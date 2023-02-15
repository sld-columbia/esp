# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

############################################################
# Design Parameters
############################################################

#
# Source the common configurations
#
source ../../../common/hls/project.tcl


#
# Set the private memory library
#
use_hls_lib "./memlib"


#
# Local synthesis attributes
#
if {$TECH eq "virtex7"} {
    # Library is in ns, but simulation uses ps!
    set CLOCK_PERIOD 10.0
    set SIM_CLOCK_PERIOD 10000.0
    set_attr default_input_delay      0.1
}
if {$TECH eq "zynq7000"} {
    # Library is in ns, but simulation uses ps!
    set CLOCK_PERIOD 10.0
    set SIM_CLOCK_PERIOD 10000.0
    set_attr default_input_delay      0.1
}
if {$TECH eq "virtexu"} {
    # Library is in ns, but simulation uses ps!
    set CLOCK_PERIOD 8.0
    set SIM_CLOCK_PERIOD 8000.0
    set_attr default_input_delay      0.1
}
if {$TECH eq "virtexup"} {
    # Library is in ns, but simulation uses ps!
    set CLOCK_PERIOD 6.4
    set SIM_CLOCK_PERIOD 6400.0
    set_attr default_input_delay      0.1
}
if {$TECH eq "cmos32soi"} {
    set CLOCK_PERIOD 1000.0
    set SIM_CLOCK_PERIOD 1000.0
    set_attr default_input_delay      100.0
}
if {$TECH eq "gf12"} {
    set CLOCK_PERIOD 1.0
    set SIM_CLOCK_PERIOD 1.0
    set_attr default_input_delay      0.1
}
set_attr clock_period $CLOCK_PERIOD


#
# System level modules to be synthesized
#
define_hls_module mriq ../src/mriq.cpp


#
# Testbench or system level modules
#
define_system_module tb ../tb/system.cpp ../tb/sc_main.cpp

# Testbench configuration
set DATA_PATH "../data"

# TESTBENCHES can be set as the following: 
# "32_32_32_dataset",  "64_64_64_dataset",  "128_128_128_dataset", "test_small"

set TESTBENCHES "test_small"

# note: test.bin is the same file as 32_32_32_dataset.bin
# note: test.out is the output when input is 32_32_32_dataset.bin
# numK = 16, numX = 4

######################################################################
# HLS and Simulation configurations
######################################################################
set DEFAULT_ARGV ""

foreach dma [list 32] {
    foreach arch [list 0] {
	foreach para [list 4] {
	        define_io_config * IOCFG_P$para\_A$arch\_DMA$dma -DPARAL=$para -DARCH=$arch -DDMA_WIDTH=$dma 
	        define_system_config tb TESTBENCH_P$para\_A$arch\_DMA$dma -DARCH=$arch -io_config IOCFG_P$para\_A$arch\_DMA$dma
	    foreach tb $TESTBENCHES {
		set ARGV ""
		append ARGV "$DATA_PATH/$tb.bin ";
		append ARGV "$DATA_PATH/$tb.out ";
		define_sim_config "BEHAV_P$para\_A$arch\_DMA$dma" "mriq BEH" "tb TESTBENCH_P$para\_A$arch\_DMA$dma" -io_config IOCFG_P$para\_A$arch\_DMA$dma -argv $ARGV
	    }
	    foreach cfg [list BASIC] {
		set cname $cfg\_P$para\_A$arch\_DMA$dma
		define_hls_config mriq $cname -io_config IOCFG_P$para\_A$arch\_DMA$dma --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS -DHLS_DIRECTIVES_$cfg
		set ARGV ""
		append ARGV "$DATA_PATH/$tb.bin ";
		append ARGV "$DATA_PATH/$tb.out ";
		if {$TECH_IS_XILINX == 1} {
		        define_sim_config "$cname\_V" "mriq RTL_V $cname" "tb TESTBENCH_P$para\_A$arch\_DMA$dma" -io_config IOCFG_P$para\_A$arch\_DMA$dma -argv $ARGV -verilog_top_modules glbl
		} else {
		        define_sim_config "$cname\_V" "mriq RTL_V $cname" "tb TESTBENCH_P$para\_A$arch\_DMA$dma" -io_config IOCFG_P$para\_A$arch\_DMA$dma -argv $ARGV
		}
	    }
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
use_systemc_simulator xcelium
set_attr cc_options "$INCLUDES -DCLOCK_PERIOD=$SIM_CLOCK_PERIOD"
# enable_waveform_logging -vcd
set_attr end_of_sim_command "make saySimPassed"
