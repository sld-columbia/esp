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

entity ddr2spax_ddr is
   generic (
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
      chkbits     : integer := 0;
      bigmem     : integer range 0 to 1 := 0;
      raspipe    : integer range 0 to 1 := 0;
      hwidthen   : integer range 0 to 1 := 0;
      phytech    : integer := 0;
      hasdqvalid : integer := 0;
      rstdel     : integer := 200;
      phyptctrl  : integer := 0;
      scantest   : integer := 0;
      dis_caslat : integer := 0;
      dis_init   : integer := 0;
      cke_rst    : integer := 0
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
      hwidth   : in std_ulogic;
      reqsel   : in std_ulogic;
      frequest : in  ddr_request_type;
      response2: out ddr_response_type;
      testen   : in std_ulogic;
      testrst  : in std_ulogic;
      testoen  : in std_ulogic
   );  
end ddr2spax_ddr;

architecture rtl of ddr2spax_ddr is

  constant CMD_PRE  : std_logic_vector(2 downto 0) := "010";
  constant CMD_REF  : std_logic_vector(2 downto 0) := "100";
  constant CMD_LMR  : std_logic_vector(2 downto 0) := "110";
  constant CMD_EMR  : std_logic_vector(2 downto 0) := "111";
  
  function tosl(x: integer) return std_logic is
  begin
    if x /= 0 then return '1'; else return '0'; end if;
  end tosl;

  function zerov(w: integer) return std_logic_vector is
    constant r: std_logic_vector(w-1 downto 0) := (others => '0');
  begin
    return r;
  end zerov;

  constant l2blen: integer := log2(burstlen)+log2(32);
  constant l2ddrw: integer := log2(ddrbits*2);
  
  constant oepols: std_logic := tosl(oepol);

  -- Write buffer dimensions
  -- Write buffer is addressable down to 32-bit level on write (AHB) side.
  constant wbuf_rabits: integer := 1+l2blen-l2ddrw; -- log2((burstlen*32)/(2*ddrbits));
  constant wbuf_rdbits: integer := 2*ddrbits;
  -- Read buffer dimensions
  constant rbuf_wabits: integer := l2blen-l2ddrw; -- log2((burstlen*32)/(2*ddrbits));
  constant rbuf_wdbits: integer := 2*(ddrbits+chkbits);
  
  -- sdram configuration register
  type sdram_cfg_type is record
    command    : std_logic_vector(2 downto 0);
    csize      : std_logic_vector(1 downto 0);
    bsize      : std_logic_vector(3 downto 0);
    trcd       : std_logic_vector(2 downto 0);  -- tRCD : 2-9 clock cycles
    trfc       : std_logic_vector(7 downto 0);
    trp        : std_logic_vector(2 downto 0);  -- precharge to activate: 2-9 clock cycles
    refresh    : std_logic_vector(11 downto 0);
    renable    : std_ulogic;
    dllrst     : std_ulogic;
    refon      : std_ulogic;
    cke        : std_ulogic;
    cal_en     : std_logic_vector(7 downto 0);
    cal_inc    : std_logic_vector(7 downto 0);
    cbcal_en   : std_logic_vector(3 downto 0);
    cbcal_inc  : std_logic_vector(3 downto 0);    
    cal_pll    : std_logic_vector(1 downto 0);  -- *** ??? pll_reconf
    cal_rst    : std_logic;
    readdly    : std_logic_vector(3 downto 0);
    twr        : std_logic_vector(4 downto 0);
    emr        : std_logic_vector(1 downto 0); -- selects EM register
    ocd        : std_ulogic; -- enable/disable ocd
    dqsctrl    : std_logic_vector(7 downto 0);
    eightbanks : std_ulogic;
    caslat     : std_logic_vector(1 downto 0);  -- CAS latency 3-6
    odten      : std_logic_vector(1 downto 0);
    tras       : std_logic_vector(4 downto 0);  -- RAS-to-Precharge minimum
    trtp       : std_ulogic;
    regmem     : std_ulogic;            -- Registered memory (1 cycle extra latency)
    strength   : std_ulogic;            -- Drive strength 1=reduced, 0=normal
  end record;

  constant ddr_burstlen: integer := (burstlen*32)/(2*ddrbits);
  constant l2ddr_burstlen: integer := l2blen-l2ddrw;
  
  type ddrstate is (dsidle,dsrascas,dscaslat,dsreaddly,dsdata,dsdone,dsagain,dsreg,dsrefresh,dspreall);
  type ddrcmdstate is (dcrstdel,dcoff,dcinit1,dcinit2,dcinit3,dcinit4,dcinit5,dcinit6,dcinit7,dcinit8,dcon);
  
  type ddr_reg_type is record
    s             : ddrstate;
    cmds          : ddrcmdstate;
    response      : ddr_response_type;
    response1     : ddr_response_type;
    response2     : ddr_response_type;
    response_prev : ddr_response_type;
    cfg           : sdram_cfg_type;
    rowsel        : std_logic_vector(2 downto 0);
    endaddr       : std_logic_vector(l2blen-4 downto 2);
    addrlo        : std_logic_vector(l2ddrw-4 downto 0);
    col           : std_logic_vector(13 downto 0);
    hwrite        : std_logic;
    hsize         : std_logic_vector(2 downto 0);
    ctr           : std_logic_vector(7 downto 0);
    casctr        : std_logic_vector(l2ddr_burstlen-1 downto 0);
    datacas       : std_logic;
    prectr        : std_logic_vector(5 downto 0);
    rastimer      : std_logic_vector(4 downto 0);
    tras_met      : std_logic;
    pchpend       : std_logic;
    refctr        : std_logic_vector(16 downto 0);
    refpend       : std_logic;
    pastlast      : std_logic;
    sdo_csn       : std_logic_vector(1 downto 0);
    sdo_wen       : std_ulogic;
    wen_prev      : std_ulogic;
    sdo_rasn      : std_ulogic;
    rasn_pre      : std_ulogic;
    sdo_casn      : std_ulogic;
    sdo_dqm       : std_logic_vector(15 downto 0);
    dqm_prev      : std_logic_vector(15 downto 0);
    twr_plus_cl   : std_logic_vector(5 downto 0);
    request_row   : std_logic_vector(14 downto 0);
    request_bank  : std_logic_vector(2 downto 0);
    request_cs    : std_logic_vector(0 downto 0);
    row           : std_logic_vector(14 downto 0);
    setrow        : std_logic;
    samerow       : std_logic;
    start_tog_prev: std_logic;
    sdo_bdrive    : std_ulogic;
    sdo_qdrive    : std_ulogic;
    sdo_nbdrive   : std_ulogic;
    sdo_address   : std_logic_vector(14 downto 0);
    sdo_address_prev: std_logic_vector(14 downto 0);
    sdo_ba        : std_logic_vector(2 downto 0);
    sdo_data      : std_logic_vector(sdo.data'length-1 downto 0);
    sdo_cb        : std_logic_vector(sdo.cb'length-1 downto 0);
    sdo_odt       : std_logic;
    sdo_oct       : std_logic;
    rbwrite       : std_logic;
    rbwdata       : std_logic_vector(rbuf_wdbits-1 downto 0);
    ramaddr       : std_logic_vector(rbuf_wabits-1 downto 0);
    ramaddr_prev  : std_logic_vector(rbuf_wabits-1 downto 0);
    mr_twr        : std_logic_vector(2 downto 0);
    mr_tcl        : std_logic_vector(2 downto 0);
    read_pend     : std_logic_vector(15 downto 0);
    req1,req2     : ddr_request_type;
    start1,start2 : std_logic;
    hwidth1       : std_logic;
    hwidth        : std_logic;    
    hwcas         : std_logic;
    hwctr         : std_logic;
  end record;

  signal dr,ndr    : ddr_reg_type;

  signal muxsel2,muxsel1,muxsel0: std_ulogic;
  signal muxin4: std_logic_vector(31 downto 0);
  signal muxout4: std_logic_vector(3 downto 0);

  signal start_tog_delta1,start_tog_delta2: std_logic;
  signal arst: std_ulogic;
  
  attribute syn_keep: boolean;
  attribute syn_keep of muxsel2:signal is true;
  attribute syn_keep of muxsel1:signal is true;
  attribute syn_keep of muxsel0:signal is true;
  
begin

  arst <= testrst when (scantest/=0 and ddr_syncrst=0) and testen='1' else ddr_rst;
  
  start_tog_delta1 <= start_tog;
  start_tog_delta2 <= start_tog_delta1;
  
  muxsel2 <= dr.rowsel(2);
  muxsel1 <= dr.rowsel(1);
  muxsel0 <= dr.rowsel(0);
  
  muxproc : process(muxin4,muxsel2,muxsel1,muxsel0)
  begin
    muxout4(3) <= genmux((muxsel2 & muxsel1 & muxsel0),muxin4(31 downto 24));
    muxout4(2) <= genmux((muxsel2 & muxsel1 & muxsel0),muxin4(23 downto 16));
    muxout4(1) <= genmux((muxsel2 & muxsel1 & muxsel0),muxin4(15 downto 8));
    muxout4(0) <= genmux((muxsel2 & muxsel1 & muxsel0),muxin4(7 downto 0));
  end process;
  
  ddrcomb : process(ddr_rst,sdi,request,frequest,start_tog_delta2,dr,wbrdata,muxout4,hwidth,reqsel,testen,testoen)
    constant plmemwrite: boolean := false;
    constant plmemread: boolean := false;
    
    variable dv: ddr_reg_type;
    variable o: ddrctrl_out_type;
    variable bdrive,qdrive: std_logic;
    variable vreq,vreqf: ddr_request_type;
    variable resp,resp2: ddr_response_type;
    variable vstart: std_logic;
    variable acsn: std_logic_vector(1 downto 0);
    variable arow: std_logic_vector(14 downto 0);
    variable acol: std_logic_vector(13 downto 0);
    variable abank: std_logic_vector(2 downto 0);
    variable aendaddr: std_logic_vector(l2blen-4 downto 2);
    variable aloa: std_logic_vector(l2ddrw-4 downto 0);
    variable rbw: std_logic;
    variable rbwd: std_logic_vector(rbuf_wdbits-1 downto 0);
    variable rbwa: std_logic_vector(rbuf_wabits-1 downto 0);
    variable wbra: std_logic_vector(wbuf_rabits-1 downto 0);
    variable regdata: std_logic_vector(31 downto 0);
    variable regsd1   : std_logic_vector(31 downto 0);   -- data from registers
    variable regsd2   : std_logic_vector(31 downto 0);   -- data from registers
    variable regsd3   : std_logic_vector(31 downto 0);   -- data from registers
    variable regsd4   : std_logic_vector(31 downto 0);   -- data from registers
    variable regsd5   : std_logic_vector(31 downto 0);   -- data from registers
    variable mr       : std_logic_vector(14 downto 0);  -- DDR2 Mode register
    variable mask: std_logic_vector(15 downto 0);
    variable hio1: std_logic;
    variable w5: std_logic;
    variable precharge_next: std_logic;
    variable precharge_notras: std_logic;
    variable goto_caslat: std_logic;
    variable block_precharge: std_logic;
    variable regt0,regt1: std_logic_vector(ddrbits-1 downto 0);
    variable addrtemp3,addrtemp2,addrtemp1,addrtemp0: std_logic_vector(7 downto 0);
    variable expcsize: std_logic_vector(2 downto 0);
    variable caslat_reg: std_logic_vector(2 downto 0);
    variable addrlo32, endaddr32: std_logic_vector(3 downto 2);
    variable endaddr43: std_logic_vector(4 downto 3);
    variable endaddr42: std_logic_vector(4 downto 2);
    variable inc_rctr: std_logic;
    
  begin
    
    
    dv := dr;
    o := ddrctrl_out_none;
    o.sdcke     := (others => dr.cfg.cke);
    o.sdcsn     := dr.sdo_csn;
    o.sdwen     := dr.wen_prev;
    o.rasn      := dr.sdo_rasn and dr.rasn_pre;
    o.casn      := dr.sdo_casn and dr.datacas;
    o.dqm       := dr.dqm_prev;
    o.bdrive    := dr.sdo_bdrive;
    o.qdrive    := dr.sdo_qdrive;
    o.nbdrive   := dr.sdo_nbdrive;
    o.address   := dr.sdo_address;
    o.data      := dr.sdo_data;
    o.ba        := dr.sdo_ba;
    o.cal_en    := dr.cfg.cal_en;
    o.cal_inc   := dr.cfg.cal_inc;
    o.cal_pll   := dr.cfg.cal_pll;
    o.cal_rst   := dr.cfg.cal_rst;
    o.odt       := (others => dr.sdo_odt);
    o.oct       := dr.sdo_oct;
    o.cb        := dr.sdo_cb;
    o.cbcal_en  := dr.cfg.cbcal_en;
    o.cbcal_inc := dr.cfg.cbcal_inc;

    resp := ddr_response_none;
    resp2 := ddr_response_none;
    
    rbw  := dr.rbwrite;
    rbwd := dr.rbwdata;
    rbwa := (others => '0');
    w5 := '0';
    wbra := dr.response.done_tog & dr.ramaddr;

    dv.ramaddr_prev := dr.ramaddr;
    dv.dqm_prev := dr.sdo_dqm;
    dv.wen_prev := dr.sdo_wen;
    dv.response_prev := dr.response;
    dv.sdo_address_prev := dr.sdo_address;
    
    dv.cfg.cal_en := (others => '0');
    dv.cfg.cal_inc := (others => '0');
    dv.cfg.cal_pll := (others => '0');
    dv.cfg.cal_rst := '0';
    dv.cfg.cbcal_en := (others => '0');
    dv.cfg.cbcal_inc := (others => '0');
    
    dv.sdo_data := (others => '0');
    dv.sdo_data(2*ddrbits-1 downto ddrbits) := wbrdata(2*ddrbits+chkbits-1 downto ddrbits+chkbits);
    dv.sdo_data(ddrbits-1 downto 0) := wbrdata(ddrbits-1 downto 0);

    dv.sdo_cb := (others => '0');
    if chkbits > 0 then
      dv.sdo_cb(2*chkbits-1 downto chkbits) := wbrdata(2*ddrbits+2*chkbits-1 downto 2*ddrbits+chkbits);
      dv.sdo_cb(chkbits-1 downto 0) := wbrdata(ddrbits+chkbits-1 downto ddrbits);
    end if;
    
    if hwidthen/=0 and dr.hwidth='1' and dr.hwctr='1' then
      dv.sdo_data(ddrbits-1 downto 0) := dr.sdo_data(2*ddrbits-1 downto ddrbits);
      if chkbits > 0 then
        dv.sdo_cb(chkbits-1 downto 0) := dr.sdo_cb(2*chkbits-1 downto chkbits);
      end if;
    end if;

    if not (hwidthen/=0 and hasdqvalid/=0 and sdi.datavalid='0') then

      dv.rbwdata(2*ddrbits+chkbits-1 downto ddrbits+chkbits) := sdi.data(2*ddrbits-1 downto ddrbits);
      dv.rbwdata(ddrbits-1 downto 0) := sdi.data(ddrbits-1 downto 0);
      if chkbits > 0 then
        dv.rbwdata(2*ddrbits+2*chkbits-1 downto 2*ddrbits+chkbits) := sdi.cb(2*chkbits-1 downto chkbits);
        dv.rbwdata(ddrbits+chkbits-1 downto ddrbits) := sdi.cb(chkbits-1 downto 0);
      end if;
      
      -- Half-width input data muxing
      if hwidthen/=0 and dr.hwidth='1' and dr.hwctr='1' then      
        dv.rbwdata(2*ddrbits+chkbits-1 downto 2*ddrbits+chkbits-ddrbits/2) :=
          dr.rbwdata(2*ddrbits+chkbits-ddrbits/2-1 downto ddrbits+chkbits);      
        dv.rbwdata(2*ddrbits+chkbits-ddrbits/2-1 downto ddrbits+chkbits) :=
          dr.rbwdata(ddrbits/2-1 downto 0);      
        dv.rbwdata(ddrbits-1 downto ddrbits/2) :=
          sdi.data(ddrbits+ddrbits/2-1 downto ddrbits);
        
        if chkbits > 0 then
          dv.rbwdata(2*ddrbits+2*chkbits-1 downto 2*ddrbits+2*chkbits-chkbits/2) :=
            dr.rbwdata(2*ddrbits+2*chkbits-chkbits/2-1 downto 2*ddrbits+chkbits);
          dv.rbwdata(2*ddrbits+2*chkbits-chkbits/2-1 downto 2*ddrbits+chkbits) :=
            dr.rbwdata(ddrbits+chkbits/2-1 downto ddrbits);
          dv.rbwdata(ddrbits+chkbits-1 downto ddrbits+chkbits/2) :=
            sdi.cb(chkbits+chkbits/2-1 downto chkbits);
        end if;
        
      end if;
      
    end if;
    
    -- hwidth input should be constant but sample it for robustness
    -- then sample in one more stage to allow replication if necessary
    dv.hwidth1 := hwidth;
    dv.hwidth := dr.hwidth1;
    if hwidthen=0 then dv.hwidth:='0'; end if;
    
    -- Synchronize 1/2 stages
    dv.req1 := request; dv.req2 := dr.req1;
    dv.start1 := start_tog_delta2; dv.start2 := dr.start1;
    vstart := dr.start2;
    vreq := dr.req2;
    vreqf := dr.req1;
    if nosync /= 0 then vstart:=start_tog_delta2; vreq:=request; vreqf:=request; end if;
    if nosync > 1 then vreqf:=frequest; end if;
    dv.start_tog_prev := vstart;

    regsd1 := (others => '0');
    regsd1(31 downto 15) := dr.cfg.refon & dr.cfg.ocd & dr.cfg.emr & dr.cfg.bsize(3) & dr.cfg.trcd(0) &
                            dr.cfg.bsize(2 downto 0) & dr.cfg.csize & dr.cfg.command &
                            dr.cfg.dllrst & dr.cfg.renable & dr.cfg.cke;
    regsd1(11 downto 0) := dr.cfg.refresh;
    regsd2 := (others => '0');
    regsd2(25 downto 18) := std_logic_vector(to_unsigned(phytech,8));
    if bigmem /= 0 then regsd2(17):='1'; end if;
    if chkbits > 0 then regsd2(16):='1'; end if;
    regsd2(15 downto 0) := "1" &
                           std_logic_vector(to_unsigned(log2(ddrbits/8),3)) &
                           std_logic_vector(to_unsigned(MHz,12));
    if dr.hwidth='1' then
      regsd2(14 downto 12) := std_logic_vector(to_unsigned(log2((ddrbits/2)/8),3));
    end if;
    regsd3 := (others => '0');    
    regsd3(17 downto 16) := dr.cfg.readdly(1 downto 0);
    regsd3(22 downto 18) := dr.cfg.trfc(4 downto 0);
    regsd3(27 downto 23) := dr.cfg.twr;
    regsd3(28) := dr.cfg.trp(0);
    regsd4 := (others => '0');
    regsd4(23 downto 22) := dr.cfg.readdly(3 downto 2);
    regsd4(21) := dr.cfg.regmem;
    regsd4(13 downto 0) := dr.cfg.trtp & "00" & dr.cfg.caslat &
                           dr.cfg.eightbanks & dr.cfg.dqsctrl;
    regsd5 := (others => '0');
    regsd5(30 downto 28) := dr.cfg.trp;
    regsd5(25 downto 18) := dr.cfg.trfc;
    regsd5(17 downto 16) := dr.cfg.odten;
    regsd5(15)           := dr.cfg.strength;
    regsd5(10 downto 8)  := dr.cfg.trcd;
    regsd5(4 downto 0)   := dr.cfg.tras;

    case ddrbits is
      when 16 => o.regwdata := dr.sdo_data(31 downto 0) & dr.sdo_data(31 downto 0);
      when 32 => o.regwdata := dr.sdo_data(31 downto 0) & dr.sdo_data(63 downto 32);
      when 64 => o.regwdata := dr.sdo_data(31 downto 0) & dr.sdo_data(63 downto 32);
      when others => o.regwdata := dr.sdo_data(2*ddrbits-7*32-1 downto 2*ddrbits-8*32) &
                                   dr.sdo_data(2*ddrbits-6*32-1 downto 2*ddrbits-7*32);
    end case;

    if dr.cfg.regmem='1' then
      caslat_reg := std_logic_vector(unsigned('0' & dr.cfg.caslat)+1);
    else
      caslat_reg := '0' & dr.cfg.caslat;
    end if;
    
    -- Mode register
    dv.mr_twr := std_logic_vector(unsigned(dr.cfg.twr(2 downto 0))-3);
    if dv.mr_twr="110" or dv.mr_twr="111" or dv.mr_twr="000" then
      dv.mr_twr := "101";
    end if;
    dv.mr_tcl := std_logic_vector(unsigned('0' & dr.cfg.caslat)+3);
    
    mr := (others => '0');
    mr(12)          := '0';             -- Power down exit time
    mr(11 downto 9) := dr.mr_twr;       -- WR-1
    mr(8)           := dr.cfg.dllrst;   -- DLL Reset
    mr(7)           := '0';             -- Test mode
    mr(6 downto 4)  := dr.mr_tcl;       -- CL
    mr(3)           := '0';             -- Burst type, 0=seq 1=interl
    mr(2 downto 0)  := "010";           -- Burst len 010=4, 011=8
    
    -- Calculate address parts from a2ds.haddr and a2ds.startword
    expcsize := dr.hwidth & dr.cfg.csize;
    case expcsize is
      when         "011"   => arow := vreqf.startaddr(l2ddrw+22 downto l2ddrw+8);
      when "111" | "010"   => arow := vreqf.startaddr(l2ddrw+21 downto l2ddrw+7);                              
      when "110" | "001"   => arow := vreqf.startaddr(l2ddrw+20 downto l2ddrw+6);
      when "101" | "000"   => arow := vreqf.startaddr(l2ddrw+19 downto l2ddrw+5);                              
      when others          => arow := vreqf.startaddr(l2ddrw+18 downto l2ddrw+4);
    end case;

    dv.rowsel := dr.cfg.bsize(2 downto 0);
    if bigmem /= 0 and dr.cfg.bsize(3 downto 1)="000" then
      dv.rowsel := "010";
    end if;
    if bigmem = 0 and dr.cfg.bsize(3)='1' then
      dv.rowsel := "111";
    end if;
    
    addrtemp3 := vreqf.startaddr(30 downto 23);  --CS
    addrtemp2 := vreqf.startaddr(29 downto 22);  --BA2/1
    addrtemp1 := vreqf.startaddr(28 downto 21);  --BA1/0
    addrtemp0 := vreqf.startaddr(27 downto 20);  --BA0/-
    if bigmem=1 then
      addrtemp3(1 downto 0) := "0" & vreqf.startaddr(31);
      addrtemp2(1 downto 0) := vreqf.startaddr(31 downto 30);
      addrtemp1(1 downto 0) := vreqf.startaddr(30 downto 29);
      addrtemp0(1 downto 0) := vreqf.startaddr(29 downto 28);
    end if;
    muxin4 <= addrtemp3 & addrtemp2 & addrtemp1 & addrtemp0;
    
    abank := muxout4(2 downto 0);
    if dr.cfg.eightbanks='0' then
      abank := '0' & abank(2) & abank(1);
    end if;

    acol := vreqf.startaddr(log2(ddrbits/8)+13 downto log2(ddrbits/8));
    if ddrbits=16 then acol(0):='0'; end if;  -- Always align to at least 32 bits

    acsn(0) := muxout4(3);
    acsn(1) := not acsn(0);

    dv.setrow := '0';
    if dr.setrow='1' then
      dv.row := dr.sdo_address_prev;
    end if;
    
    dv.samerow := '0';
    if abank=dr.sdo_ba and acsn=dr.sdo_csn and arow=dr.row then
      dv.samerow := '1';
    end if;

    dv.request_row := arow;
    dv.request_cs  := acsn(0 downto 0);
    dv.request_bank := abank;

    hio1 := vreqf.hio;
    if raspipe /= 0 then
      vstart := dr.start_tog_prev;
      arow := dr.request_row;
      acsn := (not dr.request_cs) & dr.request_cs;
      abank := dr.request_bank;
      hio1 := vreq.hio;
    end if;
    
    aendaddr := vreq.endaddr(log2(4*burstlen)-1 downto 2);
    if vreq.hsize(1 downto 0)="11" and vreq.hio='0' then
      aendaddr(2):='1';
    end if;
    if ahbdw > 64 and vreqf.hsize(2)='1' then
      aendaddr(3 downto 2) := "11";
      if ahbdw > 128 and vreqf.hsize(0)='1' then
        aendaddr(4) := '1';
      end if;
    end if;

    aloa(l2ddrw-4 downto 0) := vreq.startaddr(l2ddrw-4 downto 0);
    if ddrbits > 32 then addrlo32 := dr.addrlo(3 downto 2);
    elsif ddrbits > 16 then addrlo32 := '0' & dr.addrlo(2);
    else addrlo32 := "00";
    end if;
    endaddr32 := dr.endaddr(3 downto 2);
    endaddr43 := dr.endaddr(4 downto 3);
    endaddr42 := dr.endaddr(4 downto 2);
    
    -- Calculate data mask    
    mask := (others => dr.pastlast);
    -- Set mask bits for <word access
    if dr.hsize="000" then
      if dr.addrlo(0)='1' then
        mask := mask or "1010101010101010";
      else
        mask := mask or "0101010101010101";
      end if;
    end if;
    if dr.hsize(2 downto 1)="00" then
      if dr.addrlo(1)='1' then
        mask := mask or "1100110011001100";
      else
        mask := mask or "0011001100110011";
      end if;
    end if;
    -- First access
    -- (this could be written in generic code instead)
    if dr.ctr=zerov(dr.ctr'length) then
      case ddrbits is
        when 16 =>
          null;
        when 32 =>
          if dr.addrlo(2)='1' then
            mask(7 downto 0) := mask(7 downto 0) or x"F0";
          end if;
        when 64 =>
          case addrlo32 is
            when "00"   => null;
            when "01"   => mask := mask or x"F000";
            when "10"   => mask := mask or x"FF00";
            when others => mask := mask or x"FFF0";
          end case;
        when others => null;
      end case;      
    end if;
    -- Last access
    if dr.ramaddr = dr.endaddr(log2(4*burstlen)-1 downto log2(2*ddrbits/8)) then
      if hwidthen=0 or dr.hwidth='0' or dr.hwctr='1' then
        dv.pastlast := '1';
      end if;
      case ddrbits is
        when 16 => null;
        when 32 =>
          if dr.endaddr(2)='0' then
            mask(7 downto 0) := mask(7 downto 0) or x"0F";
          end if;
        when 64 =>
          case endaddr32 is
            when "00"   => mask := mask or x"0FFF";
            when "01"   => mask := mask or x"00FF";
            when "10"   => mask := mask or x"000F";
            when others => null;
          end case;
        when others => null;
      end case;
    end if;
    -- Before first
    if dr.col(1)='1' and dr.ctr(0)='1' and dr.ctr(dr.ctr'high downto 1)=zerov(dr.ctr'length-1) then
      mask := mask or x"FFFF";
    end if;
    
    dv.sdo_rasn := '1'; dv.sdo_casn := '1'; dv.sdo_wen := '1';
    dv.sdo_odt := '0'; dv.sdo_oct := '0';
    dv.rbwrite := '0';
    
    dv.ctr := std_logic_vector(unsigned(dr.ctr)+1);

    if hwidthen/=0 and dr.hwidth='1' and dr.s=dsdata then
      dv.hwctr := not dr.hwctr;
      if dr.hwctr='0' then dv.ctr := dr.ctr; end if;
    end if;
    
    dv.rastimer := std_logic_vector(unsigned(dr.rastimer)+1);
    if dr.rastimer=dr.cfg.tras then dv.tras_met := '1'; end if;

    -- Calculate whether we would precharge the next cycle if Tras=0 
    precharge_notras := '0';
    if dr.casctr=zerov(dr.casctr'length) and dr.prectr="000000" and dr.pchpend='1' then
      precharge_notras := '1';
    end if;
    -- Calculate whether we should precharge the next cycle
    precharge_next := precharge_notras and dr.tras_met;
    block_precharge := '0';

    inc_rctr := '0';
    
    goto_caslat := '0';
    case dr.s is
      when dsidle =>
        dv.ctr := (others => '0');
        dv.hwctr := '0';
        dv.sdo_bdrive := not oepols;
        dv.sdo_qdrive := not oepols;
        dv.sdo_nbdrive := not oepols;
        dv.col := acol;
        dv.sdo_csn := (others => '1');
        dv.rastimer := (others => '0');
        dv.tras_met := '0';
        dv.response.rctr_gray := "0000";
        
        if dr.refpend='1' and dr.cfg.refon='1' then
          -- Periodic refresh
          dv.sdo_csn := (others => '0');
          dv.sdo_rasn := '0';
          dv.sdo_casn := '0';
          dv.refpend := '0';
          dv.s := dsrefresh;

        elsif vstart /= dr.response.done_tog and (dr.cmds=dcon or (dr.cmds=dcoff and dr.cfg.renable='0')) then
          -- R/W data
          dv.sdo_rasn := '0' or hio1;
          dv.sdo_csn := acsn;
          dv.sdo_address := arow;
          dv.sdo_ba := abank;
          dv.s := dsrascas;
          
        elsif dr.cfg.command /= "000" then
          -- Command
          dv.sdo_csn := (others => '0');
          if dr.cfg.command(2 downto 1)="11" then
            dv.sdo_wen:='0'; dv.sdo_casn:='0'; dv.sdo_rasn:='0';
            
            dv.sdo_ba := "00" & dr.cfg.command(0);
            if dr.cfg.command(0)='0' or dr.cfg.emr="00" then
              dv.sdo_ba := "000";
              dv.sdo_address := mr;
            else
              dv.sdo_ba := "0" & dr.cfg.emr;
              if dr.cfg.emr="01" then
                dv.sdo_address := "0000"&conv_std_logic(dqsse=1)&dr.cfg.ocd&dr.cfg.ocd&dr.cfg.ocd 
                                  & dr.cfg.odten(1)&"000"& dr.cfg.odten(0) & dr.cfg.strength & "0"; 
                
              else
                dv.sdo_address := (others => '0');
              end if;
            end if;            
          else
            dv.sdo_wen := dr.cfg.command(2);
            dv.sdo_casn := dr.cfg.command(1);
            dv.sdo_rasn := dr.cfg.command(0);
            dv.sdo_address(10) := '1';
            -- print("X Command: " & tost(dr.cfg.command) & " -> casn:" & tost(dv.sdo_casn) & ",rasn:" & tost(dv.sdo_rasn) & ",wen:" & tost(dv.sdo_wen));
            
          end if;
          dv.cfg.command := "000";
          if dr.cfg.command=CMD_REF then
            dv.s := dsrefresh;
          end if;
          if dr.cfg.command=CMD_PRE then
            dv.s := dspreall;
          end if;
        end if;
        
      when dsrascas =>
        if dr.ctr(2 downto 0)="000" then
          -- pragma translate_off
          assert dr.ctr="00000000" severity failure;
          -- pragma translate_on
          -- dv.row := dr.sdo_address;
          dv.setrow := '1';
        end if;
        dv.hwrite := vreq.hwrite;
        dv.hsize := vreq.hsize;
        dv.endaddr := aendaddr;
        dv.addrlo := aloa;
        dv.sdo_address := dr.col(13 downto 10) & '0' & dr.col(9 downto 1) & '0';
        if dr.hwidth='1' then
          dv.sdo_address := dr.col(12 downto 9) & '0' & dr.col(8 downto 1) & "00";
        end if;
        
        if vreq.hio='1' and dr.ctr(0)='1' then
          dv.s := dsreg;
          dv.ctr := (others => '0');          
          dv.hwctr := '0';
        elsif vreq.hio='0' and dr.ctr(2 downto 0)=dr.cfg.trcd then
          goto_caslat := '1';
        end if;

      when dscaslat =>
        dv.sdo_odt := dr.hwrite;
        dv.sdo_oct := not dr.hwrite;
        dv.pastlast := '0';
        if  (dis_caslat = 0 and dr.ctr(2 downto 0)=caslat_reg) or
            (dis_caslat /= 0 and dr.hwrite='0' and dr.ctr(2 downto 0)="000" ) or
            (dis_caslat /= 0 and dr.hwrite='1' and dr.ctr(2 downto 0)=std_logic_vector(unsigned(sdi.regrdata(2 downto 0)) -1)) then
          if dr.hwrite='1' then
            dv.s := dsdata;
          else
            dv.s := dsreaddly;
          end if;
          dv.ctr := (others => '0');
          dv.hwctr := '0';
          dv.sdo_qdrive := not (dr.hwrite xor oepols);
          dv.sdo_nbdrive := not (dr.hwrite xor oepols);
        end if;

      when dsreaddly =>
        dv.sdo_odt := dr.hwrite;
        dv.sdo_oct := not dr.hwrite;
        dv.pastlast := '0';
        if dr.ctr(3 downto 0)=dr.cfg.readdly then
          dv.s := dsdata;
          dv.ctr := (others => '0');
          dv.hwctr := '0';
        end if;
        
      when dsdata =>

        inc_rctr := '0';

        dv.sdo_odt := dr.hwrite;
        dv.sdo_oct := not dr.hwrite;
        dv.rbwrite := '1';
        dv.sdo_dqm := mask;
        dv.sdo_bdrive := not (dr.hwrite xor oepols);
        dv.sdo_qdrive := not (dr.hwrite xor oepols);
        dv.sdo_nbdrive := not (dr.hwrite xor oepols);
        
        -- If-case to handle pausing for half-width mode
        if hwidthen=0 or dr.hwidth='0' or dr.hwctr='1' then

          inc_rctr := '1';
          
          -- The first request may be on a 2-odd column to get the first data first
          -- Make sure following requests are on even mult of 4xcolumns
          if dr.ctr(0)='1' then
            dv.col(1) := '0';          
          end if;
          -- Make sure we don't advance read counter for the unwanted 3:rd/4:th
          -- word in the burst in this case
          if dr.ctr(0)='1' and dr.col(1)='1' then
            inc_rctr := '0';
          end if;
          
          -- Toggle done and change state after completed burst
          if dr.ctr(log2(ddr_burstlen)-1 downto 0)=(not zerov(l2ddr_burstlen)) then
            dv.sdo_nbdrive := not oepols;
            dv.s := dsdone;
            dv.response.done_tog := not dr.response.done_tog;
          end if;
        end if;

        -- Stall if not ready yet
        if hasdqvalid/=0 and sdi.datavalid='0' and dr.hwrite='0' then
          dv.ctr := dr.ctr;
          dv.hwctr := dr.hwctr;
          dv.response := dr.response;
          dv.s := dsdata;
          dv.col(1) := dr.col(1);
          dv.rbwrite := '0';
          inc_rctr := '0';
        end if;

        if inc_rctr='1' and dr.hwrite='0' then          
          dv.response.rctr_gray(l2ddr_burstlen-1 downto 0) :=
            nextgray(dr.response.rctr_gray(l2ddr_burstlen-1 downto 0));
        end if;
        
      when dsdone =>
        dv.response.rctr_gray := "0000";
        dv.sdo_bdrive := not oepols;
        if dr.ctr(0)='1' then
          dv.sdo_qdrive := not oepols;
        end if;
        if dr.pchpend='0' and dr.prectr=zerov(dr.prectr'length) then
          dv.s := dsidle;
        end if;
        -- Short circuit if request on same row and waiting for Tras to expire
        if precharge_notras='1' and precharge_next='0' and 
          dr.start_tog_prev /= dr.response.done_tog and dr.samerow='1' and vreq.hio='0' then 
          dv.col := acol;
          dv.endaddr := aendaddr;
          dv.addrlo := aloa;
          dv.hwrite := vreq.hwrite;
          dv.hsize := vreq.hsize;
          dv.s := dsagain;
          dv.sdo_qdrive := not oepols;
        end if;

      when dsagain =>
        block_precharge := '1';
        dv.sdo_address := dr.col(13 downto 10) & '0' & dr.col(9 downto 1) & '0';
        goto_caslat := '1';
        
      when dsreg =>
        -- This code assumes ddrbits>=16, needs to be changed slightly to support
        -- smaller widths
        dv.rbwrite := '1';
        
        -- DDR2CFG1-5,PHYCFG read
        regt0 := (others => '0'); regt1 := (others => '0');
        case ddrbits is
          when 16 =>
            case endaddr42 is
              when "000"  => regt0 := regsd1(31 downto 16); regt1 := regsd1(15 downto 0);
              when "001"  => regt0 := regsd2(31 downto 16); regt1 := regsd2(15 downto 0);
              when "010"  => regt0 := regsd3(31 downto 16); regt1 := regsd3(15 downto 0);
              when "011"  => regt0 := regsd4(31 downto 16); regt1 := regsd4(15 downto 0);
              when "100" | "101"  => regt0 := regsd5(31 downto 16); regt1 := regsd5(15 downto 0);
              when "110"  => regt0 := sdi.regrdata(31 downto 16); regt1 := sdi.regrdata(15 downto 0);
              when others => regt0 := sdi.regrdata(63 downto 48); regt1 := sdi.regrdata(47 downto 32);
            end case;
          when 32 =>
            case endaddr43 is
              when "00"   => regt0 := regsd1; regt1 := regsd2;
              when "01"   => regt0 := regsd3; regt1 := regsd4;
              when "10"   => regt0 := regsd5; regt1 := regsd2;
              when others => regt0 := sdi.regrdata(31 downto 0); regt1 := sdi.regrdata(63 downto 32);
            end case;
          when 64 =>
            case dr.endaddr(4) is
              when '0'    => regt0 := regsd1 & regsd2; regt1 := regsd3 & regsd4;
              when others => regt0 := regsd5 & regsd2; regt1 := sdi.regrdata(31 downto 0) & sdi.regrdata(63 downto 32);
            end case;
          when 128 =>
            regt0 := regsd1 & regsd2 & regsd3 & regsd4;
            regt1 := regsd5 & regsd2 & sdi.regrdata(31 downto 0) & sdi.regrdata(63 downto 32);
          when others =>
            regt0(ddrbits-1 downto ddrbits-255) := regsd1 & regsd2 & regsd3 & regsd4 &
                                                   regsd5 & x"00000000" & sdi.regrdata(31 downto 0) & sdi.regrdata(63 downto 32);
        end case;
        dv.rbwdata(ddrbits*2+chkbits-1 downto ddrbits+chkbits) := regt0;
        dv.rbwdata(ddrbits-1 downto 0) := regt1;
        
        -- Note write data is two cycles behind
        regt0 := dr.sdo_data(ddrbits*2-1 downto ddrbits);
        regt1 := dr.sdo_data(ddrbits-1 downto 0);
        if dr.hwrite='1' and dr.ctr(2 downto 0)="010" then
          w5 := '0';
          case ddrbits is
            when 16 =>
              case endaddr42 is
                when "000"  => regsd1 := regt0 & regt1;
                when "001"  => regsd2 := regt0 & regt1;
                when "010"  => regsd3 := regt0 & regt1;
                when "011"  => regsd4 := regt0 & regt1;
                when "100"  => regsd5 := regt0 & regt1;
                               w5 := '1';
                when "110"  => o.regwrite(0) := '1';
                when "111"  => o.regwrite(1) := '1';
                when others => null;
              end case;
            when 32 => 
              case endaddr42 is
                when "000"  => regsd1 := regt0;
                when "001"  => regsd2 := regt1;
                when "010"  => regsd3 := regt0;
                when "011"  => regsd4 := regt1;
                when "100"  => regsd5 := regt0;
                               w5 := '1';
                when "110"  => o.regwrite(0) := '1';
                when "111"  => o.regwrite(1) := '1';
                when others => null;
              end case;
            when 64 =>
              case endaddr42 is
                when "000"  => regsd1 := regt0(63 downto 32);
                when "001"  => regsd2 := regt0(31 downto 0);
                when "010"  => regsd3 := regt1(63 downto 32);
                when "011"  => regsd4 := regt1(31 downto 0);
                when "100"  => regsd5 := regt0(63 downto 32);
                               w5 := '1';
                when "110"  => o.regwrite(0) := '1';
                when "111"  => o.regwrite(1) := '1';
                when others => null;
              end case;
            when 128 =>
              case endaddr42 is
                when "000"  => regsd1 := regt0(127 downto 96);
                when "001"  => regsd2 := regt0(95 downto 64);
                when "010"  => regsd3 := regt0(63 downto 32);
                when "011"  => regsd4 := regt0(31 downto 0);
                when "100"  => regsd5 := regt1(127 downto 96);
                               w5 := '1';
                when "110"  => o.regwrite(0) := '1';
                when "111"  => o.regwrite(1) := '1';
                when others => null;                               
              end case;
            when others =>
              case endaddr42 is
                when "000"  => regsd1 := regt0(ddrbits-1 downto ddrbits-32);
                when "001"  => regsd2 := regt0(ddrbits-33 downto ddrbits-64);
                when "010"  => regsd3 := regt0(ddrbits-65 downto ddrbits-96);
                when "011"  => regsd4 := regt0(ddrbits-97 downto ddrbits-128);
                when "100"  => regsd5 := regt0(ddrbits-129 downto ddrbits-160);
                               w5 := '1';
                when "110"  => o.regwrite(0) := '1';
                when "111"  => o.regwrite(1) := '1';
                when others => null;                               
              end case;
          end case;
          -- Update lsb aliases for expanded fields in ddr2cfg5
          if w5='1' then
            regsd3(28) := regsd5(28);   -- TRP
            regsd3(22 downto 18) := regsd5(22 downto 18);  -- TRFC
            regsd1(26) := regsd5(8);    -- TRCD
          end if;
          
        end if;

        if (dr.hwrite='1' and dr.ctr(2 downto 1)="11") or dr.hwrite='0' then
          dv.s := dsidle;
          dv.response.done_tog := not dr.response.done_tog;
        end if;

        dv.cfg := (refon => regsd1(31), ocd => regsd1(30), emr => regsd1(29 downto 28),
                   trcd => regsd5(10 downto 9) & regsd1(26),
                   bsize => regsd1(27) & regsd1(25 downto 23), csize => regsd1(22 downto 21),
                   command => regsd1(20 downto 18), dllrst => regsd1(17), renable => regsd1(16),
                   cke => regsd1(15), refresh => regsd1(11 downto 0),
                   cal_pll => regsd3(30 downto 29), cal_rst => regsd3(31),
                   trp => regsd5(30 downto 29) & regsd3(28),
                   twr => regsd3(27 downto 23),
                   trfc => regsd5(25 downto 23) & regsd3(22 downto 18),
                   readdly => regsd4(23 downto 22) & regsd3(17 downto 16), cal_inc => regsd3(15 downto 8),
                   cal_en => regsd3(7 downto 0),
                   eightbanks => regsd4(8), dqsctrl => regsd4(7 downto 0),
                   caslat => regsd4(10 downto 9),
                   odten => regsd5(17 downto 16), tras => regsd5(4 downto 0), strength => regsd5(15),
                   trtp => regsd4(13), cbcal_inc => regsd4(31 downto 28), cbcal_en => regsd4(27 downto 24),
                   regmem => regsd4(21)
                   );

      when dsrefresh =>
        if dr.ctr(7 downto 0)=dr.cfg.trfc then
          dv.s := dsidle;
        end if;

      when dspreall =>
        -- Wait for tRP (eightbanks=0) or tRP+1 (eightbanks=1)
        if dr.ctr(3 downto 0)=std_logic_vector(("0" & unsigned(dr.cfg.trp)) + (2+eightbanks)) then
          dv.s := dsidle;
        end if;
        
    end case;

    if goto_caslat='1' then
      dv.s := dscaslat;
      -- Set counter to -4 for read and -1 for write to compensate
      -- write-read diff and pipelining.
      -- Only need lowest three bits so set highest 3 to '0' as usual
      dv.ctr(5 downto 3) := "000";
      dv.ctr(2 downto 0) := "100";
      if vreq.hwrite='1' then
        dv.ctr(2 downto 0) := "111";
      end if;
      dv.casctr := std_logic_vector(to_unsigned(ddr_burstlen/2, dv.casctr'length));
      dv.hwcas := '0';
      dv.pchpend := '1';      
    end if;
    
    -- CAS and precharge handling
    -- FSM above sets up casctr and pchpend
    if dis_caslat /= 0 then
      dv.twr_plus_cl := std_logic_vector(("0" & unsigned(dr.cfg.twr)) + ("000" & unsigned(sdi.regrdata(2 downto 0))) - 1); --  should be -2 instead of -1 but AFI might delay write data for an additional clock cycle, requiring an additional twr clock cycle
    else
      dv.twr_plus_cl := std_logic_vector(("0" & unsigned(dr.cfg.twr)) + ("0000" & unsigned(dr.cfg.caslat)));
    end if;

    if dr.prectr /= zerov(dr.prectr'length) then
      dv.prectr := std_logic_vector(unsigned(dr.prectr)-1);
    end if;

    dv.read_pend := '0' & dr.read_pend(dr.read_pend'high downto 1);
    
    dv.datacas := '1';
    if dr.casctr /= zerov(dr.casctr'length) then
      if dr.datacas='1' then
        dv.datacas := '0';
        -- dv.sdo_casn := '0';
        dv.sdo_wen := not dr.hwrite;
        if dr.hwrite='0' then
          if dis_caslat /= 0 then
            dv.read_pend(4 downto 3) := "11";
          else
            case dr.cfg.caslat is
              when "00"   => dv.read_pend(4 downto 3) := "11";
              when "01"   => dv.read_pend(5 downto 4) := "11";
              when "10"   => dv.read_pend(6 downto 5) := "11";
              when others => dv.read_pend(7 downto 6) := "11";
            end case;
          end if;
        end if;
      elsif dr.hwidth='1' then

        dv.hwcas := not dr.hwcas;
        if dr.hwcas='1' then          
          dv.casctr := std_logic_vector(unsigned(dr.casctr)-1);
          if l2blen-l2ddrw > 1 then
            dv.sdo_address(l2blen-l2ddrw+1 downto 3) :=
              std_logic_vector(unsigned(dr.sdo_address(l2blen-l2ddrw+1 downto 3)+1));
          end if;
          dv.sdo_address(2) := '0';
        else
          dv.sdo_address(2) := not dr.sdo_address(2);
        end if;
        
      else
        dv.casctr := std_logic_vector(unsigned(dr.casctr)-1);
        if l2blen-l2ddrw > 1 then
          dv.sdo_address(l2blen-l2ddrw downto 2) :=
            std_logic_vector(unsigned(dr.sdo_address(l2blen-l2ddrw downto 2)+1));
        end if;
        dv.sdo_address(1) := '0';
      end if;
      -- Set up precharge counter (will not run until casctr=0)
      if dr.hwrite='0' then
        dv.prectr := "00000" & dr.cfg.trtp;
      else
        dv.prectr := dr.twr_plus_cl;
      end if;
    end if;
    
    o.read_pend := dv.read_pend(7 downto 0);
    
    dv.rasn_pre := '1';
    if precharge_next='1' and block_precharge='0' then
      dv.pchpend := '0';
      dv.sdo_wen := '0';
      -- dv.sdo_rasn := '0';
      dv.rasn_pre := '0';
      dv.prectr := "000" & dr.cfg.trp;
    end if;
    
    -- Refresh and init handling    
    dv.refctr := std_logic_vector(unsigned(dr.refctr)+1);
    case dr.cmds is
      when dcrstdel =>
        if dr.refctr=std_logic_vector(to_unsigned(MHz*rstdel, dr.refctr'length)) then
          dv.cmds := dcoff;
        end if;
        -- Bypass reset delay by writing anything to regsd2
        if dr.start_tog_prev='1' and
          vreq.hio='1' and vreq.hwrite='1' and vreq.endaddr(4 downto 2)="001" then
          dv.cmds := dcoff;
        end if;
        
      when dcoff =>
        -- Wait for renable to be set high and phy to be locked
        dv.refctr := (others => '0');
        if dr.cfg.renable='1' then
          dv.cfg.cke := '1';
          dv.cfg.dllrst := '1';
          dv.cfg.ocd := '0';
          dv.cmds := dcinit1;
        elsif dis_init /= 0 then
          dv.cmds := dcon;
        end if;
      when dcinit1 =>
        -- Wait >=400 ns
        if dr.refctr=std_logic_vector(to_unsigned((MHz*4+9)/10, dr.refctr'length)) then
          dv.cmds := dcinit2;
          dv.cfg.command := CMD_PRE;
          dv.cfg.emr := "00";
        end if;
        
      when dcinit2 =>
        -- MR order 2,3,1,0
        -- 2xcycles per command
        if dr.cfg.command="000" then
          dv.cfg.command := CMD_EMR;
          dv.cfg.emr := (not dr.cfg.emr(0)) & dr.cfg.emr(1);  -- 00->10->11->01->00          
          if dr.cfg.emr="01" then
            dv.cmds := dcinit3;
            dv.refctr := (others => '0');
          end if;
        end if;

      when dcinit3 =>
        if dr.cfg.command="000" then
          dv.cfg.command := CMD_PRE;
          dv.cmds := dcinit4;
        end if;

      when dcinit4 =>
        if dr.cfg.command="000" then
          dv.cfg.command := CMD_REF;
          dv.cmds := dcinit5;
        end if;

      when dcinit5 =>
        if dr.cfg.command="000" then
          dv.cfg.command := CMD_REF;
          dv.cmds := dcinit6;
        end if;

      when dcinit6 =>
        if dr.cfg.command="000" then
          dv.cfg.command := CMD_EMR;
          dv.cfg.emr := "00";
          dv.cfg.dllrst := '0';
          dv.cmds := dcinit7;
          dv.refctr := (others => '0');
        end if;

      when dcinit7 =>
        if dr.refctr(7 downto 0)=std_logic_vector(to_unsigned(200,8)) then
          dv.cfg.command := CMD_EMR;
          dv.cfg.emr := "01";
          dv.cfg.ocd := '1';
          dv.cmds := dcinit8;
        end if;

      when dcinit8 =>        
        if dr.cfg.command="000" then
          if dr.cfg.ocd='1' then
            dv.cfg.ocd := '0';
            dv.cfg.command := CMD_EMR;
          else            
            dv.cmds := dcon;
            dv.cfg.renable := '0';
          end if;
        end if;
        dv.refctr := (others => '0');
      
      when dcon =>
        if dr.cfg.cke='0' then
          dv.cmds := dcoff;
        elsif dr.cfg.renable='1' then          
          dv.cmds := dcinit2;
          dv.refctr := (others => '0');
        elsif dr.refctr(11 downto 0)=dr.cfg.refresh then
          dv.refpend := '1';
          dv.refctr := (others => '0');
        end if;
        
    end case;

    if dis_init /= 0 then
      dv.cfg.renable := '0';
    end if;
    -- Calculate next address    
    dv.ramaddr(0) := dv.ctr(0) xor dv.col(1);
    if rbuf_wabits > 1 then
      dv.ramaddr(rbuf_wabits-1 downto 1) :=
        std_logic_vector(unsigned(dr.col(rbuf_wabits downto 2)) +
                         unsigned(dv.ctr(rbuf_wabits-1 downto 1)));
    end if;
    
      -- print("col: " & tost(dr.col) & ", dv.ctr: " & tost(dv.ctr) & ", res: " & tost(dv.ramaddr));
    
    
    if eightbanks=0 then dv.cfg.eightbanks:='0'; end if;    

    rbwd := dv.rbwdata;
    rbwa := dr.ramaddr;
    rbw  := dv.rbwrite;

    if plmemwrite then
      rbwd := dr.rbwdata;
      rbwa := dr.ramaddr_prev;
      rbw  := dr.rbwrite;
    end if;

    if not plmemread then
      o.dqm   := dr.sdo_dqm;
      o.sdwen := dr.sdo_wen;
      o.data  := dv.sdo_data;
      o.cb    := dv.sdo_cb;
    end if;

    -- half-width output data muxing, placed after (potential) pipeline regs.
    if hwidthen/=0 and dr.hwidth='1' then
      if dr.hwctr='1' then
        o.data(ddrbits/2-1 downto 0) := o.data(2*ddrbits-ddrbits/2-1 downto ddrbits);
        o.data(2*ddrbits-ddrbits/2-1 downto ddrbits) := o.data(2*ddrbits-1 downto 2*ddrbits-ddrbits/2);
        if chkbits > 0 then
          o.cb(chkbits/2-1 downto 0) := o.cb(2*chkbits-chkbits/2-1 downto chkbits);
          o.cb(2*chkbits-chkbits/2-1 downto chkbits) := o.cb(2*chkbits-1 downto 2*chkbits-chkbits/2);
        end if;
        o.dqm(ddrbits/16-1 downto 0) := o.dqm(ddrbits/4-ddrbits/16-1 downto ddrbits/8);
        o.dqm(ddrbits/4-ddrbits/16-1 downto ddrbits/8) := o.dqm(ddrbits/4-1 downto ddrbits/4-ddrbits/16);
      else
        o.data(2*ddrbits-ddrbits/2-1 downto ddrbits) := o.data(ddrbits-1 downto ddrbits/2);
        if chkbits > 0 then
          o.cb(2*chkbits-chkbits/2-1 downto chkbits) := o.cb(chkbits-1 downto chkbits/2);
        end if;
        o.dqm(ddrbits/4-ddrbits/16-1 downto ddrbits/8) := o.dqm(ddrbits/8-1 downto ddrbits/16);
      end if;
    end if;
    
    if ddr_rst='0' then
      dv.s := dsidle;
      dv.cmds := dcrstdel;
      dv.response := ddr_response_none;
      dv.casctr := (others => '0');
      dv.refctr := (others => '0');
      dv.pchpend := '0';
      dv.refpend := '0';
      dv.rbwrite := '0';
      dv.ctr := (others => '0');
      dv.hwctr := '0';
      dv.sdo_nbdrive := not oepols;
      dv.sdo_csn := (others => '1');
      dv.rastimer := (others => '0');
      dv.tras_met := '0';
      dv.cfg.command  := "000";
      dv.cfg.emr      := "00";
      dv.cfg.csize    := conv_std_logic_vector(col-9, 2);
      dv.cfg.bsize    := conv_std_logic_vector(log2(Mbyte/8), 4);
      dv.cfg.refon    :=  '0';
      dv.cfg.trfc     := conv_std_logic_vector(TRFC*MHz/1000-2, 8);
      dv.cfg.refresh  := conv_std_logic_vector(7800*MHz/1000, 12);
      dv.cfg.twr      := conv_std_logic_vector((15 * MHz + 999) / 1000 + 3, 5);
      dv.sdo_dqm      := (others => '1');
      dv.cfg.dllrst   := '0';
      dv.cfg.cke      := std_logic(to_unsigned(cke_rst, 1)(0));
      dv.cfg.ocd      := '0';
      dv.cfg.readdly  := conv_std_logic_vector(readdly, 4);
      dv.cfg.eightbanks := conv_std_logic_vector(eightbanks, 1)(0);
      dv.cfg.odten := std_logic_vector(to_unsigned(odten,2));
      dv.cfg.dqsctrl := (others => '0');      
      dv.cfg.strength := '0';
      if pwron = 1 and dis_init = 0 then dv.cfg.renable :=  '1'; else dv.cfg.renable:='0'; end if;
      -- Default to min 15 ns tRCD, 15 ns tRP, min(7.5 ns,2*tCK) tRTP      
      -- Use CL=3 for DDR2-400/533, 4 for DDR2-667, 5 for DDR2-800
      dv.cfg.trcd := "000";
      dv.cfg.trp := "000";
      dv.cfg.trtp := '0';
      dv.cfg.caslat := "00";
      dv.cfg.regmem := '0';
      if MHz > 130 then
        dv.cfg.trcd :=  "001";
        dv.cfg.trp := "001";
      end if;
      if MHz > 200 then
        -- Will work up to 600 MHz, then trcd/trp needs to be expanded
        dv.cfg.trcd := std_logic_vector(to_unsigned((15 * MHz + 999) / 1000 - 2, 3));
        dv.cfg.trp := std_logic_vector(to_unsigned((15 * MHz + 999) / 1000 - 2, 3));        
      end if;
      if MHz > 267 then
        -- Works up to 400 MHz, then trtp will need to be expanded
        dv.cfg.trtp := '1';
        dv.cfg.caslat := "01";
      end if;
      if MHz > 334 then
        dv.cfg.caslat := "10";
      end if;
      dv.cfg.cal_rst := '1'; -- Reset input delays            
      dv.sdo_ba := (others => '0');
      dv.sdo_address := (others => '0');
      -- Default to min 45 ns tRAS
      dv.cfg.tras := std_logic_vector(to_unsigned((45*MHz+999)/1000 - 2, 5));
      dv.read_pend := (others => '0');
      if ddr_syncrst /= 0 then 
        dv.sdo_bdrive := not oepols;
        dv.sdo_qdrive := not oepols;
        dv.sdo_odt := '0';
        if phyptctrl /= 0 then
          o.sdcke := "00";
          o.bdrive := not oepols;
          o.qdrive := not oepols;
          o.odt := (others => '0');
        end if;
      end if;
    end if;
    
    if dr.cfg.odten="00" then
      dv.sdo_odt := '0';
    end if;
    if octen=0 then
      dv.sdo_oct := '0';
    end if;
    
    for x in 0 to chkbits/4-1 loop
      o.cbdqm(x) := o.dqm(x*ddrbits/chkbits);
    end loop;

    if vreq.maskdata='1' then
      o.dqm := (others => '1');
    end if;
    if vreq.maskcb='1' then
      o.cbdqm := (others => '1');
    end if;
    
    if dr.cfg.command /= "000" then
      -- print("Command: " & tost(dr.cfg.command) & " -> casn:" & tost(dv.sdo_casn) & ",rasn:" & tost(dv.sdo_rasn) & ",wen:" & tost(dv.sdo_wen));
    end if;

    -- Dynamic nosync handling (nosync=2)
    if plmemwrite then
      dv.response1 := dr.response;
      dv.response2 := dr.response;
    else
      dv.response1 := dv.response;
      dv.response2 := dv.response;
    end if;
    if reqsel='1' then dv.response1 := ddr_response_none; end if;    
    if reqsel='0' then dv.response2 := ddr_response_none; end if;

    if nosync > 1 then
      resp := dr.response1;
    elsif plmemwrite then
      resp := dr.response_prev;
    else
      resp := dr.response;
    end if;
    resp2 := dr.response2;

    if scantest/=0 and phyptctrl/=0 then
      if testen='1' then
        o.bdrive := testoen;
        o.qdrive := testoen;
      end if;
    end if;
    
    rbwdata <= rbwd;
    rbwaddr <= rbwa;
    rbwrite <= rbw;
    wbraddr <= wbra;
    sdo     <= o;
    response  <= resp;
    response2 <= resp2;
    ndr     <= dv;
  end process;

  
  ddrregs: process(clk_ddr,arst)
  begin
    if rising_edge(clk_ddr) then
      dr <= ndr;
    end if;
    if ddr_syncrst=0 and arst='0' then
      dr.cfg.cke <= std_logic(to_unsigned(cke_rst, 1)(0));
      dr.sdo_bdrive <= not oepols;
      dr.sdo_qdrive <= not oepols;
      dr.sdo_odt <= '0';
    end if;
  end process;
    
end;

