-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Testbench for ESP on proFPGA xc7v2000t with DDR3, Ethernet and DVI
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.libdcom.all;
use work.sim.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;

use work.grlib_config.all;
use work.esp_global.all;

entity testbench is
  generic (
    SIMULATION : boolean := true;
    JTAG_TRACE : integer range -1 to CFG_TILES_NUM - 1 := -1);
end;

architecture behav of testbench is

  -- Ethernet signals
  signal reset_o2 : std_ulogic;
  signal etx_clk  : std_ulogic;
  signal erx_clk  : std_ulogic;
  signal erxd     : std_logic_vector(3 downto 0);
  signal erx_dv   : std_ulogic;
  signal erx_er   : std_ulogic;
  signal erx_col  : std_ulogic;
  signal erx_crs  : std_ulogic;
  signal etxd     : std_logic_vector(3 downto 0);
  signal etx_en   : std_ulogic;
  signal etx_er   : std_ulogic;
  signal emdc     : std_ulogic;
  signal emdio    : std_logic;

  -- DVI
  -- signal tft_nhpd        : std_ulogic;
  -- signal tft_clk_p       : std_ulogic;
  -- signal tft_clk_n       : std_ulogic;
  -- signal tft_data        : std_logic_vector(23 downto 0);
  -- signal tft_hsync       : std_ulogic;
  -- signal tft_vsync       : std_ulogic;
  -- signal tft_de          : std_ulogic;
  -- signal tft_dken        : std_ulogic;
  -- signal tft_ctl1_a1_dk1 : std_ulogic;
  -- signal tft_ctl2_a2_dk2 : std_ulogic;
  -- signal tft_a3_dk3      : std_ulogic;
  -- signal tft_isel        : std_ulogic;
  -- signal tft_bsel        : std_logic;
  -- signal tft_dsel        : std_logic;
  -- signal tft_edge        : std_ulogic;
  -- signal tft_npd         : std_ulogic;

  -- Clock and reset
  signal reset      : std_ulogic := '1';

  signal main_clk_p : std_ulogic := '0';
  signal main_clk_n : std_ulogic := '1';

  signal jtag_clk_p : std_ulogic := '0';
  signal jtag_clk_n : std_ulogic := '1';

  signal clk_ref_p     : std_ulogic := '0';
  signal clk_ref_n     : std_ulogic := '1';

  signal sys_clk_p : std_ulogic := '0';
  signal sys_clk_n : std_ulogic := '1';

  -- Chip clock used for emulation on FPGA only
  signal clk_emu_p   : std_ulogic  := '0';
  signal clk_emu_n   : std_ulogic  := '1';

  -- FPGA Ethernet
  signal fpga_reset_o2     : std_ulogic;
  signal fpga_etx_clk      : std_ulogic;
  signal fpga_erx_clk      : std_ulogic;
  signal fpga_erxd         : std_logic_vector(3 downto 0);
  signal fpga_erx_dv       : std_ulogic;
  signal fpga_erx_er       : std_ulogic;
  signal fpga_erx_col      : std_ulogic;
  signal fpga_erx_crs      : std_ulogic;
  signal fpga_etxd         : std_logic_vector(3 downto 0);
  signal fpga_etx_en       : std_ulogic;
  signal fpga_etx_er       : std_ulogic;
  signal fpga_emdc         : std_ulogic;
  signal fpga_emdio        : std_logic;

 -- DDR3 memory
  signal ddr3_dq      : std_logic_vector(63 downto 0);
  signal ddr3_dqs_p   : std_logic_vector(7 downto 0);
  signal ddr3_dqs_n   : std_logic_vector(7 downto 0);
  signal ddr3_addr    : std_logic_vector(14 downto 0);
  signal ddr3_ba      : std_logic_vector(2 downto 0);
  signal ddr3_ras_n   : std_logic;
  signal ddr3_cas_n   : std_logic;
  signal ddr3_we_n    : std_logic;
  signal ddr3_reset_n : std_logic;
  signal ddr3_ck_p    : std_logic_vector(0 downto 0);
  signal ddr3_ck_n    : std_logic_vector(0 downto 0);
  signal ddr3_cke     : std_logic_vector(0 downto 0);
  signal ddr3_cs_n    : std_logic_vector(0 downto 0);
  signal ddr3_dm      : std_logic_vector(7 downto 0);
  signal ddr3_odt     : std_logic_vector(0 downto 0);
  signal calib_complete : std_logic;
  signal diagnostic_led : std_ulogic;

  -- UART
  signal uart_rxd  : std_ulogic;
  signal uart_txd  : std_ulogic;
  signal uart_ctsn : std_ulogic;
  signal uart_rtsn : std_ulogic;


  component top
    generic (
      SIMULATION : boolean;
      JTAG_TRACE : integer range -1 to CFG_TILES_NUM - 1);
    port (
      -- Main reset
      reset             : in    std_ulogic;
      -- Chip clock used for emulation on FPGA only
      clk_emu_p         : in    std_ulogic;
      clk_emu_n         : in    std_ulogic;
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
      -- tft_bsel          : out   std_logic;
      -- tft_dsel          : out   std_logic;
      -- tft_edge          : out   std_ulogic;
      -- tft_npd           : out   std_ulogic;
      -- LPDDR0
      -- UART
      uart_rxd          : in    std_ulogic;
      uart_txd          : out   std_ulogic;
      uart_ctsn         : in    std_ulogic;
      uart_rtsn         : out   std_ulogic;
      -- FPGA Ethernet
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
      -- DDR3
      sys_clk_p      : in    std_logic;
      sys_clk_n      : in    std_logic;
      ddr3_dq        : inout std_logic_vector(63 downto 0);
      ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
      ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
      ddr3_addr      : out   std_logic_vector(14 downto 0);
      ddr3_ba        : out   std_logic_vector(2 downto 0);
      ddr3_ras_n     : out   std_logic;
      ddr3_cas_n     : out   std_logic;
      ddr3_we_n      : out   std_logic;
      ddr3_reset_n   : out   std_logic;
      ddr3_ck_p      : out   std_logic_vector(0 downto 0);
      ddr3_ck_n      : out   std_logic_vector(0 downto 0);
      ddr3_cke       : out   std_logic_vector(0 downto 0);
      ddr3_cs_n      : out   std_logic_vector(0 downto 0);
      ddr3_dm        : out   std_logic_vector(7 downto 0);
      ddr3_odt       : out   std_logic_vector(0 downto 0);
      calib_complete : out   std_logic;
      diagnostic_led : out   std_ulogic;
      -- FPGA proxy main clock
      main_clk_p        : in    std_ulogic;  -- 78.25 MHz clock
      main_clk_n        : in    std_ulogic;  -- 78.25 MHz clock
      jtag_clk_p        : in    std_ulogic;
      jtag_clk_n        : in    std_ulogic;
      -- LEDs
      LED_RED           : out   std_ulogic;
      LED_GREEN         : out   std_ulogic;
      LED_BLUE          : out   std_ulogic;
      LED_YELLOW        : out   std_ulogic);

  end component;

