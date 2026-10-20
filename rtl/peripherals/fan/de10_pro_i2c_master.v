// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module de10_pro_i2c_master #(
    parameter integer CLK_HZ = 50000000,
    parameter integer I2C_HZ = 100000
) (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       start,
    input  wire       read,
    input  wire [6:0] slave_addr,
    input  wire [7:0] reg_addr,
    input  wire [7:0] write_data,
    output reg        busy,
    output reg        done,
    output reg        ack_error,
    output reg  [7:0] read_data,
    inout  wire       scl,
    inout  wire       sda
);

localparam integer HALF_DIV_RAW = CLK_HZ / (I2C_HZ * 2);
localparam integer HALF_DIV = (HALF_DIV_RAW < 2) ? 2 : HALF_DIV_RAW;

localparam [4:0] ST_IDLE          = 5'd0;
localparam [4:0] ST_START_HIGH    = 5'd1;
localparam [4:0] ST_START_LOW     = 5'd2;
localparam [4:0] ST_SEND_LOW      = 5'd3;
localparam [4:0] ST_SEND_HIGH     = 5'd4;
localparam [4:0] ST_SEND_FALL     = 5'd5;
localparam [4:0] ST_ACK_LOW       = 5'd6;
localparam [4:0] ST_ACK_HIGH      = 5'd7;
localparam [4:0] ST_ACK_SAMPLE    = 5'd8;
localparam [4:0] ST_ACK_FALL      = 5'd9;
localparam [4:0] ST_RESTART_LOW   = 5'd10;
localparam [4:0] ST_RESTART_HIGH  = 5'd11;
localparam [4:0] ST_RESTART_START = 5'd12;
localparam [4:0] ST_RESTART_FALL  = 5'd13;
localparam [4:0] ST_READ_LOW      = 5'd14;
localparam [4:0] ST_READ_HIGH     = 5'd15;
localparam [4:0] ST_READ_SAMPLE   = 5'd16;
localparam [4:0] ST_READ_FALL     = 5'd17;
localparam [4:0] ST_NACK_LOW      = 5'd18;
localparam [4:0] ST_NACK_HIGH     = 5'd19;
localparam [4:0] ST_NACK_FALL     = 5'd20;
localparam [4:0] ST_STOP_LOW      = 5'd21;
localparam [4:0] ST_STOP_HIGH     = 5'd22;
localparam [4:0] ST_STOP_RELEASE  = 5'd23;

reg [4:0] state;
reg [2:0] bit_index;
reg [2:0] phase;
reg [7:0] tx_byte;
reg [7:0] rx_byte;
reg [7:0] latched_reg;
reg [7:0] latched_write;
reg [6:0] latched_slave;
reg       latched_read;
reg       scl_drive_low;
reg       sda_drive_low;
reg [31:0] div_count;
wire      tick;

assign scl = scl_drive_low ? 1'b0 : 1'bz;
assign sda = sda_drive_low ? 1'b0 : 1'bz;
assign tick = (div_count == HALF_DIV - 1);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        div_count <= 32'd0;
    end else if (state == ST_IDLE) begin
        div_count <= 32'd0;
    end else if (tick) begin
        div_count <= 32'd0;
    end else begin
        div_count <= div_count + 32'd1;
    end
end

task load_tx_byte;
    input [7:0] value;
    begin
        tx_byte <= value;
        bit_index <= 3'd7;
    end
