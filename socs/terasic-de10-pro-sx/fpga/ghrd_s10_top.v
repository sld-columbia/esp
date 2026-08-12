// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module ghrd_s10_top (
    input  wire        CLK_50_B3C,
    input  wire        CPU_RESET_n,

    input  wire        DDR4A_REFCLK_p,
    output wire [16:0] DDR4A_A,
    output wire [1:0]  DDR4A_BA,
    output wire [1:0]  DDR4A_BG,
    output wire        DDR4A_CK,
    output wire        DDR4A_CK_n,
    output wire        DDR4A_CKE,
    inout  wire [8:0]  DDR4A_DQS,
    inout  wire [8:0]  DDR4A_DQS_n,
    inout  wire [71:0] DDR4A_DQ,
    inout  wire [8:0]  DDR4A_DBI_n,
    output wire        DDR4A_CS_n,
    output wire        DDR4A_RESET_n,
    output wire        DDR4A_ODT,
    output wire        DDR4A_PAR,
    input  wire        DDR4A_ALERT_n,
    output wire        DDR4A_ACT_n,
    input  wire        DDR4A_RZQ,

    output wire        HPS_EMAC0_TX_CLK,
    output wire        HPS_EMAC0_TX_CTL,
    input  wire        HPS_EMAC0_RX_CLK,
    input  wire        HPS_EMAC0_RX_CTL,
    output wire [3:0]  HPS_EMAC0_TXD,
    input  wire [3:0]  HPS_EMAC0_RXD,
    inout  wire        HPS_EMAC0_MDIO,
    output wire        HPS_EMAC0_MDC,

    output wire        HPS_UART0_TX,
    input  wire        HPS_UART0_RX,

    output wire        HPS_SD_CLK,
    inout  wire        HPS_SD_CMD,
    inout  wire [3:0]  HPS_SD_DATA,
    input  wire        HPS_OSC_CLK,
    inout  wire        HPS_CARD_PRSNT_n,

    inout  wire        FAN_I2C_SCL,
    inout  wire        FAN_I2C_SDA,
    input  wire        FAN_ALERT_n,

    inout  wire [3:0]  GPIO_P
);

wire        src_reset_n;
wire        h2f_reset;
wire        system_reset_n;
wire        fpga_clk;
wire [31:0] f2h_irq1_irq;

assign fpga_clk = CLK_50_B3C;
assign system_reset_n = CPU_RESET_n & src_reset_n & ~h2f_reset;
assign f2h_irq1_irq = 32'd0;

de10_pro_fan_controller #(
    .TARGET_RPM(13'd2200),
    .CLK_HZ(50000000),
    .I2C_HZ(100000)
) u_fan_controller (
    .clk(fpga_clk),
    .reset_n(system_reset_n),
    .fan_alert_n(FAN_ALERT_n),
    .alert_type(),
    .fan0_rpm(),
    .fan1_rpm(),
    .fan_i2c_scl(FAN_I2C_SCL),
    .fan_i2c_sda(FAN_I2C_SDA)
);

wire [3:0]  h2f_awid;
wire [31:0] h2f_awaddr;
wire [7:0]  h2f_awlen;
wire [2:0]  h2f_awsize;
wire [1:0]  h2f_awburst;
wire        h2f_awlock;
wire [3:0]  h2f_awcache;
wire [2:0]  h2f_awprot;
wire        h2f_awvalid;
wire        h2f_awready;
wire [31:0] h2f_wdata;
wire [3:0]  h2f_wstrb;
wire        h2f_wlast;
wire        h2f_wvalid;
wire        h2f_wready;
wire [3:0]  h2f_bid;
wire [1:0]  h2f_bresp;
wire        h2f_bvalid;
wire        h2f_bready;
wire [3:0]  h2f_arid;
wire [31:0] h2f_araddr;
wire [7:0]  h2f_arlen;
wire [2:0]  h2f_arsize;
wire [1:0]  h2f_arburst;
wire        h2f_arlock;
wire [3:0]  h2f_arcache;
wire [2:0]  h2f_arprot;
wire        h2f_arvalid;
wire        h2f_arready;
wire [3:0]  h2f_rid;
wire [31:0] h2f_rdata;
wire [1:0]  h2f_rresp;
wire        h2f_rlast;
wire        h2f_rvalid;
wire        h2f_rready;

