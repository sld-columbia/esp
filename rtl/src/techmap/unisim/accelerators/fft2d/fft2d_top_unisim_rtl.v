// *****************************************************************************
//                         Cadence C-to-Silicon Compiler
//          Version 14.10-p100  (64 bit), build 50398 Tue, 27 May 2014
// 
// File created on Tue Jul 22 16:42:55 2014
// 
// The code contained herein is generated for Cadences customer and third
// parties authorized by customer.  It may be used in accordance with a
// previously executed license agreement between Cadence and that customer.
// Absolutely no disassembling, decompiling, reverse-translations or
// reverse-engineering of the generated code is allowed.
// 
//*****************************************************************************
module fft2d_top_unisim_rtl(clk, rst, rd_grant, wr_grant, conf_size, conf_log2, 
conf_batch, conf_transpose, conf_done, bufdin_valid, bufdin_data, bufdout_ready, 
rd_index, rd_length, rd_request, wr_index, wr_length, wr_request, fft2d_done, 
bufdin_ready, bufdout_valid, bufdout_data);
    input clk;
    input rst;
    input rd_grant;
    input wr_grant;
    input [31:0] conf_size;
    input [31:0] conf_log2;
    input [31:0] conf_batch;
    input conf_transpose;
    input conf_done;
    input bufdin_valid;
    input [31:0] bufdin_data;
    input bufdout_ready;
    output [31:0] rd_index;
    output [31:0] rd_length;
    output rd_request;
    output [31:0] wr_index;
    output [31:0] wr_length;
    output wr_request;
    output fft2d_done;
    output bufdin_ready;
    output bufdout_valid;
    output [31:0] bufdout_data;
    wire A0_CE0;
    wire [12:0] A0_A0;
    wire [63:0] A0_D0;
    wire A0_WE0;
    wire [1:0] A0_WEM0;
    wire A0_CE1;
    wire [12:0] A0_A1;
    wire [63:0] A0_D1;
    wire A0_WE1;
    wire [1:0] A0_WEM1;
    wire [63:0] A0_Q1;
    wire B0_CE0;
    wire [12:0] B0_A0;
    wire [63:0] B0_D0;
    wire B0_WE0;
    wire B0_CE1;
    wire [12:0] B0_A1;
    wire [63:0] B0_Q1;

    fft2d_unisim_rtl fft2d(.clk(clk), .rst(rst), .rd_grant(rd_grant), .wr_grant(
                     wr_grant), .conf_size(conf_size), .conf_log2(conf_log2), .conf_batch(
                     conf_batch), .conf_transpose(conf_transpose), .conf_done(
                     conf_done), .bufdin_valid(bufdin_valid), .bufdin_data(
                     bufdin_data), .bufdout_ready(bufdout_ready), .A0_Q1(A0_Q1), 
                     .B0_Q1(B0_Q1), .rd_index(rd_index), .rd_length(rd_length), 
                     .rd_request(rd_request), .wr_index(wr_index), .wr_length(
                     wr_length), .wr_request(wr_request), .fft2d_done(fft2d_done), 
                     .bufdin_ready(bufdin_ready), .bufdout_valid(bufdout_valid), 
                     .bufdout_data(bufdout_data), .A0_CE0(A0_CE0), .A0_A0(A0_A0), 
                     .A0_D0(A0_D0), .A0_WE0(A0_WE0), .A0_WEM0(A0_WEM0), .A0_CE1(
                     A0_CE1), .A0_A1(A0_A1), .A0_D1(A0_D1), .A0_WE1(A0_WE1), .A0_WEM1(
                     A0_WEM1), .B0_CE0(B0_CE0), .B0_A0(B0_A0), .B0_D0(B0_D0), .B0_WE0(
                     B0_WE0), .B0_CE1(B0_CE1), .B0_A1(B0_A1));
    fft2d_unisim_ram_8192x64pm32_1w_1rw A0(.CLK(clk), .CE0(A0_CE0), .A0(A0_A0), 
                                        .D0(A0_D0), .WE0(A0_WE0), .WEM0(A0_WEM0), 
                                        .CE1(A0_CE1), .A1(A0_A1), .D1(A0_D1), .WE1(
                                        A0_WE1), .WEM1(A0_WEM1), .Q1(A0_Q1));
    fft2d_unisim_ram_8192x64p_1w_1r B0(.CLK(clk), .CE0(B0_CE0), .A0(B0_A0), .D0(
                                    B0_D0), .WE0(B0_WE0), .CE1(B0_CE1), .A1(
                                    B0_A1), .Q1(B0_Q1));
