# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
#-------------- MCS Generation ----------------------
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8            [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1    [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES         [current_design]
set_property BITSTREAM.CONFIG.SPI_OPCODE 8'h6B          [current_design]
set_property CONFIG_MODE SPIx8                          [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE            [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown        [current_design]
set_property CONFIG_VOLTAGE 1.8                         [current_design]
set_property CFGBVS GND                                 [current_design]

# --- Input clock and reset
# "DDR4_CLK_100MHZ_P" - Bank 66 VCCO - DDR4_VDDQ_1V2 - IO_L11P_T1U_N8_GC_66
set_property PACKAGE_PIN BH51 [get_ports c0_sys_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports c0_sys_clk_p]

# "DDR4_CLK_100MHZ_N" - Bank  66 VCCO - DDR4_VDDQ_1V2 - IO_L11N_T1U_N9_GC_66
set_property PACKAGE_PIN BJ51 [get_ports c0_sys_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports c0_sys_clk_n]

# "CPU_RESET" - Bank  64 VCCO - DDR4_VDDQ_1V2 - IO_L1N_T0L_N1_DBC_64
set_property PACKAGE_PIN BM29 [get_ports reset]
set_property IOSTANDARD LVCMOS12 [get_ports reset]

create_clock -period 10.0 [get_ports c0_sys_clk_p]

# Recover elaborated clock name
set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

# Declare asynchronous clocks
set_clock_groups -asynchronous -group [get_clocks ${clkm_elab}] -group [get_clocks ${refclk_elab}]


# --- False paths
set_false_path -to [get_ports {led[*]}]
set_false_path -from [get_ports reset]

# --- UART

set_property PACKAGE_PIN BN26 [get_ports uart_txd]
set_property PACKAGE_PIN BP23 [get_ports uart_ctsn]
set_property PACKAGE_PIN BP26 [get_ports uart_rxd]
set_property PACKAGE_PIN BP22 [get_ports uart_rtsn]

set_property IOSTANDARD LVCMOS18 [get_ports uart_*]

# Inputs
set_input_delay -clock [get_clocks ${refclk_elab}] -max 1.500 [get_ports uart_rxd]
set_input_delay -clock [get_clocks ${refclk_elab}] -min -add_delay 0.500 [get_ports uart_rxd]
set_input_delay -clock [get_clocks ${refclk_elab}] -max 1.500 [get_ports uart_ctsn]
set_input_delay -clock [get_clocks ${refclk_elab}] -min -add_delay 0.500 [get_ports uart_ctsn]

# Outputs
set_output_delay -clock [get_clocks ${refclk_elab}] -max 0.500 [get_ports uart_txd]
set_output_delay -clock [get_clocks ${refclk_elab}] -min -add_delay -0.500 [get_ports uart_txd]
set_output_delay -clock [get_clocks ${refclk_elab}] -max 0.500 [get_ports uart_rtsn]
set_output_delay -clock [get_clocks ${refclk_elab}] -min -add_delay -0.500 [get_ports uart_rtsn]

# --- GPIO

set_property PACKAGE_PIN BH24 [get_ports {led[0]}]
set_property PACKAGE_PIN BG24 [get_ports {led[1]}]
set_property PACKAGE_PIN BG25 [get_ports {led[2]}]
set_property PACKAGE_PIN BF25 [get_ports {led[3]}]
set_property PACKAGE_PIN BF26 [get_ports {led[4]}]
set_property PACKAGE_PIN BF27 [get_ports {led[5]}]
set_property PACKAGE_PIN BG27 [get_ports {led[6]}]

set_property IOSTANDARD LVCMOS18 [get_ports led*]
