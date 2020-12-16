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
-- Entity: 	inpad_ddr, inpad_ddrv
-- File:	inpad_ddr.vhd
-- Author:	Jan Andersson - Aeroflex Gaisler
-- Description:	Wrapper that instantiates an input pad connected to a DDR_IREG.
--              The generic tech wrappers are not used for nextreme since this
--              technology is not wrapped by ddr_ireg.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allddr.all;
use work.allpads.all;

entity inpad_ddr is
  generic (
    tech     : integer := 0;
    level    : integer := 0;
    voltage  : integer := x33v;
    filter   : integer := 0;
    strength : integer := 0
    );
  port (
    pad    : in  std_ulogic;
    o1, o2 : out std_ulogic;
    c1, c2 : in  std_ulogic;
    ce     : in  std_ulogic;
    r      : in  std_ulogic;
    s      : in  std_ulogic
  );
end;

architecture rtl of inpad_ddr is

  signal d : std_ulogic;
  signal gnd : std_ulogic;

begin

  gnd <= '0';

  p : inpad generic map (tech, level, voltage, filter, strength)
    port map (pad, d);

  ddrreg : ddr_ireg generic map (tech)
    port map (o1, o2, c1, c2, ce, d, r, s, gnd, gnd);

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity inpad_ddrv is
  generic (
    tech     : integer := 0;
    level    : integer := 0;
    voltage  : integer := 0;
    filter   : integer := 0;
    strength : integer := 0;
    width    : integer := 1
    );
  port (
    pad    : in  std_logic_vector(width-1 downto 0);
    o1, o2 : out std_logic_vector(width-1 downto 0);
    c1, c2 : in  std_ulogic;
    ce     : in  std_ulogic;
    r      : in  std_ulogic;
    s      : in  std_ulogic
    );
end;

architecture rtl of inpad_ddrv is
begin

  v : for i in width-1 downto 0 generate
    x0 : inpad_ddr generic map (tech, level, voltage, filter, strength)
      port map (pad(i), o1(i), o2(i), c1, c2, ce, r, s);
  end generate;

end;
