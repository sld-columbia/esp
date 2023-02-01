-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sdmu
-- File:	sdmu.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Square Root, Division and Multiplication Unit.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.bw.all;
use work.itsqrdiv.all;
use work.basic.all;

entity sdmu is

  port (
    clk      : in  std_ulogic;
    rst      : in  std_ulogic;
    start    : in  std_ulogic;
    opc      : in  std_logic_vector(2 downto 0);
    flush    : in  std_ulogic;
    in0      : in  std_logic_vector(63 downto 0);
    in1      : in  std_logic_vector(63 downto 0);
    man0_ldz : in  std_logic_vector(5 downto 0);
    man1_ldz : in  std_logic_vector(5 downto 0);
    in0_zero : in  std_ulogic;
    in1_zero : in  std_ulogic;
    in0_nstd : in  std_ulogic;
    in1_nstd : in  std_ulogic;
    in0_inf  : in  std_ulogic;
    in1_inf  : in  std_ulogic;
    in0_NaN  : in  std_ulogic;
    in1_NaN  : in  std_ulogic;
    in0_SNaN : in  std_ulogic;
    in1_SNaN : in  std_ulogic;
    round    : in  std_logic_vector(1 downto 0);
    result   : out std_logic_vector(63 downto 0);
    flags    : out std_logic_vector(5 downto 0));

end sdmu;

-- opcode for sdu:
-- 000/100 NOP
-- 101/001 MULD/MULS
-- 110/010 DIVD/DIVS
-- 111/011 SQRTD/SQRTS

-- flags
-- UNF | NV | OV | UF | DZ | NX

architecture rtl of sdmu is

  --divider
  signal div_cs, div_ns               : divfsm;
  signal div_addr                     : std_logic_vector(5 downto 0);
  signal div_romdata                  : std_logic_vector(9 downto 0);
  signal div_running                  : std_ulogic;
  signal sample_n, sample_d, sample_r : std_ulogic;
  signal r, n, d                      : std_logic_vector(79 downto 0);
  signal r_reg, n_reg, d_reg          : std_logic_vector(79 downto 0);
  signal q_exp_next, q_exp_prev       : std_logic_vector(10 downto 0);
  signal div_inc, div_dec, div_reset  : std_ulogic;
  signal norm_div                     : std_ulogic;
  signal man_div                      : std_logic_vector(54 downto 0);
  
  --divider exp adjust
  signal q_exp_inc : std_logic_vector(10 downto 0);
  signal exp_div   : std_logic_vector(10 downto 0);
  signal expp1_div : std_logic_vector(10 downto 0);
  signal ovf_div   : std_ulogic;
  signal udf_div   : std_ulogic;
  signal nstd_div  : std_ulogic;
  
  --square root
  signal sqrt_addr                     : std_logic_vector(5 downto 0);
  signal sqrt_romdata                  : std_logic_vector(9 downto 0);
  signal sqrt2_romdata                 : std_logic_vector(19 downto 0);
  signal sqrt_running                  : std_ulogic;
  signal rsq, rsq_reg                  : std_logic_vector(79 downto 0);
  signal sample_rsq                    : std_ulogic;
  signal bexp_isodd                    : std_ulogic;
  signal exp_odd                       : std_ulogic;
  signal sqrt                          : std_ulogic;
  signal norm_sqrt                     : std_ulogic;

  --sign
  signal s0       : std_ulogic;
  signal s1       : std_ulogic;
  signal sign_mul : std_ulogic;

  --exponent adder
  signal sub        : std_ulogic;
  signal exp0       : std_logic_vector(10 downto 0);
  signal exp1       : std_logic_vector(10 downto 0);
  signal exp        : std_logic_vector(10 downto 0);
  signal expp1      : std_logic_vector(10 downto 0);
  signal expm1      : std_logic_vector(10 downto 0);
  signal ovf_tmp    : std_ulogic;
  signal udf_tmp    : std_ulogic;
  signal nstd_res   : std_ulogic;

  --multiplier
  signal x_ext_mul   : std_logic_vector(79 downto 0);
  signal y_ext_mul   : std_logic_vector(79 downto 0);
  signal x_ext_div   : std_logic_vector(79 downto 0);
  signal y_ext_div   : std_logic_vector(79 downto 0);
  signal x_ext_sqrt  : std_logic_vector(79 downto 0);
  signal y_ext_sqrt  : std_logic_vector(79 downto 0);
  signal x_ext       : std_logic_vector(79 downto 0);
  signal y_ext       : std_logic_vector(79 downto 0);
  signal p           : std_logic_vector(159 downto 0);

  --post normalizer
  signal exp_in     : std_logic_vector(10 downto 0);
  signal expp1_in   : std_logic_vector(10 downto 0);
  signal man_in     : std_logic_vector(54 downto 0);
  signal stickys    : std_ulogic;
  signal stickyd    : std_ulogic;
  signal ovf_in     : std_ulogic;
  signal udf_in     : std_ulogic;
  signal nstd_in    : std_ulogic;
  signal double_out : std_ulogic;
  signal ovf_out    : std_ulogic;
  signal udf_out    : std_logic;
  signal nstd_out   : std_ulogic;
  signal exp_out    : std_logic_vector(10 downto 0);
  signal man_out    : std_logic_vector(51 downto 0);

  --input register
  signal start_reg : std_ulogic;
  signal in0_reg, in1_reg : std_logic_vector(63 downto 0);
  signal in0_reg1, in1_reg1 : std_logic_vector(63 downto 0);
  signal in0_reg2, in1_reg2 : std_logic_vector(63 downto 0);  
  signal double_reg, single_reg : std_ulogic;
  signal op_reg, op1_reg, op2_reg : std_logic_vector(1 downto 0);
  signal man0_ldz_reg, man0_ldz1_reg, man0_ldz2_reg : std_logic_vector(5 downto 0);
  signal man1_ldz_reg, man1_ldz1_reg, man1_ldz2_reg : std_logic_vector(5 downto 0);
  signal in0_zero_reg, in0_zero1_reg, in0_zero2_reg : std_ulogic;
  signal in1_zero_reg, in1_zero1_reg, in1_zero2_reg : std_ulogic;
  signal in0_nstd_reg, in0_nstd1_reg, in0_nstd2_reg : std_ulogic;
  signal in1_nstd_reg, in1_nstd1_reg, in1_nstd2_reg : std_ulogic;
  signal in0_inf_reg, in0_inf1_reg, in0_inf2_reg    : std_ulogic;
  signal in1_inf_reg, in1_inf1_reg, in1_inf2_reg    : std_ulogic;
  signal in0_NaN_reg, in0_NaN1_reg, in0_NaN2_reg    : std_ulogic;
  signal in1_NaN_reg, in1_NaN1_reg, in1_NaN2_reg    : std_ulogic;
  signal in0_SNaN_reg, in0_SNaN1_reg, in0_SNaN2_reg : std_ulogic;
  signal in1_SNaN_reg, in1_SNaN1_reg, in1_SNaN2_reg : std_ulogic;
  signal round_reg, round1_reg, round2_reg          : std_logic_vector(1 downto 0);

  --output register
  signal udf_o, ovf_o : std_ulogic;
  signal nan_o, nstd_o, nx_o, nv_o, dz_o : std_ulogic;
  signal product_o : std_logic_vector(63 downto 0);
  signal sign_o : std_ulogic;
  signal sample_out : std_ulogic;
  
  --exceptions
  -- UNF | NV | OV | UF | DZ | NX
  signal UNF, NV, OV, UF, DZ, NX : std_ulogic;

