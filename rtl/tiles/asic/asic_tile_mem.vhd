-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
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
use work.coretypes.all;

use work.grlib_config.all;
use work.socmap.all;
use work.tiles_pkg.all;

entity asic_tile_mem is
  generic (
    ROUTER_PORTS : ports_vec := "11111");
  port (
    rst                : in  std_ulogic;
    sys_clk            : in  std_ulogic;  -- NoC clock
    ext_clk            : in  std_ulogic;  -- backup tile clock
    -- ext_clk_sel     : in  std_ulogic;  -- backup tile clock select ??(usign registers otherwise)
    clk_div            : out std_ulogic;  -- tile clock monitor for testing purposes
    -- FPGA proxy memory link
    fpga_data_in       : in  std_logic_vector(ARCH_BITS - 1 downto 0);
    fpga_data_out      : out std_logic_vector(ARCH_BITS - 1 downto 0);
    fpga_oen           : out std_ulogic;
    fpga_valid_in      : in  std_ulogic;
    fpga_valid_out     : out std_ulogic;
    fpga_clk_in        : in  std_ulogic;
    fpga_clk_out       : out std_ulogic;
    fpga_credit_in     : in  std_ulogic;
    fpga_credit_out    : out std_ulogic;
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


architecture rtl of asic_tile_mem is

  constant ext_clk_sel_default : std_ulogic := '0';

  -- Tile clock and reset (only for I/O tile)
  signal raw_rstn     : std_ulogic;
  signal dco_clk      : std_ulogic;
  signal dco_rstn     : std_ulogic;
  signal dco_clk_lock : std_ulogic;

begin

  rst1 : rstgen                         -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, dco_clk, dco_clk_lock, dco_rstn, raw_rstn);


  tile_mem_1: tile_mem
    generic map (
      this_has_dco => 1,
      test_if_en   => 1,
      this_has_ddr => 0,
      dco_rst_cfg  => (others => '0'),
      ROUTER_PORTS => ROUTER_PORTS,
      HAS_SYNC     => 1)
    port map (
      raw_rstn           => raw_rstn,
      rst                => dco_rstn,
      refclk             => ext_clk,
      clk                => dco_clk,
      pllbypass          => ext_clk_sel_default,  --ext_clk_sel,
      pllclk             => clk_div,
      dco_clk            => dco_clk,
      dco_clk_lock       => dco_clk_lock,
      dco_clk_div2       => open,
      dco_clk_div2_90    => open,
      ddr_ahbsi          => open,
      ddr_ahbso          => ahbs_none,
      ddr_cfg0           => open,
      ddr_cfg1           => open,
      ddr_cfg2           => open,
      mem_id             => open,
      fpga_data_in       => fpga_data_in,
      fpga_data_out      => fpga_data_out,
      fpga_oen           => fpga_oen,
      fpga_valid_in      => fpga_valid_in,
      fpga_valid_out     => fpga_valid_out,
      fpga_clk_in        => fpga_clk_in,
      fpga_clk_out       => fpga_clk_out,
      fpga_credit_in     => fpga_credit_in,
      fpga_credit_out    => fpga_credit_out,
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
      mon_cache          => open,
      mon_dvfs           => open);

end;
