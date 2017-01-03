
#-----------------------------------------------------------
#              Bitstream Configuration                     -
#-----------------------------------------------------------

set_property BITSTREAM.CONFIG.UNUSEDPIN Pullnone [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

#-----------------------------------------------------------
#              UART                                         -
#-----------------------------------------------------------

# FPGA module UART
set_property PACKAGE_PIN AR42 [get_ports uart_cts_b]
set_property PACKAGE_PIN AT40 [get_ports uart_rts_b]
set_property PACKAGE_PIN AT39 [get_ports uart_rxd]
set_property PACKAGE_PIN AT42 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS18 [get_ports uart_*]

#-----------------------------------------------------------
#              LEDs                                         -
#-----------------------------------------------------------

# FPGA module LEDs
set_property PACKAGE_PIN BB41 [get_ports LED_BLUE]
set_property PACKAGE_PIN AW41 [get_ports LED_GREEN]
set_property PACKAGE_PIN AW42 [get_ports LED_RED]
set_property PACKAGE_PIN BA41 [get_ports LED_YELLOW]
set_property IOSTANDARD LVCMOS18 [get_ports LED_*]

#-----------------------------------------------------------
#              False Paths
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]