endtask

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= ST_IDLE;
        bit_index <= 3'd0;
        phase <= 3'd0;
        tx_byte <= 8'd0;
        rx_byte <= 8'd0;
        read_data <= 8'd0;
        latched_reg <= 8'd0;
        latched_write <= 8'd0;
        latched_slave <= 7'd0;
        latched_read <= 1'b0;
        busy <= 1'b0;
        done <= 1'b0;
        ack_error <= 1'b0;
        scl_drive_low <= 1'b0;
        sda_drive_low <= 1'b0;
    end else begin
        done <= 1'b0;

        if (state == ST_IDLE) begin
            scl_drive_low <= 1'b0;
            sda_drive_low <= 1'b0;
            busy <= 1'b0;

            if (start) begin
                latched_reg <= reg_addr;
                latched_write <= write_data;
                latched_slave <= slave_addr;
                latched_read <= read;
                ack_error <= 1'b0;
                busy <= 1'b1;
                phase <= 3'd0;
                state <= ST_START_HIGH;
            end
        end else if (tick) begin
            case (state)
                ST_START_HIGH: begin
                    scl_drive_low <= 1'b0;
                    sda_drive_low <= 1'b1;
                    state <= ST_START_LOW;
                end

                ST_START_LOW: begin
                    scl_drive_low <= 1'b1;
                    load_tx_byte({latched_slave, 1'b0});
                    phase <= 3'd0;
                    state <= ST_SEND_LOW;
                end

                ST_SEND_LOW: begin
                    scl_drive_low <= 1'b1;
                    sda_drive_low <= ~tx_byte[bit_index];
                    state <= ST_SEND_HIGH;
                end

                ST_SEND_HIGH: begin
                    scl_drive_low <= 1'b0;
                    state <= ST_SEND_FALL;
                end

                ST_SEND_FALL: begin
                    scl_drive_low <= 1'b1;
                    if (bit_index == 3'd0) begin
                        state <= ST_ACK_LOW;
                    end else begin
                        bit_index <= bit_index - 3'd1;
                        state <= ST_SEND_LOW;
                    end
                end

                ST_ACK_LOW: begin
                    scl_drive_low <= 1'b1;
                    sda_drive_low <= 1'b0;
                    state <= ST_ACK_HIGH;
                end

                ST_ACK_HIGH: begin
                    scl_drive_low <= 1'b0;
                    state <= ST_ACK_SAMPLE;
                end

                ST_ACK_SAMPLE: begin
                    ack_error <= ack_error | sda;
                    state <= ST_ACK_FALL;
                end

                ST_ACK_FALL: begin
                    scl_drive_low <= 1'b1;
                    case (phase)
                        3'd0: begin
                            load_tx_byte(latched_reg);
                            phase <= 3'd1;
                            state <= ST_SEND_LOW;
                        end
                        3'd1: begin
                            if (latched_read) begin
                                phase <= 3'd2;
                                state <= ST_RESTART_LOW;
                            end else begin
                                load_tx_byte(latched_write);
                                phase <= 3'd4;
                                state <= ST_SEND_LOW;
                            end
                        end
                        3'd2: begin
                            phase <= 3'd3;
                            state <= ST_READ_LOW;
                        end
                        3'd4: begin
                            state <= ST_STOP_LOW;
                        end
                        default: begin
                            state <= ST_STOP_LOW;
                        end
                    endcase
                end

                ST_RESTART_LOW: begin
                    scl_drive_low <= 1'b1;
                    sda_drive_low <= 1'b0;
                    state <= ST_RESTART_HIGH;
                end

                ST_RESTART_HIGH: begin
                    scl_drive_low <= 1'b0;
                    sda_drive_low <= 1'b0;
                    state <= ST_RESTART_START;
                end

                ST_RESTART_START: begin
                    sda_drive_low <= 1'b1;
                    state <= ST_RESTART_FALL;
                end

                ST_RESTART_FALL: begin
                    scl_drive_low <= 1'b1;
                    load_tx_byte({latched_slave, 1'b1});
                    state <= ST_SEND_LOW;
                end

                ST_READ_LOW: begin
                    scl_drive_low <= 1'b1;
                    sda_drive_low <= 1'b0;
                    state <= ST_READ_HIGH;
                end

                ST_READ_HIGH: begin
                    scl_drive_low <= 1'b0;
                    state <= ST_READ_SAMPLE;
                end

                ST_READ_SAMPLE: begin
                    rx_byte[bit_index] <= sda;
                    state <= ST_READ_FALL;
                end

                ST_READ_FALL: begin
                    scl_drive_low <= 1'b1;
                    if (bit_index == 3'd0) begin
                        state <= ST_NACK_LOW;
                    end else begin
                        bit_index <= bit_index - 3'd1;
                        state <= ST_READ_LOW;
                    end
                end

                ST_NACK_LOW: begin
                    read_data <= rx_byte;
                    scl_drive_low <= 1'b1;
                    sda_drive_low <= 1'b0;
                    state <= ST_NACK_HIGH;
                end

                ST_NACK_HIGH: begin
                    scl_drive_low <= 1'b0;
                    state <= ST_NACK_FALL;
                end

                ST_NACK_FALL: begin
                    scl_drive_low <= 1'b1;
                    state <= ST_STOP_LOW;
                end

                ST_STOP_LOW: begin
                    scl_drive_low <= 1'b1;
                    sda_drive_low <= 1'b1;
                    state <= ST_STOP_HIGH;
                end

                ST_STOP_HIGH: begin
                    scl_drive_low <= 1'b0;
                    sda_drive_low <= 1'b1;
                    state <= ST_STOP_RELEASE;
                end

                ST_STOP_RELEASE: begin
                    sda_drive_low <= 1'b0;
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= ST_IDLE;
                end

                default: begin
                    state <= ST_STOP_LOW;
                end
            endcase
        end
    end
end

endmodule

`default_nettype wire
