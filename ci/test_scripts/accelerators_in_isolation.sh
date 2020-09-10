#!/bin/bash

source /opt/cad/scripts/tools_env.sh
cd socs/xilinx-vc707-xc7vx485t
make fft-sim
make fft-hls
