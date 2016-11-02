#-----------------------------------------------------------
#              DVI                                         -
#-----------------------------------------------------------

# Timing
create_clock -period 25 [get_nets -hierarchical clkvga]

set_clock_groups -asynchronous -group [get_clocks clk_pll_i] -group [get_clocks clkvga]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks clkvga]


