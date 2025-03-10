#!/bin/bash

sleep 5

make fpga-run-linux

# ! killall -9 -u $(whoami) minicom