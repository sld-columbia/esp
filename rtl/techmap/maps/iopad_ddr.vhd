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
-- Entity: 	iopad_ddr, iopad_ddrv, iopad_ddrvv
-- File:	iopad_ddr.vhd
-- Author:	Jan Andersson - Aeroflex Gaisler
-- Description:	Wrapper that instantiates an iopad connected to DDR register.
--              Special case for easic90 tech since this tech requires that
--              oe is directly connected between DDR register and pad.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allddr.all;
use work.allpads.all;

entity iopad_ddr is
  generic (
    tech     : integer := 0;
    level    : integer := 0;
    slew     : integer := 0;
    voltage  : integer := x33v;
    strength : integer := 12;
    oepol    : integer := 0);
  port (
    pad    : inout  std_ulogic;
    i1, i2 : in  std_ulogic;            -- Input H and L
    en     : in  std_ulogic;            -- Output enable
    o1, o2 : out std_ulogic;            -- Output H and L
    c1, c2 : in  std_ulogic;
    ce     : in  std_ulogic;
    r      : in  std_ulogic;
    s      : in  std_ulogic);
end;

architecture rtl of iopad_ddr is
signal oe, oen, d, q : std_ulogic;
begin
  p : iopad generic map (tech, level, slew, voltage, strength, oepol)
    port map (pad, q, en, d);
  ddrregi : ddr_ireg generic map (tech)
    port map (o1, o2, c1, c2, ce, d, r, s);
  ddrrego : ddr_oreg generic map (tech)
    port map (q, c1, c2, ce, i1, i2, r, s);
  oe <= '0'; oen <= '0'; -- Not used in this configuration

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity iopad_ddrv is
  generic (
    tech     : integer := 0;
    level    : integer := 0;
    slew     : integer := 0;
    voltage  : integer := x33v;
    strength : integer := 12;
    width    : integer := 1;
    oepol    : integer := 0);
  port (
    pad    : inout std_logic_vector(width-1 downto 0);
    i1, i2 : in  std_logic_vector(width-1 downto 0);
    en     : in  std_ulogic;
    o1, o2 : out std_logic_vector(width-1 downto 0);
    c1, c2 : in  std_ulogic;
    ce     : in  std_ulogic;
    r      : in  std_ulogic;
    s      : in  std_ulogic);
end;
architecture rtl of iopad_ddrv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iopad_ddr generic map (tech, level, slew, voltage, strength, oepol)
      port map (pad(j), i1(j), i2(j), en, o1(j), o2(j), c1, c2, ce, r, s);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity iopad_ddrvv is
  generic (
    tech     : integer := 0;
    level    : integer := 0;
    slew     : integer := 0;
    voltage  : integer := x33v;
    strength : integer := 12;
    width    : integer := 1;
    oepol    : integer := 0);
  port (
    pad    : inout std_logic_vector(width-1 downto 0);
    i1, i2 : in  std_logic_vector(width-1 downto 0);
    en     : in  std_logic_vector(width-1 downto 0);
    o1, o2 : out std_logic_vector(width-1 downto 0);
    c1, c2 : in  std_ulogic;
    ce     : in  std_ulogic;
    r      : in  std_ulogic;
    s      : in  std_ulogic);
end;
architecture rtl of iopad_ddrvv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iopad_ddr generic map (tech, level, slew, voltage, strength, oepol)
      port map (pad(j), i1(j), i2(j), en(j), o1(j), o2(j), c1, c2, ce, r, s);
  end generate;
end;
