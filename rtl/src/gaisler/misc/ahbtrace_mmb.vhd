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
-- Entity:      ahbtrace_mmb
-- File:        ahbtrace_mmb.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Modified:    Jan Andersson - Aeroflex Gaisler
-- Description: AHB trace unit that can have registers on a separate bus and
--              select between several trace buses.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;

entity ahbtrace_mmb is
  generic (
    hindex   : integer := 0;
    ioaddr   : integer := 16#000#;
    iomask   : integer := 16#E00#;
    tech     : integer := DEFMEMTECH; 
    irq      : integer := 0; 
    kbytes   : integer := 1;
    bwidth   : integer := 32;
    ahbfilt  : integer := 0;
    ntrace   : integer range 1 to 8 := 1;
    scantest : integer range 0 to 1 := 0; 
    exttimer : integer range 0 to 1 := 0;
    exten    : integer range 0 to 1 := 0);
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;       -- Register interface
    ahbso   : out ahb_slv_out_type;
    tahbmiv : in  ahb_mst_in_vector_type(0 to ntrace-1);       -- Trace
    tahbsiv : in  ahb_slv_in_vector_type(0 to ntrace-1);
    timer   : in  std_logic_vector(30 downto 0);
    astat   : out amba_stat_type;
    resen   : in  std_ulogic := '0'
  );
end; 

architecture rtl of ahbtrace_mmb is

constant TBUFABITS : integer := log2(kbytes) + 6;
constant TIMEBITS  : integer := 32 - exttimer;
constant FILTEN    : boolean := ahbfilt /= 0;
constant PERFEN    : boolean := (ahbfilt > 1);

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBTRACE, 0, 0, irq),
  4 => ahb_iobar (ioaddr, iomask),
  others => zero32);

type tracebuf_in_type is record 
  addr             : std_logic_vector(TBUFABITS-1 downto 0);
  data             : std_logic_vector(255 downto 0);
  enable           : std_logic;
  write            : std_logic_vector(7 downto 0);
end record;

type tracebuf_out_type is record 
  data             : std_logic_vector(255 downto 0);
end record;

type trace_break_reg is record
  addr          : std_logic_vector(31 downto 2);
  mask          : std_logic_vector(31 downto 2);
  read          : std_logic;
  write         : std_logic;
end record;

type regtype is record
  thaddr        : std_logic_vector(31 downto 0);
  thwrite       : std_logic;
  thtrans       : std_logic_vector(1 downto 0);
  thsize        : std_logic_vector(2 downto 0);
  thburst       : std_logic_vector(2 downto 0);
  thmaster      : std_logic_vector(3 downto 0);
  thmastlock    : std_logic;
  ahbactive     : std_logic;
  timer         : std_logic_vector((TIMEBITS-1)*(1-exttimer) downto 0);
  aindex        : std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index

  hready        : std_logic;
  hready2       : std_logic;
  hready3       : std_logic;
  hsel          : std_logic;
  hwrite        : std_logic;
  haddr         : std_logic_vector(TBUFABITS+4 downto 2);
  hrdata        : std_logic_vector(31 downto 0);
  regacc        : std_logic;
  
  enable        : std_logic;    -- trace enable
  bahb          : std_logic;    -- break on AHB watchpoint hit
  bhit          : std_logic;    -- breakpoint hit
  dcnten        : std_logic;    -- delay counter enable
  delaycnt      : std_logic_vector(TBUFABITS - 1 downto 0); -- delay counter

  tbreg1        : trace_break_reg;
  tbreg2        : trace_break_reg;
end record;

type pregtype is record
  stat    : amba_stat_type;
  split   : std_ulogic;
  splmst  : std_logic_vector(3 downto 0);
  hready  : std_ulogic;
  hresp   : std_logic_vector(1 downto 0);
end record;

type fregtype is record
  shsel         : std_logic_vector(0 to NAHBSLV-1);
  pf            : std_ulogic;         -- Filter perf outputs
  af            : std_ulogic;         -- Address filtering
  fr            : std_ulogic;         -- Filter reads
  fw            : std_ulogic;         -- Filter writes
  smask         : std_logic_vector(15 downto 0);
  mmask         : std_logic_vector(15 downto 0);
  rf            : std_ulogic;         -- Retry filtering
end record;

type bregtype is record
  bsel          : std_logic_vector(log2(ntrace) downto 0);
end record;

