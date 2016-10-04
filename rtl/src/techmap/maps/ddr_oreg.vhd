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
-- Entity:      ddr_oreg
-- File:        ddr_oreg.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: DDR output reg with tech selection
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allddr.all;

entity ddr_oreg is generic (tech : integer; arch : integer := 0; scantest: integer := 0);
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic;
      testen: in std_ulogic;
      testrst: in std_ulogic);
end;

architecture rtl of ddr_oreg is
begin

  inf : if not ((tech = lattice) or (is_unisim(tech) = 1) or
                (tech = axcel) or (tech = axdsp) or (tech = apa3) or
		(tech = apa3e) or (tech = apa3l) or (tech = igloo2) or
                (tech = rtg4)) generate
    inf0 : gen_oddr_reg generic map (scantest,0) port map (Q, C1, C2, CE, D1, D2, R, S, testen, testrst);
  end generate;

  ax : if (tech = axcel) or (tech = axdsp) generate
    ax0 : axcel_oddr_reg port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

  pa3 : if (tech = apa3) generate
    pa0 : apa3_oddr_reg port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

  pa3e : if (tech = apa3e) generate
    pa0 : apa3e_oddr_reg port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

  pa3l : if (tech = apa3l) generate
    pa0 : apa3l_oddr_reg port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

  lat : if tech = lattice generate
    lat0 : ec_oddr_reg port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

  igl2 : if (tech = igloo2) or (tech = rtg4) generate
    igl20 : igloo2_oddr_reg port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

  xil : if is_unisim(tech) = 1 generate
    xil0 : unisim_oddr_reg generic map (tech, arch)
	port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

--pragma translate_off
  assert (tech /= easic45) and (tech /= easic90)
    report "ddr_oreg: Not supported on eASIC. Use DDR pad instead."
    severity failure;
--pragma translate_on
  
end;

