// (c) Copyright 1995-2021 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

#include "zynqmpsoc_zynq_ultra_ps_e_0_0_sc.h"

#include "zynq_ultra_ps_e_tlm.h"

#include <map>
#include <string>

zynqmpsoc_zynq_ultra_ps_e_0_0_sc::zynqmpsoc_zynq_ultra_ps_e_0_0_sc(const sc_core::sc_module_name& nm) : sc_core::sc_module(nm), mp_impl(NULL)
{
  // configure connectivity manager
  xsc::utils::xsc_sim_manager::addInstance("zynqmpsoc_zynq_ultra_ps_e_0_0", this);

  // initialize module
  xsc::common_cpp::properties model_param_props;
  model_param_props.addLong("C_DP_USE_AUDIO", "0");
  model_param_props.addLong("C_DP_USE_VIDEO", "0");
  model_param_props.addLong("C_MAXIGP0_DATA_WIDTH", "32");
  model_param_props.addLong("C_MAXIGP1_DATA_WIDTH", "32");
  model_param_props.addLong("C_MAXIGP2_DATA_WIDTH", "32");
  model_param_props.addLong("C_SAXIGP0_DATA_WIDTH", "64");
  model_param_props.addLong("C_SAXIGP1_DATA_WIDTH", "128");
  model_param_props.addLong("C_SAXIGP2_DATA_WIDTH", "128");
  model_param_props.addLong("C_SAXIGP3_DATA_WIDTH", "128");
  model_param_props.addLong("C_SAXIGP4_DATA_WIDTH", "128");
  model_param_props.addLong("C_SAXIGP5_DATA_WIDTH", "128");
  model_param_props.addLong("C_SAXIGP6_DATA_WIDTH", "128");
  model_param_props.addLong("C_USE_DIFF_RW_CLK_GP0", "0");
  model_param_props.addLong("C_USE_DIFF_RW_CLK_GP1", "0");
  model_param_props.addLong("C_USE_DIFF_RW_CLK_GP2", "0");
  model_param_props.addLong("C_USE_DIFF_RW_CLK_GP3", "0");
  model_param_props.addLong("C_USE_DIFF_RW_CLK_GP4", "0");
  model_param_props.addLong("C_USE_DIFF_RW_CLK_GP5", "0");
  model_param_props.addLong("C_USE_DIFF_RW_CLK_GP6", "0");
  model_param_props.addLong("C_TRACE_PIPELINE_WIDTH", "8");
  model_param_props.addLong("C_EN_EMIO_TRACE", "0");
  model_param_props.addLong("C_TRACE_DATA_WIDTH", "32");
  model_param_props.addLong("C_USE_DEBUG_TEST", "0");
  model_param_props.addLong("C_SD0_INTERNAL_BUS_WIDTH", "8");
  model_param_props.addLong("C_SD1_INTERNAL_BUS_WIDTH", "8");
  model_param_props.addLong("C_NUM_F2P_0_INTR_INPUTS", "1");
  model_param_props.addLong("C_NUM_F2P_1_INTR_INPUTS", "1");
  model_param_props.addLong("C_EMIO_GPIO_WIDTH", "1");
  model_param_props.addLong("C_NUM_FABRIC_RESETS", "1");
  model_param_props.addString("C_EN_FIFO_ENET0", "0");
  model_param_props.addString("C_EN_FIFO_ENET1", "0");
  model_param_props.addString("C_EN_FIFO_ENET2", "0");
  model_param_props.addString("C_EN_FIFO_ENET3", "0");
  model_param_props.addString("C_PL_CLK0_BUF", "TRUE");
  model_param_props.addString("C_PL_CLK1_BUF", "FALSE");
  model_param_props.addString("C_PL_CLK2_BUF", "FALSE");
  model_param_props.addString("C_PL_CLK3_BUF", "FALSE");
  mp_impl = new zynq_ultra_ps_e_tlm("inst", model_param_props);

  // initialize sockets
  M_AXI_HPM0_FPD_rd_socket = mp_impl->M_AXI_HPM0_FPD_rd_socket;
  M_AXI_HPM0_FPD_wr_socket = mp_impl->M_AXI_HPM0_FPD_wr_socket;
  M_AXI_HPM1_FPD_rd_socket = mp_impl->M_AXI_HPM1_FPD_rd_socket;
  M_AXI_HPM1_FPD_wr_socket = mp_impl->M_AXI_HPM1_FPD_wr_socket;
  S_AXI_HPC0_FPD_rd_socket = mp_impl->S_AXI_HPC0_FPD_rd_socket;
  S_AXI_HPC0_FPD_wr_socket = mp_impl->S_AXI_HPC0_FPD_wr_socket;
}

zynqmpsoc_zynq_ultra_ps_e_0_0_sc::~zynqmpsoc_zynq_ultra_ps_e_0_0_sc()
{
  xsc::utils::xsc_sim_manager::clean();

  delete mp_impl;
}

