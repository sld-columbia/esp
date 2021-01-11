/*********************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_axi_gp.sv
 *
 * Date : 2015-16
 *
 * Description : Connections for AXI GP ports
 *
 *****************************************************************************/

/* AXI Slave GP0*/
  zynq_ultra_ps_e_vip_v1_0_6_axi_slave #( C_USE_S_AXI_GP0, // enable
               axi_sgp0_name, // name
               C_S_AXI_GP0_DATA_WIDTH, // data width
               addr_width, /// address width
               axi_sgp_id_width, // ID width
               axi_sgp_awuser_width,
               axi_sgp_aruser_width,
               1,//axi_sgp_ruser_width,
			   1,//axi_sgp_wuser_width,
               1,//axi_sgp_buser_width,
               axi_sgp_outstanding, // outstanding transactions // 7 Reads and 3 Writes 
               axi_slv_excl_support, // Exclusive access support
               axi_sgp_wr_outstanding,
               axi_sgp_rd_outstanding,
   			   1)
  // S_AXI_GP0(.S_RESETN          (net_s_axi_gp0_rstn),
  S_AXI_HPC0_FPD(.S_RESETN          (net_s_axi_gp0_rstn),
            .S_ACLK            (SAXIGP0WCLK),
            // Write Address Channel
            .S_AWID            (SAXIGP0AWID),
            .S_AWADDR          (SAXIGP0AWADDR[39:0]),
            .S_AWLEN           (SAXIGP0AWLEN),
            .S_AWSIZE          (SAXIGP0AWSIZE),
            .S_AWBURST         (SAXIGP0AWBURST),
            .S_AWLOCK          (SAXIGP0AWLOCK),
            .S_AWCACHE         (SAXIGP0AWCACHE),
            .S_AWPROT          (SAXIGP0AWPROT),
            .S_AWVALID         (SAXIGP0AWVALID),
            .S_AWREADY         (SAXIGP0AWREADY),
            // Write Data Channel Signals.
            .S_WDATA           (SAXIGP0WDATA),
            .S_WSTRB           (SAXIGP0WSTRB), 
            .S_WLAST           (SAXIGP0WLAST), 
            .S_WVALID          (SAXIGP0WVALID),
            .S_WREADY          (SAXIGP0WREADY),
            // Write Response Channel Signals.
            .S_BID             (SAXIGP0BID),
            .S_BRESP           (SAXIGP0BRESP),
            .S_BVALID          (SAXIGP0BVALID),
            .S_BREADY          (SAXIGP0BREADY),
            // Read Address Channel Signals.
            .S_ARID            (SAXIGP0ARID),
            .S_ARADDR          (SAXIGP0ARADDR[39:0]),
            .S_ARLEN           (SAXIGP0ARLEN),
            .S_ARSIZE          (SAXIGP0ARSIZE),
            .S_ARBURST         (SAXIGP0ARBURST),
            .S_ARLOCK          (SAXIGP0ARLOCK),
            .S_ARCACHE         (SAXIGP0ARCACHE),
            .S_ARPROT          (SAXIGP0ARPROT),
            .S_ARVALID         (SAXIGP0ARVALID),
            .S_ARREADY         (SAXIGP0ARREADY),
            // Read Data Channel Signals.
            .S_RID             (SAXIGP0RID),
            .S_RDATA           (SAXIGP0RDATA),
            .S_RRESP           (SAXIGP0RRESP),
            .S_RLAST           (SAXIGP0RLAST),
            .S_RVALID          (SAXIGP0RVALID),
            .S_RREADY          (SAXIGP0RREADY),
            // Side band signals 
            .S_AWQOS           (SAXIGP0AWQOS),
            .S_ARQOS           (SAXIGP0ARQOS),            // Side band signals 
            .S_AWREGION        (0),
            .S_ARREGION        (0),
            .S_AWUSER          (SAXIGP0AWUSER),
            .S_WUSER           (0),
            .S_BUSER           (),
            .S_ARUSER          (SAXIGP0ARUSER),
            .S_RUSER           (),
            .SW_CLK            (net_sw_clk),
/* This goes to port 0 of DDR and port 0 of OCM , port 0 of REG*/
            .WR_DATA_ACK_DDR   (ddr_wr_ack_gp0),
            .WR_DATA_ACK_OCM   (ocm_wr_ack_gp0),
            .WR_DATA           (net_wr_data_gp0), 
			.WR_DATA_STRB      (net_wr_strb_gp0),
            .WR_ADDR           (net_wr_addr_gp0), 
            .WR_BYTES          (net_wr_bytes_gp0), 
            .WR_DATA_VALID_DDR (ddr_wr_dv_gp0), 
            .WR_DATA_VALID_OCM (ocm_wr_dv_gp0), 
            .WR_QOS            (net_wr_qos_gp0),
            .RD_REQ_DDR        (ddr_rd_req_gp0),
            .RD_REQ_OCM        (ocm_rd_req_gp0),
            .RD_REQ_REG        (reg_rd_req_gp0),
            .RD_ADDR           (net_rd_addr_gp0),
            .RD_DATA_DDR       (ddr_rd_data_gp0),
            .RD_DATA_OCM       (ocm_rd_data_gp0),
            .RD_DATA_REG       (reg_rd_data_gp0),
            .RD_BYTES          (net_rd_bytes_gp0),
            .RD_DATA_VALID_DDR (ddr_rd_dv_gp0),
            .RD_DATA_VALID_OCM (ocm_rd_dv_gp0),
            .RD_DATA_VALID_REG (reg_rd_dv_gp0),
            .RD_QOS            (net_rd_qos_gp0)
);

