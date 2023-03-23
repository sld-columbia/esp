-- Copyright (c) 2011-2020 Columbia University, System Level Design Group
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
    clk_emu_p         : in    std_logic;
    clk_emu_n         : in    std_logic;
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
    emdio             : inout std_logic;     -- UART
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
    -- DDR0
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
    main_clk_p        : in    std_ulogic;
    main_clk_n        : in    std_ulogic;
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
      clk_emu_p       : in    std_logic;
      clk_emu_n       : in    std_logic;
      ext_clk         : in    std_logic;
      fpga_data       : inout std_logic_vector(64 - 1 downto 0);
      fpga_valid_in   : in    std_logic_vector(0 downto 0);
      fpga_valid_out  : out   std_logic_vector(0 downto 0);
      fpga_clk_in     : in    std_logic_vector(0 downto 0);
      fpga_clk_out    : out   std_logic_vector(0 downto 0);
      fpga_credit_in  : in    std_logic_vector(0 downto 0);
      fpga_credit_out : out   std_logic_vector(0 downto 0);
      -- I/O link
      iolink_data       : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_valid_in   : in    std_ulogic;
      iolink_valid_out  : out   std_ulogic;
      iolink_clk_in     : in    std_ulogic;
      iolink_clk_out    : out   std_ulogic;
      iolink_credit_in  : in    std_ulogic;
      iolink_credit_out : out   std_ulogic;
      --Etherenet
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
      --UART
      uart_rxd        : in    std_logic;
      uart_txd        : out   std_logic;
      uart_ctsn       : in    std_logic;
      uart_rtsn       : out   std_logic;
      --JTAG
      tclk            : in    std_logic;
      tms             : in    std_logic;
      tdi_io          : in    std_logic;
      tdi_cpu         : in    std_logic;
      tdi_mem         : in    std_logic;
      tdi_acc         : in    std_logic;
      tdo_io          : out   std_logic;
      tdo_cpu         : out   std_logic;
      tdo_mem         : out   std_logic;
      tdo_acc         : out   std_logic
  );
  end component chip_emu_top;

  component fpga_proxy_top is
    generic (
      SIMULATION : boolean;
      JTAG_TRACE : integer range -1 to CFG_TILES_NUM - 1);
    port (
      reset             : in    std_ulogic;
      chip_reset        : out   std_ulogic;
      ext_clk_noc       : out   std_logic;
      ext_clk           : out   std_logic;
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
      iolink_data       : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_valid_in   : in    std_ulogic;
      iolink_valid_out  : out   std_ulogic;
      iolink_clk_in     : in    std_ulogic;
      iolink_clk_out    : out   std_ulogic;
      iolink_credit_in  : in    std_ulogic;
      iolink_credit_out : out   std_ulogic;
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
      clk_ref_p         : in    std_logic;
      clk_ref_n         : in    std_logic;
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
      LED_RED           : out   std_ulogic;
      LED_GREEN         : out   std_ulogic;
      LED_BLUE          : out   std_ulogic;
      LED_YELLOW        : out   std_ulogic);
  end component fpga_proxy_top;

  --Chip reset
  signal chip_reset : std_logic;

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
  signal ext_clk_noc : std_logic;
  signal ext_clk     : std_logic;  -- backup tile clock

  constant CPU_FREQ : integer := 50000;  -- cpu frequency in KHz
                                         -- (TODO: change for device tree)

  signal iolink_data_chip       : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_valid_in_chip   : std_ulogic;
  signal iolink_valid_out_chip  : std_ulogic;
  signal iolink_clk_in_chip     : std_ulogic;
  signal iolink_clk_out_chip    : std_ulogic;
  signal iolink_credit_in_chip  : std_ulogic;
  signal iolink_credit_out_chip : std_ulogic;

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
      ext_clk           => ext_clk,
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
      iolink_data       => iolink_data_chip,
      iolink_valid_in   => iolink_valid_out_chip,
      iolink_valid_out  => iolink_valid_in_chip,
      iolink_clk_in     => iolink_clk_out_chip,
      iolink_clk_out    => iolink_clk_in_chip,
      iolink_credit_in  => iolink_credit_out_chip,
      iolink_credit_out => iolink_credit_in_chip,
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
      calib_complete => calib_complete,
      diagnostic_led => diagnostic_led,
      LED_RED           => LED_RED,
      LED_GREEN         => LED_GREEN,
      LED_BLUE          => LED_BLUE,
      LED_YELLOW        => LED_YELLOW);


  -----------------------------------------------------------------------------
  -- ESP chip
  -----------------------------------------------------------------------------

  -- Drive unused clock monitors and JTAG output pins
  -- unused_interface_gen : for i in 0 to CFG_TILES_NUM - 1 generate
  --  unused_td_io_gen : if i /= cpu_tile_id(0) and i /= io_tile_id and i /= mem_tile_id(0) generate
  --    tdo(i) <= '0';
  --  end generate unused_td_io_gen;
  --end generate unused_interface_gen;

  chip_i : chip_emu_top
    generic map (
      SIMULATION => SIMULATION)
    port map (
      reset             => chip_reset,
      clk_emu_p         => clk_emu_p,
      clk_emu_n         => clk_emu_n,
      ext_clk           => ext_clk_noc,
      fpga_data         => fpga_data,
      fpga_valid_in     => fpga_valid_in,
      fpga_valid_out    => fpga_valid_out,
      fpga_clk_in       => fpga_clk_in,
      fpga_clk_out      => fpga_clk_out,
      fpga_credit_in    => fpga_credit_in,
      fpga_credit_out   => fpga_credit_out,
      iolink_data       => iolink_data_chip,
      iolink_valid_in   => iolink_valid_in_chip,
      iolink_valid_out  => iolink_valid_out_chip,
      iolink_clk_in     => iolink_clk_in_chip,
      iolink_clk_out    => iolink_clk_out_chip,
      iolink_credit_in  => iolink_credit_in_chip,
      iolink_credit_out => iolink_credit_out_chip,
      reset_o2          => reset_o2,
      etx_clk           => etx_clk,
      erx_clk           => erx_clk,
      erxd              => erxd,
      erx_dv            => erx_dv,
      erx_er            => erx_er,
      erx_col           => erx_col,
      erx_crs           => erx_crs,
      etxd              => etxd,
      etx_en            => etx_en,
      etx_er            => etx_er,
      emdc              => emdc,
      emdio             => emdio,
      uart_rxd          => uart_rxd,
      uart_txd          => uart_txd,
      uart_ctsn         => uart_ctsn,
      uart_rtsn         => uart_rtsn,
      tms               => tms,
      tclk              => tclk,
      tdi_io            => tdi(0),
      tdi_cpu           => tdi(1),
      tdi_mem           => tdi(3),
      tdi_acc           => tdi(2),
      tdo_io            => tdo(0),
      tdo_cpu           => tdo(1),
      tdo_mem           => tdo(3),
      tdo_acc           => tdo(2)
    );

end;
