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
#              Timing constraints                          -
#-----------------------------------------------------------

create_clock -period 20.0 [get_ports clk_emu_p]
create_clock -period 10.0 [get_ports fpga_clk_in[0]]
create_clock -period 10.0 [get_ports fpga_clk_in[1]]
create_clock -period 10.0 [get_ports fpga_clk_in[2]]
create_clock -period 10.0 [get_ports fpga_clk_in[3]]

set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[0]] -group [get_clocks clk_emu_p]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[1]] -group [get_clocks clk_emu_p]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[2]] -group [get_clocks clk_emu_p]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[3]] -group [get_clocks clk_emu_p]

set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[0]] -group [get_clocks fpga_clk_in[1]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[0]] -group [get_clocks fpga_clk_in[2]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[0]] -group [get_clocks fpga_clk_in[3]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[1]] -group [get_clocks fpga_clk_in[2]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[1]] -group [get_clocks fpga_clk_in[3]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_in[2]] -group [get_clocks fpga_clk_in[3]]

#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports reset]

