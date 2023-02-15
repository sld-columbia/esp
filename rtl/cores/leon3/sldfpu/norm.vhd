-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity:      norm
-- File:	norm.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Post Normalization
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.basic.all;

entity norm is
  
  port (
    clk              : in  std_ulogic;
    rst              : in  std_ulogic;
    exp_in           : in  std_logic_vector(10 downto 0);
    expp1_in         : in  std_logic_vector(10 downto 0);
    expm1_in         : in  std_logic_vector(10 downto 0);
    man_in           : in  std_logic_vector(54 downto 0);  --need extra bit for rounding
    stickys          : in  std_ulogic;
    stickyd          : in  std_ulogic;
    ovf_in           : in  std_ulogic;
    udf_in           : in  std_ulogic;
    double           : in  std_ulogic;
    sqrt             : in  std_ulogic;
    nstd_in          : in  std_ulogic;
    round            : in  std_logic_vector(1 downto 0);  --TODO:different rounding!
    double_out       : out std_ulogic;                    --deskew
    ovf_out          : out std_ulogic;
    udf_out          : out std_logic;
    nstd_out         : out std_logic;
    exp_out          : out std_logic_vector(10 downto 0);
    man_out          : out std_logic_vector(51 downto 0));

end norm;

architecture normalization of norm is

  constant zero : std_logic_vector(54 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Variable amount right shifter with sticky bit calculation.
-- (Copyright (C) 2002 Martin Kasprzyk) - Edit
-------------------------------------------------------------------------------
  procedure right_shifter_sticky (
    in_vect    : in  std_logic_vector(54 downto 0);
    amount     : in  std_logic_vector(5 downto 0);
    sticky_in  : in  std_ulogic;
    out_vect   : out std_logic_vector(54 downto 0);
    sticky_bit : out std_ulogic) is
    variable after32  : std_logic_vector(54 downto 0);
    variable after16  : std_logic_vector(54 downto 0);
    variable after8   : std_logic_vector(54 downto 0);
    variable after4   : std_logic_vector(54 downto 0);
    variable after2   : std_logic_vector(54 downto 0);
    variable after1   : std_logic_vector(54 downto 0);
    variable sticky32 : std_ulogic;
    variable sticky16 : std_ulogic;
    variable sticky8  : std_ulogic;
    variable sticky4  : std_ulogic;
    variable sticky2  : std_ulogic;
    variable sticky1  : std_ulogic;
  begin
    -- If amount(5) = '1' then shift vector 32 positions right
    if amount(5) = '1' then
      after32 := zero(31 downto 0) & in_vect(54 downto 32);
      if in_vect(31 downto 0) /= zero(31 downto 0) then
        sticky32 := '1';
      else
        sticky32 := '0';
      end if;
    else
      after32 := in_vect;
      sticky32 := '0';
    end if;

    -- If amount(4) = '1' then shift vector 16 positions right
    if amount(4) = '1' then
      after16 := zero(15 downto 0) & after32(54 downto 16);
      if after32(15 downto 0) /= zero(15 downto 0) then
        sticky16 := '1';
      else
        sticky16 := '0';
      end if;
    else
      after16 := after32;
      sticky16 := '0';
    end if;

    -- If amount(3) = '1' then shift vector 8 positions right
    if amount(3) = '1' then
      after8 := zero(7 downto 0) & after16(54 downto 8);
      if after16(7 downto 0) /= zero(7 downto 0) then
        sticky8 := '1';
      else
        sticky8 := '0';
      end if;
    else
      after8 := after16;
      sticky8 := '0';
    end if;

    -- If amount(2) = '1' then shift vector 4 positions right
    if amount(2) = '1' then
      after4 := zero(3 downto 0) & after8(54 downto 4);
      if after8(3 downto 0) /= zero(3 downto 0) then
        sticky4 := '1';
      else
        sticky4 := '0';
      end if;
    else
      after4 := after8;
      sticky4 := '0';
    end if;

    -- If amount(1) = '1' then shift vector 2 positions right
    if amount(1) = '1' then
      after2 := "00" & after4(54 downto 2);
      if after4(1 downto 0) /= "00" then
        sticky2 := '1';
      else
        sticky2 := '0';
      end if;
    else
      after2 := after4;
      sticky2 := '0';
    end if;

    -- If amount(0) = '1' then shift vector 1 positions right
    if amount(0) = '1' then
      after1 := "0" & after2(54 downto 1);
      sticky1 := after2(0);
    else
      after1 := after2;
      sticky1 := '0';
    end if;

    -- Return values
    out_vect := after1;
    sticky_bit := sticky32 or sticky16 or sticky8 or sticky4 or sticky2 or
                 sticky1 or sticky_in;
  end right_shifter_sticky;

-------------------------------------------------------------------------------
  
  signal double1_reg, double2_reg : std_ulogic;
  signal sqrt1_reg, sqrt2_reg : std_ulogic;
  signal udf_temp, ovf_temp, nstd_temp : std_ulogic;
  signal man_temp : std_logic_vector(51 downto 0);
  signal exp_temp : std_logic_vector(10 downto 0);

  signal carry : std_logic_vector(54 downto 0);
  signal carry_1, carry_29, carry_30, carry_round : std_ulogic;
  signal man_to_round : std_logic_vector(54 downto 0);
  signal man_round : std_logic_vector(53 downto 0);

  signal lsb, ulsb, llsb : std_ulogic;
  signal sticky, sticky_rs : std_ulogic;
  signal nstd_norm : std_ulogic;

begin  -- normalization

  io_register: process (clk, rst)
  begin  -- process io_register
    if rst = '0' then                   -- asynchronous reset (active low)
      double1_reg <= '0';
      double2_reg <= '0';
      sqrt1_reg <= '0';
      sqrt2_reg <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      double1_reg <= double;
      double2_reg <= double1_reg;
      sqrt1_reg <= sqrt;
      sqrt2_reg <= sqrt1_reg;
    end if;
  end process io_register;
  double_out <= double2_reg;
  ovf_out <= ovf_temp;
  udf_out <= udf_temp;
  nstd_out <= nstd_temp;
  exp_out <= exp_temp;
  man_out <= man_temp;

  --Sticky bit fromprevious stage
  sticky <= stickyd when double2_reg = '1' else stickys;

  --Check exception on nstd
  nstd_norm <= '0' when (exp_in = "00000000000" and man_in(54) = '1') else nstd_in;

  --Handle subnormal numbers and update sticky
  nstd_shift: process (man_in, nstd_norm, exp_in, sticky, double2_reg)
    variable mrs_in : std_logic_vector(54 downto 0);
    variable rs_amount : std_logic_vector(5 downto 0);
    variable sticky_in : std_ulogic;
    variable sticky_out : std_ulogic;
    variable mrs_out : std_logic_vector(54 downto 0);
  begin  -- process nstd_shift
    mrs_in := man_in;
    sticky_in := sticky;
    rs_amount := not exp_in(5 downto 0);  --then shift 2 more!
    if nstd_norm = '1' then
      if exp_in = zero(10 downto 0) then
        if double2_reg = '1' then
          sticky_out := sticky_in or mrs_in(0);
        else
          sticky_out := sticky_in or mrs_in(29);
        end if;
        mrs_out := '0' & man_in(54 downto 1);
      else
        right_shifter_sticky(mrs_in, rs_amount, sticky_in, mrs_out, sticky_out);
        if double2_reg = '1' then
          sticky_out := sticky_out or mrs_out(1) or mrs_out(0);
        else
          sticky_out := sticky_out or mrs_out(30) or mrs_out(29);
        end if;
        mrs_out := "00" & mrs_out(54 downto 2);
      end if;
    else
      sticky_out := sticky_in;
      mrs_out := mrs_in;
    end if;
    sticky_rs <= sticky_out;
    man_to_round <= mrs_out;
  end process nstd_shift;
  
  --Rounding (TODO: might need faster CPA)
  ulsb <= man_to_round(2) when double2_reg = '1' else man_to_round(31);
  lsb <= man_to_round(1) when double2_reg = '1' else man_to_round(30);
  llsb <= man_to_round(0) when double2_reg = '1' else man_to_round(29);

  carry(0) <= '1' when double2_reg = '1' and man_to_round(54) = '0' else '0';
  carry_1 <= '1' when double2_reg = '1' and man_to_round(54) = '1' else carry(1);
  carry_29 <= '1' when double2_reg = '0' and man_to_round(54) = '0' else carry(29);
  carry_30 <= '1' when double2_reg = '0' and man_to_round(54) = '1' else carry(30);
  ha_1: ha
    port map (
      in0  => man_to_round(1),
      in1  => carry_1,
      sum  => man_round(1),
      cout => carry(2));
  ha_29: ha
    port map (
      in0  => man_to_round(29),
      in1  => carry_29,
      sum  => man_round(29),
      cout => carry(30));
  ha_30: ha
    port map (
      in0  => man_to_round(30),
      in1  => carry_30,
      sum  => man_round(30),
      cout => carry(31));
  rounding: for i in 0 to 53 generate
    exception: if i/=1 and i/=29 and i/=30 generate
      ha_i: ha
        port map (
          in0  => man_to_round(i),
          in1  => carry(i),
          sum  => man_round(i),
          cout => carry(i+1));
    end generate exception;    
  end generate rounding;

  carry_round <= carry(54);
  
  --Normalization
  process (ovf_in, udf_in, exp_in, expp1_in, expm1_in, man_in, man_to_round, man_round, carry_round, double2_reg, sticky_rs, ulsb, llsb, lsb, sqrt2_reg, nstd_norm)
  begin  -- process
        if ovf_in = '1' then            -- overflow
          ovf_temp <= '1';
          udf_temp <= '0';
          nstd_temp <= '0';
          exp_temp <= (others => '1');
          man_temp <= (others => '0');
        elsif udf_in = '1' then         -- underflow
          ovf_temp <= '0';
          udf_temp <= '1';
          nstd_temp <= '0';
          exp_temp <= (others => '0');
          man_temp <= (others => '0');
          if nstd_norm = '1' then
            if double2_reg = '1' then
              if (man_to_round(1) or (man_to_round(0) and sticky_rs)) = '1' then  --subnormal
                udf_temp <= '0';
                nstd_temp <= '1';
                man_temp <= man_round(52 downto 1);
              end if;
            else
              if (man_to_round(30) or (man_to_round(29) and sticky_rs)) = '1' then  --subnormal
                udf_temp <= '0';
                nstd_temp <= '1';
                man_temp <= man_round(52 downto 1);
              end if;
            end if;
          end if;
        elsif nstd_norm = '1' then       --subnormal
          ovf_temp <= '0';
          udf_temp <= '0';
          nstd_temp <= '1';
          exp_temp <= (others => '0');
          man_temp <= man_round(52 downto 1);
        elsif (man_to_round(54) or carry_round) = '1' then     -- normalize!
          udf_temp <= '0';
          nstd_temp <= '0';
          if sqrt2_reg = '0' then
            if (double2_reg = '1' and exp_in = "11111111110") or (double2_reg = '0' and exp_in = "00011111110") then   -- overflow
              ovf_temp <= '1';
              exp_temp <= (others => '1');
              man_temp <= (others => '0');
            else
              ovf_temp <= '0';
              exp_temp <= expp1_in;
              if ulsb = '0' and llsb = '0' and sticky_rs = '0' then
                man_temp <= man_to_round(53 downto 2);
              else
                man_temp <= man_round(53 downto 2);          
              end if;
            end if;
          else
            ovf_temp <= '0';
            exp_temp <= exp_in;
            if ulsb = '0' and llsb = '0' and sticky_rs = '0' then
              man_temp <= man_to_round(53 downto 2);
            else
              man_temp <= man_round(53 downto 2);
            end if;
          end if;
        else                            -- normalized already except for SQRT
          ovf_temp <= '0';
          udf_temp <= '0';
          nstd_temp <= '0';
          if sqrt2_reg = '0' then
            exp_temp <= exp_in;
            if sticky_rs = '0' and lsb = '0' then
              man_temp <= man_to_round(52 downto 1);
            else
              man_temp <= man_round(52 downto 1);            
            end if;
          else
-- pragma translate_off
            assert expm1_in /= "00000000000" report "SQRT exponent goes to zero!" severity error;
-- pragma translate_on
            exp_temp <= expm1_in;
            if sticky_rs = '0' and lsb = '0' then
              man_temp <= man_to_round(52 downto 1);
            else
              man_temp <= man_round(52 downto 1);            
            end if;
          end if;
        end if;
  end process;

end normalization;
