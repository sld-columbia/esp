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

#
# Testbench or system level modules
#
define_system_module tb  ../tb/l2_tb.cpp ../tb/system.cpp ../tb/sc_main.cpp

######################################################################
# HLS and Simulation configurations
######################################################################

foreach ncpu [list 2 4] {

    set iocfg "IOCFG\_NCPU\_$ncpu"

    define_io_config * $iocfg -DN_CPU=$ncpu

    define_system_config tb "TESTBENCH\_$ncpu" -io_config $iocfg

    define_sim_config "BEHAV\_$ncpu" "l2 BEH" "tb TESTBENCH\_$ncpu" -io_config $iocfg

    foreach cfg [list BASIC] {
	set cname "$cfg\_$ncpu"
	define_hls_config l2 $cname --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS \
	    -DHLS_DIRECTIVES_$cfg -io_config $iocfg
	if {$TECH_IS_XILINX == 1} {
	    define_sim_config "$cname\_V" "l2 RTL_V $cname" "tb TESTBENCH\_$ncpu" \
		-verilog_top_modules glbl -io_config $iocfg
	} else {
	    define_sim_config "$cname\_V" "l2 RTL_V $cname" "tb TESTBENCH\_$ncpu" -io_config $iocfg
	}
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
