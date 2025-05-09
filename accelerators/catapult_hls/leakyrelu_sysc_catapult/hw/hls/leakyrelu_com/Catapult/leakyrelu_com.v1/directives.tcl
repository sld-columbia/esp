//  Catapult Ultra Synthesis 2025.1/1166825 (Production Release) Sun Feb 16 14:04:49 PST 2025
//  
//          Copyright (c) Siemens EDA, 1996-2025, All Rights Reserved.
//                        UNPUBLISHED, LICENSED SOFTWARE.
//             CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
//                   PROPERTY OF SIEMENS EDA OR ITS LICENSORS.
//  
//  Running on Linux gtombesi@corsica:22117 3.10.0-1160.102.1.el7.x86_64 x86_64 aol
//  
//  Package information: SIFLIBS v28.1_0.0, HLS_PKGS v28.1_0.0, 
//                       SIF_TOOLKITS v28.1_0.0, SIF_XILINX v28.1_0.0, 
//                       SIF_ALTERA v28.1_0.0, CCS_LIBS v28.1_0.0, 
//                       CDS_PPRO v2024.2_1, CDS_DesignChecker v2025.1, 
//                       CDS_OASYS v21.1_3.1, CDS_PSR v24.2_0.4, 
//                       DesignPad v2.78_1.0, DesignAnalyzer 2025.1/1166575
//  
solution new -state initial
solution options defaults
solution options set /OnTheFly/VthAttributeType cell_lib
solution options set /Architectural/DefaultLoopMerging false
solution options set /Input/CompilerFlags {-DCONNECTIONS_ACCURATE_SIM -DCONNECTIONS_NAMING_ORIGINAL -DHLS_CATAPULT}
solution options set /Input/SearchPath {../../../../common/matchlib_toolkit/include ../../../../common/matchlib_toolkit/examples/boost_home/ ../../../../common/matchlib_toolkit/examples/matchlib/cmod/include ../../inc/ ../../tb/ ../../../../common/inc/ ../../../../common/inc/core/systems ../../inc/mem_bank}
solution options set /Output/OutputVHDL false
solution options set /Output/GenerateCycleNetlist false
solution options set /Output/PackageOutput true
solution options set /Output/PackageStaticFiles true
solution options set /Output/PrefixStaticFiles true
solution options set /Output/DoNotModifyNames true
solution options set /Output/Basename {schedule {cyc${ENTITY}} extract {${ENTITY}}}
solution options set /Output/SubBlockNamePrefix esp_acc_DUMMY_
solution options set /Flows/QuestaSIM/ENABLE_CODE_COVERAGE true
solution file add ../../tb/testbench.cpp -type C++ -exclude true
solution file add ../../tb/testbench.hpp -type CHEADER -exclude true
solution file add ../../tb/sc_main.cpp -type C++ -exclude true
solution file add ../../tb/system.hpp -type CHEADER -exclude true
solution file add ../../inc/leakyrelu_com.h -type CHEADER
solution file add ../../inc/leakyrelu_specs.h -type CHEADER -args {-DDMA_WIDTH=64 }
directive set -DESIGN_GOAL area
directive set -SPECULATE true
directive set -MEM_MAP_THRESHOLD 32
directive set -LOGIC_OPT false
directive set -FSM_ENCODING none
directive set -FSM_BINARY_ENCODING_THRESHOLD 64
directive set -REG_MAX_FANOUT 0
directive set -NO_X_ASSIGNMENTS true
directive set -SAFE_FSM false
directive set -REGISTER_SHARING_MAX_WIDTH_DIFFERENCE 8
directive set -REGISTER_SHARING_LIMIT 0
directive set -ASSIGN_OVERHEAD 0
directive set -TIMING_CHECKS true
directive set -MUXPATH true
directive set -REALLOC true
directive set -UNROLL no
directive set -IO_MODE super
directive set -CHAN_IO_PROTOCOL use_library
directive set -ARRAY_SIZE 1024
directive set -IDLE_SIGNAL {}
directive set -STALL_FLAG_SV off
directive set -STALL_FLAG false
directive set -TRANSACTION_DONE_SIGNAL true
directive set -DONE_FLAG {}
directive set -READY_FLAG {}
directive set -START_FLAG {}
directive set -TRANSACTION_SYNC ready
directive set -RESET_CLEARS_ALL_REGS use_library
directive set -CLOCK_OVERHEAD 20.000000
directive set -ON_THE_FLY_PROTOTYPING false
directive set -OPT_CONST_MULTS use_library
directive set -CHARACTERIZE_ROM false
directive set -PROTOTYPE_ROM true
directive set -ROM_THRESHOLD 64
directive set -CLUSTER_ADDTREE_IN_WIDTH_THRESHOLD 0
directive set -CLUSTER_ADDTREE_IN_COUNT_THRESHOLD 0
directive set -CLUSTER_OPT_CONSTANT_INPUTS true
directive set -CLUSTER_RTL_SYN false
directive set -CLUSTER_FAST_MODE false
directive set -CLUSTER_TYPE combinational
directive set -PIPELINE_RAMP_UP true
go new
solution design set LeakyreluEngine -top
directive set -MERGEABLE false
directive set -CLOCKS {clk {-CLOCK_PERIOD 5.0 -CLOCK_EDGE rising -CLOCK_UNCERTAINTY 0.0 -CLOCK_HIGH_TIME 2.5 -RESET_SYNC_NAME rst -RESET_ASYNC_NAME arst_n -RESET_KIND sync -RESET_SYNC_ACTIVE high -RESET_ASYNC_ACTIVE low -ENABLE_ACTIVE high}}
directive set -REGISTER_THRESHOLD 34
go analyze
solution design set LeakyreluEngine -top
go compile
directive set -CLOCKS {clk {-CLOCK_PERIOD 5.0 -CLOCK_UNCERTAINTY 0.0 -CLOCK_HIGH_TIME 2.5}}
solution library add mgc_Xilinx-VIRTEX-7-2_beh -- -rtlsyntool Vivado -manufacturer Xilinx -family VIRTEX-7 -speed -2 -part xc7vx485tffg1761-2
go libraries
go extract
