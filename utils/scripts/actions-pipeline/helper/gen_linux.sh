#!/bin/bash

## set print styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

## set JSON file. a JSON file with config information
json_file="../esp_configs.json"
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

echo "Config Name: $config_name"
echo "FPGA Name: $fpga_name"
echo "Config Path: $config_path"
echo "Result Logs Path: $result_logs_path"

## Env setup ---------------------------------------
source /opt/cad/scripts/tools_env.sh
## set paths
ESP_ROOT=$(realpath ../../../../)
## set log files
logs="$ESP_ROOT/$result_logs_path"
if [ ! -d "$logs" ]; then
    mkdir -p "$logs"
fi
workflow_result="$logs/workflow_result.log"

## Linux ---------------------------------------
## setup
cd "$ESP_ROOT/socs/$fpga_name"
make fft_stratus-hls
make linux-distclean
sleep 5

## prep files
make soft
make linux
make examples
make linux

if [ -s "./soft-build/ariane/linux.bin" ]; then
    echo -e "${BOLD}[PASS] 'make linux' pass${NC}"
    echo "[PASS] 'make linux' pass" >> "$workflow_result"
else
    echo -e "${BOLD}[FAIL] 'make linux' fail${NC}"
    echo "[FAIL] 'make linux' fail" >> "$workflow_result"
fi