//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
//Date        : Mon Jan 11 12:06:06 2021
//Host        : skie running 64-bit Ubuntu 18.04.5 LTS
//Command     : generate_target zynqmpsoc.bd
//Design      : zynqmpsoc
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module s00_couplers_imp_17VQRNZ
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [39:0]M_AXI_araddr;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [39:0]M_AXI_awaddr;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [39:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [15:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [39:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [15:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [15:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output [15:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [39:0]auto_pc_to_s00_couplers_ARADDR;
  wire auto_pc_to_s00_couplers_ARREADY;
  wire auto_pc_to_s00_couplers_ARVALID;
  wire [39:0]auto_pc_to_s00_couplers_AWADDR;
  wire auto_pc_to_s00_couplers_AWREADY;
  wire auto_pc_to_s00_couplers_AWVALID;
  wire auto_pc_to_s00_couplers_BREADY;
  wire [1:0]auto_pc_to_s00_couplers_BRESP;
  wire auto_pc_to_s00_couplers_BVALID;
  wire [31:0]auto_pc_to_s00_couplers_RDATA;
  wire auto_pc_to_s00_couplers_RREADY;
  wire [1:0]auto_pc_to_s00_couplers_RRESP;
  wire auto_pc_to_s00_couplers_RVALID;
  wire [31:0]auto_pc_to_s00_couplers_WDATA;
  wire auto_pc_to_s00_couplers_WREADY;
  wire [3:0]auto_pc_to_s00_couplers_WSTRB;
  wire auto_pc_to_s00_couplers_WVALID;
  wire [39:0]s00_couplers_to_auto_pc_ARADDR;
  wire [1:0]s00_couplers_to_auto_pc_ARBURST;
  wire [3:0]s00_couplers_to_auto_pc_ARCACHE;
  wire [15:0]s00_couplers_to_auto_pc_ARID;
  wire [7:0]s00_couplers_to_auto_pc_ARLEN;
  wire [0:0]s00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]s00_couplers_to_auto_pc_ARPROT;
  wire [3:0]s00_couplers_to_auto_pc_ARQOS;
  wire s00_couplers_to_auto_pc_ARREADY;
  wire [2:0]s00_couplers_to_auto_pc_ARSIZE;
  wire s00_couplers_to_auto_pc_ARVALID;
  wire [39:0]s00_couplers_to_auto_pc_AWADDR;
  wire [1:0]s00_couplers_to_auto_pc_AWBURST;
  wire [3:0]s00_couplers_to_auto_pc_AWCACHE;
  wire [15:0]s00_couplers_to_auto_pc_AWID;
  wire [7:0]s00_couplers_to_auto_pc_AWLEN;
  wire [0:0]s00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]s00_couplers_to_auto_pc_AWPROT;
  wire [3:0]s00_couplers_to_auto_pc_AWQOS;
  wire s00_couplers_to_auto_pc_AWREADY;
  wire [2:0]s00_couplers_to_auto_pc_AWSIZE;
  wire s00_couplers_to_auto_pc_AWVALID;
  wire [15:0]s00_couplers_to_auto_pc_BID;
  wire s00_couplers_to_auto_pc_BREADY;
  wire [1:0]s00_couplers_to_auto_pc_BRESP;
  wire s00_couplers_to_auto_pc_BVALID;
  wire [31:0]s00_couplers_to_auto_pc_RDATA;
  wire [15:0]s00_couplers_to_auto_pc_RID;
  wire s00_couplers_to_auto_pc_RLAST;
  wire s00_couplers_to_auto_pc_RREADY;
  wire [1:0]s00_couplers_to_auto_pc_RRESP;
  wire s00_couplers_to_auto_pc_RVALID;
  wire [31:0]s00_couplers_to_auto_pc_WDATA;
  wire s00_couplers_to_auto_pc_WLAST;
  wire s00_couplers_to_auto_pc_WREADY;
  wire [3:0]s00_couplers_to_auto_pc_WSTRB;
  wire s00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[39:0] = auto_pc_to_s00_couplers_ARADDR;
  assign M_AXI_arvalid = auto_pc_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[39:0] = auto_pc_to_s00_couplers_AWADDR;
  assign M_AXI_awvalid = auto_pc_to_s00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_s00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_s00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = auto_pc_to_s00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = auto_pc_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid = auto_pc_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = s00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = s00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[15:0] = s00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[31:0] = s00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[15:0] = s00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = s00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_auto_pc_RRESP;
  assign S_AXI_rvalid = s00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = s00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_s00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_s00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_s00_couplers_RDATA = M_AXI_rdata[31:0];
  assign auto_pc_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_s00_couplers_WREADY = M_AXI_wready;
  assign s00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[39:0];
  assign s00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_auto_pc_ARID = S_AXI_arid[15:0];
  assign s00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[7:0];
  assign s00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock[0];
  assign s00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[39:0];
  assign s00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_auto_pc_AWID = S_AXI_awid[15:0];
  assign s00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[7:0];
  assign s00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock[0];
  assign s00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign s00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign s00_couplers_to_auto_pc_WDATA = S_AXI_wdata[31:0];
  assign s00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign s00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[3:0];
  assign s00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
  zynqmpsoc_auto_pc_0 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_s00_couplers_ARADDR),
        .m_axi_arready(auto_pc_to_s00_couplers_ARREADY),
        .m_axi_arvalid(auto_pc_to_s00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_s00_couplers_AWADDR),
        .m_axi_awready(auto_pc_to_s00_couplers_AWREADY),
        .m_axi_awvalid(auto_pc_to_s00_couplers_AWVALID),
        .m_axi_bready(auto_pc_to_s00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_s00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_s00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_s00_couplers_RDATA),
        .m_axi_rready(auto_pc_to_s00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_s00_couplers_RRESP),
        .m_axi_rvalid(auto_pc_to_s00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_s00_couplers_WDATA),
        .m_axi_wready(auto_pc_to_s00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_s00_couplers_WSTRB),
        .m_axi_wvalid(auto_pc_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(s00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(s00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(s00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(s00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(s00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(s00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(s00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(s00_couplers_to_auto_pc_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(s00_couplers_to_auto_pc_ARSIZE),
        .s_axi_arvalid(s00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(s00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(s00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(s00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(s00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(s00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(s00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(s00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(s00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(s00_couplers_to_auto_pc_AWREADY),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize(s00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awvalid(s00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(s00_couplers_to_auto_pc_BID),
        .s_axi_bready(s00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(s00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(s00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(s00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(s00_couplers_to_auto_pc_RID),
        .s_axi_rlast(s00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(s00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(s00_couplers_to_auto_pc_RRESP),
        .s_axi_rvalid(s00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(s00_couplers_to_auto_pc_WDATA),
        .s_axi_wlast(s00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(s00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(s00_couplers_to_auto_pc_WSTRB),
        .s_axi_wvalid(s00_couplers_to_auto_pc_WVALID));
endmodule

(* CORE_GENERATION_INFO = "zynqmpsoc,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=zynqmpsoc,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=9,numReposBlks=7,numNonXlnxBlks=0,numHierBlks=2,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "zynqmpsoc.hwdef" *) 
module zynqmpsoc
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HADDR" *) input [31:0]AHB_INTERFACE_0_haddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HBURST" *) input [2:0]AHB_INTERFACE_0_hburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HPROT" *) input [3:0]AHB_INTERFACE_0_hprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HRDATA" *) output [63:0]AHB_INTERFACE_0_hrdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HREADY_IN" *) input AHB_INTERFACE_0_hready_in;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HREADY_OUT" *) output AHB_INTERFACE_0_hready_out;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HRESP" *) output AHB_INTERFACE_0_hresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HSIZE" *) input [2:0]AHB_INTERFACE_0_hsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HTRANS" *) input [1:0]AHB_INTERFACE_0_htrans;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HWDATA" *) input [63:0]AHB_INTERFACE_0_hwdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 HWRITE" *) input AHB_INTERFACE_0_hwrite;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE_0 SEL" *) input AHB_INTERFACE_0_sel;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HADDR" *) output [31:0]M_AHB_0_haddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HBURST" *) output [2:0]M_AHB_0_hburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HMASTLOCK" *) output M_AHB_0_hmastlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HPROT" *) output [3:0]M_AHB_0_hprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HRDATA" *) input [31:0]M_AHB_0_hrdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HREADY" *) input M_AHB_0_hready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HRESP" *) input M_AHB_0_hresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HSIZE" *) output [2:0]M_AHB_0_hsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HTRANS" *) output [1:0]M_AHB_0_htrans;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HWDATA" *) output [31:0]M_AHB_0_hwdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 M_AHB_0 HWRITE" *) output M_AHB_0_hwrite;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 dip_switches_8bits TRI_I" *) input [7:0]dip_switches_8bits_tri_i;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.PERIPHERAL_RESET_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.PERIPHERAL_RESET_0, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) output [0:0]peripheral_reset_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.PL_CLK0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.PL_CLK0, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, FREQ_HZ 75000000, INSERT_VIP 0, PHASE 0.000" *) output pl_clk0;

  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HADDR" *) (* DONT_TOUCH *) wire [31:0]AHB_INTERFACE_0_1_HADDR;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HBURST" *) (* DONT_TOUCH *) wire [2:0]AHB_INTERFACE_0_1_HBURST;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HPROT" *) (* DONT_TOUCH *) wire [3:0]AHB_INTERFACE_0_1_HPROT;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HRDATA" *) (* DONT_TOUCH *) wire [63:0]AHB_INTERFACE_0_1_HRDATA;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HREADY_IN" *) (* DONT_TOUCH *) wire AHB_INTERFACE_0_1_HREADY_IN;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HREADY_OUT" *) (* DONT_TOUCH *) wire AHB_INTERFACE_0_1_HREADY_OUT;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HRESP" *) (* DONT_TOUCH *) wire AHB_INTERFACE_0_1_HRESP;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HSIZE" *) (* DONT_TOUCH *) wire [2:0]AHB_INTERFACE_0_1_HSIZE;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HTRANS" *) (* DONT_TOUCH *) wire [1:0]AHB_INTERFACE_0_1_HTRANS;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HWDATA" *) (* DONT_TOUCH *) wire [63:0]AHB_INTERFACE_0_1_HWDATA;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None HWRITE" *) (* DONT_TOUCH *) wire AHB_INTERFACE_0_1_HWRITE;
  (* CONN_BUS_INFO = "AHB_INTERFACE_0_1 xilinx.com:interface:ahblite:2.0 None SEL" *) (* DONT_TOUCH *) wire AHB_INTERFACE_0_1_SEL;
  wire [31:0]ahblite_axi_bridge_0_M_AXI_ARADDR;
  wire [1:0]ahblite_axi_bridge_0_M_AXI_ARBURST;
  wire [3:0]ahblite_axi_bridge_0_M_AXI_ARCACHE;
  wire [3:0]ahblite_axi_bridge_0_M_AXI_ARID;
  wire [7:0]ahblite_axi_bridge_0_M_AXI_ARLEN;
  wire ahblite_axi_bridge_0_M_AXI_ARLOCK;
  wire [2:0]ahblite_axi_bridge_0_M_AXI_ARPROT;
  wire ahblite_axi_bridge_0_M_AXI_ARREADY;
  wire [2:0]ahblite_axi_bridge_0_M_AXI_ARSIZE;
  wire ahblite_axi_bridge_0_M_AXI_ARVALID;
  wire [31:0]ahblite_axi_bridge_0_M_AXI_AWADDR;
  wire [1:0]ahblite_axi_bridge_0_M_AXI_AWBURST;
  wire [3:0]ahblite_axi_bridge_0_M_AXI_AWCACHE;
  wire [3:0]ahblite_axi_bridge_0_M_AXI_AWID;
  wire [7:0]ahblite_axi_bridge_0_M_AXI_AWLEN;
  wire ahblite_axi_bridge_0_M_AXI_AWLOCK;
  wire [2:0]ahblite_axi_bridge_0_M_AXI_AWPROT;
  wire ahblite_axi_bridge_0_M_AXI_AWREADY;
  wire [2:0]ahblite_axi_bridge_0_M_AXI_AWSIZE;
  wire ahblite_axi_bridge_0_M_AXI_AWVALID;
  wire [5:0]ahblite_axi_bridge_0_M_AXI_BID;
  wire ahblite_axi_bridge_0_M_AXI_BREADY;
  wire [1:0]ahblite_axi_bridge_0_M_AXI_BRESP;
  wire ahblite_axi_bridge_0_M_AXI_BVALID;
  wire [63:0]ahblite_axi_bridge_0_M_AXI_RDATA;
  wire [5:0]ahblite_axi_bridge_0_M_AXI_RID;
  wire ahblite_axi_bridge_0_M_AXI_RLAST;
  wire ahblite_axi_bridge_0_M_AXI_RREADY;
  wire [1:0]ahblite_axi_bridge_0_M_AXI_RRESP;
  wire ahblite_axi_bridge_0_M_AXI_RVALID;
  wire [63:0]ahblite_axi_bridge_0_M_AXI_WDATA;
  wire ahblite_axi_bridge_0_M_AXI_WLAST;
  wire ahblite_axi_bridge_0_M_AXI_WREADY;
  wire [7:0]ahblite_axi_bridge_0_M_AXI_WSTRB;
  wire ahblite_axi_bridge_0_M_AXI_WVALID;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HADDR" *) (* DONT_TOUCH *) wire [31:0]axi_ahblite_bridge_0_M_AHB_HADDR;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HBURST" *) (* DONT_TOUCH *) wire [2:0]axi_ahblite_bridge_0_M_AHB_HBURST;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HMASTLOCK" *) (* DONT_TOUCH *) wire axi_ahblite_bridge_0_M_AHB_HMASTLOCK;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HPROT" *) (* DONT_TOUCH *) wire [3:0]axi_ahblite_bridge_0_M_AHB_HPROT;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HRDATA" *) (* DONT_TOUCH *) wire [31:0]axi_ahblite_bridge_0_M_AHB_HRDATA;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HREADY" *) (* DONT_TOUCH *) wire axi_ahblite_bridge_0_M_AHB_HREADY;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HRESP" *) (* DONT_TOUCH *) wire axi_ahblite_bridge_0_M_AHB_HRESP;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HSIZE" *) (* DONT_TOUCH *) wire [2:0]axi_ahblite_bridge_0_M_AHB_HSIZE;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HTRANS" *) (* DONT_TOUCH *) wire [1:0]axi_ahblite_bridge_0_M_AHB_HTRANS;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HWDATA" *) (* DONT_TOUCH *) wire [31:0]axi_ahblite_bridge_0_M_AHB_HWDATA;
  (* CONN_BUS_INFO = "axi_ahblite_bridge_0_M_AHB xilinx.com:interface:ahblite:2.0 None HWRITE" *) (* DONT_TOUCH *) wire axi_ahblite_bridge_0_M_AHB_HWRITE;
  wire [7:0]axi_gpio_0_GPIO_TRI_I;
  wire [39:0]ps8_0_axi_periph_M00_AXI_ARADDR;
  wire ps8_0_axi_periph_M00_AXI_ARREADY;
  wire ps8_0_axi_periph_M00_AXI_ARVALID;
  wire [39:0]ps8_0_axi_periph_M00_AXI_AWADDR;
  wire ps8_0_axi_periph_M00_AXI_AWREADY;
  wire ps8_0_axi_periph_M00_AXI_AWVALID;
  wire ps8_0_axi_periph_M00_AXI_BREADY;
  wire [1:0]ps8_0_axi_periph_M00_AXI_BRESP;
  wire ps8_0_axi_periph_M00_AXI_BVALID;
  wire [31:0]ps8_0_axi_periph_M00_AXI_RDATA;
  wire ps8_0_axi_periph_M00_AXI_RREADY;
  wire [1:0]ps8_0_axi_periph_M00_AXI_RRESP;
  wire ps8_0_axi_periph_M00_AXI_RVALID;
  wire [31:0]ps8_0_axi_periph_M00_AXI_WDATA;
  wire ps8_0_axi_periph_M00_AXI_WREADY;
  wire [3:0]ps8_0_axi_periph_M00_AXI_WSTRB;
  wire ps8_0_axi_periph_M00_AXI_WVALID;
  wire [0:0]rst_ps8_0_75M_peripheral_aresetn;
  wire [0:0]rst_ps8_0_75M_peripheral_reset;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARSIZE;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWSIZE;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWVALID;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RDATA;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WDATA;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WREADY;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WSTRB;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WVALID;
  wire zynq_ultra_ps_e_0_pl_clk0;
  wire zynq_ultra_ps_e_0_pl_resetn0;

  assign AHB_INTERFACE_0_1_HADDR = AHB_INTERFACE_0_haddr[31:0];
  assign AHB_INTERFACE_0_1_HBURST = AHB_INTERFACE_0_hburst[2:0];
  assign AHB_INTERFACE_0_1_HPROT = AHB_INTERFACE_0_hprot[3:0];
  assign AHB_INTERFACE_0_1_HREADY_IN = AHB_INTERFACE_0_hready_in;
  assign AHB_INTERFACE_0_1_HSIZE = AHB_INTERFACE_0_hsize[2:0];
  assign AHB_INTERFACE_0_1_HTRANS = AHB_INTERFACE_0_htrans[1:0];
  assign AHB_INTERFACE_0_1_HWDATA = AHB_INTERFACE_0_hwdata[63:0];
  assign AHB_INTERFACE_0_1_HWRITE = AHB_INTERFACE_0_hwrite;
  assign AHB_INTERFACE_0_1_SEL = AHB_INTERFACE_0_sel;
  assign AHB_INTERFACE_0_hrdata[63:0] = AHB_INTERFACE_0_1_HRDATA;
  assign AHB_INTERFACE_0_hready_out = AHB_INTERFACE_0_1_HREADY_OUT;
  assign AHB_INTERFACE_0_hresp = AHB_INTERFACE_0_1_HRESP;
  assign M_AHB_0_haddr[31:0] = axi_ahblite_bridge_0_M_AHB_HADDR;
  assign M_AHB_0_hburst[2:0] = axi_ahblite_bridge_0_M_AHB_HBURST;
  assign M_AHB_0_hmastlock = axi_ahblite_bridge_0_M_AHB_HMASTLOCK;
  assign M_AHB_0_hprot[3:0] = axi_ahblite_bridge_0_M_AHB_HPROT;
  assign M_AHB_0_hsize[2:0] = axi_ahblite_bridge_0_M_AHB_HSIZE;
  assign M_AHB_0_htrans[1:0] = axi_ahblite_bridge_0_M_AHB_HTRANS;
  assign M_AHB_0_hwdata[31:0] = axi_ahblite_bridge_0_M_AHB_HWDATA;
  assign M_AHB_0_hwrite = axi_ahblite_bridge_0_M_AHB_HWRITE;
  assign axi_ahblite_bridge_0_M_AHB_HRDATA = M_AHB_0_hrdata[31:0];
  assign axi_ahblite_bridge_0_M_AHB_HREADY = M_AHB_0_hready;
  assign axi_ahblite_bridge_0_M_AHB_HRESP = M_AHB_0_hresp;
  assign axi_gpio_0_GPIO_TRI_I = dip_switches_8bits_tri_i[7:0];
  assign peripheral_reset_0[0] = rst_ps8_0_75M_peripheral_reset;
  assign pl_clk0 = zynq_ultra_ps_e_0_pl_clk0;
  zynqmpsoc_ahblite_axi_bridge_0_0 ahblite_axi_bridge_0
       (.m_axi_araddr(ahblite_axi_bridge_0_M_AXI_ARADDR),
        .m_axi_arburst(ahblite_axi_bridge_0_M_AXI_ARBURST),
        .m_axi_arcache(ahblite_axi_bridge_0_M_AXI_ARCACHE),
        .m_axi_arid(ahblite_axi_bridge_0_M_AXI_ARID),
        .m_axi_arlen(ahblite_axi_bridge_0_M_AXI_ARLEN),
        .m_axi_arlock(ahblite_axi_bridge_0_M_AXI_ARLOCK),
        .m_axi_arprot(ahblite_axi_bridge_0_M_AXI_ARPROT),
        .m_axi_arready(ahblite_axi_bridge_0_M_AXI_ARREADY),
        .m_axi_arsize(ahblite_axi_bridge_0_M_AXI_ARSIZE),
        .m_axi_arvalid(ahblite_axi_bridge_0_M_AXI_ARVALID),
        .m_axi_awaddr(ahblite_axi_bridge_0_M_AXI_AWADDR),
        .m_axi_awburst(ahblite_axi_bridge_0_M_AXI_AWBURST),
        .m_axi_awcache(ahblite_axi_bridge_0_M_AXI_AWCACHE),
        .m_axi_awid(ahblite_axi_bridge_0_M_AXI_AWID),
        .m_axi_awlen(ahblite_axi_bridge_0_M_AXI_AWLEN),
        .m_axi_awlock(ahblite_axi_bridge_0_M_AXI_AWLOCK),
        .m_axi_awprot(ahblite_axi_bridge_0_M_AXI_AWPROT),
        .m_axi_awready(ahblite_axi_bridge_0_M_AXI_AWREADY),
        .m_axi_awsize(ahblite_axi_bridge_0_M_AXI_AWSIZE),
        .m_axi_awvalid(ahblite_axi_bridge_0_M_AXI_AWVALID),
        .m_axi_bid(ahblite_axi_bridge_0_M_AXI_BID[3:0]),
        .m_axi_bready(ahblite_axi_bridge_0_M_AXI_BREADY),
        .m_axi_bresp(ahblite_axi_bridge_0_M_AXI_BRESP),
        .m_axi_bvalid(ahblite_axi_bridge_0_M_AXI_BVALID),
        .m_axi_rdata(ahblite_axi_bridge_0_M_AXI_RDATA),
        .m_axi_rid(ahblite_axi_bridge_0_M_AXI_RID[3:0]),
        .m_axi_rlast(ahblite_axi_bridge_0_M_AXI_RLAST),
        .m_axi_rready(ahblite_axi_bridge_0_M_AXI_RREADY),
        .m_axi_rresp(ahblite_axi_bridge_0_M_AXI_RRESP),
        .m_axi_rvalid(ahblite_axi_bridge_0_M_AXI_RVALID),
        .m_axi_wdata(ahblite_axi_bridge_0_M_AXI_WDATA),
        .m_axi_wlast(ahblite_axi_bridge_0_M_AXI_WLAST),
        .m_axi_wready(ahblite_axi_bridge_0_M_AXI_WREADY),
        .m_axi_wstrb(ahblite_axi_bridge_0_M_AXI_WSTRB),
        .m_axi_wvalid(ahblite_axi_bridge_0_M_AXI_WVALID),
        .s_ahb_haddr(AHB_INTERFACE_0_1_HADDR),
        .s_ahb_hburst(AHB_INTERFACE_0_1_HBURST),
        .s_ahb_hclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_ahb_hprot(AHB_INTERFACE_0_1_HPROT),
        .s_ahb_hrdata(AHB_INTERFACE_0_1_HRDATA),
        .s_ahb_hready_in(AHB_INTERFACE_0_1_HREADY_IN),
        .s_ahb_hready_out(AHB_INTERFACE_0_1_HREADY_OUT),
        .s_ahb_hresetn(rst_ps8_0_75M_peripheral_aresetn),
        .s_ahb_hresp(AHB_INTERFACE_0_1_HRESP),
        .s_ahb_hsel(AHB_INTERFACE_0_1_SEL),
        .s_ahb_hsize(AHB_INTERFACE_0_1_HSIZE),
        .s_ahb_htrans(AHB_INTERFACE_0_1_HTRANS),
        .s_ahb_hwdata(AHB_INTERFACE_0_1_HWDATA),
        .s_ahb_hwrite(AHB_INTERFACE_0_1_HWRITE));
  zynqmpsoc_axi_ahblite_bridge_0_0 axi_ahblite_bridge_0
       (.m_ahb_haddr(axi_ahblite_bridge_0_M_AHB_HADDR),
        .m_ahb_hburst(axi_ahblite_bridge_0_M_AHB_HBURST),
        .m_ahb_hmastlock(axi_ahblite_bridge_0_M_AHB_HMASTLOCK),
        .m_ahb_hprot(axi_ahblite_bridge_0_M_AHB_HPROT),
        .m_ahb_hrdata(axi_ahblite_bridge_0_M_AHB_HRDATA),
        .m_ahb_hready(axi_ahblite_bridge_0_M_AHB_HREADY),
        .m_ahb_hresp(axi_ahblite_bridge_0_M_AHB_HRESP),
        .m_ahb_hsize(axi_ahblite_bridge_0_M_AHB_HSIZE),
        .m_ahb_htrans(axi_ahblite_bridge_0_M_AHB_HTRANS),
        .m_ahb_hwdata(axi_ahblite_bridge_0_M_AHB_HWDATA),
        .m_ahb_hwrite(axi_ahblite_bridge_0_M_AHB_HWRITE),
        .s_axi_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR[31:0]),
        .s_axi_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .s_axi_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .s_axi_aresetn(rst_ps8_0_75M_peripheral_aresetn),
        .s_axi_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .s_axi_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .s_axi_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .s_axi_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .s_axi_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .s_axi_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .s_axi_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .s_axi_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR[31:0]),
        .s_axi_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .s_axi_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .s_axi_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .s_axi_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .s_axi_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .s_axi_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .s_axi_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .s_axi_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .s_axi_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .s_axi_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .s_axi_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .s_axi_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .s_axi_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .s_axi_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .s_axi_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .s_axi_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .s_axi_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .s_axi_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .s_axi_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .s_axi_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .s_axi_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .s_axi_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .s_axi_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .s_axi_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID));
  zynqmpsoc_axi_gpio_0_0 axi_gpio_0
       (.gpio_io_i(axi_gpio_0_GPIO_TRI_I),
        .s_axi_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_araddr(ps8_0_axi_periph_M00_AXI_ARADDR[8:0]),
        .s_axi_aresetn(rst_ps8_0_75M_peripheral_aresetn),
        .s_axi_arready(ps8_0_axi_periph_M00_AXI_ARREADY),
        .s_axi_arvalid(ps8_0_axi_periph_M00_AXI_ARVALID),
        .s_axi_awaddr(ps8_0_axi_periph_M00_AXI_AWADDR[8:0]),
        .s_axi_awready(ps8_0_axi_periph_M00_AXI_AWREADY),
        .s_axi_awvalid(ps8_0_axi_periph_M00_AXI_AWVALID),
        .s_axi_bready(ps8_0_axi_periph_M00_AXI_BREADY),
        .s_axi_bresp(ps8_0_axi_periph_M00_AXI_BRESP),
        .s_axi_bvalid(ps8_0_axi_periph_M00_AXI_BVALID),
        .s_axi_rdata(ps8_0_axi_periph_M00_AXI_RDATA),
        .s_axi_rready(ps8_0_axi_periph_M00_AXI_RREADY),
        .s_axi_rresp(ps8_0_axi_periph_M00_AXI_RRESP),
        .s_axi_rvalid(ps8_0_axi_periph_M00_AXI_RVALID),
        .s_axi_wdata(ps8_0_axi_periph_M00_AXI_WDATA),
        .s_axi_wready(ps8_0_axi_periph_M00_AXI_WREADY),
        .s_axi_wstrb(ps8_0_axi_periph_M00_AXI_WSTRB),
        .s_axi_wvalid(ps8_0_axi_periph_M00_AXI_WVALID));
  zynqmpsoc_ps8_0_axi_periph_0 ps8_0_axi_periph
       (.ACLK(zynq_ultra_ps_e_0_pl_clk0),
        .ARESETN(rst_ps8_0_75M_peripheral_aresetn),
        .M00_ACLK(zynq_ultra_ps_e_0_pl_clk0),
        .M00_ARESETN(rst_ps8_0_75M_peripheral_aresetn),
        .M00_AXI_araddr(ps8_0_axi_periph_M00_AXI_ARADDR),
        .M00_AXI_arready(ps8_0_axi_periph_M00_AXI_ARREADY),
        .M00_AXI_arvalid(ps8_0_axi_periph_M00_AXI_ARVALID),
        .M00_AXI_awaddr(ps8_0_axi_periph_M00_AXI_AWADDR),
        .M00_AXI_awready(ps8_0_axi_periph_M00_AXI_AWREADY),
        .M00_AXI_awvalid(ps8_0_axi_periph_M00_AXI_AWVALID),
        .M00_AXI_bready(ps8_0_axi_periph_M00_AXI_BREADY),
        .M00_AXI_bresp(ps8_0_axi_periph_M00_AXI_BRESP),
        .M00_AXI_bvalid(ps8_0_axi_periph_M00_AXI_BVALID),
        .M00_AXI_rdata(ps8_0_axi_periph_M00_AXI_RDATA),
        .M00_AXI_rready(ps8_0_axi_periph_M00_AXI_RREADY),
        .M00_AXI_rresp(ps8_0_axi_periph_M00_AXI_RRESP),
        .M00_AXI_rvalid(ps8_0_axi_periph_M00_AXI_RVALID),
        .M00_AXI_wdata(ps8_0_axi_periph_M00_AXI_WDATA),
        .M00_AXI_wready(ps8_0_axi_periph_M00_AXI_WREADY),
        .M00_AXI_wstrb(ps8_0_axi_periph_M00_AXI_WSTRB),
        .M00_AXI_wvalid(ps8_0_axi_periph_M00_AXI_WVALID),
        .S00_ACLK(zynq_ultra_ps_e_0_pl_clk0),
        .S00_ARESETN(rst_ps8_0_75M_peripheral_aresetn),
        .S00_AXI_araddr(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARADDR),
        .S00_AXI_arburst(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARBURST),
        .S00_AXI_arcache(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARCACHE),
        .S00_AXI_arid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARID),
        .S00_AXI_arlen(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLEN),
        .S00_AXI_arlock(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLOCK),
        .S00_AXI_arprot(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARPROT),
        .S00_AXI_arqos(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARQOS),
        .S00_AXI_arready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARREADY),
        .S00_AXI_arsize(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARSIZE),
        .S00_AXI_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARVALID),
        .S00_AXI_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWADDR),
        .S00_AXI_awburst(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWBURST),
        .S00_AXI_awcache(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWCACHE),
        .S00_AXI_awid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWID),
        .S00_AXI_awlen(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLEN),
        .S00_AXI_awlock(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLOCK),
        .S00_AXI_awprot(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWPROT),
        .S00_AXI_awqos(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWQOS),
        .S00_AXI_awready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWREADY),
        .S00_AXI_awsize(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWSIZE),
        .S00_AXI_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWVALID),
        .S00_AXI_bid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BID),
        .S00_AXI_bready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BREADY),
        .S00_AXI_bresp(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BRESP),
        .S00_AXI_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BVALID),
        .S00_AXI_rdata(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RDATA),
        .S00_AXI_rid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RID),
        .S00_AXI_rlast(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RLAST),
        .S00_AXI_rready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RREADY),
        .S00_AXI_rresp(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RRESP),
        .S00_AXI_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RVALID),
        .S00_AXI_wdata(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WDATA),
        .S00_AXI_wlast(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WLAST),
        .S00_AXI_wready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WREADY),
        .S00_AXI_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WSTRB),
        .S00_AXI_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WVALID));
  zynqmpsoc_rst_ps8_0_75M_0 rst_ps8_0_75M
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(zynq_ultra_ps_e_0_pl_resetn0),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_ps8_0_75M_peripheral_aresetn),
        .peripheral_reset(rst_ps8_0_75M_peripheral_reset),
        .slowest_sync_clk(zynq_ultra_ps_e_0_pl_clk0));
  zynqmpsoc_system_ila_0_0 system_ila_0
       (.SLOT_0_AHBLITE_haddr(axi_ahblite_bridge_0_M_AHB_HADDR[0]),
        .SLOT_0_AHBLITE_hburst(axi_ahblite_bridge_0_M_AHB_HBURST[0]),
        .SLOT_0_AHBLITE_hmastlock(axi_ahblite_bridge_0_M_AHB_HMASTLOCK),
        .SLOT_0_AHBLITE_hprot(axi_ahblite_bridge_0_M_AHB_HPROT[0]),
        .SLOT_0_AHBLITE_hrdata(axi_ahblite_bridge_0_M_AHB_HRDATA[0]),
        .SLOT_0_AHBLITE_hready(axi_ahblite_bridge_0_M_AHB_HREADY),
        .SLOT_0_AHBLITE_hresp(axi_ahblite_bridge_0_M_AHB_HRESP),
        .SLOT_0_AHBLITE_hsize(axi_ahblite_bridge_0_M_AHB_HSIZE[0]),
        .SLOT_0_AHBLITE_htrans(axi_ahblite_bridge_0_M_AHB_HTRANS[0]),
        .SLOT_0_AHBLITE_hwdata(axi_ahblite_bridge_0_M_AHB_HWDATA[0]),
        .SLOT_0_AHBLITE_hwrite(axi_ahblite_bridge_0_M_AHB_HWRITE),
        .SLOT_1_AHBLITE_haddr(AHB_INTERFACE_0_1_HADDR[0]),
        .SLOT_1_AHBLITE_hburst(AHB_INTERFACE_0_1_HBURST[0]),
        .SLOT_1_AHBLITE_hprot(AHB_INTERFACE_0_1_HPROT[0]),
        .SLOT_1_AHBLITE_hrdata(AHB_INTERFACE_0_1_HRDATA[0]),
        .SLOT_1_AHBLITE_hready_in(AHB_INTERFACE_0_1_HREADY_IN),
        .SLOT_1_AHBLITE_hready_out(AHB_INTERFACE_0_1_HREADY_OUT),
        .SLOT_1_AHBLITE_hresp(AHB_INTERFACE_0_1_HRESP),
        .SLOT_1_AHBLITE_hsize(AHB_INTERFACE_0_1_HSIZE[0]),
        .SLOT_1_AHBLITE_htrans(AHB_INTERFACE_0_1_HTRANS[0]),
        .SLOT_1_AHBLITE_hwdata(AHB_INTERFACE_0_1_HWDATA[0]),
        .SLOT_1_AHBLITE_hwrite(AHB_INTERFACE_0_1_HWRITE),
        .SLOT_1_AHBLITE_sel(AHB_INTERFACE_0_1_SEL),
        .clk(zynq_ultra_ps_e_0_pl_clk0));
  zynqmpsoc_zynq_ultra_ps_e_0_0 zynq_ultra_ps_e_0
       (.maxigp0_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR),
        .maxigp0_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .maxigp0_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .maxigp0_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .maxigp0_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .maxigp0_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .maxigp0_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .maxigp0_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .maxigp0_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .maxigp0_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .maxigp0_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR),
        .maxigp0_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .maxigp0_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .maxigp0_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .maxigp0_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .maxigp0_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .maxigp0_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .maxigp0_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .maxigp0_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .maxigp0_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .maxigp0_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .maxigp0_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .maxigp0_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .maxigp0_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .maxigp0_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .maxigp0_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .maxigp0_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .maxigp0_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .maxigp0_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .maxigp0_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .maxigp0_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .maxigp0_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .maxigp0_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .maxigp0_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .maxigp0_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID),
        .maxigp1_araddr(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARADDR),
        .maxigp1_arburst(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARBURST),
        .maxigp1_arcache(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARCACHE),
        .maxigp1_arid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARID),
        .maxigp1_arlen(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLEN),
        .maxigp1_arlock(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLOCK),
        .maxigp1_arprot(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARPROT),
        .maxigp1_arqos(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARQOS),
        .maxigp1_arready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARREADY),
        .maxigp1_arsize(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARSIZE),
        .maxigp1_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARVALID),
        .maxigp1_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWADDR),
        .maxigp1_awburst(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWBURST),
        .maxigp1_awcache(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWCACHE),
        .maxigp1_awid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWID),
        .maxigp1_awlen(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLEN),
        .maxigp1_awlock(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLOCK),
        .maxigp1_awprot(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWPROT),
        .maxigp1_awqos(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWQOS),
        .maxigp1_awready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWREADY),
        .maxigp1_awsize(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWSIZE),
        .maxigp1_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWVALID),
        .maxigp1_bid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BID),
        .maxigp1_bready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BREADY),
        .maxigp1_bresp(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BRESP),
        .maxigp1_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BVALID),
        .maxigp1_rdata(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RDATA),
        .maxigp1_rid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RID),
        .maxigp1_rlast(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RLAST),
        .maxigp1_rready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RREADY),
        .maxigp1_rresp(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RRESP),
        .maxigp1_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RVALID),
        .maxigp1_wdata(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WDATA),
        .maxigp1_wlast(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WLAST),
        .maxigp1_wready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WREADY),
        .maxigp1_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WSTRB),
        .maxigp1_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WVALID),
        .maxihpm0_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .maxihpm1_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .pl_clk0(zynq_ultra_ps_e_0_pl_clk0),
        .pl_resetn0(zynq_ultra_ps_e_0_pl_resetn0),
        .saxigp0_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,ahblite_axi_bridge_0_M_AXI_ARADDR}),
        .saxigp0_arburst(ahblite_axi_bridge_0_M_AXI_ARBURST),
        .saxigp0_arcache(ahblite_axi_bridge_0_M_AXI_ARCACHE),
        .saxigp0_arid({1'b0,1'b0,ahblite_axi_bridge_0_M_AXI_ARID}),
        .saxigp0_arlen(ahblite_axi_bridge_0_M_AXI_ARLEN),
        .saxigp0_arlock(ahblite_axi_bridge_0_M_AXI_ARLOCK),
        .saxigp0_arprot(ahblite_axi_bridge_0_M_AXI_ARPROT),
        .saxigp0_arqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp0_arready(ahblite_axi_bridge_0_M_AXI_ARREADY),
        .saxigp0_arsize(ahblite_axi_bridge_0_M_AXI_ARSIZE),
        .saxigp0_aruser(1'b0),
        .saxigp0_arvalid(ahblite_axi_bridge_0_M_AXI_ARVALID),
        .saxigp0_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,ahblite_axi_bridge_0_M_AXI_AWADDR}),
        .saxigp0_awburst(ahblite_axi_bridge_0_M_AXI_AWBURST),
        .saxigp0_awcache(ahblite_axi_bridge_0_M_AXI_AWCACHE),
        .saxigp0_awid({1'b0,1'b0,ahblite_axi_bridge_0_M_AXI_AWID}),
        .saxigp0_awlen(ahblite_axi_bridge_0_M_AXI_AWLEN),
        .saxigp0_awlock(ahblite_axi_bridge_0_M_AXI_AWLOCK),
        .saxigp0_awprot(ahblite_axi_bridge_0_M_AXI_AWPROT),
        .saxigp0_awqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp0_awready(ahblite_axi_bridge_0_M_AXI_AWREADY),
        .saxigp0_awsize(ahblite_axi_bridge_0_M_AXI_AWSIZE),
        .saxigp0_awuser(1'b0),
        .saxigp0_awvalid(ahblite_axi_bridge_0_M_AXI_AWVALID),
        .saxigp0_bid(ahblite_axi_bridge_0_M_AXI_BID),
        .saxigp0_bready(ahblite_axi_bridge_0_M_AXI_BREADY),
        .saxigp0_bresp(ahblite_axi_bridge_0_M_AXI_BRESP),
        .saxigp0_bvalid(ahblite_axi_bridge_0_M_AXI_BVALID),
        .saxigp0_rdata(ahblite_axi_bridge_0_M_AXI_RDATA),
        .saxigp0_rid(ahblite_axi_bridge_0_M_AXI_RID),
        .saxigp0_rlast(ahblite_axi_bridge_0_M_AXI_RLAST),
        .saxigp0_rready(ahblite_axi_bridge_0_M_AXI_RREADY),
        .saxigp0_rresp(ahblite_axi_bridge_0_M_AXI_RRESP),
        .saxigp0_rvalid(ahblite_axi_bridge_0_M_AXI_RVALID),
        .saxigp0_wdata(ahblite_axi_bridge_0_M_AXI_WDATA),
        .saxigp0_wlast(ahblite_axi_bridge_0_M_AXI_WLAST),
        .saxigp0_wready(ahblite_axi_bridge_0_M_AXI_WREADY),
        .saxigp0_wstrb(ahblite_axi_bridge_0_M_AXI_WSTRB),
        .saxigp0_wvalid(ahblite_axi_bridge_0_M_AXI_WVALID),
        .saxihpc0_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0));
