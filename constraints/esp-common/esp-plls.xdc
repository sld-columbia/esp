# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
#TODO: Fix these constraints for all FPGA boards

set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

set_clock_groups -physically_exclusive -group [get_clocks dvfs_clk0*] -group [get_clocks dvfs_clk1*] -group [get_clocks dvfs_clk2*] -group [get_clocks dvfs_clk3*]

set_clock_groups -asynchronous -group [get_clocks *${clkm_elab}*] -group [get_clocks dvfs_clk*]
set_clock_groups -asynchronous -group [get_clocks *${refclk_elab}*] -group [get_clocks dvfs_clk*]

set_clock_groups -asynchronous -group [get_clocks *mmi64*] -group [get_clocks dvfs_clk*]

# set_clock_groups -asynchronous -group [get_clocks *${clkm_elab}*] -group [get_clocks *iserdes_clk]
# set_clock_groups -asynchronous -group [get_clocks sync_pulse] -group [get_clocks mem_refclk]

