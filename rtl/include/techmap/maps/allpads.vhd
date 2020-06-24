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
----------------------------------------------------------------------------
-- Package: 	allpads
-- File:	allpads.vhd
-- Author:	Jiri Gaisler et al. - Aeroflex Gaisler
-- Description:	All tech pads
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

package allpads is

component gf12_inpad 
  generic (PAD_TYPE : std_logic := '0');
  port (pad : in std_ulogic; o : out std_ulogic);
end component; 

component gf12_iopad 
  generic (PAD_TYPE : std_logic := '0');
  port (pad : inout std_logic; i, en : in std_ulogic; o : out std_logic; sr, ds0, ds1 : in std_ulogic);
end component;

component gf12_outpad 
  generic (PAD_TYPE : std_logic := '0');
  port (pad : out std_ulogic; i : in std_ulogic; sr, ds0, ds1 : in std_ulogic);
end component;

component apa3_clkpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component apa3_clkpad_ds
  generic (level : integer := lvds);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component apa3_inpad
  generic (level : integer := 0; voltage : integer := 0;
           filter : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component apa3_inpad_ds
  generic (level : integer := lvds);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component apa3_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0;
           filter : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component apa3_iopad_ds
  generic (level : integer := lvds);
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component apa3_odpad 
  generic (level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component apa3_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component apa3_outpad_ds
  generic (level : integer := lvds);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end component;

component apa3_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component apa3_toutpad_ds
  generic (level : integer := lvds);
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end component;

component apa3e_clkpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component apa3e_clkpad_ds
  generic (level : integer := lvds);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component apa3e_inpad
  generic (level : integer := 0; voltage : integer := 0;
           filter : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component apa3e_inpad_ds
  generic (level : integer := lvds);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component apa3e_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0;
           filter : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component apa3e_iopad_ds
  generic (level : integer := lvds);
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component apa3e_odpad 
  generic (level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component apa3e_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component apa3e_outpad_ds
  generic (level : integer := lvds);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end component;

component apa3e_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component apa3e_toutpad_ds
  generic (level : integer := lvds);
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end component;

component igloo2_clkpad
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component igloo2_clkpad_ds
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component igloo2_inpad
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component igloo2_inpad_ds
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component igloo2_iopad
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component igloo2_iopad_ds
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component igloo2_outpad
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component igloo2_outpad_ds
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end component;

component igloo2_toutpad
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component igloo2_toutpad_ds
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end component;

component apa3l_clkpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component apa3l_clkpad_ds
  generic (level : integer := lvds);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component apa3l_inpad
  generic (level : integer := 0; voltage : integer := 0;
           filter : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component apa3l_inpad_ds
  generic (level : integer := lvds);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component apa3l_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0;
           filter : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component apa3l_iopad_ds
  generic (level : integer := lvds);
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component apa3l_odpad 
  generic (level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component apa3l_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component apa3l_outpad_ds
  generic (level : integer := lvds);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end component;

component apa3l_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component apa3l_toutpad_ds
  generic (level : integer := lvds);
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end component;

component fusion_clkpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component fusion_clkpad_ds
  generic (level : integer := lvds);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component fusion_inpad
  generic (level : integer := 0; voltage : integer := 0;
           filter : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component fusion_inpad_ds
  generic (level : integer := lvds);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component fusion_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0;
           filter : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component fusion_iopad_ds
  generic (level : integer := lvds);
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component fusion_odpad 
  generic (level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component fusion_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component fusion_outpad_ds
  generic (level : integer := lvds);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end component;

component fusion_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component fusion_toutpad_ds
  generic (level : integer := lvds);
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end component;

component axcel_inpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component; 

component axcel_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component axcel_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component axcel_odpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component axcel_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component axcel_clkpad 
  generic (level : integer := 0; voltage : integer := 0; arch : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component; 

component axcel_inpad_ds
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component; 

component axcel_outpad_ds
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end component;

component atc18_inpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component atc18_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;

component atc18_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end component;

component atc18_odpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end component;

component atc18_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic);
end component;

component atc18_clkpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component ihp25_inpad
  generic(level : integer := 0; voltage : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component ihp25rh_inpad
  generic(level : integer := 0; voltage : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component ihp25_iopad
  generic (level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;
  
component ihp25rh_iopad
  generic (level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;
  
component ihp25_outpad
  generic (level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 0);
  port (pad : out  std_logic; i : in  std_logic);
end component; 

component ihp25rh_outpad
  generic (level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 0);
  port (pad : out  std_logic; i : in  std_logic);
end component; 

component ihp25_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_logic);
end component;

component ihp25rh_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_logic);
end component;

component ihp25_clkpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component; 

component ihp25rh_clkpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component; 

component rhumc_inpad 
  generic (level : integer := 0; voltage : integer := 0; filter : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component rhumc_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;

component rhumc_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end component;

component rhumc_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic);
end component;

component saed32_inpad 
  generic (level : integer := 0; voltage : integer := 0; filter : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component saed32_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;

component saed32_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end component;

component saed32_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic);
end component;

component dare_inpad 
  generic (level : integer := 0; voltage : integer := 0; filter : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component dare_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;

component dare_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end component;

component dare_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic);
end component;

component rhs65_inpad 
  generic (level : integer := 0; voltage : integer := 0; filter : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component rhs65_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic;
        test, ti, ten: in std_ulogic);
end component;

component rhs65_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end component;

component rhs65_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic;
        test, ti, ten: in std_ulogic);
end component;

component umc_inpad 
  generic (level : integer := 0; voltage : integer := 0; filter : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component umc_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;

component umc_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end component;

component umc_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic);
end component;

component unisim_inpad 
  generic (level : integer := 0; voltage : integer := x33v);
  port (pad : in std_ulogic; o : out std_ulogic);
end component; 

component unisim_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component unisim_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component unisim_odpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component unisim_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component unisim_skew_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12; skew : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic; rst : in std_ulogic;
        o : out std_ulogic);
end component;

component unisim_clkpad 
  generic (level : integer := 0; voltage : integer := x33v; arch : integer := 0; hf : integer := 0;
           tech : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic; rstn : std_ulogic := '1'; lock : out std_ulogic);
end component; 

component unisim_inpad_ds
  generic (level : integer := lvds; voltage : integer := x33v; term : integer := 0);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component; 

component unisim_iopad_ds
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12; term : integer := 0);
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component unisim_outpad_ds
  generic (level : integer := lvds; slew : integer := 0; voltage : integer := x33v);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end component;

component unisim_clkpad_ds is
  generic (level : integer := lvds; voltage : integer := x33v; term : integer := 0);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component; 

component virtex4_inpad_ds
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component; 

component virtex4_clkpad_ds is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component; 

component rh_lib18t_inpad
  generic ( voltage : integer := 0; filter : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component rh_lib18t_iopad
  generic ( strength : integer := 4);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;

component rh_lib18t_inpad_ds is
  port (padp, padn : in std_ulogic; o : out std_ulogic; en : in std_ulogic);
end component; 

component rh_lib18t_outpad_ds is
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end component; 

component ut025crh_inpad
  generic ( level : integer := 0; voltage : integer := 0; filter : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component ut025crh_iopad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component ut025crh_outpad
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component ut025crh_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component ut025crh_lvds_combo 
  generic (voltage : integer := 0; width : integer := 1);
  port (odpadp, odpadn, ospadp, ospadn : out std_logic_vector(0 to width-1); 
        odval, osval, en : in std_logic_vector(0 to width-1); 
	idpadp, idpadn, ispadp, ispadn : in std_logic_vector(0 to width-1);
	idval, isval : out std_logic_vector(0 to width-1));
end component;

component ut130hbd_inpad
  generic ( level : integer := 0; voltage : integer := 0; filter : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component ut130hbd_iopad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0;
	   filter : integer :=0 );
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component ut130hbd_outpad
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end component;

component ut130hbd_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component ut130hbd_lvds_combo 
  generic (voltage : integer := 0; width : integer := 1);
  port (odpadp, odpadn, ospadp, ospadn : out std_logic_vector(0 to width-1); 
        odval, osval, en : in std_logic_vector(0 to width-1); 
	idpadp, idpadn, ispadp, ispadn : in std_logic_vector(0 to width-1);
	idval, isval : out std_logic_vector(0 to width-1);
        powerdown : in std_logic_vector(0 to width-1);
        powerdownrx : in std_logic_vector(0 to width-1);
	lvdsref : out std_logic);
end component;

component ut90nhbd_inpad is
  generic (
    level   : integer := 0;
    voltage : integer := 0;
    filter  : integer := 0);
  port (
    pad     : in  std_ulogic;
    o       : out std_ulogic);
end component;

component ut90nhbd_iopad  is
  generic(
    level    : integer := 0;
    slew     : integer := 0;
    voltage  : integer := 0;
    strength : integer := 0);
  port(
    pad      : inout std_ulogic;
    i        : in std_ulogic;
    en       : in std_ulogic;
    o        : out std_ulogic;
    slewctrl : in  std_ulogic);
end component;

component ut90nhbd_outpad is
  generic (
    level    : integer := 0;
    slew     : integer := 0;
    voltage  : integer := 0;
    strength : integer := 0);
  port(
    pad      : out std_ulogic;
    i        : in std_ulogic;
    slewctrl : in std_ulogic);
end component;

component ut90nhbd_toutpad  is
  generic (
    level    : integer := 0;
    slew     : integer := 0;
    voltage  : integer := 0;
    strength : integer := 0);
  port (
    pad      : out std_ulogic;
    i        : in  std_ulogic;
    en       : in  std_ulogic;
    slewctrl : in  std_ulogic);
end component;

component rhumc_lvds_combo 
  generic (voltage : integer := 0; width : integer := 1);
  port (odpadp, odpadn, ospadp, ospadn : out std_logic_vector(0 to width-1); 
        odval, osval, en : in std_logic_vector(0 to width-1); 
	idpadp, idpadn, ispadp, ispadn : in std_logic_vector(0 to width-1);
	idval, isval : out std_logic_vector(0 to width-1);
        powerdown : in std_logic_vector(0 to width-1);
        powerdownrx : in std_logic_vector(0 to width-1);
	lvdsref : out std_logic);
end component;

component umc_lvds_combo 
  generic (voltage : integer := 0; width : integer := 1);
  port (odpadp, odpadn, ospadp, ospadn : out std_logic_vector(0 to width-1); 
        odval, osval, en : in std_logic_vector(0 to width-1); 
	idpadp, idpadn, ispadp, ispadn : in std_logic_vector(0 to width-1);
	idval, isval : out std_logic_vector(0 to width-1);
	lvdsref : in std_logic);
end component;

component peregrine_inpad is
  generic (level : integer := 0; voltage : integer := 0; filter : integer := 0;
		strength : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component; 

component peregrine_iopad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component peregrine_toutpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end component;

component nextreme_inpad
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component nextreme_iopad
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;

component nextreme_toutpad
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic);
end component;

component atc18rha_inpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

component atc18rha_iopad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end component;

component atc18rha_outpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end component;

component atc18rha_odpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end component;

component atc18rha_toutpad 
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic);
end component;

component atc18rha_clkpad 
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end component; 

constant n2x_padcontrol_bits: integer := 22;
constant n2x_padcontrol_none: std_logic_vector(n2x_padcontrol_bits-1 downto 0) := (others => '0');

component n2x_inpad
  generic (level : integer := 0; voltage : integer := x33v; reg : integer := 0);
  port (pad : in  std_ulogic; o : out std_ulogic;
        clk : in  std_ulogic := '0'; rstn : in  std_ulogic := '0');
end component; 

component n2x_iopad
  generic (level : integer := 0; slew : integer := 0;
  voltage  : integer := x33v; strength : integer := 12;
  reg : integer := 0);
  port (pad : inout std_ulogic; i, en  : in std_ulogic; o : out std_ulogic;
        compen, compupd: in std_ulogic;
        pcomp, ncomp: in std_logic_vector(4 downto 0);
        pslew, nslew: in std_logic_vector(3 downto 0);
        clk : in  std_ulogic := '0'; rstn : in  std_ulogic := '0');
end component;

component n2x_outpad
  generic (level : integer := 0; slew : integer := 0;
  voltage : integer := 0; strength : integer := 12;
  reg : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic;
        compen, compupd: in std_ulogic;
        pcomp, ncomp: in std_logic_vector(4 downto 0);
        pslew, nslew: in std_logic_vector(3 downto 0);
        clk : in  std_ulogic := '0'; rstn : in  std_ulogic := '0');
end component;

component n2x_toutpad
  generic (level : integer := 0; slew : integer := 0;
  voltage  : integer := 0; strength : integer := 12;
  reg : integer := 0);
  port (pad : out std_ulogic; i, en : in  std_ulogic;
        compen, compupd: in std_ulogic;
        pcomp, ncomp: in std_logic_vector(4 downto 0);
        pslew, nslew: in std_logic_vector(3 downto 0);
        clk : in  std_ulogic := '0'; rstn : in  std_ulogic := '0');
end component;

component n2x_inpad_ds
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component n2x_iopad_ds
  generic (level : integer := 0; slew : integer := 0;
  voltage : integer := x33v; strength : integer := 12);
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component n2x_outpad_ds
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end component;

component n2x_inpad_ddr
  generic (level : integer := 0; voltage : integer := x33v);
  port (pad : in std_ulogic; o1, o2 : out std_ulogic; c1, c2 : in std_ulogic;
  ce : in std_ulogic; r : in std_ulogic; s : in std_ulogic);
end component;

component n2x_inpad_ddrv
  generic (level : integer := 0; voltage : integer := x33v; width : integer := 1);
  port (
    pad    : in  std_logic_vector(width-1 downto 0);
    o1, o2 : out std_logic_vector(width-1 downto 0);
    c1, c2 : in  std_ulogic; ce : in  std_ulogic;
    r      : in  std_ulogic; s  : in  std_ulogic);
end component;

component n2x_sdram_phy
  generic (
    level    : integer := 0;
    voltage  : integer := x33v;
    strength : integer := 12;
    aw       : integer := 15;               -- # address bits
    dw       : integer := 32;               -- # data bits
    ncs      : integer := 2;
    reg      : integer := 0);               -- 1: include registers on all signals
  port (
    -- SDRAM interface
    addr      : out   std_logic_vector(aw-1 downto 0);
    dq        : inout std_logic_vector(dw-1 downto 0);
    cke       : out   std_logic_vector(ncs-1 downto 0);
    sn        : out   std_logic_vector(ncs-1 downto 0);
    wen       : out   std_ulogic;
    rasn      : out   std_ulogic;
    casn      : out   std_ulogic;
    dqm       : out   std_logic_vector(dw/8-1 downto 0);

    -- Interface toward memory controller
    laddr     : in    std_logic_vector(aw-1 downto 0);
    ldq_din   : out   std_logic_vector(dw-1 downto 0);
    ldq_dout  : in    std_logic_vector(dw-1 downto 0);
    ldq_oen   : in    std_logic_vector(dw-1 downto 0);
    lcke      : in    std_logic_vector(ncs-1 downto 0);
    lsn       : in    std_logic_vector(ncs-1 downto 0);
    lwen      : in    std_ulogic;
    lrasn     : in    std_ulogic;
    lcasn     : in    std_ulogic;
    ldqm      : in    std_logic_vector(dw/8-1 downto 0);

    -- Only used when reg generic is non-zero
    rstn      : in  std_ulogic;         -- Registered pads reset
    clk       : in  std_ulogic;         -- SDRAM clock for registered pads
    
    -- Optional pad configuration inputs
    cfgi_cmd  : in std_logic_vector(19 downto 0) := "00000000000000000000"; -- CMD pads
    cfgi_dq   : in std_logic_vector(19 downto 0) := "00000000000000000000"  -- DQ pads
  );
end component;



end;

