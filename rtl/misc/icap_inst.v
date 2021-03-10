// Copyright (c) 2011-2021 Columbia University, System Level Design Group
//SPDX-License-Identifier: Apache-2.0 

`timescale 1 ps / 1 ps

module icap2_inst(
    input  icap_clk,
    input  icap_csib,
    input  [31:0]icap_i,
    input  icap_rdwrb,
    output icap_avail,
    output [31:0]icap_o,
    output icap_prdone,
    output icap_prerror
    );  
        
   ICAPE2 #(
      .DEVICE_ID(0'h3651093),     // Specifies the pre-programmed Device ID value to be used for simulation
                                  // purposes.
      .ICAP_WIDTH("X32"),         // Specifies the input and output data width.
      .SIM_CFG_FILE_NAME("NONE")  // Specifies the Raw Bitstream (RBT) file to be parsed by the simulation
                                  // model.
   )
  
   ICAPE2_inst (
//      .AVAIL(icap_avail),     // 1-bit output: Availability status of ICAP
      .O(icap_o),             // 32-bit output: Configuration data output bus
//      .PRDONE(icap_prdone),   // 1-bit output: Indicates completion of Partial Reconfiguration
//      .PRERROR(icap_prerror), // 1-bit output: Indicates Error during Partial Reconfiguration
      .CLK(icap_clk),         // 1-bit input: Clock input
      .CSIB(icap_csib),       // 1-bit input: Active-Low ICAP enable
      .I(icap_i),             // 32-bit input: Configuration data input bus
      .RDWRB(icap_rdwrb)      // 1-bit input: Read/Write Select input
   );

endmodule

