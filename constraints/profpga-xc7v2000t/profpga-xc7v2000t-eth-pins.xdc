
#-----------------------------------------------------------
#                         ETHERNET
#-----------------------------------------------------------

# {eb_ta4a4_1_ETH1_NRESET}
set_property PACKAGE_PIN AU15 [get_ports reset_o2]
set_property IOSTANDARD LVCMOS18 [get_ports reset_o2]

# {eb_ta4a4_1_ETH1_RX_CLK}
set_property PACKAGE_PIN AV16 [get_ports erx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports erx_clk]

# {eb_ta4a4_1_ETH1_TX_CLK_RGMII_SEL1}
set_property PACKAGE_PIN AV19 [get_ports etx_clk]
set_property IOSTANDARD LVCMOS18 [get_ports etx_clk]

# {eb_ta4a4_1_ETH1_CRS_RGMII_SEL0}
set_property PACKAGE_PIN BB19 [get_ports erx_crs]
set_property IOSTANDARD LVCMOS18 [get_ports erx_crs]

# {eb_ta4a4_1_ETH1_RX_DV_RCK}
set_property PACKAGE_PIN AW16 [get_ports erx_dv]
set_property IOSTANDARD LVCMOS18 [get_ports erx_dv]

# {eb_ta4a4_1_ETH1_COL_CLK_MAC_FREQ}
set_property PACKAGE_PIN BA19 [get_ports erx_col]
set_property IOSTANDARD LVCMOS18 [get_ports erx_col]

# {eb_ta4a4_1_ETH1_RX_ER_RXDV_ER}
set_property PACKAGE_PIN BD21 [get_ports erx_er]
set_property IOSTANDARD LVCMOS18 [get_ports erx_er]

# {eb_ta4a4_1_ETH1_RXD0_RX0}
set_property PACKAGE_PIN BC21 [get_ports erxd[0]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[0]]

# {eb_ta4a4_1_ETH1_RXD1_RX1}]
set_property PACKAGE_PIN BB21 [get_ports erxd[1]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[1]]

# eb_ta4a4_1_ETH1_RXD2_RX2}
set_property PACKAGE_PIN BB20 [get_ports erxd[2]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[2]]

# {eb_ta4a4_1_ETH1_RXD3_RX3}
set_property PACKAGE_PIN BA20 [get_ports erxd[3]]
set_property IOSTANDARD LVCMOS18 [get_ports erxd[3]]

# {eb_ta4a4_1_ETH1_RXD4}
#set_property PACKAGE_PIN BD18 [get_ports erxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[4]]

# {eb_ta4a4_1_ETH1_RXD5}
#set_property PACKAGE_PIN BC18 [get_ports erxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[5]]

# {eb_ta4a4_1_ETH1_RXD6}
#set_property PACKAGE_PIN BD19 [get_ports erxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[6]]

# {eb_ta4a4_1_ETH1_RXD7}
#set_property PACKAGE_PIN BC19 [get_ports erxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports erxd[7]]

# {eb_ta4a4_1_ETH1_TX_EN_TXEN_ER}
set_property PACKAGE_PIN AL17 [get_ports etx_en]
set_property IOSTANDARD LVCMOS18 [get_ports etx_en]

# {eb_ta4a4_1_ETH1_TX_ER}
set_property PACKAGE_PIN AK17 [get_ports etx_er]
set_property IOSTANDARD LVCMOS18 [get_ports etx_er]

# {eb_ta4a4_1_ETH1_MDC}
set_property PACKAGE_PIN AN19 [get_ports emdc]
set_property IOSTANDARD LVCMOS18 [get_ports emdc]

# {eb_ta4a4_1_ETH1_MDIO}
set_property PACKAGE_PIN AM20 [get_ports emdio]
set_property IOSTANDARD LVCMOS18 [get_ports emdio]

# {eb_ta4a4_1_ETH1_TXD0_TX0}
set_property PACKAGE_PIN AL18 [get_ports etxd[0]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[0]]

# {eb_ta4a4_1_ETH1_TXD1_TX1}
set_property PACKAGE_PIN AK18 [get_ports etxd[1]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[1]]

# {eb_ta4a4_1_ETH1_TXD2_TX2}
set_property PACKAGE_PIN AM19 [get_ports etxd[2]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[2]]

# {eb_ta4a4_1_ETH1_TXD3_TX3}
set_property PACKAGE_PIN AL19 [get_ports etxd[3]]
set_property IOSTANDARD LVCMOS18 [get_ports etxd[3]]

# {eb_ta4a4_1_ETH1_TXD4}
#set_property PACKAGE_PIN AL20 [get_ports etxd[4]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[4]]

# {eb_ta4a4_1_ETH1_TXD5}
#set_property PACKAGE_PIN AK20 [get_ports etxd[5]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[5]]

# {eb_ta4a4_1_ETH1_TXD6}
#set_property PACKAGE_PIN AJ19 [get_ports etxd[6]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[6]]

# {eb_ta4a4_1_ETH1_TXD7}
#set_property PACKAGE_PIN AJ20 [get_ports etxd[7]]
#set_property IOSTANDARD LVCMOS18 [get_ports etxd[7]]

# {eb_ta4a4_1_ETH1_GTX_CLK_TCK}
#set_property PACKAGE_PIN BD20 [get_ports GTX_CLK]
#set_property IOSTANDARD LVCMOS18 [get_ports GTX_CLK]

# {eb_ta4a4_1_ETH1_NINTERRUPT}
#set_property PACKAGE_PIN AY16 [get_ports INT]
#set_property IOSTANDARD LVCMOS18 [get_ports INT]

# {eb_ta4a4_1_ETH1_CLK_TO_MAC}
#set_property PACKAGE_PIN AT19 [get_ports MCLK]
#set_property IOSTANDARD LVCMOS18 [get_ports MCLK]


