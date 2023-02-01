-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	ppadd
-- File:	ppadd.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Parallel Prefix 2^logn bits adder truncated at n bits.
--              Logic synthesis will trimm unconnected nets
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.basic.all;

entity ppadd is

  generic (
    n    : integer := 56;  --operands width
    logn : integer := 6);  --ceiling of log2(operands width)
  port (
    add0_in   : in  std_logic_vector(n-1 downto 0);
    add1_in   : in  std_logic_vector(n-1 downto 0);
    carry_in  : in  std_logic;
    sum_out   : out std_logic_vector(n-1 downto 0);
    carry_out : out std_logic);

end ppadd;

architecture behav of ppadd is


  --many signals are not connected. They will be trimmed during logic synth.
  signal add0, add1 : std_logic_vector((2**logn)-1 downto 0);
  type vect_levels is array (0 to logn) of std_logic_vector((2**logn)-1 downto 0);
  signal pvectl, gvectl : vect_levels;
  signal cvect : std_logic_vector((2**logn)-1 downto 0);

begin

  assign_add01: process (add0_in, add1_in)
    variable a0, a1 : std_logic_vector((2**logn)-1 downto 0);
  begin  -- process assign_add01
    a0 := (others => '0');
    a1 := (others => '0');
    a0((2**logn)-1 downto n) := (others => add0_in(n-1));
    a0(n-1 downto 0) := add0_in;
    a1(2**logn-1 downto n) := (others => add1_in(n-1));
    a1(n-1 downto 0) := add1_in;

    add0 <= a0;
    add1 <= a1;
  end process assign_add01;
  

  pg_generate: for i in 0 to (2**logn)-1 generate
    pg_i: pg
      port map (
        a => add0(i),
        b => add1(i),
        g => gvectl(0)(i),
        p => pvectl(0)(i));
  end generate pg_generate;


  carry_dot: for i in 0 to logn-1 generate
    levels: for j in 0 to (2**(logn-i-1)-1) generate
      
      j0: if j = 0 generate
        cvect((2**i-1) + j*(2**(i+1))) <= gvectl(i)(2*j) or (pvectl(i)(2*j) and carry_in);
      end generate j0;
      jm0: if j /= 0 generate
        cvect((2**i-1) + j*(2**(i+1))) <= gvectl(i)(2*j) or (pvectl(i)(2*j) and cvect(j*(2**(i+1))-1));
      end generate jm0;

      dot_l1: dot
        port map (
          gi1 => gvectl(i)((2*j)+1),
          pi1 => pvectl(i)((2*j)+1),
          gi2 => gvectl(i)(2*j),
          pi2 => pvectl(i)(2*j),
          go  => gvectl(i+1)(j),
          po  => pvectl(i+1)(j));
      
    end generate levels;
  end generate carry_dot;

  cvect((2**logn)-1) <= gvectl(logn)(0) or (pvectl(logn)(0) and carry_in);


-------------------------------------------------------------------------------

  carry_out <= cvect(n-1);
  sum_out(0) <= pvectl(0)(0) xor carry_in;
  
  s_out: for i in 1 to (n-1) generate
    sum_out(i) <= pvectl(0)(i) xor cvect(i-1);
  end generate s_out;
  
end behav;





