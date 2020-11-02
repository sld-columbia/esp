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
-- Entity: 	syncram_2p
-- File:	syncram_2p.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	syncronous 2-port ram with tech selection
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allmem.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity syncram_2p is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0; testen : integer := 0;
	words : integer := 0; custombits : integer := 1);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
end;

architecture rtl of syncram_2p is

constant nctrl : integer := abits*2 + (TESTIN_WIDTH-2) + 2;

signal gnd : std_ulogic;
signal vgnd : std_logic_vector(dbits-1 downto 0);
signal dataoutx, dataoutxx  : std_logic_vector((dbits -1) downto 0);
signal tmode: std_ulogic;
signal testdata : std_logic_vector((dbits -1) downto 0);
signal renable2 : std_ulogic;
constant SCANTESTBP : boolean := (testen = 1) and syncram_add_scan_bypass(tech)=1;
constant iwrfst : integer := (1-syncram_2p_write_through(tech)) * wrfst;
signal xrenable,xwrite : std_ulogic;

signal custominx,customoutx: std_logic_vector(syncram_customif_maxwidth downto 0);
signal customclkx: std_ulogic;

component memrwcol is
  generic (
    techwrfst : integer;
    techrwcol : integer;
    techrdhold : integer;
    abits: integer;
    dbits: integer;
    sepclk: integer;
    wrfst: integer
    );
  port (
    clk1     : in  std_ulogic;
    clk2     : in  std_ulogic;
    uenable1 : in  std_ulogic;
    uwrite1  : in  std_ulogic;
    uaddress1: in  std_logic_vector((abits-1) downto 0);
    udatain1 : in  std_logic_vector((dbits-1) downto 0);
    udataout1: out std_logic_vector((dbits-1) downto 0);
    uenable2 : in  std_ulogic;
    uwrite2  : in  std_ulogic;
    uaddress2: in  std_logic_vector((abits-1) downto 0);
    udatain2 : in  std_logic_vector((dbits-1) downto 0);
    udataout2: out std_logic_vector((dbits-1) downto 0);
    menable1 : out std_ulogic;
    menable2 : out std_ulogic;
    mdataout1: in  std_logic_vector((dbits-1) downto 0);
    mdataout2: in  std_logic_vector((dbits-1) downto 0);
    testmode : in  std_ulogic;
    testdata : in  std_logic_vector((dbits-1) downto 0)
    );
end component;

