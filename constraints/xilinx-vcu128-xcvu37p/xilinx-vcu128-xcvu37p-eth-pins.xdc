# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
#-----------------------------------------------------------
#              Ethernet / SGMII                            -
#-----------------------------------------------------------

# "ENET_SGMII_CLK_N" - Bank 67 VCCO - VCC1V8 - IO_L12N_T1U_N11_GC_67
set_property PACKAGE_PIN BH27 [get_ports gtrefclk_p]
# "ENET_SGMII_CLK_N" - Bank 67 VCCO - VCC1V8 - IO_L12N_T1U_N11_GC_67
set_property PACKAGE_PIN BJ27 [get_ports gtrefclk_n]
# "ENET_SGMII_IN_P" - Bank 67 VCCO - VCC1V8 - IO_L23P_T3U_N8_67
set_property PACKAGE_PIN BG22 [get_ports txp]
# "ENET_SGMII_IN_N" - Bank 67 VCCO - VCC1V8 - IO_L23N_T3U_N9_67
set_property PACKAGE_PIN BH22 [get_ports txn]
# "ENET_SGMII_OUT_P" - # Bank 67 VCCO - VCC1V8 - IO_L21P_T3L_N4_AD8P_67
set_property PACKAGE_PIN BJ22 [get_ports rxp]
# "ENET_SGMII_OUT_N" - # Bank 67 VCCO - VCC1V8 - IO_L21N_T3L_N5_AD8N_67
set_property PACKAGE_PIN BK21 [get_ports rxn]
# "DUMMY_NC" - Bank 67 VCCO - VCC1V8 - IO_L19P_T3L_N0_DBC_AD9P_67 (required dummy input pin!)
set_property PACKAGE_PIN BL23 [get_ports edummy]

# "ENET_MDC" - # Bank 67 VCCO - VCC1V8 - IO_T1U_N12_67
set_property PACKAGE_PIN BN27 [get_ports emdc]
# "ENET_MDIO" - # Bank 67 VCCO - VCC1V8 - IO_T3U_N12_67
set_property PACKAGE_PIN BG23 [get_ports emdio]
# "ENET_PDWN_B_I_INT_B_O" - Bank 67 VCCO - VCC1V8 - IO_L24P_T3U_N10_67
set_property PACKAGE_PIN BF22 [get_ports eint]


#
# dummy
#
set_property IOSTANDARD LVCMOS18 [get_ports edummy]


#
# MDIO
#
set_property IOSTANDARD LVCMOS18 [get_ports emdc]
set_property IOSTANDARD LVCMOS18 [get_ports emdio]
set_property IOSTANDARD LVCMOS18 [get_ports eint]

#
# Reference Clock Pins
#

#IO standard has to be LVDS
set_property IOSTANDARD LVDS [get_ports gtrefclk_p]
set_property IOSTANDARD LVDS [get_ports gtrefclk_n]


#
# Receiver Pins
#

#IO standard has to be LVDS
set_property IOSTANDARD LVDS [get_ports rxp]
set_property IOSTANDARD LVDS [get_ports rxn]

# LVDS cannot have ODT set
set_property ODT {} [get_ports rxp]
set_property ODT {} [get_ports rxn]

# Transmitter Pins

# IO standard has to be LVDS
set_property IOSTANDARD LVDS [get_ports txp]
set_property IOSTANDARD LVDS [get_ports txn]

# LVDS cannot have output impedance set
set_property OUTPUT_IMPEDANCE {} [get_ports txp]
set_property OUTPUT_IMPEDANCE {} [get_ports txn]

