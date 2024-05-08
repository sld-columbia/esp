-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity:   add160b
-- File:  add160b.vhd
-- Author:  Paolo Mantovani - SLD @ Columbia University
-- Description:  160 bits, 40 operands Carry Save Adder
------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use work.bw.all;

entity add160b is
  port (
    add : in    add160b_in_type;
    css : out   std_logic_vector(159 downto 0); -- Carry save S
    csc : out   std_logic_vector(159 downto 0)  -- Carry save C
  );
end entity add160b;

architecture rtl of add160b is

  signal a  : csa40op_a_type;
  signal x  : compressor42_mat;
  signal ci : csa40op_c_type;
  signal co : csa40op_c_type;
  signal s  : csa40op_c_type;
  signal c  : csa40op_c_type;

begin  -- rtl

  -- Carry Save Adder array.

  input_routing : for i in 159 downto 0 generate

    -- group bits from the same column i

    bit_routign : for j in 39 downto 0 generate
      a(i)(j) <= add(j)(i);
    end generate bit_routign;

    -- compressors from 0 to 9 are always at
    -- level 0 in the tree
    x(i)(0) <= a(i)(39 downto 36);
    x(i)(1) <= a(i)(35 downto 32);
    x(i)(2) <= a(i)(31 downto 28);
    x(i)(3) <= a(i)(27 downto 24);
    x(i)(4) <= a(i)(23 downto 20);
    x(i)(5) <= a(i)(19 downto 16);
    x(i)(6) <= a(i)(15 downto 12);
    x(i)(7) <= a(i)(11 downto 8);
    x(i)(8) <= a(i)(7 downto 4);
    x(i)(9) <= a(i)(3 downto 0);

    l0_i0 : if i=0 generate
      ci(i)(0 to 9) <= (others => '0'); -- no global carry in
    end generate l0_i0;

    l0_i : if i>0 generate
      ci(i)(0 to 9) <= co(i - 1)(0 to 9);
    end generate l0_i;

    -- compressors from 10 to 14 are always at
    -- level 1 in the tree

    l1_i0 : if i=0 generate
      x(i)(10)        <= '0' & s(0)(0) & '0' & s(0)(1);
      x(i)(11)        <= '0' & s(0)(2) & '0' & s(0)(3);
      x(i)(12)        <= '0' & s(0)(4) & '0' & s(0)(5);
      x(i)(13)        <= '0' & s(0)(6) & '0' & s(0)(7);
      x(i)(14)        <= '0' & s(0)(8) & '0' & s(0)(9);
      ci(i)(10 to 14) <= (others => '0'); -- no global carry in
    end generate l1_i0;

    l1_i : if i>0 generate
      x(i)(10)        <= c(i - 1)(0) & s(i)(0) & c(i - 1)(1) & s(i)(1);
      x(i)(11)        <= c(i - 1)(2) & s(i)(2) & c(i - 1)(3) & s(i)(3);
      x(i)(12)        <= c(i - 1)(4) & s(i)(4) & c(i - 1)(5) & s(i)(5);
      x(i)(13)        <= c(i - 1)(6) & s(i)(6) & c(i - 1)(7) & s(i)(7);
      x(i)(14)        <= c(i - 1)(8) & s(i)(8) & c(i - 1)(9) & s(i)(9);
      ci(i)(10 to 14) <= co(i - 1)(10 to 14);
    end generate l1_i;

    -- compressors from 15 to 16 are always at
    -- level 2 in the tree

    l2_i0 : if i=0 generate
      x(i)(15)        <= '0' & s(i)(10) & '0' & s(i)(11);
      x(i)(16)        <= '0' & s(i)(12) & '0' & s(i)(13);
      ci(i)(15 to 16) <= (others => '0'); -- no global carry in
    end generate l2_i0;

    l2_i : if i>0 generate
      x(i)(15)        <= c(i - 1)(10) & s(i)(10) & c(i - 1)(11) & s(i)(11);
      x(i)(16)        <= c(i - 1)(12) & s(i)(12) & c(i - 1)(13) & s(i)(13);
      ci(i)(15 to 16) <= co(i - 1)(15 to 16);
    end generate l2_i;

    -- compressor 17 is always at
    -- level 3 in the tree

    l3_i0 : if i=0 generate
      x(i)(17)  <= '0' & s(i)(15) & '0' & s(i)(16);
      ci(i)(17) <= '0'; -- no global carry in
    end generate l3_i0;

    l3_i : if i>0 generate
      x(i)(17)  <= c(i - 1)(15) & s(i)(15) & c(i - 1)(16) & s(i)(16);
      ci(i)(17) <= co(i - 1)(17); -- no global carry in
    end generate l3_i;

    -- compressor 18 is the last level of the tree

    l4_i0 : if i=0 generate
      x(i)(18)  <= '0' & s(i)(17) & '0' & s(i)(14);
      ci(i)(18) <= '0';
    end generate l4_i0;

    l4_i : if i>0 generate
      x(i)(18)  <= c(i - 1)(17) & s(i)(17) & c(i - 1)(14) & s(i)(14);
      ci(i)(18) <= co(i - 1)(18);
    end generate l4_i;

  end generate input_routing;

  -- Compressors instantiation

  ct : for i in 0 to 159 generate

    csa : for j in 0 to 18 generate

      compressor42_1_7_i : component compressor42
        port map (
          x  => x(i)(j),
          ci => ci(i)(j),
          s  => s(i)(j),
          c  => c(i)(j),
          co => co(i)(j)
        );

    end generate csa;

  end generate ct;

  -- Ouput in Carry Save form

  carry_save : for i in 159 downto 0 generate
    csc(i) <= c(i)(18);
    css(i) <= s(i)(18);
  end generate carry_save;

end architecture rtl;
