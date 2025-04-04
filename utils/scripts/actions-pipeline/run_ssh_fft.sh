#!/bin/bash

# Output styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

### Env setup ###
source /opt/cad/scripts/tools_env.sh
# make fft_stratus-hls
ESP_ROOT=$(realpath ../../../)
fpga_run="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_program.sh"
fpga_run_linux="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_linux.sh"
monitor="$ESP_ROOT/utils/scripts/actions-pipeline/helper/monitor_linux_boot.sh"
run_ssh_fft="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_ssh_fft.sh"
# logs
fpga_program="$logs/fpga/fpga_program.log"
minicom="$logs/minicom/soc.log"
linux="$logs/soft/linux.log"
run_linux="$logs/fpga/fpga_run_linux.log"
boot_linux="$logs/soft/boot_linux.log"
ssh_fft="$logs/soft/ssh_fft.log"

cd "$ESP_ROOT/socs/xilinx-vc707-xc7vx485t"

# ### SoC config creation ###
# # esp config
# make esp-xconfig

# ### fft workflow ###
# make linux-distclean
# make linux
# make examples
# make linux

# upload bitstream
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


## Run software ##
# run linux, ssh, and fft
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

    # call helper to monitor linux boot progress. 
    # TODO: do not kill minicom if boot success. the linux will be used later.
    $monitor > "$boot_linux" 2>&1 &
    monitor_pid=$!

    # open minicom in foreground
    minicom="$logs/minicom/minicom_linux.log"
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1

    # print monitor status
    wait $monitor_pid
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
    echo "Monitor script detected successful boot"
    else
    echo "Monitor script detected boot failure or was terminated"
    fi

    # TODO: run ssh_fft script
    $run_ssh_fft > "$ssh_fft" 2>&1 &

    # clean up
    kill -9 "$socat_pid"

    # kill minicom manually
    # killall -u $(whoami) minicom

else
    echo ""
    echo "MAKE LINUX FAILED"
fi