#!/bin/bash

mkdir -p data
cd data
wget "https://espdev.cs.columbia.edu/stuff/esp/nn_apps/dwarf_mojo.tar.gz"
tar xzvf dwarf_mojo.tar.gz
mv dwarf_mojo/* .
rm -r dwarf_mojo
rm dwarf_mojo.tar.gz
cd ../
mkdir -p model
mv data/dwarf7.mojo model/
