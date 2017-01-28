// Copyright (c) 2014-2015, Columbia University
module BRAM_2048x8( CLK, A0, D0, Q0, WE0, WEM0, CE0, A1, D1, Q1, WE1, WEM1, CE1 );
	input CLK;
	input [10:0] A0;
	input [7:0] D0;
	output [7:0] Q0;
	input WE0;
	input [7:0] WEM0;
	input CE0;
	input [10:0] A1;
	input [7:0] D1;
	output [7:0] Q1;
	input WE1;
	input [7:0] WEM1;
	input CE1;

  wire DOPA_float;
  wire DOPB_float;

	RAMB16_S9_S9 bram (
		.DOA(Q0),
		.DOB(Q1),
		.DOPA(DOPA_float),
		.DOPB(DOPB_float),
		.ADDRA(A0),
		.ADDRB(A1),
		.CLKA(CLK),
		.CLKB(CLK),
		.DIA(D0),
		.DIB(D1),
		.DIPA(1'b0),
		.DIPB(1'b0),
		.ENA(CE0),
		.ENB(CE1),
		.SSRA(1'b0),
		.SSRB(1'b0),
		.WEA(WE0),
		.WEB(WE1));
endmodule
