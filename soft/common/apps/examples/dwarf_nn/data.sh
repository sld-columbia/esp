#!/bin/bash

mkdir -p data
cd data
wget "https://espdev.cs.columbia.edu/stuff/esp/nn_apps/dwarf_model.tar.gz"
tar xzvf dwarf_model.tar.gz
rm dwarf_model.tar.gz
cd ../ 
cp -r data/ ../../../../../socs/xilinx-vc707-xc7vx485t/soft-build/leon3/sysroot/examples/dwarf_nn/ 
 
