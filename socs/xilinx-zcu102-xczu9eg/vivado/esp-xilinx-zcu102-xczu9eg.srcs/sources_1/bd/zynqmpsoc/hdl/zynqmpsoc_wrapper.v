//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
//Date        : Mon Jan 11 12:06:06 2021
//Host        : skie running 64-bit Ubuntu 18.04.5 LTS
//Command     : generate_target zynqmpsoc_wrapper.bd
//Design      : zynqmpsoc_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module zynqmpsoc_wrapper
   (AHB_INTERFACE_0_haddr,
    AHB_INTERFACE_0_hburst,
    AHB_INTERFACE_0_hprot,
    AHB_INTERFACE_0_hrdata,
    AHB_INTERFACE_0_hready_in,
    AHB_INTERFACE_0_hready_out,
    AHB_INTERFACE_0_hresp,
    AHB_INTERFACE_0_hsize,
    AHB_INTERFACE_0_htrans,
    AHB_INTERFACE_0_hwdata,
    AHB_INTERFACE_0_hwrite,
    AHB_INTERFACE_0_sel,
    M_AHB_0_haddr,
    M_AHB_0_hburst,
    M_AHB_0_hmastlock,
    M_AHB_0_hprot,
    M_AHB_0_hrdata,
    M_AHB_0_hready,
    M_AHB_0_hresp,
    M_AHB_0_hsize,
    M_AHB_0_htrans,
    M_AHB_0_hwdata,
    M_AHB_0_hwrite,
    dip_switches_8bits_tri_i,
    peripheral_reset_0,
    pl_clk0);
  input [31:0]AHB_INTERFACE_0_haddr;
  input [2:0]AHB_INTERFACE_0_hburst;
  input [3:0]AHB_INTERFACE_0_hprot;
  output [63:0]AHB_INTERFACE_0_hrdata;
  input AHB_INTERFACE_0_hready_in;
  output AHB_INTERFACE_0_hready_out;
  output AHB_INTERFACE_0_hresp;
  input [2:0]AHB_INTERFACE_0_hsize;
  input [1:0]AHB_INTERFACE_0_htrans;
  input [63:0]AHB_INTERFACE_0_hwdata;
  input AHB_INTERFACE_0_hwrite;
  input AHB_INTERFACE_0_sel;
  output [31:0]M_AHB_0_haddr;
  output [2:0]M_AHB_0_hburst;
  output M_AHB_0_hmastlock;
  output [3:0]M_AHB_0_hprot;
  input [31:0]M_AHB_0_hrdata;
  input M_AHB_0_hready;
  input M_AHB_0_hresp;
  output [2:0]M_AHB_0_hsize;
  output [1:0]M_AHB_0_htrans;
  output [31:0]M_AHB_0_hwdata;
  output M_AHB_0_hwrite;
  input [7:0]dip_switches_8bits_tri_i;
  output [0:0]peripheral_reset_0;
  output pl_clk0;

  wire [31:0]AHB_INTERFACE_0_haddr;
  wire [2:0]AHB_INTERFACE_0_hburst;
  wire [3:0]AHB_INTERFACE_0_hprot;
  wire [63:0]AHB_INTERFACE_0_hrdata;
  wire AHB_INTERFACE_0_hready_in;
  wire AHB_INTERFACE_0_hready_out;
  wire AHB_INTERFACE_0_hresp;
  wire [2:0]AHB_INTERFACE_0_hsize;
  wire [1:0]AHB_INTERFACE_0_htrans;
  wire [63:0]AHB_INTERFACE_0_hwdata;
  wire AHB_INTERFACE_0_hwrite;
  wire AHB_INTERFACE_0_sel;
  wire [31:0]M_AHB_0_haddr;
  wire [2:0]M_AHB_0_hburst;
  wire M_AHB_0_hmastlock;
  wire [3:0]M_AHB_0_hprot;
  wire [31:0]M_AHB_0_hrdata;
  wire M_AHB_0_hready;
  wire M_AHB_0_hresp;
  wire [2:0]M_AHB_0_hsize;
  wire [1:0]M_AHB_0_htrans;
  wire [31:0]M_AHB_0_hwdata;
  wire M_AHB_0_hwrite;
  wire [7:0]dip_switches_8bits_tri_i;
  wire [0:0]peripheral_reset_0;
  wire pl_clk0;

  zynqmpsoc zynqmpsoc_i
       (.AHB_INTERFACE_0_haddr(AHB_INTERFACE_0_haddr),
        .AHB_INTERFACE_0_hburst(AHB_INTERFACE_0_hburst),
        .AHB_INTERFACE_0_hprot(AHB_INTERFACE_0_hprot),
        .AHB_INTERFACE_0_hrdata(AHB_INTERFACE_0_hrdata),
        .AHB_INTERFACE_0_hready_in(AHB_INTERFACE_0_hready_in),
        .AHB_INTERFACE_0_hready_out(AHB_INTERFACE_0_hready_out),
        .AHB_INTERFACE_0_hresp(AHB_INTERFACE_0_hresp),
        .AHB_INTERFACE_0_hsize(AHB_INTERFACE_0_hsize),
        .AHB_INTERFACE_0_htrans(AHB_INTERFACE_0_htrans),
        .AHB_INTERFACE_0_hwdata(AHB_INTERFACE_0_hwdata),
        .AHB_INTERFACE_0_hwrite(AHB_INTERFACE_0_hwrite),
        .AHB_INTERFACE_0_sel(AHB_INTERFACE_0_sel),
        .M_AHB_0_haddr(M_AHB_0_haddr),
        .M_AHB_0_hburst(M_AHB_0_hburst),
        .M_AHB_0_hmastlock(M_AHB_0_hmastlock),
        .M_AHB_0_hprot(M_AHB_0_hprot),
        .M_AHB_0_hrdata(M_AHB_0_hrdata),
        .M_AHB_0_hready(M_AHB_0_hready),
        .M_AHB_0_hresp(M_AHB_0_hresp),
        .M_AHB_0_hsize(M_AHB_0_hsize),
        .M_AHB_0_htrans(M_AHB_0_htrans),
        .M_AHB_0_hwdata(M_AHB_0_hwdata),
        .M_AHB_0_hwrite(M_AHB_0_hwrite),
        .dip_switches_8bits_tri_i(dip_switches_8bits_tri_i),
        .peripheral_reset_0(peripheral_reset_0),
        .pl_clk0(pl_clk0));
endmodule
