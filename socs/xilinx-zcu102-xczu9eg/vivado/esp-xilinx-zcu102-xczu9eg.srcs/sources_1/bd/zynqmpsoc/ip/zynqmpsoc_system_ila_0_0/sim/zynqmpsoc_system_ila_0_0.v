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


// IP VLNV: xilinx.com:ip:system_ila:1.1
// IP Revision: 6

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module zynqmpsoc_system_ila_0_0 (
  clk,
  SLOT_0_AHBLITE_haddr,
  SLOT_0_AHBLITE_hprot,
  SLOT_0_AHBLITE_htrans,
  SLOT_0_AHBLITE_hsize,
  SLOT_0_AHBLITE_hwrite,
  SLOT_0_AHBLITE_hburst,
  SLOT_0_AHBLITE_hwdata,
  SLOT_0_AHBLITE_hrdata,
  SLOT_0_AHBLITE_hresp,
  SLOT_0_AHBLITE_hmastlock,
  SLOT_0_AHBLITE_hready,
  SLOT_1_AHBLITE_sel,
  SLOT_1_AHBLITE_haddr,
  SLOT_1_AHBLITE_hprot,
  SLOT_1_AHBLITE_htrans,
  SLOT_1_AHBLITE_hsize,
  SLOT_1_AHBLITE_hwrite,
  SLOT_1_AHBLITE_hburst,
  SLOT_1_AHBLITE_hwdata,
  SLOT_1_AHBLITE_hrdata,
  SLOT_1_AHBLITE_hresp,
  SLOT_1_AHBLITE_hready_in,
  SLOT_1_AHBLITE_hready_out
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.clk, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.clk CLK" *)
input wire clk;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HADDR" *)
input wire SLOT_0_AHBLITE_haddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HPROT" *)
input wire SLOT_0_AHBLITE_hprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HTRANS" *)
input wire SLOT_0_AHBLITE_htrans;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HSIZE" *)
input wire SLOT_0_AHBLITE_hsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HWRITE" *)
input wire SLOT_0_AHBLITE_hwrite;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HBURST" *)
input wire SLOT_0_AHBLITE_hburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HWDATA" *)
input wire SLOT_0_AHBLITE_hwdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HRDATA" *)
input wire SLOT_0_AHBLITE_hrdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HRESP" *)
input wire SLOT_0_AHBLITE_hresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HMASTLOCK" *)
input wire SLOT_0_AHBLITE_hmastlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HREADY" *)
input wire SLOT_0_AHBLITE_hready;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE SEL" *)
input wire SLOT_1_AHBLITE_sel;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HADDR" *)
input wire SLOT_1_AHBLITE_haddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HPROT" *)
input wire SLOT_1_AHBLITE_hprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HTRANS" *)
input wire SLOT_1_AHBLITE_htrans;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HSIZE" *)
input wire SLOT_1_AHBLITE_hsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HWRITE" *)
input wire SLOT_1_AHBLITE_hwrite;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HBURST" *)
input wire SLOT_1_AHBLITE_hburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HWDATA" *)
input wire SLOT_1_AHBLITE_hwdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HRDATA" *)
input wire SLOT_1_AHBLITE_hrdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HRESP" *)
input wire SLOT_1_AHBLITE_hresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HREADY_IN" *)
input wire SLOT_1_AHBLITE_hready_in;
(* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HREADY_OUT" *)
input wire SLOT_1_AHBLITE_hready_out;

  bd_c007 inst (
    .clk(clk),
    .SLOT_0_AHBLITE_haddr(SLOT_0_AHBLITE_haddr),
    .SLOT_0_AHBLITE_hprot(SLOT_0_AHBLITE_hprot),
    .SLOT_0_AHBLITE_htrans(SLOT_0_AHBLITE_htrans),
    .SLOT_0_AHBLITE_hsize(SLOT_0_AHBLITE_hsize),
    .SLOT_0_AHBLITE_hwrite(SLOT_0_AHBLITE_hwrite),
    .SLOT_0_AHBLITE_hburst(SLOT_0_AHBLITE_hburst),
    .SLOT_0_AHBLITE_hwdata(SLOT_0_AHBLITE_hwdata),
    .SLOT_0_AHBLITE_hrdata(SLOT_0_AHBLITE_hrdata),
    .SLOT_0_AHBLITE_hresp(SLOT_0_AHBLITE_hresp),
    .SLOT_0_AHBLITE_hmastlock(SLOT_0_AHBLITE_hmastlock),
    .SLOT_0_AHBLITE_hready(SLOT_0_AHBLITE_hready),
    .SLOT_1_AHBLITE_sel(SLOT_1_AHBLITE_sel),
    .SLOT_1_AHBLITE_haddr(SLOT_1_AHBLITE_haddr),
    .SLOT_1_AHBLITE_hprot(SLOT_1_AHBLITE_hprot),
    .SLOT_1_AHBLITE_htrans(SLOT_1_AHBLITE_htrans),
    .SLOT_1_AHBLITE_hsize(SLOT_1_AHBLITE_hsize),
    .SLOT_1_AHBLITE_hwrite(SLOT_1_AHBLITE_hwrite),
    .SLOT_1_AHBLITE_hburst(SLOT_1_AHBLITE_hburst),
    .SLOT_1_AHBLITE_hwdata(SLOT_1_AHBLITE_hwdata),
    .SLOT_1_AHBLITE_hrdata(SLOT_1_AHBLITE_hrdata),
    .SLOT_1_AHBLITE_hresp(SLOT_1_AHBLITE_hresp),
    .SLOT_1_AHBLITE_hready_in(SLOT_1_AHBLITE_hready_in),
    .SLOT_1_AHBLITE_hready_out(SLOT_1_AHBLITE_hready_out)
  );
endmodule
