# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

############################################################
# Design Parameters
############################################################

#
# Source the common configurations
#
source ../../common/stratus/caches.tcl


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

# foreach sets [list 256 512 1024 2048 4096] {

#     foreach ways [list 1 2 4 8] {

foreach sets [list 512] {

    foreach ways [list 4] {

	foreach wbits [list 1 2] {

	    foreach bbits [list 2 3] {

		foreach abits [list 32] {

		    # Skip these configurations
		    if {$wbits == 1 && $bbits == 2} {continue}
		    if {$wbits == 2 && $bbits == 3} {continue}
		    # Ariane is 64-bits little endian, Leon3 is 32-bits big endian
		    if {$bbits == 2} { set endian BIG_ENDIAN } else { set endian LITTLE_ENDIAN }

		    set words_per_line [expr 1 << $wbits]
		    set bits_per_word [expr (1 << $bbits) * 8]

		    set pars "_${sets}SETS_${ways}WAYS_${words_per_line}x${bits_per_word}LINE_${abits}ADDR"

		    set iocfg "IOCFG$pars"

		    define_io_config * $iocfg -DL2_SETS=$sets -DL2_WAYS=$ways -DADDR_BITS=$abits -DBYTE_BITS=$bbits -DWORD_BITS=$wbits -D$endian

		    define_system_config tb "TESTBENCH$pars" -io_config $iocfg

		    define_sim_config "BEHAV$pars" "l2 BEH" \
			"tb TESTBENCH$pars" -io_config $iocfg

		    foreach cfg [list BASIC] {

			set cname "$cfg$pars"

			define_hls_config l2 $cname --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS \
			    -DHLS_DIRECTIVES_$cfg -io_config $iocfg

			if {$TECH_IS_XILINX == 1} {

			    define_sim_config "$cname\_V" "l2 RTL_V $cname" "tb TESTBENCH$pars" \
				-verilog_top_modules glbl -io_config $iocfg
			} else {

			    define_sim_config "$cname\_V" "l2 RTL_V $cname" "tb TESTBENCH$pars" \
				-io_config $iocfg
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
set_attr hls_cc_options "$INCLUDES $CACHE_INCLUDES"

#
# Simulation Options
#
use_systemc_simulator incisive
set_attr cc_options "$INCLUDES  $CACHE_INCLUDES -DCLOCK_PERIOD=$CLOCK_PERIOD"
# enable_waveform_logging -vcd
set_attr end_of_sim_command "make saySimPassed"
