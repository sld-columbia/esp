#!/bin/bash

# set print styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

## Env setup ---------------------------------------
source /opt/cad/scripts/tools_env.sh    # for unit testing script
ESP_ROOT=$(realpath ../../../)

## set soc and esp config file
soc_name="xilinx-vc707-xc7vx485t"
soc_target="socs/xilinx-vc707-xc7vx485t"
testing_config="$ESP_ROOT/socs/defconfig/esp_xilinx-vc707-xc7vx485t_testing"
esp_config="$ESP_ROOT/$soc_target/socgen/esp/.esp_config"

## set helper scripts
fpga_run="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_run.sh"
fpga_run_linux="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_linux.sh"
monitor="$ESP_ROOT/utils/scripts/actions-pipeline/helper/monitor_linux_boot.sh"
exe_ssh_fft="$ESP_ROOT/utils/scripts/actions-pipeline/helper/execute_ssh_fft.sh"

## set log files
logs="$ESP_ROOT/utils/scripts/actions-pipeline/${soc_name}_logs"
if [ -d "$logs" ]; then
    rm -rf "$logs"
else
    mkdir -p "$logs"
fi
mkdir -p "$logs/esp"
mkdir -p "$logs/fpga"   # results happened on fpga

workflow_result="$logs/workflow_result.log"
fpga_program_log="$logs/esp/fpga_program.log"
fpga_run_log="$logs/esp/fpga_run.log"
fpga_run_linux_log="$logs/fpga/fpga_run_linux.log"
boot_linux_log="$logs/fpga/boot_linux.log"
minicom_log="$logs/fpga/minicom_baremetal.log"
ssh_fft_log="$logs/fpga/ssh_fft.log"

## SoC ---------------------------------------
## setup env
cd "$ESP_ROOT/$soc_target"
rm -rf vivado
rm -rf top.bit
make clean >/dev/null 2>&1

## prep files
echo -e "Config ESP" >> "$workflow_result"
cp "$testing_config" "$esp_config"
make esp-config > "$logs/esp/esp_config.log" 2>&1

echo -e "Execute HLS" >> "$workflow_result"
make vivado-syn > "$logs/esp/vivado_syn.log" 2>&1

## run on fpga
if [ -s "top.bit" ]; then
    echo "[PASS] Bitstream is found" >> "$workflow_result"

    # make fpga-program
    cd "$ESP_ROOT/$soc_target"
    echo "..... Try to program FPGA" >> "$workflow_result"
	make fpga-program > "$fpga_program_log" 2>&1
    if grep -q ERROR "$fpga_program_log"; then
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
    $fpga_run > "$fpga_run_log" 2>&1 &

    # open minicom in foreground
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom_log" 2>&1
    # minicom will be killed when make fpga-run is done
    # check "hello" message
    if grep -q "Hello from ESP!" "$minicom_log"; then
        echo "[PASS] Baremetal hello message found" >> "$workflow_result"
    else
        echo "[FAIL] Baremetal hello message not found" >> "$workflow_result"
    fi

    # clean up
    kill -9 "$socat_pid"
else
    echo "[FAIL] Bitstream generation failed" >> "$workflow_result"
fi

## Linux ---------------------------------------
# ## setup
make fft_stratus-hls
cd "$ESP_ROOT/$soc_target"
make linux-distclean
## prep files
make soft
make linux
make examples
make linux

cd "$ESP_ROOT/$soc_target"
## run on fpga
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
    $fpga_run_linux > "$fpga_run_linux_log" 2>&1 &

    # call helper to monitor linux boot progress. kill minicom if boot successfully.
    $monitor > "$boot_linux_log" 2>&1 &
    monitor_pid=$!

    # open minicom in foreground
    minicom="$logs/fpga/minicom_boot_linux.log"
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1

    # print monitor status
    wait $monitor_pid
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo "[PASS] Linux boot pass" >> "$workflow_result"

        ## Application ---------------------------------------
        # execute ssh and fft
        cd "$ESP_ROOT/utils/scripts/actions-pipeline/helper"
        echo "..... Try ssh and run fft" >> "$workflow_result"
        $exe_ssh_fft > "$ssh_fft_log" 2>&1
        echo "..... End of ssh and run fft" >> "$workflow_result"

        # redirect overall fft result into main workflow result file
        grep "FFT OVERALL TEST RESULT" "$ssh_fft_log" >> "$workflow_result"
    else
        echo "[FAIL] Linux boot fail" >> "$workflow_result"
        killall -u $(whoami) minicom
    fi

else
    echo "[FAIL] 'make linux' fail" >> "$workflow_result"
fi
