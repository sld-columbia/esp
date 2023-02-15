# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name mig_clamshell

set_property -dict [list \
			CONFIG.C0_CLOCK_BOARD_INTERFACE {default_100mhz_clk} \
			CONFIG.C0.DDR4_Clamshell {true} \
			CONFIG.C0.DDR4_TimePeriod {1500} \
			CONFIG.C0.DDR4_InputClockPeriod {10000} \
			CONFIG.C0.DDR4_CLKOUT0_DIVIDE {9} \
			CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-075E} \
			CONFIG.C0.DDR4_DataWidth {64} \
			CONFIG.C0.DDR4_Ordering {Strict} \
			CONFIG.C0.DDR4_CasLatency {10} \
			CONFIG.C0.DDR4_CasWriteLatency {9} \
			CONFIG.C0.DDR4_Mem_Add_Map {BANK_ROW_COLUMN} \
			CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {75} \
			CONFIG.C0.BANK_GROUP_WIDTH {1} \
			CONFIG.C0.CS_WIDTH {2} \
		       ] [get_ips mig_clamshell]
