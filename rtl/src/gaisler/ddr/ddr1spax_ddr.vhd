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
-- Entity:      ddr1spax_ddr
-- File:        ddr1spax_ddr.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Merged 16/32/64-bit DDR/mobile-DDR backend
--              Based on ddrsp*a and ddr2spax_ddr
--------------------------------------------------------------------------------

-- Added features from the original ddrspa:
-- * Separated AHB,DDR parts of controller like for DDR2SPA
-- * 64/32/16 bit interfaces in the same entity
-- * Checkbit support for use with ft_ddr2spax_ahb front-end.
-- * Extended timing fields plus tRAS setting to meet DDR400 timing.
-- * Configurable burst length
-- * Support for PHY:s with read data valid signaling and extra latency
-- Incompatibility/differences to the original ddrspa:
-- * The mobile DDR had an undocumented feature that tRFC was extended with 8
--   cycles if the TRP bit was set. This is replaced by the extended
--   timing fields.
-- * ddrsp16a used a separate read-clock supplied only from the Spartan PHY.
-- * Reads/writes are made as multiple length-2 burst commands.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdlib.all;
use work.amba.all;
use work.devices.all;
use work.ddrpkg.all;
use work.ddrintpkg.all;

entity ddr1spax_ddr is
   generic (
      ddrbits    : integer := 32;
      burstlen   : integer := 8;
      MHz        : integer := 100;
      col        : integer := 9;
      Mbyte      : integer := 8;
      pwron      : integer := 0;
      oepol      : integer := 0;
      mobile     : integer := 0;
      confapi    : integer := 0;
      conf0      : integer := 0;
      conf1      : integer := 0;
      nosync     : integer := 0;
      ddr_syncrst: integer range 0 to 1 := 0;
      chkbits    : integer := 0;
      hasdqvalid : integer := 0;
      readdly    : integer := 0;
      regoutput  : integer := 1;
      ddr400     : integer := 1;
      rstdel     : integer := 200;
      phyptctrl  : integer := 0;
      scantest   : integer := 0
   );
   port (
      ddr_rst  : in  std_ulogic;
      clk_ddr  : in  std_ulogic;
      request  : in  ddr_request_type;
      start_tog: in  std_logic;
      response : out ddr_response_type;
      sdi      : in  ddrctrl_in_type;
      sdo      : out ddrctrl_out_type;
      wbraddr  : out std_logic_vector(log2((16*burstlen)/ddrbits) downto 0);
      wbrdata  : in  std_logic_vector(2*(ddrbits+chkbits)-1 downto 0);
      rbwaddr  : out std_logic_vector(log2((16*burstlen)/ddrbits)-1 downto 0);
      rbwdata  : out std_logic_vector(2*(ddrbits+chkbits)-1 downto 0);
      rbwrite  : out std_logic;
      reqsel   : in std_ulogic;
      frequest : in  ddr_request_type;
      response2: out ddr_response_type;
      testen   : in std_ulogic;
      testrst  : in std_ulogic;
      testoen  : in std_ulogic
   );  
end ddr1spax_ddr;

architecture rtl of ddr1spax_ddr is
  
  constant l2blen: integer := log2(burstlen)+log2(32);
  constant l2ddrw: integer := log2(ddrbits*2);
  constant l2ddr_burstlen: integer := l2blen-l2ddrw;
  
  -- constant oepols: std_logic := tosl(oepol);

  -- Write buffer dimensions
  -- Write buffer is addressable down to 32-bit level on write (AHB) side.
  constant wbuf_rabits: integer := 1+l2blen-l2ddrw; -- log2((burstlen*32)/(2*ddrbits));
  constant wbuf_rdbits: integer := 2*ddrbits;
  -- Read buffer dimensions
  constant rbuf_wabits: integer := l2blen-l2ddrw; -- log2((burstlen*32)/(2*ddrbits));
  constant rbuf_wdbits: integer := 2*(ddrbits+chkbits);
  
  type ddrstate is (dsidle,dsact1,dsact2,dsact3,dswr1,dswr2,dswr3,dswr4,dswr5,dswr6,
                    dsrd1,dsrd2,dsrd3,dsrd4,dsreg1,dsreg2,dscmd1,dscmd2,dspdown1,dspdown2,dsref1,
                    dssrr1,dssrr2);
  type ddrinitstate is (disrstdel,disidle,disrun,disfinished);

  type sdram_cfg_type is record
    command  : std_logic_vector(2 downto 0);
    csize    : std_logic_vector(1 downto 0);
    bsize    : std_logic_vector(2 downto 0);
    trcd     : std_ulogic;  -- tCD : 2/3 clock cycles
    trfc     : std_logic_vector(4 downto 0);
    trp      : std_logic_vector(1 downto 0);  -- precharge to activate: 2/3 clock cycles
    refresh  : std_logic_vector(11 downto 0);
    renable  : std_ulogic;
    dllrst   : std_ulogic;
    refon    : std_ulogic;
    cke      : std_ulogic;
    pasr     : std_logic_vector(5 downto 0); -- pasr(2:0) (pasr(5:3) used to detect update)
    tcsr     : std_logic_vector(3 downto 0); -- tcrs(1:0) (tcrs(3:2) used to detect update)
    ds       : std_logic_vector(5 downto 0); -- ds(1:0) (ds(3:2) used to detect update)
    pmode    : std_logic_vector(2 downto 0); -- Power-Saving mode
    mobileen : std_logic; -- Mobile SD support, Mobile SD enabled
    txsr     : std_logic_vector(5 downto 0); -- Exit Self Refresh timing
    txp      : std_logic_vector(1 downto 0); -- Exit Power-Down timing
    tcke     : std_logic; -- Clock enable timing
    cl       : std_logic; -- CAS latency 2/3 (0/1)
    conf     : std_logic_vector(63 downto 0); -- PHY control
    tras     : std_logic_vector(1 downto 0); -- tRAS minimum (6-9 cycles)
    twr      : std_logic; -- tWR write recovery, 2/3 cycles
  end record;
  
  type ddr_reg_type is record
    s             : ddrstate;
    initstate     : ddrinitstate;
    cfg           : sdram_cfg_type;
    resp,resp2    : ddr_response_type;
    req1,req2     : ddr_request_type;
    start1,start2 : std_logic;
    start3        : std_logic;
    ramaddr       : std_logic_vector(rbuf_wabits-1 downto 0);
    readpipe      : std_logic_vector(4+readdly downto 0);
    initpos       : std_logic_vector(2 downto 0);
    cmdctr        : std_logic_vector(7 downto 0);
    readdone      : std_logic;
    refctr        : std_logic_vector(17 downto 0);
    refpend       : std_logic;
    idlectr       : std_logic_vector(3 downto 0);
    pdowns        : std_logic_vector(1 downto 0);
    sdo_casn      : std_logic;
    sdo_rasn      : std_logic;
    sdo_wen       : std_logic;
    sdo_csn       : std_logic_vector(1 downto 0);
    sdo_ba        : std_logic_vector(1 downto 0);
    sdo_address   : std_logic_vector(14 downto 0);
    sdo_data      : std_logic_vector(2*ddrbits-1 downto 0);
    sdo_dqm       : std_logic_vector(ddrbits/4-1 downto 0);
    sdo_cb        : std_logic_vector(2*chkbits downto 0);
    sdo_ck        : std_logic_vector(2 downto 0);
    sdo_bdrive    : std_logic;
    sdo_qdrive    : std_logic;
  end record;

  signal dr,ndr: ddr_reg_type;

  constant onev: std_logic_vector(15 downto 0) := x"FFFF";
  constant zerov: std_logic_vector(15 downto 0) := x"0000";

  signal arst : std_ulogic;
