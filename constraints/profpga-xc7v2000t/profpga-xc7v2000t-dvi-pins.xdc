#-----------------------------------------------------------
#              DVI                                         -
#-----------------------------------------------------------

set_property IOSTANDARD LVCMOS18 [get_ports {tft_*}]

# {eb_ba2_2_DVI_OUT_DATA_*}
set_property PACKAGE_PIN AJ39 [get_ports {tft_data[0]}]
set_property PACKAGE_PIN AK41 [get_ports {tft_data[1]}]
set_property PACKAGE_PIN AJ41 [get_ports {tft_data[2]}]
set_property PACKAGE_PIN AH43 [get_ports {tft_data[3]}]
set_property PACKAGE_PIN AH33 [get_ports {tft_data[4]}]
set_property PACKAGE_PIN AH44 [get_ports {tft_data[5]}]
set_property PACKAGE_PIN AJ35 [get_ports {tft_data[6]}]
set_property PACKAGE_PIN AJ43 [get_ports {tft_data[7]}]
set_property PACKAGE_PIN AJ40 [get_ports {tft_data[8]}]
set_property PACKAGE_PIN AK40 [get_ports {tft_data[9]}]
set_property PACKAGE_PIN AK43 [get_ports {tft_data[10]}]
set_property PACKAGE_PIN AK42 [get_ports {tft_data[11]}]
set_property PACKAGE_PIN AJ34 [get_ports {tft_data[12]}]
set_property PACKAGE_PIN AJ33 [get_ports {tft_data[13]}]
set_property PACKAGE_PIN AK35 [get_ports {tft_data[14]}]
set_property PACKAGE_PIN AJ44 [get_ports {tft_data[15]}]
set_property PACKAGE_PIN AL33 [get_ports {tft_data[16]}]
set_property PACKAGE_PIN AK33 [get_ports {tft_data[17]}]
set_property PACKAGE_PIN AL34 [get_ports {tft_data[18]}]
set_property PACKAGE_PIN AM34 [get_ports {tft_data[19]}]
set_property PACKAGE_PIN AM35 [get_ports {tft_data[20]}]
set_property PACKAGE_PIN AL35 [get_ports {tft_data[21]}]
set_property PACKAGE_PIN AL40 [get_ports {tft_data[22]}]
set_property PACKAGE_PIN AH32 [get_ports {tft_data[23]}]

# {eb_ba2_2_DVI_OUT_DE}
set_property PACKAGE_PIN BA43 [get_ports {tft_de}]

# {eb_ba2_2_DVI_OUT_BSEL_SCL}
set_property -quiet PACKAGE_PIN AW43 [get_ports {tft_bsel}]

# {eb_ba2_2_DVI_OUT_DSEL_SDA}
set_property -quiet PACKAGE_PIN AJ36 [get_ports {tft_dsel}]

# {eb_ba2_2_DVI_OUT_ISEL_NRST}
set_property -quiet PACKAGE_PIN AY41 [get_ports {tft_isel}]


# {eb_ba2_2_DVI_OUT_IDCLK_N}
set_property -quiet PACKAGE_PIN AT40 [get_ports {tft_clk_n}]

# {eb_ba2_2_DVI_OUT_IDCLK_P}
set_property -quiet PACKAGE_PIN AT39 [get_ports {tft_clk_p}]

# {eb_ba1a1_1_DVI_OUT_HSYNC}
set_property -quiet PACKAGE_PIN AW41 [get_ports {tft_hsync}]

# {eb_ba1a1_1_DVI_OUT_VSYNC}
set_property -quiet PACKAGE_PIN AW40 [get_ports {tft_vsync}]

# Hot plug detect active low (nhpd). redirecting to TFP410 (htplg)
# {eb_ba2_2_DVI_OUT_NHPD}
set_property -quiet PACKAGE_PIN AH38 [get_ports {tft_nhpd}]
# {eb_ba2_2_DVI_OUT_EDGE}
set_property -quiet PACKAGE_PIN AY43 [get_ports {tft_edge}]


# Tie to constant
# {eb_ba2_2_DVI_OUT_A3_DK3}
set_property -quiet PACKAGE_PIN AW44 [get_ports {tft_a3_dk3}]

# {eb_ba2_2_DVI_OUT_CTL1_A1_DK1}
set_property -quiet PACKAGE_PIN BB42 [get_ports {tft_ctl1_a1_dk1}]

# {eb_ba2_2_DVI_OUT_CTL2_A2_DK2}
set_property -quiet PACKAGE_PIN BA42 [get_ports {tft_ctl2_a2_dk2}]

# {eb_ba2_2_DVI_OUT_DKEN}
set_property -quiet PACKAGE_PIN BB44 [get_ports {tft_dken}]

# {eb_ba2_2_DVI_OUT_NPD}
set_property -quiet PACKAGE_PIN AY42 [get_ports {tft_npd}]


#Unused I/Os

# {eb_ba2_2_DVI_OUT_NOC}
#set_property -quiet PACKAGE_PIN AH36 [get_ports {eb_ba2_2_DVI_OUT_NOC}]

# {eb_ba2_2_DVI_OUT_EDID_SCL}
#set_property -quiet PACKAGE_PIN AP36 [get_ports {eb_ba2_2_DVI_OUT_EDID_SCL}]

# {eb_ba2_2_DVI_OUT_EDID_SDA}
#set_property -quiet PACKAGE_PIN AN36 [get_ports {eb_ba2_2_DVI_OUT_EDID_SDA}]

# {eb_ba2_2_DVI_OUT_MSEN_PO1}
#set_property -quiet PACKAGE_PIN BA44 [get_ports {eb_ba2_2_DVI_OUT_MSEN_PO1}]

