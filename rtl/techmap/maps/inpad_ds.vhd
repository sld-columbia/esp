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
-- Entity: 	inpad_ds
-- File:	inpad_ds.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	input pad with technology wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity inpad_ds is
  generic (tech : integer := 0; level : integer := lvds; voltage : integer := x33v; term : integer := 0);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end;

architecture rtl of inpad_ds is
signal gnd : std_ulogic;
begin
  gnd <= '0';
  gen0 : if has_ds_pads(tech) = 0 generate
    o <= to_X01(padp) 
-- pragma translate_off
	after 1 ns
-- pragma translate_on
	;
  end generate;

  xc4v : if (tech = virtex7) or (tech = virtexu) or (tech = virtexup) generate
    u0 : virtex7_inpad_ds generic map (level, voltage) port map (padp, padn, o);
  end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity inpad_dsv is
  generic (tech : integer := 0; level : integer := lvds;
	   voltage : integer := x33v; width : integer := 1; term : integer := 0);
  port (
    padp : in  std_logic_vector(width-1 downto 0);
    padn : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end;
architecture rtl of inpad_dsv is
begin
  v : for i in width-1 downto 0 generate
    u0 : inpad_ds generic map (tech, level, voltage, term) port map (padp(i), padn(i), o(i));
  end generate;
end;

