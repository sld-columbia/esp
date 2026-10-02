// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module de10_pro_fan_controller #(
    parameter [12:0] TARGET_RPM = 13'd2200,
    parameter integer CLK_HZ = 50000000,
    parameter integer I2C_HZ = 100000,
    parameter integer STARTUP_DELAY_CYCLES = 12500000,
    parameter integer POLL_INTERVAL_CYCLES = 25000000
) (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       fan_alert_n,
    output reg  [3:0] alert_type,
    output reg [12:0] fan0_rpm,
    output reg [12:0] fan1_rpm,
    inout  wire       fan_i2c_scl,
    inout  wire       fan_i2c_sda
);

localparam [6:0] FAN_I2C_ADDR = 7'h48;
localparam [7:0] REG_FAN_DRIVE = 8'h00;
localparam [7:0] REG_CONFIG = 8'h02;
localparam [7:0] REG_GPIO = 8'h04;
localparam [7:0] REG_ALARM = 8'h08;
localparam [7:0] REG_STATUS = 8'h0a;
localparam [7:0] REG_TACH0 = 8'h0c;
localparam [7:0] REG_TACH1 = 8'h0e;
localparam [7:0] REG_TACH_COUNT = 8'h16;

localparam [3:0] ST_STARTUP   = 4'd0;
localparam [3:0] ST_INIT      = 4'd1;
localparam [3:0] ST_SET_SPEED = 4'd2;
localparam [3:0] ST_WAIT      = 4'd3;
localparam [3:0] ST_READ0     = 4'd4;
localparam [3:0] ST_READ1     = 4'd5;
localparam [3:0] ST_STATUS    = 4'd6;
localparam [3:0] ST_CMD_WAIT  = 4'd7;

localparam [2:0] OP_INIT      = 3'd0;
localparam [2:0] OP_SET_SPEED = 3'd1;
localparam [2:0] OP_READ0     = 3'd2;
localparam [2:0] OP_READ1     = 3'd3;
localparam [2:0] OP_STATUS    = 3'd4;

reg [3:0] state;
reg [3:0] return_state;
reg [2:0] active_op;
reg [3:0] init_index;
reg [31:0] wait_count;
reg cmd_start;
reg cmd_read;
reg [7:0] cmd_reg;
reg [7:0] cmd_data;
wire cmd_busy;
wire cmd_done;
wire cmd_ack_error;
wire [7:0] cmd_read_data;
wire [15:0] current_init_word;

assign current_init_word = init_word(init_index);

function [7:0] target_rpm_to_count;
    input [12:0] rpm;
    reg [12:0] rps;
    reg [31:0] count;
    begin
        rps = (rpm < 13'd60) ? 13'd1 : (rpm / 13'd60);
        count = 32'd3968 / rps;
        if (count == 32'd0) begin
            target_rpm_to_count = 8'd0;
        end else if (count > 32'd256) begin
            target_rpm_to_count = 8'hff;
        end else begin
            target_rpm_to_count = count[7:0] - 8'd1;
        end
    end
endfunction

function [15:0] init_word;
    input [3:0] index;
    begin
        case (index)
            4'd0: init_word = {REG_FAN_DRIVE, 8'h4e};
            4'd1: init_word = {REG_CONFIG, 8'h2a};
            4'd2: init_word = {REG_GPIO, 8'hf5};
            4'd3: init_word = {REG_ALARM, 8'h00};
            4'd4: init_word = {REG_ALARM, 8'h00};
            4'd5: init_word = {REG_ALARM, 8'h00};
            4'd6: init_word = {REG_ALARM, 8'h0f};
            4'd7: init_word = {REG_TACH_COUNT, 8'h02};
            default: init_word = {REG_FAN_DRIVE, target_rpm_to_count(TARGET_RPM)};
        endcase
    end
endfunction

