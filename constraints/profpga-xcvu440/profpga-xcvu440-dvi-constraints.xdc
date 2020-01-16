#-----------------------------------------------------------
#              DVI                                         -
#-----------------------------------------------------------

# Timing
create_clock -period 25 [get_nets -hierarchical clkvga]

set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

set_clock_groups -asynchronous -group [get_clocks $clkm_elab] -group [get_clocks clkvga]
set_clock_groups -asynchronous -group [get_clocks $refclk_elab] -group [get_clocks clkvga]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks clkvga]


