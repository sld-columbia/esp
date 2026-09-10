// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// vecadd_rtl_basic_dma32
//
// Elementwise 32-bit integer vector addition:  C[i] = A[i] + B[i], i in [0,N).
//
// ---------------------------------------------------------------------------
// ESP accelerator-core contract (32-bit DMA)
// ---------------------------------------------------------------------------
// This module sits at the boundary that rtl/sockets/proxy/esp_acc_dma.vhd
// drives. Everything below was taken from that file, not from the accgen
// template comments, which disagree with it in places.
//
//   rst          ACTIVE LOW. It is acc_rst from the socket, which is driven to
//                '0' in the socket's reset state (esp_acc_dma.vhd:960).
//
//   conf_done    SINGLE-CYCLE pulse, not a level. The socket asserts it for
//                exactly one cycle in its config state (esp_acc_dma.vhd:967)
//                before moving to running. It must be latched.
//
//   *_ctrl_*     index and length are counted in DMA words, i.e. units of
//                DMA_NOC_WIDTH/8 bytes, which is 4 bytes here. The socket
//                forms the address as (index << 2) + SRC_OFFSET_REG
//                (esp_acc_tlb.vhd:188). index/length are NOT byte counts.
//
//   grant        *_ctrl_ready is held high for as long as *_ctrl_valid is high
//                while the socket sits in its rd_handshake / wr_handshake state
//                (esp_acc_dma.vhd:972). It is not a one-shot, so the core must
//                drop *_ctrl_valid the cycle after it observes ready, or the
//                socket will grant the same request repeatedly. Here valid is
//                decoded from the state register and the state advances on
//                ready, which drops valid on the next cycle by construction.
//
//   *_ctrl_data_user
//                SIX bits. The accgen template declares [4:0]; socketgen.py
//                binds this port to a 6-bit VHDL signal (socketgen.py:1044),
//                so the template is wrong and would truncate on integration.
//                Zero here: non-zero selects P2P / multicast behaviour.
//
//   *_ctrl_data_size
//                AMBA HSIZE encoding. 3'b010 is HSIZE_WORD (32-bit elements),
//                which is what drives the socket's fix_endian on big-endian
//                targets. For a 32-bit DMA with 32-bit elements that mapping
//                is the identity, so no swap happens in either endianness.
//
//   acc_done     SINGLE-CYCLE pulse. The socket latches it into
//                pending_acc_done (esp_acc_dma.vhd:731) and holds the
//                accelerator until software resets it via acc_rst.
//
//   debug        Deliberately absent. socketgen does not generate a connection
//                for it, and omitting it saves 32 eFPGA boundary pins.
//
// ---------------------------------------------------------------------------
// Memory layout, in 32-bit word indices within the accelerator's virtual space
// ---------------------------------------------------------------------------
//   A: [0,   N)      B: [N,  2N)      C: [2N, 3N)
// The driver allocates one contiguous 3N-word buffer and leaves both
// SRC_OFFSET_REG and DST_OFFSET_REG at zero.


`timescale 1ps / 1ps

`define VECADD_SYNC_RESET

