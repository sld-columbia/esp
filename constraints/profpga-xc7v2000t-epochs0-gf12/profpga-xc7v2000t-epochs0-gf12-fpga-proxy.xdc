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
set_property IOSTANDARD LVDS [get_ports c0_sys_clk_p]
set_property PACKAGE_PIN AC41 [get_ports c0_sys_clk_p]

# {CLK_N_3}
set_property IOSTANDARD LVDS [get_ports c0_sys_clk_n]
set_property PACKAGE_PIN AB41 [get_ports c0_sys_clk_n]

# {CLK_P_4}
set_property IOSTANDARD LVDS [get_ports c1_sys_clk_p]
set_property PACKAGE_PIN AF39 [get_ports c1_sys_clk_p]

# {CLK_N_4}
set_property IOSTANDARD LVDS [get_ports c1_sys_clk_n]
set_property PACKAGE_PIN AG40 [get_ports c1_sys_clk_n]

# {CLK_P_5}
set_property IOSTANDARD LVDS [get_ports c2_sys_clk_p]
set_property PACKAGE_PIN AE42 [get_ports c2_sys_clk_p]

# {CLK_N_5}
set_property IOSTANDARD LVDS [get_ports c2_sys_clk_n]
set_property PACKAGE_PIN AF42 [get_ports c2_sys_clk_n]

# {CLK_P_6}
set_property IOSTANDARD LVDS [get_ports c3_sys_clk_p]
set_property PACKAGE_PIN AC39 [get_ports c3_sys_clk_p]

# {CLK_N_6}
set_property IOSTANDARD LVDS [get_ports c3_sys_clk_n]
set_property PACKAGE_PIN AB39 [get_ports c3_sys_clk_n]

# {CLK_P_2}
set_property VCCAUX_IO DONTCARE [get_ports {main_clk_p}]
set_property IOSTANDARD LVDS [get_ports {main_clk_p}]
set_property PACKAGE_PIN AA38 [get_ports {main_clk_p}]

# {CLK_N_2}
set_property VCCAUX_IO DONTCARE [get_ports {main_clk_n}]
set_property IOSTANDARD LVDS [get_ports {main_clk_n}]
set_property PACKAGE_PIN AA39 [get_ports {main_clk_n}]

# {CLK_P_7}
set_property VCCAUX_IO DONTCARE [get_ports jtag_clk_p]
set_property IOSTANDARD LVDS [get_ports jtag_clk_p]
set_property PACKAGE_PIN AB40 [get_ports jtag_clk_p]

# {CLK_N_7}
set_property VCCAUX_IO DONTCARE [get_ports jtag_clk_n]
set_property IOSTANDARD LVDS [get_ports jtag_clk_n]
set_property PACKAGE_PIN AA40 [get_ports jtag_clk_n]

# {CLK_P_1}
set_property VCCAUX_IO DONTCARE [get_ports {clk_ref_p}]
set_property IOSTANDARD LVDS [get_ports {clk_ref_p}]
set_property PACKAGE_PIN AD41 [get_ports {clk_ref_p}]

# {CLK_N_1}
set_property VCCAUX_IO DONTCARE [get_ports {clk_ref_n}]
set_property IOSTANDARD LVDS [get_ports {clk_ref_n}]
set_property PACKAGE_PIN AE41 [get_ports {clk_ref_n}]

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
#              Diagnostic LEDs                             -
#-----------------------------------------------------------

# {bc2_eb1_LED01}
set_property IOSTANDARD LVCMOS15 [get_ports c0_calib_complete]
set_property PACKAGE_PIN AT37 [get_ports c0_calib_complete]

# {bc2_eb1_LED02}
set_property IOSTANDARD LVCMOS15 [get_ports c0_diagnostic_led]
set_property PACKAGE_PIN AV34 [get_ports c0_diagnostic_led]

# {bc1_eb1_LED01}
set_property IOSTANDARD LVCMOS15 [get_ports c1_calib_complete]
set_property PACKAGE_PIN M27 [get_ports c1_calib_complete]

# {bc1_eb1_LED02}
set_property IOSTANDARD LVCMOS15 [get_ports c1_diagnostic_led]
set_property PACKAGE_PIN K27 [get_ports c1_diagnostic_led]

# {bd1_eb1_LED01}
set_property IOSTANDARD LVCMOS15 [get_ports c2_calib_complete]
set_property PACKAGE_PIN R16 [get_ports c2_calib_complete]

# {bd1_eb1_LED02}
set_property IOSTANDARD LVCMOS15 [get_ports c2_diagnostic_led]
set_property PACKAGE_PIN M14 [get_ports c2_diagnostic_led]

# {td2_eb1_LED01}
set_property IOSTANDARD LVCMOS15 [get_ports c3_calib_complete]
set_property PACKAGE_PIN AM17 [get_ports c3_calib_complete]

