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
-- Entity: 	syncram
-- File:	syncram.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	syncronous 1-port ram with tech selection
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;
use work.gencomp.all;
use work.allmem.all;

entity syncram is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	testen : integer := 0; custombits: integer := 1);
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic;
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
end;

architecture rtl of syncram is
  constant nctrl : integer := abits + (TESTIN_WIDTH-2) + 2;
  signal rena, wena : std_logic;
  signal dataoutx, databp, testdata : std_logic_vector((dbits -1) downto 0);
  constant SCANTESTBP : boolean := (testen = 1) and syncram_add_scan_bypass(tech)=1;
  signal xenable, xwrite: std_ulogic;

  signal gnd : std_ulogic;
  
  signal custominx,customoutx: std_logic_vector(syncram_customif_maxwidth downto 0);
  signal customclkx: std_ulogic;

begin

  gnd <= '0';

  xenable <= enable and not testin(TESTIN_WIDTH-2) when testen/=0 else enable;
  xwrite <= write and not testin(TESTIN_WIDTH-2) when testen/=0 else write;

  -- RAM bypass for scan
  scanbp : if SCANTESTBP generate
    comb : process (address, datain, enable, write, testin)
    variable tmp : std_logic_vector((dbits -1) downto 0);
    variable ctrlsigs : std_logic_vector((nctrl -1) downto 0);
    begin
      ctrlsigs := testin(TESTIN_WIDTH-3 downto 0) & write & enable & address;
      tmp := datain;
      for i in 0 to nctrl-1 loop
	tmp(i mod dbits) := tmp(i mod dbits) xor ctrlsigs(i);
      end loop;
      testdata <= tmp;
    end process;

    reg : process (clk)
    begin
      if rising_edge(clk) then
	databp <= testdata;
      end if;
    end process;
    dmuxout : for i in 0 to dbits-1 generate
      x0: grmux2 generic map (tech)
      port map (dataoutx(i), databp(i), testin(TESTIN_WIDTH-1), dataout(i));
    end generate;
  end generate;

    custominx <= (others => '0');
    customclkx <= '0';

  nocust: if syncram_has_customif(tech)=0 generate
    customoutx <= (others => '0');
  end generate;

    noscanbp : if not SCANTESTBP generate dataout <= dataoutx; end generate;

  inf : if tech = inferred generate
    x0 : generic_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, write);
  end generate;

  xcv : if (tech = virtex) generate
    x0 : virtex_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  xc2v : if (is_unisim(tech) = 1) and (tech /= virtex) generate
    x0 : unisim_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  vir  : if tech = memvirage generate
    x0 : virage_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  atrh : if tech = atc18rha generate
    x0 : atc18rha_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite,
                   testin(TESTIN_WIDTH-1 downto TESTIN_WIDTH-4));
  end generate;

  axc  : if (tech = axcel) or (tech = axdsp) generate
    x0 : axcel_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  proa : if tech = proasic generate
    x0 : proasic_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  igl2 : if tech = igloo2 generate
    x0 : igloo2_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  rt4 : if tech = rtg4 generate
    x0 : rtg4_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite,
                   open, gnd);
  end generate;

  umc18  : if tech = umc generate
    x0 : umc_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  rhu  : if tech = rhumc generate
    x0 : rhumc_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  saed : if tech = saed32 generate
    x0 : saed32_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  rhs : if tech = rhs65 generate
    x0 : rhs65_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write,
                   testin(TESTIN_WIDTH-8),testin(TESTIN_WIDTH-3),
                   custominx(0),customoutx(0),
                   testin(TESTIN_WIDTH-4),testin(TESTIN_WIDTH-5),testin(TESTIN_WIDTH-6),
                   customclkx,testin(TESTIN_WIDTH-7),'0',
                   customoutx(1), customoutx(7 downto 2));
    customoutx(customoutx'high downto 8) <= (others => '0');
  end generate;

  dar  : if tech = dare generate
    x0 : dare_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  proa3 : if tech = apa3 generate
    x0 : proasic3_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  proa3e : if tech = apa3e generate
    x0 : proasic3e_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  proa3l : if tech = apa3l generate
    x0 : proasic3l_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  fus : if tech = actfus generate
    x0 : fusion_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  ihp : if tech = ihp25 generate
    x0 : ihp25_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  ihprh : if tech = ihp25rh generate
    x0 : ihp25rh_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  alt : if (tech = altera) or (tech = stratix1) or (tech = stratix2) or
	(tech = stratix3) or (tech = stratix4) or (tech = cyclone3) generate
    x0 : altera_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  rht : if tech = rhlib18t generate
    x0 : rh_lib18t_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, xenable, xwrite, testin(TESTIN_WIDTH-3 downto TESTIN_WIDTH-4));
  end generate;

  lat : if tech = lattice generate
    x0 : ec_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  ut025 : if tech = ut25 generate
    x0 : ut025crh_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  ut09  : if tech = ut90 generate
    x0 : ut90nhbd_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite, testin(TESTIN_WIDTH-3));
  end generate;

  ut13 : if tech = ut130 generate
    x0 : ut130hbd_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  pere : if tech = peregrine generate
    x0 : peregrine_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  arti : if tech = memartisan generate
    x0 : artisan_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  cust1 : if tech = custom1 generate
    x0 : custom1_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  ecl : if tech = eclipse generate
    rena <= xenable and not write;
    wena <= xenable and write;
    x0 : eclipse_syncram_2p generic map(abits, dbits)
         port map(clk, rena, address, dataoutx, clk, address,
	          datain, wena);
  end generate;

  virage90 : if tech = memvirage90 generate
    x0 : virage90_syncram generic map(abits, dbits)
      port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  nex : if tech = easic90 generate
    x0 : nextreme_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  smic : if tech = smic013 generate
    x0 : smic13_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  tm65gplu  : if tech = tm65gplus generate
    x0 : tm65gplus_syncram generic map (abits, dbits)
      port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  cmos9sfx  : if tech = cmos9sf generate
    x0 : cmos9sf_syncram generic map (abits, dbits)
      port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  n2x  : if tech = easic45 generate
    x0 : n2x_syncram generic map (abits, dbits)
      port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

  rh13t : if tech = rhlib13t generate
    x0 : rh_lib13t_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, xenable, xwrite, testin(TESTIN_WIDTH-3 downto TESTIN_WIDTH-4));
  end generate;

  gf12x : if tech = gf12 generate
    x0 : gf12_syncram generic map (abits, dbits)
      port map (clk, address, datain, dataoutx, xenable, xwrite);
  end generate;

-- pragma translate_off
  noram : if has_sram(tech) = 0 generate
    x : process
    begin
      assert false report "syncram: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate;
  dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
    x : process
    begin
      assert false report "syncram: " & tost(2**abits) & "x" & tost(dbits) &
       " (" & tech_table(tech) & ")"
      severity note;
      wait;
    end process;
  end generate;
  chk : if GRLIB_CONFIG_ARRAY(grlib_syncram_selftest_enable) /= 0 generate
    chkblk: block
      signal refdo: std_logic_vector(dbits-1 downto 0);
      signal pren: std_ulogic;
      signal paddr: std_logic_vector(abits-1 downto 0);
    begin
      refram : generic_syncram generic map (abits, dbits)
        port map (clk, address, datain, refdo, write);
      p: process(clk)
      begin
        if rising_edge(clk) then
          assert pren/='1' or refdo=dataoutx or is_x(refdo) or is_x(paddr)
            report "Read mismatch addr=" & tost(paddr) & " impl=" & tost(dataoutx) & " ref=" & tost(refdo)
            severity error;
          pren <= enable and not write;
          paddr <= address;
        end if;
      end process;
    end block;
  end generate;
-- pragma translate_on
end;

