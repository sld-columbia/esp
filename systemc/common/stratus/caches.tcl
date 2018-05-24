# Copyright 2017 Columbia University, SLD Group

############################################################
# Project Parameters
############################################################

#
# Source the common configurations
#
source ../../common/stratus/project.tcl

#
# Add generated memory library
#
use_hls_lib "./memlib"

#
# Local synthesis attributes
#
set_attr message_detail           2
set_attr default_input_delay      0.1
set_attr default_protocol         false
set_attr inline_partial_constants true
set_attr output_style_reset_all   true
set_attr lsb_trimming             true
set_attr unroll_loops             off
#
# Speedup scheduling for high-perf design (disable most area-minimization techniques)
#
set_attr sharing_effort_parts low
set_attr sharing_effort_regs low


if {$TECH eq "virtex7"} {
    set CLOCK_PERIOD 12.5
    set_attr default_input_delay      0.1
}
if {$TECH eq "zynq7000"} {
    set CLOCK_PERIOD 10.0
    set_attr default_input_delay      0.1
}
if {$TECH eq "cmos32soi"} {
    set CLOCK_PERIOD 1000.0
    set_attr default_input_delay      100.0
}
set_attr clock_period $CLOCK_PERIOD


set CACHE_INCLUDES "-I../../common/caches"