/* AXI Slave GP1*/
  zynq_ultra_ps_e_vip_v1_0_6_axi_slave #( C_USE_S_AXI_GP1, // enable
               axi_sgp1_name, // name
               C_S_AXI_GP1_DATA_WIDTH, // data width
               addr_width, /// address width
               axi_sgp_id_width, // ID width
               axi_sgp_awuser_width,
               axi_sgp_aruser_width,
               1,//axi_sgp_ruser_width,
			   1,//axi_sgp_wuser_width,
               1,//axi_sgp_buser_width,
               axi_sgp_outstanding, // outstanding transactions // 7 Reads and 3 Writes 
               axi_slv_excl_support, // Exclusive access support
               axi_sgp_wr_outstanding,
               axi_sgp_rd_outstanding,
   			   1)
  // S_AXI_GP1(.S_RESETN          (net_s_axi_gp1_rstn),
  S_AXI_HPC1_FPD(.S_RESETN          (net_s_axi_gp1_rstn),
            .S_ACLK            (SAXIGP1WCLK),
            // Write Address Channel
            .S_AWID            (SAXIGP1AWID),
            .S_AWADDR          (SAXIGP1AWADDR[39:0]),
            .S_AWLEN           (SAXIGP1AWLEN),
            .S_AWSIZE          (SAXIGP1AWSIZE),
            .S_AWBURST         (SAXIGP1AWBURST),
            .S_AWLOCK          (SAXIGP1AWLOCK),
            .S_AWCACHE         (SAXIGP1AWCACHE),
            .S_AWPROT          (SAXIGP1AWPROT),
            .S_AWVALID         (SAXIGP1AWVALID),
            .S_AWREADY         (SAXIGP1AWREADY),
            // Write Data Channel Signals.
            .S_WDATA           (SAXIGP1WDATA),
            .S_WSTRB           (SAXIGP1WSTRB), 
            .S_WLAST           (SAXIGP1WLAST), 
            .S_WVALID          (SAXIGP1WVALID),
            .S_WREADY          (SAXIGP1WREADY),
            // Write Response Channel Signals.
            .S_BID             (SAXIGP1BID),
            .S_BRESP           (SAXIGP1BRESP),
            .S_BVALID          (SAXIGP1BVALID),
            .S_BREADY          (SAXIGP1BREADY),
            // Read Address Channel Signals.
            .S_ARID            (SAXIGP1ARID),
            .S_ARADDR          (SAXIGP1ARADDR[39:0]),
            .S_ARLEN           (SAXIGP1ARLEN),
            .S_ARSIZE          (SAXIGP1ARSIZE),
            .S_ARBURST         (SAXIGP1ARBURST),
            .S_ARLOCK          (SAXIGP1ARLOCK),
            .S_ARCACHE         (SAXIGP1ARCACHE),
            .S_ARPROT          (SAXIGP1ARPROT),
            .S_ARVALID         (SAXIGP1ARVALID),
            .S_ARREADY         (SAXIGP1ARREADY),
            // Read Data Channel Signals.
            .S_RID             (SAXIGP1RID),
            .S_RDATA           (SAXIGP1RDATA),
            .S_RRESP           (SAXIGP1RRESP),
            .S_RLAST           (SAXIGP1RLAST),
            .S_RVALID          (SAXIGP1RVALID),
            .S_RREADY          (SAXIGP1RREADY),
            // Side band signals 
            .S_AWQOS           (SAXIGP1AWQOS),
            .S_ARQOS           (SAXIGP1ARQOS),            // Side band signals 
            .S_AWREGION        (0),
            .S_ARREGION        (0),
            .S_AWUSER          (SAXIGP1AWUSER),
            .S_WUSER           (0),
            .S_BUSER           (),
            .S_ARUSER          (SAXIGP1ARUSER),
            .S_RUSER           (),
            .SW_CLK            (net_sw_clk),
/* This goes to port 0 of DDR and port 0 of OCM , port 0 of REG*/
            .WR_DATA_ACK_DDR   (ddr_wr_ack_gp1),
            .WR_DATA_ACK_OCM   (ocm_wr_ack_gp1),
            .WR_DATA           (net_wr_data_gp1), 
			.WR_DATA_STRB      (net_wr_strb_gp1),
            .WR_ADDR           (net_wr_addr_gp1), 
            .WR_BYTES          (net_wr_bytes_gp1), 
            .WR_DATA_VALID_DDR (ddr_wr_dv_gp1), 
            .WR_DATA_VALID_OCM (ocm_wr_dv_gp1), 
            .WR_QOS            (net_wr_qos_gp1),
            .RD_REQ_DDR        (ddr_rd_req_gp1),
            .RD_REQ_OCM        (ocm_rd_req_gp1),
            .RD_REQ_REG        (reg_rd_req_gp1),
            .RD_ADDR           (net_rd_addr_gp1),
            .RD_DATA_DDR       (ddr_rd_data_gp1),
            .RD_DATA_OCM       (ocm_rd_data_gp1),
            .RD_DATA_REG       (reg_rd_data_gp1),
            .RD_BYTES          (net_rd_bytes_gp1),
            .RD_DATA_VALID_DDR (ddr_rd_dv_gp1),
            .RD_DATA_VALID_OCM (ocm_rd_dv_gp1),
            .RD_DATA_VALID_REG (reg_rd_dv_gp1),
            .RD_QOS            (net_rd_qos_gp1)
);

