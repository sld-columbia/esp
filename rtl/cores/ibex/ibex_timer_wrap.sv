// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

module ibex_timer_wrap
  (
   input logic 	       rstn,
   input logic 	       clk,
   input logic 	       penable,
   input logic 	       psel,
   input logic 	       pwrite,
   input logic [31:0]  paddr,
   input logic [31:0]  pwdata,
   output logic [31:0] prdata,
   output logic        pready,
   output logic        pslverr,
   output logic        timer_irq
   );

   // Adapt from APB
   logic       req;
   assign req = penable & psel;

   // Only 32-bit words read or write allowed (may require adapting the device driver)
   logic [3:0] be;
   assign be = 4'b1111;

  timer #(
    .DataWidth    (32),
    .AddressWidth (32)
    ) u_timer (
      .clk_i          (clk),
      .rst_ni         (rstn),

      .timer_req_i    (req),
      .timer_we_i     (pwrite),
      .timer_be_i     (be),
      .timer_addr_i   (paddr),
      .timer_wdata_i  (pwdata),
      .timer_rvalid_o (pready),
      .timer_rdata_o  (prdata),
      .timer_err_o    (pslverr),
      .timer_intr_o   (timer_irq)
    );


endmodule
