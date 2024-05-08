-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
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

entity testbench is
end entity testbench;

architecture behav of testbench is

  constant SIMULATION : boolean := true;

  -- Ethernet signals
  signal reset_o2 : std_ulogic;
  signal etx_clk  : std_ulogic;
  signal erx_clk  : std_ulogic;
  signal erxdt    : std_logic_vector(7 downto 0);
  signal erx_dv   : std_ulogic;
  signal erx_er   : std_ulogic;
  signal erx_col  : std_ulogic;
  signal erx_crs  : std_ulogic;
  signal etxdt    : std_logic_vector(7 downto 0);
  signal etx_en   : std_ulogic;
  signal etx_er   : std_ulogic;
  signal emdc     : std_ulogic;
  signal emdio    : std_logic;

  -- DVI
  --  signal tft_nhpd        : std_ulogic;
  --  signal tft_clk_p       : std_ulogic;
  --  signal tft_clk_n       : std_ulogic;
  --  signal tft_data        : std_logic_vector(23 downto 0);
  --  signal tft_hsync       : std_ulogic;
  --  signal tft_vsync       : std_ulogic;
  --  signal tft_de          : std_ulogic;
  --  signal tft_dken        : std_ulogic;
  --  signal tft_ctl1_a1_dk1 : std_ulogic;
  --  signal tft_ctl2_a2_dk2 : std_ulogic;
  --  signal tft_a3_dk3      : std_ulogic;
  --  signal tft_isel        : std_ulogic;
  --  signal tft_bsel        : std_logic;
  --  signal tft_dsel        : std_logic;
  --  signal tft_edge        : std_ulogic;
  --  signal tft_npd         : std_ulogic;

  -- Clock and reset
  signal reset        : std_ulogic := '1';
  signal c0_sys_clk_p : std_ulogic := '0';
  signal c0_sys_clk_n : std_ulogic := '1';
  signal c1_sys_clk_p : std_ulogic := '0';
  signal c1_sys_clk_n : std_ulogic := '1';
  signal c2_sys_clk_p : std_ulogic := '0';
  signal c2_sys_clk_n : std_ulogic := '1';
  signal c3_sys_clk_p : std_ulogic := '0';
  signal c3_sys_clk_n : std_ulogic := '1';
  signal esp_clk_p    : std_ulogic := '0';
  signal esp_clk_n    : std_ulogic := '1';

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

  signal c1_ddr4_act_n     : std_logic;
  signal c1_ddr4_adr       : std_logic_vector(16 downto 0);
  signal c1_ddr4_ba        : std_logic_vector(1 downto 0);
  signal c1_ddr4_bg        : std_logic_vector(1 downto 0);
  signal c1_ddr4_cke       : std_logic_vector(1 downto 0);
  signal c1_ddr4_odt       : std_logic_vector(1 downto 0);
  signal c1_ddr4_cs_n      : std_logic_vector(1 downto 0);
  signal c1_ddr4_ck_t      : std_logic_vector(0 downto 0);
  signal c1_ddr4_ck_c      : std_logic_vector(0 downto 0);
  signal c1_ddr4_reset_n   : std_logic;
  signal c1_ddr4_dm_dbi_n  : std_logic_vector(8 downto 0);
  signal c1_ddr4_dq        : std_logic_vector(71 downto 0);
  signal c1_ddr4_dqs_c     : std_logic_vector(8 downto 0);
  signal c1_ddr4_dqs_t     : std_logic_vector(8 downto 0);
  signal c1_calib_complete : std_logic;
  signal c1_diagnostic_led : std_ulogic;

  signal c2_ddr4_act_n     : std_logic;
  signal c2_ddr4_adr       : std_logic_vector(16 downto 0);
  signal c2_ddr4_ba        : std_logic_vector(1 downto 0);
  signal c2_ddr4_bg        : std_logic_vector(1 downto 0);
  signal c2_ddr4_cke       : std_logic_vector(1 downto 0);
  signal c2_ddr4_odt       : std_logic_vector(1 downto 0);
  signal c2_ddr4_cs_n      : std_logic_vector(1 downto 0);
  signal c2_ddr4_ck_t      : std_logic_vector(0 downto 0);
  signal c2_ddr4_ck_c      : std_logic_vector(0 downto 0);
  signal c2_ddr4_reset_n   : std_logic;
  signal c2_ddr4_dm_dbi_n  : std_logic_vector(8 downto 0);
  signal c2_ddr4_dq        : std_logic_vector(71 downto 0);
  signal c2_ddr4_dqs_c     : std_logic_vector(8 downto 0);
  signal c2_ddr4_dqs_t     : std_logic_vector(8 downto 0);
  signal c2_calib_complete : std_logic;
  signal c2_diagnostic_led : std_ulogic;

  signal c3_ddr4_act_n     : std_logic;
  signal c3_ddr4_adr       : std_logic_vector(16 downto 0);
  signal c3_ddr4_ba        : std_logic_vector(1 downto 0);
  signal c3_ddr4_bg        : std_logic_vector(1 downto 0);
  signal c3_ddr4_cke       : std_logic_vector(1 downto 0);
  signal c3_ddr4_odt       : std_logic_vector(1 downto 0);
  signal c3_ddr4_cs_n      : std_logic_vector(1 downto 0);
  signal c3_ddr4_ck_t      : std_logic_vector(0 downto 0);
  signal c3_ddr4_ck_c      : std_logic_vector(0 downto 0);
  signal c3_ddr4_reset_n   : std_logic;
  signal c3_ddr4_dm_dbi_n  : std_logic_vector(8 downto 0);
  signal c3_ddr4_dq        : std_logic_vector(71 downto 0);
  signal c3_ddr4_dqs_c     : std_logic_vector(8 downto 0);
  signal c3_ddr4_dqs_t     : std_logic_vector(8 downto 0);
  signal c3_calib_complete : std_logic;
  signal c3_diagnostic_led : std_ulogic;

  -- UART
  signal uart_rxd  : std_ulogic;
  signal uart_txd  : std_ulogic;
  signal uart_ctsn : std_ulogic;
  signal uart_rtsn : std_ulogic;

  -- MMI64
  signal profpga_clk0_p  : std_ulogic := '0'; -- 100 MHz clock
  signal profpga_clk0_n  : std_ulogic := '1'; -- 100 MHz clock
  signal profpga_sync0_p : std_ulogic;
  signal profpga_sync0_n : std_ulogic;
  signal dmbi_h2f        : std_logic_vector(19 downto 0);
  signal dmbi_f2h        : std_logic_vector(19 downto 0);

  component top is
    generic (
      simulation : boolean
    );
    port (
      -- MMI64 interface:
      profpga_clk0_p  : in    std_ulogic;
      profpga_clk0_n  : in    std_ulogic;
      profpga_sync0_p : in    std_ulogic;
      profpga_sync0_n : in    std_ulogic;
      dmbi_h2f        : in    std_logic_vector(19 downto 0);
      dmbi_f2h        : out   std_logic_vector(19 downto 0);
      -- Main ESP clock
      esp_clk_p : in    std_ulogic;
      esp_clk_n : in    std_ulogic;
      reset     : in    std_ulogic;
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
      c1_sys_clk_p      : in    std_logic;
      c1_sys_clk_n      : in    std_logic;
      c1_ddr4_act_n     : out   std_logic;
      c1_ddr4_adr       : out   std_logic_vector(16 downto 0);
      c1_ddr4_ba        : out   std_logic_vector(1 downto 0);
      c1_ddr4_bg        : out   std_logic_vector(1 downto 0);
      c1_ddr4_cke       : out   std_logic_vector(1 downto 0);
      c1_ddr4_odt       : out   std_logic_vector(1 downto 0);
      c1_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
      c1_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
      c1_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
      c1_ddr4_reset_n   : out   std_logic;
      c1_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
      c1_ddr4_dq        : inout std_logic_vector(71 downto 0);
      c1_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
      c1_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
      c1_calib_complete : out   std_logic;
      c1_diagnostic_led : out   std_ulogic;
      c2_sys_clk_p      : in    std_logic;
      c2_sys_clk_n      : in    std_logic;
      c2_ddr4_act_n     : out   std_logic;
      c2_ddr4_adr       : out   std_logic_vector(16 downto 0);
      c2_ddr4_ba        : out   std_logic_vector(1 downto 0);
      c2_ddr4_bg        : out   std_logic_vector(1 downto 0);
      c2_ddr4_cke       : out   std_logic_vector(1 downto 0);
      c2_ddr4_odt       : out   std_logic_vector(1 downto 0);
      c2_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
      c2_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
      c2_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
      c2_ddr4_reset_n   : out   std_logic;
      c2_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
      c2_ddr4_dq        : inout std_logic_vector(71 downto 0);
      c2_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
      c2_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
      c2_calib_complete : out   std_logic;
      c2_diagnostic_led : out   std_ulogic;
      c3_sys_clk_p      : in    std_logic;
      c3_sys_clk_n      : in    std_logic;
      c3_ddr4_act_n     : out   std_logic;
      c3_ddr4_adr       : out   std_logic_vector(16 downto 0);
      c3_ddr4_ba        : out   std_logic_vector(1 downto 0);
      c3_ddr4_bg        : out   std_logic_vector(1 downto 0);
      c3_ddr4_cke       : out   std_logic_vector(1 downto 0);
      c3_ddr4_odt       : out   std_logic_vector(1 downto 0);
      c3_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
      c3_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
      c3_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
      c3_ddr4_reset_n   : out   std_logic;
      c3_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
      c3_ddr4_dq        : inout std_logic_vector(71 downto 0);
      c3_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
      c3_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
      c3_calib_complete : out   std_logic;
      c3_diagnostic_led : out   std_ulogic;
      -- UART
      uart_rxd  : in    std_ulogic;
      uart_txd  : out   std_ulogic;
      uart_ctsn : in    std_ulogic;
      uart_rtsn : out   std_ulogic;
      -- Ethernet signals
      reset_o2 : out   std_ulogic;
      etx_clk  : in    std_ulogic;
      erx_clk  : in    std_ulogic;
      erxd     : in    std_logic_vector(3 downto 0);
      erx_dv   : in    std_ulogic;
      erx_er   : in    std_ulogic;
      erx_col  : in    std_ulogic;
      erx_crs  : in    std_ulogic;
      etxd     : out   std_logic_vector(3 downto 0);
      etx_en   : out   std_ulogic;
      etx_er   : out   std_ulogic;
      emdc     : out   std_ulogic;
      emdio    : inout std_logic;
      -- DVI
      --      tft_nhpd          : in    std_ulogic;  -- Hot plug
      --      tft_clk_p         : out   std_ulogic;
      --      tft_clk_n         : out   std_ulogic;
      --      tft_data          : out   std_logic_vector(23 downto 0);
      --      tft_hsync         : out   std_ulogic;
      --      tft_vsync         : out   std_ulogic;
      --      tft_de            : out   std_ulogic;
      --      tft_dken          : out   std_ulogic;
      --      tft_ctl1_a1_dk1   : out   std_ulogic;
      --      tft_ctl2_a2_dk2   : out   std_ulogic;
      --      tft_a3_dk3        : out   std_ulogic;
      --      tft_isel          : out   std_ulogic;
      --      tft_bsel          : out   std_logic;
      --      tft_dsel          : out   std_logic;
      --      tft_edge          : out   std_ulogic;
      --      tft_npd           : out   std_ulogic;
      -- LEDs
      led_red    : out   std_ulogic;
      led_green  : out   std_ulogic;
      led_blue   : out   std_ulogic;
      led_yellow : out   std_ulogic
    );
  end component;

