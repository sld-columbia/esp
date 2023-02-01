# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#                         ETHERNET
#-----------------------------------------------------------

# {eb_bb1_1_ETH2_NRESET}
set_property PACKAGE_PIN D11 [get_ports reset_o2]
set_property IOSTANDARD LVCMOS18 [get_ports reset_o2]

# {eb_bb1_1_ETH2_RX_CLK}
set_property PACKAGE_PIN E16 [get_ports erx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports erx_clk]

# {eb_bb1_1_ETH2_TX_CLK_RGMII_SEL1}
set_property PACKAGE_PIN E11 [get_ports etx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports etx_clk]

# {eb_bb1_1_ETH2_CRS_RGMII_SEL0}
set_property PACKAGE_PIN M19 [get_ports erx_crs]
set_property IOSTANDARD LVCMOS18 [get_ports erx_crs]

# {eb_bb1_1_ETH2_RX_DV_RCK}
set_property PACKAGE_PIN F15 [get_ports erx_dv]
set_property IOSTANDARD LVCMOS18 [get_ports erx_dv]

# {eb_bb1_1_ETH2_COL_CLK_MAC_FREQ}
set_property PACKAGE_PIN L19 [get_ports erx_col]
set_property IOSTANDARD LVCMOS18 [get_ports erx_col]

# {eb_bb1_1_ETH2_RX_ER_RXDV_ER}
set_property PACKAGE_PIN J18 [get_ports erx_er]
set_property IOSTANDARD LVCMOS18 [get_ports erx_er]

# {eb_bb1_1_ETH2_RXD0_RX0}
set_property PACKAGE_PIN K17 [get_ports erxd[0]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[0]]

# {eb_bb1_1_ETH2_RXD1_RX1}
set_property PACKAGE_PIN L17 [get_ports erxd[1]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[1]]

# {eb_bb1_1_ETH2_RXD2_RX2}
set_property PACKAGE_PIN L20 [get_ports erxd[2]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[2]]

# {eb_bb1_1_ETH2_RXD3_RX3}
set_property PACKAGE_PIN M20 [get_ports erxd[3]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[3]]

# {eb_bb1_1_ETH2_RXD4}
#set_property PACKAGE_PIN K18 [get_ports erxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[4]]

# {eb_bb1_1_ETH2_RXD5}
#set_property PACKAGE_PIN L18 [get_ports erxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[5]]

# {eb_bb1_1_ETH2_RXD6}
#set_property PACKAGE_PIN H19 [get_ports erxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[6]]

# {eb_bb1_1_ETH2_RXD7}
#set_property PACKAGE_PIN J19 [get_ports erxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[7]]

# {eb_bb1_1_ETH2_TX_EN_TXEN_ER}
set_property PACKAGE_PIN B19 [get_ports etx_en]
set_property IOSTANDARD LVCMOS18 [get_ports etx_en]

# {eb_bb1_1_ETH2_TX_ER}
set_property PACKAGE_PIN C19 [get_ports etx_er]
set_property IOSTANDARD LVCMOS18 [get_ports etx_er]

# {eb_bb1_1_ETH2_MDC}
set_property PACKAGE_PIN D19 [get_ports emdc]
set_property IOSTANDARD LVCMOS18 [get_ports emdc]

# {eb_bb1_1_ETH2_MDIO}
set_property PACKAGE_PIN D20 [get_ports emdio]
set_property IOSTANDARD LVCMOS18 [get_ports emdio]

# {eb_bb1_1_ETH2_TXD0_TX0}
set_property PACKAGE_PIN A18 [get_ports etxd[0]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[0]]

# {eb_bb1_1_ETH2_TXD1_TX1}
set_property PACKAGE_PIN A19 [get_ports etxd[1]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[1]]

# {eb_bb1_1_ETH2_TXD2_TX2}
set_property PACKAGE_PIN A20 [get_ports etxd[2]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[2]]

# {eb_bb1_1_ETH2_TXD3_TX3}
set_property PACKAGE_PIN B20 [get_ports etxd[3]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[3]]

# {eb_bb1_1_ETH2_TXD4}
#set_property PACKAGE_PIN B21 [get_ports etxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[4]]

# {eb_bb1_1_ETH2_TXD5}
#set_property PACKAGE_PIN C21 [get_ports etxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[5]]

# {eb_bb1_1_ETH2_TXD6}
#set_property PACKAGE_PIN C18 [get_ports etxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[6]]

# {eb_bb1_1_ETH2_TXD7}
#set_property PACKAGE_PIN D18 [get_ports etxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[7]]

# {eb_bb1_1_ETH2_GTX_CLK_TCK}
#set_property PACKAGE_PIN H18 [get_ports GTX_CLK]
#set_property IOSTANDARD LVCMOS18 [get_ports GTX_CLK]

# {eb_bb1_1_ETH2_NINTERRUPT}
#set_property PACKAGE_PIN C9 [get_ports INT]
#set_property IOSTANDARD LVCMOS18 [get_ports INT]

# {eb_bb1_1_ETH2_CLK_TO_MAC}
#set_property PACKAGE_PIN E10 [get_ports MCLK]
#set_property IOSTANDARD LVCMOS18 [get_ports MCLK]


