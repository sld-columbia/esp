#-----------------------------------------------------------
#              DVI                                         -
#-----------------------------------------------------------

set_property IOSTANDARD LVCMOS18 [get_ports {tft_*}]

# eb_ba1a1_1_DVI_OUT_DATA_*
set_property PACKAGE_PIN R21 [get_ports {tft_data[0]}]
set_property PACKAGE_PIN N24 [get_ports {tft_data[1]}]
set_property PACKAGE_PIN P24 [get_ports {tft_data[2]}]
set_property PACKAGE_PIN T22 [get_ports {tft_data[3]}]
set_property PACKAGE_PIN J31 [get_ports {tft_data[4]}]
set_property PACKAGE_PIN R22 [get_ports {tft_data[5]}]
set_property PACKAGE_PIN K32 [get_ports {tft_data[6]}]
set_property PACKAGE_PIN T23 [get_ports {tft_data[7]}]
set_property PACKAGE_PIN P21 [get_ports {tft_data[8]}]
set_property PACKAGE_PIN P23 [get_ports {tft_data[9]}]
set_property PACKAGE_PIN N21 [get_ports {tft_data[10]}]
set_property PACKAGE_PIN N22 [get_ports {tft_data[11]}]
set_property PACKAGE_PIN H32 [get_ports {tft_data[12]}]
set_property PACKAGE_PIN H31 [get_ports {tft_data[13]}]
set_property PACKAGE_PIN K33 [get_ports {tft_data[14]}]
set_property PACKAGE_PIN R23 [get_ports {tft_data[15]}]
set_property PACKAGE_PIN J30 [get_ports {tft_data[16]}]
set_property PACKAGE_PIN K30 [get_ports {tft_data[17]}]
set_property PACKAGE_PIN H29 [get_ports {tft_data[18]}]
set_property PACKAGE_PIN G30 [get_ports {tft_data[19]}]
set_property PACKAGE_PIN H33 [get_ports {tft_data[20]}]
set_property PACKAGE_PIN J33 [get_ports {tft_data[21]}]
set_property PACKAGE_PIN N23 [get_ports {tft_data[22]}]
set_property PACKAGE_PIN K31 [get_ports {tft_data[23]}]

# eb_ba1a1_1_DVI_OUT_DE
set_property PACKAGE_PIN L33 [get_ports {tft_de}]

# eb_ba1a1_1_DVI_OUT_BSEL_SCL/DSEL_SDA
set_property -quiet PACKAGE_PIN N29 [get_ports {tft_bsel}]
set_property -quiet PACKAGE_PIN C33 [get_ports {tft_dsel}]

# eb_ba1a1_1_DVI_OUT_ISEL_NRST
set_property -quiet PACKAGE_PIN N32 [get_ports {tft_isel}]


# eb_ba1a1_1_DVI_OUT_IDCLK_N/P
set_property -quiet PACKAGE_PIN C28 [get_ports {tft_clk_n}]
set_property -quiet PACKAGE_PIN C27 [get_ports {tft_clk_p}]

# eb_ba1a1_1_DVI_OUT_HSYNC/VSYNC
set_property -quiet PACKAGE_PIN M31 [get_ports {tft_hsync}]
set_property -quiet PACKAGE_PIN M30 [get_ports {tft_vsync}]

# Hot plug detect active low (nhpd). redirecting to TFP410 (htplg)
set_property -quiet PACKAGE_PIN G32 [get_ports {tft_nhpd}]
set_property -quiet PACKAGE_PIN L32 [get_ports {tft_edge}]


# Tie to constant
set_property -quiet PACKAGE_PIN M29 [get_ports {tft_a3_dk3}]
set_property -quiet PACKAGE_PIN M32 [get_ports {tft_ctl1_a1_dk1}]
set_property -quiet PACKAGE_PIN N31 [get_ports {tft_ctl2_a2_dk2}]
set_property -quiet PACKAGE_PIN L30 [get_ports {tft_dken}]
set_property -quiet PACKAGE_PIN N33 [get_ports {tft_npd}]


#Unused I/Os
#set_property -quiet PACKAGE_PIN D33 [get_ports {eb_ba1a1_1_DVI_OUT_NOC}]
#set_property -quiet PACKAGE_PIN P25 [get_ports {eb_ba1a1_1_DVI_OUT_EDID_SCL}]
#set_property -quiet PACKAGE_PIN R25 [get_ports {eb_ba1a1_1_DVI_OUT_EDID_SDA}]
#set_property -quiet PACKAGE_PIN L29 [get_ports {eb_ba1a1_1_DVI_OUT_MSEN_PO1}]

