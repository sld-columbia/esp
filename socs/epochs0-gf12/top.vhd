-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

------------------------------------------------------------------------------
-- ESP top-level design connecting CHIP instance with FPGA proxy for testing
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.grlib_config.all;
use work.socmap.all;

entity top is
  generic (
    SIMULATION : boolean                               := false;
    JTAG_TRACE : integer range -1 to CFG_TILES_NUM - 1 := -1);
  port (
    reset             : in    std_logic;
    clk_div_noc       : out   std_logic;
    clk_div           : out   std_logic_vector(0 to CFG_TILES_NUM - 1);  -- tile clock monitor for testing purposes
    -- Ethernet signals
    reset_o2          : out   std_ulogic;
    etx_clk           : in    std_ulogic;
    erx_clk           : in    std_ulogic;
    erxd              : in    std_logic_vector(3 downto 0);
    erx_dv            : in    std_ulogic;
    erx_er            : in    std_ulogic;
    erx_col           : in    std_ulogic;
    erx_crs           : in    std_ulogic;
    etxd              : out   std_logic_vector(3 downto 0);
    etx_en            : out   std_ulogic;
    etx_er            : out   std_ulogic;
    emdc              : out   std_ulogic;
    emdio             : inout std_logic;
    -- DVI
    -- tft_nhpd          : in    std_ulogic;  -- Hot plug
    -- tft_clk_p         : out   std_ulogic;
    -- tft_clk_n         : out   std_ulogic;
    -- tft_data          : out   std_logic_vector(23 downto 0);
    -- tft_hsync         : out   std_ulogic;
    -- tft_vsync         : out   std_ulogic;
    -- tft_de            : out   std_ulogic;
    -- tft_dken          : out   std_ulogic;
    -- tft_ctl1_a1_dk1   : out   std_ulogic;
    -- tft_ctl2_a2_dk2   : out   std_ulogic;
    -- tft_a3_dk3        : out   std_ulogic;
    -- tft_isel          : out   std_ulogic;
    -- tft_bsel          : out   std_ulogic;
    -- tft_dsel          : out   std_ulogic;
    -- tft_edge          : out   std_ulogic;
    -- tft_npd           : out   std_ulogic;
    -- LPDDR0
    lpddr0_ck_p       : out   std_logic;
    lpddr0_ck_n       : out   std_logic;
    lpddr0_cke        : out   std_logic;
    lpddr0_ba         : out   std_logic_vector(2 downto 0);
    lpddr0_addr       : out   std_logic_vector(15 downto 0);
    lpddr0_cs_n       : out   std_logic;
    lpddr0_ras_n      : out   std_logic;
    lpddr0_cas_n      : out   std_logic;
    lpddr0_we_n       : out   std_logic;
    lpddr0_reset_n    : out   std_logic;
    lpddr0_odt        : out   std_logic;
    lpddr0_dm         : out   std_logic_vector(3 downto 0);
    lpddr0_dqs_p      : inout std_logic_vector(3 downto 0);
    lpddr0_dqs_n      : inout std_logic_vector(3 downto 0);
    lpddr0_dq         : inout std_logic_vector(31 downto 0);
    -- LPDDR1
    lpddr1_ck_p       : out   std_logic;
    lpddr1_ck_n       : out   std_logic;
    lpddr1_cke        : out   std_logic;
    lpddr1_ba         : out   std_logic_vector(2 downto 0);
    lpddr1_addr       : out   std_logic_vector(15 downto 0);
    lpddr1_cs_n       : out   std_logic;
    lpddr1_ras_n      : out   std_logic;
    lpddr1_cas_n      : out   std_logic;
    lpddr1_we_n       : out   std_logic;
    lpddr1_reset_n    : out   std_logic;
    lpddr1_odt        : out   std_logic;
    lpddr1_dm         : out   std_logic_vector(3 downto 0);
    lpddr1_dqs_p      : inout std_logic_vector(3 downto 0);
    lpddr1_dqs_n      : inout std_logic_vector(3 downto 0);
    lpddr1_dq         : inout std_logic_vector(31 downto 0);
    -- UART
    uart_rxd          : in    std_logic;   -- UART1_RX (u1i.rxd)
    uart_txd          : out   std_logic;   -- UART1_TX (u1o.txd)
    uart_ctsn         : in    std_logic;   -- UART1_RTSN (u1i.ctsn)
    uart_rtsn         : out   std_logic;   -- UART1_RTSN (u1o.rtsn)
    -- FPGA proxy Ethernet interface
    fpga_reset_o2     : out   std_ulogic;
    fpga_etx_clk      : in    std_ulogic;
    fpga_erx_clk      : in    std_ulogic;
    fpga_erxd         : in    std_logic_vector(3 downto 0);
    fpga_erx_dv       : in    std_ulogic;
    fpga_erx_er       : in    std_ulogic;
    fpga_erx_col      : in    std_ulogic;
    fpga_erx_crs      : in    std_ulogic;
    fpga_etxd         : out   std_logic_vector(3 downto 0);
    fpga_etx_en       : out   std_ulogic;
    fpga_etx_er       : out   std_ulogic;
    fpga_emdc         : out   std_ulogic;
    fpga_emdio        : inout std_logic;
    -- DDR
    clk_ref_p         : in    std_ulogic;  -- 200 MHz clock
    clk_ref_n         : in    std_ulogic;  -- 200 MHz clock
    -- DDR4
    c0_sys_clk_p      : in    std_logic;
    c0_sys_clk_n      : in    std_logic;
    c0_ddr3_dq        : inout std_logic_vector(63 downto 0);
    c0_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
    c0_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
    c0_ddr3_addr      : out   std_logic_vector(14 downto 0);
    c0_ddr3_ba        : out   std_logic_vector(2 downto 0);
    c0_ddr3_ras_n     : out   std_logic;
    c0_ddr3_cas_n     : out   std_logic;
    c0_ddr3_we_n      : out   std_logic;
    c0_ddr3_reset_n   : out   std_logic;
    c0_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
    c0_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
    c0_ddr3_cke       : out   std_logic_vector(0 downto 0);
    c0_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
    c0_ddr3_dm        : out   std_logic_vector(7 downto 0);
    c0_ddr3_odt       : out   std_logic_vector(0 downto 0);
    c0_calib_complete : out   std_logic;
    c0_diagnostic_led : out   std_ulogic;
    c1_sys_clk_p      : in    std_logic;
    c1_sys_clk_n      : in    std_logic;
    c1_ddr3_dq        : inout std_logic_vector(63 downto 0);
    c1_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
    c1_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
    c1_ddr3_addr      : out   std_logic_vector(14 downto 0);
    c1_ddr3_ba        : out   std_logic_vector(2 downto 0);
    c1_ddr3_ras_n     : out   std_logic;
    c1_ddr3_cas_n     : out   std_logic;
    c1_ddr3_we_n      : out   std_logic;
    c1_ddr3_reset_n   : out   std_logic;
    c1_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
    c1_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
    c1_ddr3_cke       : out   std_logic_vector(0 downto 0);
    c1_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
    c1_ddr3_dm        : out   std_logic_vector(7 downto 0);
    c1_ddr3_odt       : out   std_logic_vector(0 downto 0);
    c1_calib_complete : out   std_logic;
    c1_diagnostic_led : out   std_ulogic;
    c2_sys_clk_p      : in    std_logic;
    c2_sys_clk_n      : in    std_logic;
    c2_ddr3_dq        : inout std_logic_vector(63 downto 0);
    c2_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
    c2_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
    c2_ddr3_addr      : out   std_logic_vector(14 downto 0);
    c2_ddr3_ba        : out   std_logic_vector(2 downto 0);
    c2_ddr3_ras_n     : out   std_logic;
    c2_ddr3_cas_n     : out   std_logic;
    c2_ddr3_we_n      : out   std_logic;
    c2_ddr3_reset_n   : out   std_logic;
    c2_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
    c2_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
    c2_ddr3_cke       : out   std_logic_vector(0 downto 0);
    c2_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
    c2_ddr3_dm        : out   std_logic_vector(7 downto 0);
    c2_ddr3_odt       : out   std_logic_vector(0 downto 0);
    c2_calib_complete : out   std_logic;
    c2_diagnostic_led : out   std_ulogic;
    c3_sys_clk_p      : in    std_logic;
    c3_sys_clk_n      : in    std_logic;
    c3_ddr3_dq        : inout std_logic_vector(63 downto 0);
    c3_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
    c3_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
    c3_ddr3_addr      : out   std_logic_vector(14 downto 0);
    c3_ddr3_ba        : out   std_logic_vector(2 downto 0);
    c3_ddr3_ras_n     : out   std_logic;
    c3_ddr3_cas_n     : out   std_logic;
    c3_ddr3_we_n      : out   std_logic;
    c3_ddr3_reset_n   : out   std_logic;
    c3_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
    c3_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
    c3_ddr3_cke       : out   std_logic_vector(0 downto 0);
    c3_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
    c3_ddr3_dm        : out   std_logic_vector(7 downto 0);
    c3_ddr3_odt       : out   std_logic_vector(0 downto 0);
    c3_calib_complete : out   std_logic;
    c3_diagnostic_led : out   std_ulogic;
    -- FPGA proxy main clock
    main_clk_p        : in    std_ulogic;
    main_clk_n        : in    std_ulogic;
    -- FPGA proxy LEDs
    LED_RED           : out   std_ulogic;
    LED_GREEN         : out   std_ulogic;
    LED_BLUE          : out   std_ulogic;
    LED_YELLOW        : out   std_ulogic
    );
