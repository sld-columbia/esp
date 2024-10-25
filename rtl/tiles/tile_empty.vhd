-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  EMPTY tile
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
use work.ariane_esp_pkg.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity tile_empty is
  generic (
    SIMULATION   : boolean              := false;
    this_has_dco : integer range 0 to 2 := 0);
  port (
    raw_rstn           : in  std_ulogic;
    tile_rst           : in  std_logic;
    ext_clk            : in  std_ulogic;
    clk_div            : out std_ulogic;
    tile_clk_out       : out std_ulogic;
    tile_rstn_out          : out std_ulogic;
    -- DCO config
    dco_freq_sel       : in std_logic_vector(1 downto 0);
    dco_div_sel        : in std_logic_vector(2 downto 0);
    dco_fc_sel         : in std_logic_vector(5 downto 0);
    dco_cc_sel         : in std_logic_vector(5 downto 0);
    dco_clk_sel        : in std_ulogic;
    dco_en             : in std_ulogic;
    -- NoC
    test1_output_port   : in coh_noc_flit_type;
    test1_data_void_out : in std_ulogic;
    test1_stop_in       : in std_ulogic;
    test2_output_port   : in coh_noc_flit_type;
    test2_data_void_out : in std_ulogic;
    test2_stop_in       : in std_ulogic;
    test3_output_port   : in coh_noc_flit_type;
    test3_data_void_out : in std_ulogic;
    test3_stop_in       : in std_ulogic;
    test4_output_port   : in dma_noc_flit_type;
    test4_data_void_out : in std_ulogic;
    test4_stop_in       : in std_ulogic;
    test5_output_port   : in misc_noc_flit_type;
    test5_data_void_out : in std_ulogic;
    test5_stop_in       : in std_ulogic;
    test6_output_port   : in dma_noc_flit_type;
    test6_data_void_out : in std_ulogic;
    test6_stop_in       : in std_ulogic;
    test1_input_port    : out coh_noc_flit_type;
    test1_data_void_in  : out std_ulogic;
    test1_stop_out      : out std_ulogic;
    test2_input_port    : out coh_noc_flit_type;
    test2_data_void_in  : out std_ulogic;
    test2_stop_out      : out std_ulogic;
    test3_input_port    : out coh_noc_flit_type;
    test3_data_void_in  : out std_ulogic;
    test3_stop_out      : out std_ulogic;
    test4_input_port    : out dma_noc_flit_type;
    test4_data_void_in  : out std_ulogic;
    test4_stop_out      : out std_ulogic;
    test5_input_port    : out misc_noc_flit_type;
    test5_data_void_in  : out std_ulogic;
    test5_stop_out      : out std_ulogic;
    test6_input_port    : out dma_noc_flit_type;
    test6_data_void_in  : out std_ulogic;
    test6_stop_out      : out std_ulogic;
    mon_noc             : in  monitor_noc_vector(1 to 6);
    mon_dvfs_out        : out monitor_dvfs_type);

end;

architecture rtl of tile_empty is

  -- Tile synchronous reset
  signal rst : std_ulogic;

  -- DCO
  signal dco_clk_lock : std_ulogic;
  signal dco_clk      : std_ulogic;
  signal tile_clk     : std_ulogic;
  signal dco_en_int   : std_ulogic;

  -- Queues
  signal apb_rcv_rdreq    : std_ulogic;
  signal apb_rcv_data_out : misc_noc_flit_type;
  signal apb_rcv_empty    : std_ulogic;
  signal apb_snd_wrreq    : std_ulogic;
  signal apb_snd_data_in  : misc_noc_flit_type;
  signal apb_snd_full     : std_ulogic;

  -- Bus
  signal apbi           : apb_slv_in_type;
  signal apbo           : apb_slv_out_vector;

  -- Mon
  signal mon_dvfs_int         : monitor_dvfs_type;

  attribute keep              : string;

  -- Tile parameters
  signal tile_config : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);

  signal tile_id : integer range 0 to CFG_TILES_NUM - 1;

  signal this_csr_pindex        : integer range 0 to NAPBSLV - 1;
  signal this_csr_pconfig       : apb_config_type;

  signal this_local_y : local_yx;
  signal this_local_x : local_yx;

  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := (
    0 => '1',                           -- CSRs
    others => '0');

