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

# {CLK_P_3}
set_property IOSTANDARD LVDS [get_ports sys_clk_p]

# {CLK_N_3}
set_property IOSTANDARD LVDS [get_ports sys_clk_n]
set_property PACKAGE_PIN AC41 [get_ports sys_clk_p]
set_property PACKAGE_PIN AB41 [get_ports sys_clk_n]

# {CLK_P_2}
set_property VCCAUX_IO DONTCARE [get_ports main_clk_p]
set_property IOSTANDARD LVDS [get_ports main_clk_p]

# {CLK_N_2}
set_property IOSTANDARD LVDS [get_ports main_clk_n]
set_property PACKAGE_PIN AA38 [get_ports main_clk_p]
set_property PACKAGE_PIN AA39 [get_ports main_clk_n]

# {CLK_P_7}
set_property VCCAUX_IO DONTCARE [get_ports jtag_clk_p]
set_property IOSTANDARD LVDS [get_ports jtag_clk_p]

# {CLK_N_7}
set_property IOSTANDARD LVDS [get_ports jtag_clk_n]
set_property PACKAGE_PIN AB40 [get_ports jtag_clk_p]
set_property PACKAGE_PIN AA40 [get_ports jtag_clk_n]

# {CLK_P_1}
set_property IOSTANDARD LVDS [get_ports clk_ref_p]

# {CLK_N_1}
set_property IOSTANDARD LVDS [get_ports clk_ref_n]
set_property PACKAGE_PIN AD41 [get_ports clk_ref_p]
set_property PACKAGE_PIN AE41 [get_ports clk_ref_n]

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

set_property IOSTANDARD LVCMOS18 [get_ports LED_*]

#-----------------------------------------------------------
#              Diagnostic LEDs                             -
#-----------------------------------------------------------

# {bc2_eb1_LED01}
set_property IOSTANDARD LVCMOS15 [get_ports calib_complete]
set_property PACKAGE_PIN AT37 [get_ports calib_complete]

# {bc2_eb1_LED02}
set_property IOSTANDARD LVCMOS15 [get_ports diagnostic_led]
set_property PACKAGE_PIN AV34 [get_ports diagnostic_led]

#-----------------------------------------------------------
#              Reset                                       -
#-----------------------------------------------------------

# {td2_eb1_SW1}
set_property IOSTANDARD LVCMOS15 [get_ports reset]
set_property PACKAGE_PIN AR15 [get_ports reset]


#-----------------------------------------------------------
#              Timing constraints                          -
#-----------------------------------------------------------

# create_clock -period 5.0 [get_ports c0_sys_clk_p]
# create_clock -period 5.0 [get_ports c1_sys_clk_p]
# create_clock -period 5.0 [get_ports c2_sys_clk_p]
# create_clock -period 5.0 [get_ports c3_sys_clk_p]

create_clock -period 10.000 [get_ports main_clk_p]
create_clock -period 40.000 [get_ports jtag_clk_p]
create_clock -period 10.000 [get_ports {fpga_clk_out[0]}]
create_clock -period 10.000 [get_ports iolink_clk_in]

# create_clock -period 5 [get_ports clk_ref_p]

# Note: the following CLOCK_DEDICATED_ROUTE constraint will cause a warning in place similar
# to the following:
#   WARNING:Place:1402 - A clock IOB / PLL clock component pair have been found that are not
#   placed at an optimal clock IOB / PLL site pair.
# This warning can be ignored.  See the Users Guide for more information.

set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets sys_clk_p]

# Recover elaborated clock name


# Both memory controllers impose their user clock. Make them asynchronous
set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks [get_clocks -of_objects [get_nets main_clk]]]
set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks [get_clocks -of_objects [get_nets {sys_clk[0]}]]]
set_clock_groups -asynchronous -group [get_clocks [get_clocks -of_objects [get_nets {sys_clk[0]}]]] -group [get_clocks [get_clocks -of_objects [get_nets main_clk]]]

set_clock_groups -asynchronous -group [get_clocks {fpga_clk_out[0]}] -group [get_clocks main_clk_p]
set_clock_groups -asynchronous -group [get_clocks iolink_clk_in] -group [get_clocks main_clk_p]

set_clock_groups -asynchronous -group [get_clocks main_clk_p] -group [get_clocks jtag_clk_p]
set_clock_groups -asynchronous -group [get_clocks {fpga_clk_out[0]}] -group [get_clocks jtag_clk_p]
set_clock_groups -asynchronous -group [get_clocks iolink_clk_in] -group [get_clocks jtag_clk_p]

set_clock_groups -asynchronous -group [get_clocks {fpga_clk_out[0]}] -group [get_clocks [get_clocks -of_objects [get_nets {sys_clk[0]}]]]

set_clock_groups -asynchronous -group [get_clocks iolink_clk_in] -group [get_clocks [get_clocks -of_objects [get_nets {sys_clk[0]}]]]

set_clock_groups -asynchronous -group [get_clocks {fpga_clk_out[0]}] -group [get_clocks iolink_clk_in]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {fpga_io_gen[0].fpga_clk_out_pad/xcv2.u0/fpga_clk_out}]

#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]


