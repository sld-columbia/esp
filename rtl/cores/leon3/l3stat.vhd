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
-- Entity: 	l3stat
-- File:	l3stat.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Modified:    Jan Andersson - Aeroflex Gaisler
-- Description:	LEON3 statistic counters
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.amba.all;
use work.devices.all;
use work.leon3.all;

entity l3stat is
  generic (
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#fff#;
    ncnt        : integer range 1 to 64 := 4;
    ncpu        : integer := 1;
    nmax        : integer := 0;
    lahben      : integer := 0;
    dsuen       : integer := 0;
    nextev      : integer range 0 to 16 := 0;
    apb2en      : integer := 0;
    pindex2     : integer := 0;
    paddr2      : integer := 0;
    pmask2      : integer := 16#fff#;
    astaten     : integer := 0;
    selreq      : integer := 0;
    clatch      : integer := 0;
    forcer0     : integer range 0 to 1 := 0
    );
  port (
    rstn   : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbsi  : in  ahb_slv_in_type;
    dbgo   : in  l3_debug_out_vector(0 to NCPU-1);
    dsuo   : in  dsu_out_type := dsu_out_none;
    stati  : in  l3stat_in_type := l3stat_in_none;
    apb2i  : in  apb_slv_in_type := apb_slv_in_none;
    apb2o  : out apb_slv_out_type;
    astat  : in  amba_stat_type := amba_stat_none
  );


end;

architecture rtl of l3stat is

constant REVISION : integer := 1 - forcer0;
constant pconfig  : apb_config_type := (
	0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_L3STAT, 0, REVISION, 0),
	1 => apb_iobar(paddr, pmask),
        2 => (others => '0'));
constant pconfig2  : apb_config_type := (
	0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_L3STAT, 0, REVISION, 0),
	1 => apb_iobar(paddr2, pmask2),
        2 => (others => '0'));

constant MAX_CNT : natural := 64 - 32*forcer0; -- Maximum number of counters
constant MADDR   : natural := log2(MAX_CNT) + 2;

function op_len return integer is
begin
  if selreq /= 0 then return 8; end if;
  return 7;
end function op_len;

constant LATCH_CNT : boolean := clatch /= 0;

type cnt_type is record
  cpu  : std_logic_vector(3 downto 0);
  op   : std_logic_vector(op_len-1 downto 0);
  en   : std_logic;
  clr  : std_logic;
  inc  : std_logic;
  cnt  : std_logic_vector(31 downto 0);
  suen : std_logic_vector(1 downto 0);
end record;

type mcnt_type is record
  el   : std_ulogic;
  cd   : std_ulogic;
  max  : std_logic_vector(31 downto 0);
end record;
  
type reg_type is record
  hmaster : std_logic_vector(3 downto 0);
  active  : std_logic;
  latcnt  : std_logic;
  timer   : std_logic_vector(31 downto 0);
end record;

constant cnt_none : cnt_type := ("0000", zero32(op_len-1 downto 0),
                                 '0', '0', '0', zero32, "00");

constant mcnt_none : mcnt_type := ('0', '0', zero32);

type cnt_type_vector is array (natural range <>) of cnt_type;
type mcnt_type_vector is array (natural range <>) of mcnt_type;

function calc_inc(
  cnt    : cnt_type;
  dbgox  : l3_debug_out_vector(0 to 15);
  r      : reg_type;
  dastat : dsu_astat_type;
  ev     : std_logic_vector(15 downto 0);
  esource: l3stat_src_array;
  astat  : amba_stat_type;
  req    : std_logic_vector(15 downto 0);
  sel    : std_logic_vector(15 downto 0)) return std_logic is
