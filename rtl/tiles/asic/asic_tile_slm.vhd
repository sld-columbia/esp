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
use work.coretypes.all;

use work.grlib_config.all;
use work.socmap.all;
use work.tiles_pkg.all;

entity asic_tile_slm is
  generic (
    SIMULATION   : boolean := false;
    HAS_SYNC     : integer range 0 to 1 := 1;
    ROUTER_PORTS : ports_vec := "11111";
    this_has_dco : integer range 0 to 2 := 1);
  port (
    rst                : in  std_ulogic;
    raw_rstn           : in  std_ulogic;
    noc_rstn           : in  std_ulogic;
    tile_rstn          : out std_ulogic;  
    tile_clk           : out std_ulogic;
    ext_clk            : in  std_ulogic;  -- backup tile clock
    clk_div            : out std_ulogic;  -- tile clock monitor for testing purposes
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
    mon_noc                 : in monitor_noc_vector(1 to 6));
end;


architecture rtl of asic_tile_slm is

  -- Tile clock and reset (only for I/O tile)
  signal tile_rstn_s    : std_ulogic;
  signal tile_rst     : std_ulogic;
  signal tile_clk_s     : std_ulogic;

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

  tile_slm_1 : tile_slm
    generic map (
      SIMULATION   => SIMULATION,
      this_has_dco => this_has_dco,
      this_has_ddr => 0)
    port map (
      raw_rstn            => raw_rstn,
      tile_rst            => tile_rst,
      ext_clk             => ext_clk,
      clk_div             => clk_div,
      tile_clk_out        => tile_clk_s,
      tile_id_out         => open,
      dco_clk_div2        => open,
      dco_clk_div2_90     => open,
      tile_rstn_out       => tile_rstn_s,
      phy_rstn            => open,
      dco_freq_sel        => dco_freq_sel,
      dco_div_sel         => dco_div_sel,
      dco_fc_sel          => dco_fc_sel,
      dco_cc_sel          => dco_cc_sel,
      dco_clk_sel         => dco_clk_sel,
      dco_en              => dco_en,
      dco_clk_delay_sel   => dco_clk_delay_sel,
      ddr_ahbsi           => open,
      ddr_ahbso           => ahbs_none,
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
      mon_noc             => mon_noc,
      mon_mem             => open,
      mon_dvfs            => open);


end;
