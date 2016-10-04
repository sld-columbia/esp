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
-- Package: 	itsqrdiv
-- File:	itsqrdiv.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Iterative square root and division
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package itsqrdiv is

  type divfsm is (idle, div1, div2, div3, div4, div5, div6, div7, div8, div9, div10, div11, div12, div13, div14, div15,
                  sqrt1, sqrt2, sqrt3, sqrt4, sqrt5, sqrt6, sqrt7, sqrt8, sqrt9, sqrt10, sqrt11, sqrt12,
                  sqrt13, sqrt14, sqrt15, sqrt16, sqrt17, sqrt18, sqrt19, sqrt20, sqrt21, sqrt22, sqrt23,
                  sqrt24);

  component divlut
    port (
      addr    : in  std_logic_vector(5 downto 0);
      romdata : out std_logic_vector(9 downto 0));
  end component;

  component sqrtlut
    port (
      addr    : in  std_logic_vector(5 downto 0);
      romdata : out std_logic_vector(9 downto 0));
  end component;

  component sqrtlut2
    port (
      addr    : in  std_logic_vector(5 downto 0);
      romdata : out std_logic_vector(19 downto 0));
  end component;

  component exp_adder_div
    port (
      clk       : in  std_ulogic;
      rst       : in  std_ulogic;
      exp       : in  std_logic_vector(10 downto 0);
      expp1     : in  std_logic_vector(10 downto 0);
      q_exp_inc : in  std_logic_vector(10 downto 0);
      ovf_in    : in  std_ulogic;
      udf_in    : in  std_ulogic;
      nstd_in   : in  std_ulogic;
      double    : in  std_ulogic;
      exp_div   : out std_logic_vector(10 downto 0);
      expp1_div : out std_logic_vector(10 downto 0);
      ovf_div   : out std_ulogic;
      udf_div   : out std_ulogic;
      nstd_div  : out std_ulogic);
  end component;

end itsqrdiv;
