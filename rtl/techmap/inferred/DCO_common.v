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


module BUF_CHAIN10(Y, A);
output Y;
wire Y;
input A;
wire A;
wire [8:0] int1;
BUF buf1(.Y(int1[0]), .A(A));
BUF buf2(.Y(int1[1]), .A(int1[0]));
BUF buf3(.Y(int1[2]), .A(int1[1]));
BUF buf4(.Y(int1[3]), .A(int1[2]));
BUF buf5(.Y(int1[4]), .A(int1[3]));
BUF buf6(.Y(int1[5]), .A(int1[4]));
BUF buf7(.Y(int1[6]), .A(int1[5]));
BUF buf8(.Y(int1[7]), .A(int1[6]));
BUF buf9(.Y(int1[8]), .A(int1[7]));
BUF buf10(.Y(Y), .A(int1[8]));
endmodule

module CLK_BUF_CHAIN(Y, A);
output Y;
wire Y;
input A;
wire A;
wire [3:0] int1;
BUF_X1N_STDCELL buf1(.Y(int1[0]), .A(A));
BUF_X4N_STDCELL buf2(.Y(int1[1]), .A(int1[0]));
BUF_X8N_STDCELL buf3(.Y(int1[2]), .A(int1[1]));
BUF_X16N_STDCELL buf4(.Y(int1[3]), .A(int1[2]));
BUF_X32N_STDCELL buf5(.Y(Y), .A(int1[3]));
endmodule

module INV(Y, A);
output Y;
wire Y;
input A;
wire A;
INV_X1N_STDCELL inv1(.Y(Y), .A(A));
endmodule

module BUF(Y, A);
output Y;
wire Y;
input A;
wire A;
wire tmp;
INV_X1N_STDCELL buf1(.Y(tmp), .A(A));
INV_X2N_STDCELL buf2(.Y(Y), .A(tmp));
endmodule

module BUF16(Y, A);
output Y;
wire Y;
input A;
wire A;
//CLK_BUF_X4_CELL buf1(.Z(Y), .I(A));
BUF_X16N_STDCELL buf1(.Y(Y), .A(A));
endmodule

module MUX(Y, SEL, A, B);
output Y;
wire Y;
input A, B, SEL;
wire A, B, SEL;
//CLK_MUX_CELL mux2(.Z(Y), .S(SEL), .I0(A), .I1(B));
MX2_X6N_STDCELL mux2(.Y(Y), .S0(SEL), .A(A), .B(B));
endmodule

//Programmable delay step: incrementing SEL by one adds in 1 BUF delay
module DELAY_STEP(Y, A);
output Y;
wire Y;
input A;
wire A;
wire tmp;
BUF buf1(.Y(tmp), .A(A));
BUF buf2(.Y(Y), .A(tmp));
endmodule


//Variable capacitance between muxed delay stages
//to fine-tune the DCO_RING period on the fly
//implemented using NAND2 gate input cap
//EN signal connected to the footer nmos gate (B), controling Cin(A).
//when the footer is on, Cin(A) is high; when the footer is off, Cin(B) is low.
module VARIABLE_CAP(EN, A);
input EN, A;
wire EN, A;
NAND2_X4N_STDCELL nand2_cell (.B(EN), .A(A), .Y());
NAND2_X4N_STDCELL nand2_cel2 (.B(EN), .A(A), .Y());
endmodule

//SEL has 7 control bits
//Programmable delay step: incrementing SEL by one adds in 1 BUF delay
//FixedBufDly = 0 stages of BUF delay
module DCO_RING(EN, DCLK, SEL, FC_SEL);
input EN;
wire EN;
input [5:0] SEL;
wire [5:0] SEL;
input [5:0] FC_SEL;
wire [5:0] FC_SEL;
output DCLK;
wire DCLK;
wire [6:0] A;
wire [6:0] A_tmp;
wire [5:0] B;
wire [1:1] int1;
wire [3:1] int2;
wire [7:1] int3;
wire [15:1] int4;
wire [31:1] int5;

//Added variable cap control signals to fine-tune the load caps (NAND2 Cin(A))
VARIABLE_CAP XVARIABLE_CAP0_1 (.EN(FC_SEL[0]), .A(A[0]));

VARIABLE_CAP XVARIABLE_CAP1_1 (.EN(FC_SEL[1]), .A(A[0]));
VARIABLE_CAP XVARIABLE_CAP1_2 (.EN(FC_SEL[1]), .A(A[0]));

