// File Name: GT_VORTEX_wrapper.v
// Originally NVDLA wrapper modified

//    parameter AXI_DATA_WIDTH   = `VX_MEM_DATA_WIDTH,
//    parameter AXI_ADDR_WIDTH   = 32,
//    parameter AXI_TID_WIDTH    = `VX_MEM_TAG_WIDTH,    
//    parameter AXI_STROBE_WIDTH = (`VX_MEM_DATA_WIDTH / 8)
`include "VX_config.vh"
`include "VX_define.vh"

`ifndef DEBUG_XILINX

`ifdef SYNTHESIS
  `define DEBUG_XILINX (* mark_debug = "true" *)
`else 
  `define DEBUG_XILINX
`endif // !SYNTHESIS

`endif // !DEBUG_XILINX
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
    `DEBUG_XILINX input  wire                         reset;

   // AXI write request address channel
    `DEBUG_XILINX output wire [AXI_TID_WIDTH-1:0]     m_axi_awid;
    `DEBUG_XILINX output wire [AXI_ADDR_WIDTH-1:0]    m_axi_awaddr;
    `DEBUG_XILINX output wire [7:0]                   m_axi_awlen;
    `DEBUG_XILINX output wire [2:0]                   m_axi_awsize;
    output wire [1:0]                   m_axi_awburst;
    output wire                         m_axi_awlock;
    output wire [3:0]                   m_axi_awcache;
    output wire [2:0]                   m_axi_awprot;
    output wire [3:0]                   m_axi_awqos;
    `DEBUG_XILINX output wire                         m_axi_awvalid;
    `DEBUG_XILINX input wire                          m_axi_awready;

    // AXI write request data channel
    `DEBUG_XILINX output wire [AXI_DATA_WIDTH-1:0]    m_axi_wdata;
    `DEBUG_XILINX output wire [AXI_STROBE_WIDTH-1:0]  m_axi_wstrb;
    `DEBUG_XILINX output wire                         m_axi_wlast;
    `DEBUG_XILINX output wire                         m_axi_wvalid;
    `DEBUG_XILINX input wire                          m_axi_wready;

    // AXI write response channel
    `DEBUG_XILINX input wire [AXI_TID_WIDTH-1:0]      m_axi_bid;
    `DEBUG_XILINX input wire [1:0]                    m_axi_bresp;
    `DEBUG_XILINX input wire                          m_axi_bvalid;
    `DEBUG_XILINX output wire                         m_axi_bready;

    // AXI read request channel
    `DEBUG_XILINX output wire [AXI_TID_WIDTH-1:0]     m_axi_arid;
    `DEBUG_XILINX output wire [AXI_ADDR_WIDTH-1:0]    m_axi_araddr;
    `DEBUG_XILINX output wire [7:0]                   m_axi_arlen;
    `DEBUG_XILINX output wire [2:0]                   m_axi_arsize;
    `DEBUG_XILINX output wire [1:0]                   m_axi_arburst;
    `DEBUG_XILINX output wire                         m_axi_arlock;
    `DEBUG_XILINX output wire [3:0]                   m_axi_arcache;
    `DEBUG_XILINX output wire [2:0]                   m_axi_arprot;
    `DEBUG_XILINX output wire [3:0]                   m_axi_arqos;
    `DEBUG_XILINX output wire                         m_axi_arvalid;
    `DEBUG_XILINX input  wire                         m_axi_arready;

    // AXI read response channel
    `DEBUG_XILINX input wire [AXI_TID_WIDTH-1:0]      m_axi_rid;
    `DEBUG_XILINX input wire [AXI_DATA_WIDTH-1:0]     m_axi_rdata;
    `DEBUG_XILINX input wire [1:0]                    m_axi_rresp;
    `DEBUG_XILINX input wire                          m_axi_rlast;
    `DEBUG_XILINX input wire                          m_axi_rvalid;
    `DEBUG_XILINX output wire                         m_axi_rready;

    // Status
    `DEBUG_XILINX output wire                         busy;
    output wire [5:0] 		        m_axi_awatop;
   
    // APB for configuration and memory offset 
   input psel;
   input penable;
   input pwrite;
   `DEBUG_XILINX input [31:0] paddr;
   `DEBUG_XILINX input [31:0] pwdata;
   `DEBUG_XILINX output reg [31:0] prdata;
   output pready;
   output pslverr;
   output wire [3:0]      m_axi_awregion;
   output wire [3:0]      m_axi_arregion;
   ////////////////////////////////////////////////////////////////////////////////
   // parameter RESET_DELAY = 1; 
   
   // Unused wires 
   assign m_axi_awatop   =    4'b0; 
   assign m_axi_awregion =    4'b0; 
  
    // Configuration Registers
   `DEBUG_XILINX reg vx_reset_soft=0;
   `DEBUG_XILINX reg [31:0] addr;
   `DEBUG_XILINX reg  vx_started = 1'b0; // Indicates that vortex is started and running for multicycle reset.
   `DEBUG_XILINX reg  vx_reset   = 1'b0; 
   `DEBUG_XILINX wire apb_write = psel & penable & pwrite;
   `DEBUG_XILINX wire apb_read  = psel & ~pwrite;
   `DEBUG_XILINX reg [$clog2(`RESET_DELAY+1)-1:0] vx_reset_ctr;
   `DEBUG_XILINX wire [31:0] m_axi_araddr_raw; 
   `DEBUG_XILINX wire [31:0] m_axi_awaddr_raw;
   assign pready  = 1'b1;
   assign pslverr = 1'b0;
   // Adding the base address to the memory addresses reserved for Vortex programs
   assign m_axi_araddr = m_axi_araddr_raw + addr; 
   assign m_axi_awaddr = m_axi_awaddr_raw + addr;
    // Detecting positive edge of reset
   //`DEBUG_XILINX reg   reset_dly, reset_pe;                          
   //always @ (posedge clk) begin
   //     reset_dly <= reset;
   // end
   
   // assign reset_pe = reset & ~reset_dly; // Positive edge of reset
  
   wire cmd_run_done = !busy; // To reset vortex when done 
   // Clk gating to clock vortex only after copying data to memory to avoid
   // invalid vx caches
   wire vx_clk; 
   BUFGCE vx_clk_en(
	  .O(vx_clk),
	  .CE(vx_started),
	  .I(clk)
  	);

   always @(posedge clk) begin
      if (!reset) begin
         addr           <= 32'b0; // reset initial value 
         vx_reset_soft  <= 1'b0;  // Software reset to start Vortex 
      end // reset
      else begin
	if (apb_write) begin
          case (paddr[7:0])
            8'h50 : addr          <= pwdata;
	    8'h54 : vx_reset_soft <= pwdata[0];  
          endcase
        end  // write
     end // !reset
   end // always 
   
   always @(*) begin
	if(!reset)
	       prdata =0; 
	else if(apb_read) begin 
          case (paddr[7:0])
            8'h58 : prdata[0] = busy; // Interrupt Read only
            8'h54 : prdata[0] = vx_reset_soft; 
            8'h50 : prdata    = addr; 
	    default: prdata[0] = 0;	    
          endcase
        end // read
   end //always
   
   always @(posedge clk) begin
     
     if (!reset || cmd_run_done) begin
 	 // vx_reset    <= 1'b0;
         vx_started	<= 1'b0;
         vx_reset_ctr   <= 0;
      end else begin   
       
       if (vx_reset_soft == 1'b1 && vx_started == 1'b0) begin
	 vx_reset   <= 1'b1;
	 vx_started <= 1'b1;
       end // end reset begin if
       
       // Vortex reset cycles
       else if (vx_reset_ctr == (`RESET_DELAY-1) && vx_reset == 1'b1) begin
         vx_reset   <= 1'b0;
       end // end delay to reset if
       else if (vx_reset == 1'b1) begin
         vx_reset_ctr <= vx_reset_ctr + 1; 
       end

       //if (vx_started == 0 && vx_reset_soft == 1) begin
       //  vx_reset_ctr <= 0;
       //end else if (vx_started == 1) begin
       //  vx_reset_ctr <= vx_reset_ctr + 1;
       //end
     end // !reset
   end // always
  
   Vortex_axi  #(
    .AXI_DATA_WIDTH    (`VX_MEM_DATA_WIDTH),
    .AXI_ADDR_WIDTH    (32),
    .AXI_TID_WIDTH     (`VX_MEM_TAG_WIDTH),
    .AXI_STROBE_WIDTH  (`VX_MEM_DATA_WIDTH / 8) 
    )Vortex_axi_0 (
    .clk            ( vx_clk   ),
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

