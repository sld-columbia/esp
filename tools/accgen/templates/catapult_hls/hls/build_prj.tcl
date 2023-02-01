#Copyright (c) 2011-2023 Columbia University, System Level Design Group
#SPDX-License-Identifier: Apache-2.0

project new -name $ACCELERATOR\_dma$DMA_WIDTH
set CSIM_RESULTS "./tb_data/catapult_csim_results.log"
set RTL_COSIM_RESULTS "./tb_data/catapult_rtl_cosim_results.log"
set sfd [file dir [info script]]

solution new -state initial
solution options defaults

options set /Input/CppStandard c++11
options set /Input/CompilerFlags "-DCONNECTIONS_ACCURATE_SIM -DCONNECTIONS_NAMING_ORIGINAL -DHLS_CATAPULT"
options set /Input/SearchPath {/opt/cad/catapult/shared/examples/matchlib/toolkit/include} -append
options set /Input/SearchPath {/opt/cad/catapult/shared/pkgs/matchlib/cmod/include} -append
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
solution file add "../inc/<accelerator_name>_data_types.hpp"
solution file add "../../../common/inc/esp_dma_info_sysc.hpp"
solution file add "../inc/<accelerator_name>_conf_info.hpp"
solution file add "../inc/<accelerator_name>.hpp"
solution file add "../src/<accelerator_name>.cpp"
solution file add "../inc/<accelerator_name>_specs.hpp"
solution file add "../inc/mem_wrap.hpp"

solution file set ../inc/<accelerator_name>_specs.hpp -args -DDMA_WIDTH=$DMA_WIDTH

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

go new

go analyze
solution design set $ACCELERATOR -top

go compile

solution library \
    add mgc_Xilinx-$FPGA_FAMILY$FPGA_SPEED_GRADE\_beh -- \
    -rtlsyntool Vivado \
    -manufacturer Xilinx \
    -family $FPGA_FAMILY \
    -speed $FPGA_SPEED_GRADE \
    -part $FPGA_PART_NUM

solution library add DUAL_PORT_RBW

go libraries
directive set -CLOCKS {clk {-CLOCK_PERIOD 5.0}}

go assembly
go architect
go allocate
go extract

project save