/* AXI Slave GP2*/
  zynq_ultra_ps_e_vip_v1_0_6_axi_slave #( C_USE_S_AXI_GP2, // enable
               axi_sgp2_name, // name
               C_S_AXI_GP2_DATA_WIDTH, // data width
               addr_width, /// address width
               axi_sgp_id_width, // ID width
               axi_sgp_awuser_width,
               axi_sgp_aruser_width,
               1,//axi_sgp_ruser_width,
			   1,//axi_sgp_wuser_width,
               1,//axi_sgp_buser_width,
               axi_sgp_outstanding, // outstanding transactions // 7 Reads and 3 Writes 
               axi_slv_excl_support, // Exclusive access support
               axi_sgp_wr_outstanding,
               axi_sgp_rd_outstanding,
   			   1)
  // S_AXI_GP2(.S_RESETN          (net_s_axi_gp2_rstn),
  S_AXI_HP0_FPD(.S_RESETN          (net_s_axi_gp2_rstn),
            .S_ACLK            (SAXIGP2WCLK),
            // Write Address Channel
            .S_AWID            (SAXIGP2AWID),
            .S_AWADDR          (SAXIGP2AWADDR[39:0]),
            .S_AWLEN           (SAXIGP2AWLEN),
            .S_AWSIZE          (SAXIGP2AWSIZE),
            .S_AWBURST         (SAXIGP2AWBURST),
            .S_AWLOCK          (SAXIGP2AWLOCK),
            .S_AWCACHE         (SAXIGP2AWCACHE),
            .S_AWPROT          (SAXIGP2AWPROT),
            .S_AWVALID         (SAXIGP2AWVALID),
            .S_AWREADY         (SAXIGP2AWREADY),
            // Write Data Channel Signals.
            .S_WDATA           (SAXIGP2WDATA),
            .S_WSTRB           (SAXIGP2WSTRB), 
            .S_WLAST           (SAXIGP2WLAST), 
            .S_WVALID          (SAXIGP2WVALID),
            .S_WREADY          (SAXIGP2WREADY),
            // Write Response Channel Signals.
            .S_BID             (SAXIGP2BID),
            .S_BRESP           (SAXIGP2BRESP),
            .S_BVALID          (SAXIGP2BVALID),
            .S_BREADY          (SAXIGP2BREADY),
            // Read Address Channel Signals.
            .S_ARID            (SAXIGP2ARID),
            .S_ARADDR          (SAXIGP2ARADDR[39:0]),
            .S_ARLEN           (SAXIGP2ARLEN),
            .S_ARSIZE          (SAXIGP2ARSIZE),
            .S_ARBURST         (SAXIGP2ARBURST),
            .S_ARLOCK          (SAXIGP2ARLOCK),
            .S_ARCACHE         (SAXIGP2ARCACHE),
            .S_ARPROT          (SAXIGP2ARPROT),
            .S_ARVALID         (SAXIGP2ARVALID),
            .S_ARREADY         (SAXIGP2ARREADY),
            // Read Data Channel Signals.
            .S_RID             (SAXIGP2RID),
            .S_RDATA           (SAXIGP2RDATA),
            .S_RRESP           (SAXIGP2RRESP),
            .S_RLAST           (SAXIGP2RLAST),
            .S_RVALID          (SAXIGP2RVALID),
            .S_RREADY          (SAXIGP2RREADY),
            // Side band signals 
            .S_AWQOS           (SAXIGP2AWQOS),
            .S_ARQOS           (SAXIGP2ARQOS),            // Side band signals 
            .S_AWREGION        (0),
            .S_ARREGION        (0),
            .S_AWUSER          (SAXIGP2AWUSER),
            .S_WUSER           (0),
            .S_BUSER           (),
            .S_ARUSER          (SAXIGP2ARUSER),
            .S_RUSER           (),
            .SW_CLK            (net_sw_clk),
/* This goes to port 0 of DDR and port 0 of OCM , port 0 of REG*/
            .WR_DATA_ACK_DDR   (ddr_wr_ack_gp2),
            .WR_DATA_ACK_OCM   (ocm_wr_ack_gp2),
            .WR_DATA           (net_wr_data_gp2), 
			.WR_DATA_STRB      (net_wr_strb_gp2),
            .WR_ADDR           (net_wr_addr_gp2), 
            .WR_BYTES          (net_wr_bytes_gp2), 
            .WR_DATA_VALID_DDR (ddr_wr_dv_gp2), 
            .WR_DATA_VALID_OCM (ocm_wr_dv_gp2), 
            .WR_QOS            (net_wr_qos_gp2),
            .RD_REQ_DDR        (ddr_rd_req_gp2),
            .RD_REQ_OCM        (ocm_rd_req_gp2),
            .RD_REQ_REG        (reg_rd_req_gp2),
            .RD_ADDR           (net_rd_addr_gp2),
            .RD_DATA_DDR       (ddr_rd_data_gp2),
            .RD_DATA_OCM       (ocm_rd_data_gp2),
            .RD_DATA_REG       (reg_rd_data_gp2),
            .RD_BYTES          (net_rd_bytes_gp2),
            .RD_DATA_VALID_DDR (ddr_rd_dv_gp2),
            .RD_DATA_VALID_OCM (ocm_rd_dv_gp2),
            .RD_DATA_VALID_REG (reg_rd_dv_gp2),
            .RD_QOS            (net_rd_qos_gp2)
);

