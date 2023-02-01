# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#                         ETHERNET
#-----------------------------------------------------------

# {bb1_eb1_ETH2_NRESET}
set_property PACKAGE_PIN N28 [get_ports reset_o2]
set_property IOSTANDARD LVCMOS18 [get_ports reset_o2]

# {bb1_eb1_ETH2_RX_CLK}
set_property PACKAGE_PIN L33 [get_ports erx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports erx_clk]

# {bb1_eb1_ETH2_TX_CLK_RGMII_SEL1}
set_property PACKAGE_PIN N27 [get_ports etx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports etx_clk]

# {bb1_eb1_ETH2_CRS_RGMII_SEL0}
set_property PACKAGE_PIN M35 [get_ports erx_crs]
set_property IOSTANDARD LVCMOS18 [get_ports erx_crs]

# {bb1_eb1_ETH2_RX_DV_RCK}
set_property PACKAGE_PIN L32 [get_ports erx_dv]
set_property IOSTANDARD LVCMOS18 [get_ports erx_dv]

# {bb1_eb1_ETH2_COL_CLK_MAC_FREQ}
set_property PACKAGE_PIN L35 [get_ports erx_col]
set_property IOSTANDARD LVCMOS18 [get_ports erx_col]

# {bb1_eb1_ETH2_RX_ER_RXDV_ER}
set_property PACKAGE_PIN H36 [get_ports erx_er]
set_property IOSTANDARD LVCMOS18 [get_ports erx_er]

# {bb1_eb1_ETH2_RXD0_RX0}
set_property PACKAGE_PIN K37 [get_ports erxd[0]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[0]]

# {bb1_eb1_ETH2_RXD1_RX1}
set_property PACKAGE_PIN L37 [get_ports erxd[1]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[1]]

# {bb1_eb1_ETH2_RXD2_RX2}
set_property PACKAGE_PIN G37 [get_ports erxd[2]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[2]]

# {bb1_eb1_ETH2_RXD3_RX3}
set_property PACKAGE_PIN H37 [get_ports erxd[3]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[3]]

# {bb1_eb1_ETH2_RXD4}
#set_property PACKAGE_PIN J36 [get_ports erxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[4]]

# {bb1_eb1_ETH2_RXD5}
#set_property PACKAGE_PIN K36 [get_ports erxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[5]]

# {bb1_eb1_ETH2_RXD6}
#set_property PACKAGE_PIN F38 [get_ports erxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[6]]

# {bb1_eb1_ETH2_RXD7}
#set_property PACKAGE_PIN F37 [get_ports erxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[7]]

# {bb1_eb1_ETH2_TX_EN_TXEN_ER}
set_property PACKAGE_PIN N38 [get_ports etx_en]
set_property IOSTANDARD LVCMOS18 [get_ports etx_en]

# {bb1_eb1_ETH2_TX_ER}
set_property PACKAGE_PIN P38 [get_ports etx_er]
set_property IOSTANDARD LVCMOS18 [get_ports etx_er]

# {bb1_eb1_ETH2_MDC}
set_property PACKAGE_PIN M39 [get_ports emdc]
set_property IOSTANDARD LVCMOS18 [get_ports emdc]

# {bb1_eb1_ETH2_MDIO}
set_property PACKAGE_PIN N39 [get_ports emdio]
set_property IOSTANDARD LVCMOS18 [get_ports emdio]

# {bb1_eb1_ETH2_TXD0_TX0}
set_property PACKAGE_PIN M36 [get_ports etxd[0]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[0]]

# {bb1_eb1_ETH2_TXD1_TX1}
set_property PACKAGE_PIN N36 [get_ports etxd[1]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[1]]

# {bb1_eb1_ETH2_TXD2_TX2}
set_property PACKAGE_PIN P36 [get_ports etxd[2]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[2]]

# {bb1_eb1_ETH2_TXD3_TX3}
set_property PACKAGE_PIN R36 [get_ports etxd[3]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[3]]

# {bb1_eb1_ETH2_TXD4}
#set_property PACKAGE_PIN P35 [get_ports etxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[4]]

# {bb1_eb1_ETH2_TXD5}
#set_property PACKAGE_PIN R35 [get_ports etxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[5]]

# {bb1_eb1_ETH2_TXD6}
#set_property PACKAGE_PIN M37 [get_ports etxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[6]]

# {bb1_eb1_ETH2_TXD7}
#set_property PACKAGE_PIN N37 [get_ports etxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[7]]

# {bb1_eb1_ETH2_GTX_CLK_TCK}
#set_property PACKAGE_PIN G36 [get_ports GTX_CLK]
#set_property IOSTANDARD LVCMOS18 [get_ports GTX_CLK]

# {bb1_eb1_ETH2_NINTERRUPT}
#set_property PACKAGE_PIN L30 [get_ports INT]
#set_property IOSTANDARD LVCMOS18 [get_ports INT]

# {bb1_eb1_ETH2_CLK_TO_MAC}
#set_property PACKAGE_PIN P29 [get_ports MCLK]
#set_property IOSTANDARD LVCMOS18 [get_ports MCLK]


