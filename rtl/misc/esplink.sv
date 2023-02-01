// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

module esplink
  #(
    parameter APB_DW = 32,
    parameter APB_AW = 32,
    parameter REV_ENDIAN = 0
    )
   (
    input logic 		clk,
    input logic 		rstn,
    output logic 		srst,
    // APB
    input logic 		psel,
    input logic 		penable,
    input logic 		pwrite,
    input logic [APB_AW - 1:0] 	paddr,
    input logic [APB_DW - 1:0] 	pwdata,
    output logic 		pready,
    output logic 		pslverr,
    output logic [APB_DW - 1:0] prdata
    );

   // Command register
   localparam C_REG_ID          = 0;
   localparam C_SRST_BIT        = 0;
   localparam C_REG_MASK        = 32'h1;

   // Status register
   localparam S_REG_ID          = 1;
   localparam S_SRST_BIT        = 0; // soft-reset pending

   // Number of registers
   localparam NREG = S_REG_ID + 1;

   // Byte offset
   localparam APB_BYTE_OFFSET_BITS      = $clog2(APB_DW / 8);
   localparam OFFSET_MAX                = (NREG - 1) << APB_BYTE_OFFSET_BITS;
   localparam APB_ADDR_MSB              = $clog2(NREG) + APB_BYTE_OFFSET_BITS - 1;
   localparam APB_ADDR_LSB              = APB_BYTE_OFFSET_BITS;

   // Internal wires and registers
   logic [APB_DW - 1 : 0] 	       bankreg[NREG - 1 : 0];
   logic [APB_ADDR_MSB : APB_ADDR_LSB] selected;
   logic                               do_access;
   logic                               access_error;
   logic                               do_write;

   // Fix endian
   logic [APB_DW - 1:0] 	       pwdata_rev;
   logic [APB_DW - 1:0] 	       prdata_rev;

   // Timer
   logic 			       timer_en;
   logic [11:0]  		       timestamp;

   genvar 			       i;

   //
   // Decode APB command
   //
   assign selected      = paddr[APB_ADDR_MSB : APB_ADDR_LSB];
   assign do_access     = psel & penable;
   assign access_error  = 0;
   assign do_write      = do_access & ~access_error & pwrite;
   assign do_cmd        = do_write == 1'b1 && selected == C_REG_ID ? 1'b1 : 1'b0;

   generate
      for (i = 0; i < APB_DW / 8; i ++) begin : fix_endian
	 assign pwdata_rev[(i + 1) * 8 - 1 : i * 8] = REV_ENDIAN == 0 ? pwdata[(i + 1) * 8 - 1 : i * 8] : pwdata[APB_DW - i * 8 - 1 : APB_DW - (i + 1) * 8];
	 assign prdata[(i + 1) * 8 - 1 : i * 8] = REV_ENDIAN == 0 ? prdata_rev[(i + 1) * 8 - 1 : i * 8] : prdata_rev[APB_DW - i * 8 - 1 : APB_DW - (i + 1) * 8];
      end
   endgenerate

   //
   // APB Read
   //
   assign pslverr = access_error;
   assign prdata_rev = bankreg[selected];
   assign pready = 1'b1;


   //
   // Command register
   //
   assign bankreg[C_REG_ID] = do_cmd == 1'b1 ? pwdata_rev & C_REG_MASK : '0;

   //
   // Status register
   //

   always_ff @(posedge clk) begin : update_s_reg
      if (rstn == 1'b0) begin
	 bankreg[S_REG_ID] <= '0;
      end
      else begin
	 // soft reset pending
	 bankreg[S_REG_ID][S_SRST_BIT] <= timer_en;
      end
   end

   //
   // Timer
   //

   assign srst = timer_en;


   always_ff @(posedge clk) begin
      if (rstn == 1'b0) begin
	 timer_en <= 1'b0;
	 timestamp <= '0;
      end
      else begin
	 if (bankreg[C_REG_ID][C_SRST_BIT] == 1'b1)
	   timer_en <= 1'b1;

	 if (timer_en == 1'b1) begin
	    timestamp <= timestamp + 1;
	    if (timestamp == 12'hFFF)
	      timer_en <= 1'b0;
	 end
      end
   end


endmodule
