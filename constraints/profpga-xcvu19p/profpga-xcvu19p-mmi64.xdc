# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
###################### MMI64 ###########################


# {CLK0_N}
set_property PACKAGE_PIN BY37 [get_ports {profpga_clk0_n}]
set_property IOSTANDARD LVDS [get_ports {profpga_clk0_n}]

# {CLK0_P}
set_property PACKAGE_PIN BW37 [get_ports {profpga_clk0_p}]
set_property IOSTANDARD LVDS [get_ports {profpga_clk0_p}]

# {SYNC0_N}
set_property PACKAGE_PIN CC34 [get_ports {profpga_sync0_n}]
set_property IOSTANDARD LVDS [get_ports {profpga_sync0_n}]

# {SYNC0_P}
set_property PACKAGE_PIN CB34 [get_ports {profpga_sync0_p}]
set_property IOSTANDARD LVDS [get_ports {profpga_sync0_p}]


# {DMBI_F2H_00}
set_property PACKAGE_PIN BH31 [get_ports {dmbi_f2h[0]}]

# {DMBI_F2H_01}
set_property PACKAGE_PIN BH30 [get_ports {dmbi_f2h[1]}]

# {DMBI_F2H_02}
set_property PACKAGE_PIN BJ31 [get_ports {dmbi_f2h[2]}]

# {DMBI_F2H_03}
set_property PACKAGE_PIN BJ30 [get_ports {dmbi_f2h[3]}]

# {DMBI_F2H_04}
set_property PACKAGE_PIN BE33 [get_ports {dmbi_f2h[4]}]

# {DMBI_F2H_05}
set_property PACKAGE_PIN BE32 [get_ports {dmbi_f2h[5]}]

# {DMBI_F2H_06}
set_property PACKAGE_PIN BK34 [get_ports {dmbi_f2h[6]}]

# {DMBI_F2H_07}
set_property PACKAGE_PIN BL34 [get_ports {dmbi_f2h[7]}]

# {DMBI_F2H_08}
set_property PACKAGE_PIN BF32 [get_ports {dmbi_f2h[8]}]

# {DMBI_F2H_09}
set_property PACKAGE_PIN BF31 [get_ports {dmbi_f2h[9]}]

# {DMBI_F2H_10}
set_property PACKAGE_PIN BR33 [get_ports {dmbi_f2h[10]}]

# {DMBI_F2H_11}
set_property PACKAGE_PIN BR32 [get_ports {dmbi_f2h[11]}]

# {DMBI_F2H_12}
set_property PACKAGE_PIN BM34 [get_ports {dmbi_f2h[12]}]

# {DMBI_F2H_13}
set_property PACKAGE_PIN BM33 [get_ports {dmbi_f2h[13]}]

# {DMBI_F2H_14}
set_property PACKAGE_PIN BN31 [get_ports {dmbi_f2h[14]}]

# {DMBI_F2H_15}
set_property PACKAGE_PIN BN30 [get_ports {dmbi_f2h[15]}]

# {DMBI_F2H_16}
set_property PACKAGE_PIN BP31 [get_ports {dmbi_f2h[16]}]

# {DMBI_F2H_17}
set_property PACKAGE_PIN BP30 [get_ports {dmbi_f2h[17]}]

# {DMBI_F2H_18}
set_property PACKAGE_PIN BR34 [get_ports {dmbi_f2h[18]}]

# {DMBI_F2H_19}
set_property PACKAGE_PIN BT34 [get_ports {dmbi_f2h[19]}]



# {DMBI_H2F_00}
set_property PACKAGE_PIN BT35 [get_ports {dmbi_h2f[0]}]

# {DMBI_H2F_01}
set_property PACKAGE_PIN BT36 [get_ports {dmbi_h2f[1]}]

# {DMBI_H2F_02}
set_property PACKAGE_PIN BT37 [get_ports {dmbi_h2f[2]}]

# {DMBI_H2F_03}
set_property PACKAGE_PIN BU37 [get_ports {dmbi_h2f[3]}]

# {DMBI_H2F_04}
set_property PACKAGE_PIN BT41 [get_ports {dmbi_h2f[4]}]

# {DMBI_H2F_05}
set_property PACKAGE_PIN BU41 [get_ports {dmbi_h2f[5]}]

# {DMBI_H2F_06}
set_property PACKAGE_PIN BT39 [get_ports {dmbi_h2f[6]}]

# {DMBI_H2F_07}
set_property PACKAGE_PIN BT40 [get_ports {dmbi_h2f[7]}]

# {DMBI_H2F_08}
set_property PACKAGE_PIN BV40 [get_ports {dmbi_h2f[8]}]

# {DMBI_H2F_09}
set_property PACKAGE_PIN BW40 [get_ports {dmbi_h2f[9]}]

# {DMBI_H2F_10}
set_property PACKAGE_PIN BU39 [get_ports {dmbi_h2f[10]}]

# {DMBI_H2F_11}
set_property PACKAGE_PIN BV39 [get_ports {dmbi_h2f[11]}]

# {DMBI_H2F_12}
set_property PACKAGE_PIN CC40 [get_ports {dmbi_h2f[12]}]

# {DMBI_H2F_13}
set_property PACKAGE_PIN CC41 [get_ports {dmbi_h2f[13]}]

# {DMBI_H2F_14}
set_property PACKAGE_PIN CB39 [get_ports {dmbi_h2f[14]}]

# {DMBI_H2F_15}
set_property PACKAGE_PIN CC39 [get_ports {dmbi_h2f[15]}]

# {DMBI_H2F_16}
set_property PACKAGE_PIN BR37 [get_ports {dmbi_h2f[16]}]

# {DMBI_H2F_17}
set_property PACKAGE_PIN BR38 [get_ports {dmbi_h2f[17]}]

# {DMBI_H2F_18}
set_property PACKAGE_PIN BV36 [get_ports {dmbi_h2f[18]}]

# {DMBI_H2F_19}
set_property PACKAGE_PIN BY35 [get_ports {dmbi_h2f[19]}]


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
set clkm4_elab [get_clocks -of_objects [get_nets clkm_4]]
set clkm5_elab [get_clocks -of_objects [get_nets clkm_5]]
set clkm6_elab [get_clocks -of_objects [get_nets clkm_6]]
set clkm7_elab [get_clocks -of_objects [get_nets clkm_7]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm1_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm2_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm3_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm4_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm5_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm6_elab]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks profpga_clk0_p] -group [get_clocks $clkm7_elab]
set_clock_groups -asynchronous -group [get_clocks $refclk_elab] -group [get_clocks -include_generated_clocks profpga_clk0_p]