begin  -- rtl

  -- Input Register
  input_register: process (clk, rst)
  begin  -- process input_register
    if rst = '0' then                   -- asynchronous reset (active low)
      start_reg <= '0';
      in0_reg <= (others => '0');
      in1_reg <= (others => '0');
      in0_reg1 <= (others => '0');
      in1_reg1 <= (others => '0');
      in0_reg2 <= (others => '0');
      in1_reg2 <= (others => '0');
      op_reg <= (others => '0');
      op1_reg <= (others => '0');
      op2_reg <= (others => '0');
      double_reg <= '0';
      single_reg <= '0';
      man0_ldz_reg <= (others => '0');
      man0_ldz1_reg <= (others => '0');
      man0_ldz2_reg <= (others => '0');
      man1_ldz_reg <= (others => '0');
      man1_ldz1_reg <= (others => '0');
      man1_ldz2_reg <= (others => '0');
      in0_zero_reg <= '1';
      in0_zero1_reg <= '1';
      in0_zero2_reg <= '1';
      in1_zero_reg <= '1';
      in1_zero1_reg <= '1';
      in1_zero2_reg <= '1';
      in0_nstd_reg <= '0';
      in0_nstd1_reg <= '0';
      in0_nstd2_reg <= '0';
      in1_nstd_reg <= '0';
      in1_nstd1_reg <= '0';
      in1_nstd2_reg <= '0';
      in0_inf_reg <= '0';
      in0_inf1_reg <= '0';
      in0_inf2_reg <= '0';
      in1_inf_reg <= '0';
      in1_inf1_reg <= '0';
      in1_inf2_reg <= '0';
      in0_NaN_reg <= '0';
      in0_NaN1_reg <= '0';
      in0_NaN2_reg <= '0';
      in1_NaN_reg <= '0';
      in1_NaN1_reg <= '0';
      in1_NaN2_reg <= '0';
      in0_SNaN_reg <= '0';
      in0_SNaN1_reg <= '0';
      in0_SNaN2_reg <= '0';
      in1_SNaN_reg <= '0';
      in1_SNaN1_reg <= '0';
      in1_SNaN2_reg <= '0';
      round_reg <= (others => '0');
      round1_reg <= (others => '0');
      round2_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      start_reg <= start;
      if start = '1' then
        in0_reg <= in0;
        in1_reg <= in1;
        op_reg <= opc(1 downto 0);
        double_reg <= opc(2);
        single_reg <=  not opc(2);
        man0_ldz_reg <= man0_ldz;
        man1_ldz_reg <= man1_ldz;
        in0_zero_reg <= in0_zero;
        in1_zero_reg <= in1_zero;
        in0_nstd_reg <= in0_nstd;
        in1_nstd_reg <= in1_nstd;
        in0_inf_reg <= in0_inf;
        in1_inf_reg <= in1_inf;
        in0_NaN_reg <= in0_NaN;
        in1_NaN_reg <= in1_NaN;
        in0_SNaN_reg <= in0_SNaN;
        in1_SNaN_reg <= in1_SNaN;
        round_reg <= round;
      end if;
      in0_reg1 <= in0_reg;
      in1_reg1 <= in1_reg;
      in0_reg2 <= in0_reg1;
      in1_reg2 <= in1_reg1;
      op1_reg <= op_reg;
      op2_reg <= op1_reg;
      man0_ldz1_reg <= man0_ldz_reg;
      man0_ldz2_reg <= man0_ldz1_reg;
      man1_ldz1_reg <= man1_ldz_reg;
      man1_ldz2_reg <= man1_ldz1_reg;
      in0_zero1_reg <= in0_zero_reg;
      in0_zero2_reg <= in0_zero1_reg;
      in1_zero1_reg <= in1_zero_reg;
      in1_zero2_reg <= in1_zero1_reg;
      in0_nstd1_reg <= in0_nstd_reg;
      in0_nstd2_reg <= in0_nstd1_reg;
      in1_nstd1_reg <= in1_nstd_reg;
      in1_nstd2_reg <= in1_nstd1_reg;
      in0_inf1_reg <= in0_inf_reg;
      in0_inf2_reg <= in0_inf1_reg;
      in1_inf1_reg <= in1_inf_reg;
      in1_inf2_reg <= in1_inf1_reg;
      in0_NaN1_reg <= in0_NaN_reg;
      in0_NaN2_reg <= in0_NaN1_reg;
      in1_NaN1_reg <= in1_NaN_reg;
      in1_NaN2_reg <= in1_NaN1_reg;
      in0_SNaN1_reg <= in0_SNaN_reg;
      in0_SNaN2_reg <= in0_SNaN1_reg;
      in1_SNaN1_reg <= in1_SNaN_reg;
      in1_SNaN2_reg <= in1_SNaN1_reg;
      round1_reg <= round_reg;
      round2_reg <= round1_reg;
    end if;
  end process input_register;

  -- Output Register
  output_register: process (clk, rst)
  begin  -- process output_register
    if rst = '0' then                   -- asynchronous reset (active low)
      UNF <= '0';
      NV <= '0';
      OV <= '0';
      UF <= '0';
      DZ <= '0';
      NX <= '0';
      result <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_out = '1' then
        UNF <= '0';                     --handling subnormals
        NV <= nv_o;
        OV <= ovf_o;
        UF <= udf_o;
        DZ <= dz_o;
        NX <= nx_o;
        result <= product_o;
      end if;
    end if;
  end process output_register;
  flags <= UNF & NV & OV & UF & DZ & NX;
  

  -- sign
  input_sign: process (in0_reg, in1_reg, double_reg, in0_zero_reg, in1_zero_reg)
    variable s0v, s1v : std_ulogic;
  begin  -- process input_sign
    if double_reg = '1' then
      s0v := in0_reg(63);
      s1v := in1_reg(63);
    else
      s0v := in0_reg(31);
      s1v := in1_reg(31);
    end if;
    if in0_zero_reg = '1' then
      s0v := '0';
    end if;
    if in1_zero_reg = '1' then
      s1v := '0';
    end if;

    s0 <= s0v;
    s1 <= s1v;
  end process input_sign;

  sgn_1: sgn
    port map (
      clk  => clk,
      rst  => rst,
      s0   => s0,
      s1   => s1,
      sign => sign_mul);

  sign_o <= sign_mul when op2_reg(1 downto 0) /= "11" else '0';

  --exponent adder
  exp0 <= in0_reg(62 downto 52) when double_reg = '1' else "000" & in0_reg(30 downto 23);
  exp1 <= in1_reg(62 downto 52) when double_reg = '1' else "000" & in1_reg(30 downto 23);
  sub <= op_reg(1) and (not op_reg(0));
  sqrt <= op_reg(1) and op_reg(0);
  exp_odd <= sqrt and (not bexp_isodd);
  exp_adder_1: exp_adder
    port map (
      clk       => clk,
      rst       => rst,
      sub       => sub,
      sqrt      => sqrt,
      exp_odd   => exp_odd,
      exp0      => exp0,
      exp1      => exp1,
      double    => double_reg,
      man0_ldz  => man0_ldz_reg,
      man1_ldz  => man1_ldz_reg,
      in0_nstd  => in0_nstd_reg,
      in1_nstd  => in1_nstd_reg,
      exp       => exp,
      expp1     => expp1,
      expm1     => expm1,
      ovf       => ovf_tmp,
      udf       => udf_tmp,
      nstd_res  => nstd_res);

  --divider exp adjust (takes the output of the exp_adder and needs 2 clock cycles)
  exp_adder_div_1: exp_adder_div
    port map (
      clk       => clk,
      rst       => rst,
      exp       => exp,
      expp1     => expp1,
      q_exp_inc => q_exp_inc,
      ovf_in    => ovf_tmp,
      udf_in    => udf_tmp,
      nstd_in   => nstd_res,
      double    => double_reg,
      exp_div   => exp_div,
      expp1_div => expp1_div,
      ovf_div   => ovf_div,
      udf_div   => udf_div,
      nstd_div  => nstd_div);

  --multiplier
  x_ext_mul <= "01" & in0_reg(51 downto 0) & "00" & X"00" & X"0000" when double_reg = '1'
               else "01" & in0_reg(22 downto 0) & "000" & X"000" & X"0000000000";
  y_ext_mul <= "01" & in1_reg(51 downto 0) & "00" & X"00" & X"0000" when double_reg = '1'
               else "01" & in1_reg(22 downto 0) & "000" & X"000" & X"0000000000";
  mul_in_mux: process (x_ext_mul, y_ext_mul, x_ext_div, y_ext_div, x_ext_sqrt,
                       y_ext_sqrt, div_running, sqrt_running)
  begin  -- process mul_in_mux
    if sqrt_running = '1' then
      x_ext <= x_ext_sqrt;
      y_ext <= y_ext_sqrt;
    elsif div_running = '1' then
      x_ext <= x_ext_div;
      y_ext <= y_ext_div;
    else
      x_ext <= x_ext_mul;
      y_ext <= y_ext_mul;
    end if;
  end process mul_in_mux;
  bwmul_1: bwmul
    port map (
      x_ext  => x_ext,
      y_ext  => y_ext,
      clk    => clk,
      rst    => rst,
      p      => p);

  --post normalizer
  exp_in <= exp when norm_div = '0' else exp_div;
  expp1_in <= expp1 when norm_div = '0' else expp1_div;
  man_in <= p(157 downto 103) when (norm_div = '0' and norm_sqrt = '0') else man_div;
  sticky_detect: process (p, norm_sqrt)
  begin  -- process sticky_detect
    if norm_sqrt = '0' then
      if p(102 downto 78) = '0' & x"000000" then
        stickyd <= '0';
      else
        stickyd <= '1';
      end if;
      if p(131 downto 78) = "00" & x"0000000000000" then
        stickys <= '0';
      else
        stickys <= '1';
      end if;
    else
      if p(101 downto 78) = x"000000" then
        stickyd <= '0';
      else
        stickyd <= '1';
      end if;
      if p(130 downto 78) = "0" & x"0000000000000" then
        stickys <= '0';
      else
        stickys <= '1';
      end if;
    end if;
  end process sticky_detect;
  ovf_in <= ovf_tmp when norm_div = '0' else ovf_div;
  udf_in <= udf_tmp when norm_div = '0' else udf_div;
  nstd_in <= nstd_res when norm_div = '0' else nstd_div;
  norm_1: norm
    port map (
      clk        => clk,
      rst        => rst,
      exp_in     => exp_in,
      expp1_in   => expp1_in,
      expm1_in   => expm1,
      man_in     => man_in,
      stickys    => stickys,
      stickyd    => stickyd,
      ovf_in     => ovf_in,
      udf_in     => udf_in,
      double     => double_reg,
      sqrt       => sqrt,
      nstd_in    => nstd_in,
      round      => round2_reg,
      double_out => double_out,
      ovf_out    => ovf_out,
      udf_out    => udf_out,
      nstd_out   => nstd_out,
      exp_out    => exp_out,
      man_out    => man_out);
    
  --multiplier output
  mul_output_muxes: process (ovf_out, udf_out, sign_o, exp_out, man_out,
                             nstd_out, double_out, op2_reg, in0_reg2, in1_reg2,
                             in0_zero2_reg, in1_zero2_reg,
                             in0_inf2_reg, in1_inf2_reg,
                             in0_nstd2_reg, in1_nstd2_reg,
                             in0_SNaN2_reg, in1_SNaN2_reg,
                             in0_NaN2_reg, in1_NaN2_reg)
    variable nan, snan : std_ulogic;
  begin  -- process output_muxes
    if op2_reg(1 downto 0) /= "11" then
      nan := in0_NaN2_reg or in1_NaN2_reg;
      snan := in0_SNaN2_reg or in1_SNaN2_reg;
    else
      nan := in0_NaN2_reg;
      snan := in0_SNaN2_reg;
    end if;
    nstd_o <= nstd_out;
    nan_o <= nan or snan;
    ovf_o <= ovf_out;
    udf_o <= udf_out;
    nv_o <= snan;
    dz_o <= '0';
    nx_o <= '1';
    if op2_reg(1 downto 0) = "00" then  --NOP return '0';
      nstd_o <= '0';
      nan_o <= '0';
      ovf_o <= '0';
      udf_o <= '0';
      nv_o <= '0';
      dz_o <= '0';
      nx_o <= '0';
      product_o <= (others => '0');
    elsif double_out = '1' then
      product_o(63) <= sign_o;
      product_o(62 downto 52) <= exp_out;
      product_o(51 downto 0) <= man_out;
      if in0_SNaN2_reg = '1' or (in1_SNaN2_reg = '1' and op2_reg(1 downto 0) /= "11") then   -- QNaN_GEN
        nx_o <= '0';
        udf_o <= '0';
        ovf_o <= '0';
        dz_o <=  '0';
        product_o <= QNaN_GENd;
      elsif in1_NaN2_reg = '1' and op2_reg(1 downto 0) /= "11" then   -- QNaN in1
        nx_o <= '0';
        udf_o <= '0';
        ovf_o <= '0';
        dz_o <=  '0';
        product_o <= in1_reg2;
      elsif in0_NaN2_reg = '1' then   -- QNaN in0
        nx_o <= '0';
        udf_o <= '0';
        ovf_o <= '0';
        dz_o <=  '0';
        product_o <= in0_reg2;
      elsif op2_reg(1 downto 0) = "01" then         --MUL
        if ((in0_zero2_reg and in1_inf2_reg) or (in1_zero2_reg and in0_inf2_reg)) = '1' then  --0xinf
          nv_o <= '1';
          udf_o <= '0';
          ovf_o <= '0';
          nx_o <= '0';
          product_o <= QNaN_GENd;
        elsif (in0_zero2_reg or in1_zero2_reg) = '1' then  --0xA = 0
          nx_o <= '0';
          ovf_o <= '0';
          udf_o <= '0';
          product_o(62 downto 0) <= (others => '0');
        elsif (in0_nstd2_reg and in1_nstd2_reg) = '1' then --nsdtXnsdt udf
          nx_o <= '1';
          udf_o <= '1';
          ovf_o <= '0';
          product_o(62 downto 0) <= (others => '0');
        end if;
      elsif op2_reg(1 downto 0) = "10" then  --DIV
        if ((in0_inf2_reg and in1_inf2_reg) or (in0_zero2_reg and in1_zero2_reg)) = '1' then
          nv_o <= '1';
          udf_o <= '0';
          ovf_o <= '0';
          nx_o <= '0';
          product_o <= QNaN_GENd;
        elsif in1_zero2_reg = '1' then  --Division by zero
          dz_o <= '1';
          nx_o <= '0';
          product_o(62 downto 52) <= "11111111111";  --signed inf.
          product_o(51 downto 0) <= (others => '0');
        elsif in0_zero2_reg = '1' then
          udf_o <= '0';
          ovf_o <= '0';
          nx_o <= '0';
          product_o <= (others => '0');
        end if;
      elsif op2_reg(1 downto 0) = "11" then  --SQRT -Nan with no matissa
        if in0_reg2(63) = '1' then
          if in0_zero2_reg = '1' then     --SQRT(-0) = -0
            nx_o <= '0';
            udf_o <= '0';
            ovf_o <= '0';
            product_o <= X"8000000000000000";
          else
            nv_o <= '1';
            udf_o <= '0';
            ovf_o <= '0';
            nx_o <= '0';
            product_o <= QNaN_GENd;
          end if;
        else
          if in0_zero2_reg = '1' then
            nx_o <= '0';
            udf_o <= '0';
            ovf_o <= '0';
            product_o <= X"0000000000000000";
          end if;
        end if;
      end if;
    else  --Single
      product_o(63 downto 32) <= (others => '0');
      product_o(31) <= sign_o;
      product_o(30 downto 23) <= exp_out(7 downto 0);
      product_o(22 downto 0) <= man_out(51 downto 29);
      if in0_SNaN2_reg = '1' or (in1_SNaN2_reg = '1' and op2_reg(1 downto 0) /= "11") then   -- QNaN_GENs
        nx_o <= '0';
        udf_o <= '0';
        ovf_o <= '0';
        dz_o <= '0';
        product_o <= QNaN_GENs;
      elsif in1_NaN2_reg = '1'  and op2_reg(1 downto 0) /= "11" then   -- in1 QNaN
        nx_o <= '0';
        udf_o <= '0';
        ovf_o <= '0';
        dz_o <= '0';
        product_o <= in1_reg2;
      elsif (in0_NaN2_reg) = '1' then   -- in0 QNaN
        nx_o <= '0';
        udf_o <= '0';
        ovf_o <= '0';
        dz_o <= '0';
        product_o <= in0_reg2;
      elsif op2_reg(1 downto 0) = "01" then         --MUL
        if ((in0_zero2_reg and in1_inf2_reg) or (in1_zero2_reg and in0_inf2_reg)) = '1' then  --0xinf
          nv_o <= '1';
          udf_o <= '0';
          ovf_o <= '0';
          nx_o <= '0';
          product_o <= QNaN_GENs;
        elsif (in0_zero2_reg or in1_zero2_reg) = '1' then  --0xA = 0
          nx_o <= '0';
          udf_o <= '0';
          ovf_o <= '0';
          product_o(30 downto 0) <= (others => '0');
        elsif (in0_nstd2_reg and in1_nstd2_reg) = '1' then --nsdtXnsdt udf
          nx_o <= '1';
          udf_o <= '1';
          ovf_o <= '0';
          product_o(30 downto 0) <= (others => '0');
        end if;
      elsif op2_reg(1 downto 0) = "10" then  --DIV
        if ((in0_inf2_reg and in1_inf2_reg) or (in0_zero2_reg and in1_zero2_reg)) = '1' then
          nv_o <= '1';
          udf_o <= '0';
          ovf_o <= '0';
          nx_o <= '0';
          product_o <= QNaN_GENs;
        elsif in1_zero2_reg = '1' then  --Division by zero
          dz_o <= '1';
          udf_o <= '0';
          ovf_o <= '0';
          nx_o <= '0';
          product_o(30 downto 23) <= "11111111";  --signed inf.
          product_o(22 downto 0) <= (others => '0');
        elsif in0_zero2_reg = '1' then
          udf_o <= '0';
          ovf_o <= '0';
          nx_o <= '0';
          product_o(31 downto 0) <= (others => '0');
        end if;
      elsif op2_reg(1 downto 0) = "11" then -- SQRT -Nan with no matissa
        if in0_reg2(31) = '1' then
          if in0_zero2_reg = '1' then
            nx_o <= '0';
            udf_o <= '0';
            ovf_o <= '0';
            product_o <= X"0000000080000000";
          else
            nv_o <= '1';
            udf_o <= '0';
            ovf_o <= '0';
            nx_o <= '0';
            product_o <= QNaN_GENs;
          end if;
        else
          if in0_zero2_reg = '1' then
            nx_o <= '0';
            udf_o <= '0';
            ovf_o <= '0';
            product_o <= X"0000000000000000";
          end if;
        end if;
      end if;
    end if;
  end process mul_output_muxes;


  --divider and SQRT
  div_addr <= in1_reg(51 downto 46) when double_reg = '1' else in1_reg(22 downto 17);
  divlut_1: divlut
    port map (
      addr    => div_addr,
      romdata => div_romdata);
  sqrt_addr <= in0_reg(51 downto 46) when double_reg = '1' else in0_reg(22 downto 17);
  sqrtlut_1: sqrtlut
    port map (
      addr    => sqrt_addr,
      romdata => sqrt_romdata);
  sqrtlut2_1: sqrtlut2
    port map (
      addr    => sqrt_addr,
      romdata => sqrt2_romdata);
  detect_sqrt_odd_exp: process (in0_reg, double_reg, man0_ldz_reg, in0_nstd_reg)
  begin  -- process detect_sqrt_odd_exp
    --With subnormal the exponen is (-bias - man0_ldz) and bias is odd
    if in0_nstd_reg = '1' then
      bexp_isodd <= man0_ldz_reg(0);
    elsif double_reg = '1'  then
      bexp_isodd <= in0_reg(52);
    else
      bexp_isodd <= in0_reg(23);
    end if;
  end process detect_sqrt_odd_exp;


  div_buffer: process (clk, rst)
  begin  -- process div_buffer
    if rst = '0' then                   -- asynchronous reset (active low)
      n_reg <= (others => '0');
      r_reg <= (others => '0');
      d_reg <= (others => '0');
      rsq_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_n = '1' then
        n_reg <= n;        
      end if;
      if sample_r = '1' then
        r_reg <= r;
      end if;
      if sample_d = '1' then
        d_reg <= d;
      end if;
      if sample_rsq = '1' then
        rsq_reg <= rsq;
      end if;
    end if;
  end process div_buffer;

  shift_quotient_exp: process (clk, rst)
  begin  -- process shift_quotient_exp
    if rst = '0' then                   -- asynchronous reset (active low)
      q_exp_inc <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if div_reset = '0' then           -- synchronous reset (active low)
        q_exp_inc <= "00000000000";
      elsif div_inc  = '1' then
        q_exp_inc <= q_exp_next;
      elsif div_dec = '1' then
        q_exp_inc <= q_exp_prev;
      end if;
    end if;
  end process shift_quotient_exp;
  q_exp_next <= q_exp_inc + "00000000001";
  q_exp_prev <= q_exp_inc + "11111111111";

  div_update_state: process (clk, rst)
  begin  -- process div_update_state
    if rst = '0' then                   -- asynchronous reset (active low)
      div_cs <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      div_cs <= div_ns;
    end if;
  end process div_update_state;

  fsm_div: process (div_cs, op_reg, double_reg, div_romdata, p, in0_reg, in1_reg,
                    d_reg, n_reg, r_reg, sqrt_romdata, sqrt2_romdata, rsq_reg,
                    bexp_isodd, flush, start_reg)
    variable d2comp, r_next : std_logic_vector(79 downto 0);
  begin  -- process fsm_div
    --Default output assignments
    d2comp := (others => '0');
    r_next := (others => '0');

    div_ns <= idle;

    x_ext_div <= (others => '0');
    y_ext_div <= (others => '0');
    man_div <= (others => '0');
    sample_r <= '0';
    sample_n <= '0';
    sample_d <= '0';
    r <= (others => '0');
    n <= (others => '0');
    d <= (others => '0');
    div_reset <= '1';
    div_inc <= '0';
    div_dec <= '0';
    norm_div <= '0';
    div_running <= '0';

    x_ext_sqrt <= (others => '0');
    y_ext_sqrt <= (others => '0');
    sample_rsq <= '0';
    rsq <= (others => '0');
    norm_sqrt <= '0';
    sqrt_running <= '0';

    sample_out <= '0';
    --FSM
    case div_cs is
      when idle    => if op_reg = "10" and start_reg = '1' then  --D0xR0
                        div_ns <= div1;
                        div_reset <= '0';
                        div_running <= '1';
                      elsif op_reg = "11" and start_reg = '1' then  --D0xR0sq
                        div_ns <= sqrt1;
                        sqrt_running <= '1';
                      else
                        div_ns <= idle;
                      end if;
                      sample_n <= '1';
                      if double_reg = '1' then
                        n <= "001" & in0_reg(51 downto 0) & "0" & X"00" & X"0000";
                        x_ext_sqrt <= "001" & in0_reg(51 downto 0) & "0" & X"00" & X"0000";
                        x_ext_div <= "001" & in1_reg(51 downto 0) & "0" & X"00" & X"0000";
                      else
                        n <= "001" & in0_reg(22 downto 0) & "00" & X"000000000" & X"0000";
                        x_ext_sqrt <= "001" & in0_reg(22 downto 0) & "00" & X"000" & X"0000000000";
                        x_ext_div <= "001" & in1_reg(22 downto 0) & "00" & X"000" & X"0000000000";
                      end if;
                      y_ext_div <= "01" & div_romdata & X"0000000000000" & X"0000";
                      y_ext_sqrt <= "01" & sqrt2_romdata & "00" & X"0000000000" & X"0000";
                      sample_r <= '1';
                      r <= "01" & sqrt_romdata & X"0000000000000" & X"0000";
                      sample_out <= '1';  --Current MUL