endmodule

module zynqmpsoc_ps8_0_axi_periph_0
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid);
  input ACLK;
  input ARESETN;
  input M00_ACLK;
  input M00_ARESETN;
  output [39:0]M00_AXI_araddr;
  input M00_AXI_arready;
  output M00_AXI_arvalid;
  output [39:0]M00_AXI_awaddr;
  input M00_AXI_awready;
  output M00_AXI_awvalid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input M00_AXI_wready;
  output [3:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input S00_ACLK;
  input S00_ARESETN;
  input [39:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [15:0]S00_AXI_arid;
  input [7:0]S00_AXI_arlen;
  input [0:0]S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input S00_AXI_arvalid;
  input [39:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [15:0]S00_AXI_awid;
  input [7:0]S00_AXI_awlen;
  input [0:0]S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input S00_AXI_awvalid;
  output [15:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  output [15:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;

  wire S00_ACLK_1;
  wire S00_ARESETN_1;
  wire ps8_0_axi_periph_ACLK_net;
  wire ps8_0_axi_periph_ARESETN_net;
  wire [39:0]ps8_0_axi_periph_to_s00_couplers_ARADDR;
  wire [1:0]ps8_0_axi_periph_to_s00_couplers_ARBURST;
  wire [3:0]ps8_0_axi_periph_to_s00_couplers_ARCACHE;
  wire [15:0]ps8_0_axi_periph_to_s00_couplers_ARID;
  wire [7:0]ps8_0_axi_periph_to_s00_couplers_ARLEN;
  wire [0:0]ps8_0_axi_periph_to_s00_couplers_ARLOCK;
  wire [2:0]ps8_0_axi_periph_to_s00_couplers_ARPROT;
  wire [3:0]ps8_0_axi_periph_to_s00_couplers_ARQOS;
  wire ps8_0_axi_periph_to_s00_couplers_ARREADY;
  wire [2:0]ps8_0_axi_periph_to_s00_couplers_ARSIZE;
  wire ps8_0_axi_periph_to_s00_couplers_ARVALID;
  wire [39:0]ps8_0_axi_periph_to_s00_couplers_AWADDR;
  wire [1:0]ps8_0_axi_periph_to_s00_couplers_AWBURST;
  wire [3:0]ps8_0_axi_periph_to_s00_couplers_AWCACHE;
  wire [15:0]ps8_0_axi_periph_to_s00_couplers_AWID;
  wire [7:0]ps8_0_axi_periph_to_s00_couplers_AWLEN;
  wire [0:0]ps8_0_axi_periph_to_s00_couplers_AWLOCK;
  wire [2:0]ps8_0_axi_periph_to_s00_couplers_AWPROT;
  wire [3:0]ps8_0_axi_periph_to_s00_couplers_AWQOS;
  wire ps8_0_axi_periph_to_s00_couplers_AWREADY;
  wire [2:0]ps8_0_axi_periph_to_s00_couplers_AWSIZE;
  wire ps8_0_axi_periph_to_s00_couplers_AWVALID;
  wire [15:0]ps8_0_axi_periph_to_s00_couplers_BID;
  wire ps8_0_axi_periph_to_s00_couplers_BREADY;
  wire [1:0]ps8_0_axi_periph_to_s00_couplers_BRESP;
  wire ps8_0_axi_periph_to_s00_couplers_BVALID;
  wire [31:0]ps8_0_axi_periph_to_s00_couplers_RDATA;
  wire [15:0]ps8_0_axi_periph_to_s00_couplers_RID;
  wire ps8_0_axi_periph_to_s00_couplers_RLAST;
  wire ps8_0_axi_periph_to_s00_couplers_RREADY;
  wire [1:0]ps8_0_axi_periph_to_s00_couplers_RRESP;
  wire ps8_0_axi_periph_to_s00_couplers_RVALID;
  wire [31:0]ps8_0_axi_periph_to_s00_couplers_WDATA;
  wire ps8_0_axi_periph_to_s00_couplers_WLAST;
  wire ps8_0_axi_periph_to_s00_couplers_WREADY;
  wire [3:0]ps8_0_axi_periph_to_s00_couplers_WSTRB;
  wire ps8_0_axi_periph_to_s00_couplers_WVALID;
  wire [39:0]s00_couplers_to_ps8_0_axi_periph_ARADDR;
  wire s00_couplers_to_ps8_0_axi_periph_ARREADY;
  wire s00_couplers_to_ps8_0_axi_periph_ARVALID;
  wire [39:0]s00_couplers_to_ps8_0_axi_periph_AWADDR;
  wire s00_couplers_to_ps8_0_axi_periph_AWREADY;
  wire s00_couplers_to_ps8_0_axi_periph_AWVALID;
  wire s00_couplers_to_ps8_0_axi_periph_BREADY;
  wire [1:0]s00_couplers_to_ps8_0_axi_periph_BRESP;
  wire s00_couplers_to_ps8_0_axi_periph_BVALID;
  wire [31:0]s00_couplers_to_ps8_0_axi_periph_RDATA;
  wire s00_couplers_to_ps8_0_axi_periph_RREADY;
  wire [1:0]s00_couplers_to_ps8_0_axi_periph_RRESP;
  wire s00_couplers_to_ps8_0_axi_periph_RVALID;
  wire [31:0]s00_couplers_to_ps8_0_axi_periph_WDATA;
  wire s00_couplers_to_ps8_0_axi_periph_WREADY;
  wire [3:0]s00_couplers_to_ps8_0_axi_periph_WSTRB;
  wire s00_couplers_to_ps8_0_axi_periph_WVALID;

  assign M00_AXI_araddr[39:0] = s00_couplers_to_ps8_0_axi_periph_ARADDR;
  assign M00_AXI_arvalid = s00_couplers_to_ps8_0_axi_periph_ARVALID;
  assign M00_AXI_awaddr[39:0] = s00_couplers_to_ps8_0_axi_periph_AWADDR;
  assign M00_AXI_awvalid = s00_couplers_to_ps8_0_axi_periph_AWVALID;
  assign M00_AXI_bready = s00_couplers_to_ps8_0_axi_periph_BREADY;
  assign M00_AXI_rready = s00_couplers_to_ps8_0_axi_periph_RREADY;
  assign M00_AXI_wdata[31:0] = s00_couplers_to_ps8_0_axi_periph_WDATA;
  assign M00_AXI_wstrb[3:0] = s00_couplers_to_ps8_0_axi_periph_WSTRB;
  assign M00_AXI_wvalid = s00_couplers_to_ps8_0_axi_periph_WVALID;
  assign S00_ACLK_1 = S00_ACLK;
  assign S00_ARESETN_1 = S00_ARESETN;
  assign S00_AXI_arready = ps8_0_axi_periph_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = ps8_0_axi_periph_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[15:0] = ps8_0_axi_periph_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = ps8_0_axi_periph_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = ps8_0_axi_periph_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[31:0] = ps8_0_axi_periph_to_s00_couplers_RDATA;
  assign S00_AXI_rid[15:0] = ps8_0_axi_periph_to_s00_couplers_RID;
  assign S00_AXI_rlast = ps8_0_axi_periph_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = ps8_0_axi_periph_to_s00_couplers_RRESP;
  assign S00_AXI_rvalid = ps8_0_axi_periph_to_s00_couplers_RVALID;
  assign S00_AXI_wready = ps8_0_axi_periph_to_s00_couplers_WREADY;
  assign ps8_0_axi_periph_ACLK_net = M00_ACLK;
  assign ps8_0_axi_periph_ARESETN_net = M00_ARESETN;
  assign ps8_0_axi_periph_to_s00_couplers_ARADDR = S00_AXI_araddr[39:0];
  assign ps8_0_axi_periph_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign ps8_0_axi_periph_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign ps8_0_axi_periph_to_s00_couplers_ARID = S00_AXI_arid[15:0];
  assign ps8_0_axi_periph_to_s00_couplers_ARLEN = S00_AXI_arlen[7:0];
  assign ps8_0_axi_periph_to_s00_couplers_ARLOCK = S00_AXI_arlock[0];
  assign ps8_0_axi_periph_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign ps8_0_axi_periph_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign ps8_0_axi_periph_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign ps8_0_axi_periph_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign ps8_0_axi_periph_to_s00_couplers_AWADDR = S00_AXI_awaddr[39:0];
  assign ps8_0_axi_periph_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign ps8_0_axi_periph_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign ps8_0_axi_periph_to_s00_couplers_AWID = S00_AXI_awid[15:0];
  assign ps8_0_axi_periph_to_s00_couplers_AWLEN = S00_AXI_awlen[7:0];
  assign ps8_0_axi_periph_to_s00_couplers_AWLOCK = S00_AXI_awlock[0];
  assign ps8_0_axi_periph_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign ps8_0_axi_periph_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign ps8_0_axi_periph_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign ps8_0_axi_periph_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign ps8_0_axi_periph_to_s00_couplers_BREADY = S00_AXI_bready;
  assign ps8_0_axi_periph_to_s00_couplers_RREADY = S00_AXI_rready;
  assign ps8_0_axi_periph_to_s00_couplers_WDATA = S00_AXI_wdata[31:0];
  assign ps8_0_axi_periph_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign ps8_0_axi_periph_to_s00_couplers_WSTRB = S00_AXI_wstrb[3:0];
  assign ps8_0_axi_periph_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign s00_couplers_to_ps8_0_axi_periph_ARREADY = M00_AXI_arready;
  assign s00_couplers_to_ps8_0_axi_periph_AWREADY = M00_AXI_awready;
  assign s00_couplers_to_ps8_0_axi_periph_BRESP = M00_AXI_bresp[1:0];
  assign s00_couplers_to_ps8_0_axi_periph_BVALID = M00_AXI_bvalid;
  assign s00_couplers_to_ps8_0_axi_periph_RDATA = M00_AXI_rdata[31:0];
  assign s00_couplers_to_ps8_0_axi_periph_RRESP = M00_AXI_rresp[1:0];
  assign s00_couplers_to_ps8_0_axi_periph_RVALID = M00_AXI_rvalid;
  assign s00_couplers_to_ps8_0_axi_periph_WREADY = M00_AXI_wready;
  s00_couplers_imp_17VQRNZ s00_couplers
       (.M_ACLK(ps8_0_axi_periph_ACLK_net),
        .M_ARESETN(ps8_0_axi_periph_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_ps8_0_axi_periph_ARADDR),
        .M_AXI_arready(s00_couplers_to_ps8_0_axi_periph_ARREADY),
        .M_AXI_arvalid(s00_couplers_to_ps8_0_axi_periph_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_ps8_0_axi_periph_AWADDR),
        .M_AXI_awready(s00_couplers_to_ps8_0_axi_periph_AWREADY),
        .M_AXI_awvalid(s00_couplers_to_ps8_0_axi_periph_AWVALID),
        .M_AXI_bready(s00_couplers_to_ps8_0_axi_periph_BREADY),
        .M_AXI_bresp(s00_couplers_to_ps8_0_axi_periph_BRESP),
        .M_AXI_bvalid(s00_couplers_to_ps8_0_axi_periph_BVALID),
        .M_AXI_rdata(s00_couplers_to_ps8_0_axi_periph_RDATA),
        .M_AXI_rready(s00_couplers_to_ps8_0_axi_periph_RREADY),
        .M_AXI_rresp(s00_couplers_to_ps8_0_axi_periph_RRESP),
        .M_AXI_rvalid(s00_couplers_to_ps8_0_axi_periph_RVALID),
        .M_AXI_wdata(s00_couplers_to_ps8_0_axi_periph_WDATA),
        .M_AXI_wready(s00_couplers_to_ps8_0_axi_periph_WREADY),
        .M_AXI_wstrb(s00_couplers_to_ps8_0_axi_periph_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_ps8_0_axi_periph_WVALID),
        .S_ACLK(S00_ACLK_1),
        .S_ARESETN(S00_ARESETN_1),
        .S_AXI_araddr(ps8_0_axi_periph_to_s00_couplers_ARADDR),
        .S_AXI_arburst(ps8_0_axi_periph_to_s00_couplers_ARBURST),
        .S_AXI_arcache(ps8_0_axi_periph_to_s00_couplers_ARCACHE),
        .S_AXI_arid(ps8_0_axi_periph_to_s00_couplers_ARID),
        .S_AXI_arlen(ps8_0_axi_periph_to_s00_couplers_ARLEN),
        .S_AXI_arlock(ps8_0_axi_periph_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(ps8_0_axi_periph_to_s00_couplers_ARPROT),
        .S_AXI_arqos(ps8_0_axi_periph_to_s00_couplers_ARQOS),
        .S_AXI_arready(ps8_0_axi_periph_to_s00_couplers_ARREADY),
        .S_AXI_arsize(ps8_0_axi_periph_to_s00_couplers_ARSIZE),
        .S_AXI_arvalid(ps8_0_axi_periph_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(ps8_0_axi_periph_to_s00_couplers_AWADDR),
        .S_AXI_awburst(ps8_0_axi_periph_to_s00_couplers_AWBURST),
        .S_AXI_awcache(ps8_0_axi_periph_to_s00_couplers_AWCACHE),
        .S_AXI_awid(ps8_0_axi_periph_to_s00_couplers_AWID),
        .S_AXI_awlen(ps8_0_axi_periph_to_s00_couplers_AWLEN),
        .S_AXI_awlock(ps8_0_axi_periph_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(ps8_0_axi_periph_to_s00_couplers_AWPROT),
        .S_AXI_awqos(ps8_0_axi_periph_to_s00_couplers_AWQOS),
        .S_AXI_awready(ps8_0_axi_periph_to_s00_couplers_AWREADY),
        .S_AXI_awsize(ps8_0_axi_periph_to_s00_couplers_AWSIZE),
        .S_AXI_awvalid(ps8_0_axi_periph_to_s00_couplers_AWVALID),
        .S_AXI_bid(ps8_0_axi_periph_to_s00_couplers_BID),
        .S_AXI_bready(ps8_0_axi_periph_to_s00_couplers_BREADY),
        .S_AXI_bresp(ps8_0_axi_periph_to_s00_couplers_BRESP),
        .S_AXI_bvalid(ps8_0_axi_periph_to_s00_couplers_BVALID),
        .S_AXI_rdata(ps8_0_axi_periph_to_s00_couplers_RDATA),
        .S_AXI_rid(ps8_0_axi_periph_to_s00_couplers_RID),
        .S_AXI_rlast(ps8_0_axi_periph_to_s00_couplers_RLAST),
        .S_AXI_rready(ps8_0_axi_periph_to_s00_couplers_RREADY),
        .S_AXI_rresp(ps8_0_axi_periph_to_s00_couplers_RRESP),
        .S_AXI_rvalid(ps8_0_axi_periph_to_s00_couplers_RVALID),
        .S_AXI_wdata(ps8_0_axi_periph_to_s00_couplers_WDATA),
        .S_AXI_wlast(ps8_0_axi_periph_to_s00_couplers_WLAST),
        .S_AXI_wready(ps8_0_axi_periph_to_s00_couplers_WREADY),
        .S_AXI_wstrb(ps8_0_axi_periph_to_s00_couplers_WSTRB),
        .S_AXI_wvalid(ps8_0_axi_periph_to_s00_couplers_WVALID));
endmodule
