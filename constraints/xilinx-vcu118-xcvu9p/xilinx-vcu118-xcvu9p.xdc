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
set_property PACKAGE_PIN E12 [get_ports c0_sys_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports c0_sys_clk_p]

set_property PACKAGE_PIN D12 [get_ports c0_sys_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports c0_sys_clk_n]

set_property PACKAGE_PIN L19 [get_ports reset]
set_property IOSTANDARD LVCMOS12 [get_ports reset]

create_clock -period 4.0 [get_ports c0_sys_clk_p]
set_input_jitter [get_clocks -of_objects [get_ports c0_sys_clk_p]] 0.05

# Recover elaborated clock name
set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

# Declare asynchronous clocks
set_clock_groups -asynchronous -group [get_clocks ${clkm_elab}] -group [get_clocks ${refclk_elab}]


# --- False paths
set_false_path -to [get_ports {led[*]}]
set_false_path -from [get_ports {button[*]}]
set_false_path -from [get_ports reset]
set_false_path -from [get_ports switch*]
set_false_path -to [get_ports switch*]

# --- UART

set_property PACKAGE_PIN BB21 [get_ports uart_txd]
set_property PACKAGE_PIN AY25 [get_ports uart_ctsn]
set_property PACKAGE_PIN AW25 [get_ports uart_rxd]
set_property PACKAGE_PIN BB22 [get_ports uart_rtsn]

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

set_property PACKAGE_PIN AT32 [get_ports {led[0]}]
set_property PACKAGE_PIN AV34 [get_ports {led[1]}]
set_property PACKAGE_PIN AY30 [get_ports {led[2]}]
set_property PACKAGE_PIN BB32 [get_ports {led[3]}]
set_property PACKAGE_PIN BF32 [get_ports {led[4]}]
set_property PACKAGE_PIN AU37 [get_ports {led[5]}]
set_property PACKAGE_PIN AV36 [get_ports {led[6]}]

set_property PACKAGE_PIN BB24 [get_ports {button[0]}]
set_property PACKAGE_PIN BE23 [get_ports {button[1]}]
set_property PACKAGE_PIN BF22 [get_ports {button[2]}]
set_property PACKAGE_PIN BE22 [get_ports {button[3]}]

set_property PACKAGE_PIN B17 [get_ports {switch[0]}]
set_property PACKAGE_PIN G16 [get_ports {switch[1]}]
set_property PACKAGE_PIN J16 [get_ports {switch[2]}]
set_property PACKAGE_PIN D21 [get_ports {switch[3]}]

set_property IOSTANDARD LVCMOS12 [get_ports led*]
set_property IOSTANDARD LVCMOS18 [get_ports button*]
set_property IOSTANDARD LVCMOS12 [get_ports switch*]
