------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2016, Cobham Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity:      elastic_buffer
-- File:        elastic_buffer.vhd
-- Author:      Andrea Gianarro - Aeroflex Gaisler AB
-- Description: SGMII's elastic buffer
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;

entity elastic_buffer is
	generic (
		tech : integer := 0;
		abits : integer := 7
	);
	port (
		wr_clk	: in  std_logic;
		wr_rst	: in  std_logic;
		wr_data	: in  std_logic_vector(9 downto 0);
		rd_clk	: in  std_logic;
		rd_rst	: in  std_logic;
		rd_data	: out std_logic_vector(9 downto 0)
	) ;
end entity ;

architecture arch of elastic_buffer is

	type rd_reg_type is record
		fifo_out_d0		: std_logic_vector(9 downto 0);
		fifo_out_d1		: std_logic_vector(9 downto 0);
		insert_d0		: std_logic;
		insert_d1		: std_logic;
		start_reading	: std_logic;
	end record;

	type wr_reg_type is record
		fifo_in_d0	: std_logic_vector(9 downto 0);
		fifo_in_d1	: std_logic_vector(9 downto 0);
		delete_d0	: std_logic;
		delete_d1	: std_logic;
	end record;

	constant rd_reg_none : rd_reg_type := (
		fifo_out_d0		=> (others => '0'),
		fifo_out_d1		=> (others => '0'),
		insert_d0		=> '0',
		insert_d1		=> '0',
		start_reading	=> '0'
	);

	constant wr_reg_none : wr_reg_type := (
		fifo_in_d0	=> (others => '0'),
		fifo_in_d1	=> (others => '0'),
		delete_d0	=> '0',
		delete_d1	=> '0'
	);

	-- 8/10b encoding sequences
	constant COMMAP : std_logic_vector(6 downto 0) := "0011111";  
	constant COMMAN : std_logic_vector(6 downto 0) := "1100000"; 
	constant D16_2P : std_logic_vector(9 downto 0) := "0110110101";
	constant D16_2N : std_logic_vector(9 downto 0) := "1001000101";


	signal rd_r, rd_rin : rd_reg_type;
	signal wr_r, wr_rin : wr_reg_type;
	signal rd_en, wr_en : std_logic;

	signal wrusedw_int, rdusedw_int : std_logic_vector(abits-1 downto 0);
	signal fifo_out : std_logic_vector(9 downto 0);

	signal rd_rstn, wr_rstn : std_logic;

begin

	comb : process(rd_r, wr_r, fifo_out, wr_data, rdusedw_int, wrusedw_int, rd_rin, wr_rin, rd_rst, wr_rst)
		variable rd_v : rd_reg_type;
		variable wr_v : wr_reg_type;
		variable insert : std_logic;

	begin
		rd_v := rd_rin;
		wr_v := wr_rin;

		rd_v.fifo_out_d0 := fifo_out;
		rd_v.fifo_out_d1 := rd_r.fifo_out_d0;
		rd_v.insert_d0 := '0';
		rd_v.insert_d1 := rd_r.insert_d0;
		rd_v.start_reading := rd_r.start_reading or rdusedw_int(rdusedw_int'left); 

		wr_v.fifo_in_d0 := wr_data;
		wr_v.fifo_in_d1 := wr_r.fifo_in_d0;
		wr_v.delete_d0 := '0';
		wr_v.delete_d1 := wr_r.delete_d0;

		if 	rdusedw_int(abits-1 downto abits-6) < "011111" and
			((rd_r.fifo_out_d1(9 downto 3) = COMMAP and rd_r.fifo_out_d0 = D16_2N ) or (rd_r.fifo_out_d1(9 downto 3) = COMMAN and rd_r.fifo_out_d0 = D16_2P)) then
			rd_v.insert_d0 := '1';
		end if;

		if 	wrusedw_int(abits-1 downto abits-6) > "100000" and
			((wr_r.fifo_in_d1(9 downto 3) = COMMAP and wr_r.fifo_in_d0 = D16_2N ) or (wr_r.fifo_in_d1(9 downto 3) = COMMAN and wr_r.fifo_in_d0 = D16_2P)) then
			wr_v.delete_d0 := '1';
		end if;

		-- inserting /I2/ when needed
		if (rd_r.insert_d0 or rd_r.insert_d1) = '1' then
			rd_v.fifo_out_d0 := rd_r.fifo_out_d1;
		end if;
		rd_en <= rd_r.start_reading and (not rd_rst) and not (rd_r.insert_d0 or rd_v.insert_d0);

		-- deleting /I2/ when needed
		wr_en <= (not wr_rst) and not (wr_r.delete_d0 or wr_v.delete_d0);

		rd_data <= rd_r.fifo_out_d1;
		rd_rin <= rd_v;
		wr_rin <= wr_v;
	end process;

	rd_seq : process(rd_clk, rd_rst)
	begin
		if rd_rst = '1' then
			rd_r <= rd_reg_none;
		elsif rising_edge(rd_clk) then
			rd_r <= rd_rin;
		end if;
	end process;

	wr_seq : process(wr_clk, wr_rst)
	begin
		if wr_rst = '1' then
			wr_r <= wr_reg_none;
		elsif rising_edge(wr_clk) then
			wr_r <= wr_rin;
		end if;
	end process;

	-- Active low sync resets for the fifo
	rd_rstn <= not(rd_rst);
	wr_rstn <= not(wr_rst);

	fifo0: syncfifo_2p
		generic map(
			tech  => tech,
			abits => abits,
			dbits => 10
		)
		port map(
			rclk   	=> rd_clk,
			rrstn   => rd_rstn,
			wrstn   => wr_rstn,
			renable	=> rd_en,
			rfull  	=> open,
			rempty 	=> open,
			aempty  => open,
			rusedw 	=> rdusedw_int,
			dataout	=> fifo_out,
			wclk   	=> wr_clk,
			write  	=> wr_en,
			wfull  	=> open,
			afull   => open,
			wempty 	=> open,
			wusedw 	=> wrusedw_int,
			datain 	=> wr_r.fifo_in_d1
    	);

end architecture ;
