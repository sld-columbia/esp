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
-- Entity: 	clkpad
-- File:	clkpad.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Clock pad with technology wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity clkpad is
  generic (tech : integer := 0; level : integer := 0;
	   voltage : integer := x33v; arch : integer := 0;
           hf : integer := 0; filter : integer := 0; loc : std_logic := '0');
  port (pad : in std_ulogic; o : out std_ulogic; rstn : in std_ulogic := '1'; lock : out std_ulogic);
end;

architecture rtl of clkpad is
begin
  gen0 : if has_pads(tech) = 0 generate
    o <= to_X01(pad); lock <= '1';
  end generate;
  gf12p : if (tech = gf12) generate
    x0 : gf12_inpad generic map (PAD_TYPE => loc) port map (pad, o);
    lock <= '1';
  end generate;
  xcv2 : if (is_unisim(tech) = 1) generate
    u0 : unisim_clkpad generic map (level, voltage, arch, hf, tech) port map (pad, o, rstn, lock);
  end generate;
end;

