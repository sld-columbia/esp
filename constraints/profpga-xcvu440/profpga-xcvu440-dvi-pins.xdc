# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
#-----------------------------------------------------------
#              DVI                                         -
#-----------------------------------------------------------

# {ba2_eb2_DVI_OUT_DATA_0}
set_property PACKAGE_PIN BL49 [get_ports {tft_data[0]}]

# {ba2_eb2_DVI_OUT_DATA_1}
set_property PACKAGE_PIN BN52 [get_ports {tft_data[1]}]

# {ba2_eb2_DVI_OUT_DATA_2}
set_property PACKAGE_PIN BM52 [get_ports {tft_data[2]}]

# {ba2_eb2_DVI_OUT_DATA_3}
set_property PACKAGE_PIN BM51 [get_ports {tft_data[3]}]

# {ba2_eb2_DVI_OUT_DATA_4}
set_property PACKAGE_PIN BP39 [get_ports {tft_data[4]}]

# {ba2_eb2_DVI_OUT_DATA_5}
set_property PACKAGE_PIN BN51 [get_ports {tft_data[5]}]

# {ba2_eb2_DVI_OUT_DATA_6}
set_property PACKAGE_PIN BM39 [get_ports {tft_data[6]}]

# {ba2_eb2_DVI_OUT_DATA_7}
set_property PACKAGE_PIN BL50 [get_ports {tft_data[7]}]

# {ba2_eb2_DVI_OUT_DATA_8}
set_property PACKAGE_PIN BM49 [get_ports {tft_data[8]}]

# {ba2_eb2_DVI_OUT_DATA_9}
set_property PACKAGE_PIN BN49 [get_ports {tft_data[9]}]

# {ba2_eb2_DVI_OUT_DATA_10}
set_property PACKAGE_PIN BP51 [get_ports {tft_data[10]}]

# {ba2_eb2_DVI_OUT_DATA_11}
set_property PACKAGE_PIN BP50 [get_ports {tft_data[11]}]

# {ba2_eb2_DVI_OUT_DATA_12}
set_property PACKAGE_PIN BP41 [get_ports {tft_data[12]}]

# {ba2_eb2_DVI_OUT_DATA_13}
set_property PACKAGE_PIN BP40 [get_ports {tft_data[13]}]

# {ba2_eb2_DVI_OUT_DATA_14}
set_property PACKAGE_PIN BM40 [get_ports {tft_data[14]}]

# {ba2_eb2_DVI_OUT_DATA_15}
set_property PACKAGE_PIN BM50 [get_ports {tft_data[15]}]

# {ba2_eb2_DVI_OUT_DATA_16}
set_property PACKAGE_PIN BN37 [get_ports {tft_data[16]}]

# {ba2_eb2_DVI_OUT_DATA_17}
set_property PACKAGE_PIN BM37 [get_ports {tft_data[17]}]

# {ba2_eb2_DVI_OUT_DATA_18}
set_property PACKAGE_PIN BN38 [get_ports {tft_data[18]}]

# {ba2_eb2_DVI_OUT_DATA_19}
set_property PACKAGE_PIN BN39 [get_ports {tft_data[19]}]

# {ba2_eb2_DVI_OUT_DATA_20}
set_property PACKAGE_PIN BL40 [get_ports {tft_data[20]}]

# {ba2_eb2_DVI_OUT_DATA_21}
set_property PACKAGE_PIN BL39 [get_ports {tft_data[21]}]

# {ba2_eb2_DVI_OUT_DATA_22}
set_property PACKAGE_PIN BP49 [get_ports {tft_data[22]}]

# {ba2_eb2_DVI_OUT_DATA_23}
set_property PACKAGE_PIN BP38 [get_ports {tft_data[23]}]

set_property IOSTANDARD LVCMOS18 [get_ports {tft_*}]


# {ba2_eb2_DVI_OUT_DE}
set_property PACKAGE_PIN BM10 [get_ports {tft_de}]

# {ba2_eb2_DVI_OUT_BSEL_SCL}
set_property -quiet PACKAGE_PIN BN8 [get_ports {tft_bsel}]

# {ba2_eb2_DVI_OUT_DSEL_SDA}
set_property -quiet PACKAGE_PIN BP18 [get_ports {tft_dsel}]

# {ba2_eb2_DVI_OUT_ISEL_NRST}
set_property -quiet PACKAGE_PIN BP11 [get_ports {tft_isel}]


# {ba2_eb2_DVI_OUT_IDCLK_N}
set_property -quiet PACKAGE_PIN BJ51 [get_ports {tft_clk_n}]

# {ba2_eb2_DVI_OUT_IDCLK_P}
set_property -quiet PACKAGE_PIN BH51 [get_ports {tft_clk_p}]

# {ba2_eb2_DVI_OUT_HSYNC}
set_property -quiet PACKAGE_PIN BP9 [get_ports {tft_hsync}]

# {ba2_eb2_DVI_OUT_VSYNC}
set_property -quiet PACKAGE_PIN BN9 [get_ports {tft_vsync}]

# Hot plug detect active low (nhpd). redirecting to TFP410 (htplg)
# {ba2_eb2_DVI_OUT_NHPD}
set_property -quiet PACKAGE_PIN BL17 [get_ports {tft_nhpd}]
# {ba2_eb2_DVI_OUT_EDGE}
set_property -quiet PACKAGE_PIN BM11 [get_ports {tft_edge}]


# Tie to constant
# {ba2_eb2_DVI_OUT_A3_DK3}
set_property -quiet PACKAGE_PIN BP8 [get_ports {tft_a3_dk3}]

# {ba2_eb2_DVI_OUT_CTL1_A1_DK1}
set_property -quiet PACKAGE_PIN BN11 [get_ports {tft_ctl1_a1_dk1}]

# {ba2_eb2_DVI_OUT_CTL2_A2_DK2}
set_property -quiet PACKAGE_PIN BN12 [get_ports {tft_ctl2_a2_dk2}]

# {ba2_eb2_DVI_OUT_DKEN}
set_property -quiet PACKAGE_PIN BL10 [get_ports {tft_dken}]

# {ba2_eb2_DVI_OUT_NPD}
set_property -quiet PACKAGE_PIN BP10 [get_ports {tft_npd}]


#Unused I/Os

# {ba2_eb2_DVI_OUT_NOC}
#set_property -quiet PACKAGE_PIN BN18 [get_ports {ba2_eb2_DVI_OUT_NOC}]

# {ba2_eb2_DVI_OUT_EDID_SCL}
#set_property -quiet PACKAGE_PIN BH54 [get_ports {ba2_eb2_DVI_OUT_EDID_SCL}]

# {ba2_eb2_DVI_OUT_EDID_SDA}
#set_property -quiet PACKAGE_PIN BH53 [get_ports {ba2_eb2_DVI_OUT_EDID_SDA}]

# {ba2_eb2_DVI_OUT_MSEN_PO1}
#set_property -quiet PACKAGE_PIN BK10 [get_ports {ba2_eb2_DVI_OUT_MSEN_PO1}]

