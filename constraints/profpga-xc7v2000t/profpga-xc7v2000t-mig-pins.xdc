# Pin and IO property

#-----------------------------------------------------------
#              Diagnostic LEDs                             -
#-----------------------------------------------------------

# (eb_ta1a1_1_LED02)
set_property IOSTANDARD LVCMOS15 [get_ports rst_led]
set_property PACKAGE_PIN L35 [get_ports rst_led]
# (eb_ta1a1_1_LED03)
set_property IOSTANDARD LVCMOS15 [get_ports rstraw_led]
set_property PACKAGE_PIN L34 [get_ports rstraw_led]
# (eb_ta1a1_1_LED04)
set_property IOSTANDARD LVCMOS15 [get_ports rstn_led]
set_property PACKAGE_PIN J35 [get_ports rstn_led]
# (eb_ta1a1_1_LED05)
set_property IOSTANDARD LVCMOS15 [get_ports migrstn_led]
set_property PACKAGE_PIN J34 [get_ports migrstn_led]
# (eb_ta1a1_1_LED06)
set_property IOSTANDARD LVCMOS15 [get_ports diagnostic_led]
set_property PACKAGE_PIN K37 [get_ports diagnostic_led]

#-----------------------------------------------------------
#              Reset                                       -
#-----------------------------------------------------------

# sys_rst named reset in leon3mp (eb_ta1a1_1_SW1)
set_property IOSTANDARD LVCMOS15 [get_ports reset]
set_property PACKAGE_PIN J44 [get_ports reset]

#-----------------------------------------------------------
#              MIG-TA1                                         -
#-----------------------------------------------------------

# PadFunction: IO_L1N_T0_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[0]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[0]}]
set_property PACKAGE_PIN A35 [get_ports {c0_ddr3_dq[0]}]

# PadFunction: IO_L2P_T0_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[1]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[1]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[1]}]
set_property PACKAGE_PIN D34 [get_ports {c0_ddr3_dq[1]}]

# PadFunction: IO_L2N_T0_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[2]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[2]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[2]}]
set_property PACKAGE_PIN C34 [get_ports {c0_ddr3_dq[2]}]

# PadFunction: IO_L4P_T0_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[3]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[3]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[3]}]
set_property PACKAGE_PIN C36 [get_ports {c0_ddr3_dq[3]}]

# PadFunction: IO_L4N_T0_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[4]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[4]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[4]}]
set_property PACKAGE_PIN B36 [get_ports {c0_ddr3_dq[4]}]

# PadFunction: IO_L5P_T0_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[5]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[5]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[5]}]
set_property PACKAGE_PIN B34 [get_ports {c0_ddr3_dq[5]}]

# PadFunction: IO_L5N_T0_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[6]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[6]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[6]}]
set_property PACKAGE_PIN A34 [get_ports {c0_ddr3_dq[6]}]

# PadFunction: IO_L6P_T0_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[7]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[7]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[7]}]
set_property PACKAGE_PIN F35 [get_ports {c0_ddr3_dq[7]}]

# PadFunction: IO_L7N_T1_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[8]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[8]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[8]}]
set_property PACKAGE_PIN E37 [get_ports {c0_ddr3_dq[8]}]

# PadFunction: IO_L8P_T1_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[9]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[9]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[9]}]
set_property PACKAGE_PIN C37 [get_ports {c0_ddr3_dq[9]}]

# PadFunction: IO_L8N_T1_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[10]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[10]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[10]}]
set_property PACKAGE_PIN B37 [get_ports {c0_ddr3_dq[10]}]

# PadFunction: IO_L10P_T1_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[11]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[11]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[11]}]
set_property PACKAGE_PIN A37 [get_ports {c0_ddr3_dq[11]}]

# PadFunction: IO_L10N_T1_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[12]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[12]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[12]}]
set_property PACKAGE_PIN A38 [get_ports {c0_ddr3_dq[12]}]

# PadFunction: IO_L11P_T1_SRCC_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[13]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[13]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[13]}]
set_property PACKAGE_PIN E38 [get_ports {c0_ddr3_dq[13]}]

# PadFunction: IO_L11N_T1_SRCC_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[14]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[14]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[14]}]
set_property PACKAGE_PIN D38 [get_ports {c0_ddr3_dq[14]}]

# PadFunction: IO_L12P_T1_MRCC_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[15]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[15]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[15]}]
set_property PACKAGE_PIN C38 [get_ports {c0_ddr3_dq[15]}]

# PadFunction: IO_L13P_T2_MRCC_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[16]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[16]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[16]}]
set_property PACKAGE_PIN D41 [get_ports {c0_ddr3_dq[16]}]

# PadFunction: IO_L13N_T2_MRCC_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[17]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[17]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[17]}]
set_property PACKAGE_PIN C41 [get_ports {c0_ddr3_dq[17]}]

# PadFunction: IO_L14P_T2_SRCC_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[18]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[18]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[18]}]
set_property PACKAGE_PIN D39 [get_ports {c0_ddr3_dq[18]}]

# PadFunction: IO_L14N_T2_SRCC_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[19]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[19]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[19]}]
set_property PACKAGE_PIN D40 [get_ports {c0_ddr3_dq[19]}]

# PadFunction: IO_L16N_T2_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[20]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[20]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[20]}]
set_property PACKAGE_PIN B42 [get_ports {c0_ddr3_dq[20]}]

# PadFunction: IO_L16P_T2_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[21]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[21]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[21]}]
set_property PACKAGE_PIN B39 [get_ports {c0_ddr3_dq[21]}]

# PadFunction: IO_L17N_T2_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[22]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[22]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[22]}]
set_property PACKAGE_PIN B40 [get_ports {c0_ddr3_dq[22]}]

# PadFunction: IO_L18P_T2_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[23]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[23]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[23]}]
set_property PACKAGE_PIN A39 [get_ports {c0_ddr3_dq[23]}]