end;


architecture rtl of top is

  -----------------------------------------------------------------------------
  -- ESP chip specific instance
  -----------------------------------------------------------------------------
  component EPOCHS0_TOP is
    generic (
      SIMULATION : boolean);
    port (
      reset           : in    std_logic;
      ext_clk_noc     : in    std_logic;
      ext_clk_io      : in    std_logic;
      ext_clk_cpu     : in    std_logic;
      ext_clk_mem     : in    std_logic;
      ext_clk_acc0    : in    std_logic;
      ext_clk_acc1    : in    std_logic;
      clk_div_noc     : out   std_logic;
      clk_div_io      : out   std_logic;
      clk_div_cpu     : out   std_logic;
      clk_div_mem     : out   std_logic;
      clk_div_acc0    : out   std_logic;
      clk_div_acc1    : out   std_logic;
      fpga_data       : inout std_logic_vector(4 * 64 - 1 downto 0);
      fpga_valid_in   : in    std_logic_vector(3 downto 0);
      fpga_valid_out  : out   std_logic_vector(3 downto 0);
      fpga_clk_in     : in    std_logic_vector(3 downto 0);
      fpga_clk_out    : out   std_logic_vector(3 downto 0);
      fpga_credit_in  : in    std_logic_vector(3 downto 0);
      fpga_credit_out : out   std_logic_vector(3 downto 0);
      tdi_cpu         : in    std_logic;
      tdi_io          : in    std_logic;
      tdi_mem         : in    std_logic;
      tdi_acc0        : in    std_logic;
      tdi_acc1        : in    std_logic;
      tdi_acc2        : in    std_logic;
      tdi_acc3        : in    std_logic;
      tdi_acc4        : in    std_logic;
      tdi_acc5        : in    std_logic;
      tdi_acc6        : in    std_logic;
      tdi_acc7        : in    std_logic;
      tdo_cpu         : out   std_logic;
      tdo_io          : out   std_logic;
      tdo_mem         : out   std_logic;
      tdo_acc0        : out   std_logic;
      tdo_acc1        : out   std_logic;
      tdo_acc2        : out   std_logic;
      tdo_acc3        : out   std_logic;
      tdo_acc4        : out   std_logic;
      tdo_acc5        : out   std_logic;
      tdo_acc6        : out   std_logic;
      tdo_acc7        : out   std_logic;
      tms             : in    std_logic;
      tclk            : in    std_logic;
      reset_o2        : out   std_ulogic;
      etx_clk         : in    std_ulogic;
      erx_clk         : in    std_ulogic;
      erxd            : in    std_logic_vector(3 downto 0);
      erx_dv          : in    std_ulogic;
      erx_er          : in    std_ulogic;
      erx_col         : in    std_ulogic;
      erx_crs         : in    std_ulogic;
      etxd            : out   std_logic_vector(3 downto 0);
      etx_en          : out   std_ulogic;
      etx_er          : out   std_ulogic;
      emdc            : out   std_ulogic;
      emdio           : inout std_logic;
      -- tft_nhpd        : in    std_ulogic;
      -- tft_clk_p       : out   std_ulogic;
      -- tft_clk_n       : out   std_ulogic;
      -- tft_data        : out   std_logic_vector(23 downto 0);
      -- tft_hsync       : out   std_ulogic;
      -- tft_vsync       : out   std_ulogic;
      -- tft_de          : out   std_ulogic;
      -- tft_dken        : out   std_ulogic;
      -- tft_ctl1_a1_dk1 : out   std_ulogic;
      -- tft_ctl2_a2_dk2 : out   std_ulogic;
      -- tft_a3_dk3      : out   std_ulogic;
      -- tft_isel        : out   std_ulogic;
      -- tft_bsel        : out   std_ulogic;
      -- tft_dsel        : out   std_ulogic;
      -- tft_edge        : out   std_ulogic;
      -- tft_npd         : out   std_ulogic;
      lpddr0_ck_p     : out   std_logic;
      lpddr0_ck_n     : out   std_logic;
      lpddr0_cke      : out   std_logic;
      lpddr0_ba       : out   std_logic_vector(2 downto 0);
      lpddr0_addr     : out   std_logic_vector(15 downto 0);
      lpddr0_cs_n     : out   std_logic;
      lpddr0_ras_n    : out   std_logic;
      lpddr0_cas_n    : out   std_logic;
      lpddr0_we_n     : out   std_logic;
      lpddr0_reset_n  : out   std_logic;
      lpddr0_odt      : out   std_logic;
      lpddr0_dm       : out   std_logic_vector(3 downto 0);
      lpddr0_dqs_p    : inout std_logic_vector(3 downto 0);
      lpddr0_dqs_n    : inout std_logic_vector(3 downto 0);
      lpddr0_dq       : inout std_logic_vector(31 downto 0);
      lpddr1_ck_p     : out   std_logic;
      lpddr1_ck_n     : out   std_logic;
      lpddr1_cke      : out   std_logic;
      lpddr1_ba       : out   std_logic_vector(2 downto 0);
      lpddr1_addr     : out   std_logic_vector(15 downto 0);
      lpddr1_cs_n     : out   std_logic;
      lpddr1_ras_n    : out   std_logic;
      lpddr1_cas_n    : out   std_logic;
      lpddr1_we_n     : out   std_logic;
      lpddr1_reset_n  : out   std_logic;
      lpddr1_odt      : out   std_logic;
      lpddr1_dm       : out   std_logic_vector(3 downto 0);
      lpddr1_dqs_p    : inout std_logic_vector(3 downto 0);
      lpddr1_dqs_n    : inout std_logic_vector(3 downto 0);
      lpddr1_dq       : inout std_logic_vector(31 downto 0);
      uart_rxd        : in    std_logic;
      uart_txd        : out   std_logic;
      uart_ctsn       : in    std_logic;
      uart_rtsn       : out   std_logic;
      ivr_pmb_dat     : in    std_ulogic;
      ivr_pmb_clk     : in    std_ulogic;
      ivr_avs_clk     : in    std_ulogic;
      ivr_avs_dat     : in    std_ulogic;
      ivr_avs_sdat    : in    std_ulogic;
      ivr_control     : in    std_ulogic;
      ivr_gpio        : in    std_logic_vector(3 downto 0);
      unused          : in    std_ulogic
      );
  end component EPOCHS0_TOP;

  component fpga_proxy_top is
    generic (
      SIMULATION : boolean;
      JTAG_TRACE : integer range -1 to CFG_TILES_NUM - 1);
    port (
      reset             : in    std_ulogic;
      ext_clk_noc       : out   std_logic;
      ext_clk_io        : out   std_logic;
      ext_clk_cpu       : out   std_logic;
      ext_clk_mem       : out   std_logic;
      ext_clk_acc0      : out   std_logic;
      ext_clk_acc1      : out   std_logic;
      main_clk_p        : in    std_ulogic;
      main_clk_n        : in    std_ulogic;
      fpga_data         : inout std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
      fpga_valid_in     : out   std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_valid_out    : in    std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_clk_in       : out   std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_clk_out      : in    std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_credit_in    : out   std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_credit_out   : in    std_logic_vector(0 to CFG_NMEM_TILE - 1);
      tdi               : out   std_logic_vector(0 to CFG_TILES_NUM - 1);
      tdo               : in    std_logic_vector(0 to CFG_TILES_NUM - 1);
      tms               : out   std_logic;
      tclk              : out   std_logic;
      reset_o2          : out   std_ulogic;
      etx_clk           : in    std_ulogic;
      erx_clk           : in    std_ulogic;
      erxd              : in    std_logic_vector(3 downto 0);
      erx_dv            : in    std_ulogic;
      erx_er            : in    std_ulogic;
      erx_col           : in    std_ulogic;
      erx_crs           : in    std_ulogic;
      etxd              : out   std_logic_vector(3 downto 0);
      etx_en            : out   std_ulogic;
      etx_er            : out   std_ulogic;
      emdc              : out   std_ulogic;
      emdio             : inout std_logic;
      clk_ref_p         : in    std_ulogic;  -- 200 MHz clock
      clk_ref_n         : in    std_ulogic;  -- 200 MHz clock
      -- DDR4
      c0_sys_clk_p      : in    std_logic;
      c0_sys_clk_n      : in    std_logic;
      c0_ddr3_dq        : inout std_logic_vector(63 downto 0);
      c0_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
      c0_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
      c0_ddr3_addr      : out   std_logic_vector(14 downto 0);
      c0_ddr3_ba        : out   std_logic_vector(2 downto 0);
      c0_ddr3_ras_n     : out   std_logic;
      c0_ddr3_cas_n     : out   std_logic;
      c0_ddr3_we_n      : out   std_logic;
      c0_ddr3_reset_n   : out   std_logic;
      c0_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
      c0_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
      c0_ddr3_cke       : out   std_logic_vector(0 downto 0);
      c0_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
      c0_ddr3_dm        : out   std_logic_vector(7 downto 0);
      c0_ddr3_odt       : out   std_logic_vector(0 downto 0);
      c0_calib_complete : out   std_logic;
      c0_diagnostic_led : out   std_ulogic;
      c1_sys_clk_p      : in    std_logic;
      c1_sys_clk_n      : in    std_logic;
      c1_ddr3_dq        : inout std_logic_vector(63 downto 0);
      c1_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
      c1_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
      c1_ddr3_addr      : out   std_logic_vector(14 downto 0);
      c1_ddr3_ba        : out   std_logic_vector(2 downto 0);
      c1_ddr3_ras_n     : out   std_logic;
      c1_ddr3_cas_n     : out   std_logic;
      c1_ddr3_we_n      : out   std_logic;
      c1_ddr3_reset_n   : out   std_logic;
      c1_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
      c1_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
      c1_ddr3_cke       : out   std_logic_vector(0 downto 0);
      c1_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
      c1_ddr3_dm        : out   std_logic_vector(7 downto 0);
      c1_ddr3_odt       : out   std_logic_vector(0 downto 0);
      c1_calib_complete : out   std_logic;
      c1_diagnostic_led : out   std_ulogic;
      c2_sys_clk_p      : in    std_logic;
      c2_sys_clk_n      : in    std_logic;
      c2_ddr3_dq        : inout std_logic_vector(63 downto 0);
      c2_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
      c2_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
      c2_ddr3_addr      : out   std_logic_vector(14 downto 0);
      c2_ddr3_ba        : out   std_logic_vector(2 downto 0);
      c2_ddr3_ras_n     : out   std_logic;
      c2_ddr3_cas_n     : out   std_logic;
      c2_ddr3_we_n      : out   std_logic;
      c2_ddr3_reset_n   : out   std_logic;
      c2_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
      c2_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
      c2_ddr3_cke       : out   std_logic_vector(0 downto 0);
      c2_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
      c2_ddr3_dm        : out   std_logic_vector(7 downto 0);
      c2_ddr3_odt       : out   std_logic_vector(0 downto 0);
      c2_calib_complete : out   std_logic;
      c2_diagnostic_led : out   std_ulogic;
      c3_sys_clk_p      : in    std_logic;
      c3_sys_clk_n      : in    std_logic;
      c3_ddr3_dq        : inout std_logic_vector(63 downto 0);
      c3_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
      c3_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
      c3_ddr3_addr      : out   std_logic_vector(14 downto 0);
      c3_ddr3_ba        : out   std_logic_vector(2 downto 0);
      c3_ddr3_ras_n     : out   std_logic;
      c3_ddr3_cas_n     : out   std_logic;
      c3_ddr3_we_n      : out   std_logic;
      c3_ddr3_reset_n   : out   std_logic;
      c3_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
      c3_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
      c3_ddr3_cke       : out   std_logic_vector(0 downto 0);
      c3_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
      c3_ddr3_dm        : out   std_logic_vector(7 downto 0);
      c3_ddr3_odt       : out   std_logic_vector(0 downto 0);
      c3_calib_complete : out   std_logic;
      c3_diagnostic_led : out   std_ulogic;
      LED_RED           : out   std_ulogic;
      LED_GREEN         : out   std_ulogic;
      LED_BLUE          : out   std_ulogic;
      LED_YELLOW        : out   std_ulogic);
  end component fpga_proxy_top;

  -- FPGA proxy memory link
  signal fpga_data       : std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
  signal fpga_valid_in   : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_valid_out  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_in     : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_out    : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_in  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_out : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  -- Test interface
  signal tdi             : std_logic_vector(0 to CFG_TILES_NUM - 1);
  signal tdo             : std_logic_vector(0 to CFG_TILES_NUM - 1);
  signal tms             : std_logic;
  signal tclk            : std_logic;

  -- FPGA-genertated backup external clocks
  signal ext_clk_noc  : std_logic;
  signal ext_clk_io   : std_logic;
  signal ext_clk_cpu  : std_logic;
  signal ext_clk_mem  : std_logic;
  signal ext_clk_acc0 : std_logic;
  signal ext_clk_acc1 : std_logic;

  constant CPU_FREQ : integer := 78125;  -- cpu frequency in KHz
                                         -- (TODO: change for device tree)
