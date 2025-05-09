# written for flow package Vivado 
set sdc_version 1.7 

create_clock -name clk -period 5.0 -waveform { 0.0 2.5 } [get_ports {clk}]
set_clock_uncertainty 0.0 [get_clocks {clk}]

create_clock -name virtual_io_clk -period 5.0
## IO TIMING CONSTRAINTS
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_val}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_rdy}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_ctrl_dma2acc_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_ctrl_dma2acc_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_ctrl_dma2acc_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_ctrl_plm2vec_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_ctrl_plm2vec_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_ctrl_plm2vec_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_ctrl_acc2dma_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_ctrl_acc2dma_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_ctrl_acc2dma_msg[*]}]

