-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sqrtlut
-- File:	sqrtlut.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	SQRT Look-up table to reduce number of iterations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity sqrtlut is
  
  port (
    addr    : in  std_logic_vector(5 downto 0);
    romdata : out std_logic_vector(9 downto 0));

end sqrtlut;

architecture lu of sqrtlut is

begin  -- lu

  lut : process (addr)
  begin
    case conv_integer(addr) is
    when 0 => romdata <= std_logic_vector(to_unsigned(16#1a7#, 10));
    when 1 => romdata <= std_logic_vector(to_unsigned(16#19c#, 10));
    when 2 => romdata <= std_logic_vector(to_unsigned(16#191#, 10));
    when 3 => romdata <= std_logic_vector(to_unsigned(16#186#, 10));
    when 4 => romdata <= std_logic_vector(to_unsigned(16#17c#, 10));
    when 5 => romdata <= std_logic_vector(to_unsigned(16#172#, 10));
    when 6 => romdata <= std_logic_vector(to_unsigned(16#168#, 10));
    when 7 => romdata <= std_logic_vector(to_unsigned(16#15e#, 10));
    when 8 => romdata <= std_logic_vector(to_unsigned(16#155#, 10));
    when 9 => romdata <= std_logic_vector(to_unsigned(16#14b#, 10));
    when 10 => romdata <= std_logic_vector(to_unsigned(16#142#, 10));
    when 11 => romdata <= std_logic_vector(to_unsigned(16#139#, 10));
    when 12 => romdata <= std_logic_vector(to_unsigned(16#130#, 10));
    when 13 => romdata <= std_logic_vector(to_unsigned(16#128#, 10));
    when 14 => romdata <= std_logic_vector(to_unsigned(16#11f#, 10));
    when 15 => romdata <= std_logic_vector(to_unsigned(16#117#, 10));
    when 16 => romdata <= std_logic_vector(to_unsigned(16#10f#, 10));
    when 17 => romdata <= std_logic_vector(to_unsigned(16#107#, 10));
    when 18 => romdata <= std_logic_vector(to_unsigned(16#0ff#, 10));
    when 19 => romdata <= std_logic_vector(to_unsigned(16#0f7#, 10));
    when 20 => romdata <= std_logic_vector(to_unsigned(16#0f0#, 10));
    when 21 => romdata <= std_logic_vector(to_unsigned(16#0e8#, 10));
    when 22 => romdata <= std_logic_vector(to_unsigned(16#0e1#, 10));
    when 23 => romdata <= std_logic_vector(to_unsigned(16#0da#, 10));
    when 24 => romdata <= std_logic_vector(to_unsigned(16#0d2#, 10));
    when 25 => romdata <= std_logic_vector(to_unsigned(16#0cc#, 10));
    when 26 => romdata <= std_logic_vector(to_unsigned(16#0c5#, 10));
    when 27 => romdata <= std_logic_vector(to_unsigned(16#0be#, 10));
    when 28 => romdata <= std_logic_vector(to_unsigned(16#0b7#, 10));
    when 29 => romdata <= std_logic_vector(to_unsigned(16#0b1#, 10));
    when 30 => romdata <= std_logic_vector(to_unsigned(16#0aa#, 10));
    when 31 => romdata <= std_logic_vector(to_unsigned(16#0a4#, 10));
    when 32 => romdata <= std_logic_vector(to_unsigned(16#09e#, 10));
    when 33 => romdata <= std_logic_vector(to_unsigned(16#098#, 10));
    when 34 => romdata <= std_logic_vector(to_unsigned(16#092#, 10));
    when 35 => romdata <= std_logic_vector(to_unsigned(16#08c#, 10));
    when 36 => romdata <= std_logic_vector(to_unsigned(16#086#, 10));
    when 37 => romdata <= std_logic_vector(to_unsigned(16#080#, 10));
    when 38 => romdata <= std_logic_vector(to_unsigned(16#07b#, 10));
    when 39 => romdata <= std_logic_vector(to_unsigned(16#075#, 10));
    when 40 => romdata <= std_logic_vector(to_unsigned(16#070#, 10));
    when 41 => romdata <= std_logic_vector(to_unsigned(16#06a#, 10));
    when 42 => romdata <= std_logic_vector(to_unsigned(16#065#, 10));
    when 43 => romdata <= std_logic_vector(to_unsigned(16#05f#, 10));
    when 44 => romdata <= std_logic_vector(to_unsigned(16#05a#, 10));
    when 45 => romdata <= std_logic_vector(to_unsigned(16#055#, 10));
    when 46 => romdata <= std_logic_vector(to_unsigned(16#050#, 10));
    when 47 => romdata <= std_logic_vector(to_unsigned(16#04b#, 10));
    when 48 => romdata <= std_logic_vector(to_unsigned(16#046#, 10));
    when 49 => romdata <= std_logic_vector(to_unsigned(16#041#, 10));
    when 50 => romdata <= std_logic_vector(to_unsigned(16#03d#, 10));
    when 51 => romdata <= std_logic_vector(to_unsigned(16#038#, 10));
    when 52 => romdata <= std_logic_vector(to_unsigned(16#033#, 10));
    when 53 => romdata <= std_logic_vector(to_unsigned(16#02f#, 10));
    when 54 => romdata <= std_logic_vector(to_unsigned(16#02a#, 10));
    when 55 => romdata <= std_logic_vector(to_unsigned(16#026#, 10));
    when 56 => romdata <= std_logic_vector(to_unsigned(16#021#, 10));
    when 57 => romdata <= std_logic_vector(to_unsigned(16#01d#, 10));
    when 58 => romdata <= std_logic_vector(to_unsigned(16#018#, 10));
    when 59 => romdata <= std_logic_vector(to_unsigned(16#014#, 10));
    when 60 => romdata <= std_logic_vector(to_unsigned(16#010#, 10));
    when 61 => romdata <= std_logic_vector(to_unsigned(16#00c#, 10));
    when 62 => romdata <= std_logic_vector(to_unsigned(16#008#, 10));
    when 63 => romdata <= std_logic_vector(to_unsigned(16#004#, 10));
    when others => romdata <= (others => '-');
    end case;
  end process;

end lu;
