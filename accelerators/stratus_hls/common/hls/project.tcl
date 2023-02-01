# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

############################################################
# Project Parameters
############################################################

#
# Technology Libraries
#
set TECH $::env(TECH)
set ESP_ROOT $::env(ESP_ROOT)

set TECH_PATH "$ESP_ROOT/tech/$TECH"


#
# Setup technology and include behavioral models and/or libraries
#
set fpga_techs [list "virtex7" "zynq7000" "virtexu" "virtexup"]
set asic_techs [list "cmos32soi" "gf12"]

if {[lsearch $fpga_techs $TECH] >= 0} {
    set VIVADO $::env(XILINX_VIVADO)
    set_attr verilog_files "$ESP_ROOT/rtl/techmap/$TECH/mem/*v"
    set_attr verilog_files "$VIVADO/data/verilog/src/glbl.v"
    set_attr verilog_files "$VIVADO/data/verilog/src/retarget/RAMB*.v"
    set_attr verilog_files "$VIVADO/data/verilog/src/unisims/RAMB*.v"
    set_attr fpga_use_dsp off
    set_attr fpga_tool "vivado"

    if {$TECH eq "virtex7"} {
	set_attr fpga_part "xc7v2000tflg1925-2"
    }
    if {$TECH eq "zynq7000"} {
	set_attr fpga_part "xc7z020clg484-1"
    }
    if {$TECH eq "virtexu"} {
	set_attr fpga_part "xcvu440-flga2892-2-e"
    }
    if {$TECH eq "virtexup"} {
	set_attr fpga_part "xcvu9p-flga2104-2L-e"
    }

    set TECH_IS_XILINX 1

}
if {[lsearch $asic_techs $TECH] >= 0} {
    set_attr verilog_files "$ESP_ROOT/rtl/sim/$TECH/verilog/*v $ESP_ROOT/rtl/techmap/$TECH/mem/*v"
    set LIB_PATH "$TECH_PATH/lib"
    set LIB_NAME "$TECH.lib"
    use_tech_lib "$LIB_PATH/$LIB_NAME"

    set TECH_IS_XILINX 0

    use_hls_lib "[get_install_path]/share/stratus/cynware/cynw_cm_float"
}


#
# Global synthesis attributes
#
set_attr message_detail           2
set_attr default_protocol         false
set_attr inline_partial_constants true
set_attr output_style_reset_all   true
set_attr lsb_trimming             true

#
# Speedup scheduling for high-perf design (disable most area-minimization techniques)
#
#set_attr sched_effort to get lowest possible latency
set_attr sched_asap on
set_attr sharing_effort_parts low
set_attr sharing_effort_regs low

set PRINT on
set COMMON_HLS_FLAGS "--prints=$PRINT"

#
# Templates for synthesis
#
set ESP_HDRS_PATH "$ESP_ROOT/accelerators/stratus_hls/common/inc"
set ESP_UTILS_PATH "$ESP_ROOT/accelerators/stratus_hls/common/utils"

#
# Compiling Options
#
set INCLUDES "-I$ESP_HDRS_PATH -I$ESP_UTILS_PATH -I../src -I./memlib"

