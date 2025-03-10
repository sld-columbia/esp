#!/bin/bash

# helper script to monitor linux boot progress

# Env setup
ESP_ROOT=$(realpath ../../)
logs="$ESP_ROOT/utils/scripts/actions-pipeline/logs"
minicom="$logs/minicom/minicom_linux.log"

# Target
SUCCESS_PATTERN="Welcome to ESP"

# Ensure log file exist
if [ ! -f "$minicom" ]; then
  echo "Log file $minicom does not exist yet. Waiting..."
  sleep 10
  continue
fi

# Monitor the log file for success pattern
while true; do
  if grep -q "$SUCCESS_PATTERN" "$minicom"; then
    echo "Boot completed successfully!"
    killall -u $(whoami) minicom
    sleep 3
    exit 0
  fi
  
  # Check for common failure patterns
  if grep -q "Kernel panic" "$minicom"; then
    echo "Boot failed: Kernel panic detected"
    exit 1
  fi
  
  sleep 3
done