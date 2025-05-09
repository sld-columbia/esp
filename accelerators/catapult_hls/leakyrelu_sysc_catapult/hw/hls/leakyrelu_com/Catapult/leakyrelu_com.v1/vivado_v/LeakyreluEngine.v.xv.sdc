# written for flow package Vivado 
set sdc_version 1.7 

create_clock -name clk -period 5.0 -waveform { 0.0 2.5 } [get_ports {clk}]
set_clock_uncertainty 0.0 [get_clocks {clk}]

create_clock -name virtual_io_clk -period 5.0
## IO TIMING CONSTRAINTS
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {vec_in_a_val}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {vec_in_a_rdy}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {vec_in_a_msg[*]}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {vec_in_b_val}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {vec_in_b_rdy}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {vec_in_b_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {vec_out_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {vec_out_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {vec_out_msg[*]}]