begin

  -----------------------------------------------------------------------------
  -- Control FPGA
  -----------------------------------------------------------------------------

  fpga_proxy_top_i : fpga_proxy_top
    generic map (
      SIMULATION => SIMULATION,
      JTAG_TRACE => JTAG_TRACE)
    port map (
      reset             => reset,
      ext_clk_noc       => ext_clk_noc,
      ext_clk_io        => ext_clk_io,
      ext_clk_cpu       => ext_clk_cpu,
      ext_clk_mem       => ext_clk_mem,
      ext_clk_acc0      => ext_clk_acc0,
      ext_clk_acc1      => ext_clk_acc1,
      main_clk_p        => main_clk_p,
      main_clk_n        => main_clk_n,
      fpga_data         => fpga_data,
      fpga_valid_in     => fpga_valid_in,
      fpga_valid_out    => fpga_valid_out,
      fpga_clk_in       => fpga_clk_in,
      fpga_clk_out      => fpga_clk_out,
      fpga_credit_in    => fpga_credit_in,
      fpga_credit_out   => fpga_credit_out,
      tdi               => tdi,
      tdo               => tdo,
      tms               => tms,
      tclk              => tclk,
      reset_o2          => fpga_reset_o2,
      etx_clk           => fpga_etx_clk,
      erx_clk           => fpga_erx_clk,
      erxd              => fpga_erxd,
      erx_dv            => fpga_erx_dv,
      erx_er            => fpga_erx_er,
      erx_col           => fpga_erx_col,
      erx_crs           => fpga_erx_crs,
      etxd              => fpga_etxd,
      etx_en            => fpga_etx_en,
      etx_er            => fpga_etx_er,
      emdc              => fpga_emdc,
      emdio             => fpga_emdio,
      clk_ref_p         => clk_ref_p,
      clk_ref_n         => clk_ref_n,
      c0_sys_clk_p      => c0_sys_clk_p,
      c0_sys_clk_n      => c0_sys_clk_n,
      c0_ddr3_dq        => c0_ddr3_dq,
      c0_ddr3_dqs_p     => c0_ddr3_dqs_p,
      c0_ddr3_dqs_n     => c0_ddr3_dqs_n,
      c0_ddr3_addr      => c0_ddr3_addr,
      c0_ddr3_ba        => c0_ddr3_ba,
      c0_ddr3_ras_n     => c0_ddr3_ras_n,
      c0_ddr3_cas_n     => c0_ddr3_cas_n,
      c0_ddr3_we_n      => c0_ddr3_we_n,
      c0_ddr3_reset_n   => c0_ddr3_reset_n,
      c0_ddr3_ck_p      => c0_ddr3_ck_p,
      c0_ddr3_ck_n      => c0_ddr3_ck_n,
      c0_ddr3_cke       => c0_ddr3_cke,
      c0_ddr3_cs_n      => c0_ddr3_cs_n,
      c0_ddr3_dm        => c0_ddr3_dm,
      c0_ddr3_odt       => c0_ddr3_odt,
      c0_calib_complete => c0_calib_complete,
      c0_diagnostic_led => c0_diagnostic_led,
      c1_sys_clk_p      => c1_sys_clk_p,
      c1_sys_clk_n      => c1_sys_clk_n,
      c1_ddr3_dq        => c1_ddr3_dq,
      c1_ddr3_dqs_p     => c1_ddr3_dqs_p,
      c1_ddr3_dqs_n     => c1_ddr3_dqs_n,
      c1_ddr3_addr      => c1_ddr3_addr,
      c1_ddr3_ba        => c1_ddr3_ba,
      c1_ddr3_ras_n     => c1_ddr3_ras_n,
      c1_ddr3_cas_n     => c1_ddr3_cas_n,
      c1_ddr3_we_n      => c1_ddr3_we_n,
      c1_ddr3_reset_n   => c1_ddr3_reset_n,
      c1_ddr3_ck_p      => c1_ddr3_ck_p,
      c1_ddr3_ck_n      => c1_ddr3_ck_n,
      c1_ddr3_cke       => c1_ddr3_cke,
      c1_ddr3_cs_n      => c1_ddr3_cs_n,
      c1_ddr3_dm        => c1_ddr3_dm,
      c1_ddr3_odt       => c1_ddr3_odt,
      c1_calib_complete => c1_calib_complete,
      c1_diagnostic_led => c1_diagnostic_led,
      c2_sys_clk_p      => c2_sys_clk_p,
      c2_sys_clk_n      => c2_sys_clk_n,
      c2_ddr3_dq        => c2_ddr3_dq,
      c2_ddr3_dqs_p     => c2_ddr3_dqs_p,
      c2_ddr3_dqs_n     => c2_ddr3_dqs_n,
      c2_ddr3_addr      => c2_ddr3_addr,
      c2_ddr3_ba        => c2_ddr3_ba,
      c2_ddr3_ras_n     => c2_ddr3_ras_n,
      c2_ddr3_cas_n     => c2_ddr3_cas_n,
      c2_ddr3_we_n      => c2_ddr3_we_n,
      c2_ddr3_reset_n   => c2_ddr3_reset_n,
      c2_ddr3_ck_p      => c2_ddr3_ck_p,
      c2_ddr3_ck_n      => c2_ddr3_ck_n,
      c2_ddr3_cke       => c2_ddr3_cke,
      c2_ddr3_cs_n      => c2_ddr3_cs_n,
      c2_ddr3_dm        => c2_ddr3_dm,
      c2_ddr3_odt       => c2_ddr3_odt,
      c2_calib_complete => c2_calib_complete,
      c2_diagnostic_led => c2_diagnostic_led,
      c3_sys_clk_p      => c3_sys_clk_p,
      c3_sys_clk_n      => c3_sys_clk_n,
      c3_ddr3_dq        => c3_ddr3_dq,
      c3_ddr3_dqs_p     => c3_ddr3_dqs_p,
      c3_ddr3_dqs_n     => c3_ddr3_dqs_n,
      c3_ddr3_addr      => c3_ddr3_addr,
      c3_ddr3_ba        => c3_ddr3_ba,
      c3_ddr3_ras_n     => c3_ddr3_ras_n,
      c3_ddr3_cas_n     => c3_ddr3_cas_n,
      c3_ddr3_we_n      => c3_ddr3_we_n,
      c3_ddr3_reset_n   => c3_ddr3_reset_n,
      c3_ddr3_ck_p      => c3_ddr3_ck_p,
      c3_ddr3_ck_n      => c3_ddr3_ck_n,
      c3_ddr3_cke       => c3_ddr3_cke,
      c3_ddr3_cs_n      => c3_ddr3_cs_n,
      c3_ddr3_dm        => c3_ddr3_dm,
      c3_ddr3_odt       => c3_ddr3_odt,
      c3_calib_complete => c3_calib_complete,
      c3_diagnostic_led => c3_diagnostic_led,
      LED_RED           => LED_RED,
      LED_GREEN         => LED_GREEN,
      LED_BLUE          => LED_BLUE,
      LED_YELLOW        => LED_YELLOW);


  -----------------------------------------------------------------------------
  -- ESP chip
  -----------------------------------------------------------------------------

  -- Drive unused clock monitors and JTAG output pins
  unused_interface_gen : for i in 0 to CFG_TILES_NUM - 1 generate
    unused_ext_clk_io_gen : if i /= cpu_tile_id(0) and i /= io_tile_id and i /= 1 and i /= 12 and i /= mem_tile_id(0) generate
      clk_div(i) <= '0';
    end generate unused_ext_clk_io_gen;
    unused_td_io_gen : if i /= cpu_tile_id(0) and i /= io_tile_id and i /= mem_tile_id(0) and i /= mem_tile_id(1) and i /= mem_tile_id(2) and i /= mem_tile_id(3)
                         and i /= 8 and i /= 4 and i /= 1 and i /= 2 and i /= 15 generate
      tdo(i) <= '0';
    end generate unused_td_io_gen;
  end generate unused_interface_gen;

  chip_i : EPOCHS0_TOP
    generic map (
      SIMULATION => SIMULATION)
    port map (
      reset           => reset,
      ext_clk_noc     => ext_clk_noc,
      ext_clk_io      => ext_clk_io,
      ext_clk_cpu     => ext_clk_cpu,
      ext_clk_mem     => ext_clk_mem,
      ext_clk_acc0    => ext_clk_acc0,
      ext_clk_acc1    => ext_clk_acc1,
      clk_div_noc     => clk_div_noc,
      clk_div_io      => clk_div(io_tile_id),
      clk_div_cpu     => clk_div(cpu_tile_id(0)),
      clk_div_mem     => clk_div(mem_tile_id(0)),
      clk_div_acc0    => clk_div(1),
      clk_div_acc1    => clk_div(12),
      fpga_data       => fpga_data,
      fpga_valid_in   => fpga_valid_in,
      fpga_valid_out  => fpga_valid_out,
      fpga_clk_in     => fpga_clk_in,
      fpga_clk_out    => fpga_clk_out,
      fpga_credit_in  => fpga_credit_in,
      fpga_credit_out => fpga_credit_out,
      tdi_cpu         => tdi(cpu_tile_id(0)),
      tdi_io          => tdi(io_tile_id),
      tdi_mem         => tdi(mem_tile_id(0)),
      tdi_acc0        => tdi(8),
      tdi_acc1        => tdi(4),
      tdi_acc2        => tdi(1),
      tdi_acc3        => tdi(2),
      tdi_acc4        => tdi(mem_tile_id(1)),
      tdi_acc5        => tdi(15),
      tdi_acc6        => tdi(mem_tile_id(3)),
      tdi_acc7        => tdi(mem_tile_id(2)),
      tdo_cpu         => tdo(cpu_tile_id(0)),
      tdo_io          => tdo(io_tile_id),
      tdo_mem         => tdo(mem_tile_id(0)),
      tdo_acc0        => tdo(8),
      tdo_acc1        => tdo(4),
      tdo_acc2        => tdo(1),
      tdo_acc3        => tdo(2),
      tdo_acc4        => tdo(mem_tile_id(1)),
      tdo_acc5        => tdo(15),
      tdo_acc6        => tdo(mem_tile_id(3)),
      tdo_acc7        => tdo(mem_tile_id(2)),
      tms             => tms,
      tclk            => tclk,
      reset_o2        => reset_o2,
      etx_clk         => etx_clk,
      erx_clk         => erx_clk,
      erxd            => erxd,
      erx_dv          => erx_dv,
      erx_er          => erx_er,
      erx_col         => erx_col,
      erx_crs         => erx_crs,
      etxd            => etxd,
      etx_en          => etx_en,
      etx_er          => etx_er,
      emdc            => emdc,
      emdio           => emdio,
      -- tft_nhpd        => tft_nhpd,
      -- tft_clk_p       => tft_clk_p,
      -- tft_clk_n       => tft_clk_n,
      -- tft_data        => tft_data,
      -- tft_hsync       => tft_hsync,
      -- tft_vsync       => tft_vsync,
      -- tft_de          => tft_de,
      -- tft_dken        => tft_dken,
      -- tft_ctl1_a1_dk1 => tft_ctl1_a1_dk1,
      -- tft_ctl2_a2_dk2 => tft_ctl2_a2_dk2,
      -- tft_a3_dk3      => tft_a3_dk3,
      -- tft_isel        => tft_isel,
      -- tft_bsel        => tft_bsel,
      -- tft_dsel        => tft_dsel,
      -- tft_edge        => tft_edge,
      -- tft_npd         => tft_npd,
      lpddr0_ck_p     => lpddr0_ck_p,
      lpddr0_ck_n     => lpddr0_ck_n,
      lpddr0_cke      => lpddr0_cke,
      lpddr0_ba       => lpddr0_ba,
      lpddr0_addr     => lpddr0_addr,
      lpddr0_cs_n     => lpddr0_cs_n,
      lpddr0_ras_n    => lpddr0_ras_n,
      lpddr0_cas_n    => lpddr0_cas_n,
      lpddr0_we_n     => lpddr0_we_n,
      lpddr0_reset_n  => lpddr0_reset_n,
      lpddr0_odt      => lpddr0_odt,
      lpddr0_dm       => lpddr0_dm,
      lpddr0_dqs_p    => lpddr0_dqs_p,
      lpddr0_dqs_n    => lpddr0_dqs_n,
      lpddr0_dq       => lpddr0_dq,
      lpddr1_ck_p     => lpddr1_ck_p,
      lpddr1_ck_n     => lpddr1_ck_n,
      lpddr1_cke      => lpddr1_cke,
      lpddr1_ba       => lpddr1_ba,
      lpddr1_addr     => lpddr1_addr,
      lpddr1_cs_n     => lpddr1_cs_n,
      lpddr1_ras_n    => lpddr1_ras_n,
      lpddr1_cas_n    => lpddr1_cas_n,
      lpddr1_we_n     => lpddr1_we_n,
      lpddr1_reset_n  => lpddr1_reset_n,
      lpddr1_odt      => lpddr1_odt,
      lpddr1_dm       => lpddr1_dm,
      lpddr1_dqs_p    => lpddr1_dqs_p,
      lpddr1_dqs_n    => lpddr1_dqs_n,
      lpddr1_dq       => lpddr1_dq,
      uart_rxd        => uart_rxd,
      uart_txd        => uart_txd,
      uart_ctsn       => uart_ctsn,
      uart_rtsn       => uart_rtsn,
      ivr_pmb_dat     => '0',
      ivr_pmb_clk     => '0',
      ivr_avs_clk     => '0',
      ivr_avs_dat     => '0',
      ivr_avs_sdat    => '0',
      ivr_control     => '0',
      ivr_gpio        => (others => '0'),
      unused          => '0'
      );

end;
