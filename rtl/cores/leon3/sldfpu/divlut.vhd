-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	divlut
-- File:	divlut.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Divider Look-up table to reduce number of iterations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity divlut is
  
  port (
    addr    : in  std_logic_vector(5 downto 0);
    romdata : out std_logic_vector(9 downto 0));

end divlut;

architecture lu of divlut is

begin  -- lu

  lut : process (addr)
  begin
    case conv_integer(addr) is
    when 0 => romdata <= std_logic_vector(to_unsigned(16#3f8#, 10));
    when 1 => romdata <= std_logic_vector(to_unsigned(16#3d9#, 10));
    when 2 => romdata <= std_logic_vector(to_unsigned(16#3bb#, 10));
    when 3 => romdata <= std_logic_vector(to_unsigned(16#39f#, 10));
    when 4 => romdata <= std_logic_vector(to_unsigned(16#383#, 10));
    when 5 => romdata <= std_logic_vector(to_unsigned(16#367#, 10));
    when 6 => romdata <= std_logic_vector(to_unsigned(16#34d#, 10));
    when 7 => romdata <= std_logic_vector(to_unsigned(16#333#, 10));
    when 8 => romdata <= std_logic_vector(to_unsigned(16#31a#, 10));
    when 9 => romdata <= std_logic_vector(to_unsigned(16#301#, 10));
    when 10 => romdata <= std_logic_vector(to_unsigned(16#2e9#, 10));
    when 11 => romdata <= std_logic_vector(to_unsigned(16#2d2#, 10));
    when 12 => romdata <= std_logic_vector(to_unsigned(16#2bb#, 10));
    when 13 => romdata <= std_logic_vector(to_unsigned(16#2a5#, 10));
    when 14 => romdata <= std_logic_vector(to_unsigned(16#28f#, 10));
    when 15 => romdata <= std_logic_vector(to_unsigned(16#27a#, 10));
    when 16 => romdata <= std_logic_vector(to_unsigned(16#265#, 10));
    when 17 => romdata <= std_logic_vector(to_unsigned(16#251#, 10));
    when 18 => romdata <= std_logic_vector(to_unsigned(16#23d#, 10));
    when 19 => romdata <= std_logic_vector(to_unsigned(16#22a#, 10));
    when 20 => romdata <= std_logic_vector(to_unsigned(16#218#, 10));
    when 21 => romdata <= std_logic_vector(to_unsigned(16#205#, 10));
    when 22 => romdata <= std_logic_vector(to_unsigned(16#1f3#, 10));
    when 23 => romdata <= std_logic_vector(to_unsigned(16#1e2#, 10));
    when 24 => romdata <= std_logic_vector(to_unsigned(16#1d1#, 10));
    when 25 => romdata <= std_logic_vector(to_unsigned(16#1c0#, 10));
    when 26 => romdata <= std_logic_vector(to_unsigned(16#1b0#, 10));
    when 27 => romdata <= std_logic_vector(to_unsigned(16#1a0#, 10));
    when 28 => romdata <= std_logic_vector(to_unsigned(16#190#, 10));
    when 29 => romdata <= std_logic_vector(to_unsigned(16#181#, 10));
    when 30 => romdata <= std_logic_vector(to_unsigned(16#172#, 10));
    when 31 => romdata <= std_logic_vector(to_unsigned(16#163#, 10));
    when 32 => romdata <= std_logic_vector(to_unsigned(16#155#, 10));
    when 33 => romdata <= std_logic_vector(to_unsigned(16#147#, 10));
    when 34 => romdata <= std_logic_vector(to_unsigned(16#139#, 10));
    when 35 => romdata <= std_logic_vector(to_unsigned(16#12b#, 10));
    when 36 => romdata <= std_logic_vector(to_unsigned(16#11e#, 10));
    when 37 => romdata <= std_logic_vector(to_unsigned(16#111#, 10));
    when 38 => romdata <= std_logic_vector(to_unsigned(16#105#, 10));
    when 39 => romdata <= std_logic_vector(to_unsigned(16#0f8#, 10));
    when 40 => romdata <= std_logic_vector(to_unsigned(16#0ec#, 10));
    when 41 => romdata <= std_logic_vector(to_unsigned(16#0e0#, 10));
    when 42 => romdata <= std_logic_vector(to_unsigned(16#0d4#, 10));
    when 43 => romdata <= std_logic_vector(to_unsigned(16#0c8#, 10));
    when 44 => romdata <= std_logic_vector(to_unsigned(16#0bd#, 10));
    when 45 => romdata <= std_logic_vector(to_unsigned(16#0b2#, 10));
    when 46 => romdata <= std_logic_vector(to_unsigned(16#0a7#, 10));
    when 47 => romdata <= std_logic_vector(to_unsigned(16#09c#, 10));
    when 48 => romdata <= std_logic_vector(to_unsigned(16#092#, 10));
    when 49 => romdata <= std_logic_vector(to_unsigned(16#087#, 10));
    when 50 => romdata <= std_logic_vector(to_unsigned(16#07d#, 10));
    when 51 => romdata <= std_logic_vector(to_unsigned(16#073#, 10));
    when 52 => romdata <= std_logic_vector(to_unsigned(16#069#, 10));
    when 53 => romdata <= std_logic_vector(to_unsigned(16#060#, 10));
    when 54 => romdata <= std_logic_vector(to_unsigned(16#056#, 10));
    when 55 => romdata <= std_logic_vector(to_unsigned(16#04d#, 10));
    when 56 => romdata <= std_logic_vector(to_unsigned(16#044#, 10));
    when 57 => romdata <= std_logic_vector(to_unsigned(16#03b#, 10));
    when 58 => romdata <= std_logic_vector(to_unsigned(16#032#, 10));
    when 59 => romdata <= std_logic_vector(to_unsigned(16#029#, 10));
    when 60 => romdata <= std_logic_vector(to_unsigned(16#021#, 10));
    when 61 => romdata <= std_logic_vector(to_unsigned(16#018#, 10));
    when 62 => romdata <= std_logic_vector(to_unsigned(16#010#, 10));
    when 63 => romdata <= std_logic_vector(to_unsigned(16#008#, 10));
    when others => romdata <= (others => '-');
    end case;
  end process;

end lu;
