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
-- Entity: 	outpad
-- File:	outpad.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	output pad with technology wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity outpad is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12; loc : std_logic := '0');
  port (pad : out std_ulogic; i : in std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end;

architecture rtl of outpad is
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
  gf12p : if (tech = gf12) generate
    x0 : gf12_outpad generic map (PAD_TYPE => loc) port map (pad, i, cfgi(2), cfgi(1), cfgi(0));
  end generate;
  xcv : if (is_unisim(tech) = 1) generate
    x0 : unisim_outpad generic map (level, slew, voltage, strength) port map (pad, i);
  end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity outpadv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := 0; strength : integer := 12; width : integer := 1;
        loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : out std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    cfgi: in  std_logic_vector(19 downto 0) := "00000000000000000000");
end;
architecture rtl of outpadv is
begin
  v : for j in width-1 downto 0 generate
    x0 : outpad generic map (tech, level, slew, voltage, strength, loc(j))
	 port map (pad(j), i(j), cfgi);
  end generate;
end;


library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity outpadvvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 12; width : integer := 1;
           loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : out std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(width*20 - 1 downto 0) := (others => '0'));
end;
architecture rtl of outpadvvv is
begin
  v : for j in width-1 downto 0 generate
    x0 : outpad generic map (tech, level, slew, voltage, strength, loc(j))
	 port map (pad(j), i(j), cfgi((j+1) * 20 - 1 downto j * 20));
  end generate;
end;