VARIABLE_CAP XVARIABLE_CAP2_1 (.EN(FC_SEL[2]), .A(A[1]));
VARIABLE_CAP XVARIABLE_CAP2_2 (.EN(FC_SEL[2]), .A(A[1]));
VARIABLE_CAP XVARIABLE_CAP2_3 (.EN(FC_SEL[2]), .A(A[1]));

VARIABLE_CAP XVARIABLE_CAP3_1 (.EN(FC_SEL[3]), .A(A[2]));
VARIABLE_CAP XVARIABLE_CAP3_2 (.EN(FC_SEL[3]), .A(A[2]));
VARIABLE_CAP XVARIABLE_CAP3_3 (.EN(FC_SEL[3]), .A(A[2]));
VARIABLE_CAP XVARIABLE_CAP3_4 (.EN(FC_SEL[3]), .A(A[2]));

VARIABLE_CAP XVARIABLE_CAP4_1 (.EN(FC_SEL[4]), .A(A[3]));
VARIABLE_CAP XVARIABLE_CAP4_2 (.EN(FC_SEL[4]), .A(A[3]));
VARIABLE_CAP XVARIABLE_CAP4_3 (.EN(FC_SEL[4]), .A(A[3]));
VARIABLE_CAP XVARIABLE_CAP4_4 (.EN(FC_SEL[4]), .A(A[3]));
VARIABLE_CAP XVARIABLE_CAP4_5 (.EN(FC_SEL[4]), .A(A[4]));

VARIABLE_CAP XVARIABLE_CAP5_1 (.EN(FC_SEL[5]), .A(A[4]));
VARIABLE_CAP XVARIABLE_CAP5_2 (.EN(FC_SEL[5]), .A(A[4]));
VARIABLE_CAP XVARIABLE_CAP5_3 (.EN(FC_SEL[5]), .A(A[4]));
VARIABLE_CAP XVARIABLE_CAP5_4 (.EN(FC_SEL[5]), .A(A[5]));
VARIABLE_CAP XVARIABLE_CAP5_5 (.EN(FC_SEL[5]), .A(A[5]));
VARIABLE_CAP XVARIABLE_CAP5_6 (.EN(FC_SEL[5]), .A(A[5]));

//instantiate an array of 6 varaible_cap, loaded on each mux output node
//each node has #6.