function ahb_filt_hit (
  r     : regtype;
  rf    : fregtype;
  hresp : std_logic_vector(1 downto 0)) return boolean is
  variable hit : boolean;
begin
  -- filter hit -> inhibit
  hit := false;
  -- Filter on read/write
  if ((rf.fw and r.thwrite) or (rf.fr and not r.thwrite)) = '1'  then
    hit := true;
  end if;
  -- Filter on address range
  if (((r.tbreg2.addr xor r.thaddr(31 downto 2)) and r.tbreg2.mask) /= zero32(29 downto 0)) then
    if rf.af = '1' then hit := true; end if;
  end if;
  -- Filter on master mask
  for i in rf.mmask'range loop
    if i > NAHBMST-1 then exit; end if;
    if i = conv_integer(r.thmaster) and rf.mmask(i) = '1' then
      hit := true;
    end if;
  end loop;
  -- Filter on slave mask
  for i in rf.smask'range loop
    if i > NAHBSLV-1 then exit; end if;
    if (rf.shsel(i) and rf.smask(i)) /= '0' then
      hit := true;
    end if;    
  end loop;
  -- Filter on retry response
  if (rf.rf = '1' and hresp = HRESP_RETRY) then
    hit := true;
  end if;
  return hit;
end function ahb_filt_hit;

function getnrams return integer is
  variable v: integer;
begin
  v := 2;
  if bwidth > 32 then v:=v+1; end if;
  if bwidth > 64 then v:=v+1; end if;
  return v;
end getnrams;
constant nrams: integer := getnrams;
subtype mtest64_vector is std_logic_vector(2*memtest_vlen-1 downto 0);
type mtest64_type is array(0 to 2) of mtest64_vector;
signal mtesti64, mtesto64: mtest64_type;


signal tbi   : tracebuf_in_type;
signal tbo   : tracebuf_out_type;

signal enable : std_logic_vector(1 downto 0);

signal r, rin : regtype;
signal rf, rfin : fregtype;
signal rb, rbin : bregtype;
signal pr, prin : pregtype;

begin

  ctrl : process(rst, ahbsi, tahbmiv, tahbsiv, r, rf, rb, tbo, pr, timer, resen)
  variable v : regtype;
  variable vabufi : tracebuf_in_type;
  variable regsd : std_logic_vector(31 downto 0);   -- data from registers
  variable aindex : std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
  variable bphit : std_logic;
  variable wdata, rdata : std_logic_vector(255 downto 0);
  variable hwdata : std_logic_vector(31 downto 0);
  variable hirq : std_logic_vector(NAHBIRQ-1 downto 0); 
  variable tahbmi : ahb_mst_in_type;
  variable tahbsi : ahb_slv_in_type;
  variable vf : fregtype;
  variable vb : bregtype;
  variable regaddr : std_logic_vector(4 downto 2);
  variable tbaddr  : std_logic_vector(3 downto 2);
  variable timeval : std_logic_vector(31 downto 0);
  variable pv : pregtype;
  begin

    v := r; regsd := (others => '0'); vabufi.enable := '0'; 
    vabufi.data := (others => '0'); vabufi.addr := (others => '0'); 
    vabufi.write := (others => '0'); bphit := '0'; 
    v.hready := r.hready2; v.hready2 := r.hready3; v.hready3 := '0'; 
    hwdata := ahbreadword(ahbsi.hwdata, r.haddr(4 downto 2));
    hirq := (others => '0'); hirq(irq) := r.bhit;
    vf := rf; vb := rb; pv := pr;
    if ntrace = 1 then
      tahbmi := tahbmiv(0); tahbsi := tahbsiv(0);
    else
      tahbmi := tahbmiv(conv_integer(rb.bsel));
      tahbsi := tahbsiv(conv_integer(rb.bsel));
    end if;
    regaddr := r.haddr(4 downto 2); --tbaddr := r.haddr(3 downto 2);
    timeval := (others => '0');
    timeval((TIMEBITS-1)*(1-exttimer) downto 0) := r.timer;
    if exttimer /= 0 then
      timeval(TIMEBITS-1 downto 0) := timer(TIMEBITS-1 downto 0);
    end if;
    wdata := (others => '0'); rdata := (others => '0');
    
-- trace buffer index and delay counters
    if exttimer = 0 and r.enable = '1' then v.timer := r.timer + 1; end if;
    aindex := r.aindex + 1;

