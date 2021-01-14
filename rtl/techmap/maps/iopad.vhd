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
-- Entity: 	iopad
-- File:	iopad.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	io pad with technology wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity iopad is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0; filter : integer := 0; loc : std_logic := '0');
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end;

architecture rtl of iopad is
signal oen : std_ulogic;
begin
  oen <= not en when oepol /= padoen_polarity(tech) else en;
  gen0 : if has_pads(tech) = 0 generate
    pad <= transport i 
-- pragma translate_off
	after 2 ns 
-- pragma translate_on
	when oen = '0' and slew = 0 else i when oen = '0'
-- pragma translate_off
           else 'X' after 2 ns when is_x(oen) and slew = 0
           else 'X' when is_x(oen)
-- pragma translate_on
           else 'Z' 
-- pragma translate_off
	after 2 ns 
-- pragma translate_on
	when slew = 0 else 'Z';
    o <= transport to_X01(pad) 
-- pragma translate_off
	after 1 ns
-- pragma translate_on
	;
  end generate;
  gf12p : if (tech = gf12) generate
    x0 : gf12_iopad
         generic map (PAD_TYPE => loc) port map (pad, i, oen, o, cfgi(2), cfgi(1), cfgi(0));
  end generate;
  xcv : if (is_unisim(tech) = 1) generate
    x0 : unisim_iopad generic map (level, slew, voltage, strength)
	 port map (pad, i, oen, o);
  end generate;
end;


library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity iopadien is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0; filter : integer := 0; loc : std_logic := '0');
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic; ien : in std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end;

architecture rtl of iopadien is
signal oen   : std_ulogic;
signal ien_i : std_ulogic;
begin
  oen   <= not en  when oepol /= padoen_polarity(tech) else en;
  ien_i <= not ien when oepol /= padoen_polarity(tech) else ien;

  gen0 : if has_pads(tech) = 0 generate
    pad <= transport i
-- pragma translate_off
	after 2 ns
-- pragma translate_on
	when oen = '0' and slew = 0 else i when oen = '0'
-- pragma translate_off
           else 'X' after 2 ns when is_x(oen) and slew = 0
           else 'X' when is_x(oen)
-- pragma translate_on
           else 'Z'
-- pragma translate_off
	after 2 ns
-- pragma translate_on
	when slew = 0 else 'Z';
    o <= transport to_X01(pad)
-- pragma translate_off
	after 1 ns
-- pragma translate_on
	;
  end generate;

  gf12p : if (tech = gf12) generate
    x0 : gf12_iopadien
         generic map (PAD_TYPE => loc) port map (pad, i, oen, o, ien_i, cfgi(2), cfgi(1), cfgi(0));
  end generate;

  xcv : if (is_unisim(tech) = 1) generate
    x0 : unisim_iopad generic map (level, slew, voltage, strength)
	 port map (pad, i, oen, o);
  end generate;
end;



library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity iopadv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0; filter : integer := 0;
        loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_ulogic;
    o   : out std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end;
architecture rtl of iopadv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iopad generic map (tech, level, slew, voltage, strength, oepol, filter, loc(j))
	 port map (pad(j), i(j), en, o(j), cfgi);
  end generate;
end;


library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity iopadienv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0; filter : integer := 0;
        loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0);
    ien : in  std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end;
architecture rtl of iopadienv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iopadien generic map (tech, level, slew, voltage, strength, oepol, filter, loc(j))
	 port map (pad(j), i(j), en(j), o(j), ien(j), cfgi);
  end generate;
end;



library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity iopadvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0; filter : integer := 0;
        loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");  
end;
architecture rtl of iopadvv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iopad generic map (tech, level, slew, voltage, strength, oepol, filter, loc(j))
	 port map (pad(j), i(j), en(j), o(j), cfgi);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity iopadvvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0; filter : integer := 0;
        loc : std_logic_vector := (31 downto 0 => '0'));

  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(width*20 - 1 downto 0) := (others => '0'));
end;
architecture rtl of iopadvvv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iopad generic map (tech, level, slew, voltage, strength, oepol, filter, loc(j))
	 port map (pad(j), i(j), en(j), o(j), cfgi((j+1) * 20 - 1 downto j * 20));
  end generate;
end;

