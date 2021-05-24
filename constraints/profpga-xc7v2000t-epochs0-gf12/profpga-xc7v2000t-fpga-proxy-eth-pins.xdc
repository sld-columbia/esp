# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
##                         ETHERNET
##-----------------------------------------------------------

#bd2_eb1_ETH1_COL_CLK_MAC_FREQ}]
set_property PACKAGE_PIN W33 [get_ports {erx_col}]
#bd2_eb1_ETH1_COL_CLK_MAC_FREQ}]
set_property IOSTANDARD LVCMOS18 [get_ports {erx_col}]

#bd2_eb1_ETH1_CRS_RGMII_SEL0}]
set_property PACKAGE_PIN W34 [get_ports {erx_crs}]
#bd2_eb1_ETH1_CRS_RGMII_SEL0}]
set_property IOSTANDARD LVCMOS18 [get_ports {erx_crs}]

#bd2_eb1_ETH1_MDC}]
set_property PACKAGE_PIN V32 [get_ports {emdc}]
#bd2_eb1_ETH1_MDC}]
set_property IOSTANDARD LVCMOS18 [get_ports {emdc}]

#bd2_eb1_ETH1_MDIO}]
set_property PACKAGE_PIN V31 [get_ports {emdio}]
#bd2_eb1_ETH1_MDIO}]
set_property IOSTANDARD LVCMOS18 [get_ports {emdio}]

#bd2_eb1_ETH1_NRESET}]
set_property PACKAGE_PIN V42 [get_ports {reset_o2}]
#bd2_eb1_ETH1_NRESET}]
set_property IOSTANDARD LVCMOS18 [get_ports {reset_o2}]

#bd2_eb1_ETH1_RX_CLK}]
set_property PACKAGE_PIN Y40 [get_ports {erx_clk}]
#bd2_eb1_ETH1_RX_CLK}]
set_property IOSTANDARD LVCMOS18 [get_ports {erx_clk}]

#bd2_eb1_ETH1_RX_DV_RCK}]
set_property PACKAGE_PIN W38 [get_ports {erx_dv}]
#bd2_eb1_ETH1_RX_DV_RCK}]
set_property IOSTANDARD LVCMOS18 [get_ports {erx_dv}]

#bd2_eb1_ETH1_RX_ER_RXDV_ER}]
set_property PACKAGE_PIN U39 [get_ports {erx_er}]
#bd2_eb1_ETH1_RX_ER_RXDV_ER}]
set_property IOSTANDARD LVCMOS18 [get_ports {erx_er}]

#bd2_eb1_ETH1_RXD0_RX0}]
set_property PACKAGE_PIN Y43 [get_ports {erxd[0]}]
#bd2_eb1_ETH1_RXD0_RX0}]
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[0]}]

#bd2_eb1_ETH1_RXD1_RX1}]
set_property PACKAGE_PIN Y42 [get_ports {erxd[1]}]
#bd2_eb1_ETH1_RXD1_RX1}]
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[1]}]

#bd2_eb1_ETH1_RXD2_RX2}]
set_property PACKAGE_PIN Y38 [get_ports {erxd[2]}]
#bd2_eb1_ETH1_RXD2_RX2}]
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[2]}]

#bd2_eb1_ETH1_RXD3_RX3}]
set_property PACKAGE_PIN Y37 [get_ports {erxd[3]}]
#bd2_eb1_ETH1_RXD3_RX3}]
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[3]}]

#bd2_eb1_ETH1_TX_CLK_RGMII_SEL1}]
set_property PACKAGE_PIN W30 [get_ports {etx_clk}]
#bd2_eb1_ETH1_TX_CLK_RGMII_SEL1}]
set_property IOSTANDARD LVCMOS18 [get_ports {etx_clk}]

#bd2_eb1_ETH1_TX_EN_TXEN_ER}]
set_property PACKAGE_PIN V37 [get_ports {etx_en}]
#bd2_eb1_ETH1_TX_EN_TXEN_ER}]
set_property IOSTANDARD LVCMOS18 [get_ports {etx_en}]

#bd2_eb1_ETH1_TX_ER}]
set_property PACKAGE_PIN V36 [get_ports {etx_er}]
#bd2_eb1_ETH1_TX_ER}]
set_property IOSTANDARD LVCMOS18 [get_ports {etx_er}]

#bd2_eb1_ETH1_TXD0_TX0}]
set_property PACKAGE_PIN V44 [get_ports {etxd[0]}]
#bd2_eb1_ETH1_TXD0_TX0}]
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[0]}]

#bd2_eb1_ETH1_TXD1_TX1}]
set_property PACKAGE_PIN V43 [get_ports {etxd[1]}]
#bd2_eb1_ETH1_TXD1_TX1}]
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[1]}]

#bd2_eb1_ETH1_TXD2_TX2}]
set_property PACKAGE_PIN Y36 [get_ports {etxd[2]}]
#bd2_eb1_ETH1_TXD2_TX2}]
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[2]}]

#bd2_eb1_ETH1_TXD3_TX3}]
set_property PACKAGE_PIN Y35 [get_ports {etxd[3]}]
#bd2_eb1_ETH1_TXD3_TX3}]
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[3]}]
