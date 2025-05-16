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
config_index=0  # default work on testing 1 config
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
## set helper scripts
fpga_run="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_run.sh"
fpga_run_linux="$ESP_ROOT/utils/scripts/actions-pipeline/helper/run_fpga_linux.sh"
monitor="$ESP_ROOT/utils/scripts/actions-pipeline/helper/monitor_linux_boot.sh"
exe_ssh_fft="$ESP_ROOT/utils/scripts/actions-pipeline/helper/execute_ssh_fft.sh"
## set paths
ESP_ROOT=$(realpath ../../../)
## set soc and esp config file
soc_target="socs/$fpga_name"
testing_config="$ESP_ROOT/$config_path"
esp_config="$ESP_ROOT/socs/$fpga_name/socgen/esp/.esp_config"   # actual path for esp. will be replaced by target testing config.

## set log files
logs="$ESP_ROOT/$result_logs_path"
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
fpga_run_linux_log="$logs/esp/fpga_run_linux.log"
boot_linux_log="$logs/fpga/boot_linux.log"
minicom_log="$logs/fpga/minicom_baremetal.log"
ssh_fft_log="$logs/fpga/ssh_fft.log"

## SoC ---------------------------------------
cd "$ESP_ROOT/socs/$fpga_name"
# ## setup env
# rm -rf vivado
# rm -rf top.bit
# make clean >/dev/null 2>&1

# ## prep files
# echo -e "${BOLD}Configure ESP${NC}"
# echo -e "Configure ESP" >> "$workflow_result"
# cp "$testing_config" "$esp_config"
# make esp-config > "$logs/esp/esp_config.log" 2>&1

# echo -e "${BOLD}Execute HLS${NC}"
# echo -e "Execute HLS" >> "$workflow_result"
# make vivado-syn > "$logs/esp/vivado_syn.log" 2>&1
# echo -e "${BOLD}HLS done${NC}"
# echo "HLS done" >> "$workflow_result"

## run on fpga
if [ -s "top.bit" ]; then
    echo -e "${BOLD}[PASS] Bitstream is found${NC}"
    echo "[PASS] Bitstream is found" >> "$workflow_result"

    # make fpga-program
    cd "$ESP_ROOT/socs/$fpga_name"
    echo -e "${BOLD}..... Try to program FPGA${NC}"
    echo "..... Try to program FPGA" >> "$workflow_result"
	make fpga-program > "$fpga_program_log" 2>&1
    if grep -q ERROR "$fpga_program_log"; then
        echo -e "${BOLD}[FAIL] 'make fpga-program' failed${NC}"
        echo "[FAIL] 'make fpga-program' failed" >> "$workflow_result"
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
    echo -e "${BOLD}... Writing baremetal to minicom${NC}"
    echo -e "... Writing baremetal to minicom" >> "$workflow_result"
    cd "$ESP_ROOT/socs/$fpga_name"
    $fpga_run > "$fpga_run_log" 2>&1 &

    # open minicom in background
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom_log" 2>&1
    # minicom will be killed when make fpga-run is done

    # check "hello" message
    wait $fpgarun_pid
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        if grep -q "Hello from ESP!" "$minicom_log"; then
            echo -e "${BOLD}[PASS] Baremetal hello message found"
            echo "[PASS] Baremetal hello message found" >> "$workflow_result"
        else
            echo -e "${BOLD}[FAIL] Baremetal hello message not found${NC}"
            echo "[FAIL] Baremetal hello message not found" >> "$workflow_result"

            # clean up
            rm -rf ttyV0 
            kill -9 "$socat_pid"
            killall -9 -u $(whoami) minicom
            # early terminate the script
            exit 1
        fi
    else
        echo -e "${BOLD}[FAIL] fpga-run failed"
        echo "[FAIL] fpga-run failed" >> "$workflow_result"
    fi

    # clean up
    rm -rf ttyV0 
    kill -9 "$socat_pid"
    killall -9 -u $(whoami) minicom
else
    echo -e "${BOLD}[FAIL] Bitstream generation failed${NC}"
    echo "[FAIL] Bitstream generation failed" >> "$workflow_result"
fi
killall -9 -u $(whoami) minicom     # make sure no running minicom

## Linux ---------------------------------------
## setup
cd "$ESP_ROOT/socs/$fpga_name"
# make fft_stratus-hls
# make linux-distclean
# ## prep files
# make soft
# make linux
# make examples
# make linux

cd "$ESP_ROOT/socs/$fpga_name"
## run on fpga
if [ -s "./soft-build/ariane/linux.bin" ]; then
    echo -e "${BOLD}[PASS] 'make linux' pass${NC}"
    echo "[PASS] 'make linux' pass" >> "$workflow_result"

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
        killall -u $(whoami) minicom
    fi

else
    echo -e "${BOLD}[FAIL] 'make linux' fail${NC}"
    echo "[FAIL] 'make linux' fail" >> "$workflow_result"
fi
killall -9 -u $(whoami) minicom     # make sure no running minicom

## redirect workflow result. print to standard output.
if [ -r "$workflow_result" ]; then
  echo "--- Content of $workflow_result ---"
  echo "$(<"$workflow_result")"
  echo "--- End of content ---"
else
  echo "Error: File '$workflow_result' not found or not readable."
fi