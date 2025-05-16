#!/bin/bash

# set print styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

## set JSON file. a JSON file with config information
json_file="esp_configs.json"
if [ ! -f "$json_file" ]; then
    echo "Error: JSON file '$json_file' not found!"
    exit 1
fi
config_count=$(jq '.configs | length' "$json_file")
# check if there are any configs
if [ "$config_count" -eq 0 ]; then
    echo "Error: No configurations found in the JSON file!"
    exit 1
fi
# read JSON content
config_index=0  # this workflow template works on testing 1 config. could be expanded.
config_name=$(jq -r ".configs[$config_index].config_name" "$json_file")
fpga_name=$(jq -r ".configs[$config_index].fpga_name" "$json_file")
config_path=$(jq -r ".configs[$config_index].config_path" "$json_file")
result_logs_path=$(jq -r ".configs[$config_index].result_logs_path" "$json_file")
uart_ip=$(jq -r ".configs[$config_index].UART_IP" "$json_file")
uart_port=$(jq -r ".configs[$config_index].UART_PORT" "$json_file")
ssh_ip=$(jq -r ".configs[$config_index].SSH_IP" "$json_file")
ssh_port=$(jq -r ".configs[$config_index].SSH_PORT" "$json_file")

echo "Config Name: $config_name"
echo "FPGA Name: $fpga_name"
echo "Config Path: $config_path"
echo "Result Logs Path: $result_logs_path"
echo "UART IP: $uart_ip"
echo "UART Port: $uart_port"
echo "SSH IP: $ssh_ip"
echo "SSH Port: $ssh_port"

## Env setup ---------------------------------------
source /opt/cad/scripts/tools_env.sh    # for unit testing script
## set paths
ESP_ROOT=$(realpath ../../../)

## set log files
logs="$ESP_ROOT/$result_logs_path"
if [ ! -d "$logs" ]; then
    mkdir -p "$logs"
else
    # optional to remove existing log folder
    # rm -rf "$logs"
    echo "Directory $logs already exists."
fi

if [ ! -d "$logs/esp" ]; then
    mkdir -p "$logs/esp"
else
    # optional to remove existing log folder
    # rm -rf "$logs/esp"
    echo "Directory $logs/esp already exists."
fi

mkdir -p "$logs/fpga"   # results happened on fpga
workflow_result="$logs/workflow_result.log"
fpga_program_log="$logs/esp/fpga_program.log"
fpga_run_log="$logs/esp/fpga_run.log"
fpga_run_linux_log="$logs/esp/fpga_run_linux.log"
boot_linux_log="$logs/fpga/boot_linux.log"
minicom_log="$logs/fpga/minicom_baremetal.log"
minicom_boot_linux_log="$logs/fpga/minicom_boot_linux.log"
ssh_fft_log="$logs/fpga/ssh_fft.log"

## set helper scripts
gen_bit="$ESP_ROOT/utils/scripts/actions-pipeline/helper/gen_bitstream.sh"
gen_linux="$ESP_ROOT/utils/scripts/actions-pipeline/helper/gen_linux.sh"
fpga_run="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_run.sh $minicom_log $workflow_result"
fpga_run_linux="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_linux.sh"
monitor="$ESP_ROOT/utils/scripts/actions-pipeline/helper/monitor_linux_boot.sh $minicom_boot_linux_log"
exe_ssh_fft="$ESP_ROOT/utils/scripts/actions-pipeline/helper/execute_ssh_fft.sh $ssh_port root $ssh_ip openesp"
## set set esp config file
testing_config="$ESP_ROOT/$config_path"
esp_config="$ESP_ROOT/socs/$fpga_name/socgen/esp/.esp_config"   # actual path for esp. will be replaced by target testing config
cp "$testing_config" "$logs/esp"    # copy a testing config into log folder for reference

## SoC ---------------------------------------
cd "$ESP_ROOT/socs/$fpga_name"

# ## config and HLS. (optional to run together with this workflow)
# $gen_bit
# gen_bit_pid=$!
# wait $gen_bit
# EXIT_CODE=$?
# if [ $EXIT_CODE -eq 1 ]; then
#     echo -e "${BOLD}[FAIL] Generate Bitstream failed${NC}"
#     echo "[FAIL] Generate Bitstream failed" >> "$workflow_result"
#     exit 1
# fi

