#! /bin/bash
# Copyright (c) 2011-2022 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

########################################################################
# This script creates the technology integration folder outside the ESP 
# directory
########################################################################

source asic_defs.sh

TECH_DIR_PATH="../../../$DIRTECH_NAME"
PROJ_DIR_PATH="../../../$PROJECT_NAME"

if [ ! -d "$TECH_DIR_PATH" ]
then
  mkdir "$TECH_DIR_PATH"
fi

if [ ! -d "TECH_DIR_PATH/mem_models" ]
then
  mkdir "$TECH_DIR_PATH/mem_models"
  ln -sf $TECH_DIR_PATH/mem_models/ ../../rtl/sim/asic/verilog
fi

if [ ! -d "TECH_DIR_PATH/mem_wrappers" ]
then
  mkdir "$TECH_DIR_PATH/mem_wrappers"
  ln -sf $TECH_DIR_PATH/mem_wrappers/ ../../rtl/techmap/asic/mem
fi

if [ ! -d "PROJ_DIR_PATH" ]
then
  mkdir "$PROJ_DIR_PATH"
fi

if [ ! -f "PROJ_DIR_PATH/Makefile" ]
then
  cp Makefile "$PROJ_DIR_PATH/"
fi

if [ ! -f "PROJ_DIR_PATH/esp_asic_defconfig" ]
then
  cp esp_asic_defconfig "$PROJ_DIR_PATH/"
fi

if [ ! -f "PROJ_DIR_PATH/grlib_asic_defconfig" ]
then
  cp grlib_asic_defconfig "$PROJ_DIR_PATH/"
fi

if [ ! -f "PROJ_DIR_PATH/grlib_config.in" ]
then
  cp grlib_config.in "$PROJ_DIR_PATH/"
fi
