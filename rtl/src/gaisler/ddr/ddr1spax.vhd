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
-- Entity:      ddr1spax
-- File:        ddr1spax.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: DDR1 memory controller with asynch AHB interface
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdlib.all;
use work.amba.all;
use work.devices.all;
use work.ddrpkg.all;
use work.ddrintpkg.all;
use work.gencomp.ddrphy_has_datavalid;
use work.gencomp.ddrphy_latency;
use work.gencomp.ddrphy_ptctrl;

entity ddr1spax is
   generic (
      memtech    : integer := 0;
      phytech    : integer := 0;
      hindex     : integer := 0;
      haddr      : integer := 0;
      hmask      : integer := 16#f00#;
      ioaddr     : integer := 16#000#;
      iomask     : integer := 16#fff#;
      ddrbits    : integer := 32;
      burstlen   : integer := 8;
      MHz        : integer := 100;
      col        : integer := 9;
      Mbyte      : integer := 8;
      pwron      : integer := 0;
      oepol      : integer := 0;
      nosync     : integer := 1;
      ddr_syncrst: integer range 0 to 1 := 0;
      ahbbits    : integer := ahbdw;
      mobile     : integer := 0;
      confapi    : integer := 0;
      conf0      : integer := 0;
      conf1      : integer := 0;
      regoutput  : integer := 0;
      ft         : integer := 0;
      ddr400     : integer := 1;
      rstdel     : integer := 200;
      scantest   : integer := 0
   );
   port (
      ddr_rst : in  std_ulogic;
      ahb_rst : in  std_ulogic;
      clk_ddr : in  std_ulogic;
      clk_ahb : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      sdi     : in  ddrctrl_in_type;
      sdo     : out ddrctrl_out_type
   );  
end ddr1spax;

architecture rtl of ddr1spax is

  constant REVISION  : integer := 0;

  constant ramwt: integer := 0;
  
  constant l2blen: integer := log2(burstlen)+log2(32);
  constant l2ddrw: integer := log2(ddrbits*2);

  function pick(choice: boolean; t,f: integer) return integer is
  begin
    if choice then return t; else return f; end if;
  end;

  constant xahbw: integer := pick(ft/=0 and ahbbits<64, 64, ahbbits);
  constant l2ahbw: integer := log2(xahbw);
  
  -- For non-FT, write buffer has room for two write bursts and is addressable
  -- down to 32-bit level on write (AHB) side.
  -- For FT, the write buffer has room for one write burst and is addressable
  -- down to 64-bit level on write side.

  -- Write buffer dimensions
  constant wbuf_rabits_s: integer := 1+l2blen-l2ddrw;
  constant wbuf_rabits_r: integer := wbuf_rabits_s-FT;
  constant wbuf_rdbits: integer := pick(ft/=0, 3*ddrbits, 2*ddrbits);
  constant wbuf_wabits: integer := pick(ft/=0, l2blen-6,          1+l2blen-5);
  constant wbuf_wdbits: integer := pick(ft/=0, xahbw+xahbw/2, xahbw);
  -- Read buffer dimensions
  constant rbuf_rabits: integer := l2blen-l2ahbw;
  constant rbuf_rdbits: integer := wbuf_wdbits;
  constant rbuf_wabits: integer := l2blen-l2ddrw; -- log2((burstlen*32)/(2*ddrbits));
  constant rbuf_wdbits: integer := pick(ft/=0, 3*ddrbits, 2*ddrbits);

  signal request   : ddr_request_type;
  signal start_tog : std_logic;
  signal response  : ddr_response_type;

  signal wbwaddr: std_logic_vector(wbuf_wabits-1 downto 0);
  signal wbwdata: std_logic_vector(wbuf_wdbits-1 downto 0);
  signal wbraddr: std_logic_vector(wbuf_rabits_s-1 downto 0);
  signal wbrdata: std_logic_vector(wbuf_rdbits-1 downto 0);
  signal rbwaddr: std_logic_vector(rbuf_wabits-1 downto 0);
  signal rbwdata: std_logic_vector(rbuf_wdbits-1 downto 0);
  signal rbraddr: std_logic_vector(rbuf_rabits-1 downto 0);
  signal rbrdata: std_logic_vector(rbuf_rdbits-1 downto 0);
  signal wbwrite,wbwritebig,rbwrite: std_logic;

  attribute keep                     : boolean;
  attribute syn_keep                 : boolean;
  attribute syn_preserve             : boolean;
  
  attribute keep of rbwdata : signal is true; 
  attribute syn_keep of rbwdata : signal is true; 
  attribute syn_preserve of rbwdata : signal is true; 
  
  signal vcc: std_ulogic;

  signal sdox: ddrctrl_out_type;
  signal ce: std_logic;

