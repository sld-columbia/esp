-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.monitor_pkg.all;
use work.nocpackage.all;

entity sync_noc32_xy is
  generic (
    PORTS     : std_logic_vector(4 downto 0);
--    local_x   : std_logic_vector(2 downto 0);
--    local_y   : std_logic_vector(2 downto 0);
    HAS_SYNC  : integer range 0 to 1 := 0);
  port (
    clk           : in  std_logic;
    clk_tile      : in  std_logic;
    rst           : in  std_logic;
    rst_tile      : in  std_logic;
--    CONST_PORTS   : in  std_logic_vector(4 downto 0);
    CONST_local_x : in  std_logic_vector(2 downto 0);
    CONST_local_y : in  std_logic_vector(2 downto 0);
    data_n_in     : in  misc_noc_flit_type; 
    data_s_in     : in  misc_noc_flit_type;
    data_w_in     : in  misc_noc_flit_type;
    data_e_in     : in  misc_noc_flit_type;
    input_port    : in  misc_noc_flit_type;
    data_void_in  : in  std_logic_vector(4 downto 0);
    stop_in       : in  std_logic_vector(4 downto 0);
    data_n_out    : out misc_noc_flit_type;
    data_s_out    : out misc_noc_flit_type;
    data_w_out    : out misc_noc_flit_type;
    data_e_out    : out misc_noc_flit_type;
    output_port   : out misc_noc_flit_type;
    data_void_out : out std_logic_vector(4 downto 0);
    stop_out      : out std_logic_vector(4 downto 0);
    -- Monitor output. Can be left unconnected
    mon_noc       : out monitor_noc_type
    );

end sync_noc32_xy;

architecture mesh of sync_noc32_xy is

  component router
    generic (
      flow_control : integer;
      width        : integer;
      depth        : integer;
      ports        : std_logic_vector(4 downto 0)
--      localx       : std_logic_vector(2 downto 0);
--      localy       : std_logic_vector(2 downto 0)
    );

    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
--      CONST_ports   : in  std_logic_vector(4 downto 0);
      CONST_localx  : in  std_logic_vector(2 downto 0);
      CONST_localy  : in  std_logic_vector(2 downto 0);
      data_n_in     : in  std_logic_vector(width-1 downto 0);
      data_s_in     : in  std_logic_vector(width-1 downto 0);
      data_w_in     : in  std_logic_vector(width-1 downto 0);
      data_e_in     : in  std_logic_vector(width-1 downto 0);
      data_p_in     : in  std_logic_vector(width-1 downto 0);
      data_void_in  : in  std_logic_vector(4 downto 0);
      stop_in       : in  std_logic_vector(4 downto 0);
      data_n_out    : out std_logic_vector(width-1 downto 0);
      data_s_out    : out std_logic_vector(width-1 downto 0);
      data_w_out    : out std_logic_vector(width-1 downto 0);
      data_e_out    : out std_logic_vector(width-1 downto 0);
      data_p_out    : out std_logic_vector(width-1 downto 0);
      data_void_out : out std_logic_vector(4 downto 0);
      stop_out      : out std_logic_vector(4 downto 0));
  end component;

  signal fwd_ack	  : std_logic;
  signal fwd_req	  : std_logic;
  signal fwd_chnl_data	  : misc_noc_flit_type;
  signal fwd_chnl_stop	  : std_logic;

  signal rev_ack	  : std_logic;
  signal rev_req	  : std_logic;
  signal rev_chnl_data	  : misc_noc_flit_type;
  signal rev_chnl_stop	  : std_logic;

  signal sync_output_port   : misc_noc_flit_type;
  signal sync_data_void_out : std_logic;
  signal sync_input_port    : misc_noc_flit_type;
  signal sync_data_void_in  : std_logic;
  signal sync_stop_in 	    : std_logic;
  signal sync_stop_out 	    : std_logic;

  signal fwd_rd_i, fwd_we_i : std_logic;
  signal rev_rd_i, rev_we_i : std_logic;
  signal fwd_rd_empty_o     : std_logic;
  signal fwd_wr_full_o      : std_logic;
  signal rev_rd_empty_o     : std_logic;
  signal rev_wr_full_o      : std_logic;

  signal data_void_in_i  : std_logic_vector(4 downto 0);
  signal stop_in_i       : std_logic_vector(4 downto 0);
  signal data_void_out_i : std_logic_vector(4 downto 0);
  signal stop_out_i      : std_logic_vector(4 downto 0);

  begin

  data_void_in_i            <= sync_data_void_in & data_void_in(3 downto 0);
  stop_in_i                 <= sync_stop_in & stop_in(3 downto 0);
  sync_data_void_out        <= data_void_out_i(4);
  data_void_out(3 downto 0) <= data_void_out_i(3 downto 0);
  sync_stop_out             <= stop_out_i(4);
  stop_out(3 downto 0)      <= stop_out_i(3 downto 0);

