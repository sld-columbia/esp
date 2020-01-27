
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

# {ba2_eb1_USB2UART_PVIO_A3_NCTS}
set_property PACKAGE_PIN BK45 [get_ports uart_rtsn]

# {ba2_eb1_USB2UART_PVIO_A2_NRTS}
set_property PACKAGE_PIN BG44 [get_ports uart_ctsn]

# {ba2_eb1_USB2UART_PVIO_A1_RXD}
set_property PACKAGE_PIN BG45 [get_ports uart_txd]

# {ba2_eb1_USB2UART_PVIO_A0_TXD}
set_property PACKAGE_PIN BF43 [get_ports uart_rxd]

set_property IOSTANDARD LVCMOS18 [get_ports {uart_*}]

#-----------------------------------------------------------
#              LEDs                                        -
#-----------------------------------------------------------

# {LED_RED}
set_property PACKAGE_PIN W43 [get_ports LED_RED]

# {LED_GREEN}
set_property PACKAGE_PIN Y43 [get_ports LED_GREEN]

# {LED_BLUE}
set_property PACKAGE_PIN Y42 [get_ports LED_BLUE]

# {LED_YELLOW}
set_property PACKAGE_PIN Y41 [get_ports LED_YELLOW]

set_property IOSTANDARD LVCMOS18 [get_ports {LED_*}]

#-----------------------------------------------------------
#              Diagnostic LEDs                             -
#-----------------------------------------------------------

# {ta1_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c0_calib_complete]
set_property DRIVE 8 [get_ports c0_calib_complete]
set_property PACKAGE_PIN AP41 [get_ports c0_calib_complete]

# {ta1_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c0_diagnostic_led]
set_property DRIVE 8 [get_ports c0_diagnostic_led]
set_property PACKAGE_PIN AW41 [get_ports c0_diagnostic_led]


#-----------------------------------------------------------
#              Reset                                       -
#-----------------------------------------------------------

# {ta1_eb1_BUTTON3}
set_property IOSTANDARD LVCMOS12 [get_ports reset]
set_property DRIVE 8 [get_ports reset]
set_property PACKAGE_PIN AM41 [get_ports reset]


#-----------------------------------------------------------
#              Clock                                       -
#-----------------------------------------------------------

# {CLK1_N}
set_property IOSTANDARD LVDS [get_ports {esp_clk_n}]
set_property PACKAGE_PIN BC28 [get_ports {esp_clk_n}]

# {CLK1_P}
set_property IOSTANDARD LVDS [get_ports {esp_clk_p}]
set_property PACKAGE_PIN BC27 [get_ports {esp_clk_p}]


#-----------------------------------------------------------
#              Timing constraints                          -
#-----------------------------------------------------------

create_clock -period 11.2 [get_ports c0_sys_clk_p]

create_clock -period 12.8 [get_ports esp_clk_p]

# Recover elaborated clock name
set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

# Both memory controllers impose their user clock. Make them asynchronous
set_clock_groups -asynchronous -group [get_clocks $clkm_elab] -group [get_clocks $refclk_elab]

#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]

