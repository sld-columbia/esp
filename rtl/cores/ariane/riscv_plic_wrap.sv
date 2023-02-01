// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

module riscv_plic_wrap
  # (
     parameter NHARTS = 1,
     parameter NIRQ_SRCS = 30
     )
   (
    input logic 		clk,
    input logic 		rstn,
    input logic [NIRQ_SRCS-1:0] irq_sources,
    output logic [NHARTS*2-1:0] irq,
    input logic 		plic_penable,
    input logic 		plic_pwrite,
    input logic [31:0] 		plic_paddr,
    input logic 		plic_psel,
    input logic [31:0] 		plic_pwdata,
    output logic [31:0] 	plic_prdata,
    output logic 		plic_pready,
    output logic 		plic_pslverr
    );

   localparam int unsigned 	MaxPriority = 7;

   logic [NHARTS-1:0][1:0] 	irq_x;
   genvar 			i;
   generate
      for (i = 0; i < NHARTS; i++) begin : remap_eip_targets
	 assign irq[2 * (i + 1) - 1 : 2 * i] = irq_x[i];
      end
   endgenerate

   REG_BUS #(
             .ADDR_WIDTH ( 32 ),
             .DATA_WIDTH ( 32 )
	     ) reg_bus (clk);

   apb_to_reg i_apb_to_reg
     (
      .clk_i     ( clk          ),
      .rst_ni    ( rstn         ),
      .penable_i ( plic_penable ),
      .pwrite_i  ( plic_pwrite  ),
      .paddr_i   ( plic_paddr   ),
      .psel_i    ( plic_psel    ),
      .pwdata_i  ( plic_pwdata  ),
      .prdata_o  ( plic_prdata  ),
      .pready_o  ( plic_pready  ),
      .pslverr_o ( plic_pslverr ),
      .reg_o     ( reg_bus      )
      );

   reg_intf::reg_intf_resp_d32 plic_resp;
   reg_intf::reg_intf_req_a32_d32 plic_req;

   assign plic_req.addr  = reg_bus.addr;
   assign plic_req.write = reg_bus.write;
   assign plic_req.wdata = reg_bus.wdata;
   assign plic_req.wstrb = reg_bus.wstrb;
   assign plic_req.valid = reg_bus.valid;

   assign reg_bus.rdata = plic_resp.rdata;
   assign reg_bus.error = plic_resp.error;
   assign reg_bus.ready = plic_resp.ready;

   plic_top
     #(
       .N_SOURCE    ( NIRQ_SRCS   ),
       .N_TARGET    ( 2*NHARTS    ),
       .MAX_PRIO    ( MaxPriority )
       ) i_plic
       (
	.clk_i         ( clk         ),
	.rst_ni        ( rstn        ),
	.req_i         ( plic_req    ),
	.resp_o        ( plic_resp   ),
	.le_i          ( '0          ), // 0:level 1:edge
	.irq_sources_i ( irq_sources ),
	.eip_targets_o ( irq_x       )
	);

endmodule // riscv_plic_wrap
