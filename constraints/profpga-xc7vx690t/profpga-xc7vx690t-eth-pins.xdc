
#-----------------------------------------------------------
#                         ETHERNET
#-----------------------------------------------------------

# PadFunction: eb_ta4_1_ETH1_NRESET
set_property PACKAGE_PIN AV35 [get_ports reset_o2]
set_property IOSTANDARD LVCMOS18 [get_ports reset_o2]

# PadFunction: eb_ta4_1_ETH1_RX_CLK
set_property PACKAGE_PIN BA31 [get_ports erx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports erx_clk]

# PadFunction: eb_ta4_1_ETH1_TX_CLK_RGMII_SEL1
set_property PACKAGE_PIN AU32 [get_ports etx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports etx_clk]

# PadFunction: eb_ta4_1_ETH1_CRS_RGMII_SEL0
set_property PACKAGE_PIN AY35 [get_ports erx_crs]
set_property IOSTANDARD LVCMOS18 [get_ports erx_crs]

# PadFunction: eb_ta4_1_ETH1_RX_DV_RCK
set_property PACKAGE_PIN AW32 [get_ports erx_dv]
set_property IOSTANDARD LVCMOS18 [get_ports erx_dv]

# PadFunction: eb_ta4_1_ETH1_COL_CLK_MAC_FREQ
set_property PACKAGE_PIN AW35 [get_ports erx_col]
set_property IOSTANDARD LVCMOS18 [get_ports erx_col]

# PadFunction: eb_ta4_1_ETH1_RX_ER_RXDV_ER
set_property PACKAGE_PIN BA34 [get_ports erx_er]
set_property IOSTANDARD LVCMOS18 [get_ports erx_er]

# PadFunction: eb_ta4_1_ETH1_RXD0_RX0
set_property PACKAGE_PIN BA35 [get_ports {erxd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[0]}]

# PadFunction: eb_ta4_1_ETH1_RXD1_RX1
set_property PACKAGE_PIN AY34 [get_ports {erxd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[1]}]

# PadFunction: eb_ta4_1_ETH1_RXD2_RX2
set_property PACKAGE_PIN AW36 [get_ports {erxd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[2]}]

# PadFunction: eb_ta4_1_ETH1_RXD3_RX3
set_property PACKAGE_PIN AV36 [get_ports {erxd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {erxd[3]}]

# PadFunction: eb_ta4_1_ETH1_RXD4
#set_property PACKAGE_PIN BB36 [get_ports erxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[4]]

# PadFunction: eb_ta4_1_ETH1_RXD5
#set_property PACKAGE_PIN BA36 [get_ports erxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[5]]

# PadFunction: eb_ta4_1_ETH1_RXD6
#set_property PACKAGE_PIN BB33 [get_ports erxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[6]]

# PadFunction: eb_ta4_1_ETH1_RXD7
#set_property PACKAGE_PIN BB32 [get_ports erxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[7]]

# PadFunction: eb_ta4_1_ETH1_TX_EN_TXEN_ER
set_property PACKAGE_PIN AP30 [get_ports etx_en]
set_property IOSTANDARD LVCMOS18 [get_ports etx_en]

# PadFunction: eb_ta4_1_ETH1_TX_ER
set_property PACKAGE_PIN AN30 [get_ports etx_er]
set_property IOSTANDARD LVCMOS18 [get_ports etx_er]

# PadFunction: eb_ta4_1_ETH1_MDC
set_property PACKAGE_PIN AR33 [get_ports emdc]
set_property IOSTANDARD LVCMOS18 [get_ports emdc]

# PadFunction: eb_ta4_1_ETH1_MDIO
set_property PACKAGE_PIN AP33 [get_ports emdio]
set_property IOSTANDARD LVCMOS18 [get_ports emdio]

# PadFunction: eb_ta4_1_ETH1_TXD0_TX0
set_property PACKAGE_PIN AT30 [get_ports {etxd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[0]}]

# PadFunction: eb_ta4_1_ETH1_TXD1_TX1
set_property PACKAGE_PIN AR30 [get_ports {etxd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[1]}]

# PadFunction: eb_ta4_1_ETH1_TXD2_TX2
set_property PACKAGE_PIN AV31 [get_ports {etxd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[2]}]

# PadFunction: eb_ta4_1_ETH1_TXD3_TX3
set_property PACKAGE_PIN AU31 [get_ports {etxd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {etxd[3]}]

# PadFunction: eb_ta4_1_ETH1_TXD4
#set_property PACKAGE_PIN AR32 [get_ports etxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[4]]

# PadFunction: eb_ta4_1_ETH1_TXD5
#set_property PACKAGE_PIN AP32 [get_ports etxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[5]]

# PadFunction: eb_ta4_1_ETH1_TXD6
#set_property PACKAGE_PIN AP31 [get_ports etxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[6]]

# PadFunction: eb_ta4_1_ETH1_TXD7
#set_property PACKAGE_PIN AN31 [get_ports etxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[7]]

# PadFunction: eb_ta4_1_ETH1_GTX_CLK_TCK
#set_property PACKAGE_PIN BB34 [get_ports GTX_CLK]
#set_property IOSTANDARD LVCMOS18 [get_ports GTX_CLK]

# PadFunction: eb_ta4_1_ETH1_NINTERRUPT
#set_property PACKAGE_PIN AW33 [get_ports INT]
#set_property IOSTANDARD LVCMOS18 [get_ports INT]

# PadFunction: eb_ta4_1_ETH1_CLK_TO_MAC
#set_property PACKAGE_PIN BA30 [get_ports MCLK]
#set_property IOSTANDARD LVCMOS18 [get_ports MCLK]



