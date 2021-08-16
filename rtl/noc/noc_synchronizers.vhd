-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.nocpackage.all;

entity noc_synchronizers is
  port (
    noc_rstn  : in std_ulogic;
    tile_rstn : in std_ulogic;
    noc_clk   : in std_ulogic;
    tile_clk  : in std_ulogic;

    -- NoC out to synchronizers
    noc1_output_port   : in  noc_flit_type;
    noc1_data_void_out : in  std_ulogic;
    noc1_stop_in       : out std_ulogic;
    noc2_output_port   : in  noc_flit_type;
    noc2_data_void_out : in  std_ulogic;
    noc2_stop_in       : out std_ulogic;
    noc3_output_port   : in  noc_flit_type;
    noc3_data_void_out : in  std_ulogic;
    noc3_stop_in       : out std_ulogic;
    noc4_output_port   : in  noc_flit_type;
    noc4_data_void_out : in  std_ulogic;
    noc4_stop_in       : out std_ulogic;
    noc5_output_port   : in  misc_noc_flit_type;
    noc5_data_void_out : in  std_ulogic;
    noc5_stop_in       : out std_ulogic;
    noc6_output_port   : in  noc_flit_type;
    noc6_data_void_out : in  std_ulogic;
    noc6_stop_in       : out std_ulogic;

    -- synchronizers to NoC in
    noc1_input_port   : out noc_flit_type;
    noc1_data_void_in : out std_ulogic;
    noc1_stop_out     : in  std_ulogic;
    noc2_input_port   : out noc_flit_type;
    noc2_data_void_in : out std_ulogic;
    noc2_stop_out     : in  std_ulogic;
    noc3_input_port   : out noc_flit_type;
    noc3_data_void_in : out std_ulogic;
    noc3_stop_out     : in  std_ulogic;
    noc4_input_port   : out noc_flit_type;
    noc4_data_void_in : out std_ulogic;
    noc4_stop_out     : in  std_ulogic;
    noc5_input_port   : out misc_noc_flit_type;
    noc5_data_void_in : out std_ulogic;
    noc5_stop_out     : in  std_ulogic;
    noc6_input_port   : out noc_flit_type;
    noc6_data_void_in : out std_ulogic;
    noc6_stop_out     : in  std_ulogic;

    -- synchronizers out to tile
    noc1_output_port_tile   : out noc_flit_type;
    noc1_data_void_out_tile : out std_ulogic;
    noc1_stop_in_tile       : in  std_ulogic;
    noc2_output_port_tile   : out noc_flit_type;
    noc2_data_void_out_tile : out std_ulogic;
    noc2_stop_in_tile       : in  std_ulogic;
    noc3_output_port_tile   : out noc_flit_type;
    noc3_data_void_out_tile : out std_ulogic;
    noc3_stop_in_tile       : in  std_ulogic;
    noc4_output_port_tile   : out noc_flit_type;
    noc4_data_void_out_tile : out std_ulogic;
    noc4_stop_in_tile       : in  std_ulogic;
    noc5_output_port_tile   : out misc_noc_flit_type;
    noc5_data_void_out_tile : out std_ulogic;
    noc5_stop_in_tile       : in  std_ulogic;
    noc6_output_port_tile   : out noc_flit_type;
    noc6_data_void_out_tile : out std_ulogic;
    noc6_stop_in_tile       : in  std_ulogic;

    -- tile to synchronizers in
    noc1_input_port_tile   : in  noc_flit_type;
    noc1_data_void_in_tile : in  std_ulogic;
    noc1_stop_out_tile     : out std_ulogic;
    noc2_input_port_tile   : in  noc_flit_type;
    noc2_data_void_in_tile : in  std_ulogic;
    noc2_stop_out_tile     : out std_ulogic;
    noc3_input_port_tile   : in  noc_flit_type;
    noc3_data_void_in_tile : in  std_ulogic;
    noc3_stop_out_tile     : out std_ulogic;
    noc4_input_port_tile   : in  noc_flit_type;
    noc4_data_void_in_tile : in  std_ulogic;
    noc4_stop_out_tile     : out std_ulogic;
    noc5_input_port_tile   : in  misc_noc_flit_type;
    noc5_data_void_in_tile : in  std_ulogic;
    noc5_stop_out_tile     : out std_ulogic;
    noc6_input_port_tile   : in  noc_flit_type;
    noc6_data_void_in_tile : in  std_ulogic;
    noc6_stop_out_tile     : out std_ulogic);

