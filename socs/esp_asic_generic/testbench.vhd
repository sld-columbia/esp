-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Testbench for ESP on proFPGA xcvu440 with DDR4, Ethernet and DVI
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

  signal c0_sys_clk_p : std_ulogic := '0';
  signal c0_sys_clk_n : std_ulogic := '1';

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

  -- DDR4 memory
  signal c0_ddr4_act_n     : std_logic;
  signal c0_ddr4_adr       : std_logic_vector(16 downto 0);
  signal c0_ddr4_ba        : std_logic_vector(1 downto 0);
  signal c0_ddr4_bg        : std_logic_vector(1 downto 0);
  signal c0_ddr4_cke       : std_logic_vector(1 downto 0);
  signal c0_ddr4_odt       : std_logic_vector(1 downto 0);
  signal c0_ddr4_cs_n      : std_logic_vector(1 downto 0);
  signal c0_ddr4_ck_t      : std_logic_vector(0 downto 0);
  signal c0_ddr4_ck_c      : std_logic_vector(0 downto 0);
  signal c0_ddr4_reset_n   : std_logic;
  signal c0_ddr4_dm_dbi_n  : std_logic_vector(8 downto 0);
  signal c0_ddr4_dq        : std_logic_vector(71 downto 0);
  signal c0_ddr4_dqs_c     : std_logic_vector(8 downto 0);
  signal c0_ddr4_dqs_t     : std_logic_vector(8 downto 0);
  signal c0_calib_complete : std_logic;
  signal c0_diagnostic_led : std_ulogic;

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
      -- DDR4
      c0_sys_clk_p      : in    std_logic;
      c0_sys_clk_n      : in    std_logic;
      c0_ddr4_act_n     : out   std_logic;
      c0_ddr4_adr       : out   std_logic_vector(16 downto 0);
      c0_ddr4_ba        : out   std_logic_vector(1 downto 0);
      c0_ddr4_bg        : out   std_logic_vector(1 downto 0);
      c0_ddr4_cke       : out   std_logic_vector(1 downto 0);
      c0_ddr4_odt       : out   std_logic_vector(1 downto 0);
      c0_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
      c0_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
      c0_ddr4_reset_n   : out   std_logic;
      c0_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
      c0_ddr4_dq        : inout std_logic_vector(71 downto 0);
      c0_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
      c0_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
      c0_calib_complete : out   std_logic;
      c0_diagnostic_led : out   std_ulogic;
      -- FPGA proxy main clock
      main_clk_p        : in    std_ulogic;  -- 78.25 MHz clock
      main_clk_n        : in    std_ulogic;  -- 78.25 MHz clock
      -- LEDs
      LED_RED           : out   std_ulogic;
      LED_GREEN         : out   std_ulogic;
      LED_BLUE          : out   std_ulogic;
      LED_YELLOW        : out   std_ulogic);

  end component;

begin

  -- clock and reset
  reset        <= '0'              after 2500 ns;

  main_clk_p <= not main_clk_p after 6.4 ns;
  main_clk_n <= not main_clk_n after 6.4 ns;

  c0_sys_clk_p <= not c0_sys_clk_p after 4.0 ns;
  c0_sys_clk_n <= not c0_sys_clk_n after 4.0 ns;

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

  -- DDR4 (memory simulation model does not emulate DDR behavior)
  c0_ddr4_dm_dbi_n <= (others => 'Z');
  c0_ddr4_dq       <= (others => 'Z');
  c0_ddr4_dqs_c    <= (others => 'Z');
  c0_ddr4_dqs_t    <= (others => 'Z');

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
      c0_sys_clk_p      => c0_sys_clk_p,
      c0_sys_clk_n      => c0_sys_clk_n,
      c0_ddr4_act_n     => c0_ddr4_act_n,
      c0_ddr4_adr       => c0_ddr4_adr,
      c0_ddr4_ba        => c0_ddr4_ba,
      c0_ddr4_bg        => c0_ddr4_bg,
      c0_ddr4_cke       => c0_ddr4_cke,
      c0_ddr4_odt       => c0_ddr4_odt,
      c0_ddr4_cs_n      => c0_ddr4_cs_n,
      c0_ddr4_ck_t      => c0_ddr4_ck_t,
      c0_ddr4_ck_c      => c0_ddr4_ck_c,
      c0_ddr4_reset_n   => c0_ddr4_reset_n,
      c0_ddr4_dm_dbi_n  => c0_ddr4_dm_dbi_n,
      c0_ddr4_dq        => c0_ddr4_dq,
      c0_ddr4_dqs_c     => c0_ddr4_dqs_c,
      c0_ddr4_dqs_t     => c0_ddr4_dqs_t,
      c0_calib_complete => open,
      c0_diagnostic_led => open,
      main_clk_p        => main_clk_p,
      main_clk_n        => main_clk_n,
      LED_RED           => open,
      LED_GREEN         => open,
      LED_BLUE          => open,
      LED_YELLOW        => open
      );

end;

