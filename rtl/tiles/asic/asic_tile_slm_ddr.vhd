-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Memory interface tile
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
use work.leon3.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.ahb2mig_7series_pkg.all;
use work.coretypes.all;

use work.grlib_config.all;
use work.socmap.all;
use work.tiles_pkg.all;

entity asic_tile_slm_ddr is
  generic (
    ROUTER_PORTS : ports_vec := "11111");
  port (
    rst                : in  std_ulogic;
    sys_clk            : in  std_ulogic;  -- NoC clock
    ext_clk            : in  std_ulogic;  -- backup tile clock
    -- ext_clk_sel     : in  std_ulogic;  -- backup tile clock select ??(usign registers otherwise)
    clk_div            : out std_ulogic;  -- tile clock monitor for testing purposes
    -- LPDDR
    lpddr_o_calib_done : out std_ulogic;
    lpddr_o_ck_p       : out std_logic;
    lpddr_o_ck_n       : out std_logic;
    lpddr_o_cke        : out std_logic;
    lpddr_o_ba         : out std_logic_vector(2 downto 0);
    lpddr_o_addr       : out std_logic_vector(15 downto 0);
    lpddr_o_cs_n       : out std_logic;
    lpddr_o_ras_n      : out std_logic;
    lpddr_o_cas_n      : out std_logic;
    lpddr_o_we_n       : out std_logic;
    lpddr_o_reset_n    : out std_logic;
    lpddr_o_odt        : out std_logic;
    lpddr_o_dm_oen     : out std_logic_vector(3 downto 0);
    lpddr_o_dm         : out std_logic_vector(3 downto 0);
    lpddr_o_dqs_p_oen  : out std_logic_vector(3 downto 0);
    lpddr_o_dqs_p_ien  : out std_logic_vector(3 downto 0);
    lpddr_o_dqs_p_o    : out std_logic_vector(3 downto 0);
    lpddr_o_dqs_n_oen  : out std_logic_vector(3 downto 0);
    lpddr_o_dqs_n_ien  : out std_logic_vector(3 downto 0);
    lpddr_o_dqs_n_o    : out std_logic_vector(3 downto 0);
    lpddr_o_dq_oen     : out std_logic_vector(31 downto 0);
    lpddr_o_dq_o       : out std_logic_vector(31 downto 0);
    lpddr_i_dqs_p_i    : in  std_logic_vector(3 downto 0);
    lpddr_i_dqs_n_i    : in  std_logic_vector(3 downto 0);
    lpddr_i_dq_i       : in  std_logic_vector(31 downto 0);
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
    noc6_stop_out      : out std_logic_vector(3 downto 0));
end;


architecture rtl of asic_tile_slm_ddr is

  component ahb2bsg_dmc is
    port (
      hindex          : in  integer;
      haddr           : in  integer;
      hmask           : in  integer;
      lpddr_ck_p      : out std_logic;
      lpddr_ck_n      : out std_logic;
      lpddr_cke       : out std_logic;
      lpddr_ba        : out std_logic_vector(2 downto 0);
      lpddr_addr      : out std_logic_vector(15 downto 0);
      lpddr_cs_n      : out std_logic;
      lpddr_ras_n     : out std_logic;
      lpddr_cas_n     : out std_logic;
      lpddr_we_n      : out std_logic;
      lpddr_reset_n   : out std_logic;
      lpddr_odt       : out std_logic;
      lpddr_dm_oen    : out std_logic_vector(3 downto 0);
      lpddr_dm        : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_oen : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_ien : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_o   : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_i   : in  std_logic_vector(3 downto 0);
      lpddr_dqs_n_oen : out std_logic_vector(3 downto 0);
      lpddr_dqs_n_ien : out std_logic_vector(3 downto 0);
      lpddr_dqs_n_o   : out std_logic_vector(3 downto 0);
      lpddr_dqs_n_i   : in  std_logic_vector(3 downto 0);
      lpddr_dq_oen    : out std_logic_vector(31 downto 0);
      lpddr_dq_o      : out std_logic_vector(31 downto 0);
      lpddr_dq_i      : in  std_logic_vector(31 downto 0);
      ddr_cfg0        : in  std_logic_vector(31 downto 0);
      ddr_cfg1        : in  std_logic_vector(31 downto 0);
      ddr_cfg2        : in  std_logic_vector(31 downto 0);
      ahbso           : out ahb_slv_out_type;
      ahbsi           : in  ahb_slv_in_type;
      calib_done      : out std_logic;
      ui_clk          : in  std_logic;
      ui_rstn         : in  std_logic;
      phy_clk_1x      : in  std_logic;
      phy_clk_2x      : in  std_logic;
      phy_rstn        : in  std_logic);
  end component ahb2bsg_dmc;

  signal ddr_cfg0 : std_logic_vector(31 downto 0);
  signal ddr_cfg1 : std_logic_vector(31 downto 0);
  signal ddr_cfg2 : std_logic_vector(31 downto 0);

  signal ddr_ahbsi : ahb_slv_in_type;
  signal ddr_ahbso : ahb_slv_out_type;

  signal this_slmddr_id : integer range 0 to SLMDDR_ID_RANGE_MSB;
  signal this_slmddr_haddr  : integer range 0 to 4095;
  signal this_slmddr_hmask  : integer range 0 to 4095;

  constant ext_clk_sel_default : std_ulogic := '0';

  constant DEFAULT_DCO_LPDDR_CFG : std_logic_vector(22 downto 0) :=
    "0100"      &   "00"   &   "100"  & "000000" & "110010" &   "0"   & "1";
  -- UI_CLK_DEL   FREQ_SEL    DIV_SEL    FC_SEL     CC_SEL    CLK_SEL    EN

  -- Tile clock and reset (only for I/O tile)
  signal raw_rstn        : std_ulogic;
  signal dco_clk         : std_ulogic;
  signal dco_clk_div2    : std_ulogic;
  signal dco_clk_div2_90 : std_ulogic;
  signal dco_rstn        : std_ulogic;
  signal dco_clk_lock    : std_ulogic;

  signal phy_rstn, phy_raw_rstn : std_logic;

