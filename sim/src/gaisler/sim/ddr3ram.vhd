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
-- Entity:      ddr3ram
-- File:        ddr3ram.vhd
-- Author:      Magnus Hjorth, Aeroflex Gaisler
-- Description: Generic simulation model of DDR3 SDRAM (JESD79-3)
------------------------------------------------------------------------------

--pragma translate_off

use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdio.hread;
use work.stdlib.all;

entity ddr3ram is
  generic (
    width: integer := 32;
    abits: integer range 13 to 16 := 13;
    colbits: integer range 9 to 12 := 10;
    rowbits: integer range 1 to 16 := 13;
    implbanks: integer range 1 to 8 := 1;
    fname: string;
    lddelay: time := (0 ns);
    ldguard: integer range 0 to 1 := 0;  -- 1: wait for doload input before
                                         -- loading RAM
    -- Speed bins: 0-1:800E-D, 2-4:1066G-E 5-8:1333J-F 9-12:1600K-G
    speedbin: integer range 0 to 12 := 0;
    density: integer range 2 to 6 := 3;  -- 2:512M 3:1G 4:2G 5:4G 6:8G bits/chip
    pagesize: integer range 1 to 2 := 1;  -- 1K/2K page size (controls tRRD)
    changeendian: integer range 0 to 32 := 0
    );
  port (
    ck: in std_ulogic;
    ckn: in std_ulogic;
    cke: in std_ulogic;
    csn: in std_ulogic;
    odt: in std_ulogic;
    rasn: in std_ulogic;
    casn: in std_ulogic;
    wen: in std_ulogic;
    dm: in std_logic_vector(width/8-1 downto 0);
    ba: in std_logic_vector(2 downto 0);
    a: in std_logic_vector(abits-1 downto 0);
    resetn: in std_ulogic;
    dq: inout std_logic_vector(width-1 downto 0);
    dqs: inout std_logic_vector(width/8-1 downto 0);
    dqsn: inout std_logic_vector(width/8-1 downto 0);
    doload: in std_ulogic := '1'
    );
end;

architecture sim of ddr3ram is

  type moderegs is record
    -- Mode register (0)
    ppd: std_ulogic;
    wr: std_logic_vector(2 downto 0);
    dllres: std_ulogic;
    tm: std_ulogic;
    rbt: std_ulogic;
    caslat: std_logic_vector(3 downto 0);
    blen: std_logic_vector(1 downto 0);
    -- Extended mode register 1
    qoff: std_ulogic;
    tdqsen: std_ulogic;
    level: std_ulogic;
    al: std_logic_vector(1 downto 0);
    rtt_nom: std_logic_vector(2 downto 0);
    dic: std_logic_vector(1 downto 0);
    dlldis: std_ulogic;
    -- Extended mode register 2
    rtt_wr: std_logic_vector(1 downto 0);
    srt: std_ulogic;
    asr: std_ulogic;
    cwl: std_logic_vector(2 downto 0);
    pasr: std_logic_vector(2 downto 0);
    -- Extended mode register 3
    mpr: std_ulogic;
    mprloc: std_logic_vector(1 downto 0);
  end record;

  -- Mode registers as signal, useful for debugging
  signal mr: moderegs;

  -- Handshaking between command and DQ/DQS processes
  signal read_en, write_en, dqscal_en: boolean := false;
  signal read_data, write_data: std_logic_vector(2*width-1 downto 0);
  signal write_mask: std_logic_vector(width/4-1 downto 0);

  signal initdone: boolean := false;

  -- Small delta-t to adjust calculations for jitter tol.
  constant deltat: time := 50 ps;

  -- Timing parameters
  constant tWR: time := 15 ns;
  constant tMRD_ck: integer := 4;
  constant tRTP_ck: integer := 4;
  constant tRTP_t: time := 7.5 ns;
  function tRTP(tper: time) return time is
  begin
    if tRTP_ck*tper > tRTP_t then return tRTP_ck*tper; else return tRTP_t; end if;
  end tRTP;
  constant tMOD_ck: integer := 12;
  constant tMOD_t: time := 15 ns;

  type timetab is array (0 to 12) of time;
  -- 800E     800D     1066G    1066H      1066E     1333J  1333H    1333G  1333F    1600K     1600J    1600H     1600G
  constant tRAS : timetab :=
    (37.5 ns, 37.5 ns, 37.5 ns, 37.5   ns, 37.5  ns, 36 ns, 36   ns, 36 ns, 36   ns, 35    ns, 35   ns, 35    ns, 35 ns);
  constant tRP :  timetab :=
    (15   ns, 12.5 ns, 15   ns, 13.125 ns, 11.25 ns, 15 ns, 13.5 ns, 12 ns, 10.5 ns, 13.75 ns, 12.5 ns, 11.25 ns, 10 ns);
  constant tRCD:  timetab := tRP;

  type timetab2 is array(2 to 6) of time;
  constant tRFC: timetab2 := (90 ns, 110 ns, 160 ns, 300 ns, 350 ns);

  function tRRD(tper: time; speedbin: integer range 0 to 12) return time is
    variable t: time;
  begin
    case speedbin is
      when 0 to 1  => t:=10 ns;
      when 2 to 4  => if pagesize<2 then t:=7.5 ns; else t:=10 ns; end if;
      when 5 to 12  => if pagesize<2 then t:=6 ns; else t:=7.5 ns; end if;
    end case;
    if t < 4*tper then t:=4*tper; end if;
    return t;
  end tRRD;

  function pick(t,f: integer; b: boolean) return integer is
  begin
    if b then return t; else return f; end if;
  end pick;

