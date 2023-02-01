-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

--/*
-- * Module: fifo3
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

entity fifo3 is
	generic(
		depth : integer := 5;
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
                almost_full     : out std_logic;
		data_out 	: out std_logic_vector(width-1 downto 0));

end fifo3;



architecture behavior of fifo3 is

	type reg_type is array(0 to depth-1) of std_logic_vector(width-1 downto 0);
	signal reg, data_out_and : reg_type;
	
	signal head : std_logic_vector(depth-1 downto 0);
	signal tail : std_logic_vector(depth-1 downto 0);
	signal usedw : std_logic_vector(depth downto 0);

begin
	
	-- head pointer	
	process(clk, rst)
	begin
		if rst = '0' then
			head(depth-1 downto 1) <= (others => '0');
			head(0) <= '1';
		elsif clk = '1' and clk'event then
			if rdreq = '1' then
				head(depth-1 downto 1) <= head(depth-2 downto 0);
				head(0) <= head(depth-1);
			end if;
		end if;
	end process;

	--tail pointer	
	process(clk, rst)
	begin
		if rst = '0' then
			tail(depth-1 downto 1) <= (others => '0');
			tail(0) <= '1';
		elsif clk = '1' and clk'event then
			if wrreq = '1' then
				tail(depth-1 downto 1) <= tail(depth-2 downto 0);
				tail(0) <= tail(depth-1);
			end if;
		end if;
	end process;


	--fifo occupation
	process(clk, rst)
	begin
		if rst = '0' then
			usedw(depth downto 1) <= (others => '0');
			usedw(0) <= '1';
		elsif clk = '1' and clk'event then
			if wrreq = '1' and rdreq = '0' then
				usedw(depth downto 1) <= usedw(depth-1 downto 0);
				usedw(0) <= '0';
			elsif rdreq = '1' and wrreq = '0' then
				usedw(depth-1 downto 0) <= usedw(depth downto 1);
				usedw(depth) <= '0';
			end if;
		end if;
	end process;

	empty <= usedw(0);
	full <= usedw(depth);
	almost_full <= usedw(depth-1);
	
	REGS: for i in 0 to depth-1 generate
		process(clk, rst)
		begin
			if rst = '0' then
				reg(i) <= (others => '0');
 			elsif clk = '1' and clk'event then
				if wrreq = '1' and tail(i) = '1' then
					reg(i) <= data_in;
				end if;
			end if;
		end process;
	end generate;
	
	DATA_OUT_MASK: for i in 0 to depth-1 generate
		data_out_and(i) <= (others => '0') when head(i) = '0' else reg(i);
	end generate;
	
	process(data_out_and)
		variable data_out_or : std_logic_vector(width-1 downto 0);
	begin
		data_out_or := (others => '0');	
		for i in 0 to depth-1 loop
			data_out_or := data_out_or or data_out_and(i);
		end loop;
		data_out <= data_out_or; 
	end process;

end behavior;
