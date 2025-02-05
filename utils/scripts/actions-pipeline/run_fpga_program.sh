#!/bin/bash

cd "$HOME/esp/socs/xilinx-vc707-xc7vx485t"
sleep 10

make fpga-run

! killall -9 minicom