begin

  gnd <= '0'; vgnd <= (others => '0');

  xrenable <= renable and not testin(TESTIN_WIDTH-2) when testen/=0 else renable;
  xwrite <= write and not testin(TESTIN_WIDTH-2) when testen/=0 else write;
  dataout <= dataoutxx;

  rwcol0: memrwcol
    generic map (
      techwrfst  => syncram_2p_write_through(tech),
      techrwcol  => syncram_2p_dest_rw_collision(tech),
      techrdhold => syncram_2p_readhold(tech),
      abits      => abits,
      dbits      => dbits,
      sepclk     => sepclk,
      wrfst      => wrfst)
    port map (
      clk1      => rclk,
      clk2      => wclk,
      uenable1  => xrenable,
      uwrite1   => '0',
      uaddress1 => raddress,
      udatain1  => vgnd,
      udataout1 => dataoutxx,
      uenable2  => '1',
      uwrite2   => write,
      uaddress2 => waddress,
      udatain2  => datain,
      udataout2 => open,
      menable1  => renable2,
      menable2  => open,
      mdataout1 => dataoutx,
      mdataout2 => vgnd,
      testmode  => tmode,
      testdata  => testdata
      );

  tmode <= testin(TESTIN_WIDTH-1) when SCANTESTBP else '0';
  scanbp : if SCANTESTBP generate
    comb : process (waddress, raddress, datain, renable, write, testin)
      variable tmp : std_logic_vector((dbits -1) downto 0);
      variable ctrlsigs : std_logic_vector((nctrl -1) downto 0);
    begin
      ctrlsigs := testin(TESTIN_WIDTH-3 downto 0) & write & renable & raddress & waddress;
      tmp := datain;
      for i in 0 to nctrl-1 loop
        tmp(i mod dbits) := tmp(i mod dbits) xor ctrlsigs(i);
      end loop;
      testdata <= tmp;
    end process;
  end generate;
  noscanbp : if not SCANTESTBP generate
    testdata <= (others => '0');
  end generate;

    custominx <= (others => '0');
    customclkx <= '0';

  nocust: if syncram_has_customif(tech)=0 generate
    customoutx <= (others => '0');
  end generate;

  inf : if tech = inferred generate
    x0 : generic_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, wclk, raddress, waddress, datain, write, dataoutx);
  end generate;

  xcv : if tech = virtex generate
    x0 : virtex_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, xwrite, xwrite,
                   rclk, raddress, vgnd, dataoutx, renable2, gnd);
  end generate;

  xc2v : if (is_unisim(tech) = 1) and (tech /= virtex)generate
    x0 : unisim_syncram_2p generic map (abits, dbits, sepclk, iwrfst)
         port map (rclk, renable2, raddress, dataoutx, wclk,
		   xwrite, waddress, datain);
  end generate;

  vir  : if tech = memvirage generate
   d39 : if dbits = 39 generate
    x0 : virage_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, xwrite, waddress, datain);
   end generate;
   d32 : if dbits <= 32 generate
    x0 : virage_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, xwrite, xwrite,
                   rclk, raddress, vgnd, dataoutx, renable2, gnd);
   end generate;
  end generate;

  atrh : if tech = atc18rha generate
    x0 : atc18rha_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, xwrite, waddress, datain, testin(TESTIN_WIDTH-1 downto TESTIN_WIDTH-4));
  end generate;

  axc  : if (tech = axcel) or (tech = axdsp) generate
    x0 : axcel_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  proa : if tech = proasic generate
    x0 : proasic_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  proa3 : if tech = apa3 generate
    x0 : proasic3_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  proa3e : if tech = apa3e generate
    x0 : proasic3e_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  proa3l : if tech = apa3l generate
    x0 : proasic3l_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  igl2 : if tech = igloo2 generate
    x0 : igloo2_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  rt4 : if tech = rtg4 generate
    x0 : rtg4_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx, open,
                   wclk, xwrite, waddress, datain, gnd);
  end generate;

  saed : if tech = saed32 generate
--    x0 : saed32_syncram_2p generic map (abits, dbits, sepclk)
--         port map (rclk, renable2, raddress, dataoutx,
--		   wclk, waddress, datain, xwrite);
       x0 : generic_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, wclk, raddress, waddress, datain, write, dataoutx);
  end generate;

  rhs : if tech = rhs65 generate
    x0 : rhs65_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, waddress, datain, write,
                   testin(TESTIN_WIDTH-8),testin(TESTIN_WIDTH-3),
                   custominx(0),customoutx(0),
                   testin(TESTIN_WIDTH-4),testin(TESTIN_WIDTH-5),testin(TESTIN_WIDTH-6),
                   customclkx,
                   testin(TESTIN_WIDTH-7),'0',customoutx(1),
                   customoutx(7 downto 2));
    customoutx(customoutx'high downto 8) <= (others => '0');
  end generate;

  dar : if tech = dare generate
    x0 : dare_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  rhu : if tech = rhumc generate
    x0 : rhumc_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  fus : if tech = actfus generate
    x0 : fusion_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  ihp : if tech = ihp25 generate
    x0 : generic_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, wclk, raddress, waddress, datain, xwrite, dataoutx);
  end generate;