wire [3:0]  f2s_awid;
wire [31:0] esp_f2s_awaddr;
wire [32:0] hps_f2s_awaddr;
wire [7:0]  f2s_awlen;
wire [2:0]  f2s_awsize;
wire [1:0]  f2s_awburst;
wire        f2s_awlock;
wire [3:0]  f2s_awcache;
wire [2:0]  esp_f2s_awprot;
wire [3:0]  f2s_awqos;
wire        f2s_awvalid;
wire        f2s_awready;
wire [63:0] f2s_wdata;
wire [7:0]  f2s_wstrb;
wire        f2s_wlast;
wire        f2s_wvalid;
wire        f2s_wready;
wire [3:0]  f2s_bid;
wire [1:0]  f2s_bresp;
wire        f2s_bvalid;
wire        f2s_bready;
wire [3:0]  f2s_arid;
wire [31:0] esp_f2s_araddr;
wire [32:0] hps_f2s_araddr;
wire [7:0]  f2s_arlen;
wire [2:0]  f2s_arsize;
wire [1:0]  f2s_arburst;
wire        f2s_arlock;
wire [3:0]  f2s_arcache;
wire [2:0]  esp_f2s_arprot;
wire [3:0]  f2s_arqos;
wire        f2s_arvalid;
wire        f2s_arready;
wire [3:0]  f2s_rid;
wire [63:0] f2s_rdata;
wire [1:0]  f2s_rresp;
wire        f2s_rlast;
wire        f2s_rvalid;
wire        f2s_rready;

wire        mo_hlock;
wire [1:0]  mo_htrans;
wire [31:0] mo_haddr;
wire        mo_hwrite;
wire [2:0]  mo_hsize;
wire [2:0]  mo_hburst;
wire [3:0]  mo_hprot;
wire [31:0] mo_hwdata;
wire        mi_hready;
wire [1:0]  mi_hresp;
wire [31:0] mi_hrdata;
wire        mi_hgrant;

wire        esp_uart_txd;
wire        esp_uart_rtsn;

