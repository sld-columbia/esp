//`default_nettype none

// Copyright (c) 2020 Harvard University
// SPDX-License-Identifier: Apache-2.0
// Author: Tianyu Jia

// SET DONT_TOUCH ON ALL CELLS IN THIS MODULE

/*
// synopsys dc_script_begin
// set_dont_touch find("cell","*")
// synopsys dc_script_end
*/


module DCO(EN,CC_SEL,FC_SEL,EXT_CLK,CLK_SEL,DIV_SEL,FREQ_SEL,CLK,CLK_DIV,RSTN);
input RSTN;
wire RSTN;
input EN;
wire EN;
input EXT_CLK, CLK_SEL;
wire EXT_CLK, CLK_SEL;
input [5:0] CC_SEL;
wire [5:0] CC_SEL;
input [2:0] DIV_SEL;
wire [2:0] DIV_SEL;
input [1:0] FREQ_SEL;
wire [1:0] FREQ_SEL;
output CLK;
wire CLK;
output CLK_DIV;
wire CLK_DIV;
//fine-tune inter-mux cap load
// TODO only using 6:1, keeping it as 6:0 for compatibility (LSB floating)
input [5:0] FC_SEL;
wire [5:0] FC_SEL;

wire EN_I, RSTN_I;
wire [5:0] CC_SEL_I, FC_SEL_I;
wire [2:0] DIV_SEL_I;
wire [1:0] FREQ_SEL_I;
wire RING_OUT, DIV_CLK_OUT;
wire EXT_CLK_I, CLK_SEL_I;
wire CLK_SELECT;
wire CLK_I;

BUF bufen(.Y(EN_I), .A(EN));
BUF bufrstn(.Y(RSTN_I), .A(RSTN));
BUF bufdcosel_0(.Y(CC_SEL_I[0]), .A(CC_SEL[0]));
BUF bufdcosel_1(.Y(CC_SEL_I[1]), .A(CC_SEL[1]));
BUF bufdcosel_2(.Y(CC_SEL_I[2]), .A(CC_SEL[2]));
BUF bufdcosel_3(.Y(CC_SEL_I[3]), .A(CC_SEL[3]));
BUF bufdcosel_4(.Y(CC_SEL_I[4]), .A(CC_SEL[4]));
BUF bufdcosel_5(.Y(CC_SEL_I[5]), .A(CC_SEL[5]));
BUF bufdfine_0(.Y(FC_SEL_I[0]), .A(FC_SEL[0]));
BUF bufdfine_1(.Y(FC_SEL_I[1]), .A(FC_SEL[1]));
BUF bufdfine_2(.Y(FC_SEL_I[2]), .A(FC_SEL[2]));
BUF bufdfine_3(.Y(FC_SEL_I[3]), .A(FC_SEL[3]));
BUF bufdfine_4(.Y(FC_SEL_I[4]), .A(FC_SEL[4]));
BUF bufdfine_5(.Y(FC_SEL_I[5]), .A(FC_SEL[5]));
BUF bufdivsel_0(.Y(DIV_SEL_I[0]), .A(DIV_SEL[0]));
BUF bufdivsel_1(.Y(DIV_SEL_I[1]), .A(DIV_SEL[1]));
BUF bufdivsel_2(.Y(DIV_SEL_I[2]), .A(DIV_SEL[2]));
BUF bufextclk(.Y(EXT_CLK_I), .A(EXT_CLK));
BUF bufclksel(.Y(CLK_SEL_I), .A(CLK_SEL));
BUF buffreqsel_0(.Y(FREQ_SEL_I[0]), .A(FREQ_SEL[0]));
BUF buffreqsel_1(.Y(FREQ_SEL_I[1]), .A(FREQ_SEL[1]));

// DCO
DCO_RING DCO_CORE(.EN(EN_I), .SEL(CC_SEL_I), .DCLK(RING_OUT), .FC_SEL(FC_SEL_I));

MUX mux_clk(.A(RING_OUT), .B(EXT_CLK_I), .SEL(CLK_SEL_I), .Y(CLK_SELECT));

// Clock Divider, for testing purpose
MX_CLK_DIVIDER DIVIDER_TEST(.CLK_IN(CLK_SELECT), .CLK_OUT(DIV_CLK_OUT), .SEL(DIV_SEL_I), .FRSTN(RSTN_I));

MX_CLK_DIVIDER_SMALL DIVIDER_CLK(.CLK_IN(CLK_SELECT), .CLK_OUT(CLK_I), .SEL(FREQ_SEL_I), .FRSTN(RSTN_I));

CLK_BUF_CHAIN bufdclk(.Y(CLK), .A(CLK_I));
CLK_BUF_CHAIN bufdivclk(.Y(CLK_DIV), .A(DIV_CLK_OUT));

endmodule

//`default_nettype wire