# {td2_eb1_LED02}
set_property IOSTANDARD LVCMOS15 [get_ports c3_diagnostic_led]
set_property PACKAGE_PIN AJ15 [get_ports c3_diagnostic_led]

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

create_clock -period 10.0 [get_ports main_clk_p]
create_clock -period 40.000 [get_ports jtag_clk_p]
create_clock -period 10.0 [get_ports fpga_clk_out[0]]
create_clock -period 10.0 [get_ports fpga_clk_out[1]]
create_clock -period 10.0 [get_ports fpga_clk_out[2]]
create_clock -period 10.0 [get_ports fpga_clk_out[3]]

# create_clock -period 5 [get_ports clk_ref_p]

# Note: the following CLOCK_DEDICATED_ROUTE constraint will cause a warning in place similar
# to the following:
#   WARNING:Place:1402 - A clock IOB / PLL clock component pair have been found that are not
#   placed at an optimal clock IOB / PLL site pair.
# This warning can be ignored.  See the Users Guide for more information.

set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets c0_sys_clk_p]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets c1_sys_clk_p]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets c2_sys_clk_p]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets c3_sys_clk_p]

# Recover elaborated clock name
set main_clk_elab [get_clocks -of_objects [get_nets main_clk]]

set sys_clk_elab0 [get_clocks -of_objects [get_nets sys_clk[0]]]
set sys_clk_elab1 [get_clocks -of_objects [get_nets sys_clk[1]]]
set sys_clk_elab2 [get_clocks -of_objects [get_nets sys_clk[2]]]
set sys_clk_elab3 [get_clocks -of_objects [get_nets sys_clk[3]]]

# Both memory controllers impose their user clock. Make them asynchronous
set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks $main_clk_elab]
set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks $sys_clk_elab0]
set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab0] -group [get_clocks $main_clk_elab]
set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks $sys_clk_elab1]
set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab1] -group [get_clocks $main_clk_elab]
set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks $sys_clk_elab2]
set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab2] -group [get_clocks $main_clk_elab]
set_clock_groups -asynchronous -group [get_clocks clk_ref_p] -group [get_clocks $sys_clk_elab3]
set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab3] -group [get_clocks $main_clk_elab]

set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab0] -group [get_clocks $sys_clk_elab1]
set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab0] -group [get_clocks $sys_clk_elab2]
set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab0] -group [get_clocks $sys_clk_elab3]
set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab1] -group [get_clocks $sys_clk_elab2]
set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab1] -group [get_clocks $sys_clk_elab3]
set_clock_groups -asynchronous -group [get_clocks $sys_clk_elab2] -group [get_clocks $sys_clk_elab3]

set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[0]] -group [get_clocks main_clk_p]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[1]] -group [get_clocks main_clk_p]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[2]] -group [get_clocks main_clk_p]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[3]] -group [get_clocks main_clk_p]

set_clock_groups -asynchronous -group [get_clocks main_clk_p] -group [get_clocks jtag_clk_p]
set_clock_groups -asynchronous -group [get_clocks {fpga_clk_out[0]}] -group [get_clocks jtag_clk_p]
set_clock_groups -asynchronous -group [get_clocks {fpga_clk_out[1]}] -group [get_clocks jtag_clk_p]
set_clock_groups -asynchronous -group [get_clocks {fpga_clk_out[2]}] -group [get_clocks jtag_clk_p]
set_clock_groups -asynchronous -group [get_clocks {fpga_clk_out[3]}] -group [get_clocks jtag_clk_p]

set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[0]] -group [get_clocks fpga_clk_out[1]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[0]] -group [get_clocks fpga_clk_out[2]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[0]] -group [get_clocks fpga_clk_out[3]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[1]] -group [get_clocks fpga_clk_out[2]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[1]] -group [get_clocks fpga_clk_out[3]]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[2]] -group [get_clocks fpga_clk_out[3]]

set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[0]] -group [get_clocks $sys_clk_elab0]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[0]] -group [get_clocks $sys_clk_elab1]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[0]] -group [get_clocks $sys_clk_elab2]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[0]] -group [get_clocks $sys_clk_elab3]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[1]] -group [get_clocks $sys_clk_elab0]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[1]] -group [get_clocks $sys_clk_elab1]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[1]] -group [get_clocks $sys_clk_elab2]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[1]] -group [get_clocks $sys_clk_elab3]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[2]] -group [get_clocks $sys_clk_elab0]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[2]] -group [get_clocks $sys_clk_elab1]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[2]] -group [get_clocks $sys_clk_elab2]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[2]] -group [get_clocks $sys_clk_elab3]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[3]] -group [get_clocks $sys_clk_elab0]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[3]] -group [get_clocks $sys_clk_elab1]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[3]] -group [get_clocks $sys_clk_elab2]
set_clock_groups -asynchronous -group [get_clocks fpga_clk_out[3]] -group [get_clocks $sys_clk_elab3]

#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]
