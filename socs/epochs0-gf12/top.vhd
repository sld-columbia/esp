-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
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
    JTAG_TRACE : integer range -1 to CFG_TILES_NUM -1 := -1);
  port (
    reset             : in    std_logic;
    -- Chip clock used for emulation on FPGA only
    clk_emu_p         : in    std_logic;
    clk_emu_n         : in    std_logic;
    -- Divided clock brought to top for testing purposes
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
    -- FPGA proxy main clock
    jtag_clk_p        : in    std_ulogic;
    jtag_clk_n        : in    std_ulogic;
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
  component chip_emu_top is
    generic (
      SIMULATION : boolean);
    port (
      reset           : in    std_logic;
      -- Chip clock used for emulation on FPGA only
      clk_emu_p       : in    std_logic;
      clk_emu_n       : in    std_logic;
      -- Backup external clocks for selected tiles and NoC
      ext_clk_noc     : in    std_logic;
      ext_clk_io      : in    std_logic;
      ext_clk_cpu     : in    std_logic;
      ext_clk_mem     : in    std_logic;
      ext_clk_acc0    : in    std_logic;
      ext_clk_acc1    : in    std_logic;
      -- FPGA proxy memory link
      fpga_data       : inout std_logic_vector(4 * 64 - 1 downto 0);
      fpga_valid_in   : in    std_logic_vector(3 downto 0);
      fpga_valid_out  : out   std_logic_vector(3 downto 0);
      fpga_clk_in     : in    std_logic_vector(3 downto 0);
      fpga_clk_out    : out   std_logic_vector(3 downto 0);
      fpga_credit_in  : in    std_logic_vector(3 downto 0);
      fpga_credit_out : out   std_logic_vector(3 downto 0);
      -- Test interface
      tdi             : in    std_logic_vector(0 to CFG_TILES_NUM - 1);
      tdo             : out   std_logic_vector(0 to CFG_TILES_NUM - 1);
      tms             : in    std_logic;
      tclk            : in    std_logic;
      -- Ethernet signals
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
      -- UART
      uart_rxd        : in    std_logic;  -- UART1_RX (u1i.rxd)
      uart_txd        : out   std_logic;  -- UART1_TX (u1o.txd)
      uart_ctsn       : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
      uart_rtsn       : out   std_logic   -- UART1_RTSN (u1o.rtsn)
      );
  end component chip_emu_top;

  component fpga_proxy_top is
    generic (
      SIMULATION : boolean;
      JTAG_TRACE : integer range -1 to CFG_TILES_NUM - 1);
    port (
      reset             : in    std_ulogic;
      chip_reset        : out   std_ulogic;  -- Chip reset (active high)
      ext_clk_noc       : out   std_logic;
      ext_clk_io        : out   std_logic;
      ext_clk_cpu       : out   std_logic;
      ext_clk_mem       : out   std_logic;
      ext_clk_acc0      : out   std_logic;
      ext_clk_acc1      : out   std_logic;
      main_clk_p        : in    std_ulogic;
      main_clk_n        : in    std_ulogic;
      jtag_clk_p        : in    std_ulogic;
      jtag_clk_n        : in    std_ulogic;
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

  signal chip_reset : std_ulogic;

  constant CPU_FREQ : integer := 50000;  -- cpu frequency in KHz

  attribute mark_debug : string;
  attribute mark_debug of tclk : signal is "true";
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
      chip_reset        => chip_reset,
      ext_clk_noc       => ext_clk_noc,
      ext_clk_io        => ext_clk_io,
      ext_clk_cpu       => ext_clk_cpu,
      ext_clk_mem       => ext_clk_mem,
      ext_clk_acc0      => ext_clk_acc0,
      ext_clk_acc1      => ext_clk_acc1,
      main_clk_p        => main_clk_p,
      main_clk_n        => main_clk_n,
      jtag_clk_p        => jtag_clk_p,
      jtag_clk_n        => jtag_clk_n,
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

  chip_i : chip_emu_top
    generic map (
      SIMULATION => SIMULATION)
    port map (
      reset           => chip_reset,
      clk_emu_p       => clk_emu_p,
      clk_emu_n       => clk_emu_n,
      ext_clk_noc     => ext_clk_noc,
      ext_clk_io      => ext_clk_io,
      ext_clk_cpu     => ext_clk_cpu,
      ext_clk_mem     => ext_clk_mem,
      ext_clk_acc0    => ext_clk_acc0,
      ext_clk_acc1    => ext_clk_acc1,
      fpga_data       => fpga_data,
      fpga_valid_in   => fpga_valid_in,
      fpga_valid_out  => fpga_valid_out,
      fpga_clk_in     => fpga_clk_in,
      fpga_clk_out    => fpga_clk_out,
      fpga_credit_in  => fpga_credit_in,
      fpga_credit_out => fpga_credit_out,
      tdi             => tdi,
      tdo             => tdo,
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
      uart_rxd        => uart_rxd,
      uart_txd        => uart_txd,
      uart_ctsn       => uart_ctsn,
      uart_rtsn       => uart_rtsn
      );

end;
