# Pin and IO property

# PadFunction: eb_ta3_1_CLK_200MHZ
set_property IOSTANDARD LVDS [get_ports c0_sys_clk_p]

# PadFunction: eb_ta3_1_CLK_200MHZn
set_property IOSTANDARD LVDS [get_ports c0_sys_clk_n]
set_property PACKAGE_PIN U36 [get_ports c0_sys_clk_p]
set_property PACKAGE_PIN T37 [get_ports c0_sys_clk_n]

# PadFunction: eb_tb3_1_CLK_200MHZ
set_property IOSTANDARD LVDS [get_ports c1_sys_clk_p]

# PadFunction: eb_tb3_1_CLK_200MHZn
set_property IOSTANDARD LVDS [get_ports c1_sys_clk_n]
set_property PACKAGE_PIN G18 [get_ports c1_sys_clk_n]
set_property PACKAGE_PIN H19 [get_ports c1_sys_clk_p]

# PadFunction: CLK_P_1
set_property IOSTANDARD LVDS [get_ports clk_ref_p]

# PadFunction: CLK_N_1
set_property IOSTANDARD LVDS [get_ports clk_ref_n]
set_property PACKAGE_PIN AJ32 [get_ports clk_ref_p]
set_property PACKAGE_PIN AK32 [get_ports clk_ref_n]


#-----------------------------------------------------------
#              Diagnostic LEDs                             -
#-----------------------------------------------------------

# PadFunction: eb_ta3_1_LED02
set_property IOSTANDARD LVCMOS15 [get_ports rst_led]
set_property PACKAGE_PIN T41 [get_ports rst_led]
# PadFunction: eb_ta3_1_LED03
set_property IOSTANDARD LVCMOS15 [get_ports rstraw_led]
set_property PACKAGE_PIN T40 [get_ports rstraw_led]
# PadFunction: eb_ta3_1_LED04
set_property IOSTANDARD LVCMOS15 [get_ports rstn_led]
set_property PACKAGE_PIN T42 [get_ports rstn_led]
# PadFunction: eb_ta3_1_LED05
set_property IOSTANDARD LVCMOS15 [get_ports migrstn_led]
set_property PACKAGE_PIN U41 [get_ports migrstn_led]
# PadFunction: eb_ta3_1_LED06
set_property IOSTANDARD LVCMOS15 [get_ports diagnostic_led]
set_property PACKAGE_PIN V38 [get_ports diagnostic_led]

#-----------------------------------------------------------
#              Reset                                       -
#-----------------------------------------------------------

# PadFunction: eb_ta3_1_SW1
set_property IOSTANDARD LVCMOS15 [get_ports reset]
set_property PACKAGE_PIN W33 [get_ports reset]

#-----------------------------------------------------------
#              MIG-TA1                                         -
#-----------------------------------------------------------

# PadFunction: eb_ta3_1_DQ00_D0
set_property SLEW FAST [get_ports {c0_ddr3_dq[0]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[0]}]
set_property PACKAGE_PIN AB42 [get_ports {c0_ddr3_dq[0]}]

# PadFunction: eb_ta3_1_DQ00_D1
set_property SLEW FAST [get_ports {c0_ddr3_dq[1]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[1]}]
set_property PACKAGE_PIN Y42 [get_ports {c0_ddr3_dq[1]}]

# PadFunction: eb_ta3_1_DQ00_D2
set_property SLEW FAST [get_ports {c0_ddr3_dq[2]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[2]}]
set_property PACKAGE_PIN AA42 [get_ports {c0_ddr3_dq[2]}]

# PadFunction: eb_ta3_1_DQ00_D3
set_property SLEW FAST [get_ports {c0_ddr3_dq[3]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[3]}]
set_property PACKAGE_PIN W40 [get_ports {c0_ddr3_dq[3]}]

# PadFunction: eb_ta3_1_DQ00_D4
set_property SLEW FAST [get_ports {c0_ddr3_dq[4]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[4]}]
set_property PACKAGE_PIN Y40 [get_ports {c0_ddr3_dq[4]}]

# PadFunction: eb_ta3_1_DQ00_D5
set_property SLEW FAST [get_ports {c0_ddr3_dq[5]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[5]}]
set_property PACKAGE_PIN AB38 [get_ports {c0_ddr3_dq[5]}]

# PadFunction: eb_ta3_1_DQ00_D6
set_property SLEW FAST [get_ports {c0_ddr3_dq[6]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[6]}]
set_property PACKAGE_PIN AB39 [get_ports {c0_ddr3_dq[6]}]

# PadFunction: eb_ta3_1_DQ00_D7
set_property SLEW FAST [get_ports {c0_ddr3_dq[7]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[7]}]
set_property PACKAGE_PIN AA40 [get_ports {c0_ddr3_dq[7]}]

# PadFunction: eb_ta3_1_DQ01_D0
set_property SLEW FAST [get_ports {c0_ddr3_dq[8]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[8]}]
set_property PACKAGE_PIN AC39 [get_ports {c0_ddr3_dq[8]}]

# PadFunction: eb_ta3_1_DQ01_D1
set_property SLEW FAST [get_ports {c0_ddr3_dq[9]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[9]}]
set_property PACKAGE_PIN AC40 [get_ports {c0_ddr3_dq[9]}]

# PadFunction: eb_ta3_1_DQ01_D2
set_property SLEW FAST [get_ports {c0_ddr3_dq[10]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[10]}]
set_property PACKAGE_PIN AC41 [get_ports {c0_ddr3_dq[10]}]

# PadFunction: eb_ta3_1_DQ01_D3
set_property SLEW FAST [get_ports {c0_ddr3_dq[11]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[11]}]
set_property PACKAGE_PIN AD42 [get_ports {c0_ddr3_dq[11]}]

# PadFunction: eb_ta3_1_DQ01_D4
set_property SLEW FAST [get_ports {c0_ddr3_dq[12]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[12]}]
set_property PACKAGE_PIN AE42 [get_ports {c0_ddr3_dq[12]}]

# PadFunction: eb_ta3_1_DQ01_D5
set_property SLEW FAST [get_ports {c0_ddr3_dq[13]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[13]}]
set_property PACKAGE_PIN AE39 [get_ports {c0_ddr3_dq[13]}]

# PadFunction: eb_ta3_1_DQ01_D6
set_property SLEW FAST [get_ports {c0_ddr3_dq[14]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[14]}]
set_property PACKAGE_PIN AE40 [get_ports {c0_ddr3_dq[14]}]

# PadFunction: eb_ta3_1_DQ01_D7
set_property SLEW FAST [get_ports {c0_ddr3_dq[15]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[15]}]
set_property PACKAGE_PIN AD40 [get_ports {c0_ddr3_dq[15]}]

# PadFunction: eb_ta3_1_DQ02_D0
set_property SLEW FAST [get_ports {c0_ddr3_dq[16]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[16]}]
set_property PACKAGE_PIN AF39 [get_ports {c0_ddr3_dq[16]}]

# PadFunction: eb_ta3_1_DQ02_D1
set_property SLEW FAST [get_ports {c0_ddr3_dq[17]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[17]}]
set_property PACKAGE_PIN AF40 [get_ports {c0_ddr3_dq[17]}]

