# Copyright 2017 Columbia University, SLD Group

############################################################
# Project Parameters
############################################################

#
# Technology Libraries
#
set TECH $::env(TECH)

set TECH_PATH "../../../tech/$TECH"

#
# Setup technology and include behavioral models and/or libraries
#
if {$TECH eq "virtex7"} {
    set VIVADO $::env(VIVADO)
    set_attr verilog_files "$TECH_PATH/mem/*.v $VIVADO/ids_lite/ISE/verilog/src/unisims/RAMB16_S*.v"
    set_attr fpga_use_dsp on
    set_attr fpga_tool "vivado"
    set_attr fpga_part "xc7v2000tflg1925-2"

    set CLOCK_PERIOD 10000.0
}
if {$TECH eq "cmos32soi"} {
    set_attr verilog_files {$TECH_PATH/verilog/*v $TECH_PATH/mem/*v}
    set LIB_PATH "$TECH_PATH/lib"
    set LIB_NAME "cmos32soi_1000.lib"

    set CLOCK_PERIOD 1000.0

    use_hls_lib "[get_install_path]/share/stratus/cynware/cynw_cm_float"
}

#
# Set the private memory library
#
use_hls_lib "./memlib"

#
# Global synthesis attributes
#
set_attr message_detail           2
set_attr default_input_delay      0.1
set_attr default_protocol         false
set_attr inline_partial_constants true
set_attr output_style_reset_all   true
set_attr lsb_trimming             true

set PRINT on
set SCHED_ASAP no
set COMMON_HLS_FLAGS "--prints=$PRINT --sched_asap=$SCHED_ASAP -DCLOCK_PERIOD=$CLOCK_PERIOD"

#
# Templates for synthesis
#
set ESP_HDRS_PATH "../../common/syn-templates"

#
# Compiling Options
#
set INCLUDES "-I$ESP_HDRS_PATH -I../src -I./memlib"

