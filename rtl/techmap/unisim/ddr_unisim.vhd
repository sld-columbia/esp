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
-- Entity:      unisim_iddr_reg
-- File:        unisim_iddr_reg.vhd
-- Author:      David Lindh, Jiri Gaisler - Gaisler Research
-- Description: Xilinx DDR input register
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
library unisim;
use unisim.vcomponents.iddr;
use unisim.vcomponents.iddr2;

entity unisim_iddr_reg is
  generic (tech : integer := virtex7;arch : integer := 0);
  port(
         Q1 : out std_ulogic;
         Q2 : out std_ulogic;
         C1 : in std_ulogic;
         C2 : in std_ulogic;
         CE : in std_ulogic;
         D : in std_ulogic;
         R : in std_ulogic;
         S : in std_ulogic
      );
end;

architecture rtl of unisim_iddr_reg is


  signal preQ1, preQ2   : std_ulogic;
  signal D_delay : std_ulogic;

begin
     V7 : if (tech = virtex7) generate
       U0 : IDDR generic map( DDR_CLK_EDGE => "SAME_EDGE")
         Port map( Q1 => Q1, Q2 => Q2, C => C1, CE => CE,
                   D => D, R => R, S => S);
     end generate;

     VU : if (tech = virtexu) or (tech = virtexup) generate
       U0 : IDDR generic map( DDR_CLK_EDGE => "SAME_EDGE", SRTYPE => "ASYNC")
         Port map( Q1 => Q1, Q2 => Q2, C => C1, CE => CE,
                   D => D, R => R, S => S);
     end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
library unisim;
use unisim.vcomponents.oddr;
use unisim.vcomponents.oddr2;

entity unisim_oddr_reg is
  generic (tech : integer := virtex7; arch : integer := 0);
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end;

architecture rtl of unisim_oddr_reg is

  signal preD2 : std_ulogic;

begin

  V7 : if (tech = virtex7) generate
     U0 : ODDR generic map( DDR_CLK_EDGE => "SAME_EDGE")
       port map(
         Q => Q, C => C1, CE => CE, D1 => D1,
         D2 => D2, R => R, S => S);
  end generate;

  VU : if (tech = virtexu) or (tech = virtexup) generate
     U0 : ODDR generic map( DDR_CLK_EDGE => "SAME_EDGE", SRTYPE => "ASYNC")
       port map(
         Q => Q, C => C1, CE => CE, D1 => D1,
         D2 => D2, R => R, S => S);
  end generate;

end ;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
library unisim;
use unisim.vcomponents.fd;
use unisim.vcomponents.oddr2;

entity oddrc3e is
  generic ( tech : integer := virtex7);
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end;

architecture rtl of oddrc3e is

  signal preD2 : std_ulogic;

begin

  rf : FD port map ( Q => preD2, C => C1, D => D2);
  rr : ODDR2  port map ( Q => Q, C0 => C1, C1 => C2,
  CE => CE, D0 => D1, D1 => preD2, R => R, S => R);
end;
