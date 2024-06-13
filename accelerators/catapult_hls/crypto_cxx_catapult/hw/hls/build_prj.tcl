# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

############################################################
# Design Parameters
############################################################

#
# Source the common configurations
#
source ../../../common/hls/common.tcl

#
# Local synthesis attributes
#
if {$TECH eq "gf12"} {
    set CLOCK_PERIOD 1.25
    set CLOCK_HIGH_TIME 0.625
} elseif {$TECH eq "virtex7"} {
    set CLOCK_PERIOD 12.0
    set CLOCK_HIGH_TIME 6.0
} else {
    set CLOCK_PERIOD 10.0
    set CLOCK_HIGH_TIME 5.0
}

#
# Accelerator
#

set ACCELERATOR "crypto_cxx_catapult"
set PLM_WIDTH 32

set uarch "basic"

#
# Technology-dependend reports and project dirs.
#

file delete -force -- $ACCELERATOR\_$uarch\_fx$PLM_WIDTH\_dma$DMA_WIDTH
file delete -force -- $ACCELERATOR\_$uarch\_fx$PLM_WIDTH\_dma$DMA_WIDTH.css
project new -name $ACCELERATOR\_$uarch\_fx$PLM_WIDTH\_dma$DMA_WIDTH
set CSIM_RESULTS "./tb_data/catapult_csim_results.log"
set RTL_COSIM_RESULTS "./tb_data/catapult_rtl_cosim_results.log"

#
# Reset the options to the factory defaults
#

solution new -state initial
solution options defaults

solution options set Flows/ModelSim/VLOG_OPTS {-suppress 12110}
solution options set Flows/ModelSim/VSIM_OPTS {-t ps -suppress 12110}
solution options set Flows/DesignCompiler/OutNetlistFormat verilog
solution options set /Input/CppStandard c++11
#solution options set /Input/TargetPlatform x86_64

set CATAPULT_VERSION  [string map { / - } [string map { . - } [application get /SYSTEM/RELEASE_VERSION]]]
solution options set Cache/UserCacheHome "catapult_cache_$CATAPULT_VERSION"
solution options set Cache/DefaultCacheHomeEnabled false
solution options set /Flows/SCVerify/DISABLE_EMPTY_INPUTS true

flow package require /SCVerify

flow package option set /SCVerify/USE_CCS_BLOCK true
flow package option set /SCVerify/USE_QUESTASIM true
flow package option set /SCVerify/USE_NCSIM false

#options set Flows/OSCI/GCOV true
#flow package require /CCOV
#flow package require /SLEC
#flow package require /CDesignChecker

#directive set -DESIGN_GOAL area
##directive set -OLD_SCHED false
#directive set -SPECULATE true
#directive set -MERGEABLE true
directive set -REGISTER_THRESHOLD 8192
#directive set -MEM_MAP_THRESHOLD 32
#directive set -LOGIC_OPT false
#directive set -FSM_ENCODING none
#directive set -FSM_BINARY_ENCODING_THRESHOLD 64
#directive set -REG_MAX_FANOUT 0
#directive set -NO_X_ASSIGNMENTS true
#directive set -SAFE_FSM false
#directive set -REGISTER_SHARING_MAX_WIDTH_DIFFERENCE 8
#directive set -REGISTER_SHARING_LIMIT 0
#directive set -ASSIGN_OVERHEAD 0
#directive set -TIMING_CHECKS true
#directive set -MUXPATH true
#directive set -REALLOC true
#directive set -UNROLL no
#directive set -IO_MODE super
#directive set -CHAN_IO_PROTOCOL standard
#directive set -ARRAY_SIZE 1024
#directive set -REGISTER_IDLE_SIGNAL false
#directive set -IDLE_SIGNAL {}
#directive set -STALL_FLAG false
##############################directive set -TRANSACTION_DONE_SIGNAL true
#directive set -DONE_FLAG {}
#directive set -READY_FLAG {}
#directive set -START_FLAG {}
#directive set -BLOCK_SYNC none
#directive set -TRANSACTION_SYNC ready
#directive set -DATA_SYNC none
#directive set -CLOCKS {clk {-CLOCK_PERIOD 0.0 -CLOCK_EDGE rising -CLOCK_UNCERTAINTY 0.0 -RESET_SYNC_NAME rst -RESET_ASYNC_NAME arst_n -RESET_KIND sync -RESET_SYNC_ACTIVE high -RESET_ASYNC_ACTIVE low -ENABLE_ACTIVE high}}
directive set -RESET_CLEARS_ALL_REGS true
#directive set -CLOCK_OVERHEAD 20.000000
#directive set -OPT_CONST_MULTS use_library
#directive set -CHARACTERIZE_ROM false
#directive set -PROTOTYPE_ROM true
#directive set -ROM_THRESHOLD 64
#directive set -CLUSTER_ADDTREE_IN_COUNT_THRESHOLD 0
#directive set -CLUSTER_OPT_CONSTANT_INPUTS true
#directive set -CLUSTER_RTL_SYN false
#directive set -CLUSTER_FAST_MODE false
#directive set -CLUSTER_TYPE combinational
#directive set -COMPGRADE fast

