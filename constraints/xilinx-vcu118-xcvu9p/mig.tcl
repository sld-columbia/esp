# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name mig

set_property -dict [list \
			CONFIG.C0_CLOCK_BOARD_INTERFACE {default_250mhz_clk1} \
			CONFIG.C0.DDR4_TimePeriod {1600} \
			CONFIG.C0.DDR4_InputClockPeriod {4000} \
			CONFIG.C0.DDR4_CLKOUT0_DIVIDE {8} \
			CONFIG.C0.DDR4_MemoryPart {MT40A256M16GE-083E} \
			CONFIG.C0.DDR4_DataWidth {64} \
			CONFIG.C0.DDR4_DataMask {DM_NO_DBI} \
			CONFIG.C0.DDR4_Ordering {Strict} \
			CONFIG.C0.DDR4_CasLatency {9} \
			CONFIG.C0.DDR4_CasWriteLatency {9} \
			CONFIG.C0.DDR4_Mem_Add_Map {BANK_ROW_COLUMN} \
			CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {78} \
			CONFIG.C0.BANK_GROUP_WIDTH {1}\
		       ] [get_ips mig]
