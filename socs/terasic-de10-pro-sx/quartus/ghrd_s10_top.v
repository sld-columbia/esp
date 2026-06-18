// ============================================================================
// Copyright (c) 2018 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// ============================================================================
//
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Wed Jan 31 14:15:58 2018
// ============================================================================

`define ENABLE_DDR4A
//`define ENABLE_DDR4B
//`define ENABLE_DDR4C
//`define ENABLE_DDR4D
//`define ENABLE_PCIE
//`define ENABLE_QSFP28A
//`define ENABLE_QSFP28B
//`define ENABLE_QSFP28C
//`define ENABLE_QSFP28D
`define ENABLE_HPS

module ghrd_s10_top(

      ///////// CLOCK /////////
      input              CLK_100_B3I,
      input              CLK_50_B2C,
      input              CLK_50_B2L,
      input              CLK_50_B3C,
      input              CLK_50_B3I,
      input              CLK_50_B3L,

      ///////// Buttons /////////
      input              CPU_RESET_n,
      input    [ 1: 0]   BUTTON,

      ///////// FPGA /////////
      inout              FPGA_PR_DONE,
      inout              FPGA_PR_ERROR,
      inout              FPGA_PR_REQUEST,

      ///////// Swtiches /////////
      input    [ 1: 0]   SW,

      ///////// LED /////////
      output   [ 3: 0]   LED, //LED is Low-Active

      ///////// FLASH /////////
      output             FLASH_CLK,
      output   [27: 1]   FLASH_A,
      inout    [15: 0]   FLASH_D,
      output             FLASH_CE_n,
      output             FLASH_WE_n,
      output             FLASH_OE_n,
      output             FLASH_ADV_n,
      output             FLASH_RESET_n,
      input              FLASH_RDY_BSY_n,

`ifdef ENABLE_DDR4A
      ///////// DDR4A /////////
      input              DDR4A_REFCLK_p,
      output   [16: 0]   DDR4A_A,
      output   [ 1: 0]   DDR4A_BA,
      output   [ 1: 0]   DDR4A_BG,
      output             DDR4A_CK,
      output             DDR4A_CK_n,
      output             DDR4A_CKE,
      inout    [ 8: 0]   DDR4A_DQS,
      inout    [ 8: 0]   DDR4A_DQS_n,
      inout    [71: 0]   DDR4A_DQ,
      inout    [ 8: 0]   DDR4A_DBI_n,
      output             DDR4A_CS_n,
      output             DDR4A_RESET_n,
      output             DDR4A_ODT,
      output             DDR4A_PAR,
      input              DDR4A_ALERT_n,
      output             DDR4A_ACT_n,
      input              DDR4A_EVENT_n,
      inout              DDR4A_SCL,
      inout              DDR4A_SDA,
      input              DDR4A_RZQ,
`endif /*ENABLE_DDR4A*/

`ifdef ENABLE_DDR4B
      ///////// DDR4B /////////
      input              DDR4B_REFCLK_p,
      output   [16: 0]   DDR4B_A,
      output   [ 1: 0]   DDR4B_BA,
      output   [ 1: 0]   DDR4B_BG,
      output             DDR4B_CK,
      output             DDR4B_CK_n,
      output             DDR4B_CKE,
      inout    [ 8: 0]   DDR4B_DQS,
      inout    [ 8: 0]   DDR4B_DQS_n,
      inout    [71: 0]   DDR4B_DQ,
      inout    [ 8: 0]   DDR4B_DBI_n,
      output             DDR4B_CS_n,
      output             DDR4B_RESET_n,
      output             DDR4B_ODT,
      output             DDR4B_PAR,
      input              DDR4B_ALERT_n,
      output             DDR4B_ACT_n,
      input              DDR4B_EVENT_n,
      inout              DDR4B_SCL,
      inout              DDR4B_SDA,
      input              DDR4B_RZQ,
`endif /*ENABLE_DDR4B*/

`ifdef ENABLE_DDR4C
      ///////// DDR4C /////////
      input              DDR4C_REFCLK_p,
      output   [16: 0]   DDR4C_A,
      output   [ 1: 0]   DDR4C_BA,
      output   [ 1: 0]   DDR4C_BG,
      output             DDR4C_CK,
      output             DDR4C_CK_n,
      output             DDR4C_CKE,
      inout    [ 8: 0]   DDR4C_DQS,
      inout    [ 8: 0]   DDR4C_DQS_n,
      inout    [71: 0]   DDR4C_DQ,
      inout    [ 8: 0]   DDR4C_DBI_n,
      output             DDR4C_CS_n,
      output             DDR4C_RESET_n,
      output             DDR4C_ODT,
      output             DDR4C_PAR,
      input              DDR4C_ALERT_n,
      output             DDR4C_ACT_n,
      input              DDR4C_EVENT_n,
      inout              DDR4C_SCL,
      inout              DDR4C_SDA,
      input              DDR4C_RZQ,
`endif /*ENABLE_DDR4C*/

`ifdef ENABLE_DDR4D
      ///////// DDR4D /////////
      input              DDR4D_REFCLK_p,
      output   [16: 0]   DDR4D_A,
      output   [ 1: 0]   DDR4D_BA,
      output   [ 1: 0]   DDR4D_BG,
      output             DDR4D_CK,
      output             DDR4D_CK_n,
      output             DDR4D_CKE,
      inout    [ 8: 0]   DDR4D_DQS,
      inout    [ 8: 0]   DDR4D_DQS_n,
      inout    [71: 0]   DDR4D_DQ,
      inout    [ 8: 0]   DDR4D_DBI_n,
      output             DDR4D_CS_n,
      output             DDR4D_RESET_n,
      output             DDR4D_ODT,
      output             DDR4D_PAR,
      input              DDR4D_ALERT_n,
      output             DDR4D_ACT_n,
      input              DDR4D_EVENT_n,
      inout              DDR4D_SCL,
      inout              DDR4D_SDA,
      input              DDR4D_RZQ,