# PadFunction: IO_L20P_T3_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[24]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[24]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[24]}]
set_property PACKAGE_PIN C43 [get_ports {c0_ddr3_dq[24]}]

# PadFunction: IO_L20N_T3_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[25]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[25]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[25]}]
set_property PACKAGE_PIN C44 [get_ports {c0_ddr3_dq[25]}]

# PadFunction: IO_L22P_T3_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[26]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[26]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[26]}]
set_property PACKAGE_PIN F43 [get_ports {c0_ddr3_dq[26]}]

# PadFunction: IO_L22N_T3_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[27]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[27]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[27]}]
set_property PACKAGE_PIN F44 [get_ports {c0_ddr3_dq[27]}]

# PadFunction: IO_L23P_T3_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[28]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[28]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[28]}]
set_property PACKAGE_PIN E41 [get_ports {c0_ddr3_dq[28]}]

# PadFunction: IO_L23N_T3_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[29]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[29]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[29]}]
set_property PACKAGE_PIN E42 [get_ports {c0_ddr3_dq[29]}]

# PadFunction: IO_L24P_T3_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[30]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[30]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[30]}]
set_property PACKAGE_PIN F42 [get_ports {c0_ddr3_dq[30]}]

# PadFunction: IO_L24N_T3_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[31]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[31]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[31]}]
set_property PACKAGE_PIN E43 [get_ports {c0_ddr3_dq[31]}]

# PadFunction: IO_L1N_T0_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[32]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[32]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[32]}]
set_property PACKAGE_PIN P36 [get_ports {c0_ddr3_dq[32]}]

# PadFunction: IO_L2P_T0_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[33]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[33]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[33]}]
set_property PACKAGE_PIN N36 [get_ports {c0_ddr3_dq[33]}]

# PadFunction: IO_L2N_T0_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[34]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[34]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[34]}]
set_property PACKAGE_PIN N37 [get_ports {c0_ddr3_dq[34]}]

# PadFunction: IO_L4P_T0_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[35]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[35]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[35]}]
set_property PACKAGE_PIN N38 [get_ports {c0_ddr3_dq[35]}]

# PadFunction: IO_L4N_T0_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[36]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[36]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[36]}]
set_property PACKAGE_PIN N39 [get_ports {c0_ddr3_dq[36]}]

# PadFunction: IO_L5P_T0_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[37]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[37]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[37]}]
set_property PACKAGE_PIN R36 [get_ports {c0_ddr3_dq[37]}]

# PadFunction: IO_L5N_T0_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[38]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[38]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[38]}]
set_property PACKAGE_PIN R37 [get_ports {c0_ddr3_dq[38]}]

# PadFunction: IO_L6P_T0_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[39]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[39]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[39]}]
set_property PACKAGE_PIN M39 [get_ports {c0_ddr3_dq[39]}]

# PadFunction: IO_L7N_T1_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[40]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[40]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[40]}]
set_property PACKAGE_PIN T40 [get_ports {c0_ddr3_dq[40]}]

# PadFunction: IO_L8P_T1_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[41]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[41]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[41]}]
set_property PACKAGE_PIN N41 [get_ports {c0_ddr3_dq[41]}]

# PadFunction: IO_L8N_T1_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[42]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[42]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[42]}]
set_property PACKAGE_PIN M41 [get_ports {c0_ddr3_dq[42]}]

# PadFunction: IO_L10P_T1_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[43]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[43]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[43]}]
set_property PACKAGE_PIN P41 [get_ports {c0_ddr3_dq[43]}]

# PadFunction: IO_L10N_T1_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[44]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[44]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[44]}]
set_property PACKAGE_PIN N42 [get_ports {c0_ddr3_dq[44]}]

# PadFunction: IO_L11P_T1_SRCC_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[45]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[45]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[45]}]
set_property PACKAGE_PIN P39 [get_ports {c0_ddr3_dq[45]}]

# PadFunction: IO_L11N_T1_SRCC_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[46]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[46]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[46]}]
set_property PACKAGE_PIN P40 [get_ports {c0_ddr3_dq[46]}]

# PadFunction: IO_L12P_T1_MRCC_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[47]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[47]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[47]}]
set_property PACKAGE_PIN R38 [get_ports {c0_ddr3_dq[47]}]

# PadFunction: IO_L13P_T2_MRCC_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[48]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[48]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[48]}]
set_property PACKAGE_PIN R40 [get_ports {c0_ddr3_dq[48]}]

# PadFunction: IO_L13N_T2_MRCC_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[49]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[49]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[49]}]
set_property PACKAGE_PIN R41 [get_ports {c0_ddr3_dq[49]}]

# PadFunction: IO_L14P_T2_SRCC_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[50]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[50]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[50]}]
set_property PACKAGE_PIN T42 [get_ports {c0_ddr3_dq[50]}]

# PadFunction: IO_L14N_T2_SRCC_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[51]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[51]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[51]}]
set_property PACKAGE_PIN R42 [get_ports {c0_ddr3_dq[51]}]

# PadFunction: IO_L16N_T2_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[52]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[52]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[52]}]
set_property PACKAGE_PIN T44 [get_ports {c0_ddr3_dq[52]}]

# PadFunction: IO_L17P_T2_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[53]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[53]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[53]}]
set_property PACKAGE_PIN T43 [get_ports {c0_ddr3_dq[53]}]

# PadFunction: IO_L18N_T2_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[54]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[54]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[54]}]
set_property PACKAGE_PIN R43 [get_ports {c0_ddr3_dq[54]}]

# PadFunction: IO_L16P_T2_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[55]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[55]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[55]}]
set_property PACKAGE_PIN P44 [get_ports {c0_ddr3_dq[55]}]

# PadFunction: IO_L20P_T3_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[56]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[56]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[56]}]
set_property PACKAGE_PIN P30 [get_ports {c0_ddr3_dq[56]}]

