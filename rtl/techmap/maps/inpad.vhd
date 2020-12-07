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
-- Entity: 	inpad
-- File:	inpad.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	input pad with technology wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity inpad is
  generic (tech : integer := 0; level : integer := 0;
	voltage : integer := x33v; filter : integer := 0;
	strength : integer := 0; loc : std_logic := '0');
  port (pad : in std_ulogic; o : out std_ulogic);
end;

architecture rtl of inpad is
begin
  gen0 : if has_pads(tech) = 0 generate
    o <= transport to_X01(pad)
-- pragma translate_off
 	after 1 ns
-- pragma translate_on
	;
  end generate;
  gf12p : if (tech = gf12) generate
    x0 : gf12_inpad generic map (PAD_TYPE => loc) port map (pad, o);
  end generate;
  xcv : if (is_unisim(tech) = 1) generate
    x0 : unisim_inpad generic map (level, voltage) port map (pad, o);
  end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity inpadv is
  generic (tech : integer := 0; level : integer := 0;
	   voltage : integer := 0; width : integer := 1;
           filter : integer := 0; strength : integer := 0;
           loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end;
architecture rtl of inpadv is
begin
  v : for i in width-1 downto 0 generate
    x0 : inpad generic map (tech, level, voltage, filter, strength, loc(i)) port map (pad(i), o(i));
  end generate;
end;

