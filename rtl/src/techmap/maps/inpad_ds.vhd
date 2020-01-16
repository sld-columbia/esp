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
  xcv : if (tech = virtex2) or (tech = spartan3) generate
    u0 : unisim_inpad_ds generic map (level, voltage, term) port map (padp, padn, o);
  end generate;
  xc4v : if (tech = virtex4) or (tech = spartan3e) or (tech = virtex5) or (tech = spartan6) 
            or (tech = virtex6) or (tech = virtex7) or (tech = kintex7) or (tech =artix7) or (tech =zynq7000) or (tech = virtexu) or (tech = virtexup) generate
    u0 : virtex4_inpad_ds generic map (level, voltage) port map (padp, padn, o);
  end generate;
  axc : if (tech = axcel) or (tech = axdsp) generate
    u0 : axcel_inpad_ds generic map (level, voltage) port map (padp, padn, o);
  end generate;
  pa3 : if (tech = apa3) generate
    u0 : apa3_inpad_ds generic map (level) port map (padp, padn, o);
  end generate;
  igl2 : if (tech = igloo2) or (tech = rtg4) generate
    u0 : igloo2_inpad_ds port map (padp, padn, o);
  end generate;
  pa3e : if (tech = apa3e) generate
    u0 : apa3e_inpad_ds generic map (level) port map (padp, padn, o);
  end generate;
  pa3l : if (tech = apa3l) generate
    u0 : apa3l_inpad_ds generic map (level) port map (padp, padn, o);
  end generate;
  fus : if (tech = actfus) generate
    u0 : fusion_inpad_ds generic map (level) port map (padp, padn, o);
  end generate;
  rht : if (tech = rhlib18t) generate
    u0 : rh_lib18t_inpad_ds port map (padp, padn, o, gnd);
  end generate;
  n2x : if (tech = easic45) generate
    u0 : n2x_inpad_ds generic map (level, voltage) port map (padp, padn, o);
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

