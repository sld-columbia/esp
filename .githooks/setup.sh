#!/bin/bash

# Copy pre-push hook script to .git/hooks directory
cp .githooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push

echo "Pre-push hook activated successfully."