-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

--/*
-- * Module: bypassable_queue
-- * Description: Bypassable FIFO.  
-- *              A FIFO can be bypassed when the incoming flit can be forwarded directly
-- *              to an output without need to be stored.
-- * Author: Michele Petracca
-- * $ID$
-- * 
-- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity bypassable_queue is
	generic(
		depth : integer;
		width : integer
--		localx	: std_logic_vector(2 downto 0);
--		localy	: std_logic_vector(2 downto 0)
        );

	port(
		clk		: in std_logic := '0';
		rst		: in std_logic;


		rdreq		: in std_logic;	
		wrreq		: in std_logic;	
		data_in 	: in std_logic_vector(width-1 downto 0);

		--request registers
		empty		: out std_logic;	
		full		: out std_logic;	
		data_out 	: out std_logic_vector(width-1 downto 0);
		routing_out	: out std_logic_vector(4 downto 0));
end bypassable_queue;


architecture behavior of bypassable_queue is

component fifo0
	generic(
		depth : integer;
		width : integer);
	port(
		clk		: in std_logic;
		rst		: in std_logic;

		rdreq		: in std_logic;	
		wrreq		: in std_logic;
		data_in 	: in std_logic_vector(width-1 downto 0);

		--request registers
		empty		: out std_logic;	
		full		: out std_logic;	
		data_out 	: out std_logic_vector(width-1 downto 0));
end component;

component fifo1
	generic(
		width : integer);
	port(
		clk		: in std_logic;
		rst		: in std_logic;

		rdreq		: in std_logic;	
		wrreq		: in std_logic;
		data_in 	: in std_logic_vector(width-1 downto 0);

		--request registers
		empty		: out std_logic;	
		full		: out std_logic;	
		data_out 	: out std_logic_vector(width-1 downto 0));
end component;


signal fifo_data_out, data_out_i : std_logic_vector(width-1 downto 0);
signal wr_internal_fifo, rd_internal_fifo : std_logic;
signal empty_i : std_logic;
signal routing_out_i	: std_logic_vector(4 downto 0);

--for others: fifo use entity testchip_v2.fifo(behavior);
--for others: fifo1 use entity testchip_v2.fifo1(behavior);

begin

wr_internal_fifo <= '1' when (wrreq = '1' and empty_i = '1' and rdreq = '0') or (wrreq = '1' and empty_i = '0') else '0';
rd_internal_fifo <= '1' when (rdreq = '1' and empty_i = '0') else '0';

QUEUE_INST1: if (depth = 1) generate
queue: fifo1 
	generic map(
		width => width)
	port map(
		clk => clk,
		rst => rst,

		rdreq	=> rd_internal_fifo,
		wrreq	=> wr_internal_fifo,
		data_in => data_in,

		--request registers
		empty => empty_i,
		full => full,
		data_out => fifo_data_out);
end generate;

QUEUE_INST: if (depth > 1) generate
queue: fifo0
	generic map(
		depth => depth,
		width => width)
	port map(
		clk => clk,
		rst => rst,

		rdreq	=> rd_internal_fifo,
		wrreq	=> wr_internal_fifo,
		data_in => data_in,

		--request registers
		empty => empty_i,
		full => full,
		data_out => fifo_data_out);
end generate;


empty <= empty_i;
routing_out <= data_out_i(4 downto 0);
data_out <= data_out_i;

process(data_in, fifo_data_out, empty_i)
begin
	if empty_i = '1' then
		data_out_i <= data_in;
	else
		data_out_i <= fifo_data_out;
	end if;		
end process;

end behavior;
