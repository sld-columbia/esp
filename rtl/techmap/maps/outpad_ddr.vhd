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
-- Entity: 	outpad_ddr, outpad_ddrv
-- File:	outpad_ddr.vhd
-- Author:	Jan Andersson - Aeroflex Gaisler
-- Description:	Wrapper that instantiates a DDR register connected to an
--              output pad. The generic tech wrappers are not used for nextreme
--              since this technology requires that the output enable signal is
--              connected between the DDR register and the pad.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allddr.all;
use work.allpads.all;

entity outpad_ddr is
  generic (
    tech     : integer := 0;
    level    : integer := 0;
    slew     : integer := 0;
    voltage  : integer := x33v;
    strength : integer := 12
    );
  port (
    pad    : out std_ulogic;
    i1, i2 : in  std_ulogic;
    c1, c2 : in  std_ulogic;
    ce     : in  std_ulogic;
    r      : in  std_ulogic;
    s      : in  std_ulogic
    );
end;

architecture rtl of outpad_ddr is
signal q, oe, vcc : std_ulogic;
begin
  vcc <= '1';

  ddrreg : ddr_oreg generic map (tech)
    port map (q, c1, c2, ce, i1, i2, r, s);
  p : outpad generic map (tech, level, slew, voltage, strength)
    port map (pad, q);
  oe <= '0';

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity outpad_ddrv is
  generic (
    tech     : integer := 0;
    level    : integer := 0;
    slew     : integer := 0;
    voltage  : integer := 0;
    strength : integer := 12;
    width    : integer := 1
    );
  port (
    pad    : out std_logic_vector(width-1 downto 0);
    i1, i2 : in  std_logic_vector(width-1 downto 0);
    c1, c2 : in  std_ulogic;
    ce     : in  std_ulogic;
    r      : in  std_ulogic;
    s      : in  std_ulogic
    );
end;
architecture rtl of outpad_ddrv is
begin
  v : for j in width-1 downto 0 generate
    x0 : outpad_ddr generic map (tech, level, slew, voltage, strength)
	 port map (pad(j), i1(j), i2(j), c1, c2, ce, r, s);
  end generate;
end;
