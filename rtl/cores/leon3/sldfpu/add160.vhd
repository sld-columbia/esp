-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	add160b
-- File:	add160b.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	160 bits, 40 operands Carry Save Adder
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.bw.all;

entity add160b is
  
  port (
    add : in  add160b_in_type;
    css : out std_logic_vector(159 downto 0);  --Carry save S
    csc : out std_logic_vector(159 downto 0));  --Carry save C

end add160b;


architecture rtl of add160b is

  signal a : csa40op_a_type;
  signal x  : compressor42_mat;
  signal ci : csa40op_c_type;
  signal co : csa40op_c_type;
  signal S : csa40op_c_type;
  signal C : csa40op_c_type;
  
begin  -- rtl

  -- Carry Save Adder array.
  input_routing: for i in 159 downto 0 generate

    -- group bits from the same column i
    bit_routign: for j in 39 downto 0 generate
      a(i)(j) <= add(j)(i);
    end generate bit_routign;

    -- compressors from 0 to 9 are always at
    -- level 0 in the tree
    x(i)(0)  <= a(i)(39 downto 36);
    x(i)(1)  <= a(i)(35 downto 32);
    x(i)(2)  <= a(i)(31 downto 28);
    x(i)(3)  <= a(i)(27 downto 24);
    x(i)(4)  <= a(i)(23 downto 20);
    x(i)(5)  <= a(i)(19 downto 16);
    x(i)(6)  <= a(i)(15 downto 12);
    x(i)(7) <= a(i)(11 downto 8);
    x(i)(8) <= a(i)(7 downto 4);
    x(i)(9) <= a(i)(3 downto 0);
    l0_i0: if i=0 generate
      ci(i)(0 to 9) <= (others => '0'); --no global carry in
    end generate l0_i0;
    l0_i: if i>0 generate
      ci(i)(0 to 9) <= co(i-1)(0 to 9);
    end generate l0_i;
    
    -- compressors from 10 to 14 are always at
    -- level 1 in the tree
    l1_i0: if i=0 generate
      x(i)(10) <= '0' & S(0)(0) & '0' & S(0)(1);
      x(i)(11) <= '0' & S(0)(2) & '0' & S(0)(3);
      x(i)(12) <= '0' & S(0)(4) & '0' & S(0)(5);
      x(i)(13) <= '0' & S(0)(6) & '0' & S(0)(7);
      x(i)(14) <= '0' & S(0)(8) & '0' & S(0)(9);
      ci(i)(10 to 14) <= (others => '0'); --no global carry in
    end generate l1_i0;
    l1_i: if i>0 generate
      x(i)(10) <= C(i-1)(0) & S(i)(0) & C(i-1)(1) & S(i)(1);
      x(i)(11) <= C(i-1)(2) & S(i)(2) & C(i-1)(3) & S(i)(3);
      x(i)(12) <= C(i-1)(4) & S(i)(4) & C(i-1)(5) & S(i)(5);
      x(i)(13) <= C(i-1)(6) & S(i)(6) & C(i-1)(7) & S(i)(7);
      x(i)(14) <= C(i-1)(8) & S(i)(8) & C(i-1)(9) & S(i)(9);
      ci(i)(10 to 14) <= co(i-1)(10 to 14);
    end generate l1_i;

    -- compressors from 15 to 16 are always at
    -- level 2 in the tree
    l2_i0: if i=0 generate
      x(i)(15) <= '0' & S(i)(10) & '0' & S(i)(11);
      x(i)(16) <= '0' & S(i)(12) & '0' & S(i)(13);
      ci(i)(15 to 16) <= (others => '0'); --no global carry in
    end generate l2_i0;
    l2_i: if i>0 generate
      x(i)(15) <= C(i-1)(10) & S(i)(10) & C(i-1)(11) & S(i)(11);
      x(i)(16) <= C(i-1)(12) & S(i)(12) & C(i-1)(13) & S(i)(13);
      ci(i)(15 to 16) <= co(i-1)(15 to 16);
    end generate l2_i;

    -- compressor 17 is always at
    -- level 3 in the tree
    l3_i0: if i=0 generate
      x(i)(17) <= '0' & S(i)(15) & '0' & S(i)(16);
      ci(i)(17) <= '0'; --no global carry in      
    end generate l3_i0;
    l3_i: if i>0 generate
      x(i)(17) <= C(i-1)(15) & S(i)(15) & C(i-1)(16) & S(i)(16);
      ci(i)(17) <= co(i-1)(17); --no global carry in      
    end generate l3_i;

    -- compressor 18 is the last level of the tree
    l4_i0: if i=0 generate
      x(i)(18) <= '0' & S(i)(17) & '0' & S(i)(14);
      ci(i)(18) <= '0';
    end generate l4_i0;
    l4_i: if i>0 generate
      x(i)(18) <= C(i-1)(17) & S(i)(17) & C(i-1)(14) & S(i)(14);
      ci(i)(18) <= co(i-1)(18);
    end generate l4_i;
  end generate input_routing;
    

  -- Compressors instantiation
  ct: for i in 0 to 159 generate
    csa: for j in 0 to 18 generate
      compressor42_1_7_i: compressor42
        port map (
          x  => x(i)(j),
          ci => ci(i)(j),
          S  => S(i)(j),
          C  => C(i)(j),
          co => co(i)(j));
    end generate csa;
  end generate ct;
  
  -- Ouput in Carry Save form
  carry_save: for i in 159 downto 0 generate
    csc(i) <= C(i)(18);
    css(i) <= S(i)(18);
  end generate carry_save;

end rtl;
