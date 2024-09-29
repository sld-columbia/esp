#!/bin/bash

cp $HOME/esp/.githooks/pre-push.sh $HOME/esp/.git/hooks/pre-push
chmod +x $HOME/esp/.git/hooks/pre-push

echo "Pre-push hook activated successfully."