# Flag to indicate SCVerify readiness
set can_simulate 1

# Design specific options.

#
# Flags
#

solution options set Flows/QuestaSIM/SCCOM_OPTS {-64 -g -x c++ -Wall -Wno-unused-label -Wno-unknown-pragmas}
set PRE_FLAGS ""
append PRE_FLAGS " -D__MENTOR_CATAPULT_HLS__"
append PRE_FLAGS " -DSYN_SHA256"
append PRE_FLAGS " -DSYN_AES_ECB"
append PRE_FLAGS " -DSYN_AES_CTR"
append PRE_FLAGS " -DSYN_AES_CBC"
append PRE_FLAGS " -DSYN_AES_GCM"
solution options set /Input/CompilerFlags ${PRE_FLAGS}

#
# Input
#

solution options set /Input/SearchPath { \
    ../tb \
    ../inc \
    ../src \
    ../inc/sha1 \
    ../src/sha1 \
    ../inc/sha2 \
    ../src/sha2 \
    ../inc/aes \
    ../src/aes \
    ../inc/aes/modes \
    ../src/aes/modes \
    ../../../common/inc }

if {$TECH eq "gf12"} {
    solution options set ComponentLibs/SearchPath " $COMPONENT_LIBS_SEARCH_PATH "
}

# Add source files.
solution file add ../inc/conf_info.hpp -type C++
solution file add ../inc/crypto_cxx_catapult.hpp -type C++
solution file add ../inc/data.hpp -type C++

solution file add ../inc/sha1/defines.h -type C++
solution file add ../inc/sha1/sha1.h -type C++
solution file add ../inc/sha2/defines.h -type C++
solution file add ../inc/sha2/sha2.h -type C++
solution file add ../inc/sha2/sha2_256.h -type C++
solution file add ../inc/sha2/sha2_512.h -type C++
solution file add ../inc/aes/aes.h -type C++
solution file add ../inc/aes/common.h -type C++
solution file add ../inc/aes/defines.h -type C++
solution file add ../inc/aes/modes/gcm.h -type C++

solution file add ../src/crypto_cxx_catapult.cpp -type C++
solution file add ../src/sha1/sha1.cpp -type C++
solution file add ../src/sha2/sha2.cpp -type C++
solution file add ../src/aes/aes.cpp -type C++

solution file add ../tb/main.cpp -type C++ -exclude true

solution file set ../inc/crypto_cxx_catapult.hpp -args -DDMA_WIDTH=$DMA_WIDTH
solution file set ../src/crypto_cxx_catapult.cpp -args -DDMA_WIDTH=$DMA_WIDTH
solution file set ../tb/main.cpp -args -DDMA_WIDTH=$DMA_WIDTH

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

#
#
#

go analyze

#
#
#


# Set the top module and inline all of the other functions.

# 10.4c
#directive set -DESIGN_HIERARCHY ${ACCELERATOR}

# 10.5
solution design set $ACCELERATOR -top

#solution design set sha1 -block
#solution design set sha2 -block
#solution design set aes -block
#solution design set add_padding -block
#solution design set rm_padding -block
#solution design set mont_red -block
#solution design set mont_red2 -block
#solution design set mont_exp -block
#solution design set adjust_last_input_shift -block

#solution design set sha256_block -block

#directive set PRESERVE_STRUCTS false

#
#
#

# Run C simulation.
if {$opt(csim)} {
    go compile
    flow run /SCVerify/launch_make ./scverify/Verify_orig_cxx_osci.mk {} SIMTOOL=osci sim
}

#
#
#

