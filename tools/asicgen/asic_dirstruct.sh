#! /bin/bash
# Copyright (c) 2011-2022 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

########################################################################
# This script creates the technology integration folder outside the ESP 
# directory
########################################################################

source asic_defs.sh

TECH_DIR_PATH=$(realpath ../../../$DIRTECH_NAME)
PROJ_DIR_PATH=$(realpath ../../../$PROJECT_NAME)

if [ ! -d "$TECH_DIR_PATH" ]
then
  mkdir "$TECH_DIR_PATH"
fi

if [ ! -d "../../rtl/techmap/asic" ]
then
  mkdir "../../rtl/techmap/asic"
fi

if [ ! -d "$TECH_DIR_PATH/verilog" ]
then
  mkdir "$TECH_DIR_PATH/verilog"
fi

if [ ! -d "../../rtl/sim/asic" ]
then
  mkdir "../../rtl/sim/asic"
fi

if [ ! -d "$TECH_DIR_PATH/mem_wrappers" ]
then
  mkdir "$TECH_DIR_PATH/mem_wrappers"
fi

if [ ! -d "$TECH_DIR_PATH/mem_wrappers/tb" ]
then
  mkdir "$TECH_DIR_PATH/mem_wrappers/tb"
fi

if [ ! -d "$TECH_DIR_PATH/pad_wrappers" ]
then
  mkdir "$TECH_DIR_PATH/pad_wrappers"
fi

if [ ! -d "$TECH_DIR_PATH/dco_wrappers" ]
then
  mkdir "$TECH_DIR_PATH/dco_wrappers"
fi

if [ ! -d "$TECH_DIR_PATH/lib" ]
then
  mkdir "$TECH_DIR_PATH/lib"
fi

if [ ! -d "../../tech/$DIRTECH_NAME" ]
then
  mkdir "../../tech/$DIRTECH_NAME"
fi

if [ ! -d "../../tech/$DIRTECH_NAME/acc" ]
then
  mkdir "../../tech/$DIRTECH_NAME/acc"
fi

cd ../../rtl/sim/asic
ln -sf $TECH_DIR_PATH/verilog verilog
cd -

cd ../../rtl/techmap/asic
ln -sf $TECH_DIR_PATH/mem_wrappers mem
cd -

cd ../../rtl/techmap/asic
ln -sf $TECH_DIR_PATH/pad_wrappers pad
cd -

cd ../../rtl/techmap/asic
ln -sf $TECH_DIR_PATH/dco_wrappers dco
cd -

cd ../../tech/$DIRTECH_NAME
ln -sf $TECH_DIR_PATH/lib lib
cd -

if [ ! -d "$PROJ_DIR_PATH" ]
then
  mkdir "$PROJ_DIR_PATH"
fi

if [ ! -f "$PROJ_DIR_PATH/Makefile" ]
then
  cp ../../socs/esp_asic_generic/Makefile "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/esp_defconfig" ]
then
  cp ../../socs/esp_asic_generic/esp_defconfig "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/grlib_defconfig" ]
then
  cp ../../socs/esp_asic_generic/grlib_defconfig "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/grlib_config.in" ]
then
  cp ../../socs/esp_asic_generic/grlib_config.in "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/fpga_proxy_top.vhd" ]
then
  cp ../../socs/esp_asic_generic/fpga_proxy_top.vhd "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/pads_loc.vhd" ]
then
  cp ../../socs/esp_asic_generic/pads_loc.vhd "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/pads_loc.txt" ]
then
  cp ../../socs/esp_asic_generic/pads_loc.txt "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/systest.c" ]
then
  cp ../../socs/esp_asic_generic/systest.c "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/testbench.vhd" ]
then
  cp ../../socs/esp_asic_generic/testbench.vhd "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/top.vhd" ]
then
  cp ../../socs/esp_asic_generic/top.vhd "$PROJ_DIR_PATH/"
fi

if [ ! -f "$PROJ_DIR_PATH/vsim.tcl" ]
then
  cp ../../socs/esp_asic_generic/vsim.tcl "$PROJ_DIR_PATH/"
fi

