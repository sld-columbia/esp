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
if [ -d "$logs" ]; then
    rm -rf "$logs"
    echo "Overwriting existing $logs"
else
    echo "Creating new $logs"
fi

mkdir -p "$logs/esp"



workflow_result="$logs/workflow_result.log"
## set esp config file
testing_config="$ESP_ROOT/$config_path"
esp_config="$ESP_ROOT/socs/$fpga_name/socgen/esp/.esp_config"   # actual path for esp. will be replaced by target testing config.

## SoC ---------------------------------------
cd "$ESP_ROOT/socs/$fpga_name"
## setup env
rm -rf vivado
rm -rf top.bit
make clean >/dev/null 2>&1

## prep files
echo -e "${BOLD}Configure ESP${NC}"
echo -e "Configure ESP" >> "$workflow_result"
cp "$testing_config" "$esp_config"
make esp-config > "$logs/esp/make_esp_config.log" 2>&1

echo -e "${BOLD}Running Logic Synthesis${NC}"
echo -e "Execute Logic Synthesis" >> "$workflow_result"
make vivado-syn > "$logs/esp/vivado_syn.log" 2>&1   # could be optimized
echo -e "${BOLD}Logic Synthesis done${NC}"
echo "Logic Synthesis done" >> "$workflow_result"

if [ -s "top.bit" ]; then
    echo -e "${BOLD}[PASS] Logic Synthesis Success${NC}"
    echo "[PASS] Logic Synthesis Logic Synthesis" >> "$workflow_result"
else
    echo -e "${BOLD}[FAIL] Logic Synthesis Fail${NC}"
    echo "Logic Synthesis Fail" >> "$workflow_result"
    exit 1
fi
