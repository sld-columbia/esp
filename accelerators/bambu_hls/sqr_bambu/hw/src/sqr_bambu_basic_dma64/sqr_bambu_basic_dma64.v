// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

// ESP wrapper around the 64-bit dataflow square DMA-master core `sqr_bambu_core`.
// The core is already a DMA master (emits {index,length} requests, request-precedes-data),
// so this wrapper is thin: it renames the core's AXIS request/data to the ESP socket,
// fills size=DWORD/user=0, starts on conf_done, and forwards the core's done_port as acc_done (measured
// blocking-to-the-wire: done never precedes the last AXIS write handshake; the
// ESP socket samples the pulse). The debug port counts accepted write beats.
module sqr_bambu_basic_dma64 (
    clk,
    rst,
    conf_info_len,
    conf_info_base_in,
    conf_info_base_out,
    conf_done,
    acc_done,
    debug,
    dma_read_ctrl_valid,
    dma_read_ctrl_data_index,
    dma_read_ctrl_data_length,
    dma_read_ctrl_data_size,
    dma_read_ctrl_data_user,
    dma_read_ctrl_ready,
    dma_read_chnl_valid,
    dma_read_chnl_data,
    dma_read_chnl_ready,
    dma_write_ctrl_valid,
    dma_write_ctrl_data_index,
    dma_write_ctrl_data_length,
    dma_write_ctrl_data_size,
    dma_write_ctrl_data_user,
    dma_write_ctrl_ready,
    dma_write_chnl_valid,
    dma_write_chnl_data,
    dma_write_chnl_ready
);

    input clk;
    input rst;  // active-low
    input [31:0] conf_info_len;       // positive multiple of 16 words
    input [31:0] conf_info_base_in;   // input offset in 64-bit DMA beats
    input [31:0] conf_info_base_out;  // output offset in 64-bit DMA beats
    input conf_done;
    input dma_read_ctrl_ready;
    output dma_read_ctrl_valid;
    output [31:0] dma_read_ctrl_data_index;
    output [31:0] dma_read_ctrl_data_length;
    output [2:0] dma_read_ctrl_data_size;
    output [5:0] dma_read_ctrl_data_user;
    output dma_read_chnl_ready;
    input dma_read_chnl_valid;
    input [63:0] dma_read_chnl_data;
    input dma_write_ctrl_ready;
    output dma_write_ctrl_valid;
    output [31:0] dma_write_ctrl_data_index;
    output [31:0] dma_write_ctrl_data_length;
    output [2:0] dma_write_ctrl_data_size;
    output [5:0] dma_write_ctrl_data_user;
    input dma_write_chnl_ready;
    output dma_write_chnl_valid;
    output [63:0] dma_write_chnl_data;
    output acc_done;
    output [31:0] debug;

    localparam [2:0] DMA_SIZE = 3'd3;  // SIZE_DWORD (8-byte beats)

    wire [63:0] rc_tdata, wc_tdata;
    wire c_done;

    sqr_bambu_core u_core (
        .clock(clk),
        .reset(rst),
        .start_port(conf_done),
        .done_port(c_done),
        /* <<--core-conf-map-->> */
        .len(conf_info_len),
        .base_in(conf_info_base_in),
        .base_out(conf_info_base_out),
        .dma_read_ctrl_TDATA(rc_tdata),
        .dma_read_ctrl_TVALID(dma_read_ctrl_valid),
        .dma_read_ctrl_TREADY(dma_read_ctrl_ready),
        .dma_read_chnl_TDATA(dma_read_chnl_data),
        .dma_read_chnl_TVALID(dma_read_chnl_valid),
        .dma_read_chnl_TREADY(dma_read_chnl_ready),
        .dma_write_ctrl_TDATA(wc_tdata),
        .dma_write_ctrl_TVALID(dma_write_ctrl_valid),
        .dma_write_ctrl_TREADY(dma_write_ctrl_ready),
        .dma_write_chnl_TDATA(dma_write_chnl_data),
        .dma_write_chnl_TVALID(dma_write_chnl_valid),
        .dma_write_chnl_TREADY(dma_write_chnl_ready)
    );

    assign dma_read_ctrl_data_index   = rc_tdata[31:0];
    assign dma_read_ctrl_data_length  = rc_tdata[63:32];
    assign dma_read_ctrl_data_size    = DMA_SIZE;
    assign dma_read_ctrl_data_user    = 6'd0;
    assign dma_write_ctrl_data_index  = wc_tdata[31:0];
    assign dma_write_ctrl_data_length = wc_tdata[63:32];
    assign dma_write_ctrl_data_size   = DMA_SIZE;
    assign dma_write_ctrl_data_user   = 6'd0;

    // acc_done: bambu's done_port is blocking-to-the-wire (measured -- it never
    // precedes the last AXIS write handshake), so it is forwarded directly; the
    // ESP socket samples acc_done, so the single-cycle pulse is sufficient.
    assign acc_done                   = c_done;

    // debug: accepted write beats this invocation (observability only)
    wire        wbeat = dma_write_chnl_valid & dma_write_chnl_ready;
    reg  [31:0] wcnt;
    always @(posedge clk) begin
        if (rst == 1'b0) wcnt <= 32'd0;
        else if (conf_done) wcnt <= 32'd0;
        else if (wbeat) wcnt <= wcnt + 1'b1;
    end
    assign debug = wcnt;

endmodule
