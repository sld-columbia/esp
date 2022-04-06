// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Mon Apr  4 20:23:55 2022
// Host        : socp06-ubuntu running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/esp2022/sr3859/esp/esp/accelerators/third-party/GT_VORTEX/ip/rtl/fp_cores/xilinx/vc707/acl_fmadd/acl_fmadd.srcs/sources_1/ip/acl_fmadd/acl_fmadd_stub.v
// Design      : acl_fmadd
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "floating_point_v7_1_9,Vivado 2019.2" *)
module acl_fmadd(aclk, aclken, aresetn, 
  //s_axis_a_tvalid, 
  //s_axis_a_tready, 
  s_axis_a_tdata, 
  //s_axis_b_tvalid, 
  //s_axis_b_tready, 
  s_axis_b_tdata, 
  //s_axis_c_tvalid, 
  //s_axis_c_tready, 
  s_axis_c_tdata, 
  //m_axis_result_tvalid, 
  m_axis_result_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,aclken,aresetn,s_axis_a_tvalid,s_axis_a_tready,s_axis_a_tdata[31:0],s_axis_b_tvalid,s_axis_b_tready,s_axis_b_tdata[31:0],s_axis_c_tvalid,s_axis_c_tready,s_axis_c_tdata[31:0],m_axis_result_tvalid,m_axis_result_tdata[31:0]" */;
  input aclk;
  input aclken;
  input aresetn;
  //input s_axis_a_tvalid;
  //output s_axis_a_tready;
  input [31:0]s_axis_a_tdata;
  //input s_axis_b_tvalid;
  //output s_axis_b_tready;
  input [31:0]s_axis_b_tdata;
  //input s_axis_c_tvalid;
  //output s_axis_c_tready;
  input [31:0]s_axis_c_tdata;
  //output m_axis_result_tvalid;
  output [31:0]m_axis_result_tdata;
endmodule
