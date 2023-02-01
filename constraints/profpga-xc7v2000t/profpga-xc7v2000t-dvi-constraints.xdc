# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
#-----------------------------------------------------------
#              DVI                                         -
#-----------------------------------------------------------

# Timing
create_clock -period 25 [get_nets -hierarchical clkvga]

set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set clkm2_elab [get_clocks -of_objects [get_nets clkm_2]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

set_clock_groups -asynchronous -group [get_clocks $clkm_elab] -group [get_clocks clkvga]
set_clock_groups -asynchronous -group [get_clocks $clkm2_elab] -group [get_clocks clkvga]
set_clock_groups -asynchronous -group [get_clocks $refclk_elab] -group [get_clocks clkvga]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks clkvga]


