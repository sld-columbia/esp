// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

//
// Clock divider that divides by 1, 2, 3, and 4
// Author: Davide Giri
//

module clkdiv1234 (
    rstn,
    clkin,
    clk_div1,
    clk_div2,
    clk_div3,
    clk_div4
);

    input rstn;
    input clkin;
    output clk_div1, clk_div3, clk_div4;
    output reg clk_div2;

    reg [1:0] pos_cnt, neg_cnt;
    reg  [1:0] r_reg;
    wire [1:0] r_nxt;
    reg        clk_track;

    // clk_div1
    assign clk_div1 = clkin;

    // clk_div2
    always @(posedge clkin) begin
        if (~rstn) clk_div2 <= 1'b0;
        else clk_div2 <= ~clk_div2;
    end

    // clk_div3
    always @(posedge clkin)
        if (~rstn) pos_cnt <= 0;
        else if (pos_cnt == 2) pos_cnt <= 0;
        else pos_cnt <= pos_cnt + 1;

    always @(negedge clkin)
        if (~rstn) neg_cnt <= 0;
        else if (neg_cnt == 2) neg_cnt <= 0;
        else neg_cnt <= neg_cnt + 1;

    assign clk_div3 = ((pos_cnt == 2) | (neg_cnt == 2));

    // clk_div4
    always @(posedge clkin or negedge rstn) begin
        if (~rstn) begin
            r_reg     <= 3'b0;
            clk_track <= 1'b0;
        end else if (r_nxt == 2'b10) begin
            r_reg     <= 0;
            clk_track <= ~clk_track;
        end else r_reg <= r_nxt;
    end

    assign r_nxt    = r_reg + 1;
    assign clk_div4 = clk_track;

endmodule
