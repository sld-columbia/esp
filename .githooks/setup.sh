#!/bin/bash

cp "$HOME/esp/.githooks/pre-push.sh" "$HOME/esp/.git/hooks/pre-push"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy pre-push hook."
    exit 1
fi

chmod +x "$HOME/esp/.git/hooks/pre-push"
if [ $? -ne 0 ]; then
    echo "Error: Failed to make pre-push hook executable."
    exit 1
fi

echo "Pre-push hook activated successfully."