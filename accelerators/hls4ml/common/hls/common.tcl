# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

############################################################
# Project Parameters
############################################################

#
# Technology Libraries
#
set TECH $::env(TECH)
set ESP_ROOT $::env(ESP_ROOT)
set ACCELERATOR $::env(ACCELERATOR)
set TECH_PATH "$ESP_ROOT/tech/$TECH"
set fpga_techs [list "virtex7" "zynq7000" "virtexu" "virtexup"]

source "./custom.tcl"

foreach dma $dma_width {
    foreach width $word_widths {

	if {$dma < $width} {error "dma width larger than word width"}

	set unroll_factor [expr $dma / $width]

	# Create project
	open_project "${ACCELERATOR}_dma${dma}_w${width}"

	set_top "top"

	add_files [glob ../src/*] -cflags "-I../inc -I../hls4ml/firmware -I[file normalize ../hls4ml/firmware/nnet_utils] -DDMA_SIZE=${dma} -DDATA_BITWIDTH=${width} -std=c++0x "
	add_files -tb ../tb/tb.cc -cflags "-I../inc -I../hls4ml/firmware -I[file normalize ../hls4ml/firmware/nnet_utils] -Wno-unknown-pragmas -Wno-unknown-pragmas -DDMA_SIZE=${dma} -DDATA_BITWIDTH=${width} -std=c++0x "

	open_solution "${ACCELERATOR}_acc"

	create_clock -period $clock_period -name default

	if {[lsearch $fpga_techs $TECH] >= 0} {
	    if {$TECH eq "virtex7"} {
		set_part "xc7v2000tflg1925-2"
	    }
	    if {$TECH eq "zynq7000"} {
		set_part "xc7z020clg484-1"
	    }
	    if {$TECH eq "virtexu"} {
		set_part "xcvu440-flga2892-2-e"
	    }
	    if {$TECH eq "virtexup"} {
		set_part "xcvu9p-flga2104-2L-e"
	    }
	}

	# Config HLS
	config_rtl -prefix "${ACCELERATOR}_dma${dma}_w${width}_" 
	config_compile -no_signed_zeros=0 -unsafe_math_optimizations=0
	config_schedule -effort medium -relax_ii_for_timing=0 -verbose=0
	config_bind -effort medium
	config_sdx -optimization_level none -target none
	set_clock_uncertainty 12.5%

	# Directives
	set_directive_interface -mode ap_none "top" conf_info_ninputs
	set_directive_interface -mode ap_hs -depth 10 "top" load_ctrl
	set_directive_interface -mode ap_hs -depth 10 "top" store_ctrl
	set_directive_interface -mode ap_fifo -depth 100000 "top" in1
	set_directive_interface -mode ap_fifo -depth 100000 "top" out
	set_directive_data_pack "top" load_ctrl
	set_directive_data_pack "top" store_ctrl
	set_directive_data_pack "top" in1
	set_directive_data_pack "top" out
	set_directive_loop_tripcount -min 256 -max 256 -avg 256 "top/go"
	set_directive_dataflow "top/go"
	set_directive_unroll -factor ${unroll_factor} "store/store_label1"
	set_directive_unroll -factor ${unroll_factor} "load/load_label0"
	# set_directive_array_partition -type cyclic -factor ${unroll_factor} -dim 1 "top" _inbuff
	# set_directive_array_partition -type cyclic -factor ${unroll_factor} -dim 1 "top" _outbuff

	# Custom directives
	source "./directives.tcl"

	# C Simulation
	csim_design

	# HLS
	csynth_design

	# # C-RTL Cosimulation
	# add_files -tb ../tb/tb.cc -cflags "-I../inc -Wno-unknown-pragmas -Wno-unknown-pragmas -DDMA_SIZE=${dma} -std=c++0x -DRTL_SIM"
	# cosim_design

	# Export RTL
	export_design -rtl verilog -format ip_catalog
    }
}

exit
