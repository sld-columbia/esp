#!/bin/bash

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

if [ "$ESP_ROOT" == "" ]; then
    echo "ESP_ROOT is not set; aborting!"
    echo ""
    exit
fi

CURR_DIR=${PWD}
cd $ESP_ROOT

if [[ "$2" != "stratus_hls" && "$2" != "vivado_hls" ]]; then
    echo "Usage: ./utils/scripts/init_accelerator.sh <accelerator_name> <design_flow>"
    echo "   design_flow options: stratus_hls, vivado_hls"
    echo ""
    exit
fi

FLOW_DIR=$2
TEMPLATES_DIR=$ESP_ROOT/utils/scripts/templates/$2

if [ "$2" == "stratus_hls" ]; then

    dirs="src  stratus  tb"

elif [ "$2" == "vivado_hls" ]; then

    dirs="src  inc  syn  tb"

fi

LOWER=$(echo $1 | awk '{print tolower($0)}')
UPPER=$(echo $LOWER | awk '{print toupper($0)}')


ACC_DIR=$ESP_ROOT/accelerators/$FLOW_DIR/$LOWER

if test -e $ACC_DIR; then
    echo -n "Accelerator $LOWER exists; do you want to overwrite? [y|n]"
    while true; do
	read -p " " yn
	case $yn in
	    [Yy] )
		rm -rf  $ACC_DIR
		break;;
	    [Nn] )
	        echo "Aborting initialization of $LOWER"
		exit
		break;;
	    * )
	        echo -n "Please answer yes or no [y|n]."
	esac
    done
fi

# initialize all design folders
for d in $dirs; do
    mkdir -p $ACC_DIR/$d
    cd $ACC_DIR/$d
    cp $TEMPLATES_DIR/$d/* . 
    rename accelerator $LOWER *
    sed -i "s/<accelerator_name>/$LOWER/g" *
    sed -i "s/<ACCELERATOR_NAME>/$UPPER/g" *

    if [[ "$2" == "stratus_hls" && "$d" == "stratus" ]]; then
	ln -s ../../common/stratus/Makefile
    fi

    if [[ "$2" == "vivado_hls" && "$d" == "syn" ]]; then
	ln -s ../../common/syn/Makefile
	ln -s ../../common/syn/common.tcl
    fi
done

# initialize xml file
cd $ACC_DIR
cp $TEMPLATES_DIR/*.xml .
rename accelerator $LOWER *.xml
sed -i "s/<accelerator_name>/$LOWER/g" *.xml
sed -i "s/<ACCELERATOR_NAME>/$UPPER/g" *.xml


if [ "$2" == "stratus_hls" ]; then
    ## Initialize SystemC execution folder (no HLS license required)
    mkdir -p $ACC_DIR/sim
    cd $ACC_DIR/sim
    echo "include ../../common/systemc.mk" > Makefile
    echo "$LOWER" > .gitignore
fi

cd $CURR_DIR