variable wbhold, inc, icnt, fcnt, bpmiss, dsumode : std_logic;
variable istat, dstat : l3_cstat_type;
variable cpu : natural range 0 to 15;
variable inst : std_logic_vector(5 downto 0);
variable su : std_logic;
variable op : std_logic_vector(5 downto 0);
begin
  cpu := conv_integer(cnt.cpu); wbhold := dbgox(cpu).wbhold;
  istat := dbgox(cpu).istat; dstat := dbgox(cpu).dstat;
  icnt := dbgox(cpu).icnt; fcnt := dbgox(cpu).fcnt;
  inst := dbgox(cpu).optype;  bpmiss := dbgox(cpu).bpmiss;
  dsumode := dbgox(cpu).dsumode;
  su := dbgox(cpu).su;
  inc := '0';
  op := cnt.op(5 downto 0);
  if selreq = 0 or cnt.op(cnt.op'left) = '0' then
  if (nextev = 0 and dsuen = 0 and astaten = 0) or cnt.op(6) = '0' then
    case op is
      when "000000" => inc := istat.cmiss; 		-- icache miss
      when "000001" => inc := istat.tmiss; 		-- icache tlb miss
      when "000010" => inc := istat.chold; 		-- icache total hold
      when "000011" => inc := istat.mhold; 		-- icache MMU hold
      when "001000" => inc := dstat.cmiss; 
      when "001001" => inc := dstat.tmiss; 
      when "001010" => inc := dstat.chold; 
      when "001011" => inc := dstat.mhold; 
      when "010000" => inc := wbhold;		-- dcache write buffer hold
      when "010001" => inc := icnt;			-- total number of instructions
      when "010010" => inc := icnt and not fcnt;	-- integer instructions
      when "010011" => inc := fcnt;			-- FPU instructions
      when "010100" => inc := bpmiss;		-- branch prediction miss
      when "010101" => inc := not dsumode;		-- total cycles
      when "010111" => 				-- AHB utilization per master
        if lahben /= 0 then
          if (r.active = '1') and (r.hmaster = cnt.cpu) then inc := '1'; end if;
        end if;
      when "011000" => 				-- Total AHB utilization
        if lahben /= 0 then
          if (r.active = '1') then inc := '1'; end if;
        end if;
      when "100010" => 				-- integer branches
        if inst(5 downto 1) = "00010" then inc := icnt; end if;
      when "101000" => 				-- CALL
        if inst(5 downto 4) = "01" then inc := icnt; end if;
      when "110000" => 				-- Normal instructions
        if inst(5 downto 4) = "10" then inc := icnt; end if;
      when "111000" => 				-- load & store
        if inst(5 downto 4) = "11" then inc := icnt; end if;
      when "111001" => 				-- load
        if (inst(5 downto 4) = "11") and ((inst(0) = '0') or inst(1) = '1') then inc := icnt; end if;
      when "111010" => 				-- store
        if (inst(5 downto 4) = "11") and (inst(0) = '1') then inc := icnt; end if;
      when others => null;
    end case;

    case cnt.suen is
      when "01" => if su = '0' then inc := '0'; end if; 
      when "10" => if su = '1' then inc := '0'; end if; 
      when others      => null; 
    end case;
  elsif dsuen /= 0 and cnt.op(6 downto 5) = "10" then
    case op(4 downto 0) is
      when "00000" => inc := dastat.idle;
      when "00001" => inc := dastat.busy;
      when "00010" => inc := dastat.nseq;
      when "00011" => inc := dastat.seq;
      when "00100" => inc := dastat.read;
      when "00101" => inc := dastat.write;
      when "00110" => inc := dastat.hsize(0);
      when "00111" => inc := dastat.hsize(1);
      when "01000" => inc := dastat.hsize(2);
      when "01001" => inc := dastat.hsize(3);
      when "01010" => inc := dastat.hsize(4);
      when "01011" => inc := dastat.hsize(5);
      when "01100" => inc := dastat.ws;
      when "01101" => inc := dastat.retry;
      when "01110" => inc := dastat.split;
      when "01111" => inc := dastat.spdel;
      when "10000" => inc := dastat.locked;
      when others => null;
    end case;
    if cnt.suen(1) = '1' and cnt.cpu /= dastat.hmaster then
      inc := '0';
    end if;
  elsif astaten /= 0 and cnt.op(6 downto 4) = "111" then  -- 0x70 - 0x7F
    case op(3 downto 0) is
      when "0000" => inc := astat.idle;
      when "0001" => inc := astat.busy;
      when "0010" => inc := astat.nseq;
      when "0011" => inc := astat.seq;
      when "0100" => inc := astat.read;
      when "0101" => inc := astat.write;
      when "0110" => inc := astat.hsize(0);
      when "0111" => inc := astat.hsize(1);
      when "1000" => inc := astat.hsize(2);
      when "1001" => inc := astat.hsize(3);
      when "1010" => inc := astat.hsize(4);
      when "1011" => inc := astat.hsize(5);
      when "1100" => inc := astat.ws;
      when "1101" => inc := astat.retry;
      when "1110" => inc := astat.split;
      when "1111"  => inc := astat.spdel;
      when others => null;
    end case;
    if cnt.suen(1) = '1' and cnt.cpu /= astat.hmaster then
      inc := '0';
    end if;
  elsif nextev /= 0 then                -- 0x60 - 0x6F
    -- External event 0 to 15
    for i in 0 to 15 loop
      if i >= nextev then
        exit;
      end if;
      if i = conv_integer(cnt.op(3 downto 0)) then
        if cnt.suen(1) = '0' or cnt.cpu = esource(i) then
          inc := ev(i);
        end if;
      end if;
    end loop;
  end if;
  end if;
  if selreq /= 0 and cnt.op(cnt.op'left) = '1' then
    -- Possible extensions to the below:
    -- - add check for when OP(3:0).hbusreq and AHBM.hbusreq is asserted at
    --   the same time
    -- - also take supervisor/usermode into account
    -- - do not only check on bus master but also/instead on MMU context ID
    for i in 0 to selreq loop
      for j in 0 to selreq loop
        if (i = conv_integer(cnt.op(3 downto 0)) and
            j = conv_integer(cnt.cpu)) then
          inc := req(j) and (sel(i) xor cnt.op(4));
        end if;
      end loop;
    end loop;
  end if;

  return(inc);
end;

function nmax_right return integer is
begin
  if nmax /= 0 then return nmax-1; end if;
  return 0;
end function;

function latch_cnt_addr (paddr : std_logic_vector(31 downto 0)) return boolean is
begin
  return LATCH_CNT and paddr(MADDR+1) = '1';
end function;

signal rc, rcin : cnt_type_vector(0 to ncnt-1);
signal mrc, mrcin : mcnt_type_vector(0 to nmax_right);
signal r, rin : reg_type;

begin


  comb : process(r, rc, mrc, rstn, apbi, dbgo, stati, astat)
    variable rdata : std_logic_vector(31 downto 0);
    variable rdata2 : std_logic_vector(31 downto 0);
    variable rv : cnt_type_vector(0 to MAX_CNT-1);
    variable mrv : mcnt_type_vector(0 to MAX_CNT-1);
    variable lrc : cnt_type_vector(0 to MAX_CNT-1);
    variable lmrc : mcnt_type_vector(0 to MAX_CNT-1);
    variable v : reg_type;
    variable addr : natural;
    variable addr2 : natural;
    variable dbgol : l3_debug_out_vector(0 to 15);

  begin
    for i in 0 to MAX_CNT-1 loop
      rv(i) := cnt_none; mrv(i) := mcnt_none;
      lrc(i) := cnt_none; lmrc(i) := mcnt_none;
    end loop;
    rv(0 to ncnt-1) := rc; mrv(0 to nmax_right) := mrc; v := r; 
    lrc(0 to ncnt-1) := rc; lmrc(0 to nmax_right) := mrc;
    addr := conv_integer(apbi.paddr(MADDR-1 downto 2));
    rdata := zero32; rdata2 := zero32; v.latcnt := '0'; v.timer := (others => '0');
    if LATCH_CNT then
      v.latcnt := stati.latcnt;
      if r.latcnt = '1' then v.timer := stati.timer; end if;
    end if;
    for i in 0 to ncpu-1 loop dbgol(i) := dbgo(i); end loop;
    for i in ncpu to 15 loop dbgol(i) := l3_dbgo_none; end loop;

    for i in 0 to ncnt-1 loop
      rv(i).inc := calc_inc(rc(i), dbgol, r, dsuo.astat, stati.event, stati.esource,
                            astat, stati.req, stati.sel) and rc(i).en;
      if nmax = 0 or i >= nmax or mrc(i).cd = '0' then
        if rc(i).inc = '1' then rv(i).cnt := rc(i).cnt + 1; end if;
      elsif nmax /= 0 and i < nmax then
        -- count maximum duration
        if (rc(i).en = '1') then
          if rc(i).inc = mrc(i).el then
            rv(i).cnt := rc(i).cnt + 1;
          else
            rv(i).cnt := zero32;
          end if;
          if rc(i).cnt > mrc(i).max then
            mrv(i).max := rc(i).cnt;
          end if;
        end if;
      end if;
      if LATCH_CNT and r.latcnt = '1' and nmax /= 0 and i < nmax then
        if mrc(i).cd = '0' then
          mrv(i).max := rv(i).cnt;
          if rc(i).clr = '1' then rv(i).cnt := (others => '0'); end if;
        end if;
      end if;
    end loop;

    if apb2en /= 0 then                 -- 2nd APB interface
      addr2 := conv_integer(apb2i.paddr(MADDR-1 downto 2));
      if (apb2i.psel(pindex2) and apb2i.penable) = '1' and (not latch_cnt_addr(apb2i.paddr)) then
        if apb2i.pwrite = '0' then
          if apb2i.paddr(MADDR) = '0' then
            rdata2 := lrc(addr2).cnt;
            if nmax = 0 or lmrc(addr2).cd = '0' then
              rdata2 := lrc(addr2).cnt;
            else
              rdata2 := lmrc(addr2).max;
            end if;
            if rv(addr2).clr = '1' then
              rv(addr2).cnt := zero32;
              if nmax /= 0 and nmax > addr2 then mrv(addr2).max := zero32; end if;
            end if;
          else
            if REVISION = 0 then
              rdata2(31 downto 28) := conv_std_logic_vector(ncpu-1, 4);
              rdata2(27 downto 23) := conv_std_logic_vector(ncnt-1, 5);
            else
              rdata2(31 downto 23) := conv_std_logic_vector(ncnt-1, 9);
            end if;
            rdata2(22) := conv_std_logic(nmax > addr2);
            rdata2(21) := conv_std_logic(lahben /= 0);
            rdata2(20) := conv_std_logic(dsuen /= 0);
            rdata2(19) := conv_std_logic(nextev /= 0);
            rdata2(18) := conv_std_logic(astaten /= 0);
            if nmax /= 0 and nmax > addr2 then
              rdata2(17) := lmrc(addr2).el;
              rdata2(16) := lmrc(addr2).cd;
            end if;
            rdata2(15 downto 14) := lrc(addr2).suen;
            rdata2(13) := lrc(addr2).clr; 
            rdata2(12) := lrc(addr2).en;
            rdata2(11 downto 4) := (others => '0');
            rdata2(4+op_len-1 downto 4) := lrc(addr2).op;
            rdata2(3 downto 0) := lrc(addr2).cpu;
          end if;
        else
          if apb2i.paddr(MADDR) = '0' then
            rv(addr2).cnt := apb2i.pwdata;
            if nmax /= 0 and nmax > addr2 then mrv(addr2).max := apbi.pwdata; end if; 
          else
            if nmax /= 0 and nmax > addr2 then
              mrv(addr2).el := apb2i.pwdata(17);
              mrv(addr2).cd := apb2i.pwdata(16);
            end if;
            rv(addr2).suen := apb2i.pwdata(15 downto 14);
            rv(addr2).clr := apb2i.pwdata(13);
            rv(addr2).en := apb2i.pwdata(12);
            rv(addr2).op := apb2i.pwdata(4+op_len-1 downto 4);
            rv(addr2).cpu := apb2i.pwdata(3 downto 0);
          end if;
        end if;
      end if;
      if latch_cnt_addr(apb2i.paddr) and (apb2i.psel(pindex2) and apb2i.penable) = '1' then
        if apb2i.paddr(7) = '0' then
          rdata2 := lmrc(addr2).max;
        else
          rdata := r.timer;
        end if;
        v.latcnt := v.latcnt or apb2i.pwrite;
      end if;
    else
      addr2 := 0;
    end if;
    
    if (apbi.psel(pindex) and apbi.penable) = '1' and (not latch_cnt_addr(apbi.paddr)) then
      if apbi.pwrite = '0' then
        if apbi.paddr(MADDR) = '0' then
          if nmax = 0 or lmrc(addr).cd = '0' then
            rdata := lrc(addr).cnt;
          else
            rdata := lmrc(addr).max;
          end if;
          if rv(addr).clr = '1' then
            rv(addr).cnt := zero32;
            if nmax /= 0 and nmax > addr then mrv(addr).max := zero32; end if;
          end if;
	else
          if REVISION = 0 then
            rdata(31 downto 28) := conv_std_logic_vector(ncpu-1, 4);
            rdata(27 downto 23) := conv_std_logic_vector(ncnt-1, 5);
          else
            rdata(31 downto 23) := conv_std_logic_vector(ncnt-1, 9);
          end if;
          rdata(22) := conv_std_logic(nmax > addr);
          rdata(21) := conv_std_logic(lahben /= 0);
          rdata(20) := conv_std_logic(dsuen /= 0);
          rdata(19) := conv_std_logic(nextev /= 0);
          rdata(18) := conv_std_logic(astaten /= 0);
          if nmax /= 0 and nmax > addr then
            rdata(17) := lmrc(addr).el;
            rdata(16) := lmrc(addr).cd;
          end if;
          rdata(15 downto 14) := lrc(addr).suen;
          rdata(13) := lrc(addr).clr; 
          rdata(12) := lrc(addr).en;
          rdata(11 downto 4) := (others => '0');
          rdata(4+op_len-1 downto 4) := lrc(addr).op;
          rdata(3 downto 0) := lrc(addr).cpu;
	end if;
      else
        if apbi.paddr(MADDR) = '0' then
          rv(addr).cnt := apbi.pwdata;
          if nmax /= 0 and nmax > addr then mrv(addr).max := apbi.pwdata; end if; 
	else
          if nmax /= 0 and nmax > addr then
            mrv(addr).el := apbi.pwdata(17);
            mrv(addr).cd := apbi.pwdata(16);
          end if;
          rv(addr).suen := apbi.pwdata(15 downto 14);
          rv(addr).clr := apbi.pwdata(13);
          rv(addr).en := apbi.pwdata(12);
          rv(addr).op := apbi.pwdata(4+op_len-1 downto 4);
          rv(addr).cpu := apbi.pwdata(3 downto 0);
        end if;
      end if;
      if latch_cnt_addr(apbi.paddr) and (apbi.psel(pindex) and apbi.penable) = '1' then
        if apbi.paddr(MADDR) = '0' then
          rdata:= lmrc(addr).max;
        else
          rdata := r.timer;
        end if;
        v.latcnt := v.latcnt or apbi.pwrite;
      end if;
    end if;

    if lahben /= 0 then
      if ahbsi.hready = '1' then
        if ahbsi.htrans(1) = '1' then v.active := '1'; v.hmaster := ahbsi.hmaster;
        else v.active := '0'; end if;
      end if;
    else
      v.active := '0'; v.hmaster := (others => '0');
    end if;
      
    if rstn = '0' then 
      for i in 0 to ncnt-1 loop rv(i).en := '0'; rv(i).inc := '0'; end loop;
      if lahben /= 0 then v.active := '0'; end if;
    end if;

    if nextev = 0 and dsuen = 0 and astaten = 0 then
      for i in 0 to ncnt-1 loop rv(i).op(6) := '0'; end loop;
    end if;
      
    rcin <= rv(0 to ncnt-1); mrcin <= mrv(0 to nmax_right); rin <= v;

    apbo.prdata <= rdata; 	-- drive apb read bus
    apbo.pirq <= (others => '0');

    apb2o.prdata <= rdata2;
    apb2o.pirq <= (others => '0');

  end process;

  apbo.pindex <= pindex;
  apbo.pconfig <= pconfig;

  apb2o.pindex <= pindex2;
  apb2o.pconfig <= pconfig2;
  
  regs : process(clk)
  begin
    if rising_edge(clk) then
      rc <= rcin;
    end if;
  end process;
  
  mregs : if nmax /= 0 generate
    regs : process(clk)
    begin
      if rising_edge(clk) then
        mrc <= mrcin;
      end if;
    end process;
  end generate;
  nomregs : if nmax = 0 generate
    mrc(0) <= mcnt_none;
  end generate;
  
  ahbregs : if lahben /= 0 or LATCH_CNT generate
    regs : process(clk)
    begin if rising_edge(clk) then r <= rin; end if; end process;
  end generate;
  noahbregs : if lahben = 0 and not LATCH_CNT generate
    r <= ((others => '0'), '0', '0', (others => '0'));
  end generate;

  
  
-- pragma translate_off
    bootmsg : report_version
    generic map ("lstat_" & tost(pindex) & ": " & 
	"LEON Statistics Unit, " & "ncpu : " & tost(ncpu) & 
	", ncnt : " & tost(ncnt) & ", rev "  & tost(REVISION));
-- pragma translate_on

-- pragma translate_off
  cproc : process
  begin
    assert (clatch = 0) or (pmask /= 16#fff# and nmax /= 0)
      report "LSTAT: clatch /= 0 requires pmask /= 16#fff# and nmax /= 0"
      severity failure;
    wait;
    assert (REVISION = 1 and pmask <= 16#ffc#) or (REVISION = 0)
      report "LSTAT: REVISION 1 of core requires pmask = 16#ffc# or larger area"
      severity failure;
    wait;
  end process;
-- pragma translate_on

end;

