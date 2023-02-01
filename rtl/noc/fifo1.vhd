-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

--/*
-- * Module: fifo1
-- * Description: First In First Out queue.  
-- *              The DEPTH parameter represents the number of memory locations 
-- *              into the FIFO. The WIDTH parameter represents data parallelism.
-- * Author: Michele Petracca
-- * $ID$
-- * 
-- */

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity fifo1 is
	generic(
		width : integer := 18);
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
end fifo1;


architecture behavior of fifo1 is

	signal reg : std_logic_vector(width-1 downto 0);
	
	signal usedw : std_logic;

begin

	--fifo occupation
	process(clk, rst)
	begin
		if rst = '0' then
			usedw <= '0';
		elsif clk = '1' and clk'event then
			if wrreq = '1' and rdreq = '0' then
				usedw <= '1';
			elsif rdreq = '1' and wrreq = '0' then
				usedw <= '0';
			end if;
		end if;
	end process;

	empty <= not usedw;
	full <= usedw;
 
	process(clk, rst)
	begin
		if rst = '0' then
			reg <= (others => '0');
 		elsif clk = '1' and clk'event then
			if wrreq = '1' then
				reg <= data_in;
			end if;
		end if;
	end process;

	data_out <= reg;

end behavior;
