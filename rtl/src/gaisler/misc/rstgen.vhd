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
-- Entity: 	rstgen
-- File:	rstgen.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Reset generation with glitch filter
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.gencomp.all;

entity rstgen is
  generic (
    acthigh : integer := 0;
    syncrst : integer := 0;
    scanen  : integer := 0;
    syncin  : integer := 0);
  port (
    rstin     : in  std_ulogic;
    clk       : in  std_ulogic;
    clklock   : in  std_ulogic;
    rstout    : out std_ulogic;
    rstoutraw : out std_ulogic;
    testrst   : in  std_ulogic := '0';
    testen    : in  std_ulogic := '0'
  );
end;

architecture rtl of rstgen is

signal r : std_logic_vector(4 downto 0);
signal rst, rstoutl, clklockl, arst : std_ulogic;

signal rstsyncin      : std_ulogic;
signal inrst_syncreg  : std_ulogic;
signal genrst         : std_ulogic;
signal genrst_syncreg : std_logic_vector(1 downto 0);

attribute equivalent_register_removal: string;   
attribute keep:string;

attribute equivalent_register_removal of r              : signal is "no";
attribute equivalent_register_removal of rstsyncin      : signal is "no";
attribute equivalent_register_removal of inrst_syncreg  : signal is "no";
attribute equivalent_register_removal of genrst         : signal is "no";
attribute equivalent_register_removal of genrst_syncreg : signal is "no";
attribute equivalent_register_removal of rst, rstoutl, clklockl, arst : signal is "no";

attribute keep of r : signal is "true";
attribute keep of rstsyncin      : signal is "true";
attribute keep of inrst_syncreg  : signal is "true";
attribute keep of genrst         : signal is "true";
attribute keep of genrst_syncreg : signal is "true";
attribute keep of rst, rstoutl, clklockl, arst : signal is "true";

begin

  nosyncinrst : if syncin = 0 generate
    rst <= not rstin when acthigh = 1 else rstin;
    clklockl <= clklock;
  end generate;

  syncinrst : if syncin = 1 generate
    rstsyncin <= not rstin when acthigh = 1 else rstin;

    syncreg0 : syncreg port map (clk, rstsyncin, inrst_syncreg);

    genrst <= testrst when (scanen = 1) and (testen = '1') else inrst_syncreg;

    gensyncrest : process (clk, genrst) begin
      if rising_edge(clk) then 
        genrst_syncreg(0) <= '1'; 
        genrst_syncreg(1) <= genrst_syncreg(0); 
      end if;
      if ( genrst = '0') then genrst_syncreg <= (others => '0'); end if;
    end process;
    
    rst <= genrst_syncreg(1);

    syncreg1 : syncreg port map (clk, clklock, clklockl);
    
  end generate;

  rstoutraw <= not rstin when acthigh = 1 else rstin;
  
  arst <= testrst when (scanen = 1) and (testen = '1') else rst;
  async : if (syncrst = 0 and syncin = 0) generate
    reg1 : process (clk, arst) begin
      if rising_edge(clk) then 
        r <= r(3 downto 0) & clklockl; 
        rstoutl <= r(4) and r(3) and r(2);
      end if;
      if (arst = '0') then r <= "00000"; rstoutl <= '0'; end if;
    end process;
    rstout <= (rstoutl and rst) when scanen = 1 else rstoutl;
  end generate;

  sync : if (syncrst = 1 or syncin = 1) generate
    reg1 : process (clk) begin
      if rising_edge(clk) then 
        r <= (r(3 downto 0) & clklockl) and (rst & rst & rst & rst & rst); 
        rstoutl <= r(4) and r(3) and r(2);
      end if;
    end process;
    rstout <= rstoutl and rst;
  end generate;

end;

