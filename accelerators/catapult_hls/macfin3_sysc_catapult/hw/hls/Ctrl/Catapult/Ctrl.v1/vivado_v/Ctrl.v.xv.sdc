# written for flow package Vivado 
set sdc_version 1.7 

create_clock -name clk -period 5.0 -waveform { 0.0 2.5 } [get_ports {clk}]
set_clock_uncertainty 0.0 [get_clocks {clk}]

create_clock -name virtual_io_clk -period 5.0
## IO TIMING CONSTRAINTS
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {acc_done}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_val}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_rdy}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_msg[*]}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_read_chnl_val}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_read_chnl_rdy}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_read_chnl_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_write_chnl_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_write_chnl_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_write_chnl_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_read_ctrl_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_read_ctrl_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_read_ctrl_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_write_ctrl_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_write_ctrl_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {dma_write_ctrl_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_out_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_out_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {conf_info_out_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {sync00_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {sync00_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {sync00_msg}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {in_wr_req_val}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {in_wr_req_rdy}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {in_wr_req_msg[*]}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {in_rd_rsp_val}]
set_input_delay -clock [get_clocks {clk}] 0.0 [get_ports {in_rd_rsp_rdy}]
set_output_delay -clock [get_clocks {clk}] 0.0 [get_ports {in_rd_rsp_msg[*]}]

