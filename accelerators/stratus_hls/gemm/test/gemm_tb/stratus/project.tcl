# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

############################################################
# Design Parameters
############################################################

#
# Source the common configurations
#
source ../../../../common/stratus/project.tcl

#
# Set the private memory library
#
use_hls_lib "./memlib"

if {$ACCELERATOR eq "conv2d"} {
    
    append INCLUDES " -I../../../../conv2d/src -I../tb/common -I../tb/common/mojo_utils" 
    
    # source ../../../../conv2d/test/conv2D_tb/stratus/project.tcl

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
    if {$TECH eq "kintex7"} {
    	# Library is in ns, but simulation uses ps!
    	set CLOCK_PERIOD 10.0
    	set SIM_CLOCK_PERIOD 10000.0
    	set_attr default_input_delay      0.1
    }
    if {$TECH eq "cmos32soi"} {
    	set CLOCK_PERIOD 1000.0
    	set SIM_CLOCK_PERIOD 1000.0
    	set_attr default_input_delay      100.0
    }
    if {$TECH eq "gf12"} {
    	set CLOCK_PERIOD 670.0
    	set SIM_CLOCK_PERIOD 2000.0
    	set_attr default_input_delay      100.0
    }

    set_attr clock_period $CLOCK_PERIOD

    #
    # System level modules to be synthesized
    #
    define_hls_module conv2d ../../../../conv2d/src/conv2d.cpp 
    #
    # Testbench or system level modules
    #

    # define_system_module ../../../../conv2d/tb/utils.cpp ../../../../conv2d/tb/golden.cpp  
    # define_system_module tb ../../../../conv2d/test/conv2D_tb/tb/system.cpp ../../../../conv2d/test/conv2D_tb/tb/sc_main.cpp

    define_system_module ../tb/common/utils.cpp ../tb/common/golden.cpp  
    define_system_module tb ../tb/conv2d/system.cpp ../tb/conv2d/sc_main.cpp

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

    foreach dma [list 64] {
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
    use_systemc_simulator incisive
    set_attr cc_options "$INCLUDES -DCLOCK_PERIOD=$SIM_CLOCK_PERIOD"
    # enable_waveform_logging -vcd
    set_attr end_of_sim_command "make saySimPassed"
} else {


append INCLUDES " -I../../../src -I../tb/common -I../tb/common/mojo_utils" 
# # Include folders for header files
# INCDIR = -I$(OPENCV)/include -I./include/mojo -I./include/contrast_adj -I../../../tb/  -I./in\
# clude/pv_wrap


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
if {$TECH eq "virtexup"} {
    # Library is in ns, but simulation uses ps!
    set CLOCK_PERIOD 10
    set SIM_CLOCK_PERIOD 10000.0
    set_attr default_input_delay      0.1
}
if {$TECH eq "kintex7"} {
    # Library is in ns, but simulation uses ps!
    set CLOCK_PERIOD 10.0
    set SIM_CLOCK_PERIOD 10000.0
    set_attr default_input_delay      0.1
}
if {$TECH eq "cmos32soi"} {
    set CLOCK_PERIOD 1000.0
    set SIM_CLOCK_PERIOD 1000.0
    set_attr default_input_delay      100.0
}
if {$TECH eq "gf12"} {
    set CLOCK_PERIOD 670.0
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
define_system_module ../tb/common/gemm_pvt.cpp
define_system_module tb ../tb/gemm/system.cpp ../tb/gemm/sc_main.cpp 
#../tb/gemm/system.hpp


# define_system_module ../tb/gemm_pvt.c
# define_system_module tb ../tb/system.cpp ../tb/sc_main.cpp ../tb/system.hpp

#
# Testbench configuration
#
set INPUT_PATH  "../datagen/input"
set OUTPUT_PATH "../datagen/output"
# set TESTBENCHES "testS testM testL testR testC testNTS testNTM testNTL"
set TESTBENCHES "testS"

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
set DMA_WIDTH "64"
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
use_systemc_simulator incisive
set_attr cc_options "$INCLUDES -DCLOCK_PERIOD=$SIM_CLOCK_PERIOD"
# enable_waveform_logging -vcd
set_attr end_of_sim_command "make saySimPassed"

}