-------------------------------------------------------------------------------
-- Square Root
-------------------------------------------------------------------------------

      when sqrt1   => div_ns <= sqrt2;
                      x_ext_sqrt <= n_reg;  --N0xR0
                      y_ext_sqrt <= r_reg;
                      sqrt_running <= '1';
                      sample_out <= '1';  --Previous MUL

      when sqrt2   => div_ns <= sqrt3;  --R1=(2-(D1/2 + 0.5))
                      sample_d <= '1';
                      d <= p(157 downto 78);
                      d2comp := '0' & p(157 downto 79);  -- D1/2
                      d2comp(79 downto 77) := d2comp(79 downto 77) + "001"; -- +0.5
                      d2comp := (not d2comp) + (X"0000000000" & X"0000000001");
                      r_next := '0' & d2comp(78 downto 0);  --2's complement
                      sample_r <= '1';
                      r <= r_next;
                      sqrt_running <= '1';

      when sqrt3   => div_ns <= sqrt4;  --R1xR1
                      sample_n <= '1';
                      n <= p(157 downto 78);
                      x_ext_sqrt <= r_reg;
                      y_ext_sqrt <= r_reg;
                      sqrt_running <= '1';
                      
      when sqrt4   => div_ns <= sqrt5;
                      x_ext_sqrt <= n_reg;  --N1xR1
                      y_ext_sqrt <= r_reg;
                      sqrt_running <= '1';
                      
      when sqrt5   => div_ns <= sqrt6;
                      sample_rsq <= '1';
                      rsq <= p(157 downto 78);
                      sqrt_running <= '1';

      when sqrt6   => div_ns <= sqrt7;  --D1xR1sq
                      sample_n <= '1';
                      n <= p(157 downto 78);
                      x_ext_sqrt <= d_reg;
                      y_ext_sqrt <= rsq_reg;
                      sqrt_running <= '1';


      when sqrt7   => div_ns <= sqrt8;
                      sqrt_running <= '1';

      when sqrt8   => div_ns <= sqrt9;  --R2=(2-(D2/2 + 0.5))
                      sample_d <= '1';
                      d <= p(157 downto 78);
                      d2comp := '0' & p(157 downto 79);  -- D2/2
                      d2comp(79 downto 77) := d2comp(79 downto 77) + "001"; -- +0.5
                      d2comp := (not d2comp) + (X"0000000000" & X"0000000001");
                      r_next := '0' & d2comp(78 downto 0);  --2's complement
                      sample_r <= '1';
                      r <= r_next;
                      sqrt_running <= '1';

      when sqrt9   => div_ns <= sqrt10;  --R2xR2
                      x_ext_sqrt <= r_reg;
                      y_ext_sqrt <= r_reg;
                      sqrt_running <= '1';
                      
      when sqrt10  => div_ns <= sqrt11;
                      x_ext_sqrt <= n_reg;  --N2xR2
                      y_ext_sqrt <= r_reg;
                      sqrt_running <= '1';
                      
      when sqrt11  => div_ns <= sqrt12;
                      sample_rsq <= '1';
                      rsq <= p(157 downto 78);
                      sqrt_running <= '1';

      when sqrt12  => div_ns <= sqrt13;  --D2xR2sq
                      sample_n <= '1';
                      n <= p(157 downto 78);
                      x_ext_sqrt <= d_reg;
                      y_ext_sqrt <= rsq_reg;
                      sqrt_running <= '1';

      when sqrt13  => div_ns <= sqrt14;
                      sqrt_running <= '1';

      when sqrt14  => div_ns <= sqrt15;  --R3=(2-(D3/2 + 0.5))
                      sample_d <= '1';
                      d <= p(157 downto 78);
                      d2comp := '0' & p(157 downto 79);  -- D3/2
                      d2comp(79 downto 77) := d2comp(79 downto 77) + "001"; -- +0.5
                      d2comp := (not d2comp) + (X"0000000000" & X"0000000001");
                      r_next := '0' & d2comp(78 downto 0);  --2's complement
                      sample_r <= '1';
                      r <= r_next;
                      sqrt_running <= '1';

      when sqrt15  => div_ns <= sqrt16;  --R3xR3
                      x_ext_sqrt <= r_reg;
                      y_ext_sqrt <= r_reg;
                      sqrt_running <= '1';
                      
      when sqrt16  => div_ns <= sqrt17;
                      x_ext_sqrt <= n_reg;  --N3xR3
                      y_ext_sqrt <= r_reg;
                      sqrt_running <= '1';
                      
      when sqrt17  => div_ns <= sqrt18;
                      sample_rsq <= '1';
                      rsq <= p(157 downto 78);
                      sqrt_running <= '1';

      when sqrt18  => div_ns <= sqrt19;  --D3xR3sq
                      sample_n <= '1';
                      n <= p(157 downto 78);
                      x_ext_sqrt <= d_reg;
                      y_ext_sqrt <= rsq_reg;
                      sqrt_running <= '1';

      when sqrt19  => div_ns <= sqrt20;  --N4xSQRT(2)
                      x_ext_sqrt <= n_reg;
                      y_ext_sqrt <= "01" & X"6A09E667F3BCC908B2F" & "00";
                      sqrt_running <= '1';

      when sqrt20  => div_ns <= sqrt21;  --R4=(2-(D4/2 + 0.5))
                      d2comp := '0' & p(157 downto 79);  -- D3/2
                      d2comp(79 downto 77) := d2comp(79 downto 77) + "001"; -- +0.5
                      d2comp := (not d2comp) + (X"0000000000" & X"0000000001");
                      r_next := '0' & d2comp(78 downto 0);  --2's complement
                      sample_r <= '1';
                      r <= r_next;
                      sqrt_running <= '1';

      when sqrt21  => div_ns <= sqrt22;
                      if bexp_isodd = '1' then  --use N4xSQRT(2)
                        sample_n <= '1';                        
                      end if;
                      n <= p(157 downto 78);
                      sqrt_running <= '1';

      when sqrt22  => div_ns <= sqrt23;
                      x_ext_sqrt <= n_reg;  --N4xR4
                      y_ext_sqrt <= r_reg;
                      sqrt_running <= '1';

      when sqrt23  => div_ns <= sqrt24;
                      sqrt_running <= '1';

      when sqrt24  => div_ns <= idle;
                      norm_sqrt <= '1';
                      man_div <= p(156 downto 102);
                      sqrt_running <= '0';
                      sample_out <= '1';  --SQRT done

