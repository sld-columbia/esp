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
set_attr output_style_reset_all on
set_attr output_style_reset_all_sync on
set_attr dpopt_effort high

#
# System level modules to be synthesized
#
define_hls_module gemm ../src/gemm.cpp

#
# Testbench or system level modules
#
define_system_module ../tb/gemm_pv.c
define_system_module tb ../tb/system.cpp ../tb/sc_main.cpp

#
# Testbench configuration
#
set INPUT_PATH  "../datagen/input"
set OUTPUT_PATH "../datagen/output"
set TESTBENCHES "testS testM testL testR testC testNTS testNTM testNTL"
#set TESTBENCHES "testS"

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
set DMA_WIDTH "32 64"
set DMA_CHUNK "2048" 
set WORD_SIZE "32"
set PARALLELISM "8"
# set DMA_WIDTH "64"
# set DMA_CHUNK "8 16 32 64 128 512 2048 4096 8192" 
# set WORD_SIZE "32"
# set PARALLELISM "1 2 4 8 16"

set_attr split_multiply 32
set_attr split_add 32

######################################################################
# HLS and Simulation configurations
######################################################################

set DEFAULT_ARGV ""

foreach chk $DMA_CHUNK {
    foreach dma $DMA_WIDTH {
	foreach word $WORD_SIZE {
	    foreach paral $PARALLELISM {

		# Skip these configurations
		if {$word == 64 && $dma == 32} {continue}
		
		set conf "CHK$chk\_DMA$dma\_WORD$word\_PARAL$paral"

		define_io_config * IOCFG_$conf -DDMA_CHUNK=$chk \
		    -DDMA_WIDTH=$dma -DWORD_SIZE=$word -DPARALLELISM=$paral $COMMON_CFG_FLAGS

		define_system_config tb TESTBENCH_$conf -io_config IOCFG_$conf

		foreach tb $TESTBENCHES {

		    set ARGV ""
		    append ARGV "$INPUT_PATH/$tb\_A.txt ";  # argv[1]
		    append ARGV "$INPUT_PATH/$tb\_B.txt ";  # argv[2]
		    append ARGV "$OUTPUT_PATH/$tb.txt ";    # argv[3]

		    define_sim_config "BEHAV_$conf\_$tb" "gemm BEH" \
			"tb TESTBENCH_$conf" -io_config IOCFG_$conf \
			-argv $ARGV
		}

		foreach cfg [list BASIC] {

		    set cname $cfg\_$conf

		    define_hls_config gemm $cname -io_config IOCFG_$conf \
			-DDMA_CHUNK=$chk -DDMA_WIDTH=$dma -DWORD_SIZE=$word \
			-DPARALLELISM=$paral $COMMON_HLS_FLAGS -DHLS_DIRECTIVES_$cfg

		    foreach tb $TESTBENCHES {

			set ARGV ""
			append ARGV "$INPUT_PATH/$tb\_A.txt ";  # argv[1]
			append ARGV "$INPUT_PATH/$tb\_B.txt ";  # argv[2]
			append ARGV "$OUTPUT_PATH/$tb.txt ";    # argv[3]

			if {$TECH_IS_XILINX == 1} {
			    define_sim_config "$cname\_$tb\_V" "gemm RTL_V $cname" \
				"tb TESTBENCH_$conf" -io_config IOCFG_$conf \
				-argv $ARGV -verilog_top_modules glbl
			} else {
			    define_sim_config "$cname\_$tb\_V" "gemm RTL_V $cname" \
				"tb TESTBENCH_$conf" -io_config IOCFG_$conf \
				-argv $ARGV
			}
		    }
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
