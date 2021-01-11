open_project esp-xilinx-zcu102-xczu9eg.xpr
update_ip_catalog
update_compile_order -fileset sources_1
reset_run impl_1
reset_run synth_1
launch_runs synth_1 -jobs 12
get_ips
wait_on_run -timeout 360 synth_1
set_msg_config -suppress -id {Drc 23-20}
launch_runs impl_1 -jobs 12
wait_on_run -timeout 360 impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run -timeout 60 impl_1
