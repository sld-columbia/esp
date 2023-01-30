# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

# HLS configs

set dma_width {32 64}
set word_widths {32}
# set datatype to "fl32" for flaoting point implementation
set datatype ""

# Clock period

if {[lsearch $fpga_techs $TECH] >= 0} {
    if {$TECH eq "virtex7"} {
	set clock_period 10
    }
    if {$TECH eq "zynq7000"} {
	set clock_period 10
    }
    if {$TECH eq "virtexu"} {
	set clock_period 10
    }
    if {$TECH eq "virtexup"} {
	set clock_period 10
    }
}