//CLK_NAND_CELL nanden(.ZN(A[0]), .A1(DCLK), .A2(EN));
NAND2_X2N_STDCELL nanden(.Y(A_tmp[0]), .A(A[6]), .B(EN));
BUF buf_a0(.Y(A[0]), .A(A_tmp[0]));
BUF buffers(.Y(DCLK), .A(A[6]));
MUX mux0(.Y(A_tmp[1]), .SEL(SEL[0]), .A(A[0]), .B(B[0]));
BUF buf_a1(.Y(A[1]), .A(A_tmp[1]));
DELAY_STEP buf0_0(.Y(B[0]), .A(A[0]));
MUX mux1(.Y(A_tmp[2]), .SEL(SEL[1]), .A(A[1]), .B(B[1]));
BUF buf_a2(.Y(A[2]), .A(A_tmp[2]));
DELAY_STEP buf1_0(.Y(int1[1]), .A(A[1]));
DELAY_STEP buf1_1(.Y(B[1]), .A(int1[1]));
MUX mux2(.Y(A_tmp[3]), .SEL(SEL[2]), .A(A[2]), .B(B[2]));
BUF buf_a3(.Y(A[3]), .A(A_tmp[3]));
DELAY_STEP buf2_0(.Y(int2[1]), .A(A[2]));
DELAY_STEP buf2_1(.Y(int2[2]), .A(int2[1]));
DELAY_STEP buf2_2(.Y(int2[3]), .A(int2[2]));
DELAY_STEP buf2_3(.Y(B[2]), .A(int2[3]));
MUX mux3(.Y(A_tmp[4]), .SEL(SEL[3]), .A(A[3]), .B(B[3]));
BUF buf_a4(.Y(A[4]), .A(A_tmp[4]));
DELAY_STEP buf3_0(.Y(int3[1]), .A(A[3]));
DELAY_STEP buf3_1(.Y(int3[2]), .A(int3[1]));
DELAY_STEP buf3_2(.Y(int3[3]), .A(int3[2]));
DELAY_STEP buf3_3(.Y(int3[4]), .A(int3[3]));
DELAY_STEP buf3_4(.Y(int3[5]), .A(int3[4]));
DELAY_STEP buf3_5(.Y(int3[6]), .A(int3[5]));
DELAY_STEP buf3_6(.Y(int3[7]), .A(int3[6]));
DELAY_STEP buf3_7(.Y(B[3]), .A(int3[7]));
MUX mux4(.Y(A_tmp[5]), .SEL(SEL[4]), .A(A[4]), .B(B[4]));
BUF buf_a5(.Y(A[5]), .A(A_tmp[5]));
DELAY_STEP buf4_0(.Y(int4[1]), .A(A[4]));
DELAY_STEP buf4_1(.Y(int4[2]), .A(int4[1]));
DELAY_STEP buf4_2(.Y(int4[3]), .A(int4[2]));
DELAY_STEP buf4_3(.Y(int4[4]), .A(int4[3]));
DELAY_STEP buf4_4(.Y(int4[5]), .A(int4[4]));
DELAY_STEP buf4_5(.Y(int4[6]), .A(int4[5]));
DELAY_STEP buf4_6(.Y(int4[7]), .A(int4[6]));
DELAY_STEP buf4_7(.Y(int4[8]), .A(int4[7]));
DELAY_STEP buf4_8(.Y(int4[9]), .A(int4[8]));
DELAY_STEP buf4_9(.Y(int4[10]), .A(int4[9]));
DELAY_STEP buf4_10(.Y(int4[11]), .A(int4[10]));
DELAY_STEP buf4_11(.Y(int4[12]), .A(int4[11]));
DELAY_STEP buf4_12(.Y(int4[13]), .A(int4[12]));
DELAY_STEP buf4_13(.Y(int4[14]), .A(int4[13]));
DELAY_STEP buf4_14(.Y(int4[15]), .A(int4[14]));
DELAY_STEP buf4_15(.Y(B[4]), .A(int4[15]));
MUX mux5(.Y(A_tmp[6]), .SEL(SEL[5]), .A(A[5]), .B(B[5]));
BUF buf_a6(.Y(A[6]), .A(A_tmp[6]));
DELAY_STEP buf5_0(.Y(int5[1]), .A(A[5]));
DELAY_STEP buf5_1(.Y(int5[2]), .A(int5[1]));
DELAY_STEP buf5_2(.Y(int5[3]), .A(int5[2]));
DELAY_STEP buf5_3(.Y(int5[4]), .A(int5[3]));
DELAY_STEP buf5_4(.Y(int5[5]), .A(int5[4]));
DELAY_STEP buf5_5(.Y(int5[6]), .A(int5[5]));
DELAY_STEP buf5_6(.Y(int5[7]), .A(int5[6]));
DELAY_STEP buf5_7(.Y(int5[8]), .A(int5[7]));
DELAY_STEP buf5_8(.Y(int5[9]), .A(int5[8]));
DELAY_STEP buf5_9(.Y(int5[10]), .A(int5[9]));
DELAY_STEP buf5_10(.Y(int5[11]), .A(int5[10]));
DELAY_STEP buf5_11(.Y(int5[12]), .A(int5[11]));
DELAY_STEP buf5_12(.Y(int5[13]), .A(int5[12]));
DELAY_STEP buf5_13(.Y(int5[14]), .A(int5[13]));
DELAY_STEP buf5_14(.Y(int5[15]), .A(int5[14]));
DELAY_STEP buf5_15(.Y(int5[16]), .A(int5[15]));
DELAY_STEP buf5_16(.Y(int5[17]), .A(int5[16]));
DELAY_STEP buf5_17(.Y(int5[18]), .A(int5[17]));
DELAY_STEP buf5_18(.Y(int5[19]), .A(int5[18]));
DELAY_STEP buf5_19(.Y(int5[20]), .A(int5[19]));
DELAY_STEP buf5_20(.Y(int5[21]), .A(int5[20]));
DELAY_STEP buf5_21(.Y(int5[22]), .A(int5[21]));
DELAY_STEP buf5_22(.Y(int5[23]), .A(int5[22]));
DELAY_STEP buf5_23(.Y(int5[24]), .A(int5[23]));
DELAY_STEP buf5_24(.Y(int5[25]), .A(int5[24]));
DELAY_STEP buf5_25(.Y(int5[26]), .A(int5[25]));
DELAY_STEP buf5_26(.Y(int5[27]), .A(int5[26]));
DELAY_STEP buf5_27(.Y(int5[28]), .A(int5[27]));
DELAY_STEP buf5_28(.Y(int5[29]), .A(int5[28]));
DELAY_STEP buf5_29(.Y(int5[30]), .A(int5[29]));
DELAY_STEP buf5_30(.Y(int5[31]), .A(int5[30]));
DELAY_STEP buf5_31(.Y(B[5]), .A(int5[31]));

endmodule


