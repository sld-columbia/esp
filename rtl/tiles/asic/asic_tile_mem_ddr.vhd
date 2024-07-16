-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
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
use work.esp_noc_csr_pkg.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.ahb2mig_7series_pkg.all;
use work.coretypes.all;

use work.grlib_config.all;
use work.socmap.all;
use work.tiles_pkg.all;

entity asic_tile_mem_ddr is
  generic (
    SIMULATION   : boolean   := false;
    ROUTER_PORTS : ports_vec := "11111";
    this_has_dco : integer range 0 to 1 := 1;
    HAS_SYNC     : integer range 0 to 1 := 1;
    ROUTER_PORTS : ports_vec := "11111");
  port (
    rst                : in  std_ulogic;
    raw_rstn           : in  std_ulogic;
    noc_rstn           : in  std_ulogic;
    tile_rstn          : out std_ulogic;  
    tile_clk           : out std_ulogic;
    ext_clk            : in  std_ulogic;  -- backup tile clock
    clk_div            : out std_ulogic;  -- tile clock monitor for testing purposes
    -- LPDDR
    lpddr_o            : out lpddr_out_t;
    lpddr_i            : in  lpddr_in_t;
    -- Test interface
    tdi                : in  std_logic;
    tdo                : out std_logic;
    tms                : in  std_logic;
    tclk               : in  std_logic;
    -- DCO config
    dco_en            : in std_ulogic;
    dco_clk_sel       : in std_ulogic;
    dco_cc_sel        : in std_logic_vector(5 downto 0);
    dco_fc_sel        : in std_logic_vector(5 downto 0);
    dco_div_sel       : in std_logic_vector(2 downto 0);
    dco_freq_sel      : in std_logic_vector(1 downto 0);
    dco_clk_delay_sel : in std_logic_vector(11 downto 0);
    -- NoC interface
    noc1_stop_in_tile       : out std_ulogic;
    noc1_stop_out_tile      : in  std_ulogic;
    noc1_data_void_in_tile  : out std_ulogic;
    noc1_data_void_out_tile : in  std_ulogic;
    noc2_stop_in_tile       : out std_ulogic;
    noc2_stop_out_tile      : in  std_ulogic;
    noc2_data_void_in_tile  : out std_ulogic;
    noc2_data_void_out_tile : in  std_ulogic;
    noc3_stop_in_tile       : out std_ulogic;
    noc3_stop_out_tile      : in  std_ulogic;
    noc3_data_void_in_tile  : out std_ulogic;
    noc3_data_void_out_tile : in  std_ulogic;
    noc4_stop_in_tile       : out std_ulogic;
    noc4_stop_out_tile      : in  std_ulogic;
    noc4_data_void_in_tile  : out std_ulogic;
    noc4_data_void_out_tile : in  std_ulogic;
    noc5_stop_in_tile       : out std_ulogic;
    noc5_stop_out_tile      : in  std_ulogic;
    noc5_data_void_in_tile  : out std_ulogic;
    noc5_data_void_out_tile : in  std_ulogic;
    noc6_stop_in_tile       : out std_ulogic;
    noc6_stop_out_tile      : in  std_ulogic;
    noc6_data_void_in_tile  : out std_ulogic;
    noc6_data_void_out_tile : in  std_ulogic;
    noc1_input_port_tile    : out coh_noc_flit_type;
    noc2_input_port_tile    : out coh_noc_flit_type;
    noc3_input_port_tile    : out coh_noc_flit_type;
    noc4_input_port_tile    : out dma_noc_flit_type;
    noc5_input_port_tile    : out misc_noc_flit_type;
    noc6_input_port_tile    : out dma_noc_flit_type;
    noc1_output_port_tile   : in  coh_noc_flit_type;
    noc2_output_port_tile   : in  coh_noc_flit_type;
    noc3_output_port_tile   : in  coh_noc_flit_type;
    noc4_output_port_tile   : in  dma_noc_flit_type;
    noc5_output_port_tile   : in  misc_noc_flit_type;
    noc6_output_port_tile   : in  dma_noc_flit_type;
    -- NoC monitors
    mon_noc                 : in  monitor_noc_vector(1 to 6));
end;


