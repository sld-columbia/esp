# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
#-----------------------------------------------------------
#              Ethernet / SGMII                            -
#-----------------------------------------------------------

set_property PACKAGE_PIN AT22 [get_ports gtrefclk_p]
set_property PACKAGE_PIN AU22 [get_ports gtrefclk_n]
set_property PACKAGE_PIN AU21 [get_ports txp]
set_property PACKAGE_PIN AV21 [get_ports txn]
set_property PACKAGE_PIN AU24 [get_ports rxp]
set_property PACKAGE_PIN AV24 [get_ports rxn]
set_property PACKAGE_PIN AV23 [get_ports emdc]
set_property PACKAGE_PIN BA21 [get_ports erst]
set_property PACKAGE_PIN AR23 [get_ports emdio]
set_property PACKAGE_PIN AR24 [get_ports eint]

#
# MDIO
#
set_property IOSTANDARD LVCMOS18 [get_ports emdc]
set_property IOSTANDARD LVCMOS18 [get_ports erst]
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

