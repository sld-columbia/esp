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
------------------------------------------------------------------------------
-- Delayed bidirectional wire 
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity delay_wire is
  generic(
    data_width  : integer := 1;
    delay_atob  : real := 0.0;
    delay_btoa  : real := 0.0
  );
  port(
    a : inout std_logic_vector(data_width-1 downto 0);
    b : inout std_logic_vector(data_width-1 downto 0);
    x : in std_logic_vector(data_width-1 downto 0) := (others => '0')
  );
end delay_wire;

architecture rtl of delay_wire is

signal a_dly,b_dly : std_logic_vector(data_width-1 downto 0) := (others => 'Z');
constant zvector : std_logic_vector(data_width-1 downto 0) := (others => 'Z');

  function errinj(a,b: std_logic_vector) return std_logic_vector is
    variable r: std_logic_vector(a'length-1 downto 0);
  begin
    r := a;
    for k in a'length-1 downto 0 loop
      if (a(k)='0' or a(k)='1') and b(k)='1' then
        r(k) := not a(k);
      end if;
    end loop;
    return r;
  end;

begin
  
  process(a)
  begin
    if a'event then
      if b_dly = zvector then
        a_dly <= transport a after delay_atob*1 ns;
      else
        a_dly <= (others => 'Z');
      end if;
    end if;
  end process;
  
  process(b)
  begin
    if b'event then
      if a_dly = zvector then
        b_dly <= transport errinj(b,x) after delay_btoa*1 ns;
      else
        b_dly <= (others => 'Z');
      end if;
    end if;
  end process;

  a <= b_dly; b <= a_dly;

end;