begin

  -- Tile main clock and reset
  rst_tile : rstgen                         -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, dco_clk_div2_90, dco_clk_lock, dco_rstn, raw_rstn);

  -- DDR PHY reset
  rst_ddr : rstgen                         -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, dco_clk_div2, dco_clk_lock, phy_rstn, phy_raw_rstn);

  -- DDR Controller address range
  this_slmddr_haddr    <= slmddr_haddr(this_slmddr_id);
  this_slmddr_hmask    <= slmddr_hmask(this_slmddr_id);


  -- DDR controller
  ahb2bsg_dmc_1 : ahb2bsg_dmc
    port map (
      hindex          => 0,
      haddr           => this_slmddr_haddr,
      hmask           => this_slmddr_hmask,
      lpddr_ck_p      => lpddr_o_ck_p,
      lpddr_ck_n      => lpddr_o_ck_n,
      lpddr_cke       => lpddr_o_cke,
      lpddr_ba        => lpddr_o_ba,
      lpddr_addr      => lpddr_o_addr,
      lpddr_cs_n      => lpddr_o_cs_n,
      lpddr_ras_n     => lpddr_o_ras_n,
      lpddr_cas_n     => lpddr_o_cas_n,
      lpddr_we_n      => lpddr_o_we_n,
      lpddr_reset_n   => lpddr_o_reset_n,
      lpddr_odt       => lpddr_o_odt,
      lpddr_dm_oen    => lpddr_o_dm_oen,
      lpddr_dm        => lpddr_o_dm,
      lpddr_dqs_p_oen => lpddr_o_dqs_p_oen,
      lpddr_dqs_p_ien => lpddr_o_dqs_p_ien,
      lpddr_dqs_p_o   => lpddr_o_dqs_p_o,
      lpddr_dqs_p_i   => lpddr_i_dqs_p_i,
      lpddr_dqs_n_oen => lpddr_o_dqs_n_oen,
      lpddr_dqs_n_ien => lpddr_o_dqs_n_ien,
      lpddr_dqs_n_o   => lpddr_o_dqs_n_o,
      lpddr_dqs_n_i   => lpddr_i_dqs_n_i,
      lpddr_dq_oen    => lpddr_o_dq_oen,
      lpddr_dq_o      => lpddr_o_dq_o,
      lpddr_dq_i      => lpddr_i_dq_i,
      ddr_cfg0        => ddr_cfg0,
      ddr_cfg1        => ddr_cfg1,
      ddr_cfg2        => ddr_cfg2,
      ahbso           => ddr_ahbso,
      ahbsi           => ddr_ahbsi,
      calib_done      => lpddr_o_calib_done,
      ui_clk          => dco_clk_div2_90,
      ui_rstn         => dco_rstn,
      phy_clk_1x      => dco_clk_div2,
      phy_clk_2x      => dco_clk,
      phy_rstn        => phy_rstn);

  tile_slm_1 : tile_slm
    generic map (
      this_has_dco => 1,
      test_if_en   => 1,
      this_has_ddr => 1,
      dco_rst_cfg  => DEFAULT_DCO_LPDDR_CFG,
      ROUTER_PORTS => ROUTER_PORTS,
      HAS_SYNC     => 1)
    port map (
      raw_rstn           => raw_rstn,   -- DCO raw reset
      rst                => dco_rstn,   -- tile main synchronouse reset
      clk                => dco_clk_div2_90,      -- tile main clock
      refclk             => ext_clk,    -- external backup clock
      pllbypass          => ext_clk_sel_default,  -- ext_clk_sel,
      pllclk             => clk_div,    -- test clock output to PCB
      dco_clk            => dco_clk,    -- DDR PHY 2x clock
      dco_clk_lock       => dco_clk_lock,
      dco_clk_div2       => dco_clk_div2,         -- DDR PHY 1x clock
      dco_clk_div2_90    => dco_clk_div2_90,      -- user clock
      ddr_ahbsi          => ddr_ahbsi,
      ddr_ahbso          => ddr_ahbso,
      ddr_cfg0           => ddr_cfg0,
      ddr_cfg1           => ddr_cfg1,
      ddr_cfg2           => ddr_cfg2,
      slmddr_id          => this_slmddr_id,
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
      mon_mem            => open,
      mon_dvfs           => open);

end;
