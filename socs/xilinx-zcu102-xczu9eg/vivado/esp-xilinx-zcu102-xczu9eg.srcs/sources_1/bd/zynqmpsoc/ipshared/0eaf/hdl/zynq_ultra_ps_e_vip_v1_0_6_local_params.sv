 /********************************************************************
 * File : zynq_ultra_scale!_ps_e_vip_v1_0_local_params.sv
 *
 * Date : 2015-16
 *
 * Description : Parameters used in Zynq MPSOC BFM
 *
 *****************************************************************************/

function automatic integer clogb2;
  input [31:0] value;
  begin
      value = value - 1;
      for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
          value = value >> 1;
      end
  end
endfunction

/////////////////////////////////////////////////Zynq MPSoC BFM parameters///////////////////////////
parameter addr_width = 40;   // maximum address width
parameter data_width = 32;   // maximum data width.
parameter axi_mgp_data_width = 32;
parameter axi_slv_excl_support = 0; // For Slave  ports EXCL access is not supported
parameter axi_mst_excl_support = 1; // For Master ports EXCL access is supported
/* for ACP slave ports*/
parameter axi_acp_name  = "S_AXI_ACP";
parameter axi_acp_data_width = 128;
parameter axi_acp_id_width   = 5;
parameter axi_acp_rd_outstanding = 7;
parameter axi_acp_wr_outstanding = 3;
parameter axi_acp_outstanding = axi_acp_rd_outstanding + axi_acp_wr_outstanding;
parameter axi_acp_awuser_width   = 2;
parameter axi_acp_aruser_width   = 2;
parameter axi_acp_ruser_width    = 0;
parameter axi_acp_wuser_width    = 0;
parameter axi_acp_buser_width    = 0;
parameter axi_acp_region_width   = 0;

/* for ACE slave ports*/
parameter axi_ace_name  = "S_AXI_ACE";
parameter axi_ace_data_width = 128;
parameter axi_ace_id_width   = 6;
parameter axi_ace_rd_outstanding = 7;
parameter axi_ace_wr_outstanding = 3;
parameter axi_ace_outstanding = axi_ace_rd_outstanding + axi_ace_wr_outstanding;
parameter axi_ace_awuser_width   = 15;
parameter axi_ace_aruser_width   = 15;
parameter axi_ace_ruser_width    = 1;
parameter axi_ace_wuser_width    = 1;
parameter axi_ace_buser_width    = 1;
parameter axi_ace_region_width   = 4;

/* for GP slave ports*/
parameter axi_sgp0_name  = "S_AXI_GP0";
parameter axi_sgp1_name  = "S_AXI_GP1";
parameter axi_sgp2_name  = "S_AXI_GP2";
parameter axi_sgp3_name  = "S_AXI_GP3";
parameter axi_sgp4_name  = "S_AXI_GP4";
parameter axi_sgp5_name  = "S_AXI_GP5";
parameter axi_sgp6_name  = "S_AXI_GP6";
parameter axi_sgp_id_width   = 6;
parameter axi_sgp_awuser_width   = 1;
parameter axi_sgp_aruser_width   = 1;
parameter axi_sgp_ruser_width    = 0;
parameter axi_sgp_wuser_width    = 0;
parameter axi_sgp_buser_width    = 0;
parameter axi_sgp_region_width   = 0;
parameter axi_sgp_rd_outstanding = 8;
parameter axi_sgp_wr_outstanding = 8;
parameter axi_sgp_outstanding = axi_sgp_rd_outstanding + axi_sgp_wr_outstanding;

/* for GP master ports*/
parameter axi_mgp0_name  = "M_AXI_GP0";
parameter axi_mgp1_name  = "M_AXI_GP1";
parameter axi_mgp2_name  = "M_AXI_GP2";
parameter axi_mgp_id_width   = 16;
parameter axi_mgp_outstanding = 8;
parameter axi_mgp_wr_id = 16'h0800;
parameter axi_mgp_rd_id = 16'h0900;
parameter axi_mgp_awuser_width   = 1;
parameter axi_mgp_aruser_width   = 1;
parameter axi_mgp_ruser_width    = 0;
parameter axi_mgp_wuser_width    = 0;
parameter axi_mgp_buser_width    = 0;
parameter axi_mgp_region_width   = 0;

/* local */ 
parameter m_axi_gp0_baseaddr      = 40'h0_A000_0000;
parameter m_axi_gp0_highaddr      = 40'h0_AFFF_FFFF;
parameter m_axi_gp0_mid_baseaddr  = 40'h4_0000_0000;
parameter m_axi_gp0_mid_highaddr  = 40'h4_FFFF_FFFF;
parameter m_axi_gp0_high_baseaddr = 40'h10_0000_0000;
parameter m_axi_gp0_high_highaddr = 40'h47_FFFF_FFFF;

