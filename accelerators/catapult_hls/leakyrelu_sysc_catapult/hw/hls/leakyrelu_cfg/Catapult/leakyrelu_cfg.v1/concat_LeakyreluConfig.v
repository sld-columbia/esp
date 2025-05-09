
//------> ./LeakyreluConfig_ccs_ctrl_in_buf_wait_v4.v 
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



//------> ./LeakyreluConfig_ccs_out_buf_wait_v5.v 
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

//------> ./LeakyreluConfig.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2025.1/1166825 Production Release
//  HLS Date:       Sun Feb 16 14:04:49 PST 2025
// 
//  Generated by:   gtombesi@corsica
//  Generated date: Thu May  8 18:59:14 2025
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_ConfigRead_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_ConfigRead_fsm (
  clk, rst, ConfigRead_wen, fsm_output
);
  input clk;
  input rst;
  input ConfigRead_wen;
  output [2:0] fsm_output;
  reg [2:0] fsm_output;


  // FSM State Type Declaration for esp_acc_DUMMY_LeakyreluConfig_ConfigRead_ConfigRead_fsm_1
  parameter
    ConfigRead_rlp_C_0 = 2'd0,
    while_C_0 = 2'd1,
    while_C_1 = 2'd2;

  reg [1:0] state_var;
  reg [1:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_DUMMY_LeakyreluConfig_ConfigRead_ConfigRead_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 3'b010;
        state_var_NS = while_C_1;
      end
      while_C_1 : begin
        fsm_output = 3'b100;
        state_var_NS = while_C_0;
      end
      // ConfigRead_rlp_C_0
      default : begin
        fsm_output = 3'b001;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      state_var <= ConfigRead_rlp_C_0;
    end
    else if ( ConfigRead_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_staller
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_staller (
  ConfigRead_wen, conf_info_Pop_mioi_wen_comp, conf_info_ctrl_dma2acc_Push_mioi_wen_comp,
      conf_info_ctrl_plm2vec_Push_mioi_wen_comp, conf_info_ctrl_acc2dma_Push_mioi_wen_comp
);
  output ConfigRead_wen;
  input conf_info_Pop_mioi_wen_comp;
  input conf_info_ctrl_dma2acc_Push_mioi_wen_comp;
  input conf_info_ctrl_plm2vec_Push_mioi_wen_comp;
  input conf_info_ctrl_acc2dma_Push_mioi_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign ConfigRead_wen = conf_info_Pop_mioi_wen_comp & conf_info_ctrl_dma2acc_Push_mioi_wen_comp
      & conf_info_ctrl_plm2vec_Push_mioi_wen_comp & conf_info_ctrl_acc2dma_Push_mioi_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi_conf_info_ctrl_acc2dma_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi_conf_info_ctrl_acc2dma_Push_mio_wait_dp
    (
  clk, rst, conf_info_ctrl_acc2dma_Push_mioi_oswt, conf_info_ctrl_acc2dma_Push_mioi_wen_comp,
      conf_info_ctrl_acc2dma_Push_mioi_biwt, conf_info_ctrl_acc2dma_Push_mioi_bdwt,
      conf_info_ctrl_acc2dma_Push_mioi_bcwt, conf_info_ctrl_acc2dma_Push_mioi_biwt_pff,
      conf_info_ctrl_acc2dma_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input conf_info_ctrl_acc2dma_Push_mioi_oswt;
  output conf_info_ctrl_acc2dma_Push_mioi_wen_comp;
  input conf_info_ctrl_acc2dma_Push_mioi_biwt;
  input conf_info_ctrl_acc2dma_Push_mioi_bdwt;
  output conf_info_ctrl_acc2dma_Push_mioi_bcwt;
  input conf_info_ctrl_acc2dma_Push_mioi_biwt_pff;
  output conf_info_ctrl_acc2dma_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg conf_info_ctrl_acc2dma_Push_mioi_bcwt_reg;
  wire while_nor_4_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_4_rmff = ~((~(conf_info_ctrl_acc2dma_Push_mioi_bcwt | conf_info_ctrl_acc2dma_Push_mioi_biwt))
      | conf_info_ctrl_acc2dma_Push_mioi_bdwt);
  assign conf_info_ctrl_acc2dma_Push_mioi_wen_comp = (~ conf_info_ctrl_acc2dma_Push_mioi_oswt)
      | conf_info_ctrl_acc2dma_Push_mioi_biwt_pff | conf_info_ctrl_acc2dma_Push_mioi_bcwt_pff;
  assign conf_info_ctrl_acc2dma_Push_mioi_bcwt = conf_info_ctrl_acc2dma_Push_mioi_bcwt_reg;
  assign conf_info_ctrl_acc2dma_Push_mioi_bcwt_pff = while_nor_4_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf_info_ctrl_acc2dma_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      conf_info_ctrl_acc2dma_Push_mioi_bcwt_reg <= while_nor_4_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi_conf_info_ctrl_acc2dma_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi_conf_info_ctrl_acc2dma_Push_mio_wait_ctrl
    (
  ConfigRead_wen, conf_info_ctrl_acc2dma_Push_mioi_oswt, conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg,
      conf_info_ctrl_acc2dma_Push_mioi_biwt, conf_info_ctrl_acc2dma_Push_mioi_bdwt,
      conf_info_ctrl_acc2dma_Push_mioi_bcwt, conf_info_ctrl_acc2dma_Push_mioi_ivld_ConfigRead_sct,
      conf_info_ctrl_acc2dma_Push_mioi_biwt_pff, conf_info_ctrl_acc2dma_Push_mioi_oswt_pff,
      conf_info_ctrl_acc2dma_Push_mioi_bcwt_pff, conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_pff
);
  input ConfigRead_wen;
  input conf_info_ctrl_acc2dma_Push_mioi_oswt;
  input conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg;
  output conf_info_ctrl_acc2dma_Push_mioi_biwt;
  output conf_info_ctrl_acc2dma_Push_mioi_bdwt;
  input conf_info_ctrl_acc2dma_Push_mioi_bcwt;
  output conf_info_ctrl_acc2dma_Push_mioi_ivld_ConfigRead_sct;
  output conf_info_ctrl_acc2dma_Push_mioi_biwt_pff;
  input conf_info_ctrl_acc2dma_Push_mioi_oswt_pff;
  input conf_info_ctrl_acc2dma_Push_mioi_bcwt_pff;
  input conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf_info_ctrl_acc2dma_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_ctrl_acc2dma_Push_mioi_bdwt = conf_info_ctrl_acc2dma_Push_mioi_oswt
      & ConfigRead_wen;
  assign conf_info_ctrl_acc2dma_Push_mioi_ogwt = conf_info_ctrl_acc2dma_Push_mioi_oswt
      & (~ conf_info_ctrl_acc2dma_Push_mioi_bcwt);
  assign conf_info_ctrl_acc2dma_Push_mioi_ivld_ConfigRead_sct = conf_info_ctrl_acc2dma_Push_mioi_ogwt;
  assign conf_info_ctrl_acc2dma_Push_mioi_biwt = conf_info_ctrl_acc2dma_Push_mioi_ogwt
      & conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg;
  assign conf_info_ctrl_acc2dma_Push_mioi_biwt_pff = conf_info_ctrl_acc2dma_Push_mioi_oswt_pff
      & (~ conf_info_ctrl_acc2dma_Push_mioi_bcwt_pff) & conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi_conf_info_ctrl_plm2vec_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi_conf_info_ctrl_plm2vec_Push_mio_wait_dp
    (
  clk, rst, conf_info_ctrl_plm2vec_Push_mioi_oswt, conf_info_ctrl_plm2vec_Push_mioi_wen_comp,
      conf_info_ctrl_plm2vec_Push_mioi_biwt, conf_info_ctrl_plm2vec_Push_mioi_bdwt,
      conf_info_ctrl_plm2vec_Push_mioi_bcwt, conf_info_ctrl_plm2vec_Push_mioi_biwt_pff,
      conf_info_ctrl_plm2vec_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input conf_info_ctrl_plm2vec_Push_mioi_oswt;
  output conf_info_ctrl_plm2vec_Push_mioi_wen_comp;
  input conf_info_ctrl_plm2vec_Push_mioi_biwt;
  input conf_info_ctrl_plm2vec_Push_mioi_bdwt;
  output conf_info_ctrl_plm2vec_Push_mioi_bcwt;
  input conf_info_ctrl_plm2vec_Push_mioi_biwt_pff;
  output conf_info_ctrl_plm2vec_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg conf_info_ctrl_plm2vec_Push_mioi_bcwt_reg;
  wire while_nor_2_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_2_rmff = ~((~(conf_info_ctrl_plm2vec_Push_mioi_bcwt | conf_info_ctrl_plm2vec_Push_mioi_biwt))
      | conf_info_ctrl_plm2vec_Push_mioi_bdwt);
  assign conf_info_ctrl_plm2vec_Push_mioi_wen_comp = (~ conf_info_ctrl_plm2vec_Push_mioi_oswt)
      | conf_info_ctrl_plm2vec_Push_mioi_biwt_pff | conf_info_ctrl_plm2vec_Push_mioi_bcwt_pff;
  assign conf_info_ctrl_plm2vec_Push_mioi_bcwt = conf_info_ctrl_plm2vec_Push_mioi_bcwt_reg;
  assign conf_info_ctrl_plm2vec_Push_mioi_bcwt_pff = while_nor_2_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf_info_ctrl_plm2vec_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      conf_info_ctrl_plm2vec_Push_mioi_bcwt_reg <= while_nor_2_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi_conf_info_ctrl_plm2vec_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi_conf_info_ctrl_plm2vec_Push_mio_wait_ctrl
    (
  ConfigRead_wen, conf_info_ctrl_plm2vec_Push_mioi_oswt, conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg,
      conf_info_ctrl_plm2vec_Push_mioi_biwt, conf_info_ctrl_plm2vec_Push_mioi_bdwt,
      conf_info_ctrl_plm2vec_Push_mioi_bcwt, conf_info_ctrl_plm2vec_Push_mioi_ivld_ConfigRead_sct,
      conf_info_ctrl_plm2vec_Push_mioi_biwt_pff, conf_info_ctrl_plm2vec_Push_mioi_oswt_pff,
      conf_info_ctrl_plm2vec_Push_mioi_bcwt_pff, conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_pff
);
  input ConfigRead_wen;
  input conf_info_ctrl_plm2vec_Push_mioi_oswt;
  input conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg;
  output conf_info_ctrl_plm2vec_Push_mioi_biwt;
  output conf_info_ctrl_plm2vec_Push_mioi_bdwt;
  input conf_info_ctrl_plm2vec_Push_mioi_bcwt;
  output conf_info_ctrl_plm2vec_Push_mioi_ivld_ConfigRead_sct;
  output conf_info_ctrl_plm2vec_Push_mioi_biwt_pff;
  input conf_info_ctrl_plm2vec_Push_mioi_oswt_pff;
  input conf_info_ctrl_plm2vec_Push_mioi_bcwt_pff;
  input conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf_info_ctrl_plm2vec_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_ctrl_plm2vec_Push_mioi_bdwt = conf_info_ctrl_plm2vec_Push_mioi_oswt
      & ConfigRead_wen;
  assign conf_info_ctrl_plm2vec_Push_mioi_ogwt = conf_info_ctrl_plm2vec_Push_mioi_oswt
      & (~ conf_info_ctrl_plm2vec_Push_mioi_bcwt);
  assign conf_info_ctrl_plm2vec_Push_mioi_ivld_ConfigRead_sct = conf_info_ctrl_plm2vec_Push_mioi_ogwt;
  assign conf_info_ctrl_plm2vec_Push_mioi_biwt = conf_info_ctrl_plm2vec_Push_mioi_ogwt
      & conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg;
  assign conf_info_ctrl_plm2vec_Push_mioi_biwt_pff = conf_info_ctrl_plm2vec_Push_mioi_oswt_pff
      & (~ conf_info_ctrl_plm2vec_Push_mioi_bcwt_pff) & conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi_conf_info_ctrl_dma2acc_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi_conf_info_ctrl_dma2acc_Push_mio_wait_dp
    (
  clk, rst, conf_info_ctrl_dma2acc_Push_mioi_oswt, conf_info_ctrl_dma2acc_Push_mioi_wen_comp,
      conf_info_ctrl_dma2acc_Push_mioi_biwt, conf_info_ctrl_dma2acc_Push_mioi_bdwt,
      conf_info_ctrl_dma2acc_Push_mioi_bcwt, conf_info_ctrl_dma2acc_Push_mioi_biwt_pff,
      conf_info_ctrl_dma2acc_Push_mioi_bcwt_pff
);
  input clk;
  input rst;
  input conf_info_ctrl_dma2acc_Push_mioi_oswt;
  output conf_info_ctrl_dma2acc_Push_mioi_wen_comp;
  input conf_info_ctrl_dma2acc_Push_mioi_biwt;
  input conf_info_ctrl_dma2acc_Push_mioi_bdwt;
  output conf_info_ctrl_dma2acc_Push_mioi_bcwt;
  input conf_info_ctrl_dma2acc_Push_mioi_biwt_pff;
  output conf_info_ctrl_dma2acc_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg conf_info_ctrl_dma2acc_Push_mioi_bcwt_reg;
  wire while_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_rmff = ~((~(conf_info_ctrl_dma2acc_Push_mioi_bcwt | conf_info_ctrl_dma2acc_Push_mioi_biwt))
      | conf_info_ctrl_dma2acc_Push_mioi_bdwt);
  assign conf_info_ctrl_dma2acc_Push_mioi_wen_comp = (~ conf_info_ctrl_dma2acc_Push_mioi_oswt)
      | conf_info_ctrl_dma2acc_Push_mioi_biwt_pff | conf_info_ctrl_dma2acc_Push_mioi_bcwt_pff;
  assign conf_info_ctrl_dma2acc_Push_mioi_bcwt = conf_info_ctrl_dma2acc_Push_mioi_bcwt_reg;
  assign conf_info_ctrl_dma2acc_Push_mioi_bcwt_pff = while_nor_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf_info_ctrl_dma2acc_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      conf_info_ctrl_dma2acc_Push_mioi_bcwt_reg <= while_nor_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi_conf_info_ctrl_dma2acc_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi_conf_info_ctrl_dma2acc_Push_mio_wait_ctrl
    (
  ConfigRead_wen, conf_info_ctrl_dma2acc_Push_mioi_oswt, conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg,
      conf_info_ctrl_dma2acc_Push_mioi_biwt, conf_info_ctrl_dma2acc_Push_mioi_bdwt,
      conf_info_ctrl_dma2acc_Push_mioi_bcwt, conf_info_ctrl_dma2acc_Push_mioi_ivld_ConfigRead_sct,
      conf_info_ctrl_dma2acc_Push_mioi_biwt_pff, conf_info_ctrl_dma2acc_Push_mioi_oswt_pff,
      conf_info_ctrl_dma2acc_Push_mioi_bcwt_pff, conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_pff
);
  input ConfigRead_wen;
  input conf_info_ctrl_dma2acc_Push_mioi_oswt;
  input conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg;
  output conf_info_ctrl_dma2acc_Push_mioi_biwt;
  output conf_info_ctrl_dma2acc_Push_mioi_bdwt;
  input conf_info_ctrl_dma2acc_Push_mioi_bcwt;
  output conf_info_ctrl_dma2acc_Push_mioi_ivld_ConfigRead_sct;
  output conf_info_ctrl_dma2acc_Push_mioi_biwt_pff;
  input conf_info_ctrl_dma2acc_Push_mioi_oswt_pff;
  input conf_info_ctrl_dma2acc_Push_mioi_bcwt_pff;
  input conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf_info_ctrl_dma2acc_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_ctrl_dma2acc_Push_mioi_bdwt = conf_info_ctrl_dma2acc_Push_mioi_oswt
      & ConfigRead_wen;
  assign conf_info_ctrl_dma2acc_Push_mioi_ogwt = conf_info_ctrl_dma2acc_Push_mioi_oswt
      & (~ conf_info_ctrl_dma2acc_Push_mioi_bcwt);
  assign conf_info_ctrl_dma2acc_Push_mioi_ivld_ConfigRead_sct = conf_info_ctrl_dma2acc_Push_mioi_ogwt;
  assign conf_info_ctrl_dma2acc_Push_mioi_biwt = conf_info_ctrl_dma2acc_Push_mioi_ogwt
      & conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg;
  assign conf_info_ctrl_dma2acc_Push_mioi_biwt_pff = conf_info_ctrl_dma2acc_Push_mioi_oswt_pff
      & (~ conf_info_ctrl_dma2acc_Push_mioi_bcwt_pff) & conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_wait_dp (
  clk, rst, conf_info_ctrl_dma2acc_Push_mioi_irdy, conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg,
      conf_info_ctrl_plm2vec_Push_mioi_irdy, conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg,
      conf_info_ctrl_acc2dma_Push_mioi_irdy, conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg
);
  input clk;
  input rst;
  input conf_info_ctrl_dma2acc_Push_mioi_irdy;
  output conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg;
  input conf_info_ctrl_plm2vec_Push_mioi_irdy;
  output conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg;
  input conf_info_ctrl_acc2dma_Push_mioi_irdy;
  output conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg;


  // Interconnect Declarations
  reg conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_rneg;
  reg conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_rneg;
  reg conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg = ~ conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_rneg;
  assign conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg = ~ conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_rneg;
  assign conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg = ~ conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_rneg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_rneg <= 1'b0;
      conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_rneg <= 1'b0;
      conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_rneg <= ~ conf_info_ctrl_dma2acc_Push_mioi_irdy;
      conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_rneg <= ~ conf_info_ctrl_plm2vec_Push_mioi_irdy;
      conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_rneg <= ~ conf_info_ctrl_acc2dma_Push_mioi_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_Pop_mioi_conf_info_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_Pop_mioi_conf_info_Pop_mio_wait_ctrl
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
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi
    (
  clk, rst, conf_info_ctrl_acc2dma_val, conf_info_ctrl_acc2dma_rdy, conf_info_ctrl_acc2dma_msg,
      ConfigRead_wen, conf_info_ctrl_acc2dma_Push_mioi_oswt, conf_info_ctrl_acc2dma_Push_mioi_wen_comp,
      conf_info_ctrl_acc2dma_Push_mioi_idat, conf_info_ctrl_acc2dma_Push_mioi_irdy,
      conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg, conf_info_ctrl_acc2dma_Push_mioi_oswt_pff,
      conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output conf_info_ctrl_acc2dma_val;
  input conf_info_ctrl_acc2dma_rdy;
  output [159:0] conf_info_ctrl_acc2dma_msg;
  input ConfigRead_wen;
  input conf_info_ctrl_acc2dma_Push_mioi_oswt;
  output conf_info_ctrl_acc2dma_Push_mioi_wen_comp;
  input [159:0] conf_info_ctrl_acc2dma_Push_mioi_idat;
  output conf_info_ctrl_acc2dma_Push_mioi_irdy;
  input conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg;
  input conf_info_ctrl_acc2dma_Push_mioi_oswt_pff;
  input conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf_info_ctrl_acc2dma_Push_mioi_biwt;
  wire conf_info_ctrl_acc2dma_Push_mioi_bdwt;
  wire conf_info_ctrl_acc2dma_Push_mioi_bcwt;
  wire conf_info_ctrl_acc2dma_Push_mioi_ivld_ConfigRead_sct;
  wire conf_info_ctrl_acc2dma_Push_mioi_wen_comp_reg;
  wire conf_info_ctrl_acc2dma_Push_mioi_biwt_iff;
  wire conf_info_ctrl_acc2dma_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd14),
  .width(32'sd160),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_ctrl_acc2dma_Push_mioi (
      .vld(conf_info_ctrl_acc2dma_val),
      .rdy(conf_info_ctrl_acc2dma_rdy),
      .dat(conf_info_ctrl_acc2dma_msg),
      .idat(conf_info_ctrl_acc2dma_Push_mioi_idat),
      .irdy(conf_info_ctrl_acc2dma_Push_mioi_irdy),
      .ivld(conf_info_ctrl_acc2dma_Push_mioi_ivld_ConfigRead_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi_conf_info_ctrl_acc2dma_Push_mio_wait_ctrl
      LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi_conf_info_ctrl_acc2dma_Push_mio_wait_ctrl_inst
      (
      .ConfigRead_wen(ConfigRead_wen),
      .conf_info_ctrl_acc2dma_Push_mioi_oswt(conf_info_ctrl_acc2dma_Push_mioi_oswt),
      .conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg(conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg),
      .conf_info_ctrl_acc2dma_Push_mioi_biwt(conf_info_ctrl_acc2dma_Push_mioi_biwt),
      .conf_info_ctrl_acc2dma_Push_mioi_bdwt(conf_info_ctrl_acc2dma_Push_mioi_bdwt),
      .conf_info_ctrl_acc2dma_Push_mioi_bcwt(conf_info_ctrl_acc2dma_Push_mioi_bcwt),
      .conf_info_ctrl_acc2dma_Push_mioi_ivld_ConfigRead_sct(conf_info_ctrl_acc2dma_Push_mioi_ivld_ConfigRead_sct),
      .conf_info_ctrl_acc2dma_Push_mioi_biwt_pff(conf_info_ctrl_acc2dma_Push_mioi_biwt_iff),
      .conf_info_ctrl_acc2dma_Push_mioi_oswt_pff(conf_info_ctrl_acc2dma_Push_mioi_oswt_pff),
      .conf_info_ctrl_acc2dma_Push_mioi_bcwt_pff(conf_info_ctrl_acc2dma_Push_mioi_bcwt_iff),
      .conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_pff(conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi_conf_info_ctrl_acc2dma_Push_mio_wait_dp
      LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi_conf_info_ctrl_acc2dma_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_ctrl_acc2dma_Push_mioi_oswt(conf_info_ctrl_acc2dma_Push_mioi_oswt_pff),
      .conf_info_ctrl_acc2dma_Push_mioi_wen_comp(conf_info_ctrl_acc2dma_Push_mioi_wen_comp_reg),
      .conf_info_ctrl_acc2dma_Push_mioi_biwt(conf_info_ctrl_acc2dma_Push_mioi_biwt),
      .conf_info_ctrl_acc2dma_Push_mioi_bdwt(conf_info_ctrl_acc2dma_Push_mioi_bdwt),
      .conf_info_ctrl_acc2dma_Push_mioi_bcwt(conf_info_ctrl_acc2dma_Push_mioi_bcwt),
      .conf_info_ctrl_acc2dma_Push_mioi_biwt_pff(conf_info_ctrl_acc2dma_Push_mioi_biwt_iff),
      .conf_info_ctrl_acc2dma_Push_mioi_bcwt_pff(conf_info_ctrl_acc2dma_Push_mioi_bcwt_iff)
    );
  assign conf_info_ctrl_acc2dma_Push_mioi_wen_comp = conf_info_ctrl_acc2dma_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi
    (
  clk, rst, conf_info_ctrl_plm2vec_val, conf_info_ctrl_plm2vec_rdy, conf_info_ctrl_plm2vec_msg,
      ConfigRead_wen, conf_info_ctrl_plm2vec_Push_mioi_oswt, conf_info_ctrl_plm2vec_Push_mioi_wen_comp,
      conf_info_ctrl_plm2vec_Push_mioi_idat, conf_info_ctrl_plm2vec_Push_mioi_irdy,
      conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg, conf_info_ctrl_plm2vec_Push_mioi_oswt_pff,
      conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output conf_info_ctrl_plm2vec_val;
  input conf_info_ctrl_plm2vec_rdy;
  output [159:0] conf_info_ctrl_plm2vec_msg;
  input ConfigRead_wen;
  input conf_info_ctrl_plm2vec_Push_mioi_oswt;
  output conf_info_ctrl_plm2vec_Push_mioi_wen_comp;
  input [159:0] conf_info_ctrl_plm2vec_Push_mioi_idat;
  output conf_info_ctrl_plm2vec_Push_mioi_irdy;
  input conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg;
  input conf_info_ctrl_plm2vec_Push_mioi_oswt_pff;
  input conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf_info_ctrl_plm2vec_Push_mioi_biwt;
  wire conf_info_ctrl_plm2vec_Push_mioi_bdwt;
  wire conf_info_ctrl_plm2vec_Push_mioi_bcwt;
  wire conf_info_ctrl_plm2vec_Push_mioi_ivld_ConfigRead_sct;
  wire conf_info_ctrl_plm2vec_Push_mioi_wen_comp_reg;
  wire conf_info_ctrl_plm2vec_Push_mioi_biwt_iff;
  wire conf_info_ctrl_plm2vec_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd13),
  .width(32'sd160),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_ctrl_plm2vec_Push_mioi (
      .vld(conf_info_ctrl_plm2vec_val),
      .rdy(conf_info_ctrl_plm2vec_rdy),
      .dat(conf_info_ctrl_plm2vec_msg),
      .idat(conf_info_ctrl_plm2vec_Push_mioi_idat),
      .irdy(conf_info_ctrl_plm2vec_Push_mioi_irdy),
      .ivld(conf_info_ctrl_plm2vec_Push_mioi_ivld_ConfigRead_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi_conf_info_ctrl_plm2vec_Push_mio_wait_ctrl
      LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi_conf_info_ctrl_plm2vec_Push_mio_wait_ctrl_inst
      (
      .ConfigRead_wen(ConfigRead_wen),
      .conf_info_ctrl_plm2vec_Push_mioi_oswt(conf_info_ctrl_plm2vec_Push_mioi_oswt),
      .conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg(conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg),
      .conf_info_ctrl_plm2vec_Push_mioi_biwt(conf_info_ctrl_plm2vec_Push_mioi_biwt),
      .conf_info_ctrl_plm2vec_Push_mioi_bdwt(conf_info_ctrl_plm2vec_Push_mioi_bdwt),
      .conf_info_ctrl_plm2vec_Push_mioi_bcwt(conf_info_ctrl_plm2vec_Push_mioi_bcwt),
      .conf_info_ctrl_plm2vec_Push_mioi_ivld_ConfigRead_sct(conf_info_ctrl_plm2vec_Push_mioi_ivld_ConfigRead_sct),
      .conf_info_ctrl_plm2vec_Push_mioi_biwt_pff(conf_info_ctrl_plm2vec_Push_mioi_biwt_iff),
      .conf_info_ctrl_plm2vec_Push_mioi_oswt_pff(conf_info_ctrl_plm2vec_Push_mioi_oswt_pff),
      .conf_info_ctrl_plm2vec_Push_mioi_bcwt_pff(conf_info_ctrl_plm2vec_Push_mioi_bcwt_iff),
      .conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_pff(conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi_conf_info_ctrl_plm2vec_Push_mio_wait_dp
      LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi_conf_info_ctrl_plm2vec_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_ctrl_plm2vec_Push_mioi_oswt(conf_info_ctrl_plm2vec_Push_mioi_oswt_pff),
      .conf_info_ctrl_plm2vec_Push_mioi_wen_comp(conf_info_ctrl_plm2vec_Push_mioi_wen_comp_reg),
      .conf_info_ctrl_plm2vec_Push_mioi_biwt(conf_info_ctrl_plm2vec_Push_mioi_biwt),
      .conf_info_ctrl_plm2vec_Push_mioi_bdwt(conf_info_ctrl_plm2vec_Push_mioi_bdwt),
      .conf_info_ctrl_plm2vec_Push_mioi_bcwt(conf_info_ctrl_plm2vec_Push_mioi_bcwt),
      .conf_info_ctrl_plm2vec_Push_mioi_biwt_pff(conf_info_ctrl_plm2vec_Push_mioi_biwt_iff),
      .conf_info_ctrl_plm2vec_Push_mioi_bcwt_pff(conf_info_ctrl_plm2vec_Push_mioi_bcwt_iff)
    );
  assign conf_info_ctrl_plm2vec_Push_mioi_wen_comp = conf_info_ctrl_plm2vec_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi
    (
  clk, rst, conf_info_ctrl_dma2acc_val, conf_info_ctrl_dma2acc_rdy, conf_info_ctrl_dma2acc_msg,
      ConfigRead_wen, conf_info_ctrl_dma2acc_Push_mioi_oswt, conf_info_ctrl_dma2acc_Push_mioi_wen_comp,
      conf_info_ctrl_dma2acc_Push_mioi_idat, conf_info_ctrl_dma2acc_Push_mioi_irdy,
      conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg, conf_info_ctrl_dma2acc_Push_mioi_oswt_pff,
      conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_pff
);
  input clk;
  input rst;
  output conf_info_ctrl_dma2acc_val;
  input conf_info_ctrl_dma2acc_rdy;
  output [159:0] conf_info_ctrl_dma2acc_msg;
  input ConfigRead_wen;
  input conf_info_ctrl_dma2acc_Push_mioi_oswt;
  output conf_info_ctrl_dma2acc_Push_mioi_wen_comp;
  input [159:0] conf_info_ctrl_dma2acc_Push_mioi_idat;
  output conf_info_ctrl_dma2acc_Push_mioi_irdy;
  input conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg;
  input conf_info_ctrl_dma2acc_Push_mioi_oswt_pff;
  input conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire conf_info_ctrl_dma2acc_Push_mioi_biwt;
  wire conf_info_ctrl_dma2acc_Push_mioi_bdwt;
  wire conf_info_ctrl_dma2acc_Push_mioi_bcwt;
  wire conf_info_ctrl_dma2acc_Push_mioi_ivld_ConfigRead_sct;
  wire conf_info_ctrl_dma2acc_Push_mioi_wen_comp_reg;
  wire conf_info_ctrl_dma2acc_Push_mioi_biwt_iff;
  wire conf_info_ctrl_dma2acc_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd12),
  .width(32'sd160),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_ctrl_dma2acc_Push_mioi (
      .vld(conf_info_ctrl_dma2acc_val),
      .rdy(conf_info_ctrl_dma2acc_rdy),
      .dat(conf_info_ctrl_dma2acc_msg),
      .idat(conf_info_ctrl_dma2acc_Push_mioi_idat),
      .irdy(conf_info_ctrl_dma2acc_Push_mioi_irdy),
      .ivld(conf_info_ctrl_dma2acc_Push_mioi_ivld_ConfigRead_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi_conf_info_ctrl_dma2acc_Push_mio_wait_ctrl
      LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi_conf_info_ctrl_dma2acc_Push_mio_wait_ctrl_inst
      (
      .ConfigRead_wen(ConfigRead_wen),
      .conf_info_ctrl_dma2acc_Push_mioi_oswt(conf_info_ctrl_dma2acc_Push_mioi_oswt),
      .conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg(conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg),
      .conf_info_ctrl_dma2acc_Push_mioi_biwt(conf_info_ctrl_dma2acc_Push_mioi_biwt),
      .conf_info_ctrl_dma2acc_Push_mioi_bdwt(conf_info_ctrl_dma2acc_Push_mioi_bdwt),
      .conf_info_ctrl_dma2acc_Push_mioi_bcwt(conf_info_ctrl_dma2acc_Push_mioi_bcwt),
      .conf_info_ctrl_dma2acc_Push_mioi_ivld_ConfigRead_sct(conf_info_ctrl_dma2acc_Push_mioi_ivld_ConfigRead_sct),
      .conf_info_ctrl_dma2acc_Push_mioi_biwt_pff(conf_info_ctrl_dma2acc_Push_mioi_biwt_iff),
      .conf_info_ctrl_dma2acc_Push_mioi_oswt_pff(conf_info_ctrl_dma2acc_Push_mioi_oswt_pff),
      .conf_info_ctrl_dma2acc_Push_mioi_bcwt_pff(conf_info_ctrl_dma2acc_Push_mioi_bcwt_iff),
      .conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_pff(conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_pff)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi_conf_info_ctrl_dma2acc_Push_mio_wait_dp
      LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi_conf_info_ctrl_dma2acc_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_ctrl_dma2acc_Push_mioi_oswt(conf_info_ctrl_dma2acc_Push_mioi_oswt_pff),
      .conf_info_ctrl_dma2acc_Push_mioi_wen_comp(conf_info_ctrl_dma2acc_Push_mioi_wen_comp_reg),
      .conf_info_ctrl_dma2acc_Push_mioi_biwt(conf_info_ctrl_dma2acc_Push_mioi_biwt),
      .conf_info_ctrl_dma2acc_Push_mioi_bdwt(conf_info_ctrl_dma2acc_Push_mioi_bdwt),
      .conf_info_ctrl_dma2acc_Push_mioi_bcwt(conf_info_ctrl_dma2acc_Push_mioi_bcwt),
      .conf_info_ctrl_dma2acc_Push_mioi_biwt_pff(conf_info_ctrl_dma2acc_Push_mioi_biwt_iff),
      .conf_info_ctrl_dma2acc_Push_mioi_bcwt_pff(conf_info_ctrl_dma2acc_Push_mioi_bcwt_iff)
    );
  assign conf_info_ctrl_dma2acc_Push_mioi_wen_comp = conf_info_ctrl_dma2acc_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_Pop_mioi (
  clk, rst, conf_info_val, conf_info_rdy, conf_info_msg, conf_info_Pop_mioi_oswt,
      conf_info_Pop_mioi_wen_comp, conf_info_Pop_mioi_idat_mxwt, conf_info_Pop_mioi_oswt_pff
);
  input clk;
  input rst;
  input conf_info_val;
  output conf_info_rdy;
  input [159:0] conf_info_msg;
  input conf_info_Pop_mioi_oswt;
  output conf_info_Pop_mioi_wen_comp;
  output [159:0] conf_info_Pop_mioi_idat_mxwt;
  input conf_info_Pop_mioi_oswt_pff;


  // Interconnect Declarations
  wire conf_info_Pop_mioi_biwt;
  wire [159:0] conf_info_Pop_mioi_idat;
  wire conf_info_Pop_mioi_ivld;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd11),
  .width(32'sd160),
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
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_Pop_mioi_conf_info_Pop_mio_wait_ctrl
      LeakyreluConfig_ConfigRead_conf_info_Pop_mioi_conf_info_Pop_mio_wait_ctrl_inst
      (
      .conf_info_Pop_mioi_iswt0(conf_info_Pop_mioi_oswt_pff),
      .conf_info_Pop_mioi_ivld_oreg(conf_info_Pop_mioi_ivld),
      .conf_info_Pop_mioi_biwt(conf_info_Pop_mioi_biwt)
    );
  assign conf_info_Pop_mioi_idat_mxwt = conf_info_Pop_mioi_idat;
  assign conf_info_Pop_mioi_wen_comp = (~ conf_info_Pop_mioi_oswt_pff) | conf_info_Pop_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluConfig_ConfigRead
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluConfig_ConfigRead (
  clk, rst, conf_info_val, conf_info_rdy, conf_info_msg, conf_info_ctrl_dma2acc_val,
      conf_info_ctrl_dma2acc_rdy, conf_info_ctrl_dma2acc_msg, conf_info_ctrl_plm2vec_val,
      conf_info_ctrl_plm2vec_rdy, conf_info_ctrl_plm2vec_msg, conf_info_ctrl_acc2dma_val,
      conf_info_ctrl_acc2dma_rdy, conf_info_ctrl_acc2dma_msg
);
  input clk;
  input rst;
  input conf_info_val;
  output conf_info_rdy;
  input [159:0] conf_info_msg;
  output conf_info_ctrl_dma2acc_val;
  input conf_info_ctrl_dma2acc_rdy;
  output [159:0] conf_info_ctrl_dma2acc_msg;
  output conf_info_ctrl_plm2vec_val;
  input conf_info_ctrl_plm2vec_rdy;
  output [159:0] conf_info_ctrl_plm2vec_msg;
  output conf_info_ctrl_acc2dma_val;
  input conf_info_ctrl_acc2dma_rdy;
  output [159:0] conf_info_ctrl_acc2dma_msg;


  // Interconnect Declarations
  reg ConfigRead_wen;
  wire conf_info_Pop_mioi_wen_comp;
  wire [159:0] conf_info_Pop_mioi_idat_mxwt;
  wire conf_info_ctrl_dma2acc_Push_mioi_wen_comp;
  wire conf_info_ctrl_dma2acc_Push_mioi_irdy;
  wire conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg;
  wire conf_info_ctrl_plm2vec_Push_mioi_wen_comp;
  wire conf_info_ctrl_plm2vec_Push_mioi_irdy;
  wire conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg;
  wire conf_info_ctrl_acc2dma_Push_mioi_wen_comp;
  wire conf_info_ctrl_acc2dma_Push_mioi_irdy;
  wire conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg;
  wire [2:0] fsm_output;
  reg [159:0] reg_conf_info_ctrl_dma2acc_Push_mioi_idat_cse;
  wire ConfigRead_wen_rtff;
  reg reg_conf_info_Pop_mioi_oswt_tmp;
  reg reg_conf_info_ctrl_dma2acc_Push_mioi_oswt_tmp;
  wire while_mux_rmff;
  wire while_mux_3_rmff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_Pop_mioi LeakyreluConfig_ConfigRead_conf_info_Pop_mioi_inst
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
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_wait_dp LeakyreluConfig_ConfigRead_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_ctrl_dma2acc_Push_mioi_irdy(conf_info_ctrl_dma2acc_Push_mioi_irdy),
      .conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg(conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg),
      .conf_info_ctrl_plm2vec_Push_mioi_irdy(conf_info_ctrl_plm2vec_Push_mioi_irdy),
      .conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg(conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg),
      .conf_info_ctrl_acc2dma_Push_mioi_irdy(conf_info_ctrl_acc2dma_Push_mioi_irdy),
      .conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg(conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi LeakyreluConfig_ConfigRead_conf_info_ctrl_dma2acc_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_ctrl_dma2acc_val(conf_info_ctrl_dma2acc_val),
      .conf_info_ctrl_dma2acc_rdy(conf_info_ctrl_dma2acc_rdy),
      .conf_info_ctrl_dma2acc_msg(conf_info_ctrl_dma2acc_msg),
      .ConfigRead_wen(ConfigRead_wen),
      .conf_info_ctrl_dma2acc_Push_mioi_oswt(reg_conf_info_ctrl_dma2acc_Push_mioi_oswt_tmp),
      .conf_info_ctrl_dma2acc_Push_mioi_wen_comp(conf_info_ctrl_dma2acc_Push_mioi_wen_comp),
      .conf_info_ctrl_dma2acc_Push_mioi_idat(reg_conf_info_ctrl_dma2acc_Push_mioi_idat_cse),
      .conf_info_ctrl_dma2acc_Push_mioi_irdy(conf_info_ctrl_dma2acc_Push_mioi_irdy),
      .conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg(conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg),
      .conf_info_ctrl_dma2acc_Push_mioi_oswt_pff(while_mux_3_rmff),
      .conf_info_ctrl_dma2acc_Push_mioi_irdy_oreg_pff(conf_info_ctrl_dma2acc_Push_mioi_irdy)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi LeakyreluConfig_ConfigRead_conf_info_ctrl_plm2vec_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_ctrl_plm2vec_val(conf_info_ctrl_plm2vec_val),
      .conf_info_ctrl_plm2vec_rdy(conf_info_ctrl_plm2vec_rdy),
      .conf_info_ctrl_plm2vec_msg(conf_info_ctrl_plm2vec_msg),
      .ConfigRead_wen(ConfigRead_wen),
      .conf_info_ctrl_plm2vec_Push_mioi_oswt(reg_conf_info_ctrl_dma2acc_Push_mioi_oswt_tmp),
      .conf_info_ctrl_plm2vec_Push_mioi_wen_comp(conf_info_ctrl_plm2vec_Push_mioi_wen_comp),
      .conf_info_ctrl_plm2vec_Push_mioi_idat(reg_conf_info_ctrl_dma2acc_Push_mioi_idat_cse),
      .conf_info_ctrl_plm2vec_Push_mioi_irdy(conf_info_ctrl_plm2vec_Push_mioi_irdy),
      .conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg(conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg),
      .conf_info_ctrl_plm2vec_Push_mioi_oswt_pff(while_mux_3_rmff),
      .conf_info_ctrl_plm2vec_Push_mioi_irdy_oreg_pff(conf_info_ctrl_plm2vec_Push_mioi_irdy)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi LeakyreluConfig_ConfigRead_conf_info_ctrl_acc2dma_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_ctrl_acc2dma_val(conf_info_ctrl_acc2dma_val),
      .conf_info_ctrl_acc2dma_rdy(conf_info_ctrl_acc2dma_rdy),
      .conf_info_ctrl_acc2dma_msg(conf_info_ctrl_acc2dma_msg),
      .ConfigRead_wen(ConfigRead_wen),
      .conf_info_ctrl_acc2dma_Push_mioi_oswt(reg_conf_info_ctrl_dma2acc_Push_mioi_oswt_tmp),
      .conf_info_ctrl_acc2dma_Push_mioi_wen_comp(conf_info_ctrl_acc2dma_Push_mioi_wen_comp),
      .conf_info_ctrl_acc2dma_Push_mioi_idat(reg_conf_info_ctrl_dma2acc_Push_mioi_idat_cse),
      .conf_info_ctrl_acc2dma_Push_mioi_irdy(conf_info_ctrl_acc2dma_Push_mioi_irdy),
      .conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg(conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg),
      .conf_info_ctrl_acc2dma_Push_mioi_oswt_pff(while_mux_3_rmff),
      .conf_info_ctrl_acc2dma_Push_mioi_irdy_oreg_pff(conf_info_ctrl_acc2dma_Push_mioi_irdy)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_staller LeakyreluConfig_ConfigRead_staller_inst
      (
      .ConfigRead_wen(ConfigRead_wen_rtff),
      .conf_info_Pop_mioi_wen_comp(conf_info_Pop_mioi_wen_comp),
      .conf_info_ctrl_dma2acc_Push_mioi_wen_comp(conf_info_ctrl_dma2acc_Push_mioi_wen_comp),
      .conf_info_ctrl_plm2vec_Push_mioi_wen_comp(conf_info_ctrl_plm2vec_Push_mioi_wen_comp),
      .conf_info_ctrl_acc2dma_Push_mioi_wen_comp(conf_info_ctrl_acc2dma_Push_mioi_wen_comp)
    );
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead_ConfigRead_fsm LeakyreluConfig_ConfigRead_ConfigRead_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .ConfigRead_wen(ConfigRead_wen),
      .fsm_output(fsm_output)
    );
  assign while_mux_rmff = MUX_s_1_2_2(reg_conf_info_Pop_mioi_oswt_tmp, (~ (fsm_output[1])),
      ConfigRead_wen);
  assign while_mux_3_rmff = MUX_s_1_2_2(reg_conf_info_ctrl_dma2acc_Push_mioi_oswt_tmp,
      (fsm_output[1]), ConfigRead_wen);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      reg_conf_info_Pop_mioi_oswt_tmp <= 1'b0;
      reg_conf_info_ctrl_dma2acc_Push_mioi_oswt_tmp <= 1'b0;
      ConfigRead_wen <= 1'b1;
    end
    else begin
      reg_conf_info_Pop_mioi_oswt_tmp <= while_mux_rmff;
      reg_conf_info_ctrl_dma2acc_Push_mioi_oswt_tmp <= while_mux_3_rmff;
      ConfigRead_wen <= ConfigRead_wen_rtff;
    end
  end
  always @(posedge clk) begin
    if ( ConfigRead_wen & (fsm_output[1]) ) begin
      reg_conf_info_ctrl_dma2acc_Push_mioi_idat_cse <= conf_info_Pop_mioi_idat_mxwt;
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
//  Design Unit:    LeakyreluConfig
// ------------------------------------------------------------------


module LeakyreluConfig (
  clk, rst, conf_info_val, conf_info_rdy, conf_info_msg, conf_info_ctrl_dma2acc_val,
      conf_info_ctrl_dma2acc_rdy, conf_info_ctrl_dma2acc_msg, conf_info_ctrl_plm2vec_val,
      conf_info_ctrl_plm2vec_rdy, conf_info_ctrl_plm2vec_msg, conf_info_ctrl_acc2dma_val,
      conf_info_ctrl_acc2dma_rdy, conf_info_ctrl_acc2dma_msg
);
  input clk;
  input rst;
  input conf_info_val;
  output conf_info_rdy;
  input [159:0] conf_info_msg;
  output conf_info_ctrl_dma2acc_val;
  input conf_info_ctrl_dma2acc_rdy;
  output [159:0] conf_info_ctrl_dma2acc_msg;
  output conf_info_ctrl_plm2vec_val;
  input conf_info_ctrl_plm2vec_rdy;
  output [159:0] conf_info_ctrl_plm2vec_msg;
  output conf_info_ctrl_acc2dma_val;
  input conf_info_ctrl_acc2dma_rdy;
  output [159:0] conf_info_ctrl_acc2dma_msg;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_LeakyreluConfig_ConfigRead LeakyreluConfig_ConfigRead_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_val(conf_info_val),
      .conf_info_rdy(conf_info_rdy),
      .conf_info_msg(conf_info_msg),
      .conf_info_ctrl_dma2acc_val(conf_info_ctrl_dma2acc_val),
      .conf_info_ctrl_dma2acc_rdy(conf_info_ctrl_dma2acc_rdy),
      .conf_info_ctrl_dma2acc_msg(conf_info_ctrl_dma2acc_msg),
      .conf_info_ctrl_plm2vec_val(conf_info_ctrl_plm2vec_val),
      .conf_info_ctrl_plm2vec_rdy(conf_info_ctrl_plm2vec_rdy),
      .conf_info_ctrl_plm2vec_msg(conf_info_ctrl_plm2vec_msg),
      .conf_info_ctrl_acc2dma_val(conf_info_ctrl_acc2dma_val),
      .conf_info_ctrl_acc2dma_rdy(conf_info_ctrl_acc2dma_rdy),
      .conf_info_ctrl_acc2dma_msg(conf_info_ctrl_acc2dma_msg)
    );
endmodule



