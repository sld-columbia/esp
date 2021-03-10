// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0 

`timescale 1 ps / 1 ps

module pr_decoupler (
  input  rst,
  input  clk,
  input  decouple_acc,
  output coherence_req_wrreq,
  output coherence_fwd_rdreq,
  output coherent_dma_snd_wrreq,
  output coherence_rsp_rcv_rdreq,
  output coherence_rsp_snd_wrreq,
  output dma_rcv_rdreq,
  output dma_snd_wrreq ,
  output interrupt_wrreq, 
  output interrupt_data_in,
  output interrupt_full,
  output interrupt_ack_rdreq,
  output interrupt_ack_empty,
  output pready  
);

  reg coherence_req_wrreq_reg;
  reg coherence_fwd_rdreq_reg;
  reg coherent_dma_snd_wrreq_reg;
  reg coherence_rsp_rcv_rdreq_reg; 
  reg coherence_rsp_snd_wrreq_reg;
  reg dma_rcv_rdreq_reg;
  reg dma_snd_wrreq_reg; 
  reg interrupt_wrreq_reg;
  reg interrupt_full_reg;
  reg interrupt_data_in_reg;
  reg interrupt_ack_rdreq_reg;
  reg interrupt_ack_empty_reg;
  reg pready_reg;

    always @(posedge clk) begin
        if (decouple_acc) begin
            coherence_req_wrreq_reg     <= 0;
            coherence_fwd_rdreq_reg     <= 0;
            coherent_dma_snd_wrreq_reg  <= 0;
            coherence_rsp_rcv_rdreq_reg <= 0; 
            coherence_rsp_snd_wrreq_reg <= 0;
            dma_rcv_rdreq_reg           <= 0;
            dma_snd_wrreq_reg           <= 0; 
            interrupt_wrreq_reg         <= 0;
            interrupt_full_reg          <= 0;
            interrupt_data_in_reg       <= 0;
            interrupt_ack_rdreq_reg     <= 0;
            interrupt_ack_empty_reg     <= 0;
            pready_reg                  <= 0;
        end
    end

    assign coherence_req_wrreq      = coherence_req_wrreq_reg;
    assign coherence_fwd_rdreq      = coherence_fwd_rdreq_reg;
    assign coherent_dma_snd_wrreq   = coherent_dma_snd_wrreq_reg;
    assign coherence_rsp_rcv_rdreq  = coherence_rsp_rcv_rdreq_reg;
    assign coherence_rsp_snd_wrreq  = coherence_rsp_snd_wrreq_reg;
    assign dma_rcv_rdreq            = dma_rcv_rdreq_reg;
    assign dma_snd_wrreq            = dma_snd_wrreq_reg;
    assign interrupt_wrreq          = interrupt_wrreq_reg;
    assign interrupt_full           = interrupt_full_reg;
    assign interrupt_data_in        = interrupt_data_in_reg;
    assign interrupt_ack_rdreq      = interrupt_ack_rdreq_reg;
    assign interrupt_ack_empty      = interrupt_ack_empty_reg;
    assign pready                   = pready_reg;

endmodule
