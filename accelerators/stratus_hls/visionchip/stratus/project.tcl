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
    set CLOCK_PERIOD 10
    set SIM_CLOCK_PERIOD 10000.0
    set_attr default_input_delay      0.1
}
if {$TECH eq "cmos32soi"} {
    set CLOCK_PERIOD 1000.0
    set SIM_CLOCK_PERIOD 1000.0
    set_attr default_input_delay      100.0
}
if {$TECH eq "gf12"} {
    set CLOCK_PERIOD 750.0
    set SIM_CLOCK_PERIOD 2000.0
    set_attr default_input_delay      100.0
}
set_attr clock_period $CLOCK_PERIOD

#
# System level modules to be synthesized
#
define_hls_module visionchip ../src/visionchip.cpp


#
# Testbench or system level modules
#
define_system_module tb ../tb/system.cpp ../tb/sc_main.cpp

######################################################################
# HLS and Simulation configurations
######################################################################
set DEFAULT_ARGV ""

foreach dma [list 64] {
    foreach plm_img_size [list 1024] {
	foreach max_pxl_width_log [list 3] {

	    # # Skip these configurations
	    # if {$plm_img_size == 1024 && $max_pxl_width_log == 4} {continue}
	    # if {$plm_img_size == 307200 && $max_pxl_width_log == 3} {continue}

	    set ext DMA$dma\_IMG$plm_img_size\_PXL$max_pxl_width_log

	    define_io_config * IOCFG_$ext -DDMA_WIDTH=$dma \
		-DPLM_IMG_SIZE=$plm_img_size -DMAX_PXL_WIDTH_LOG=$max_pxl_width_log

	    define_system_config tb TESTBENCH_$ext -io_config IOCFG_$ext

	    define_sim_config "BEHAV_$ext" "visionchip BEH" "tb TESTBENCH_$ext" -io_config IOCFG_$ext -argv $DEFAULT_ARGV

	    foreach cfg [list FAST] {
		set cname $cfg\_$ext
		define_hls_config visionchip $cname -io_config IOCFG_$ext --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS -DHLS_DIRECTIVES_$cfg
		if {$TECH_IS_XILINX == 1} {
		    define_sim_config "$cname\_V" "visionchip RTL_V $cname" "tb TESTBENCH_$ext" -io_config IOCFG_$ext -argv $DEFAULT_ARGV -verilog_top_modules glbl
		} else {
		    define_sim_config "$cname\_V" "visionchip RTL_V $cname" "tb TESTBENCH_$ext" -io_config IOCFG_$ext -argv $DEFAULT_ARGV
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
use_systemc_simulator incisive
set_attr cc_options "$INCLUDES -DCLOCK_PERIOD=$SIM_CLOCK_PERIOD"
# enable_waveform_logging -vcd
set_attr end_of_sim_command "make saySimPassed"
