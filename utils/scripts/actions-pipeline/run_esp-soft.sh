#!/bin/bash

# enhance run_esp-config with software flow of booting linux

# Output styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

### Env setup ###
source /opt/cad/scripts/tools_env.sh
ESP_ROOT=$(realpath ../../../)
esp_config="$ESP_ROOT/socs/xilinx-vc707-xc7vx485t/socgen/esp/.esp_config"
fpga_run="$ESP_ROOT/utils/scripts/actions-pipeline/run_fpga_program.sh"
fpga_run_linux="$ESP_ROOT/utils/scripts/actions-pipeline/run_fpga_linux.sh"
logs="$ESP_ROOT/utils/scripts/actions-pipeline/logs"

# Specify logging directories. Clean up old log files.
if [ -d "$logs" ]; then
    rm -r "$logs"
else
    echo "Directory does not exist: $logs"
fi
mkdir -p "$logs"
mkdir -p "$logs/hls"
mkdir -p "$logs/fpga"
mkdir -p "$logs/minicom"
mkdir -p "$logs/soft"

vivado_syn="$logs/hls/vivado_syn.log"
fpga_program="$logs/fpga/fpga_program.log"
run="$logs/fpga/fpga_run.log"
minicom="$logs/minicom/minicom_soc.log"
soft="$logs/soft/soft.log"
linux="$logs/soft/linux.log"
run_linux="$logs/fpga/fpga_run_linux.log"

cd "$ESP_ROOT/socs/xilinx-vc707-xc7vx485t"

### SoC flow ###

## HLS ##
# Clean the vivado directory and bitstream
echo ""
echo -e "${BOLD}CLEANING VIVADO DIRECTORIES...${NC}"
cd "$ESP_ROOT/socs/xilinx-vc707-xc7vx485t"
rm top.bit
rm -rf vivado
make clean >/dev/null 2>&1
echo ""
# Make esp config by default config
esp_config="$logs/config/esp_config.log"
echo ""
echo -e "${BOLD}CREATING SoC CONFIG W/ ACCELERATOR...${NC}"
make esp-config > "$esp_config" 2>&1
# Generate bitstream (*** takes time ***)
echo ""
echo -e "${BOLD}STARTING SoC HLS W/ ACCELERATOR...${NC}"
make vivado-syn > "$vivado_syn" 2>&1

## FPGA ##
# Check bitstream
if [ -s "top.bit" ]; then
    echo ""
    echo "BITSTREAM IS FOUND"

    # make fpga-program
    echo ""
    echo "TRYING TO PROGRAM FPGA..."
	make fpga-program > "$fpga_program" 2>&1
    if grep -q ERROR "$fpga_program"; then
        echo ""
        echo -e "FPGA-PROGRAM FAILED..."
    else
        echo ""
        echo -e "FPGA-PROGRAM SUCCEEDED..."
    fi

    # open minicom session
    echo ""
    echo "TRY TO OPEN MINICOM..."
    socat pty,link=ttyV0,waitslave,mode=777 tcp:espdev.cs.columbia.edu:4322 &
    socat_pid=$!
    sleep 2
    VIRTUAL_DEVICE=$(readlink ttyV0)

    # make fpga-run in background
    echo ""
    echo -e "${BOLD}WRITING BAREMETAL RESULTS TO MINICOM...${NC}"
    cd "$ESP_ROOT/socs/xilinx-vc707-xc7vx485t"
    $fpga_run > "$run" 2>&1 &

    # open minicom in foreground
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1
    # minicom will be killed when make fpga-run is done

    # clean up
    kill -9 "$socat_pid"

else
    echo ""
    echo "BITSTREAM GENERATION FAILED"
fi

### Software Flow ###

## Prepare target ##
# Clean
echo ""
echo -e "${BOLD}PRE MAKE LINUX CLEANUP...${NC}"
make linux-distclean >/dev/null 2>&1
# Make soft
make soft
echo ""
echo -e "${BOLD}STARTING MAKE SOFT...${NC}"
make soft > "$soft" 2>&1
# Check make soft success
if [ -s "./soft-build/ariane/ram.srec" ] && [ -s "./soft-build/ariane/systest.bin" ]; then
    echo ""
    echo "MAKE SOFT SUCCESS"
else
    echo ""
    echo "MAKE SOFT FAILED"
fi
# Make linux
echo ""
echo -e "${BOLD}STARTING MAKE LINUX...${NC}"
make linux > "$linux" 2>&1

## Run software ##
# check make linux success
if [ -s "./soft-build/ariane/linux.bin" ]; then
    echo ""
    echo "MAKE LINUX SUCCESS"

    # open minicom session
    echo ""
    echo "TRY TO OPEN MINICOM..."
    socat pty,link=ttyV0,waitslave,mode=777 tcp:espdev.cs.columbia.edu:4322 &
    socat_pid=$!
    sleep 2
    VIRTUAL_DEVICE=$(readlink ttyV0)

    # make fpga-run-linux in background
    echo ""
    echo -e "${BOLD}BOOTING LINUX...${NC}"
    cd "$ESP_ROOT/socs/xilinx-vc707-xc7vx485t"
    $fpga_run_linux > "$run_linux" 2>&1 &

    # open minicom in foreground
    minicom="$logs/minicom/minicom_linux.log"
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1
    # minicom will NOT kill. stop minicom manually

    # clean up
    kill -9 "$socat_pid"

else
    echo ""
    echo "MAKE LINUX FAILED"
fi
