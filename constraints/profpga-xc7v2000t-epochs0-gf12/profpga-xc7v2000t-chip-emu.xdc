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

# {CLK_P_7}
set_property IOSTANDARD LVDS [get_ports {clk_emu_p}]
set_property PACKAGE_PIN AB40 [get_ports {clk_emu_p}]

# {CLK_N_7}
set_property IOSTANDARD LVDS [get_ports {clk_emu_n}]
set_property PACKAGE_PIN AA40 [get_ports {clk_emu_n}]


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
#              Timing constraints                          -
#-----------------------------------------------------------

create_clock -period 20.0 [get_ports clk_emu_p]

#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]

