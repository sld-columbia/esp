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
-- Entity:      jtagcom
-- File:        jtagcom.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: JTAG Debug Interface with AHB master interface
--              Redesigned to work for TCK both slower and faster than AHB
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.libjtagcom.all;
use work.misc.all;

entity jtagcom2 is
  generic (
    gatetech: integer := 0;
    isel   : integer range 0 to 1 := 0;
    ainst  : integer range 0 to 255 := 2;
    dinst  : integer range 0 to 255 := 3);
  port (
    rst  : in std_ulogic;
    clk  : in std_ulogic;
    tapo : in tap_out_type;
    tapi : out tap_in_type;
    dmao : in  ahb_dma_out_type;
    dmai : out ahb_dma_in_type;
    tckp : in std_ulogic;
    tckn : in std_ulogic;
    trst : in std_ulogic
    );
  attribute sync_set_reset of rst : signal is "true";
end;


architecture rtl of jtagcom2 is

  constant ADDBITS : integer := 10;
  constant NOCMP : boolean := (isel /= 0);

  type tckpreg_type is record
    addr       : std_logic_vector(34 downto 0);
    datashft   : std_logic_vector(32 downto 0);
    done_sync  : std_ulogic;
    prun       : std_ulogic;
    inshift    : std_ulogic;
    holdn      : std_ulogic;
  end record;

  type tcknreg_type is record
    run: std_ulogic;
    done_sync1: std_ulogic;
    qual_rdata: std_ulogic;
    addrlo    : std_logic_vector(ADDBITS-1 downto 2);
    data       : std_logic_vector(32 downto 0);
  end record;

  type ahbreg_type is record
    run_sync:  std_logic_vector(2 downto 0);
    qual_dreg: std_ulogic;
    qual_areg: std_ulogic;
    areg: std_logic_vector(34 downto 0);
    dreg: std_logic_vector(31 downto 0);
    done: std_ulogic;
    dmastart: std_ulogic;
    wdone: std_ulogic;
  end record;

  signal ar, arin : ahbreg_type;
  signal tpr, tprin: tckpreg_type;
  signal tnr, tnrin: tcknreg_type;

  signal qual_rdata, rdataq: std_logic_vector(31 downto 0);
  signal qual_dreg,  dregq: std_logic_vector(31 downto 0);
  signal qual_areg,  aregqin, aregq: std_logic_vector(34 downto 0);

  attribute syn_keep: boolean;
  attribute syn_keep of rdataq : signal is true;
  attribute syn_keep of dregq : signal is true;
  attribute syn_keep of aregq : signal is true;

  ----
  attribute syn_preserve: boolean;  
  attribute syn_keep of ar : signal is true;
  attribute syn_keep of tnr : signal is true;
  attribute syn_keep of tpr : signal is true;
  attribute syn_keep of arin : signal is true;
  attribute syn_keep of tnrin : signal is true;
  attribute syn_preserve of ar : signal is true;
  attribute syn_preserve of tnr : signal is true;
  attribute syn_preserve of tpr : signal is true;
  attribute syn_preserve of rdataq : signal is true;
  attribute syn_preserve of dregq : signal is true;
  attribute syn_preserve of aregq : signal is true;

  ----


