set_clock_groups -physically_exclusive -group [get_clocks dvfs_clk0*] -group [get_clocks dvfs_clk1*] -group [get_clocks dvfs_clk2*] -group [get_clocks dvfs_clk3*]

set_clock_groups -asynchronous -group [get_clocks *clk_pll_i*] -group [get_clocks dvfs_clk*]

set_clock_groups -asynchronous -group [get_clocks *mmi64*] -group [get_clocks dvfs_clk*]

# set_clock_groups -asynchronous -group [get_clocks clk_pll_i] -group [get_clocks *iserdes_clk]
# set_clock_groups -asynchronous -group [get_clocks sync_pulse] -group [get_clocks mem_refclk]