architecture rtl of asic_tile_mem_ddr is

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

  signal ddr_cfg0_s : std_logic_vector(31 downto 0);
  signal ddr_cfg1_s : std_logic_vector(31 downto 0);
  signal ddr_cfg1_s : std_logic_vector(31 downto 0);

  signal tile_id_s : std_logic_vector(CFG_TILES_NUM - 1 downto 0);
  signal tile_id   : integer range 0 to CFG_TILES_NUM - 1;
  signal mem_id    : integer range 0 to CFG_NDDR_TILE - 1;

  -- Tile clock and reset (only for I/O tile)
  signal tile_rstn_s  : std_ulogic;
  signal tile_rst     : std_ulogic;
  signal tile_clk_s      : std_ulogic;

  signal phy_rstn, phy_raw_rstn : std_logic;

  -- Tile NoC interface
  signal test_rstn             : std_ulogic;
  signal test1_output_port_s   : coh_noc_flit_type;
  signal test1_data_void_out_s : std_ulogic;
  signal test1_stop_in_s       : std_ulogic;
  signal test2_output_port_s   : coh_noc_flit_type;
  signal test2_data_void_out_s : std_ulogic;
  signal test2_stop_in_s       : std_ulogic;
  signal test3_output_port_s   : coh_noc_flit_type;
  signal test3_data_void_out_s : std_ulogic;
  signal test3_stop_in_s       : std_ulogic;
  signal test4_output_port_s   : dma_noc_flit_type;
  signal test4_data_void_out_s : std_ulogic;
  signal test4_stop_in_s       : std_ulogic;
  signal test5_output_port_s   : misc_noc_flit_type;
  signal test5_data_void_out_s : std_ulogic;
  signal test5_stop_in_s       : std_ulogic;
  signal test6_output_port_s   : dma_noc_flit_type;
  signal test6_data_void_out_s : std_ulogic;
  signal test6_stop_in_s       : std_ulogic;
  signal test1_input_port_s    : coh_noc_flit_type;
  signal test1_data_void_in_s  : std_ulogic;
  signal test1_stop_out_s      : std_ulogic;
  signal test2_input_port_s    : coh_noc_flit_type;
  signal test2_data_void_in_s  : std_ulogic;
  signal test2_stop_out_s      : std_ulogic;
  signal test3_input_port_s    : coh_noc_flit_type;
  signal test3_data_void_in_s  : std_ulogic;
  signal test3_stop_out_s      : std_ulogic;
  signal test4_input_port_s    : dma_noc_flit_type;
  signal test4_data_void_in_s  : std_ulogic;
  signal test4_stop_out_s      : std_ulogic;
  signal test5_input_port_s    : misc_noc_flit_type;
  signal test5_data_void_in_s  : std_ulogic;
  signal test5_stop_out_s      : std_ulogic;
  signal test6_input_port_s    : dma_noc_flit_type;
  signal test6_data_void_in_s  : std_ulogic;
  signal test6_stop_out_s      : std_ulogic;