# PadFunction: eb_ta3_1_DQ02_D2
set_property SLEW FAST [get_ports {c0_ddr3_dq[18]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[18]}]
set_property PACKAGE_PIN AF41 [get_ports {c0_ddr3_dq[18]}]

# PadFunction: eb_ta3_1_DQ02_D3
set_property SLEW FAST [get_ports {c0_ddr3_dq[19]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[19]}]
set_property PACKAGE_PIN AG41 [get_ports {c0_ddr3_dq[19]}]

# PadFunction: eb_ta3_1_DQ02_D4
set_property SLEW FAST [get_ports {c0_ddr3_dq[20]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[20]}]
set_property PACKAGE_PIN AG42 [get_ports {c0_ddr3_dq[20]}]

# PadFunction: eb_ta3_1_DQ02_D5
set_property SLEW FAST [get_ports {c0_ddr3_dq[21]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[21]}]
set_property PACKAGE_PIN AG38 [get_ports {c0_ddr3_dq[21]}]

# PadFunction: eb_ta3_1_DQ02_D6
set_property SLEW FAST [get_ports {c0_ddr3_dq[22]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[22]}]
set_property PACKAGE_PIN AH38 [get_ports {c0_ddr3_dq[22]}]

# PadFunction: eb_ta3_1_DQ02_D7
set_property SLEW FAST [get_ports {c0_ddr3_dq[23]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[23]}]
set_property PACKAGE_PIN AJ38 [get_ports {c0_ddr3_dq[23]}]

# PadFunction: eb_ta3_1_DQ03_D0
set_property SLEW FAST [get_ports {c0_ddr3_dq[24]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[24]}]
set_property PACKAGE_PIN AJ40 [get_ports {c0_ddr3_dq[24]}]

# PadFunction: eb_ta3_1_DQ03_D1
set_property SLEW FAST [get_ports {c0_ddr3_dq[25]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[25]}]
set_property PACKAGE_PIN AJ41 [get_ports {c0_ddr3_dq[25]}]

# PadFunction: eb_ta3_1_DQ03_D2
set_property SLEW FAST [get_ports {c0_ddr3_dq[26]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[26]}]
set_property PACKAGE_PIN AK39 [get_ports {c0_ddr3_dq[26]}]

# PadFunction: eb_ta3_1_DQ03_D3
set_property SLEW FAST [get_ports {c0_ddr3_dq[27]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[27]}]
set_property PACKAGE_PIN AL39 [get_ports {c0_ddr3_dq[27]}]

# PadFunction: eb_ta3_1_DQ03_D4
set_property SLEW FAST [get_ports {c0_ddr3_dq[28]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[28]}]
set_property PACKAGE_PIN AH40 [get_ports {c0_ddr3_dq[28]}]

# PadFunction: eb_ta3_1_DQ03_D5
set_property SLEW FAST [get_ports {c0_ddr3_dq[29]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[29]}]
set_property PACKAGE_PIN AH41 [get_ports {c0_ddr3_dq[29]}]

# PadFunction: eb_ta3_1_DQ03_D6
set_property SLEW FAST [get_ports {c0_ddr3_dq[30]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[30]}]
set_property PACKAGE_PIN AJ42 [get_ports {c0_ddr3_dq[30]}]

# PadFunction: eb_ta3_1_DQ03_D7
set_property SLEW FAST [get_ports {c0_ddr3_dq[31]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[31]}]
set_property PACKAGE_PIN AK42 [get_ports {c0_ddr3_dq[31]}]

# PadFunction: eb_ta3_1_DQ04_D0
set_property SLEW FAST [get_ports {c0_ddr3_dq[32]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[32]}]
set_property PACKAGE_PIN B42 [get_ports {c0_ddr3_dq[32]}]

# PadFunction: eb_ta3_1_DQ04_D1
set_property SLEW FAST [get_ports {c0_ddr3_dq[33]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[33]}]
set_property PACKAGE_PIN A40 [get_ports {c0_ddr3_dq[33]}]

# PadFunction: eb_ta3_1_DQ04_D2
set_property SLEW FAST [get_ports {c0_ddr3_dq[34]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[34]}]
set_property PACKAGE_PIN A41 [get_ports {c0_ddr3_dq[34]}]

# PadFunction: eb_ta3_1_DQ04_D3
set_property SLEW FAST [get_ports {c0_ddr3_dq[35]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[35]}]
set_property PACKAGE_PIN E40 [get_ports {c0_ddr3_dq[35]}]

# PadFunction: eb_ta3_1_DQ04_D4
set_property SLEW FAST [get_ports {c0_ddr3_dq[36]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[36]}]
set_property PACKAGE_PIN D40 [get_ports {c0_ddr3_dq[36]}]

# PadFunction: eb_ta3_1_DQ04_D5
set_property SLEW FAST [get_ports {c0_ddr3_dq[37]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[37]}]
set_property PACKAGE_PIN F42 [get_ports {c0_ddr3_dq[37]}]

# PadFunction: eb_ta3_1_DQ04_D6
set_property SLEW FAST [get_ports {c0_ddr3_dq[38]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[38]}]
set_property PACKAGE_PIN E42 [get_ports {c0_ddr3_dq[38]}]

# PadFunction: eb_ta3_1_DQ04_D7
set_property SLEW FAST [get_ports {c0_ddr3_dq[39]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[39]}]
set_property PACKAGE_PIN C40 [get_ports {c0_ddr3_dq[39]}]

# PadFunction: eb_ta3_1_DQ05_D0
set_property SLEW FAST [get_ports {c0_ddr3_dq[40]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[40]}]
set_property PACKAGE_PIN H41 [get_ports {c0_ddr3_dq[40]}]

# PadFunction: eb_ta3_1_DQ05_D1
set_property SLEW FAST [get_ports {c0_ddr3_dq[41]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[41]}]
set_property PACKAGE_PIN H39 [get_ports {c0_ddr3_dq[41]}]

# PadFunction: eb_ta3_1_DQ05_D2
set_property SLEW FAST [get_ports {c0_ddr3_dq[42]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[42]}]
set_property PACKAGE_PIN G39 [get_ports {c0_ddr3_dq[42]}]

# PadFunction: eb_ta3_1_DQ05_D3
set_property SLEW FAST [get_ports {c0_ddr3_dq[43]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[43]}]
set_property PACKAGE_PIN F40 [get_ports {c0_ddr3_dq[43]}]

# PadFunction: eb_ta3_1_DQ05_D4
set_property SLEW FAST [get_ports {c0_ddr3_dq[44]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[44]}]
set_property PACKAGE_PIN F41 [get_ports {c0_ddr3_dq[44]}]

# PadFunction: eb_ta3_1_DQ05_D5
set_property SLEW FAST [get_ports {c0_ddr3_dq[45]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[45]}]
set_property PACKAGE_PIN J40 [get_ports {c0_ddr3_dq[45]}]

# PadFunction: eb_ta3_1_DQ05_D6
set_property SLEW FAST [get_ports {c0_ddr3_dq[46]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[46]}]
set_property PACKAGE_PIN J41 [get_ports {c0_ddr3_dq[46]}]

