# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
# Configure ZYNQ MP SoC block with AXI-to-AHB-L adapter

set AHBDW [lindex $argv 0]

# Create block design
create_bd_design "zynqmpsoc"

# ZYNQ MP SoC PS
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 zynq_ultra_ps_e_0
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]
set_property -dict [list \
			CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.333333} \
			CONFIG.PSU__MAXIGP0__DATA_WIDTH {32} \
			CONFIG.PSU__USE__S_AXI_GP0 {1} \
			CONFIG.PSU__SAXIGP0__DATA_WIDTH $AHBDW \
			CONFIG.PSU__USE__M_AXI_GP1 {0} \
			CONFIG.PSU__USE__IRQ0 {0} \
			CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {75} \
		       ] [get_bd_cells zynq_ultra_ps_e_0]

# AXI-to-AHB-L
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ahblite_bridge:3.0 axi_ahblite_bridge_0
connect_bd_intf_net [get_bd_intf_pins axi_ahblite_bridge_0/AXI4] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]
set_property -dict [list \
			CONFIG.C_S_AXI_SUPPORTS_NARROW_BURST {1} \
		       ] [get_bd_cells axi_ahblite_bridge_0]
make_bd_intf_pins_external  [get_bd_intf_pins axi_ahblite_bridge_0/M_AHB]

# AHB-L-to-AXI
create_bd_cell -type ip -vlnv xilinx.com:ip:ahblite_axi_bridge:3.0 ahblite_axi_bridge_0
set_property -dict [list \
			CONFIG.C_S_AHB_DATA_WIDTH $AHBDW \
			CONFIG.C_M_AXI_DATA_WIDTH $AHBDW \
		       ] [get_bd_cells ahblite_axi_bridge_0]
connect_bd_intf_net [get_bd_intf_pins ahblite_axi_bridge_0/M_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC0_FPD]
make_bd_intf_pins_external  [get_bd_intf_pins ahblite_axi_bridge_0/AHB_INTERFACE]

# Connect clock and reset
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/zynq_ultra_ps_e_0/pl_clk0 (75 MHz)} Freq {75} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/zynq_ultra_ps_e_0/pl_clk0 (75 MHz)} Freq {75} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins ahblite_axi_bridge_0/s_ahb_hclk]
make_bd_pins_external  [get_bd_pins rst_ps8_0_75M/peripheral_reset]
create_bd_port -dir O -type clk pl_clk0
connect_bd_net [get_bd_pins /zynq_ultra_ps_e_0/pl_clk0] [get_bd_ports pl_clk0]

# Map address space A53 Master, ESP slave (4GB)
assign_bd_address [get_bd_addr_segs {M_AHB_0/Reg }]
set_property offset 0x0400000000 [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_M_AHB_0_Reg}]
set_property range 4G [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_M_AHB_0_Reg}]

# Map address space ESP Master, PS-side DDR4 Slave (1GB)
exclude_bd_addr_seg [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_HIGH] -target_address_space [get_bd_addr_spaces AHB_INTERFACE_0]
exclude_bd_addr_seg [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_LPS_OCM] -target_address_space [get_bd_addr_spaces AHB_INTERFACE_0]
exclude_bd_addr_seg [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_PCIE_LOW] -target_address_space [get_bd_addr_spaces AHB_INTERFACE_0]
exclude_bd_addr_seg [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_QSPI] -target_address_space [get_bd_addr_spaces AHB_INTERFACE_0]
assign_bd_address [get_bd_addr_segs {zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_LOW }]
set_property offset 0x40000000 [get_bd_addr_segs {AHB_INTERFACE_0/SEG_zynq_ultra_ps_e_0_HPC0_DDR_LOW}]
set_property range 1G [get_bd_addr_segs {AHB_INTERFACE_0/SEG_zynq_ultra_ps_e_0_HPC0_DDR_LOW}]

# Add ILA
create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0
set_property -dict [list \
			CONFIG.C_NUM_MONITOR_SLOTS {2} \
			CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:ahblite_rtl:2.0} \
			CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:ahblite_rtl:2.0} \
		       ] [get_bd_cells system_ila_0]
connect_bd_net [get_bd_pins system_ila_0/clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_intf_net [get_bd_intf_pins system_ila_0/SLOT_1_AHBLITE] [get_bd_intf_pins ahblite_axi_bridge_0/AHB_INTERFACE]
connect_bd_intf_net [get_bd_intf_pins system_ila_0/SLOT_0_AHBLITE] [get_bd_intf_pins axi_ahblite_bridge_0/M_AHB]

# Dummy GPIO device connected to dip switches (workaroud for bug in generating device tree)
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {dip_switches_8bits ( DIP switches ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_gpio_0/GPIO]
set_property location {3 681 -15} [get_bd_cells axi_gpio_0]
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP1 {1} CONFIG.PSU__MAXIGP1__DATA_WIDTH {32}] [get_bd_cells zynq_ultra_ps_e_0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD} Slave {/axi_gpio_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_gpio_0/S_AXI]


# Save
save_bd_design
close_bd_design [get_bd_designs zynqmpsoc]
