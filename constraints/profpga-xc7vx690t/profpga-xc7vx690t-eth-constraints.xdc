
#-----------------------------------------------------------
#                         ETHERNET
#-----------------------------------------------------------

create_clock -period 40.000 [get_ports erx_clk]
set_false_path -reset_path -from [get_clocks {etx_clk erx_clk}] -to [get_clocks {mmcm_ps_clk_bufg_in*}]

set_propagated_clock [get_clocks erx_clk]
set_input_delay -clock [get_clocks erx_clk] 10 [all_inputs]

create_clock -period 40.000 [get_ports etx_clk]
set_propagated_clock [get_clocks etx_clk]
set_output_delay -clock [get_clocks etx_clk] 5 [all_outputs]
set_input_delay  -clock [get_clocks etx_clk] 10 [all_inputs]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ethpads.erxc_pad/xcv2.u0/ol]

set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks {c0_* c1_*}]
set_clock_groups -asynchronous -group [get_clocks oserdes*] -group [get_clocks {etx_clk}]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks {*_dmbi* *_mmi64}]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks {clk_pll_*}]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks {clk_pll_*}]
set_clock_groups -asynchronous -group [get_clocks clk_pll_*] -group [get_clocks {etx_clk}]