# Run HLS.
if {$opt(hsynth)} {

    solution library remove *
    if {$TECH eq "gf12"} { 
        solution library add sc9mcpp84_12lp_base_rvt_c14_tt_nominal_max_0p80v_25c_dc -- -rtlsyntool DesignCompiler -vendor GlobalFoundries -technology gf12nm
        solution library add GF12_SRAM_SP_1024x8
        solution library add GF12_SRAM_SP_16384x32
        solution library add GF12_SRAM_SP_16384x64
        solution library add GF12_SRAM_SP_2048x32
        solution library add GF12_SRAM_SP_2048x4
        solution library add GF12_SRAM_SP_2048x8
        solution library add GF12_SRAM_SP_256x16
        solution library add GF12_SRAM_SP_256x64
        solution library add GF12_SRAM_SP_4096x4
        solution library add GF12_SRAM_SP_512x16
        solution library add GF12_SRAM_SP_512x24
        solution library add GF12_SRAM_SP_512x28
        solution library add GF12_SRAM_SP_512x64
        solution library add GF12_SRAM_SP_8192x32
    } else {
        solution library \
            add mgc_Xilinx-$FPGA_FAMILY$FPGA_SPEED_GRADE\_beh -- \
            -rtlsyntool Vivado \
            -manufacturer Xilinx \
            -family $FPGA_FAMILY \
            -speed $FPGA_SPEED_GRADE \
            -part $FPGA_PART_NUM
        solution library add Xilinx_RAMS
        solution library add Xilinx_ROMS
        solution library add Xilinx_FIFO
    }


    #solution library add nangate-45nm_beh -- -rtlsyntool DesignCompiler -vendor Nangate -technology 045nm

    # For Catapult 10.5: disable all sequential clock-gating
    directive set GATE_REGISTERS false

    go libraries

    #
    #
    #

    directive set -CLOCKS " \
        clk { \
            -CLOCK_PERIOD $CLOCK_PERIOD \
            -CLOCK_EDGE rising \
            -CLOCK_HIGH_TIME $CLOCK_HIGH_TIME \
            -CLOCK_OFFSET 0.000000 \
            -CLOCK_UNCERTAINTY 0.0 \
            -RESET_KIND sync \
            -RESET_SYNC_NAME rst \
            -RESET_SYNC_ACTIVE low \
            -RESET_ASYNC_NAME arst_n \
            -RESET_ASYNC_ACTIVE low \
            -ENABLE_NAME {} \
            -ENABLE_ACTIVE high \
        } \
    "

    #directive set /${ACCELERATOR}/sha256_block -MAP_TO_MODULE {[CCORE]}

    # BUGFIX: This prevents the creation of the empty module CGHpart. In the
    # next releases of Catapult HLS, this may be fixed.
    directive set /$ACCELERATOR -GATE_EFFORT normal

    go assembly

    #
    #
    #

    # Top-Module I/O
    directive set /$ACCELERATOR/conf_info:rsc -MAP_TO_MODULE ccs_ioport.ccs_in_wait
    directive set /$ACCELERATOR/dma_read_ctrl:rsc -MAP_TO_MODULE ccs_ioport.ccs_out_wait
    directive set /$ACCELERATOR/dma_write_ctrl:rsc -MAP_TO_MODULE ccs_ioport.ccs_out_wait
    directive set /$ACCELERATOR/dma_read_chnl:rsc -MAP_TO_MODULE ccs_ioport.ccs_in_wait
    directive set /$ACCELERATOR/dma_write_chnl:rsc -MAP_TO_MODULE ccs_ioport.ccs_out_wait
    directive set /$ACCELERATOR/acc_done:rsc -MAP_TO_MODULE ccs_ioport.ccs_sync_out_vld

    # Arrays
    directive set /crypto_cxx_catapult/sha1:h.rom:rsc -MAP_TO_MODULE {[Register]}
    if {$TECH eq "gf12"} {
        directive set /$ACCELERATOR/core/sha1_plm_in.data:rsc -MAP_TO_MODULE GF12_SRAM_SP_2048x32.GF12_SRAM_SP_2048x32
    } else {
        directive set /$ACCELERATOR/core/sha1_plm_in.data:rsc -MAP_TO_MODULE Xilinx_RAMS.BLOCK_1R1W_RBW
    }
    directive set /$ACCELERATOR/core/sha1_plm_in.data:rsc -GEN_EXTERNAL_ENABLE true
    directive set /crypto_cxx_catapult/core/sha1_plm_out.data:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/core/sha1:h:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/core/sha1:data:rsc -MAP_TO_MODULE {[Register]}

    if {$TECH eq "gf12"} {
        directive set /$ACCELERATOR/core/sha2_plm_in.data:rsc -MAP_TO_MODULE GF12_SRAM_SP_2048x32.GF12_SRAM_SP_2048x32
    } else {
        directive set /$ACCELERATOR/core/sha2_plm_in.data:rsc -MAP_TO_MODULE Xilinx_RAMS.BLOCK_1R1W_RBW
    }
    directive set /$ACCELERATOR/core/sha2_plm_in.data:rsc -GEN_EXTERNAL_ENABLE true
    directive set /crypto_cxx_catapult/core/sha2_plm_out.data:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/sha256_block:K256.rom:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/sha256_block#1:K256.rom:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/sha256_block#2:K256.rom:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/sha256:h.rom:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/core/sha256:h:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/core/sha256:data:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/core/sha256_block:tmp:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/core/sha256_block#1:tmp:rsc -MAP_TO_MODULE {[Register]}
    directive set /crypto_cxx_catapult/core/sha256_block#2:tmp:rsc -MAP_TO_MODULE {[Register]}

    #directive set /crypto_cxx_catapult/Te2.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/Te3.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/Te0.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/Te1.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/Td0.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/Td1.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/Td2.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/Td3.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/Td4.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/rcon.rom:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_plm_key.data:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_plm_iv.data:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_plm_in.data:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_plm_out.data:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes:ekey:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_ecb_ctr_cipher:in_mem:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_ecb_ctr_cipher:out_mem:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_ecb_ctr_cipher:tmp_mem:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_cbc_cipher:tmp_mem:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_cbc_cipher:out_mem:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_cbc_cipher:in_mem:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/gcm_init:LL:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/gcm_init:tmp:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/gcm_core:in_tmp:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/gcm_core:out_tmp:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/gcm_core:hash_tmp:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_gcm_cipher:cb:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_gcm_cipher:S:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_gcm_cipher:H:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_gcm_cipher:L:rsc -MAP_TO_MODULE {[Register]}
    #directive set /crypto_cxx_catapult/core/aes_gcm_cipher:J:rsc -MAP_TO_MODULE {[Register]}

    # Loops
    directive set /crypto_cxx_catapult/core/main -MERGEABLE false

    directive set /crypto_cxx_catapult/core/SHA1_LOAD_CTRL_LOOP -MERGEABLE false
    directive set /crypto_cxx_catapult/core/SHA1_LOAD_LOOP -MERGEABLE false
    directive set /crypto_cxx_catapult/core/SHA1_STORE_CTRL_LOOP -MERGEABLE false
    directive set /crypto_cxx_catapult/core/SHA1_STORE_LOOP -MERGEABLE false

    directive set /crypto_cxx_catapult/core/SHA2_LOAD_CTRL_LOOP -MERGEABLE false
    directive set /crypto_cxx_catapult/core/SHA2_LOAD_LOOP -MERGEABLE false
    directive set /crypto_cxx_catapult/core/SHA2_STORE_CTRL_LOOP -MERGEABLE false
    directive set /crypto_cxx_catapult/core/SHA2_STORE_LOOP -MERGEABLE false

    #directive set /crypto_cxx_catapult/core/AES_LOAD_KEY_CTRL_LOOP -MERGEABLE false
    #directive set /crypto_cxx_catapult/core/AES_LOAD_KEY_LOOP -MERGEABLE false
    #directive set /crypto_cxx_catapult/core/AES_LOAD_IV_CTRL_LOOP -MERGEABLE false
    #directive set /crypto_cxx_catapult/core/AES_LOAD_IV_LOOP -MERGEABLE false
    #directive set /crypto_cxx_catapult/core/AES_LOAD_INPUT_CTRL_LOOP -MERGEABLE false
    #directive set /crypto_cxx_catapult/core/AES_LOAD_INPUT_LOOP -MERGEABLE false
    #directive set /crypto_cxx_catapult/core/AES_STORE_CTRL_LOOP -MERGEABLE false
    #directive set /crypto_cxx_catapult/core/AES_STORE_LOOP -MERGEABLE false

    # Loops performance tracing

    # Area vs Latency Goals
    directive set /$ACCELERATOR/core -EFFORT_LEVEL high
    directive set /$ACCELERATOR/core -DESIGN_GOAL Latency

    if {$opt(debug) != 1} {
        go architect

        #
        #
        #

        go allocate

        #
        # RTL
        #

        #directive set ENABLE_PHYSICAL true

        go extract

        #
        #
        #

        if {$opt(rtlsim)} {
            #flow run /SCVerify/launch_make ./scverify/Verify_concat_sim_${ACCELERATOR}_v_msim.mk {} SIMTOOL=msim sim
            flow run /SCVerify/launch_make ./scverify/Verify_concat_sim_${ACCELERATOR}_v_msim.mk {} SIMTOOL=msim simgui
        }

        if {$opt(lsynth)} {
            flow run /Vivado/synthesize -shell vivado_concat_v/concat_${ACCELERATOR}.v.xv
            #flow run /Vivado/synthesize vivado_concat_v/concat_${ACCELERATOR}.v.xv
        }
    }
}

project save

puts "***************************************************************"
puts "uArch: Single block"
puts "***************************************************************"
puts "Done!"

