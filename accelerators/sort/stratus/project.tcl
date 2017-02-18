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
define_hls_module sort ../src/sort.cpp


#
# Testbench or system level modules
#
define_system_module tb ../tb/system.cpp ../tb/sc_main.cpp

######################################################################
# HLS and Simulation configurations
######################################################################
set DEFAULT_ARGV "128 4"

foreach dma [list 32 64] {
    define_io_config * IOCFG_DMA$dma -DDMA_WIDTH=$dma

    define_system_config tb TESTBENCH_DMA$dma -io_config IOCFG_DMA$dma

    define_sim_config "BEHAV_DMA$dma" "sort BEH" "tb TESTBENCH_DMA$dma" -io_config IOCFG_DMA$dma -argv $DEFAULT_ARGV

    foreach cfg [list BASIC] {
	set cname $cfg\_DMA$dma
	define_hls_config sort $cname -io_config IOCFG_DMA$dma --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS -DHLS_DIRECTIVES_$cfg
	if {$TECH_IS_XILINX == 1} {
	    define_sim_config "$cname\_V" "sort RTL_V $cname" "tb TESTBENCH_DMA$dma" -io_config IOCFG_DMA$dma -argv $DEFAULT_ARGV -verilog_top_modules glbl
	} else {
	    define_sim_config "$cname\_V" "sort RTL_V $cname" "tb TESTBENCH_DMA$dma" -io_config IOCFG_DMA$dma -argv $DEFAULT_ARGV
	}
    }
}

#
# Compile Flags
#
set_attr hls_cc_options "$INCLUDES"

#
# Simulation Options
#
use_systemc_simulator incisive
set_attr cc_options "$INCLUDES -DCLOCK_PERIOD=$CLOCK_PERIOD"
# enable_waveform_logging -vcd
set_attr end_of_sim_command "make saySimPassed"
