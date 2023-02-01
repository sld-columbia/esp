// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

import bsg_dmc_pkg::*;

module bsg_dmc_wrap
  #(
    parameter ui_addr_width_p    = 28,
    parameter ui_data_width_p    = 64,
    parameter ui_burst_length_p  = 1,
    parameter dq_data_width_p    = 32,
    parameter cmd_afifo_depth_p  = 4,
    parameter cmd_sfifo_depth_p  = 4
    )
   (
    // User interface input signals
    input logic [ui_addr_width_p-1:0]       app_addr,
    input logic [2:0]                       app_cmd,
    input logic                             app_en,
    input logic [ui_data_width_p-1:0]       app_wdf_data,
    input logic                             app_wdf_end,
    input logic [(ui_data_width_p>>3)-1:0]  app_wdf_mask,
    input logic                             app_wdf_wren,
    // User interface output signals
    output logic [ui_data_width_p-1:0]      app_rd_data,
    output logic                            app_rd_data_end,
    output logic                            app_rd_data_valid,
    output logic                            app_rdy,
    output logic                            app_wdf_rdy,
    // Status signal
    output logic                            init_calib_complete,
    // Tile clock == DDR clock (200 MHz rotated 90 degrees) and tile synchronous reset
    input logic                             ui_clk_i,
    input logic                             ui_reset_i,
    // PHY 2x clock (400 MHz) and 1x clock (200 MHz) with synchronous reset
    input logic                             dfi_clk_2x_i,
    input logic                             dfi_clk_1x_i,
    input logic                             dfi_reset_i,
    // // Temperature monitor
    // output logic [11:0]                 device_temp_o,
    // Command and Address interface
    output logic                            ddr_ck_p_o,
    output logic                            ddr_ck_n_o,
    output logic                            ddr_cke_o,
    output logic [2:0]                      ddr_ba_o,
    output logic [15:0]                     ddr_addr_o,
    output logic                            ddr_cs_n_o,
    output logic                            ddr_ras_n_o,
    output logic                            ddr_cas_n_o,
    output logic                            ddr_we_n_o,
    output logic                            ddr_reset_n_o,
    output logic                            ddr_odt_o,
    // Data interface
    output logic [(dq_data_width_p>>3)-1:0] ddr_dm_oen_o,
    output logic [(dq_data_width_p>>3)-1:0] ddr_dm_o,
    output logic [(dq_data_width_p>>3)-1:0] ddr_dqs_p_oen_o,
    output logic [(dq_data_width_p>>3)-1:0] ddr_dqs_p_ien_o,
    output logic [(dq_data_width_p>>3)-1:0] ddr_dqs_p_o,
    input logic [(dq_data_width_p>>3)-1:0]  ddr_dqs_p_i,
    output logic [(dq_data_width_p>>3)-1:0] ddr_dqs_n_oen_o,
    output logic [(dq_data_width_p>>3)-1:0] ddr_dqs_n_ien_o,
    output logic [(dq_data_width_p>>3)-1:0] ddr_dqs_n_o,
    input logic [(dq_data_width_p>>3)-1:0]  ddr_dqs_n_i,
    output logic [dq_data_width_p-1:0]      ddr_dq_oen_o,
    output logic [dq_data_width_p-1:0]      ddr_dq_o,
    input logic [dq_data_width_p-1:0]       ddr_dq_i,
    // Delay line configuration
    input logic [3:0]                       delay_sel_i,
    // DDR controller configuration
    input logic [12:0]                      trefi_i,
    input logic [3:0]                       tmrd_i,
    input logic [3:0]                       trfc_i,
    input logic [3:0]                       trc_i,
    input logic [3:0]                       trp_i,
    input logic [3:0]                       tras_i,
    input logic [3:0]                       trrd_i,
    input logic [3:0]                       trcd_i,
    input logic [3:0]                       twr_i,
    input logic [3:0]                       twtr_i,
    input logic [3:0]                       trtp_i,
    input logic [3:0]                       tcas_i,
    input logic [3:0]                       col_width_i,
    input logic [3:0]                       row_width_i,
    input logic [1:0]                       bank_width_i,
    input logic [5:0]                       bank_pos_i,
    input logic [2:0]                       dqs_sel_cal_i,
    input logic [15:0]                      init_cycles_i
    );

   localparam burst_data_width_lp = ui_data_width_p * ui_burst_length_p;
   localparam dfi_data_width_lp  = dq_data_width_p << 1;
   localparam dfi_mask_width_lp  = (dq_data_width_p >> 3) << 1;

   genvar 				    i;

   // app_cmd data type conversion
   app_cmd_e				    app_cmd_int;

   // DFI 1.0 compatible
   wire [2:0] 				    dfi_bank;
   wire [15:0] 				    dfi_address;
   wire 				    dfi_cke;
   wire 				    dfi_cs_n;
   wire 				    dfi_ras_n;
   wire 				    dfi_cas_n;
   wire 				    dfi_we_n;
   wire 				    dfi_reset_n;
   wire 				    dfi_odt;
   wire 				    dfi_wrdata_en;
   wire [dfi_data_width_lp-1:0] 	    dfi_wrdata;
   wire [dfi_mask_width_lp-1:0] 	    dfi_wrdata_mask;
   wire 				    dfi_rddata_en;
   wire [dfi_data_width_lp-1:0] 	    dfi_rddata;
   wire 				    dfi_rddata_valid;
   wire [(dq_data_width_p>>3)-1:0] 	    dqs_p_li;

   generate
      for (i = 0; i < (dq_data_width_p>>3); i++) begin : dqs_delay_gen
	 // Delay line (GF12 only)
	 DELAY_CELL_GF12_C14 dly_line_i
	       (
		.DATA_IN(ddr_dqs_p_i[i]),
		.DATA_OUT(dqs_p_li[i]),
		.SEL(delay_sel_i)
		);
      end;
   endgenerate

   always_comb begin
      case(app_cmd)
	3'b000 : app_cmd_int = WR;
	3'b001 : app_cmd_int = RD;
	3'b010 : app_cmd_int = WP;
	3'b011 : app_cmd_int = RP;
	default : app_cmd_int = RP;
      endcase
   end

   // Configuration
   bsg_dmc_s                        dmc_p;

   // DDR controller configuration
   assign dmc_p.trefi = {3'b000, trefi_i};
   assign dmc_p.tmrd = tmrd_i;
   assign dmc_p.trfc = trfc_i;
   assign dmc_p.trc = trc_i;
   assign dmc_p.trp = trp_i;
   assign dmc_p.tras = tras_i;
   assign dmc_p.trrd = trrd_i;
   assign dmc_p.trcd = trcd_i;
   assign dmc_p.twr = twr_i;
   assign dmc_p.twtr = twtr_i;
   assign dmc_p.trtp = trtp_i;
   assign dmc_p.tcas = tcas_i;
   assign dmc_p.col_width = col_width_i;
   assign dmc_p.row_width = row_width_i;
   assign dmc_p.bank_width = bank_width_i;
   assign dmc_p.bank_pos = bank_pos_i;
   assign dmc_p.dqs_sel_cal = dqs_sel_cal_i;
   assign dmc_p.init_cycles = init_cycles_i;


   // -- bdg_dmc controller and PHY instances
   bsg_dmc_controller #
     (.ui_addr_width_p       ( ui_addr_width_p       ),
      .ui_data_width_p       ( ui_data_width_p       ),
      .burst_data_width_p    ( burst_data_width_lp   ),
      .dfi_data_width_p      ( dfi_data_width_lp     ),
      .cmd_afifo_depth_p     ( cmd_afifo_depth_p     ),
      .cmd_sfifo_depth_p     ( cmd_sfifo_depth_p     ))
     controller
     // User interface clock and reset
     (.ui_clk_i              ( ui_clk_i              ),
      .ui_clk_sync_rst_i     ( ui_reset_i            ),
      // User interface signals
      .app_addr_i            ( app_addr              ),
      .app_cmd_i             ( app_cmd_int           ),
      .app_en_i              ( app_en                ),
      .app_rdy_o             ( app_rdy               ),
      .app_wdf_wren_i        ( app_wdf_wren          ),
      .app_wdf_data_i        ( app_wdf_data          ),
      .app_wdf_mask_i        ( app_wdf_mask          ),
      .app_wdf_end_i         ( app_wdf_end           ),
      .app_wdf_rdy_o         ( app_wdf_rdy           ),
      .app_rd_data_valid_o   ( app_rd_data_valid     ),
      .app_rd_data_o         ( app_rd_data           ),
      .app_rd_data_end_o     ( app_rd_data_end       ),
      .app_ref_req_i         ( 1'b0                  ),
      .app_ref_ack_o         (                       ),
      .app_zq_req_i          ( 1'b0                  ),
      .app_zq_ack_o          (                       ),
      .app_sr_req_i          ( 1'b0                  ),
      .app_sr_active_o       (                       ),
      // DDR PHY interface clock and reset
      .dfi_clk_i             ( dfi_clk_1x_i          ),
      .dfi_clk_sync_rst_i    ( dfi_reset_i           ),
      // DDR PHY interface signals
      .dfi_bank_o            ( dfi_bank              ),
      .dfi_address_o         ( dfi_address           ),
      .dfi_cke_o             ( dfi_cke               ),
      .dfi_cs_n_o            ( dfi_cs_n              ),
      .dfi_ras_n_o           ( dfi_ras_n             ),
      .dfi_cas_n_o           ( dfi_cas_n             ),
      .dfi_we_n_o            ( dfi_we_n              ),
      .dfi_reset_n_o         ( dfi_reset_n           ),
      .dfi_odt_o             ( dfi_odt               ),
      .dfi_wrdata_en_o       ( dfi_wrdata_en         ),
      .dfi_wrdata_o          ( dfi_wrdata            ),
      .dfi_wrdata_mask_o     ( dfi_wrdata_mask       ),
      .dfi_rddata_en_o       ( dfi_rddata_en         ),
      .dfi_rddata_i          ( dfi_rddata            ),
      .dfi_rddata_valid_i    ( dfi_rddata_valid      ),
      // Control and Status Registers
      .dmc_p_i               ( dmc_p                 ),
      //
      .init_calib_complete_o ( init_calib_complete   ));

   bsg_dmc_phy #(.dq_data_width_p(dq_data_width_p)) phy
     // DDR PHY interface clock and reset
     (.dfi_clk_1x_i        ( dfi_clk_1x_i        ),
      .dfi_clk_2x_i        ( dfi_clk_2x_i        ),
      .dfi_rst_i           ( dfi_reset_i         ),
      // DFI interface signals
      .dfi_bank_i          ( dfi_bank            ),
      .dfi_address_i       ( dfi_address         ),
      .dfi_cke_i           ( dfi_cke             ),
      .dfi_cs_n_i          ( dfi_cs_n            ),
      .dfi_ras_n_i         ( dfi_ras_n           ),
      .dfi_cas_n_i         ( dfi_cas_n           ),
      .dfi_we_n_i          ( dfi_we_n            ),
      .dfi_reset_n_i       ( dfi_reset_n         ),
      .dfi_odt_i           ( dfi_odt             ),
      .dfi_wrdata_en_i     ( dfi_wrdata_en       ),
      .dfi_wrdata_i        ( dfi_wrdata          ),
      .dfi_wrdata_mask_i   ( dfi_wrdata_mask     ),
      .dfi_rddata_en_i     ( dfi_rddata_en       ),
      .dfi_rddata_o        ( dfi_rddata          ),
      .dfi_rddata_valid_o  ( dfi_rddata_valid    ),
      // DDR interface signals
      .ck_p_o              ( ddr_ck_p_o          ),
      .ck_n_o              ( ddr_ck_n_o          ),
      .cke_o               ( ddr_cke_o           ),
      .ba_o                ( ddr_ba_o            ),
      .a_o                 ( ddr_addr_o          ),
      .cs_n_o              ( ddr_cs_n_o          ),
      .ras_n_o             ( ddr_ras_n_o         ),
      .cas_n_o             ( ddr_cas_n_o         ),
      .we_n_o              ( ddr_we_n_o          ),
      .reset_o             ( ddr_reset_n_o       ),
      .odt_o               ( ddr_odt_o           ),
      .dm_oe_n_o           ( ddr_dm_oen_o        ),
      .dm_o                ( ddr_dm_o            ),
      .dqs_p_oe_n_o        ( ddr_dqs_p_oen_o     ),
      .dqs_p_ie_n_o        ( ddr_dqs_p_ien_o     ),
      .dqs_p_o             ( ddr_dqs_p_o         ),
      .dqs_p_i             ( dqs_p_li            ),
      .dqs_n_oe_n_o        ( ddr_dqs_n_oen_o     ),
      .dqs_n_ie_n_o        ( ddr_dqs_n_ien_o     ),
      .dqs_n_o             ( ddr_dqs_n_o         ),
      .dqs_n_i             ( ~dqs_p_li           ),
      .dq_oe_n_o           ( ddr_dq_oen_o        ),
      .dq_o                ( ddr_dq_o            ),
      .dq_i                ( ddr_dq_i            ),
      // Control and Status Registers
      .dqs_sel_cal         ( dmc_p.dqs_sel_cal ));

endmodule
