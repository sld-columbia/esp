`timescale 1 ps / 1 ps
// Copyright (c) 2014-2021, Columbia University
module SRAM_1024x16(CLK0, A0, D0, Q0, WE0, WEM0, CE0 );
	input CLK0;
	input [9:0] A0;
	input [15:0] D0;
	output [15:0] Q0;
	input WE0;
	input [15:0] WEM0;
	input CE0;

  sram_behav #(.DATA_WIDTH(16), .NUM_WORDS(1024)) sram(
    .clk_i(CLK0),
    .req_i(CE0),
    .we_i(WE0),
    .addr_i(A0),
    .wdata_i(D0),
    .be_i(WEM0),
    .rdata_o(Q0)
  );

endmodule
