# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#              Bitstream Configuration                     -
#-----------------------------------------------------------

set_property BITSTREAM.CONFIG.UNUSEDPIN Pullnone [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

#-----------------------------------------------------------
#              Clock Pins                                  -
#-----------------------------------------------------------

#TODO

# # {CLK_P_1}
# set_property IOSTANDARD LVDS [get_ports c0_main_clk_p]
# set_property PACKAGE_PIN AD41 [get_ports c0_main_clk_p]

# # {CLK_N_1}
# set_property IOSTANDARD LVDS [get_ports c0_main_clk_n]
# set_property PACKAGE_PIN AE41 [get_ports c0_main_clk_n]

# {CLK_P_4}
set_property IOSTANDARD LVDS [get_ports c0_main_clk_p]
set_property PACKAGE_PIN AF39 [get_ports c0_main_clk_p]

# {CLK_N_4}
set_property IOSTANDARD LVDS [get_ports c0_main_clk_n]
set_property PACKAGE_PIN AG40 [get_ports c0_main_clk_n]


# {CLK_P_3}
set_property IOSTANDARD LVDS [get_ports c1_main_clk_p]
set_property PACKAGE_PIN AC41 [get_ports c1_main_clk_p]

# {CLK_N_3}
set_property IOSTANDARD LVDS [get_ports c1_main_clk_n]
set_property PACKAGE_PIN AB41 [get_ports c1_main_clk_n]

# {CLK_P_2}
set_property VCCAUX_IO DONTCARE [get_ports {clk_ref_p}]
set_property IOSTANDARD LVDS [get_ports {clk_ref_p}]
set_property PACKAGE_PIN AA38 [get_ports {clk_ref_p}]

# {CLK_N_2}
set_property VCCAUX_IO DONTCARE [get_ports {clk_ref_n}]
set_property IOSTANDARD LVDS [get_ports {clk_ref_n}]
set_property PACKAGE_PIN AA39 [get_ports {clk_ref_n}]


#-----------------------------------------------------------
#              UART                                        -
#-----------------------------------------------------------
#bd1_eb1_UART1_CTSN
set_property  PACKAGE_PIN G20 [get_ports {uart_rtsn}]

#bd1_eb1_UART1_RTSN
set_property  PACKAGE_PIN F18 [get_ports {uart_ctsn}]

#bd1_eb1_UART1_RXD
set_property  PACKAGE_PIN E18 [get_ports {uart_txd}]

#bd1_eb1_UART1_TXD
set_property  PACKAGE_PIN K20 [get_ports {uart_rxd}]

set_property IOSTANDARD LVCMOS18 [get_ports {uart_*}]

#-----------------------------------------------------------
#              LEDs                                        -
#-----------------------------------------------------------

# {LED_RED}
set_property PACKAGE_PIN AD31 [get_ports LED_RED]

# {LED_GREEN}
set_property PACKAGE_PIN AD30 [get_ports LED_GREEN]

# {LED_BLUE}
set_property PACKAGE_PIN AC29 [get_ports LED_BLUE]

# {LED_YELLOW}
set_property PACKAGE_PIN AD29 [get_ports LED_YELLOW]

set_property IOSTANDARD LVCMOS18 [get_ports {LED_*}]

#-----------------------------------------------------------
#              Reset                                       -
#-----------------------------------------------------------

#mb1_TD1_IO_037_P_18_mb1_TB3_IO_035_P_17}]
set_property IOSTANDARD LVCMOS15 [get_ports chip_reset]
set_property  PACKAGE_PIN U2 [get_ports {chip_reset}]


#-----------------------------------------------------------
#              Timing constraints                          -
#-----------------------------------------------------------

#TODO

create_clock -period 5.0 [get_ports c0_main_clk_p]

create_clock -period 5.0 [get_ports c1_main_clk_p]

create_clock -period 5 [get_ports clk_ref_p]

# Note: the following CLOCK_DEDICATED_ROUTE constraint will cause a warning in place similar
# to the following:
#   WARNING:Place:1402 - A clock IOB / PLL clock component pair have been found that are not
#   placed at an optimal clock IOB / PLL site pair.
# This warning can be ignored.  See the Users Guide for more information.

set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets c0_main_clk_p]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets c1_main_clk_p]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_pins -hierarchical *pll*CLKIN1]

# Recover elaborated clock name
set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set clkm2_elab [get_clocks -of_objects [get_nets clkm_2]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

# Both memory controllers impose their user clock. Make them asynchronous
set_clock_groups -asynchronous -group [get_clocks $clkm_elab] -group [get_clocks $clkm2_elab]
set_clock_groups -asynchronous -group [get_clocks $clkm_elab] -group [get_clocks $refclk_elab]
set_clock_groups -asynchronous -group [get_clocks $clkm2_elab] -group [get_clocks $refclk_elab]

set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks $clkm_elab]
set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks $clkm2_elab]
set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks $refclk_elab]

#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports chip_reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]