/* AXI Slave GP3*/
  zynq_ultra_ps_e_vip_v1_0_6_axi_slave #( C_USE_S_AXI_GP3, // enable
               axi_sgp3_name, // name
               C_S_AXI_GP3_DATA_WIDTH, // data width
               addr_width, /// address width
               axi_sgp_id_width, // ID width
               axi_sgp_awuser_width,
               axi_sgp_aruser_width,
               1,//axi_sgp_ruser_width,
			   1,//axi_sgp_wuser_width,
               1,//axi_sgp_buser_width,
               axi_sgp_outstanding, // outstanding transactions // 7 Reads and 3 Writes 
               axi_slv_excl_support, // Exclusive access support
               axi_sgp_wr_outstanding,
               axi_sgp_rd_outstanding,
   			   1)
  // S_AXI_GP3(.S_RESETN          (net_s_axi_gp3_rstn),
  S_AXI_HP1_FPD(.S_RESETN          (net_s_axi_gp3_rstn),
            .S_ACLK            (SAXIGP3WCLK),
            // Write Address Channel
            .S_AWID            (SAXIGP3AWID),
            .S_AWADDR          (SAXIGP3AWADDR[39:0]),
            .S_AWLEN           (SAXIGP3AWLEN),
            .S_AWSIZE          (SAXIGP3AWSIZE),
            .S_AWBURST         (SAXIGP3AWBURST),
            .S_AWLOCK          (SAXIGP3AWLOCK),
            .S_AWCACHE         (SAXIGP3AWCACHE),
            .S_AWPROT          (SAXIGP3AWPROT),
            .S_AWVALID         (SAXIGP3AWVALID),
            .S_AWREADY         (SAXIGP3AWREADY),
            // Write Data Channel Signals.
            .S_WDATA           (SAXIGP3WDATA),
            .S_WSTRB           (SAXIGP3WSTRB), 
            .S_WLAST           (SAXIGP3WLAST), 
            .S_WVALID          (SAXIGP3WVALID),
            .S_WREADY          (SAXIGP3WREADY),
            // Write Response Channel Signals.
            .S_BID             (SAXIGP3BID),
            .S_BRESP           (SAXIGP3BRESP),
            .S_BVALID          (SAXIGP3BVALID),
            .S_BREADY          (SAXIGP3BREADY),
            // Read Address Channel Signals.
            .S_ARID            (SAXIGP3ARID),
            .S_ARADDR          (SAXIGP3ARADDR[39:0]),
            .S_ARLEN           (SAXIGP3ARLEN),
            .S_ARSIZE          (SAXIGP3ARSIZE),
            .S_ARBURST         (SAXIGP3ARBURST),
            .S_ARLOCK          (SAXIGP3ARLOCK),
            .S_ARCACHE         (SAXIGP3ARCACHE),
            .S_ARPROT          (SAXIGP3ARPROT),
            .S_ARVALID         (SAXIGP3ARVALID),
            .S_ARREADY         (SAXIGP3ARREADY),
            // Read Data Channel Signals.
            .S_RID             (SAXIGP3RID),
            .S_RDATA           (SAXIGP3RDATA),
            .S_RRESP           (SAXIGP3RRESP),
            .S_RLAST           (SAXIGP3RLAST),
            .S_RVALID          (SAXIGP3RVALID),
            .S_RREADY          (SAXIGP3RREADY),
            // Side band signals 
            .S_AWQOS           (SAXIGP3AWQOS),
            .S_ARQOS           (SAXIGP3ARQOS),            // Side band signals 
            .S_AWREGION        (0),
            .S_ARREGION        (0),
            .S_AWUSER          (SAXIGP3AWUSER),
            .S_WUSER           (0),
            .S_BUSER           (),
            .S_ARUSER          (SAXIGP3ARUSER),
            .S_RUSER           (),
            .SW_CLK            (net_sw_clk),
/* This goes to port 0 of DDR and port 0 of OCM , port 0 of REG*/
            .WR_DATA_ACK_DDR   (ddr_wr_ack_gp3),
            .WR_DATA_ACK_OCM   (ocm_wr_ack_gp3),
            .WR_DATA           (net_wr_data_gp3), 
			.WR_DATA_STRB      (net_wr_strb_gp3),
            .WR_ADDR           (net_wr_addr_gp3), 
            .WR_BYTES          (net_wr_bytes_gp3), 
            .WR_DATA_VALID_DDR (ddr_wr_dv_gp3), 
            .WR_DATA_VALID_OCM (ocm_wr_dv_gp3), 
            .WR_QOS            (net_wr_qos_gp3),
            .RD_REQ_DDR        (ddr_rd_req_gp3),
            .RD_REQ_OCM        (ocm_rd_req_gp3),
            .RD_REQ_REG        (reg_rd_req_gp3),
            .RD_ADDR           (net_rd_addr_gp3),
            .RD_DATA_DDR       (ddr_rd_data_gp3),
            .RD_DATA_OCM       (ocm_rd_data_gp3),
            .RD_DATA_REG       (reg_rd_data_gp3),
            .RD_BYTES          (net_rd_bytes_gp3),
            .RD_DATA_VALID_DDR (ddr_rd_dv_gp3),
            .RD_DATA_VALID_OCM (ocm_rd_dv_gp3),
            .RD_DATA_VALID_REG (reg_rd_dv_gp3),
            .RD_QOS            (net_rd_qos_gp3)
);

/* AXI Slave GP4*/
  zynq_ultra_ps_e_vip_v1_0_6_axi_slave #( C_USE_S_AXI_GP4, // enable
               axi_sgp4_name, // name
               C_S_AXI_GP4_DATA_WIDTH, // data width
               addr_width, /// address width
               axi_sgp_id_width, // ID width
               axi_sgp_awuser_width,
               axi_sgp_aruser_width,
               1,//axi_sgp_ruser_width,
			   1,//axi_sgp_wuser_width,
               1,//axi_sgp_buser_width,
               axi_sgp_outstanding, // outstanding transactions // 7 Reads and 3 Writes 
               axi_slv_excl_support, // Exclusive access support
               axi_sgp_wr_outstanding,
               axi_sgp_rd_outstanding,
   			   1)
  // S_AXI_GP4(.S_RESETN          (net_s_axi_gp4_rstn),
  S_AXI_HP2_FPD(.S_RESETN          (net_s_axi_gp4_rstn),
            .S_ACLK            (SAXIGP4WCLK),
            // Write Address Channel
            .S_AWID            (SAXIGP4AWID),
            .S_AWADDR          (SAXIGP4AWADDR[39:0]),
            .S_AWLEN           (SAXIGP4AWLEN),
            .S_AWSIZE          (SAXIGP4AWSIZE),
            .S_AWBURST         (SAXIGP4AWBURST),
            .S_AWLOCK          (SAXIGP4AWLOCK),
            .S_AWCACHE         (SAXIGP4AWCACHE),
            .S_AWPROT          (SAXIGP4AWPROT),
            .S_AWVALID         (SAXIGP4AWVALID),
            .S_AWREADY         (SAXIGP4AWREADY),
            // Write Data Channel Signals.
            .S_WDATA           (SAXIGP4WDATA),
            .S_WSTRB           (SAXIGP4WSTRB), 
            .S_WLAST           (SAXIGP4WLAST), 
            .S_WVALID          (SAXIGP4WVALID),
            .S_WREADY          (SAXIGP4WREADY),
            // Write Response Channel Signals.
            .S_BID             (SAXIGP4BID),
            .S_BRESP           (SAXIGP4BRESP),
            .S_BVALID          (SAXIGP4BVALID),
            .S_BREADY          (SAXIGP4BREADY),
            // Read Address Channel Signals.
            .S_ARID            (SAXIGP4ARID),
            .S_ARADDR          (SAXIGP4ARADDR[39:0]),
            .S_ARLEN           (SAXIGP4ARLEN),
            .S_ARSIZE          (SAXIGP4ARSIZE),
            .S_ARBURST         (SAXIGP4ARBURST),
            .S_ARLOCK          (SAXIGP4ARLOCK),
            .S_ARCACHE         (SAXIGP4ARCACHE),
            .S_ARPROT          (SAXIGP4ARPROT),
            .S_ARVALID         (SAXIGP4ARVALID),
            .S_ARREADY         (SAXIGP4ARREADY),
            // Read Data Channel Signals.
            .S_RID             (SAXIGP4RID),
            .S_RDATA           (SAXIGP4RDATA),
            .S_RRESP           (SAXIGP4RRESP),
            .S_RLAST           (SAXIGP4RLAST),
            .S_RVALID          (SAXIGP4RVALID),
            .S_RREADY          (SAXIGP4RREADY),
            // Side band signals 
            .S_AWQOS           (SAXIGP4AWQOS),
            .S_ARQOS           (SAXIGP4ARQOS),            // Side band signals 
            .S_AWREGION        (0),
            .S_ARREGION        (0),
            .S_AWUSER          (SAXIGP4AWUSER),
            .S_WUSER           (0),
            .S_BUSER           (),
            .S_ARUSER          (SAXIGP4ARUSER),
            .S_RUSER           (),
            .SW_CLK            (net_sw_clk),
/* This goes to port 0 of DDR and port 0 of OCM , port 0 of REG*/
            .WR_DATA_ACK_DDR   (ddr_wr_ack_gp4),
            .WR_DATA_ACK_OCM   (ocm_wr_ack_gp4),
            .WR_DATA           (net_wr_data_gp4), 
			.WR_DATA_STRB      (net_wr_strb_gp4),
            .WR_ADDR           (net_wr_addr_gp4), 
            .WR_BYTES          (net_wr_bytes_gp4), 
            .WR_DATA_VALID_DDR (ddr_wr_dv_gp4), 
            .WR_DATA_VALID_OCM (ocm_wr_dv_gp4), 
            .WR_QOS            (net_wr_qos_gp4),
            .RD_REQ_DDR        (ddr_rd_req_gp4),
            .RD_REQ_OCM        (ocm_rd_req_gp4),
            .RD_REQ_REG        (reg_rd_req_gp4),
            .RD_ADDR           (net_rd_addr_gp4),
            .RD_DATA_DDR       (ddr_rd_data_gp4),
            .RD_DATA_OCM       (ocm_rd_data_gp4),
            .RD_DATA_REG       (reg_rd_data_gp4),
            .RD_BYTES          (net_rd_bytes_gp4),
            .RD_DATA_VALID_DDR (ddr_rd_dv_gp4),
            .RD_DATA_VALID_OCM (ocm_rd_dv_gp4),
            .RD_DATA_VALID_REG (reg_rd_dv_gp4),
            .RD_QOS            (net_rd_qos_gp4)
);

