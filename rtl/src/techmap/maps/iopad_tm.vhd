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
-- Entity:      iopad_tm, iopad_tmvv
-- File:        iopad_tm.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Tech map for IO pad with built-in test mux
------------------------------------------------------------------------------

-- This is implemented recursively by passing in the test signals via the cfgi
-- input for technologies that support it, and muxing manually for others.

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allpads.all;

entity iopad_tm is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
           voltage : integer := x33v; strength : integer := 12;
           oepol : integer := 0; filter : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic;
        test: in std_ulogic; ti,ten : in std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end;

architecture rtl of iopad_tm is
  signal mi,men: std_ulogic;
  signal mcfgi: std_logic_vector(19 downto 0);
begin

  notm: if has_tm_pads(tech)=0 generate
    mi <= ti when test='1' else i;
    men <= ten when test='1' else en;
    mcfgi <= cfgi;
  end generate;

  hastm: if has_tm_pads(tech)/=0 generate
    mi <= i;
    men <= en;
    mcfgi <= cfgi(19 downto 3) & ti & ten & test;
  end generate;

  p: iopad
    generic map (tech => tech, level => level, slew => slew,
                 voltage => voltage, strength => strength,
                 oepol => oepol, filter => filter)
    port map (pad => pad, i => mi, en => men, o => o, cfgi => mcfgi);

end;



library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity iopad_tmvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
        voltage : integer := x33v; strength : integer := 12; width : integer := 1;
        oepol : integer := 0; filter : integer := 0);
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0);
    test: in  std_ulogic;
    ti  : in  std_logic_vector(width-1 downto 0);
    ten : in  std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");  
end;
architecture rtl of iopad_tmvv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iopad_tm generic map (tech, level, slew, voltage, strength, oepol, filter)
         port map (pad(j), i(j), en(j), o(j), test, ti(j), ten(j), cfgi);
  end generate;
end;

