# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#              Ethernet / SGMII                            -
#-----------------------------------------------------------
set_property PACKAGE_PIN AH8 [get_ports gtrefclk_p]
set_property PACKAGE_PIN AH7 [get_ports gtrefclk_n]
set_property PACKAGE_PIN AN2 [get_ports txp]
set_property PACKAGE_PIN AN1 [get_ports txn]
set_property PACKAGE_PIN AM7 [get_ports rxn]
set_property PACKAGE_PIN AM8 [get_ports rxp]
set_property PACKAGE_PIN AH31 [get_ports emdc]
set_property PACKAGE_PIN AJ33 [get_ports erst]
set_property PACKAGE_PIN AK33 [get_ports emdio]
set_property PACKAGE_PIN AL31 [get_ports eint]

set_property IOSTANDARD LVCMOS18 [get_ports emdc]
set_property IOSTANDARD LVCMOS18 [get_ports erst]
set_property IOSTANDARD LVCMOS18 [get_ports emdio]
set_property IOSTANDARD LVCMOS18 [get_ports eint]

