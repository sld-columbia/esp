// Copyright (c) 2014-2015, Columbia University
module BRAM_16384x1( CLK, A0, D0, Q0, WE0, WEM0, CE0, A1, D1, Q1, WE1, WEM1, CE1 );
	input CLK;
	input [13:0] A0;
	input D0;
	output Q0;
	input WE0;
	input WEM0;
	input CE0;
	input [13:0] A1;
	input D1;
	output Q1;
	input WE1;
	input WEM1;
	input CE1;

	RAMB16_S1_S1 bram (
		.DOA(Q0),
		.DOB(Q1),
		.ADDRA(A0),
		.ADDRB(A1),
		.CLKA(CLK),
		.CLKB(CLK),
		.DIA(D0),
		.DIB(D1),
		.ENA(CE0),
		.ENB(CE1),
		.SSRA(1'b0),
		.SSRB(1'b0),
		.WEA(WE0),
		.WEB(WE1));
endmodule
