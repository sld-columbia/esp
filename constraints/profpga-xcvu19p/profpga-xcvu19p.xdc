# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#              Bitstream Configuration                     -
#-----------------------------------------------------------
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

#-----------------------------------------------------------
#              Clock Pins                                  -
#-----------------------------------------------------------

# Reference clocks pins are connected to DDR4 cards and to the DMBI interface


#-----------------------------------------------------------
#              UART                                        -
#-----------------------------------------------------------

# {ba1_eb1_UART1_CTSN}
set_property PACKAGE_PIN M26 [get_ports uart_rtsn]

# {ba1_eb1_UART1_RTSN}
set_property PACKAGE_PIN M22 [get_ports uart_ctsn]

# {ba1_eb1_UART1_RXD}
set_property PACKAGE_PIN L22 [get_ports uart_txd]

# {ba1_eb1_UART1_TXD}
set_property PACKAGE_PIN L25 [get_ports uart_rxd]

set_property IOSTANDARD LVCMOS18 [get_ports {uart_*}]

#-----------------------------------------------------------
#              LEDs                                        -
#-----------------------------------------------------------

# {LED_RED}
set_property PACKAGE_PIN BF34 [get_ports LED_RED]

# {LED_GREEN}
set_property PACKAGE_PIN BE34 [get_ports LED_GREEN]

# {LED_BLUE}
set_property PACKAGE_PIN BE29 [get_ports LED_BLUE]

# {LED_YELLOW}
set_property PACKAGE_PIN BE30 [get_ports LED_YELLOW]

set_property IOSTANDARD LVCMOS18 [get_ports {LED_*}]

#-----------------------------------------------------------
#              Diagnostic LEDs                             -
#-----------------------------------------------------------
# {ta0_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c0_calib_complete]
set_property DRIVE 8 [get_ports c0_calib_complete]
set_property PACKAGE_PIN C9 [get_ports {c0_calib_complete}]

# {ta0_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c0_diagnostic_led]
set_property DRIVE 8 [get_ports c0_diagnostic_led]
set_property PACKAGE_PIN B13 [get_ports {c0_diagnostic_led}]

# {ta1_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c1_calib_complete]
set_property DRIVE 8 [get_ports c1_calib_complete]
set_property PACKAGE_PIN T34 [get_ports {c1_calib_complete}]

# {ta1_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c1_diagnostic_led]
set_property DRIVE 8 [get_ports c1_diagnostic_led]
set_property PACKAGE_PIN F39 [get_ports {c1_diagnostic_led}]

# {ta2_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c2_calib_complete]
set_property DRIVE 8 [get_ports c2_calib_complete]
set_property PACKAGE_PIN A54 [get_ports {c2_calib_complete}]

# {ta2_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c2_diagnostic_led]
set_property DRIVE 8 [get_ports c2_diagnostic_led]
set_property PACKAGE_PIN E63 [get_ports {c2_diagnostic_led}]

# {tb0_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c3_calib_complete]
set_property DRIVE 8 [get_ports c3_calib_complete]
set_property PACKAGE_PIN BH15 [get_ports {c3_calib_complete}]

# {tb0_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c3_diagnostic_led]
set_property DRIVE 8 [get_ports c3_diagnostic_led]
set_property PACKAGE_PIN BY14 [get_ports {c3_diagnostic_led}]

# {tb1_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c4_calib_complete]
set_property DRIVE 8 [get_ports c4_calib_complete]
set_property PACKAGE_PIN BU51 [get_ports {c4_calib_complete}]

# {tb1_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c4_diagnostic_led]
set_property DRIVE 8 [get_ports c4_diagnostic_led]
set_property PACKAGE_PIN BH41 [get_ports {c4_diagnostic_led}]

# {tb2_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c5_calib_complete]
set_property DRIVE 8 [get_ports c5_calib_complete]
set_property PACKAGE_PIN AR44 [get_ports {c5_calib_complete}]

# {tb2_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c5_diagnostic_led]
set_property DRIVE 8 [get_ports c5_diagnostic_led]
set_property PACKAGE_PIN AY55 [get_ports {c5_diagnostic_led}]

# {ba2_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c6_calib_complete]
set_property DRIVE 8 [get_ports c6_calib_complete]
set_property PACKAGE_PIN AA45 [get_ports {c6_calib_complete}]

# {ba2_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c6_diagnostic_led]
set_property DRIVE 8 [get_ports c6_diagnostic_led]
set_property PACKAGE_PIN W58 [get_ports {c6_diagnostic_led}]

## {ba0_eb1_LED_GREEN1}
#set_property IOSTANDARD LVCMOS12 [get_ports c7_calib_complete]
#set_property DRIVE 8 [get_ports c7_calib_complete]
#set_property PACKAGE_PIN E22 [get_ports {c7_calib_complete}]
#
## {ba0_eb1_LED_YELLOW2}
#set_property IOSTANDARD LVCMOS12 [get_ports c7_diagnostic_led]
#set_property DRIVE 8 [get_ports c7_diagnostic_led]
#set_property PACKAGE_PIN K44 [get_ports {c7_diagnostic_led}]

#-----------------------------------------------------------
#              Reset                                       -
#-----------------------------------------------------------

# {ta1_eb1_BUTTON3}
set_property IOSTANDARD LVCMOS12 [get_ports reset]
set_property DRIVE 8 [get_ports reset]
set_property PACKAGE_PIN K28 [get_ports reset]


#-----------------------------------------------------------
#              Clock                                       -
#-----------------------------------------------------------

# {CLK1_N}
set_property IOSTANDARD LVDS [get_ports {esp_clk_n}]
set_property PACKAGE_PIN CA40 [get_ports {esp_clk_n}]

# {CLK1_P}
set_property IOSTANDARD LVDS [get_ports {esp_clk_p}]
set_property PACKAGE_PIN CA39 [get_ports {esp_clk_p}]


#-----------------------------------------------------------
#              Timing constraints                          -
#-----------------------------------------------------------

create_clock -period 11.2 [get_ports c0_sys_clk_p]
create_clock -period 11.2 [get_ports c1_sys_clk_p]
create_clock -period 11.2 [get_ports c2_sys_clk_p]
create_clock -period 11.2 [get_ports c3_sys_clk_p]
create_clock -period 11.2 [get_ports c4_sys_clk_p]
create_clock -period 11.2 [get_ports c5_sys_clk_p]
create_clock -period 11.2 [get_ports c6_sys_clk_p]

create_clock -period 10.0 [get_ports esp_clk_p]

# Recover elaborated clock name
set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set clkm1_elab [get_clocks -of_objects [get_nets clkm_1]]
set clkm2_elab [get_clocks -of_objects [get_nets clkm_2]]
set clkm3_elab [get_clocks -of_objects [get_nets clkm_3]]
set clkm4_elab [get_clocks -of_objects [get_nets clkm_4]]
set clkm5_elab [get_clocks -of_objects [get_nets clkm_5]]
set clkm6_elab [get_clocks -of_objects [get_nets clkm_6]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

# Both memory controllers impose their user clock. Make them asynchronous
set_clock_groups -asynchronous \
    -group [get_clocks $refclk_elab] \
    -group [get_clocks $clkm_elab]   \
    -group [get_clocks $clkm1_elab]  \
    -group [get_clocks $clkm2_elab]  \
    -group [get_clocks $clkm3_elab]  \
    -group [get_clocks $clkm4_elab]  \
    -group [get_clocks $clkm5_elab]  \
    -group [get_clocks $clkm6_elab]
#    -group [get_clocks $clkm7_elab]
#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]

