#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/opt/xilinx/Vivado/2019.2/ids_lite/ISE/bin/lin64:/opt/xilinx/Vivado/2019.2/bin
else
  PATH=/opt/xilinx/Vivado/2019.2/ids_lite/ISE/bin/lin64:/opt/xilinx/Vivado/2019.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/esp2022/sr3859/esp/esp/accelerators/third-party/GT_VORTEX/ip/rtl/fp_cores/xilinx/vc707/acl_fdiv/acl_fdiv.runs/acl_div_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log acl_div.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source acl_div.tcl
