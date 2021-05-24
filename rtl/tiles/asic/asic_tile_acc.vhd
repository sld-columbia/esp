-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Accelerator Tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;
use work.misc.all;
use work.coretypes.all;
use work.esp_acc_regmap.all;
use work.socmap.all;
use work.grlib_config.all;
use work.tiles_pkg.all;

entity asic_tile_acc is
  generic (
    this_hls_conf      : hlscfg_t             := 0;
    this_device        : devid_t              := 0;
    this_irq_type      : integer              := 0;
    this_has_l2        : integer range 0 to 1 := 0;
    ROUTER_PORTS       : ports_vec            := "11111");
  port (
    rst                : in  std_ulogic;
    sys_clk            : in  std_ulogic;  -- NoC clock
    ext_clk            : in  std_ulogic;  -- backup tile clock
    -- ext_clk_sel     : in  std_ulogic;  -- backup tile clock select ??(usign registers otherwise)
    clk_div            : out std_ulogic;  -- tile clock monitor for testing purposes
    -- Test interface
    tdi                : in  std_logic;
    tdo                : out std_logic;
    tms                : in  std_logic;
    tclk               : in  std_logic;
    -- Pad configuratio
    pad_cfg            : out std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
    -- NOC
    noc1_data_n_in     : in  noc_flit_type;
    noc1_data_s_in     : in  noc_flit_type;
    noc1_data_w_in     : in  noc_flit_type;
    noc1_data_e_in     : in  noc_flit_type;
    noc1_data_void_in  : in  std_logic_vector(3 downto 0);
    noc1_stop_in       : in  std_logic_vector(3 downto 0);
    noc1_data_n_out    : out noc_flit_type;
    noc1_data_s_out    : out noc_flit_type;
    noc1_data_w_out    : out noc_flit_type;
    noc1_data_e_out    : out noc_flit_type;
    noc1_data_void_out : out std_logic_vector(3 downto 0);
    noc1_stop_out      : out std_logic_vector(3 downto 0);
    noc2_data_n_in     : in  noc_flit_type;
    noc2_data_s_in     : in  noc_flit_type;
    noc2_data_w_in     : in  noc_flit_type;
    noc2_data_e_in     : in  noc_flit_type;
    noc2_data_void_in  : in  std_logic_vector(3 downto 0);
    noc2_stop_in       : in  std_logic_vector(3 downto 0);
    noc2_data_n_out    : out noc_flit_type;
    noc2_data_s_out    : out noc_flit_type;
    noc2_data_w_out    : out noc_flit_type;
    noc2_data_e_out    : out noc_flit_type;
    noc2_data_void_out : out std_logic_vector(3 downto 0);
    noc2_stop_out      : out std_logic_vector(3 downto 0);
    noc3_data_n_in     : in  noc_flit_type;
    noc3_data_s_in     : in  noc_flit_type;
    noc3_data_w_in     : in  noc_flit_type;
    noc3_data_e_in     : in  noc_flit_type;
    noc3_data_void_in  : in  std_logic_vector(3 downto 0);
    noc3_stop_in       : in  std_logic_vector(3 downto 0);
    noc3_data_n_out    : out noc_flit_type;
    noc3_data_s_out    : out noc_flit_type;
    noc3_data_w_out    : out noc_flit_type;
    noc3_data_e_out    : out noc_flit_type;
    noc3_data_void_out : out std_logic_vector(3 downto 0);
    noc3_stop_out      : out std_logic_vector(3 downto 0);
    noc4_data_n_in     : in  noc_flit_type;
    noc4_data_s_in     : in  noc_flit_type;
    noc4_data_w_in     : in  noc_flit_type;
    noc4_data_e_in     : in  noc_flit_type;
    noc4_data_void_in  : in  std_logic_vector(3 downto 0);
    noc4_stop_in       : in  std_logic_vector(3 downto 0);
    noc4_data_n_out    : out noc_flit_type;
    noc4_data_s_out    : out noc_flit_type;
    noc4_data_w_out    : out noc_flit_type;
    noc4_data_e_out    : out noc_flit_type;
    noc4_data_void_out : out std_logic_vector(3 downto 0);
    noc4_stop_out      : out std_logic_vector(3 downto 0);
    noc5_data_n_in     : in  misc_noc_flit_type;
    noc5_data_s_in     : in  misc_noc_flit_type;
    noc5_data_w_in     : in  misc_noc_flit_type;
    noc5_data_e_in     : in  misc_noc_flit_type;
    noc5_data_void_in  : in  std_logic_vector(3 downto 0);
    noc5_stop_in       : in  std_logic_vector(3 downto 0);
    noc5_data_n_out    : out misc_noc_flit_type;
    noc5_data_s_out    : out misc_noc_flit_type;
    noc5_data_w_out    : out misc_noc_flit_type;
    noc5_data_e_out    : out misc_noc_flit_type;
    noc5_data_void_out : out std_logic_vector(3 downto 0);
    noc5_stop_out      : out std_logic_vector(3 downto 0);
    noc6_data_n_in     : in  noc_flit_type;
    noc6_data_s_in     : in  noc_flit_type;
    noc6_data_w_in     : in  noc_flit_type;
    noc6_data_e_in     : in  noc_flit_type;
    noc6_data_void_in  : in  std_logic_vector(3 downto 0);
    noc6_stop_in       : in  std_logic_vector(3 downto 0);
    noc6_data_n_out    : out noc_flit_type;
    noc6_data_s_out    : out noc_flit_type;
    noc6_data_w_out    : out noc_flit_type;
    noc6_data_e_out    : out noc_flit_type;
    noc6_data_void_out : out std_logic_vector(3 downto 0);
    noc6_stop_out      : out std_logic_vector(3 downto 0)
    );