`endif /*ENABLE_DDR4D*/

      ///////// SI5340A0 /////////
      inout              SI5340A0_I2C_SCL,
      inout              SI5340A0_I2C_SDA,
      input              SI5340A0_INTR,
      output             SI5340A0_OE_n,
      output             SI5340A0_RST_n,

      ///////// SI5340A1 /////////
      inout              SI5340A1_I2C_SCL,
      inout              SI5340A1_I2C_SDA,
      input              SI5340A1_INTR,
      output             SI5340A1_OE_n,
      output             SI5340A1_RST_n,

      ///////// I2Cs /////////
      inout              FAN_I2C_SCL,
      inout              FAN_I2C_SDA,
      input              FAN_ALERT_n,
      inout              POWER_MONITOR_I2C_SCL,
      inout              POWER_MONITOR_I2C_SDA,
      input              POWER_MONITOR_ALERT_n,
      inout              TEMP_I2C_SCL,
      inout              TEMP_I2C_SDA,

      ///////// GPIO /////////
      inout    [ 1: 0]   GPIO_CLK,
      inout    [ 3: 0]   GPIO_P,

`ifdef ENABLE_PCIE
      ///////// PCIE /////////
      inout              PCIE_SMBCLK,
      inout              PCIE_SMBDAT,
      input              PCIE_REFCLK_p,
      output   [15: 0]   PCIE_TX_p,
      input    [15: 0]   PCIE_RX_p,
      input              PCIE_PERST_n,
      output             PCIE_WAKE_n,
`endif /*ENABLE_PCIE*/

`ifdef ENABLE_QSFP28A
      ///////// QSFP28A /////////
      input              QSFP28A_REFCLK_p,
      output   [ 3: 0]   QSFP28A_TX_p,
      input    [ 3: 0]   QSFP28A_RX_p,
      input              QSFP28A_INTERRUPT_n,
      output             QSFP28A_LP_MODE,
      input              QSFP28A_MOD_PRS_n,
      output             QSFP28A_MOD_SEL_n,
      output             QSFP28A_RST_n,
      inout              QSFP28A_SCL,
      inout              QSFP28A_SDA,
`endif /*ENABLE_QSFP28A*/

`ifdef ENABLE_QSFP28B
      ///////// QSFP28B /////////
      input              QSFP28B_REFCLK_p,
      output   [ 3: 0]   QSFP28B_TX_p,
      input    [ 3: 0]   QSFP28B_RX_p,
      input              QSFP28B_INTERRUPT_n,
      output             QSFP28B_LP_MODE,
      input              QSFP28B_MOD_PRS_n,
      output             QSFP28B_MOD_SEL_n,
      output             QSFP28B_RST_n,
      inout              QSFP28B_SCL,
      inout              QSFP28B_SDA,
`endif /*ENABLE_QSFP28B*/

`ifdef ENABLE_QSFP28C
      ///////// QSFP28C /////////
      input              QSFP28C_REFCLK_p,
      output   [ 3: 0]   QSFP28C_TX_p,
      input    [ 3: 0]   QSFP28C_RX_p,
      input              QSFP28C_INTERRUPT_n,
      output             QSFP28C_LP_MODE,
      input              QSFP28C_MOD_PRS_n,
      output             QSFP28C_MOD_SEL_n,
      output             QSFP28C_RST_n,
      inout              QSFP28C_SCL,
      inout              QSFP28C_SDA,
`endif /*ENABLE_QSFP28C*/

`ifdef ENABLE_QSFP28D
      ///////// QSFP28D /////////
      input              QSFP28D_REFCLK_p,
      output   [ 3: 0]   QSFP28D_TX_p,
      input    [ 3: 0]   QSFP28D_RX_p,
      input              QSFP28D_INTERRUPT_n,
      output             QSFP28D_LP_MODE,
      input              QSFP28D_MOD_PRS_n,
      output             QSFP28D_MOD_SEL_n,
      output             QSFP28D_RST_n,
      inout              QSFP28D_SCL,
      inout              QSFP28D_SDA,
`endif /*ENABLE_QSFP28D*/


`ifdef ENABLE_HPS
      ///////// HPS /////////

      // USB
      input              HPS_USB0_CLK,
      output             HPS_USB0_STP,
      input              HPS_USB0_DIR,
      inout    [ 7: 0]   HPS_USB0_DATA,
      input              HPS_USB0_NXT,

      // Ethernet
      output             HPS_EMAC0_TX_CLK,
      output             HPS_EMAC0_TX_CTL,
      input              HPS_EMAC0_RX_CLK,
      input              HPS_EMAC0_RX_CTL,
      output   [ 3: 0]   HPS_EMAC0_TXD,
      input    [ 3: 0]   HPS_EMAC0_RXD,
      inout              HPS_EMAC0_MDIO,
      output             HPS_EMAC0_MDC,

      // uart
      output             HPS_UART0_TX,
      input              HPS_UART0_RX,
      output             HPS_FPGA_UART1_TX,
      input              HPS_FPGA_UART1_RX,

      // sdcard
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout    [ 3: 0]   HPS_SD_DATA,
      input              HPS_OSC_CLK,

      // user io
      inout              HPS_LED,
      inout              HPS_KEY,

      // card detection
      inout              HPS_CARD_PRSNT_n,

