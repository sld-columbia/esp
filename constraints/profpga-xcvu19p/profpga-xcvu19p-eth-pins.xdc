# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#                         ETHERNET
#-----------------------------------------------------------
# {bb1_eb1_ETH1_NRESET}
set_property PACKAGE_PIN BD61 [get_ports {reset_o2}]
set_property IOSTANDARD LVCMOS18 [get_ports reset_o2]

# {bb1_eb1_ETH1_RX_CLK}
set_property PACKAGE_PIN BE59 [get_ports {erx_clk}]
set_property IOSTANDARD LVCMOS18 [get_ports erx_clk]

# {bb1_eb1_ETH1_TX_CLK_RGMII_SEL1}
set_property PACKAGE_PIN BF52 [get_ports {etx_clk}]
set_property IOSTANDARD LVCMOS18 [get_ports etx_clk]

# {bb1_eb1_ETH1_CRS_RGMII_SEL0}
set_property PACKAGE_PIN BE55 [get_ports {erx_crs}]
set_property IOSTANDARD LVCMOS18 [get_ports erx_crs]

# {bb1_eb1_ETH1_RX_DV_RCK}
set_property PACKAGE_PIN BE60 [get_ports {erx_dv}]
set_property IOSTANDARD LVCMOS18 [get_ports erx_dv]

# {bb1_eb1_ETH1_COL_CLK_MAC_FREQ}
set_property PACKAGE_PIN BE54 [get_ports {erx_col}]
set_property IOSTANDARD LVCMOS18 [get_ports erx_col]

# {bb1_eb1_ETH1_RX_ER_RXDV_ER}
set_property PACKAGE_PIN BF57 [get_ports {erx_er}]
set_property IOSTANDARD LVCMOS18 [get_ports erx_er]

# {bb1_eb1_ETH1_RXD0_RX0}
set_property PACKAGE_PIN BF56 [get_ports {erxd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[0]]

# {bb1_eb1_ETH1_RXD1_RX1}
set_property PACKAGE_PIN BF55 [get_ports {erxd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[1]]

# {bb1_eb1_ETH1_RXD2_RX2}
set_property PACKAGE_PIN BE57 [get_ports {erxd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[2]]

# {bb1_eb1_ETH1_RXD3_RX3}
set_property PACKAGE_PIN BD57 [get_ports {erxd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[3]]

# {ta0_eb1_ETH1_RXD4}
#set_property PACKAGE_PIN B6 [get_ports erxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[4]]

# {ta0_eb1_ETH1_RXD5}
#set_property PACKAGE_PIN C6 [get_ports erxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[5]]

# {ta0_eb1_ETH1_RXD6}
#set_property PACKAGE_PIN A5 [get_ports erxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[6]]

# {ta0_eb1_ETH1_RXD7}
#set_property PACKAGE_PIN A6 [get_ports erxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[7]]

# {bb1_eb1_ETH1_TX_EN_TXEN_ER}
set_property PACKAGE_PIN BG47 [get_ports {etx_en}]
set_property IOSTANDARD LVCMOS18 [get_ports etx_en]

# {bb1_eb1_ETH1_TX_ER}
set_property PACKAGE_PIN BG46 [get_ports {etx_er}]
set_property IOSTANDARD LVCMOS18 [get_ports etx_er]

# {bb1_eb1_ETH1_MDC}
set_property PACKAGE_PIN BD48 [get_ports {emdc}]
set_property IOSTANDARD LVCMOS18 [get_ports emdc]

# {bb1_eb1_ETH1_MDIO}
set_property PACKAGE_PIN BD47 [get_ports {emdio}]
set_property IOSTANDARD LVCMOS18 [get_ports emdio]

# {bb1_eb1_ETH1_TXD0_TX0}
set_property PACKAGE_PIN BH46 [get_ports {etxd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[0]]

# {bb1_eb1_ETH1_TXD1_TX1}
set_property PACKAGE_PIN BH45 [get_ports {etxd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[1]]

# {bb1_eb1_ETH1_TXD2_TX2}
set_property PACKAGE_PIN BD46 [get_ports {etxd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[2]]

# {bb1_eb1_ETH1_TXD3_TX3}
set_property PACKAGE_PIN BD45 [get_ports {etxd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[3]]

# {ta0_eb1_ETH1_TXD4}
#set_property PACKAGE_PIN C3 [get_ports etxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[4]]

# {ta0_eb1_ETH1_TXD5}
#set_property PACKAGE_PIN D3 [get_ports etxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[5]]

# {ta0_eb1_ETH1_TXD6}
#set_property PACKAGE_PIN E4 [get_ports etxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[6]]

# {ta0_eb1_ETH1_TXD7}
#set_property PACKAGE_PIN E5 [get_ports etxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[7]]

# {ta0_eb1_ETH1_GTX_CLK_TCK}
#set_property PACKAGE_PIN F6 [get_ports GTX_CLK]
#set_property IOSTANDARD LVCMOS18 [get_ports GTX_CLK]

# {ta0_eb1_ETH1_NINTERRUPT}
#set_property PACKAGE_PIN F14 [get_ports INT]
#set_property IOSTANDARD LVCMOS18 [get_ports INT]

# {ta0_eb1_ETH1_CLK_TO_MAC}
#set_property PACKAGE_PIN H15 [get_ports MCLK]
#set_property IOSTANDARD LVCMOS18 [get_ports MCLK]
