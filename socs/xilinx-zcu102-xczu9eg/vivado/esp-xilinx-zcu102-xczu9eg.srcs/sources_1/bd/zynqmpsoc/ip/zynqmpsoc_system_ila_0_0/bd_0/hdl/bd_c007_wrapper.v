//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_c007_wrapper.bd
//Design : bd_c007_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_c007_wrapper
   (SLOT_0_AHBLITE_haddr,
    SLOT_0_AHBLITE_hburst,
    SLOT_0_AHBLITE_hmastlock,
    SLOT_0_AHBLITE_hprot,
    SLOT_0_AHBLITE_hrdata,
    SLOT_0_AHBLITE_hready,
    SLOT_0_AHBLITE_hresp,
    SLOT_0_AHBLITE_hsize,
    SLOT_0_AHBLITE_htrans,
    SLOT_0_AHBLITE_hwdata,
    SLOT_0_AHBLITE_hwrite,
    SLOT_1_AHBLITE_haddr,
    SLOT_1_AHBLITE_hburst,
    SLOT_1_AHBLITE_hprot,
    SLOT_1_AHBLITE_hrdata,
    SLOT_1_AHBLITE_hready_in,
    SLOT_1_AHBLITE_hready_out,
    SLOT_1_AHBLITE_hresp,
    SLOT_1_AHBLITE_hsize,
    SLOT_1_AHBLITE_htrans,
    SLOT_1_AHBLITE_hwdata,
    SLOT_1_AHBLITE_hwrite,
    SLOT_1_AHBLITE_sel,
    clk);
  input SLOT_0_AHBLITE_haddr;
  input SLOT_0_AHBLITE_hburst;
  input SLOT_0_AHBLITE_hmastlock;
  input SLOT_0_AHBLITE_hprot;
  input SLOT_0_AHBLITE_hrdata;
  input SLOT_0_AHBLITE_hready;
  input SLOT_0_AHBLITE_hresp;
  input SLOT_0_AHBLITE_hsize;
  input SLOT_0_AHBLITE_htrans;
  input SLOT_0_AHBLITE_hwdata;
  input SLOT_0_AHBLITE_hwrite;
  input SLOT_1_AHBLITE_haddr;
  input SLOT_1_AHBLITE_hburst;
  input SLOT_1_AHBLITE_hprot;
  input SLOT_1_AHBLITE_hrdata;
  input SLOT_1_AHBLITE_hready_in;
  input SLOT_1_AHBLITE_hready_out;
  input SLOT_1_AHBLITE_hresp;
  input SLOT_1_AHBLITE_hsize;
  input SLOT_1_AHBLITE_htrans;
  input SLOT_1_AHBLITE_hwdata;
  input SLOT_1_AHBLITE_hwrite;
  input SLOT_1_AHBLITE_sel;
  input clk;

  wire SLOT_0_AHBLITE_haddr;
  wire SLOT_0_AHBLITE_hburst;
  wire SLOT_0_AHBLITE_hmastlock;
  wire SLOT_0_AHBLITE_hprot;
  wire SLOT_0_AHBLITE_hrdata;
  wire SLOT_0_AHBLITE_hready;
  wire SLOT_0_AHBLITE_hresp;
  wire SLOT_0_AHBLITE_hsize;
  wire SLOT_0_AHBLITE_htrans;
  wire SLOT_0_AHBLITE_hwdata;
  wire SLOT_0_AHBLITE_hwrite;
  wire SLOT_1_AHBLITE_haddr;
  wire SLOT_1_AHBLITE_hburst;
  wire SLOT_1_AHBLITE_hprot;
  wire SLOT_1_AHBLITE_hrdata;
  wire SLOT_1_AHBLITE_hready_in;
  wire SLOT_1_AHBLITE_hready_out;
  wire SLOT_1_AHBLITE_hresp;
  wire SLOT_1_AHBLITE_hsize;
  wire SLOT_1_AHBLITE_htrans;
  wire SLOT_1_AHBLITE_hwdata;
  wire SLOT_1_AHBLITE_hwrite;
  wire SLOT_1_AHBLITE_sel;
  wire clk;

  bd_c007 bd_c007_i
       (.SLOT_0_AHBLITE_haddr(SLOT_0_AHBLITE_haddr),
        .SLOT_0_AHBLITE_hburst(SLOT_0_AHBLITE_hburst),
        .SLOT_0_AHBLITE_hmastlock(SLOT_0_AHBLITE_hmastlock),
        .SLOT_0_AHBLITE_hprot(SLOT_0_AHBLITE_hprot),
        .SLOT_0_AHBLITE_hrdata(SLOT_0_AHBLITE_hrdata),
        .SLOT_0_AHBLITE_hready(SLOT_0_AHBLITE_hready),
        .SLOT_0_AHBLITE_hresp(SLOT_0_AHBLITE_hresp),
        .SLOT_0_AHBLITE_hsize(SLOT_0_AHBLITE_hsize),
        .SLOT_0_AHBLITE_htrans(SLOT_0_AHBLITE_htrans),
        .SLOT_0_AHBLITE_hwdata(SLOT_0_AHBLITE_hwdata),
        .SLOT_0_AHBLITE_hwrite(SLOT_0_AHBLITE_hwrite),
        .SLOT_1_AHBLITE_haddr(SLOT_1_AHBLITE_haddr),
        .SLOT_1_AHBLITE_hburst(SLOT_1_AHBLITE_hburst),
        .SLOT_1_AHBLITE_hprot(SLOT_1_AHBLITE_hprot),
        .SLOT_1_AHBLITE_hrdata(SLOT_1_AHBLITE_hrdata),
        .SLOT_1_AHBLITE_hready_in(SLOT_1_AHBLITE_hready_in),
        .SLOT_1_AHBLITE_hready_out(SLOT_1_AHBLITE_hready_out),
        .SLOT_1_AHBLITE_hresp(SLOT_1_AHBLITE_hresp),
        .SLOT_1_AHBLITE_hsize(SLOT_1_AHBLITE_hsize),
        .SLOT_1_AHBLITE_htrans(SLOT_1_AHBLITE_htrans),
        .SLOT_1_AHBLITE_hwdata(SLOT_1_AHBLITE_hwdata),
        .SLOT_1_AHBLITE_hwrite(SLOT_1_AHBLITE_hwrite),
        .SLOT_1_AHBLITE_sel(SLOT_1_AHBLITE_sel),
        .clk(clk));
endmodule
