/*****************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_axi_acp.sv
 *
 * Date : 2015-16
 *
 * Description : Connections for ACP port
 *
 *****************************************************************************/

/* AXI Slave ACP */
  zynq_ultra_ps_e_vip_v1_0_6_axi_slave_acp #( C_USE_S_AXI_ACP, // enable
               axi_acp_name, // name
               axi_acp_data_width, // data width
               addr_width, /// address width
               axi_acp_id_width, // ID width
			   axi_acp_awuser_width,
			   axi_acp_aruser_width,
               1,//axi_acp_ruser_width,
			   1,//axi_acp_wuser_width,
               1,//axi_acp_buser_width,
               axi_acp_outstanding, // outstanding transactions // 7 Reads and 3 Writes 
               axi_slv_excl_support, // Exclusive access support
               axi_acp_wr_outstanding,
               axi_acp_rd_outstanding,
			   1)
  S_AXI_ACP(.S_RESETN          (net_s_axi_acp_rstn),
            .S_ACLK            (SAXIACPACLK),
            // Write Address Channel
            .S_AWID            (SAXIACPAWID),
            .S_AWADDR          (SAXIACPAWADDR),
            .S_AWLEN           (SAXIACPAWLEN),
            .S_AWSIZE          (SAXIACPAWSIZE),
            .S_AWBURST         (SAXIACPAWBURST),
            .S_AWLOCK          (SAXIACPAWLOCK),
            .S_AWCACHE         (SAXIACPAWCACHE),
            .S_AWPROT          (SAXIACPAWPROT),
            .S_AWVALID         (SAXIACPAWVALID),
            .S_AWREADY         (SAXIACPAWREADY),
            // Write Data Channel Signals.
            .S_WDATA           (SAXIACPWDATA),
            .S_WSTRB           (SAXIACPWSTRB), 
            .S_WLAST           (SAXIACPWLAST), 
            .S_WVALID          (SAXIACPWVALID),
            .S_WREADY          (SAXIACPWREADY),
            // Write Response Channel Signals.
            .S_BID             (SAXIACPBID),
            .S_BRESP           (SAXIACPBRESP),
            .S_BVALID          (SAXIACPBVALID),
            .S_BREADY          (SAXIACPBREADY),
            // Read Address Channel Signals.
            .S_ARID            (SAXIACPARID),
            .S_ARADDR          (SAXIACPARADDR),
            .S_ARLEN           (SAXIACPARLEN),
            .S_ARSIZE          (SAXIACPARSIZE),
            .S_ARBURST         (SAXIACPARBURST),
            .S_ARLOCK          (SAXIACPARLOCK),
            .S_ARCACHE         (SAXIACPARCACHE),
            .S_ARPROT          (SAXIACPARPROT),
            .S_ARVALID         (SAXIACPARVALID),
            .S_ARREADY         (SAXIACPARREADY),
            // Read Data Channel Signals.
            .S_RID             (SAXIACPRID),
            .S_RDATA           (SAXIACPRDATA),
            .S_RRESP           (SAXIACPRRESP),
            .S_RLAST           (SAXIACPRLAST),
            .S_RVALID          (SAXIACPRVALID),
            .S_RREADY          (SAXIACPRREADY),
            // Side band signals 
            .S_AWQOS           (SAXIACPAWQOS),
            .S_ARQOS           (SAXIACPARQOS),            // Side band signals 
            .S_AWREGION        (0),
            .S_ARREGION        (0),
            .S_AWUSER          (SAXIACPAWUSER),
            .S_WUSER           (0),
            .S_BUSER           (),
            .S_ARUSER          (SAXIACPARUSER),
            .S_RUSER           (),
            .SW_CLK            (net_sw_clk),
/* This goes to DDR, OCM and REG*/
            .WR_DATA_ACK_DDR   (ddr_wr_ack_acp),
            .WR_DATA_ACK_OCM   (ocm_wr_ack_acp),
            .WR_DATA           (net_wr_data_acp), 
			.WR_DATA_STRB      (net_wr_strb_acp),
            .WR_ADDR           (net_wr_addr_acp), 
            .WR_BYTES          (net_wr_bytes_acp), 
            .WR_DATA_VALID_DDR (ddr_wr_dv_acp), 
            .WR_DATA_VALID_OCM (ocm_wr_dv_acp), 
            .WR_QOS            (net_wr_qos_acp),
            .RD_REQ_DDR        (ddr_rd_req_acp),
            .RD_REQ_OCM        (ocm_rd_req_acp),
            .RD_REQ_REG        (reg_rd_req_acp),
            .RD_ADDR           (net_rd_addr_acp),
            .RD_DATA_DDR       (ddr_rd_data_acp),
            .RD_DATA_OCM       (ocm_rd_data_acp),
            .RD_DATA_REG       (reg_rd_data_acp),
            .RD_BYTES          (net_rd_bytes_acp),
            .RD_DATA_VALID_DDR (ddr_rd_dv_acp),
            .RD_DATA_VALID_OCM (ocm_rd_dv_acp),
            .RD_DATA_VALID_REG (reg_rd_dv_acp),
            .RD_QOS            (net_rd_qos_acp)

);
