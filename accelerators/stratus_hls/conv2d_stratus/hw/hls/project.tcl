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
    set CLOCK_PERIOD 750.0
    set SIM_CLOCK_PERIOD 2000.0
    set_attr default_input_delay      100.0
}

set_attr clock_period $CLOCK_PERIOD

#
# System level modules to be synthesized
#
define_hls_module conv2d ../src/conv2d.cpp

#
# Testbench or system level modules
#
define_system_module ../tb/utils.cpp ../tb/golden.cpp
define_system_module tb ../tb/system.cpp ../tb/sc_main.cpp

######################################################################
# HLS and Simulation configurations
######################################################################

#
# Testbench configuration
#
set TB_INOUT_SIZE "XS S M L XL"
set TB_FILTER_SIZE "1x1 3x3 5x5"

#
# Common options for all configurations
#

append COMMON_HLS_FLAGS \
    " -DFIXED_POINT --clock_period=$CLOCK_PERIOD"
set COMMON_CFG_FLAGS \
    "-DFIXED_POINT -DCLOCK_PERIOD=$SIM_CLOCK_PERIOD"

# append COMMON_HLS_FLAGS \
#     " -DFLOAT_POINT --clock_period=$CLOCK_PERIOD"
# set COMMON_CFG_FLAGS \
#     "-DFLOAT_POINT -DCLOCK_PERIOD=$SIM_CLOCK_PERIOD"

if {$TECH_IS_XILINX == 1} {
    append COMMON_HLS_FLAGS " -DTECH_IS_FPGA "
    append COMMON_CFG_FLAGS " -DTECH_IS_FPGA "
}

#
# DSE configuration
#

set data_width 32
set input_plm_size 2048
set weights_plm_size 2048
set bias_plm_size 16
set output_plm_size 2048
set patch_plm_size 512
set mac_plm_size 512

append COMMON_HLS_FLAGS \
    " -DDATA_WIDTH=${data_width} -DWORD_SIZE=${data_width} -DINPUT_PLM_SIZE=$input_plm_size \
      -DWEIGHTS_PLM_SIZE=$weights_plm_size -DBIAS_PLM_SIZE=$bias_plm_size \
      -DOUTPUT_PLM_SIZE=$output_plm_size \
      -DPATCH_PLM_SIZE=$patch_plm_size -DMAC_PLM_SIZE=$mac_plm_size"
append COMMON_CFG_FLAGS \
    " -DDATA_WIDTH=${data_width} -DWORD_SIZE=${data_width} -DINPUT_PLM_SIZE=$input_plm_size \
      -DWEIGHTS_PLM_SIZE=$weights_plm_size -DBIAS_PLM_SIZE=$bias_plm_size \
      -DOUTPUT_PLM_SIZE=$output_plm_size \
      -DPATCH_PLM_SIZE=$patch_plm_size -DMAC_PLM_SIZE=$mac_plm_size"

foreach dma [list 32 64] {
    define_io_config * IOCFG_DMA$dma -DDMA_WIDTH=$dma $COMMON_CFG_FLAGS
    define_system_config tb TESTBENCH_DMA$dma -io_config IOCFG_DMA$dma

    foreach iosz $TB_INOUT_SIZE {
	foreach fsz $TB_FILTER_SIZE {
	    set ARGV ""
	    append ARGV "$iosz "; # argv[1]
	    append ARGV "$fsz ";  # argv[2]
	    define_sim_config "BEHAV_DMA$dma\_$iosz\_$fsz" "conv2d BEH" \
		"tb TESTBENCH_DMA$dma" -io_config IOCFG_DMA$dma -argv $ARGV
	}
    }

    foreach cfg [list BASIC] {
	set cname $cfg\_DMA$dma
	define_hls_config conv2d $cname -io_config IOCFG_DMA$dma \
	    --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS -DHLS_DIRECTIVES_$cfg

	foreach iosz $TB_INOUT_SIZE {
	    foreach fsz $TB_FILTER_SIZE {
		set ARGV ""
		append ARGV "$iosz "; # argv[1]
		append ARGV "$fsz ";  # argv[2]

		if {$TECH_IS_XILINX == 1} {
		    define_sim_config "$cname\_$iosz\_$fsz\_V" "conv2d RTL_V $cname" \
			"tb TESTBENCH_DMA$dma" -io_config IOCFG_DMA$dma \
			-argv $ARGV -verilog_top_modules glbl
		} else {
		    define_sim_config "$cname\_$iosz\_$fsz\_V" "conv2d RTL_V $cname" \
			"tb TESTBENCH_DMA$dma" -io_config IOCFG_DMA$dma \
			-argv $ARGV
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
