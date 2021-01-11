`timescale 1ns/1ps

//PORTS

      bit  maxihpm0_fpd_aclk;
      bit  [15 : 0] maxigp0_awid;
      bit  [39 : 0] maxigp0_awaddr;
      bit  [7 : 0] maxigp0_awlen;
      bit  [2 : 0] maxigp0_awsize;
      bit  [1 : 0] maxigp0_awburst;
      bit  maxigp0_awlock;
      bit  [3 : 0] maxigp0_awcache;
      bit  [2 : 0] maxigp0_awprot;
      bit  maxigp0_awvalid;
      bit  [15 : 0] maxigp0_awuser;
      bit  maxigp0_awready;
      bit  [31 : 0] maxigp0_wdata;
      bit  [3 : 0] maxigp0_wstrb;
      bit  maxigp0_wlast;
      bit  maxigp0_wvalid;
      bit  maxigp0_wready;
      bit  [15 : 0] maxigp0_bid;
      bit  [1 : 0] maxigp0_bresp;
      bit  maxigp0_bvalid;
      bit  maxigp0_bready;
      bit  [15 : 0] maxigp0_arid;
      bit  [39 : 0] maxigp0_araddr;
      bit  [7 : 0] maxigp0_arlen;
      bit  [2 : 0] maxigp0_arsize;
      bit  [1 : 0] maxigp0_arburst;
      bit  maxigp0_arlock;
      bit  [3 : 0] maxigp0_arcache;
      bit  [2 : 0] maxigp0_arprot;
      bit  maxigp0_arvalid;
      bit  [15 : 0] maxigp0_aruser;
      bit  maxigp0_arready;
      bit  [15 : 0] maxigp0_rid;
      bit  [31 : 0] maxigp0_rdata;
      bit  [1 : 0] maxigp0_rresp;
      bit  maxigp0_rlast;
      bit  maxigp0_rvalid;
      bit  maxigp0_rready;
      bit  [3 : 0] maxigp0_awqos;
      bit  [3 : 0] maxigp0_arqos;
      bit  maxihpm1_fpd_aclk;
      bit  [15 : 0] maxigp1_awid;
      bit  [39 : 0] maxigp1_awaddr;
      bit  [7 : 0] maxigp1_awlen;
      bit  [2 : 0] maxigp1_awsize;
      bit  [1 : 0] maxigp1_awburst;
      bit  maxigp1_awlock;
      bit  [3 : 0] maxigp1_awcache;
      bit  [2 : 0] maxigp1_awprot;
      bit  maxigp1_awvalid;
      bit  [15 : 0] maxigp1_awuser;
      bit  maxigp1_awready;
      bit  [31 : 0] maxigp1_wdata;
      bit  [3 : 0] maxigp1_wstrb;
      bit  maxigp1_wlast;
      bit  maxigp1_wvalid;
      bit  maxigp1_wready;
      bit  [15 : 0] maxigp1_bid;
      bit  [1 : 0] maxigp1_bresp;
      bit  maxigp1_bvalid;
      bit  maxigp1_bready;
      bit  [15 : 0] maxigp1_arid;
      bit  [39 : 0] maxigp1_araddr;
      bit  [7 : 0] maxigp1_arlen;
      bit  [2 : 0] maxigp1_arsize;
      bit  [1 : 0] maxigp1_arburst;
      bit  maxigp1_arlock;
      bit  [3 : 0] maxigp1_arcache;
      bit  [2 : 0] maxigp1_arprot;
      bit  maxigp1_arvalid;
      bit  [15 : 0] maxigp1_aruser;
      bit  maxigp1_arready;
      bit  [15 : 0] maxigp1_rid;
      bit  [31 : 0] maxigp1_rdata;
      bit  [1 : 0] maxigp1_rresp;
      bit  maxigp1_rlast;
      bit  maxigp1_rvalid;
      bit  maxigp1_rready;
      bit  [3 : 0] maxigp1_awqos;
      bit  [3 : 0] maxigp1_arqos;
      bit  maxihpm0_lpd_aclk;
      bit  [15 : 0] maxigp2_awid;
      bit  [39 : 0] maxigp2_awaddr;
      bit  [7 : 0] maxigp2_awlen;
      bit  [2 : 0] maxigp2_awsize;
      bit  [1 : 0] maxigp2_awburst;
      bit  maxigp2_awlock;
      bit  [3 : 0] maxigp2_awcache;
      bit  [2 : 0] maxigp2_awprot;
      bit  maxigp2_awvalid;
      bit  [15 : 0] maxigp2_awuser;
      bit  maxigp2_awready;
      bit  [31 : 0] maxigp2_wdata;
      bit  [3 : 0] maxigp2_wstrb;
      bit  maxigp2_wlast;
      bit  maxigp2_wvalid;
      bit  maxigp2_wready;
      bit  [15 : 0] maxigp2_bid;
      bit  [1 : 0] maxigp2_bresp;
      bit  maxigp2_bvalid;
      bit  maxigp2_bready;
      bit  [15 : 0] maxigp2_arid;
      bit  [39 : 0] maxigp2_araddr;
      bit  [7 : 0] maxigp2_arlen;
      bit  [2 : 0] maxigp2_arsize;
      bit  [1 : 0] maxigp2_arburst;
      bit  maxigp2_arlock;
      bit  [3 : 0] maxigp2_arcache;
      bit  [2 : 0] maxigp2_arprot;
      bit  maxigp2_arvalid;
      bit  [15 : 0] maxigp2_aruser;
      bit  maxigp2_arready;
      bit  [15 : 0] maxigp2_rid;
      bit  [31 : 0] maxigp2_rdata;
      bit  [1 : 0] maxigp2_rresp;
      bit  maxigp2_rlast;
      bit  maxigp2_rvalid;
      bit  maxigp2_rready;
      bit  [3 : 0] maxigp2_awqos;
      bit  [3 : 0] maxigp2_arqos;
      bit  saxihpc0_fpd_rclk;
      bit  saxihpc0_fpd_wclk;
      bit  saxihpc0_fpd_aclk;
      bit  saxigp0_aruser;
      bit  saxigp0_awuser;
      bit  [5 : 0] saxigp0_awid;
      bit  [48 : 0] saxigp0_awaddr;
      bit  [7 : 0] saxigp0_awlen;
      bit  [2 : 0] saxigp0_awsize;
      bit  [1 : 0] saxigp0_awburst;
      bit  saxigp0_awlock;
      bit  [3 : 0] saxigp0_awcache;
      bit  [2 : 0] saxigp0_awprot;
      bit  saxigp0_awvalid;
      bit  saxigp0_awready;
      bit  [63 : 0] saxigp0_wdata;
      bit  [7 : 0] saxigp0_wstrb;
      bit  saxigp0_wlast;
      bit  saxigp0_wvalid;
      bit  saxigp0_wready;
      bit  [5 : 0] saxigp0_bid;
      bit  [1 : 0] saxigp0_bresp;
      bit  ddrc_ext_refresh_rank0_req;
      bit  ddrc_ext_refresh_rank1_req;
      bit  ddrc_refresh_pl_clk;
      bit  saxigp0_bvalid;
      bit  saxigp0_bready;
      bit  [5 : 0] saxigp0_arid;
      bit  [48 : 0] saxigp0_araddr;
      bit  [7 : 0] saxigp0_arlen;
      bit  [2 : 0] saxigp0_arsize;
      bit  [1 : 0] saxigp0_arburst;
      bit  saxigp0_arlock;
      bit  [3 : 0] saxigp0_arcache;
      bit  [2 : 0] saxigp0_arprot;
      bit  saxigp0_arvalid;
      bit  saxigp0_arready;
      bit  [5 : 0] saxigp0_rid;
      bit  [63 : 0] saxigp0_rdata;
      bit  [1 : 0] saxigp0_rresp;
      bit  saxigp0_rlast;
      bit  saxigp0_rvalid;
      bit  saxigp0_rready;
      bit  [3 : 0] saxigp0_awqos;
      bit  [3 : 0] saxigp0_arqos;
      bit  [7 : 0] saxigp0_rcount;
      bit  [7 : 0] saxigp0_wcount;
      bit  [3 : 0] saxigp0_racount;
      bit  [3 : 0] saxigp0_wacount;
      bit  saxihpc1_fpd_rclk;
      bit  saxihpc1_fpd_wclk;
      bit  saxihpc1_fpd_aclk;
      bit  saxigp1_aruser;
      bit  saxigp1_awuser;
      bit  [5 : 0] saxigp1_awid;
      bit  [48 : 0] saxigp1_awaddr;
      bit  [7 : 0] saxigp1_awlen;
      bit  [2 : 0] saxigp1_awsize;
      bit  [1 : 0] saxigp1_awburst;
      bit  saxigp1_awlock;
      bit  [3 : 0] saxigp1_awcache;
      bit  [2 : 0] saxigp1_awprot;
      bit  saxigp1_awvalid;
      bit  saxigp1_awready;
      bit  [127 : 0] saxigp1_wdata;
      bit  [15 : 0] saxigp1_wstrb;
      bit  saxigp1_wlast;
      bit  saxigp1_wvalid;
      bit  saxigp1_wready;
      bit  [5 : 0] saxigp1_bid;
      bit  [1 : 0] saxigp1_bresp;
      bit  saxigp1_bvalid;
      bit  saxigp1_bready;
      bit  [5 : 0] saxigp1_arid;
      bit  [48 : 0] saxigp1_araddr;
      bit  [7 : 0] saxigp1_arlen;
      bit  [2 : 0] saxigp1_arsize;
      bit  [1 : 0] saxigp1_arburst;
      bit  saxigp1_arlock;
      bit  [3 : 0] saxigp1_arcache;
      bit  [2 : 0] saxigp1_arprot;
      bit  saxigp1_arvalid;
      bit  saxigp1_arready;
      bit  [5 : 0] saxigp1_rid;
      bit  [127 : 0] saxigp1_rdata;
      bit  [1 : 0] saxigp1_rresp;
      bit  saxigp1_rlast;
      bit  saxigp1_rvalid;
      bit  saxigp1_rready;
      bit  [3 : 0] saxigp1_awqos;
      bit  [3 : 0] saxigp1_arqos;
      bit  [7 : 0] saxigp1_rcount;
      bit  [7 : 0] saxigp1_wcount;
      bit  [3 : 0] saxigp1_racount;
      bit  [3 : 0] saxigp1_wacount;
      bit  saxihp0_fpd_rclk;
      bit  saxihp0_fpd_wclk;
      bit  saxihp0_fpd_aclk;
      bit  saxigp2_aruser;
      bit  saxigp2_awuser;
      bit  [5 : 0] saxigp2_awid;
      bit  [48 : 0] saxigp2_awaddr;
      bit  [7 : 0] saxigp2_awlen;
      bit  [2 : 0] saxigp2_awsize;
      bit  [1 : 0] saxigp2_awburst;
      bit  saxigp2_awlock;
      bit  [3 : 0] saxigp2_awcache;
      bit  [2 : 0] saxigp2_awprot;
      bit  saxigp2_awvalid;
      bit  saxigp2_awready;
      bit  [127 : 0] saxigp2_wdata;
      bit  [15 : 0] saxigp2_wstrb;
      bit  saxigp2_wlast;
      bit  saxigp2_wvalid;
      bit  saxigp2_wready;
      bit  [5 : 0] saxigp2_bid;
      bit  [1 : 0] saxigp2_bresp;
      bit  saxigp2_bvalid;
      bit  saxigp2_bready;
      bit  [5 : 0] saxigp2_arid;
      bit  [48 : 0] saxigp2_araddr;
      bit  [7 : 0] saxigp2_arlen;
      bit  [2 : 0] saxigp2_arsize;
      bit  [1 : 0] saxigp2_arburst;
      bit  saxigp2_arlock;
      bit  [3 : 0] saxigp2_arcache;
      bit  [2 : 0] saxigp2_arprot;
      bit  saxigp2_arvalid;
      bit  saxigp2_arready;
      bit  [5 : 0] saxigp2_rid;
      bit  [127 : 0] saxigp2_rdata;
      bit  [1 : 0] saxigp2_rresp;
      bit  saxigp2_rlast;
      bit  saxigp2_rvalid;
      bit  saxigp2_rready;
      bit  [3 : 0] saxigp2_awqos;
      bit  [3 : 0] saxigp2_arqos;
      bit  [7 : 0] saxigp2_rcount;
      bit  [7 : 0] saxigp2_wcount;
      bit  [3 : 0] saxigp2_racount;
      bit  [3 : 0] saxigp2_wacount;
      bit  saxihp1_fpd_rclk;
      bit  saxihp1_fpd_wclk;
      bit  saxihp1_fpd_aclk;
      bit  saxigp3_aruser;
      bit  saxigp3_awuser;
      bit  [5 : 0] saxigp3_awid;
      bit  [48 : 0] saxigp3_awaddr;
      bit  [7 : 0] saxigp3_awlen;
      bit  [2 : 0] saxigp3_awsize;
      bit  [1 : 0] saxigp3_awburst;
      bit  saxigp3_awlock;
      bit  [3 : 0] saxigp3_awcache;
      bit  [2 : 0] saxigp3_awprot;
      bit  saxigp3_awvalid;
      bit  saxigp3_awready;
      bit  [127 : 0] saxigp3_wdata;
      bit  [15 : 0] saxigp3_wstrb;
      bit  saxigp3_wlast;
      bit  saxigp3_wvalid;
      bit  saxigp3_wready;
      bit  [5 : 0] saxigp3_bid;
      bit  [1 : 0] saxigp3_bresp;
      bit  saxigp3_bvalid;
      bit  saxigp3_bready;
      bit  [5 : 0] saxigp3_arid;
      bit  [48 : 0] saxigp3_araddr;
      bit  [7 : 0] saxigp3_arlen;
      bit  [2 : 0] saxigp3_arsize;
      bit  [1 : 0] saxigp3_arburst;
      bit  saxigp3_arlock;
      bit  [3 : 0] saxigp3_arcache;
      bit  [2 : 0] saxigp3_arprot;
      bit  saxigp3_arvalid;
      bit  saxigp3_arready;
      bit  [5 : 0] saxigp3_rid;
      bit  [127 : 0] saxigp3_rdata;
      bit  [1 : 0] saxigp3_rresp;
      bit  saxigp3_rlast;
      bit  saxigp3_rvalid;
      bit  saxigp3_rready;
      bit  [3 : 0] saxigp3_awqos;
      bit  [3 : 0] saxigp3_arqos;
      bit  [7 : 0] saxigp3_rcount;
      bit  [7 : 0] saxigp3_wcount;
      bit  [3 : 0] saxigp3_racount;
      bit  [3 : 0] saxigp3_wacount;
      bit  saxihp2_fpd_rclk;
      bit  saxihp2_fpd_wclk;
      bit  saxihp2_fpd_aclk;
      bit  saxigp4_aruser;
      bit  saxigp4_awuser;
      bit  [5 : 0] saxigp4_awid;
      bit  [48 : 0] saxigp4_awaddr;
      bit  [7 : 0] saxigp4_awlen;
      bit  [2 : 0] saxigp4_awsize;
      bit  [1 : 0] saxigp4_awburst;
      bit  saxigp4_awlock;
      bit  [3 : 0] saxigp4_awcache;
      bit  [2 : 0] saxigp4_awprot;
      bit  saxigp4_awvalid;
      bit  saxigp4_awready;
      bit  [127 : 0] saxigp4_wdata;
      bit  [15 : 0] saxigp4_wstrb;
      bit  saxigp4_wlast;
      bit  saxigp4_wvalid;
      bit  saxigp4_wready;
      bit  [5 : 0] saxigp4_bid;
      bit  [1 : 0] saxigp4_bresp;
      bit  saxigp4_bvalid;
      bit  saxigp4_bready;
      bit  [5 : 0] saxigp4_arid;
      bit  [48 : 0] saxigp4_araddr;
      bit  [7 : 0] saxigp4_arlen;
      bit  [2 : 0] saxigp4_arsize;
      bit  [1 : 0] saxigp4_arburst;
      bit  saxigp4_arlock;
      bit  [3 : 0] saxigp4_arcache;
      bit  [2 : 0] saxigp4_arprot;
      bit  saxigp4_arvalid;
      bit  saxigp4_arready;
      bit  [5 : 0] saxigp4_rid;
      bit  [127 : 0] saxigp4_rdata;
      bit  [1 : 0] saxigp4_rresp;
      bit  saxigp4_rlast;
      bit  saxigp4_rvalid;
      bit  saxigp4_rready;
      bit  [3 : 0] saxigp4_awqos;
      bit  [3 : 0] saxigp4_arqos;
      bit  [7 : 0] saxigp4_rcount;
      bit  [7 : 0] saxigp4_wcount;
      bit  [3 : 0] saxigp4_racount;
      bit  [3 : 0] saxigp4_wacount;
      bit  saxihp3_fpd_rclk;
      bit  saxihp3_fpd_wclk;
      bit  saxihp3_fpd_aclk;
      bit  saxigp5_aruser;
      bit  saxigp5_awuser;
      bit  [5 : 0] saxigp5_awid;
      bit  [48 : 0] saxigp5_awaddr;
      bit  [7 : 0] saxigp5_awlen;
      bit  [2 : 0] saxigp5_awsize;
      bit  [1 : 0] saxigp5_awburst;
      bit  saxigp5_awlock;
      bit  [3 : 0] saxigp5_awcache;
      bit  [2 : 0] saxigp5_awprot;
      bit  saxigp5_awvalid;
      bit  saxigp5_awready;
      bit  [127 : 0] saxigp5_wdata;
      bit  [15 : 0] saxigp5_wstrb;
      bit  saxigp5_wlast;
      bit  saxigp5_wvalid;
      bit  saxigp5_wready;
      bit  [5 : 0] saxigp5_bid;
      bit  [1 : 0] saxigp5_bresp;
      bit  saxigp5_bvalid;
      bit  saxigp5_bready;
      bit  [5 : 0] saxigp5_arid;
      bit  [48 : 0] saxigp5_araddr;
      bit  [7 : 0] saxigp5_arlen;
      bit  [2 : 0] saxigp5_arsize;
      bit  [1 : 0] saxigp5_arburst;
      bit  saxigp5_arlock;
      bit  [3 : 0] saxigp5_arcache;
      bit  [2 : 0] saxigp5_arprot;
      bit  saxigp5_arvalid;
      bit  saxigp5_arready;
      bit  [5 : 0] saxigp5_rid;
      bit  [127 : 0] saxigp5_rdata;
      bit  [1 : 0] saxigp5_rresp;
      bit  saxigp5_rlast;
      bit  saxigp5_rvalid;
      bit  saxigp5_rready;
      bit  [3 : 0] saxigp5_awqos;
      bit  [3 : 0] saxigp5_arqos;
      bit  [7 : 0] saxigp5_rcount;
      bit  [7 : 0] saxigp5_wcount;
      bit  [3 : 0] saxigp5_racount;
      bit  [3 : 0] saxigp5_wacount;
      bit  saxi_lpd_rclk;
      bit  saxi_lpd_wclk;
      bit  saxi_lpd_aclk;
      bit  saxigp6_aruser;
      bit  saxigp6_awuser;
      bit  [5 : 0] saxigp6_awid;
      bit  [48 : 0] saxigp6_awaddr;
      bit  [7 : 0] saxigp6_awlen;
      bit  [2 : 0] saxigp6_awsize;
      bit  [1 : 0] saxigp6_awburst;
      bit  saxigp6_awlock;
      bit  [3 : 0] saxigp6_awcache;
      bit  [2 : 0] saxigp6_awprot;
      bit  saxigp6_awvalid;
      bit  saxigp6_awready;
      bit  [127 : 0] saxigp6_wdata;
      bit  [15 : 0] saxigp6_wstrb;
      bit  saxigp6_wlast;
      bit  saxigp6_wvalid;
      bit  saxigp6_wready;
      bit  [5 : 0] saxigp6_bid;
      bit  [1 : 0] saxigp6_bresp;
      bit  saxigp6_bvalid;
      bit  saxigp6_bready;
      bit  [5 : 0] saxigp6_arid;
      bit  [48 : 0] saxigp6_araddr;
      bit  [7 : 0] saxigp6_arlen;
      bit  [2 : 0] saxigp6_arsize;
      bit  [1 : 0] saxigp6_arburst;
      bit  saxigp6_arlock;
      bit  [3 : 0] saxigp6_arcache;
      bit  [2 : 0] saxigp6_arprot;
      bit  saxigp6_arvalid;
      bit  saxigp6_arready;
      bit  [5 : 0] saxigp6_rid;
      bit  [127 : 0] saxigp6_rdata;
      bit  [1 : 0] saxigp6_rresp;
      bit  saxigp6_rlast;
      bit  saxigp6_rvalid;
      bit  saxigp6_rready;
      bit  [3 : 0] saxigp6_awqos;
      bit  [3 : 0] saxigp6_arqos;
      bit  [7 : 0] saxigp6_rcount;
      bit  [7 : 0] saxigp6_wcount;
      bit  [3 : 0] saxigp6_racount;
      bit  [3 : 0] saxigp6_wacount;
      bit  saxiacp_fpd_aclk;
      bit  [1 : 0] saxiacp_awuser;
      bit  [1 : 0] saxiacp_aruser;
      bit  [4 : 0] saxiacp_awid;
      bit  [39 : 0] saxiacp_awaddr;
      bit  [7 : 0] saxiacp_awlen;
      bit  [2 : 0] saxiacp_awsize;
      bit  [1 : 0] saxiacp_awburst;
      bit  saxiacp_awlock;
      bit  [3 : 0] saxiacp_awcache;
      bit  [2 : 0] saxiacp_awprot;
      bit  saxiacp_awvalid;
      bit  saxiacp_awready;
      bit  [127 : 0] saxiacp_wdata;
      bit  [15 : 0] saxiacp_wstrb;
      bit  saxiacp_wlast;
      bit  saxiacp_wvalid;
      bit  saxiacp_wready;
      bit  [4 : 0] saxiacp_bid;
      bit  [1 : 0] saxiacp_bresp;
      bit  saxiacp_bvalid;
      bit  saxiacp_bready;
      bit  [4 : 0] saxiacp_arid;
      bit  [39 : 0] saxiacp_araddr;
      bit  [7 : 0] saxiacp_arlen;
      bit  [2 : 0] saxiacp_arsize;
      bit  [1 : 0] saxiacp_arburst;
      bit  saxiacp_arlock;
      bit  [3 : 0] saxiacp_arcache;
      bit  [2 : 0] saxiacp_arprot;
      bit  saxiacp_arvalid;
      bit  saxiacp_arready;
      bit  [4 : 0] saxiacp_rid;
      bit  [127 : 0] saxiacp_rdata;
      bit  [1 : 0] saxiacp_rresp;
      bit  saxiacp_rlast;
      bit  saxiacp_rvalid;
      bit  saxiacp_rready;
      bit  [3 : 0] saxiacp_awqos;
      bit  [3 : 0] saxiacp_arqos;
      bit  sacefpd_aclk;
      bit  sacefpd_wuser;
      bit  sacefpd_buser;
      bit  sacefpd_ruser;
      bit  [15 : 0] sacefpd_awuser;
      bit  [2 : 0] sacefpd_awsnoop;
      bit  [2 : 0] sacefpd_awsize;
      bit  [3 : 0] sacefpd_awregion;
      bit  [3 : 0] sacefpd_awqos;
      bit  [2 : 0] sacefpd_awprot;
      bit  [7 : 0] sacefpd_awlen;
      bit  [5 : 0] sacefpd_awid;
      bit  [1 : 0] sacefpd_awdomain;
      bit  [3 : 0] sacefpd_awcache;
      bit  [1 : 0] sacefpd_awburst;
      bit  [1 : 0] sacefpd_awbar;
      bit  [43 : 0] sacefpd_awaddr;
      bit  sacefpd_awlock;
      bit  sacefpd_awvalid;
      bit  sacefpd_awready;
      bit  [15 : 0] sacefpd_wstrb;
      bit  [127 : 0] sacefpd_wdata;
      bit  sacefpd_wlast;
      bit  sacefpd_wvalid;
      bit  sacefpd_wready;
      bit  [1 : 0] sacefpd_bresp;
      bit  [5 : 0] sacefpd_bid;
      bit  sacefpd_bvalid;
      bit  sacefpd_bready;
      bit  [15 : 0] sacefpd_aruser;
      bit  [3 : 0] sacefpd_arsnoop;
      bit  [2 : 0] sacefpd_arsize;
      bit  [3 : 0] sacefpd_arregion;
      bit  [3 : 0] sacefpd_arqos;
      bit  [2 : 0] sacefpd_arprot;
      bit  [7 : 0] sacefpd_arlen;
      bit  [5 : 0] sacefpd_arid;
      bit  [1 : 0] sacefpd_ardomain;
      bit  [3 : 0] sacefpd_arcache;
      bit  [1 : 0] sacefpd_arburst;
      bit  [1 : 0] sacefpd_arbar;
      bit  [43 : 0] sacefpd_araddr;
      bit  sacefpd_arlock;
      bit  sacefpd_arvalid;
      bit  sacefpd_arready;
      bit  [3 : 0] sacefpd_rresp;
      bit  [5 : 0] sacefpd_rid;
      bit  [127 : 0] sacefpd_rdata;
      bit  sacefpd_rlast;
      bit  sacefpd_rvalid;
      bit  sacefpd_rready;
      bit  [3 : 0] sacefpd_acsnoop;
      bit  [2 : 0] sacefpd_acprot;
      bit  [43 : 0] sacefpd_acaddr;
      bit  sacefpd_acvalid;
      bit  sacefpd_acready;
      bit  [127 : 0] sacefpd_cddata;
      bit  sacefpd_cdlast;
      bit  sacefpd_cdvalid;
      bit  sacefpd_cdready;
      bit  [4 : 0] sacefpd_crresp;
      bit  sacefpd_crvalid;
      bit  sacefpd_crready;
      bit  sacefpd_wack;
      bit  sacefpd_rack;
      bit  emio_can0_phy_tx;
      bit  emio_can0_phy_rx;
      bit  emio_can1_phy_tx;
      bit  emio_can1_phy_rx;
      bit  emio_enet0_gmii_rx_clk;
      bit  [2 : 0] emio_enet0_speed_mode;
      bit  emio_enet0_gmii_crs;
      bit  emio_enet0_gmii_col;
      bit  [7 : 0] emio_enet0_gmii_rxd;
      bit  emio_enet0_gmii_rx_er;
      bit  emio_enet0_gmii_rx_dv;
      bit  emio_enet0_gmii_tx_clk;
      bit  [7 : 0] emio_enet0_gmii_txd;
      bit  emio_enet0_gmii_tx_en;
      bit  emio_enet0_gmii_tx_er;
      bit  emio_enet0_mdio_mdc;
      bit  emio_enet0_mdio_i;
      bit  emio_enet0_mdio_o;
      bit  emio_enet0_mdio_t;
      bit  emio_enet1_gmii_rx_clk;
      bit  [2 : 0] emio_enet1_speed_mode;
      bit  emio_enet1_gmii_crs;
      bit  emio_enet1_gmii_col;
      bit  [7 : 0] emio_enet1_gmii_rxd;
      bit  emio_enet1_gmii_rx_er;
      bit  emio_enet1_gmii_rx_dv;
      bit  emio_enet1_gmii_tx_clk;
      bit  [7 : 0] emio_enet1_gmii_txd;
      bit  emio_enet1_gmii_tx_en;
      bit  emio_enet1_gmii_tx_er;
      bit  emio_enet1_mdio_mdc;
      bit  emio_enet1_mdio_i;
      bit  emio_enet1_mdio_o;
      bit  emio_enet1_mdio_t;
      bit  emio_enet2_gmii_rx_clk;
      bit  [2 : 0] emio_enet2_speed_mode;
      bit  emio_enet2_gmii_crs;
      bit  emio_enet2_gmii_col;
      bit  [7 : 0] emio_enet2_gmii_rxd;
      bit  emio_enet2_gmii_rx_er;
      bit  emio_enet2_gmii_rx_dv;
      bit  emio_enet2_gmii_tx_clk;
      bit  [7 : 0] emio_enet2_gmii_txd;
      bit  emio_enet2_gmii_tx_en;
      bit  emio_enet2_gmii_tx_er;
      bit  emio_enet2_mdio_mdc;
      bit  emio_enet2_mdio_i;
      bit  emio_enet2_mdio_o;
      bit  emio_enet2_mdio_t;
      bit  emio_enet3_gmii_rx_clk;
      bit  [2 : 0] emio_enet3_speed_mode;
      bit  emio_enet3_gmii_crs;
      bit  emio_enet3_gmii_col;
      bit  [7 : 0] emio_enet3_gmii_rxd;
      bit  emio_enet3_gmii_rx_er;
      bit  emio_enet3_gmii_rx_dv;
      bit  emio_enet3_gmii_tx_clk;
      bit  [7 : 0] emio_enet3_gmii_txd;
      bit  emio_enet3_gmii_tx_en;
      bit  emio_enet3_gmii_tx_er;
      bit  emio_enet3_mdio_mdc;
      bit  emio_enet3_mdio_i;
      bit  emio_enet3_mdio_o;
      bit  emio_enet3_mdio_t;
      bit  emio_enet0_tx_r_data_rdy;
      bit  emio_enet0_tx_r_rd;
      bit  emio_enet0_tx_r_valid;
      bit  [7 : 0] emio_enet0_tx_r_data;
      bit  emio_enet0_tx_r_sop;
      bit  emio_enet0_tx_r_eop;
      bit  emio_enet0_tx_r_err;
      bit  emio_enet0_tx_r_underflow;
      bit  emio_enet0_tx_r_flushed;
      bit  emio_enet0_tx_r_control;
      bit  emio_enet0_dma_tx_end_tog;
      bit  emio_enet0_dma_tx_status_tog;
      bit  [3 : 0] emio_enet0_tx_r_status;
      bit  emio_enet0_rx_w_wr;
      bit  [7 : 0] emio_enet0_rx_w_data;
      bit  emio_enet0_rx_w_sop;
      bit  emio_enet0_rx_w_eop;
      bit  [44 : 0] emio_enet0_rx_w_status;
      bit  emio_enet0_rx_w_err;
      bit  emio_enet0_rx_w_overflow;
      bit  emio_enet0_rx_w_flush;
      bit  emio_enet0_tx_r_fixed_lat;
      bit  fmio_gem0_fifo_tx_clk_to_pl_bufg;
      bit  fmio_gem0_fifo_rx_clk_to_pl_bufg;
      bit  emio_enet1_tx_r_data_rdy;
      bit  emio_enet1_tx_r_rd;
      bit  emio_enet1_tx_r_valid;
      bit  [7 : 0] emio_enet1_tx_r_data;
      bit  emio_enet1_tx_r_sop;
      bit  emio_enet1_tx_r_eop;
      bit  emio_enet1_tx_r_err;
      bit  emio_enet1_tx_r_underflow;
      bit  emio_enet1_tx_r_flushed;
      bit  emio_enet1_tx_r_control;
      bit  emio_enet1_dma_tx_end_tog;
      bit  emio_enet1_dma_tx_status_tog;
      bit  [3 : 0] emio_enet1_tx_r_status;
      bit  emio_enet1_rx_w_wr;
      bit  [7 : 0] emio_enet1_rx_w_data;
      bit  emio_enet1_rx_w_sop;
      bit  emio_enet1_rx_w_eop;
      bit  [44 : 0] emio_enet1_rx_w_status;
      bit  emio_enet1_rx_w_err;
      bit  emio_enet1_rx_w_overflow;
      bit  emio_enet1_rx_w_flush;
      bit  emio_enet1_tx_r_fixed_lat;
      bit  fmio_gem1_fifo_tx_clk_to_pl_bufg;
      bit  fmio_gem1_fifo_rx_clk_to_pl_bufg;
      bit  emio_enet2_tx_r_data_rdy;
      bit  emio_enet2_tx_r_rd;
      bit  emio_enet2_tx_r_valid;
      bit  [7 : 0] emio_enet2_tx_r_data;
      bit  emio_enet2_tx_r_sop;
      bit  emio_enet2_tx_r_eop;
      bit  emio_enet2_tx_r_err;
      bit  emio_enet2_tx_r_underflow;
      bit  emio_enet2_tx_r_flushed;
      bit  emio_enet2_tx_r_control;
      bit  emio_enet2_dma_tx_end_tog;
      bit  emio_enet2_dma_tx_status_tog;
      bit  [3 : 0] emio_enet2_tx_r_status;
      bit  emio_enet2_rx_w_wr;
      bit  [7 : 0] emio_enet2_rx_w_data;
      bit  emio_enet2_rx_w_sop;
      bit  emio_enet2_rx_w_eop;
      bit  [44 : 0] emio_enet2_rx_w_status;
      bit  emio_enet2_rx_w_err;
      bit  emio_enet2_rx_w_overflow;
      bit  emio_enet2_rx_w_flush;
      bit  emio_enet2_tx_r_fixed_lat;
      bit  fmio_gem2_fifo_tx_clk_to_pl_bufg;
      bit  fmio_gem2_fifo_rx_clk_to_pl_bufg;
      bit  emio_enet3_tx_r_data_rdy;
      bit  emio_enet3_tx_r_rd;
      bit  emio_enet3_tx_r_valid;
      bit  [7 : 0] emio_enet3_tx_r_data;
      bit  emio_enet3_tx_r_sop;
      bit  emio_enet3_tx_r_eop;
      bit  emio_enet3_tx_r_err;
      bit  emio_enet3_tx_r_underflow;
      bit  emio_enet3_tx_r_flushed;
      bit  emio_enet3_tx_r_control;
      bit  emio_enet3_dma_tx_end_tog;
      bit  emio_enet3_dma_tx_status_tog;
      bit  [3 : 0] emio_enet3_tx_r_status;
      bit  emio_enet3_rx_w_wr;
      bit  [7 : 0] emio_enet3_rx_w_data;
      bit  emio_enet3_rx_w_sop;
      bit  emio_enet3_rx_w_eop;
      bit  [44 : 0] emio_enet3_rx_w_status;
      bit  emio_enet3_rx_w_err;
      bit  emio_enet3_rx_w_overflow;
      bit  emio_enet3_rx_w_flush;
      bit  emio_enet3_tx_r_fixed_lat;
      bit  fmio_gem3_fifo_tx_clk_to_pl_bufg;
      bit  fmio_gem3_fifo_rx_clk_to_pl_bufg;
      bit  emio_enet0_tx_sof;
      bit  emio_enet0_sync_frame_tx;
      bit  emio_enet0_delay_req_tx;
      bit  emio_enet0_pdelay_req_tx;
      bit  emio_enet0_pdelay_resp_tx;
      bit  emio_enet0_rx_sof;
      bit  emio_enet0_sync_frame_rx;
      bit  emio_enet0_delay_req_rx;
      bit  emio_enet0_pdelay_req_rx;
      bit  emio_enet0_pdelay_resp_rx;
      bit  [1 : 0] emio_enet0_tsu_inc_ctrl;
      bit  emio_enet0_tsu_timer_cmp_val;
      bit  emio_enet1_tx_sof;
      bit  emio_enet1_sync_frame_tx;
      bit  emio_enet1_delay_req_tx;
      bit  emio_enet1_pdelay_req_tx;
      bit  emio_enet1_pdelay_resp_tx;
      bit  emio_enet1_rx_sof;
      bit  emio_enet1_sync_frame_rx;
      bit  emio_enet1_delay_req_rx;
      bit  emio_enet1_pdelay_req_rx;
      bit  emio_enet1_pdelay_resp_rx;
      bit  [1 : 0] emio_enet1_tsu_inc_ctrl;
      bit  emio_enet1_tsu_timer_cmp_val;
      bit  emio_enet2_tx_sof;
      bit  emio_enet2_sync_frame_tx;
      bit  emio_enet2_delay_req_tx;
      bit  emio_enet2_pdelay_req_tx;
      bit  emio_enet2_pdelay_resp_tx;
      bit  emio_enet2_rx_sof;
      bit  emio_enet2_sync_frame_rx;
      bit  emio_enet2_delay_req_rx;
      bit  emio_enet2_pdelay_req_rx;
      bit  emio_enet2_pdelay_resp_rx;
      bit  [1 : 0] emio_enet2_tsu_inc_ctrl;
      bit  emio_enet2_tsu_timer_cmp_val;
      bit  emio_enet3_tx_sof;
      bit  emio_enet3_sync_frame_tx;
      bit  emio_enet3_delay_req_tx;
      bit  emio_enet3_pdelay_req_tx;
      bit  emio_enet3_pdelay_resp_tx;
      bit  emio_enet3_rx_sof;
      bit  emio_enet3_sync_frame_rx;
      bit  emio_enet3_delay_req_rx;
      bit  emio_enet3_pdelay_req_rx;
      bit  emio_enet3_pdelay_resp_rx;
      bit  [1 : 0] emio_enet3_tsu_inc_ctrl;
      bit  emio_enet3_tsu_timer_cmp_val;
      bit  fmio_gem_tsu_clk_to_pl_bufg;
      bit  fmio_gem_tsu_clk_from_pl;
      bit  emio_enet_tsu_clk;
      bit  [93 : 0] emio_enet0_enet_tsu_timer_cnt;
      bit  emio_enet0_ext_int_in;
      bit  emio_enet1_ext_int_in;
      bit  emio_enet2_ext_int_in;
      bit  emio_enet3_ext_int_in;
      bit  [1 : 0] emio_enet0_dma_bus_width;
      bit  [1 : 0] emio_enet1_dma_bus_width;
      bit  [1 : 0] emio_enet2_dma_bus_width;
      bit  [1 : 0] emio_enet3_dma_bus_width;
      bit  [0 : 0] emio_gpio_i;
      bit  [0 : 0] emio_gpio_o;
      bit  [0 : 0] emio_gpio_t;
      bit  emio_i2c0_scl_i;
      bit  emio_i2c0_scl_o;
      bit  emio_i2c0_scl_t;
      bit  emio_i2c0_sda_i;
      bit  emio_i2c0_sda_o;
      bit  emio_i2c0_sda_t;
      bit  emio_i2c1_scl_i;
      bit  emio_i2c1_scl_o;
      bit  emio_i2c1_scl_t;
      bit  emio_i2c1_sda_i;
      bit  emio_i2c1_sda_o;
      bit  emio_i2c1_sda_t;
      bit  emio_uart0_txd;
      bit  emio_uart0_rxd;
      bit  emio_uart0_ctsn;
      bit  emio_uart0_rtsn;
      bit  emio_uart0_dsrn;
      bit  emio_uart0_dcdn;
      bit  emio_uart0_rin;
      bit  emio_uart0_dtrn;
      bit  emio_uart1_txd;
      bit  emio_uart1_rxd;
      bit  emio_uart1_ctsn;
      bit  emio_uart1_rtsn;
      bit  emio_uart1_dsrn;
      bit  emio_uart1_dcdn;
      bit  emio_uart1_rin;
      bit  emio_uart1_dtrn;
      bit  emio_sdio0_clkout;
      bit  emio_sdio0_fb_clk_in;
      bit  emio_sdio0_cmdout;
      bit  emio_sdio0_cmdin;
      bit  emio_sdio0_cmdena;
      bit  [7 : 0] emio_sdio0_datain;
      bit  [7 : 0] emio_sdio0_dataout;
      bit  [7 : 0] emio_sdio0_dataena;
      bit  emio_sdio0_cd_n;
      bit  emio_sdio0_wp;
      bit  emio_sdio0_ledcontrol;
      bit  emio_sdio0_buspower;
      bit  [2 : 0] emio_sdio0_bus_volt;
      bit  emio_sdio1_clkout;
      bit  emio_sdio1_fb_clk_in;
      bit  emio_sdio1_cmdout;
      bit  emio_sdio1_cmdin;
      bit  emio_sdio1_cmdena;
      bit  [7 : 0] emio_sdio1_datain;
      bit  [7 : 0] emio_sdio1_dataout;
      bit  [7 : 0] emio_sdio1_dataena;
      bit  emio_sdio1_cd_n;
      bit  emio_sdio1_wp;
      bit  emio_sdio1_ledcontrol;
      bit  emio_sdio1_buspower;
      bit  [2 : 0] emio_sdio1_bus_volt;
      bit  emio_spi0_sclk_i;
      bit  emio_spi0_sclk_o;
      bit  emio_spi0_sclk_t;
      bit  emio_spi0_m_i;
      bit  emio_spi0_m_o;
      bit  emio_spi0_mo_t;
      bit  emio_spi0_s_i;
      bit  emio_spi0_s_o;
      bit  emio_spi0_so_t;
      bit  emio_spi0_ss_i_n;
      bit  emio_spi0_ss_o_n;
      bit  emio_spi0_ss1_o_n;
      bit  emio_spi0_ss2_o_n;
      bit  emio_spi0_ss_n_t;
      bit  emio_spi1_sclk_i;
      bit  emio_spi1_sclk_o;
      bit  emio_spi1_sclk_t;
      bit  emio_spi1_m_i;
      bit  emio_spi1_m_o;
      bit  emio_spi1_mo_t;
      bit  emio_spi1_s_i;
      bit  emio_spi1_s_o;
      bit  emio_spi1_so_t;
      bit  emio_spi1_ss_i_n;
      bit  emio_spi1_ss_o_n;
      bit  emio_spi1_ss1_o_n;
      bit  emio_spi1_ss2_o_n;
      bit  emio_spi1_ss_n_t;
      bit  pl_ps_trace_clk;
      bit  ps_pl_tracectl;
      bit  [31 : 0] ps_pl_tracedata;
      bit  trace_clk_out;
      bit  [2 : 0] emio_ttc0_wave_o;
      bit  [2 : 0] emio_ttc0_clk_i;
      bit  [2 : 0] emio_ttc1_wave_o;
      bit  [2 : 0] emio_ttc1_clk_i;
      bit  [2 : 0] emio_ttc2_wave_o;
      bit  [2 : 0] emio_ttc2_clk_i;
      bit  [2 : 0] emio_ttc3_wave_o;
      bit  [2 : 0] emio_ttc3_clk_i;
      bit  emio_wdt0_clk_i;
      bit  emio_wdt0_rst_o;
      bit  emio_wdt1_clk_i;
      bit  emio_wdt1_rst_o;
      bit  emio_hub_port_overcrnt_usb3_0;
      bit  emio_hub_port_overcrnt_usb3_1;
      bit  emio_hub_port_overcrnt_usb2_0;
      bit  emio_hub_port_overcrnt_usb2_1;
      bit  emio_u2dsport_vbus_ctrl_usb3_0;
      bit  emio_u2dsport_vbus_ctrl_usb3_1;
      bit  emio_u3dsport_vbus_ctrl_usb3_0;
      bit  emio_u3dsport_vbus_ctrl_usb3_1;
      bit  [7 : 0] adma_fci_clk;
      bit  [7 : 0] pl2adma_cvld;
      bit  [7 : 0] pl2adma_tack;
      bit  [7 : 0] adma2pl_cack;
      bit  [7 : 0] adma2pl_tvld;
      bit  [7 : 0] perif_gdma_clk;
      bit  [7 : 0] perif_gdma_cvld;
      bit  [7 : 0] perif_gdma_tack;
      bit  [7 : 0] gdma_perif_cack;
      bit  [7 : 0] gdma_perif_tvld;
      bit  [3 : 0] pl_clock_stop;
      bit  [1 : 0] pll_aux_refclk_lpd;
      bit  [2 : 0] pll_aux_refclk_fpd;
      bit  dp_audio_ref_clk;
      bit  dp_video_ref_clk;
      bit  [31 : 0] dp_s_axis_audio_tdata;
      bit  dp_s_axis_audio_tid;
      bit  dp_s_axis_audio_tvalid;
      bit  dp_s_axis_audio_tready;
      bit  [31 : 0] dp_m_axis_mixed_audio_tdata;
      bit  dp_m_axis_mixed_audio_tid;
      bit  dp_m_axis_mixed_audio_tvalid;
      bit  dp_m_axis_mixed_audio_tready;
      bit  dp_s_axis_audio_clk;
      bit  dp_live_video_in_vsync;
      bit  dp_live_video_in_hsync;
      bit  dp_live_video_in_de;
      bit  [35 : 0] dp_live_video_in_pixel1;
      bit  dp_video_in_clk;
      bit  dp_video_out_hsync;
      bit  dp_video_out_vsync;
      bit  [35 : 0] dp_video_out_pixel1;
      bit  dp_aux_data_in;
      bit  dp_aux_data_out;
      bit  dp_aux_data_oe_n;
      bit  [7 : 0] dp_live_gfx_alpha_in;
      bit  [35 : 0] dp_live_gfx_pixel1_in;
      bit  dp_hot_plug_detect;
      bit  dp_external_custom_event1;
      bit  dp_external_custom_event2;
      bit  dp_external_vsync_event;
      bit  dp_live_video_de_out;
      bit  pl_ps_eventi;
      bit  ps_pl_evento;
      bit  [3 : 0] ps_pl_standbywfe;
      bit  [3 : 0] ps_pl_standbywfi;
      bit  [3 : 0] pl_ps_apugic_irq;
      bit  [3 : 0] pl_ps_apugic_fiq;
      bit  rpu_eventi0;
      bit  rpu_eventi1;
      bit  rpu_evento0;
      bit  rpu_evento1;
      bit  nfiq0_lpd_rpu;
      bit  nfiq1_lpd_rpu;
      bit  nirq0_lpd_rpu;
      bit  nirq1_lpd_rpu;
      bit  irq_ipi_pl_0;
      bit  irq_ipi_pl_1;
      bit  irq_ipi_pl_2;
      bit  irq_ipi_pl_3;
      bit  [59 : 0] stm_event;
      bit  pl_ps_trigger_0;
      bit  pl_ps_trigger_1;
      bit  pl_ps_trigger_2;
      bit  pl_ps_trigger_3;
      bit  ps_pl_trigack_0;
      bit  ps_pl_trigack_1;
      bit  ps_pl_trigack_2;
      bit  ps_pl_trigack_3;
      bit  ps_pl_trigger_0;
      bit  ps_pl_trigger_1;
      bit  ps_pl_trigger_2;
      bit  ps_pl_trigger_3;
      bit  pl_ps_trigack_0;
      bit  pl_ps_trigack_1;
      bit  pl_ps_trigack_2;
      bit  pl_ps_trigack_3;
      bit  [31 : 0] ftm_gpo;
      bit  [31 : 0] ftm_gpi;
      bit  [0 : 0] pl_ps_irq0;
      bit  [0 : 0] pl_ps_irq1;
      bit  pl_resetn0;
      bit  pl_resetn1;
      bit  pl_resetn2;
      bit  pl_resetn3;
      bit  osc_rtc_clk;
      bit  [31 : 0] pl_pmu_gpi;
      bit  [31 : 0] pmu_pl_gpo;
      bit  aib_pmu_afifm_fpd_ack;
      bit  aib_pmu_afifm_lpd_ack;
      bit  pmu_aib_afifm_fpd_req;
      bit  pmu_aib_afifm_lpd_req;
      bit  [3 : 0] pmu_error_from_pl;
      bit  [46 : 0] pmu_error_to_pl;
      bit  pl_acpinact;
      bit  pl_clk0;
      bit  pl_clk1;
      bit  pl_clk2;
      bit  pl_clk3;
      bit  ps_pl_irq_can0;
      bit  ps_pl_irq_can1;
      bit  ps_pl_irq_enet0;
      bit  ps_pl_irq_enet1;
      bit  ps_pl_irq_enet2;
      bit  ps_pl_irq_enet3;
      bit  ps_pl_irq_enet0_wake;
      bit  ps_pl_irq_enet1_wake;
      bit  ps_pl_irq_enet2_wake;
      bit  ps_pl_irq_enet3_wake;
      bit  ps_pl_irq_gpio;
      bit  ps_pl_irq_i2c0;
      bit  ps_pl_irq_i2c1;
      bit  ps_pl_irq_uart0;
      bit  ps_pl_irq_uart1;
      bit  ps_pl_irq_sdio0;
      bit  ps_pl_irq_sdio1;
      bit  ps_pl_irq_sdio0_wake;
      bit  ps_pl_irq_sdio1_wake;
      bit  ps_pl_irq_spi0;
      bit  ps_pl_irq_spi1;
      bit  ps_pl_irq_qspi;
      bit  ps_pl_irq_ttc0_0;
      bit  ps_pl_irq_ttc0_1;
      bit  ps_pl_irq_ttc0_2;
      bit  ps_pl_irq_ttc1_0;
      bit  ps_pl_irq_ttc1_1;
      bit  ps_pl_irq_ttc1_2;
      bit  ps_pl_irq_ttc2_0;
      bit  ps_pl_irq_ttc2_1;
      bit  ps_pl_irq_ttc2_2;
      bit  ps_pl_irq_ttc3_0;
      bit  ps_pl_irq_ttc3_1;
      bit  ps_pl_irq_ttc3_2;
      bit  ps_pl_irq_csu_pmu_wdt;
      bit  ps_pl_irq_lp_wdt;
      bit  [3 : 0] ps_pl_irq_usb3_0_endpoint;
      bit  ps_pl_irq_usb3_0_otg;
      bit  [3 : 0] ps_pl_irq_usb3_1_endpoint;
      bit  ps_pl_irq_usb3_1_otg;
      bit  [7 : 0] ps_pl_irq_adma_chan;
      bit  [1 : 0] ps_pl_irq_usb3_0_pmu_wakeup;
      bit  [7 : 0] ps_pl_irq_gdma_chan;
      bit  ps_pl_irq_csu;
      bit  ps_pl_irq_csu_dma;
      bit  ps_pl_irq_efuse;
      bit  ps_pl_irq_xmpu_lpd;
      bit  ps_pl_irq_ddr_ss;
      bit  ps_pl_irq_nand;
      bit  ps_pl_irq_fp_wdt;
      bit  [1 : 0] ps_pl_irq_pcie_msi;
      bit  ps_pl_irq_pcie_legacy;
      bit  ps_pl_irq_pcie_dma;
      bit  ps_pl_irq_pcie_msc;
      bit  ps_pl_irq_dport;
      bit  ps_pl_irq_fpd_apb_int;
      bit  ps_pl_irq_fpd_atb_error;
      bit  ps_pl_irq_dpdma;
      bit  ps_pl_irq_apm_fpd;
      bit  ps_pl_irq_gpu;
      bit  ps_pl_irq_sata;
      bit  ps_pl_irq_xmpu_fpd;
      bit  [3 : 0] ps_pl_irq_apu_cpumnt;
      bit  [3 : 0] ps_pl_irq_apu_cti;
      bit  [3 : 0] ps_pl_irq_apu_pmu;
      bit  [3 : 0] ps_pl_irq_apu_comm;
      bit  ps_pl_irq_apu_l2err;
      bit  ps_pl_irq_apu_exterr;
      bit  ps_pl_irq_apu_regs;
      bit  ps_pl_irq_intf_ppd_cci;
      bit  ps_pl_irq_intf_fpd_smmu;
      bit  ps_pl_irq_atb_err_lpd;
      bit  ps_pl_irq_aib_axi;
      bit  ps_pl_irq_ams;
      bit  ps_pl_irq_lpd_apm;
      bit  ps_pl_irq_rtc_alaram;
      bit  ps_pl_irq_rtc_seconds;
      bit  ps_pl_irq_clkmon;
      bit  ps_pl_irq_ipi_channel0;
      bit  ps_pl_irq_ipi_channel1;
      bit  ps_pl_irq_ipi_channel2;
      bit  ps_pl_irq_ipi_channel7;
      bit  ps_pl_irq_ipi_channel8;
      bit  ps_pl_irq_ipi_channel9;
      bit  ps_pl_irq_ipi_channel10;
      bit  [1 : 0] ps_pl_irq_rpu_pm;
      bit  ps_pl_irq_ocm_error;
      bit  ps_pl_irq_lpd_apb_intr;
      bit  ps_pl_irq_r5_core0_ecc_error;
      bit  ps_pl_irq_r5_core1_ecc_error;
      bit  [3 : 0] test_adc_clk;
      bit  [31 : 0] test_adc_in;
      bit  [31 : 0] test_adc2_in;
      bit  [15 : 0] test_db;
      bit  [19 : 0] test_adc_out;
      bit  [7 : 0] test_ams_osc;
      bit  [15 : 0] test_mon_data;
      bit  test_dclk;
      bit  test_den;
      bit  test_dwe;
      bit  [7 : 0] test_daddr;
      bit  [15 : 0] test_di;
      bit  test_drdy;
      bit  [15 : 0] test_do;
      bit  test_convst;
      bit  [3 : 0] pstp_pl_clk;
      bit  [31 : 0] pstp_pl_in;
      bit  [31 : 0] pstp_pl_out;
      bit  [31 : 0] pstp_pl_ts;
      bit  fmio_test_gem_scanmux_1;
      bit  fmio_test_gem_scanmux_2;
      bit  test_char_mode_fpd_n;
      bit  test_char_mode_lpd_n;
      bit  fmio_test_io_char_scan_clock;
      bit  fmio_test_io_char_scanenable;
      bit  fmio_test_io_char_scan_in;
      bit  fmio_test_io_char_scan_out;
      bit  fmio_test_io_char_scan_reset_n;
      bit  fmio_char_afifslpd_test_select_n;
      bit  fmio_char_afifslpd_test_input;
      bit  fmio_char_afifslpd_test_output;
      bit  fmio_char_afifsfpd_test_select_n;
      bit  fmio_char_afifsfpd_test_input;
      bit  fmio_char_afifsfpd_test_output;
      bit  io_char_audio_in_test_data;
      bit  io_char_audio_mux_sel_n;
      bit  io_char_video_in_test_data;
      bit  io_char_video_mux_sel_n;
      bit  io_char_video_out_test_data;
      bit  io_char_audio_out_test_data;
      bit  fmio_test_qspi_scanmux_1_n;
      bit  fmio_test_sdio_scanmux_1;
      bit  fmio_test_sdio_scanmux_2;
      bit  [3 : 0] fmio_sd0_dll_test_in_n;
      bit  [7 : 0] fmio_sd0_dll_test_out;
      bit  [3 : 0] fmio_sd1_dll_test_in_n;
      bit  [7 : 0] fmio_sd1_dll_test_out;
      bit  test_pl_scan_chopper_si;
      bit  test_pl_scan_chopper_so;
      bit  test_pl_scan_chopper_trig;
      bit  test_pl_scan_clk0;
      bit  test_pl_scan_clk1;
      bit  test_pl_scan_edt_clk;
      bit  test_pl_scan_edt_in_apu;
      bit  test_pl_scan_edt_in_cpu;
      bit  [3 : 0] test_pl_scan_edt_in_ddr;
      bit  [9 : 0] test_pl_scan_edt_in_fp;
      bit  [3 : 0] test_pl_scan_edt_in_gpu;
      bit  [8 : 0] test_pl_scan_edt_in_lp;
      bit  [1 : 0] test_pl_scan_edt_in_usb3;
      bit  test_pl_scan_edt_out_apu;
      bit  test_pl_scan_edt_out_cpu0;
      bit  test_pl_scan_edt_out_cpu1;
      bit  test_pl_scan_edt_out_cpu2;
      bit  test_pl_scan_edt_out_cpu3;
      bit  [3 : 0] test_pl_scan_edt_out_ddr;
      bit  [9 : 0] test_pl_scan_edt_out_fp;
      bit  [3 : 0] test_pl_scan_edt_out_gpu;
      bit  [8 : 0] test_pl_scan_edt_out_lp;
      bit  [1 : 0] test_pl_scan_edt_out_usb3;
      bit  test_pl_scan_edt_update;
      bit  test_pl_scan_reset_n;
      bit  test_pl_scanenable;
      bit  test_pl_scan_pll_reset;
      bit  test_pl_scan_spare_in0;
      bit  test_pl_scan_spare_in1;
      bit  test_pl_scan_spare_out0;
      bit  test_pl_scan_spare_out1;
      bit  test_pl_scan_wrap_clk;
      bit  test_pl_scan_wrap_ishift;
      bit  test_pl_scan_wrap_oshift;
      bit  test_pl_scan_slcr_config_clk;
      bit  test_pl_scan_slcr_config_rstn;
      bit  test_pl_scan_slcr_config_si;
      bit  test_pl_scan_spare_in2;
      bit  test_pl_scanenable_slcr_en;
      bit  [4 : 0] test_pl_pll_lock_out;
      bit  test_pl_scan_slcr_config_so;
      bit  [20 : 0] tst_rtc_calibreg_in;
      bit  [20 : 0] tst_rtc_calibreg_out;
      bit  tst_rtc_calibreg_we;
      bit  tst_rtc_clk;
      bit  tst_rtc_osc_clk_out;
      bit  [31 : 0] tst_rtc_sec_counter_out;
      bit  tst_rtc_seconds_raw_int;
      bit  tst_rtc_testclock_select_n;
      bit  [15 : 0] tst_rtc_tick_counter_out;
      bit  [31 : 0] tst_rtc_timesetreg_in;
      bit  [31 : 0] tst_rtc_timesetreg_out;
      bit  tst_rtc_disable_bat_op;
      bit  [3 : 0] tst_rtc_osc_cntrl_in;
      bit  [3 : 0] tst_rtc_osc_cntrl_out;
      bit  tst_rtc_osc_cntrl_we;
      bit  tst_rtc_sec_reload;
      bit  tst_rtc_timesetreg_we;
      bit  tst_rtc_testmode_n;
      bit  test_usb0_funcmux_0_n;
      bit  test_usb1_funcmux_0_n;
      bit  test_usb0_scanmux_0_n;
      bit  test_usb1_scanmux_0_n;
      bit  [31 : 0] lpd_pll_test_out;
      bit  [2 : 0] pl_lpd_pll_test_ck_sel_n;
      bit  pl_lpd_pll_test_fract_clk_sel_n;
      bit  pl_lpd_pll_test_fract_en_n;
      bit  pl_lpd_pll_test_mux_sel;
      bit  [3 : 0] pl_lpd_pll_test_sel;
      bit  [31 : 0] fpd_pll_test_out;
      bit  [2 : 0] pl_fpd_pll_test_ck_sel_n;
      bit  pl_fpd_pll_test_fract_clk_sel_n;
      bit  pl_fpd_pll_test_fract_en_n;
      bit  [1 : 0] pl_fpd_pll_test_mux_sel;
      bit  [3 : 0] pl_fpd_pll_test_sel;
      bit  [1 : 0] fmio_char_gem_selection;
      bit  fmio_char_gem_test_select_n;
      bit  fmio_char_gem_test_input;
      bit  fmio_char_gem_test_output;
      bit  test_ddr2pl_dcd_skewout;
      bit  test_pl2ddr_dcd_sample_pulse;
      bit  test_bscan_en_n;
      bit  test_bscan_tdi;
      bit  test_bscan_updatedr;
      bit  test_bscan_shiftdr;
      bit  test_bscan_reset_tap_b;
      bit  test_bscan_misr_jtag_load;
      bit  test_bscan_intest;
      bit  test_bscan_extest;
      bit  test_bscan_clockdr;
      bit  test_bscan_ac_mode;
      bit  test_bscan_ac_test;
      bit  test_bscan_init_memory;
      bit  test_bscan_mode_c;
      bit  test_bscan_tdo;
      bit  i_dbg_l0_txclk;
      bit  i_dbg_l0_rxclk;
      bit  i_dbg_l1_txclk;
      bit  i_dbg_l1_rxclk;
      bit  i_dbg_l2_txclk;
      bit  i_dbg_l2_rxclk;
      bit  i_dbg_l3_txclk;
      bit  i_dbg_l3_rxclk;
      bit  i_afe_rx_symbol_clk_by_2_pl;
      bit  pl_fpd_spare_0_in;
      bit  pl_fpd_spare_1_in;
      bit  pl_fpd_spare_2_in;
      bit  pl_fpd_spare_3_in;
      bit  pl_fpd_spare_4_in;
      bit  fpd_pl_spare_0_out;
      bit  fpd_pl_spare_1_out;
      bit  fpd_pl_spare_2_out;
      bit  fpd_pl_spare_3_out;
      bit  fpd_pl_spare_4_out;
      bit  pl_lpd_spare_0_in;
      bit  pl_lpd_spare_1_in;
      bit  pl_lpd_spare_2_in;
      bit  pl_lpd_spare_3_in;
      bit  pl_lpd_spare_4_in;
      bit  lpd_pl_spare_0_out;
      bit  lpd_pl_spare_1_out;
      bit  lpd_pl_spare_2_out;
      bit  lpd_pl_spare_3_out;
      bit  lpd_pl_spare_4_out;
      bit  o_dbg_l0_phystatus;
      bit  [19 : 0] o_dbg_l0_rxdata;
      bit  [1 : 0] o_dbg_l0_rxdatak;
      bit  o_dbg_l0_rxvalid;
      bit  [2 : 0] o_dbg_l0_rxstatus;
      bit  o_dbg_l0_rxelecidle;
      bit  o_dbg_l0_rstb;
      bit  [19 : 0] o_dbg_l0_txdata;
      bit  [1 : 0] o_dbg_l0_txdatak;
      bit  [1 : 0] o_dbg_l0_rate;
      bit  [1 : 0] o_dbg_l0_powerdown;
      bit  o_dbg_l0_txelecidle;
      bit  o_dbg_l0_txdetrx_lpback;
      bit  o_dbg_l0_rxpolarity;
      bit  o_dbg_l0_tx_sgmii_ewrap;
      bit  o_dbg_l0_rx_sgmii_en_cdet;
      bit  [19 : 0] o_dbg_l0_sata_corerxdata;
      bit  [1 : 0] o_dbg_l0_sata_corerxdatavalid;
      bit  o_dbg_l0_sata_coreready;
      bit  o_dbg_l0_sata_coreclockready;
      bit  o_dbg_l0_sata_corerxsignaldet;
      bit  [19 : 0] o_dbg_l0_sata_phyctrltxdata;
      bit  o_dbg_l0_sata_phyctrltxidle;
      bit  [1 : 0] o_dbg_l0_sata_phyctrltxrate;
      bit  [1 : 0] o_dbg_l0_sata_phyctrlrxrate;
      bit  o_dbg_l0_sata_phyctrltxrst;
      bit  o_dbg_l0_sata_phyctrlrxrst;
      bit  o_dbg_l0_sata_phyctrlreset;
      bit  o_dbg_l0_sata_phyctrlpartial;
      bit  o_dbg_l0_sata_phyctrlslumber;
      bit  o_dbg_l1_phystatus;
      bit  [19 : 0] o_dbg_l1_rxdata;
      bit  [1 : 0] o_dbg_l1_rxdatak;
      bit  o_dbg_l1_rxvalid;
      bit  [2 : 0] o_dbg_l1_rxstatus;
      bit  o_dbg_l1_rxelecidle;
      bit  o_dbg_l1_rstb;
      bit  [19 : 0] o_dbg_l1_txdata;
      bit  [1 : 0] o_dbg_l1_txdatak;
      bit  [1 : 0] o_dbg_l1_rate;
      bit  [1 : 0] o_dbg_l1_powerdown;
      bit  o_dbg_l1_txelecidle;
      bit  o_dbg_l1_txdetrx_lpback;
      bit  o_dbg_l1_rxpolarity;
      bit  o_dbg_l1_tx_sgmii_ewrap;
      bit  o_dbg_l1_rx_sgmii_en_cdet;
      bit  [19 : 0] o_dbg_l1_sata_corerxdata;
      bit  [1 : 0] o_dbg_l1_sata_corerxdatavalid;
      bit  o_dbg_l1_sata_coreready;
      bit  o_dbg_l1_sata_coreclockready;
      bit  o_dbg_l1_sata_corerxsignaldet;
      bit  [19 : 0] o_dbg_l1_sata_phyctrltxdata;
      bit  o_dbg_l1_sata_phyctrltxidle;
      bit  [1 : 0] o_dbg_l1_sata_phyctrltxrate;
      bit  [1 : 0] o_dbg_l1_sata_phyctrlrxrate;
      bit  o_dbg_l1_sata_phyctrltxrst;
      bit  o_dbg_l1_sata_phyctrlrxrst;
      bit  o_dbg_l1_sata_phyctrlreset;
      bit  o_dbg_l1_sata_phyctrlpartial;
      bit  o_dbg_l1_sata_phyctrlslumber;
      bit  o_dbg_l2_phystatus;
      bit  [19 : 0] o_dbg_l2_rxdata;
      bit  [1 : 0] o_dbg_l2_rxdatak;
      bit  o_dbg_l2_rxvalid;
      bit  [2 : 0] o_dbg_l2_rxstatus;
      bit  o_dbg_l2_rxelecidle;
      bit  o_dbg_l2_rstb;
      bit  [19 : 0] o_dbg_l2_txdata;
      bit  [1 : 0] o_dbg_l2_txdatak;
      bit  [1 : 0] o_dbg_l2_rate;
      bit  [1 : 0] o_dbg_l2_powerdown;
      bit  o_dbg_l2_txelecidle;
      bit  o_dbg_l2_txdetrx_lpback;
      bit  o_dbg_l2_rxpolarity;
      bit  o_dbg_l2_tx_sgmii_ewrap;
      bit  o_dbg_l2_rx_sgmii_en_cdet;
      bit  [19 : 0] o_dbg_l2_sata_corerxdata;
      bit  [1 : 0] o_dbg_l2_sata_corerxdatavalid;
      bit  o_dbg_l2_sata_coreready;
      bit  o_dbg_l2_sata_coreclockready;
      bit  o_dbg_l2_sata_corerxsignaldet;
      bit  [19 : 0] o_dbg_l2_sata_phyctrltxdata;
      bit  o_dbg_l2_sata_phyctrltxidle;
      bit  [1 : 0] o_dbg_l2_sata_phyctrltxrate;
      bit  [1 : 0] o_dbg_l2_sata_phyctrlrxrate;
      bit  o_dbg_l2_sata_phyctrltxrst;
      bit  o_dbg_l2_sata_phyctrlrxrst;
      bit  o_dbg_l2_sata_phyctrlreset;
      bit  o_dbg_l2_sata_phyctrlpartial;
      bit  o_dbg_l2_sata_phyctrlslumber;
      bit  o_dbg_l3_phystatus;
      bit  [19 : 0] o_dbg_l3_rxdata;
      bit  [1 : 0] o_dbg_l3_rxdatak;
      bit  o_dbg_l3_rxvalid;
      bit  [2 : 0] o_dbg_l3_rxstatus;
      bit  o_dbg_l3_rxelecidle;
      bit  o_dbg_l3_rstb;
      bit  [19 : 0] o_dbg_l3_txdata;
      bit  [1 : 0] o_dbg_l3_txdatak;
      bit  [1 : 0] o_dbg_l3_rate;
      bit  [1 : 0] o_dbg_l3_powerdown;
      bit  o_dbg_l3_txelecidle;
      bit  o_dbg_l3_txdetrx_lpback;
      bit  o_dbg_l3_rxpolarity;
      bit  o_dbg_l3_tx_sgmii_ewrap;
      bit  o_dbg_l3_rx_sgmii_en_cdet;
      bit  [19 : 0] o_dbg_l3_sata_corerxdata;
      bit  [1 : 0] o_dbg_l3_sata_corerxdatavalid;
      bit  o_dbg_l3_sata_coreready;
      bit  o_dbg_l3_sata_coreclockready;
      bit  o_dbg_l3_sata_corerxsignaldet;
      bit  [19 : 0] o_dbg_l3_sata_phyctrltxdata;
      bit  o_dbg_l3_sata_phyctrltxidle;
      bit  [1 : 0] o_dbg_l3_sata_phyctrltxrate;
      bit  [1 : 0] o_dbg_l3_sata_phyctrlrxrate;
      bit  o_dbg_l3_sata_phyctrltxrst;
      bit  o_dbg_l3_sata_phyctrlrxrst;
      bit  o_dbg_l3_sata_phyctrlreset;
      bit  o_dbg_l3_sata_phyctrlpartial;
      bit  o_dbg_l3_sata_phyctrlslumber;
      bit  dbg_path_fifo_bypass;
      bit  i_afe_pll_pd_hs_clock_r;
      bit  i_afe_mode;
      bit  i_bgcal_afe_mode;
      bit  o_afe_cmn_calib_comp_out;
      bit  i_afe_cmn_bg_enable_low_leakage;
      bit  i_afe_cmn_bg_iso_ctrl_bar;
      bit  i_afe_cmn_bg_pd;
      bit  i_afe_cmn_bg_pd_bg_ok;
      bit  i_afe_cmn_bg_pd_ptat;
      bit  i_afe_cmn_calib_en_iconst;
      bit  i_afe_cmn_calib_enable_low_leakage;
      bit  i_afe_cmn_calib_iso_ctrl_bar;
      bit  [12 : 0] o_afe_pll_dco_count;
      bit  o_afe_pll_clk_sym_hs;
      bit  o_afe_pll_fbclk_frac;
      bit  o_afe_rx_pipe_lfpsbcn_rxelecidle;
      bit  o_afe_rx_pipe_sigdet;
      bit  [19 : 0] o_afe_rx_symbol;
      bit  o_afe_rx_symbol_clk_by_2;
      bit  o_afe_rx_uphy_save_calcode;
      bit  o_afe_rx_uphy_startloop_buf;
      bit  o_afe_rx_uphy_rx_calib_done;
      bit  i_afe_rx_rxpma_rstb;
      bit  [7 : 0] i_afe_rx_uphy_restore_calcode_data;
      bit  i_afe_rx_pipe_rxeqtraining;
      bit  i_afe_rx_iso_hsrx_ctrl_bar;
      bit  i_afe_rx_iso_lfps_ctrl_bar;
      bit  i_afe_rx_iso_sigdet_ctrl_bar;
      bit  i_afe_rx_hsrx_clock_stop_req;
      bit  [7 : 0] o_afe_rx_uphy_save_calcode_data;
      bit  o_afe_rx_hsrx_clock_stop_ack;
      bit  o_afe_pg_avddcr;
      bit  o_afe_pg_avddio;
      bit  o_afe_pg_dvddcr;
      bit  o_afe_pg_static_avddcr;
      bit  o_afe_pg_static_avddio;
      bit  i_pll_afe_mode;
      bit  [10 : 0] i_afe_pll_coarse_code;
      bit  i_afe_pll_en_clock_hs_div2;
      bit  [15 : 0] i_afe_pll_fbdiv;
      bit  i_afe_pll_load_fbdiv;
      bit  i_afe_pll_pd;
      bit  i_afe_pll_pd_pfd;
      bit  i_afe_pll_rst_fdbk_div;
      bit  i_afe_pll_startloop;
      bit  [5 : 0] i_afe_pll_v2i_code;
      bit  [4 : 0] i_afe_pll_v2i_prog;
      bit  i_afe_pll_vco_cnt_window;
      bit  i_afe_rx_mphy_gate_symbol_clk;
      bit  i_afe_rx_mphy_mux_hsb_ls;
      bit  i_afe_rx_pipe_rx_term_enable;
      bit  i_afe_rx_uphy_biasgen_iconst_core_mirror_enable;
      bit  i_afe_rx_uphy_biasgen_iconst_io_mirror_enable;
      bit  i_afe_rx_uphy_biasgen_irconst_core_mirror_enable;
      bit  i_afe_rx_uphy_enable_cdr;
      bit  i_afe_rx_uphy_enable_low_leakage;
      bit  i_afe_rx_rxpma_refclk_dig;
      bit  i_afe_rx_uphy_hsrx_rstb;
      bit  i_afe_rx_uphy_pdn_hs_des;
      bit  i_afe_rx_uphy_pd_samp_c2c;
      bit  i_afe_rx_uphy_pd_samp_c2c_eclk;
      bit  i_afe_rx_uphy_pso_clk_lane;
      bit  i_afe_rx_uphy_pso_eq;
      bit  i_afe_rx_uphy_pso_hsrxdig;
      bit  i_afe_rx_uphy_pso_iqpi;
      bit  i_afe_rx_uphy_pso_lfpsbcn;
      bit  i_afe_rx_uphy_pso_samp_flops;
      bit  i_afe_rx_uphy_pso_sigdet;
      bit  i_afe_rx_uphy_restore_calcode;
      bit  i_afe_rx_uphy_run_calib;
      bit  i_afe_rx_uphy_rx_lane_polarity_swap;
      bit  i_afe_rx_uphy_startloop_pll;
      bit  [1 : 0] i_afe_rx_uphy_hsclk_division_factor;
      bit  [7 : 0] i_afe_rx_uphy_rx_pma_opmode;
      bit  [1 : 0] i_afe_tx_enable_hsclk_division;
      bit  i_afe_tx_enable_ldo;
      bit  i_afe_tx_enable_ref;
      bit  i_afe_tx_enable_supply_hsclk;
      bit  i_afe_tx_enable_supply_pipe;
      bit  i_afe_tx_enable_supply_serializer;
      bit  i_afe_tx_enable_supply_uphy;
      bit  i_afe_tx_hs_ser_rstb;
      bit  [19 : 0] i_afe_tx_hs_symbol;
      bit  i_afe_tx_mphy_tx_ls_data;
      bit  [1 : 0] i_afe_tx_pipe_tx_enable_idle_mode;
      bit  [1 : 0] i_afe_tx_pipe_tx_enable_lfps;
      bit  i_afe_tx_pipe_tx_enable_rxdet;
      bit  [7 : 0] i_afe_TX_uphy_txpma_opmode;
      bit  i_afe_TX_pmadig_digital_reset_n;
      bit  i_afe_TX_serializer_rst_rel;
      bit  i_afe_TX_pll_symb_clk_2;
      bit  [1 : 0] i_afe_TX_ana_if_rate;
      bit  i_afe_TX_en_dig_sublp_mode;
      bit  [2 : 0] i_afe_TX_LPBK_SEL;
      bit  i_afe_TX_iso_ctrl_bar;
      bit  i_afe_TX_ser_iso_ctrl_bar;
      bit  i_afe_TX_lfps_clk;
      bit  i_afe_TX_serializer_rstb;
      bit  o_afe_TX_dig_reset_rel_ack;
      bit  o_afe_TX_pipe_TX_dn_rxdet;
      bit  o_afe_TX_pipe_TX_dp_rxdet;
      bit  i_afe_tx_pipe_tx_fast_est_common_mode;
      bit  o_dbg_l0_txclk;
      bit  o_dbg_l0_rxclk;
      bit  o_dbg_l1_txclk;
      bit  o_dbg_l1_rxclk;
      bit  o_dbg_l2_txclk;
      bit  o_dbg_l2_rxclk;
      bit  o_dbg_l3_txclk;
      bit  o_dbg_l3_rxclk;
      bit  emio_i2c0_scl_t_n;
      bit  emio_i2c0_sda_t_n;
      bit  emio_enet0_mdio_t_n;
      bit  emio_enet1_mdio_t_n;
      bit  emio_enet2_mdio_t_n;
      bit  emio_enet3_mdio_t_n;
      bit  [0 : 0] emio_gpio_t_n;
      bit  emio_i2c1_scl_t_n;
      bit  emio_i2c1_sda_t_n;
      bit  emio_spi0_sclk_t_n;
      bit  emio_spi0_mo_t_n;
      bit  emio_spi0_so_t_n;
      bit  emio_spi0_ss_n_t_n;
      bit  emio_spi1_sclk_t_n;
      bit  emio_spi1_mo_t_n;
      bit  emio_spi1_so_t_n;
      bit  emio_spi1_ss_n_t_n;

//MODULE DECLARATION
 module zynqmpsoc_zynq_ultra_ps_e_0_0 (
  maxihpm0_fpd_aclk,
  maxigp0_awid,
  maxigp0_awaddr,
  maxigp0_awlen,
  maxigp0_awsize,
  maxigp0_awburst,
  maxigp0_awlock,
  maxigp0_awcache,
  maxigp0_awprot,
  maxigp0_awvalid,
  maxigp0_awuser,
  maxigp0_awready,
  maxigp0_wdata,
  maxigp0_wstrb,
  maxigp0_wlast,
  maxigp0_wvalid,
  maxigp0_wready,
  maxigp0_bid,
  maxigp0_bresp,
  maxigp0_bvalid,
  maxigp0_bready,
  maxigp0_arid,
  maxigp0_araddr,
  maxigp0_arlen,
  maxigp0_arsize,
  maxigp0_arburst,
  maxigp0_arlock,
  maxigp0_arcache,
  maxigp0_arprot,
  maxigp0_arvalid,
  maxigp0_aruser,
  maxigp0_arready,
  maxigp0_rid,
  maxigp0_rdata,
  maxigp0_rresp,
  maxigp0_rlast,
  maxigp0_rvalid,
  maxigp0_rready,
  maxigp0_awqos,
  maxigp0_arqos,
  maxihpm1_fpd_aclk,
  maxigp1_awid,
  maxigp1_awaddr,
  maxigp1_awlen,
  maxigp1_awsize,
  maxigp1_awburst,
  maxigp1_awlock,
  maxigp1_awcache,
  maxigp1_awprot,
  maxigp1_awvalid,
  maxigp1_awuser,
  maxigp1_awready,
  maxigp1_wdata,
  maxigp1_wstrb,
  maxigp1_wlast,
  maxigp1_wvalid,
  maxigp1_wready,
  maxigp1_bid,
  maxigp1_bresp,
  maxigp1_bvalid,
  maxigp1_bready,
  maxigp1_arid,
  maxigp1_araddr,
  maxigp1_arlen,
  maxigp1_arsize,
  maxigp1_arburst,
  maxigp1_arlock,
  maxigp1_arcache,
  maxigp1_arprot,
  maxigp1_arvalid,
  maxigp1_aruser,
  maxigp1_arready,
  maxigp1_rid,
  maxigp1_rdata,
  maxigp1_rresp,
  maxigp1_rlast,
  maxigp1_rvalid,
  maxigp1_rready,
  maxigp1_awqos,
  maxigp1_arqos,
  saxihpc0_fpd_aclk,
  saxigp0_aruser,
  saxigp0_awuser,
  saxigp0_awid,
  saxigp0_awaddr,
  saxigp0_awlen,
  saxigp0_awsize,
  saxigp0_awburst,
  saxigp0_awlock,
  saxigp0_awcache,
  saxigp0_awprot,
  saxigp0_awvalid,
  saxigp0_awready,
  saxigp0_wdata,
  saxigp0_wstrb,
  saxigp0_wlast,
  saxigp0_wvalid,
  saxigp0_wready,
  saxigp0_bid,
  saxigp0_bresp,
  saxigp0_bvalid,
  saxigp0_bready,
  saxigp0_arid,
  saxigp0_araddr,
  saxigp0_arlen,
  saxigp0_arsize,
  saxigp0_arburst,
  saxigp0_arlock,
  saxigp0_arcache,
  saxigp0_arprot,
  saxigp0_arvalid,
  saxigp0_arready,
  saxigp0_rid,
  saxigp0_rdata,
  saxigp0_rresp,
  saxigp0_rlast,
  saxigp0_rvalid,
  saxigp0_rready,
  saxigp0_awqos,
  saxigp0_arqos,
  pl_resetn0,
  pl_clk0
 );

//PARAMETERS

      parameter C_DP_USE_AUDIO = 0;
      parameter C_DP_USE_VIDEO = 0;
      parameter C_MAXIGP0_DATA_WIDTH = 32;
      parameter C_MAXIGP1_DATA_WIDTH = 32;
      parameter C_MAXIGP2_DATA_WIDTH = 32;
      parameter C_SAXIGP0_DATA_WIDTH = 64;
      parameter C_SAXIGP1_DATA_WIDTH = 128;
      parameter C_SAXIGP2_DATA_WIDTH = 128;
      parameter C_SAXIGP3_DATA_WIDTH = 128;
      parameter C_SAXIGP4_DATA_WIDTH = 128;
      parameter C_SAXIGP5_DATA_WIDTH = 128;
      parameter C_SAXIGP6_DATA_WIDTH = 128;
      parameter C_USE_DIFF_RW_CLK_GP0 = 0;
      parameter C_USE_DIFF_RW_CLK_GP1 = 0;
      parameter C_USE_DIFF_RW_CLK_GP2 = 0;
      parameter C_USE_DIFF_RW_CLK_GP3 = 0;
      parameter C_USE_DIFF_RW_CLK_GP4 = 0;
      parameter C_USE_DIFF_RW_CLK_GP5 = 0;
      parameter C_USE_DIFF_RW_CLK_GP6 = 0;
      parameter C_EN_FIFO_ENET0 = "0";
      parameter C_EN_FIFO_ENET1 = "0";
      parameter C_EN_FIFO_ENET2 = "0";
      parameter C_EN_FIFO_ENET3 = "0";
      parameter C_PL_CLK0_BUF = "TRUE";
      parameter C_PL_CLK1_BUF = "FALSE";
      parameter C_PL_CLK2_BUF = "FALSE";
      parameter C_PL_CLK3_BUF = "FALSE";
      parameter C_TRACE_PIPELINE_WIDTH = 8;
      parameter C_EN_EMIO_TRACE = 0;
      parameter C_TRACE_DATA_WIDTH = 32;
      parameter C_USE_DEBUG_TEST = 0;
      parameter C_SD0_INTERNAL_BUS_WIDTH = 8;
      parameter C_SD1_INTERNAL_BUS_WIDTH = 8;
      parameter C_NUM_F2P_0_INTR_INPUTS = 1;
      parameter C_NUM_F2P_1_INTR_INPUTS = 1;
      parameter C_EMIO_GPIO_WIDTH = 1;
      parameter C_NUM_FABRIC_RESETS = 1;

//INPUT AND OUTPUT PORTS

      input  maxihpm0_fpd_aclk;
      output  [15 : 0] maxigp0_awid;
      output  [39 : 0] maxigp0_awaddr;
      output  [7 : 0] maxigp0_awlen;
      output  [2 : 0] maxigp0_awsize;
      output  [1 : 0] maxigp0_awburst;
      output  maxigp0_awlock;
      output  [3 : 0] maxigp0_awcache;
      output  [2 : 0] maxigp0_awprot;
      output  maxigp0_awvalid;
      output  [15 : 0] maxigp0_awuser;
      input  maxigp0_awready;
      output  [31 : 0] maxigp0_wdata;
      output  [3 : 0] maxigp0_wstrb;
      output  maxigp0_wlast;
      output  maxigp0_wvalid;
      input  maxigp0_wready;
      input  [15 : 0] maxigp0_bid;
      input  [1 : 0] maxigp0_bresp;
      input  maxigp0_bvalid;
      output  maxigp0_bready;
      output  [15 : 0] maxigp0_arid;
      output  [39 : 0] maxigp0_araddr;
      output  [7 : 0] maxigp0_arlen;
      output  [2 : 0] maxigp0_arsize;
      output  [1 : 0] maxigp0_arburst;
      output  maxigp0_arlock;
      output  [3 : 0] maxigp0_arcache;
      output  [2 : 0] maxigp0_arprot;
      output  maxigp0_arvalid;
      output  [15 : 0] maxigp0_aruser;
      input  maxigp0_arready;
      input  [15 : 0] maxigp0_rid;
      input  [31 : 0] maxigp0_rdata;
      input  [1 : 0] maxigp0_rresp;
      input  maxigp0_rlast;
      input  maxigp0_rvalid;
      output  maxigp0_rready;
      output  [3 : 0] maxigp0_awqos;
      output  [3 : 0] maxigp0_arqos;
      input  maxihpm1_fpd_aclk;
      output  [15 : 0] maxigp1_awid;
      output  [39 : 0] maxigp1_awaddr;
      output  [7 : 0] maxigp1_awlen;
      output  [2 : 0] maxigp1_awsize;
      output  [1 : 0] maxigp1_awburst;
      output  maxigp1_awlock;
      output  [3 : 0] maxigp1_awcache;
      output  [2 : 0] maxigp1_awprot;
      output  maxigp1_awvalid;
      output  [15 : 0] maxigp1_awuser;
      input  maxigp1_awready;
      output  [31 : 0] maxigp1_wdata;
      output  [3 : 0] maxigp1_wstrb;
      output  maxigp1_wlast;
      output  maxigp1_wvalid;
      input  maxigp1_wready;
      input  [15 : 0] maxigp1_bid;
      input  [1 : 0] maxigp1_bresp;
      input  maxigp1_bvalid;
      output  maxigp1_bready;
      output  [15 : 0] maxigp1_arid;
      output  [39 : 0] maxigp1_araddr;
      output  [7 : 0] maxigp1_arlen;
      output  [2 : 0] maxigp1_arsize;
      output  [1 : 0] maxigp1_arburst;
      output  maxigp1_arlock;
      output  [3 : 0] maxigp1_arcache;
      output  [2 : 0] maxigp1_arprot;
      output  maxigp1_arvalid;
      output  [15 : 0] maxigp1_aruser;
      input  maxigp1_arready;
      input  [15 : 0] maxigp1_rid;
      input  [31 : 0] maxigp1_rdata;
      input  [1 : 0] maxigp1_rresp;
      input  maxigp1_rlast;
      input  maxigp1_rvalid;
      output  maxigp1_rready;
      output  [3 : 0] maxigp1_awqos;
      output  [3 : 0] maxigp1_arqos;
      input  saxihpc0_fpd_aclk;
      input  saxigp0_aruser;
      input  saxigp0_awuser;
      input  [5 : 0] saxigp0_awid;
      input  [48 : 0] saxigp0_awaddr;
      input  [7 : 0] saxigp0_awlen;
      input  [2 : 0] saxigp0_awsize;
      input  [1 : 0] saxigp0_awburst;
      input  saxigp0_awlock;
      input  [3 : 0] saxigp0_awcache;
      input  [2 : 0] saxigp0_awprot;
      input  saxigp0_awvalid;
      output  saxigp0_awready;
      input  [63 : 0] saxigp0_wdata;
      input  [7 : 0] saxigp0_wstrb;
      input  saxigp0_wlast;
      input  saxigp0_wvalid;
      output  saxigp0_wready;
      output  [5 : 0] saxigp0_bid;
      output  [1 : 0] saxigp0_bresp;
      output  saxigp0_bvalid;
      input  saxigp0_bready;
      input  [5 : 0] saxigp0_arid;
      input  [48 : 0] saxigp0_araddr;
      input  [7 : 0] saxigp0_arlen;
      input  [2 : 0] saxigp0_arsize;
      input  [1 : 0] saxigp0_arburst;
      input  saxigp0_arlock;
      input  [3 : 0] saxigp0_arcache;
      input  [2 : 0] saxigp0_arprot;
      input  saxigp0_arvalid;
      output  saxigp0_arready;
      output  [5 : 0] saxigp0_rid;
      output  [63 : 0] saxigp0_rdata;
      output  [1 : 0] saxigp0_rresp;
      output  saxigp0_rlast;
      output  saxigp0_rvalid;
      input  saxigp0_rready;
      input  [3 : 0] saxigp0_awqos;
      input  [3 : 0] saxigp0_arqos;
      output  pl_resetn0;
      output  pl_clk0;

//REG DECLARATIONS

      reg [15 : 0] maxigp0_awid;
      reg [39 : 0] maxigp0_awaddr;
      reg [7 : 0] maxigp0_awlen;
      reg [2 : 0] maxigp0_awsize;
      reg [1 : 0] maxigp0_awburst;
      reg maxigp0_awlock;
      reg [3 : 0] maxigp0_awcache;
      reg [2 : 0] maxigp0_awprot;
      reg maxigp0_awvalid;
      reg [15 : 0] maxigp0_awuser;
      reg [31 : 0] maxigp0_wdata;
      reg [3 : 0] maxigp0_wstrb;
      reg maxigp0_wlast;
      reg maxigp0_wvalid;
      reg maxigp0_bready;
      reg [15 : 0] maxigp0_arid;
      reg [39 : 0] maxigp0_araddr;
      reg [7 : 0] maxigp0_arlen;
      reg [2 : 0] maxigp0_arsize;
      reg [1 : 0] maxigp0_arburst;
      reg maxigp0_arlock;
      reg [3 : 0] maxigp0_arcache;
      reg [2 : 0] maxigp0_arprot;
      reg maxigp0_arvalid;
      reg [15 : 0] maxigp0_aruser;
      reg maxigp0_rready;
      reg [3 : 0] maxigp0_awqos;
      reg [3 : 0] maxigp0_arqos;
      reg [15 : 0] maxigp1_awid;
      reg [39 : 0] maxigp1_awaddr;
      reg [7 : 0] maxigp1_awlen;
      reg [2 : 0] maxigp1_awsize;
      reg [1 : 0] maxigp1_awburst;
      reg maxigp1_awlock;
      reg [3 : 0] maxigp1_awcache;
      reg [2 : 0] maxigp1_awprot;
      reg maxigp1_awvalid;
      reg [15 : 0] maxigp1_awuser;
      reg [31 : 0] maxigp1_wdata;
      reg [3 : 0] maxigp1_wstrb;
      reg maxigp1_wlast;
      reg maxigp1_wvalid;
      reg maxigp1_bready;
      reg [15 : 0] maxigp1_arid;
      reg [39 : 0] maxigp1_araddr;
      reg [7 : 0] maxigp1_arlen;
      reg [2 : 0] maxigp1_arsize;
      reg [1 : 0] maxigp1_arburst;
      reg maxigp1_arlock;
      reg [3 : 0] maxigp1_arcache;
      reg [2 : 0] maxigp1_arprot;
      reg maxigp1_arvalid;
      reg [15 : 0] maxigp1_aruser;
      reg maxigp1_rready;
      reg [3 : 0] maxigp1_awqos;
      reg [3 : 0] maxigp1_arqos;
      reg saxigp0_awready;
      reg saxigp0_wready;
      reg [5 : 0] saxigp0_bid;
      reg [1 : 0] saxigp0_bresp;
      reg saxigp0_bvalid;
      reg saxigp0_arready;
      reg [5 : 0] saxigp0_rid;
      reg [63 : 0] saxigp0_rdata;
      reg [1 : 0] saxigp0_rresp;
      reg saxigp0_rlast;
      reg saxigp0_rvalid;
      reg pl_resetn0;
      reg pl_clk0;
      string ip_name;
      reg disable_port;

//DPI DECLARATIONS
import "DPI-C" function void ps8_set_ip_context(input string ip_name);
import "DPI-C" function void ps8_set_str_param(input string name,input string val);
import "DPI-C" function void ps8_set_int_param(input string name,input longint val);
import "DPI-C" function void ps8_init_c_model();
 import "DPI-C" function void ps8_set_input_pl_pmu_gpi(input int pinIndex, input int pinVlaue);
 always@(posedge pl_pmu_gpi[0])
 begin
  ps8_set_input_pl_pmu_gpi(0,1);
end

 always@(negedge pl_pmu_gpi[0])
 begin
  ps8_set_input_pl_pmu_gpi(0,0);
end

 always@(posedge pl_pmu_gpi[1])
 begin
  ps8_set_input_pl_pmu_gpi(1,1);
end

 always@(negedge pl_pmu_gpi[1])
 begin
  ps8_set_input_pl_pmu_gpi(1,0);
end

 always@(posedge pl_pmu_gpi[2])
 begin
  ps8_set_input_pl_pmu_gpi(2,1);
end

 always@(negedge pl_pmu_gpi[2])
 begin
  ps8_set_input_pl_pmu_gpi(2,0);
end

 always@(posedge pl_pmu_gpi[3])
 begin
  ps8_set_input_pl_pmu_gpi(3,1);
end

 always@(negedge pl_pmu_gpi[3])
 begin
  ps8_set_input_pl_pmu_gpi(3,0);
end

 always@(posedge pl_pmu_gpi[4])
 begin
  ps8_set_input_pl_pmu_gpi(4,1);
end

 always@(negedge pl_pmu_gpi[4])
 begin
  ps8_set_input_pl_pmu_gpi(4,0);
end

 always@(posedge pl_pmu_gpi[5])
 begin
  ps8_set_input_pl_pmu_gpi(5,1);
end

 always@(negedge pl_pmu_gpi[5])
 begin
  ps8_set_input_pl_pmu_gpi(5,0);
end

 always@(posedge pl_pmu_gpi[6])
 begin
  ps8_set_input_pl_pmu_gpi(6,1);
end

 always@(negedge pl_pmu_gpi[6])
 begin
  ps8_set_input_pl_pmu_gpi(6,0);
end

 always@(posedge pl_pmu_gpi[7])
 begin
  ps8_set_input_pl_pmu_gpi(7,1);
end

 always@(negedge pl_pmu_gpi[7])
 begin
  ps8_set_input_pl_pmu_gpi(7,0);
end

 always@(posedge pl_pmu_gpi[8])
 begin
  ps8_set_input_pl_pmu_gpi(8,1);
end

 always@(negedge pl_pmu_gpi[8])
 begin
  ps8_set_input_pl_pmu_gpi(8,0);
end

 always@(posedge pl_pmu_gpi[9])
 begin
  ps8_set_input_pl_pmu_gpi(9,1);
end

 always@(negedge pl_pmu_gpi[9])
 begin
  ps8_set_input_pl_pmu_gpi(9,0);
end

 always@(posedge pl_pmu_gpi[10])
 begin
  ps8_set_input_pl_pmu_gpi(10,1);
end

 always@(negedge pl_pmu_gpi[10])
 begin
  ps8_set_input_pl_pmu_gpi(10,0);
end

 always@(posedge pl_pmu_gpi[11])
 begin
  ps8_set_input_pl_pmu_gpi(11,1);
end

 always@(negedge pl_pmu_gpi[11])
 begin
  ps8_set_input_pl_pmu_gpi(11,0);
end

 always@(posedge pl_pmu_gpi[12])
 begin
  ps8_set_input_pl_pmu_gpi(12,1);
end

 always@(negedge pl_pmu_gpi[12])
 begin
  ps8_set_input_pl_pmu_gpi(12,0);
end

 always@(posedge pl_pmu_gpi[13])
 begin
  ps8_set_input_pl_pmu_gpi(13,1);
end

 always@(negedge pl_pmu_gpi[13])
 begin
  ps8_set_input_pl_pmu_gpi(13,0);
end

 always@(posedge pl_pmu_gpi[14])
 begin
  ps8_set_input_pl_pmu_gpi(14,1);
end

 always@(negedge pl_pmu_gpi[14])
 begin
  ps8_set_input_pl_pmu_gpi(14,0);
end

 always@(posedge pl_pmu_gpi[15])
 begin
  ps8_set_input_pl_pmu_gpi(15,1);
end

 always@(negedge pl_pmu_gpi[15])
 begin
  ps8_set_input_pl_pmu_gpi(15,0);
end

 always@(posedge pl_pmu_gpi[16])
 begin
  ps8_set_input_pl_pmu_gpi(16,1);
end

 always@(negedge pl_pmu_gpi[16])
 begin
  ps8_set_input_pl_pmu_gpi(16,0);
end

 always@(posedge pl_pmu_gpi[17])
 begin
  ps8_set_input_pl_pmu_gpi(17,1);
end

 always@(negedge pl_pmu_gpi[17])
 begin
  ps8_set_input_pl_pmu_gpi(17,0);
end

 always@(posedge pl_pmu_gpi[18])
 begin
  ps8_set_input_pl_pmu_gpi(18,1);
end

 always@(negedge pl_pmu_gpi[18])
 begin
  ps8_set_input_pl_pmu_gpi(18,0);
end

 always@(posedge pl_pmu_gpi[19])
 begin
  ps8_set_input_pl_pmu_gpi(19,1);
end

 always@(negedge pl_pmu_gpi[19])
 begin
  ps8_set_input_pl_pmu_gpi(19,0);
end

 always@(posedge pl_pmu_gpi[20])
 begin
  ps8_set_input_pl_pmu_gpi(20,1);
end

 always@(negedge pl_pmu_gpi[20])
 begin
  ps8_set_input_pl_pmu_gpi(20,0);
end

 always@(posedge pl_pmu_gpi[21])
 begin
  ps8_set_input_pl_pmu_gpi(21,1);
end

 always@(negedge pl_pmu_gpi[21])
 begin
  ps8_set_input_pl_pmu_gpi(21,0);
end

 always@(posedge pl_pmu_gpi[22])
 begin
  ps8_set_input_pl_pmu_gpi(22,1);
end

 always@(negedge pl_pmu_gpi[22])
 begin
  ps8_set_input_pl_pmu_gpi(22,0);
end

 always@(posedge pl_pmu_gpi[23])
 begin
  ps8_set_input_pl_pmu_gpi(23,1);
end

 always@(negedge pl_pmu_gpi[23])
 begin
  ps8_set_input_pl_pmu_gpi(23,0);
end

 always@(posedge pl_pmu_gpi[24])
 begin
  ps8_set_input_pl_pmu_gpi(24,1);
end

 always@(negedge pl_pmu_gpi[24])
 begin
  ps8_set_input_pl_pmu_gpi(24,0);
end

 always@(posedge pl_pmu_gpi[25])
 begin
  ps8_set_input_pl_pmu_gpi(25,1);
end

 always@(negedge pl_pmu_gpi[25])
 begin
  ps8_set_input_pl_pmu_gpi(25,0);
end

 always@(posedge pl_pmu_gpi[26])
 begin
  ps8_set_input_pl_pmu_gpi(26,1);
end

 always@(negedge pl_pmu_gpi[26])
 begin
  ps8_set_input_pl_pmu_gpi(26,0);
end

 always@(posedge pl_pmu_gpi[27])
 begin
  ps8_set_input_pl_pmu_gpi(27,1);
end

 always@(negedge pl_pmu_gpi[27])
 begin
  ps8_set_input_pl_pmu_gpi(27,0);
end

 always@(posedge pl_pmu_gpi[28])
 begin
  ps8_set_input_pl_pmu_gpi(28,1);
end

 always@(negedge pl_pmu_gpi[28])
 begin
  ps8_set_input_pl_pmu_gpi(28,0);
end

 always@(posedge pl_pmu_gpi[29])
 begin
  ps8_set_input_pl_pmu_gpi(29,1);
end

 always@(negedge pl_pmu_gpi[29])
 begin
  ps8_set_input_pl_pmu_gpi(29,0);
end

 always@(posedge pl_pmu_gpi[30])
 begin
  ps8_set_input_pl_pmu_gpi(30,1);
end

 always@(negedge pl_pmu_gpi[30])
 begin
  ps8_set_input_pl_pmu_gpi(30,0);
end

 always@(posedge pl_pmu_gpi[31])
 begin
  ps8_set_input_pl_pmu_gpi(31,1);
end

 always@(negedge pl_pmu_gpi[31])
 begin
  ps8_set_input_pl_pmu_gpi(31,0);
end

import "DPI-C" function void ps8_init_m_axi_hpm0_fpd(input int maxigp0_awid_size,input int maxigp0_awaddr_size,input int maxigp0_awlen_size,input int maxigp0_awsize_size,input int maxigp0_awburst_size,input int maxigp0_awlock_size,input int maxigp0_awcache_size,input int maxigp0_awprot_size,input int maxigp0_awqos_size,input int maxigp0_awuser_size,input int maxigp0_awvalid_size,input int maxigp0_awready_size,input int maxigp0_wdata_size,input int maxigp0_wstrb_size,input int maxigp0_wlast_size,input int maxigp0_wvalid_size,input int maxigp0_wready_size,input int maxigp0_bid_size,input int maxigp0_bresp_size,input int maxigp0_bvalid_size,input int maxigp0_bready_size,input int maxigp0_arid_size,input int maxigp0_araddr_size,input int maxigp0_arlen_size,input int maxigp0_arsize_size,input int maxigp0_arburst_size,input int maxigp0_arlock_size,input int maxigp0_arcache_size,input int maxigp0_arprot_size,input int maxigp0_arqos_size,input int maxigp0_aruser_size,input int maxigp0_arvalid_size,input int maxigp0_arready_size,input int maxigp0_rid_size,input int maxigp0_rdata_size,input int maxigp0_rresp_size,input int maxigp0_rlast_size,input int maxigp0_rvalid_size,input int maxigp0_rready_size);
import "DPI-C" function void ps8_init_m_axi_hpm1_fpd(input int maxigp1_awid_size,input int maxigp1_awaddr_size,input int maxigp1_awlen_size,input int maxigp1_awsize_size,input int maxigp1_awburst_size,input int maxigp1_awlock_size,input int maxigp1_awcache_size,input int maxigp1_awprot_size,input int maxigp1_awqos_size,input int maxigp1_awuser_size,input int maxigp1_awvalid_size,input int maxigp1_awready_size,input int maxigp1_wdata_size,input int maxigp1_wstrb_size,input int maxigp1_wlast_size,input int maxigp1_wvalid_size,input int maxigp1_wready_size,input int maxigp1_bid_size,input int maxigp1_bresp_size,input int maxigp1_bvalid_size,input int maxigp1_bready_size,input int maxigp1_arid_size,input int maxigp1_araddr_size,input int maxigp1_arlen_size,input int maxigp1_arsize_size,input int maxigp1_arburst_size,input int maxigp1_arlock_size,input int maxigp1_arcache_size,input int maxigp1_arprot_size,input int maxigp1_arqos_size,input int maxigp1_aruser_size,input int maxigp1_arvalid_size,input int maxigp1_arready_size,input int maxigp1_rid_size,input int maxigp1_rdata_size,input int maxigp1_rresp_size,input int maxigp1_rlast_size,input int maxigp1_rvalid_size,input int maxigp1_rready_size);
import "DPI-C" function void ps8_init_s_axi_hpc0_fpd(input int saxigp0_awid_size,input int saxigp0_awaddr_size,input int saxigp0_awlen_size,input int saxigp0_awsize_size,input int saxigp0_awburst_size,input int saxigp0_awlock_size,input int saxigp0_awcache_size,input int saxigp0_awprot_size,input int saxigp0_awqos_size,input int saxigp0_awuser_size,input int saxigp0_awvalid_size,input int saxigp0_awready_size,input int saxigp0_wdata_size,input int saxigp0_wstrb_size,input int saxigp0_wlast_size,input int saxigp0_wvalid_size,input int saxigp0_wready_size,input int saxigp0_bid_size,input int saxigp0_bresp_size,input int saxigp0_bvalid_size,input int saxigp0_bready_size,input int saxigp0_arid_size,input int saxigp0_araddr_size,input int saxigp0_arlen_size,input int saxigp0_arsize_size,input int saxigp0_arburst_size,input int saxigp0_arlock_size,input int saxigp0_arcache_size,input int saxigp0_arprot_size,input int saxigp0_arqos_size,input int saxigp0_aruser_size,input int saxigp0_arvalid_size,input int saxigp0_arready_size,input int saxigp0_rid_size,input int saxigp0_rdata_size,input int saxigp0_rresp_size,input int saxigp0_rlast_size,input int saxigp0_rvalid_size,input int saxigp0_rready_size);
import "DPI-C" function void ps8_simulate_single_cycle_maxihpm0_fpd_aclk();
import "DPI-C" function void ps8_set_inputs_m_axi_hpm0_fpd_maxihpm0_fpd_aclk(
input bit maxigp0_awready,
input bit maxigp0_wready,
input bit [15 : 0] maxigp0_bid,
input bit [1 : 0] maxigp0_bresp,
input bit maxigp0_bvalid,
input bit maxigp0_arready,
input bit [15 : 0] maxigp0_rid,
input bit [31 : 0] maxigp0_rdata,
input bit [1 : 0] maxigp0_rresp,
input bit maxigp0_rlast,
input bit maxigp0_rvalid
);
import "DPI-C" function void ps8_get_outputs_m_axi_hpm0_fpd_maxihpm0_fpd_aclk(
output bit [15 : 0] maxigp0_awid,
output bit [39 : 0] maxigp0_awaddr,
output bit [7 : 0] maxigp0_awlen,
output bit [2 : 0] maxigp0_awsize,
output bit [1 : 0] maxigp0_awburst,
output bit maxigp0_awlock,
output bit [3 : 0] maxigp0_awcache,
output bit [2 : 0] maxigp0_awprot,
output bit [3 : 0] maxigp0_awqos,
output bit [15 : 0] maxigp0_awuser,
output bit maxigp0_awvalid,
output bit [31 : 0] maxigp0_wdata,
output bit [3 : 0] maxigp0_wstrb,
output bit maxigp0_wlast,
output bit maxigp0_wvalid,
output bit maxigp0_bready,
output bit [15 : 0] maxigp0_arid,
output bit [39 : 0] maxigp0_araddr,
output bit [7 : 0] maxigp0_arlen,
output bit [2 : 0] maxigp0_arsize,
output bit [1 : 0] maxigp0_arburst,
output bit maxigp0_arlock,
output bit [3 : 0] maxigp0_arcache,
output bit [2 : 0] maxigp0_arprot,
output bit [3 : 0] maxigp0_arqos,
output bit [15 : 0] maxigp0_aruser,
output bit maxigp0_arvalid,
output bit maxigp0_rready
);

import "DPI-C" function void ps8_simulate_single_cycle_maxihpm1_fpd_aclk();
import "DPI-C" function void ps8_set_inputs_m_axi_hpm1_fpd_maxihpm1_fpd_aclk(
input bit maxigp1_awready,
input bit maxigp1_wready,
input bit [15 : 0] maxigp1_bid,
input bit [1 : 0] maxigp1_bresp,
input bit maxigp1_bvalid,
input bit maxigp1_arready,
input bit [15 : 0] maxigp1_rid,
input bit [31 : 0] maxigp1_rdata,
input bit [1 : 0] maxigp1_rresp,
input bit maxigp1_rlast,
input bit maxigp1_rvalid
);
import "DPI-C" function void ps8_get_outputs_m_axi_hpm1_fpd_maxihpm1_fpd_aclk(
output bit [15 : 0] maxigp1_awid,
output bit [39 : 0] maxigp1_awaddr,
output bit [7 : 0] maxigp1_awlen,
output bit [2 : 0] maxigp1_awsize,
output bit [1 : 0] maxigp1_awburst,
output bit maxigp1_awlock,
output bit [3 : 0] maxigp1_awcache,
output bit [2 : 0] maxigp1_awprot,
output bit [3 : 0] maxigp1_awqos,
output bit [15 : 0] maxigp1_awuser,
output bit maxigp1_awvalid,
output bit [31 : 0] maxigp1_wdata,
output bit [3 : 0] maxigp1_wstrb,
output bit maxigp1_wlast,
output bit maxigp1_wvalid,
output bit maxigp1_bready,
output bit [15 : 0] maxigp1_arid,
output bit [39 : 0] maxigp1_araddr,
output bit [7 : 0] maxigp1_arlen,
output bit [2 : 0] maxigp1_arsize,
output bit [1 : 0] maxigp1_arburst,
output bit maxigp1_arlock,
output bit [3 : 0] maxigp1_arcache,
output bit [2 : 0] maxigp1_arprot,
output bit [3 : 0] maxigp1_arqos,
output bit [15 : 0] maxigp1_aruser,
output bit maxigp1_arvalid,
output bit maxigp1_rready
);

import "DPI-C" function void ps8_simulate_single_cycle_saxihpc0_fpd_aclk();
import "DPI-C" function void ps8_set_inputs_s_axi_hpc0_fpd_saxihpc0_fpd_aclk(
input bit [5 : 0] saxigp0_awid,
input bit [48 : 0] saxigp0_awaddr,
input bit [7 : 0] saxigp0_awlen,
input bit [2 : 0] saxigp0_awsize,
input bit [1 : 0] saxigp0_awburst,
input bit saxigp0_awlock,
input bit [3 : 0] saxigp0_awcache,
input bit [2 : 0] saxigp0_awprot,
input bit [3 : 0] saxigp0_awqos,
input bit saxigp0_awuser,
input bit saxigp0_awvalid,
input bit [63 : 0] saxigp0_wdata,
input bit [7 : 0] saxigp0_wstrb,
input bit saxigp0_wlast,
input bit saxigp0_wvalid,
input bit saxigp0_bready,
input bit [5 : 0] saxigp0_arid,
input bit [48 : 0] saxigp0_araddr,
input bit [7 : 0] saxigp0_arlen,
input bit [2 : 0] saxigp0_arsize,
input bit [1 : 0] saxigp0_arburst,
input bit saxigp0_arlock,
input bit [3 : 0] saxigp0_arcache,
input bit [2 : 0] saxigp0_arprot,
input bit [3 : 0] saxigp0_arqos,
input bit saxigp0_aruser,
input bit saxigp0_arvalid,
input bit saxigp0_rready
);
import "DPI-C" function void ps8_get_outputs_s_axi_hpc0_fpd_saxihpc0_fpd_aclk(
output bit saxigp0_awready,
output bit saxigp0_wready,
output bit [5 : 0] saxigp0_bid,
output bit [1 : 0] saxigp0_bresp,
output bit saxigp0_bvalid,
output bit saxigp0_arready,
output bit [5 : 0] saxigp0_rid,
output bit [63 : 0] saxigp0_rdata,
output bit [1 : 0] saxigp0_rresp,
output bit saxigp0_rlast,
output bit saxigp0_rvalid
);

import "DPI-C" function void ps8_simulate_single_cycle_pl_clk0();
   export "DPI-C" function ps8_stop_sim;
   function void ps8_stop_sim();
        $display("End of simulation");
        $finish(0);
   endfunction
   export "DPI-C" function ps8_get_time;
   function real ps8_get_time();
       ps8_get_time = $time;
   endfunction

   export "DPI-C" function ps8_set_output_pins_pl_resetn0;
   function void ps8_set_output_pins_pl_resetn0(int value);
       pl_resetn0 = 1'b1; 
   endfunction


//INITIAL BLOCK

   initial
   begin
  $sformat(ip_name,"%m");
      ps8_set_ip_context(ip_name);
      ps8_set_int_param ( "C_DP_USE_AUDIO",C_DP_USE_AUDIO );
      ps8_set_int_param ( "C_DP_USE_VIDEO",C_DP_USE_VIDEO );
      ps8_set_int_param ( "C_MAXIGP0_DATA_WIDTH",C_MAXIGP0_DATA_WIDTH );
      ps8_set_int_param ( "C_MAXIGP1_DATA_WIDTH",C_MAXIGP1_DATA_WIDTH );
      ps8_set_int_param ( "C_MAXIGP2_DATA_WIDTH",C_MAXIGP2_DATA_WIDTH );
      ps8_set_int_param ( "C_SAXIGP0_DATA_WIDTH",C_SAXIGP0_DATA_WIDTH );
      ps8_set_int_param ( "C_SAXIGP1_DATA_WIDTH",C_SAXIGP1_DATA_WIDTH );
      ps8_set_int_param ( "C_SAXIGP2_DATA_WIDTH",C_SAXIGP2_DATA_WIDTH );
      ps8_set_int_param ( "C_SAXIGP3_DATA_WIDTH",C_SAXIGP3_DATA_WIDTH );
      ps8_set_int_param ( "C_SAXIGP4_DATA_WIDTH",C_SAXIGP4_DATA_WIDTH );
      ps8_set_int_param ( "C_SAXIGP5_DATA_WIDTH",C_SAXIGP5_DATA_WIDTH );
      ps8_set_int_param ( "C_SAXIGP6_DATA_WIDTH",C_SAXIGP6_DATA_WIDTH );
      ps8_set_int_param ( "C_USE_DIFF_RW_CLK_GP0",C_USE_DIFF_RW_CLK_GP0 );
      ps8_set_int_param ( "C_USE_DIFF_RW_CLK_GP1",C_USE_DIFF_RW_CLK_GP1 );
      ps8_set_int_param ( "C_USE_DIFF_RW_CLK_GP2",C_USE_DIFF_RW_CLK_GP2 );
      ps8_set_int_param ( "C_USE_DIFF_RW_CLK_GP3",C_USE_DIFF_RW_CLK_GP3 );
      ps8_set_int_param ( "C_USE_DIFF_RW_CLK_GP4",C_USE_DIFF_RW_CLK_GP4 );
      ps8_set_int_param ( "C_USE_DIFF_RW_CLK_GP5",C_USE_DIFF_RW_CLK_GP5 );
      ps8_set_int_param ( "C_USE_DIFF_RW_CLK_GP6",C_USE_DIFF_RW_CLK_GP6 );
      ps8_set_str_param ( "C_EN_FIFO_ENET0",C_EN_FIFO_ENET0 );
      ps8_set_str_param ( "C_EN_FIFO_ENET1",C_EN_FIFO_ENET1 );
      ps8_set_str_param ( "C_EN_FIFO_ENET2",C_EN_FIFO_ENET2 );
      ps8_set_str_param ( "C_EN_FIFO_ENET3",C_EN_FIFO_ENET3 );
      ps8_set_str_param ( "C_PL_CLK0_BUF",C_PL_CLK0_BUF );
      ps8_set_str_param ( "C_PL_CLK1_BUF",C_PL_CLK1_BUF );
      ps8_set_str_param ( "C_PL_CLK2_BUF",C_PL_CLK2_BUF );
      ps8_set_str_param ( "C_PL_CLK3_BUF",C_PL_CLK3_BUF );
      ps8_set_int_param ( "C_TRACE_PIPELINE_WIDTH",C_TRACE_PIPELINE_WIDTH );
      ps8_set_int_param ( "C_EN_EMIO_TRACE",C_EN_EMIO_TRACE );
      ps8_set_int_param ( "C_TRACE_DATA_WIDTH",C_TRACE_DATA_WIDTH );
      ps8_set_int_param ( "C_USE_DEBUG_TEST",C_USE_DEBUG_TEST );
      ps8_set_int_param ( "C_SD0_INTERNAL_BUS_WIDTH",C_SD0_INTERNAL_BUS_WIDTH );
      ps8_set_int_param ( "C_SD1_INTERNAL_BUS_WIDTH",C_SD1_INTERNAL_BUS_WIDTH );
      ps8_set_int_param ( "C_NUM_F2P_0_INTR_INPUTS",C_NUM_F2P_0_INTR_INPUTS );
      ps8_set_int_param ( "C_NUM_F2P_1_INTR_INPUTS",C_NUM_F2P_1_INTR_INPUTS );
      ps8_set_int_param ( "C_EMIO_GPIO_WIDTH",C_EMIO_GPIO_WIDTH );
      ps8_set_int_param ( "C_NUM_FABRIC_RESETS",C_NUM_FABRIC_RESETS );

  ps8_init_m_axi_hpm0_fpd($bits(maxigp0_awid),$bits(maxigp0_awaddr),$bits(maxigp0_awlen),$bits(maxigp0_awsize),$bits(maxigp0_awburst),$bits(maxigp0_awlock),$bits(maxigp0_awcache),$bits(maxigp0_awprot),$bits(maxigp0_awqos),$bits(maxigp0_awuser),$bits(maxigp0_awvalid),$bits(maxigp0_awready),$bits(maxigp0_wdata),$bits(maxigp0_wstrb),$bits(maxigp0_wlast),$bits(maxigp0_wvalid),$bits(maxigp0_wready),$bits(maxigp0_bid),$bits(maxigp0_bresp),$bits(maxigp0_bvalid),$bits(maxigp0_bready),$bits(maxigp0_arid),$bits(maxigp0_araddr),$bits(maxigp0_arlen),$bits(maxigp0_arsize),$bits(maxigp0_arburst),$bits(maxigp0_arlock),$bits(maxigp0_arcache),$bits(maxigp0_arprot),$bits(maxigp0_arqos),$bits(maxigp0_aruser),$bits(maxigp0_arvalid),$bits(maxigp0_arready),$bits(maxigp0_rid),$bits(maxigp0_rdata),$bits(maxigp0_rresp),$bits(maxigp0_rlast),$bits(maxigp0_rvalid),$bits(maxigp0_rready));

  ps8_init_m_axi_hpm1_fpd($bits(maxigp1_awid),$bits(maxigp1_awaddr),$bits(maxigp1_awlen),$bits(maxigp1_awsize),$bits(maxigp1_awburst),$bits(maxigp1_awlock),$bits(maxigp1_awcache),$bits(maxigp1_awprot),$bits(maxigp1_awqos),$bits(maxigp1_awuser),$bits(maxigp1_awvalid),$bits(maxigp1_awready),$bits(maxigp1_wdata),$bits(maxigp1_wstrb),$bits(maxigp1_wlast),$bits(maxigp1_wvalid),$bits(maxigp1_wready),$bits(maxigp1_bid),$bits(maxigp1_bresp),$bits(maxigp1_bvalid),$bits(maxigp1_bready),$bits(maxigp1_arid),$bits(maxigp1_araddr),$bits(maxigp1_arlen),$bits(maxigp1_arsize),$bits(maxigp1_arburst),$bits(maxigp1_arlock),$bits(maxigp1_arcache),$bits(maxigp1_arprot),$bits(maxigp1_arqos),$bits(maxigp1_aruser),$bits(maxigp1_arvalid),$bits(maxigp1_arready),$bits(maxigp1_rid),$bits(maxigp1_rdata),$bits(maxigp1_rresp),$bits(maxigp1_rlast),$bits(maxigp1_rvalid),$bits(maxigp1_rready));

  ps8_init_s_axi_hpc0_fpd($bits(saxigp0_awid),$bits(saxigp0_awaddr),$bits(saxigp0_awlen),$bits(saxigp0_awsize),$bits(saxigp0_awburst),$bits(saxigp0_awlock),$bits(saxigp0_awcache),$bits(saxigp0_awprot),$bits(saxigp0_awqos),$bits(saxigp0_awuser),$bits(saxigp0_awvalid),$bits(saxigp0_awready),$bits(saxigp0_wdata),$bits(saxigp0_wstrb),$bits(saxigp0_wlast),$bits(saxigp0_wvalid),$bits(saxigp0_wready),$bits(saxigp0_bid),$bits(saxigp0_bresp),$bits(saxigp0_bvalid),$bits(saxigp0_bready),$bits(saxigp0_arid),$bits(saxigp0_araddr),$bits(saxigp0_arlen),$bits(saxigp0_arsize),$bits(saxigp0_arburst),$bits(saxigp0_arlock),$bits(saxigp0_arcache),$bits(saxigp0_arprot),$bits(saxigp0_arqos),$bits(saxigp0_aruser),$bits(saxigp0_arvalid),$bits(saxigp0_arready),$bits(saxigp0_rid),$bits(saxigp0_rdata),$bits(saxigp0_rresp),$bits(saxigp0_rlast),$bits(saxigp0_rvalid),$bits(saxigp0_rready));
  ps8_init_c_model();
  pl_clk0=0;
  end
  initial
  begin
     pl_clk0 = 1'b0;
  end

  always #(6.666666666666667) pl_clk0 <= ~pl_clk0;

  always@(posedge pl_clk0)
  begin
   ps8_set_ip_context(ip_name);
   ps8_simulate_single_cycle_pl_clk0();
  end


always@(posedge maxihpm0_fpd_aclk)
  begin

   ps8_set_ip_context(ip_name);

   ps8_set_inputs_m_axi_hpm0_fpd_maxihpm0_fpd_aclk(
    maxigp0_awready,
    maxigp0_wready,
    maxigp0_bid,
    maxigp0_bresp,
    maxigp0_bvalid,
    maxigp0_arready,
    maxigp0_rid,
    maxigp0_rdata,
    maxigp0_rresp,
    maxigp0_rlast,
    maxigp0_rvalid
  );

   ps8_simulate_single_cycle_maxihpm0_fpd_aclk();

   ps8_get_outputs_m_axi_hpm0_fpd_maxihpm0_fpd_aclk(
    maxigp0_awid,
    maxigp0_awaddr,
    maxigp0_awlen,
    maxigp0_awsize,
    maxigp0_awburst,
    maxigp0_awlock,
    maxigp0_awcache,
    maxigp0_awprot,
    maxigp0_awqos,
    maxigp0_awuser,
    maxigp0_awvalid,
    maxigp0_wdata,
    maxigp0_wstrb,
    maxigp0_wlast,
    maxigp0_wvalid,
    maxigp0_bready,
    maxigp0_arid,
    maxigp0_araddr,
    maxigp0_arlen,
    maxigp0_arsize,
    maxigp0_arburst,
    maxigp0_arlock,
    maxigp0_arcache,
    maxigp0_arprot,
    maxigp0_arqos,
    maxigp0_aruser,
    maxigp0_arvalid,
    maxigp0_rready
  );
   end


always@(posedge maxihpm1_fpd_aclk)
  begin

   ps8_set_ip_context(ip_name);

   ps8_set_inputs_m_axi_hpm1_fpd_maxihpm1_fpd_aclk(
    maxigp1_awready,
    maxigp1_wready,
    maxigp1_bid,
    maxigp1_bresp,
    maxigp1_bvalid,
    maxigp1_arready,
    maxigp1_rid,
    maxigp1_rdata,
    maxigp1_rresp,
    maxigp1_rlast,
    maxigp1_rvalid
  );

   ps8_simulate_single_cycle_maxihpm1_fpd_aclk();

   ps8_get_outputs_m_axi_hpm1_fpd_maxihpm1_fpd_aclk(
    maxigp1_awid,
    maxigp1_awaddr,
    maxigp1_awlen,
    maxigp1_awsize,
    maxigp1_awburst,
    maxigp1_awlock,
    maxigp1_awcache,
    maxigp1_awprot,
    maxigp1_awqos,
    maxigp1_awuser,
    maxigp1_awvalid,
    maxigp1_wdata,
    maxigp1_wstrb,
    maxigp1_wlast,
    maxigp1_wvalid,
    maxigp1_bready,
    maxigp1_arid,
    maxigp1_araddr,
    maxigp1_arlen,
    maxigp1_arsize,
    maxigp1_arburst,
    maxigp1_arlock,
    maxigp1_arcache,
    maxigp1_arprot,
    maxigp1_arqos,
    maxigp1_aruser,
    maxigp1_arvalid,
    maxigp1_rready
  );
   end


always@(posedge saxihpc0_fpd_aclk)
  begin

   ps8_set_ip_context(ip_name);

   ps8_set_inputs_s_axi_hpc0_fpd_saxihpc0_fpd_aclk(
    saxigp0_awid,
    saxigp0_awaddr,
    saxigp0_awlen,
    saxigp0_awsize,
    saxigp0_awburst,
    saxigp0_awlock,
    saxigp0_awcache,
    saxigp0_awprot,
    saxigp0_awqos,
    saxigp0_awuser,
    saxigp0_awvalid,
    saxigp0_wdata,
    saxigp0_wstrb,
    saxigp0_wlast,
    saxigp0_wvalid,
    saxigp0_bready,
    saxigp0_arid,
    saxigp0_araddr,
    saxigp0_arlen,
    saxigp0_arsize,
    saxigp0_arburst,
    saxigp0_arlock,
    saxigp0_arcache,
    saxigp0_arprot,
    saxigp0_arqos,
    saxigp0_aruser,
    saxigp0_arvalid,
    saxigp0_rready
  );

   ps8_simulate_single_cycle_saxihpc0_fpd_aclk();

   ps8_get_outputs_s_axi_hpc0_fpd_saxihpc0_fpd_aclk(
    saxigp0_awready,
    saxigp0_wready,
    saxigp0_bid,
    saxigp0_bresp,
    saxigp0_bvalid,
    saxigp0_arready,
    saxigp0_rid,
    saxigp0_rdata,
    saxigp0_rresp,
    saxigp0_rlast,
    saxigp0_rvalid
  );
   end

endmodule

