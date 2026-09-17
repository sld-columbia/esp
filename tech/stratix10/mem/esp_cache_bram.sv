// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

`timescale 1 ps / 1 ps

module esp_cache_tdp_ram #(
    parameter int DATA_WIDTH = 16,
    parameter int ADDR_WIDTH = 10,
    parameter int DEPTH = 1024
) (
    input  logic                  CLK0,
    input  logic [ADDR_WIDTH-1:0] A0,
    input  logic [DATA_WIDTH-1:0] D0,
    output logic [DATA_WIDTH-1:0] Q0,
    input  logic                  WE0,
    input  logic                  CE0,
    input  logic                  CLK1,
    input  logic [ADDR_WIDTH-1:0] A1,
    input  logic [DATA_WIDTH-1:0] D1,
    output logic [DATA_WIDTH-1:0] Q1,
    input  logic                  WE1,
    input  logic                  CE1
);

    (* ramstyle = "M20K, no_rw_check" *) logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge CLK0) begin
        if (CE0) begin
            Q0 <= mem[A0];
            if (WE0) begin
                mem[A0] <= D0;
            end
        end
    end

    always_ff @(posedge CLK1) begin
        if (CE1) begin
            Q1 <= mem[A1];
            if (WE1) begin
                mem[A1] <= D1;
            end
        end
    end

endmodule

`define ESP_CACHE_BRAM_WRAPPER(name, addr_width, data_width) \
module name ( \
    input  logic                    CLK0, \
    input  logic [addr_width-1:0]   A0, \
    input  logic [data_width-1:0]   D0, \
    output logic [data_width-1:0]   Q0, \
    input  logic                    WE0, \
    input  logic [data_width-1:0]   WEM0, \
    input  logic                    CE0, \
    input  logic                    CLK1, \
    input  logic [addr_width-1:0]   A1, \
    input  logic [data_width-1:0]   D1, \
    output logic [data_width-1:0]   Q1, \
    input  logic                    WE1, \
    input  logic [data_width-1:0]   WEM1, \
    input  logic                    CE1 \
); \
    esp_cache_tdp_ram #( \
        .DATA_WIDTH(data_width), \
        .ADDR_WIDTH(addr_width), \
        .DEPTH(1 << addr_width) \
    ) ram ( \
        .CLK0(CLK0), \
        .A0(A0), \
        .D0(D0), \
        .Q0(Q0), \
        .WE0(WE0), \
        .CE0(CE0), \
        .CLK1(CLK1), \
        .A1(A1), \
        .D1(D1), \
        .Q1(Q1), \
        .WE1(WE1), \
        .CE1(CE1) \
    ); \
endmodule

`ESP_CACHE_BRAM_WRAPPER(BRAM_512x32,   9, 32)
`ESP_CACHE_BRAM_WRAPPER(BRAM_1024x16, 10, 16)
`ESP_CACHE_BRAM_WRAPPER(BRAM_2048x8,  11,  8)
`ESP_CACHE_BRAM_WRAPPER(BRAM_4096x4,  12,  4)
`ESP_CACHE_BRAM_WRAPPER(BRAM_8192x2,  13,  2)
`ESP_CACHE_BRAM_WRAPPER(BRAM_16384x1, 14,  1)

`undef ESP_CACHE_BRAM_WRAPPER
