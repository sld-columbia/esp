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
-- Entity: 	genclkbuf
-- File:	genclkbuf.vhd
-- Author:	Jiri Gaisler, Marko Isomaki - Gaisler Research
-- Description:	Hard buffers with tech wrapper
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allclkgen.all;

entity techbuf is
  generic(
    buftype  :  integer range 0 to 6 := 0;
    tech     :  integer range 0 to NTECH := inferred);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end entity;

architecture rtl of techbuf is
component clkbuf_fusion is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_apa3 is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_igloo2 is generic( buftype :  integer range 0 to 5 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_apa3e is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_apa3l is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_actel is generic( buftype :  integer range 0 to 6 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_xilinx is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_ut025crh is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_ut130hbd is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_nextreme is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_n2x is generic(buftype : integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;

signal vcc, gnd : std_ulogic;

begin

  vcc <= '1'; gnd <= '0';

  gen : if has_techbuf(tech) = 0 generate
    o <= i;
  end generate;
  fus : if (tech = actfus) generate
    fus0 : clkbuf_fusion generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  pa3 : if (tech = apa3) generate
    pa30 : clkbuf_apa3 generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  pa3e : if (tech = apa3e) generate
    pae30 : clkbuf_apa3e generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  igl2 : if (tech = igloo2) or (tech = rtg4) generate
    igl20 : clkbuf_igloo2 generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  pa3l : if (tech = apa3l) generate
    pa3l0 : clkbuf_apa3l generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  axc : if (tech = axcel) or (tech = axdsp) generate
    axc0 : clkbuf_actel generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  xil : if (is_unisim(tech) = 1) generate
    xil0 : clkbuf_xilinx generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  ut  : if (tech = ut25) generate
    ut0 : clkbuf_ut025crh generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  ut13  : if (tech = ut130) generate
    ut0 : clkbuf_ut130hbd generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  ut09  : if (tech = ut90) generate
    ut0 : clkand_ut90nhbd port map(i => i, en => vcc, o => o, tsten => gnd);
  end generate;
  easic: if tech = easic90 generate
    eas : clkbuf_nextreme generic map (buftype => buftype) port map(i => i, o => o);
  end generate easic;
  n2x : if tech = easic45 generate
    n2x0 : clkbuf_n2x generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  
end architecture;

