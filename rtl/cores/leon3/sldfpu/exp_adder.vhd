-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity:      exp_adder
-- File:	exp_adder.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Exponents adder for floating point multiplier and SQRT
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.basic.all;

entity exp_adder is
  
  port (
    clk      : in  std_ulogic;
    rst      : in  std_ulogic;
    sub      : in  std_ulogic;
    sqrt     : in  std_ulogic;
    exp_odd  : in  std_ulogic;
    exp0     : in  std_logic_vector(10 downto 0);
    exp1     : in  std_logic_vector(10 downto 0);
    double   : in  std_ulogic;
    man0_ldz : in  std_logic_vector(5 downto 0);
    man1_ldz : in  std_logic_vector(5 downto 0);
    in0_nstd : in  std_ulogic;
    in1_nstd : in  std_ulogic;
    exp      : out std_logic_vector(10 downto 0);
    expp1    : out std_logic_vector(10 downto 0);
    expm1    : out std_logic_vector(10 downto 0);
    ovf      : out std_ulogic;
    udf      : out std_ulogic;
    nstd_res : out std_ulogic);

end exp_adder;

architecture eadd of exp_adder is

  signal double_reg1, double_reg2 : std_ulogic;
  signal bias, bias_prenorm : std_logic_vector(10 downto 0);
  signal p_bias, p_bias_reg1 : std_logic_vector(10 downto 0);
  signal p_bias_m1, p_bias_m1_reg1 : std_logic_vector(10 downto 0);
  signal tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6 : std_logic_vector(10 downto 0);
  signal tmp0_reg, tmp1_reg, tmp2_reg, tmp3_reg, tmp4_reg, tmp5_reg, tmp6_reg : std_logic_vector(10 downto 0);
  signal carry : std_logic_vector(1 downto 0);
  signal carry_reg : std_ulogic;

  signal exp_in_s1 : std_logic_vector(10 downto 0);
  signal total_out_s1 : std_logic_vector(10 downto 0);
  signal sub_reg1, sub_reg2 : std_ulogic;
  signal sqrt_reg1, sqrt_reg2 : std_ulogic;
  signal nstd_sqrt_mask : std_logic_vector(10 downto 0);
  
  signal zero, expp1_zero, one, explow, expudf : std_ulogic;
  signal ones : std_logic_vector(10 downto 0);
  signal msb1, msb2, msb3, dummy, dummy2, dummy3 : std_ulogic;
  signal msb4 : std_ulogic;
  signal false_ovf : std_ulogic;
  signal false_udf : std_ulogic;

  signal nstd_adj : std_logic_vector(10 downto 0);
  signal nldz : std_logic_vector(10 downto 0);
  signal bias_cin : std_ulogic;
  signal nstd_adj_carry, nstd_adj_carry_reg1, nstd_adj_carry_reg2 : std_ulogic;
  signal in0_nstd_reg1, in0_nstd_reg2, in1_nstd_reg1, in1_nstd_reg2 : std_ulogic;
  signal exp0_msb, exp0_msb_reg1, exp0_msb_reg2 : std_ulogic;
  signal div_nstd1_ovf : std_ulogic;

  constant expmax : std_logic_vector(10 downto 0) := "11111111110";

