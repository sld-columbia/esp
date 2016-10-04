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
-- Entity:      ddr2ram
-- File:        ddr2ram.vhd
-- Author:      Magnus Hjorth, Aeroflex Gaisler
-- Description: Generic simulation model of DDR2 SDRAM (JESD79-2C)
------------------------------------------------------------------------------

--pragma translate_off

use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdio.hread;
use work.stdlib.all;

entity ddr2ram is
  generic (
    width: integer := 32;
    abits: integer range 13 to 16 := 13;
    babits: integer range 2 to 3 := 3;
    colbits: integer range 9 to 11 := 9;
    rowbits: integer range 1 to 16 := 13;
    implbanks: integer range 1 to 8 := 1;
    swap : integer := 0; -- byte swap during srec load
    fname: string;
    lddelay: time := (0 ns);
    ldguard: integer range 0 to 1 := 0;  -- 1: wait for doload input before
                                         -- loading RAM
    -- Speed bins: 0:DDR2-400C,1:400B,2:533C,3:533B,4:667D,5:667C,6:800E,7:800D,8:800C
    -- 9:800+ (MT47H-25E)
    speedbin: integer range 0 to 9 := 0;
    density: integer range 1 to 5 := 3;  -- 1:256M 2:512M 3:1G 4:2G 5:4G bits/chip
    pagesize: integer range 1 to 2 := 1  -- 1K/2K page size (controls tRRD)
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
    ba: in std_logic_vector(babits-1 downto 0);
    a: in std_logic_vector(abits-1 downto 0);
    dq: inout std_logic_vector(width-1 downto 0);
    dqs: inout std_logic_vector(width/8-1 downto 0);
    dqsn: inout std_logic_vector(width/8-1 downto 0);
    doload: in std_ulogic := '1'
    );
end;

architecture sim of ddr2ram is

  type moderegs is record
    -- Mode register (0)
    pd: std_ulogic;
    wr: std_logic_vector(2 downto 0);
    dllres: std_ulogic;
    tm: std_ulogic;
    caslat: std_logic_vector(2 downto 0);
    bt: std_ulogic;
    blen: std_logic_vector(2 downto 0);
    -- Extended mode register 1
    qoff: std_ulogic;
    rdqsen: std_ulogic;
    dqsndis: std_ulogic;
    ocdprog: std_logic_vector(2 downto 0);
    al: std_logic_vector(2 downto 0);
    rtt: std_logic_vector(1 downto 0);
    ds: std_ulogic;
    dlldis: std_ulogic;
    -- Extended mode register 2
    srf: std_ulogic;
    dccen: std_ulogic;
    pasr: std_logic_vector(2 downto 0);
    -- Extended mode register 3
    emr3: std_logic_vector(abits-1 downto 0);
  end record;

  -- Mode registers as signal, useful for debugging
  signal mr: moderegs;

  -- Handshaking between command and DQ/DQS processes
  signal read_en, write_en: boolean := false;
  signal read_data, write_data: std_logic_vector(2*width-1 downto 0);
  signal write_mask: std_logic_vector(width/4-1 downto 0);

  signal initdone: boolean := false;

  -- Small delta-t to adjust calculations for jitter tol.
  constant deltat: time := 50 ps;

  -- Timing parameters
  constant tWR: time := 15 ns;
  constant tMRD_ck: integer := 2;
  constant tRTP: time := 7.5 ns;
  type timetab is array (0 to 9) of time;
  --                          400C   400B   533C   533B      667D   667C   800E   800D     800C   MT-2.5E
  constant tRAS : timetab := (45 ns, 40 ns, 45 ns, 45    ns, 45 ns, 45 ns, 45 ns, 45   ns, 45 ns, 40 ns);
  constant tRP :  timetab := (20 ns, 15 ns, 15 ns, 11.25 ns, 15 ns, 12 ns, 15 ns, 12.5 ns, 10 ns, 12.5 ns);
  constant tRCD:  timetab := tRP;

  type timetab2 is array(1 to 5) of time;
  constant tRFC: timetab2 := (75 ns, 105 ns, 127.5 ns, 195 ns, 327.5 ns);

  type timetab3 is array(1 to 2) of time;
  constant tRRD: timetab3 := (7.5 ns, 10 ns);

