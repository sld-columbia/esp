// FIFO for packet-switched router
//
// Interface
//
// * Inputs
// - clk: all signals are synchronous to this clock signal.
// - rst: active high reset
// - rdreq: set to 1 for one cycle to pop unless the FIFO is empty; if BypassEnable is set, rdreq
//   and wrreq can be asserted in the same cycle to forward data_in to data_out.
// - wrreq: set to 1 for one cycle to push; wrreq has no effect if the FIFO is full.
// - data_in: data to be pushed; if BypassEnable is set and the FIFO is empty data_in is forwarded
//   to data_out with zero-cycles delay.
//
// * Outputs
// - empty: when set to 1, the FIFO is empty; after reset, the FIFO is empty.
// - full: when set to 1, the FIFO is full.
// - data_out: data present at the head of the FIFO; this output is not valid when the FIFO is
//   empty. If BypassEnable is set, data_out may be valid if data_in is valid; in this case the
//   user should assert both rdreq and wrreq.
//
// Parameters
// - BypassEnable: set to 1 to enable zero-cycles delay between data_in and data_out when the FIFO
//   is empty.
// - Depth: depth of the FIFO
// - Width: bit-width of data_in and data_out
//
module router_fifo #(
    parameter bit BypassEnable = 1'b1,
    parameter int unsigned Depth = 4,
    parameter int unsigned Width = 8
) (
    input logic clk,
    input logic rst,
    input logic rdreq,
    input logic wrreq,
    input logic [Width-1:0] data_in,
    output logic empty,
    output logic full,
    output logic [Width-1:0] data_out
);

    logic [Depth-1:0][Width-1:0] mem;

    // Read pointer for FIFO head
    logic [$clog2(Depth+1)-1:0] head;
    logic [$clog2(Depth+1)-1:0] head_next;

    // One hot mask for FIFO tail and tilization
    logic [Depth-1:0] tail;
    logic [Depth:0] used;

    logic valid_read;
    logic valid_write;
    logic [Width-1:0] data_out_nobypass;

    genvar g_i;

    assign valid_read  = rdreq & ~empty;
    assign valid_write = BypassEnable & empty ? wrreq & ~rdreq : wrreq & ~full;
    assign data_out    = BypassEnable & empty ? data_in : data_out_nobypass;

    // Update head
    assign head_next   = head == (Depth - 1'b1) ? '0 : head + 1'b1;
    always_ff @(posedge clk) begin
        if (rst) begin
            head <= '0;
        end else if (valid_read) begin
            head <= head_next;
        end
    end

    // Update tail
    always_ff @(posedge clk) begin
        if (rst) begin
            tail[Depth-1:1] <= '0;
            tail[0]         <= 1'b1;
        end else if (valid_write) begin
            tail[Depth-1:1] <= tail[Depth-2:0];
            tail[0]         <= tail[Depth-1];
        end
    end

    // Update FIFO state
    always_ff @(posedge clk) begin
        if (rst) begin
            used[Depth:1] <= '0;
            used[0]       <= 1'b1;
        end else begin
            if (valid_write & ~valid_read) begin
                used[Depth:1] <= used[Depth-1:0];
                used[0]       <= 1'b0;
            end else if (~valid_write & valid_read) begin
                used[Depth-1:0] <= used[Depth:1];
                used[Depth]     <= 1'b0;
            end
        end
    end

    assign empty = used[0];
    assign full  = used[Depth];

    // Write
    for (g_i = 0; g_i < Depth; g_i++) begin : gen_fifo_write
        always_ff @(posedge clk) begin
            if (rst) begin
                mem[g_i] <= '0;
            end else if (valid_write & tail[g_i]) begin
                mem[g_i] <= data_in;
            end
        end
    end

    // Read
    assign data_out_nobypass = mem[head];  // ri lint_check_waive VAR_INDEX_RANGE

    //
    // Assertions
    //

`ifndef SYNTHESIS
    // pragma coverage off
    //VCS coverage off

    // FIFO is in good state
    a_head_lt_depth :
    assert property (@(posedge clk) disable iff (rst) head < Depth)
    else $error("Fail: a_head_lt_depth");
    a_tail_onehot :
    assert property (@(posedge clk) disable iff (rst) $onehot(tail))
    else $error("Fail: a_tail_onehot");
    a_used_onehot :
    assert property (@(posedge clk) disable iff (rst) $onehot(used))
    else $error("Fail: a_used_onehot");

    // pragma coverage on
    //VCS coverage on
`endif  // ~SYNTHESIS

endmodule
