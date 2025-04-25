#!/bin/bash

# Output styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

## Env setup
source /opt/cad/scripts/tools_env.sh
# make fft_stratus-hls
ESP_ROOT=$(realpath ../../../)
fpga_run="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_program.sh"
fpga_run_linux="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_linux.sh"
monitor="$ESP_ROOT/utils/scripts/actions-pipeline/helper/monitor_linux_boot.sh"
exe_ssh_fft="$ESP_ROOT/utils/scripts/actions-pipeline/helper/execute_ssh_fft.sh"

# Specify logging directories. Some were created by previous action of testing soft.
logs="$ESP_ROOT/utils/scripts/actions-pipeline/logs"
rm -rf "$logs"
mkdir -p "$logs"
mkdir -p "$logs/hls"
mkdir -p "$logs/fpga"
mkdir -p "$logs/minicom"
mkdir -p "$logs/soft"
fpga_program="$logs/fpga/fpga_program.log"
run="$logs/fpga/fpga_run.log"
minicom="$logs/minicom/baremetal_hello.log"
linux="$logs/soft/linux.log"
run_linux="$logs/fpga/fpga_run_linux.log"
boot_linux="$logs/soft/boot_linux.log"
ssh_fft="$logs/soft/ssh_fft.log"
workflow_result="$logs/workflow_result.log"

soc_target="socs/xilinx-vc707-xc7vx485t"
cd "$ESP_ROOT/$soc_target"

## SoC config creation
# TODO
# make esp-xconfig

## upload bitstream
if [ -s "top.bit" ]; then
    echo "[PASS] Bitstream is found" >> "$workflow_result"

    # make fpga-program
    echo "..... Try to program FPGA" >> "$workflow_result"
	make fpga-program > "$fpga_program" 2>&1
    if grep -q ERROR "$fpga_program"; then
        echo "[FAIL] 'make fpga-program' failed" >> "$workflow_result"
    else
        echo "[PASS] 'make fpga-program' pass" >> "$workflow_result"
    fi

    # open minicom session
    echo "..... Try to open minicom" >> "$workflow_result"
    socat pty,link=ttyV0,waitslave,mode=777 tcp:espdev.cs.columbia.edu:4322 &
    socat_pid=$!
    sleep 2
    VIRTUAL_DEVICE=$(readlink ttyV0)

    # make fpga-run in background
    echo -e "... Writing baremetal to minicom" >> "$workflow_result"
    cd "$ESP_ROOT/$soc_target"
    $fpga_run > "$run" 2>&1 &

    # open minicom in foreground
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1
    # minicom will be killed when make fpga-run is done
    # check "hello" message
    if grep -q "Hello from ESP!" "$minicom"; then
        echo "[PASS] Baremetal hello message found" >> "$workflow_result"
    else
        echo "[FAIL] Baremetal hello message not found" >> "$workflow_result"
    fi

    # clean up
    kill -9 "$socat_pid"

else
    echo "[FAIL] Bitstream generation failed" >> "$workflow_result"
fi
## SoC flow end ##

## Software Flow ##
## suppose targets are prepared
## fft workflow
# make linux-distclean
# make linux
# make examples
# make linux

## Run Software
if [ -s "./soft-build/ariane/linux.bin" ]; then
    echo "[PASS] 'make linux' pass" >> "$workflow_result"

    # open minicom session
    echo "..... Try to open minicom" >> "$workflow_result"
    socat pty,link=ttyV0,waitslave,mode=777 tcp:espdev.cs.columbia.edu:4322 &
    socat_pid=$!
    sleep 2
    VIRTUAL_DEVICE=$(readlink ttyV0)

    # make fpga-run-linux in background
    echo "..... Try to boot linux" >> "$workflow_result"
    cd "$ESP_ROOT/$soc_target"
    $fpga_run_linux > "$run_linux" 2>&1 &

    # call helper to monitor linux boot progress. kill minicom if boot successfully.
    $monitor > "$boot_linux" 2>&1 &
    monitor_pid=$!

    # open minicom in foreground
    minicom="$logs/minicom/linux_boot.log"
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1

    # print monitor status
    wait $monitor_pid
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo "[PASS] Linux boot pass" >> "$workflow_result"

        # execute ssh and fft
        cd "$ESP_ROOT/utils/scripts/actions-pipeline/helper"
        echo "..... Try ssh and run fft" >> "$workflow_result"
        $exe_ssh_fft > "$ssh_fft" 2>&1
        echo "..... End of ssh and run fft" >> "$workflow_result"

        # redirect overall fft result into main workflow result file
        grep "FFT OVERALL TEST RESULT" "$ssh_fft" >> "$workflow_result"
    else
        echo "[FAIL] Linux boot fail" >> "$workflow_result"
        killall -u $(whoami) minicom
    fi

else
    echo "[FAIL] 'make linux' fail" >> "$workflow_result"
fi