end;

architecture rtl of asic_tile_acc is

  constant ext_clk_sel_default : std_ulogic := '0';

  -- Tile clock and reset (only for I/O tile)
  signal raw_rstn     : std_ulogic;
  signal dco_clk      : std_ulogic;
  signal dco_rstn     : std_ulogic;
  signal dco_clk_lock : std_ulogic;

  signal refclk : std_ulogic;

begin

  -- On FPGA we don't have a DCO and we cannot instantiate a PLL on every tile
  -- for large designs. Therefore, we must use the external clock and disable
  -- the generic this_has_dco. I addition, since the chip top level may not
  -- have neough pins to connect a backup clock for each tile, we use the NoC
  -- clock as the main tile clock, because this clock is guaranteed to be connected.
  regular_ext_clk_gen: if ESP_EMU = 0 generate
    refclk <= ext_clk;
  end generate;
  emu_ext_clk_gen: if ESP_EMU /= 0 generate
    refclk <= sys_clk;
  end generate;

  rst1 : rstgen                         -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, dco_clk, dco_clk_lock, dco_rstn, raw_rstn);

  tile_acc_1: tile_acc
    generic map (
      this_hls_conf      => this_hls_conf,
      this_device        => this_device,
      this_irq_type      => this_irq_type,
      this_has_l2        => this_has_l2,
      this_has_dvfs      => 0,          -- no DVFS controller
      this_has_pll       => 0,
      this_has_dco       => 1 - ESP_EMU,-- use DCO
      this_extra_clk_buf => 0,
      test_if_en         => 1,          -- enable test interface
      ROUTER_PORTS       => ROUTER_PORTS,
      HAS_SYNC           => 1)
    port map (
      raw_rstn           => raw_rstn,
      rst                => dco_rstn,
      refclk             => refclk,
      pllbypass          => ext_clk_sel_default,  --ext_clk_sel (unused; using CSRs instead)
      pllclk             => clk_div,
      dco_clk            => dco_clk,
      dco_clk_lock       => dco_clk_lock,
      tdi                => tdi,
      tdo                => tdo,
      tms                => tms,
      tclk               => tclk,
      pad_cfg            => pad_cfg,
      sys_clk_int        => sys_clk,
      noc1_data_n_in     => noc1_data_n_in,
      noc1_data_s_in     => noc1_data_s_in,
      noc1_data_w_in     => noc1_data_w_in,
      noc1_data_e_in     => noc1_data_e_in,
      noc1_data_void_in  => noc1_data_void_in,
      noc1_stop_in       => noc1_stop_in,
      noc1_data_n_out    => noc1_data_n_out,
      noc1_data_s_out    => noc1_data_s_out,
      noc1_data_w_out    => noc1_data_w_out,
      noc1_data_e_out    => noc1_data_e_out,
      noc1_data_void_out => noc1_data_void_out,
      noc1_stop_out      => noc1_stop_out,
      noc2_data_n_in     => noc2_data_n_in,
      noc2_data_s_in     => noc2_data_s_in,
      noc2_data_w_in     => noc2_data_w_in,
      noc2_data_e_in     => noc2_data_e_in,
      noc2_data_void_in  => noc2_data_void_in,
      noc2_stop_in       => noc2_stop_in,
      noc2_data_n_out    => noc2_data_n_out,
      noc2_data_s_out    => noc2_data_s_out,
      noc2_data_w_out    => noc2_data_w_out,
      noc2_data_e_out    => noc2_data_e_out,
      noc2_data_void_out => noc2_data_void_out,
      noc2_stop_out      => noc2_stop_out,
      noc3_data_n_in     => noc3_data_n_in,
      noc3_data_s_in     => noc3_data_s_in,
      noc3_data_w_in     => noc3_data_w_in,
      noc3_data_e_in     => noc3_data_e_in,
      noc3_data_void_in  => noc3_data_void_in,
      noc3_stop_in       => noc3_stop_in,
      noc3_data_n_out    => noc3_data_n_out,
      noc3_data_s_out    => noc3_data_s_out,
      noc3_data_w_out    => noc3_data_w_out,
      noc3_data_e_out    => noc3_data_e_out,
      noc3_data_void_out => noc3_data_void_out,
      noc3_stop_out      => noc3_stop_out,
      noc4_data_n_in     => noc4_data_n_in,
      noc4_data_s_in     => noc4_data_s_in,
      noc4_data_w_in     => noc4_data_w_in,
      noc4_data_e_in     => noc4_data_e_in,
      noc4_data_void_in  => noc4_data_void_in,
      noc4_stop_in       => noc4_stop_in,
      noc4_data_n_out    => noc4_data_n_out,
      noc4_data_s_out    => noc4_data_s_out,
      noc4_data_w_out    => noc4_data_w_out,
      noc4_data_e_out    => noc4_data_e_out,
      noc4_data_void_out => noc4_data_void_out,
      noc4_stop_out      => noc4_stop_out,
      noc5_data_n_in     => noc5_data_n_in,
      noc5_data_s_in     => noc5_data_s_in,
      noc5_data_w_in     => noc5_data_w_in,
      noc5_data_e_in     => noc5_data_e_in,
      noc5_data_void_in  => noc5_data_void_in,
      noc5_stop_in       => noc5_stop_in,
      noc5_data_n_out    => noc5_data_n_out,
      noc5_data_s_out    => noc5_data_s_out,
      noc5_data_w_out    => noc5_data_w_out,
      noc5_data_e_out    => noc5_data_e_out,
      noc5_data_void_out => noc5_data_void_out,
      noc5_stop_out      => noc5_stop_out,
      noc6_data_n_in     => noc6_data_n_in,
      noc6_data_s_in     => noc6_data_s_in,
      noc6_data_w_in     => noc6_data_w_in,
      noc6_data_e_in     => noc6_data_e_in,
      noc6_data_void_in  => noc6_data_void_in,
      noc6_stop_in       => noc6_stop_in,
      noc6_data_n_out    => noc6_data_n_out,
      noc6_data_s_out    => noc6_data_s_out,
      noc6_data_w_out    => noc6_data_w_out,
      noc6_data_e_out    => noc6_data_e_out,
      noc6_data_void_out => noc6_data_void_out,
      noc6_stop_out      => noc6_stop_out,
      noc1_mon_noc_vec   => open,
      noc2_mon_noc_vec   => open,
      noc3_mon_noc_vec   => open,
      noc4_mon_noc_vec   => open,
      noc5_mon_noc_vec   => open,
      noc6_mon_noc_vec   => open,
      mon_dvfs_in        => monitor_dvfs_none,
      mon_acc            => open,
      mon_cache          => open,
      mon_dvfs           => open
      );
end;