parameter m_axi_gp1_baseaddr      = 40'h0_B000_0000;
parameter m_axi_gp1_highaddr      = 40'h0_BFFF_FFFF;
parameter m_axi_gp1_mid_baseaddr  = 40'h5_0000_0000;
parameter m_axi_gp1_mid_highaddr  = 40'h5_FFFF_FFFF;
parameter m_axi_gp1_high_baseaddr = 40'h48_0000_0000;
parameter m_axi_gp1_high_highaddr = 40'h7F_FFFF_FFFF;

parameter m_axi_gp2_baseaddr = 40'h0_8000_0000;
parameter m_axi_gp2_highaddr = 40'h0_9FFF_FFFF;

parameter max_chars  = 128;  // max characters for file name
parameter mem_width  = data_width/8; /// memory width in bytes
parameter shft_addr_bits = clogb2(mem_width); /// Address to be right shifted
parameter int_width  = 32; //integre width

/* for internal read/write APIs used for data transfers */
parameter max_burst_len   = 256;  /// maximum brst length on axi 
parameter max_data_width  = 128; // maximum data width for internal AXI bursts 
parameter max_burst_bits  = (max_data_width * max_burst_len); // maximum data width for internal AXI bursts 
parameter max_burst_bytes = (max_burst_bits)/8;                // maximum data bytes in each transfer 
parameter max_burst_bytes_width = clogb2(max_burst_bytes); // maximum data width for internal AXI bursts 
parameter all_strb_valid = 2048'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

parameter max_registers   = 32;
parameter max_regs_width  = clogb2(max_registers);

parameter REG_MEM = 2'b00, DDR_MEM = 2'b01, OCM_MEM = 2'b10, INVALID_MEM_TYPE = 2'b11; 

parameter ALL_RANDOM= 2'b00;
parameter ALL_ZEROS = 2'b01;
parameter ALL_ONES  = 2'b10;

/* AXI transfer types */
parameter AXI_FIXED = 2'b00;
parameter AXI_INCR  = 2'b01;
parameter AXI_WRAP  = 2'b10;

/* Exclusive Access */
parameter AXI_NRML  = 2'b00;
parameter AXI_EXCL  = 2'b01;
parameter AXI_LOCK  = 2'b10;

/* AXI Response types */
parameter AXI_OK = 2'b00;
parameter AXI_EXCL_OK  = 2'b01;
parameter AXI_SLV_ERR  = 2'b10;
parameter AXI_DEC_ERR  = 2'b11;

/* Display */
parameter DISP_INFO = "*ZYNQ_MPSoC_BFM_INFO";
parameter DISP_WARN = "*ZYNQ_MPSoC_BFM_WARNING";
parameter DISP_ERR  = "*ZYNQ_MPSoC_BFM_ERROR";
parameter DISP_INT_INFO = "ZYNQ_MPSoC_BFM_INT_INFO";

/* Latency types */
parameter BEST_CASE  = 0;
parameter AVG_CASE   = 1;
parameter WORST_CASE = 2;
parameter RANDOM_CASE  = 3;

/* Latency Parameters ACP  */
parameter acp_wr_min   =  21;
parameter acp_wr_avg   =  16;
parameter acp_wr_max   =  27;
parameter acp_rd_min   =  34;
parameter acp_rd_avg   =  125;
parameter acp_rd_max   =  130;

/* Latency Parameters GP  */
  parameter gp_wr_min   =  21;
  parameter gp_wr_avg   =  16;
  parameter gp_wr_max   =  46;
  parameter gp_rd_min   =  38;
  parameter gp_rd_avg   =  125;
  parameter gp_rd_max   =  130; 

/* ID VALID and INVALID */
parameter secure_access_enabled = 0;
parameter id_invalid = 0;
parameter id_valid = 1;

parameter ddr_start_addr = 40'h0_0000_0000;
parameter ddr_end_addr   = 40'h0_7FFF_FFFF;
parameter high_ddr_start_addr = 40'h8_0000_0000;

parameter ocm_start_addr = 40'h0_FFFC_0000;
parameter ocm_end_addr   = 40'h0_FFFF_FFFF;

parameter reg_start_addr = 40'h0_F900_0000;
parameter reg_end_addr   = 40'h0_FFF0_0000;

/* for Master port APIs and AXI protocol related signal widths*/
parameter axi_burst_len  = 256;
parameter axi_len_width  = 8;
parameter axi_size_width = 3;
parameter axi_brst_type_width = 2;
parameter axi_lock_width = 1;
parameter axi_cache_width = 4;
parameter axi_prot_width = 3;
parameter axi_rsp_width = 2;
parameter axi_qos_width  = 4;
parameter axi_max_mdata_width  = 128;
parameter max_transfer_bytes = 256; // For Master APIs.
parameter max_transfer_bytes_width = clogb2(max_transfer_bytes); // For Master APIs.

/* Interrupt bits supported */
parameter irq_width = 16;

