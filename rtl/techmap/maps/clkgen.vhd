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
-- Entity: 	clkgen
-- File:	clkgen.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Clock generator with tech selection
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allclkgen.all;

entity clkgen is
  generic (
    tech     : integer := DEFFABTECH;
    clk_mul  : integer := 1;
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    noclkfb  : integer := 1;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;	-- clock frequency in KHz
    clk2xen  : integer := 0;            
    clksel   : integer := 0;            -- enable clock select
    clk_odiv : integer := 1;            -- Proasic3/Fusion output divider clkA
    clkb_odiv: integer := 0;            -- Proasic3/Fusion output divider clkB
    clkc_odiv: integer := 0);           -- Proasic3/Fusion output divider clkC
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- 2x clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type;
    clk4x   : out std_logic;			-- 4x clock
    clk1xu  : out std_logic;			-- unscaled 1X clock
    clk2xu  : out std_logic;			-- unscaled 2X clock
    clkb    : out std_logic;            -- Proasic3/Fusion clkB
    clkc    : out std_logic;            -- Proasic3/Fusion clkC
    clk8x   : out std_logic);           -- 8x clock
end;

architecture struct of clkgen is
signal intclk, sdintclk : std_ulogic;
signal lock : std_ulogic;
begin
  gen : if (has_clkgen(tech) = 0) generate
    sdintclk <= pciclkin when (PCISYSCLK = 1 and PCIEN /= 0) else clkin;
    sdclk <= sdintclk; intclk <= sdintclk
-- pragma translate_off
	after 1 ns	-- create 1 ns skew between clk and sdclk
-- pragma translate_on
    ;
    clk1xu <= intclk; pciclk <= pciclkin; clk <= intclk; clkn <= not intclk;
    cgo.clklock <= '1'; cgo.pcilock <= '1'; clk2x <= '0'; clk4x <= '0';
    clkb <= '0'; clkc <= '0'; clk8x <= '0';
  end generate;
  xc7l : if (tech = virtex7) generate
    v : clkgen_virtex7
    generic map (clk_mul, clk_div, freq)
    port map (clkin, clk, clkn, clk2x ,cgi, cgo);
  end generate;
  xcu : if (tech = virtexu) generate
    v : clkgen_virtexu
    generic map (clk_mul, clk_div, freq)
    port map (clkin, clk, clkn, clk2x ,cgi, cgo);
  end generate;
  xcup : if (tech = virtexup) generate
    v : clkgen_virtexup
    generic map (clk_mul, clk_div, freq)
    port map (clkin, clk, clkn, clk2x ,cgi, cgo);
  end generate;
end;

