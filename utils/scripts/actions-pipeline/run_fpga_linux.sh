#!/bin/bash

cd "$HOME/esp/socs/xilinx-vc707-xc7vx485t"
sleep 10

make fpga-run-linux

# ensure minicom is not running
! killall -9 minicom