/* AXI Slave GP5*/
  zynq_ultra_ps_e_vip_v1_0_6_axi_slave #( C_USE_S_AXI_GP5, // enable
               axi_sgp5_name, // name
               C_S_AXI_GP5_DATA_WIDTH, // data width
               addr_width, /// address width
               axi_sgp_id_width, // ID width
               axi_sgp_awuser_width,
               axi_sgp_aruser_width,
               1,//axi_sgp_ruser_width,
			   1,//axi_sgp_wuser_width,
               1,//axi_sgp_buser_width,
               axi_sgp_outstanding, // outstanding transactions // 7 Reads and 3 Writes 
               axi_slv_excl_support, // Exclusive access support
               axi_sgp_wr_outstanding,
               axi_sgp_rd_outstanding,
   			   1)
  // S_AXI_GP5(.S_RESETN          (net_s_axi_gp5_rstn),
  S_AXI_HP3_FPD(.S_RESETN          (net_s_axi_gp5_rstn),
            .S_ACLK            (SAXIGP5WCLK),
            // Write Address Channel
            .S_AWID            (SAXIGP5AWID),
            .S_AWADDR          (SAXIGP5AWADDR[39:0]),
            .S_AWLEN           (SAXIGP5AWLEN),
            .S_AWSIZE          (SAXIGP5AWSIZE),
            .S_AWBURST         (SAXIGP5AWBURST),
            .S_AWLOCK          (SAXIGP5AWLOCK),
            .S_AWCACHE         (SAXIGP5AWCACHE),
            .S_AWPROT          (SAXIGP5AWPROT),
            .S_AWVALID         (SAXIGP5AWVALID),
            .S_AWREADY         (SAXIGP5AWREADY),
            // Write Data Channel Signals.
            .S_WDATA           (SAXIGP5WDATA),
            .S_WSTRB           (SAXIGP5WSTRB), 
            .S_WLAST           (SAXIGP5WLAST), 
            .S_WVALID          (SAXIGP5WVALID),
            .S_WREADY          (SAXIGP5WREADY),
            // Write Response Channel Signals.
            .S_BID             (SAXIGP5BID),
            .S_BRESP           (SAXIGP5BRESP),
            .S_BVALID          (SAXIGP5BVALID),
            .S_BREADY          (SAXIGP5BREADY),
            // Read Address Channel Signals.
            .S_ARID            (SAXIGP5ARID),
            .S_ARADDR          (SAXIGP5ARADDR[39:0]),
            .S_ARLEN           (SAXIGP5ARLEN),
            .S_ARSIZE          (SAXIGP5ARSIZE),
            .S_ARBURST         (SAXIGP5ARBURST),
            .S_ARLOCK          (SAXIGP5ARLOCK),
            .S_ARCACHE         (SAXIGP5ARCACHE),
            .S_ARPROT          (SAXIGP5ARPROT),
            .S_ARVALID         (SAXIGP5ARVALID),
            .S_ARREADY         (SAXIGP5ARREADY),
            // Read Data Channel Signals.
            .S_RID             (SAXIGP5RID),
            .S_RDATA           (SAXIGP5RDATA),
            .S_RRESP           (SAXIGP5RRESP),
            .S_RLAST           (SAXIGP5RLAST),
            .S_RVALID          (SAXIGP5RVALID),
            .S_RREADY          (SAXIGP5RREADY),
            // Side band signals 
            .S_AWQOS           (SAXIGP5AWQOS),
            .S_ARQOS           (SAXIGP5ARQOS),            // Side band signals 
            .S_AWREGION        (0),
            .S_ARREGION        (0),
            .S_AWUSER          (SAXIGP5AWUSER),
            .S_WUSER           (0),
            .S_BUSER           (),
            .S_ARUSER          (SAXIGP5ARUSER),
            .S_RUSER           (),
            .SW_CLK            (net_sw_clk),
/* This goes to port 0 of DDR and port 0 of OCM , port 0 of REG*/
            .WR_DATA_ACK_DDR   (ddr_wr_ack_gp5),
            .WR_DATA_ACK_OCM   (ocm_wr_ack_gp5),
            .WR_DATA           (net_wr_data_gp5), 
			.WR_DATA_STRB      (net_wr_strb_gp5),
            .WR_ADDR           (net_wr_addr_gp5), 
            .WR_BYTES          (net_wr_bytes_gp5), 
            .WR_DATA_VALID_DDR (ddr_wr_dv_gp5), 
            .WR_DATA_VALID_OCM (ocm_wr_dv_gp5), 
            .WR_QOS            (net_wr_qos_gp5),
            .RD_REQ_DDR        (ddr_rd_req_gp5),
            .RD_REQ_OCM        (ocm_rd_req_gp5),
            .RD_REQ_REG        (reg_rd_req_gp5),
            .RD_ADDR           (net_rd_addr_gp5),
            .RD_DATA_DDR       (ddr_rd_data_gp5),
            .RD_DATA_OCM       (ocm_rd_data_gp5),
            .RD_DATA_REG       (reg_rd_data_gp5),
            .RD_BYTES          (net_rd_bytes_gp5),
            .RD_DATA_VALID_DDR (ddr_rd_dv_gp5),
            .RD_DATA_VALID_OCM (ocm_rd_dv_gp5),
            .RD_DATA_VALID_REG (reg_rd_dv_gp5),
            .RD_QOS            (net_rd_qos_gp5)
);

