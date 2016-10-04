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
-- Entity: 	allmul
-- File:	allmul.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Multiplier components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package allmul is

  component mul_dw is
    generic ( 
         a_width       : positive := 2;                      -- multiplier word width
         b_width       : positive := 2;                      -- multiplicand word width
         num_stages    : positive := 2;                 -- number of pipeline stages
         stall_mode    : natural range 0 to 1 := 1      -- '0': non-stallable; '1': stallable
    );   
    port(a       : in std_logic_vector(a_width-1 downto 0);  
         b       : in std_logic_vector(b_width-1 downto 0);
         clk     : in std_logic;     
         en      : in std_logic;     
         sign    : in std_logic;     
         product : out std_logic_vector(a_width+b_width-1 downto 0));
  end component;

  component gen_mult_pipe
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
  end component;

  component axcel_mul_33x33_signed
   generic (
      pipe:          Integer := 0);
   port (
      a:       in    Std_Logic_Vector(32 downto 0);
      b:       in    Std_Logic_Vector(32 downto 0);
      en:      in    Std_Logic;
      clk:     in    Std_Logic;
      p:       out   Std_Logic_Vector(65 downto 0));
  end component;


end;