# PadFunction: eb_ta3_1_DQ05_D7
set_property SLEW FAST [get_ports {c0_ddr3_dq[47]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[47]}]
set_property PACKAGE_PIN K39 [get_ports {c0_ddr3_dq[47]}]

# PadFunction: eb_ta3_1_DQ06_D0
set_property SLEW FAST [get_ports {c0_ddr3_dq[48]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[48]}]
set_property PACKAGE_PIN L39 [get_ports {c0_ddr3_dq[48]}]

# PadFunction: eb_ta3_1_DQ06_D1
set_property SLEW FAST [get_ports {c0_ddr3_dq[49]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[49]}]
set_property PACKAGE_PIN L40 [get_ports {c0_ddr3_dq[49]}]

# PadFunction: eb_ta3_1_DQ06_D2
set_property SLEW FAST [get_ports {c0_ddr3_dq[50]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[50]}]
set_property PACKAGE_PIN M41 [get_ports {c0_ddr3_dq[50]}]

# PadFunction: eb_ta3_1_DQ06_D3
set_property SLEW FAST [get_ports {c0_ddr3_dq[51]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[51]}]
set_property PACKAGE_PIN L41 [get_ports {c0_ddr3_dq[51]}]

# PadFunction: eb_ta3_1_DQ06_D4
set_property SLEW FAST [get_ports {c0_ddr3_dq[52]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[52]}]
set_property PACKAGE_PIN K38 [get_ports {c0_ddr3_dq[52]}]

# PadFunction: eb_ta3_1_DQ06_D5
set_property SLEW FAST [get_ports {c0_ddr3_dq[53]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[53]}]
set_property PACKAGE_PIN M42 [get_ports {c0_ddr3_dq[53]}]

# PadFunction: eb_ta3_1_DQ06_D6
set_property SLEW FAST [get_ports {c0_ddr3_dq[54]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[54]}]
set_property PACKAGE_PIN L42 [get_ports {c0_ddr3_dq[54]}]

# PadFunction: eb_ta3_1_DQ06_D7
set_property SLEW FAST [get_ports {c0_ddr3_dq[55]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[55]}]
set_property PACKAGE_PIN M36 [get_ports {c0_ddr3_dq[55]}]

# PadFunction: eb_ta3_1_DQ07_D0
set_property SLEW FAST [get_ports {c0_ddr3_dq[56]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[56]}]
set_property PACKAGE_PIN M37 [get_ports {c0_ddr3_dq[56]}]

# PadFunction: eb_ta3_1_DQ07_D1
set_property SLEW FAST [get_ports {c0_ddr3_dq[57]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[57]}]
set_property PACKAGE_PIN M38 [get_ports {c0_ddr3_dq[57]}]

# PadFunction: eb_ta3_1_DQ07_D2
set_property SLEW FAST [get_ports {c0_ddr3_dq[58]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[58]}]
set_property PACKAGE_PIN N38 [get_ports {c0_ddr3_dq[58]}]

# PadFunction: eb_ta3_1_DQ07_D3
set_property SLEW FAST [get_ports {c0_ddr3_dq[59]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[59]}]
set_property PACKAGE_PIN M39 [get_ports {c0_ddr3_dq[59]}]

# PadFunction: eb_ta3_1_DQ07_D4
set_property SLEW FAST [get_ports {c0_ddr3_dq[60]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[60]}]
set_property PACKAGE_PIN R40 [get_ports {c0_ddr3_dq[60]}]

# PadFunction: eb_ta3_1_DQ07_D5
set_property SLEW FAST [get_ports {c0_ddr3_dq[61]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[61]}]
set_property PACKAGE_PIN P40 [get_ports {c0_ddr3_dq[61]}]

# PadFunction: eb_ta3_1_DQ07_D6
set_property SLEW FAST [get_ports {c0_ddr3_dq[62]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[62]}]
set_property PACKAGE_PIN N39 [get_ports {c0_ddr3_dq[62]}]

# PadFunction: eb_ta3_1_DQ07_D7
set_property SLEW FAST [get_ports {c0_ddr3_dq[63]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[63]}]
set_property PACKAGE_PIN N40 [get_ports {c0_ddr3_dq[63]}]

