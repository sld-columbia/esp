# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
###################### MMI64 ###########################


# {CLK_N_0}
set_property PACKAGE_PIN BE28 [get_ports {profpga_clk0_n}]
set_property IOSTANDARD LVDS [get_ports {profpga_clk0_n}]

# {CLK_P_0}
set_property PACKAGE_PIN BD28 [get_ports {profpga_clk0_p}]
set_property IOSTANDARD LVDS [get_ports {profpga_clk0_p}]

# {SYNC_N_0}
set_property PACKAGE_PIN BF29 [get_ports {profpga_sync0_n}]
set_property IOSTANDARD LVDS [get_ports {profpga_sync0_n}]

# {SYNC_P_0}
set_property PACKAGE_PIN BF28 [get_ports {profpga_sync0_p}]
set_property IOSTANDARD LVDS [get_ports {profpga_sync0_p}]


# {DMBI_F2H_00}
set_property PACKAGE_PIN AB45 [get_ports {dmbi_f2h[0]}]

# {DMBI_F2H_01}
set_property PACKAGE_PIN AB46 [get_ports {dmbi_f2h[1]}]

# {DMBI_F2H_02}
set_property PACKAGE_PIN AC46 [get_ports {dmbi_f2h[2]}]

# {DMBI_F2H_03}
set_property PACKAGE_PIN AC47 [get_ports {dmbi_f2h[3]}]

# {DMBI_F2H_04}
set_property PACKAGE_PIN AC42 [get_ports {dmbi_f2h[4]}]

# {DMBI_F2H_05}
set_property PACKAGE_PIN AC43 [get_ports {dmbi_f2h[5]}]

# {DMBI_F2H_06}
set_property PACKAGE_PIN W44 [get_ports {dmbi_f2h[6]}]

# {DMBI_F2H_07}
set_property PACKAGE_PIN W45 [get_ports {dmbi_f2h[7]}]

# {DMBI_F2H_08}
set_property PACKAGE_PIN AB41 [get_ports {dmbi_f2h[8]}]

# {DMBI_F2H_09}
set_property PACKAGE_PIN AB42 [get_ports {dmbi_f2h[9]}]

# {DMBI_F2H_10}
set_property PACKAGE_PIN AD53 [get_ports {dmbi_f2h[10]}]

# {DMBI_F2H_11}
set_property PACKAGE_PIN AC53 [get_ports {dmbi_f2h[11]}]

# {DMBI_F2H_12}
set_property PACKAGE_PIN AC49 [get_ports {dmbi_f2h[12]}]

# {DMBI_F2H_13}
set_property PACKAGE_PIN AB49 [get_ports {dmbi_f2h[13]}]

# {DMBI_F2H_14}
set_property PACKAGE_PIN AB50 [get_ports {dmbi_f2h[14]}]

# {DMBI_F2H_15}
set_property PACKAGE_PIN AA50 [get_ports {dmbi_f2h[15]}]

# {DMBI_F2H_16}
set_property PACKAGE_PIN AC51 [get_ports {dmbi_f2h[16]}]

# {DMBI_F2H_17}
set_property PACKAGE_PIN AB51 [get_ports {dmbi_f2h[17]}]

# {DMBI_F2H_18}
set_property PACKAGE_PIN AC52 [get_ports {dmbi_f2h[18]}]

# {DMBI_F2H_19}
set_property PACKAGE_PIN AB52 [get_ports {dmbi_f2h[19]}]



# {DMBI_H2F_00}
set_property PACKAGE_PIN BG26 [get_ports {dmbi_h2f[0]}]

# {DMBI_H2F_01}
set_property PACKAGE_PIN BH26 [get_ports {dmbi_h2f[1]}]

# {DMBI_H2F_02}
set_property PACKAGE_PIN BH28 [get_ports {dmbi_h2f[2]}]

# {DMBI_H2F_03}
set_property PACKAGE_PIN BJ28 [get_ports {dmbi_h2f[3]}]

# {DMBI_H2F_04}
set_property PACKAGE_PIN AV28 [get_ports {dmbi_h2f[4]}]

# {DMBI_H2F_05}
set_property PACKAGE_PIN AW28 [get_ports {dmbi_h2f[5]}]

# {DMBI_H2F_06}
set_property PACKAGE_PIN AU27 [get_ports {dmbi_h2f[6]}]

# {DMBI_H2F_07}
set_property PACKAGE_PIN AV27 [get_ports {dmbi_h2f[7]}]

# {DMBI_H2F_08}
set_property PACKAGE_PIN AW26 [get_ports {dmbi_h2f[8]}]

# {DMBI_H2F_09}
set_property PACKAGE_PIN AY26 [get_ports {dmbi_h2f[9]}]

# {DMBI_H2F_10}
set_property PACKAGE_PIN AU26 [get_ports {dmbi_h2f[10]}]

# {DMBI_H2F_11}
set_property PACKAGE_PIN AV26 [get_ports {dmbi_h2f[11]}]

# {DMBI_H2F_12}
set_property PACKAGE_PIN BA30 [get_ports {dmbi_h2f[12]}]

# {DMBI_H2F_13}
set_property PACKAGE_PIN BB30 [get_ports {dmbi_h2f[13]}]

# {DMBI_H2F_14}
set_property PACKAGE_PIN BA29 [get_ports {dmbi_h2f[14]}]

# {DMBI_H2F_15}
set_property PACKAGE_PIN BB29 [get_ports {dmbi_h2f[15]}]

# {DMBI_H2F_16}
set_property PACKAGE_PIN BF30 [get_ports {dmbi_h2f[16]}]

# {DMBI_H2F_17}
set_property PACKAGE_PIN BG30 [get_ports {dmbi_h2f[17]}]

# {DMBI_H2F_18}
set_property PACKAGE_PIN BH29 [get_ports {dmbi_h2f[18]}]

# {DMBI_H2F_19}
set_property PACKAGE_PIN BD25 [get_ports {dmbi_h2f[19]}]


# IOSTANDARD
set_property IOSTANDARD LVCMOS18 [get_ports {dmbi_f2h[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dmbi_h2f[*]}]


################### MMI64 Timing #######################

create_clock -period 10.000 [get_ports {profpga_clk0_p}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {profpga_clk0_p}]

set_input_delay  -clock profpga_clk0_p 0 [get_ports {profpga_sync0_p}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {profpga_sync0_p}]

# mmi and the rest of the desing are asynchronous
set clkm_elab [get_clocks -of_objects [get_nets {clkm}]]
set clkm1_elab [get_clocks -of_objects [get_nets clkm_1]]
set clkm2_elab [get_clocks -of_objects [get_nets clkm_2]]
set clkm3_elab [get_clocks -of_objects [get_nets clkm_3]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm1_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm2_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm3_elab]
set_clock_groups -asynchronous -group [get_clocks $refclk_elab] -group [get_clocks -include_generated_clocks profpga_clk0_p]

