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
  xc2v : if (tech = virtex2) or (tech = virtex4) generate
    v : clkgen_virtex2
    generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll, pcisysclk, freq, clk2xen, clksel)
    port map (clkin, pciclkin, clk, clkn, clk2x, sdclk, pciclk, cgi, cgo, clk1xu, clk2xu);
  end generate;
  xc5l : if (tech = virtex5) or (tech = virtex6) generate
    v : clkgen_virtex5
    generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll, pcisysclk, freq, clk2xen, clksel)
    port map (clkin, pciclkin, clk, clkn, clk2x, sdclk, pciclk, cgi, cgo, clk1xu, clk2xu);
  end generate;
  xc7l : if (tech =virtex7) or (tech =kintex7) or (tech =artix7) or (tech =zynq7000) generate
    v : clkgen_virtex7
    generic map (clk_mul, clk_div, freq)
    port map (clkin, clk, clkn, clk2x ,cgi, cgo);
  end generate;
  xcup : if (tech = virtexup) generate
    v : clkgen_virtexup
    generic map (clk_mul, clk_div, freq)
    port map (clkin, clk, clkn, clk2x ,cgi, cgo);
  end generate;
  xc3s : if (tech = spartan3) or (tech = spartan3e) or (tech = spartan6) generate
    v : clkgen_spartan3
    generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll, pcisysclk, freq, clk2xen, clksel)
    port map (clkin, pciclkin, clk, clkn, clk2x, sdclk, pciclk, cgi, cgo, clk1xu, clk2xu);
  end generate;
  alt : if (tech = altera) or (tech = stratix1) generate
   v : clkgen_altera_mf
   generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll, pcisysclk, freq, clk2xen)
   port map (clkin, pciclkin, clk, clkn, clk2x, sdclk, pciclk, cgi, cgo);
  end generate;
  strat2 : if (tech = stratix2) generate
   v : clkgen_stratixii
   generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll, pcisysclk, freq, clk2xen)
   port map (clkin, pciclkin, clk, clkn, clk2x, sdclk, pciclk, cgi, cgo);
  end generate;
  cyc3 : if (tech = cyclone3)  generate
   v : clkgen_cycloneiii
   generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll, pcisysclk, freq, clk2xen)
   port map (clkin, pciclkin, clk, clkn, clk2x, sdclk, pciclk, cgi, cgo);
  end generate;
  stra3 : if (tech = stratix3) or (tech = stratix4) generate
   v : clkgen_stratixiii
   generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll, pcisysclk, freq, clk2xen)
   port map (clkin, pciclkin, clk, clkn, clk2x, sdclk, pciclk, cgi, cgo);
  end generate;
  act : if (tech = axdsp) or (tech = proasic) generate
    intclk <= pciclkin when (PCISYSCLK = 1 and PCIEN /= 0) else clkin;
    sdclk <= '0'; pciclk <= pciclkin; clk <= intclk; clkn <= '0';
    cgo.clklock <= '1'; cgo.pcilock <= '1'; clk2x <= '0';
  end generate;
  axc : if (tech = axcel) generate
    pll_disabled : if (clk_mul = clk_div) generate
      intclk <= pciclkin when (PCISYSCLK = 1 and PCIEN /= 0) else clkin;
      sdclk <= '0'; pciclk <= pciclkin; clk <= intclk; clkn <= '0';
      cgo.clklock <= '1'; cgo.pcilock <= '1'; clk2x <= '0';
    end generate;
    pll_enabled : if (clk_mul /= clk_div) generate
      clk2x <= '0';
      pll : clkgen_axcelerator
        generic map (
          clk_mul   => clk_mul,
          clk_div   => clk_div,
          sdramen   => sdramen,
          sdinvclk  => 0,
          pcien     => pcien,
          pcidll    => pcidll,
          pcisysclk => pcisysclk,
          freq      => freq)
        port map(
          clkin     => clkin,
          pciclkin  => pciclkin,
          clk       => clk,
          clkn      => clkn,
          sdclk     => sdclk,
          pciclk    => pciclk,
          cgi       => cgi,
          cgo       => cgo);
    end generate;
  end generate;
  lib18t : if (tech = rhlib18t) generate
    v : clkgen_rh_lib18t
    generic map (clk_mul, clk_div)
    port map (cgi.pllrst, intclk, clk, sdclk, clk2x, clk4x);
    intclk <= pciclkin when (PCISYSCLK = 1 and PCIEN /= 0) else clkin;
    pciclk <= pciclkin; clkn <= '0';
    cgo.clklock <= '1'; cgo.pcilock <= '1';
  end generate;
  ap3 : if tech = apa3 generate
    v : clkgen_proasic3
    generic map (clk_mul, clk_div, clk_odiv, pcien, pcisysclk, freq, clkb_odiv, clkc_odiv)
    port map (clkin, pciclkin, clk, sdclk, pciclk, cgi, cgo, clkb, clkc);
    clk2x <= '0';
  end generate;
  ap3e : if tech = apa3e generate
    v : clkgen_proasic3e
    generic map (clk_mul, clk_div, clk_odiv, pcien, pcisysclk, freq, clkb_odiv, clkc_odiv)
    port map (clkin, pciclkin, clk, sdclk, pciclk, cgi, cgo, clkb, clkc);
    clk2x <= '0';
  end generate;
  ap3l : if tech = apa3l generate
    v : clkgen_proasic3l
    generic map (clk_mul, clk_div, clk_odiv, pcien, pcisysclk, freq, clkb_odiv, clkc_odiv)
    port map (clkin, pciclkin, clk, sdclk, pciclk, cgi, cgo, clkb, clkc);
    clk2x <= '0';
  end generate;
  fus : if tech = actfus generate
    v : clkgen_fusion
    generic map (clk_mul, clk_div, clk_odiv, pcien, pcisysclk, freq, clkb_odiv, clkc_odiv)
    port map (clkin, pciclkin, clk, sdclk, pciclk, cgi, cgo, clkb, clkc);
    clk2x <= '0';
  end generate;
  dr : if (tech = rhumc)  generate
   v : clkgen_rhumc
   port map (clkin, clk, clk2x, sdclk, pciclk,
	cgi, cgo, clk4x, clk1xu, clk2xu);
   clk8x <= '0';
  end generate;
  saed : if (tech = saed32)  generate
   v : clkgen_saed32
   port map (clkin, clk, clk2x, sdclk, pciclk,
	cgi, cgo, clk4x, clk1xu, clk2xu);
  end generate;
  rhs : if (tech = rhs65)  generate
   v : clkgen_rhs65
   port map (clkin, clk, clk2x, sdclk, pciclk,
	cgi, cgo, clk4x, clk1xu, clk2xu);
  end generate;
  dar : if (tech = dare)  generate
   v : clkgen_dare
   generic map (noclkfb)
   port map (clkin, clk, clk2x, sdclk, pciclk,
	cgi, cgo, clk4x, clk1xu, clk2xu, clk8x);
  end generate;

  nextreme90 : if tech = easic90 generate
    pll0 : clkgen_easic90
      generic map (
        clk_mul   => clk_mul,
        clk_div   => clk_div,
        freq      => freq,
        pcisysclk => pcisysclk,
        pcien     => pcien)
      port map (clkin, pciclkin, clk,  clk2x, clk4x, clkn, lock);
    cgo.clklock <= lock;
    cgo.pcilock <= lock;
  end generate;

  n2x : if tech = easic45 generate
    v : clkgen_n2x
      generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll,
                   pcisysclk, freq, clk2xen, clksel, 0)
      port map (clkin, pciclkin, clk, clkn, clk2x, sdclk, pciclk, cgi,
                cgo, clk1xu, clk2xu, open);
  end generate;
  ut13 : if (tech = ut130) generate
    v : clkgen_ut130hbd
    generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll, pcisysclk, freq, clk2xen, clksel)
    port map (clkin, pciclkin, clk, clkn, clk2x, clk4x, clk8x, sdclk, pciclk, cgi, cgo, clk1xu, clk2xu);
  end generate;
  ut90nhbd : if (tech = ut90) generate
    v : clkgen_ut90nhbd
    generic map (clk_mul, clk_div, sdramen, noclkfb, pcien, pcidll, pcisysclk, freq, clk2xen, clksel)
    port map (clkin, pciclkin, clk, clkn, clk2x, sdclk, pciclk, cgi, cgo, clk1xu, clk2xu);
  end generate;
end;

