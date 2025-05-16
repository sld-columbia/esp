#!/bin/bash

# helper script to execute baremetal hello, check result.

sleep 10
make fpga-run

sleep 10
if grep -q "Hello from ESP!" "$1"; then
    echo "[PASS] Baremetal hello message found (helper)" >> "$2"
else
    echo "[FAIL] Baremetal hello message not found (helper)" >> "$2"
fi

killall -9 -u $(whoami) minicom