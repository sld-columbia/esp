
###################### MMI64 ###########################
create_clock -period 10.000 [get_ports profpga_clk0_p]

# mmi and the rest of the desing are asynchronous
set_clock_groups -asynchronous -group [get_clocks profpga_clk0_p] -group [get_clocks *clk_pll_i*]
set_clock_groups -asynchronous -group [get_clocks *clk_pll_i*] -group [get_clocks *clk_mmi64]
set_clock_groups -asynchronous -group [get_clocks *clk_mmi64] -group [get_clocks *clk_pll_i*]

#set_max_delay -from [all_registers -clock profpga_clk0_p ] -to [all_registers -clock sys_clk  ] 4 -datapath_only
#set_max_delay -from [all_registers -clock sys_clk  ] -to [all_registers -clock profpga_clk0_p ] 4 -datapath_only


set_property SLEW FAST [get_ports {dmbi_f2h[*]}]
set_property IOSTANDARD LVDS [get_ports profpga_clk0_n]
set_property IOSTANDARD LVDS [get_ports profpga_clk0_p]
set_property IOSTANDARD LVDS [get_ports profpga_sync0_n]
set_property IOSTANDARD LVDS [get_ports profpga_sync0_p]
set_property IOSTANDARD LVCMOS18 [get_ports {dmbi_f2h[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dmbi_h2f[*]}]

set_property PACKAGE_PIN AK34 [get_ports profpga_clk0_p]
set_property PACKAGE_PIN AL34 [get_ports profpga_clk0_n]
set_property PACKAGE_PIN BA39 [get_ports profpga_sync0_p]
set_property PACKAGE_PIN BA40 [get_ports profpga_sync0_n]

set_input_delay -clock profpga_clk0_p 0.000 [get_ports profpga_sync0_p]

set_property PACKAGE_PIN AJ28 [get_ports {dmbi_f2h[0]}]
set_property PACKAGE_PIN AH28 [get_ports {dmbi_f2h[1]}]
set_property PACKAGE_PIN AG31 [get_ports {dmbi_f2h[2]}]
set_property PACKAGE_PIN AF30 [get_ports {dmbi_f2h[3]}]
set_property PACKAGE_PIN AK29 [get_ports {dmbi_f2h[4]}]
set_property PACKAGE_PIN AK28 [get_ports {dmbi_f2h[5]}]
set_property PACKAGE_PIN AG29 [get_ports {dmbi_f2h[6]}]
set_property PACKAGE_PIN AK30 [get_ports {dmbi_f2h[7]}]
set_property PACKAGE_PIN AJ30 [get_ports {dmbi_f2h[8]}]
set_property PACKAGE_PIN AH30 [get_ports {dmbi_f2h[9]}]
set_property PACKAGE_PIN AH29 [get_ports {dmbi_f2h[10]}]
set_property PACKAGE_PIN AL30 [get_ports {dmbi_f2h[11]}]
set_property PACKAGE_PIN AL29 [get_ports {dmbi_f2h[12]}]
set_property PACKAGE_PIN AN33 [get_ports {dmbi_f2h[13]}]
set_property PACKAGE_PIN AM33 [get_ports {dmbi_f2h[14]}]
set_property PACKAGE_PIN AM32 [get_ports {dmbi_f2h[15]}]
set_property PACKAGE_PIN AG32 [get_ports {dmbi_f2h[16]}]
set_property PACKAGE_PIN AF29 [get_ports {dmbi_f2h[17]}]
set_property PACKAGE_PIN AN34 [get_ports {dmbi_f2h[18]}]
set_property PACKAGE_PIN AU37 [get_ports {dmbi_f2h[19]}]
set_property PACKAGE_PIN AM36 [get_ports {dmbi_h2f[0]}]
set_property PACKAGE_PIN AN36 [get_ports {dmbi_h2f[1]}]
set_property PACKAGE_PIN AJ36 [get_ports {dmbi_h2f[2]}]
set_property PACKAGE_PIN AJ37 [get_ports {dmbi_h2f[3]}]
set_property PACKAGE_PIN AK37 [get_ports {dmbi_h2f[4]}]
set_property PACKAGE_PIN AL37 [get_ports {dmbi_h2f[5]}]
set_property PACKAGE_PIN AN35 [get_ports {dmbi_h2f[6]}]
set_property PACKAGE_PIN AP35 [get_ports {dmbi_h2f[7]}]
set_property PACKAGE_PIN AM37 [get_ports {dmbi_h2f[8]}]
set_property PACKAGE_PIN AG33 [get_ports {dmbi_h2f[9]}]
set_property PACKAGE_PIN AH33 [get_ports {dmbi_h2f[10]}]
set_property PACKAGE_PIN AK35 [get_ports {dmbi_h2f[11]}]
set_property PACKAGE_PIN AL35 [get_ports {dmbi_h2f[12]}]
set_property PACKAGE_PIN AJ31 [get_ports {dmbi_h2f[13]}]
set_property PACKAGE_PIN AH34 [get_ports {dmbi_h2f[14]}]
set_property PACKAGE_PIN AJ35 [get_ports {dmbi_h2f[15]}]
set_property PACKAGE_PIN AH31 [get_ports {dmbi_h2f[16]}]
set_property PACKAGE_PIN AL36 [get_ports {dmbi_h2f[17]}]
set_property PACKAGE_PIN AH35 [get_ports {dmbi_h2f[18]}]
set_property PACKAGE_PIN AM38 [get_ports {dmbi_h2f[19]}]

set_property IODELAY_GROUP IODELAY_MMI64 [get_cells {*/U_PROFPGA_CTRL/PHY/G_MUXDEMUX[*].u_demux/*I_idelay/U_IDELAYE2}]
set_property IODELAY_GROUP IODELAY_MMI64 [get_cells */U_PROFPGA_CTRL/*IDEALAYCTRL_INST]

