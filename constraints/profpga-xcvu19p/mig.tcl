# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name mig

set_property -dict [list CONFIG.C0.DDR4_isCustom {true}] [get_ips mig]
set_property -dict [list CONFIG.C0.DDR4_CustomParts "[pwd]/mig/mig.csv"] [get_ips mig]

set_property -dict [list \
                        CONFIG.C0.DDR4_TimePeriod {1600} \
                        CONFIG.C0.DDR4_InputClockPeriod {11200} \
                        CONFIG.C0.DDR4_MemoryPart {EB-PDS-DDR4-R5_MT40A2G8FSE-083E} \
                        CONFIG.C0.DDR4_DataWidth {72} \
                        CONFIG.C0.DDR4_CasLatency {16} \
			CONFIG.C0.DDR4_Ordering {Strict} \
			CONFIG.C0.DDR4_Mem_Add_Map {BANK_ROW_COLUMN}] [get_ips mig]
