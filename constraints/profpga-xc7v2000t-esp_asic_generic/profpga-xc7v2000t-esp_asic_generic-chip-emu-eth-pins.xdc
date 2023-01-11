# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
##                         ETHERNET
##-----------------------------------------------------------
#bc1_eb1_ETH2_COL_CLK_MAC_FREQ
set_property PACKAGE_PIN M32 [get_ports erx_col]
#bc1_eb1_ETH2_COL_CLK_MAC_FREQ
set_property IOSTANDARD LVCMOS18 [get_ports erx_col]

#bc1_eb1_ETH2_CRS_RGMII_SEL0
set_property PACKAGE_PIN N31 [get_ports erx_crs]
#bc1_eb1_ETH2_CRS_RGMII_SEL0
set_property IOSTANDARD LVCMOS18 [get_ports erx_crs]

#bc1_eb1_ETH2_MDC
set_property PACKAGE_PIN D31 [get_ports emdc]
#bc1_eb1_ETH2_MDC
set_property IOSTANDARD LVCMOS18 [get_ports emdc]

#bc1_eb1_ETH2_MDIO
set_property PACKAGE_PIN E31 [get_ports emdio]
#bc1_eb1_ETH2_MDIO
set_property IOSTANDARD LVCMOS18 [get_ports emdio]

#bc1_eb1_ETH2_NRESET
set_property PACKAGE_PIN C23 [get_ports reset_o2]
#bc1_eb1_ETH2_NRESET
set_property IOSTANDARD LVCMOS18 [get_ports reset_o2]

#bc1_eb1_ETH2_RX_CLK
set_property PACKAGE_PIN C27 [get_ports erx_clk]
#bc1_eb1_ETH2_RX_CLK
set_property IOSTANDARD LVCMOS18 [get_ports erx_clk]

#bc1_eb1_ETH2_RX_DV_RCK
set_property PACKAGE_PIN D28 [get_ports erx_dv]
#bc1_eb1_ETH2_RX_DV_RCK
set_property IOSTANDARD LVCMOS18 [get_ports erx_dv]

#bc1_eb1_ETH2_RX_ER_RXDV_ER
set_property PACKAGE_PIN N29 [get_ports erx_er]
#bc1_eb1_ETH2_RX_ER_RXDV_ER
set_property IOSTANDARD LVCMOS18 [get_ports erx_er]

#bc1_eb1_ETH2_RXD0_RX0
set_property PACKAGE_PIN M31 [get_ports {erxd[0]}]
#bc1_eb1_ETH2_RXD0_RX0
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[0]}]

#bc1_eb1_ETH2_RXD1_RX1
set_property PACKAGE_PIN M30 [get_ports {erxd[1]}]
#bc1_eb1_ETH2_RXD1_RX1
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[1]}]

#bc1_eb1_ETH2_RXD2_RX2
set_property PACKAGE_PIN L33 [get_ports {erxd[2]}]
#bc1_eb1_ETH2_RXD2_RX2
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[2]}]

#bc1_eb1_ETH2_RXD3_RX3
set_property PACKAGE_PIN L32 [get_ports {erxd[3]}]
#bc1_eb1_ETH2_RXD3_RX3
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[3]}]

#bc1_eb1_ETH2_TX_CLK_RGMII_SEL1
set_property PACKAGE_PIN D23 [get_ports etx_clk]
#bc1_eb1_ETH2_TX_CLK_RGMII_SEL1
set_property IOSTANDARD LVCMOS18 [get_ports etx_clk]

#bc1_eb1_ETH2_TX_EN_TXEN_ER
set_property PACKAGE_PIN B32 [get_ports etx_en]
#bc1_eb1_ETH2_TX_EN_TXEN_ER
set_property IOSTANDARD LVCMOS18 [get_ports etx_en]

#bc1_eb1_ETH2_TX_ER
set_property PACKAGE_PIN C32 [get_ports etx_er]
#bc1_eb1_ETH2_TX_ER
set_property IOSTANDARD LVCMOS18 [get_ports etx_er]

#bc1_eb1_ETH2_TXD0_TX0
set_property PACKAGE_PIN C33 [get_ports {etxd[0]}]
#bc1_eb1_ETH2_TXD0_TX0
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[0]}]

#bc1_eb1_ETH2_TXD1_TX1
set_property PACKAGE_PIN D33 [get_ports {etxd[1]}]
#bc1_eb1_ETH2_TXD1_TX1
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[1]}]

#bc1_eb1_ETH2_TXD2_TX2
set_property PACKAGE_PIN G32 [get_ports {etxd[2]}]
#bc1_eb1_ETH2_TXD2_TX2
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[2]}]

#bc1_eb1_ETH2_TXD3_TX3
set_property PACKAGE_PIN G31 [get_ports {etxd[3]}]
#bc1_eb1_ETH2_TXD3_TX3
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[3]}]

