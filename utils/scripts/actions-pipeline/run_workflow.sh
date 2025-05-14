#!/bin/bash

# set print styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

# set helper scripts


# set soc and esp config file
soc_target_dir="socs/xilinx-vc707-xc7vx485t"    # directory to switch to
esp_config_path="<path to target esp config>"   # file path

for one esp config do the following
{
    # set log files

    # soc ---------------------------------------
    # setup
    make clean
	rm -rf vivado
    rm top.bit
    # task - prep files
    make esp-config
    make vivado-syn
    # task - run on fpga
    check top.bit
    make fpga-program
    # testing [baremetal hello]
    open minicom
        make fpga-run &
        kill minicom
    kill minicom

    # software ---------------------------------------
    # setup
    make fft_stratus-hls
    make linux-distclean
    # task - prep files
    make soft
    make linux
    make examples
    make linux
    # task - run on fpga
    check linux.bin
    # testing [linux boot]
    open minicom
        make fpga-run-linux &
        monitor linux boot
    check monitor linux boot result
        if linux boot success
            # testing [SSH and fft]
            try ssh
            try execute fft
    kill minicom
}