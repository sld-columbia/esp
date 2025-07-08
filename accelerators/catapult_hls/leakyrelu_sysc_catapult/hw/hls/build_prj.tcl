#Copyright (c) 2011-2025 Columbia University, System Level Design Group
#SPDX-License-Identifier: Apache-2.0

set proj_name "${ACCELERATOR}_dma${DMA_WIDTH}"
set ccs_file "${proj_name}.ccs"

if {[file exists $ccs_file]} {
    project load $ccs_file
} else {
    project new -name $proj_name
}

set CSIM_RESULTS "./tb_data/catapult_csim_results.log"
set RTL_COSIM_RESULTS "./tb_data/catapult_rtl_cosim_results.log"
set sfd [file dir [info script]]

solution options defaults

options set /Input/CppStandard c++11
options set /Input/CompilerFlags "-DCONNECTIONS_ACCURATE_SIM -DCONNECTIONS_NAMING_ORIGINAL -DHLS_CATAPULT"
options set /Input/SearchPath {../../../common/matchlib_toolkit/include} -append
options set /Input/SearchPath {../../../common/matchlib_toolkit/examples/boost_home/} -append
options set /Input/SearchPath {../../../common/matchlib_toolkit/examples/matchlib/cmod/include} -append

flow package require /SCVerify
flow package require /QuestaSIM
flow package option set /QuestaSIM/ENABLE_CODE_COVERAGE true

#
# Input
#

solution options set /Input/SearchPath { \
    ../inc/ \
    ../tb/ \
    ../../../common/inc/ \
    ../../../common/inc/core/systems \
    ../inc/mem_bank
} -append


solution new -state new -solution solution.v1 ${ACCELERATOR}

solution file add "../tb/testbench.cpp" -exclude true
solution file add "../tb/testbench.hpp" -exclude true
solution file add "../tb/sc_main.cpp" -exclude true
solution file add "../tb/system.hpp" -exclude true
solution file add "../inc/leakyrelu_data_types.h"
solution file add "../../../common/inc/esp_dma_info_sysc.hpp"
solution file add "../inc/leakyrelu_conf_info.h"
solution file add "../inc/leakyrelu.h"
solution file add "../inc/leakyrelu_cfg.h"
solution file add "../inc/leakyrelu_ctrl.h"
solution file add "../inc/leakyrelu_com.h"
solution file add "../inc/leakyrelu_specs.h"

solution file set ../inc/leakyrelu_specs.h -args -DDMA_WIDTH=$DMA_WIDTH

#
# Output
#

# Verilog only
solution option set Output/OutputVHDL false
solution option set Output/OutputVerilog true

# Package output in Solution dir
solution option set Output/PackageOutput true
solution option set Output/PackageStaticFiles true

# Add Prefix to library and generated sub-blocks
solution option set Output/PrefixStaticFiles true
solution options set Output/SubBlockNamePrefix "esp_acc_${ACCELERATOR}_"

# Do not modify names
solution option set Output/DoNotModifyNames true
options set Message/ErrorOverride ASSERT-1 -remove


solution library \
    add mgc_Xilinx-$FPGA_FAMILY$FPGA_SPEED_GRADE\_beh -- \
    -rtlsyntool Vivado \
    -manufacturer Xilinx \
    -family $FPGA_FAMILY \
    -speed $FPGA_SPEED_GRADE \
    -part $FPGA_PART_NUM

solution options set ComponentLibs/SearchPath ./leakyrelu_ctrl/Catapult -append
solution options set ComponentLibs/SearchPath ./leakyrelu_cfg/Catapult -append
solution options set ComponentLibs/SearchPath ./leakyrelu_com/Catapult -append

# solution library add DUAL_PORT_RBW
directive set -CLOCKS {clk {-CLOCK_PERIOD 5.0}}

solution library add {[Block] leakyrelu_ctrl.v1}
solution library add {[Block] leakyrelu_cfg.v1}
solution library add {[Block] leakyrelu_com.v1}

solution design set $ACCELERATOR -top

go libraries

directive set /leakyrelu_sysc_catapult/LeakyreluConfig -MAP_TO_MODULE {[Block] leakyrelu_cfg.v1}
directive set /leakyrelu_sysc_catapult/LeakyreluEngine -MAP_TO_MODULE {[Block] leakyrelu_com.v1}
directive set /leakyrelu_sysc_catapult/LeakyreluController -MAP_TO_MODULE {[Block] leakyrelu_ctrl.v1}

go extract


project save
