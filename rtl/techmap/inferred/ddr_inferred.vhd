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
  generic (
    scantest : integer;
    noasync  : integer
  );
  port (
    q1      : out   std_ulogic;
    q2      : out   std_ulogic;
    c1      : in    std_ulogic;
    c2      : in    std_ulogic;
    ce      : in    std_ulogic;
    d       : in    std_ulogic;
    r       : in    std_ulogic;
    s       : in    std_ulogic;
    testen  : in    std_ulogic;
    testrst : in    std_ulogic
  );
end entity gen_iddr_reg;

architecture rtl of gen_iddr_reg is

  signal preq2 : std_ulogic;
  signal ri    : std_ulogic;

begin

  ri <= (not testrst) when (scantest/=0 and testen='1') else
        r;

  ddrregp : process (ri, c1) is
  begin

    if (ri = '1' and (noasync=0)) then
      q1 <= '0';
      q2 <= '0';
    elsif rising_edge(c1) then
      q1 <= d;
      q2 <= preq2;
    end if;

  end process ddrregp;

  ddrregn : process (ri, c2) is
  begin

    if (ri = '1' and (noasync=0)) then
      preq2 <= '0';
    --    elsif falling_edge(C1) then preQ2 <= D; end if;
    elsif rising_edge(c2) then
      preq2 <= d;
    end if;

  end process ddrregn;

end architecture rtl;

library ieee;
  use ieee.std_logic_1164.all;

entity gen_oddr_reg is
  generic (
    scantest : integer;
    noasync  : integer
  );
  port (
    q       : out   std_ulogic;
    c1      : in    std_ulogic;
    c2      : in    std_ulogic;
    ce      : in    std_ulogic;
    d1      : in    std_ulogic;
    d2      : in    std_ulogic;
    r       : in    std_ulogic;
    s       : in    std_ulogic;
    testen  : in    std_ulogic;
    testrst : in    std_ulogic
  );
end entity gen_oddr_reg;

architecture rtl of gen_oddr_reg is

  signal q1, q2 : std_ulogic;
  signal sel    : std_ulogic := '1';
  signal ri, si : std_ulogic;

begin

  ri <= (not testrst) when (scantest/=0 and testen='1') else
        r;
  si <= '0' when (scantest/=0 and testen='1') else
        s;

  q <= q1 when sel = '1' else
       q2;

  ddrregp : process (c1, ri, si) is
  begin

    if rising_edge(c1) then
      q1 <= d1;
      q2 <= d2;
    end if;

    if (si='1' and noasync=0) then
      q1 <= '1';
      q2 <= '1';
    end if;

    if (ri='1' and noasync=0) then
      q1 <= '0';
      q2 <= '0';
    end if;

    if (c1='1' and noasync=0) then
      sel <= '1';
    else
      sel <= '0';
    end if;

  end process ddrregp;

end architecture rtl;