assign hps_f2s_awaddr = {1'b1, esp_f2s_awaddr};
assign hps_f2s_araddr = {1'b1, esp_f2s_araddr};
assign GPIO_P[1] = esp_uart_txd;
assign GPIO_P[3] = esp_uart_rtsn;

qsys_top u_hps_system (
    .src_prb_rst_sources_source(src_reset_n),
    .reset_reset_n(system_reset_n),
    .clk_100_clk(fpga_clk),
    .s10_hps_f2h_stm_hw_events_stm_hwevents(43'd0),

    .emif_hps_pll_ref_clk_clk(DDR4A_REFCLK_p),
    .emif_hps_mem_mem_ck(DDR4A_CK),
    .emif_hps_mem_mem_ck_n(DDR4A_CK_n),
    .emif_hps_mem_mem_a(DDR4A_A),
    .emif_hps_mem_mem_act_n(DDR4A_ACT_n),
    .emif_hps_mem_mem_ba(DDR4A_BA),
    .emif_hps_mem_mem_bg(DDR4A_BG),
    .emif_hps_mem_mem_cke(DDR4A_CKE),
    .emif_hps_mem_mem_cs_n(DDR4A_CS_n),
    .emif_hps_mem_mem_odt(DDR4A_ODT),
    .emif_hps_mem_mem_reset_n(DDR4A_RESET_n),
    .emif_hps_mem_mem_par(DDR4A_PAR),
    .emif_hps_mem_mem_alert_n(DDR4A_ALERT_n),
    .emif_hps_mem_mem_dqs(DDR4A_DQS),
    .emif_hps_mem_mem_dqs_n(DDR4A_DQS_n),
    .emif_hps_mem_mem_dq(DDR4A_DQ),
    .emif_hps_mem_mem_dbi_n(DDR4A_DBI_n),
    .emif_hps_oct_oct_rzqin(DDR4A_RZQ),

    .hps_io_hps_io_phery_emac0_TX_CLK(HPS_EMAC0_TX_CLK),
    .hps_io_hps_io_phery_emac0_RX_CLK(HPS_EMAC0_RX_CLK),
    .hps_io_hps_io_phery_emac0_TX_CTL(HPS_EMAC0_TX_CTL),
    .hps_io_hps_io_phery_emac0_RX_CTL(HPS_EMAC0_RX_CTL),
    .hps_io_hps_io_phery_emac0_TXD0(HPS_EMAC0_TXD[0]),
    .hps_io_hps_io_phery_emac0_TXD1(HPS_EMAC0_TXD[1]),
    .hps_io_hps_io_phery_emac0_RXD0(HPS_EMAC0_RXD[0]),
    .hps_io_hps_io_phery_emac0_RXD1(HPS_EMAC0_RXD[1]),
    .hps_io_hps_io_phery_emac0_TXD2(HPS_EMAC0_TXD[2]),
    .hps_io_hps_io_phery_emac0_TXD3(HPS_EMAC0_TXD[3]),
    .hps_io_hps_io_phery_emac0_RXD2(HPS_EMAC0_RXD[2]),
    .hps_io_hps_io_phery_emac0_RXD3(HPS_EMAC0_RXD[3]),
    .hps_io_hps_io_phery_uart0_TX(HPS_UART0_TX),
    .hps_io_hps_io_phery_uart0_RX(HPS_UART0_RX),
    .hps_io_hps_io_phery_sdmmc_CCLK(HPS_SD_CLK),
    .hps_io_hps_io_phery_sdmmc_CMD(HPS_SD_CMD),
    .hps_io_hps_io_phery_sdmmc_D0(HPS_SD_DATA[0]),
    .hps_io_hps_io_phery_sdmmc_D1(HPS_SD_DATA[1]),
    .hps_io_hps_io_phery_sdmmc_D2(HPS_SD_DATA[2]),
    .hps_io_hps_io_phery_sdmmc_D3(HPS_SD_DATA[3]),
    .hps_io_hps_io_hps_ocs_clk(HPS_OSC_CLK),
    .hps_io_hps_io_gpio_gpio1_io20(HPS_CARD_PRSNT_n),
    .hps_io_hps_io_phery_emac0_MDIO(HPS_EMAC0_MDIO),
    .hps_io_hps_io_phery_emac0_MDC(HPS_EMAC0_MDC),

    .f2h_irq1_irq(f2h_irq1_irq),
    .h2f_reset_reset(h2f_reset),

    .s10_hps_h2f_axi_clock_clk(fpga_clk),
    .s10_hps_h2f_axi_reset_reset_n(system_reset_n),
    .s10_hps_h2f_axi_master_awid(h2f_awid),
    .s10_hps_h2f_axi_master_awaddr(h2f_awaddr),
    .s10_hps_h2f_axi_master_awlen(h2f_awlen),
    .s10_hps_h2f_axi_master_awsize(h2f_awsize),
    .s10_hps_h2f_axi_master_awburst(h2f_awburst),
    .s10_hps_h2f_axi_master_awlock(h2f_awlock),
    .s10_hps_h2f_axi_master_awcache(h2f_awcache),
    .s10_hps_h2f_axi_master_awprot(h2f_awprot),
    .s10_hps_h2f_axi_master_awvalid(h2f_awvalid),
    .s10_hps_h2f_axi_master_awready(h2f_awready),
    .s10_hps_h2f_axi_master_wdata(h2f_wdata),
    .s10_hps_h2f_axi_master_wstrb(h2f_wstrb),
    .s10_hps_h2f_axi_master_wlast(h2f_wlast),
    .s10_hps_h2f_axi_master_wvalid(h2f_wvalid),
    .s10_hps_h2f_axi_master_wready(h2f_wready),
    .s10_hps_h2f_axi_master_bid(h2f_bid),
    .s10_hps_h2f_axi_master_bresp(h2f_bresp),
    .s10_hps_h2f_axi_master_bvalid(h2f_bvalid),
    .s10_hps_h2f_axi_master_bready(h2f_bready),
    .s10_hps_h2f_axi_master_arid(h2f_arid),
    .s10_hps_h2f_axi_master_araddr(h2f_araddr),
    .s10_hps_h2f_axi_master_arlen(h2f_arlen),
    .s10_hps_h2f_axi_master_arsize(h2f_arsize),
    .s10_hps_h2f_axi_master_arburst(h2f_arburst),
    .s10_hps_h2f_axi_master_arlock(h2f_arlock),
    .s10_hps_h2f_axi_master_arcache(h2f_arcache),
    .s10_hps_h2f_axi_master_arprot(h2f_arprot),
    .s10_hps_h2f_axi_master_arvalid(h2f_arvalid),
    .s10_hps_h2f_axi_master_arready(h2f_arready),
    .s10_hps_h2f_axi_master_rid(h2f_rid),
    .s10_hps_h2f_axi_master_rdata(h2f_rdata),
    .s10_hps_h2f_axi_master_rresp(h2f_rresp),
    .s10_hps_h2f_axi_master_rlast(h2f_rlast),
    .s10_hps_h2f_axi_master_rvalid(h2f_rvalid),
    .s10_hps_h2f_axi_master_rready(h2f_rready),

    .s10_hps_f2sdram0_clock_clk(fpga_clk),
    .s10_hps_f2sdram0_reset_reset_n(system_reset_n),
    .s10_hps_f2sdram0_data_awid(f2s_awid),
    .s10_hps_f2sdram0_data_awaddr(hps_f2s_awaddr),
    .s10_hps_f2sdram0_data_awlen(f2s_awlen),
    .s10_hps_f2sdram0_data_awsize(f2s_awsize),
    .s10_hps_f2sdram0_data_awburst(f2s_awburst),
    .s10_hps_f2sdram0_data_awlock(f2s_awlock),
    .s10_hps_f2sdram0_data_awcache(f2s_awcache),
    // The HPS F2SDRAM firewall expects non-secure privileged data traffic.
    .s10_hps_f2sdram0_data_awprot(3'b011),
    .s10_hps_f2sdram0_data_awqos(f2s_awqos),
    .s10_hps_f2sdram0_data_awvalid(f2s_awvalid),
    .s10_hps_f2sdram0_data_awready(f2s_awready),
    .s10_hps_f2sdram0_data_wdata(f2s_wdata),
    .s10_hps_f2sdram0_data_wstrb(f2s_wstrb),
    .s10_hps_f2sdram0_data_wlast(f2s_wlast),
    .s10_hps_f2sdram0_data_wvalid(f2s_wvalid),
    .s10_hps_f2sdram0_data_wready(f2s_wready),
    .s10_hps_f2sdram0_data_bid(f2s_bid),
    .s10_hps_f2sdram0_data_bresp(f2s_bresp),
    .s10_hps_f2sdram0_data_bvalid(f2s_bvalid),
    .s10_hps_f2sdram0_data_bready(f2s_bready),
    .s10_hps_f2sdram0_data_arid(f2s_arid),
    .s10_hps_f2sdram0_data_araddr(hps_f2s_araddr),
    .s10_hps_f2sdram0_data_arlen(f2s_arlen),
    .s10_hps_f2sdram0_data_arsize(f2s_arsize),
    .s10_hps_f2sdram0_data_arburst(f2s_arburst),
    .s10_hps_f2sdram0_data_arlock(f2s_arlock),
    .s10_hps_f2sdram0_data_arcache(f2s_arcache),
    .s10_hps_f2sdram0_data_arprot(3'b011),
    .s10_hps_f2sdram0_data_arqos(f2s_arqos),
    .s10_hps_f2sdram0_data_arvalid(f2s_arvalid),
    .s10_hps_f2sdram0_data_arready(f2s_arready),
    .s10_hps_f2sdram0_data_rid(f2s_rid),
    .s10_hps_f2sdram0_data_rdata(f2s_rdata),
    .s10_hps_f2sdram0_data_rresp(f2s_rresp),
    .s10_hps_f2sdram0_data_rlast(f2s_rlast),
    .s10_hps_f2sdram0_data_rvalid(f2s_rvalid),
    .s10_hps_f2sdram0_data_rready(f2s_rready)
);

hps_h2f_axi_to_esp_ahb_master u_h2f_to_ahb (
    .h2f_axi_clk(fpga_clk),
    .h2f_axi_rst_n(system_reset_n),
    .h2f_AWID(h2f_awid),
    .h2f_AWADDR(h2f_awaddr),
    .h2f_AWLEN(h2f_awlen),
    .h2f_AWSIZE(h2f_awsize),
    .h2f_AWBURST(h2f_awburst),
    .h2f_AWLOCK(h2f_awlock),
    .h2f_AWCACHE(h2f_awcache),
    .h2f_AWPROT(h2f_awprot),
    .h2f_AWVALID(h2f_awvalid),
    .h2f_AWREADY(h2f_awready),
    .h2f_WDATA(h2f_wdata),
    .h2f_WSTRB(h2f_wstrb),
    .h2f_WLAST(h2f_wlast),
    .h2f_WVALID(h2f_wvalid),
    .h2f_WREADY(h2f_wready),
    .h2f_BID(h2f_bid),
    .h2f_BRESP(h2f_bresp),
    .h2f_BVALID(h2f_bvalid),
    .h2f_BREADY(h2f_bready),
    .h2f_ARID(h2f_arid),
    .h2f_ARADDR(h2f_araddr),
    .h2f_ARLEN(h2f_arlen),
    .h2f_ARSIZE(h2f_arsize),
    .h2f_ARBURST(h2f_arburst),
    .h2f_ARLOCK(h2f_arlock),
    .h2f_ARCACHE(h2f_arcache),
    .h2f_ARPROT(h2f_arprot),
    .h2f_ARVALID(h2f_arvalid),
    .h2f_ARREADY(h2f_arready),
    .h2f_RID(h2f_rid),
    .h2f_RDATA(h2f_rdata),
    .h2f_RRESP(h2f_rresp),
    .h2f_RLAST(h2f_rlast),
    .h2f_RVALID(h2f_rvalid),
    .h2f_RREADY(h2f_rready),
    .mo_hlock(mo_hlock),
    .mo_htrans(mo_htrans),
    .mo_haddr(mo_haddr),
    .mo_hwrite(mo_hwrite),
    .mo_hsize(mo_hsize),
    .mo_hburst(mo_hburst),
    .mo_hprot(mo_hprot),
    .mo_hwdata(mo_hwdata),
    .mi_hready(mi_hready),
    .mi_hresp(mi_hresp),
    .mi_hrdata(mi_hrdata),
    .mi_hgrant(mi_hgrant)
);

top u_esp_top (
    .reset(~system_reset_n),
    .chip_refclk(fpga_clk),
    .uart_rxd(GPIO_P[0]),
    .uart_txd(esp_uart_txd),
    .uart_ctsn(GPIO_P[2]),
    .uart_rtsn(esp_uart_rtsn),

    .ddr_awid(f2s_awid),
    .ddr_awaddr(esp_f2s_awaddr),
    .ddr_awlen(f2s_awlen),
    .ddr_awsize(f2s_awsize),
    .ddr_awburst(f2s_awburst),
    .ddr_awlock(f2s_awlock),
    .ddr_awcache(f2s_awcache),
    .ddr_awprot(esp_f2s_awprot),
    .ddr_awqos(f2s_awqos),
    .ddr_awvalid(f2s_awvalid),
    .ddr_awready(f2s_awready),
    .ddr_wdata(f2s_wdata),
    .ddr_wstrb(f2s_wstrb),
    .ddr_wlast(f2s_wlast),
    .ddr_wvalid(f2s_wvalid),
    .ddr_wready(f2s_wready),
    .ddr_bid(f2s_bid),
    .ddr_bresp(f2s_bresp),
    .ddr_bvalid(f2s_bvalid),
    .ddr_bready(f2s_bready),
    .ddr_arid(f2s_arid),
    .ddr_araddr(esp_f2s_araddr),
    .ddr_arlen(f2s_arlen),
    .ddr_arsize(f2s_arsize),
    .ddr_arburst(f2s_arburst),
    .ddr_arlock(f2s_arlock),
    .ddr_arcache(f2s_arcache),
    .ddr_arprot(esp_f2s_arprot),
    .ddr_arqos(f2s_arqos),
    .ddr_arvalid(f2s_arvalid),
    .ddr_arready(f2s_arready),
    .ddr_rid(f2s_rid),
    .ddr_rdata(f2s_rdata),
    .ddr_rresp(f2s_rresp),
    .ddr_rlast(f2s_rlast),
    .ddr_rvalid(f2s_rvalid),
    .ddr_rready(f2s_rready),

    .mi_hready(mi_hready),
    .mi_hresp(mi_hresp),
    .mi_hrdata(mi_hrdata),
    .mi_hgrant(mi_hgrant),
    .mo_hlock(mo_hlock),
    .mo_htrans(mo_htrans),
    .mo_haddr(mo_haddr),
    .mo_hwrite(mo_hwrite),
    .mo_hsize(mo_hsize),
    .mo_hburst(mo_hburst),
    .mo_hprot(mo_hprot),
    .mo_hwdata(mo_hwdata)
);

endmodule

`default_nettype wire