/* AXI Slave GP6*/
  zynq_ultra_ps_e_vip_v1_0_6_axi_slave #( C_USE_S_AXI_GP6, // enable
               axi_sgp6_name, // name
               C_S_AXI_GP6_DATA_WIDTH, // data width
               addr_width, /// address width
               axi_sgp_id_width, // ID width
               axi_sgp_awuser_width,
               axi_sgp_aruser_width,
               1,//axi_sgp_ruser_width,
			   1,//axi_sgp_wuser_width,
               1,//axi_sgp_buser_width,
               axi_sgp_outstanding, // outstanding transactions // 7 Reads and 3 Writes 
               axi_slv_excl_support, // Exclusive access support
               axi_sgp_wr_outstanding,
               axi_sgp_rd_outstanding,
   			   1)
  // S_AXI_GP6(.S_RESETN          (net_s_axi_gp6_rstn),
  S_AXI_HPM0_LPD(.S_RESETN          (net_s_axi_gp6_rstn),
            .S_ACLK            (SAXIGP6WCLK),
            // Write Address Channel
            .S_AWID            (SAXIGP6AWID),
            .S_AWADDR          (SAXIGP6AWADDR[39:0]),
            .S_AWLEN           (SAXIGP6AWLEN),
            .S_AWSIZE          (SAXIGP6AWSIZE),
            .S_AWBURST         (SAXIGP6AWBURST),
            .S_AWLOCK          (SAXIGP6AWLOCK),
            .S_AWCACHE         (SAXIGP6AWCACHE),
            .S_AWPROT          (SAXIGP6AWPROT),
            .S_AWVALID         (SAXIGP6AWVALID),
            .S_AWREADY         (SAXIGP6AWREADY),
            // Write Data Channel Signals.
            .S_WDATA           (SAXIGP6WDATA),
            .S_WSTRB           (SAXIGP6WSTRB), 
            .S_WLAST           (SAXIGP6WLAST), 
            .S_WVALID          (SAXIGP6WVALID),
            .S_WREADY          (SAXIGP6WREADY),
            // Write Response Channel Signals.
            .S_BID             (SAXIGP6BID),
            .S_BRESP           (SAXIGP6BRESP),
            .S_BVALID          (SAXIGP6BVALID),
            .S_BREADY          (SAXIGP6BREADY),
            // Read Address Channel Signals.
            .S_ARID            (SAXIGP6ARID),
            .S_ARADDR          (SAXIGP6ARADDR[39:0]),
            .S_ARLEN           (SAXIGP6ARLEN),
            .S_ARSIZE          (SAXIGP6ARSIZE),
            .S_ARBURST         (SAXIGP6ARBURST),
            .S_ARLOCK          (SAXIGP6ARLOCK),
            .S_ARCACHE         (SAXIGP6ARCACHE),
            .S_ARPROT          (SAXIGP6ARPROT),
            .S_ARVALID         (SAXIGP6ARVALID),
            .S_ARREADY         (SAXIGP6ARREADY),
            // Read Data Channel Signals.
            .S_RID             (SAXIGP6RID),
            .S_RDATA           (SAXIGP6RDATA),
            .S_RRESP           (SAXIGP6RRESP),
            .S_RLAST           (SAXIGP6RLAST),
            .S_RVALID          (SAXIGP6RVALID),
            .S_RREADY          (SAXIGP6RREADY),
            // Side band signals 
            .S_AWQOS           (SAXIGP6AWQOS),
            .S_ARQOS           (SAXIGP6ARQOS),            // Side band signals 
            .S_AWREGION        (0),
            .S_ARREGION        (0),
            .S_AWUSER          (SAXIGP6AWUSER),
            .S_WUSER           (0),
            .S_BUSER           (),
            .S_ARUSER          (SAXIGP6ARUSER),
            .S_RUSER           (),
            .SW_CLK            (net_sw_clk),
/* This goes to port 0 of DDR and port 0 of OCM , port 0 of REG*/
            .WR_DATA_ACK_DDR   (ddr_wr_ack_gp6),
            .WR_DATA_ACK_OCM   (ocm_wr_ack_gp6),
            .WR_DATA           (net_wr_data_gp6), 
			.WR_DATA_STRB      (net_wr_strb_gp6),
            .WR_ADDR           (net_wr_addr_gp6), 
            .WR_BYTES          (net_wr_bytes_gp6), 
            .WR_DATA_VALID_DDR (ddr_wr_dv_gp6), 
            .WR_DATA_VALID_OCM (ocm_wr_dv_gp6), 
            .WR_QOS            (net_wr_qos_gp6),
            .RD_REQ_DDR        (ddr_rd_req_gp6),
            .RD_REQ_OCM        (ocm_rd_req_gp6),
            .RD_REQ_REG        (reg_rd_req_gp6),
            .RD_ADDR           (net_rd_addr_gp6),
            .RD_DATA_DDR       (ddr_rd_data_gp6),
            .RD_DATA_OCM       (ocm_rd_data_gp6),
            .RD_DATA_REG       (reg_rd_data_gp6),
            .RD_BYTES          (net_rd_bytes_gp6),
            .RD_DATA_VALID_DDR (ddr_rd_dv_gp6),
            .RD_DATA_VALID_OCM (ocm_rd_dv_gp6),
            .RD_DATA_VALID_REG (reg_rd_dv_gp6),
            .RD_QOS            (net_rd_qos_gp6)
);