-------------------------------------------------------------------------------
-- Division
-------------------------------------------------------------------------------

      when div1    => div_ns <= div2;    --N0xR0
                      div_running <= '1';
                      if double_reg = '1' then
                        x_ext_div <= "01" & in0_reg(51 downto 0) & "00" & X"00" & X"0000";
                      else
                        x_ext_div <= "01" & in0_reg(22 downto 0) & "000" & X"000000000" & X"0000";
                      end if;
                      y_ext_div <= "01" & div_romdata & X"0000000000000" & X"0000";
                      sample_out <= '1';  --Previous MUL
                     
      when div2    => div_ns <= div3;    --get D1, R1
                      div_running <= '1';
                      sample_d <= '1';
                      d <= p(157 downto 78);
                      d2comp := p(157 downto 78);
                      d2comp := (not d2comp) + (X"0000000000" & X"0000000001");
                      r_next := '0' & d2comp(78 downto 0);
                      sample_r <= '1';
                      r <= r_next;

      when div3    => div_ns <= div4;    --get N1, D1xR1
                      div_running <= '1';
                      sample_n <= '1';
                      if p(157) = '1' then
                        n <= '0' & p(157 downto 79);  --increment exponent
                        div_inc <= '1';
                      elsif p(156) = '0' then
                        n <= p(156 downto 77);
                        div_dec <= '1';
                      else
                        n <= p(157 downto 78);
                      end if;
                      x_ext_div <= d_reg;
                      y_ext_div <= r_reg;

      when div4    => div_ns <= div5;    --N1xR1
                      div_running <= '1';
                      x_ext_div <= n_reg;
                      y_ext_div <= r_reg;

      when div5    => div_ns <= div6;    --get D2, R2
                      div_running <= '1';
                      sample_d <= '1';
                      d <= p(157 downto 78);
                      d2comp := p(157 downto 78);
                      d2comp := (not d2comp) + (X"0000000000" & X"0000000001");
                      r_next := '0' & d2comp(78 downto 0);
                      sample_r <= '1';
                      r <= r_next;

      when div6    => div_ns <= div7;    --get N2, D2xR2
                      div_running <= '1';
                      sample_n <= '1';
                      if p(157) = '1' then
                        n <= '0' & p(157 downto 79);  --increment exponent
                        div_inc <= '1';
                      elsif p(156) = '0' then
                        n <= p(156 downto 77);
                        div_dec <= '1';
                      else
                        n <= p(157 downto 78);
                      end if;
                      x_ext_div <= d_reg;
                      y_ext_div <= r_reg;

      when div7    => div_ns <= div8;    --N2xR2
                      div_running <= '1';
                      x_ext_div <= n_reg;
                      y_ext_div <= r_reg;

      when div8    => div_ns <= div9;    --get D3, R3
                      div_running <= '1';
                      sample_d <= '1';
                      d <= p(157 downto 78);
                      d2comp := p(157 downto 78);
                      d2comp := (not d2comp) + (X"0000000000" & X"0000000001");
                      r_next := '0' & d2comp(78 downto 0);
                      sample_r <= '1';
                      r <= r_next;

     when div9     => div_ns <= div10;    --get N3, D3xR3
                      div_running <= '1';
                      sample_n <= '1';
                      if p(157) = '1' then
                        n <= '0' & p(157 downto 79);  --increment exponent
                        div_inc <= '1';
                      elsif p(156) = '0' then
                        n <= p(156 downto 77);
                        div_dec <= '1';
                      else
                        n <= p(157 downto 78);
                      end if;
                      x_ext_div <= d_reg;
                      y_ext_div <= r_reg;

      when div10   => div_ns <= div11;    --N3xR3
                      div_running <= '1';
                      x_ext_div <= n_reg;
                      y_ext_div <= r_reg;

      when div11   => div_ns <= div12;    --get R4
                      div_running <= '1';
                      sample_d <= '1';
                      d <= p(157 downto 78);
                      d2comp := p(157 downto 78);
                      d2comp := (not d2comp) + (X"0000000000" & X"0000000001");
                      r_next := '0' & d2comp(78 downto 0);
                      sample_r <= '1';
                      r <= r_next;

      when div12   => div_ns <= div13;    --get N4
                      div_running <= '1';
                      sample_n <= '1';
                      if p(157) = '1' then
                        n <= '0' & p(157 downto 79);  --increment exponent
                        div_inc <= '1';
                      elsif p(156) = '0' then
                        n <= p(156 downto 77);
                        div_dec <= '1';
                      else
                        n <= p(157 downto 78);
                      end if;

      when div13   => div_ns <= div14;    --N4xR4
                      div_running <= '1';
                      x_ext_div <= n_reg;
                      y_ext_div <= r_reg;

      when div14   => div_ns <= div15;
                      div_running <= '1';

      when div15   => div_ns <= idle;
                      norm_div <= '1';
                      div_running <= '0';
                      man_div <= p(157 downto 103);
                      sample_out <= '1';  --DIV done

      when others => div_ns <= idle;
    end case;
    if flush = '1' then
      div_ns <= idle;
    end if;
  end process fsm_div;

end rtl;
