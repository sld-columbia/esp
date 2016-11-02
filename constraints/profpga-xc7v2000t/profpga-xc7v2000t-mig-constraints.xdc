##################################################################################################
## Controllers configuration:
## Memory Device: DDR3_SDRAM->Components->MT41J256m16XX-125
## Data Width: 64
## Time Period: 2500
## Data Mask: 1
##################################################################################################

#-----------------------------------------------------------
#              MIG-TA1
#-----------------------------------------------------------

set_property LOC PHASER_OUT_PHY_X0Y39 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y38 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y37 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y36 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y43 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y42 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y41 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y47 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y46 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y45 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out}]
set_property LOC PHASER_OUT_PHY_X0Y44 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out}]

set_property LOC PHASER_IN_PHY_X0Y39 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X0Y38 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X0Y37 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X0Y36 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X0Y43 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X0Y42 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X0Y41 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X0Y47 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X0Y46 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X0Y45 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X0Y44 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_in_gen.phaser_in}]

set_property LOC OUT_FIFO_X0Y39 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo}]
set_property LOC OUT_FIFO_X0Y38 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo}]
set_property LOC OUT_FIFO_X0Y37 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo}]
set_property LOC OUT_FIFO_X0Y36 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/out_fifo}]
set_property LOC OUT_FIFO_X0Y43 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo}]
set_property LOC OUT_FIFO_X0Y42 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo}]
set_property LOC OUT_FIFO_X0Y41 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo}]
set_property LOC OUT_FIFO_X0Y47 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo}]
set_property LOC OUT_FIFO_X0Y46 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo}]
set_property LOC OUT_FIFO_X0Y45 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo}]
set_property LOC OUT_FIFO_X0Y44 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/out_fifo}]

set_property LOC IN_FIFO_X0Y39 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X0Y38 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X0Y37 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X0Y36 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X0Y47 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X0Y46 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X0Y45 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X0Y44 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/in_fifo_gen.in_fifo}]


set_property LOC PHY_CONTROL_X0Y9 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/phy_control_i}]
set_property LOC PHY_CONTROL_X0Y10 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/phy_control_i}]
set_property LOC PHY_CONTROL_X0Y11 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/phy_control_i}]

set_property LOC PHASER_REF_X0Y9 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/phaser_ref_i}]
set_property LOC PHASER_REF_X0Y10 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/phaser_ref_i}]
set_property LOC PHASER_REF_X0Y11 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/phaser_ref_i}]


set_property LOC OLOGIC_X0Y493 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X0Y481 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X0Y469 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X0Y457 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X0Y593 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X0Y581 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X0Y569 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X0Y557 [get_cells  -hier -filter {NAME =~ */c0_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/*slave_ts}]


set_property LOC PLLE2_ADV_X0Y10 [get_cells -hier -filter {NAME =~ */c0_u_ddr3_infrastructure/plle2_i}]
set_property LOC MMCME2_ADV_X0Y10 [get_cells -hier -filter {NAME =~ */c0_u_ddr3_infrastructure/gen_mmcm.mmcm_i}]


#-----------------------------------------------------------
#              MIG-TA2
#-----------------------------------------------------------

set_property LOC PHASER_OUT_PHY_X1Y15 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y14 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y13 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y12 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y19 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y18 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y17 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y23 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y22 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y21 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y20 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out}]

set_property LOC PHASER_IN_PHY_X1Y15 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y14 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y13 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y12 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X1Y19 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X1Y18 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X1Y17 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y23 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y22 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y21 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y20 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_in_gen.phaser_in}]

set_property LOC OUT_FIFO_X1Y15 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo}]
set_property LOC OUT_FIFO_X1Y14 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo}]
set_property LOC OUT_FIFO_X1Y13 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo}]
set_property LOC OUT_FIFO_X1Y12 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/out_fifo}]
set_property LOC OUT_FIFO_X1Y19 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo}]
set_property LOC OUT_FIFO_X1Y18 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo}]
set_property LOC OUT_FIFO_X1Y17 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo}]
set_property LOC OUT_FIFO_X1Y23 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo}]
set_property LOC OUT_FIFO_X1Y22 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo}]
set_property LOC OUT_FIFO_X1Y21 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo}]
set_property LOC OUT_FIFO_X1Y20 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/out_fifo}]

set_property LOC IN_FIFO_X1Y15 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y14 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y13 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y12 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y23 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y22 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y21 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y20 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/in_fifo_gen.in_fifo}]

set_property LOC PHY_CONTROL_X1Y3 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/phy_control_i}]
set_property LOC PHY_CONTROL_X1Y4 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/phy_control_i}]
set_property LOC PHY_CONTROL_X1Y5 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/phy_control_i}]

set_property LOC PHASER_REF_X1Y3 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/phaser_ref_i}]
set_property LOC PHASER_REF_X1Y4 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_1.u_ddr_phy_4lanes/phaser_ref_i}]
set_property LOC PHASER_REF_X1Y5 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/phaser_ref_i}]

set_property LOC OLOGIC_X1Y193 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y181 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y169 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y157 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y293 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y281 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y269 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y257 [get_cells  -hier -filter {NAME =~ */c1_u_memc_ui_top_std/*/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/*slave_ts}]

set_property LOC PLLE2_ADV_X1Y4 [get_cells -hier -filter {NAME =~ */c1_u_ddr3_infrastructure/plle2_i}]
set_property LOC MMCME2_ADV_X1Y4 [get_cells -hier -filter {NAME =~ */c1_u_ddr3_infrastructure/gen_mmcm.mmcm_i}]

#######################################################

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hierarchical -filter {NAME =~ *ddr3_clk_ibuf/sys_clk_ibufg}]
