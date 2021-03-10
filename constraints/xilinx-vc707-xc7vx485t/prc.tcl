# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set ip_name prc
  #source [get_property REPOSITORY [get_ipdefs *prc:1.3]]/xilinx/prc_v1_3/tcl/api.tcl -notrace
create_ip -name prc -vendor xilinx.com -library ip -module_name $ip_name
set_property -dict [list  \
            CONFIG.HAS_AXI_LITE_IF  {1} \
            CONFIG.RESET_ACTIVE_LEVEL {0} \
            CONFIG.CP_FIFO_DEPTH {16} \
            CONFIG.CP_FIFO_TYPE  {"lutram"} \
            CONFIG.CP_ARBITRATION_PROTOCOL {1} \
            CONFIG.CP_COMPRESSION {0} \
            CONFIG.CP_FAMILY     {7series} \
            CONFIG.CDC_STAGES    {2} \
             ] [get_ips $ip_name]
generate_target {all} [get_ips $ip_name]

