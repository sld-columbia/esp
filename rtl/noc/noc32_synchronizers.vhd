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

entity noc32_synchronizers is
  port (
    noc_rstn  : in std_ulogic;
    tile_rstn : in std_ulogic;
    noc_clk   : in std_ulogic;
    tile_clk  : in std_ulogic;

    -- NoC out to synchronizers
    output_port   : in  misc_noc_flit_type;
    data_void_out : in  std_ulogic;
    stop_in       : out std_ulogic;

    -- synchronizers to NoC in
    input_port   : out misc_noc_flit_type;
    data_void_in : out std_ulogic;
    stop_out     : in  std_ulogic;

    -- synchronizers out to tile
    output_port_tile   : out misc_noc_flit_type;
    data_void_out_tile : out std_ulogic;
    stop_in_tile       : in  std_ulogic;

    -- tile to synchronizers in
    input_port_tile   : in  misc_noc_flit_type;
    data_void_in_tile : in  std_ulogic;
    stop_out_tile     : out std_ulogic);

end entity noc32_synchronizers;

architecture rtl of noc32_synchronizers is

  signal fwd_rd_i, fwd_we_i : std_ulogic;
  signal rev_rd_i, rev_we_i : std_ulogic;
  signal fwd_rd_empty_o     : std_ulogic;
  signal fwd_wr_full_o      : std_ulogic;
  signal rev_rd_empty_o     : std_ulogic;
  signal rev_wr_full_o      : std_ulogic;

begin  -- architecture rtl

  rev_we_i           <= not data_void_out;
  stop_in            <= rev_wr_full_o when data_void_out = '0' else '0';
  rev_rd_i           <= not stop_in_tile;
  data_void_out_tile <= rev_rd_empty_o;

  sync_noc_out : inferred_async_fifo
    generic map (
      g_data_width => MISC_NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => noc_rstn,
      clk_wr_i   => noc_clk,
      we_i       => rev_we_i,
      d_i        => output_port,
      wr_full_o  => rev_wr_full_o,
      rst_rd_n_i => tile_rstn,
      clk_rd_i   => tile_clk,
      rd_i       => rev_rd_i,
      q_o        => output_port_tile,
      rd_empty_o => rev_rd_empty_o);

  fwd_we_i      <= not data_void_in_tile;
  stop_out_tile <= fwd_wr_full_o;
  fwd_rd_i      <= not stop_out;
  data_void_in  <= fwd_rd_empty_o when stop_out = '0' else '1';

  sync_noc_in : inferred_async_fifo
    generic map (
      g_data_width => MISC_NOC_FLIT_SIZE,
      g_size       => 8)
    port map (
      rst_wr_n_i => tile_rstn,
      clk_wr_i   => tile_clk,
      we_i       => fwd_we_i,
      d_i        => input_port_tile,
      wr_full_o  => fwd_wr_full_o,
      rst_rd_n_i => noc_rstn,
      clk_rd_i   => noc_clk,
      rd_i       => fwd_rd_i,
      q_o        => input_port,
      rd_empty_o => fwd_rd_empty_o);

end architecture rtl;
