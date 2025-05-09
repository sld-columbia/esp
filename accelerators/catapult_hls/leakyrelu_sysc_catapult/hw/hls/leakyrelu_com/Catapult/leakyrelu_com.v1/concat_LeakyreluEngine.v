
//------> ./LeakyreluEngine_ccs_ctrl_in_buf_wait_v4.v 
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



//------> ./LeakyreluEngine_ccs_out_buf_wait_v5.v 
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

//------> ./LeakyreluEngine.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2025.1/1166825 Production Release
//  HLS Date:       Sun Feb 16 14:04:49 PST 2025
// 
//  Generated by:   gtombesi@corsica
//  Generated date: Thu May  8 19:13:30 2025
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_Compute_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_Compute_fsm (
  clk, rst, Compute_wen, fsm_output
);
  input clk;
  input rst;
  input Compute_wen;
  output [2:0] fsm_output;
  reg [2:0] fsm_output;


  // FSM State Type Declaration for esp_acc_DUMMY_LeakyreluEngine_Compute_Compute_fsm_1
  parameter
    Compute_rlp_C_0 = 2'd0,
    while_C_0 = 2'd1,
    while_C_1 = 2'd2;

  reg [1:0] state_var;
  reg [1:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_DUMMY_LeakyreluEngine_Compute_Compute_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 3'b010;
        state_var_NS = while_C_1;
      end
      while_C_1 : begin
        fsm_output = 3'b100;
        state_var_NS = while_C_0;
      end
      // Compute_rlp_C_0
      default : begin
        fsm_output = 3'b001;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      state_var <= Compute_rlp_C_0;
    end
    else if ( Compute_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_staller
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_staller (
  Compute_wen, vec_in_a_Pop_mioi_wen_comp, vec_in_b_Pop_mioi_wen_comp, vec_out_Push_mioi_wen_comp
);
  output Compute_wen;
  input vec_in_a_Pop_mioi_wen_comp;
  input vec_in_b_Pop_mioi_wen_comp;
  input vec_out_Push_mioi_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign Compute_wen = vec_in_a_Pop_mioi_wen_comp & vec_in_b_Pop_mioi_wen_comp &
      vec_out_Push_mioi_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_vec_out_Push_mioi_vec_out_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_vec_out_Push_mioi_vec_out_Push_mio_wait_ctrl
    (
  vec_out_Push_mioi_iswt0, vec_out_Push_mioi_irdy_oreg, vec_out_Push_mioi_biwt
);
  input vec_out_Push_mioi_iswt0;
  input vec_out_Push_mioi_irdy_oreg;
  output vec_out_Push_mioi_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign vec_out_Push_mioi_biwt = vec_out_Push_mioi_iswt0 & vec_out_Push_mioi_irdy_oreg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_b_Pop_mioi_vec_in_b_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_b_Pop_mioi_vec_in_b_Pop_mio_wait_dp
    (
  clk, rst, vec_in_b_Pop_mioi_oswt, vec_in_b_Pop_mioi_wen_comp, vec_in_b_Pop_mioi_idat_mxwt,
      vec_in_b_Pop_mioi_biwt, vec_in_b_Pop_mioi_bdwt, vec_in_b_Pop_mioi_bcwt, vec_in_b_Pop_mioi_idat,
      vec_in_b_Pop_mioi_biwt_pff, vec_in_b_Pop_mioi_bcwt_pff
);
  input clk;
  input rst;
  input vec_in_b_Pop_mioi_oswt;
  output vec_in_b_Pop_mioi_wen_comp;
  output [511:0] vec_in_b_Pop_mioi_idat_mxwt;
  input vec_in_b_Pop_mioi_biwt;
  input vec_in_b_Pop_mioi_bdwt;
  output vec_in_b_Pop_mioi_bcwt;
  input [511:0] vec_in_b_Pop_mioi_idat;
  input vec_in_b_Pop_mioi_biwt_pff;
  output vec_in_b_Pop_mioi_bcwt_pff;


  // Interconnect Declarations
  reg [511:0] vec_in_b_Pop_mioi_idat_bfwt;
  reg vec_in_b_Pop_mioi_bcwt_reg;
  wire while_nor_2_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_2_rmff = ~((~(vec_in_b_Pop_mioi_bcwt | vec_in_b_Pop_mioi_biwt))
      | vec_in_b_Pop_mioi_bdwt);
  assign vec_in_b_Pop_mioi_idat_mxwt = MUX_v_512_2_2(vec_in_b_Pop_mioi_idat, vec_in_b_Pop_mioi_idat_bfwt,
      vec_in_b_Pop_mioi_bcwt);
  assign vec_in_b_Pop_mioi_wen_comp = (~ vec_in_b_Pop_mioi_oswt) | vec_in_b_Pop_mioi_biwt_pff
      | vec_in_b_Pop_mioi_bcwt_pff;
  assign vec_in_b_Pop_mioi_bcwt = vec_in_b_Pop_mioi_bcwt_reg;
  assign vec_in_b_Pop_mioi_bcwt_pff = while_nor_2_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      vec_in_b_Pop_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      vec_in_b_Pop_mioi_bcwt_reg <= while_nor_2_rmff;
    end
  end
  always @(posedge clk) begin
    if ( vec_in_b_Pop_mioi_biwt ) begin
      vec_in_b_Pop_mioi_idat_bfwt <= vec_in_b_Pop_mioi_idat;
    end
  end

  function automatic [511:0] MUX_v_512_2_2;
    input [511:0] input_0;
    input [511:0] input_1;
    input  sel;
    reg [511:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_512_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_b_Pop_mioi_vec_in_b_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_b_Pop_mioi_vec_in_b_Pop_mio_wait_ctrl
    (
  Compute_wen, vec_in_b_Pop_mioi_oswt, vec_in_b_Pop_mioi_ivld_oreg, vec_in_b_Pop_mioi_biwt,
      vec_in_b_Pop_mioi_bdwt, vec_in_b_Pop_mioi_bcwt, vec_in_b_Pop_mioi_irdy_Compute_sct,
      vec_in_b_Pop_mioi_biwt_pff, vec_in_b_Pop_mioi_oswt_pff, vec_in_b_Pop_mioi_bcwt_pff,
      vec_in_b_Pop_mioi_ivld_oreg_pff
);
  input Compute_wen;
  input vec_in_b_Pop_mioi_oswt;
  input vec_in_b_Pop_mioi_ivld_oreg;
  output vec_in_b_Pop_mioi_biwt;
  output vec_in_b_Pop_mioi_bdwt;
  input vec_in_b_Pop_mioi_bcwt;
  output vec_in_b_Pop_mioi_irdy_Compute_sct;
  output vec_in_b_Pop_mioi_biwt_pff;
  input vec_in_b_Pop_mioi_oswt_pff;
  input vec_in_b_Pop_mioi_bcwt_pff;
  input vec_in_b_Pop_mioi_ivld_oreg_pff;


  // Interconnect Declarations
  wire vec_in_b_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign vec_in_b_Pop_mioi_bdwt = vec_in_b_Pop_mioi_oswt & Compute_wen;
  assign vec_in_b_Pop_mioi_ogwt = vec_in_b_Pop_mioi_oswt & (~ vec_in_b_Pop_mioi_bcwt);
  assign vec_in_b_Pop_mioi_irdy_Compute_sct = vec_in_b_Pop_mioi_ogwt;
  assign vec_in_b_Pop_mioi_biwt = vec_in_b_Pop_mioi_ogwt & vec_in_b_Pop_mioi_ivld_oreg;
  assign vec_in_b_Pop_mioi_biwt_pff = vec_in_b_Pop_mioi_oswt_pff & (~ vec_in_b_Pop_mioi_bcwt_pff)
      & vec_in_b_Pop_mioi_ivld_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_wait_dp (
  clk, rst, vec_in_a_Pop_mioi_ivld, vec_in_a_Pop_mioi_ivld_oreg, vec_in_b_Pop_mioi_ivld,
      vec_in_b_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input vec_in_a_Pop_mioi_ivld;
  output vec_in_a_Pop_mioi_ivld_oreg;
  input vec_in_b_Pop_mioi_ivld;
  output vec_in_b_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  reg vec_in_a_Pop_mioi_ivld_oreg_rneg;
  reg vec_in_b_Pop_mioi_ivld_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign vec_in_a_Pop_mioi_ivld_oreg = ~ vec_in_a_Pop_mioi_ivld_oreg_rneg;
  assign vec_in_b_Pop_mioi_ivld_oreg = ~ vec_in_b_Pop_mioi_ivld_oreg_rneg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      vec_in_a_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      vec_in_b_Pop_mioi_ivld_oreg_rneg <= 1'b0;
    end
    else begin
      vec_in_a_Pop_mioi_ivld_oreg_rneg <= ~ vec_in_a_Pop_mioi_ivld;
      vec_in_b_Pop_mioi_ivld_oreg_rneg <= ~ vec_in_b_Pop_mioi_ivld;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_a_Pop_mioi_vec_in_a_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_a_Pop_mioi_vec_in_a_Pop_mio_wait_dp
    (
  clk, rst, vec_in_a_Pop_mioi_oswt, vec_in_a_Pop_mioi_wen_comp, vec_in_a_Pop_mioi_idat_mxwt,
      vec_in_a_Pop_mioi_biwt, vec_in_a_Pop_mioi_bdwt, vec_in_a_Pop_mioi_bcwt, vec_in_a_Pop_mioi_idat,
      vec_in_a_Pop_mioi_biwt_pff, vec_in_a_Pop_mioi_bcwt_pff
);
  input clk;
  input rst;
  input vec_in_a_Pop_mioi_oswt;
  output vec_in_a_Pop_mioi_wen_comp;
  output [511:0] vec_in_a_Pop_mioi_idat_mxwt;
  input vec_in_a_Pop_mioi_biwt;
  input vec_in_a_Pop_mioi_bdwt;
  output vec_in_a_Pop_mioi_bcwt;
  input [511:0] vec_in_a_Pop_mioi_idat;
  input vec_in_a_Pop_mioi_biwt_pff;
  output vec_in_a_Pop_mioi_bcwt_pff;


  // Interconnect Declarations
  reg [511:0] vec_in_a_Pop_mioi_idat_bfwt;
  reg vec_in_a_Pop_mioi_bcwt_reg;
  wire while_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign while_nor_rmff = ~((~(vec_in_a_Pop_mioi_bcwt | vec_in_a_Pop_mioi_biwt))
      | vec_in_a_Pop_mioi_bdwt);
  assign vec_in_a_Pop_mioi_idat_mxwt = MUX_v_512_2_2(vec_in_a_Pop_mioi_idat, vec_in_a_Pop_mioi_idat_bfwt,
      vec_in_a_Pop_mioi_bcwt);
  assign vec_in_a_Pop_mioi_wen_comp = (~ vec_in_a_Pop_mioi_oswt) | vec_in_a_Pop_mioi_biwt_pff
      | vec_in_a_Pop_mioi_bcwt_pff;
  assign vec_in_a_Pop_mioi_bcwt = vec_in_a_Pop_mioi_bcwt_reg;
  assign vec_in_a_Pop_mioi_bcwt_pff = while_nor_rmff;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      vec_in_a_Pop_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      vec_in_a_Pop_mioi_bcwt_reg <= while_nor_rmff;
    end
  end
  always @(posedge clk) begin
    if ( vec_in_a_Pop_mioi_biwt ) begin
      vec_in_a_Pop_mioi_idat_bfwt <= vec_in_a_Pop_mioi_idat;
    end
  end

  function automatic [511:0] MUX_v_512_2_2;
    input [511:0] input_0;
    input [511:0] input_1;
    input  sel;
    reg [511:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_512_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_a_Pop_mioi_vec_in_a_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_a_Pop_mioi_vec_in_a_Pop_mio_wait_ctrl
    (
  Compute_wen, vec_in_a_Pop_mioi_oswt, vec_in_a_Pop_mioi_ivld_oreg, vec_in_a_Pop_mioi_biwt,
      vec_in_a_Pop_mioi_bdwt, vec_in_a_Pop_mioi_bcwt, vec_in_a_Pop_mioi_irdy_Compute_sct,
      vec_in_a_Pop_mioi_biwt_pff, vec_in_a_Pop_mioi_oswt_pff, vec_in_a_Pop_mioi_bcwt_pff,
      vec_in_a_Pop_mioi_ivld_oreg_pff
);
  input Compute_wen;
  input vec_in_a_Pop_mioi_oswt;
  input vec_in_a_Pop_mioi_ivld_oreg;
  output vec_in_a_Pop_mioi_biwt;
  output vec_in_a_Pop_mioi_bdwt;
  input vec_in_a_Pop_mioi_bcwt;
  output vec_in_a_Pop_mioi_irdy_Compute_sct;
  output vec_in_a_Pop_mioi_biwt_pff;
  input vec_in_a_Pop_mioi_oswt_pff;
  input vec_in_a_Pop_mioi_bcwt_pff;
  input vec_in_a_Pop_mioi_ivld_oreg_pff;


  // Interconnect Declarations
  wire vec_in_a_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign vec_in_a_Pop_mioi_bdwt = vec_in_a_Pop_mioi_oswt & Compute_wen;
  assign vec_in_a_Pop_mioi_ogwt = vec_in_a_Pop_mioi_oswt & (~ vec_in_a_Pop_mioi_bcwt);
  assign vec_in_a_Pop_mioi_irdy_Compute_sct = vec_in_a_Pop_mioi_ogwt;
  assign vec_in_a_Pop_mioi_biwt = vec_in_a_Pop_mioi_ogwt & vec_in_a_Pop_mioi_ivld_oreg;
  assign vec_in_a_Pop_mioi_biwt_pff = vec_in_a_Pop_mioi_oswt_pff & (~ vec_in_a_Pop_mioi_bcwt_pff)
      & vec_in_a_Pop_mioi_ivld_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_vec_out_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_vec_out_Push_mioi (
  clk, rst, vec_out_val, vec_out_rdy, vec_out_msg, vec_out_Push_mioi_oswt, vec_out_Push_mioi_wen_comp,
      vec_out_Push_mioi_idat, vec_out_Push_mioi_oswt_pff
);
  input clk;
  input rst;
  output vec_out_val;
  input vec_out_rdy;
  output [511:0] vec_out_msg;
  input vec_out_Push_mioi_oswt;
  output vec_out_Push_mioi_wen_comp;
  input [511:0] vec_out_Push_mioi_idat;
  input vec_out_Push_mioi_oswt_pff;


  // Interconnect Declarations
  wire vec_out_Push_mioi_biwt;
  wire vec_out_Push_mioi_irdy;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd7),
  .width(32'sd512),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) vec_out_Push_mioi (
      .vld(vec_out_val),
      .rdy(vec_out_rdy),
      .dat(vec_out_msg),
      .idat(vec_out_Push_mioi_idat),
      .irdy(vec_out_Push_mioi_irdy),
      .ivld(vec_out_Push_mioi_oswt),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_vec_out_Push_mioi_vec_out_Push_mio_wait_ctrl
      LeakyreluEngine_Compute_vec_out_Push_mioi_vec_out_Push_mio_wait_ctrl_inst (
      .vec_out_Push_mioi_iswt0(vec_out_Push_mioi_oswt_pff),
      .vec_out_Push_mioi_irdy_oreg(vec_out_Push_mioi_irdy),
      .vec_out_Push_mioi_biwt(vec_out_Push_mioi_biwt)
    );
  assign vec_out_Push_mioi_wen_comp = (~ vec_out_Push_mioi_oswt_pff) | vec_out_Push_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_b_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_b_Pop_mioi (
  clk, rst, vec_in_b_val, vec_in_b_rdy, vec_in_b_msg, Compute_wen, vec_in_b_Pop_mioi_oswt,
      vec_in_b_Pop_mioi_wen_comp, vec_in_b_Pop_mioi_idat_mxwt, vec_in_b_Pop_mioi_ivld,
      vec_in_b_Pop_mioi_ivld_oreg, vec_in_b_Pop_mioi_oswt_pff, vec_in_b_Pop_mioi_ivld_oreg_pff
);
  input clk;
  input rst;
  input vec_in_b_val;
  output vec_in_b_rdy;
  input [511:0] vec_in_b_msg;
  input Compute_wen;
  input vec_in_b_Pop_mioi_oswt;
  output vec_in_b_Pop_mioi_wen_comp;
  output [511:0] vec_in_b_Pop_mioi_idat_mxwt;
  output vec_in_b_Pop_mioi_ivld;
  input vec_in_b_Pop_mioi_ivld_oreg;
  input vec_in_b_Pop_mioi_oswt_pff;
  input vec_in_b_Pop_mioi_ivld_oreg_pff;


  // Interconnect Declarations
  wire vec_in_b_Pop_mioi_biwt;
  wire vec_in_b_Pop_mioi_bdwt;
  wire vec_in_b_Pop_mioi_bcwt;
  wire [511:0] vec_in_b_Pop_mioi_idat;
  wire vec_in_b_Pop_mioi_irdy_Compute_sct;
  wire vec_in_b_Pop_mioi_wen_comp_reg;
  wire vec_in_b_Pop_mioi_biwt_iff;
  wire vec_in_b_Pop_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd6),
  .width(32'sd512),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) vec_in_b_Pop_mioi (
      .vld(vec_in_b_val),
      .rdy(vec_in_b_rdy),
      .dat(vec_in_b_msg),
      .idat(vec_in_b_Pop_mioi_idat),
      .irdy(vec_in_b_Pop_mioi_irdy_Compute_sct),
      .ivld(vec_in_b_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_b_Pop_mioi_vec_in_b_Pop_mio_wait_ctrl
      LeakyreluEngine_Compute_vec_in_b_Pop_mioi_vec_in_b_Pop_mio_wait_ctrl_inst (
      .Compute_wen(Compute_wen),
      .vec_in_b_Pop_mioi_oswt(vec_in_b_Pop_mioi_oswt),
      .vec_in_b_Pop_mioi_ivld_oreg(vec_in_b_Pop_mioi_ivld_oreg),
      .vec_in_b_Pop_mioi_biwt(vec_in_b_Pop_mioi_biwt),
      .vec_in_b_Pop_mioi_bdwt(vec_in_b_Pop_mioi_bdwt),
      .vec_in_b_Pop_mioi_bcwt(vec_in_b_Pop_mioi_bcwt),
      .vec_in_b_Pop_mioi_irdy_Compute_sct(vec_in_b_Pop_mioi_irdy_Compute_sct),
      .vec_in_b_Pop_mioi_biwt_pff(vec_in_b_Pop_mioi_biwt_iff),
      .vec_in_b_Pop_mioi_oswt_pff(vec_in_b_Pop_mioi_oswt_pff),
      .vec_in_b_Pop_mioi_bcwt_pff(vec_in_b_Pop_mioi_bcwt_iff),
      .vec_in_b_Pop_mioi_ivld_oreg_pff(vec_in_b_Pop_mioi_ivld_oreg_pff)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_b_Pop_mioi_vec_in_b_Pop_mio_wait_dp
      LeakyreluEngine_Compute_vec_in_b_Pop_mioi_vec_in_b_Pop_mio_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .vec_in_b_Pop_mioi_oswt(vec_in_b_Pop_mioi_oswt_pff),
      .vec_in_b_Pop_mioi_wen_comp(vec_in_b_Pop_mioi_wen_comp_reg),
      .vec_in_b_Pop_mioi_idat_mxwt(vec_in_b_Pop_mioi_idat_mxwt),
      .vec_in_b_Pop_mioi_biwt(vec_in_b_Pop_mioi_biwt),
      .vec_in_b_Pop_mioi_bdwt(vec_in_b_Pop_mioi_bdwt),
      .vec_in_b_Pop_mioi_bcwt(vec_in_b_Pop_mioi_bcwt),
      .vec_in_b_Pop_mioi_idat(vec_in_b_Pop_mioi_idat),
      .vec_in_b_Pop_mioi_biwt_pff(vec_in_b_Pop_mioi_biwt_iff),
      .vec_in_b_Pop_mioi_bcwt_pff(vec_in_b_Pop_mioi_bcwt_iff)
    );
  assign vec_in_b_Pop_mioi_wen_comp = vec_in_b_Pop_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_a_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_a_Pop_mioi (
  clk, rst, vec_in_a_val, vec_in_a_rdy, vec_in_a_msg, Compute_wen, vec_in_a_Pop_mioi_oswt,
      vec_in_a_Pop_mioi_wen_comp, vec_in_a_Pop_mioi_idat_mxwt, vec_in_a_Pop_mioi_ivld,
      vec_in_a_Pop_mioi_ivld_oreg, vec_in_a_Pop_mioi_oswt_pff, vec_in_a_Pop_mioi_ivld_oreg_pff
);
  input clk;
  input rst;
  input vec_in_a_val;
  output vec_in_a_rdy;
  input [511:0] vec_in_a_msg;
  input Compute_wen;
  input vec_in_a_Pop_mioi_oswt;
  output vec_in_a_Pop_mioi_wen_comp;
  output [511:0] vec_in_a_Pop_mioi_idat_mxwt;
  output vec_in_a_Pop_mioi_ivld;
  input vec_in_a_Pop_mioi_ivld_oreg;
  input vec_in_a_Pop_mioi_oswt_pff;
  input vec_in_a_Pop_mioi_ivld_oreg_pff;


  // Interconnect Declarations
  wire vec_in_a_Pop_mioi_biwt;
  wire vec_in_a_Pop_mioi_bdwt;
  wire vec_in_a_Pop_mioi_bcwt;
  wire [511:0] vec_in_a_Pop_mioi_idat;
  wire vec_in_a_Pop_mioi_irdy_Compute_sct;
  wire vec_in_a_Pop_mioi_wen_comp_reg;
  wire vec_in_a_Pop_mioi_biwt_iff;
  wire vec_in_a_Pop_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd5),
  .width(32'sd512),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) vec_in_a_Pop_mioi (
      .vld(vec_in_a_val),
      .rdy(vec_in_a_rdy),
      .dat(vec_in_a_msg),
      .idat(vec_in_a_Pop_mioi_idat),
      .irdy(vec_in_a_Pop_mioi_irdy_Compute_sct),
      .ivld(vec_in_a_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_a_Pop_mioi_vec_in_a_Pop_mio_wait_ctrl
      LeakyreluEngine_Compute_vec_in_a_Pop_mioi_vec_in_a_Pop_mio_wait_ctrl_inst (
      .Compute_wen(Compute_wen),
      .vec_in_a_Pop_mioi_oswt(vec_in_a_Pop_mioi_oswt),
      .vec_in_a_Pop_mioi_ivld_oreg(vec_in_a_Pop_mioi_ivld_oreg),
      .vec_in_a_Pop_mioi_biwt(vec_in_a_Pop_mioi_biwt),
      .vec_in_a_Pop_mioi_bdwt(vec_in_a_Pop_mioi_bdwt),
      .vec_in_a_Pop_mioi_bcwt(vec_in_a_Pop_mioi_bcwt),
      .vec_in_a_Pop_mioi_irdy_Compute_sct(vec_in_a_Pop_mioi_irdy_Compute_sct),
      .vec_in_a_Pop_mioi_biwt_pff(vec_in_a_Pop_mioi_biwt_iff),
      .vec_in_a_Pop_mioi_oswt_pff(vec_in_a_Pop_mioi_oswt_pff),
      .vec_in_a_Pop_mioi_bcwt_pff(vec_in_a_Pop_mioi_bcwt_iff),
      .vec_in_a_Pop_mioi_ivld_oreg_pff(vec_in_a_Pop_mioi_ivld_oreg_pff)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_a_Pop_mioi_vec_in_a_Pop_mio_wait_dp
      LeakyreluEngine_Compute_vec_in_a_Pop_mioi_vec_in_a_Pop_mio_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .vec_in_a_Pop_mioi_oswt(vec_in_a_Pop_mioi_oswt_pff),
      .vec_in_a_Pop_mioi_wen_comp(vec_in_a_Pop_mioi_wen_comp_reg),
      .vec_in_a_Pop_mioi_idat_mxwt(vec_in_a_Pop_mioi_idat_mxwt),
      .vec_in_a_Pop_mioi_biwt(vec_in_a_Pop_mioi_biwt),
      .vec_in_a_Pop_mioi_bdwt(vec_in_a_Pop_mioi_bdwt),
      .vec_in_a_Pop_mioi_bcwt(vec_in_a_Pop_mioi_bcwt),
      .vec_in_a_Pop_mioi_idat(vec_in_a_Pop_mioi_idat),
      .vec_in_a_Pop_mioi_biwt_pff(vec_in_a_Pop_mioi_biwt_iff),
      .vec_in_a_Pop_mioi_bcwt_pff(vec_in_a_Pop_mioi_bcwt_iff)
    );
  assign vec_in_a_Pop_mioi_wen_comp = vec_in_a_Pop_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_LeakyreluEngine_Compute
// ------------------------------------------------------------------


module esp_acc_DUMMY_LeakyreluEngine_Compute (
  clk, rst, vec_in_a_val, vec_in_a_rdy, vec_in_a_msg, vec_in_b_val, vec_in_b_rdy,
      vec_in_b_msg, vec_out_val, vec_out_rdy, vec_out_msg
);
  input clk;
  input rst;
  input vec_in_a_val;
  output vec_in_a_rdy;
  input [511:0] vec_in_a_msg;
  input vec_in_b_val;
  output vec_in_b_rdy;
  input [511:0] vec_in_b_msg;
  output vec_out_val;
  input vec_out_rdy;
  output [511:0] vec_out_msg;


  // Interconnect Declarations
  reg Compute_wen;
  wire vec_in_a_Pop_mioi_wen_comp;
  wire [511:0] vec_in_a_Pop_mioi_idat_mxwt;
  wire vec_in_a_Pop_mioi_ivld;
  wire vec_in_a_Pop_mioi_ivld_oreg;
  wire vec_in_b_Pop_mioi_wen_comp;
  wire [511:0] vec_in_b_Pop_mioi_idat_mxwt;
  wire vec_in_b_Pop_mioi_ivld;
  wire vec_in_b_Pop_mioi_ivld_oreg;
  wire vec_out_Push_mioi_wen_comp;
  wire [2:0] fsm_output;
  reg vec_out_Push_mioi_idat_511;
  reg vec_out_Push_mioi_idat_479;
  reg vec_out_Push_mioi_idat_447;
  reg vec_out_Push_mioi_idat_415;
  reg vec_out_Push_mioi_idat_383;
  reg vec_out_Push_mioi_idat_351;
  reg vec_out_Push_mioi_idat_319;
  reg vec_out_Push_mioi_idat_287;
  wire while_and_ssc;
  reg vec_out_Push_mioi_idat_255;
  reg vec_out_Push_mioi_idat_223;
  reg vec_out_Push_mioi_idat_191;
  reg vec_out_Push_mioi_idat_159;
  reg vec_out_Push_mioi_idat_127;
  reg vec_out_Push_mioi_idat_95;
  reg vec_out_Push_mioi_idat_63;
  reg vec_out_Push_mioi_idat_31;
  reg vec_out_Push_mioi_idat_510;
  reg [29:0] vec_out_Push_mioi_idat_509_480;
  reg vec_out_Push_mioi_idat_478;
  reg [29:0] vec_out_Push_mioi_idat_477_448;
  reg vec_out_Push_mioi_idat_446;
  reg [29:0] vec_out_Push_mioi_idat_445_416;
  reg vec_out_Push_mioi_idat_414;
  reg [29:0] vec_out_Push_mioi_idat_413_384;
  reg vec_out_Push_mioi_idat_382;
  reg [29:0] vec_out_Push_mioi_idat_381_352;
  reg vec_out_Push_mioi_idat_350;
  reg [29:0] vec_out_Push_mioi_idat_349_320;
  reg vec_out_Push_mioi_idat_318;
  reg [29:0] vec_out_Push_mioi_idat_317_288;
  reg vec_out_Push_mioi_idat_286;
  reg [29:0] vec_out_Push_mioi_idat_285_256;
  reg vec_out_Push_mioi_idat_254;
  reg [29:0] vec_out_Push_mioi_idat_253_224;
  reg vec_out_Push_mioi_idat_222;
  reg [29:0] vec_out_Push_mioi_idat_221_192;
  reg vec_out_Push_mioi_idat_190;
  reg [29:0] vec_out_Push_mioi_idat_189_160;
  reg vec_out_Push_mioi_idat_158;
  reg [29:0] vec_out_Push_mioi_idat_157_128;
  reg vec_out_Push_mioi_idat_126;
  reg [29:0] vec_out_Push_mioi_idat_125_96;
  reg vec_out_Push_mioi_idat_94;
  reg [29:0] vec_out_Push_mioi_idat_93_64;
  reg vec_out_Push_mioi_idat_62;
  reg [29:0] vec_out_Push_mioi_idat_61_32;
  reg vec_out_Push_mioi_idat_30;
  reg [29:0] vec_out_Push_mioi_idat_29_0;
  wire [31:0] while_for_acc_1_cse_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_sva_1;
  wire [31:0] while_for_acc_1_cse_15_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_15_sva_1;
  wire [31:0] while_for_acc_1_cse_14_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_14_sva_1;
  wire [31:0] while_for_acc_1_cse_13_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_13_sva_1;
  wire [31:0] while_for_acc_1_cse_12_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_12_sva_1;
  wire [31:0] while_for_acc_1_cse_11_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_11_sva_1;
  wire [31:0] while_for_acc_1_cse_10_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_10_sva_1;
  wire [31:0] while_for_acc_1_cse_9_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_9_sva_1;
  wire [31:0] while_for_acc_1_cse_8_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_8_sva_1;
  wire [31:0] while_for_acc_1_cse_7_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_7_sva_1;
  wire [31:0] while_for_acc_1_cse_6_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_6_sva_1;
  wire [31:0] while_for_acc_1_cse_5_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_5_sva_1;
  wire [31:0] while_for_acc_1_cse_4_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_4_sva_1;
  wire [31:0] while_for_acc_1_cse_3_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_3_sva_1;
  wire [31:0] while_for_acc_1_cse_2_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_2_sva_1;
  wire [31:0] while_for_acc_1_cse_1_sva_1;
  wire [32:0] nl_while_for_acc_1_cse_1_sva_1;
  wire Compute_wen_rtff;
  reg reg_vec_in_a_Pop_mioi_oswt_tmp;
  reg reg_vec_out_Push_mioi_oswt_tmp;
  wire while_mux_rmff;
  wire while_mux_1_rmff;
  wire vec_out_Push_mioi_idat_255_224_mx0c1;
  wire vec_out_Push_mioi_idat_287_256_mx0c1;
  wire vec_out_Push_mioi_idat_223_192_mx0c1;
  wire vec_out_Push_mioi_idat_319_288_mx0c1;
  wire vec_out_Push_mioi_idat_191_160_mx0c1;
  wire vec_out_Push_mioi_idat_351_320_mx0c1;
  wire vec_out_Push_mioi_idat_159_128_mx0c1;
  wire vec_out_Push_mioi_idat_383_352_mx0c1;
  wire vec_out_Push_mioi_idat_127_96_mx0c1;
  wire vec_out_Push_mioi_idat_415_384_mx0c1;
  wire vec_out_Push_mioi_idat_95_64_mx0c1;
  wire vec_out_Push_mioi_idat_447_416_mx0c1;
  wire vec_out_Push_mioi_idat_63_32_mx0c1;
  wire vec_out_Push_mioi_idat_479_448_mx0c1;
  wire vec_out_Push_mioi_idat_31_0_mx0c1;
  wire vec_out_Push_mioi_idat_511_480_mx0c1;

  wire[32:0] while_for_8_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_8_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_9_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_9_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_7_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_7_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_10_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_10_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_6_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_6_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_11_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_11_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_5_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_5_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_12_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_12_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_4_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_4_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_13_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_13_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_3_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_3_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_14_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_14_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_2_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_2_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_15_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_15_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_1_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_1_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[32:0] while_for_16_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;
  wire[33:0] nl_while_for_16_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [511:0] nl_LeakyreluEngine_Compute_vec_out_Push_mioi_inst_vec_out_Push_mioi_idat;
  assign nl_LeakyreluEngine_Compute_vec_out_Push_mioi_inst_vec_out_Push_mioi_idat
      = {vec_out_Push_mioi_idat_511 , vec_out_Push_mioi_idat_510 , vec_out_Push_mioi_idat_509_480
      , vec_out_Push_mioi_idat_479 , vec_out_Push_mioi_idat_478 , vec_out_Push_mioi_idat_477_448
      , vec_out_Push_mioi_idat_447 , vec_out_Push_mioi_idat_446 , vec_out_Push_mioi_idat_445_416
      , vec_out_Push_mioi_idat_415 , vec_out_Push_mioi_idat_414 , vec_out_Push_mioi_idat_413_384
      , vec_out_Push_mioi_idat_383 , vec_out_Push_mioi_idat_382 , vec_out_Push_mioi_idat_381_352
      , vec_out_Push_mioi_idat_351 , vec_out_Push_mioi_idat_350 , vec_out_Push_mioi_idat_349_320
      , vec_out_Push_mioi_idat_319 , vec_out_Push_mioi_idat_318 , vec_out_Push_mioi_idat_317_288
      , vec_out_Push_mioi_idat_287 , vec_out_Push_mioi_idat_286 , vec_out_Push_mioi_idat_285_256
      , vec_out_Push_mioi_idat_255 , vec_out_Push_mioi_idat_254 , vec_out_Push_mioi_idat_253_224
      , vec_out_Push_mioi_idat_223 , vec_out_Push_mioi_idat_222 , vec_out_Push_mioi_idat_221_192
      , vec_out_Push_mioi_idat_191 , vec_out_Push_mioi_idat_190 , vec_out_Push_mioi_idat_189_160
      , vec_out_Push_mioi_idat_159 , vec_out_Push_mioi_idat_158 , vec_out_Push_mioi_idat_157_128
      , vec_out_Push_mioi_idat_127 , vec_out_Push_mioi_idat_126 , vec_out_Push_mioi_idat_125_96
      , vec_out_Push_mioi_idat_95 , vec_out_Push_mioi_idat_94 , vec_out_Push_mioi_idat_93_64
      , vec_out_Push_mioi_idat_63 , vec_out_Push_mioi_idat_62 , vec_out_Push_mioi_idat_61_32
      , vec_out_Push_mioi_idat_31 , vec_out_Push_mioi_idat_30 , vec_out_Push_mioi_idat_29_0};
  esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_a_Pop_mioi LeakyreluEngine_Compute_vec_in_a_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .vec_in_a_val(vec_in_a_val),
      .vec_in_a_rdy(vec_in_a_rdy),
      .vec_in_a_msg(vec_in_a_msg),
      .Compute_wen(Compute_wen),
      .vec_in_a_Pop_mioi_oswt(reg_vec_in_a_Pop_mioi_oswt_tmp),
      .vec_in_a_Pop_mioi_wen_comp(vec_in_a_Pop_mioi_wen_comp),
      .vec_in_a_Pop_mioi_idat_mxwt(vec_in_a_Pop_mioi_idat_mxwt),
      .vec_in_a_Pop_mioi_ivld(vec_in_a_Pop_mioi_ivld),
      .vec_in_a_Pop_mioi_ivld_oreg(vec_in_a_Pop_mioi_ivld_oreg),
      .vec_in_a_Pop_mioi_oswt_pff(while_mux_rmff),
      .vec_in_a_Pop_mioi_ivld_oreg_pff(vec_in_a_Pop_mioi_ivld)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_wait_dp LeakyreluEngine_Compute_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .vec_in_a_Pop_mioi_ivld(vec_in_a_Pop_mioi_ivld),
      .vec_in_a_Pop_mioi_ivld_oreg(vec_in_a_Pop_mioi_ivld_oreg),
      .vec_in_b_Pop_mioi_ivld(vec_in_b_Pop_mioi_ivld),
      .vec_in_b_Pop_mioi_ivld_oreg(vec_in_b_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_vec_in_b_Pop_mioi LeakyreluEngine_Compute_vec_in_b_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .vec_in_b_val(vec_in_b_val),
      .vec_in_b_rdy(vec_in_b_rdy),
      .vec_in_b_msg(vec_in_b_msg),
      .Compute_wen(Compute_wen),
      .vec_in_b_Pop_mioi_oswt(reg_vec_in_a_Pop_mioi_oswt_tmp),
      .vec_in_b_Pop_mioi_wen_comp(vec_in_b_Pop_mioi_wen_comp),
      .vec_in_b_Pop_mioi_idat_mxwt(vec_in_b_Pop_mioi_idat_mxwt),
      .vec_in_b_Pop_mioi_ivld(vec_in_b_Pop_mioi_ivld),
      .vec_in_b_Pop_mioi_ivld_oreg(vec_in_b_Pop_mioi_ivld_oreg),
      .vec_in_b_Pop_mioi_oswt_pff(while_mux_rmff),
      .vec_in_b_Pop_mioi_ivld_oreg_pff(vec_in_b_Pop_mioi_ivld)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_vec_out_Push_mioi LeakyreluEngine_Compute_vec_out_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .vec_out_val(vec_out_val),
      .vec_out_rdy(vec_out_rdy),
      .vec_out_msg(vec_out_msg),
      .vec_out_Push_mioi_oswt(reg_vec_out_Push_mioi_oswt_tmp),
      .vec_out_Push_mioi_wen_comp(vec_out_Push_mioi_wen_comp),
      .vec_out_Push_mioi_idat(nl_LeakyreluEngine_Compute_vec_out_Push_mioi_inst_vec_out_Push_mioi_idat[511:0]),
      .vec_out_Push_mioi_oswt_pff(while_mux_1_rmff)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_staller LeakyreluEngine_Compute_staller_inst
      (
      .Compute_wen(Compute_wen_rtff),
      .vec_in_a_Pop_mioi_wen_comp(vec_in_a_Pop_mioi_wen_comp),
      .vec_in_b_Pop_mioi_wen_comp(vec_in_b_Pop_mioi_wen_comp),
      .vec_out_Push_mioi_wen_comp(vec_out_Push_mioi_wen_comp)
    );
  esp_acc_DUMMY_LeakyreluEngine_Compute_Compute_fsm LeakyreluEngine_Compute_Compute_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .Compute_wen(Compute_wen),
      .fsm_output(fsm_output)
    );
  assign while_mux_rmff = MUX_s_1_2_2(reg_vec_in_a_Pop_mioi_oswt_tmp, (~ (fsm_output[1])),
      Compute_wen);
  assign while_mux_1_rmff = MUX_s_1_2_2(reg_vec_out_Push_mioi_oswt_tmp, (fsm_output[1]),
      Compute_wen);
  assign while_and_ssc = Compute_wen & (fsm_output[1]);
  assign nl_while_for_acc_1_cse_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[511:480]) +
      (vec_in_b_Pop_mioi_idat_mxwt[511:480]);
  assign while_for_acc_1_cse_sva_1 = nl_while_for_acc_1_cse_sva_1[31:0];
  assign nl_while_for_acc_1_cse_1_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[31:0]) + (vec_in_b_Pop_mioi_idat_mxwt[31:0]);
  assign while_for_acc_1_cse_1_sva_1 = nl_while_for_acc_1_cse_1_sva_1[31:0];
  assign nl_while_for_acc_1_cse_15_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[479:448])
      + (vec_in_b_Pop_mioi_idat_mxwt[479:448]);
  assign while_for_acc_1_cse_15_sva_1 = nl_while_for_acc_1_cse_15_sva_1[31:0];
  assign nl_while_for_acc_1_cse_2_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[63:32]) +
      (vec_in_b_Pop_mioi_idat_mxwt[63:32]);
  assign while_for_acc_1_cse_2_sva_1 = nl_while_for_acc_1_cse_2_sva_1[31:0];
  assign nl_while_for_acc_1_cse_14_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[447:416])
      + (vec_in_b_Pop_mioi_idat_mxwt[447:416]);
  assign while_for_acc_1_cse_14_sva_1 = nl_while_for_acc_1_cse_14_sva_1[31:0];
  assign nl_while_for_acc_1_cse_3_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[95:64]) +
      (vec_in_b_Pop_mioi_idat_mxwt[95:64]);
  assign while_for_acc_1_cse_3_sva_1 = nl_while_for_acc_1_cse_3_sva_1[31:0];
  assign nl_while_for_acc_1_cse_13_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[415:384])
      + (vec_in_b_Pop_mioi_idat_mxwt[415:384]);
  assign while_for_acc_1_cse_13_sva_1 = nl_while_for_acc_1_cse_13_sva_1[31:0];
  assign nl_while_for_acc_1_cse_4_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[127:96]) +
      (vec_in_b_Pop_mioi_idat_mxwt[127:96]);
  assign while_for_acc_1_cse_4_sva_1 = nl_while_for_acc_1_cse_4_sva_1[31:0];
  assign nl_while_for_acc_1_cse_12_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[383:352])
      + (vec_in_b_Pop_mioi_idat_mxwt[383:352]);
  assign while_for_acc_1_cse_12_sva_1 = nl_while_for_acc_1_cse_12_sva_1[31:0];
  assign nl_while_for_acc_1_cse_5_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[159:128])
      + (vec_in_b_Pop_mioi_idat_mxwt[159:128]);
  assign while_for_acc_1_cse_5_sva_1 = nl_while_for_acc_1_cse_5_sva_1[31:0];
  assign nl_while_for_acc_1_cse_11_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[351:320])
      + (vec_in_b_Pop_mioi_idat_mxwt[351:320]);
  assign while_for_acc_1_cse_11_sva_1 = nl_while_for_acc_1_cse_11_sva_1[31:0];
  assign nl_while_for_acc_1_cse_6_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[191:160])
      + (vec_in_b_Pop_mioi_idat_mxwt[191:160]);
  assign while_for_acc_1_cse_6_sva_1 = nl_while_for_acc_1_cse_6_sva_1[31:0];
  assign nl_while_for_acc_1_cse_10_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[319:288])
      + (vec_in_b_Pop_mioi_idat_mxwt[319:288]);
  assign while_for_acc_1_cse_10_sva_1 = nl_while_for_acc_1_cse_10_sva_1[31:0];
  assign nl_while_for_acc_1_cse_7_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[223:192])
      + (vec_in_b_Pop_mioi_idat_mxwt[223:192]);
  assign while_for_acc_1_cse_7_sva_1 = nl_while_for_acc_1_cse_7_sva_1[31:0];
  assign nl_while_for_acc_1_cse_9_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[287:256])
      + (vec_in_b_Pop_mioi_idat_mxwt[287:256]);
  assign while_for_acc_1_cse_9_sva_1 = nl_while_for_acc_1_cse_9_sva_1[31:0];
  assign nl_while_for_acc_1_cse_8_sva_1 = (vec_in_a_Pop_mioi_idat_mxwt[255:224])
      + (vec_in_b_Pop_mioi_idat_mxwt[255:224]);
  assign while_for_acc_1_cse_8_sva_1 = nl_while_for_acc_1_cse_8_sva_1[31:0];
  assign nl_while_for_8_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_8_sva_1);
  assign while_for_8_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_8_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_255_224_mx0c1 = (~ (readslicef_33_1_32(while_for_8_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_9_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_9_sva_1);
  assign while_for_9_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_9_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_287_256_mx0c1 = (~ (readslicef_33_1_32(while_for_9_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_7_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_7_sva_1);
  assign while_for_7_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_7_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_223_192_mx0c1 = (~ (readslicef_33_1_32(while_for_7_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_10_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_10_sva_1);
  assign while_for_10_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_10_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_319_288_mx0c1 = (~ (readslicef_33_1_32(while_for_10_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_6_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_6_sva_1);
  assign while_for_6_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_6_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_191_160_mx0c1 = (~ (readslicef_33_1_32(while_for_6_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_11_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_11_sva_1);
  assign while_for_11_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_11_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_351_320_mx0c1 = (~ (readslicef_33_1_32(while_for_11_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_5_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_5_sva_1);
  assign while_for_5_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_5_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_159_128_mx0c1 = (~ (readslicef_33_1_32(while_for_5_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_12_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_12_sva_1);
  assign while_for_12_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_12_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_383_352_mx0c1 = (~ (readslicef_33_1_32(while_for_12_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_4_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_4_sva_1);
  assign while_for_4_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_4_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_127_96_mx0c1 = (~ (readslicef_33_1_32(while_for_4_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_13_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_13_sva_1);
  assign while_for_13_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_13_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_415_384_mx0c1 = (~ (readslicef_33_1_32(while_for_13_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_3_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_3_sva_1);
  assign while_for_3_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_3_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_95_64_mx0c1 = (~ (readslicef_33_1_32(while_for_3_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_14_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_14_sva_1);
  assign while_for_14_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_14_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_447_416_mx0c1 = (~ (readslicef_33_1_32(while_for_14_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_2_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_2_sva_1);
  assign while_for_2_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_2_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_63_32_mx0c1 = (~ (readslicef_33_1_32(while_for_2_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_15_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_15_sva_1);
  assign while_for_15_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_15_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_479_448_mx0c1 = (~ (readslicef_33_1_32(while_for_15_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_1_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_1_sva_1);
  assign while_for_1_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_1_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_31_0_mx0c1 = (~ (readslicef_33_1_32(while_for_1_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  assign nl_while_for_16_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl =  -conv_s2s_32_33(while_for_acc_1_cse_sva_1);
  assign while_for_16_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl = nl_while_for_16_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl[32:0];
  assign vec_out_Push_mioi_idat_511_480_mx0c1 = (~ (readslicef_33_1_32(while_for_16_operator_32_16_true_AC_TRN_AC_WRAP_acc_nl)))
      & (fsm_output[1]);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      reg_vec_in_a_Pop_mioi_oswt_tmp <= 1'b0;
      reg_vec_out_Push_mioi_oswt_tmp <= 1'b0;
      Compute_wen <= 1'b1;
    end
    else begin
      reg_vec_in_a_Pop_mioi_oswt_tmp <= while_mux_rmff;
      reg_vec_out_Push_mioi_oswt_tmp <= while_mux_1_rmff;
      Compute_wen <= Compute_wen_rtff;
    end
  end
  always @(posedge clk) begin
    if ( while_and_ssc ) begin
      vec_out_Push_mioi_idat_255 <= (while_for_acc_1_cse_8_sva_1[31]) & vec_out_Push_mioi_idat_255_224_mx0c1;
      vec_out_Push_mioi_idat_254 <= MUX_s_1_2_2((while_for_acc_1_cse_8_sva_1[30]),
          (while_for_acc_1_cse_8_sva_1[31]), vec_out_Push_mioi_idat_255_224_mx0c1);
      vec_out_Push_mioi_idat_253_224 <= MUX_v_30_2_2((while_for_acc_1_cse_8_sva_1[29:0]),
          (while_for_acc_1_cse_8_sva_1[30:1]), vec_out_Push_mioi_idat_255_224_mx0c1);
      vec_out_Push_mioi_idat_287 <= (while_for_acc_1_cse_9_sva_1[31]) & vec_out_Push_mioi_idat_287_256_mx0c1;
      vec_out_Push_mioi_idat_286 <= MUX_s_1_2_2((while_for_acc_1_cse_9_sva_1[30]),
          (while_for_acc_1_cse_9_sva_1[31]), vec_out_Push_mioi_idat_287_256_mx0c1);
      vec_out_Push_mioi_idat_285_256 <= MUX_v_30_2_2((while_for_acc_1_cse_9_sva_1[29:0]),
          (while_for_acc_1_cse_9_sva_1[30:1]), vec_out_Push_mioi_idat_287_256_mx0c1);
      vec_out_Push_mioi_idat_223 <= (while_for_acc_1_cse_7_sva_1[31]) & vec_out_Push_mioi_idat_223_192_mx0c1;
      vec_out_Push_mioi_idat_222 <= MUX_s_1_2_2((while_for_acc_1_cse_7_sva_1[30]),
          (while_for_acc_1_cse_7_sva_1[31]), vec_out_Push_mioi_idat_223_192_mx0c1);
      vec_out_Push_mioi_idat_221_192 <= MUX_v_30_2_2((while_for_acc_1_cse_7_sva_1[29:0]),
          (while_for_acc_1_cse_7_sva_1[30:1]), vec_out_Push_mioi_idat_223_192_mx0c1);
      vec_out_Push_mioi_idat_319 <= (while_for_acc_1_cse_10_sva_1[31]) & vec_out_Push_mioi_idat_319_288_mx0c1;
      vec_out_Push_mioi_idat_318 <= MUX_s_1_2_2((while_for_acc_1_cse_10_sva_1[30]),
          (while_for_acc_1_cse_10_sva_1[31]), vec_out_Push_mioi_idat_319_288_mx0c1);
      vec_out_Push_mioi_idat_317_288 <= MUX_v_30_2_2((while_for_acc_1_cse_10_sva_1[29:0]),
          (while_for_acc_1_cse_10_sva_1[30:1]), vec_out_Push_mioi_idat_319_288_mx0c1);
      vec_out_Push_mioi_idat_191 <= (while_for_acc_1_cse_6_sva_1[31]) & vec_out_Push_mioi_idat_191_160_mx0c1;
      vec_out_Push_mioi_idat_190 <= MUX_s_1_2_2((while_for_acc_1_cse_6_sva_1[30]),
          (while_for_acc_1_cse_6_sva_1[31]), vec_out_Push_mioi_idat_191_160_mx0c1);
      vec_out_Push_mioi_idat_189_160 <= MUX_v_30_2_2((while_for_acc_1_cse_6_sva_1[29:0]),
          (while_for_acc_1_cse_6_sva_1[30:1]), vec_out_Push_mioi_idat_191_160_mx0c1);
      vec_out_Push_mioi_idat_351 <= (while_for_acc_1_cse_11_sva_1[31]) & vec_out_Push_mioi_idat_351_320_mx0c1;
      vec_out_Push_mioi_idat_350 <= MUX_s_1_2_2((while_for_acc_1_cse_11_sva_1[30]),
          (while_for_acc_1_cse_11_sva_1[31]), vec_out_Push_mioi_idat_351_320_mx0c1);
      vec_out_Push_mioi_idat_349_320 <= MUX_v_30_2_2((while_for_acc_1_cse_11_sva_1[29:0]),
          (while_for_acc_1_cse_11_sva_1[30:1]), vec_out_Push_mioi_idat_351_320_mx0c1);
      vec_out_Push_mioi_idat_159 <= (while_for_acc_1_cse_5_sva_1[31]) & vec_out_Push_mioi_idat_159_128_mx0c1;
      vec_out_Push_mioi_idat_158 <= MUX_s_1_2_2((while_for_acc_1_cse_5_sva_1[30]),
          (while_for_acc_1_cse_5_sva_1[31]), vec_out_Push_mioi_idat_159_128_mx0c1);
      vec_out_Push_mioi_idat_157_128 <= MUX_v_30_2_2((while_for_acc_1_cse_5_sva_1[29:0]),
          (while_for_acc_1_cse_5_sva_1[30:1]), vec_out_Push_mioi_idat_159_128_mx0c1);
      vec_out_Push_mioi_idat_383 <= (while_for_acc_1_cse_12_sva_1[31]) & vec_out_Push_mioi_idat_383_352_mx0c1;
      vec_out_Push_mioi_idat_382 <= MUX_s_1_2_2((while_for_acc_1_cse_12_sva_1[30]),
          (while_for_acc_1_cse_12_sva_1[31]), vec_out_Push_mioi_idat_383_352_mx0c1);
      vec_out_Push_mioi_idat_381_352 <= MUX_v_30_2_2((while_for_acc_1_cse_12_sva_1[29:0]),
          (while_for_acc_1_cse_12_sva_1[30:1]), vec_out_Push_mioi_idat_383_352_mx0c1);
      vec_out_Push_mioi_idat_127 <= (while_for_acc_1_cse_4_sva_1[31]) & vec_out_Push_mioi_idat_127_96_mx0c1;
      vec_out_Push_mioi_idat_126 <= MUX_s_1_2_2((while_for_acc_1_cse_4_sva_1[30]),
          (while_for_acc_1_cse_4_sva_1[31]), vec_out_Push_mioi_idat_127_96_mx0c1);
      vec_out_Push_mioi_idat_125_96 <= MUX_v_30_2_2((while_for_acc_1_cse_4_sva_1[29:0]),
          (while_for_acc_1_cse_4_sva_1[30:1]), vec_out_Push_mioi_idat_127_96_mx0c1);
      vec_out_Push_mioi_idat_415 <= (while_for_acc_1_cse_13_sva_1[31]) & vec_out_Push_mioi_idat_415_384_mx0c1;
      vec_out_Push_mioi_idat_414 <= MUX_s_1_2_2((while_for_acc_1_cse_13_sva_1[30]),
          (while_for_acc_1_cse_13_sva_1[31]), vec_out_Push_mioi_idat_415_384_mx0c1);
      vec_out_Push_mioi_idat_413_384 <= MUX_v_30_2_2((while_for_acc_1_cse_13_sva_1[29:0]),
          (while_for_acc_1_cse_13_sva_1[30:1]), vec_out_Push_mioi_idat_415_384_mx0c1);
      vec_out_Push_mioi_idat_95 <= (while_for_acc_1_cse_3_sva_1[31]) & vec_out_Push_mioi_idat_95_64_mx0c1;
      vec_out_Push_mioi_idat_94 <= MUX_s_1_2_2((while_for_acc_1_cse_3_sva_1[30]),
          (while_for_acc_1_cse_3_sva_1[31]), vec_out_Push_mioi_idat_95_64_mx0c1);
      vec_out_Push_mioi_idat_93_64 <= MUX_v_30_2_2((while_for_acc_1_cse_3_sva_1[29:0]),
          (while_for_acc_1_cse_3_sva_1[30:1]), vec_out_Push_mioi_idat_95_64_mx0c1);
      vec_out_Push_mioi_idat_447 <= (while_for_acc_1_cse_14_sva_1[31]) & vec_out_Push_mioi_idat_447_416_mx0c1;
      vec_out_Push_mioi_idat_446 <= MUX_s_1_2_2((while_for_acc_1_cse_14_sva_1[30]),
          (while_for_acc_1_cse_14_sva_1[31]), vec_out_Push_mioi_idat_447_416_mx0c1);
      vec_out_Push_mioi_idat_445_416 <= MUX_v_30_2_2((while_for_acc_1_cse_14_sva_1[29:0]),
          (while_for_acc_1_cse_14_sva_1[30:1]), vec_out_Push_mioi_idat_447_416_mx0c1);
      vec_out_Push_mioi_idat_63 <= (while_for_acc_1_cse_2_sva_1[31]) & vec_out_Push_mioi_idat_63_32_mx0c1;
      vec_out_Push_mioi_idat_62 <= MUX_s_1_2_2((while_for_acc_1_cse_2_sva_1[30]),
          (while_for_acc_1_cse_2_sva_1[31]), vec_out_Push_mioi_idat_63_32_mx0c1);
      vec_out_Push_mioi_idat_61_32 <= MUX_v_30_2_2((while_for_acc_1_cse_2_sva_1[29:0]),
          (while_for_acc_1_cse_2_sva_1[30:1]), vec_out_Push_mioi_idat_63_32_mx0c1);
      vec_out_Push_mioi_idat_479 <= (while_for_acc_1_cse_15_sva_1[31]) & vec_out_Push_mioi_idat_479_448_mx0c1;
      vec_out_Push_mioi_idat_478 <= MUX_s_1_2_2((while_for_acc_1_cse_15_sva_1[30]),
          (while_for_acc_1_cse_15_sva_1[31]), vec_out_Push_mioi_idat_479_448_mx0c1);
      vec_out_Push_mioi_idat_477_448 <= MUX_v_30_2_2((while_for_acc_1_cse_15_sva_1[29:0]),
          (while_for_acc_1_cse_15_sva_1[30:1]), vec_out_Push_mioi_idat_479_448_mx0c1);
      vec_out_Push_mioi_idat_31 <= (while_for_acc_1_cse_1_sva_1[31]) & vec_out_Push_mioi_idat_31_0_mx0c1;
      vec_out_Push_mioi_idat_30 <= MUX_s_1_2_2((while_for_acc_1_cse_1_sva_1[30]),
          (while_for_acc_1_cse_1_sva_1[31]), vec_out_Push_mioi_idat_31_0_mx0c1);
      vec_out_Push_mioi_idat_29_0 <= MUX_v_30_2_2((while_for_acc_1_cse_1_sva_1[29:0]),
          (while_for_acc_1_cse_1_sva_1[30:1]), vec_out_Push_mioi_idat_31_0_mx0c1);
      vec_out_Push_mioi_idat_511 <= (while_for_acc_1_cse_sva_1[31]) & vec_out_Push_mioi_idat_511_480_mx0c1;
      vec_out_Push_mioi_idat_510 <= MUX_s_1_2_2((while_for_acc_1_cse_sva_1[30]),
          (while_for_acc_1_cse_sva_1[31]), vec_out_Push_mioi_idat_511_480_mx0c1);
      vec_out_Push_mioi_idat_509_480 <= MUX_v_30_2_2((while_for_acc_1_cse_sva_1[29:0]),
          (while_for_acc_1_cse_sva_1[30:1]), vec_out_Push_mioi_idat_511_480_mx0c1);
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


  function automatic [29:0] MUX_v_30_2_2;
    input [29:0] input_0;
    input [29:0] input_1;
    input  sel;
    reg [29:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_30_2_2 = result;
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


  function automatic [32:0] conv_s2s_32_33 ;
    input [31:0]  vector ;
  begin
    conv_s2s_32_33 = {vector[31], vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    LeakyreluEngine
// ------------------------------------------------------------------


module LeakyreluEngine (
  clk, rst, vec_in_a_val, vec_in_a_rdy, vec_in_a_msg, vec_in_b_val, vec_in_b_rdy,
      vec_in_b_msg, vec_out_val, vec_out_rdy, vec_out_msg
);
  input clk;
  input rst;
  input vec_in_a_val;
  output vec_in_a_rdy;
  input [511:0] vec_in_a_msg;
  input vec_in_b_val;
  output vec_in_b_rdy;
  input [511:0] vec_in_b_msg;
  output vec_out_val;
  input vec_out_rdy;
  output [511:0] vec_out_msg;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_LeakyreluEngine_Compute LeakyreluEngine_Compute_inst (
      .clk(clk),
      .rst(rst),
      .vec_in_a_val(vec_in_a_val),
      .vec_in_a_rdy(vec_in_a_rdy),
      .vec_in_a_msg(vec_in_a_msg),
      .vec_in_b_val(vec_in_b_val),
      .vec_in_b_rdy(vec_in_b_rdy),
      .vec_in_b_msg(vec_in_b_msg),
      .vec_out_val(vec_out_val),
      .vec_out_rdy(vec_out_rdy),
      .vec_out_msg(vec_out_msg)
    );
endmodule