-- check for AHB watchpoints
    if (tahbsi.hready and r.ahbactive ) = '1' then
      if ((((r.tbreg1.addr xor r.thaddr(31 downto 2)) and r.tbreg1.mask) = zero32(29 downto 0)) and
         (((r.tbreg1.read and not r.thwrite) or (r.tbreg1.write and r.thwrite)) = '1')) 
        or ((((r.tbreg2.addr xor r.thaddr(31 downto 2)) and r.tbreg2.mask) = zero32(29 downto 0)) and
           (((r.tbreg2.read and not r.thwrite) or (r.tbreg2.write and r.thwrite)) = '1')) 
      then
        if (r.enable = '1') and (r.dcnten = '0') and 
           (r.delaycnt /= zero32(TBUFABITS-1 downto 0))
        then v.dcnten := '1'; bphit := '1';
        --else bphit := '1'; v.enable := '0'; end if;
        elsif (r.enable = '1') and (r.dcnten = '0') then bphit := '1'; v.enable := '0'; end if;
      end if;
    end if;

-- generate buffer inputs
      vabufi.write := "00000000";
      wdata(AHBDW-1 downto 0) := tahbsi.hwdata;
      rdata(AHBDW-1 downto 0) := tahbmi.hrdata;
      if r.enable = '1' then
        vabufi.addr(TBUFABITS-1 downto 0) := r.aindex;
        vabufi.data(127 downto 96) := timeval;
        vabufi.data(95) := bphit;
        vabufi.data(94 downto 80) := (others => '0'); --tahbmi.hirq(15 downto 1);
        vabufi.data(79) := r.thwrite;
        vabufi.data(78 downto 77) := r.thtrans;
        vabufi.data(76 downto 74) := r.thsize;
        vabufi.data(73 downto 71) := r.thburst;
        vabufi.data(70 downto 67) := r.thmaster;
        vabufi.data(66) := r.thmastlock;
        vabufi.data(65 downto 64) := tahbmi.hresp;
        if r.thwrite = '1' then
          vabufi.data(63 downto 32)     := wdata(31 downto 0);
          vabufi.data(223 downto 128)   := wdata(127 downto 32);
        else
          vabufi.data(63 downto 32)     := rdata(31 downto 0);
          vabufi.data(223 downto 128)   := rdata(127 downto 32);
        end if; 
        vabufi.data(31 downto 0) := r.thaddr;
      else
        if bwidth = 32 then
          vabufi.addr(TBUFABITS-1 downto 0) := r.haddr(TBUFABITS+3 downto 4);
        else
          vabufi.addr(TBUFABITS-1 downto 0) := r.haddr(TBUFABITS+4 downto 5);
        end if;
        -- Note: HWDATA from register i/f
        vabufi.data := hwdata & hwdata & hwdata & hwdata & hwdata & hwdata & hwdata & hwdata;
      end if;

-- write trace buffer

      if r.enable = '1' then 
        if (r.ahbactive and tahbsi.hready) = '1' then
          if not (FILTEN and ahb_filt_hit(r, rf, tahbmi.hresp)) then
            v.aindex := aindex;
            vabufi.enable := '1'; vabufi.write := "11111111";
          end if;
        end if;
      end if;

-- trace buffer delay counter handling

    if (r.dcnten = '1') and (r.ahbactive and tahbsi.hready) = '1' then
      if (r.delaycnt = zero32(TBUFABITS-1 downto 0)) then
        v.enable := '0'; v.dcnten := '0';
      end if;
      v.delaycnt := r.delaycnt - 1;
    end if;

