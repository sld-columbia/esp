# Copyright 2017 Columbia University, SLD Group

############################################################
# Project Parameters
############################################################

#
# Technology Libraries
#
set TECH virtex7

set TECH_PATH "../tech/$TECH"

#
# Set the private memory library
#
# use_hls_lib "./memlib"

#
# Setup technology and include behavioral models and/or libraries
#
set fpga_techs [list "virtex7" "zynq7000" "virtexu" "virtexup"]
set asic_techs [list "cmos32soi" "gf12"]

if {[lsearch $fpga_techs $TECH] >= 0} {
    set VIVADO $::env(XILINX_VIVADO)
    # set_attr verilog_files "$ESP_ROOT/rtl/techmap/$TECH/mem/*v"
    # set_attr verilog_files "$VIVADO/data/verilog/src/glbl.v"
    # set_attr verilog_files "$VIVADO/data/verilog/src/retarget/RAMB*.v"
    # set_attr verilog_files "$VIVADO/data/verilog/src/unisims/RAMB*.v"
    set_attr fpga_use_dsp off
    set_attr fpga_tool "vivado"

    if {$TECH eq "virtex7"} {
	set_attr fpga_part "xc7v2000tflg1925-2"
    }
    if {$TECH eq "zynq7000"} {
	set_attr fpga_part "xc7z020clg484-1"
    }
    if {$TECH eq "virtexu"} {
	set_attr fpga_part "xcvu440-flga2892-2-e"
    }
    if {$TECH eq "virtexup"} {
	set_attr fpga_part "xcvu9p-flga2104-2L-e"
    }

    set TECH_IS_XILINX 1
    set CLOCK_PERIOD 10

}
if {[lsearch $asic_techs $TECH] >= 0} {
    # set_attr verilog_files "$ESP_ROOT/rtl/sim/$TECH/verilog/*v"
    # $ESP_ROOT/rtl/techmap/$TECH/mem/*v"
    set LIB_PATH "$TECH_PATH/lib"
    set LIB_NAME "$TECH.lib"
    use_tech_lib "$LIB_PATH/$LIB_NAME"

    set TECH_IS_XILINX 0

    # use_hls_lib "[get_install_path]/share/stratus/cynware/cynw_cm_float"

    set CLOCK_PERIOD 1000
}


#
# Global synthesis attributes
#
set_attr message_detail           2
set_attr default_protocol         false
set_attr inline_partial_constants true
set_attr output_style_reset_all   true
set_attr lsb_trimming             true

#
# Speedup scheduling for high-perf design (disable most area-minimization techniques)
#
set_attr sched_asap on
set_attr sharing_effort_parts low
set_attr sharing_effort_regs low

set PRINT off
set COMMON_HLS_FLAGS "--prints=$PRINT -DCLOCK_PERIOD=$CLOCK_PERIOD"

#
# Compiling Options
#
set INCLUDES "-I../src"
# -I./memlib"


############################################################
# Design Parameters
############################################################


#
# System level modules to be synthesized
#
define_hls_module divider_hls ../src/divider.cpp


#
# Testbench or system level modules
#
define_system_module tb ../tb/system.cpp ../tb/sc_main.cpp

######################################################################
# HLS and Simulation configurations
######################################################################
set DEFAULT_ARGV ""

define_system_config tb TESTBENCH

define_sim_config "BEHAV" "divider_hls BEH" "tb TESTBENCH" -argv $DEFAULT_ARGV

foreach cfg [list BASIC] {
    set cname $cfg
    define_hls_config divider_hls $cname --clock_period=$CLOCK_PERIOD $COMMON_HLS_FLAGS
    if {$TECH_IS_XILINX == 1} {
	define_sim_config "$cname\_V" "divider_hls RTL_V $cname" "tb TESTBENCH" -argv $DEFAULT_ARGV -verilog_top_modules
    } else {
	define_sim_config "$cname\_V" "divider_hls RTL_V $cname" "tb TESTBENCH" -argv $DEFAULT_ARGV
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
set_attr cc_options "$INCLUDES -DCLOCK_PERIOD=$CLOCK_PERIOD"
# enable_waveform_logging -vcd
set_attr end_of_sim_command "make saySimPassed"
