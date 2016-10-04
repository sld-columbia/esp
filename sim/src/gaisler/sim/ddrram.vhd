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
-- Entity:      ddrram
-- File:        ddrram.vhd
-- Author:      Magnus Hjorth, Aeroflex Gaisler
-- Description: Generic simulation model of DDR SDRAM (JESD79E)
------------------------------------------------------------------------------

--pragma translate_off

use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdio.hread;
use work.stdlib.all;

entity ddrram is
  generic (
    width: integer := 32;
    abits: integer range 12 to 14 := 12;
    colbits: integer range 8 to 13 := 8;
    rowbits: integer range 1 to 14 := 12;
    implbanks: integer range 1 to 4 := 1;
    fname: string;
    lddelay: time := (0 ns);
    speedbin: integer range 0 to 5 := 0;     -- 0:DDR200,1:266,2:333,3:400C,4:400B,5:400A
    density: integer range 0 to 3 := 0;  -- 0:128Mbit 1:256Mbit 2:512Mbit 3:1Gbit / chip
    igndqs: integer range 0 to 1 := 0
    );
  port (
    ck: in std_ulogic;
    cke: in std_ulogic;
    csn: in std_ulogic;
    rasn: in std_ulogic;
    casn: in std_ulogic;
    wen: in std_ulogic;
    dm: in std_logic_vector(width/8-1 downto 0);
    ba: in std_logic_vector(1 downto 0);
    a: in std_logic_vector(abits-1 downto 0);
    dq: inout std_logic_vector(width-1 downto 0);
    dqs: inout std_logic_vector(width/8-1 downto 0)
    );
end;

architecture sim of ddrram is

  type moderegs is record
    -- Mode register (0)
    opmode: std_logic_vector(6 downto 0);
    caslat: std_logic_vector(2 downto 0);
    bt: std_ulogic;
    blen: std_logic_vector(2 downto 0);
    -- Extended mode register (1)
    opmode1: std_logic_vector(10 downto 0);
    res1: std_ulogic;
    ds: std_ulogic;
    dlldis: std_ulogic;
  end record;

  -- Mode registers as signal, useful for debugging
  signal mr: moderegs;

  -- Handshaking between command and DQ/DQS processes
  signal read_en, write_en: boolean := false;
  signal hcmode: boolean := false;      -- Shift DQS/read data one cycle for CL=1.5/2.5
  signal hcread_en: boolean := false;   -- One cycle earlier for half-cycle mode read preamble gen
  signal read_data, write_data: std_logic_vector(2*width-1 downto 0);
  signal write_mask: std_logic_vector(width/4-1 downto 0);

  signal initdone: boolean := false;

  -- Small delta-t to adjust calculations for jitter tol.
  constant deltat: time := 50 ps;
  -- Timing parameters
  constant tWR: time := 15 ns;
  constant tMRD_ck: integer := 2;
  type timetab is array (0 to 5) of time;
  constant tRAS : timetab := (50 ns, 45 ns, 42 ns, 40 ns, 40 ns, 40 ns);
  constant tRP :  timetab := (20 ns, 20 ns, 18 ns, 18 ns, 15 ns, 15 ns);
  constant tRCD:  timetab := (20 ns, 20 ns, 18 ns, 18 ns, 15 ns, 15 ns);
  constant tRRD:  timetab := (15 ns, 15 ns, 12 ns, 10 ns, 10 ns, 10 ns);
  constant tRFC_lt1G: timetab := (80 ns, 75 ns, 72 ns, 70 ns, 70 ns, 70 ns);  --Assuming<1Gb
  constant tRFC_mt1G: time := 120 ns;
  function tRFC return time is
  begin
    if density < 3 then return tRFC_lt1G(speedbin);
    else return tRFC_mt1G; end if;
  end tRFC;