begin

  -- MMI64
  profpga_clk0_p  <= not profpga_clk0_p after 5 ns;
  profpga_clk0_n  <= not profpga_clk0_n after 5 ns;
  profpga_sync0_p <= '0';
  profpga_sync0_n <= '1';
  dmbi_h2f        <= (others => '0');

  -- clock and reset
  reset        <= '0'              after 2500 ns;
  c0_sys_clk_p <= not c0_sys_clk_p after 4.0 ns;
  c0_sys_clk_n <= not c0_sys_clk_n after 4.0 ns;
  c1_sys_clk_p <= not c1_sys_clk_p after 4.0 ns;
  c1_sys_clk_n <= not c1_sys_clk_n after 4.0 ns;
  c2_sys_clk_p <= not c2_sys_clk_p after 4.0 ns;
  c2_sys_clk_n <= not c2_sys_clk_n after 4.0 ns;
  c3_sys_clk_p <= not c3_sys_clk_p after 4.0 ns;
  c3_sys_clk_n <= not c3_sys_clk_n after 4.0 ns;
  esp_clk_p    <= not esp_clk_p    after 5.0 ns;
  esp_clk_n    <= not esp_clk_n    after 5.0 ns;

  -- UART
  uart_rxd  <= '0';
  uart_ctsn <= '0';

  -- DDR4 (memory simulation model does not emulate DDR behavior)
  c0_ddr4_dm_dbi_n <= (others => 'Z');
  c0_ddr4_dq       <= (others => 'Z');
  c0_ddr4_dqs_c    <= (others => 'Z');
  c0_ddr4_dqs_t    <= (others => 'Z');
  c1_ddr4_dm_dbi_n <= (others => 'Z');
  c1_ddr4_dq       <= (others => 'Z');
  c1_ddr4_dqs_c    <= (others => 'Z');
  c1_ddr4_dqs_t    <= (others => 'Z');
  c2_ddr4_dm_dbi_n <= (others => 'Z');
  c2_ddr4_dq       <= (others => 'Z');
  c2_ddr4_dqs_c    <= (others => 'Z');
  c2_ddr4_dqs_t    <= (others => 'Z');
  c3_ddr4_dm_dbi_n <= (others => 'Z');
  c3_ddr4_dq       <= (others => 'Z');
  c3_ddr4_dqs_c    <= (others => 'Z');
  c3_ddr4_dqs_t    <= (others => 'Z');

  top_1 : component top
    generic map (
      simulation => SIMULATION
    )
    port map (
      -- MMI64
      profpga_clk0_p    => profpga_clk0_p,
      profpga_clk0_n    => profpga_clk0_n,
      profpga_sync0_p   => profpga_sync0_p,
      profpga_sync0_n   => profpga_sync0_n,
      dmbi_h2f          => dmbi_h2f,
      dmbi_f2h          => dmbi_f2h,
      esp_clk_p         => esp_clk_p,
      esp_clk_n         => esp_clk_n,
      reset             => reset,
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
      c1_sys_clk_p      => c1_sys_clk_p,
      c1_sys_clk_n      => c1_sys_clk_n,
      c1_ddr4_act_n     => c1_ddr4_act_n,
      c1_ddr4_adr       => c1_ddr4_adr,
      c1_ddr4_ba        => c1_ddr4_ba,
      c1_ddr4_bg        => c1_ddr4_bg,
      c1_ddr4_cke       => c1_ddr4_cke,
      c1_ddr4_odt       => c1_ddr4_odt,
      c1_ddr4_cs_n      => c1_ddr4_cs_n,
      c1_ddr4_ck_t      => c1_ddr4_ck_t,
      c1_ddr4_ck_c      => c1_ddr4_ck_c,
      c1_ddr4_reset_n   => c1_ddr4_reset_n,
      c1_ddr4_dm_dbi_n  => c1_ddr4_dm_dbi_n,
      c1_ddr4_dq        => c1_ddr4_dq,
      c1_ddr4_dqs_c     => c1_ddr4_dqs_c,
      c1_ddr4_dqs_t     => c1_ddr4_dqs_t,
      c1_calib_complete => open,
      c1_diagnostic_led => open,
      c2_sys_clk_p      => c2_sys_clk_p,
      c2_sys_clk_n      => c2_sys_clk_n,
      c2_ddr4_act_n     => c2_ddr4_act_n,
      c2_ddr4_adr       => c2_ddr4_adr,
      c2_ddr4_ba        => c2_ddr4_ba,
      c2_ddr4_bg        => c2_ddr4_bg,
      c2_ddr4_cke       => c2_ddr4_cke,
      c2_ddr4_odt       => c2_ddr4_odt,
      c2_ddr4_cs_n      => c2_ddr4_cs_n,
      c2_ddr4_ck_t      => c2_ddr4_ck_t,
      c2_ddr4_ck_c      => c2_ddr4_ck_c,
      c2_ddr4_reset_n   => c2_ddr4_reset_n,
      c2_ddr4_dm_dbi_n  => c2_ddr4_dm_dbi_n,
      c2_ddr4_dq        => c2_ddr4_dq,
      c2_ddr4_dqs_c     => c2_ddr4_dqs_c,
      c2_ddr4_dqs_t     => c2_ddr4_dqs_t,
      c2_calib_complete => open,
      c2_diagnostic_led => open,
      c3_sys_clk_p      => c3_sys_clk_p,
      c3_sys_clk_n      => c3_sys_clk_n,
      c3_ddr4_act_n     => c3_ddr4_act_n,
      c3_ddr4_adr       => c3_ddr4_adr,
      c3_ddr4_ba        => c3_ddr4_ba,
      c3_ddr4_bg        => c3_ddr4_bg,
      c3_ddr4_cke       => c3_ddr4_cke,
      c3_ddr4_odt       => c3_ddr4_odt,
      c3_ddr4_cs_n      => c3_ddr4_cs_n,
      c3_ddr4_ck_t      => c3_ddr4_ck_t,
      c3_ddr4_ck_c      => c3_ddr4_ck_c,
      c3_ddr4_reset_n   => c3_ddr4_reset_n,
      c3_ddr4_dm_dbi_n  => c3_ddr4_dm_dbi_n,
      c3_ddr4_dq        => c3_ddr4_dq,
      c3_ddr4_dqs_c     => c3_ddr4_dqs_c,
      c3_ddr4_dqs_t     => c3_ddr4_dqs_t,
      c3_calib_complete => open,
      c3_diagnostic_led => open,
      uart_rxd          => uart_rxd,
      uart_txd          => uart_txd,
      uart_ctsn         => uart_ctsn,
      uart_rtsn         => uart_rtsn,
      reset_o2          => reset_o2,
      etx_clk           => etx_clk,
      erx_clk           => erx_clk,
      erxd              => erxdt(3 downto 0),
      erx_dv            => erx_dv,
      erx_er            => erx_er,
      erx_col           => erx_col,
      erx_crs           => erx_crs,
      etxd              => etxdt(3 downto 0),
      etx_en            => etx_en,
      etx_er            => etx_er,
      emdc              => emdc,
      emdio             => emdio,
      --      tft_nhpd          => '0',
      --      tft_clk_p         => tft_clk_p,
      --      tft_clk_n         => tft_clk_n,
      --      tft_data          => tft_data,
      --      tft_hsync         => tft_hsync,
      --      tft_vsync         => tft_vsync,
      --      tft_de            => tft_de,
      --      tft_dken          => tft_dken,
      --      tft_ctl1_a1_dk1   => tft_ctl1_a1_dk1,
      --      tft_ctl2_a2_dk2   => tft_ctl2_a2_dk2,
      --      tft_a3_dk3        => tft_a3_dk3,
      --      tft_isel          => tft_isel,
      --      tft_bsel          => tft_bsel,
      --      tft_dsel          => tft_dsel,
      --      tft_edge          => tft_edge,
      --      tft_npd           => tft_npd,
      led_red    => open,
      led_green  => open,
      led_blue   => open,
      led_yellow => open
    );

end architecture behav;