begin

  -----------------------------------------------------------------------------
  -- Init sequence checker
  -----------------------------------------------------------------------------
  initp: process

    variable cyctr: integer := 0;

    procedure checkcmd(crasn,ccasn,cwen: std_ulogic;
                       cba: std_logic_vector(1 downto 0);
                       ca: std_logic_vector(15 downto 0)) is
      variable amatch: boolean;
    begin
      wait until rising_edge(ck);
      cyctr := cyctr+1;
      while cke='1' and (csn='1' or (rasn='1' and casn='1' and wen='1')) loop
        wait until rising_edge(ck);
        cyctr := cyctr+1;
      end loop;
      amatch := true;
      for x in a'range loop
        if ca(x)/='-' and ca(x)/=a(x) then amatch:=false; end if;
      end loop;
      assert cke='1' and csn='0' and rasn=crasn and casn=ccasn and wen=cwen and
        (cba="--" or cba=ba(1 downto 0)) and amatch
        report "Wrong command during init sequence" severity warning;
    end checkcmd;

    variable t: time;
  begin
    initdone <= false;
    -- Allow cke to be X or U for a while during sim start
    if is_x(cke) then
      wait until not is_x(cke);
    end if;
    assert cke='0' report "CKE not deasserted on power-up" severity warning;
    wait until cke/='0' for 200 us;
    assert cke='0' report "CKE raised with less than 200 us init delay" severity warning;
    wait until cke/='0' and rising_edge(ck);
    assert cke='1' and (csn='1' or (rasn='1' and casn='1' and wen='1'));
    t := now;
    -- Precharge all
    checkcmd('0','1','0',"--","-----1----------");
    assert (now-t) > 400 ns report "Less than 400 ns wait period after CKE high!" severity warning;
    -- EMRS EMR2
    checkcmd('0','0','0',"10","----------------");
    -- EMRS EMR3
    checkcmd('0','0','0',"11","----------------");
    -- EMRS enable DLL
    checkcmd('0','0','0',"01","000---000-------");
    -- MRS reset DLL
    checkcmd('0','0','0',"00","000----1--------");
    cyctr := 0;
      -- Precharge all
    checkcmd('0','1','0',"--","-----1----------");
    -- 2 x auto refresh
    checkcmd('0','0','1',"--","----------------");
    checkcmd('0','0','1',"--","----------------");
    -- MRS !reset DLL
    checkcmd('0','0','0',"00","-------0--------");
    -- EMRS EMR1 OCD default, EMRS EMR1 exit OCD cal
    -- (assume OCD impedance adjust not performed)
    checkcmd('0','0','0',"01","------111-------");
    assert cyctr >= 200 report "Less than 200 cycles (" & tost(cyctr) & ") between DLL reset and OCD cal" severity warning;
    checkcmd('0','0','0',"01","------000-------");
    initdone <= true;
    wait;
  end process;

  -----------------------------------------------------------------------------
  -- Command state machine
  -----------------------------------------------------------------------------
  cmdp: process(ck)
    subtype coldata is std_logic_vector(width-1 downto 0);
    type coldata_arr is array(0 to implbanks*(2**(colbits+rowbits))-1) of coldata;
    variable memdata: coldata_arr;

    procedure load_srec is
      file TCF : text open read_mode is fname;
      variable L1: line;
      variable CH : character;
      variable rectype : std_logic_vector(3 downto 0);
      variable recaddr : std_logic_vector(31 downto 0);
      variable reclen  : std_logic_vector(7 downto 0);
      variable recdata : std_logic_vector(0 to 16*8-1);
      variable recdatatemp : std_logic_vector(0 to 63);
      variable col, coloffs, len: integer;
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
              if swap=1 then  -- byte swap during srec load
                for i in 0 to 7 loop
                  recdatatemp(0 to 7) := recdata(i*16 to i*16+7);
                  recdata(i*16 to i*16+7) := recdata(i*16+8 to i*16+15);
                  recdata(i*16+8 to i*16+15) := recdatatemp(0 to 7);
                end loop;
              elsif swap = 2 then
                recaddr(4)          := not recaddr(4);
                recdatatemp         := recdata(0 to 63);
                recdata(0 to 63)    := recdata(64 to 127);
                recdata(64 to 127)  := recdatatemp;
              end if;
              col := to_integer(unsigned(recaddr(log2(width/8)+rowbits+colbits+1 downto log2(width/8))));
              coloffs := 8*to_integer(unsigned(recaddr(log2(width/8)-1 downto 0)));
              while len > width/8 loop
                assert coloffs=0;
                memdata(col) := recdata(0 to width-1);
                col := col+1;
                len := len-width/8;
                recdata(0 to recdata'length-width-1) := recdata(width to recdata'length-1);
              end loop;
              memdata(col)(width-1-coloffs downto width-coloffs-len*8) := recdata(0 to len*8-1);
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
    end record;
    type dataacc_arr is array(natural range <>) of dataacc;
    variable accpipe: dataacc_arr(0 to 9);
    variable cmd: std_logic_vector(2 downto 0);
    variable bank: integer;
    variable colv: unsigned(a'high-1 downto 0);
    variable alow: unsigned(2 downto 0);
    variable col: integer;
    variable prev_re, re: time;
    variable blen: integer;
    variable lastref: time := 0 ns;
    variable i, al, cl, wrap: integer;
    variable b: boolean;
    variable mrscount: integer := 0;
    variable loaded: boolean := false;

    procedure checktime(got, exp: time; gt: boolean; req: string) is
    begin
      assert (got + deltat > exp and gt) or (got-deltat < exp and not gt)
        report (req & " violation, got: " & tost(got/(1 ps)) & " ps, exp: " & tost(exp/(1 ps)) & "ps")
        severity warning;
    end checktime;
  begin
    if rising_edge(ck) then
      -- Update pipe regs
      prev_re := re;
      re := now;
      accpipe(1 to accpipe'high) := accpipe(0 to accpipe'high-1);
      accpipe(0).r:=false; accpipe(0).w:=false;
      -- Parse MR fields
      cmd := rasn & casn & wen;
      if is_x(vmr.caslat) then cl:=0; else cl:=to_integer(unsigned(vmr.caslat)); end if;
      if cl<2 or cl>6 then cl:=0; end if;
      if is_x(vmr.al) then al:=0; else al:=to_integer(unsigned(vmr.al)); end if;
      if al>5 then al:=0; end if;
      if is_x(vmr.wr) then wrap:=0; else wrap:=1+to_integer(unsigned(vmr.wr)); end if;
      if wrap<2 or wrap>6 then wrap:=0; end if;
      -- Checks for all-bank commands
      if mrscount > 0 then
        mrscount := mrscount-1;
        assert cke='1' and (csn='1' or cmd="111") report "tMRS violation!" severity warning;
      end if;
      if cke='1' and csn='0' and cmd/="111" then
        checktime(now-lastref, tRFC(density), true, "tRFC");
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
              checktime(now-banks(x).opentime, tRRD(pagesize), true, "tRRD");
            end loop;
            banks(bank).openrow := to_integer(unsigned(a(rowbits-1 downto 0)));
            banks(bank).opentime := now;

          when "101" | "100" =>                   -- Read/Write
            bank := to_integer(unsigned(ba));
            -- Get additive latency
            i := to_integer(unsigned(vmr.al));
            assert banks(bank).openrow >= 0
              report "Row not open" severity error;
            checktime(now-banks(bank).opentime+al*(re-prev_re), tRCD(speedbin), true, "tRCD");
            -- Allow interrupting read in case of middle of BL8 burst only
            if (accpipe(3).r and accpipe(2).r and
                not (accpipe(1).r or accpipe(1).w or accpipe(0).r or accpipe(0).w)) then
              accpipe(3).r := false;
              accpipe(2).r := false;
            end if;
            for x in 0 to 3 loop
              assert not accpipe(x).r and not accpipe(x).w;
            end loop;
            if cmd(0)='1' then accpipe(3).r:=true; else accpipe(3).w:=true; end if;
            colv := unsigned(std_logic_vector'(a(a'high downto 11) & a(9 downto 0)));
            case vmr.blen is
              when "010" => blen := 4;
              when "011" => blen := 8;
              when others => assert false report "Invalid burst length setting in MR!" severity error;
            end case;
            alow := unsigned(a(2 downto 0));
            for x in 0 to blen-1 loop
              accpipe(3-x/2).bank := bank;
              if cmd(0)='1' then accpipe(3-x/2).r:=true; else accpipe(3-x/2).w:=true; end if;
              if vmr.bt='0' then -- Sequential
                colv(log2(blen)-1 downto 0) := alow(log2(blen)-1 downto 0) + x;
              else               -- Interleaved
                colv(log2(blen)-1 downto 0) := alow(log2(blen)-1 downto 0) xor to_unsigned(x,log2(blen));
              end if;
              col := to_integer(unsigned(ba))*(2**(colbits+rowbits)) +
                     banks(bank).openrow * (2**colbits) + to_integer(colv(colbits-1 downto 0));
              accpipe(3-x/2).col(x mod 2) := col;
            end loop;
            -- Auto precharge
            if a(10)='1' then
              if cmd(0)='1' then
                banks(bank).autopch := al+blen/2;
              else
                banks(bank).autopch := cl+al-1+blen/2+wrap;
              end if;
              banks(bank).pchpush := true;
            end if;

          when "110" =>                   -- Reserved (Burst terminate on DDR1)
            assert false report "Invalid command RAS=1 CAS=1 WE=0" severity warning;

          when "010" =>                   -- Precharge
            if a(10)='0' then bank := to_integer(unsigned(ba)); else bank:=0; end if;
            for x in 3 downto 0 loop    -- FIXME potential window which isn't checked if AL>0
              assert (not (accpipe(x).r or accpipe(x).w)) or (a(10)='0' and bank/=accpipe(x).bank)
                report "Precharging bank with access in progress"
                severity warning;
            end loop;
            for x in 0 to (2**babits)-1 loop
              if a(10)='1' or ba=std_logic_vector(to_unsigned(x,babits)) then
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
                vmr.pd := a(12);
                vmr.wr := a(11 downto 9);
                vmr.dllres := a(8);
                vmr.tm := a(7);
                vmr.caslat := a(6 downto 4);
                vmr.bt := a(3);
                vmr.blen := a(2 downto 0);
              when 1 =>
                vmr.qoff := a(12);
                vmr.rdqsen := a(11);
                vmr.dqsndis := a(10);
                vmr.ocdprog := a(9 downto 7);
                vmr.al := a(5 downto 3);
                vmr.rtt := a(6) & a(2);
                vmr.ds := a(1);
                vmr.dlldis := a(0);
              when 2 =>
                vmr.srf := a(7);
                vmr.dccen := a(3);
                vmr.pasr := a(2 downto 0);
              when 3 =>
                vmr.emr3 := a;
              when others =>
                assert false report ("MRS to invalid bank addr: " & std_logic'image(ba(1)) & std_logic'image(ba(0))) severity warning;
            end case;
            mrscount := tMRD_ck-1;

          when others =>
            assert false report ("Invalid command: " & std_logic'image(rasn) & std_logic'image(casn) & std_logic'image(wen)) severity warning;
        end case;
      end if;

      -- Manual or auto precharge handling
      for x in 0 to 7 loop
        if banks(x).autopch=0 then
          if banks(x).pchpush and (now-banks(x).opentime-deltat) < tRAS(speedbin) then
            -- Auto delay auto-precharge to satisfy tRAS/tRC
            banks(x).autopch := banks(x).autopch+1;
          elsif banks(x).pchpush and (now-banks(x).readtime-deltat) < tRTP then
            -- Auto delay auto-precharge to satisfy tRTP
            banks(x).autopch := banks(x).autopch+1;
          else
            checktime(now-banks(x).writetime, tWR, true, "tWR");
            checktime(now-banks(x).opentime, tRAS(speedbin), true, "tRAS");
            checktime(now-banks(x).readtime, tRTP, true, "tRTP");
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
        read_data <= memdata(accpipe(2+cl+al).col(0)) & memdata(accpipe(2+cl+al).col(1));
      else
        read_en <= false;
      end if;
      -- tRTP is counted from read command + AL for BL4, read command + AL + 2
      -- for BL8. This check covers both cases by writing readtime on the next-to-last
      -- transfer.
      if accpipe(3+al).r and accpipe(2+al).r and accpipe(3+al).bank=accpipe(2+al).bank then
        banks(accpipe(2+al).bank).readtime := now;
      end if;
      write_en <= accpipe(1+cl+al).w or accpipe(2+cl+al).w;
      if accpipe(3+cl+al).w then
        assert not is_x(write_mask) report "Write error!";
        for x in 0 to 1 loop
          for b in width/8-1 downto 0 loop
            if write_mask((1-x)*width/8+b)='0' then
              memdata(accpipe(3+cl+al).col(x))(8*b+7 downto 8*b) :=
                write_data( (1-x)*width+b*8+7 downto (1-x)*width+b*8);
            end if;
          end loop;
        end loop;
        banks(accpipe(3+cl+al).bank).writetime := now;
      end if;
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
    wait until read_en or write_en;
    assert not (read_en and write_en);
    if read_en then
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
      assert (to_X01(dqs)=(dqs'range => '0')) or ((to_X01(dqs)=(dqs'range => '1')) and (to_X01(dm)=(dm'range => '1') or dm=(dm'range => 'Z')));

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