begin

  -----------------------------------------------------------------------------
  -- Init sequence checker
  -----------------------------------------------------------------------------
  initp: process

    variable cyctr : integer := 0;

    procedure checkcmd(crasn,ccasn,cwen: std_ulogic;
                       cba: std_logic_vector(1 downto 0);
                       a10,a8,a0: std_ulogic) is
    begin
      wait until rising_edge(ck);
      cyctr := cyctr+1;
      while cke='1' and (csn='1' or (rasn='1' and casn='1' and wen='1')) loop
        wait until rising_edge(ck);
        cyctr := cyctr+1;
      end loop;
      assert cke='1' and csn='0' and rasn=crasn and casn=ccasn and wen=cwen and
        (cba="--" or cba=ba) and (a10='-' or a10=a(10)) and (a8='-' or a8=a(8)) and
        (a0='-' or a0=a(0))
        report "Wrong command during init sequence" severity warning;
    end checkcmd;

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
    -- Precharge all
    checkcmd('0','1','0',"--",'1','-','-');
    -- EMRS enable DLL
    checkcmd('0','0','0',"01",'-','-','0');
    -- MRS reset DLL
    checkcmd('0','0','0',"00",'-','1','-');
    cyctr := 0;
    -- 200 cycle NOP
    -- Precharge all
    checkcmd('0','1','0',"--",'1','-','-');
    assert cyctr >= 200
      report "Command issued too quickly after DLL reset" severity warning;
    -- 2 x auto refresh
    checkcmd('0','0','1',"--",'-','-','-');
    checkcmd('0','0','1',"--",'-','-','-');
    -- MRS !reset DLL
    checkcmd('0','0','0',"00",'-','0','-');
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

    variable vmr: moderegs := ((others => '0'), "UUU", 'U', "UUU", (others => '0'), '0', '0', '0');
    type bankstate is record
      openrow: integer;
      opentime: time;
      closetime: time;
      writetime: time;
      autopch: integer;
    end record;
    type bankstate_arr is array(natural range <>) of bankstate;
    variable banks: bankstate_arr(3 downto 0) := (others => (-1, 0 ns, 0 ns, 0 ns, -1));
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
    variable i: integer;
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
      -- Main command handler
      cmd := rasn & casn & wen;
      if mrscount > 0 then
        mrscount := mrscount-1;
        assert cke='1' and (csn='1' or cmd="111") report "tMRS violation!" severity warning;
      end if;
      if cke='1' and csn='0' and cmd/="111" then
        checktime(now-lastref, tRFC, true, "tRFC");
      end if;
      if cke='1' and csn='0' then
        case cmd is
          when "111" =>                   -- NOP

          when "011" =>                   -- RAS
            assert initdone report "Opening row before init sequence done!" severity warning;
            bank := to_integer(unsigned(ba));
            assert banks(bank).openrow < 0
              report "Row already open" severity warning;
            checktime(now-banks(bank).closetime, tRP(speedbin), true, "tRP");
            for x in 0 to 3 loop
              checktime(now-banks(x).opentime, tRRD(speedbin), true, "tRRD");
            end loop;
            banks(bank).openrow := to_integer(unsigned(a(rowbits-1 downto 0)));
            banks(bank).opentime := now;

          when "101" | "100" =>                   -- Read/Write
            bank := to_integer(unsigned(ba));
            assert banks(bank).openrow >= 0
              report "Row not open" severity error;
            checktime(now-banks(bank).opentime, tRCD(speedbin), true, "tRCD");
            for x in 0 to 3 loop
              -- Xilinx V4 MIG controller issues multiple overlapping load commands
              -- during calibration, therefore this assertion is bypassed before
              -- load-delay has passed.
              assert (not accpipe(x).r and not accpipe(x).w) or (now < lddelay);
            end loop;
            if cmd(0)='1' then accpipe(3).r:=true; else accpipe(3).w:=true; end if;
            colv := unsigned(std_logic_vector'(a(a'high downto 11) & a(9 downto 0)));
            case vmr.blen is
              when "001" => blen := 2;
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
                banks(bank).autopch := blen/2;
              else
                banks(bank).autopch := 1+blen/2 + (tWR-deltat+(re-prev_re))/(re-prev_re);
              end if;
            end if;

          when "110" =>                   -- Burst terminate
            assert not accpipe(3).w
              report "Burst terminate on write burst!" severity warning;
            assert banks(accpipe(3).bank).autopch<0
              report "Burst terminate on read with auto-precharge!" severity warning;
            assert accpipe(3).r
              report "Burst terminate with no effect!" severity warning;
            for x in 3 downto 0 loop
              accpipe(x).r := false;
              accpipe(x).w := false;
            end loop;

          when "010" =>                   -- Precharge
            for x in 3 downto 0 loop
              accpipe(x).r := false;
              accpipe(x).w := false;
            end loop;
            for x in 0 to 3 loop
              if a(10)='1' or ba=std_logic_vector(to_unsigned(x,2)) then
                assert banks(x).autopch<0
                  report "Precharging bank that is auto-precharged" severity note;
                assert a(10)='1' or banks(x).openrow>=0
                  report "Precharging single bank that is in idle state" severity note;
                banks(x).autopch := 0;  -- Handled below
              end if;
            end loop;


          when "001" =>                   -- Auto refresh
            for x in 0 to 3 loop
              assert banks(x).openrow < 0
                report "Bank in wrong state for auto refresh!" severity warning;
              checktime(now-banks(x).closetime, tRP(speedbin), true, "tRP");
            end loop;
            lastref := now;


          when "000" =>                   -- MRS
            for x in 0 to 3 loop
              checktime(now-banks(x).closetime, tRP(speedbin), true, "tRP");
            end loop;
            case ba is
              when "00" =>
                vmr.opmode(a'high-7 downto 0) := a(a'high downto 7);
                vmr.caslat := a(6 downto 4);
                vmr.bt := a(3);
                vmr.blen := a(2 downto 0);
              when "01" =>
                vmr.opmode1(a'high-3 downto 0) := a(a'high downto 3);
                vmr.res1 := a(2);
                vmr.ds := a(1);
                vmr.dlldis := a(0);
              when others =>
                assert false report ("MRS to invalid bank addr: " & std_logic'image(ba(1)) & std_logic'image(ba(0))) severity warning;
            end case;
            mrscount := tMRD_ck-1;

          when others =>
            assert false report ("Invalid command: " & std_logic'image(rasn) & std_logic'image(casn) & std_logic'image(wen)) severity warning;
        end case;
      end if;

      -- Manual or auto precharge
      for x in 0 to 3 loop
        if banks(x).autopch=0 then
          checktime(now-banks(x).writetime, tWR, true, "tWR");
          checktime(now-banks(x).opentime, tRAS(speedbin), true, "tRAS");
          banks(x).openrow := -1;
          banks(x).closetime := now;
        end if;
        if banks(x).autopch >= 0 then
          banks(x).autopch := banks(x).autopch - 1;
        end if;
      end loop;

      -- Read/write management
      if not loaded and lddelay < now then
        load_srec;
        loaded := true;
      end if;
      case vmr.caslat is
        when "010" => i := 2; b:=false;  -- CL2
        when "011" => i := 3; b:=false;  -- CL3
        when "101" => i := 2; b:=true;   -- CL1.5
        when "110" => i := 3; b:=true;   -- CL2.5
        when others => i := 1;
      end case;
      hcmode <= b;
      if b then hcread_en <= accpipe(1+i).r; else hcread_en <= false; end if;
      if accpipe(2+i).r then
        assert i>1 report "Incorrect CL setting!" severity warning;
        read_en <= true;
        -- print("Reading from col " & tost(accpipe(2+i).col(0)) & " and " & tost(accpipe(2+i).col(1)));
        -- col0 <= accpipe(2+i).col(0); col1 <= accpipe(2+i).col(1);
        read_data <= memdata(accpipe(2+i).col(0)) & memdata(accpipe(2+i).col(1));
      else
        read_en <= false;
      end if;
      write_en <= accpipe(3).w or accpipe(4).w;
      if accpipe(5).w and write_mask/=(write_mask'range => '1') then
        assert not is_x(write_mask) report "Write error";
        for x in 0 to 1 loop
          for b in width/8-1 downto 0 loop
            if write_mask((1-x)*width/8+b)='0' then
              memdata(accpipe(5).col(x))(8*b+7 downto 8*b) :=
                write_data( (1-x)*width+b*8+7 downto (1-x)*width+b*8);
            end if;
          end loop;
        end loop;
        banks(accpipe(5).bank).writetime := now;
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
    wait until (hcmode and hcread_en) or read_en or write_en;
    assert not ((read_en or hcread_en) and write_en);
    if (read_en or hcread_en) then
      if hcmode then
        wait until falling_edge(ck);
      end if;
      dqs <= (others => '0');
      wait until falling_edge(ck);
      while read_en loop
        rdata := read_data;
        if not hcmode then
          wait until rising_edge(ck);
        end if;
        dqs <= (others => '1');
        dq <= rdata(2*width-1 downto width);
        if hcmode then
          wait until rising_edge(ck);
        else
          wait until falling_edge(ck);
        end if;
        dqs <= (others => '0');
        dq <= rdata(width-1 downto 0);
        if hcmode then
          wait until falling_edge(ck);
        end if;
      end loop;
      if not hcmode then
        wait until rising_edge(ck);
      end if;
    else
      wait until falling_edge(ck);
      assert to_X01(dqs)=(dqs'range => '0') or igndqs/=0;
      while write_en loop
        prevdqs := to_X01(dqs);
        if igndqs /= 0 then
          wait on ck,write_en;
        else
          wait until to_X01(dqs) /= prevdqs or not write_en or rising_edge(ck);
        end if;
        if rising_edge(ck) then
          -- Just to make sure missing DQS is not undetected
          write_data <= (others => 'X');
          write_mask <= (others => 'X');
        end if;
        for x in dqs'range loop
          if (igndqs=0 and prevdqs(x)='0' and to_X01(dqs(x))='1') or (igndqs/=0 and rising_edge(ck)) then
            hdata(8*x+7 downto 8*x) := dq(8*x+7 downto 8*x);
            hmask(x) := dm(x);
          elsif (igndqs=0 and prevdqs(x)='1' and to_X01(dqs(x))='0') or (igndqs/=0 and falling_edge(ck)) then
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

