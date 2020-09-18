# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set TECH $::env(TECH)
set ESP_ROOT $::env(ESP_ROOT)
set ACCELERATOR $::env(ACCELERATOR)
set TECH_PATH "$ESP_ROOT/tech/$TECH"
set DMA_WIDTH $::env(DMA_WIDTH)

#
# Technology Libraries
#
set fpga_techs [list "virtex7" "zynq7000" "virtexu" "virtexup"]

if {[lsearch $fpga_techs $TECH] >= 0} {
    if {$TECH eq "virtex7"} {
	    set FPGA_PART_NUM "xc7v2000tflg1925-2"
        set FPGA_FAMILY "VIRTEX-7"
        set FPGA_SPEED_GRADE "-2"
    }
    if {$TECH eq "zynq7000"} {
    	set FPGA_PART_NUM "xc7z020clg484-1"
        set FPGA_FAMILY "VIRTEX-7"
        set FPGA_SPEED_GRADE "-1"
    }
    if {$TECH eq "virtexu"} {
    	set FPGA_PART_NUM "xcvu440-flga2892-2-e"
        set FPGA_FAMILY "VIRTEX-u"
        set FPGA_SPEED_GRADE "-2"
    }
    if {$TECH eq "virtexup"} {
#    	set FPGA_PART_NUM "xcvu9p-flga2104-2L-e"
    	set FPGA_PART_NUM "xcvu9p-flga2104-2-e"
        set FPGA_FAMILY "VIRTEX-uplus"
        set FPGA_SPEED_GRADE "-2"
    }
}
