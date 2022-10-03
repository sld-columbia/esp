// File Name: GT_VORTEX_wrapper.v
// Originally NVDLA wrapper modified

//    parameter AXI_DATA_WIDTH   = `VX_MEM_DATA_WIDTH,
//    parameter AXI_ADDR_WIDTH   = 32,
//    parameter AXI_TID_WIDTH    = `VX_MEM_TAG_WIDTH,    
//    parameter AXI_STROBE_WIDTH = (`VX_MEM_DATA_WIDTH / 8)
`include "VX_define.vh"
`include "VX_config.vh"
module GT_VORTEX_wrapper #(
   parameter AXI_DATA_WIDTH   = `VX_MEM_DATA_WIDTH,
   parameter AXI_ADDR_WIDTH   = 32,
   parameter AXI_TID_WIDTH    = `VX_MEM_TAG_WIDTH,
   parameter AXI_STROBE_WIDTH = (`VX_MEM_DATA_WIDTH / 8)
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
   busy
   );

   ////////////////////////////////////////////////////////////////////////////////
   ///////////////
   // Clock
    input  wire                         clk;
    input  wire                         reset;

   // AXI write request address channel
    output wire [AXI_TID_WIDTH-1:0]     m_axi_awid;
    output wire [AXI_ADDR_WIDTH-1:0]    m_axi_awaddr;
    output wire [7:0]                   m_axi_awlen;
    output wire [2:0]                   m_axi_awsize;
    output wire [1:0]                   m_axi_awburst;
    output wire                         m_axi_awlock;
    output wire [3:0]                   m_axi_awcache;
    output wire [2:0]                   m_axi_awprot;
    output wire [3:0]                   m_axi_awqos;
    output wire                         m_axi_awvalid;
    input wire                          m_axi_awready;

    // AXI write request data channel
    output wire [AXI_DATA_WIDTH-1:0]    m_axi_wdata;
    output wire [AXI_STROBE_WIDTH-1:0]  m_axi_wstrb;
    output wire                         m_axi_wlast;
    output wire                         m_axi_wvalid;
    input wire                          m_axi_wready;

    // AXI write response channel
    input wire [AXI_TID_WIDTH-1:0]      m_axi_bid;
    input wire [1:0]                    m_axi_bresp;
    input wire                          m_axi_bvalid;
    output wire                         m_axi_bready;

    // AXI read request channel
    output wire [AXI_TID_WIDTH-1:0]     m_axi_arid;
    output wire [AXI_ADDR_WIDTH-1:0]    m_axi_araddr;
    output wire [7:0]                   m_axi_arlen;
    output wire [2:0]                   m_axi_arsize;
    output wire [1:0]                   m_axi_arburst;
    output wire                         m_axi_arlock;
    output wire [3:0]                   m_axi_arcache;
    output wire [2:0]                   m_axi_arprot;
    output wire [3:0]                   m_axi_arqos;
    output wire                         m_axi_arvalid;
    input  wire                         m_axi_arready;

    // AXI read response channel
    input wire [AXI_TID_WIDTH-1:0]      m_axi_rid;
    input wire [AXI_DATA_WIDTH-1:0]     m_axi_rdata;
    input wire [1:0]                    m_axi_rresp;
    input wire                          m_axi_rlast;
    input wire                          m_axi_rvalid;
    output wire                         m_axi_rready;

    // Status
    output wire                         busy;
    output wire [5:0] 		        m_axi_awatop;
   
    // APB for configuration and memory offset 
   input psel;
   input penable;
   input pwrite;
   input [31:0] paddr;
   input [31:0] pwdata;
   output reg [31:0] prdata;
   output pready;
   output pslverr;
   output wire [3:0]      m_axi_awregion;
   output wire [3:0]      m_axi_arregion;
   ////////////////////////////////////////////////////////////////////////////////
   parameter RESET_DELAY = 12; 
   
   // Unused wires 
   assign m_axi_awatop   =    4'b0; 
   assign m_axi_awregion =    4'b0; 

    // Configuration Registers
   reg vx_reset_soft = 0;
   reg [31:0] addr;
   reg  vx_started = 1'b0; // Indicates that vortex is started and running for multicycle reset.
   reg  vx_reset   = 1'b0; 
   wire apb_write = psel & penable & pwrite;
   wire apb_read  = psel & ~pwrite;
   reg [$clog2(`RESET_DELAY+1)-1:0] vx_reset_ctr;
   wire [AXI_ADDR_WIDTH-1:0] m_axi_araddr_raw; 
   wire [AXI_ADDR_WIDTH-1:0] m_axi_awaddr_raw;
   wire vx_busy_int = busy;
   assign pready  = 1'b1;
   assign pslverr = 1'b0;
   // Adding the base address to the memory addresses reserved for Vortex programs
   assign m_axi_araddr = m_axi_araddr_raw + addr; // FIXME: check for comb loop 
   assign m_axi_awaddr = m_axi_awaddr_raw + addr; // FIXME: check for comb loop
   assign vx_busy_int  = busy;  
    // Detecting positive edge of reset
   reg   reset_dly, reset_pe;                          
   always @ (posedge clk) begin
        reset_dly <= reset;
   end
   
   assign reset_pe = reset & ~reset_dly; // Positive edge of reset

   always @(posedge clk) begin
      if (reset_pe) begin
         addr           <= 32'b0; // reset initial value 
         vx_reset_soft  <= 1'b0;  // Software reset to start Vortex 
	 prdata         <= 32'b0;
	 vx_reset       <= 1'b0;
	 vx_started     <= 1'b0;
      end // reset 
      if (apb_write) begin
        case (paddr[7:0])
          8'h50 : addr          <= pwdata;
	  8'h54 : vx_reset_soft <= pwdata[0]; 
        endcase
      end  // write
      else begin
         
        case (paddr[7:0])
           8'h50 : prdata    <= addr; 
           8'h58 : prdata[0] <= vx_busy_int; // Interrupt Read only
           8'h54 : prdata[0] <= vx_reset_soft;	
        endcase
      end // read

   end // always 
  
   always @(posedge clk) begin
      if (vx_started == 0 && vx_reset_soft == 1) begin
         vx_reset_ctr <= 0;
      end else if (vx_started == 1) begin
         vx_reset_ctr <= vx_reset_ctr + 1;
      end
   end

   always @(posedge clk) begin
      if (vx_reset_soft == 1 && vx_started == 0) begin
	 vx_reset   <= 1;
	 vx_started <= 1;
      end // end reset begin if
      // Vortex reset cycles
      if (vx_reset_ctr == (`RESET_DELAY-1) && vx_started == 1'b1) begin
         vx_reset   <= 1'b0;
      end // end delay to reset if
   end // always
    
   Vortex_axi  #(
    .AXI_DATA_WIDTH    (`VX_MEM_DATA_WIDTH),
    .AXI_ADDR_WIDTH    (32),
    .AXI_TID_WIDTH     (`VX_MEM_TAG_WIDTH),
    .AXI_STROBE_WIDTH  (`VX_MEM_DATA_WIDTH / 8) 
    )Vortex_axi_0 (
    .clk            ( clk & vx_started  ),
    .reset          ( vx_reset ),

    .m_axi_awid     ( m_axi_awid    ),
    .m_axi_awaddr   ( m_axi_awaddr_raw  ),
    .m_axi_awlen    ( m_axi_awlen   ),
    .m_axi_awsize   ( m_axi_awsize  ),
    .m_axi_awburst  ( m_axi_awburst ),
    .m_axi_awlock   ( m_axi_awlock  ),
    .m_axi_awcache  ( m_axi_awcache ),
    .m_axi_awprot   ( m_axi_awprot  ),
    .m_axi_awqos    ( m_axi_awqos   ),
    .m_axi_awvalid  ( m_axi_awvalid ),
    .m_axi_awready  ( m_axi_awready ),

    .m_axi_wdata    ( m_axi_wdata   ),
    .m_axi_wstrb    ( m_axi_wstrb   ),
    .m_axi_wlast    ( m_axi_wlast   ),
    .m_axi_wvalid   ( m_axi_wvalid  ),
    .m_axi_wready   ( m_axi_wready  ),

    .m_axi_bid      ( m_axi_bid     ),
    .m_axi_bresp    ( m_axi_bresp   ),
    .m_axi_bvalid   ( m_axi_bvalid  ),
    .m_axi_bready   ( m_axi_bready  ),

    .m_axi_arid     ( m_axi_arid    ),
    .m_axi_araddr   ( m_axi_araddr_raw ),
    .m_axi_arlen    ( m_axi_arlen   ),
    .m_axi_arsize   ( m_axi_arsize  ),
    .m_axi_arburst  ( m_axi_arburst ),
    .m_axi_arlock   ( m_axi_arlock  ),
    .m_axi_arcache  ( m_axi_arcache ),
    .m_axi_arprot   ( m_axi_arprot  ),
    .m_axi_arqos    ( m_axi_arqos   ),
    .m_axi_arvalid  ( m_axi_arvalid ),
    .m_axi_arready  ( m_axi_arready ),

    .m_axi_rid      ( m_axi_rid     ),
    .m_axi_rdata    ( m_axi_rdata   ),
    .m_axi_rresp    ( m_axi_rresp   ),
    .m_axi_rlast    ( m_axi_rlast   ),
    .m_axi_rvalid   ( m_axi_rvalid  ),
    .m_axi_rready   ( m_axi_rready  ),

    .busy           ( busy )
  );  
endmodule