begin

  -- DCO Reset synchronizer
  rst_gen: if this_has_dco = 1 generate
    tile_rstn_out : rstgen
      generic map (acthigh => 1, syncin => 0)
      port map (tile_rst, dco_clk, dco_clk_lock, rst, open);
  end generate rst_gen;

  no_rst_gen: if this_has_dco /= 1 generate
    rst <= tile_rst;
  end generate no_rst_gen;

  tile_rstn_out <= rst;

  -- DCO
  dco_en_int <= dco_en and raw_rstn;

  dco_gen: if this_has_dco = 1 generate

    dco_i: dco
      generic map (
        tech => CFG_FABTECH,
        enable_div2 => 0,
        dlog => 9)                      -- come out of reset after NoC, but
                                        -- before tile_io.
      port map (
        rstn     => raw_rstn,
        ext_clk  => ext_clk,
        en       => dco_en_int,
        clk_sel  => dco_clk_sel,
        cc_sel   => dco_cc_sel,
        fc_sel   => dco_fc_sel,
        div_sel  => dco_div_sel,
        freq_sel => dco_freq_sel,
        clk      => dco_clk,
        clk_div  => clk_div,
        lock     => dco_clk_lock);

    tile_clk <= dco_clk;
  end generate dco_gen;

  no_dco_gen: if this_has_dco /= 1 generate
    clk_div       <= '0';
    tile_clk  <= ext_clk;
    dco_clk_lock <= '1';
  end generate no_dco_gen;

  tile_clk_out <= tile_clk;

  -----------------------------------------------------------------------------
  -- Tile parameters
  -----------------------------------------------------------------------------
  tile_id                <= to_integer(unsigned(tile_config(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB)));

  this_csr_pindex        <= tile_csr_pindex(tile_id);
  this_csr_pconfig       <= fixed_apbo_pconfig(this_csr_pindex);

  this_local_y           <= tile_y(tile_id);
  this_local_x           <= tile_x(tile_id);

  -----------------------------------------------------------------------------
  -- Buse
  -----------------------------------------------------------------------------
  -- Unused APB ports
  no_apb : for i in 0 to NAPBSLV - 1 generate
    local_apb : if this_local_apb_en(i) = '0' generate
      apbo(i)      <= apb_none;
      apbo(i).pirq <= (others => '0');
    end generate local_apb;
  end generate no_apb;

  -----------------------------------------------------------------------------
  -- Services
  -----------------------------------------------------------------------------

  -- APB
  noc2apb_1 : noc2apb
    generic map (
      tech         => CFG_FABTECH,
      local_apb_en => this_local_apb_en)
    port map (
      rst              => rst,
      clk              => tile_clk,
      local_y          => this_local_y,
      local_x          => this_local_x,
      apbi             => apbi,
      apbo             => apbo,
      pready           => '1',
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty);

  --Monitors
  mon_dvfs_int.vf        <= (others => '0');
  mon_dvfs_int.clk       <= tile_clk;
  mon_dvfs_int.acc_idle  <= '0';
  mon_dvfs_int.traffic   <= '0';
  mon_dvfs_int.burst     <= '0';
  mon_dvfs_int.transient <= '0';
  mon_dvfs_out           <= mon_dvfs_int;

  --Memory mapped registers
 empty_tile_csr : esp_tile_csr
    generic map(
      pindex => 0)
   port map(
     clk => tile_clk,
     rstn => rst,
     pconfig => this_csr_pconfig,
     mon_ddr => monitor_ddr_none,
     mon_mem => monitor_mem_none,
     mon_noc => mon_noc,
     mon_l2 => monitor_cache_none,
     mon_llc => monitor_cache_none,
     mon_acc => monitor_acc_none,
     mon_dvfs => mon_dvfs_int,
     tile_config => tile_config,
     srst => open,
     tp_acc_rst => open,
     apbi => apbi,
     apbo => apbo(0)
   );


  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  empty_tile_q_1 : empty_tile_q
    generic map (
      tech => CFG_FABTECH)
    port map (
      rst                        => rst,
      clk                        => tile_clk,
      apb_snd_wrreq              => apb_snd_wrreq,
      apb_snd_data_in            => apb_snd_data_in,
      apb_snd_full               => apb_snd_full,
      apb_rcv_rdreq              => apb_rcv_rdreq,
      apb_rcv_data_out           => apb_rcv_data_out,
      apb_rcv_empty              => apb_rcv_empty,
      noc1_out_data              => test1_output_port,
      noc1_out_void              => test1_data_void_out,
      noc1_out_stop              => test1_stop_out,
      noc1_in_data               => test1_input_port,
      noc1_in_void               => test1_data_void_in,
      noc1_in_stop               => test1_stop_in,
      noc2_out_data              => test2_output_port,
      noc2_out_void              => test2_data_void_out,
      noc2_out_stop              => test2_stop_out,
      noc2_in_data               => test2_input_port,
      noc2_in_void               => test2_data_void_in,
      noc2_in_stop               => test2_stop_in,
      noc3_out_data              => test3_output_port,
      noc3_out_void              => test3_data_void_out,
      noc3_out_stop              => test3_stop_out,
      noc3_in_data               => test3_input_port,
      noc3_in_void               => test3_data_void_in,
      noc3_in_stop               => test3_stop_in,
      noc4_out_data              => test4_output_port,
      noc4_out_void              => test4_data_void_out,
      noc4_out_stop              => test4_stop_out,
      noc4_in_data               => test4_input_port,
      noc4_in_void               => test4_data_void_in,
      noc4_in_stop               => test4_stop_in,
      noc5_out_data              => test5_output_port,
      noc5_out_void              => test5_data_void_out,
      noc5_out_stop              => test5_stop_out,
      noc5_in_data               => test5_input_port,
      noc5_in_void               => test5_data_void_in,
      noc5_in_stop               => test5_stop_in,
      noc6_out_data              => test6_output_port,
      noc6_out_void              => test6_data_void_out,
      noc6_out_stop              => test6_stop_out,
      noc6_in_data               => test6_input_port,
      noc6_in_void               => test6_data_void_in,
      noc6_in_stop               => test6_stop_in);

end;
