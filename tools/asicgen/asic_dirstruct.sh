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

if [ ! -d "../../rtl/techmap/$DIRTECH_NAME" ]
then
  mkdir "../../rtl/techmap/$DIRTECH_NAME"
fi

if [ ! -d "TECH_DIR_PATH/mem_models" ]
then
  mkdir "$TECH_DIR_PATH/mem_models"
fi

if [ ! -d "../../rtl/sim/$DIRTECH_NAME" ]
then
  mkdir "../../rtl/sim/$DIRTECH_NAME"
fi

if [ ! -d "TECH_DIR_PATH/mem_wrappers" ]
then
  mkdir "$TECH_DIR_PATH/mem_wrappers"
fi

if [ ! -d "TECH_DIR_PATH/lib" ]
then
  mkdir "$TECH_DIR_PATH/lib"
fi

cd ../../rtl/sim/$DIRTECH_NAME
ln -sf $TECH_DIR_PATH/mem_models/ verilog
cd -

cd ../../rtl/techmap/$DIRTECH_NAME
ln -sf $TECH_DIR_PATH/mem_wrappers/ mem
cd -

cd ../../tech/
ln -sf ../../$DIRTECH_NAME/lib/ lib
cd -

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