begin
  
  vcc <= '1';

  gft0: if ft=0 generate
    ahbc : ddr2spax_ahb
      generic map (hindex => hindex, haddr => haddr, hmask => hmask, ioaddr => ioaddr, iomask => iomask,
                   nosync => nosync, burstlen => burstlen, ahbbits => xahbw, revision => revision,
                   devid => GAISLER_DDRSP, regarea => 0)
      port map (ahb_rst, clk_ahb, ahbsi, ahbso, request, start_tog, response,
                wbwaddr, wbwdata, wbwrite, wbwritebig, rbraddr, rbrdata, '0', FTFE_BEID_DDR1);
    ce <= '0';
  end generate;

  gft1: if ft/=0 generate
    ftc: ft_ddr2spax_ahb
      generic map (hindex => hindex, haddr => haddr, hmask => hmask, ioaddr => ioaddr, iomask => iomask,
                   nosync => nosync, burstlen => burstlen, ahbbits => xahbw, bufbits => xahbw+xahbw/2,
                   ddrbits => ddrbits, hwidthen => 0, revision => revision, devid => GAISLER_DDRSP)
      port map (ahb_rst, clk_ahb, ahbsi, ahbso, ce, request, start_tog, response,
                wbwaddr, wbwdata, wbwrite, wbwritebig, rbraddr, rbrdata, '0', '0', open, open, FTFE_BEID_DDR1);
  end generate;
  
  ddrc : ddr1spax_ddr
    generic map (ddrbits => ddrbits,
                 pwron => pwron, MHz => MHz, col => col, Mbyte => Mbyte,
                 nosync => nosync, burstlen => burstlen,
                 chkbits => ft*ddrbits/2, oepol => oepol, mobile => mobile,
                 confapi => confapi, conf0 => conf0, conf1 => conf1,
                 hasdqvalid => ddrphy_has_datavalid(phytech),
                 ddr_syncrst => ddr_syncrst, regoutput => regoutput,
                 readdly => ddrphy_latency(phytech)+regoutput, ddr400 => ddr400,
                 rstdel => rstdel, phyptctrl => ddrphy_ptctrl(phytech), scantest => scantest)
    port map (ddr_rst, clk_ddr, request, start_tog, response, sdi, sdox,
              wbraddr, wbrdata, rbwaddr, rbwdata, rbwrite, 
              '0', ddr_request_none, open, ahbsi.testen, ahbsi.testrst, ahbsi.testoen);


  sdoproc: process(sdox,ce)
    variable o: ddrctrl_out_type;
  begin
    o := sdox;
    o.ce := ce;
    sdo <= o;
  end process;
  
  wbuf: ddr2buf
    generic map (tech => memtech, wabits => wbuf_wabits, wdbits => wbuf_wdbits,
                 rabits => wbuf_rabits_r, rdbits => wbuf_rdbits,
                 sepclk => 1, wrfst => ramwt, testen => scantest)
    port map ( rclk => clk_ddr, renable => vcc, raddress => wbraddr(wbuf_rabits_r-1 downto 0),
               dataout => wbrdata, wclk => clk_ahb, write => wbwrite,
               writebig => wbwritebig, waddress => wbwaddr, datain => wbwdata, testin => ahbsi.testin);
  
  rbuf: ddr2buf
    generic map (tech => memtech, wabits => rbuf_wabits, wdbits => rbuf_wdbits,
                 rabits => rbuf_rabits, rdbits => rbuf_rdbits,
                 sepclk => 1, wrfst => ramwt, testen => scantest)
    port map ( rclk => clk_ahb, renable => vcc, raddress => rbraddr,
               dataout => rbrdata,
               wclk => clk_ddr, write => rbwrite,
               writebig => '0', waddress => rbwaddr, datain => rbwdata, testin => ahbsi.testin);
  
-- pragma translate_off
   bootmsg : report_version
   generic map (
      msg1 => "ddrspa: DDR controller rev " &
              tost(REVISION) & ", " & tost(ddrbits) & " bit width, " & tost(Mbyte) & " Mbyte, " & tost(MHz) &
              " MHz DDR clock");
-- pragma translate_on
  
end;

