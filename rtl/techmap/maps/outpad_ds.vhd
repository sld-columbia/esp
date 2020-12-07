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
-- Entity: 	outpad_ds
-- File:	outpad_ds.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Differential output pad with technology wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity outpad_ds is
  generic (tech : integer := 0; level : integer := lvds;
	voltage : integer := x33v; oepol : integer := 0; slew : integer := 0);
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end;

architecture rtl of outpad_ds is
signal gnd, oen : std_ulogic;
begin
  gnd <= '0';
  oen <= not en when oepol /= padoen_polarity(tech) else en;
  gen0 : if has_ds_pads(tech) = 0 generate
    padp <= i 
-- pragma translate_off
	after 1 ns
-- pragma translate_on
	;
    padn <= not i
-- pragma translate_off
	after 1 ns
-- pragma translate_on
	;
  end generate;
  xcv : if (is_unisim(tech) = 1) generate
    u0 : unisim_outpad_ds generic map (level, slew, voltage) port map (padp, padn, i);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity outpad_dsv is
  generic (tech : integer := 0; level : integer := x33v;
	voltage : integer := lvds; width : integer := 1;
	oepol : integer := 0; slew : integer := 0);
  port (
    padp : out std_logic_vector(width-1 downto 0);
    padn : out std_logic_vector(width-1 downto 0);
    i, en: in  std_logic_vector(width-1 downto 0));
end;
architecture rtl of outpad_dsv is
begin
  v : for j in width-1 downto 0 generate
    u0 : outpad_ds generic map (tech, level, voltage, oepol, slew)
	 port map (padp(j), padn(j), i(j), en(j));
  end generate;
end;

