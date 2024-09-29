#!/bin/bash

FORMAT_SCRIPT="$HOME/esp/utils/scripts/format/format.sh"

if [ ! -f "$FORMAT_SCRIPT" ]; then
    echo "Error: Formatting script not found"
    exit 1
fi

cd "$(dirname "$FORMAT_SCRIPT")" || exit

echo "Running code format check with pre-push hook..."
./$(basename "$FORMAT_SCRIPT") -g -ca