## run on fpga
if [ -s "top.bit" ]; then
    echo -e "${BOLD}Bitstream is found${NC}"
    echo "Bitstream is found" >> "$workflow_result"

    # make fpga-program
    cd "$ESP_ROOT/socs/$fpga_name"
    echo -e "${BOLD}..... Try to program FPGA${NC}"
    echo "..... Try to program FPGA" >> "$workflow_result"
	make fpga-program > "$fpga_program_log" 2>&1
    if grep -q ERROR "$fpga_program_log"; then
        echo -e "${BOLD}[FAIL] 'make fpga-program' failed${NC}"
        echo "[FAIL] 'make fpga-program' failed" >> "$workflow_result"
        exit 1
    else
        echo -e "${BOLD}[PASS] 'make fpga-program' pass${NC}"
        echo "[PASS] 'make fpga-program' pass" >> "$workflow_result"
    fi

    # open minicom session
    killall -9 -u $(whoami) minicom     # make sure no running minicom
    echo -e "${BOLD}..... Try to open minicom${NC}"
    echo "..... Try to open minicom" >> "$workflow_result"
    socat pty,link=ttyV0,waitslave,mode=777 tcp:$uart_ip:$uart_port &
    socat_pid=$!
    sleep 2
    VIRTUAL_DEVICE=$(readlink ttyV0)

    # make fpga-run in background
    echo -e "${BOLD}..... Writing baremetal to minicom${NC}"
    echo -e "..... Writing baremetal to minicom" >> "$workflow_result"
    cd "$ESP_ROOT/socs/$fpga_name"
    $fpga_run > "$fpga_run_log" 2>&1 &
    fpgarun_pid=$!

    # open minicom in background
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom_log" 2>&1
    # make fpga-run script will kill minicom

    # check "hello" message
    wait $fpgarun_pid
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${BOLD}[FAIL] 'make fpga-run' failed"
        echo "[FAIL] 'make fpga-run' failed" >> "$workflow_result"
        # clean minicom
        rm -rf ttyV0 
        kill -9 "$socat_pid"
        killall -9 -u $(whoami) minicom
        exit 1
    else
        echo -e "${BOLD}[PASS] 'make fpga-run' pass"
        echo "[PASS] 'make fpga-run' pass" >> "$workflow_result"

        if grep -q "Hello from ESP!" "$minicom_log"; then
            echo -e "${BOLD} -- Baremetal hello message found"
            echo " -- Baremetal hello message found" >> "$workflow_result"
        else
            echo -e "${BOLD}[FAIL] Baremetal hello message not found${NC}"
            echo "[FAIL] Baremetal hello message not found" >> "$workflow_result"
        fi
    fi
else
    echo -e "${BOLD}[FAIL] Bitstream not found${NC}"
    echo "[FAIL] Bitstream not found" >> "$workflow_result"
fi
# clean minicom
rm -rf ttyV0 
kill -9 "$socat_pid"
killall -9 -u $(whoami) minicom

## Linux ---------------------------------------
# ## Generate Linux Image. (optional to run together with this workflow)
# $gen_linux
# gen_linux_pid=$!
# wait $gen_linux
# EXIT_CODE=$?
# if [ $EXIT_CODE -eq 1 ]; then
#     echo -e "${BOLD}[FAIL] Generate Linux failed${NC}"
#     echo "[FAIL] Generate Linux failed" >> "$workflow_result"
#     exit 1
# fi

cd "$ESP_ROOT/socs/$fpga_name"
## run on fpga
if [ -s "./soft-build/ariane/linux.bin" ]; then
    echo -e "${BOLD}[PASS] Linux image is found${NC}"
    echo "[PASS] Linux image is found" >> "$workflow_result"

    # open minicom session
    killall -9 -u $(whoami) minicom     # make sure no running minicom
    echo -e "${BOLD}..... Try to open minicom${NC}"
    echo "..... Try to open minicom" >> "$workflow_result"
    socat pty,link=ttyV0,waitslave,mode=777 tcp:$uart_ip:$uart_port &
    socat_pid=$!
    sleep 2
    VIRTUAL_DEVICE=$(readlink ttyV0)

    # make fpga-run-linux in background
    echo -e "${BOLD}..... Try to boot linux${NC}"
    echo "..... Try to boot linux" >> "$workflow_result"
    cd "$ESP_ROOT/socs/$fpga_name"
    $fpga_run_linux > "$fpga_run_linux_log" 2>&1 &

    # call helper to monitor linux boot progress.
    $monitor > "$boot_linux_log" 2>&1 &
    monitor_pid=$!

    # open minicom in foreground
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom_boot_linux_log" 2>&1
    # monitor kills minicom if boot successfully

    # print monitor status
    wait $monitor_pid
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${BOLD}[PASS] Linux boot pass${NC}"
        echo "[PASS] Linux boot pass" >> "$workflow_result"

        ## Application ---------------------------------------
        # execute ssh and fft
        cd "$ESP_ROOT/utils/scripts/actions-pipeline/helper"
        echo -e "${BOLD}..... Try ssh and run fft${NC}"
        echo "..... Try ssh and run fft" >> "$workflow_result"
        $exe_ssh_fft > "$ssh_fft_log" 2>&1
        echo -e "${BOLD}..... End of ssh and run fft${NC}"
        echo "..... End of ssh and run fft" >> "$workflow_result"

        # redirect overall fft result into main workflow result file
        grep "FFT OVERALL TEST RESULT" "$ssh_fft_log" >> "$workflow_result"
    else
        echo -e "${BOLD}[FAIL] Linux boot fail${NC}"
        echo "[FAIL] Linux boot fail" >> "$workflow_result"
        # clean minicom
        rm -rf ttyV0 
        kill -9 "$socat_pid"
        killall -9 -u $(whoami) minicom
        exit 1
    fi

else
    echo -e "${BOLD}[FAIL] Linux image not found${NC}"
    echo "[FAIL] Linux image not found" >> "$workflow_result"
    exit 1
fi
# clean minicom
rm -rf ttyV0 
kill -9 "$socat_pid"
killall -9 -u $(whoami) minicom