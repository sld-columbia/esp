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
-- Package: 	allclkgen
-- File:	allclkgen.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Clock generator interface package
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

package allclkgen is


component clkgen_virtex7
  generic (
    clk_mul  : integer := 1;
    clk_div  : integer := 1;
    freq     : integer := 25000);
  port (
    clkin   : in  std_logic;
    clk     : out std_logic;      -- main clock
    clk90   : out std_ulogic;     -- main clock 90deg
    clkio   : out std_ulogic;     -- IO ref clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end component;

component clkgen_virtexup is
  generic (
    clk_mul : integer;
    clk_div : integer;
    freq    : integer);
  port (
    clkin : in  std_ulogic;
    clk   : out std_ulogic;
    clkn  : out std_ulogic;
    clkio : out std_ulogic;
    cgi   : in  clkgen_in_type;
    cgo   : out clkgen_out_type);
end component clkgen_virtexup;

component clkgen_virtexu is
  generic (
    clk_mul : integer;
    clk_div : integer;
    freq    : integer);
  port (
    clkin : in  std_ulogic;
    clk   : out std_ulogic;
    clkn  : out std_ulogic;
    clkio : out std_ulogic;
    cgi   : in  clkgen_in_type;
    cgo   : out clkgen_out_type);
end component clkgen_virtexu;


component clkand_unisim
  port(
    i      :  in  std_ulogic;
    en     :  in  std_ulogic;
    o      :  out std_ulogic
  );
end component;


component clkmux_unisim
  port(
    i0, i1  :  in  std_ulogic;
    sel     :  in  std_ulogic;
    o       :  out std_ulogic
  );
end component;

component clkmuxctrl_unisim
  port (
    i0  : in  std_ulogic;
    i1  : in  std_ulogic;
    sel : in  std_ulogic;
    o   : out std_ulogic
  );
end component;

end;
