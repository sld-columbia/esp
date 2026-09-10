// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// Private local memory (PLM) for vecadd_rtl.
//
// Simple dual-port: one write port, one read port, independent addresses.
// The read port has a fixed latency of ONE cycle (registered read data).
// vecadd_rtl_basic_dma32 is built around that latency; do not change it
// without updating the pipelines in the core.
//
// Read-during-write behaviour at the SAME address is intentionally left
// unspecified, because the core never reads and writes the same address in
// the same cycle. See the hazard notes in vecadd_rtl_basic_dma32.v.
//
`timescale 1ps / 1ps

module vecadd_plm #(
    parameter WIDTH = 32,
    parameter DEPTH = 512,
    parameter AW    = 9
) (
    input  wire             clk,

    input  wire             wr_en,
    input  wire [AW-1:0]    wr_addr,
    input  wire [WIDTH-1:0] wr_data,

    input  wire             rd_en,
    input  wire [AW-1:0]    rd_addr,
    output wire [WIDTH-1:0] rd_data
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [WIDTH-1:0] rd_data_r;

    always @(posedge clk) begin
        if (wr_en)
            mem[wr_addr] <= wr_data;
        if (rd_en)
            rd_data_r <= mem[rd_addr];
    end

    assign rd_data = rd_data_r;

endmodule
