-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: MIT

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sldcommon.all;
use work.nocpackage.all;

entity sync_noc32_xy is
  generic (
    XLEN      : integer;
    YLEN      : integer;
    TILES_NUM : integer;
    HAS_SYNC  : integer range 0 to 1 := 0);
  port (
    clk           : in  std_logic;
    clk_tile      : in  std_logic_vector(TILES_NUM-1 downto 0);
    rst           : in  std_logic;
    input_port    : in  misc_noc_flit_vector(TILES_NUM-1 downto 0);
    data_void_in  : in  std_logic_vector(TILES_NUM-1 downto 0);
    stop_in       : in  std_logic_vector(TILES_NUM-1 downto 0);
    output_port   : out misc_noc_flit_vector(TILES_NUM-1 downto 0);
    data_void_out : out std_logic_vector(TILES_NUM-1 downto 0);
    stop_out      : out std_logic_vector(TILES_NUM-1 downto 0);
    -- Monitor output. Can be left unconnected
    mon_noc       : out monitor_noc_vector(0 to TILES_NUM-1)
    );

end sync_noc32_xy;

architecture mesh of sync_noc32_xy is

  component noc32_xy
    generic (
      XLEN      : integer;
      YLEN      : integer;
      TILES_NUM : integer);
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      input_port    : in  misc_noc_flit_vector(TILES_NUM-1 downto 0);
      data_void_in  : in  std_logic_vector(TILES_NUM-1 downto 0);
      stop_in       : in  std_logic_vector(TILES_NUM-1 downto 0);
      output_port   : out misc_noc_flit_vector(TILES_NUM-1 downto 0);
      data_void_out : out std_logic_vector(TILES_NUM-1 downto 0);
      stop_out      : out std_logic_vector(TILES_NUM-1 downto 0);
      -- Monitor output
      mon_noc       : out monitor_noc_vector(0 to TILES_NUM-1)
      );
  end component;

  signal fwd_ack	  : std_logic_vector(TILES_NUM-1 downto 0);
  signal fwd_req	  : std_logic_vector(TILES_NUM-1 downto 0);
  signal fwd_chnl_data	  : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal fwd_chnl_stop	  : std_logic_vector(TILES_NUM-1 downto 0);

  signal rev_ack	  : std_logic_vector(TILES_NUM-1 downto 0);
  signal rev_req	  : std_logic_vector(TILES_NUM-1 downto 0);
  signal rev_chnl_data	  : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal rev_chnl_stop	  : std_logic_vector(TILES_NUM-1 downto 0);

  signal sync_output_port   : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal sync_data_void_out : std_logic_vector(TILES_NUM-1 downto 0);
  signal sync_input_port    : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal sync_data_void_in  : std_logic_vector(TILES_NUM-1 downto 0);
  signal sync_stop_in 	    : std_logic_vector(TILES_NUM-1 downto 0);
  signal sync_stop_out 	    : std_logic_vector(TILES_NUM-1 downto 0);

  signal fwd_rd_i, fwd_we_i : std_logic_vector(TILES_NUM-1 downto 0);
  signal rev_rd_i, rev_we_i : std_logic_vector(TILES_NUM-1 downto 0);
  signal fwd_rd_empty_o     : std_logic_vector(TILES_NUM-1 downto 0);
  signal fwd_wr_full_o      : std_logic_vector(TILES_NUM-1 downto 0);
  signal rev_rd_empty_o     : std_logic_vector(TILES_NUM-1 downto 0);
  signal rev_wr_full_o      : std_logic_vector(TILES_NUM-1 downto 0);

begin

  noc_xy_1: noc32_xy
    generic map (
      XLEN      => XLEN,
      YLEN      => YLEN,
      TILES_NUM => TILES_NUM)
    port map (
      clk           => clk,
      rst           => rst,
      input_port    => sync_input_port,
      data_void_in  => sync_data_void_in,
      stop_in       => sync_stop_in,
      output_port   => sync_output_port,
      data_void_out => sync_data_void_out,
      stop_out      => sync_stop_out,
      mon_noc       => mon_noc
      );

----------------------------------------------------------------------------------------------
-- FWD channel: input to the NoC
-- REV channel: output from the Noc
-- each channel will have a sync tx and rx pair with prefix FWD and REV respectively

  no_synchronizers: if HAS_SYNC = 0 generate
    sync_input_port <= input_port;
    sync_data_void_in <= data_void_in;
    sync_stop_in <= stop_in;
    output_port <= sync_output_port;
    data_void_out <= sync_data_void_out;
    stop_out <= sync_stop_out;
    fwd_ack <= (others => '0');
    fwd_req <= (others => '0');
    fwd_chnl_stop <= (others => '0');
    rev_ack <= (others => '0');
    rev_req <= (others => '0');
    rev_chnl_stop <= (others => '0');
    data_reset: for i in 0 to TILES_NUM-1 generate
      fwd_chnl_data(i) <= (others => '0');
      rev_chnl_data(i) <= (others => '0');
    end generate;
  end generate no_synchronizers;

  inferred_async_fifos_gen: if HAS_SYNC /= 0 generate
    tile_to_NoC:
    for i in 0 to TILES_NUM-1 generate
    begin
      fwd_we_i(i) <= not data_void_in(i);
      stop_out(i) <= fwd_wr_full_o(i);-- when data_void_in(i) = '0' else '0';
      fwd_rd_i(i) <= not sync_stop_out(i);
      sync_data_void_in(i) <= fwd_rd_empty_o(i) when sync_stop_out(i) = '0' else '1';
      inferred_async_fifo_1: inferred_async_fifo
        generic map (
          g_data_width => MISC_NOC_FLIT_SIZE,
          g_size       => 8)
        port map (
          rst_n_i    => rst,
          clk_wr_i   => clk_tile(i),
          we_i       => fwd_we_i(i),
          d_i        => input_port(i),
          wr_full_o  => fwd_wr_full_o(i),
          clk_rd_i   => clk,
          rd_i       => fwd_rd_i(i),
          q_o        => sync_input_port(i),
          rd_empty_o => fwd_rd_empty_o(i));
    end generate tile_to_NoC;

    Noc_to_tile:
    for i in 0 to TILES_NUM-1 generate
    begin
      rev_we_i(i) <= not sync_data_void_out(i);
      sync_stop_in(i) <= rev_wr_full_o(i) when sync_data_void_out(i) = '0' else '0';
      rev_rd_i(i) <= not stop_in(i);
      data_void_out(i) <= rev_rd_empty_o(i);-- when stop_in(i) = '0' else '1';
      inferred_async_fifo_1: inferred_async_fifo
        generic map (
          g_data_width => MISC_NOC_FLIT_SIZE,
          g_size       => 8)
        port map (
          rst_n_i    => rst,
          clk_wr_i   => clk,
          we_i       => rev_we_i(i),
          d_i        => sync_output_port(i),
          wr_full_o  => rev_wr_full_o(i),
          clk_rd_i   => clk_tile(i),
          rd_i       => rev_rd_i(i),
          q_o        => output_port(i),
          rd_empty_o => rev_rd_empty_o(i));
    end generate Noc_to_tile;

  end generate inferred_async_fifos_gen;

end mesh;