module vecadd_rtl_basic_dma32 #(
    parameter PLM_DEPTH = 512
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
    input  [31:0] dma_read_chnl_data;
    output        dma_read_chnl_ready;

    input         dma_write_ctrl_ready;
    output        dma_write_ctrl_valid;
    output [31:0] dma_write_ctrl_data_index;
    output [31:0] dma_write_ctrl_data_length;
    output [ 2:0] dma_write_ctrl_data_size;
    output [ 5:0] dma_write_ctrl_data_user;

    input         dma_write_chnl_ready;
    output        dma_write_chnl_valid;
    output [31:0] dma_write_chnl_data;

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
    localparam CNT_W  = PLM_AW + 1;                 // holds 0..PLM_DEPTH

    localparam [CNT_W-1:0] PLM_DEPTH_V  = PLM_DEPTH;
    localparam [31:0]      PLM_DEPTH_32 = PLM_DEPTH;

    localparam [2:0] HSIZE_WORD = 3'b010;           // amba.vhd:212

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

    // -----------------------------------------------------------------------
    // State
    // -----------------------------------------------------------------------
    reg  [3:0]        state;

    reg  [31:0]       len_total;          // N, latched at conf_done
    reg  [CNT_W-1:0]  chunk_max;          // clamped chunk size
    reg  [31:0]       offset;             // elements completed so far
    reg  [CNT_W-1:0]  chunk_len;          // beats in the current chunk

    reg  [31:0]       rd_index_r /* synthesis syn_preserve=1 */;
    reg  [31:0]       wr_index_r /* synthesis syn_preserve=1 */;

    reg  [CNT_W-1:0]  a_cnt;              // A beats absorbed
    reg  [CNT_W-1:0]  b_cnt;              // B beats absorbed
    reg  [CNT_W-1:0]  o_cnt;              // PLM reads issued in the write phase
    reg  [CNT_W-1:0]  w_cnt;              // C beats accepted

    // Accumulate pipeline
    reg               b0_vld;
    reg  [PLM_AW-1:0] b0_idx;
    reg  [31:0]       b0_data;
    reg               b1_vld;
    reg  [PLM_AW-1:0] b1_idx;
    reg  [31:0]       b1_sum;

    reg               wr_issue_d;
    reg  [1:0]        inflight;           // reads issued but not yet popped
    reg  [1:0]        fifo_cnt;
    reg               fifo_wp;
    reg               fifo_rp;
    reg  [31:0]       fifo0;
    reg  [31:0]       fifo1;

    // -----------------------------------------------------------------------
    // PLM
    // -----------------------------------------------------------------------
    wire              plm_wr_en;
    wire [PLM_AW-1:0] plm_wr_addr;
    wire [31:0]       plm_wr_data;
    wire              plm_rd_en;
    wire [PLM_AW-1:0] plm_rd_addr;
    wire [31:0]       plm_rd_data;

    vecadd_plm #(
        .WIDTH (32),
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
    // Combinational helpers
    // -----------------------------------------------------------------------
    wire [31:0] chunk_req    = conf_info_chunk_size;
    wire        chunk_req_ok = (chunk_req != 32'd0) && (chunk_req <= PLM_DEPTH_32);

    wire [31:0] chunk_len32  = {{(32-CNT_W){1'b0}}, chunk_len};
    wire [31:0] chunk_max32  = {{(32-CNT_W){1'b0}}, chunk_max};

    wire [31:0] remaining    = len_total - offset;
    wire [CNT_W-1:0] next_chunk = (remaining > chunk_max32) ? chunk_max
                                                            : remaining[CNT_W-1:0];

    wire [31:0] offset_next  = offset + chunk_len32;

    // Bases of the three vectors in the shared buffer, in elements. These feed
    // rd_index_r / wr_index_r rather than the pins directly; see the register
    // declarations above.
    wire [31:0] a_index = offset;
    wire [31:0] b_index = len_total + offset;

    wire rd_a_fire = (state == S_RD_A_DAT) && dma_read_chnl_valid && dma_read_chnl_ready;
    wire rd_b_fire = (state == S_RD_B_DAT) && dma_read_chnl_valid && dma_read_chnl_ready;
    wire wr_pop    = dma_write_chnl_valid && dma_write_chnl_ready;

    wire wr_issue = (state == S_WR_DAT) &&
                    (o_cnt < chunk_len) &&
                    ((inflight < 2'd2) || wr_pop);

    assign plm_wr_en   = rd_a_fire || b1_vld;
    assign plm_wr_addr = rd_a_fire ? a_cnt[PLM_AW-1:0] : b1_idx;
    assign plm_wr_data = rd_a_fire ? dma_read_chnl_data : b1_sum;

    // A single read port shared by the accumulate phase and the write phase.
    assign plm_rd_en   = rd_b_fire || wr_issue;
    assign plm_rd_addr = rd_b_fire ? b_cnt[PLM_AW-1:0] : o_cnt[PLM_AW-1:0];

    // -----------------------------------------------------------------------
    // DMA interface
    // -----------------------------------------------------------------------
    assign dma_read_ctrl_valid       = (state == S_RD_A_REQ) || (state == S_RD_B_REQ);
    assign dma_read_ctrl_data_index  = rd_index_r;
    assign dma_read_ctrl_data_length = chunk_len32;
    assign dma_read_ctrl_data_size   = HSIZE_WORD;
    assign dma_read_ctrl_data_user   = 6'd0;

    assign dma_read_chnl_ready       = (state == S_RD_A_DAT) || (state == S_RD_B_DAT);

    assign dma_write_ctrl_valid       = (state == S_WR_REQ);
    assign dma_write_ctrl_data_index  = wr_index_r;
    assign dma_write_ctrl_data_length = chunk_len32;
    assign dma_write_ctrl_data_size   = HSIZE_WORD;
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
`ifdef VECADD_SYNC_RESET
    always @(posedge clk) begin
`else
    always @(posedge clk or negedge rst) begin
`endif
        if (!rst) begin
            state      <= S_IDLE;
            len_total  <= 32'd0;
            chunk_max  <= {CNT_W{1'b0}};
            offset     <= 32'd0;
            chunk_len  <= {CNT_W{1'b0}};
            rd_index_r <= 32'd0;
            wr_index_r <= 32'd0;
            a_cnt      <= {CNT_W{1'b0}};
            b_cnt      <= {CNT_W{1'b0}};
            o_cnt      <= {CNT_W{1'b0}};
            w_cnt      <= {CNT_W{1'b0}};
            b0_vld     <= 1'b0;
            b0_idx     <= {PLM_AW{1'b0}};
            b0_data    <= 32'd0;
            b1_vld     <= 1'b0;
            b1_idx     <= {PLM_AW{1'b0}};
            b1_sum     <= 32'd0;
            wr_issue_d <= 1'b0;
            inflight   <= 2'd0;
            fifo_cnt   <= 2'd0;
            fifo_wp    <= 1'b0;
            fifo_rp    <= 1'b0;
            fifo0      <= 32'd0;
            fifo1      <= 32'd0;
        end else begin

            // -- accumulate pipeline ------------------------------------------
            b0_vld <= rd_b_fire;
            if (rd_b_fire) begin
                b0_idx  <= b_cnt[PLM_AW-1:0];
                b0_data <= dma_read_chnl_data;
            end

            b1_vld <= b0_vld;
            if (b0_vld) begin
                b1_idx <= b0_idx;
                b1_sum <= plm_rd_data + b0_data;
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
                        chunk_max <= chunk_req_ok ? chunk_req[CNT_W-1:0]
                                                  : PLM_DEPTH_V;
                        offset    <= 32'd0;
                        state     <= S_START;
                    end
                end

                S_START: begin
                    a_cnt    <= {CNT_W{1'b0}};
                    b_cnt    <= {CNT_W{1'b0}};
                    o_cnt      <= {CNT_W{1'b0}};
                    w_cnt      <= {CNT_W{1'b0}};
                    fifo_cnt   <= 2'd0;
                    inflight   <= 2'd0;
                    fifo_wp    <= 1'b0;
                    fifo_rp    <= 1'b0;
                    wr_issue_d <= 1'b0;
                    // Both indices are latched here, a full cycle before the
                    // request they belong to is asserted. rd_index_r starts on
                    // the A base and is reloaded with the B base below.
                    rd_index_r <= a_index;
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
                    if (rd_a_fire && (a_cnt + 1'b1 == chunk_len)) begin
                        // Same edge that enters S_RD_B_REQ, so the B base is in
                        // place before dma_read_ctrl_valid rises again.
                        rd_index_r <= b_index;
                        state      <= S_RD_B_REQ;
                    end
                end

                S_RD_B_REQ: begin
                    // rd_index_r holds b_index throughout this state and
                    // len_total cannot change, so this is idempotent, and it
                    // lands many cycles before S_WR_REQ needs it. Adding
                    // len_total to the B base gives the C base.
                    wr_index_r <= rd_index_r + len_total;
                    if (dma_read_ctrl_ready)
                        state <= S_RD_B_DAT;
                end

                S_RD_B_DAT: begin
                    // Wait for the last two pipeline stages to retire so the
                    // final sum has reached the PLM before it is streamed out.
                    if ((b_cnt == chunk_len) && !b0_vld && !b1_vld)
                        state <= S_WR_REQ;
                end

                S_WR_REQ: begin
                    if (dma_write_ctrl_ready)
                        state <= S_WR_DAT;
                end

                S_WR_DAT: begin
                    if (wr_pop && (w_cnt + 1'b1 == chunk_len))
                        state <= S_NEXT;
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
