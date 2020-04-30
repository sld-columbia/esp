# Copyright 2018 Columbia University, SLD Group

#
# Enable DIFT support
#

set DIFT_ENABLED 0

#
# Source the common configurations
#

source ../../common/stratus/project.tcl

#
# Set the library for the memories
#

use_hls_lib "./memlib"

#
# Set the target clock and reset period
#

if {$TECH eq "virtex7"} {
    set CLOCK_PERIOD                 10.0
    set SIM_CLOCK_PERIOD             10000.0
    set_attr default_input_delay     0.1
}

if {$TECH eq "zynq7000"} {
    set CLOCK_PERIOD                 10.0
    set SIM_CLOCK_PERIOD             10000.0
    set_attr default_input_delay     0.1
}

if {$TECH eq "virtexu"} {
    set CLOCK_PERIOD                 8.0
    set SIM_CLOCK_PERIOD             8000.0
    set_attr default_input_delay     0.1
}

if {$TECH eq "virtexup"} {
    set CLOCK_PERIOD                 6.4
    set SIM_CLOCK_PERIOD             6400.0
    set_attr default_input_delay     0.1
}

if {$TECH eq "cmos32soi"} {
    set CLOCK_PERIOD                 1000.0
    set SIM_CLOCK_PERIOD             1000.0
    set_attr default_input_delay     100.0
}

set_attr clock_period $CLOCK_PERIOD

set SIM_RESET_PERIOD [expr $SIM_CLOCK_PERIOD * 30]

#
# Set common options for all configurations
#

set PRINT no
set SCHED_ASAP no
set COMMON_HLS_FLAGS "--clock_period=$CLOCK_PERIOD --prints=$PRINT --sched_asap=$SCHED_ASAP"
set COMMON_CFG_FLAGS "-DCLOCK_PERIOD=$SIM_CLOCK_PERIOD -DRESET_PERIOD=$SIM_RESET_PERIOD"

#
# Testbench or system level modules
#

define_system_module ../tb/pv_obfuscator.c ../tb/utils.c
define_system_module tb ../tb/system.cpp ../tb/sc_main.cpp

#
# System level modules to be synthesized
#

define_hls_module obfuscator ../src/obfuscator.cpp

#
# TB configuration
#

set INPUT_PATH  "../stratus/input"
set OUTPUT_PATH "../stratus/output"

# -- Lincoln
set I_ROW_BLURS(lincoln) "75"
set I_COL_BLURS(lincoln) "125"
set E_ROW_BLURS(lincoln) "175"
set E_COL_BLURS(lincoln) "250"

# -- Jefferson
set I_ROW_BLURS(jefferson) "100"
set I_COL_BLURS(jefferson) "150"
set E_ROW_BLURS(jefferson) "250"
set E_COL_BLURS(jefferson) "300"

# -- Washington
set I_ROW_BLURS(washington) "150"
set I_COL_BLURS(washington) "75"
set E_ROW_BLURS(washington) "350"
set E_COL_BLURS(washington) "300"

# -- Roosvelt
set I_ROW_BLURS(roosevelt) "75"
set I_COL_BLURS(roosevelt) "100"
set E_ROW_BLURS(roosevelt) "250"
set E_COL_BLURS(roosevelt) "250"

set TESTBENCH "lincoln"
# set TESTBENCH "jefferson"
# set TESTBENCH "washington"
# set TESTBENCH "roosevelt"

#
# DSE configurations
#

set NUM_PORTS "1"

set DMA_CHUNK "8"

set TAG_OFFSETS "1"

#
# Split the multipliers
#

set_attr split_add 32
set_attr split_multiply 32

#
# Generating sim/system configs
#

foreach dma [list 32] {

    set ARGV ""
    append ARGV "$INPUT_PATH/$TESTBENCH.txt " ; # argv[1]
    append ARGV "$OUTPUT_PATH/$TESTBENCH.txt "; # argv[2]
    append ARGV "$I_ROW_BLURS($TESTBENCH) "   ; # argv[3]
    append ARGV "$I_COL_BLURS($TESTBENCH) "   ; # argv[4]
    append ARGV "$E_ROW_BLURS($TESTBENCH) "   ; # argv[5]
    append ARGV "$E_COL_BLURS($TESTBENCH) "   ; # argv[6]

    define_io_config * IOCFG_DMA$dma -DDMA_WIDTH=$dma \
                                     -DNUM_PORTS=$NUM_PORTS \
                                     -DDMA_CHUNK=$DMA_CHUNK \
                                      $COMMON_CFG_FLAGS

    define_system_config tb TESTBENCH_DMA$dma -io_config IOCFG_DMA$dma

    # Behavioral simulation

    define_sim_config "BEHAV_DMA$dma" "obfuscator BEH" "tb TESTBENCH_DMA$dma" \
        -io_config IOCFG_DMA$dma -argv $ARGV

    # High-Level Synthesi Conf

    define_hls_config obfuscator BASIC -io_config IOCFG_DMA$dma $COMMON_HLS_FLAGS

    # RTL Verilog simulation

    if {$TECH_IS_XILINX == 1} {

        define_sim_config "BASIC_V" "obfuscator RTL_V BASIC" "tb TESTBENCH_DMA$dma" \
            -io_config IOCFG_DMA$dma -verilog_top_modules glbl -argv $ARGV

    } else {

        define_sim_config "BASIC_V" "obfuscator RTL_V BASIC" "tb TESTBENCH_DMA$dma" \
            -io_config IOCFG_DMA$dma -argv $ARGV
    }

}; # foreach dma

#
# Compile Flags
#

set_attr hls_cc_options "$INCLUDES"

#
# Simulation Options
#

use_systemc_simulator incisive
set_attr cc_options "$INCLUDES -DCLOCK_PERIOD=$SIM_CLOCK_PERIOD"
set_attr end_of_sim_command "make saySimPassed"