-- AHB statistics
      
    if PERFEN then
      pv.hready := tahbsi.hready;
      pv.hresp := tahbmi.hresp;
      pv.stat := amba_stat_none;
      if pr.hready = '1' then
        case r.thtrans is
          when HTRANS_IDLE => pv.stat.idle := '1';
          when HTRANS_BUSY => pv.stat.busy := '1';
          when HTRANS_NONSEQ => pv.stat.nseq := '1';
          when others => pv.stat.seq := '1';
        end case;
        if r.ahbactive = '1' then
          pv.stat.read := not r.thwrite;
          pv.stat.write := r.thwrite;
          case r.thsize is
            when HSIZE_BYTE => pv.stat.hsize(0) := '1';
            when HSIZE_HWORD => pv.stat.hsize(1) := '1';
            when HSIZE_WORD => pv.stat.hsize(2) := '1';
            when HSIZE_DWORD => pv.stat.hsize(3) := '1';
            when HSIZE_4WORD => pv.stat.hsize(4) := '1';
            when others => pv.stat.hsize(5) := '1';
          end case;
        end if;
        pv.stat.hmaster := r.thmaster;
      end if;
      if pr.hresp = HRESP_OKAY then
        pv.stat.ws := not pr.hready;
      end if;
      -- It may also be interesting to count the maximum grant latency. That
      -- is; the delay between asserting hbusreq and receiving hgrant. This
      -- would require that all bus request signals were present in this
      -- entity. This has been left as a possible future extension.

      if pr.hready = '1' then
        if pr.hresp = HRESP_SPLIT then
          pv.stat.split := '1';
          pv.split := '1';
          if pr.split = '0' then
            pv.splmst := r.thmaster;
          end if;
        end if;
        if pr.hresp = HRESP_RETRY then
          pv.stat.retry := '1';
        end if;
      end if;

      pv.stat.locked := r.thmastlock;
        
      if rf.pf = '1' and ahb_filt_hit(r, rf, tahbmi.hresp) then
        pv.stat := amba_stat_none;
        pv.split := pr.split; pv.splmst := pr.splmst;
      end if;

      -- Count cycles where master is in SPLIT
      if pr.split = '1' then
        for i in tahbmi.hgrant'range loop
          if i = conv_integer(pr.splmst) and tahbmi.hgrant(i) = '1' then
            pv.split := '0';
          end if;
        end loop;
        pv.stat.spdel := pv.split;
      end if;
    end if;

-- save AHB transfer parameters

    if (tahbsi.hready = '1' ) then
      v.thaddr := tahbsi.haddr; v.thwrite := tahbsi.hwrite; v.thtrans := tahbsi.htrans;
      v.thsize := tahbsi.hsize; v.thburst := tahbsi.hburst;
      v.thmaster := tahbsi.hmaster; v.thmastlock := tahbsi.hmastlock;
      v.ahbactive := tahbsi.htrans(1);
      if FILTEN then vf.shsel := tahbsi.hsel; end if;
    end if;

-- AHB transfer parameters for register accesses
    
    if (ahbsi.hready = '1' ) then
      v.haddr := ahbsi.haddr(TBUFABITS+4 downto 2); v.hwrite := ahbsi.hwrite;
      v.regacc := ahbsi.haddr(16);
      v.hsel := ahbsi.htrans(1) and ahbsi.hsel(hindex);
    end if;
        
