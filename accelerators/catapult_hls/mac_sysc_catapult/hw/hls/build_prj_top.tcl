#Copyright (c) 2011-2023 Columbia University, System Level Design Group
#SPDX-License-Identifier: Apache-2.0

source ../../../common/hls/common.tcl


if {$TECH eq "virtex7"} {
source ../inc/mem_bank/DUAL_PORT_RBW_VIRTEX7.tcl
} elseif {$TECH eq "virtexu"} {
source ../inc/mem_bank/DUAL_PORT_RBW_VIRTEXU.tcl
} elseif {$TECH eq "virtexup"} {
source ../inc/mem_bank/DUAL_PORT_RBW_VIRTEXUP.tcl}

source ./build_prj.tcl
