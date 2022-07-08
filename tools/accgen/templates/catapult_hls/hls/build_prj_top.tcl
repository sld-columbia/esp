# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

source ../../../common/hls/common.tcl


if {$TECH eq "virtex7"} {
source ../inc/mem_bank/BLOCK_1R1W_RBW_VIRTEX7.tcl
} elseif {$TECH eq "virtexu"} {
source ../inc/mem_bank/BLOCK_1R1W_RBW_VIRTEXU.tcl} elseif {$TECH eq "virtexup"} {
source ../inc/mem_bank/BLOCK_1R1W_RBW_VIRTEXUP.tcl}

source ./build_prj.tcl
