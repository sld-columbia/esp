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

-- GF12
component gf12_inpad
  generic (PAD_TYPE : std_logic := '0');
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component gf12_iopad
  generic (PAD_TYPE : std_logic := '0');
  port (pad : inout std_logic; i, en : in std_ulogic; o : out std_logic; sr, ds0, ds1 : in std_ulogic);
end component;

component gf12_iopadien
  generic (PAD_TYPE : std_logic := '0');
  port (pad : inout std_logic; i, en : in std_ulogic; o : out std_logic; ien : in std_ulogic; sr, ds0, ds1 : in std_ulogic);
end component;

component gf12_outpad
  generic (PAD_TYPE : std_logic := '0');
  port (pad : out std_ulogic; i : in std_ulogic; sr, ds0, ds1 : in std_ulogic);
end component;

-- Xilinx
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

component virtex7_inpad_ds
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component virtex7_clkpad_ds is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

end;