begin
  
  arst <= testrst when (scantest/=0 and ddr_syncrst=0) and testen='1' else ddr_rst;
  
  ddrcomb: process(ddr_rst,sdi,request,frequest,start_tog,dr,wbrdata,testen,testoen,reqsel)

    variable dv: ddr_reg_type;
    variable o: ddrctrl_out_type;
    variable rbw: std_logic;
    variable rbwd: std_logic_vector(2*(ddrbits+chkbits)-1 downto 0);
    
    variable vstart, vstartd, vdone, incdone: std_logic;
    variable vrctr: std_logic_vector(3 downto 0);
    variable vreq,vreqf: ddr_request_type;
    variable regsd1   : std_logic_vector(31 downto 0);
    variable regsd2   : std_logic_vector(31 downto 0);
    variable regsd3   : std_logic_vector(31 downto 0);
    variable lastreadcmd: std_logic;
    variable lastwrite : std_logic;
    variable vmaskfirst, vmasklast: std_logic_vector(ddrbits/4-1 downto 0);
    variable ea: std_logic_vector(3 downto 2);
    variable inc_sdoaddr, inc_ramaddr: std_logic;
    variable datavalid: std_logic;
    variable vcsf: std_logic_vector(1 downto 0);
    variable vrowf: std_logic_vector(14 downto 0);
    variable vbankf: std_logic_vector(1 downto 0);
    variable vcol,vcoladdr: std_logic_vector(14 downto 1);
    variable seqin,seqout: std_logic_vector(3 downto 0);
    variable regrdata: std_logic_vector(2*ddrbits-1 downto 0);
    variable regad: std_logic_vector(2 downto 0);
    variable wrdreg1,wrdreg2,wrdreg3: std_logic_vector(31 downto 0);
    variable reqselv: std_logic_vector(3 downto 0);
  begin
    ---------------------------------------------------------------------------
    -- Init vars
    ---------------------------------------------------------------------------
    dv := dr;
    o := ddrctrl_out_none;
    o.bdrive := '1'; o.qdrive := '1';
    vdone := dr.resp.done_tog or dr.resp2.done_tog;
    vrctr := dr.resp.rctr_gray or dr.resp2.rctr_gray;
    
    incdone := '0';
    lastreadcmd := '0';
    lastwrite := '0';
    reqselv := reqsel & reqsel & reqsel & reqsel;
    
    -- Config registers    
    regsd1 := (others => '0');
    regsd1(31 downto 15) := dr.cfg.refon & dr.cfg.trp(0) & dr.cfg.trfc(2 downto 0) &
                            dr.cfg.trcd & dr.cfg.bsize & dr.cfg.csize & dr.cfg.command &
                            dr.cfg.dllrst & dr.cfg.renable & dr.cfg.cke; 
    regsd1(11 downto 0) := dr.cfg.refresh;
    regsd2 := (others => '0');
    regsd2(8 downto 0) := conv_std_logic_vector(MHz, 9);
    regsd2(14 downto 12) := conv_std_logic_vector(log2(ddrbits/8),3);
    if mobile/=0 then regsd2(15):='1'; end if;-- Mobile DDR support
    regsd2(19 downto 16) := conv_std_logic_vector(confapi, 4);
    regsd3 := (others => '0');
    regsd3(31) := dr.cfg.mobileen; -- Mobile DDR enable
    regsd3(30) := dr.cfg.cl;
    regsd3(24 downto 19) := dr.cfg.tcke & dr.cfg.txsr(3 downto 0) & dr.cfg.txp(0);
    regsd3(18 downto 16) := dr.cfg.pmode;
    regsd3( 7 downto  0) := dr.cfg.ds(2 downto 0) & dr.cfg.tcsr(1 downto 0) 
                            & dr.cfg.pasr(2 downto 0);
    -- Extended timing fields for DDR400
    if ddr400 /= 0 then
      regsd2(20) := '1';   -- Ext. fields available
      regsd3(29 downto 28) := dr.cfg.tras;
      regsd3(27 downto 26) := dr.cfg.txsr(5 downto 4);
      regsd3(25) := dr.cfg.txp(1);
      regsd3(11) := dr.cfg.twr;
      regsd3(10) := dr.cfg.trp(1);
      regsd3(9 downto 8) := dr.cfg.trfc(4 downto 3);
    end if;
    
    -- Data path
    rbw := '0';
    rbwd := (others => '0');
    rbwd(ddrbits-1 downto 0) := sdi.data(ddrbits-1 downto 0);
    rbwd(2*ddrbits+chkbits-1 downto ddrbits+chkbits) :=
      sdi.data(2*ddrbits-1 downto ddrbits);
    if chkbits > 0 then
      rbwd(ddrbits+chkbits-1 downto ddrbits) := sdi.cb(chkbits-1 downto 0);
      rbwd(2*(ddrbits+chkbits)-1 downto 2*ddrbits+chkbits) :=
        sdi.cb(2*chkbits-1 downto chkbits);
    end if;
    dv.sdo_data(ddrbits-1 downto 0) := wbrdata(ddrbits-1 downto 0);
    dv.sdo_data(2*ddrbits-1 downto ddrbits) :=
      wbrdata(2*ddrbits+chkbits-1 downto ddrbits+chkbits);
    dv.sdo_cb(chkbits) := '0'; -- dummy bit just to ensure length>0
    if chkbits > 0 then
      dv.sdo_cb(chkbits-1 downto 0) := wbrdata(ddrbits+chkbits-1 downto ddrbits);
      dv.sdo_cb(2*chkbits-1 downto chkbits) :=
        wbrdata(2*(ddrbits+chkbits)-1 downto 2*ddrbits+chkbits);
    end if;
    
    ---------------------------------------------------------------------------
    -- Request handling logic
    ---------------------------------------------------------------------------

    -- Sync request inputs
    dv.req1 := request;
    dv.req2 := dr.req1;
    dv.start1 := start_tog;
    dv.start2 := dr.start1;
    dv.start3 := dr.start2;
    vstart := dr.start2;
    vstartd := dr.start3;
    vreq := dr.req2;
    vreqf := dr.req1;
    if nosync/=0 then
      vstart:=start_tog;
      vstartd:=start_tog;
      vreq:=request;
      vreqf:=request;
    end if;
    if nosync > 1 then
      vreqf := frequest;
    end if;

    -- Address muxing
    vcsf(0) := genmux(dr.cfg.bsize, vreqf.startaddr(30 downto 23));
    vcsf(1) := not vcsf(0);
    vbankf := genmux(dr.cfg.bsize, vreqf.startaddr(29 downto 22)) &
              genmux(dr.cfg.bsize, vreqf.startaddr(28 downto 21));
    case dr.cfg.csize is
      when "00"   => vrowf := vreqf.startaddr(19+l2ddrw downto 5+l2ddrw);
      when "01"   => vrowf := vreqf.startaddr(20+l2ddrw downto 6+l2ddrw);
      when "10"   => vrowf := vreqf.startaddr(21+l2ddrw downto 7+l2ddrw);
      when others => vrowf := vreqf.startaddr(22+l2ddrw downto 8+l2ddrw);
    end case;
    vcol := vreq.startaddr(l2ddrw+10 downto l2ddrw-3);
    -- vcoladdr==vcol when dr.ramaddr==lsb of vcol
    vcoladdr := vcol(14 downto rbuf_wabits+1) & dr.ramaddr;  
    
    -- Generate data mask
    -- Mask for 32-bit and larger bursts and single access
    vmaskfirst := (others => '0');
    vmasklast := (others => '0');
    ea := vreq.endaddr(3 downto 2);
    if vreq.hsize(1 downto 0)="11" then ea(2):='1'; end if;
    if vreq.hsize(2)='1' then ea(3 downto 2):="11"; end if;
    case ddrbits is
      when 64 =>
        -- 64-bit DDR width
        case vreq.startaddr(3 downto 2) is
          when "11"   => vmaskfirst := "1111111111110000";
          when "10"   => vmaskfirst := "1111111100000000";
          when "01"   => vmaskfirst := "1111000000000000";
          when others => vmaskfirst := "0000000000000000";
        end case;
        case ea(3 downto 2) is
          when "11"   => vmasklast := "0000000000000000";
          when "10"   => vmasklast := "0000000000001111";
          when "01"   => vmasklast := "0000000011111111";
          when others => vmasklast := "0000111111111111";
        end case;
        if vreq.hsize(2 downto 1)="00" then 
          if vreq.startaddr(1)='1' then
            vmaskfirst := vmaskfirst or "1100110011001100";
          else
            vmaskfirst := vmaskfirst or "0011001100110011";
          end if;
        end if;
        if vreq.hsize="000" then
          if vreq.startaddr(0)='1' then
            vmaskfirst := vmaskfirst or "1010101010101010";
          else
            vmaskfirst := vmaskfirst or "0101010101010101";
          end if;
        end if;
      when 32 =>
        -- 32-bit DDR width
        case vreq.startaddr(2) is
          when '1'    => vmaskfirst := "11110000";
          when others => vmaskfirst := "00000000";
        end case;
        case ea(2) is
          when '1'    => vmasklast := "00000000";
          when others => vmasklast := "00001111";
        end case;
        if vreq.hsize(2 downto 1)="00" then 
          if vreq.startaddr(1)='1' then
            vmaskfirst := vmaskfirst or "11001100";
          else
            vmaskfirst := vmaskfirst or "00110011";
          end if;          
        end if;
        if vreq.hsize="000" then
          if vreq.startaddr(0)='1' then
            vmaskfirst := vmaskfirst or "10101010";
          else
            vmaskfirst := vmaskfirst or "01010101";
          end if;
        end if;
        
      when others =>
        -- 16-bit DDR width
        if vreq.hsize(2 downto 1)="00" then 
          if vreq.startaddr(1)='1' then
            vmaskfirst := vmaskfirst or "1100";
          else
            vmaskfirst := vmaskfirst or "0011";
          end if;          
        end if;
        if vreq.hsize="000" then
          if vreq.startaddr(0)='1' then
            vmaskfirst := vmaskfirst or "1010";
          else
            vmaskfirst := vmaskfirst or "0101";
          end if;
        end if;
    end case;

    -- Register read/write data muxing
    regrdata := (others => '0');    
    case ddrbits is
      when 64 =>
        regad := vreq.startaddr(4 downto 2);
        regrdata := regsd1 & regsd2 & regsd3 & x"00000000";
        if confapi /= 0 and regad(2)='1' then
          regrdata(95 downto 32) := dr.cfg.conf(31 downto 0) & dr.cfg.conf(63 downto 32);
        end if;          
        wrdreg1 := wbrdata(128+chkbits-1 downto 96+chkbits);
        wrdreg2 := wbrdata(96+chkbits-1 downto 64+chkbits);
        wrdreg3 := wbrdata(63 downto 32);
      when 32 =>
        regad := dr.ramaddr(1 downto 0) & vreq.startaddr(2);        
        if regad(1)='0' then
          regrdata := regsd1 & regsd2;
          if confapi /= 0 and regad(2)='1' then
            regrdata := regsd1 & dr.cfg.conf(31 downto 0);
          end if;
        else
          regrdata := regsd3 & regsd2;
          if confapi /= 0 and regad(2)='1' then
            regrdata := dr.cfg.conf(63 downto 0);
          end if;
        end if;        
        wrdreg1 := wbrdata(64+chkbits-1 downto 32+chkbits);
        wrdreg2 := wbrdata(31 downto 0);
        wrdreg3 := wbrdata(64+chkbits-1 downto 32+chkbits);
      when others =>
        regad := dr.ramaddr(2 downto 0);
        case regad is
          when "000"|"100" => regrdata := regsd1;
          when "001" => regrdata := regsd2;
          when "010" => regrdata := regsd3;
          when "101" =>
            if confapi /= 0 then
              regrdata := dr.cfg.conf(31 downto 0);
            else
              regrdata := regsd2;
            end if;
          when "110" =>
            if confapi /= 0 then
              regrdata := dr.cfg.conf(63 downto 32);
            else
              regrdata := regsd3;
            end if;
          when others => regrdata := regsd3;
        end case;
        wrdreg1 := wbrdata(31+chkbits downto 16+chkbits) & wbrdata(15 downto 0);
        wrdreg2 := wbrdata(31+chkbits downto 16+chkbits) & wbrdata(15 downto 0);
        wrdreg3 := wbrdata(31+chkbits downto 16+chkbits) & wbrdata(15 downto 0);        
    end case;
           
    ---------------------------------------------------------------------------
    -- Main DDR-SDRAM access FSM
    ---------------------------------------------------------------------------

    dv.sdo_ck := "111";
    dv.sdo_rasn := '1';
    dv.sdo_casn := '1';
    dv.sdo_wen := '1';
    dv.sdo_dqm := (others => '1');
    dv.sdo_bdrive := '1';
    dv.sdo_qdrive := '1';
    
    inc_sdoaddr := '0';
    inc_ramaddr := '0';

    dv.readpipe := dr.readpipe(3+readdly downto 0) & '0';

    datavalid := '0';
    if hasdqvalid/=0 then
      datavalid := sdi.datavalid;
      if dr.s/=dsrd1 and dr.s/=dsrd2 and dr.s/=dsrd3 and dr.s/=dsrd4 and dr.s/=dssrr2 then
        datavalid := '0';
      end if;
    end if;
    if hasdqvalid=0 then
      if dr.cfg.cl='0' then
        datavalid := dr.readpipe(3+readdly);
      else
        datavalid := dr.readpipe(4+readdly);
      end if;
    end if;

    if datavalid='1' and dr.s/=dsidle then
      inc_ramaddr := '1';
      rbw := '1';
      vrctr(l2ddr_burstlen-1 downto 0) :=
        nextgray(vrctr(l2ddr_burstlen-1 downto 0));
      if dr.ramaddr=onev(dr.ramaddr'length-1 downto 0) then
        dv.readdone := '1';
        incdone:='1';
        vrctr := "0000";
      end if;
    end if;

    if dr.sdo_address((l2blen-l2ddrw) downto 1)=onev((l2blen-l2ddrw) downto 1) then
      lastreadcmd := '1';
    end if;

    if dr.ramaddr=vreq.endaddr((l2blen-3)-1 downto (l2ddrw-3)) then      
      lastwrite := '1';
    end if;

    -- Update EMR when ds, tcsr or pasr change
    if dr.cfg.command="000" and
      ( dr.cfg.ds(2 downto 0) /= dr.cfg.ds(5 downto 3) or
        dr.cfg.tcsr(1 downto 0) /= dr.cfg.tcsr(3 downto 2) or
        dr.cfg.pasr(2 downto 0) /= dr.cfg.pasr(5 downto 3) ) then
      dv.cfg.command := "111";
    end if;

    -- Auto-refresh counter
    dv.refctr := std_logic_vector(unsigned(dr.refctr)+1);
    if (dr.refctr(11 downto 0)=dr.cfg.refresh and dr.cfg.refon='1') then
      dv.refpend := '1';
      dv.refctr := (others => '0');
    end if;
    if dr.initstate/=disrstdel and (dr.cfg.refon='0' or dr.cfg.pmode(1)='1') then
      dv.refpend := '0';
      dv.refctr := (others => '0');
    end if;

    dv.idlectr := "0000";
    dv.pdowns(0) := '0';
    
    if not (dr.cmdctr=(dr.cmdctr'range => '0')) and dr.pdowns(0)='0' then
      dv.cmdctr := std_logic_vector(unsigned(dr.cmdctr)-1);
    end if;
    
    case dr.s is
      when dsidle =>
        vrctr := "0000";
        dv.sdo_ck := "111";
        if dr.cfg.pmode /= "000" then
          dv.idlectr := std_logic_vector(unsigned(dr.idlectr)+1);
        end if;
        dv.sdo_csn := "11";
        if dr.refpend='1' then
          dv.sdo_csn := "00";
          dv.sdo_rasn := '0';
          dv.sdo_casn := '0';
          dv.s := dsref1;
          dv.refpend := '0';
        elsif vstart /= vdone and dr.cfg.renable='0' then
          -- Transfer
          dv.sdo_csn := vcsf;
          dv.sdo_address := vrowf;
          dv.sdo_ba := vbankf;
          dv.sdo_rasn := '0' or vreqf.hio;
          dv.s := dsact1;
        elsif dr.cfg.command /= "000" then
          dv.s := dscmd1;
        elsif dr.idlectr="1111" then
          dv.s := dspdown1;
        end if;

      when dsact1 =>
        dv.ramaddr := vcol(rbuf_wabits downto 1);
        if ddr400 /= 0 then
          dv.cmdctr(2 downto 0) := "1" & dr.cfg.tras; -- t(RAS)-2t(CK) = TRAS+6-2 = TRAS+4
        else
          dv.cmdctr(2 downto 0) := "10" & dr.cfg.trcd;
        end if;
        dv.readdone := '0';
        if dr.cfg.trcd='1' then
          dv.s := dsact2;
        else
          dv.s := dsact3;
        end if;
        if vreq.hio='1' then
          dv.s := dsreg1;
        end if;

      when dsact2 =>
        dv.s := dsact3;

      when dsact3 =>
        dv.sdo_casn := '0';
        dv.sdo_wen := not vreq.hwrite;
        dv.sdo_qdrive := not vreq.hwrite;
        -- dv.sdo_address := vcol(12 downto 10) & '0' & vcol(9 downto 1) & '0';
        -- Since part of column is stored in ramaddr in dsact1, use that to
        -- reduce fanout on vreq.startaddr
        dv.sdo_address := vcoladdr(13 downto 10) & '0' & vcoladdr(9 downto 1) & '0';
        if vreq.hwrite='1' then
          dv.s := dswr1;
        else
          dv.s := dsrd1;
          dv.readpipe(0) := '1';
        end if;

      when dswr1 =>
        -- NOP,NOP,[WR]: issue either WR+D or NOP+D
        dv.sdo_bdrive := '0';
        dv.sdo_qdrive := '0';
        inc_sdoaddr := '1';
        inc_ramaddr := '1';
        if lastwrite='1' then
          dv.sdo_dqm := vmaskfirst or vmasklast;
          dv.s := dswr3;
        else
          dv.sdo_casn := '0';
          dv.sdo_wen := '0';
          dv.sdo_dqm := vmaskfirst;
          dv.s := dswr2;
        end if;

      when dswr2 =>
        dv.sdo_dqm := (others => '0');
        dv.sdo_bdrive := '0';
        dv.sdo_qdrive := '0';
        inc_sdoaddr := '1';
        inc_ramaddr := '1';
        if lastwrite='0' then
          dv.sdo_casn := '0';
          dv.sdo_wen := '0';
        else
          dv.s := dswr3;
          dv.sdo_dqm := vmasklast;
        end if;
        
      when dswr3 =>
        -- ...,WR+D,WR+D,[NOP+D]: issue NOP
        dv.sdo_qdrive := '0';
        dv.sdo_dqm := (others => '1');
        dv.s := dswr4;
        incdone := '1';
        
      when dswr4 =>
        -- Issue more NOP:s to meet tWR
        dv.idlectr := std_logic_vector(unsigned(dr.idlectr)+1);
        if dr.idlectr(0)=dr.cfg.twr then
          dv.s := dswr5;
        end if;

      when dswr5 => 
        -- Issue NOP:s until tRAS met.
        if dr.cmdctr(2 downto 0)="000" then
          dv.sdo_rasn := '0';
          dv.sdo_wen := '0';
          dv.s := dswr6;
        end if;

      when dswr6 =>
        -- PRE: issue one or two NOP:s depending on trp setting
        if dr.idlectr(1 downto 0)=dr.cfg.trp then
          dv.s := dsidle;
        else
          dv.idlectr := std_logic_vector(unsigned(dr.idlectr)+1);          
        end if;

      when dsrd1 =>
        inc_sdoaddr := '1';
        if lastreadcmd='0' then
          dv.sdo_casn := '0';
          dv.readpipe(0):='1';
        elsif dr.cmdctr(2 downto 0)="000" then
          dv.sdo_rasn := '0';
          dv.sdo_wen := '0';
          dv.s := dsrd3;
        else
          dv.s := dsrd2;
        end if;

      when dsrd2 =>
        if dr.cmdctr(2 downto 0)="000" then
          dv.sdo_rasn := '0';
          dv.sdo_wen := '0';
          dv.s := dsrd3;
        end if;

      when dsrd3 =>
        if dr.idlectr(1 downto 0)=dr.cfg.trp then
          if dv.readdone='1' then
            dv.s := dsidle;
          else
            dv.s := dsrd4;
          end if;
        else
          dv.idlectr := std_logic_vector(unsigned(dr.idlectr)+1);          
        end if;

      when dsrd4 =>
        if dv.readdone='1' then
          dv.s := dsidle;
        end if;
        
      when dsreg1 =>
        rbw := '1';
        rbwd(2*ddrbits+chkbits-1 downto ddrbits+chkbits) := regrdata(2*ddrbits-1 downto ddrbits);
        rbwd(ddrbits-1 downto 0) := regrdata(ddrbits-1 downto 0);
        if vreq.hwrite='1' then
          dv.s := dsreg2;
        elsif regad="100" and dr.cfg.mobileen='1' then
          dv.sdo_address := (others => '0');
          dv.sdo_ba := "01";
          dv.sdo_csn := "10";
          dv.sdo_rasn := '0';
          dv.sdo_casn := '0';
          dv.sdo_wen := '0';
          dv.s := dssrr1;
          dv.cmdctr(0) := '1';
          null;
        else
          incdone := '1';
          dv.s := dsidle;
        end if;

      when dsreg2 =>        
        case regad is
          when "000" =>
            dv.cfg.refon   := wrdreg1(31);
            dv.cfg.trp(0)  := wrdreg1(30);
            dv.cfg.trfc(2 downto 0) := wrdreg1(29 downto 27);
            dv.cfg.trcd    := wrdreg1(26);
            dv.cfg.bsize   := wrdreg1(25 downto 23);
            dv.cfg.csize   := wrdreg1(22 downto 21);
            dv.cfg.command := wrdreg1(20 downto 18);
            dv.cfg.dllrst  := wrdreg1(17);
            dv.cfg.renable := wrdreg1(16);
            dv.cfg.cke     := wrdreg1(15);
            dv.cfg.refresh := wrdreg1(11 downto 0);
          when "010" =>
            dv.cfg.mobileen         := wrdreg3(31);
            dv.cfg.cl               := wrdreg3(30);
            dv.cfg.tcke             := wrdreg3(24);
            dv.cfg.txsr(3 downto 0) := wrdreg3(23 downto 20);
            dv.cfg.txp(0)           := wrdreg3(19);
            dv.cfg.pmode            := wrdreg3(18 downto 16);
            dv.cfg.ds  (5 downto 3) := wrdreg3(7 downto 5);
            dv.cfg.tcsr(3 downto 2) := wrdreg3(4 downto 3);
            dv.cfg.pasr(5 downto 3) := wrdreg3(2 downto 0);
            -- Extended DDR400 fields
            dv.cfg.tras             := wrdreg3(29 downto 28);
            dv.cfg.txsr(5 downto 4) := wrdreg3(27 downto 26);
            dv.cfg.txp(1)           := wrdreg3(25);
            dv.cfg.twr              := wrdreg3(11);
            dv.cfg.trp(1)           := wrdreg3(10);
            dv.cfg.trfc(4 downto 3) := wrdreg3(9 downto 8);
          when "101" =>
            if confapi /= 0 then
              dv.cfg.conf(31 downto 0) := wrdreg2;
            end if;
          when "110" =>
            if confapi /= 0 then
              dv.cfg.conf(63 downto 32) := wrdreg3;
            end if;
          when others =>
            null;
        end case;
        incdone := '1';
        dv.s := dsidle;
        
        
      when dscmd1 =>
        dv.sdo_csn := (others => '0');
        dv.sdo_address(10) := '1';
        dv.cfg.command := "000";
        dv.s := dscmd2;
        case dr.cfg.command is
          when "010" => -- PRECHARGE ALL
            dv.sdo_rasn := '0';
            dv.sdo_wen := '0';
            dv.cmdctr(1 downto 0) := "11";
          when "100" => -- AUTO-REFRESH
            dv.sdo_rasn := '0';
            dv.sdo_casn := '0';
            dv.cmdctr(4 downto 0) := dr.cfg.trfc;
          when "110" => -- MODE REGISTER
            dv.sdo_rasn := '0';
            dv.sdo_casn := '0';
            dv.sdo_wen := '0';
            dv.sdo_ba := "00";
            dv.sdo_address := "00000000" & "01" & dr.cfg.cl & "0001";
            if dr.cfg.mobileen='0' then
              dv.sdo_address(8) := dr.cfg.dllrst;
            end if;
            if dr.cfg.dllrst='1' then
              dv.cmdctr := std_logic_vector(to_unsigned(200,dr.cmdctr'length));
            end if;
          when "111" => -- EXT. MODE REGISTER
            dv.sdo_rasn := '0';
            dv.sdo_casn := '0';
            dv.sdo_wen := '0';
            if dr.cfg.mobileen='1' then
              dv.sdo_ba := "10";
              dv.sdo_address := "0000000" & dr.cfg.ds(5 downto 3) & dr.cfg.tcsr(3 downto 2) 
                                & dr.cfg.pasr(5 downto 3);
            else
              dv.sdo_ba := "01";
              dv.sdo_address := "000000000000000";  -- bit0=0 -> DLL enable
            end if;
            dv.cfg.pasr(2 downto 0) := dr.cfg.pasr(5 downto 3);
            dv.cfg.ds(2 downto 0) := dr.cfg.ds(5 downto 3);
            dv.cfg.tcsr(1 downto 0) := dr.cfg.tcsr(3 downto 2);

          when others => null;
            
        end case;

      when dscmd2 =>
        if dr.cmdctr=(dr.cmdctr'range => '0') then
          dv.s := dsidle;
        end if;

      when dspdown1 =>        
        dv.sdo_csn := "00";
        if dr.cfg.pmode(0)='1' or dr.cfg.pmode(1)='1' then
          dv.cfg.cke := '0';
        end if;
        if dr.cfg.pmode(1)='1' then
          dv.sdo_rasn := '0';
          dv.sdo_casn := '0';
        end if;
        if dr.cfg.pmode(2)='1' and dr.cfg.pmode(0)='1' then
          dv.sdo_wen := '0';
        end if;
        if dr.cfg.pmode(0)='1' then
          dv.cmdctr(1 downto 0) := dr.cfg.txp;
        end if;
        if dr.cfg.pmode(1)='1' then
          if dr.cfg.mobileen='1' then
            dv.cmdctr(5 downto 0) := dr.cfg.txsr;
          else
            dv.cmdctr(7 downto 0) := std_logic_vector(to_unsigned(200,8));
          end if;
        end if;
        dv.pdowns(1) := '0';
        dv.s := dspdown2;

      when dspdown2 =>
        dv.pdowns(0) := '1';
        if dr.pdowns(0)='0' and dr.cmdctr=(dr.cmdctr'range => '0') then
          dv.pdowns(1):='1';
        end if;
        if dr.cfg.pmode(2)='1' and dr.cfg.pmode(0)='0' then
          dv.sdo_ck := "000";
        end if;
        if dr.cfg.pmode(1)='1' then
          dv.refpend := '1';
        end if;
        if (dr.refpend='1' and dr.cfg.pmode(1)='0') or vstart /= vdone then
          if (dr.pdowns(0) or not dr.cfg.tcke)='1' then
            dv.cfg.cke := '1';
            if dr.pdowns(1)='1' then
              dv.s := dsidle;
            else
              dv.s := dscmd2;
              dv.pdowns(0) := '0';
            end if;
          end if;
        end if;

      when dsref1 =>
        dv.s := dscmd2;
        dv.cmdctr(4 downto 0) := dr.cfg.trfc;

      when dssrr1 =>
        if dr.cmdctr(0)='0' then
          dv.sdo_casn := '0';
          dv.readpipe(0):='1';
          dv.s := dssrr2;
        end if;

      when dssrr2 =>
        if datavalid='1' then
          incdone := '1';
          dv.s := dsidle;
        end if;
        
    end case;
    
    if inc_sdoaddr='1' then
      dv.sdo_address(l2blen-l2ddrw downto 1) :=
        std_logic_vector(unsigned(dr.sdo_address(l2blen-l2ddrw downto 1))+1);
    end if;
    if inc_ramaddr='1' then
      dv.ramaddr := std_logic_vector(unsigned(dr.ramaddr)+1);
    end if;

    -- Update the done flags
    dv.resp.done_tog  := (dr.resp.done_tog xor incdone) and (not reqsel);
    dv.resp.rctr_gray := vrctr and (not reqselv);
    dv.resp2.done_tog := (dr.resp2.done_tog xor incdone) and reqsel;
    dv.resp2.rctr_gray := vrctr and reqselv;
    
    ---------------------------------------------------------------------------
    -- DDR Init Sequence FSM
    ---------------------------------------------------------------------------

    -- Command sequence lookup table
    seqin := dr.cfg.mobileen & dr.initpos;
    case seqin is
      -- Mobile DDR
      when "1100" => seqout := "0010";   -- PRECHARGE ALL
      when "1011" => seqout := "0100";   -- AUTO REFRESH #1
      when "1010" => seqout := "0100";   -- AUTO REFRESH #2
      when "1001" => seqout := "0110";   -- MODE REG
      when "1000" => seqout := "0111";   -- EXT MODE REG
      -- Normal DDR
      when "0110" => seqout := "0010";   -- PRECHARGE ALL
      when "0101" => seqout := "0111";   -- EXT MODE REG En DLL
      when "0100" => seqout := "1110";   -- MODE REG Rst DLL
      when "0011" => seqout := "0010";   -- PRECHARGE ALL
      when "0010" => seqout := "0100";   -- AUTO REFRESH #1
      when "0001" => seqout := "0100";   -- AUTO REFRESH #2
      when "0000" => seqout := "0110";   -- MODE REG NoRst DLL
      when others => seqout := "0000";
    end case;
    
    case dr.initstate is

      when disrstdel =>
        if dr.refctr=std_logic_vector(to_unsigned(MHz*rstdel,dr.refctr'length)) then
          dv.initstate := disidle;
          if pwron=0 then dv.cfg.renable:='0'; end if;
        end if;
        -- Bypass reset delay by writing anything to regsd2        
        if vstartd='1' and (vreq.hio='1' and vreq.hwrite='1' and vreq.endaddr(4 downto 2)="001") then
          dv.initstate := disidle;
          if pwron=0 then dv.cfg.renable:='0'; end if;
        end if;
        
      when disidle =>
        if dr.cfg.renable='1' then
          dv.cfg.cke := '1';          
          if dr.cfg.cke='1' then
            dv.initpos := "111";
            dv.initstate := disrun;
          end if;
        end if;

      when disrun =>
        if dr.cfg.command="000" then          
          dv.cfg.dllrst := seqout(3);
          dv.cfg.command := seqout(2 downto 0);
          dv.initpos := std_logic_vector(unsigned(dr.initpos)-1);
          if dr.initpos="000" then
            dv.initstate := disfinished;
          end if;
        end if;        

      when disfinished =>
        if dr.cfg.command="000" then
          dv.cfg.renable := '0';
          dv.cfg.refon := '1';
          dv.initstate := disidle;
        end if;
    end case;
    
    ---------------------------------------------------------------------------
    -- Reset
    ---------------------------------------------------------------------------
    if ddr_rst='0' then
      dv.s := dsidle;
      dv.cmdctr := (others => '0');
      dv.refctr := (others => '0');
      dv.resp := ddr_response_none;
      dv.resp2 := ddr_response_none;
      dv.initstate := disrstdel;
      dv.refpend := '0';
      -- Reset cfg record
      dv.cfg.command       := "000";
      dv.cfg.csize         := conv_std_logic_vector(col-9, 2);
      dv.cfg.bsize         := conv_std_logic_vector(log2(Mbyte/8), 3);
      dv.cfg.refon         :=  '0';
      dv.cfg.refresh       := conv_std_logic_vector(7800*MHz/1000, 12);
      dv.cfg.dllrst        := '0';
      dv.cfg.pasr          := (others => '0');
      dv.cfg.tcsr          := (others => '0');
      dv.cfg.ds            := (others => '0');
      dv.cfg.pmode         := (others => '0');
      dv.cfg.txsr          := conv_std_logic_vector(120*MHz/1000, 6);
      dv.cfg.txp           := "01";
      dv.cfg.cl            := '0'; -- CL = 3/2 -- ****
      dv.cfg.tcke          := '1';
      if MHz > 100 then
           dv.cfg.trcd     := '1';
      else dv.cfg.trcd     := '0';
      end if;
      if MHz > 100 then
           dv.cfg.trp      := "01";
      else dv.cfg.trp      := "00";
      end if;
      dv.cfg.renable       := '1'; -- Updated in disrstdel state
      if mobile >= 2 then
           dv.cfg.mobileen := '1';   -- Default: Mobile DDR
      else dv.cfg.mobileen := '0';
      end if;
      if mobile >= 2 then
           dv.cfg.trfc   := conv_std_logic_vector(98*MHz/1000-2, 5);
      else dv.cfg.trfc   := conv_std_logic_vector(75*MHz/1000-2, 5);
      end if;
      if ddr_syncrst /= 0 then
        dv.sdo_ck := "000";
        if mobile >= 2 then
             dv.cfg.cke      := '1';
        else dv.cfg.cke      := '0';
        end if;
      end if;
      if confapi /= 0 then
        dv.cfg.conf(31 downto  0) := conv_std_logic_vector(conf0, 32); --x"0000A0A0";
        dv.cfg.conf(63 downto 32) := conv_std_logic_vector(conf1, 32); --x"00060606";
      else
        dv.cfg.conf := (others => '0');
      end if;
      if MHz > 175 then
        dv.cfg.tras := "10";
      elsif MHz > 150 then
        dv.cfg.tras := "01";
      else
        dv.cfg.tras := "00";
      end if;
      if MHz > 133 then
        dv.cfg.twr := '1';
      else
        dv.cfg.twr := '0';
      end if;
      
      dv.sdo_csn := "11";
      dv.sdo_dqm         := (others => '1');
      dv.sdo_wen         := '1';
      dv.sdo_rasn          := '1';
      dv.sdo_casn          := '1';

      -- Extra reset for X-sensitive techs
      dv.ramaddr := (others => '0');
    end if;

    ---------------------------------------------------------------------------
    -- Static logic/forced regs, etc
    ---------------------------------------------------------------------------
    
    -- Force mobile disable/enabled
    if mobile=0 then dv.cfg.mobileen := '0'; end if;
    if mobile=3 then dv.cfg.mobileen := '1'; end if;
    if mobile=0 then
      dv.cfg.pasr := (others => '0');
      dv.cfg.tcsr := (others => '0');
      dv.cfg.ds := (others => '0');
      dv.cfg.pmode := (others => '0');
      dv.cfg.txp := "00";
      dv.cfg.txsr := (others => '0');
      dv.cfg.tcke := '0';
    end if;

    if ddr400=0 then
      dv.cfg.tras := "00";
      dv.cfg.txsr(5 downto 4) := "00";
      dv.cfg.txp(1) := '0';
      dv.cfg.trp(1) := '0';
      dv.cfg.trfc(4 downto 3) := "00";
      dv.cfg.twr := '0';
    end if;
    
    -- Assign sdo
    o.bdrive := '1'; o.qdrive := '1';   --Temp.
    o.sdck := dr.sdo_ck;
    if ddr_syncrst/=0 and phyptctrl/=0 then
      o.sdck := o.sdck and (o.sdck'range => ddr_rst);
    end if;
    
    if regoutput /= 0 then
      o.casn    := dr.sdo_casn;
      o.rasn    := dr.sdo_rasn;
      o.sdwen   := dr.sdo_wen;
      o.sdcsn   := dr.sdo_csn;      
      o.ba      := '0' & dr.sdo_ba;
      o.address := dr.sdo_address;
      o.sdcke   := (others => dr.cfg.cke);
      if ddr_syncrst /= 0 and phyptctrl /= 0 then
        if ddr_rst='0' then
          if mobile >= 2 then o.sdcke := (others => '1');
          else                o.sdcke := (others => '0');
          end if;
        end if;
      end if;
      o.data(2*ddrbits-1 downto 0) := dr.sdo_data;
      o.dqm(ddrbits/4-1 downto 0)  := dr.sdo_dqm;
      if chkbits > 0 then
        o.cb(2*chkbits-1 downto 0)   := dr.sdo_cb(2*chkbits-1 downto 0);
      end if;
      o.bdrive := dr.sdo_bdrive;
      o.qdrive := dr.sdo_qdrive;
    else
      o.casn    := dv.sdo_casn;
      o.rasn    := dv.sdo_rasn;
      o.sdwen   := dv.sdo_wen;
      o.sdcsn   := dv.sdo_csn;
      o.ba      := '0' & dv.sdo_ba;
      o.address := dv.sdo_address;
      o.sdcke   := (others => dv.cfg.cke);
      o.data(2*ddrbits-1 downto 0) := dv.sdo_data;
      o.dqm(ddrbits/4-1 downto 0)  := dv.sdo_dqm;
      if chkbits > 0 then
        o.cb(2*chkbits-1 downto 0)   := dv.sdo_cb(2*chkbits-1 downto 0);
      end if;
      o.bdrive := dv.sdo_bdrive;
      o.qdrive := dv.sdo_qdrive;
     end if;
    for x in 7 downto 0 loop
      o.cbdqm(x) := o.dqm(2*x);
    end loop;

    -- Diag access
    if vreq.maskcb='1' then
      o.cbdqm := (others => '1');
    end if;
    if vreq.maskdata='1' then
      o.dqm := (others => '1');
    end if;

    if scantest/=0 and phyptctrl/=0 then
      if testen='1' then
        o.bdrive := testoen;
        o.qdrive := testoen;
      end if;
    end if;
    
    ---------------------------------------------------------------------------
    -- Drive outputs
    ---------------------------------------------------------------------------
    ndr <= dv;
    sdo <= o;
    response <= dr.resp;
    response2 <= dr.resp2;
    rbwrite <= rbw;
    rbwaddr <= dr.ramaddr;
    rbwdata <= rbwd;
    wbraddr <= vdone & dv.ramaddr;
  end process;

  ddrregs: process(clk_ddr,arst)
  begin
    if rising_edge(clk_ddr) then
      dr <= ndr;
    end if;
    if ddr_syncrst=0 and arst='0' then
      dr.sdo_ck <= "000";
      if mobile >= 2 then
           dr.cfg.cke      <= '1';
      else dr.cfg.cke      <= '0';
      end if;
    end if;
  end process;
  
end;