# PadFunction: IO_L20N_T3_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[57]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[57]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[57]}]
set_property PACKAGE_PIN P31 [get_ports {c0_ddr3_dq[57]}]

# PadFunction: IO_L22P_T3_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[58]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[58]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[58]}]
set_property PACKAGE_PIN T29 [get_ports {c0_ddr3_dq[58]}]

# PadFunction: IO_L22N_T3_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[59]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[59]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[59]}]
set_property PACKAGE_PIN T30 [get_ports {c0_ddr3_dq[59]}]

# PadFunction: IO_L23P_T3_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[60]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[60]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[60]}]
set_property PACKAGE_PIN R32 [get_ports {c0_ddr3_dq[60]}]

# PadFunction: IO_L23N_T3_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[61]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[61]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[61]}]
set_property PACKAGE_PIN R33 [get_ports {c0_ddr3_dq[61]}]

# PadFunction: IO_L24P_T3_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[62]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[62]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[62]}]
set_property PACKAGE_PIN P33 [get_ports {c0_ddr3_dq[62]}]

# PadFunction: IO_L24N_T3_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dq[63]}]
set_property SLEW FAST [get_ports {c0_ddr3_dq[63]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c0_ddr3_dq[63]}]
set_property PACKAGE_PIN P34 [get_ports {c0_ddr3_dq[63]}]

# PadFunction: IO_L1P_T0_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[14]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[14]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[14]}]
set_property PACKAGE_PIN G39 [get_ports {c0_ddr3_addr[14]}]

# PadFunction: IO_L1N_T0_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[13]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[13]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[13]}]
set_property PACKAGE_PIN G40 [get_ports {c0_ddr3_addr[13]}]

# PadFunction: IO_L2P_T0_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[12]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[12]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[12]}]
set_property PACKAGE_PIN G34 [get_ports {c0_ddr3_addr[12]}]

# PadFunction: IO_L2N_T0_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[11]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[11]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[11]}]
set_property PACKAGE_PIN G35 [get_ports {c0_ddr3_addr[11]}]

# PadFunction: IO_L4P_T0_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[10]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[10]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[10]}]
set_property PACKAGE_PIN G36 [get_ports {c0_ddr3_addr[10]}]

# PadFunction: IO_L4N_T0_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[9]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[9]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[9]}]
set_property PACKAGE_PIN G37 [get_ports {c0_ddr3_addr[9]}]

# PadFunction: IO_L5P_T0_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[8]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[8]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[8]}]
set_property PACKAGE_PIN J38 [get_ports {c0_ddr3_addr[8]}]

# PadFunction: IO_L5N_T0_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[7]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[7]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[7]}]
set_property PACKAGE_PIN H38 [get_ports {c0_ddr3_addr[7]}]

# PadFunction: IO_L6P_T0_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[6]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[6]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[6]}]
set_property PACKAGE_PIN H36 [get_ports {c0_ddr3_addr[6]}]

# PadFunction: IO_L6N_T0_VREF_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[5]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[5]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[5]}]
set_property PACKAGE_PIN H37 [get_ports {c0_ddr3_addr[5]}]

# PadFunction: IO_L7P_T1_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[4]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[4]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[4]}]
set_property PACKAGE_PIN G41 [get_ports {c0_ddr3_addr[4]}]

# PadFunction: IO_L7N_T1_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[3]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[3]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[3]}]
set_property PACKAGE_PIN G42 [get_ports {c0_ddr3_addr[3]}]

# PadFunction: IO_L8P_T1_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[2]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[2]}]
set_property PACKAGE_PIN L39 [get_ports {c0_ddr3_addr[2]}]

# PadFunction: IO_L8N_T1_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[1]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[1]}]
set_property PACKAGE_PIN L40 [get_ports {c0_ddr3_addr[1]}]

# PadFunction: IO_L9P_T1_DQS_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_addr[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_addr[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_addr[0]}]
set_property PACKAGE_PIN H42 [get_ports {c0_ddr3_addr[0]}]

# PadFunction: IO_L9N_T1_DQS_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_ba[2]}]
set_property SLEW FAST [get_ports {c0_ddr3_ba[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_ba[2]}]
set_property PACKAGE_PIN H43 [get_ports {c0_ddr3_ba[2]}]

# PadFunction: IO_L10P_T1_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_ba[1]}]
set_property SLEW FAST [get_ports {c0_ddr3_ba[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_ba[1]}]
set_property PACKAGE_PIN L38 [get_ports {c0_ddr3_ba[1]}]

# PadFunction: IO_L10N_T1_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_ba[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_ba[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_ba[0]}]
set_property PACKAGE_PIN K38 [get_ports {c0_ddr3_ba[0]}]

# PadFunction: IO_L11P_T1_SRCC_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_ras_n}]
set_property SLEW FAST [get_ports {c0_ddr3_ras_n}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_ras_n}]
set_property PACKAGE_PIN J41 [get_ports {c0_ddr3_ras_n}]

# PadFunction: IO_L11N_T1_SRCC_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_cas_n}]
set_property SLEW FAST [get_ports {c0_ddr3_cas_n}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_cas_n}]
set_property PACKAGE_PIN H41 [get_ports {c0_ddr3_cas_n}]

# PadFunction: IO_L12P_T1_MRCC_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_we_n}]
set_property SLEW FAST [get_ports {c0_ddr3_we_n}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_we_n}]
set_property PACKAGE_PIN K40 [get_ports {c0_ddr3_we_n}]

# PadFunction: IO_L18N_T2_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_reset_n}]
set_property SLEW FAST [get_ports {c0_ddr3_reset_n}]
set_property IOSTANDARD LVCMOS15 [get_ports {c0_ddr3_reset_n}]
set_property PACKAGE_PIN A40 [get_ports {c0_ddr3_reset_n}]

# PadFunction: IO_L15P_T2_DQS_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_cke[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_cke[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_cke[0]}]
set_property PACKAGE_PIN L43 [get_ports {c0_ddr3_cke[0]}]

