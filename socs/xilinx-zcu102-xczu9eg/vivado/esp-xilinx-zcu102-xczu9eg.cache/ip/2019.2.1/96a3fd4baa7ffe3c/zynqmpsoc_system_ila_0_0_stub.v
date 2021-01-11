// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
// Date        : Mon Jan 11 12:11:29 2021
// Host        : skie running 64-bit Ubuntu 18.04.5 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ zynqmpsoc_system_ila_0_0_stub.v
// Design      : zynqmpsoc_system_ila_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "bd_c007,Vivado 2019.2.1" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk, SLOT_0_AHBLITE_haddr, 
  SLOT_0_AHBLITE_hprot, SLOT_0_AHBLITE_htrans, SLOT_0_AHBLITE_hsize, 
  SLOT_0_AHBLITE_hwrite, SLOT_0_AHBLITE_hburst, SLOT_0_AHBLITE_hwdata, 
  SLOT_0_AHBLITE_hrdata, SLOT_0_AHBLITE_hresp, SLOT_0_AHBLITE_hmastlock, 
  SLOT_0_AHBLITE_hready, SLOT_1_AHBLITE_sel, SLOT_1_AHBLITE_haddr, SLOT_1_AHBLITE_hprot, 
  SLOT_1_AHBLITE_htrans, SLOT_1_AHBLITE_hsize, SLOT_1_AHBLITE_hwrite, 
  SLOT_1_AHBLITE_hburst, SLOT_1_AHBLITE_hwdata, SLOT_1_AHBLITE_hrdata, 
  SLOT_1_AHBLITE_hresp, SLOT_1_AHBLITE_hready_in, SLOT_1_AHBLITE_hready_out)
/* synthesis syn_black_box black_box_pad_pin="clk,SLOT_0_AHBLITE_haddr,SLOT_0_AHBLITE_hprot,SLOT_0_AHBLITE_htrans,SLOT_0_AHBLITE_hsize,SLOT_0_AHBLITE_hwrite,SLOT_0_AHBLITE_hburst,SLOT_0_AHBLITE_hwdata,SLOT_0_AHBLITE_hrdata,SLOT_0_AHBLITE_hresp,SLOT_0_AHBLITE_hmastlock,SLOT_0_AHBLITE_hready,SLOT_1_AHBLITE_sel,SLOT_1_AHBLITE_haddr,SLOT_1_AHBLITE_hprot,SLOT_1_AHBLITE_htrans,SLOT_1_AHBLITE_hsize,SLOT_1_AHBLITE_hwrite,SLOT_1_AHBLITE_hburst,SLOT_1_AHBLITE_hwdata,SLOT_1_AHBLITE_hrdata,SLOT_1_AHBLITE_hresp,SLOT_1_AHBLITE_hready_in,SLOT_1_AHBLITE_hready_out" */;
  input clk;
  input SLOT_0_AHBLITE_haddr;
  input SLOT_0_AHBLITE_hprot;
  input SLOT_0_AHBLITE_htrans;
  input SLOT_0_AHBLITE_hsize;
  input SLOT_0_AHBLITE_hwrite;
  input SLOT_0_AHBLITE_hburst;
  input SLOT_0_AHBLITE_hwdata;
  input SLOT_0_AHBLITE_hrdata;
  input SLOT_0_AHBLITE_hresp;
  input SLOT_0_AHBLITE_hmastlock;
  input SLOT_0_AHBLITE_hready;
  input SLOT_1_AHBLITE_sel;
  input SLOT_1_AHBLITE_haddr;
  input SLOT_1_AHBLITE_hprot;
  input SLOT_1_AHBLITE_htrans;
  input SLOT_1_AHBLITE_hsize;
  input SLOT_1_AHBLITE_hwrite;
  input SLOT_1_AHBLITE_hburst;
  input SLOT_1_AHBLITE_hwdata;
  input SLOT_1_AHBLITE_hrdata;
  input SLOT_1_AHBLITE_hresp;
  input SLOT_1_AHBLITE_hready_in;
  input SLOT_1_AHBLITE_hready_out;
endmodule
