#!/bin/bash

mkdir -p data_rv
cd data_rv
wget "https://espdev.cs.columbia.edu/stuff/esp/nn_apps/dwarf_model_rv.tar.gz"
tar xzvf dwarf_model_rv.tar.gz
rm dwarf_model_rv.tar.gz
cd ../ 
cp -r data_rv/ ../../../../../socs/xilinx-vc707-xc7vx485t/soft-build/ariane/sysroot/examples/dwarf_nn/ 
mv ../../../../../socs/xilinx-vc707-xc7vx485t/soft-build/ariane/sysroot/examples/dwarf_nn/data_rv ../../../../../socs/xilinx-vc707-xc7vx485t/soft-build/ariane/sysroot/examples/dwarf_nn/data
