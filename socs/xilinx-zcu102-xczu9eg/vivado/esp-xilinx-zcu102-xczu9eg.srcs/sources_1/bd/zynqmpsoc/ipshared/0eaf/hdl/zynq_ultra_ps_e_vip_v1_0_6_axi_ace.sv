/******************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_axi_ace.sv
 *
 * Date : 2015-16
 *
 * Description : Connections for ACE port
 *
 *****************************************************************************/

/* AXI Slave ACE */
  zynq_ultra_ps_e_vip_v1_0_6_axi_slave #( C_USE_S_AXI_ACE, // enable
               axi_ace_name, // name
               axi_ace_data_width, // data width
               addr_width, /// address width
               axi_ace_id_width, // ID width
               axi_ace_awuser_width,
               axi_ace_aruser_width,
               axi_ace_ruser_width,
			   axi_ace_wuser_width,
               axi_ace_buser_width,
               axi_ace_outstanding, // outstanding transactions // 7 Reads and 3 Writes 
               axi_slv_excl_support, // Exclusive access support
               axi_ace_wr_outstanding,
               axi_ace_rd_outstanding,
			   axi_ace_region_width)
  S_AXI_ACE (.S_RESETN           (net_s_axi_ace_rstn),
            .S_ACLK             (PLACECLK),
            // Write Address Channel
            .S_AWID             (SACEFPDAWID),
            .S_AWADDR           (SACEFPDAWADDR[39:0]),
            .S_AWLEN            (SACEFPDAWLEN),
            .S_AWSIZE           (SACEFPDAWSIZE),
            .S_AWBURST          (SACEFPDAWBURST),
            .S_AWLOCK           (SACEFPDAWLOCK),
            .S_AWCACHE          (SACEFPDAWCACHE),
            .S_AWPROT           (SACEFPDAWPROT),
            .S_AWVALID          (SACEFPDAWVALID),
            .S_AWREADY          (SACEFPDAWREADY),
            // Write Data Channel Signals.
            .S_WDATA            (SACEFPDWDATA),
            .S_WSTRB            (SACEFPDWSTRB), 
            .S_WLAST            (SACEFPDWLAST), 
            .S_WVALID           (SACEFPDWVALID),
            .S_WREADY           (SACEFPDWREADY),
            // Write Response Channel Signals.
            .S_BID              (SACEFPDBID),
            .S_BRESP            (SACEFPDBRESP),
            .S_BVALID           (SACEFPDBVALID),
            .S_BREADY           (SACEFPDBREADY),
            // Read Address Channel Signals.
            .S_ARID             (SACEFPDARID),
            .S_ARADDR           (SACEFPDARADDR[39:0]),
            .S_ARLEN            (SACEFPDARLEN),
            .S_ARSIZE           (SACEFPDARSIZE),
            .S_ARBURST          (SACEFPDARBURST),
            .S_ARLOCK           (SACEFPDARLOCK),
            .S_ARCACHE          (SACEFPDARCACHE),
            .S_ARPROT           (SACEFPDARPROT),
            .S_ARVALID          (SACEFPDARVALID),
            .S_ARREADY          (SACEFPDARREADY),
            // Read Data Channel Signals.
            .S_RID              (SACEFPDRID),
            .S_RDATA            (SACEFPDRDATA),
            .S_RRESP            (SACEFPDRRESP),
            .S_RLAST            (SACEFPDRLAST),
            .S_RVALID           (SACEFPDRVALID),
            .S_RREADY           (SACEFPDRREADY),
            // Side band signals 
            .S_AWQOS            (SACEFPDAWQOS),
            .S_ARQOS            (SACEFPDARQOS),
            .S_AWREGION         (SACEFPDAWREGION),
            .S_ARREGION         (SACEFPDARREGION),
            .S_AWUSER           (SACEFPDAWUSER),
            .S_WUSER            (SACEFPDWUSER),
            .S_BUSER            (SACEFPDBUSER),
            .S_ARUSER           (SACEFPDARUSER),
            .S_RUSER            (SACEFPDRUSER),
			.SW_CLK             (net_sw_clk),
/* This goes to DDR, OCM and REG*/
            .WR_DATA_ACK_DDR    (ddr_wr_ack_ace),
            .WR_DATA_ACK_OCM    (ocm_wr_ack_ace),
            .WR_DATA            (net_wr_data_ace), 
			.WR_DATA_STRB       (net_wr_strb_ace),
            .WR_ADDR            (net_wr_addr_ace), 
            .WR_BYTES           (net_wr_bytes_ace), 
            .WR_DATA_VALID_DDR  (ddr_wr_dv_ace), 
            .WR_DATA_VALID_OCM  (ocm_wr_dv_ace), 
            .WR_QOS             (net_wr_qos_ace),
            .RD_REQ_DDR         (ddr_rd_req_ace),
            .RD_REQ_OCM         (ocm_rd_req_ace),
            .RD_REQ_REG         (reg_rd_req_ace),
            .RD_ADDR            (net_rd_addr_ace),
            .RD_DATA_DDR        (ddr_rd_data_ace),
            .RD_DATA_OCM        (ocm_rd_data_ace),
            .RD_DATA_REG        (reg_rd_data_ace),
            .RD_BYTES           (net_rd_bytes_ace),
            .RD_DATA_VALID_DDR  (ddr_rd_dv_ace),
            .RD_DATA_VALID_OCM  (ocm_rd_dv_ace),
            .RD_DATA_VALID_REG  (reg_rd_dv_ace),
            .RD_QOS             (net_rd_qos_ace)
);
