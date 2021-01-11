//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_c007.bd
//Design : bd_c007
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "bd_c007,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=bd_c007,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=SBD,synth_mode=Global}" *) (* HW_HANDOFF = "zynqmpsoc_system_ila_0_0.hwdef" *) 
module bd_c007
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HADDR" *) input SLOT_0_AHBLITE_haddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HBURST" *) input SLOT_0_AHBLITE_hburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HMASTLOCK" *) input SLOT_0_AHBLITE_hmastlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HPROT" *) input SLOT_0_AHBLITE_hprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HRDATA" *) input SLOT_0_AHBLITE_hrdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HREADY" *) input SLOT_0_AHBLITE_hready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HRESP" *) input SLOT_0_AHBLITE_hresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HSIZE" *) input SLOT_0_AHBLITE_hsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HTRANS" *) input SLOT_0_AHBLITE_htrans;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HWDATA" *) input SLOT_0_AHBLITE_hwdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_0_AHBLITE HWRITE" *) input SLOT_0_AHBLITE_hwrite;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HADDR" *) input SLOT_1_AHBLITE_haddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HBURST" *) input SLOT_1_AHBLITE_hburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HPROT" *) input SLOT_1_AHBLITE_hprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HRDATA" *) input SLOT_1_AHBLITE_hrdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HREADY_IN" *) input SLOT_1_AHBLITE_hready_in;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HREADY_OUT" *) input SLOT_1_AHBLITE_hready_out;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HRESP" *) input SLOT_1_AHBLITE_hresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HSIZE" *) input SLOT_1_AHBLITE_hsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HTRANS" *) input SLOT_1_AHBLITE_htrans;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HWDATA" *) input SLOT_1_AHBLITE_hwdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE HWRITE" *) input SLOT_1_AHBLITE_hwrite;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 SLOT_1_AHBLITE SEL" *) input SLOT_1_AHBLITE_sel;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, FREQ_HZ 75000000, INSERT_VIP 0, PHASE 0.000" *) input clk;

  wire SLOT_0_AHBLITE_haddr_1;
  wire SLOT_0_AHBLITE_hburst_1;
  wire SLOT_0_AHBLITE_hmastlock_1;
  wire SLOT_0_AHBLITE_hprot_1;
  wire SLOT_0_AHBLITE_hrdata_1;
  wire SLOT_0_AHBLITE_hready_1;
  wire SLOT_0_AHBLITE_hresp_1;
  wire SLOT_0_AHBLITE_hsize_1;
  wire SLOT_0_AHBLITE_htrans_1;
  wire SLOT_0_AHBLITE_hwdata_1;
  wire SLOT_0_AHBLITE_hwrite_1;
  wire SLOT_1_AHBLITE_haddr_1;
  wire SLOT_1_AHBLITE_hburst_1;
  wire SLOT_1_AHBLITE_hprot_1;
  wire SLOT_1_AHBLITE_hrdata_1;
  wire SLOT_1_AHBLITE_hready_in_1;
  wire SLOT_1_AHBLITE_hready_out_1;
  wire SLOT_1_AHBLITE_hresp_1;
  wire SLOT_1_AHBLITE_hsize_1;
  wire SLOT_1_AHBLITE_htrans_1;
  wire SLOT_1_AHBLITE_hwdata_1;
  wire SLOT_1_AHBLITE_hwrite_1;
  wire SLOT_1_AHBLITE_sel_1;
  wire clk_1;

  assign SLOT_0_AHBLITE_haddr_1 = SLOT_0_AHBLITE_haddr;
  assign SLOT_0_AHBLITE_hburst_1 = SLOT_0_AHBLITE_hburst;
  assign SLOT_0_AHBLITE_hmastlock_1 = SLOT_0_AHBLITE_hmastlock;
  assign SLOT_0_AHBLITE_hprot_1 = SLOT_0_AHBLITE_hprot;
  assign SLOT_0_AHBLITE_hrdata_1 = SLOT_0_AHBLITE_hrdata;
  assign SLOT_0_AHBLITE_hready_1 = SLOT_0_AHBLITE_hready;
  assign SLOT_0_AHBLITE_hresp_1 = SLOT_0_AHBLITE_hresp;
  assign SLOT_0_AHBLITE_hsize_1 = SLOT_0_AHBLITE_hsize;
  assign SLOT_0_AHBLITE_htrans_1 = SLOT_0_AHBLITE_htrans;
  assign SLOT_0_AHBLITE_hwdata_1 = SLOT_0_AHBLITE_hwdata;
  assign SLOT_0_AHBLITE_hwrite_1 = SLOT_0_AHBLITE_hwrite;
  assign SLOT_1_AHBLITE_haddr_1 = SLOT_1_AHBLITE_haddr;
  assign SLOT_1_AHBLITE_hburst_1 = SLOT_1_AHBLITE_hburst;
  assign SLOT_1_AHBLITE_hprot_1 = SLOT_1_AHBLITE_hprot;
  assign SLOT_1_AHBLITE_hrdata_1 = SLOT_1_AHBLITE_hrdata;
  assign SLOT_1_AHBLITE_hready_in_1 = SLOT_1_AHBLITE_hready_in;
  assign SLOT_1_AHBLITE_hready_out_1 = SLOT_1_AHBLITE_hready_out;
  assign SLOT_1_AHBLITE_hresp_1 = SLOT_1_AHBLITE_hresp;
  assign SLOT_1_AHBLITE_hsize_1 = SLOT_1_AHBLITE_hsize;
  assign SLOT_1_AHBLITE_htrans_1 = SLOT_1_AHBLITE_htrans;
  assign SLOT_1_AHBLITE_hwdata_1 = SLOT_1_AHBLITE_hwdata;
  assign SLOT_1_AHBLITE_hwrite_1 = SLOT_1_AHBLITE_hwrite;
  assign SLOT_1_AHBLITE_sel_1 = SLOT_1_AHBLITE_sel;
  assign clk_1 = clk;
  bd_c007_ila_lib_0 ila_lib
       (.clk(clk_1),
        .probe0(SLOT_0_AHBLITE_haddr_1),
        .probe1(SLOT_0_AHBLITE_hburst_1),
        .probe10(SLOT_0_AHBLITE_hwrite_1),
        .probe11(SLOT_1_AHBLITE_haddr_1),
        .probe12(SLOT_1_AHBLITE_hburst_1),
        .probe13(SLOT_1_AHBLITE_hprot_1),
        .probe14(SLOT_1_AHBLITE_hrdata_1),
        .probe15(SLOT_1_AHBLITE_hready_in_1),
        .probe16(SLOT_1_AHBLITE_hready_out_1),
        .probe17(SLOT_1_AHBLITE_hresp_1),
        .probe18(SLOT_1_AHBLITE_hsize_1),
        .probe19(SLOT_1_AHBLITE_htrans_1),
        .probe2(SLOT_0_AHBLITE_hmastlock_1),
        .probe20(SLOT_1_AHBLITE_hwdata_1),
        .probe21(SLOT_1_AHBLITE_hwrite_1),
        .probe22(SLOT_1_AHBLITE_sel_1),
        .probe3(SLOT_0_AHBLITE_hprot_1),
        .probe4(SLOT_0_AHBLITE_hrdata_1),
        .probe5(SLOT_0_AHBLITE_hready_1),
        .probe6(SLOT_0_AHBLITE_hresp_1),
        .probe7(SLOT_0_AHBLITE_hsize_1),
        .probe8(SLOT_0_AHBLITE_htrans_1),
        .probe9(SLOT_0_AHBLITE_hwdata_1));
endmodule