# PadFunction: IO_L15N_T2_DQS_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_odt[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_odt[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_odt[0]}]
set_property PACKAGE_PIN K43 [get_ports {c0_ddr3_odt[0]}]

# PadFunction: IO_L12N_T1_MRCC_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_cs_n[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_cs_n[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_cs_n[0]}]
set_property PACKAGE_PIN J40 [get_ports {c0_ddr3_cs_n[0]}]

# PadFunction: IO_L1P_T0_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dm[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_dm[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[0]}]
set_property PACKAGE_PIN B35 [get_ports {c0_ddr3_dm[0]}]

# PadFunction: IO_L7P_T1_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dm[1]}]
set_property SLEW FAST [get_ports {c0_ddr3_dm[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[1]}]
set_property PACKAGE_PIN E36 [get_ports {c0_ddr3_dm[1]}]

# PadFunction: IO_L17P_T2_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dm[2]}]
set_property SLEW FAST [get_ports {c0_ddr3_dm[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[2]}]
set_property PACKAGE_PIN C42 [get_ports {c0_ddr3_dm[2]}]

# PadFunction: IO_L19P_T3_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dm[3]}]
set_property SLEW FAST [get_ports {c0_ddr3_dm[3]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[3]}]
set_property PACKAGE_PIN F40 [get_ports {c0_ddr3_dm[3]}]

# PadFunction: IO_L1P_T0_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dm[4]}]
set_property SLEW FAST [get_ports {c0_ddr3_dm[4]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[4]}]
set_property PACKAGE_PIN P35 [get_ports {c0_ddr3_dm[4]}]

# PadFunction: IO_L7P_T1_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dm[5]}]
set_property SLEW FAST [get_ports {c0_ddr3_dm[5]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[5]}]
set_property PACKAGE_PIN T39 [get_ports {c0_ddr3_dm[5]}]

# PadFunction: IO_L18P_T2_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dm[6]}]
set_property SLEW FAST [get_ports {c0_ddr3_dm[6]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[6]}]
set_property PACKAGE_PIN U44 [get_ports {c0_ddr3_dm[6]}]

# PadFunction: IO_L19P_T3_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dm[7]}]
set_property SLEW FAST [get_ports {c0_ddr3_dm[7]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[7]}]
set_property PACKAGE_PIN T33 [get_ports {c0_ddr3_dm[7]}]

# PadFunction: IO_L3P_T0_DQS_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_p[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[0]}]
set_property PACKAGE_PIN D35 [get_ports {c0_ddr3_dqs_p[0]}]

# PadFunction: IO_L3N_T0_DQS_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_n[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[0]}]
set_property PACKAGE_PIN D36 [get_ports {c0_ddr3_dqs_n[0]}]

# PadFunction: IO_L9P_T1_DQS_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_p[1]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[1]}]
set_property PACKAGE_PIN F38 [get_ports {c0_ddr3_dqs_p[1]}]

# PadFunction: IO_L9N_T1_DQS_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_n[1]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[1]}]
set_property PACKAGE_PIN F39 [get_ports {c0_ddr3_dqs_n[1]}]

# PadFunction: IO_L15P_T2_DQS_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_p[2]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[2]}]
set_property PACKAGE_PIN B41 [get_ports {c0_ddr3_dqs_p[2]}]

# PadFunction: IO_L15N_T2_DQS_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_n[2]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[2]}]
set_property PACKAGE_PIN A42 [get_ports {c0_ddr3_dqs_n[2]}]

# PadFunction: IO_L21P_T3_DQS_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_p[3]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[3]}]
set_property PACKAGE_PIN D43 [get_ports {c0_ddr3_dqs_p[3]}]

# PadFunction: IO_L21N_T3_DQS_22 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_n[3]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[3]}]
set_property PACKAGE_PIN D44 [get_ports {c0_ddr3_dqs_n[3]}]

# PadFunction: IO_L3P_T0_DQS_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_p[4]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[4]}]
set_property PACKAGE_PIN T35 [get_ports {c0_ddr3_dqs_p[4]}]

# PadFunction: IO_L3N_T0_DQS_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_n[4]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[4]}]
set_property PACKAGE_PIN R35 [get_ports {c0_ddr3_dqs_n[4]}]

# PadFunction: IO_L9P_T1_DQS_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_p[5]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[5]}]
set_property PACKAGE_PIN T37 [get_ports {c0_ddr3_dqs_p[5]}]

# PadFunction: IO_L9N_T1_DQS_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_n[5]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[5]}]
set_property PACKAGE_PIN T38 [get_ports {c0_ddr3_dqs_n[5]}]

# PadFunction: IO_L15P_T2_DQS_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_p[6]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[6]}]
set_property PACKAGE_PIN P43 [get_ports {c0_ddr3_dqs_p[6]}]

# PadFunction: IO_L15N_T2_DQS_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_n[6]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[6]}]
set_property PACKAGE_PIN N43 [get_ports {c0_ddr3_dqs_n[6]}]

# PadFunction: IO_L21P_T3_DQS_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_p[7]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_p[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_p[7]}]
set_property PACKAGE_PIN R30 [get_ports {c0_ddr3_dqs_p[7]}]

# PadFunction: IO_L21N_T3_DQS_20 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_dqs_n[7]}]
set_property SLEW FAST [get_ports {c0_ddr3_dqs_n[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c0_ddr3_dqs_n[7]}]
set_property PACKAGE_PIN R31 [get_ports {c0_ddr3_dqs_n[7]}]

# PadFunction: IO_L3P_T0_DQS_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_ck_p[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_ck_p[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {c0_ddr3_ck_p[0]}]
set_property PACKAGE_PIN J39 [get_ports {c0_ddr3_ck_p[0]}]

# PadFunction: IO_L3N_T0_DQS_21 
set_property VCCAUX_IO HIGH [get_ports {c0_ddr3_ck_n[0]}]
set_property SLEW FAST [get_ports {c0_ddr3_ck_n[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {c0_ddr3_ck_n[0]}]
set_property PACKAGE_PIN H39 [get_ports {c0_ddr3_ck_n[0]}]

# DDR3 calibration complete LED (eb_ta1a1_1_LED01)
set_property IOSTANDARD LVCMOS15 [get_ports c0_calib_complete]
set_property PACKAGE_PIN K36 [get_ports c0_calib_complete]

# Pin and IO property

#-----------------------------------------------------------
#              MIG-TA2                                         -
#-----------------------------------------------------------

# PadFunction: IO_L1N_T0_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[0]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[0]}]
set_property PACKAGE_PIN BD33 [get_ports {c1_ddr3_dq[0]}]

# PadFunction: IO_L2P_T0_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[1]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[1]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[1]}]
set_property PACKAGE_PIN BC31 [get_ports {c1_ddr3_dq[1]}]

# PadFunction: IO_L2N_T0_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[2]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[2]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[2]}]
set_property PACKAGE_PIN BC32 [get_ports {c1_ddr3_dq[2]}]

# PadFunction: IO_L4P_T0_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[3]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[3]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[3]}]
set_property PACKAGE_PIN BA32 [get_ports {c1_ddr3_dq[3]}]

# PadFunction: IO_L4N_T0_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[4]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[4]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[4]}]
set_property PACKAGE_PIN BA33 [get_ports {c1_ddr3_dq[4]}]

# PadFunction: IO_L5P_T0_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[5]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[5]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[5]}]
set_property PACKAGE_PIN BD30 [get_ports {c1_ddr3_dq[5]}]

# PadFunction: IO_L5N_T0_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[6]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[6]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[6]}]
set_property PACKAGE_PIN BD31 [get_ports {c1_ddr3_dq[6]}]

# PadFunction: IO_L6P_T0_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[7]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[7]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[7]}]
set_property PACKAGE_PIN BA30 [get_ports {c1_ddr3_dq[7]}]

# PadFunction: IO_L7N_T1_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[8]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[8]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[8]}]
set_property PACKAGE_PIN AY33 [get_ports {c1_ddr3_dq[8]}]

# PadFunction: IO_L10P_T1_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[9]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[9]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[9]}]
set_property PACKAGE_PIN AW30 [get_ports {c1_ddr3_dq[9]}]

# PadFunction: IO_L10N_T1_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[10]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[10]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[10]}]
set_property PACKAGE_PIN AY30 [get_ports {c1_ddr3_dq[10]}]

# PadFunction: IO_L8P_T1_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[11]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[11]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[11]}]
set_property PACKAGE_PIN AV31 [get_ports {c1_ddr3_dq[11]}]

# PadFunction: IO_L8N_T1_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[12]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[12]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[12]}]
set_property PACKAGE_PIN AW31 [get_ports {c1_ddr3_dq[12]}]

# PadFunction: IO_L11P_T1_SRCC_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[13]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[13]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[13]}]
set_property PACKAGE_PIN AU32 [get_ports {c1_ddr3_dq[13]}]

# PadFunction: IO_L11N_T1_SRCC_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[14]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[14]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[14]}]
set_property PACKAGE_PIN AV32 [get_ports {c1_ddr3_dq[14]}]

# PadFunction: IO_L12P_T1_MRCC_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[15]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[15]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[15]}]
set_property PACKAGE_PIN AU30 [get_ports {c1_ddr3_dq[15]}]

# PadFunction: IO_L13P_T2_MRCC_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[16]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[16]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[16]}]
set_property PACKAGE_PIN AP31 [get_ports {c1_ddr3_dq[16]}]

# PadFunction: IO_L13N_T2_MRCC_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[17]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[17]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[17]}]
set_property PACKAGE_PIN AR31 [get_ports {c1_ddr3_dq[17]}]

# PadFunction: IO_L14P_T2_SRCC_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[18]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[18]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[18]}]
set_property PACKAGE_PIN AR32 [get_ports {c1_ddr3_dq[18]}]

# PadFunction: IO_L14N_T2_SRCC_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[19]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[19]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[19]}]
set_property PACKAGE_PIN AT32 [get_ports {c1_ddr3_dq[19]}]

# PadFunction: IO_L17N_T2_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[20]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[20]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[20]}]
set_property PACKAGE_PIN AT30 [get_ports {c1_ddr3_dq[20]}]

# PadFunction: IO_L17P_T2_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[21]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[21]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[21]}]
set_property PACKAGE_PIN AP29 [get_ports {c1_ddr3_dq[21]}]

# PadFunction: IO_L18N_T2_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[22]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[22]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[22]}]
set_property PACKAGE_PIN AP30 [get_ports {c1_ddr3_dq[22]}]

# PadFunction: IO_L16P_T2_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[23]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[23]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[23]}]
set_property PACKAGE_PIN AN33 [get_ports {c1_ddr3_dq[23]}]

# PadFunction: IO_L23P_T3_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[24]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[24]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[24]}]
set_property PACKAGE_PIN AM30 [get_ports {c1_ddr3_dq[24]}]

# PadFunction: IO_L23N_T3_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[25]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[25]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[25]}]
set_property PACKAGE_PIN AM31 [get_ports {c1_ddr3_dq[25]}]

# PadFunction: IO_L22P_T3_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[26]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[26]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[26]}]
set_property PACKAGE_PIN AM29 [get_ports {c1_ddr3_dq[26]}]

# PadFunction: IO_L22N_T3_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[27]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[27]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[27]}]
set_property PACKAGE_PIN AN29 [get_ports {c1_ddr3_dq[27]}]

# PadFunction: IO_L24P_T3_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[28]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[28]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[28]}]
set_property PACKAGE_PIN AL29 [get_ports {c1_ddr3_dq[28]}]

# PadFunction: IO_L24N_T3_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[29]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[29]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[29]}]
set_property PACKAGE_PIN AL30 [get_ports {c1_ddr3_dq[29]}]

# PadFunction: IO_L20P_T3_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[30]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[30]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[30]}]
set_property PACKAGE_PIN AN31 [get_ports {c1_ddr3_dq[30]}]

# PadFunction: IO_L20N_T3_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[31]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[31]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[31]}]
set_property PACKAGE_PIN AN32 [get_ports {c1_ddr3_dq[31]}]

# PadFunction: IO_L24N_T3_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[32]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[32]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[32]}]
set_property PACKAGE_PIN AJ24 [get_ports {c1_ddr3_dq[32]}]

# PadFunction: IO_L23P_T3_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[33]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[33]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[33]}]
set_property PACKAGE_PIN AL22 [get_ports {c1_ddr3_dq[33]}]

# PadFunction: IO_L23N_T3_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[34]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[34]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[34]}]
set_property PACKAGE_PIN AM22 [get_ports {c1_ddr3_dq[34]}]

# PadFunction: IO_L22P_T3_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[35]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[35]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[35]}]
set_property PACKAGE_PIN AK23 [get_ports {c1_ddr3_dq[35]}]

# PadFunction: IO_L22N_T3_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[36]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[36]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[36]}]
set_property PACKAGE_PIN AL23 [get_ports {c1_ddr3_dq[36]}]

# PadFunction: IO_L20P_T3_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[37]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[37]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[37]}]
set_property PACKAGE_PIN AK21 [get_ports {c1_ddr3_dq[37]}]

# PadFunction: IO_L20N_T3_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[38]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[38]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[38]}]
set_property PACKAGE_PIN AK22 [get_ports {c1_ddr3_dq[38]}]

# PadFunction: IO_L19P_T3_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[39]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[39]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[39]}]
set_property PACKAGE_PIN AL24 [get_ports {c1_ddr3_dq[39]}]

# PadFunction: IO_L7N_T1_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[40]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[40]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[40]}]
set_property PACKAGE_PIN AW23 [get_ports {c1_ddr3_dq[40]}]

# PadFunction: IO_L10P_T1_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[41]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[41]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[41]}]
set_property PACKAGE_PIN AY22 [get_ports {c1_ddr3_dq[41]}]

# PadFunction: IO_L10N_T1_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[42]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[42]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[42]}]
set_property PACKAGE_PIN AY23 [get_ports {c1_ddr3_dq[42]}]

# PadFunction: IO_L8P_T1_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[43]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[43]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[43]}]
set_property PACKAGE_PIN AY25 [get_ports {c1_ddr3_dq[43]}]

# PadFunction: IO_L8N_T1_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[44]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[44]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[44]}]
set_property PACKAGE_PIN BA25 [get_ports {c1_ddr3_dq[44]}]

# PadFunction: IO_L11P_T1_SRCC_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[45]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[45]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[45]}]
set_property PACKAGE_PIN AU24 [get_ports {c1_ddr3_dq[45]}]

# PadFunction: IO_L11N_T1_SRCC_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[46]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[46]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[46]}]
set_property PACKAGE_PIN AU25 [get_ports {c1_ddr3_dq[46]}]

# PadFunction: IO_L12P_T1_MRCC_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[47]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[47]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[47]}]
set_property PACKAGE_PIN AV24 [get_ports {c1_ddr3_dq[47]}]

# PadFunction: IO_L13P_T2_MRCC_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[48]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[48]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[48]}]
set_property PACKAGE_PIN AT23 [get_ports {c1_ddr3_dq[48]}]

# PadFunction: IO_L13N_T2_MRCC_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[49]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[49]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[49]}]
set_property PACKAGE_PIN AT24 [get_ports {c1_ddr3_dq[49]}]

# PadFunction: IO_L14P_T2_SRCC_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[50]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[50]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[50]}]
set_property PACKAGE_PIN AP23 [get_ports {c1_ddr3_dq[50]}]

# PadFunction: IO_L14N_T2_SRCC_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[51]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[51]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[51]}]
set_property PACKAGE_PIN AR23 [get_ports {c1_ddr3_dq[51]}]

# PadFunction: IO_L17N_T2_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[52]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[52]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[52]}]
set_property PACKAGE_PIN AN23 [get_ports {c1_ddr3_dq[52]}]

# PadFunction: IO_L16P_T2_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[53]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[53]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[53]}]
set_property PACKAGE_PIN AN24 [get_ports {c1_ddr3_dq[53]}]

# PadFunction: IO_L18N_T2_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[54]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[54]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[54]}]
set_property PACKAGE_PIN AP24 [get_ports {c1_ddr3_dq[54]}]

# PadFunction: IO_L17P_T2_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[55]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[55]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[55]}]
set_property PACKAGE_PIN AR25 [get_ports {c1_ddr3_dq[55]}]

# PadFunction: IO_L2P_T0_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[56]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[56]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[56]}]
set_property PACKAGE_PIN BB24 [get_ports {c1_ddr3_dq[56]}]

# PadFunction: IO_L2N_T0_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[57]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[57]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[57]}]
set_property PACKAGE_PIN BC24 [get_ports {c1_ddr3_dq[57]}]

# PadFunction: IO_L4P_T0_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[58]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[58]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[58]}]
set_property PACKAGE_PIN BC23 [get_ports {c1_ddr3_dq[58]}]

# PadFunction: IO_L4N_T0_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[59]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[59]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[59]}]
set_property PACKAGE_PIN BD23 [get_ports {c1_ddr3_dq[59]}]

# PadFunction: IO_L5P_T0_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[60]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[60]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[60]}]
set_property PACKAGE_PIN BB22 [get_ports {c1_ddr3_dq[60]}]

# PadFunction: IO_L5N_T0_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[61]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[61]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[61]}]
set_property PACKAGE_PIN BC22 [get_ports {c1_ddr3_dq[61]}]

# PadFunction: IO_L1P_T0_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[62]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[62]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[62]}]
set_property PACKAGE_PIN BA24 [get_ports {c1_ddr3_dq[62]}]

# PadFunction: IO_L1N_T0_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dq[63]}]
set_property SLEW FAST [get_ports {c1_ddr3_dq[63]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {c1_ddr3_dq[63]}]
set_property PACKAGE_PIN BB25 [get_ports {c1_ddr3_dq[63]}]

# PadFunction: IO_L1P_T0_AD4P_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[14]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[14]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[14]}]
set_property PACKAGE_PIN BC26 [get_ports {c1_ddr3_addr[14]}]

# PadFunction: IO_L1N_T0_AD4N_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[13]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[13]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[13]}]
set_property PACKAGE_PIN BD26 [get_ports {c1_ddr3_addr[13]}]

# PadFunction: IO_L2P_T0_AD12P_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[12]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[12]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[12]}]
set_property PACKAGE_PIN BB29 [get_ports {c1_ddr3_addr[12]}]

# PadFunction: IO_L2N_T0_AD12N_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[11]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[11]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[11]}]
set_property PACKAGE_PIN BC29 [get_ports {c1_ddr3_addr[11]}]

# PadFunction: IO_L4P_T0_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[10]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[10]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[10]}]
set_property PACKAGE_PIN BD28 [get_ports {c1_ddr3_addr[10]}]

# PadFunction: IO_L4N_T0_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[9]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[9]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[9]}]
set_property PACKAGE_PIN BD29 [get_ports {c1_ddr3_addr[9]}]

# PadFunction: IO_L5P_T0_AD13P_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[8]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[8]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[8]}]
set_property PACKAGE_PIN BA27 [get_ports {c1_ddr3_addr[8]}]

# PadFunction: IO_L5N_T0_AD13N_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[7]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[7]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[7]}]
set_property PACKAGE_PIN BA28 [get_ports {c1_ddr3_addr[7]}]

# PadFunction: IO_L6P_T0_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[6]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[6]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[6]}]
set_property PACKAGE_PIN BC27 [get_ports {c1_ddr3_addr[6]}]

# PadFunction: IO_L6N_T0_VREF_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[5]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[5]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[5]}]
set_property PACKAGE_PIN BC28 [get_ports {c1_ddr3_addr[5]}]

# PadFunction: IO_L7P_T1_AD6P_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[4]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[4]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[4]}]
set_property PACKAGE_PIN AY28 [get_ports {c1_ddr3_addr[4]}]

# PadFunction: IO_L7N_T1_AD6N_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[3]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[3]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[3]}]
set_property PACKAGE_PIN BA29 [get_ports {c1_ddr3_addr[3]}]

# PadFunction: IO_L8P_T1_AD14P_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[2]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[2]}]
set_property PACKAGE_PIN AY26 [get_ports {c1_ddr3_addr[2]}]

# PadFunction: IO_L8N_T1_AD14N_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[1]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[1]}]
set_property PACKAGE_PIN AY27 [get_ports {c1_ddr3_addr[1]}]

# PadFunction: IO_L9P_T1_DQS_AD7P_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_addr[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_addr[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_addr[0]}]
set_property PACKAGE_PIN AW28 [get_ports {c1_ddr3_addr[0]}]

# PadFunction: IO_L9N_T1_DQS_AD7N_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_ba[2]}]
set_property SLEW FAST [get_ports {c1_ddr3_ba[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_ba[2]}]
set_property PACKAGE_PIN AW29 [get_ports {c1_ddr3_ba[2]}]

# PadFunction: IO_L10P_T1_AD15P_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_ba[1]}]
set_property SLEW FAST [get_ports {c1_ddr3_ba[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_ba[1]}]
set_property PACKAGE_PIN AV26 [get_ports {c1_ddr3_ba[1]}]

# PadFunction: IO_L10N_T1_AD15N_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_ba[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_ba[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_ba[0]}]
set_property PACKAGE_PIN AW26 [get_ports {c1_ddr3_ba[0]}]

# PadFunction: IO_L11P_T1_SRCC_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_ras_n}]
set_property SLEW FAST [get_ports {c1_ddr3_ras_n}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_ras_n}]
set_property PACKAGE_PIN AV27 [get_ports {c1_ddr3_ras_n}]

# PadFunction: IO_L11N_T1_SRCC_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_cas_n}]
set_property SLEW FAST [get_ports {c1_ddr3_cas_n}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_cas_n}]
set_property PACKAGE_PIN AV28 [get_ports {c1_ddr3_cas_n}]

# PadFunction: IO_L12P_T1_MRCC_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_we_n}]
set_property SLEW FAST [get_ports {c1_ddr3_we_n}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_we_n}]
set_property PACKAGE_PIN AU26 [get_ports {c1_ddr3_we_n}]

# PadFunction: IO_L16N_T2_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_reset_n}]
set_property SLEW FAST [get_ports {c1_ddr3_reset_n}]
set_property IOSTANDARD LVCMOS15 [get_ports {c1_ddr3_reset_n}]
set_property PACKAGE_PIN AP33 [get_ports {c1_ddr3_reset_n}]

# PadFunction: IO_L15P_T2_DQS_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_cke[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_cke[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_cke[0]}]
set_property PACKAGE_PIN AP28 [get_ports {c1_ddr3_cke[0]}]

# PadFunction: IO_L15N_T2_DQS_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_odt[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_odt[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_odt[0]}]
set_property PACKAGE_PIN AR28 [get_ports {c1_ddr3_odt[0]}]

# PadFunction: IO_L12N_T1_MRCC_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_cs_n[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_cs_n[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_cs_n[0]}]
set_property PACKAGE_PIN AU27 [get_ports {c1_ddr3_cs_n[0]}]

# PadFunction: IO_L1P_T0_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dm[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_dm[0]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[0]}]
set_property PACKAGE_PIN BC33 [get_ports {c1_ddr3_dm[0]}]

# PadFunction: IO_L7P_T1_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dm[1]}]
set_property SLEW FAST [get_ports {c1_ddr3_dm[1]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[1]}]
set_property PACKAGE_PIN AW33 [get_ports {c1_ddr3_dm[1]}]

# PadFunction: IO_L18P_T2_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dm[2]}]
set_property SLEW FAST [get_ports {c1_ddr3_dm[2]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[2]}]
set_property PACKAGE_PIN AR30 [get_ports {c1_ddr3_dm[2]}]

# PadFunction: IO_L19P_T3_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dm[3]}]
set_property SLEW FAST [get_ports {c1_ddr3_dm[3]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[3]}]
set_property PACKAGE_PIN AL32 [get_ports {c1_ddr3_dm[3]}]

# PadFunction: IO_L24P_T3_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dm[4]}]
set_property SLEW FAST [get_ports {c1_ddr3_dm[4]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[4]}]
set_property PACKAGE_PIN AJ23 [get_ports {c1_ddr3_dm[4]}]

# PadFunction: IO_L7P_T1_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dm[5]}]
set_property SLEW FAST [get_ports {c1_ddr3_dm[5]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[5]}]
set_property PACKAGE_PIN AV23 [get_ports {c1_ddr3_dm[5]}]

# PadFunction: IO_L18P_T2_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dm[6]}]
set_property SLEW FAST [get_ports {c1_ddr3_dm[6]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[6]}]
set_property PACKAGE_PIN AN22 [get_ports {c1_ddr3_dm[6]}]

# PadFunction: IO_L6P_T0_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dm[7]}]
set_property SLEW FAST [get_ports {c1_ddr3_dm[7]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[7]}]
set_property PACKAGE_PIN BA22 [get_ports {c1_ddr3_dm[7]}]

# PadFunction: IO_L3P_T0_DQS_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_p[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[0]}]
set_property PACKAGE_PIN BB31 [get_ports {c1_ddr3_dqs_p[0]}]

# PadFunction: IO_L3N_T0_DQS_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_n[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[0]}]
set_property PACKAGE_PIN BB32 [get_ports {c1_ddr3_dqs_n[0]}]

# PadFunction: IO_L9P_T1_DQS_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_p[1]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[1]}]
set_property PACKAGE_PIN AY31 [get_ports {c1_ddr3_dqs_p[1]}]

# PadFunction: IO_L9N_T1_DQS_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_n[1]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[1]}]
set_property PACKAGE_PIN AY32 [get_ports {c1_ddr3_dqs_n[1]}]

# PadFunction: IO_L15P_T2_DQS_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_p[2]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[2]}]
set_property PACKAGE_PIN AR33 [get_ports {c1_ddr3_dqs_p[2]}]

# PadFunction: IO_L15N_T2_DQS_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_n[2]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[2]}]
set_property PACKAGE_PIN AT33 [get_ports {c1_ddr3_dqs_n[2]}]

# PadFunction: IO_L21P_T3_DQS_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_p[3]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[3]}]
set_property PACKAGE_PIN AK30 [get_ports {c1_ddr3_dqs_p[3]}]

# PadFunction: IO_L21N_T3_DQS_36 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_n[3]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[3]}]
set_property PACKAGE_PIN AK31 [get_ports {c1_ddr3_dqs_n[3]}]

# PadFunction: IO_L21P_T3_DQS_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_p[4]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[4]}]
set_property PACKAGE_PIN AM21 [get_ports {c1_ddr3_dqs_p[4]}]

# PadFunction: IO_L21N_T3_DQS_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_n[4]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[4]}]
set_property PACKAGE_PIN AN21 [get_ports {c1_ddr3_dqs_n[4]}]

# PadFunction: IO_L9P_T1_DQS_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_p[5]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[5]}]
set_property PACKAGE_PIN AU22 [get_ports {c1_ddr3_dqs_p[5]}]

# PadFunction: IO_L9N_T1_DQS_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_n[5]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[5]}]
set_property PACKAGE_PIN AV22 [get_ports {c1_ddr3_dqs_n[5]}]

# PadFunction: IO_L15P_T2_DQS_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_p[6]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[6]}]
set_property PACKAGE_PIN AR22 [get_ports {c1_ddr3_dqs_p[6]}]

# PadFunction: IO_L15N_T2_DQS_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_n[6]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[6]}]
set_property PACKAGE_PIN AT22 [get_ports {c1_ddr3_dqs_n[6]}]

# PadFunction: IO_L3P_T0_DQS_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_p[7]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_p[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_p[7]}]
set_property PACKAGE_PIN BD24 [get_ports {c1_ddr3_dqs_p[7]}]

# PadFunction: IO_L3N_T0_DQS_34 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_dqs_n[7]}]
set_property SLEW FAST [get_ports {c1_ddr3_dqs_n[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {c1_ddr3_dqs_n[7]}]
set_property PACKAGE_PIN BD25 [get_ports {c1_ddr3_dqs_n[7]}]

# PadFunction: IO_L3P_T0_DQS_AD5P_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_ck_p[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_ck_p[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {c1_ddr3_ck_p[0]}]
set_property PACKAGE_PIN BB26 [get_ports {c1_ddr3_ck_p[0]}]

# PadFunction: IO_L3N_T0_DQS_AD5N_35 
set_property VCCAUX_IO HIGH [get_ports {c1_ddr3_ck_n[0]}]
set_property SLEW FAST [get_ports {c1_ddr3_ck_n[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {c1_ddr3_ck_n[0]}]
set_property PACKAGE_PIN BB27 [get_ports {c1_ddr3_ck_n[0]}]

set_property IOSTANDARD LVCMOS15 [get_ports c1_calib_complete]
set_property PACKAGE_PIN AM26 [get_ports c1_calib_complete]

