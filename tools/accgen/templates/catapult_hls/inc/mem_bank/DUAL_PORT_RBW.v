// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

module DUAL_PORT_RBW #(
  parameter AddressSz = 32 ,
  parameter data_width = 8 ,
  parameter Sz = 128
)( clk,clk_en,din,qout,r_adr,w_adr,w_en);

  input  clk;
  input  clk_en;
  input [data_width-1:0] din;
  output [data_width-1:0] qout;
  input [AddressSz-1:0] r_adr;
  input [AddressSz-1:0] w_adr;
  input  w_en;

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