begin


  rst_jtag : rstgen
    generic map (acthigh => 1, syncin => 0)
    port map (rst, tclk, '1', test_rstn, open);

  has_dco_rst : if this_has_dco = 1 generate
    tile_rst <= rst;
  end generate has_dco_rst;

  no_dco_rst : if this_has_dco /= 1 generate
    tile_rst <= noc_rstn;
  end generate no_dco_rst;

  tile_rstn <= tile_rstn_s;
  tile_clk  <= tile_clk_s;

  -- DDR controller
  ahb2bsg_dmc_1 : ahb2bsg_dmc
    port map (
      hindex          => ddr_hindex(mem_id),
      haddr           => ddr_haddr(mem_id),
      hmask           => ddr_hmask(mem_id),
      lpddr_ck_p      => lpddr_o.lpddr_ck_p,
      lpddr_ck_n      => lpddr_o.lpddr_ck_n,
      lpddr_cke       => lpddr_o.lpddr_cke,
      lpddr_ba        => lpddr_o.lpddr_ba,
      lpddr_addr      => lpddr_o.lpddr_addr,
      lpddr_cs_n      => lpddr_o.lpddr_cs_n,
      lpddr_ras_n     => lpddr_o.lpddr_ras_n,
      lpddr_cas_n     => lpddr_o.lpddr_cas_n,
      lpddr_we_n      => lpddr_o.lpddr_we_n,
      lpddr_reset_n   => lpddr_o.lpddr_reset_n,
      lpddr_odt       => lpddr_o.lpddr_odt,
      lpddr_dm_oen    => lpddr_o.lpddr_dm_oen,
      lpddr_dm        => lpddr_o.lpddr_dm,
      lpddr_dqs_p_oen => lpddr_o.lpddr_dqs_p_oen,
      lpddr_dqs_p_ien => lpddr_o.lpddr_dqs_p_ien,
      lpddr_dqs_p_o   => lpddr_o.lpddr_dqs_p_o,
      lpddr_dqs_p_i   => lpddr_i.lpddr_dqs_p_i,
      lpddr_dqs_n_oen => lpddr_o.lpddr_dqs_n_oen,
      lpddr_dqs_n_ien => lpddr_o.lpddr_dqs_n_ien,
      lpddr_dqs_n_o   => lpddr_o.lpddr_dqs_n_o,
      lpddr_dqs_n_i   => lpddr_i.lpddr_dqs_n_i,
      lpddr_dq_oen    => lpddr_o.lpddr_dq_oen,
      lpddr_dq_o      => lpddr_o.lpddr_dq_o,
      lpddr_dq_i      => lpddr_i.lpddr_dq_i,
      ddr_cfg0        => ddr_cfg0_s,
      ddr_cfg1        => ddr_cfg1_s,
      ddr_cfg2        => ddr_cfg2_s, 
      ahbso           => ahbso,
      ahbsi           => ahbsi,
      calib_done      => calib_done,
      ui_clk          => dco_clk_div2_90,
      ui_rstn         => tile_rstn_s,
      phy_clk_1x      => dco_clk_div2,
      phy_clk_2x      => tile_clk_s,
      phy_rstn        => phy_rstn);

  -----------------------------------------------------------------------------
  -- JTAG for single tile testing / bypass when test_if_en = 0
  -----------------------------------------------------------------------------
  jtag_test_i : jtag_test
    generic map (
      test_if_en => CFG_JTAG_EN)
    port map (
      rstn                => test_rstn,
      clk                 => tile_clk_s,
      tile_rstn           => tile_rstn_s,
      tdi                 => tdi,
      tdo                 => tdo,
      tms                 => tms,
      tclk                => tclk,
      noc1_output_port    => noc1_output_port_tile,
      noc1_data_void_out  => noc1_data_void_out_tile,
      noc1_stop_in        => noc1_stop_in_tile,
      noc2_output_port    => noc2_output_port_tile,
      noc2_data_void_out  => noc2_data_void_out_tile,
      noc2_stop_in        => noc2_stop_in_tile,
      noc3_output_port    => noc3_output_port_tile,
      noc3_data_void_out  => noc3_data_void_out_tile,
      noc3_stop_in        => noc3_stop_in_tile,
      noc4_output_port    => noc4_output_port_tile,
      noc4_data_void_out  => noc4_data_void_out_tile,
      noc4_stop_in        => noc4_stop_in_tile,
      noc5_output_port    => noc5_output_port_tile,
      noc5_data_void_out  => noc5_data_void_out_tile,
      noc5_stop_in        => noc5_stop_in_tile,
      noc6_output_port    => noc6_output_port_tile,
      noc6_data_void_out  => noc6_data_void_out_tile,
      noc6_stop_in        => noc6_stop_in_tile,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_in_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_out_s,
      noc1_input_port     => noc1_input_port_tile,
      noc1_data_void_in   => noc1_data_void_in_tile,
      noc1_stop_out       => noc1_stop_out_tile,
      noc2_input_port     => noc2_input_port_tile,
      noc2_data_void_in   => noc2_data_void_in_tile,
      noc2_stop_out       => noc2_stop_out_tile,
      noc3_input_port     => noc3_input_port_tile,
      noc3_data_void_in   => noc3_data_void_in_tile,
      noc3_stop_out       => noc3_stop_out_tile,
      noc4_input_port     => noc4_input_port_tile,
      noc4_data_void_in   => noc4_data_void_in_tile,
      noc4_stop_out       => noc4_stop_out_tile,
      noc5_input_port     => noc5_input_port_tile,
      noc5_data_void_in   => noc5_data_void_in_tile,
      noc5_stop_out       => noc5_stop_out_tile,
      noc6_input_port     => noc6_input_port_tile,
      noc6_data_void_in   => noc6_data_void_in_tile,
      noc6_stop_out       => noc6_stop_out_tile);

  tile_mem_1 : tile_mem
    generic map (
      SIMULATION   => SIMULATION,
      this_has_dco => this_has_dco,
      this_has_ddr => 1)
    port map (
      raw_rstn            => raw_rstn,   -- DCO raw reset
      tile_rst            => tile_rst,   -- tile main synchronouse reset
      ext_clk             => ext_clk,    -- external backup clock
      clk_div             => clk_div,    -- test clock output to PCB
      tile_clk_out        => tile_clk_s,    -- DDR PHY 2x clock
      tile_rstn_out       => tile_rstn_s,
      phy_rstn            => phy_rstn,
      dco_clk_div2        => dco_clk_div2,         -- DDR PHY 1x clock
      dco_clk_div2_90     => dco_clk_div2_90,      -- user clock
      dco_freq_sel        => dco_freq_sel,
      dco_div_sel         => dco_div_sel,
      dco_fc_sel          => dco_fc_sel,
      dco_cc_sel          => dco_cc_sel,
      dco_clk_sel         => dco_clk_sel,
      dco_en              => dco_en,
      ddr_ahbsi           => ddr_ahbsi,
      ddr_ahbso           => ddr_ahbso,
      fpga_data_in        => (others => '0'),
      fpga_data_out       => open,
      fpga_oen            => open,
      fpga_valid_in       => '0',
      fpga_valid_out      => open,
      fpga_clk_in         => '0',
      fpga_clk_out        => open,
      fpga_credit_in      => '0',
      fpga_credit_out     => open,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_out_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_in_s,
      mon_mem             => open,
      mon_cache           => open,
      mon_dvfs            => open);

  -- IDs
  tile_id <= to_integer(unsigned(tile_id_s));
  mem_id  <= tile_mem_id(tile_id);

end;