# PadFunction: eb_ta3_1_A0
set_property SLEW FAST [get_ports {c0_ddr3_addr[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[0]}]
set_property PACKAGE_PIN U34 [get_ports {c0_ddr3_addr[0]}]

# PadFunction: eb_ta3_1_A1
set_property SLEW FAST [get_ports {c0_ddr3_addr[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[1]}]
set_property PACKAGE_PIN P38 [get_ports {c0_ddr3_addr[1]}]

# PadFunction: eb_ta3_1_A2
set_property SLEW FAST [get_ports {c0_ddr3_addr[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[2]}]
set_property PACKAGE_PIN P37 [get_ports {c0_ddr3_addr[2]}]

# PadFunction: eb_ta3_1_A3
set_property SLEW FAST [get_ports {c0_ddr3_addr[3]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[3]}]
set_property PACKAGE_PIN R37 [get_ports {c0_ddr3_addr[3]}]

# PadFunction: eb_ta3_1_A4
set_property SLEW FAST [get_ports {c0_ddr3_addr[4]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[4]}]
set_property PACKAGE_PIN T36 [get_ports {c0_ddr3_addr[4]}]

# PadFunction: eb_ta3_1_A5
set_property SLEW FAST [get_ports {c0_ddr3_addr[5]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[5]}]
set_property PACKAGE_PIN P33 [get_ports {c0_ddr3_addr[5]}]

# PadFunction: eb_ta3_1_A6
set_property SLEW FAST [get_ports {c0_ddr3_addr[6]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[6]}]
set_property PACKAGE_PIN P32 [get_ports {c0_ddr3_addr[6]}]

# PadFunction: eb_ta3_1_A7
set_property SLEW FAST [get_ports {c0_ddr3_addr[7]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[7]}]
set_property PACKAGE_PIN R32 [get_ports {c0_ddr3_addr[7]}]

# PadFunction: eb_ta3_1_A8
set_property SLEW FAST [get_ports {c0_ddr3_addr[8]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[8]}]
set_property PACKAGE_PIN T32 [get_ports {c0_ddr3_addr[8]}]

# PadFunction: eb_ta3_1_A9
set_property SLEW FAST [get_ports {c0_ddr3_addr[9]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[9]}]
set_property PACKAGE_PIN P36 [get_ports {c0_ddr3_addr[9]}]

# PadFunction: eb_ta3_1_A10
set_property SLEW FAST [get_ports {c0_ddr3_addr[10]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[10]}]
set_property PACKAGE_PIN P35 [get_ports {c0_ddr3_addr[10]}]

# PadFunction: eb_ta3_1_A11
set_property SLEW FAST [get_ports {c0_ddr3_addr[11]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[11]}]
set_property PACKAGE_PIN N34 [get_ports {c0_ddr3_addr[11]}]

# PadFunction: eb_ta3_1_A12
set_property SLEW FAST [get_ports {c0_ddr3_addr[12]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[12]}]
set_property PACKAGE_PIN N33 [get_ports {c0_ddr3_addr[12]}]

# PadFunction: eb_ta3_1_A13
set_property SLEW FAST [get_ports {c0_ddr3_addr[13]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[13]}]
set_property PACKAGE_PIN R35 [get_ports {c0_ddr3_addr[13]}]

# PadFunction: eb_ta3_1_A14
set_property SLEW FAST [get_ports {c0_ddr3_addr[14]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[14]}]
set_property PACKAGE_PIN T34 [get_ports {c0_ddr3_addr[14]}]

# PadFunction: eb_ta3_1_BA0
set_property SLEW FAST [get_ports {c0_ddr3_ba[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_ba[0]}]
set_property PACKAGE_PIN R39 [get_ports {c0_ddr3_ba[0]}]

# PadFunction: eb_ta3_1_BA1
set_property SLEW FAST [get_ports {c0_ddr3_ba[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_ba[1]}]
set_property PACKAGE_PIN R38 [get_ports {c0_ddr3_ba[1]}]

# PadFunction: eb_ta3_1_BA2
set_property SLEW FAST [get_ports {c0_ddr3_ba[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_ba[2]}]
set_property PACKAGE_PIN T35 [get_ports {c0_ddr3_ba[2]}]

# PadFunction: eb_ta3_1_CASn
set_property SLEW FAST [get_ports c0_ddr3_cas_n]
set_property IOSTANDARD SSTL15 [get_ports c0_ddr3_cas_n]
set_property PACKAGE_PIN U38 [get_ports c0_ddr3_cas_n]

# PadFunction: eb_ta3_1_RASn
set_property SLEW FAST [get_ports c0_ddr3_ras_n]
set_property IOSTANDARD SSTL15 [get_ports c0_ddr3_ras_n]
set_property PACKAGE_PIN U37 [get_ports c0_ddr3_ras_n]

# PadFunction: eb_ta3_1_WEn
set_property SLEW FAST [get_ports c0_ddr3_we_n]
set_property IOSTANDARD SSTL15 [get_ports c0_ddr3_we_n]
set_property PACKAGE_PIN U39 [get_ports c0_ddr3_we_n]

# PadFunction: eb_ta3_1_RESETn
set_property SLEW FAST [get_ports c0_ddr3_reset_n]
set_property IOSTANDARD LVCMOS15 [get_ports c0_ddr3_reset_n]
set_property PACKAGE_PIN AK38 [get_ports c0_ddr3_reset_n]

# PadFunction: eb_ta3_1_CKE
set_property SLEW FAST [get_ports {c0_ddr3_cke[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_cke[0]}]
set_property PACKAGE_PIN V33 [get_ports {c0_ddr3_cke[0]}]

# PadFunction: eb_ta3_1_ODT
set_property SLEW FAST [get_ports {c0_ddr3_odt[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_odt[0]}]
set_property PACKAGE_PIN V34 [get_ports {c0_ddr3_odt[0]}]

# PadFunction: eb_ta3_1_CSn
set_property SLEW FAST [get_ports {c0_ddr3_cs_n[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_cs_n[0]}]
set_property PACKAGE_PIN T39 [get_ports {c0_ddr3_cs_n[0]}]

# PadFunction: eb_ta3_1_DQ00_DM
set_property SLEW FAST [get_ports {c0_ddr3_dm[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[0]}]
set_property PACKAGE_PIN AB41 [get_ports {c0_ddr3_dm[0]}]

# PadFunction: eb_ta3_1_DQ01_DM
set_property SLEW FAST [get_ports {c0_ddr3_dm[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[1]}]
set_property PACKAGE_PIN AC38 [get_ports {c0_ddr3_dm[1]}]

# PadFunction: eb_ta3_1_DQ02_DM
set_property SLEW FAST [get_ports {c0_ddr3_dm[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[2]}]
set_property PACKAGE_PIN AF42 [get_ports {c0_ddr3_dm[2]}]

# PadFunction: eb_ta3_1_DQ03_DM
set_property SLEW FAST [get_ports {c0_ddr3_dm[3]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[3]}]
set_property PACKAGE_PIN AK40 [get_ports {c0_ddr3_dm[3]}]

# PadFunction: eb_ta3_1_DQ04_DM
set_property SLEW FAST [get_ports {c0_ddr3_dm[4]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[4]}]
set_property PACKAGE_PIN B41 [get_ports {c0_ddr3_dm[4]}]

# PadFunction: eb_ta3_1_DQ05_DM
set_property SLEW FAST [get_ports {c0_ddr3_dm[5]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[5]}]
set_property PACKAGE_PIN H40 [get_ports {c0_ddr3_dm[5]}]

# PadFunction: eb_ta3_1_DQ06_DM
set_property SLEW FAST [get_ports {c0_ddr3_dm[6]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[6]}]
set_property PACKAGE_PIN K37 [get_ports {c0_ddr3_dm[6]}]

# PadFunction: eb_ta3_1_DQ07_DM
set_property SLEW FAST [get_ports {c0_ddr3_dm[7]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[7]}]
set_property PACKAGE_PIN P41 [get_ports {c0_ddr3_dm[7]}]

# PadFunction: eb_ta3_1_DQ00_DQS
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[0]}]

# PadFunction: eb_ta3_1_DQ00_DQSn
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[0]}]
set_property PACKAGE_PIN AA39 [get_ports {c0_ddr3_dqs_n[0]}]
set_property PACKAGE_PIN Y39 [get_ports {c0_ddr3_dqs_p[0]}]

# PadFunction: eb_ta3_1_DQ01_DQS
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[1]}]

# PadFunction: eb_ta3_1_DQ01_DQSn
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[1]}]
set_property PACKAGE_PIN AE38 [get_ports {c0_ddr3_dqs_n[1]}]
set_property PACKAGE_PIN AD38 [get_ports {c0_ddr3_dqs_p[1]}]

# PadFunction: eb_ta3_1_DQ02_DQS
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[2]}]

# PadFunction: eb_ta3_1_DQ02_DQSn
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[2]}]
set_property PACKAGE_PIN AH39 [get_ports {c0_ddr3_dqs_n[2]}]
set_property PACKAGE_PIN AG39 [get_ports {c0_ddr3_dqs_p[2]}]

# PadFunction: eb_ta3_1_DQ03_DQS
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[3]}]

# PadFunction: eb_ta3_1_DQ03_DQSn
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[3]}]
set_property PACKAGE_PIN AL42 [get_ports {c0_ddr3_dqs_n[3]}]
set_property PACKAGE_PIN AL41 [get_ports {c0_ddr3_dqs_p[3]}]

# PadFunction: eb_ta3_1_DQ04_DQS
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[4]}]

# PadFunction: eb_ta3_1_DQ04_DQSn
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[4]}]
set_property PACKAGE_PIN D42 [get_ports {c0_ddr3_dqs_n[4]}]
set_property PACKAGE_PIN D41 [get_ports {c0_ddr3_dqs_p[4]}]

# PadFunction: eb_ta3_1_DQ05_DQS
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[5]}]

# PadFunction: eb_ta3_1_DQ05_DQSn
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[5]}]
set_property PACKAGE_PIN G42 [get_ports {c0_ddr3_dqs_n[5]}]
set_property PACKAGE_PIN G41 [get_ports {c0_ddr3_dqs_p[5]}]

# PadFunction: eb_ta3_1_DQ06_DQS
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[6]}]

