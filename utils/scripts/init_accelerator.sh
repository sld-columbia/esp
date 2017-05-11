#!/bin/bash

if [ "$ESP_ROOT" == "" ]; then
    echo "ESP_ROOT is not set; aborting!"
    echo ""
    exit
fi

CURR_DIR=${PWD}
cd $ESP_ROOT

if [ "$1" == "" ]; then
    echo "Usage: ./utils/scripts/init_accelerator.sh <accelerator_name>"
    echo ""
    exit
fi

LOWER=$(echo $1 | awk '{print tolower($0)}')
UPPER=$(echo $LOWER | awk '{print toupper($0)}')


dirs="src  stratus  tb"
ACC_DIR=$ESP_ROOT/accelerators/$LOWER

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


for d in $dirs; do
    mkdir -p $ACC_DIR/$d
done

## initialize stratus folder
cd $ACC_DIR
cd stratus
ln -s ../../common/stratus/Makefile
cp $ESP_ROOT/utils/scripts/templates/project.tcl .
sed -i "s/<accelerator_name>/$LOWER/g" *
sed -i "s/<ACCELERATOR_NAME>/$UPPER/g" *

## initialize source files
cd $ACC_DIR
cd src
cp $ESP_ROOT/utils/scripts/templates/accelerator_src/*.cpp .
cp $ESP_ROOT/utils/scripts/templates/accelerator_src/*.hpp .
rename accelerator $LOWER *
sed -i "s/<accelerator_name>/$LOWER/g" *
sed -i "s/<ACCELERATOR_NAME>/$UPPER/g" *

## initialize testbench files
cd $ACC_DIR
cd tb
cp $ESP_ROOT/utils/scripts/templates/accelerator_tb/*.cpp .
cp $ESP_ROOT/utils/scripts/templates/accelerator_tb/*.hpp .
sed -i "s/<accelerator_name>/$LOWER/g" *
sed -i "s/<ACCELERATOR_NAME>/$UPPER/g" *

## Initialize accelerator specs
cd $ACC_DIR
cp $ESP_ROOT/utils/scripts/templates/accelerator.xml .
cp $ESP_ROOT/utils/scripts/templates/memlist.txt .
rename accelerator $LOWER *
sed -i "s/<accelerator_name>/$LOWER/g" *.xml
sed -i "s/<ACCELERATOR_NAME>/$UPPER/g" *.xml

cd $CURR_DIR

