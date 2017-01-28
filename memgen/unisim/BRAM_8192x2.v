// Copyright (c) 2014-2015, Columbia University
module BRAM_8192x2( CLK, A0, D0, Q0, WE0, WEM0, CE0, A1, D1, Q1, WE1, WEM1, CE1 );
	input CLK;
	input [12:0] A0;
	input [1:0] D0;
	output [1:0] Q0;
	input WE0;
	input [1:0] WEM0;
	input CE0;
	input [12:0] A1;
	input [1:0] D1;
	output [1:0] Q1;
	input WE1;
	input [1:0] WEM1;
	input CE1;

	RAMB16_S2_S2 bram (
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
