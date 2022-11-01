// File Name: hu_sysarray_wrapper.v

module hu_sysarray_wrapper
  (
   clk,
   rstn,
   ext_dco_cc_sel,
   ext_ldo_res_sel,
   interrupt,
   paddr,
   penable,
   psel,
   pwdata,
   pwrite,
   prdata,
   pready,
   pslverr,
   if_data_awvalid,
   if_data_awready,
   if_data_awid,
   if_data_awlen,
   if_data_awaddr,
   if_data_wvalid,
   if_data_wready,
   if_data_wdata,
   if_data_wstrb,
   if_data_wlast,
   if_data_arvalid,
   if_data_arready,
   if_data_arid,
   if_data_arlen,
   if_data_araddr,
   if_data_bresp,
   if_data_bvalid,
   if_data_bready,
   if_data_bid,
   if_data_rvalid,
   if_data_rready,
   if_data_rid,
   if_data_rlast,
   if_data_rdata,
   if_data_rresp,
   if_data_awsize,
   if_data_arsize,
   if_data_awburst,
   if_data_arburst,
   if_data_awlock,
   if_data_arlock,
   if_data_awcache,
   if_data_arcache,
   if_data_awprot,
   if_data_arprot,
   if_data_awqos,
   if_data_awatop,
   if_data_awregion,
   if_data_arqos,
   if_data_arregion,
   );

   ////////////////////////////////////////////////////////////////////////////////
   input clk;
   input rstn;
   output [5:0] ext_dco_cc_sel;
   output [7:0] ext_ldo_res_sel;
   output interrupt;
   //APB
   input psel;
   input penable;
   input pwrite;
   input [31:0] paddr;
   input [31:0] pwdata;
   output [31:0] prdata;
   output pready;
   output pslverr;
   //AXI
   output wire 		 if_data_awvalid;
   input wire 		 if_data_awready;
   output wire [9:0] 	 if_data_awid;
   output wire [7:0] 	 if_data_awlen;
   output wire [32 -1:0] if_data_awaddr;
   output wire 		 if_data_wvalid;
   input wire 		 if_data_wready;
   output wire [64 -1:0] if_data_wdata;
   output wire [64/8-1:0] if_data_wstrb;
   output wire 		  if_data_wlast;
   output wire 		  if_data_arvalid;
   input wire 		  if_data_arready;
   output wire [9:0] 	  if_data_arid;
   output wire [7:0] 	  if_data_arlen;
   output wire [32 -1:0]  if_data_araddr;
   input wire  [1:0]	  if_data_bresp;
   input wire 		  if_data_bvalid;
   output wire 		  if_data_bready;
   input wire [9:0] 	  if_data_bid;
   input wire 		  if_data_rvalid;
   output wire 		  if_data_rready;
   input wire [9:0] 	  if_data_rid;
   input wire 		  if_data_rlast;
   input wire [64 -1:0]   if_data_rdata;
   input wire [1:0] 	  if_data_rresp;
   output wire [2:0] 	  if_data_awsize;
   output wire [2:0] 	  if_data_arsize;
   output wire [1:0] 	  if_data_awburst;
   output wire [1:0] 	  if_data_arburst;
   output wire 		  if_data_awlock;
   output wire 		  if_data_arlock;
   output wire [3:0] 	  if_data_awcache;
   output wire [3:0] 	  if_data_arcache;
   output wire [2:0] 	  if_data_awprot;
   output wire [2:0] 	  if_data_arprot;
   output wire [3:0] 	  if_data_awqos;
   output wire [5:0] 	  if_data_awatop;
   output wire [3:0] 	  if_data_awregion;
   output wire [3:0] 	  if_data_arqos;
   output wire [3:0] 	  if_data_arregion;
   ////////////////////////////////////////////////////////////////////////////////


   // AXI-Lite wires
   wire 		  s_axil_awvalid;
   wire 		  s_axil_awready;
   wire [31:0] 		  s_axil_awaddr;
   wire 		  s_axil_wvalid;
   wire 		  s_axil_wready;
   wire [31:0] 		  s_axil_wdata;
   wire [3:0] 		  s_axil_wstrb;
   wire 		  s_axil_arvalid;
   wire 		  s_axil_arready;
   wire [31:0] 		  s_axil_araddr;
   wire 		  s_axil_rvalid;
   wire 		  s_axil_rready;
   wire [31:0] 		  s_axil_rdata;
   wire [1:0] 		  s_axil_rresp;
   wire 		  s_axil_bvalid;
   wire 		  s_axil_bready;
   wire [1:0] 		  s_axil_bresp;

   // AXI flattened wires
   wire [42:0] 			 if_axi_rd_ar_msg;
   wire [44:0] 			 if_axi_rd_r_msg;
   wire [42:0] 			 if_axi_wr_aw_msg;
   wire [36:0] 			 if_axi_wr_w_msg;
   wire [11:0] 			 if_axi_wr_b_msg;
   wire [49:0] 			 if_data_rd_ar_msg;
   wire [76:0] 			 if_data_rd_r_msg;
   wire [49:0] 			 if_data_wr_aw_msg;
   wire [72:0] 			 if_data_wr_w_msg;
   wire [11:0] 			 if_data_wr_b_msg;

   // set unused wrapper outputs
   assign ext_dco_cc_sel = 6'b0;
   assign ext_ldo_res_sel = 8'b0;

   // set AXI channel ports not present on the interface
   assign if_data_awsize = 3'b011;
   assign if_data_arsize = 3'b011;
   assign if_data_awburst = 2'b01;
   assign if_data_arburst = 2'b01;
   assign if_data_awlock = 1'b0;
   assign if_data_arlock = 1'b0;
   assign if_data_awcache = 4'b0011;
   assign if_data_arcache = 4'b0011;
   assign if_data_awprot = 3'b010;
   assign if_data_arprot = 3'b010;
   assign if_data_awqos = 4'b0000;
   assign if_data_arqos = 4'b0000;
   assign if_data_awatop = 6'b000000;
   assign if_data_awregion = 4'b0000;
   assign if_data_arregion = 4'b0000;

   // APB2AXI-L
   apb2axil apb2axil_inst
     (
      .clk(clk),
      .rstn(rstn),
      .paddr(paddr),
      .penable(penable),
      .psel(psel),
      .pwdata(pwdata),
      .pwrite(pwrite),
      .prdata(prdata),
      .pready(pready),
      .pslverr(pslverr),
      .s_axil_awvalid(s_axil_awvalid),
      .s_axil_awready(s_axil_awready),
      .s_axil_awaddr(s_axil_awaddr),
      .s_axil_wvalid(s_axil_wvalid),
      .s_axil_wready(s_axil_wready),
      .s_axil_wdata(s_axil_wdata),
      .s_axil_wstrb(s_axil_wstrb),
      .s_axil_arvalid(s_axil_arvalid),
      .s_axil_arready(s_axil_arready),
      .s_axil_araddr(s_axil_araddr),
      .s_axil_rvalid(s_axil_rvalid),
      .s_axil_rready(s_axil_rready),
      .s_axil_rdata(s_axil_rdata),
      .s_axil_rresp(s_axil_rresp),
      .s_axil_bvalid(s_axil_bvalid),
      .s_axil_bready(s_axil_bready),
      .s_axil_bresp(s_axil_bresp)
      );


   // Accelerator instance
   // AR-l
   assign if_axi_rd_ar_msg = {1'b0, 32'h0ff & s_axil_araddr, {10{1'b0}}};
   // AW-l
   assign if_axi_wr_aw_msg = {1'b0, 32'h0ff & s_axil_awaddr, {10{1'b0}}};
   // W-l
   assign if_axi_wr_w_msg  = {s_axil_wstrb, 1'b1, s_axil_wdata};
   // R-l
   assign s_axil_rdata = if_axi_rd_r_msg[41:10];
   assign s_axil_rresp = if_axi_rd_r_msg[43:42];
   // B-l
   assign s_axil_bresp = if_axi_wr_b_msg[11:10];

   // AR
   assign if_data_arlen = if_data_rd_ar_msg[49:42];
   assign if_data_araddr = if_data_rd_ar_msg[41:10];
   assign if_data_arid = if_data_rd_ar_msg[9:0];
   // AW
   assign if_data_awlen = if_data_wr_aw_msg[49:42];
   assign if_data_awaddr = if_data_wr_aw_msg[41:10];
   assign if_data_awid = if_data_wr_aw_msg[9:0];
   // W
   assign if_data_wdata = if_data_wr_w_msg[63:0];
   assign if_data_wstrb = if_data_wr_w_msg[72:65];
   assign if_data_wlast = if_data_wr_w_msg[64];
   // R
   assign if_data_rd_r_msg = {if_data_rlast, if_data_rresp, if_data_rdata, if_data_rid};
   // B
   assign if_data_wr_b_msg = {if_data_bresp, if_data_bid};


   hu_sysarray_top_rtl hu_sysarray_top_rtl_0
     (
      .clk(clk),
      .rst(rstn),
      .interrupt(interrupt),
      .if_axi_rd_ar_val(s_axil_arvalid),
      .if_axi_rd_ar_rdy(s_axil_arready),
      .if_axi_rd_ar_msg(if_axi_rd_ar_msg),
      .if_axi_rd_r_val(s_axil_rvalid),
      .if_axi_rd_r_rdy(s_axil_rready),
      .if_axi_rd_r_msg(if_axi_rd_r_msg),
      .if_axi_wr_aw_val(s_axil_awvalid),
      .if_axi_wr_aw_rdy(s_axil_awready),
      .if_axi_wr_aw_msg(if_axi_wr_aw_msg),
      .if_axi_wr_w_val(s_axil_wvalid),
      .if_axi_wr_w_rdy(s_axil_wready),
      .if_axi_wr_w_msg(if_axi_wr_w_msg),
      .if_axi_wr_b_val(s_axil_bvalid),
      .if_axi_wr_b_rdy(s_axil_bready),
      .if_axi_wr_b_msg(if_axi_wr_b_msg),
      .if_data_rd_ar_val(if_data_arvalid),
      .if_data_rd_ar_rdy(if_data_arready),
      .if_data_rd_ar_msg(if_data_rd_ar_msg),
      .if_data_rd_r_val(if_data_rvalid),
      .if_data_rd_r_rdy(if_data_rready),
      .if_data_rd_r_msg(if_data_rd_r_msg),
      .if_data_wr_aw_val(if_data_awvalid),
      .if_data_wr_aw_rdy(if_data_awready),
      .if_data_wr_aw_msg(if_data_wr_aw_msg),
      .if_data_wr_w_val(if_data_wvalid),
      .if_data_wr_w_rdy(if_data_wready),
      .if_data_wr_w_msg(if_data_wr_w_msg),
      .if_data_wr_b_val(if_data_bvalid),
      .if_data_wr_b_rdy(if_data_bready),
      .if_data_wr_b_msg(if_data_wr_b_msg)
      );

endmodule
