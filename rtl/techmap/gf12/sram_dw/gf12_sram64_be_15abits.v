//
// Created with the ESP Memory Generator
//
// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// @author Paolo Mantovani <paolo@cs.columbia.edu>
//

`timescale  1 ps / 1 ps

module gf12_sram64_be_15abits(
    CLK,
    CE0,
    A0,
    D0,
    WE0,
    WEM0,
    CE1,
    A1,
    Q1
  );
  input CLK;
  input CE0;
  input [14:0] A0;
  input [63:0] D0;
  input WE0;
  input [63:0] WEM0;
  input CE1;
  input [14:0] A1;
  output [63:0] Q1;
  genvar d, h, v, hh;

  reg               bank_CE  [0:0][0:0][3:0][0:0][0:0];
  reg        [12:0] bank_A   [0:0][0:0][3:0][0:0][0:0];
  reg        [63:0] bank_D   [0:0][0:0][3:0][0:0][0:0];
  reg               bank_WE  [0:0][0:0][3:0][0:0][0:0];
  reg        [63:0] bank_WEM [0:0][0:0][3:0][0:0][0:0];
  wire       [63:0] bank_Q   [0:0][0:0][3:0][0:0][0:0];
  wire        [0:0] ctrld    [1:1];
  wire        [0:0] ctrlh    [1:0];
  wire        [1:0] ctrlv    [1:0];
  reg         [0:0] seld     [1:1];
  reg         [0:0] selh     [1:1];
  reg         [1:0] selv     [1:1];
// synthesis translate_off
// synopsys translate_off
  integer check_bank_access [0:0][0:0][3:0][0:0][0:0];

  task check_access;
    input integer iface;
    input integer d;
    input integer h;
    input integer v;
    input integer hh;
    input integer p;
  begin
    if ((check_bank_access[d][h][v][hh][p] != -1) &&
        (check_bank_access[d][h][v][hh][p] != iface)) begin
      $display("ASSERTION FAILED in %m: port conflict on bank", h, "h", v, "v", hh, "hh", " for port", p, " involving interfaces", check_bank_access[d][h][v][hh][p], iface);
      $finish;
    end
    else begin
      check_bank_access[d][h][v][hh][p] = iface;
    end
  end
  endtask
// synopsys translate_on
// synthesis translate_on

  assign ctrld[1] = 0;
  assign ctrlh[0] = 0;
  assign ctrlh[1] = 0;
  assign ctrlv[0] = A0[14:13];
  assign ctrlv[1] = A1[14:13];

  always @(posedge CLK) begin
    seld[1] <= ctrld[1];
    selh[1] <= ctrlh[1];
    selv[1] <= ctrlv[1];
  end

  generate
  for (h = 0; h < 1; h = h + 1) begin : gen_ctrl_hbanks
    for (v = 0; v < 4; v = v + 1) begin : gen_ctrl_vbanks
      for (hh = 0; hh < 1; hh = hh + 1) begin : gen_ctrl_hhbanks

        always @(*) begin : handle_ops

// synthesis translate_off
// synopsys translate_off
          // Prevent assertions to trigger with false positive
          # 1
// synopsys translate_on
// synthesis translate_on

          /** Default **/
// synthesis translate_off
// synopsys translate_off
          check_bank_access[0][h][v][hh][0] = -1;
// synopsys translate_on
// synthesis translate_on
          bank_CE[0][h][v][hh][0]  = 0;
          bank_A[0][h][v][hh][0]   = 0;
          bank_D[0][h][v][hh][0]   = 0;
          bank_WE[0][h][v][hh][0]  = 0;
          bank_WEM[0][h][v][hh][0] = 0;

          /** Handle 1w:0r **/
          // Duplicated bank set 0
            if (ctrlh[0] == h && ctrlv[0] == v && CE0 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              // check_access(0, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE0;
                bank_A[0][h][v][hh][0]   = A0[12:0];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D0[64 * (hh + 1) - 1:64 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[64 * (hh + 1) - 1:64 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D0[63 + 64 * hh:64 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[63 + 64 * hh:64 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE0;
            end

          /** Handle 0w:1r **/
          // Always choose duplicated bank set 0
            if (ctrlh[1] == h && ctrlv[1] == v && CE1 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              // check_access(1, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE1;
                bank_A[0][h][v][hh][0]   = A1[12:0];
            end

        end

      end
    end
  end
  endgenerate

  generate
  for (hh = 0; hh < 1; hh = hh + 1) begin : gen_q_assign_hhbanks
    if (hh == 0 && (hh + 1) * 64 > 64) begin : gen_q_assign_hhbanks_last_1 
       assign Q1[63:64 * hh] = bank_Q[seld[1]][selh[1]][selv[1]][hh][0][63:0];
    end else begin : gen_q_assign_hhbanks_others_1 
      assign Q1[64 * (hh + 1) - 1:64 * hh] = bank_Q[seld[1]][selh[1]][selv[1]][hh][0];
    end
  end
  endgenerate

  generate
  for (d = 0; d < 1; d = d + 1) begin : gen_wires_dbanks
    for (h = 0; h < 1; h = h + 1) begin : gen_wires_hbanks
      for (v = 0; v < 4; v = v + 1) begin : gen_wires_vbanks
        for (hh = 0; hh < 1; hh = hh + 1) begin : gen_wires_hhbanks

          GF12_SRAM_SP_8192x64_HD bank_i(
              .CLK(CLK),
              .CE0(bank_CE[d][h][v][hh][0]),
              .A0(bank_A[d][h][v][hh][0]),
              .D0(bank_D[d][h][v][hh][0]),
              .WE0(bank_WE[d][h][v][hh][0]),
              .WEM0(bank_WEM[d][h][v][hh][0]),
              .Q0(bank_Q[d][h][v][hh][0])
            );

        end
      end
    end
  end
  endgenerate

endmodule
