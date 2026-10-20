// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
// File Name: GT_VORTEX_wrapper.v

`include "VX_config.vh"
`include "VX_define.vh"
`include "VX_gpu_pkg.sv"
`include "VX_trace_pkg.sv"
`include "VX_fpu_pkg.sv"

`ifndef DEBUG_XILINX
// Keep ILA preservation opt-in. Unconditional mark_debug blocks useful
// synthesis/implementation optimization in normal timing-closure builds.
`ifdef GT_VORTEX_ENABLE_MARK_DEBUG
  `define DEBUG_XILINX (* mark_debug = "true" *)
`else
  `define DEBUG_XILINX
`endif
`endif // !DEBUG_XILINX
module GT_VORTEX_wrapper import VX_gpu_pkg::*; #(
   parameter AXI_DATA_WIDTH   = `VX_MEM_DATA_WIDTH,
   parameter AXI_ADDR_WIDTH   = 32,
   parameter AXI_TID_WIDTH    = `VX_MEM_TAG_WIDTH,
   parameter AXI_STROBE_WIDTH = (`VX_MEM_DATA_WIDTH / 8),
   parameter AXI_NUM_BANKS  = 1
) (clk,
   reset, 
   paddr,
   penable,
   psel,
   pwdata,
   pwrite,
   prdata,
   pready,
   pslverr,
   m_axi_awvalid,
   m_axi_awready,
   m_axi_awid,
   m_axi_awlen,
   m_axi_awaddr,
   m_axi_wvalid,
   m_axi_wready,
   m_axi_wdata,
   m_axi_wstrb,
   m_axi_wlast,
   m_axi_arvalid,
   m_axi_arready,
   m_axi_arid,
   m_axi_arlen,
   m_axi_araddr,
   m_axi_bresp,
   m_axi_bvalid,
   m_axi_bready,
   m_axi_bid,
   m_axi_rvalid,
   m_axi_rready,
   m_axi_rid,
   m_axi_rlast,
   m_axi_rdata,
   m_axi_rresp,
   m_axi_awsize,
   m_axi_arsize,
   m_axi_awburst,
   m_axi_arburst,
   m_axi_awlock,
   m_axi_arlock,
   m_axi_awcache,
   m_axi_arcache,
   m_axi_awprot,
   m_axi_arprot,
   m_axi_awqos,
   m_axi_awatop,
   m_axi_awregion,
   m_axi_arqos,
   m_axi_arregion,
   busy_interrupt
   );

   ////////////////////////////////////////////////////////////////////////////////

    // Clock
    `DEBUG_XILINX input wire                          clk;
    `DEBUG_XILINX input wire                          reset;

    // AXI write request address channel
    `DEBUG_XILINX output wire                         m_axi_awvalid;
    `DEBUG_XILINX input wire                          m_axi_awready;
    `DEBUG_XILINX output wire [AXI_ADDR_WIDTH-1:0]    m_axi_awaddr;
    `DEBUG_XILINX output wire [AXI_TID_WIDTH-1:0]     m_axi_awid;
    `DEBUG_XILINX output wire [7:0]                   m_axi_awlen;
    `DEBUG_XILINX output wire [2:0]                   m_axi_awsize;
    `DEBUG_XILINX output wire [1:0]                   m_axi_awburst;
    `DEBUG_XILINX output wire                         m_axi_awlock;
    `DEBUG_XILINX output wire [3:0]                   m_axi_awcache;
    `DEBUG_XILINX output wire [2:0]                   m_axi_awprot;
    `DEBUG_XILINX output wire [3:0]                   m_axi_awqos;
    `DEBUG_XILINX output wire [3:0]                   m_axi_awregion;

    // AXI write request data channel
    `DEBUG_XILINX output wire                         m_axi_wvalid;
    `DEBUG_XILINX input wire                          m_axi_wready;
    `DEBUG_XILINX output wire [AXI_DATA_WIDTH-1:0]    m_axi_wdata;
    `DEBUG_XILINX output wire [AXI_STROBE_WIDTH-1:0]  m_axi_wstrb;
    `DEBUG_XILINX output wire                         m_axi_wlast;

    // AXI write response channel
    `DEBUG_XILINX input wire                          m_axi_bvalid;
    `DEBUG_XILINX output wire                         m_axi_bready;
    `DEBUG_XILINX input wire [AXI_TID_WIDTH-1:0]      m_axi_bid;
    `DEBUG_XILINX input wire [1:0]                    m_axi_bresp;

    // AXI read request channel
    `DEBUG_XILINX output wire                         m_axi_arvalid;
    `DEBUG_XILINX input  wire                         m_axi_arready;
    `DEBUG_XILINX output wire [AXI_ADDR_WIDTH-1:0]    m_axi_araddr;
    `DEBUG_XILINX output wire [AXI_TID_WIDTH-1:0]     m_axi_arid;
    `DEBUG_XILINX output wire [7:0]                   m_axi_arlen;
    `DEBUG_XILINX output wire [2:0]                   m_axi_arsize;
    `DEBUG_XILINX output wire [1:0]                   m_axi_arburst;
    `DEBUG_XILINX output wire                         m_axi_arlock;
    `DEBUG_XILINX output wire [3:0]                   m_axi_arcache;
    `DEBUG_XILINX output wire [2:0]                   m_axi_arprot;
    `DEBUG_XILINX output wire [3:0]                   m_axi_arqos;
    `DEBUG_XILINX output wire [3:0]                   m_axi_arregion;

    // AXI read response channel
    `DEBUG_XILINX input wire                          m_axi_rvalid;
    `DEBUG_XILINX output wire                         m_axi_rready;
    `DEBUG_XILINX input wire [AXI_DATA_WIDTH-1:0]     m_axi_rdata;
    `DEBUG_XILINX input wire                          m_axi_rlast;
    `DEBUG_XILINX input wire [AXI_TID_WIDTH-1:0]      m_axi_rid;
    `DEBUG_XILINX input wire [1:0]                    m_axi_rresp;

    // Status
    `DEBUG_XILINX wire 				                        busy; 
    `DEBUG_XILINX output wire                         busy_interrupt;
    `DEBUG_XILINX output wire [5:0] 		              m_axi_awatop;
   
    // APB for configuration and memory offset 
    `DEBUG_XILINX input psel;
    `DEBUG_XILINX input penable;
    `DEBUG_XILINX input pwrite;
    `DEBUG_XILINX input [31:0] paddr;
    `DEBUG_XILINX input [31:0] pwdata;
    `DEBUG_XILINX output [31:0] prdata;
    `DEBUG_XILINX output pready;
    `DEBUG_XILINX output pslverr;

    ////////////////////////////////////////////////////////////////////////////////

    // Unused wires 
    assign m_axi_awatop   =    4'b0; 

    // DCR Write Request Registers
    `DEBUG_XILINX reg                          dcr_wr_valid;
    `DEBUG_XILINX reg [`VX_DCR_ADDR_WIDTH-1:0] dcr_wr_addr;
    `DEBUG_XILINX reg [`VX_DCR_DATA_WIDTH-1:0] dcr_wr_data;
    
    // DCR Registers
    `DEBUG_XILINX reg [`VX_DCR_DATA_WIDTH-1:0] startup_addr0;
    `DEBUG_XILINX reg [`VX_DCR_DATA_WIDTH-1:0] startup_addr1;
    `DEBUG_XILINX reg [`VX_DCR_DATA_WIDTH-1:0] startup_arg0;
    `DEBUG_XILINX reg [`VX_DCR_DATA_WIDTH-1:0] startup_arg1;
    `DEBUG_XILINX reg [`VX_DCR_DATA_WIDTH-1:0] mpm_class;
    `DEBUG_XILINX reg [2:0] vx_dcr_done;
    `DEBUG_XILINX reg vx_doing_reset;
  
    // Configuration Registers
    `DEBUG_XILINX reg vx_reset_soft = 0;
    `DEBUG_XILINX reg [31:0] addr;
    `DEBUG_XILINX reg vx_reset   = 1'b0;
    `DEBUG_XILINX reg [$clog2(`RESET_DELAY + 1) - 1:0] vx_reset_ctr;
    `DEBUG_XILINX reg reg_done;
    `DEBUG_XILINX reg [1:0] vx_state;
    
    // APB Related Signals
    `DEBUG_XILINX wire apb_write = psel & penable & pwrite;
    `DEBUG_XILINX wire apb_read  = psel & penable & ~pwrite;
    `DEBUG_XILINX wire [31:0] m_axi_araddr_raw;
    `DEBUG_XILINX wire [31:0] m_axi_awaddr_raw;
    assign pready  = 1'b1;
    assign pslverr = 1'b0;
    reg [31:0] read_apb_data = 32'b0;

    // Adding the base address to the memory addresses reserved for Vortex programs
    assign m_axi_araddr = m_axi_araddr_raw + addr; 
    assign m_axi_awaddr = m_axi_awaddr_raw + addr;

  always @(posedge clk) begin
    if (!reset) begin
      reg_done <= 0;
      vx_state <= 0;
    end else begin
      reg_done <= 0;
      if (vx_reset_soft) vx_state <= 1;
      else if (vx_state == 1 && !busy) vx_state <= 2;
      else if (vx_state == 2 && busy) vx_state <= 3;
      else if (vx_state == 3 && !busy) begin
        vx_state <= 0;
        reg_done <= 1;
      end
    end
  end

  assign busy_interrupt = reg_done;

  always @(posedge clk) begin
      if (!reset) begin
        addr           <= 32'b0; // reset initial value 
        vx_reset_soft  <= 1'b0;  // Software reset to start Vortex 
        startup_addr0 <= 0;
        startup_addr1 <= 0;
        startup_arg0 <= 0;
        startup_arg1 <= 0;
        mpm_class <= 0;
      end // reset
      else if (apb_write) begin
          case (paddr[7:0])
            8'h50 : addr          <= pwdata;
	          8'h54 : vx_reset_soft <= pwdata[0];  
            8'h60 : startup_addr0 <= pwdata[`VX_DCR_DATA_WIDTH-1:0];
            8'h64 : startup_addr1 <= pwdata[`VX_DCR_DATA_WIDTH-1:0];
            8'h68 : startup_arg0 <= pwdata[`VX_DCR_DATA_WIDTH-1:0];
            8'h6C : startup_arg1 <= pwdata[`VX_DCR_DATA_WIDTH-1:0];
            8'h70 : mpm_class <= pwdata[`VX_DCR_DATA_WIDTH-1:0];
          endcase
      end else begin
          vx_reset_soft <= 1'b0;
      end // !reset
 end // always
   
  always @(*) begin
    case (paddr[7:0]) 
      8'h50 :  read_apb_data   = addr;
	    8'h54 :  read_apb_data   = {31'b0, vx_reset_soft}; 
      8'h58 :  read_apb_data   = {31'b0, busy}; // Interrupt Read only
      8'h60 : read_apb_data   = startup_addr0;
      8'h64 : read_apb_data   = startup_addr1;
      8'h68 : read_apb_data   = startup_arg0;
      8'h6C : read_apb_data   = startup_arg1;
      8'h70 : read_apb_data   = mpm_class;
	    default: read_apb_data   = 32'b0;	    
    endcase
  end //always comb for apb reads
  
  assign prdata = read_apb_data; 

  always @(posedge clk) begin
     if (!reset) begin
         vx_reset_ctr   <= 0;
         dcr_wr_valid  <= 0;
         dcr_wr_addr   <= 0;
         dcr_wr_data   <= 0;
         vx_dcr_done <= 0;
         vx_doing_reset <= 0;
     end else begin   
      if (vx_reset_soft == 1'b1) begin
            vx_doing_reset <= 1;
            vx_dcr_done <= 0;
      end // end reset begin if
       if (vx_dcr_done < 6) begin
        case (vx_dcr_done)
          0: begin 
            dcr_wr_valid <= 1;
            dcr_wr_addr <= 1;
            dcr_wr_data <= startup_addr0;
          end
          1: begin
            dcr_wr_valid <= 1;
            dcr_wr_addr <= 2;
            dcr_wr_data <= startup_addr1;
          end
          2: begin
            dcr_wr_valid <= 1;
            dcr_wr_addr <= 3;
            dcr_wr_data <= startup_arg0;
          end
          3: begin
            dcr_wr_valid <= 1;
            dcr_wr_addr <= 4;
            dcr_wr_data <= startup_arg1;
          end
          4: begin
            dcr_wr_valid <= 1;
            dcr_wr_addr <= 5;
            dcr_wr_data <= mpm_class;
          end
          5: begin
            dcr_wr_valid <= 0;
            dcr_wr_addr <= 0;
            dcr_wr_data <= 0;
          end
        endcase
        vx_dcr_done <= vx_dcr_done + 1;
       end
       else begin
        if (vx_doing_reset) begin
         vx_reset   <= 1'b1;
         vx_doing_reset <= 0;
        end
        // Vortex reset cycles
        else if (vx_reset_ctr == (`RESET_DELAY-1) && vx_reset == 1'b1) begin
         vx_reset   <= 1'b0;
         vx_reset_ctr <= 0;
        end // end delay to reset if
        else if (vx_reset == 1'b1) begin
          vx_reset_ctr <= vx_reset_ctr + 1; 
        end
      end // !reset
     end
   end // always

  // Defintions of unpacked array inputs for Vortex
  wire m_axi_awvalid_arr [AXI_NUM_BANKS];
  wire m_axi_awready_arr [AXI_NUM_BANKS];
  wire [AXI_ADDR_WIDTH-1:0] m_axi_awaddr_raw_arr [AXI_NUM_BANKS];
  wire [AXI_TID_WIDTH-1:0] m_axi_awid_arr [AXI_NUM_BANKS];
  wire [7:0] m_axi_awlen_arr [AXI_NUM_BANKS];
  wire [2:0] m_axi_awsize_arr [AXI_NUM_BANKS];
  wire [1:0] m_axi_awburst_arr [AXI_NUM_BANKS];
  wire [1:0] m_axi_awlock_arr [AXI_NUM_BANKS];
  wire [3:0] m_axi_awcache_arr [AXI_NUM_BANKS];
  wire [2:0] m_axi_awprot_arr [AXI_NUM_BANKS];
  wire [3:0] m_axi_awqos_arr [AXI_NUM_BANKS];
  wire [3:0] m_axi_awregion_arr [AXI_NUM_BANKS];

  // AXI write request data channel
  wire m_axi_wvalid_arr [AXI_NUM_BANKS];
  wire m_axi_wready_arr [AXI_NUM_BANKS];
  wire [AXI_DATA_WIDTH-1:0] m_axi_wdata_arr [AXI_NUM_BANKS];
  wire [AXI_STROBE_WIDTH-1:0] m_axi_wstrb_arr [AXI_NUM_BANKS];
  wire m_axi_wlast_arr [AXI_NUM_BANKS];

  // AXI write response channel
  wire m_axi_bvalid_arr [AXI_NUM_BANKS];
  wire m_axi_bready_arr [AXI_NUM_BANKS];
  wire [AXI_TID_WIDTH-1:0] m_axi_bid_arr [AXI_NUM_BANKS];
  wire [1:0] m_axi_bresp_arr [AXI_NUM_BANKS];

  // AXI read request channel
  wire m_axi_arvalid_arr [AXI_NUM_BANKS];
  wire m_axi_arready_arr [AXI_NUM_BANKS];
  wire [AXI_ADDR_WIDTH-1:0] m_axi_araddr_raw_arr [AXI_NUM_BANKS];
  wire [AXI_TID_WIDTH-1:0] m_axi_arid_arr [AXI_NUM_BANKS];
  wire [7:0] m_axi_arlen_arr [AXI_NUM_BANKS];
  wire [2:0] m_axi_arsize_arr [AXI_NUM_BANKS];
  wire [1:0] m_axi_arburst_arr [AXI_NUM_BANKS];
  wire [1:0] m_axi_arlock_arr [AXI_NUM_BANKS];
  wire [3:0] m_axi_arcache_arr [AXI_NUM_BANKS];
  wire [2:0] m_axi_arprot_arr [AXI_NUM_BANKS];
  wire [3:0] m_axi_arqos_arr [AXI_NUM_BANKS];
  wire [3:0] m_axi_arregion_arr [AXI_NUM_BANKS];

  // AXI read response channel
  wire m_axi_rvalid_arr [AXI_NUM_BANKS];
  wire m_axi_rready_arr [AXI_NUM_BANKS];
  wire [AXI_DATA_WIDTH-1:0] m_axi_rdata_arr [AXI_NUM_BANKS];
  wire m_axi_rlast_arr [AXI_NUM_BANKS];
  wire [AXI_TID_WIDTH-1:0] m_axi_rid_arr [AXI_NUM_BANKS];
  wire [1:0] m_axi_rresp_arr [AXI_NUM_BANKS];

  // Conversion of inputs to unpacked arrays

  assign m_axi_awvalid = m_axi_awvalid_arr[0];
  assign m_axi_awready_arr[0] = m_axi_awready;
  assign m_axi_awaddr_raw = m_axi_awaddr_raw_arr[0];
  assign m_axi_awid = m_axi_awid_arr[0];
  assign m_axi_awlen = m_axi_awlen_arr[0];
  assign m_axi_awsize = m_axi_awsize_arr[0];
  assign m_axi_awburst = m_axi_awburst_arr[0];
  assign m_axi_awlock = m_axi_awlock_arr[0];
  assign m_axi_awcache = m_axi_awcache_arr[0];
  assign m_axi_awprot = m_axi_awprot_arr[0];
  assign m_axi_awqos = m_axi_awqos_arr[0];
  assign m_axi_awregion = m_axi_awregion_arr[0];

  assign m_axi_wvalid = m_axi_wvalid_arr[0];
  assign m_axi_wready_arr[0] = m_axi_wready;
  assign m_axi_wdata = m_axi_wdata_arr[0];
  assign m_axi_wstrb = m_axi_wstrb_arr[0];
  assign m_axi_wlast = m_axi_wlast_arr[0];

  assign m_axi_bvalid_arr[0] = m_axi_bvalid;
  assign m_axi_bready = m_axi_bready_arr[0];
  assign m_axi_bid_arr[0] = m_axi_bid;
  assign m_axi_bresp_arr[0] = m_axi_bresp;

  assign m_axi_arvalid = m_axi_arvalid_arr[0];
  assign m_axi_arready_arr[0] = m_axi_arready;
  assign m_axi_araddr_raw = m_axi_araddr_raw_arr[0];
  assign m_axi_arid = m_axi_arid_arr[0];
  assign m_axi_arlen = m_axi_arlen_arr[0];
  assign m_axi_arsize = m_axi_arsize_arr[0];
  assign m_axi_arburst = m_axi_arburst_arr[0];
  assign m_axi_arlock = m_axi_arlock_arr[0];
  assign m_axi_arcache = m_axi_arcache_arr[0];
  assign m_axi_arprot = m_axi_arprot_arr[0];
  assign m_axi_arqos = m_axi_arqos_arr[0];
  assign m_axi_arregion = m_axi_arregion_arr[0];

  assign m_axi_rvalid_arr[0] = m_axi_rvalid;
  assign m_axi_rready = m_axi_rready_arr[0];
  assign m_axi_rdata_arr[0] = m_axi_rdata;
  assign m_axi_rlast_arr[0] = m_axi_rlast;
  assign m_axi_rid_arr[0] = m_axi_rid;
  assign m_axi_rresp_arr[0] = m_axi_rresp;
  
  Vortex_axi  #(
    .AXI_DATA_WIDTH    (`VX_MEM_DATA_WIDTH),
    .AXI_ADDR_WIDTH    (32),
    .AXI_TID_WIDTH     (`VX_MEM_TAG_WIDTH),
    .AXI_NUM_BANKS     (1)
    )Vortex_axi_0 (
    
    // Clock
    .clk            ( clk   ),
    .reset          ( vx_reset),

    // AXI write request address channel
    .m_axi_awvalid  ( m_axi_awvalid_arr ),
    .m_axi_awready  ( m_axi_awready_arr ),
    .m_axi_awaddr   ( m_axi_awaddr_raw_arr ),
    .m_axi_awid     ( m_axi_awid_arr    ),
    .m_axi_awlen    ( m_axi_awlen_arr   ),
    .m_axi_awsize   ( m_axi_awsize_arr  ),
    .m_axi_awburst  ( m_axi_awburst_arr ),
    .m_axi_awlock   ( m_axi_awlock_arr  ),
    .m_axi_awcache  ( m_axi_awcache_arr ),
    .m_axi_awprot   ( m_axi_awprot_arr  ),
    .m_axi_awqos    ( m_axi_awqos_arr   ),
    .m_axi_awregion ( m_axi_awregion_arr ),

    // AXI write request data channel
    .m_axi_wvalid   ( m_axi_wvalid_arr  ),
    .m_axi_wready   ( m_axi_wready_arr  ),
    .m_axi_wdata    ( m_axi_wdata_arr   ),
    .m_axi_wstrb    ( m_axi_wstrb_arr   ),
    .m_axi_wlast    ( m_axi_wlast_arr   ),
    
    // AXI write response channel
    .m_axi_bvalid   ( m_axi_bvalid_arr  ),
    .m_axi_bready   ( m_axi_bready_arr  ),
    .m_axi_bid      ( m_axi_bid_arr     ),
    .m_axi_bresp    ( m_axi_bresp_arr   ),

    // AXI read request channel
    .m_axi_arvalid  ( m_axi_arvalid_arr ),
    .m_axi_arready  ( m_axi_arready_arr ),
    .m_axi_araddr   ( m_axi_araddr_raw_arr ),
    .m_axi_arid     ( m_axi_arid_arr    ),
    .m_axi_arlen    ( m_axi_arlen_arr   ),
    .m_axi_arsize   ( m_axi_arsize_arr  ),
    .m_axi_arburst  ( m_axi_arburst_arr ),
    .m_axi_arlock   ( m_axi_arlock_arr  ),
    .m_axi_arcache  ( m_axi_arcache_arr ),
    .m_axi_arprot   ( m_axi_arprot_arr  ),
    .m_axi_arqos    ( m_axi_arqos_arr   ),
    .m_axi_arregion ( m_axi_arregion_arr ),

    // AXI read response channel
    .m_axi_rvalid   ( m_axi_rvalid_arr  ),
    .m_axi_rready   ( m_axi_rready_arr  ),
    .m_axi_rdata    ( m_axi_rdata_arr   ),
    .m_axi_rid      ( m_axi_rid_arr     ),
    .m_axi_rlast    ( m_axi_rlast_arr   ),
    .m_axi_rresp    ( m_axi_rresp_arr   ),

    // DCR write request
    .dcr_wr_valid   ( dcr_wr_valid  ),
    .dcr_wr_addr    ( dcr_wr_addr   ),
    .dcr_wr_data    ( dcr_wr_data   ),

    // Status
    .busy           ( busy )
  );  
endmodule