`endif /*ENABLE_HPS*/

       ///////// EXP /////////
      input              EXP_EN,

      ///////// UFL /////////
      inout              UFL_CLKIN_p,
      inout              UFL_CLKIN_n

);

wire src_reset_n;
wire system_reset_n;
wire h2f_reset;
assign system_reset_n = CPU_RESET_n & src_reset_n & ~h2f_reset;

de10_pro_fan_controller #(
  .TARGET_RPM (13'd2200)
) u_fan_controller (
  .clk         (CLK_50_B3C),
  .reset_n     (system_reset_n),
  .fan_alert_n (FAN_ALERT_n),
  .fan_i2c_scl (FAN_I2C_SCL),
  .fan_i2c_sda (FAN_I2C_SDA)
);


wire [ 1: 0] fpga_debounced_buttons;
wire [ 2: 0] fpga_led_internal;
wire heartbeat_led;
reg  [22: 0] heartbeat_count;
assign heartbeat_led = ~heartbeat_count[22];

wire [31: 0] f2h_irq1_irq;


wire [42:0] stm_hw_events;

assign stm_hw_events = {{35{1'b0}}, heartbeat_led, fpga_led_internal, SW, fpga_debounced_buttons};

assign f2h_irq1_irq = 32'b0;

wire fpga_clk_100;

assign fpga_clk_100 = CLK_50_B3C;

//Ethernet AXI4 Master
wire [3:0]  s10_hps_h2f_axi_master_awid;            //    s10_hps_h2f_axi_master.awid
wire [31:0] s10_hps_h2f_axi_master_awaddr;          //                          .awaddr
wire [7:0]  s10_hps_h2f_axi_master_awlen;           //                          .awlen
wire [2:0]  s10_hps_h2f_axi_master_awsize;          //                          .awsize
wire [1:0]  s10_hps_h2f_axi_master_awburst;         //                          .awburst
wire        s10_hps_h2f_axi_master_awlock;          //                          .awlock
wire [3:0]  s10_hps_h2f_axi_master_awcache;         //                          .awcache
wire [2:0]  s10_hps_h2f_axi_master_awprot;          //                          .awprot
wire        s10_hps_h2f_axi_master_awvalid;         //                          .awvalid
wire        s10_hps_h2f_axi_master_awready;         //                          .awready
wire [31:0] s10_hps_h2f_axi_master_wdata;           //                          .wdata
wire [3:0]  s10_hps_h2f_axi_master_wstrb;           //                          .wstrb
wire        s10_hps_h2f_axi_master_wlast;           //                          .wlast
wire        s10_hps_h2f_axi_master_wvalid;          //                          .wvalid
wire        s10_hps_h2f_axi_master_wready;          //                          .wready
wire [3:0]  s10_hps_h2f_axi_master_bid;             //                          .bid
wire [1:0]  s10_hps_h2f_axi_master_bresp;           //                          .bresp
wire        s10_hps_h2f_axi_master_bvalid;          //                          .bvalid
wire        s10_hps_h2f_axi_master_bready;          //                          .bready
wire [3:0]  s10_hps_h2f_axi_master_arid;            //                          .arid
wire [31:0] s10_hps_h2f_axi_master_araddr;          //                          .araddr
wire [7:0]  s10_hps_h2f_axi_master_arlen;           //                          .arlen
wire [2:0]  s10_hps_h2f_axi_master_arsize;          //                          .arsize
wire [1:0]  s10_hps_h2f_axi_master_arburst;         //                          .arburst
wire        s10_hps_h2f_axi_master_arlock;          //                          .arlock
wire [3:0]  s10_hps_h2f_axi_master_arcache;         //                          .arcache
wire [2:0]  s10_hps_h2f_axi_master_arprot;          //                          .arprot
wire        s10_hps_h2f_axi_master_arvalid;         //                          .arvalid
wire        s10_hps_h2f_axi_master_arready;         //                          .arready
wire [3:0]  s10_hps_h2f_axi_master_rid;             //                          .rid
wire [31:0] s10_hps_h2f_axi_master_rdata;           //                          .rdata
wire [1:0]  s10_hps_h2f_axi_master_rresp;           //                          .rresp
wire        s10_hps_h2f_axi_master_rlast;           //                          .rlast
wire        s10_hps_h2f_axi_master_rvalid;          //                          .rvalid
wire        s10_hps_h2f_axi_master_rready;          //                          .rready

//Memory AXI4 Slave
wire [3:0]  s10_hps_f2sdram0_data_awid;             //     s10_hps_f2sdram0_data.awid
wire [32:0] s10_hps_f2sdram0_data_awaddr;           //                          .awaddr
wire [7:0]  s10_hps_f2sdram0_data_awlen;            //                          .awlen
wire [2:0]  s10_hps_f2sdram0_data_awsize;           //                          .awsize
wire [1:0]  s10_hps_f2sdram0_data_awburst;          //                          .awburst
wire        s10_hps_f2sdram0_data_awlock;           //                          .awlock
wire [3:0]  s10_hps_f2sdram0_data_awcache;          //                          .awcache
wire [2:0]  s10_hps_f2sdram0_data_awprot;           //                          .awprot
wire [3:0]  s10_hps_f2sdram0_data_awqos;            //                          .awqos
wire        s10_hps_f2sdram0_data_awvalid;          //                          .awvalid
wire        s10_hps_f2sdram0_data_awready;          //                          .awready
wire [63:0] s10_hps_f2sdram0_data_wdata;            //                          .wdata
wire [7:0]  s10_hps_f2sdram0_data_wstrb;            //                          .wstrb
wire        s10_hps_f2sdram0_data_wlast;            //                          .wlast
wire        s10_hps_f2sdram0_data_wvalid;           //                          .wvalid
wire        s10_hps_f2sdram0_data_wready;           //                          .wready
wire [3:0]  s10_hps_f2sdram0_data_bid;              //                          .bid
wire [1:0]  s10_hps_f2sdram0_data_bresp;            //                          .bresp
wire        s10_hps_f2sdram0_data_bvalid;           //                          .bvalid
wire        s10_hps_f2sdram0_data_bready;           //                          .bready
wire [3:0]  s10_hps_f2sdram0_data_arid;             //                          .arid
wire [32:0] s10_hps_f2sdram0_data_araddr;           //                          .araddr
wire [7:0]  s10_hps_f2sdram0_data_arlen;            //                          .arlen
wire [2:0]  s10_hps_f2sdram0_data_arsize;           //                          .arsize
wire [1:0]  s10_hps_f2sdram0_data_arburst;          //                          .arburst
wire        s10_hps_f2sdram0_data_arlock;           //                          .arlock
wire [3:0]  s10_hps_f2sdram0_data_arcache;          //                          .arcache
wire [2:0]  s10_hps_f2sdram0_data_arprot;           //                          .arprot
wire [3:0]  s10_hps_f2sdram0_data_arqos;            //                          .arqos
wire        s10_hps_f2sdram0_data_arvalid;          //                          .arvalid
wire        s10_hps_f2sdram0_data_arready;          //                          .arready
wire [3:0]  s10_hps_f2sdram0_data_rid;              //                          .rid
wire [63:0] s10_hps_f2sdram0_data_rdata;            //                          .rdata
wire [1:0]  s10_hps_f2sdram0_data_rresp;            //                          .rresp
wire        s10_hps_f2sdram0_data_rlast;            //                          .rlast
wire        s10_hps_f2sdram0_data_rvalid;           //                          .rvalid
wire        s10_hps_f2sdram0_data_rready;           //                          .rready
wire [31:0] esp_f2sdram0_data_awaddr;               // ESP local DDR address
wire [31:0] esp_f2sdram0_data_araddr;               // ESP local DDR address
wire [2:0]  esp_f2sdram0_data_awprot;               // ESP top output before wrapper override
wire [2:0]  esp_f2sdram0_data_arprot;               // ESP top output before wrapper override

// Present ESP's 0x80000000-based DDR aperture to the HPS F2SDRAM port through
// the live HPS/ECC alias at 0x180000000. This preserves the ESP software ABI
// while matching the Linux reserved-memory alias used by the owned boot chain.
assign s10_hps_f2sdram0_data_awaddr = {1'b1, esp_f2sdram0_data_awaddr};
assign s10_hps_f2sdram0_data_araddr = {1'b1, esp_f2sdram0_data_araddr};

// The Stratix 10 HPS F2SDRAM port is TrustZone-aware. Force the HPS-facing AxPROT
// sidebands at the board wrapper so the actual port seen by SignalTap and the HPS
// always uses non-secure privileged accesses.
assign s10_hps_f2sdram0_data_awprot = 3'b011;
assign s10_hps_f2sdram0_data_arprot = 3'b011;


// AHB-Lite bridge signals between the HPS h2f AXI port and the ESP wrapper.
// "mo_*" are request signals driven by the h2f AXI-to-AHB bridge into ESP top,
// and "mi_*" are the return response signals from ESP top back to that bridge.
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

// LEDs and UART handshake from ESP top
wire [6:0]  esp_led;
wire        esp_uart_rtsn_nc;

// Qsys Top module
qsys_top soc_inst (
.src_prb_rst_sources_source             (src_reset_n),
.reset_reset_n                          (system_reset_n),
.clk_100_clk                            (fpga_clk_100),
.s10_hps_f2h_stm_hw_events_stm_hwevents (stm_hw_events),
.emif_hps_pll_ref_clk_clk               (DDR4A_REFCLK_p),
.emif_hps_mem_mem_ck                    (DDR4A_CK),
.emif_hps_mem_mem_ck_n                  (DDR4A_CK_n),
.emif_hps_mem_mem_a                     (DDR4A_A),
.emif_hps_mem_mem_act_n                 (DDR4A_ACT_n),
.emif_hps_mem_mem_ba                    (DDR4A_BA),
.emif_hps_mem_mem_bg                    (DDR4A_BG),
.emif_hps_mem_mem_cke                   (DDR4A_CKE),
.emif_hps_mem_mem_cs_n                  (DDR4A_CS_n),
.emif_hps_mem_mem_odt                   (DDR4A_ODT),
.emif_hps_mem_mem_reset_n               (DDR4A_RESET_n),
.emif_hps_mem_mem_par                   (DDR4A_PAR),
.emif_hps_mem_mem_alert_n               (DDR4A_ALERT_n),
.emif_hps_mem_mem_dqs                   (DDR4A_DQS),
.emif_hps_mem_mem_dqs_n                 (DDR4A_DQS_n),
.emif_hps_mem_mem_dq                    (DDR4A_DQ),
.emif_hps_mem_mem_dbi_n                 (DDR4A_DBI_n),
.emif_hps_oct_oct_rzqin                 (DDR4A_RZQ),

.hps_io_hps_io_phery_usb0_CLK           (HPS_USB0_CLK),
.hps_io_hps_io_phery_usb0_STP           (HPS_USB0_STP),
.hps_io_hps_io_phery_usb0_DIR           (HPS_USB0_DIR),
.hps_io_hps_io_phery_usb0_NXT           (HPS_USB0_NXT),
.hps_io_hps_io_phery_usb0_DATA0         (HPS_USB0_DATA[0]),
.hps_io_hps_io_phery_usb0_DATA1         (HPS_USB0_DATA[1]),
.hps_io_hps_io_phery_usb0_DATA2         (HPS_USB0_DATA[2]),
.hps_io_hps_io_phery_usb0_DATA3         (HPS_USB0_DATA[3]),
.hps_io_hps_io_phery_usb0_DATA4         (HPS_USB0_DATA[4]),
.hps_io_hps_io_phery_usb0_DATA5         (HPS_USB0_DATA[5]),
.hps_io_hps_io_phery_usb0_DATA6         (HPS_USB0_DATA[6]),
.hps_io_hps_io_phery_usb0_DATA7         (HPS_USB0_DATA[7]),
.hps_io_hps_io_phery_emac0_TX_CLK       (HPS_EMAC0_TX_CLK),
.hps_io_hps_io_phery_emac0_RX_CLK       (HPS_EMAC0_RX_CLK),
.hps_io_hps_io_phery_emac0_TX_CTL       (HPS_EMAC0_TX_CTL),
.hps_io_hps_io_phery_emac0_RX_CTL       (HPS_EMAC0_RX_CTL),
.hps_io_hps_io_phery_emac0_TXD0         (HPS_EMAC0_TXD[0]),
.hps_io_hps_io_phery_emac0_TXD1         (HPS_EMAC0_TXD[1]),
.hps_io_hps_io_phery_emac0_RXD0         (HPS_EMAC0_RXD[0]),
.hps_io_hps_io_phery_emac0_RXD1         (HPS_EMAC0_RXD[1]),
.hps_io_hps_io_phery_emac0_TXD2         (HPS_EMAC0_TXD[2]),
.hps_io_hps_io_phery_emac0_TXD3         (HPS_EMAC0_TXD[3]),
.hps_io_hps_io_phery_emac0_RXD2         (HPS_EMAC0_RXD[2]),
.hps_io_hps_io_phery_emac0_RXD3         (HPS_EMAC0_RXD[3]),
.hps_io_hps_io_gpio_gpio1_io0           (HPS_LED),
.hps_io_hps_io_gpio_gpio1_io1           (HPS_KEY),
.hps_io_hps_io_phery_uart0_TX           (HPS_UART0_TX),
.hps_io_hps_io_phery_uart0_RX           (HPS_UART0_RX),
.hps_io_hps_io_phery_uart1_TX           (HPS_FPGA_UART1_TX),
.hps_io_hps_io_phery_uart1_RX           (HPS_FPGA_UART1_RX),
.hps_io_hps_io_phery_sdmmc_CCLK         (HPS_SD_CLK),
.hps_io_hps_io_phery_sdmmc_CMD          (HPS_SD_CMD),
.hps_io_hps_io_phery_sdmmc_D0           (HPS_SD_DATA[0]),
.hps_io_hps_io_phery_sdmmc_D1           (HPS_SD_DATA[1]),
.hps_io_hps_io_phery_sdmmc_D2           (HPS_SD_DATA[2]),
.hps_io_hps_io_phery_sdmmc_D3           (HPS_SD_DATA[3]),
.hps_io_hps_io_hps_ocs_clk              (HPS_OSC_CLK),
.hps_io_hps_io_gpio_gpio1_io20          (HPS_CARD_PRSNT_n),
.hps_io_hps_io_phery_emac0_MDIO         (HPS_EMAC0_MDIO),
.hps_io_hps_io_phery_emac0_MDC          (HPS_EMAC0_MDC),

.f2h_irq1_irq                           (f2h_irq1_irq),
.h2f_reset_reset                        (h2f_reset),

.s10_hps_h2f_axi_clock_clk              (fpga_clk_100),             
.s10_hps_h2f_axi_reset_reset_n          (system_reset_n),         
.s10_hps_h2f_axi_master_awid            (s10_hps_h2f_axi_master_awid),            //  output,   width = 4,    s10_hps_h2f_axi_master.awid
.s10_hps_h2f_axi_master_awaddr          (s10_hps_h2f_axi_master_awaddr),          //  output,  width = 32,                          .awaddr
.s10_hps_h2f_axi_master_awlen           (s10_hps_h2f_axi_master_awlen),           //  output,   width = 8,                          .awlen
.s10_hps_h2f_axi_master_awsize          (s10_hps_h2f_axi_master_awsize),          //  output,   width = 3,                          .awsize
.s10_hps_h2f_axi_master_awburst         (s10_hps_h2f_axi_master_awburst),         //  output,   width = 2,                          .awburst
.s10_hps_h2f_axi_master_awlock          (s10_hps_h2f_axi_master_awlock),          //  output,   width = 1,                          .awlock
.s10_hps_h2f_axi_master_awcache         (s10_hps_h2f_axi_master_awcache),         //  output,   width = 4,                          .awcache
.s10_hps_h2f_axi_master_awprot          (s10_hps_h2f_axi_master_awprot),          //  output,   width = 3,                          .awprot
.s10_hps_h2f_axi_master_awvalid         (s10_hps_h2f_axi_master_awvalid),         //  output,   width = 1,                          .awvalid
.s10_hps_h2f_axi_master_awready         (s10_hps_h2f_axi_master_awready),         //   input,   width = 1,                          .awready
.s10_hps_h2f_axi_master_wdata           (s10_hps_h2f_axi_master_wdata),           //  output,  width = 32,                          .wdata
.s10_hps_h2f_axi_master_wstrb           (s10_hps_h2f_axi_master_wstrb),           //  output,   width = 4,                          .wstrb
.s10_hps_h2f_axi_master_wlast           (s10_hps_h2f_axi_master_wlast),           //  output,   width = 1,                          .wlast
.s10_hps_h2f_axi_master_wvalid          (s10_hps_h2f_axi_master_wvalid),          //  output,   width = 1,                          .wvalid
.s10_hps_h2f_axi_master_wready          (s10_hps_h2f_axi_master_wready),          //   input,   width = 1,                          .wready
.s10_hps_h2f_axi_master_bid             (s10_hps_h2f_axi_master_bid),             //   input,   width = 4,                          .bid
.s10_hps_h2f_axi_master_bresp           (s10_hps_h2f_axi_master_bresp),           //   input,   width = 2,                          .bresp
.s10_hps_h2f_axi_master_bvalid          (s10_hps_h2f_axi_master_bvalid),          //   input,   width = 1,                          .bvalid
.s10_hps_h2f_axi_master_bready          (s10_hps_h2f_axi_master_bready),          //  output,   width = 1,                          .bready
.s10_hps_h2f_axi_master_arid            (s10_hps_h2f_axi_master_arid),            //  output,   width = 4,                          .arid
.s10_hps_h2f_axi_master_araddr          (s10_hps_h2f_axi_master_araddr),          //  output,  width = 32,                          .araddr
.s10_hps_h2f_axi_master_arlen           (s10_hps_h2f_axi_master_arlen),           //  output,   width = 8,                          .arlen
.s10_hps_h2f_axi_master_arsize          (s10_hps_h2f_axi_master_arsize),          //  output,   width = 3,                          .arsize
.s10_hps_h2f_axi_master_arburst         (s10_hps_h2f_axi_master_arburst),         //  output,   width = 2,                          .arburst
.s10_hps_h2f_axi_master_arlock          (s10_hps_h2f_axi_master_arlock),          //  output,   width = 1,                          .arlock
.s10_hps_h2f_axi_master_arcache         (s10_hps_h2f_axi_master_arcache),         //  output,   width = 4,                          .arcache
.s10_hps_h2f_axi_master_arprot          (s10_hps_h2f_axi_master_arprot),          //  output,   width = 3,                          .arprot
.s10_hps_h2f_axi_master_arvalid         (s10_hps_h2f_axi_master_arvalid),         //  output,   width = 1,                          .arvalid
.s10_hps_h2f_axi_master_arready         (s10_hps_h2f_axi_master_arready),         //   input,   width = 1,                          .arready
.s10_hps_h2f_axi_master_rid             (s10_hps_h2f_axi_master_rid),             //   input,   width = 4,                          .rid
.s10_hps_h2f_axi_master_rdata           (s10_hps_h2f_axi_master_rdata),           //   input,  width = 32,                          .rdata
.s10_hps_h2f_axi_master_rresp           (s10_hps_h2f_axi_master_rresp),           //   input,   width = 2,                          .rresp
.s10_hps_h2f_axi_master_rlast           (s10_hps_h2f_axi_master_rlast),           //   input,   width = 1,                          .rlast
.s10_hps_h2f_axi_master_rvalid          (s10_hps_h2f_axi_master_rvalid),          //   input,   width = 1,                          .rvalid
.s10_hps_h2f_axi_master_rready          (s10_hps_h2f_axi_master_rready),          //  output,   width = 1,                          .rready

.s10_hps_f2sdram0_clock_clk             (fpga_clk_100),            
.s10_hps_f2sdram0_reset_reset_n         (system_reset_n),        
.s10_hps_f2sdram0_data_awid             (s10_hps_f2sdram0_data_awid),             //   input,   width = 4,     s10_hps_f2sdram0_data.awid
.s10_hps_f2sdram0_data_awaddr           (s10_hps_f2sdram0_data_awaddr),           //   input,  width = 33,                          .awaddr
.s10_hps_f2sdram0_data_awlen            (s10_hps_f2sdram0_data_awlen),            //   input,   width = 8,                          .awlen
.s10_hps_f2sdram0_data_awsize           (s10_hps_f2sdram0_data_awsize),           //   input,   width = 3,                          .awsize
.s10_hps_f2sdram0_data_awburst          (s10_hps_f2sdram0_data_awburst),          //   input,   width = 2,                          .awburst
.s10_hps_f2sdram0_data_awlock           (s10_hps_f2sdram0_data_awlock),           //   input,   width = 1,                          .awlock
.s10_hps_f2sdram0_data_awcache          (s10_hps_f2sdram0_data_awcache),          //   input,   width = 4,                          .awcache
.s10_hps_f2sdram0_data_awprot           (s10_hps_f2sdram0_data_awprot),           //   input,   width = 3,                          .awprot
.s10_hps_f2sdram0_data_awqos            (s10_hps_f2sdram0_data_awqos),            //   input,   width = 4,                          .awqos
.s10_hps_f2sdram0_data_awvalid          (s10_hps_f2sdram0_data_awvalid),          //   input,   width = 1,                          .awvalid
.s10_hps_f2sdram0_data_awready          (s10_hps_f2sdram0_data_awready),          //  output,   width = 1,                          .awready
.s10_hps_f2sdram0_data_wdata            (s10_hps_f2sdram0_data_wdata),            //   input,  width = 64,                          .wdata
.s10_hps_f2sdram0_data_wstrb            (s10_hps_f2sdram0_data_wstrb),            //   input,   width = 8,                          .wstrb
.s10_hps_f2sdram0_data_wlast            (s10_hps_f2sdram0_data_wlast),            //   input,   width = 1,                          .wlast
.s10_hps_f2sdram0_data_wvalid           (s10_hps_f2sdram0_data_wvalid),           //   input,   width = 1,                          .wvalid
.s10_hps_f2sdram0_data_wready           (s10_hps_f2sdram0_data_wready),           //  output,   width = 1,                          .wready
.s10_hps_f2sdram0_data_bid              (s10_hps_f2sdram0_data_bid),              //  output,   width = 4,                          .bid
.s10_hps_f2sdram0_data_bresp            (s10_hps_f2sdram0_data_bresp),            //  output,   width = 2,                          .bresp
.s10_hps_f2sdram0_data_bvalid           (s10_hps_f2sdram0_data_bvalid),           //  output,   width = 1,                          .bvalid
.s10_hps_f2sdram0_data_bready           (s10_hps_f2sdram0_data_bready),           //   input,   width = 1,                          .bready
.s10_hps_f2sdram0_data_arid             (s10_hps_f2sdram0_data_arid),             //   input,   width = 4,                          .arid
.s10_hps_f2sdram0_data_araddr           (s10_hps_f2sdram0_data_araddr),           //   input,  width = 33,                          .araddr
.s10_hps_f2sdram0_data_arlen            (s10_hps_f2sdram0_data_arlen),            //   input,   width = 8,                          .arlen
.s10_hps_f2sdram0_data_arsize           (s10_hps_f2sdram0_data_arsize),           //   input,   width = 3,                          .arsize
.s10_hps_f2sdram0_data_arburst          (s10_hps_f2sdram0_data_arburst),          //   input,   width = 2,                          .arburst
.s10_hps_f2sdram0_data_arlock           (s10_hps_f2sdram0_data_arlock),           //   input,   width = 1,                          .arlock
.s10_hps_f2sdram0_data_arcache          (s10_hps_f2sdram0_data_arcache),          //   input,   width = 4,                          .arcache
.s10_hps_f2sdram0_data_arprot           (s10_hps_f2sdram0_data_arprot),           //   input,   width = 3,                          .arprot
.s10_hps_f2sdram0_data_arqos            (s10_hps_f2sdram0_data_arqos),            //   input,   width = 4,                          .arqos
.s10_hps_f2sdram0_data_arvalid          (s10_hps_f2sdram0_data_arvalid),          //   input,   width = 1,                          .arvalid
.s10_hps_f2sdram0_data_arready          (s10_hps_f2sdram0_data_arready),          //  output,   width = 1,                          .arready
.s10_hps_f2sdram0_data_rid              (s10_hps_f2sdram0_data_rid),              //  output,   width = 4,                          .rid
.s10_hps_f2sdram0_data_rdata            (s10_hps_f2sdram0_data_rdata),            //  output,  width = 64,                          .rdata
.s10_hps_f2sdram0_data_rresp            (s10_hps_f2sdram0_data_rresp),            //  output,   width = 2,                          .rresp
.s10_hps_f2sdram0_data_rlast            (s10_hps_f2sdram0_data_rlast),            //  output,   width = 1,                          .rlast
.s10_hps_f2sdram0_data_rvalid           (s10_hps_f2sdram0_data_rvalid),           //  output,   width = 1,                          .rvalid
.s10_hps_f2sdram0_data_rready           (s10_hps_f2sdram0_data_rready)            //   input,   width = 1,                          .rready
);


hps_h2f_axi_to_esp_ahb_master u_h2f_to_ahb (
  // AXI clock/reset
  .h2f_axi_clk   (fpga_clk_100),
  .h2f_axi_rst_n (system_reset_n),

  // ===== h2f AXI master =====
  .h2f_AWID      (s10_hps_h2f_axi_master_awid),
  .h2f_AWADDR    (s10_hps_h2f_axi_master_awaddr),
  .h2f_AWLEN     (s10_hps_h2f_axi_master_awlen),
  .h2f_AWSIZE    (s10_hps_h2f_axi_master_awsize),
  .h2f_AWBURST   (s10_hps_h2f_axi_master_awburst),
  .h2f_AWLOCK    (s10_hps_h2f_axi_master_awlock),
  .h2f_AWCACHE   (s10_hps_h2f_axi_master_awcache),
  .h2f_AWPROT    (s10_hps_h2f_axi_master_awprot),
  .h2f_AWVALID   (s10_hps_h2f_axi_master_awvalid),
  .h2f_AWREADY   (s10_hps_h2f_axi_master_awready),
  .h2f_WDATA     (s10_hps_h2f_axi_master_wdata),
  .h2f_WSTRB     (s10_hps_h2f_axi_master_wstrb),
  .h2f_WLAST     (s10_hps_h2f_axi_master_wlast),
  .h2f_WVALID    (s10_hps_h2f_axi_master_wvalid),
  .h2f_WREADY    (s10_hps_h2f_axi_master_wready),
  .h2f_BID       (s10_hps_h2f_axi_master_bid),
  .h2f_BRESP     (s10_hps_h2f_axi_master_bresp),
  .h2f_BVALID    (s10_hps_h2f_axi_master_bvalid),
  .h2f_BREADY    (s10_hps_h2f_axi_master_bready),
  .h2f_ARID      (s10_hps_h2f_axi_master_arid),
  .h2f_ARADDR    (s10_hps_h2f_axi_master_araddr),
  .h2f_ARLEN     (s10_hps_h2f_axi_master_arlen),
  .h2f_ARSIZE    (s10_hps_h2f_axi_master_arsize),
  .h2f_ARBURST   (s10_hps_h2f_axi_master_arburst),
  .h2f_ARLOCK    (s10_hps_h2f_axi_master_arlock),
  .h2f_ARCACHE   (s10_hps_h2f_axi_master_arcache),
  .h2f_ARPROT    (s10_hps_h2f_axi_master_arprot),
  .h2f_ARVALID   (s10_hps_h2f_axi_master_arvalid),
  .h2f_ARREADY   (s10_hps_h2f_axi_master_arready),
  .h2f_RID       (s10_hps_h2f_axi_master_rid),
  .h2f_RDATA     (s10_hps_h2f_axi_master_rdata),
  .h2f_RRESP     (s10_hps_h2f_axi_master_rresp),
  .h2f_RLAST     (s10_hps_h2f_axi_master_rlast),
  .h2f_RVALID    (s10_hps_h2f_axi_master_rvalid),
  .h2f_RREADY    (s10_hps_h2f_axi_master_rready),

  // ===== AHB request channel from the h2f AXI-to-AHB bridge into ESP top ("mo_*") =====
  .mo_hlock      (mo_hlock),
  .mo_htrans     (mo_htrans),
  .mo_haddr      (mo_haddr),
  .mo_hwrite     (mo_hwrite),
  .mo_hsize      (mo_hsize),
  .mo_hburst     (mo_hburst),
  .mo_hprot      (mo_hprot),
  .mo_hwdata     (mo_hwdata),

  // ===== AHB response channel from ESP top back to the bridge ("mi_*") =====
  .mi_hready     (mi_hready),
  .mi_hresp      (mi_hresp),
  .mi_hrdata     (mi_hrdata),
  .mi_hgrant     (mi_hgrant)
);

// -----------------------------------------------------------------------------
// ESP SoC top (VHDL entity "top")
// -----------------------------------------------------------------------------
top u_esp_top (
  // Board I/O
  .reset        (~system_reset_n),   // VHDL rstgen expects active-high "reset"
  .chip_refclk  (CLK_50_B3C),        // any 50 MHz board clock is fine
  .uart_rxd     (GPIO_P[0]), 
  .uart_txd     (GPIO_P[1]),
  .uart_ctsn    (GPIO_P[2]),  
  .uart_rtsn    (GPIO_P[3]),
  .led          (esp_led),

  // ---------------- DDR AXI master side (ESP -> HPS F2SDRAM0) ---------------
  .ddr_awid     (s10_hps_f2sdram0_data_awid),
  .ddr_awaddr   (esp_f2sdram0_data_awaddr),
  .ddr_awlen    (s10_hps_f2sdram0_data_awlen),
  .ddr_awsize   (s10_hps_f2sdram0_data_awsize),
  .ddr_awburst  (s10_hps_f2sdram0_data_awburst),
  .ddr_awlock   (s10_hps_f2sdram0_data_awlock),
  .ddr_awcache  (s10_hps_f2sdram0_data_awcache),
  .ddr_awprot   (esp_f2sdram0_data_awprot),
  .ddr_awqos    (s10_hps_f2sdram0_data_awqos),
  .ddr_awvalid  (s10_hps_f2sdram0_data_awvalid),
  .ddr_awready  (s10_hps_f2sdram0_data_awready),
  .ddr_wdata    (s10_hps_f2sdram0_data_wdata),
  .ddr_wstrb    (s10_hps_f2sdram0_data_wstrb),
  .ddr_wlast    (s10_hps_f2sdram0_data_wlast),
  .ddr_wvalid   (s10_hps_f2sdram0_data_wvalid),
  .ddr_wready   (s10_hps_f2sdram0_data_wready),
  .ddr_bid      (s10_hps_f2sdram0_data_bid),
  .ddr_bresp    (s10_hps_f2sdram0_data_bresp),
  .ddr_bvalid   (s10_hps_f2sdram0_data_bvalid),
  .ddr_bready   (s10_hps_f2sdram0_data_bready),
  .ddr_arid     (s10_hps_f2sdram0_data_arid),
  .ddr_araddr   (esp_f2sdram0_data_araddr),
  .ddr_arlen    (s10_hps_f2sdram0_data_arlen),
  .ddr_arsize   (s10_hps_f2sdram0_data_arsize),
  .ddr_arburst  (s10_hps_f2sdram0_data_arburst),
  .ddr_arlock   (s10_hps_f2sdram0_data_arlock),
  .ddr_arcache  (s10_hps_f2sdram0_data_arcache),
  .ddr_arprot   (esp_f2sdram0_data_arprot),
  .ddr_arqos    (s10_hps_f2sdram0_data_arqos),
  .ddr_arvalid  (s10_hps_f2sdram0_data_arvalid),
  .ddr_arready  (s10_hps_f2sdram0_data_arready),
  .ddr_rid      (s10_hps_f2sdram0_data_rid),
  .ddr_rdata    (s10_hps_f2sdram0_data_rdata),
  .ddr_rresp    (s10_hps_f2sdram0_data_rresp),
  .ddr_rlast    (s10_hps_f2sdram0_data_rlast),
  .ddr_rvalid   (s10_hps_f2sdram0_data_rvalid),
  .ddr_rready   (s10_hps_f2sdram0_data_rready),

  // ---------------- AHB response path back to the h2f AXI-to-AHB bridge ("mi_*") ------------------
  .mi_hready    (mi_hready),
  .mi_hresp     (mi_hresp),
  .mi_hrdata    (mi_hrdata),
  .mi_hgrant    (mi_hgrant),

  // ---------------- AHB request path from the h2f AXI-to-AHB bridge into ESP top ("mo_*") ------------------
  .mo_hlock     (mo_hlock),
  .mo_htrans    (mo_htrans),
  .mo_haddr     (mo_haddr),
  .mo_hwrite    (mo_hwrite),
  .mo_hsize     (mo_hsize),
  .mo_hburst    (mo_hburst),
  .mo_hprot     (mo_hprot),
  .mo_hwdata    (mo_hwdata)
);

assign LED[0] = ~esp_led[0];
assign LED[1] = ~esp_led[1];
assign LED[2] = ~esp_led[2];
assign LED[3] = ~esp_led[3];

endmodule
