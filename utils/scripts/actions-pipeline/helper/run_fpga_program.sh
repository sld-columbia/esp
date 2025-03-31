#!/bin/bash

sleep 5

make fpga-run

! killall -9 -u $(whoami) minicom