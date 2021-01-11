// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
// Date        : Mon Jan 11 12:10:11 2021
// Host        : skie running 64-bit Ubuntu 18.04.5 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/jescobedo/repos/juanesp/socs/xilinx-zcu102-xczu9eg/vivado/esp-xilinx-zcu102-xczu9eg.srcs/sources_1/bd/zynqmpsoc/ip/zynqmpsoc_auto_pc_0/zynqmpsoc_auto_pc_0_sim_netlist.v
// Design      : zynqmpsoc_auto_pc_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "zynqmpsoc_auto_pc_0,axi_protocol_converter_v2_1_20_axi_protocol_converter,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "axi_protocol_converter_v2_1_20_axi_protocol_converter,Vivado 2019.2.1" *) 
(* NotValidForBitStream *)
module zynqmpsoc_auto_pc_0
   (aclk,
    aresetn,
    s_axi_awid,
    s_axi_awaddr,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awlock,
    s_axi_awcache,
    s_axi_awprot,
    s_axi_awregion,
    s_axi_awqos,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wlast,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bid,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_arid,
    s_axi_araddr,
    s_axi_arlen,
    s_axi_arsize,
    s_axi_arburst,
    s_axi_arlock,
    s_axi_arcache,
    s_axi_arprot,
    s_axi_arregion,
    s_axi_arqos,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rid,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rlast,
    s_axi_rvalid,
    s_axi_rready,
    m_axi_awaddr,
    m_axi_awprot,
    m_axi_awvalid,
    m_axi_awready,
    m_axi_wdata,
    m_axi_wstrb,
    m_axi_wvalid,
    m_axi_wready,
    m_axi_bresp,
    m_axi_bvalid,
    m_axi_bready,
    m_axi_araddr,
    m_axi_arprot,
    m_axi_arvalid,
    m_axi_arready,
    m_axi_rdata,
    m_axi_rresp,
    m_axi_rvalid,
    m_axi_rready);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, ASSOCIATED_BUSIF S_AXI:M_AXI, ASSOCIATED_RESET ARESETN, INSERT_VIP 0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST, POLARITY ACTIVE_LOW, INSERT_VIP 0, TYPE INTERCONNECT" *) input aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWID" *) input [15:0]s_axi_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWADDR" *) input [39:0]s_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWLEN" *) input [7:0]s_axi_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWSIZE" *) input [2:0]s_axi_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWBURST" *) input [1:0]s_axi_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWLOCK" *) input [0:0]s_axi_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWCACHE" *) input [3:0]s_axi_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWPROT" *) input [2:0]s_axi_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWREGION" *) input [3:0]s_axi_awregion;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWQOS" *) input [3:0]s_axi_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWVALID" *) input s_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWREADY" *) output s_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WDATA" *) input [31:0]s_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WSTRB" *) input [3:0]s_axi_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WLAST" *) input s_axi_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WVALID" *) input s_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WREADY" *) output s_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BID" *) output [15:0]s_axi_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BRESP" *) output [1:0]s_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BVALID" *) output s_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BREADY" *) input s_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARID" *) input [15:0]s_axi_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARADDR" *) input [39:0]s_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARLEN" *) input [7:0]s_axi_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARSIZE" *) input [2:0]s_axi_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARBURST" *) input [1:0]s_axi_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARLOCK" *) input [0:0]s_axi_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARCACHE" *) input [3:0]s_axi_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARPROT" *) input [2:0]s_axi_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARREGION" *) input [3:0]s_axi_arregion;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARQOS" *) input [3:0]s_axi_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARVALID" *) input s_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARREADY" *) output s_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RID" *) output [15:0]s_axi_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RDATA" *) output [31:0]s_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RRESP" *) output [1:0]s_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RLAST" *) output s_axi_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RVALID" *) output s_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 16, ADDR_WIDTH 40, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input s_axi_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWADDR" *) output [39:0]m_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWPROT" *) output [2:0]m_axi_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWVALID" *) output m_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWREADY" *) input m_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WDATA" *) output [31:0]m_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WSTRB" *) output [3:0]m_axi_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WVALID" *) output m_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WREADY" *) input m_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BRESP" *) input [1:0]m_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BVALID" *) input m_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BREADY" *) output m_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARADDR" *) output [39:0]m_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARPROT" *) output [2:0]m_axi_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARVALID" *) output m_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARREADY" *) input m_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RDATA" *) input [31:0]m_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RRESP" *) input [1:0]m_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RVALID" *) input m_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 75000000, ID_WIDTH 0, ADDR_WIDTH 40, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output m_axi_rready;

  wire aclk;
  wire aresetn;
  wire [39:0]m_axi_araddr;
  wire [2:0]m_axi_arprot;
  wire m_axi_arready;
  wire m_axi_arvalid;
  wire [39:0]m_axi_awaddr;
  wire [2:0]m_axi_awprot;
  wire m_axi_awready;
  wire m_axi_awvalid;
  wire m_axi_bready;
  wire [1:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire [31:0]m_axi_rdata;
  wire m_axi_rready;
  wire [1:0]m_axi_rresp;
  wire m_axi_rvalid;
  wire [31:0]m_axi_wdata;
  wire m_axi_wready;
  wire [3:0]m_axi_wstrb;
  wire m_axi_wvalid;
  wire [39:0]s_axi_araddr;
  wire [1:0]s_axi_arburst;
  wire [3:0]s_axi_arcache;
  wire [15:0]s_axi_arid;
  wire [7:0]s_axi_arlen;
  wire [0:0]s_axi_arlock;
  wire [2:0]s_axi_arprot;
  wire [3:0]s_axi_arqos;
  wire s_axi_arready;
  wire [3:0]s_axi_arregion;
  wire [2:0]s_axi_arsize;
  wire s_axi_arvalid;
  wire [39:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [3:0]s_axi_awcache;
  wire [15:0]s_axi_awid;
  wire [7:0]s_axi_awlen;
  wire [0:0]s_axi_awlock;
  wire [2:0]s_axi_awprot;
  wire [3:0]s_axi_awqos;
  wire s_axi_awready;
  wire [3:0]s_axi_awregion;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire [15:0]s_axi_bid;
  wire s_axi_bready;
  wire [1:0]s_axi_bresp;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire [15:0]s_axi_rid;
  wire s_axi_rlast;
  wire s_axi_rready;
  wire [1:0]s_axi_rresp;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire s_axi_wlast;
  wire s_axi_wready;
  wire [3:0]s_axi_wstrb;
  wire s_axi_wvalid;
  wire NLW_inst_m_axi_wlast_UNCONNECTED;
  wire [1:0]NLW_inst_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_arcache_UNCONNECTED;
  wire [15:0]NLW_inst_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_inst_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_arlock_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_inst_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_aruser_UNCONNECTED;
  wire [1:0]NLW_inst_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_awcache_UNCONNECTED;
  wire [15:0]NLW_inst_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_inst_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_awlock_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_inst_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_awuser_UNCONNECTED;
  wire [15:0]NLW_inst_m_axi_wid_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_wuser_UNCONNECTED;
  wire [0:0]NLW_inst_s_axi_buser_UNCONNECTED;
  wire [0:0]NLW_inst_s_axi_ruser_UNCONNECTED;

  (* C_AXI_ADDR_WIDTH = "40" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "32" *) 
  (* C_AXI_ID_WIDTH = "16" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_SUPPORTS_READ = "1" *) 
  (* C_AXI_SUPPORTS_USER_SIGNALS = "0" *) 
  (* C_AXI_SUPPORTS_WRITE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_IGNORE_ID = "0" *) 
  (* C_M_AXI_PROTOCOL = "2" *) 
  (* C_S_AXI_PROTOCOL = "0" *) 
  (* C_TRANSLATION_MODE = "2" *) 
  (* DowngradeIPIdentifiedWarnings = "yes" *) 
  (* P_AXI3 = "1" *) 
  (* P_AXI4 = "0" *) 
  (* P_AXILITE = "2" *) 
  (* P_AXILITE_SIZE = "3'b010" *) 
  (* P_CONVERSION = "2" *) 
  (* P_DECERR = "2'b11" *) 
  (* P_INCR = "2'b01" *) 
  (* P_PROTECTION = "1" *) 
  (* P_SLVERR = "2'b10" *) 
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_axi_protocol_converter inst
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arburst(NLW_inst_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_inst_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_inst_m_axi_arid_UNCONNECTED[15:0]),
        .m_axi_arlen(NLW_inst_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_inst_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(m_axi_arprot),
        .m_axi_arqos(NLW_inst_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(m_axi_arready),
        .m_axi_arregion(NLW_inst_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_inst_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_inst_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awburst(NLW_inst_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_inst_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_inst_m_axi_awid_UNCONNECTED[15:0]),
        .m_axi_awlen(NLW_inst_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_inst_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(m_axi_awprot),
        .m_axi_awqos(NLW_inst_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(m_axi_awready),
        .m_axi_awregion(NLW_inst_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_inst_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_inst_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_bid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_bready(m_axi_bready),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rlast(1'b1),
        .m_axi_rready(m_axi_rready),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wid(NLW_inst_m_axi_wid_UNCONNECTED[15:0]),
        .m_axi_wlast(NLW_inst_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(m_axi_wready),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wuser(NLW_inst_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(m_axi_wvalid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arcache(s_axi_arcache),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arlock(s_axi_arlock),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arqos(s_axi_arqos),
        .s_axi_arready(s_axi_arready),
        .s_axi_arregion(s_axi_arregion),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awcache(s_axi_awcache),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awlock(s_axi_awlock),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awqos(s_axi_awqos),
        .s_axi_awready(s_axi_awready),
        .s_axi_awregion(s_axi_awregion),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bid(s_axi_bid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_buser(NLW_inst_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rid(s_axi_rid),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_ruser(NLW_inst_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(s_axi_wvalid));
endmodule

(* C_AXI_ADDR_WIDTH = "40" *) (* C_AXI_ARUSER_WIDTH = "1" *) (* C_AXI_AWUSER_WIDTH = "1" *) 
(* C_AXI_BUSER_WIDTH = "1" *) (* C_AXI_DATA_WIDTH = "32" *) (* C_AXI_ID_WIDTH = "16" *) 
(* C_AXI_RUSER_WIDTH = "1" *) (* C_AXI_SUPPORTS_READ = "1" *) (* C_AXI_SUPPORTS_USER_SIGNALS = "0" *) 
(* C_AXI_SUPPORTS_WRITE = "1" *) (* C_AXI_WUSER_WIDTH = "1" *) (* C_FAMILY = "zynquplus" *) 
(* C_IGNORE_ID = "0" *) (* C_M_AXI_PROTOCOL = "2" *) (* C_S_AXI_PROTOCOL = "0" *) 
(* C_TRANSLATION_MODE = "2" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_axi_protocol_converter" *) 
(* P_AXI3 = "1" *) (* P_AXI4 = "0" *) (* P_AXILITE = "2" *) 
(* P_AXILITE_SIZE = "3'b010" *) (* P_CONVERSION = "2" *) (* P_DECERR = "2'b11" *) 
(* P_INCR = "2'b01" *) (* P_PROTECTION = "1" *) (* P_SLVERR = "2'b10" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_axi_protocol_converter
   (aclk,
    aresetn,
    s_axi_awid,
    s_axi_awaddr,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awlock,
    s_axi_awcache,
    s_axi_awprot,
    s_axi_awregion,
    s_axi_awqos,
    s_axi_awuser,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wid,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wlast,
    s_axi_wuser,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bid,
    s_axi_bresp,
    s_axi_buser,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_arid,
    s_axi_araddr,
    s_axi_arlen,
    s_axi_arsize,
    s_axi_arburst,
    s_axi_arlock,
    s_axi_arcache,
    s_axi_arprot,
    s_axi_arregion,
    s_axi_arqos,
    s_axi_aruser,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rid,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rlast,
    s_axi_ruser,
    s_axi_rvalid,
    s_axi_rready,
    m_axi_awid,
    m_axi_awaddr,
    m_axi_awlen,
    m_axi_awsize,
    m_axi_awburst,
    m_axi_awlock,
    m_axi_awcache,
    m_axi_awprot,
    m_axi_awregion,
    m_axi_awqos,
    m_axi_awuser,
    m_axi_awvalid,
    m_axi_awready,
    m_axi_wid,
    m_axi_wdata,
    m_axi_wstrb,
    m_axi_wlast,
    m_axi_wuser,
    m_axi_wvalid,
    m_axi_wready,
    m_axi_bid,
    m_axi_bresp,
    m_axi_buser,
    m_axi_bvalid,
    m_axi_bready,
    m_axi_arid,
    m_axi_araddr,
    m_axi_arlen,
    m_axi_arsize,
    m_axi_arburst,
    m_axi_arlock,
    m_axi_arcache,
    m_axi_arprot,
    m_axi_arregion,
    m_axi_arqos,
    m_axi_aruser,
    m_axi_arvalid,
    m_axi_arready,
    m_axi_rid,
    m_axi_rdata,
    m_axi_rresp,
    m_axi_rlast,
    m_axi_ruser,
    m_axi_rvalid,
    m_axi_rready);
  input aclk;
  input aresetn;
  input [15:0]s_axi_awid;
  input [39:0]s_axi_awaddr;
  input [7:0]s_axi_awlen;
  input [2:0]s_axi_awsize;
  input [1:0]s_axi_awburst;
  input [0:0]s_axi_awlock;
  input [3:0]s_axi_awcache;
  input [2:0]s_axi_awprot;
  input [3:0]s_axi_awregion;
  input [3:0]s_axi_awqos;
  input [0:0]s_axi_awuser;
  input s_axi_awvalid;
  output s_axi_awready;
  input [15:0]s_axi_wid;
  input [31:0]s_axi_wdata;
  input [3:0]s_axi_wstrb;
  input s_axi_wlast;
  input [0:0]s_axi_wuser;
  input s_axi_wvalid;
  output s_axi_wready;
  output [15:0]s_axi_bid;
  output [1:0]s_axi_bresp;
  output [0:0]s_axi_buser;
  output s_axi_bvalid;
  input s_axi_bready;
  input [15:0]s_axi_arid;
  input [39:0]s_axi_araddr;
  input [7:0]s_axi_arlen;
  input [2:0]s_axi_arsize;
  input [1:0]s_axi_arburst;
  input [0:0]s_axi_arlock;
  input [3:0]s_axi_arcache;
  input [2:0]s_axi_arprot;
  input [3:0]s_axi_arregion;
  input [3:0]s_axi_arqos;
  input [0:0]s_axi_aruser;
  input s_axi_arvalid;
  output s_axi_arready;
  output [15:0]s_axi_rid;
  output [31:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rlast;
  output [0:0]s_axi_ruser;
  output s_axi_rvalid;
  input s_axi_rready;
  output [15:0]m_axi_awid;
  output [39:0]m_axi_awaddr;
  output [7:0]m_axi_awlen;
  output [2:0]m_axi_awsize;
  output [1:0]m_axi_awburst;
  output [0:0]m_axi_awlock;
  output [3:0]m_axi_awcache;
  output [2:0]m_axi_awprot;
  output [3:0]m_axi_awregion;
  output [3:0]m_axi_awqos;
  output [0:0]m_axi_awuser;
  output m_axi_awvalid;
  input m_axi_awready;
  output [15:0]m_axi_wid;
  output [31:0]m_axi_wdata;
  output [3:0]m_axi_wstrb;
  output m_axi_wlast;
  output [0:0]m_axi_wuser;
  output m_axi_wvalid;
  input m_axi_wready;
  input [15:0]m_axi_bid;
  input [1:0]m_axi_bresp;
  input [0:0]m_axi_buser;
  input m_axi_bvalid;
  output m_axi_bready;
  output [15:0]m_axi_arid;
  output [39:0]m_axi_araddr;
  output [7:0]m_axi_arlen;
  output [2:0]m_axi_arsize;
  output [1:0]m_axi_arburst;
  output [0:0]m_axi_arlock;
  output [3:0]m_axi_arcache;
  output [2:0]m_axi_arprot;
  output [3:0]m_axi_arregion;
  output [3:0]m_axi_arqos;
  output [0:0]m_axi_aruser;
  output m_axi_arvalid;
  input m_axi_arready;
  input [15:0]m_axi_rid;
  input [31:0]m_axi_rdata;
  input [1:0]m_axi_rresp;
  input m_axi_rlast;
  input [0:0]m_axi_ruser;
  input m_axi_rvalid;
  output m_axi_rready;

  wire \<const0> ;
  wire \<const1> ;
  wire aclk;
  wire aresetn;
  wire [39:0]m_axi_araddr;
  wire [2:0]m_axi_arprot;
  wire m_axi_arready;
  wire m_axi_arvalid;
  wire [39:0]m_axi_awaddr;
  wire [2:0]m_axi_awprot;
  wire m_axi_awready;
  wire m_axi_awvalid;
  wire m_axi_bready;
  wire [1:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire [31:0]m_axi_rdata;
  wire m_axi_rready;
  wire [1:0]m_axi_rresp;
  wire m_axi_rvalid;
  wire m_axi_wready;
  wire [39:0]s_axi_araddr;
  wire [1:0]s_axi_arburst;
  wire [15:0]s_axi_arid;
  wire [7:0]s_axi_arlen;
  wire [2:0]s_axi_arprot;
  wire s_axi_arready;
  wire [2:0]s_axi_arsize;
  wire s_axi_arvalid;
  wire [39:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [15:0]s_axi_awid;
  wire [7:0]s_axi_awlen;
  wire [2:0]s_axi_awprot;
  wire s_axi_awready;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire [15:0]s_axi_bid;
  wire s_axi_bready;
  wire [1:0]s_axi_bresp;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire [15:0]s_axi_rid;
  wire s_axi_rlast;
  wire s_axi_rready;
  wire [1:0]s_axi_rresp;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire [3:0]s_axi_wstrb;
  wire s_axi_wvalid;

  assign m_axi_arburst[1] = \<const0> ;
  assign m_axi_arburst[0] = \<const1> ;
  assign m_axi_arcache[3] = \<const0> ;
  assign m_axi_arcache[2] = \<const0> ;
  assign m_axi_arcache[1] = \<const0> ;
  assign m_axi_arcache[0] = \<const0> ;
  assign m_axi_arid[15] = \<const0> ;
  assign m_axi_arid[14] = \<const0> ;
  assign m_axi_arid[13] = \<const0> ;
  assign m_axi_arid[12] = \<const0> ;
  assign m_axi_arid[11] = \<const0> ;
  assign m_axi_arid[10] = \<const0> ;
  assign m_axi_arid[9] = \<const0> ;
  assign m_axi_arid[8] = \<const0> ;
  assign m_axi_arid[7] = \<const0> ;
  assign m_axi_arid[6] = \<const0> ;
  assign m_axi_arid[5] = \<const0> ;
  assign m_axi_arid[4] = \<const0> ;
  assign m_axi_arid[3] = \<const0> ;
  assign m_axi_arid[2] = \<const0> ;
  assign m_axi_arid[1] = \<const0> ;
  assign m_axi_arid[0] = \<const0> ;
  assign m_axi_arlen[7] = \<const0> ;
  assign m_axi_arlen[6] = \<const0> ;
  assign m_axi_arlen[5] = \<const0> ;
  assign m_axi_arlen[4] = \<const0> ;
  assign m_axi_arlen[3] = \<const0> ;
  assign m_axi_arlen[2] = \<const0> ;
  assign m_axi_arlen[1] = \<const0> ;
  assign m_axi_arlen[0] = \<const0> ;
  assign m_axi_arlock[0] = \<const0> ;
  assign m_axi_arqos[3] = \<const0> ;
  assign m_axi_arqos[2] = \<const0> ;
  assign m_axi_arqos[1] = \<const0> ;
  assign m_axi_arqos[0] = \<const0> ;
  assign m_axi_arregion[3] = \<const0> ;
  assign m_axi_arregion[2] = \<const0> ;
  assign m_axi_arregion[1] = \<const0> ;
  assign m_axi_arregion[0] = \<const0> ;
  assign m_axi_arsize[2] = \<const0> ;
  assign m_axi_arsize[1] = \<const1> ;
  assign m_axi_arsize[0] = \<const0> ;
  assign m_axi_aruser[0] = \<const0> ;
  assign m_axi_awburst[1] = \<const0> ;
  assign m_axi_awburst[0] = \<const1> ;
  assign m_axi_awcache[3] = \<const0> ;
  assign m_axi_awcache[2] = \<const0> ;
  assign m_axi_awcache[1] = \<const0> ;
  assign m_axi_awcache[0] = \<const0> ;
  assign m_axi_awid[15] = \<const0> ;
  assign m_axi_awid[14] = \<const0> ;
  assign m_axi_awid[13] = \<const0> ;
  assign m_axi_awid[12] = \<const0> ;
  assign m_axi_awid[11] = \<const0> ;
  assign m_axi_awid[10] = \<const0> ;
  assign m_axi_awid[9] = \<const0> ;
  assign m_axi_awid[8] = \<const0> ;
  assign m_axi_awid[7] = \<const0> ;
  assign m_axi_awid[6] = \<const0> ;
  assign m_axi_awid[5] = \<const0> ;
  assign m_axi_awid[4] = \<const0> ;
  assign m_axi_awid[3] = \<const0> ;
  assign m_axi_awid[2] = \<const0> ;
  assign m_axi_awid[1] = \<const0> ;
  assign m_axi_awid[0] = \<const0> ;
  assign m_axi_awlen[7] = \<const0> ;
  assign m_axi_awlen[6] = \<const0> ;
  assign m_axi_awlen[5] = \<const0> ;
  assign m_axi_awlen[4] = \<const0> ;
  assign m_axi_awlen[3] = \<const0> ;
  assign m_axi_awlen[2] = \<const0> ;
  assign m_axi_awlen[1] = \<const0> ;
  assign m_axi_awlen[0] = \<const0> ;
  assign m_axi_awlock[0] = \<const0> ;
  assign m_axi_awqos[3] = \<const0> ;
  assign m_axi_awqos[2] = \<const0> ;
  assign m_axi_awqos[1] = \<const0> ;
  assign m_axi_awqos[0] = \<const0> ;
  assign m_axi_awregion[3] = \<const0> ;
  assign m_axi_awregion[2] = \<const0> ;
  assign m_axi_awregion[1] = \<const0> ;
  assign m_axi_awregion[0] = \<const0> ;
  assign m_axi_awsize[2] = \<const0> ;
  assign m_axi_awsize[1] = \<const1> ;
  assign m_axi_awsize[0] = \<const0> ;
  assign m_axi_awuser[0] = \<const0> ;
  assign m_axi_wdata[31:0] = s_axi_wdata;
  assign m_axi_wid[15] = \<const0> ;
  assign m_axi_wid[14] = \<const0> ;
  assign m_axi_wid[13] = \<const0> ;
  assign m_axi_wid[12] = \<const0> ;
  assign m_axi_wid[11] = \<const0> ;
  assign m_axi_wid[10] = \<const0> ;
  assign m_axi_wid[9] = \<const0> ;
  assign m_axi_wid[8] = \<const0> ;
  assign m_axi_wid[7] = \<const0> ;
  assign m_axi_wid[6] = \<const0> ;
  assign m_axi_wid[5] = \<const0> ;
  assign m_axi_wid[4] = \<const0> ;
  assign m_axi_wid[3] = \<const0> ;
  assign m_axi_wid[2] = \<const0> ;
  assign m_axi_wid[1] = \<const0> ;
  assign m_axi_wid[0] = \<const0> ;
  assign m_axi_wlast = \<const1> ;
  assign m_axi_wstrb[3:0] = s_axi_wstrb;
  assign m_axi_wuser[0] = \<const0> ;
  assign m_axi_wvalid = s_axi_wvalid;
  assign s_axi_buser[0] = \<const0> ;
  assign s_axi_ruser[0] = \<const0> ;
  assign s_axi_wready = m_axi_wready;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s \gen_axilite.gen_b2s_conv.axilite_b2s 
       (.Q({m_axi_awprot,m_axi_awaddr[39:12]}),
        .aclk(aclk),
        .aresetn(aresetn),
        .in({m_axi_rresp,m_axi_rdata}),
        .m_axi_araddr(m_axi_araddr[11:0]),
        .m_axi_arready(m_axi_arready),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_awaddr(m_axi_awaddr[11:0]),
        .m_axi_awready(m_axi_awready),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_bready(m_axi_bready),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_rready(m_axi_rready),
        .m_axi_rvalid(m_axi_rvalid),
        .\m_payload_i_reg[17] ({s_axi_bid,s_axi_bresp}),
        .\m_payload_i_reg[42] ({m_axi_arprot,m_axi_araddr[39:12]}),
        .\m_payload_i_reg[50] ({s_axi_rid,s_axi_rlast,s_axi_rresp,s_axi_rdata}),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arready(s_axi_arready),
        .s_axi_arsize(s_axi_arsize[1:0]),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awready(s_axi_awready),
        .s_axi_awsize(s_axi_awsize[1:0]),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rready(s_axi_rready),
        .s_axi_rvalid(s_axi_rvalid));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s
   (s_axi_awready,
    s_axi_rvalid,
    s_axi_bvalid,
    s_axi_arready,
    Q,
    \m_payload_i_reg[42] ,
    \m_payload_i_reg[17] ,
    \m_payload_i_reg[50] ,
    m_axi_bready,
    m_axi_arvalid,
    m_axi_rready,
    m_axi_awvalid,
    m_axi_awaddr,
    m_axi_araddr,
    s_axi_awvalid,
    s_axi_rready,
    s_axi_bready,
    s_axi_arvalid,
    aclk,
    in,
    s_axi_awid,
    s_axi_awlen,
    s_axi_awburst,
    s_axi_awsize,
    s_axi_awprot,
    s_axi_awaddr,
    m_axi_bresp,
    s_axi_arid,
    s_axi_arlen,
    s_axi_arburst,
    s_axi_arsize,
    s_axi_arprot,
    s_axi_araddr,
    m_axi_awready,
    m_axi_bvalid,
    m_axi_arready,
    m_axi_rvalid,
    aresetn);
  output s_axi_awready;
  output s_axi_rvalid;
  output s_axi_bvalid;
  output s_axi_arready;
  output [30:0]Q;
  output [30:0]\m_payload_i_reg[42] ;
  output [17:0]\m_payload_i_reg[17] ;
  output [50:0]\m_payload_i_reg[50] ;
  output m_axi_bready;
  output m_axi_arvalid;
  output m_axi_rready;
  output m_axi_awvalid;
  output [11:0]m_axi_awaddr;
  output [11:0]m_axi_araddr;
  input s_axi_awvalid;
  input s_axi_rready;
  input s_axi_bready;
  input s_axi_arvalid;
  input aclk;
  input [33:0]in;
  input [15:0]s_axi_awid;
  input [7:0]s_axi_awlen;
  input [1:0]s_axi_awburst;
  input [1:0]s_axi_awsize;
  input [2:0]s_axi_awprot;
  input [39:0]s_axi_awaddr;
  input [1:0]m_axi_bresp;
  input [15:0]s_axi_arid;
  input [7:0]s_axi_arlen;
  input [1:0]s_axi_arburst;
  input [1:0]s_axi_arsize;
  input [2:0]s_axi_arprot;
  input [39:0]s_axi_araddr;
  input m_axi_awready;
  input m_axi_bvalid;
  input m_axi_arready;
  input m_axi_rvalid;
  input aresetn;

  wire [30:0]Q;
  wire \RD.ar_channel_0_n_10 ;
  wire \RD.ar_channel_0_n_11 ;
  wire \RD.ar_channel_0_n_12 ;
  wire \RD.ar_channel_0_n_16 ;
  wire \RD.ar_channel_0_n_17 ;
  wire \RD.ar_channel_0_n_18 ;
  wire \RD.ar_channel_0_n_19 ;
  wire \RD.ar_channel_0_n_20 ;
  wire \RD.ar_channel_0_n_21 ;
  wire \RD.ar_channel_0_n_22 ;
  wire \RD.ar_channel_0_n_23 ;
  wire \RD.ar_channel_0_n_3 ;
  wire \RD.ar_channel_0_n_4 ;
  wire \RD.ar_channel_0_n_7 ;
  wire \RD.r_channel_0_n_0 ;
  wire \RD.r_channel_0_n_2 ;
  wire SI_REG_n_101;
  wire SI_REG_n_128;
  wire SI_REG_n_129;
  wire SI_REG_n_130;
  wire SI_REG_n_174;
  wire SI_REG_n_175;
  wire SI_REG_n_176;
  wire SI_REG_n_177;
  wire SI_REG_n_178;
  wire SI_REG_n_180;
  wire SI_REG_n_181;
  wire SI_REG_n_182;
  wire SI_REG_n_183;
  wire SI_REG_n_184;
  wire SI_REG_n_185;
  wire SI_REG_n_186;
  wire SI_REG_n_187;
  wire SI_REG_n_188;
  wire SI_REG_n_189;
  wire SI_REG_n_190;
  wire SI_REG_n_191;
  wire SI_REG_n_192;
  wire SI_REG_n_193;
  wire SI_REG_n_194;
  wire SI_REG_n_195;
  wire SI_REG_n_196;
  wire SI_REG_n_197;
  wire SI_REG_n_198;
  wire SI_REG_n_199;
  wire SI_REG_n_200;
  wire SI_REG_n_201;
  wire SI_REG_n_202;
  wire SI_REG_n_203;
  wire SI_REG_n_204;
  wire SI_REG_n_205;
  wire SI_REG_n_206;
  wire SI_REG_n_207;
  wire SI_REG_n_208;
  wire SI_REG_n_209;
  wire SI_REG_n_210;
  wire SI_REG_n_211;
  wire SI_REG_n_212;
  wire SI_REG_n_213;
  wire SI_REG_n_214;
  wire SI_REG_n_215;
  wire SI_REG_n_216;
  wire SI_REG_n_217;
  wire SI_REG_n_218;
  wire SI_REG_n_219;
  wire SI_REG_n_220;
  wire SI_REG_n_221;
  wire SI_REG_n_34;
  wire SI_REG_n_7;
  wire SI_REG_n_8;
  wire SI_REG_n_80;
  wire SI_REG_n_81;
  wire SI_REG_n_83;
  wire SI_REG_n_92;
  wire SI_REG_n_93;
  wire SI_REG_n_94;
  wire SI_REG_n_95;
  wire SI_REG_n_96;
  wire SI_REG_n_97;
  wire SI_REG_n_98;
  wire SI_REG_n_99;
  wire \WR.aw_channel_0_n_1 ;
  wire \WR.aw_channel_0_n_10 ;
  wire \WR.aw_channel_0_n_12 ;
  wire \WR.aw_channel_0_n_14 ;
  wire \WR.aw_channel_0_n_15 ;
  wire \WR.aw_channel_0_n_16 ;
  wire \WR.aw_channel_0_n_17 ;
  wire \WR.aw_channel_0_n_18 ;
  wire \WR.aw_channel_0_n_19 ;
  wire \WR.aw_channel_0_n_2 ;
  wire \WR.aw_channel_0_n_20 ;
  wire \WR.aw_channel_0_n_21 ;
  wire \WR.aw_channel_0_n_22 ;
  wire \WR.aw_channel_0_n_23 ;
  wire \WR.aw_channel_0_n_24 ;
  wire \WR.aw_channel_0_n_25 ;
  wire \WR.aw_channel_0_n_26 ;
  wire \WR.b_channel_0_n_3 ;
  wire \WR.b_channel_0_n_4 ;
  wire aclk;
  wire \ar.ar_pipe/p_1_in ;
  wire [1:0]\ar_cmd_fsm_0/state ;
  wire areset_d1;
  wire aresetn;
  wire \aw.aw_pipe/p_1_in ;
  wire [1:0]\aw_cmd_fsm_0/state ;
  wire [3:0]axaddr_wrap;
  wire [7:4]axlen;
  wire [1:0]axsize;
  wire [15:0]b_awid;
  wire [7:0]b_awlen;
  wire b_push;
  wire [1:0]\bid_fifo_0/cnt_read ;
  wire \cmd_translator_0/incr_cmd_0/sel_first ;
  wire \cmd_translator_0/incr_cmd_0/sel_first_2 ;
  wire \cmd_translator_0/incr_next_pending ;
  wire \cmd_translator_0/sel_first_i ;
  wire [0:0]\cmd_translator_0/wrap_cmd_0/axaddr_offset ;
  wire [0:0]\cmd_translator_0/wrap_cmd_0/axaddr_offset_0 ;
  wire [0:0]\cmd_translator_0/wrap_cmd_0/axaddr_offset_r ;
  wire [0:0]\cmd_translator_0/wrap_cmd_0/axaddr_offset_r_1 ;
  wire \cmd_translator_0/wrap_next_pending ;
  wire [33:0]in;
  wire [11:0]m_axi_araddr;
  wire m_axi_arready;
  wire m_axi_arvalid;
  wire [11:0]m_axi_awaddr;
  wire m_axi_awready;
  wire m_axi_awvalid;
  wire m_axi_bready;
  wire [1:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire m_axi_rready;
  wire m_axi_rvalid;
  wire [17:0]\m_payload_i_reg[17] ;
  wire [30:0]\m_payload_i_reg[42] ;
  wire [50:0]\m_payload_i_reg[50] ;
  wire [11:0]p_1_in;
  wire r_push;
  wire r_rlast;
  wire [15:0]s_arid;
  wire [15:0]s_arid_r;
  wire [15:0]s_awid;
  wire [7:4]s_awlen;
  wire [39:0]s_axi_araddr;
  wire [1:0]s_axi_arburst;
  wire [15:0]s_axi_arid;
  wire [7:0]s_axi_arlen;
  wire [2:0]s_axi_arprot;
  wire s_axi_arready;
  wire [1:0]s_axi_arsize;
  wire s_axi_arvalid;
  wire [39:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [15:0]s_axi_awid;
  wire [7:0]s_axi_awlen;
  wire [2:0]s_axi_awprot;
  wire s_axi_awready;
  wire [1:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire s_axi_bvalid;
  wire s_axi_rready;
  wire s_axi_rvalid;
  wire shandshake;
  wire [11:0]si_rs_araddr;
  wire [1:1]si_rs_arburst;
  wire [3:0]si_rs_arlen;
  wire si_rs_arvalid;
  wire [11:0]si_rs_awaddr;
  wire [1:1]si_rs_awburst;
  wire [3:0]si_rs_awlen;
  wire si_rs_awvalid;
  wire [15:0]si_rs_bid;
  wire si_rs_bready;
  wire [1:0]si_rs_bresp;
  wire si_rs_bvalid;
  wire [31:0]si_rs_rdata;
  wire [15:0]si_rs_rid;
  wire si_rs_rlast;
  wire [1:0]si_rs_rresp;

  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_ar_channel \RD.ar_channel_0 
       (.D(\cmd_translator_0/wrap_cmd_0/axaddr_offset ),
        .E(\ar.ar_pipe/p_1_in ),
        .\FSM_sequential_state_reg[1] (\RD.ar_channel_0_n_3 ),
        .\FSM_sequential_state_reg[1]_0 (\RD.r_channel_0_n_0 ),
        .Q(\ar_cmd_fsm_0/state ),
        .aclk(aclk),
        .areset_d1(areset_d1),
        .\axaddr_incr_reg[10] (\RD.ar_channel_0_n_16 ),
        .\axaddr_incr_reg[10]_0 (SI_REG_n_187),
        .\axaddr_incr_reg[11] ({\RD.ar_channel_0_n_17 ,\RD.ar_channel_0_n_18 ,\RD.ar_channel_0_n_19 ,\RD.ar_channel_0_n_20 ,\RD.ar_channel_0_n_21 }),
        .\axaddr_incr_reg[11]_0 ({SI_REG_n_181,SI_REG_n_182,SI_REG_n_183,SI_REG_n_184,SI_REG_n_185}),
        .\axaddr_incr_reg[2] (SI_REG_n_192),
        .\axaddr_incr_reg[2]_0 (SI_REG_n_193),
        .\axaddr_incr_reg[4] (SI_REG_n_191),
        .\axaddr_incr_reg[5] (\RD.ar_channel_0_n_22 ),
        .\axaddr_incr_reg[5]_0 (SI_REG_n_186),
        .\axaddr_incr_reg[7] (SI_REG_n_190),
        .\axaddr_incr_reg[8] (SI_REG_n_189),
        .\axaddr_incr_reg[9] (SI_REG_n_188),
        .\axaddr_offset_r_reg[0] (\cmd_translator_0/wrap_cmd_0/axaddr_offset_r ),
        .\axaddr_offset_r_reg[1] (SI_REG_n_178),
        .\axaddr_offset_r_reg[2] (SI_REG_n_177),
        .\axaddr_wrap_reg[0] (SI_REG_n_204),
        .\axaddr_wrap_reg[1] (SI_REG_n_203),
        .\axaddr_wrap_reg[2] (SI_REG_n_220),
        .\axaddr_wrap_reg[3] ({\RD.ar_channel_0_n_10 ,\RD.ar_channel_0_n_11 ,\RD.ar_channel_0_n_12 }),
        .\axaddr_wrap_reg[3]_0 (SI_REG_n_221),
        .\axlen_cnt_reg[3] (SI_REG_n_176),
        .incr_next_pending(\cmd_translator_0/incr_next_pending ),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arready(m_axi_arready),
        .m_axi_arready_0(\RD.ar_channel_0_n_4 ),
        .m_axi_arvalid(m_axi_arvalid),
        .\m_payload_i_reg[43] (\RD.ar_channel_0_n_23 ),
        .next_pending_r_reg(\RD.ar_channel_0_n_7 ),
        .next_pending_r_reg_0(SI_REG_n_194),
        .r_push(r_push),
        .r_rlast(r_rlast),
        .\s_arid_r_reg[15]_0 (s_arid_r),
        .\s_arid_r_reg[15]_1 ({s_arid,axlen,si_rs_arlen,si_rs_arburst,SI_REG_n_128,SI_REG_n_129,SI_REG_n_130,si_rs_araddr}),
        .s_axburst_eq0_reg(SI_REG_n_101),
        .s_axburst_eq1_reg(SI_REG_n_174),
        .sel_first(\cmd_translator_0/incr_cmd_0/sel_first ),
        .sel_first_i(\cmd_translator_0/sel_first_i ),
        .si_rs_arvalid(si_rs_arvalid),
        .\wrap_boundary_axaddr_r_reg[6] ({SI_REG_n_196,SI_REG_n_197,SI_REG_n_198,SI_REG_n_199,SI_REG_n_200,SI_REG_n_201,SI_REG_n_202}),
        .wrap_next_pending(\cmd_translator_0/wrap_next_pending ),
        .\wrap_second_len_r_reg[3] (SI_REG_n_180),
        .\wrap_second_len_r_reg[3]_0 (SI_REG_n_175));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_r_channel \RD.r_channel_0 
       (.D(s_arid_r),
        .aclk(aclk),
        .areset_d1(areset_d1),
        .\cnt_read_reg[0] (\RD.r_channel_0_n_0 ),
        .\cnt_read_reg[3] (\RD.r_channel_0_n_2 ),
        .\cnt_read_reg[4] (SI_REG_n_195),
        .in(in),
        .m_axi_rready(m_axi_rready),
        .m_axi_rvalid(m_axi_rvalid),
        .out({si_rs_rresp,si_rs_rdata}),
        .r_push(r_push),
        .r_push_r_reg_0({si_rs_rid,si_rs_rlast}),
        .r_rlast(r_rlast));
  zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axi_register_slice SI_REG
       (.D(\cmd_translator_0/wrap_cmd_0/axaddr_offset_0 ),
        .E(\aw.aw_pipe/p_1_in ),
        .Q(\ar_cmd_fsm_0/state ),
        .aclk(aclk),
        .aresetn(aresetn),
        .aresetn_0(SI_REG_n_7),
        .\axaddr_incr_reg[0] (\WR.aw_channel_0_n_1 ),
        .\axaddr_incr_reg[0]_0 (\RD.ar_channel_0_n_4 ),
        .\axaddr_incr_reg[10] ({\WR.aw_channel_0_n_15 ,\WR.aw_channel_0_n_16 ,\WR.aw_channel_0_n_17 ,\WR.aw_channel_0_n_18 ,\WR.aw_channel_0_n_19 ,\WR.aw_channel_0_n_20 ,\WR.aw_channel_0_n_21 }),
        .\axaddr_incr_reg[10]_0 (\WR.aw_channel_0_n_22 ),
        .\axaddr_incr_reg[11] (\WR.aw_channel_0_n_14 ),
        .\axaddr_incr_reg[11]_0 (\WR.aw_channel_0_n_10 ),
        .\axaddr_incr_reg[11]_1 ({\RD.ar_channel_0_n_17 ,\RD.ar_channel_0_n_18 ,\RD.ar_channel_0_n_19 ,\RD.ar_channel_0_n_20 ,\RD.ar_channel_0_n_21 }),
        .\axaddr_incr_reg[11]_2 (\RD.ar_channel_0_n_16 ),
        .\axaddr_incr_reg[3] (\aw_cmd_fsm_0/state ),
        .\axaddr_incr_reg[3]_0 (\WR.aw_channel_0_n_26 ),
        .\axaddr_incr_reg[3]_1 (\RD.ar_channel_0_n_23 ),
        .\axaddr_incr_reg[6] (\WR.aw_channel_0_n_25 ),
        .\axaddr_incr_reg[6]_0 (\RD.ar_channel_0_n_22 ),
        .\axaddr_incr_reg[7] (\WR.aw_channel_0_n_24 ),
        .\axaddr_incr_reg[8] (\WR.aw_channel_0_n_23 ),
        .\axaddr_offset_r_reg[0] (\cmd_translator_0/wrap_cmd_0/axaddr_offset_r_1 ),
        .\axaddr_offset_r_reg[0]_0 (\cmd_translator_0/wrap_cmd_0/axaddr_offset_r ),
        .\axaddr_offset_r_reg[1] (\WR.aw_channel_0_n_2 ),
        .\axaddr_wrap_reg[0] (SI_REG_n_203),
        .\axaddr_wrap_reg[0]_0 (SI_REG_n_215),
        .\axaddr_wrap_reg[2] (SI_REG_n_212),
        .\axaddr_wrap_reg[2]_0 (SI_REG_n_220),
        .\axaddr_wrap_reg[3] (SI_REG_n_217),
        .\axaddr_wrap_reg[3]_0 (SI_REG_n_221),
        .\axaddr_wrap_reg[3]_1 ({\RD.ar_channel_0_n_10 ,\RD.ar_channel_0_n_11 ,\RD.ar_channel_0_n_12 }),
        .\axaddr_wrap_reg[3]_2 ({axaddr_wrap[3:2],axaddr_wrap[0]}),
        .b_push(b_push),
        .incr_next_pending(\cmd_translator_0/incr_next_pending ),
        .m_axi_arready(m_axi_arready),
        .\m_payload_i_reg[0] (SI_REG_n_214),
        .\m_payload_i_reg[0]_0 (\ar.ar_pipe/p_1_in ),
        .\m_payload_i_reg[11] ({p_1_in[11:10],p_1_in[8:6],p_1_in[3],p_1_in[1:0]}),
        .\m_payload_i_reg[11]_0 ({SI_REG_n_181,SI_REG_n_182,SI_REG_n_183,SI_REG_n_184,SI_REG_n_185}),
        .\m_payload_i_reg[17] (\m_payload_i_reg[17] ),
        .\m_payload_i_reg[1] (SI_REG_n_96),
        .\m_payload_i_reg[1]_0 (SI_REG_n_193),
        .\m_payload_i_reg[2] (SI_REG_n_97),
        .\m_payload_i_reg[2]_0 (SI_REG_n_192),
        .\m_payload_i_reg[2]_1 (SI_REG_n_216),
        .\m_payload_i_reg[3] (SI_REG_n_93),
        .\m_payload_i_reg[3]_0 (SI_REG_n_94),
        .\m_payload_i_reg[3]_1 (SI_REG_n_186),
        .\m_payload_i_reg[43] (SI_REG_n_80),
        .\m_payload_i_reg[43]_0 (SI_REG_n_81),
        .\m_payload_i_reg[43]_1 (SI_REG_n_92),
        .\m_payload_i_reg[43]_2 (SI_REG_n_177),
        .\m_payload_i_reg[43]_3 (SI_REG_n_178),
        .\m_payload_i_reg[43]_4 (SI_REG_n_204),
        .\m_payload_i_reg[43]_5 (SI_REG_n_218),
        .\m_payload_i_reg[44] (SI_REG_n_175),
        .\m_payload_i_reg[44]_0 (SI_REG_n_191),
        .\m_payload_i_reg[44]_1 (SI_REG_n_213),
        .\m_payload_i_reg[44]_2 (SI_REG_n_219),
        .\m_payload_i_reg[47] (SI_REG_n_101),
        .\m_payload_i_reg[47]_0 (SI_REG_n_174),
        .\m_payload_i_reg[50] (\m_payload_i_reg[50] ),
        .\m_payload_i_reg[52] (SI_REG_n_83),
        .\m_payload_i_reg[52]_0 (\cmd_translator_0/wrap_cmd_0/axaddr_offset ),
        .\m_payload_i_reg[52]_1 (SI_REG_n_180),
        .\m_payload_i_reg[53] (SI_REG_n_99),
        .\m_payload_i_reg[54] (SI_REG_n_98),
        .\m_payload_i_reg[55] (SI_REG_n_176),
        .\m_payload_i_reg[56] (SI_REG_n_194),
        .\m_payload_i_reg[5] (SI_REG_n_190),
        .\m_payload_i_reg[6] (SI_REG_n_8),
        .\m_payload_i_reg[6]_0 (SI_REG_n_189),
        .\m_payload_i_reg[6]_1 ({SI_REG_n_196,SI_REG_n_197,SI_REG_n_198,SI_REG_n_199,SI_REG_n_200,SI_REG_n_201,SI_REG_n_202}),
        .\m_payload_i_reg[6]_2 ({SI_REG_n_205,SI_REG_n_206,SI_REG_n_207,SI_REG_n_208,SI_REG_n_209,SI_REG_n_210,SI_REG_n_211}),
        .\m_payload_i_reg[76] ({s_awid,s_awlen,si_rs_awlen,si_rs_awburst,SI_REG_n_34,axsize,Q,si_rs_awaddr}),
        .\m_payload_i_reg[76]_0 ({s_arid,axlen,si_rs_arlen,si_rs_arburst,SI_REG_n_128,SI_REG_n_129,SI_REG_n_130,\m_payload_i_reg[42] ,si_rs_araddr}),
        .\m_payload_i_reg[7] (SI_REG_n_188),
        .\m_payload_i_reg[8] (SI_REG_n_95),
        .\m_payload_i_reg[9] (SI_REG_n_187),
        .m_valid_i_reg(s_axi_bvalid),
        .m_valid_i_reg_0(s_axi_rvalid),
        .m_valid_i_reg_1(\RD.r_channel_0_n_2 ),
        .next_pending_r_reg(\RD.ar_channel_0_n_7 ),
        .next_pending_r_reg_0(\RD.ar_channel_0_n_3 ),
        .out(si_rs_bid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_rready(s_axi_rready),
        .s_ready_i_reg(s_axi_awready),
        .s_ready_i_reg_0(s_axi_arready),
        .s_ready_i_reg_1(SI_REG_n_195),
        .sel_first(\cmd_translator_0/incr_cmd_0/sel_first_2 ),
        .sel_first_0(\cmd_translator_0/incr_cmd_0/sel_first ),
        .sel_first_i(\cmd_translator_0/sel_first_i ),
        .shandshake(shandshake),
        .si_rs_arvalid(si_rs_arvalid),
        .si_rs_awvalid(si_rs_awvalid),
        .si_rs_bready(si_rs_bready),
        .si_rs_bvalid(si_rs_bvalid),
        .\skid_buffer_reg[1] (si_rs_bresp),
        .\skid_buffer_reg[33] ({si_rs_rresp,si_rs_rdata}),
        .\skid_buffer_reg[50] ({si_rs_rid,si_rs_rlast}),
        .wrap_next_pending(\cmd_translator_0/wrap_next_pending ));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_aw_channel \WR.aw_channel_0 
       (.D(\cmd_translator_0/wrap_cmd_0/axaddr_offset_0 ),
        .E(\aw.aw_pipe/p_1_in ),
        .Q(\aw_cmd_fsm_0/state ),
        .aclk(aclk),
        .areset_d1(areset_d1),
        .\axaddr_incr[11]_i_3 (SI_REG_n_216),
        .\axaddr_incr[11]_i_3_0 (SI_REG_n_214),
        .\axaddr_incr[11]_i_5 (SI_REG_n_219),
        .\axaddr_incr[11]_i_5_0 (\WR.b_channel_0_n_4 ),
        .\axaddr_incr[11]_i_5_1 (SI_REG_n_213),
        .\axaddr_incr[11]_i_5_2 (SI_REG_n_92),
        .\axaddr_incr_reg[0] (\WR.aw_channel_0_n_26 ),
        .\axaddr_incr_reg[10] (\WR.aw_channel_0_n_14 ),
        .\axaddr_incr_reg[10]_0 ({\WR.aw_channel_0_n_15 ,\WR.aw_channel_0_n_16 ,\WR.aw_channel_0_n_17 ,\WR.aw_channel_0_n_18 ,\WR.aw_channel_0_n_19 ,\WR.aw_channel_0_n_20 ,\WR.aw_channel_0_n_21 }),
        .\axaddr_incr_reg[11] ({p_1_in[11:10],p_1_in[8:6],p_1_in[3],p_1_in[1:0]}),
        .\axaddr_incr_reg[2] (SI_REG_n_96),
        .\axaddr_incr_reg[2]_0 (SI_REG_n_97),
        .\axaddr_incr_reg[4] (SI_REG_n_93),
        .\axaddr_incr_reg[5] (\WR.aw_channel_0_n_25 ),
        .\axaddr_incr_reg[5]_0 (SI_REG_n_94),
        .\axaddr_incr_reg[6] (\WR.aw_channel_0_n_24 ),
        .\axaddr_incr_reg[7] (\WR.aw_channel_0_n_23 ),
        .\axaddr_incr_reg[9] (\WR.aw_channel_0_n_22 ),
        .\axaddr_incr_reg[9]_0 (SI_REG_n_95),
        .\axaddr_offset_r_reg[0] (\cmd_translator_0/wrap_cmd_0/axaddr_offset_r_1 ),
        .\axaddr_offset_r_reg[1] (SI_REG_n_81),
        .\axaddr_offset_r_reg[2] (SI_REG_n_80),
        .\axaddr_wrap_reg[0] (SI_REG_n_218),
        .\axaddr_wrap_reg[1] (SI_REG_n_215),
        .\axaddr_wrap_reg[2] (SI_REG_n_212),
        .\axaddr_wrap_reg[3] ({axaddr_wrap[3:2],axaddr_wrap[0]}),
        .\axaddr_wrap_reg[3]_0 (SI_REG_n_217),
        .b_push(b_push),
        .\cnt_read_reg[0] (\WR.aw_channel_0_n_1 ),
        .in({b_awid,b_awlen}),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awready(m_axi_awready),
        .m_axi_awvalid(m_axi_awvalid),
        .\m_payload_i_reg[3] (\WR.aw_channel_0_n_10 ),
        .next_pending_r_reg(SI_REG_n_98),
        .next_pending_r_reg_0(SI_REG_n_99),
        .\s_awid_r_reg[15]_0 ({s_awid,s_awlen,si_rs_awlen,si_rs_awburst,SI_REG_n_34,axsize,si_rs_awaddr}),
        .s_axburst_eq1_reg(\WR.aw_channel_0_n_12 ),
        .sel_first(\cmd_translator_0/incr_cmd_0/sel_first_2 ),
        .si_rs_awvalid(si_rs_awvalid),
        .\state_reg[1] (\WR.aw_channel_0_n_2 ),
        .\state_reg[1]_0 (\bid_fifo_0/cnt_read ),
        .\state_reg[1]_1 (\WR.b_channel_0_n_3 ),
        .\wrap_boundary_axaddr_r_reg[6] ({SI_REG_n_205,SI_REG_n_206,SI_REG_n_207,SI_REG_n_208,SI_REG_n_209,SI_REG_n_210,SI_REG_n_211}),
        .\wrap_second_len_r_reg[3] (SI_REG_n_83),
        .\wrap_second_len_r_reg[3]_0 (SI_REG_n_8));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_b_channel \WR.b_channel_0 
       (.Q(\bid_fifo_0/cnt_read ),
        .aclk(aclk),
        .areset_d1(areset_d1),
        .b_push(b_push),
        .\cnt_read_reg[0] (\WR.b_channel_0_n_4 ),
        .\cnt_read_reg[1] (\WR.b_channel_0_n_3 ),
        .in({b_awid,b_awlen}),
        .m_axi_awready(m_axi_awready),
        .m_axi_bready(m_axi_bready),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .out(si_rs_bid),
        .\s_bresp_acc_reg[1]_0 (si_rs_bresp),
        .shandshake(shandshake),
        .si_rs_bready(si_rs_bready),
        .si_rs_bvalid(si_rs_bvalid),
        .\state_reg[1] (\WR.aw_channel_0_n_12 ),
        .\state_reg[1]_0 (\aw_cmd_fsm_0/state [1]));
  FDRE #(
    .INIT(1'b0)) 
    areset_d1_reg
       (.C(aclk),
        .CE(1'b1),
        .D(SI_REG_n_7),
        .Q(areset_d1),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_ar_channel" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_ar_channel
   (incr_next_pending,
    sel_first_i,
    sel_first,
    \FSM_sequential_state_reg[1] ,
    m_axi_arready_0,
    Q,
    next_pending_r_reg,
    \axaddr_offset_r_reg[0] ,
    r_push,
    \axaddr_wrap_reg[3] ,
    m_axi_arvalid,
    E,
    r_rlast,
    \axaddr_incr_reg[10] ,
    \axaddr_incr_reg[11] ,
    \axaddr_incr_reg[5] ,
    \m_payload_i_reg[43] ,
    m_axi_araddr,
    \s_arid_r_reg[15]_0 ,
    aclk,
    wrap_next_pending,
    s_axburst_eq0_reg,
    s_axburst_eq1_reg,
    next_pending_r_reg_0,
    si_rs_arvalid,
    m_axi_arready,
    areset_d1,
    \s_arid_r_reg[15]_1 ,
    \wrap_second_len_r_reg[3] ,
    D,
    \wrap_second_len_r_reg[3]_0 ,
    \axlen_cnt_reg[3] ,
    \axaddr_offset_r_reg[2] ,
    \axaddr_offset_r_reg[1] ,
    \axaddr_wrap_reg[3]_0 ,
    \axaddr_wrap_reg[2] ,
    \axaddr_wrap_reg[1] ,
    \axaddr_wrap_reg[0] ,
    \axaddr_incr_reg[4] ,
    \axaddr_incr_reg[5]_0 ,
    \axaddr_incr_reg[7] ,
    \axaddr_incr_reg[8] ,
    \axaddr_incr_reg[9] ,
    \axaddr_incr_reg[10]_0 ,
    \axaddr_incr_reg[2] ,
    \axaddr_incr_reg[2]_0 ,
    \FSM_sequential_state_reg[1]_0 ,
    \wrap_boundary_axaddr_r_reg[6] ,
    \axaddr_incr_reg[11]_0 );
  output incr_next_pending;
  output sel_first_i;
  output sel_first;
  output \FSM_sequential_state_reg[1] ;
  output m_axi_arready_0;
  output [1:0]Q;
  output next_pending_r_reg;
  output [0:0]\axaddr_offset_r_reg[0] ;
  output r_push;
  output [2:0]\axaddr_wrap_reg[3] ;
  output m_axi_arvalid;
  output [0:0]E;
  output r_rlast;
  output \axaddr_incr_reg[10] ;
  output [4:0]\axaddr_incr_reg[11] ;
  output \axaddr_incr_reg[5] ;
  output \m_payload_i_reg[43] ;
  output [11:0]m_axi_araddr;
  output [15:0]\s_arid_r_reg[15]_0 ;
  input aclk;
  input wrap_next_pending;
  input s_axburst_eq0_reg;
  input s_axburst_eq1_reg;
  input next_pending_r_reg_0;
  input si_rs_arvalid;
  input m_axi_arready;
  input areset_d1;
  input [39:0]\s_arid_r_reg[15]_1 ;
  input \wrap_second_len_r_reg[3] ;
  input [0:0]D;
  input \wrap_second_len_r_reg[3]_0 ;
  input \axlen_cnt_reg[3] ;
  input \axaddr_offset_r_reg[2] ;
  input \axaddr_offset_r_reg[1] ;
  input \axaddr_wrap_reg[3]_0 ;
  input \axaddr_wrap_reg[2] ;
  input \axaddr_wrap_reg[1] ;
  input \axaddr_wrap_reg[0] ;
  input \axaddr_incr_reg[4] ;
  input \axaddr_incr_reg[5]_0 ;
  input \axaddr_incr_reg[7] ;
  input \axaddr_incr_reg[8] ;
  input \axaddr_incr_reg[9] ;
  input \axaddr_incr_reg[10]_0 ;
  input \axaddr_incr_reg[2] ;
  input \axaddr_incr_reg[2]_0 ;
  input \FSM_sequential_state_reg[1]_0 ;
  input [6:0]\wrap_boundary_axaddr_r_reg[6] ;
  input [4:0]\axaddr_incr_reg[11]_0 ;

  wire [0:0]D;
  wire [0:0]E;
  wire \FSM_sequential_state_reg[1] ;
  wire \FSM_sequential_state_reg[1]_0 ;
  wire [1:0]Q;
  wire aclk;
  wire ar_cmd_fsm_0_n_0;
  wire ar_cmd_fsm_0_n_18;
  wire ar_cmd_fsm_0_n_19;
  wire ar_cmd_fsm_0_n_20;
  wire ar_cmd_fsm_0_n_21;
  wire ar_cmd_fsm_0_n_22;
  wire ar_cmd_fsm_0_n_23;
  wire ar_cmd_fsm_0_n_3;
  wire ar_cmd_fsm_0_n_4;
  wire ar_cmd_fsm_0_n_6;
  wire ar_cmd_fsm_0_n_7;
  wire ar_cmd_fsm_0_n_8;
  wire ar_cmd_fsm_0_n_9;
  wire areset_d1;
  wire \axaddr_incr_reg[10] ;
  wire \axaddr_incr_reg[10]_0 ;
  wire [4:0]\axaddr_incr_reg[11] ;
  wire [4:0]\axaddr_incr_reg[11]_0 ;
  wire \axaddr_incr_reg[2] ;
  wire \axaddr_incr_reg[2]_0 ;
  wire \axaddr_incr_reg[4] ;
  wire \axaddr_incr_reg[5] ;
  wire \axaddr_incr_reg[5]_0 ;
  wire \axaddr_incr_reg[7] ;
  wire \axaddr_incr_reg[8] ;
  wire \axaddr_incr_reg[9] ;
  wire [0:0]\axaddr_offset_r_reg[0] ;
  wire \axaddr_offset_r_reg[1] ;
  wire \axaddr_offset_r_reg[2] ;
  wire \axaddr_wrap_reg[0] ;
  wire \axaddr_wrap_reg[1] ;
  wire \axaddr_wrap_reg[2] ;
  wire [2:0]\axaddr_wrap_reg[3] ;
  wire \axaddr_wrap_reg[3]_0 ;
  wire \axlen_cnt_reg[3] ;
  wire cmd_translator_0_n_1;
  wire cmd_translator_0_n_10;
  wire cmd_translator_0_n_14;
  wire cmd_translator_0_n_15;
  wire cmd_translator_0_n_16;
  wire cmd_translator_0_n_26;
  wire cmd_translator_0_n_3;
  wire cmd_translator_0_n_4;
  wire cmd_translator_0_n_6;
  wire cmd_translator_0_n_7;
  wire cmd_translator_0_n_8;
  wire cmd_translator_0_n_9;
  wire incr_next_pending;
  wire [11:0]m_axi_araddr;
  wire m_axi_arready;
  wire m_axi_arready_0;
  wire m_axi_arvalid;
  wire \m_payload_i_reg[43] ;
  wire next_pending_r_reg;
  wire next_pending_r_reg_0;
  wire r_push;
  wire r_rlast;
  wire [15:0]\s_arid_r_reg[15]_0 ;
  wire [39:0]\s_arid_r_reg[15]_1 ;
  wire s_axburst_eq0_reg;
  wire s_axburst_eq1_reg;
  wire sel_first;
  wire sel_first_i;
  wire si_rs_arvalid;
  wire [6:0]\wrap_boundary_axaddr_r_reg[6] ;
  wire [3:1]\wrap_cmd_0/axaddr_offset ;
  wire [3:1]\wrap_cmd_0/axaddr_offset_r ;
  wire [3:0]\wrap_cmd_0/wrap_second_len ;
  wire [3:0]\wrap_cmd_0/wrap_second_len_r ;
  wire wrap_next_pending;
  wire \wrap_second_len_r_reg[3] ;
  wire \wrap_second_len_r_reg[3]_0 ;

  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_rd_cmd_fsm ar_cmd_fsm_0
       (.D({ar_cmd_fsm_0_n_6,ar_cmd_fsm_0_n_7,ar_cmd_fsm_0_n_8,ar_cmd_fsm_0_n_9}),
        .E(ar_cmd_fsm_0_n_0),
        .\FSM_sequential_state_reg[0]_0 (cmd_translator_0_n_15),
        .\FSM_sequential_state_reg[1]_0 (\FSM_sequential_state_reg[1] ),
        .\FSM_sequential_state_reg[1]_1 (\FSM_sequential_state_reg[1]_0 ),
        .\FSM_sequential_state_reg[1]_2 (cmd_translator_0_n_16),
        .Q(Q),
        .aclk(aclk),
        .areset_d1(areset_d1),
        .\axaddr_incr_reg[0] (sel_first),
        .axaddr_offset(\wrap_cmd_0/axaddr_offset ),
        .\axaddr_offset_r_reg[1] (\axaddr_offset_r_reg[1] ),
        .\axaddr_offset_r_reg[2] (\axaddr_offset_r_reg[2] ),
        .\axaddr_offset_r_reg[3] (\wrap_cmd_0/axaddr_offset_r ),
        .\axlen_cnt_reg[4] (cmd_translator_0_n_26),
        .\axlen_cnt_reg[4]_0 (cmd_translator_0_n_4),
        .\axlen_cnt_reg[5] (cmd_translator_0_n_10),
        .\axlen_cnt_reg[7] ({\s_arid_r_reg[15]_1 [23],\s_arid_r_reg[15]_1 [21:20],\s_arid_r_reg[15]_1 [16]}),
        .\axlen_cnt_reg[7]_0 ({cmd_translator_0_n_6,cmd_translator_0_n_7,cmd_translator_0_n_8,cmd_translator_0_n_9}),
        .\axlen_cnt_reg[7]_1 (cmd_translator_0_n_14),
        .m_axi_arready(m_axi_arready),
        .m_axi_arready_0(m_axi_arready_0),
        .m_axi_arvalid(m_axi_arvalid),
        .\m_payload_i_reg[59] ({ar_cmd_fsm_0_n_18,ar_cmd_fsm_0_n_19,ar_cmd_fsm_0_n_20,ar_cmd_fsm_0_n_21}),
        .m_valid_i_reg(ar_cmd_fsm_0_n_22),
        .m_valid_i_reg_0(E),
        .r_push(r_push),
        .sel_first_i(sel_first_i),
        .sel_first_reg(ar_cmd_fsm_0_n_3),
        .sel_first_reg_0(ar_cmd_fsm_0_n_4),
        .sel_first_reg_1(ar_cmd_fsm_0_n_23),
        .sel_first_reg_2(cmd_translator_0_n_3),
        .sel_first_reg_3(cmd_translator_0_n_1),
        .si_rs_arvalid(si_rs_arvalid),
        .wrap_second_len(\wrap_cmd_0/wrap_second_len ),
        .\wrap_second_len_r_reg[3] (\wrap_cmd_0/wrap_second_len_r ),
        .\wrap_second_len_r_reg[3]_0 (\wrap_second_len_r_reg[3] ),
        .\wrap_second_len_r_reg[3]_1 (\wrap_second_len_r_reg[3]_0 ));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_cmd_translator_1 cmd_translator_0
       (.D({ar_cmd_fsm_0_n_18,ar_cmd_fsm_0_n_19,ar_cmd_fsm_0_n_20,ar_cmd_fsm_0_n_21}),
        .E(\FSM_sequential_state_reg[1] ),
        .\FSM_sequential_state_reg[0] (Q[0]),
        .Q({cmd_translator_0_n_6,cmd_translator_0_n_7,cmd_translator_0_n_8,cmd_translator_0_n_9}),
        .aclk(aclk),
        .\axaddr_incr_reg[0] (ar_cmd_fsm_0_n_23),
        .\axaddr_incr_reg[10] (\axaddr_incr_reg[10] ),
        .\axaddr_incr_reg[10]_0 (\axaddr_incr_reg[10]_0 ),
        .\axaddr_incr_reg[11] (\axaddr_incr_reg[11] ),
        .\axaddr_incr_reg[11]_0 (\axaddr_incr_reg[11]_0 ),
        .\axaddr_incr_reg[2] (\axaddr_incr_reg[2] ),
        .\axaddr_incr_reg[2]_0 (\axaddr_incr_reg[2]_0 ),
        .\axaddr_incr_reg[4] (\axaddr_incr_reg[4] ),
        .\axaddr_incr_reg[5] (\axaddr_incr_reg[5] ),
        .\axaddr_incr_reg[5]_0 (\axaddr_incr_reg[5]_0 ),
        .\axaddr_incr_reg[7] (\axaddr_incr_reg[7] ),
        .\axaddr_incr_reg[8] (\axaddr_incr_reg[8] ),
        .\axaddr_incr_reg[9] (\axaddr_incr_reg[9] ),
        .\axaddr_offset_r_reg[3] ({\wrap_cmd_0/axaddr_offset_r ,\axaddr_offset_r_reg[0] }),
        .\axaddr_offset_r_reg[3]_0 ({\wrap_cmd_0/axaddr_offset ,D}),
        .\axaddr_wrap_reg[0] (\axaddr_wrap_reg[0] ),
        .\axaddr_wrap_reg[0]_0 (ar_cmd_fsm_0_n_0),
        .\axaddr_wrap_reg[11] (m_axi_arready_0),
        .\axaddr_wrap_reg[1] (\axaddr_wrap_reg[1] ),
        .\axaddr_wrap_reg[2] (\axaddr_wrap_reg[2] ),
        .\axaddr_wrap_reg[3] (\axaddr_wrap_reg[3] ),
        .\axaddr_wrap_reg[3]_0 (\axaddr_wrap_reg[3]_0 ),
        .\axlen_cnt_reg[1] (cmd_translator_0_n_10),
        .\axlen_cnt_reg[3] (cmd_translator_0_n_26),
        .\axlen_cnt_reg[3]_0 (\axlen_cnt_reg[3] ),
        .\axlen_cnt_reg[6] (cmd_translator_0_n_14),
        .\axlen_cnt_reg[6]_0 ({\s_arid_r_reg[15]_1 [22],\s_arid_r_reg[15]_1 [19:0]}),
        .\axlen_cnt_reg[6]_1 (ar_cmd_fsm_0_n_22),
        .\axlen_cnt_reg[7] (cmd_translator_0_n_4),
        .incr_next_pending(incr_next_pending),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arready(m_axi_arready),
        .m_axi_arready_0(cmd_translator_0_n_16),
        .\m_payload_i_reg[43] (\m_payload_i_reg[43] ),
        .next_pending_r_reg(next_pending_r_reg),
        .next_pending_r_reg_0(next_pending_r_reg_0),
        .r_rlast(r_rlast),
        .s_axburst_eq0_reg_0(s_axburst_eq0_reg),
        .s_axburst_eq1_reg_0(cmd_translator_0_n_15),
        .s_axburst_eq1_reg_1(s_axburst_eq1_reg),
        .sel_first_i(sel_first_i),
        .sel_first_reg_0(cmd_translator_0_n_1),
        .sel_first_reg_1(sel_first),
        .sel_first_reg_2(cmd_translator_0_n_3),
        .sel_first_reg_3(ar_cmd_fsm_0_n_4),
        .sel_first_reg_4(ar_cmd_fsm_0_n_3),
        .\wrap_boundary_axaddr_r_reg[6] (\wrap_boundary_axaddr_r_reg[6] ),
        .\wrap_cnt_r_reg[3] ({ar_cmd_fsm_0_n_6,ar_cmd_fsm_0_n_7,ar_cmd_fsm_0_n_8,ar_cmd_fsm_0_n_9}),
        .wrap_next_pending(wrap_next_pending),
        .\wrap_second_len_r_reg[3] (\wrap_cmd_0/wrap_second_len_r ),
        .\wrap_second_len_r_reg[3]_0 (\wrap_cmd_0/wrap_second_len ));
  FDRE \s_arid_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [24]),
        .Q(\s_arid_r_reg[15]_0 [0]),
        .R(1'b0));
  FDRE \s_arid_r_reg[10] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [34]),
        .Q(\s_arid_r_reg[15]_0 [10]),
        .R(1'b0));
  FDRE \s_arid_r_reg[11] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [35]),
        .Q(\s_arid_r_reg[15]_0 [11]),
        .R(1'b0));
  FDRE \s_arid_r_reg[12] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [36]),
        .Q(\s_arid_r_reg[15]_0 [12]),
        .R(1'b0));
  FDRE \s_arid_r_reg[13] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [37]),
        .Q(\s_arid_r_reg[15]_0 [13]),
        .R(1'b0));
  FDRE \s_arid_r_reg[14] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [38]),
        .Q(\s_arid_r_reg[15]_0 [14]),
        .R(1'b0));
  FDRE \s_arid_r_reg[15] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [39]),
        .Q(\s_arid_r_reg[15]_0 [15]),
        .R(1'b0));
  FDRE \s_arid_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [25]),
        .Q(\s_arid_r_reg[15]_0 [1]),
        .R(1'b0));
  FDRE \s_arid_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [26]),
        .Q(\s_arid_r_reg[15]_0 [2]),
        .R(1'b0));
  FDRE \s_arid_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [27]),
        .Q(\s_arid_r_reg[15]_0 [3]),
        .R(1'b0));
  FDRE \s_arid_r_reg[4] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [28]),
        .Q(\s_arid_r_reg[15]_0 [4]),
        .R(1'b0));
  FDRE \s_arid_r_reg[5] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [29]),
        .Q(\s_arid_r_reg[15]_0 [5]),
        .R(1'b0));
  FDRE \s_arid_r_reg[6] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [30]),
        .Q(\s_arid_r_reg[15]_0 [6]),
        .R(1'b0));
  FDRE \s_arid_r_reg[7] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [31]),
        .Q(\s_arid_r_reg[15]_0 [7]),
        .R(1'b0));
  FDRE \s_arid_r_reg[8] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [32]),
        .Q(\s_arid_r_reg[15]_0 [8]),
        .R(1'b0));
  FDRE \s_arid_r_reg[9] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_arid_r_reg[15]_1 [33]),
        .Q(\s_arid_r_reg[15]_0 [9]),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_aw_channel" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_aw_channel
   (sel_first,
    \cnt_read_reg[0] ,
    \state_reg[1] ,
    b_push,
    Q,
    \axaddr_offset_r_reg[0] ,
    \axaddr_wrap_reg[3] ,
    \m_payload_i_reg[3] ,
    E,
    s_axburst_eq1_reg,
    m_axi_awvalid,
    \axaddr_incr_reg[10] ,
    \axaddr_incr_reg[10]_0 ,
    \axaddr_incr_reg[9] ,
    \axaddr_incr_reg[7] ,
    \axaddr_incr_reg[6] ,
    \axaddr_incr_reg[5] ,
    \axaddr_incr_reg[0] ,
    m_axi_awaddr,
    in,
    aclk,
    \s_awid_r_reg[15]_0 ,
    next_pending_r_reg,
    next_pending_r_reg_0,
    si_rs_awvalid,
    areset_d1,
    \wrap_second_len_r_reg[3] ,
    D,
    \wrap_second_len_r_reg[3]_0 ,
    \axaddr_offset_r_reg[2] ,
    \axaddr_offset_r_reg[1] ,
    \axaddr_wrap_reg[3]_0 ,
    \axaddr_wrap_reg[2] ,
    \axaddr_wrap_reg[1] ,
    \axaddr_wrap_reg[0] ,
    \axaddr_incr_reg[11] ,
    \axaddr_incr_reg[2] ,
    \axaddr_incr_reg[2]_0 ,
    \axaddr_incr_reg[4] ,
    \axaddr_incr_reg[5]_0 ,
    \axaddr_incr_reg[9]_0 ,
    \axaddr_incr[11]_i_3 ,
    \axaddr_incr[11]_i_3_0 ,
    \axaddr_incr[11]_i_5 ,
    m_axi_awready,
    \axaddr_incr[11]_i_5_0 ,
    \axaddr_incr[11]_i_5_1 ,
    \axaddr_incr[11]_i_5_2 ,
    \state_reg[1]_0 ,
    \wrap_boundary_axaddr_r_reg[6] ,
    \state_reg[1]_1 );
  output sel_first;
  output \cnt_read_reg[0] ;
  output \state_reg[1] ;
  output b_push;
  output [1:0]Q;
  output [0:0]\axaddr_offset_r_reg[0] ;
  output [2:0]\axaddr_wrap_reg[3] ;
  output \m_payload_i_reg[3] ;
  output [0:0]E;
  output s_axburst_eq1_reg;
  output m_axi_awvalid;
  output \axaddr_incr_reg[10] ;
  output [6:0]\axaddr_incr_reg[10]_0 ;
  output \axaddr_incr_reg[9] ;
  output \axaddr_incr_reg[7] ;
  output \axaddr_incr_reg[6] ;
  output \axaddr_incr_reg[5] ;
  output \axaddr_incr_reg[0] ;
  output [11:0]m_axi_awaddr;
  output [23:0]in;
  input aclk;
  input [39:0]\s_awid_r_reg[15]_0 ;
  input next_pending_r_reg;
  input next_pending_r_reg_0;
  input si_rs_awvalid;
  input areset_d1;
  input \wrap_second_len_r_reg[3] ;
  input [0:0]D;
  input \wrap_second_len_r_reg[3]_0 ;
  input \axaddr_offset_r_reg[2] ;
  input \axaddr_offset_r_reg[1] ;
  input \axaddr_wrap_reg[3]_0 ;
  input \axaddr_wrap_reg[2] ;
  input \axaddr_wrap_reg[1] ;
  input \axaddr_wrap_reg[0] ;
  input [7:0]\axaddr_incr_reg[11] ;
  input \axaddr_incr_reg[2] ;
  input \axaddr_incr_reg[2]_0 ;
  input \axaddr_incr_reg[4] ;
  input \axaddr_incr_reg[5]_0 ;
  input \axaddr_incr_reg[9]_0 ;
  input \axaddr_incr[11]_i_3 ;
  input \axaddr_incr[11]_i_3_0 ;
  input \axaddr_incr[11]_i_5 ;
  input m_axi_awready;
  input \axaddr_incr[11]_i_5_0 ;
  input \axaddr_incr[11]_i_5_1 ;
  input \axaddr_incr[11]_i_5_2 ;
  input [1:0]\state_reg[1]_0 ;
  input [6:0]\wrap_boundary_axaddr_r_reg[6] ;
  input [0:0]\state_reg[1]_1 ;

  wire [0:0]D;
  wire [0:0]E;
  wire [1:0]Q;
  wire aclk;
  wire areset_d1;
  wire aw_cmd_fsm_0_n_0;
  wire aw_cmd_fsm_0_n_19;
  wire aw_cmd_fsm_0_n_4;
  wire aw_cmd_fsm_0_n_5;
  wire \axaddr_incr[11]_i_3 ;
  wire \axaddr_incr[11]_i_3_0 ;
  wire \axaddr_incr[11]_i_5 ;
  wire \axaddr_incr[11]_i_5_0 ;
  wire \axaddr_incr[11]_i_5_1 ;
  wire \axaddr_incr[11]_i_5_2 ;
  wire \axaddr_incr_reg[0] ;
  wire \axaddr_incr_reg[10] ;
  wire [6:0]\axaddr_incr_reg[10]_0 ;
  wire [7:0]\axaddr_incr_reg[11] ;
  wire \axaddr_incr_reg[2] ;
  wire \axaddr_incr_reg[2]_0 ;
  wire \axaddr_incr_reg[4] ;
  wire \axaddr_incr_reg[5] ;
  wire \axaddr_incr_reg[5]_0 ;
  wire \axaddr_incr_reg[6] ;
  wire \axaddr_incr_reg[7] ;
  wire \axaddr_incr_reg[9] ;
  wire \axaddr_incr_reg[9]_0 ;
  wire [0:0]\axaddr_offset_r_reg[0] ;
  wire \axaddr_offset_r_reg[1] ;
  wire \axaddr_offset_r_reg[2] ;
  wire \axaddr_wrap_reg[0] ;
  wire \axaddr_wrap_reg[1] ;
  wire \axaddr_wrap_reg[2] ;
  wire [2:0]\axaddr_wrap_reg[3] ;
  wire \axaddr_wrap_reg[3]_0 ;
  wire b_push;
  wire cmd_translator_0_n_0;
  wire cmd_translator_0_n_7;
  wire \cnt_read_reg[0] ;
  wire [23:0]in;
  wire [11:0]m_axi_awaddr;
  wire m_axi_awready;
  wire m_axi_awvalid;
  wire \m_payload_i_reg[3] ;
  wire next_pending_r_reg;
  wire next_pending_r_reg_0;
  wire [39:0]\s_awid_r_reg[15]_0 ;
  wire s_axburst_eq1_reg;
  wire sel_first;
  wire sel_first__0;
  wire sel_first_i;
  wire si_rs_awvalid;
  wire \state_reg[1] ;
  wire [1:0]\state_reg[1]_0 ;
  wire [0:0]\state_reg[1]_1 ;
  wire [6:0]\wrap_boundary_axaddr_r_reg[6] ;
  wire [3:1]\wrap_cmd_0/axaddr_offset ;
  wire [3:1]\wrap_cmd_0/axaddr_offset_r ;
  wire [3:0]\wrap_cmd_0/wrap_second_len ;
  wire [3:0]\wrap_cmd_0/wrap_second_len_r ;
  wire [3:0]wrap_cnt;
  wire \wrap_second_len_r_reg[3] ;
  wire \wrap_second_len_r_reg[3]_0 ;

  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_wr_cmd_fsm aw_cmd_fsm_0
       (.D(wrap_cnt),
        .E(aw_cmd_fsm_0_n_0),
        .Q(Q),
        .aclk(aclk),
        .areset_d1(areset_d1),
        .\axaddr_incr[11]_i_3 (\s_awid_r_reg[15]_0 [3]),
        .\axaddr_incr[11]_i_3_0 (\axaddr_incr[11]_i_3 ),
        .\axaddr_incr[11]_i_3_1 (\axaddr_incr[11]_i_3_0 ),
        .\axaddr_incr[11]_i_5_0 (\axaddr_incr[11]_i_5 ),
        .\axaddr_incr[11]_i_5_1 (\axaddr_incr[11]_i_5_0 ),
        .\axaddr_incr[11]_i_5_2 (\axaddr_incr[11]_i_5_1 ),
        .\axaddr_incr[11]_i_5_3 (\axaddr_incr[11]_i_5_2 ),
        .\axaddr_incr_reg[0] (sel_first),
        .axaddr_offset(\wrap_cmd_0/axaddr_offset ),
        .\axaddr_offset_r_reg[1] (\axaddr_offset_r_reg[1] ),
        .\axaddr_offset_r_reg[2] (\axaddr_offset_r_reg[2] ),
        .\axaddr_offset_r_reg[3] (\wrap_cmd_0/axaddr_offset_r ),
        .\cnt_read_reg[0] (\cnt_read_reg[0] ),
        .m_axi_awready(m_axi_awready),
        .m_axi_awvalid(m_axi_awvalid),
        .\m_payload_i_reg[3] (\m_payload_i_reg[3] ),
        .m_valid_i_reg(E),
        .next_pending_r_reg(cmd_translator_0_n_7),
        .sel_first__0(sel_first__0),
        .sel_first_i(sel_first_i),
        .sel_first_reg(aw_cmd_fsm_0_n_4),
        .sel_first_reg_0(aw_cmd_fsm_0_n_5),
        .sel_first_reg_1(aw_cmd_fsm_0_n_19),
        .sel_first_reg_2(cmd_translator_0_n_0),
        .si_rs_awvalid(si_rs_awvalid),
        .\state_reg[0]_0 (\state_reg[1]_0 ),
        .\state_reg[1]_0 (b_push),
        .\state_reg[1]_1 (\state_reg[1] ),
        .\state_reg[1]_2 (\state_reg[1]_1 ),
        .wrap_second_len(\wrap_cmd_0/wrap_second_len ),
        .\wrap_second_len_r_reg[3] (\wrap_cmd_0/wrap_second_len_r ),
        .\wrap_second_len_r_reg[3]_0 (\wrap_second_len_r_reg[3] ),
        .\wrap_second_len_r_reg[3]_1 (\wrap_second_len_r_reg[3]_0 ));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_cmd_translator cmd_translator_0
       (.D({\wrap_cmd_0/axaddr_offset ,D}),
        .E(\state_reg[1] ),
        .Q(Q),
        .aclk(aclk),
        .\axaddr_incr_reg[0] (\axaddr_incr_reg[0] ),
        .\axaddr_incr_reg[0]_0 (aw_cmd_fsm_0_n_19),
        .\axaddr_incr_reg[10] (\axaddr_incr_reg[10] ),
        .\axaddr_incr_reg[10]_0 (\axaddr_incr_reg[10]_0 ),
        .\axaddr_incr_reg[11] (\axaddr_incr_reg[11] ),
        .\axaddr_incr_reg[2] (\axaddr_incr_reg[2] ),
        .\axaddr_incr_reg[2]_0 (\axaddr_incr_reg[2]_0 ),
        .\axaddr_incr_reg[4] (\axaddr_incr_reg[4] ),
        .\axaddr_incr_reg[5] (\axaddr_incr_reg[5] ),
        .\axaddr_incr_reg[5]_0 (\axaddr_incr_reg[5]_0 ),
        .\axaddr_incr_reg[6] (\axaddr_incr_reg[6] ),
        .\axaddr_incr_reg[7] (\axaddr_incr_reg[7] ),
        .\axaddr_incr_reg[9] (\axaddr_incr_reg[9] ),
        .\axaddr_incr_reg[9]_0 (\axaddr_incr_reg[9]_0 ),
        .\axaddr_offset_r_reg[3] ({\wrap_cmd_0/axaddr_offset_r ,\axaddr_offset_r_reg[0] }),
        .\axaddr_wrap_reg[0] (\axaddr_wrap_reg[0] ),
        .\axaddr_wrap_reg[0]_0 (aw_cmd_fsm_0_n_0),
        .\axaddr_wrap_reg[1] (\axaddr_wrap_reg[1] ),
        .\axaddr_wrap_reg[2] (\axaddr_wrap_reg[2] ),
        .\axaddr_wrap_reg[3] (\axaddr_wrap_reg[3] ),
        .\axaddr_wrap_reg[3]_0 (\axaddr_wrap_reg[3]_0 ),
        .\axlen_cnt_reg[7] (\s_awid_r_reg[15]_0 [23:0]),
        .m_axi_awaddr(m_axi_awaddr),
        .next_pending_r_reg(\cnt_read_reg[0] ),
        .next_pending_r_reg_0(next_pending_r_reg),
        .next_pending_r_reg_1(next_pending_r_reg_0),
        .s_axburst_eq1_reg_0(s_axburst_eq1_reg),
        .s_axburst_eq1_reg_1(cmd_translator_0_n_7),
        .sel_first__0(sel_first__0),
        .sel_first_i(sel_first_i),
        .sel_first_reg_0(cmd_translator_0_n_0),
        .sel_first_reg_1(sel_first),
        .sel_first_reg_2(aw_cmd_fsm_0_n_5),
        .sel_first_reg_3(aw_cmd_fsm_0_n_4),
        .si_rs_awvalid(si_rs_awvalid),
        .\state_reg[1] (\state_reg[1]_0 ),
        .\wrap_boundary_axaddr_r_reg[6] (\wrap_boundary_axaddr_r_reg[6] ),
        .\wrap_cnt_r_reg[3] (wrap_cnt),
        .\wrap_second_len_r_reg[3] (\wrap_cmd_0/wrap_second_len_r ),
        .\wrap_second_len_r_reg[3]_0 (\wrap_cmd_0/wrap_second_len ));
  FDRE \s_awid_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [24]),
        .Q(in[8]),
        .R(1'b0));
  FDRE \s_awid_r_reg[10] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [34]),
        .Q(in[18]),
        .R(1'b0));
  FDRE \s_awid_r_reg[11] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [35]),
        .Q(in[19]),
        .R(1'b0));
  FDRE \s_awid_r_reg[12] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [36]),
        .Q(in[20]),
        .R(1'b0));
  FDRE \s_awid_r_reg[13] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [37]),
        .Q(in[21]),
        .R(1'b0));
  FDRE \s_awid_r_reg[14] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [38]),
        .Q(in[22]),
        .R(1'b0));
  FDRE \s_awid_r_reg[15] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [39]),
        .Q(in[23]),
        .R(1'b0));
  FDRE \s_awid_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [25]),
        .Q(in[9]),
        .R(1'b0));
  FDRE \s_awid_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [26]),
        .Q(in[10]),
        .R(1'b0));
  FDRE \s_awid_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [27]),
        .Q(in[11]),
        .R(1'b0));
  FDRE \s_awid_r_reg[4] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [28]),
        .Q(in[12]),
        .R(1'b0));
  FDRE \s_awid_r_reg[5] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [29]),
        .Q(in[13]),
        .R(1'b0));
  FDRE \s_awid_r_reg[6] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [30]),
        .Q(in[14]),
        .R(1'b0));
  FDRE \s_awid_r_reg[7] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [31]),
        .Q(in[15]),
        .R(1'b0));
  FDRE \s_awid_r_reg[8] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [32]),
        .Q(in[16]),
        .R(1'b0));
  FDRE \s_awid_r_reg[9] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [33]),
        .Q(in[17]),
        .R(1'b0));
  FDRE \s_awlen_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [16]),
        .Q(in[0]),
        .R(1'b0));
  FDRE \s_awlen_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [17]),
        .Q(in[1]),
        .R(1'b0));
  FDRE \s_awlen_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [18]),
        .Q(in[2]),
        .R(1'b0));
  FDRE \s_awlen_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [19]),
        .Q(in[3]),
        .R(1'b0));
  FDRE \s_awlen_r_reg[4] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [20]),
        .Q(in[4]),
        .R(1'b0));
  FDRE \s_awlen_r_reg[5] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [21]),
        .Q(in[5]),
        .R(1'b0));
  FDRE \s_awlen_r_reg[6] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [22]),
        .Q(in[6]),
        .R(1'b0));
  FDRE \s_awlen_r_reg[7] 
       (.C(aclk),
        .CE(1'b1),
        .D(\s_awid_r_reg[15]_0 [23]),
        .Q(in[7]),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_b_channel" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_b_channel
   (si_rs_bvalid,
    Q,
    \cnt_read_reg[1] ,
    \cnt_read_reg[0] ,
    m_axi_bready,
    out,
    \s_bresp_acc_reg[1]_0 ,
    areset_d1,
    shandshake,
    aclk,
    b_push,
    \state_reg[1] ,
    m_axi_awready,
    \state_reg[1]_0 ,
    si_rs_bready,
    m_axi_bresp,
    m_axi_bvalid,
    in);
  output si_rs_bvalid;
  output [1:0]Q;
  output [0:0]\cnt_read_reg[1] ;
  output \cnt_read_reg[0] ;
  output m_axi_bready;
  output [15:0]out;
  output [1:0]\s_bresp_acc_reg[1]_0 ;
  input areset_d1;
  input shandshake;
  input aclk;
  input b_push;
  input \state_reg[1] ;
  input m_axi_awready;
  input [0:0]\state_reg[1]_0 ;
  input si_rs_bready;
  input [1:0]m_axi_bresp;
  input m_axi_bvalid;
  input [23:0]in;

  wire [1:0]Q;
  wire aclk;
  wire areset_d1;
  wire b_push;
  wire bid_fifo_0_n_4;
  wire bid_fifo_0_n_7;
  wire \bresp_cnt[7]_i_2_n_0 ;
  wire [7:0]bresp_cnt_reg;
  wire bresp_fifo_0_n_0;
  wire bresp_push;
  wire \cnt_read_reg[0] ;
  wire [0:0]\cnt_read_reg[1] ;
  wire [23:0]in;
  wire m_axi_awready;
  wire m_axi_bready;
  wire [1:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire mhandshake;
  wire mhandshake_r;
  wire [15:0]out;
  wire [7:0]p_0_in;
  wire s_bresp_acc;
  wire s_bresp_acc0;
  wire [1:0]\s_bresp_acc_reg[1]_0 ;
  wire \s_bresp_acc_reg_n_0_[0] ;
  wire \s_bresp_acc_reg_n_0_[1] ;
  wire shandshake;
  wire shandshake_r;
  wire si_rs_bready;
  wire si_rs_bvalid;
  wire \state_reg[1] ;
  wire [0:0]\state_reg[1]_0 ;

  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_simple_fifo bid_fifo_0
       (.E(bid_fifo_0_n_4),
        .Q(Q),
        .SR(s_bresp_acc0),
        .aclk(aclk),
        .areset_d1(areset_d1),
        .b_push(b_push),
        .bresp_push(bresp_push),
        .\cnt_read_reg[0]_0 (\cnt_read_reg[0] ),
        .\cnt_read_reg[0]_1 (bid_fifo_0_n_7),
        .\cnt_read_reg[1]_0 (\cnt_read_reg[1] ),
        .in(in),
        .m_axi_awready(m_axi_awready),
        .\memory_reg[3][0]_srl4_i_1__0_0 (bresp_cnt_reg),
        .mhandshake_r(mhandshake_r),
        .out(out),
        .shandshake_r(shandshake_r),
        .\state_reg[1] (\state_reg[1] ),
        .\state_reg[1]_0 (\state_reg[1]_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \bresp_cnt[0]_i_1 
       (.I0(bresp_cnt_reg[0]),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair166" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \bresp_cnt[1]_i_1 
       (.I0(bresp_cnt_reg[0]),
        .I1(bresp_cnt_reg[1]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair166" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \bresp_cnt[2]_i_1 
       (.I0(bresp_cnt_reg[2]),
        .I1(bresp_cnt_reg[1]),
        .I2(bresp_cnt_reg[0]),
        .O(p_0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair164" *) 
  LUT4 #(
    .INIT(16'h6AAA)) 
    \bresp_cnt[3]_i_1 
       (.I0(bresp_cnt_reg[3]),
        .I1(bresp_cnt_reg[0]),
        .I2(bresp_cnt_reg[1]),
        .I3(bresp_cnt_reg[2]),
        .O(p_0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair164" *) 
  LUT5 #(
    .INIT(32'h6AAAAAAA)) 
    \bresp_cnt[4]_i_1 
       (.I0(bresp_cnt_reg[4]),
        .I1(bresp_cnt_reg[3]),
        .I2(bresp_cnt_reg[2]),
        .I3(bresp_cnt_reg[1]),
        .I4(bresp_cnt_reg[0]),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h6AAAAAAAAAAAAAAA)) 
    \bresp_cnt[5]_i_1 
       (.I0(bresp_cnt_reg[5]),
        .I1(bresp_cnt_reg[0]),
        .I2(bresp_cnt_reg[1]),
        .I3(bresp_cnt_reg[2]),
        .I4(bresp_cnt_reg[3]),
        .I5(bresp_cnt_reg[4]),
        .O(p_0_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair165" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \bresp_cnt[6]_i_1 
       (.I0(bresp_cnt_reg[6]),
        .I1(\bresp_cnt[7]_i_2_n_0 ),
        .O(p_0_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair165" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \bresp_cnt[7]_i_1 
       (.I0(bresp_cnt_reg[7]),
        .I1(\bresp_cnt[7]_i_2_n_0 ),
        .I2(bresp_cnt_reg[6]),
        .O(p_0_in[7]));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \bresp_cnt[7]_i_2 
       (.I0(bresp_cnt_reg[5]),
        .I1(bresp_cnt_reg[0]),
        .I2(bresp_cnt_reg[1]),
        .I3(bresp_cnt_reg[2]),
        .I4(bresp_cnt_reg[3]),
        .I5(bresp_cnt_reg[4]),
        .O(\bresp_cnt[7]_i_2_n_0 ));
  FDRE \bresp_cnt_reg[0] 
       (.C(aclk),
        .CE(mhandshake_r),
        .D(p_0_in[0]),
        .Q(bresp_cnt_reg[0]),
        .R(s_bresp_acc0));
  FDRE \bresp_cnt_reg[1] 
       (.C(aclk),
        .CE(mhandshake_r),
        .D(p_0_in[1]),
        .Q(bresp_cnt_reg[1]),
        .R(s_bresp_acc0));
  FDRE \bresp_cnt_reg[2] 
       (.C(aclk),
        .CE(mhandshake_r),
        .D(p_0_in[2]),
        .Q(bresp_cnt_reg[2]),
        .R(s_bresp_acc0));
  FDRE \bresp_cnt_reg[3] 
       (.C(aclk),
        .CE(mhandshake_r),
        .D(p_0_in[3]),
        .Q(bresp_cnt_reg[3]),
        .R(s_bresp_acc0));
  FDRE \bresp_cnt_reg[4] 
       (.C(aclk),
        .CE(mhandshake_r),
        .D(p_0_in[4]),
        .Q(bresp_cnt_reg[4]),
        .R(s_bresp_acc0));
  FDRE \bresp_cnt_reg[5] 
       (.C(aclk),
        .CE(mhandshake_r),
        .D(p_0_in[5]),
        .Q(bresp_cnt_reg[5]),
        .R(s_bresp_acc0));
  FDRE \bresp_cnt_reg[6] 
       (.C(aclk),
        .CE(mhandshake_r),
        .D(p_0_in[6]),
        .Q(bresp_cnt_reg[6]),
        .R(s_bresp_acc0));
  FDRE \bresp_cnt_reg[7] 
       (.C(aclk),
        .CE(mhandshake_r),
        .D(p_0_in[7]),
        .Q(bresp_cnt_reg[7]),
        .R(s_bresp_acc0));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_simple_fifo__parameterized0 bresp_fifo_0
       (.E(s_bresp_acc),
        .Q({\s_bresp_acc_reg_n_0_[1] ,\s_bresp_acc_reg_n_0_[0] }),
        .aclk(aclk),
        .areset_d1(areset_d1),
        .areset_d1_reg(bresp_fifo_0_n_0),
        .bvalid_i_reg(bid_fifo_0_n_7),
        .\cnt_read_reg[1]_0 (bid_fifo_0_n_4),
        .m_axi_bready(m_axi_bready),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .mhandshake(mhandshake),
        .mhandshake_r(mhandshake_r),
        .\s_bresp_acc_reg[1] (\s_bresp_acc_reg[1]_0 ),
        .sel(bresp_push),
        .shandshake_r(shandshake_r),
        .si_rs_bready(si_rs_bready),
        .si_rs_bvalid(si_rs_bvalid));
  FDRE #(
    .INIT(1'b0)) 
    bvalid_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(bresp_fifo_0_n_0),
        .Q(si_rs_bvalid),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    mhandshake_r_reg
       (.C(aclk),
        .CE(1'b1),
        .D(mhandshake),
        .Q(mhandshake_r),
        .R(areset_d1));
  FDRE \s_bresp_acc_reg[0] 
       (.C(aclk),
        .CE(s_bresp_acc),
        .D(m_axi_bresp[0]),
        .Q(\s_bresp_acc_reg_n_0_[0] ),
        .R(s_bresp_acc0));
  FDRE \s_bresp_acc_reg[1] 
       (.C(aclk),
        .CE(s_bresp_acc),
        .D(m_axi_bresp[1]),
        .Q(\s_bresp_acc_reg_n_0_[1] ),
        .R(s_bresp_acc0));
  FDRE #(
    .INIT(1'b0)) 
    shandshake_r_reg
       (.C(aclk),
        .CE(1'b1),
        .D(shandshake),
        .Q(shandshake_r),
        .R(areset_d1));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_cmd_translator" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_cmd_translator
   (sel_first_reg_0,
    sel_first_reg_1,
    sel_first__0,
    \axaddr_wrap_reg[3] ,
    s_axburst_eq1_reg_0,
    s_axburst_eq1_reg_1,
    \axaddr_incr_reg[10] ,
    \axaddr_incr_reg[10]_0 ,
    \axaddr_incr_reg[9] ,
    \axaddr_incr_reg[7] ,
    \axaddr_incr_reg[6] ,
    \axaddr_incr_reg[5] ,
    \axaddr_incr_reg[0] ,
    m_axi_awaddr,
    \axaddr_offset_r_reg[3] ,
    \wrap_second_len_r_reg[3] ,
    aclk,
    sel_first_i,
    sel_first_reg_2,
    sel_first_reg_3,
    \axlen_cnt_reg[7] ,
    next_pending_r_reg,
    E,
    next_pending_r_reg_0,
    next_pending_r_reg_1,
    Q,
    si_rs_awvalid,
    \axaddr_wrap_reg[3]_0 ,
    \axaddr_wrap_reg[2] ,
    \axaddr_wrap_reg[1] ,
    \axaddr_wrap_reg[0] ,
    \axaddr_incr_reg[2] ,
    \axaddr_incr_reg[2]_0 ,
    \axaddr_incr_reg[4] ,
    \axaddr_incr_reg[5]_0 ,
    \axaddr_incr_reg[9]_0 ,
    \state_reg[1] ,
    \axaddr_wrap_reg[0]_0 ,
    D,
    \wrap_second_len_r_reg[3]_0 ,
    \wrap_cnt_r_reg[3] ,
    \wrap_boundary_axaddr_r_reg[6] ,
    \axaddr_incr_reg[0]_0 ,
    \axaddr_incr_reg[11] );
  output sel_first_reg_0;
  output sel_first_reg_1;
  output sel_first__0;
  output [2:0]\axaddr_wrap_reg[3] ;
  output s_axburst_eq1_reg_0;
  output s_axburst_eq1_reg_1;
  output \axaddr_incr_reg[10] ;
  output [6:0]\axaddr_incr_reg[10]_0 ;
  output \axaddr_incr_reg[9] ;
  output \axaddr_incr_reg[7] ;
  output \axaddr_incr_reg[6] ;
  output \axaddr_incr_reg[5] ;
  output \axaddr_incr_reg[0] ;
  output [11:0]m_axi_awaddr;
  output [3:0]\axaddr_offset_r_reg[3] ;
  output [3:0]\wrap_second_len_r_reg[3] ;
  input aclk;
  input sel_first_i;
  input sel_first_reg_2;
  input sel_first_reg_3;
  input [23:0]\axlen_cnt_reg[7] ;
  input next_pending_r_reg;
  input [0:0]E;
  input next_pending_r_reg_0;
  input next_pending_r_reg_1;
  input [1:0]Q;
  input si_rs_awvalid;
  input \axaddr_wrap_reg[3]_0 ;
  input \axaddr_wrap_reg[2] ;
  input \axaddr_wrap_reg[1] ;
  input \axaddr_wrap_reg[0] ;
  input \axaddr_incr_reg[2] ;
  input \axaddr_incr_reg[2]_0 ;
  input \axaddr_incr_reg[4] ;
  input \axaddr_incr_reg[5]_0 ;
  input \axaddr_incr_reg[9]_0 ;
  input [1:0]\state_reg[1] ;
  input [0:0]\axaddr_wrap_reg[0]_0 ;
  input [3:0]D;
  input [3:0]\wrap_second_len_r_reg[3]_0 ;
  input [3:0]\wrap_cnt_r_reg[3] ;
  input [6:0]\wrap_boundary_axaddr_r_reg[6] ;
  input [0:0]\axaddr_incr_reg[0]_0 ;
  input [7:0]\axaddr_incr_reg[11] ;

  wire [3:0]D;
  wire [0:0]E;
  wire [1:0]Q;
  wire aclk;
  wire \axaddr_incr_reg[0] ;
  wire [0:0]\axaddr_incr_reg[0]_0 ;
  wire \axaddr_incr_reg[10] ;
  wire [6:0]\axaddr_incr_reg[10]_0 ;
  wire [7:0]\axaddr_incr_reg[11] ;
  wire \axaddr_incr_reg[2] ;
  wire \axaddr_incr_reg[2]_0 ;
  wire \axaddr_incr_reg[4] ;
  wire \axaddr_incr_reg[5] ;
  wire \axaddr_incr_reg[5]_0 ;
  wire \axaddr_incr_reg[6] ;
  wire \axaddr_incr_reg[7] ;
  wire \axaddr_incr_reg[9] ;
  wire \axaddr_incr_reg[9]_0 ;
  wire [3:0]\axaddr_offset_r_reg[3] ;
  wire [11:1]axaddr_wrap;
  wire \axaddr_wrap_reg[0] ;
  wire [0:0]\axaddr_wrap_reg[0]_0 ;
  wire \axaddr_wrap_reg[1] ;
  wire \axaddr_wrap_reg[2] ;
  wire [2:0]\axaddr_wrap_reg[3] ;
  wire \axaddr_wrap_reg[3]_0 ;
  wire [23:0]\axlen_cnt_reg[7] ;
  wire incr_next_pending;
  wire [11:0]m_axi_awaddr;
  wire next_pending_r_reg;
  wire next_pending_r_reg_0;
  wire next_pending_r_reg_1;
  wire s_axburst_eq0;
  wire s_axburst_eq1;
  wire s_axburst_eq1_reg_0;
  wire s_axburst_eq1_reg_1;
  wire sel_first__0;
  wire sel_first_i;
  wire sel_first_reg_0;
  wire sel_first_reg_1;
  wire sel_first_reg_2;
  wire sel_first_reg_3;
  wire si_rs_awvalid;
  wire [1:0]\state_reg[1] ;
  wire [6:0]\wrap_boundary_axaddr_r_reg[6] ;
  wire wrap_cmd_0_n_1;
  wire wrap_cmd_0_n_2;
  wire [3:0]\wrap_cnt_r_reg[3] ;
  wire [3:0]\wrap_second_len_r_reg[3] ;
  wire [3:0]\wrap_second_len_r_reg[3]_0 ;

  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_incr_cmd incr_cmd_0
       (.E(E),
        .Q(Q),
        .aclk(aclk),
        .\axaddr_incr_reg[0]_0 (\axaddr_incr_reg[0] ),
        .\axaddr_incr_reg[0]_1 (\axaddr_incr_reg[0]_0 ),
        .\axaddr_incr_reg[10]_0 (\axaddr_incr_reg[10] ),
        .\axaddr_incr_reg[10]_1 (\axaddr_incr_reg[10]_0 ),
        .\axaddr_incr_reg[11]_0 (\axaddr_incr_reg[11] ),
        .\axaddr_incr_reg[2]_0 (\axaddr_incr_reg[2] ),
        .\axaddr_incr_reg[2]_1 (\axaddr_incr_reg[2]_0 ),
        .\axaddr_incr_reg[4]_0 (\axaddr_incr_reg[4] ),
        .\axaddr_incr_reg[5]_0 (\axaddr_incr_reg[5] ),
        .\axaddr_incr_reg[5]_1 (\axaddr_incr_reg[5]_0 ),
        .\axaddr_incr_reg[6]_0 (\axaddr_incr_reg[6] ),
        .\axaddr_incr_reg[7]_0 (\axaddr_incr_reg[7] ),
        .\axaddr_incr_reg[9]_0 (\axaddr_incr_reg[9] ),
        .\axaddr_incr_reg[9]_1 (\axaddr_incr_reg[9]_0 ),
        .\axlen_cnt_reg[0]_0 (\axaddr_wrap_reg[0]_0 ),
        .\axlen_cnt_reg[7]_0 (\axlen_cnt_reg[7] ),
        .incr_next_pending(incr_next_pending),
        .m_axi_awaddr(m_axi_awaddr),
        .\m_axi_awaddr[11] ({axaddr_wrap[11:4],\axaddr_wrap_reg[3] [2:1],axaddr_wrap[1],\axaddr_wrap_reg[3] [0]}),
        .\m_axi_awaddr[11]_0 (sel_first__0),
        .next_pending_r_reg_0(next_pending_r_reg),
        .next_pending_r_reg_1(next_pending_r_reg_0),
        .s_axburst_eq0(s_axburst_eq0),
        .s_axburst_eq1(s_axburst_eq1),
        .s_axburst_eq1_reg(s_axburst_eq1_reg_1),
        .sel_first_reg_0(sel_first_reg_1),
        .sel_first_reg_1(sel_first_reg_2),
        .si_rs_awvalid(si_rs_awvalid));
  FDRE s_axburst_eq0_reg
       (.C(aclk),
        .CE(1'b1),
        .D(wrap_cmd_0_n_1),
        .Q(s_axburst_eq0),
        .R(1'b0));
  FDRE s_axburst_eq1_reg
       (.C(aclk),
        .CE(1'b1),
        .D(wrap_cmd_0_n_2),
        .Q(s_axburst_eq1),
        .R(1'b0));
  FDRE sel_first_reg
       (.C(aclk),
        .CE(1'b1),
        .D(sel_first_i),
        .Q(sel_first_reg_0),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h47004747FFFFFFFF)) 
    \state[1]_i_2 
       (.I0(s_axburst_eq1),
        .I1(\axlen_cnt_reg[7] [15]),
        .I2(s_axburst_eq0),
        .I3(\state_reg[1] [0]),
        .I4(\state_reg[1] [1]),
        .I5(Q[0]),
        .O(s_axburst_eq1_reg_0));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_wrap_cmd wrap_cmd_0
       (.D(D),
        .E(E),
        .Q(Q),
        .aclk(aclk),
        .\axaddr_offset_r_reg[3]_0 (\axaddr_offset_r_reg[3] ),
        .\axaddr_wrap_reg[0]_0 (\axaddr_wrap_reg[0] ),
        .\axaddr_wrap_reg[0]_1 (\axaddr_wrap_reg[0]_0 ),
        .\axaddr_wrap_reg[11]_0 ({axaddr_wrap[11:4],\axaddr_wrap_reg[3] [2:1],axaddr_wrap[1],\axaddr_wrap_reg[3] [0]}),
        .\axaddr_wrap_reg[1]_0 (\axaddr_wrap_reg[1] ),
        .\axaddr_wrap_reg[2]_0 (\axaddr_wrap_reg[2] ),
        .\axaddr_wrap_reg[3]_0 (\axaddr_wrap_reg[3]_0 ),
        .\axlen_cnt_reg[3]_0 ({\axlen_cnt_reg[7] [19:15],\axlen_cnt_reg[7] [13:0]}),
        .incr_next_pending(incr_next_pending),
        .\m_payload_i_reg[47] (wrap_cmd_0_n_1),
        .\m_payload_i_reg[47]_0 (wrap_cmd_0_n_2),
        .next_pending_r_reg_0(next_pending_r_reg_1),
        .next_pending_r_reg_1(next_pending_r_reg),
        .sel_first__0(sel_first__0),
        .sel_first_i(sel_first_i),
        .sel_first_reg_0(sel_first_reg_3),
        .si_rs_awvalid(si_rs_awvalid),
        .\wrap_boundary_axaddr_r_reg[6]_0 (\wrap_boundary_axaddr_r_reg[6] ),
        .\wrap_cnt_r_reg[3]_0 (\wrap_cnt_r_reg[3] ),
        .\wrap_second_len_r_reg[3]_0 (\wrap_second_len_r_reg[3] ),
        .\wrap_second_len_r_reg[3]_1 (\wrap_second_len_r_reg[3]_0 ));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_cmd_translator" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_cmd_translator_1
   (incr_next_pending,
    sel_first_reg_0,
    sel_first_reg_1,
    sel_first_reg_2,
    \axlen_cnt_reg[7] ,
    next_pending_r_reg,
    Q,
    \axlen_cnt_reg[1] ,
    \axaddr_wrap_reg[3] ,
    \axlen_cnt_reg[6] ,
    s_axburst_eq1_reg_0,
    m_axi_arready_0,
    r_rlast,
    \axaddr_incr_reg[10] ,
    \axaddr_incr_reg[11] ,
    \axaddr_incr_reg[5] ,
    \m_payload_i_reg[43] ,
    \axlen_cnt_reg[3] ,
    m_axi_araddr,
    \axaddr_offset_r_reg[3] ,
    \wrap_second_len_r_reg[3] ,
    aclk,
    wrap_next_pending,
    sel_first_i,
    s_axburst_eq0_reg_0,
    s_axburst_eq1_reg_1,
    sel_first_reg_3,
    sel_first_reg_4,
    next_pending_r_reg_0,
    E,
    \axaddr_wrap_reg[11] ,
    \axlen_cnt_reg[6]_0 ,
    \axlen_cnt_reg[3]_0 ,
    \axlen_cnt_reg[6]_1 ,
    \axaddr_wrap_reg[3]_0 ,
    \axaddr_wrap_reg[2] ,
    \axaddr_wrap_reg[1] ,
    \axaddr_wrap_reg[0] ,
    \axaddr_incr_reg[4] ,
    \axaddr_incr_reg[5]_0 ,
    \axaddr_incr_reg[7] ,
    \axaddr_incr_reg[8] ,
    \axaddr_incr_reg[9] ,
    \axaddr_incr_reg[10]_0 ,
    \axaddr_incr_reg[2] ,
    \axaddr_incr_reg[2]_0 ,
    m_axi_arready,
    \FSM_sequential_state_reg[0] ,
    \axaddr_wrap_reg[0]_0 ,
    D,
    \axaddr_offset_r_reg[3]_0 ,
    \wrap_second_len_r_reg[3]_0 ,
    \wrap_cnt_r_reg[3] ,
    \wrap_boundary_axaddr_r_reg[6] ,
    \axaddr_incr_reg[0] ,
    \axaddr_incr_reg[11]_0 );
  output incr_next_pending;
  output sel_first_reg_0;
  output sel_first_reg_1;
  output sel_first_reg_2;
  output \axlen_cnt_reg[7] ;
  output next_pending_r_reg;
  output [3:0]Q;
  output \axlen_cnt_reg[1] ;
  output [2:0]\axaddr_wrap_reg[3] ;
  output \axlen_cnt_reg[6] ;
  output s_axburst_eq1_reg_0;
  output m_axi_arready_0;
  output r_rlast;
  output \axaddr_incr_reg[10] ;
  output [4:0]\axaddr_incr_reg[11] ;
  output \axaddr_incr_reg[5] ;
  output \m_payload_i_reg[43] ;
  output \axlen_cnt_reg[3] ;
  output [11:0]m_axi_araddr;
  output [3:0]\axaddr_offset_r_reg[3] ;
  output [3:0]\wrap_second_len_r_reg[3] ;
  input aclk;
  input wrap_next_pending;
  input sel_first_i;
  input s_axburst_eq0_reg_0;
  input s_axburst_eq1_reg_1;
  input sel_first_reg_3;
  input sel_first_reg_4;
  input next_pending_r_reg_0;
  input [0:0]E;
  input \axaddr_wrap_reg[11] ;
  input [20:0]\axlen_cnt_reg[6]_0 ;
  input \axlen_cnt_reg[3]_0 ;
  input \axlen_cnt_reg[6]_1 ;
  input \axaddr_wrap_reg[3]_0 ;
  input \axaddr_wrap_reg[2] ;
  input \axaddr_wrap_reg[1] ;
  input \axaddr_wrap_reg[0] ;
  input \axaddr_incr_reg[4] ;
  input \axaddr_incr_reg[5]_0 ;
  input \axaddr_incr_reg[7] ;
  input \axaddr_incr_reg[8] ;
  input \axaddr_incr_reg[9] ;
  input \axaddr_incr_reg[10]_0 ;
  input \axaddr_incr_reg[2] ;
  input \axaddr_incr_reg[2]_0 ;
  input m_axi_arready;
  input [0:0]\FSM_sequential_state_reg[0] ;
  input [0:0]\axaddr_wrap_reg[0]_0 ;
  input [3:0]D;
  input [3:0]\axaddr_offset_r_reg[3]_0 ;
  input [3:0]\wrap_second_len_r_reg[3]_0 ;
  input [3:0]\wrap_cnt_r_reg[3] ;
  input [6:0]\wrap_boundary_axaddr_r_reg[6] ;
  input [0:0]\axaddr_incr_reg[0] ;
  input [4:0]\axaddr_incr_reg[11]_0 ;

  wire [3:0]D;
  wire [0:0]E;
  wire [0:0]\FSM_sequential_state_reg[0] ;
  wire [3:0]Q;
  wire aclk;
  wire [0:0]\axaddr_incr_reg[0] ;
  wire \axaddr_incr_reg[10] ;
  wire \axaddr_incr_reg[10]_0 ;
  wire [4:0]\axaddr_incr_reg[11] ;
  wire [4:0]\axaddr_incr_reg[11]_0 ;
  wire \axaddr_incr_reg[2] ;
  wire \axaddr_incr_reg[2]_0 ;
  wire \axaddr_incr_reg[4] ;
  wire \axaddr_incr_reg[5] ;
  wire \axaddr_incr_reg[5]_0 ;
  wire \axaddr_incr_reg[7] ;
  wire \axaddr_incr_reg[8] ;
  wire \axaddr_incr_reg[9] ;
  wire [3:0]\axaddr_offset_r_reg[3] ;
  wire [3:0]\axaddr_offset_r_reg[3]_0 ;
  wire \axaddr_wrap_reg[0] ;
  wire [0:0]\axaddr_wrap_reg[0]_0 ;
  wire \axaddr_wrap_reg[11] ;
  wire \axaddr_wrap_reg[1] ;
  wire \axaddr_wrap_reg[2] ;
  wire [2:0]\axaddr_wrap_reg[3] ;
  wire \axaddr_wrap_reg[3]_0 ;
  wire \axlen_cnt_reg[1] ;
  wire \axlen_cnt_reg[3] ;
  wire \axlen_cnt_reg[3]_0 ;
  wire \axlen_cnt_reg[6] ;
  wire [20:0]\axlen_cnt_reg[6]_0 ;
  wire \axlen_cnt_reg[6]_1 ;
  wire \axlen_cnt_reg[7] ;
  wire incr_next_pending;
  wire [11:0]m_axi_araddr;
  wire m_axi_arready;
  wire m_axi_arready_0;
  wire \m_payload_i_reg[43] ;
  wire next_pending_r_reg;
  wire next_pending_r_reg_0;
  wire r_rlast;
  wire s_axburst_eq0;
  wire s_axburst_eq0_reg_0;
  wire s_axburst_eq1;
  wire s_axburst_eq1_reg_0;
  wire s_axburst_eq1_reg_1;
  wire sel_first_i;
  wire sel_first_reg_0;
  wire sel_first_reg_1;
  wire sel_first_reg_2;
  wire sel_first_reg_3;
  wire sel_first_reg_4;
  wire [6:0]\wrap_boundary_axaddr_r_reg[6] ;
  wire wrap_cmd_0_n_12;
  wire wrap_cmd_0_n_2;
  wire wrap_cmd_0_n_3;
  wire wrap_cmd_0_n_4;
  wire wrap_cmd_0_n_5;
  wire wrap_cmd_0_n_6;
  wire wrap_cmd_0_n_7;
  wire wrap_cmd_0_n_8;
  wire wrap_cmd_0_n_9;
  wire [3:0]\wrap_cnt_r_reg[3] ;
  wire wrap_next_pending;
  wire [3:0]\wrap_second_len_r_reg[3] ;
  wire [3:0]\wrap_second_len_r_reg[3]_0 ;

  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT5 #(
    .INIT(32'h4700FFFF)) 
    \FSM_sequential_state[0]_i_2 
       (.I0(s_axburst_eq1),
        .I1(\axlen_cnt_reg[6]_0 [15]),
        .I2(s_axburst_eq0),
        .I3(m_axi_arready),
        .I4(\FSM_sequential_state_reg[0] ),
        .O(s_axburst_eq1_reg_0));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT4 #(
    .INIT(16'h02A2)) 
    \FSM_sequential_state[1]_i_2 
       (.I0(m_axi_arready),
        .I1(s_axburst_eq0),
        .I2(\axlen_cnt_reg[6]_0 [15]),
        .I3(s_axburst_eq1),
        .O(m_axi_arready_0));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_incr_cmd_2 incr_cmd_0
       (.D(D),
        .E(E),
        .Q(Q),
        .aclk(aclk),
        .\axaddr_incr_reg[0]_0 (\axaddr_incr_reg[0] ),
        .\axaddr_incr_reg[10]_0 (\axaddr_incr_reg[10] ),
        .\axaddr_incr_reg[10]_1 (\axaddr_incr_reg[10]_0 ),
        .\axaddr_incr_reg[11]_0 (\axaddr_incr_reg[11] ),
        .\axaddr_incr_reg[11]_1 (\axaddr_incr_reg[11]_0 ),
        .\axaddr_incr_reg[2]_0 (\axaddr_incr_reg[2] ),
        .\axaddr_incr_reg[2]_1 (\axaddr_incr_reg[2]_0 ),
        .\axaddr_incr_reg[4]_0 (\axaddr_incr_reg[4] ),
        .\axaddr_incr_reg[5]_0 (\axaddr_incr_reg[5] ),
        .\axaddr_incr_reg[5]_1 (\axaddr_incr_reg[5]_0 ),
        .\axaddr_incr_reg[7]_0 (\axaddr_incr_reg[7] ),
        .\axaddr_incr_reg[8]_0 (\axaddr_incr_reg[8] ),
        .\axaddr_incr_reg[9]_0 (\axaddr_incr_reg[9] ),
        .\axlen_cnt_reg[0]_0 (\axaddr_wrap_reg[0]_0 ),
        .\axlen_cnt_reg[1]_0 (\axlen_cnt_reg[1] ),
        .\axlen_cnt_reg[3]_0 (\axlen_cnt_reg[3] ),
        .\axlen_cnt_reg[3]_1 (\axlen_cnt_reg[3]_0 ),
        .\axlen_cnt_reg[6]_0 (\axlen_cnt_reg[6] ),
        .\axlen_cnt_reg[6]_1 (\axlen_cnt_reg[6]_1 ),
        .\axlen_cnt_reg[6]_2 ({\axlen_cnt_reg[6]_0 [20],\axlen_cnt_reg[6]_0 [18:17],\axlen_cnt_reg[6]_0 [15:0]}),
        .\axlen_cnt_reg[7]_0 (\axlen_cnt_reg[7] ),
        .incr_next_pending(incr_next_pending),
        .m_axi_araddr(m_axi_araddr),
        .\m_axi_araddr[11] ({wrap_cmd_0_n_2,wrap_cmd_0_n_3,wrap_cmd_0_n_4,wrap_cmd_0_n_5,wrap_cmd_0_n_6,wrap_cmd_0_n_7,wrap_cmd_0_n_8,wrap_cmd_0_n_9,\axaddr_wrap_reg[3] [2:1],wrap_cmd_0_n_12,\axaddr_wrap_reg[3] [0]}),
        .\m_axi_araddr[11]_0 (sel_first_reg_2),
        .\m_payload_i_reg[43] (\m_payload_i_reg[43] ),
        .next_pending_r_reg_0(next_pending_r_reg_0),
        .next_pending_r_reg_1(\axaddr_wrap_reg[11] ),
        .sel_first_reg_0(sel_first_reg_1),
        .sel_first_reg_1(sel_first_reg_3));
  LUT3 #(
    .INIT(8'h1D)) 
    r_rlast_r_i_1
       (.I0(s_axburst_eq0),
        .I1(\axlen_cnt_reg[6]_0 [15]),
        .I2(s_axburst_eq1),
        .O(r_rlast));
  FDRE s_axburst_eq0_reg
       (.C(aclk),
        .CE(1'b1),
        .D(s_axburst_eq0_reg_0),
        .Q(s_axburst_eq0),
        .R(1'b0));
  FDRE s_axburst_eq1_reg
       (.C(aclk),
        .CE(1'b1),
        .D(s_axburst_eq1_reg_1),
        .Q(s_axburst_eq1),
        .R(1'b0));
  FDRE sel_first_reg
       (.C(aclk),
        .CE(1'b1),
        .D(sel_first_i),
        .Q(sel_first_reg_0),
        .R(1'b0));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_wrap_cmd_3 wrap_cmd_0
       (.E(E),
        .Q({wrap_cmd_0_n_2,wrap_cmd_0_n_3,wrap_cmd_0_n_4,wrap_cmd_0_n_5,wrap_cmd_0_n_6,wrap_cmd_0_n_7,wrap_cmd_0_n_8,wrap_cmd_0_n_9,\axaddr_wrap_reg[3] [2:1],wrap_cmd_0_n_12,\axaddr_wrap_reg[3] [0]}),
        .aclk(aclk),
        .\axaddr_offset_r_reg[3]_0 (\axaddr_offset_r_reg[3] ),
        .\axaddr_offset_r_reg[3]_1 (\axaddr_offset_r_reg[3]_0 ),
        .\axaddr_wrap_reg[0]_0 (\axaddr_wrap_reg[0] ),
        .\axaddr_wrap_reg[0]_1 (\axaddr_wrap_reg[0]_0 ),
        .\axaddr_wrap_reg[11]_0 (\axaddr_wrap_reg[11] ),
        .\axaddr_wrap_reg[1]_0 (\axaddr_wrap_reg[1] ),
        .\axaddr_wrap_reg[2]_0 (\axaddr_wrap_reg[2] ),
        .\axaddr_wrap_reg[3]_0 (\axaddr_wrap_reg[3]_0 ),
        .\axlen_cnt_reg[3]_0 ({\axlen_cnt_reg[6]_0 [19:16],\axlen_cnt_reg[6]_0 [13:0]}),
        .next_pending_r_reg_0(next_pending_r_reg),
        .sel_first_reg_0(sel_first_reg_2),
        .sel_first_reg_1(sel_first_reg_4),
        .\wrap_boundary_axaddr_r_reg[6]_0 (\wrap_boundary_axaddr_r_reg[6] ),
        .\wrap_cnt_r_reg[3]_0 (\wrap_cnt_r_reg[3] ),
        .wrap_next_pending(wrap_next_pending),
        .\wrap_second_len_r_reg[3]_0 (\wrap_second_len_r_reg[3] ),
        .\wrap_second_len_r_reg[3]_1 (\wrap_second_len_r_reg[3]_0 ));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_incr_cmd" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_incr_cmd
   (incr_next_pending,
    sel_first_reg_0,
    s_axburst_eq1_reg,
    \axaddr_incr_reg[10]_0 ,
    \axaddr_incr_reg[10]_1 ,
    \axaddr_incr_reg[9]_0 ,
    \axaddr_incr_reg[7]_0 ,
    \axaddr_incr_reg[6]_0 ,
    \axaddr_incr_reg[5]_0 ,
    \axaddr_incr_reg[0]_0 ,
    m_axi_awaddr,
    aclk,
    sel_first_reg_1,
    next_pending_r_reg_0,
    E,
    next_pending_r_reg_1,
    \axlen_cnt_reg[7]_0 ,
    Q,
    si_rs_awvalid,
    \axaddr_incr_reg[2]_0 ,
    \axaddr_incr_reg[2]_1 ,
    \axaddr_incr_reg[4]_0 ,
    \axaddr_incr_reg[5]_1 ,
    \axaddr_incr_reg[9]_1 ,
    s_axburst_eq1,
    s_axburst_eq0,
    \m_axi_awaddr[11] ,
    \m_axi_awaddr[11]_0 ,
    \axlen_cnt_reg[0]_0 ,
    \axaddr_incr_reg[0]_1 ,
    \axaddr_incr_reg[11]_0 );
  output incr_next_pending;
  output sel_first_reg_0;
  output s_axburst_eq1_reg;
  output \axaddr_incr_reg[10]_0 ;
  output [6:0]\axaddr_incr_reg[10]_1 ;
  output \axaddr_incr_reg[9]_0 ;
  output \axaddr_incr_reg[7]_0 ;
  output \axaddr_incr_reg[6]_0 ;
  output \axaddr_incr_reg[5]_0 ;
  output \axaddr_incr_reg[0]_0 ;
  output [11:0]m_axi_awaddr;
  input aclk;
  input sel_first_reg_1;
  input next_pending_r_reg_0;
  input [0:0]E;
  input next_pending_r_reg_1;
  input [23:0]\axlen_cnt_reg[7]_0 ;
  input [1:0]Q;
  input si_rs_awvalid;
  input \axaddr_incr_reg[2]_0 ;
  input \axaddr_incr_reg[2]_1 ;
  input \axaddr_incr_reg[4]_0 ;
  input \axaddr_incr_reg[5]_1 ;
  input \axaddr_incr_reg[9]_1 ;
  input s_axburst_eq1;
  input s_axburst_eq0;
  input [11:0]\m_axi_awaddr[11] ;
  input \m_axi_awaddr[11]_0 ;
  input [0:0]\axlen_cnt_reg[0]_0 ;
  input [0:0]\axaddr_incr_reg[0]_1 ;
  input [7:0]\axaddr_incr_reg[11]_0 ;

  wire [0:0]E;
  wire [1:0]Q;
  wire aclk;
  wire \axaddr_incr[2]_i_4__0_n_0 ;
  wire \axaddr_incr[5]_i_2__0_n_0 ;
  wire \axaddr_incr[9]_i_2__0_n_0 ;
  wire \axaddr_incr_reg[0]_0 ;
  wire [0:0]\axaddr_incr_reg[0]_1 ;
  wire \axaddr_incr_reg[10]_0 ;
  wire [6:0]\axaddr_incr_reg[10]_1 ;
  wire [7:0]\axaddr_incr_reg[11]_0 ;
  wire \axaddr_incr_reg[2]_0 ;
  wire \axaddr_incr_reg[2]_1 ;
  wire \axaddr_incr_reg[4]_0 ;
  wire \axaddr_incr_reg[5]_0 ;
  wire \axaddr_incr_reg[5]_1 ;
  wire \axaddr_incr_reg[6]_0 ;
  wire \axaddr_incr_reg[7]_0 ;
  wire \axaddr_incr_reg[9]_0 ;
  wire \axaddr_incr_reg[9]_1 ;
  wire \axaddr_incr_reg_n_0_[11] ;
  wire \axaddr_incr_reg_n_0_[2] ;
  wire \axaddr_incr_reg_n_0_[4] ;
  wire \axaddr_incr_reg_n_0_[5] ;
  wire \axaddr_incr_reg_n_0_[9] ;
  wire [7:0]axlen_cnt;
  wire \axlen_cnt[0]_i_1_n_0 ;
  wire \axlen_cnt[1]_i_1_n_0 ;
  wire \axlen_cnt[2]_i_1_n_0 ;
  wire \axlen_cnt[3]_i_1_n_0 ;
  wire \axlen_cnt[3]_i_2__0_n_0 ;
  wire \axlen_cnt[4]_i_1_n_0 ;
  wire \axlen_cnt[4]_i_2_n_0 ;
  wire \axlen_cnt[5]_i_1_n_0 ;
  wire \axlen_cnt[5]_i_2_n_0 ;
  wire \axlen_cnt[6]_i_1_n_0 ;
  wire \axlen_cnt[6]_i_2_n_0 ;
  wire \axlen_cnt[7]_i_2_n_0 ;
  wire \axlen_cnt[7]_i_3_n_0 ;
  wire [0:0]\axlen_cnt_reg[0]_0 ;
  wire [23:0]\axlen_cnt_reg[7]_0 ;
  wire incr_next_pending;
  wire [11:0]m_axi_awaddr;
  wire [11:0]\m_axi_awaddr[11] ;
  wire \m_axi_awaddr[11]_0 ;
  wire \m_axi_awaddr[11]_INST_0_i_1_n_0 ;
  wire next_pending_r_i_3_n_0;
  wire next_pending_r_i_5_n_0;
  wire next_pending_r_reg_0;
  wire next_pending_r_reg_1;
  wire next_pending_r_reg_n_0;
  wire [9:2]p_1_in;
  wire s_axburst_eq0;
  wire s_axburst_eq1;
  wire s_axburst_eq1_reg;
  wire sel_first_reg_0;
  wire sel_first_reg_1;
  wire si_rs_awvalid;

  (* SOFT_HLUTNM = "soft_lutpair148" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \axaddr_incr[10]_i_2__0 
       (.I0(\axaddr_incr_reg_n_0_[9] ),
        .I1(\axaddr_incr[9]_i_2__0_n_0 ),
        .O(\axaddr_incr_reg[9]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair148" *) 
  LUT5 #(
    .INIT(32'h00007F80)) 
    \axaddr_incr[11]_i_4__0 
       (.I0(\axaddr_incr_reg[10]_1 [6]),
        .I1(\axaddr_incr[9]_i_2__0_n_0 ),
        .I2(\axaddr_incr_reg_n_0_[9] ),
        .I3(\axaddr_incr_reg_n_0_[11] ),
        .I4(sel_first_reg_0),
        .O(\axaddr_incr_reg[10]_0 ));
  LUT5 #(
    .INIT(32'h66F0660F)) 
    \axaddr_incr[2]_i_1 
       (.I0(\axaddr_incr_reg[2]_0 ),
        .I1(\axaddr_incr_reg[2]_1 ),
        .I2(\axaddr_incr_reg_n_0_[2] ),
        .I3(sel_first_reg_0),
        .I4(\axaddr_incr[2]_i_4__0_n_0 ),
        .O(p_1_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair152" *) 
  LUT4 #(
    .INIT(16'hD1D3)) 
    \axaddr_incr[2]_i_4__0 
       (.I0(\axaddr_incr_reg[10]_1 [1]),
        .I1(\axlen_cnt_reg[7]_0 [13]),
        .I2(\axlen_cnt_reg[7]_0 [12]),
        .I3(\axaddr_incr_reg[10]_1 [0]),
        .O(\axaddr_incr[2]_i_4__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair152" *) 
  LUT5 #(
    .INIT(32'hC1CFFFFF)) 
    \axaddr_incr[3]_i_5__0 
       (.I0(\axaddr_incr_reg[10]_1 [0]),
        .I1(\axlen_cnt_reg[7]_0 [12]),
        .I2(\axlen_cnt_reg[7]_0 [13]),
        .I3(\axaddr_incr_reg[10]_1 [1]),
        .I4(\axaddr_incr_reg_n_0_[2] ),
        .O(\axaddr_incr_reg[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair153" *) 
  LUT4 #(
    .INIT(16'hABBA)) 
    \axaddr_incr[4]_i_1 
       (.I0(\axaddr_incr_reg[4]_0 ),
        .I1(sel_first_reg_0),
        .I2(\axaddr_incr_reg_n_0_[4] ),
        .I3(\axaddr_incr[5]_i_2__0_n_0 ),
        .O(p_1_in[4]));
  LUT6 #(
    .INIT(64'h909F9F909F909F90)) 
    \axaddr_incr[5]_i_1 
       (.I0(\axlen_cnt_reg[7]_0 [5]),
        .I1(\axaddr_incr_reg[5]_1 ),
        .I2(sel_first_reg_0),
        .I3(\axaddr_incr_reg_n_0_[5] ),
        .I4(\axaddr_incr[5]_i_2__0_n_0 ),
        .I5(\axaddr_incr_reg_n_0_[4] ),
        .O(p_1_in[5]));
  LUT6 #(
    .INIT(64'hFEF0C0C000000000)) 
    \axaddr_incr[5]_i_2__0 
       (.I0(\axaddr_incr_reg[10]_1 [0]),
        .I1(\axlen_cnt_reg[7]_0 [12]),
        .I2(\axlen_cnt_reg[7]_0 [13]),
        .I3(\axaddr_incr_reg[10]_1 [1]),
        .I4(\axaddr_incr_reg_n_0_[2] ),
        .I5(\axaddr_incr_reg[10]_1 [2]),
        .O(\axaddr_incr[5]_i_2__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair153" *) 
  LUT3 #(
    .INIT(8'h80)) 
    \axaddr_incr[6]_i_3__0 
       (.I0(\axaddr_incr_reg_n_0_[5] ),
        .I1(\axaddr_incr[5]_i_2__0_n_0 ),
        .I2(\axaddr_incr_reg_n_0_[4] ),
        .O(\axaddr_incr_reg[5]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair149" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \axaddr_incr[7]_i_3__0 
       (.I0(\axaddr_incr_reg[10]_1 [3]),
        .I1(\axaddr_incr_reg_n_0_[4] ),
        .I2(\axaddr_incr[5]_i_2__0_n_0 ),
        .I3(\axaddr_incr_reg_n_0_[5] ),
        .O(\axaddr_incr_reg[6]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair149" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    \axaddr_incr[8]_i_3__0 
       (.I0(\axaddr_incr_reg[10]_1 [4]),
        .I1(\axaddr_incr_reg_n_0_[5] ),
        .I2(\axaddr_incr[5]_i_2__0_n_0 ),
        .I3(\axaddr_incr_reg_n_0_[4] ),
        .I4(\axaddr_incr_reg[10]_1 [3]),
        .O(\axaddr_incr_reg[7]_0 ));
  LUT5 #(
    .INIT(32'h606F6F60)) 
    \axaddr_incr[9]_i_1 
       (.I0(\axlen_cnt_reg[7]_0 [9]),
        .I1(\axaddr_incr_reg[9]_1 ),
        .I2(sel_first_reg_0),
        .I3(\axaddr_incr_reg_n_0_[9] ),
        .I4(\axaddr_incr[9]_i_2__0_n_0 ),
        .O(p_1_in[9]));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \axaddr_incr[9]_i_2__0 
       (.I0(\axaddr_incr_reg[10]_1 [5]),
        .I1(\axaddr_incr_reg[10]_1 [3]),
        .I2(\axaddr_incr_reg_n_0_[4] ),
        .I3(\axaddr_incr[5]_i_2__0_n_0 ),
        .I4(\axaddr_incr_reg_n_0_[5] ),
        .I5(\axaddr_incr_reg[10]_1 [4]),
        .O(\axaddr_incr[9]_i_2__0_n_0 ));
  FDRE \axaddr_incr_reg[0] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(\axaddr_incr_reg[11]_0 [0]),
        .Q(\axaddr_incr_reg[10]_1 [0]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[10] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(\axaddr_incr_reg[11]_0 [6]),
        .Q(\axaddr_incr_reg[10]_1 [6]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[11] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(\axaddr_incr_reg[11]_0 [7]),
        .Q(\axaddr_incr_reg_n_0_[11] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[1] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(\axaddr_incr_reg[11]_0 [1]),
        .Q(\axaddr_incr_reg[10]_1 [1]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[2] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(p_1_in[2]),
        .Q(\axaddr_incr_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[3] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(\axaddr_incr_reg[11]_0 [2]),
        .Q(\axaddr_incr_reg[10]_1 [2]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[4] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(p_1_in[4]),
        .Q(\axaddr_incr_reg_n_0_[4] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[5] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(p_1_in[5]),
        .Q(\axaddr_incr_reg_n_0_[5] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[6] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(\axaddr_incr_reg[11]_0 [3]),
        .Q(\axaddr_incr_reg[10]_1 [3]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[7] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(\axaddr_incr_reg[11]_0 [4]),
        .Q(\axaddr_incr_reg[10]_1 [4]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[8] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(\axaddr_incr_reg[11]_0 [5]),
        .Q(\axaddr_incr_reg[10]_1 [5]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[9] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_1 ),
        .D(p_1_in[9]),
        .Q(\axaddr_incr_reg_n_0_[9] ),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h44444F4444444444)) 
    \axlen_cnt[0]_i_1 
       (.I0(axlen_cnt[0]),
        .I1(next_pending_r_i_3_n_0),
        .I2(Q[1]),
        .I3(si_rs_awvalid),
        .I4(Q[0]),
        .I5(\axlen_cnt_reg[7]_0 [16]),
        .O(\axlen_cnt[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair151" *) 
  LUT5 #(
    .INIT(32'hFF909090)) 
    \axlen_cnt[1]_i_1 
       (.I0(axlen_cnt[1]),
        .I1(axlen_cnt[0]),
        .I2(next_pending_r_i_3_n_0),
        .I3(E),
        .I4(\axlen_cnt_reg[7]_0 [17]),
        .O(\axlen_cnt[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFE100E100E100)) 
    \axlen_cnt[2]_i_1 
       (.I0(axlen_cnt[0]),
        .I1(axlen_cnt[1]),
        .I2(axlen_cnt[2]),
        .I3(next_pending_r_i_3_n_0),
        .I4(E),
        .I5(\axlen_cnt_reg[7]_0 [18]),
        .O(\axlen_cnt[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF888F8F888F88888)) 
    \axlen_cnt[3]_i_1 
       (.I0(\axlen_cnt_reg[7]_0 [19]),
        .I1(E),
        .I2(next_pending_r_i_3_n_0),
        .I3(axlen_cnt[2]),
        .I4(\axlen_cnt[3]_i_2__0_n_0 ),
        .I5(axlen_cnt[3]),
        .O(\axlen_cnt[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair151" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \axlen_cnt[3]_i_2__0 
       (.I0(axlen_cnt[0]),
        .I1(axlen_cnt[1]),
        .O(\axlen_cnt[3]_i_2__0_n_0 ));
  LUT5 #(
    .INIT(32'hFF606060)) 
    \axlen_cnt[4]_i_1 
       (.I0(\axlen_cnt[4]_i_2_n_0 ),
        .I1(axlen_cnt[4]),
        .I2(next_pending_r_i_3_n_0),
        .I3(E),
        .I4(\axlen_cnt_reg[7]_0 [20]),
        .O(\axlen_cnt[4]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h0001)) 
    \axlen_cnt[4]_i_2 
       (.I0(axlen_cnt[3]),
        .I1(axlen_cnt[2]),
        .I2(axlen_cnt[1]),
        .I3(axlen_cnt[0]),
        .O(\axlen_cnt[4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h88F8F888)) 
    \axlen_cnt[5]_i_1 
       (.I0(\axlen_cnt_reg[7]_0 [21]),
        .I1(E),
        .I2(next_pending_r_i_3_n_0),
        .I3(\axlen_cnt[5]_i_2_n_0 ),
        .I4(axlen_cnt[5]),
        .O(\axlen_cnt[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair150" *) 
  LUT5 #(
    .INIT(32'h00000001)) 
    \axlen_cnt[5]_i_2 
       (.I0(axlen_cnt[3]),
        .I1(axlen_cnt[4]),
        .I2(axlen_cnt[1]),
        .I3(axlen_cnt[2]),
        .I4(axlen_cnt[0]),
        .O(\axlen_cnt[5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h88F8F888)) 
    \axlen_cnt[6]_i_1 
       (.I0(\axlen_cnt_reg[7]_0 [22]),
        .I1(E),
        .I2(next_pending_r_i_3_n_0),
        .I3(\axlen_cnt[6]_i_2_n_0 ),
        .I4(axlen_cnt[6]),
        .O(\axlen_cnt[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000001)) 
    \axlen_cnt[6]_i_2 
       (.I0(axlen_cnt[0]),
        .I1(axlen_cnt[2]),
        .I2(axlen_cnt[1]),
        .I3(axlen_cnt[4]),
        .I4(axlen_cnt[3]),
        .I5(axlen_cnt[5]),
        .O(\axlen_cnt[6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h88F8F888)) 
    \axlen_cnt[7]_i_2 
       (.I0(\axlen_cnt_reg[7]_0 [23]),
        .I1(E),
        .I2(next_pending_r_i_3_n_0),
        .I3(axlen_cnt[7]),
        .I4(\axlen_cnt[7]_i_3_n_0 ),
        .O(\axlen_cnt[7]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h10)) 
    \axlen_cnt[7]_i_3 
       (.I0(axlen_cnt[6]),
        .I1(axlen_cnt[5]),
        .I2(\axlen_cnt[5]_i_2_n_0 ),
        .O(\axlen_cnt[7]_i_3_n_0 ));
  FDRE \axlen_cnt_reg[0] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[0]_i_1_n_0 ),
        .Q(axlen_cnt[0]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[1] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[1]_i_1_n_0 ),
        .Q(axlen_cnt[1]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[2] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[2]_i_1_n_0 ),
        .Q(axlen_cnt[2]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[3] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[3]_i_1_n_0 ),
        .Q(axlen_cnt[3]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[4] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[4]_i_1_n_0 ),
        .Q(axlen_cnt[4]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[5] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[5]_i_1_n_0 ),
        .Q(axlen_cnt[5]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[6] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[6]_i_1_n_0 ),
        .Q(axlen_cnt[6]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[7] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[7]_i_2_n_0 ),
        .Q(axlen_cnt[7]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[0]_INST_0 
       (.I0(\axaddr_incr_reg[10]_1 [0]),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [0]),
        .I3(\axlen_cnt_reg[7]_0 [0]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[0]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[10]_INST_0 
       (.I0(\axaddr_incr_reg[10]_1 [6]),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [10]),
        .I3(\axlen_cnt_reg[7]_0 [10]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[10]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[11]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[11] ),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [11]),
        .I3(\axlen_cnt_reg[7]_0 [11]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[11]));
  LUT2 #(
    .INIT(4'hB)) 
    \m_axi_awaddr[11]_INST_0_i_1 
       (.I0(sel_first_reg_0),
        .I1(\axlen_cnt_reg[7]_0 [14]),
        .O(\m_axi_awaddr[11]_INST_0_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[1]_INST_0 
       (.I0(\axaddr_incr_reg[10]_1 [1]),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [1]),
        .I3(\axlen_cnt_reg[7]_0 [1]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[1]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[2]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[2] ),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [2]),
        .I3(\axlen_cnt_reg[7]_0 [2]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[2]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[3]_INST_0 
       (.I0(\axaddr_incr_reg[10]_1 [2]),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [3]),
        .I3(\axlen_cnt_reg[7]_0 [3]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[3]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[4]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[4] ),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [4]),
        .I3(\axlen_cnt_reg[7]_0 [4]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[4]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[5]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[5] ),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [5]),
        .I3(\axlen_cnt_reg[7]_0 [5]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[5]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[6]_INST_0 
       (.I0(\axaddr_incr_reg[10]_1 [3]),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [6]),
        .I3(\axlen_cnt_reg[7]_0 [6]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[6]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[7]_INST_0 
       (.I0(\axaddr_incr_reg[10]_1 [4]),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [7]),
        .I3(\axlen_cnt_reg[7]_0 [7]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[7]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[8]_INST_0 
       (.I0(\axaddr_incr_reg[10]_1 [5]),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [8]),
        .I3(\axlen_cnt_reg[7]_0 [8]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[8]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_awaddr[9]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[9] ),
        .I1(\m_axi_awaddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_awaddr[11] [9]),
        .I3(\axlen_cnt_reg[7]_0 [9]),
        .I4(\m_axi_awaddr[11]_0 ),
        .I5(\axlen_cnt_reg[7]_0 [15]),
        .O(m_axi_awaddr[9]));
  LUT3 #(
    .INIT(8'hB8)) 
    \memory_reg[3][0]_srl4_i_2 
       (.I0(s_axburst_eq1),
        .I1(\axlen_cnt_reg[7]_0 [15]),
        .I2(s_axburst_eq0),
        .O(s_axburst_eq1_reg));
  LUT5 #(
    .INIT(32'hFFB8B0B8)) 
    next_pending_r_i_1
       (.I0(next_pending_r_reg_n_0),
        .I1(next_pending_r_reg_0),
        .I2(next_pending_r_i_3_n_0),
        .I3(E),
        .I4(next_pending_r_reg_1),
        .O(incr_next_pending));
  LUT5 #(
    .INIT(32'h0000FFFD)) 
    next_pending_r_i_3
       (.I0(next_pending_r_i_5_n_0),
        .I1(axlen_cnt[6]),
        .I2(axlen_cnt[5]),
        .I3(axlen_cnt[7]),
        .I4(E),
        .O(next_pending_r_i_3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair150" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    next_pending_r_i_5
       (.I0(axlen_cnt[2]),
        .I1(axlen_cnt[1]),
        .I2(axlen_cnt[4]),
        .I3(axlen_cnt[3]),
        .O(next_pending_r_i_5_n_0));
  FDRE next_pending_r_reg
       (.C(aclk),
        .CE(1'b1),
        .D(incr_next_pending),
        .Q(next_pending_r_reg_n_0),
        .R(1'b0));
  FDRE sel_first_reg
       (.C(aclk),
        .CE(1'b1),
        .D(sel_first_reg_1),
        .Q(sel_first_reg_0),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_incr_cmd" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_incr_cmd_2
   (incr_next_pending,
    sel_first_reg_0,
    \axlen_cnt_reg[7]_0 ,
    Q,
    \axlen_cnt_reg[1]_0 ,
    \axlen_cnt_reg[6]_0 ,
    \axaddr_incr_reg[10]_0 ,
    \axaddr_incr_reg[11]_0 ,
    \axaddr_incr_reg[5]_0 ,
    \m_payload_i_reg[43] ,
    \axlen_cnt_reg[3]_0 ,
    m_axi_araddr,
    aclk,
    sel_first_reg_1,
    next_pending_r_reg_0,
    E,
    next_pending_r_reg_1,
    \axlen_cnt_reg[3]_1 ,
    \axlen_cnt_reg[6]_1 ,
    \axlen_cnt_reg[6]_2 ,
    \axaddr_incr_reg[4]_0 ,
    \axaddr_incr_reg[5]_1 ,
    \axaddr_incr_reg[7]_0 ,
    \axaddr_incr_reg[8]_0 ,
    \axaddr_incr_reg[9]_0 ,
    \axaddr_incr_reg[10]_1 ,
    \axaddr_incr_reg[2]_0 ,
    \axaddr_incr_reg[2]_1 ,
    \m_axi_araddr[11] ,
    \m_axi_araddr[11]_0 ,
    \axlen_cnt_reg[0]_0 ,
    D,
    \axaddr_incr_reg[0]_0 ,
    \axaddr_incr_reg[11]_1 );
  output incr_next_pending;
  output sel_first_reg_0;
  output \axlen_cnt_reg[7]_0 ;
  output [3:0]Q;
  output \axlen_cnt_reg[1]_0 ;
  output \axlen_cnt_reg[6]_0 ;
  output \axaddr_incr_reg[10]_0 ;
  output [4:0]\axaddr_incr_reg[11]_0 ;
  output \axaddr_incr_reg[5]_0 ;
  output \m_payload_i_reg[43] ;
  output \axlen_cnt_reg[3]_0 ;
  output [11:0]m_axi_araddr;
  input aclk;
  input sel_first_reg_1;
  input next_pending_r_reg_0;
  input [0:0]E;
  input next_pending_r_reg_1;
  input \axlen_cnt_reg[3]_1 ;
  input \axlen_cnt_reg[6]_1 ;
  input [18:0]\axlen_cnt_reg[6]_2 ;
  input \axaddr_incr_reg[4]_0 ;
  input \axaddr_incr_reg[5]_1 ;
  input \axaddr_incr_reg[7]_0 ;
  input \axaddr_incr_reg[8]_0 ;
  input \axaddr_incr_reg[9]_0 ;
  input \axaddr_incr_reg[10]_1 ;
  input \axaddr_incr_reg[2]_0 ;
  input \axaddr_incr_reg[2]_1 ;
  input [11:0]\m_axi_araddr[11] ;
  input \m_axi_araddr[11]_0 ;
  input [0:0]\axlen_cnt_reg[0]_0 ;
  input [3:0]D;
  input [0:0]\axaddr_incr_reg[0]_0 ;
  input [4:0]\axaddr_incr_reg[11]_1 ;

  wire [3:0]D;
  wire [0:0]E;
  wire [3:0]Q;
  wire aclk;
  wire \axaddr_incr[10]_i_1__0_n_0 ;
  wire \axaddr_incr[10]_i_2_n_0 ;
  wire \axaddr_incr[2]_i_1__0_n_0 ;
  wire \axaddr_incr[2]_i_4_n_0 ;
  wire \axaddr_incr[4]_i_1__0_n_0 ;
  wire \axaddr_incr[5]_i_1__0_n_0 ;
  wire \axaddr_incr[5]_i_2_n_0 ;
  wire \axaddr_incr[7]_i_1__0_n_0 ;
  wire \axaddr_incr[7]_i_3_n_0 ;
  wire \axaddr_incr[8]_i_1__0_n_0 ;
  wire \axaddr_incr[8]_i_3_n_0 ;
  wire \axaddr_incr[9]_i_1__0_n_0 ;
  wire [0:0]\axaddr_incr_reg[0]_0 ;
  wire \axaddr_incr_reg[10]_0 ;
  wire \axaddr_incr_reg[10]_1 ;
  wire [4:0]\axaddr_incr_reg[11]_0 ;
  wire [4:0]\axaddr_incr_reg[11]_1 ;
  wire \axaddr_incr_reg[2]_0 ;
  wire \axaddr_incr_reg[2]_1 ;
  wire \axaddr_incr_reg[4]_0 ;
  wire \axaddr_incr_reg[5]_0 ;
  wire \axaddr_incr_reg[5]_1 ;
  wire \axaddr_incr_reg[7]_0 ;
  wire \axaddr_incr_reg[8]_0 ;
  wire \axaddr_incr_reg[9]_0 ;
  wire \axaddr_incr_reg_n_0_[10] ;
  wire \axaddr_incr_reg_n_0_[2] ;
  wire \axaddr_incr_reg_n_0_[4] ;
  wire \axaddr_incr_reg_n_0_[5] ;
  wire \axaddr_incr_reg_n_0_[7] ;
  wire \axaddr_incr_reg_n_0_[8] ;
  wire \axaddr_incr_reg_n_0_[9] ;
  wire \axlen_cnt[1]_i_1__1_n_0 ;
  wire \axlen_cnt[2]_i_1__2_n_0 ;
  wire \axlen_cnt[3]_i_1__2_n_0 ;
  wire \axlen_cnt[6]_i_1__0_n_0 ;
  wire [0:0]\axlen_cnt_reg[0]_0 ;
  wire \axlen_cnt_reg[1]_0 ;
  wire \axlen_cnt_reg[3]_0 ;
  wire \axlen_cnt_reg[3]_1 ;
  wire \axlen_cnt_reg[6]_0 ;
  wire \axlen_cnt_reg[6]_1 ;
  wire [18:0]\axlen_cnt_reg[6]_2 ;
  wire \axlen_cnt_reg[7]_0 ;
  wire \axlen_cnt_reg_n_0_[1] ;
  wire \axlen_cnt_reg_n_0_[2] ;
  wire \axlen_cnt_reg_n_0_[3] ;
  wire \axlen_cnt_reg_n_0_[6] ;
  wire incr_next_pending;
  wire [11:0]m_axi_araddr;
  wire [11:0]\m_axi_araddr[11] ;
  wire \m_axi_araddr[11]_0 ;
  wire \m_axi_araddr[11]_INST_0_i_1_n_0 ;
  wire \m_payload_i_reg[43] ;
  wire next_pending_r_i_5__0_n_0;
  wire next_pending_r_reg_0;
  wire next_pending_r_reg_1;
  wire next_pending_r_reg_n_0;
  wire sel_first_reg_0;
  wire sel_first_reg_1;

  LUT6 #(
    .INIT(64'h606F6F606F606F60)) 
    \axaddr_incr[10]_i_1__0 
       (.I0(\axlen_cnt_reg[6]_2 [10]),
        .I1(\axaddr_incr_reg[10]_1 ),
        .I2(sel_first_reg_0),
        .I3(\axaddr_incr_reg_n_0_[10] ),
        .I4(\axaddr_incr[10]_i_2_n_0 ),
        .I5(\axaddr_incr_reg_n_0_[9] ),
        .O(\axaddr_incr[10]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \axaddr_incr[10]_i_2 
       (.I0(\axaddr_incr_reg_n_0_[8] ),
        .I1(\axaddr_incr_reg[11]_0 [3]),
        .I2(\axaddr_incr_reg_n_0_[4] ),
        .I3(\axaddr_incr[5]_i_2_n_0 ),
        .I4(\axaddr_incr_reg_n_0_[5] ),
        .I5(\axaddr_incr_reg_n_0_[7] ),
        .O(\axaddr_incr[10]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h80)) 
    \axaddr_incr[11]_i_4 
       (.I0(\axaddr_incr_reg_n_0_[10] ),
        .I1(\axaddr_incr[10]_i_2_n_0 ),
        .I2(\axaddr_incr_reg_n_0_[9] ),
        .O(\axaddr_incr_reg[10]_0 ));
  LUT5 #(
    .INIT(32'h66F0660F)) 
    \axaddr_incr[2]_i_1__0 
       (.I0(\axaddr_incr_reg[2]_0 ),
        .I1(\axaddr_incr_reg[2]_1 ),
        .I2(\axaddr_incr_reg_n_0_[2] ),
        .I3(sel_first_reg_0),
        .I4(\axaddr_incr[2]_i_4_n_0 ),
        .O(\axaddr_incr[2]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'hF307)) 
    \axaddr_incr[2]_i_4 
       (.I0(\axaddr_incr_reg[11]_0 [0]),
        .I1(\axaddr_incr_reg[11]_0 [1]),
        .I2(\axlen_cnt_reg[6]_2 [13]),
        .I3(\axlen_cnt_reg[6]_2 [12]),
        .O(\axaddr_incr[2]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT5 #(
    .INIT(32'h8B9BFFFF)) 
    \axaddr_incr[3]_i_5 
       (.I0(\axlen_cnt_reg[6]_2 [12]),
        .I1(\axlen_cnt_reg[6]_2 [13]),
        .I2(\axaddr_incr_reg[11]_0 [1]),
        .I3(\axaddr_incr_reg[11]_0 [0]),
        .I4(\axaddr_incr_reg_n_0_[2] ),
        .O(\m_payload_i_reg[43] ));
  LUT5 #(
    .INIT(32'h909F9F90)) 
    \axaddr_incr[4]_i_1__0 
       (.I0(\axlen_cnt_reg[6]_2 [4]),
        .I1(\axaddr_incr_reg[4]_0 ),
        .I2(sel_first_reg_0),
        .I3(\axaddr_incr_reg_n_0_[4] ),
        .I4(\axaddr_incr[5]_i_2_n_0 ),
        .O(\axaddr_incr[4]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'h909F9F909F909F90)) 
    \axaddr_incr[5]_i_1__0 
       (.I0(\axlen_cnt_reg[6]_2 [5]),
        .I1(\axaddr_incr_reg[5]_1 ),
        .I2(sel_first_reg_0),
        .I3(\axaddr_incr_reg_n_0_[5] ),
        .I4(\axaddr_incr[5]_i_2_n_0 ),
        .I5(\axaddr_incr_reg_n_0_[4] ),
        .O(\axaddr_incr[5]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'hFCEC888800000000)) 
    \axaddr_incr[5]_i_2 
       (.I0(\axlen_cnt_reg[6]_2 [12]),
        .I1(\axlen_cnt_reg[6]_2 [13]),
        .I2(\axaddr_incr_reg[11]_0 [1]),
        .I3(\axaddr_incr_reg[11]_0 [0]),
        .I4(\axaddr_incr_reg_n_0_[2] ),
        .I5(\axaddr_incr_reg[11]_0 [2]),
        .O(\axaddr_incr[5]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h80)) 
    \axaddr_incr[6]_i_3 
       (.I0(\axaddr_incr_reg_n_0_[5] ),
        .I1(\axaddr_incr[5]_i_2_n_0 ),
        .I2(\axaddr_incr_reg_n_0_[4] ),
        .O(\axaddr_incr_reg[5]_0 ));
  LUT5 #(
    .INIT(32'h909F9F90)) 
    \axaddr_incr[7]_i_1__0 
       (.I0(\axlen_cnt_reg[6]_2 [7]),
        .I1(\axaddr_incr_reg[7]_0 ),
        .I2(sel_first_reg_0),
        .I3(\axaddr_incr_reg_n_0_[7] ),
        .I4(\axaddr_incr[7]_i_3_n_0 ),
        .O(\axaddr_incr[7]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \axaddr_incr[7]_i_3 
       (.I0(\axaddr_incr_reg[11]_0 [3]),
        .I1(\axaddr_incr_reg_n_0_[4] ),
        .I2(\axaddr_incr[5]_i_2_n_0 ),
        .I3(\axaddr_incr_reg_n_0_[5] ),
        .O(\axaddr_incr[7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h909F9F90)) 
    \axaddr_incr[8]_i_1__0 
       (.I0(\axlen_cnt_reg[6]_2 [8]),
        .I1(\axaddr_incr_reg[8]_0 ),
        .I2(sel_first_reg_0),
        .I3(\axaddr_incr_reg_n_0_[8] ),
        .I4(\axaddr_incr[8]_i_3_n_0 ),
        .O(\axaddr_incr[8]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    \axaddr_incr[8]_i_3 
       (.I0(\axaddr_incr_reg_n_0_[7] ),
        .I1(\axaddr_incr_reg_n_0_[5] ),
        .I2(\axaddr_incr[5]_i_2_n_0 ),
        .I3(\axaddr_incr_reg_n_0_[4] ),
        .I4(\axaddr_incr_reg[11]_0 [3]),
        .O(\axaddr_incr[8]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h909F9F90)) 
    \axaddr_incr[9]_i_1__0 
       (.I0(\axlen_cnt_reg[6]_2 [9]),
        .I1(\axaddr_incr_reg[9]_0 ),
        .I2(sel_first_reg_0),
        .I3(\axaddr_incr_reg_n_0_[9] ),
        .I4(\axaddr_incr[10]_i_2_n_0 ),
        .O(\axaddr_incr[9]_i_1__0_n_0 ));
  FDRE \axaddr_incr_reg[0] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr_reg[11]_1 [0]),
        .Q(\axaddr_incr_reg[11]_0 [0]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[10] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr[10]_i_1__0_n_0 ),
        .Q(\axaddr_incr_reg_n_0_[10] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[11] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr_reg[11]_1 [4]),
        .Q(\axaddr_incr_reg[11]_0 [4]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[1] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr_reg[11]_1 [1]),
        .Q(\axaddr_incr_reg[11]_0 [1]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[2] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr[2]_i_1__0_n_0 ),
        .Q(\axaddr_incr_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[3] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr_reg[11]_1 [2]),
        .Q(\axaddr_incr_reg[11]_0 [2]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[4] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr[4]_i_1__0_n_0 ),
        .Q(\axaddr_incr_reg_n_0_[4] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[5] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr[5]_i_1__0_n_0 ),
        .Q(\axaddr_incr_reg_n_0_[5] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[6] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr_reg[11]_1 [3]),
        .Q(\axaddr_incr_reg[11]_0 [3]),
        .R(1'b0));
  FDRE \axaddr_incr_reg[7] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr[7]_i_1__0_n_0 ),
        .Q(\axaddr_incr_reg_n_0_[7] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[8] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr[8]_i_1__0_n_0 ),
        .Q(\axaddr_incr_reg_n_0_[8] ),
        .R(1'b0));
  FDRE \axaddr_incr_reg[9] 
       (.C(aclk),
        .CE(\axaddr_incr_reg[0]_0 ),
        .D(\axaddr_incr[9]_i_1__0_n_0 ),
        .Q(\axaddr_incr_reg_n_0_[9] ),
        .R(1'b0));
  LUT5 #(
    .INIT(32'hAAAA3003)) 
    \axlen_cnt[1]_i_1__1 
       (.I0(\axlen_cnt_reg[6]_2 [16]),
        .I1(\axlen_cnt_reg[7]_0 ),
        .I2(\axlen_cnt_reg_n_0_[1] ),
        .I3(Q[0]),
        .I4(E),
        .O(\axlen_cnt[1]_i_1__1_n_0 ));
  LUT6 #(
    .INIT(64'hF8F8F888888888F8)) 
    \axlen_cnt[2]_i_1__2 
       (.I0(\axlen_cnt_reg[6]_2 [17]),
        .I1(E),
        .I2(\axlen_cnt_reg[6]_1 ),
        .I3(\axlen_cnt_reg_n_0_[1] ),
        .I4(Q[0]),
        .I5(\axlen_cnt_reg_n_0_[2] ),
        .O(\axlen_cnt[2]_i_1__2_n_0 ));
  LUT6 #(
    .INIT(64'hEEEEEEEBAAAAAAAA)) 
    \axlen_cnt[3]_i_1__2 
       (.I0(\axlen_cnt_reg[3]_1 ),
        .I1(\axlen_cnt_reg_n_0_[3] ),
        .I2(\axlen_cnt_reg_n_0_[2] ),
        .I3(Q[0]),
        .I4(\axlen_cnt_reg_n_0_[1] ),
        .I5(\axlen_cnt_reg[6]_1 ),
        .O(\axlen_cnt[3]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    \axlen_cnt[4]_i_2__0 
       (.I0(\axlen_cnt_reg_n_0_[3] ),
        .I1(\axlen_cnt_reg_n_0_[2] ),
        .I2(Q[0]),
        .I3(\axlen_cnt_reg_n_0_[1] ),
        .O(\axlen_cnt_reg[3]_0 ));
  LUT6 #(
    .INIT(64'hFFF88888888F8888)) 
    \axlen_cnt[6]_i_1__0 
       (.I0(\axlen_cnt_reg[6]_2 [18]),
        .I1(E),
        .I2(Q[2]),
        .I3(\axlen_cnt_reg[1]_0 ),
        .I4(\axlen_cnt_reg[6]_1 ),
        .I5(\axlen_cnt_reg_n_0_[6] ),
        .O(\axlen_cnt[6]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \axlen_cnt[6]_i_2__0 
       (.I0(\axlen_cnt_reg_n_0_[1] ),
        .I1(Q[0]),
        .I2(\axlen_cnt_reg_n_0_[2] ),
        .I3(\axlen_cnt_reg_n_0_[3] ),
        .I4(Q[1]),
        .O(\axlen_cnt_reg[1]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h01)) 
    \axlen_cnt[7]_i_3__0 
       (.I0(\axlen_cnt_reg_n_0_[6] ),
        .I1(Q[2]),
        .I2(\axlen_cnt_reg[1]_0 ),
        .O(\axlen_cnt_reg[6]_0 ));
  FDRE \axlen_cnt_reg[0] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(D[0]),
        .Q(Q[0]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[1] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[1]_i_1__1_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[1] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[2] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[2]_i_1__2_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[3] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[3]_i_1__2_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[3] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[4] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(D[1]),
        .Q(Q[1]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[5] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(D[2]),
        .Q(Q[2]),
        .R(1'b0));
  FDRE \axlen_cnt_reg[6] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(\axlen_cnt[6]_i_1__0_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[6] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[7] 
       (.C(aclk),
        .CE(\axlen_cnt_reg[0]_0 ),
        .D(D[3]),
        .Q(Q[3]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[0]_INST_0 
       (.I0(\axaddr_incr_reg[11]_0 [0]),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [0]),
        .I3(\axlen_cnt_reg[6]_2 [0]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[0]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[10]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[10] ),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [10]),
        .I3(\axlen_cnt_reg[6]_2 [10]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[10]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[11]_INST_0 
       (.I0(\axaddr_incr_reg[11]_0 [4]),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [11]),
        .I3(\axlen_cnt_reg[6]_2 [11]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[11]));
  LUT2 #(
    .INIT(4'hB)) 
    \m_axi_araddr[11]_INST_0_i_1 
       (.I0(sel_first_reg_0),
        .I1(\axlen_cnt_reg[6]_2 [14]),
        .O(\m_axi_araddr[11]_INST_0_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[1]_INST_0 
       (.I0(\axaddr_incr_reg[11]_0 [1]),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [1]),
        .I3(\axlen_cnt_reg[6]_2 [1]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[1]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[2]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[2] ),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [2]),
        .I3(\axlen_cnt_reg[6]_2 [2]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[2]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[3]_INST_0 
       (.I0(\axaddr_incr_reg[11]_0 [2]),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [3]),
        .I3(\axlen_cnt_reg[6]_2 [3]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[3]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[4]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[4] ),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [4]),
        .I3(\axlen_cnt_reg[6]_2 [4]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[4]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[5]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[5] ),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [5]),
        .I3(\axlen_cnt_reg[6]_2 [5]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[5]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[6]_INST_0 
       (.I0(\axaddr_incr_reg[11]_0 [3]),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [6]),
        .I3(\axlen_cnt_reg[6]_2 [6]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[6]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[7]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[7] ),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [7]),
        .I3(\axlen_cnt_reg[6]_2 [7]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[7]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[8]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[8] ),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [8]),
        .I3(\axlen_cnt_reg[6]_2 [8]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[8]));
  LUT6 #(
    .INIT(64'hFF00F0F0EE22EE22)) 
    \m_axi_araddr[9]_INST_0 
       (.I0(\axaddr_incr_reg_n_0_[9] ),
        .I1(\m_axi_araddr[11]_INST_0_i_1_n_0 ),
        .I2(\m_axi_araddr[11] [9]),
        .I3(\axlen_cnt_reg[6]_2 [9]),
        .I4(\m_axi_araddr[11]_0 ),
        .I5(\axlen_cnt_reg[6]_2 [15]),
        .O(m_axi_araddr[9]));
  LUT5 #(
    .INIT(32'h3F753075)) 
    next_pending_r_i_1__1
       (.I0(\axlen_cnt_reg[7]_0 ),
        .I1(next_pending_r_reg_0),
        .I2(E),
        .I3(next_pending_r_reg_1),
        .I4(next_pending_r_reg_n_0),
        .O(incr_next_pending));
  LUT6 #(
    .INIT(64'h0000000000000002)) 
    next_pending_r_i_2__2
       (.I0(next_pending_r_i_5__0_n_0),
        .I1(Q[3]),
        .I2(\axlen_cnt_reg_n_0_[3] ),
        .I3(Q[1]),
        .I4(\axlen_cnt_reg_n_0_[1] ),
        .I5(\axlen_cnt_reg_n_0_[2] ),
        .O(\axlen_cnt_reg[7]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT2 #(
    .INIT(4'h1)) 
    next_pending_r_i_5__0
       (.I0(Q[2]),
        .I1(\axlen_cnt_reg_n_0_[6] ),
        .O(next_pending_r_i_5__0_n_0));
  FDRE next_pending_r_reg
       (.C(aclk),
        .CE(1'b1),
        .D(incr_next_pending),
        .Q(next_pending_r_reg_n_0),
        .R(1'b0));
  FDRE sel_first_reg
       (.C(aclk),
        .CE(1'b1),
        .D(sel_first_reg_1),
        .Q(sel_first_reg_0),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_r_channel" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_r_channel
   (\cnt_read_reg[0] ,
    m_axi_rready,
    \cnt_read_reg[3] ,
    out,
    r_push_r_reg_0,
    r_push,
    aclk,
    r_rlast,
    \cnt_read_reg[4] ,
    m_axi_rvalid,
    in,
    D,
    areset_d1);
  output \cnt_read_reg[0] ;
  output m_axi_rready;
  output \cnt_read_reg[3] ;
  output [33:0]out;
  output [16:0]r_push_r_reg_0;
  input r_push;
  input aclk;
  input r_rlast;
  input \cnt_read_reg[4] ;
  input m_axi_rvalid;
  input [33:0]in;
  input [15:0]D;
  input areset_d1;

  wire [15:0]D;
  wire aclk;
  wire areset_d1;
  wire \cnt_read_reg[0] ;
  wire \cnt_read_reg[3] ;
  wire \cnt_read_reg[4] ;
  wire [33:0]in;
  wire m_axi_rready;
  wire m_axi_rvalid;
  wire [33:0]out;
  wire r_push;
  wire r_push_r;
  wire [16:0]r_push_r_reg_0;
  wire r_rlast;
  wire rd_data_fifo_0_n_1;
  wire [16:0]trans_in;
  wire transaction_fifo_0_n_1;

  FDRE \r_arid_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[0]),
        .Q(trans_in[1]),
        .R(1'b0));
  FDRE \r_arid_r_reg[10] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[10]),
        .Q(trans_in[11]),
        .R(1'b0));
  FDRE \r_arid_r_reg[11] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[11]),
        .Q(trans_in[12]),
        .R(1'b0));
  FDRE \r_arid_r_reg[12] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[12]),
        .Q(trans_in[13]),
        .R(1'b0));
  FDRE \r_arid_r_reg[13] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[13]),
        .Q(trans_in[14]),
        .R(1'b0));
  FDRE \r_arid_r_reg[14] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[14]),
        .Q(trans_in[15]),
        .R(1'b0));
  FDRE \r_arid_r_reg[15] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[15]),
        .Q(trans_in[16]),
        .R(1'b0));
  FDRE \r_arid_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[1]),
        .Q(trans_in[2]),
        .R(1'b0));
  FDRE \r_arid_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[2]),
        .Q(trans_in[3]),
        .R(1'b0));
  FDRE \r_arid_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[3]),
        .Q(trans_in[4]),
        .R(1'b0));
  FDRE \r_arid_r_reg[4] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[4]),
        .Q(trans_in[5]),
        .R(1'b0));
  FDRE \r_arid_r_reg[5] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[5]),
        .Q(trans_in[6]),
        .R(1'b0));
  FDRE \r_arid_r_reg[6] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[6]),
        .Q(trans_in[7]),
        .R(1'b0));
  FDRE \r_arid_r_reg[7] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[7]),
        .Q(trans_in[8]),
        .R(1'b0));
  FDRE \r_arid_r_reg[8] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[8]),
        .Q(trans_in[9]),
        .R(1'b0));
  FDRE \r_arid_r_reg[9] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[9]),
        .Q(trans_in[10]),
        .R(1'b0));
  FDRE r_push_r_reg
       (.C(aclk),
        .CE(1'b1),
        .D(r_push),
        .Q(r_push_r),
        .R(1'b0));
  FDRE r_rlast_r_reg
       (.C(aclk),
        .CE(1'b1),
        .D(r_rlast),
        .Q(trans_in[0]),
        .R(1'b0));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_simple_fifo__parameterized1 rd_data_fifo_0
       (.aclk(aclk),
        .areset_d1(areset_d1),
        .\cnt_read_reg[0]_0 (rd_data_fifo_0_n_1),
        .\cnt_read_reg[3]_0 (\cnt_read_reg[3] ),
        .\cnt_read_reg[4]_0 (\cnt_read_reg[4] ),
        .in(in),
        .m_axi_rready(m_axi_rready),
        .m_axi_rvalid(m_axi_rvalid),
        .m_valid_i_reg(transaction_fifo_0_n_1),
        .out(out));
  zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_simple_fifo__parameterized2 transaction_fifo_0
       (.\FSM_sequential_state_reg[1] (rd_data_fifo_0_n_1),
        .aclk(aclk),
        .areset_d1(areset_d1),
        .\cnt_read_reg[0]_0 (\cnt_read_reg[0] ),
        .\cnt_read_reg[4]_0 (transaction_fifo_0_n_1),
        .\cnt_read_reg[4]_1 (\cnt_read_reg[4] ),
        .in(trans_in),
        .r_push_r(r_push_r),
        .r_push_r_reg(r_push_r_reg_0));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_rd_cmd_fsm" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_rd_cmd_fsm
   (E,
    Q,
    sel_first_reg,
    sel_first_reg_0,
    sel_first_i,
    D,
    wrap_second_len,
    \FSM_sequential_state_reg[1]_0 ,
    axaddr_offset,
    \m_payload_i_reg[59] ,
    m_valid_i_reg,
    sel_first_reg_1,
    r_push,
    m_axi_arready_0,
    m_axi_arvalid,
    m_valid_i_reg_0,
    si_rs_arvalid,
    m_axi_arready,
    sel_first_reg_2,
    areset_d1,
    \axaddr_incr_reg[0] ,
    sel_first_reg_3,
    \wrap_second_len_r_reg[3] ,
    \wrap_second_len_r_reg[3]_0 ,
    \wrap_second_len_r_reg[3]_1 ,
    \axaddr_offset_r_reg[3] ,
    \axaddr_offset_r_reg[2] ,
    \axaddr_offset_r_reg[1] ,
    \axlen_cnt_reg[7] ,
    \axlen_cnt_reg[4] ,
    \axlen_cnt_reg[7]_0 ,
    \axlen_cnt_reg[5] ,
    \axlen_cnt_reg[7]_1 ,
    \axlen_cnt_reg[4]_0 ,
    \FSM_sequential_state_reg[1]_1 ,
    \FSM_sequential_state_reg[0]_0 ,
    \FSM_sequential_state_reg[1]_2 ,
    aclk);
  output [0:0]E;
  output [1:0]Q;
  output sel_first_reg;
  output sel_first_reg_0;
  output sel_first_i;
  output [3:0]D;
  output [3:0]wrap_second_len;
  output [0:0]\FSM_sequential_state_reg[1]_0 ;
  output [2:0]axaddr_offset;
  output [3:0]\m_payload_i_reg[59] ;
  output m_valid_i_reg;
  output [0:0]sel_first_reg_1;
  output r_push;
  output m_axi_arready_0;
  output m_axi_arvalid;
  output [0:0]m_valid_i_reg_0;
  input si_rs_arvalid;
  input m_axi_arready;
  input sel_first_reg_2;
  input areset_d1;
  input \axaddr_incr_reg[0] ;
  input sel_first_reg_3;
  input [3:0]\wrap_second_len_r_reg[3] ;
  input \wrap_second_len_r_reg[3]_0 ;
  input \wrap_second_len_r_reg[3]_1 ;
  input [2:0]\axaddr_offset_r_reg[3] ;
  input \axaddr_offset_r_reg[2] ;
  input \axaddr_offset_r_reg[1] ;
  input [3:0]\axlen_cnt_reg[7] ;
  input \axlen_cnt_reg[4] ;
  input [3:0]\axlen_cnt_reg[7]_0 ;
  input \axlen_cnt_reg[5] ;
  input \axlen_cnt_reg[7]_1 ;
  input \axlen_cnt_reg[4]_0 ;
  input \FSM_sequential_state_reg[1]_1 ;
  input \FSM_sequential_state_reg[0]_0 ;
  input \FSM_sequential_state_reg[1]_2 ;
  input aclk;

  wire [3:0]D;
  wire [0:0]E;
  wire \FSM_sequential_state_reg[0]_0 ;
  wire [0:0]\FSM_sequential_state_reg[1]_0 ;
  wire \FSM_sequential_state_reg[1]_1 ;
  wire \FSM_sequential_state_reg[1]_2 ;
  wire [1:0]Q;
  wire aclk;
  wire areset_d1;
  wire \axaddr_incr_reg[0] ;
  wire [2:0]axaddr_offset;
  wire \axaddr_offset_r_reg[1] ;
  wire \axaddr_offset_r_reg[2] ;
  wire [2:0]\axaddr_offset_r_reg[3] ;
  wire \axlen_cnt_reg[4] ;
  wire \axlen_cnt_reg[4]_0 ;
  wire \axlen_cnt_reg[5] ;
  wire [3:0]\axlen_cnt_reg[7] ;
  wire [3:0]\axlen_cnt_reg[7]_0 ;
  wire \axlen_cnt_reg[7]_1 ;
  wire m_axi_arready;
  wire m_axi_arready_0;
  wire m_axi_arvalid;
  wire [3:0]\m_payload_i_reg[59] ;
  wire m_valid_i_reg;
  wire [0:0]m_valid_i_reg_0;
  wire [1:0]next_state__0;
  wire r_push;
  wire sel_first_i;
  wire sel_first_reg;
  wire sel_first_reg_0;
  wire [0:0]sel_first_reg_1;
  wire sel_first_reg_2;
  wire sel_first_reg_3;
  wire si_rs_arvalid;
  wire \wrap_cnt_r[0]_i_2__0_n_0 ;
  wire \wrap_cnt_r[3]_i_2__0_n_0 ;
  wire [3:0]wrap_second_len;
  wire [3:0]\wrap_second_len_r_reg[3] ;
  wire \wrap_second_len_r_reg[3]_0 ;
  wire \wrap_second_len_r_reg[3]_1 ;

  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h2FAF2FFF)) 
    \FSM_sequential_state[0]_i_1 
       (.I0(\FSM_sequential_state_reg[1]_1 ),
        .I1(Q[0]),
        .I2(Q[1]),
        .I3(\FSM_sequential_state_reg[0]_0 ),
        .I4(m_axi_arready),
        .O(next_state__0[0]));
  LUT5 #(
    .INIT(32'h5F5FC000)) 
    \FSM_sequential_state[1]_i_1 
       (.I0(\FSM_sequential_state_reg[1]_2 ),
        .I1(\FSM_sequential_state_reg[1]_1 ),
        .I2(Q[0]),
        .I3(si_rs_arvalid),
        .I4(Q[1]),
        .O(next_state__0[1]));
  (* FSM_ENCODED_STATES = "SM_IDLE:01,SM_DONE:00,SM_CMD_ACCEPTED:10,SM_CMD_EN:11" *) 
  FDSE #(
    .INIT(1'b1)) 
    \FSM_sequential_state_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(next_state__0[0]),
        .Q(Q[0]),
        .S(areset_d1));
  (* FSM_ENCODED_STATES = "SM_IDLE:01,SM_DONE:00,SM_CMD_ACCEPTED:10,SM_CMD_EN:11" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential_state_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(next_state__0[1]),
        .Q(Q[1]),
        .R(areset_d1));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hEAAA)) 
    \axaddr_incr[11]_i_1__0 
       (.I0(\axaddr_incr_reg[0] ),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(m_axi_arready),
        .O(sel_first_reg_1));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hBAAA0000)) 
    \axaddr_offset_r[1]_i_1__0 
       (.I0(\axaddr_offset_r_reg[3] [0]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(si_rs_arvalid),
        .I4(\axaddr_offset_r_reg[1] ),
        .O(axaddr_offset[0]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hBAAA0000)) 
    \axaddr_offset_r[2]_i_1__0 
       (.I0(\axaddr_offset_r_reg[3] [1]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(si_rs_arvalid),
        .I4(\axaddr_offset_r_reg[2] ),
        .O(axaddr_offset[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'hEFFFAAAA)) 
    \axaddr_offset_r[3]_i_1__0 
       (.I0(\wrap_second_len_r_reg[3]_1 ),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(si_rs_arvalid),
        .I4(\axaddr_offset_r_reg[3] [2]),
        .O(axaddr_offset[2]));
  LUT5 #(
    .INIT(32'h4F444444)) 
    \axlen_cnt[0]_i_1__2 
       (.I0(\axlen_cnt_reg[7]_0 [0]),
        .I1(m_valid_i_reg),
        .I2(Q[1]),
        .I3(si_rs_arvalid),
        .I4(\axlen_cnt_reg[7] [0]),
        .O(\m_payload_i_reg[59] [0]));
  LUT5 #(
    .INIT(32'hF8888F88)) 
    \axlen_cnt[4]_i_1__0 
       (.I0(\axlen_cnt_reg[7] [1]),
        .I1(\FSM_sequential_state_reg[1]_0 ),
        .I2(\axlen_cnt_reg[4] ),
        .I3(m_valid_i_reg),
        .I4(\axlen_cnt_reg[7]_0 [1]),
        .O(\m_payload_i_reg[59] [1]));
  LUT5 #(
    .INIT(32'hF8888F88)) 
    \axlen_cnt[5]_i_1__0 
       (.I0(\axlen_cnt_reg[7] [2]),
        .I1(\FSM_sequential_state_reg[1]_0 ),
        .I2(\axlen_cnt_reg[5] ),
        .I3(m_valid_i_reg),
        .I4(\axlen_cnt_reg[7]_0 [2]),
        .O(\m_payload_i_reg[59] [2]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'hE020)) 
    \axlen_cnt[7]_i_1__0 
       (.I0(si_rs_arvalid),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(m_axi_arready),
        .O(E));
  LUT5 #(
    .INIT(32'h8F88F888)) 
    \axlen_cnt[7]_i_2__0 
       (.I0(\axlen_cnt_reg[7] [3]),
        .I1(\FSM_sequential_state_reg[1]_0 ),
        .I2(\axlen_cnt_reg[7]_1 ),
        .I3(m_valid_i_reg),
        .I4(\axlen_cnt_reg[7]_0 [3]),
        .O(\m_payload_i_reg[59] [3]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h5515)) 
    \axlen_cnt[7]_i_4 
       (.I0(\axlen_cnt_reg[4]_0 ),
        .I1(si_rs_arvalid),
        .I2(Q[0]),
        .I3(Q[1]),
        .O(m_valid_i_reg));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    m_axi_arvalid_INST_0
       (.I0(Q[1]),
        .I1(Q[0]),
        .O(m_axi_arvalid));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h57)) 
    \m_payload_i[39]_i_1__0 
       (.I0(si_rs_arvalid),
        .I1(Q[0]),
        .I2(Q[1]),
        .O(m_valid_i_reg_0));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'h7F)) 
    next_pending_r_i_4__0
       (.I0(m_axi_arready),
        .I1(Q[0]),
        .I2(Q[1]),
        .O(m_axi_arready_0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h80)) 
    r_push_r_i_1
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(m_axi_arready),
        .O(r_push));
  LUT6 #(
    .INIT(64'hFFFFFFFF2FAA2AAA)) 
    sel_first_i_1__2
       (.I0(sel_first_reg_2),
        .I1(m_axi_arready),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(si_rs_arvalid),
        .I5(areset_d1),
        .O(sel_first_reg));
  LUT6 #(
    .INIT(64'hFFFFFFFF2FAA2AAA)) 
    sel_first_i_1__3
       (.I0(\axaddr_incr_reg[0] ),
        .I1(m_axi_arready),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(si_rs_arvalid),
        .I5(areset_d1),
        .O(sel_first_reg_0));
  LUT6 #(
    .INIT(64'hFFFFFFFF4FCC4CCC)) 
    sel_first_i_1__4
       (.I0(m_axi_arready),
        .I1(sel_first_reg_3),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(si_rs_arvalid),
        .I5(areset_d1),
        .O(sel_first_i));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \wrap_boundary_axaddr_r[11]_i_1__0 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(si_rs_arvalid),
        .O(\FSM_sequential_state_reg[1]_0 ));
  LUT6 #(
    .INIT(64'h9999099999995999)) 
    \wrap_cnt_r[0]_i_1__0 
       (.I0(\wrap_cnt_r[0]_i_2__0_n_0 ),
        .I1(\wrap_second_len_r_reg[3] [0]),
        .I2(si_rs_arvalid),
        .I3(Q[0]),
        .I4(Q[1]),
        .I5(\wrap_second_len_r_reg[3]_0 ),
        .O(D[0]));
  LUT6 #(
    .INIT(64'h0000000000004500)) 
    \wrap_cnt_r[0]_i_2__0 
       (.I0(\wrap_second_len_r_reg[3]_1 ),
        .I1(\FSM_sequential_state_reg[1]_0 ),
        .I2(\axaddr_offset_r_reg[3] [2]),
        .I3(\wrap_second_len_r_reg[3]_0 ),
        .I4(axaddr_offset[0]),
        .I5(axaddr_offset[1]),
        .O(\wrap_cnt_r[0]_i_2__0_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \wrap_cnt_r[1]_i_1__0 
       (.I0(wrap_second_len[1]),
        .I1(\wrap_cnt_r[3]_i_2__0_n_0 ),
        .O(D[1]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \wrap_cnt_r[2]_i_1__0 
       (.I0(wrap_second_len[2]),
        .I1(\wrap_cnt_r[3]_i_2__0_n_0 ),
        .I2(wrap_second_len[1]),
        .O(D[2]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h6AAA)) 
    \wrap_cnt_r[3]_i_1__0 
       (.I0(wrap_second_len[3]),
        .I1(wrap_second_len[1]),
        .I2(\wrap_cnt_r[3]_i_2__0_n_0 ),
        .I3(wrap_second_len[2]),
        .O(D[3]));
  LUT6 #(
    .INIT(64'hEEEE2222EEE02222)) 
    \wrap_cnt_r[3]_i_2__0 
       (.I0(\wrap_second_len_r_reg[3] [0]),
        .I1(\FSM_sequential_state_reg[1]_0 ),
        .I2(axaddr_offset[1]),
        .I3(axaddr_offset[0]),
        .I4(\wrap_second_len_r_reg[3]_0 ),
        .I5(axaddr_offset[2]),
        .O(\wrap_cnt_r[3]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'hAAA8FFFFAAA80000)) 
    \wrap_second_len_r[0]_i_1__0 
       (.I0(\wrap_second_len_r_reg[3]_0 ),
        .I1(axaddr_offset[1]),
        .I2(axaddr_offset[0]),
        .I3(axaddr_offset[2]),
        .I4(\FSM_sequential_state_reg[1]_0 ),
        .I5(\wrap_second_len_r_reg[3] [0]),
        .O(wrap_second_len[0]));
  LUT6 #(
    .INIT(64'h22EEEE2222E2EE22)) 
    \wrap_second_len_r[1]_i_1__0 
       (.I0(\wrap_second_len_r_reg[3] [1]),
        .I1(\FSM_sequential_state_reg[1]_0 ),
        .I2(axaddr_offset[1]),
        .I3(axaddr_offset[0]),
        .I4(\wrap_second_len_r_reg[3]_0 ),
        .I5(axaddr_offset[2]),
        .O(wrap_second_len[1]));
  LUT6 #(
    .INIT(64'hE22EE2E2E222E2E2)) 
    \wrap_second_len_r[2]_i_1__0 
       (.I0(\wrap_second_len_r_reg[3] [2]),
        .I1(\FSM_sequential_state_reg[1]_0 ),
        .I2(axaddr_offset[1]),
        .I3(axaddr_offset[0]),
        .I4(\wrap_second_len_r_reg[3]_0 ),
        .I5(axaddr_offset[2]),
        .O(wrap_second_len[2]));
  LUT6 #(
    .INIT(64'hFB00FFFFFB00FB00)) 
    \wrap_second_len_r[3]_i_1__0 
       (.I0(axaddr_offset[0]),
        .I1(\wrap_second_len_r_reg[3]_0 ),
        .I2(axaddr_offset[1]),
        .I3(\wrap_second_len_r_reg[3]_1 ),
        .I4(\FSM_sequential_state_reg[1]_0 ),
        .I5(\wrap_second_len_r_reg[3] [3]),
        .O(wrap_second_len[3]));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_simple_fifo" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_simple_fifo
   (Q,
    \cnt_read_reg[1]_0 ,
    \cnt_read_reg[0]_0 ,
    E,
    bresp_push,
    SR,
    \cnt_read_reg[0]_1 ,
    out,
    shandshake_r,
    b_push,
    \state_reg[1] ,
    m_axi_awready,
    \state_reg[1]_0 ,
    areset_d1,
    mhandshake_r,
    \memory_reg[3][0]_srl4_i_1__0_0 ,
    in,
    aclk);
  output [1:0]Q;
  output [0:0]\cnt_read_reg[1]_0 ;
  output \cnt_read_reg[0]_0 ;
  output [0:0]E;
  output bresp_push;
  output [0:0]SR;
  output \cnt_read_reg[0]_1 ;
  output [15:0]out;
  input shandshake_r;
  input b_push;
  input \state_reg[1] ;
  input m_axi_awready;
  input [0:0]\state_reg[1]_0 ;
  input areset_d1;
  input mhandshake_r;
  input [7:0]\memory_reg[3][0]_srl4_i_1__0_0 ;
  input [23:0]in;
  input aclk;

  wire [0:0]E;
  wire [1:0]Q;
  wire [0:0]SR;
  wire aclk;
  wire areset_d1;
  wire b_push;
  wire bresp_push;
  wire \cnt_read[0]_i_1__1_n_0 ;
  wire \cnt_read[1]_i_1_n_0 ;
  wire \cnt_read[1]_i_2_n_0 ;
  wire \cnt_read_reg[0]_0 ;
  wire \cnt_read_reg[0]_1 ;
  wire [0:0]\cnt_read_reg[1]_0 ;
  wire [23:0]in;
  wire m_axi_awready;
  wire [7:0]\memory_reg[3][0]_srl4_i_1__0_0 ;
  wire \memory_reg[3][0]_srl4_i_2__0_n_0 ;
  wire \memory_reg[3][0]_srl4_i_3_n_0 ;
  wire \memory_reg[3][0]_srl4_i_4_n_0 ;
  wire \memory_reg[3][0]_srl4_i_5_n_0 ;
  wire \memory_reg[3][0]_srl4_n_0 ;
  wire \memory_reg[3][1]_srl4_n_0 ;
  wire \memory_reg[3][2]_srl4_n_0 ;
  wire \memory_reg[3][3]_srl4_n_0 ;
  wire \memory_reg[3][4]_srl4_n_0 ;
  wire \memory_reg[3][5]_srl4_n_0 ;
  wire \memory_reg[3][6]_srl4_n_0 ;
  wire \memory_reg[3][7]_srl4_n_0 ;
  wire mhandshake_r;
  wire [15:0]out;
  wire shandshake_r;
  wire \state_reg[1] ;
  wire [0:0]\state_reg[1]_0 ;

  (* SOFT_HLUTNM = "soft_lutpair159" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \axaddr_incr[11]_i_11 
       (.I0(Q[0]),
        .I1(Q[1]),
        .O(\cnt_read_reg[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair160" *) 
  LUT2 #(
    .INIT(4'h8)) 
    bvalid_i_i_3
       (.I0(Q[0]),
        .I1(Q[1]),
        .O(\cnt_read_reg[0]_1 ));
  LUT1 #(
    .INIT(2'h1)) 
    \cnt_read[0]_i_1__1 
       (.I0(Q[0]),
        .O(\cnt_read[0]_i_1__1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \cnt_read[1]_i_1 
       (.I0(shandshake_r),
        .I1(b_push),
        .O(\cnt_read[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair161" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \cnt_read[1]_i_1__0 
       (.I0(shandshake_r),
        .I1(bresp_push),
        .O(E));
  (* SOFT_HLUTNM = "soft_lutpair160" *) 
  LUT4 #(
    .INIT(16'hB44B)) 
    \cnt_read[1]_i_2 
       (.I0(shandshake_r),
        .I1(b_push),
        .I2(Q[0]),
        .I3(Q[1]),
        .O(\cnt_read[1]_i_2_n_0 ));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[0] 
       (.C(aclk),
        .CE(\cnt_read[1]_i_1_n_0 ),
        .D(\cnt_read[0]_i_1__1_n_0 ),
        .Q(Q[0]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[1] 
       (.C(aclk),
        .CE(\cnt_read[1]_i_1_n_0 ),
        .D(\cnt_read[1]_i_2_n_0 ),
        .Q(Q[1]),
        .S(areset_d1));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][0]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][0]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[0]),
        .Q(\memory_reg[3][0]_srl4_n_0 ));
  LUT5 #(
    .INIT(32'h00000002)) 
    \memory_reg[3][0]_srl4_i_1__0 
       (.I0(mhandshake_r),
        .I1(\memory_reg[3][0]_srl4_i_2__0_n_0 ),
        .I2(\memory_reg[3][0]_srl4_i_3_n_0 ),
        .I3(\memory_reg[3][0]_srl4_i_4_n_0 ),
        .I4(\memory_reg[3][0]_srl4_i_5_n_0 ),
        .O(bresp_push));
  LUT4 #(
    .INIT(16'h6FF6)) 
    \memory_reg[3][0]_srl4_i_2__0 
       (.I0(\memory_reg[3][1]_srl4_n_0 ),
        .I1(\memory_reg[3][0]_srl4_i_1__0_0 [1]),
        .I2(\memory_reg[3][0]_srl4_n_0 ),
        .I3(\memory_reg[3][0]_srl4_i_1__0_0 [0]),
        .O(\memory_reg[3][0]_srl4_i_2__0_n_0 ));
  LUT4 #(
    .INIT(16'h6FF6)) 
    \memory_reg[3][0]_srl4_i_3 
       (.I0(\memory_reg[3][5]_srl4_n_0 ),
        .I1(\memory_reg[3][0]_srl4_i_1__0_0 [5]),
        .I2(\memory_reg[3][0]_srl4_i_1__0_0 [3]),
        .I3(\memory_reg[3][3]_srl4_n_0 ),
        .O(\memory_reg[3][0]_srl4_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h8FF8FFFFFFFF8FF8)) 
    \memory_reg[3][0]_srl4_i_4 
       (.I0(Q[0]),
        .I1(Q[1]),
        .I2(\memory_reg[3][0]_srl4_i_1__0_0 [4]),
        .I3(\memory_reg[3][4]_srl4_n_0 ),
        .I4(\memory_reg[3][7]_srl4_n_0 ),
        .I5(\memory_reg[3][0]_srl4_i_1__0_0 [7]),
        .O(\memory_reg[3][0]_srl4_i_4_n_0 ));
  LUT4 #(
    .INIT(16'h6FF6)) 
    \memory_reg[3][0]_srl4_i_5 
       (.I0(\memory_reg[3][6]_srl4_n_0 ),
        .I1(\memory_reg[3][0]_srl4_i_1__0_0 [6]),
        .I2(\memory_reg[3][2]_srl4_n_0 ),
        .I3(\memory_reg[3][0]_srl4_i_1__0_0 [2]),
        .O(\memory_reg[3][0]_srl4_i_5_n_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][10]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][10]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[10]),
        .Q(out[2]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][11]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][11]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[11]),
        .Q(out[3]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][12]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][12]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[12]),
        .Q(out[4]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][13]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][13]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[13]),
        .Q(out[5]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][14]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][14]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[14]),
        .Q(out[6]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][15]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][15]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[15]),
        .Q(out[7]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][16]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][16]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[16]),
        .Q(out[8]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][17]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][17]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[17]),
        .Q(out[9]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][18]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][18]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[18]),
        .Q(out[10]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][19]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][19]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[19]),
        .Q(out[11]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][1]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][1]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[1]),
        .Q(\memory_reg[3][1]_srl4_n_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][20]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][20]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[20]),
        .Q(out[12]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][21]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][21]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[21]),
        .Q(out[13]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][22]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][22]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[22]),
        .Q(out[14]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][23]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][23]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[23]),
        .Q(out[15]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][2]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][2]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[2]),
        .Q(\memory_reg[3][2]_srl4_n_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][3]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][3]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[3]),
        .Q(\memory_reg[3][3]_srl4_n_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][4]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][4]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[4]),
        .Q(\memory_reg[3][4]_srl4_n_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][5]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][5]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[5]),
        .Q(\memory_reg[3][5]_srl4_n_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][6]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][6]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[6]),
        .Q(\memory_reg[3][6]_srl4_n_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][7]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][7]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[7]),
        .Q(\memory_reg[3][7]_srl4_n_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][8]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][8]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[8]),
        .Q(out[0]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bid_fifo_0/memory_reg[3][9]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][9]_srl4 
       (.A0(Q[0]),
        .A1(Q[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(b_push),
        .CLK(aclk),
        .D(in[9]),
        .Q(out[1]));
  (* SOFT_HLUTNM = "soft_lutpair161" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \s_bresp_acc[1]_i_1 
       (.I0(areset_d1),
        .I1(bresp_push),
        .O(SR));
  (* SOFT_HLUTNM = "soft_lutpair159" *) 
  LUT5 #(
    .INIT(32'h02020F00)) 
    \state[1]_i_1 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(\state_reg[1] ),
        .I3(m_axi_awready),
        .I4(\state_reg[1]_0 ),
        .O(\cnt_read_reg[1]_0 ));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_simple_fifo" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_simple_fifo__parameterized0
   (areset_d1_reg,
    m_axi_bready,
    E,
    mhandshake,
    \s_bresp_acc_reg[1] ,
    sel,
    shandshake_r,
    areset_d1,
    bvalid_i_reg,
    si_rs_bvalid,
    si_rs_bready,
    mhandshake_r,
    m_axi_bresp,
    Q,
    m_axi_bvalid,
    aclk,
    \cnt_read_reg[1]_0 );
  output areset_d1_reg;
  output m_axi_bready;
  output [0:0]E;
  output mhandshake;
  output [1:0]\s_bresp_acc_reg[1] ;
  input sel;
  input shandshake_r;
  input areset_d1;
  input bvalid_i_reg;
  input si_rs_bvalid;
  input si_rs_bready;
  input mhandshake_r;
  input [1:0]m_axi_bresp;
  input [1:0]Q;
  input m_axi_bvalid;
  input aclk;
  input [0:0]\cnt_read_reg[1]_0 ;

  wire [0:0]E;
  wire [1:0]Q;
  wire aclk;
  wire areset_d1;
  wire areset_d1_reg;
  wire bvalid_i_i_2_n_0;
  wire bvalid_i_reg;
  wire [1:0]cnt_read;
  wire \cnt_read[0]_i_1__2_n_0 ;
  wire \cnt_read[1]_i_2__0_n_0 ;
  wire [0:0]\cnt_read_reg[1]_0 ;
  wire m_axi_bready;
  wire [1:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire mhandshake;
  wire mhandshake_r;
  wire [1:0]\s_bresp_acc_reg[1] ;
  wire sel;
  wire shandshake_r;
  wire si_rs_bready;
  wire si_rs_bvalid;

  LUT6 #(
    .INIT(64'h0000000155550001)) 
    bvalid_i_i_1
       (.I0(areset_d1),
        .I1(bvalid_i_i_2_n_0),
        .I2(bvalid_i_reg),
        .I3(shandshake_r),
        .I4(si_rs_bvalid),
        .I5(si_rs_bready),
        .O(areset_d1_reg));
  (* SOFT_HLUTNM = "soft_lutpair163" *) 
  LUT2 #(
    .INIT(4'h8)) 
    bvalid_i_i_2
       (.I0(cnt_read[0]),
        .I1(cnt_read[1]),
        .O(bvalid_i_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    \cnt_read[0]_i_1__2 
       (.I0(cnt_read[0]),
        .O(\cnt_read[0]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair163" *) 
  LUT4 #(
    .INIT(16'hD22D)) 
    \cnt_read[1]_i_2__0 
       (.I0(sel),
        .I1(shandshake_r),
        .I2(cnt_read[1]),
        .I3(cnt_read[0]),
        .O(\cnt_read[1]_i_2__0_n_0 ));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[0] 
       (.C(aclk),
        .CE(\cnt_read_reg[1]_0 ),
        .D(\cnt_read[0]_i_1__2_n_0 ),
        .Q(cnt_read[0]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[1] 
       (.C(aclk),
        .CE(\cnt_read_reg[1]_0 ),
        .D(\cnt_read[1]_i_2__0_n_0 ),
        .Q(cnt_read[1]),
        .S(areset_d1));
  (* SOFT_HLUTNM = "soft_lutpair162" *) 
  LUT3 #(
    .INIT(8'h08)) 
    m_axi_bready_INST_0
       (.I0(cnt_read[1]),
        .I1(cnt_read[0]),
        .I2(mhandshake_r),
        .O(m_axi_bready));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bresp_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bresp_fifo_0/memory_reg[3][0]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][0]_srl4 
       (.A0(cnt_read[0]),
        .A1(cnt_read[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(sel),
        .CLK(aclk),
        .D(Q[0]),
        .Q(\s_bresp_acc_reg[1] [0]));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bresp_fifo_0/memory_reg[3] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/WR.b_channel_0/bresp_fifo_0/memory_reg[3][1]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \memory_reg[3][1]_srl4 
       (.A0(cnt_read[0]),
        .A1(cnt_read[1]),
        .A2(1'b0),
        .A3(1'b0),
        .CE(sel),
        .CLK(aclk),
        .D(Q[1]),
        .Q(\s_bresp_acc_reg[1] [1]));
  (* SOFT_HLUTNM = "soft_lutpair162" *) 
  LUT4 #(
    .INIT(16'h4000)) 
    mhandshake_r_i_1
       (.I0(mhandshake_r),
        .I1(m_axi_bvalid),
        .I2(cnt_read[1]),
        .I3(cnt_read[0]),
        .O(mhandshake));
  LUT5 #(
    .INIT(32'h08088A08)) 
    \s_bresp_acc[1]_i_2 
       (.I0(mhandshake),
        .I1(m_axi_bresp[1]),
        .I2(Q[1]),
        .I3(m_axi_bresp[0]),
        .I4(Q[0]),
        .O(E));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_simple_fifo" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_simple_fifo__parameterized1
   (m_axi_rready,
    \cnt_read_reg[0]_0 ,
    \cnt_read_reg[3]_0 ,
    out,
    \cnt_read_reg[4]_0 ,
    m_axi_rvalid,
    m_valid_i_reg,
    in,
    aclk,
    areset_d1);
  output m_axi_rready;
  output \cnt_read_reg[0]_0 ;
  output \cnt_read_reg[3]_0 ;
  output [33:0]out;
  input \cnt_read_reg[4]_0 ;
  input m_axi_rvalid;
  input m_valid_i_reg;
  input [33:0]in;
  input aclk;
  input areset_d1;

  wire aclk;
  wire areset_d1;
  wire \cnt_read[0]_i_1_n_0 ;
  wire \cnt_read[1]_i_1__1_n_0 ;
  wire \cnt_read[2]_i_1_n_0 ;
  wire \cnt_read[3]_i_1_n_0 ;
  wire \cnt_read[4]_i_1_n_0 ;
  wire \cnt_read[4]_i_2_n_0 ;
  wire \cnt_read[4]_i_4_n_0 ;
  wire [4:0]cnt_read_reg;
  wire \cnt_read_reg[0]_0 ;
  wire \cnt_read_reg[3]_0 ;
  wire \cnt_read_reg[4]_0 ;
  wire [33:0]in;
  wire m_axi_rready;
  wire m_axi_rvalid;
  wire m_valid_i_reg;
  wire [33:0]out;
  wire wr_en0;
  wire \NLW_memory_reg[31][0]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][10]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][11]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][12]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][13]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][14]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][15]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][16]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][17]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][18]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][19]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][1]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][20]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][21]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][22]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][23]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][24]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][25]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][26]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][27]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][28]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][29]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][2]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][30]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][31]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][32]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][33]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][3]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][4]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][5]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][6]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][7]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][8]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][9]_srl32_Q31_UNCONNECTED ;

  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT5 #(
    .INIT(32'h7C000000)) 
    \FSM_sequential_state[1]_i_4 
       (.I0(cnt_read_reg[0]),
        .I1(cnt_read_reg[1]),
        .I2(cnt_read_reg[2]),
        .I3(cnt_read_reg[3]),
        .I4(cnt_read_reg[4]),
        .O(\cnt_read_reg[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \cnt_read[0]_i_1 
       (.I0(cnt_read_reg[0]),
        .O(\cnt_read[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'h69)) 
    \cnt_read[1]_i_1__1 
       (.I0(cnt_read_reg[0]),
        .I1(cnt_read_reg[1]),
        .I2(\cnt_read[4]_i_4_n_0 ),
        .O(\cnt_read[1]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT4 #(
    .INIT(16'h7E81)) 
    \cnt_read[2]_i_1 
       (.I0(cnt_read_reg[0]),
        .I1(\cnt_read[4]_i_4_n_0 ),
        .I2(cnt_read_reg[1]),
        .I3(cnt_read_reg[2]),
        .O(\cnt_read[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT5 #(
    .INIT(32'h7F80FE01)) 
    \cnt_read[3]_i_1 
       (.I0(\cnt_read[4]_i_4_n_0 ),
        .I1(cnt_read_reg[0]),
        .I2(cnt_read_reg[1]),
        .I3(cnt_read_reg[3]),
        .I4(cnt_read_reg[2]),
        .O(\cnt_read[3]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \cnt_read[4]_i_1 
       (.I0(wr_en0),
        .I1(\cnt_read_reg[4]_0 ),
        .O(\cnt_read[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h6AAAAAAAAAAAAAA9)) 
    \cnt_read[4]_i_2 
       (.I0(cnt_read_reg[4]),
        .I1(cnt_read_reg[3]),
        .I2(\cnt_read[4]_i_4_n_0 ),
        .I3(cnt_read_reg[0]),
        .I4(cnt_read_reg[1]),
        .I5(cnt_read_reg[2]),
        .O(\cnt_read[4]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cnt_read[4]_i_4 
       (.I0(wr_en0),
        .I1(\cnt_read_reg[4]_0 ),
        .O(\cnt_read[4]_i_4_n_0 ));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[0] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1_n_0 ),
        .D(\cnt_read[0]_i_1_n_0 ),
        .Q(cnt_read_reg[0]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[1] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1_n_0 ),
        .D(\cnt_read[1]_i_1__1_n_0 ),
        .Q(cnt_read_reg[1]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[2] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1_n_0 ),
        .D(\cnt_read[2]_i_1_n_0 ),
        .Q(cnt_read_reg[2]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[3] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1_n_0 ),
        .D(\cnt_read[3]_i_1_n_0 ),
        .Q(cnt_read_reg[3]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[4] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1_n_0 ),
        .D(\cnt_read[4]_i_2_n_0 ),
        .Q(cnt_read_reg[4]),
        .S(areset_d1));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT5 #(
    .INIT(32'hF77F777F)) 
    m_axi_rready_INST_0
       (.I0(cnt_read_reg[4]),
        .I1(cnt_read_reg[3]),
        .I2(cnt_read_reg[2]),
        .I3(cnt_read_reg[1]),
        .I4(cnt_read_reg[0]),
        .O(m_axi_rready));
  LUT6 #(
    .INIT(64'h000000007FFFFFFF)) 
    m_valid_i_i_2
       (.I0(cnt_read_reg[3]),
        .I1(cnt_read_reg[4]),
        .I2(cnt_read_reg[2]),
        .I3(cnt_read_reg[1]),
        .I4(cnt_read_reg[0]),
        .I5(m_valid_i_reg),
        .O(\cnt_read_reg[3]_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][0]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][0]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[0]),
        .Q(out[0]),
        .Q31(\NLW_memory_reg[31][0]_srl32_Q31_UNCONNECTED ));
  LUT6 #(
    .INIT(64'hAA2A2AAA2A2A2AAA)) 
    \memory_reg[31][0]_srl32_i_1 
       (.I0(m_axi_rvalid),
        .I1(cnt_read_reg[4]),
        .I2(cnt_read_reg[3]),
        .I3(cnt_read_reg[2]),
        .I4(cnt_read_reg[1]),
        .I5(cnt_read_reg[0]),
        .O(wr_en0));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][10]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][10]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[10]),
        .Q(out[10]),
        .Q31(\NLW_memory_reg[31][10]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][11]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][11]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[11]),
        .Q(out[11]),
        .Q31(\NLW_memory_reg[31][11]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][12]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][12]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[12]),
        .Q(out[12]),
        .Q31(\NLW_memory_reg[31][12]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][13]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][13]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[13]),
        .Q(out[13]),
        .Q31(\NLW_memory_reg[31][13]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][14]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][14]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[14]),
        .Q(out[14]),
        .Q31(\NLW_memory_reg[31][14]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][15]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][15]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[15]),
        .Q(out[15]),
        .Q31(\NLW_memory_reg[31][15]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][16]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][16]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[16]),
        .Q(out[16]),
        .Q31(\NLW_memory_reg[31][16]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][17]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][17]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[17]),
        .Q(out[17]),
        .Q31(\NLW_memory_reg[31][17]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][18]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][18]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[18]),
        .Q(out[18]),
        .Q31(\NLW_memory_reg[31][18]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][19]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][19]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[19]),
        .Q(out[19]),
        .Q31(\NLW_memory_reg[31][19]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][1]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][1]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[1]),
        .Q(out[1]),
        .Q31(\NLW_memory_reg[31][1]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][20]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][20]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[20]),
        .Q(out[20]),
        .Q31(\NLW_memory_reg[31][20]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][21]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][21]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[21]),
        .Q(out[21]),
        .Q31(\NLW_memory_reg[31][21]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][22]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][22]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[22]),
        .Q(out[22]),
        .Q31(\NLW_memory_reg[31][22]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][23]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][23]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[23]),
        .Q(out[23]),
        .Q31(\NLW_memory_reg[31][23]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][24]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][24]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[24]),
        .Q(out[24]),
        .Q31(\NLW_memory_reg[31][24]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][25]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][25]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[25]),
        .Q(out[25]),
        .Q31(\NLW_memory_reg[31][25]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][26]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][26]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[26]),
        .Q(out[26]),
        .Q31(\NLW_memory_reg[31][26]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][27]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][27]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[27]),
        .Q(out[27]),
        .Q31(\NLW_memory_reg[31][27]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][28]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][28]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[28]),
        .Q(out[28]),
        .Q31(\NLW_memory_reg[31][28]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][29]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][29]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[29]),
        .Q(out[29]),
        .Q31(\NLW_memory_reg[31][29]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][2]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][2]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[2]),
        .Q(out[2]),
        .Q31(\NLW_memory_reg[31][2]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][30]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][30]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[30]),
        .Q(out[30]),
        .Q31(\NLW_memory_reg[31][30]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][31]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][31]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[31]),
        .Q(out[31]),
        .Q31(\NLW_memory_reg[31][31]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][32]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][32]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[32]),
        .Q(out[32]),
        .Q31(\NLW_memory_reg[31][32]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][33]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][33]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[33]),
        .Q(out[33]),
        .Q31(\NLW_memory_reg[31][33]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][3]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][3]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[3]),
        .Q(out[3]),
        .Q31(\NLW_memory_reg[31][3]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][4]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][4]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[4]),
        .Q(out[4]),
        .Q31(\NLW_memory_reg[31][4]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][5]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][5]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[5]),
        .Q(out[5]),
        .Q31(\NLW_memory_reg[31][5]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][6]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][6]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[6]),
        .Q(out[6]),
        .Q31(\NLW_memory_reg[31][6]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][7]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][7]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[7]),
        .Q(out[7]),
        .Q31(\NLW_memory_reg[31][7]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][8]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][8]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[8]),
        .Q(out[8]),
        .Q31(\NLW_memory_reg[31][8]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/rd_data_fifo_0/memory_reg[31][9]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][9]_srl32 
       (.A(cnt_read_reg),
        .CE(wr_en0),
        .CLK(aclk),
        .D(in[9]),
        .Q(out[9]),
        .Q31(\NLW_memory_reg[31][9]_srl32_Q31_UNCONNECTED ));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_simple_fifo" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_simple_fifo__parameterized2
   (\cnt_read_reg[0]_0 ,
    \cnt_read_reg[4]_0 ,
    r_push_r_reg,
    \FSM_sequential_state_reg[1] ,
    r_push_r,
    \cnt_read_reg[4]_1 ,
    in,
    aclk,
    areset_d1);
  output \cnt_read_reg[0]_0 ;
  output \cnt_read_reg[4]_0 ;
  output [16:0]r_push_r_reg;
  input \FSM_sequential_state_reg[1] ;
  input r_push_r;
  input \cnt_read_reg[4]_1 ;
  input [16:0]in;
  input aclk;
  input areset_d1;

  wire \FSM_sequential_state_reg[1] ;
  wire aclk;
  wire areset_d1;
  wire \cnt_read[0]_i_1__0_n_0 ;
  wire \cnt_read[1]_i_1__2_n_0 ;
  wire \cnt_read[2]_i_1__0_n_0 ;
  wire \cnt_read[3]_i_1__0_n_0 ;
  wire \cnt_read[4]_i_1__0_n_0 ;
  wire \cnt_read[4]_i_2__0_n_0 ;
  wire \cnt_read[4]_i_3_n_0 ;
  wire [4:0]cnt_read_reg;
  wire \cnt_read_reg[0]_0 ;
  wire \cnt_read_reg[4]_0 ;
  wire \cnt_read_reg[4]_1 ;
  wire [16:0]in;
  wire r_push_r;
  wire [16:0]r_push_r_reg;
  wire \NLW_memory_reg[31][0]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][10]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][11]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][12]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][13]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][14]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][15]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][16]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][1]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][2]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][3]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][4]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][5]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][6]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][7]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][8]_srl32_Q31_UNCONNECTED ;
  wire \NLW_memory_reg[31][9]_srl32_Q31_UNCONNECTED ;

  LUT6 #(
    .INIT(64'h2003333333333333)) 
    \FSM_sequential_state[1]_i_3 
       (.I0(cnt_read_reg[0]),
        .I1(\FSM_sequential_state_reg[1] ),
        .I2(cnt_read_reg[2]),
        .I3(cnt_read_reg[1]),
        .I4(cnt_read_reg[4]),
        .I5(cnt_read_reg[3]),
        .O(\cnt_read_reg[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \cnt_read[0]_i_1__0 
       (.I0(cnt_read_reg[0]),
        .O(\cnt_read[0]_i_1__0_n_0 ));
  LUT4 #(
    .INIT(16'h9969)) 
    \cnt_read[1]_i_1__2 
       (.I0(cnt_read_reg[0]),
        .I1(cnt_read_reg[1]),
        .I2(r_push_r),
        .I3(\cnt_read_reg[4]_1 ),
        .O(\cnt_read[1]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT5 #(
    .INIT(32'hDFBA2045)) 
    \cnt_read[2]_i_1__0 
       (.I0(cnt_read_reg[0]),
        .I1(\cnt_read_reg[4]_1 ),
        .I2(r_push_r),
        .I3(cnt_read_reg[1]),
        .I4(cnt_read_reg[2]),
        .O(\cnt_read[2]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'hDFFF2000FFF2000D)) 
    \cnt_read[3]_i_1__0 
       (.I0(r_push_r),
        .I1(\cnt_read_reg[4]_1 ),
        .I2(cnt_read_reg[0]),
        .I3(cnt_read_reg[1]),
        .I4(cnt_read_reg[3]),
        .I5(cnt_read_reg[2]),
        .O(\cnt_read[3]_i_1__0_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \cnt_read[4]_i_1__0 
       (.I0(r_push_r),
        .I1(\cnt_read_reg[4]_1 ),
        .O(\cnt_read[4]_i_1__0_n_0 ));
  LUT4 #(
    .INIT(16'h6AA9)) 
    \cnt_read[4]_i_2__0 
       (.I0(cnt_read_reg[4]),
        .I1(cnt_read_reg[3]),
        .I2(cnt_read_reg[2]),
        .I3(\cnt_read[4]_i_3_n_0 ),
        .O(\cnt_read[4]_i_2__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT5 #(
    .INIT(32'h54D55454)) 
    \cnt_read[4]_i_3 
       (.I0(cnt_read_reg[2]),
        .I1(cnt_read_reg[1]),
        .I2(cnt_read_reg[0]),
        .I3(\cnt_read_reg[4]_1 ),
        .I4(r_push_r),
        .O(\cnt_read[4]_i_3_n_0 ));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[0] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1__0_n_0 ),
        .D(\cnt_read[0]_i_1__0_n_0 ),
        .Q(cnt_read_reg[0]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[1] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1__0_n_0 ),
        .D(\cnt_read[1]_i_1__2_n_0 ),
        .Q(cnt_read_reg[1]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[2] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1__0_n_0 ),
        .D(\cnt_read[2]_i_1__0_n_0 ),
        .Q(cnt_read_reg[2]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[3] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1__0_n_0 ),
        .D(\cnt_read[3]_i_1__0_n_0 ),
        .Q(cnt_read_reg[3]),
        .S(areset_d1));
  FDSE #(
    .INIT(1'b1)) 
    \cnt_read_reg[4] 
       (.C(aclk),
        .CE(\cnt_read[4]_i_1__0_n_0 ),
        .D(\cnt_read[4]_i_2__0_n_0 ),
        .Q(cnt_read_reg[4]),
        .S(areset_d1));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    m_valid_i_i_3
       (.I0(cnt_read_reg[4]),
        .I1(cnt_read_reg[3]),
        .I2(cnt_read_reg[1]),
        .I3(cnt_read_reg[2]),
        .I4(cnt_read_reg[0]),
        .O(\cnt_read_reg[4]_0 ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][0]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][0]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[0]),
        .Q(r_push_r_reg[0]),
        .Q31(\NLW_memory_reg[31][0]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][10]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][10]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[10]),
        .Q(r_push_r_reg[10]),
        .Q31(\NLW_memory_reg[31][10]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][11]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][11]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[11]),
        .Q(r_push_r_reg[11]),
        .Q31(\NLW_memory_reg[31][11]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][12]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][12]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[12]),
        .Q(r_push_r_reg[12]),
        .Q31(\NLW_memory_reg[31][12]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][13]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][13]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[13]),
        .Q(r_push_r_reg[13]),
        .Q31(\NLW_memory_reg[31][13]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][14]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][14]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[14]),
        .Q(r_push_r_reg[14]),
        .Q31(\NLW_memory_reg[31][14]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][15]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][15]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[15]),
        .Q(r_push_r_reg[15]),
        .Q31(\NLW_memory_reg[31][15]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][16]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][16]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[16]),
        .Q(r_push_r_reg[16]),
        .Q31(\NLW_memory_reg[31][16]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][1]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][1]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[1]),
        .Q(r_push_r_reg[1]),
        .Q31(\NLW_memory_reg[31][1]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][2]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][2]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[2]),
        .Q(r_push_r_reg[2]),
        .Q31(\NLW_memory_reg[31][2]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][3]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][3]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[3]),
        .Q(r_push_r_reg[3]),
        .Q31(\NLW_memory_reg[31][3]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][4]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][4]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[4]),
        .Q(r_push_r_reg[4]),
        .Q31(\NLW_memory_reg[31][4]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][5]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][5]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[5]),
        .Q(r_push_r_reg[5]),
        .Q31(\NLW_memory_reg[31][5]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][6]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][6]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[6]),
        .Q(r_push_r_reg[6]),
        .Q31(\NLW_memory_reg[31][6]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][7]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][7]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[7]),
        .Q(r_push_r_reg[7]),
        .Q31(\NLW_memory_reg[31][7]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][8]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][8]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[8]),
        .Q(r_push_r_reg[8]),
        .Q31(\NLW_memory_reg[31][8]_srl32_Q31_UNCONNECTED ));
  (* srl_bus_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31] " *) 
  (* srl_name = "inst/\gen_axilite.gen_b2s_conv.axilite_b2s/RD.r_channel_0/transaction_fifo_0/memory_reg[31][9]_srl32 " *) 
  SRLC32E #(
    .INIT(32'h00000000)) 
    \memory_reg[31][9]_srl32 
       (.A(cnt_read_reg),
        .CE(r_push_r),
        .CLK(aclk),
        .D(in[9]),
        .Q(r_push_r_reg[9]),
        .Q31(\NLW_memory_reg[31][9]_srl32_Q31_UNCONNECTED ));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_wr_cmd_fsm" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_wr_cmd_fsm
   (E,
    \state_reg[1]_0 ,
    Q,
    sel_first_reg,
    sel_first_reg_0,
    sel_first_i,
    D,
    wrap_second_len,
    \state_reg[1]_1 ,
    axaddr_offset,
    sel_first_reg_1,
    \m_payload_i_reg[3] ,
    \cnt_read_reg[0] ,
    m_valid_i_reg,
    m_axi_awvalid,
    si_rs_awvalid,
    sel_first__0,
    areset_d1,
    \axaddr_incr_reg[0] ,
    sel_first_reg_2,
    \wrap_second_len_r_reg[3] ,
    \wrap_second_len_r_reg[3]_0 ,
    \wrap_second_len_r_reg[3]_1 ,
    \axaddr_offset_r_reg[3] ,
    \axaddr_offset_r_reg[2] ,
    \axaddr_offset_r_reg[1] ,
    \axaddr_incr[11]_i_3 ,
    \axaddr_incr[11]_i_3_0 ,
    \axaddr_incr[11]_i_3_1 ,
    \axaddr_incr[11]_i_5_0 ,
    m_axi_awready,
    \axaddr_incr[11]_i_5_1 ,
    next_pending_r_reg,
    \axaddr_incr[11]_i_5_2 ,
    \axaddr_incr[11]_i_5_3 ,
    \state_reg[0]_0 ,
    \state_reg[1]_2 ,
    aclk);
  output [0:0]E;
  output \state_reg[1]_0 ;
  output [1:0]Q;
  output sel_first_reg;
  output sel_first_reg_0;
  output sel_first_i;
  output [3:0]D;
  output [3:0]wrap_second_len;
  output [0:0]\state_reg[1]_1 ;
  output [2:0]axaddr_offset;
  output [0:0]sel_first_reg_1;
  output \m_payload_i_reg[3] ;
  output \cnt_read_reg[0] ;
  output [0:0]m_valid_i_reg;
  output m_axi_awvalid;
  input si_rs_awvalid;
  input sel_first__0;
  input areset_d1;
  input \axaddr_incr_reg[0] ;
  input sel_first_reg_2;
  input [3:0]\wrap_second_len_r_reg[3] ;
  input \wrap_second_len_r_reg[3]_0 ;
  input \wrap_second_len_r_reg[3]_1 ;
  input [2:0]\axaddr_offset_r_reg[3] ;
  input \axaddr_offset_r_reg[2] ;
  input \axaddr_offset_r_reg[1] ;
  input [0:0]\axaddr_incr[11]_i_3 ;
  input \axaddr_incr[11]_i_3_0 ;
  input \axaddr_incr[11]_i_3_1 ;
  input \axaddr_incr[11]_i_5_0 ;
  input m_axi_awready;
  input \axaddr_incr[11]_i_5_1 ;
  input next_pending_r_reg;
  input \axaddr_incr[11]_i_5_2 ;
  input \axaddr_incr[11]_i_5_3 ;
  input [1:0]\state_reg[0]_0 ;
  input [0:0]\state_reg[1]_2 ;
  input aclk;

  wire [3:0]D;
  wire [0:0]E;
  wire [1:0]Q;
  wire aclk;
  wire areset_d1;
  wire [0:0]\axaddr_incr[11]_i_3 ;
  wire \axaddr_incr[11]_i_3_0 ;
  wire \axaddr_incr[11]_i_3_1 ;
  wire \axaddr_incr[11]_i_5_0 ;
  wire \axaddr_incr[11]_i_5_1 ;
  wire \axaddr_incr[11]_i_5_2 ;
  wire \axaddr_incr[11]_i_5_3 ;
  wire \axaddr_incr[11]_i_6_n_0 ;
  wire \axaddr_incr[11]_i_7_n_0 ;
  wire \axaddr_incr[11]_i_9_n_0 ;
  wire \axaddr_incr_reg[0] ;
  wire [2:0]axaddr_offset;
  wire \axaddr_offset_r_reg[1] ;
  wire \axaddr_offset_r_reg[2] ;
  wire [2:0]\axaddr_offset_r_reg[3] ;
  wire \cnt_read_reg[0] ;
  wire m_axi_awready;
  wire m_axi_awvalid;
  wire \m_payload_i_reg[3] ;
  wire [0:0]m_valid_i_reg;
  wire next_pending_r_reg;
  wire sel_first__0;
  wire sel_first_i;
  wire sel_first_reg;
  wire sel_first_reg_0;
  wire [0:0]sel_first_reg_1;
  wire sel_first_reg_2;
  wire si_rs_awvalid;
  wire \state[0]_i_1_n_0 ;
  wire \state[0]_i_2_n_0 ;
  wire [1:0]\state_reg[0]_0 ;
  wire \state_reg[1]_0 ;
  wire [0:0]\state_reg[1]_1 ;
  wire [0:0]\state_reg[1]_2 ;
  wire \wrap_cnt_r[0]_i_2_n_0 ;
  wire \wrap_cnt_r[3]_i_2_n_0 ;
  wire [3:0]wrap_second_len;
  wire [3:0]\wrap_second_len_r_reg[3] ;
  wire \wrap_second_len_r_reg[3]_0 ;
  wire \wrap_second_len_r_reg[3]_1 ;

  (* SOFT_HLUTNM = "soft_lutpair145" *) 
  LUT4 #(
    .INIT(16'hEEFE)) 
    \axaddr_incr[11]_i_1 
       (.I0(\axaddr_incr_reg[0] ),
        .I1(\state_reg[1]_0 ),
        .I2(Q[1]),
        .I3(Q[0]),
        .O(sel_first_reg_1));
  LUT6 #(
    .INIT(64'hB3BBB3BBB3BB33BB)) 
    \axaddr_incr[11]_i_5 
       (.I0(\axaddr_incr[11]_i_6_n_0 ),
        .I1(\axaddr_incr[11]_i_3 ),
        .I2(\axaddr_incr[11]_i_7_n_0 ),
        .I3(\axaddr_incr[11]_i_3_0 ),
        .I4(\axaddr_incr[11]_i_9_n_0 ),
        .I5(\axaddr_incr[11]_i_3_1 ),
        .O(\m_payload_i_reg[3] ));
  LUT6 #(
    .INIT(64'h55DD15DDFFFFFFFF)) 
    \axaddr_incr[11]_i_6 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(m_axi_awready),
        .I3(\axaddr_incr[11]_i_5_1 ),
        .I4(next_pending_r_reg),
        .I5(\axaddr_incr[11]_i_5_3 ),
        .O(\axaddr_incr[11]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h55DD15DDFFFFFFFF)) 
    \axaddr_incr[11]_i_7 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(m_axi_awready),
        .I3(\axaddr_incr[11]_i_5_1 ),
        .I4(next_pending_r_reg),
        .I5(\axaddr_incr[11]_i_5_2 ),
        .O(\axaddr_incr[11]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hBBBBFBFBABBBFBFB)) 
    \axaddr_incr[11]_i_9 
       (.I0(\axaddr_incr[11]_i_5_0 ),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(m_axi_awready),
        .I4(\axaddr_incr[11]_i_5_1 ),
        .I5(next_pending_r_reg),
        .O(\axaddr_incr[11]_i_9_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair143" *) 
  LUT5 #(
    .INIT(32'hAABA0000)) 
    \axaddr_offset_r[1]_i_1 
       (.I0(\axaddr_offset_r_reg[3] [0]),
        .I1(Q[1]),
        .I2(si_rs_awvalid),
        .I3(Q[0]),
        .I4(\axaddr_offset_r_reg[1] ),
        .O(axaddr_offset[0]));
  LUT5 #(
    .INIT(32'hAABA0000)) 
    \axaddr_offset_r[2]_i_1 
       (.I0(\axaddr_offset_r_reg[3] [1]),
        .I1(Q[1]),
        .I2(si_rs_awvalid),
        .I3(Q[0]),
        .I4(\axaddr_offset_r_reg[2] ),
        .O(axaddr_offset[1]));
  (* SOFT_HLUTNM = "soft_lutpair144" *) 
  LUT5 #(
    .INIT(32'hFFEFAAAA)) 
    \axaddr_offset_r[3]_i_1 
       (.I0(\wrap_second_len_r_reg[3]_1 ),
        .I1(Q[1]),
        .I2(si_rs_awvalid),
        .I3(Q[0]),
        .I4(\axaddr_offset_r_reg[3] [2]),
        .O(axaddr_offset[2]));
  (* SOFT_HLUTNM = "soft_lutpair145" *) 
  LUT4 #(
    .INIT(16'hCCFE)) 
    \axlen_cnt[7]_i_1 
       (.I0(si_rs_awvalid),
        .I1(\state_reg[1]_0 ),
        .I2(Q[1]),
        .I3(Q[0]),
        .O(E));
  (* SOFT_HLUTNM = "soft_lutpair144" *) 
  LUT2 #(
    .INIT(4'h2)) 
    m_axi_awvalid_INST_0
       (.I0(Q[0]),
        .I1(Q[1]),
        .O(m_axi_awvalid));
  (* SOFT_HLUTNM = "soft_lutpair147" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \m_payload_i[39]_i_1 
       (.I0(\state_reg[1]_0 ),
        .I1(si_rs_awvalid),
        .O(m_valid_i_reg));
  LUT6 #(
    .INIT(64'h88880088C8C800C8)) 
    \memory_reg[3][0]_srl4_i_1 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(m_axi_awready),
        .I3(\state_reg[0]_0 [1]),
        .I4(\state_reg[0]_0 [0]),
        .I5(next_pending_r_reg),
        .O(\state_reg[1]_0 ));
  LUT6 #(
    .INIT(64'h30300000BAFFFFFF)) 
    next_pending_r_i_2__0
       (.I0(next_pending_r_reg),
        .I1(\state_reg[0]_0 [0]),
        .I2(\state_reg[0]_0 [1]),
        .I3(m_axi_awready),
        .I4(Q[0]),
        .I5(Q[1]),
        .O(\cnt_read_reg[0] ));
  LUT6 #(
    .INIT(64'hFFFFFFFF22220F02)) 
    sel_first_i_1
       (.I0(sel_first__0),
        .I1(\state_reg[1]_0 ),
        .I2(Q[1]),
        .I3(si_rs_awvalid),
        .I4(Q[0]),
        .I5(areset_d1),
        .O(sel_first_reg));
  LUT6 #(
    .INIT(64'hFFFFFFFF22220F02)) 
    sel_first_i_1__0
       (.I0(\axaddr_incr_reg[0] ),
        .I1(\state_reg[1]_0 ),
        .I2(Q[1]),
        .I3(si_rs_awvalid),
        .I4(Q[0]),
        .I5(areset_d1),
        .O(sel_first_reg_0));
  LUT6 #(
    .INIT(64'hFFFFFFFF44440F04)) 
    sel_first_i_1__1
       (.I0(\state_reg[1]_0 ),
        .I1(sel_first_reg_2),
        .I2(Q[1]),
        .I3(si_rs_awvalid),
        .I4(Q[0]),
        .I5(areset_d1),
        .O(sel_first_i));
  (* SOFT_HLUTNM = "soft_lutpair147" *) 
  LUT3 #(
    .INIT(8'hF4)) 
    \state[0]_i_1 
       (.I0(Q[0]),
        .I1(si_rs_awvalid),
        .I2(\state[0]_i_2_n_0 ),
        .O(\state[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h3030FFFF10FF0000)) 
    \state[0]_i_2 
       (.I0(next_pending_r_reg),
        .I1(\state_reg[0]_0 [0]),
        .I2(\state_reg[0]_0 [1]),
        .I3(m_axi_awready),
        .I4(Q[0]),
        .I5(Q[1]),
        .O(\state[0]_i_2_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \state_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\state[0]_i_1_n_0 ),
        .Q(Q[0]),
        .R(areset_d1));
  FDRE #(
    .INIT(1'b0)) 
    \state_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\state_reg[1]_2 ),
        .Q(Q[1]),
        .R(areset_d1));
  (* SOFT_HLUTNM = "soft_lutpair143" *) 
  LUT3 #(
    .INIT(8'h04)) 
    \wrap_boundary_axaddr_r[11]_i_1 
       (.I0(Q[1]),
        .I1(si_rs_awvalid),
        .I2(Q[0]),
        .O(\state_reg[1]_1 ));
  LUT6 #(
    .INIT(64'h9999909999999599)) 
    \wrap_cnt_r[0]_i_1 
       (.I0(\wrap_cnt_r[0]_i_2_n_0 ),
        .I1(\wrap_second_len_r_reg[3] [0]),
        .I2(Q[0]),
        .I3(si_rs_awvalid),
        .I4(Q[1]),
        .I5(\wrap_second_len_r_reg[3]_0 ),
        .O(D[0]));
  LUT6 #(
    .INIT(64'h0000000000004500)) 
    \wrap_cnt_r[0]_i_2 
       (.I0(\wrap_second_len_r_reg[3]_1 ),
        .I1(\state_reg[1]_1 ),
        .I2(\axaddr_offset_r_reg[3] [2]),
        .I3(\wrap_second_len_r_reg[3]_0 ),
        .I4(axaddr_offset[0]),
        .I5(axaddr_offset[1]),
        .O(\wrap_cnt_r[0]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \wrap_cnt_r[1]_i_1 
       (.I0(wrap_second_len[1]),
        .I1(\wrap_cnt_r[3]_i_2_n_0 ),
        .O(D[1]));
  (* SOFT_HLUTNM = "soft_lutpair146" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \wrap_cnt_r[2]_i_1 
       (.I0(wrap_second_len[2]),
        .I1(\wrap_cnt_r[3]_i_2_n_0 ),
        .I2(wrap_second_len[1]),
        .O(D[2]));
  (* SOFT_HLUTNM = "soft_lutpair146" *) 
  LUT4 #(
    .INIT(16'h6AAA)) 
    \wrap_cnt_r[3]_i_1 
       (.I0(wrap_second_len[3]),
        .I1(wrap_second_len[1]),
        .I2(\wrap_cnt_r[3]_i_2_n_0 ),
        .I3(wrap_second_len[2]),
        .O(D[3]));
  LUT6 #(
    .INIT(64'hEEEE2222EEE02222)) 
    \wrap_cnt_r[3]_i_2 
       (.I0(\wrap_second_len_r_reg[3] [0]),
        .I1(\state_reg[1]_1 ),
        .I2(axaddr_offset[1]),
        .I3(axaddr_offset[0]),
        .I4(\wrap_second_len_r_reg[3]_0 ),
        .I5(axaddr_offset[2]),
        .O(\wrap_cnt_r[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAAA8FFFFAAA80000)) 
    \wrap_second_len_r[0]_i_1 
       (.I0(\wrap_second_len_r_reg[3]_0 ),
        .I1(axaddr_offset[1]),
        .I2(axaddr_offset[0]),
        .I3(axaddr_offset[2]),
        .I4(\state_reg[1]_1 ),
        .I5(\wrap_second_len_r_reg[3] [0]),
        .O(wrap_second_len[0]));
  LUT6 #(
    .INIT(64'h22EEEE2222E2EE22)) 
    \wrap_second_len_r[1]_i_1 
       (.I0(\wrap_second_len_r_reg[3] [1]),
        .I1(\state_reg[1]_1 ),
        .I2(axaddr_offset[1]),
        .I3(axaddr_offset[0]),
        .I4(\wrap_second_len_r_reg[3]_0 ),
        .I5(axaddr_offset[2]),
        .O(wrap_second_len[1]));
  LUT6 #(
    .INIT(64'hE22EE2E2E222E2E2)) 
    \wrap_second_len_r[2]_i_1 
       (.I0(\wrap_second_len_r_reg[3] [2]),
        .I1(\state_reg[1]_1 ),
        .I2(axaddr_offset[1]),
        .I3(axaddr_offset[0]),
        .I4(\wrap_second_len_r_reg[3]_0 ),
        .I5(axaddr_offset[2]),
        .O(wrap_second_len[2]));
  LUT6 #(
    .INIT(64'hFB00FFFFFB00FB00)) 
    \wrap_second_len_r[3]_i_1 
       (.I0(axaddr_offset[0]),
        .I1(\wrap_second_len_r_reg[3]_0 ),
        .I2(axaddr_offset[1]),
        .I3(\wrap_second_len_r_reg[3]_1 ),
        .I4(\state_reg[1]_1 ),
        .I5(\wrap_second_len_r_reg[3] [3]),
        .O(wrap_second_len[3]));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_wrap_cmd" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_wrap_cmd
   (sel_first__0,
    \m_payload_i_reg[47] ,
    \m_payload_i_reg[47]_0 ,
    \axaddr_wrap_reg[11]_0 ,
    \axaddr_offset_r_reg[3]_0 ,
    \wrap_second_len_r_reg[3]_0 ,
    aclk,
    sel_first_reg_0,
    \axlen_cnt_reg[3]_0 ,
    sel_first_i,
    incr_next_pending,
    next_pending_r_reg_0,
    E,
    next_pending_r_reg_1,
    Q,
    si_rs_awvalid,
    \axaddr_wrap_reg[3]_0 ,
    \axaddr_wrap_reg[2]_0 ,
    \axaddr_wrap_reg[1]_0 ,
    \axaddr_wrap_reg[0]_0 ,
    D,
    \wrap_second_len_r_reg[3]_1 ,
    \axaddr_wrap_reg[0]_1 ,
    \wrap_cnt_r_reg[3]_0 ,
    \wrap_boundary_axaddr_r_reg[6]_0 );
  output sel_first__0;
  output \m_payload_i_reg[47] ;
  output \m_payload_i_reg[47]_0 ;
  output [11:0]\axaddr_wrap_reg[11]_0 ;
  output [3:0]\axaddr_offset_r_reg[3]_0 ;
  output [3:0]\wrap_second_len_r_reg[3]_0 ;
  input aclk;
  input sel_first_reg_0;
  input [18:0]\axlen_cnt_reg[3]_0 ;
  input sel_first_i;
  input incr_next_pending;
  input next_pending_r_reg_0;
  input [0:0]E;
  input next_pending_r_reg_1;
  input [1:0]Q;
  input si_rs_awvalid;
  input \axaddr_wrap_reg[3]_0 ;
  input \axaddr_wrap_reg[2]_0 ;
  input \axaddr_wrap_reg[1]_0 ;
  input \axaddr_wrap_reg[0]_0 ;
  input [3:0]D;
  input [3:0]\wrap_second_len_r_reg[3]_1 ;
  input [0:0]\axaddr_wrap_reg[0]_1 ;
  input [3:0]\wrap_cnt_r_reg[3]_0 ;
  input [6:0]\wrap_boundary_axaddr_r_reg[6]_0 ;

  wire [3:0]D;
  wire [0:0]E;
  wire [1:0]Q;
  wire aclk;
  wire [3:0]\axaddr_offset_r_reg[3]_0 ;
  wire \axaddr_wrap[0]_i_1_n_0 ;
  wire \axaddr_wrap[10]_i_1_n_0 ;
  wire \axaddr_wrap[10]_i_2__0_n_0 ;
  wire \axaddr_wrap[11]_i_1_n_0 ;
  wire \axaddr_wrap[11]_i_2__0_n_0 ;
  wire \axaddr_wrap[11]_i_3_n_0 ;
  wire \axaddr_wrap[11]_i_4_n_0 ;
  wire \axaddr_wrap[1]_i_1_n_0 ;
  wire \axaddr_wrap[2]_i_1_n_0 ;
  wire \axaddr_wrap[2]_i_3__0_n_0 ;
  wire \axaddr_wrap[3]_i_1_n_0 ;
  wire \axaddr_wrap[3]_i_3__0_n_0 ;
  wire \axaddr_wrap[4]_i_1_n_0 ;
  wire \axaddr_wrap[4]_i_2__0_n_0 ;
  wire \axaddr_wrap[5]_i_1_n_0 ;
  wire \axaddr_wrap[5]_i_2__0_n_0 ;
  wire \axaddr_wrap[6]_i_1_n_0 ;
  wire \axaddr_wrap[6]_i_2__0_n_0 ;
  wire \axaddr_wrap[7]_i_1_n_0 ;
  wire \axaddr_wrap[7]_i_2__0_n_0 ;
  wire \axaddr_wrap[8]_i_1_n_0 ;
  wire \axaddr_wrap[8]_i_2__0_n_0 ;
  wire \axaddr_wrap[9]_i_1_n_0 ;
  wire \axaddr_wrap[9]_i_2__0_n_0 ;
  wire \axaddr_wrap_reg[0]_0 ;
  wire [0:0]\axaddr_wrap_reg[0]_1 ;
  wire [11:0]\axaddr_wrap_reg[11]_0 ;
  wire \axaddr_wrap_reg[1]_0 ;
  wire \axaddr_wrap_reg[2]_0 ;
  wire \axaddr_wrap_reg[3]_0 ;
  wire \axlen_cnt[0]_i_1__0_n_0 ;
  wire \axlen_cnt[1]_i_1__0_n_0 ;
  wire \axlen_cnt[2]_i_1__0_n_0 ;
  wire \axlen_cnt[3]_i_1__0_n_0 ;
  wire [18:0]\axlen_cnt_reg[3]_0 ;
  wire \axlen_cnt_reg_n_0_[0] ;
  wire \axlen_cnt_reg_n_0_[1] ;
  wire \axlen_cnt_reg_n_0_[2] ;
  wire \axlen_cnt_reg_n_0_[3] ;
  wire incr_next_pending;
  wire \m_payload_i_reg[47] ;
  wire \m_payload_i_reg[47]_0 ;
  wire next_pending_r_i_2_n_0;
  wire next_pending_r_reg_0;
  wire next_pending_r_reg_1;
  wire next_pending_r_reg_n_0;
  wire sel_first__0;
  wire sel_first_i;
  wire sel_first_reg_0;
  wire si_rs_awvalid;
  wire [11:0]wrap_boundary_axaddr_r;
  wire [6:0]\wrap_boundary_axaddr_r_reg[6]_0 ;
  wire [3:0]wrap_cnt_r;
  wire [3:0]\wrap_cnt_r_reg[3]_0 ;
  wire wrap_next_pending;
  wire [3:0]\wrap_second_len_r_reg[3]_0 ;
  wire [3:0]\wrap_second_len_r_reg[3]_1 ;

  FDRE \axaddr_offset_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[0]),
        .Q(\axaddr_offset_r_reg[3]_0 [0]),
        .R(1'b0));
  FDRE \axaddr_offset_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[1]),
        .Q(\axaddr_offset_r_reg[3]_0 [1]),
        .R(1'b0));
  FDRE \axaddr_offset_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[2]),
        .Q(\axaddr_offset_r_reg[3]_0 [2]),
        .R(1'b0));
  FDRE \axaddr_offset_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(D[3]),
        .Q(\axaddr_offset_r_reg[3]_0 [3]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[0]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [0]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[0]_0 ),
        .I3(\axaddr_wrap_reg[11]_0 [0]),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[0]),
        .O(\axaddr_wrap[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[10]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [10]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[11]_0 [10]),
        .I3(\axaddr_wrap[10]_i_2__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[10]),
        .O(\axaddr_wrap[10]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair158" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \axaddr_wrap[10]_i_2__0 
       (.I0(\axaddr_wrap_reg[11]_0 [9]),
        .I1(\axaddr_wrap[9]_i_2__0_n_0 ),
        .O(\axaddr_wrap[10]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[11]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [11]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[11]_0 [11]),
        .I3(\axaddr_wrap[11]_i_2__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[11]),
        .O(\axaddr_wrap[11]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair158" *) 
  LUT3 #(
    .INIT(8'h80)) 
    \axaddr_wrap[11]_i_2__0 
       (.I0(\axaddr_wrap_reg[11]_0 [10]),
        .I1(\axaddr_wrap[9]_i_2__0_n_0 ),
        .I2(\axaddr_wrap_reg[11]_0 [9]),
        .O(\axaddr_wrap[11]_i_2__0_n_0 ));
  LUT3 #(
    .INIT(8'h41)) 
    \axaddr_wrap[11]_i_3 
       (.I0(\axaddr_wrap[11]_i_4_n_0 ),
        .I1(wrap_cnt_r[3]),
        .I2(\axlen_cnt_reg_n_0_[3] ),
        .O(\axaddr_wrap[11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \axaddr_wrap[11]_i_4 
       (.I0(\axlen_cnt_reg_n_0_[2] ),
        .I1(wrap_cnt_r[2]),
        .I2(\axlen_cnt_reg_n_0_[0] ),
        .I3(wrap_cnt_r[0]),
        .I4(wrap_cnt_r[1]),
        .I5(\axlen_cnt_reg_n_0_[1] ),
        .O(\axaddr_wrap[11]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hBBBBB88B8888B88B)) 
    \axaddr_wrap[1]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [1]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[11]_0 [1]),
        .I3(\axaddr_wrap_reg[1]_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[1]),
        .O(\axaddr_wrap[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[2]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [2]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[2]_0 ),
        .I3(\axaddr_wrap[2]_i_3__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[2]),
        .O(\axaddr_wrap[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair155" *) 
  LUT4 #(
    .INIT(16'h2220)) 
    \axaddr_wrap[2]_i_3__0 
       (.I0(\axaddr_wrap_reg[11]_0 [1]),
        .I1(\axlen_cnt_reg[3]_0 [13]),
        .I2(\axlen_cnt_reg[3]_0 [12]),
        .I3(\axaddr_wrap_reg[11]_0 [0]),
        .O(\axaddr_wrap[2]_i_3__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[3]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [3]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[3]_0 ),
        .I3(\axaddr_wrap[3]_i_3__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[3]),
        .O(\axaddr_wrap[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair155" *) 
  LUT5 #(
    .INIT(32'h0AF80000)) 
    \axaddr_wrap[3]_i_3__0 
       (.I0(\axaddr_wrap_reg[11]_0 [1]),
        .I1(\axaddr_wrap_reg[11]_0 [0]),
        .I2(\axlen_cnt_reg[3]_0 [13]),
        .I3(\axlen_cnt_reg[3]_0 [12]),
        .I4(\axaddr_wrap_reg[11]_0 [2]),
        .O(\axaddr_wrap[3]_i_3__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[4]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [4]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[11]_0 [4]),
        .I3(\axaddr_wrap[4]_i_2__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[4]),
        .O(\axaddr_wrap[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFAF8F00000000000)) 
    \axaddr_wrap[4]_i_2__0 
       (.I0(\axaddr_wrap_reg[11]_0 [1]),
        .I1(\axaddr_wrap_reg[11]_0 [0]),
        .I2(\axlen_cnt_reg[3]_0 [13]),
        .I3(\axlen_cnt_reg[3]_0 [12]),
        .I4(\axaddr_wrap_reg[11]_0 [2]),
        .I5(\axaddr_wrap_reg[11]_0 [3]),
        .O(\axaddr_wrap[4]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[5]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [5]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[11]_0 [5]),
        .I3(\axaddr_wrap[5]_i_2__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[5]),
        .O(\axaddr_wrap[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair157" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \axaddr_wrap[5]_i_2__0 
       (.I0(\axaddr_wrap_reg[11]_0 [4]),
        .I1(\axaddr_wrap[4]_i_2__0_n_0 ),
        .O(\axaddr_wrap[5]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[6]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [6]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[11]_0 [6]),
        .I3(\axaddr_wrap[6]_i_2__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[6]),
        .O(\axaddr_wrap[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair157" *) 
  LUT3 #(
    .INIT(8'h80)) 
    \axaddr_wrap[6]_i_2__0 
       (.I0(\axaddr_wrap_reg[11]_0 [5]),
        .I1(\axaddr_wrap[4]_i_2__0_n_0 ),
        .I2(\axaddr_wrap_reg[11]_0 [4]),
        .O(\axaddr_wrap[6]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[7]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [7]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[11]_0 [7]),
        .I3(\axaddr_wrap[7]_i_2__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[7]),
        .O(\axaddr_wrap[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair154" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \axaddr_wrap[7]_i_2__0 
       (.I0(\axaddr_wrap_reg[11]_0 [6]),
        .I1(\axaddr_wrap_reg[11]_0 [4]),
        .I2(\axaddr_wrap[4]_i_2__0_n_0 ),
        .I3(\axaddr_wrap_reg[11]_0 [5]),
        .O(\axaddr_wrap[7]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[8]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [8]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[11]_0 [8]),
        .I3(\axaddr_wrap[8]_i_2__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[8]),
        .O(\axaddr_wrap[8]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair154" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    \axaddr_wrap[8]_i_2__0 
       (.I0(\axaddr_wrap_reg[11]_0 [7]),
        .I1(\axaddr_wrap_reg[11]_0 [5]),
        .I2(\axaddr_wrap[4]_i_2__0_n_0 ),
        .I3(\axaddr_wrap_reg[11]_0 [4]),
        .I4(\axaddr_wrap_reg[11]_0 [6]),
        .O(\axaddr_wrap[8]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[9]_i_1 
       (.I0(\axlen_cnt_reg[3]_0 [9]),
        .I1(next_pending_r_reg_1),
        .I2(\axaddr_wrap_reg[11]_0 [9]),
        .I3(\axaddr_wrap[9]_i_2__0_n_0 ),
        .I4(\axaddr_wrap[11]_i_3_n_0 ),
        .I5(wrap_boundary_axaddr_r[9]),
        .O(\axaddr_wrap[9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \axaddr_wrap[9]_i_2__0 
       (.I0(\axaddr_wrap_reg[11]_0 [8]),
        .I1(\axaddr_wrap_reg[11]_0 [6]),
        .I2(\axaddr_wrap_reg[11]_0 [4]),
        .I3(\axaddr_wrap[4]_i_2__0_n_0 ),
        .I4(\axaddr_wrap_reg[11]_0 [5]),
        .I5(\axaddr_wrap_reg[11]_0 [7]),
        .O(\axaddr_wrap[9]_i_2__0_n_0 ));
  FDRE \axaddr_wrap_reg[0] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[0]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [0]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[10] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[10]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [10]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[11] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[11]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [11]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[1] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[1]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [1]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[2] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[2]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [2]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[3] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[3]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [3]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[4] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[4]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [4]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[5] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[5]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [5]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[6] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[6]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [6]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[7] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[7]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [7]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[8] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[8]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [8]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[9] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[9]_i_1_n_0 ),
        .Q(\axaddr_wrap_reg[11]_0 [9]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFFFF555400005554)) 
    \axlen_cnt[0]_i_1__0 
       (.I0(\axlen_cnt_reg_n_0_[0] ),
        .I1(\axlen_cnt_reg_n_0_[3] ),
        .I2(\axlen_cnt_reg_n_0_[1] ),
        .I3(\axlen_cnt_reg_n_0_[2] ),
        .I4(E),
        .I5(\axlen_cnt_reg[3]_0 [15]),
        .O(\axlen_cnt[0]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFA5A40000A5A4)) 
    \axlen_cnt[1]_i_1__0 
       (.I0(\axlen_cnt_reg_n_0_[0] ),
        .I1(\axlen_cnt_reg_n_0_[2] ),
        .I2(\axlen_cnt_reg_n_0_[1] ),
        .I3(\axlen_cnt_reg_n_0_[3] ),
        .I4(E),
        .I5(\axlen_cnt_reg[3]_0 [16]),
        .O(\axlen_cnt[1]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFC9C80000C9C8)) 
    \axlen_cnt[2]_i_1__0 
       (.I0(\axlen_cnt_reg_n_0_[0] ),
        .I1(\axlen_cnt_reg_n_0_[2] ),
        .I2(\axlen_cnt_reg_n_0_[1] ),
        .I3(\axlen_cnt_reg_n_0_[3] ),
        .I4(E),
        .I5(\axlen_cnt_reg[3]_0 [17]),
        .O(\axlen_cnt[2]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'hAAAACCCCAAAACCC0)) 
    \axlen_cnt[3]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [18]),
        .I1(\axlen_cnt_reg_n_0_[3] ),
        .I2(\axlen_cnt_reg_n_0_[1] ),
        .I3(\axlen_cnt_reg_n_0_[2] ),
        .I4(E),
        .I5(\axlen_cnt_reg_n_0_[0] ),
        .O(\axlen_cnt[3]_i_1__0_n_0 ));
  FDRE \axlen_cnt_reg[0] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axlen_cnt[0]_i_1__0_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[1] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axlen_cnt[1]_i_1__0_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[1] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[2] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axlen_cnt[2]_i_1__0_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[3] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axlen_cnt[3]_i_1__0_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[3] ),
        .R(1'b0));
  LUT5 #(
    .INIT(32'hCFCAC0CA)) 
    next_pending_r_i_1__0
       (.I0(next_pending_r_i_2_n_0),
        .I1(next_pending_r_reg_0),
        .I2(E),
        .I3(next_pending_r_reg_1),
        .I4(next_pending_r_reg_n_0),
        .O(wrap_next_pending));
  LUT6 #(
    .INIT(64'hFEFEFEFEFE00FEFE)) 
    next_pending_r_i_2
       (.I0(\axlen_cnt_reg_n_0_[3] ),
        .I1(\axlen_cnt_reg_n_0_[1] ),
        .I2(\axlen_cnt_reg_n_0_[2] ),
        .I3(Q[0]),
        .I4(si_rs_awvalid),
        .I5(Q[1]),
        .O(next_pending_r_i_2_n_0));
  FDRE next_pending_r_reg
       (.C(aclk),
        .CE(1'b1),
        .D(wrap_next_pending),
        .Q(next_pending_r_reg_n_0),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair156" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    s_axburst_eq0_i_1
       (.I0(wrap_next_pending),
        .I1(\axlen_cnt_reg[3]_0 [14]),
        .I2(sel_first_i),
        .I3(incr_next_pending),
        .O(\m_payload_i_reg[47] ));
  (* SOFT_HLUTNM = "soft_lutpair156" *) 
  LUT4 #(
    .INIT(16'hABA8)) 
    s_axburst_eq1_i_1
       (.I0(wrap_next_pending),
        .I1(\axlen_cnt_reg[3]_0 [14]),
        .I2(sel_first_i),
        .I3(incr_next_pending),
        .O(\m_payload_i_reg[47]_0 ));
  FDRE sel_first_reg
       (.C(aclk),
        .CE(1'b1),
        .D(sel_first_reg_0),
        .Q(sel_first__0),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [0]),
        .Q(wrap_boundary_axaddr_r[0]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[10] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [10]),
        .Q(wrap_boundary_axaddr_r[10]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[11] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [11]),
        .Q(wrap_boundary_axaddr_r[11]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [1]),
        .Q(wrap_boundary_axaddr_r[1]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[2] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [2]),
        .Q(wrap_boundary_axaddr_r[2]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[3] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [3]),
        .Q(wrap_boundary_axaddr_r[3]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[4] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [4]),
        .Q(wrap_boundary_axaddr_r[4]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[5] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [5]),
        .Q(wrap_boundary_axaddr_r[5]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[6] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [6]),
        .Q(wrap_boundary_axaddr_r[6]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[7] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [7]),
        .Q(wrap_boundary_axaddr_r[7]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[8] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [8]),
        .Q(wrap_boundary_axaddr_r[8]),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[9] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [9]),
        .Q(wrap_boundary_axaddr_r[9]),
        .R(1'b0));
  FDRE \wrap_cnt_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_cnt_r_reg[3]_0 [0]),
        .Q(wrap_cnt_r[0]),
        .R(1'b0));
  FDRE \wrap_cnt_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_cnt_r_reg[3]_0 [1]),
        .Q(wrap_cnt_r[1]),
        .R(1'b0));
  FDRE \wrap_cnt_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_cnt_r_reg[3]_0 [2]),
        .Q(wrap_cnt_r[2]),
        .R(1'b0));
  FDRE \wrap_cnt_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_cnt_r_reg[3]_0 [3]),
        .Q(wrap_cnt_r[3]),
        .R(1'b0));
  FDRE \wrap_second_len_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_second_len_r_reg[3]_1 [0]),
        .Q(\wrap_second_len_r_reg[3]_0 [0]),
        .R(1'b0));
  FDRE \wrap_second_len_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_second_len_r_reg[3]_1 [1]),
        .Q(\wrap_second_len_r_reg[3]_0 [1]),
        .R(1'b0));
  FDRE \wrap_second_len_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_second_len_r_reg[3]_1 [2]),
        .Q(\wrap_second_len_r_reg[3]_0 [2]),
        .R(1'b0));
  FDRE \wrap_second_len_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_second_len_r_reg[3]_1 [3]),
        .Q(\wrap_second_len_r_reg[3]_0 [3]),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "axi_protocol_converter_v2_1_20_b2s_wrap_cmd" *) 
module zynqmpsoc_auto_pc_0_axi_protocol_converter_v2_1_20_b2s_wrap_cmd_3
   (sel_first_reg_0,
    next_pending_r_reg_0,
    Q,
    \axaddr_offset_r_reg[3]_0 ,
    \wrap_second_len_r_reg[3]_0 ,
    wrap_next_pending,
    aclk,
    sel_first_reg_1,
    E,
    \axlen_cnt_reg[3]_0 ,
    \axaddr_wrap_reg[11]_0 ,
    \axaddr_wrap_reg[3]_0 ,
    \axaddr_wrap_reg[2]_0 ,
    \axaddr_wrap_reg[1]_0 ,
    \axaddr_wrap_reg[0]_0 ,
    \axaddr_offset_r_reg[3]_1 ,
    \wrap_second_len_r_reg[3]_1 ,
    \axaddr_wrap_reg[0]_1 ,
    \wrap_cnt_r_reg[3]_0 ,
    \wrap_boundary_axaddr_r_reg[6]_0 );
  output sel_first_reg_0;
  output next_pending_r_reg_0;
  output [11:0]Q;
  output [3:0]\axaddr_offset_r_reg[3]_0 ;
  output [3:0]\wrap_second_len_r_reg[3]_0 ;
  input wrap_next_pending;
  input aclk;
  input sel_first_reg_1;
  input [0:0]E;
  input [17:0]\axlen_cnt_reg[3]_0 ;
  input \axaddr_wrap_reg[11]_0 ;
  input \axaddr_wrap_reg[3]_0 ;
  input \axaddr_wrap_reg[2]_0 ;
  input \axaddr_wrap_reg[1]_0 ;
  input \axaddr_wrap_reg[0]_0 ;
  input [3:0]\axaddr_offset_r_reg[3]_1 ;
  input [3:0]\wrap_second_len_r_reg[3]_1 ;
  input [0:0]\axaddr_wrap_reg[0]_1 ;
  input [3:0]\wrap_cnt_r_reg[3]_0 ;
  input [6:0]\wrap_boundary_axaddr_r_reg[6]_0 ;

  wire [0:0]E;
  wire [11:0]Q;
  wire aclk;
  wire [3:0]\axaddr_offset_r_reg[3]_0 ;
  wire [3:0]\axaddr_offset_r_reg[3]_1 ;
  wire \axaddr_wrap[0]_i_1__0_n_0 ;
  wire \axaddr_wrap[10]_i_1__0_n_0 ;
  wire \axaddr_wrap[10]_i_2_n_0 ;
  wire \axaddr_wrap[11]_i_1__0_n_0 ;
  wire \axaddr_wrap[11]_i_2_n_0 ;
  wire \axaddr_wrap[11]_i_3__0_n_0 ;
  wire \axaddr_wrap[11]_i_4__0_n_0 ;
  wire \axaddr_wrap[1]_i_1__0_n_0 ;
  wire \axaddr_wrap[2]_i_1__0_n_0 ;
  wire \axaddr_wrap[2]_i_3_n_0 ;
  wire \axaddr_wrap[3]_i_1__0_n_0 ;
  wire \axaddr_wrap[3]_i_3_n_0 ;
  wire \axaddr_wrap[4]_i_1__0_n_0 ;
  wire \axaddr_wrap[4]_i_2_n_0 ;
  wire \axaddr_wrap[5]_i_1__0_n_0 ;
  wire \axaddr_wrap[5]_i_2_n_0 ;
  wire \axaddr_wrap[6]_i_1__0_n_0 ;
  wire \axaddr_wrap[6]_i_2_n_0 ;
  wire \axaddr_wrap[7]_i_1__0_n_0 ;
  wire \axaddr_wrap[7]_i_2_n_0 ;
  wire \axaddr_wrap[8]_i_1__0_n_0 ;
  wire \axaddr_wrap[8]_i_2_n_0 ;
  wire \axaddr_wrap[9]_i_1__0_n_0 ;
  wire \axaddr_wrap[9]_i_2_n_0 ;
  wire \axaddr_wrap_reg[0]_0 ;
  wire [0:0]\axaddr_wrap_reg[0]_1 ;
  wire \axaddr_wrap_reg[11]_0 ;
  wire \axaddr_wrap_reg[1]_0 ;
  wire \axaddr_wrap_reg[2]_0 ;
  wire \axaddr_wrap_reg[3]_0 ;
  wire \axlen_cnt[0]_i_1__1_n_0 ;
  wire \axlen_cnt[1]_i_1__2_n_0 ;
  wire \axlen_cnt[2]_i_1__1_n_0 ;
  wire \axlen_cnt[3]_i_1__1_n_0 ;
  wire [17:0]\axlen_cnt_reg[3]_0 ;
  wire \axlen_cnt_reg_n_0_[0] ;
  wire \axlen_cnt_reg_n_0_[1] ;
  wire \axlen_cnt_reg_n_0_[2] ;
  wire \axlen_cnt_reg_n_0_[3] ;
  wire next_pending_r_reg_0;
  wire next_pending_r_reg_n_0;
  wire sel_first_reg_0;
  wire sel_first_reg_1;
  wire [6:0]\wrap_boundary_axaddr_r_reg[6]_0 ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[0] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[10] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[11] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[1] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[2] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[3] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[4] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[5] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[6] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[7] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[8] ;
  wire \wrap_boundary_axaddr_r_reg_n_0_[9] ;
  wire [3:0]\wrap_cnt_r_reg[3]_0 ;
  wire \wrap_cnt_r_reg_n_0_[0] ;
  wire \wrap_cnt_r_reg_n_0_[1] ;
  wire \wrap_cnt_r_reg_n_0_[2] ;
  wire \wrap_cnt_r_reg_n_0_[3] ;
  wire wrap_next_pending;
  wire [3:0]\wrap_second_len_r_reg[3]_0 ;
  wire [3:0]\wrap_second_len_r_reg[3]_1 ;

  FDRE \axaddr_offset_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\axaddr_offset_r_reg[3]_1 [0]),
        .Q(\axaddr_offset_r_reg[3]_0 [0]),
        .R(1'b0));
  FDRE \axaddr_offset_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\axaddr_offset_r_reg[3]_1 [1]),
        .Q(\axaddr_offset_r_reg[3]_0 [1]),
        .R(1'b0));
  FDRE \axaddr_offset_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(\axaddr_offset_r_reg[3]_1 [2]),
        .Q(\axaddr_offset_r_reg[3]_0 [2]),
        .R(1'b0));
  FDRE \axaddr_offset_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(\axaddr_offset_r_reg[3]_1 [3]),
        .Q(\axaddr_offset_r_reg[3]_0 [3]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[0]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [0]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(\axaddr_wrap_reg[0]_0 ),
        .I3(Q[0]),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[0] ),
        .O(\axaddr_wrap[0]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[10]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [10]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(Q[10]),
        .I3(\axaddr_wrap[10]_i_2_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[10] ),
        .O(\axaddr_wrap[10]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \axaddr_wrap[10]_i_2 
       (.I0(Q[9]),
        .I1(Q[7]),
        .I2(Q[5]),
        .I3(\axaddr_wrap[5]_i_2_n_0 ),
        .I4(Q[6]),
        .I5(Q[8]),
        .O(\axaddr_wrap[10]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[11]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [11]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(Q[11]),
        .I3(\axaddr_wrap[11]_i_2_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[11] ),
        .O(\axaddr_wrap[11]_i_1__0_n_0 ));
  LUT3 #(
    .INIT(8'h80)) 
    \axaddr_wrap[11]_i_2 
       (.I0(Q[10]),
        .I1(\axaddr_wrap[9]_i_2_n_0 ),
        .I2(Q[9]),
        .O(\axaddr_wrap[11]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h41)) 
    \axaddr_wrap[11]_i_3__0 
       (.I0(\axaddr_wrap[11]_i_4__0_n_0 ),
        .I1(\wrap_cnt_r_reg_n_0_[3] ),
        .I2(\axlen_cnt_reg_n_0_[3] ),
        .O(\axaddr_wrap[11]_i_3__0_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \axaddr_wrap[11]_i_4__0 
       (.I0(\axlen_cnt_reg_n_0_[1] ),
        .I1(\wrap_cnt_r_reg_n_0_[1] ),
        .I2(\axlen_cnt_reg_n_0_[2] ),
        .I3(\wrap_cnt_r_reg_n_0_[2] ),
        .I4(\wrap_cnt_r_reg_n_0_[0] ),
        .I5(\axlen_cnt_reg_n_0_[0] ),
        .O(\axaddr_wrap[11]_i_4__0_n_0 ));
  LUT6 #(
    .INIT(64'hB8BBB888B888B8BB)) 
    \axaddr_wrap[1]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [1]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(\wrap_boundary_axaddr_r_reg_n_0_[1] ),
        .I3(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I4(\axaddr_wrap_reg[1]_0 ),
        .I5(Q[1]),
        .O(\axaddr_wrap[1]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[2]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [2]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(\axaddr_wrap_reg[2]_0 ),
        .I3(\axaddr_wrap[2]_i_3_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[2] ),
        .O(\axaddr_wrap[2]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h0A08)) 
    \axaddr_wrap[2]_i_3 
       (.I0(Q[1]),
        .I1(\axlen_cnt_reg[3]_0 [12]),
        .I2(\axlen_cnt_reg[3]_0 [13]),
        .I3(Q[0]),
        .O(\axaddr_wrap[2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[3]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [3]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(\axaddr_wrap_reg[3]_0 ),
        .I3(\axaddr_wrap[3]_i_3_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[3] ),
        .O(\axaddr_wrap[3]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT5 #(
    .INIT(32'h3A380000)) 
    \axaddr_wrap[3]_i_3 
       (.I0(Q[1]),
        .I1(\axlen_cnt_reg[3]_0 [12]),
        .I2(\axlen_cnt_reg[3]_0 [13]),
        .I3(Q[0]),
        .I4(Q[2]),
        .O(\axaddr_wrap[3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[4]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [4]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(Q[4]),
        .I3(\axaddr_wrap[4]_i_2_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[4] ),
        .O(\axaddr_wrap[4]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'hFAF8C0C000000000)) 
    \axaddr_wrap[4]_i_2 
       (.I0(Q[1]),
        .I1(\axlen_cnt_reg[3]_0 [12]),
        .I2(\axlen_cnt_reg[3]_0 [13]),
        .I3(Q[0]),
        .I4(Q[2]),
        .I5(Q[3]),
        .O(\axaddr_wrap[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[5]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [5]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(Q[5]),
        .I3(\axaddr_wrap[5]_i_2_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[5] ),
        .O(\axaddr_wrap[5]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'h8888808080008000)) 
    \axaddr_wrap[5]_i_2 
       (.I0(Q[4]),
        .I1(Q[3]),
        .I2(Q[2]),
        .I3(\axaddr_wrap[2]_i_3_n_0 ),
        .I4(\axlen_cnt_reg[3]_0 [12]),
        .I5(\axlen_cnt_reg[3]_0 [13]),
        .O(\axaddr_wrap[5]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[6]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [6]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(Q[6]),
        .I3(\axaddr_wrap[6]_i_2_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[6] ),
        .O(\axaddr_wrap[6]_i_1__0_n_0 ));
  LUT3 #(
    .INIT(8'h80)) 
    \axaddr_wrap[6]_i_2 
       (.I0(Q[5]),
        .I1(\axaddr_wrap[4]_i_2_n_0 ),
        .I2(Q[4]),
        .O(\axaddr_wrap[6]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[7]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [7]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(Q[7]),
        .I3(\axaddr_wrap[7]_i_2_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[7] ),
        .O(\axaddr_wrap[7]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \axaddr_wrap[7]_i_2 
       (.I0(Q[6]),
        .I1(Q[4]),
        .I2(\axaddr_wrap[4]_i_2_n_0 ),
        .I3(Q[5]),
        .O(\axaddr_wrap[7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[8]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [8]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(Q[8]),
        .I3(\axaddr_wrap[8]_i_2_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[8] ),
        .O(\axaddr_wrap[8]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    \axaddr_wrap[8]_i_2 
       (.I0(Q[7]),
        .I1(Q[5]),
        .I2(\axaddr_wrap[4]_i_2_n_0 ),
        .I3(Q[4]),
        .I4(Q[6]),
        .O(\axaddr_wrap[8]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8BB888888BB8)) 
    \axaddr_wrap[9]_i_1__0 
       (.I0(\axlen_cnt_reg[3]_0 [9]),
        .I1(\axaddr_wrap_reg[11]_0 ),
        .I2(Q[9]),
        .I3(\axaddr_wrap[9]_i_2_n_0 ),
        .I4(\axaddr_wrap[11]_i_3__0_n_0 ),
        .I5(\wrap_boundary_axaddr_r_reg_n_0_[9] ),
        .O(\axaddr_wrap[9]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \axaddr_wrap[9]_i_2 
       (.I0(Q[8]),
        .I1(Q[6]),
        .I2(Q[4]),
        .I3(\axaddr_wrap[4]_i_2_n_0 ),
        .I4(Q[5]),
        .I5(Q[7]),
        .O(\axaddr_wrap[9]_i_2_n_0 ));
  FDRE \axaddr_wrap_reg[0] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[0]_i_1__0_n_0 ),
        .Q(Q[0]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[10] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[10]_i_1__0_n_0 ),
        .Q(Q[10]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[11] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[11]_i_1__0_n_0 ),
        .Q(Q[11]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[1] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[1]_i_1__0_n_0 ),
        .Q(Q[1]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[2] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[2]_i_1__0_n_0 ),
        .Q(Q[2]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[3] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[3]_i_1__0_n_0 ),
        .Q(Q[3]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[4] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[4]_i_1__0_n_0 ),
        .Q(Q[4]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[5] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[5]_i_1__0_n_0 ),
        .Q(Q[5]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[6] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[6]_i_1__0_n_0 ),
        .Q(Q[6]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[7] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[7]_i_1__0_n_0 ),
        .Q(Q[7]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[8] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[8]_i_1__0_n_0 ),
        .Q(Q[8]),
        .R(1'b0));
  FDRE \axaddr_wrap_reg[9] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axaddr_wrap[9]_i_1__0_n_0 ),
        .Q(Q[9]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFFFF555400005554)) 
    \axlen_cnt[0]_i_1__1 
       (.I0(\axlen_cnt_reg_n_0_[0] ),
        .I1(\axlen_cnt_reg_n_0_[3] ),
        .I2(\axlen_cnt_reg_n_0_[1] ),
        .I3(\axlen_cnt_reg_n_0_[2] ),
        .I4(E),
        .I5(\axlen_cnt_reg[3]_0 [14]),
        .O(\axlen_cnt[0]_i_1__1_n_0 ));
  LUT6 #(
    .INIT(64'hB8B88B8BB8B88B88)) 
    \axlen_cnt[1]_i_1__2 
       (.I0(\axlen_cnt_reg[3]_0 [15]),
        .I1(E),
        .I2(\axlen_cnt_reg_n_0_[0] ),
        .I3(\axlen_cnt_reg_n_0_[3] ),
        .I4(\axlen_cnt_reg_n_0_[1] ),
        .I5(\axlen_cnt_reg_n_0_[2] ),
        .O(\axlen_cnt[1]_i_1__2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBB8888BB8888B8)) 
    \axlen_cnt[2]_i_1__1 
       (.I0(\axlen_cnt_reg[3]_0 [16]),
        .I1(E),
        .I2(\axlen_cnt_reg_n_0_[3] ),
        .I3(\axlen_cnt_reg_n_0_[1] ),
        .I4(\axlen_cnt_reg_n_0_[2] ),
        .I5(\axlen_cnt_reg_n_0_[0] ),
        .O(\axlen_cnt[2]_i_1__1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAFFFCAAAA0000)) 
    \axlen_cnt[3]_i_1__1 
       (.I0(\axlen_cnt_reg[3]_0 [17]),
        .I1(\axlen_cnt_reg_n_0_[1] ),
        .I2(\axlen_cnt_reg_n_0_[0] ),
        .I3(\axlen_cnt_reg_n_0_[2] ),
        .I4(E),
        .I5(\axlen_cnt_reg_n_0_[3] ),
        .O(\axlen_cnt[3]_i_1__1_n_0 ));
  FDRE \axlen_cnt_reg[0] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axlen_cnt[0]_i_1__1_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[1] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axlen_cnt[1]_i_1__2_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[1] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[2] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axlen_cnt[2]_i_1__1_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \axlen_cnt_reg[3] 
       (.C(aclk),
        .CE(\axaddr_wrap_reg[0]_1 ),
        .D(\axlen_cnt[3]_i_1__1_n_0 ),
        .Q(\axlen_cnt_reg_n_0_[3] ),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h2222222233333330)) 
    next_pending_r_i_2__1
       (.I0(next_pending_r_reg_n_0),
        .I1(E),
        .I2(\axlen_cnt_reg_n_0_[2] ),
        .I3(\axlen_cnt_reg_n_0_[1] ),
        .I4(\axlen_cnt_reg_n_0_[3] ),
        .I5(\axaddr_wrap_reg[11]_0 ),
        .O(next_pending_r_reg_0));
  FDRE next_pending_r_reg
       (.C(aclk),
        .CE(1'b1),
        .D(wrap_next_pending),
        .Q(next_pending_r_reg_n_0),
        .R(1'b0));
  FDRE sel_first_reg
       (.C(aclk),
        .CE(1'b1),
        .D(sel_first_reg_1),
        .Q(sel_first_reg_0),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [0]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[10] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [10]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[10] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[11] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [11]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[11] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [1]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[1] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[2] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [2]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[3] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [3]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[3] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[4] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [4]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[4] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[5] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [5]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[5] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[6] 
       (.C(aclk),
        .CE(E),
        .D(\wrap_boundary_axaddr_r_reg[6]_0 [6]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[6] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[7] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [7]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[7] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[8] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [8]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[8] ),
        .R(1'b0));
  FDRE \wrap_boundary_axaddr_r_reg[9] 
       (.C(aclk),
        .CE(E),
        .D(\axlen_cnt_reg[3]_0 [9]),
        .Q(\wrap_boundary_axaddr_r_reg_n_0_[9] ),
        .R(1'b0));
  FDRE \wrap_cnt_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_cnt_r_reg[3]_0 [0]),
        .Q(\wrap_cnt_r_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \wrap_cnt_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_cnt_r_reg[3]_0 [1]),
        .Q(\wrap_cnt_r_reg_n_0_[1] ),
        .R(1'b0));
  FDRE \wrap_cnt_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_cnt_r_reg[3]_0 [2]),
        .Q(\wrap_cnt_r_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \wrap_cnt_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_cnt_r_reg[3]_0 [3]),
        .Q(\wrap_cnt_r_reg_n_0_[3] ),
        .R(1'b0));
  FDRE \wrap_second_len_r_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_second_len_r_reg[3]_1 [0]),
        .Q(\wrap_second_len_r_reg[3]_0 [0]),
        .R(1'b0));
  FDRE \wrap_second_len_r_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_second_len_r_reg[3]_1 [1]),
        .Q(\wrap_second_len_r_reg[3]_0 [1]),
        .R(1'b0));
  FDRE \wrap_second_len_r_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_second_len_r_reg[3]_1 [2]),
        .Q(\wrap_second_len_r_reg[3]_0 [2]),
        .R(1'b0));
  FDRE \wrap_second_len_r_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(\wrap_second_len_r_reg[3]_1 [3]),
        .Q(\wrap_second_len_r_reg[3]_0 [3]),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "axi_register_slice_v2_1_20_axi_register_slice" *) 
module zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axi_register_slice
   (s_ready_i_reg,
    s_ready_i_reg_0,
    si_rs_awvalid,
    m_valid_i_reg,
    si_rs_bready,
    si_rs_arvalid,
    m_valid_i_reg_0,
    aresetn_0,
    \m_payload_i_reg[6] ,
    \m_payload_i_reg[76] ,
    \m_payload_i_reg[43] ,
    \m_payload_i_reg[43]_0 ,
    D,
    \m_payload_i_reg[52] ,
    \m_payload_i_reg[11] ,
    \m_payload_i_reg[43]_1 ,
    \m_payload_i_reg[3] ,
    \m_payload_i_reg[3]_0 ,
    \m_payload_i_reg[8] ,
    \m_payload_i_reg[1] ,
    \m_payload_i_reg[2] ,
    \m_payload_i_reg[54] ,
    \m_payload_i_reg[53] ,
    shandshake,
    \m_payload_i_reg[47] ,
    wrap_next_pending,
    \m_payload_i_reg[76]_0 ,
    \m_payload_i_reg[47]_0 ,
    \m_payload_i_reg[44] ,
    \m_payload_i_reg[55] ,
    \m_payload_i_reg[43]_2 ,
    \m_payload_i_reg[43]_3 ,
    \m_payload_i_reg[52]_0 ,
    \m_payload_i_reg[52]_1 ,
    \m_payload_i_reg[11]_0 ,
    \m_payload_i_reg[3]_1 ,
    \m_payload_i_reg[9] ,
    \m_payload_i_reg[7] ,
    \m_payload_i_reg[6]_0 ,
    \m_payload_i_reg[5] ,
    \m_payload_i_reg[44]_0 ,
    \m_payload_i_reg[2]_0 ,
    \m_payload_i_reg[1]_0 ,
    \m_payload_i_reg[56] ,
    s_ready_i_reg_1,
    \m_payload_i_reg[6]_1 ,
    \axaddr_wrap_reg[0] ,
    \m_payload_i_reg[43]_4 ,
    \m_payload_i_reg[6]_2 ,
    \axaddr_wrap_reg[2] ,
    \m_payload_i_reg[44]_1 ,
    \m_payload_i_reg[0] ,
    \axaddr_wrap_reg[0]_0 ,
    \m_payload_i_reg[2]_1 ,
    \axaddr_wrap_reg[3] ,
    \m_payload_i_reg[43]_5 ,
    \m_payload_i_reg[44]_2 ,
    \axaddr_wrap_reg[2]_0 ,
    \axaddr_wrap_reg[3]_0 ,
    \m_payload_i_reg[17] ,
    \m_payload_i_reg[50] ,
    aclk,
    b_push,
    s_axi_awvalid,
    s_axi_rready,
    m_valid_i_reg_1,
    si_rs_bvalid,
    s_axi_bready,
    Q,
    s_axi_arvalid,
    \axaddr_incr_reg[3] ,
    \axaddr_offset_r_reg[1] ,
    \axaddr_offset_r_reg[0] ,
    sel_first,
    \axaddr_incr_reg[10] ,
    \axaddr_incr_reg[3]_0 ,
    \axaddr_incr_reg[0] ,
    \axaddr_incr_reg[6] ,
    \axaddr_incr_reg[7] ,
    \axaddr_incr_reg[8] ,
    \axaddr_incr_reg[10]_0 ,
    \axaddr_incr_reg[11] ,
    \axaddr_incr_reg[11]_0 ,
    sel_first_i,
    incr_next_pending,
    next_pending_r_reg,
    next_pending_r_reg_0,
    \axaddr_offset_r_reg[0]_0 ,
    sel_first_0,
    \axaddr_incr_reg[11]_1 ,
    \axaddr_incr_reg[3]_1 ,
    m_axi_arready,
    \axaddr_incr_reg[6]_0 ,
    \axaddr_incr_reg[11]_2 ,
    \axaddr_incr_reg[0]_0 ,
    \axaddr_wrap_reg[3]_1 ,
    s_axi_awid,
    s_axi_awlen,
    s_axi_awburst,
    s_axi_awsize,
    s_axi_awprot,
    s_axi_awaddr,
    \axaddr_wrap_reg[3]_2 ,
    s_axi_arid,
    s_axi_arlen,
    s_axi_arburst,
    s_axi_arsize,
    s_axi_arprot,
    s_axi_araddr,
    out,
    \skid_buffer_reg[1] ,
    \skid_buffer_reg[50] ,
    \skid_buffer_reg[33] ,
    aresetn,
    E,
    \m_payload_i_reg[0]_0 );
  output s_ready_i_reg;
  output s_ready_i_reg_0;
  output si_rs_awvalid;
  output m_valid_i_reg;
  output si_rs_bready;
  output si_rs_arvalid;
  output m_valid_i_reg_0;
  output aresetn_0;
  output \m_payload_i_reg[6] ;
  output [70:0]\m_payload_i_reg[76] ;
  output \m_payload_i_reg[43] ;
  output \m_payload_i_reg[43]_0 ;
  output [0:0]D;
  output \m_payload_i_reg[52] ;
  output [7:0]\m_payload_i_reg[11] ;
  output \m_payload_i_reg[43]_1 ;
  output \m_payload_i_reg[3] ;
  output \m_payload_i_reg[3]_0 ;
  output \m_payload_i_reg[8] ;
  output \m_payload_i_reg[1] ;
  output \m_payload_i_reg[2] ;
  output \m_payload_i_reg[54] ;
  output \m_payload_i_reg[53] ;
  output shandshake;
  output \m_payload_i_reg[47] ;
  output wrap_next_pending;
  output [70:0]\m_payload_i_reg[76]_0 ;
  output \m_payload_i_reg[47]_0 ;
  output \m_payload_i_reg[44] ;
  output \m_payload_i_reg[55] ;
  output \m_payload_i_reg[43]_2 ;
  output \m_payload_i_reg[43]_3 ;
  output [0:0]\m_payload_i_reg[52]_0 ;
  output \m_payload_i_reg[52]_1 ;
  output [4:0]\m_payload_i_reg[11]_0 ;
  output \m_payload_i_reg[3]_1 ;
  output \m_payload_i_reg[9] ;
  output \m_payload_i_reg[7] ;
  output \m_payload_i_reg[6]_0 ;
  output \m_payload_i_reg[5] ;
  output \m_payload_i_reg[44]_0 ;
  output \m_payload_i_reg[2]_0 ;
  output \m_payload_i_reg[1]_0 ;
  output \m_payload_i_reg[56] ;
  output s_ready_i_reg_1;
  output [6:0]\m_payload_i_reg[6]_1 ;
  output \axaddr_wrap_reg[0] ;
  output \m_payload_i_reg[43]_4 ;
  output [6:0]\m_payload_i_reg[6]_2 ;
  output \axaddr_wrap_reg[2] ;
  output \m_payload_i_reg[44]_1 ;
  output \m_payload_i_reg[0] ;
  output \axaddr_wrap_reg[0]_0 ;
  output \m_payload_i_reg[2]_1 ;
  output \axaddr_wrap_reg[3] ;
  output \m_payload_i_reg[43]_5 ;
  output \m_payload_i_reg[44]_2 ;
  output \axaddr_wrap_reg[2]_0 ;
  output \axaddr_wrap_reg[3]_0 ;
  output [17:0]\m_payload_i_reg[17] ;
  output [50:0]\m_payload_i_reg[50] ;
  input aclk;
  input b_push;
  input s_axi_awvalid;
  input s_axi_rready;
  input m_valid_i_reg_1;
  input si_rs_bvalid;
  input s_axi_bready;
  input [1:0]Q;
  input s_axi_arvalid;
  input [1:0]\axaddr_incr_reg[3] ;
  input \axaddr_offset_r_reg[1] ;
  input [0:0]\axaddr_offset_r_reg[0] ;
  input sel_first;
  input [6:0]\axaddr_incr_reg[10] ;
  input \axaddr_incr_reg[3]_0 ;
  input \axaddr_incr_reg[0] ;
  input \axaddr_incr_reg[6] ;
  input \axaddr_incr_reg[7] ;
  input \axaddr_incr_reg[8] ;
  input \axaddr_incr_reg[10]_0 ;
  input \axaddr_incr_reg[11] ;
  input \axaddr_incr_reg[11]_0 ;
  input sel_first_i;
  input incr_next_pending;
  input next_pending_r_reg;
  input next_pending_r_reg_0;
  input [0:0]\axaddr_offset_r_reg[0]_0 ;
  input sel_first_0;
  input [4:0]\axaddr_incr_reg[11]_1 ;
  input \axaddr_incr_reg[3]_1 ;
  input m_axi_arready;
  input \axaddr_incr_reg[6]_0 ;
  input \axaddr_incr_reg[11]_2 ;
  input \axaddr_incr_reg[0]_0 ;
  input [2:0]\axaddr_wrap_reg[3]_1 ;
  input [15:0]s_axi_awid;
  input [7:0]s_axi_awlen;
  input [1:0]s_axi_awburst;
  input [1:0]s_axi_awsize;
  input [2:0]s_axi_awprot;
  input [39:0]s_axi_awaddr;
  input [2:0]\axaddr_wrap_reg[3]_2 ;
  input [15:0]s_axi_arid;
  input [7:0]s_axi_arlen;
  input [1:0]s_axi_arburst;
  input [1:0]s_axi_arsize;
  input [2:0]s_axi_arprot;
  input [39:0]s_axi_araddr;
  input [15:0]out;
  input [1:0]\skid_buffer_reg[1] ;
  input [16:0]\skid_buffer_reg[50] ;
  input [33:0]\skid_buffer_reg[33] ;
  input aresetn;
  input [0:0]E;
  input [0:0]\m_payload_i_reg[0]_0 ;

  wire [0:0]D;
  wire [0:0]E;
  wire [1:0]Q;
  wire aclk;
  wire \ar.ar_pipe_n_2 ;
  wire aresetn;
  wire aresetn_0;
  wire \aw.aw_pipe_n_1 ;
  wire \aw.aw_pipe_n_3 ;
  wire \axaddr_incr_reg[0] ;
  wire \axaddr_incr_reg[0]_0 ;
  wire [6:0]\axaddr_incr_reg[10] ;
  wire \axaddr_incr_reg[10]_0 ;
  wire \axaddr_incr_reg[11] ;
  wire \axaddr_incr_reg[11]_0 ;
  wire [4:0]\axaddr_incr_reg[11]_1 ;
  wire \axaddr_incr_reg[11]_2 ;
  wire [1:0]\axaddr_incr_reg[3] ;
  wire \axaddr_incr_reg[3]_0 ;
  wire \axaddr_incr_reg[3]_1 ;
  wire \axaddr_incr_reg[6] ;
  wire \axaddr_incr_reg[6]_0 ;
  wire \axaddr_incr_reg[7] ;
  wire \axaddr_incr_reg[8] ;
  wire [0:0]\axaddr_offset_r_reg[0] ;
  wire [0:0]\axaddr_offset_r_reg[0]_0 ;
  wire \axaddr_offset_r_reg[1] ;
  wire \axaddr_wrap_reg[0] ;
  wire \axaddr_wrap_reg[0]_0 ;
  wire \axaddr_wrap_reg[2] ;
  wire \axaddr_wrap_reg[2]_0 ;
  wire \axaddr_wrap_reg[3] ;
  wire \axaddr_wrap_reg[3]_0 ;
  wire [2:0]\axaddr_wrap_reg[3]_1 ;
  wire [2:0]\axaddr_wrap_reg[3]_2 ;
  wire b_push;
  wire incr_next_pending;
  wire m_axi_arready;
  wire \m_payload_i_reg[0] ;
  wire [0:0]\m_payload_i_reg[0]_0 ;
  wire [7:0]\m_payload_i_reg[11] ;
  wire [4:0]\m_payload_i_reg[11]_0 ;
  wire [17:0]\m_payload_i_reg[17] ;
  wire \m_payload_i_reg[1] ;
  wire \m_payload_i_reg[1]_0 ;
  wire \m_payload_i_reg[2] ;
  wire \m_payload_i_reg[2]_0 ;
  wire \m_payload_i_reg[2]_1 ;
  wire \m_payload_i_reg[3] ;
  wire \m_payload_i_reg[3]_0 ;
  wire \m_payload_i_reg[3]_1 ;
  wire \m_payload_i_reg[43] ;
  wire \m_payload_i_reg[43]_0 ;
  wire \m_payload_i_reg[43]_1 ;
  wire \m_payload_i_reg[43]_2 ;
  wire \m_payload_i_reg[43]_3 ;
  wire \m_payload_i_reg[43]_4 ;
  wire \m_payload_i_reg[43]_5 ;
  wire \m_payload_i_reg[44] ;
  wire \m_payload_i_reg[44]_0 ;
  wire \m_payload_i_reg[44]_1 ;
  wire \m_payload_i_reg[44]_2 ;
  wire \m_payload_i_reg[47] ;
  wire \m_payload_i_reg[47]_0 ;
  wire [50:0]\m_payload_i_reg[50] ;
  wire \m_payload_i_reg[52] ;
  wire [0:0]\m_payload_i_reg[52]_0 ;
  wire \m_payload_i_reg[52]_1 ;
  wire \m_payload_i_reg[53] ;
  wire \m_payload_i_reg[54] ;
  wire \m_payload_i_reg[55] ;
  wire \m_payload_i_reg[56] ;
  wire \m_payload_i_reg[5] ;
  wire \m_payload_i_reg[6] ;
  wire \m_payload_i_reg[6]_0 ;
  wire [6:0]\m_payload_i_reg[6]_1 ;
  wire [6:0]\m_payload_i_reg[6]_2 ;
  wire [70:0]\m_payload_i_reg[76] ;
  wire [70:0]\m_payload_i_reg[76]_0 ;
  wire \m_payload_i_reg[7] ;
  wire \m_payload_i_reg[8] ;
  wire \m_payload_i_reg[9] ;
  wire m_valid_i_reg;
  wire m_valid_i_reg_0;
  wire m_valid_i_reg_1;
  wire next_pending_r_reg;
  wire next_pending_r_reg_0;
  wire [15:0]out;
  wire [39:0]s_axi_araddr;
  wire [1:0]s_axi_arburst;
  wire [15:0]s_axi_arid;
  wire [7:0]s_axi_arlen;
  wire [2:0]s_axi_arprot;
  wire [1:0]s_axi_arsize;
  wire s_axi_arvalid;
  wire [39:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [15:0]s_axi_awid;
  wire [7:0]s_axi_awlen;
  wire [2:0]s_axi_awprot;
  wire [1:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire s_axi_rready;
  wire s_ready_i_reg;
  wire s_ready_i_reg_0;
  wire s_ready_i_reg_1;
  wire sel_first;
  wire sel_first_0;
  wire sel_first_i;
  wire shandshake;
  wire si_rs_arvalid;
  wire si_rs_awvalid;
  wire si_rs_bready;
  wire si_rs_bvalid;
  wire [1:0]\skid_buffer_reg[1] ;
  wire [33:0]\skid_buffer_reg[33] ;
  wire [16:0]\skid_buffer_reg[50] ;
  wire wrap_next_pending;

  zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axic_register_slice \ar.ar_pipe 
       (.Q(Q),
        .aclk(aclk),
        .aresetn(aresetn),
        .aresetn_0(aresetn_0),
        .\aresetn_d_reg[1]_0 (\ar.ar_pipe_n_2 ),
        .\aresetn_d_reg[1]_1 (\aw.aw_pipe_n_3 ),
        .\axaddr_incr_reg[0] (\axaddr_incr_reg[0]_0 ),
        .\axaddr_incr_reg[11] (\axaddr_incr_reg[11]_1 ),
        .\axaddr_incr_reg[11]_0 (\axaddr_incr_reg[11]_2 ),
        .\axaddr_incr_reg[3] (\axaddr_incr_reg[3]_1 ),
        .\axaddr_incr_reg[6] (\axaddr_incr_reg[6]_0 ),
        .\axaddr_offset_r_reg[0] (\axaddr_offset_r_reg[0]_0 ),
        .\axaddr_wrap_reg[0] (\axaddr_wrap_reg[0] ),
        .\axaddr_wrap_reg[2] (\axaddr_wrap_reg[2]_0 ),
        .\axaddr_wrap_reg[3] (\axaddr_wrap_reg[3]_0 ),
        .\axaddr_wrap_reg[3]_0 (\axaddr_wrap_reg[3]_1 ),
        .incr_next_pending(incr_next_pending),
        .m_axi_arready(m_axi_arready),
        .\m_payload_i_reg[0]_0 (\m_payload_i_reg[0]_0 ),
        .\m_payload_i_reg[11]_0 (\m_payload_i_reg[11]_0 ),
        .\m_payload_i_reg[1]_0 (\m_payload_i_reg[1]_0 ),
        .\m_payload_i_reg[2]_0 (\m_payload_i_reg[2]_0 ),
        .\m_payload_i_reg[3]_0 (\m_payload_i_reg[3]_1 ),
        .\m_payload_i_reg[43]_0 (\m_payload_i_reg[43]_2 ),
        .\m_payload_i_reg[43]_1 (\m_payload_i_reg[43]_3 ),
        .\m_payload_i_reg[43]_2 (\m_payload_i_reg[43]_4 ),
        .\m_payload_i_reg[44]_0 (\m_payload_i_reg[44] ),
        .\m_payload_i_reg[44]_1 (\m_payload_i_reg[44]_0 ),
        .\m_payload_i_reg[47]_0 (\m_payload_i_reg[47] ),
        .\m_payload_i_reg[47]_1 (\m_payload_i_reg[47]_0 ),
        .\m_payload_i_reg[52]_0 (\m_payload_i_reg[52]_0 ),
        .\m_payload_i_reg[52]_1 (\m_payload_i_reg[52]_1 ),
        .\m_payload_i_reg[55]_0 (\m_payload_i_reg[55] ),
        .\m_payload_i_reg[56]_0 (\m_payload_i_reg[56] ),
        .\m_payload_i_reg[5]_0 (\m_payload_i_reg[5] ),
        .\m_payload_i_reg[6]_0 (\m_payload_i_reg[6]_0 ),
        .\m_payload_i_reg[6]_1 (\m_payload_i_reg[6]_1 ),
        .\m_payload_i_reg[76]_0 (\m_payload_i_reg[76]_0 ),
        .\m_payload_i_reg[7]_0 (\m_payload_i_reg[7] ),
        .\m_payload_i_reg[9]_0 (\m_payload_i_reg[9] ),
        .m_valid_i_reg_0(si_rs_arvalid),
        .next_pending_r_reg(next_pending_r_reg),
        .next_pending_r_reg_0(next_pending_r_reg_0),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arvalid(s_axi_arvalid),
        .s_ready_i_reg_0(s_ready_i_reg_0),
        .s_ready_i_reg_1(\aw.aw_pipe_n_1 ),
        .sel_first_0(sel_first_0),
        .sel_first_i(sel_first_i),
        .wrap_next_pending(wrap_next_pending));
  zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axic_register_slice_0 \aw.aw_pipe 
       (.D(D),
        .E(E),
        .Q(\m_payload_i_reg[76] ),
        .aclk(aclk),
        .\aresetn_d_reg[0]_0 (\aw.aw_pipe_n_1 ),
        .\aresetn_d_reg[0]_1 (\aw.aw_pipe_n_3 ),
        .\aresetn_d_reg[0]_2 (aresetn_0),
        .\axaddr_incr_reg[0] (\axaddr_incr_reg[0] ),
        .\axaddr_incr_reg[10] (\axaddr_incr_reg[10] ),
        .\axaddr_incr_reg[10]_0 (\axaddr_incr_reg[10]_0 ),
        .\axaddr_incr_reg[11] (\axaddr_incr_reg[11] ),
        .\axaddr_incr_reg[11]_0 (\axaddr_incr_reg[11]_0 ),
        .\axaddr_incr_reg[3] (\axaddr_incr_reg[3] ),
        .\axaddr_incr_reg[3]_0 (\axaddr_incr_reg[3]_0 ),
        .\axaddr_incr_reg[6] (\axaddr_incr_reg[6] ),
        .\axaddr_incr_reg[7] (\axaddr_incr_reg[7] ),
        .\axaddr_incr_reg[8] (\axaddr_incr_reg[8] ),
        .\axaddr_offset_r_reg[0] (\axaddr_offset_r_reg[0] ),
        .\axaddr_offset_r_reg[1] (\axaddr_offset_r_reg[1] ),
        .\axaddr_wrap_reg[0] (\axaddr_wrap_reg[0]_0 ),
        .\axaddr_wrap_reg[2] (\axaddr_wrap_reg[2] ),
        .\axaddr_wrap_reg[3] (\axaddr_wrap_reg[3] ),
        .\axaddr_wrap_reg[3]_0 (\axaddr_wrap_reg[3]_2 ),
        .b_push(b_push),
        .\m_payload_i_reg[0]_0 (\m_payload_i_reg[0] ),
        .\m_payload_i_reg[11]_0 (\m_payload_i_reg[11] ),
        .\m_payload_i_reg[1]_0 (\m_payload_i_reg[1] ),
        .\m_payload_i_reg[2]_0 (\m_payload_i_reg[2] ),
        .\m_payload_i_reg[2]_1 (\m_payload_i_reg[2]_1 ),
        .\m_payload_i_reg[3]_0 (\m_payload_i_reg[3] ),
        .\m_payload_i_reg[3]_1 (\m_payload_i_reg[3]_0 ),
        .\m_payload_i_reg[43]_0 (\m_payload_i_reg[43] ),
        .\m_payload_i_reg[43]_1 (\m_payload_i_reg[43]_0 ),
        .\m_payload_i_reg[43]_2 (\m_payload_i_reg[43]_1 ),
        .\m_payload_i_reg[43]_3 (\m_payload_i_reg[43]_5 ),
        .\m_payload_i_reg[44]_0 (\m_payload_i_reg[44]_1 ),
        .\m_payload_i_reg[44]_1 (\m_payload_i_reg[44]_2 ),
        .\m_payload_i_reg[52]_0 (\m_payload_i_reg[52] ),
        .\m_payload_i_reg[53]_0 (\m_payload_i_reg[53] ),
        .\m_payload_i_reg[54]_0 (\m_payload_i_reg[54] ),
        .\m_payload_i_reg[6]_0 (\m_payload_i_reg[6] ),
        .\m_payload_i_reg[6]_1 (\m_payload_i_reg[6]_2 ),
        .\m_payload_i_reg[8]_0 (\m_payload_i_reg[8] ),
        .m_valid_i_reg_0(si_rs_awvalid),
        .m_valid_i_reg_1(\ar.ar_pipe_n_2 ),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_ready_i_reg_0(s_ready_i_reg),
        .sel_first(sel_first));
  zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axic_register_slice__parameterized1 \b.b_pipe 
       (.aclk(aclk),
        .\m_payload_i_reg[17]_0 (\m_payload_i_reg[17] ),
        .m_valid_i_reg_0(m_valid_i_reg),
        .m_valid_i_reg_1(\ar.ar_pipe_n_2 ),
        .out(out),
        .s_axi_bready(s_axi_bready),
        .s_ready_i_reg_0(si_rs_bready),
        .s_ready_i_reg_1(\aw.aw_pipe_n_1 ),
        .shandshake(shandshake),
        .si_rs_bvalid(si_rs_bvalid),
        .\skid_buffer_reg[1]_0 (\skid_buffer_reg[1] ));
  zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axic_register_slice__parameterized2 \r.r_pipe 
       (.aclk(aclk),
        .\m_payload_i_reg[50]_0 (\m_payload_i_reg[50] ),
        .m_valid_i_reg_0(m_valid_i_reg_0),
        .m_valid_i_reg_1(\ar.ar_pipe_n_2 ),
        .m_valid_i_reg_2(m_valid_i_reg_1),
        .s_axi_rready(s_axi_rready),
        .s_ready_i_reg_0(s_ready_i_reg_1),
        .s_ready_i_reg_1(\aw.aw_pipe_n_1 ),
        .\skid_buffer_reg[33]_0 (\skid_buffer_reg[33] ),
        .\skid_buffer_reg[50]_0 (\skid_buffer_reg[50] ));
endmodule

(* ORIG_REF_NAME = "axi_register_slice_v2_1_20_axic_register_slice" *) 
module zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axic_register_slice
   (s_ready_i_reg_0,
    m_valid_i_reg_0,
    \aresetn_d_reg[1]_0 ,
    aresetn_0,
    \m_payload_i_reg[47]_0 ,
    wrap_next_pending,
    \m_payload_i_reg[76]_0 ,
    \m_payload_i_reg[47]_1 ,
    \m_payload_i_reg[44]_0 ,
    \m_payload_i_reg[55]_0 ,
    \m_payload_i_reg[43]_0 ,
    \m_payload_i_reg[43]_1 ,
    \m_payload_i_reg[52]_0 ,
    \m_payload_i_reg[52]_1 ,
    \m_payload_i_reg[11]_0 ,
    \m_payload_i_reg[3]_0 ,
    \m_payload_i_reg[9]_0 ,
    \m_payload_i_reg[7]_0 ,
    \m_payload_i_reg[6]_0 ,
    \m_payload_i_reg[5]_0 ,
    \m_payload_i_reg[44]_1 ,
    \m_payload_i_reg[2]_0 ,
    \m_payload_i_reg[1]_0 ,
    \m_payload_i_reg[56]_0 ,
    \m_payload_i_reg[6]_1 ,
    \axaddr_wrap_reg[0] ,
    \m_payload_i_reg[43]_2 ,
    \axaddr_wrap_reg[2] ,
    \axaddr_wrap_reg[3] ,
    s_ready_i_reg_1,
    aclk,
    \aresetn_d_reg[1]_1 ,
    Q,
    s_axi_arvalid,
    sel_first_i,
    incr_next_pending,
    next_pending_r_reg,
    next_pending_r_reg_0,
    \axaddr_offset_r_reg[0] ,
    sel_first_0,
    \axaddr_incr_reg[11] ,
    \axaddr_incr_reg[3] ,
    m_axi_arready,
    \axaddr_incr_reg[6] ,
    \axaddr_incr_reg[11]_0 ,
    \axaddr_incr_reg[0] ,
    \axaddr_wrap_reg[3]_0 ,
    s_axi_arid,
    s_axi_arlen,
    s_axi_arburst,
    s_axi_arsize,
    s_axi_arprot,
    s_axi_araddr,
    aresetn,
    \m_payload_i_reg[0]_0 );
  output s_ready_i_reg_0;
  output m_valid_i_reg_0;
  output \aresetn_d_reg[1]_0 ;
  output aresetn_0;
  output \m_payload_i_reg[47]_0 ;
  output wrap_next_pending;
  output [70:0]\m_payload_i_reg[76]_0 ;
  output \m_payload_i_reg[47]_1 ;
  output \m_payload_i_reg[44]_0 ;
  output \m_payload_i_reg[55]_0 ;
  output \m_payload_i_reg[43]_0 ;
  output \m_payload_i_reg[43]_1 ;
  output [0:0]\m_payload_i_reg[52]_0 ;
  output \m_payload_i_reg[52]_1 ;
  output [4:0]\m_payload_i_reg[11]_0 ;
  output \m_payload_i_reg[3]_0 ;
  output \m_payload_i_reg[9]_0 ;
  output \m_payload_i_reg[7]_0 ;
  output \m_payload_i_reg[6]_0 ;
  output \m_payload_i_reg[5]_0 ;
  output \m_payload_i_reg[44]_1 ;
  output \m_payload_i_reg[2]_0 ;
  output \m_payload_i_reg[1]_0 ;
  output \m_payload_i_reg[56]_0 ;
  output [6:0]\m_payload_i_reg[6]_1 ;
  output \axaddr_wrap_reg[0] ;
  output \m_payload_i_reg[43]_2 ;
  output \axaddr_wrap_reg[2] ;
  output \axaddr_wrap_reg[3] ;
  input s_ready_i_reg_1;
  input aclk;
  input \aresetn_d_reg[1]_1 ;
  input [1:0]Q;
  input s_axi_arvalid;
  input sel_first_i;
  input incr_next_pending;
  input next_pending_r_reg;
  input next_pending_r_reg_0;
  input [0:0]\axaddr_offset_r_reg[0] ;
  input sel_first_0;
  input [4:0]\axaddr_incr_reg[11] ;
  input \axaddr_incr_reg[3] ;
  input m_axi_arready;
  input \axaddr_incr_reg[6] ;
  input \axaddr_incr_reg[11]_0 ;
  input \axaddr_incr_reg[0] ;
  input [2:0]\axaddr_wrap_reg[3]_0 ;
  input [15:0]s_axi_arid;
  input [7:0]s_axi_arlen;
  input [1:0]s_axi_arburst;
  input [1:0]s_axi_arsize;
  input [2:0]s_axi_arprot;
  input [39:0]s_axi_araddr;
  input aresetn;
  input [0:0]\m_payload_i_reg[0]_0 ;

  wire [1:0]Q;
  wire aclk;
  wire aresetn;
  wire aresetn_0;
  wire \aresetn_d_reg[1]_0 ;
  wire \aresetn_d_reg[1]_1 ;
  wire \aresetn_d_reg_n_0_[1] ;
  wire \axaddr_incr[1]_i_2__0_n_0 ;
  wire \axaddr_incr[3]_i_2__0_n_0 ;
  wire \axaddr_incr[3]_i_3__0_n_0 ;
  wire \axaddr_incr[3]_i_4__0_n_0 ;
  wire \axaddr_incr_reg[0] ;
  wire [4:0]\axaddr_incr_reg[11] ;
  wire \axaddr_incr_reg[11]_0 ;
  wire \axaddr_incr_reg[3] ;
  wire \axaddr_incr_reg[6] ;
  wire \axaddr_offset_r[0]_i_3__0_n_0 ;
  wire \axaddr_offset_r[1]_i_3__0_n_0 ;
  wire \axaddr_offset_r[2]_i_3__0_n_0 ;
  wire \axaddr_offset_r[3]_i_3__0_n_0 ;
  wire [0:0]\axaddr_offset_r_reg[0] ;
  wire \axaddr_wrap_reg[0] ;
  wire \axaddr_wrap_reg[2] ;
  wire \axaddr_wrap_reg[3] ;
  wire [2:0]\axaddr_wrap_reg[3]_0 ;
  wire incr_next_pending;
  wire m_axi_arready;
  wire \m_payload_i[0]_i_1__0_n_0 ;
  wire \m_payload_i[10]_i_1__0_n_0 ;
  wire \m_payload_i[11]_i_1__0_n_0 ;
  wire \m_payload_i[12]_i_1__0_n_0 ;
  wire \m_payload_i[13]_i_1__0_n_0 ;
  wire \m_payload_i[14]_i_1__0_n_0 ;
  wire \m_payload_i[15]_i_1__0_n_0 ;
  wire \m_payload_i[16]_i_1__0_n_0 ;
  wire \m_payload_i[17]_i_1__1_n_0 ;
  wire \m_payload_i[18]_i_1__0_n_0 ;
  wire \m_payload_i[19]_i_1__0_n_0 ;
  wire \m_payload_i[1]_i_1__0_n_0 ;
  wire \m_payload_i[20]_i_1__0_n_0 ;
  wire \m_payload_i[21]_i_1__0_n_0 ;
  wire \m_payload_i[22]_i_1__0_n_0 ;
  wire \m_payload_i[23]_i_1__0_n_0 ;
  wire \m_payload_i[24]_i_1__0_n_0 ;
  wire \m_payload_i[25]_i_1__0_n_0 ;
  wire \m_payload_i[26]_i_1__0_n_0 ;
  wire \m_payload_i[27]_i_1__0_n_0 ;
  wire \m_payload_i[28]_i_1__0_n_0 ;
  wire \m_payload_i[29]_i_1__0_n_0 ;
  wire \m_payload_i[2]_i_1__0_n_0 ;
  wire \m_payload_i[30]_i_1__0_n_0 ;
  wire \m_payload_i[31]_i_1__0_n_0 ;
  wire \m_payload_i[32]_i_1__0_n_0 ;
  wire \m_payload_i[33]_i_1__0_n_0 ;
  wire \m_payload_i[34]_i_1__0_n_0 ;
  wire \m_payload_i[35]_i_1__0_n_0 ;
  wire \m_payload_i[36]_i_1__0_n_0 ;
  wire \m_payload_i[37]_i_1__0_n_0 ;
  wire \m_payload_i[38]_i_1__0_n_0 ;
  wire \m_payload_i[39]_i_2__0_n_0 ;
  wire \m_payload_i[3]_i_1__0_n_0 ;
  wire \m_payload_i[40]_i_1__0_n_0 ;
  wire \m_payload_i[41]_i_1__0_n_0 ;
  wire \m_payload_i[42]_i_1__0_n_0 ;
  wire \m_payload_i[43]_i_1__0_n_0 ;
  wire \m_payload_i[44]_i_1__0_n_0 ;
  wire \m_payload_i[46]_i_1__0_n_0 ;
  wire \m_payload_i[47]_i_1__0_n_0 ;
  wire \m_payload_i[4]_i_1__0_n_0 ;
  wire \m_payload_i[52]_i_1__0_n_0 ;
  wire \m_payload_i[53]_i_1__0_n_0 ;
  wire \m_payload_i[54]_i_1__0_n_0 ;
  wire \m_payload_i[55]_i_1__0_n_0 ;
  wire \m_payload_i[56]_i_1__0_n_0 ;
  wire \m_payload_i[57]_i_1__0_n_0 ;
  wire \m_payload_i[58]_i_1__0_n_0 ;
  wire \m_payload_i[59]_i_1__0_n_0 ;
  wire \m_payload_i[5]_i_1__0_n_0 ;
  wire \m_payload_i[61]_i_1__0_n_0 ;
  wire \m_payload_i[62]_i_1__0_n_0 ;
  wire \m_payload_i[63]_i_1__0_n_0 ;
  wire \m_payload_i[64]_i_1__0_n_0 ;
  wire \m_payload_i[65]_i_1__0_n_0 ;
  wire \m_payload_i[66]_i_1__0_n_0 ;
  wire \m_payload_i[67]_i_1__0_n_0 ;
  wire \m_payload_i[68]_i_1__0_n_0 ;
  wire \m_payload_i[69]_i_1__0_n_0 ;
  wire \m_payload_i[6]_i_1__0_n_0 ;
  wire \m_payload_i[70]_i_1__0_n_0 ;
  wire \m_payload_i[71]_i_1__0_n_0 ;
  wire \m_payload_i[72]_i_1__0_n_0 ;
  wire \m_payload_i[73]_i_1__0_n_0 ;
  wire \m_payload_i[74]_i_1__0_n_0 ;
  wire \m_payload_i[75]_i_1__0_n_0 ;
  wire \m_payload_i[76]_i_1__0_n_0 ;
  wire \m_payload_i[7]_i_1__0_n_0 ;
  wire \m_payload_i[8]_i_1__0_n_0 ;
  wire \m_payload_i[9]_i_1__0_n_0 ;
  wire [0:0]\m_payload_i_reg[0]_0 ;
  wire [4:0]\m_payload_i_reg[11]_0 ;
  wire \m_payload_i_reg[1]_0 ;
  wire \m_payload_i_reg[2]_0 ;
  wire \m_payload_i_reg[3]_0 ;
  wire \m_payload_i_reg[43]_0 ;
  wire \m_payload_i_reg[43]_1 ;
  wire \m_payload_i_reg[43]_2 ;
  wire \m_payload_i_reg[44]_0 ;
  wire \m_payload_i_reg[44]_1 ;
  wire \m_payload_i_reg[47]_0 ;
  wire \m_payload_i_reg[47]_1 ;
  wire [0:0]\m_payload_i_reg[52]_0 ;
  wire \m_payload_i_reg[52]_1 ;
  wire \m_payload_i_reg[55]_0 ;
  wire \m_payload_i_reg[56]_0 ;
  wire \m_payload_i_reg[5]_0 ;
  wire \m_payload_i_reg[6]_0 ;
  wire [6:0]\m_payload_i_reg[6]_1 ;
  wire [70:0]\m_payload_i_reg[76]_0 ;
  wire \m_payload_i_reg[7]_0 ;
  wire \m_payload_i_reg[9]_0 ;
  wire m_valid_i_i_1__2_n_0;
  wire m_valid_i_reg_0;
  wire next_pending_r_i_6__0_n_0;
  wire next_pending_r_reg;
  wire next_pending_r_reg_0;
  wire [39:0]s_axi_araddr;
  wire [1:0]s_axi_arburst;
  wire [15:0]s_axi_arid;
  wire [7:0]s_axi_arlen;
  wire [2:0]s_axi_arprot;
  wire [1:0]s_axi_arsize;
  wire s_axi_arvalid;
  wire s_ready_i0;
  wire s_ready_i_reg_0;
  wire s_ready_i_reg_1;
  wire sel_first_0;
  wire sel_first_i;
  wire \skid_buffer_reg_n_0_[0] ;
  wire \skid_buffer_reg_n_0_[10] ;
  wire \skid_buffer_reg_n_0_[11] ;
  wire \skid_buffer_reg_n_0_[12] ;
  wire \skid_buffer_reg_n_0_[13] ;
  wire \skid_buffer_reg_n_0_[14] ;
  wire \skid_buffer_reg_n_0_[15] ;
  wire \skid_buffer_reg_n_0_[16] ;
  wire \skid_buffer_reg_n_0_[17] ;
  wire \skid_buffer_reg_n_0_[18] ;
  wire \skid_buffer_reg_n_0_[19] ;
  wire \skid_buffer_reg_n_0_[1] ;
  wire \skid_buffer_reg_n_0_[20] ;
  wire \skid_buffer_reg_n_0_[21] ;
  wire \skid_buffer_reg_n_0_[22] ;
  wire \skid_buffer_reg_n_0_[23] ;
  wire \skid_buffer_reg_n_0_[24] ;
  wire \skid_buffer_reg_n_0_[25] ;
  wire \skid_buffer_reg_n_0_[26] ;
  wire \skid_buffer_reg_n_0_[27] ;
  wire \skid_buffer_reg_n_0_[28] ;
  wire \skid_buffer_reg_n_0_[29] ;
  wire \skid_buffer_reg_n_0_[2] ;
  wire \skid_buffer_reg_n_0_[30] ;
  wire \skid_buffer_reg_n_0_[31] ;
  wire \skid_buffer_reg_n_0_[32] ;
  wire \skid_buffer_reg_n_0_[33] ;
  wire \skid_buffer_reg_n_0_[34] ;
  wire \skid_buffer_reg_n_0_[35] ;
  wire \skid_buffer_reg_n_0_[36] ;
  wire \skid_buffer_reg_n_0_[37] ;
  wire \skid_buffer_reg_n_0_[38] ;
  wire \skid_buffer_reg_n_0_[39] ;
  wire \skid_buffer_reg_n_0_[3] ;
  wire \skid_buffer_reg_n_0_[40] ;
  wire \skid_buffer_reg_n_0_[41] ;
  wire \skid_buffer_reg_n_0_[42] ;
  wire \skid_buffer_reg_n_0_[43] ;
  wire \skid_buffer_reg_n_0_[44] ;
  wire \skid_buffer_reg_n_0_[46] ;
  wire \skid_buffer_reg_n_0_[47] ;
  wire \skid_buffer_reg_n_0_[4] ;
  wire \skid_buffer_reg_n_0_[52] ;
  wire \skid_buffer_reg_n_0_[53] ;
  wire \skid_buffer_reg_n_0_[54] ;
  wire \skid_buffer_reg_n_0_[55] ;
  wire \skid_buffer_reg_n_0_[56] ;
  wire \skid_buffer_reg_n_0_[57] ;
  wire \skid_buffer_reg_n_0_[58] ;
  wire \skid_buffer_reg_n_0_[59] ;
  wire \skid_buffer_reg_n_0_[5] ;
  wire \skid_buffer_reg_n_0_[61] ;
  wire \skid_buffer_reg_n_0_[62] ;
  wire \skid_buffer_reg_n_0_[63] ;
  wire \skid_buffer_reg_n_0_[64] ;
  wire \skid_buffer_reg_n_0_[65] ;
  wire \skid_buffer_reg_n_0_[66] ;
  wire \skid_buffer_reg_n_0_[67] ;
  wire \skid_buffer_reg_n_0_[68] ;
  wire \skid_buffer_reg_n_0_[69] ;
  wire \skid_buffer_reg_n_0_[6] ;
  wire \skid_buffer_reg_n_0_[70] ;
  wire \skid_buffer_reg_n_0_[71] ;
  wire \skid_buffer_reg_n_0_[72] ;
  wire \skid_buffer_reg_n_0_[73] ;
  wire \skid_buffer_reg_n_0_[74] ;
  wire \skid_buffer_reg_n_0_[75] ;
  wire \skid_buffer_reg_n_0_[76] ;
  wire \skid_buffer_reg_n_0_[7] ;
  wire \skid_buffer_reg_n_0_[8] ;
  wire \skid_buffer_reg_n_0_[9] ;
  wire \wrap_boundary_axaddr_r[3]_i_2__0_n_0 ;
  wire wrap_next_pending;

  LUT1 #(
    .INIT(2'h1)) 
    areset_d1_i_1
       (.I0(aresetn),
        .O(aresetn_0));
  FDRE #(
    .INIT(1'b0)) 
    \aresetn_d_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\aresetn_d_reg[1]_1 ),
        .Q(\aresetn_d_reg_n_0_[1] ),
        .R(aresetn_0));
  LUT6 #(
    .INIT(64'h0F000F000F00909F)) 
    \axaddr_incr[0]_i_1__0 
       (.I0(\m_payload_i_reg[76]_0 [0]),
        .I1(\axaddr_incr_reg[0] ),
        .I2(sel_first_0),
        .I3(\axaddr_incr_reg[11] [0]),
        .I4(\m_payload_i_reg[76]_0 [44]),
        .I5(\m_payload_i_reg[76]_0 [43]),
        .O(\m_payload_i_reg[11]_0 [0]));
  LUT6 #(
    .INIT(64'h6A006AFF6AFF6A00)) 
    \axaddr_incr[11]_i_2__0 
       (.I0(\m_payload_i_reg[76]_0 [11]),
        .I1(\m_payload_i_reg[9]_0 ),
        .I2(\m_payload_i_reg[76]_0 [10]),
        .I3(sel_first_0),
        .I4(\axaddr_incr_reg[11] [4]),
        .I5(\axaddr_incr_reg[11]_0 ),
        .O(\m_payload_i_reg[11]_0 [4]));
  LUT6 #(
    .INIT(64'h0080000000000000)) 
    \axaddr_incr[11]_i_3__0 
       (.I0(\m_payload_i_reg[76]_0 [9]),
        .I1(\m_payload_i_reg[76]_0 [8]),
        .I2(\m_payload_i_reg[76]_0 [6]),
        .I3(\m_payload_i_reg[3]_0 ),
        .I4(\m_payload_i_reg[76]_0 [5]),
        .I5(\m_payload_i_reg[76]_0 [7]),
        .O(\m_payload_i_reg[9]_0 ));
  LUT6 #(
    .INIT(64'hAEAEABABAEAEABAE)) 
    \axaddr_incr[1]_i_1__0 
       (.I0(\axaddr_incr[1]_i_2__0_n_0 ),
        .I1(\axaddr_incr_reg[11] [1]),
        .I2(sel_first_0),
        .I3(\m_payload_i_reg[76]_0 [43]),
        .I4(\m_payload_i_reg[76]_0 [44]),
        .I5(\axaddr_incr_reg[11] [0]),
        .O(\m_payload_i_reg[11]_0 [1]));
  LUT6 #(
    .INIT(64'h00CD000000320000)) 
    \axaddr_incr[1]_i_2__0 
       (.I0(\m_payload_i_reg[76]_0 [0]),
        .I1(\axaddr_incr_reg[0] ),
        .I2(\m_payload_i_reg[76]_0 [43]),
        .I3(\m_payload_i_reg[76]_0 [44]),
        .I4(sel_first_0),
        .I5(\m_payload_i_reg[76]_0 [1]),
        .O(\axaddr_incr[1]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'h0000AAAA6AAAAAAA)) 
    \axaddr_incr[2]_i_2__0 
       (.I0(\m_payload_i_reg[76]_0 [2]),
        .I1(m_axi_arready),
        .I2(Q[0]),
        .I3(Q[1]),
        .I4(\m_payload_i_reg[76]_0 [44]),
        .I5(\m_payload_i_reg[76]_0 [43]),
        .O(\m_payload_i_reg[2]_0 ));
  LUT5 #(
    .INIT(32'h00002220)) 
    \axaddr_incr[2]_i_3__0 
       (.I0(\m_payload_i_reg[76]_0 [1]),
        .I1(\axaddr_incr_reg[0] ),
        .I2(\m_payload_i_reg[76]_0 [0]),
        .I3(\m_payload_i_reg[76]_0 [43]),
        .I4(\m_payload_i_reg[76]_0 [44]),
        .O(\m_payload_i_reg[1]_0 ));
  LUT6 #(
    .INIT(64'h606F6F606F60606F)) 
    \axaddr_incr[3]_i_1__0 
       (.I0(\axaddr_incr[3]_i_2__0_n_0 ),
        .I1(\axaddr_incr[3]_i_3__0_n_0 ),
        .I2(sel_first_0),
        .I3(\axaddr_incr[3]_i_4__0_n_0 ),
        .I4(\axaddr_incr_reg[11] [2]),
        .I5(\axaddr_incr_reg[3] ),
        .O(\m_payload_i_reg[11]_0 [2]));
  LUT6 #(
    .INIT(64'h800000007FFFFFFF)) 
    \axaddr_incr[3]_i_2__0 
       (.I0(m_axi_arready),
        .I1(Q[0]),
        .I2(Q[1]),
        .I3(\m_payload_i_reg[76]_0 [43]),
        .I4(\m_payload_i_reg[76]_0 [44]),
        .I5(\m_payload_i_reg[76]_0 [3]),
        .O(\axaddr_incr[3]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'hF8FFF9FFFBFFFBFF)) 
    \axaddr_incr[3]_i_3__0 
       (.I0(\m_payload_i_reg[76]_0 [43]),
        .I1(\m_payload_i_reg[76]_0 [44]),
        .I2(\axaddr_incr_reg[0] ),
        .I3(\m_payload_i_reg[76]_0 [2]),
        .I4(\m_payload_i_reg[76]_0 [0]),
        .I5(\m_payload_i_reg[76]_0 [1]),
        .O(\axaddr_incr[3]_i_3__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \axaddr_incr[3]_i_4__0 
       (.I0(\m_payload_i_reg[76]_0 [43]),
        .I1(\m_payload_i_reg[76]_0 [44]),
        .O(\axaddr_incr[3]_i_4__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT5 #(
    .INIT(32'hF700FFF7)) 
    \axaddr_incr[4]_i_2__0 
       (.I0(\m_payload_i_reg[76]_0 [44]),
        .I1(\m_payload_i_reg[76]_0 [43]),
        .I2(\axaddr_incr_reg[0] ),
        .I3(\axaddr_incr[3]_i_3__0_n_0 ),
        .I4(\m_payload_i_reg[76]_0 [3]),
        .O(\m_payload_i_reg[44]_1 ));
  LUT6 #(
    .INIT(64'hA600A6FFA6FFA600)) 
    \axaddr_incr[6]_i_1__0 
       (.I0(\m_payload_i_reg[76]_0 [6]),
        .I1(\m_payload_i_reg[76]_0 [5]),
        .I2(\m_payload_i_reg[3]_0 ),
        .I3(sel_first_0),
        .I4(\axaddr_incr_reg[11] [3]),
        .I5(\axaddr_incr_reg[6] ),
        .O(\m_payload_i_reg[11]_0 [3]));
  LUT6 #(
    .INIT(64'hD4DDDDDDFFFFFFFF)) 
    \axaddr_incr[6]_i_2__0 
       (.I0(\m_payload_i_reg[76]_0 [3]),
        .I1(\axaddr_incr[3]_i_3__0_n_0 ),
        .I2(\axaddr_incr_reg[0] ),
        .I3(\m_payload_i_reg[76]_0 [43]),
        .I4(\m_payload_i_reg[76]_0 [44]),
        .I5(\m_payload_i_reg[76]_0 [4]),
        .O(\m_payload_i_reg[3]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hDF)) 
    \axaddr_incr[7]_i_2__0 
       (.I0(\m_payload_i_reg[76]_0 [5]),
        .I1(\m_payload_i_reg[3]_0 ),
        .I2(\m_payload_i_reg[76]_0 [6]),
        .O(\m_payload_i_reg[5]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT4 #(
    .INIT(16'hDFFF)) 
    \axaddr_incr[8]_i_2__0 
       (.I0(\m_payload_i_reg[76]_0 [6]),
        .I1(\m_payload_i_reg[3]_0 ),
        .I2(\m_payload_i_reg[76]_0 [5]),
        .I3(\m_payload_i_reg[76]_0 [7]),
        .O(\m_payload_i_reg[6]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT5 #(
    .INIT(32'hF7FFFFFF)) 
    \axaddr_incr[9]_i_2 
       (.I0(\m_payload_i_reg[76]_0 [7]),
        .I1(\m_payload_i_reg[76]_0 [5]),
        .I2(\m_payload_i_reg[3]_0 ),
        .I3(\m_payload_i_reg[76]_0 [6]),
        .I4(\m_payload_i_reg[76]_0 [8]),
        .O(\m_payload_i_reg[7]_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \axaddr_offset_r[0]_i_1__0 
       (.I0(\m_payload_i_reg[52]_1 ),
        .O(\m_payload_i_reg[52]_0 ));
  LUT6 #(
    .INIT(64'h00007000FFFF7FFF)) 
    \axaddr_offset_r[0]_i_2__0 
       (.I0(\axaddr_offset_r[0]_i_3__0_n_0 ),
        .I1(\m_payload_i_reg[76]_0 [47]),
        .I2(m_valid_i_reg_0),
        .I3(Q[0]),
        .I4(Q[1]),
        .I5(\axaddr_offset_r_reg[0] ),
        .O(\m_payload_i_reg[52]_1 ));
  LUT6 #(
    .INIT(64'hFC0CFAFAFC0C0A0A)) 
    \axaddr_offset_r[0]_i_3__0 
       (.I0(\m_payload_i_reg[76]_0 [0]),
        .I1(\m_payload_i_reg[76]_0 [2]),
        .I2(\m_payload_i_reg[76]_0 [43]),
        .I3(\m_payload_i_reg[76]_0 [3]),
        .I4(\m_payload_i_reg[76]_0 [44]),
        .I5(\m_payload_i_reg[76]_0 [1]),
        .O(\axaddr_offset_r[0]_i_3__0_n_0 ));
  LUT5 #(
    .INIT(32'hF5DD5555)) 
    \axaddr_offset_r[1]_i_2__0 
       (.I0(next_pending_r_reg_0),
        .I1(\axaddr_offset_r[1]_i_3__0_n_0 ),
        .I2(\axaddr_offset_r[2]_i_3__0_n_0 ),
        .I3(\m_payload_i_reg[76]_0 [43]),
        .I4(\m_payload_i_reg[76]_0 [48]),
        .O(\m_payload_i_reg[43]_1 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axaddr_offset_r[1]_i_3__0 
       (.I0(\m_payload_i_reg[76]_0 [3]),
        .I1(\m_payload_i_reg[76]_0 [44]),
        .I2(\m_payload_i_reg[76]_0 [1]),
        .O(\axaddr_offset_r[1]_i_3__0_n_0 ));
  LUT5 #(
    .INIT(32'hF5DD5555)) 
    \axaddr_offset_r[2]_i_2__0 
       (.I0(next_pending_r_reg_0),
        .I1(\axaddr_offset_r[2]_i_3__0_n_0 ),
        .I2(\axaddr_offset_r[3]_i_3__0_n_0 ),
        .I3(\m_payload_i_reg[76]_0 [43]),
        .I4(\m_payload_i_reg[76]_0 [49]),
        .O(\m_payload_i_reg[43]_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \axaddr_offset_r[2]_i_3__0 
       (.I0(\m_payload_i_reg[76]_0 [4]),
        .I1(\m_payload_i_reg[76]_0 [44]),
        .I2(\m_payload_i_reg[76]_0 [2]),
        .O(\axaddr_offset_r[2]_i_3__0_n_0 ));
  LUT6 #(
    .INIT(64'hDF8FD08000000000)) 
    \axaddr_offset_r[3]_i_2__0 
       (.I0(\m_payload_i_reg[76]_0 [44]),
        .I1(\m_payload_i_reg[76]_0 [6]),
        .I2(\m_payload_i_reg[76]_0 [43]),
        .I3(\m_payload_i_reg[76]_0 [4]),
        .I4(\axaddr_offset_r[3]_i_3__0_n_0 ),
        .I5(\m_payload_i_reg[55]_0 ),
        .O(\m_payload_i_reg[44]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axaddr_offset_r[3]_i_3__0 
       (.I0(\m_payload_i_reg[76]_0 [5]),
        .I1(\m_payload_i_reg[76]_0 [44]),
        .I2(\m_payload_i_reg[76]_0 [3]),
        .O(\axaddr_offset_r[3]_i_3__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \axaddr_wrap[0]_i_2 
       (.I0(\m_payload_i_reg[76]_0 [43]),
        .I1(\m_payload_i_reg[76]_0 [44]),
        .O(\m_payload_i_reg[43]_2 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hCD)) 
    \axaddr_wrap[1]_i_2 
       (.I0(\axaddr_wrap_reg[3]_0 [0]),
        .I1(\m_payload_i_reg[76]_0 [44]),
        .I2(\m_payload_i_reg[76]_0 [43]),
        .O(\axaddr_wrap_reg[0] ));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'h9A)) 
    \axaddr_wrap[2]_i_2__0 
       (.I0(\axaddr_wrap_reg[3]_0 [1]),
        .I1(\m_payload_i_reg[76]_0 [43]),
        .I2(\m_payload_i_reg[76]_0 [44]),
        .O(\axaddr_wrap_reg[2] ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \axaddr_wrap[3]_i_2__0 
       (.I0(\axaddr_wrap_reg[3]_0 [2]),
        .I1(\m_payload_i_reg[76]_0 [44]),
        .I2(\m_payload_i_reg[76]_0 [43]),
        .O(\axaddr_wrap_reg[3] ));
  LUT4 #(
    .INIT(16'h0080)) 
    \axlen_cnt[3]_i_2 
       (.I0(\m_payload_i_reg[76]_0 [50]),
        .I1(m_valid_i_reg_0),
        .I2(Q[0]),
        .I3(Q[1]),
        .O(\m_payload_i_reg[55]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[0]_i_1__0 
       (.I0(s_axi_araddr[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[0] ),
        .O(\m_payload_i[0]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[10]_i_1__0 
       (.I0(s_axi_araddr[10]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[10] ),
        .O(\m_payload_i[10]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[11]_i_1__0 
       (.I0(s_axi_araddr[11]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[11] ),
        .O(\m_payload_i[11]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[12]_i_1__0 
       (.I0(s_axi_araddr[12]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[12] ),
        .O(\m_payload_i[12]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[13]_i_1__0 
       (.I0(s_axi_araddr[13]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[13] ),
        .O(\m_payload_i[13]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[14]_i_1__0 
       (.I0(s_axi_araddr[14]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[14] ),
        .O(\m_payload_i[14]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[15]_i_1__0 
       (.I0(s_axi_araddr[15]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[15] ),
        .O(\m_payload_i[15]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[16]_i_1__0 
       (.I0(s_axi_araddr[16]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[16] ),
        .O(\m_payload_i[16]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[17]_i_1__1 
       (.I0(s_axi_araddr[17]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[17] ),
        .O(\m_payload_i[17]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[18]_i_1__0 
       (.I0(s_axi_araddr[18]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[18] ),
        .O(\m_payload_i[18]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[19]_i_1__0 
       (.I0(s_axi_araddr[19]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[19] ),
        .O(\m_payload_i[19]_i_1__0_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[1]_i_1__0 
       (.I0(s_axi_araddr[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[1] ),
        .O(\m_payload_i[1]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[20]_i_1__0 
       (.I0(s_axi_araddr[20]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[20] ),
        .O(\m_payload_i[20]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[21]_i_1__0 
       (.I0(s_axi_araddr[21]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[21] ),
        .O(\m_payload_i[21]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[22]_i_1__0 
       (.I0(s_axi_araddr[22]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[22] ),
        .O(\m_payload_i[22]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[23]_i_1__0 
       (.I0(s_axi_araddr[23]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[23] ),
        .O(\m_payload_i[23]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[24]_i_1__0 
       (.I0(s_axi_araddr[24]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[24] ),
        .O(\m_payload_i[24]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[25]_i_1__0 
       (.I0(s_axi_araddr[25]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[25] ),
        .O(\m_payload_i[25]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[26]_i_1__0 
       (.I0(s_axi_araddr[26]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[26] ),
        .O(\m_payload_i[26]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[27]_i_1__0 
       (.I0(s_axi_araddr[27]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[27] ),
        .O(\m_payload_i[27]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[28]_i_1__0 
       (.I0(s_axi_araddr[28]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[28] ),
        .O(\m_payload_i[28]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[29]_i_1__0 
       (.I0(s_axi_araddr[29]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[29] ),
        .O(\m_payload_i[29]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[2]_i_1__0 
       (.I0(s_axi_araddr[2]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[2] ),
        .O(\m_payload_i[2]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[30]_i_1__0 
       (.I0(s_axi_araddr[30]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[30] ),
        .O(\m_payload_i[30]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[31]_i_1__0 
       (.I0(s_axi_araddr[31]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[31] ),
        .O(\m_payload_i[31]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[32]_i_1__0 
       (.I0(s_axi_araddr[32]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[32] ),
        .O(\m_payload_i[32]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[33]_i_1__0 
       (.I0(s_axi_araddr[33]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[33] ),
        .O(\m_payload_i[33]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[34]_i_1__0 
       (.I0(s_axi_araddr[34]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[34] ),
        .O(\m_payload_i[34]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[35]_i_1__0 
       (.I0(s_axi_araddr[35]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[35] ),
        .O(\m_payload_i[35]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[36]_i_1__0 
       (.I0(s_axi_araddr[36]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[36] ),
        .O(\m_payload_i[36]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[37]_i_1__0 
       (.I0(s_axi_araddr[37]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[37] ),
        .O(\m_payload_i[37]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[38]_i_1__0 
       (.I0(s_axi_araddr[38]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[38] ),
        .O(\m_payload_i[38]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[39]_i_2__0 
       (.I0(s_axi_araddr[39]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[39] ),
        .O(\m_payload_i[39]_i_2__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[3]_i_1__0 
       (.I0(s_axi_araddr[3]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[3] ),
        .O(\m_payload_i[3]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[40]_i_1__0 
       (.I0(s_axi_arprot[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[40] ),
        .O(\m_payload_i[40]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[41]_i_1__0 
       (.I0(s_axi_arprot[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[41] ),
        .O(\m_payload_i[41]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[42]_i_1__0 
       (.I0(s_axi_arprot[2]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[42] ),
        .O(\m_payload_i[42]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[43]_i_1__0 
       (.I0(s_axi_arsize[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[43] ),
        .O(\m_payload_i[43]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[44]_i_1__0 
       (.I0(s_axi_arsize[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[44] ),
        .O(\m_payload_i[44]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[46]_i_1__0 
       (.I0(s_axi_arburst[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[46] ),
        .O(\m_payload_i[46]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[47]_i_1__0 
       (.I0(s_axi_arburst[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[47] ),
        .O(\m_payload_i[47]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[4]_i_1__0 
       (.I0(s_axi_araddr[4]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[4] ),
        .O(\m_payload_i[4]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[52]_i_1__0 
       (.I0(s_axi_arlen[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[52] ),
        .O(\m_payload_i[52]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[53]_i_1__0 
       (.I0(s_axi_arlen[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[53] ),
        .O(\m_payload_i[53]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[54]_i_1__0 
       (.I0(s_axi_arlen[2]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[54] ),
        .O(\m_payload_i[54]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[55]_i_1__0 
       (.I0(s_axi_arlen[3]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[55] ),
        .O(\m_payload_i[55]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[56]_i_1__0 
       (.I0(s_axi_arlen[4]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[56] ),
        .O(\m_payload_i[56]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[57]_i_1__0 
       (.I0(s_axi_arlen[5]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[57] ),
        .O(\m_payload_i[57]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[58]_i_1__0 
       (.I0(s_axi_arlen[6]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[58] ),
        .O(\m_payload_i[58]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[59]_i_1__0 
       (.I0(s_axi_arlen[7]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[59] ),
        .O(\m_payload_i[59]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[5]_i_1__0 
       (.I0(s_axi_araddr[5]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[5] ),
        .O(\m_payload_i[5]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[61]_i_1__0 
       (.I0(s_axi_arid[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[61] ),
        .O(\m_payload_i[61]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[62]_i_1__0 
       (.I0(s_axi_arid[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[62] ),
        .O(\m_payload_i[62]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[63]_i_1__0 
       (.I0(s_axi_arid[2]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[63] ),
        .O(\m_payload_i[63]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[64]_i_1__0 
       (.I0(s_axi_arid[3]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[64] ),
        .O(\m_payload_i[64]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[65]_i_1__0 
       (.I0(s_axi_arid[4]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[65] ),
        .O(\m_payload_i[65]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[66]_i_1__0 
       (.I0(s_axi_arid[5]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[66] ),
        .O(\m_payload_i[66]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[67]_i_1__0 
       (.I0(s_axi_arid[6]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[67] ),
        .O(\m_payload_i[67]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[68]_i_1__0 
       (.I0(s_axi_arid[7]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[68] ),
        .O(\m_payload_i[68]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[69]_i_1__0 
       (.I0(s_axi_arid[8]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[69] ),
        .O(\m_payload_i[69]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[6]_i_1__0 
       (.I0(s_axi_araddr[6]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[6] ),
        .O(\m_payload_i[6]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[70]_i_1__0 
       (.I0(s_axi_arid[9]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[70] ),
        .O(\m_payload_i[70]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[71]_i_1__0 
       (.I0(s_axi_arid[10]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[71] ),
        .O(\m_payload_i[71]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[72]_i_1__0 
       (.I0(s_axi_arid[11]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[72] ),
        .O(\m_payload_i[72]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[73]_i_1__0 
       (.I0(s_axi_arid[12]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[73] ),
        .O(\m_payload_i[73]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[74]_i_1__0 
       (.I0(s_axi_arid[13]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[74] ),
        .O(\m_payload_i[74]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[75]_i_1__0 
       (.I0(s_axi_arid[14]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[75] ),
        .O(\m_payload_i[75]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[76]_i_1__0 
       (.I0(s_axi_arid[15]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[76] ),
        .O(\m_payload_i[76]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[7]_i_1__0 
       (.I0(s_axi_araddr[7]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[7] ),
        .O(\m_payload_i[7]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[8]_i_1__0 
       (.I0(s_axi_araddr[8]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[8] ),
        .O(\m_payload_i[8]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[9]_i_1__0 
       (.I0(s_axi_araddr[9]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[9] ),
        .O(\m_payload_i[9]_i_1__0_n_0 ));
  FDRE \m_payload_i_reg[0] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[0]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [0]),
        .R(1'b0));
  FDRE \m_payload_i_reg[10] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[10]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [10]),
        .R(1'b0));
  FDRE \m_payload_i_reg[11] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[11]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [11]),
        .R(1'b0));
  FDRE \m_payload_i_reg[12] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[12]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [12]),
        .R(1'b0));
  FDRE \m_payload_i_reg[13] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[13]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [13]),
        .R(1'b0));
  FDRE \m_payload_i_reg[14] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[14]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [14]),
        .R(1'b0));
  FDRE \m_payload_i_reg[15] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[15]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [15]),
        .R(1'b0));
  FDRE \m_payload_i_reg[16] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[16]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [16]),
        .R(1'b0));
  FDRE \m_payload_i_reg[17] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[17]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [17]),
        .R(1'b0));
  FDRE \m_payload_i_reg[18] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[18]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [18]),
        .R(1'b0));
  FDRE \m_payload_i_reg[19] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[19]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [19]),
        .R(1'b0));
  FDRE \m_payload_i_reg[1] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[1]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [1]),
        .R(1'b0));
  FDRE \m_payload_i_reg[20] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[20]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [20]),
        .R(1'b0));
  FDRE \m_payload_i_reg[21] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[21]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [21]),
        .R(1'b0));
  FDRE \m_payload_i_reg[22] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[22]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [22]),
        .R(1'b0));
  FDRE \m_payload_i_reg[23] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[23]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [23]),
        .R(1'b0));
  FDRE \m_payload_i_reg[24] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[24]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [24]),
        .R(1'b0));
  FDRE \m_payload_i_reg[25] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[25]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [25]),
        .R(1'b0));
  FDRE \m_payload_i_reg[26] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[26]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [26]),
        .R(1'b0));
  FDRE \m_payload_i_reg[27] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[27]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [27]),
        .R(1'b0));
  FDRE \m_payload_i_reg[28] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[28]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [28]),
        .R(1'b0));
  FDRE \m_payload_i_reg[29] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[29]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [29]),
        .R(1'b0));
  FDRE \m_payload_i_reg[2] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[2]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [2]),
        .R(1'b0));
  FDRE \m_payload_i_reg[30] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[30]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [30]),
        .R(1'b0));
  FDRE \m_payload_i_reg[31] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[31]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [31]),
        .R(1'b0));
  FDRE \m_payload_i_reg[32] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[32]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [32]),
        .R(1'b0));
  FDRE \m_payload_i_reg[33] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[33]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [33]),
        .R(1'b0));
  FDRE \m_payload_i_reg[34] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[34]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [34]),
        .R(1'b0));
  FDRE \m_payload_i_reg[35] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[35]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [35]),
        .R(1'b0));
  FDRE \m_payload_i_reg[36] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[36]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [36]),
        .R(1'b0));
  FDRE \m_payload_i_reg[37] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[37]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [37]),
        .R(1'b0));
  FDRE \m_payload_i_reg[38] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[38]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [38]),
        .R(1'b0));
  FDRE \m_payload_i_reg[39] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[39]_i_2__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [39]),
        .R(1'b0));
  FDRE \m_payload_i_reg[3] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[3]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [3]),
        .R(1'b0));
  FDRE \m_payload_i_reg[40] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[40]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [40]),
        .R(1'b0));
  FDRE \m_payload_i_reg[41] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[41]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [41]),
        .R(1'b0));
  FDRE \m_payload_i_reg[42] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[42]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [42]),
        .R(1'b0));
  FDRE \m_payload_i_reg[43] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[43]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [43]),
        .R(1'b0));
  FDRE \m_payload_i_reg[44] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[44]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [44]),
        .R(1'b0));
  FDRE \m_payload_i_reg[46] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[46]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [45]),
        .R(1'b0));
  FDRE \m_payload_i_reg[47] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[47]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [46]),
        .R(1'b0));
  FDRE \m_payload_i_reg[4] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[4]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [4]),
        .R(1'b0));
  FDRE \m_payload_i_reg[52] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[52]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [47]),
        .R(1'b0));
  FDRE \m_payload_i_reg[53] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[53]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [48]),
        .R(1'b0));
  FDRE \m_payload_i_reg[54] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[54]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [49]),
        .R(1'b0));
  FDRE \m_payload_i_reg[55] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[55]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [50]),
        .R(1'b0));
  FDRE \m_payload_i_reg[56] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[56]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [51]),
        .R(1'b0));
  FDRE \m_payload_i_reg[57] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[57]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [52]),
        .R(1'b0));
  FDRE \m_payload_i_reg[58] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[58]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [53]),
        .R(1'b0));
  FDRE \m_payload_i_reg[59] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[59]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [54]),
        .R(1'b0));
  FDRE \m_payload_i_reg[5] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[5]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [5]),
        .R(1'b0));
  FDRE \m_payload_i_reg[61] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[61]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [55]),
        .R(1'b0));
  FDRE \m_payload_i_reg[62] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[62]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [56]),
        .R(1'b0));
  FDRE \m_payload_i_reg[63] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[63]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [57]),
        .R(1'b0));
  FDRE \m_payload_i_reg[64] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[64]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [58]),
        .R(1'b0));
  FDRE \m_payload_i_reg[65] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[65]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [59]),
        .R(1'b0));
  FDRE \m_payload_i_reg[66] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[66]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [60]),
        .R(1'b0));
  FDRE \m_payload_i_reg[67] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[67]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [61]),
        .R(1'b0));
  FDRE \m_payload_i_reg[68] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[68]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [62]),
        .R(1'b0));
  FDRE \m_payload_i_reg[69] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[69]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [63]),
        .R(1'b0));
  FDRE \m_payload_i_reg[6] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[6]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [6]),
        .R(1'b0));
  FDRE \m_payload_i_reg[70] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[70]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [64]),
        .R(1'b0));
  FDRE \m_payload_i_reg[71] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[71]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [65]),
        .R(1'b0));
  FDRE \m_payload_i_reg[72] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[72]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [66]),
        .R(1'b0));
  FDRE \m_payload_i_reg[73] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[73]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [67]),
        .R(1'b0));
  FDRE \m_payload_i_reg[74] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[74]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [68]),
        .R(1'b0));
  FDRE \m_payload_i_reg[75] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[75]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [69]),
        .R(1'b0));
  FDRE \m_payload_i_reg[76] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[76]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [70]),
        .R(1'b0));
  FDRE \m_payload_i_reg[7] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[7]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [7]),
        .R(1'b0));
  FDRE \m_payload_i_reg[8] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[8]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [8]),
        .R(1'b0));
  FDRE \m_payload_i_reg[9] 
       (.C(aclk),
        .CE(\m_payload_i_reg[0]_0 ),
        .D(\m_payload_i[9]_i_1__0_n_0 ),
        .Q(\m_payload_i_reg[76]_0 [9]),
        .R(1'b0));
  LUT1 #(
    .INIT(2'h1)) 
    m_valid_i_i_1__0
       (.I0(\aresetn_d_reg_n_0_[1] ),
        .O(\aresetn_d_reg[1]_0 ));
  LUT5 #(
    .INIT(32'hFFA8FFFF)) 
    m_valid_i_i_1__2
       (.I0(m_valid_i_reg_0),
        .I1(Q[0]),
        .I2(Q[1]),
        .I3(s_axi_arvalid),
        .I4(s_ready_i_reg_0),
        .O(m_valid_i_i_1__2_n_0));
  FDRE #(
    .INIT(1'b0)) 
    m_valid_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(m_valid_i_i_1__2_n_0),
        .Q(m_valid_i_reg_0),
        .R(\aresetn_d_reg[1]_0 ));
  LUT6 #(
    .INIT(64'hEEEEEEEEEEEEEEEA)) 
    next_pending_r_i_1__2
       (.I0(next_pending_r_reg),
        .I1(next_pending_r_reg_0),
        .I2(\m_payload_i_reg[76]_0 [48]),
        .I3(\m_payload_i_reg[76]_0 [49]),
        .I4(\m_payload_i_reg[76]_0 [50]),
        .I5(\m_payload_i_reg[76]_0 [47]),
        .O(wrap_next_pending));
  LUT5 #(
    .INIT(32'h00010000)) 
    next_pending_r_i_3__1
       (.I0(\m_payload_i_reg[76]_0 [51]),
        .I1(\m_payload_i_reg[76]_0 [52]),
        .I2(\m_payload_i_reg[76]_0 [53]),
        .I3(\m_payload_i_reg[76]_0 [54]),
        .I4(next_pending_r_i_6__0_n_0),
        .O(\m_payload_i_reg[56]_0 ));
  LUT4 #(
    .INIT(16'h0001)) 
    next_pending_r_i_6__0
       (.I0(\m_payload_i_reg[76]_0 [48]),
        .I1(\m_payload_i_reg[76]_0 [47]),
        .I2(\m_payload_i_reg[76]_0 [50]),
        .I3(\m_payload_i_reg[76]_0 [49]),
        .O(next_pending_r_i_6__0_n_0));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    s_axburst_eq0_i_1__0
       (.I0(wrap_next_pending),
        .I1(\m_payload_i_reg[76]_0 [46]),
        .I2(sel_first_i),
        .I3(incr_next_pending),
        .O(\m_payload_i_reg[47]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT4 #(
    .INIT(16'hABA8)) 
    s_axburst_eq1_i_1__0
       (.I0(wrap_next_pending),
        .I1(\m_payload_i_reg[76]_0 [46]),
        .I2(sel_first_i),
        .I3(incr_next_pending),
        .O(\m_payload_i_reg[47]_1 ));
  LUT5 #(
    .INIT(32'h4F4F4FFF)) 
    s_ready_i_i_1
       (.I0(s_axi_arvalid),
        .I1(s_ready_i_reg_0),
        .I2(m_valid_i_reg_0),
        .I3(Q[0]),
        .I4(Q[1]),
        .O(s_ready_i0));
  FDRE #(
    .INIT(1'b0)) 
    s_ready_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(s_ready_i0),
        .Q(s_ready_i_reg_0),
        .R(s_ready_i_reg_1));
  FDRE \skid_buffer_reg[0] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[0]),
        .Q(\skid_buffer_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[10] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[10]),
        .Q(\skid_buffer_reg_n_0_[10] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[11] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[11]),
        .Q(\skid_buffer_reg_n_0_[11] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[12] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[12]),
        .Q(\skid_buffer_reg_n_0_[12] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[13] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[13]),
        .Q(\skid_buffer_reg_n_0_[13] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[14] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[14]),
        .Q(\skid_buffer_reg_n_0_[14] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[15] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[15]),
        .Q(\skid_buffer_reg_n_0_[15] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[16] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[16]),
        .Q(\skid_buffer_reg_n_0_[16] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[17] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[17]),
        .Q(\skid_buffer_reg_n_0_[17] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[18] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[18]),
        .Q(\skid_buffer_reg_n_0_[18] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[19] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[19]),
        .Q(\skid_buffer_reg_n_0_[19] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[1] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[1]),
        .Q(\skid_buffer_reg_n_0_[1] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[20] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[20]),
        .Q(\skid_buffer_reg_n_0_[20] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[21] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[21]),
        .Q(\skid_buffer_reg_n_0_[21] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[22] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[22]),
        .Q(\skid_buffer_reg_n_0_[22] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[23] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[23]),
        .Q(\skid_buffer_reg_n_0_[23] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[24] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[24]),
        .Q(\skid_buffer_reg_n_0_[24] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[25] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[25]),
        .Q(\skid_buffer_reg_n_0_[25] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[26] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[26]),
        .Q(\skid_buffer_reg_n_0_[26] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[27] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[27]),
        .Q(\skid_buffer_reg_n_0_[27] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[28] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[28]),
        .Q(\skid_buffer_reg_n_0_[28] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[29] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[29]),
        .Q(\skid_buffer_reg_n_0_[29] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[2] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[2]),
        .Q(\skid_buffer_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[30] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[30]),
        .Q(\skid_buffer_reg_n_0_[30] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[31] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[31]),
        .Q(\skid_buffer_reg_n_0_[31] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[32] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[32]),
        .Q(\skid_buffer_reg_n_0_[32] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[33] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[33]),
        .Q(\skid_buffer_reg_n_0_[33] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[34] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[34]),
        .Q(\skid_buffer_reg_n_0_[34] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[35] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[35]),
        .Q(\skid_buffer_reg_n_0_[35] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[36] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[36]),
        .Q(\skid_buffer_reg_n_0_[36] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[37] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[37]),
        .Q(\skid_buffer_reg_n_0_[37] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[38] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[38]),
        .Q(\skid_buffer_reg_n_0_[38] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[39] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[39]),
        .Q(\skid_buffer_reg_n_0_[39] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[3] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[3]),
        .Q(\skid_buffer_reg_n_0_[3] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[40] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arprot[0]),
        .Q(\skid_buffer_reg_n_0_[40] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[41] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arprot[1]),
        .Q(\skid_buffer_reg_n_0_[41] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[42] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arprot[2]),
        .Q(\skid_buffer_reg_n_0_[42] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[43] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arsize[0]),
        .Q(\skid_buffer_reg_n_0_[43] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[44] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arsize[1]),
        .Q(\skid_buffer_reg_n_0_[44] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[46] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arburst[0]),
        .Q(\skid_buffer_reg_n_0_[46] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[47] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arburst[1]),
        .Q(\skid_buffer_reg_n_0_[47] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[4] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[4]),
        .Q(\skid_buffer_reg_n_0_[4] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[52] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arlen[0]),
        .Q(\skid_buffer_reg_n_0_[52] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[53] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arlen[1]),
        .Q(\skid_buffer_reg_n_0_[53] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[54] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arlen[2]),
        .Q(\skid_buffer_reg_n_0_[54] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[55] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arlen[3]),
        .Q(\skid_buffer_reg_n_0_[55] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[56] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arlen[4]),
        .Q(\skid_buffer_reg_n_0_[56] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[57] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arlen[5]),
        .Q(\skid_buffer_reg_n_0_[57] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[58] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arlen[6]),
        .Q(\skid_buffer_reg_n_0_[58] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[59] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arlen[7]),
        .Q(\skid_buffer_reg_n_0_[59] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[5] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[5]),
        .Q(\skid_buffer_reg_n_0_[5] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[61] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[0]),
        .Q(\skid_buffer_reg_n_0_[61] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[62] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[1]),
        .Q(\skid_buffer_reg_n_0_[62] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[63] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[2]),
        .Q(\skid_buffer_reg_n_0_[63] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[64] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[3]),
        .Q(\skid_buffer_reg_n_0_[64] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[65] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[4]),
        .Q(\skid_buffer_reg_n_0_[65] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[66] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[5]),
        .Q(\skid_buffer_reg_n_0_[66] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[67] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[6]),
        .Q(\skid_buffer_reg_n_0_[67] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[68] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[7]),
        .Q(\skid_buffer_reg_n_0_[68] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[69] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[8]),
        .Q(\skid_buffer_reg_n_0_[69] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[6] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[6]),
        .Q(\skid_buffer_reg_n_0_[6] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[70] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[9]),
        .Q(\skid_buffer_reg_n_0_[70] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[71] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[10]),
        .Q(\skid_buffer_reg_n_0_[71] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[72] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[11]),
        .Q(\skid_buffer_reg_n_0_[72] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[73] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[12]),
        .Q(\skid_buffer_reg_n_0_[73] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[74] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[13]),
        .Q(\skid_buffer_reg_n_0_[74] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[75] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[14]),
        .Q(\skid_buffer_reg_n_0_[75] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[76] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_arid[15]),
        .Q(\skid_buffer_reg_n_0_[76] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[7] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[7]),
        .Q(\skid_buffer_reg_n_0_[7] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[8] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[8]),
        .Q(\skid_buffer_reg_n_0_[8] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[9] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_araddr[9]),
        .Q(\skid_buffer_reg_n_0_[9] ),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT4 #(
    .INIT(16'hAAA2)) 
    \wrap_boundary_axaddr_r[0]_i_1 
       (.I0(\m_payload_i_reg[76]_0 [0]),
        .I1(\m_payload_i_reg[76]_0 [47]),
        .I2(\m_payload_i_reg[76]_0 [43]),
        .I3(\m_payload_i_reg[76]_0 [44]),
        .O(\m_payload_i_reg[6]_1 [0]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT5 #(
    .INIT(32'hFF470000)) 
    \wrap_boundary_axaddr_r[1]_i_1__0 
       (.I0(\m_payload_i_reg[76]_0 [47]),
        .I1(\m_payload_i_reg[76]_0 [43]),
        .I2(\m_payload_i_reg[76]_0 [48]),
        .I3(\m_payload_i_reg[76]_0 [44]),
        .I4(\m_payload_i_reg[76]_0 [1]),
        .O(\m_payload_i_reg[6]_1 [1]));
  LUT6 #(
    .INIT(64'hA0A002A2AAAA02A2)) 
    \wrap_boundary_axaddr_r[2]_i_1__0 
       (.I0(\m_payload_i_reg[76]_0 [2]),
        .I1(\m_payload_i_reg[76]_0 [49]),
        .I2(\m_payload_i_reg[76]_0 [43]),
        .I3(\m_payload_i_reg[76]_0 [48]),
        .I4(\m_payload_i_reg[76]_0 [44]),
        .I5(\m_payload_i_reg[76]_0 [47]),
        .O(\m_payload_i_reg[6]_1 [2]));
  LUT6 #(
    .INIT(64'h4747000000FF0000)) 
    \wrap_boundary_axaddr_r[3]_i_1__0 
       (.I0(\m_payload_i_reg[76]_0 [47]),
        .I1(\m_payload_i_reg[76]_0 [43]),
        .I2(\m_payload_i_reg[76]_0 [48]),
        .I3(\wrap_boundary_axaddr_r[3]_i_2__0_n_0 ),
        .I4(\m_payload_i_reg[76]_0 [3]),
        .I5(\m_payload_i_reg[76]_0 [44]),
        .O(\m_payload_i_reg[6]_1 [3]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \wrap_boundary_axaddr_r[3]_i_2__0 
       (.I0(\m_payload_i_reg[76]_0 [49]),
        .I1(\m_payload_i_reg[76]_0 [43]),
        .I2(\m_payload_i_reg[76]_0 [50]),
        .O(\wrap_boundary_axaddr_r[3]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'h002A0A2AA02AAA2A)) 
    \wrap_boundary_axaddr_r[4]_i_1 
       (.I0(\m_payload_i_reg[76]_0 [4]),
        .I1(\m_payload_i_reg[76]_0 [50]),
        .I2(\m_payload_i_reg[76]_0 [43]),
        .I3(\m_payload_i_reg[76]_0 [44]),
        .I4(\m_payload_i_reg[76]_0 [49]),
        .I5(\m_payload_i_reg[76]_0 [48]),
        .O(\m_payload_i_reg[6]_1 [4]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT5 #(
    .INIT(32'h47FF0000)) 
    \wrap_boundary_axaddr_r[5]_i_1__0 
       (.I0(\m_payload_i_reg[76]_0 [49]),
        .I1(\m_payload_i_reg[76]_0 [43]),
        .I2(\m_payload_i_reg[76]_0 [50]),
        .I3(\m_payload_i_reg[76]_0 [44]),
        .I4(\m_payload_i_reg[76]_0 [5]),
        .O(\m_payload_i_reg[6]_1 [5]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT4 #(
    .INIT(16'h2AAA)) 
    \wrap_boundary_axaddr_r[6]_i_1__0 
       (.I0(\m_payload_i_reg[76]_0 [6]),
        .I1(\m_payload_i_reg[76]_0 [43]),
        .I2(\m_payload_i_reg[76]_0 [44]),
        .I3(\m_payload_i_reg[76]_0 [50]),
        .O(\m_payload_i_reg[6]_1 [6]));
endmodule

(* ORIG_REF_NAME = "axi_register_slice_v2_1_20_axic_register_slice" *) 
module zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axic_register_slice_0
   (s_ready_i_reg_0,
    \aresetn_d_reg[0]_0 ,
    m_valid_i_reg_0,
    \aresetn_d_reg[0]_1 ,
    \m_payload_i_reg[6]_0 ,
    Q,
    \m_payload_i_reg[43]_0 ,
    \m_payload_i_reg[43]_1 ,
    D,
    \m_payload_i_reg[52]_0 ,
    \m_payload_i_reg[11]_0 ,
    \m_payload_i_reg[43]_2 ,
    \m_payload_i_reg[3]_0 ,
    \m_payload_i_reg[3]_1 ,
    \m_payload_i_reg[8]_0 ,
    \m_payload_i_reg[1]_0 ,
    \m_payload_i_reg[2]_0 ,
    \m_payload_i_reg[54]_0 ,
    \m_payload_i_reg[53]_0 ,
    \m_payload_i_reg[6]_1 ,
    \axaddr_wrap_reg[2] ,
    \m_payload_i_reg[44]_0 ,
    \m_payload_i_reg[0]_0 ,
    \axaddr_wrap_reg[0] ,
    \m_payload_i_reg[2]_1 ,
    \axaddr_wrap_reg[3] ,
    \m_payload_i_reg[43]_3 ,
    \m_payload_i_reg[44]_1 ,
    aclk,
    m_valid_i_reg_1,
    \aresetn_d_reg[0]_2 ,
    b_push,
    s_axi_awvalid,
    \axaddr_incr_reg[3] ,
    \axaddr_offset_r_reg[1] ,
    \axaddr_offset_r_reg[0] ,
    sel_first,
    \axaddr_incr_reg[10] ,
    \axaddr_incr_reg[3]_0 ,
    \axaddr_incr_reg[0] ,
    \axaddr_incr_reg[6] ,
    \axaddr_incr_reg[7] ,
    \axaddr_incr_reg[8] ,
    \axaddr_incr_reg[10]_0 ,
    \axaddr_incr_reg[11] ,
    \axaddr_incr_reg[11]_0 ,
    s_axi_awid,
    s_axi_awlen,
    s_axi_awburst,
    s_axi_awsize,
    s_axi_awprot,
    s_axi_awaddr,
    \axaddr_wrap_reg[3]_0 ,
    E);
  output s_ready_i_reg_0;
  output \aresetn_d_reg[0]_0 ;
  output m_valid_i_reg_0;
  output \aresetn_d_reg[0]_1 ;
  output \m_payload_i_reg[6]_0 ;
  output [70:0]Q;
  output \m_payload_i_reg[43]_0 ;
  output \m_payload_i_reg[43]_1 ;
  output [0:0]D;
  output \m_payload_i_reg[52]_0 ;
  output [7:0]\m_payload_i_reg[11]_0 ;
  output \m_payload_i_reg[43]_2 ;
  output \m_payload_i_reg[3]_0 ;
  output \m_payload_i_reg[3]_1 ;
  output \m_payload_i_reg[8]_0 ;
  output \m_payload_i_reg[1]_0 ;
  output \m_payload_i_reg[2]_0 ;
  output \m_payload_i_reg[54]_0 ;
  output \m_payload_i_reg[53]_0 ;
  output [6:0]\m_payload_i_reg[6]_1 ;
  output \axaddr_wrap_reg[2] ;
  output \m_payload_i_reg[44]_0 ;
  output \m_payload_i_reg[0]_0 ;
  output \axaddr_wrap_reg[0] ;
  output \m_payload_i_reg[2]_1 ;
  output \axaddr_wrap_reg[3] ;
  output \m_payload_i_reg[43]_3 ;
  output \m_payload_i_reg[44]_1 ;
  input aclk;
  input m_valid_i_reg_1;
  input \aresetn_d_reg[0]_2 ;
  input b_push;
  input s_axi_awvalid;
  input [1:0]\axaddr_incr_reg[3] ;
  input \axaddr_offset_r_reg[1] ;
  input [0:0]\axaddr_offset_r_reg[0] ;
  input sel_first;
  input [6:0]\axaddr_incr_reg[10] ;
  input \axaddr_incr_reg[3]_0 ;
  input \axaddr_incr_reg[0] ;
  input \axaddr_incr_reg[6] ;
  input \axaddr_incr_reg[7] ;
  input \axaddr_incr_reg[8] ;
  input \axaddr_incr_reg[10]_0 ;
  input \axaddr_incr_reg[11] ;
  input \axaddr_incr_reg[11]_0 ;
  input [15:0]s_axi_awid;
  input [7:0]s_axi_awlen;
  input [1:0]s_axi_awburst;
  input [1:0]s_axi_awsize;
  input [2:0]s_axi_awprot;
  input [39:0]s_axi_awaddr;
  input [2:0]\axaddr_wrap_reg[3]_0 ;
  input [0:0]E;

  wire [0:0]D;
  wire [0:0]E;
  wire [70:0]Q;
  wire aclk;
  wire \aresetn_d_reg[0]_0 ;
  wire \aresetn_d_reg[0]_1 ;
  wire \aresetn_d_reg[0]_2 ;
  wire \axaddr_incr[1]_i_2_n_0 ;
  wire \axaddr_incr[3]_i_2_n_0 ;
  wire \axaddr_incr[3]_i_3_n_0 ;
  wire \axaddr_incr[7]_i_2_n_0 ;
  wire \axaddr_incr[8]_i_2_n_0 ;
  wire \axaddr_incr[8]_i_4_n_0 ;
  wire \axaddr_incr_reg[0] ;
  wire [6:0]\axaddr_incr_reg[10] ;
  wire \axaddr_incr_reg[10]_0 ;
  wire \axaddr_incr_reg[11] ;
  wire \axaddr_incr_reg[11]_0 ;
  wire [1:0]\axaddr_incr_reg[3] ;
  wire \axaddr_incr_reg[3]_0 ;
  wire \axaddr_incr_reg[6] ;
  wire \axaddr_incr_reg[7] ;
  wire \axaddr_incr_reg[8] ;
  wire \axaddr_offset_r[0]_i_3_n_0 ;
  wire \axaddr_offset_r[1]_i_3_n_0 ;
  wire \axaddr_offset_r[2]_i_3_n_0 ;
  wire \axaddr_offset_r[3]_i_3_n_0 ;
  wire \axaddr_offset_r[3]_i_4_n_0 ;
  wire [0:0]\axaddr_offset_r_reg[0] ;
  wire \axaddr_offset_r_reg[1] ;
  wire \axaddr_wrap_reg[0] ;
  wire \axaddr_wrap_reg[2] ;
  wire \axaddr_wrap_reg[3] ;
  wire [2:0]\axaddr_wrap_reg[3]_0 ;
  wire b_push;
  wire \m_payload_i_reg[0]_0 ;
  wire [7:0]\m_payload_i_reg[11]_0 ;
  wire \m_payload_i_reg[1]_0 ;
  wire \m_payload_i_reg[2]_0 ;
  wire \m_payload_i_reg[2]_1 ;
  wire \m_payload_i_reg[3]_0 ;
  wire \m_payload_i_reg[3]_1 ;
  wire \m_payload_i_reg[43]_0 ;
  wire \m_payload_i_reg[43]_1 ;
  wire \m_payload_i_reg[43]_2 ;
  wire \m_payload_i_reg[43]_3 ;
  wire \m_payload_i_reg[44]_0 ;
  wire \m_payload_i_reg[44]_1 ;
  wire \m_payload_i_reg[52]_0 ;
  wire \m_payload_i_reg[53]_0 ;
  wire \m_payload_i_reg[54]_0 ;
  wire \m_payload_i_reg[6]_0 ;
  wire [6:0]\m_payload_i_reg[6]_1 ;
  wire \m_payload_i_reg[8]_0 ;
  wire m_valid_i_i_1__1_n_0;
  wire m_valid_i_reg_0;
  wire m_valid_i_reg_1;
  wire next_pending_r_i_6_n_0;
  wire [39:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [15:0]s_axi_awid;
  wire [7:0]s_axi_awlen;
  wire [2:0]s_axi_awprot;
  wire [1:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire s_ready_i0;
  wire s_ready_i_reg_0;
  wire sel_first;
  wire [76:0]skid_buffer;
  wire \skid_buffer_reg_n_0_[0] ;
  wire \skid_buffer_reg_n_0_[10] ;
  wire \skid_buffer_reg_n_0_[11] ;
  wire \skid_buffer_reg_n_0_[12] ;
  wire \skid_buffer_reg_n_0_[13] ;
  wire \skid_buffer_reg_n_0_[14] ;
  wire \skid_buffer_reg_n_0_[15] ;
  wire \skid_buffer_reg_n_0_[16] ;
  wire \skid_buffer_reg_n_0_[17] ;
  wire \skid_buffer_reg_n_0_[18] ;
  wire \skid_buffer_reg_n_0_[19] ;
  wire \skid_buffer_reg_n_0_[1] ;
  wire \skid_buffer_reg_n_0_[20] ;
  wire \skid_buffer_reg_n_0_[21] ;
  wire \skid_buffer_reg_n_0_[22] ;
  wire \skid_buffer_reg_n_0_[23] ;
  wire \skid_buffer_reg_n_0_[24] ;
  wire \skid_buffer_reg_n_0_[25] ;
  wire \skid_buffer_reg_n_0_[26] ;
  wire \skid_buffer_reg_n_0_[27] ;
  wire \skid_buffer_reg_n_0_[28] ;
  wire \skid_buffer_reg_n_0_[29] ;
  wire \skid_buffer_reg_n_0_[2] ;
  wire \skid_buffer_reg_n_0_[30] ;
  wire \skid_buffer_reg_n_0_[31] ;
  wire \skid_buffer_reg_n_0_[32] ;
  wire \skid_buffer_reg_n_0_[33] ;
  wire \skid_buffer_reg_n_0_[34] ;
  wire \skid_buffer_reg_n_0_[35] ;
  wire \skid_buffer_reg_n_0_[36] ;
  wire \skid_buffer_reg_n_0_[37] ;
  wire \skid_buffer_reg_n_0_[38] ;
  wire \skid_buffer_reg_n_0_[39] ;
  wire \skid_buffer_reg_n_0_[3] ;
  wire \skid_buffer_reg_n_0_[40] ;
  wire \skid_buffer_reg_n_0_[41] ;
  wire \skid_buffer_reg_n_0_[42] ;
  wire \skid_buffer_reg_n_0_[43] ;
  wire \skid_buffer_reg_n_0_[44] ;
  wire \skid_buffer_reg_n_0_[46] ;
  wire \skid_buffer_reg_n_0_[47] ;
  wire \skid_buffer_reg_n_0_[4] ;
  wire \skid_buffer_reg_n_0_[52] ;
  wire \skid_buffer_reg_n_0_[53] ;
  wire \skid_buffer_reg_n_0_[54] ;
  wire \skid_buffer_reg_n_0_[55] ;
  wire \skid_buffer_reg_n_0_[56] ;
  wire \skid_buffer_reg_n_0_[57] ;
  wire \skid_buffer_reg_n_0_[58] ;
  wire \skid_buffer_reg_n_0_[59] ;
  wire \skid_buffer_reg_n_0_[5] ;
  wire \skid_buffer_reg_n_0_[61] ;
  wire \skid_buffer_reg_n_0_[62] ;
  wire \skid_buffer_reg_n_0_[63] ;
  wire \skid_buffer_reg_n_0_[64] ;
  wire \skid_buffer_reg_n_0_[65] ;
  wire \skid_buffer_reg_n_0_[66] ;
  wire \skid_buffer_reg_n_0_[67] ;
  wire \skid_buffer_reg_n_0_[68] ;
  wire \skid_buffer_reg_n_0_[69] ;
  wire \skid_buffer_reg_n_0_[6] ;
  wire \skid_buffer_reg_n_0_[70] ;
  wire \skid_buffer_reg_n_0_[71] ;
  wire \skid_buffer_reg_n_0_[72] ;
  wire \skid_buffer_reg_n_0_[73] ;
  wire \skid_buffer_reg_n_0_[74] ;
  wire \skid_buffer_reg_n_0_[75] ;
  wire \skid_buffer_reg_n_0_[76] ;
  wire \skid_buffer_reg_n_0_[7] ;
  wire \skid_buffer_reg_n_0_[8] ;
  wire \skid_buffer_reg_n_0_[9] ;
  wire \wrap_boundary_axaddr_r[3]_i_2_n_0 ;

  FDRE #(
    .INIT(1'b0)) 
    \aresetn_d_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(1'b1),
        .Q(\aresetn_d_reg[0]_1 ),
        .R(\aresetn_d_reg[0]_2 ));
  LUT6 #(
    .INIT(64'h0F000F000F00909F)) 
    \axaddr_incr[0]_i_1 
       (.I0(Q[0]),
        .I1(\axaddr_incr_reg[0] ),
        .I2(sel_first),
        .I3(\axaddr_incr_reg[10] [0]),
        .I4(Q[44]),
        .I5(Q[43]),
        .O(\m_payload_i_reg[11]_0 [0]));
  LUT6 #(
    .INIT(64'h6A006AFF6AFF6A00)) 
    \axaddr_incr[10]_i_1 
       (.I0(Q[10]),
        .I1(\m_payload_i_reg[8]_0 ),
        .I2(Q[9]),
        .I3(sel_first),
        .I4(\axaddr_incr_reg[10] [6]),
        .I5(\axaddr_incr_reg[10]_0 ),
        .O(\m_payload_i_reg[11]_0 [6]));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT3 #(
    .INIT(8'hF1)) 
    \axaddr_incr[11]_i_10 
       (.I0(Q[0]),
        .I1(Q[43]),
        .I2(Q[44]),
        .O(\m_payload_i_reg[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \axaddr_incr[11]_i_12 
       (.I0(Q[44]),
        .I1(Q[43]),
        .O(\m_payload_i_reg[44]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \axaddr_incr[11]_i_13 
       (.I0(Q[44]),
        .I1(Q[1]),
        .O(\m_payload_i_reg[44]_1 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF48888888)) 
    \axaddr_incr[11]_i_2 
       (.I0(Q[11]),
        .I1(sel_first),
        .I2(Q[9]),
        .I3(\m_payload_i_reg[8]_0 ),
        .I4(Q[10]),
        .I5(\axaddr_incr_reg[11] ),
        .O(\m_payload_i_reg[11]_0 [7]));
  LUT6 #(
    .INIT(64'h0080000000000000)) 
    \axaddr_incr[11]_i_3 
       (.I0(Q[8]),
        .I1(Q[6]),
        .I2(Q[5]),
        .I3(\axaddr_incr_reg[11]_0 ),
        .I4(Q[4]),
        .I5(Q[7]),
        .O(\m_payload_i_reg[8]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT3 #(
    .INIT(8'h2A)) 
    \axaddr_incr[11]_i_8 
       (.I0(Q[2]),
        .I1(Q[44]),
        .I2(Q[43]),
        .O(\m_payload_i_reg[2]_1 ));
  LUT6 #(
    .INIT(64'hAEABAEABAEABAEAE)) 
    \axaddr_incr[1]_i_1 
       (.I0(\axaddr_incr[1]_i_2_n_0 ),
        .I1(\axaddr_incr_reg[10] [1]),
        .I2(sel_first),
        .I3(Q[44]),
        .I4(Q[43]),
        .I5(\axaddr_incr_reg[10] [0]),
        .O(\m_payload_i_reg[11]_0 [1]));
  LUT6 #(
    .INIT(64'h0099009A00000000)) 
    \axaddr_incr[1]_i_2 
       (.I0(Q[1]),
        .I1(\axaddr_incr_reg[0] ),
        .I2(Q[43]),
        .I3(Q[44]),
        .I4(Q[0]),
        .I5(sel_first),
        .O(\axaddr_incr[1]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT5 #(
    .INIT(32'hFBFBFBFF)) 
    \axaddr_incr[2]_i_2 
       (.I0(\axaddr_incr_reg[0] ),
        .I1(Q[1]),
        .I2(Q[44]),
        .I3(Q[43]),
        .I4(Q[0]),
        .O(\m_payload_i_reg[1]_0 ));
  LUT6 #(
    .INIT(64'hD9D5D9D5D9D9D9D5)) 
    \axaddr_incr[2]_i_3 
       (.I0(Q[2]),
        .I1(Q[44]),
        .I2(Q[43]),
        .I3(b_push),
        .I4(\axaddr_incr_reg[3] [1]),
        .I5(\axaddr_incr_reg[3] [0]),
        .O(\m_payload_i_reg[2]_0 ));
  LUT6 #(
    .INIT(64'h606F6F606F60606F)) 
    \axaddr_incr[3]_i_1 
       (.I0(\axaddr_incr[3]_i_2_n_0 ),
        .I1(\axaddr_incr[3]_i_3_n_0 ),
        .I2(sel_first),
        .I3(\m_payload_i_reg[43]_2 ),
        .I4(\axaddr_incr_reg[10] [2]),
        .I5(\axaddr_incr_reg[3]_0 ),
        .O(\m_payload_i_reg[11]_0 [2]));
  LUT6 #(
    .INIT(64'hFFD5FFF7FFD7FFF7)) 
    \axaddr_incr[3]_i_2 
       (.I0(Q[2]),
        .I1(Q[44]),
        .I2(Q[43]),
        .I3(\axaddr_incr_reg[0] ),
        .I4(Q[1]),
        .I5(Q[0]),
        .O(\axaddr_incr[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h99A9555555555555)) 
    \axaddr_incr[3]_i_3 
       (.I0(Q[3]),
        .I1(b_push),
        .I2(\axaddr_incr_reg[3] [1]),
        .I3(\axaddr_incr_reg[3] [0]),
        .I4(Q[44]),
        .I5(Q[43]),
        .O(\axaddr_incr[3]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \axaddr_incr[3]_i_4 
       (.I0(Q[43]),
        .I1(Q[44]),
        .O(\m_payload_i_reg[43]_2 ));
  LUT6 #(
    .INIT(64'hBF0F000040F00000)) 
    \axaddr_incr[4]_i_2 
       (.I0(\axaddr_incr_reg[0] ),
        .I1(\m_payload_i_reg[43]_2 ),
        .I2(Q[3]),
        .I3(\axaddr_incr[3]_i_2_n_0 ),
        .I4(sel_first),
        .I5(Q[4]),
        .O(\m_payload_i_reg[3]_0 ));
  LUT6 #(
    .INIT(64'hA600A6FFA6FFA600)) 
    \axaddr_incr[6]_i_1 
       (.I0(Q[6]),
        .I1(Q[5]),
        .I2(\m_payload_i_reg[3]_1 ),
        .I3(sel_first),
        .I4(\axaddr_incr_reg[10] [3]),
        .I5(\axaddr_incr_reg[6] ),
        .O(\m_payload_i_reg[11]_0 [3]));
  LUT6 #(
    .INIT(64'hBBBB3BBBFFFFFFFF)) 
    \axaddr_incr[6]_i_2 
       (.I0(\axaddr_incr[3]_i_2_n_0 ),
        .I1(Q[3]),
        .I2(Q[43]),
        .I3(Q[44]),
        .I4(\axaddr_incr_reg[0] ),
        .I5(Q[4]),
        .O(\m_payload_i_reg[3]_1 ));
  LUT6 #(
    .INIT(64'h9A009AFF9AFF9A00)) 
    \axaddr_incr[7]_i_1 
       (.I0(Q[7]),
        .I1(\axaddr_incr[7]_i_2_n_0 ),
        .I2(Q[6]),
        .I3(sel_first),
        .I4(\axaddr_incr_reg[10] [4]),
        .I5(\axaddr_incr_reg[7] ),
        .O(\m_payload_i_reg[11]_0 [4]));
  LUT6 #(
    .INIT(64'hDFFF55FFFFFFFFFF)) 
    \axaddr_incr[7]_i_2 
       (.I0(Q[4]),
        .I1(\axaddr_incr_reg[0] ),
        .I2(\m_payload_i_reg[43]_2 ),
        .I3(Q[3]),
        .I4(\axaddr_incr[3]_i_2_n_0 ),
        .I5(Q[5]),
        .O(\axaddr_incr[7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h6A006AFF6AFF6A00)) 
    \axaddr_incr[8]_i_1 
       (.I0(Q[8]),
        .I1(\axaddr_incr[8]_i_2_n_0 ),
        .I2(Q[7]),
        .I3(sel_first),
        .I4(\axaddr_incr_reg[10] [5]),
        .I5(\axaddr_incr_reg[8] ),
        .O(\m_payload_i_reg[11]_0 [5]));
  LUT6 #(
    .INIT(64'h0800888800000000)) 
    \axaddr_incr[8]_i_2 
       (.I0(Q[6]),
        .I1(Q[5]),
        .I2(\axaddr_incr[3]_i_2_n_0 ),
        .I3(Q[3]),
        .I4(\axaddr_incr[8]_i_4_n_0 ),
        .I5(Q[4]),
        .O(\axaddr_incr[8]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h7777F7FFFFFFFFFF)) 
    \axaddr_incr[8]_i_4 
       (.I0(Q[43]),
        .I1(Q[44]),
        .I2(\axaddr_incr_reg[3] [0]),
        .I3(\axaddr_incr_reg[3] [1]),
        .I4(b_push),
        .I5(Q[3]),
        .O(\axaddr_incr[8]_i_4_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \axaddr_offset_r[0]_i_1 
       (.I0(\m_payload_i_reg[52]_0 ),
        .O(D));
  LUT6 #(
    .INIT(64'h00000700FFFFF7FF)) 
    \axaddr_offset_r[0]_i_2 
       (.I0(\axaddr_offset_r[0]_i_3_n_0 ),
        .I1(Q[47]),
        .I2(\axaddr_incr_reg[3] [0]),
        .I3(m_valid_i_reg_0),
        .I4(\axaddr_incr_reg[3] [1]),
        .I5(\axaddr_offset_r_reg[0] ),
        .O(\m_payload_i_reg[52]_0 ));
  LUT6 #(
    .INIT(64'hFC0CFAFAFC0C0A0A)) 
    \axaddr_offset_r[0]_i_3 
       (.I0(Q[0]),
        .I1(Q[2]),
        .I2(Q[43]),
        .I3(Q[3]),
        .I4(Q[44]),
        .I5(Q[1]),
        .O(\axaddr_offset_r[0]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hF5DD5555)) 
    \axaddr_offset_r[1]_i_2 
       (.I0(\axaddr_offset_r_reg[1] ),
        .I1(\axaddr_offset_r[1]_i_3_n_0 ),
        .I2(\axaddr_offset_r[2]_i_3_n_0 ),
        .I3(Q[43]),
        .I4(Q[48]),
        .O(\m_payload_i_reg[43]_1 ));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axaddr_offset_r[1]_i_3 
       (.I0(Q[3]),
        .I1(Q[44]),
        .I2(Q[1]),
        .O(\axaddr_offset_r[1]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hF5DD5555)) 
    \axaddr_offset_r[2]_i_2 
       (.I0(\axaddr_offset_r_reg[1] ),
        .I1(\axaddr_offset_r[2]_i_3_n_0 ),
        .I2(\axaddr_offset_r[3]_i_3_n_0 ),
        .I3(Q[43]),
        .I4(Q[49]),
        .O(\m_payload_i_reg[43]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axaddr_offset_r[2]_i_3 
       (.I0(Q[4]),
        .I1(Q[44]),
        .I2(Q[2]),
        .O(\axaddr_offset_r[2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hBF8FB08000000000)) 
    \axaddr_offset_r[3]_i_2 
       (.I0(Q[6]),
        .I1(Q[44]),
        .I2(Q[43]),
        .I3(Q[4]),
        .I4(\axaddr_offset_r[3]_i_3_n_0 ),
        .I5(\axaddr_offset_r[3]_i_4_n_0 ),
        .O(\m_payload_i_reg[6]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axaddr_offset_r[3]_i_3 
       (.I0(Q[5]),
        .I1(Q[44]),
        .I2(Q[3]),
        .O(\axaddr_offset_r[3]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'h0020)) 
    \axaddr_offset_r[3]_i_4 
       (.I0(Q[50]),
        .I1(\axaddr_incr_reg[3] [0]),
        .I2(m_valid_i_reg_0),
        .I3(\axaddr_incr_reg[3] [1]),
        .O(\axaddr_offset_r[3]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \axaddr_wrap[0]_i_2__0 
       (.I0(Q[43]),
        .I1(Q[44]),
        .O(\m_payload_i_reg[43]_3 ));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT3 #(
    .INIT(8'hF1)) 
    \axaddr_wrap[1]_i_2__0 
       (.I0(\axaddr_wrap_reg[3]_0 [0]),
        .I1(Q[43]),
        .I2(Q[44]),
        .O(\axaddr_wrap_reg[0] ));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT3 #(
    .INIT(8'h9A)) 
    \axaddr_wrap[2]_i_2 
       (.I0(\axaddr_wrap_reg[3]_0 [1]),
        .I1(Q[43]),
        .I2(Q[44]),
        .O(\axaddr_wrap_reg[2] ));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \axaddr_wrap[3]_i_2 
       (.I0(\axaddr_wrap_reg[3]_0 [2]),
        .I1(Q[44]),
        .I2(Q[43]),
        .O(\axaddr_wrap_reg[3] ));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[0]_i_1 
       (.I0(s_axi_awaddr[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[0] ),
        .O(skid_buffer[0]));
  (* SOFT_HLUTNM = "soft_lutpair101" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[10]_i_1 
       (.I0(s_axi_awaddr[10]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[10] ),
        .O(skid_buffer[10]));
  (* SOFT_HLUTNM = "soft_lutpair104" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[11]_i_1 
       (.I0(s_axi_awaddr[11]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[11] ),
        .O(skid_buffer[11]));
  (* SOFT_HLUTNM = "soft_lutpair103" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[12]_i_1 
       (.I0(s_axi_awaddr[12]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[12] ),
        .O(skid_buffer[12]));
  (* SOFT_HLUTNM = "soft_lutpair102" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[13]_i_1 
       (.I0(s_axi_awaddr[13]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[13] ),
        .O(skid_buffer[13]));
  (* SOFT_HLUTNM = "soft_lutpair101" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[14]_i_1 
       (.I0(s_axi_awaddr[14]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[14] ),
        .O(skid_buffer[14]));
  (* SOFT_HLUTNM = "soft_lutpair100" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[15]_i_1 
       (.I0(s_axi_awaddr[15]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[15] ),
        .O(skid_buffer[15]));
  (* SOFT_HLUTNM = "soft_lutpair100" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[16]_i_1 
       (.I0(s_axi_awaddr[16]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[16] ),
        .O(skid_buffer[16]));
  (* SOFT_HLUTNM = "soft_lutpair95" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[17]_i_1__0 
       (.I0(s_axi_awaddr[17]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[17] ),
        .O(skid_buffer[17]));
  (* SOFT_HLUTNM = "soft_lutpair93" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[18]_i_1 
       (.I0(s_axi_awaddr[18]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[18] ),
        .O(skid_buffer[18]));
  (* SOFT_HLUTNM = "soft_lutpair92" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[19]_i_1 
       (.I0(s_axi_awaddr[19]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[19] ),
        .O(skid_buffer[19]));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[1]_i_1 
       (.I0(s_axi_awaddr[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[1] ),
        .O(skid_buffer[1]));
  (* SOFT_HLUTNM = "soft_lutpair99" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[20]_i_1 
       (.I0(s_axi_awaddr[20]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[20] ),
        .O(skid_buffer[20]));
  (* SOFT_HLUTNM = "soft_lutpair99" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[21]_i_1 
       (.I0(s_axi_awaddr[21]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[21] ),
        .O(skid_buffer[21]));
  (* SOFT_HLUTNM = "soft_lutpair98" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[22]_i_1 
       (.I0(s_axi_awaddr[22]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[22] ),
        .O(skid_buffer[22]));
  (* SOFT_HLUTNM = "soft_lutpair98" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[23]_i_1 
       (.I0(s_axi_awaddr[23]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[23] ),
        .O(skid_buffer[23]));
  (* SOFT_HLUTNM = "soft_lutpair97" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[24]_i_1 
       (.I0(s_axi_awaddr[24]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[24] ),
        .O(skid_buffer[24]));
  (* SOFT_HLUTNM = "soft_lutpair97" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[25]_i_1 
       (.I0(s_axi_awaddr[25]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[25] ),
        .O(skid_buffer[25]));
  (* SOFT_HLUTNM = "soft_lutpair96" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[26]_i_1 
       (.I0(s_axi_awaddr[26]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[26] ),
        .O(skid_buffer[26]));
  (* SOFT_HLUTNM = "soft_lutpair96" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[27]_i_1 
       (.I0(s_axi_awaddr[27]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[27] ),
        .O(skid_buffer[27]));
  (* SOFT_HLUTNM = "soft_lutpair95" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[28]_i_1 
       (.I0(s_axi_awaddr[28]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[28] ),
        .O(skid_buffer[28]));
  (* SOFT_HLUTNM = "soft_lutpair94" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[29]_i_1 
       (.I0(s_axi_awaddr[29]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[29] ),
        .O(skid_buffer[29]));
  (* SOFT_HLUTNM = "soft_lutpair106" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[2]_i_1 
       (.I0(s_axi_awaddr[2]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[2] ),
        .O(skid_buffer[2]));
  (* SOFT_HLUTNM = "soft_lutpair91" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[30]_i_1 
       (.I0(s_axi_awaddr[30]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[30] ),
        .O(skid_buffer[30]));
  (* SOFT_HLUTNM = "soft_lutpair94" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[31]_i_1 
       (.I0(s_axi_awaddr[31]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[31] ),
        .O(skid_buffer[31]));
  (* SOFT_HLUTNM = "soft_lutpair93" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[32]_i_1 
       (.I0(s_axi_awaddr[32]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[32] ),
        .O(skid_buffer[32]));
  (* SOFT_HLUTNM = "soft_lutpair92" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[33]_i_1 
       (.I0(s_axi_awaddr[33]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[33] ),
        .O(skid_buffer[33]));
  (* SOFT_HLUTNM = "soft_lutpair91" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[34]_i_1 
       (.I0(s_axi_awaddr[34]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[34] ),
        .O(skid_buffer[34]));
  (* SOFT_HLUTNM = "soft_lutpair80" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[35]_i_1 
       (.I0(s_axi_awaddr[35]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[35] ),
        .O(skid_buffer[35]));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[36]_i_1 
       (.I0(s_axi_awaddr[36]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[36] ),
        .O(skid_buffer[36]));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[37]_i_1 
       (.I0(s_axi_awaddr[37]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[37] ),
        .O(skid_buffer[37]));
  (* SOFT_HLUTNM = "soft_lutpair90" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[38]_i_1 
       (.I0(s_axi_awaddr[38]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[38] ),
        .O(skid_buffer[38]));
  (* SOFT_HLUTNM = "soft_lutpair90" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[39]_i_2 
       (.I0(s_axi_awaddr[39]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[39] ),
        .O(skid_buffer[39]));
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[3]_i_1 
       (.I0(s_axi_awaddr[3]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[3] ),
        .O(skid_buffer[3]));
  (* SOFT_HLUTNM = "soft_lutpair89" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[40]_i_1 
       (.I0(s_axi_awprot[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[40] ),
        .O(skid_buffer[40]));
  (* SOFT_HLUTNM = "soft_lutpair89" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[41]_i_1 
       (.I0(s_axi_awprot[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[41] ),
        .O(skid_buffer[41]));
  (* SOFT_HLUTNM = "soft_lutpair88" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[42]_i_1 
       (.I0(s_axi_awprot[2]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[42] ),
        .O(skid_buffer[42]));
  (* SOFT_HLUTNM = "soft_lutpair88" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[43]_i_1 
       (.I0(s_axi_awsize[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[43] ),
        .O(skid_buffer[43]));
  (* SOFT_HLUTNM = "soft_lutpair87" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[44]_i_1 
       (.I0(s_axi_awsize[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[44] ),
        .O(skid_buffer[44]));
  (* SOFT_HLUTNM = "soft_lutpair87" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[46]_i_1 
       (.I0(s_axi_awburst[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[46] ),
        .O(skid_buffer[46]));
  (* SOFT_HLUTNM = "soft_lutpair86" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[47]_i_1 
       (.I0(s_axi_awburst[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[47] ),
        .O(skid_buffer[47]));
  (* SOFT_HLUTNM = "soft_lutpair106" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[4]_i_1 
       (.I0(s_axi_awaddr[4]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[4] ),
        .O(skid_buffer[4]));
  (* SOFT_HLUTNM = "soft_lutpair86" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[52]_i_1 
       (.I0(s_axi_awlen[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[52] ),
        .O(skid_buffer[52]));
  (* SOFT_HLUTNM = "soft_lutpair85" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[53]_i_1 
       (.I0(s_axi_awlen[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[53] ),
        .O(skid_buffer[53]));
  (* SOFT_HLUTNM = "soft_lutpair85" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[54]_i_1 
       (.I0(s_axi_awlen[2]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[54] ),
        .O(skid_buffer[54]));
  (* SOFT_HLUTNM = "soft_lutpair84" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[55]_i_1 
       (.I0(s_axi_awlen[3]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[55] ),
        .O(skid_buffer[55]));
  (* SOFT_HLUTNM = "soft_lutpair84" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[56]_i_1 
       (.I0(s_axi_awlen[4]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[56] ),
        .O(skid_buffer[56]));
  (* SOFT_HLUTNM = "soft_lutpair83" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[57]_i_1 
       (.I0(s_axi_awlen[5]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[57] ),
        .O(skid_buffer[57]));
  (* SOFT_HLUTNM = "soft_lutpair83" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[58]_i_1 
       (.I0(s_axi_awlen[6]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[58] ),
        .O(skid_buffer[58]));
  (* SOFT_HLUTNM = "soft_lutpair82" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[59]_i_1 
       (.I0(s_axi_awlen[7]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[59] ),
        .O(skid_buffer[59]));
  (* SOFT_HLUTNM = "soft_lutpair105" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[5]_i_1 
       (.I0(s_axi_awaddr[5]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[5] ),
        .O(skid_buffer[5]));
  (* SOFT_HLUTNM = "soft_lutpair82" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[61]_i_1 
       (.I0(s_axi_awid[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[61] ),
        .O(skid_buffer[61]));
  (* SOFT_HLUTNM = "soft_lutpair81" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[62]_i_1 
       (.I0(s_axi_awid[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[62] ),
        .O(skid_buffer[62]));
  (* SOFT_HLUTNM = "soft_lutpair81" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[63]_i_1 
       (.I0(s_axi_awid[2]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[63] ),
        .O(skid_buffer[63]));
  (* SOFT_HLUTNM = "soft_lutpair80" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[64]_i_1 
       (.I0(s_axi_awid[3]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[64] ),
        .O(skid_buffer[64]));
  (* SOFT_HLUTNM = "soft_lutpair79" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[65]_i_1 
       (.I0(s_axi_awid[4]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[65] ),
        .O(skid_buffer[65]));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[66]_i_1 
       (.I0(s_axi_awid[5]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[66] ),
        .O(skid_buffer[66]));
  (* SOFT_HLUTNM = "soft_lutpair79" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[67]_i_1 
       (.I0(s_axi_awid[6]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[67] ),
        .O(skid_buffer[67]));
  (* SOFT_HLUTNM = "soft_lutpair78" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[68]_i_1 
       (.I0(s_axi_awid[7]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[68] ),
        .O(skid_buffer[68]));
  (* SOFT_HLUTNM = "soft_lutpair78" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[69]_i_1 
       (.I0(s_axi_awid[8]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[69] ),
        .O(skid_buffer[69]));
  (* SOFT_HLUTNM = "soft_lutpair105" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[6]_i_1 
       (.I0(s_axi_awaddr[6]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[6] ),
        .O(skid_buffer[6]));
  (* SOFT_HLUTNM = "soft_lutpair77" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[70]_i_1 
       (.I0(s_axi_awid[9]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[70] ),
        .O(skid_buffer[70]));
  (* SOFT_HLUTNM = "soft_lutpair77" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[71]_i_1 
       (.I0(s_axi_awid[10]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[71] ),
        .O(skid_buffer[71]));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[72]_i_1 
       (.I0(s_axi_awid[11]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[72] ),
        .O(skid_buffer[72]));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[73]_i_1 
       (.I0(s_axi_awid[12]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[73] ),
        .O(skid_buffer[73]));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[74]_i_1 
       (.I0(s_axi_awid[13]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[74] ),
        .O(skid_buffer[74]));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[75]_i_1 
       (.I0(s_axi_awid[14]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[75] ),
        .O(skid_buffer[75]));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[76]_i_1 
       (.I0(s_axi_awid[15]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[76] ),
        .O(skid_buffer[76]));
  (* SOFT_HLUTNM = "soft_lutpair104" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[7]_i_1 
       (.I0(s_axi_awaddr[7]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[7] ),
        .O(skid_buffer[7]));
  (* SOFT_HLUTNM = "soft_lutpair103" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[8]_i_1 
       (.I0(s_axi_awaddr[8]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[8] ),
        .O(skid_buffer[8]));
  (* SOFT_HLUTNM = "soft_lutpair102" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[9]_i_1 
       (.I0(s_axi_awaddr[9]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[9] ),
        .O(skid_buffer[9]));
  FDRE \m_payload_i_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[0]),
        .Q(Q[0]),
        .R(1'b0));
  FDRE \m_payload_i_reg[10] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[10]),
        .Q(Q[10]),
        .R(1'b0));
  FDRE \m_payload_i_reg[11] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[11]),
        .Q(Q[11]),
        .R(1'b0));
  FDRE \m_payload_i_reg[12] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[12]),
        .Q(Q[12]),
        .R(1'b0));
  FDRE \m_payload_i_reg[13] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[13]),
        .Q(Q[13]),
        .R(1'b0));
  FDRE \m_payload_i_reg[14] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[14]),
        .Q(Q[14]),
        .R(1'b0));
  FDRE \m_payload_i_reg[15] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[15]),
        .Q(Q[15]),
        .R(1'b0));
  FDRE \m_payload_i_reg[16] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[16]),
        .Q(Q[16]),
        .R(1'b0));
  FDRE \m_payload_i_reg[17] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[17]),
        .Q(Q[17]),
        .R(1'b0));
  FDRE \m_payload_i_reg[18] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[18]),
        .Q(Q[18]),
        .R(1'b0));
  FDRE \m_payload_i_reg[19] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[19]),
        .Q(Q[19]),
        .R(1'b0));
  FDRE \m_payload_i_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[1]),
        .Q(Q[1]),
        .R(1'b0));
  FDRE \m_payload_i_reg[20] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[20]),
        .Q(Q[20]),
        .R(1'b0));
  FDRE \m_payload_i_reg[21] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[21]),
        .Q(Q[21]),
        .R(1'b0));
  FDRE \m_payload_i_reg[22] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[22]),
        .Q(Q[22]),
        .R(1'b0));
  FDRE \m_payload_i_reg[23] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[23]),
        .Q(Q[23]),
        .R(1'b0));
  FDRE \m_payload_i_reg[24] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[24]),
        .Q(Q[24]),
        .R(1'b0));
  FDRE \m_payload_i_reg[25] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[25]),
        .Q(Q[25]),
        .R(1'b0));
  FDRE \m_payload_i_reg[26] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[26]),
        .Q(Q[26]),
        .R(1'b0));
  FDRE \m_payload_i_reg[27] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[27]),
        .Q(Q[27]),
        .R(1'b0));
  FDRE \m_payload_i_reg[28] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[28]),
        .Q(Q[28]),
        .R(1'b0));
  FDRE \m_payload_i_reg[29] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[29]),
        .Q(Q[29]),
        .R(1'b0));
  FDRE \m_payload_i_reg[2] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[2]),
        .Q(Q[2]),
        .R(1'b0));
  FDRE \m_payload_i_reg[30] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[30]),
        .Q(Q[30]),
        .R(1'b0));
  FDRE \m_payload_i_reg[31] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[31]),
        .Q(Q[31]),
        .R(1'b0));
  FDRE \m_payload_i_reg[32] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[32]),
        .Q(Q[32]),
        .R(1'b0));
  FDRE \m_payload_i_reg[33] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[33]),
        .Q(Q[33]),
        .R(1'b0));
  FDRE \m_payload_i_reg[34] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[34]),
        .Q(Q[34]),
        .R(1'b0));
  FDRE \m_payload_i_reg[35] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[35]),
        .Q(Q[35]),
        .R(1'b0));
  FDRE \m_payload_i_reg[36] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[36]),
        .Q(Q[36]),
        .R(1'b0));
  FDRE \m_payload_i_reg[37] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[37]),
        .Q(Q[37]),
        .R(1'b0));
  FDRE \m_payload_i_reg[38] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[38]),
        .Q(Q[38]),
        .R(1'b0));
  FDRE \m_payload_i_reg[39] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[39]),
        .Q(Q[39]),
        .R(1'b0));
  FDRE \m_payload_i_reg[3] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[3]),
        .Q(Q[3]),
        .R(1'b0));
  FDRE \m_payload_i_reg[40] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[40]),
        .Q(Q[40]),
        .R(1'b0));
  FDRE \m_payload_i_reg[41] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[41]),
        .Q(Q[41]),
        .R(1'b0));
  FDRE \m_payload_i_reg[42] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[42]),
        .Q(Q[42]),
        .R(1'b0));
  FDRE \m_payload_i_reg[43] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[43]),
        .Q(Q[43]),
        .R(1'b0));
  FDRE \m_payload_i_reg[44] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[44]),
        .Q(Q[44]),
        .R(1'b0));
  FDRE \m_payload_i_reg[46] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[46]),
        .Q(Q[45]),
        .R(1'b0));
  FDRE \m_payload_i_reg[47] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[47]),
        .Q(Q[46]),
        .R(1'b0));
  FDRE \m_payload_i_reg[4] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[4]),
        .Q(Q[4]),
        .R(1'b0));
  FDRE \m_payload_i_reg[52] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[52]),
        .Q(Q[47]),
        .R(1'b0));
  FDRE \m_payload_i_reg[53] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[53]),
        .Q(Q[48]),
        .R(1'b0));
  FDRE \m_payload_i_reg[54] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[54]),
        .Q(Q[49]),
        .R(1'b0));
  FDRE \m_payload_i_reg[55] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[55]),
        .Q(Q[50]),
        .R(1'b0));
  FDRE \m_payload_i_reg[56] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[56]),
        .Q(Q[51]),
        .R(1'b0));
  FDRE \m_payload_i_reg[57] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[57]),
        .Q(Q[52]),
        .R(1'b0));
  FDRE \m_payload_i_reg[58] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[58]),
        .Q(Q[53]),
        .R(1'b0));
  FDRE \m_payload_i_reg[59] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[59]),
        .Q(Q[54]),
        .R(1'b0));
  FDRE \m_payload_i_reg[5] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[5]),
        .Q(Q[5]),
        .R(1'b0));
  FDRE \m_payload_i_reg[61] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[61]),
        .Q(Q[55]),
        .R(1'b0));
  FDRE \m_payload_i_reg[62] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[62]),
        .Q(Q[56]),
        .R(1'b0));
  FDRE \m_payload_i_reg[63] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[63]),
        .Q(Q[57]),
        .R(1'b0));
  FDRE \m_payload_i_reg[64] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[64]),
        .Q(Q[58]),
        .R(1'b0));
  FDRE \m_payload_i_reg[65] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[65]),
        .Q(Q[59]),
        .R(1'b0));
  FDRE \m_payload_i_reg[66] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[66]),
        .Q(Q[60]),
        .R(1'b0));
  FDRE \m_payload_i_reg[67] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[67]),
        .Q(Q[61]),
        .R(1'b0));
  FDRE \m_payload_i_reg[68] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[68]),
        .Q(Q[62]),
        .R(1'b0));
  FDRE \m_payload_i_reg[69] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[69]),
        .Q(Q[63]),
        .R(1'b0));
  FDRE \m_payload_i_reg[6] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[6]),
        .Q(Q[6]),
        .R(1'b0));
  FDRE \m_payload_i_reg[70] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[70]),
        .Q(Q[64]),
        .R(1'b0));
  FDRE \m_payload_i_reg[71] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[71]),
        .Q(Q[65]),
        .R(1'b0));
  FDRE \m_payload_i_reg[72] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[72]),
        .Q(Q[66]),
        .R(1'b0));
  FDRE \m_payload_i_reg[73] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[73]),
        .Q(Q[67]),
        .R(1'b0));
  FDRE \m_payload_i_reg[74] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[74]),
        .Q(Q[68]),
        .R(1'b0));
  FDRE \m_payload_i_reg[75] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[75]),
        .Q(Q[69]),
        .R(1'b0));
  FDRE \m_payload_i_reg[76] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[76]),
        .Q(Q[70]),
        .R(1'b0));
  FDRE \m_payload_i_reg[7] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[7]),
        .Q(Q[7]),
        .R(1'b0));
  FDRE \m_payload_i_reg[8] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[8]),
        .Q(Q[8]),
        .R(1'b0));
  FDRE \m_payload_i_reg[9] 
       (.C(aclk),
        .CE(E),
        .D(skid_buffer[9]),
        .Q(Q[9]),
        .R(1'b0));
  LUT4 #(
    .INIT(16'hF4FF)) 
    m_valid_i_i_1__1
       (.I0(b_push),
        .I1(m_valid_i_reg_0),
        .I2(s_axi_awvalid),
        .I3(s_ready_i_reg_0),
        .O(m_valid_i_i_1__1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    m_valid_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(m_valid_i_i_1__1_n_0),
        .Q(m_valid_i_reg_0),
        .R(m_valid_i_reg_1));
  LUT4 #(
    .INIT(16'hFFFE)) 
    next_pending_r_i_3__0
       (.I0(Q[48]),
        .I1(Q[49]),
        .I2(Q[50]),
        .I3(Q[47]),
        .O(\m_payload_i_reg[53]_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    next_pending_r_i_4
       (.I0(Q[49]),
        .I1(Q[48]),
        .I2(Q[47]),
        .I3(Q[52]),
        .I4(next_pending_r_i_6_n_0),
        .O(\m_payload_i_reg[54]_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    next_pending_r_i_6
       (.I0(Q[54]),
        .I1(Q[50]),
        .I2(Q[53]),
        .I3(Q[51]),
        .O(next_pending_r_i_6_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    s_ready_i_i_1__0
       (.I0(\aresetn_d_reg[0]_1 ),
        .O(\aresetn_d_reg[0]_0 ));
  LUT4 #(
    .INIT(16'hF4FF)) 
    s_ready_i_i_2
       (.I0(s_axi_awvalid),
        .I1(s_ready_i_reg_0),
        .I2(b_push),
        .I3(m_valid_i_reg_0),
        .O(s_ready_i0));
  FDRE #(
    .INIT(1'b0)) 
    s_ready_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(s_ready_i0),
        .Q(s_ready_i_reg_0),
        .R(\aresetn_d_reg[0]_0 ));
  FDRE \skid_buffer_reg[0] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[0]),
        .Q(\skid_buffer_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[10] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[10]),
        .Q(\skid_buffer_reg_n_0_[10] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[11] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[11]),
        .Q(\skid_buffer_reg_n_0_[11] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[12] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[12]),
        .Q(\skid_buffer_reg_n_0_[12] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[13] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[13]),
        .Q(\skid_buffer_reg_n_0_[13] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[14] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[14]),
        .Q(\skid_buffer_reg_n_0_[14] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[15] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[15]),
        .Q(\skid_buffer_reg_n_0_[15] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[16] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[16]),
        .Q(\skid_buffer_reg_n_0_[16] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[17] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[17]),
        .Q(\skid_buffer_reg_n_0_[17] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[18] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[18]),
        .Q(\skid_buffer_reg_n_0_[18] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[19] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[19]),
        .Q(\skid_buffer_reg_n_0_[19] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[1] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[1]),
        .Q(\skid_buffer_reg_n_0_[1] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[20] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[20]),
        .Q(\skid_buffer_reg_n_0_[20] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[21] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[21]),
        .Q(\skid_buffer_reg_n_0_[21] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[22] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[22]),
        .Q(\skid_buffer_reg_n_0_[22] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[23] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[23]),
        .Q(\skid_buffer_reg_n_0_[23] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[24] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[24]),
        .Q(\skid_buffer_reg_n_0_[24] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[25] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[25]),
        .Q(\skid_buffer_reg_n_0_[25] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[26] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[26]),
        .Q(\skid_buffer_reg_n_0_[26] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[27] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[27]),
        .Q(\skid_buffer_reg_n_0_[27] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[28] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[28]),
        .Q(\skid_buffer_reg_n_0_[28] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[29] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[29]),
        .Q(\skid_buffer_reg_n_0_[29] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[2] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[2]),
        .Q(\skid_buffer_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[30] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[30]),
        .Q(\skid_buffer_reg_n_0_[30] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[31] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[31]),
        .Q(\skid_buffer_reg_n_0_[31] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[32] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[32]),
        .Q(\skid_buffer_reg_n_0_[32] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[33] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[33]),
        .Q(\skid_buffer_reg_n_0_[33] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[34] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[34]),
        .Q(\skid_buffer_reg_n_0_[34] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[35] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[35]),
        .Q(\skid_buffer_reg_n_0_[35] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[36] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[36]),
        .Q(\skid_buffer_reg_n_0_[36] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[37] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[37]),
        .Q(\skid_buffer_reg_n_0_[37] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[38] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[38]),
        .Q(\skid_buffer_reg_n_0_[38] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[39] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[39]),
        .Q(\skid_buffer_reg_n_0_[39] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[3] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[3]),
        .Q(\skid_buffer_reg_n_0_[3] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[40] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awprot[0]),
        .Q(\skid_buffer_reg_n_0_[40] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[41] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awprot[1]),
        .Q(\skid_buffer_reg_n_0_[41] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[42] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awprot[2]),
        .Q(\skid_buffer_reg_n_0_[42] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[43] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awsize[0]),
        .Q(\skid_buffer_reg_n_0_[43] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[44] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awsize[1]),
        .Q(\skid_buffer_reg_n_0_[44] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[46] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awburst[0]),
        .Q(\skid_buffer_reg_n_0_[46] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[47] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awburst[1]),
        .Q(\skid_buffer_reg_n_0_[47] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[4] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[4]),
        .Q(\skid_buffer_reg_n_0_[4] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[52] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awlen[0]),
        .Q(\skid_buffer_reg_n_0_[52] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[53] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awlen[1]),
        .Q(\skid_buffer_reg_n_0_[53] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[54] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awlen[2]),
        .Q(\skid_buffer_reg_n_0_[54] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[55] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awlen[3]),
        .Q(\skid_buffer_reg_n_0_[55] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[56] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awlen[4]),
        .Q(\skid_buffer_reg_n_0_[56] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[57] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awlen[5]),
        .Q(\skid_buffer_reg_n_0_[57] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[58] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awlen[6]),
        .Q(\skid_buffer_reg_n_0_[58] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[59] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awlen[7]),
        .Q(\skid_buffer_reg_n_0_[59] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[5] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[5]),
        .Q(\skid_buffer_reg_n_0_[5] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[61] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[0]),
        .Q(\skid_buffer_reg_n_0_[61] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[62] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[1]),
        .Q(\skid_buffer_reg_n_0_[62] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[63] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[2]),
        .Q(\skid_buffer_reg_n_0_[63] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[64] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[3]),
        .Q(\skid_buffer_reg_n_0_[64] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[65] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[4]),
        .Q(\skid_buffer_reg_n_0_[65] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[66] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[5]),
        .Q(\skid_buffer_reg_n_0_[66] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[67] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[6]),
        .Q(\skid_buffer_reg_n_0_[67] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[68] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[7]),
        .Q(\skid_buffer_reg_n_0_[68] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[69] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[8]),
        .Q(\skid_buffer_reg_n_0_[69] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[6] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[6]),
        .Q(\skid_buffer_reg_n_0_[6] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[70] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[9]),
        .Q(\skid_buffer_reg_n_0_[70] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[71] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[10]),
        .Q(\skid_buffer_reg_n_0_[71] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[72] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[11]),
        .Q(\skid_buffer_reg_n_0_[72] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[73] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[12]),
        .Q(\skid_buffer_reg_n_0_[73] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[74] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[13]),
        .Q(\skid_buffer_reg_n_0_[74] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[75] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[14]),
        .Q(\skid_buffer_reg_n_0_[75] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[76] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awid[15]),
        .Q(\skid_buffer_reg_n_0_[76] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[7] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[7]),
        .Q(\skid_buffer_reg_n_0_[7] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[8] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[8]),
        .Q(\skid_buffer_reg_n_0_[8] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[9] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(s_axi_awaddr[9]),
        .Q(\skid_buffer_reg_n_0_[9] ),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT4 #(
    .INIT(16'hAA8A)) 
    \wrap_boundary_axaddr_r[0]_i_1__0 
       (.I0(Q[0]),
        .I1(Q[43]),
        .I2(Q[47]),
        .I3(Q[44]),
        .O(\m_payload_i_reg[6]_1 [0]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT5 #(
    .INIT(32'hFF470000)) 
    \wrap_boundary_axaddr_r[1]_i_1 
       (.I0(Q[47]),
        .I1(Q[43]),
        .I2(Q[48]),
        .I3(Q[44]),
        .I4(Q[1]),
        .O(\m_payload_i_reg[6]_1 [1]));
  LUT6 #(
    .INIT(64'hA0A002A2AAAA02A2)) 
    \wrap_boundary_axaddr_r[2]_i_1 
       (.I0(Q[2]),
        .I1(Q[49]),
        .I2(Q[43]),
        .I3(Q[48]),
        .I4(Q[44]),
        .I5(Q[47]),
        .O(\m_payload_i_reg[6]_1 [2]));
  LUT6 #(
    .INIT(64'h4747000000FF0000)) 
    \wrap_boundary_axaddr_r[3]_i_1 
       (.I0(Q[47]),
        .I1(Q[43]),
        .I2(Q[48]),
        .I3(\wrap_boundary_axaddr_r[3]_i_2_n_0 ),
        .I4(Q[3]),
        .I5(Q[44]),
        .O(\m_payload_i_reg[6]_1 [3]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \wrap_boundary_axaddr_r[3]_i_2 
       (.I0(Q[49]),
        .I1(Q[43]),
        .I2(Q[50]),
        .O(\wrap_boundary_axaddr_r[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h002A0A2AA02AAA2A)) 
    \wrap_boundary_axaddr_r[4]_i_1__0 
       (.I0(Q[4]),
        .I1(Q[50]),
        .I2(Q[43]),
        .I3(Q[44]),
        .I4(Q[49]),
        .I5(Q[48]),
        .O(\m_payload_i_reg[6]_1 [4]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT5 #(
    .INIT(32'h47FF0000)) 
    \wrap_boundary_axaddr_r[5]_i_1 
       (.I0(Q[49]),
        .I1(Q[43]),
        .I2(Q[50]),
        .I3(Q[44]),
        .I4(Q[5]),
        .O(\m_payload_i_reg[6]_1 [5]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT4 #(
    .INIT(16'h2AAA)) 
    \wrap_boundary_axaddr_r[6]_i_1 
       (.I0(Q[6]),
        .I1(Q[43]),
        .I2(Q[44]),
        .I3(Q[50]),
        .O(\m_payload_i_reg[6]_1 [6]));
endmodule

(* ORIG_REF_NAME = "axi_register_slice_v2_1_20_axic_register_slice" *) 
module zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axic_register_slice__parameterized1
   (m_valid_i_reg_0,
    s_ready_i_reg_0,
    shandshake,
    \m_payload_i_reg[17]_0 ,
    m_valid_i_reg_1,
    aclk,
    s_ready_i_reg_1,
    si_rs_bvalid,
    s_axi_bready,
    out,
    \skid_buffer_reg[1]_0 );
  output m_valid_i_reg_0;
  output s_ready_i_reg_0;
  output shandshake;
  output [17:0]\m_payload_i_reg[17]_0 ;
  input m_valid_i_reg_1;
  input aclk;
  input s_ready_i_reg_1;
  input si_rs_bvalid;
  input s_axi_bready;
  input [15:0]out;
  input [1:0]\skid_buffer_reg[1]_0 ;

  wire aclk;
  wire \m_payload_i[0]_i_1__1_n_0 ;
  wire \m_payload_i[10]_i_1__1_n_0 ;
  wire \m_payload_i[11]_i_1__1_n_0 ;
  wire \m_payload_i[12]_i_1__1_n_0 ;
  wire \m_payload_i[13]_i_1__1_n_0 ;
  wire \m_payload_i[14]_i_1__1_n_0 ;
  wire \m_payload_i[15]_i_1__1_n_0 ;
  wire \m_payload_i[16]_i_1__1_n_0 ;
  wire \m_payload_i[17]_i_2_n_0 ;
  wire \m_payload_i[1]_i_1__1_n_0 ;
  wire \m_payload_i[2]_i_1__1_n_0 ;
  wire \m_payload_i[3]_i_1__1_n_0 ;
  wire \m_payload_i[4]_i_1__1_n_0 ;
  wire \m_payload_i[5]_i_1__1_n_0 ;
  wire \m_payload_i[6]_i_1__1_n_0 ;
  wire \m_payload_i[7]_i_1__1_n_0 ;
  wire \m_payload_i[8]_i_1__1_n_0 ;
  wire \m_payload_i[9]_i_1__1_n_0 ;
  wire [17:0]\m_payload_i_reg[17]_0 ;
  wire m_valid_i0;
  wire m_valid_i_reg_0;
  wire m_valid_i_reg_1;
  wire [15:0]out;
  wire p_1_in;
  wire s_axi_bready;
  wire s_ready_i_i_1__2_n_0;
  wire s_ready_i_reg_0;
  wire s_ready_i_reg_1;
  wire shandshake;
  wire si_rs_bvalid;
  wire [1:0]\skid_buffer_reg[1]_0 ;
  wire \skid_buffer_reg_n_0_[0] ;
  wire \skid_buffer_reg_n_0_[10] ;
  wire \skid_buffer_reg_n_0_[11] ;
  wire \skid_buffer_reg_n_0_[12] ;
  wire \skid_buffer_reg_n_0_[13] ;
  wire \skid_buffer_reg_n_0_[14] ;
  wire \skid_buffer_reg_n_0_[15] ;
  wire \skid_buffer_reg_n_0_[16] ;
  wire \skid_buffer_reg_n_0_[17] ;
  wire \skid_buffer_reg_n_0_[1] ;
  wire \skid_buffer_reg_n_0_[2] ;
  wire \skid_buffer_reg_n_0_[3] ;
  wire \skid_buffer_reg_n_0_[4] ;
  wire \skid_buffer_reg_n_0_[5] ;
  wire \skid_buffer_reg_n_0_[6] ;
  wire \skid_buffer_reg_n_0_[7] ;
  wire \skid_buffer_reg_n_0_[8] ;
  wire \skid_buffer_reg_n_0_[9] ;

  (* SOFT_HLUTNM = "soft_lutpair116" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[0]_i_1__1 
       (.I0(\skid_buffer_reg[1]_0 [0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[0] ),
        .O(\m_payload_i[0]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair111" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[10]_i_1__1 
       (.I0(out[8]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[10] ),
        .O(\m_payload_i[10]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair111" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[11]_i_1__1 
       (.I0(out[9]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[11] ),
        .O(\m_payload_i[11]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair110" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[12]_i_1__1 
       (.I0(out[10]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[12] ),
        .O(\m_payload_i[12]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair110" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[13]_i_1__1 
       (.I0(out[11]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[13] ),
        .O(\m_payload_i[13]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair109" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[14]_i_1__1 
       (.I0(out[12]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[14] ),
        .O(\m_payload_i[14]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair108" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[15]_i_1__1 
       (.I0(out[13]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[15] ),
        .O(\m_payload_i[15]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair109" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[16]_i_1__1 
       (.I0(out[14]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[16] ),
        .O(\m_payload_i[16]_i_1__1_n_0 ));
  LUT2 #(
    .INIT(4'hB)) 
    \m_payload_i[17]_i_1 
       (.I0(s_axi_bready),
        .I1(m_valid_i_reg_0),
        .O(p_1_in));
  (* SOFT_HLUTNM = "soft_lutpair108" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[17]_i_2 
       (.I0(out[15]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[17] ),
        .O(\m_payload_i[17]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair116" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[1]_i_1__1 
       (.I0(\skid_buffer_reg[1]_0 [1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[1] ),
        .O(\m_payload_i[1]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair115" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[2]_i_1__1 
       (.I0(out[0]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[2] ),
        .O(\m_payload_i[2]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair115" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[3]_i_1__1 
       (.I0(out[1]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[3] ),
        .O(\m_payload_i[3]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair114" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[4]_i_1__1 
       (.I0(out[2]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[4] ),
        .O(\m_payload_i[4]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair114" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[5]_i_1__1 
       (.I0(out[3]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[5] ),
        .O(\m_payload_i[5]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair113" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[6]_i_1__1 
       (.I0(out[4]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[6] ),
        .O(\m_payload_i[6]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair113" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[7]_i_1__1 
       (.I0(out[5]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[7] ),
        .O(\m_payload_i[7]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair112" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[8]_i_1__1 
       (.I0(out[6]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[8] ),
        .O(\m_payload_i[8]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair112" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[9]_i_1__1 
       (.I0(out[7]),
        .I1(s_ready_i_reg_0),
        .I2(\skid_buffer_reg_n_0_[9] ),
        .O(\m_payload_i[9]_i_1__1_n_0 ));
  FDRE \m_payload_i_reg[0] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[0]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [0]),
        .R(1'b0));
  FDRE \m_payload_i_reg[10] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[10]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [10]),
        .R(1'b0));
  FDRE \m_payload_i_reg[11] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[11]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [11]),
        .R(1'b0));
  FDRE \m_payload_i_reg[12] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[12]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [12]),
        .R(1'b0));
  FDRE \m_payload_i_reg[13] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[13]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [13]),
        .R(1'b0));
  FDRE \m_payload_i_reg[14] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[14]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [14]),
        .R(1'b0));
  FDRE \m_payload_i_reg[15] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[15]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [15]),
        .R(1'b0));
  FDRE \m_payload_i_reg[16] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[16]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [16]),
        .R(1'b0));
  FDRE \m_payload_i_reg[17] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[17]_i_2_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [17]),
        .R(1'b0));
  FDRE \m_payload_i_reg[1] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[1]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [1]),
        .R(1'b0));
  FDRE \m_payload_i_reg[2] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[2]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [2]),
        .R(1'b0));
  FDRE \m_payload_i_reg[3] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[3]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [3]),
        .R(1'b0));
  FDRE \m_payload_i_reg[4] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[4]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [4]),
        .R(1'b0));
  FDRE \m_payload_i_reg[5] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[5]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [5]),
        .R(1'b0));
  FDRE \m_payload_i_reg[6] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[6]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [6]),
        .R(1'b0));
  FDRE \m_payload_i_reg[7] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[7]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [7]),
        .R(1'b0));
  FDRE \m_payload_i_reg[8] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[8]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [8]),
        .R(1'b0));
  FDRE \m_payload_i_reg[9] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[9]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[17]_0 [9]),
        .R(1'b0));
  LUT4 #(
    .INIT(16'hDFDD)) 
    m_valid_i_i_2__0
       (.I0(s_ready_i_reg_0),
        .I1(si_rs_bvalid),
        .I2(s_axi_bready),
        .I3(m_valid_i_reg_0),
        .O(m_valid_i0));
  FDRE #(
    .INIT(1'b0)) 
    m_valid_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(m_valid_i0),
        .Q(m_valid_i_reg_0),
        .R(m_valid_i_reg_1));
  (* SOFT_HLUTNM = "soft_lutpair107" *) 
  LUT4 #(
    .INIT(16'hF2FF)) 
    s_ready_i_i_1__2
       (.I0(s_ready_i_reg_0),
        .I1(si_rs_bvalid),
        .I2(s_axi_bready),
        .I3(m_valid_i_reg_0),
        .O(s_ready_i_i_1__2_n_0));
  FDRE #(
    .INIT(1'b0)) 
    s_ready_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(s_ready_i_i_1__2_n_0),
        .Q(s_ready_i_reg_0),
        .R(s_ready_i_reg_1));
  (* SOFT_HLUTNM = "soft_lutpair107" *) 
  LUT2 #(
    .INIT(4'h8)) 
    shandshake_r_i_1
       (.I0(s_ready_i_reg_0),
        .I1(si_rs_bvalid),
        .O(shandshake));
  FDRE \skid_buffer_reg[0] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(\skid_buffer_reg[1]_0 [0]),
        .Q(\skid_buffer_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[10] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[8]),
        .Q(\skid_buffer_reg_n_0_[10] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[11] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[9]),
        .Q(\skid_buffer_reg_n_0_[11] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[12] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[10]),
        .Q(\skid_buffer_reg_n_0_[12] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[13] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[11]),
        .Q(\skid_buffer_reg_n_0_[13] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[14] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[12]),
        .Q(\skid_buffer_reg_n_0_[14] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[15] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[13]),
        .Q(\skid_buffer_reg_n_0_[15] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[16] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[14]),
        .Q(\skid_buffer_reg_n_0_[16] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[17] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[15]),
        .Q(\skid_buffer_reg_n_0_[17] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[1] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(\skid_buffer_reg[1]_0 [1]),
        .Q(\skid_buffer_reg_n_0_[1] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[2] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[0]),
        .Q(\skid_buffer_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[3] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[1]),
        .Q(\skid_buffer_reg_n_0_[3] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[4] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[2]),
        .Q(\skid_buffer_reg_n_0_[4] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[5] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[3]),
        .Q(\skid_buffer_reg_n_0_[5] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[6] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[4]),
        .Q(\skid_buffer_reg_n_0_[6] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[7] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[5]),
        .Q(\skid_buffer_reg_n_0_[7] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[8] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[6]),
        .Q(\skid_buffer_reg_n_0_[8] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[9] 
       (.C(aclk),
        .CE(s_ready_i_reg_0),
        .D(out[7]),
        .Q(\skid_buffer_reg_n_0_[9] ),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "axi_register_slice_v2_1_20_axic_register_slice" *) 
module zynqmpsoc_auto_pc_0_axi_register_slice_v2_1_20_axic_register_slice__parameterized2
   (m_valid_i_reg_0,
    s_ready_i_reg_0,
    \m_payload_i_reg[50]_0 ,
    m_valid_i_reg_1,
    aclk,
    s_ready_i_reg_1,
    s_axi_rready,
    m_valid_i_reg_2,
    \skid_buffer_reg[50]_0 ,
    \skid_buffer_reg[33]_0 );
  output m_valid_i_reg_0;
  output s_ready_i_reg_0;
  output [50:0]\m_payload_i_reg[50]_0 ;
  input m_valid_i_reg_1;
  input aclk;
  input s_ready_i_reg_1;
  input s_axi_rready;
  input m_valid_i_reg_2;
  input [16:0]\skid_buffer_reg[50]_0 ;
  input [33:0]\skid_buffer_reg[33]_0 ;

  wire aclk;
  wire \m_payload_i[0]_i_1__2_n_0 ;
  wire \m_payload_i[10]_i_1__2_n_0 ;
  wire \m_payload_i[11]_i_1__2_n_0 ;
  wire \m_payload_i[12]_i_1__2_n_0 ;
  wire \m_payload_i[13]_i_1__2_n_0 ;
  wire \m_payload_i[14]_i_1__2_n_0 ;
  wire \m_payload_i[15]_i_1__2_n_0 ;
  wire \m_payload_i[16]_i_1__2_n_0 ;
  wire \m_payload_i[17]_i_1__2_n_0 ;
  wire \m_payload_i[18]_i_1__1_n_0 ;
  wire \m_payload_i[19]_i_1__1_n_0 ;
  wire \m_payload_i[1]_i_1__2_n_0 ;
  wire \m_payload_i[20]_i_1__1_n_0 ;
  wire \m_payload_i[21]_i_1__1_n_0 ;
  wire \m_payload_i[22]_i_1__1_n_0 ;
  wire \m_payload_i[23]_i_1__1_n_0 ;
  wire \m_payload_i[24]_i_1__1_n_0 ;
  wire \m_payload_i[25]_i_1__1_n_0 ;
  wire \m_payload_i[26]_i_1__1_n_0 ;
  wire \m_payload_i[27]_i_1__1_n_0 ;
  wire \m_payload_i[28]_i_1__1_n_0 ;
  wire \m_payload_i[29]_i_1__1_n_0 ;
  wire \m_payload_i[2]_i_1__2_n_0 ;
  wire \m_payload_i[30]_i_1__1_n_0 ;
  wire \m_payload_i[31]_i_1__1_n_0 ;
  wire \m_payload_i[32]_i_1__1_n_0 ;
  wire \m_payload_i[33]_i_1__1_n_0 ;
  wire \m_payload_i[34]_i_1__1_n_0 ;
  wire \m_payload_i[35]_i_1__1_n_0 ;
  wire \m_payload_i[36]_i_1__1_n_0 ;
  wire \m_payload_i[37]_i_1__1_n_0 ;
  wire \m_payload_i[38]_i_1__1_n_0 ;
  wire \m_payload_i[39]_i_1__1_n_0 ;
  wire \m_payload_i[3]_i_1__2_n_0 ;
  wire \m_payload_i[40]_i_1__1_n_0 ;
  wire \m_payload_i[41]_i_1__1_n_0 ;
  wire \m_payload_i[42]_i_1__1_n_0 ;
  wire \m_payload_i[43]_i_1__1_n_0 ;
  wire \m_payload_i[44]_i_1__1_n_0 ;
  wire \m_payload_i[45]_i_1_n_0 ;
  wire \m_payload_i[46]_i_1__1_n_0 ;
  wire \m_payload_i[47]_i_1__1_n_0 ;
  wire \m_payload_i[48]_i_1_n_0 ;
  wire \m_payload_i[49]_i_1_n_0 ;
  wire \m_payload_i[4]_i_1__2_n_0 ;
  wire \m_payload_i[50]_i_2_n_0 ;
  wire \m_payload_i[5]_i_1__2_n_0 ;
  wire \m_payload_i[6]_i_1__2_n_0 ;
  wire \m_payload_i[7]_i_1__2_n_0 ;
  wire \m_payload_i[8]_i_1__2_n_0 ;
  wire \m_payload_i[9]_i_1__2_n_0 ;
  wire [50:0]\m_payload_i_reg[50]_0 ;
  wire m_valid_i0;
  wire m_valid_i_reg_0;
  wire m_valid_i_reg_1;
  wire m_valid_i_reg_2;
  wire p_1_in;
  wire s_axi_rready;
  wire s_ready_i_i_1__1_n_0;
  wire s_ready_i_reg_0;
  wire s_ready_i_reg_1;
  wire si_rs_rready;
  wire [33:0]\skid_buffer_reg[33]_0 ;
  wire [16:0]\skid_buffer_reg[50]_0 ;
  wire \skid_buffer_reg_n_0_[0] ;
  wire \skid_buffer_reg_n_0_[10] ;
  wire \skid_buffer_reg_n_0_[11] ;
  wire \skid_buffer_reg_n_0_[12] ;
  wire \skid_buffer_reg_n_0_[13] ;
  wire \skid_buffer_reg_n_0_[14] ;
  wire \skid_buffer_reg_n_0_[15] ;
  wire \skid_buffer_reg_n_0_[16] ;
  wire \skid_buffer_reg_n_0_[17] ;
  wire \skid_buffer_reg_n_0_[18] ;
  wire \skid_buffer_reg_n_0_[19] ;
  wire \skid_buffer_reg_n_0_[1] ;
  wire \skid_buffer_reg_n_0_[20] ;
  wire \skid_buffer_reg_n_0_[21] ;
  wire \skid_buffer_reg_n_0_[22] ;
  wire \skid_buffer_reg_n_0_[23] ;
  wire \skid_buffer_reg_n_0_[24] ;
  wire \skid_buffer_reg_n_0_[25] ;
  wire \skid_buffer_reg_n_0_[26] ;
  wire \skid_buffer_reg_n_0_[27] ;
  wire \skid_buffer_reg_n_0_[28] ;
  wire \skid_buffer_reg_n_0_[29] ;
  wire \skid_buffer_reg_n_0_[2] ;
  wire \skid_buffer_reg_n_0_[30] ;
  wire \skid_buffer_reg_n_0_[31] ;
  wire \skid_buffer_reg_n_0_[32] ;
  wire \skid_buffer_reg_n_0_[33] ;
  wire \skid_buffer_reg_n_0_[34] ;
  wire \skid_buffer_reg_n_0_[35] ;
  wire \skid_buffer_reg_n_0_[36] ;
  wire \skid_buffer_reg_n_0_[37] ;
  wire \skid_buffer_reg_n_0_[38] ;
  wire \skid_buffer_reg_n_0_[39] ;
  wire \skid_buffer_reg_n_0_[3] ;
  wire \skid_buffer_reg_n_0_[40] ;
  wire \skid_buffer_reg_n_0_[41] ;
  wire \skid_buffer_reg_n_0_[42] ;
  wire \skid_buffer_reg_n_0_[43] ;
  wire \skid_buffer_reg_n_0_[44] ;
  wire \skid_buffer_reg_n_0_[45] ;
  wire \skid_buffer_reg_n_0_[46] ;
  wire \skid_buffer_reg_n_0_[47] ;
  wire \skid_buffer_reg_n_0_[48] ;
  wire \skid_buffer_reg_n_0_[49] ;
  wire \skid_buffer_reg_n_0_[4] ;
  wire \skid_buffer_reg_n_0_[50] ;
  wire \skid_buffer_reg_n_0_[5] ;
  wire \skid_buffer_reg_n_0_[6] ;
  wire \skid_buffer_reg_n_0_[7] ;
  wire \skid_buffer_reg_n_0_[8] ;
  wire \skid_buffer_reg_n_0_[9] ;

  (* SOFT_HLUTNM = "soft_lutpair117" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \cnt_read[4]_i_3__0 
       (.I0(si_rs_rready),
        .I1(m_valid_i_reg_2),
        .O(s_ready_i_reg_0));
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[0]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [0]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[0] ),
        .O(\m_payload_i[0]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair138" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[10]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [10]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[10] ),
        .O(\m_payload_i[10]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair137" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[11]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [11]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[11] ),
        .O(\m_payload_i[11]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair131" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[12]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [12]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[12] ),
        .O(\m_payload_i[12]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair137" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[13]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [13]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[13] ),
        .O(\m_payload_i[13]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair136" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[14]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [14]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[14] ),
        .O(\m_payload_i[14]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair136" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[15]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [15]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[15] ),
        .O(\m_payload_i[15]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair135" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[16]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [16]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[16] ),
        .O(\m_payload_i[16]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair135" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[17]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [17]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[17] ),
        .O(\m_payload_i[17]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair134" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[18]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [18]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[18] ),
        .O(\m_payload_i[18]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair134" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[19]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [19]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[19] ),
        .O(\m_payload_i[19]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair142" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[1]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [1]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[1] ),
        .O(\m_payload_i[1]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair133" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[20]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [20]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[20] ),
        .O(\m_payload_i[20]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair133" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[21]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [21]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[21] ),
        .O(\m_payload_i[21]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair132" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[22]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [22]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[22] ),
        .O(\m_payload_i[22]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair132" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[23]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [23]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[23] ),
        .O(\m_payload_i[23]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair131" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[24]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [24]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[24] ),
        .O(\m_payload_i[24]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair130" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[25]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [25]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[25] ),
        .O(\m_payload_i[25]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair118" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[26]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [26]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[26] ),
        .O(\m_payload_i[26]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair130" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[27]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [27]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[27] ),
        .O(\m_payload_i[27]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair129" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[28]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [28]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[28] ),
        .O(\m_payload_i[28]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair129" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[29]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [29]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[29] ),
        .O(\m_payload_i[29]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair142" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[2]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [2]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[2] ),
        .O(\m_payload_i[2]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair128" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[30]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [30]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[30] ),
        .O(\m_payload_i[30]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair128" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[31]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [31]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[31] ),
        .O(\m_payload_i[31]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair127" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[32]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [32]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[32] ),
        .O(\m_payload_i[32]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair127" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[33]_i_1__1 
       (.I0(\skid_buffer_reg[33]_0 [33]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[33] ),
        .O(\m_payload_i[33]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair126" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[34]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [0]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[34] ),
        .O(\m_payload_i[34]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair126" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[35]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [1]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[35] ),
        .O(\m_payload_i[35]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair125" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[36]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [2]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[36] ),
        .O(\m_payload_i[36]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair125" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[37]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [3]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[37] ),
        .O(\m_payload_i[37]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair124" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[38]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [4]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[38] ),
        .O(\m_payload_i[38]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair124" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[39]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [5]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[39] ),
        .O(\m_payload_i[39]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair141" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[3]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [3]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[3] ),
        .O(\m_payload_i[3]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair123" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[40]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [6]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[40] ),
        .O(\m_payload_i[40]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair123" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[41]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [7]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[41] ),
        .O(\m_payload_i[41]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair122" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[42]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [8]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[42] ),
        .O(\m_payload_i[42]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair122" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[43]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [9]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[43] ),
        .O(\m_payload_i[43]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair121" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[44]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [10]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[44] ),
        .O(\m_payload_i[44]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair121" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[45]_i_1 
       (.I0(\skid_buffer_reg[50]_0 [11]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[45] ),
        .O(\m_payload_i[45]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair120" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[46]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [12]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[46] ),
        .O(\m_payload_i[46]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair120" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[47]_i_1__1 
       (.I0(\skid_buffer_reg[50]_0 [13]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[47] ),
        .O(\m_payload_i[47]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair119" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[48]_i_1 
       (.I0(\skid_buffer_reg[50]_0 [14]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[48] ),
        .O(\m_payload_i[48]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair119" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[49]_i_1 
       (.I0(\skid_buffer_reg[50]_0 [15]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[49] ),
        .O(\m_payload_i[49]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair141" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[4]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [4]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[4] ),
        .O(\m_payload_i[4]_i_1__2_n_0 ));
  LUT2 #(
    .INIT(4'hB)) 
    \m_payload_i[50]_i_1 
       (.I0(s_axi_rready),
        .I1(m_valid_i_reg_0),
        .O(p_1_in));
  (* SOFT_HLUTNM = "soft_lutpair118" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[50]_i_2 
       (.I0(\skid_buffer_reg[50]_0 [16]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[50] ),
        .O(\m_payload_i[50]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair138" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[5]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [5]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[5] ),
        .O(\m_payload_i[5]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair140" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[6]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [6]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[6] ),
        .O(\m_payload_i[6]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair140" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[7]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [7]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[7] ),
        .O(\m_payload_i[7]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair139" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[8]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [8]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[8] ),
        .O(\m_payload_i[8]_i_1__2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair139" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \m_payload_i[9]_i_1__2 
       (.I0(\skid_buffer_reg[33]_0 [9]),
        .I1(si_rs_rready),
        .I2(\skid_buffer_reg_n_0_[9] ),
        .O(\m_payload_i[9]_i_1__2_n_0 ));
  FDRE \m_payload_i_reg[0] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[0]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [0]),
        .R(1'b0));
  FDRE \m_payload_i_reg[10] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[10]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [10]),
        .R(1'b0));
  FDRE \m_payload_i_reg[11] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[11]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [11]),
        .R(1'b0));
  FDRE \m_payload_i_reg[12] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[12]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [12]),
        .R(1'b0));
  FDRE \m_payload_i_reg[13] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[13]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [13]),
        .R(1'b0));
  FDRE \m_payload_i_reg[14] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[14]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [14]),
        .R(1'b0));
  FDRE \m_payload_i_reg[15] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[15]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [15]),
        .R(1'b0));
  FDRE \m_payload_i_reg[16] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[16]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [16]),
        .R(1'b0));
  FDRE \m_payload_i_reg[17] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[17]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [17]),
        .R(1'b0));
  FDRE \m_payload_i_reg[18] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[18]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [18]),
        .R(1'b0));
  FDRE \m_payload_i_reg[19] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[19]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [19]),
        .R(1'b0));
  FDRE \m_payload_i_reg[1] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[1]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [1]),
        .R(1'b0));
  FDRE \m_payload_i_reg[20] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[20]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [20]),
        .R(1'b0));
  FDRE \m_payload_i_reg[21] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[21]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [21]),
        .R(1'b0));
  FDRE \m_payload_i_reg[22] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[22]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [22]),
        .R(1'b0));
  FDRE \m_payload_i_reg[23] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[23]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [23]),
        .R(1'b0));
  FDRE \m_payload_i_reg[24] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[24]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [24]),
        .R(1'b0));
  FDRE \m_payload_i_reg[25] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[25]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [25]),
        .R(1'b0));
  FDRE \m_payload_i_reg[26] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[26]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [26]),
        .R(1'b0));
  FDRE \m_payload_i_reg[27] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[27]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [27]),
        .R(1'b0));
  FDRE \m_payload_i_reg[28] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[28]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [28]),
        .R(1'b0));
  FDRE \m_payload_i_reg[29] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[29]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [29]),
        .R(1'b0));
  FDRE \m_payload_i_reg[2] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[2]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [2]),
        .R(1'b0));
  FDRE \m_payload_i_reg[30] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[30]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [30]),
        .R(1'b0));
  FDRE \m_payload_i_reg[31] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[31]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [31]),
        .R(1'b0));
  FDRE \m_payload_i_reg[32] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[32]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [32]),
        .R(1'b0));
  FDRE \m_payload_i_reg[33] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[33]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [33]),
        .R(1'b0));
  FDRE \m_payload_i_reg[34] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[34]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [34]),
        .R(1'b0));
  FDRE \m_payload_i_reg[35] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[35]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [35]),
        .R(1'b0));
  FDRE \m_payload_i_reg[36] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[36]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [36]),
        .R(1'b0));
  FDRE \m_payload_i_reg[37] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[37]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [37]),
        .R(1'b0));
  FDRE \m_payload_i_reg[38] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[38]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [38]),
        .R(1'b0));
  FDRE \m_payload_i_reg[39] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[39]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [39]),
        .R(1'b0));
  FDRE \m_payload_i_reg[3] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[3]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [3]),
        .R(1'b0));
  FDRE \m_payload_i_reg[40] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[40]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [40]),
        .R(1'b0));
  FDRE \m_payload_i_reg[41] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[41]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [41]),
        .R(1'b0));
  FDRE \m_payload_i_reg[42] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[42]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [42]),
        .R(1'b0));
  FDRE \m_payload_i_reg[43] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[43]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [43]),
        .R(1'b0));
  FDRE \m_payload_i_reg[44] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[44]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [44]),
        .R(1'b0));
  FDRE \m_payload_i_reg[45] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[45]_i_1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [45]),
        .R(1'b0));
  FDRE \m_payload_i_reg[46] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[46]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [46]),
        .R(1'b0));
  FDRE \m_payload_i_reg[47] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[47]_i_1__1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [47]),
        .R(1'b0));
  FDRE \m_payload_i_reg[48] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[48]_i_1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [48]),
        .R(1'b0));
  FDRE \m_payload_i_reg[49] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[49]_i_1_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [49]),
        .R(1'b0));
  FDRE \m_payload_i_reg[4] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[4]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [4]),
        .R(1'b0));
  FDRE \m_payload_i_reg[50] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[50]_i_2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [50]),
        .R(1'b0));
  FDRE \m_payload_i_reg[5] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[5]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [5]),
        .R(1'b0));
  FDRE \m_payload_i_reg[6] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[6]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [6]),
        .R(1'b0));
  FDRE \m_payload_i_reg[7] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[7]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [7]),
        .R(1'b0));
  FDRE \m_payload_i_reg[8] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[8]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [8]),
        .R(1'b0));
  FDRE \m_payload_i_reg[9] 
       (.C(aclk),
        .CE(p_1_in),
        .D(\m_payload_i[9]_i_1__2_n_0 ),
        .Q(\m_payload_i_reg[50]_0 [9]),
        .R(1'b0));
  LUT4 #(
    .INIT(16'hDDFD)) 
    m_valid_i_i_1
       (.I0(si_rs_rready),
        .I1(m_valid_i_reg_2),
        .I2(m_valid_i_reg_0),
        .I3(s_axi_rready),
        .O(m_valid_i0));
  FDRE #(
    .INIT(1'b0)) 
    m_valid_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(m_valid_i0),
        .Q(m_valid_i_reg_0),
        .R(m_valid_i_reg_1));
  (* SOFT_HLUTNM = "soft_lutpair117" *) 
  LUT4 #(
    .INIT(16'hDDFD)) 
    s_ready_i_i_1__1
       (.I0(m_valid_i_reg_0),
        .I1(s_axi_rready),
        .I2(si_rs_rready),
        .I3(m_valid_i_reg_2),
        .O(s_ready_i_i_1__1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    s_ready_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(s_ready_i_i_1__1_n_0),
        .Q(si_rs_rready),
        .R(s_ready_i_reg_1));
  FDRE \skid_buffer_reg[0] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [0]),
        .Q(\skid_buffer_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[10] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [10]),
        .Q(\skid_buffer_reg_n_0_[10] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[11] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [11]),
        .Q(\skid_buffer_reg_n_0_[11] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[12] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [12]),
        .Q(\skid_buffer_reg_n_0_[12] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[13] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [13]),
        .Q(\skid_buffer_reg_n_0_[13] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[14] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [14]),
        .Q(\skid_buffer_reg_n_0_[14] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[15] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [15]),
        .Q(\skid_buffer_reg_n_0_[15] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[16] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [16]),
        .Q(\skid_buffer_reg_n_0_[16] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[17] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [17]),
        .Q(\skid_buffer_reg_n_0_[17] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[18] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [18]),
        .Q(\skid_buffer_reg_n_0_[18] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[19] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [19]),
        .Q(\skid_buffer_reg_n_0_[19] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[1] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [1]),
        .Q(\skid_buffer_reg_n_0_[1] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[20] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [20]),
        .Q(\skid_buffer_reg_n_0_[20] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[21] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [21]),
        .Q(\skid_buffer_reg_n_0_[21] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[22] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [22]),
        .Q(\skid_buffer_reg_n_0_[22] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[23] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [23]),
        .Q(\skid_buffer_reg_n_0_[23] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[24] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [24]),
        .Q(\skid_buffer_reg_n_0_[24] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[25] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [25]),
        .Q(\skid_buffer_reg_n_0_[25] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[26] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [26]),
        .Q(\skid_buffer_reg_n_0_[26] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[27] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [27]),
        .Q(\skid_buffer_reg_n_0_[27] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[28] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [28]),
        .Q(\skid_buffer_reg_n_0_[28] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[29] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [29]),
        .Q(\skid_buffer_reg_n_0_[29] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[2] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [2]),
        .Q(\skid_buffer_reg_n_0_[2] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[30] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [30]),
        .Q(\skid_buffer_reg_n_0_[30] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[31] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [31]),
        .Q(\skid_buffer_reg_n_0_[31] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[32] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [32]),
        .Q(\skid_buffer_reg_n_0_[32] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[33] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [33]),
        .Q(\skid_buffer_reg_n_0_[33] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[34] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [0]),
        .Q(\skid_buffer_reg_n_0_[34] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[35] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [1]),
        .Q(\skid_buffer_reg_n_0_[35] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[36] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [2]),
        .Q(\skid_buffer_reg_n_0_[36] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[37] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [3]),
        .Q(\skid_buffer_reg_n_0_[37] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[38] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [4]),
        .Q(\skid_buffer_reg_n_0_[38] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[39] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [5]),
        .Q(\skid_buffer_reg_n_0_[39] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[3] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [3]),
        .Q(\skid_buffer_reg_n_0_[3] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[40] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [6]),
        .Q(\skid_buffer_reg_n_0_[40] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[41] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [7]),
        .Q(\skid_buffer_reg_n_0_[41] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[42] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [8]),
        .Q(\skid_buffer_reg_n_0_[42] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[43] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [9]),
        .Q(\skid_buffer_reg_n_0_[43] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[44] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [10]),
        .Q(\skid_buffer_reg_n_0_[44] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[45] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [11]),
        .Q(\skid_buffer_reg_n_0_[45] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[46] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [12]),
        .Q(\skid_buffer_reg_n_0_[46] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[47] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [13]),
        .Q(\skid_buffer_reg_n_0_[47] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[48] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [14]),
        .Q(\skid_buffer_reg_n_0_[48] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[49] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [15]),
        .Q(\skid_buffer_reg_n_0_[49] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[4] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [4]),
        .Q(\skid_buffer_reg_n_0_[4] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[50] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[50]_0 [16]),
        .Q(\skid_buffer_reg_n_0_[50] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[5] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [5]),
        .Q(\skid_buffer_reg_n_0_[5] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[6] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [6]),
        .Q(\skid_buffer_reg_n_0_[6] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[7] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [7]),
        .Q(\skid_buffer_reg_n_0_[7] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[8] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [8]),
        .Q(\skid_buffer_reg_n_0_[8] ),
        .R(1'b0));
  FDRE \skid_buffer_reg[9] 
       (.C(aclk),
        .CE(si_rs_rready),
        .D(\skid_buffer_reg[33]_0 [9]),
        .Q(\skid_buffer_reg_n_0_[9] ),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
