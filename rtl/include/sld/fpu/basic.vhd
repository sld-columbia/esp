------------------------------------------------------------------------------
--  This file is part of Floating Point Unit design for the Leon3 processor
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
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
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Package: 	basic
-- File:	basic.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Booth-Wallace multiplier
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package basic is

  constant QNaN_GENs : std_logic_vector(63 downto 0) := X"000000007fff0000";
  constant QNaN_GENd : std_logic_vector(63 downto 0) := X"7fffe00000000000";
  
  component ha
    port (
      in0  : in  std_ulogic;
      in1  : in  std_ulogic;
      sum  : out std_ulogic;
      cout : out std_ulogic);
  end component;

  component fa
    port (
      in0  : in  std_ulogic;
      in1  : in  std_ulogic;
      cin  : in  std_ulogic;
      sum  : out std_ulogic;
      cout : out std_ulogic); 
  end component;

  component addern
    generic (
      n : natural);
    port (
      in0   : in  std_logic_vector(n-1 downto 0);
      in1   : in  std_logic_vector(n-1 downto 0);
      cin   : in  std_ulogic;
      total : out std_logic_vector(n-1 downto 0);
      cout  : out std_ulogic);
  end component;

  component dot
    port (
      gi1, pi1 : in  std_logic;
      gi2, pi2 : in  std_logic;
      go, po   : out std_logic);
  end component;

  component pg
    port (
      a, b : in  std_logic;
      g, p : out std_logic);
  end component;

  component ppadd
    generic (
      n    : integer;
      logn : integer);
    port (
      add0_in   : in  std_logic_vector(n-1 downto 0);
      add1_in   : in  std_logic_vector(n-1 downto 0);
      carry_in  : in  std_logic;
      sum_out   : out std_logic_vector(n-1 downto 0);
      carry_out : out std_logic);
  end component;

end basic;