begin

  rdqgen: for x in 31 downto 0 generate
    rdq: grnand2 generic map (tech => gatetech) port map (ar.dreg(x), qual_rdata(x), rdataq(x));
  end generate;
  dqgen: for x in 31 downto 0 generate
    dq: grnand2 generic map (tech => gatetech) port map (tnr.data(x), qual_dreg(x), dregq(x));
  end generate;

  aregqin <= tpr.addr(34 downto ADDBITS) &
             tnr.addrlo(ADDBITS-1 downto 2) &
             tpr.addr(1 downto 0);

  aqgen: for x in 34 downto 0 generate
    aq: grnand2 generic map (tech => gatetech) port map (aregqin(x), qual_areg(x), aregq(x));
  end generate;

  comb : process (rst, ar, tapo, dmao, tpr, tnr, aregq, dregq, rdataq)
    variable av : ahbreg_type;
    variable tpv : tckpreg_type;
    variable tnv : tcknreg_type;
    variable vdmai : ahb_dma_in_type;
    variable asel, dsel : std_ulogic;
    variable vtapi : tap_in_type;
    variable write, seq : std_ulogic;
  begin

    av := ar; tpv := tpr; tnv := tnr;

    ---------------------------------------------------------------------------
    -- TCK side logic
    ---------------------------------------------------------------------------

    if NOCMP then
      asel := tapo.asel; dsel := tapo.dsel;
    else
      if tapo.inst = conv_std_logic_vector(ainst, 8) then asel := '1'; else asel := '0'; end if;
      if tapo.inst = conv_std_logic_vector(dinst, 8) then dsel := '1'; else dsel := '0'; end if;
    end if;
    vtapi.en := asel or dsel;
    vtapi.tdo:=tpr.addr(0);
    if dsel='1' then
      vtapi.tdo:=tpr.datashft(0) and tpr.holdn;
    end if;
    write := tpr.addr(34); seq := tpr.datashft(32);

    -- Sync regs using alternating phases
    tnv.done_sync1 := ar.done;
    tpv.done_sync  := tnr.done_sync1;

    -- Data CDC
    qual_rdata <= (others => tnr.qual_rdata);
    if tnr.qual_rdata='1' then tpv.datashft(32 downto 0) := '1' & (not rdataq); end if;

    if tapo.capt='1' then tpv.addr(ADDBITS-1 downto 2) := tnr.addrlo; end if;

    -- Track whether we're in the middle of shifting
    if tapo.shift='1' then tpv.inshift:='1'; end if;
    if tapo.upd='1' then tpv.inshift:='0'; end if;

    if tapo.shift='1' then
      if asel = '1' and tpr.prun='0'  then tpv.addr(34 downto 0) := tapo.tdi & tpr.addr(34 downto 1); end if;
      if dsel = '1' and tpr.holdn='1' then tpv.datashft(32 downto 0) := tapo.tdi & tpr.datashft(32 downto 1); end if;
    end if;

    if tnr.run='0' then tpv.holdn:='1'; end if;
    tpv.prun := tnr.run;

    if tpr.prun='0' then
      tnv.qual_rdata := '0';
      if tapo.shift='0' and tapo.upd = '1' then
        if asel='1' then tnv.addrlo := tpr.addr(ADDBITS-1 downto 2); end if;
        if dsel='1' then tnv.data := tpr.datashft; end if;
        if (asel and not write) = '1' then tpv.holdn := '0'; tnv.run := '1'; end if;
        if (dsel and (write or (not write and seq))) = '1' then
          tnv.run := '1';
          if (seq and not write) = '1' then
            if tpr.inshift='1' then
              tnv.addrlo := tnr.addrlo + 1;
            end if;
            tpv.holdn := '0';
          end if;
        end if;
      end if;
    else
      if tpr.done_sync='1' and (tpv.inshift='0' or write='1') then
        tnv.run := '0';
        if write='0' then
          tnv.qual_rdata := '1';
        end if;
        if (write and tnr.data(32)) = '1' then
          tnv.addrlo := tnr.addrlo + 1;
        end if;
      end if;
    end if;

    if tapo.reset='1' then
      tpv.inshift := '0';
      tnv.run := '0';
    end if;

    ---------------------------------------------------------------------------
    -- AHB side logic
    ---------------------------------------------------------------------------

    -- Sync regs and CDC transfer
    av.run_sync := tnr.run & ar.run_sync(2) & ar.run_sync(1);

    qual_dreg <= (others => ar.qual_dreg);
    if ar.qual_dreg='1' then av.dreg:=not dregq; end if;
    qual_areg <= (others => ar.qual_areg);
    if ar.qual_areg='1' then av.areg:=not aregq; end if;

    vdmai.address := ar.areg(31 downto 0);
    vdmai.wdata := ahbdrivedata(ar.dreg(31 downto 0));
    vdmai.start := '0'; vdmai.burst := '0';
    vdmai.write := ar.areg(34);
    vdmai.busy := '0'; vdmai.irq := '0';
    vdmai.size := '0' & ar.areg(33 downto 32);

    av.qual_dreg := '0';
    av.qual_areg := '0';
    vdmai.start := '0';

    if ar.dmastart='1' then
      if dmao.active='1' then
        if dmao.ready='1' then
          av.dreg := ahbreadword(dmao.rdata);
          if ar.areg(34)='0' then
            av.done := '1';
          end if;
          av.dmastart := '0';
        end if;
      else
        vdmai.start := '1';
        if ar.areg(34)='1' and ar.wdone='0' then
          av.done := '1';
          av.wdone := '1';
        end if;
      end if;
    end if;
    if ar.qual_areg='1' then
      av.dmastart := '1';
      av.wdone := '0';
    end if;
    if ar.run_sync(0)='1' and ar.qual_areg='0' and ar.dmastart='0' and ar.done='0' then
      av.qual_dreg := '1';
      av.qual_areg := '1';
    end if;
    if ar.run_sync(0)='0' and ar.done='1' then
      av.done := '0';
    end if;


    if (rst = '0') then
      av.qual_dreg := '0';
      av.qual_areg := '0';
      av.done := '0';
      av.areg := (others => '0');
      av.dreg := (others => '0');
      av.dmastart := '0';
      av.run_sync := (others => '0');
    end if;

    tprin <= tpv; tnrin <= tnv; arin <= av; dmai <= vdmai; tapi <= vtapi;
  end process;



  ahbreg : process(clk)
  begin
    if rising_edge(clk) then ar <= arin; end if;
  end process;

  tckpreg: process(tckp,trst)
  begin
    if rising_edge(tckp) then
      tpr <= tprin;
    end if;
    if trst='0' then
      tpr.done_sync <= '0';
      tpr.prun <= '0';
      tpr.inshift <= '0';
      tpr.holdn <= '1';
      tpr.datashft(0) <= '0';
    end if;
  end process;

  tcknreg: process(tckn,trst)
  begin
    if rising_edge(tckn) then
      tnr <= tnrin;
    end if;
    if trst='0' then
      tnr.run <= '0';
      tnr.done_sync1 <= '0';
      tnr.qual_rdata <= '0';
    end if;
  end process;

end;