# PadFunction: eb_ta3_1_DQ06_DQSn
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[6]}]
set_property PACKAGE_PIN J42 [get_ports {c0_ddr3_dqs_n[6]}]
set_property PACKAGE_PIN K42 [get_ports {c0_ddr3_dqs_p[6]}]

# PadFunction: eb_ta3_1_DQ07_DQS
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[7]}]

# PadFunction: eb_ta3_1_DQ07_DQSn
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[7]}]
set_property PACKAGE_PIN P42 [get_ports {c0_ddr3_dqs_n[7]}]
set_property PACKAGE_PIN R42 [get_ports {c0_ddr3_dqs_p[7]}]

# PadFunction: eb_ta3_1_CK
set_property SLEW FAST [get_ports {c0_ddr3_ck_p[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {c0_ddr3_ck_p[0]}]

# PadFunction: eb_ta3_1_CKn
set_property SLEW FAST [get_ports {c0_ddr3_ck_n[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {c0_ddr3_ck_n[0]}]
set_property PACKAGE_PIN R34 [get_ports {c0_ddr3_ck_n[0]}]
set_property PACKAGE_PIN R33 [get_ports {c0_ddr3_ck_p[0]}]

# PadFunction: eb_ta3_1_LED01
set_property IOSTANDARD LVCMOS15 [get_ports c0_calib_complete]
set_property PACKAGE_PIN V39 [get_ports c0_calib_complete]

# Pin and IO property

#-----------------------------------------------------------
#              MIG-TB1                                         -
#-----------------------------------------------------------

# PadFunction: eb_tb3_1_DQ00_D0
set_property SLEW FAST [get_ports {c1_ddr3_dq[0]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[0]}]
set_property PACKAGE_PIN A25 [get_ports {c1_ddr3_dq[0]}]

# PadFunction: eb_tb3_1_DQ00_D1
set_property SLEW FAST [get_ports {c1_ddr3_dq[1]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[1]}]
set_property PACKAGE_PIN C23 [get_ports {c1_ddr3_dq[1]}]

# PadFunction: eb_tb3_1_DQ00_D2
set_property SLEW FAST [get_ports {c1_ddr3_dq[2]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[2]}]
set_property PACKAGE_PIN B23 [get_ports {c1_ddr3_dq[2]}]

# PadFunction: eb_tb3_1_DQ00_D3
set_property SLEW FAST [get_ports {c1_ddr3_dq[3]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[3]}]
set_property PACKAGE_PIN B22 [get_ports {c1_ddr3_dq[3]}]

# PadFunction: eb_tb3_1_DQ00_D4
set_property SLEW FAST [get_ports {c1_ddr3_dq[4]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[4]}]
set_property PACKAGE_PIN A22 [get_ports {c1_ddr3_dq[4]}]

# PadFunction: eb_tb3_1_DQ00_D5
set_property SLEW FAST [get_ports {c1_ddr3_dq[5]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[5]}]
set_property PACKAGE_PIN B26 [get_ports {c1_ddr3_dq[5]}]

# PadFunction: eb_tb3_1_DQ00_D6
set_property SLEW FAST [get_ports {c1_ddr3_dq[6]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[6]}]
set_property PACKAGE_PIN B27 [get_ports {c1_ddr3_dq[6]}]

# PadFunction: eb_tb3_1_DQ00_D7
set_property SLEW FAST [get_ports {c1_ddr3_dq[7]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[7]}]
set_property PACKAGE_PIN C24 [get_ports {c1_ddr3_dq[7]}]

# PadFunction: eb_tb3_1_DQ01_D0
set_property SLEW FAST [get_ports {c1_ddr3_dq[8]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[8]}]
set_property PACKAGE_PIN D23 [get_ports {c1_ddr3_dq[8]}]

# PadFunction: eb_tb3_1_DQ01_D1
set_property SLEW FAST [get_ports {c1_ddr3_dq[9]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[9]}]
set_property PACKAGE_PIN F22 [get_ports {c1_ddr3_dq[9]}]

# PadFunction: eb_tb3_1_DQ01_D2
set_property SLEW FAST [get_ports {c1_ddr3_dq[10]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[10]}]
set_property PACKAGE_PIN E22 [get_ports {c1_ddr3_dq[10]}]

# PadFunction: eb_tb3_1_DQ01_D3
set_property SLEW FAST [get_ports {c1_ddr3_dq[11]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[11]}]
set_property PACKAGE_PIN E23 [get_ports {c1_ddr3_dq[11]}]

# PadFunction: eb_tb3_1_DQ01_D4
set_property SLEW FAST [get_ports {c1_ddr3_dq[12]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[12]}]
set_property PACKAGE_PIN E24 [get_ports {c1_ddr3_dq[12]}]

# PadFunction: eb_tb3_1_DQ01_D5
set_property SLEW FAST [get_ports {c1_ddr3_dq[13]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[13]}]
set_property PACKAGE_PIN D25 [get_ports {c1_ddr3_dq[13]}]

# PadFunction: eb_tb3_1_DQ01_D6
set_property SLEW FAST [get_ports {c1_ddr3_dq[14]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[14]}]
set_property PACKAGE_PIN D26 [get_ports {c1_ddr3_dq[14]}]

# PadFunction: eb_tb3_1_DQ01_D7
set_property SLEW FAST [get_ports {c1_ddr3_dq[15]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[15]}]
set_property PACKAGE_PIN C25 [get_ports {c1_ddr3_dq[15]}]

# PadFunction: eb_tb3_1_DQ02_D0
set_property SLEW FAST [get_ports {c1_ddr3_dq[16]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[16]}]
set_property PACKAGE_PIN D27 [get_ports {c1_ddr3_dq[16]}]

# PadFunction: eb_tb3_1_DQ02_D1
set_property SLEW FAST [get_ports {c1_ddr3_dq[17]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[17]}]
set_property PACKAGE_PIN D28 [get_ports {c1_ddr3_dq[17]}]

# PadFunction: eb_tb3_1_DQ02_D2
set_property SLEW FAST [get_ports {c1_ddr3_dq[18]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[18]}]
set_property PACKAGE_PIN C28 [get_ports {c1_ddr3_dq[18]}]

# PadFunction: eb_tb3_1_DQ02_D3
set_property SLEW FAST [get_ports {c1_ddr3_dq[19]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[19]}]
set_property PACKAGE_PIN C29 [get_ports {c1_ddr3_dq[19]}]

# PadFunction: eb_tb3_1_DQ02_D4
set_property SLEW FAST [get_ports {c1_ddr3_dq[20]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[20]}]
set_property PACKAGE_PIN B31 [get_ports {c1_ddr3_dq[20]}]

# PadFunction: eb_tb3_1_DQ02_D5
set_property SLEW FAST [get_ports {c1_ddr3_dq[21]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[21]}]
set_property PACKAGE_PIN A29 [get_ports {c1_ddr3_dq[21]}]

# PadFunction: eb_tb3_1_DQ02_D6
set_property SLEW FAST [get_ports {c1_ddr3_dq[22]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[22]}]
set_property PACKAGE_PIN A30 [get_ports {c1_ddr3_dq[22]}]

# PadFunction: eb_tb3_1_DQ02_D7
set_property SLEW FAST [get_ports {c1_ddr3_dq[23]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[23]}]
set_property PACKAGE_PIN A31 [get_ports {c1_ddr3_dq[23]}]

# PadFunction: eb_tb3_1_DQ03_D0
set_property SLEW FAST [get_ports {c1_ddr3_dq[24]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[24]}]
set_property PACKAGE_PIN F26 [get_ports {c1_ddr3_dq[24]}]

# PadFunction: eb_tb3_1_DQ03_D1
set_property SLEW FAST [get_ports {c1_ddr3_dq[25]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[25]}]
set_property PACKAGE_PIN F27 [get_ports {c1_ddr3_dq[25]}]

# PadFunction: eb_tb3_1_DQ03_D2
set_property SLEW FAST [get_ports {c1_ddr3_dq[26]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[26]}]
set_property PACKAGE_PIN F30 [get_ports {c1_ddr3_dq[26]}]

# PadFunction: eb_tb3_1_DQ03_D3
set_property SLEW FAST [get_ports {c1_ddr3_dq[27]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[27]}]
set_property PACKAGE_PIN F31 [get_ports {c1_ddr3_dq[27]}]

# PadFunction: eb_tb3_1_DQ03_D4
set_property SLEW FAST [get_ports {c1_ddr3_dq[28]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[28]}]
set_property PACKAGE_PIN D30 [get_ports {c1_ddr3_dq[28]}]

# PadFunction: eb_tb3_1_DQ03_D5
set_property SLEW FAST [get_ports {c1_ddr3_dq[29]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[29]}]
set_property PACKAGE_PIN C30 [get_ports {c1_ddr3_dq[29]}]

# PadFunction: eb_tb3_1_DQ03_D6
set_property SLEW FAST [get_ports {c1_ddr3_dq[30]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[30]}]
set_property PACKAGE_PIN F29 [get_ports {c1_ddr3_dq[30]}]

# PadFunction: eb_tb3_1_DQ03_D7
set_property SLEW FAST [get_ports {c1_ddr3_dq[31]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[31]}]
set_property PACKAGE_PIN E29 [get_ports {c1_ddr3_dq[31]}]

# PadFunction: eb_tb3_1_DQ04_D0
set_property SLEW FAST [get_ports {c1_ddr3_dq[32]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[32]}]
set_property PACKAGE_PIN B16 [get_ports {c1_ddr3_dq[32]}]

# PadFunction: eb_tb3_1_DQ04_D1
set_property SLEW FAST [get_ports {c1_ddr3_dq[33]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[33]}]
set_property PACKAGE_PIN D16 [get_ports {c1_ddr3_dq[33]}]

# PadFunction: eb_tb3_1_DQ04_D2
set_property SLEW FAST [get_ports {c1_ddr3_dq[34]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[34]}]
set_property PACKAGE_PIN D15 [get_ports {c1_ddr3_dq[34]}]

# PadFunction: eb_tb3_1_DQ04_D3
set_property SLEW FAST [get_ports {c1_ddr3_dq[35]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[35]}]
set_property PACKAGE_PIN D13 [get_ports {c1_ddr3_dq[35]}]

# PadFunction: eb_tb3_1_DQ04_D4
set_property SLEW FAST [get_ports {c1_ddr3_dq[36]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[36]}]
set_property PACKAGE_PIN C13 [get_ports {c1_ddr3_dq[36]}]

# PadFunction: eb_tb3_1_DQ04_D5
set_property SLEW FAST [get_ports {c1_ddr3_dq[37]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[37]}]
set_property PACKAGE_PIN B14 [get_ports {c1_ddr3_dq[37]}]

# PadFunction: eb_tb3_1_DQ04_D6
set_property SLEW FAST [get_ports {c1_ddr3_dq[38]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[38]}]
set_property PACKAGE_PIN A14 [get_ports {c1_ddr3_dq[38]}]

# PadFunction: eb_tb3_1_DQ04_D7
set_property SLEW FAST [get_ports {c1_ddr3_dq[39]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[39]}]
set_property PACKAGE_PIN E12 [get_ports {c1_ddr3_dq[39]}]

# PadFunction: eb_tb3_1_DQ05_D0
set_property SLEW FAST [get_ports {c1_ddr3_dq[40]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[40]}]
set_property PACKAGE_PIN E15 [get_ports {c1_ddr3_dq[40]}]

# PadFunction: eb_tb3_1_DQ05_D1
set_property SLEW FAST [get_ports {c1_ddr3_dq[41]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[41]}]
set_property PACKAGE_PIN E14 [get_ports {c1_ddr3_dq[41]}]

# PadFunction: eb_tb3_1_DQ05_D2
set_property SLEW FAST [get_ports {c1_ddr3_dq[42]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[42]}]
set_property PACKAGE_PIN E13 [get_ports {c1_ddr3_dq[42]}]

# PadFunction: eb_tb3_1_DQ05_D3
set_property SLEW FAST [get_ports {c1_ddr3_dq[43]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[43]}]
set_property PACKAGE_PIN G12 [get_ports {c1_ddr3_dq[43]}]

# PadFunction: eb_tb3_1_DQ05_D4
set_property SLEW FAST [get_ports {c1_ddr3_dq[44]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[44]}]
set_property PACKAGE_PIN F12 [get_ports {c1_ddr3_dq[44]}]

# PadFunction: eb_tb3_1_DQ05_D5
set_property SLEW FAST [get_ports {c1_ddr3_dq[45]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[45]}]
set_property PACKAGE_PIN F15 [get_ports {c1_ddr3_dq[45]}]

# PadFunction: eb_tb3_1_DQ05_D6
set_property SLEW FAST [get_ports {c1_ddr3_dq[46]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[46]}]
set_property PACKAGE_PIN F14 [get_ports {c1_ddr3_dq[46]}]

# PadFunction: eb_tb3_1_DQ05_D7
set_property SLEW FAST [get_ports {c1_ddr3_dq[47]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[47]}]
set_property PACKAGE_PIN G14 [get_ports {c1_ddr3_dq[47]}]

# PadFunction: eb_tb3_1_DQ06_D0
set_property SLEW FAST [get_ports {c1_ddr3_dq[48]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[48]}]
set_property PACKAGE_PIN H15 [get_ports {c1_ddr3_dq[48]}]

# PadFunction: eb_tb3_1_DQ06_D1
set_property SLEW FAST [get_ports {c1_ddr3_dq[49]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[49]}]
set_property PACKAGE_PIN H14 [get_ports {c1_ddr3_dq[49]}]

# PadFunction: eb_tb3_1_DQ06_D2
set_property SLEW FAST [get_ports {c1_ddr3_dq[50]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[50]}]
set_property PACKAGE_PIN J13 [get_ports {c1_ddr3_dq[50]}]

# PadFunction: eb_tb3_1_DQ06_D3
set_property SLEW FAST [get_ports {c1_ddr3_dq[51]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[51]}]
set_property PACKAGE_PIN H13 [get_ports {c1_ddr3_dq[51]}]

# PadFunction: eb_tb3_1_DQ06_D4
set_property SLEW FAST [get_ports {c1_ddr3_dq[52]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[52]}]
set_property PACKAGE_PIN K13 [get_ports {c1_ddr3_dq[52]}]

# PadFunction: eb_tb3_1_DQ06_D5
set_property SLEW FAST [get_ports {c1_ddr3_dq[53]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[53]}]
set_property PACKAGE_PIN K15 [get_ports {c1_ddr3_dq[53]}]

# PadFunction: eb_tb3_1_DQ06_D6
set_property SLEW FAST [get_ports {c1_ddr3_dq[54]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[54]}]
set_property PACKAGE_PIN J15 [get_ports {c1_ddr3_dq[54]}]

# PadFunction: eb_tb3_1_DQ06_D7
set_property SLEW FAST [get_ports {c1_ddr3_dq[55]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[55]}]
set_property PACKAGE_PIN L16 [get_ports {c1_ddr3_dq[55]}]

# PadFunction: eb_tb3_1_DQ07_D0
set_property SLEW FAST [get_ports {c1_ddr3_dq[56]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[56]}]
set_property PACKAGE_PIN N15 [get_ports {c1_ddr3_dq[56]}]

# PadFunction: eb_tb3_1_DQ07_D1
set_property SLEW FAST [get_ports {c1_ddr3_dq[57]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[57]}]
set_property PACKAGE_PIN N14 [get_ports {c1_ddr3_dq[57]}]

# PadFunction: eb_tb3_1_DQ07_D2
set_property SLEW FAST [get_ports {c1_ddr3_dq[58]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[58]}]
set_property PACKAGE_PIN N13 [get_ports {c1_ddr3_dq[58]}]

# PadFunction: eb_tb3_1_DQ07_D3
set_property SLEW FAST [get_ports {c1_ddr3_dq[59]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[59]}]
set_property PACKAGE_PIN M13 [get_ports {c1_ddr3_dq[59]}]

# PadFunction: eb_tb3_1_DQ07_D4
set_property SLEW FAST [get_ports {c1_ddr3_dq[60]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[60]}]
set_property PACKAGE_PIN M14 [get_ports {c1_ddr3_dq[60]}]

# PadFunction: eb_tb3_1_DQ07_D5
set_property SLEW FAST [get_ports {c1_ddr3_dq[61]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[61]}]
set_property PACKAGE_PIN L14 [get_ports {c1_ddr3_dq[61]}]

# PadFunction: eb_tb3_1_DQ07_D6
set_property SLEW FAST [get_ports {c1_ddr3_dq[62]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[62]}]
set_property PACKAGE_PIN M12 [get_ports {c1_ddr3_dq[62]}]

# PadFunction: eb_tb3_1_DQ07_D7
set_property SLEW FAST [get_ports {c1_ddr3_dq[63]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[63]}]
set_property PACKAGE_PIN M11 [get_ports {c1_ddr3_dq[63]}]

# PadFunction: eb_tb3_1_A0
set_property SLEW FAST [get_ports {c1_ddr3_addr[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[0]}]
set_property PACKAGE_PIN D21 [get_ports {c1_ddr3_addr[0]}]

# PadFunction: eb_tb3_1_A1
set_property SLEW FAST [get_ports {c1_ddr3_addr[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[1]}]
set_property PACKAGE_PIN E17 [get_ports {c1_ddr3_addr[1]}]

# PadFunction: eb_tb3_1_A2
set_property SLEW FAST [get_ports {c1_ddr3_addr[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[2]}]
set_property PACKAGE_PIN F17 [get_ports {c1_ddr3_addr[2]}]

# PadFunction: eb_tb3_1_A3
set_property SLEW FAST [get_ports {c1_ddr3_addr[3]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[3]}]
set_property PACKAGE_PIN C20 [get_ports {c1_ddr3_addr[3]}]

# PadFunction: eb_tb3_1_A4
set_property SLEW FAST [get_ports {c1_ddr3_addr[4]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[4]}]
set_property PACKAGE_PIN D20 [get_ports {c1_ddr3_addr[4]}]

# PadFunction: eb_tb3_1_A5
set_property SLEW FAST [get_ports {c1_ddr3_addr[5]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[5]}]
set_property PACKAGE_PIN B18 [get_ports {c1_ddr3_addr[5]}]

# PadFunction: eb_tb3_1_A6
set_property SLEW FAST [get_ports {c1_ddr3_addr[6]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[6]}]
set_property PACKAGE_PIN C18 [get_ports {c1_ddr3_addr[6]}]

# PadFunction: eb_tb3_1_A7
set_property SLEW FAST [get_ports {c1_ddr3_addr[7]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[7]}]
set_property PACKAGE_PIN A21 [get_ports {c1_ddr3_addr[7]}]

# PadFunction: eb_tb3_1_A8
set_property SLEW FAST [get_ports {c1_ddr3_addr[8]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[8]}]
set_property PACKAGE_PIN B21 [get_ports {c1_ddr3_addr[8]}]

# PadFunction: eb_tb3_1_A9
set_property SLEW FAST [get_ports {c1_ddr3_addr[9]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[9]}]
set_property PACKAGE_PIN A17 [get_ports {c1_ddr3_addr[9]}]

# PadFunction: eb_tb3_1_A10
set_property SLEW FAST [get_ports {c1_ddr3_addr[10]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[10]}]
set_property PACKAGE_PIN B17 [get_ports {c1_ddr3_addr[10]}]

# PadFunction: eb_tb3_1_A11
set_property SLEW FAST [get_ports {c1_ddr3_addr[11]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[11]}]
set_property PACKAGE_PIN A15 [get_ports {c1_ddr3_addr[11]}]

# PadFunction: eb_tb3_1_A12
set_property SLEW FAST [get_ports {c1_ddr3_addr[12]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[12]}]
set_property PACKAGE_PIN A16 [get_ports {c1_ddr3_addr[12]}]

# PadFunction: eb_tb3_1_A13
set_property SLEW FAST [get_ports {c1_ddr3_addr[13]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[13]}]
set_property PACKAGE_PIN B19 [get_ports {c1_ddr3_addr[13]}]

# PadFunction: eb_tb3_1_A14
set_property SLEW FAST [get_ports {c1_ddr3_addr[14]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[14]}]
set_property PACKAGE_PIN C19 [get_ports {c1_ddr3_addr[14]}]

# PadFunction: eb_tb3_1_BA0
set_property SLEW FAST [get_ports {c1_ddr3_ba[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_ba[0]}]
set_property PACKAGE_PIN D17 [get_ports {c1_ddr3_ba[0]}]

# PadFunction: eb_tb3_1_BA1
set_property SLEW FAST [get_ports {c1_ddr3_ba[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_ba[1]}]
set_property PACKAGE_PIN D18 [get_ports {c1_ddr3_ba[1]}]

# PadFunction: eb_tb3_1_BA2
set_property SLEW FAST [get_ports {c1_ddr3_ba[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_ba[2]}]
set_property PACKAGE_PIN C21 [get_ports {c1_ddr3_ba[2]}]

# PadFunction: eb_tb3_1_CASn
set_property SLEW FAST [get_ports c1_ddr3_cas_n]
set_property IOSTANDARD SSTL15 [get_ports c1_ddr3_cas_n]
set_property PACKAGE_PIN F19 [get_ports c1_ddr3_cas_n]

# PadFunction: eb_tb3_1_RASn
set_property SLEW FAST [get_ports c1_ddr3_ras_n]
set_property IOSTANDARD SSTL15 [get_ports c1_ddr3_ras_n]
set_property PACKAGE_PIN G19 [get_ports c1_ddr3_ras_n]

# PadFunction: eb_tb3_1_WEn
set_property SLEW FAST [get_ports c1_ddr3_we_n]
set_property IOSTANDARD SSTL15 [get_ports c1_ddr3_we_n]
set_property PACKAGE_PIN E19 [get_ports c1_ddr3_we_n]

# PadFunction: eb_tb3_1_RESETn
set_property SLEW FAST [get_ports c1_ddr3_reset_n]
set_property IOSTANDARD LVCMOS15 [get_ports c1_ddr3_reset_n]
set_property PACKAGE_PIN A32 [get_ports c1_ddr3_reset_n]

# PadFunction: eb_tb3_1_CKE
set_property SLEW FAST [get_ports {c1_ddr3_cke[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_cke[0]}]
set_property PACKAGE_PIN F20 [get_ports {c1_ddr3_cke[0]}]

# PadFunction: eb_tb3_1_ODT
set_property SLEW FAST [get_ports {c1_ddr3_odt[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_odt[0]}]
set_property PACKAGE_PIN E20 [get_ports {c1_ddr3_odt[0]}]

# PadFunction: eb_tb3_1_CSn
set_property SLEW FAST [get_ports {c1_ddr3_cs_n[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_cs_n[0]}]
set_property PACKAGE_PIN E18 [get_ports {c1_ddr3_cs_n[0]}]

# PadFunction: eb_tb3_1_DQ00_DM
set_property SLEW FAST [get_ports {c1_ddr3_dm[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[0]}]
set_property PACKAGE_PIN A24 [get_ports {c1_ddr3_dm[0]}]

# PadFunction: eb_tb3_1_DQ01_DM
set_property SLEW FAST [get_ports {c1_ddr3_dm[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[1]}]
set_property PACKAGE_PIN D22 [get_ports {c1_ddr3_dm[1]}]

# PadFunction: eb_tb3_1_DQ02_DM
set_property SLEW FAST [get_ports {c1_ddr3_dm[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[2]}]
set_property PACKAGE_PIN C31 [get_ports {c1_ddr3_dm[2]}]

# PadFunction: eb_tb3_1_DQ03_DM
set_property SLEW FAST [get_ports {c1_ddr3_dm[3]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[3]}]
set_property PACKAGE_PIN E30 [get_ports {c1_ddr3_dm[3]}]

# PadFunction: eb_tb3_1_DQ04_DM
set_property SLEW FAST [get_ports {c1_ddr3_dm[4]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[4]}]
set_property PACKAGE_PIN C16 [get_ports {c1_ddr3_dm[4]}]

# PadFunction: eb_tb3_1_DQ05_DM
set_property SLEW FAST [get_ports {c1_ddr3_dm[5]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[5]}]
set_property PACKAGE_PIN F16 [get_ports {c1_ddr3_dm[5]}]

# PadFunction: eb_tb3_1_DQ06_DM
set_property SLEW FAST [get_ports {c1_ddr3_dm[6]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[6]}]
set_property PACKAGE_PIN K14 [get_ports {c1_ddr3_dm[6]}]

# PadFunction: eb_tb3_1_DQ07_DM
set_property SLEW FAST [get_ports {c1_ddr3_dm[7]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[7]}]
set_property PACKAGE_PIN L12 [get_ports {c1_ddr3_dm[7]}]

# PadFunction: eb_tb3_1_DQ00_DQS
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[0]}]

# PadFunction: eb_tb3_1_DQ00_DQSn
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[0]}]
set_property PACKAGE_PIN A27 [get_ports {c1_ddr3_dqs_n[0]}]
set_property PACKAGE_PIN A26 [get_ports {c1_ddr3_dqs_p[0]}]

# PadFunction: eb_tb3_1_DQ01_DQS
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[1]}]

# PadFunction: eb_tb3_1_DQ01_DQSn
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[1]}]
set_property PACKAGE_PIN E25 [get_ports {c1_ddr3_dqs_n[1]}]
set_property PACKAGE_PIN F25 [get_ports {c1_ddr3_dqs_p[1]}]

# PadFunction: eb_tb3_1_DQ02_DQS
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[2]}]

# PadFunction: eb_tb3_1_DQ02_DQSn
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[2]}]
set_property PACKAGE_PIN B29 [get_ports {c1_ddr3_dqs_n[2]}]
set_property PACKAGE_PIN B28 [get_ports {c1_ddr3_dqs_p[2]}]

# PadFunction: eb_tb3_1_DQ03_DQS
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[3]}]

# PadFunction: eb_tb3_1_DQ03_DQSn
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[3]}]
set_property PACKAGE_PIN E28 [get_ports {c1_ddr3_dqs_n[3]}]
set_property PACKAGE_PIN E27 [get_ports {c1_ddr3_dqs_p[3]}]

