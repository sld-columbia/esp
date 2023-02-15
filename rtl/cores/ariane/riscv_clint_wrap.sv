// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0


module riscv_clint_wrap
  #(
    parameter AXI_ADDR_WIDTH = 64,
    parameter AXI_DATA_WIDTH = 64,
    parameter AXI_ID_WIDTH_SLV = 10,
    parameter AXI_USER_WIDTH = 1,
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8,
    parameter NR_CORES = 1
    )
   (
    input logic 			clk,
    input logic 			rstn,
    // Timer interrupt
    output logic [NR_CORES-1:0] 	timer_irq,
    // Software interrupt
    output logic [NR_CORES-1:0] 	ipi,
    // AW
    input logic [AXI_ID_WIDTH_SLV-1:0] 	aw_id,
    input logic [AXI_ADDR_WIDTH-1:0] 	aw_addr,
    input logic [7:0] 			aw_len,
    input logic [2:0] 			aw_size,
    input logic [1:0] 			aw_burst,
    input logic 			aw_lock,
    input logic [3:0] 			aw_cache,
    input logic [2:0] 			aw_prot,
    input logic [3:0] 			aw_qos,
    input logic [5:0] 			aw_atop,
    input logic [3:0] 			aw_region,
    input logic [AXI_USER_WIDTH-1:0] 	aw_user,
    input logic 			aw_valid,
    output logic 			aw_ready,
    // W
    input logic [AXI_DATA_WIDTH-1:0] 	w_data,
    input logic [AXI_STRB_WIDTH-1:0] 	w_strb,
    input logic 			w_last,
    input logic [AXI_USER_WIDTH-1:0] 	w_user,
    input logic 			w_valid,
    output logic 			w_ready,
    // B
    output logic [AXI_ID_WIDTH_SLV-1:0] b_id,
    output logic [1:0] 			b_resp,
    output logic [AXI_USER_WIDTH-1:0] 	b_user,
    output logic 			b_valid,
    input logic 			b_ready,
    // AR
    input logic [AXI_ID_WIDTH_SLV-1:0] 	ar_id,
    input logic [AXI_ADDR_WIDTH-1:0] 	ar_addr,
    input logic [7:0] 			ar_len,
    input logic [2:0] 			ar_size,
    input logic [1:0] 			ar_burst,
    input logic 			ar_lock,
    input logic [3:0] 			ar_cache,
    input logic [2:0] 			ar_prot,
    input logic [3:0] 			ar_qos,
    input logic [3:0] 			ar_region,
    input logic [AXI_USER_WIDTH-1:0] 	ar_user,
    input logic 			ar_valid,
    output logic 			ar_ready,
    // R
    output logic [AXI_ID_WIDTH_SLV-1:0] r_id,
    output logic [AXI_DATA_WIDTH-1:0] 	r_data,
    output logic [1:0] 			r_resp,
    output logic 			r_last,
    output logic [AXI_USER_WIDTH-1:0] 	r_user,
    output logic 			r_valid,
    input logic 			r_ready
    );

   logic 				rtc;

   ariane_axi::req_t    		axi_req_i;
   ariane_axi::resp_t   		axi_resp_o;

   // AW
   assign axi_req_i.aw.id = aw_id;
   assign axi_req_i.aw.addr = aw_addr;
   assign axi_req_i.aw.len = aw_len;
   assign axi_req_i.aw.size = aw_size;
   assign axi_req_i.aw.burst = aw_burst;
   assign axi_req_i.aw.lock = aw_lock;
   assign axi_req_i.aw.cache = aw_cache;
   assign axi_req_i.aw.prot = aw_prot;
   assign axi_req_i.aw.qos = aw_qos;
   assign axi_req_i.aw.atop = aw_atop;
   assign axi_req_i.aw.region = aw_region;
   assign axi_req_i.aw_valid = aw_valid;
   assign aw_ready = axi_resp_o.aw_ready;
   // W
   assign axi_req_i.w.data = w_data;
   assign axi_req_i.w.strb = w_strb;
   assign axi_req_i.w.last = w_last;
   assign axi_req_i.w_valid = w_valid;
   assign w_ready = axi_resp_o.w_ready;
   // B
   assign b_id = axi_resp_o.b.id;
   assign b_resp = axi_resp_o.b.resp;
   assign b_user = '0;
   assign b_valid = axi_resp_o.b_valid;
   assign axi_req_i.b_ready = b_ready;
   // AR
   assign axi_req_i.ar.id = ar_id;
   assign axi_req_i.ar.addr = ar_addr;
   assign axi_req_i.ar.len = ar_len;
   assign axi_req_i.ar.size = ar_size;
   assign axi_req_i.ar.burst = ar_burst;
   assign axi_req_i.ar.lock = ar_lock;
   assign axi_req_i.ar.cache = ar_cache;
   assign axi_req_i.ar.prot = ar_prot;
   assign axi_req_i.ar.qos = ar_qos;
   assign axi_req_i.ar.region = ar_region;
   assign axi_req_i.ar_valid = ar_valid;
   assign ar_ready = axi_resp_o.ar_ready;
   // R
   assign r_id = axi_resp_o.r.id;
   assign r_data = axi_resp_o.r.data;
   assign r_resp = axi_resp_o.r.resp;
   assign r_last = axi_resp_o.r.last;
   assign r_user = '0;
   assign r_valid = axi_resp_o.r_valid;
   assign axi_req_i.r_ready = r_ready;

   // divide clock by two to generate the tick for the timer

   always_ff @(posedge clk or negedge rstn) begin
      if (~rstn) begin
	 rtc <= 0;
      end else begin
	 rtc <= rtc ^ 1'b1;
      end
   end

   clint
     #(
       .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH   ),
       .AXI_DATA_WIDTH ( AXI_DATA_WIDTH   ),
       .AXI_ID_WIDTH   ( AXI_ID_WIDTH_SLV ),
       .NR_CORES       ( NR_CORES         )
       ) i_clint
       (
	.clk_i       ( clk            ),
	.rst_ni      ( rstn           ),
	.testmode_i  ( 1'b0           ),
	.axi_req_i   ( axi_req_i      ),
	.axi_resp_o  ( axi_resp_o     ),
	.rtc_i       ( rtc            ),
	.timer_irq_o ( timer_irq      ),
	.ipi_o       ( ipi            )
	);

endmodule // riscv_clint_wrap
