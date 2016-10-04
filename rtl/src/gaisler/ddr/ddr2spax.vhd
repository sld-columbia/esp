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
-- Entity:      ddr2spax
-- File:        ddr2spax.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: DDR2 memory controller with asynch AHB interface
--              Based on ddr2sp(16/32/64)a, generalized and expanded
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdlib.all;
use work.amba.all;
use work.devices.all;
use work.ddrpkg.all;
use work.ddrintpkg.all;
use work.gencomp.ddr2phy_has_datavalid;
use work.gencomp.ddr2phy_dis_caslat;
use work.gencomp.ddr2phy_dis_init;
use work.gencomp.ddr2phy_ptctrl;

entity ddr2spax is
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
      TRFC       : integer := 130;
      col        : integer := 9;
      Mbyte      : integer := 8;
      pwron      : integer := 0;
      oepol      : integer := 0;
      readdly    : integer := 1;
      odten      : integer := 0;
      octen      : integer := 0;
      -- dqsgating  : integer := 0;
      nosync     : integer := 0;
      dqsgating  : integer := 0;
      eightbanks : integer range 0 to 1 := 0; -- Set to 1 if 8 banks instead of 4
      dqsse      : integer range 0 to 1 := 0;  -- single ended DQS
      ddr_syncrst: integer range 0 to 1 := 0;
      ahbbits    : integer := ahbdw;
      ft         : integer range 0 to 1 := 0;
      bigmem     : integer range 0 to 1 := 0;
      raspipe    : integer range 0 to 1 := 0;
      hwidthen   : integer range 0 to 1 := 0;
      rstdel     : integer := 200;
      scantest   : integer := 0;
      cke_rst    : integer := 0;
      pipe_ctrl  : integer := 0
   );
   port (
      ddr_rst : in  std_ulogic;
      ahb_rst : in  std_ulogic;
      clk_ddr : in  std_ulogic;
      clk_ahb : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      sdi     : in  ddrctrl_in_type;
      sdo     : out ddrctrl_out_type;
      hwidth  : in  std_ulogic
   );  
end ddr2spax;

architecture rtl of ddr2spax is

  constant REVISION  : integer := 1;

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
  signal start_tog, start_tog_l, start_tog_r : std_logic;
  signal response, response_l, response_r  : ddr_response_type;

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
                   ddrbits => ddrbits, regarea => 0)
      port map (ahb_rst, clk_ahb, ahbsi, ahbso, request, start_tog, response_l,
                wbwaddr, wbwdata, wbwrite, wbwritebig, rbraddr, rbrdata, hwidth, FTFE_BEID_DDR2);
    ce <= '0';
  end generate;

  gft1: if ft/=0 generate
    ftc: ft_ddr2spax_ahb
      generic map (hindex => hindex, haddr => haddr, hmask => hmask, ioaddr => ioaddr, iomask => iomask,
                   nosync => nosync, burstlen => burstlen, ahbbits => xahbw, bufbits => xahbw+xahbw/2,
                   ddrbits => ddrbits, hwidthen => hwidthen, devid => GAISLER_DDR2SP, revision => revision)
      port map (ahb_rst, clk_ahb, ahbsi, ahbso, ce, request, start_tog, response_l,
                wbwaddr, wbwdata, wbwrite, wbwritebig, rbraddr, rbrdata, hwidth, '0', open, open, FTFE_BEID_DDR2);
  end generate;
  
  ddrc : ddr2spax_ddr
    generic map (ddrbits => ddrbits,
                 pwron => pwron, MHz => MHz, TRFC => TRFC, col => col, Mbyte => Mbyte,
                 readdly => readdly, odten => odten, octen => octen, dqsgating => dqsgating,
                 nosync => nosync, eightbanks => eightbanks, dqsse => dqsse, burstlen => burstlen,
                 chkbits => ft*ddrbits/2, bigmem => bigmem, raspipe => raspipe,
                 hwidthen => hwidthen, phytech => phytech, hasdqvalid => ddr2phy_has_datavalid(phytech),
                 rstdel => rstdel, phyptctrl => ddr2phy_ptctrl(phytech), scantest => scantest,
                 ddr_syncrst => ddr_syncrst, dis_caslat => ddr2phy_dis_caslat(phytech),
                 dis_init => ddr2phy_dis_init(phytech), cke_rst => cke_rst)
    port map (ddr_rst, clk_ddr, request, start_tog_l, response, sdi, sdox,
              wbraddr, wbrdata, rbwaddr, rbwdata, rbwrite, hwidth,
              '0', ddr_request_none, open, ahbsi.testen, ahbsi.testrst, ahbsi.testoen);


  pipeline: if pipe_ctrl/= 0 generate
    pipeline_ddr: process(ddr_rst, clk_ddr)
    begin
      if ddr_rst = '0' then
        response_r <= ddr_response_none;
      elsif rising_edge(clk_ddr) then
        response_r <= response;
      end if;
    end process;
    
    pipeline_ahb: process(ahb_rst, clk_ahb)
    begin
      if ahb_rst = '0' then
        start_tog_r <= '0';
      elsif rising_edge(clk_ahb) then
        start_tog_r <= start_tog;
      end if;
    end process;

    start_tog_l <= start_tog_r;
    response_l <= response_r;
  end generate;

  no_pipeline: if pipe_ctrl= 0 generate
    start_tog_l <= start_tog;
    response_l <= response;
  end generate;

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
      msg1 => "ddr2spa: DDR2 controller rev " &
              tost(REVISION) & ", " & tost(ddrbits) & " bit width, " & tost(Mbyte) & " Mbyte, " & tost(MHz) &
              " MHz DDR clock");
-- pragma translate_on
  
end;