begin  -- eadd

  -- Output is not registered here.
  nstd_sqrt_mask <= "01111111111" when (double_reg2 and in0_nstd_reg2) = '1' else "11111111111";
  exp <= tmp2_reg when sqrt_reg2 = '0' else (tmp5_reg and nstd_sqrt_mask);
  expp1 <= tmp4_reg;                    --No need for exo + 1 with SQRT!
  expm1 <= tmp6_reg and nstd_sqrt_mask; --SQRT may need exp - 1;

  udf_ovf: process (double_reg2, msb1, msb3, msb4, one, sqrt_reg2, explow,
                    sub_reg2, in0_nstd_reg2, in1_nstd_reg2, false_udf, div_nstd1_ovf)
  begin  -- process udf_ovf
    if (sub_reg2 and in0_nstd_reg2 and in1_nstd_reg2) = '1' then  --no under nor overflow
        udf <= '0';
        ovf <= '0';
    elsif sqrt_reg2 = '1' then     --SQRT cannot overflow, nor underflow.
      udf <= '0';
      ovf <= '0';
    else
      udf <= (explow and msb1 and (not msb3) and (not false_udf));  --exp <= -52
      if double_reg2 = '1' then
        ovf <= (not(msb1) and (msb3 or one)) or div_nstd1_ovf;
      else
        ovf <= (not(msb1) and (msb4 or one)) or div_nstd1_ovf;
      end if;
    end if;
  end process udf_ovf;
  --when exp is negative and at least -54 (-25) it could be subnormal; when it's
  --at least -52 (-23) it is certainly a subnormal.
  nstd: process (double_reg2, msb1, carry_reg, msb2, msb3, msb4, zero, expudf, false_udf)
  begin  -- process nstd
    if double_reg2 = '1' then
      nstd_res <= (msb1 and (not carry_reg) and msb2 and (not expudf) and (not false_udf))
                  or (zero and (msb1 or (not msb3)));  --needed when overflow with exp_max + 1 = 0!!!
    else
      nstd_res <= (msb1 and (not carry_reg) and msb2 and (not expudf) and (not false_udf))
                  or (zero and (msb1 or (not msb4)));  --needed when overflow with exp_max + 1 = 0!!!
    end if;
  end process nstd;

  -- When exp0 msb is '1' and operand1 is subnormal, then division overflows.
  exp0_msb <= exp0(7) when double = '0' else exp0(10);
  -- Exponent bias
  bias_prenorm <= conv_std_logic_vector(-127,11) when double = '0' else conv_std_logic_vector(-1023,11);
  p_bias <= conv_std_logic_vector(127,11) when double = '0' else conv_std_logic_vector(1023,11);
  p_bias_m1 <= conv_std_logic_vector(126,11) when double = '0' else conv_std_logic_vector(1022,11);
  -- Adjust bias for division and multiplication when one operand is subnormal.
  -- When both are subnormal, multiplication will underflow, while division will
  -- have exponent equal to 0 (stored as +bias)
  bias_adjust: process (man0_ldz, man1_ldz, in0_nstd, in1_nstd, sub)
  begin  -- process bias_adjust
    if sub = '0' then
      if in0_nstd = '1' then
        nldz <= not ("00000" & man0_ldz);
      else
        nldz <= not ("00000" & man1_ldz);
      end if;
      bias_cin <= '1';
    else
      if in0_nstd = '1' then
        nldz <= ("00000" & man0_ldz);
        bias_cin <= '0';
      else
        nldz <= not ("00000" & man1_ldz);
        bias_cin <= '1';
      end if;
    end if;
  end process bias_adjust;

  a0 : addern generic map (
    n => 11)
    port map (
      in0    => bias_prenorm,
      in1    => nldz,
      cin    => bias_cin,
      total  => nstd_adj,
      cout   => nstd_adj_carry);
  bias <= bias_prenorm when in0_nstd = '0' and in1_nstd = '0' else nstd_adj;
  
  -- Mul Stage 1: exp = exp0 + bias
  exp_in_s1 <= exp0 when sub = '0' else exp1;
  a1 : addern generic map (
    n => 11)
    port map (
      in0    => exp_in_s1,
      in1    => bias,
      cin    => exp_odd,                --For SQRT add 1 if real exp is odd!
      total  => total_out_s1,
      cout   => carry(0));

  div_both_nstd: process (exp1, exp0, sub, man1_ldz, in0_nstd, in1_nstd)
  begin  -- process div_both_nstd
    if sub = '1' then
      if (in0_nstd and in1_nstd) = '1' then
        tmp1 <= "00000" & man1_ldz;
      else
        tmp1 <= exp0;
      end if;
    else
      tmp1 <= exp1;
    end if;
  end process div_both_nstd;

  first_add: process (total_out_s1, sub, sqrt, exp0, exp_odd)
  begin  -- process first_add
    if sub = '1' then                   -- -exp1-1
      tmp0 <= not total_out_s1;
    elsif sqrt = '1' then               -- exp0/2
      if exp0 = expmax and exp_odd = '1' then
        tmp0 <= '0' & total_out_s1(10 downto 1);
      else
        tmp0 <= total_out_s1(10) & total_out_s1(10 downto 1);
      end if;
    else                                -- exp0
      tmp0 <= total_out_s1;        
    end if;
  end process first_add;
  
  stage1: process (clk, rst)
  begin  -- process stage1
    if rst = '0' then                   -- asynchronous reset (active low)
      tmp0_reg <= (others => '0');
      tmp1_reg <= "00000000000";
      double_reg1 <= '0';
      sub_reg1 <= '0';
      sqrt_reg1 <= '0';
      in0_nstd_reg1 <= '0';
      in1_nstd_reg1 <= '0';
      p_bias_reg1 <= (others => '0');
      p_bias_m1_reg1 <= (others => '0');
      nstd_adj_carry_reg1 <= '0';
      exp0_msb_reg1 <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      tmp0_reg <= tmp0;
      tmp1_reg <= tmp1;
      double_reg1 <= double;
      sub_reg1 <= sub;
      sqrt_reg1 <= sqrt;
      in0_nstd_reg1 <= in0_nstd;
      in1_nstd_reg1 <= in1_nstd;
      p_bias_reg1 <= p_bias;
      p_bias_m1_reg1 <= p_bias_m1;
      nstd_adj_carry_reg1 <= nstd_adj_carry;
      exp0_msb_reg1 <= exp0_msb;
    end if;
  end process stage1;

  -- Mul Stage 2: exp += exp1
  a2 : addern generic map (
    n => 11)
    port map (
      in0    => tmp0_reg,
      in1    => tmp1_reg,
      cin    => '0',
      total  => tmp2,
      cout   => carry(1));
  a2_p1 : addern generic map (
    n => 11)
    port map (
      in0    => tmp0_reg,
      in1    => tmp1_reg,
      cin    => '1',
      total  => tmp4,
      cout   => dummy);

  --square root: divide exp0 by 2 then add back bias
  add_sqrt1: addern
    generic map (
      n => 11)
    port map (
      in0   => tmp0_reg,
      in1   => p_bias_reg1,
      cin   => '0',
      total => tmp5,
      cout  => dummy2);
  add_sqrt2: addern
    generic map (
      n => 11)
    port map (
      in0   => tmp0_reg,
      in1   => p_bias_m1_reg1,
      cin   => '0',
      total => tmp6,
      cout  => dummy3);

  tmp3 <= tmp0_reg;
  
  stage2: process (clk, rst)
  begin  -- process stage2
    if rst = '0' then                   -- asynchronous reset (active low)
      tmp2_reg <= "00000000000";
      tmp3_reg <= (others => '0');
      tmp4_reg <= "00000000000";
      tmp5_reg <= "00000000000";
      tmp6_reg <= "00000000000";
      carry_reg <= '0';
      double_reg2 <= '0';
      sub_reg2 <= '0';
      sqrt_reg2 <= '0';
      in0_nstd_reg2 <= '0';
      in1_nstd_reg2 <= '0';
      nstd_adj_carry_reg2 <= '0';
      exp0_msb_reg2 <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      tmp2_reg <= tmp2;
      tmp3_reg <= tmp3;
      tmp4_reg <= tmp4;
      tmp5_reg <= tmp5;
      tmp6_reg <= tmp6;
      carry_reg <= carry(1);
      double_reg2 <= double_reg1;
      sub_reg2 <= sub_reg1;
      sqrt_reg2 <= sqrt_reg1;
      in0_nstd_reg2 <= in0_nstd_reg1;
      in1_nstd_reg2 <= in1_nstd_reg1;
      nstd_adj_carry_reg2 <= nstd_adj_carry_reg1;
      exp0_msb_reg2 <= exp0_msb_reg1;
    end if;
  end process stage2;

  -- Overflow / Underflow detection
  ones <= "11111111111" when double_reg2 = '1' else "00011111111";

  zero_detect: process (tmp2_reg, tmp4_reg, double_reg2)
  begin  -- process zero_detect
    if double_reg2 = '1' then
      if tmp2_reg = "00000000000" then
        zero <= '1';
      else
        zero <= '0';
      end if;
      if tmp4_reg = "00000000000" then
        expp1_zero <= '1';
      else
        expp1_zero <= '0';
      end if;
    else
      if tmp2_reg(7 downto 0) = "00000000" then
        zero <= '1';
      else
        zero <= '0';
      end if;
      if tmp4_reg(7 downto 0) = "00000000" then
        expp1_zero <= '1';
      else
        expp1_zero <= '0';
      end if;
    end if; 
  end process zero_detect;
  one <= '1' when tmp2_reg = ones else '0';
  -- msb1 is 1 if the result of the addition in stage 1 is negative.
  -- false_ovf takes into account the carry of adjusted bias for double
  -- precision operations
  false_ovf <= nstd_adj_carry_reg2 and (in1_nstd_reg2 or in0_nstd_reg2) when sub_reg2 = '0'
               else nstd_adj_carry_reg2 and (not in1_nstd_reg2) and in0_nstd_reg2;
  false_udf <= sub_reg2 and (not in0_nstd_reg2) and in1_nstd_reg2;  --cannot underflow
  div_nstd1_ovf <= sub_reg2 and exp0_msb_reg2 and in1_nstd_reg2 and (not expp1_zero);
  msb1 <= (tmp3_reg(10) or false_ovf);
  msb2 <= tmp2_reg(10) when double_reg2 = '1' else tmp2_reg(7);
  msb3 <= carry_reg;
  msb4 <= tmp2_reg(8);

  explow_detect: process (tmp2_reg, double_reg2)
  begin  -- process explow_detect
    explow <= '0';
    expudf <= '0';
    if double_reg2 = '1' then
      if tmp2_reg(10) = '1' and tmp2_reg(9 downto 0) <= "1111001100" then
        explow <= '1';
      end if;
      if tmp2_reg(10) = '1' and tmp2_reg(9 downto 0) <= "1111001010" then
        expudf <= '1';
      end if;
    else
      if tmp2_reg(10) = '1' and tmp2_reg(9 downto 0) <= "1111101001" then
        explow <= '1';
      end if;
      if tmp2_reg(10) = '1' and tmp2_reg(9 downto 0) <= "1111100111" then
        expudf <= '1';
      end if;
    end if;
  end process explow_detect;

end eadd;
