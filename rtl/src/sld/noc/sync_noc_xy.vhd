-------------------------------------------------------------------------------
--
-- Module:      sync_noc_xy
-- Description: Mesh of x columns by y rows RTL routers with synchronizers
--
-- Author:      Christian Pilato
-- Affiliation: Columbia University
--
-- last update: 2015-12-07
--
-------------------------------------------------------------------------------
--
-- Addressing is XY; X: from left to right, Y: from top to bottom
--
-- Local mapping for the latency insensitive protocol
-- 0 = North
-- 1 = South
-- 2 = West
-- 3 = East
-- 4 = Local tile
--
-- Check the module "router" in router.vhd for details on routing algorithm
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sldcommon.all;
use work.nocpackage.all;

entity sync_noc_xy is
  generic (
    flit_size : integer := 34;
    XLEN      : integer;
    YLEN      : integer;
    TILES_NUM : integer;
    HAS_SYNC  : integer := 1);
  port (
    clk           : in  std_logic;
    clk_tile      : in  std_logic_vector(TILES_NUM-1 downto 0);
    rst           : in  std_logic;
    input_port    : in  noc_flit_vector(TILES_NUM-1 downto 0);
    data_void_in  : in  std_logic_vector(TILES_NUM-1 downto 0);
    stop_in       : in  std_logic_vector(TILES_NUM-1 downto 0);
    output_port   : out noc_flit_vector(TILES_NUM-1 downto 0);
    data_void_out : out std_logic_vector(TILES_NUM-1 downto 0);
    stop_out      : out std_logic_vector(TILES_NUM-1 downto 0);
    -- Monitor output. Can be left unconnected
    mon_noc       : out monitor_noc_vector(0 to TILES_NUM-1)
    );

end sync_noc_xy;

architecture mesh of sync_noc_xy is

  component noc_xy
    generic (
      XLEN      : integer;
      YLEN      : integer;
      TILES_NUM : integer;
      flit_size : integer);
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      input_port    : in  noc_flit_vector(TILES_NUM-1 downto 0);
      data_void_in  : in  std_logic_vector(TILES_NUM-1 downto 0);
      stop_in       : in  std_logic_vector(TILES_NUM-1 downto 0);
      output_port   : out noc_flit_vector(TILES_NUM-1 downto 0);
      data_void_out : out std_logic_vector(TILES_NUM-1 downto 0);
      stop_out      : out std_logic_vector(TILES_NUM-1 downto 0);
      -- Monitor output
      mon_noc       : out monitor_noc_vector(0 to TILES_NUM-1)
      );
  end component;

  signal fwd_ack	  : std_logic_vector(TILES_NUM-1 downto 0);
  signal fwd_req	  : std_logic_vector(TILES_NUM-1 downto 0);
  signal fwd_chnl_data	  : noc_flit_vector(TILES_NUM-1 downto 0);
  signal fwd_chnl_stop	  : std_logic_vector(TILES_NUM-1 downto 0);

  signal rev_ack	  : std_logic_vector(TILES_NUM-1 downto 0);
  signal rev_req	  : std_logic_vector(TILES_NUM-1 downto 0);
  signal rev_chnl_data	  : noc_flit_vector(TILES_NUM-1 downto 0);
  signal rev_chnl_stop	  : std_logic_vector(TILES_NUM-1 downto 0);

  signal sync_output_port   : noc_flit_vector(TILES_NUM-1 downto 0);
  signal sync_data_void_out : std_logic_vector(TILES_NUM-1 downto 0);
  signal sync_input_port    : noc_flit_vector(TILES_NUM-1 downto 0);
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

  noc_xy_1: noc_xy
    generic map (
      XLEN      => XLEN,
      YLEN      => YLEN,
      TILES_NUM => TILES_NUM,
      flit_size => NOC_FLIT_SIZE)
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

  synchronizers: if HAS_SYNC = 1 generate
  FWD_rx:
    for i in 0 to TILES_NUM-1 generate
    begin
      FWD_rx1: sync_noc_receiver
        port map (
          clock         => clk,
          reset         => rst,
          req           => fwd_req(i),
          data_in       => fwd_chnl_data(i),
          stop_out      => sync_stop_out(i),     -- name convention confusion
          chnl_stop     => fwd_chnl_stop(i),
          ack           => fwd_ack(i),
          data_out      => sync_input_port(i),
          valid_out     => sync_data_void_in(i));
    end generate FWD_rx;

  FWD_tx:
    for i in 0 to TILES_NUM-1 generate
    begin
      FWD_tx1: sync_transmitter
        port map (
          clock         => clk_tile(i),
          reset         => rst,  -- change to rst2
          valid_in      => data_void_in(i),
          ack           => fwd_ack(i),
          data_in       => input_port(i),
          chnl_stop     => fwd_chnl_stop(i),
          req           => fwd_req(i),
          data_out      => fwd_chnl_data(i),
          stop_in       => stop_out(i));     --name convention confusion
    end generate FWD_tx;

  REV_tx:
    for i in 0 to TILES_NUM-1 generate
    begin
      REV_tx1: sync_noc_transmitter
        port map (
          clock         => clk,
          reset         => rst,
          valid_in      => sync_data_void_out(i),
          ack           => rev_ack(i),
          data_in       => sync_output_port(i),
          chnl_stop     => rev_chnl_stop(i),
          req           => rev_req(i),
          data_out      => rev_chnl_data(i),
          stop_in       => sync_stop_in(i));    -- name convention confusion
    end generate REV_tx;

  REV_rx:
    for i in 0 to TILES_NUM-1 generate
    begin
      REV_rx1: sync_receiver
        port map (
          clock         => clk_tile(i),  
          reset         => rst,  -- change to rst2
          req           => rev_req(i),
          data_in       => rev_chnl_data(i),
          stop_out      => stop_in(i), -- naem convention confusion
          chnl_stop     => rev_chnl_stop(i),
          ack           => rev_ack(i),
          data_out      => output_port(i),
          valid_out     => data_void_out(i));
    end generate REV_rx;
  end generate synchronizers;

  inferred_async_fifos_gen: if HAS_SYNC = 2 generate
    tile_to_NoC:
    for i in 0 to TILES_NUM-1 generate
    begin
      fwd_we_i(i) <= not data_void_in(i);
      stop_out(i) <= fwd_wr_full_o(i);-- when data_void_in(i) = '0' else '0';
      fwd_rd_i(i) <= not sync_stop_out(i);
      sync_data_void_in(i) <= fwd_rd_empty_o(i) when sync_stop_out(i) = '0' else '1';
      inferred_async_fifo_1: inferred_async_fifo
        generic map (
          g_data_width => NOC_FLIT_SIZE,
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
          g_data_width => NOC_FLIT_SIZE,
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

