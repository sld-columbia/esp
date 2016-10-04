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
-- Entity:      ahb2avl_async
-- File:        ahb2avl_async.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Asynchronous AHB to Avalon-MM interface based on ddr2spa
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.ddrpkg.all;
use work.ddrintpkg.all;

entity ahb2avl_async is
   generic (
      hindex     : integer := 0;
      haddr      : integer := 0;
      hmask      : integer := 16#f00#;
      burstlen   : integer := 8;
      nosync     : integer := 0;
      ahbbits    : integer := ahbdw;
      avldbits   : integer := 32;
      avlabits   : integer := 20
   );
   port (
      rst_ahb  : in  std_ulogic;
      clk_ahb  : in  std_ulogic;
      ahbsi    : in  ahb_slv_in_type;
      ahbso    : out ahb_slv_out_type;
      rst_avl  : in  std_ulogic;
      clk_avl  : in  std_ulogic;
      avlsi    : out ddravl_slv_in_type;
      avlso    : in  ddravl_slv_out_type
      );
end;

architecture struct of ahb2avl_async is

  constant l2blen: integer := log2(burstlen)+log2(32);
  constant l2ddrw: integer := log2(avldbits);
  constant l2ahbw: integer := log2(ahbbits);

  -- Write buffer dimensions
  constant wbuf_rabits_s: integer := 1+l2blen-l2ddrw;
  constant wbuf_rabits_r: integer := wbuf_rabits_s;
  constant wbuf_rdbits: integer := avldbits;
  constant wbuf_wabits: integer := 1+l2blen-5;
  constant wbuf_wdbits: integer := ahbbits;
  -- Read buffer dimensions
  constant rbuf_rabits: integer := l2blen-l2ahbw;
  constant rbuf_rdbits: integer := wbuf_wdbits;
  constant rbuf_wabits: integer := l2blen-l2ddrw; -- log2((burstlen*32)/(2*ddrbits));
  constant rbuf_wdbits: integer := avldbits;

  signal request   : ddr_request_type;
  signal start_tog : std_ulogic;
  signal response  : ddr_response_type;

  signal wbwaddr: std_logic_vector(wbuf_wabits-1 downto 0);
  signal wbwdata: std_logic_vector(wbuf_wdbits-1 downto 0);
  signal wbraddr: std_logic_vector(wbuf_rabits_s-1 downto 0);
  signal wbrdata: std_logic_vector(wbuf_rdbits-1 downto 0);
  signal rbwaddr: std_logic_vector(rbuf_wabits-1 downto 0);
  signal rbwdata: std_logic_vector(rbuf_wdbits-1 downto 0);
  signal rbraddr: std_logic_vector(rbuf_rabits-1 downto 0);
  signal rbrdata: std_logic_vector(rbuf_rdbits-1 downto 0);
  signal wbwrite,wbwritebig,rbwrite: std_ulogic;

  signal gnd: std_logic_vector(3 downto 0);
  signal vcc: std_ulogic;

begin

  gnd <= (others => '0');
  vcc <= '1';

  fe0: ddr2spax_ahb
    generic map (
      hindex => hindex,
      haddr => haddr,
      hmask => hmask,
      ioaddr => 0,
      iomask => 0,
      burstlen => burstlen,
      nosync => nosync,
      ahbbits => ahbbits,
      devid => GAISLER_AHB2AVLA,
      ddrbits => avldbits/2
      )
    port map (
      rst => rst_ahb,
      clk_ahb => clk_ahb,
      ahbsi => ahbsi,
      ahbso => ahbso,
      request => request,
      start_tog => start_tog,
      response => response,
      wbwaddr => wbwaddr,
      wbwdata => wbwdata,
      wbwrite => wbwrite,
      wbwritebig => wbwritebig,
      rbraddr => rbraddr,
      rbrdata => rbrdata,
      hwidth => gnd(0),
      beid => gnd(3 downto 0)
      );

  be0: ahb2avl_async_be
    generic map (
      avldbits => avldbits,
      avlabits => avlabits,
      ahbbits => ahbbits,
      burstlen => burstlen,
      nosync => nosync
      )
    port map (
      rst => rst_avl,
      clk => clk_avl,
      avlsi => avlsi,
      avlso => avlso,
      request => request,
      start_tog => start_tog,
      response => response,
      wbraddr => wbraddr,
      wbrdata => wbrdata,
      rbwaddr => rbwaddr,
      rbwdata => rbwdata,
      rbwrite => rbwrite
      );

  wbuf: ddr2buf
    generic map (tech => 0, wabits => wbuf_wabits, wdbits => wbuf_wdbits,
                 rabits => wbuf_rabits_r, rdbits => wbuf_rdbits,
                 sepclk => 1, wrfst => 0, testen => 0)
    port map ( rclk => clk_avl, renable => vcc, raddress => wbraddr(wbuf_rabits_r-1 downto 0),
               dataout => wbrdata, wclk => clk_ahb, write => wbwrite,
               writebig => wbwritebig, waddress => wbwaddr, datain => wbwdata,
               testin => ahbsi.testin);

  rbuf: ddr2buf
    generic map (tech => 0, wabits => rbuf_wabits, wdbits => rbuf_wdbits,
                 rabits => rbuf_rabits, rdbits => rbuf_rdbits,
                 sepclk => 1, wrfst => 0, testen => 0)
    port map ( rclk => clk_ahb, renable => vcc, raddress => rbraddr,
               dataout => rbrdata,
               wclk => clk_avl, write => rbwrite,
               writebig => '0', waddress => rbwaddr, datain => rbwdata,
               testin => ahbsi.testin);

end;

