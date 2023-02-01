# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
###################### MMI64 ###########################


# {CLK_N_0}
set_property PACKAGE_PIN AF40 [get_ports {profpga_clk0_n}]
set_property IOSTANDARD LVDS [get_ports {profpga_clk0_n}]

# {CLK_P_0}
set_property PACKAGE_PIN AE40 [get_ports {profpga_clk0_p}]
set_property IOSTANDARD LVDS [get_ports {profpga_clk0_p}]

# {SYNC_N_0}
set_property PACKAGE_PIN AB36 [get_ports {profpga_sync0_n}]
set_property IOSTANDARD LVDS [get_ports {profpga_sync0_n}]

# {SYNC_P_0}
set_property PACKAGE_PIN AB35 [get_ports {profpga_sync0_p}]
set_property IOSTANDARD LVDS [get_ports {profpga_sync0_p}]


# {DMBI_F2H_00}
set_property PACKAGE_PIN AH31 [get_ports {dmbi_f2h[0]}]

# {DMBI_F2H_01}
set_property PACKAGE_PIN AG31 [get_ports {dmbi_f2h[1]}]

# {DMBI_F2H_02}
set_property PACKAGE_PIN AJ30 [get_ports {dmbi_f2h[2]}]

# {DMBI_F2H_03}
set_property PACKAGE_PIN AJ29 [get_ports {dmbi_f2h[3]}]

# {DMBI_F2H_04}
set_property PACKAGE_PIN AF30 [get_ports {dmbi_f2h[4]}]

# {DMBI_F2H_05}
set_property PACKAGE_PIN AF29 [get_ports {dmbi_f2h[5]}]

# {DMBI_F2H_06}
set_property PACKAGE_PIN AH29 [get_ports {dmbi_f2h[6]}]

# {DMBI_F2H_07}
set_property PACKAGE_PIN AE31 [get_ports {dmbi_f2h[7]}]

# {DMBI_F2H_08}
set_property PACKAGE_PIN AE30 [get_ports {dmbi_f2h[8]}]

# {DMBI_F2H_09}
set_property PACKAGE_PIN AG30 [get_ports {dmbi_f2h[9]}]

# {DMBI_F2H_10}
set_property PACKAGE_PIN AG29 [get_ports {dmbi_f2h[10]}]

# {DMBI_F2H_11}
set_property PACKAGE_PIN AG44 [get_ports {dmbi_f2h[11]}]

# {DMBI_F2H_12}
set_property PACKAGE_PIN AF44 [get_ports {dmbi_f2h[12]}]

# {DMBI_F2H_13}
set_property PACKAGE_PIN AF43 [get_ports {dmbi_f2h[13]}]

# {DMBI_F2H_14}
set_property PACKAGE_PIN AE43 [get_ports {dmbi_f2h[14]}]

# {DMBI_F2H_15}
set_property PACKAGE_PIN AH42 [get_ports {dmbi_f2h[15]}]

# {DMBI_F2H_16}
set_property PACKAGE_PIN AJ28 [get_ports {dmbi_f2h[16]}]

# {DMBI_F2H_17}
set_property PACKAGE_PIN AH28 [get_ports {dmbi_f2h[17]}]

# {DMBI_F2H_18}
set_property PACKAGE_PIN AD44 [get_ports {dmbi_f2h[18]}]

# {DMBI_F2H_19}
set_property PACKAGE_PIN AB28 [get_ports {dmbi_f2h[19]}]

