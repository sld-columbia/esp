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
           hf : integer := 0; filter : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic; rstn : in std_ulogic := '1'; lock : out std_ulogic);
end;

architecture rtl of clkpad is
begin
  gen0 : if has_pads(tech) = 0 generate
    o <= to_X01(pad); lock <= '1';
  end generate;
  xcv2 : if (is_unisim(tech) = 1) generate
    u0 : unisim_clkpad generic map (level, voltage, arch, hf, tech) port map (pad, o, rstn, lock);
  end generate;
  axc : if (tech = axcel) or (tech = axdsp) generate
    u0 : axcel_clkpad generic map (level, voltage, arch) port map (pad, o); lock <= '1';
  end generate;
  pa : if (tech = proasic) or (tech = apa3) generate
    u0 : apa3_clkpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  pa3e : if (tech = apa3e) generate
    u0 : apa3e_clkpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  igl2 : if (tech = igloo2) or (tech = rtg4) generate
    u0 : igloo2_clkpad port map (pad, o); lock <= '1';
  end generate;
  pa3l : if (tech = apa3l) generate
    u0 : apa3l_clkpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  fus : if (tech = actfus) generate
    u0 : fusion_clkpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  atc : if (tech = atc18s) generate
    u0 : atc18_clkpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  atcrh : if (tech = atc18rha) generate
    u0 : atc18rha_clkpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  um : if (tech = umc) generate
    u0 : umc_inpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  rhu : if (tech = rhumc) generate
    u0 : rhumc_inpad generic map (level, voltage, filter) port map (pad, o); lock <= '1';
  end generate;
  saed : if (tech = saed32) generate
    u0 : saed32_inpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  rhs : if (tech = rhs65) generate
    u0 : rhs65_inpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  dar : if (tech = dare) generate
    u0 : dare_inpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  ihp : if (tech = ihp25) generate
    u0 : ihp25_clkpad generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
  rh18t : if (tech = rhlib18t) generate
    u0 : rh_lib18t_inpad port map (pad, o); lock <= '1';
  end generate;
  ut025 : if (tech = ut25) generate
    u0 : ut025crh_inpad port map (pad, o); lock <= '1';
  end generate;
  ut13 : if (tech = ut130) generate
    u0 : ut130hbd_inpad generic map (level, voltage, filter) 
	 port map (pad, o); lock <= '1';
  end generate;
  ut9 : if (tech = ut90) generate
    u0 : ut90nhbd_inpad port map (pad, o); lock <= '1';
  end generate;
  pere  : if (tech = peregrine) generate
    u0 : peregrine_inpad port map (pad, o); lock <= '1';
  end generate;
  n2x  : if (tech = easic45) generate
    u0 : n2x_inpad  generic map (level, voltage) port map (pad, o); lock <= '1';
  end generate;
end;

