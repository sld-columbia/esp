------------------------------------------------------------------------------
--  This file is part of Floating Point Unit design for the Leon3 processor
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
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
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity: 	booth4
-- File:	booth4.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Booth encoder radix 4
--              Given 80 bits multiplicand A and 80 bits multiplier X assign
--              40 partial products from A, -A, 2A and -2A.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

use work.bw.all;

entity booth4 is

  port (
    mc  : in  std_logic_vector(79 downto 0);
    mp  : in  std_logic_vector(79 downto 0);
    sel : out booth4_sel_type;
    A   : out std_logic_vector(159 downto 0);
    Ab  : out std_logic_vector(159 downto 0);
    A2  : out std_logic_vector(159 downto 0);
    A2b : out std_logic_vector(159 downto 0));
  
end booth4;

architecture rtl of booth4 is

  signal X : std_logic_vector(80 downto 0);
  signal test : booth4_window_type;
  signal A_i, A2_i : std_logic_vector(159 downto 0);
  
begin  -- rtl

  X <= mp & '0';

  --Unsigned booth encoding
  --A_i(159 downto 80) <= (others => '0');

  --Signed booth encoding
  A_i(159 downto 80) <= (others => mc(79));

  A_i(79 downto 0) <= mc;
  A <= A_i;
  Ab <= (not A_i) + conv_std_logic_vector(1, 160);
  A2_i <= A_i(158 downto 0) & '0';
  A2 <= A2_i;
  A2b <= (not A2_i) + conv_std_logic_vector(1, 160);


  selector: for i in 0 to 39 generate

    test(i) <= X(2*i+2 downto 2*i);
    
    encode: process (test(i))
    begin  -- process encode
      case test(i) is
--      when "000" => sel(i) <= "00001";  -- +0
        when "010" => sel(i) <= "00010";  -- +A
        when "100" => sel(i) <= "00100";  -- -2A
        when "110" => sel(i) <= "01000";  -- -A
        when "001" => sel(i) <= "00010";  -- +A
        when "011" => sel(i) <= "10000";  -- +2A
        when "101" => sel(i) <= "01000";  -- -A
--      when "111" => sel(i) <= "00000";  -- +0
        when others => sel(i) <= "00001"; -- +0
      end case;      
    end process encode;

  end generate selector;
  
end rtl;
