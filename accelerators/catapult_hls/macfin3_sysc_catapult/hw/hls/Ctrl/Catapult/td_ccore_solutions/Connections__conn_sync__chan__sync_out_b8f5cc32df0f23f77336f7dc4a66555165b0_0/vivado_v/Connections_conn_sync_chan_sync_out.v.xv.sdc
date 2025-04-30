# written for flow package Vivado 
set sdc_version 1.7 

create_clock -name ccs_MIO_clk -period 5.0 -waveform { 0.0 2.5 } [get_ports {ccs_MIO_clk}]
set_clock_uncertainty 0.0 [get_clocks {ccs_MIO_clk}]

create_clock -name virtual_io_clk -period 5.0
## IO TIMING CONSTRAINTS
set_output_delay -clock [get_clocks {ccs_MIO_clk}] 0.0 [get_ports {this_vld}]
set_input_delay -clock [get_clocks {ccs_MIO_clk}] 0.0 [get_ports {this_rdy}]
set_input_delay -clock [get_clocks {ccs_MIO_clk}] 0.0 [get_ports {ccs_ccore_start_rsc_dat}]
set_max_delay 5.0 -from [all_inputs] -to [all_outputs]
set_output_delay -clock [get_clocks {ccs_MIO_clk}] 0.0 [get_ports {ccs_ccore_done_sync_vld}]

