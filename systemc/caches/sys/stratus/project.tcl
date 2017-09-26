# Copyright 2017 Columbia University, SLD Group

############################################################
# Design Parameters
############################################################

#
# Source the common configurations
#
source ../../common/stratus/project.tcl


#
# System level modules to be synthesized
#
define_hls_module l2 ../src/l2.cpp
define_hls_module llc ../src/llc.cpp

#
# Testbench or system level modules
#
define_system_module tb  ../tb/mem.cpp ../tb/noc.cpp ../tb/sys_tb.cpp ../tb/system.cpp ../tb/sc_main.cpp

######################################################################
# HLS and Simulation configurations
######################################################################

define_system_config tb TESTBENCH

define_sim_config "BEHAV" "l2 BEH" "llc BEH" "tb TESTBENCH"

foreach cfg [list BASIC] {
    set cname $cfg
    define_hls_config l2 $cname --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS -DHLS_DIRECTIVES_$cfg
    define_hls_config llc $cname --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS -DHLS_DIRECTIVES_$cfg
    if {$TECH_IS_XILINX == 1} {
	define_sim_config "$cname\_V" "l2 RTL_V $cname" "llc RTL_V $cname" "tb TESTBENCH" -verilog_top_modules glbl
    } else {
	define_sim_config "$cname\_V" "l2 RTL_V $cname" "llc RTL_V $cname" "tb TESTBENCH"
    }
}

#
# Compile Flags
#
set_attr hls_cc_options "$INCLUDES $CACHE_INCLUDES"

#
# Simulation Options
#
use_systemc_simulator incisive
set_attr cc_options "$INCLUDES  $CACHE_INCLUDES -DCLOCK_PERIOD=$CLOCK_PERIOD"
# enable_waveform_logging -vcd
set_attr end_of_sim_command "make saySimPassed"