----------------------------------------------------------------------------------------------
-- Router
----------------------------------------------------------------------------------------------

    router_ij: router
      generic map (
          flow_control => FLOW_CONTROL,
          width        => MISC_NOC_FLIT_SIZE,
          depth        => ROUTER_DEPTH,
          ports        => PORTS
--          localx       => local_x,
--          localy       => local_y
      )
      port map (
          clk           => clk,
          rst           => rst,
--          CONST_ports   => CONST_PORTS,
          CONST_localx  => CONST_local_x,
          CONST_localy  => CONST_local_y,
          data_n_in     => data_n_in,
          data_s_in     => data_s_in,
          data_w_in     => data_w_in,
          data_e_in     => data_e_in,
          data_p_in     => sync_input_port,
          data_void_in  => data_void_in_i,
          stop_in       => stop_in_i,
          data_n_out    => data_n_out,
          data_s_out    => data_s_out,
          data_w_out    => data_w_out,
          data_e_out    => data_e_out,
          data_p_out    => sync_output_port,
          data_void_out => data_void_out_i,
          stop_out      => stop_out_i);

    -- Monitor signals
    mon_noc.clk          <= clk;
    mon_noc.tile_inject  <= not data_void_in(4);

    mon_noc.queue_full(4) <= data_void_out_i(4) nand data_void_in_i(4);
    mon_noc.queue_full(3) <= not data_void_out_i(3);
    mon_noc.queue_full(2) <= not data_void_out_i(2);
    mon_noc.queue_full(1) <= not data_void_out_i(1);
    mon_noc.queue_full(0) <= not data_void_out_i(0);

----------------------------------------------------------------------------------------------
-- FWD channel: input to the NoC
-- REV channel: output from the Noc
-- each channel will have a sync tx and rx pair with prefix FWD and REV respectively

  no_synchronizers: if HAS_SYNC = 0 generate
    sync_input_port <= input_port;
    sync_data_void_in <= data_void_in(4);
    sync_stop_in <= stop_in(4);
    output_port  <= sync_output_port;
    data_void_out(4) <= sync_data_void_out;
    stop_out(4) <= sync_stop_out;
    fwd_ack <= '0';
    fwd_req <= '0';
    fwd_chnl_stop <= '0';
    rev_ack <= '0';
    rev_req <= '0';
    rev_chnl_stop <= '0';
    fwd_chnl_data <= (others => '0');
    rev_chnl_data <= (others => '0');

  end generate no_synchronizers;

  inferred_async_fifos_gen: if HAS_SYNC /= 0 generate
    begin
      fwd_we_i    <= not data_void_in(4);
      stop_out(4) <= fwd_wr_full_o;-- when data_void_in = '0' else '0';
      fwd_rd_i    <= not sync_stop_out;
      sync_data_void_in <= fwd_rd_empty_o when sync_stop_out = '0' else '1';
      inferred_async_fifo_1: inferred_async_fifo
        generic map (
          g_data_width => MISC_NOC_FLIT_SIZE,
          g_size       => 8)
        port map (
          rst_wr_n_i => rst_tile,
          clk_wr_i   => clk_tile,
          we_i       => fwd_we_i,
          d_i        => input_port,
          wr_full_o  => fwd_wr_full_o,
          rst_rd_n_i => rst,
          clk_rd_i   => clk,
          rd_i       => fwd_rd_i,
          q_o        => sync_input_port,
          rd_empty_o => fwd_rd_empty_o);

      rev_we_i         <= not sync_data_void_out;
      sync_stop_in     <= rev_wr_full_o when sync_data_void_out = '0' else '0';
      rev_rd_i         <= not stop_in(4);
      data_void_out(4) <= rev_rd_empty_o;-- when stop_in = '0' else '1';
      inferred_async_fifo_2: inferred_async_fifo
        generic map (
          g_data_width => MISC_NOC_FLIT_SIZE,
          g_size       => 8)
        port map (
          rst_wr_n_i   => rst,
          clk_wr_i     => clk,
          we_i         => rev_we_i,
          d_i          => sync_output_port,
          wr_full_o    => rev_wr_full_o,
          rst_rd_n_i   => rst_tile,
          clk_rd_i     => clk_tile,
          rd_i         => rev_rd_i,
          q_o          => output_port,
          rd_empty_o   => rev_rd_empty_o);

  end generate inferred_async_fifos_gen;

end mesh;

