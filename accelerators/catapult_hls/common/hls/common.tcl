# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-1.0

set TECH $::env(TECH)
set ESP_ROOT $::env(ESP_ROOT)
set ACCELERATOR $::env(ACCELERATOR)
set TECH_PATH "$ESP_ROOT/tech/$TECH"
set MEMTECH_PATH "$ESP_ROOT/rtl/techmap/$TECH/mem"
set DMA_WIDTH $::env(DMA_WIDTH)

#
# Technology Libraries
#
set fpga_techs [list "virtex7" "zynq7000" "virtexu" "virtexup" "gf12"]

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
	# set FPGA_PART_NUM "xcvu9p-flga2104-2L-e"
    	set FPGA_PART_NUM "xcvu9p-flga2104-2-e"
        set FPGA_FAMILY "VIRTEX-uplus"
        set FPGA_SPEED_GRADE "-2"
    }
    if {$TECH eq "gf12"} {
	set COMPONENT_LIBS_SEARCH_PATH \
            {../../../../../tech/gf12/lib-catapult \
            ../../../common/memgen/GF12_SRAM_SP_256x32 \
            ../../../common/memgen/GF12_SRAM_SP_256x64 \
            ../../../common/memgen/GF12_SRAM_SP_256x16 \
            ../../../common/memgen/GF12_SRAM_SP_256x64 \
            ../../../common/memgen/GF12_SRAM_SP_512x16 \
            ../../../common/memgen/GF12_SRAM_SP_512x24 \
            ../../../common/memgen/GF12_SRAM_SP_512x28 \
            ../../../common/memgen/GF12_SRAM_SP_512x64 \
            ../../../common/memgen/GF12_SRAM_SP_1024x8 \
            ../../../common/memgen/GF12_SRAM_SP_2048x4 \
            ../../../common/memgen/GF12_SRAM_SP_2048x8 \
            ../../../common/memgen/GF12_SRAM_SP_2048x32 \
            ../../../common/memgen/GF12_SRAM_SP_4096x4 \
            ../../../common/memgen/GF12_SRAM_SP_4096x32 \
            ../../../common/memgen/GF12_SRAM_SP_4096x64 \
            ../../../common/memgen/GF12_SRAM_SP_8192x32 \
            ../../../common/memgen/GF12_SRAM_SP_8192x64 \
            ../../../common/memgen/GF12_SRAM_SP_16384x32 \
            ../../../common/memgen/GF12_SRAM_SP_16384x64}
    }
}