/* AXI -Master GP0 */
  zynq_ultra_ps_e_vip_v1_0_6_axi_master #(C_USE_M_AXI_GP0, // enable
               axi_mgp0_name,// name
               C_M_AXI_GP0_DATA_WIDTH, /// Data Width
               addr_width, /// Address width
               axi_mgp_id_width,  //// ID Width
			   axi_mgp_awuser_width,
               axi_mgp_aruser_width,
               1,//axi_mgp_ruser_width,
			   1,//axi_mgp_wuser_width,
               1,//axi_mgp_buser_width,
               axi_mgp_outstanding,  //// Outstanding transactions
               axi_mst_excl_support, // EXCL Access Support
               axi_mgp_wr_id, //WR_ID
               axi_mgp_rd_id,
			   1) //RD_ID
  // M_AXI_GP0(.M_RESETN  (net_m_axi_gp0_rstn),
  M_AXI_HPM0_FPD(.M_RESETN  (net_m_axi_gp0_rstn),
            .M_ACLK    (MAXIGP0ACLK),
            // Write Address Channel
            .M_AWID    (MAXIGP0AWID),
            .M_AWADDR  (MAXIGP0AWADDR),
            .M_AWLEN   (MAXIGP0AWLEN),
            .M_AWSIZE  (MAXIGP0AWSIZE),
            .M_AWBURST (MAXIGP0AWBURST),
            .M_AWLOCK  (MAXIGP0AWLOCK),
            .M_AWCACHE (MAXIGP0AWCACHE),
            .M_AWPROT  (MAXIGP0AWPROT),
            .M_AWVALID (MAXIGP0AWVALID),
            .M_AWREADY (MAXIGP0AWREADY),
            // Write Data Channel Signals.
            .M_WDATA   (MAXIGP0WDATA),
            .M_WSTRB   (MAXIGP0WSTRB), 
            .M_WLAST   (MAXIGP0WLAST), 
            .M_WVALID  (MAXIGP0WVALID),
            .M_WREADY  (MAXIGP0WREADY),
            // Write Response Channel Signals.
            .M_BID     (MAXIGP0BID),
            .M_BRESP   (MAXIGP0BRESP),
            .M_BVALID  (MAXIGP0BVALID),
            .M_BREADY  (MAXIGP0BREADY),
            // Read Address Channel Signals.
            .M_ARID    (MAXIGP0ARID),
            .M_ARADDR  (MAXIGP0ARADDR),
            .M_ARLEN   (MAXIGP0ARLEN),
            .M_ARSIZE  (MAXIGP0ARSIZE),
            .M_ARBURST (MAXIGP0ARBURST),
            .M_ARLOCK  (MAXIGP0ARLOCK),
            .M_ARCACHE (MAXIGP0ARCACHE),
            .M_ARPROT  (MAXIGP0ARPROT),
            .M_ARVALID (MAXIGP0ARVALID),
            .M_ARREADY (MAXIGP0ARREADY),
            // Read Data Channel Signals.
            .M_RID     (MAXIGP0RID),
            .M_RDATA   (MAXIGP0RDATA),
            .M_RRESP   (MAXIGP0RRESP),
            .M_RLAST   (MAXIGP0RLAST),
            .M_RVALID  (MAXIGP0RVALID),
            .M_RREADY  (MAXIGP0RREADY),
            // Side band signals 
            .M_AWQOS   (MAXIGP0AWQOS),
            .M_ARQOS   (MAXIGP0ARQOS),
            .M_AWREGION(),
            .M_ARREGION(),
            .M_AWUSER  (MAXIGP0AWUSER),
            .M_WUSER   (),
            .M_BUSER   (0),
            .M_ARUSER  (MAXIGP0ARUSER),
            .M_RUSER   (0)
            ); 
 
