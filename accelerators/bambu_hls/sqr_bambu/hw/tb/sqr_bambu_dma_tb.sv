// Copyright (c) 2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
// Independent ESP DMA oracle. No sequential C model of shared ping-pong RAMs.
`timescale 1ns/1ps
module sqr_bambu_dma_tb;
    reg clk = 0, rst = 0, conf_done = 0;
    always #5 clk = ~clk;
    reg [31:0] conf_info_len, conf_info_base_in, conf_info_base_out;
    wire acc_done;
    wire [31:0] debug;
    wire dma_read_ctrl_valid, dma_write_ctrl_valid;
    reg dma_read_ctrl_ready = 0, dma_write_ctrl_ready = 0;
    wire [31:0] dma_read_ctrl_data_index, dma_read_ctrl_data_length;
    wire [31:0] dma_write_ctrl_data_index, dma_write_ctrl_data_length;
    wire [2:0] dma_read_ctrl_data_size, dma_write_ctrl_data_size;
    wire [5:0] dma_read_ctrl_data_user, dma_write_ctrl_data_user;
    reg dma_read_chnl_valid = 0, dma_write_chnl_ready = 0;
    wire dma_read_chnl_ready, dma_write_chnl_valid;
    reg [63:0] dma_read_chnl_data = 0;
    wire [63:0] dma_write_chnl_data;
    sqr_bambu_basic_dma64 dut (.*);

    reg [31:0] mem [0:4095];
    reg [31:0] expected [0:4095];
    integer rd_left, wr_left, rd_addr, wr_addr, rd_reqs, wr_reqs;
    integer reads, writes, cycles, overlap, total_overlap = 0;
    integer rc_stalls, wc_stalls, wd_stalls, seed = 1;
    reg [31:0] rng = 1;
    reg rc_held, wc_held, wd_held;
    reg [63:0] rc_previous, wc_previous, wd_previous;
    reg completed;

    function automatic [31:0] sample(input integer i, input integer invocation);
        // Different every batch, including overflow and high-bit values.
        sample = (32'h9e3779b9 * (i + 1)) ^ (32'h10203041 * invocation);
    endfunction

    task automatic run_case(input integer words, input integer mode, input integer invocation);
        integer i, in_base, out_base;
        reg [31:0] value;
        begin
            in_base = 5 + invocation;
            out_base = 1024 + invocation * 3;
            for (i = 0; i < 4096; i = i + 1) begin
                mem[i] = 32'hdeadbeef;
                expected[i] = 32'hdeadbeef;
            end
            for (i = 0; i < words; i = i + 1) begin
                value = sample(i, invocation);
                mem[2*in_base+i] = value;
                expected[2*in_base+i] = value;
                expected[2*out_base+i] = value * value;
            end
            conf_info_len = words;
            conf_info_base_in = in_base;
            conf_info_base_out = out_base;
            rd_left = 0; wr_left = 0; rd_reqs = 0; wr_reqs = 0;
            reads = 0; writes = 0; cycles = 0; overlap = 0;
            rc_stalls = 0; wc_stalls = 0; wd_stalls = 0;
            rc_held = 0; wc_held = 0; wd_held = 0; completed = 0;
            rng = seed + invocation;
            @(negedge clk); conf_done = 1;
            @(negedge clk); conf_done = 0;
            while (!completed && cycles < 200000) begin
                // Hold input data/valid until accepted; independently stall all channels.
                rng = rng ^ (rng << 13); rng = rng ^ (rng >> 17); rng = rng ^ (rng << 5);
                dma_read_ctrl_ready = rd_left == 0 && (mode == 0 || rng[2:0] == 0);
                dma_write_ctrl_ready = wr_left == 0 && (mode == 0 || rng[5:3] == 0);
                if (!dma_read_chnl_valid && rd_left > 0 &&
                    (mode != 1 || rng[9:6] == 0)) begin
                    dma_read_chnl_valid = 1;
                    dma_read_chnl_data = {mem[2*rd_addr+1], mem[2*rd_addr]};
                end
                dma_write_chnl_ready = wr_left > 0 && (mode != 2 || rng[13:10] == 0);
                // Long final-output stall checks done ordering against the wire.
                if (mode == 2 && writes == words/2-1 && cycles % 257 != 0)
                    dma_write_chnl_ready = 0;
                @(posedge clk);
                if (rc_held && (!dma_read_ctrl_valid ||
                    {dma_read_ctrl_data_length,dma_read_ctrl_data_index} !== rc_previous))
                    $fatal(1, "read descriptor changed under backpressure");
                if (wc_held && (!dma_write_ctrl_valid ||
                    {dma_write_ctrl_data_length,dma_write_ctrl_data_index} !== wc_previous))
                    $fatal(1, "write descriptor changed under backpressure");
                if (wd_held && (!dma_write_chnl_valid || dma_write_chnl_data !== wd_previous))
                    $fatal(1, "write data changed under backpressure");
                rc_held = dma_read_ctrl_valid && !dma_read_ctrl_ready;
                wc_held = dma_write_ctrl_valid && !dma_write_ctrl_ready;
                wd_held = dma_write_chnl_valid && !dma_write_chnl_ready;
                rc_previous = {dma_read_ctrl_data_length,dma_read_ctrl_data_index};
                wc_previous = {dma_write_ctrl_data_length,dma_write_ctrl_data_index};
                wd_previous = dma_write_chnl_data;
                rc_stalls = rc_stalls + rc_held;
                wc_stalls = wc_stalls + wc_held;
                wd_stalls = wd_stalls + wd_held;
                if (rd_left > 0 && wr_left > 0) overlap = overlap + 1;
                if (dma_read_ctrl_valid && dma_read_ctrl_ready) begin
                    if (rd_reqs >= words/16 || dma_read_ctrl_data_index !== in_base+rd_reqs*8 ||
                        dma_read_ctrl_data_length !== 8 || dma_read_ctrl_data_size !== 3 ||
                        dma_read_ctrl_data_user !== 0) $fatal(1, "bad read descriptor");
                    rd_addr = dma_read_ctrl_data_index; rd_left = 8; rd_reqs = rd_reqs + 1;
                end
                if (dma_write_ctrl_valid && dma_write_ctrl_ready) begin
                    if (wr_reqs >= words/16 || dma_write_ctrl_data_index !== out_base+wr_reqs*8 ||
                        dma_write_ctrl_data_length !== 8 || dma_write_ctrl_data_size !== 3 ||
                        dma_write_ctrl_data_user !== 0) $fatal(1, "bad write descriptor");
                    wr_addr = dma_write_ctrl_data_index; wr_left = 8; wr_reqs = wr_reqs + 1;
                end
                if (dma_read_chnl_valid && dma_read_chnl_ready) begin
                    if (rd_left <= 0) $fatal(1, "read without descriptor");
                    rd_left = rd_left - 1; rd_addr = rd_addr + 1; reads = reads + 1;
                end
                if (dma_write_chnl_valid && dma_write_chnl_ready) begin
                    if (wr_left <= 0) $fatal(1, "write without descriptor");
                    mem[2*wr_addr] = dma_write_chnl_data[31:0];
                    mem[2*wr_addr+1] = dma_write_chnl_data[63:32];
                    wr_left = wr_left - 1; wr_addr = wr_addr + 1; writes = writes + 1;
                end
                if (acc_done) begin
                    if (reads != words/2 || writes != words/2 || rd_left || wr_left ||
                        rd_reqs != words/16 || wr_reqs != words/16)
                        $fatal(1, "early done reads=%0d writes=%0d expected=%0d", reads,writes,words/2);
                    completed = 1;
                end
                // Change testbench inputs after the DUT's sampling edge.
                if (dma_read_chnl_valid && dma_read_chnl_ready) begin
                    #1; dma_read_chnl_valid = 0;
                end
                cycles = cycles + 1;
                @(negedge clk);
            end
            if (!completed) $fatal(1, "deadlock words=%0d mode=%0d", words, mode);
            dma_read_ctrl_ready = 0; dma_write_ctrl_ready = 0; dma_write_chnl_ready = 0;
            for (i = 0; i < 4096; i = i + 1)
                if (mem[i] !== expected[i])
                    $fatal(1, "memory[%0d]=%h expected=%h words=%0d mode=%0d",i,mem[i],expected[i],words,mode);
            if (debug !== words/2) $fatal(1, "debug write count mismatch");
            if (mode != 0 && (rc_stalls == 0 || wc_stalls == 0))
                $fatal(1, "descriptor stalls not exercised");
            if (mode == 2 && wd_stalls == 0) $fatal(1, "write stalls not exercised");
            total_overlap = total_overlap + overlap;
            $display("PASS words=%0d mode=%0d cycles=%0d overlap=%0d stalls=%0d/%0d/%0d",
                     words,mode,cycles,overlap,rc_stalls,wc_stalls,wd_stalls);
            repeat (12) begin
                @(posedge clk); #1;
                if (acc_done || dma_read_ctrl_valid || dma_write_ctrl_valid || dma_write_chnl_valid)
                    $fatal(1, "unexpected traffic/completion after done");
            end
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        repeat (6) @(negedge clk);
        rst = 1;
        run_case(16, 0, 1);
        run_case(48, 1, 2);
        run_case(128, 2, 3);
        run_case(272, 0, 4);
        run_case(272, 1, 5);
        run_case(272, 2, 6);
        if (total_overlap == 0) $fatal(1, "load/store overlap never observed");
        $display("SQR_BAMBU DMA RTL PASS seed=%0d overlap_cycles=%0d", seed,total_overlap);
        $finish;
    end
    initial begin #20000000; $fatal(1, "global watchdog"); end
endmodule