# PadFunction: eb_tb3_1_DQ04_DQS
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[4]}]

# PadFunction: eb_tb3_1_DQ04_DQSn
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[4]}]
set_property PACKAGE_PIN C14 [get_ports {c1_ddr3_dqs_n[4]}]
set_property PACKAGE_PIN C15 [get_ports {c1_ddr3_dqs_p[4]}]

# PadFunction: eb_tb3_1_DQ05_DQS
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[5]}]

# PadFunction: eb_tb3_1_DQ05_DQSn
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[5]}]
set_property PACKAGE_PIN G16 [get_ports {c1_ddr3_dqs_n[5]}]
set_property PACKAGE_PIN H16 [get_ports {c1_ddr3_dqs_p[5]}]

# PadFunction: eb_tb3_1_DQ06_DQS
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[6]}]

# PadFunction: eb_tb3_1_DQ06_DQSn
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[6]}]
set_property PACKAGE_PIN J12 [get_ports {c1_ddr3_dqs_n[6]}]
set_property PACKAGE_PIN K12 [get_ports {c1_ddr3_dqs_p[6]}]

# PadFunction: eb_tb3_1_DQ07_DQS
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[7]}]

# PadFunction: eb_tb3_1_DQ07_DQSn
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[7]}]
set_property PACKAGE_PIN M16 [get_ports {c1_ddr3_dqs_n[7]}]
set_property PACKAGE_PIN N16 [get_ports {c1_ddr3_dqs_p[7]}]

# PadFunction: eb_tb3_1_CK
set_property SLEW FAST [get_ports {c1_ddr3_ck_p[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {c1_ddr3_ck_p[0]}]

# PadFunction: eb_tb3_1_CKn
set_property SLEW FAST [get_ports {c1_ddr3_ck_n[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {c1_ddr3_ck_n[0]}]
set_property PACKAGE_PIN A20 [get_ports {c1_ddr3_ck_p[0]}]
set_property PACKAGE_PIN A19 [get_ports {c1_ddr3_ck_n[0]}]

# PadFunction: eb_tb3_1_LED01
set_property IOSTANDARD LVCMOS15 [get_ports c1_calib_complete]
set_property PACKAGE_PIN P18 [get_ports c1_calib_complete]


