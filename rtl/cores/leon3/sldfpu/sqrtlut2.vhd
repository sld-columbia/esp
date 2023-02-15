-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sqrtlut2
-- File:	sqrtlut2.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	SQRT Look-up table to reduce number of iterations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity sqrtlut2 is
  
  port (
    addr    : in  std_logic_vector(5 downto 0);
    romdata : out std_logic_vector(19 downto 0));

end sqrtlut2;

architecture lu of sqrtlut2 is

begin  -- lu

  lut : process (addr)
  begin
    case conv_integer(addr) is
    when 0 => romdata <= std_logic_vector(to_unsigned(16#ff2f1#, 20));
    when 1 => romdata <= std_logic_vector(to_unsigned(16#f7710#, 20));
    when 2 => romdata <= std_logic_vector(to_unsigned(16#efc21#, 20));
    when 3 => romdata <= std_logic_vector(to_unsigned(16#e8224#, 20));
    when 4 => romdata <= std_logic_vector(to_unsigned(16#e1410#, 20));
    when 5 => romdata <= std_logic_vector(to_unsigned(16#da6c4#, 20));
    when 6 => romdata <= std_logic_vector(to_unsigned(16#d3a40#, 20));
    when 7 => romdata <= std_logic_vector(to_unsigned(16#cce84#, 20));
    when 8 => romdata <= std_logic_vector(to_unsigned(16#c6e39#, 20));
    when 9 => romdata <= std_logic_vector(to_unsigned(16#c03f9#, 20));
    when 10 => romdata <= std_logic_vector(to_unsigned(16#ba504#, 20));
    when 11 => romdata <= std_logic_vector(to_unsigned(16#b46b1#, 20));
    when 12 => romdata <= std_logic_vector(to_unsigned(16#ae900#, 20));
    when 13 => romdata <= std_logic_vector(to_unsigned(16#a9640#, 20));
    when 14 => romdata <= std_logic_vector(to_unsigned(16#a39c1#, 20));
    when 15 => romdata <= std_logic_vector(to_unsigned(16#9e811#, 20));
    when 16 => romdata <= std_logic_vector(to_unsigned(16#996e1#, 20));
    when 17 => romdata <= std_logic_vector(to_unsigned(16#94631#, 20));
    when 18 => romdata <= std_logic_vector(to_unsigned(16#8f601#, 20));
    when 19 => romdata <= std_logic_vector(to_unsigned(16#8a651#, 20));
    when 20 => romdata <= std_logic_vector(to_unsigned(16#86100#, 20));
    when 21 => romdata <= std_logic_vector(to_unsigned(16#81240#, 20));
    when 22 => romdata <= std_logic_vector(to_unsigned(16#7cdc1#, 20));
    when 23 => romdata <= std_logic_vector(to_unsigned(16#789a4#, 20));
    when 24 => romdata <= std_logic_vector(to_unsigned(16#73c44#, 20));
    when 25 => romdata <= std_logic_vector(to_unsigned(16#70290#, 20));
    when 26 => romdata <= std_logic_vector(to_unsigned(16#6bf99#, 20));
    when 27 => romdata <= std_logic_vector(to_unsigned(16#67d04#, 20));
    when 28 => romdata <= std_logic_vector(to_unsigned(16#63ad1#, 20));
    when 29 => romdata <= std_logic_vector(to_unsigned(16#60261#, 20));
    when 30 => romdata <= std_logic_vector(to_unsigned(16#5c0e4#, 20));
    when 31 => romdata <= std_logic_vector(to_unsigned(16#58910#, 20));
    when 32 => romdata <= std_logic_vector(to_unsigned(16#55184#, 20));
    when 33 => romdata <= std_logic_vector(to_unsigned(16#51a40#, 20));
    when 34 => romdata <= std_logic_vector(to_unsigned(16#4e344#, 20));
    when 35 => romdata <= std_logic_vector(to_unsigned(16#4ac90#, 20));
    when 36 => romdata <= std_logic_vector(to_unsigned(16#47624#, 20));
    when 37 => romdata <= std_logic_vector(to_unsigned(16#44000#, 20));
    when 38 => romdata <= std_logic_vector(to_unsigned(16#41319#, 20));
    when 39 => romdata <= std_logic_vector(to_unsigned(16#3dd79#, 20));
    when 40 => romdata <= std_logic_vector(to_unsigned(16#3b100#, 20));
    when 41 => romdata <= std_logic_vector(to_unsigned(16#37be4#, 20));
    when 42 => romdata <= std_logic_vector(to_unsigned(16#34fd9#, 20));
    when 43 => romdata <= std_logic_vector(to_unsigned(16#31b41#, 20));
    when 44 => romdata <= std_logic_vector(to_unsigned(16#2efa4#, 20));
    when 45 => romdata <= std_logic_vector(to_unsigned(16#2c439#, 20));
    when 46 => romdata <= std_logic_vector(to_unsigned(16#29900#, 20));
    when 47 => romdata <= std_logic_vector(to_unsigned(16#26df9#, 20));
    when 48 => romdata <= std_logic_vector(to_unsigned(16#24324#, 20));
    when 49 => romdata <= std_logic_vector(to_unsigned(16#21881#, 20));
    when 50 => romdata <= std_logic_vector(to_unsigned(16#1f689#, 20));
    when 51 => romdata <= std_logic_vector(to_unsigned(16#1cc40#, 20));
    when 52 => romdata <= std_logic_vector(to_unsigned(16#1a229#, 20));
    when 53 => romdata <= std_logic_vector(to_unsigned(16#180a1#, 20));
    when 54 => romdata <= std_logic_vector(to_unsigned(16#156e4#, 20));
    when 55 => romdata <= std_logic_vector(to_unsigned(16#135a4#, 20));
    when 56 => romdata <= std_logic_vector(to_unsigned(16#10c41#, 20));
    when 57 => romdata <= std_logic_vector(to_unsigned(16#0eb49#, 20));
    when 58 => romdata <= std_logic_vector(to_unsigned(16#0c240#, 20));
    when 59 => romdata <= std_logic_vector(to_unsigned(16#0a190#, 20));
    when 60 => romdata <= std_logic_vector(to_unsigned(16#08100#, 20));
    when 61 => romdata <= std_logic_vector(to_unsigned(16#06090#, 20));
    when 62 => romdata <= std_logic_vector(to_unsigned(16#04040#, 20));
    when 63 => romdata <= std_logic_vector(to_unsigned(16#02010#, 20));
    when others => romdata <= (others => '-');
    end case;
  end process;

end lu;
