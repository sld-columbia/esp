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
-- Entity:      gen_iddr_reg
-- File:        gen_iddr_reg.vhd
-- Author:      David Lindh, Jiri Gaisler - Gaisler Research
-- Description: Generic DDR input reg
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity gen_iddr_reg is
  generic (scantest: integer; noasync: integer);
  port(
         Q1 : out std_ulogic;
         Q2 : out std_ulogic;
         C1 : in std_ulogic;
         C2 : in std_ulogic;
         CE : in std_ulogic;
         D : in std_ulogic;
         R : in std_ulogic;
         S : in std_ulogic;
         testen: in std_ulogic;
         testrst: in std_ulogic
      );
end;
  
architecture rtl of gen_iddr_reg is
  signal preQ2 : std_ulogic;
  signal RI: std_ulogic;
begin

  RI <= (not testrst) when (scantest/=0 and testen='1') else R;

  ddrregp : process(RI,C1)
  begin
    if RI = '1' and (noasync=0) then Q1 <= '0'; Q2 <= '0';
    elsif rising_edge(C1) then Q1 <= D; Q2 <= preQ2; end if;
  end process;

  ddrregn : process(RI,C2)
  begin
    if RI = '1' and (noasync=0) then preQ2 <= '0';
--    elsif falling_edge(C1) then preQ2 <= D; end if;
    elsif rising_edge(C2) then preQ2 <= D; end if;
  end process;

end;

library ieee;
use ieee.std_logic_1164.all;

entity gen_oddr_reg is
  generic (scantest: integer; noasync: integer);
  port (
      Q : out std_ulogic;
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

architecture rtl of gen_oddr_reg is
  signal Q1,Q2: std_ulogic;
  signal SEL : std_ulogic := '1';
  signal RI,SI: std_ulogic;
begin

  RI <= (not testrst) when (scantest/=0 and testen='1') else R;
  SI <= '0' when (scantest/=0 and testen='1') else S;

  Q <= Q1 when SEL = '1' else Q2;
  
  ddrregp: process(C1,RI,SI)
  begin
    if rising_edge(C1) then Q1 <= D1; Q2 <= D2; end if;
    if SI='1' and noasync=0 then Q1 <= '1'; Q2 <= '1'; end if;
    if RI='1' and noasync=0 then Q1 <= '0'; Q2 <= '0'; end if;
    if C1='1' and noasync=0 then SEL <= '1'; else SEL <= '0'; end if;
  end process;
  
end;
  