module CLK_DIVIDER(CLK_IN, CLK_OUT, FRSTN);
input CLK_IN;
wire CLK_IN;
output CLK_OUT;
wire CLK_OUT;
input FRSTN;
wire FRSTN;
wire CLK_DIV_D;
wire CLK_DIV_QN;
//DFF Truth table
//  SETN    CLK    D    |    QN
//   0       x     x    |    0 
//   1      _/-    0    |    1
//   1      _/-    1    |    0
//   1       0     x    |    QN
//   1       1     x    |    QN
//
//DFF_CELL DFFSQN(.CLK(CLK_IN), .D(CLK_DIV_D), .QN(CLK_DIV_QN), .SETN(FRSTN));
DFFSQN_X2N_STDCELL DFFSQN(.CK(CLK_IN), .D(CLK_DIV_D), .QN(CLK_DIV_QN), .SN(FRSTN));

BUF_CHAIN10 buf_loop(.Y(CLK_DIV_D), .A(CLK_DIV_QN));
BUF bufdiv(.Y(CLK_OUT), .A(CLK_DIV_QN));
endmodule

module MX_CLK_DIVIDER(CLK_IN, CLK_OUT, SEL, FRSTN);
input CLK_IN;
wire CLK_IN;
output CLK_OUT;
wire CLK_OUT;
input [2:0] SEL;
wire [2:0] SEL;
input FRSTN;
wire FRSTN;
wire [0:7] X0;
wire CLK_DIV;
BUF buf0(.Y(X0[0]), .A(CLK_IN));
CLK_DIVIDER DIV0 (.CLK_IN(X0[0]), .CLK_OUT(X0[1]), .FRSTN(FRSTN));
CLK_DIVIDER DIV1 (.CLK_IN(X0[1]), .CLK_OUT(X0[2]), .FRSTN(FRSTN));
CLK_DIVIDER DIV2 (.CLK_IN(X0[2]), .CLK_OUT(X0[3]), .FRSTN(FRSTN));
CLK_DIVIDER DIV3 (.CLK_IN(X0[3]), .CLK_OUT(X0[4]), .FRSTN(FRSTN));
CLK_DIVIDER DIV4 (.CLK_IN(X0[4]), .CLK_OUT(X0[5]), .FRSTN(FRSTN));
CLK_DIVIDER DIV5 (.CLK_IN(X0[5]), .CLK_OUT(X0[6]), .FRSTN(FRSTN));
CLK_DIVIDER DIV6 (.CLK_IN(X0[6]), .CLK_OUT(X0[7]), .FRSTN(FRSTN));
wire [3:0] X1;
wire [1:0] X2;
MUX mux10(.A(X0[0]), .B(X0[1]), .SEL(SEL[0]), .Y(X1[0]));
MUX mux11(.A(X0[2]), .B(X0[3]), .SEL(SEL[0]), .Y(X1[1]));
MUX mux12(.A(X0[4]), .B(X0[5]), .SEL(SEL[0]), .Y(X1[2]));
MUX mux13(.A(X0[6]), .B(X0[7]), .SEL(SEL[0]), .Y(X1[3]));
MUX mux20(.A(X1[0]), .B(X1[1]), .SEL(SEL[1]), .Y(X2[0]));
MUX mux21(.A(X1[2]), .B(X1[3]), .SEL(SEL[1]), .Y(X2[1]));
MUX mux30(.A(X2[0]), .B(X2[1]), .SEL(SEL[2]), .Y(CLK_DIV));
BUF bufmx(.Y(CLK_OUT), .A(CLK_DIV));
endmodule

module MX_CLK_DIVIDER_SMALL(CLK_IN, CLK_OUT, SEL, FRSTN); //SEL: 00:CLK_IN, 01:/2, 11:/4
input CLK_IN;
wire CLK_IN;
output CLK_OUT;
wire CLK_OUT;
input [1:0] SEL;
wire [1:0] SEL;
input FRSTN;
wire FRSTN;
wire [0:3] X0;
wire CLK_DIV;
BUF buf0(.Y(X0[0]), .A(CLK_IN));
CLK_DIVIDER DIV0 (.CLK_IN(X0[0]), .CLK_OUT(X0[1]), .FRSTN(FRSTN));
CLK_DIVIDER DIV1 (.CLK_IN(X0[1]), .CLK_OUT(X0[2]), .FRSTN(FRSTN));
MUX mux0(.A(X0[0]), .B(X0[3]), .SEL(SEL[0]), .Y(CLK_DIV));
MUX mux1(.A(X0[1]), .B(X0[2]), .SEL(SEL[1]), .Y(X0[3]));
BUF bufmx(.Y(CLK_OUT), .A(CLK_DIV));
endmodule
