// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

import top_pkg::*;
import tlul_pkg::*;
import prim_mubi_pkg::*;

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

   logic [NHARTS-1:0][1:0]     irq_x;
   genvar 			i;
   generate
      for (i = 0; i < NHARTS; i++) begin : remap_eip_targets
        assign irq[2 * (i + 1) - 1 : 2 * i] = irq_x[i];
      end
   endgenerate

  tlul_pkg::tl_h2d_t tl_i;
  tlul_pkg::tl_d2h_t tl_o;

  assign tl_i.a_valid = plic_penable & plic_psel;
  assign tl_i.a_opcode = plic_pwrite ? tlul_pkg::PutFullData : tlul_pkg::Get;
  assign tl_i.a_param = 3'b0;
  assign tl_i.a_size = 2'b10;
  assign tl_i.a_source = {top_pkg::TL_AIW{1'b0}};
  assign tl_i.a_address = {6'b0, plic_paddr[25:0]};
  assign tl_i.a_mask = {top_pkg::TL_DBW{1'b1}};
  assign tl_i.a_data = plic_pwdata;
  assign tl_i.a_user.rsvd = '0;
  assign tl_i.a_user.instr_type = prim_mubi_pkg::MuBi4False;
  assign tl_i.a_user.cmd_intg = tlul_pkg::get_cmd_intg(tl_i);
  assign tl_i.a_user.data_intg = tlul_pkg::get_data_intg(plic_pwdata);
  assign tl_i.d_ready = 1'b1;

  assign plic_pready = tl_o.d_valid | tl_o.a_ready;
  assign plic_prdata = tl_o.d_data;
  assign plic_plsverr = tl_o.d_error;

  rv_plic i_plic
    (
	.clk_i           (clk),
	.rst_ni          (rstn),
	.tl_i            (tl_i),
	.tl_o            (tl_o),
	.intr_src_i      (irq_sources),
	.alert_rx_i      ('0),
	.alert_tx_o      (),
    .irq_o           (irq_x),
    .irq_id_o        (),
    .msip_o          ()
	);

endmodule // riscv_plic_wrap
