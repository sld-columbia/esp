// Copyright 2014 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/**
 * Inferable, Synchronous Single-Port N x 64bit RAM with Byte-Wise Enable
 *
 * This module contains an implementation for either Xilinx or Altera FPGAs.  To synthesize for
 * Xilinx, define `FPGA_TARGET_XILINX`.  To synthesize for Altera, define `FPGA_TARGET_ALTERA`.  The
 * implementations follow the respective guidelines:
 * - Xilinx UG901 Vivado Design Suite User Guide: Synthesis (p. 106)
 * - Altera Quartus II Handbook Volume 1: Design and Synthesis (p. 768)
 *
 * Current Maintainers:
 * - Michael Schaffner  <schaffer@iis.ee.ethz.ch>
 */

/**
 * Adapted to ASIC SRAM wrapper L1_SRAM_SP
 */


module SyncSpRamBeNx64
  #(
  parameter ADDR_WIDTH = 10,
  parameter DATA_DEPTH = 1024, // usually 2**ADDR_WIDTH, but can be lower
  parameter OUT_REGS   = 0,    // set to 1 to enable outregs
  parameter SIM_INIT   = 0     // for simulation only, will not be synthesized
                               // 0: no init, 1: zero init, 2: random init, 3: deadbeef init
                               // note: on verilator, 2 is not supported. define the VERILATOR macro to work around.
    )(
      input logic 		   Clk_CI,
      input logic 		   Rst_RBI,
      input logic 		   CSel_SI,
      input logic 		   WrEn_SI,
      input logic [7:0] 	   BEn_SI,
      input logic [63:0] 	   WrData_DI,
      input logic [ADDR_WIDTH-1:0] Addr_DI,
      output logic [63:0] 	   RdData_DO
      );

   ////////////////////////////
    // signals, localparams
   ////////////////////////////

   // needs to be consistent with the Altera implemenation below
   localparam DATA_BYTES = 8;

   logic [DATA_BYTES*8-1:0] 	   RdData_DN;
   logic [DATA_BYTES*8-1:0] 	   RdData_DP;

   logic [DATA_BYTES*8-1:0] 	   Mem_DP[DATA_DEPTH-1:0];

   logic [DATA_BYTES*8-1:0] 	   bitmask;

   assign bitmask[7:0]   = {8{BEn_SI[0]}};
   assign bitmask[15:8]  = {8{BEn_SI[1]}};
   assign bitmask[23:16] = {8{BEn_SI[2]}};
   assign bitmask[31:24] = {8{BEn_SI[3]}};
   assign bitmask[39:32] = {8{BEn_SI[4]}};
   assign bitmask[47:40] = {8{BEn_SI[5]}};
   assign bitmask[55:48] = {8{BEn_SI[6]}};
   assign bitmask[63:56] = {8{BEn_SI[7]}};

   L1_SRAM_SP i_L1_SRAM_SP
     (
      .CLK0(Clk_CI),
      .A0(Addr_DI),
      .D0(WrData_DI),
      .Q0(RdData_DN),
      .WE0(WrEn_SI),
      .WEM0(bitmask),
      .CE0(CSel_SI)
      );

   ////////////////////////////
	// optional output regs
   ////////////////////////////

   // output regs
   generate
      if (OUT_REGS>0) begin : g_outreg
	 always_ff @(posedge Clk_CI or negedge Rst_RBI) begin
            if(Rst_RBI == 1'b0)
              begin
		 RdData_DP  <= 0;
              end
            else
              begin
		 RdData_DP  <= RdData_DN;
              end
	 end
      end
   endgenerate // g_outreg

   // output reg bypass
   generate
      if (OUT_REGS==0) begin : g_oureg_byp
	 assign RdData_DP  = RdData_DN;
      end
   endgenerate// g_oureg_byp

   assign RdData_DO = RdData_DP;

   ////////////////////////////
   // assertions
   ////////////////////////////

   // pragma translate_off
   assert property
   (@(posedge Clk_CI) (longint'(2)**longint'(ADDR_WIDTH) >= longint'(DATA_DEPTH)))
     else $error("depth out of bounds");
   // pragma translate_on

endmodule // SyncSpRamBeNx64
