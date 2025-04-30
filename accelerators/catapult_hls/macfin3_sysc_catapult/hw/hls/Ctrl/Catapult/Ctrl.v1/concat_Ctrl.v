
//------> ./Ctrl_ccs_ctrl_in_buf_wait_v4.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
// Change History:
//    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
//                 Fix bug in that behavior.
//    2019-01-04 - Fixed bug 54073 - rdy signal should not be asserted during
//                 reset
//    2018-11-19 - Improved code coverage for is_idle
//    2018-08-22 - Added is_idle to interface (as compare to
//                 ccs_ctrl_in_buf_wait_v2)
//------------------------------------------------------------------------------


module esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 (clk, en, arst, srst, irdy, ivld, idat, vld, rdy, dat, is_idle);

    parameter integer rscid   = 1;
    parameter integer width   = 8;
    parameter integer ph_clk  = 1;
    parameter integer ph_en   = 1;
    parameter integer ph_arst = 1;
    parameter integer ph_srst = 1;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    output             rdy;
    input              vld;
    input  [width-1:0] dat;
    input              irdy;
    output             ivld;
    output [width-1:0] idat;
    output             is_idle;

    wire               rdy_int;
    wire               vld_int;
    reg                filled;
    wire               filled_next;
    wire               lbuf;
    reg    [width-1:0] abuf;
    reg                hs_init;

    assign rdy_int = ~filled | irdy;
    assign rdy = rdy_int & hs_init;
    assign vld_int = vld & hs_init;

    assign ivld = filled_next;
    assign idat = abuf;

    assign lbuf = vld_int & rdy_int;
    assign filled_next = vld_int | (filled & ~irdy);

    assign is_idle = ~lbuf & (filled ~^ filled_next) & hs_init;

    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk == 1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    else if (ph_arst == 0 && ph_clk == 0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    endgenerate

`ifdef RDY_ASRT
    generate
    if (ph_clk==1)
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) (srst==ph_srst) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(posedge clk) (arst==ph_arst) |-> (rdy==0);
       endproperty
       a2: assert property(rdyAsrtASync);

    end else if (ph_clk==0)
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(negedge clk) (arst==ph_arst) |-> (rdy==0);
       endproperty
       a2: assert property(rdyAsrtASync);
    end
    endgenerate

`endif

endmodule



//------> ./Ctrl_ccs_out_buf_wait_v5.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_DUMMY_ccs_out_buf_wait_v5 (clk, en, arst, srst, ivld, irdy, idat, rdy, vld, dat, is_idle);

    parameter integer  rscid   = 1;
    parameter integer  width   = 8;
    parameter integer  ph_clk  = 1;
    parameter integer  ph_en   = 1;
    parameter integer  ph_arst = 1;
    parameter integer  ph_srst = 1;
    parameter integer  rst_val = 0;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    output             irdy;
    input              ivld;
    input  [width-1:0] idat;
    input              rdy;
    output             vld;
    output [width-1:0] dat;
    output             is_idle;

    reg                filled;
    wire               filled_next;
    wire               lbuf;
    reg    [width-1:0] abuf;

    assign irdy = ~filled_next;

    assign vld = filled | ivld;
    assign dat = filled ? abuf : idat;

    assign lbuf = ivld & ~filled & ~rdy;
    assign filled_next = filled ? ~rdy : lbuf;

    assign is_idle = ~lbuf & (filled ~^ filled_next);

    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk == 1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    else if (ph_arst == 0 && ph_clk == 0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    endgenerate
endmodule

//------> ./Ctrl_Connections_conn_sync_chan_sync_out_ccs_in_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module esp_acc_DUMMY_esp_acc_DUMMY_ccs_in_v1 (idat, dat);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  input  [width-1:0] dat;

  wire   [width-1:0] idat;

  assign idat = dat;

endmodule


//------> ./Ctrl_Connections_conn_sync_chan_sync_out_ccs_sync_out_vld_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_DUMMY_esp_acc_DUMMY_ccs_sync_out_vld_v1 (vld, ivld);
  parameter integer rscid = 1;

  input  ivld;
  output vld;

  wire   vld;

  assign vld = ivld;
endmodule

//------> ./Ctrl_Connections_conn_sync_chan_sync_out.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2024.2/1130128 Production Release
//  HLS Date:       Mon Aug 26 21:59:12 PDT 2024
//
//  Generated by:   gtombesi@corsica
//  Generated date: Wed Apr 30 13:21:37 2025
// ----------------------------------------------------------------------

//
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Connections_conn_sync_chan_sync_out_core
// ------------------------------------------------------------------


module esp_acc_DUMMY_esp_acc_DUMMY_Connections_conn_sync_chan_sync_out_core (
  this_vld, this_rdy, ccs_ccore_start_rsc_dat, ccs_ccore_done_sync_vld, ccs_MIO_clk,
      ccs_MIO_arst
);
  output this_vld;
  reg this_vld;
  input this_rdy;
  input ccs_ccore_start_rsc_dat;
  output ccs_ccore_done_sync_vld;
  input ccs_MIO_clk;
  input ccs_MIO_arst;


  // Interconnect Declarations
  wire ccs_ccore_start_rsci_idat;
  reg io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1;
  wire or_3_cse;
  wire this_vld_mx0c1;


  // Interconnect Declarations for Component Instantiations
  wire  nl_ccs_ccore_done_synci_ivld;
  assign nl_ccs_ccore_done_synci_ivld = io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1
      & this_rdy;
  esp_acc_DUMMY_esp_acc_DUMMY_ccs_in_v1 #(.rscid(32'sd101),
  .width(32'sd1)) ccs_ccore_start_rsci (
      .dat(ccs_ccore_start_rsc_dat),
      .idat(ccs_ccore_start_rsci_idat)
    );
  esp_acc_DUMMY_esp_acc_DUMMY_ccs_sync_out_vld_v1 #(.rscid(32'sd103)) ccs_ccore_done_synci (
      .vld(ccs_ccore_done_sync_vld),
      .ivld(nl_ccs_ccore_done_synci_ivld)
    );
  assign or_3_cse = ccs_ccore_start_rsci_idat | (io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1
      & (~ this_rdy));
  assign this_vld_mx0c1 = io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1 & this_rdy
      & (~ ccs_ccore_start_rsci_idat);
  always @(posedge ccs_MIO_clk or negedge ccs_MIO_arst) begin
    if ( ~ ccs_MIO_arst ) begin
      this_vld <= 1'b0;
    end
    else if ( or_3_cse | this_vld_mx0c1 ) begin
      this_vld <= ~ this_vld_mx0c1;
    end
  end
  always @(posedge ccs_MIO_clk or negedge ccs_MIO_arst) begin
    if ( ~ ccs_MIO_arst ) begin
      io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1 <= 1'b0;
    end
    else begin
      io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1 <= or_3_cse;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    Connections_conn_sync_chan_sync_out
// ------------------------------------------------------------------


module esp_acc_DUMMY_Connections_conn_sync_chan_sync_out (
  this_vld, this_rdy, ccs_ccore_start_rsc_dat, ccs_ccore_done_sync_vld, ccs_MIO_clk,
      ccs_MIO_arst
);
  output this_vld;
  input this_rdy;
  input ccs_ccore_start_rsc_dat;
  output ccs_ccore_done_sync_vld;
  input ccs_MIO_clk;
  input ccs_MIO_arst;



  // Interconnect Declarations for Component Instantiations
  esp_acc_DUMMY_esp_acc_DUMMY_Connections_conn_sync_chan_sync_out_core Connections_conn_sync_chan_sync_out_core_inst
      (
      .this_vld(this_vld),
      .this_rdy(this_rdy),
      .ccs_ccore_start_rsc_dat(ccs_ccore_start_rsc_dat),
      .ccs_ccore_done_sync_vld(ccs_ccore_done_sync_vld),
      .ccs_MIO_clk(ccs_MIO_clk),
      .ccs_MIO_arst(ccs_MIO_arst)
    );
endmodule




//------> ./Ctrl_Connections_conn_sync_chan_sync_in_ccs_in_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module esp_acc_DUMMY_esp_acc_DUMMY_ccs_in_v1 (idat, dat);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  input  [width-1:0] dat;

  wire   [width-1:0] idat;

  assign idat = dat;

endmodule


//------> ./Ctrl_Connections_conn_sync_chan_sync_in_ccs_sync_out_vld_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_DUMMY_esp_acc_DUMMY_ccs_sync_out_vld_v1 (vld, ivld);
  parameter integer rscid = 1;

  input  ivld;
  output vld;

  wire   vld;

  assign vld = ivld;
endmodule

//------> ./Ctrl_Connections_conn_sync_chan_sync_in.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2024.2/1130128 Production Release
//  HLS Date:       Mon Aug 26 21:59:12 PDT 2024
//
//  Generated by:   gtombesi@corsica
//  Generated date: Wed Apr 30 13:21:32 2025
// ----------------------------------------------------------------------

//
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Connections_conn_sync_chan_sync_in_core
// ------------------------------------------------------------------


module esp_acc_DUMMY_esp_acc_DUMMY_Connections_conn_sync_chan_sync_in_core (
  this_vld, this_rdy, ccs_ccore_start_rsc_dat, ccs_ccore_done_sync_vld, ccs_MIO_clk,
      ccs_MIO_arst
);
  input this_vld;
  output this_rdy;
  reg this_rdy;
  input ccs_ccore_start_rsc_dat;
  output ccs_ccore_done_sync_vld;
  input ccs_MIO_clk;
  input ccs_MIO_arst;


  // Interconnect Declarations
  wire ccs_ccore_start_rsci_idat;
  reg io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1;
  wire or_3_cse;
  wire this_rdy_mx0c1;


  // Interconnect Declarations for Component Instantiations
  wire  nl_ccs_ccore_done_synci_ivld;
  assign nl_ccs_ccore_done_synci_ivld = io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1
      & this_vld;
  esp_acc_DUMMY_esp_acc_DUMMY_ccs_in_v1 #(.rscid(32'sd100),
  .width(32'sd1)) ccs_ccore_start_rsci (
      .dat(ccs_ccore_start_rsc_dat),
      .idat(ccs_ccore_start_rsci_idat)
    );
  esp_acc_DUMMY_esp_acc_DUMMY_ccs_sync_out_vld_v1 #(.rscid(32'sd102)) ccs_ccore_done_synci (
      .vld(ccs_ccore_done_sync_vld),
      .ivld(nl_ccs_ccore_done_synci_ivld)
    );
  assign or_3_cse = ccs_ccore_start_rsci_idat | (io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1
      & (~ this_vld));
  assign this_rdy_mx0c1 = io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1 & this_vld
      & (~ ccs_ccore_start_rsci_idat);
  always @(posedge ccs_MIO_clk or negedge ccs_MIO_arst) begin
    if ( ~ ccs_MIO_arst ) begin
      this_rdy <= 1'b0;
    end
    else if ( or_3_cse | this_rdy_mx0c1 ) begin
      this_rdy <= ~ this_rdy_mx0c1;
    end
  end
  always @(posedge ccs_MIO_clk or negedge ccs_MIO_arst) begin
    if ( ~ ccs_MIO_arst ) begin
      io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1 <= 1'b0;
    end
    else begin
      io_read_ccs_ccore_start_rsc_sft_lpi_1_dfm_1 <= or_3_cse;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    Connections_conn_sync_chan_sync_in
// ------------------------------------------------------------------


module esp_acc_DUMMY_Connections_conn_sync_chan_sync_in (
  this_vld, this_rdy, ccs_ccore_start_rsc_dat, ccs_ccore_done_sync_vld, ccs_MIO_clk,
      ccs_MIO_arst
);
  input this_vld;
  output this_rdy;
  input ccs_ccore_start_rsc_dat;
  output ccs_ccore_done_sync_vld;
  input ccs_MIO_clk;
  input ccs_MIO_arst;



  // Interconnect Declarations for Component Instantiations
  esp_acc_DUMMY_esp_acc_DUMMY_Connections_conn_sync_chan_sync_in_core Connections_conn_sync_chan_sync_in_core_inst
      (
      .this_vld(this_vld),
      .this_rdy(this_rdy),
      .ccs_ccore_start_rsc_dat(ccs_ccore_start_rsc_dat),
      .ccs_ccore_done_sync_vld(ccs_ccore_done_sync_vld),
      .ccs_MIO_clk(ccs_MIO_clk),
      .ccs_MIO_arst(ccs_MIO_arst)
    );
endmodule




//------> ../../../../inc/mem_bank/DUAL_PORT_RBW.v 
// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

module DUAL_PORT_RBW #(
    parameter AddressSz = 32,
    parameter data_width = 8,
    parameter Sz = 128
) (
    clk,
    clk_en,
    din,
    qout,
    r_adr,
    w_adr,
    w_en
);

    input clk;
    input clk_en;
    input [data_width-1:0] din;
    output [data_width-1:0] qout;
    input [AddressSz-1:0] r_adr;
    input [AddressSz-1:0] w_adr;
    input w_en;

    (* ram_style = "block" *)
    reg [data_width-1:0] out;
    reg [data_width-1:0] arr [Sz-1:0];

    always @(posedge clk) begin
        if (clk_en) begin
            out <= arr[r_adr];
            if (w_en) begin
                arr[w_adr] <= din;
            end
        end
    end

    assign qout = out;

endmodule

//------> ./Ctrl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2024.2/1130128 Production Release
//  HLS Date:       Mon Aug 26 21:59:12 PDT 2024
// 
//  Generated by:   gtombesi@corsica
//  Generated date: Wed Apr 30 13:21:56 2025
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_plm_outeBApGdata_rsc_bctl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_plm_outeBApGdata_rsc_bctl (
  clk, rst, plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst, plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst,
      plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst, plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz,
      plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz, plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst,
      plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz, plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud
);
  input clk;
  input rst;
  input [31:0] plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst;
  input [4:0] plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  input plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
  output [4:0] plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz;
  output [31:0] plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz;
  input [4:0] plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  output [4:0] plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz;
  output plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz = plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst;
  assign plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz = plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  assign plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz = plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  assign plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud = plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_plm_outEkvZidata_rsc_bctl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_plm_outEkvZidata_rsc_bctl (
  clk, rst, plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst, plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst,
      plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst, plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz,
      plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz, plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst,
      plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz, plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud
);
  input clk;
  input rst;
  input [31:0] plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst;
  input [4:0] plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  input plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
  output [4:0] plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz;
  output [31:0] plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz;
  input [4:0] plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  output [4:0] plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz;
  output plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz = plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst;
  assign plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz = plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  assign plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz = plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  assign plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud = plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_plm_outdyLTOdata_rsc_bctl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_plm_outdyLTOdata_rsc_bctl (
  clk, rst, plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst, plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst,
      plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst, plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz,
      plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz, plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst,
      plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz, plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud
);
  input clk;
  input rst;
  input [31:0] plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst;
  input [4:0] plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  input plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
  output [4:0] plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz;
  output [31:0] plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz;
  input [4:0] plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  output [4:0] plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz;
  output plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz = plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst;
  assign plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz = plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  assign plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz = plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  assign plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud = plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_plm_outEiGDqdata_rsc_bctl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_plm_outEiGDqdata_rsc_bctl (
  clk, rst, plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst, plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst,
      plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst, plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz,
      plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz, plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst,
      plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz, plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud
);
  input clk;
  input rst;
  input [31:0] plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst;
  input [4:0] plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  input plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
  output [4:0] plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz;
  output [31:0] plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz;
  input [4:0] plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  output [4:0] plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz;
  output plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz = plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst;
  assign plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz = plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  assign plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz = plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  assign plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud = plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_plm_in_xCVCqdata_rsc_bctl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_plm_in_xCVCqdata_rsc_bctl (
  clk, rst, plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst, plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst,
      plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst, plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz,
      plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz, plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst,
      plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz, plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud
);
  input clk;
  input rst;
  input [31:0] plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst;
  input [8:0] plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  input plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst;
  output [8:0] plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz;
  output [31:0] plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz;
  input [8:0] plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  output [8:0] plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz;
  output plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz = plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst;
  assign plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz = plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  assign plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz = plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  assign plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud = plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_plm_in_iLMvRdata_rsc_bctl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_plm_in_iLMvRdata_rsc_bctl (
  clk, rst, plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst, plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst,
      plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst, plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz,
      plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz, plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst,
      plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz, plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud
);
  input clk;
  input rst;
  input [31:0] plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst;
  input [8:0] plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  input plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst;
  output [8:0] plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz;
  output [31:0] plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz;
  input [8:0] plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  output [8:0] plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz;
  output plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz = plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst;
  assign plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz = plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  assign plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz = plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  assign plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud = plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_plm_in_xCUZOdata_rsc_bctl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_plm_in_xCUZOdata_rsc_bctl (
  clk, rst, plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst, plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst,
      plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst, plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz,
      plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz, plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst,
      plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz, plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud
);
  input clk;
  input rst;
  input [31:0] plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst;
  input [8:0] plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  input plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst;
  output [8:0] plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz;
  output [31:0] plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz;
  input [8:0] plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  output [8:0] plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz;
  output plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz = plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst;
  assign plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz = plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  assign plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz = plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  assign plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud = plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_plm_in_iLMRpdata_rsc_bctl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_plm_in_iLMRpdata_rsc_bctl (
  clk, rst, plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst, plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst,
      plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst, plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz,
      plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz, plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz,
      plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz, plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz,
      plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz, plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst,
      plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz, plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz,
      plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz, plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz,
      plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz, plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud,
      plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud, plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud,
      plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud, plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud,
      plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud, plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud
);
  input clk;
  input rst;
  input [31:0] plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst;
  input [8:0] plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  input plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst;
  output plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz;
  output [8:0] plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz;
  output [31:0] plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz;
  output plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz;
  output plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz;
  output plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz;
  input [8:0] plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  output [8:0] plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz;
  output plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz;
  output plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz;
  output plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz;
  output plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz;
  input plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;
  input plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;
  input plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;
  input plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
  input plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
  input plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
  input plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz = plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst;
  assign plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz = plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  assign plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz = plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  assign plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz = plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst;
  assign plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz = plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;
  assign plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz = plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;
  assign plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz = plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;
  assign plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz = plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
  assign plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz = plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
  assign plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz = plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
  assign plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz = plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_99_5_32_32_32_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_99_5_32_32_32_32_gen
    (
  r_adr, qout, qout_d, r_adr_d, port_0_r_ram_ir_internal_RMASK_B_d
);
  output [4:0] r_adr;
  input [31:0] qout;
  output [31:0] qout_d;
  input [4:0] r_adr_d;
  input port_0_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign r_adr = (r_adr_d);
  assign qout_d = qout;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_98_5_32_32_32_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_98_5_32_32_32_32_gen
    (
  r_adr, qout, qout_d, r_adr_d, port_0_r_ram_ir_internal_RMASK_B_d
);
  output [4:0] r_adr;
  input [31:0] qout;
  output [31:0] qout_d;
  input [4:0] r_adr_d;
  input port_0_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign r_adr = (r_adr_d);
  assign qout_d = qout;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_97_5_32_32_32_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_97_5_32_32_32_32_gen
    (
  r_adr, qout, qout_d, r_adr_d, port_0_r_ram_ir_internal_RMASK_B_d
);
  output [4:0] r_adr;
  input [31:0] qout;
  output [31:0] qout_d;
  input [4:0] r_adr_d;
  input port_0_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign r_adr = (r_adr_d);
  assign qout_d = qout;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_96_5_32_32_32_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_96_5_32_32_32_32_gen
    (
  r_adr, qout, qout_d, r_adr_d, port_0_r_ram_ir_internal_RMASK_B_d
);
  output [4:0] r_adr;
  input [31:0] qout;
  output [31:0] qout_d;
  input [4:0] r_adr_d;
  input port_0_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign r_adr = (r_adr_d);
  assign qout_d = qout;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_store_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_store_fsm (
  clk, rst, store_wen, fsm_output, while_C_4_tr0, while_for_C_0_tr0, while_for_for_C_2_tr0,
      while_for_for_for_for_C_0_tr0, while_for_for_for_C_0_tr0, while_for_for_C_3_tr0,
      while_for_C_1_tr0
);
  input clk;
  input rst;
  input store_wen;
  output [16:0] fsm_output;
  reg [16:0] fsm_output;
  input while_C_4_tr0;
  input while_for_C_0_tr0;
  input while_for_for_C_2_tr0;
  input while_for_for_for_for_C_0_tr0;
  input while_for_for_for_C_0_tr0;
  input while_for_for_C_3_tr0;
  input while_for_C_1_tr0;


  // FSM State Type Declaration for esp_acc_DUMMY_Ctrl_store_store_store_fsm_1
  parameter
    store_rlp_C_0 = 5'd0,
    while_C_0 = 5'd1,
    while_C_1 = 5'd2,
    while_C_2 = 5'd3,
    while_C_3 = 5'd4,
    while_C_4 = 5'd5,
    while_for_C_0 = 5'd6,
    while_for_for_C_0 = 5'd7,
    while_for_for_C_1 = 5'd8,
    while_for_for_C_2 = 5'd9,
    while_for_for_for_for_C_0 = 5'd10,
    while_for_for_for_for_C_1 = 5'd11,
    while_for_for_for_C_0 = 5'd12,
    while_for_for_C_3 = 5'd13,
    while_for_C_1 = 5'd14,
    while_C_5 = 5'd15,
    while_C_6 = 5'd16;

  reg [4:0] state_var;
  reg [4:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_DUMMY_Ctrl_store_store_store_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 17'b00000000000000010;
        state_var_NS = while_C_1;
      end
      while_C_1 : begin
        fsm_output = 17'b00000000000000100;
        state_var_NS = while_C_2;
      end
      while_C_2 : begin
        fsm_output = 17'b00000000000001000;
        state_var_NS = while_C_3;
      end
      while_C_3 : begin
        fsm_output = 17'b00000000000010000;
        state_var_NS = while_C_4;
      end
      while_C_4 : begin
        fsm_output = 17'b00000000000100000;
        if ( while_C_4_tr0 ) begin
          state_var_NS = while_C_5;
        end
        else begin
          state_var_NS = while_for_C_0;
        end
      end
      while_for_C_0 : begin
        fsm_output = 17'b00000000001000000;
        if ( while_for_C_0_tr0 ) begin
          state_var_NS = while_for_C_1;
        end
        else begin
          state_var_NS = while_for_for_C_0;
        end
      end
      while_for_for_C_0 : begin
        fsm_output = 17'b00000000010000000;
        state_var_NS = while_for_for_C_1;
      end
      while_for_for_C_1 : begin
        fsm_output = 17'b00000000100000000;
        state_var_NS = while_for_for_C_2;
      end
      while_for_for_C_2 : begin
        fsm_output = 17'b00000001000000000;
        if ( while_for_for_C_2_tr0 ) begin
          state_var_NS = while_for_for_C_3;
        end
        else begin
          state_var_NS = while_for_for_for_for_C_0;
        end
      end
      while_for_for_for_for_C_0 : begin
        fsm_output = 17'b00000010000000000;
        if ( while_for_for_for_for_C_0_tr0 ) begin
          state_var_NS = while_for_for_for_C_0;
        end
        else begin
          state_var_NS = while_for_for_for_for_C_1;
        end
      end
      while_for_for_for_for_C_1 : begin
        fsm_output = 17'b00000100000000000;
        state_var_NS = while_for_for_for_for_C_0;
      end
      while_for_for_for_C_0 : begin
        fsm_output = 17'b00001000000000000;
        if ( while_for_for_for_C_0_tr0 ) begin
          state_var_NS = while_for_for_C_3;
        end
        else begin
          state_var_NS = while_for_for_for_for_C_0;
        end
      end
      while_for_for_C_3 : begin
        fsm_output = 17'b00010000000000000;
        if ( while_for_for_C_3_tr0 ) begin
          state_var_NS = while_for_C_1;
        end
        else begin
          state_var_NS = while_for_for_C_0;
        end
      end
      while_for_C_1 : begin
        fsm_output = 17'b00100000000000000;
        if ( while_for_C_1_tr0 ) begin
          state_var_NS = while_C_5;
        end
        else begin
          state_var_NS = while_for_C_0;
        end
      end
      while_C_5 : begin
        fsm_output = 17'b01000000000000000;
        state_var_NS = while_C_6;
      end
      while_C_6 : begin
        fsm_output = 17'b10000000000000000;
        state_var_NS = while_C_0;
      end
      // store_rlp_C_0
      default : begin
        fsm_output = 17'b00000000000000001;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      state_var <= store_rlp_C_0;
    end
    else if ( store_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_staller
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_staller (
  clk, rst, store_wen, store_wten, sync03_Pop_mioi_wen_comp, conf3_Pop_mioi_wen_comp,
      sync23_sync_in_mioi_wen_comp, dma_write_ctrl_Push_mioi_wen_comp, dma_write_chnl_Push_mioi_wen_comp
);
  input clk;
  input rst;
  output store_wen;
  output store_wten;
  input sync03_Pop_mioi_wen_comp;
  input conf3_Pop_mioi_wen_comp;
  input sync23_sync_in_mioi_wen_comp;
  input dma_write_ctrl_Push_mioi_wen_comp;
  input dma_write_chnl_Push_mioi_wen_comp;


  // Interconnect Declarations
  reg store_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign store_wen = sync03_Pop_mioi_wen_comp & conf3_Pop_mioi_wen_comp & sync23_sync_in_mioi_wen_comp
      & dma_write_ctrl_Push_mioi_wen_comp & dma_write_chnl_Push_mioi_wen_comp;
  assign store_wten = store_wten_reg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      store_wten_reg <= 1'b0;
    end
    else begin
      store_wten_reg <= ~ store_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_out_pong_a1_a_d_data_rsci_qout_d, plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt,
      plm_out_pong_a1_a_d_data_rsci_biwt, plm_out_pong_a1_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_out_pong_a1_a_d_data_rsci_qout_d;
  output [31:0] plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt;
  input plm_out_pong_a1_a_d_data_rsci_biwt;
  input plm_out_pong_a1_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_pong_a1_a_d_data_rsci_bcwt;
  reg [31:0] plm_out_pong_a1_a_d_data_rsci_qout_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt = MUX_v_32_2_2(plm_out_pong_a1_a_d_data_rsci_qout_d,
      plm_out_pong_a1_a_d_data_rsci_qout_d_bfwt, plm_out_pong_a1_a_d_data_rsci_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_out_pong_a1_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_pong_a1_a_d_data_rsci_bcwt <= ~((~(plm_out_pong_a1_a_d_data_rsci_bcwt
          | plm_out_pong_a1_a_d_data_rsci_biwt)) | plm_out_pong_a1_a_d_data_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_out_pong_a1_a_d_data_rsci_biwt ) begin
      plm_out_pong_a1_a_d_data_rsci_qout_d_bfwt <= plm_out_pong_a1_a_d_data_rsci_qout_d;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_ctrl
    (
  store_wen, store_wten, plm_out_pong_a1_a_d_data_rsci_oswt, plm_out_pong_a1_a_d_data_rsci_biwt,
      plm_out_pong_a1_a_d_data_rsci_bdwt, plm_out_pong_a1_a_d_data_rsci_biwt_pff,
      plm_out_pong_a1_a_d_data_rsci_oswt_pff
);
  input store_wen;
  input store_wten;
  input plm_out_pong_a1_a_d_data_rsci_oswt;
  output plm_out_pong_a1_a_d_data_rsci_biwt;
  output plm_out_pong_a1_a_d_data_rsci_bdwt;
  output plm_out_pong_a1_a_d_data_rsci_biwt_pff;
  input plm_out_pong_a1_a_d_data_rsci_oswt_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a1_a_d_data_rsci_bdwt = plm_out_pong_a1_a_d_data_rsci_oswt
      & store_wen;
  assign plm_out_pong_a1_a_d_data_rsci_biwt = (~ store_wten) & plm_out_pong_a1_a_d_data_rsci_oswt;
  assign plm_out_pong_a1_a_d_data_rsci_biwt_pff = store_wen & plm_out_pong_a1_a_d_data_rsci_oswt_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_out_pong_a0_a_d_data_rsci_qout_d, plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt,
      plm_out_pong_a0_a_d_data_rsci_biwt, plm_out_pong_a0_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_out_pong_a0_a_d_data_rsci_qout_d;
  output [31:0] plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt;
  input plm_out_pong_a0_a_d_data_rsci_biwt;
  input plm_out_pong_a0_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_pong_a0_a_d_data_rsci_bcwt;
  reg [31:0] plm_out_pong_a0_a_d_data_rsci_qout_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt = MUX_v_32_2_2(plm_out_pong_a0_a_d_data_rsci_qout_d,
      plm_out_pong_a0_a_d_data_rsci_qout_d_bfwt, plm_out_pong_a0_a_d_data_rsci_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_out_pong_a0_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_pong_a0_a_d_data_rsci_bcwt <= ~((~(plm_out_pong_a0_a_d_data_rsci_bcwt
          | plm_out_pong_a0_a_d_data_rsci_biwt)) | plm_out_pong_a0_a_d_data_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_out_pong_a0_a_d_data_rsci_biwt ) begin
      plm_out_pong_a0_a_d_data_rsci_qout_d_bfwt <= plm_out_pong_a0_a_d_data_rsci_qout_d;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_ctrl
    (
  store_wen, store_wten, plm_out_pong_a0_a_d_data_rsci_oswt, plm_out_pong_a0_a_d_data_rsci_biwt,
      plm_out_pong_a0_a_d_data_rsci_bdwt, plm_out_pong_a0_a_d_data_rsci_biwt_pff,
      plm_out_pong_a0_a_d_data_rsci_oswt_pff
);
  input store_wen;
  input store_wten;
  input plm_out_pong_a0_a_d_data_rsci_oswt;
  output plm_out_pong_a0_a_d_data_rsci_biwt;
  output plm_out_pong_a0_a_d_data_rsci_bdwt;
  output plm_out_pong_a0_a_d_data_rsci_biwt_pff;
  input plm_out_pong_a0_a_d_data_rsci_oswt_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a0_a_d_data_rsci_bdwt = plm_out_pong_a0_a_d_data_rsci_oswt
      & store_wen;
  assign plm_out_pong_a0_a_d_data_rsci_biwt = (~ store_wten) & plm_out_pong_a0_a_d_data_rsci_oswt;
  assign plm_out_pong_a0_a_d_data_rsci_biwt_pff = store_wen & plm_out_pong_a0_a_d_data_rsci_oswt_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_out_ping_a1_a_d_data_rsci_qout_d, plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt,
      plm_out_ping_a1_a_d_data_rsci_biwt, plm_out_ping_a1_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_out_ping_a1_a_d_data_rsci_qout_d;
  output [31:0] plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt;
  input plm_out_ping_a1_a_d_data_rsci_biwt;
  input plm_out_ping_a1_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_ping_a1_a_d_data_rsci_bcwt;
  reg [31:0] plm_out_ping_a1_a_d_data_rsci_qout_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt = MUX_v_32_2_2(plm_out_ping_a1_a_d_data_rsci_qout_d,
      plm_out_ping_a1_a_d_data_rsci_qout_d_bfwt, plm_out_ping_a1_a_d_data_rsci_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_out_ping_a1_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_ping_a1_a_d_data_rsci_bcwt <= ~((~(plm_out_ping_a1_a_d_data_rsci_bcwt
          | plm_out_ping_a1_a_d_data_rsci_biwt)) | plm_out_ping_a1_a_d_data_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_out_ping_a1_a_d_data_rsci_biwt ) begin
      plm_out_ping_a1_a_d_data_rsci_qout_d_bfwt <= plm_out_ping_a1_a_d_data_rsci_qout_d;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_ctrl
    (
  store_wen, store_wten, plm_out_ping_a1_a_d_data_rsci_oswt, plm_out_ping_a1_a_d_data_rsci_biwt,
      plm_out_ping_a1_a_d_data_rsci_bdwt, plm_out_ping_a1_a_d_data_rsci_biwt_pff,
      plm_out_ping_a1_a_d_data_rsci_oswt_pff
);
  input store_wen;
  input store_wten;
  input plm_out_ping_a1_a_d_data_rsci_oswt;
  output plm_out_ping_a1_a_d_data_rsci_biwt;
  output plm_out_ping_a1_a_d_data_rsci_bdwt;
  output plm_out_ping_a1_a_d_data_rsci_biwt_pff;
  input plm_out_ping_a1_a_d_data_rsci_oswt_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a1_a_d_data_rsci_bdwt = plm_out_ping_a1_a_d_data_rsci_oswt
      & store_wen;
  assign plm_out_ping_a1_a_d_data_rsci_biwt = (~ store_wten) & plm_out_ping_a1_a_d_data_rsci_oswt;
  assign plm_out_ping_a1_a_d_data_rsci_biwt_pff = store_wen & plm_out_ping_a1_a_d_data_rsci_oswt_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_out_ping_a0_a_d_data_rsci_qout_d, plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt,
      plm_out_ping_a0_a_d_data_rsci_biwt, plm_out_ping_a0_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_out_ping_a0_a_d_data_rsci_qout_d;
  output [31:0] plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt;
  input plm_out_ping_a0_a_d_data_rsci_biwt;
  input plm_out_ping_a0_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_ping_a0_a_d_data_rsci_bcwt;
  reg [31:0] plm_out_ping_a0_a_d_data_rsci_qout_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt = MUX_v_32_2_2(plm_out_ping_a0_a_d_data_rsci_qout_d,
      plm_out_ping_a0_a_d_data_rsci_qout_d_bfwt, plm_out_ping_a0_a_d_data_rsci_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_out_ping_a0_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_ping_a0_a_d_data_rsci_bcwt <= ~((~(plm_out_ping_a0_a_d_data_rsci_bcwt
          | plm_out_ping_a0_a_d_data_rsci_biwt)) | plm_out_ping_a0_a_d_data_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_out_ping_a0_a_d_data_rsci_biwt ) begin
      plm_out_ping_a0_a_d_data_rsci_qout_d_bfwt <= plm_out_ping_a0_a_d_data_rsci_qout_d;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_ctrl
    (
  store_wen, store_wten, plm_out_ping_a0_a_d_data_rsci_oswt, plm_out_ping_a0_a_d_data_rsci_biwt,
      plm_out_ping_a0_a_d_data_rsci_bdwt, plm_out_ping_a0_a_d_data_rsci_biwt_pff,
      plm_out_ping_a0_a_d_data_rsci_oswt_pff
);
  input store_wen;
  input store_wten;
  input plm_out_ping_a0_a_d_data_rsci_oswt;
  output plm_out_ping_a0_a_d_data_rsci_biwt;
  output plm_out_ping_a0_a_d_data_rsci_bdwt;
  output plm_out_ping_a0_a_d_data_rsci_biwt_pff;
  input plm_out_ping_a0_a_d_data_rsci_oswt_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a0_a_d_data_rsci_bdwt = plm_out_ping_a0_a_d_data_rsci_oswt
      & store_wen;
  assign plm_out_ping_a0_a_d_data_rsci_biwt = (~ store_wten) & plm_out_ping_a0_a_d_data_rsci_oswt;
  assign plm_out_ping_a0_a_d_data_rsci_biwt_pff = store_wen & plm_out_ping_a0_a_d_data_rsci_oswt_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_dma_write_chnl_Push_mioi_dma_write_chnl_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_dma_write_chnl_Push_mioi_dma_write_chnl_Push_mio_wait_ctrl
    (
  dma_write_chnl_Push_mioi_iswt0, dma_write_chnl_Push_mioi_irdy_oreg, dma_write_chnl_Push_mioi_biwt
);
  input dma_write_chnl_Push_mioi_iswt0;
  input dma_write_chnl_Push_mioi_irdy_oreg;
  output dma_write_chnl_Push_mioi_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_write_chnl_Push_mioi_biwt = dma_write_chnl_Push_mioi_iswt0 & dma_write_chnl_Push_mioi_irdy_oreg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_dma_write_ctrl_Push_mioi_dma_write_ctrl_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_dma_write_ctrl_Push_mioi_dma_write_ctrl_Push_mio_wait_ctrl
    (
  dma_write_ctrl_Push_mioi_iswt0, dma_write_ctrl_Push_mioi_irdy_oreg, dma_write_ctrl_Push_mioi_biwt
);
  input dma_write_ctrl_Push_mioi_iswt0;
  input dma_write_ctrl_Push_mioi_irdy_oreg;
  output dma_write_ctrl_Push_mioi_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_write_ctrl_Push_mioi_biwt = dma_write_ctrl_Push_mioi_iswt0 & dma_write_ctrl_Push_mioi_irdy_oreg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_sync23_sync_in_mioi_sync23_sync_in_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_sync23_sync_in_mioi_sync23_sync_in_mio_wait_ctrl
    (
  store_wten, sync23_sync_in_mioi_iswt0, sync23_sync_in_mioi_biwt, sync23_sync_in_mioi_ccs_ccore_start_rsc_dat_store_sct,
      sync23_sync_in_mioi_ccs_ccore_done_sync_vld, sync23_sync_in_mioi_iswt0_pff
);
  input store_wten;
  input sync23_sync_in_mioi_iswt0;
  output sync23_sync_in_mioi_biwt;
  output sync23_sync_in_mioi_ccs_ccore_start_rsc_dat_store_sct;
  input sync23_sync_in_mioi_ccs_ccore_done_sync_vld;
  input sync23_sync_in_mioi_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign sync23_sync_in_mioi_biwt = sync23_sync_in_mioi_iswt0 & sync23_sync_in_mioi_ccs_ccore_done_sync_vld;
  assign sync23_sync_in_mioi_ccs_ccore_start_rsc_dat_store_sct = (~ store_wten) &
      sync23_sync_in_mioi_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_conf3_Pop_mioi_conf3_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_conf3_Pop_mioi_conf3_Pop_mio_wait_dp (
  clk, rst, conf3_Pop_mioi_oswt, conf3_Pop_mioi_wen_comp, conf3_Pop_mioi_idat_mxwt,
      conf3_Pop_mioi_biwt, conf3_Pop_mioi_bdwt, conf3_Pop_mioi_bcwt, conf3_Pop_mioi_idat
);
  input clk;
  input rst;
  input conf3_Pop_mioi_oswt;
  output conf3_Pop_mioi_wen_comp;
  output [95:0] conf3_Pop_mioi_idat_mxwt;
  input conf3_Pop_mioi_biwt;
  input conf3_Pop_mioi_bdwt;
  output conf3_Pop_mioi_bcwt;
  reg conf3_Pop_mioi_bcwt;
  input [95:0] conf3_Pop_mioi_idat;


  // Interconnect Declarations
  reg [95:0] conf3_Pop_mioi_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf3_Pop_mioi_wen_comp = (~ conf3_Pop_mioi_oswt) | conf3_Pop_mioi_biwt
      | conf3_Pop_mioi_bcwt;
  assign conf3_Pop_mioi_idat_mxwt = MUX_v_96_2_2(conf3_Pop_mioi_idat, conf3_Pop_mioi_idat_bfwt,
      conf3_Pop_mioi_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf3_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      conf3_Pop_mioi_bcwt <= ~((~(conf3_Pop_mioi_bcwt | conf3_Pop_mioi_biwt)) | conf3_Pop_mioi_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( conf3_Pop_mioi_biwt ) begin
      conf3_Pop_mioi_idat_bfwt <= conf3_Pop_mioi_idat;
    end
  end

  function automatic [95:0] MUX_v_96_2_2;
    input [95:0] input_0;
    input [95:0] input_1;
    input  sel;
    reg [95:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_96_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_conf3_Pop_mioi_conf3_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_conf3_Pop_mioi_conf3_Pop_mio_wait_ctrl (
  store_wen, conf3_Pop_mioi_oswt, conf3_Pop_mioi_ivld_oreg, conf3_Pop_mioi_biwt,
      conf3_Pop_mioi_bdwt, conf3_Pop_mioi_bcwt, conf3_Pop_mioi_irdy_store_sct
);
  input store_wen;
  input conf3_Pop_mioi_oswt;
  input conf3_Pop_mioi_ivld_oreg;
  output conf3_Pop_mioi_biwt;
  output conf3_Pop_mioi_bdwt;
  input conf3_Pop_mioi_bcwt;
  output conf3_Pop_mioi_irdy_store_sct;


  // Interconnect Declarations
  wire conf3_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf3_Pop_mioi_bdwt = conf3_Pop_mioi_oswt & store_wen;
  assign conf3_Pop_mioi_biwt = conf3_Pop_mioi_ogwt & conf3_Pop_mioi_ivld_oreg;
  assign conf3_Pop_mioi_ogwt = conf3_Pop_mioi_oswt & (~ conf3_Pop_mioi_bcwt);
  assign conf3_Pop_mioi_irdy_store_sct = conf3_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_wait_dp (
  clk, rst, while_store_offset_mul_1_cmp_z, store_wen, sync03_Pop_mioi_ivld, sync03_Pop_mioi_ivld_oreg,
      conf3_Pop_mioi_ivld, conf3_Pop_mioi_ivld_oreg, dma_write_ctrl_Push_mioi_irdy,
      dma_write_ctrl_Push_mioi_irdy_oreg, dma_write_chnl_Push_mioi_irdy, dma_write_chnl_Push_mioi_irdy_oreg,
      while_store_offset_mul_1_cmp_z_oreg
);
  input clk;
  input rst;
  input [31:0] while_store_offset_mul_1_cmp_z;
  input store_wen;
  input sync03_Pop_mioi_ivld;
  output sync03_Pop_mioi_ivld_oreg;
  input conf3_Pop_mioi_ivld;
  output conf3_Pop_mioi_ivld_oreg;
  input dma_write_ctrl_Push_mioi_irdy;
  output dma_write_ctrl_Push_mioi_irdy_oreg;
  input dma_write_chnl_Push_mioi_irdy;
  output dma_write_chnl_Push_mioi_irdy_oreg;
  output [31:0] while_store_offset_mul_1_cmp_z_oreg;
  reg [31:0] while_store_offset_mul_1_cmp_z_oreg;


  // Interconnect Declarations
  reg sync03_Pop_mioi_ivld_oreg_rneg;
  reg conf3_Pop_mioi_ivld_oreg_rneg;
  reg dma_write_ctrl_Push_mioi_irdy_oreg_rneg;
  reg dma_write_chnl_Push_mioi_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign sync03_Pop_mioi_ivld_oreg = ~ sync03_Pop_mioi_ivld_oreg_rneg;
  assign conf3_Pop_mioi_ivld_oreg = ~ conf3_Pop_mioi_ivld_oreg_rneg;
  assign dma_write_ctrl_Push_mioi_irdy_oreg = ~ dma_write_ctrl_Push_mioi_irdy_oreg_rneg;
  assign dma_write_chnl_Push_mioi_irdy_oreg = ~ dma_write_chnl_Push_mioi_irdy_oreg_rneg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync03_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      conf3_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      dma_write_ctrl_Push_mioi_irdy_oreg_rneg <= 1'b0;
      dma_write_chnl_Push_mioi_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      sync03_Pop_mioi_ivld_oreg_rneg <= ~ sync03_Pop_mioi_ivld;
      conf3_Pop_mioi_ivld_oreg_rneg <= ~ conf3_Pop_mioi_ivld;
      dma_write_ctrl_Push_mioi_irdy_oreg_rneg <= ~ dma_write_ctrl_Push_mioi_irdy;
      dma_write_chnl_Push_mioi_irdy_oreg_rneg <= ~ dma_write_chnl_Push_mioi_irdy;
    end
  end
  always @(posedge clk) begin
    if ( store_wen ) begin
      while_store_offset_mul_1_cmp_z_oreg <= while_store_offset_mul_1_cmp_z;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_sync03_Pop_mioi_sync03_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_sync03_Pop_mioi_sync03_Pop_mio_wait_dp (
  clk, rst, sync03_Pop_mioi_oswt, sync03_Pop_mioi_wen_comp, sync03_Pop_mioi_biwt,
      sync03_Pop_mioi_bdwt, sync03_Pop_mioi_bcwt
);
  input clk;
  input rst;
  input sync03_Pop_mioi_oswt;
  output sync03_Pop_mioi_wen_comp;
  input sync03_Pop_mioi_biwt;
  input sync03_Pop_mioi_bdwt;
  output sync03_Pop_mioi_bcwt;
  reg sync03_Pop_mioi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign sync03_Pop_mioi_wen_comp = (~ sync03_Pop_mioi_oswt) | sync03_Pop_mioi_biwt
      | sync03_Pop_mioi_bcwt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync03_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      sync03_Pop_mioi_bcwt <= ~((~(sync03_Pop_mioi_bcwt | sync03_Pop_mioi_biwt))
          | sync03_Pop_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_sync03_Pop_mioi_sync03_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_sync03_Pop_mioi_sync03_Pop_mio_wait_ctrl (
  store_wen, sync03_Pop_mioi_oswt, sync03_Pop_mioi_ivld_oreg, sync03_Pop_mioi_biwt,
      sync03_Pop_mioi_bdwt, sync03_Pop_mioi_bcwt, sync03_Pop_mioi_irdy_store_sct
);
  input store_wen;
  input sync03_Pop_mioi_oswt;
  input sync03_Pop_mioi_ivld_oreg;
  output sync03_Pop_mioi_biwt;
  output sync03_Pop_mioi_bdwt;
  input sync03_Pop_mioi_bcwt;
  output sync03_Pop_mioi_irdy_store_sct;


  // Interconnect Declarations
  wire sync03_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign sync03_Pop_mioi_bdwt = sync03_Pop_mioi_oswt & store_wen;
  assign sync03_Pop_mioi_biwt = sync03_Pop_mioi_ogwt & sync03_Pop_mioi_ivld_oreg;
  assign sync03_Pop_mioi_ogwt = sync03_Pop_mioi_oswt & (~ sync03_Pop_mioi_bcwt);
  assign sync03_Pop_mioi_irdy_store_sct = sync03_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_95_5_32_32_32_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_95_5_32_32_32_32_gen
    (
  w_en, w_adr, din, din_d, w_adr_d, w_en_d, port_1_w_ram_ir_internal_WMASK_B_d
);
  output w_en;
  output [4:0] w_adr;
  output [31:0] din;
  input [31:0] din_d;
  input [4:0] w_adr_d;
  input w_en_d;
  input port_1_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign w_en = (port_1_w_ram_ir_internal_WMASK_B_d);
  assign w_adr = (w_adr_d);
  assign din = (din_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_94_5_32_32_32_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_94_5_32_32_32_32_gen
    (
  w_en, w_adr, din, din_d, w_adr_d, w_en_d, port_1_w_ram_ir_internal_WMASK_B_d
);
  output w_en;
  output [4:0] w_adr;
  output [31:0] din;
  input [31:0] din_d;
  input [4:0] w_adr_d;
  input w_en_d;
  input port_1_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign w_en = (port_1_w_ram_ir_internal_WMASK_B_d);
  assign w_adr = (w_adr_d);
  assign din = (din_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_93_5_32_32_32_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_93_5_32_32_32_32_gen
    (
  w_en, w_adr, din, din_d, w_adr_d, w_en_d, port_1_w_ram_ir_internal_WMASK_B_d
);
  output w_en;
  output [4:0] w_adr;
  output [31:0] din;
  input [31:0] din_d;
  input [4:0] w_adr_d;
  input w_en_d;
  input port_1_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign w_en = (port_1_w_ram_ir_internal_WMASK_B_d);
  assign w_adr = (w_adr_d);
  assign din = (din_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_92_5_32_32_32_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_92_5_32_32_32_32_gen
    (
  w_en, w_adr, din, din_d, w_adr_d, w_en_d, port_1_w_ram_ir_internal_WMASK_B_d
);
  output w_en;
  output [4:0] w_adr;
  output [31:0] din;
  input [31:0] din_d;
  input [4:0] w_adr_d;
  input w_en_d;
  input port_1_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign w_en = (port_1_w_ram_ir_internal_WMASK_B_d);
  assign w_adr = (w_adr_d);
  assign din = (din_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_91_9_32_320_320_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_91_9_32_320_320_32_gen
    (
  r_adr, qout, qout_d, r_adr_d, port_0_r_ram_ir_internal_RMASK_B_d
);
  output [8:0] r_adr;
  input [31:0] qout;
  output [31:0] qout_d;
  input [8:0] r_adr_d;
  input port_0_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign r_adr = (r_adr_d);
  assign qout_d = qout;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_90_9_32_320_320_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_90_9_32_320_320_32_gen
    (
  r_adr, qout, qout_d, r_adr_d, port_0_r_ram_ir_internal_RMASK_B_d
);
  output [8:0] r_adr;
  input [31:0] qout;
  output [31:0] qout_d;
  input [8:0] r_adr_d;
  input port_0_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign r_adr = (r_adr_d);
  assign qout_d = qout;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_89_9_32_320_320_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_89_9_32_320_320_32_gen
    (
  r_adr, qout, qout_d, r_adr_d, port_0_r_ram_ir_internal_RMASK_B_d
);
  output [8:0] r_adr;
  input [31:0] qout;
  output [31:0] qout_d;
  input [8:0] r_adr_d;
  input port_0_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign r_adr = (r_adr_d);
  assign qout_d = qout;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_88_9_32_320_320_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_88_9_32_320_320_32_gen
    (
  r_adr, qout, qout_d, r_adr_d, port_0_r_ram_ir_internal_RMASK_B_d
);
  output [8:0] r_adr;
  input [31:0] qout;
  output [31:0] qout_d;
  input [8:0] r_adr_d;
  input port_0_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign r_adr = (r_adr_d);
  assign qout_d = qout;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_compute_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_compute_fsm (
  clk, rst, compute_wen, fsm_output, while_C_0_tr0, while_for_C_1_tr0, while_for_for_for_C_1_tr0,
      while_for_for_C_3_tr0, while_for_C_2_tr0
);
  input clk;
  input rst;
  input compute_wen;
  output [10:0] fsm_output;
  reg [10:0] fsm_output;
  input while_C_0_tr0;
  input while_for_C_1_tr0;
  input while_for_for_for_C_1_tr0;
  input while_for_for_C_3_tr0;
  input while_for_C_2_tr0;


  // FSM State Type Declaration for esp_acc_DUMMY_Ctrl_compute_compute_compute_fsm_1
  parameter
    compute_rlp_C_0 = 4'd0,
    while_C_0 = 4'd1,
    while_for_C_0 = 4'd2,
    while_for_C_1 = 4'd3,
    while_for_for_C_0 = 4'd4,
    while_for_for_C_1 = 4'd5,
    while_for_for_for_C_0 = 4'd6,
    while_for_for_for_C_1 = 4'd7,
    while_for_for_C_2 = 4'd8,
    while_for_for_C_3 = 4'd9,
    while_for_C_2 = 4'd10;

  reg [3:0] state_var;
  reg [3:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_DUMMY_Ctrl_compute_compute_compute_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 11'b00000000010;
        if ( while_C_0_tr0 ) begin
          state_var_NS = while_C_0;
        end
        else begin
          state_var_NS = while_for_C_0;
        end
      end
      while_for_C_0 : begin
        fsm_output = 11'b00000000100;
        state_var_NS = while_for_C_1;
      end
      while_for_C_1 : begin
        fsm_output = 11'b00000001000;
        if ( while_for_C_1_tr0 ) begin
          state_var_NS = while_for_C_2;
        end
        else begin
          state_var_NS = while_for_for_C_0;
        end
      end
      while_for_for_C_0 : begin
        fsm_output = 11'b00000010000;
        state_var_NS = while_for_for_C_1;
      end
      while_for_for_C_1 : begin
        fsm_output = 11'b00000100000;
        state_var_NS = while_for_for_for_C_0;
      end
      while_for_for_for_C_0 : begin
        fsm_output = 11'b00001000000;
        state_var_NS = while_for_for_for_C_1;
      end
      while_for_for_for_C_1 : begin
        fsm_output = 11'b00010000000;
        if ( while_for_for_for_C_1_tr0 ) begin
          state_var_NS = while_for_for_C_2;
        end
        else begin
          state_var_NS = while_for_for_for_C_0;
        end
      end
      while_for_for_C_2 : begin
        fsm_output = 11'b00100000000;
        state_var_NS = while_for_for_C_3;
      end
      while_for_for_C_3 : begin
        fsm_output = 11'b01000000000;
        if ( while_for_for_C_3_tr0 ) begin
          state_var_NS = while_for_C_2;
        end
        else begin
          state_var_NS = while_for_for_C_0;
        end
      end
      while_for_C_2 : begin
        fsm_output = 11'b10000000000;
        if ( while_for_C_2_tr0 ) begin
          state_var_NS = while_C_0;
        end
        else begin
          state_var_NS = while_for_C_0;
        end
      end
      // compute_rlp_C_0
      default : begin
        fsm_output = 11'b00000000001;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      state_var <= compute_rlp_C_0;
    end
    else if ( compute_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_staller
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_staller (
  clk, rst, compute_wen, compute_wten, sync02_Pop_mioi_iden, sync02_Pop_mioi_wen_comp,
      conf2_Pop_mioi_iden, conf2_Pop_mioi_wen_comp, sync12_sync_in_mioi_wen_comp,
      in_rd_rsp_Push_mioi_iden, in_rd_rsp_Push_mioi_wen_comp, in_wr_req_Pop_mioi_iden,
      in_wr_req_Pop_mioi_wen_comp, sync23_sync_out_mioi_wen_comp, plm_in_ping_a0_a_d_data_rsci_iden,
      plm_in_ping_a1_a_d_data_rsci_iden, plm_in_pong_a0_a_d_data_rsci_iden, plm_in_pong_a1_a_d_data_rsci_iden,
      plm_out_ping_a0_a_d_data_rsci_iden, plm_out_ping_a1_a_d_data_rsci_iden, plm_out_pong_a0_a_d_data_rsci_iden,
      plm_out_pong_a1_a_d_data_rsci_iden, compute_flen_unreg
);
  input clk;
  input rst;
  output compute_wen;
  output compute_wten;
  input sync02_Pop_mioi_iden;
  input sync02_Pop_mioi_wen_comp;
  input conf2_Pop_mioi_iden;
  input conf2_Pop_mioi_wen_comp;
  input sync12_sync_in_mioi_wen_comp;
  input in_rd_rsp_Push_mioi_iden;
  input in_rd_rsp_Push_mioi_wen_comp;
  input in_wr_req_Pop_mioi_iden;
  input in_wr_req_Pop_mioi_wen_comp;
  input sync23_sync_out_mioi_wen_comp;
  input plm_in_ping_a0_a_d_data_rsci_iden;
  input plm_in_ping_a1_a_d_data_rsci_iden;
  input plm_in_pong_a0_a_d_data_rsci_iden;
  input plm_in_pong_a1_a_d_data_rsci_iden;
  input plm_out_ping_a0_a_d_data_rsci_iden;
  input plm_out_ping_a1_a_d_data_rsci_iden;
  input plm_out_pong_a0_a_d_data_rsci_iden;
  input plm_out_pong_a1_a_d_data_rsci_iden;
  input compute_flen_unreg;


  // Interconnect Declarations
  reg compute_flen_shf_1;
  reg compute_flen_shf_0;
  reg compute_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign compute_wen = sync02_Pop_mioi_wen_comp & conf2_Pop_mioi_wen_comp & sync12_sync_in_mioi_wen_comp
      & in_rd_rsp_Push_mioi_wen_comp & in_wr_req_Pop_mioi_wen_comp & sync23_sync_out_mioi_wen_comp
      & (~(compute_flen_shf_1 & compute_flen_shf_0 & compute_flen_unreg));
  assign compute_wten = compute_wten_reg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      compute_flen_shf_1 <= 1'b0;
      compute_flen_shf_0 <= 1'b0;
      compute_wten_reg <= 1'b0;
    end
    else begin
      compute_flen_shf_1 <= compute_flen_shf_0;
      compute_flen_shf_0 <= compute_flen_unreg & (~(sync02_Pop_mioi_iden | conf2_Pop_mioi_iden
          | in_rd_rsp_Push_mioi_iden | in_wr_req_Pop_mioi_iden | plm_in_ping_a0_a_d_data_rsci_iden
          | plm_in_ping_a1_a_d_data_rsci_iden | plm_in_pong_a0_a_d_data_rsci_iden
          | plm_in_pong_a1_a_d_data_rsci_iden | plm_out_ping_a0_a_d_data_rsci_iden
          | plm_out_ping_a1_a_d_data_rsci_iden | plm_out_pong_a0_a_d_data_rsci_iden
          | plm_out_pong_a1_a_d_data_rsci_iden));
      compute_wten_reg <= ~ compute_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_out_pong_a1_a_d_data_rsci_bawt, plm_out_pong_a1_a_d_data_rsci_iden,
      plm_out_pong_a1_a_d_data_rsci_biwt, plm_out_pong_a1_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  output plm_out_pong_a1_a_d_data_rsci_bawt;
  output plm_out_pong_a1_a_d_data_rsci_iden;
  input plm_out_pong_a1_a_d_data_rsci_biwt;
  input plm_out_pong_a1_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_pong_a1_a_d_data_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a1_a_d_data_rsci_iden = plm_out_pong_a1_a_d_data_rsci_biwt
      | plm_out_pong_a1_a_d_data_rsci_bdwt;
  assign plm_out_pong_a1_a_d_data_rsci_bawt = plm_out_pong_a1_a_d_data_rsci_biwt
      | plm_out_pong_a1_a_d_data_rsci_bcwt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_out_pong_a1_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_pong_a1_a_d_data_rsci_bcwt <= ~((~(plm_out_pong_a1_a_d_data_rsci_bcwt
          | plm_out_pong_a1_a_d_data_rsci_biwt)) | plm_out_pong_a1_a_d_data_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_ctrl
    (
  compute_wen, compute_wten, plm_out_pong_a1_a_d_data_rsci_oswt_unreg, plm_out_pong_a1_a_d_data_rsci_iswt0,
      plm_out_pong_a1_a_d_data_rsci_biwt, plm_out_pong_a1_a_d_data_rsci_bdwt, plm_out_pong_a1_a_d_data_rsci_biwt_pff,
      plm_out_pong_a1_a_d_data_rsci_iswt0_pff
);
  input compute_wen;
  input compute_wten;
  input plm_out_pong_a1_a_d_data_rsci_oswt_unreg;
  input plm_out_pong_a1_a_d_data_rsci_iswt0;
  output plm_out_pong_a1_a_d_data_rsci_biwt;
  output plm_out_pong_a1_a_d_data_rsci_bdwt;
  output plm_out_pong_a1_a_d_data_rsci_biwt_pff;
  input plm_out_pong_a1_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a1_a_d_data_rsci_bdwt = plm_out_pong_a1_a_d_data_rsci_oswt_unreg
      & compute_wen;
  assign plm_out_pong_a1_a_d_data_rsci_biwt = (~ compute_wten) & plm_out_pong_a1_a_d_data_rsci_iswt0;
  assign plm_out_pong_a1_a_d_data_rsci_biwt_pff = compute_wen & plm_out_pong_a1_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_out_pong_a0_a_d_data_rsci_bawt, plm_out_pong_a0_a_d_data_rsci_iden,
      plm_out_pong_a0_a_d_data_rsci_biwt, plm_out_pong_a0_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  output plm_out_pong_a0_a_d_data_rsci_bawt;
  output plm_out_pong_a0_a_d_data_rsci_iden;
  input plm_out_pong_a0_a_d_data_rsci_biwt;
  input plm_out_pong_a0_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_pong_a0_a_d_data_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a0_a_d_data_rsci_iden = plm_out_pong_a0_a_d_data_rsci_biwt
      | plm_out_pong_a0_a_d_data_rsci_bdwt;
  assign plm_out_pong_a0_a_d_data_rsci_bawt = plm_out_pong_a0_a_d_data_rsci_biwt
      | plm_out_pong_a0_a_d_data_rsci_bcwt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_out_pong_a0_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_pong_a0_a_d_data_rsci_bcwt <= ~((~(plm_out_pong_a0_a_d_data_rsci_bcwt
          | plm_out_pong_a0_a_d_data_rsci_biwt)) | plm_out_pong_a0_a_d_data_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_ctrl
    (
  compute_wen, compute_wten, plm_out_pong_a0_a_d_data_rsci_oswt_unreg, plm_out_pong_a0_a_d_data_rsci_iswt0,
      plm_out_pong_a0_a_d_data_rsci_biwt, plm_out_pong_a0_a_d_data_rsci_bdwt, plm_out_pong_a0_a_d_data_rsci_biwt_pff,
      plm_out_pong_a0_a_d_data_rsci_iswt0_pff
);
  input compute_wen;
  input compute_wten;
  input plm_out_pong_a0_a_d_data_rsci_oswt_unreg;
  input plm_out_pong_a0_a_d_data_rsci_iswt0;
  output plm_out_pong_a0_a_d_data_rsci_biwt;
  output plm_out_pong_a0_a_d_data_rsci_bdwt;
  output plm_out_pong_a0_a_d_data_rsci_biwt_pff;
  input plm_out_pong_a0_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_pong_a0_a_d_data_rsci_bdwt = plm_out_pong_a0_a_d_data_rsci_oswt_unreg
      & compute_wen;
  assign plm_out_pong_a0_a_d_data_rsci_biwt = (~ compute_wten) & plm_out_pong_a0_a_d_data_rsci_iswt0;
  assign plm_out_pong_a0_a_d_data_rsci_biwt_pff = compute_wen & plm_out_pong_a0_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_out_ping_a1_a_d_data_rsci_bawt, plm_out_ping_a1_a_d_data_rsci_iden,
      plm_out_ping_a1_a_d_data_rsci_biwt, plm_out_ping_a1_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  output plm_out_ping_a1_a_d_data_rsci_bawt;
  output plm_out_ping_a1_a_d_data_rsci_iden;
  input plm_out_ping_a1_a_d_data_rsci_biwt;
  input plm_out_ping_a1_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_ping_a1_a_d_data_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a1_a_d_data_rsci_iden = plm_out_ping_a1_a_d_data_rsci_biwt
      | plm_out_ping_a1_a_d_data_rsci_bdwt;
  assign plm_out_ping_a1_a_d_data_rsci_bawt = plm_out_ping_a1_a_d_data_rsci_biwt
      | plm_out_ping_a1_a_d_data_rsci_bcwt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_out_ping_a1_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_ping_a1_a_d_data_rsci_bcwt <= ~((~(plm_out_ping_a1_a_d_data_rsci_bcwt
          | plm_out_ping_a1_a_d_data_rsci_biwt)) | plm_out_ping_a1_a_d_data_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_ctrl
    (
  compute_wen, compute_wten, plm_out_ping_a1_a_d_data_rsci_oswt_unreg, plm_out_ping_a1_a_d_data_rsci_iswt0,
      plm_out_ping_a1_a_d_data_rsci_biwt, plm_out_ping_a1_a_d_data_rsci_bdwt, plm_out_ping_a1_a_d_data_rsci_biwt_pff,
      plm_out_ping_a1_a_d_data_rsci_iswt0_pff
);
  input compute_wen;
  input compute_wten;
  input plm_out_ping_a1_a_d_data_rsci_oswt_unreg;
  input plm_out_ping_a1_a_d_data_rsci_iswt0;
  output plm_out_ping_a1_a_d_data_rsci_biwt;
  output plm_out_ping_a1_a_d_data_rsci_bdwt;
  output plm_out_ping_a1_a_d_data_rsci_biwt_pff;
  input plm_out_ping_a1_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a1_a_d_data_rsci_bdwt = plm_out_ping_a1_a_d_data_rsci_oswt_unreg
      & compute_wen;
  assign plm_out_ping_a1_a_d_data_rsci_biwt = (~ compute_wten) & plm_out_ping_a1_a_d_data_rsci_iswt0;
  assign plm_out_ping_a1_a_d_data_rsci_biwt_pff = compute_wen & plm_out_ping_a1_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_out_ping_a0_a_d_data_rsci_bawt, plm_out_ping_a0_a_d_data_rsci_iden,
      plm_out_ping_a0_a_d_data_rsci_biwt, plm_out_ping_a0_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  output plm_out_ping_a0_a_d_data_rsci_bawt;
  output plm_out_ping_a0_a_d_data_rsci_iden;
  input plm_out_ping_a0_a_d_data_rsci_biwt;
  input plm_out_ping_a0_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_ping_a0_a_d_data_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a0_a_d_data_rsci_iden = plm_out_ping_a0_a_d_data_rsci_biwt
      | plm_out_ping_a0_a_d_data_rsci_bdwt;
  assign plm_out_ping_a0_a_d_data_rsci_bawt = plm_out_ping_a0_a_d_data_rsci_biwt
      | plm_out_ping_a0_a_d_data_rsci_bcwt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_out_ping_a0_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_ping_a0_a_d_data_rsci_bcwt <= ~((~(plm_out_ping_a0_a_d_data_rsci_bcwt
          | plm_out_ping_a0_a_d_data_rsci_biwt)) | plm_out_ping_a0_a_d_data_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_ctrl
    (
  compute_wen, compute_wten, plm_out_ping_a0_a_d_data_rsci_oswt_unreg, plm_out_ping_a0_a_d_data_rsci_iswt0,
      plm_out_ping_a0_a_d_data_rsci_biwt, plm_out_ping_a0_a_d_data_rsci_bdwt, plm_out_ping_a0_a_d_data_rsci_biwt_pff,
      plm_out_ping_a0_a_d_data_rsci_iswt0_pff
);
  input compute_wen;
  input compute_wten;
  input plm_out_ping_a0_a_d_data_rsci_oswt_unreg;
  input plm_out_ping_a0_a_d_data_rsci_iswt0;
  output plm_out_ping_a0_a_d_data_rsci_biwt;
  output plm_out_ping_a0_a_d_data_rsci_bdwt;
  output plm_out_ping_a0_a_d_data_rsci_biwt_pff;
  input plm_out_ping_a0_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_ping_a0_a_d_data_rsci_bdwt = plm_out_ping_a0_a_d_data_rsci_oswt_unreg
      & compute_wen;
  assign plm_out_ping_a0_a_d_data_rsci_biwt = (~ compute_wten) & plm_out_ping_a0_a_d_data_rsci_iswt0;
  assign plm_out_ping_a0_a_d_data_rsci_biwt_pff = compute_wen & plm_out_ping_a0_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_in_pong_a1_a_d_data_rsci_qout_d, plm_in_pong_a1_a_d_data_rsci_bawt,
      plm_in_pong_a1_a_d_data_rsci_iden, plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt,
      plm_in_pong_a1_a_d_data_rsci_biwt, plm_in_pong_a1_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_in_pong_a1_a_d_data_rsci_qout_d;
  output plm_in_pong_a1_a_d_data_rsci_bawt;
  output plm_in_pong_a1_a_d_data_rsci_iden;
  output [31:0] plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt;
  input plm_in_pong_a1_a_d_data_rsci_biwt;
  input plm_in_pong_a1_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_in_pong_a1_a_d_data_rsci_bcwt;
  reg [31:0] plm_in_pong_a1_a_d_data_rsci_qout_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_pong_a1_a_d_data_rsci_iden = plm_in_pong_a1_a_d_data_rsci_biwt |
      plm_in_pong_a1_a_d_data_rsci_bdwt;
  assign plm_in_pong_a1_a_d_data_rsci_bawt = plm_in_pong_a1_a_d_data_rsci_biwt |
      plm_in_pong_a1_a_d_data_rsci_bcwt;
  assign plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt = MUX_v_32_2_2(plm_in_pong_a1_a_d_data_rsci_qout_d,
      plm_in_pong_a1_a_d_data_rsci_qout_d_bfwt, plm_in_pong_a1_a_d_data_rsci_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_in_pong_a1_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_in_pong_a1_a_d_data_rsci_bcwt <= ~((~(plm_in_pong_a1_a_d_data_rsci_bcwt
          | plm_in_pong_a1_a_d_data_rsci_biwt)) | plm_in_pong_a1_a_d_data_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_in_pong_a1_a_d_data_rsci_biwt ) begin
      plm_in_pong_a1_a_d_data_rsci_qout_d_bfwt <= plm_in_pong_a1_a_d_data_rsci_qout_d;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_ctrl
    (
  compute_wen, compute_wten, plm_in_pong_a1_a_d_data_rsci_oswt_unreg, plm_in_pong_a1_a_d_data_rsci_iswt0,
      plm_in_pong_a1_a_d_data_rsci_biwt, plm_in_pong_a1_a_d_data_rsci_bdwt, plm_in_pong_a1_a_d_data_rsci_biwt_pff,
      plm_in_pong_a1_a_d_data_rsci_iswt0_pff
);
  input compute_wen;
  input compute_wten;
  input plm_in_pong_a1_a_d_data_rsci_oswt_unreg;
  input plm_in_pong_a1_a_d_data_rsci_iswt0;
  output plm_in_pong_a1_a_d_data_rsci_biwt;
  output plm_in_pong_a1_a_d_data_rsci_bdwt;
  output plm_in_pong_a1_a_d_data_rsci_biwt_pff;
  input plm_in_pong_a1_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_pong_a1_a_d_data_rsci_bdwt = plm_in_pong_a1_a_d_data_rsci_oswt_unreg
      & compute_wen;
  assign plm_in_pong_a1_a_d_data_rsci_biwt = (~ compute_wten) & plm_in_pong_a1_a_d_data_rsci_iswt0;
  assign plm_in_pong_a1_a_d_data_rsci_biwt_pff = compute_wen & plm_in_pong_a1_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_in_pong_a0_a_d_data_rsci_qout_d, plm_in_pong_a0_a_d_data_rsci_bawt,
      plm_in_pong_a0_a_d_data_rsci_iden, plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt,
      plm_in_pong_a0_a_d_data_rsci_biwt, plm_in_pong_a0_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_in_pong_a0_a_d_data_rsci_qout_d;
  output plm_in_pong_a0_a_d_data_rsci_bawt;
  output plm_in_pong_a0_a_d_data_rsci_iden;
  output [31:0] plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt;
  input plm_in_pong_a0_a_d_data_rsci_biwt;
  input plm_in_pong_a0_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_in_pong_a0_a_d_data_rsci_bcwt;
  reg [31:0] plm_in_pong_a0_a_d_data_rsci_qout_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_pong_a0_a_d_data_rsci_iden = plm_in_pong_a0_a_d_data_rsci_biwt |
      plm_in_pong_a0_a_d_data_rsci_bdwt;
  assign plm_in_pong_a0_a_d_data_rsci_bawt = plm_in_pong_a0_a_d_data_rsci_biwt |
      plm_in_pong_a0_a_d_data_rsci_bcwt;
  assign plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt = MUX_v_32_2_2(plm_in_pong_a0_a_d_data_rsci_qout_d,
      plm_in_pong_a0_a_d_data_rsci_qout_d_bfwt, plm_in_pong_a0_a_d_data_rsci_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_in_pong_a0_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_in_pong_a0_a_d_data_rsci_bcwt <= ~((~(plm_in_pong_a0_a_d_data_rsci_bcwt
          | plm_in_pong_a0_a_d_data_rsci_biwt)) | plm_in_pong_a0_a_d_data_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_in_pong_a0_a_d_data_rsci_biwt ) begin
      plm_in_pong_a0_a_d_data_rsci_qout_d_bfwt <= plm_in_pong_a0_a_d_data_rsci_qout_d;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_ctrl
    (
  compute_wen, compute_wten, plm_in_pong_a0_a_d_data_rsci_oswt_unreg, plm_in_pong_a0_a_d_data_rsci_iswt0,
      plm_in_pong_a0_a_d_data_rsci_biwt, plm_in_pong_a0_a_d_data_rsci_bdwt, plm_in_pong_a0_a_d_data_rsci_biwt_pff,
      plm_in_pong_a0_a_d_data_rsci_iswt0_pff
);
  input compute_wen;
  input compute_wten;
  input plm_in_pong_a0_a_d_data_rsci_oswt_unreg;
  input plm_in_pong_a0_a_d_data_rsci_iswt0;
  output plm_in_pong_a0_a_d_data_rsci_biwt;
  output plm_in_pong_a0_a_d_data_rsci_bdwt;
  output plm_in_pong_a0_a_d_data_rsci_biwt_pff;
  input plm_in_pong_a0_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_pong_a0_a_d_data_rsci_bdwt = plm_in_pong_a0_a_d_data_rsci_oswt_unreg
      & compute_wen;
  assign plm_in_pong_a0_a_d_data_rsci_biwt = (~ compute_wten) & plm_in_pong_a0_a_d_data_rsci_iswt0;
  assign plm_in_pong_a0_a_d_data_rsci_biwt_pff = compute_wen & plm_in_pong_a0_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_in_ping_a1_a_d_data_rsci_qout_d, plm_in_ping_a1_a_d_data_rsci_bawt,
      plm_in_ping_a1_a_d_data_rsci_iden, plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt,
      plm_in_ping_a1_a_d_data_rsci_biwt, plm_in_ping_a1_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_in_ping_a1_a_d_data_rsci_qout_d;
  output plm_in_ping_a1_a_d_data_rsci_bawt;
  output plm_in_ping_a1_a_d_data_rsci_iden;
  output [31:0] plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt;
  input plm_in_ping_a1_a_d_data_rsci_biwt;
  input plm_in_ping_a1_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_in_ping_a1_a_d_data_rsci_bcwt;
  reg [31:0] plm_in_ping_a1_a_d_data_rsci_qout_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_ping_a1_a_d_data_rsci_iden = plm_in_ping_a1_a_d_data_rsci_biwt |
      plm_in_ping_a1_a_d_data_rsci_bdwt;
  assign plm_in_ping_a1_a_d_data_rsci_bawt = plm_in_ping_a1_a_d_data_rsci_biwt |
      plm_in_ping_a1_a_d_data_rsci_bcwt;
  assign plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt = MUX_v_32_2_2(plm_in_ping_a1_a_d_data_rsci_qout_d,
      plm_in_ping_a1_a_d_data_rsci_qout_d_bfwt, plm_in_ping_a1_a_d_data_rsci_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_in_ping_a1_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_in_ping_a1_a_d_data_rsci_bcwt <= ~((~(plm_in_ping_a1_a_d_data_rsci_bcwt
          | plm_in_ping_a1_a_d_data_rsci_biwt)) | plm_in_ping_a1_a_d_data_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_in_ping_a1_a_d_data_rsci_biwt ) begin
      plm_in_ping_a1_a_d_data_rsci_qout_d_bfwt <= plm_in_ping_a1_a_d_data_rsci_qout_d;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_ctrl
    (
  compute_wen, compute_wten, plm_in_ping_a1_a_d_data_rsci_oswt_unreg, plm_in_ping_a1_a_d_data_rsci_iswt0,
      plm_in_ping_a1_a_d_data_rsci_biwt, plm_in_ping_a1_a_d_data_rsci_bdwt, plm_in_ping_a1_a_d_data_rsci_biwt_pff,
      plm_in_ping_a1_a_d_data_rsci_iswt0_pff
);
  input compute_wen;
  input compute_wten;
  input plm_in_ping_a1_a_d_data_rsci_oswt_unreg;
  input plm_in_ping_a1_a_d_data_rsci_iswt0;
  output plm_in_ping_a1_a_d_data_rsci_biwt;
  output plm_in_ping_a1_a_d_data_rsci_bdwt;
  output plm_in_ping_a1_a_d_data_rsci_biwt_pff;
  input plm_in_ping_a1_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_ping_a1_a_d_data_rsci_bdwt = plm_in_ping_a1_a_d_data_rsci_oswt_unreg
      & compute_wen;
  assign plm_in_ping_a1_a_d_data_rsci_biwt = (~ compute_wten) & plm_in_ping_a1_a_d_data_rsci_iswt0;
  assign plm_in_ping_a1_a_d_data_rsci_biwt_pff = compute_wen & plm_in_ping_a1_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_dp
    (
  clk, rst, plm_in_ping_a0_a_d_data_rsci_qout_d, plm_in_ping_a0_a_d_data_rsci_bawt,
      plm_in_ping_a0_a_d_data_rsci_iden, plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt,
      plm_in_ping_a0_a_d_data_rsci_biwt, plm_in_ping_a0_a_d_data_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_in_ping_a0_a_d_data_rsci_qout_d;
  output plm_in_ping_a0_a_d_data_rsci_bawt;
  output plm_in_ping_a0_a_d_data_rsci_iden;
  output [31:0] plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt;
  input plm_in_ping_a0_a_d_data_rsci_biwt;
  input plm_in_ping_a0_a_d_data_rsci_bdwt;


  // Interconnect Declarations
  reg plm_in_ping_a0_a_d_data_rsci_bcwt;
  reg [31:0] plm_in_ping_a0_a_d_data_rsci_qout_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_ping_a0_a_d_data_rsci_iden = plm_in_ping_a0_a_d_data_rsci_biwt |
      plm_in_ping_a0_a_d_data_rsci_bdwt;
  assign plm_in_ping_a0_a_d_data_rsci_bawt = plm_in_ping_a0_a_d_data_rsci_biwt |
      plm_in_ping_a0_a_d_data_rsci_bcwt;
  assign plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt = MUX_v_32_2_2(plm_in_ping_a0_a_d_data_rsci_qout_d,
      plm_in_ping_a0_a_d_data_rsci_qout_d_bfwt, plm_in_ping_a0_a_d_data_rsci_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      plm_in_ping_a0_a_d_data_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_in_ping_a0_a_d_data_rsci_bcwt <= ~((~(plm_in_ping_a0_a_d_data_rsci_bcwt
          | plm_in_ping_a0_a_d_data_rsci_biwt)) | plm_in_ping_a0_a_d_data_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_in_ping_a0_a_d_data_rsci_biwt ) begin
      plm_in_ping_a0_a_d_data_rsci_qout_d_bfwt <= plm_in_ping_a0_a_d_data_rsci_qout_d;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_ctrl
    (
  compute_wen, compute_wten, plm_in_ping_a0_a_d_data_rsci_oswt_unreg, plm_in_ping_a0_a_d_data_rsci_iswt0,
      plm_in_ping_a0_a_d_data_rsci_biwt, plm_in_ping_a0_a_d_data_rsci_bdwt, plm_in_ping_a0_a_d_data_rsci_biwt_pff,
      plm_in_ping_a0_a_d_data_rsci_iswt0_pff
);
  input compute_wen;
  input compute_wten;
  input plm_in_ping_a0_a_d_data_rsci_oswt_unreg;
  input plm_in_ping_a0_a_d_data_rsci_iswt0;
  output plm_in_ping_a0_a_d_data_rsci_biwt;
  output plm_in_ping_a0_a_d_data_rsci_bdwt;
  output plm_in_ping_a0_a_d_data_rsci_biwt_pff;
  input plm_in_ping_a0_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_ping_a0_a_d_data_rsci_bdwt = plm_in_ping_a0_a_d_data_rsci_oswt_unreg
      & compute_wen;
  assign plm_in_ping_a0_a_d_data_rsci_biwt = (~ compute_wten) & plm_in_ping_a0_a_d_data_rsci_iswt0;
  assign plm_in_ping_a0_a_d_data_rsci_biwt_pff = compute_wen & plm_in_ping_a0_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_sync23_sync_out_mioi_sync23_sync_out_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_sync23_sync_out_mioi_sync23_sync_out_mio_wait_ctrl
    (
  compute_wten, sync23_sync_out_mioi_iswt0, sync23_sync_out_mioi_biwt, sync23_sync_out_mioi_ccs_ccore_start_rsc_dat_compute_sct,
      sync23_sync_out_mioi_ccs_ccore_done_sync_vld, sync23_sync_out_mioi_iswt0_pff
);
  input compute_wten;
  input sync23_sync_out_mioi_iswt0;
  output sync23_sync_out_mioi_biwt;
  output sync23_sync_out_mioi_ccs_ccore_start_rsc_dat_compute_sct;
  input sync23_sync_out_mioi_ccs_ccore_done_sync_vld;
  input sync23_sync_out_mioi_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign sync23_sync_out_mioi_biwt = sync23_sync_out_mioi_iswt0 & sync23_sync_out_mioi_ccs_ccore_done_sync_vld;
  assign sync23_sync_out_mioi_ccs_ccore_start_rsc_dat_compute_sct = (~ compute_wten)
      & sync23_sync_out_mioi_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_in_wr_req_Pop_mioi_in_wr_req_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_in_wr_req_Pop_mioi_in_wr_req_Pop_mio_wait_dp
    (
  clk, rst, in_wr_req_Pop_mioi_oswt_unreg, in_wr_req_Pop_mioi_bawt, in_wr_req_Pop_mioi_iden,
      in_wr_req_Pop_mioi_wen_comp, in_wr_req_Pop_mioi_idat_mxwt, in_wr_req_Pop_mioi_biwt,
      in_wr_req_Pop_mioi_bdwt, in_wr_req_Pop_mioi_bcwt, in_wr_req_Pop_mioi_idat
);
  input clk;
  input rst;
  input in_wr_req_Pop_mioi_oswt_unreg;
  output in_wr_req_Pop_mioi_bawt;
  output in_wr_req_Pop_mioi_iden;
  output in_wr_req_Pop_mioi_wen_comp;
  output [31:0] in_wr_req_Pop_mioi_idat_mxwt;
  input in_wr_req_Pop_mioi_biwt;
  input in_wr_req_Pop_mioi_bdwt;
  output in_wr_req_Pop_mioi_bcwt;
  reg in_wr_req_Pop_mioi_bcwt;
  input [31:0] in_wr_req_Pop_mioi_idat;


  // Interconnect Declarations
  reg [31:0] in_wr_req_Pop_mioi_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign in_wr_req_Pop_mioi_iden = in_wr_req_Pop_mioi_biwt | in_wr_req_Pop_mioi_bdwt;
  assign in_wr_req_Pop_mioi_bawt = in_wr_req_Pop_mioi_biwt | in_wr_req_Pop_mioi_bcwt;
  assign in_wr_req_Pop_mioi_wen_comp = (~ in_wr_req_Pop_mioi_oswt_unreg) | in_wr_req_Pop_mioi_bawt;
  assign in_wr_req_Pop_mioi_idat_mxwt = MUX_v_32_2_2(in_wr_req_Pop_mioi_idat, in_wr_req_Pop_mioi_idat_bfwt,
      in_wr_req_Pop_mioi_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      in_wr_req_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      in_wr_req_Pop_mioi_bcwt <= ~((~(in_wr_req_Pop_mioi_bcwt | in_wr_req_Pop_mioi_biwt))
          | in_wr_req_Pop_mioi_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( in_wr_req_Pop_mioi_biwt ) begin
      in_wr_req_Pop_mioi_idat_bfwt <= in_wr_req_Pop_mioi_idat;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_in_wr_req_Pop_mioi_in_wr_req_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_in_wr_req_Pop_mioi_in_wr_req_Pop_mio_wait_ctrl
    (
  compute_wen, in_wr_req_Pop_mioi_oswt_unreg, in_wr_req_Pop_mioi_iswt0, in_wr_req_Pop_mioi_ivld_oreg,
      in_wr_req_Pop_mioi_biwt, in_wr_req_Pop_mioi_bdwt, in_wr_req_Pop_mioi_bcwt,
      in_wr_req_Pop_mioi_irdy_compute_sct
);
  input compute_wen;
  input in_wr_req_Pop_mioi_oswt_unreg;
  input in_wr_req_Pop_mioi_iswt0;
  input in_wr_req_Pop_mioi_ivld_oreg;
  output in_wr_req_Pop_mioi_biwt;
  output in_wr_req_Pop_mioi_bdwt;
  input in_wr_req_Pop_mioi_bcwt;
  output in_wr_req_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations
  wire in_wr_req_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign in_wr_req_Pop_mioi_bdwt = in_wr_req_Pop_mioi_oswt_unreg & compute_wen;
  assign in_wr_req_Pop_mioi_biwt = in_wr_req_Pop_mioi_ogwt & in_wr_req_Pop_mioi_ivld_oreg;
  assign in_wr_req_Pop_mioi_ogwt = in_wr_req_Pop_mioi_iswt0 & (~ in_wr_req_Pop_mioi_bcwt);
  assign in_wr_req_Pop_mioi_irdy_compute_sct = in_wr_req_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_in_rd_rsp_Push_mioi_in_rd_rsp_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_in_rd_rsp_Push_mioi_in_rd_rsp_Push_mio_wait_dp
    (
  clk, rst, in_rd_rsp_Push_mioi_oswt_unreg, in_rd_rsp_Push_mioi_bawt, in_rd_rsp_Push_mioi_iden,
      in_rd_rsp_Push_mioi_wen_comp, in_rd_rsp_Push_mioi_biwt, in_rd_rsp_Push_mioi_bdwt,
      in_rd_rsp_Push_mioi_bcwt
);
  input clk;
  input rst;
  input in_rd_rsp_Push_mioi_oswt_unreg;
  output in_rd_rsp_Push_mioi_bawt;
  output in_rd_rsp_Push_mioi_iden;
  output in_rd_rsp_Push_mioi_wen_comp;
  input in_rd_rsp_Push_mioi_biwt;
  input in_rd_rsp_Push_mioi_bdwt;
  output in_rd_rsp_Push_mioi_bcwt;
  reg in_rd_rsp_Push_mioi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign in_rd_rsp_Push_mioi_iden = in_rd_rsp_Push_mioi_biwt | in_rd_rsp_Push_mioi_bdwt;
  assign in_rd_rsp_Push_mioi_bawt = in_rd_rsp_Push_mioi_biwt | in_rd_rsp_Push_mioi_bcwt;
  assign in_rd_rsp_Push_mioi_wen_comp = (~ in_rd_rsp_Push_mioi_oswt_unreg) | in_rd_rsp_Push_mioi_bawt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      in_rd_rsp_Push_mioi_bcwt <= 1'b0;
    end
    else begin
      in_rd_rsp_Push_mioi_bcwt <= ~((~(in_rd_rsp_Push_mioi_bcwt | in_rd_rsp_Push_mioi_biwt))
          | in_rd_rsp_Push_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_in_rd_rsp_Push_mioi_in_rd_rsp_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_in_rd_rsp_Push_mioi_in_rd_rsp_Push_mio_wait_ctrl
    (
  compute_wen, in_rd_rsp_Push_mioi_oswt_unreg, in_rd_rsp_Push_mioi_iswt0, in_rd_rsp_Push_mioi_irdy_oreg,
      in_rd_rsp_Push_mioi_biwt, in_rd_rsp_Push_mioi_bdwt, in_rd_rsp_Push_mioi_bcwt,
      in_rd_rsp_Push_mioi_ivld_compute_sct
);
  input compute_wen;
  input in_rd_rsp_Push_mioi_oswt_unreg;
  input in_rd_rsp_Push_mioi_iswt0;
  input in_rd_rsp_Push_mioi_irdy_oreg;
  output in_rd_rsp_Push_mioi_biwt;
  output in_rd_rsp_Push_mioi_bdwt;
  input in_rd_rsp_Push_mioi_bcwt;
  output in_rd_rsp_Push_mioi_ivld_compute_sct;


  // Interconnect Declarations
  wire in_rd_rsp_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign in_rd_rsp_Push_mioi_bdwt = in_rd_rsp_Push_mioi_oswt_unreg & compute_wen;
  assign in_rd_rsp_Push_mioi_biwt = in_rd_rsp_Push_mioi_ogwt & in_rd_rsp_Push_mioi_irdy_oreg;
  assign in_rd_rsp_Push_mioi_ogwt = in_rd_rsp_Push_mioi_iswt0 & (~ in_rd_rsp_Push_mioi_bcwt);
  assign in_rd_rsp_Push_mioi_ivld_compute_sct = in_rd_rsp_Push_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_sync12_sync_in_mioi_sync12_sync_in_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_sync12_sync_in_mioi_sync12_sync_in_mio_wait_ctrl
    (
  compute_wten, sync12_sync_in_mioi_iswt0, sync12_sync_in_mioi_biwt, sync12_sync_in_mioi_ccs_ccore_start_rsc_dat_compute_sct,
      sync12_sync_in_mioi_ccs_ccore_done_sync_vld, sync12_sync_in_mioi_iswt0_pff
);
  input compute_wten;
  input sync12_sync_in_mioi_iswt0;
  output sync12_sync_in_mioi_biwt;
  output sync12_sync_in_mioi_ccs_ccore_start_rsc_dat_compute_sct;
  input sync12_sync_in_mioi_ccs_ccore_done_sync_vld;
  input sync12_sync_in_mioi_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign sync12_sync_in_mioi_biwt = sync12_sync_in_mioi_iswt0 & sync12_sync_in_mioi_ccs_ccore_done_sync_vld;
  assign sync12_sync_in_mioi_ccs_ccore_start_rsc_dat_compute_sct = (~ compute_wten)
      & sync12_sync_in_mioi_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_conf2_Pop_mioi_conf2_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_conf2_Pop_mioi_conf2_Pop_mio_wait_dp (
  clk, rst, conf2_Pop_mioi_oswt, conf2_Pop_mioi_iden, conf2_Pop_mioi_wen_comp, conf2_Pop_mioi_idat_mxwt,
      conf2_Pop_mioi_biwt, conf2_Pop_mioi_bdwt, conf2_Pop_mioi_bcwt, conf2_Pop_mioi_idat
);
  input clk;
  input rst;
  input conf2_Pop_mioi_oswt;
  output conf2_Pop_mioi_iden;
  output conf2_Pop_mioi_wen_comp;
  output [95:0] conf2_Pop_mioi_idat_mxwt;
  input conf2_Pop_mioi_biwt;
  input conf2_Pop_mioi_bdwt;
  output conf2_Pop_mioi_bcwt;
  reg conf2_Pop_mioi_bcwt;
  input [95:0] conf2_Pop_mioi_idat;


  // Interconnect Declarations
  reg [95:0] conf2_Pop_mioi_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf2_Pop_mioi_iden = conf2_Pop_mioi_biwt | conf2_Pop_mioi_bdwt;
  assign conf2_Pop_mioi_wen_comp = (~ conf2_Pop_mioi_oswt) | conf2_Pop_mioi_biwt
      | conf2_Pop_mioi_bcwt;
  assign conf2_Pop_mioi_idat_mxwt = MUX_v_96_2_2(conf2_Pop_mioi_idat, conf2_Pop_mioi_idat_bfwt,
      conf2_Pop_mioi_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf2_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      conf2_Pop_mioi_bcwt <= ~((~(conf2_Pop_mioi_bcwt | conf2_Pop_mioi_biwt)) | conf2_Pop_mioi_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( conf2_Pop_mioi_biwt ) begin
      conf2_Pop_mioi_idat_bfwt <= conf2_Pop_mioi_idat;
    end
  end

  function automatic [95:0] MUX_v_96_2_2;
    input [95:0] input_0;
    input [95:0] input_1;
    input  sel;
    reg [95:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_96_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_conf2_Pop_mioi_conf2_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_conf2_Pop_mioi_conf2_Pop_mio_wait_ctrl
    (
  compute_wen, conf2_Pop_mioi_oswt, conf2_Pop_mioi_ivld_oreg, conf2_Pop_mioi_biwt,
      conf2_Pop_mioi_bdwt, conf2_Pop_mioi_bcwt, conf2_Pop_mioi_irdy_compute_sct
);
  input compute_wen;
  input conf2_Pop_mioi_oswt;
  input conf2_Pop_mioi_ivld_oreg;
  output conf2_Pop_mioi_biwt;
  output conf2_Pop_mioi_bdwt;
  input conf2_Pop_mioi_bcwt;
  output conf2_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations
  wire conf2_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf2_Pop_mioi_bdwt = conf2_Pop_mioi_oswt & compute_wen;
  assign conf2_Pop_mioi_biwt = conf2_Pop_mioi_ogwt & conf2_Pop_mioi_ivld_oreg;
  assign conf2_Pop_mioi_ogwt = conf2_Pop_mioi_oswt & (~ conf2_Pop_mioi_bcwt);
  assign conf2_Pop_mioi_irdy_compute_sct = conf2_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_wait_dp (
  clk, rst, while_for_in_length_mul_cmp_z, compute_wen, sync02_Pop_mioi_ivld, sync02_Pop_mioi_ivld_oreg,
      conf2_Pop_mioi_ivld, conf2_Pop_mioi_ivld_oreg, in_rd_rsp_Push_mioi_irdy, in_rd_rsp_Push_mioi_irdy_oreg,
      in_wr_req_Pop_mioi_ivld, in_wr_req_Pop_mioi_ivld_oreg, while_for_in_length_mul_cmp_z_oreg
);
  input clk;
  input rst;
  input [31:0] while_for_in_length_mul_cmp_z;
  input compute_wen;
  input sync02_Pop_mioi_ivld;
  output sync02_Pop_mioi_ivld_oreg;
  input conf2_Pop_mioi_ivld;
  output conf2_Pop_mioi_ivld_oreg;
  input in_rd_rsp_Push_mioi_irdy;
  output in_rd_rsp_Push_mioi_irdy_oreg;
  input in_wr_req_Pop_mioi_ivld;
  output in_wr_req_Pop_mioi_ivld_oreg;
  output [31:0] while_for_in_length_mul_cmp_z_oreg;
  reg [31:0] while_for_in_length_mul_cmp_z_oreg;


  // Interconnect Declarations
  reg sync02_Pop_mioi_ivld_oreg_rneg;
  reg conf2_Pop_mioi_ivld_oreg_rneg;
  reg in_rd_rsp_Push_mioi_irdy_oreg_rneg;
  reg in_wr_req_Pop_mioi_ivld_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign sync02_Pop_mioi_ivld_oreg = ~ sync02_Pop_mioi_ivld_oreg_rneg;
  assign conf2_Pop_mioi_ivld_oreg = ~ conf2_Pop_mioi_ivld_oreg_rneg;
  assign in_rd_rsp_Push_mioi_irdy_oreg = ~ in_rd_rsp_Push_mioi_irdy_oreg_rneg;
  assign in_wr_req_Pop_mioi_ivld_oreg = ~ in_wr_req_Pop_mioi_ivld_oreg_rneg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync02_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      conf2_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      in_rd_rsp_Push_mioi_irdy_oreg_rneg <= 1'b0;
      in_wr_req_Pop_mioi_ivld_oreg_rneg <= 1'b0;
    end
    else begin
      sync02_Pop_mioi_ivld_oreg_rneg <= ~ sync02_Pop_mioi_ivld;
      conf2_Pop_mioi_ivld_oreg_rneg <= ~ conf2_Pop_mioi_ivld;
      in_rd_rsp_Push_mioi_irdy_oreg_rneg <= ~ in_rd_rsp_Push_mioi_irdy;
      in_wr_req_Pop_mioi_ivld_oreg_rneg <= ~ in_wr_req_Pop_mioi_ivld;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen ) begin
      while_for_in_length_mul_cmp_z_oreg <= while_for_in_length_mul_cmp_z;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_sync02_Pop_mioi_sync02_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_sync02_Pop_mioi_sync02_Pop_mio_wait_dp
    (
  clk, rst, sync02_Pop_mioi_oswt, sync02_Pop_mioi_iden, sync02_Pop_mioi_wen_comp,
      sync02_Pop_mioi_biwt, sync02_Pop_mioi_bdwt, sync02_Pop_mioi_bcwt
);
  input clk;
  input rst;
  input sync02_Pop_mioi_oswt;
  output sync02_Pop_mioi_iden;
  output sync02_Pop_mioi_wen_comp;
  input sync02_Pop_mioi_biwt;
  input sync02_Pop_mioi_bdwt;
  output sync02_Pop_mioi_bcwt;
  reg sync02_Pop_mioi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign sync02_Pop_mioi_iden = sync02_Pop_mioi_biwt | sync02_Pop_mioi_bdwt;
  assign sync02_Pop_mioi_wen_comp = (~ sync02_Pop_mioi_oswt) | sync02_Pop_mioi_biwt
      | sync02_Pop_mioi_bcwt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync02_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      sync02_Pop_mioi_bcwt <= ~((~(sync02_Pop_mioi_bcwt | sync02_Pop_mioi_biwt))
          | sync02_Pop_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_sync02_Pop_mioi_sync02_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_sync02_Pop_mioi_sync02_Pop_mio_wait_ctrl
    (
  compute_wen, sync02_Pop_mioi_oswt, sync02_Pop_mioi_ivld_oreg, sync02_Pop_mioi_biwt,
      sync02_Pop_mioi_bdwt, sync02_Pop_mioi_bcwt, sync02_Pop_mioi_irdy_compute_sct
);
  input compute_wen;
  input sync02_Pop_mioi_oswt;
  input sync02_Pop_mioi_ivld_oreg;
  output sync02_Pop_mioi_biwt;
  output sync02_Pop_mioi_bdwt;
  input sync02_Pop_mioi_bcwt;
  output sync02_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations
  wire sync02_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign sync02_Pop_mioi_bdwt = sync02_Pop_mioi_oswt & compute_wen;
  assign sync02_Pop_mioi_biwt = sync02_Pop_mioi_ogwt & sync02_Pop_mioi_ivld_oreg;
  assign sync02_Pop_mioi_ogwt = sync02_Pop_mioi_oswt & (~ sync02_Pop_mioi_bcwt);
  assign sync02_Pop_mioi_irdy_compute_sct = sync02_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_87_9_32_320_320_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_87_9_32_320_320_32_gen
    (
  w_en, w_adr, din, din_d, w_adr_d, w_en_d, port_1_w_ram_ir_internal_WMASK_B_d
);
  output w_en;
  output [8:0] w_adr;
  output [31:0] din;
  input [31:0] din_d;
  input [8:0] w_adr_d;
  input w_en_d;
  input port_1_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign w_en = (port_1_w_ram_ir_internal_WMASK_B_d);
  assign w_adr = (w_adr_d);
  assign din = (din_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_86_9_32_320_320_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_86_9_32_320_320_32_gen
    (
  w_en, w_adr, din, din_d, w_adr_d, w_en_d, port_1_w_ram_ir_internal_WMASK_B_d
);
  output w_en;
  output [8:0] w_adr;
  output [31:0] din;
  input [31:0] din_d;
  input [8:0] w_adr_d;
  input w_en_d;
  input port_1_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign w_en = (port_1_w_ram_ir_internal_WMASK_B_d);
  assign w_adr = (w_adr_d);
  assign din = (din_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_85_9_32_320_320_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_85_9_32_320_320_32_gen
    (
  w_en, w_adr, din, din_d, w_adr_d, w_en_d, port_1_w_ram_ir_internal_WMASK_B_d
);
  output w_en;
  output [8:0] w_adr;
  output [31:0] din;
  input [31:0] din_d;
  input [8:0] w_adr_d;
  input w_en_d;
  input port_1_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign w_en = (port_1_w_ram_ir_internal_WMASK_B_d);
  assign w_adr = (w_adr_d);
  assign din = (din_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_84_9_32_320_320_32_gen
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_84_9_32_320_320_32_gen
    (
  w_en, w_adr, din, din_d, w_adr_d, w_en_d, port_1_w_ram_ir_internal_WMASK_B_d
);
  output w_en;
  output [8:0] w_adr;
  output [31:0] din;
  input [31:0] din_d;
  input [8:0] w_adr_d;
  input w_en_d;
  input port_1_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign w_en = (port_1_w_ram_ir_internal_WMASK_B_d);
  assign w_adr = (w_adr_d);
  assign din = (din_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_load_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_load_fsm (
  clk, rst, load_wen, fsm_output, while_C_0_tr0, while_for_C_2_tr0, while_for_for_for_C_0_tr0,
      while_for_for_C_3_tr0, while_for_C_3_tr0
);
  input clk;
  input rst;
  input load_wen;
  output [10:0] fsm_output;
  reg [10:0] fsm_output;
  input while_C_0_tr0;
  input while_for_C_2_tr0;
  input while_for_for_for_C_0_tr0;
  input while_for_for_C_3_tr0;
  input while_for_C_3_tr0;


  // FSM State Type Declaration for esp_acc_DUMMY_Ctrl_load_load_load_fsm_1
  parameter
    load_rlp_C_0 = 4'd0,
    while_C_0 = 4'd1,
    while_for_C_0 = 4'd2,
    while_for_C_1 = 4'd3,
    while_for_C_2 = 4'd4,
    while_for_for_C_0 = 4'd5,
    while_for_for_C_1 = 4'd6,
    while_for_for_for_C_0 = 4'd7,
    while_for_for_C_2 = 4'd8,
    while_for_for_C_3 = 4'd9,
    while_for_C_3 = 4'd10;

  reg [3:0] state_var;
  reg [3:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_DUMMY_Ctrl_load_load_load_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 11'b00000000010;
        if ( while_C_0_tr0 ) begin
          state_var_NS = while_C_0;
        end
        else begin
          state_var_NS = while_for_C_0;
        end
      end
      while_for_C_0 : begin
        fsm_output = 11'b00000000100;
        state_var_NS = while_for_C_1;
      end
      while_for_C_1 : begin
        fsm_output = 11'b00000001000;
        state_var_NS = while_for_C_2;
      end
      while_for_C_2 : begin
        fsm_output = 11'b00000010000;
        if ( while_for_C_2_tr0 ) begin
          state_var_NS = while_for_C_3;
        end
        else begin
          state_var_NS = while_for_for_C_0;
        end
      end
      while_for_for_C_0 : begin
        fsm_output = 11'b00000100000;
        state_var_NS = while_for_for_C_1;
      end
      while_for_for_C_1 : begin
        fsm_output = 11'b00001000000;
        state_var_NS = while_for_for_for_C_0;
      end
      while_for_for_for_C_0 : begin
        fsm_output = 11'b00010000000;
        if ( while_for_for_for_C_0_tr0 ) begin
          state_var_NS = while_for_for_C_2;
        end
        else begin
          state_var_NS = while_for_for_for_C_0;
        end
      end
      while_for_for_C_2 : begin
        fsm_output = 11'b00100000000;
        state_var_NS = while_for_for_C_3;
      end
      while_for_for_C_3 : begin
        fsm_output = 11'b01000000000;
        if ( while_for_for_C_3_tr0 ) begin
          state_var_NS = while_for_C_3;
        end
        else begin
          state_var_NS = while_for_for_C_0;
        end
      end
      while_for_C_3 : begin
        fsm_output = 11'b10000000000;
        if ( while_for_C_3_tr0 ) begin
          state_var_NS = while_C_0;
        end
        else begin
          state_var_NS = while_for_C_0;
        end
      end
      // load_rlp_C_0
      default : begin
        fsm_output = 11'b00000000001;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      state_var <= load_rlp_C_0;
    end
    else if ( load_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_staller
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_staller (
  load_wen, sync01_Pop_mioi_wen_comp, conf1_Pop_mioi_wen_comp, dma_read_ctrl_Push_mioi_wen_comp,
      dma_read_chnl_Pop_mioi_wen_comp, sync12_sync_out_mioi_wen_comp
);
  output load_wen;
  input sync01_Pop_mioi_wen_comp;
  input conf1_Pop_mioi_wen_comp;
  input dma_read_ctrl_Push_mioi_wen_comp;
  input dma_read_chnl_Pop_mioi_wen_comp;
  input sync12_sync_out_mioi_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign load_wen = sync01_Pop_mioi_wen_comp & conf1_Pop_mioi_wen_comp & dma_read_ctrl_Push_mioi_wen_comp
      & dma_read_chnl_Pop_mioi_wen_comp & sync12_sync_out_mioi_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_ctrl
    (
  plm_in_pong_a1_a_d_data_rsci_biwt_pff, load_wten_pff, plm_in_pong_a1_a_d_data_rsci_iswt0_pff
);
  output plm_in_pong_a1_a_d_data_rsci_biwt_pff;
  input load_wten_pff;
  input plm_in_pong_a1_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_pong_a1_a_d_data_rsci_biwt_pff = (~ load_wten_pff) & plm_in_pong_a1_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_ctrl
    (
  plm_in_pong_a0_a_d_data_rsci_biwt_pff, load_wten_pff, plm_in_pong_a0_a_d_data_rsci_iswt0_pff
);
  output plm_in_pong_a0_a_d_data_rsci_biwt_pff;
  input load_wten_pff;
  input plm_in_pong_a0_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_pong_a0_a_d_data_rsci_biwt_pff = (~ load_wten_pff) & plm_in_pong_a0_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_ctrl
    (
  plm_in_ping_a1_a_d_data_rsci_biwt_pff, load_wten_pff, plm_in_ping_a1_a_d_data_rsci_iswt0_pff
);
  output plm_in_ping_a1_a_d_data_rsci_biwt_pff;
  input load_wten_pff;
  input plm_in_ping_a1_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_ping_a1_a_d_data_rsci_biwt_pff = (~ load_wten_pff) & plm_in_ping_a1_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_ctrl
    (
  plm_in_ping_a0_a_d_data_rsci_biwt_pff, load_wten_pff, plm_in_ping_a0_a_d_data_rsci_iswt0_pff
);
  output plm_in_ping_a0_a_d_data_rsci_biwt_pff;
  input load_wten_pff;
  input plm_in_ping_a0_a_d_data_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_ping_a0_a_d_data_rsci_biwt_pff = (~ load_wten_pff) & plm_in_ping_a0_a_d_data_rsci_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_sync12_sync_out_mioi_sync12_sync_out_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_sync12_sync_out_mioi_sync12_sync_out_mio_wait_ctrl
    (
  load_wten, sync12_sync_out_mioi_iswt0, sync12_sync_out_mioi_biwt, sync12_sync_out_mioi_ccs_ccore_start_rsc_dat_load_sct,
      sync12_sync_out_mioi_ccs_ccore_done_sync_vld, sync12_sync_out_mioi_iswt0_pff
);
  input load_wten;
  input sync12_sync_out_mioi_iswt0;
  output sync12_sync_out_mioi_biwt;
  output sync12_sync_out_mioi_ccs_ccore_start_rsc_dat_load_sct;
  input sync12_sync_out_mioi_ccs_ccore_done_sync_vld;
  input sync12_sync_out_mioi_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign sync12_sync_out_mioi_biwt = sync12_sync_out_mioi_iswt0 & sync12_sync_out_mioi_ccs_ccore_done_sync_vld;
  assign sync12_sync_out_mioi_ccs_ccore_start_rsc_dat_load_sct = (~ load_wten) &
      sync12_sync_out_mioi_iswt0_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_dma_read_chnl_Pop_mioi_dma_read_chnl_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_dma_read_chnl_Pop_mioi_dma_read_chnl_Pop_mio_wait_dp
    (
  clk, rst, dma_read_chnl_Pop_mioi_oswt, dma_read_chnl_Pop_mioi_wen_comp, dma_read_chnl_Pop_mioi_idat_mxwt,
      dma_read_chnl_Pop_mioi_biwt, dma_read_chnl_Pop_mioi_bdwt, dma_read_chnl_Pop_mioi_bcwt,
      dma_read_chnl_Pop_mioi_idat
);
  input clk;
  input rst;
  input dma_read_chnl_Pop_mioi_oswt;
  output dma_read_chnl_Pop_mioi_wen_comp;
  output [63:0] dma_read_chnl_Pop_mioi_idat_mxwt;
  input dma_read_chnl_Pop_mioi_biwt;
  input dma_read_chnl_Pop_mioi_bdwt;
  output dma_read_chnl_Pop_mioi_bcwt;
  reg dma_read_chnl_Pop_mioi_bcwt;
  input [63:0] dma_read_chnl_Pop_mioi_idat;


  // Interconnect Declarations
  reg [63:0] dma_read_chnl_Pop_mioi_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_chnl_Pop_mioi_wen_comp = (~ dma_read_chnl_Pop_mioi_oswt) | dma_read_chnl_Pop_mioi_biwt
      | dma_read_chnl_Pop_mioi_bcwt;
  assign dma_read_chnl_Pop_mioi_idat_mxwt = MUX_v_64_2_2(dma_read_chnl_Pop_mioi_idat,
      dma_read_chnl_Pop_mioi_idat_bfwt, dma_read_chnl_Pop_mioi_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      dma_read_chnl_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      dma_read_chnl_Pop_mioi_bcwt <= ~((~(dma_read_chnl_Pop_mioi_bcwt | dma_read_chnl_Pop_mioi_biwt))
          | dma_read_chnl_Pop_mioi_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( dma_read_chnl_Pop_mioi_biwt ) begin
      dma_read_chnl_Pop_mioi_idat_bfwt <= dma_read_chnl_Pop_mioi_idat;
    end
  end

  function automatic [63:0] MUX_v_64_2_2;
    input [63:0] input_0;
    input [63:0] input_1;
    input  sel;
    reg [63:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_64_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_dma_read_chnl_Pop_mioi_dma_read_chnl_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_dma_read_chnl_Pop_mioi_dma_read_chnl_Pop_mio_wait_ctrl
    (
  load_wen, dma_read_chnl_Pop_mioi_oswt, dma_read_chnl_Pop_mioi_ivld_oreg, dma_read_chnl_Pop_mioi_biwt,
      dma_read_chnl_Pop_mioi_bdwt, dma_read_chnl_Pop_mioi_bcwt, dma_read_chnl_Pop_mioi_irdy_load_sct
);
  input load_wen;
  input dma_read_chnl_Pop_mioi_oswt;
  input dma_read_chnl_Pop_mioi_ivld_oreg;
  output dma_read_chnl_Pop_mioi_biwt;
  output dma_read_chnl_Pop_mioi_bdwt;
  input dma_read_chnl_Pop_mioi_bcwt;
  output dma_read_chnl_Pop_mioi_irdy_load_sct;


  // Interconnect Declarations
  wire dma_read_chnl_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_chnl_Pop_mioi_bdwt = dma_read_chnl_Pop_mioi_oswt & load_wen;
  assign dma_read_chnl_Pop_mioi_biwt = dma_read_chnl_Pop_mioi_ogwt & dma_read_chnl_Pop_mioi_ivld_oreg;
  assign dma_read_chnl_Pop_mioi_ogwt = dma_read_chnl_Pop_mioi_oswt & (~ dma_read_chnl_Pop_mioi_bcwt);
  assign dma_read_chnl_Pop_mioi_irdy_load_sct = dma_read_chnl_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_dma_read_ctrl_Push_mioi_dma_read_ctrl_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_dma_read_ctrl_Push_mioi_dma_read_ctrl_Push_mio_wait_ctrl
    (
  dma_read_ctrl_Push_mioi_iswt0, dma_read_ctrl_Push_mioi_irdy_oreg, dma_read_ctrl_Push_mioi_biwt
);
  input dma_read_ctrl_Push_mioi_iswt0;
  input dma_read_ctrl_Push_mioi_irdy_oreg;
  output dma_read_ctrl_Push_mioi_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_Push_mioi_biwt = dma_read_ctrl_Push_mioi_iswt0 & dma_read_ctrl_Push_mioi_irdy_oreg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_conf1_Pop_mioi_conf1_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_conf1_Pop_mioi_conf1_Pop_mio_wait_dp (
  clk, rst, conf1_Pop_mioi_oswt, conf1_Pop_mioi_wen_comp, conf1_Pop_mioi_idat_mxwt,
      conf1_Pop_mioi_biwt, conf1_Pop_mioi_bdwt, conf1_Pop_mioi_bcwt, conf1_Pop_mioi_idat
);
  input clk;
  input rst;
  input conf1_Pop_mioi_oswt;
  output conf1_Pop_mioi_wen_comp;
  output [95:0] conf1_Pop_mioi_idat_mxwt;
  input conf1_Pop_mioi_biwt;
  input conf1_Pop_mioi_bdwt;
  output conf1_Pop_mioi_bcwt;
  reg conf1_Pop_mioi_bcwt;
  input [95:0] conf1_Pop_mioi_idat;


  // Interconnect Declarations
  reg [95:0] conf1_Pop_mioi_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf1_Pop_mioi_wen_comp = (~ conf1_Pop_mioi_oswt) | conf1_Pop_mioi_biwt
      | conf1_Pop_mioi_bcwt;
  assign conf1_Pop_mioi_idat_mxwt = MUX_v_96_2_2(conf1_Pop_mioi_idat, conf1_Pop_mioi_idat_bfwt,
      conf1_Pop_mioi_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf1_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      conf1_Pop_mioi_bcwt <= ~((~(conf1_Pop_mioi_bcwt | conf1_Pop_mioi_biwt)) | conf1_Pop_mioi_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( conf1_Pop_mioi_biwt ) begin
      conf1_Pop_mioi_idat_bfwt <= conf1_Pop_mioi_idat;
    end
  end

  function automatic [95:0] MUX_v_96_2_2;
    input [95:0] input_0;
    input [95:0] input_1;
    input  sel;
    reg [95:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_96_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_conf1_Pop_mioi_conf1_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_conf1_Pop_mioi_conf1_Pop_mio_wait_ctrl (
  load_wen, conf1_Pop_mioi_oswt, conf1_Pop_mioi_ivld_oreg, conf1_Pop_mioi_biwt, conf1_Pop_mioi_bdwt,
      conf1_Pop_mioi_bcwt, conf1_Pop_mioi_irdy_load_sct
);
  input load_wen;
  input conf1_Pop_mioi_oswt;
  input conf1_Pop_mioi_ivld_oreg;
  output conf1_Pop_mioi_biwt;
  output conf1_Pop_mioi_bdwt;
  input conf1_Pop_mioi_bcwt;
  output conf1_Pop_mioi_irdy_load_sct;


  // Interconnect Declarations
  wire conf1_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf1_Pop_mioi_bdwt = conf1_Pop_mioi_oswt & load_wen;
  assign conf1_Pop_mioi_biwt = conf1_Pop_mioi_ogwt & conf1_Pop_mioi_ivld_oreg;
  assign conf1_Pop_mioi_ogwt = conf1_Pop_mioi_oswt & (~ conf1_Pop_mioi_bcwt);
  assign conf1_Pop_mioi_irdy_load_sct = conf1_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_wait_dp (
  clk, rst, while_for_len_mul_cmp_z, load_wen, sync01_Pop_mioi_ivld, sync01_Pop_mioi_ivld_oreg,
      conf1_Pop_mioi_ivld, conf1_Pop_mioi_ivld_oreg, dma_read_ctrl_Push_mioi_irdy,
      dma_read_ctrl_Push_mioi_irdy_oreg, dma_read_chnl_Pop_mioi_ivld, dma_read_chnl_Pop_mioi_ivld_oreg,
      while_for_len_mul_cmp_z_oreg
);
  input clk;
  input rst;
  input [31:0] while_for_len_mul_cmp_z;
  input load_wen;
  input sync01_Pop_mioi_ivld;
  output sync01_Pop_mioi_ivld_oreg;
  input conf1_Pop_mioi_ivld;
  output conf1_Pop_mioi_ivld_oreg;
  input dma_read_ctrl_Push_mioi_irdy;
  output dma_read_ctrl_Push_mioi_irdy_oreg;
  input dma_read_chnl_Pop_mioi_ivld;
  output dma_read_chnl_Pop_mioi_ivld_oreg;
  output [31:0] while_for_len_mul_cmp_z_oreg;
  reg [31:0] while_for_len_mul_cmp_z_oreg;


  // Interconnect Declarations
  reg sync01_Pop_mioi_ivld_oreg_rneg;
  reg conf1_Pop_mioi_ivld_oreg_rneg;
  reg dma_read_ctrl_Push_mioi_irdy_oreg_rneg;
  reg dma_read_chnl_Pop_mioi_ivld_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign sync01_Pop_mioi_ivld_oreg = ~ sync01_Pop_mioi_ivld_oreg_rneg;
  assign conf1_Pop_mioi_ivld_oreg = ~ conf1_Pop_mioi_ivld_oreg_rneg;
  assign dma_read_ctrl_Push_mioi_irdy_oreg = ~ dma_read_ctrl_Push_mioi_irdy_oreg_rneg;
  assign dma_read_chnl_Pop_mioi_ivld_oreg = ~ dma_read_chnl_Pop_mioi_ivld_oreg_rneg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync01_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      conf1_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      dma_read_ctrl_Push_mioi_irdy_oreg_rneg <= 1'b0;
      dma_read_chnl_Pop_mioi_ivld_oreg_rneg <= 1'b0;
    end
    else begin
      sync01_Pop_mioi_ivld_oreg_rneg <= ~ sync01_Pop_mioi_ivld;
      conf1_Pop_mioi_ivld_oreg_rneg <= ~ conf1_Pop_mioi_ivld;
      dma_read_ctrl_Push_mioi_irdy_oreg_rneg <= ~ dma_read_ctrl_Push_mioi_irdy;
      dma_read_chnl_Pop_mioi_ivld_oreg_rneg <= ~ dma_read_chnl_Pop_mioi_ivld;
    end
  end
  always @(posedge clk) begin
    if ( load_wen ) begin
      while_for_len_mul_cmp_z_oreg <= while_for_len_mul_cmp_z;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_sync01_Pop_mioi_sync01_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_sync01_Pop_mioi_sync01_Pop_mio_wait_dp (
  clk, rst, sync01_Pop_mioi_oswt, sync01_Pop_mioi_wen_comp, sync01_Pop_mioi_biwt,
      sync01_Pop_mioi_bdwt, sync01_Pop_mioi_bcwt
);
  input clk;
  input rst;
  input sync01_Pop_mioi_oswt;
  output sync01_Pop_mioi_wen_comp;
  input sync01_Pop_mioi_biwt;
  input sync01_Pop_mioi_bdwt;
  output sync01_Pop_mioi_bcwt;
  reg sync01_Pop_mioi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign sync01_Pop_mioi_wen_comp = (~ sync01_Pop_mioi_oswt) | sync01_Pop_mioi_biwt
      | sync01_Pop_mioi_bcwt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync01_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      sync01_Pop_mioi_bcwt <= ~((~(sync01_Pop_mioi_bcwt | sync01_Pop_mioi_biwt))
          | sync01_Pop_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_sync01_Pop_mioi_sync01_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_sync01_Pop_mioi_sync01_Pop_mio_wait_ctrl (
  load_wen, sync01_Pop_mioi_oswt, sync01_Pop_mioi_ivld_oreg, sync01_Pop_mioi_biwt,
      sync01_Pop_mioi_bdwt, sync01_Pop_mioi_bcwt, sync01_Pop_mioi_irdy_load_sct
);
  input load_wen;
  input sync01_Pop_mioi_oswt;
  input sync01_Pop_mioi_ivld_oreg;
  output sync01_Pop_mioi_biwt;
  output sync01_Pop_mioi_bdwt;
  input sync01_Pop_mioi_bcwt;
  output sync01_Pop_mioi_irdy_load_sct;


  // Interconnect Declarations
  wire sync01_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign sync01_Pop_mioi_bdwt = sync01_Pop_mioi_oswt & load_wen;
  assign sync01_Pop_mioi_biwt = sync01_Pop_mioi_ogwt & sync01_Pop_mioi_ivld_oreg;
  assign sync01_Pop_mioi_ogwt = sync01_Pop_mioi_oswt & (~ sync01_Pop_mioi_bcwt);
  assign sync01_Pop_mioi_irdy_load_sct = sync01_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_config_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_config_fsm (
  clk, rst, config_wen, fsm_output
);
  input clk;
  input rst;
  input config_wen;
  output [2:0] fsm_output;
  reg [2:0] fsm_output;


  // FSM State Type Declaration for esp_acc_DUMMY_Ctrl_config_config_config_fsm_1
  parameter
    config_rlp_C_0 = 2'd0,
    while_C_0 = 2'd1,
    while_C_1 = 2'd2;

  reg [1:0] state_var;
  reg [1:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_DUMMY_Ctrl_config_config_config_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 3'b010;
        state_var_NS = while_C_1;
      end
      while_C_1 : begin
        fsm_output = 3'b100;
        state_var_NS = while_C_0;
      end
      // config_rlp_C_0
      default : begin
        fsm_output = 3'b001;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      state_var <= config_rlp_C_0;
    end
    else if ( config_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_staller
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_staller (
  config_wen, conf_info_Pop_mioi_wen_comp, conf_info_out_Push_mioi_wen_comp, conf1_Push_mioi_wen_comp,
      conf2_Push_mioi_wen_comp, conf3_Push_mioi_wen_comp, sync00_Push_mioi_wen_comp,
      sync01_Push_mioi_wen_comp, sync02_Push_mioi_wen_comp, sync03_Push_mioi_wen_comp
);
  output config_wen;
  input conf_info_Pop_mioi_wen_comp;
  input conf_info_out_Push_mioi_wen_comp;
  input conf1_Push_mioi_wen_comp;
  input conf2_Push_mioi_wen_comp;
  input conf3_Push_mioi_wen_comp;
  input sync00_Push_mioi_wen_comp;
  input sync01_Push_mioi_wen_comp;
  input sync02_Push_mioi_wen_comp;
  input sync03_Push_mioi_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign config_wen = conf_info_Pop_mioi_wen_comp & conf_info_out_Push_mioi_wen_comp
      & conf1_Push_mioi_wen_comp & conf2_Push_mioi_wen_comp & conf3_Push_mioi_wen_comp
      & sync00_Push_mioi_wen_comp & sync01_Push_mioi_wen_comp & sync02_Push_mioi_wen_comp
      & sync03_Push_mioi_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync03_Push_mioi_sync03_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync03_Push_mioi_sync03_Push_mio_wait_dp
    (
  clk, rst, sync03_Push_mioi_oswt, sync03_Push_mioi_wen_comp, sync03_Push_mioi_biwt,
      sync03_Push_mioi_bdwt, sync03_Push_mioi_bcwt, sync03_Push_mioi_biwt_pff, sync03_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input sync03_Push_mioi_oswt;
  output sync03_Push_mioi_wen_comp;
  input sync03_Push_mioi_biwt;
  input sync03_Push_mioi_bdwt;
  output sync03_Push_mioi_bcwt;
  input sync03_Push_mioi_biwt_pff;
  output sync03_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg sync03_Push_mioi_bcwt_reg;
  wire while_nor_14_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_14_rmff = ~((~(sync03_Push_mioi_bcwt | sync03_Push_mioi_biwt))
      | sync03_Push_mioi_bdwt);
  assign sync03_Push_mioi_wen_comp = (~ sync03_Push_mioi_oswt) | sync03_Push_mioi_biwt_pff
      | sync03_Push_mioi_bcwt_pff;
  assign sync03_Push_mioi_bcwt = sync03_Push_mioi_bcwt_reg;
  assign sync03_Push_mioi_bcwt_pff = while_nor_14_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync03_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      sync03_Push_mioi_bcwt_reg <= while_nor_14_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync03_Push_mioi_sync03_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync03_Push_mioi_sync03_Push_mio_wait_ctrl
    (
  config_wen, sync03_Push_mioi_oswt, sync03_Push_mioi_irdy_oreg, sync03_Push_mioi_biwt,
      sync03_Push_mioi_bdwt, sync03_Push_mioi_bcwt, sync03_Push_mioi_ivld_config_sct,
      sync03_Push_mioi_biwt_pff, sync03_Push_mioi_oswt_pff, sync03_Push_mioi_bcwt_pff,
      sync03_Push_mioi_irdy_oreg_pff
);
  input config_wen;
  input sync03_Push_mioi_oswt;
  input sync03_Push_mioi_irdy_oreg;
  output sync03_Push_mioi_biwt;
  output sync03_Push_mioi_bdwt;
  input sync03_Push_mioi_bcwt;
  output sync03_Push_mioi_ivld_config_sct;
  output sync03_Push_mioi_biwt_pff;
  input sync03_Push_mioi_oswt_pff;
  input sync03_Push_mioi_bcwt_pff;
  input sync03_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire sync03_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign sync03_Push_mioi_bdwt = sync03_Push_mioi_oswt & config_wen;
  assign sync03_Push_mioi_ogwt = sync03_Push_mioi_oswt & (~ sync03_Push_mioi_bcwt);
  assign sync03_Push_mioi_ivld_config_sct = sync03_Push_mioi_ogwt;
  assign sync03_Push_mioi_biwt = sync03_Push_mioi_ogwt & sync03_Push_mioi_irdy_oreg;
  assign sync03_Push_mioi_biwt_pff = sync03_Push_mioi_oswt_pff & (~ sync03_Push_mioi_bcwt_pff)
      & sync03_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync02_Push_mioi_sync02_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync02_Push_mioi_sync02_Push_mio_wait_dp
    (
  clk, rst, sync02_Push_mioi_oswt, sync02_Push_mioi_wen_comp, sync02_Push_mioi_biwt,
      sync02_Push_mioi_bdwt, sync02_Push_mioi_bcwt, sync02_Push_mioi_biwt_pff, sync02_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input sync02_Push_mioi_oswt;
  output sync02_Push_mioi_wen_comp;
  input sync02_Push_mioi_biwt;
  input sync02_Push_mioi_bdwt;
  output sync02_Push_mioi_bcwt;
  input sync02_Push_mioi_biwt_pff;
  output sync02_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg sync02_Push_mioi_bcwt_reg;
  wire while_nor_12_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_12_rmff = ~((~(sync02_Push_mioi_bcwt | sync02_Push_mioi_biwt))
      | sync02_Push_mioi_bdwt);
  assign sync02_Push_mioi_wen_comp = (~ sync02_Push_mioi_oswt) | sync02_Push_mioi_biwt_pff
      | sync02_Push_mioi_bcwt_pff;
  assign sync02_Push_mioi_bcwt = sync02_Push_mioi_bcwt_reg;
  assign sync02_Push_mioi_bcwt_pff = while_nor_12_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync02_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      sync02_Push_mioi_bcwt_reg <= while_nor_12_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync02_Push_mioi_sync02_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync02_Push_mioi_sync02_Push_mio_wait_ctrl
    (
  config_wen, sync02_Push_mioi_oswt, sync02_Push_mioi_irdy_oreg, sync02_Push_mioi_biwt,
      sync02_Push_mioi_bdwt, sync02_Push_mioi_bcwt, sync02_Push_mioi_ivld_config_sct,
      sync02_Push_mioi_biwt_pff, sync02_Push_mioi_oswt_pff, sync02_Push_mioi_bcwt_pff,
      sync02_Push_mioi_irdy_oreg_pff
);
  input config_wen;
  input sync02_Push_mioi_oswt;
  input sync02_Push_mioi_irdy_oreg;
  output sync02_Push_mioi_biwt;
  output sync02_Push_mioi_bdwt;
  input sync02_Push_mioi_bcwt;
  output sync02_Push_mioi_ivld_config_sct;
  output sync02_Push_mioi_biwt_pff;
  input sync02_Push_mioi_oswt_pff;
  input sync02_Push_mioi_bcwt_pff;
  input sync02_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire sync02_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign sync02_Push_mioi_bdwt = sync02_Push_mioi_oswt & config_wen;
  assign sync02_Push_mioi_ogwt = sync02_Push_mioi_oswt & (~ sync02_Push_mioi_bcwt);
  assign sync02_Push_mioi_ivld_config_sct = sync02_Push_mioi_ogwt;
  assign sync02_Push_mioi_biwt = sync02_Push_mioi_ogwt & sync02_Push_mioi_irdy_oreg;
  assign sync02_Push_mioi_biwt_pff = sync02_Push_mioi_oswt_pff & (~ sync02_Push_mioi_bcwt_pff)
      & sync02_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync01_Push_mioi_sync01_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync01_Push_mioi_sync01_Push_mio_wait_dp
    (
  clk, rst, sync01_Push_mioi_oswt, sync01_Push_mioi_wen_comp, sync01_Push_mioi_biwt,
      sync01_Push_mioi_bdwt, sync01_Push_mioi_bcwt, sync01_Push_mioi_biwt_pff, sync01_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input sync01_Push_mioi_oswt;
  output sync01_Push_mioi_wen_comp;
  input sync01_Push_mioi_biwt;
  input sync01_Push_mioi_bdwt;
  output sync01_Push_mioi_bcwt;
  input sync01_Push_mioi_biwt_pff;
  output sync01_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg sync01_Push_mioi_bcwt_reg;
  wire while_nor_10_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_10_rmff = ~((~(sync01_Push_mioi_bcwt | sync01_Push_mioi_biwt))
      | sync01_Push_mioi_bdwt);
  assign sync01_Push_mioi_wen_comp = (~ sync01_Push_mioi_oswt) | sync01_Push_mioi_biwt_pff
      | sync01_Push_mioi_bcwt_pff;
  assign sync01_Push_mioi_bcwt = sync01_Push_mioi_bcwt_reg;
  assign sync01_Push_mioi_bcwt_pff = while_nor_10_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync01_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      sync01_Push_mioi_bcwt_reg <= while_nor_10_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync01_Push_mioi_sync01_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync01_Push_mioi_sync01_Push_mio_wait_ctrl
    (
  config_wen, sync01_Push_mioi_oswt, sync01_Push_mioi_irdy_oreg, sync01_Push_mioi_biwt,
      sync01_Push_mioi_bdwt, sync01_Push_mioi_bcwt, sync01_Push_mioi_ivld_config_sct,
      sync01_Push_mioi_biwt_pff, sync01_Push_mioi_oswt_pff, sync01_Push_mioi_bcwt_pff,
      sync01_Push_mioi_irdy_oreg_pff
);
  input config_wen;
  input sync01_Push_mioi_oswt;
  input sync01_Push_mioi_irdy_oreg;
  output sync01_Push_mioi_biwt;
  output sync01_Push_mioi_bdwt;
  input sync01_Push_mioi_bcwt;
  output sync01_Push_mioi_ivld_config_sct;
  output sync01_Push_mioi_biwt_pff;
  input sync01_Push_mioi_oswt_pff;
  input sync01_Push_mioi_bcwt_pff;
  input sync01_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire sync01_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign sync01_Push_mioi_bdwt = sync01_Push_mioi_oswt & config_wen;
  assign sync01_Push_mioi_ogwt = sync01_Push_mioi_oswt & (~ sync01_Push_mioi_bcwt);
  assign sync01_Push_mioi_ivld_config_sct = sync01_Push_mioi_ogwt;
  assign sync01_Push_mioi_biwt = sync01_Push_mioi_ogwt & sync01_Push_mioi_irdy_oreg;
  assign sync01_Push_mioi_biwt_pff = sync01_Push_mioi_oswt_pff & (~ sync01_Push_mioi_bcwt_pff)
      & sync01_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync00_Push_mioi_sync00_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync00_Push_mioi_sync00_Push_mio_wait_dp
    (
  clk, rst, sync00_Push_mioi_oswt, sync00_Push_mioi_wen_comp, sync00_Push_mioi_biwt,
      sync00_Push_mioi_bdwt, sync00_Push_mioi_bcwt, sync00_Push_mioi_biwt_pff, sync00_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input sync00_Push_mioi_oswt;
  output sync00_Push_mioi_wen_comp;
  input sync00_Push_mioi_biwt;
  input sync00_Push_mioi_bdwt;
  output sync00_Push_mioi_bcwt;
  input sync00_Push_mioi_biwt_pff;
  output sync00_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg sync00_Push_mioi_bcwt_reg;
  wire while_nor_8_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_8_rmff = ~((~(sync00_Push_mioi_bcwt | sync00_Push_mioi_biwt))
      | sync00_Push_mioi_bdwt);
  assign sync00_Push_mioi_wen_comp = (~ sync00_Push_mioi_oswt) | sync00_Push_mioi_biwt_pff
      | sync00_Push_mioi_bcwt_pff;
  assign sync00_Push_mioi_bcwt = sync00_Push_mioi_bcwt_reg;
  assign sync00_Push_mioi_bcwt_pff = while_nor_8_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync00_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      sync00_Push_mioi_bcwt_reg <= while_nor_8_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync00_Push_mioi_sync00_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync00_Push_mioi_sync00_Push_mio_wait_ctrl
    (
  config_wen, sync00_Push_mioi_oswt, sync00_Push_mioi_irdy_oreg, sync00_Push_mioi_biwt,
      sync00_Push_mioi_bdwt, sync00_Push_mioi_bcwt, sync00_Push_mioi_ivld_config_sct,
      sync00_Push_mioi_biwt_pff, sync00_Push_mioi_oswt_pff, sync00_Push_mioi_bcwt_pff,
      sync00_Push_mioi_irdy_oreg_pff
);
  input config_wen;
  input sync00_Push_mioi_oswt;
  input sync00_Push_mioi_irdy_oreg;
  output sync00_Push_mioi_biwt;
  output sync00_Push_mioi_bdwt;
  input sync00_Push_mioi_bcwt;
  output sync00_Push_mioi_ivld_config_sct;
  output sync00_Push_mioi_biwt_pff;
  input sync00_Push_mioi_oswt_pff;
  input sync00_Push_mioi_bcwt_pff;
  input sync00_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire sync00_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign sync00_Push_mioi_bdwt = sync00_Push_mioi_oswt & config_wen;
  assign sync00_Push_mioi_ogwt = sync00_Push_mioi_oswt & (~ sync00_Push_mioi_bcwt);
  assign sync00_Push_mioi_ivld_config_sct = sync00_Push_mioi_ogwt;
  assign sync00_Push_mioi_biwt = sync00_Push_mioi_ogwt & sync00_Push_mioi_irdy_oreg;
  assign sync00_Push_mioi_biwt_pff = sync00_Push_mioi_oswt_pff & (~ sync00_Push_mioi_bcwt_pff)
      & sync00_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf3_Push_mioi_conf3_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf3_Push_mioi_conf3_Push_mio_wait_dp (
  clk, rst, conf3_Push_mioi_oswt, conf3_Push_mioi_wen_comp, conf3_Push_mioi_biwt,
      conf3_Push_mioi_bdwt, conf3_Push_mioi_bcwt, conf3_Push_mioi_biwt_pff, conf3_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input conf3_Push_mioi_oswt;
  output conf3_Push_mioi_wen_comp;
  input conf3_Push_mioi_biwt;
  input conf3_Push_mioi_bdwt;
  output conf3_Push_mioi_bcwt;
  input conf3_Push_mioi_biwt_pff;
  output conf3_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg conf3_Push_mioi_bcwt_reg;
  wire while_nor_6_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_6_rmff = ~((~(conf3_Push_mioi_bcwt | conf3_Push_mioi_biwt)) |
      conf3_Push_mioi_bdwt);
  assign conf3_Push_mioi_wen_comp = (~ conf3_Push_mioi_oswt) | conf3_Push_mioi_biwt_pff
      | conf3_Push_mioi_bcwt_pff;
  assign conf3_Push_mioi_bcwt = conf3_Push_mioi_bcwt_reg;
  assign conf3_Push_mioi_bcwt_pff = while_nor_6_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf3_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      conf3_Push_mioi_bcwt_reg <= while_nor_6_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf3_Push_mioi_conf3_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf3_Push_mioi_conf3_Push_mio_wait_ctrl
    (
  config_wen, conf3_Push_mioi_oswt, conf3_Push_mioi_irdy_oreg, conf3_Push_mioi_biwt,
      conf3_Push_mioi_bdwt, conf3_Push_mioi_bcwt, conf3_Push_mioi_ivld_config_sct,
      conf3_Push_mioi_biwt_pff, conf3_Push_mioi_oswt_pff, conf3_Push_mioi_bcwt_pff,
      conf3_Push_mioi_irdy_oreg_pff
);
  input config_wen;
  input conf3_Push_mioi_oswt;
  input conf3_Push_mioi_irdy_oreg;
  output conf3_Push_mioi_biwt;
  output conf3_Push_mioi_bdwt;
  input conf3_Push_mioi_bcwt;
  output conf3_Push_mioi_ivld_config_sct;
  output conf3_Push_mioi_biwt_pff;
  input conf3_Push_mioi_oswt_pff;
  input conf3_Push_mioi_bcwt_pff;
  input conf3_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf3_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf3_Push_mioi_bdwt = conf3_Push_mioi_oswt & config_wen;
  assign conf3_Push_mioi_ogwt = conf3_Push_mioi_oswt & (~ conf3_Push_mioi_bcwt);
  assign conf3_Push_mioi_ivld_config_sct = conf3_Push_mioi_ogwt;
  assign conf3_Push_mioi_biwt = conf3_Push_mioi_ogwt & conf3_Push_mioi_irdy_oreg;
  assign conf3_Push_mioi_biwt_pff = conf3_Push_mioi_oswt_pff & (~ conf3_Push_mioi_bcwt_pff)
      & conf3_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf2_Push_mioi_conf2_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf2_Push_mioi_conf2_Push_mio_wait_dp (
  clk, rst, conf2_Push_mioi_oswt, conf2_Push_mioi_wen_comp, conf2_Push_mioi_biwt,
      conf2_Push_mioi_bdwt, conf2_Push_mioi_bcwt, conf2_Push_mioi_biwt_pff, conf2_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input conf2_Push_mioi_oswt;
  output conf2_Push_mioi_wen_comp;
  input conf2_Push_mioi_biwt;
  input conf2_Push_mioi_bdwt;
  output conf2_Push_mioi_bcwt;
  input conf2_Push_mioi_biwt_pff;
  output conf2_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg conf2_Push_mioi_bcwt_reg;
  wire while_nor_4_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_4_rmff = ~((~(conf2_Push_mioi_bcwt | conf2_Push_mioi_biwt)) |
      conf2_Push_mioi_bdwt);
  assign conf2_Push_mioi_wen_comp = (~ conf2_Push_mioi_oswt) | conf2_Push_mioi_biwt_pff
      | conf2_Push_mioi_bcwt_pff;
  assign conf2_Push_mioi_bcwt = conf2_Push_mioi_bcwt_reg;
  assign conf2_Push_mioi_bcwt_pff = while_nor_4_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf2_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      conf2_Push_mioi_bcwt_reg <= while_nor_4_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf2_Push_mioi_conf2_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf2_Push_mioi_conf2_Push_mio_wait_ctrl
    (
  config_wen, conf2_Push_mioi_oswt, conf2_Push_mioi_irdy_oreg, conf2_Push_mioi_biwt,
      conf2_Push_mioi_bdwt, conf2_Push_mioi_bcwt, conf2_Push_mioi_ivld_config_sct,
      conf2_Push_mioi_biwt_pff, conf2_Push_mioi_oswt_pff, conf2_Push_mioi_bcwt_pff,
      conf2_Push_mioi_irdy_oreg_pff
);
  input config_wen;
  input conf2_Push_mioi_oswt;
  input conf2_Push_mioi_irdy_oreg;
  output conf2_Push_mioi_biwt;
  output conf2_Push_mioi_bdwt;
  input conf2_Push_mioi_bcwt;
  output conf2_Push_mioi_ivld_config_sct;
  output conf2_Push_mioi_biwt_pff;
  input conf2_Push_mioi_oswt_pff;
  input conf2_Push_mioi_bcwt_pff;
  input conf2_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf2_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf2_Push_mioi_bdwt = conf2_Push_mioi_oswt & config_wen;
  assign conf2_Push_mioi_ogwt = conf2_Push_mioi_oswt & (~ conf2_Push_mioi_bcwt);
  assign conf2_Push_mioi_ivld_config_sct = conf2_Push_mioi_ogwt;
  assign conf2_Push_mioi_biwt = conf2_Push_mioi_ogwt & conf2_Push_mioi_irdy_oreg;
  assign conf2_Push_mioi_biwt_pff = conf2_Push_mioi_oswt_pff & (~ conf2_Push_mioi_bcwt_pff)
      & conf2_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf1_Push_mioi_conf1_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf1_Push_mioi_conf1_Push_mio_wait_dp (
  clk, rst, conf1_Push_mioi_oswt, conf1_Push_mioi_wen_comp, conf1_Push_mioi_biwt,
      conf1_Push_mioi_bdwt, conf1_Push_mioi_bcwt, conf1_Push_mioi_biwt_pff, conf1_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input conf1_Push_mioi_oswt;
  output conf1_Push_mioi_wen_comp;
  input conf1_Push_mioi_biwt;
  input conf1_Push_mioi_bdwt;
  output conf1_Push_mioi_bcwt;
  input conf1_Push_mioi_biwt_pff;
  output conf1_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg conf1_Push_mioi_bcwt_reg;
  wire while_nor_2_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_2_rmff = ~((~(conf1_Push_mioi_bcwt | conf1_Push_mioi_biwt)) |
      conf1_Push_mioi_bdwt);
  assign conf1_Push_mioi_wen_comp = (~ conf1_Push_mioi_oswt) | conf1_Push_mioi_biwt_pff
      | conf1_Push_mioi_bcwt_pff;
  assign conf1_Push_mioi_bcwt = conf1_Push_mioi_bcwt_reg;
  assign conf1_Push_mioi_bcwt_pff = while_nor_2_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf1_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      conf1_Push_mioi_bcwt_reg <= while_nor_2_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf1_Push_mioi_conf1_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf1_Push_mioi_conf1_Push_mio_wait_ctrl
    (
  config_wen, conf1_Push_mioi_oswt, conf1_Push_mioi_irdy_oreg, conf1_Push_mioi_biwt,
      conf1_Push_mioi_bdwt, conf1_Push_mioi_bcwt, conf1_Push_mioi_ivld_config_sct,
      conf1_Push_mioi_biwt_pff, conf1_Push_mioi_oswt_pff, conf1_Push_mioi_bcwt_pff,
      conf1_Push_mioi_irdy_oreg_pff
);
  input config_wen;
  input conf1_Push_mioi_oswt;
  input conf1_Push_mioi_irdy_oreg;
  output conf1_Push_mioi_biwt;
  output conf1_Push_mioi_bdwt;
  input conf1_Push_mioi_bcwt;
  output conf1_Push_mioi_ivld_config_sct;
  output conf1_Push_mioi_biwt_pff;
  input conf1_Push_mioi_oswt_pff;
  input conf1_Push_mioi_bcwt_pff;
  input conf1_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf1_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf1_Push_mioi_bdwt = conf1_Push_mioi_oswt & config_wen;
  assign conf1_Push_mioi_ogwt = conf1_Push_mioi_oswt & (~ conf1_Push_mioi_bcwt);
  assign conf1_Push_mioi_ivld_config_sct = conf1_Push_mioi_ogwt;
  assign conf1_Push_mioi_biwt = conf1_Push_mioi_ogwt & conf1_Push_mioi_irdy_oreg;
  assign conf1_Push_mioi_biwt_pff = conf1_Push_mioi_oswt_pff & (~ conf1_Push_mioi_bcwt_pff)
      & conf1_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf_info_out_Push_mioi_conf_info_out_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf_info_out_Push_mioi_conf_info_out_Push_mio_wait_dp
    (
  clk, rst, conf_info_out_Push_mioi_oswt, conf_info_out_Push_mioi_wen_comp, conf_info_out_Push_mioi_biwt,
      conf_info_out_Push_mioi_bdwt, conf_info_out_Push_mioi_bcwt, conf_info_out_Push_mioi_biwt_pff,
      conf_info_out_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input conf_info_out_Push_mioi_oswt;
  output conf_info_out_Push_mioi_wen_comp;
  input conf_info_out_Push_mioi_biwt;
  input conf_info_out_Push_mioi_bdwt;
  output conf_info_out_Push_mioi_bcwt;
  input conf_info_out_Push_mioi_biwt_pff;
  output conf_info_out_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg conf_info_out_Push_mioi_bcwt_reg;
  wire while_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_rmff = ~((~(conf_info_out_Push_mioi_bcwt | conf_info_out_Push_mioi_biwt))
      | conf_info_out_Push_mioi_bdwt);
  assign conf_info_out_Push_mioi_wen_comp = (~ conf_info_out_Push_mioi_oswt) | conf_info_out_Push_mioi_biwt_pff
      | conf_info_out_Push_mioi_bcwt_pff;
  assign conf_info_out_Push_mioi_bcwt = conf_info_out_Push_mioi_bcwt_reg;
  assign conf_info_out_Push_mioi_bcwt_pff = while_nor_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf_info_out_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      conf_info_out_Push_mioi_bcwt_reg <= while_nor_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf_info_out_Push_mioi_conf_info_out_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf_info_out_Push_mioi_conf_info_out_Push_mio_wait_ctrl
    (
  config_wen, conf_info_out_Push_mioi_oswt, conf_info_out_Push_mioi_irdy_oreg, conf_info_out_Push_mioi_biwt,
      conf_info_out_Push_mioi_bdwt, conf_info_out_Push_mioi_bcwt, conf_info_out_Push_mioi_ivld_config_sct,
      conf_info_out_Push_mioi_biwt_pff, conf_info_out_Push_mioi_oswt_pff, conf_info_out_Push_mioi_bcwt_pff,
      conf_info_out_Push_mioi_irdy_oreg_pff
);
  input config_wen;
  input conf_info_out_Push_mioi_oswt;
  input conf_info_out_Push_mioi_irdy_oreg;
  output conf_info_out_Push_mioi_biwt;
  output conf_info_out_Push_mioi_bdwt;
  input conf_info_out_Push_mioi_bcwt;
  output conf_info_out_Push_mioi_ivld_config_sct;
  output conf_info_out_Push_mioi_biwt_pff;
  input conf_info_out_Push_mioi_oswt_pff;
  input conf_info_out_Push_mioi_bcwt_pff;
  input conf_info_out_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf_info_out_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_out_Push_mioi_bdwt = conf_info_out_Push_mioi_oswt & config_wen;
  assign conf_info_out_Push_mioi_ogwt = conf_info_out_Push_mioi_oswt & (~ conf_info_out_Push_mioi_bcwt);
  assign conf_info_out_Push_mioi_ivld_config_sct = conf_info_out_Push_mioi_ogwt;
  assign conf_info_out_Push_mioi_biwt = conf_info_out_Push_mioi_ogwt & conf_info_out_Push_mioi_irdy_oreg;
  assign conf_info_out_Push_mioi_biwt_pff = conf_info_out_Push_mioi_oswt_pff & (~
      conf_info_out_Push_mioi_bcwt_pff) & conf_info_out_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_wait_dp (
  clk, rst, conf_info_out_Push_mioi_irdy, conf_info_out_Push_mioi_irdy_oreg, conf1_Push_mioi_irdy,
      conf1_Push_mioi_irdy_oreg, conf2_Push_mioi_irdy, conf2_Push_mioi_irdy_oreg,
      conf3_Push_mioi_irdy, conf3_Push_mioi_irdy_oreg, sync00_Push_mioi_irdy, sync00_Push_mioi_irdy_oreg,
      sync01_Push_mioi_irdy, sync01_Push_mioi_irdy_oreg, sync02_Push_mioi_irdy, sync02_Push_mioi_irdy_oreg,
      sync03_Push_mioi_irdy, sync03_Push_mioi_irdy_oreg
);
  input clk;
  input rst;
  input conf_info_out_Push_mioi_irdy;
  output conf_info_out_Push_mioi_irdy_oreg;
  input conf1_Push_mioi_irdy;
  output conf1_Push_mioi_irdy_oreg;
  input conf2_Push_mioi_irdy;
  output conf2_Push_mioi_irdy_oreg;
  input conf3_Push_mioi_irdy;
  output conf3_Push_mioi_irdy_oreg;
  input sync00_Push_mioi_irdy;
  output sync00_Push_mioi_irdy_oreg;
  input sync01_Push_mioi_irdy;
  output sync01_Push_mioi_irdy_oreg;
  input sync02_Push_mioi_irdy;
  output sync02_Push_mioi_irdy_oreg;
  input sync03_Push_mioi_irdy;
  output sync03_Push_mioi_irdy_oreg;


  // Interconnect Declarations
  reg conf_info_out_Push_mioi_irdy_oreg_rneg;
  reg conf1_Push_mioi_irdy_oreg_rneg;
  reg conf2_Push_mioi_irdy_oreg_rneg;
  reg conf3_Push_mioi_irdy_oreg_rneg;
  reg sync00_Push_mioi_irdy_oreg_rneg;
  reg sync01_Push_mioi_irdy_oreg_rneg;
  reg sync02_Push_mioi_irdy_oreg_rneg;
  reg sync03_Push_mioi_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_out_Push_mioi_irdy_oreg = ~ conf_info_out_Push_mioi_irdy_oreg_rneg;
  assign conf1_Push_mioi_irdy_oreg = ~ conf1_Push_mioi_irdy_oreg_rneg;
  assign conf2_Push_mioi_irdy_oreg = ~ conf2_Push_mioi_irdy_oreg_rneg;
  assign conf3_Push_mioi_irdy_oreg = ~ conf3_Push_mioi_irdy_oreg_rneg;
  assign sync00_Push_mioi_irdy_oreg = ~ sync00_Push_mioi_irdy_oreg_rneg;
  assign sync01_Push_mioi_irdy_oreg = ~ sync01_Push_mioi_irdy_oreg_rneg;
  assign sync02_Push_mioi_irdy_oreg = ~ sync02_Push_mioi_irdy_oreg_rneg;
  assign sync03_Push_mioi_irdy_oreg = ~ sync03_Push_mioi_irdy_oreg_rneg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf_info_out_Push_mioi_irdy_oreg_rneg <= 1'b0;
      conf1_Push_mioi_irdy_oreg_rneg <= 1'b0;
      conf2_Push_mioi_irdy_oreg_rneg <= 1'b0;
      conf3_Push_mioi_irdy_oreg_rneg <= 1'b0;
      sync00_Push_mioi_irdy_oreg_rneg <= 1'b0;
      sync01_Push_mioi_irdy_oreg_rneg <= 1'b0;
      sync02_Push_mioi_irdy_oreg_rneg <= 1'b0;
      sync03_Push_mioi_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      conf_info_out_Push_mioi_irdy_oreg_rneg <= ~ conf_info_out_Push_mioi_irdy;
      conf1_Push_mioi_irdy_oreg_rneg <= ~ conf1_Push_mioi_irdy;
      conf2_Push_mioi_irdy_oreg_rneg <= ~ conf2_Push_mioi_irdy;
      conf3_Push_mioi_irdy_oreg_rneg <= ~ conf3_Push_mioi_irdy;
      sync00_Push_mioi_irdy_oreg_rneg <= ~ sync00_Push_mioi_irdy;
      sync01_Push_mioi_irdy_oreg_rneg <= ~ sync01_Push_mioi_irdy;
      sync02_Push_mioi_irdy_oreg_rneg <= ~ sync02_Push_mioi_irdy;
      sync03_Push_mioi_irdy_oreg_rneg <= ~ sync03_Push_mioi_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf_info_Pop_mioi_conf_info_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf_info_Pop_mioi_conf_info_Pop_mio_wait_ctrl
    (
  conf_info_Pop_mioi_iswt0, conf_info_Pop_mioi_ivld_oreg, conf_info_Pop_mioi_biwt
);
  input conf_info_Pop_mioi_iswt0;
  input conf_info_Pop_mioi_ivld_oreg;
  output conf_info_Pop_mioi_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign conf_info_Pop_mioi_biwt = conf_info_Pop_mioi_iswt0 & conf_info_Pop_mioi_ivld_oreg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1 (
  clk, rst, plm_out_pong_a1_a_d_data_rsci_qout_d, plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      store_wen, store_wten, plm_out_pong_a1_a_d_data_rsci_oswt, plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt,
      plm_out_pong_a1_a_d_data_rsci_oswt_pff
);
  input clk;
  input rst;
  input [31:0] plm_out_pong_a1_a_d_data_rsci_qout_d;
  output plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input store_wen;
  input store_wten;
  input plm_out_pong_a1_a_d_data_rsci_oswt;
  output [31:0] plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt;
  input plm_out_pong_a1_a_d_data_rsci_oswt_pff;


  // Interconnect Declarations
  wire plm_out_pong_a1_a_d_data_rsci_biwt;
  wire plm_out_pong_a1_a_d_data_rsci_bdwt;
  wire plm_out_pong_a1_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_ctrl
      Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_ctrl_inst
      (
      .store_wen(store_wen),
      .store_wten(store_wten),
      .plm_out_pong_a1_a_d_data_rsci_oswt(plm_out_pong_a1_a_d_data_rsci_oswt),
      .plm_out_pong_a1_a_d_data_rsci_biwt(plm_out_pong_a1_a_d_data_rsci_biwt),
      .plm_out_pong_a1_a_d_data_rsci_bdwt(plm_out_pong_a1_a_d_data_rsci_bdwt),
      .plm_out_pong_a1_a_d_data_rsci_biwt_pff(plm_out_pong_a1_a_d_data_rsci_biwt_iff),
      .plm_out_pong_a1_a_d_data_rsci_oswt_pff(plm_out_pong_a1_a_d_data_rsci_oswt_pff)
    );
  esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_dp
      Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_pong_a1_a_d_data_rsci_qout_d(plm_out_pong_a1_a_d_data_rsci_qout_d),
      .plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt(plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt),
      .plm_out_pong_a1_a_d_data_rsci_biwt(plm_out_pong_a1_a_d_data_rsci_biwt),
      .plm_out_pong_a1_a_d_data_rsci_bdwt(plm_out_pong_a1_a_d_data_rsci_bdwt)
    );
  assign plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_out_pong_a1_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1 (
  clk, rst, plm_out_pong_a0_a_d_data_rsci_qout_d, plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      store_wen, store_wten, plm_out_pong_a0_a_d_data_rsci_oswt, plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt,
      plm_out_pong_a0_a_d_data_rsci_oswt_pff
);
  input clk;
  input rst;
  input [31:0] plm_out_pong_a0_a_d_data_rsci_qout_d;
  output plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input store_wen;
  input store_wten;
  input plm_out_pong_a0_a_d_data_rsci_oswt;
  output [31:0] plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt;
  input plm_out_pong_a0_a_d_data_rsci_oswt_pff;


  // Interconnect Declarations
  wire plm_out_pong_a0_a_d_data_rsci_biwt;
  wire plm_out_pong_a0_a_d_data_rsci_bdwt;
  wire plm_out_pong_a0_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_ctrl
      Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_ctrl_inst
      (
      .store_wen(store_wen),
      .store_wten(store_wten),
      .plm_out_pong_a0_a_d_data_rsci_oswt(plm_out_pong_a0_a_d_data_rsci_oswt),
      .plm_out_pong_a0_a_d_data_rsci_biwt(plm_out_pong_a0_a_d_data_rsci_biwt),
      .plm_out_pong_a0_a_d_data_rsci_bdwt(plm_out_pong_a0_a_d_data_rsci_bdwt),
      .plm_out_pong_a0_a_d_data_rsci_biwt_pff(plm_out_pong_a0_a_d_data_rsci_biwt_iff),
      .plm_out_pong_a0_a_d_data_rsci_oswt_pff(plm_out_pong_a0_a_d_data_rsci_oswt_pff)
    );
  esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_dp
      Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_pong_a0_a_d_data_rsci_qout_d(plm_out_pong_a0_a_d_data_rsci_qout_d),
      .plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt(plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt),
      .plm_out_pong_a0_a_d_data_rsci_biwt(plm_out_pong_a0_a_d_data_rsci_biwt),
      .plm_out_pong_a0_a_d_data_rsci_bdwt(plm_out_pong_a0_a_d_data_rsci_bdwt)
    );
  assign plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_out_pong_a0_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1 (
  clk, rst, plm_out_ping_a1_a_d_data_rsci_qout_d, plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      store_wen, store_wten, plm_out_ping_a1_a_d_data_rsci_oswt, plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt,
      plm_out_ping_a1_a_d_data_rsci_oswt_pff
);
  input clk;
  input rst;
  input [31:0] plm_out_ping_a1_a_d_data_rsci_qout_d;
  output plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input store_wen;
  input store_wten;
  input plm_out_ping_a1_a_d_data_rsci_oswt;
  output [31:0] plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt;
  input plm_out_ping_a1_a_d_data_rsci_oswt_pff;


  // Interconnect Declarations
  wire plm_out_ping_a1_a_d_data_rsci_biwt;
  wire plm_out_ping_a1_a_d_data_rsci_bdwt;
  wire plm_out_ping_a1_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_ctrl
      Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_ctrl_inst
      (
      .store_wen(store_wen),
      .store_wten(store_wten),
      .plm_out_ping_a1_a_d_data_rsci_oswt(plm_out_ping_a1_a_d_data_rsci_oswt),
      .plm_out_ping_a1_a_d_data_rsci_biwt(plm_out_ping_a1_a_d_data_rsci_biwt),
      .plm_out_ping_a1_a_d_data_rsci_bdwt(plm_out_ping_a1_a_d_data_rsci_bdwt),
      .plm_out_ping_a1_a_d_data_rsci_biwt_pff(plm_out_ping_a1_a_d_data_rsci_biwt_iff),
      .plm_out_ping_a1_a_d_data_rsci_oswt_pff(plm_out_ping_a1_a_d_data_rsci_oswt_pff)
    );
  esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_dp
      Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_ping_a1_a_d_data_rsci_qout_d(plm_out_ping_a1_a_d_data_rsci_qout_d),
      .plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt(plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt),
      .plm_out_ping_a1_a_d_data_rsci_biwt(plm_out_ping_a1_a_d_data_rsci_biwt),
      .plm_out_ping_a1_a_d_data_rsci_bdwt(plm_out_ping_a1_a_d_data_rsci_bdwt)
    );
  assign plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_out_ping_a1_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1 (
  clk, rst, plm_out_ping_a0_a_d_data_rsci_qout_d, plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      store_wen, store_wten, plm_out_ping_a0_a_d_data_rsci_oswt, plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt,
      plm_out_ping_a0_a_d_data_rsci_oswt_pff
);
  input clk;
  input rst;
  input [31:0] plm_out_ping_a0_a_d_data_rsci_qout_d;
  output plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input store_wen;
  input store_wten;
  input plm_out_ping_a0_a_d_data_rsci_oswt;
  output [31:0] plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt;
  input plm_out_ping_a0_a_d_data_rsci_oswt_pff;


  // Interconnect Declarations
  wire plm_out_ping_a0_a_d_data_rsci_biwt;
  wire plm_out_ping_a0_a_d_data_rsci_bdwt;
  wire plm_out_ping_a0_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_ctrl
      Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_ctrl_inst
      (
      .store_wen(store_wen),
      .store_wten(store_wten),
      .plm_out_ping_a0_a_d_data_rsci_oswt(plm_out_ping_a0_a_d_data_rsci_oswt),
      .plm_out_ping_a0_a_d_data_rsci_biwt(plm_out_ping_a0_a_d_data_rsci_biwt),
      .plm_out_ping_a0_a_d_data_rsci_bdwt(plm_out_ping_a0_a_d_data_rsci_bdwt),
      .plm_out_ping_a0_a_d_data_rsci_biwt_pff(plm_out_ping_a0_a_d_data_rsci_biwt_iff),
      .plm_out_ping_a0_a_d_data_rsci_oswt_pff(plm_out_ping_a0_a_d_data_rsci_oswt_pff)
    );
  esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_dp
      Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_ping_a0_a_d_data_rsci_qout_d(plm_out_ping_a0_a_d_data_rsci_qout_d),
      .plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt(plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt),
      .plm_out_ping_a0_a_d_data_rsci_biwt(plm_out_ping_a0_a_d_data_rsci_biwt),
      .plm_out_ping_a0_a_d_data_rsci_bdwt(plm_out_ping_a0_a_d_data_rsci_bdwt)
    );
  assign plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_out_ping_a0_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_dma_write_chnl_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_dma_write_chnl_Push_mioi (
  clk, rst, dma_write_chnl_val, dma_write_chnl_rdy, dma_write_chnl_msg, dma_write_chnl_Push_mioi_oswt,
      dma_write_chnl_Push_mioi_wen_comp, dma_write_chnl_Push_mioi_idat, dma_write_chnl_Push_mioi_irdy,
      dma_write_chnl_Push_mioi_irdy_oreg
);
  input clk;
  input rst;
  output dma_write_chnl_val;
  input dma_write_chnl_rdy;
  output [63:0] dma_write_chnl_msg;
  input dma_write_chnl_Push_mioi_oswt;
  output dma_write_chnl_Push_mioi_wen_comp;
  input [63:0] dma_write_chnl_Push_mioi_idat;
  output dma_write_chnl_Push_mioi_irdy;
  input dma_write_chnl_Push_mioi_irdy_oreg;


  // Interconnect Declarations
  wire dma_write_chnl_Push_mioi_biwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd83),
  .width(32'sd64),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) dma_write_chnl_Push_mioi (
      .vld(dma_write_chnl_val),
      .rdy(dma_write_chnl_rdy),
      .dat(dma_write_chnl_msg),
      .idat(dma_write_chnl_Push_mioi_idat),
      .irdy(dma_write_chnl_Push_mioi_irdy),
      .ivld(dma_write_chnl_Push_mioi_oswt),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_store_store_dma_write_chnl_Push_mioi_dma_write_chnl_Push_mio_wait_ctrl
      Ctrl_store_store_dma_write_chnl_Push_mioi_dma_write_chnl_Push_mio_wait_ctrl_inst
      (
      .dma_write_chnl_Push_mioi_iswt0(dma_write_chnl_Push_mioi_oswt),
      .dma_write_chnl_Push_mioi_irdy_oreg(dma_write_chnl_Push_mioi_irdy_oreg),
      .dma_write_chnl_Push_mioi_biwt(dma_write_chnl_Push_mioi_biwt)
    );
  assign dma_write_chnl_Push_mioi_wen_comp = (~ dma_write_chnl_Push_mioi_oswt) |
      dma_write_chnl_Push_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_dma_write_ctrl_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_dma_write_ctrl_Push_mioi (
  clk, rst, dma_write_ctrl_val, dma_write_ctrl_rdy, dma_write_ctrl_msg, dma_write_ctrl_Push_mioi_oswt,
      dma_write_ctrl_Push_mioi_wen_comp, dma_write_ctrl_Push_mioi_idat, dma_write_ctrl_Push_mioi_irdy,
      dma_write_ctrl_Push_mioi_irdy_oreg
);
  input clk;
  input rst;
  output dma_write_ctrl_val;
  input dma_write_ctrl_rdy;
  output [72:0] dma_write_ctrl_msg;
  input dma_write_ctrl_Push_mioi_oswt;
  output dma_write_ctrl_Push_mioi_wen_comp;
  input [72:0] dma_write_ctrl_Push_mioi_idat;
  output dma_write_ctrl_Push_mioi_irdy;
  input dma_write_ctrl_Push_mioi_irdy_oreg;


  // Interconnect Declarations
  wire dma_write_ctrl_Push_mioi_biwt;


  // Interconnect Declarations for Component Instantiations 
  wire [72:0] nl_dma_write_ctrl_Push_mioi_idat;
  assign nl_dma_write_ctrl_Push_mioi_idat = {10'b0000000100 , (dma_write_ctrl_Push_mioi_idat[62:32])
      , 1'b0 , (dma_write_ctrl_Push_mioi_idat[30:0])};
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd82),
  .width(32'sd73),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) dma_write_ctrl_Push_mioi (
      .vld(dma_write_ctrl_val),
      .rdy(dma_write_ctrl_rdy),
      .dat(dma_write_ctrl_msg),
      .idat(nl_dma_write_ctrl_Push_mioi_idat[72:0]),
      .irdy(dma_write_ctrl_Push_mioi_irdy),
      .ivld(dma_write_ctrl_Push_mioi_oswt),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_store_store_dma_write_ctrl_Push_mioi_dma_write_ctrl_Push_mio_wait_ctrl
      Ctrl_store_store_dma_write_ctrl_Push_mioi_dma_write_ctrl_Push_mio_wait_ctrl_inst
      (
      .dma_write_ctrl_Push_mioi_iswt0(dma_write_ctrl_Push_mioi_oswt),
      .dma_write_ctrl_Push_mioi_irdy_oreg(dma_write_ctrl_Push_mioi_irdy_oreg),
      .dma_write_ctrl_Push_mioi_biwt(dma_write_ctrl_Push_mioi_biwt)
    );
  assign dma_write_ctrl_Push_mioi_wen_comp = (~ dma_write_ctrl_Push_mioi_oswt) |
      dma_write_ctrl_Push_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_sync23_sync_in_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_sync23_sync_in_mioi (
  clk, rst, sync23_vld, sync23_rdy, store_wten, sync23_sync_in_mioi_oswt, sync23_sync_in_mioi_wen_comp,
      sync23_sync_in_mioi_oswt_pff
);
  input clk;
  input rst;
  input sync23_vld;
  output sync23_rdy;
  input store_wten;
  input sync23_sync_in_mioi_oswt;
  output sync23_sync_in_mioi_wen_comp;
  input sync23_sync_in_mioi_oswt_pff;


  // Interconnect Declarations
  wire sync23_sync_in_mioi_biwt;
  wire sync23_sync_in_mioi_ccs_ccore_start_rsc_dat_store_sct;
  wire sync23_sync_in_mioi_ccs_ccore_done_sync_vld;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Connections_conn_sync_chan_sync_in  sync23_sync_in_mioi (
      .this_vld(sync23_vld),
      .this_rdy(sync23_rdy),
      .ccs_ccore_start_rsc_dat(sync23_sync_in_mioi_ccs_ccore_start_rsc_dat_store_sct),
      .ccs_ccore_done_sync_vld(sync23_sync_in_mioi_ccs_ccore_done_sync_vld),
      .ccs_MIO_clk(clk),
      .ccs_MIO_arst(rst)
    );
  esp_acc_DUMMY_Ctrl_store_store_sync23_sync_in_mioi_sync23_sync_in_mio_wait_ctrl
      Ctrl_store_store_sync23_sync_in_mioi_sync23_sync_in_mio_wait_ctrl_inst (
      .store_wten(store_wten),
      .sync23_sync_in_mioi_iswt0(sync23_sync_in_mioi_oswt),
      .sync23_sync_in_mioi_biwt(sync23_sync_in_mioi_biwt),
      .sync23_sync_in_mioi_ccs_ccore_start_rsc_dat_store_sct(sync23_sync_in_mioi_ccs_ccore_start_rsc_dat_store_sct),
      .sync23_sync_in_mioi_ccs_ccore_done_sync_vld(sync23_sync_in_mioi_ccs_ccore_done_sync_vld),
      .sync23_sync_in_mioi_iswt0_pff(sync23_sync_in_mioi_oswt_pff)
    );
  assign sync23_sync_in_mioi_wen_comp = (~ sync23_sync_in_mioi_oswt) | sync23_sync_in_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_conf3_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_conf3_Pop_mioi (
  clk, rst, conf3_val, conf3_rdy, conf3_msg, store_wen, conf3_Pop_mioi_oswt, conf3_Pop_mioi_wen_comp,
      conf3_Pop_mioi_idat_mxwt, conf3_Pop_mioi_ivld, conf3_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input conf3_val;
  output conf3_rdy;
  input [95:0] conf3_msg;
  input store_wen;
  input conf3_Pop_mioi_oswt;
  output conf3_Pop_mioi_wen_comp;
  output [95:0] conf3_Pop_mioi_idat_mxwt;
  output conf3_Pop_mioi_ivld;
  input conf3_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire conf3_Pop_mioi_biwt;
  wire conf3_Pop_mioi_bdwt;
  wire conf3_Pop_mioi_bcwt;
  wire [95:0] conf3_Pop_mioi_idat;
  wire conf3_Pop_mioi_irdy_store_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd80),
  .width(32'sd96),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf3_Pop_mioi (
      .vld(conf3_val),
      .rdy(conf3_rdy),
      .dat(conf3_msg),
      .idat(conf3_Pop_mioi_idat),
      .irdy(conf3_Pop_mioi_irdy_store_sct),
      .ivld(conf3_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_store_store_conf3_Pop_mioi_conf3_Pop_mio_wait_ctrl Ctrl_store_store_conf3_Pop_mioi_conf3_Pop_mio_wait_ctrl_inst
      (
      .store_wen(store_wen),
      .conf3_Pop_mioi_oswt(conf3_Pop_mioi_oswt),
      .conf3_Pop_mioi_ivld_oreg(conf3_Pop_mioi_ivld_oreg),
      .conf3_Pop_mioi_biwt(conf3_Pop_mioi_biwt),
      .conf3_Pop_mioi_bdwt(conf3_Pop_mioi_bdwt),
      .conf3_Pop_mioi_bcwt(conf3_Pop_mioi_bcwt),
      .conf3_Pop_mioi_irdy_store_sct(conf3_Pop_mioi_irdy_store_sct)
    );
  esp_acc_DUMMY_Ctrl_store_store_conf3_Pop_mioi_conf3_Pop_mio_wait_dp Ctrl_store_store_conf3_Pop_mioi_conf3_Pop_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf3_Pop_mioi_oswt(conf3_Pop_mioi_oswt),
      .conf3_Pop_mioi_wen_comp(conf3_Pop_mioi_wen_comp),
      .conf3_Pop_mioi_idat_mxwt(conf3_Pop_mioi_idat_mxwt),
      .conf3_Pop_mioi_biwt(conf3_Pop_mioi_biwt),
      .conf3_Pop_mioi_bdwt(conf3_Pop_mioi_bdwt),
      .conf3_Pop_mioi_bcwt(conf3_Pop_mioi_bcwt),
      .conf3_Pop_mioi_idat(conf3_Pop_mioi_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store_sync03_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store_sync03_Pop_mioi (
  clk, rst, sync03_val, sync03_rdy, sync03_msg, store_wen, sync03_Pop_mioi_oswt,
      sync03_Pop_mioi_wen_comp, sync03_Pop_mioi_ivld, sync03_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input sync03_val;
  output sync03_rdy;
  input sync03_msg;
  input store_wen;
  input sync03_Pop_mioi_oswt;
  output sync03_Pop_mioi_wen_comp;
  output sync03_Pop_mioi_ivld;
  input sync03_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire sync03_Pop_mioi_biwt;
  wire sync03_Pop_mioi_bdwt;
  wire sync03_Pop_mioi_bcwt;
  wire sync03_Pop_mioi_idat;
  wire sync03_Pop_mioi_irdy_store_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd79),
  .width(32'sd1),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) sync03_Pop_mioi (
      .vld(sync03_val),
      .rdy(sync03_rdy),
      .dat(sync03_msg),
      .idat(sync03_Pop_mioi_idat),
      .irdy(sync03_Pop_mioi_irdy_store_sct),
      .ivld(sync03_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_store_store_sync03_Pop_mioi_sync03_Pop_mio_wait_ctrl Ctrl_store_store_sync03_Pop_mioi_sync03_Pop_mio_wait_ctrl_inst
      (
      .store_wen(store_wen),
      .sync03_Pop_mioi_oswt(sync03_Pop_mioi_oswt),
      .sync03_Pop_mioi_ivld_oreg(sync03_Pop_mioi_ivld_oreg),
      .sync03_Pop_mioi_biwt(sync03_Pop_mioi_biwt),
      .sync03_Pop_mioi_bdwt(sync03_Pop_mioi_bdwt),
      .sync03_Pop_mioi_bcwt(sync03_Pop_mioi_bcwt),
      .sync03_Pop_mioi_irdy_store_sct(sync03_Pop_mioi_irdy_store_sct)
    );
  esp_acc_DUMMY_Ctrl_store_store_sync03_Pop_mioi_sync03_Pop_mio_wait_dp Ctrl_store_store_sync03_Pop_mioi_sync03_Pop_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .sync03_Pop_mioi_oswt(sync03_Pop_mioi_oswt),
      .sync03_Pop_mioi_wen_comp(sync03_Pop_mioi_wen_comp),
      .sync03_Pop_mioi_biwt(sync03_Pop_mioi_biwt),
      .sync03_Pop_mioi_bdwt(sync03_Pop_mioi_bdwt),
      .sync03_Pop_mioi_bcwt(sync03_Pop_mioi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1 (
  clk, rst, compute_wen, compute_wten, plm_out_pong_a1_a_d_data_rsci_oswt_unreg,
      plm_out_pong_a1_a_d_data_rsci_bawt, plm_out_pong_a1_a_d_data_rsci_iden, plm_out_pong_a1_a_d_data_rsci_iswt0,
      plm_out_pong_a1_a_d_data_rsci_w_en_d_pff, plm_out_pong_a1_a_d_data_rsci_iswt0_pff
);
  input clk;
  input rst;
  input compute_wen;
  input compute_wten;
  input plm_out_pong_a1_a_d_data_rsci_oswt_unreg;
  output plm_out_pong_a1_a_d_data_rsci_bawt;
  output plm_out_pong_a1_a_d_data_rsci_iden;
  input plm_out_pong_a1_a_d_data_rsci_iswt0;
  output plm_out_pong_a1_a_d_data_rsci_w_en_d_pff;
  input plm_out_pong_a1_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_out_pong_a1_a_d_data_rsci_biwt;
  wire plm_out_pong_a1_a_d_data_rsci_bdwt;
  wire plm_out_pong_a1_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_ctrl
      Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_out_pong_a1_a_d_data_rsci_oswt_unreg(plm_out_pong_a1_a_d_data_rsci_oswt_unreg),
      .plm_out_pong_a1_a_d_data_rsci_iswt0(plm_out_pong_a1_a_d_data_rsci_iswt0),
      .plm_out_pong_a1_a_d_data_rsci_biwt(plm_out_pong_a1_a_d_data_rsci_biwt),
      .plm_out_pong_a1_a_d_data_rsci_bdwt(plm_out_pong_a1_a_d_data_rsci_bdwt),
      .plm_out_pong_a1_a_d_data_rsci_biwt_pff(plm_out_pong_a1_a_d_data_rsci_biwt_iff),
      .plm_out_pong_a1_a_d_data_rsci_iswt0_pff(plm_out_pong_a1_a_d_data_rsci_iswt0_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_dp
      Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_plm_out_pong_a1_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_pong_a1_a_d_data_rsci_bawt(plm_out_pong_a1_a_d_data_rsci_bawt),
      .plm_out_pong_a1_a_d_data_rsci_iden(plm_out_pong_a1_a_d_data_rsci_iden),
      .plm_out_pong_a1_a_d_data_rsci_biwt(plm_out_pong_a1_a_d_data_rsci_biwt),
      .plm_out_pong_a1_a_d_data_rsci_bdwt(plm_out_pong_a1_a_d_data_rsci_bdwt)
    );
  assign plm_out_pong_a1_a_d_data_rsci_w_en_d_pff = plm_out_pong_a1_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1 (
  clk, rst, compute_wen, compute_wten, plm_out_pong_a0_a_d_data_rsci_oswt_unreg,
      plm_out_pong_a0_a_d_data_rsci_bawt, plm_out_pong_a0_a_d_data_rsci_iden, plm_out_pong_a0_a_d_data_rsci_iswt0,
      plm_out_pong_a0_a_d_data_rsci_w_en_d_pff, plm_out_pong_a0_a_d_data_rsci_iswt0_pff
);
  input clk;
  input rst;
  input compute_wen;
  input compute_wten;
  input plm_out_pong_a0_a_d_data_rsci_oswt_unreg;
  output plm_out_pong_a0_a_d_data_rsci_bawt;
  output plm_out_pong_a0_a_d_data_rsci_iden;
  input plm_out_pong_a0_a_d_data_rsci_iswt0;
  output plm_out_pong_a0_a_d_data_rsci_w_en_d_pff;
  input plm_out_pong_a0_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_out_pong_a0_a_d_data_rsci_biwt;
  wire plm_out_pong_a0_a_d_data_rsci_bdwt;
  wire plm_out_pong_a0_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_ctrl
      Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_out_pong_a0_a_d_data_rsci_oswt_unreg(plm_out_pong_a0_a_d_data_rsci_oswt_unreg),
      .plm_out_pong_a0_a_d_data_rsci_iswt0(plm_out_pong_a0_a_d_data_rsci_iswt0),
      .plm_out_pong_a0_a_d_data_rsci_biwt(plm_out_pong_a0_a_d_data_rsci_biwt),
      .plm_out_pong_a0_a_d_data_rsci_bdwt(plm_out_pong_a0_a_d_data_rsci_bdwt),
      .plm_out_pong_a0_a_d_data_rsci_biwt_pff(plm_out_pong_a0_a_d_data_rsci_biwt_iff),
      .plm_out_pong_a0_a_d_data_rsci_iswt0_pff(plm_out_pong_a0_a_d_data_rsci_iswt0_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_dp
      Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_plm_out_pong_a0_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_pong_a0_a_d_data_rsci_bawt(plm_out_pong_a0_a_d_data_rsci_bawt),
      .plm_out_pong_a0_a_d_data_rsci_iden(plm_out_pong_a0_a_d_data_rsci_iden),
      .plm_out_pong_a0_a_d_data_rsci_biwt(plm_out_pong_a0_a_d_data_rsci_biwt),
      .plm_out_pong_a0_a_d_data_rsci_bdwt(plm_out_pong_a0_a_d_data_rsci_bdwt)
    );
  assign plm_out_pong_a0_a_d_data_rsci_w_en_d_pff = plm_out_pong_a0_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1 (
  clk, rst, compute_wen, compute_wten, plm_out_ping_a1_a_d_data_rsci_oswt_unreg,
      plm_out_ping_a1_a_d_data_rsci_bawt, plm_out_ping_a1_a_d_data_rsci_iden, plm_out_ping_a1_a_d_data_rsci_iswt0,
      plm_out_ping_a1_a_d_data_rsci_w_en_d_pff, plm_out_ping_a1_a_d_data_rsci_iswt0_pff
);
  input clk;
  input rst;
  input compute_wen;
  input compute_wten;
  input plm_out_ping_a1_a_d_data_rsci_oswt_unreg;
  output plm_out_ping_a1_a_d_data_rsci_bawt;
  output plm_out_ping_a1_a_d_data_rsci_iden;
  input plm_out_ping_a1_a_d_data_rsci_iswt0;
  output plm_out_ping_a1_a_d_data_rsci_w_en_d_pff;
  input plm_out_ping_a1_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_out_ping_a1_a_d_data_rsci_biwt;
  wire plm_out_ping_a1_a_d_data_rsci_bdwt;
  wire plm_out_ping_a1_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_ctrl
      Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_out_ping_a1_a_d_data_rsci_oswt_unreg(plm_out_ping_a1_a_d_data_rsci_oswt_unreg),
      .plm_out_ping_a1_a_d_data_rsci_iswt0(plm_out_ping_a1_a_d_data_rsci_iswt0),
      .plm_out_ping_a1_a_d_data_rsci_biwt(plm_out_ping_a1_a_d_data_rsci_biwt),
      .plm_out_ping_a1_a_d_data_rsci_bdwt(plm_out_ping_a1_a_d_data_rsci_bdwt),
      .plm_out_ping_a1_a_d_data_rsci_biwt_pff(plm_out_ping_a1_a_d_data_rsci_biwt_iff),
      .plm_out_ping_a1_a_d_data_rsci_iswt0_pff(plm_out_ping_a1_a_d_data_rsci_iswt0_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_dp
      Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_plm_out_ping_a1_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_ping_a1_a_d_data_rsci_bawt(plm_out_ping_a1_a_d_data_rsci_bawt),
      .plm_out_ping_a1_a_d_data_rsci_iden(plm_out_ping_a1_a_d_data_rsci_iden),
      .plm_out_ping_a1_a_d_data_rsci_biwt(plm_out_ping_a1_a_d_data_rsci_biwt),
      .plm_out_ping_a1_a_d_data_rsci_bdwt(plm_out_ping_a1_a_d_data_rsci_bdwt)
    );
  assign plm_out_ping_a1_a_d_data_rsci_w_en_d_pff = plm_out_ping_a1_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1 (
  clk, rst, compute_wen, compute_wten, plm_out_ping_a0_a_d_data_rsci_oswt_unreg,
      plm_out_ping_a0_a_d_data_rsci_bawt, plm_out_ping_a0_a_d_data_rsci_iden, plm_out_ping_a0_a_d_data_rsci_iswt0,
      plm_out_ping_a0_a_d_data_rsci_w_en_d_pff, plm_out_ping_a0_a_d_data_rsci_iswt0_pff
);
  input clk;
  input rst;
  input compute_wen;
  input compute_wten;
  input plm_out_ping_a0_a_d_data_rsci_oswt_unreg;
  output plm_out_ping_a0_a_d_data_rsci_bawt;
  output plm_out_ping_a0_a_d_data_rsci_iden;
  input plm_out_ping_a0_a_d_data_rsci_iswt0;
  output plm_out_ping_a0_a_d_data_rsci_w_en_d_pff;
  input plm_out_ping_a0_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_out_ping_a0_a_d_data_rsci_biwt;
  wire plm_out_ping_a0_a_d_data_rsci_bdwt;
  wire plm_out_ping_a0_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_ctrl
      Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_out_ping_a0_a_d_data_rsci_oswt_unreg(plm_out_ping_a0_a_d_data_rsci_oswt_unreg),
      .plm_out_ping_a0_a_d_data_rsci_iswt0(plm_out_ping_a0_a_d_data_rsci_iswt0),
      .plm_out_ping_a0_a_d_data_rsci_biwt(plm_out_ping_a0_a_d_data_rsci_biwt),
      .plm_out_ping_a0_a_d_data_rsci_bdwt(plm_out_ping_a0_a_d_data_rsci_bdwt),
      .plm_out_ping_a0_a_d_data_rsci_biwt_pff(plm_out_ping_a0_a_d_data_rsci_biwt_iff),
      .plm_out_ping_a0_a_d_data_rsci_iswt0_pff(plm_out_ping_a0_a_d_data_rsci_iswt0_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_dp
      Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_plm_out_ping_a0_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_ping_a0_a_d_data_rsci_bawt(plm_out_ping_a0_a_d_data_rsci_bawt),
      .plm_out_ping_a0_a_d_data_rsci_iden(plm_out_ping_a0_a_d_data_rsci_iden),
      .plm_out_ping_a0_a_d_data_rsci_biwt(plm_out_ping_a0_a_d_data_rsci_biwt),
      .plm_out_ping_a0_a_d_data_rsci_bdwt(plm_out_ping_a0_a_d_data_rsci_bdwt)
    );
  assign plm_out_ping_a0_a_d_data_rsci_w_en_d_pff = plm_out_ping_a0_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1 (
  clk, rst, plm_in_pong_a1_a_d_data_rsci_qout_d, plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      compute_wen, compute_wten, plm_in_pong_a1_a_d_data_rsci_oswt_unreg, plm_in_pong_a1_a_d_data_rsci_bawt,
      plm_in_pong_a1_a_d_data_rsci_iden, plm_in_pong_a1_a_d_data_rsci_iswt0, plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt,
      plm_in_pong_a1_a_d_data_rsci_iswt0_pff
);
  input clk;
  input rst;
  input [31:0] plm_in_pong_a1_a_d_data_rsci_qout_d;
  output plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input compute_wen;
  input compute_wten;
  input plm_in_pong_a1_a_d_data_rsci_oswt_unreg;
  output plm_in_pong_a1_a_d_data_rsci_bawt;
  output plm_in_pong_a1_a_d_data_rsci_iden;
  input plm_in_pong_a1_a_d_data_rsci_iswt0;
  output [31:0] plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt;
  input plm_in_pong_a1_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_pong_a1_a_d_data_rsci_biwt;
  wire plm_in_pong_a1_a_d_data_rsci_bdwt;
  wire plm_in_pong_a1_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_ctrl
      Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_in_pong_a1_a_d_data_rsci_oswt_unreg(plm_in_pong_a1_a_d_data_rsci_oswt_unreg),
      .plm_in_pong_a1_a_d_data_rsci_iswt0(plm_in_pong_a1_a_d_data_rsci_iswt0),
      .plm_in_pong_a1_a_d_data_rsci_biwt(plm_in_pong_a1_a_d_data_rsci_biwt),
      .plm_in_pong_a1_a_d_data_rsci_bdwt(plm_in_pong_a1_a_d_data_rsci_bdwt),
      .plm_in_pong_a1_a_d_data_rsci_biwt_pff(plm_in_pong_a1_a_d_data_rsci_biwt_iff),
      .plm_in_pong_a1_a_d_data_rsci_iswt0_pff(plm_in_pong_a1_a_d_data_rsci_iswt0_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_dp
      Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_pong_a1_a_d_data_rsci_qout_d(plm_in_pong_a1_a_d_data_rsci_qout_d),
      .plm_in_pong_a1_a_d_data_rsci_bawt(plm_in_pong_a1_a_d_data_rsci_bawt),
      .plm_in_pong_a1_a_d_data_rsci_iden(plm_in_pong_a1_a_d_data_rsci_iden),
      .plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt(plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt),
      .plm_in_pong_a1_a_d_data_rsci_biwt(plm_in_pong_a1_a_d_data_rsci_biwt),
      .plm_in_pong_a1_a_d_data_rsci_bdwt(plm_in_pong_a1_a_d_data_rsci_bdwt)
    );
  assign plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_in_pong_a1_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1 (
  clk, rst, plm_in_pong_a0_a_d_data_rsci_qout_d, plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      compute_wen, compute_wten, plm_in_pong_a0_a_d_data_rsci_oswt_unreg, plm_in_pong_a0_a_d_data_rsci_bawt,
      plm_in_pong_a0_a_d_data_rsci_iden, plm_in_pong_a0_a_d_data_rsci_iswt0, plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt,
      plm_in_pong_a0_a_d_data_rsci_iswt0_pff
);
  input clk;
  input rst;
  input [31:0] plm_in_pong_a0_a_d_data_rsci_qout_d;
  output plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input compute_wen;
  input compute_wten;
  input plm_in_pong_a0_a_d_data_rsci_oswt_unreg;
  output plm_in_pong_a0_a_d_data_rsci_bawt;
  output plm_in_pong_a0_a_d_data_rsci_iden;
  input plm_in_pong_a0_a_d_data_rsci_iswt0;
  output [31:0] plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt;
  input plm_in_pong_a0_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_pong_a0_a_d_data_rsci_biwt;
  wire plm_in_pong_a0_a_d_data_rsci_bdwt;
  wire plm_in_pong_a0_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_ctrl
      Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_in_pong_a0_a_d_data_rsci_oswt_unreg(plm_in_pong_a0_a_d_data_rsci_oswt_unreg),
      .plm_in_pong_a0_a_d_data_rsci_iswt0(plm_in_pong_a0_a_d_data_rsci_iswt0),
      .plm_in_pong_a0_a_d_data_rsci_biwt(plm_in_pong_a0_a_d_data_rsci_biwt),
      .plm_in_pong_a0_a_d_data_rsci_bdwt(plm_in_pong_a0_a_d_data_rsci_bdwt),
      .plm_in_pong_a0_a_d_data_rsci_biwt_pff(plm_in_pong_a0_a_d_data_rsci_biwt_iff),
      .plm_in_pong_a0_a_d_data_rsci_iswt0_pff(plm_in_pong_a0_a_d_data_rsci_iswt0_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_dp
      Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_pong_a0_a_d_data_rsci_qout_d(plm_in_pong_a0_a_d_data_rsci_qout_d),
      .plm_in_pong_a0_a_d_data_rsci_bawt(plm_in_pong_a0_a_d_data_rsci_bawt),
      .plm_in_pong_a0_a_d_data_rsci_iden(plm_in_pong_a0_a_d_data_rsci_iden),
      .plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt(plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt),
      .plm_in_pong_a0_a_d_data_rsci_biwt(plm_in_pong_a0_a_d_data_rsci_biwt),
      .plm_in_pong_a0_a_d_data_rsci_bdwt(plm_in_pong_a0_a_d_data_rsci_bdwt)
    );
  assign plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_in_pong_a0_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1 (
  clk, rst, plm_in_ping_a1_a_d_data_rsci_qout_d, plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      compute_wen, compute_wten, plm_in_ping_a1_a_d_data_rsci_oswt_unreg, plm_in_ping_a1_a_d_data_rsci_bawt,
      plm_in_ping_a1_a_d_data_rsci_iden, plm_in_ping_a1_a_d_data_rsci_iswt0, plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt,
      plm_in_ping_a1_a_d_data_rsci_iswt0_pff
);
  input clk;
  input rst;
  input [31:0] plm_in_ping_a1_a_d_data_rsci_qout_d;
  output plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input compute_wen;
  input compute_wten;
  input plm_in_ping_a1_a_d_data_rsci_oswt_unreg;
  output plm_in_ping_a1_a_d_data_rsci_bawt;
  output plm_in_ping_a1_a_d_data_rsci_iden;
  input plm_in_ping_a1_a_d_data_rsci_iswt0;
  output [31:0] plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt;
  input plm_in_ping_a1_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_ping_a1_a_d_data_rsci_biwt;
  wire plm_in_ping_a1_a_d_data_rsci_bdwt;
  wire plm_in_ping_a1_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_ctrl
      Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_in_ping_a1_a_d_data_rsci_oswt_unreg(plm_in_ping_a1_a_d_data_rsci_oswt_unreg),
      .plm_in_ping_a1_a_d_data_rsci_iswt0(plm_in_ping_a1_a_d_data_rsci_iswt0),
      .plm_in_ping_a1_a_d_data_rsci_biwt(plm_in_ping_a1_a_d_data_rsci_biwt),
      .plm_in_ping_a1_a_d_data_rsci_bdwt(plm_in_ping_a1_a_d_data_rsci_bdwt),
      .plm_in_ping_a1_a_d_data_rsci_biwt_pff(plm_in_ping_a1_a_d_data_rsci_biwt_iff),
      .plm_in_ping_a1_a_d_data_rsci_iswt0_pff(plm_in_ping_a1_a_d_data_rsci_iswt0_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_dp
      Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_ping_a1_a_d_data_rsci_qout_d(plm_in_ping_a1_a_d_data_rsci_qout_d),
      .plm_in_ping_a1_a_d_data_rsci_bawt(plm_in_ping_a1_a_d_data_rsci_bawt),
      .plm_in_ping_a1_a_d_data_rsci_iden(plm_in_ping_a1_a_d_data_rsci_iden),
      .plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt(plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt),
      .plm_in_ping_a1_a_d_data_rsci_biwt(plm_in_ping_a1_a_d_data_rsci_biwt),
      .plm_in_ping_a1_a_d_data_rsci_bdwt(plm_in_ping_a1_a_d_data_rsci_bdwt)
    );
  assign plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_in_ping_a1_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1 (
  clk, rst, plm_in_ping_a0_a_d_data_rsci_qout_d, plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      compute_wen, compute_wten, plm_in_ping_a0_a_d_data_rsci_oswt_unreg, plm_in_ping_a0_a_d_data_rsci_bawt,
      plm_in_ping_a0_a_d_data_rsci_iden, plm_in_ping_a0_a_d_data_rsci_iswt0, plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt,
      plm_in_ping_a0_a_d_data_rsci_iswt0_pff
);
  input clk;
  input rst;
  input [31:0] plm_in_ping_a0_a_d_data_rsci_qout_d;
  output plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input compute_wen;
  input compute_wten;
  input plm_in_ping_a0_a_d_data_rsci_oswt_unreg;
  output plm_in_ping_a0_a_d_data_rsci_bawt;
  output plm_in_ping_a0_a_d_data_rsci_iden;
  input plm_in_ping_a0_a_d_data_rsci_iswt0;
  output [31:0] plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt;
  input plm_in_ping_a0_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_ping_a0_a_d_data_rsci_biwt;
  wire plm_in_ping_a0_a_d_data_rsci_bdwt;
  wire plm_in_ping_a0_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_ctrl
      Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_in_ping_a0_a_d_data_rsci_oswt_unreg(plm_in_ping_a0_a_d_data_rsci_oswt_unreg),
      .plm_in_ping_a0_a_d_data_rsci_iswt0(plm_in_ping_a0_a_d_data_rsci_iswt0),
      .plm_in_ping_a0_a_d_data_rsci_biwt(plm_in_ping_a0_a_d_data_rsci_biwt),
      .plm_in_ping_a0_a_d_data_rsci_bdwt(plm_in_ping_a0_a_d_data_rsci_bdwt),
      .plm_in_ping_a0_a_d_data_rsci_biwt_pff(plm_in_ping_a0_a_d_data_rsci_biwt_iff),
      .plm_in_ping_a0_a_d_data_rsci_iswt0_pff(plm_in_ping_a0_a_d_data_rsci_iswt0_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_dp
      Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_ping_a0_a_d_data_rsci_qout_d(plm_in_ping_a0_a_d_data_rsci_qout_d),
      .plm_in_ping_a0_a_d_data_rsci_bawt(plm_in_ping_a0_a_d_data_rsci_bawt),
      .plm_in_ping_a0_a_d_data_rsci_iden(plm_in_ping_a0_a_d_data_rsci_iden),
      .plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt(plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt),
      .plm_in_ping_a0_a_d_data_rsci_biwt(plm_in_ping_a0_a_d_data_rsci_biwt),
      .plm_in_ping_a0_a_d_data_rsci_bdwt(plm_in_ping_a0_a_d_data_rsci_bdwt)
    );
  assign plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_in_ping_a0_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_sync23_sync_out_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_sync23_sync_out_mioi (
  clk, rst, sync23_vld, sync23_rdy, compute_wten, sync23_sync_out_mioi_oswt, sync23_sync_out_mioi_wen_comp,
      sync23_sync_out_mioi_oswt_pff
);
  input clk;
  input rst;
  output sync23_vld;
  input sync23_rdy;
  input compute_wten;
  input sync23_sync_out_mioi_oswt;
  output sync23_sync_out_mioi_wen_comp;
  input sync23_sync_out_mioi_oswt_pff;


  // Interconnect Declarations
  wire sync23_sync_out_mioi_biwt;
  wire sync23_sync_out_mioi_ccs_ccore_start_rsc_dat_compute_sct;
  wire sync23_sync_out_mioi_ccs_ccore_done_sync_vld;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Connections_conn_sync_chan_sync_out  sync23_sync_out_mioi (
      .this_vld(sync23_vld),
      .this_rdy(sync23_rdy),
      .ccs_ccore_start_rsc_dat(sync23_sync_out_mioi_ccs_ccore_start_rsc_dat_compute_sct),
      .ccs_ccore_done_sync_vld(sync23_sync_out_mioi_ccs_ccore_done_sync_vld),
      .ccs_MIO_clk(clk),
      .ccs_MIO_arst(rst)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_sync23_sync_out_mioi_sync23_sync_out_mio_wait_ctrl
      Ctrl_compute_compute_sync23_sync_out_mioi_sync23_sync_out_mio_wait_ctrl_inst
      (
      .compute_wten(compute_wten),
      .sync23_sync_out_mioi_iswt0(sync23_sync_out_mioi_oswt),
      .sync23_sync_out_mioi_biwt(sync23_sync_out_mioi_biwt),
      .sync23_sync_out_mioi_ccs_ccore_start_rsc_dat_compute_sct(sync23_sync_out_mioi_ccs_ccore_start_rsc_dat_compute_sct),
      .sync23_sync_out_mioi_ccs_ccore_done_sync_vld(sync23_sync_out_mioi_ccs_ccore_done_sync_vld),
      .sync23_sync_out_mioi_iswt0_pff(sync23_sync_out_mioi_oswt_pff)
    );
  assign sync23_sync_out_mioi_wen_comp = (~ sync23_sync_out_mioi_oswt) | sync23_sync_out_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_in_wr_req_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_in_wr_req_Pop_mioi (
  clk, rst, in_wr_req_val, in_wr_req_rdy, in_wr_req_msg, compute_wen, in_wr_req_Pop_mioi_oswt_unreg,
      in_wr_req_Pop_mioi_bawt, in_wr_req_Pop_mioi_iden, in_wr_req_Pop_mioi_iswt0,
      in_wr_req_Pop_mioi_wen_comp, in_wr_req_Pop_mioi_idat_mxwt, in_wr_req_Pop_mioi_ivld,
      in_wr_req_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input in_wr_req_val;
  output in_wr_req_rdy;
  input [31:0] in_wr_req_msg;
  input compute_wen;
  input in_wr_req_Pop_mioi_oswt_unreg;
  output in_wr_req_Pop_mioi_bawt;
  output in_wr_req_Pop_mioi_iden;
  input in_wr_req_Pop_mioi_iswt0;
  output in_wr_req_Pop_mioi_wen_comp;
  output [31:0] in_wr_req_Pop_mioi_idat_mxwt;
  output in_wr_req_Pop_mioi_ivld;
  input in_wr_req_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire in_wr_req_Pop_mioi_biwt;
  wire in_wr_req_Pop_mioi_bdwt;
  wire in_wr_req_Pop_mioi_bcwt;
  wire [31:0] in_wr_req_Pop_mioi_idat;
  wire in_wr_req_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd77),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) in_wr_req_Pop_mioi (
      .vld(in_wr_req_val),
      .rdy(in_wr_req_rdy),
      .dat(in_wr_req_msg),
      .idat(in_wr_req_Pop_mioi_idat),
      .irdy(in_wr_req_Pop_mioi_irdy_compute_sct),
      .ivld(in_wr_req_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_in_wr_req_Pop_mioi_in_wr_req_Pop_mio_wait_ctrl
      Ctrl_compute_compute_in_wr_req_Pop_mioi_in_wr_req_Pop_mio_wait_ctrl_inst (
      .compute_wen(compute_wen),
      .in_wr_req_Pop_mioi_oswt_unreg(in_wr_req_Pop_mioi_oswt_unreg),
      .in_wr_req_Pop_mioi_iswt0(in_wr_req_Pop_mioi_iswt0),
      .in_wr_req_Pop_mioi_ivld_oreg(in_wr_req_Pop_mioi_ivld_oreg),
      .in_wr_req_Pop_mioi_biwt(in_wr_req_Pop_mioi_biwt),
      .in_wr_req_Pop_mioi_bdwt(in_wr_req_Pop_mioi_bdwt),
      .in_wr_req_Pop_mioi_bcwt(in_wr_req_Pop_mioi_bcwt),
      .in_wr_req_Pop_mioi_irdy_compute_sct(in_wr_req_Pop_mioi_irdy_compute_sct)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_in_wr_req_Pop_mioi_in_wr_req_Pop_mio_wait_dp
      Ctrl_compute_compute_in_wr_req_Pop_mioi_in_wr_req_Pop_mio_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .in_wr_req_Pop_mioi_oswt_unreg(in_wr_req_Pop_mioi_oswt_unreg),
      .in_wr_req_Pop_mioi_bawt(in_wr_req_Pop_mioi_bawt),
      .in_wr_req_Pop_mioi_iden(in_wr_req_Pop_mioi_iden),
      .in_wr_req_Pop_mioi_wen_comp(in_wr_req_Pop_mioi_wen_comp),
      .in_wr_req_Pop_mioi_idat_mxwt(in_wr_req_Pop_mioi_idat_mxwt),
      .in_wr_req_Pop_mioi_biwt(in_wr_req_Pop_mioi_biwt),
      .in_wr_req_Pop_mioi_bdwt(in_wr_req_Pop_mioi_bdwt),
      .in_wr_req_Pop_mioi_bcwt(in_wr_req_Pop_mioi_bcwt),
      .in_wr_req_Pop_mioi_idat(in_wr_req_Pop_mioi_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_in_rd_rsp_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_in_rd_rsp_Push_mioi (
  clk, rst, in_rd_rsp_val, in_rd_rsp_rdy, in_rd_rsp_msg, compute_wen, in_rd_rsp_Push_mioi_oswt_unreg,
      in_rd_rsp_Push_mioi_bawt, in_rd_rsp_Push_mioi_iden, in_rd_rsp_Push_mioi_iswt0,
      in_rd_rsp_Push_mioi_wen_comp, in_rd_rsp_Push_mioi_idat, in_rd_rsp_Push_mioi_irdy,
      in_rd_rsp_Push_mioi_irdy_oreg
);
  input clk;
  input rst;
  output in_rd_rsp_val;
  input in_rd_rsp_rdy;
  output [63:0] in_rd_rsp_msg;
  input compute_wen;
  input in_rd_rsp_Push_mioi_oswt_unreg;
  output in_rd_rsp_Push_mioi_bawt;
  output in_rd_rsp_Push_mioi_iden;
  input in_rd_rsp_Push_mioi_iswt0;
  output in_rd_rsp_Push_mioi_wen_comp;
  input [63:0] in_rd_rsp_Push_mioi_idat;
  output in_rd_rsp_Push_mioi_irdy;
  input in_rd_rsp_Push_mioi_irdy_oreg;


  // Interconnect Declarations
  wire in_rd_rsp_Push_mioi_biwt;
  wire in_rd_rsp_Push_mioi_bdwt;
  wire in_rd_rsp_Push_mioi_bcwt;
  wire in_rd_rsp_Push_mioi_ivld_compute_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd76),
  .width(32'sd64),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) in_rd_rsp_Push_mioi (
      .vld(in_rd_rsp_val),
      .rdy(in_rd_rsp_rdy),
      .dat(in_rd_rsp_msg),
      .idat(in_rd_rsp_Push_mioi_idat),
      .irdy(in_rd_rsp_Push_mioi_irdy),
      .ivld(in_rd_rsp_Push_mioi_ivld_compute_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_in_rd_rsp_Push_mioi_in_rd_rsp_Push_mio_wait_ctrl
      Ctrl_compute_compute_in_rd_rsp_Push_mioi_in_rd_rsp_Push_mio_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .in_rd_rsp_Push_mioi_oswt_unreg(in_rd_rsp_Push_mioi_oswt_unreg),
      .in_rd_rsp_Push_mioi_iswt0(in_rd_rsp_Push_mioi_iswt0),
      .in_rd_rsp_Push_mioi_irdy_oreg(in_rd_rsp_Push_mioi_irdy_oreg),
      .in_rd_rsp_Push_mioi_biwt(in_rd_rsp_Push_mioi_biwt),
      .in_rd_rsp_Push_mioi_bdwt(in_rd_rsp_Push_mioi_bdwt),
      .in_rd_rsp_Push_mioi_bcwt(in_rd_rsp_Push_mioi_bcwt),
      .in_rd_rsp_Push_mioi_ivld_compute_sct(in_rd_rsp_Push_mioi_ivld_compute_sct)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_in_rd_rsp_Push_mioi_in_rd_rsp_Push_mio_wait_dp
      Ctrl_compute_compute_in_rd_rsp_Push_mioi_in_rd_rsp_Push_mio_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .in_rd_rsp_Push_mioi_oswt_unreg(in_rd_rsp_Push_mioi_oswt_unreg),
      .in_rd_rsp_Push_mioi_bawt(in_rd_rsp_Push_mioi_bawt),
      .in_rd_rsp_Push_mioi_iden(in_rd_rsp_Push_mioi_iden),
      .in_rd_rsp_Push_mioi_wen_comp(in_rd_rsp_Push_mioi_wen_comp),
      .in_rd_rsp_Push_mioi_biwt(in_rd_rsp_Push_mioi_biwt),
      .in_rd_rsp_Push_mioi_bdwt(in_rd_rsp_Push_mioi_bdwt),
      .in_rd_rsp_Push_mioi_bcwt(in_rd_rsp_Push_mioi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_sync12_sync_in_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_sync12_sync_in_mioi (
  clk, rst, sync12_vld, sync12_rdy, compute_wten, sync12_sync_in_mioi_oswt, sync12_sync_in_mioi_wen_comp,
      sync12_sync_in_mioi_oswt_pff
);
  input clk;
  input rst;
  input sync12_vld;
  output sync12_rdy;
  input compute_wten;
  input sync12_sync_in_mioi_oswt;
  output sync12_sync_in_mioi_wen_comp;
  input sync12_sync_in_mioi_oswt_pff;


  // Interconnect Declarations
  wire sync12_sync_in_mioi_biwt;
  wire sync12_sync_in_mioi_ccs_ccore_start_rsc_dat_compute_sct;
  wire sync12_sync_in_mioi_ccs_ccore_done_sync_vld;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Connections_conn_sync_chan_sync_in  sync12_sync_in_mioi (
      .this_vld(sync12_vld),
      .this_rdy(sync12_rdy),
      .ccs_ccore_start_rsc_dat(sync12_sync_in_mioi_ccs_ccore_start_rsc_dat_compute_sct),
      .ccs_ccore_done_sync_vld(sync12_sync_in_mioi_ccs_ccore_done_sync_vld),
      .ccs_MIO_clk(clk),
      .ccs_MIO_arst(rst)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_sync12_sync_in_mioi_sync12_sync_in_mio_wait_ctrl
      Ctrl_compute_compute_sync12_sync_in_mioi_sync12_sync_in_mio_wait_ctrl_inst
      (
      .compute_wten(compute_wten),
      .sync12_sync_in_mioi_iswt0(sync12_sync_in_mioi_oswt),
      .sync12_sync_in_mioi_biwt(sync12_sync_in_mioi_biwt),
      .sync12_sync_in_mioi_ccs_ccore_start_rsc_dat_compute_sct(sync12_sync_in_mioi_ccs_ccore_start_rsc_dat_compute_sct),
      .sync12_sync_in_mioi_ccs_ccore_done_sync_vld(sync12_sync_in_mioi_ccs_ccore_done_sync_vld),
      .sync12_sync_in_mioi_iswt0_pff(sync12_sync_in_mioi_oswt_pff)
    );
  assign sync12_sync_in_mioi_wen_comp = (~ sync12_sync_in_mioi_oswt) | sync12_sync_in_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_conf2_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_conf2_Pop_mioi (
  clk, rst, conf2_val, conf2_rdy, conf2_msg, compute_wen, conf2_Pop_mioi_oswt, conf2_Pop_mioi_iden,
      conf2_Pop_mioi_wen_comp, conf2_Pop_mioi_idat_mxwt, conf2_Pop_mioi_ivld, conf2_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input conf2_val;
  output conf2_rdy;
  input [95:0] conf2_msg;
  input compute_wen;
  input conf2_Pop_mioi_oswt;
  output conf2_Pop_mioi_iden;
  output conf2_Pop_mioi_wen_comp;
  output [95:0] conf2_Pop_mioi_idat_mxwt;
  output conf2_Pop_mioi_ivld;
  input conf2_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire conf2_Pop_mioi_biwt;
  wire conf2_Pop_mioi_bdwt;
  wire conf2_Pop_mioi_bcwt;
  wire [95:0] conf2_Pop_mioi_idat;
  wire conf2_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd74),
  .width(32'sd96),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf2_Pop_mioi (
      .vld(conf2_val),
      .rdy(conf2_rdy),
      .dat(conf2_msg),
      .idat(conf2_Pop_mioi_idat),
      .irdy(conf2_Pop_mioi_irdy_compute_sct),
      .ivld(conf2_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_conf2_Pop_mioi_conf2_Pop_mio_wait_ctrl Ctrl_compute_compute_conf2_Pop_mioi_conf2_Pop_mio_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .conf2_Pop_mioi_oswt(conf2_Pop_mioi_oswt),
      .conf2_Pop_mioi_ivld_oreg(conf2_Pop_mioi_ivld_oreg),
      .conf2_Pop_mioi_biwt(conf2_Pop_mioi_biwt),
      .conf2_Pop_mioi_bdwt(conf2_Pop_mioi_bdwt),
      .conf2_Pop_mioi_bcwt(conf2_Pop_mioi_bcwt),
      .conf2_Pop_mioi_irdy_compute_sct(conf2_Pop_mioi_irdy_compute_sct)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_conf2_Pop_mioi_conf2_Pop_mio_wait_dp Ctrl_compute_compute_conf2_Pop_mioi_conf2_Pop_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf2_Pop_mioi_oswt(conf2_Pop_mioi_oswt),
      .conf2_Pop_mioi_iden(conf2_Pop_mioi_iden),
      .conf2_Pop_mioi_wen_comp(conf2_Pop_mioi_wen_comp),
      .conf2_Pop_mioi_idat_mxwt(conf2_Pop_mioi_idat_mxwt),
      .conf2_Pop_mioi_biwt(conf2_Pop_mioi_biwt),
      .conf2_Pop_mioi_bdwt(conf2_Pop_mioi_bdwt),
      .conf2_Pop_mioi_bcwt(conf2_Pop_mioi_bcwt),
      .conf2_Pop_mioi_idat(conf2_Pop_mioi_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute_sync02_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute_sync02_Pop_mioi (
  clk, rst, sync02_val, sync02_rdy, sync02_msg, compute_wen, sync02_Pop_mioi_oswt,
      sync02_Pop_mioi_iden, sync02_Pop_mioi_wen_comp, sync02_Pop_mioi_ivld, sync02_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input sync02_val;
  output sync02_rdy;
  input sync02_msg;
  input compute_wen;
  input sync02_Pop_mioi_oswt;
  output sync02_Pop_mioi_iden;
  output sync02_Pop_mioi_wen_comp;
  output sync02_Pop_mioi_ivld;
  input sync02_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire sync02_Pop_mioi_biwt;
  wire sync02_Pop_mioi_bdwt;
  wire sync02_Pop_mioi_bcwt;
  wire sync02_Pop_mioi_idat;
  wire sync02_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd73),
  .width(32'sd1),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) sync02_Pop_mioi (
      .vld(sync02_val),
      .rdy(sync02_rdy),
      .dat(sync02_msg),
      .idat(sync02_Pop_mioi_idat),
      .irdy(sync02_Pop_mioi_irdy_compute_sct),
      .ivld(sync02_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_sync02_Pop_mioi_sync02_Pop_mio_wait_ctrl Ctrl_compute_compute_sync02_Pop_mioi_sync02_Pop_mio_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .sync02_Pop_mioi_oswt(sync02_Pop_mioi_oswt),
      .sync02_Pop_mioi_ivld_oreg(sync02_Pop_mioi_ivld_oreg),
      .sync02_Pop_mioi_biwt(sync02_Pop_mioi_biwt),
      .sync02_Pop_mioi_bdwt(sync02_Pop_mioi_bdwt),
      .sync02_Pop_mioi_bcwt(sync02_Pop_mioi_bcwt),
      .sync02_Pop_mioi_irdy_compute_sct(sync02_Pop_mioi_irdy_compute_sct)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_sync02_Pop_mioi_sync02_Pop_mio_wait_dp Ctrl_compute_compute_sync02_Pop_mioi_sync02_Pop_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .sync02_Pop_mioi_oswt(sync02_Pop_mioi_oswt),
      .sync02_Pop_mioi_iden(sync02_Pop_mioi_iden),
      .sync02_Pop_mioi_wen_comp(sync02_Pop_mioi_wen_comp),
      .sync02_Pop_mioi_biwt(sync02_Pop_mioi_biwt),
      .sync02_Pop_mioi_bdwt(sync02_Pop_mioi_bdwt),
      .sync02_Pop_mioi_bcwt(sync02_Pop_mioi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1 (
  plm_in_pong_a1_a_d_data_rsci_w_en_d_pff, load_wten_pff, plm_in_pong_a1_a_d_data_rsci_iswt0_pff
);
  output plm_in_pong_a1_a_d_data_rsci_w_en_d_pff;
  input load_wten_pff;
  input plm_in_pong_a1_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_pong_a1_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_ctrl
      Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1_plm_in_pong_a1_a_d_data_rsc_wait_ctrl_inst
      (
      .plm_in_pong_a1_a_d_data_rsci_biwt_pff(plm_in_pong_a1_a_d_data_rsci_biwt_iff),
      .load_wten_pff(load_wten_pff),
      .plm_in_pong_a1_a_d_data_rsci_iswt0_pff(plm_in_pong_a1_a_d_data_rsci_iswt0_pff)
    );
  assign plm_in_pong_a1_a_d_data_rsci_w_en_d_pff = plm_in_pong_a1_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1 (
  plm_in_pong_a0_a_d_data_rsci_w_en_d_pff, load_wten_pff, plm_in_pong_a0_a_d_data_rsci_iswt0_pff
);
  output plm_in_pong_a0_a_d_data_rsci_w_en_d_pff;
  input load_wten_pff;
  input plm_in_pong_a0_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_pong_a0_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_ctrl
      Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1_plm_in_pong_a0_a_d_data_rsc_wait_ctrl_inst
      (
      .plm_in_pong_a0_a_d_data_rsci_biwt_pff(plm_in_pong_a0_a_d_data_rsci_biwt_iff),
      .load_wten_pff(load_wten_pff),
      .plm_in_pong_a0_a_d_data_rsci_iswt0_pff(plm_in_pong_a0_a_d_data_rsci_iswt0_pff)
    );
  assign plm_in_pong_a0_a_d_data_rsci_w_en_d_pff = plm_in_pong_a0_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1 (
  plm_in_ping_a1_a_d_data_rsci_w_en_d_pff, load_wten_pff, plm_in_ping_a1_a_d_data_rsci_iswt0_pff
);
  output plm_in_ping_a1_a_d_data_rsci_w_en_d_pff;
  input load_wten_pff;
  input plm_in_ping_a1_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_ping_a1_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_ctrl
      Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1_plm_in_ping_a1_a_d_data_rsc_wait_ctrl_inst
      (
      .plm_in_ping_a1_a_d_data_rsci_biwt_pff(plm_in_ping_a1_a_d_data_rsci_biwt_iff),
      .load_wten_pff(load_wten_pff),
      .plm_in_ping_a1_a_d_data_rsci_iswt0_pff(plm_in_ping_a1_a_d_data_rsci_iswt0_pff)
    );
  assign plm_in_ping_a1_a_d_data_rsci_w_en_d_pff = plm_in_ping_a1_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1 (
  plm_in_ping_a0_a_d_data_rsci_w_en_d_pff, load_wten_pff, plm_in_ping_a0_a_d_data_rsci_iswt0_pff
);
  output plm_in_ping_a0_a_d_data_rsci_w_en_d_pff;
  input load_wten_pff;
  input plm_in_ping_a0_a_d_data_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_ping_a0_a_d_data_rsci_biwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_ctrl
      Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1_plm_in_ping_a0_a_d_data_rsc_wait_ctrl_inst
      (
      .plm_in_ping_a0_a_d_data_rsci_biwt_pff(plm_in_ping_a0_a_d_data_rsci_biwt_iff),
      .load_wten_pff(load_wten_pff),
      .plm_in_ping_a0_a_d_data_rsci_iswt0_pff(plm_in_ping_a0_a_d_data_rsci_iswt0_pff)
    );
  assign plm_in_ping_a0_a_d_data_rsci_w_en_d_pff = plm_in_ping_a0_a_d_data_rsci_biwt_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_sync12_sync_out_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_sync12_sync_out_mioi (
  clk, rst, sync12_vld, sync12_rdy, load_wten, sync12_sync_out_mioi_oswt, sync12_sync_out_mioi_wen_comp,
      sync12_sync_out_mioi_oswt_pff
);
  input clk;
  input rst;
  output sync12_vld;
  input sync12_rdy;
  input load_wten;
  input sync12_sync_out_mioi_oswt;
  output sync12_sync_out_mioi_wen_comp;
  input sync12_sync_out_mioi_oswt_pff;


  // Interconnect Declarations
  wire sync12_sync_out_mioi_biwt;
  wire sync12_sync_out_mioi_ccs_ccore_start_rsc_dat_load_sct;
  wire sync12_sync_out_mioi_ccs_ccore_done_sync_vld;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Connections_conn_sync_chan_sync_out  sync12_sync_out_mioi (
      .this_vld(sync12_vld),
      .this_rdy(sync12_rdy),
      .ccs_ccore_start_rsc_dat(sync12_sync_out_mioi_ccs_ccore_start_rsc_dat_load_sct),
      .ccs_ccore_done_sync_vld(sync12_sync_out_mioi_ccs_ccore_done_sync_vld),
      .ccs_MIO_clk(clk),
      .ccs_MIO_arst(rst)
    );
  esp_acc_DUMMY_Ctrl_load_load_sync12_sync_out_mioi_sync12_sync_out_mio_wait_ctrl
      Ctrl_load_load_sync12_sync_out_mioi_sync12_sync_out_mio_wait_ctrl_inst (
      .load_wten(load_wten),
      .sync12_sync_out_mioi_iswt0(sync12_sync_out_mioi_oswt),
      .sync12_sync_out_mioi_biwt(sync12_sync_out_mioi_biwt),
      .sync12_sync_out_mioi_ccs_ccore_start_rsc_dat_load_sct(sync12_sync_out_mioi_ccs_ccore_start_rsc_dat_load_sct),
      .sync12_sync_out_mioi_ccs_ccore_done_sync_vld(sync12_sync_out_mioi_ccs_ccore_done_sync_vld),
      .sync12_sync_out_mioi_iswt0_pff(sync12_sync_out_mioi_oswt_pff)
    );
  assign sync12_sync_out_mioi_wen_comp = (~ sync12_sync_out_mioi_oswt) | sync12_sync_out_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_dma_read_chnl_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_dma_read_chnl_Pop_mioi (
  clk, rst, dma_read_chnl_val, dma_read_chnl_rdy, dma_read_chnl_msg, load_wen, dma_read_chnl_Pop_mioi_oswt,
      dma_read_chnl_Pop_mioi_wen_comp, dma_read_chnl_Pop_mioi_idat_mxwt, dma_read_chnl_Pop_mioi_ivld,
      dma_read_chnl_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input dma_read_chnl_val;
  output dma_read_chnl_rdy;
  input [63:0] dma_read_chnl_msg;
  input load_wen;
  input dma_read_chnl_Pop_mioi_oswt;
  output dma_read_chnl_Pop_mioi_wen_comp;
  output [63:0] dma_read_chnl_Pop_mioi_idat_mxwt;
  output dma_read_chnl_Pop_mioi_ivld;
  input dma_read_chnl_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire dma_read_chnl_Pop_mioi_biwt;
  wire dma_read_chnl_Pop_mioi_bdwt;
  wire dma_read_chnl_Pop_mioi_bcwt;
  wire [63:0] dma_read_chnl_Pop_mioi_idat;
  wire dma_read_chnl_Pop_mioi_irdy_load_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd71),
  .width(32'sd64),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) dma_read_chnl_Pop_mioi (
      .vld(dma_read_chnl_val),
      .rdy(dma_read_chnl_rdy),
      .dat(dma_read_chnl_msg),
      .idat(dma_read_chnl_Pop_mioi_idat),
      .irdy(dma_read_chnl_Pop_mioi_irdy_load_sct),
      .ivld(dma_read_chnl_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_load_load_dma_read_chnl_Pop_mioi_dma_read_chnl_Pop_mio_wait_ctrl
      Ctrl_load_load_dma_read_chnl_Pop_mioi_dma_read_chnl_Pop_mio_wait_ctrl_inst
      (
      .load_wen(load_wen),
      .dma_read_chnl_Pop_mioi_oswt(dma_read_chnl_Pop_mioi_oswt),
      .dma_read_chnl_Pop_mioi_ivld_oreg(dma_read_chnl_Pop_mioi_ivld_oreg),
      .dma_read_chnl_Pop_mioi_biwt(dma_read_chnl_Pop_mioi_biwt),
      .dma_read_chnl_Pop_mioi_bdwt(dma_read_chnl_Pop_mioi_bdwt),
      .dma_read_chnl_Pop_mioi_bcwt(dma_read_chnl_Pop_mioi_bcwt),
      .dma_read_chnl_Pop_mioi_irdy_load_sct(dma_read_chnl_Pop_mioi_irdy_load_sct)
    );
  esp_acc_DUMMY_Ctrl_load_load_dma_read_chnl_Pop_mioi_dma_read_chnl_Pop_mio_wait_dp
      Ctrl_load_load_dma_read_chnl_Pop_mioi_dma_read_chnl_Pop_mio_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_Pop_mioi_oswt(dma_read_chnl_Pop_mioi_oswt),
      .dma_read_chnl_Pop_mioi_wen_comp(dma_read_chnl_Pop_mioi_wen_comp),
      .dma_read_chnl_Pop_mioi_idat_mxwt(dma_read_chnl_Pop_mioi_idat_mxwt),
      .dma_read_chnl_Pop_mioi_biwt(dma_read_chnl_Pop_mioi_biwt),
      .dma_read_chnl_Pop_mioi_bdwt(dma_read_chnl_Pop_mioi_bdwt),
      .dma_read_chnl_Pop_mioi_bcwt(dma_read_chnl_Pop_mioi_bcwt),
      .dma_read_chnl_Pop_mioi_idat(dma_read_chnl_Pop_mioi_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_dma_read_ctrl_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_dma_read_ctrl_Push_mioi (
  clk, rst, dma_read_ctrl_val, dma_read_ctrl_rdy, dma_read_ctrl_msg, dma_read_ctrl_Push_mioi_oswt,
      dma_read_ctrl_Push_mioi_wen_comp, dma_read_ctrl_Push_mioi_idat, dma_read_ctrl_Push_mioi_irdy,
      dma_read_ctrl_Push_mioi_irdy_oreg
);
  input clk;
  input rst;
  output dma_read_ctrl_val;
  input dma_read_ctrl_rdy;
  output [72:0] dma_read_ctrl_msg;
  input dma_read_ctrl_Push_mioi_oswt;
  output dma_read_ctrl_Push_mioi_wen_comp;
  input [72:0] dma_read_ctrl_Push_mioi_idat;
  output dma_read_ctrl_Push_mioi_irdy;
  input dma_read_ctrl_Push_mioi_irdy_oreg;


  // Interconnect Declarations
  wire dma_read_ctrl_Push_mioi_biwt;


  // Interconnect Declarations for Component Instantiations 
  wire [72:0] nl_dma_read_ctrl_Push_mioi_idat;
  assign nl_dma_read_ctrl_Push_mioi_idat = {10'b0000000100 , (dma_read_ctrl_Push_mioi_idat[62:32])
      , 1'b0 , (dma_read_ctrl_Push_mioi_idat[30:0])};
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd70),
  .width(32'sd73),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) dma_read_ctrl_Push_mioi (
      .vld(dma_read_ctrl_val),
      .rdy(dma_read_ctrl_rdy),
      .dat(dma_read_ctrl_msg),
      .idat(nl_dma_read_ctrl_Push_mioi_idat[72:0]),
      .irdy(dma_read_ctrl_Push_mioi_irdy),
      .ivld(dma_read_ctrl_Push_mioi_oswt),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_load_load_dma_read_ctrl_Push_mioi_dma_read_ctrl_Push_mio_wait_ctrl
      Ctrl_load_load_dma_read_ctrl_Push_mioi_dma_read_ctrl_Push_mio_wait_ctrl_inst
      (
      .dma_read_ctrl_Push_mioi_iswt0(dma_read_ctrl_Push_mioi_oswt),
      .dma_read_ctrl_Push_mioi_irdy_oreg(dma_read_ctrl_Push_mioi_irdy_oreg),
      .dma_read_ctrl_Push_mioi_biwt(dma_read_ctrl_Push_mioi_biwt)
    );
  assign dma_read_ctrl_Push_mioi_wen_comp = (~ dma_read_ctrl_Push_mioi_oswt) | dma_read_ctrl_Push_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_conf1_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_conf1_Pop_mioi (
  clk, rst, conf1_val, conf1_rdy, conf1_msg, load_wen, conf1_Pop_mioi_oswt, conf1_Pop_mioi_wen_comp,
      conf1_Pop_mioi_idat_mxwt, conf1_Pop_mioi_ivld, conf1_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input conf1_val;
  output conf1_rdy;
  input [95:0] conf1_msg;
  input load_wen;
  input conf1_Pop_mioi_oswt;
  output conf1_Pop_mioi_wen_comp;
  output [95:0] conf1_Pop_mioi_idat_mxwt;
  output conf1_Pop_mioi_ivld;
  input conf1_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire conf1_Pop_mioi_biwt;
  wire conf1_Pop_mioi_bdwt;
  wire conf1_Pop_mioi_bcwt;
  wire [95:0] conf1_Pop_mioi_idat;
  wire conf1_Pop_mioi_irdy_load_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd69),
  .width(32'sd96),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf1_Pop_mioi (
      .vld(conf1_val),
      .rdy(conf1_rdy),
      .dat(conf1_msg),
      .idat(conf1_Pop_mioi_idat),
      .irdy(conf1_Pop_mioi_irdy_load_sct),
      .ivld(conf1_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_load_load_conf1_Pop_mioi_conf1_Pop_mio_wait_ctrl Ctrl_load_load_conf1_Pop_mioi_conf1_Pop_mio_wait_ctrl_inst
      (
      .load_wen(load_wen),
      .conf1_Pop_mioi_oswt(conf1_Pop_mioi_oswt),
      .conf1_Pop_mioi_ivld_oreg(conf1_Pop_mioi_ivld_oreg),
      .conf1_Pop_mioi_biwt(conf1_Pop_mioi_biwt),
      .conf1_Pop_mioi_bdwt(conf1_Pop_mioi_bdwt),
      .conf1_Pop_mioi_bcwt(conf1_Pop_mioi_bcwt),
      .conf1_Pop_mioi_irdy_load_sct(conf1_Pop_mioi_irdy_load_sct)
    );
  esp_acc_DUMMY_Ctrl_load_load_conf1_Pop_mioi_conf1_Pop_mio_wait_dp Ctrl_load_load_conf1_Pop_mioi_conf1_Pop_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf1_Pop_mioi_oswt(conf1_Pop_mioi_oswt),
      .conf1_Pop_mioi_wen_comp(conf1_Pop_mioi_wen_comp),
      .conf1_Pop_mioi_idat_mxwt(conf1_Pop_mioi_idat_mxwt),
      .conf1_Pop_mioi_biwt(conf1_Pop_mioi_biwt),
      .conf1_Pop_mioi_bdwt(conf1_Pop_mioi_bdwt),
      .conf1_Pop_mioi_bcwt(conf1_Pop_mioi_bcwt),
      .conf1_Pop_mioi_idat(conf1_Pop_mioi_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load_sync01_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load_sync01_Pop_mioi (
  clk, rst, sync01_val, sync01_rdy, sync01_msg, load_wen, sync01_Pop_mioi_oswt, sync01_Pop_mioi_wen_comp,
      sync01_Pop_mioi_ivld, sync01_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input sync01_val;
  output sync01_rdy;
  input sync01_msg;
  input load_wen;
  input sync01_Pop_mioi_oswt;
  output sync01_Pop_mioi_wen_comp;
  output sync01_Pop_mioi_ivld;
  input sync01_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire sync01_Pop_mioi_biwt;
  wire sync01_Pop_mioi_bdwt;
  wire sync01_Pop_mioi_bcwt;
  wire sync01_Pop_mioi_idat;
  wire sync01_Pop_mioi_irdy_load_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd68),
  .width(32'sd1),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) sync01_Pop_mioi (
      .vld(sync01_val),
      .rdy(sync01_rdy),
      .dat(sync01_msg),
      .idat(sync01_Pop_mioi_idat),
      .irdy(sync01_Pop_mioi_irdy_load_sct),
      .ivld(sync01_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_load_load_sync01_Pop_mioi_sync01_Pop_mio_wait_ctrl Ctrl_load_load_sync01_Pop_mioi_sync01_Pop_mio_wait_ctrl_inst
      (
      .load_wen(load_wen),
      .sync01_Pop_mioi_oswt(sync01_Pop_mioi_oswt),
      .sync01_Pop_mioi_ivld_oreg(sync01_Pop_mioi_ivld_oreg),
      .sync01_Pop_mioi_biwt(sync01_Pop_mioi_biwt),
      .sync01_Pop_mioi_bdwt(sync01_Pop_mioi_bdwt),
      .sync01_Pop_mioi_bcwt(sync01_Pop_mioi_bcwt),
      .sync01_Pop_mioi_irdy_load_sct(sync01_Pop_mioi_irdy_load_sct)
    );
  esp_acc_DUMMY_Ctrl_load_load_sync01_Pop_mioi_sync01_Pop_mio_wait_dp Ctrl_load_load_sync01_Pop_mioi_sync01_Pop_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .sync01_Pop_mioi_oswt(sync01_Pop_mioi_oswt),
      .sync01_Pop_mioi_wen_comp(sync01_Pop_mioi_wen_comp),
      .sync01_Pop_mioi_biwt(sync01_Pop_mioi_biwt),
      .sync01_Pop_mioi_bdwt(sync01_Pop_mioi_bdwt),
      .sync01_Pop_mioi_bcwt(sync01_Pop_mioi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync03_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync03_Push_mioi (
  clk, rst, sync03_val, sync03_rdy, sync03_msg, config_wen, sync03_Push_mioi_oswt,
      sync03_Push_mioi_wen_comp, sync03_Push_mioi_irdy, sync03_Push_mioi_irdy_oreg,
      sync03_Push_mioi_oswt_pff, sync03_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output sync03_val;
  input sync03_rdy;
  output sync03_msg;
  input config_wen;
  input sync03_Push_mioi_oswt;
  output sync03_Push_mioi_wen_comp;
  output sync03_Push_mioi_irdy;
  input sync03_Push_mioi_irdy_oreg;
  input sync03_Push_mioi_oswt_pff;
  input sync03_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire sync03_Push_mioi_biwt;
  wire sync03_Push_mioi_bdwt;
  wire sync03_Push_mioi_bcwt;
  wire sync03_Push_mioi_ivld_config_sct;
  wire sync03_Push_mioi_wen_comp_reg;
  wire sync03_Push_mioi_biwt_iff;
  wire sync03_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd67),
  .width(32'sd1),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) sync03_Push_mioi (
      .vld(sync03_val),
      .rdy(sync03_rdy),
      .dat(sync03_msg),
      .idat(1'b1),
      .irdy(sync03_Push_mioi_irdy),
      .ivld(sync03_Push_mioi_ivld_config_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync03_Push_mioi_sync03_Push_mio_wait_ctrl Ctrl_config_config_sync03_Push_mioi_sync03_Push_mio_wait_ctrl_inst
      (
      .config_wen(config_wen),
      .sync03_Push_mioi_oswt(sync03_Push_mioi_oswt),
      .sync03_Push_mioi_irdy_oreg(sync03_Push_mioi_irdy_oreg),
      .sync03_Push_mioi_biwt(sync03_Push_mioi_biwt),
      .sync03_Push_mioi_bdwt(sync03_Push_mioi_bdwt),
      .sync03_Push_mioi_bcwt(sync03_Push_mioi_bcwt),
      .sync03_Push_mioi_ivld_config_sct(sync03_Push_mioi_ivld_config_sct),
      .sync03_Push_mioi_biwt_pff(sync03_Push_mioi_biwt_iff),
      .sync03_Push_mioi_oswt_pff(sync03_Push_mioi_oswt_pff),
      .sync03_Push_mioi_bcwt_pff(sync03_Push_mioi_bcwt_iff),
      .sync03_Push_mioi_irdy_oreg_pff(sync03_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync03_Push_mioi_sync03_Push_mio_wait_dp Ctrl_config_config_sync03_Push_mioi_sync03_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .sync03_Push_mioi_oswt(sync03_Push_mioi_oswt_pff),
      .sync03_Push_mioi_wen_comp(sync03_Push_mioi_wen_comp_reg),
      .sync03_Push_mioi_biwt(sync03_Push_mioi_biwt),
      .sync03_Push_mioi_bdwt(sync03_Push_mioi_bdwt),
      .sync03_Push_mioi_bcwt(sync03_Push_mioi_bcwt),
      .sync03_Push_mioi_biwt_pff(sync03_Push_mioi_biwt_iff),
      .sync03_Push_mioi_bcwt_pff(sync03_Push_mioi_bcwt_iff)
    );
  assign sync03_Push_mioi_wen_comp = sync03_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync02_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync02_Push_mioi (
  clk, rst, sync02_val, sync02_rdy, sync02_msg, config_wen, sync02_Push_mioi_oswt,
      sync02_Push_mioi_wen_comp, sync02_Push_mioi_irdy, sync02_Push_mioi_irdy_oreg,
      sync02_Push_mioi_oswt_pff, sync02_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output sync02_val;
  input sync02_rdy;
  output sync02_msg;
  input config_wen;
  input sync02_Push_mioi_oswt;
  output sync02_Push_mioi_wen_comp;
  output sync02_Push_mioi_irdy;
  input sync02_Push_mioi_irdy_oreg;
  input sync02_Push_mioi_oswt_pff;
  input sync02_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire sync02_Push_mioi_biwt;
  wire sync02_Push_mioi_bdwt;
  wire sync02_Push_mioi_bcwt;
  wire sync02_Push_mioi_ivld_config_sct;
  wire sync02_Push_mioi_wen_comp_reg;
  wire sync02_Push_mioi_biwt_iff;
  wire sync02_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd66),
  .width(32'sd1),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) sync02_Push_mioi (
      .vld(sync02_val),
      .rdy(sync02_rdy),
      .dat(sync02_msg),
      .idat(1'b1),
      .irdy(sync02_Push_mioi_irdy),
      .ivld(sync02_Push_mioi_ivld_config_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync02_Push_mioi_sync02_Push_mio_wait_ctrl Ctrl_config_config_sync02_Push_mioi_sync02_Push_mio_wait_ctrl_inst
      (
      .config_wen(config_wen),
      .sync02_Push_mioi_oswt(sync02_Push_mioi_oswt),
      .sync02_Push_mioi_irdy_oreg(sync02_Push_mioi_irdy_oreg),
      .sync02_Push_mioi_biwt(sync02_Push_mioi_biwt),
      .sync02_Push_mioi_bdwt(sync02_Push_mioi_bdwt),
      .sync02_Push_mioi_bcwt(sync02_Push_mioi_bcwt),
      .sync02_Push_mioi_ivld_config_sct(sync02_Push_mioi_ivld_config_sct),
      .sync02_Push_mioi_biwt_pff(sync02_Push_mioi_biwt_iff),
      .sync02_Push_mioi_oswt_pff(sync02_Push_mioi_oswt_pff),
      .sync02_Push_mioi_bcwt_pff(sync02_Push_mioi_bcwt_iff),
      .sync02_Push_mioi_irdy_oreg_pff(sync02_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync02_Push_mioi_sync02_Push_mio_wait_dp Ctrl_config_config_sync02_Push_mioi_sync02_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .sync02_Push_mioi_oswt(sync02_Push_mioi_oswt_pff),
      .sync02_Push_mioi_wen_comp(sync02_Push_mioi_wen_comp_reg),
      .sync02_Push_mioi_biwt(sync02_Push_mioi_biwt),
      .sync02_Push_mioi_bdwt(sync02_Push_mioi_bdwt),
      .sync02_Push_mioi_bcwt(sync02_Push_mioi_bcwt),
      .sync02_Push_mioi_biwt_pff(sync02_Push_mioi_biwt_iff),
      .sync02_Push_mioi_bcwt_pff(sync02_Push_mioi_bcwt_iff)
    );
  assign sync02_Push_mioi_wen_comp = sync02_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync01_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync01_Push_mioi (
  clk, rst, sync01_val, sync01_rdy, sync01_msg, config_wen, sync01_Push_mioi_oswt,
      sync01_Push_mioi_wen_comp, sync01_Push_mioi_irdy, sync01_Push_mioi_irdy_oreg,
      sync01_Push_mioi_oswt_pff, sync01_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output sync01_val;
  input sync01_rdy;
  output sync01_msg;
  input config_wen;
  input sync01_Push_mioi_oswt;
  output sync01_Push_mioi_wen_comp;
  output sync01_Push_mioi_irdy;
  input sync01_Push_mioi_irdy_oreg;
  input sync01_Push_mioi_oswt_pff;
  input sync01_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire sync01_Push_mioi_biwt;
  wire sync01_Push_mioi_bdwt;
  wire sync01_Push_mioi_bcwt;
  wire sync01_Push_mioi_ivld_config_sct;
  wire sync01_Push_mioi_wen_comp_reg;
  wire sync01_Push_mioi_biwt_iff;
  wire sync01_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd65),
  .width(32'sd1),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) sync01_Push_mioi (
      .vld(sync01_val),
      .rdy(sync01_rdy),
      .dat(sync01_msg),
      .idat(1'b1),
      .irdy(sync01_Push_mioi_irdy),
      .ivld(sync01_Push_mioi_ivld_config_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync01_Push_mioi_sync01_Push_mio_wait_ctrl Ctrl_config_config_sync01_Push_mioi_sync01_Push_mio_wait_ctrl_inst
      (
      .config_wen(config_wen),
      .sync01_Push_mioi_oswt(sync01_Push_mioi_oswt),
      .sync01_Push_mioi_irdy_oreg(sync01_Push_mioi_irdy_oreg),
      .sync01_Push_mioi_biwt(sync01_Push_mioi_biwt),
      .sync01_Push_mioi_bdwt(sync01_Push_mioi_bdwt),
      .sync01_Push_mioi_bcwt(sync01_Push_mioi_bcwt),
      .sync01_Push_mioi_ivld_config_sct(sync01_Push_mioi_ivld_config_sct),
      .sync01_Push_mioi_biwt_pff(sync01_Push_mioi_biwt_iff),
      .sync01_Push_mioi_oswt_pff(sync01_Push_mioi_oswt_pff),
      .sync01_Push_mioi_bcwt_pff(sync01_Push_mioi_bcwt_iff),
      .sync01_Push_mioi_irdy_oreg_pff(sync01_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync01_Push_mioi_sync01_Push_mio_wait_dp Ctrl_config_config_sync01_Push_mioi_sync01_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .sync01_Push_mioi_oswt(sync01_Push_mioi_oswt_pff),
      .sync01_Push_mioi_wen_comp(sync01_Push_mioi_wen_comp_reg),
      .sync01_Push_mioi_biwt(sync01_Push_mioi_biwt),
      .sync01_Push_mioi_bdwt(sync01_Push_mioi_bdwt),
      .sync01_Push_mioi_bcwt(sync01_Push_mioi_bcwt),
      .sync01_Push_mioi_biwt_pff(sync01_Push_mioi_biwt_iff),
      .sync01_Push_mioi_bcwt_pff(sync01_Push_mioi_bcwt_iff)
    );
  assign sync01_Push_mioi_wen_comp = sync01_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_sync00_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_sync00_Push_mioi (
  clk, rst, sync00_val, sync00_rdy, sync00_msg, config_wen, sync00_Push_mioi_oswt,
      sync00_Push_mioi_wen_comp, sync00_Push_mioi_irdy, sync00_Push_mioi_irdy_oreg,
      sync00_Push_mioi_oswt_pff, sync00_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output sync00_val;
  input sync00_rdy;
  output sync00_msg;
  input config_wen;
  input sync00_Push_mioi_oswt;
  output sync00_Push_mioi_wen_comp;
  output sync00_Push_mioi_irdy;
  input sync00_Push_mioi_irdy_oreg;
  input sync00_Push_mioi_oswt_pff;
  input sync00_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire sync00_Push_mioi_biwt;
  wire sync00_Push_mioi_bdwt;
  wire sync00_Push_mioi_bcwt;
  wire sync00_Push_mioi_ivld_config_sct;
  wire sync00_Push_mioi_wen_comp_reg;
  wire sync00_Push_mioi_biwt_iff;
  wire sync00_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd64),
  .width(32'sd1),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) sync00_Push_mioi (
      .vld(sync00_val),
      .rdy(sync00_rdy),
      .dat(sync00_msg),
      .idat(1'b1),
      .irdy(sync00_Push_mioi_irdy),
      .ivld(sync00_Push_mioi_ivld_config_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync00_Push_mioi_sync00_Push_mio_wait_ctrl Ctrl_config_config_sync00_Push_mioi_sync00_Push_mio_wait_ctrl_inst
      (
      .config_wen(config_wen),
      .sync00_Push_mioi_oswt(sync00_Push_mioi_oswt),
      .sync00_Push_mioi_irdy_oreg(sync00_Push_mioi_irdy_oreg),
      .sync00_Push_mioi_biwt(sync00_Push_mioi_biwt),
      .sync00_Push_mioi_bdwt(sync00_Push_mioi_bdwt),
      .sync00_Push_mioi_bcwt(sync00_Push_mioi_bcwt),
      .sync00_Push_mioi_ivld_config_sct(sync00_Push_mioi_ivld_config_sct),
      .sync00_Push_mioi_biwt_pff(sync00_Push_mioi_biwt_iff),
      .sync00_Push_mioi_oswt_pff(sync00_Push_mioi_oswt_pff),
      .sync00_Push_mioi_bcwt_pff(sync00_Push_mioi_bcwt_iff),
      .sync00_Push_mioi_irdy_oreg_pff(sync00_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync00_Push_mioi_sync00_Push_mio_wait_dp Ctrl_config_config_sync00_Push_mioi_sync00_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .sync00_Push_mioi_oswt(sync00_Push_mioi_oswt_pff),
      .sync00_Push_mioi_wen_comp(sync00_Push_mioi_wen_comp_reg),
      .sync00_Push_mioi_biwt(sync00_Push_mioi_biwt),
      .sync00_Push_mioi_bdwt(sync00_Push_mioi_bdwt),
      .sync00_Push_mioi_bcwt(sync00_Push_mioi_bcwt),
      .sync00_Push_mioi_biwt_pff(sync00_Push_mioi_biwt_iff),
      .sync00_Push_mioi_bcwt_pff(sync00_Push_mioi_bcwt_iff)
    );
  assign sync00_Push_mioi_wen_comp = sync00_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf3_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf3_Push_mioi (
  clk, rst, conf3_val, conf3_rdy, conf3_msg, config_wen, conf3_Push_mioi_oswt, conf3_Push_mioi_wen_comp,
      conf3_Push_mioi_idat, conf3_Push_mioi_irdy, conf3_Push_mioi_irdy_oreg, conf3_Push_mioi_oswt_pff,
      conf3_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output conf3_val;
  input conf3_rdy;
  output [95:0] conf3_msg;
  input config_wen;
  input conf3_Push_mioi_oswt;
  output conf3_Push_mioi_wen_comp;
  input [95:0] conf3_Push_mioi_idat;
  output conf3_Push_mioi_irdy;
  input conf3_Push_mioi_irdy_oreg;
  input conf3_Push_mioi_oswt_pff;
  input conf3_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf3_Push_mioi_biwt;
  wire conf3_Push_mioi_bdwt;
  wire conf3_Push_mioi_bcwt;
  wire conf3_Push_mioi_ivld_config_sct;
  wire conf3_Push_mioi_wen_comp_reg;
  wire conf3_Push_mioi_biwt_iff;
  wire conf3_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd63),
  .width(32'sd96),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf3_Push_mioi (
      .vld(conf3_val),
      .rdy(conf3_rdy),
      .dat(conf3_msg),
      .idat(conf3_Push_mioi_idat),
      .irdy(conf3_Push_mioi_irdy),
      .ivld(conf3_Push_mioi_ivld_config_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf3_Push_mioi_conf3_Push_mio_wait_ctrl Ctrl_config_config_conf3_Push_mioi_conf3_Push_mio_wait_ctrl_inst
      (
      .config_wen(config_wen),
      .conf3_Push_mioi_oswt(conf3_Push_mioi_oswt),
      .conf3_Push_mioi_irdy_oreg(conf3_Push_mioi_irdy_oreg),
      .conf3_Push_mioi_biwt(conf3_Push_mioi_biwt),
      .conf3_Push_mioi_bdwt(conf3_Push_mioi_bdwt),
      .conf3_Push_mioi_bcwt(conf3_Push_mioi_bcwt),
      .conf3_Push_mioi_ivld_config_sct(conf3_Push_mioi_ivld_config_sct),
      .conf3_Push_mioi_biwt_pff(conf3_Push_mioi_biwt_iff),
      .conf3_Push_mioi_oswt_pff(conf3_Push_mioi_oswt_pff),
      .conf3_Push_mioi_bcwt_pff(conf3_Push_mioi_bcwt_iff),
      .conf3_Push_mioi_irdy_oreg_pff(conf3_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf3_Push_mioi_conf3_Push_mio_wait_dp Ctrl_config_config_conf3_Push_mioi_conf3_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf3_Push_mioi_oswt(conf3_Push_mioi_oswt_pff),
      .conf3_Push_mioi_wen_comp(conf3_Push_mioi_wen_comp_reg),
      .conf3_Push_mioi_biwt(conf3_Push_mioi_biwt),
      .conf3_Push_mioi_bdwt(conf3_Push_mioi_bdwt),
      .conf3_Push_mioi_bcwt(conf3_Push_mioi_bcwt),
      .conf3_Push_mioi_biwt_pff(conf3_Push_mioi_biwt_iff),
      .conf3_Push_mioi_bcwt_pff(conf3_Push_mioi_bcwt_iff)
    );
  assign conf3_Push_mioi_wen_comp = conf3_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf2_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf2_Push_mioi (
  clk, rst, conf2_val, conf2_rdy, conf2_msg, config_wen, conf2_Push_mioi_oswt, conf2_Push_mioi_wen_comp,
      conf2_Push_mioi_idat, conf2_Push_mioi_irdy, conf2_Push_mioi_irdy_oreg, conf2_Push_mioi_oswt_pff,
      conf2_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output conf2_val;
  input conf2_rdy;
  output [95:0] conf2_msg;
  input config_wen;
  input conf2_Push_mioi_oswt;
  output conf2_Push_mioi_wen_comp;
  input [95:0] conf2_Push_mioi_idat;
  output conf2_Push_mioi_irdy;
  input conf2_Push_mioi_irdy_oreg;
  input conf2_Push_mioi_oswt_pff;
  input conf2_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf2_Push_mioi_biwt;
  wire conf2_Push_mioi_bdwt;
  wire conf2_Push_mioi_bcwt;
  wire conf2_Push_mioi_ivld_config_sct;
  wire conf2_Push_mioi_wen_comp_reg;
  wire conf2_Push_mioi_biwt_iff;
  wire conf2_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd62),
  .width(32'sd96),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf2_Push_mioi (
      .vld(conf2_val),
      .rdy(conf2_rdy),
      .dat(conf2_msg),
      .idat(conf2_Push_mioi_idat),
      .irdy(conf2_Push_mioi_irdy),
      .ivld(conf2_Push_mioi_ivld_config_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf2_Push_mioi_conf2_Push_mio_wait_ctrl Ctrl_config_config_conf2_Push_mioi_conf2_Push_mio_wait_ctrl_inst
      (
      .config_wen(config_wen),
      .conf2_Push_mioi_oswt(conf2_Push_mioi_oswt),
      .conf2_Push_mioi_irdy_oreg(conf2_Push_mioi_irdy_oreg),
      .conf2_Push_mioi_biwt(conf2_Push_mioi_biwt),
      .conf2_Push_mioi_bdwt(conf2_Push_mioi_bdwt),
      .conf2_Push_mioi_bcwt(conf2_Push_mioi_bcwt),
      .conf2_Push_mioi_ivld_config_sct(conf2_Push_mioi_ivld_config_sct),
      .conf2_Push_mioi_biwt_pff(conf2_Push_mioi_biwt_iff),
      .conf2_Push_mioi_oswt_pff(conf2_Push_mioi_oswt_pff),
      .conf2_Push_mioi_bcwt_pff(conf2_Push_mioi_bcwt_iff),
      .conf2_Push_mioi_irdy_oreg_pff(conf2_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf2_Push_mioi_conf2_Push_mio_wait_dp Ctrl_config_config_conf2_Push_mioi_conf2_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf2_Push_mioi_oswt(conf2_Push_mioi_oswt_pff),
      .conf2_Push_mioi_wen_comp(conf2_Push_mioi_wen_comp_reg),
      .conf2_Push_mioi_biwt(conf2_Push_mioi_biwt),
      .conf2_Push_mioi_bdwt(conf2_Push_mioi_bdwt),
      .conf2_Push_mioi_bcwt(conf2_Push_mioi_bcwt),
      .conf2_Push_mioi_biwt_pff(conf2_Push_mioi_biwt_iff),
      .conf2_Push_mioi_bcwt_pff(conf2_Push_mioi_bcwt_iff)
    );
  assign conf2_Push_mioi_wen_comp = conf2_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf1_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf1_Push_mioi (
  clk, rst, conf1_val, conf1_rdy, conf1_msg, config_wen, conf1_Push_mioi_oswt, conf1_Push_mioi_wen_comp,
      conf1_Push_mioi_idat, conf1_Push_mioi_irdy, conf1_Push_mioi_irdy_oreg, conf1_Push_mioi_oswt_pff,
      conf1_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output conf1_val;
  input conf1_rdy;
  output [95:0] conf1_msg;
  input config_wen;
  input conf1_Push_mioi_oswt;
  output conf1_Push_mioi_wen_comp;
  input [95:0] conf1_Push_mioi_idat;
  output conf1_Push_mioi_irdy;
  input conf1_Push_mioi_irdy_oreg;
  input conf1_Push_mioi_oswt_pff;
  input conf1_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf1_Push_mioi_biwt;
  wire conf1_Push_mioi_bdwt;
  wire conf1_Push_mioi_bcwt;
  wire conf1_Push_mioi_ivld_config_sct;
  wire conf1_Push_mioi_wen_comp_reg;
  wire conf1_Push_mioi_biwt_iff;
  wire conf1_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd61),
  .width(32'sd96),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf1_Push_mioi (
      .vld(conf1_val),
      .rdy(conf1_rdy),
      .dat(conf1_msg),
      .idat(conf1_Push_mioi_idat),
      .irdy(conf1_Push_mioi_irdy),
      .ivld(conf1_Push_mioi_ivld_config_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf1_Push_mioi_conf1_Push_mio_wait_ctrl Ctrl_config_config_conf1_Push_mioi_conf1_Push_mio_wait_ctrl_inst
      (
      .config_wen(config_wen),
      .conf1_Push_mioi_oswt(conf1_Push_mioi_oswt),
      .conf1_Push_mioi_irdy_oreg(conf1_Push_mioi_irdy_oreg),
      .conf1_Push_mioi_biwt(conf1_Push_mioi_biwt),
      .conf1_Push_mioi_bdwt(conf1_Push_mioi_bdwt),
      .conf1_Push_mioi_bcwt(conf1_Push_mioi_bcwt),
      .conf1_Push_mioi_ivld_config_sct(conf1_Push_mioi_ivld_config_sct),
      .conf1_Push_mioi_biwt_pff(conf1_Push_mioi_biwt_iff),
      .conf1_Push_mioi_oswt_pff(conf1_Push_mioi_oswt_pff),
      .conf1_Push_mioi_bcwt_pff(conf1_Push_mioi_bcwt_iff),
      .conf1_Push_mioi_irdy_oreg_pff(conf1_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf1_Push_mioi_conf1_Push_mio_wait_dp Ctrl_config_config_conf1_Push_mioi_conf1_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf1_Push_mioi_oswt(conf1_Push_mioi_oswt_pff),
      .conf1_Push_mioi_wen_comp(conf1_Push_mioi_wen_comp_reg),
      .conf1_Push_mioi_biwt(conf1_Push_mioi_biwt),
      .conf1_Push_mioi_bdwt(conf1_Push_mioi_bdwt),
      .conf1_Push_mioi_bcwt(conf1_Push_mioi_bcwt),
      .conf1_Push_mioi_biwt_pff(conf1_Push_mioi_biwt_iff),
      .conf1_Push_mioi_bcwt_pff(conf1_Push_mioi_bcwt_iff)
    );
  assign conf1_Push_mioi_wen_comp = conf1_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf_info_out_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf_info_out_Push_mioi (
  clk, rst, conf_info_out_val, conf_info_out_rdy, conf_info_out_msg, config_wen,
      conf_info_out_Push_mioi_oswt, conf_info_out_Push_mioi_wen_comp, conf_info_out_Push_mioi_idat,
      conf_info_out_Push_mioi_irdy, conf_info_out_Push_mioi_irdy_oreg, conf_info_out_Push_mioi_oswt_pff,
      conf_info_out_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output conf_info_out_val;
  input conf_info_out_rdy;
  output [95:0] conf_info_out_msg;
  input config_wen;
  input conf_info_out_Push_mioi_oswt;
  output conf_info_out_Push_mioi_wen_comp;
  input [95:0] conf_info_out_Push_mioi_idat;
  output conf_info_out_Push_mioi_irdy;
  input conf_info_out_Push_mioi_irdy_oreg;
  input conf_info_out_Push_mioi_oswt_pff;
  input conf_info_out_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf_info_out_Push_mioi_biwt;
  wire conf_info_out_Push_mioi_bdwt;
  wire conf_info_out_Push_mioi_bcwt;
  wire conf_info_out_Push_mioi_ivld_config_sct;
  wire conf_info_out_Push_mioi_wen_comp_reg;
  wire conf_info_out_Push_mioi_biwt_iff;
  wire conf_info_out_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd60),
  .width(32'sd96),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_out_Push_mioi (
      .vld(conf_info_out_val),
      .rdy(conf_info_out_rdy),
      .dat(conf_info_out_msg),
      .idat(conf_info_out_Push_mioi_idat),
      .irdy(conf_info_out_Push_mioi_irdy),
      .ivld(conf_info_out_Push_mioi_ivld_config_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf_info_out_Push_mioi_conf_info_out_Push_mio_wait_ctrl
      Ctrl_config_config_conf_info_out_Push_mioi_conf_info_out_Push_mio_wait_ctrl_inst
      (
      .config_wen(config_wen),
      .conf_info_out_Push_mioi_oswt(conf_info_out_Push_mioi_oswt),
      .conf_info_out_Push_mioi_irdy_oreg(conf_info_out_Push_mioi_irdy_oreg),
      .conf_info_out_Push_mioi_biwt(conf_info_out_Push_mioi_biwt),
      .conf_info_out_Push_mioi_bdwt(conf_info_out_Push_mioi_bdwt),
      .conf_info_out_Push_mioi_bcwt(conf_info_out_Push_mioi_bcwt),
      .conf_info_out_Push_mioi_ivld_config_sct(conf_info_out_Push_mioi_ivld_config_sct),
      .conf_info_out_Push_mioi_biwt_pff(conf_info_out_Push_mioi_biwt_iff),
      .conf_info_out_Push_mioi_oswt_pff(conf_info_out_Push_mioi_oswt_pff),
      .conf_info_out_Push_mioi_bcwt_pff(conf_info_out_Push_mioi_bcwt_iff),
      .conf_info_out_Push_mioi_irdy_oreg_pff(conf_info_out_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf_info_out_Push_mioi_conf_info_out_Push_mio_wait_dp
      Ctrl_config_config_conf_info_out_Push_mioi_conf_info_out_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_out_Push_mioi_oswt(conf_info_out_Push_mioi_oswt_pff),
      .conf_info_out_Push_mioi_wen_comp(conf_info_out_Push_mioi_wen_comp_reg),
      .conf_info_out_Push_mioi_biwt(conf_info_out_Push_mioi_biwt),
      .conf_info_out_Push_mioi_bdwt(conf_info_out_Push_mioi_bdwt),
      .conf_info_out_Push_mioi_bcwt(conf_info_out_Push_mioi_bcwt),
      .conf_info_out_Push_mioi_biwt_pff(conf_info_out_Push_mioi_biwt_iff),
      .conf_info_out_Push_mioi_bcwt_pff(conf_info_out_Push_mioi_bcwt_iff)
    );
  assign conf_info_out_Push_mioi_wen_comp = conf_info_out_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config_conf_info_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config_conf_info_Pop_mioi (
  clk, rst, conf_info_val, conf_info_rdy, conf_info_msg, conf_info_Pop_mioi_oswt,
      conf_info_Pop_mioi_wen_comp, conf_info_Pop_mioi_idat_mxwt, conf_info_Pop_mioi_oswt_pff
);
  input clk;
  input rst;
  input conf_info_val;
  output conf_info_rdy;
  input [95:0] conf_info_msg;
  input conf_info_Pop_mioi_oswt;
  output conf_info_Pop_mioi_wen_comp;
  output [95:0] conf_info_Pop_mioi_idat_mxwt;
  input conf_info_Pop_mioi_oswt_pff;


  // Interconnect Declarations
  wire conf_info_Pop_mioi_biwt;
  wire [95:0] conf_info_Pop_mioi_idat;
  wire conf_info_Pop_mioi_ivld;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd59),
  .width(32'sd96),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_Pop_mioi (
      .vld(conf_info_val),
      .rdy(conf_info_rdy),
      .dat(conf_info_msg),
      .idat(conf_info_Pop_mioi_idat),
      .irdy(conf_info_Pop_mioi_oswt),
      .ivld(conf_info_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf_info_Pop_mioi_conf_info_Pop_mio_wait_ctrl
      Ctrl_config_config_conf_info_Pop_mioi_conf_info_Pop_mio_wait_ctrl_inst (
      .conf_info_Pop_mioi_iswt0(conf_info_Pop_mioi_oswt_pff),
      .conf_info_Pop_mioi_ivld_oreg(conf_info_Pop_mioi_ivld),
      .conf_info_Pop_mioi_biwt(conf_info_Pop_mioi_biwt)
    );
  assign conf_info_Pop_mioi_idat_mxwt = conf_info_Pop_mioi_idat;
  assign conf_info_Pop_mioi_wen_comp = (~ conf_info_Pop_mioi_oswt_pff) | conf_info_Pop_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store_store
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store_store (
  clk, rst, acc_done, dma_write_chnl_val, dma_write_chnl_rdy, dma_write_chnl_msg,
      dma_write_ctrl_val, dma_write_ctrl_rdy, dma_write_ctrl_msg, sync23_vld, sync23_rdy,
      sync03_val, sync03_rdy, sync03_msg, conf3_val, conf3_rdy, conf3_msg, plm_out_ping_a0_a_d_data_rsci_qout_d,
      plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d, plm_out_ping_a1_a_d_data_rsci_qout_d,
      plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d, plm_out_pong_a0_a_d_data_rsci_qout_d,
      plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d, plm_out_pong_a1_a_d_data_rsci_qout_d,
      plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d, while_store_offset_mul_1_cmp_a,
      while_store_offset_mul_1_cmp_b, while_store_offset_mul_1_cmp_z, plm_out_ping_a0_a_d_data_rsci_r_adr_d_pff
);
  input clk;
  input rst;
  output acc_done;
  reg acc_done;
  output dma_write_chnl_val;
  input dma_write_chnl_rdy;
  output [63:0] dma_write_chnl_msg;
  output dma_write_ctrl_val;
  input dma_write_ctrl_rdy;
  output [72:0] dma_write_ctrl_msg;
  input sync23_vld;
  output sync23_rdy;
  input sync03_val;
  output sync03_rdy;
  input sync03_msg;
  input conf3_val;
  output conf3_rdy;
  input [95:0] conf3_msg;
  input [31:0] plm_out_ping_a0_a_d_data_rsci_qout_d;
  output plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input [31:0] plm_out_ping_a1_a_d_data_rsci_qout_d;
  output plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input [31:0] plm_out_pong_a0_a_d_data_rsci_qout_d;
  output plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input [31:0] plm_out_pong_a1_a_d_data_rsci_qout_d;
  output plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  output [31:0] while_store_offset_mul_1_cmp_a;
  output [31:0] while_store_offset_mul_1_cmp_b;
  input [31:0] while_store_offset_mul_1_cmp_z;
  output [4:0] plm_out_ping_a0_a_d_data_rsci_r_adr_d_pff;


  // Interconnect Declarations
  wire store_wen;
  wire store_wten;
  wire sync03_Pop_mioi_wen_comp;
  wire sync03_Pop_mioi_ivld;
  wire sync03_Pop_mioi_ivld_oreg;
  wire conf3_Pop_mioi_wen_comp;
  wire [95:0] conf3_Pop_mioi_idat_mxwt;
  wire conf3_Pop_mioi_ivld;
  wire conf3_Pop_mioi_ivld_oreg;
  wire sync23_sync_in_mioi_wen_comp;
  wire dma_write_ctrl_Push_mioi_wen_comp;
  wire dma_write_ctrl_Push_mioi_irdy;
  wire dma_write_ctrl_Push_mioi_irdy_oreg;
  wire dma_write_chnl_Push_mioi_wen_comp;
  wire dma_write_chnl_Push_mioi_irdy;
  wire dma_write_chnl_Push_mioi_irdy_oreg;
  wire [31:0] plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt;
  wire [31:0] plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt;
  wire [31:0] plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt;
  wire [31:0] plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt;
  wire [31:0] while_store_offset_mul_1_cmp_z_oreg;
  reg [25:0] dma_write_ctrl_Push_mioi_idat_62_37;
  reg [4:0] dma_write_ctrl_Push_mioi_idat_36_32;
  reg [30:0] dma_write_ctrl_Push_mioi_idat_30_0;
  reg [31:0] dma_write_chnl_Push_mioi_idat_63_32;
  reg [31:0] dma_write_chnl_Push_mioi_idat_31_0;
  wire [16:0] fsm_output;
  wire and_dcpl_9;
  wire and_dcpl_10;
  reg while_for_for_for_for_k_1_sva;
  wire exit_while_for_sva_mx0;
  wire exit_while_for_for_sva_mx0;
  wire exit_while_for_for_for_sva_mx0;
  reg while_for_for_for_for_k_0_sva;
  reg ping_pong_lpi_2;
  wire or_17_cse;
  wire plm_out_ping_operator_mux_cse;
  wire or_20_cse;
  wire plm_out_pong_operator_mux_cse;
  reg reg_sync03_Pop_mioi_oswt_cse;
  reg reg_sync23_sync_in_mioi_oswt_cse;
  reg reg_dma_write_ctrl_Push_mioi_oswt_cse;
  reg reg_dma_write_chnl_Push_mioi_oswt_cse;
  reg reg_plm_out_ping_a0_a_d_data_rsci_oswt_cse;
  reg reg_plm_out_ping_a1_a_d_data_rsci_oswt_cse;
  reg reg_plm_out_pong_a0_a_d_data_rsci_oswt_cse;
  reg reg_plm_out_pong_a1_a_d_data_rsci_oswt_cse;
  wire while_for_for_and_cse;
  wire while_for_for_for_and_cse;
  wire while_for_for_for_i_and_cse;
  wire nor_3_cse;
  wire plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_75_rmff;
  wire plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_77_rmff;
  wire plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_79_rmff;
  wire plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_81_rmff;
  reg [6:0] while_for_for_out_idx_6_0_sva;
  reg ping_pong_sva;
  reg [30:0] while_length_acc_psp_sva;
  wire [31:0] nl_while_length_acc_psp_sva;
  reg [15:0] while_for_b_sva;
  reg [30:0] while_offset_31_1_lpi_3;
  reg [25:0] while_for_for_rem_31_6_sva;
  reg [25:0] while_for_for_len_qr_31_6_lpi_3_dfm;
  reg [4:0] while_for_for_len_qr_5_1_lpi_3_dfm;
  reg [6:0] while_for_for_for_i_7_1_sva;
  reg while_for_for_for_slc_32_1_itm;
  reg while_for_slc_32_1_itm;
  reg [31:0] while_for_for_for_dataBv_sva_1_63_32_1;
  reg [31:0] while_for_for_for_dataBv_sva_1_31_0_1;
  wire ac_array_1D_FPDATA_WORD_32U_operator_ac_array_1D_FPDATA_WORD_32U_operator_xnor_psp_sva_1;
  wire [15:0] while_for_b_sva_2;
  wire [16:0] nl_while_for_b_sva_2;
  wire ping_pong_lpi_2_mx0c1;
  wire [25:0] while_for_for_rem_31_6_sva_4;
  wire [26:0] nl_while_for_for_rem_31_6_sva_4;
  wire [4:0] while_for_for_len_qr_5_1_lpi_3_dfm_mx0w0;
  wire [6:0] while_for_for_for_i_7_1_sva_2;
  wire [7:0] nl_while_for_for_for_i_7_1_sva_2;
  wire [31:0] while_for_for_for_for_while_for_for_for_for_mux1h_ctmp_1;
  reg [31:0] conf3_Pop_mio_mrgout_dat_sva_31_0;
  reg reg_while_store_offset_mul_1_cmp_a_ftd;
  reg [30:0] reg_while_store_offset_mul_1_cmp_a_ftd_1;
  reg reg_while_store_offset_mul_1_cmp_b_ftd;
  reg [30:0] reg_while_store_offset_mul_1_cmp_b_ftd_1;
  wire while_for_for_len_and_cse;
  wire while_for_for_rem_or_cse;
  wire while_and_cse;
  wire while_for_for_len_acc_itm_32_1;

  wire pidx_C_ctrl_prb;
  wire pidx_C_prb;
  wire pidx_D1_prb;
  wire pidx_D1_ctrl_prb;
  wire pidx_C_ctrl_prb_1;
  wire pidx_C_prb_1;
  wire pidx_D1_prb_1;
  wire pidx_D1_ctrl_prb_1;
  wire[30:0] while_store_offset_acc_nl;
  wire[31:0] nl_while_store_offset_acc_nl;
  wire[31:0] while_store_offset_acc_1_nl;
  wire[32:0] nl_while_store_offset_acc_1_nl;
  wire[32:0] while_for_acc_2_nl;
  wire[33:0] nl_while_for_acc_2_nl;
  wire[30:0] while_for_for_acc_3_nl;
  wire[31:0] nl_while_for_for_acc_3_nl;
  wire and_152_nl;
  wire[32:0] while_for_for_for_acc_3_nl;
  wire[33:0] nl_while_for_for_for_acc_3_nl;
  wire[25:0] while_for_for_len_qif_mux_nl;
  wire[6:0] while_for_for_for_acc_1_nl;
  wire[7:0] nl_while_for_for_for_acc_1_nl;
  wire[32:0] while_for_acc_3_nl;
  wire[33:0] nl_while_for_acc_3_nl;
  wire[32:0] while_for_for_acc_4_nl;
  wire[33:0] nl_while_for_for_acc_4_nl;
  wire[32:0] while_for_for_acc_nl;
  wire[33:0] nl_while_for_for_acc_nl;
  wire while_for_for_len_not_6_nl;
  wire[32:0] while_for_for_len_acc_nl;
  wire[33:0] nl_while_for_for_len_acc_nl;
  wire[32:0] while_for_for_for_acc_4_nl;
  wire[33:0] nl_while_for_for_for_acc_4_nl;

  // Interconnect Declarations for Component Instantiations 
  wire  nl_Ctrl_store_store_sync23_sync_in_mioi_inst_store_wten;
  assign nl_Ctrl_store_store_sync23_sync_in_mioi_inst_store_wten = ~ store_wen;
  wire  nl_Ctrl_store_store_sync23_sync_in_mioi_inst_sync23_sync_in_mioi_oswt_pff;
  assign nl_Ctrl_store_store_sync23_sync_in_mioi_inst_sync23_sync_in_mioi_oswt_pff
      = fsm_output[7];
  wire [72:0] nl_Ctrl_store_store_dma_write_ctrl_Push_mioi_inst_dma_write_ctrl_Push_mioi_idat;
  assign nl_Ctrl_store_store_dma_write_ctrl_Push_mioi_inst_dma_write_ctrl_Push_mioi_idat
      = {10'b0000000100 , dma_write_ctrl_Push_mioi_idat_62_37 , dma_write_ctrl_Push_mioi_idat_36_32
      , 1'b0 , dma_write_ctrl_Push_mioi_idat_30_0};
  wire [63:0] nl_Ctrl_store_store_dma_write_chnl_Push_mioi_inst_dma_write_chnl_Push_mioi_idat;
  assign nl_Ctrl_store_store_dma_write_chnl_Push_mioi_inst_dma_write_chnl_Push_mioi_idat
      = {dma_write_chnl_Push_mioi_idat_63_32 , dma_write_chnl_Push_mioi_idat_31_0};
  esp_acc_DUMMY_Ctrl_store_store_sync03_Pop_mioi Ctrl_store_store_sync03_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync03_val(sync03_val),
      .sync03_rdy(sync03_rdy),
      .sync03_msg(sync03_msg),
      .store_wen(store_wen),
      .sync03_Pop_mioi_oswt(reg_sync03_Pop_mioi_oswt_cse),
      .sync03_Pop_mioi_wen_comp(sync03_Pop_mioi_wen_comp),
      .sync03_Pop_mioi_ivld(sync03_Pop_mioi_ivld),
      .sync03_Pop_mioi_ivld_oreg(sync03_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_Ctrl_store_store_wait_dp Ctrl_store_store_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .while_store_offset_mul_1_cmp_z(while_store_offset_mul_1_cmp_z),
      .store_wen(store_wen),
      .sync03_Pop_mioi_ivld(sync03_Pop_mioi_ivld),
      .sync03_Pop_mioi_ivld_oreg(sync03_Pop_mioi_ivld_oreg),
      .conf3_Pop_mioi_ivld(conf3_Pop_mioi_ivld),
      .conf3_Pop_mioi_ivld_oreg(conf3_Pop_mioi_ivld_oreg),
      .dma_write_ctrl_Push_mioi_irdy(dma_write_ctrl_Push_mioi_irdy),
      .dma_write_ctrl_Push_mioi_irdy_oreg(dma_write_ctrl_Push_mioi_irdy_oreg),
      .dma_write_chnl_Push_mioi_irdy(dma_write_chnl_Push_mioi_irdy),
      .dma_write_chnl_Push_mioi_irdy_oreg(dma_write_chnl_Push_mioi_irdy_oreg),
      .while_store_offset_mul_1_cmp_z_oreg(while_store_offset_mul_1_cmp_z_oreg)
    );
  esp_acc_DUMMY_Ctrl_store_store_conf3_Pop_mioi Ctrl_store_store_conf3_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf3_val(conf3_val),
      .conf3_rdy(conf3_rdy),
      .conf3_msg(conf3_msg),
      .store_wen(store_wen),
      .conf3_Pop_mioi_oswt(reg_sync03_Pop_mioi_oswt_cse),
      .conf3_Pop_mioi_wen_comp(conf3_Pop_mioi_wen_comp),
      .conf3_Pop_mioi_idat_mxwt(conf3_Pop_mioi_idat_mxwt),
      .conf3_Pop_mioi_ivld(conf3_Pop_mioi_ivld),
      .conf3_Pop_mioi_ivld_oreg(conf3_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_Ctrl_store_store_sync23_sync_in_mioi Ctrl_store_store_sync23_sync_in_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync23_vld(sync23_vld),
      .sync23_rdy(sync23_rdy),
      .store_wten(nl_Ctrl_store_store_sync23_sync_in_mioi_inst_store_wten),
      .sync23_sync_in_mioi_oswt(reg_sync23_sync_in_mioi_oswt_cse),
      .sync23_sync_in_mioi_wen_comp(sync23_sync_in_mioi_wen_comp),
      .sync23_sync_in_mioi_oswt_pff(nl_Ctrl_store_store_sync23_sync_in_mioi_inst_sync23_sync_in_mioi_oswt_pff)
    );
  esp_acc_DUMMY_Ctrl_store_store_dma_write_ctrl_Push_mioi Ctrl_store_store_dma_write_ctrl_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_val(dma_write_ctrl_val),
      .dma_write_ctrl_rdy(dma_write_ctrl_rdy),
      .dma_write_ctrl_msg(dma_write_ctrl_msg),
      .dma_write_ctrl_Push_mioi_oswt(reg_dma_write_ctrl_Push_mioi_oswt_cse),
      .dma_write_ctrl_Push_mioi_wen_comp(dma_write_ctrl_Push_mioi_wen_comp),
      .dma_write_ctrl_Push_mioi_idat(nl_Ctrl_store_store_dma_write_ctrl_Push_mioi_inst_dma_write_ctrl_Push_mioi_idat[72:0]),
      .dma_write_ctrl_Push_mioi_irdy(dma_write_ctrl_Push_mioi_irdy),
      .dma_write_ctrl_Push_mioi_irdy_oreg(dma_write_ctrl_Push_mioi_irdy_oreg)
    );
  esp_acc_DUMMY_Ctrl_store_store_dma_write_chnl_Push_mioi Ctrl_store_store_dma_write_chnl_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_chnl_val(dma_write_chnl_val),
      .dma_write_chnl_rdy(dma_write_chnl_rdy),
      .dma_write_chnl_msg(dma_write_chnl_msg),
      .dma_write_chnl_Push_mioi_oswt(reg_dma_write_chnl_Push_mioi_oswt_cse),
      .dma_write_chnl_Push_mioi_wen_comp(dma_write_chnl_Push_mioi_wen_comp),
      .dma_write_chnl_Push_mioi_idat(nl_Ctrl_store_store_dma_write_chnl_Push_mioi_inst_dma_write_chnl_Push_mioi_idat[63:0]),
      .dma_write_chnl_Push_mioi_irdy(dma_write_chnl_Push_mioi_irdy),
      .dma_write_chnl_Push_mioi_irdy_oreg(dma_write_chnl_Push_mioi_irdy_oreg)
    );
  esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1 Ctrl_store_store_plm_out_ping_a0_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_ping_a0_a_d_data_rsci_qout_d(plm_out_ping_a0_a_d_data_rsci_qout_d),
      .plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg),
      .store_wen(store_wen),
      .store_wten(store_wten),
      .plm_out_ping_a0_a_d_data_rsci_oswt(reg_plm_out_ping_a0_a_d_data_rsci_oswt_cse),
      .plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt(plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt),
      .plm_out_ping_a0_a_d_data_rsci_oswt_pff(and_75_rmff)
    );
  esp_acc_DUMMY_Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1 Ctrl_store_store_plm_out_ping_a1_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_ping_a1_a_d_data_rsci_qout_d(plm_out_ping_a1_a_d_data_rsci_qout_d),
      .plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg),
      .store_wen(store_wen),
      .store_wten(store_wten),
      .plm_out_ping_a1_a_d_data_rsci_oswt(reg_plm_out_ping_a1_a_d_data_rsci_oswt_cse),
      .plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt(plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt),
      .plm_out_ping_a1_a_d_data_rsci_oswt_pff(and_77_rmff)
    );
  esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1 Ctrl_store_store_plm_out_pong_a0_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_pong_a0_a_d_data_rsci_qout_d(plm_out_pong_a0_a_d_data_rsci_qout_d),
      .plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg),
      .store_wen(store_wen),
      .store_wten(store_wten),
      .plm_out_pong_a0_a_d_data_rsci_oswt(reg_plm_out_pong_a0_a_d_data_rsci_oswt_cse),
      .plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt(plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt),
      .plm_out_pong_a0_a_d_data_rsci_oswt_pff(and_79_rmff)
    );
  esp_acc_DUMMY_Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1 Ctrl_store_store_plm_out_pong_a1_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_pong_a1_a_d_data_rsci_qout_d(plm_out_pong_a1_a_d_data_rsci_qout_d),
      .plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg),
      .store_wen(store_wen),
      .store_wten(store_wten),
      .plm_out_pong_a1_a_d_data_rsci_oswt(reg_plm_out_pong_a1_a_d_data_rsci_oswt_cse),
      .plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt(plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt),
      .plm_out_pong_a1_a_d_data_rsci_oswt_pff(and_81_rmff)
    );
  esp_acc_DUMMY_Ctrl_store_store_staller Ctrl_store_store_staller_inst (
      .clk(clk),
      .rst(rst),
      .store_wen(store_wen),
      .store_wten(store_wten),
      .sync03_Pop_mioi_wen_comp(sync03_Pop_mioi_wen_comp),
      .conf3_Pop_mioi_wen_comp(conf3_Pop_mioi_wen_comp),
      .sync23_sync_in_mioi_wen_comp(sync23_sync_in_mioi_wen_comp),
      .dma_write_ctrl_Push_mioi_wen_comp(dma_write_ctrl_Push_mioi_wen_comp),
      .dma_write_chnl_Push_mioi_wen_comp(dma_write_chnl_Push_mioi_wen_comp)
    );
  esp_acc_DUMMY_Ctrl_store_store_store_fsm Ctrl_store_store_store_fsm_inst (
      .clk(clk),
      .rst(rst),
      .store_wen(store_wen),
      .fsm_output(fsm_output),
      .while_C_4_tr0(exit_while_for_sva_mx0),
      .while_for_C_0_tr0(exit_while_for_for_sva_mx0),
      .while_for_for_C_2_tr0(exit_while_for_for_for_sva_mx0),
      .while_for_for_for_for_C_0_tr0(while_for_for_for_for_k_1_sva),
      .while_for_for_for_C_0_tr0(exit_while_for_for_for_sva_mx0),
      .while_for_for_C_3_tr0(exit_while_for_for_sva_mx0),
      .while_for_C_1_tr0(exit_while_for_sva_mx0)
    );
  assign plm_out_ping_operator_mux_cse = MUX1HOT_s_1_1_2(store_wen, or_17_cse);
  assign pidx_C_ctrl_prb = plm_out_ping_operator_mux_cse;
  assign or_17_cse = (~ while_for_for_for_for_k_1_sva) & ping_pong_lpi_2 & (fsm_output[10]);
  assign pidx_C_prb = MUX1HOT_s_1_1_2(~ while_for_for_for_for_k_1_sva, or_17_cse);
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl default clock = (posedge clk);
  // psl Ctrl_store_ac_shared_bank_array_h_ln85_assert_idx_lt_C_2 : assert always ( rst &&  pidx_C_ctrl_prb  -> pidx_C_prb );
  assign pidx_D1_prb = MUX1HOT_s_1_1_2(ac_array_1D_FPDATA_WORD_32U_operator_ac_array_1D_FPDATA_WORD_32U_operator_xnor_psp_sva_1,
      or_17_cse);
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl Ctrl_store_ac_array_1D_h_ln58_assert_idx_lt_D1 : assert always ( rst &&  pidx_D1_ctrl_prb  -> pidx_D1_prb );
  assign pidx_D1_ctrl_prb = plm_out_ping_operator_mux_cse;
  assign plm_out_pong_operator_mux_cse = MUX1HOT_s_1_1_2(store_wen, or_20_cse);
  assign pidx_C_ctrl_prb_1 = plm_out_pong_operator_mux_cse;
  assign or_20_cse = nor_3_cse & (fsm_output[10]);
  assign pidx_C_prb_1 = MUX1HOT_s_1_1_2(~ while_for_for_for_for_k_1_sva, or_20_cse);
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl Ctrl_store_ac_shared_bank_array_h_ln85_assert_idx_lt_C_3 : assert always ( rst &&  pidx_C_ctrl_prb_1  -> pidx_C_prb_1 );
  assign pidx_D1_prb_1 = MUX1HOT_s_1_1_2(ac_array_1D_FPDATA_WORD_32U_operator_ac_array_1D_FPDATA_WORD_32U_operator_xnor_psp_sva_1,
      or_20_cse);
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl Ctrl_store_ac_array_1D_h_ln58_assert_idx_lt_D1_1 : assert always ( rst &&  pidx_D1_ctrl_prb_1  -> pidx_D1_prb_1 );
  assign pidx_D1_ctrl_prb_1 = plm_out_pong_operator_mux_cse;
  assign and_75_rmff = and_dcpl_10 & (~ while_for_for_for_for_k_0_sva) & (fsm_output[10]);
  assign and_77_rmff = and_dcpl_10 & while_for_for_for_for_k_0_sva & (fsm_output[10]);
  assign and_79_rmff = nor_3_cse & (~ while_for_for_for_for_k_0_sva) & (fsm_output[10]);
  assign and_81_rmff = nor_3_cse & while_for_for_for_for_k_0_sva & (fsm_output[10]);
  assign while_store_offset_mul_1_cmp_a = {reg_while_store_offset_mul_1_cmp_a_ftd
      , reg_while_store_offset_mul_1_cmp_a_ftd_1};
  assign while_store_offset_mul_1_cmp_b = {reg_while_store_offset_mul_1_cmp_b_ftd
      , reg_while_store_offset_mul_1_cmp_b_ftd_1};
  assign while_for_for_and_cse = store_wen & (fsm_output[8]);
  assign while_for_for_for_and_cse = store_wen & (fsm_output[10]) & while_for_for_for_for_k_1_sva;
  assign while_and_cse = store_wen & (~((~((fsm_output[1]) | (fsm_output[15]))) &
      and_dcpl_9));
  assign while_for_for_rem_or_cse = (fsm_output[6]) | (fsm_output[13]);
  assign while_for_for_len_and_cse = store_wen & (fsm_output[7]);
  assign while_for_for_for_i_and_cse = store_wen & ((fsm_output[12]) | (fsm_output[9]));
  assign ac_array_1D_FPDATA_WORD_32U_operator_ac_array_1D_FPDATA_WORD_32U_operator_xnor_psp_sva_1
      = ~((while_for_for_out_idx_6_0_sva[5]) ^ (while_for_for_out_idx_6_0_sva[6]));
  assign nl_while_for_acc_3_nl = ({17'b10000000000000000 , while_for_b_sva_2}) +
      conv_u2u_32_33(~ conf3_Pop_mio_mrgout_dat_sva_31_0) + 33'b000000000000000000000000000000001;
  assign while_for_acc_3_nl = nl_while_for_acc_3_nl[32:0];
  assign exit_while_for_sva_mx0 = MUX_s_1_2_2((~ while_for_slc_32_1_itm), (~ (readslicef_33_1_32(while_for_acc_3_nl))),
      fsm_output[14]);
  assign nl_while_for_b_sva_2 = while_for_b_sva + 16'b0000000000000001;
  assign while_for_b_sva_2 = nl_while_for_b_sva_2[15:0];
  assign nl_while_for_for_acc_4_nl = conv_s2u_32_33({(~ while_length_acc_psp_sva)
      , 1'b1}) + 33'b000000000000000000000000000000001;
  assign while_for_for_acc_4_nl = nl_while_for_for_acc_4_nl[32:0];
  assign nl_while_for_for_acc_nl = conv_s2u_32_33({(~ while_for_for_rem_31_6_sva_4)
      , (~ (while_length_acc_psp_sva[4:0])) , 1'b1}) + 33'b000000000000000000000000000000001;
  assign while_for_for_acc_nl = nl_while_for_for_acc_nl[32:0];
  assign exit_while_for_for_sva_mx0 = MUX_s_1_2_2((~ (readslicef_33_1_32(while_for_for_acc_4_nl))),
      (~ (readslicef_33_1_32(while_for_for_acc_nl))), fsm_output[13]);
  assign nl_while_for_for_rem_31_6_sva_4 = while_for_for_rem_31_6_sva + 26'b11111111111111111111111111;
  assign while_for_for_rem_31_6_sva_4 = nl_while_for_for_rem_31_6_sva_4[25:0];
  assign while_for_for_len_not_6_nl = ~ while_for_for_len_acc_itm_32_1;
  assign while_for_for_len_qr_5_1_lpi_3_dfm_mx0w0 = MUX_v_5_2_2(5'b00000, (while_length_acc_psp_sva[4:0]),
      while_for_for_len_not_6_nl);
  assign nl_while_for_for_len_acc_nl = conv_s2u_32_33({(~ while_for_for_rem_31_6_sva)
      , (~ (while_length_acc_psp_sva[4:0])) , 1'b1}) + 33'b000000000000000000000000001000001;
  assign while_for_for_len_acc_nl = nl_while_for_for_len_acc_nl[32:0];
  assign while_for_for_len_acc_itm_32_1 = readslicef_33_1_32(while_for_for_len_acc_nl);
  assign nl_while_for_for_for_acc_4_nl = ({25'b1000000000000000000000000 , while_for_for_for_i_7_1_sva_2
      , 1'b0}) + conv_u2u_32_33({(~ while_for_for_len_qr_31_6_lpi_3_dfm) , (~ while_for_for_len_qr_5_1_lpi_3_dfm)
      , 1'b1}) + 33'b000000000000000000000000000000001;
  assign while_for_for_for_acc_4_nl = nl_while_for_for_for_acc_4_nl[32:0];
  assign exit_while_for_for_for_sva_mx0 = MUX_s_1_2_2((~ while_for_for_for_slc_32_1_itm),
      (~ (readslicef_33_1_32(while_for_for_for_acc_4_nl))), fsm_output[12]);
  assign nl_while_for_for_for_i_7_1_sva_2 = while_for_for_for_i_7_1_sva + 7'b0000001;
  assign while_for_for_for_i_7_1_sva_2 = nl_while_for_for_for_i_7_1_sva_2[6:0];
  assign while_for_for_for_for_while_for_for_for_for_mux1h_ctmp_1 = MUX_v_32_4_2(plm_out_pong_a0_a_d_data_rsci_qout_d_mxwt,
      plm_out_pong_a1_a_d_data_rsci_qout_d_mxwt, plm_out_ping_a0_a_d_data_rsci_qout_d_mxwt,
      plm_out_ping_a1_a_d_data_rsci_qout_d_mxwt, {ping_pong_lpi_2 , while_for_for_for_for_k_0_sva});
  assign nor_3_cse = ~(while_for_for_for_for_k_1_sva | ping_pong_lpi_2);
  assign and_dcpl_9 = ~((fsm_output[16]) | (fsm_output[0]));
  assign and_dcpl_10 = (~ while_for_for_for_for_k_1_sva) & ping_pong_lpi_2;
  assign ping_pong_lpi_2_mx0c1 = exit_while_for_for_sva_mx0 & while_for_for_rem_or_cse;
  assign plm_out_ping_a0_a_d_data_rsci_r_adr_d_pff = while_for_for_out_idx_6_0_sva[4:0];
  assign plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      acc_done <= 1'b0;
    end
    else if ( store_wen & ((fsm_output[16:15]!=2'b00)) ) begin
      acc_done <= ~ (fsm_output[16]);
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      reg_sync03_Pop_mioi_oswt_cse <= 1'b0;
      reg_sync23_sync_in_mioi_oswt_cse <= 1'b0;
      reg_dma_write_ctrl_Push_mioi_oswt_cse <= 1'b0;
      reg_dma_write_chnl_Push_mioi_oswt_cse <= 1'b0;
      reg_plm_out_ping_a0_a_d_data_rsci_oswt_cse <= 1'b0;
      reg_plm_out_ping_a1_a_d_data_rsci_oswt_cse <= 1'b0;
      reg_plm_out_pong_a0_a_d_data_rsci_oswt_cse <= 1'b0;
      reg_plm_out_pong_a1_a_d_data_rsci_oswt_cse <= 1'b0;
      while_for_for_for_for_k_1_sva <= 1'b0;
    end
    else if ( store_wen ) begin
      reg_sync03_Pop_mioi_oswt_cse <= ~ and_dcpl_9;
      reg_sync23_sync_in_mioi_oswt_cse <= fsm_output[7];
      reg_dma_write_ctrl_Push_mioi_oswt_cse <= fsm_output[8];
      reg_dma_write_chnl_Push_mioi_oswt_cse <= while_for_for_for_for_k_1_sva & (fsm_output[10]);
      reg_plm_out_ping_a0_a_d_data_rsci_oswt_cse <= and_75_rmff;
      reg_plm_out_ping_a1_a_d_data_rsci_oswt_cse <= and_77_rmff;
      reg_plm_out_pong_a0_a_d_data_rsci_oswt_cse <= and_79_rmff;
      reg_plm_out_pong_a1_a_d_data_rsci_oswt_cse <= and_81_rmff;
      while_for_for_for_for_k_1_sva <= while_for_for_for_for_k_0_sva & (fsm_output[11]);
    end
  end
  always @(posedge clk) begin
    if ( store_wen ) begin
      reg_while_store_offset_mul_1_cmp_a_ftd <= (conf3_Pop_mioi_idat_mxwt[63]) &
          (~ (fsm_output[3]));
      reg_while_store_offset_mul_1_cmp_a_ftd_1 <= MUX_v_31_2_2((conf3_Pop_mioi_idat_mxwt[62:32]),
          (conf3_Pop_mio_mrgout_dat_sva_31_0[30:0]), fsm_output[3]);
      reg_while_store_offset_mul_1_cmp_b_ftd <= (conf3_Pop_mioi_idat_mxwt[95]) &
          (~ (fsm_output[3]));
      reg_while_store_offset_mul_1_cmp_b_ftd_1 <= MUX_v_31_2_2((conf3_Pop_mioi_idat_mxwt[94:64]),
          while_store_offset_acc_nl, fsm_output[3]);
      while_for_for_for_dataBv_sva_1_63_32_1 <= while_for_for_for_for_while_for_for_for_for_mux1h_ctmp_1;
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_and_cse ) begin
      dma_write_ctrl_Push_mioi_idat_36_32 <= while_for_for_len_qr_5_1_lpi_3_dfm;
      dma_write_ctrl_Push_mioi_idat_62_37 <= while_for_for_len_qr_31_6_lpi_3_dfm;
      dma_write_ctrl_Push_mioi_idat_30_0 <= while_offset_31_1_lpi_3;
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_for_and_cse ) begin
      dma_write_chnl_Push_mioi_idat_31_0 <= while_for_for_for_dataBv_sva_1_31_0_1;
      dma_write_chnl_Push_mioi_idat_63_32 <= while_for_for_for_dataBv_sva_1_63_32_1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      ping_pong_sva <= 1'b0;
    end
    else if ( store_wen & (fsm_output[16]) ) begin
      ping_pong_sva <= ping_pong_lpi_2;
    end
  end
  always @(posedge clk) begin
    if ( while_and_cse ) begin
      conf3_Pop_mio_mrgout_dat_sva_31_0 <= conf3_Pop_mioi_idat_mxwt[31:0];
      while_length_acc_psp_sva <= nl_while_length_acc_psp_sva[30:0];
    end
  end
  always @(posedge clk) begin
    if ( store_wen & (fsm_output[1]) ) begin
      while_for_slc_32_1_itm <= readslicef_33_1_32(while_for_acc_2_nl);
    end
  end
  always @(posedge clk) begin
    if ( store_wen & ((fsm_output[14]) | (fsm_output[5])) ) begin
      while_for_b_sva <= MUX_v_16_2_2(16'b0000000000000000, while_for_b_sva_2, (fsm_output[14]));
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      ping_pong_lpi_2 <= 1'b0;
    end
    else if ( store_wen & ((fsm_output[5]) | ping_pong_lpi_2_mx0c1) ) begin
      ping_pong_lpi_2 <= MUX_s_1_2_2(ping_pong_sva, (~ ping_pong_lpi_2), ping_pong_lpi_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( store_wen & (~((fsm_output[8]) | (fsm_output[12]) | (fsm_output[7]) | (fsm_output[6])
        | (fsm_output[10]) | (fsm_output[9]) | (fsm_output[11]) | (fsm_output[14])))
        ) begin
      while_offset_31_1_lpi_3 <= MUX_v_31_2_2((while_store_offset_mul_1_cmp_z_oreg[30:0]),
          while_for_for_acc_3_nl, fsm_output[13]);
    end
  end
  always @(posedge clk) begin
    if ( store_wen & while_for_for_rem_or_cse ) begin
      while_for_for_rem_31_6_sva <= MUX_v_26_2_2((while_length_acc_psp_sva[30:5]),
          while_for_for_rem_31_6_sva_4, fsm_output[13]);
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_len_and_cse ) begin
      while_for_for_len_qr_31_6_lpi_3_dfm <= MUX_v_26_2_2(26'b00000000000000000000000001,
          while_for_for_rem_31_6_sva, and_152_nl);
      while_for_for_len_qr_5_1_lpi_3_dfm <= while_for_for_len_qr_5_1_lpi_3_dfm_mx0w0;
      while_for_for_for_slc_32_1_itm <= readslicef_33_1_32(while_for_for_for_acc_3_nl);
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_for_i_and_cse ) begin
      while_for_for_for_i_7_1_sva <= MUX_v_7_2_2(7'b0000000, while_for_for_for_i_7_1_sva_2,
          (fsm_output[12]));
      while_for_for_out_idx_6_0_sva <= MUX_v_7_2_2(7'b0000000, while_for_for_for_acc_1_nl,
          (fsm_output[12]));
    end
  end
  always @(posedge clk) begin
    if ( store_wen & (~ while_for_for_for_for_k_0_sva) & (fsm_output[11]) ) begin
      while_for_for_for_dataBv_sva_1_31_0_1 <= while_for_for_for_for_while_for_for_for_for_mux1h_ctmp_1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_for_k_0_sva <= 1'b0;
    end
    else if ( store_wen & (~ (fsm_output[10])) ) begin
      while_for_for_for_for_k_0_sva <= (~ while_for_for_for_for_k_0_sva) & (fsm_output[11]);
    end
  end
  assign nl_while_store_offset_acc_1_nl = while_store_offset_mul_1_cmp_z_oreg + 32'b11111111111111111111111111111111;
  assign while_store_offset_acc_1_nl = nl_while_store_offset_acc_1_nl[31:0];
  assign nl_while_store_offset_acc_nl = (readslicef_32_31_1(while_store_offset_acc_1_nl))
      + 31'b0000000000000000000000000000001;
  assign while_store_offset_acc_nl = nl_while_store_offset_acc_nl[30:0];
  assign nl_while_length_acc_psp_sva  = conv_u2u_1_31(conf3_Pop_mioi_idat_mxwt[32])
      + (conf3_Pop_mioi_idat_mxwt[63:33]);
  assign nl_while_for_acc_2_nl = ({1'b1 , (~ (conf3_Pop_mioi_idat_mxwt[31:0]))})
      + 33'b000000000000000000000000000000001;
  assign while_for_acc_2_nl = nl_while_for_acc_2_nl[32:0];
  assign nl_while_for_for_acc_3_nl = while_offset_31_1_lpi_3 + ({while_for_for_len_qr_31_6_lpi_3_dfm
      , while_for_for_len_qr_5_1_lpi_3_dfm});
  assign while_for_for_acc_3_nl = nl_while_for_for_acc_3_nl[30:0];
  assign and_152_nl = (~ while_for_for_len_acc_itm_32_1) & (fsm_output[7]);
  assign while_for_for_len_qif_mux_nl = MUX_v_26_2_2(while_for_for_rem_31_6_sva,
      26'b00000000000000000000000001, while_for_for_len_acc_itm_32_1);
  assign nl_while_for_for_for_acc_3_nl = ({1'b1 , (~ while_for_for_len_qif_mux_nl)
      , (~ while_for_for_len_qr_5_1_lpi_3_dfm_mx0w0) , 1'b1}) + 33'b000000000000000000000000000000001;
  assign while_for_for_for_acc_3_nl = nl_while_for_for_for_acc_3_nl[32:0];
  assign nl_while_for_for_for_acc_1_nl = while_for_for_out_idx_6_0_sva + 7'b0000001;
  assign while_for_for_for_acc_1_nl = nl_while_for_for_for_acc_1_nl[6:0];

  function automatic  MUX1HOT_s_1_1_2;
    input  input_0;
    input  sel;
    reg  result;
  begin
    result = input_0 & sel;
    MUX1HOT_s_1_1_2 = result;
  end
  endfunction


  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input  sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction


  function automatic [25:0] MUX_v_26_2_2;
    input [25:0] input_0;
    input [25:0] input_1;
    input  sel;
    reg [25:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_26_2_2 = result;
  end
  endfunction


  function automatic [30:0] MUX_v_31_2_2;
    input [30:0] input_0;
    input [30:0] input_1;
    input  sel;
    reg [30:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_31_2_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_4_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [31:0] input_2;
    input [31:0] input_3;
    input [1:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      2'b00 : begin
        result = input_0;
      end
      2'b01 : begin
        result = input_1;
      end
      2'b10 : begin
        result = input_2;
      end
      default : begin
        result = input_3;
      end
    endcase
    MUX_v_32_4_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input  sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function automatic [6:0] MUX_v_7_2_2;
    input [6:0] input_0;
    input [6:0] input_1;
    input  sel;
    reg [6:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_7_2_2 = result;
  end
  endfunction


  function automatic [30:0] readslicef_32_31_1;
    input [31:0] vector;
    reg [31:0] tmp;
  begin
    tmp = vector >> 1;
    readslicef_32_31_1 = tmp[30:0];
  end
  endfunction


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [32:0] conv_s2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_s2u_32_33 = {vector[31], vector};
  end
  endfunction


  function automatic [30:0] conv_u2u_1_31 ;
    input  vector ;
  begin
    conv_u2u_1_31 = {{30{1'b0}}, vector};
  end
  endfunction


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute_compute
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute_compute (
  clk, rst, in_wr_req_val, in_wr_req_rdy, in_wr_req_msg, in_rd_rsp_val, in_rd_rsp_rdy,
      in_rd_rsp_msg, sync12_vld, sync12_rdy, sync23_vld, sync23_rdy, sync02_val,
      sync02_rdy, sync02_msg, conf2_val, conf2_rdy, conf2_msg, plm_in_ping_a0_a_d_data_rsci_qout_d,
      plm_in_ping_a0_a_d_data_rsci_r_adr_d, plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      plm_in_ping_a1_a_d_data_rsci_qout_d, plm_in_ping_a1_a_d_data_rsci_r_adr_d,
      plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d, plm_in_pong_a0_a_d_data_rsci_qout_d,
      plm_in_pong_a0_a_d_data_rsci_r_adr_d, plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d,
      plm_in_pong_a1_a_d_data_rsci_qout_d, plm_in_pong_a1_a_d_data_rsci_r_adr_d,
      plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d, plm_out_ping_a0_a_d_data_rsci_din_d,
      plm_out_ping_a0_a_d_data_rsci_w_adr_d, plm_out_ping_a1_a_d_data_rsci_din_d,
      plm_out_ping_a1_a_d_data_rsci_w_adr_d, plm_out_pong_a0_a_d_data_rsci_din_d,
      plm_out_pong_a0_a_d_data_rsci_w_adr_d, plm_out_pong_a1_a_d_data_rsci_din_d,
      plm_out_pong_a1_a_d_data_rsci_w_adr_d, while_for_in_length_mul_cmp_a, while_for_in_length_mul_cmp_b,
      while_for_in_length_mul_cmp_z, plm_out_ping_a0_a_d_data_rsci_w_en_d_pff, plm_out_ping_a1_a_d_data_rsci_w_en_d_pff,
      plm_out_pong_a0_a_d_data_rsci_w_en_d_pff, plm_out_pong_a1_a_d_data_rsci_w_en_d_pff
);
  input clk;
  input rst;
  input in_wr_req_val;
  output in_wr_req_rdy;
  input [31:0] in_wr_req_msg;
  output in_rd_rsp_val;
  input in_rd_rsp_rdy;
  output [63:0] in_rd_rsp_msg;
  input sync12_vld;
  output sync12_rdy;
  output sync23_vld;
  input sync23_rdy;
  input sync02_val;
  output sync02_rdy;
  input sync02_msg;
  input conf2_val;
  output conf2_rdy;
  input [95:0] conf2_msg;
  input [31:0] plm_in_ping_a0_a_d_data_rsci_qout_d;
  output [8:0] plm_in_ping_a0_a_d_data_rsci_r_adr_d;
  output plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input [31:0] plm_in_ping_a1_a_d_data_rsci_qout_d;
  output [8:0] plm_in_ping_a1_a_d_data_rsci_r_adr_d;
  output plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input [31:0] plm_in_pong_a0_a_d_data_rsci_qout_d;
  output [8:0] plm_in_pong_a0_a_d_data_rsci_r_adr_d;
  output plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  input [31:0] plm_in_pong_a1_a_d_data_rsci_qout_d;
  output [8:0] plm_in_pong_a1_a_d_data_rsci_r_adr_d;
  output plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  output [31:0] plm_out_ping_a0_a_d_data_rsci_din_d;
  output [4:0] plm_out_ping_a0_a_d_data_rsci_w_adr_d;
  output [31:0] plm_out_ping_a1_a_d_data_rsci_din_d;
  output [4:0] plm_out_ping_a1_a_d_data_rsci_w_adr_d;
  output [31:0] plm_out_pong_a0_a_d_data_rsci_din_d;
  output [4:0] plm_out_pong_a0_a_d_data_rsci_w_adr_d;
  output [31:0] plm_out_pong_a1_a_d_data_rsci_din_d;
  output [4:0] plm_out_pong_a1_a_d_data_rsci_w_adr_d;
  output [31:0] while_for_in_length_mul_cmp_a;
  reg [31:0] while_for_in_length_mul_cmp_a;
  output [31:0] while_for_in_length_mul_cmp_b;
  reg [31:0] while_for_in_length_mul_cmp_b;
  input [31:0] while_for_in_length_mul_cmp_z;
  output plm_out_ping_a0_a_d_data_rsci_w_en_d_pff;
  output plm_out_ping_a1_a_d_data_rsci_w_en_d_pff;
  output plm_out_pong_a0_a_d_data_rsci_w_en_d_pff;
  output plm_out_pong_a1_a_d_data_rsci_w_en_d_pff;


  // Interconnect Declarations
  wire compute_wen;
  wire compute_wten;
  wire sync02_Pop_mioi_iden;
  wire sync02_Pop_mioi_wen_comp;
  wire sync02_Pop_mioi_ivld;
  wire sync02_Pop_mioi_ivld_oreg;
  wire conf2_Pop_mioi_iden;
  wire conf2_Pop_mioi_wen_comp;
  wire [95:0] conf2_Pop_mioi_idat_mxwt;
  wire conf2_Pop_mioi_ivld;
  wire conf2_Pop_mioi_ivld_oreg;
  wire sync12_sync_in_mioi_wen_comp;
  wire in_rd_rsp_Push_mioi_bawt;
  wire in_rd_rsp_Push_mioi_iden;
  reg in_rd_rsp_Push_mioi_iswt0;
  wire in_rd_rsp_Push_mioi_wen_comp;
  wire in_rd_rsp_Push_mioi_irdy;
  wire in_rd_rsp_Push_mioi_irdy_oreg;
  wire in_wr_req_Pop_mioi_bawt;
  wire in_wr_req_Pop_mioi_iden;
  reg in_wr_req_Pop_mioi_iswt0;
  wire in_wr_req_Pop_mioi_wen_comp;
  wire [31:0] in_wr_req_Pop_mioi_idat_mxwt;
  wire in_wr_req_Pop_mioi_ivld;
  wire in_wr_req_Pop_mioi_ivld_oreg;
  wire sync23_sync_out_mioi_wen_comp;
  wire plm_in_ping_a0_a_d_data_rsci_bawt;
  wire plm_in_ping_a0_a_d_data_rsci_iden;
  wire [31:0] plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt;
  wire plm_in_ping_a1_a_d_data_rsci_bawt;
  wire plm_in_ping_a1_a_d_data_rsci_iden;
  wire [31:0] plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt;
  wire plm_in_pong_a0_a_d_data_rsci_bawt;
  wire plm_in_pong_a0_a_d_data_rsci_iden;
  wire [31:0] plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt;
  wire plm_in_pong_a1_a_d_data_rsci_bawt;
  wire plm_in_pong_a1_a_d_data_rsci_iden;
  wire [31:0] plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt;
  wire plm_out_ping_a0_a_d_data_rsci_bawt;
  wire plm_out_ping_a0_a_d_data_rsci_iden;
  reg plm_out_ping_a0_a_d_data_rsci_iswt0;
  wire plm_out_ping_a1_a_d_data_rsci_bawt;
  wire plm_out_ping_a1_a_d_data_rsci_iden;
  reg plm_out_ping_a1_a_d_data_rsci_iswt0;
  wire plm_out_pong_a0_a_d_data_rsci_bawt;
  wire plm_out_pong_a0_a_d_data_rsci_iden;
  reg plm_out_pong_a0_a_d_data_rsci_iswt0;
  wire plm_out_pong_a1_a_d_data_rsci_bawt;
  wire plm_out_pong_a1_a_d_data_rsci_iden;
  reg plm_out_pong_a1_a_d_data_rsci_iswt0;
  wire [31:0] while_for_in_length_mul_cmp_z_oreg;
  reg compute_flen;
  reg [31:0] in_rd_rsp_Push_mioi_idat_63_32;
  reg [31:0] in_rd_rsp_Push_mioi_idat_31_0;
  wire [10:0] fsm_output;
  wire while_for_for_for_and_7_tmp;
  wire while_for_for_for_if_1_unequal_tmp;
  wire and_dcpl_1;
  wire and_dcpl_2;
  wire or_dcpl_4;
  wire and_dcpl_11;
  wire and_dcpl_14;
  wire and_dcpl_32;
  wire and_dcpl_46;
  wire mux_tmp_33;
  wire and_dcpl_52;
  wire or_dcpl_42;
  wire and_dcpl_66;
  wire and_dcpl_67;
  wire and_dcpl_70;
  wire and_dcpl_80;
  wire and_dcpl_89;
  wire or_dcpl_63;
  wire and_dcpl_99;
  wire and_dcpl_102;
  wire and_dcpl_106;
  wire or_dcpl_65;
  wire or_dcpl_69;
  wire or_dcpl_81;
  wire or_dcpl_82;
  wire or_dcpl_84;
  wire and_dcpl_128;
  wire and_dcpl_129;
  wire or_dcpl_91;
  wire or_dcpl_94;
  wire or_dcpl_100;
  wire or_dcpl_110;
  wire or_dcpl_111;
  wire and_dcpl_133;
  wire or_dcpl_118;
  wire nand_tmp_15;
  wire or_tmp_177;
  wire or_tmp_180;
  wire or_tmp_205;
  wire or_tmp_210;
  wire or_tmp_212;
  wire or_tmp_214;
  wire or_tmp_216;
  wire or_tmp_222;
  wire or_tmp_232;
  wire or_tmp_307;
  wire and_300_cse;
  wire and_504_cse;
  wire and_456_cse;
  wire and_452_cse;
  reg exit_while_for_for_sva;
  wire exit_while_for_sva_mx0;
  reg out_ping_pong_sva;
  reg while_for_for_for_if_1_asn_itm_1;
  reg while_for_for_for_while_for_for_for_if_1_nor_svs_st_1;
  reg while_for_for_for_if_1_if_asn_itm_1;
  reg while_for_for_for_if_1_else_asn_itm_1;
  reg exit_while_for_for_for_sva_st_1;
  reg [95:0] conf2_Pop_mio_mrgout_dat_sva;
  reg while_for_for_for_stage_v;
  reg while_for_for_for_stage_v_1;
  reg while_for_for_for_stage_0_1;
  reg while_for_for_for_stage_v_2;
  reg while_for_for_for_stage_0_2;
  reg ping_pong_lpi_3;
  reg out_ping_pong_lpi_2;
  reg while_for_for_for_stage_0;
  reg exit_while_for_for_for_sva;
  reg while_for_for_for_while_for_for_for_if_1_nor_svs;
  reg while_for_for_for_while_for_for_for_if_1_nor_svs_st;
  reg while_for_for_vec_idx_0_sva;
  reg while_for_for_for_if_1_asn_itm;
  reg while_for_for_for_if_1_else_asn_itm;
  reg while_for_for_for_if_1_if_asn_itm;
  reg while_for_for_for_asn_itm;
  reg [24:0] while_for_for_in_rem_31_7_sva;
  reg [6:0] while_for_in_length_sva_6_0;
  wire plm_in_ping_operator_mux_1_cse;
  wire plm_in_ping_operator_mux_cse;
  wire ac_array_1D_FPDATA_WORD_320U_operator_mux_1_cse;
  wire plm_in_pong_operator_mux_1_cse;
  wire plm_in_pong_operator_mux_cse;
  wire or_203_cse;
  wire or_205_cse;
  wire or_214_cse;
  wire or_216_cse;
  reg reg_sync02_Pop_mioi_oswt_cse;
  reg reg_sync12_sync_in_mioi_oswt_cse;
  reg reg_sync23_sync_out_mioi_oswt_cse;
  reg reg_plm_in_ping_a0_a_d_data_rsci_iswt0_cse;
  reg reg_plm_in_pong_a0_a_d_data_rsci_iswt0_cse;
  wire while_for_for_for_and_9_cse;
  wire while_for_for_for_if_1_and_1_cse;
  wire while_for_for_for_if_1_if_and_1_cse;
  wire while_for_for_for_and_13_cse;
  wire while_for_for_in_len_and_cse;
  reg reg_while_for_for_for_asn_5_cse;
  wire while_for_for_vec_idx_and_cse;
  wire while_for_for_for_if_1_and_5_cse;
  wire nor_107_cse;
  wire or_198_cse;
  wire or_201_cse;
  wire or_2_cse;
  wire nor_63_cse;
  wire nor_62_cse;
  wire ac_array_1D_FPDATA_WORD_320U_operator_2_mux_1_cse;
  wire while_for_for_for_i_while_for_for_for_i_nor_cse;
  wire and_61_cse;
  wire or_3_cse;
  reg [8:0] plm_in_ping_a0_a_d_data_rsci_r_adr_d_reg;
  wire [8:0] plm_in_ping_a1_a_d_data_mux_rmff;
  wire plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_315_rmff;
  reg [8:0] plm_in_ping_a1_a_d_data_rsci_r_adr_d_reg;
  wire [8:0] plm_in_ping_a1_a_d_data_mux_1_rmff;
  wire plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  reg [8:0] plm_in_pong_a0_a_d_data_rsci_r_adr_d_reg;
  wire [8:0] plm_in_ping_a1_a_d_data_mux_2_rmff;
  wire plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_319_rmff;
  reg [8:0] plm_in_pong_a1_a_d_data_rsci_r_adr_d_reg;
  wire [8:0] plm_in_ping_a1_a_d_data_mux_3_rmff;
  wire plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  reg [31:0] plm_out_ping_a0_a_d_data_rsci_din_d_reg;
  wire [31:0] while_for_for_for_if_1_acc_mux_rmff;
  reg [4:0] plm_out_ping_a0_a_d_data_rsci_w_adr_d_reg;
  wire [4:0] ac_array_1D_FPDATA_WORD_32U_operator_mux_rmff;
  wire plm_out_ping_a0_a_d_data_rsci_w_en_d_iff;
  wire and_323_rmff;
  reg [31:0] plm_out_ping_a1_a_d_data_rsci_din_d_reg;
  wire [31:0] while_for_for_for_if_1_acc_mux_1_rmff;
  reg [4:0] plm_out_ping_a1_a_d_data_rsci_w_adr_d_reg;
  wire [4:0] ac_array_1D_FPDATA_WORD_32U_operator_mux_1_rmff;
  wire plm_out_ping_a1_a_d_data_rsci_w_en_d_iff;
  wire and_327_rmff;
  reg [31:0] plm_out_pong_a0_a_d_data_rsci_din_d_reg;
  wire [31:0] while_for_for_for_if_1_acc_mux_2_rmff;
  reg [4:0] plm_out_pong_a0_a_d_data_rsci_w_adr_d_reg;
  wire [4:0] ac_array_1D_FPDATA_WORD_32U_operator_1_mux_rmff;
  wire plm_out_pong_a0_a_d_data_rsci_w_en_d_iff;
  wire and_331_rmff;
  reg [31:0] plm_out_pong_a1_a_d_data_rsci_din_d_reg;
  wire [31:0] while_for_for_for_if_1_acc_mux_3_rmff;
  reg [4:0] plm_out_pong_a1_a_d_data_rsci_w_adr_d_reg;
  wire [4:0] ac_array_1D_FPDATA_WORD_32U_operator_1_mux_1_rmff;
  wire plm_out_pong_a1_a_d_data_rsci_w_en_d_iff;
  wire and_335_rmff;
  wire and_312_rmff;
  wire and_316_rmff;
  wire and_606_rmff;
  reg [9:0] while_for_for_for_i_10_1_sva;
  reg ping_pong_sva;
  reg [15:0] while_for_b_sva;
  reg while_for_for_in_len_slc_32_svs;
  reg [6:0] while_for_for_in_len_qr_6_0_lpi_3_dfm;
  reg [30:0] while_for_for_vec_indx_31_1_sva;
  reg [31:0] while_for_for_vec_num_sva;
  reg [30:0] while_for_for_vec_indx_31_1_sva_1;
  reg while_for_for_for_stage_en_2;
  reg while_for_for_for_stage_en_4;
  reg while_for_for_for_mux_6_itm;
  reg [4:0] ac_array_1D_FPDATA_WORD_32U_operator_slc_ac_array_1D_FPDATA_WORD_32U_operator_idx_4_0_2_itm_1;
  wire while_for_for_for_stage_en_5;
  wire while_for_for_for_stage_en_4_mx1w0;
  wire out_ping_pong_sva_mx1;
  wire [15:0] while_for_b_sva_2;
  wire [16:0] nl_while_for_b_sva_2;
  wire [24:0] while_for_for_in_rem_31_7_sva_3;
  wire [25:0] nl_while_for_for_in_rem_31_7_sva_3;
  wire while_for_for_for_stage_0_mx0c1;
  wire while_for_for_for_stage_v_1_mx0c1;
  wire while_for_for_for_stage_v_2_mx0c0;
  wire while_for_for_for_mux_6_itm_mx1c1;
  wire [30:0] while_for_for_vec_indx_31_1_sva_2;
  wire [31:0] nl_while_for_for_vec_indx_31_1_sva_2;
  wire while_for_for_for_nand_16_cse_1;
  wire [63:0] conf2_Pop_mio_mrgout_dat_sva_mx0_95_32;
  wire ac_array_1D_FPDATA_WORD_320U_operator_acc_itm_3_1;
  wire while_for_for_in_len_acc_itm_32_1;
  wire while_for_for_for_acc_3_itm_32_1;
  wire ac_array_1D_FPDATA_WORD_32U_operator_acc_itm_27_1;
  wire while_for_for_acc_2_itm_32_1;

  wire pidx_C_prb;
  wire pidx_C_ctrl_prb;
  wire pidx_D1_ctrl_prb;
  wire pidx_D1_prb;
  wire pidx_C_prb_1;
  wire pidx_C_ctrl_prb_1;
  wire pidx_D1_ctrl_prb_1;
  wire pidx_D1_prb_1;
  wire pidx_C_prb_2;
  wire pidx_C_ctrl_prb_2;
  wire pidx_D1_ctrl_prb_2;
  wire pidx_D1_prb_2;
  wire pidx_C_prb_3;
  wire pidx_C_ctrl_prb_3;
  wire pidx_D1_ctrl_prb_3;
  wire pidx_D1_prb_3;
  wire pidx_C_prb_4;
  wire pidx_C_ctrl_prb_4;
  wire pidx_C_prb_5;
  wire pidx_C_ctrl_prb_5;
  wire pidx_D1_ctrl_prb_4;
  wire pidx_D1_prb_4;
  wire pidx_D1_ctrl_prb_5;
  wire pidx_D1_prb_5;
  wire mux1h_nl;
  wire nor_nl;
  wire while_for_for_for_for_dataBv_int_mux_3_nl;
  wire while_for_for_for_mux_2_nl;
  wire while_for_for_for_mux_4_nl;
  wire nor_1_nl;
  wire or_312_nl;
  wire out_ping_pong_mux1h_3_nl;
  wire or_390_nl;
  wire or_405_nl;
  wire[32:0] while_for_for_acc_nl;
  wire[33:0] nl_while_for_for_acc_nl;
  wire while_for_for_in_len_not_4_nl;
  wire[9:0] while_for_for_for_acc_2_nl;
  wire[10:0] nl_while_for_for_for_acc_2_nl;
  wire while_for_for_for_i_not_1_nl;
  wire while_for_for_for_mux_16_nl;
  wire while_for_for_for_for_dataBv_int_while_for_for_for_nor_nl;
  wire mux_105_nl;
  wire or_477_nl;
  wire nand_42_nl;
  wire[31:0] while_for_for_for_if_1_qif_acc_nl;
  wire[32:0] nl_while_for_for_for_if_1_qif_acc_nl;
  wire while_for_for_vec_num_not_1_nl;
  wire[3:0] ac_array_1D_FPDATA_WORD_320U_operator_acc_nl;
  wire[4:0] nl_ac_array_1D_FPDATA_WORD_320U_operator_acc_nl;
  wire[32:0] while_for_acc_2_nl;
  wire[33:0] nl_while_for_acc_2_nl;
  wire[32:0] while_for_acc_3_nl;
  wire[33:0] nl_while_for_acc_3_nl;
  wire[32:0] while_for_for_in_len_acc_nl;
  wire[33:0] nl_while_for_for_in_len_acc_nl;
  wire[32:0] while_for_for_for_acc_3_nl;
  wire[33:0] nl_while_for_for_for_acc_3_nl;
  wire[24:0] while_for_for_in_len_mux_2_nl;
  wire[27:0] ac_array_1D_FPDATA_WORD_32U_operator_acc_nl;
  wire[28:0] nl_ac_array_1D_FPDATA_WORD_32U_operator_acc_nl;
  wire mux_32_nl;
  wire mux_31_nl;
  wire[32:0] while_for_for_acc_2_nl;
  wire[33:0] nl_while_for_for_acc_2_nl;

  // Interconnect Declarations for Component Instantiations 
  wire  nl_Ctrl_compute_compute_sync12_sync_in_mioi_inst_compute_wten;
  assign nl_Ctrl_compute_compute_sync12_sync_in_mioi_inst_compute_wten = ~ compute_wen;
  wire  nl_Ctrl_compute_compute_sync12_sync_in_mioi_inst_sync12_sync_in_mioi_oswt_pff;
  assign nl_Ctrl_compute_compute_sync12_sync_in_mioi_inst_sync12_sync_in_mioi_oswt_pff
      = fsm_output[4];
  wire [63:0] nl_Ctrl_compute_compute_in_rd_rsp_Push_mioi_inst_in_rd_rsp_Push_mioi_idat;
  assign nl_Ctrl_compute_compute_in_rd_rsp_Push_mioi_inst_in_rd_rsp_Push_mioi_idat
      = {in_rd_rsp_Push_mioi_idat_63_32 , in_rd_rsp_Push_mioi_idat_31_0};
  wire  nl_Ctrl_compute_compute_sync23_sync_out_mioi_inst_compute_wten;
  assign nl_Ctrl_compute_compute_sync23_sync_out_mioi_inst_compute_wten = ~ compute_wen;
  wire  nl_Ctrl_compute_compute_sync23_sync_out_mioi_inst_sync23_sync_out_mioi_oswt_pff;
  assign nl_Ctrl_compute_compute_sync23_sync_out_mioi_inst_sync23_sync_out_mioi_oswt_pff
      = fsm_output[8];
  wire  nl_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_inst_plm_out_ping_a0_a_d_data_rsci_oswt_unreg;
  assign nl_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_inst_plm_out_ping_a0_a_d_data_rsci_oswt_unreg
      = and_dcpl_99 & plm_out_ping_a0_a_d_data_rsci_bawt & (~ while_for_for_for_if_1_if_asn_itm_1)
      & while_for_for_for_if_1_asn_itm_1 & (fsm_output[7]);
  wire  nl_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_inst_plm_out_ping_a1_a_d_data_rsci_oswt_unreg;
  assign nl_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_inst_plm_out_ping_a1_a_d_data_rsci_oswt_unreg
      = and_dcpl_99 & plm_out_ping_a1_a_d_data_rsci_bawt & while_for_for_for_if_1_if_asn_itm_1
      & while_for_for_for_if_1_asn_itm_1 & (fsm_output[7]);
  wire  nl_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_inst_plm_out_pong_a0_a_d_data_rsci_oswt_unreg;
  assign nl_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_inst_plm_out_pong_a0_a_d_data_rsci_oswt_unreg
      = and_dcpl_99 & plm_out_pong_a0_a_d_data_rsci_bawt & (~ while_for_for_for_if_1_else_asn_itm_1)
      & (~ while_for_for_for_if_1_asn_itm_1) & (fsm_output[7]);
  wire  nl_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_inst_plm_out_pong_a1_a_d_data_rsci_oswt_unreg;
  assign nl_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_inst_plm_out_pong_a1_a_d_data_rsci_oswt_unreg
      = and_dcpl_99 & plm_out_pong_a1_a_d_data_rsci_bawt & while_for_for_for_if_1_else_asn_itm_1
      & (~ while_for_for_for_if_1_asn_itm_1) & (fsm_output[7]);
  wire  nl_Ctrl_compute_compute_compute_fsm_inst_while_for_C_1_tr0;
  assign nl_Ctrl_compute_compute_compute_fsm_inst_while_for_C_1_tr0 = ~ while_for_for_acc_2_itm_32_1;
  esp_acc_DUMMY_Ctrl_compute_compute_sync02_Pop_mioi Ctrl_compute_compute_sync02_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync02_val(sync02_val),
      .sync02_rdy(sync02_rdy),
      .sync02_msg(sync02_msg),
      .compute_wen(compute_wen),
      .sync02_Pop_mioi_oswt(reg_sync02_Pop_mioi_oswt_cse),
      .sync02_Pop_mioi_iden(sync02_Pop_mioi_iden),
      .sync02_Pop_mioi_wen_comp(sync02_Pop_mioi_wen_comp),
      .sync02_Pop_mioi_ivld(sync02_Pop_mioi_ivld),
      .sync02_Pop_mioi_ivld_oreg(sync02_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_wait_dp Ctrl_compute_compute_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .while_for_in_length_mul_cmp_z(while_for_in_length_mul_cmp_z),
      .compute_wen(compute_wen),
      .sync02_Pop_mioi_ivld(sync02_Pop_mioi_ivld),
      .sync02_Pop_mioi_ivld_oreg(sync02_Pop_mioi_ivld_oreg),
      .conf2_Pop_mioi_ivld(conf2_Pop_mioi_ivld),
      .conf2_Pop_mioi_ivld_oreg(conf2_Pop_mioi_ivld_oreg),
      .in_rd_rsp_Push_mioi_irdy(in_rd_rsp_Push_mioi_irdy),
      .in_rd_rsp_Push_mioi_irdy_oreg(in_rd_rsp_Push_mioi_irdy_oreg),
      .in_wr_req_Pop_mioi_ivld(in_wr_req_Pop_mioi_ivld),
      .in_wr_req_Pop_mioi_ivld_oreg(in_wr_req_Pop_mioi_ivld_oreg),
      .while_for_in_length_mul_cmp_z_oreg(while_for_in_length_mul_cmp_z_oreg)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_conf2_Pop_mioi Ctrl_compute_compute_conf2_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf2_val(conf2_val),
      .conf2_rdy(conf2_rdy),
      .conf2_msg(conf2_msg),
      .compute_wen(compute_wen),
      .conf2_Pop_mioi_oswt(reg_sync02_Pop_mioi_oswt_cse),
      .conf2_Pop_mioi_iden(conf2_Pop_mioi_iden),
      .conf2_Pop_mioi_wen_comp(conf2_Pop_mioi_wen_comp),
      .conf2_Pop_mioi_idat_mxwt(conf2_Pop_mioi_idat_mxwt),
      .conf2_Pop_mioi_ivld(conf2_Pop_mioi_ivld),
      .conf2_Pop_mioi_ivld_oreg(conf2_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_sync12_sync_in_mioi Ctrl_compute_compute_sync12_sync_in_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync12_vld(sync12_vld),
      .sync12_rdy(sync12_rdy),
      .compute_wten(nl_Ctrl_compute_compute_sync12_sync_in_mioi_inst_compute_wten),
      .sync12_sync_in_mioi_oswt(reg_sync12_sync_in_mioi_oswt_cse),
      .sync12_sync_in_mioi_wen_comp(sync12_sync_in_mioi_wen_comp),
      .sync12_sync_in_mioi_oswt_pff(nl_Ctrl_compute_compute_sync12_sync_in_mioi_inst_sync12_sync_in_mioi_oswt_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_in_rd_rsp_Push_mioi Ctrl_compute_compute_in_rd_rsp_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .in_rd_rsp_val(in_rd_rsp_val),
      .in_rd_rsp_rdy(in_rd_rsp_rdy),
      .in_rd_rsp_msg(in_rd_rsp_msg),
      .compute_wen(compute_wen),
      .in_rd_rsp_Push_mioi_oswt_unreg(or_tmp_177),
      .in_rd_rsp_Push_mioi_bawt(in_rd_rsp_Push_mioi_bawt),
      .in_rd_rsp_Push_mioi_iden(in_rd_rsp_Push_mioi_iden),
      .in_rd_rsp_Push_mioi_iswt0(in_rd_rsp_Push_mioi_iswt0),
      .in_rd_rsp_Push_mioi_wen_comp(in_rd_rsp_Push_mioi_wen_comp),
      .in_rd_rsp_Push_mioi_idat(nl_Ctrl_compute_compute_in_rd_rsp_Push_mioi_inst_in_rd_rsp_Push_mioi_idat[63:0]),
      .in_rd_rsp_Push_mioi_irdy(in_rd_rsp_Push_mioi_irdy),
      .in_rd_rsp_Push_mioi_irdy_oreg(in_rd_rsp_Push_mioi_irdy_oreg)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_in_wr_req_Pop_mioi Ctrl_compute_compute_in_wr_req_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .in_wr_req_val(in_wr_req_val),
      .in_wr_req_rdy(in_wr_req_rdy),
      .in_wr_req_msg(in_wr_req_msg),
      .compute_wen(compute_wen),
      .in_wr_req_Pop_mioi_oswt_unreg(or_tmp_180),
      .in_wr_req_Pop_mioi_bawt(in_wr_req_Pop_mioi_bawt),
      .in_wr_req_Pop_mioi_iden(in_wr_req_Pop_mioi_iden),
      .in_wr_req_Pop_mioi_iswt0(in_wr_req_Pop_mioi_iswt0),
      .in_wr_req_Pop_mioi_wen_comp(in_wr_req_Pop_mioi_wen_comp),
      .in_wr_req_Pop_mioi_idat_mxwt(in_wr_req_Pop_mioi_idat_mxwt),
      .in_wr_req_Pop_mioi_ivld(in_wr_req_Pop_mioi_ivld),
      .in_wr_req_Pop_mioi_ivld_oreg(in_wr_req_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_sync23_sync_out_mioi Ctrl_compute_compute_sync23_sync_out_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync23_vld(sync23_vld),
      .sync23_rdy(sync23_rdy),
      .compute_wten(nl_Ctrl_compute_compute_sync23_sync_out_mioi_inst_compute_wten),
      .sync23_sync_out_mioi_oswt(reg_sync23_sync_out_mioi_oswt_cse),
      .sync23_sync_out_mioi_wen_comp(sync23_sync_out_mioi_wen_comp),
      .sync23_sync_out_mioi_oswt_pff(nl_Ctrl_compute_compute_sync23_sync_out_mioi_inst_sync23_sync_out_mioi_oswt_pff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1 Ctrl_compute_compute_plm_in_ping_a0_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_ping_a0_a_d_data_rsci_qout_d(plm_in_ping_a0_a_d_data_rsci_qout_d),
      .plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_in_ping_a0_a_d_data_rsci_oswt_unreg(and_312_rmff),
      .plm_in_ping_a0_a_d_data_rsci_bawt(plm_in_ping_a0_a_d_data_rsci_bawt),
      .plm_in_ping_a0_a_d_data_rsci_iden(plm_in_ping_a0_a_d_data_rsci_iden),
      .plm_in_ping_a0_a_d_data_rsci_iswt0(reg_plm_in_ping_a0_a_d_data_rsci_iswt0_cse),
      .plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt(plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt),
      .plm_in_ping_a0_a_d_data_rsci_iswt0_pff(and_315_rmff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1 Ctrl_compute_compute_plm_in_ping_a1_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_ping_a1_a_d_data_rsci_qout_d(plm_in_ping_a1_a_d_data_rsci_qout_d),
      .plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_in_ping_a1_a_d_data_rsci_oswt_unreg(and_312_rmff),
      .plm_in_ping_a1_a_d_data_rsci_bawt(plm_in_ping_a1_a_d_data_rsci_bawt),
      .plm_in_ping_a1_a_d_data_rsci_iden(plm_in_ping_a1_a_d_data_rsci_iden),
      .plm_in_ping_a1_a_d_data_rsci_iswt0(reg_plm_in_ping_a0_a_d_data_rsci_iswt0_cse),
      .plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt(plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt),
      .plm_in_ping_a1_a_d_data_rsci_iswt0_pff(and_315_rmff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1 Ctrl_compute_compute_plm_in_pong_a0_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_pong_a0_a_d_data_rsci_qout_d(plm_in_pong_a0_a_d_data_rsci_qout_d),
      .plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_in_pong_a0_a_d_data_rsci_oswt_unreg(and_316_rmff),
      .plm_in_pong_a0_a_d_data_rsci_bawt(plm_in_pong_a0_a_d_data_rsci_bawt),
      .plm_in_pong_a0_a_d_data_rsci_iden(plm_in_pong_a0_a_d_data_rsci_iden),
      .plm_in_pong_a0_a_d_data_rsci_iswt0(reg_plm_in_pong_a0_a_d_data_rsci_iswt0_cse),
      .plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt(plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt),
      .plm_in_pong_a0_a_d_data_rsci_iswt0_pff(and_319_rmff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1 Ctrl_compute_compute_plm_in_pong_a1_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_pong_a1_a_d_data_rsci_qout_d(plm_in_pong_a1_a_d_data_rsci_qout_d),
      .plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_in_pong_a1_a_d_data_rsci_oswt_unreg(and_316_rmff),
      .plm_in_pong_a1_a_d_data_rsci_bawt(plm_in_pong_a1_a_d_data_rsci_bawt),
      .plm_in_pong_a1_a_d_data_rsci_iden(plm_in_pong_a1_a_d_data_rsci_iden),
      .plm_in_pong_a1_a_d_data_rsci_iswt0(reg_plm_in_pong_a0_a_d_data_rsci_iswt0_cse),
      .plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt(plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt),
      .plm_in_pong_a1_a_d_data_rsci_iswt0_pff(and_319_rmff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1 Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_out_ping_a0_a_d_data_rsci_oswt_unreg(nl_Ctrl_compute_compute_plm_out_ping_a0_a_d_data_rsci_1_inst_plm_out_ping_a0_a_d_data_rsci_oswt_unreg),
      .plm_out_ping_a0_a_d_data_rsci_bawt(plm_out_ping_a0_a_d_data_rsci_bawt),
      .plm_out_ping_a0_a_d_data_rsci_iden(plm_out_ping_a0_a_d_data_rsci_iden),
      .plm_out_ping_a0_a_d_data_rsci_iswt0(plm_out_ping_a0_a_d_data_rsci_iswt0),
      .plm_out_ping_a0_a_d_data_rsci_w_en_d_pff(plm_out_ping_a0_a_d_data_rsci_w_en_d_iff),
      .plm_out_ping_a0_a_d_data_rsci_iswt0_pff(and_323_rmff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1 Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_out_ping_a1_a_d_data_rsci_oswt_unreg(nl_Ctrl_compute_compute_plm_out_ping_a1_a_d_data_rsci_1_inst_plm_out_ping_a1_a_d_data_rsci_oswt_unreg),
      .plm_out_ping_a1_a_d_data_rsci_bawt(plm_out_ping_a1_a_d_data_rsci_bawt),
      .plm_out_ping_a1_a_d_data_rsci_iden(plm_out_ping_a1_a_d_data_rsci_iden),
      .plm_out_ping_a1_a_d_data_rsci_iswt0(plm_out_ping_a1_a_d_data_rsci_iswt0),
      .plm_out_ping_a1_a_d_data_rsci_w_en_d_pff(plm_out_ping_a1_a_d_data_rsci_w_en_d_iff),
      .plm_out_ping_a1_a_d_data_rsci_iswt0_pff(and_327_rmff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1 Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_out_pong_a0_a_d_data_rsci_oswt_unreg(nl_Ctrl_compute_compute_plm_out_pong_a0_a_d_data_rsci_1_inst_plm_out_pong_a0_a_d_data_rsci_oswt_unreg),
      .plm_out_pong_a0_a_d_data_rsci_bawt(plm_out_pong_a0_a_d_data_rsci_bawt),
      .plm_out_pong_a0_a_d_data_rsci_iden(plm_out_pong_a0_a_d_data_rsci_iden),
      .plm_out_pong_a0_a_d_data_rsci_iswt0(plm_out_pong_a0_a_d_data_rsci_iswt0),
      .plm_out_pong_a0_a_d_data_rsci_w_en_d_pff(plm_out_pong_a0_a_d_data_rsci_w_en_d_iff),
      .plm_out_pong_a0_a_d_data_rsci_iswt0_pff(and_331_rmff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1 Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .plm_out_pong_a1_a_d_data_rsci_oswt_unreg(nl_Ctrl_compute_compute_plm_out_pong_a1_a_d_data_rsci_1_inst_plm_out_pong_a1_a_d_data_rsci_oswt_unreg),
      .plm_out_pong_a1_a_d_data_rsci_bawt(plm_out_pong_a1_a_d_data_rsci_bawt),
      .plm_out_pong_a1_a_d_data_rsci_iden(plm_out_pong_a1_a_d_data_rsci_iden),
      .plm_out_pong_a1_a_d_data_rsci_iswt0(plm_out_pong_a1_a_d_data_rsci_iswt0),
      .plm_out_pong_a1_a_d_data_rsci_w_en_d_pff(plm_out_pong_a1_a_d_data_rsci_w_en_d_iff),
      .plm_out_pong_a1_a_d_data_rsci_iswt0_pff(and_335_rmff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_staller Ctrl_compute_compute_staller_inst (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .sync02_Pop_mioi_iden(sync02_Pop_mioi_iden),
      .sync02_Pop_mioi_wen_comp(sync02_Pop_mioi_wen_comp),
      .conf2_Pop_mioi_iden(conf2_Pop_mioi_iden),
      .conf2_Pop_mioi_wen_comp(conf2_Pop_mioi_wen_comp),
      .sync12_sync_in_mioi_wen_comp(sync12_sync_in_mioi_wen_comp),
      .in_rd_rsp_Push_mioi_iden(in_rd_rsp_Push_mioi_iden),
      .in_rd_rsp_Push_mioi_wen_comp(in_rd_rsp_Push_mioi_wen_comp),
      .in_wr_req_Pop_mioi_iden(in_wr_req_Pop_mioi_iden),
      .in_wr_req_Pop_mioi_wen_comp(in_wr_req_Pop_mioi_wen_comp),
      .sync23_sync_out_mioi_wen_comp(sync23_sync_out_mioi_wen_comp),
      .plm_in_ping_a0_a_d_data_rsci_iden(plm_in_ping_a0_a_d_data_rsci_iden),
      .plm_in_ping_a1_a_d_data_rsci_iden(plm_in_ping_a1_a_d_data_rsci_iden),
      .plm_in_pong_a0_a_d_data_rsci_iden(plm_in_pong_a0_a_d_data_rsci_iden),
      .plm_in_pong_a1_a_d_data_rsci_iden(plm_in_pong_a1_a_d_data_rsci_iden),
      .plm_out_ping_a0_a_d_data_rsci_iden(plm_out_ping_a0_a_d_data_rsci_iden),
      .plm_out_ping_a1_a_d_data_rsci_iden(plm_out_ping_a1_a_d_data_rsci_iden),
      .plm_out_pong_a0_a_d_data_rsci_iden(plm_out_pong_a0_a_d_data_rsci_iden),
      .plm_out_pong_a1_a_d_data_rsci_iden(plm_out_pong_a1_a_d_data_rsci_iden),
      .compute_flen_unreg(and_606_rmff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute_compute_fsm Ctrl_compute_compute_compute_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .fsm_output(fsm_output),
      .while_C_0_tr0(exit_while_for_sva_mx0),
      .while_for_C_1_tr0(nl_Ctrl_compute_compute_compute_fsm_inst_while_for_C_1_tr0),
      .while_for_for_for_C_1_tr0(and_dcpl_52),
      .while_for_for_C_3_tr0(exit_while_for_for_sva),
      .while_for_C_2_tr0(exit_while_for_sva_mx0)
    );
  assign plm_in_ping_operator_mux_cse = MUX1HOT_s_1_1_2(1'b1, or_198_cse);
  assign pidx_C_prb = plm_in_ping_operator_mux_cse;
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl default clock = (posedge clk);
  // psl Ctrl_compute_ac_shared_bank_array_h_ln85_assert_idx_lt_C : assert always ( rst &&  pidx_C_ctrl_prb  -> pidx_C_prb );
  assign plm_in_ping_operator_mux_1_cse = MUX1HOT_s_1_1_2(while_for_for_for_stage_en_5,
      or_198_cse);
  assign pidx_C_ctrl_prb = plm_in_ping_operator_mux_1_cse;
  assign pidx_D1_ctrl_prb = plm_in_ping_operator_mux_1_cse;
  assign ac_array_1D_FPDATA_WORD_320U_operator_mux_1_cse = MUX1HOT_s_1_1_2(ac_array_1D_FPDATA_WORD_320U_operator_acc_itm_3_1,
      or_198_cse);
  assign pidx_D1_prb = ac_array_1D_FPDATA_WORD_320U_operator_mux_1_cse;
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl Ctrl_compute_ac_array_1D_h_ln58_assert_idx_lt_D1_14 : assert always ( rst &&  pidx_D1_ctrl_prb  -> pidx_D1_prb );
  assign pidx_C_prb_1 = plm_in_ping_operator_mux_cse;
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl Ctrl_compute_ac_shared_bank_array_h_ln85_assert_idx_lt_C_1 : assert always ( rst &&  pidx_C_ctrl_prb_1  -> pidx_C_prb_1 );
  assign pidx_C_ctrl_prb_1 = plm_in_ping_operator_mux_1_cse;
  assign pidx_D1_ctrl_prb_1 = plm_in_ping_operator_mux_1_cse;
  assign pidx_D1_prb_1 = ac_array_1D_FPDATA_WORD_320U_operator_mux_1_cse;
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl Ctrl_compute_ac_array_1D_h_ln58_assert_idx_lt_D1_12 : assert always ( rst &&  pidx_D1_ctrl_prb_1  -> pidx_D1_prb_1 );
  assign plm_in_pong_operator_mux_cse = MUX1HOT_s_1_1_2(1'b1, or_201_cse);
  assign pidx_C_prb_2 = plm_in_pong_operator_mux_cse;
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl Ctrl_compute_ac_shared_bank_array_h_ln85_assert_idx_lt_C_2 : assert always ( rst &&  pidx_C_ctrl_prb_2  -> pidx_C_prb_2 );
  assign plm_in_pong_operator_mux_1_cse = MUX1HOT_s_1_1_2(while_for_for_for_stage_en_5,
      or_201_cse);
  assign pidx_C_ctrl_prb_2 = plm_in_pong_operator_mux_1_cse;
  assign pidx_D1_ctrl_prb_2 = plm_in_pong_operator_mux_1_cse;
  assign ac_array_1D_FPDATA_WORD_320U_operator_2_mux_1_cse = MUX1HOT_s_1_1_2(ac_array_1D_FPDATA_WORD_320U_operator_acc_itm_3_1,
      or_201_cse);
  assign pidx_D1_prb_2 = ac_array_1D_FPDATA_WORD_320U_operator_2_mux_1_cse;
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl Ctrl_compute_ac_array_1D_h_ln58_assert_idx_lt_D1_15 : assert always ( rst &&  pidx_D1_ctrl_prb_2  -> pidx_D1_prb_2 );
  assign pidx_C_prb_3 = plm_in_pong_operator_mux_cse;
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl Ctrl_compute_ac_shared_bank_array_h_ln85_assert_idx_lt_C_3 : assert always ( rst &&  pidx_C_ctrl_prb_3  -> pidx_C_prb_3 );
  assign pidx_C_ctrl_prb_3 = plm_in_pong_operator_mux_1_cse;
  assign pidx_D1_ctrl_prb_3 = plm_in_pong_operator_mux_1_cse;
  assign pidx_D1_prb_3 = ac_array_1D_FPDATA_WORD_320U_operator_2_mux_1_cse;
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl Ctrl_compute_ac_array_1D_h_ln58_assert_idx_lt_D1_13 : assert always ( rst &&  pidx_D1_ctrl_prb_3  -> pidx_D1_prb_3 );
  assign or_203_cse = or_dcpl_4 & and_dcpl_14 & and_dcpl_11 & out_ping_pong_lpi_2
      & (fsm_output[6]);
  assign pidx_C_prb_4 = MUX1HOT_s_1_1_2(1'b1, or_203_cse);
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl Ctrl_compute_ac_shared_bank_array_h_ln85_assert_idx_lt_C_4 : assert always ( rst &&  pidx_C_ctrl_prb_4  -> pidx_C_prb_4 );
  assign pidx_C_ctrl_prb_4 = MUX1HOT_s_1_1_2(while_for_for_for_stage_en_5, or_203_cse);
  assign or_205_cse = or_dcpl_4 & and_dcpl_14 & and_dcpl_11 & (~ out_ping_pong_lpi_2)
      & (fsm_output[6]);
  assign pidx_C_prb_5 = MUX1HOT_s_1_1_2(1'b1, or_205_cse);
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl Ctrl_compute_ac_shared_bank_array_h_ln85_assert_idx_lt_C_5 : assert always ( rst &&  pidx_C_ctrl_prb_5  -> pidx_C_prb_5 );
  assign pidx_C_ctrl_prb_5 = MUX1HOT_s_1_1_2(while_for_for_for_stage_en_5, or_205_cse);
  assign or_214_cse = and_dcpl_46 & while_for_for_for_and_7_tmp & while_for_for_for_if_1_asn_itm
      & (fsm_output[7]);
  assign pidx_D1_ctrl_prb_4 = MUX1HOT_s_1_1_2(while_for_for_for_and_7_tmp, or_214_cse);
  assign pidx_D1_prb_4 = MUX1HOT_s_1_1_2(ac_array_1D_FPDATA_WORD_32U_operator_acc_itm_27_1,
      or_214_cse);
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl Ctrl_compute_ac_array_1D_h_ln58_assert_idx_lt_D1_10 : assert always ( rst &&  pidx_D1_ctrl_prb_4  -> pidx_D1_prb_4 );
  assign or_216_cse = and_dcpl_46 & while_for_for_for_and_7_tmp & (~ while_for_for_for_if_1_asn_itm)
      & (fsm_output[7]);
  assign pidx_D1_ctrl_prb_5 = MUX1HOT_s_1_1_2(while_for_for_for_and_7_tmp, or_216_cse);
  assign pidx_D1_prb_5 = MUX1HOT_s_1_1_2(ac_array_1D_FPDATA_WORD_32U_operator_acc_itm_27_1,
      or_216_cse);
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl Ctrl_compute_ac_array_1D_h_ln58_assert_idx_lt_D1_11 : assert always ( rst &&  pidx_D1_ctrl_prb_5  -> pidx_D1_prb_5 );
  assign while_for_for_for_for_dataBv_int_mux_3_nl = MUX_s_1_2_2(while_for_for_for_stage_0,
      while_for_for_for_stage_0_1, or_tmp_307);
  assign while_for_for_for_mux_2_nl = MUX_s_1_2_2(while_for_for_for_stage_en_2, while_for_for_for_and_7_tmp,
      fsm_output[7]);
  assign while_for_for_for_mux_4_nl = MUX_s_1_2_2(while_for_for_for_stage_en_4, while_for_for_for_stage_en_4_mx1w0,
      fsm_output[7]);
  assign nor_nl = ~(((~((while_for_for_for_stage_v & (~ (fsm_output[5]))) | (while_for_for_for_stage_v_1
      & or_tmp_307) | (out_ping_pong_sva & or_dcpl_111 & (fsm_output[7])))) & (while_for_for_for_for_dataBv_int_mux_3_nl
      | (fsm_output[5]))) | while_for_for_for_mux_2_nl | while_for_for_for_mux_4_nl);
  assign nor_1_nl = ~(while_for_for_for_stage_en_5 | (while_for_for_for_stage_v_2
      & (~ out_ping_pong_sva) & while_for_for_for_stage_0_2 & (in_rd_rsp_Push_mioi_bawt
      | exit_while_for_for_for_sva_st_1) & (in_wr_req_Pop_mioi_bawt | (~(while_for_for_for_while_for_for_for_if_1_nor_svs_st_1
      & (~ exit_while_for_for_for_sva_st_1))))));
  assign or_312_nl = (or_dcpl_42 & (fsm_output[7])) | (fsm_output[5]);
  assign mux1h_nl = MUX1HOT_s_1_3_2(nor_nl, nor_1_nl, compute_flen, {or_312_nl ,
      (fsm_output[6]) , and_300_cse});
  assign and_606_rmff = mux1h_nl & (~(and_dcpl_52 & (fsm_output[7])));
  assign and_312_rmff = and_dcpl_70 & while_for_for_for_asn_itm & (fsm_output[7]);
  assign and_315_rmff = or_dcpl_63 & and_dcpl_2 & while_for_for_for_acc_3_itm_32_1
      & ping_pong_lpi_3 & (fsm_output[6]);
  assign and_316_rmff = and_dcpl_70 & (~ while_for_for_for_asn_itm) & (fsm_output[7]);
  assign and_319_rmff = or_dcpl_63 & and_dcpl_2 & while_for_for_for_acc_3_itm_32_1
      & (~ ping_pong_lpi_3) & (fsm_output[6]);
  assign and_323_rmff = and_dcpl_106 & and_dcpl_102 & (~ while_for_for_for_if_1_if_asn_itm_1)
      & while_for_for_for_if_1_asn_itm_1 & (fsm_output[6]);
  assign and_327_rmff = and_dcpl_106 & and_dcpl_102 & while_for_for_for_if_1_if_asn_itm_1
      & while_for_for_for_if_1_asn_itm_1 & (fsm_output[6]);
  assign and_331_rmff = and_dcpl_106 & and_dcpl_102 & (~(while_for_for_for_if_1_else_asn_itm_1
      | while_for_for_for_if_1_asn_itm_1)) & (fsm_output[6]);
  assign and_335_rmff = and_dcpl_106 & and_dcpl_102 & while_for_for_for_if_1_else_asn_itm_1
      & (~ while_for_for_for_if_1_asn_itm_1) & (fsm_output[6]);
  assign while_for_for_for_and_9_cse = compute_wen & ((and_dcpl_70 & ping_pong_lpi_3
      & (fsm_output[7])) | or_tmp_205);
  assign while_for_for_for_if_1_acc_mux_rmff = MUX_v_32_2_2(in_wr_req_Pop_mioi_idat_mxwt,
      plm_out_ping_a0_a_d_data_rsci_din_d_reg, or_tmp_210);
  assign ac_array_1D_FPDATA_WORD_32U_operator_mux_rmff = MUX_v_5_2_2(ac_array_1D_FPDATA_WORD_32U_operator_slc_ac_array_1D_FPDATA_WORD_32U_operator_idx_4_0_2_itm_1,
      plm_out_ping_a0_a_d_data_rsci_w_adr_d_reg, or_tmp_210);
  assign while_for_for_for_if_1_acc_mux_1_rmff = MUX_v_32_2_2(in_wr_req_Pop_mioi_idat_mxwt,
      plm_out_ping_a1_a_d_data_rsci_din_d_reg, or_tmp_212);
  assign ac_array_1D_FPDATA_WORD_32U_operator_mux_1_rmff = MUX_v_5_2_2(ac_array_1D_FPDATA_WORD_32U_operator_slc_ac_array_1D_FPDATA_WORD_32U_operator_idx_4_0_2_itm_1,
      plm_out_ping_a1_a_d_data_rsci_w_adr_d_reg, or_tmp_212);
  assign while_for_for_for_if_1_acc_mux_2_rmff = MUX_v_32_2_2(in_wr_req_Pop_mioi_idat_mxwt,
      plm_out_pong_a0_a_d_data_rsci_din_d_reg, or_tmp_214);
  assign ac_array_1D_FPDATA_WORD_32U_operator_1_mux_rmff = MUX_v_5_2_2(ac_array_1D_FPDATA_WORD_32U_operator_slc_ac_array_1D_FPDATA_WORD_32U_operator_idx_4_0_2_itm_1,
      plm_out_pong_a0_a_d_data_rsci_w_adr_d_reg, or_tmp_214);
  assign while_for_for_for_if_1_acc_mux_3_rmff = MUX_v_32_2_2(in_wr_req_Pop_mioi_idat_mxwt,
      plm_out_pong_a1_a_d_data_rsci_din_d_reg, or_tmp_216);
  assign ac_array_1D_FPDATA_WORD_32U_operator_1_mux_1_rmff = MUX_v_5_2_2(ac_array_1D_FPDATA_WORD_32U_operator_slc_ac_array_1D_FPDATA_WORD_32U_operator_idx_4_0_2_itm_1,
      plm_out_pong_a1_a_d_data_rsci_w_adr_d_reg, or_tmp_216);
  assign plm_in_ping_a1_a_d_data_mux_rmff = MUX_v_9_2_2((while_for_for_for_i_10_1_sva[8:0]),
      plm_in_ping_a0_a_d_data_rsci_r_adr_d_reg, or_tmp_222);
  assign plm_in_ping_a1_a_d_data_mux_1_rmff = MUX_v_9_2_2((while_for_for_for_i_10_1_sva[8:0]),
      plm_in_ping_a1_a_d_data_rsci_r_adr_d_reg, or_tmp_222);
  assign plm_in_ping_a1_a_d_data_mux_2_rmff = MUX_v_9_2_2((while_for_for_for_i_10_1_sva[8:0]),
      plm_in_pong_a0_a_d_data_rsci_r_adr_d_reg, or_tmp_232);
  assign plm_in_ping_a1_a_d_data_mux_3_rmff = MUX_v_9_2_2((while_for_for_for_i_10_1_sva[8:0]),
      plm_in_pong_a1_a_d_data_rsci_r_adr_d_reg, or_tmp_232);
  assign while_for_for_for_if_1_and_1_cse = compute_wen & (~((~ (fsm_output[6]))
      | and_dcpl_129 | or_dcpl_81 | (~(while_for_for_for_stage_0_1 & while_for_for_for_acc_3_itm_32_1))));
  assign while_for_for_for_if_1_if_and_1_cse = compute_wen & while_for_for_for_and_7_tmp
      & (fsm_output[7]);
  assign while_for_for_for_and_13_cse = compute_wen & (fsm_output[7]);
  assign while_for_for_in_len_and_cse = compute_wen & (fsm_output[7:5]==3'b000);
  assign while_for_for_for_i_while_for_for_for_i_nor_cse = ~(or_dcpl_118 | (fsm_output[7]));
  assign while_for_for_vec_idx_and_cse = compute_wen & ((~((~ while_for_for_for_and_7_tmp)
      | reg_while_for_for_for_asn_5_cse | exit_while_for_for_for_sva | (fsm_output[6])))
      | nor_63_cse);
  assign while_for_for_for_if_1_and_5_cse = compute_wen & while_for_for_for_i_while_for_for_for_i_nor_cse;
  assign nor_107_cse = ~((conf2_Pop_mio_mrgout_dat_sva[64]) | while_for_for_for_if_1_unequal_tmp);
  assign or_198_cse = or_dcpl_4 & and_dcpl_2 & while_for_for_for_acc_3_itm_32_1 &
      ping_pong_lpi_3 & (fsm_output[6]);
  assign while_for_for_for_stage_en_5 = while_for_for_for_stage_v & (~(while_for_for_for_stage_v_1
      | (while_for_for_for_stage_v_2 & or_dcpl_110))) & while_for_for_for_stage_0_1;
  assign nl_ac_array_1D_FPDATA_WORD_320U_operator_acc_nl = (while_for_for_for_i_10_1_sva[9:6])
      + 4'b1011;
  assign ac_array_1D_FPDATA_WORD_320U_operator_acc_nl = nl_ac_array_1D_FPDATA_WORD_320U_operator_acc_nl[3:0];
  assign ac_array_1D_FPDATA_WORD_320U_operator_acc_itm_3_1 = readslicef_4_1_3(ac_array_1D_FPDATA_WORD_320U_operator_acc_nl);
  assign or_201_cse = or_dcpl_4 & and_dcpl_2 & while_for_for_for_acc_3_itm_32_1 &
      (~ ping_pong_lpi_3) & (fsm_output[6]);
  assign while_for_for_for_if_1_unequal_tmp = while_for_for_vec_indx_31_1_sva_2 !=
      (conf2_Pop_mio_mrgout_dat_sva[95:65]);
  assign while_for_for_for_and_7_tmp = while_for_for_for_stage_v_1 & (~(while_for_for_for_stage_v_2
      | out_ping_pong_sva_mx1)) & while_for_for_for_stage_0_1 & (plm_in_ping_a0_a_d_data_rsci_bawt
      | while_for_for_for_nand_16_cse_1) & (plm_in_ping_a1_a_d_data_rsci_bawt | while_for_for_for_nand_16_cse_1)
      & (plm_in_pong_a0_a_d_data_rsci_bawt | while_for_for_for_asn_itm | reg_while_for_for_for_asn_5_cse)
      & (plm_in_pong_a1_a_d_data_rsci_bawt | while_for_for_for_asn_itm | reg_while_for_for_for_asn_5_cse);
  assign while_for_for_for_stage_en_4_mx1w0 = out_ping_pong_sva & (plm_out_ping_a0_a_d_data_rsci_bawt
      | (~((~ while_for_for_for_if_1_if_asn_itm_1) & while_for_for_for_if_1_asn_itm_1
      & while_for_for_for_while_for_for_for_if_1_nor_svs_st_1 & (~ exit_while_for_for_for_sva_st_1))))
      & (plm_out_ping_a1_a_d_data_rsci_bawt | (~(while_for_for_for_if_1_if_asn_itm_1
      & while_for_for_for_if_1_asn_itm_1 & while_for_for_for_while_for_for_for_if_1_nor_svs_st_1
      & (~ exit_while_for_for_for_sva_st_1)))) & (plm_out_pong_a0_a_d_data_rsci_bawt
      | while_for_for_for_if_1_else_asn_itm_1 | while_for_for_for_if_1_asn_itm_1
      | (~ while_for_for_for_while_for_for_for_if_1_nor_svs_st_1) | exit_while_for_for_for_sva_st_1)
      & (plm_out_pong_a1_a_d_data_rsci_bawt | (~(while_for_for_for_if_1_else_asn_itm_1
      & (~ while_for_for_for_if_1_asn_itm_1) & while_for_for_for_while_for_for_for_if_1_nor_svs_st_1
      & (~ exit_while_for_for_for_sva_st_1))));
  assign out_ping_pong_sva_mx1 = out_ping_pong_sva & or_dcpl_111;
  assign nl_while_for_acc_2_nl = ({1'b1 , (~ (conf2_Pop_mioi_idat_mxwt[31:0]))})
      + 33'b000000000000000000000000000000001;
  assign while_for_acc_2_nl = nl_while_for_acc_2_nl[32:0];
  assign nl_while_for_acc_3_nl = ({17'b10000000000000000 , while_for_b_sva_2}) +
      conv_u2u_32_33(~ (conf2_Pop_mio_mrgout_dat_sva[31:0])) + 33'b000000000000000000000000000000001;
  assign while_for_acc_3_nl = nl_while_for_acc_3_nl[32:0];
  assign exit_while_for_sva_mx0 = MUX_s_1_2_2((~ (readslicef_33_1_32(while_for_acc_2_nl))),
      (~ (readslicef_33_1_32(while_for_acc_3_nl))), fsm_output[10]);
  assign conf2_Pop_mio_mrgout_dat_sva_mx0_95_32 = MUX_v_64_2_2((conf2_Pop_mio_mrgout_dat_sva[95:32]),
      (conf2_Pop_mioi_idat_mxwt[95:32]), fsm_output[1]);
  assign nl_while_for_b_sva_2 = while_for_b_sva + 16'b0000000000000001;
  assign while_for_b_sva_2 = nl_while_for_b_sva_2[15:0];
  assign nl_while_for_for_in_rem_31_7_sva_3 = while_for_for_in_rem_31_7_sva + 25'b1111111111111111111111011;
  assign while_for_for_in_rem_31_7_sva_3 = nl_while_for_for_in_rem_31_7_sva_3[24:0];
  assign nl_while_for_for_in_len_acc_nl = conv_s2u_32_33({(~ while_for_for_in_rem_31_7_sva)
      , (~ while_for_in_length_sva_6_0)}) + 33'b000000000000000000000001010000001;
  assign while_for_for_in_len_acc_nl = nl_while_for_for_in_len_acc_nl[32:0];
  assign while_for_for_in_len_acc_itm_32_1 = readslicef_33_1_32(while_for_for_in_len_acc_nl);
  assign while_for_for_in_len_mux_2_nl = MUX_v_25_2_2(while_for_for_in_rem_31_7_sva,
      25'b0000000000000000000000101, while_for_for_in_len_slc_32_svs);
  assign nl_while_for_for_for_acc_3_nl = ({22'b1000000000000000000000 , while_for_for_for_i_10_1_sva
      , 1'b0}) + conv_u2u_32_33({(~ while_for_for_in_len_mux_2_nl) , (~ while_for_for_in_len_qr_6_0_lpi_3_dfm)})
      + 33'b000000000000000000000000000000001;
  assign while_for_for_for_acc_3_nl = nl_while_for_for_for_acc_3_nl[32:0];
  assign while_for_for_for_acc_3_itm_32_1 = readslicef_33_1_32(while_for_for_for_acc_3_nl);
  assign nl_while_for_for_vec_indx_31_1_sva_2 = while_for_for_vec_indx_31_1_sva +
      31'b0000000000000000000000000000001;
  assign while_for_for_vec_indx_31_1_sva_2 = nl_while_for_for_vec_indx_31_1_sva_2[30:0];
  assign nl_ac_array_1D_FPDATA_WORD_32U_operator_acc_nl = conv_u2u_27_28(while_for_for_vec_num_sva[31:5])
      + 28'b1111111111111111111111111111;
  assign ac_array_1D_FPDATA_WORD_32U_operator_acc_nl = nl_ac_array_1D_FPDATA_WORD_32U_operator_acc_nl[27:0];
  assign ac_array_1D_FPDATA_WORD_32U_operator_acc_itm_27_1 = readslicef_28_1_27(ac_array_1D_FPDATA_WORD_32U_operator_acc_nl);
  assign while_for_for_for_nand_16_cse_1 = ~(while_for_for_for_asn_itm & (~ reg_while_for_for_for_asn_5_cse));
  assign and_dcpl_1 = while_for_for_for_stage_v & (~ while_for_for_for_stage_v_1);
  assign and_dcpl_2 = and_dcpl_1 & while_for_for_for_stage_0_1;
  assign or_2_cse = (~ while_for_for_for_while_for_for_for_if_1_nor_svs_st_1) | in_wr_req_Pop_mioi_bawt;
  assign or_3_cse = (or_2_cse & in_rd_rsp_Push_mioi_bawt) | exit_while_for_for_for_sva_st_1;
  assign or_dcpl_4 = ~((~(or_3_cse & while_for_for_for_stage_0_2 & (~ out_ping_pong_sva)))
      & while_for_for_for_stage_v_2);
  assign and_dcpl_11 = (~ while_for_for_for_if_1_unequal_tmp) & while_for_for_for_acc_3_itm_32_1;
  assign and_dcpl_14 = and_dcpl_1 & while_for_for_for_stage_0_1 & (~ (conf2_Pop_mio_mrgout_dat_sva[64]));
  assign and_dcpl_32 = (~ exit_while_for_for_for_sva_st_1) & while_for_for_for_while_for_for_for_if_1_nor_svs_st_1;
  assign and_dcpl_46 = (~ reg_while_for_for_for_asn_5_cse) & while_for_for_for_while_for_for_for_if_1_nor_svs_st;
  assign mux_32_nl = MUX_s_1_2_2(plm_out_pong_a0_a_d_data_rsci_bawt, plm_out_pong_a1_a_d_data_rsci_bawt,
      while_for_for_for_if_1_else_asn_itm_1);
  assign mux_31_nl = MUX_s_1_2_2(plm_out_ping_a0_a_d_data_rsci_bawt, plm_out_ping_a1_a_d_data_rsci_bawt,
      while_for_for_for_if_1_if_asn_itm_1);
  assign mux_tmp_33 = MUX_s_1_2_2(mux_32_nl, mux_31_nl, while_for_for_for_if_1_asn_itm_1);
  assign and_dcpl_52 = (mux_tmp_33 | (~ while_for_for_for_while_for_for_for_if_1_nor_svs_st_1)
      | exit_while_for_for_for_sva_st_1) & out_ping_pong_sva & (~ while_for_for_for_stage_0_1)
      & (~ while_for_for_for_stage_0);
  assign and_61_cse = (~ mux_tmp_33) & and_dcpl_32;
  assign or_dcpl_42 = and_61_cse | (~ out_ping_pong_sva) | while_for_for_for_stage_0_1
      | while_for_for_for_stage_0;
  assign nor_63_cse = ~((fsm_output[7:6]!=2'b00));
  assign nor_62_cse = ~((fsm_output[0]) | (fsm_output[1]) | (fsm_output[10]));
  assign and_dcpl_66 = in_rd_rsp_Push_mioi_bawt & (~ out_ping_pong_sva) & while_for_for_for_stage_v_2;
  assign and_dcpl_67 = (~ exit_while_for_for_for_sva_st_1) & while_for_for_for_stage_0_2;
  assign and_dcpl_70 = (~ reg_while_for_for_for_asn_5_cse) & while_for_for_for_and_7_tmp;
  assign and_dcpl_80 = ~((fsm_output[5]) | (fsm_output[7]));
  assign and_dcpl_89 = while_for_for_for_stage_0_2 & (~ out_ping_pong_sva);
  assign or_dcpl_63 = ~((~(or_3_cse & and_dcpl_89)) & while_for_for_for_stage_v_2);
  assign and_dcpl_99 = and_dcpl_32 & out_ping_pong_sva;
  assign and_dcpl_102 = (~ out_ping_pong_sva) & while_for_for_for_stage_v_2;
  assign and_dcpl_106 = and_dcpl_67 & while_for_for_for_while_for_for_for_if_1_nor_svs_st_1
      & in_wr_req_Pop_mioi_bawt & in_rd_rsp_Push_mioi_bawt;
  assign or_dcpl_65 = out_ping_pong_sva | (~ while_for_for_for_stage_v_2);
  assign or_dcpl_69 = exit_while_for_for_for_sva_st_1 | (~ while_for_for_for_stage_0_2)
      | (~ while_for_for_for_while_for_for_for_if_1_nor_svs_st_1) | (~(in_rd_rsp_Push_mioi_bawt
      & in_wr_req_Pop_mioi_bawt));
  assign or_dcpl_81 = (~ while_for_for_for_stage_v) | while_for_for_for_stage_v_1;
  assign or_dcpl_82 = or_dcpl_81 | (~ while_for_for_for_stage_0_1);
  assign or_dcpl_84 = (~ while_for_for_for_stage_0_2) | out_ping_pong_sva;
  assign and_dcpl_128 = ~(((~(while_for_for_for_while_for_for_for_if_1_nor_svs_st_1
      & (~ in_wr_req_Pop_mioi_bawt))) & in_rd_rsp_Push_mioi_bawt) | exit_while_for_for_for_sva_st_1);
  assign and_dcpl_129 = (and_dcpl_128 | or_dcpl_84) & while_for_for_for_stage_v_2;
  assign or_dcpl_91 = while_for_for_for_if_1_unequal_tmp | (~ while_for_for_for_acc_3_itm_32_1);
  assign or_dcpl_94 = or_dcpl_81 | (~ while_for_for_for_stage_0_1) | (conf2_Pop_mio_mrgout_dat_sva[64]);
  assign or_dcpl_100 = (conf2_Pop_mio_mrgout_dat_sva[64]) | while_for_for_for_if_1_unequal_tmp;
  assign or_dcpl_110 = and_dcpl_128 | or_dcpl_84 | (~ while_for_for_for_stage_v_2);
  assign or_dcpl_111 = and_61_cse | (~ out_ping_pong_sva);
  assign and_dcpl_133 = ~((fsm_output[1:0]!=2'b00));
  assign or_dcpl_118 = and_dcpl_129 | or_dcpl_82;
  assign nand_tmp_15 = exit_while_for_for_for_sva_st_1 | (~ while_for_for_for_while_for_for_for_if_1_nor_svs_st_1)
      | (~ out_ping_pong_sva) | mux_tmp_33;
  assign or_tmp_177 = and_dcpl_67 & or_2_cse & and_dcpl_66 & (fsm_output[6]);
  assign or_tmp_180 = and_dcpl_67 & while_for_for_for_while_for_for_for_if_1_nor_svs_st_1
      & in_wr_req_Pop_mioi_bawt & and_dcpl_66 & (fsm_output[6]);
  assign and_300_cse = and_dcpl_80 & (~ (fsm_output[6]));
  assign or_tmp_205 = and_dcpl_70 & (~ ping_pong_lpi_3) & (fsm_output[7]);
  assign or_tmp_210 = (~ (fsm_output[6])) | or_dcpl_69 | or_dcpl_65 | while_for_for_for_if_1_if_asn_itm_1
      | (~ while_for_for_for_if_1_asn_itm_1);
  assign or_tmp_212 = (~ (fsm_output[6])) | or_dcpl_69 | or_dcpl_65 | (~(while_for_for_for_if_1_if_asn_itm_1
      & while_for_for_for_if_1_asn_itm_1));
  assign or_tmp_214 = (~ (fsm_output[6])) | or_dcpl_69 | or_dcpl_65 | while_for_for_for_if_1_asn_itm_1
      | while_for_for_for_if_1_else_asn_itm_1;
  assign or_tmp_216 = (~ (fsm_output[6])) | or_dcpl_69 | or_dcpl_65 | (~ while_for_for_for_if_1_else_asn_itm_1)
      | while_for_for_for_if_1_asn_itm_1;
  assign or_tmp_222 = (~ (fsm_output[6])) | and_dcpl_129 | or_dcpl_82 | (~(while_for_for_for_acc_3_itm_32_1
      & ping_pong_lpi_3));
  assign or_tmp_232 = (~ (fsm_output[6])) | and_dcpl_129 | or_dcpl_82 | (~ while_for_for_for_acc_3_itm_32_1)
      | ping_pong_lpi_3;
  assign and_452_cse = or_dcpl_110 & (fsm_output[6]);
  assign and_456_cse = or_3_cse & and_dcpl_89 & while_for_for_for_stage_v_2 & (fsm_output[6]);
  assign and_504_cse = or_dcpl_118 & (fsm_output[6]);
  assign or_tmp_307 = ((~ while_for_for_for_and_7_tmp) & (fsm_output[7])) | and_dcpl_80;
  assign while_for_for_for_stage_0_mx0c1 = and_300_cse | (or_dcpl_63 & and_dcpl_1
      & while_for_for_for_stage_0_1 & (~ while_for_for_for_acc_3_itm_32_1) & (fsm_output[6]));
  assign while_for_for_for_stage_v_1_mx0c1 = or_dcpl_63 & and_dcpl_2 & (fsm_output[6]);
  assign while_for_for_for_stage_v_2_mx0c0 = (fsm_output[5]) | and_456_cse;
  assign while_for_for_for_mux_6_itm_mx1c1 = or_dcpl_63 & and_dcpl_2 & or_dcpl_100;
  assign nl_while_for_for_acc_2_nl =  -conv_s2s_32_33(while_for_in_length_mul_cmp_z_oreg);
  assign while_for_for_acc_2_nl = nl_while_for_for_acc_2_nl[32:0];
  assign while_for_for_acc_2_itm_32_1 = readslicef_33_1_32(while_for_for_acc_2_nl);
  assign plm_in_ping_a0_a_d_data_rsci_r_adr_d = plm_in_ping_a1_a_d_data_mux_rmff;
  assign plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_in_ping_a1_a_d_data_rsci_r_adr_d = plm_in_ping_a1_a_d_data_mux_1_rmff;
  assign plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_in_pong_a0_a_d_data_rsci_r_adr_d = plm_in_ping_a1_a_d_data_mux_2_rmff;
  assign plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_in_pong_a1_a_d_data_rsci_r_adr_d = plm_in_ping_a1_a_d_data_mux_3_rmff;
  assign plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d = plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_out_ping_a0_a_d_data_rsci_din_d = while_for_for_for_if_1_acc_mux_rmff;
  assign plm_out_ping_a0_a_d_data_rsci_w_adr_d = ac_array_1D_FPDATA_WORD_32U_operator_mux_rmff;
  assign plm_out_ping_a0_a_d_data_rsci_w_en_d_pff = plm_out_ping_a0_a_d_data_rsci_w_en_d_iff;
  assign plm_out_ping_a1_a_d_data_rsci_din_d = while_for_for_for_if_1_acc_mux_1_rmff;
  assign plm_out_ping_a1_a_d_data_rsci_w_adr_d = ac_array_1D_FPDATA_WORD_32U_operator_mux_1_rmff;
  assign plm_out_ping_a1_a_d_data_rsci_w_en_d_pff = plm_out_ping_a1_a_d_data_rsci_w_en_d_iff;
  assign plm_out_pong_a0_a_d_data_rsci_din_d = while_for_for_for_if_1_acc_mux_2_rmff;
  assign plm_out_pong_a0_a_d_data_rsci_w_adr_d = ac_array_1D_FPDATA_WORD_32U_operator_1_mux_rmff;
  assign plm_out_pong_a0_a_d_data_rsci_w_en_d_pff = plm_out_pong_a0_a_d_data_rsci_w_en_d_iff;
  assign plm_out_pong_a1_a_d_data_rsci_din_d = while_for_for_for_if_1_acc_mux_3_rmff;
  assign plm_out_pong_a1_a_d_data_rsci_w_adr_d = ac_array_1D_FPDATA_WORD_32U_operator_1_mux_1_rmff;
  assign plm_out_pong_a1_a_d_data_rsci_w_en_d_pff = plm_out_pong_a1_a_d_data_rsci_w_en_d_iff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      in_rd_rsp_Push_mioi_iswt0 <= 1'b0;
    end
    else if ( compute_wen & (or_tmp_177 | (and_dcpl_70 & (fsm_output[7]))) ) begin
      in_rd_rsp_Push_mioi_iswt0 <= ~ or_tmp_177;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      in_wr_req_Pop_mioi_iswt0 <= 1'b0;
    end
    else if ( compute_wen & (or_tmp_180 | ((~ reg_while_for_for_for_asn_5_cse) &
        while_for_for_for_while_for_for_for_if_1_nor_svs_st & while_for_for_for_and_7_tmp
        & (fsm_output[7]))) ) begin
      in_wr_req_Pop_mioi_iswt0 <= ~ or_tmp_180;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      compute_flen <= 1'b0;
      reg_sync02_Pop_mioi_oswt_cse <= 1'b0;
      reg_sync12_sync_in_mioi_oswt_cse <= 1'b0;
      reg_sync23_sync_out_mioi_oswt_cse <= 1'b0;
      reg_plm_in_ping_a0_a_d_data_rsci_iswt0_cse <= 1'b0;
      reg_plm_in_pong_a0_a_d_data_rsci_iswt0_cse <= 1'b0;
      plm_out_ping_a0_a_d_data_rsci_iswt0 <= 1'b0;
      plm_out_ping_a1_a_d_data_rsci_iswt0 <= 1'b0;
      plm_out_pong_a0_a_d_data_rsci_iswt0 <= 1'b0;
      plm_out_pong_a1_a_d_data_rsci_iswt0 <= 1'b0;
      out_ping_pong_sva <= 1'b0;
      exit_while_for_for_sva <= 1'b0;
    end
    else if ( compute_wen ) begin
      compute_flen <= and_606_rmff;
      reg_sync02_Pop_mioi_oswt_cse <= ~(nor_62_cse | (~(exit_while_for_sva_mx0 |
          (fsm_output[0]))));
      reg_sync12_sync_in_mioi_oswt_cse <= fsm_output[4];
      reg_sync23_sync_out_mioi_oswt_cse <= fsm_output[8];
      reg_plm_in_ping_a0_a_d_data_rsci_iswt0_cse <= and_315_rmff;
      reg_plm_in_pong_a0_a_d_data_rsci_iswt0_cse <= and_319_rmff;
      plm_out_ping_a0_a_d_data_rsci_iswt0 <= and_323_rmff;
      plm_out_ping_a1_a_d_data_rsci_iswt0 <= and_327_rmff;
      plm_out_pong_a0_a_d_data_rsci_iswt0 <= and_331_rmff;
      plm_out_pong_a1_a_d_data_rsci_iswt0 <= and_335_rmff;
      out_ping_pong_sva <= (out_ping_pong_mux1h_3_nl & (~(nor_62_cse & nor_63_cse)))
          | and_456_cse;
      exit_while_for_for_sva <= ~ (readslicef_33_1_32(while_for_for_acc_nl));
    end
  end
  always @(posedge clk) begin
    if ( compute_wen ) begin
      while_for_in_length_mul_cmp_a <= conf2_Pop_mio_mrgout_dat_sva_mx0_95_32[31:0];
      while_for_in_length_mul_cmp_b <= conf2_Pop_mio_mrgout_dat_sva_mx0_95_32[63:32];
      plm_out_ping_a0_a_d_data_rsci_din_d_reg <= while_for_for_for_if_1_acc_mux_rmff;
      plm_out_ping_a0_a_d_data_rsci_w_adr_d_reg <= ac_array_1D_FPDATA_WORD_32U_operator_mux_rmff;
      plm_out_ping_a1_a_d_data_rsci_din_d_reg <= while_for_for_for_if_1_acc_mux_1_rmff;
      plm_out_ping_a1_a_d_data_rsci_w_adr_d_reg <= ac_array_1D_FPDATA_WORD_32U_operator_mux_1_rmff;
      plm_out_pong_a0_a_d_data_rsci_din_d_reg <= while_for_for_for_if_1_acc_mux_2_rmff;
      plm_out_pong_a0_a_d_data_rsci_w_adr_d_reg <= ac_array_1D_FPDATA_WORD_32U_operator_1_mux_rmff;
      plm_out_pong_a1_a_d_data_rsci_din_d_reg <= while_for_for_for_if_1_acc_mux_3_rmff;
      plm_out_pong_a1_a_d_data_rsci_w_adr_d_reg <= ac_array_1D_FPDATA_WORD_32U_operator_1_mux_1_rmff;
      plm_in_ping_a0_a_d_data_rsci_r_adr_d_reg <= plm_in_ping_a1_a_d_data_mux_rmff;
      plm_in_ping_a1_a_d_data_rsci_r_adr_d_reg <= plm_in_ping_a1_a_d_data_mux_1_rmff;
      plm_in_pong_a0_a_d_data_rsci_r_adr_d_reg <= plm_in_ping_a1_a_d_data_mux_2_rmff;
      plm_in_pong_a1_a_d_data_rsci_r_adr_d_reg <= plm_in_ping_a1_a_d_data_mux_3_rmff;
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_for_and_9_cse ) begin
      in_rd_rsp_Push_mioi_idat_31_0 <= MUX_v_32_2_2(plm_in_ping_a0_a_d_data_rsci_qout_d_mxwt,
          plm_in_pong_a0_a_d_data_rsci_qout_d_mxwt, or_tmp_205);
      in_rd_rsp_Push_mioi_idat_63_32 <= MUX_v_32_2_2(plm_in_ping_a1_a_d_data_rsci_qout_d_mxwt,
          plm_in_pong_a1_a_d_data_rsci_qout_d_mxwt, or_tmp_205);
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_if_1_if_asn_itm <= 1'b0;
    end
    else if ( compute_wen & (~((~ (fsm_output[6])) | and_dcpl_129 | or_dcpl_94 |
        or_dcpl_91 | (~ out_ping_pong_lpi_2))) ) begin
      while_for_for_for_if_1_if_asn_itm <= while_for_for_vec_idx_0_sva;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_if_1_else_asn_itm <= 1'b0;
    end
    else if ( compute_wen & (~((~ (fsm_output[6])) | and_dcpl_129 | or_dcpl_94 |
        or_dcpl_91 | out_ping_pong_lpi_2)) ) begin
      while_for_for_for_if_1_else_asn_itm <= while_for_for_vec_idx_0_sva;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_if_1_asn_itm <= 1'b0;
    end
    else if ( compute_wen & (~((~ (fsm_output[6])) | and_dcpl_129 | or_dcpl_82 |
        or_dcpl_100 | (~ while_for_for_for_acc_3_itm_32_1))) ) begin
      while_for_for_for_if_1_asn_itm <= out_ping_pong_lpi_2;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_while_for_for_for_if_1_nor_svs_st <= 1'b0;
      while_for_for_for_asn_itm <= 1'b0;
    end
    else if ( while_for_for_for_if_1_and_1_cse ) begin
      while_for_for_for_while_for_for_for_if_1_nor_svs_st <= nor_107_cse;
      while_for_for_for_asn_itm <= ping_pong_lpi_3;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_if_1_if_asn_itm_1 <= 1'b0;
      while_for_for_for_if_1_else_asn_itm_1 <= 1'b0;
      while_for_for_for_if_1_asn_itm_1 <= 1'b0;
      while_for_for_for_while_for_for_for_if_1_nor_svs_st_1 <= 1'b0;
      exit_while_for_for_for_sva_st_1 <= 1'b0;
    end
    else if ( while_for_for_for_if_1_if_and_1_cse ) begin
      while_for_for_for_if_1_if_asn_itm_1 <= while_for_for_for_if_1_if_asn_itm;
      while_for_for_for_if_1_else_asn_itm_1 <= while_for_for_for_if_1_else_asn_itm;
      while_for_for_for_if_1_asn_itm_1 <= while_for_for_for_if_1_asn_itm;
      while_for_for_for_while_for_for_for_if_1_nor_svs_st_1 <= while_for_for_for_while_for_for_for_if_1_nor_svs_st;
      exit_while_for_for_for_sva_st_1 <= reg_while_for_for_for_asn_5_cse;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_en_2 <= 1'b0;
      while_for_for_for_stage_en_4 <= 1'b0;
    end
    else if ( while_for_for_for_and_13_cse ) begin
      while_for_for_for_stage_en_2 <= while_for_for_for_and_7_tmp;
      while_for_for_for_stage_en_4 <= while_for_for_for_stage_en_4_mx1w0;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      ping_pong_sva <= 1'b0;
    end
    else if ( compute_wen & (fsm_output[10]) ) begin
      ping_pong_sva <= ping_pong_lpi_3;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf2_Pop_mio_mrgout_dat_sva <= 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( compute_wen & (~ and_dcpl_133) ) begin
      conf2_Pop_mio_mrgout_dat_sva <= conf2_Pop_mioi_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (~ nor_62_cse) ) begin
      while_for_b_sva <= MUX_v_16_2_2(16'b0000000000000000, while_for_b_sva_2, (fsm_output[10]));
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      ping_pong_lpi_3 <= 1'b0;
    end
    else if ( compute_wen & ((~ or_dcpl_42) | (fsm_output[1])) & (~(and_dcpl_133
        & (~ (fsm_output[7])))) ) begin
      ping_pong_lpi_3 <= MUX_s_1_2_2(ping_pong_sva, (~ ping_pong_lpi_3), fsm_output[7]);
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      out_ping_pong_lpi_2 <= 1'b0;
    end
    else if ( compute_wen & ((~((~((fsm_output[3]) | (fsm_output[0]) | (fsm_output[9])))
        | (while_for_for_acc_2_itm_32_1 & (fsm_output[3])) | ((~ exit_while_for_for_sva)
        & (fsm_output[9])))) | (fsm_output[1])) ) begin
      out_ping_pong_lpi_2 <= MUX_s_1_2_2(out_ping_pong_sva, (~ out_ping_pong_lpi_2),
          or_405_nl);
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (~((fsm_output[5]) | (fsm_output[4]) | (fsm_output[9]) | (fsm_output[7])
        | (fsm_output[6]))) ) begin
      while_for_for_in_rem_31_7_sva <= MUX_v_25_2_2((while_for_in_length_mul_cmp_z_oreg[31:7]),
          while_for_for_in_rem_31_7_sva_3, fsm_output[8]);
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (~((~((fsm_output[2]) | (fsm_output[10]) | (fsm_output[3])))
        & and_dcpl_133)) ) begin
      while_for_in_length_sva_6_0 <= while_for_in_length_mul_cmp_z_oreg[6:0];
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_in_len_slc_32_svs <= 1'b0;
    end
    else if ( while_for_for_in_len_and_cse ) begin
      while_for_for_in_len_slc_32_svs <= while_for_for_in_len_acc_itm_32_1;
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_in_len_and_cse ) begin
      while_for_for_in_len_qr_6_0_lpi_3_dfm <= MUX_v_7_2_2(7'b0000000, while_for_in_length_sva_6_0,
          while_for_for_in_len_not_4_nl);
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      reg_while_for_for_for_asn_5_cse <= 1'b0;
    end
    else if ( compute_wen & (~((fsm_output[7]) | and_504_cse)) ) begin
      reg_while_for_for_for_asn_5_cse <= ~ while_for_for_for_acc_3_itm_32_1;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (while_for_for_for_i_while_for_for_for_i_nor_cse | nor_63_cse)
        ) begin
      while_for_for_for_i_10_1_sva <= MUX_v_10_2_2(10'b0000000000, while_for_for_for_acc_2_nl,
          while_for_for_for_i_not_1_nl);
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_vec_idx_0_sva <= 1'b0;
    end
    else if ( while_for_for_vec_idx_and_cse ) begin
      while_for_for_vec_idx_0_sva <= while_for_for_for_mux_6_itm & (~ nor_63_cse);
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_vec_idx_and_cse ) begin
      while_for_for_vec_indx_31_1_sva <= while_for_for_vec_indx_31_1_sva_1 & (signext_31_1(~
          while_for_for_for_while_for_for_for_if_1_nor_svs)) & (signext_31_1(~ nor_63_cse));
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_v <= 1'b0;
    end
    else if ( compute_wen & (while_for_for_for_mux_16_nl | nor_63_cse) ) begin
      while_for_for_for_stage_v <= (fsm_output[7]) | nor_63_cse;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_0 <= 1'b0;
    end
    else if ( compute_wen & ((fsm_output[5]) | while_for_for_for_stage_0_mx0c1) )
        begin
      while_for_for_for_stage_0 <= ~ while_for_for_for_stage_0_mx0c1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_v_1 <= 1'b0;
    end
    else if ( compute_wen & ((while_for_for_for_and_7_tmp & (~(and_300_cse | and_504_cse)))
        | (fsm_output[5]) | while_for_for_for_stage_v_1_mx0c1) ) begin
      while_for_for_for_stage_v_1 <= while_for_for_for_stage_v_1_mx0c1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_v_2 <= 1'b0;
    end
    else if ( compute_wen & ((while_for_for_for_and_7_tmp & (~(and_300_cse | and_452_cse)))
        | while_for_for_for_stage_v_2_mx0c0) ) begin
      while_for_for_for_stage_v_2 <= ~ while_for_for_for_stage_v_2_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (nor_63_cse | (while_for_for_for_and_7_tmp & while_for_for_vec_idx_0_sva
        & while_for_for_for_while_for_for_for_if_1_nor_svs & (~(reg_while_for_for_for_asn_5_cse
        | exit_while_for_for_for_sva)) & (fsm_output[7]))) ) begin
      while_for_for_vec_num_sva <= MUX_v_32_2_2(32'b00000000000000000000000000000000,
          while_for_for_for_if_1_qif_acc_nl, while_for_for_vec_num_not_1_nl);
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_for_if_1_if_and_1_cse ) begin
      ac_array_1D_FPDATA_WORD_32U_operator_slc_ac_array_1D_FPDATA_WORD_32U_operator_idx_4_0_2_itm_1
          <= while_for_for_vec_num_sva[4:0];
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_0_1 <= 1'b0;
    end
    else if ( compute_wen & ((while_for_for_for_and_7_tmp & (~ and_dcpl_80)) | (fsm_output[5]))
        ) begin
      while_for_for_for_stage_0_1 <= while_for_for_for_stage_0 | (fsm_output[5]);
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_0_2 <= 1'b0;
    end
    else if ( compute_wen & ((~((or_dcpl_111 & (~ while_for_for_for_and_7_tmp)) |
        (fsm_output[6]))) | nor_63_cse) ) begin
      while_for_for_for_stage_0_2 <= while_for_for_for_stage_0_1 & (~ nor_63_cse);
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_while_for_for_for_if_1_nor_svs <= 1'b0;
      exit_while_for_for_for_sva <= 1'b0;
    end
    else if ( while_for_for_for_if_1_and_5_cse ) begin
      while_for_for_for_while_for_for_for_if_1_nor_svs <= nor_107_cse;
      exit_while_for_for_for_sva <= ~ while_for_for_for_acc_3_itm_32_1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_mux_6_itm <= 1'b0;
    end
    else if ( compute_wen & (~((~((or_dcpl_63 & and_dcpl_2 & nor_107_cse) | while_for_for_for_mux_6_itm_mx1c1))
        | (fsm_output[7]))) ) begin
      while_for_for_for_mux_6_itm <= MUX_s_1_2_2((~ while_for_for_vec_idx_0_sva),
          while_for_for_vec_idx_0_sva, while_for_for_for_mux_6_itm_mx1c1);
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_for_if_1_and_5_cse ) begin
      while_for_for_vec_indx_31_1_sva_1 <= while_for_for_vec_indx_31_1_sva_2;
    end
  end
  assign or_390_nl = (fsm_output[1:0]!=2'b00) | and_452_cse;
  assign out_ping_pong_mux1h_3_nl = MUX1HOT_s_1_3_2(out_ping_pong_sva, out_ping_pong_sva_mx1,
      out_ping_pong_lpi_2, {or_390_nl , (fsm_output[7]) , (fsm_output[10])});
  assign nl_while_for_for_acc_nl = conv_s2u_32_33({(~ while_for_for_in_rem_31_7_sva_3)
      , (~ while_for_in_length_sva_6_0)}) + 33'b000000000000000000000000000000001;
  assign while_for_for_acc_nl = nl_while_for_for_acc_nl[32:0];
  assign or_405_nl = ((~ while_for_for_acc_2_itm_32_1) & (fsm_output[3])) | (exit_while_for_for_sva
      & (fsm_output[9]));
  assign while_for_for_in_len_not_4_nl = ~ while_for_for_in_len_acc_itm_32_1;
  assign nl_while_for_for_for_acc_2_nl = while_for_for_for_i_10_1_sva + 10'b0000000001;
  assign while_for_for_for_acc_2_nl = nl_while_for_for_for_acc_2_nl[9:0];
  assign while_for_for_for_i_not_1_nl = ~ nor_63_cse;
  assign or_477_nl = (~ while_for_for_for_stage_0_1) | while_for_for_for_stage_v_1
      | (~ nand_tmp_15);
  assign nand_42_nl = ~(while_for_for_for_stage_0 & nand_tmp_15);
  assign mux_105_nl = MUX_s_1_2_2(or_477_nl, nand_42_nl, while_for_for_for_and_7_tmp);
  assign while_for_for_for_for_dataBv_int_while_for_for_for_nor_nl = ~(mux_105_nl
      | while_for_for_for_stage_v);
  assign while_for_for_for_mux_16_nl = MUX_s_1_2_2((~ or_dcpl_118), while_for_for_for_for_dataBv_int_while_for_for_for_nor_nl,
      fsm_output[7]);
  assign nl_while_for_for_for_if_1_qif_acc_nl = while_for_for_vec_num_sva + 32'b00000000000000000000000000000001;
  assign while_for_for_for_if_1_qif_acc_nl = nl_while_for_for_for_if_1_qif_acc_nl[31:0];
  assign while_for_for_vec_num_not_1_nl = ~ nor_63_cse;

  function automatic  MUX1HOT_s_1_1_2;
    input  input_0;
    input  sel;
    reg  result;
  begin
    result = input_0 & sel;
    MUX1HOT_s_1_1_2 = result;
  end
  endfunction


  function automatic  MUX1HOT_s_1_3_2;
    input  input_2;
    input  input_1;
    input  input_0;
    input [2:0] sel;
    reg  result;
  begin
    result = input_0 & sel[0];
    result = result | (input_1 & sel[1]);
    result = result | (input_2 & sel[2]);
    MUX1HOT_s_1_3_2 = result;
  end
  endfunction


  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [9:0] MUX_v_10_2_2;
    input [9:0] input_0;
    input [9:0] input_1;
    input  sel;
    reg [9:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_10_2_2 = result;
  end
  endfunction


  function automatic [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input  sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction


  function automatic [24:0] MUX_v_25_2_2;
    input [24:0] input_0;
    input [24:0] input_1;
    input  sel;
    reg [24:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_25_2_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input  sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function automatic [63:0] MUX_v_64_2_2;
    input [63:0] input_0;
    input [63:0] input_1;
    input  sel;
    reg [63:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_64_2_2 = result;
  end
  endfunction


  function automatic [6:0] MUX_v_7_2_2;
    input [6:0] input_0;
    input [6:0] input_1;
    input  sel;
    reg [6:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_7_2_2 = result;
  end
  endfunction


  function automatic [8:0] MUX_v_9_2_2;
    input [8:0] input_0;
    input [8:0] input_1;
    input  sel;
    reg [8:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_9_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_28_1_27;
    input [27:0] vector;
    reg [27:0] tmp;
  begin
    tmp = vector >> 27;
    readslicef_28_1_27 = tmp[0:0];
  end
  endfunction


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [0:0] readslicef_4_1_3;
    input [3:0] vector;
    reg [3:0] tmp;
  begin
    tmp = vector >> 3;
    readslicef_4_1_3 = tmp[0:0];
  end
  endfunction


  function automatic [30:0] signext_31_1;
    input  vector;
  begin
    signext_31_1= {{30{vector}}, vector};
  end
  endfunction


  function automatic [32:0] conv_s2s_32_33 ;
    input [31:0]  vector ;
  begin
    conv_s2s_32_33 = {vector[31], vector};
  end
  endfunction


  function automatic [32:0] conv_s2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_s2u_32_33 = {vector[31], vector};
  end
  endfunction


  function automatic [27:0] conv_u2u_27_28 ;
    input [26:0]  vector ;
  begin
    conv_u2u_27_28 = {1'b0, vector};
  end
  endfunction


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load_load
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load_load (
  clk, rst, dma_read_chnl_val, dma_read_chnl_rdy, dma_read_chnl_msg, dma_read_ctrl_val,
      dma_read_ctrl_rdy, dma_read_ctrl_msg, sync12_vld, sync12_rdy, sync01_val, sync01_rdy,
      sync01_msg, conf1_val, conf1_rdy, conf1_msg, while_for_len_mul_cmp_a, while_for_len_mul_cmp_b,
      while_for_len_mul_cmp_z, plm_in_ping_a0_a_d_data_rsci_din_d_pff, plm_in_ping_a0_a_d_data_rsci_w_adr_d_pff,
      plm_in_ping_a0_a_d_data_rsci_w_en_d_pff, plm_in_ping_a1_a_d_data_rsci_din_d_pff,
      plm_in_ping_a1_a_d_data_rsci_w_en_d_pff, plm_in_pong_a0_a_d_data_rsci_w_en_d_pff,
      plm_in_pong_a1_a_d_data_rsci_w_en_d_pff
);
  input clk;
  input rst;
  input dma_read_chnl_val;
  output dma_read_chnl_rdy;
  input [63:0] dma_read_chnl_msg;
  output dma_read_ctrl_val;
  input dma_read_ctrl_rdy;
  output [72:0] dma_read_ctrl_msg;
  output sync12_vld;
  input sync12_rdy;
  input sync01_val;
  output sync01_rdy;
  input sync01_msg;
  input conf1_val;
  output conf1_rdy;
  input [95:0] conf1_msg;
  output [31:0] while_for_len_mul_cmp_a;
  reg [31:0] while_for_len_mul_cmp_a;
  output [31:0] while_for_len_mul_cmp_b;
  reg [31:0] while_for_len_mul_cmp_b;
  input [31:0] while_for_len_mul_cmp_z;
  output [31:0] plm_in_ping_a0_a_d_data_rsci_din_d_pff;
  output [8:0] plm_in_ping_a0_a_d_data_rsci_w_adr_d_pff;
  output plm_in_ping_a0_a_d_data_rsci_w_en_d_pff;
  output [31:0] plm_in_ping_a1_a_d_data_rsci_din_d_pff;
  output plm_in_ping_a1_a_d_data_rsci_w_en_d_pff;
  output plm_in_pong_a0_a_d_data_rsci_w_en_d_pff;
  output plm_in_pong_a1_a_d_data_rsci_w_en_d_pff;


  // Interconnect Declarations
  wire load_wen;
  wire sync01_Pop_mioi_wen_comp;
  wire sync01_Pop_mioi_ivld;
  wire sync01_Pop_mioi_ivld_oreg;
  wire conf1_Pop_mioi_wen_comp;
  wire [95:0] conf1_Pop_mioi_idat_mxwt;
  wire conf1_Pop_mioi_ivld;
  wire conf1_Pop_mioi_ivld_oreg;
  wire dma_read_ctrl_Push_mioi_wen_comp;
  wire dma_read_ctrl_Push_mioi_irdy;
  wire dma_read_ctrl_Push_mioi_irdy_oreg;
  wire dma_read_chnl_Pop_mioi_wen_comp;
  wire [63:0] dma_read_chnl_Pop_mioi_idat_mxwt;
  wire dma_read_chnl_Pop_mioi_ivld;
  wire dma_read_chnl_Pop_mioi_ivld_oreg;
  wire sync12_sync_out_mioi_wen_comp;
  wire [31:0] while_for_len_mul_cmp_z_oreg;
  reg [30:0] dma_read_ctrl_Push_mioi_idat_30_0;
  wire [10:0] fsm_output;
  wire and_dcpl;
  wire and_dcpl_3;
  wire and_dcpl_7;
  wire and_dcpl_11;
  reg exit_while_for_for_sva;
  wire exit_while_for_sva_mx0;
  reg ping_pong_lpi_3;
  reg while_for_for_for_stage_0_2;
  reg while_for_for_for_stage_0;
  reg while_for_for_for_asn_1_itm_1;
  reg while_for_for_for_for_asn_itm_1;
  wire plm_in_ping_operator_mux_cse;
  wire plm_in_ping_operator_mux_1_cse;
  wire ac_array_1D_FPDATA_WORD_320U_operator_mux_1_cse;
  wire plm_in_pong_operator_mux_cse;
  wire plm_in_pong_operator_mux_1_cse;
  reg reg_sync01_Pop_mioi_oswt_cse;
  reg reg_dma_read_ctrl_Push_mioi_oswt_cse;
  reg reg_dma_read_chnl_Pop_mioi_oswt_cse;
  reg reg_sync12_sync_out_mioi_oswt_cse;
  wire while_for_for_and_cse;
  wire or_27_cse;
  wire or_30_cse;
  wire ac_array_1D_FPDATA_WORD_320U_operator_1_mux_1_cse;
  reg [24:0] reg_dma_read_ctrl_Push_mioi_idat_62_38_cse;
  reg [5:0] reg_dma_read_ctrl_Push_mioi_idat_37_32_cse;
  wire plm_in_ping_a0_a_d_data_rsci_w_en_d_iff;
  wire and_91_rmff;
  wire plm_in_ping_a1_a_d_data_rsci_w_en_d_iff;
  wire plm_in_pong_a0_a_d_data_rsci_w_en_d_iff;
  wire and_93_rmff;
  wire plm_in_pong_a1_a_d_data_rsci_w_en_d_iff;
  reg [9:0] while_for_for_for_i_10_1_sva;
  reg ping_pong_sva;
  reg [95:0] conf1_Pop_mio_mrgout_dat_sva;
  reg [15:0] while_for_b_sva;
  reg [30:0] while_offset_31_1_lpi_3;
  reg [30:0] while_for_len_acc_psp_sva;
  wire [31:0] nl_while_for_len_acc_psp_sva;
  reg [24:0] while_for_for_rem_31_7_sva;
  reg [9:0] while_for_for_for_mux_1_itm_1;
  wire [10:0] nl_while_for_for_for_mux_1_itm_1;
  wire [15:0] while_for_b_sva_2;
  wire [16:0] nl_while_for_b_sva_2;
  wire [24:0] while_for_for_rem_31_7_sva_4;
  wire [25:0] nl_while_for_for_rem_31_7_sva_4;
  wire [9:0] while_for_for_for_i_10_1_sva_mx1;
  wire [63:0] conf1_Pop_mio_mrgout_dat_sva_mx0_95_32;
  wire while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_itm_3_1;
  wire while_for_for_len1_acc_itm_32_1;
  wire while_for_for_for_acc_2_itm_32_1;
  wire z_out_32;

  wire pidx_C_ctrl_prb;
  wire pidx_C_prb;
  wire pidx_D1_ctrl_prb;
  wire pidx_D1_prb;
  wire pidx_C_ctrl_prb_1;
  wire pidx_C_prb_1;
  wire pidx_D1_ctrl_prb_1;
  wire pidx_D1_prb_1;
  wire pidx_C_ctrl_prb_2;
  wire pidx_C_prb_2;
  wire pidx_D1_ctrl_prb_2;
  wire pidx_D1_prb_2;
  wire pidx_C_ctrl_prb_3;
  wire pidx_C_prb_3;
  wire pidx_D1_ctrl_prb_3;
  wire pidx_D1_prb_3;
  wire while_for_for_len1_not_4_nl;
  wire and_100_nl;
  wire and_153_nl;
  wire[30:0] while_for_for_acc_3_nl;
  wire[31:0] nl_while_for_for_acc_3_nl;
  wire[31:0] while_for_len_acc_1_nl;
  wire[32:0] nl_while_for_len_acc_1_nl;
  wire[3:0] while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_nl;
  wire[4:0] nl_while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_nl;
  wire[32:0] while_for_acc_2_nl;
  wire[33:0] nl_while_for_acc_2_nl;
  wire[32:0] while_for_acc_3_nl;
  wire[33:0] nl_while_for_acc_3_nl;
  wire[32:0] while_for_for_len1_acc_nl;
  wire[33:0] nl_while_for_for_len1_acc_nl;
  wire or_40_nl;
  wire[32:0] while_for_for_for_acc_2_nl;
  wire[33:0] nl_while_for_for_for_acc_2_nl;
  wire[32:0] while_for_for_acc_rg_1_nl;
  wire[33:0] nl_while_for_for_acc_rg_1_nl;
  wire[24:0] while_for_for_mux_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [72:0] nl_Ctrl_load_load_dma_read_ctrl_Push_mioi_inst_dma_read_ctrl_Push_mioi_idat;
  assign nl_Ctrl_load_load_dma_read_ctrl_Push_mioi_inst_dma_read_ctrl_Push_mioi_idat
      = {10'b0000000100 , reg_dma_read_ctrl_Push_mioi_idat_62_38_cse , reg_dma_read_ctrl_Push_mioi_idat_37_32_cse
      , 1'b0 , dma_read_ctrl_Push_mioi_idat_30_0};
  wire  nl_Ctrl_load_load_sync12_sync_out_mioi_inst_load_wten;
  assign nl_Ctrl_load_load_sync12_sync_out_mioi_inst_load_wten = ~ load_wen;
  wire  nl_Ctrl_load_load_sync12_sync_out_mioi_inst_sync12_sync_out_mioi_oswt_pff;
  assign nl_Ctrl_load_load_sync12_sync_out_mioi_inst_sync12_sync_out_mioi_oswt_pff
      = fsm_output[8];
  wire  nl_Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1_inst_load_wten_pff;
  assign nl_Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1_inst_load_wten_pff = ~
      load_wen;
  wire  nl_Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1_inst_load_wten_pff;
  assign nl_Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1_inst_load_wten_pff = ~
      load_wen;
  wire  nl_Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1_inst_load_wten_pff;
  assign nl_Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1_inst_load_wten_pff = ~
      load_wen;
  wire  nl_Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1_inst_load_wten_pff;
  assign nl_Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1_inst_load_wten_pff = ~
      load_wen;
  wire  nl_Ctrl_load_load_load_fsm_inst_while_for_C_2_tr0;
  assign nl_Ctrl_load_load_load_fsm_inst_while_for_C_2_tr0 = ~ z_out_32;
  esp_acc_DUMMY_Ctrl_load_load_sync01_Pop_mioi Ctrl_load_load_sync01_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync01_val(sync01_val),
      .sync01_rdy(sync01_rdy),
      .sync01_msg(sync01_msg),
      .load_wen(load_wen),
      .sync01_Pop_mioi_oswt(reg_sync01_Pop_mioi_oswt_cse),
      .sync01_Pop_mioi_wen_comp(sync01_Pop_mioi_wen_comp),
      .sync01_Pop_mioi_ivld(sync01_Pop_mioi_ivld),
      .sync01_Pop_mioi_ivld_oreg(sync01_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_Ctrl_load_load_wait_dp Ctrl_load_load_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .while_for_len_mul_cmp_z(while_for_len_mul_cmp_z),
      .load_wen(load_wen),
      .sync01_Pop_mioi_ivld(sync01_Pop_mioi_ivld),
      .sync01_Pop_mioi_ivld_oreg(sync01_Pop_mioi_ivld_oreg),
      .conf1_Pop_mioi_ivld(conf1_Pop_mioi_ivld),
      .conf1_Pop_mioi_ivld_oreg(conf1_Pop_mioi_ivld_oreg),
      .dma_read_ctrl_Push_mioi_irdy(dma_read_ctrl_Push_mioi_irdy),
      .dma_read_ctrl_Push_mioi_irdy_oreg(dma_read_ctrl_Push_mioi_irdy_oreg),
      .dma_read_chnl_Pop_mioi_ivld(dma_read_chnl_Pop_mioi_ivld),
      .dma_read_chnl_Pop_mioi_ivld_oreg(dma_read_chnl_Pop_mioi_ivld_oreg),
      .while_for_len_mul_cmp_z_oreg(while_for_len_mul_cmp_z_oreg)
    );
  esp_acc_DUMMY_Ctrl_load_load_conf1_Pop_mioi Ctrl_load_load_conf1_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf1_val(conf1_val),
      .conf1_rdy(conf1_rdy),
      .conf1_msg(conf1_msg),
      .load_wen(load_wen),
      .conf1_Pop_mioi_oswt(reg_sync01_Pop_mioi_oswt_cse),
      .conf1_Pop_mioi_wen_comp(conf1_Pop_mioi_wen_comp),
      .conf1_Pop_mioi_idat_mxwt(conf1_Pop_mioi_idat_mxwt),
      .conf1_Pop_mioi_ivld(conf1_Pop_mioi_ivld),
      .conf1_Pop_mioi_ivld_oreg(conf1_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_Ctrl_load_load_dma_read_ctrl_Push_mioi Ctrl_load_load_dma_read_ctrl_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_val(dma_read_ctrl_val),
      .dma_read_ctrl_rdy(dma_read_ctrl_rdy),
      .dma_read_ctrl_msg(dma_read_ctrl_msg),
      .dma_read_ctrl_Push_mioi_oswt(reg_dma_read_ctrl_Push_mioi_oswt_cse),
      .dma_read_ctrl_Push_mioi_wen_comp(dma_read_ctrl_Push_mioi_wen_comp),
      .dma_read_ctrl_Push_mioi_idat(nl_Ctrl_load_load_dma_read_ctrl_Push_mioi_inst_dma_read_ctrl_Push_mioi_idat[72:0]),
      .dma_read_ctrl_Push_mioi_irdy(dma_read_ctrl_Push_mioi_irdy),
      .dma_read_ctrl_Push_mioi_irdy_oreg(dma_read_ctrl_Push_mioi_irdy_oreg)
    );
  esp_acc_DUMMY_Ctrl_load_load_dma_read_chnl_Pop_mioi Ctrl_load_load_dma_read_chnl_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_val(dma_read_chnl_val),
      .dma_read_chnl_rdy(dma_read_chnl_rdy),
      .dma_read_chnl_msg(dma_read_chnl_msg),
      .load_wen(load_wen),
      .dma_read_chnl_Pop_mioi_oswt(reg_dma_read_chnl_Pop_mioi_oswt_cse),
      .dma_read_chnl_Pop_mioi_wen_comp(dma_read_chnl_Pop_mioi_wen_comp),
      .dma_read_chnl_Pop_mioi_idat_mxwt(dma_read_chnl_Pop_mioi_idat_mxwt),
      .dma_read_chnl_Pop_mioi_ivld(dma_read_chnl_Pop_mioi_ivld),
      .dma_read_chnl_Pop_mioi_ivld_oreg(dma_read_chnl_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_Ctrl_load_load_sync12_sync_out_mioi Ctrl_load_load_sync12_sync_out_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync12_vld(sync12_vld),
      .sync12_rdy(sync12_rdy),
      .load_wten(nl_Ctrl_load_load_sync12_sync_out_mioi_inst_load_wten),
      .sync12_sync_out_mioi_oswt(reg_sync12_sync_out_mioi_oswt_cse),
      .sync12_sync_out_mioi_wen_comp(sync12_sync_out_mioi_wen_comp),
      .sync12_sync_out_mioi_oswt_pff(nl_Ctrl_load_load_sync12_sync_out_mioi_inst_sync12_sync_out_mioi_oswt_pff)
    );
  esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1 Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1_inst
      (
      .plm_in_ping_a0_a_d_data_rsci_w_en_d_pff(plm_in_ping_a0_a_d_data_rsci_w_en_d_iff),
      .load_wten_pff(nl_Ctrl_load_load_plm_in_ping_a0_a_d_data_rsci_1_inst_load_wten_pff),
      .plm_in_ping_a0_a_d_data_rsci_iswt0_pff(and_91_rmff)
    );
  esp_acc_DUMMY_Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1 Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1_inst
      (
      .plm_in_ping_a1_a_d_data_rsci_w_en_d_pff(plm_in_ping_a1_a_d_data_rsci_w_en_d_iff),
      .load_wten_pff(nl_Ctrl_load_load_plm_in_ping_a1_a_d_data_rsci_1_inst_load_wten_pff),
      .plm_in_ping_a1_a_d_data_rsci_iswt0_pff(and_91_rmff)
    );
  esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1 Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1_inst
      (
      .plm_in_pong_a0_a_d_data_rsci_w_en_d_pff(plm_in_pong_a0_a_d_data_rsci_w_en_d_iff),
      .load_wten_pff(nl_Ctrl_load_load_plm_in_pong_a0_a_d_data_rsci_1_inst_load_wten_pff),
      .plm_in_pong_a0_a_d_data_rsci_iswt0_pff(and_93_rmff)
    );
  esp_acc_DUMMY_Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1 Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1_inst
      (
      .plm_in_pong_a1_a_d_data_rsci_w_en_d_pff(plm_in_pong_a1_a_d_data_rsci_w_en_d_iff),
      .load_wten_pff(nl_Ctrl_load_load_plm_in_pong_a1_a_d_data_rsci_1_inst_load_wten_pff),
      .plm_in_pong_a1_a_d_data_rsci_iswt0_pff(and_93_rmff)
    );
  esp_acc_DUMMY_Ctrl_load_load_staller Ctrl_load_load_staller_inst (
      .load_wen(load_wen),
      .sync01_Pop_mioi_wen_comp(sync01_Pop_mioi_wen_comp),
      .conf1_Pop_mioi_wen_comp(conf1_Pop_mioi_wen_comp),
      .dma_read_ctrl_Push_mioi_wen_comp(dma_read_ctrl_Push_mioi_wen_comp),
      .dma_read_chnl_Pop_mioi_wen_comp(dma_read_chnl_Pop_mioi_wen_comp),
      .sync12_sync_out_mioi_wen_comp(sync12_sync_out_mioi_wen_comp)
    );
  esp_acc_DUMMY_Ctrl_load_load_load_fsm Ctrl_load_load_load_fsm_inst (
      .clk(clk),
      .rst(rst),
      .load_wen(load_wen),
      .fsm_output(fsm_output),
      .while_C_0_tr0(exit_while_for_sva_mx0),
      .while_for_C_2_tr0(nl_Ctrl_load_load_load_fsm_inst_while_for_C_2_tr0),
      .while_for_for_for_C_0_tr0(and_dcpl_7),
      .while_for_for_C_3_tr0(exit_while_for_for_sva),
      .while_for_C_3_tr0(exit_while_for_sva_mx0)
    );
  assign plm_in_ping_operator_mux_cse = MUX1HOT_s_1_1_2(load_wen, or_27_cse);
  assign pidx_C_ctrl_prb = plm_in_ping_operator_mux_cse;
  assign plm_in_ping_operator_mux_1_cse = MUX1HOT_s_1_1_2(1'b1, or_27_cse);
  assign pidx_C_prb = plm_in_ping_operator_mux_1_cse;
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl default clock = (posedge clk);
  // psl while_for_for_for_for_1_Ctrl_load_ac_shared_bank_array_h_ln85_assert_idx_lt_C_2 : assert always ( rst &&  pidx_C_ctrl_prb  -> pidx_C_prb );
  assign pidx_D1_ctrl_prb = plm_in_ping_operator_mux_cse;
  assign ac_array_1D_FPDATA_WORD_320U_operator_mux_1_cse = MUX1HOT_s_1_1_2(while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_itm_3_1,
      or_27_cse);
  assign pidx_D1_prb = ac_array_1D_FPDATA_WORD_320U_operator_mux_1_cse;
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl while_for_for_for_for_1_Ctrl_load_ac_array_1D_h_ln58_assert_idx_lt_D1_4 : assert always ( rst &&  pidx_D1_ctrl_prb  -> pidx_D1_prb );
  assign pidx_C_ctrl_prb_1 = plm_in_ping_operator_mux_cse;
  assign pidx_C_prb_1 = plm_in_ping_operator_mux_1_cse;
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl while_for_for_for_for_2_Ctrl_load_ac_shared_bank_array_h_ln85_assert_idx_lt_C_2 : assert always ( rst &&  pidx_C_ctrl_prb_1  -> pidx_C_prb_1 );
  assign pidx_D1_ctrl_prb_1 = plm_in_ping_operator_mux_cse;
  assign pidx_D1_prb_1 = ac_array_1D_FPDATA_WORD_320U_operator_mux_1_cse;
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl while_for_for_for_for_2_Ctrl_load_ac_array_1D_h_ln58_assert_idx_lt_D1_4 : assert always ( rst &&  pidx_D1_ctrl_prb_1  -> pidx_D1_prb_1 );
  assign plm_in_pong_operator_mux_cse = MUX1HOT_s_1_1_2(load_wen, or_30_cse);
  assign pidx_C_ctrl_prb_2 = plm_in_pong_operator_mux_cse;
  assign plm_in_pong_operator_mux_1_cse = MUX1HOT_s_1_1_2(1'b1, or_30_cse);
  assign pidx_C_prb_2 = plm_in_pong_operator_mux_1_cse;
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl while_for_for_for_for_1_Ctrl_load_ac_shared_bank_array_h_ln85_assert_idx_lt_C_3 : assert always ( rst &&  pidx_C_ctrl_prb_2  -> pidx_C_prb_2 );
  assign pidx_D1_ctrl_prb_2 = plm_in_pong_operator_mux_cse;
  assign ac_array_1D_FPDATA_WORD_320U_operator_1_mux_1_cse = MUX1HOT_s_1_1_2(while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_itm_3_1,
      or_30_cse);
  assign pidx_D1_prb_2 = ac_array_1D_FPDATA_WORD_320U_operator_1_mux_1_cse;
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl while_for_for_for_for_1_Ctrl_load_ac_array_1D_h_ln58_assert_idx_lt_D1_5 : assert always ( rst &&  pidx_D1_ctrl_prb_2  -> pidx_D1_prb_2 );
  assign pidx_C_ctrl_prb_3 = plm_in_pong_operator_mux_cse;
  assign pidx_C_prb_3 = plm_in_pong_operator_mux_1_cse;
  // assert(idx < C) - ../../../../common/matchlib_toolkit/include/ac_shared_bank_array.h: line 85
  // psl while_for_for_for_for_2_Ctrl_load_ac_shared_bank_array_h_ln85_assert_idx_lt_C_3 : assert always ( rst &&  pidx_C_ctrl_prb_3  -> pidx_C_prb_3 );
  assign pidx_D1_ctrl_prb_3 = plm_in_pong_operator_mux_cse;
  assign pidx_D1_prb_3 = ac_array_1D_FPDATA_WORD_320U_operator_1_mux_1_cse;
  // assert(idx < D1) - ../../../../common/matchlib_toolkit/include/ac_array_1D.h: line 58
  // psl while_for_for_for_for_2_Ctrl_load_ac_array_1D_h_ln58_assert_idx_lt_D1_5 : assert always ( rst &&  pidx_D1_ctrl_prb_3  -> pidx_D1_prb_3 );
  assign and_91_rmff = and_dcpl_11 & while_for_for_for_for_asn_itm_1 & (fsm_output[7]);
  assign and_93_rmff = and_dcpl_11 & (~ while_for_for_for_for_asn_itm_1) & (fsm_output[7]);
  assign while_for_for_and_cse = load_wen & (fsm_output[5]);
  assign or_27_cse = and_dcpl & ping_pong_lpi_3 & (fsm_output[7]);
  assign nl_while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_nl
      = (while_for_for_for_i_10_1_sva_mx1[9:6]) + 4'b1011;
  assign while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_nl = nl_while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_nl[3:0];
  assign while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_itm_3_1
      = readslicef_4_1_3(while_for_for_for_for_1_ac_array_1D_FPDATA_WORD_320U_operator_acc_nl);
  assign or_30_cse = and_dcpl & (~ ping_pong_lpi_3) & (fsm_output[7]);
  assign nl_while_for_acc_2_nl = ({1'b1 , (~ (conf1_Pop_mioi_idat_mxwt[31:0]))})
      + 33'b000000000000000000000000000000001;
  assign while_for_acc_2_nl = nl_while_for_acc_2_nl[32:0];
  assign nl_while_for_acc_3_nl = ({17'b10000000000000000 , while_for_b_sva_2}) +
      conv_u2u_32_33(~ (conf1_Pop_mio_mrgout_dat_sva[31:0])) + 33'b000000000000000000000000000000001;
  assign while_for_acc_3_nl = nl_while_for_acc_3_nl[32:0];
  assign exit_while_for_sva_mx0 = MUX_s_1_2_2((~ (readslicef_33_1_32(while_for_acc_2_nl))),
      (~ (readslicef_33_1_32(while_for_acc_3_nl))), fsm_output[10]);
  assign conf1_Pop_mio_mrgout_dat_sva_mx0_95_32 = MUX_v_64_2_2((conf1_Pop_mio_mrgout_dat_sva[95:32]),
      (conf1_Pop_mioi_idat_mxwt[95:32]), fsm_output[1]);
  assign nl_while_for_b_sva_2 = while_for_b_sva + 16'b0000000000000001;
  assign while_for_b_sva_2 = nl_while_for_b_sva_2[15:0];
  assign nl_while_for_for_rem_31_7_sva_4 = while_for_for_rem_31_7_sva + 25'b1111111111111111111111011;
  assign while_for_for_rem_31_7_sva_4 = nl_while_for_for_rem_31_7_sva_4[24:0];
  assign nl_while_for_for_len1_acc_nl = conv_s2u_32_33({(~ while_for_for_rem_31_7_sva)
      , (~ (while_for_len_acc_psp_sva[5:0])) , 1'b1}) + 33'b000000000000000000000001010000001;
  assign while_for_for_len1_acc_nl = nl_while_for_for_len1_acc_nl[32:0];
  assign while_for_for_len1_acc_itm_32_1 = readslicef_33_1_32(while_for_for_len1_acc_nl);
  assign or_40_nl = (~ while_for_for_for_stage_0_2) | while_for_for_for_asn_1_itm_1;
  assign while_for_for_for_i_10_1_sva_mx1 = MUX_v_10_2_2(while_for_for_for_mux_1_itm_1,
      while_for_for_for_i_10_1_sva, or_40_nl);
  assign and_dcpl = while_for_for_for_stage_0 & while_for_for_for_acc_2_itm_32_1;
  assign and_dcpl_3 = ~((fsm_output[1:0]!=2'b00));
  assign and_dcpl_7 = ~(while_for_for_for_stage_0 | while_for_for_for_stage_0_2);
  assign and_dcpl_11 = while_for_for_for_stage_0_2 & (~ while_for_for_for_asn_1_itm_1);
  assign nl_while_for_for_for_acc_2_nl = ({22'b1000000000000000000000 , while_for_for_for_i_10_1_sva_mx1
      , 1'b0}) + conv_u2u_32_33({(~ reg_dma_read_ctrl_Push_mioi_idat_62_38_cse) ,
      (~ reg_dma_read_ctrl_Push_mioi_idat_37_32_cse) , 1'b1}) + 33'b000000000000000000000000000000001;
  assign while_for_for_for_acc_2_nl = nl_while_for_for_for_acc_2_nl[32:0];
  assign while_for_for_for_acc_2_itm_32_1 = readslicef_33_1_32(while_for_for_for_acc_2_nl);
  assign plm_in_ping_a0_a_d_data_rsci_din_d_pff = dma_read_chnl_Pop_mioi_idat_mxwt[31:0];
  assign plm_in_ping_a0_a_d_data_rsci_w_adr_d_pff = while_for_for_for_i_10_1_sva[8:0];
  assign plm_in_ping_a0_a_d_data_rsci_w_en_d_pff = plm_in_ping_a0_a_d_data_rsci_w_en_d_iff;
  assign plm_in_ping_a1_a_d_data_rsci_din_d_pff = dma_read_chnl_Pop_mioi_idat_mxwt[63:32];
  assign plm_in_ping_a1_a_d_data_rsci_w_en_d_pff = plm_in_ping_a1_a_d_data_rsci_w_en_d_iff;
  assign plm_in_pong_a0_a_d_data_rsci_w_en_d_pff = plm_in_pong_a0_a_d_data_rsci_w_en_d_iff;
  assign plm_in_pong_a1_a_d_data_rsci_w_en_d_pff = plm_in_pong_a1_a_d_data_rsci_w_en_d_iff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      reg_sync01_Pop_mioi_oswt_cse <= 1'b0;
      reg_dma_read_ctrl_Push_mioi_oswt_cse <= 1'b0;
      reg_dma_read_chnl_Pop_mioi_oswt_cse <= 1'b0;
      reg_sync12_sync_out_mioi_oswt_cse <= 1'b0;
      exit_while_for_for_sva <= 1'b0;
      while_for_for_for_for_asn_itm_1 <= 1'b0;
      while_for_for_for_asn_1_itm_1 <= 1'b0;
      while_for_for_for_stage_0_2 <= 1'b0;
    end
    else if ( load_wen ) begin
      reg_sync01_Pop_mioi_oswt_cse <= ~((~((fsm_output[10]) | (fsm_output[1]) | (fsm_output[0])))
          | (~(exit_while_for_sva_mx0 | (fsm_output[0]))));
      reg_dma_read_ctrl_Push_mioi_oswt_cse <= fsm_output[5];
      reg_dma_read_chnl_Pop_mioi_oswt_cse <= while_for_for_for_stage_0 & while_for_for_for_acc_2_itm_32_1
          & (fsm_output[7]);
      reg_sync12_sync_out_mioi_oswt_cse <= fsm_output[8];
      exit_while_for_for_sva <= ~ z_out_32;
      while_for_for_for_for_asn_itm_1 <= ping_pong_lpi_3;
      while_for_for_for_asn_1_itm_1 <= ~ while_for_for_for_acc_2_itm_32_1;
      while_for_for_for_stage_0_2 <= while_for_for_for_stage_0 & (fsm_output[7]);
    end
  end
  always @(posedge clk) begin
    if ( load_wen ) begin
      while_for_len_mul_cmp_a <= conf1_Pop_mio_mrgout_dat_sva_mx0_95_32[31:0];
      while_for_len_mul_cmp_b <= conf1_Pop_mio_mrgout_dat_sva_mx0_95_32[63:32];
      while_for_for_for_i_10_1_sva <= MUX_v_10_2_2(10'b0000000000, while_for_for_for_i_10_1_sva_mx1,
          (fsm_output[7]));
      while_for_for_for_mux_1_itm_1 <= nl_while_for_for_for_mux_1_itm_1[9:0];
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_and_cse ) begin
      reg_dma_read_ctrl_Push_mioi_idat_37_32_cse <= MUX_v_6_2_2(6'b000000, (while_for_len_acc_psp_sva[5:0]),
          while_for_for_len1_not_4_nl);
      reg_dma_read_ctrl_Push_mioi_idat_62_38_cse <= MUX_v_25_2_2(25'b0000000000000000000000101,
          while_for_for_rem_31_7_sva, and_100_nl);
      dma_read_ctrl_Push_mioi_idat_30_0 <= while_offset_31_1_lpi_3;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      ping_pong_sva <= 1'b0;
    end
    else if ( load_wen & (fsm_output[10]) ) begin
      ping_pong_sva <= ping_pong_lpi_3;
    end
  end
  always @(posedge clk) begin
    if ( load_wen & (~ and_dcpl_3) ) begin
      conf1_Pop_mio_mrgout_dat_sva <= conf1_Pop_mioi_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( load_wen & ((fsm_output[1]) | (fsm_output[10])) ) begin
      while_for_b_sva <= MUX_v_16_2_2(16'b0000000000000000, while_for_b_sva_2, (fsm_output[10]));
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      ping_pong_lpi_3 <= 1'b0;
    end
    else if ( load_wen & ((~(((while_for_for_for_stage_0_2 | while_for_for_for_stage_0)
        & (fsm_output[7])) | (~((fsm_output[7]) | (fsm_output[0]))))) | (fsm_output[1]))
        ) begin
      ping_pong_lpi_3 <= MUX_s_1_2_2(ping_pong_sva, (~ ping_pong_lpi_3), and_153_nl);
    end
  end
  always @(posedge clk) begin
    if ( load_wen & ((fsm_output[8]) | (fsm_output[1]) | (fsm_output[0])) ) begin
      while_offset_31_1_lpi_3 <= MUX_v_31_2_2(31'b0000000000000000000000000000000,
          while_for_for_acc_3_nl, (fsm_output[8]));
    end
  end
  always @(posedge clk) begin
    if ( load_wen & (~((~((fsm_output[3]) | (fsm_output[2]) | (fsm_output[10])))
        & and_dcpl_3)) ) begin
      while_for_len_acc_psp_sva <= nl_while_for_len_acc_psp_sva[30:0];
    end
  end
  always @(posedge clk) begin
    if ( load_wen & (~((fsm_output[9]) | (fsm_output[6]) | (fsm_output[5]) | (fsm_output[7])))
        ) begin
      while_for_for_rem_31_7_sva <= MUX_v_25_2_2((while_for_len_acc_psp_sva[30:6]),
          while_for_for_rem_31_7_sva_4, fsm_output[8]);
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_0 <= 1'b0;
    end
    else if ( load_wen & (~(((~ while_for_for_for_stage_0) | while_for_for_for_acc_2_itm_32_1)
        & (fsm_output[7]))) ) begin
      while_for_for_for_stage_0 <= ~ (fsm_output[7]);
    end
  end
  assign nl_while_for_for_for_mux_1_itm_1  = while_for_for_for_i_10_1_sva_mx1 + 10'b0000000001;
  assign while_for_for_len1_not_4_nl = ~ while_for_for_len1_acc_itm_32_1;
  assign and_100_nl = (~ while_for_for_len1_acc_itm_32_1) & (fsm_output[5]);
  assign and_153_nl = and_dcpl_7 & (fsm_output[7]);
  assign nl_while_for_for_acc_3_nl = while_offset_31_1_lpi_3 + ({reg_dma_read_ctrl_Push_mioi_idat_62_38_cse
      , reg_dma_read_ctrl_Push_mioi_idat_37_32_cse});
  assign while_for_for_acc_3_nl = nl_while_for_for_acc_3_nl[30:0];
  assign nl_while_for_len_acc_1_nl = while_for_len_mul_cmp_z_oreg + 32'b11111111111111111111111111111111;
  assign while_for_len_acc_1_nl = nl_while_for_len_acc_1_nl[31:0];
  assign nl_while_for_len_acc_psp_sva  = (readslicef_32_31_1(while_for_len_acc_1_nl))
      + 31'b0000000000000000000000000000001;
  assign while_for_for_mux_nl = MUX_v_25_2_2((~ while_for_for_rem_31_7_sva_4), (~
      (while_for_len_acc_psp_sva[30:6])), fsm_output[4]);
  assign nl_while_for_for_acc_rg_1_nl = conv_s2u_32_33({while_for_for_mux_nl , (~
      (while_for_len_acc_psp_sva[5:0])) , 1'b1}) + 33'b000000000000000000000000000000001;
  assign while_for_for_acc_rg_1_nl = nl_while_for_for_acc_rg_1_nl[32:0];
  assign z_out_32 = readslicef_33_1_32(while_for_for_acc_rg_1_nl);

  function automatic  MUX1HOT_s_1_1_2;
    input  input_0;
    input  sel;
    reg  result;
  begin
    result = input_0 & sel;
    MUX1HOT_s_1_1_2 = result;
  end
  endfunction


  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [9:0] MUX_v_10_2_2;
    input [9:0] input_0;
    input [9:0] input_1;
    input  sel;
    reg [9:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_10_2_2 = result;
  end
  endfunction


  function automatic [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input  sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction


  function automatic [24:0] MUX_v_25_2_2;
    input [24:0] input_0;
    input [24:0] input_1;
    input  sel;
    reg [24:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_25_2_2 = result;
  end
  endfunction


  function automatic [30:0] MUX_v_31_2_2;
    input [30:0] input_0;
    input [30:0] input_1;
    input  sel;
    reg [30:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_31_2_2 = result;
  end
  endfunction


  function automatic [63:0] MUX_v_64_2_2;
    input [63:0] input_0;
    input [63:0] input_1;
    input  sel;
    reg [63:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_64_2_2 = result;
  end
  endfunction


  function automatic [5:0] MUX_v_6_2_2;
    input [5:0] input_0;
    input [5:0] input_1;
    input  sel;
    reg [5:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_6_2_2 = result;
  end
  endfunction


  function automatic [30:0] readslicef_32_31_1;
    input [31:0] vector;
    reg [31:0] tmp;
  begin
    tmp = vector >> 1;
    readslicef_32_31_1 = tmp[30:0];
  end
  endfunction


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [0:0] readslicef_4_1_3;
    input [3:0] vector;
    reg [3:0] tmp;
  begin
    tmp = vector >> 3;
    readslicef_4_1_3 = tmp[0:0];
  end
  endfunction


  function automatic [32:0] conv_s2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_s2u_32_33 = {vector[31], vector};
  end
  endfunction


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config_config
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config_config (
  clk, rst, conf_info_val, conf_info_rdy, conf_info_msg, conf_info_out_val, conf_info_out_rdy,
      conf_info_out_msg, sync00_val, sync00_rdy, sync00_msg, sync01_val, sync01_rdy,
      sync01_msg, sync02_val, sync02_rdy, sync02_msg, sync03_val, sync03_rdy, sync03_msg,
      conf1_val, conf1_rdy, conf1_msg, conf2_val, conf2_rdy, conf2_msg, conf3_val,
      conf3_rdy, conf3_msg
);
  input clk;
  input rst;
  input conf_info_val;
  output conf_info_rdy;
  input [95:0] conf_info_msg;
  output conf_info_out_val;
  input conf_info_out_rdy;
  output [95:0] conf_info_out_msg;
  output sync00_val;
  input sync00_rdy;
  output sync00_msg;
  output sync01_val;
  input sync01_rdy;
  output sync01_msg;
  output sync02_val;
  input sync02_rdy;
  output sync02_msg;
  output sync03_val;
  input sync03_rdy;
  output sync03_msg;
  output conf1_val;
  input conf1_rdy;
  output [95:0] conf1_msg;
  output conf2_val;
  input conf2_rdy;
  output [95:0] conf2_msg;
  output conf3_val;
  input conf3_rdy;
  output [95:0] conf3_msg;


  // Interconnect Declarations
  reg config_wen;
  wire conf_info_Pop_mioi_wen_comp;
  wire [95:0] conf_info_Pop_mioi_idat_mxwt;
  wire conf_info_out_Push_mioi_wen_comp;
  wire conf_info_out_Push_mioi_irdy;
  wire conf_info_out_Push_mioi_irdy_oreg;
  wire conf1_Push_mioi_wen_comp;
  wire conf1_Push_mioi_irdy;
  wire conf1_Push_mioi_irdy_oreg;
  wire conf2_Push_mioi_wen_comp;
  wire conf2_Push_mioi_irdy;
  wire conf2_Push_mioi_irdy_oreg;
  wire conf3_Push_mioi_wen_comp;
  wire conf3_Push_mioi_irdy;
  wire conf3_Push_mioi_irdy_oreg;
  wire sync00_Push_mioi_wen_comp;
  wire sync00_Push_mioi_irdy;
  wire sync00_Push_mioi_irdy_oreg;
  wire sync01_Push_mioi_wen_comp;
  wire sync01_Push_mioi_irdy;
  wire sync01_Push_mioi_irdy_oreg;
  wire sync02_Push_mioi_wen_comp;
  wire sync02_Push_mioi_irdy;
  wire sync02_Push_mioi_irdy_oreg;
  wire sync03_Push_mioi_wen_comp;
  wire sync03_Push_mioi_irdy;
  wire sync03_Push_mioi_irdy_oreg;
  wire [2:0] fsm_output;
  reg [95:0] reg_conf_info_out_Push_mioi_idat_cse;
  wire config_wen_rtff;
  reg reg_conf_info_Pop_mioi_oswt_tmp;
  reg reg_conf_info_out_Push_mioi_oswt_tmp;
  wire while_mux_rmff;
  wire while_mux_4_rmff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_config_config_conf_info_Pop_mioi Ctrl_config_config_conf_info_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_val(conf_info_val),
      .conf_info_rdy(conf_info_rdy),
      .conf_info_msg(conf_info_msg),
      .conf_info_Pop_mioi_oswt(reg_conf_info_Pop_mioi_oswt_tmp),
      .conf_info_Pop_mioi_wen_comp(conf_info_Pop_mioi_wen_comp),
      .conf_info_Pop_mioi_idat_mxwt(conf_info_Pop_mioi_idat_mxwt),
      .conf_info_Pop_mioi_oswt_pff(while_mux_rmff)
    );
  esp_acc_DUMMY_Ctrl_config_config_wait_dp Ctrl_config_config_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_out_Push_mioi_irdy(conf_info_out_Push_mioi_irdy),
      .conf_info_out_Push_mioi_irdy_oreg(conf_info_out_Push_mioi_irdy_oreg),
      .conf1_Push_mioi_irdy(conf1_Push_mioi_irdy),
      .conf1_Push_mioi_irdy_oreg(conf1_Push_mioi_irdy_oreg),
      .conf2_Push_mioi_irdy(conf2_Push_mioi_irdy),
      .conf2_Push_mioi_irdy_oreg(conf2_Push_mioi_irdy_oreg),
      .conf3_Push_mioi_irdy(conf3_Push_mioi_irdy),
      .conf3_Push_mioi_irdy_oreg(conf3_Push_mioi_irdy_oreg),
      .sync00_Push_mioi_irdy(sync00_Push_mioi_irdy),
      .sync00_Push_mioi_irdy_oreg(sync00_Push_mioi_irdy_oreg),
      .sync01_Push_mioi_irdy(sync01_Push_mioi_irdy),
      .sync01_Push_mioi_irdy_oreg(sync01_Push_mioi_irdy_oreg),
      .sync02_Push_mioi_irdy(sync02_Push_mioi_irdy),
      .sync02_Push_mioi_irdy_oreg(sync02_Push_mioi_irdy_oreg),
      .sync03_Push_mioi_irdy(sync03_Push_mioi_irdy),
      .sync03_Push_mioi_irdy_oreg(sync03_Push_mioi_irdy_oreg)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf_info_out_Push_mioi Ctrl_config_config_conf_info_out_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_out_val(conf_info_out_val),
      .conf_info_out_rdy(conf_info_out_rdy),
      .conf_info_out_msg(conf_info_out_msg),
      .config_wen(config_wen),
      .conf_info_out_Push_mioi_oswt(reg_conf_info_out_Push_mioi_oswt_tmp),
      .conf_info_out_Push_mioi_wen_comp(conf_info_out_Push_mioi_wen_comp),
      .conf_info_out_Push_mioi_idat(reg_conf_info_out_Push_mioi_idat_cse),
      .conf_info_out_Push_mioi_irdy(conf_info_out_Push_mioi_irdy),
      .conf_info_out_Push_mioi_irdy_oreg(conf_info_out_Push_mioi_irdy_oreg),
      .conf_info_out_Push_mioi_oswt_pff(while_mux_4_rmff),
      .conf_info_out_Push_mioi_irdy_oreg_pff(conf_info_out_Push_mioi_irdy)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf1_Push_mioi Ctrl_config_config_conf1_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf1_val(conf1_val),
      .conf1_rdy(conf1_rdy),
      .conf1_msg(conf1_msg),
      .config_wen(config_wen),
      .conf1_Push_mioi_oswt(reg_conf_info_out_Push_mioi_oswt_tmp),
      .conf1_Push_mioi_wen_comp(conf1_Push_mioi_wen_comp),
      .conf1_Push_mioi_idat(reg_conf_info_out_Push_mioi_idat_cse),
      .conf1_Push_mioi_irdy(conf1_Push_mioi_irdy),
      .conf1_Push_mioi_irdy_oreg(conf1_Push_mioi_irdy_oreg),
      .conf1_Push_mioi_oswt_pff(while_mux_4_rmff),
      .conf1_Push_mioi_irdy_oreg_pff(conf1_Push_mioi_irdy)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf2_Push_mioi Ctrl_config_config_conf2_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf2_val(conf2_val),
      .conf2_rdy(conf2_rdy),
      .conf2_msg(conf2_msg),
      .config_wen(config_wen),
      .conf2_Push_mioi_oswt(reg_conf_info_out_Push_mioi_oswt_tmp),
      .conf2_Push_mioi_wen_comp(conf2_Push_mioi_wen_comp),
      .conf2_Push_mioi_idat(reg_conf_info_out_Push_mioi_idat_cse),
      .conf2_Push_mioi_irdy(conf2_Push_mioi_irdy),
      .conf2_Push_mioi_irdy_oreg(conf2_Push_mioi_irdy_oreg),
      .conf2_Push_mioi_oswt_pff(while_mux_4_rmff),
      .conf2_Push_mioi_irdy_oreg_pff(conf2_Push_mioi_irdy)
    );
  esp_acc_DUMMY_Ctrl_config_config_conf3_Push_mioi Ctrl_config_config_conf3_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf3_val(conf3_val),
      .conf3_rdy(conf3_rdy),
      .conf3_msg(conf3_msg),
      .config_wen(config_wen),
      .conf3_Push_mioi_oswt(reg_conf_info_out_Push_mioi_oswt_tmp),
      .conf3_Push_mioi_wen_comp(conf3_Push_mioi_wen_comp),
      .conf3_Push_mioi_idat(reg_conf_info_out_Push_mioi_idat_cse),
      .conf3_Push_mioi_irdy(conf3_Push_mioi_irdy),
      .conf3_Push_mioi_irdy_oreg(conf3_Push_mioi_irdy_oreg),
      .conf3_Push_mioi_oswt_pff(while_mux_4_rmff),
      .conf3_Push_mioi_irdy_oreg_pff(conf3_Push_mioi_irdy)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync00_Push_mioi Ctrl_config_config_sync00_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync00_val(sync00_val),
      .sync00_rdy(sync00_rdy),
      .sync00_msg(sync00_msg),
      .config_wen(config_wen),
      .sync00_Push_mioi_oswt(reg_conf_info_out_Push_mioi_oswt_tmp),
      .sync00_Push_mioi_wen_comp(sync00_Push_mioi_wen_comp),
      .sync00_Push_mioi_irdy(sync00_Push_mioi_irdy),
      .sync00_Push_mioi_irdy_oreg(sync00_Push_mioi_irdy_oreg),
      .sync00_Push_mioi_oswt_pff(while_mux_4_rmff),
      .sync00_Push_mioi_irdy_oreg_pff(sync00_Push_mioi_irdy)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync01_Push_mioi Ctrl_config_config_sync01_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync01_val(sync01_val),
      .sync01_rdy(sync01_rdy),
      .sync01_msg(sync01_msg),
      .config_wen(config_wen),
      .sync01_Push_mioi_oswt(reg_conf_info_out_Push_mioi_oswt_tmp),
      .sync01_Push_mioi_wen_comp(sync01_Push_mioi_wen_comp),
      .sync01_Push_mioi_irdy(sync01_Push_mioi_irdy),
      .sync01_Push_mioi_irdy_oreg(sync01_Push_mioi_irdy_oreg),
      .sync01_Push_mioi_oswt_pff(while_mux_4_rmff),
      .sync01_Push_mioi_irdy_oreg_pff(sync01_Push_mioi_irdy)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync02_Push_mioi Ctrl_config_config_sync02_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync02_val(sync02_val),
      .sync02_rdy(sync02_rdy),
      .sync02_msg(sync02_msg),
      .config_wen(config_wen),
      .sync02_Push_mioi_oswt(reg_conf_info_out_Push_mioi_oswt_tmp),
      .sync02_Push_mioi_wen_comp(sync02_Push_mioi_wen_comp),
      .sync02_Push_mioi_irdy(sync02_Push_mioi_irdy),
      .sync02_Push_mioi_irdy_oreg(sync02_Push_mioi_irdy_oreg),
      .sync02_Push_mioi_oswt_pff(while_mux_4_rmff),
      .sync02_Push_mioi_irdy_oreg_pff(sync02_Push_mioi_irdy)
    );
  esp_acc_DUMMY_Ctrl_config_config_sync03_Push_mioi Ctrl_config_config_sync03_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync03_val(sync03_val),
      .sync03_rdy(sync03_rdy),
      .sync03_msg(sync03_msg),
      .config_wen(config_wen),
      .sync03_Push_mioi_oswt(reg_conf_info_out_Push_mioi_oswt_tmp),
      .sync03_Push_mioi_wen_comp(sync03_Push_mioi_wen_comp),
      .sync03_Push_mioi_irdy(sync03_Push_mioi_irdy),
      .sync03_Push_mioi_irdy_oreg(sync03_Push_mioi_irdy_oreg),
      .sync03_Push_mioi_oswt_pff(while_mux_4_rmff),
      .sync03_Push_mioi_irdy_oreg_pff(sync03_Push_mioi_irdy)
    );
  esp_acc_DUMMY_Ctrl_config_config_staller Ctrl_config_config_staller_inst (
      .config_wen(config_wen_rtff),
      .conf_info_Pop_mioi_wen_comp(conf_info_Pop_mioi_wen_comp),
      .conf_info_out_Push_mioi_wen_comp(conf_info_out_Push_mioi_wen_comp),
      .conf1_Push_mioi_wen_comp(conf1_Push_mioi_wen_comp),
      .conf2_Push_mioi_wen_comp(conf2_Push_mioi_wen_comp),
      .conf3_Push_mioi_wen_comp(conf3_Push_mioi_wen_comp),
      .sync00_Push_mioi_wen_comp(sync00_Push_mioi_wen_comp),
      .sync01_Push_mioi_wen_comp(sync01_Push_mioi_wen_comp),
      .sync02_Push_mioi_wen_comp(sync02_Push_mioi_wen_comp),
      .sync03_Push_mioi_wen_comp(sync03_Push_mioi_wen_comp)
    );
  esp_acc_DUMMY_Ctrl_config_config_config_fsm Ctrl_config_config_config_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .config_wen(config_wen),
      .fsm_output(fsm_output)
    );
  assign while_mux_rmff = MUX_s_1_2_2(reg_conf_info_Pop_mioi_oswt_tmp, (~ (fsm_output[1])),
      config_wen);
  assign while_mux_4_rmff = MUX_s_1_2_2(reg_conf_info_out_Push_mioi_oswt_tmp, (fsm_output[1]),
      config_wen);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      reg_conf_info_Pop_mioi_oswt_tmp <= 1'b0;
      reg_conf_info_out_Push_mioi_oswt_tmp <= 1'b0;
      config_wen <= 1'b1;
    end
    else begin
      reg_conf_info_Pop_mioi_oswt_tmp <= while_mux_rmff;
      reg_conf_info_out_Push_mioi_oswt_tmp <= while_mux_4_rmff;
      config_wen <= config_wen_rtff;
    end
  end
  always @(posedge clk) begin
    if ( config_wen & (fsm_output[1]) ) begin
      reg_conf_info_out_Push_mioi_idat_cse <= conf_info_Pop_mioi_idat_mxwt;
    end
  end

  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_store
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_store (
  clk, rst, acc_done, dma_write_chnl_val, dma_write_chnl_rdy, dma_write_chnl_msg,
      dma_write_ctrl_val, dma_write_ctrl_rdy, dma_write_ctrl_msg, sync23_vld, sync23_rdy,
      sync03_val, sync03_rdy, sync03_msg, conf3_val, conf3_rdy, conf3_msg, plm_out_ping_a0_a_d_data_rsc_qout,
      plm_out_ping_a0_a_d_data_rsc_r_adr, plm_out_ping_a1_a_d_data_rsc_qout, plm_out_ping_a1_a_d_data_rsc_r_adr,
      plm_out_pong_a0_a_d_data_rsc_qout, plm_out_pong_a0_a_d_data_rsc_r_adr, plm_out_pong_a1_a_d_data_rsc_qout,
      plm_out_pong_a1_a_d_data_rsc_r_adr
);
  input clk;
  input rst;
  output acc_done;
  output dma_write_chnl_val;
  input dma_write_chnl_rdy;
  output [63:0] dma_write_chnl_msg;
  output dma_write_ctrl_val;
  input dma_write_ctrl_rdy;
  output [72:0] dma_write_ctrl_msg;
  input sync23_vld;
  output sync23_rdy;
  input sync03_val;
  output sync03_rdy;
  input sync03_msg;
  input conf3_val;
  output conf3_rdy;
  input [95:0] conf3_msg;
  input [31:0] plm_out_ping_a0_a_d_data_rsc_qout;
  output [4:0] plm_out_ping_a0_a_d_data_rsc_r_adr;
  input [31:0] plm_out_ping_a1_a_d_data_rsc_qout;
  output [4:0] plm_out_ping_a1_a_d_data_rsc_r_adr;
  input [31:0] plm_out_pong_a0_a_d_data_rsc_qout;
  output [4:0] plm_out_pong_a0_a_d_data_rsc_r_adr;
  input [31:0] plm_out_pong_a1_a_d_data_rsc_qout;
  output [4:0] plm_out_pong_a1_a_d_data_rsc_r_adr;


  // Interconnect Declarations
  wire [31:0] plm_out_ping_a0_a_d_data_rsci_qout_d;
  wire plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_out_ping_a1_a_d_data_rsci_qout_d;
  wire plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_out_pong_a0_a_d_data_rsci_qout_d;
  wire plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_out_pong_a1_a_d_data_rsci_qout_d;
  wire plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] while_store_offset_mul_1_cmp_a;
  wire [31:0] while_store_offset_mul_1_cmp_b;
  wire [4:0] plm_out_ping_a0_a_d_data_rsci_r_adr_d_iff;


  // Interconnect Declarations for Component Instantiations 
  wire [63:0] nl_Ctrl_store_store_inst_while_store_offset_mul_1_cmp_z;
  assign nl_Ctrl_store_store_inst_while_store_offset_mul_1_cmp_z = while_store_offset_mul_1_cmp_a
      * while_store_offset_mul_1_cmp_b;
  esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_96_5_32_32_32_32_gen
      plm_out_ping_a0_a_d_data_rsci (
      .r_adr(plm_out_ping_a0_a_d_data_rsc_r_adr),
      .qout(plm_out_ping_a0_a_d_data_rsc_qout),
      .qout_d(plm_out_ping_a0_a_d_data_rsci_qout_d),
      .r_adr_d(plm_out_ping_a0_a_d_data_rsci_r_adr_d_iff),
      .port_0_r_ram_ir_internal_RMASK_B_d(plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_97_5_32_32_32_32_gen
      plm_out_ping_a1_a_d_data_rsci (
      .r_adr(plm_out_ping_a1_a_d_data_rsc_r_adr),
      .qout(plm_out_ping_a1_a_d_data_rsc_qout),
      .qout_d(plm_out_ping_a1_a_d_data_rsci_qout_d),
      .r_adr_d(plm_out_ping_a0_a_d_data_rsci_r_adr_d_iff),
      .port_0_r_ram_ir_internal_RMASK_B_d(plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_98_5_32_32_32_32_gen
      plm_out_pong_a0_a_d_data_rsci (
      .r_adr(plm_out_pong_a0_a_d_data_rsc_r_adr),
      .qout(plm_out_pong_a0_a_d_data_rsc_qout),
      .qout_d(plm_out_pong_a0_a_d_data_rsci_qout_d),
      .r_adr_d(plm_out_ping_a0_a_d_data_rsci_r_adr_d_iff),
      .port_0_r_ram_ir_internal_RMASK_B_d(plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_DUMMY_Ctrl_store_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_99_5_32_32_32_32_gen
      plm_out_pong_a1_a_d_data_rsci (
      .r_adr(plm_out_pong_a1_a_d_data_rsc_r_adr),
      .qout(plm_out_pong_a1_a_d_data_rsc_qout),
      .qout_d(plm_out_pong_a1_a_d_data_rsci_qout_d),
      .r_adr_d(plm_out_ping_a0_a_d_data_rsci_r_adr_d_iff),
      .port_0_r_ram_ir_internal_RMASK_B_d(plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_DUMMY_Ctrl_store_store Ctrl_store_store_inst (
      .clk(clk),
      .rst(rst),
      .acc_done(acc_done),
      .dma_write_chnl_val(dma_write_chnl_val),
      .dma_write_chnl_rdy(dma_write_chnl_rdy),
      .dma_write_chnl_msg(dma_write_chnl_msg),
      .dma_write_ctrl_val(dma_write_ctrl_val),
      .dma_write_ctrl_rdy(dma_write_ctrl_rdy),
      .dma_write_ctrl_msg(dma_write_ctrl_msg),
      .sync23_vld(sync23_vld),
      .sync23_rdy(sync23_rdy),
      .sync03_val(sync03_val),
      .sync03_rdy(sync03_rdy),
      .sync03_msg(sync03_msg),
      .conf3_val(conf3_val),
      .conf3_rdy(conf3_rdy),
      .conf3_msg(conf3_msg),
      .plm_out_ping_a0_a_d_data_rsci_qout_d(plm_out_ping_a0_a_d_data_rsci_qout_d),
      .plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_out_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d),
      .plm_out_ping_a1_a_d_data_rsci_qout_d(plm_out_ping_a1_a_d_data_rsci_qout_d),
      .plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_out_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d),
      .plm_out_pong_a0_a_d_data_rsci_qout_d(plm_out_pong_a0_a_d_data_rsci_qout_d),
      .plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_out_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d),
      .plm_out_pong_a1_a_d_data_rsci_qout_d(plm_out_pong_a1_a_d_data_rsci_qout_d),
      .plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_out_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d),
      .while_store_offset_mul_1_cmp_a(while_store_offset_mul_1_cmp_a),
      .while_store_offset_mul_1_cmp_b(while_store_offset_mul_1_cmp_b),
      .while_store_offset_mul_1_cmp_z(nl_Ctrl_store_store_inst_while_store_offset_mul_1_cmp_z[31:0]),
      .plm_out_ping_a0_a_d_data_rsci_r_adr_d_pff(plm_out_ping_a0_a_d_data_rsci_r_adr_d_iff)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_compute
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_compute (
  clk, rst, in_wr_req_val, in_wr_req_rdy, in_wr_req_msg, in_rd_rsp_val, in_rd_rsp_rdy,
      in_rd_rsp_msg, sync12_vld, sync12_rdy, sync23_vld, sync23_rdy, sync02_val,
      sync02_rdy, sync02_msg, conf2_val, conf2_rdy, conf2_msg, plm_in_ping_a0_a_d_data_rsc_qout,
      plm_in_ping_a0_a_d_data_rsc_r_adr, plm_in_ping_a1_a_d_data_rsc_qout, plm_in_ping_a1_a_d_data_rsc_r_adr,
      plm_in_pong_a0_a_d_data_rsc_qout, plm_in_pong_a0_a_d_data_rsc_r_adr, plm_in_pong_a1_a_d_data_rsc_qout,
      plm_in_pong_a1_a_d_data_rsc_r_adr, plm_out_ping_a0_a_d_data_rsc_din, plm_out_ping_a0_a_d_data_rsc_w_adr,
      plm_out_ping_a0_a_d_data_rsc_w_en, plm_out_ping_a1_a_d_data_rsc_din, plm_out_ping_a1_a_d_data_rsc_w_adr,
      plm_out_ping_a1_a_d_data_rsc_w_en, plm_out_pong_a0_a_d_data_rsc_din, plm_out_pong_a0_a_d_data_rsc_w_adr,
      plm_out_pong_a0_a_d_data_rsc_w_en, plm_out_pong_a1_a_d_data_rsc_din, plm_out_pong_a1_a_d_data_rsc_w_adr,
      plm_out_pong_a1_a_d_data_rsc_w_en
);
  input clk;
  input rst;
  input in_wr_req_val;
  output in_wr_req_rdy;
  input [31:0] in_wr_req_msg;
  output in_rd_rsp_val;
  input in_rd_rsp_rdy;
  output [63:0] in_rd_rsp_msg;
  input sync12_vld;
  output sync12_rdy;
  output sync23_vld;
  input sync23_rdy;
  input sync02_val;
  output sync02_rdy;
  input sync02_msg;
  input conf2_val;
  output conf2_rdy;
  input [95:0] conf2_msg;
  input [31:0] plm_in_ping_a0_a_d_data_rsc_qout;
  output [8:0] plm_in_ping_a0_a_d_data_rsc_r_adr;
  input [31:0] plm_in_ping_a1_a_d_data_rsc_qout;
  output [8:0] plm_in_ping_a1_a_d_data_rsc_r_adr;
  input [31:0] plm_in_pong_a0_a_d_data_rsc_qout;
  output [8:0] plm_in_pong_a0_a_d_data_rsc_r_adr;
  input [31:0] plm_in_pong_a1_a_d_data_rsc_qout;
  output [8:0] plm_in_pong_a1_a_d_data_rsc_r_adr;
  output [31:0] plm_out_ping_a0_a_d_data_rsc_din;
  output [4:0] plm_out_ping_a0_a_d_data_rsc_w_adr;
  output plm_out_ping_a0_a_d_data_rsc_w_en;
  output [31:0] plm_out_ping_a1_a_d_data_rsc_din;
  output [4:0] plm_out_ping_a1_a_d_data_rsc_w_adr;
  output plm_out_ping_a1_a_d_data_rsc_w_en;
  output [31:0] plm_out_pong_a0_a_d_data_rsc_din;
  output [4:0] plm_out_pong_a0_a_d_data_rsc_w_adr;
  output plm_out_pong_a0_a_d_data_rsc_w_en;
  output [31:0] plm_out_pong_a1_a_d_data_rsc_din;
  output [4:0] plm_out_pong_a1_a_d_data_rsc_w_adr;
  output plm_out_pong_a1_a_d_data_rsc_w_en;


  // Interconnect Declarations
  wire [31:0] plm_in_ping_a0_a_d_data_rsci_qout_d;
  wire [8:0] plm_in_ping_a0_a_d_data_rsci_r_adr_d;
  wire plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_in_ping_a1_a_d_data_rsci_qout_d;
  wire [8:0] plm_in_ping_a1_a_d_data_rsci_r_adr_d;
  wire plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_in_pong_a0_a_d_data_rsci_qout_d;
  wire [8:0] plm_in_pong_a0_a_d_data_rsci_r_adr_d;
  wire plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_in_pong_a1_a_d_data_rsci_qout_d;
  wire [8:0] plm_in_pong_a1_a_d_data_rsci_r_adr_d;
  wire plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_out_ping_a0_a_d_data_rsci_din_d;
  wire [4:0] plm_out_ping_a0_a_d_data_rsci_w_adr_d;
  wire [31:0] plm_out_ping_a1_a_d_data_rsci_din_d;
  wire [4:0] plm_out_ping_a1_a_d_data_rsci_w_adr_d;
  wire [31:0] plm_out_pong_a0_a_d_data_rsci_din_d;
  wire [4:0] plm_out_pong_a0_a_d_data_rsci_w_adr_d;
  wire [31:0] plm_out_pong_a1_a_d_data_rsci_din_d;
  wire [4:0] plm_out_pong_a1_a_d_data_rsci_w_adr_d;
  wire [31:0] while_for_in_length_mul_cmp_a;
  wire [31:0] while_for_in_length_mul_cmp_b;
  wire plm_out_ping_a0_a_d_data_rsci_w_en_d_iff;
  wire plm_out_ping_a1_a_d_data_rsci_w_en_d_iff;
  wire plm_out_pong_a0_a_d_data_rsci_w_en_d_iff;
  wire plm_out_pong_a1_a_d_data_rsci_w_en_d_iff;


  // Interconnect Declarations for Component Instantiations 
  wire [63:0] nl_Ctrl_compute_compute_inst_while_for_in_length_mul_cmp_z;
  assign nl_Ctrl_compute_compute_inst_while_for_in_length_mul_cmp_z = while_for_in_length_mul_cmp_a
      * while_for_in_length_mul_cmp_b;
  esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_88_9_32_320_320_32_gen
      plm_in_ping_a0_a_d_data_rsci (
      .r_adr(plm_in_ping_a0_a_d_data_rsc_r_adr),
      .qout(plm_in_ping_a0_a_d_data_rsc_qout),
      .qout_d(plm_in_ping_a0_a_d_data_rsci_qout_d),
      .r_adr_d(plm_in_ping_a0_a_d_data_rsci_r_adr_d),
      .port_0_r_ram_ir_internal_RMASK_B_d(plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_89_9_32_320_320_32_gen
      plm_in_ping_a1_a_d_data_rsci (
      .r_adr(plm_in_ping_a1_a_d_data_rsc_r_adr),
      .qout(plm_in_ping_a1_a_d_data_rsc_qout),
      .qout_d(plm_in_ping_a1_a_d_data_rsci_qout_d),
      .r_adr_d(plm_in_ping_a1_a_d_data_rsci_r_adr_d),
      .port_0_r_ram_ir_internal_RMASK_B_d(plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_90_9_32_320_320_32_gen
      plm_in_pong_a0_a_d_data_rsci (
      .r_adr(plm_in_pong_a0_a_d_data_rsc_r_adr),
      .qout(plm_in_pong_a0_a_d_data_rsc_qout),
      .qout_d(plm_in_pong_a0_a_d_data_rsci_qout_d),
      .r_adr_d(plm_in_pong_a0_a_d_data_rsci_r_adr_d),
      .port_0_r_ram_ir_internal_RMASK_B_d(plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_rport_91_9_32_320_320_32_gen
      plm_in_pong_a1_a_d_data_rsci (
      .r_adr(plm_in_pong_a1_a_d_data_rsc_r_adr),
      .qout(plm_in_pong_a1_a_d_data_rsc_qout),
      .qout_d(plm_in_pong_a1_a_d_data_rsci_qout_d),
      .r_adr_d(plm_in_pong_a1_a_d_data_rsci_r_adr_d),
      .port_0_r_ram_ir_internal_RMASK_B_d(plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_92_5_32_32_32_32_gen
      plm_out_ping_a0_a_d_data_rsci (
      .w_en(plm_out_ping_a0_a_d_data_rsc_w_en),
      .w_adr(plm_out_ping_a0_a_d_data_rsc_w_adr),
      .din(plm_out_ping_a0_a_d_data_rsc_din),
      .din_d(plm_out_ping_a0_a_d_data_rsci_din_d),
      .w_adr_d(plm_out_ping_a0_a_d_data_rsci_w_adr_d),
      .w_en_d(plm_out_ping_a0_a_d_data_rsci_w_en_d_iff),
      .port_1_w_ram_ir_internal_WMASK_B_d(plm_out_ping_a0_a_d_data_rsci_w_en_d_iff)
    );
  esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_93_5_32_32_32_32_gen
      plm_out_ping_a1_a_d_data_rsci (
      .w_en(plm_out_ping_a1_a_d_data_rsc_w_en),
      .w_adr(plm_out_ping_a1_a_d_data_rsc_w_adr),
      .din(plm_out_ping_a1_a_d_data_rsc_din),
      .din_d(plm_out_ping_a1_a_d_data_rsci_din_d),
      .w_adr_d(plm_out_ping_a1_a_d_data_rsci_w_adr_d),
      .w_en_d(plm_out_ping_a1_a_d_data_rsci_w_en_d_iff),
      .port_1_w_ram_ir_internal_WMASK_B_d(plm_out_ping_a1_a_d_data_rsci_w_en_d_iff)
    );
  esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_94_5_32_32_32_32_gen
      plm_out_pong_a0_a_d_data_rsci (
      .w_en(plm_out_pong_a0_a_d_data_rsc_w_en),
      .w_adr(plm_out_pong_a0_a_d_data_rsc_w_adr),
      .din(plm_out_pong_a0_a_d_data_rsc_din),
      .din_d(plm_out_pong_a0_a_d_data_rsci_din_d),
      .w_adr_d(plm_out_pong_a0_a_d_data_rsci_w_adr_d),
      .w_en_d(plm_out_pong_a0_a_d_data_rsci_w_en_d_iff),
      .port_1_w_ram_ir_internal_WMASK_B_d(plm_out_pong_a0_a_d_data_rsci_w_en_d_iff)
    );
  esp_acc_DUMMY_Ctrl_compute_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_95_5_32_32_32_32_gen
      plm_out_pong_a1_a_d_data_rsci (
      .w_en(plm_out_pong_a1_a_d_data_rsc_w_en),
      .w_adr(plm_out_pong_a1_a_d_data_rsc_w_adr),
      .din(plm_out_pong_a1_a_d_data_rsc_din),
      .din_d(plm_out_pong_a1_a_d_data_rsci_din_d),
      .w_adr_d(plm_out_pong_a1_a_d_data_rsci_w_adr_d),
      .w_en_d(plm_out_pong_a1_a_d_data_rsci_w_en_d_iff),
      .port_1_w_ram_ir_internal_WMASK_B_d(plm_out_pong_a1_a_d_data_rsci_w_en_d_iff)
    );
  esp_acc_DUMMY_Ctrl_compute_compute Ctrl_compute_compute_inst (
      .clk(clk),
      .rst(rst),
      .in_wr_req_val(in_wr_req_val),
      .in_wr_req_rdy(in_wr_req_rdy),
      .in_wr_req_msg(in_wr_req_msg),
      .in_rd_rsp_val(in_rd_rsp_val),
      .in_rd_rsp_rdy(in_rd_rsp_rdy),
      .in_rd_rsp_msg(in_rd_rsp_msg),
      .sync12_vld(sync12_vld),
      .sync12_rdy(sync12_rdy),
      .sync23_vld(sync23_vld),
      .sync23_rdy(sync23_rdy),
      .sync02_val(sync02_val),
      .sync02_rdy(sync02_rdy),
      .sync02_msg(sync02_msg),
      .conf2_val(conf2_val),
      .conf2_rdy(conf2_rdy),
      .conf2_msg(conf2_msg),
      .plm_in_ping_a0_a_d_data_rsci_qout_d(plm_in_ping_a0_a_d_data_rsci_qout_d),
      .plm_in_ping_a0_a_d_data_rsci_r_adr_d(plm_in_ping_a0_a_d_data_rsci_r_adr_d),
      .plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_in_ping_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d),
      .plm_in_ping_a1_a_d_data_rsci_qout_d(plm_in_ping_a1_a_d_data_rsci_qout_d),
      .plm_in_ping_a1_a_d_data_rsci_r_adr_d(plm_in_ping_a1_a_d_data_rsci_r_adr_d),
      .plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_in_ping_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d),
      .plm_in_pong_a0_a_d_data_rsci_qout_d(plm_in_pong_a0_a_d_data_rsci_qout_d),
      .plm_in_pong_a0_a_d_data_rsci_r_adr_d(plm_in_pong_a0_a_d_data_rsci_r_adr_d),
      .plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_in_pong_a0_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d),
      .plm_in_pong_a1_a_d_data_rsci_qout_d(plm_in_pong_a1_a_d_data_rsci_qout_d),
      .plm_in_pong_a1_a_d_data_rsci_r_adr_d(plm_in_pong_a1_a_d_data_rsci_r_adr_d),
      .plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d(plm_in_pong_a1_a_d_data_rsci_port_0_r_ram_ir_internal_RMASK_B_d),
      .plm_out_ping_a0_a_d_data_rsci_din_d(plm_out_ping_a0_a_d_data_rsci_din_d),
      .plm_out_ping_a0_a_d_data_rsci_w_adr_d(plm_out_ping_a0_a_d_data_rsci_w_adr_d),
      .plm_out_ping_a1_a_d_data_rsci_din_d(plm_out_ping_a1_a_d_data_rsci_din_d),
      .plm_out_ping_a1_a_d_data_rsci_w_adr_d(plm_out_ping_a1_a_d_data_rsci_w_adr_d),
      .plm_out_pong_a0_a_d_data_rsci_din_d(plm_out_pong_a0_a_d_data_rsci_din_d),
      .plm_out_pong_a0_a_d_data_rsci_w_adr_d(plm_out_pong_a0_a_d_data_rsci_w_adr_d),
      .plm_out_pong_a1_a_d_data_rsci_din_d(plm_out_pong_a1_a_d_data_rsci_din_d),
      .plm_out_pong_a1_a_d_data_rsci_w_adr_d(plm_out_pong_a1_a_d_data_rsci_w_adr_d),
      .while_for_in_length_mul_cmp_a(while_for_in_length_mul_cmp_a),
      .while_for_in_length_mul_cmp_b(while_for_in_length_mul_cmp_b),
      .while_for_in_length_mul_cmp_z(nl_Ctrl_compute_compute_inst_while_for_in_length_mul_cmp_z[31:0]),
      .plm_out_ping_a0_a_d_data_rsci_w_en_d_pff(plm_out_ping_a0_a_d_data_rsci_w_en_d_iff),
      .plm_out_ping_a1_a_d_data_rsci_w_en_d_pff(plm_out_ping_a1_a_d_data_rsci_w_en_d_iff),
      .plm_out_pong_a0_a_d_data_rsci_w_en_d_pff(plm_out_pong_a0_a_d_data_rsci_w_en_d_iff),
      .plm_out_pong_a1_a_d_data_rsci_w_en_d_pff(plm_out_pong_a1_a_d_data_rsci_w_en_d_iff)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_load
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_load (
  clk, rst, dma_read_chnl_val, dma_read_chnl_rdy, dma_read_chnl_msg, dma_read_ctrl_val,
      dma_read_ctrl_rdy, dma_read_ctrl_msg, sync12_vld, sync12_rdy, sync01_val, sync01_rdy,
      sync01_msg, conf1_val, conf1_rdy, conf1_msg, plm_in_ping_a0_a_d_data_rsc_din,
      plm_in_ping_a0_a_d_data_rsc_w_adr, plm_in_ping_a0_a_d_data_rsc_w_en, plm_in_ping_a1_a_d_data_rsc_din,
      plm_in_ping_a1_a_d_data_rsc_w_adr, plm_in_ping_a1_a_d_data_rsc_w_en, plm_in_pong_a0_a_d_data_rsc_din,
      plm_in_pong_a0_a_d_data_rsc_w_adr, plm_in_pong_a0_a_d_data_rsc_w_en, plm_in_pong_a1_a_d_data_rsc_din,
      plm_in_pong_a1_a_d_data_rsc_w_adr, plm_in_pong_a1_a_d_data_rsc_w_en
);
  input clk;
  input rst;
  input dma_read_chnl_val;
  output dma_read_chnl_rdy;
  input [63:0] dma_read_chnl_msg;
  output dma_read_ctrl_val;
  input dma_read_ctrl_rdy;
  output [72:0] dma_read_ctrl_msg;
  output sync12_vld;
  input sync12_rdy;
  input sync01_val;
  output sync01_rdy;
  input sync01_msg;
  input conf1_val;
  output conf1_rdy;
  input [95:0] conf1_msg;
  output [31:0] plm_in_ping_a0_a_d_data_rsc_din;
  output [8:0] plm_in_ping_a0_a_d_data_rsc_w_adr;
  output plm_in_ping_a0_a_d_data_rsc_w_en;
  output [31:0] plm_in_ping_a1_a_d_data_rsc_din;
  output [8:0] plm_in_ping_a1_a_d_data_rsc_w_adr;
  output plm_in_ping_a1_a_d_data_rsc_w_en;
  output [31:0] plm_in_pong_a0_a_d_data_rsc_din;
  output [8:0] plm_in_pong_a0_a_d_data_rsc_w_adr;
  output plm_in_pong_a0_a_d_data_rsc_w_en;
  output [31:0] plm_in_pong_a1_a_d_data_rsc_din;
  output [8:0] plm_in_pong_a1_a_d_data_rsc_w_adr;
  output plm_in_pong_a1_a_d_data_rsc_w_en;


  // Interconnect Declarations
  wire [31:0] while_for_len_mul_cmp_a;
  wire [31:0] while_for_len_mul_cmp_b;
  wire [31:0] plm_in_ping_a0_a_d_data_rsci_din_d_iff;
  wire [8:0] plm_in_ping_a0_a_d_data_rsci_w_adr_d_iff;
  wire plm_in_ping_a0_a_d_data_rsci_w_en_d_iff;
  wire [31:0] plm_in_ping_a1_a_d_data_rsci_din_d_iff;
  wire plm_in_ping_a1_a_d_data_rsci_w_en_d_iff;
  wire plm_in_pong_a0_a_d_data_rsci_w_en_d_iff;
  wire plm_in_pong_a1_a_d_data_rsci_w_en_d_iff;


  // Interconnect Declarations for Component Instantiations 
  wire [63:0] nl_Ctrl_load_load_inst_while_for_len_mul_cmp_z;
  assign nl_Ctrl_load_load_inst_while_for_len_mul_cmp_z = while_for_len_mul_cmp_a
      * while_for_len_mul_cmp_b;
  esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_84_9_32_320_320_32_gen
      plm_in_ping_a0_a_d_data_rsci (
      .w_en(plm_in_ping_a0_a_d_data_rsc_w_en),
      .w_adr(plm_in_ping_a0_a_d_data_rsc_w_adr),
      .din(plm_in_ping_a0_a_d_data_rsc_din),
      .din_d(plm_in_ping_a0_a_d_data_rsci_din_d_iff),
      .w_adr_d(plm_in_ping_a0_a_d_data_rsci_w_adr_d_iff),
      .w_en_d(plm_in_ping_a0_a_d_data_rsci_w_en_d_iff),
      .port_1_w_ram_ir_internal_WMASK_B_d(plm_in_ping_a0_a_d_data_rsci_w_en_d_iff)
    );
  esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_85_9_32_320_320_32_gen
      plm_in_ping_a1_a_d_data_rsci (
      .w_en(plm_in_ping_a1_a_d_data_rsc_w_en),
      .w_adr(plm_in_ping_a1_a_d_data_rsc_w_adr),
      .din(plm_in_ping_a1_a_d_data_rsc_din),
      .din_d(plm_in_ping_a1_a_d_data_rsci_din_d_iff),
      .w_adr_d(plm_in_ping_a0_a_d_data_rsci_w_adr_d_iff),
      .w_en_d(plm_in_ping_a1_a_d_data_rsci_w_en_d_iff),
      .port_1_w_ram_ir_internal_WMASK_B_d(plm_in_ping_a1_a_d_data_rsci_w_en_d_iff)
    );
  esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_86_9_32_320_320_32_gen
      plm_in_pong_a0_a_d_data_rsci (
      .w_en(plm_in_pong_a0_a_d_data_rsc_w_en),
      .w_adr(plm_in_pong_a0_a_d_data_rsc_w_adr),
      .din(plm_in_pong_a0_a_d_data_rsc_din),
      .din_d(plm_in_ping_a0_a_d_data_rsci_din_d_iff),
      .w_adr_d(plm_in_ping_a0_a_d_data_rsci_w_adr_d_iff),
      .w_en_d(plm_in_pong_a0_a_d_data_rsci_w_en_d_iff),
      .port_1_w_ram_ir_internal_WMASK_B_d(plm_in_pong_a0_a_d_data_rsci_w_en_d_iff)
    );
  esp_acc_DUMMY_Ctrl_load_DUAL_PORT_RBW_DUAL_PORT_RBW_wport_87_9_32_320_320_32_gen
      plm_in_pong_a1_a_d_data_rsci (
      .w_en(plm_in_pong_a1_a_d_data_rsc_w_en),
      .w_adr(plm_in_pong_a1_a_d_data_rsc_w_adr),
      .din(plm_in_pong_a1_a_d_data_rsc_din),
      .din_d(plm_in_ping_a1_a_d_data_rsci_din_d_iff),
      .w_adr_d(plm_in_ping_a0_a_d_data_rsci_w_adr_d_iff),
      .w_en_d(plm_in_pong_a1_a_d_data_rsci_w_en_d_iff),
      .port_1_w_ram_ir_internal_WMASK_B_d(plm_in_pong_a1_a_d_data_rsci_w_en_d_iff)
    );
  esp_acc_DUMMY_Ctrl_load_load Ctrl_load_load_inst (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_val(dma_read_chnl_val),
      .dma_read_chnl_rdy(dma_read_chnl_rdy),
      .dma_read_chnl_msg(dma_read_chnl_msg),
      .dma_read_ctrl_val(dma_read_ctrl_val),
      .dma_read_ctrl_rdy(dma_read_ctrl_rdy),
      .dma_read_ctrl_msg(dma_read_ctrl_msg),
      .sync12_vld(sync12_vld),
      .sync12_rdy(sync12_rdy),
      .sync01_val(sync01_val),
      .sync01_rdy(sync01_rdy),
      .sync01_msg(sync01_msg),
      .conf1_val(conf1_val),
      .conf1_rdy(conf1_rdy),
      .conf1_msg(conf1_msg),
      .while_for_len_mul_cmp_a(while_for_len_mul_cmp_a),
      .while_for_len_mul_cmp_b(while_for_len_mul_cmp_b),
      .while_for_len_mul_cmp_z(nl_Ctrl_load_load_inst_while_for_len_mul_cmp_z[31:0]),
      .plm_in_ping_a0_a_d_data_rsci_din_d_pff(plm_in_ping_a0_a_d_data_rsci_din_d_iff),
      .plm_in_ping_a0_a_d_data_rsci_w_adr_d_pff(plm_in_ping_a0_a_d_data_rsci_w_adr_d_iff),
      .plm_in_ping_a0_a_d_data_rsci_w_en_d_pff(plm_in_ping_a0_a_d_data_rsci_w_en_d_iff),
      .plm_in_ping_a1_a_d_data_rsci_din_d_pff(plm_in_ping_a1_a_d_data_rsci_din_d_iff),
      .plm_in_ping_a1_a_d_data_rsci_w_en_d_pff(plm_in_ping_a1_a_d_data_rsci_w_en_d_iff),
      .plm_in_pong_a0_a_d_data_rsci_w_en_d_pff(plm_in_pong_a0_a_d_data_rsci_w_en_d_iff),
      .plm_in_pong_a1_a_d_data_rsci_w_en_d_pff(plm_in_pong_a1_a_d_data_rsci_w_en_d_iff)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_Ctrl_config
// ------------------------------------------------------------------


module esp_acc_DUMMY_Ctrl_config (
  clk, rst, conf_info_val, conf_info_rdy, conf_info_msg, conf_info_out_val, conf_info_out_rdy,
      conf_info_out_msg, sync00_val, sync00_rdy, sync00_msg, sync01_val, sync01_rdy,
      sync01_msg, sync02_val, sync02_rdy, sync02_msg, sync03_val, sync03_rdy, sync03_msg,
      conf1_val, conf1_rdy, conf1_msg, conf2_val, conf2_rdy, conf2_msg, conf3_val,
      conf3_rdy, conf3_msg
);
  input clk;
  input rst;
  input conf_info_val;
  output conf_info_rdy;
  input [95:0] conf_info_msg;
  output conf_info_out_val;
  input conf_info_out_rdy;
  output [95:0] conf_info_out_msg;
  output sync00_val;
  input sync00_rdy;
  output sync00_msg;
  output sync01_val;
  input sync01_rdy;
  output sync01_msg;
  output sync02_val;
  input sync02_rdy;
  output sync02_msg;
  output sync03_val;
  input sync03_rdy;
  output sync03_msg;
  output conf1_val;
  input conf1_rdy;
  output [95:0] conf1_msg;
  output conf2_val;
  input conf2_rdy;
  output [95:0] conf2_msg;
  output conf3_val;
  input conf3_rdy;
  output [95:0] conf3_msg;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_Ctrl_config_config Ctrl_config_config_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_val(conf_info_val),
      .conf_info_rdy(conf_info_rdy),
      .conf_info_msg(conf_info_msg),
      .conf_info_out_val(conf_info_out_val),
      .conf_info_out_rdy(conf_info_out_rdy),
      .conf_info_out_msg(conf_info_out_msg),
      .sync00_val(sync00_val),
      .sync00_rdy(sync00_rdy),
      .sync00_msg(sync00_msg),
      .sync01_val(sync01_val),
      .sync01_rdy(sync01_rdy),
      .sync01_msg(sync01_msg),
      .sync02_val(sync02_val),
      .sync02_rdy(sync02_rdy),
      .sync02_msg(sync02_msg),
      .sync03_val(sync03_val),
      .sync03_rdy(sync03_rdy),
      .sync03_msg(sync03_msg),
      .conf1_val(conf1_val),
      .conf1_rdy(conf1_rdy),
      .conf1_msg(conf1_msg),
      .conf2_val(conf2_val),
      .conf2_rdy(conf2_rdy),
      .conf2_msg(conf2_msg),
      .conf3_val(conf3_val),
      .conf3_rdy(conf3_rdy),
      .conf3_msg(conf3_msg)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    Ctrl
// ------------------------------------------------------------------


module Ctrl (
  clk, rst, acc_done, conf_info_val, conf_info_rdy, conf_info_msg, dma_read_chnl_val,
      dma_read_chnl_rdy, dma_read_chnl_msg, dma_write_chnl_val, dma_write_chnl_rdy,
      dma_write_chnl_msg, dma_read_ctrl_val, dma_read_ctrl_rdy, dma_read_ctrl_msg,
      dma_write_ctrl_val, dma_write_ctrl_rdy, dma_write_ctrl_msg, conf_info_out_val,
      conf_info_out_rdy, conf_info_out_msg, sync00_val, sync00_rdy, sync00_msg, in_wr_req_val,
      in_wr_req_rdy, in_wr_req_msg, in_rd_rsp_val, in_rd_rsp_rdy, in_rd_rsp_msg
);
  input clk;
  input rst;
  output acc_done;
  input conf_info_val;
  output conf_info_rdy;
  input [95:0] conf_info_msg;
  input dma_read_chnl_val;
  output dma_read_chnl_rdy;
  input [63:0] dma_read_chnl_msg;
  output dma_write_chnl_val;
  input dma_write_chnl_rdy;
  output [63:0] dma_write_chnl_msg;
  output dma_read_ctrl_val;
  input dma_read_ctrl_rdy;
  output [72:0] dma_read_ctrl_msg;
  output dma_write_ctrl_val;
  input dma_write_ctrl_rdy;
  output [72:0] dma_write_ctrl_msg;
  output conf_info_out_val;
  input conf_info_out_rdy;
  output [95:0] conf_info_out_msg;
  output sync00_val;
  input sync00_rdy;
  output sync00_msg;
  input in_wr_req_val;
  output in_wr_req_rdy;
  input [31:0] in_wr_req_msg;
  output in_rd_rsp_val;
  input in_rd_rsp_rdy;
  output [63:0] in_rd_rsp_msg;


  // Interconnect Declarations
  wire sync12_vld;
  wire sync12_rdy;
  wire sync23_vld;
  wire sync23_rdy;
  wire sync01_val;
  wire sync01_rdy;
  wire sync01_msg;
  wire sync02_val;
  wire sync02_rdy;
  wire sync02_msg;
  wire sync03_val;
  wire sync03_rdy;
  wire sync03_msg;
  wire conf1_val;
  wire conf1_rdy;
  wire [95:0] conf1_msg;
  wire conf2_val;
  wire conf2_rdy;
  wire [95:0] conf2_msg;
  wire conf3_val;
  wire conf3_rdy;
  wire [95:0] conf3_msg;
  wire [31:0] plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst;
  wire [8:0] plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  wire plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst;
  wire [31:0] plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst;
  wire [8:0] plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  wire plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst;
  wire [31:0] plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst;
  wire [8:0] plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  wire plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst;
  wire [31:0] plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst;
  wire [8:0] plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst;
  wire plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst;
  wire plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz;
  wire [8:0] plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz;
  wire [31:0] plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz;
  wire plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz;
  wire [8:0] plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz;
  wire [31:0] plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz;
  wire plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz;
  wire [8:0] plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz;
  wire [31:0] plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz;
  wire plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz;
  wire [8:0] plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz;
  wire [31:0] plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz;
  wire [31:0] plm_in_ping_a0_a_d_data_rsc_qout_n_Ctrl_compute_inst;
  wire [8:0] plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  wire [31:0] plm_in_ping_a1_a_d_data_rsc_qout_n_Ctrl_compute_inst;
  wire [8:0] plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  wire [31:0] plm_in_pong_a0_a_d_data_rsc_qout_n_Ctrl_compute_inst;
  wire [8:0] plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  wire [31:0] plm_in_pong_a1_a_d_data_rsc_qout_n_Ctrl_compute_inst;
  wire [8:0] plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst;
  wire [31:0] plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst;
  wire [4:0] plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  wire plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
  wire [31:0] plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst;
  wire [4:0] plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  wire plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
  wire [31:0] plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst;
  wire [4:0] plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  wire plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
  wire [31:0] plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst;
  wire [4:0] plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst;
  wire plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst;
  wire [8:0] plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz;
  wire [8:0] plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz;
  wire [8:0] plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz;
  wire [8:0] plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz;
  wire plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz;
  wire [4:0] plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz;
  wire [31:0] plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz;
  wire plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz;
  wire [4:0] plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz;
  wire [31:0] plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz;
  wire plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz;
  wire [4:0] plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz;
  wire [31:0] plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz;
  wire plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz;
  wire [4:0] plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz;
  wire [31:0] plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz;
  wire [31:0] plm_out_ping_a0_a_d_data_rsc_qout_n_Ctrl_store_inst;
  wire [4:0] plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  wire [31:0] plm_out_ping_a1_a_d_data_rsc_qout_n_Ctrl_store_inst;
  wire [4:0] plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  wire [31:0] plm_out_pong_a0_a_d_data_rsc_qout_n_Ctrl_store_inst;
  wire [4:0] plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  wire [31:0] plm_out_pong_a1_a_d_data_rsc_qout_n_Ctrl_store_inst;
  wire [4:0] plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst;
  wire [4:0] plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz;
  wire [4:0] plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz;
  wire [4:0] plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz;
  wire [4:0] plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz;
  wire plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;
  wire plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;
  wire plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud;
  wire plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
  wire plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
  wire plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;
  wire plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud;


  // Interconnect Declarations for Component Instantiations 
  DUAL_PORT_RBW #(.AddressSz(32'sd9),
  .data_width(32'sd32),
  .Sz(32'sd320)) plm_in_ping_a0_a_d_data_rsc_comp (
      .clk(clk),
      .clk_en(1'b1),
      .din(plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz),
      .qout(plm_in_ping_a0_a_d_data_rsc_qout_n_Ctrl_compute_inst),
      .r_adr(plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz),
      .w_adr(plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz),
      .w_en(plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz)
    );
  DUAL_PORT_RBW #(.AddressSz(32'sd9),
  .data_width(32'sd32),
  .Sz(32'sd320)) plm_in_ping_a1_a_d_data_rsc_comp (
      .clk(clk),
      .clk_en(1'b1),
      .din(plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz),
      .qout(plm_in_ping_a1_a_d_data_rsc_qout_n_Ctrl_compute_inst),
      .r_adr(plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz),
      .w_adr(plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz),
      .w_en(plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz)
    );
  DUAL_PORT_RBW #(.AddressSz(32'sd9),
  .data_width(32'sd32),
  .Sz(32'sd320)) plm_in_pong_a0_a_d_data_rsc_comp (
      .clk(clk),
      .clk_en(1'b1),
      .din(plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz),
      .qout(plm_in_pong_a0_a_d_data_rsc_qout_n_Ctrl_compute_inst),
      .r_adr(plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz),
      .w_adr(plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz),
      .w_en(plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz)
    );
  DUAL_PORT_RBW #(.AddressSz(32'sd9),
  .data_width(32'sd32),
  .Sz(32'sd320)) plm_in_pong_a1_a_d_data_rsc_comp (
      .clk(clk),
      .clk_en(1'b1),
      .din(plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz),
      .qout(plm_in_pong_a1_a_d_data_rsc_qout_n_Ctrl_compute_inst),
      .r_adr(plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz),
      .w_adr(plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz),
      .w_en(plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz)
    );
  DUAL_PORT_RBW #(.AddressSz(32'sd5),
  .data_width(32'sd32),
  .Sz(32'sd32)) plm_out_ping_a0_a_d_data_rsc_comp (
      .clk(clk),
      .clk_en(1'b1),
      .din(plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz),
      .qout(plm_out_ping_a0_a_d_data_rsc_qout_n_Ctrl_store_inst),
      .r_adr(plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz),
      .w_adr(plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz),
      .w_en(plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz)
    );
  DUAL_PORT_RBW #(.AddressSz(32'sd5),
  .data_width(32'sd32),
  .Sz(32'sd32)) plm_out_ping_a1_a_d_data_rsc_comp (
      .clk(clk),
      .clk_en(1'b1),
      .din(plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz),
      .qout(plm_out_ping_a1_a_d_data_rsc_qout_n_Ctrl_store_inst),
      .r_adr(plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz),
      .w_adr(plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz),
      .w_en(plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz)
    );
  DUAL_PORT_RBW #(.AddressSz(32'sd5),
  .data_width(32'sd32),
  .Sz(32'sd32)) plm_out_pong_a0_a_d_data_rsc_comp (
      .clk(clk),
      .clk_en(1'b1),
      .din(plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz),
      .qout(plm_out_pong_a0_a_d_data_rsc_qout_n_Ctrl_store_inst),
      .r_adr(plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz),
      .w_adr(plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz),
      .w_en(plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz)
    );
  DUAL_PORT_RBW #(.AddressSz(32'sd5),
  .data_width(32'sd32),
  .Sz(32'sd32)) plm_out_pong_a1_a_d_data_rsc_comp (
      .clk(clk),
      .clk_en(1'b1),
      .din(plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz),
      .qout(plm_out_pong_a1_a_d_data_rsc_qout_n_Ctrl_store_inst),
      .r_adr(plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz),
      .w_adr(plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz),
      .w_en(plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz)
    );
  esp_acc_DUMMY_Ctrl_config Ctrl_config_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_val(conf_info_val),
      .conf_info_rdy(conf_info_rdy),
      .conf_info_msg(conf_info_msg),
      .conf_info_out_val(conf_info_out_val),
      .conf_info_out_rdy(conf_info_out_rdy),
      .conf_info_out_msg(conf_info_out_msg),
      .sync00_val(sync00_val),
      .sync00_rdy(sync00_rdy),
      .sync00_msg(sync00_msg),
      .sync01_val(sync01_val),
      .sync01_rdy(sync01_rdy),
      .sync01_msg(sync01_msg),
      .sync02_val(sync02_val),
      .sync02_rdy(sync02_rdy),
      .sync02_msg(sync02_msg),
      .sync03_val(sync03_val),
      .sync03_rdy(sync03_rdy),
      .sync03_msg(sync03_msg),
      .conf1_val(conf1_val),
      .conf1_rdy(conf1_rdy),
      .conf1_msg(conf1_msg),
      .conf2_val(conf2_val),
      .conf2_rdy(conf2_rdy),
      .conf2_msg(conf2_msg),
      .conf3_val(conf3_val),
      .conf3_rdy(conf3_rdy),
      .conf3_msg(conf3_msg)
    );
  esp_acc_DUMMY_Ctrl_load Ctrl_load_inst (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_val(dma_read_chnl_val),
      .dma_read_chnl_rdy(dma_read_chnl_rdy),
      .dma_read_chnl_msg(dma_read_chnl_msg),
      .dma_read_ctrl_val(dma_read_ctrl_val),
      .dma_read_ctrl_rdy(dma_read_ctrl_rdy),
      .dma_read_ctrl_msg(dma_read_ctrl_msg),
      .sync12_vld(sync12_vld),
      .sync12_rdy(sync12_rdy),
      .sync01_val(sync01_val),
      .sync01_rdy(sync01_rdy),
      .sync01_msg(sync01_msg),
      .conf1_val(conf1_val),
      .conf1_rdy(conf1_rdy),
      .conf1_msg(conf1_msg),
      .plm_in_ping_a0_a_d_data_rsc_din(plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst),
      .plm_in_ping_a0_a_d_data_rsc_w_adr(plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst),
      .plm_in_ping_a0_a_d_data_rsc_w_en(plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst),
      .plm_in_ping_a1_a_d_data_rsc_din(plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst),
      .plm_in_ping_a1_a_d_data_rsc_w_adr(plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst),
      .plm_in_ping_a1_a_d_data_rsc_w_en(plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst),
      .plm_in_pong_a0_a_d_data_rsc_din(plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst),
      .plm_in_pong_a0_a_d_data_rsc_w_adr(plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst),
      .plm_in_pong_a0_a_d_data_rsc_w_en(plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst),
      .plm_in_pong_a1_a_d_data_rsc_din(plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst),
      .plm_in_pong_a1_a_d_data_rsc_w_adr(plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst),
      .plm_in_pong_a1_a_d_data_rsc_w_en(plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst)
    );
  esp_acc_DUMMY_Ctrl_compute Ctrl_compute_inst (
      .clk(clk),
      .rst(rst),
      .in_wr_req_val(in_wr_req_val),
      .in_wr_req_rdy(in_wr_req_rdy),
      .in_wr_req_msg(in_wr_req_msg),
      .in_rd_rsp_val(in_rd_rsp_val),
      .in_rd_rsp_rdy(in_rd_rsp_rdy),
      .in_rd_rsp_msg(in_rd_rsp_msg),
      .sync12_vld(sync12_vld),
      .sync12_rdy(sync12_rdy),
      .sync23_vld(sync23_vld),
      .sync23_rdy(sync23_rdy),
      .sync02_val(sync02_val),
      .sync02_rdy(sync02_rdy),
      .sync02_msg(sync02_msg),
      .conf2_val(conf2_val),
      .conf2_rdy(conf2_rdy),
      .conf2_msg(conf2_msg),
      .plm_in_ping_a0_a_d_data_rsc_qout(plm_in_ping_a0_a_d_data_rsc_qout_n_Ctrl_compute_inst),
      .plm_in_ping_a0_a_d_data_rsc_r_adr(plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst),
      .plm_in_ping_a1_a_d_data_rsc_qout(plm_in_ping_a1_a_d_data_rsc_qout_n_Ctrl_compute_inst),
      .plm_in_ping_a1_a_d_data_rsc_r_adr(plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst),
      .plm_in_pong_a0_a_d_data_rsc_qout(plm_in_pong_a0_a_d_data_rsc_qout_n_Ctrl_compute_inst),
      .plm_in_pong_a0_a_d_data_rsc_r_adr(plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst),
      .plm_in_pong_a1_a_d_data_rsc_qout(plm_in_pong_a1_a_d_data_rsc_qout_n_Ctrl_compute_inst),
      .plm_in_pong_a1_a_d_data_rsc_r_adr(plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst),
      .plm_out_ping_a0_a_d_data_rsc_din(plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst),
      .plm_out_ping_a0_a_d_data_rsc_w_adr(plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst),
      .plm_out_ping_a0_a_d_data_rsc_w_en(plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst),
      .plm_out_ping_a1_a_d_data_rsc_din(plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst),
      .plm_out_ping_a1_a_d_data_rsc_w_adr(plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst),
      .plm_out_ping_a1_a_d_data_rsc_w_en(plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst),
      .plm_out_pong_a0_a_d_data_rsc_din(plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst),
      .plm_out_pong_a0_a_d_data_rsc_w_adr(plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst),
      .plm_out_pong_a0_a_d_data_rsc_w_en(plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst),
      .plm_out_pong_a1_a_d_data_rsc_din(plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst),
      .plm_out_pong_a1_a_d_data_rsc_w_adr(plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst),
      .plm_out_pong_a1_a_d_data_rsc_w_en(plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst)
    );
  esp_acc_DUMMY_Ctrl_store Ctrl_store_inst (
      .clk(clk),
      .rst(rst),
      .acc_done(acc_done),
      .dma_write_chnl_val(dma_write_chnl_val),
      .dma_write_chnl_rdy(dma_write_chnl_rdy),
      .dma_write_chnl_msg(dma_write_chnl_msg),
      .dma_write_ctrl_val(dma_write_ctrl_val),
      .dma_write_ctrl_rdy(dma_write_ctrl_rdy),
      .dma_write_ctrl_msg(dma_write_ctrl_msg),
      .sync23_vld(sync23_vld),
      .sync23_rdy(sync23_rdy),
      .sync03_val(sync03_val),
      .sync03_rdy(sync03_rdy),
      .sync03_msg(sync03_msg),
      .conf3_val(conf3_val),
      .conf3_rdy(conf3_rdy),
      .conf3_msg(conf3_msg),
      .plm_out_ping_a0_a_d_data_rsc_qout(plm_out_ping_a0_a_d_data_rsc_qout_n_Ctrl_store_inst),
      .plm_out_ping_a0_a_d_data_rsc_r_adr(plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst),
      .plm_out_ping_a1_a_d_data_rsc_qout(plm_out_ping_a1_a_d_data_rsc_qout_n_Ctrl_store_inst),
      .plm_out_ping_a1_a_d_data_rsc_r_adr(plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst),
      .plm_out_pong_a0_a_d_data_rsc_qout(plm_out_pong_a0_a_d_data_rsc_qout_n_Ctrl_store_inst),
      .plm_out_pong_a0_a_d_data_rsc_r_adr(plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst),
      .plm_out_pong_a1_a_d_data_rsc_qout(plm_out_pong_a1_a_d_data_rsc_qout_n_Ctrl_store_inst),
      .plm_out_pong_a1_a_d_data_rsc_r_adr(plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst)
    );
  esp_acc_DUMMY_Ctrl_plm_in_iLMRpdata_rsc_bctl Ctrl_plm_in_iLMRpdata_rsc_bctl_inst
      (
      .clk(1'b0),
      .rst(1'b0),
      .plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst(plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst),
      .plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst(plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst),
      .plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst(plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst),
      .plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz(plm_in_ping_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz),
      .plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz(plm_in_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz),
      .plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz(plm_in_ping_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz),
      .plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz(plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz),
      .plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz(plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz),
      .plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz(plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz),
      .plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst(plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst),
      .plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz(plm_in_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz),
      .plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz(plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz),
      .plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz(plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz),
      .plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz(plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz),
      .plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz(plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz),
      .plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud(plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud),
      .plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud(plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud),
      .plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud(plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud),
      .plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud(plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud),
      .plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud(plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud),
      .plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud(plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud),
      .plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud(plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud)
    );
  esp_acc_DUMMY_Ctrl_plm_in_xCUZOdata_rsc_bctl Ctrl_plm_in_xCUZOdata_rsc_bctl_inst
      (
      .clk(1'b0),
      .rst(1'b0),
      .plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst(plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst),
      .plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst(plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst),
      .plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst(plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst),
      .plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz(plm_in_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz),
      .plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz(plm_in_ping_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz),
      .plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst(plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst),
      .plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz(plm_in_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz),
      .plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud(plm_in_ping_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud)
    );
  esp_acc_DUMMY_Ctrl_plm_in_iLMvRdata_rsc_bctl Ctrl_plm_in_iLMvRdata_rsc_bctl_inst
      (
      .clk(1'b0),
      .rst(1'b0),
      .plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst(plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst),
      .plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst(plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst),
      .plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst(plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst),
      .plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz(plm_in_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz),
      .plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz(plm_in_pong_a0_a_d_data_rsc_din_n_Ctrl_load_inst_buz),
      .plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst(plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst),
      .plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz(plm_in_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz),
      .plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud(plm_in_pong_a0_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud)
    );
  esp_acc_DUMMY_Ctrl_plm_in_xCVCqdata_rsc_bctl Ctrl_plm_in_xCVCqdata_rsc_bctl_inst
      (
      .clk(1'b0),
      .rst(1'b0),
      .plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst(plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst),
      .plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst(plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst),
      .plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst(plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst),
      .plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz(plm_in_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_load_inst_buz),
      .plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz(plm_in_pong_a1_a_d_data_rsc_din_n_Ctrl_load_inst_buz),
      .plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst(plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst),
      .plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz(plm_in_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_compute_inst_buz),
      .plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud(plm_in_pong_a1_a_d_data_rsc_w_en_n_Ctrl_load_inst_buz_bud)
    );
  esp_acc_DUMMY_Ctrl_plm_outEiGDqdata_rsc_bctl Ctrl_plm_outEiGDqdata_rsc_bctl_inst
      (
      .clk(1'b0),
      .rst(1'b0),
      .plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst(plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst),
      .plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst(plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst),
      .plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst(plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst),
      .plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz(plm_out_ping_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz),
      .plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz(plm_out_ping_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz),
      .plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst(plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst),
      .plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz(plm_out_ping_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz),
      .plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud(plm_out_ping_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud)
    );
  esp_acc_DUMMY_Ctrl_plm_outdyLTOdata_rsc_bctl Ctrl_plm_outdyLTOdata_rsc_bctl_inst
      (
      .clk(1'b0),
      .rst(1'b0),
      .plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst(plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst),
      .plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst(plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst),
      .plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst(plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst),
      .plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz(plm_out_ping_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz),
      .plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz(plm_out_ping_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz),
      .plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst(plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst),
      .plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz(plm_out_ping_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz),
      .plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud(plm_out_ping_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud)
    );
  esp_acc_DUMMY_Ctrl_plm_outEkvZidata_rsc_bctl Ctrl_plm_outEkvZidata_rsc_bctl_inst
      (
      .clk(1'b0),
      .rst(1'b0),
      .plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst(plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst),
      .plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst(plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst),
      .plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst(plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst),
      .plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz(plm_out_pong_a0_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz),
      .plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz(plm_out_pong_a0_a_d_data_rsc_din_n_Ctrl_compute_inst_buz),
      .plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst(plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst),
      .plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz(plm_out_pong_a0_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz),
      .plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud(plm_out_pong_a0_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud)
    );
  esp_acc_DUMMY_Ctrl_plm_outeBApGdata_rsc_bctl Ctrl_plm_outeBApGdata_rsc_bctl_inst
      (
      .clk(1'b0),
      .rst(1'b0),
      .plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst(plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst),
      .plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst(plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst),
      .plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst(plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst),
      .plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz(plm_out_pong_a1_a_d_data_rsc_w_adr_n_Ctrl_compute_inst_buz),
      .plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz(plm_out_pong_a1_a_d_data_rsc_din_n_Ctrl_compute_inst_buz),
      .plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst(plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst),
      .plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz(plm_out_pong_a1_a_d_data_rsc_r_adr_n_Ctrl_store_inst_buz),
      .plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud(plm_out_pong_a1_a_d_data_rsc_w_en_n_Ctrl_compute_inst_buz_bud)
    );
endmodule



