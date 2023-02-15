// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

module ariane_wrap
  # (
     parameter NMST = 2,
     parameter NSLV = 6,
     parameter AXI_ID_WIDTH = ariane_soc::IdWidth,
     parameter AXI_ID_WIDTH_SLV = ariane_soc::IdWidthSlave + $clog2(NMST),
     parameter AXI_ADDR_WIDTH = 64,
     parameter AXI_DATA_WIDTH = 64,
     parameter AXI_USER_WIDTH = 1,
     parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8,
     parameter USE_SPANDEX = 0,
     // Slave 0
     parameter logic [63:0] ROMBase             = 64'h0000_0000_0001_0000,
     parameter logic [63:0] ROMLength           = 64'h0000_0000_0001_0000,
     // Slave 1
     parameter logic [63:0] APBBase             = 64'h0000_0000_6000_0000,
     parameter logic [63:0] APBLength           = 64'h0000_0000_1000_0000,
     // Slave 2
     parameter logic [63:0] CLINTBase           = 64'h0000_0000_0200_0000,
     parameter logic [63:0] CLINTLength         = 64'h0000_0000_000C_0000,
     // Slave 3
     parameter logic [63:0] SLMBase             = 64'h0000_0000_0400_0000,
     parameter logic [63:0] SLMLength           = 64'h0000_0000_0400_0000,
     // Slave 4
     parameter logic [63:0] SLMDDRBase          = 64'h0000_0000_C000_0000,
     parameter logic [63:0] SLMDDRLength        = 64'h0000_0000_4000_0000,
     // Slave 5
     parameter logic [63:0] DRAMBase            = 64'h0000_0000_8000_0000,
     parameter logic [63:0] DRAMLength          = 64'h0000_0000_2000_0000,
     parameter logic [63:0] DRAMCachedLength    = 64'h0000_0000_2000_0000
     )
   (
    input logic 			clk,
    input logic 			rstn,
    input logic [63:0]                  HART_ID,
    input logic [1:0] 			irq,
    input logic 			timer_irq,
    input logic 			ipi,
    // -- ROM
    //    AW
    output logic [AXI_ID_WIDTH_SLV-1:0] rom_aw_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	rom_aw_addr,
    output logic [7:0] 			rom_aw_len,
    output logic [2:0] 			rom_aw_size,
    output logic [1:0] 			rom_aw_burst,
    output logic 			rom_aw_lock,
    output logic [3:0] 			rom_aw_cache,
    output logic [2:0] 			rom_aw_prot,
    output logic [3:0] 			rom_aw_qos,
    output logic [5:0] 			rom_aw_atop,
    output logic [3:0] 			rom_aw_region,
    output logic [AXI_USER_WIDTH-1:0] 	rom_aw_user,
    output logic 			rom_aw_valid,
    input logic 			rom_aw_ready,
    //    W
    output logic [AXI_DATA_WIDTH-1:0] 	rom_w_data,
    output logic [AXI_STRB_WIDTH-1:0] 	rom_w_strb,
    output logic 			rom_w_last,
    output logic [AXI_USER_WIDTH-1:0] 	rom_w_user,
    output logic 			rom_w_valid,
    input logic 			rom_w_ready,
    //    B
    input logic [AXI_ID_WIDTH_SLV-1:0] 	rom_b_id,
    input logic [1:0] 			rom_b_resp,
    input logic [AXI_USER_WIDTH-1:0] 	rom_b_user,
    input logic 			rom_b_valid,
    output logic 			rom_b_ready,
    //    AR
    output logic [AXI_ID_WIDTH_SLV-1:0] rom_ar_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	rom_ar_addr,
    output logic [7:0] 			rom_ar_len,
    output logic [2:0] 			rom_ar_size,
    output logic [1:0] 			rom_ar_burst,
    output logic 			rom_ar_lock,
    output logic [3:0] 			rom_ar_cache,
    output logic [2:0] 			rom_ar_prot,
    output logic [3:0] 			rom_ar_qos,
    output logic [3:0] 			rom_ar_region,
    output logic [AXI_USER_WIDTH-1:0] 	rom_ar_user,
    output logic 			rom_ar_valid,
    input logic 			rom_ar_ready,
    //    R
    input logic [AXI_ID_WIDTH_SLV-1:0] 	rom_r_id,
    input logic [AXI_DATA_WIDTH-1:0] 	rom_r_data,
    input logic [1:0] 			rom_r_resp,
    input logic 			rom_r_last,
    input logic [AXI_USER_WIDTH-1:0] 	rom_r_user,
    input logic 			rom_r_valid,
    output logic 			rom_r_ready,
    // -- DRAM
    //    AW
    output logic [AXI_ID_WIDTH_SLV-1:0] dram_aw_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	dram_aw_addr,
    output logic [7:0] 			dram_aw_len,
    output logic [2:0] 			dram_aw_size,
    output logic [1:0] 			dram_aw_burst,
    output logic 			dram_aw_lock,
    output logic [3:0] 			dram_aw_cache,
    output logic [2:0] 			dram_aw_prot,
    output logic [3:0] 			dram_aw_qos,
    output logic [5:0] 			dram_aw_atop,
    output logic [3:0] 			dram_aw_region,
    output logic [AXI_USER_WIDTH-1:0] 	dram_aw_user,
    output logic 			dram_aw_valid,
    input logic 			dram_aw_ready,
    //    W
    output logic [AXI_DATA_WIDTH-1:0] 	dram_w_data,
    output logic [AXI_STRB_WIDTH-1:0] 	dram_w_strb,
    output logic 			dram_w_last,
    output logic [AXI_USER_WIDTH-1:0] 	dram_w_user,
    output logic 			dram_w_valid,
    input logic 			dram_w_ready,
    //    B
    input logic [AXI_ID_WIDTH_SLV-1:0] 	dram_b_id,
    input logic [1:0] 			dram_b_resp,
    input logic [AXI_USER_WIDTH-1:0] 	dram_b_user,
    input logic 			dram_b_valid,
    output logic 			dram_b_ready,
    //    AR
    output logic [AXI_ID_WIDTH_SLV-1:0] dram_ar_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	dram_ar_addr,
    output logic [7:0] 			dram_ar_len,
    output logic [2:0] 			dram_ar_size,
    output logic [1:0] 			dram_ar_burst,
    output logic 			dram_ar_lock,
    output logic [3:0] 			dram_ar_cache,
    output logic [2:0] 			dram_ar_prot,
    output logic [3:0] 			dram_ar_qos,
    output logic [3:0] 			dram_ar_region,
    output logic [AXI_USER_WIDTH-1:0] 	dram_ar_user,
    output logic 			dram_ar_valid,
    input logic 			dram_ar_ready,
    //    R
    input logic [AXI_ID_WIDTH_SLV-1:0] 	dram_r_id,
    input logic [AXI_DATA_WIDTH-1:0] 	dram_r_data,
    input logic [1:0] 			dram_r_resp,
    input logic 			dram_r_last,
    input logic [AXI_USER_WIDTH-1:0] 	dram_r_user,
    input logic 			dram_r_valid,
    output logic 			dram_r_ready,
    //   AC
    input logic [AXI_ADDR_WIDTH-1:0] dram_ac_addr,
    input logic [2:0]                dram_ac_prot,
    input logic [3:0]                dram_ac_snoop,
    input logic                      dram_ac_valid,
    output logic                     dram_ac_ready,
    // -- CLINT
    //    AW
    output logic [AXI_ID_WIDTH_SLV-1:0] clint_aw_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	clint_aw_addr,
    output logic [7:0] 			clint_aw_len,
    output logic [2:0] 			clint_aw_size,
    output logic [1:0] 			clint_aw_burst,
    output logic 			clint_aw_lock,
    output logic [3:0] 			clint_aw_cache,
    output logic [2:0] 			clint_aw_prot,
    output logic [3:0] 			clint_aw_qos,
    output logic [5:0] 			clint_aw_atop,
    output logic [3:0] 			clint_aw_region,
    output logic [AXI_USER_WIDTH-1:0] 	clint_aw_user,
    output logic 			clint_aw_valid,
    input logic 			clint_aw_ready,
    //    W
    output logic [AXI_DATA_WIDTH-1:0] 	clint_w_data,
    output logic [AXI_STRB_WIDTH-1:0] 	clint_w_strb,
    output logic 			clint_w_last,
    output logic [AXI_USER_WIDTH-1:0] 	clint_w_user,
    output logic 			clint_w_valid,
    input logic 			clint_w_ready,
    //    B
    input logic [AXI_ID_WIDTH_SLV-1:0] 	clint_b_id,
    input logic [1:0] 			clint_b_resp,
    input logic [AXI_USER_WIDTH-1:0] 	clint_b_user,
    input logic 			clint_b_valid,
    output logic 			clint_b_ready,
    //    AR
    output logic [AXI_ID_WIDTH_SLV-1:0] clint_ar_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	clint_ar_addr,
    output logic [7:0] 			clint_ar_len,
    output logic [2:0] 			clint_ar_size,
    output logic [1:0] 			clint_ar_burst,
    output logic 			clint_ar_lock,
    output logic [3:0] 			clint_ar_cache,
    output logic [2:0] 			clint_ar_prot,
    output logic [3:0] 			clint_ar_qos,
    output logic [3:0] 			clint_ar_region,
    output logic [AXI_USER_WIDTH-1:0] 	clint_ar_user,
    output logic 			clint_ar_valid,
    input logic 			clint_ar_ready,
    //    R
    input logic [AXI_ID_WIDTH_SLV-1:0] 	clint_r_id,
    input logic [AXI_DATA_WIDTH-1:0] 	clint_r_data,
    input logic [1:0] 			clint_r_resp,
    input logic 			clint_r_last,
    input logic [AXI_USER_WIDTH-1:0] 	clint_r_user,
    input logic 			clint_r_valid,
    output logic 			clint_r_ready,
    // -- SLM
    //    AW
    output logic [AXI_ID_WIDTH_SLV-1:0] slm_aw_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	slm_aw_addr,
    output logic [7:0] 			slm_aw_len,
    output logic [2:0] 			slm_aw_size,
    output logic [1:0] 			slm_aw_burst,
    output logic 			slm_aw_lock,
    output logic [3:0] 			slm_aw_cache,
    output logic [2:0] 			slm_aw_prot,
    output logic [3:0] 			slm_aw_qos,
    output logic [5:0] 			slm_aw_atop,
    output logic [3:0] 			slm_aw_region,
    output logic [AXI_USER_WIDTH-1:0] 	slm_aw_user,
    output logic 			slm_aw_valid,
    input logic 			slm_aw_ready,
    //    W
    output logic [AXI_DATA_WIDTH-1:0] 	slm_w_data,
    output logic [AXI_STRB_WIDTH-1:0] 	slm_w_strb,
    output logic 			slm_w_last,
    output logic [AXI_USER_WIDTH-1:0] 	slm_w_user,
    output logic 			slm_w_valid,
    input logic 			slm_w_ready,
    //    B
    input logic [AXI_ID_WIDTH_SLV-1:0] 	slm_b_id,
    input logic [1:0] 			slm_b_resp,
    input logic [AXI_USER_WIDTH-1:0] 	slm_b_user,
    input logic 			slm_b_valid,
    output logic 			slm_b_ready,
    //    AR
    output logic [AXI_ID_WIDTH_SLV-1:0] slm_ar_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	slm_ar_addr,
    output logic [7:0] 			slm_ar_len,
    output logic [2:0] 			slm_ar_size,
    output logic [1:0] 			slm_ar_burst,
    output logic 			slm_ar_lock,
    output logic [3:0] 			slm_ar_cache,
    output logic [2:0] 			slm_ar_prot,
    output logic [3:0] 			slm_ar_qos,
    output logic [3:0] 			slm_ar_region,
    output logic [AXI_USER_WIDTH-1:0] 	slm_ar_user,
    output logic 			slm_ar_valid,
    input logic 			slm_ar_ready,
    //    R
    input logic [AXI_ID_WIDTH_SLV-1:0] 	slm_r_id,
    input logic [AXI_DATA_WIDTH-1:0] 	slm_r_data,
    input logic [1:0] 			slm_r_resp,
    input logic 			slm_r_last,
    input logic [AXI_USER_WIDTH-1:0] 	slm_r_user,
    input logic 			slm_r_valid,
    output logic 			slm_r_ready,
    // -- SLMDDR
    //    AW
    output logic [AXI_ID_WIDTH_SLV-1:0] slmddr_aw_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	slmddr_aw_addr,
    output logic [7:0] 			slmddr_aw_len,
    output logic [2:0] 			slmddr_aw_size,
    output logic [1:0] 			slmddr_aw_burst,
    output logic 			slmddr_aw_lock,
    output logic [3:0] 			slmddr_aw_cache,
    output logic [2:0] 			slmddr_aw_prot,
    output logic [3:0] 			slmddr_aw_qos,
    output logic [5:0] 			slmddr_aw_atop,
    output logic [3:0] 			slmddr_aw_region,
    output logic [AXI_USER_WIDTH-1:0] 	slmddr_aw_user,
    output logic 			slmddr_aw_valid,
    input logic 			slmddr_aw_ready,
    //    W
    output logic [AXI_DATA_WIDTH-1:0] 	slmddr_w_data,
    output logic [AXI_STRB_WIDTH-1:0] 	slmddr_w_strb,
    output logic 			slmddr_w_last,
    output logic [AXI_USER_WIDTH-1:0] 	slmddr_w_user,
    output logic 			slmddr_w_valid,
    input logic 			slmddr_w_ready,
    //    B
    input logic [AXI_ID_WIDTH_SLV-1:0] 	slmddr_b_id,
    input logic [1:0] 			slmddr_b_resp,
    input logic [AXI_USER_WIDTH-1:0] 	slmddr_b_user,
    input logic 			slmddr_b_valid,
    output logic 			slmddr_b_ready,
    //    AR
    output logic [AXI_ID_WIDTH_SLV-1:0] slmddr_ar_id,
    output logic [AXI_ADDR_WIDTH-1:0] 	slmddr_ar_addr,
    output logic [7:0] 			slmddr_ar_len,
    output logic [2:0] 			slmddr_ar_size,
    output logic [1:0] 			slmddr_ar_burst,
    output logic 			slmddr_ar_lock,
    output logic [3:0] 			slmddr_ar_cache,
    output logic [2:0] 			slmddr_ar_prot,
    output logic [3:0] 			slmddr_ar_qos,
    output logic [3:0] 			slmddr_ar_region,
    output logic [AXI_USER_WIDTH-1:0] 	slmddr_ar_user,
    output logic 			slmddr_ar_valid,
    input logic 			slmddr_ar_ready,
    //    R
    input logic [AXI_ID_WIDTH_SLV-1:0] 	slmddr_r_id,
    input logic [AXI_DATA_WIDTH-1:0] 	slmddr_r_data,
    input logic [1:0] 			slmddr_r_resp,
    input logic 			slmddr_r_last,
    input logic [AXI_USER_WIDTH-1:0] 	slmddr_r_user,
    input logic 			slmddr_r_valid,
    output logic 			slmddr_r_ready,
    // APB
    output logic 			penable,
    output logic 			pwrite,
    output logic [31:0] 		paddr,
    output logic 			psel,
    output logic [31:0] 		pwdata,
    input logic [31:0] 			prdata,
    input logic 			pready,
    input logic 			pslverr,
    // fence indication to l2
    output logic [1:0]			fence_l2,
    input logic                 flush_l1,
    output logic                flush_done
    );

   // Base addresses for Ariane
  localparam ariane_pkg::ariane_cfg_t ArianeSocCfg = '{
    RASDepth: 2,
    BTBEntries: 32,
    BHTEntries: 128,
    // idempotent region
    NrNonIdempotentRules:  1,
    NonIdempotentAddrBase: {64'b0},
    NonIdempotentLength:   {DRAMBase},
    NrExecuteRegionRules:  2,
    ExecuteRegionAddrBase: {DRAMBase,   ROMBase},
    ExecuteRegionLength:   {DRAMCachedLength, ROMLength},
    // cached region
    NrCachedRegionRules:    1,
    CachedRegionAddrBase:  {DRAMBase},
    CachedRegionLength:    {DRAMCachedLength},
    //  cache config
    Axi64BitCompliant:      1'b1,
    SwapEndianess:          1'b0,
    // debug
    DmBaseAddress:          64'd0
  };

   // TODO: move this to I/O tile and socmap CFG_NCPUTILE
   localparam NHARTS = 1;

   typedef enum int unsigned {
      ROM      = 0,
      APB      = 1,
      CLINT    = 2,
      SLM      = 3,
      SLMDDR   = 4,
      DRAM     = 5
   } axi_slaves_t;

   AXI_BUS
     #(
       .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH   ),
       .AXI_DATA_WIDTH ( AXI_DATA_WIDTH     ),
       .AXI_ID_WIDTH   ( AXI_ID_WIDTH ),
       .AXI_USER_WIDTH ( AXI_USER_WIDTH     )
       ) slave[NMST-1:0]();

   AXI_BUS
     #(
       .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH     ),
       .AXI_DATA_WIDTH ( AXI_DATA_WIDTH     ),
       .AXI_ID_WIDTH   ( AXI_ID_WIDTH_SLV ),
       .AXI_USER_WIDTH ( AXI_USER_WIDTH     )
       ) master[NSLV-1:0]();

   assign slave[1].aw_valid = 1'b0;
   assign slave[1].w_valid = 1'b0;
   assign slave[1].ar_valid = 1'b0;
   assign slave[1].r_ready = 1'b1;
   assign slave[1].b_ready = 1'b1;

   // ---------------
   // AXI Xbar
   // ---------------
   axi_node_wrap_with_slices
     #(
       .NB_SLAVE           ( NMST   ),
       .NB_MASTER          ( NSLV   ),
       .NB_REGION          ( 1                ),
       .AXI_ADDR_WIDTH     ( AXI_ADDR_WIDTH     ),
       .AXI_DATA_WIDTH     ( AXI_DATA_WIDTH     ),
       .AXI_USER_WIDTH     ( AXI_USER_WIDTH     ),
       .AXI_ID_WIDTH       ( AXI_ID_WIDTH ),
       .MASTER_SLICE_DEPTH ( 2                ),
       .SLAVE_SLICE_DEPTH  ( 2                )
       ) i_axi_xbar
       (
	.clk          ( clk     ),
	.rst_n        ( rstn    ),
	.test_en_i    ( 1'b0    ),
	.slave        ( slave   ),
	.master       ( master  ),
	.start_addr_i ({
			DRAMBase[AXI_ADDR_WIDTH-1:0],
			SLMDDRBase[AXI_ADDR_WIDTH-1:0],
			SLMBase[AXI_ADDR_WIDTH-1:0],
			CLINTBase[AXI_ADDR_WIDTH-1:0],
			APBBase[AXI_ADDR_WIDTH-1:0],
			ROMBase[AXI_ADDR_WIDTH-1:0]
			}),
	.end_addr_i   ({
			DRAMBase[AXI_ADDR_WIDTH-1:0]  + DRAMLength[AXI_ADDR_WIDTH-1:0] - 1,
			SLMDDRBase[AXI_ADDR_WIDTH-1:0] + SLMDDRLength[AXI_ADDR_WIDTH-1:0] - 1,
			SLMBase[AXI_ADDR_WIDTH-1:0]   + SLMLength[AXI_ADDR_WIDTH-1:0] - 1,
			CLINTBase[AXI_ADDR_WIDTH-1:0] + CLINTLength[AXI_ADDR_WIDTH-1:0] - 1,
			APBBase[AXI_ADDR_WIDTH-1:0]   + APBLength[AXI_ADDR_WIDTH-1:0] - 1,
			ROMBase[AXI_ADDR_WIDTH-1:0]   + ROMLength[AXI_ADDR_WIDTH-1:0] - 1
			}),
	.valid_rule_i ({{NSLV}{1'b1}})
	);

   // ---------------
   // Core
   // ---------------

   ariane_axi::req_t           axi_ariane_req;
   ariane_axi::resp_t          axi_ariane_resp;
   ariane_axi::snoop_req_t     ace_req;
   ariane_axi::snoop_resp_t    ace_resp;

   ariane
     #(
       .ArianeCfg ( ArianeSocCfg )
       ) i_ariane
       (
    .clk_i        ( clk                 ),
    .rst_ni       ( rstn                ),
    .boot_addr_i  ( ROMBase             ),
    .hart_id_i    ( HART_ID             ),
    .irq_i        ( irq                 ),
    .ipi_i        ( ipi                 ),
    .time_irq_i   ( timer_irq           ),
    .debug_req_i  ( 1'b0                ),
    .axi_req_o    ( axi_ariane_req      ),
    .axi_resp_i   ( axi_ariane_resp     ),
    .ace_req_i    ( ace_req             ),
    .ace_resp_o   ( ace_resp            ),
    .fence_l2_o   ( fence_l2            ),
    .flush_l1_i   ( flush_l1            ),
    .flush_done_o ( flush_done          )
    );

   axi_master_connect i_axi_master_connect_ariane (.axi_req_i(axi_ariane_req), .axi_resp_o(axi_ariane_resp), .master(slave[0]));


   // ---------------
   // ROM
   // ---------------
   //    AW
   assign rom_aw_id = master[ROM].aw_id;
   assign rom_aw_addr = master[ROM].aw_addr;
   assign rom_aw_len = master[ROM].aw_len;
   assign rom_aw_size = master[ROM].aw_size;
   assign rom_aw_burst = master[ROM].aw_burst;
   assign rom_aw_lock = master[ROM].aw_lock;
   assign rom_aw_cache = master[ROM].aw_cache;
   assign rom_aw_prot = master[ROM].aw_prot;
   assign rom_aw_qos = master[ROM].aw_qos;
   assign rom_aw_atop = master[ROM].aw_atop;
   assign rom_aw_region = master[ROM].aw_region;
   assign rom_aw_user = master[ROM].aw_user;
   assign rom_aw_valid = master[ROM].aw_valid;
   assign master[ROM].aw_ready = rom_aw_ready;
   //    W
   assign rom_w_data = master[ROM].w_data;
   assign rom_w_strb = master[ROM].w_strb;
   assign rom_w_last = master[ROM].w_last;
   assign rom_w_user = master[ROM].w_user;
   assign rom_w_valid = master[ROM].w_valid;
   assign master[ROM].w_ready = rom_w_ready;
   //    B
   assign master[ROM].b_id = rom_b_id;
   assign master[ROM].b_resp = rom_b_resp;
   assign master[ROM].b_user = rom_b_user;
   assign master[ROM].b_valid = rom_b_valid;
   assign rom_b_ready = master[ROM].b_ready;
   //    AR
   assign rom_ar_id = master[ROM].ar_id;
   assign rom_ar_addr = master[ROM].ar_addr;
   assign rom_ar_len = master[ROM].ar_len;
   assign rom_ar_size = master[ROM].ar_size;
   assign rom_ar_burst = master[ROM].ar_burst;
   assign rom_ar_lock = master[ROM].ar_lock;
   assign rom_ar_cache = master[ROM].ar_cache;
   assign rom_ar_prot = master[ROM].ar_prot;
   assign rom_ar_qos = master[ROM].ar_qos;
   assign rom_ar_region = master[ROM].ar_region;
   assign rom_ar_user = master[ROM].ar_user;
   assign rom_ar_valid = master[ROM].ar_valid;
   assign master[ROM].ar_ready = rom_ar_ready;
   //    R
   assign master[ROM].r_id = rom_r_id;
   assign master[ROM].r_data = rom_r_data;
   assign master[ROM].r_resp = rom_r_resp;
   assign master[ROM].r_last = rom_r_last;
   assign master[ROM].r_user = rom_r_user;
   assign master[ROM].r_valid = rom_r_valid;
   assign rom_r_ready = master[ROM].r_ready;

   // ---------------
   // APB
   // ---------------
   axi2apb_64_32
     #(
       .AXI4_ADDRESS_WIDTH ( AXI_ADDR_WIDTH   ),
       .AXI4_RDATA_WIDTH   ( AXI_DATA_WIDTH   ),
       .AXI4_WDATA_WIDTH   ( AXI_DATA_WIDTH   ),
       .AXI4_ID_WIDTH      ( AXI_ID_WIDTH_SLV ),
       .AXI4_USER_WIDTH    ( AXI_USER_WIDTH   ),
       .BUFF_DEPTH_SLAVE   ( 2                ),
       .APB_ADDR_WIDTH     ( 32               )
       ) i_axi2apb_64_32_bridge
       (
        .ACLK      ( clk                   ),
        .ARESETn   ( rstn                  ),
        .test_en_i ( 1'b0                  ),
        .AWID_i    ( master[APB].aw_id     ),
        .AWADDR_i  ( master[APB].aw_addr   ),
        .AWLEN_i   ( master[APB].aw_len    ),
        .AWSIZE_i  ( master[APB].aw_size   ),
        .AWBURST_i ( master[APB].aw_burst  ),
        .AWLOCK_i  ( master[APB].aw_lock   ),
        .AWCACHE_i ( master[APB].aw_cache  ),
        .AWPROT_i  ( master[APB].aw_prot   ),
        .AWREGION_i( master[APB].aw_region ),
        .AWUSER_i  ( master[APB].aw_user   ),
        .AWQOS_i   ( master[APB].aw_qos    ),
        .AWVALID_i ( master[APB].aw_valid  ),
        .AWREADY_o ( master[APB].aw_ready  ),
        .WDATA_i   ( master[APB].w_data    ),
        .WSTRB_i   ( master[APB].w_strb    ),
        .WLAST_i   ( master[APB].w_last    ),
        .WUSER_i   ( master[APB].w_user    ),
        .WVALID_i  ( master[APB].w_valid   ),
        .WREADY_o  ( master[APB].w_ready   ),
        .BID_o     ( master[APB].b_id      ),
        .BRESP_o   ( master[APB].b_resp    ),
        .BVALID_o  ( master[APB].b_valid   ),
        .BUSER_o   ( master[APB].b_user    ),
        .BREADY_i  ( master[APB].b_ready   ),
        .ARID_i    ( master[APB].ar_id     ),
        .ARADDR_i  ( master[APB].ar_addr   ),
        .ARLEN_i   ( master[APB].ar_len    ),
        .ARSIZE_i  ( master[APB].ar_size   ),
        .ARBURST_i ( master[APB].ar_burst  ),
        .ARLOCK_i  ( master[APB].ar_lock   ),
        .ARCACHE_i ( master[APB].ar_cache  ),
        .ARPROT_i  ( master[APB].ar_prot   ),
        .ARREGION_i( master[APB].ar_region ),
        .ARUSER_i  ( master[APB].ar_user   ),
        .ARQOS_i   ( master[APB].ar_qos    ),
        .ARVALID_i ( master[APB].ar_valid  ),
        .ARREADY_o ( master[APB].ar_ready  ),
        .RID_o     ( master[APB].r_id      ),
        .RDATA_o   ( master[APB].r_data    ),
        .RRESP_o   ( master[APB].r_resp    ),
        .RLAST_o   ( master[APB].r_last    ),
        .RUSER_o   ( master[APB].r_user    ),
        .RVALID_o  ( master[APB].r_valid   ),
        .RREADY_i  ( master[APB].r_ready   ),
        .PENABLE   ( penable   ),
        .PWRITE    ( pwrite    ),
        .PADDR     ( paddr     ),
        .PSEL      ( psel      ),
        .PWDATA    ( pwdata    ),
        .PRDATA    ( prdata    ),
        .PREADY    ( pready    ),
        .PSLVERR   ( pslverr   )
	);



   // ---------------
   // CLINT
   // ---------------
   //    AW
   AXI_BUS
     #(
       .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH   ),
       .AXI_DATA_WIDTH ( AXI_DATA_WIDTH   ),
       .AXI_ID_WIDTH   ( AXI_ID_WIDTH_SLV ),
       .AXI_USER_WIDTH ( AXI_USER_WIDTH   )
       ) clint();

   axi_riscv_atomics_wrap
          #(
            .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH   ),
            .AXI_DATA_WIDTH ( AXI_DATA_WIDTH   ),
            .AXI_ID_WIDTH   ( AXI_ID_WIDTH_SLV ),
            .AXI_USER_WIDTH ( AXI_USER_WIDTH   ),
            .AXI_MAX_WRITE_TXNS ( 1  ),
            .RISCV_WORD_WIDTH   ( 64 )
            ) i_axi_riscv_atomics
            (
             .clk_i  ( clk          ),
             .rst_ni ( rstn         ),
             .slv    ( master[CLINT] ),
             .mst    ( clint         )
             );

   assign clint_aw_id = clint.aw_id;
   assign clint_aw_addr = clint.aw_addr;
   assign clint_aw_len = clint.aw_len;
   assign clint_aw_size = clint.aw_size;
   assign clint_aw_burst = clint.aw_burst;
   assign clint_aw_lock = clint.aw_lock;
   assign clint_aw_cache = clint.aw_cache;
   assign clint_aw_prot = clint.aw_prot;
   assign clint_aw_qos = clint.aw_qos;
   assign clint_aw_atop = clint.aw_atop;
   assign clint_aw_region = clint.aw_region;
   assign clint_aw_user = clint.aw_user;
   assign clint_aw_valid = clint.aw_valid;
   assign clint.aw_ready = clint_aw_ready;
   //    W
   assign clint_w_data = clint.w_data;
   assign clint_w_strb = clint.w_strb;
   assign clint_w_last = clint.w_last;
   assign clint_w_user = clint.w_user;
   assign clint_w_valid = clint.w_valid;
   assign clint.w_ready = clint_w_ready;
   //    B
   assign clint.b_id = clint_b_id;
   assign clint.b_resp = 2'b01;
   assign clint.b_user = clint_b_user;
   assign clint.b_valid = clint_b_valid;
   assign clint_b_ready = clint.b_ready;
   //    AR
   assign clint_ar_id = clint.ar_id;
   assign clint_ar_addr = clint.ar_addr;
   assign clint_ar_len = clint.ar_len;
   assign clint_ar_size = clint.ar_size;
   assign clint_ar_burst = clint.ar_burst;
   assign clint_ar_lock = clint.ar_lock;
   assign clint_ar_cache = clint.ar_cache;
   assign clint_ar_prot = clint.ar_prot;
   assign clint_ar_qos = clint.ar_qos;
   assign clint_ar_region = clint.ar_region;
   assign clint_ar_user = clint.ar_user;
   assign clint_ar_valid = clint.ar_valid;
   assign clint.ar_ready = clint_ar_ready;
   //    R
   assign clint.r_id = clint_r_id;
   assign clint.r_data = clint_r_data;
   assign clint.r_resp = clint_r_resp;
   assign clint.r_last = clint_r_last;
   assign clint.r_user = clint_r_user;
   assign clint.r_valid = clint_r_valid;
   assign clint_r_ready = clint.r_ready;


   // ---------------
   // SLM
   // ---------------
   //    AW
   assign slm_aw_id = master[SLM].aw_id;
   assign slm_aw_addr = master[SLM].aw_addr;
   assign slm_aw_len = master[SLM].aw_len;
   assign slm_aw_size = master[SLM].aw_size;
   assign slm_aw_burst = master[SLM].aw_burst;
   assign slm_aw_lock = master[SLM].aw_lock;
   assign slm_aw_cache = master[SLM].aw_cache;
   assign slm_aw_prot = master[SLM].aw_prot;
   assign slm_aw_qos = master[SLM].aw_qos;
   assign slm_aw_atop = master[SLM].aw_atop;
   assign slm_aw_region = master[SLM].aw_region;
   assign slm_aw_user = master[SLM].aw_user;
   assign slm_aw_valid = master[SLM].aw_valid;
   assign master[SLM].aw_ready = slm_aw_ready;
   //    W
   assign slm_w_data = master[SLM].w_data;
   assign slm_w_strb = master[SLM].w_strb;
   assign slm_w_last = master[SLM].w_last;
   assign slm_w_user = master[SLM].w_user;
   assign slm_w_valid = master[SLM].w_valid;
   assign master[SLM].w_ready = slm_w_ready;
   //    B
   assign master[SLM].b_id = slm_b_id;
   assign master[SLM].b_resp = slm_b_resp;
   assign master[SLM].b_user = slm_b_user;
   assign master[SLM].b_valid = slm_b_valid;
   assign slm_b_ready = master[SLM].b_ready;
   //    AR
   assign slm_ar_id = master[SLM].ar_id;
   assign slm_ar_addr = master[SLM].ar_addr;
   assign slm_ar_len = master[SLM].ar_len;
   assign slm_ar_size = master[SLM].ar_size;
   assign slm_ar_burst = master[SLM].ar_burst;
   assign slm_ar_lock = master[SLM].ar_lock;
   assign slm_ar_cache = master[SLM].ar_cache;
   assign slm_ar_prot = master[SLM].ar_prot;
   assign slm_ar_qos = master[SLM].ar_qos;
   assign slm_ar_region = master[SLM].ar_region;
   assign slm_ar_user = master[SLM].ar_user;
   assign slm_ar_valid = master[SLM].ar_valid;
   assign master[SLM].ar_ready = slm_ar_ready;
   //    R
   assign master[SLM].r_id = slm_r_id;
   assign master[SLM].r_data = slm_r_data;
   assign master[SLM].r_resp = slm_r_resp;
   assign master[SLM].r_last = slm_r_last;
   assign master[SLM].r_user = slm_r_user;
   assign master[SLM].r_valid = slm_r_valid;
   assign slm_r_ready = master[SLM].r_ready;

   // ---------------
   // SLMDDR
   // ---------------
   //    AW
   assign slmddr_aw_id = master[SLMDDR].aw_id;
   assign slmddr_aw_addr = master[SLMDDR].aw_addr;
   assign slmddr_aw_len = master[SLMDDR].aw_len;
   assign slmddr_aw_size = master[SLMDDR].aw_size;
   assign slmddr_aw_burst = master[SLMDDR].aw_burst;
   assign slmddr_aw_lock = master[SLMDDR].aw_lock;
   assign slmddr_aw_cache = master[SLMDDR].aw_cache;
   assign slmddr_aw_prot = master[SLMDDR].aw_prot;
   assign slmddr_aw_qos = master[SLMDDR].aw_qos;
   assign slmddr_aw_atop = master[SLMDDR].aw_atop;
   assign slmddr_aw_region = master[SLMDDR].aw_region;
   assign slmddr_aw_user = master[SLMDDR].aw_user;
   assign slmddr_aw_valid = master[SLMDDR].aw_valid;
   assign master[SLMDDR].aw_ready = slmddr_aw_ready;
   //    W
   assign slmddr_w_data = master[SLMDDR].w_data;
   assign slmddr_w_strb = master[SLMDDR].w_strb;
   assign slmddr_w_last = master[SLMDDR].w_last;
   assign slmddr_w_user = master[SLMDDR].w_user;
   assign slmddr_w_valid = master[SLMDDR].w_valid;
   assign master[SLMDDR].w_ready = slmddr_w_ready;
   //    B
   assign master[SLMDDR].b_id = slmddr_b_id;
   assign master[SLMDDR].b_resp = slmddr_b_resp;
   assign master[SLMDDR].b_user = slmddr_b_user;
   assign master[SLMDDR].b_valid = slmddr_b_valid;
   assign slmddr_b_ready = master[SLMDDR].b_ready;
   //    AR
   assign slmddr_ar_id = master[SLMDDR].ar_id;
   assign slmddr_ar_addr = master[SLMDDR].ar_addr;
   assign slmddr_ar_len = master[SLMDDR].ar_len;
   assign slmddr_ar_size = master[SLMDDR].ar_size;
   assign slmddr_ar_burst = master[SLMDDR].ar_burst;
   assign slmddr_ar_lock = master[SLMDDR].ar_lock;
   assign slmddr_ar_cache = master[SLMDDR].ar_cache;
   assign slmddr_ar_prot = master[SLMDDR].ar_prot;
   assign slmddr_ar_qos = master[SLMDDR].ar_qos;
   assign slmddr_ar_region = master[SLMDDR].ar_region;
   assign slmddr_ar_user = master[SLMDDR].ar_user;
   assign slmddr_ar_valid = master[SLMDDR].ar_valid;
   assign master[SLMDDR].ar_ready = slmddr_ar_ready;
   //    R
   assign master[SLMDDR].r_id = slmddr_r_id;
   assign master[SLMDDR].r_data = slmddr_r_data;
   assign master[SLMDDR].r_resp = slmddr_r_resp;
   assign master[SLMDDR].r_last = slmddr_r_last;
   assign master[SLMDDR].r_user = slmddr_r_user;
   assign master[SLMDDR].r_valid = slmddr_r_valid;
   assign slmddr_r_ready = master[SLMDDR].r_ready;


   // ---------------
   // Memory
   // ---------------
   AXI_BUS
     #(
       .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH   ),
       .AXI_DATA_WIDTH ( AXI_DATA_WIDTH   ),
       .AXI_ID_WIDTH   ( AXI_ID_WIDTH_SLV ),
       .AXI_USER_WIDTH ( AXI_USER_WIDTH   )
       ) dram();

   generate
     if (USE_SPANDEX) begin : axi_riscv_lrsc_gen
        axi_riscv_lrsc_wrap
          #(
            .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH   ),
            .AXI_DATA_WIDTH ( AXI_DATA_WIDTH   ),
            .AXI_ID_WIDTH   ( AXI_ID_WIDTH_SLV ),
            .AXI_USER_WIDTH ( AXI_USER_WIDTH   )
            ) i_axi_riscv_lrsc
            (
             .clk_i  ( clk          ),
             .rst_ni ( rstn         ),
             .slv    ( master[DRAM] ),
             .mst    ( dram         )
             );
     end // block: axi_riscv_lrsc_gen
     else begin : axi_riscv_atomics_gen
        axi_riscv_atomics_wrap
          #(
            .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH   ),
            .AXI_DATA_WIDTH ( AXI_DATA_WIDTH   ),
            .AXI_ID_WIDTH   ( AXI_ID_WIDTH_SLV ),
            .AXI_USER_WIDTH ( AXI_USER_WIDTH   ),
            .AXI_MAX_WRITE_TXNS ( 1  ),
            .RISCV_WORD_WIDTH   ( 64 )
            ) i_axi_riscv_atomics
            (
             .clk_i  ( clk          ),
             .rst_ni ( rstn         ),
             .slv    ( master[DRAM] ),
             .mst    ( dram         )
             );
     end // block: axi_riscv_atomics_gen
   endgenerate


   //    AW
   assign dram_aw_id = dram.aw_id;
   assign dram_aw_addr = dram.aw_addr;
   assign dram_aw_len = dram.aw_len;
   assign dram_aw_size = dram.aw_size;
   assign dram_aw_burst = dram.aw_burst;
   assign dram_aw_lock = dram.aw_lock;
   assign dram_aw_cache = dram.aw_cache;
   assign dram_aw_prot = dram.aw_prot;
   assign dram_aw_qos = dram.aw_qos;
   assign dram_aw_atop = dram.aw_atop;
   assign dram_aw_region = dram.aw_region;
   assign dram_aw_user = dram.aw_user;
   assign dram_aw_valid = dram.aw_valid;
   assign dram.aw_ready = dram_aw_ready;
   //    W
   assign dram_w_data = dram.w_data;
   assign dram_w_strb = dram.w_strb;
   assign dram_w_last = dram.w_last;
   assign dram_w_user = dram.w_user;
   assign dram_w_valid = dram.w_valid;
   assign dram.w_ready = dram_w_ready;
   //    B
   assign dram.b_id = dram_b_id;
   assign dram.b_resp = dram_b_resp;
   assign dram.b_user = dram_b_user;
   assign dram.b_valid = dram_b_valid;
   assign dram_b_ready = dram.b_ready;
   //    AR
   assign dram_ar_id = dram.ar_id;
   assign dram_ar_addr = dram.ar_addr;
   assign dram_ar_len = dram.ar_len;
   assign dram_ar_size = dram.ar_size;
   assign dram_ar_burst = dram.ar_burst;
   assign dram_ar_lock = dram.ar_lock;
   assign dram_ar_cache = dram.ar_cache;
   assign dram_ar_prot = dram.ar_prot;
   assign dram_ar_qos = dram.ar_qos;
   assign dram_ar_region = dram.ar_region;
   assign dram_ar_user = dram.ar_user;
   assign dram_ar_valid = dram.ar_valid;
   assign dram.ar_ready = dram_ar_ready;
   //    R
   assign dram.r_id = dram_r_id;
   assign dram.r_data = dram_r_data;
   assign dram.r_resp = dram_r_resp;
   assign dram.r_last = dram_r_last;
   assign dram.r_user = dram_r_user;
   assign dram.r_valid = dram_r_valid;
   assign dram_r_ready = dram.r_ready;
   //    AC (TODO: connect through the AXI crossbar!)
   assign ace_req.ac_valid = dram_ac_valid;
   assign ace_req.ac.addr  = dram_ac_addr;
   assign ace_req.ac.prot  = dram_ac_prot;
   assign ace_req.ac.snoop = dram_ac_snoop;
   assign dram_ac_ready = ace_resp.ac_ready;
endmodule
