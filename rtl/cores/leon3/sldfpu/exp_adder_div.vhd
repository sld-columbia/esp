-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity:      exp_adder_div
-- File:	exp_adder_div.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Exponents adder for floating point division
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.basic.all;

entity exp_adder_div is
  
  port (
    clk        : in  std_ulogic;
    rst        : in  std_ulogic;
    exp        : in  std_logic_vector(10 downto 0);
    expp1      : in  std_logic_vector(10 downto 0);
    q_exp_inc  : in  std_logic_vector(10 downto 0);
    ovf_in     : in  std_ulogic;
    udf_in     : in  std_ulogic;
    nstd_in    : in  std_ulogic;
    double     : in  std_ulogic;
    exp_div    : out std_logic_vector(10 downto 0);
    expp1_div  : out std_logic_vector(10 downto 0);
    ovf_div    : out std_ulogic;
    udf_div    : out std_ulogic;
    nstd_div   : out std_ulogic);

end exp_adder_div;

architecture eadd of exp_adder_div is

  signal ones : std_logic_vector(10 downto 0);
  signal double_reg1 : std_ulogic;
  signal exp_temp_reg, expp1_temp_reg : std_logic_vector(10 downto 0);
  signal exp_temp, expp1_temp : std_logic_vector(10 downto 0);
  signal cout : std_logic_vector(1 downto 0);
  signal cout_reg : std_ulogic;
  signal ovf_temp, udf_temp, nstd_temp, msb1 : std_ulogic;
  signal zero, one, ovf_in_reg, udf_in_reg, nstd_in_reg : std_ulogic;
  signal explow, expudf, expnorm : std_ulogic;
 
begin  -- eadd
  
  --Stage 1 of last multiplication for division: N56
  addern_1: addern
    generic map (
      n => 11)
    port map (
      in0   => exp,
      in1   => q_exp_inc,
      cin   => '0',
      total => exp_temp,
      cout  => cout(0));

  addern_2: addern
    generic map (
      n => 11)
    port map (
      in0   => expp1,
      in1   => q_exp_inc,
      cin   => '0',
      total => expp1_temp,
      cout  => cout(1));

  stage1: process (clk, rst)
  begin  -- process stage1
    if rst = '0' then                   -- asynchronous reset (active low)
      exp_temp_reg <= (others => '0');
      expp1_temp_reg <= (others => '0');
      cout_reg <= '0';
      double_reg1 <= '0';
      ovf_in_reg <= '0';
      udf_in_reg <= '0';
      nstd_in_reg <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      exp_temp_reg <= exp_temp;
      expp1_temp_reg <= expp1_temp;
      cout_reg <= cout(0);
      double_reg1 <= double;
      ovf_in_reg <= ovf_in;
      udf_in_reg <= udf_in;
      nstd_in_reg <= nstd_in;
    end if;
  end process stage1;

  --Stage 2 of last multiplication for division: N56
  explow_detect: process (exp_temp_reg, double_reg1, cout_reg)
  begin  -- process explow_detect
    explow <= '0';
    expudf <= '0';
    expnorm <= '0';
    if (cout_reg = '1' or exp_temp_reg(10) = '0') and exp_temp_reg(9 downto 0) /= "0000000000" then
      expnorm <= '1';
    end if;
    if double_reg1 = '1' then
      if exp_temp_reg(10) = '1' and exp_temp_reg(9 downto 0) <= "1111001100" then
        explow <= '1';
      end if;
      if exp_temp_reg(10) = '1' and exp_temp_reg(9 downto 0) <= "1111001010" then
        expudf <= '1';
      end if;
    else
      if exp_temp_reg(10) = '1' and exp_temp_reg(9 downto 0) <= "1111101001" then
        explow <= '1';
      end if;
      if exp_temp_reg(10) = '1' and exp_temp_reg(9 downto 0) <= "1111100111" then
        expudf <= '1';
      end if;
    end if;
  end process explow_detect;

  
  zero <= '1' when exp_temp_reg = "00000000000" else '0';
  ones <= "11111111111" when double_reg1 = '1' else "00011111111";
  one <= '1' when exp_temp_reg = ones else '0';
  msb1 <= cout_reg when double_reg1 = '1' else exp_temp_reg(8);
  udf_temp <= (udf_in_reg and explow) or (nstd_in_reg and explow);
  ovf_temp <= (one or ovf_in_reg or msb1) and (not udf_in_reg) and (not nstd_in_reg);
  nstd_temp <= nstd_in_reg and (not expudf) and (not expnorm);
  
  output_register: process (clk, rst)
  begin  -- process output_register
    if rst = '0' then                   -- asynchronous reset (active low)
      exp_div <= (others => '0');
      expp1_div <= (others => '0');
      ovf_div <= '0';
      udf_div <= '0';
      nstd_div <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      exp_div <= exp_temp_reg;
      expp1_div <= expp1_temp_reg;
      ovf_div <= ovf_temp;
      udf_div <= udf_temp;
      nstd_div <= nstd_temp;
    end if;
  end process output_register;
    
end eadd;
