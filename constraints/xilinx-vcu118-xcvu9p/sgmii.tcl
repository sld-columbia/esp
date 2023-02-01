# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
create_ip -name gig_ethernet_pcs_pma -vendor xilinx.com -library ip -version 16.1 -module_name sgmii


set_property -dict [list \
			CONFIG.ETHERNET_BOARD_INTERFACE {sgmii_lvds} \
			CONFIG.Standard {SGMII} \
			CONFIG.Physical_Interface {LVDS} \
			CONFIG.Management_Interface {false} \
			CONFIG.LvdsRefClk {625} \
			CONFIG.Tx_In_Upper_Nibble {0} \
			CONFIG.TxLane0_Placement {DIFF_PAIR_2} \
			CONFIG.ClockSelection {Async} \
		       ] [get_ips sgmii]
