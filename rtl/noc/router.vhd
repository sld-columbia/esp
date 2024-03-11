-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

--/*
-- * Module: router
-- * Description: 5x5 router
-- *              The router has 1 port attached to the processor and 4 ports to route
-- *              data. The routing algorithm is XY Dimension Order.
-- *              The router uses a worm-hole flow-control at network level
-- *              and an ACK/NACK flow control at link level. It can be interfaced with
-- *              single state Relay Stations.
-- *              The router implements routing look-ahead, performing routing for the following hop
-- *              and carrying the routing result into the head flit of the worm.
-- *              In case of incoming head flit directed to a free output without contention
-- *              the flit is forwarded in a single clock cycle (low load hypotesys). In all the other
-- *              scenarios the worm is forwarded in two clock cycles, resolving contentions during
-- *              the added cycle.
-- * Author: Michele Petracca
-- * $ID$
-- * 
-- Mapping:
-- 0 = North
-- 1 = South
-- 2 = West
-- 3 = East
-- 4 = Processor
-- */

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.stdlib.all;

entity router is
  generic(
    flow_control : integer                      := 0;  --0 = AN; 1 = CB
    width        : integer                      := 34;
    depth        : integer                      := 4;
    ports        : std_logic_vector(4 downto 0) := "11111";
    DEST_SIZE    : integer
    );
  port(
    clk : in std_logic;
    rst : in std_logic;

    CONST_localx : in std_logic_vector(2 downto 0);
    CONST_localy : in std_logic_vector(2 downto 0);

    data_n_in : in std_logic_vector(width-1 downto 0);
    data_s_in : in std_logic_vector(width-1 downto 0);
    data_w_in : in std_logic_vector(width-1 downto 0);
    data_e_in : in std_logic_vector(width-1 downto 0);
    data_p_in : in std_logic_vector(width-1 downto 0);

    data_void_in : in std_logic_vector(4 downto 0);
    stop_in      : in std_logic_vector(4 downto 0);

    data_n_out : out std_logic_vector(width-1 downto 0);
    data_s_out : out std_logic_vector(width-1 downto 0);
    data_w_out : out std_logic_vector(width-1 downto 0);
    data_e_out : out std_logic_vector(width-1 downto 0);
    data_p_out : out std_logic_vector(width-1 downto 0);

    data_void_out : out std_logic_vector(4 downto 0);
    stop_out      : out std_logic_vector(4 downto 0));
end router;



architecture behavior of router is

  component lookahead_router_wrapper
    generic(
      FlowControl : std_logic;
      Width       : integer;
      Ports       : std_logic_vector(4 downto 0);
      DEST_SIZE   : integer
      );
    port(
      clk : in std_logic;
      rst : in std_logic;

      CONST_localx : in std_logic_vector(2 downto 0);
      CONST_localy : in std_logic_vector(2 downto 0);

      data_n_in : in std_logic_vector(width-1 downto 0);
      data_s_in : in std_logic_vector(width-1 downto 0);
      data_w_in : in std_logic_vector(width-1 downto 0);
      data_e_in : in std_logic_vector(width-1 downto 0);
      data_p_in : in std_logic_vector(width-1 downto 0);

      data_void_in : in std_logic_vector(4 downto 0);
      stop_in      : in std_logic_vector(4 downto 0);

      data_n_out : out std_logic_vector(width-1 downto 0);
      data_s_out : out std_logic_vector(width-1 downto 0);
      data_w_out : out std_logic_vector(width-1 downto 0);
      data_e_out : out std_logic_vector(width-1 downto 0);
      data_p_out : out std_logic_vector(width-1 downto 0);

      data_void_out : out std_logic_vector(4 downto 0);
      stop_out      : out std_logic_vector(4 downto 0));
  end component;

begin

  lookahead_router_wrapper_i: lookahead_router_wrapper
    generic map (
      FlowControl => to_std_logic(flow_control),
      Width       => width,
      Ports       => Ports,
      DEST_SIZE   => DEST_SIZE)
    port map (
      clk           => clk,
      rst           => rst,
      CONST_localx  => CONST_localx,
      CONST_localy  => CONST_localy,
      data_n_in     => data_n_in,
      data_s_in     => data_s_in,
      data_w_in     => data_w_in,
      data_e_in     => data_e_in,
      data_p_in     => data_p_in,
      data_void_in  => data_void_in,
      stop_in       => stop_in,
      data_n_out    => data_n_out,
      data_s_out    => data_s_out,
      data_w_out    => data_w_out,
      data_e_out    => data_e_out,
      data_p_out    => data_p_out,
      data_void_out => data_void_out,
      stop_out      => stop_out);

end behavior;
