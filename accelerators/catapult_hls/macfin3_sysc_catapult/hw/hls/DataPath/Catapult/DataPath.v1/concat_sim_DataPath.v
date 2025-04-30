
//------> ./DataPath_ccs_ctrl_in_buf_wait_v4.v 
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



//------> ./DataPath_ccs_out_buf_wait_v5.v 
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

//------> ./DataPath_mgc_mul_pipe_beh.v 
//
// File:      $Mgc_home/pkgs/hls_pkgs/mgc_comps_src/mgc_mul_pipe_beh.v
//
// BASELINE:  Catapult-C version 2006b.63
// MODIFIED:  2007-04-03, tnagler
//
// Note: this file uses Verilog2001 features;
//       please enable Verilog2001 in the flow!

module esp_acc_DUMMY_mgc_mul_pipe (a, b, clk, en, a_rst, s_rst, z);

    // Parameters:
    parameter integer width_a = 32'd4;  // input a bit width
    parameter         signd_a =  1'b1;  // input a type (1=signed, 0=unsigned)
    parameter integer width_b = 32'd4;  // input b bit width
    parameter         signd_b =  1'b1;  // input b type (1=signed, 0=unsigned)
    parameter integer width_z = 32'd8;  // result bit width (= width_a + width_b)
    parameter      clock_edge =  1'b0;  // clock polarity (1=posedge, 0=negedge)
    parameter   enable_active =  1'b0;  // enable polarity (1=posedge, 0=negedge)
    parameter    a_rst_active =  1'b1;  // unused
    parameter    s_rst_active =  1'b1;  // unused
    parameter integer  stages = 32'd2;  // number of output registers + 1 (careful!)
    parameter integer n_inreg = 32'd0;  // number of input registers

    localparam integer width_ab = width_a + width_b;  // multiplier result width
    localparam integer n_inreg_min = (n_inreg > 1) ? (n_inreg-1) : 0; // for Synopsys DC

    // I/O ports:
    input  [width_a-1:0] a;      // input A
    input  [width_b-1:0] b;      // input B
    input                clk;    // clock
    input                en;     // enable
    input                a_rst;  // spyglass disable SYNTH_5121,W240
    input                s_rst;  // spyglass disable SYNTH_5121,W240
    output [width_z-1:0] z;      // output


    // Input registers:

    wire [width_a-1:0] a_f;
    wire [width_b-1:0] b_f;

    integer i;

    generate
    if (clock_edge == 1'b0)
    begin: NEG_EDGE1
        case (n_inreg)
        32'd0: begin: B1
            assign a_f = a,
                   b_f = b;
        end
        default: begin: B2
            reg [width_a-1:0] a_reg [n_inreg_min:0];
            reg [width_b-1:0] b_reg [n_inreg_min:0];
            always @(negedge clk)
            if (en == enable_active)
            begin: B21
                a_reg[0] <= a;
                b_reg[0] <= b;
                for (i = 0; i < n_inreg_min; i = i + 1)
                begin: B3
                    a_reg[i+1] <= a_reg[i]; //spyglass disable FlopEConst
                    b_reg[i+1] <= b_reg[i]; //spyglass disable FlopEConst
                end
            end
            assign a_f = a_reg[n_inreg_min],
                   b_f = b_reg[n_inreg_min];
        end
        endcase
    end
    else
    begin: POS_EDGE1
        case (n_inreg)
        32'd0: begin: B1
            assign a_f = a,
                   b_f = b;
        end
        default: begin: B2
            reg [width_a-1:0] a_reg [n_inreg_min:0];
            reg [width_b-1:0] b_reg [n_inreg_min:0];
            always @(posedge clk)
            if (en == enable_active)
            begin: B21
                a_reg[0] <= a; //spyglass disable FlopEConst
                b_reg[0] <= b; //spyglass disable FlopEConst
                for (i = 0; i < n_inreg_min; i = i + 1)
                begin: B3
                    a_reg[i+1] <= a_reg[i]; //spyglass disable FlopEConst
                    b_reg[i+1] <= b_reg[i]; //spyglass disable FlopEConst
                end
            end
            assign a_f = a_reg[n_inreg_min],
                   b_f = b_reg[n_inreg_min];
        end
        endcase
    end
    endgenerate


    // Output:
    wire [width_z-1:0]  xz;

    function signed [width_z-1:0] conv_signed;
      input signed [width_ab-1:0] res;
      conv_signed = res[width_z-1:0];
    endfunction

    generate
      wire signed [width_ab-1:0] res;
      if ( (signd_a == 1'b1) && (signd_b == 1'b1) )
      begin: SIGNED_AB
              assign res = $signed(a_f) * $signed(b_f);
              assign xz = conv_signed(res);
      end
      else if ( (signd_a == 1'b1) && (signd_b == 1'b0) )
      begin: SIGNED_A
              assign res = $signed(a_f) * $signed({1'b0, b_f});
              assign xz = conv_signed(res);
      end
      else if ( (signd_a == 1'b0) && (signd_b == 1'b1) )
      begin: SIGNED_B
              assign res = $signed({1'b0,a_f}) * $signed(b_f);
              assign xz = conv_signed(res);
      end
      else
      begin: UNSIGNED_AB
              assign res = a_f * b_f;
	      assign xz = res[width_z-1:0];
      end
    endgenerate


    // Output registers:

    reg  [width_z-1:0] reg_array[stages-2:0];
    wire [width_z-1:0] z;

    generate
    if (clock_edge == 1'b0)
    begin: NEG_EDGE2
        always @(negedge clk)
        if (en == enable_active)
            for (i = stages-2; i >= 0; i = i-1)
                if (i == 0)
                    reg_array[i] <= xz; //spyglass disable FlopEConst
                else
                    reg_array[i] <= reg_array[i-1]; //spyglass disable FlopEConst
    end
    else
    begin: POS_EDGE2
        always @(posedge clk)
        if (en == enable_active)
            for (i = stages-2; i >= 0; i = i-1)
                if (i == 0)
                    reg_array[i] <= xz; //spyglass disable FlopEConst
                else
                    reg_array[i] <= reg_array[i-1]; //spyglass disable FlopEConst
    end
    endgenerate

    assign z = reg_array[stages-2];
endmodule

//------> ./DataPath.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2024.2/1130128 Production Release
//  HLS Date:       Mon Aug 26 21:59:12 PDT 2024
// 
//  Generated by:   gtombesi@corsica
//  Generated date: Wed Apr 30 13:18:34 2025
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_compute_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_compute_fsm (
  clk, rst, compute_wen, fsm_output, while_C_0_tr0, while_for_C_1_tr0, while_for_for_for_C_1_tr0,
      while_for_for_C_1_tr0, while_for_C_2_tr0
);
  input clk;
  input rst;
  input compute_wen;
  output [8:0] fsm_output;
  reg [8:0] fsm_output;
  input while_C_0_tr0;
  input while_for_C_1_tr0;
  input while_for_for_for_C_1_tr0;
  input while_for_for_C_1_tr0;
  input while_for_C_2_tr0;


  // FSM State Type Declaration for esp_acc_DUMMY_DataPath_compute_compute_fsm_1
  parameter
    compute_rlp_C_0 = 4'd0,
    while_C_0 = 4'd1,
    while_for_C_0 = 4'd2,
    while_for_C_1 = 4'd3,
    while_for_for_C_0 = 4'd4,
    while_for_for_for_C_0 = 4'd5,
    while_for_for_for_C_1 = 4'd6,
    while_for_for_C_1 = 4'd7,
    while_for_C_2 = 4'd8;

  reg [3:0] state_var;
  reg [3:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_DUMMY_DataPath_compute_compute_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 9'b000000010;
        if ( while_C_0_tr0 ) begin
          state_var_NS = while_C_0;
        end
        else begin
          state_var_NS = while_for_C_0;
        end
      end
      while_for_C_0 : begin
        fsm_output = 9'b000000100;
        state_var_NS = while_for_C_1;
      end
      while_for_C_1 : begin
        fsm_output = 9'b000001000;
        if ( while_for_C_1_tr0 ) begin
          state_var_NS = while_for_C_2;
        end
        else begin
          state_var_NS = while_for_for_C_0;
        end
      end
      while_for_for_C_0 : begin
        fsm_output = 9'b000010000;
        state_var_NS = while_for_for_for_C_0;
      end
      while_for_for_for_C_0 : begin
        fsm_output = 9'b000100000;
        state_var_NS = while_for_for_for_C_1;
      end
      while_for_for_for_C_1 : begin
        fsm_output = 9'b001000000;
        if ( while_for_for_for_C_1_tr0 ) begin
          state_var_NS = while_for_for_C_1;
        end
        else begin
          state_var_NS = while_for_for_for_C_0;
        end
      end
      while_for_for_C_1 : begin
        fsm_output = 9'b010000000;
        if ( while_for_for_C_1_tr0 ) begin
          state_var_NS = while_for_C_2;
        end
        else begin
          state_var_NS = while_for_for_C_0;
        end
      end
      while_for_C_2 : begin
        fsm_output = 9'b100000000;
        if ( while_for_C_2_tr0 ) begin
          state_var_NS = while_C_0;
        end
        else begin
          state_var_NS = while_for_C_0;
        end
      end
      // compute_rlp_C_0
      default : begin
        fsm_output = 9'b000000001;
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
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_staller
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_staller (
  clk, rst, compute_wen, compute_wten, sync00_Pop_mioi_iden, sync00_Pop_mioi_wen_comp,
      conf_info_in_Pop_mioi_iden, conf_info_in_Pop_mioi_wen_comp, in_rd_rsp_Pop_mioi_iden,
      in_rd_rsp_Pop_mioi_wen_comp, in_wr_req_Push_mioi_iden, in_wr_req_Push_mioi_wen_comp,
      while_for_for_for_while_for_for_for_mul_cmp_iden, while_for_for_for_while_for_for_for_mul_cmp_iden_1,
      compute_flen_unreg
);
  input clk;
  input rst;
  output compute_wen;
  output compute_wten;
  input sync00_Pop_mioi_iden;
  input sync00_Pop_mioi_wen_comp;
  input conf_info_in_Pop_mioi_iden;
  input conf_info_in_Pop_mioi_wen_comp;
  input in_rd_rsp_Pop_mioi_iden;
  input in_rd_rsp_Pop_mioi_wen_comp;
  input in_wr_req_Push_mioi_iden;
  input in_wr_req_Push_mioi_wen_comp;
  input while_for_for_for_while_for_for_for_mul_cmp_iden;
  input while_for_for_for_while_for_for_for_mul_cmp_iden_1;
  input compute_flen_unreg;


  // Interconnect Declarations
  reg compute_flen_shf_1;
  reg compute_flen_shf_0;
  reg compute_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign compute_wen = sync00_Pop_mioi_wen_comp & conf_info_in_Pop_mioi_wen_comp
      & in_rd_rsp_Pop_mioi_wen_comp & in_wr_req_Push_mioi_wen_comp & (~(compute_flen_shf_1
      & compute_flen_shf_0 & compute_flen_unreg));
  assign compute_wten = compute_wten_reg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      compute_flen_shf_1 <= 1'b0;
      compute_flen_shf_0 <= 1'b0;
      compute_wten_reg <= 1'b0;
    end
    else begin
      compute_flen_shf_1 <= compute_flen_shf_0;
      compute_flen_shf_0 <= compute_flen_unreg & (~(sync00_Pop_mioi_iden | conf_info_in_Pop_mioi_iden
          | in_rd_rsp_Pop_mioi_iden | in_wr_req_Push_mioi_iden | while_for_for_for_while_for_for_for_mul_cmp_iden
          | while_for_for_for_while_for_for_for_mul_cmp_iden_1));
      compute_wten_reg <= ~ compute_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_mgc_mul_pipe_32_1_32_1_48_1_1_0_0_2_2_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_mgc_mul_pipe_32_1_32_1_48_1_1_0_0_2_2_wait_dp
    (
  clk, rst, while_for_for_for_while_for_for_for_mul_cmp_bawt, while_for_for_for_while_for_for_for_mul_cmp_iden,
      while_for_for_for_while_for_for_for_mul_cmp_z_mxwt, while_for_for_for_while_for_for_for_mul_cmp_biwt,
      while_for_for_for_while_for_for_for_mul_cmp_bdwt, while_for_for_for_while_for_for_for_mul_cmp_z
);
  input clk;
  input rst;
  output while_for_for_for_while_for_for_for_mul_cmp_bawt;
  output while_for_for_for_while_for_for_for_mul_cmp_iden;
  output [31:0] while_for_for_for_while_for_for_for_mul_cmp_z_mxwt;
  input while_for_for_for_while_for_for_for_mul_cmp_biwt;
  input while_for_for_for_while_for_for_for_mul_cmp_bdwt;
  input [47:0] while_for_for_for_while_for_for_for_mul_cmp_z;


  // Interconnect Declarations
  reg [1:0] while_for_for_for_while_for_for_for_mul_cmp_bcwt;
  wire [2:0] nl_while_for_for_for_while_for_for_for_mul_cmp_bcwt;
  reg [31:0] while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_2_47_16;
  reg [31:0] while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_1_47_16;
  reg [31:0] while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_47_16;

  wire[1:0] while_for_for_for_acc_1_nl;
  wire[2:0] nl_while_for_for_for_acc_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign while_for_for_for_while_for_for_for_mul_cmp_iden = while_for_for_for_while_for_for_for_mul_cmp_biwt
      | while_for_for_for_while_for_for_for_mul_cmp_bdwt;
  assign while_for_for_for_while_for_for_for_mul_cmp_bawt = while_for_for_for_while_for_for_for_mul_cmp_biwt
      | (while_for_for_for_while_for_for_for_mul_cmp_bcwt!=2'b00);
  assign while_for_for_for_while_for_for_for_mul_cmp_z_mxwt = MUX_v_32_4_2((while_for_for_for_while_for_for_for_mul_cmp_z[47:16]),
      while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_47_16, while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_1_47_16,
      while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_2_47_16, while_for_for_for_while_for_for_for_mul_cmp_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_while_for_for_for_mul_cmp_bcwt <= 2'b00;
    end
    else begin
      while_for_for_for_while_for_for_for_mul_cmp_bcwt <= nl_while_for_for_for_while_for_for_for_mul_cmp_bcwt[1:0];
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_for_while_for_for_for_mul_cmp_biwt ) begin
      while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_47_16 <= while_for_for_for_while_for_for_for_mul_cmp_z[47:16];
      while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_1_47_16 <= while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_47_16;
      while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_2_47_16 <= while_for_for_for_while_for_for_for_mul_cmp_z_bfwt_1_47_16;
    end
  end
  assign nl_while_for_for_for_acc_1_nl = conv_s2s_1_2(while_for_for_for_while_for_for_for_mul_cmp_bdwt)
      + conv_u2s_1_2(while_for_for_for_while_for_for_for_mul_cmp_biwt);
  assign while_for_for_for_acc_1_nl = nl_while_for_for_for_acc_1_nl[1:0];
  assign nl_while_for_for_for_while_for_for_for_mul_cmp_bcwt  = while_for_for_for_acc_1_nl
      + while_for_for_for_while_for_for_for_mul_cmp_bcwt;

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


  function automatic [1:0] conv_s2s_1_2 ;
    input  vector ;
  begin
    conv_s2s_1_2 = {vector, vector};
  end
  endfunction


  function automatic [1:0] conv_u2s_1_2 ;
    input  vector ;
  begin
    conv_u2s_1_2 =  {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_mgc_mul_pipe_32_1_32_1_48_1_1_0_0_2_2_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_mgc_mul_pipe_32_1_32_1_48_1_1_0_0_2_2_wait_ctrl
    (
  clk, rst, compute_wen, compute_wten, while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg,
      while_for_for_for_while_for_for_for_mul_cmp_iswt2, while_for_for_for_while_for_for_for_mul_cmp_iden_1,
      compute_cgwt, while_for_for_for_while_for_for_for_mul_cmp_bdwt, while_for_for_for_while_for_for_for_mul_cmp_iswt2_pff
);
  input clk;
  input rst;
  input compute_wen;
  input compute_wten;
  input while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg;
  input while_for_for_for_while_for_for_for_mul_cmp_iswt2;
  output while_for_for_for_while_for_for_for_mul_cmp_iden_1;
  output compute_cgwt;
  output while_for_for_for_while_for_for_for_mul_cmp_bdwt;
  input while_for_for_for_while_for_for_for_mul_cmp_iswt2_pff;


  // Interconnect Declarations
  wire while_for_for_for_while_for_for_for_mul_cmp_ogwt;
  wire while_for_for_for_while_for_for_for_mul_cmp_tiswt2;
  reg while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt1;
  reg while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt0;
  reg [1:0] while_for_for_for_while_for_for_for_mul_cmp_icwt;
  wire [2:0] nl_while_for_for_for_while_for_for_for_mul_cmp_icwt;

  wire[1:0] while_for_for_for_acc_nl;
  wire[2:0] nl_while_for_for_for_acc_nl;

  // Interconnect Declarations for Component Instantiations 
  assign while_for_for_for_while_for_for_for_mul_cmp_bdwt = while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg
      & compute_wen;
  assign while_for_for_for_while_for_for_for_mul_cmp_tiswt2 = (~ compute_wten) &
      while_for_for_for_while_for_for_for_mul_cmp_iswt2;
  assign while_for_for_for_while_for_for_for_mul_cmp_iden_1 = while_for_for_for_while_for_for_for_mul_cmp_ogwt;
  assign while_for_for_for_while_for_for_for_mul_cmp_ogwt = while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt0
      | (while_for_for_for_while_for_for_for_mul_cmp_icwt!=2'b00);
  assign compute_cgwt = while_for_for_for_while_for_for_for_mul_cmp_ogwt | while_for_for_for_while_for_for_for_mul_cmp_tiswt2
      | while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt1
      | (compute_wen & while_for_for_for_while_for_for_for_mul_cmp_iswt2_pff);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt1
          <= 1'b0;
      while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt0
          <= 1'b0;
      while_for_for_for_while_for_for_for_mul_cmp_icwt <= 2'b00;
    end
    else begin
      while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt1
          <= while_for_for_for_while_for_for_for_mul_cmp_tiswt2;
      while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt0
          <= while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt1;
      while_for_for_for_while_for_for_for_mul_cmp_icwt <= nl_while_for_for_for_while_for_for_for_mul_cmp_icwt[1:0];
    end
  end
  assign nl_while_for_for_for_acc_nl = conv_s2s_1_2(while_for_for_for_while_for_for_for_mul_cmp_ogwt)
      + conv_u2s_1_2(while_for_for_for_while_for_for_for_mul_cmp_hile_for_for_for_while_for_for_for_mul_cmp_pdswt0);
  assign while_for_for_for_acc_nl = nl_while_for_for_for_acc_nl[1:0];
  assign nl_while_for_for_for_while_for_for_for_mul_cmp_icwt  = while_for_for_for_acc_nl
      + while_for_for_for_while_for_for_for_mul_cmp_icwt;

  function automatic [1:0] conv_s2s_1_2 ;
    input  vector ;
  begin
    conv_s2s_1_2 = {vector, vector};
  end
  endfunction


  function automatic [1:0] conv_u2s_1_2 ;
    input  vector ;
  begin
    conv_u2s_1_2 =  {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_in_wr_req_Push_mioi_in_wr_req_Push_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_in_wr_req_Push_mioi_in_wr_req_Push_mio_wait_dp
    (
  clk, rst, in_wr_req_Push_mioi_oswt_unreg, in_wr_req_Push_mioi_bawt, in_wr_req_Push_mioi_iden,
      in_wr_req_Push_mioi_wen_comp, in_wr_req_Push_mioi_biwt, in_wr_req_Push_mioi_bdwt,
      in_wr_req_Push_mioi_bcwt
);
  input clk;
  input rst;
  input in_wr_req_Push_mioi_oswt_unreg;
  output in_wr_req_Push_mioi_bawt;
  output in_wr_req_Push_mioi_iden;
  output in_wr_req_Push_mioi_wen_comp;
  input in_wr_req_Push_mioi_biwt;
  input in_wr_req_Push_mioi_bdwt;
  output in_wr_req_Push_mioi_bcwt;
  reg in_wr_req_Push_mioi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign in_wr_req_Push_mioi_iden = in_wr_req_Push_mioi_biwt | in_wr_req_Push_mioi_bdwt;
  assign in_wr_req_Push_mioi_bawt = in_wr_req_Push_mioi_biwt | in_wr_req_Push_mioi_bcwt;
  assign in_wr_req_Push_mioi_wen_comp = (~ in_wr_req_Push_mioi_oswt_unreg) | in_wr_req_Push_mioi_bawt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      in_wr_req_Push_mioi_bcwt <= 1'b0;
    end
    else begin
      in_wr_req_Push_mioi_bcwt <= ~((~(in_wr_req_Push_mioi_bcwt | in_wr_req_Push_mioi_biwt))
          | in_wr_req_Push_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_in_wr_req_Push_mioi_in_wr_req_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_in_wr_req_Push_mioi_in_wr_req_Push_mio_wait_ctrl
    (
  compute_wen, in_wr_req_Push_mioi_oswt_unreg, in_wr_req_Push_mioi_iswt0, in_wr_req_Push_mioi_irdy_oreg,
      in_wr_req_Push_mioi_biwt, in_wr_req_Push_mioi_bdwt, in_wr_req_Push_mioi_bcwt,
      in_wr_req_Push_mioi_ivld_compute_sct
);
  input compute_wen;
  input in_wr_req_Push_mioi_oswt_unreg;
  input in_wr_req_Push_mioi_iswt0;
  input in_wr_req_Push_mioi_irdy_oreg;
  output in_wr_req_Push_mioi_biwt;
  output in_wr_req_Push_mioi_bdwt;
  input in_wr_req_Push_mioi_bcwt;
  output in_wr_req_Push_mioi_ivld_compute_sct;


  // Interconnect Declarations
  wire in_wr_req_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign in_wr_req_Push_mioi_bdwt = in_wr_req_Push_mioi_oswt_unreg & compute_wen;
  assign in_wr_req_Push_mioi_biwt = in_wr_req_Push_mioi_ogwt & in_wr_req_Push_mioi_irdy_oreg;
  assign in_wr_req_Push_mioi_ogwt = in_wr_req_Push_mioi_iswt0 & (~ in_wr_req_Push_mioi_bcwt);
  assign in_wr_req_Push_mioi_ivld_compute_sct = in_wr_req_Push_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_in_rd_rsp_Pop_mioi_in_rd_rsp_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_in_rd_rsp_Pop_mioi_in_rd_rsp_Pop_mio_wait_dp
    (
  clk, rst, in_rd_rsp_Pop_mioi_oswt_unreg, in_rd_rsp_Pop_mioi_bawt, in_rd_rsp_Pop_mioi_iden,
      in_rd_rsp_Pop_mioi_wen_comp, in_rd_rsp_Pop_mioi_idat_mxwt, in_rd_rsp_Pop_mioi_biwt,
      in_rd_rsp_Pop_mioi_bdwt, in_rd_rsp_Pop_mioi_bcwt, in_rd_rsp_Pop_mioi_idat
);
  input clk;
  input rst;
  input in_rd_rsp_Pop_mioi_oswt_unreg;
  output in_rd_rsp_Pop_mioi_bawt;
  output in_rd_rsp_Pop_mioi_iden;
  output in_rd_rsp_Pop_mioi_wen_comp;
  output [63:0] in_rd_rsp_Pop_mioi_idat_mxwt;
  input in_rd_rsp_Pop_mioi_biwt;
  input in_rd_rsp_Pop_mioi_bdwt;
  output in_rd_rsp_Pop_mioi_bcwt;
  reg in_rd_rsp_Pop_mioi_bcwt;
  input [63:0] in_rd_rsp_Pop_mioi_idat;


  // Interconnect Declarations
  reg [63:0] in_rd_rsp_Pop_mioi_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign in_rd_rsp_Pop_mioi_iden = in_rd_rsp_Pop_mioi_biwt | in_rd_rsp_Pop_mioi_bdwt;
  assign in_rd_rsp_Pop_mioi_bawt = in_rd_rsp_Pop_mioi_biwt | in_rd_rsp_Pop_mioi_bcwt;
  assign in_rd_rsp_Pop_mioi_wen_comp = (~ in_rd_rsp_Pop_mioi_oswt_unreg) | in_rd_rsp_Pop_mioi_bawt;
  assign in_rd_rsp_Pop_mioi_idat_mxwt = MUX_v_64_2_2(in_rd_rsp_Pop_mioi_idat, in_rd_rsp_Pop_mioi_idat_bfwt,
      in_rd_rsp_Pop_mioi_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      in_rd_rsp_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      in_rd_rsp_Pop_mioi_bcwt <= ~((~(in_rd_rsp_Pop_mioi_bcwt | in_rd_rsp_Pop_mioi_biwt))
          | in_rd_rsp_Pop_mioi_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( in_rd_rsp_Pop_mioi_biwt ) begin
      in_rd_rsp_Pop_mioi_idat_bfwt <= in_rd_rsp_Pop_mioi_idat;
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
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_in_rd_rsp_Pop_mioi_in_rd_rsp_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_in_rd_rsp_Pop_mioi_in_rd_rsp_Pop_mio_wait_ctrl
    (
  compute_wen, in_rd_rsp_Pop_mioi_oswt_unreg, in_rd_rsp_Pop_mioi_iswt0, in_rd_rsp_Pop_mioi_ivld_oreg,
      in_rd_rsp_Pop_mioi_biwt, in_rd_rsp_Pop_mioi_bdwt, in_rd_rsp_Pop_mioi_bcwt,
      in_rd_rsp_Pop_mioi_irdy_compute_sct
);
  input compute_wen;
  input in_rd_rsp_Pop_mioi_oswt_unreg;
  input in_rd_rsp_Pop_mioi_iswt0;
  input in_rd_rsp_Pop_mioi_ivld_oreg;
  output in_rd_rsp_Pop_mioi_biwt;
  output in_rd_rsp_Pop_mioi_bdwt;
  input in_rd_rsp_Pop_mioi_bcwt;
  output in_rd_rsp_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations
  wire in_rd_rsp_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign in_rd_rsp_Pop_mioi_bdwt = in_rd_rsp_Pop_mioi_oswt_unreg & compute_wen;
  assign in_rd_rsp_Pop_mioi_biwt = in_rd_rsp_Pop_mioi_ogwt & in_rd_rsp_Pop_mioi_ivld_oreg;
  assign in_rd_rsp_Pop_mioi_ogwt = in_rd_rsp_Pop_mioi_iswt0 & (~ in_rd_rsp_Pop_mioi_bcwt);
  assign in_rd_rsp_Pop_mioi_irdy_compute_sct = in_rd_rsp_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_conf_info_in_Pop_mioi_conf_info_in_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_conf_info_in_Pop_mioi_conf_info_in_Pop_mio_wait_dp
    (
  clk, rst, conf_info_in_Pop_mioi_oswt, conf_info_in_Pop_mioi_iden, conf_info_in_Pop_mioi_wen_comp,
      conf_info_in_Pop_mioi_idat_mxwt, conf_info_in_Pop_mioi_biwt, conf_info_in_Pop_mioi_bdwt,
      conf_info_in_Pop_mioi_bcwt, conf_info_in_Pop_mioi_idat
);
  input clk;
  input rst;
  input conf_info_in_Pop_mioi_oswt;
  output conf_info_in_Pop_mioi_iden;
  output conf_info_in_Pop_mioi_wen_comp;
  output [95:0] conf_info_in_Pop_mioi_idat_mxwt;
  input conf_info_in_Pop_mioi_biwt;
  input conf_info_in_Pop_mioi_bdwt;
  output conf_info_in_Pop_mioi_bcwt;
  reg conf_info_in_Pop_mioi_bcwt;
  input [95:0] conf_info_in_Pop_mioi_idat;


  // Interconnect Declarations
  reg [95:0] conf_info_in_Pop_mioi_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_in_Pop_mioi_iden = conf_info_in_Pop_mioi_biwt | conf_info_in_Pop_mioi_bdwt;
  assign conf_info_in_Pop_mioi_wen_comp = (~ conf_info_in_Pop_mioi_oswt) | conf_info_in_Pop_mioi_biwt
      | conf_info_in_Pop_mioi_bcwt;
  assign conf_info_in_Pop_mioi_idat_mxwt = MUX_v_96_2_2(conf_info_in_Pop_mioi_idat,
      conf_info_in_Pop_mioi_idat_bfwt, conf_info_in_Pop_mioi_bcwt);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf_info_in_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      conf_info_in_Pop_mioi_bcwt <= ~((~(conf_info_in_Pop_mioi_bcwt | conf_info_in_Pop_mioi_biwt))
          | conf_info_in_Pop_mioi_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( conf_info_in_Pop_mioi_biwt ) begin
      conf_info_in_Pop_mioi_idat_bfwt <= conf_info_in_Pop_mioi_idat;
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
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_conf_info_in_Pop_mioi_conf_info_in_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_conf_info_in_Pop_mioi_conf_info_in_Pop_mio_wait_ctrl
    (
  compute_wen, conf_info_in_Pop_mioi_oswt, conf_info_in_Pop_mioi_ivld_oreg, conf_info_in_Pop_mioi_biwt,
      conf_info_in_Pop_mioi_bdwt, conf_info_in_Pop_mioi_bcwt, conf_info_in_Pop_mioi_irdy_compute_sct
);
  input compute_wen;
  input conf_info_in_Pop_mioi_oswt;
  input conf_info_in_Pop_mioi_ivld_oreg;
  output conf_info_in_Pop_mioi_biwt;
  output conf_info_in_Pop_mioi_bdwt;
  input conf_info_in_Pop_mioi_bcwt;
  output conf_info_in_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations
  wire conf_info_in_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_in_Pop_mioi_bdwt = conf_info_in_Pop_mioi_oswt & compute_wen;
  assign conf_info_in_Pop_mioi_biwt = conf_info_in_Pop_mioi_ogwt & conf_info_in_Pop_mioi_ivld_oreg;
  assign conf_info_in_Pop_mioi_ogwt = conf_info_in_Pop_mioi_oswt & (~ conf_info_in_Pop_mioi_bcwt);
  assign conf_info_in_Pop_mioi_irdy_compute_sct = conf_info_in_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_wait_dp (
  clk, rst, while_for_in_length_mul_cmp_z, compute_wen, sync00_Pop_mioi_ivld, sync00_Pop_mioi_ivld_oreg,
      conf_info_in_Pop_mioi_ivld, conf_info_in_Pop_mioi_ivld_oreg, in_rd_rsp_Pop_mioi_ivld,
      in_rd_rsp_Pop_mioi_ivld_oreg, in_wr_req_Push_mioi_irdy, in_wr_req_Push_mioi_irdy_oreg,
      while_for_in_length_mul_cmp_z_oreg
);
  input clk;
  input rst;
  input [31:0] while_for_in_length_mul_cmp_z;
  input compute_wen;
  input sync00_Pop_mioi_ivld;
  output sync00_Pop_mioi_ivld_oreg;
  input conf_info_in_Pop_mioi_ivld;
  output conf_info_in_Pop_mioi_ivld_oreg;
  input in_rd_rsp_Pop_mioi_ivld;
  output in_rd_rsp_Pop_mioi_ivld_oreg;
  input in_wr_req_Push_mioi_irdy;
  output in_wr_req_Push_mioi_irdy_oreg;
  output [31:0] while_for_in_length_mul_cmp_z_oreg;
  reg [31:0] while_for_in_length_mul_cmp_z_oreg;


  // Interconnect Declarations
  reg sync00_Pop_mioi_ivld_oreg_rneg;
  reg conf_info_in_Pop_mioi_ivld_oreg_rneg;
  reg in_rd_rsp_Pop_mioi_ivld_oreg_rneg;
  reg in_wr_req_Push_mioi_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign sync00_Pop_mioi_ivld_oreg = ~ sync00_Pop_mioi_ivld_oreg_rneg;
  assign conf_info_in_Pop_mioi_ivld_oreg = ~ conf_info_in_Pop_mioi_ivld_oreg_rneg;
  assign in_rd_rsp_Pop_mioi_ivld_oreg = ~ in_rd_rsp_Pop_mioi_ivld_oreg_rneg;
  assign in_wr_req_Push_mioi_irdy_oreg = ~ in_wr_req_Push_mioi_irdy_oreg_rneg;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync00_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      conf_info_in_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      in_rd_rsp_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      in_wr_req_Push_mioi_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      sync00_Pop_mioi_ivld_oreg_rneg <= ~ sync00_Pop_mioi_ivld;
      conf_info_in_Pop_mioi_ivld_oreg_rneg <= ~ conf_info_in_Pop_mioi_ivld;
      in_rd_rsp_Pop_mioi_ivld_oreg_rneg <= ~ in_rd_rsp_Pop_mioi_ivld;
      in_wr_req_Push_mioi_irdy_oreg_rneg <= ~ in_wr_req_Push_mioi_irdy;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen ) begin
      while_for_in_length_mul_cmp_z_oreg <= while_for_in_length_mul_cmp_z;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_sync00_Pop_mioi_sync00_Pop_mio_wait_dp
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_sync00_Pop_mioi_sync00_Pop_mio_wait_dp (
  clk, rst, sync00_Pop_mioi_oswt, sync00_Pop_mioi_iden, sync00_Pop_mioi_wen_comp,
      sync00_Pop_mioi_biwt, sync00_Pop_mioi_bdwt, sync00_Pop_mioi_bcwt
);
  input clk;
  input rst;
  input sync00_Pop_mioi_oswt;
  output sync00_Pop_mioi_iden;
  output sync00_Pop_mioi_wen_comp;
  input sync00_Pop_mioi_biwt;
  input sync00_Pop_mioi_bdwt;
  output sync00_Pop_mioi_bcwt;
  reg sync00_Pop_mioi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign sync00_Pop_mioi_iden = sync00_Pop_mioi_biwt | sync00_Pop_mioi_bdwt;
  assign sync00_Pop_mioi_wen_comp = (~ sync00_Pop_mioi_oswt) | sync00_Pop_mioi_biwt
      | sync00_Pop_mioi_bcwt;
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      sync00_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      sync00_Pop_mioi_bcwt <= ~((~(sync00_Pop_mioi_bcwt | sync00_Pop_mioi_biwt))
          | sync00_Pop_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_sync00_Pop_mioi_sync00_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_sync00_Pop_mioi_sync00_Pop_mio_wait_ctrl (
  compute_wen, sync00_Pop_mioi_oswt, sync00_Pop_mioi_ivld_oreg, sync00_Pop_mioi_biwt,
      sync00_Pop_mioi_bdwt, sync00_Pop_mioi_bcwt, sync00_Pop_mioi_irdy_compute_sct
);
  input compute_wen;
  input sync00_Pop_mioi_oswt;
  input sync00_Pop_mioi_ivld_oreg;
  output sync00_Pop_mioi_biwt;
  output sync00_Pop_mioi_bdwt;
  input sync00_Pop_mioi_bcwt;
  output sync00_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations
  wire sync00_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign sync00_Pop_mioi_bdwt = sync00_Pop_mioi_oswt & compute_wen;
  assign sync00_Pop_mioi_biwt = sync00_Pop_mioi_ogwt & sync00_Pop_mioi_ivld_oreg;
  assign sync00_Pop_mioi_ogwt = sync00_Pop_mioi_oswt & (~ sync00_Pop_mioi_bcwt);
  assign sync00_Pop_mioi_irdy_compute_sct = sync00_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp
    (
  clk, rst, compute_wen, compute_wten, while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg,
      while_for_for_for_while_for_for_for_mul_cmp_bawt, while_for_for_for_while_for_for_for_mul_cmp_iden,
      while_for_for_for_while_for_for_for_mul_cmp_iswt2, while_for_for_for_while_for_for_for_mul_cmp_iden_1,
      while_for_for_for_while_for_for_for_mul_cmp_a_compute, while_for_for_for_while_for_for_for_mul_cmp_b_compute,
      while_for_for_for_while_for_for_for_mul_cmp_z_mxwt, while_for_for_for_while_for_for_for_mul_cmp_iswt2_pff
);
  input clk;
  input rst;
  input compute_wen;
  input compute_wten;
  input while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg;
  output while_for_for_for_while_for_for_for_mul_cmp_bawt;
  output while_for_for_for_while_for_for_for_mul_cmp_iden;
  input while_for_for_for_while_for_for_for_mul_cmp_iswt2;
  output while_for_for_for_while_for_for_for_mul_cmp_iden_1;
  input [31:0] while_for_for_for_while_for_for_for_mul_cmp_a_compute;
  input [31:0] while_for_for_for_while_for_for_for_mul_cmp_b_compute;
  output [31:0] while_for_for_for_while_for_for_for_mul_cmp_z_mxwt;
  input while_for_for_for_while_for_for_for_mul_cmp_iswt2_pff;


  // Interconnect Declarations
  wire while_for_for_for_while_for_for_for_mul_cmp_bdwt;
  wire [47:0] while_for_for_for_while_for_for_for_mul_cmp_z;
  wire [31:0] while_for_for_for_while_for_for_for_mul_cmp_z_mxwt_pconst;
  wire compute_cgwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_mgc_mul_pipe #(.width_a(32'sd32),
  .signd_a(32'sd1),
  .width_b(32'sd32),
  .signd_b(32'sd1),
  .width_z(32'sd48),
  .clock_edge(32'sd1),
  .enable_active(32'sd1),
  .a_rst_active(32'sd0),
  .s_rst_active(32'sd0),
  .stages(32'sd2),
  .n_inreg(32'sd2)) while_for_for_for_while_for_for_for_mul_cmp (
      .a(while_for_for_for_while_for_for_for_mul_cmp_a_compute),
      .b(while_for_for_for_while_for_for_for_mul_cmp_b_compute),
      .clk(clk),
      .en(compute_cgwt),
      .a_rst(rst),
      .s_rst(1'b1),
      .z(while_for_for_for_while_for_for_for_mul_cmp_z)
    );
  esp_acc_DUMMY_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_mgc_mul_pipe_32_1_32_1_48_1_1_0_0_2_2_wait_ctrl
      DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_mgc_mul_pipe_32_1_32_1_48_1_1_0_0_2_2_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg(while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg),
      .while_for_for_for_while_for_for_for_mul_cmp_iswt2(while_for_for_for_while_for_for_for_mul_cmp_iswt2),
      .while_for_for_for_while_for_for_for_mul_cmp_iden_1(while_for_for_for_while_for_for_for_mul_cmp_iden_1),
      .compute_cgwt(compute_cgwt),
      .while_for_for_for_while_for_for_for_mul_cmp_bdwt(while_for_for_for_while_for_for_for_mul_cmp_bdwt),
      .while_for_for_for_while_for_for_for_mul_cmp_iswt2_pff(while_for_for_for_while_for_for_for_mul_cmp_iswt2_pff)
    );
  esp_acc_DUMMY_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_mgc_mul_pipe_32_1_32_1_48_1_1_0_0_2_2_wait_dp
      DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_mgc_mul_pipe_32_1_32_1_48_1_1_0_0_2_2_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .while_for_for_for_while_for_for_for_mul_cmp_bawt(while_for_for_for_while_for_for_for_mul_cmp_bawt),
      .while_for_for_for_while_for_for_for_mul_cmp_iden(while_for_for_for_while_for_for_for_mul_cmp_iden),
      .while_for_for_for_while_for_for_for_mul_cmp_z_mxwt(while_for_for_for_while_for_for_for_mul_cmp_z_mxwt_pconst),
      .while_for_for_for_while_for_for_for_mul_cmp_biwt(while_for_for_for_while_for_for_for_mul_cmp_iden_1),
      .while_for_for_for_while_for_for_for_mul_cmp_bdwt(while_for_for_for_while_for_for_for_mul_cmp_bdwt),
      .while_for_for_for_while_for_for_for_mul_cmp_z(while_for_for_for_while_for_for_for_mul_cmp_z)
    );
  assign while_for_for_for_while_for_for_for_mul_cmp_z_mxwt = while_for_for_for_while_for_for_for_mul_cmp_z_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_in_wr_req_Push_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_in_wr_req_Push_mioi (
  clk, rst, in_wr_req_val, in_wr_req_rdy, in_wr_req_msg, compute_wen, in_wr_req_Push_mioi_oswt_unreg,
      in_wr_req_Push_mioi_bawt, in_wr_req_Push_mioi_iden, in_wr_req_Push_mioi_iswt0,
      in_wr_req_Push_mioi_wen_comp, in_wr_req_Push_mioi_idat, in_wr_req_Push_mioi_irdy,
      in_wr_req_Push_mioi_irdy_oreg
);
  input clk;
  input rst;
  output in_wr_req_val;
  input in_wr_req_rdy;
  output [31:0] in_wr_req_msg;
  input compute_wen;
  input in_wr_req_Push_mioi_oswt_unreg;
  output in_wr_req_Push_mioi_bawt;
  output in_wr_req_Push_mioi_iden;
  input in_wr_req_Push_mioi_iswt0;
  output in_wr_req_Push_mioi_wen_comp;
  input [31:0] in_wr_req_Push_mioi_idat;
  output in_wr_req_Push_mioi_irdy;
  input in_wr_req_Push_mioi_irdy_oreg;


  // Interconnect Declarations
  wire in_wr_req_Push_mioi_biwt;
  wire in_wr_req_Push_mioi_bdwt;
  wire in_wr_req_Push_mioi_bcwt;
  wire in_wr_req_Push_mioi_ivld_compute_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_out_buf_wait_v5 #(.rscid(32'sd11),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) in_wr_req_Push_mioi (
      .vld(in_wr_req_val),
      .rdy(in_wr_req_rdy),
      .dat(in_wr_req_msg),
      .idat(in_wr_req_Push_mioi_idat),
      .irdy(in_wr_req_Push_mioi_irdy),
      .ivld(in_wr_req_Push_mioi_ivld_compute_sct),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_DataPath_compute_in_wr_req_Push_mioi_in_wr_req_Push_mio_wait_ctrl
      DataPath_compute_in_wr_req_Push_mioi_in_wr_req_Push_mio_wait_ctrl_inst (
      .compute_wen(compute_wen),
      .in_wr_req_Push_mioi_oswt_unreg(in_wr_req_Push_mioi_oswt_unreg),
      .in_wr_req_Push_mioi_iswt0(in_wr_req_Push_mioi_iswt0),
      .in_wr_req_Push_mioi_irdy_oreg(in_wr_req_Push_mioi_irdy_oreg),
      .in_wr_req_Push_mioi_biwt(in_wr_req_Push_mioi_biwt),
      .in_wr_req_Push_mioi_bdwt(in_wr_req_Push_mioi_bdwt),
      .in_wr_req_Push_mioi_bcwt(in_wr_req_Push_mioi_bcwt),
      .in_wr_req_Push_mioi_ivld_compute_sct(in_wr_req_Push_mioi_ivld_compute_sct)
    );
  esp_acc_DUMMY_DataPath_compute_in_wr_req_Push_mioi_in_wr_req_Push_mio_wait_dp DataPath_compute_in_wr_req_Push_mioi_in_wr_req_Push_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .in_wr_req_Push_mioi_oswt_unreg(in_wr_req_Push_mioi_oswt_unreg),
      .in_wr_req_Push_mioi_bawt(in_wr_req_Push_mioi_bawt),
      .in_wr_req_Push_mioi_iden(in_wr_req_Push_mioi_iden),
      .in_wr_req_Push_mioi_wen_comp(in_wr_req_Push_mioi_wen_comp),
      .in_wr_req_Push_mioi_biwt(in_wr_req_Push_mioi_biwt),
      .in_wr_req_Push_mioi_bdwt(in_wr_req_Push_mioi_bdwt),
      .in_wr_req_Push_mioi_bcwt(in_wr_req_Push_mioi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_in_rd_rsp_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_in_rd_rsp_Pop_mioi (
  clk, rst, in_rd_rsp_val, in_rd_rsp_rdy, in_rd_rsp_msg, compute_wen, in_rd_rsp_Pop_mioi_oswt_unreg,
      in_rd_rsp_Pop_mioi_bawt, in_rd_rsp_Pop_mioi_iden, in_rd_rsp_Pop_mioi_iswt0,
      in_rd_rsp_Pop_mioi_wen_comp, in_rd_rsp_Pop_mioi_idat_mxwt, in_rd_rsp_Pop_mioi_ivld,
      in_rd_rsp_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input in_rd_rsp_val;
  output in_rd_rsp_rdy;
  input [63:0] in_rd_rsp_msg;
  input compute_wen;
  input in_rd_rsp_Pop_mioi_oswt_unreg;
  output in_rd_rsp_Pop_mioi_bawt;
  output in_rd_rsp_Pop_mioi_iden;
  input in_rd_rsp_Pop_mioi_iswt0;
  output in_rd_rsp_Pop_mioi_wen_comp;
  output [63:0] in_rd_rsp_Pop_mioi_idat_mxwt;
  output in_rd_rsp_Pop_mioi_ivld;
  input in_rd_rsp_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire in_rd_rsp_Pop_mioi_biwt;
  wire in_rd_rsp_Pop_mioi_bdwt;
  wire in_rd_rsp_Pop_mioi_bcwt;
  wire [63:0] in_rd_rsp_Pop_mioi_idat;
  wire in_rd_rsp_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd10),
  .width(32'sd64),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) in_rd_rsp_Pop_mioi (
      .vld(in_rd_rsp_val),
      .rdy(in_rd_rsp_rdy),
      .dat(in_rd_rsp_msg),
      .idat(in_rd_rsp_Pop_mioi_idat),
      .irdy(in_rd_rsp_Pop_mioi_irdy_compute_sct),
      .ivld(in_rd_rsp_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_DataPath_compute_in_rd_rsp_Pop_mioi_in_rd_rsp_Pop_mio_wait_ctrl DataPath_compute_in_rd_rsp_Pop_mioi_in_rd_rsp_Pop_mio_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .in_rd_rsp_Pop_mioi_oswt_unreg(in_rd_rsp_Pop_mioi_oswt_unreg),
      .in_rd_rsp_Pop_mioi_iswt0(in_rd_rsp_Pop_mioi_iswt0),
      .in_rd_rsp_Pop_mioi_ivld_oreg(in_rd_rsp_Pop_mioi_ivld_oreg),
      .in_rd_rsp_Pop_mioi_biwt(in_rd_rsp_Pop_mioi_biwt),
      .in_rd_rsp_Pop_mioi_bdwt(in_rd_rsp_Pop_mioi_bdwt),
      .in_rd_rsp_Pop_mioi_bcwt(in_rd_rsp_Pop_mioi_bcwt),
      .in_rd_rsp_Pop_mioi_irdy_compute_sct(in_rd_rsp_Pop_mioi_irdy_compute_sct)
    );
  esp_acc_DUMMY_DataPath_compute_in_rd_rsp_Pop_mioi_in_rd_rsp_Pop_mio_wait_dp DataPath_compute_in_rd_rsp_Pop_mioi_in_rd_rsp_Pop_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .in_rd_rsp_Pop_mioi_oswt_unreg(in_rd_rsp_Pop_mioi_oswt_unreg),
      .in_rd_rsp_Pop_mioi_bawt(in_rd_rsp_Pop_mioi_bawt),
      .in_rd_rsp_Pop_mioi_iden(in_rd_rsp_Pop_mioi_iden),
      .in_rd_rsp_Pop_mioi_wen_comp(in_rd_rsp_Pop_mioi_wen_comp),
      .in_rd_rsp_Pop_mioi_idat_mxwt(in_rd_rsp_Pop_mioi_idat_mxwt),
      .in_rd_rsp_Pop_mioi_biwt(in_rd_rsp_Pop_mioi_biwt),
      .in_rd_rsp_Pop_mioi_bdwt(in_rd_rsp_Pop_mioi_bdwt),
      .in_rd_rsp_Pop_mioi_bcwt(in_rd_rsp_Pop_mioi_bcwt),
      .in_rd_rsp_Pop_mioi_idat(in_rd_rsp_Pop_mioi_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_conf_info_in_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_conf_info_in_Pop_mioi (
  clk, rst, conf_info_in_val, conf_info_in_rdy, conf_info_in_msg, compute_wen, conf_info_in_Pop_mioi_oswt,
      conf_info_in_Pop_mioi_iden, conf_info_in_Pop_mioi_wen_comp, conf_info_in_Pop_mioi_idat_mxwt,
      conf_info_in_Pop_mioi_ivld, conf_info_in_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input conf_info_in_val;
  output conf_info_in_rdy;
  input [95:0] conf_info_in_msg;
  input compute_wen;
  input conf_info_in_Pop_mioi_oswt;
  output conf_info_in_Pop_mioi_iden;
  output conf_info_in_Pop_mioi_wen_comp;
  output [95:0] conf_info_in_Pop_mioi_idat_mxwt;
  output conf_info_in_Pop_mioi_ivld;
  input conf_info_in_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire conf_info_in_Pop_mioi_biwt;
  wire conf_info_in_Pop_mioi_bdwt;
  wire conf_info_in_Pop_mioi_bcwt;
  wire [95:0] conf_info_in_Pop_mioi_idat;
  wire conf_info_in_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd9),
  .width(32'sd96),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_in_Pop_mioi (
      .vld(conf_info_in_val),
      .rdy(conf_info_in_rdy),
      .dat(conf_info_in_msg),
      .idat(conf_info_in_Pop_mioi_idat),
      .irdy(conf_info_in_Pop_mioi_irdy_compute_sct),
      .ivld(conf_info_in_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_DataPath_compute_conf_info_in_Pop_mioi_conf_info_in_Pop_mio_wait_ctrl
      DataPath_compute_conf_info_in_Pop_mioi_conf_info_in_Pop_mio_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .conf_info_in_Pop_mioi_oswt(conf_info_in_Pop_mioi_oswt),
      .conf_info_in_Pop_mioi_ivld_oreg(conf_info_in_Pop_mioi_ivld_oreg),
      .conf_info_in_Pop_mioi_biwt(conf_info_in_Pop_mioi_biwt),
      .conf_info_in_Pop_mioi_bdwt(conf_info_in_Pop_mioi_bdwt),
      .conf_info_in_Pop_mioi_bcwt(conf_info_in_Pop_mioi_bcwt),
      .conf_info_in_Pop_mioi_irdy_compute_sct(conf_info_in_Pop_mioi_irdy_compute_sct)
    );
  esp_acc_DUMMY_DataPath_compute_conf_info_in_Pop_mioi_conf_info_in_Pop_mio_wait_dp
      DataPath_compute_conf_info_in_Pop_mioi_conf_info_in_Pop_mio_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_in_Pop_mioi_oswt(conf_info_in_Pop_mioi_oswt),
      .conf_info_in_Pop_mioi_iden(conf_info_in_Pop_mioi_iden),
      .conf_info_in_Pop_mioi_wen_comp(conf_info_in_Pop_mioi_wen_comp),
      .conf_info_in_Pop_mioi_idat_mxwt(conf_info_in_Pop_mioi_idat_mxwt),
      .conf_info_in_Pop_mioi_biwt(conf_info_in_Pop_mioi_biwt),
      .conf_info_in_Pop_mioi_bdwt(conf_info_in_Pop_mioi_bdwt),
      .conf_info_in_Pop_mioi_bcwt(conf_info_in_Pop_mioi_bcwt),
      .conf_info_in_Pop_mioi_idat(conf_info_in_Pop_mioi_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute_sync00_Pop_mioi
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute_sync00_Pop_mioi (
  clk, rst, sync00_val, sync00_rdy, sync00_msg, compute_wen, sync00_Pop_mioi_oswt,
      sync00_Pop_mioi_iden, sync00_Pop_mioi_wen_comp, sync00_Pop_mioi_ivld, sync00_Pop_mioi_ivld_oreg
);
  input clk;
  input rst;
  input sync00_val;
  output sync00_rdy;
  input sync00_msg;
  input compute_wen;
  input sync00_Pop_mioi_oswt;
  output sync00_Pop_mioi_iden;
  output sync00_Pop_mioi_wen_comp;
  output sync00_Pop_mioi_ivld;
  input sync00_Pop_mioi_ivld_oreg;


  // Interconnect Declarations
  wire sync00_Pop_mioi_biwt;
  wire sync00_Pop_mioi_bdwt;
  wire sync00_Pop_mioi_bcwt;
  wire sync00_Pop_mioi_idat;
  wire sync00_Pop_mioi_irdy_compute_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_DUMMY_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd8),
  .width(32'sd1),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) sync00_Pop_mioi (
      .vld(sync00_val),
      .rdy(sync00_rdy),
      .dat(sync00_msg),
      .idat(sync00_Pop_mioi_idat),
      .irdy(sync00_Pop_mioi_irdy_compute_sct),
      .ivld(sync00_Pop_mioi_ivld),
      .clk(clk),
      .en(1'b0),
      .arst(rst),
      .srst(1'b1)
    );
  esp_acc_DUMMY_DataPath_compute_sync00_Pop_mioi_sync00_Pop_mio_wait_ctrl DataPath_compute_sync00_Pop_mioi_sync00_Pop_mio_wait_ctrl_inst
      (
      .compute_wen(compute_wen),
      .sync00_Pop_mioi_oswt(sync00_Pop_mioi_oswt),
      .sync00_Pop_mioi_ivld_oreg(sync00_Pop_mioi_ivld_oreg),
      .sync00_Pop_mioi_biwt(sync00_Pop_mioi_biwt),
      .sync00_Pop_mioi_bdwt(sync00_Pop_mioi_bdwt),
      .sync00_Pop_mioi_bcwt(sync00_Pop_mioi_bcwt),
      .sync00_Pop_mioi_irdy_compute_sct(sync00_Pop_mioi_irdy_compute_sct)
    );
  esp_acc_DUMMY_DataPath_compute_sync00_Pop_mioi_sync00_Pop_mio_wait_dp DataPath_compute_sync00_Pop_mioi_sync00_Pop_mio_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .sync00_Pop_mioi_oswt(sync00_Pop_mioi_oswt),
      .sync00_Pop_mioi_iden(sync00_Pop_mioi_iden),
      .sync00_Pop_mioi_wen_comp(sync00_Pop_mioi_wen_comp),
      .sync00_Pop_mioi_biwt(sync00_Pop_mioi_biwt),
      .sync00_Pop_mioi_bdwt(sync00_Pop_mioi_bdwt),
      .sync00_Pop_mioi_bcwt(sync00_Pop_mioi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_DUMMY_DataPath_compute
// ------------------------------------------------------------------


module esp_acc_DUMMY_DataPath_compute (
  clk, rst, conf_info_in_val, conf_info_in_rdy, conf_info_in_msg, sync00_val, sync00_rdy,
      sync00_msg, in_wr_req_val, in_wr_req_rdy, in_wr_req_msg, in_rd_rsp_val, in_rd_rsp_rdy,
      in_rd_rsp_msg, while_for_in_length_mul_cmp_a, while_for_in_length_mul_cmp_b,
      while_for_in_length_mul_cmp_z
);
  input clk;
  input rst;
  input conf_info_in_val;
  output conf_info_in_rdy;
  input [95:0] conf_info_in_msg;
  input sync00_val;
  output sync00_rdy;
  input sync00_msg;
  output in_wr_req_val;
  input in_wr_req_rdy;
  output [31:0] in_wr_req_msg;
  input in_rd_rsp_val;
  output in_rd_rsp_rdy;
  input [63:0] in_rd_rsp_msg;
  output [31:0] while_for_in_length_mul_cmp_a;
  reg [31:0] while_for_in_length_mul_cmp_a;
  output [31:0] while_for_in_length_mul_cmp_b;
  reg [31:0] while_for_in_length_mul_cmp_b;
  input [31:0] while_for_in_length_mul_cmp_z;


  // Interconnect Declarations
  wire compute_wen;
  wire compute_wten;
  wire sync00_Pop_mioi_iden;
  wire sync00_Pop_mioi_wen_comp;
  wire sync00_Pop_mioi_ivld;
  wire sync00_Pop_mioi_ivld_oreg;
  wire conf_info_in_Pop_mioi_iden;
  wire conf_info_in_Pop_mioi_wen_comp;
  wire [95:0] conf_info_in_Pop_mioi_idat_mxwt;
  wire conf_info_in_Pop_mioi_ivld;
  wire conf_info_in_Pop_mioi_ivld_oreg;
  wire in_rd_rsp_Pop_mioi_bawt;
  wire in_rd_rsp_Pop_mioi_iden;
  reg in_rd_rsp_Pop_mioi_iswt0;
  wire in_rd_rsp_Pop_mioi_wen_comp;
  wire [63:0] in_rd_rsp_Pop_mioi_idat_mxwt;
  wire in_rd_rsp_Pop_mioi_ivld;
  wire in_rd_rsp_Pop_mioi_ivld_oreg;
  wire in_wr_req_Push_mioi_bawt;
  wire in_wr_req_Push_mioi_iden;
  reg in_wr_req_Push_mioi_iswt0;
  wire in_wr_req_Push_mioi_wen_comp;
  reg [31:0] in_wr_req_Push_mioi_idat;
  wire in_wr_req_Push_mioi_irdy;
  wire in_wr_req_Push_mioi_irdy_oreg;
  wire while_for_for_for_while_for_for_for_mul_cmp_bawt;
  wire while_for_for_for_while_for_for_for_mul_cmp_iden;
  wire while_for_for_for_while_for_for_for_mul_cmp_iden_1;
  wire [31:0] while_for_for_for_while_for_for_for_mul_cmp_z_mxwt;
  wire [31:0] while_for_in_length_mul_cmp_z_oreg;
  reg compute_flen;
  wire [8:0] fsm_output;
  wire not_tmp_23;
  wire or_tmp_102;
  wire and_dcpl_23;
  wire and_dcpl_49;
  wire and_dcpl_50;
  wire and_dcpl_51;
  wire and_tmp_46;
  wire and_tmp_47;
  wire mux_tmp_237;
  wire mux_tmp_238;
  wire and_dcpl_64;
  wire and_dcpl_70;
  wire and_dcpl_74;
  wire or_dcpl_39;
  wire or_dcpl_41;
  wire mux_tmp_239;
  wire or_dcpl_45;
  wire or_dcpl_48;
  wire or_dcpl_50;
  wire or_dcpl_60;
  wire or_dcpl_63;
  wire or_dcpl_65;
  wire or_tmp_192;
  wire or_tmp_195;
  wire or_tmp_244;
  wire while_for_for_for_while_for_for_for_or_cse;
  wire while_for_for_for_while_for_for_for_or_5_cse;
  wire and_170_cse;
  wire and_189_cse;
  wire and_187_cse;
  wire and_241_cse;
  wire and_284_cse;
  wire and_304_cse;
  wire exit_while_for_sva_mx0;
  wire exit_while_for_for_sva_mx0;
  reg while_for_for_for_stage_v_1;
  reg while_for_for_for_stage_v_2;
  wire while_for_for_for_stage_v_3_mx2;
  reg while_for_for_for_stage_0_1;
  reg while_for_for_for_stage_v_3;
  reg while_for_for_for_stage_v_4;
  wire while_for_for_for_stage_v_5_mx2;
  reg while_for_for_for_stage_0_2;
  reg while_for_for_for_while_for_for_for_if_nor_svs_st_2;
  reg while_for_for_for_stage_v_5;
  reg while_for_for_for_stage_v;
  wire while_for_for_for_stage_v_4_mx1;
  reg while_for_for_for_stage_0_3;
  reg [95:0] conf_info_in_Pop_mio_mrgout_dat_sva;
  reg while_for_for_in_len_slc_32_svs;
  reg while_for_for_for_stage_0;
  reg exit_while_for_for_for_sva_st_2;
  reg while_for_for_for_asn_3_itm;
  reg while_for_for_for_asn_3_itm_2;
  reg while_for_for_for_while_for_for_for_if_nor_svs_2;
  reg while_for_for_for_asn_3_itm_1;
  reg while_for_for_for_while_for_for_for_if_nor_svs_st_1;
  reg while_for_for_for_while_for_for_for_if_nor_svs_1;
  reg exit_while_for_for_for_sva_st_1;
  reg while_for_for_for_while_for_for_for_if_nor_svs_st;
  reg exit_while_for_for_for_sva_st;
  reg while_for_for_for_while_for_for_for_if_nor_svs;
  reg [24:0] while_for_for_in_rem_31_7_sva;
  reg [6:0] while_for_in_length_sva_6_0;
  reg reg_sync00_Pop_mioi_oswt_cse;
  reg reg_in_rd_rsp_Pop_mioi_oswt_cse;
  wire while_for_for_for_if_and_2_cse;
  wire while_for_for_for_and_12_cse;
  wire while_for_for_in_len_and_cse;
  wire while_for_for_for_and_28_cse;
  wire while_for_for_for_and_23_cse;
  wire while_for_for_for_and_18_cse;
  wire and_414_cse;
  wire nand_25_cse;
  wire and_385_rmff;
  reg [15:0] while_for_b_sva;
  reg [6:0] while_for_for_in_len_qr_6_0_lpi_3_dfm;
  reg [31:0] while_for_for_acc_fx_sva;
  reg [30:0] while_for_for_vec_indx_31_1_sva;
  reg [9:0] while_for_for_for_i_10_1_sva;
  reg [31:0] while_for_for_acc_fx_sva_1;
  reg [30:0] while_for_for_vec_indx_31_1_sva_1;
  reg while_for_for_for_stage_en_2;
  reg while_for_for_for_stage_en_4;
  reg while_for_for_for_stage_en_6;
  wire [31:0] while_for_for_acc_fx_sva_1_mx0w0;
  wire [32:0] nl_while_for_for_acc_fx_sva_1_mx0w0;
  wire while_for_for_for_stage_en_2_mx1w0;
  wire while_for_for_for_stage_en_4_mx1w0;
  wire while_for_for_for_stage_en_6_mx1w0;
  wire [15:0] while_for_b_sva_2;
  wire [16:0] nl_while_for_b_sva_2;
  wire [24:0] while_for_for_in_rem_31_7_sva_3;
  wire [25:0] nl_while_for_for_in_rem_31_7_sva_3;
  wire while_for_for_for_stage_0_mx0c1;
  wire while_for_for_for_stage_v_1_mx0c1;
  wire while_for_for_for_stage_v_2_mx0c0;
  wire while_for_for_for_stage_v_4_mx0c0;
  wire [30:0] while_for_for_vec_indx_31_1_sva_2;
  wire [31:0] nl_while_for_for_vec_indx_31_1_sva_2;
  wire [63:0] conf_info_in_Pop_mio_mrgout_dat_sva_mx0_95_32;
  wire while_for_for_for_while_for_for_for_if_nor_svs_st_1_1;
  wire while_for_for_for_acc_4_itm_32_1;
  wire while_for_for_in_len_acc_itm_32_1;

  wire mux1h_nl;
  wire nor_nl;
  wire sync00_read_reset_check_reset_mux_4_nl;
  wire while_for_for_for_mux_5_nl;
  wire while_for_for_for_mux_7_nl;
  wire while_for_for_for_mux_9_nl;
  wire nor_1_nl;
  wire or_271_nl;
  wire[9:0] while_for_for_for_acc_3_nl;
  wire[10:0] nl_while_for_for_for_acc_3_nl;
  wire while_for_for_for_i_not_1_nl;
  wire while_for_for_in_len_not_4_nl;
  wire while_for_for_for_mux_39_nl;
  wire sync00_read_reset_check_reset_while_for_for_for_nor_nl;
  wire mux_240_nl;
  wire nand_21_nl;
  wire mux_242_nl;
  wire mux_241_nl;
  wire or_259_nl;
  wire mux_243_nl;
  wire or_260_nl;
  wire[32:0] while_for_acc_2_nl;
  wire[33:0] nl_while_for_acc_2_nl;
  wire[32:0] while_for_acc_3_nl;
  wire[33:0] nl_while_for_acc_3_nl;
  wire[32:0] while_for_for_acc_2_nl;
  wire[33:0] nl_while_for_for_acc_2_nl;
  wire[32:0] while_for_for_acc_nl;
  wire[33:0] nl_while_for_for_acc_nl;
  wire[32:0] while_for_for_for_acc_4_nl;
  wire[33:0] nl_while_for_for_for_acc_4_nl;
  wire[24:0] while_for_for_in_len_mux_nl;
  wire[32:0] while_for_for_in_len_acc_nl;
  wire[33:0] nl_while_for_for_in_len_acc_nl;
  wire or_368_nl;
  wire or_152_nl;
  wire or_226_nl;

  // Interconnect Declarations for Component Instantiations 
  wire  nl_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst_while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg;
  assign nl_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst_while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg
      = and_dcpl_64 & and_dcpl_74 & (fsm_output[5]);
  wire [31:0] nl_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst_while_for_for_for_while_for_for_for_mul_cmp_a_compute;
  assign nl_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst_while_for_for_for_while_for_for_for_mul_cmp_a_compute
      = in_rd_rsp_Pop_mioi_idat_mxwt[31:0];
  wire [31:0] nl_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst_while_for_for_for_while_for_for_for_mul_cmp_b_compute;
  assign nl_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst_while_for_for_for_while_for_for_for_mul_cmp_b_compute
      = in_rd_rsp_Pop_mioi_idat_mxwt[63:32];
  esp_acc_DUMMY_DataPath_compute_sync00_Pop_mioi DataPath_compute_sync00_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .sync00_val(sync00_val),
      .sync00_rdy(sync00_rdy),
      .sync00_msg(sync00_msg),
      .compute_wen(compute_wen),
      .sync00_Pop_mioi_oswt(reg_sync00_Pop_mioi_oswt_cse),
      .sync00_Pop_mioi_iden(sync00_Pop_mioi_iden),
      .sync00_Pop_mioi_wen_comp(sync00_Pop_mioi_wen_comp),
      .sync00_Pop_mioi_ivld(sync00_Pop_mioi_ivld),
      .sync00_Pop_mioi_ivld_oreg(sync00_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_DataPath_compute_wait_dp DataPath_compute_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .while_for_in_length_mul_cmp_z(while_for_in_length_mul_cmp_z),
      .compute_wen(compute_wen),
      .sync00_Pop_mioi_ivld(sync00_Pop_mioi_ivld),
      .sync00_Pop_mioi_ivld_oreg(sync00_Pop_mioi_ivld_oreg),
      .conf_info_in_Pop_mioi_ivld(conf_info_in_Pop_mioi_ivld),
      .conf_info_in_Pop_mioi_ivld_oreg(conf_info_in_Pop_mioi_ivld_oreg),
      .in_rd_rsp_Pop_mioi_ivld(in_rd_rsp_Pop_mioi_ivld),
      .in_rd_rsp_Pop_mioi_ivld_oreg(in_rd_rsp_Pop_mioi_ivld_oreg),
      .in_wr_req_Push_mioi_irdy(in_wr_req_Push_mioi_irdy),
      .in_wr_req_Push_mioi_irdy_oreg(in_wr_req_Push_mioi_irdy_oreg),
      .while_for_in_length_mul_cmp_z_oreg(while_for_in_length_mul_cmp_z_oreg)
    );
  esp_acc_DUMMY_DataPath_compute_conf_info_in_Pop_mioi DataPath_compute_conf_info_in_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_in_val(conf_info_in_val),
      .conf_info_in_rdy(conf_info_in_rdy),
      .conf_info_in_msg(conf_info_in_msg),
      .compute_wen(compute_wen),
      .conf_info_in_Pop_mioi_oswt(reg_sync00_Pop_mioi_oswt_cse),
      .conf_info_in_Pop_mioi_iden(conf_info_in_Pop_mioi_iden),
      .conf_info_in_Pop_mioi_wen_comp(conf_info_in_Pop_mioi_wen_comp),
      .conf_info_in_Pop_mioi_idat_mxwt(conf_info_in_Pop_mioi_idat_mxwt),
      .conf_info_in_Pop_mioi_ivld(conf_info_in_Pop_mioi_ivld),
      .conf_info_in_Pop_mioi_ivld_oreg(conf_info_in_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_DataPath_compute_in_rd_rsp_Pop_mioi DataPath_compute_in_rd_rsp_Pop_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .in_rd_rsp_val(in_rd_rsp_val),
      .in_rd_rsp_rdy(in_rd_rsp_rdy),
      .in_rd_rsp_msg(in_rd_rsp_msg),
      .compute_wen(compute_wen),
      .in_rd_rsp_Pop_mioi_oswt_unreg(or_tmp_192),
      .in_rd_rsp_Pop_mioi_bawt(in_rd_rsp_Pop_mioi_bawt),
      .in_rd_rsp_Pop_mioi_iden(in_rd_rsp_Pop_mioi_iden),
      .in_rd_rsp_Pop_mioi_iswt0(in_rd_rsp_Pop_mioi_iswt0),
      .in_rd_rsp_Pop_mioi_wen_comp(in_rd_rsp_Pop_mioi_wen_comp),
      .in_rd_rsp_Pop_mioi_idat_mxwt(in_rd_rsp_Pop_mioi_idat_mxwt),
      .in_rd_rsp_Pop_mioi_ivld(in_rd_rsp_Pop_mioi_ivld),
      .in_rd_rsp_Pop_mioi_ivld_oreg(in_rd_rsp_Pop_mioi_ivld_oreg)
    );
  esp_acc_DUMMY_DataPath_compute_in_wr_req_Push_mioi DataPath_compute_in_wr_req_Push_mioi_inst
      (
      .clk(clk),
      .rst(rst),
      .in_wr_req_val(in_wr_req_val),
      .in_wr_req_rdy(in_wr_req_rdy),
      .in_wr_req_msg(in_wr_req_msg),
      .compute_wen(compute_wen),
      .in_wr_req_Push_mioi_oswt_unreg(or_tmp_195),
      .in_wr_req_Push_mioi_bawt(in_wr_req_Push_mioi_bawt),
      .in_wr_req_Push_mioi_iden(in_wr_req_Push_mioi_iden),
      .in_wr_req_Push_mioi_iswt0(in_wr_req_Push_mioi_iswt0),
      .in_wr_req_Push_mioi_wen_comp(in_wr_req_Push_mioi_wen_comp),
      .in_wr_req_Push_mioi_idat(in_wr_req_Push_mioi_idat),
      .in_wr_req_Push_mioi_irdy(in_wr_req_Push_mioi_irdy),
      .in_wr_req_Push_mioi_irdy_oreg(in_wr_req_Push_mioi_irdy_oreg)
    );
  esp_acc_DUMMY_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg(nl_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst_while_for_for_for_while_for_for_for_mul_cmp_oswt_unreg),
      .while_for_for_for_while_for_for_for_mul_cmp_bawt(while_for_for_for_while_for_for_for_mul_cmp_bawt),
      .while_for_for_for_while_for_for_for_mul_cmp_iden(while_for_for_for_while_for_for_for_mul_cmp_iden),
      .while_for_for_for_while_for_for_for_mul_cmp_iswt2(reg_in_rd_rsp_Pop_mioi_oswt_cse),
      .while_for_for_for_while_for_for_for_mul_cmp_iden_1(while_for_for_for_while_for_for_for_mul_cmp_iden_1),
      .while_for_for_for_while_for_for_for_mul_cmp_a_compute(nl_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst_while_for_for_for_while_for_for_for_mul_cmp_a_compute[31:0]),
      .while_for_for_for_while_for_for_for_mul_cmp_b_compute(nl_DataPath_compute_while_for_for_for_while_for_for_for_mul_cmp_inst_while_for_for_for_while_for_for_for_mul_cmp_b_compute[31:0]),
      .while_for_for_for_while_for_for_for_mul_cmp_z_mxwt(while_for_for_for_while_for_for_for_mul_cmp_z_mxwt),
      .while_for_for_for_while_for_for_for_mul_cmp_iswt2_pff(or_tmp_192)
    );
  esp_acc_DUMMY_DataPath_compute_staller DataPath_compute_staller_inst (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .compute_wten(compute_wten),
      .sync00_Pop_mioi_iden(sync00_Pop_mioi_iden),
      .sync00_Pop_mioi_wen_comp(sync00_Pop_mioi_wen_comp),
      .conf_info_in_Pop_mioi_iden(conf_info_in_Pop_mioi_iden),
      .conf_info_in_Pop_mioi_wen_comp(conf_info_in_Pop_mioi_wen_comp),
      .in_rd_rsp_Pop_mioi_iden(in_rd_rsp_Pop_mioi_iden),
      .in_rd_rsp_Pop_mioi_wen_comp(in_rd_rsp_Pop_mioi_wen_comp),
      .in_wr_req_Push_mioi_iden(in_wr_req_Push_mioi_iden),
      .in_wr_req_Push_mioi_wen_comp(in_wr_req_Push_mioi_wen_comp),
      .while_for_for_for_while_for_for_for_mul_cmp_iden(while_for_for_for_while_for_for_for_mul_cmp_iden),
      .while_for_for_for_while_for_for_for_mul_cmp_iden_1(while_for_for_for_while_for_for_for_mul_cmp_iden_1),
      .compute_flen_unreg(and_385_rmff)
    );
  esp_acc_DUMMY_DataPath_compute_compute_fsm DataPath_compute_compute_fsm_inst (
      .clk(clk),
      .rst(rst),
      .compute_wen(compute_wen),
      .fsm_output(fsm_output),
      .while_C_0_tr0(exit_while_for_sva_mx0),
      .while_for_C_1_tr0(exit_while_for_for_sva_mx0),
      .while_for_for_for_C_1_tr0(and_dcpl_50),
      .while_for_for_C_1_tr0(exit_while_for_for_sva_mx0),
      .while_for_C_2_tr0(exit_while_for_sva_mx0)
    );
  assign sync00_read_reset_check_reset_mux_4_nl = MUX_s_1_2_2(while_for_for_for_stage_0,
      while_for_for_for_stage_0_1, or_tmp_244);
  assign while_for_for_for_mux_5_nl = MUX_s_1_2_2(while_for_for_for_stage_en_2, while_for_for_for_stage_en_2_mx1w0,
      fsm_output[6]);
  assign while_for_for_for_mux_7_nl = MUX_s_1_2_2(while_for_for_for_stage_en_4, while_for_for_for_stage_en_4_mx1w0,
      fsm_output[6]);
  assign while_for_for_for_mux_9_nl = MUX_s_1_2_2(while_for_for_for_stage_en_6, while_for_for_for_stage_en_6_mx1w0,
      fsm_output[6]);
  assign nor_nl = ~(((~((while_for_for_for_stage_v & (~ (fsm_output[4]))) | (while_for_for_for_stage_v_1
      & or_tmp_244) | (while_for_for_for_stage_v_3 & (and_dcpl_70 | (or_dcpl_41 &
      (fsm_output[6])))) | (while_for_for_for_stage_v_5 & (and_dcpl_70 | (nand_25_cse
      & (fsm_output[6])))))) & (sync00_read_reset_check_reset_mux_4_nl | (fsm_output[4])))
      | while_for_for_for_mux_5_nl | while_for_for_for_mux_7_nl | while_for_for_for_mux_9_nl);
  assign nor_1_nl = ~((while_for_for_for_stage_v & (~(while_for_for_for_stage_v_1
      | (while_for_for_for_stage_v_2 & or_dcpl_63))) & while_for_for_for_stage_0_1
      & (while_for_for_for_while_for_for_for_mul_cmp_bawt | (~((~ exit_while_for_for_for_sva_st_2)
      & while_for_for_for_stage_v_4_mx1)))) | (while_for_for_for_stage_v_2 & (~(while_for_for_for_stage_v_3
      | while_for_for_for_stage_v_4_mx1)) & while_for_for_for_stage_0_2) | (while_for_for_for_stage_v_4
      & (~ while_for_for_for_stage_v_5) & while_for_for_for_stage_0_3 & while_for_for_for_while_for_for_for_or_cse));
  assign or_271_nl = ((nand_25_cse | while_for_for_for_stage_0_2 | while_for_for_for_stage_0
      | while_for_for_for_stage_0_1) & (fsm_output[6])) | (fsm_output[4]);
  assign mux1h_nl = MUX1HOT_s_1_3_2(nor_nl, nor_1_nl, compute_flen, {or_271_nl ,
      (fsm_output[5]) , and_187_cse});
  assign and_385_rmff = mux1h_nl & (~(and_dcpl_50 & (fsm_output[6])));
  assign while_for_for_for_if_and_2_cse = compute_wen & (~((~ (fsm_output[6])) |
      or_dcpl_41));
  assign while_for_for_for_and_12_cse = compute_wen & (fsm_output[6]);
  assign while_for_for_for_while_for_for_for_if_nor_svs_st_1_1 = ~((while_for_for_vec_indx_31_1_sva_2
      != (conf_info_in_Pop_mio_mrgout_dat_sva[95:65])) | (conf_info_in_Pop_mio_mrgout_dat_sva[64]));
  assign while_for_for_in_len_and_cse = compute_wen & (~ or_dcpl_45);
  assign while_for_for_for_and_18_cse = compute_wen & (~(while_for_for_for_stage_v_1
      | (fsm_output[6])));
  assign while_for_for_for_and_23_cse = compute_wen & (~((~ or_tmp_102) | while_for_for_for_stage_v_4))
      & (fsm_output[6]);
  assign and_414_cse = while_for_for_for_stage_0_1 & while_for_for_for_stage_v_1;
  assign while_for_for_for_and_28_cse = compute_wen & (~((~ or_tmp_102) | (while_for_for_for_stage_v_4
      & while_for_for_for_stage_v_3) | while_for_for_for_stage_v_2)) & (fsm_output[6]);
  assign nl_while_for_for_acc_fx_sva_1_mx0w0 = while_for_for_acc_fx_sva + while_for_for_for_while_for_for_for_mul_cmp_z_mxwt;
  assign while_for_for_acc_fx_sva_1_mx0w0 = nl_while_for_for_acc_fx_sva_1_mx0w0[31:0];
  assign while_for_for_for_while_for_for_for_or_5_cse = in_rd_rsp_Pop_mioi_bawt |
      exit_while_for_for_for_sva_st;
  assign while_for_for_for_stage_en_2_mx1w0 = while_for_for_for_stage_v_1 & (~(while_for_for_for_stage_v_2
      | while_for_for_for_stage_v_3_mx2)) & while_for_for_for_stage_0_1 & while_for_for_for_while_for_for_for_or_5_cse
      & (~ while_for_for_for_stage_v_5_mx2);
  assign while_for_for_for_stage_en_4_mx1w0 = while_for_for_for_stage_v_3 & (~(while_for_for_for_stage_v_4
      | while_for_for_for_stage_v_5_mx2)) & while_for_for_for_stage_0_2;
  assign while_for_for_for_stage_en_6_mx1w0 = while_for_for_for_stage_v_5 & (in_wr_req_Push_mioi_bawt
      | (~(while_for_for_for_while_for_for_for_if_nor_svs_st_2 & (~ exit_while_for_for_for_sva_st_2))));
  assign nl_while_for_acc_2_nl = ({1'b1 , (~ (conf_info_in_Pop_mioi_idat_mxwt[31:0]))})
      + 33'b000000000000000000000000000000001;
  assign while_for_acc_2_nl = nl_while_for_acc_2_nl[32:0];
  assign nl_while_for_acc_3_nl = ({17'b10000000000000000 , while_for_b_sva_2}) +
      conv_u2u_32_33(~ (conf_info_in_Pop_mio_mrgout_dat_sva[31:0])) + 33'b000000000000000000000000000000001;
  assign while_for_acc_3_nl = nl_while_for_acc_3_nl[32:0];
  assign exit_while_for_sva_mx0 = MUX_s_1_2_2((~ (readslicef_33_1_32(while_for_acc_2_nl))),
      (~ (readslicef_33_1_32(while_for_acc_3_nl))), fsm_output[8]);
  assign conf_info_in_Pop_mio_mrgout_dat_sva_mx0_95_32 = MUX_v_64_2_2((conf_info_in_Pop_mio_mrgout_dat_sva[95:32]),
      (conf_info_in_Pop_mioi_idat_mxwt[95:32]), fsm_output[1]);
  assign nl_while_for_b_sva_2 = while_for_b_sva + 16'b0000000000000001;
  assign while_for_b_sva_2 = nl_while_for_b_sva_2[15:0];
  assign nl_while_for_for_acc_2_nl =  -conv_s2s_32_33(while_for_in_length_mul_cmp_z_oreg);
  assign while_for_for_acc_2_nl = nl_while_for_for_acc_2_nl[32:0];
  assign nl_while_for_for_acc_nl = conv_s2u_32_33({(~ while_for_for_in_rem_31_7_sva_3)
      , (~ while_for_in_length_sva_6_0)}) + 33'b000000000000000000000000000000001;
  assign while_for_for_acc_nl = nl_while_for_for_acc_nl[32:0];
  assign exit_while_for_for_sva_mx0 = MUX_s_1_2_2((~ (readslicef_33_1_32(while_for_for_acc_2_nl))),
      (~ (readslicef_33_1_32(while_for_for_acc_nl))), fsm_output[7]);
  assign nl_while_for_for_in_rem_31_7_sva_3 = while_for_for_in_rem_31_7_sva + 25'b1111111111111111111111011;
  assign while_for_for_in_rem_31_7_sva_3 = nl_while_for_for_in_rem_31_7_sva_3[24:0];
  assign while_for_for_in_len_mux_nl = MUX_v_25_2_2(while_for_for_in_rem_31_7_sva,
      25'b0000000000000000000000101, while_for_for_in_len_slc_32_svs);
  assign nl_while_for_for_for_acc_4_nl = ({22'b1000000000000000000000 , while_for_for_for_i_10_1_sva
      , 1'b0}) + conv_u2u_32_33({(~ while_for_for_in_len_mux_nl) , (~ while_for_for_in_len_qr_6_0_lpi_3_dfm)})
      + 33'b000000000000000000000000000000001;
  assign while_for_for_for_acc_4_nl = nl_while_for_for_for_acc_4_nl[32:0];
  assign while_for_for_for_acc_4_itm_32_1 = readslicef_33_1_32(while_for_for_for_acc_4_nl);
  assign nl_while_for_for_in_len_acc_nl = conv_s2u_32_33({(~ while_for_for_in_rem_31_7_sva)
      , (~ while_for_in_length_sva_6_0)}) + 33'b000000000000000000000001010000001;
  assign while_for_for_in_len_acc_nl = nl_while_for_for_in_len_acc_nl[32:0];
  assign while_for_for_in_len_acc_itm_32_1 = readslicef_33_1_32(while_for_for_in_len_acc_nl);
  assign while_for_for_for_stage_v_3_mx2 = while_for_for_for_stage_v_3 & or_dcpl_41;
  assign while_for_for_for_stage_v_4_mx1 = while_for_for_for_stage_v_4 & or_dcpl_65;
  assign while_for_for_for_stage_v_5_mx2 = while_for_for_for_stage_v_5 & nand_25_cse;
  assign nl_while_for_for_vec_indx_31_1_sva_2 = while_for_for_vec_indx_31_1_sva +
      31'b0000000000000000000000000000001;
  assign while_for_for_vec_indx_31_1_sva_2 = nl_while_for_for_vec_indx_31_1_sva_2[30:0];
  assign while_for_for_for_while_for_for_for_or_cse = while_for_for_for_while_for_for_for_mul_cmp_bawt
      | exit_while_for_for_for_sva_st_2;
  assign not_tmp_23 = ~((~ while_for_for_for_stage_v_4) | while_for_for_for_while_for_for_for_mul_cmp_bawt
      | exit_while_for_for_for_sva_st_2);
  assign or_tmp_102 = (~ while_for_for_for_stage_v_5) | in_wr_req_Push_mioi_bawt
      | exit_while_for_for_for_sva_st_2 | (~ while_for_for_for_while_for_for_for_if_nor_svs_st_2);
  assign and_dcpl_23 = while_for_for_for_while_for_for_for_if_nor_svs_st_2 & (~ exit_while_for_for_for_sva_st_2);
  assign nand_25_cse = ~((~(and_dcpl_23 & (~ in_wr_req_Push_mioi_bawt))) & while_for_for_for_stage_v_5);
  assign and_dcpl_49 = (in_wr_req_Push_mioi_bawt | (~ while_for_for_for_while_for_for_for_if_nor_svs_st_2)
      | exit_while_for_for_for_sva_st_2) & while_for_for_for_stage_v_5;
  assign and_dcpl_50 = and_dcpl_49 & (~(while_for_for_for_stage_0_2 | while_for_for_for_stage_0
      | while_for_for_for_stage_0_1));
  assign and_dcpl_51 = (~ while_for_for_for_stage_v_1) & while_for_for_for_stage_0_1;
  assign and_tmp_46 = while_for_for_for_stage_0_3 & while_for_for_for_while_for_for_for_or_cse;
  assign and_tmp_47 = while_for_for_for_stage_v_4 & (while_for_for_for_stage_v_5
      | (~ and_tmp_46));
  assign or_368_nl = while_for_for_for_stage_v_3 | (~ while_for_for_for_stage_0_2)
      | and_tmp_47;
  assign mux_tmp_237 = MUX_s_1_2_2(not_tmp_23, or_368_nl, while_for_for_for_stage_v_2);
  assign or_152_nl = (~ while_for_for_for_stage_0_2) | while_for_for_for_stage_v_4
      | (~ or_tmp_102);
  assign mux_tmp_238 = MUX_s_1_2_2((~ or_tmp_102), or_152_nl, while_for_for_for_stage_v_3);
  assign and_dcpl_64 = (~ exit_while_for_for_for_sva_st_2) & while_for_for_for_while_for_for_for_mul_cmp_bawt
      & while_for_for_for_stage_0_3;
  assign and_dcpl_70 = ~((fsm_output[4]) | (fsm_output[6]));
  assign and_dcpl_74 = (~ while_for_for_for_stage_v_5) & while_for_for_for_stage_v_4;
  assign or_dcpl_39 = while_for_for_for_stage_v_4 | (~ while_for_for_for_stage_0_2);
  assign or_dcpl_41 = (~ or_tmp_102) | or_dcpl_39 | (~ while_for_for_for_stage_v_3);
  assign or_226_nl = while_for_for_for_stage_v_3 | (while_for_for_for_stage_v_4 &
      (while_for_for_for_stage_v_5 | (~ while_for_for_for_while_for_for_for_or_cse)));
  assign mux_tmp_239 = MUX_s_1_2_2(not_tmp_23, or_226_nl, while_for_for_for_stage_v_2);
  assign or_dcpl_45 = (fsm_output[6:5]!=2'b00);
  assign or_dcpl_48 = (~ while_for_for_for_stage_v) | while_for_for_for_stage_v_1;
  assign or_dcpl_50 = mux_tmp_237 | or_dcpl_48 | (~ while_for_for_for_stage_0_1);
  assign or_dcpl_60 = mux_tmp_238 | (~(in_rd_rsp_Pop_mioi_bawt | exit_while_for_for_for_sva_st))
      | while_for_for_for_stage_v_2 | (~(while_for_for_for_stage_v_1 & while_for_for_for_stage_0_1));
  assign or_dcpl_63 = and_tmp_47 | (~ while_for_for_for_stage_0_2) | while_for_for_for_stage_v_3
      | (~ while_for_for_for_stage_v_2);
  assign or_dcpl_65 = (~ and_tmp_46) | while_for_for_for_stage_v_5 | (~ while_for_for_for_stage_v_4);
  assign or_tmp_192 = (~ mux_tmp_238) & (~ while_for_for_for_stage_v_2) & in_rd_rsp_Pop_mioi_bawt
      & (~ exit_while_for_for_for_sva_st) & and_414_cse & (fsm_output[6]);
  assign and_170_cse = ~((fsm_output[6:5]!=2'b00));
  assign or_tmp_195 = and_dcpl_23 & in_wr_req_Push_mioi_bawt & while_for_for_for_stage_v_5
      & (fsm_output[6]);
  assign and_187_cse = and_dcpl_70 & (~ (fsm_output[5]));
  assign and_189_cse = ~((fsm_output[8]) | (fsm_output[1]) | (fsm_output[0]));
  assign and_241_cse = or_dcpl_50 & (fsm_output[5]);
  assign or_tmp_244 = and_dcpl_70 | (or_dcpl_60 & (fsm_output[6]));
  assign and_284_cse = (~ and_tmp_47) & while_for_for_for_stage_0_2 & (~ while_for_for_for_stage_v_3)
      & while_for_for_for_stage_v_2 & (fsm_output[5]);
  assign and_304_cse = and_tmp_46 & and_dcpl_74 & (fsm_output[5]);
  assign while_for_for_for_stage_0_mx0c1 = and_187_cse | ((~ mux_tmp_237) & while_for_for_for_stage_v
      & (~ while_for_for_for_acc_4_itm_32_1) & and_dcpl_51 & (fsm_output[5]));
  assign while_for_for_for_stage_v_1_mx0c1 = (~ mux_tmp_237) & while_for_for_for_stage_v
      & (~ while_for_for_for_stage_v_1) & while_for_for_for_stage_0_1 & (fsm_output[5]);
  assign while_for_for_for_stage_v_2_mx0c0 = and_284_cse | (fsm_output[4]);
  assign while_for_for_for_stage_v_4_mx0c0 = and_304_cse | (fsm_output[4]);
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      in_rd_rsp_Pop_mioi_iswt0 <= 1'b0;
    end
    else if ( compute_wen & (((~ mux_tmp_237) & while_for_for_for_stage_v & while_for_for_for_acc_4_itm_32_1
        & and_dcpl_51 & (fsm_output[5])) | or_tmp_192) ) begin
      in_rd_rsp_Pop_mioi_iswt0 <= ~ or_tmp_192;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      in_wr_req_Push_mioi_iswt0 <= 1'b0;
    end
    else if ( compute_wen & ((and_dcpl_64 & while_for_for_for_while_for_for_for_if_nor_svs_st_2
        & (~ while_for_for_for_stage_v_5) & while_for_for_for_stage_v_4 & (fsm_output[5]))
        | or_tmp_195) ) begin
      in_wr_req_Push_mioi_iswt0 <= ~ or_tmp_195;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      compute_flen <= 1'b0;
      reg_sync00_Pop_mioi_oswt_cse <= 1'b0;
      reg_in_rd_rsp_Pop_mioi_oswt_cse <= 1'b0;
    end
    else if ( compute_wen ) begin
      compute_flen <= and_385_rmff;
      reg_sync00_Pop_mioi_oswt_cse <= ~(and_189_cse | (~(exit_while_for_sva_mx0 |
          (fsm_output[0]))));
      reg_in_rd_rsp_Pop_mioi_oswt_cse <= or_tmp_192;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen ) begin
      while_for_in_length_mul_cmp_a <= conf_info_in_Pop_mio_mrgout_dat_sva_mx0_95_32[31:0];
      while_for_in_length_mul_cmp_b <= conf_info_in_Pop_mio_mrgout_dat_sva_mx0_95_32[63:32];
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (fsm_output[5]) & (~ exit_while_for_for_for_sva_st_2) & while_for_for_for_while_for_for_for_mul_cmp_bawt
        & while_for_for_for_stage_0_3 & while_for_for_for_while_for_for_for_if_nor_svs_st_2
        & (~ while_for_for_for_stage_v_5) & while_for_for_for_stage_v_4 ) begin
      in_wr_req_Push_mioi_idat <= while_for_for_acc_fx_sva_1_mx0w0;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_while_for_for_for_if_nor_svs_st_2 <= 1'b0;
      exit_while_for_for_for_sva_st_2 <= 1'b0;
    end
    else if ( while_for_for_for_if_and_2_cse ) begin
      while_for_for_for_while_for_for_for_if_nor_svs_st_2 <= while_for_for_for_while_for_for_for_if_nor_svs_st_1;
      exit_while_for_for_for_sva_st_2 <= exit_while_for_for_for_sva_st_1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_en_2 <= 1'b0;
      while_for_for_for_stage_en_4 <= 1'b0;
      while_for_for_for_stage_en_6 <= 1'b0;
    end
    else if ( while_for_for_for_and_12_cse ) begin
      while_for_for_for_stage_en_2 <= while_for_for_for_stage_en_2_mx1w0;
      while_for_for_for_stage_en_4 <= while_for_for_for_stage_en_4_mx1w0;
      while_for_for_for_stage_en_6 <= while_for_for_for_stage_en_6_mx1w0;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_while_for_for_for_if_nor_svs_st <= 1'b0;
    end
    else if ( compute_wen & (~(mux_tmp_239 | (~(while_for_for_for_stage_v & while_for_for_for_acc_4_itm_32_1))
        | while_for_for_for_stage_v_1 | (~ while_for_for_for_stage_0_1) | (~((fsm_output[0])
        | (fsm_output[5]))))) ) begin
      while_for_for_for_while_for_for_for_if_nor_svs_st <= while_for_for_for_while_for_for_for_if_nor_svs_st_1_1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      conf_info_in_Pop_mio_mrgout_dat_sva <= 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( compute_wen & ((fsm_output[1:0]!=2'b00)) ) begin
      conf_info_in_Pop_mio_mrgout_dat_sva <= conf_info_in_Pop_mioi_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (~ and_189_cse) ) begin
      while_for_b_sva <= MUX_v_16_2_2(16'b0000000000000000, while_for_b_sva_2, (fsm_output[8]));
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (fsm_output[6:4]==3'b000) ) begin
      while_for_for_in_rem_31_7_sva <= MUX_v_25_2_2((while_for_in_length_mul_cmp_z_oreg[31:7]),
          while_for_for_in_rem_31_7_sva_3, fsm_output[7]);
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (~((fsm_output[7]) | (fsm_output[4]) | or_dcpl_45)) ) begin
      while_for_in_length_sva_6_0 <= while_for_in_length_mul_cmp_z_oreg[6:0];
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      exit_while_for_for_for_sva_st <= 1'b0;
    end
    else if ( compute_wen & (~(and_241_cse | (fsm_output[6]))) ) begin
      exit_while_for_for_for_sva_st <= ~ while_for_for_for_acc_4_itm_32_1;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & ((~(mux_tmp_239 | or_dcpl_48 | (fsm_output[6]))) | and_170_cse)
        ) begin
      while_for_for_for_i_10_1_sva <= MUX_v_10_2_2(10'b0000000000, while_for_for_for_acc_3_nl,
          while_for_for_for_i_not_1_nl);
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
      while_for_for_for_stage_v <= 1'b0;
    end
    else if ( compute_wen & (while_for_for_for_mux_39_nl | and_170_cse) ) begin
      while_for_for_for_stage_v <= (fsm_output[6]) | and_170_cse;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_0 <= 1'b0;
    end
    else if ( compute_wen & ((fsm_output[4]) | while_for_for_for_stage_0_mx0c1) )
        begin
      while_for_for_for_stage_0 <= ~ while_for_for_for_stage_0_mx0c1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_asn_3_itm <= 1'b0;
      while_for_for_for_while_for_for_for_if_nor_svs <= 1'b0;
    end
    else if ( while_for_for_for_and_18_cse ) begin
      while_for_for_for_asn_3_itm <= ~ while_for_for_for_acc_4_itm_32_1;
      while_for_for_for_while_for_for_for_if_nor_svs <= while_for_for_for_while_for_for_for_if_nor_svs_st_1_1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_v_1 <= 1'b0;
    end
    else if ( compute_wen & ((~(or_dcpl_60 | and_187_cse | and_241_cse)) | (fsm_output[4])
        | while_for_for_for_stage_v_1_mx0c1) ) begin
      while_for_for_for_stage_v_1 <= while_for_for_for_stage_v_1_mx0c1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_v_2 <= 1'b0;
    end
    else if ( compute_wen & ((~(or_dcpl_60 | and_187_cse | (or_dcpl_63 & (fsm_output[5]))))
        | while_for_for_for_stage_v_2_mx0c0) ) begin
      while_for_for_for_stage_v_2 <= ~ while_for_for_for_stage_v_2_mx0c0;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_v_3 <= 1'b0;
    end
    else if ( compute_wen & ((fsm_output[4]) | and_284_cse | (fsm_output[6])) ) begin
      while_for_for_for_stage_v_3 <= (while_for_for_for_stage_v_3_mx2 & (~ (fsm_output[4])))
          | and_284_cse;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_v_4 <= 1'b0;
    end
    else if ( compute_wen & ((~(or_dcpl_41 | and_187_cse | (or_dcpl_65 & (fsm_output[5]))))
        | while_for_for_for_stage_v_4_mx0c0) ) begin
      while_for_for_for_stage_v_4 <= ~ while_for_for_for_stage_v_4_mx0c0;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_asn_3_itm_2 <= 1'b0;
      while_for_for_for_while_for_for_for_if_nor_svs_2 <= 1'b0;
    end
    else if ( while_for_for_for_and_23_cse ) begin
      while_for_for_for_asn_3_itm_2 <= while_for_for_for_asn_3_itm_1;
      while_for_for_for_while_for_for_for_if_nor_svs_2 <= while_for_for_for_while_for_for_for_if_nor_svs_1;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_v_5 <= 1'b0;
    end
    else if ( compute_wen & ((fsm_output[4]) | and_304_cse | (fsm_output[6])) ) begin
      while_for_for_for_stage_v_5 <= (while_for_for_for_stage_v_5_mx2 & (~ (fsm_output[4])))
          | and_304_cse;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (and_170_cse | (while_for_for_for_stage_v_5 & (~ while_for_for_for_asn_3_itm_2)
        & (fsm_output[6]))) ) begin
      while_for_for_acc_fx_sva <= while_for_for_acc_fx_sva_1 & (signext_32_1(~ while_for_for_for_while_for_for_for_if_nor_svs_2))
          & (signext_32_1(~ and_170_cse));
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_0_1 <= 1'b0;
    end
    else if ( compute_wen & ((~(or_dcpl_60 | and_dcpl_70)) | (fsm_output[4])) ) begin
      while_for_for_for_stage_0_1 <= while_for_for_for_stage_0 | (fsm_output[4]);
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_0_2 <= 1'b0;
    end
    else if ( compute_wen & ((~(mux_242_nl | and_dcpl_70)) | (fsm_output[4])) ) begin
      while_for_for_for_stage_0_2 <= while_for_for_for_stage_0_1 & (~ (fsm_output[4]));
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_stage_0_3 <= 1'b0;
    end
    else if ( compute_wen & ((mux_243_nl & (~ (fsm_output[5]))) | and_170_cse) )
        begin
      while_for_for_for_stage_0_3 <= while_for_for_for_stage_0_2 & (~ and_170_cse);
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & (~(while_for_for_for_stage_v_5 | (fsm_output[6]))) ) begin
      while_for_for_acc_fx_sva_1 <= while_for_for_acc_fx_sva_1_mx0w0;
    end
  end
  always @(posedge clk or negedge rst) begin
    if ( ~ rst ) begin
      while_for_for_for_asn_3_itm_1 <= 1'b0;
      exit_while_for_for_for_sva_st_1 <= 1'b0;
      while_for_for_for_while_for_for_for_if_nor_svs_st_1 <= 1'b0;
      while_for_for_for_while_for_for_for_if_nor_svs_1 <= 1'b0;
    end
    else if ( while_for_for_for_and_28_cse ) begin
      while_for_for_for_asn_3_itm_1 <= while_for_for_for_asn_3_itm;
      exit_while_for_for_for_sva_st_1 <= exit_while_for_for_for_sva_st;
      while_for_for_for_while_for_for_for_if_nor_svs_st_1 <= while_for_for_for_while_for_for_for_if_nor_svs_st;
      while_for_for_for_while_for_for_for_if_nor_svs_1 <= while_for_for_for_while_for_for_for_if_nor_svs;
    end
  end
  always @(posedge clk) begin
    if ( compute_wen & ((~(while_for_for_for_asn_3_itm | (~ while_for_for_for_stage_v_1)
        | (fsm_output[5]))) | and_170_cse) ) begin
      while_for_for_vec_indx_31_1_sva <= while_for_for_vec_indx_31_1_sva_1 & (signext_31_1(~
          while_for_for_for_while_for_for_for_if_nor_svs)) & (signext_31_1(~ and_170_cse));
    end
  end
  always @(posedge clk) begin
    if ( while_for_for_for_and_18_cse ) begin
      while_for_for_vec_indx_31_1_sva_1 <= while_for_for_vec_indx_31_1_sva_2;
    end
  end
  assign nl_while_for_for_for_acc_3_nl = while_for_for_for_i_10_1_sva + 10'b0000000001;
  assign while_for_for_for_acc_3_nl = nl_while_for_for_for_acc_3_nl[9:0];
  assign while_for_for_for_i_not_1_nl = ~ and_170_cse;
  assign while_for_for_in_len_not_4_nl = ~ while_for_for_in_len_acc_itm_32_1;
  assign nand_21_nl = ~(while_for_for_for_stage_0 & (~((~ while_for_for_for_while_for_for_for_or_5_cse)
      | while_for_for_for_stage_v_2 | (~ or_tmp_102))));
  assign mux_240_nl = MUX_s_1_2_2((~ or_tmp_102), nand_21_nl, while_for_for_for_stage_v_1);
  assign sync00_read_reset_check_reset_while_for_for_for_nor_nl = ~(mux_240_nl |
      (or_dcpl_39 & while_for_for_for_stage_v_3) | while_for_for_for_stage_v | (~
      while_for_for_for_stage_0_1));
  assign while_for_for_for_mux_39_nl = MUX_s_1_2_2((~ or_dcpl_50), sync00_read_reset_check_reset_while_for_for_for_nor_nl,
      fsm_output[6]);
  assign or_259_nl = (~ while_for_for_for_while_for_for_for_or_5_cse) | while_for_for_for_stage_v_2;
  assign mux_241_nl = MUX_s_1_2_2(mux_tmp_238, or_dcpl_41, or_259_nl);
  assign mux_242_nl = MUX_s_1_2_2(or_dcpl_41, mux_241_nl, and_414_cse);
  assign or_260_nl = (~ while_for_for_for_stage_v_3) | (~ while_for_for_for_stage_0_2)
      | while_for_for_for_stage_v_4;
  assign mux_243_nl = MUX_s_1_2_2(or_tmp_102, and_dcpl_49, or_260_nl);

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


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [30:0] signext_31_1;
    input  vector;
  begin
    signext_31_1= {{30{vector}}, vector};
  end
  endfunction


  function automatic [31:0] signext_32_1;
    input  vector;
  begin
    signext_32_1= {{31{vector}}, vector};
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


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    DataPath
// ------------------------------------------------------------------


module DataPath (
  clk, rst, conf_info_in_val, conf_info_in_rdy, conf_info_in_msg, sync00_val, sync00_rdy,
      sync00_msg, in_wr_req_val, in_wr_req_rdy, in_wr_req_msg, in_rd_rsp_val, in_rd_rsp_rdy,
      in_rd_rsp_msg
);
  input clk;
  input rst;
  input conf_info_in_val;
  output conf_info_in_rdy;
  input [95:0] conf_info_in_msg;
  input sync00_val;
  output sync00_rdy;
  input sync00_msg;
  output in_wr_req_val;
  input in_wr_req_rdy;
  output [31:0] in_wr_req_msg;
  input in_rd_rsp_val;
  output in_rd_rsp_rdy;
  input [63:0] in_rd_rsp_msg;


  // Interconnect Declarations
  wire [31:0] while_for_in_length_mul_cmp_a;
  wire [31:0] while_for_in_length_mul_cmp_b;


  // Interconnect Declarations for Component Instantiations 
  wire [63:0] nl_DataPath_compute_inst_while_for_in_length_mul_cmp_z;
  assign nl_DataPath_compute_inst_while_for_in_length_mul_cmp_z = while_for_in_length_mul_cmp_a
      * while_for_in_length_mul_cmp_b;
  esp_acc_DUMMY_DataPath_compute DataPath_compute_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_in_val(conf_info_in_val),
      .conf_info_in_rdy(conf_info_in_rdy),
      .conf_info_in_msg(conf_info_in_msg),
      .sync00_val(sync00_val),
      .sync00_rdy(sync00_rdy),
      .sync00_msg(sync00_msg),
      .in_wr_req_val(in_wr_req_val),
      .in_wr_req_rdy(in_wr_req_rdy),
      .in_wr_req_msg(in_wr_req_msg),
      .in_rd_rsp_val(in_rd_rsp_val),
      .in_rd_rsp_rdy(in_rd_rsp_rdy),
      .in_rd_rsp_msg(in_rd_rsp_msg),
      .while_for_in_length_mul_cmp_a(while_for_in_length_mul_cmp_a),
      .while_for_in_length_mul_cmp_b(while_for_in_length_mul_cmp_b),
      .while_for_in_length_mul_cmp_z(nl_DataPath_compute_inst_while_for_in_length_mul_cmp_z[31:0])
    );
endmodule