-- NOTE: port 1 on altsyncram must be a read port due to Cyclone II M4K write issue
  alt : if (tech = altera) or (tech = stratix1) or (tech = stratix2) or
	(tech = stratix3) or (tech = stratix4) or (tech = cyclone3) generate
    x0 : altera_syncram_dp generic map (abits, dbits)
         port map (rclk, raddress, vgnd, dataoutx, renable2, gnd,
                   wclk, waddress, datain, open, xwrite, xwrite);
  end generate;

  rh_lib18t0 : if tech = rhlib18t generate
    x0 : rh_lib18t_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx, wclk, xwrite, waddress, datain,
                   testin(TESTIN_WIDTH-1 downto TESTIN_WIDTH-4));
  end generate;

  lat : if tech = lattice generate
    x0 : ec_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, xwrite, xwrite,
                   rclk, raddress, vgnd, dataoutx, renable2, gnd);
  end generate;

  ut025 : if tech = ut25 generate
    x0 : ut025crh_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  ut09 : if tech = ut90 generate
    x0 : ut90nhbd_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, xwrite, waddress, datain, testin(TESTIN_WIDTH-3));
  end generate;

  ut13 : if tech = ut130 generate
    x0 : ut130hbd_syncram_2p generic map (abits, dbits, words)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, xwrite, waddress, datain);
  end generate;

  arti : if tech = memartisan generate
    x0 : artisan_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, xwrite, waddress, datain);
  end generate;

  cust1 : if tech = custom1 generate
    x0 : custom1_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, xwrite, waddress, datain);
  end generate;

  ecl : if tech = eclipse generate
    x0 : eclipse_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, xwrite);
  end generate;

  vir90  : if tech = memvirage90 generate
    x0 : virage90_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, xwrite, xwrite,
                   rclk, raddress, vgnd, dataoutx, renable2, gnd);
  end generate;

  nex : if tech = easic90 generate
    x0 : nextreme_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, xwrite, waddress, datain);
  end generate;

  smic : if tech = smic013 generate
    x0 : smic13_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, xwrite, waddress, datain);
  end generate;

  tm65gplu : if tech = tm65gplus generate
    x0 : tm65gplus_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
                   wclk, xwrite, waddress, datain);
  end generate;

  cmos9sfx : if tech = cmos9sf generate
    x0 : cmos9sf_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
                   wclk, xwrite, waddress, datain);
  end generate;

  n2x : if tech = easic45 generate
    x0 : n2x_syncram_2p generic map (abits, dbits, sepclk, iwrfst)
      port map (rclk, renable2, raddress, dataoutx, wclk,
                xwrite, waddress, datain);
  end generate;

  rh_lib13t0 : if tech = rhlib13t generate
    x0 : rh_lib13t_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx, wclk, xwrite, waddress, datain,
                   testin(TESTIN_WIDTH-1 downto TESTIN_WIDTH-4));
  end generate;

  gf12x : if tech = gf12 generate
    x0 : gf12_syncram_2p generic map (abits, dbits)
      port map (rclk, renable2, raddress, dataoutx,
                wclk, xwrite, waddress, datain);
  end generate;

-- pragma translate_off
  noram : if has_2pram(tech) = 0 generate
    x : process
    begin
      assert false report "synram_2p: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate;
  dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
    x : process
    begin
      assert false report "syncram_2p: " & tost(2**abits) & "x" & tost(dbits) &
       " (" & tech_table(tech) & ")"
      severity note;
      wait;
    end process;
  end generate;
  generic_check : process
  begin
    assert sepclk = 0 or wrfst = 0
      report "syncram_2p: Write-first not supported for RAM with separate clocks"
      severity failure;
    wait;
  end process;
  chk : if GRLIB_CONFIG_ARRAY(grlib_syncram_selftest_enable) /= 0 generate
    chkblk: block
      signal refdo,pwdata: std_logic_vector(dbits-1 downto 0);
      signal pren,bpen: std_ulogic;
      signal praddr,pwaddr: std_logic_vector(abits-1 downto 0);
    begin
      refram : generic_syncram_2p generic map (abits, dbits, 1)
        port map (rclk, wclk, raddress, waddress, datain, write, refdo);
      p: process(rclk)
      begin
        if rising_edge(rclk) then
          assert pren/='1' or (bpen='0' and refdo=dataoutxx) or
            (bpen='1' and pwdata=dataoutxx) or is_x(refdo) or is_x(praddr)
            report "Read mismatch addr=" & tost(praddr) & " impl=" & tost(dataoutxx) & " ref=" & tost(refdo)
            severity error;
          pren <= renable;
          praddr <= raddress;
          pwdata <= datain;
          if wrfst/=0 and renable='1' and write='1' and raddress=waddress then
            bpen <= '1';
          else
            bpen <= '0';
          end if;
        end if;
      end process;
    end block;
  end generate;
-- pragma translate_on

end;

