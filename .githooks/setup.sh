#!/bin/bash

cp .githooks/pre-push.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push

echo "Pre-push hook activated successfully."