endmodule


/**
 * Copyright (c) 2014, Columbia University
 *
 * @author Christian Pilato <pilato@cs.columbia.edu>
 */

module fft2d_unisim_ram_8192x64pm32_1w_1rw(CLK, CE0, A0, D0, WE0, WEM0, CE1, A1, D1, WE1, WEM1, Q1);

  parameter memSize=8192;  /* physical memory size */
  parameter selBit=4;      /* log_2(memSize/512), # of banks */

  parameter nOfBanks=(memSize/512);
  parameter bitAddress=9+selBit;

  input CLK;
  input CE0;
  input [bitAddress-1:0] A0;
  input [63 : 0] D0;
  input WE0;
  input [1 : 0] WEM0;
  input CE1;
  input [bitAddress-1:0] A1;
  input [63 : 0] D1;
  input WE1;
  input [1 : 0] WEM1;
  output[63 : 0] Q1;

  wire [nOfBanks-1:0] A_ENA_tmp;
  wire [nOfBanks-1:0] A_WEA_0_tmp;
  wire [nOfBanks-1:0] A_WEA_1_tmp;
  wire [63:0] A_DOA_temp[0:nOfBanks-1];
  wire [7:0] A_DOPA_float[0:nOfBanks-1];

  wire [nOfBanks-1:0] A_ENB_tmp;
  wire [nOfBanks-1:0] A_WEB_0_tmp;
  wire [nOfBanks-1:0] A_WEB_1_tmp;
  wire [63:0] A_DOB_temp[0:nOfBanks-1];
  wire [7:0] A_DOPB_float[0:nOfBanks-1];

  reg [selBit-1:0] sel;

  always@(posedge CLK)
  begin
     sel = A1[selBit-1:0];
  end

  assign Q1 = A_DOB_temp[sel];

  genvar i;
  generate
  for(i=0; i< nOfBanks; i=i+1) begin:bramgen

    assign A_WEA_0_tmp[i] = (WE0 && A0[selBit-1:0] == i && WEM0[0]);
    assign A_WEA_1_tmp[i] = (WE0 && A0[selBit-1:0] == i && WEM0[1]);
    assign A_ENA_tmp[i] = (CE0 && A0[selBit-1:0] == i);

    assign A_WEB_0_tmp[i] = (WE1 && A1[selBit-1:0] == i && WEM1[0]);
    assign A_WEB_1_tmp[i] = (WE1 && A1[selBit-1:0] == i && WEM1[1]);
    assign A_ENB_tmp[i] = (CE1 && A1[selBit-1:0] == i);

    RAMB16_S36_S36 b1(
      .DOA(A_DOA_temp[i][63:32]),
      .DOB(A_DOB_temp[i][63:32]),
      .DOPA(A_DOPA_float[i][7:4]),
      .DOPB(A_DOPB_float[i][7:4]),
      .ADDRA(A0[bitAddress-1:selBit]),
      .ADDRB(A1[bitAddress-1:selBit]),
      .CLKA(CLK),
      .CLKB(CLK),
      .DIA(D0[63:32]),
      .DIB(D1[63:32]),
      .DIPA(4'b0),
      .DIPB(4'b0),
      .ENA(A_ENA_tmp[i]),
      .ENB(A_ENB_tmp[i]),
      .SSRA(1'b0),
      .SSRB(1'b0),
      .WEA(A_WEA_1_tmp[i]),
      .WEB(A_WEB_1_tmp[i]));

    RAMB16_S36_S36 b0(
      .DOA(A_DOA_temp[i][31:0]),
      .DOB(A_DOB_temp[i][31:0]),
      .DOPA(A_DOPA_float[i][3:0]),
      .DOPB(A_DOPB_float[i][3:0]),
      .ADDRA(A0[bitAddress-1:selBit]),
      .ADDRB(A1[bitAddress-1:selBit]),
      .CLKA(CLK),
      .CLKB(CLK),
      .DIA(D0[31:0]),
      .DIB(D1[31:0]),
      .DIPA(4'b0),
      .DIPB(4'b0),
      .ENA(A_ENA_tmp[i]),
      .ENB(A_ENB_tmp[i]),
      .SSRA(1'b0),
      .SSRB(1'b0),
      .WEA(A_WEA_0_tmp[i]),
      .WEB(A_WEB_0_tmp[i]));

    end
    endgenerate

endmodule

/**
 * Copyright (c) 2014, Columbia University
 *
 * @author Christian Pilato <pilato@cs.columbia.edu>
 */

module fft2d_unisim_ram_8192x64p_1w_1r(CLK,
				      CE0, A0, D0, WE0,
				      CE1, A1, Q1);

  parameter memSize=8192;  /* physical memory size */
  parameter selBit=4;      /* log_2(memSize/512), # of banks */

  parameter nOfBanks=(memSize/512);
  parameter bitAddress=9+selBit;

  input CLK;

  input CE0;
  input [bitAddress-1:0] A0;
  input [63:0] D0;
  input WE0;

  input CE1;
  input [bitAddress-1:0] A1;
  output [63:0] Q1;

  wire [nOfBanks-1:0] A_ENA_tmp;
  wire [nOfBanks-1:0] A_WEA_tmp;
  wire [63:0] A_DOA_float[0:nOfBanks-1];
  wire [7:0] A_DOPA_float[0:nOfBanks-1];

  wire [nOfBanks-1:0] A_ENB_tmp;
  wire [nOfBanks-1:0] A_WEB_tmp;
  wire [63:0] A_DOB_temp[0:nOfBanks-1];
  wire [7:0] A_DOPB_float[0:nOfBanks-1];

  reg [selBit-1:0] sel;

  always@(posedge CLK)
  begin
     sel = A1[selBit-1:0];
  end

  assign Q1 = A_DOB_temp[sel];

  genvar i;
  generate
  for(i=0; i< nOfBanks; i=i+1) begin:bramgen

    assign A_WEA_tmp[i] = (WE0 && A0[selBit-1:0] == i);
    assign A_ENA_tmp[i] = (CE0 && A0[selBit-1:0] == i);

    assign A_WEB_tmp[i] = 1'b0;
    assign A_ENB_tmp[i] = (CE1 && A1[selBit-1:0] == i);

    RAMB16_S36_S36 b0(
      .DOA(A_DOA_float[i][63:32]),
      .DOB(A_DOB_temp[i][63:32]),
      .DOPA(A_DOPA_float[i][7:4]),
      .DOPB(A_DOPB_float[i][7:4]),
      .ADDRA(A0[bitAddress-1:selBit]),
      .ADDRB(A1[bitAddress-1:selBit]),
      .CLKA(CLK),
      .CLKB(CLK),
      .DIA(D0[63:32]),
      .DIB(32'b0),
      .DIPA(4'b0),
      .DIPB(4'b0),
      .ENA(A_ENA_tmp[i]),
      .ENB(A_ENB_tmp[i]),
      .SSRA(1'b0),
      .SSRB(1'b0),
      .WEA(A_WEA_tmp[i]),
      .WEB(A_WEB_tmp[i]));

    RAMB16_S36_S36 b1(
      .DOA(A_DOA_float[i][31:0]),
      .DOB(A_DOB_temp[i][31:0]),
      .DOPA(A_DOPA_float[i][3:0]),
      .DOPB(A_DOPB_float[i][3:0]),
      .ADDRA(A0[bitAddress-1:selBit]),
      .ADDRB(A1[bitAddress-1:selBit]),
      .CLKA(CLK),
      .CLKB(CLK),
      .DIA(D0[31:0]),
      .DIB(32'b0),
      .DIPA(4'b0),
      .DIPB(4'b0),
      .ENA(A_ENA_tmp[i]),
      .ENB(A_ENB_tmp[i]),
      .SSRA(1'b0),
      .SSRB(1'b0),
      .WEA(A_WEA_tmp[i]),
      .WEB(A_WEB_tmp[i]));

    end
    endgenerate

endmodule

