# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#                         ETHERNET
#-----------------------------------------------------------

# {ta0_eb1_ETH2_NRESET}
set_property PACKAGE_PIN G13 [get_ports reset_o2]
set_property IOSTANDARD LVCMOS18 [get_ports reset_o2]

# {ta0_eb1_ETH2_RX_CLK}
set_property PACKAGE_PIN H10 [get_ports erx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports erx_clk]

# {ta0_eb1_ETH2_TX_CLK_RGMII_SEL1}
set_property PACKAGE_PIN H13 [get_ports etx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports etx_clk]

# {ta0_eb1_ETH2_CRS_RGMII_SEL0}
set_property PACKAGE_PIN B7 [get_ports erx_crs]
set_property IOSTANDARD LVCMOS18 [get_ports erx_crs]

# {ta0_eb1_ETH2_RX_DV_RCK}
set_property PACKAGE_PIN G9 [get_ports erx_dv]
set_property IOSTANDARD LVCMOS18 [get_ports erx_dv]

# {ta0_eb1_ETH2_COL_CLK_MAC_FREQ}
set_property PACKAGE_PIN A7 [get_ports erx_col]
set_property IOSTANDARD LVCMOS18 [get_ports erx_col]

# {ta0_eb1_ETH2_RX_ER_RXDV_ER}
set_property PACKAGE_PIN F7 [get_ports erx_er]
set_property IOSTANDARD LVCMOS18 [get_ports erx_er]

# {ta0_eb1_ETH2_RXD0_RX0}
set_property PACKAGE_PIN C5 [get_ports erxd[0]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[0]]

# {ta0_eb1_ETH2_RXD1_RX1}
set_property PACKAGE_PIN D5 [get_ports erxd[1]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[1]]

# {ta0_eb1_ETH2_RXD2_RX2}
set_property PACKAGE_PIN D6 [get_ports erxd[2]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[2]]

# {ta0_eb1_ETH2_RXD3_RX3}
set_property PACKAGE_PIN D7 [get_ports erxd[3]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[3]]

# {ta0_eb1_ETH2_RXD4}
#set_property PACKAGE_PIN B6 [get_ports erxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[4]]

# {ta0_eb1_ETH2_RXD5}
#set_property PACKAGE_PIN C6 [get_ports erxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[5]]

# {ta0_eb1_ETH2_RXD6}
#set_property PACKAGE_PIN A5 [get_ports erxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[6]]

# {ta0_eb1_ETH2_RXD7}
#set_property PACKAGE_PIN A6 [get_ports erxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[7]]

# {ta0_eb1_ETH2_TX_EN_TXEN_ER}
set_property PACKAGE_PIN F1 [get_ports etx_en]
set_property IOSTANDARD LVCMOS18 [get_ports etx_en]

# {ta0_eb1_ETH2_TX_ER}
set_property PACKAGE_PIN F2 [get_ports etx_er]
set_property IOSTANDARD LVCMOS18 [get_ports etx_er]

# {ta0_eb1_ETH2_MDC}
set_property PACKAGE_PIN F4 [get_ports emdc]
set_property IOSTANDARD LVCMOS18 [get_ports emdc]

# {ta0_eb1_ETH2_MDIO}
set_property PACKAGE_PIN F5 [get_ports emdio]
set_property IOSTANDARD LVCMOS18 [get_ports emdio]

# {ta0_eb1_ETH2_TXD0_TX0}
set_property PACKAGE_PIN B4 [get_ports etxd[0]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[0]]

# {ta0_eb1_ETH2_TXD1_TX1}
set_property PACKAGE_PIN C4 [get_ports etxd[1]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[1]]

# {ta0_eb1_ETH2_TXD2_TX2}
set_property PACKAGE_PIN E2 [get_ports etxd[2]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[2]]

# {ta0_eb1_ETH2_TXD3_TX3}
set_property PACKAGE_PIN E3 [get_ports etxd[3]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[3]]

# {ta0_eb1_ETH2_TXD4}
#set_property PACKAGE_PIN C3 [get_ports etxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[4]]

# {ta0_eb1_ETH2_TXD5}
#set_property PACKAGE_PIN D3 [get_ports etxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[5]]

# {ta0_eb1_ETH2_TXD6}
#set_property PACKAGE_PIN E4 [get_ports etxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[6]]

# {ta0_eb1_ETH2_TXD7}
#set_property PACKAGE_PIN E5 [get_ports etxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[7]]

# {ta0_eb1_ETH2_GTX_CLK_TCK}
#set_property PACKAGE_PIN F6 [get_ports GTX_CLK]
#set_property IOSTANDARD LVCMOS18 [get_ports GTX_CLK]

# {ta0_eb1_ETH2_NINTERRUPT}
#set_property PACKAGE_PIN F14 [get_ports INT]
#set_property IOSTANDARD LVCMOS18 [get_ports INT]

# {ta0_eb1_ETH2_CLK_TO_MAC}
#set_property PACKAGE_PIN H15 [get_ports MCLK]
#set_property IOSTANDARD LVCMOS18 [get_ports MCLK]


