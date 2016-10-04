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
-- Entity:        ringosc
-- File:          ringosc.vhd
-- Author:        Jiri Gaisler - Gaisler Research
-- Description:   Ring-oscillator with tech mapping
------------------------------------------------------------------------------
library  IEEE;
use      IEEE.Std_Logic_1164.all;
use work.gencomp.all;

entity ringosc is
   generic (tech : integer := 0);
   port (
      roen  :  in    Std_ULogic;
      roout :  out   Std_ULogic);
end ;

architecture rtl of ringosc is
  component ringosc_rhumc 
   port (
      roen  :  in    Std_ULogic;
      roout :  out   Std_ULogic);
  end component;

  component ringosc_ut130hbd
   port (
      roen  :  in    Std_ULogic;
      roout :  out   Std_ULogic);
  end component;

  component ringosc_rhs65
   port (
      roen  :  in    Std_ULogic;
      roout :  out   Std_ULogic);
  end component;

begin

  dr : if tech = rhumc generate
    drx : ringosc_rhumc port map (roen, roout);
  end generate;

  ut130r : if tech = ut130 generate
    ut130rx : ringosc_ut130hbd port map (roen, roout);
  end generate;

  rhs65r : if tech = rhs65 generate
    rhs65rx : ringosc_rhs65 port map (roen, roout);
  end generate;

-- pragma translate_off
  gen : if tech /= rhumc and tech /= ut130 and tech /= rhs65 generate
  signal tmp : std_ulogic := '0';
  begin
    tmp <= not tmp after 1 ns when roen = '1' else '0';
    roout <= tmp;
  end generate;
-- pragma translate_on

end architecture rtl;