-- AHB slave access to DSU registers and trace buffers

    if (r.hsel and not r.hready) = '1' then
      if r.regacc = '0' then            -- registers
        v.hready := '1';
        case regaddr is
        when "000" =>
          regsd((TBUFABITS + 15) downto 16) := r.delaycnt;
          if ntrace /= 1 then
            regsd(15) := '1';
            regsd(log2(ntrace)+12 downto 12) := vb.bsel;
          end if;
          regsd(7 downto 6) := conv_std_logic_vector(log2(bwidth/32), 2);
          if FILTEN then
            regsd(8) := rf.pf;
            regsd(5) := rf.rf;
            regsd(4) := rf.af;
            regsd(3) := rf.fr;
            regsd(2) := rf.fw;
          end if;
          regsd(1 downto 0) := r.dcnten & r.enable;
          if r.hwrite = '1' then
            v.delaycnt := ahbsi.hwdata((TBUFABITS+ 15) downto 16); 
            if ntrace /= 1 then
              vb.bsel := ahbsi.hwdata(log2(ntrace)+12 downto 12);
            end if;
            if FILTEN then
              vf.pf := ahbsi.hwdata(8);
              vf.rf := ahbsi.hwdata(5);
              vf.af := ahbsi.hwdata(4);
              vf.fr := ahbsi.hwdata(3);
              vf.fw := ahbsi.hwdata(2);
            end if;
            v.dcnten := ahbsi.hwdata(1);
            v.enable := ahbsi.hwdata(0);
          end if;
        when "001" =>
            regsd((TBUFABITS - 1 + 4) downto 4) := r.aindex;
            if r.hwrite = '1' then
              v.aindex := ahbsi.hwdata((TBUFABITS- 1) downto 0); 
            end if;
        when "010" =>
          regsd := timeval;
          if exttimer = 0 and r.hwrite = '1' then
            v.timer := ahbsi.hwdata((TIMEBITS- 1)*(1-exttimer) downto 0); 
          end if;
        when "011" =>
          if FILTEN then
            regsd(31 downto 0) := rf.smask & rf.mmask;
            if r.hwrite = '1' then
              vf.smask := ahbsi.hwdata(31 downto 16);
              vf.mmask := ahbsi.hwdata(15 downto 0);
            end if;
          end if;
        when "100" =>
          regsd(31 downto 2) := r.tbreg1.addr; 
          if r.hwrite = '1' then
            v.tbreg1.addr := ahbsi.hwdata(31 downto 2); 
          end if;
        when "101" =>
          regsd := r.tbreg1.mask & r.tbreg1.read & r.tbreg1.write; 
          if r.hwrite = '1' then
            v.tbreg1.mask := ahbsi.hwdata(31 downto 2); 
            v.tbreg1.read := ahbsi.hwdata(1); 
            v.tbreg1.write := ahbsi.hwdata(0); 
          end if;
        when "110" =>
          regsd(31 downto 2) := r.tbreg2.addr; 
          if r.hwrite = '1' then
            v.tbreg2.addr := ahbsi.hwdata(31 downto 2); 
          end if;
        when others =>
          regsd := r.tbreg2.mask & r.tbreg2.read & r.tbreg2.write; 
          if r.hwrite = '1' then
            v.tbreg2.mask := ahbsi.hwdata(31 downto 2); 
            v.tbreg2.read := ahbsi.hwdata(1); 
            v.tbreg2.write := ahbsi.hwdata(0); 
          end if;
        end case;
        v.hrdata := regsd;
      else              -- read/write access to trace buffer
          if r.hwrite = '1' then v.hready := '1'; else v.hready2 := not (r.hready2 or r.hready); end if;
          vabufi.enable := not r.enable;
          case regaddr is
          when "000" =>
            v.hrdata := tbo.data(127 downto 96);
            if r.hwrite = '1' then 
              vabufi.write(3) := vabufi.enable;
            end if;
          when "001" =>
            v.hrdata := tbo.data(95 downto 64);
            if r.hwrite = '1' then 
              vabufi.write(2) := vabufi.enable;
            end if;
          when "010" =>
            v.hrdata := tbo.data(63 downto 32);
            if r.hwrite = '1' then 
              vabufi.write(1) := vabufi.enable;
            end if;
          when "011" =>
            v.hrdata := tbo.data(31 downto 0);
            if r.hwrite = '1' then 
              vabufi.write(0) := vabufi.enable;
            end if;
          when "100" =>
            if bwidth > 32 then
              v.hrdata := tbo.data(159 downto 128);
              if r.hwrite = '1' then 
                vabufi.write(7) := vabufi.enable;
              end if;
            else
              v.hrdata := tbo.data(127 downto 96);
              if r.hwrite = '1' then 
                vabufi.write(3) := vabufi.enable;
              end if;
            end if;
          when "101" =>
            if bwidth > 32 then
              if bwidth > 64 then
                v.hrdata := tbo.data(223 downto 192);
                if r.hwrite = '1' then 
                  vabufi.write(6) := vabufi.enable;
                end if;
              else v.hrdata := zero32; end if;
            else
              v.hrdata := tbo.data(95 downto 64);
              if r.hwrite = '1' then 
                vabufi.write(2) := vabufi.enable;
              end if;
            end if;
          when "110" =>
            if bwidth > 32 then
              if bwidth > 64 then
                v.hrdata := tbo.data(191 downto 160);
                if r.hwrite = '1' then 
                  vabufi.write(5) := vabufi.enable;
                end if;
              else v.hrdata := zero32; end if;
            else
              v.hrdata := tbo.data(63 downto 32);
              if r.hwrite = '1' then 
                vabufi.write(1) := vabufi.enable;
              end if;
            end if;
          when others =>
            if bwidth > 32 then
              v.hrdata := zero32;
            else
              v.hrdata := tbo.data(31 downto 0);
              if r.hwrite = '1' then 
                vabufi.write(0) := vabufi.enable;
              end if;
            end if;
          end case;
      end if;
    end if;

    if ((ahbsi.hsel(hindex) and ahbsi.hready) = '1') and 
          ((ahbsi.htrans = HTRANS_BUSY) or (ahbsi.htrans = HTRANS_IDLE))
    then v.hready := '1'; end if;

    if rst = '0' then
      v.ahbactive := '0';
      if exten /= 0 then v.enable := resen;
      else v.enable := '0'; end if;
      v.timer := (others => '0');
      v.hsel := '0'; v.dcnten := '0'; v.bhit := '0';
      v.regacc := '0'; v.hready := '1';
      v.tbreg1.read := '0'; v.tbreg1.write := '0';
      v.tbreg2.read := '0'; v.tbreg2.write := '0';
      if FILTEN then
        vf.smask := (others => '0'); vf.mmask := (others => '0');
      end if;
      if PERFEN then
        pv.split := '0'; pv.splmst := (others => '0');
      end if;
      if ntrace /= 1 then vb.bsel := (others => '0'); end if;
    end if;

    if PERFEN then astat <= pr.stat; else astat <= amba_stat_none; end if;

    tbi <= vabufi;
    rin <= v; rfin <= vf; rbin <= vb; prin <= pv;

    ahbso.hconfig <= hconfig;
    ahbso.hirq    <= hirq;
    ahbso.hsplit  <= (others => '0');
    ahbso.hrdata <= ahbdrivedata(r.hrdata);
    ahbso.hready <= r.hready;
    ahbso.hindex <= hindex;

  end process;

  ahbso.hresp <= HRESP_OKAY;

  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

  fregs : if FILTEN generate
    regs : process(clk)
    begin if rising_edge(clk) then rf <= rfin; end if; end process;
  end generate;
  nofregs : if not FILTEN generate
    rf.shsel     <= (others => '0');
    rf.pf        <= '0';
    rf.af        <= '0';
    rf.fr        <= '0';
    rf.fw        <= '0';
    rf.smask     <= (others => '0');
    rf.mmask     <= (others => '0');
    rf.rf        <= '0';
  end generate;
  perf : if PERFEN generate
    preg : process(clk)
    begin
      if rising_edge(clk) then
        pr <= prin;
      end if;
    end process;
  end generate;
  noperf : if not PERFEN generate
    pr.stat   <= amba_stat_none;
    pr.split  <= '0';
    pr.splmst <= (others => '0');
    pr.hready <= '0';
    pr.hresp  <= (others => '0');
  end generate;
  bregs : if ntrace /= 1 generate
    regs : process(clk)
    begin if rising_edge(clk) then rb <= rbin; end if; end process;
  end generate;
  nobregs : if ntrace = 1 generate
    rb.bsel <= (others => '0');
  end generate;
  
  enable <= tbi.enable & tbi.enable;
  mem32 : for i in 0 to 1 generate
    ram0 : syncram64 generic map (tech => tech, abits => TBUFABITS, testen => scantest, custombits => memtest_vlen)
      port map (clk, tbi.addr(TBUFABITS-1 downto 0), tbi.data(((i*64)+63) downto (i*64)),
                 tbo.data(((i*64)+63) downto (i*64)), enable, tbi.write(i*2+1 downto i*2),
                ahbsi.testin
                );
  end generate;

  mem64 : if bwidth > 32 generate -- extra data buffer for 64-bit bus
    ram0 : syncram generic map (tech => tech, abits => TBUFABITS, dbits => 32, testen => scantest, custombits => memtest_vlen)
      port map ( clk, tbi.addr(TBUFABITS-1 downto 0), tbi.data((128+31) downto 128),
          tbo.data((128+31) downto 128), tbi.enable, tbi.write(7),
          ahbsi.testin
                 );
  end generate;
  mem128 : if bwidth > 64 generate -- extra data buffer for 128-bit bus
    ram0 : syncram64 generic map (tech => tech, abits => TBUFABITS, testen => scantest, custombits => memtest_vlen)
      port map ( clk, tbi.addr(TBUFABITS-1 downto 0), tbi.data((128+95) downto (128+32)),
          tbo.data((128+95) downto (128+32)), enable, tbi.write(6 downto 5),
          ahbsi.testin
                 );
  end generate;

  nomem64 : if bwidth < 64 generate -- no extra data buffer for 64-bit bus
    tbo.data((128+31) downto 128) <= (others => '0');
  end generate;
  nomem128 : if bwidth < 128 generate -- no extra data buffer for 128-bit bus
    tbo.data((128+95) downto (128+32)) <= (others => '0');
  end generate;
  tbo.data(255 downto 224) <= (others => '0');


-- pragma translate_off
    bootmsg : report_version 
    generic map ("ahbtrace" & tost(hindex) &
    ": AHB Trace Buffer, " & tost(kbytes) & " kbytes");
-- pragma translate_on

end;


