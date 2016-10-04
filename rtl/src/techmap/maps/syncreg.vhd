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
-- Entity:      syncreg
-- File:        syncreg.vhd
-- Author:      Aeroflex Gaisler AB
-- Description: Technology wrapper for sync registers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity syncreg is
  generic (
    tech    : integer := 0;
    stages  : integer range 1 to 5 := 2
    );
  port (
    clk    : in  std_ulogic;
    d      : in  std_ulogic;
    q      : out std_ulogic
    );
end;

architecture tmap of syncreg is
  
begin
  sync0 : if has_syncreg(tech) = 0 generate
    --syncreg : block
    --  signal c : std_logic_vector(stages-1 downto 0);
    --begin
    --  x0 : process(clk)
    --  begin
    --    if rising_edge(clk) then
    --      for i in 0 to stages-1 loop
    --        c(i) <= d;
    --        if i /= 0 then c(i) = c(i-1); end if;
    --      end loop;
    --    end if;
    --  end process;
    --  q <= c(stages-1);
    --end block syncreg;
    syncreg : block
      signal c            : std_logic_vector(stages downto 0);
      attribute keep      : boolean;
      attribute keep of c : signal is true;
    begin
      c(0) <= d;
      syncregs : for i in 1 to stages generate
        dff : grdff
          generic map(tech => tech)
          port map(clk => clk, d => c(i-1), q => c(i));
      end generate;
      q <= c(stages);
    end block syncreg;
  end generate;
end;

