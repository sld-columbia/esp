# Copyright 2017 Columbia University, SLD Group

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
set fpga_techs [list "virtex7" "zynq"]
set asic_techs [list "cmos32soi"]

if {[lsearch $fpga_techs $TECH] >= 0} {
    set VIVADO $::env(XILINX_VIVADO)
    set_attr verilog_files "$TECH_PATH/mem/*.v"
    set_attr verilog_files "$VIVADO/ids_lite/ISE/verilog/src/glbl.v"
    set_attr verilog_files "$VIVADO/ids_lite/ISE/verilog/src/unisims/RAMB16_S*.v"
    set_attr fpga_use_dsp on
    set_attr fpga_tool "vivado"

    if {$TECH eq "virtex7"} {
	set_attr fpga_part "xc7v2000tflg1925-2"
    }
    if {$TECH eq "zynq"} {
	set_attr fpga_part "xc7z020clg484-1"
    }

    set TECH_IS_XILINX 1

}
if {[lsearch $asic_techs $TECH] >= 0} {
    set_attr verilog_files "$TECH_PATH/verilog/*v $TECH_PATH/mem/*v"
    set LIB_PATH "$TECH_PATH/lib"
    set LIB_NAME "ibm32soi_hvt_1p0v.lib"
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
set_attr sched_aggressive_1 on
set_attr sched_effort low
set_attr sharing_effort_parts low
set_attr sharing_effort_regs low

set PRINT on
set COMMON_HLS_FLAGS "--prints=$PRINT"

#
# Templates for synthesis
#
set ESP_HDRS_PATH "$ESP_ROOT/accelerators/common/syn-templates"

#
# Compiling Options
#
set INCLUDES "-I$ESP_HDRS_PATH -I../src -I./memlib"

