------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2016, Cobham Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	gen_mul_61x61
-- File:	mul_inferred.vhd
-- Author:	Edvin Catovic - Gaisler Research
-- Description:	Generic 61x61 multplier
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdlib.all;

entity gen_mul_61x61 is
    port(A       : in std_logic_vector(60 downto 0);  
         B       : in std_logic_vector(60 downto 0);
         EN      : in std_logic;
         CLK     : in std_logic;     
         PRODUCT : out std_logic_vector(121 downto 0));
end;

architecture rtl of gen_mul_61x61 is

  signal r1, r1in, r2, r2in : std_logic_vector(121 downto 0);
  
begin
   comb : process(A, B, r1)
   begin
-- pragma translate_off
    if not (is_x(A) or is_x(B)) then
-- pragma translate_on            
      r1in <= std_logic_vector(unsigned(A) * unsigned(B));
-- pragma translate_off
    end if;
-- pragma translate_on            
      r2in <= r1;  
    end process;
 
    reg : process(clk)
    begin
      if rising_edge(clk) then
        if EN = '1' then
          r1 <= r1in;
          r2 <= r2in;
        end if;
      end if;
    end process;
    PRODUCT <= r2;
end;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.stdlib.all;

entity gen_mult_pipe is
  generic (
    a_width       : positive;                      -- multiplier word width
    b_width       : positive;                      -- multiplicand word width
    num_stages    : positive := 2;                 -- number of pipeline stages
    stall_mode    : natural range 0 to 1 := 1);     -- '0': non-stallable; '1': stallable
  port (
    clk     : in  std_logic;          -- register clock
    en      : in  std_logic;          -- register enable
    tc      : in  std_logic;          -- '0' : unsigned, '1' : signed
    a       : in  std_logic_vector(a_width-1 downto 0);  -- multiplier
    b       : in  std_logic_vector(b_width-1 downto 0);  -- multiplicand
    product : out std_logic_vector(a_width+b_width-1 downto 0));  -- product
end ;

architecture simple of gen_mult_pipe is

subtype resw is  std_logic_vector(A_width+B_width-1 downto 0);
type pipet is array (num_stages-1 downto 1) of resw;
signal p_i : pipet;
signal prod :  resw;
  
begin

  comb : process(A, B, TC)
  begin 
-- pragma translate_off
    if notx(A) and notx(B) and notx(tc) then
-- pragma translate_on
      if TC = '1' then
        prod <= signed(A) * signed(B);
      else
        prod <= unsigned(A) * unsigned(B);
      end if;
-- pragma translate_off
    else
      prod <= (others => 'X');
    end if;
-- pragma translate_on
  end process;

  w2 : if num_stages = 2 generate
    reg : process(clk)
    begin
      if rising_edge(clk) then
        if (stall_mode = 0) or (en = '1') then
          p_i(1) <= prod;
        end if;
      end if;
    end process;
  end generate;

  w3 : if num_stages > 2 generate
    reg : process(clk)
    begin
      if rising_edge(clk) then
        if (stall_mode = 0) or (en = '1') then
          p_i <= p_i(num_stages-2 downto 1) & prod;
        end if;
      end if;
    end process;
  end generate;

  product <= p_i(num_stages-1);
end;

