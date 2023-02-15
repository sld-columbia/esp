// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
module apb2axil
  (
   clk,
   rstn,
   paddr,
   penable,
   psel,
   pwdata,
   pwrite,
   prdata,
   pready,
   pslverr,
   s_axil_awvalid,
   s_axil_awready,
   s_axil_awaddr,
   s_axil_wvalid,
   s_axil_wready,
   s_axil_wdata,
   s_axil_wstrb,
   s_axil_arvalid,
   s_axil_arready,
   s_axil_araddr,
   s_axil_rvalid,
   s_axil_rready,
   s_axil_rdata,
   s_axil_rresp,
   s_axil_bvalid,
   s_axil_bready,
   s_axil_bresp
   );

   input clk;
   input rstn;
   // APB
   input psel;
   input penable;
   input pwrite;
   input [31:0] paddr;
   input [31:0] pwdata;
   output reg [31:0] prdata;
   output reg 	     pready;
   output reg 	     pslverr;
   // AXI-L
   output reg 	     s_axil_awvalid;
   input 	     s_axil_awready;
   output [31:0]     s_axil_awaddr;
   output reg 	     s_axil_wvalid;
   input 	     s_axil_wready;
   output [31:0]     s_axil_wdata;
   output [3:0]      s_axil_wstrb;
   output reg 	     s_axil_arvalid;
   input 	     s_axil_arready;
   output [31:0]     s_axil_araddr;
   input 	     s_axil_rvalid;
   output reg 	     s_axil_rready;
   input [31:0]      s_axil_rdata;
   input [1:0] 	     s_axil_rresp;
   input wire 	     s_axil_bvalid;
   output reg 	     s_axil_bready;
   input wire [1:0]  s_axil_bresp;

   localparam apb2axil_idle              = 3'b000;
   localparam apb2axil_write             = 3'b001;
   localparam apb2axil_write_data        = 3'b010;
   localparam apb2axil_write_ack         = 3'b011;
   localparam apb2axil_read              = 3'b100;
   localparam apb2axil_read_data         = 3'b101;

   // APB2AXI-Lite
   reg [2:0] 	     apb2axil_state;
   reg [2:0] 	     apb2axil_next;

   assign s_axil_awaddr = paddr[31:0];
   assign s_axil_wdata = pwdata;
   assign s_axil_wstrb = 4'b1111;
   assign s_axil_araddr = paddr[31:0];

   always @ (*) begin
      pready = 1'b0;
      pslverr = 1'b0;
      prdata = '0;
      s_axil_awvalid = 1'b0;
      s_axil_wvalid = 1'b0;
      s_axil_arvalid = 1'b0;
      s_axil_rready = 1'b0;
      s_axil_bready = 1'b0;

      case (apb2axil_state)
	apb2axil_idle : begin
	   pready = 1'b0;
	   pslverr = 1'b0;
	   prdata = '0;
	   s_axil_awvalid = 1'b0;
	   s_axil_wvalid = 1'b0;
	   s_axil_arvalid = 1'b0;
	   s_axil_rready = 1'b0;
	   s_axil_bready = 1'b0;

	   if ((psel & penable) == 1'b1) begin
	      if (pwrite == 1'b1) begin
		 apb2axil_next = apb2axil_write;
	      end else begin
		 apb2axil_next = apb2axil_read;
	      end
	   end else begin
	      apb2axil_next = apb2axil_idle;
	   end
	end // case: idle

	apb2axil_write : begin
	   s_axil_awvalid = 1'b1;
	   pready = 1'b0;
	   pslverr = 1'b0;
	   prdata = '0;
	   s_axil_wvalid = 1'b1;
	   s_axil_arvalid = 1'b0;
	   s_axil_rready = 1'b0;
	   s_axil_bready = 1'b0;
	   if ((s_axil_awready & s_axil_wready) == 1'b1)
	     apb2axil_next = apb2axil_write_ack;
	   else if (s_axil_awready == 1'b1)
	     apb2axil_next = apb2axil_write_data;
	   else
	     apb2axil_next = apb2axil_write;
	end // case: write

	apb2axil_write_data : begin
	   s_axil_awvalid = 1'b0;
	   pready = 1'b0;
	   pslverr = 1'b0;
	   prdata = '0;
	   s_axil_wvalid = 1'b1;
	   s_axil_arvalid = 1'b0;
	   s_axil_rready = 1'b0;
	   s_axil_bready = 1'b0;
	   if (s_axil_wready == 1'b1)
	     apb2axil_next = apb2axil_write_ack;
	   else
	     apb2axil_next = apb2axil_write_data;
	end // case: write_data

	apb2axil_write_ack : begin
	   s_axil_awvalid = 1'b0;
	   pready = s_axil_bvalid;
	   pslverr = s_axil_bresp == '0 ? 1'b0 : s_axil_bvalid;
	   prdata = '0;
	   s_axil_wvalid = 1'b0;
	   s_axil_arvalid = 1'b0;
	   s_axil_rready = 1'b0;
	   s_axil_bready = 1'b1;
	   if (s_axil_bvalid == 1'b1)
	     apb2axil_next = apb2axil_idle;
	   else
	     apb2axil_next = apb2axil_write_ack;
	end // case: write_ack

	apb2axil_read : begin
	   pready = s_axil_arready & s_axil_rvalid;
	   pslverr = s_axil_rresp == '0 ? 1'b0 : s_axil_rvalid;
	   prdata = s_axil_rdata;
	   s_axil_awvalid = 1'b0;
	   s_axil_wvalid = 1'b0;
	   s_axil_arvalid = 1'b1;
	   s_axil_rready = 1'b1;
	   s_axil_bready = 1'b0;
	   if ((s_axil_arready & s_axil_rvalid) == 1'b1)
	     apb2axil_next = apb2axil_idle;
	   else if (s_axil_arready == 1'b1)
	     apb2axil_next = apb2axil_read_data;
	   else
	     apb2axil_next = apb2axil_read;
	end // case: read

	apb2axil_read_data : begin
	   pready = s_axil_rvalid;
	   pslverr = s_axil_rresp == '0 ? 1'b0 : s_axil_rvalid;
	   prdata = s_axil_rdata;
	   s_axil_awvalid = 1'b0;
	   s_axil_wvalid = 1'b0;
	   s_axil_arvalid = 1'b0;
	   s_axil_rready = 1'b1;
	   s_axil_bready = 1'b0;
	   if (s_axil_rvalid == 1'b1)
	     apb2axil_next = apb2axil_idle;
	   else
	     apb2axil_next = apb2axil_read_data;
	end // case: read_data

	default: begin
	   pready = 1'b0;
	   pslverr = 1'b0;
	   prdata = '0;
	   s_axil_awvalid = 1'b0;
	   s_axil_wvalid = 1'b0;
	   s_axil_arvalid = 1'b0;
	   s_axil_rready = 1'b0;
	   s_axil_bready = 1'b0;
	   apb2axil_next = apb2axil_idle;
	end

      endcase // case (apb2axil_state)
   end // always @ (*)

   // State update
   always @(posedge clk) begin
      if (rstn == 1'b0) begin
	 apb2axil_state <= apb2axil_idle;
      end else begin
	 apb2axil_state <= apb2axil_next;
      end
   end

endmodule // apb2axil
