#!/bin/bash

# enhance run_esp-config with software flow of booting linux

# Output styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

## Env setup ##
source /opt/cad/scripts/tools_env.sh
soc_target="socs/xilinx-vc707-xc7vx485t"
ESP_ROOT=$(realpath ../../../)
esp_config="$ESP_ROOT/$soc_target/socgen/esp/.esp_config"
fpga_run="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_program.sh"
fpga_run_linux="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_linux.sh"
monitor="$ESP_ROOT/utils/scripts/actions-pipeline/helper/monitor_linux_boot.sh"

# Specify logging directories. Clean up old log files.
logs="$ESP_ROOT/utils/scripts/actions-pipeline/logs"
if [ -d "$logs" ]; then
    rm -r "$logs"
else
    echo "Directory does not exist: $logs"
    mkdir -p "$logs"
fi
mkdir -p "$logs/hls"
mkdir -p "$logs/fpga"
mkdir -p "$logs/minicom"
mkdir -p "$logs/soft"
mkdir -p "$logs/config"

vivado_syn="$logs/hls/vivado_syn.log"
fpga_program="$logs/fpga/fpga_program.log"
run="$logs/fpga/fpga_run.log"
minicom="$logs/minicom/soc.log"
soft="$logs/soft/soft.log"
linux="$logs/soft/linux.log"
run_linux="$logs/fpga/fpga_run_linux.log"
boot_linux="$logs/soft/boot_linux.log"

cd "$ESP_ROOT/$soc_target"

## SoC flow ##

## HLS
# Clean the vivado directory and bitstream
echo -e "${BOLD}CLEANING VIVADO DIRECTORIES...${NC}"
cd "$ESP_ROOT/$soc_target"
rm top.bit
rm -rf vivado
make clean >/dev/null 2>&1
# Make esp config by default config
esp_config="$logs/config/esp_config.log"
echo -e "${BOLD}CREATING SoC CONFIG W/ ACCELERATOR...${NC}"
make esp-config > "$esp_config" 2>&1
# Generate bitstream (*** takes time ***)
echo -e "${BOLD}STARTING SoC HLS W/ ACCELERATOR...${NC}"
make vivado-syn > "$vivado_syn" 2>&1

## FPGA
# Check bitstream
if [ -s "top.bit" ]; then
    echo "[PASS] BITSTREAM IS FOUND"

    # make fpga-program
    echo "TRYING TO PROGRAM FPGA..."
	make fpga-program > "$fpga_program" 2>&1
    if grep -q ERROR "$fpga_program"; then
        echo "[FAIL] FPGA-PROGRAM FAIL"
    else
        echo "[PASS] FPGA-PROGRAM SUCCEEDED"

        # make fpga-run in foreground
        echo -e "${BOLD}WRITING BAREMETAL RESULTS TO MINICOM...${NC}"
        $fpga_run > "$run" 2>&1 &
        if grep -q ERROR "$run"; then
            echo "[FAIL] FPGA-RUN FAIL"
        else
            echo "[PASS] FPGA-RUN SUCCEEDED"
        fi
    fi

    # # open minicom session
    # echo "TRY TO OPEN MINICOM..."
    # socat pty,link=ttyV0,waitslave,mode=777 tcp:espdev.cs.columbia.edu:4322 &
    # socat_pid=$!
    # sleep 2
    # VIRTUAL_DEVICE=$(readlink ttyV0)

    # # open minicom in foreground
    # minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1
    # # minicom will be killed when make fpga-run is done

    # # clean up
    # kill -9 "$socat_pid"

else
    echo "[FAIL] BITSTREAM GENERATION FAILED"
fi
## SoC flow end ##


## Software Flow ##

# ## Prepare target
# # Clean
# echo -e "${BOLD}PRE MAKE LINUX CLEANUP...${NC}"
# make linux-distclean >/dev/null 2>&1
# # Make soft
# echo -e "${BOLD}STARTING MAKE SOFT...${NC}"
# make soft > "$soft" 2>&1
# # Check make soft success
# if [ -s "./soft-build/ariane/ram.srec" ] && [ -s "./soft-build/ariane/systest.bin" ]; then
#     echo "MAKE SOFT SUCCESS"
# else
#     echo "MAKE SOFT FAILED"
# fi
# # Make linux
# echo -e "${BOLD}STARTING MAKE LINUX...${NC}"
# make linux > "$linux" 2>&1

# ## Run software
# # check make linux success
# if [ -s "./soft-build/ariane/linux.bin" ]; then
#     echo "MAKE LINUX SUCCESS"

#     # open minicom session
#     echo "TRY TO OPEN MINICOM..."
#     socat pty,link=ttyV0,waitslave,mode=777 tcp:espdev.cs.columbia.edu:4322 &
#     socat_pid=$!
#     sleep 2
#     VIRTUAL_DEVICE=$(readlink ttyV0)

#     # make fpga-run-linux in background
#     echo -e "${BOLD}BOOTING LINUX...${NC}"
#     cd "$ESP_ROOT/$soc_target"
#     $fpga_run_linux > "$run_linux" 2>&1 &

#     # call helper to monitor linux boot progress. kill minicom if boot success.
#     $monitor > "$boot_linux" 2>&1 &
#     monitor_pid=$!

#     # open minicom in foreground
#     minicom="$logs/minicom/minicom_linux.log"
#     minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1

#     # print monitor status
#     wait $monitor_pid
#     EXIT_CODE=$?
#     if [ $EXIT_CODE -eq 0 ]; then
#     echo "Monitor script detected successful boot"
#     else
#     echo "Monitor script detected boot failure or was terminated"
#     fi

#     # clean up
#     kill -9 "$socat_pid"

# else
#     echo "MAKE LINUX FAILED"
# fi
