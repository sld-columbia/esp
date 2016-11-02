
#-----------------------------------------------------------
#              Bitstream Configuration                     -
#-----------------------------------------------------------

set_property BITSTREAM.CONFIG.UNUSEDPIN Pullnone [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

#-----------------------------------------------------------
#              Clocks                                      -
#-----------------------------------------------------------

set_property IOSTANDARD LVDS [get_ports clkp_0]
set_property PACKAGE_PIN AD41 [get_ports clkp_0]

set_property IOSTANDARD LVDS [get_ports clkn_0]
set_property PACKAGE_PIN AE41 [get_ports clkn_0]

set_property IOSTANDARD LVDS [get_ports clkp_1]
set_property PACKAGE_PIN AC41 [get_ports clkp_1]

set_property IOSTANDARD LVDS [get_ports clkn_1]
set_property PACKAGE_PIN AB41 [get_ports clkn_1]

set_property VCCAUX_IO DONTCARE [get_ports {clk_ref_p}]
set_property IOSTANDARD LVDS [get_ports {clk_ref_p}]
set_property PACKAGE_PIN AA38 [get_ports {clk_ref_p}]

set_property VCCAUX_IO DONTCARE [get_ports {clk_ref_n}]
set_property IOSTANDARD LVDS [get_ports {clk_ref_n}]
set_property PACKAGE_PIN AA39 [get_ports {clk_ref_n}]


#-----------------------------------------------------------
#              Timing constraints                          -
#-----------------------------------------------------------

# --- Define and constrain system clock
create_clock -period 6.250 [get_ports clkp_0]

create_clock -period 6.250 [get_ports clkp_1]

create_clock -period 5 [get_ports clk_ref_p]

# Note: the following CLOCK_DEDICATED_ROUTE constraint will cause a warning in place similar
# to the following:
#   WARNING:Place:1402 - A clock IOB / PLL clock component pair have been found that are not
#   placed at an optimal clock IOB / PLL site pair.
# This warning can be ignored.  See the Users Guide for more information.

set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets clkp_0]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets clkp_1]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_pins -hierarchical *pll*CLKIN1]

#-----------------------------------------------------------
#      Common constraints for all memory controllers       -
#-----------------------------------------------------------

set_false_path -through [get_pins -filter {NAME =~ */DQSFOUND} -of [get_cells -hier -filter {REF_NAME == PHASER_IN_PHY}]]

set_multicycle_path -through [get_pins -filter {NAME =~ */OSERDESRST} -of [get_cells -hier -filter {REF_NAME == PHASER_OUT_PHY}]] -setup 2 -start
set_multicycle_path -through [get_pins -filter {NAME =~ */OSERDESRST} -of [get_cells -hier -filter {REF_NAME == PHASER_OUT_PHY}]] -hold 1 -start

set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/* && IS_SEQUENTIAL}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/device_temp_sync_r1*}] 20
set_max_delay -from [get_cells -hier *rstdiv0_sync_r1_reg*] -to [get_pins -filter {NAME =~ */RESET} -of [get_cells -hier -filter {REF_NAME == PHY_CONTROL}]] -datapath_only 5

set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1_reg*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/xadc_supplied_temperature.rst_r1*}] 20

# Both memory controllers impose their user clock. Make them asynchronous
set_clock_groups -asynchronous -group [get_clocks clk_pll_i] -group [get_clocks clk_pll_i_1]


#-----------------------------------------------------------
#              UART                                         -
#-----------------------------------------------------------

# UART - usign daughter card UART2USB
# (eb_tb2b2_1_UART_CTSN_FPGA2HOST)
set_property PACKAGE_PIN M5 [get_ports dsurtsn]
set_property IOSTANDARD LVCMOS18 [get_ports dsurtsn]
# (eb_tb2b2_1_UART_RTSN_HOST2FPGA)
set_property PACKAGE_PIN M4 [get_ports dsuctsn]
set_property IOSTANDARD LVCMOS18 [get_ports dsuctsn]
# (eb_tb2b2_1_UART_RXD_FPGA2HOST)
set_property PACKAGE_PIN D3 [get_ports dsutx]
set_property IOSTANDARD LVCMOS18 [get_ports dsutx]
# (eb_tb2b2_1_UART_TXD_HOST2FPGA)
set_property PACKAGE_PIN C3 [get_ports dsurx]
set_property IOSTANDARD LVCMOS18 [get_ports dsurx]

#-----------------------------------------------------------
#              LEDs                                         -
#-----------------------------------------------------------

#Motherboard LEDs
set_property PACKAGE_PIN AD31 [get_ports LED_RED]
set_property PACKAGE_PIN AD30 [get_ports LED_GREEN]
set_property PACKAGE_PIN AC29 [get_ports LED_BLUE]
set_property PACKAGE_PIN AD29 [get_ports LED_YELLOW]

set_property IOSTANDARD LVCMOS18 [get_ports LED_YELLOW]
set_property IOSTANDARD LVCMOS18 [get_ports LED_BLUE]
set_property IOSTANDARD LVCMOS18 [get_ports LED_GREEN]
set_property IOSTANDARD LVCMOS18 [get_ports LED_RED]

#-----------------------------------------------------------
#              False Paths
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]


