// File Name: NV_NVDLA_wrapper.v

module NV_NVDLA_wrapper
  (
   dla_core_clk,
   dla_csb_clk,
   dla_reset_rstn,
   direct_reset,
   paddr,
   penable,
   psel,
   pwdata,
   pwrite,
   prdata,
   pready,
   pslverr,
   nvdla_core2dbb_awvalid,
   nvdla_core2dbb_awready,
   nvdla_core2dbb_awid,
   nvdla_core2dbb_awlen,
   nvdla_core2dbb_awaddr,
   nvdla_core2dbb_wvalid,
   nvdla_core2dbb_wready,
   nvdla_core2dbb_wdata,
   nvdla_core2dbb_wstrb,
   nvdla_core2dbb_wlast,
   nvdla_core2dbb_arvalid,
   nvdla_core2dbb_arready,
   nvdla_core2dbb_arid,
   nvdla_core2dbb_arlen,
   nvdla_core2dbb_araddr,
   nvdla_core2dbb_bresp,
   nvdla_core2dbb_bvalid,
   nvdla_core2dbb_bready,
   nvdla_core2dbb_bid,
   nvdla_core2dbb_rvalid,
   nvdla_core2dbb_rready,
   nvdla_core2dbb_rid,
   nvdla_core2dbb_rlast,
   nvdla_core2dbb_rdata,
   nvdla_core2dbb_rresp,
   nvdla_core2dbb_awsize,
   nvdla_core2dbb_arsize,
   nvdla_core2dbb_awburst,
   nvdla_core2dbb_arburst,
   nvdla_core2dbb_awlock,
   nvdla_core2dbb_arlock,
   nvdla_core2dbb_awcache,
   nvdla_core2dbb_arcache,
   nvdla_core2dbb_awprot,
   nvdla_core2dbb_arprot,
   nvdla_core2dbb_awqos,
   nvdla_core2dbb_awatop,
   nvdla_core2dbb_awregion,
   nvdla_core2dbb_arqos,
   nvdla_core2dbb_arregion,
   dla_intr
   );

   ////////////////////////////////////////////////////////////////////////////////
   input dla_core_clk;
   input dla_csb_clk;
   input dla_reset_rstn;
   input direct_reset;
   //apb
   input psel;
   input penable;
   input pwrite;
   input [31:0] paddr;
   input [31:0] pwdata;
   output [31:0] prdata;
   output pready;
   output pslverr;
   ///////////////
   output wire 		 nvdla_core2dbb_awvalid;
   input wire 		 nvdla_core2dbb_awready;
   output wire [7:0] 	 nvdla_core2dbb_awid;
   output wire [7:0] 	 nvdla_core2dbb_awlen;
   output wire [32 -1:0] nvdla_core2dbb_awaddr;
   output wire 		 nvdla_core2dbb_wvalid;
   input wire 		 nvdla_core2dbb_wready;
   output wire [64 -1:0] nvdla_core2dbb_wdata;
   output wire [64/8-1:0] nvdla_core2dbb_wstrb;
   output wire 		  nvdla_core2dbb_wlast;
   output wire 		  nvdla_core2dbb_arvalid;
   input wire 		  nvdla_core2dbb_arready;
   output wire [7:0] 	  nvdla_core2dbb_arid;
   output wire [7:0] 	  nvdla_core2dbb_arlen;
   output wire [32 -1:0]  nvdla_core2dbb_araddr;
   input wire  [1:0]	  nvdla_core2dbb_bresp;
   input wire 		  nvdla_core2dbb_bvalid;
   output wire 		  nvdla_core2dbb_bready;
   input wire [7:0] 	  nvdla_core2dbb_bid;
   input wire 		  nvdla_core2dbb_rvalid;
   output wire 		  nvdla_core2dbb_rready;
   input wire [7:0] 	  nvdla_core2dbb_rid;
   input wire 		  nvdla_core2dbb_rlast;
   input wire [64 -1:0]   nvdla_core2dbb_rdata;
   input wire [1:0] 	  nvdla_core2dbb_rresp;
   output wire [2:0] 	  nvdla_core2dbb_awsize;
   output wire [2:0] 	  nvdla_core2dbb_arsize;
   output wire [1:0] 	  nvdla_core2dbb_awburst;
   output wire [1:0] 	  nvdla_core2dbb_arburst;
   output wire 		  nvdla_core2dbb_awlock;
   output wire 		  nvdla_core2dbb_arlock;
   output wire [3:0] 	  nvdla_core2dbb_awcache;
   output wire [3:0] 	  nvdla_core2dbb_arcache;
   output wire [2:0] 	  nvdla_core2dbb_awprot;
   output wire [2:0] 	  nvdla_core2dbb_arprot;
   output wire [3:0] 	  nvdla_core2dbb_awqos;
   output wire [5:0] 	  nvdla_core2dbb_awatop;
   output wire [3:0] 	  nvdla_core2dbb_awregion;
   output wire [3:0] 	  nvdla_core2dbb_arqos;
   output wire [3:0] 	  nvdla_core2dbb_arregion;
   ///////////////
   output 		  dla_intr;
   ////////////////////////////////////////////////////////////////////////////////

   // CSB connections
   wire 		  csb2nvdla_valid;
   wire 		  csb2nvdla_ready;
   wire [15:0] 		  csb2nvdla_addr;
   wire [31:0] 		  csb2nvdla_wdat;
   wire 		  csb2nvdla_write;
   wire 		  csb2nvdla_nposted;
   wire 		  nvdla2csb_valid;
   wire [31:0] 		  nvdla2csb_data;
   // NVDLA ports not used
   wire 		  global_clk_ovr_on;
   wire 		  tmc2slcg_disable_clock_gating;
   wire 		  test_mode;
   wire 		  nvdla2csb_wr_complete;
   wire [31:0] 		  nvdla_pwrbus_ram_c_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_ma_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_mb_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_p_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_o_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_a_pd;
   ///////////////

   // set NVDLA ports not used
   assign global_clk_ovr_on = 1'b0;
   assign tmc2slcg_disable_clock_gating = 1'b0;
   assign test_mode = 1'b0;
   assign nvdla_pwrbus_ram_c_pd = 32'b0;
   assign nvdla_pwrbus_ram_ma_pd = 32'b0;
   assign nvdla_pwrbus_ram_mb_pd = 32'b0;
   assign nvdla_pwrbus_ram_p_pd = 32'b0;
   assign nvdla_pwrbus_ram_o_pd = 32'b0;
   assign nvdla_pwrbus_ram_a_pd = 32'b0;
   assign pslverr = 1'b0;
   
   // map NVDLA dbb channel to an AXI channel
   // set AXI channel ports not present on the NVDLA interface
   assign nvdla_core2dbb_awsize = 3'b011;
   assign nvdla_core2dbb_arsize = 3'b011;
   assign nvdla_core2dbb_awburst = 2'b01;
   assign nvdla_core2dbb_arburst = 2'b01;
   assign nvdla_core2dbb_awlock = 1'b0;
   assign nvdla_core2dbb_arlock = 1'b0;
   assign nvdla_core2dbb_awcache = 4'b0011;
   assign nvdla_core2dbb_arcache = 4'b0011;
   assign nvdla_core2dbb_awprot = 3'b010;
   assign nvdla_core2dbb_arprot = 3'b010;
   assign nvdla_core2dbb_awqos = 4'b0000;
   assign nvdla_core2dbb_arqos = 4'b0000;
   assign nvdla_core2dbb_awatop = 6'b000000;
   assign nvdla_core2dbb_awregion = 4'b0000;
   assign nvdla_core2dbb_arregion = 4'b0000;

   assign nvdla_core2dbb_awlen[7:4] = 4'b0000;
   assign nvdla_core2dbb_arlen[7:4] = 4'b0000;

   NV_nvdla NV_nvdla_0
     (
      .dla_core_clk(dla_core_clk) //|< i
      ,.dla_csb_clk(dla_csb_clk) //|< i
      ,.global_clk_ovr_on(global_clk_ovr_on) //|< i
      ,.tmc2slcg_disable_clock_gating(tmc2slcg_disable_clock_gating) //|< i
      ,.dla_reset_rstn(dla_reset_rstn) //|< i
      ,.direct_reset_(direct_reset) //|< i
      ,.test_mode(test_mode) //|< i
      ,.csb2nvdla_valid(csb2nvdla_valid) //|< i
      ,.csb2nvdla_ready(csb2nvdla_ready) //|> o
      ,.csb2nvdla_addr(csb2nvdla_addr) //|< i
      ,.csb2nvdla_wdat(csb2nvdla_wdat) //|< i
      ,.csb2nvdla_write(csb2nvdla_write) //|< i
      ,.csb2nvdla_nposted(csb2nvdla_nposted) //|< i
      ,.nvdla2csb_valid(nvdla2csb_valid) //|> o
      ,.nvdla2csb_data(nvdla2csb_data) //|> o
      ,.nvdla2csb_wr_complete() //|> o
      ,.nvdla_core2dbb_aw_awvalid(nvdla_core2dbb_awvalid) //|> o
      ,.nvdla_core2dbb_aw_awready(nvdla_core2dbb_awready) //|< i
      ,.nvdla_core2dbb_aw_awid(nvdla_core2dbb_awid) //|> o
      ,.nvdla_core2dbb_aw_awlen(nvdla_core2dbb_awlen[3:0]) //|> o
      ,.nvdla_core2dbb_aw_awaddr(nvdla_core2dbb_awaddr) //|> o
      ,.nvdla_core2dbb_w_wvalid(nvdla_core2dbb_wvalid) //|> o
      ,.nvdla_core2dbb_w_wready(nvdla_core2dbb_wready) //|< i
      ,.nvdla_core2dbb_w_wdata(nvdla_core2dbb_wdata) //|> o
      ,.nvdla_core2dbb_w_wstrb(nvdla_core2dbb_wstrb) //|> o
      ,.nvdla_core2dbb_w_wlast(nvdla_core2dbb_wlast) //|> o
      ,.nvdla_core2dbb_b_bvalid(nvdla_core2dbb_bvalid) //|< i
      ,.nvdla_core2dbb_b_bready(nvdla_core2dbb_bready) //|> o
      ,.nvdla_core2dbb_b_bid(nvdla_core2dbb_bid) //|< i
      ,.nvdla_core2dbb_ar_arvalid(nvdla_core2dbb_arvalid) //|> o
      ,.nvdla_core2dbb_ar_arready(nvdla_core2dbb_arready) //|< i
      ,.nvdla_core2dbb_ar_arid(nvdla_core2dbb_arid) //|> o
      ,.nvdla_core2dbb_ar_arlen(nvdla_core2dbb_arlen[3:0]) //|> o
      ,.nvdla_core2dbb_ar_araddr(nvdla_core2dbb_araddr) //|> o
      ,.nvdla_core2dbb_r_rvalid(nvdla_core2dbb_rvalid) //|< i
      ,.nvdla_core2dbb_r_rready(nvdla_core2dbb_rready) //|> o
      ,.nvdla_core2dbb_r_rid(nvdla_core2dbb_rid) //|< i
      ,.nvdla_core2dbb_r_rlast(nvdla_core2dbb_rlast) //|< i
      ,.nvdla_core2dbb_r_rdata(nvdla_core2dbb_rdata) //|< i
      ,.dla_intr(dla_intr) //|> o
      ,.nvdla_pwrbus_ram_c_pd(nvdla_pwrbus_ram_c_pd) //|< i
      ,.nvdla_pwrbus_ram_ma_pd(nvdla_pwrbus_ram_ma_pd) //|< i *
      ,.nvdla_pwrbus_ram_mb_pd(nvdla_pwrbus_ram_mb_pd) //|< i *
      ,.nvdla_pwrbus_ram_p_pd(nvdla_pwrbus_ram_p_pd) //|< i
      ,.nvdla_pwrbus_ram_o_pd(nvdla_pwrbus_ram_o_pd) //|< i
      ,.nvdla_pwrbus_ram_a_pd(nvdla_pwrbus_ram_a_pd) //|< i
      );

   NV_NVDLA_apb2csb apb2csb_0
     (
      .pclk(dla_csb_clk)
      ,.prstn(dla_reset_rstn)
      ,.csb2nvdla_ready(csb2nvdla_ready)
      ,.nvdla2csb_data(nvdla2csb_data)
      ,.nvdla2csb_valid(nvdla2csb_valid)
      ,.paddr(paddr)
      ,.penable(penable)
      ,.psel(psel)
      ,.pwdata(pwdata)
      ,.pwrite(pwrite)
      ,.csb2nvdla_addr(csb2nvdla_addr)
      ,.csb2nvdla_nposted(csb2nvdla_nposted)
      ,.csb2nvdla_valid(csb2nvdla_valid)
      ,.csb2nvdla_wdat(csb2nvdla_wdat)
      ,.csb2nvdla_write(csb2nvdla_write)
      ,.prdata(prdata)
      ,.pready(pready)
      );

   
endmodule
