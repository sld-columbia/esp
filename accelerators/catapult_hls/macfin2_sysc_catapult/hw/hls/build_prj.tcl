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

options set /Input/SearchPath "$sfd/../inc/mem_bank" -append
options set /ComponentLibs/SearchPath "$sfd/../inc/mem_bank" -append

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
    ../inc/mem_bank } -append

solution file add "../tb/testbench.cpp" -exclude true
solution file add "../tb/testbench.hpp" -exclude true
solution file add "../tb/sc_main.cpp" -exclude true
solution file add "../tb/system.hpp" -exclude true
solution file add "../inc/macfin2_data_types.h"
solution file add "../../../common/inc/esp_dma_info_sysc.hpp"
solution file add "../inc/macfin2_conf_info.h"
solution file add "../inc/macfin2.h"
solution file add "../inc/DataPath.h"
solution file add "../inc/Ctrl.h"
solution file add "../inc/macfin2_specs.h"

solution file set ../inc/macfin2_specs.h -args -DDMA_WIDTH=$DMA_WIDTH

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


solution library \
    add mgc_Xilinx-$FPGA_FAMILY$FPGA_SPEED_GRADE\_beh -- \
    -rtlsyntool Vivado \
    -manufacturer Xilinx \
    -family $FPGA_FAMILY \
    -speed $FPGA_SPEED_GRADE \
    -part $FPGA_PART_NUM

solution library add DUAL_PORT_RBW
directive set -CLOCKS {clk {-CLOCK_PERIOD 5.0}}


go analyze

# solution design set $ACCELERATOR -top
################
# # Read Design
# solution file add ${sfd}/src/testbench.cpp -type C++
# go analyze

# # Synthesize 'transpose' block
# solution design set transpose -top
# go extract

# # Synthesize 'mac' block
# go analyze
# solution design set mac -top
# go extract

# # Synthesize 'top' block with pre-synthesized blocks
# go analyze
# solution design set matrixMultiply -top
# solution library add {[Block] mac.v1}
# solution library add {[Block] transpose.v1}
# go libraries
###################

solution new -state new -solution solution.v1 Ctrl
solution design set Ctrl -top

go compile
go libraries
go assembly
go architect
go allocate
go extract

solution new -state new -solution solution.v1 DataPath
solution design set DataPath -top

go compile
go libraries
go assembly
go architect
go allocate
go extract

solution new -state new -solution solution.v1 ${ACCELERATOR}
solution design set $ACCELERATOR -top

solution library add {[Block] Ctrl.v1}
solution library add {[Block] DataPath.v1}
go compile
go libraries
go assembly
go architect
go allocate
go extract


project save
