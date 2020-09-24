# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

# HLS configs

set dma_width {<<--dma-width-->>}
set word_widths {<<--data-widths-->>}
# specify if the input or the output of the accelerator are float
# set dataype "" if input and output are NOT float
# set dataype "fl" if both input and output are float
# set dataype "flin" if only the input is float
# set dataype "flout" if only the output is float
set datatype ""

# Clock period

if {[lsearch $fpga_techs $TECH] >= 0} {
    if {$TECH eq "virtex7"} {
	set clock_period 10
    }
    if {$TECH eq "zynq7000"} {
	set clock_period 10
    }
    if {$TECH eq "virtexup"} {
	set clock_period 10
    }
}
