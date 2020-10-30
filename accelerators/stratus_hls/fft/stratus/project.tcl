# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

############################################################
# Design Parameters
############################################################

#
# Source the common configurations
#
source ../../common/stratus/project.tcl


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
    set CLOCK_PERIOD 8
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
set_attr clock_period $CLOCK_PERIOD


#
# System level modules to be synthesized
#
define_hls_module fft ../src/fft.cpp


#
# Testbench or system level modules
#
define_system_module tb ../tb/fft_test.cpp ../tb/system.cpp ../tb/sc_main.cpp

######################################################################
# HLS and Simulation configurations
######################################################################
set DEFAULT_ARGV ""

set FX_IL "-DFX32_IL=14 -DFX64_IL=42"

foreach dma [list 32 64] {
    foreach fx [list 32 64] {
	define_io_config * IOCFG_FX$fx\_DMA$dma -DFX_WIDTH=$fx -DDMA_WIDTH=$dma

	define_system_config tb TESTBENCH_FX$fx\_DMA$dma -io_config IOCFG_FX$fx\_DMA$dma

	define_sim_config "BEHAV_FX$fx\_DMA$dma" "fft BEH" "tb TESTBENCH_FX$fx\_DMA$dma" -io_config IOCFG_FX$fx\_DMA$dma -argv $DEFAULT_ARGV

	foreach cfg [list BASIC] {
	    set cname $cfg\_FX$fx\_DMA$dma
	    define_hls_config fft $cname -io_config IOCFG_FX$fx\_DMA$dma --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS -DHLS_DIRECTIVES_$cfg
	    if {$TECH_IS_XILINX == 1} {
		define_sim_config "$cname\_V" "fft RTL_V $cname" "tb TESTBENCH_FX$fx\_DMA$dma" -io_config IOCFG_FX$fx\_DMA$dma -argv $DEFAULT_ARGV -verilog_top_modules glbl
	    } else {
		define_sim_config "$cname\_V" "fft RTL_V $cname" "tb TESTBENCH_FX$fx\_DMA$dma" -io_config IOCFG_FX$fx\_DMA$dma -argv $DEFAULT_ARGV
	    }
	}
    }
}

#
# Compile Flags
#
set_attr hls_cc_options "$INCLUDES $FX_IL"

#
# Simulation Options
#
use_systemc_simulator incisive
set_attr cc_options "$INCLUDES $FX_IL -DCLOCK_PERIOD=$SIM_CLOCK_PERIOD -std=gnu++11"
# enable_waveform_logging -vcd
set_attr end_of_sim_command "make saySimPassed"
