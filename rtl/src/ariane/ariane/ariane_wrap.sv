// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Copyright 2019 Columbia University, System Level Design Group
// This file is derived work that includes substantial portions of code from
// the Ariane project, distributed under the Solderpad Hardware License,
// Version 0.51. The original copyright notice and copyright owners are
// reported above. A full copy of the license is available in the liceses
// folder.

// Description and modifications:
// Ariane interface for integration into the ESP processor tile.

module ariane_wrap
  # (
     parameter logic [63:0] HART_ID = '0,
     parameter NMST = 2,
     parameter NSLV = 5,
     parameter NIRQ_SRCS = 1,
     parameter AXI_ID_WIDTH = ariane_soc::IdWidth,
     parameter AXI_ID_WIDTH_SLV = ariane_soc::IdWidthSlave + $clog2(NMST),
     parameter AXI_ADDR_WIDTH = 64,
     parameter AXI_DATA_WIDTH = 64,
     parameter AXI_USER_WIDTH = 1,
     parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8,
     // Slave 0
     parameter logic [63:0] ROMBase        = 64'h0000_0000_0001_0000,
     parameter logic [63:0] ROMLength      = 64'h0000_0000_0001_0000,
     // Slave 1
     parameter logic [63:0] APBBase        = 64'h0000_0000_8000_0000,
     parameter logic [63:0] APBLength      = 64'h0000_0000_1000_0000,
     // Slave 2 (TODO: move to I/O tile)
     parameter logic [63:0] CLINTBase      = 64'h0000_0000_0200_0000,
     parameter logic [63:0] CLINTLength    = 64'h0000_0000_000C_0000,
     // Slave 3 (TODO: move to I/O tile)
     parameter logic [63:0] PLICBase       = 64'h0000_0000_0C00_0000,
     parameter logic [63:0] PLICLength     = 64'h0000_0000_03FF_FFFF,
     // Slave 4
     parameter logic [63:0] DRAMBase       = 64'h0000_0000_4000_0000,
     parameter logic [63:0] DRAMLength     = 64'h0000_0000_4000_0000  // 1GByte of DDR for now (will change!)
     )
   (
    input logic 			clk,
    input logic 			rstn,
    // TODO: move this to I/O tile
    input logic [NIRQ_SRCS-1:0] 	irq_sources,
    // TODO: add more AXI outputs for CLINT; use APB for PLIC
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
    // APB
    output logic 			penable,
    output logic 			pwrite,
    output logic [31:0] 		paddr,
    output logic 			psel,
    output logic [31:0] 		pwdata,
    input logic [31:0] 			prdata,
    input logic 			pready,
    input logic 			pslverr
    );

   // Base addresses for Ariane
   localparam bit SwapEndianess = 0;
   localparam logic [63:0] CachedAddrBeg  = DRAMBase;
   localparam logic [63:0] CachedAddrEnd  = DRAMBase + DRAMLength;

   // TODO: move this to I/O tile and socmap CFG_NCPUTILE
   localparam NHARTS = 1;

   typedef enum int unsigned {
      ROM      = 0,
      APB      = 1,
      CLINT    = 2,
      PLIC     = 3,
      DRAM     = 4
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
			DRAMBase,
			PLICBase,
			CLINTBase,
			APBBase,
			ROMBase
			}),
	.end_addr_i   ({
			DRAMBase  + DRAMLength - 1,
			PLICBase  + PLICLength - 1,
			CLINTBase + CLINTLength - 1,
			APBBase   + APBLength - 1,
			ROMBase   + ROMLength - 1
			}),
	.valid_rule_i ({{NSLV}{1'b1}})
	);

   // ---------------
   // Core
   // ---------------
   // TODO: move to inputs. These come from NoC
   // input logic [NHARTS-1:0][1:0] irq;
   // input logic [NHARTS-1:0] 	   ipi;
   // input logic [NHARTS-1:0] 	   time_irq;
   logic [1:0]	irq;
   logic 	ipi;
   logic 	time_irq;

   ariane_axi::req_t    axi_ariane_req;
   ariane_axi::resp_t   axi_ariane_resp;

   ariane
     #(
       .SwapEndianess ( SwapEndianess ),
       .CachedAddrEnd ( CachedAddrEnd ),
       .CachedAddrBeg ( CachedAddrBeg )
       ) i_ariane
       (
	.clk_i        ( clk                 ),
	.rst_ni       ( rstn                ),
	.boot_addr_i  ( ROMBase             ),
	.hart_id_i    ( HART_ID             ),
	.irq_i        ( irq                 ),
	.ipi_i        ( ipi	            ),
	.time_irq_i   ( time_irq            ),
	.debug_req_i  ( 1'b0                ),
	.axi_req_o    ( axi_ariane_req      ),
	.axi_resp_i   ( axi_ariane_resp     )
	);

   axi_master_connect i_axi_master_connect_ariane (.axi_req_i(axi_ariane_req), .axi_resp_o(axi_ariane_resp), .master(slave[0]));


   // ---------------
   // ROM
   // ---------------
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
   // CLINT (TODO: move to I/O tile)
   // ---------------
   // divide clock by two
   logic rtc;

   always_ff @(posedge clk or negedge rstn) begin
      if (~rstn) begin
	 rtc <= 0;
      end else begin
	 rtc <= rtc ^ 1'b1;
      end
   end

   ariane_axi::req_t    axi_clint_req;
   ariane_axi::resp_t   axi_clint_resp;

   clint
     #(
       .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH   ),
       .AXI_DATA_WIDTH ( AXI_DATA_WIDTH   ),
       .AXI_ID_WIDTH   ( AXI_ID_WIDTH_SLV ),
       .NR_CORES       ( NHARTS           )
       ) i_clint
       (
	.clk_i       ( clk            ),
	.rst_ni      ( rstn           ),
	.testmode_i  ( 1'b0           ),
	.axi_req_i   ( axi_clint_req  ),
	.axi_resp_o  ( axi_clint_resp ),
	.rtc_i       ( rtc            ),
	.timer_irq_o ( time_irq       ),
	.ipi_o       ( ipi            )
	);

   axi_slave_connect i_axi_slave_connect_clint (.axi_req_o(axi_clint_req), .axi_resp_i(axi_clint_resp), .slave(master[CLINT]));

   // ---------------
   // PLIC (TODO: move to I/O tile)
   // ---------------

    REG_BUS #(
        .ADDR_WIDTH ( 32 ),
        .DATA_WIDTH ( 32 )
    ) reg_bus (clk_i);

    logic         plic_penable;
    logic         plic_pwrite;
    logic [31:0]  plic_paddr;
    logic         plic_psel;
    logic [31:0]  plic_pwdata;
    logic [31:0]  plic_prdata;
    logic         plic_pready;
    logic         plic_pslverr;

    axi2apb_64_32
      #(
        .AXI4_ADDRESS_WIDTH ( AXI_ADDR_WIDTH   ),
        .AXI4_RDATA_WIDTH   ( AXI_DATA_WIDTH   ),
        .AXI4_WDATA_WIDTH   ( AXI_DATA_WIDTH   ),
        .AXI4_ID_WIDTH      ( AXI_ID_WIDTH_SLV ),
        .AXI4_USER_WIDTH    ( AXI_USER_WIDTH   ),
        .BUFF_DEPTH_SLAVE   ( 2                ),
        .APB_ADDR_WIDTH     ( 32               )
	) i_axi2apb_64_32_plic
	(
	 .ACLK      ( clk_i          ),
         .ARESETn   ( rst_ni         ),
         .test_en_i ( 1'b0           ),
         .AWID_i    ( master[PLIC].aw_id     ),
         .AWADDR_i  ( master[PLIC].aw_addr   ),
         .AWLEN_i   ( master[PLIC].aw_len    ),
         .AWSIZE_i  ( master[PLIC].aw_size   ),
         .AWBURST_i ( master[PLIC].aw_burst  ),
         .AWLOCK_i  ( master[PLIC].aw_lock   ),
         .AWCACHE_i ( master[PLIC].aw_cache  ),
         .AWPROT_i  ( master[PLIC].aw_prot   ),
         .AWREGION_i( master[PLIC].aw_region ),
         .AWUSER_i  ( master[PLIC].aw_user   ),
         .AWQOS_i   ( master[PLIC].aw_qos    ),
         .AWVALID_i ( master[PLIC].aw_valid  ),
         .AWREADY_o ( master[PLIC].aw_ready  ),
         .WDATA_i   ( master[PLIC].w_data    ),
         .WSTRB_i   ( master[PLIC].w_strb    ),
         .WLAST_i   ( master[PLIC].w_last    ),
         .WUSER_i   ( master[PLIC].w_user    ),
         .WVALID_i  ( master[PLIC].w_valid   ),
         .WREADY_o  ( master[PLIC].w_ready   ),
         .BID_o     ( master[PLIC].b_id      ),
         .BRESP_o   ( master[PLIC].b_resp    ),
         .BVALID_o  ( master[PLIC].b_valid   ),
         .BUSER_o   ( master[PLIC].b_user    ),
         .BREADY_i  ( master[PLIC].b_ready   ),
         .ARID_i    ( master[PLIC].ar_id     ),
         .ARADDR_i  ( master[PLIC].ar_addr   ),
         .ARLEN_i   ( master[PLIC].ar_len    ),
         .ARSIZE_i  ( master[PLIC].ar_size   ),
         .ARBURST_i ( master[PLIC].ar_burst  ),
         .ARLOCK_i  ( master[PLIC].ar_lock   ),
         .ARCACHE_i ( master[PLIC].ar_cache  ),
         .ARPROT_i  ( master[PLIC].ar_prot   ),
         .ARREGION_i( master[PLIC].ar_region ),
         .ARUSER_i  ( master[PLIC].ar_user   ),
         .ARQOS_i   ( master[PLIC].ar_qos    ),
         .ARVALID_i ( master[PLIC].ar_valid  ),
         .ARREADY_o ( master[PLIC].ar_ready  ),
         .RID_o     ( master[PLIC].r_id      ),
         .RDATA_o   ( master[PLIC].r_data    ),
         .RRESP_o   ( master[PLIC].r_resp    ),
         .RLAST_o   ( master[PLIC].r_last    ),
         .RUSER_o   ( master[PLIC].r_user    ),
         .RVALID_o  ( master[PLIC].r_valid   ),
         .RREADY_i  ( master[PLIC].r_ready   ),
         .PENABLE   ( plic_penable   ),
         .PWRITE    ( plic_pwrite    ),
         .PADDR     ( plic_paddr     ),
         .PSEL      ( plic_psel      ),
         .PWDATA    ( plic_pwdata    ),
         .PRDATA    ( plic_prdata    ),
         .PREADY    ( plic_pready    ),
         .PSLVERR   ( plic_pslverr   )
	 );

    apb_to_reg i_apb_to_reg
      (
       .clk_i     ( clk_i        ),
       .rst_ni    ( rst_ni       ),
       .penable_i ( plic_penable ),
       .pwrite_i  ( plic_pwrite  ),
       .paddr_i   ( plic_paddr   ),
       .psel_i    ( plic_psel    ),
       .pwdata_i  ( plic_pwdata  ),
       .prdata_o  ( plic_prdata  ),
       .pready_o  ( plic_pready  ),
       .pslverr_o ( plic_pslverr ),
       .reg_o     ( reg_bus      )
       );

    plic
      #(
        .ID_BITWIDTH        ( 3         ), // TODO: check upstream repo (up to 8 physical lines?)
        .PARAMETER_BITWIDTH ( 3         ),
        .NUM_TARGETS        ( 2*NHARTS  ),
        .NUM_SOURCES        ( NIRQ_SRCS )
	) i_plic
	(
	 .clk_i              ( clk_i        ),
	 .rst_ni             ( rst_ni       ),
	 .irq_sources_i      ( irq_sources  ),
	 .eip_targets_o      ( irq          ),
	 .external_bus_io    ( reg_bus      )
	 );


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

endmodule