begin

  -- clock and reset
  reset        <= '0'              after 2500 ns;

  main_clk_p <= not main_clk_p after 5 ns;
  main_clk_n <= not main_clk_n after 5 ns;

  jtag_clk_p <= not jtag_clk_p after 25 ns;
  jtag_clk_n <= not jtag_clk_n after 25 ns;

  clk_ref_p <= not clk_ref_p after 2.5 ns;
  clk_ref_n <= not clk_ref_n after 2.5 ns;

  sys_clk_p <= not sys_clk_p after 2.5 ns;
  sys_clk_n <= not sys_clk_n after 2.5 ns;

  clk_emu_p <= not clk_emu_p after 10 ns;
  clk_emu_n <= not clk_emu_n after 10 ns;

  -- UART
  uart_rxd  <= '0';
  uart_ctsn <= '0';

  -- FPGA Ethernet
  fpga_etx_clk           <= '0';
  fpga_erx_clk           <= '0';
  fpga_erxd              <= (others => '0');
  fpga_erx_dv            <= '0';
  fpga_erx_er            <= '0';
  fpga_erx_col           <= '0';
  fpga_erx_crs           <= '0';
  fpga_emdio             <= 'Z';

  -- DDR3 (memory simulation model does not emulate DDR behavior)
  ddr3_dq    <= (others => 'Z');
  ddr3_dqs_p <= (others => 'Z');
  ddr3_dqs_n <= (others => 'Z');

  -- Ethernet
  etx_clk           <= '0';
  erx_clk           <= '0';
  erxd              <= (others => '0');
  erx_dv            <= '0';
  erx_er            <= '0';
  erx_col           <= '0';
  erx_crs           <= '0';
  emdio             <= 'Z';

  -- DVI
  -- tft_nhpd <= '0';

  top_1 : top
    generic map (
      SIMULATION => SIMULATION,
      JTAG_TRACE => JTAG_TRACE
      )
    port map (
      reset             => reset,
      clk_emu_p         => clk_emu_p,
      clk_emu_n         => clk_emu_n,
      uart_rxd          => uart_rxd,
      uart_txd          => uart_txd,
      uart_ctsn         => uart_ctsn,
      uart_rtsn         => uart_rtsn,
      reset_o2          => reset_o2,
      etx_clk           => etx_clk,
      erx_clk           => erx_clk,
      erxd              => erxd(3 downto 0),
      erx_dv            => erx_dv,
      erx_er            => erx_er,
      erx_col           => erx_col,
      erx_crs           => erx_crs,
      etxd              => etxd(3 downto 0),
      etx_en            => etx_en,
      etx_er            => etx_er,
      emdc              => emdc,
      emdio             => emdio,
      -- tft_nhpd          => tft_nhpd,
      -- tft_clk_p         => tft_clk_p,
      -- tft_clk_n         => tft_clk_n,
      -- tft_data          => tft_data,
      -- tft_hsync         => tft_hsync,
      -- tft_vsync         => tft_vsync,
      -- tft_de            => tft_de,
      -- tft_dken          => tft_dken,
      -- tft_ctl1_a1_dk1   => tft_ctl1_a1_dk1,
      -- tft_ctl2_a2_dk2   => tft_ctl2_a2_dk2,
      -- tft_a3_dk3        => tft_a3_dk3,
      -- tft_isel          => tft_isel,
      -- tft_bsel          => tft_bsel,
      -- tft_dsel          => tft_dsel,
      -- tft_edge          => tft_edge,
      -- tft_npd           => tft_npd,
      fpga_reset_o2     => fpga_reset_o2,
      fpga_etx_clk      => fpga_etx_clk,
      fpga_erx_clk      => fpga_erx_clk,
      fpga_erxd         => fpga_erxd,
      fpga_erx_dv       => fpga_erx_dv,
      fpga_erx_er       => fpga_erx_er,
      fpga_erx_col      => fpga_erx_col,
      fpga_erx_crs      => fpga_erx_crs,
      fpga_etxd         => fpga_etxd,
      fpga_etx_en       => fpga_etx_en,
      fpga_etx_er       => fpga_etx_er,
      fpga_emdc         => fpga_emdc,
      fpga_emdio        => fpga_emdio,
      clk_ref_p         => clk_ref_p,
      clk_ref_n         => clk_ref_n,
      sys_clk_p      => sys_clk_p,
      sys_clk_n      => sys_clk_n,
      ddr3_dq        => ddr3_dq,
      ddr3_dqs_p     => ddr3_dqs_p,
      ddr3_dqs_n     => ddr3_dqs_n,
      ddr3_addr      => ddr3_addr,
      ddr3_ba        => ddr3_ba,
      ddr3_ras_n     => ddr3_ras_n,
      ddr3_cas_n     => ddr3_cas_n,
      ddr3_we_n      => ddr3_we_n,
      ddr3_reset_n   => ddr3_reset_n,
      ddr3_ck_p      => ddr3_ck_p,
      ddr3_ck_n      => ddr3_ck_n,
      ddr3_cke       => ddr3_cke,
      ddr3_cs_n      => ddr3_cs_n,
      ddr3_dm        => ddr3_dm,
      ddr3_odt       => ddr3_odt,
      calib_complete => open,
      diagnostic_led => open,
      main_clk_p        => main_clk_p,
      main_clk_n        => main_clk_n,
      jtag_clk_p        => jtag_clk_p,
      jtag_clk_n        => jtag_clk_n,
      LED_RED           => open,
      LED_GREEN         => open,
      LED_BLUE          => open,
      LED_YELLOW        => open
      );

end;

