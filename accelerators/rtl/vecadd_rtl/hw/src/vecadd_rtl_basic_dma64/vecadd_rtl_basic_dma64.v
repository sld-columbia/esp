// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// vecadd_rtl_basic_dma64
//
// Elementwise 32-bit integer vector addition:  C[i] = A[i] + B[i], i in [0,N),
// on a 64-bit-wide DMA channel. This is the DMA_NOC_WIDTH=64 sibling of
// vecadd_rtl_basic_dma32 that widens only the channel, not the element: each
// element is still a plain 32-bit int, matching vecadd_rtl_basic_dma32's
// register contract and token type exactly, but two elements are packed into
// every 64-bit beat whenever a full pair is available.

`timescale 1ps / 1ps

`define VECADD_SYNC_RESET

module vecadd_rtl_basic_dma64 #(
    // Chunk buffer depth in 64-bit PACKED WORDS, not elements. Must be a
    // power of two. 256 x 64 bits holds 512 elements, the same element
    // capacity as vecadd_rtl_basic_dma32's default PLM_DEPTH=512, so the
    // chunk_size register's clamp behaves identically across both cores.
    parameter PLM_DEPTH = 256
) (
    clk,
    rst,

    conf_info_vector_size,
    conf_info_chunk_size,
    conf_done,

    dma_read_ctrl_valid,
    dma_read_ctrl_ready,
    dma_read_ctrl_data_index,
    dma_read_ctrl_data_length,
    dma_read_ctrl_data_size,
    dma_read_ctrl_data_user,

    dma_read_chnl_valid,
    dma_read_chnl_ready,
    dma_read_chnl_data,

    dma_write_ctrl_valid,
    dma_write_ctrl_ready,
    dma_write_ctrl_data_index,
    dma_write_ctrl_data_length,
    dma_write_ctrl_data_size,
    dma_write_ctrl_data_user,

    dma_write_chnl_valid,
    dma_write_chnl_ready,
    dma_write_chnl_data,

    acc_done
);

    // -----------------------------------------------------------------------
    // Ports
    // -----------------------------------------------------------------------
    input         clk;
    input         rst;                    // active low (acc_rst)

    input  [31:0] conf_info_vector_size;  // N, number of 32-bit elements
    input  [31:0] conf_info_chunk_size;   // elements per DMA burst; 0 = max
    input         conf_done;              // one-cycle pulse

    input         dma_read_ctrl_ready;
    output        dma_read_ctrl_valid;
    output [31:0] dma_read_ctrl_data_index;
    output [31:0] dma_read_ctrl_data_length;
    output [ 2:0] dma_read_ctrl_data_size;
    output [ 5:0] dma_read_ctrl_data_user;

    input         dma_read_chnl_valid;
    input  [63:0] dma_read_chnl_data;
    output        dma_read_chnl_ready;

    input         dma_write_ctrl_ready;
    output        dma_write_ctrl_valid;
    output [31:0] dma_write_ctrl_data_index;
    output [31:0] dma_write_ctrl_data_length;
    output [ 2:0] dma_write_ctrl_data_size;
    output [ 5:0] dma_write_ctrl_data_user;

    input         dma_write_chnl_ready;
    output        dma_write_chnl_valid;
    output [63:0] dma_write_chnl_data;

    output        acc_done;

    // -----------------------------------------------------------------------
    // Local parameters
    // -----------------------------------------------------------------------
    function integer clogb2;
        input integer value;
        integer v;
        begin
            v = value - 1;
            clogb2 = 0;
            while (v > 0) begin
                v = v >> 1;
                clogb2 = clogb2 + 1;
            end
        end
    endfunction

    localparam PLM_AW = clogb2(PLM_DEPTH);
    localparam CNT_W  = PLM_AW + 1;                 // holds 0..PLM_DEPTH words

    localparam [31:0] PLM_DEPTH_ELEMS = PLM_DEPTH * 2;

    localparam [2:0] HSIZE_WORD  = 3'b010;          // amba.vhd:212
    localparam [2:0] HSIZE_DWORD = 3'b011;          // amba.vhd:213

    localparam [3:0] S_IDLE     = 4'd0,
                     S_START    = 4'd1,
                     S_RD_A_REQ = 4'd2,
                     S_RD_A_DAT = 4'd3,
                     S_RD_B_REQ = 4'd4,
                     S_RD_B_DAT = 4'd5,
                     S_WR_REQ   = 4'd6,
                     S_WR_DAT   = 4'd7,
                     S_NEXT     = 4'd8,
                     S_DONE     = 4'd9,
                     S_HOLD     = 4'd10;

    reg  [3:0]        state;
    reg               segment;

    reg  [31:0]       len_total;          // N, latched at conf_done
    reg  [31:0]       chunk_max;          // clamped, evened, per-chunk budget
    reg  [31:0]       offset;             // elements completed so far
    reg  [31:0]       chunk_len;          // elements in the current chunk
    reg  [31:0]       rd_index_r /* synthesis syn_preserve=1 */;
    reg  [31:0]       wr_index_r /* synthesis syn_preserve=1 */;

    reg  [CNT_W-1:0]  a_cnt;              // A words absorbed this phase
    reg  [CNT_W-1:0]  b_cnt;              // B words absorbed this phase
    reg  [CNT_W-1:0]  o_cnt;              // PLM reads issued in the write phase
    reg  [CNT_W-1:0]  w_cnt;              // C words accepted this phase

    // Accumulate pipeline, one packed 64-bit word (two 32-bit lanes) per beat.
    reg               b0_vld;
    reg  [PLM_AW-1:0] b0_idx;
    reg  [63:0]       b0_data;
    reg               b1_vld;
    reg  [PLM_AW-1:0] b1_idx;
    reg  [63:0]       b1_sum;

    // Write-side output staging: two-entry skid FIFO covering the one-cycle
    // PLM read latency, so the write channel can sustain a beat per cycle.
    reg               wr_issue_d;
    reg  [1:0]        inflight;           // reads issued but not yet popped
    reg  [1:0]        fifo_cnt;
    reg               fifo_wp;
    reg               fifo_rp;
    reg  [63:0]       fifo0;
    reg  [63:0]       fifo1;

    // -----------------------------------------------------------------------
    // PLM: one 64-bit packed word per pair of elements.
    // -----------------------------------------------------------------------
    wire              plm_wr_en;
    wire [PLM_AW-1:0] plm_wr_addr;
    wire [63:0]       plm_wr_data;
    wire              plm_rd_en;
    wire [PLM_AW-1:0] plm_rd_addr;
    wire [63:0]       plm_rd_data;

    vecadd_plm #(
        .WIDTH (64),
        .DEPTH (PLM_DEPTH),
        .AW    (PLM_AW)
    ) plm_i (
        .clk     (clk),
        .wr_en   (plm_wr_en),
        .wr_addr (plm_wr_addr),
        .wr_data (plm_wr_data),
        .rd_en   (plm_rd_en),
        .rd_addr (plm_rd_addr),
        .rd_data (plm_rd_data)
    );

    // -----------------------------------------------------------------------
    // Combinational helpers: chunking (element domain)
    // -----------------------------------------------------------------------
    wire [31:0] chunk_req    = conf_info_chunk_size;
    wire        chunk_req_ok = (chunk_req != 32'd0) && (chunk_req <= PLM_DEPTH_ELEMS);
    wire [31:0] chunk_req_even = (chunk_req[31:1] == 31'd0) ? 32'd2
                                                            : {chunk_req[31:1], 1'b0};

    wire [31:0] remaining    = len_total - offset;
    wire [31:0] next_chunk   = (remaining > chunk_max) ? chunk_max : remaining;

    wire [31:0] offset_next  = offset + chunk_len;

    // This chunk's bulk/tail split, element and word domain. Stable for the
    // whole chunk once chunk_len is latched in S_START.
    wire [31:0] bulk_beats = chunk_len[31:1];       // full pairs (DWORD beats)
    wire        tail_beat  = chunk_len[0];          // 0 or 1 (WORD beat)
    wire [31:0] word_len   = bulk_beats + {31'd0, tail_beat};

    // Starting segment for a phase about to begin, given ITS OWN chunk's
    // bulk/tail split: skip straight to the tail segment when there is no
    // bulk part at all (a one-element chunk), rather than issuing a
    // zero-length bulk request.
    wire        seg_start  = (bulk_beats == 32'd0);

    // Same split, but evaluated against the INCOMING next_chunk rather than
    // the registered chunk_len, for use only in S_START where chunk_len is
    // being set on this very edge and is not yet valid to read back.
    wire        seg_start_next = (next_chunk == 32'd1);

    // M = N rounded up to even, and the derived word-domain bases. M is
    // recomputed from len_total every run; nothing stores it as a register.
    wire [31:0] m_elems      = len_total + {31'd0, len_total[0]};
    wire [31:0] m_words      = m_elems[31:1];
    wire [31:0] offset_words = offset[31:1];        // exact: offset is always
                                                     // even at a chunk start

    wire [31:0] a_index_word = offset_words;
    wire [31:0] b_index_word = m_words + offset_words;
    wire [31:0] c_index_word = m_words + b_index_word;   // = 2*m_words + offset_words,
                                                          // via an add rather than a
                                                          // shift; see header note.

    wire rd_a_fire = (state == S_RD_A_DAT) && dma_read_chnl_valid && dma_read_chnl_ready;
    wire rd_b_fire = (state == S_RD_B_DAT) && dma_read_chnl_valid && dma_read_chnl_ready;
    wire wr_pop    = dma_write_chnl_valid && dma_write_chnl_ready;

    // Issue a PLM read whenever the skid FIFO has room. inflight counts reads
    // in flight plus entries already buffered, so it never exceeds the FIFO
    // depth. A pop frees a slot in the same cycle, hence the || wr_pop term.
    wire wr_issue = (state == S_WR_DAT) &&
                    (o_cnt < word_len[CNT_W-1:0]) &&
                    ((inflight < 2'd2) || wr_pop);

    // A single write port shared by the A-load and the accumulate writeback.
    // For a tail A-beat only the low lane is valid data from the channel; the
    // high lane is deliberately zeroed rather than passed through so no X
    // from an unused HSIZE_WORD beat's upper half can propagate into the sum
    // (that lane is never written back, but zeroing it keeps simulation
    // clean regardless).
    assign plm_wr_en   = rd_a_fire || b1_vld;
    assign plm_wr_addr = rd_a_fire ? a_cnt[PLM_AW-1:0] : b1_idx;
    assign plm_wr_data = rd_a_fire ? (segment == 1'b1 ? {32'd0, dma_read_chnl_data[31:0]}
                                                        : dma_read_chnl_data)
                                    : b1_sum;

    // A single read port shared by the accumulate phase and the write phase.
    assign plm_rd_en   = rd_b_fire || wr_issue;
    assign plm_rd_addr = rd_b_fire ? b_cnt[PLM_AW-1:0] : o_cnt[PLM_AW-1:0];

    // -----------------------------------------------------------------------
    // DMA interface
    // -----------------------------------------------------------------------
    assign dma_read_ctrl_valid       = (state == S_RD_A_REQ) || (state == S_RD_B_REQ);
    assign dma_read_ctrl_data_index  = rd_index_r;
    assign dma_read_ctrl_data_length = segment ? 32'd1 : bulk_beats;
    assign dma_read_ctrl_data_size   = segment ? HSIZE_WORD : HSIZE_DWORD;
    assign dma_read_ctrl_data_user   = 6'd0;

    assign dma_read_chnl_ready       = (state == S_RD_A_DAT) || (state == S_RD_B_DAT);

    assign dma_write_ctrl_valid       = (state == S_WR_REQ);
    assign dma_write_ctrl_data_index  = wr_index_r;
    assign dma_write_ctrl_data_length = segment ? 32'd1 : bulk_beats;
    assign dma_write_ctrl_data_size   = segment ? HSIZE_WORD : HSIZE_DWORD;
    assign dma_write_ctrl_data_user   = 6'd0;

    assign dma_write_chnl_valid = (state == S_WR_DAT) && (fifo_cnt != 2'd0);
    assign dma_write_chnl_data  = fifo_rp ? fifo1 : fifo0;

    assign acc_done = (state == S_DONE);

    // -----------------------------------------------------------------------
    // Sequential logic
    //
    // The reset is asynchronous and active low, which is what the ESP socket
    // drives: acc_rst is a registered signal held low for a single cycle in
    // the socket's reset state (esp_acc_dma.vhd:960, :724).
    //
    // Define VECADD_SYNC_RESET to make it synchronous instead. Some eFPGA
    // fabrics have no usable asynchronous reset on their flops, and a flow
    // that cannot map one may quietly drop it, leaving the core to come out of
    // reset in an arbitrary state. Synchronous reset is safe here because the
    // socket clocks acc_rst off the same clock the accelerator runs on, so the
    // clock is always running while the reset is asserted.
    // -----------------------------------------------------------------------
`ifdef VECADD_SYNC_RESET
    always @(posedge clk) begin
`else
    always @(posedge clk or negedge rst) begin
`endif
        if (!rst) begin
            state      <= S_IDLE;
            segment    <= 1'b0;
            len_total  <= 32'd0;
            chunk_max  <= 32'd0;
            offset     <= 32'd0;
            chunk_len  <= 32'd0;
            rd_index_r <= 32'd0;
            wr_index_r <= 32'd0;
            a_cnt      <= {CNT_W{1'b0}};
            b_cnt      <= {CNT_W{1'b0}};
            o_cnt      <= {CNT_W{1'b0}};
            w_cnt      <= {CNT_W{1'b0}};
            b0_vld     <= 1'b0;
            b0_idx     <= {PLM_AW{1'b0}};
            b0_data    <= 64'd0;
            b1_vld     <= 1'b0;
            b1_idx     <= {PLM_AW{1'b0}};
            b1_sum     <= 64'd0;
            wr_issue_d <= 1'b0;
            inflight   <= 2'd0;
            fifo_cnt   <= 2'd0;
            fifo_wp    <= 1'b0;
            fifo_rp    <= 1'b0;
            fifo0      <= 64'd0;
            fifo1      <= 64'd0;
        end else begin

            // -- accumulate pipeline ------------------------------------------
            b0_vld <= rd_b_fire;
            if (rd_b_fire) begin
                b0_idx  <= b_cnt[PLM_AW-1:0];
                b0_data <= (segment == 1'b1) ? {32'd0, dma_read_chnl_data[31:0]}
                                              : dma_read_chnl_data;
            end

            b1_vld <= b0_vld;
            if (b0_vld) begin
                b1_idx <= b0_idx;
                // Two independent 32-bit lanes. The high lane is only ever
                // meaningful when this word is a bulk (paired) word; for a
                // tail word both operands' high lanes were zeroed above, so
                // the high-lane sum here is a harmless zero that is never
                // written out (the tail write beat only sends bits [31:0]).
                b1_sum[31:0]  <= plm_rd_data[31:0]  + b0_data[31:0];
                b1_sum[63:32] <= plm_rd_data[63:32] + b0_data[63:32];
            end

            // -- write-side staging -------------------------------------------
            wr_issue_d <= wr_issue;

            if (wr_issue_d) begin
                if (fifo_wp)
                    fifo1 <= plm_rd_data;
                else
                    fifo0 <= plm_rd_data;
                fifo_wp <= ~fifo_wp;
            end

            if (wr_pop)
                fifo_rp <= ~fifo_rp;

            case ({wr_issue_d, wr_pop})
                2'b10:   fifo_cnt <= fifo_cnt + 2'd1;
                2'b01:   fifo_cnt <= fifo_cnt - 2'd1;
                default: fifo_cnt <= fifo_cnt;
            endcase

            case ({wr_issue, wr_pop})
                2'b10:   inflight <= inflight + 2'd1;
                2'b01:   inflight <= inflight - 2'd1;
                default: inflight <= inflight;
            endcase

            // -- beat counters -------------------------------------------------
            if (rd_a_fire) a_cnt <= a_cnt + 1'b1;
            if (rd_b_fire) b_cnt <= b_cnt + 1'b1;
            if (wr_issue)  o_cnt <= o_cnt + 1'b1;
            if (wr_pop)    w_cnt <= w_cnt + 1'b1;

            // -- control -------------------------------------------------------
            case (state)

                S_IDLE: begin
                    // conf_done is a one-cycle pulse, so latch on the edge.
                    if (conf_done) begin
                        len_total <= conf_info_vector_size;
                        chunk_max <= chunk_req_ok ? chunk_req_even
                                                  : PLM_DEPTH_ELEMS;
                        offset    <= 32'd0;
                        state     <= S_START;
                    end
                end

                S_START: begin
                    a_cnt      <= {CNT_W{1'b0}};
                    b_cnt      <= {CNT_W{1'b0}};
                    o_cnt      <= {CNT_W{1'b0}};
                    w_cnt      <= {CNT_W{1'b0}};
                    fifo_cnt   <= 2'd0;
                    inflight   <= 2'd0;
                    fifo_wp    <= 1'b0;
                    fifo_rp    <= 1'b0;
                    wr_issue_d <= 1'b0;
                    // rd_index_r starts on A's word base; segment picks bulk
                    // unless this chunk is a single unpaired element.
                    rd_index_r <= a_index_word;
                    segment    <= seg_start_next;
                    if (remaining == 32'd0) begin
                        state <= S_DONE;
                    end else begin
                        chunk_len <= next_chunk;
                        state     <= S_RD_A_REQ;
                    end
                end

                S_RD_A_REQ: begin
                    if (dma_read_ctrl_ready)
                        state <= S_RD_A_DAT;
                end

                S_RD_A_DAT: begin
                    if (rd_a_fire && (a_cnt + 1'b1 == word_len[CNT_W-1:0])) begin
                        // Whole A phase (bulk + optional tail) done. Same edge
                        // that enters S_RD_B_REQ, so the B base is in place
                        // before dma_read_ctrl_valid rises again.
                        rd_index_r <= b_index_word;
                        segment    <= seg_start;
                        state      <= S_RD_B_REQ;
                    end else if (rd_a_fire && (segment == 1'b0) &&
                                 (a_cnt + 1'b1 == bulk_beats[CNT_W-1:0])) begin
                        // Bulk segment done, a tail beat remains in this same
                        // phase: re-issue a request rather than staying in
                        // S_RD_A_DAT under the now-finished bulk grant.
                        rd_index_r <= rd_index_r + bulk_beats;
                        segment    <= 1'b1;
                        state      <= S_RD_A_REQ;
                    end
                end

                S_RD_B_REQ: begin
                    // rd_index_r holds b_index_word throughout the bulk part
                    // of this state and does not depend on it changing later
                    // in the phase, so this write is safe here regardless of
                    // how many times S_RD_B_REQ is re-entered for the tail.
                    wr_index_r <= c_index_word;
                    if (dma_read_ctrl_ready)
                        state <= S_RD_B_DAT;
                end

                S_RD_B_DAT: begin
                    // Level checks, not fire-gated: b_cnt holds its final
                    // value for as long as it takes the accumulate pipeline
                    // to drain (b0_vld/b1_vld), and that drain takes two more
                    // cycles after the beat that brought b_cnt to word_len,
                    // cycles in which rd_b_fire is false.
                    //
                    if ((b_cnt == word_len[CNT_W-1:0]) && !b0_vld && !b1_vld) begin
                        segment <= seg_start;
                        state   <= S_WR_REQ;
                    end else if ((segment == 1'b0) && tail_beat &&
                                 (b_cnt == bulk_beats[CNT_W-1:0])) begin
                        rd_index_r <= rd_index_r + bulk_beats;
                        segment    <= 1'b1;
                        state      <= S_RD_B_REQ;
                    end
                end

                S_WR_REQ: begin
                    if (dma_write_ctrl_ready)
                        state <= S_WR_DAT;
                end

                S_WR_DAT: begin
                    if (wr_pop && (w_cnt + 1'b1 == word_len[CNT_W-1:0])) begin
                        state <= S_NEXT;
                    end else if (wr_pop && (segment == 1'b0) &&
                                 (w_cnt + 1'b1 == bulk_beats[CNT_W-1:0])) begin
                        wr_index_r <= wr_index_r + bulk_beats;
                        segment    <= 1'b1;
                        state      <= S_WR_REQ;
                    end
                end

                S_NEXT: begin
                    offset <= offset_next;
                    if (offset_next >= len_total)
                        state <= S_DONE;
                    else
                        state <= S_START;
                end

                S_DONE: begin
                    // acc_done is asserted for exactly this one cycle.
                    state <= S_HOLD;
                end

                S_HOLD: begin
                    // Park until software resets us through acc_rst.
                    state <= S_HOLD;
                end

                default: begin
                    state <= S_IDLE;
                end

            endcase
        end
    end

endmodule
