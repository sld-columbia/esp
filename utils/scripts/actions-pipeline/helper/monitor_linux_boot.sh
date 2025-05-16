#!/bin/bash

# helper script to monitor linux boot progress

# Target
SUCCESS_PATTERN="Welcome to ESP"

# Ensure log file exist
if [ ! -f "$1" ]; then
  echo "Log file $1 does not exist yet. Waiting..."
  sleep 10
  continue
fi

# Monitor the log file for success pattern
while true; do
  if grep -q "$SUCCESS_PATTERN" "$1"; then
    echo "Boot completed successfully!"
    killall -u $(whoami) minicom
    sleep 3
    exit 0
  fi
  
  # Check for common failure patterns
  if grep -q "Kernel panic" "$1"; then
    echo "Boot failed: Kernel panic detected"
    killall -u $(whoami) minicom
    sleep 3
    exit 1
  fi
  
  sleep 3
done