// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

module ibex_wrap
  # (
     parameter logic [31:0] ROMBase = 32'h0001_0000
     )
   (
    input logic 	clk,
    input logic 	rstn,
    input logic [31:0] 	HART_ID,

    // Instruction memory interface
    output logic 	instr_req_o,
    input logic 	instr_gnt_i,
    input logic 	instr_rvalid_i,
    output logic [31:0] instr_addr_o,
    input logic [31:0] 	instr_rdata_i,

    // Data memory interface
    output logic 	data_req_o,
    input logic 	data_gnt_i,
    input logic 	data_rvalid_i,
    output logic 	data_we_o,
    output logic [3:0] 	data_be_o,
    output logic [31:0] data_addr_o,
    output logic [31:0] data_wdata_o,
    input logic [31:0] 	data_rdata_i,

    // Interrupts
    input logic [1:0] 	irq,
    input logic 	timer_irq,
    input logic 	ipi,

    // CPU Control Signals
    output logic 	core_sleep_o
    );

   // IBEX small configuration
   // PMP
   localparam bit      IBEX_SMALL_PMPEnable                  = 0;
   localparam int      unsigned IBEX_SMALL_PMPGranularity    = 0;
   localparam int      unsigned IBEX_SMALL_PMPNumRegions     = 4;
   // Performance counters
   localparam int      unsigned IBEX_SMALL_MHPMCounterNum    = 0;
   localparam int      unsigned IBEX_SMALL_MHPMCounterWidth  = 40;
   // ISA extensions
   localparam bit      IBEX_SMALL_RV32E                      = 1'b0;
   localparam ibex_pkg::rv32m_e IBEX_SMALL_RV32M        = ibex_pkg::RV32MFast;
   localparam ibex_pkg::rv32b_e IBEX_SMALL_RV32B        = ibex_pkg::RV32BNone;
   localparam ibex_pkg::regfile_e IBEX_SMALL_RegFile    = ibex_pkg::RegFileFF;
   localparam bit      IBEX_SMALL_BranchTargetALU            = 0;
   localparam bit      IBEX_SMALL_WritebackStage             = 0;
   localparam bit      IBEX_SMALL_ICache                     = 0;
   localparam bit      IBEX_SMALL_ICacheECC                  = 0;
   localparam bit      IBEX_SMALL_BranchPredictor            = 0;

   // Using IBEX Small configuration
   ibex_core
     #(
       .PMPEnable(IBEX_SMALL_PMPEnable),
       .PMPGranularity(IBEX_SMALL_PMPGranularity),
       .PMPNumRegions(IBEX_SMALL_PMPNumRegions),
       .MHPMCounterNum(IBEX_SMALL_MHPMCounterNum),
       .MHPMCounterWidth(IBEX_SMALL_MHPMCounterWidth),
       .RV32E(IBEX_SMALL_RV32E),
       .RV32M(IBEX_SMALL_RV32M),
       .RV32B(IBEX_SMALL_RV32B),
       .RegFile(IBEX_SMALL_RegFile),
       .BranchTargetALU(IBEX_SMALL_BranchTargetALU),
       .WritebackStage(IBEX_SMALL_WritebackStage),
       .ICache(IBEX_SMALL_ICache),
       .ICacheECC(IBEX_SMALL_ICacheECC),
       .BranchPredictor(IBEX_SMALL_BranchPredictor),
       .DbgTriggerEn(1'b0),
       .DbgHwBreakNum(1),
       .SecureIbex(1'b0),
       .DmHaltAddr(32'h80001000),
       .DmExceptionAddr(32'h80000120)
       ) u_core
       (
	.clk_i                 (clk),
	.rst_ni                (rstn),

	.test_en_i             (1'b0),
	.hart_id_i             (HART_ID),

	.boot_addr_i           (ROMBase),

	.instr_req_o           (instr_req_o),
	.instr_gnt_i           (instr_gnt_i),
	.instr_rvalid_i        (instr_rvalid_i),
	.instr_addr_o          (instr_addr_o),
	.instr_rdata_i         (instr_rdata_i),
	.instr_err_i           (1'b0),

	.data_req_o            (data_req_o),
	.data_gnt_i            (data_gnt_i),
	.data_rvalid_i         (data_rvalid_i),
	.data_we_o             (data_we_o),
	.data_be_o             (data_be_o),
	.data_addr_o           (data_addr_o),
	.data_wdata_o          (data_wdata_o),
	.data_rdata_i          (data_rdata_i),
	.data_err_i            (1'b0),

	.irq_software_i        (ipi),
	.irq_timer_i           (timer_irq),
	.irq_external_i        (irq[0]), // irq[0] is Machine mode; irq[1] os Supervisor mode (not supported by IBEX)
	.irq_fast_i            (15'b0),
	.irq_nm_i              (1'b0),

	.debug_req_i           (1'b0),

	.fetch_enable_i        (1'b1),
	.alert_minor_o         (),
	.alert_major_o         (),
	.core_sleep_o          (core_sleep_o)
	);


endmodule
