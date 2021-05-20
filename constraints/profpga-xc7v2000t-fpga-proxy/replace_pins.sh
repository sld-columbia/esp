#!/bin/bash
while read -r line; do
    pin=$(cut -f 1 -d " " <<< $line)
    name=$(cut -f 2 -d " " <<< $line)
    sed -i "s/{\(.*${pin}.*\)}/{${name}} # \1/g" profpga-xc7v2000t-fpga-proxy-cable-pins.xdc 
done < "cable_pins.txt"