task launch_command;
    input       is_read;
    input [7:0] reg_addr;
    input [7:0] reg_data;
    input [2:0] op;
    input [3:0] next_state;
    begin
        cmd_read <= is_read;
        cmd_reg <= reg_addr;
        cmd_data <= reg_data;
        cmd_start <= 1'b1;
        active_op <= op;
        return_state <= next_state;
        state <= ST_CMD_WAIT;
    end
endtask

de10_pro_i2c_master #(
    .CLK_HZ(CLK_HZ),
    .I2C_HZ(I2C_HZ)
) u_i2c_master (
    .clk(clk),
    .reset_n(reset_n),
    .start(cmd_start),
    .read(cmd_read),
    .slave_addr(FAN_I2C_ADDR),
    .reg_addr(cmd_reg),
    .write_data(cmd_data),
    .busy(cmd_busy),
    .done(cmd_done),
    .ack_error(cmd_ack_error),
    .read_data(cmd_read_data),
    .scl(fan_i2c_scl),
    .sda(fan_i2c_sda)
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= ST_STARTUP;
        return_state <= ST_STARTUP;
        active_op <= OP_INIT;
        init_index <= 4'd0;
        wait_count <= 32'd0;
        cmd_start <= 1'b0;
        cmd_read <= 1'b0;
        cmd_reg <= 8'd0;
        cmd_data <= 8'd0;
        alert_type <= 4'd0;
        fan0_rpm <= 13'd0;
        fan1_rpm <= 13'd0;
    end else begin
        cmd_start <= 1'b0;

        case (state)
            ST_STARTUP: begin
                if (wait_count >= STARTUP_DELAY_CYCLES) begin
                    wait_count <= 32'd0;
                    init_index <= 4'd0;
                    state <= ST_INIT;
                end else begin
                    wait_count <= wait_count + 32'd1;
                end
            end

            ST_INIT: begin
                if (!cmd_busy) begin
                    launch_command(
                        1'b0,
                        current_init_word[15:8],
                        current_init_word[7:0],
                        OP_INIT,
                        (init_index == 4'd7) ? ST_SET_SPEED : ST_INIT
                    );
                end
            end

            ST_SET_SPEED: begin
                if (!cmd_busy) begin
                    launch_command(1'b0, REG_FAN_DRIVE, target_rpm_to_count(TARGET_RPM), OP_SET_SPEED, ST_WAIT);
                end
            end

            ST_WAIT: begin
                if (wait_count >= POLL_INTERVAL_CYCLES) begin
                    wait_count <= 32'd0;
                    state <= fan_alert_n ? ST_READ0 : ST_STATUS;
                end else begin
                    wait_count <= wait_count + 32'd1;
                end
            end

            ST_READ0: begin
                if (!cmd_busy) begin
                    launch_command(1'b1, REG_TACH0, 8'd0, OP_READ0, ST_READ1);
                end
            end

            ST_READ1: begin
                if (!cmd_busy) begin
                    launch_command(1'b1, REG_TACH1, 8'd0, OP_READ1, ST_WAIT);
                end
            end

            ST_STATUS: begin
                if (!cmd_busy) begin
                    launch_command(1'b1, REG_STATUS, 8'd0, OP_STATUS, ST_WAIT);
                end
            end

            ST_CMD_WAIT: begin
                if (cmd_done) begin
                    if (cmd_ack_error) begin
                        alert_type <= 4'hf;
                    end else begin
                        case (active_op)
                            OP_INIT: begin
                                if (init_index < 4'd7) begin
                                    init_index <= init_index + 4'd1;
                                end
                            end
                            OP_READ0: begin
                                fan0_rpm <= cmd_read_data * 13'd30;
                            end
                            OP_READ1: begin
                                fan1_rpm <= cmd_read_data * 13'd30;
                            end
                            OP_STATUS: begin
                                alert_type <= cmd_read_data[3:0];
                            end
                            default: begin
                            end
                        endcase
                    end
                    state <= return_state;
                end
            end

            default: begin
                state <= ST_STARTUP;
            end
        endcase
    end
end

endmodule

`default_nettype wire