end entity noc_synchronizers;

architecture rtl of noc_synchronizers is

  constant this_noc_planes : natural range 1 to 6 := 6;

  signal fwd_rd_i, fwd_we_i : std_logic_vector(this_noc_planes - 1 downto 0);
  signal rev_rd_i, rev_we_i : std_logic_vector(this_noc_planes - 1 downto 0);
  signal fwd_rd_empty_o     : std_logic_vector(this_noc_planes - 1 downto 0);
  signal fwd_wr_full_o      : std_logic_vector(this_noc_planes - 1 downto 0);
  signal rev_rd_empty_o     : std_logic_vector(this_noc_planes - 1 downto 0);
  signal rev_wr_full_o      : std_logic_vector(this_noc_planes - 1 downto 0);

begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- NoC plane 1
  -----------------------------------------------------------------------------

  rev_we_i(0)             <= not noc1_data_void_out;
  noc1_stop_in            <= rev_wr_full_o(0) when noc1_data_void_out = '0' else '0';
  rev_rd_i(0)             <= not noc1_stop_in_tile;
  noc1_data_void_out_tile <= rev_rd_empty_o(0);
  sync_noc1_out : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => noc_rstn,
      clk_wr_i   => noc_clk,
      we_i       => rev_we_i(0),
      d_i        => noc1_output_port,
      wr_full_o  => rev_wr_full_o(0),
      rst_rd_n_i => tile_rstn,
      clk_rd_i   => tile_clk,
      rd_i       => rev_rd_i(0),
      q_o        => noc1_output_port_tile,
      rd_empty_o => rev_rd_empty_o(0));

  fwd_we_i(0)        <= not noc1_data_void_in_tile;
  noc1_stop_out_tile <= fwd_wr_full_o(0);
  fwd_rd_i(0)        <= not noc1_stop_out;
  noc1_data_void_in  <= fwd_rd_empty_o(0) when noc1_stop_out = '0' else '1';
  sync_noc1_in : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => tile_rstn,
      clk_wr_i   => tile_clk,
      we_i       => fwd_we_i(0),
      d_i        => noc1_input_port_tile,
      wr_full_o  => fwd_wr_full_o(0),
      rst_rd_n_i => noc_rstn,
      clk_rd_i   => noc_clk,
      rd_i       => fwd_rd_i(0),
      q_o        => noc1_input_port,
      rd_empty_o => fwd_rd_empty_o(0));

  -----------------------------------------------------------------------------
  -- NoC plane 2
  -----------------------------------------------------------------------------

  rev_we_i(1)             <= not noc2_data_void_out;
  noc2_stop_in            <= rev_wr_full_o(1) when noc2_data_void_out = '0' else '0';
  rev_rd_i(1)             <= not noc2_stop_in_tile;
  noc2_data_void_out_tile <= rev_rd_empty_o(1);
  sync_noc2_out : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => noc_rstn,
      clk_wr_i   => noc_clk,
      we_i       => rev_we_i(1),
      d_i        => noc2_output_port,
      wr_full_o  => rev_wr_full_o(1),
      rst_rd_n_i => tile_rstn,
      clk_rd_i   => tile_clk,
      rd_i       => rev_rd_i(1),
      q_o        => noc2_output_port_tile,
      rd_empty_o => rev_rd_empty_o(1));

  fwd_we_i(1)        <= not noc2_data_void_in_tile;
  noc2_stop_out_tile <= fwd_wr_full_o(1);
  fwd_rd_i(1)        <= not noc2_stop_out;
  noc2_data_void_in  <= fwd_rd_empty_o(1) when noc2_stop_out = '0' else '1';
  sync_noc2_in : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => tile_rstn,
      clk_wr_i   => tile_clk,
      we_i       => fwd_we_i(1),
      d_i        => noc2_input_port_tile,
      wr_full_o  => fwd_wr_full_o(1),
      rst_rd_n_i => noc_rstn,
      clk_rd_i   => noc_clk,
      rd_i       => fwd_rd_i(1),
      q_o        => noc2_input_port,
      rd_empty_o => fwd_rd_empty_o(1));

  -----------------------------------------------------------------------------
  -- NoC plane 3
  -----------------------------------------------------------------------------

  rev_we_i(2)             <= not noc3_data_void_out;
  noc3_stop_in            <= rev_wr_full_o(2) when noc3_data_void_out = '0' else '0';
  rev_rd_i(2)             <= not noc3_stop_in_tile;
  noc3_data_void_out_tile <= rev_rd_empty_o(2);
  sync_noc3_out : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => noc_rstn,
      clk_wr_i   => noc_clk,
      we_i       => rev_we_i(2),
      d_i        => noc3_output_port,
      wr_full_o  => rev_wr_full_o(2),
      rst_rd_n_i => tile_rstn,
      clk_rd_i   => tile_clk,
      rd_i       => rev_rd_i(2),
      q_o        => noc3_output_port_tile,
      rd_empty_o => rev_rd_empty_o(2));

  fwd_we_i(2)        <= not noc3_data_void_in_tile;
  noc3_stop_out_tile <= fwd_wr_full_o(2);
  fwd_rd_i(2)        <= not noc3_stop_out;
  noc3_data_void_in  <= fwd_rd_empty_o(2) when noc3_stop_out = '0' else '1';
  sync_noc3_in : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => tile_rstn,
      clk_wr_i   => tile_clk,
      we_i       => fwd_we_i(2),
      d_i        => noc3_input_port_tile,
      wr_full_o  => fwd_wr_full_o(2),
      rst_rd_n_i => noc_rstn,
      clk_rd_i   => noc_clk,
      rd_i       => fwd_rd_i(2),
      q_o        => noc3_input_port,
      rd_empty_o => fwd_rd_empty_o(2));

  -----------------------------------------------------------------------------
  -- NoC plane 4
  -----------------------------------------------------------------------------

  rev_we_i(3)             <= not noc4_data_void_out;
  noc4_stop_in            <= rev_wr_full_o(3) when noc4_data_void_out = '0' else '0';
  rev_rd_i(3)             <= not noc4_stop_in_tile;
  noc4_data_void_out_tile <= rev_rd_empty_o(3);
  sync_noc4_out : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => noc_rstn,
      clk_wr_i   => noc_clk,
      we_i       => rev_we_i(3),
      d_i        => noc4_output_port,
      wr_full_o  => rev_wr_full_o(3),
      rst_rd_n_i => tile_rstn,
      clk_rd_i   => tile_clk,
      rd_i       => rev_rd_i(3),
      q_o        => noc4_output_port_tile,
      rd_empty_o => rev_rd_empty_o(3));

  fwd_we_i(3)        <= not noc4_data_void_in_tile;
  noc4_stop_out_tile <= fwd_wr_full_o(3);
  fwd_rd_i(3)        <= not noc4_stop_out;
  noc4_data_void_in  <= fwd_rd_empty_o(3) when noc4_stop_out = '0' else '1';
  sync_noc4_in : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => tile_rstn,
      clk_wr_i   => tile_clk,
      we_i       => fwd_we_i(3),
      d_i        => noc4_input_port_tile,
      wr_full_o  => fwd_wr_full_o(3),
      rst_rd_n_i => noc_rstn,
      clk_rd_i   => noc_clk,
      rd_i       => fwd_rd_i(3),
      q_o        => noc4_input_port,
      rd_empty_o => fwd_rd_empty_o(3));

  -----------------------------------------------------------------------------
  -- NoC plane 5
  -----------------------------------------------------------------------------

  rev_we_i(4)             <= not noc5_data_void_out;
  noc5_stop_in            <= rev_wr_full_o(4) when noc5_data_void_out = '0' else '0';
  rev_rd_i(4)             <= not noc5_stop_in_tile;
  noc5_data_void_out_tile <= rev_rd_empty_o(4);
  sync_noc5_out : inferred_async_fifo
    generic map (
      g_data_width => MISC_NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => noc_rstn,
      clk_wr_i   => noc_clk,
      we_i       => rev_we_i(4),
      d_i        => noc5_output_port,
      wr_full_o  => rev_wr_full_o(4),
      rst_rd_n_i => tile_rstn,
      clk_rd_i   => tile_clk,
      rd_i       => rev_rd_i(4),
      q_o        => noc5_output_port_tile,
      rd_empty_o => rev_rd_empty_o(4));

  fwd_we_i(4)        <= not noc5_data_void_in_tile;
  noc5_stop_out_tile <= fwd_wr_full_o(4);
  fwd_rd_i(4)        <= not noc5_stop_out;
  noc5_data_void_in  <= fwd_rd_empty_o(4) when noc5_stop_out = '0' else '1';
  sync_noc5_in : inferred_async_fifo
    generic map (
      g_data_width => MISC_NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => tile_rstn,
      clk_wr_i   => tile_clk,
      we_i       => fwd_we_i(4),
      d_i        => noc5_input_port_tile,
      wr_full_o  => fwd_wr_full_o(4),
      rst_rd_n_i => noc_rstn,
      clk_rd_i   => noc_clk,
      rd_i       => fwd_rd_i(4),
      q_o        => noc5_input_port,
      rd_empty_o => fwd_rd_empty_o(4));

  -----------------------------------------------------------------------------
  -- NoC plane 6
  -----------------------------------------------------------------------------

  rev_we_i(5)             <= not noc6_data_void_out;
  noc6_stop_in            <= rev_wr_full_o(5) when noc6_data_void_out = '0' else '0';
  rev_rd_i(5)             <= not noc6_stop_in_tile;
  noc6_data_void_out_tile <= rev_rd_empty_o(5);
  sync_noc6_out : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => noc_rstn,
      clk_wr_i   => noc_clk,
      we_i       => rev_we_i(5),
      d_i        => noc6_output_port,
      wr_full_o  => rev_wr_full_o(5),
      rst_rd_n_i => tile_rstn,
      clk_rd_i   => tile_clk,
      rd_i       => rev_rd_i(5),
      q_o        => noc6_output_port_tile,
      rd_empty_o => rev_rd_empty_o(5));

  fwd_we_i(5)        <= not noc6_data_void_in_tile;
  noc6_stop_out_tile <= fwd_wr_full_o(5);
  fwd_rd_i(5)        <= not noc6_stop_out;
  noc6_data_void_in  <= fwd_rd_empty_o(5) when noc6_stop_out = '0' else '1';
  sync_noc6_in : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => tile_rstn,
      clk_wr_i   => tile_clk,
      we_i       => fwd_we_i(5),
      d_i        => noc6_input_port_tile,
      wr_full_o  => fwd_wr_full_o(5),
      rst_rd_n_i => noc_rstn,
      clk_rd_i   => noc_clk,
      rd_i       => fwd_rd_i(5),
      q_o        => noc6_input_port,
      rd_empty_o => fwd_rd_empty_o(5));

end architecture rtl;
