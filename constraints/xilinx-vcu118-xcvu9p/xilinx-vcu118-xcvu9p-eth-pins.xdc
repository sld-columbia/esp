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


# Reference Clock Pins

#IO standard has to be LVDS
set_property IOSTANDARD LVDS [get_ports gtrefclk_p]
set_property IOSTANDARD LVDS [get_ports gtrefclk_n]


# Receiver Pins

#IO standard has to be LVDS
set_property IOSTANDARD LVDS [get_ports rxp]
set_property IOSTANDARD LVDS [get_ports rxn]

# Equalization can be set to EQ_LEVEL0-4 based on the loss in the
# channel. EQ_NONE an invalid option
set_property EQUALIZATION EQ_LEVEL0 [get_ports rxp]
set_property EQUALIZATION EQ_LEVEL0 [get_ports rxn]

# DQS_BIAS is to be set to TRUE if internal DC biasing is used - this is recommended.
# If the signal is biased externally on the board, should be set to FALSE
# set_property DQS_BIAS TRUE [get_ports rxp]
# set_property DQS_BIAS TRUE [get_ports rxn]

# DIFF_TERM is to be set to TERM_100 if internal Diff term is used -
# this is recommended. If differential termination is external on the
# board, should be set to TERM_NONE
# set_property DIFF_TERM_ADV TERM_100 [get_ports rxp]
# set_property DIFF_TERM_ADV TERM_100 [get_ports rxn]

set_property IOSTANDARD LVCMOS18 [get_ports emdc]
set_property IOSTANDARD LVCMOS18 [get_ports erst]
set_property IOSTANDARD LVCMOS18 [get_ports emdio]
set_property IOSTANDARD LVCMOS18 [get_ports eint]


# Transmitter Pins

# IO standard has to be LVDS
set_property IOSTANDARD LVDS [get_ports txp]
set_property IOSTANDARD LVDS [get_ports txn]

# LVDS_PRE_EMPHASIS can be set to TRUE/FALSE based on loss in the line if pre-emphasis
# is desired or not. Note, if PRE -emphasis is desired, ENABLE_PRE_EMPHASIS attribute
# in TXBITSLICE needs to be set to TRUE as well.
# set_property LVDS_PRE_EMPHASIS FALSE [get_ports txn]
# set_property LVDS_PRE_EMPHASIS FALSE [get_ports txp]