/* AXI -Master GP1 */
  zynq_ultra_ps_e_vip_v1_0_6_axi_master #(C_USE_M_AXI_GP1, // enable
               axi_mgp1_name,// name
               C_M_AXI_GP1_DATA_WIDTH, /// Data Width
               addr_width, /// Address width
               axi_mgp_id_width,  //// ID Width
			   axi_mgp_awuser_width,
               axi_mgp_aruser_width,
               1,//axi_mgp_ruser_width,
			   1,//axi_mgp_wuser_width,
               1,//axi_mgp_buser_width,
               axi_mgp_outstanding,  //// Outstanding transactions
               axi_mst_excl_support, // EXCL Access Support
               axi_mgp_wr_id, //WR_ID
               axi_mgp_rd_id, //RD_ID
			   1) //RD_ID
  // M_AXI_GP1(.M_RESETN  (net_m_axi_gp1_rstn),
  M_AXI_HPM1_FPD(.M_RESETN  (net_m_axi_gp1_rstn),
            .M_ACLK    (MAXIGP1ACLK),
            // Write Address Channel
            .M_AWID    (MAXIGP1AWID),
            .M_AWADDR  (MAXIGP1AWADDR),
            .M_AWLEN   (MAXIGP1AWLEN),
            .M_AWSIZE  (MAXIGP1AWSIZE),
            .M_AWBURST (MAXIGP1AWBURST),
            .M_AWLOCK  (MAXIGP1AWLOCK),
            .M_AWCACHE (MAXIGP1AWCACHE),
            .M_AWPROT  (MAXIGP1AWPROT),
            .M_AWVALID (MAXIGP1AWVALID),
            .M_AWREADY (MAXIGP1AWREADY),
            // Write Data Channel Signals.
            .M_WDATA   (MAXIGP1WDATA),
            .M_WSTRB   (MAXIGP1WSTRB), 
            .M_WLAST   (MAXIGP1WLAST), 
            .M_WVALID  (MAXIGP1WVALID),
            .M_WREADY  (MAXIGP1WREADY),
            // Write Response Channel Signals.
            .M_BID     (MAXIGP1BID),
            .M_BRESP   (MAXIGP1BRESP),
            .M_BVALID  (MAXIGP1BVALID),
            .M_BREADY  (MAXIGP1BREADY),
            // Read Address Channel Signals.
            .M_ARID    (MAXIGP1ARID),
            .M_ARADDR  (MAXIGP1ARADDR),
            .M_ARLEN   (MAXIGP1ARLEN),
            .M_ARSIZE  (MAXIGP1ARSIZE),
            .M_ARBURST (MAXIGP1ARBURST),
            .M_ARLOCK  (MAXIGP1ARLOCK),
            .M_ARCACHE (MAXIGP1ARCACHE),
            .M_ARPROT  (MAXIGP1ARPROT),
            .M_ARVALID (MAXIGP1ARVALID),
            .M_ARREADY (MAXIGP1ARREADY),
            // Read Data Channel Signals.
            .M_RID     (MAXIGP1RID),
            .M_RDATA   (MAXIGP1RDATA),
            .M_RRESP   (MAXIGP1RRESP),
            .M_RLAST   (MAXIGP1RLAST),
            .M_RVALID  (MAXIGP1RVALID),
            .M_RREADY  (MAXIGP1RREADY),
            // Side band signals 
            .M_AWQOS   (MAXIGP1AWQOS),
            .M_ARQOS   (MAXIGP1ARQOS),
            .M_AWREGION(),
            .M_ARREGION(),
            .M_AWUSER  (MAXIGP1AWUSER),
            .M_WUSER   (),
            .M_BUSER   (0),
            .M_ARUSER  (MAXIGP1ARUSER),
            .M_RUSER   (0)
            ); 
 
 /* AXI -Master GP2 */
  zynq_ultra_ps_e_vip_v1_0_6_axi_master #(C_USE_M_AXI_GP2, // enable
               axi_mgp2_name,// name
               C_M_AXI_GP2_DATA_WIDTH, /// Data Width
               addr_width, /// Address width
               axi_mgp_id_width,  //// ID Width
			   axi_mgp_awuser_width,
               axi_mgp_aruser_width,
               1,//axi_mgp_ruser_width,
			   1,//axi_mgp_wuser_width,
               1,//axi_mgp_buser_width,
               axi_mgp_outstanding,  //// Outstanding transactions
               axi_mst_excl_support, // EXCL Access Support
               axi_mgp_wr_id, //WR_ID
               axi_mgp_rd_id, //RD_ID
			   1) //RD_ID
  // M_AXI_GP2(.M_RESETN  (net_m_axi_gp2_rstn),
  M_AXI_HPM0_LPD(.M_RESETN  (net_m_axi_gp2_rstn),
            .M_ACLK    (MAXIGP2ACLK),
            // Write Address Channel
            .M_AWID    (MAXIGP2AWID),
            .M_AWADDR  (MAXIGP2AWADDR),
            .M_AWLEN   (MAXIGP2AWLEN),
            .M_AWSIZE  (MAXIGP2AWSIZE),
            .M_AWBURST (MAXIGP2AWBURST),
            .M_AWLOCK  (MAXIGP2AWLOCK),
            .M_AWCACHE (MAXIGP2AWCACHE),
            .M_AWPROT  (MAXIGP2AWPROT),
            .M_AWVALID (MAXIGP2AWVALID),
            .M_AWREADY (MAXIGP2AWREADY),
            // Write Data Channel Signals.
            .M_WDATA   (MAXIGP2WDATA),
            .M_WSTRB   (MAXIGP2WSTRB), 
            .M_WLAST   (MAXIGP2WLAST), 
            .M_WVALID  (MAXIGP2WVALID),
            .M_WREADY  (MAXIGP2WREADY),
            // Write Response Channel Signals.
            .M_BID     (MAXIGP2BID),
            .M_BRESP   (MAXIGP2BRESP),
            .M_BVALID  (MAXIGP2BVALID),
            .M_BREADY  (MAXIGP2BREADY),
            // Read Address Channel Signals.
            .M_ARID    (MAXIGP2ARID),
            .M_ARADDR  (MAXIGP2ARADDR),
            .M_ARLEN   (MAXIGP2ARLEN),
            .M_ARSIZE  (MAXIGP2ARSIZE),
            .M_ARBURST (MAXIGP2ARBURST),
            .M_ARLOCK  (MAXIGP2ARLOCK),
            .M_ARCACHE (MAXIGP2ARCACHE),
            .M_ARPROT  (MAXIGP2ARPROT),
            .M_ARVALID (MAXIGP2ARVALID),
            .M_ARREADY (MAXIGP2ARREADY),
            // Read Data Channel Signals.
            .M_RID     (MAXIGP2RID),
            .M_RDATA   (MAXIGP2RDATA),
            .M_RRESP   (MAXIGP2RRESP),
            .M_RLAST   (MAXIGP2RLAST),
            .M_RVALID  (MAXIGP2RVALID),
            .M_RREADY  (MAXIGP2RREADY),
            // Side band signals 
            .M_AWQOS   (MAXIGP2AWQOS),
            .M_ARQOS   (MAXIGP2ARQOS),
            .M_AWREGION(),
            .M_ARREGION(),
            .M_AWUSER  (MAXIGP2AWUSER),
            .M_WUSER   (),
            .M_BUSER   (0),
            .M_ARUSER  (MAXIGP2ARUSER),
            .M_RUSER   (0)
            ); 
 