begin
  -----------------------------------------------------------------------------
  -- Init sequence checker
  -----------------------------------------------------------------------------
  initp: process

    procedure checkcmd(crasn,ccasn,cwen: std_ulogic;
                       cba: std_logic_vector(2 downto 0);
                       ca: std_logic_vector(15 downto 0)) is
      variable amatch: boolean;
    begin
      wait until rising_edge(ck);
      while cke='1' and (csn='1' or (rasn='1' and casn='1' and wen='1')) loop
        wait until rising_edge(ck);
      end loop;
      amatch := true;
      for x in a'range loop
        if ca(x)/='-' and ca(x)/=a(x) then amatch:=false; end if;
      end loop;
      assert cke='1' and csn='0' and rasn=crasn and casn=ccasn and wen=cwen and
        (cba="---" or cba=ba) and amatch
        report "Wrong command during init sequence" severity warning;
    end checkcmd;

    variable t,t2: time;
    variable i: integer;
  begin
    initdone <= false;
    -- Allow resetn to be X or U for a while during sim start
    if resetn /= '0' then
      wait until resetn='0' for 1 us;
    end if;
    assert resetn='0' report "RESETn not asserted on power-up" severity warning;
    wait until resetn/='0' for 200 us;
    assert resetn='0' report "RESETn raised with less than 200 us init delay" severity warning;
    l0: loop
      initdone <= false;
      wait until resetn/='0';
      assert cke='0' report "CKE not low when RESETn deasserted" severity warning;
      wait until (resetn='0' or cke/='0') for 500 us;
      if resetn='0' then next; end if;
      assert cke='0' report "CKE raised with less than 500 us delay after RESETn deasserted" severity warning;
      wait until (resetn='0' or cke/='0') and rising_edge(ck);
      if resetn='0' then next; end if;
      assert cke='1' and (csn='1' or (rasn='1' and casn='1' and wen='1'));
      t := now;
      t2 := t+tRFC(density)+(10 ns);
      i := 0;
      while i<5 and now<t2 loop
        wait until (resetn='0' or rising_edge(ck));
        if resetn='0' then next l0; end if;
        assert cke='1' and (csn='1' or (rasn='1' and casn='1' and wen='1'));
        i := i+1;
      end loop;
      -- EMRS EMR2
      checkcmd('0','0','0',"010","----------------");
      if resetn='0' then next; end if;
      -- EMRS EMR3
      checkcmd('0','0','0',"011","----------------");
      if resetn='0' then next; end if;
      -- EMRS EMR1 enable DLL
      checkcmd('0','0','0',"001","---------------0");
      if resetn='0' then next; end if;
      -- EMRS EMR0 reset DLL
      checkcmd('0','0','0',"000","-------1--------");
      if resetn='0' then next; end if;
      -- ZQCL
      checkcmd('1','1','0',"---","-----1----------");
      if resetn='0' then next; end if;
      for x in 1 to 512 loop
        wait until (resetn='0' or rising_edge(ck));
        if resetn='0' then next l0; end if;
        assert cke='1' and (csn='1' or (rasn='1' and casn='1' and wen='1'));
      end loop;
      initdone <= true;
      wait until resetn='0';
    end loop;
  end process;

  -----------------------------------------------------------------------------
  -- Command state machine
  -----------------------------------------------------------------------------
  cmdp: process(ck)
    -- Data split by bank to avoid exceeding 4G
    constant b0size: integer := (2**(colbits+rowbits)) * ((width+15)/16);
    constant b1size: integer := pick(b0size, 1, implbanks>1);
    constant b2size: integer := pick(b0size, 1, implbanks>2);
    constant b3size: integer := pick(b0size, 1, implbanks>3);
    constant b4size: integer := pick(b0size, 1, implbanks>4);
    constant b5size: integer := pick(b0size, 1, implbanks>5);
    constant b6size: integer := pick(b0size, 1, implbanks>6);
    constant b7size: integer := pick(b0size, 1, implbanks>7);

    subtype coldata is std_logic_vector(width-1 downto 0);
    subtype idata is integer range 0 to (2**20)-1;  -- 16 data bits + 2x2 X/U state
    type idata_arr is array(natural range <>) of idata;
    variable memdata0: idata_arr(0 to b0size-1);
    variable memdata1: idata_arr(0 to b1size-1);
    variable memdata2: idata_arr(0 to b2size-1);
    variable memdata3: idata_arr(0 to b3size-1);
    variable memdata4: idata_arr(0 to b4size-1);
    variable memdata5: idata_arr(0 to b5size-1);
    variable memdata6: idata_arr(0 to b6size-1);
    variable memdata7: idata_arr(0 to b7size-1);

    function reversedata(data : std_logic_vector; step : integer)
      return std_logic_vector is
      variable rdata: std_logic_vector(data'length-1 downto 0);
    begin
      for i in 0 to (data'length/step-1) loop
        rdata(i*step+step-1 downto i*step) := data(data'length-i*step-1 downto data'length-i*step-step);
      end loop;
      return rdata;
    end function reversedata;

    impure function memdata_get(bank,idx: integer) return coldata is
      variable r: coldata;
      variable x: idata;
      variable p: std_logic_vector(19 downto 0);
      variable iidx: integer;
    begin
      iidx := (idx*width)/16;
      for q in 0 to (width+15)/16-1 loop
        case bank is
          when 0      => x := memdata0(iidx+q);
          when 1      => x := memdata1(iidx+q);
          when 2      => x := memdata2(iidx+q);
          when 3      => x := memdata3(iidx+q);
          when 4      => x := memdata4(iidx+q);
          when 5      => x := memdata5(iidx+q);
          when 6      => x := memdata6(iidx+q);
          when others => x := memdata7(iidx+q);
        end case;
        p := std_logic_vector(to_unsigned(x,20));
        if p(18)='0' then p(15 downto 8) := "UUUUUUUU";
        elsif p(19)='1' then p(15 downto 8) := "XXXXXXXX"; end if;
        if p(16)='0' then p(7 downto 0) := "UUUUUUUU";
        elsif p(17)='1' then p(7 downto 0) := "XXXXXXXX"; end if;
        if width < 16 then
          r := p(7 downto 0);
        else
          r(width-16*q-1 downto width-16*q-16) := p(15 downto 0);
        end if;
      end loop;
      if changeendian /= 0 then
        r := reversedata(r, changeendian);
      end if;
      return r;
    end memdata_get;

    procedure memdata_set(bank,idx: integer; v: coldata) is
      variable n: coldata;
      variable x: idata;
      variable p: std_logic_vector(19 downto 0);
      variable iidx: integer;
    begin
--      assert false
--        report ("memdata_set: bank " & tost(bank) & " idx " & tost(idx) & " data " & tost(v))
--        severity note;
      n := v;
      if changeendian /= 0 then
        n := reversedata(n, changeendian);
      end if;
      iidx := (idx*width)/16;
      for q in 0 to (width+15)/16-1 loop
        p := "0101" & x"0000";
        if width < 16 then
          p(7 downto 0) := n;
        else
          p(15 downto 0) := n(width-16*q-1 downto width-16*q-16);
        end if;
        if p(15 downto 8)="UUUUUUUU" then p(18):='0'; p(15 downto 8):=x"00";
        elsif is_x(p(15 downto 8)) then p(19):='1'; p(15 downto 8):=x"00"; end if;
        if p(7 downto 0)="UUUUUUUU" then p(16):='0'; p(7 downto 0):=x"00";
        elsif is_x(p(7 downto 0)) then p(17):='1'; p(7 downto 0):=x"00"; end if;
        x := to_integer(unsigned(p));
        case bank is
          when 0      => memdata0(iidx+q) := x;
          when 1      => memdata1(iidx+q) := x;
          when 2      => memdata2(iidx+q) := x;
          when 3      => memdata3(iidx+q) := x;
          when 4      => memdata4(iidx+q) := x;
          when 5      => memdata5(iidx+q) := x;
          when 6      => memdata6(iidx+q) := x;
          when others => memdata7(iidx+q) := x;
        end case;
      end loop;
    end memdata_set;

    procedure load_srec is
      file TCF : text open read_mode is fname;
      variable L1: line;
      variable CH : character;
      variable rectype : std_logic_vector(3 downto 0);
      variable recaddr : std_logic_vector(31 downto 0);
      variable reclen  : std_logic_vector(7 downto 0);
      variable recdata : std_logic_vector(0 to 16*8-1);
      variable idx, coloffs, len: integer;
    begin
      L1:= new string'("");
      while not endfile(TCF) loop
        readline(TCF,L1);
        if (L1'length /= 0) then
          while (not (L1'length=0)) and (L1(L1'left) = ' ') loop
            std.textio.read(L1,CH);
          end loop;
          if L1'length > 0 then
            read(L1, ch);
            if (ch = 'S') or (ch = 's') then
              hread(L1, rectype);
              hread(L1, reclen);
              len := to_integer(unsigned(reclen))-1;
              recaddr := (others => '0');
              case rectype is
                when "0001" => hread(L1, recaddr(15 downto 0)); len := len - 2;
                when "0010" => hread(L1, recaddr(23 downto 0)); len := len - 3;
                when "0011" => hread(L1, recaddr);              len := len - 4;
                when others => next;
              end case;
              hread(L1, recdata(0 to len*8-1));
              if width < 16 then
                idx := to_integer(unsigned(recaddr(rowbits+colbits-1 downto 0)));
                while len > 1 loop
                  memdata0(idx) := 16#10000# + to_integer(unsigned(recdata(0 to 7)));
                  idx := idx+1;
                  len := len-1;
                  recdata(0 to recdata'length-8-1) := recdata(8 to recdata'length-1);
                end loop;
              else
                assert recaddr(0)='0';    -- Assume 16-bit alignment on SREC entry
                idx := to_integer(unsigned(recaddr(rowbits+colbits+log2(width/16) downto 1)));
                while len > 1 loop
                  memdata0(idx) := 16#50000# + to_integer(unsigned(recdata(0 to 15)));
                  idx := idx+1;
                  len := len-2;
                  recdata(0 to recdata'length-16-1) := recdata(16 to recdata'length-1);
                end loop;
                if len > 0 then
                  memdata0(idx) := 16#40000# + to_integer(unsigned(recdata(0 to 15)));
                end if;
              end if;
            end if;
          end if;
        end if;
      end loop;
    end load_srec;

    variable vmr: moderegs;
    type bankstate is record
      openrow: integer;
      opentime: time;
      closetime: time;
      writetime: time;
      readtime: time;
      autopch: integer;
      pchpush: boolean;
    end record;
    type bankstate_arr is array(natural range <>) of bankstate;
    variable banks: bankstate_arr(7 downto 0) := (others => (-1, 0 ns, 0 ns, 0 ns, 0 ns, -1, false));
    type int_arr is array(natural range <>) of integer;
    type dataacc is record
      r,w: boolean;
      col: int_arr(0 to 1);
      bank: integer;
      first,wchop: boolean;
    end record;
    type dataacc_arr is array(natural range <>) of dataacc;
    variable accpipe: dataacc_arr(0 to 25);
    variable cmd: std_logic_vector(2 downto 0);
    variable bank: integer;
    variable colv: unsigned(a'high-2 downto 0);
    variable alow: unsigned(2 downto 0);
    variable col: integer;
    variable prev_re, re: time;
    variable blen, wblen: integer;
    variable lastref: time := 0 ns;
    variable i, al, cl, cwl, wrap: integer;
    variable b: boolean;
    variable mrscount: integer := 100;
    variable mrstime: time;
    variable loaded: boolean := false;
    variable cold: coldata;

    procedure checktime(got, exp: time; gt: boolean; req: string) is
    begin
      assert (got + deltat > exp and gt) or (got-deltat < exp and not gt)
        report (req & " violation, got: " & tost(got/(1 ps)) & " ps, exp: " & tost(exp/(1 ps)) & "ps")
        severity warning;
    end checktime;
  begin
    if rising_edge(ck) and resetn='1' then
      -- Update pipe regs
      prev_re := re;
      re := now;
      accpipe(1 to accpipe'high) := accpipe(0 to accpipe'high-1);
      accpipe(0).r:=false; accpipe(0).w:=false; accpipe(0).first:=false;
      -- Parse MR fields
      cmd := rasn & casn & wen;
      if is_x(vmr.caslat) then cl:=0; else cl:=to_integer(unsigned(vmr.caslat(3 downto 1)))+4; end if;
      if cl<5 or cl>11 then cl:=0; end if;
      case vmr.al is
        when "00" => al:=0;
        when "01" => al:=cl-1;
        when "10" => al:=cl-2;
        when others => al:=-1;
      end case;
      if is_x(vmr.cwl) then cwl:=0; else cwl:=to_integer(unsigned(vmr.cwl))+5; end if;
      if cwl>8 then cwl:=0; end if;
      if is_x(vmr.wr) then wrap:=0; else wrap:=to_integer(unsigned(vmr.wr))+4; end if;
      if wrap<5 or wrap>12 then wrap:=0; end if;
      -- Checks for all-bank commands
      mrscount := mrscount+1;
      assert (mrscount >= tMRD_ck) or (cke='1' and (csn='1' or cmd="111"))
        report "tMRD violation!" severity warning;
      assert (mrscount > tMOD_ck and now > mrstime+tMOD_t-deltat) or
        (cke='1' and (csn='1' or cmd="111" or cmd="000"))
        report "tMOD violation!" severity warning;
      if cke='1' and csn='0' and cmd/="111" then
        checktime(now-lastref, tRFC(density), true, "tRFC");
      end if;
      if vmr.mpr='1' then
        assert cke='0' or csn='1' or cmd="111" or cmd="101"
          report "Command other than read in MPR mode!" severity warning;
        for x in 7 downto 0 loop
          assert banks(x).openrow<0
            report "Row opened in MPR mode!" severity warning;
        end loop;
      end if;
      -- Main command handler
      if cke='1' and csn='0' then
        case cmd is
          when "111" =>                   -- NOP

          when "011" =>                   -- RAS
            assert initdone report "Opening row before init sequence done!" severity warning;
            bank := to_integer(unsigned(ba));
            assert banks(bank).openrow < 0
              report "Row already open" severity warning;
            checktime(now-banks(bank).closetime, tRP(speedbin), true, "tRP");
            for x in 0 to 7 loop
              checktime(now-banks(x).opentime, tRRD(re-prev_re, speedbin), true, "tRRD");
            end loop;
            banks(bank).openrow := to_integer(unsigned(a(rowbits-1 downto 0)));
            banks(bank).opentime := now;

          when "101" | "100" =>                   -- Read/Write
            bank := to_integer(unsigned(ba));
            assert banks(bank).openrow >= 0 or vmr.mpr='1'
              report "Row not open" severity error;
            checktime(now-banks(bank).opentime+al*(re-prev_re), tRCD(speedbin), true, "tRCD");
            for x in 0 to 3 loop
              assert not accpipe(x).r and not accpipe(x).w;
            end loop;
            if cmd(0)='1' then accpipe(3).r:=true; else accpipe(3).w:=true; end if;
            colv := unsigned(std_logic_vector'(a(a'high downto 13) & a(11) & a(9 downto 0)));
            wblen := 8;
            case vmr.blen is
              when "00" => blen := 8;
              when "01" => if a(12)='1' then blen:=8; else blen:=4; end if;
              when "11" => blen := 4; wblen:=4;
              when others => assert false report "Invalid burst length setting in MR!" severity error;
            end case;
            alow := unsigned(a(2 downto 0));
            if cmd(0)='0' then
              alow(1 downto 0) := "00";
              if blen=8 then alow(2):='0'; end if;
            end if;
            for x in 0 to blen-1 loop
              accpipe(3-x/2).bank := bank;
              if cmd(0)='1' then accpipe(3-x/2).r:=true; else accpipe(3-x/2).w:=true; end if;
              if vmr.rbt='0' then -- Sequential
                colv(log2(blen)-1 downto 0) := alow(log2(blen)-1 downto 0) + x;
              else               -- Interleaved
                colv(log2(blen)-1 downto 0) := alow(log2(blen)-1 downto 0) xor to_unsigned(x,log2(blen));
              end if;
              col := banks(bank).openrow * (2**colbits) + to_integer(colv(colbits-1 downto 0));
              accpipe(3-x/2).col(x mod 2) := col;
              accpipe(3-x/2).wchop := (blen<wblen);
            end loop;
            accpipe(3).first := true;
            -- Auto precharge
            if a(10)='1' then
              if cmd(0)='1' then
                banks(bank).autopch := al+tRTP_ck;
              else
                banks(bank).autopch := al+cwl+wblen/2+wrap;
              end if;
              banks(bank).pchpush := true;
            end if;

          when "110" =>                   -- ZQInit
            for x in 0 to 7 loop
              checktime(now-banks(x).closetime, tRP(speedbin), true, "tRP");
            end loop;
            for x in 3+cl+al downto 0 loop
              assert not accpipe(x).r severity warning;
            end loop;
            for x in 4+cwl+al downto 0 loop
              assert not accpipe(x).w severity warning;
            end loop;
            -- Currently does not check TZQCoper/TZQCs


          when "010" =>                   -- Precharge
            if a(10)='0' then bank := to_integer(unsigned(ba)); else bank:=0; end if;
            for x in 6+cwl+al downto 0 loop
              assert ( (not ((accpipe(x).r and x<=3+al) or accpipe(x).w)) or
                       (a(10)='0' and accpipe(x).bank/=bank) )
                report "Precharging bank with access in progress" severity warning;
            end loop;
            for x in 0 to 7 loop
              if a(10)='1' or ba=std_logic_vector(to_unsigned(x,3)) then
                assert banks(x).autopch<0
                  report "Precharging bank that is auto-precharged!" severity note;
                assert a(10)='1' or banks(x).openrow >= 0
                  report "Precharging single bank that is in idle state!" severity note;
                banks(x).autopch := 0;  -- Handled below case statement
                banks(x).pchpush := false;
              end if;
            end loop;


          when "001" =>                   -- Auto refresh
            for x in 0 to 7 loop
              assert banks(x).openrow < 0
                report "Bank in wrong state for auto refresh!" severity warning;
              checktime(now-banks(x).closetime, tRP(speedbin), true, "tRP");
            end loop;
            lastref := now;


          when "000" =>                   -- MRS
            for x in 0 to 7 loop
              checktime(now-banks(x).closetime, tRP(speedbin), true, "tRP");
            end loop;
            bank := to_integer(unsigned(ba));
            case bank is
              when 0 =>
                vmr.ppd := a(12);
                vmr.wr := a(11 downto 9);
                vmr.dllres := a(8);
                vmr.tm := a(7);
                vmr.caslat := a(6 downto 4) & a(2);
                vmr.rbt := a(3);
                vmr.blen := a(1 downto 0);
              when 1 =>
                vmr.qoff := a(12);
                vmr.tdqsen := a(11);
                vmr.level := a(7);
                vmr.al := a(4 downto 3);
                vmr.rtt_nom := a(9) & a(6) & a(2);
                vmr.dic := a(5) & a(1);
                vmr.dlldis := a(0);
              when 2 =>
                vmr.rtt_wr := a(10 downto 9);
                vmr.srt := a(7);
                vmr.asr := a(6);
                vmr.cwl := a(5 downto 3);
                vmr.pasr := a(2 downto 0);
              when 3 =>
                vmr.mpr := a(2);
                vmr.mprloc := a(1 downto 0);
              when others =>
                assert false report ("MRS to invalid bank addr: " & std_logic'image(ba(1)) & std_logic'image(ba(0))) severity warning;
            end case;
            mrscount := 0;
            mrstime := now;

          when others =>
            assert false report ("Invalid command: " & std_logic'image(rasn) & std_logic'image(casn) & std_logic'image(wen)) severity warning;
        end case;
      end if;

      -- Manual or auto precharge handling
      for x in 0 to 7 loop
        if banks(x).autopch=0 then
          if banks(x).pchpush and
            ((now-banks(x).readtime-deltat) < tRTP_t or
             (now-banks(x).opentime-deltat) < tRAS(speedbin)) then
            -- Auto delay auto-precharge to satisfy tRTP_t
            -- NOTE: According to Micron's datasheets, their DDR3 memories
            -- automatically hold off the auto precharge so that also tRAS is satisfied,
            -- and the MIG controller seems to depend on this. It is not clear in the
            -- JEDEC standard (rev F) whether this is guaranteed behavior for all DDR3
            -- RAMs, but we emulate that behavior here.
            banks(x).autopch := banks(x).autopch+1;
          else
            checktime(now-banks(x).writetime, tWR, true, "tWR");
            checktime(now-banks(x).opentime, tRAS(speedbin), true, "tRAS");
            checktime(now-banks(x).readtime, tRTP(re-prev_re), true, "tRTP");
            banks(x).openrow := -1;
            banks(x).closetime := now;
          end if;
        end if;
        if banks(x).autopch >= 0 then
          banks(x).autopch := banks(x).autopch - 1;
        end if;
      end loop;

      -- Read/write management
      if not loaded and lddelay < now and (ldguard=0 or doload='1') then
        load_srec;
        loaded := true;
      end if;
      if accpipe(2+cl+al).r then
        assert cl>1 report "Incorrect CL setting!" severity warning;
        read_en <= true;
        -- print("Reading from col " & tost(accpipe(2+i).col(0)) & " and " & tost(accpipe(2+i).col(1)));
        -- col0 <= accpipe(2+i).col(0); col1 <= accpipe(2+i).col(1);
        if vmr.mpr='1' then
          assert vmr.mprloc="00" report "Read from undefined MPR!" severity warning;
          read_data <= (others => '0');
          for x in width/8-1 downto 0 loop
            read_data(x*8) <= '1';
          end loop;
        else
          read_data <= memdata_get(accpipe(2+cl+al).bank, accpipe(2+cl+al).col(0)) &
                       memdata_get(accpipe(2+cl+al).bank, accpipe(2+cl+al).col(1));
        end if;
      else
        read_en <= false;
      end if;
      if accpipe(3+al).r and accpipe(3+al).first then
        banks(accpipe(3+al).bank).readtime := now;
      end if;
      write_en <= accpipe(2+cwl+al).w or accpipe(3+cwl+al).w;
      if accpipe(4+cwl+al).w then
        assert not is_x(write_mask) report "Write error!";
        for x in 0 to 1 loop
          cold := memdata_get(accpipe(4+cwl+al).bank, accpipe(4+cwl+al).col(x));
          for b in width/8-1 downto 0 loop
            if write_mask((1-x)*width/8+b)='0' then
              cold(8*b+7 downto 8*b) :=
                write_data( (1-x)*width+b*8+7 downto (1-x)*width+b*8);
            end if;
          end loop;
          memdata_set(accpipe(4+cwl+al).bank, accpipe(4+cwl+al).col(x), cold);
        end loop;
        banks(accpipe(4+cwl+al).bank).writetime := now;
      end if;
      if accpipe(6+cwl+al).w and accpipe(6+cwl+al).wchop then
        banks(accpipe(6+cwl+al).bank).writetime := now;
      end if;
      dqscal_en <= (vmr.level='1');
    elsif resetn='0' then
      for x in banks'range loop
        banks(x).openrow := -1;
      end loop;
    end if;
    mr <= vmr;
  end process;

  -----------------------------------------------------------------------------
  -- DQS/DQ handling and data sampling process
  -----------------------------------------------------------------------------
  dqproc: process
    variable rdata: std_logic_vector(2*width-1 downto 0);
    variable hdata: std_logic_vector(width-1 downto 0);
    variable hmask: std_logic_vector(width/8-1 downto 0);
    variable prevdqs: std_logic_vector(width/8-1 downto 0);
  begin
    dq <= (others => 'Z');
    dqs <= (others => 'Z');
    dqsn <= (others => 'Z');
    wait until read_en or write_en or dqscal_en;
    assert not (read_en and write_en);
    if dqscal_en then
      while dqscal_en loop
        prevdqs := dqs;
        wait on dqs,dqscal_en;
        for x in dqs'range loop
          if dqs(x)='1' and prevdqs(x)='0' then
            dq(8*x+7 downto 8*x) <= "0000000" & ck;
          end if;
        end loop;
      end loop;
    elsif read_en then
      dqs <= (others => '0');
      dqsn <= (others => '1');
      wait until falling_edge(ck);
      while read_en loop
        rdata := read_data;
        wait until rising_edge(ck);
        dqs <= (others => '1');
        dqsn <= (others => '0');
        dq <= rdata(2*width-1 downto width);
        wait until falling_edge(ck);
        dqs <= (others => '0');
        dqsn <= (others => '1');
        dq <= rdata(width-1 downto 0);
      end loop;
      wait until rising_edge(ck);
    else
      wait until falling_edge(ck);
      while write_en loop
        prevdqs := to_X01(dqs);
        wait until to_X01(dqs) /= prevdqs or not write_en or rising_edge(ck);
        if rising_edge(ck) then
          write_data <= (others => 'X');
          write_mask <= (others => 'X');
        end if;
        for x in dqs'range loop
          if prevdqs(x)='0' and to_X01(dqs(x))='1' then
            hdata(8*x+7 downto 8*x) := dq(8*x+7 downto 8*x);
            hmask(x) := dm(x);
          elsif prevdqs(x)='1' and to_X01(dqs(x))='0' then
            write_data(width+8*x+7 downto width+8*x) <= hdata(8*x+7 downto 8*x);
            write_data(8*x+7 downto 8*x) <= dq(8*x+7 downto 8*x);
            write_mask(width/8+x) <= hmask(x);
            write_mask(x) <= dm(x);
          end if;
        end loop;
      end loop;
    end if;
  end process;

end;

-- pragma translate_on

