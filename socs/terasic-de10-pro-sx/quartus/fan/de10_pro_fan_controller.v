// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

module de10_pro_fan_controller #(
  parameter [12:0] TARGET_RPM = 13'd2200
) (
  input  wire clk,
  input  wire reset_n,
  input  wire fan_alert_n,
  output wire fan_i2c_scl,
  inout  wire fan_i2c_sda
);

wire [12:0] fan0_speed;
wire [12:0] fan1_speed;
wire [ 3:0] alert_type;
wire        fan_control_reset_n;

Fan_Control u_fan_control (
  .CLK         (clk),
  .Speed_Set   (TARGET_RPM),
  .Alert_Clear (reset_n),
  .Alert       (fan_alert_n),
  .Alert_Type  (alert_type),
  .FAN0_Speed  (fan0_speed),
  .FAN1_Speed  (fan1_speed),
  .FAN_I2C_SCL (fan_i2c_scl),
  .FAN_I2C_SDA (fan_i2c_sda),
  .RST_N       (fan_control_reset_n)
);

endmodule