set_property SLEW FAST [get_ports {dmbi_f2h[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dmbi_f2h[*]}]


# {DMBI_H2F_00}
set_property PACKAGE_PIN AF33 [get_ports {dmbi_h2f[0]}]

# {DMBI_H2F_01}
set_property PACKAGE_PIN AF34 [get_ports {dmbi_h2f[1]}]

# {DMBI_H2F_02}
set_property PACKAGE_PIN AG34 [get_ports {dmbi_h2f[2]}]

# {DMBI_H2F_03}
set_property PACKAGE_PIN AG35 [get_ports {dmbi_h2f[3]}]

# {DMBI_H2F_04}
set_property PACKAGE_PIN AE32 [get_ports {dmbi_h2f[4]}]

# {DMBI_H2F_05}
set_property PACKAGE_PIN AE33 [get_ports {dmbi_h2f[5]}]

# {DMBI_H2F_06}
set_property PACKAGE_PIN AF32 [get_ports {dmbi_h2f[6]}]

# {DMBI_H2F_07}
set_property PACKAGE_PIN AG32 [get_ports {dmbi_h2f[7]}]

# {DMBI_H2F_08}
set_property PACKAGE_PIN AF35 [get_ports {dmbi_h2f[8]}]

# {DMBI_H2F_09}
set_property PACKAGE_PIN AG41 [get_ports {dmbi_h2f[9]}]

# {DMBI_H2F_10}
set_property PACKAGE_PIN AH41 [get_ports {dmbi_h2f[10]}]

# {DMBI_H2F_11}
set_property PACKAGE_PIN AE37 [get_ports {dmbi_h2f[11]}]

# {DMBI_H2F_12}
set_property PACKAGE_PIN AE38 [get_ports {dmbi_h2f[12]}]

# {DMBI_H2F_13}
set_property PACKAGE_PIN AH39 [get_ports {dmbi_h2f[13]}]

# {DMBI_H2F_14}
set_property PACKAGE_PIN AF37 [get_ports {dmbi_h2f[14]}]

# {DMBI_H2F_15}
set_property PACKAGE_PIN AF38 [get_ports {dmbi_h2f[15]}]

# {DMBI_H2F_16}
set_property PACKAGE_PIN AG39 [get_ports {dmbi_h2f[16]}]

# {DMBI_H2F_17}
set_property PACKAGE_PIN AE35 [get_ports {dmbi_h2f[17]}]

# {DMBI_H2F_18}
set_property PACKAGE_PIN AE36 [get_ports {dmbi_h2f[18]}]

# {DMBI_H2F_19}
set_property PACKAGE_PIN AA35 [get_ports {dmbi_h2f[19]}]

set_property IOSTANDARD LVCMOS18 [get_ports {dmbi_h2f[*]}]


################### MMI64 Timing #######################

create_clock -period 10.000 [get_ports {profpga_clk0_p}]

# mmi and the rest of the desing are asynchronous
set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set clkm2_elab [get_clocks -of_objects [get_nets clkm_2]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

set_clock_groups -asynchronous -group [get_clocks profpga_clk0_p] -group [get_clocks $clkm_elab]
set_clock_groups -asynchronous -group [get_clocks profpga_clk0_p] -group [get_clocks $clkm2_elab]
set_clock_groups -asynchronous -group [get_clocks $clkm2_elab] -group [get_clocks *clk_mmi64]
set_clock_groups -asynchronous -group [get_clocks $clkm_elab] -group [get_clocks *clk_mmi64]
set_clock_groups -asynchronous -group [get_clocks clk_nobuf] -group [get_clocks *clk_mmi64]

#set_max_delay -from [all_registers -clock profpga_clk0_p ] -to [all_registers -clock sys_clk  ] 4 -datapath_only
#set_max_delay -from [all_registers -clock sys_clk  ] -to [all_registers -clock profpga_clk0_p ] 4 -datapath_only

set_input_delay  -clock profpga_clk0_p 0 [get_ports profpga_sync0_p ]

set_property IODELAY_GROUP IODELAY_MMI64 [get_cells */U_PROFPGA_CTRL/PHY/G_MUXDEMUX[*].u_demux/*I_idelay]
set_property IODELAY_GROUP IODELAY_MMI64 [get_cells */U_PROFPGA_CTRL/*IDEALAYCTRL_INST]
