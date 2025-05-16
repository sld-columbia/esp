#!/bin/bash
ESP_ROOT=$(realpath ../../../)
soc_name="xilinx-vc707-xc7vx485t"
logs="$ESP_ROOT/utils/scripts/actions-pipeline/${soc_name}_logs"
minicom_log="$logs/fpga/minicom_baremetal.log"

sleep 5
make fpga-run

sleep 10
if grep -q "Hello from ESP!" "$minicom_log"; then
    echo "[PASS] Baremetal hello message found (helper)" >> "$workflow_result"
else
    echo "[FAIL] Baremetal hello message not found (helper)" >> "$workflow_result"
fi

! killall -9 -u $(whoami) minicom