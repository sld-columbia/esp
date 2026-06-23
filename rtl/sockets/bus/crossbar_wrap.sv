
// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

module crossbar_wrap
  # (
     parameter NMST = 2,
     parameter NSLV = 2,
     parameter AXI_ID_WIDTH = 2,
     parameter AXI_ID_WIDTH_SLV = 4,
     parameter AXI_ADDR_WIDTH = 32,
     parameter AXI_DATA_WIDTH = 32,
     parameter AXI_USER_WIDTH = 4,
     parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8,
     // Slave 0
     parameter logic [31:0] ROMBase             = 32'h0000_0000,
     parameter logic [31:0] ROMLength           = 32'h0001_0000,
     // Slave 1
     parameter logic [31:0] DRAMBase            = 32'h4000_0000,
     parameter logic [31:0] DRAMLength          = 32'h4000_0000
     )
   (
    input logic 			clk,
    input logic 			rstn,
    
    // -- MASTER 0
    //    AW
    input logic [AXI_ID_WIDTH-1:0] 	mst0_aw_id,
    input logic [AXI_ADDR_WIDTH-1:0] 	mst0_aw_addr,
    input logic [7:0] 			mst0_aw_len,
    input logic [2:0] 			mst0_aw_size,
    input logic [1:0] 			mst0_aw_burst,
    input logic 				mst0_aw_lock,
    input logic [3:0] 			mst0_aw_cache,
    input logic [2:0] 			mst0_aw_prot,
    input logic [3:0] 			mst0_aw_qos,
    input logic [5:0] 			mst0_aw_atop,
    input logic [3:0] 			mst0_aw_region,
    input logic [AXI_USER_WIDTH-1:0] 	mst0_aw_user,
    input logic 			mst0_aw_valid,
    output logic 			mst0_aw_ready,
    //    W
    input logic [AXI_DATA_WIDTH-1:0] 	mst0_w_data,
    input logic [AXI_STRB_WIDTH-1:0] 	mst0_w_strb,
    input logic 			mst0_w_last,
    input logic [AXI_USER_WIDTH-1:0] 	mst0_w_user,
    input logic 			mst0_w_valid,
    output logic 			mst0_w_ready,
    //    B
    output logic [AXI_ID_WIDTH-1:0] 	mst0_b_id,
    output logic [1:0] 			mst0_b_resp,
    output logic [AXI_USER_WIDTH-1:0] 	mst0_b_user,
    output logic 			mst0_b_valid,
    input logic 			mst0_b_ready,
    //    AR
    input logic [AXI_ID_WIDTH-1:0] 	mst0_ar_id,
    input logic [AXI_ADDR_WIDTH-1:0] 	mst0_ar_addr,
    input logic [7:0] 			mst0_ar_len,
    input logic [2:0] 			mst0_ar_size,
    input logic [1:0] 			mst0_ar_burst,
    input logic 			mst0_ar_lock,
    input logic [3:0] 			mst0_ar_cache,
    input logic [2:0] 			mst0_ar_prot,
    input logic [3:0] 			mst0_ar_qos,
    input logic [3:0] 			mst0_ar_region,
    input logic [AXI_USER_WIDTH-1:0] 	mst0_ar_user,
    input logic 			mst0_ar_valid,
    output logic 			mst0_ar_ready,
    //    R
    output logic [AXI_ID_WIDTH-1:0] 	mst0_r_id,
    output logic [AXI_DATA_WIDTH-1:0] 	mst0_r_data,
    output logic [1:0] 			mst0_r_resp,
    output logic 			mst0_r_last,
    output logic [AXI_USER_WIDTH-1:0] 	mst0_r_user,
    output logic 			mst0_r_valid,
    input logic 			mst0_r_ready,

    // -- MASTER 1
    //    AW
    input logic [AXI_ID_WIDTH-1:0] 	mst1_aw_id,
    input logic [AXI_ADDR_WIDTH-1:0] 	mst1_aw_addr,
    input logic [7:0] 			mst1_aw_len,
    input logic [2:0] 			mst1_aw_size,
    input logic [1:0] 			mst1_aw_burst,
    input logic 			mst1_aw_lock,
    input logic [3:0] 			mst1_aw_cache,
    input logic [2:0] 			mst1_aw_prot,
    input logic [3:0] 			mst1_aw_qos,
    input logic [5:0] 			mst1_aw_atop,
    input logic [3:0] 			mst1_aw_region,
    input logic [AXI_USER_WIDTH-1:0] 	mst1_aw_user,
    input logic 			mst1_aw_valid,
    output logic 			mst1_aw_ready,
    //    W
    input logic [AXI_DATA_WIDTH-1:0] 	mst1_w_data,
    input logic [AXI_STRB_WIDTH-1:0] 	mst1_w_strb,
    input logic 			mst1_w_last,
    input logic [AXI_USER_WIDTH-1:0] 	mst1_w_user,
    input logic 			mst1_w_valid,
    output logic 			mst1_w_ready,
    //    B
    output logic [AXI_ID_WIDTH-1:0] 	mst1_b_id,
    output logic [1:0] 			mst1_b_resp,
    output logic [AXI_USER_WIDTH-1:0] 	mst1_b_user,
    output logic 			mst1_b_valid,
    input logic 			mst1_b_ready,
    //    AR
    input logic [AXI_ID_WIDTH-1:0] 	mst1_ar_id,
    input logic [AXI_ADDR_WIDTH-1:0] 	mst1_ar_addr,
    input logic [7:0] 			mst1_ar_len,
    input logic [2:0] 			mst1_ar_size,
    input logic [1:0] 			mst1_ar_burst,
    input logic 			mst1_ar_lock,
    input logic [3:0] 			mst1_ar_cache,
    input logic [2:0] 			mst1_ar_prot,
    input logic [3:0] 			mst1_ar_qos,
    input logic [3:0] 			mst1_ar_region,
    input logic [AXI_USER_WIDTH-1:0] 	mst1_ar_user,
    input logic 			mst1_ar_valid,
    output logic 			mst1_ar_ready,
    //    R
    output logic [AXI_ID_WIDTH-1:0] 	mst1_r_id,
    output logic [AXI_DATA_WIDTH-1:0] 	mst1_r_data,
    output logic [1:0] 			mst1_r_resp,
    output logic 			mst1_r_last,
    output logic [AXI_USER_WIDTH-1:0] 	mst1_r_user,
    output logic 			mst1_r_valid,
    input logic 			mst1_r_ready,

    // -- MASTER 2
    //    AW
    input logic [AXI_ID_WIDTH-1:0] 	mst2_aw_id,
    input logic [AXI_ADDR_WIDTH-1:0] 	mst2_aw_addr,
    input logic [7:0] 			mst2_aw_len,
    input logic [2:0] 			mst2_aw_size,
    input logic [1:0] 			mst2_aw_burst,
    input logic 			mst2_aw_lock,
    input logic [3:0] 			mst2_aw_cache,
    input logic [2:0] 			mst2_aw_prot,
    input logic [3:0] 			mst2_aw_qos,
    input logic [5:0] 			mst2_aw_atop,
    input logic [3:0] 			mst2_aw_region,
    input logic [AXI_USER_WIDTH-1:0] 	mst2_aw_user,
    input logic 			mst2_aw_valid,
    output logic 			mst2_aw_ready,
    //    W
    input logic [AXI_DATA_WIDTH-1:0] 	mst2_w_data,
    input logic [AXI_STRB_WIDTH-1:0] 	mst2_w_strb,
    input logic 			mst2_w_last,
    input logic [AXI_USER_WIDTH-1:0] 	mst2_w_user,
    input logic 			mst2_w_valid,
    output logic 			mst2_w_ready,
    //    B
    output logic [AXI_ID_WIDTH-1:0] 	mst2_b_id,
    output logic [1:0] 			mst2_b_resp,
    output logic [AXI_USER_WIDTH-1:0] 	mst2_b_user,
    output logic 			mst2_b_valid,
    input logic 			mst2_b_ready,
    //    AR
    input logic [AXI_ID_WIDTH-1:0] 	mst2_ar_id,
    input logic [AXI_ADDR_WIDTH-1:0] 	mst2_ar_addr,
    input logic [7:0] 			mst2_ar_len,
    input logic [2:0] 			mst2_ar_size,
    input logic [1:0] 			mst2_ar_burst,
    input logic 			mst2_ar_lock,
    input logic [3:0] 			mst2_ar_cache,
    input logic [2:0] 			mst2_ar_prot,
    input logic [3:0] 			mst2_ar_qos,
    input logic [3:0] 			mst2_ar_region,
    input logic [AXI_USER_WIDTH-1:0] 	mst2_ar_user,
    input logic 			mst2_ar_valid,
    output logic 			mst2_ar_ready,
    //    R
    output logic [AXI_ID_WIDTH-1:0] 	mst2_r_id,
    output logic [AXI_DATA_WIDTH-1:0] 	mst2_r_data,
    output logic [1:0] 			mst2_r_resp,
    output logic 			mst2_r_last,
    output logic [AXI_USER_WIDTH-1:0] 	mst2_r_user,
    output logic 			mst2_r_valid,
    input logic 			mst2_r_ready,     

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
    output logic 				dram_ar_lock,
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
    output logic 			dram_r_ready
    );


   typedef enum int unsigned {
      ROM      = 0,
      DRAM     = 1
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


   // ---------------
   // AXI Xbar
   // ---------------
   axi_node_wrap_with_slices
     #(
       .NB_SLAVE           (NMST),
       .NB_MASTER          (NSLV   ),
       .NB_REGION          (1),
       .AXI_ADDR_WIDTH     (AXI_ADDR_WIDTH),
       .AXI_DATA_WIDTH     (AXI_DATA_WIDTH),
       .AXI_USER_WIDTH     (AXI_USER_WIDTH),
       .AXI_ID_WIDTH       (AXI_ID_WIDTH),
       .MASTER_SLICE_DEPTH (1),
       .SLAVE_SLICE_DEPTH  (1)
       ) i_axi_xbar
       (
	.clk          (clk),
	.rst_n        (rstn),
	.test_en_i    (1'b0),
	.slave        (slave),
	.master       (master),
	.start_addr_i ({
			DRAMBase[AXI_ADDR_WIDTH-1:0],
			ROMBase[AXI_ADDR_WIDTH-1:0]
			}),
	.end_addr_i   ({
			DRAMBase[AXI_ADDR_WIDTH-1:0]  + DRAMLength[AXI_ADDR_WIDTH-1:0] - 1,
			ROMBase[AXI_ADDR_WIDTH-1:0]   + ROMLength[AXI_ADDR_WIDTH-1:0] - 1
			}),
	.valid_rule_i ({{NSLV}{1'b1}})
	);
    

   // ---------------
   // MASTER 0
   // ---------------
   //    AW
   assign slave[0].aw_id	= mst0_aw_id;
   assign slave[0].aw_addr	= mst0_aw_addr;
   assign slave[0].aw_len	= mst0_aw_len;
   assign slave[0].aw_size	= mst0_aw_size;
   assign slave[0].aw_burst	= mst0_aw_burst;
   assign slave[0].aw_lock	= mst0_aw_lock;
   assign slave[0].aw_cache	= mst0_aw_cache;
   assign slave[0].aw_prot	= mst0_aw_prot;
   assign slave[0].aw_qos	= mst0_aw_qos;
   assign slave[0].aw_atop	= mst0_aw_atop;
   assign slave[0].aw_region	= mst0_aw_region;
   assign slave[0].aw_user	= mst0_aw_user;
   assign slave[0].aw_valid	= mst0_aw_valid;
   assign mst0_aw_ready = slave[0].aw_ready;
   //    W
   assign slave[0].w_data	= mst0_w_data;
   assign slave[0].w_strb	= mst0_w_strb;
   assign slave[0].w_last	= mst0_w_last;
   assign slave[0].w_user	= mst0_w_user;
   assign slave[0].w_valid	= mst0_w_valid;
   assign mst0_w_ready = slave[0].w_ready;
   //    B
   assign mst0_b_id    = slave[0].b_id;
   assign mst0_b_resp  = slave[0].b_resp;
   assign mst0_b_user  = slave[0].b_user;
   assign mst0_b_valid = slave[0].b_valid;
   assign slave[0].b_ready = mst0_b_ready;
   //    AR
   assign slave[0].ar_id	= mst0_ar_id;
   assign slave[0].ar_addr	= mst0_ar_addr;
   assign slave[0].ar_len	= mst0_ar_len;
   assign slave[0].ar_size	= mst0_ar_size;
   assign slave[0].ar_burst	= mst0_ar_burst;
   assign slave[0].ar_lock	= mst0_ar_lock;
   assign slave[0].ar_cache	= mst0_ar_cache;
   assign slave[0].ar_prot	= mst0_ar_prot;
   assign slave[0].ar_qos	= mst0_ar_qos;
   assign slave[0].ar_region	= mst0_ar_region;
   assign slave[0].ar_user	= mst0_ar_user;
   assign slave[0].ar_valid	= mst0_ar_valid;
   assign mst0_ar_ready = slave[0].ar_ready;
   //    R
   assign mst0_r_id    = slave[0].r_id;
   assign mst0_r_data  = slave[0].r_data;
   assign mst0_r_resp  = slave[0].r_resp;
   assign mst0_r_last  = slave[0].r_last;
   assign mst0_r_user  = slave[0].r_user;
   assign mst0_r_valid = slave[0].r_valid;
   assign slave[0].r_ready = mst0_r_ready;

   // ---------------
   // MASTER 1
   // ---------------
   //    AW
   assign slave[1].aw_id	= mst1_aw_id;
   assign slave[1].aw_addr	= mst1_aw_addr;
   assign slave[1].aw_len	= mst1_aw_len;
   assign slave[1].aw_size	= mst1_aw_size;
   assign slave[1].aw_burst	= mst1_aw_burst;
   assign slave[1].aw_lock	= mst1_aw_lock;
   assign slave[1].aw_cache	= mst1_aw_cache;
   assign slave[1].aw_prot	= mst1_aw_prot;
   assign slave[1].aw_qos	= mst1_aw_qos;
   assign slave[1].aw_atop	= mst1_aw_atop;
   assign slave[1].aw_region	= mst1_aw_region;
   assign slave[1].aw_user	= mst1_aw_user;
   assign slave[1].aw_valid	= mst1_aw_valid;
   assign mst1_aw_ready = slave[1].aw_ready;
   //    W
   assign slave[1].w_data	= mst1_w_data;
   assign slave[1].w_strb	= mst1_w_strb;
   assign slave[1].w_last	= mst1_w_last;
   assign slave[1].w_user	= mst1_w_user;
   assign slave[1].w_valid	= mst1_w_valid;
   assign mst1_w_ready = slave[1].w_ready;
   //    B
   assign mst1_b_id    = slave[1].b_id;
   assign mst1_b_resp  = slave[1].b_resp;
   assign mst1_b_user  = slave[1].b_user;
   assign mst1_b_valid = slave[1].b_valid;
   assign slave[1].b_ready = mst1_b_ready;
   //    AR
   assign slave[1].ar_id	= mst1_ar_id;
   assign slave[1].ar_addr	= mst1_ar_addr;
   assign slave[1].ar_len	= mst1_ar_len;
   assign slave[1].ar_size	= mst1_ar_size;
   assign slave[1].ar_burst	= mst1_ar_burst;
   assign slave[1].ar_lock	= mst1_ar_lock;
   assign slave[1].ar_cache	= mst1_ar_cache;
   assign slave[1].ar_prot	= mst1_ar_prot;
   assign slave[1].ar_qos	= mst1_ar_qos;
   assign slave[1].ar_region	= mst1_ar_region;
   assign slave[1].ar_user	= mst1_ar_user;
   assign slave[1].ar_valid	= mst1_ar_valid;
   assign mst1_ar_ready = slave[1].ar_ready;
   //    R
   assign mst1_r_id    = slave[1].r_id;
   assign mst1_r_data  = slave[1].r_data;
   assign mst1_r_resp  = slave[1].r_resp;
   assign mst1_r_last  = slave[1].r_last;
   assign mst1_r_user  = slave[1].r_user;
   assign mst1_r_valid = slave[1].r_valid;
   assign slave[1].r_ready = mst1_r_ready;

   // ---------------
   // MASTER 2
   // ---------------
   //    AW
   assign slave[2].aw_id	= mst2_aw_id;
   assign slave[2].aw_addr	= mst2_aw_addr;
   assign slave[2].aw_len	= mst2_aw_len;
   assign slave[2].aw_size	= mst2_aw_size;
   assign slave[2].aw_burst	= mst2_aw_burst;
   assign slave[2].aw_lock	= mst2_aw_lock;
   assign slave[2].aw_cache	= mst2_aw_cache;
   assign slave[2].aw_prot	= mst2_aw_prot;
   assign slave[2].aw_qos	= mst2_aw_qos;
   assign slave[2].aw_atop	= mst2_aw_atop;
   assign slave[2].aw_region	= mst2_aw_region;
   assign slave[2].aw_user	= mst2_aw_user;
   assign slave[2].aw_valid	= mst2_aw_valid;
   assign mst2_aw_ready = slave[2].aw_ready;
   //    W
   assign slave[2].w_data	= mst2_w_data;
   assign slave[2].w_strb	= mst2_w_strb;
   assign slave[2].w_last	= mst2_w_last;
   assign slave[2].w_user	= mst2_w_user;
   assign slave[2].w_valid	= mst2_w_valid;
   assign mst2_w_ready = slave[2].w_ready;
   //    B
   assign mst2_b_id    = slave[2].b_id;
   assign mst2_b_resp  = slave[2].b_resp;
   assign mst2_b_user  = slave[2].b_user;
   assign mst2_b_valid = slave[2].b_valid;
   assign slave[2].b_ready = mst2_b_ready;
   //    AR
   assign slave[2].ar_id	= mst2_ar_id;
   assign slave[2].ar_addr	= mst2_ar_addr;
   assign slave[2].ar_len	= mst2_ar_len;
   assign slave[2].ar_size	= mst2_ar_size;
   assign slave[2].ar_burst	= mst2_ar_burst;
   assign slave[2].ar_lock	= mst2_ar_lock;
   assign slave[2].ar_cache	= mst2_ar_cache;
   assign slave[2].ar_prot	= mst2_ar_prot;
   assign slave[2].ar_qos	= mst2_ar_qos;
   assign slave[2].ar_region	= mst2_ar_region;
   assign slave[2].ar_user	= mst2_ar_user;
   assign slave[2].ar_valid	= mst2_ar_valid;
   assign mst2_ar_ready = slave[2].ar_ready;
   //    R
   assign mst2_r_id    = slave[2].r_id;
   assign mst2_r_data  = slave[2].r_data;
   assign mst2_r_resp  = slave[2].r_resp;
   assign mst2_r_last  = slave[2].r_last;
   assign mst2_r_user  = slave[2].r_user;
   assign mst2_r_valid = slave[2].r_valid;
   assign slave[2].r_ready = mst2_r_ready;


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


   //    AW
   assign dram_aw_id = master[DRAM].aw_id;
   assign dram_aw_addr = master[DRAM].aw_addr;
   assign dram_aw_len = master[DRAM].aw_len;
   assign dram_aw_size = master[DRAM].aw_size;
   assign dram_aw_burst = master[DRAM].aw_burst;
   assign dram_aw_lock = master[DRAM].aw_lock;
   assign dram_aw_cache = master[DRAM].aw_cache;
   assign dram_aw_prot = master[DRAM].aw_prot;
   assign dram_aw_qos = master[DRAM].aw_qos;
   assign dram_aw_atop = master[DRAM].aw_atop;
   assign dram_aw_region = master[DRAM].aw_region;
   assign dram_aw_user = master[DRAM].aw_user;
   assign dram_aw_valid = master[DRAM].aw_valid;
   assign master[DRAM].aw_ready = dram_aw_ready;
   //    W
   assign dram_w_data = master[DRAM].w_data;
   assign dram_w_strb = master[DRAM].w_strb;
   assign dram_w_last = master[DRAM].w_last;
   assign dram_w_user = master[DRAM].w_user;
   assign dram_w_valid = master[DRAM].w_valid;
   assign master[DRAM].w_ready = dram_w_ready;
   //    B
   assign master[DRAM].b_id = dram_b_id;
   assign master[DRAM].b_resp = dram_b_resp;
   assign master[DRAM].b_user = dram_b_user;
   assign master[DRAM].b_valid = dram_b_valid;
   assign dram_b_ready = master[DRAM].b_ready;
   //    AR
   assign dram_ar_id = master[DRAM].ar_id;
   assign dram_ar_addr = master[DRAM].ar_addr;
   assign dram_ar_len = master[DRAM].ar_len;
   assign dram_ar_size = master[DRAM].ar_size;
   assign dram_ar_burst = master[DRAM].ar_burst;
   assign dram_ar_lock = master[DRAM].ar_lock;
   assign dram_ar_cache = master[DRAM].ar_cache;
   assign dram_ar_prot = master[DRAM].ar_prot;
   assign dram_ar_qos = master[DRAM].ar_qos;
   assign dram_ar_region = master[DRAM].ar_region;
   assign dram_ar_user = master[DRAM].ar_user;
   assign dram_ar_valid = master[DRAM].ar_valid;
   assign master[DRAM].ar_ready = dram_ar_ready;
   //    R
   assign master[DRAM].r_id = dram_r_id;
   assign master[DRAM].r_data = dram_r_data;
   assign master[DRAM].r_resp = dram_r_resp;
   assign master[DRAM].r_last = dram_r_last;
   assign master[DRAM].r_user = dram_r_user;
   assign master[DRAM].r_valid = dram_r_valid;
   assign dram_r_ready = master[DRAM].r_ready;

endmodule
