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
-- Entity: 	clkmux
-- File:	clkmux.vhd
-- Author:	Edvin Catovic - Gaisler Research
-- Description:	Glitch-free clock multiplexer
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allclkgen.all;

entity clkmux is
  generic(tech : integer := 0;
          rsel : integer range 0 to 1 := 0); -- registered sel
  port(
    i0, i1  :  in  std_ulogic;
    sel     :  in  std_ulogic;
    o       :  out std_ulogic;
    rst     :  in  std_ulogic := '1'
  );
end entity;

architecture rtl of clkmux is
  signal seli, sel0, sel1, cg0, cg1 : std_ulogic;  
begin

  rs : if rsel = 1 generate
    rsproc : process(i0)
    begin
      if rising_edge(i0) then seli <= sel; end if;
    end process;
  end generate;

  cs : if rsel = 0 generate seli <= sel; end generate;
  
  tec : if has_clkmux(tech) = 1 generate

    xil : if is_unisim(tech) = 1 generate
      buf : clkmux_unisim port map(sel => seli, I0 => i0, I1 => i1, O => o);
    end generate;
    rhl : if tech = rhlib18t generate
      buf : clkmux_rhlib18t port map(sel => seli, I0 => i0, I1 => i1, O => o);
    end generate;
    ut13 : if tech = ut130 generate
      x0 : clkmux_ut130hbd port map (i0 => i0, i1 => i1, sel => sel, o => o);
    end generate;
    n2x : if tech = easic45 generate
      mux : clkmux_n2x port map (i0 => i0, i1 => i1, sel => sel, o => o);
    end generate;
    ut90n : if tech = ut90 generate
      x0 : clkmux_ut90nhbd port map (i0 => i0, i1 => i1, sel => seli, o => o);
    end generate;
    saed : if tech = saed32 generate
      x0 : clkmux_saed32 port map (i0 => i0, i1 => i1, sel => seli, o => o);
    end generate;
    rhs : if tech = rhs65 generate
      x0 : clkmux_rhs65 port map (i0 => i0, i1 => i1, sel => seli, o => o);
    end generate;
    dar : if tech = dare generate
      x0 : clkmux_dare port map (i0 => i0, i1 => i1, sel => seli, o => o);
    end generate;
    rhu : if tech = rhumc generate
      x0 : clkmux_rhumc port map (i0 => i0, i1 => i1, sel => seli, o => o);
    end generate;
   
    noxil : if not((is_unisim(tech) = 1) or (tech = rhlib18t) or (tech = ut130) or
                   (tech = easic45) or (tech = ut90) or (tech = saed32) or (tech = rhs65) or (tech = dare) or (tech = rhumc)) generate
      o <= i0 when seli = '0' else i1;
    end generate;

  end generate;

  gen : if has_clkmux(tech) = 0 generate

    p0 : process(i0, rst)
    begin
      if rst = '0' then
        sel0 <= '1';      
      elsif falling_edge(i0) then
        sel0 <= (not seli) and (not sel1);
      end if;
    end process;
    
    p1 : process(i1, rst)
    begin      
      if rst = '0' then
        sel1 <= '0';
      elsif falling_edge(i1) then
        sel1 <= seli and (not sel0);
      end if;
    end process;

    cg0 <= i0 and sel0;
    cg1 <= i1 and sel1;
    o   <= cg0 or cg1;    
    
  end generate;
end architecture;




