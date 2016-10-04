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
-- Entity: 	skew_outpad
-- File:	skew_outpad.vhd
-- Author:	Nils-Johan Wessman - Gaisler Research
-- Description:	output pad with technology wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity skew_outpad is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12; skew : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic; rst : in std_ulogic;
        o : out std_ulogic);
end; 

architecture rtl of skew_outpad is
signal padx, gnd, vcc : std_ulogic;
begin
  gnd <= '0'; vcc <= '1';
  gen0 : if has_pads(tech) = 0 generate
    pad <= i 
-- pragma translate_off
	after 2 ns
-- pragma translate_on
 	when slew = 0 else i;
  end generate;
  xcv : if (is_unisim(tech) = 1) generate
    x0 : unisim_skew_outpad generic map (level, slew, voltage, strength, skew) port map (pad, i, rst, o);
  end generate;
end;

