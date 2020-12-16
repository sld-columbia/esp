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
-- Entity:      dsu
-- File:        dsu.vhd
-- Author:      Jiri Gaisler, Edvin Catovic - Gaisler Research
-- Description: Combined LEON3 debug support and AHB trace unit
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.config_types.all;
use work.config.all;
use work.stdlib.all;
use work.devices.all;
use work.leon3.all;
use work.gencomp.all;

entity dsu3x is
  generic (
    hindex  : integer := 0;
    haddr   : integer := 16#900#;
    hmask   : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0;
    clk2x   : integer range 0 to 1 := 0;
    testen  : integer := 0;
    bwidth  : integer := 32;
    ahbpf   : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    hclk   : in  std_ulogic;
    cpuclk : in std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    tahbsi : in  ahb_slv_in_type;
    dbgi   : in l3_debug_out_vector(0 to NCPU-1);
    dbgo   : out l3_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu_in_type;
    dsuo   : out dsu_out_type;
    hclken : in std_ulogic
  );
  attribute sync_set_reset of rst : signal is "true"; 
end; 

architecture rtl of dsu3x is

  constant TBUFABITS : integer := log2(kbytes) + 6;
  constant NBITS  : integer := log2x(ncpu);
  constant PROC_H : integer := 24+NBITS-1;
  constant PROC_L : integer := 24;
  constant AREA_H : integer := 23;
  constant AREA_L : integer := 20;
  constant HBITS : integer := 28;

  constant DSU3_VERSION : integer := 2;

  constant hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LEON3DSU, 0, DSU3_VERSION, 0),
    4 => ahb_membar(haddr, '0', '0', hmask),
    others => zero32);
  
  type slv_reg_type is record
    hsel     : std_ulogic;
    haddr    : std_logic_vector(PROC_H downto 0);
    hwrite   : std_ulogic;
    hwdata   : std_logic_vector(31 downto 0);
    hrdata   : std_logic_vector(31 downto 0);    
    hready  : std_ulogic;
    hready2 : std_ulogic;
  end record;                   

  constant slv_reg_none : slv_reg_type := (
    hsel     => '0',
    haddr    => (others => '0'),
    hwrite   => '0',
    hwdata   => (others => '0'),
    hrdata   => (others => '0'),
    hready   => '1',
    hready2  => '1'
    );
  
  type reg_type is record
    slv  : slv_reg_type;
    en  : std_logic_vector(0 to NCPU-1);
    te  : std_logic_vector(0 to NCPU-1);
    be  : std_logic_vector(0 to NCPU-1);
    bw  : std_logic_vector(0 to NCPU-1);
    bs  : std_logic_vector(0 to NCPU-1);
    bx  : std_logic_vector(0 to NCPU-1);
    bz  : std_logic_vector(0 to NCPU-1);
    halt  : std_logic_vector(0 to NCPU-1);
    reset : std_logic_vector(0 to NCPU-1);
    bn    : std_logic_vector(NCPU-1 downto 0);
    ss    : std_logic_vector(NCPU-1 downto 0);
    bmsk  : std_logic_vector(NCPU-1 downto 0);
    dmsk  : std_logic_vector(NCPU-1 downto 0);
    cnt   : std_logic_vector(2 downto 0);
    dsubre : std_logic_vector(2 downto 0);
    dsuen : std_logic_vector(2 downto 0);
    act   : std_ulogic;
    timer : std_logic_vector(tbits-1 downto 0);
    pwd   : std_logic_vector(NCPU-1 downto 0);    
    tstop : std_ulogic;
  end record;

  constant RRES : reg_type := (
    slv    => slv_reg_none,
    en     => (others => '0'),
    te     => (others => '0'),
    be     => (others => '0'),
    bw     => (others => '0'),
    bs     => (others => '0'),
    bx     => (others => '0'),
    bz     => (others => '0'),
    halt   => (others => '0'),
    reset  => (others => '0'),
    bn     => (others => '0'),
    ss     => (others => '0'),
    bmsk   => (others => '0'),
    dmsk   => (others => '0'),
    cnt    => (others => '0'),
    dsubre => (others => '0'),
    dsuen  => (others => '0'),
    act    => '0',
    timer  => (others => '0'),
    pwd    => (others => '0'),
    tstop  => '0'
    );
  
  type trace_break_reg is record
    addr          : std_logic_vector(31 downto 2);
    mask          : std_logic_vector(31 downto 2);
    read          : std_logic;
    write         : std_logic;
  end record;

  constant trace_break_none : trace_break_reg := (
    addr  => (others => '0'),
    mask  => (others => '0'),
    read  => '0',
    write => '0'
    );

  type tregtype is record
    haddr         : std_logic_vector(31 downto 0);
    hwrite        : std_logic;
    htrans        : std_logic_vector(1 downto 0);
    hsize         : std_logic_vector(2 downto 0);
    hburst        : std_logic_vector(2 downto 0);
    hwdata        : std_logic_vector(31 downto 0);
    hmaster       : std_logic_vector(3 downto 0);
    hmastlock     : std_logic;
    ahbactive     : std_logic;
    aindex        : std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
    enable        : std_logic;  -- trace enable
    bphit         : std_logic;  -- AHB breakpoint hit
    bphit2        : std_logic;  -- delayed bphit
    dcnten        : std_logic;  -- delay counter enable
    delaycnt      : std_logic_vector(TBUFABITS - 1 downto 0); -- delay counter
    tbreg1        : trace_break_reg;
    tbreg2        : trace_break_reg;
    tbwr          : std_logic;  -- trace buffer write enable
    break         : std_logic;  -- break CPU when AHB tracing stops
    tforce        : std_logic;  -- Force AHB trace
    timeren       : std_logic;  -- Keep timer enabled 
    sample        : std_logic;  -- Force sample
  end record;

  constant TRES : tregtype := (
    haddr         => (others => '0'),
    hwrite        => '0',
    htrans        => (others => '0'),
    hsize         => (others => '0'),
    hburst        => (others => '0'),
    hwdata        => (others => '0'),
    hmaster       => (others => '0'),
    hmastlock     => '0',
    ahbactive     => '0',
    aindex        => (others => '0'),
    enable        => '0',
    bphit         => '0',
    bphit2        => '0',
    dcnten        => '0',
    delaycnt      => (others => '0'),
    tbreg1        => trace_break_none,
    tbreg2        => trace_break_none,
    tbwr          => '0',
    break         => '0',
    tforce        => '0',
    timeren       => '0',
    sample        => '0'
    );

  type tfregtype is record
    shsel         : std_logic_vector(0 to NAHBSLV-1);
    pf            : std_ulogic;         -- Filter perf outputs
    af            : std_ulogic;         -- Address filtering
    fr            : std_ulogic;         -- Filter reads
    fw            : std_ulogic;         -- Filter writes
    smask         : std_logic_vector(15 downto 0);
    mmask         : std_logic_vector(15 downto 0);
    bpfilt        : std_logic_vector(1 downto 0);
  end record;

  type pregtype is record
    stat    : dsu_astat_type;
    split   : std_ulogic;
    splmst  : std_logic_vector(3 downto 0);
    hready  : std_ulogic;
    hresp   : std_logic_vector(1 downto 0);
  end record;

  constant PRES : pregtype := (
    stat => dsu_astat_none, split => '0', splmst => "0000", hready =>  '1', hresp => "00");
  constant TFRES : tfregtype :=
    (shsel => (others => '0'), pf => '0', af => '0', fr => '0', fw  => '0',
     smask => (others => '0'), mmask => (others => '0'),
     bpfilt => (others => '0'));
  
  type hclk_reg_type is record
    irq  : std_ulogic;
    oen  : std_ulogic;
  end record;

  constant hclk_reg_none : hclk_reg_type := (
    irq => '0', oen => '0'
    );

  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
  
  constant TRACEN : boolean := (kbytes /= 0);
  constant FILTEN : boolean := TRACEN and (ahbpf > 0);
  constant PERFEN : boolean := (ahbpf > 1);

  function ahb_filt_hit (
    tr : tregtype;
    tfr : tfregtype) return boolean is
    variable hit : boolean;
  begin
    -- filter hit -> inhibit
    hit := false;
    -- Filter on read/write
    if ((tfr.fw and tr.hwrite) or (tfr.fr and not tr.hwrite)) = '1'  then
      hit := true;
    end if;
    -- Filter on address range
    if (((tr.tbreg2.addr xor tr.haddr(31 downto 2)) and tr.tbreg2.mask) /= zero32(29 downto 0)) then
      if tfr.af = '1' then hit := true; end if;
    end if;
    -- Filter on master mask
    for i in tfr.mmask'range loop
      if i > NAHBMST-1 then exit; end if;
      if i = conv_integer(tr.hmaster) and tfr.mmask(i) = '1' then
        hit := true;
      end if;
    end loop;
    -- Filter on slave mask
    for i in tfr.smask'range loop
      if i > NAHBSLV-1 then exit; end if;
      if (tfr.shsel(i) and tfr.smask(i)) /= '0' then
        hit := true;
      end if;    
    end loop;
    return hit;
  end function ahb_filt_hit;

  
  
  signal tbi   : tracebuf_in_type;
  signal tbo   : tracebuf_out_type;

  signal pr, prin : pregtype;
  signal tfr, tfrin : tfregtype;
  signal tr, trin : tregtype;
  signal r, rin : reg_type;

  signal rh, rhin : hclk_reg_type;
  signal ahbsi2, tahbsi2 : ahb_slv_in_type;
  signal hrdata2x : std_logic_vector(31 downto 0);
  
begin

  comb: process(rst, r, ahbsi, ahbsi2, tahbsi2, dbgi, dsui, ahbmi, tr, tbo, hclken, rh, hrdata2x, tfr, pr)
                
    variable v : reg_type;
    variable iuacc : std_ulogic;
    variable dbgmode, tstop : std_ulogic;
    variable rawindex : integer range 0 to (2**NBITS)-1;
    variable index : natural range 0 to NCPU-1;
    variable hasel1 : std_logic_vector(AREA_H-1 downto AREA_L);
    variable hasel2 : std_logic_vector(6 downto 2);
    variable tv : tregtype;
    variable vabufi : tracebuf_in_type;
    variable aindex : std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
    variable hirq : std_logic_vector(NAHBIRQ-1 downto 0);
    variable cpwd : std_logic_vector(15 downto 0);     
    variable hrdata : std_logic_vector(31 downto 0);
    variable hwdata : std_logic_vector(31 downto 0);
    variable rdata, wdata : std_logic_vector(127 downto 0);
    variable bphit : std_logic_vector(1 to 2);
    variable vh : hclk_reg_type;    
    variable atact : std_ulogic;        -- ahb trace active
    variable tfv : tfregtype;
    variable pv : pregtype;
    variable slvhaddr : std_logic_vector(2 downto 0);

  begin
    
    v := r;
    iuacc := '0'; --v.slv.hready := '0';
    dbgmode := '0'; tstop := '1';
    v.dsubre := r.dsubre(1 downto 0) & dsui.break;
    v.dsuen := r.dsuen(1 downto 0) & dsui.enable;
    hrdata := r.slv.hrdata; hwdata := ahbreadword(ahbsi2.hwdata, r.slv.haddr(4 downto 2));
    wdata := (others => '0'); rdata := (others => '0');
    
    tv := tr; vabufi.enable := '0'; tv.bphit := '0';  tv.tbwr := '0'; tv.sample := '0';
    if (clk2x /= 0) then tv.bphit2 := tr.bphit; else tv.bphit2 := '0'; end if;
    vabufi.data := (others => '0'); vabufi.addr := (others => '0'); 
    vabufi.write := (others => '0'); aindex := (others => '0');
    hirq := (others => '0'); v.reset := (others => '0');
    tfv := tfr; pv := pr;
    
    if TRACEN then 
      aindex := tr.aindex + 1;
      if (clk2x /= 0) then vh.irq := tr.bphit or tr.bphit2; hirq(irq) := rh.irq;
      else hirq(irq) := tr.bphit; end if;
    end if;
    if hclken = '1' then
      v.slv.hready := '0'; v.act := '0';
    end if; 

    atact := tr.enable and ((not r.act) or tr.tforce);
    
-- check for AHB watchpoints
    bphit := (others => '0');
    if TRACEN and ((tahbsi2.hready and tr.ahbactive) = '1') then
      if ((((tr.tbreg1.addr xor tr.haddr(31 downto 2)) and tr.tbreg1.mask) = zero32(29 downto 0)) and
         (((tr.tbreg1.read and not tr.hwrite) or (tr.tbreg1.write and tr.hwrite)) = '1')) 
      then bphit(1) := '1'; end if;
      if ((((tr.tbreg2.addr xor tr.haddr(31 downto 2)) and tr.tbreg2.mask) = zero32(29 downto 0)) and
         (((tr.tbreg2.read and not tr.hwrite) or (tr.tbreg2.write and tr.hwrite)) = '1')) 
      then bphit(2) := '1'; end if;
    end if;    

-- generate AHB buffer inputs

    vabufi.write := (others => '0');
    if TRACEN then
      wdata(AHBDW-1 downto 0) := tahbsi2.hwdata;
      rdata(AHBDW-1 downto 0) := ahbmi.hrdata;
      if atact = '1' then
        vabufi.addr(TBUFABITS-1 downto 0) := tr.aindex;
        vabufi.data(127) := orv(bphit);
        vabufi.data(96+tbits-1 downto 96) := r.timer; 
        vabufi.data(94 downto 80) := (others => '0'); --ahbmi.hirq(15 downto 1);
        vabufi.data(79) := tr.hwrite;
        vabufi.data(78 downto 77) := tr.htrans;
        vabufi.data(76 downto 74) := tr.hsize;
        vabufi.data(73 downto 71) := tr.hburst;
        vabufi.data(70 downto 67) := tr.hmaster;
        vabufi.data(66) := tr.hmastlock;
        vabufi.data(65 downto 64) := ahbmi.hresp;
        if tr.hwrite = '1' then
          vabufi.data(63 downto 32) := wdata(31 downto 0);
          vabufi.data(223 downto 128) := wdata(127 downto 32);
        else
          vabufi.data(63 downto 32) := rdata(31 downto 0);
          vabufi.data(223 downto 128) := rdata(127 downto 32);
        end if; 
        vabufi.data(31 downto 0) := tr.haddr;
      else
        if bwidth = 32 then
          vabufi.addr(TBUFABITS-1 downto 0) := r.slv.haddr(TBUFABITS+3 downto 4); --tr.haddr(TBUFABITS+3 downto 4);
	else
          vabufi.addr(TBUFABITS-1 downto 0) := r.slv.haddr(TBUFABITS+4 downto 5); --tr.haddr(TBUFABITS+4 downto 5);
	end if;
        -- Note: HWDATA from register i/f
        vabufi.data(255 downto 0) := hwdata & hwdata & hwdata & hwdata & hwdata & hwdata & hwdata & hwdata;
      end if;

-- filter and write trace buffer

      if atact = '1' then 
        if ((tr.ahbactive and tahbsi2.hready) or tr.sample) = '1' then
          if not (FILTEN and ahb_filt_hit(tr, tfr)) then
            tv.aindex := aindex; tv.tbwr := '1';
            vabufi.enable := '1'; vabufi.write := (others => '1');
          elsif FILTEN then
            for i in 1 to 2 loop
              if tfr.bpfilt(i-1) = '1' then bphit(i) := '0'; end if;
            end loop;
          end if;
        end if;
      end if;

-- trigger AHB break/watchpoints
      if orv(bphit) = '1' then
        if (atact = '1') and (tr.dcnten = '0') and 
	   (tr.delaycnt /= zero32(TBUFABITS-1 downto 0))
        then tv.dcnten := '1'; 
	else tv.enable := '0'; tv.tforce := '0'; tv.timeren := '0'; tv.bphit := tr.break; end if;
      end if;
      
-- trace buffer delay counter handling

      if (tr.dcnten = '1') then
        if (tr.delaycnt = zero32(TBUFABITS-1 downto 0)) then
          tv.enable := '0'; tv.dcnten := '0'; tv.bphit := tr.break;
          end if;
        if tr.tbwr = '1' then tv.delaycnt := tr.delaycnt - 1; end if;          
      end if;

-- AHB statistics
      
      if PERFEN then
        pv.hready := tahbsi2.hready;
        pv.hresp := ahbmi.hresp;
        pv.stat := dsu_astat_none;
        if pr.hready = '1' then
          case tr.htrans is
            when HTRANS_IDLE => pv.stat.idle := '1';
            when HTRANS_BUSY => pv.stat.busy := '1';
            when HTRANS_NONSEQ => pv.stat.nseq := '1';
            when others => pv.stat.seq := '1';
          end case;
          if tr.ahbactive = '1' then
            pv.stat.read := not tr.hwrite;
            pv.stat.write := tr.hwrite;
            case tr.hsize is
              when HSIZE_BYTE => pv.stat.hsize(0) := '1';
              when HSIZE_HWORD => pv.stat.hsize(1) := '1';
              when HSIZE_WORD => pv.stat.hsize(2) := '1';
              when HSIZE_DWORD => pv.stat.hsize(3) := '1';
              when HSIZE_4WORD => pv.stat.hsize(4) := '1';
              when others => pv.stat.hsize(5) := '1';
            end case;
          end if;
          pv.stat.hmaster := tr.hmaster;
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
              pv.splmst := tr.hmaster;
            end if;
          end if;
          if pr.hresp = HRESP_RETRY then
            pv.stat.retry := '1';
          end if;
        end if;
                
        pv.stat.locked := tr.hmastlock;
        
        if tfr.pf = '1' and ahb_filt_hit(tr, tfr) then
          pv.stat := dsu_astat_none;
          pv.split := pr.split; pv.splmst := pr.splmst;
        end if;

        -- Count cycles where master is in SPLIT
        if pr.split = '1' then
          for i in ahbmi.hgrant'range loop
            if i = conv_integer(pr.splmst) and ahbmi.hgrant(i) = '1' then
              pv.split := '0';
            end if;
          end loop;
          pv.stat.spdel := pv.split;
        end if;
      end if;
      
-- save AHB transfer parameters

      if (tahbsi2.hready or tr.sample) = '1' then
        tv.haddr := tahbsi2.haddr; tv.hwrite := tahbsi2.hwrite; tv.htrans := tahbsi2.htrans;
        tv.hsize := tahbsi2.hsize; tv.hburst := tahbsi2.hburst;
        tv.hmaster := tahbsi2.hmaster; tv.hmastlock := tahbsi2.hmastlock;
        tv.ahbactive := tahbsi2.htrans(1);
        if FILTEN then tfv.shsel := tahbsi2.hsel; end if;
      end if;
    end if;

    if r.slv.hsel  = '1' then
      if (clk2x = 0) then
        v.cnt := r.cnt - 1;
      else
        if (r.cnt /= "111") or (hclken = '1') then v.cnt := r.cnt - 1; end if; 
      end if;                          
    end if;
    
    if (r.slv.hready and hclken) = '1' then
      v.slv.hsel := '0'; --v.slv.act := '0';
    end if;
    
    for i in 0 to NCPU-1 loop
      if dbgi(i).dsumode = '1' then
        if r.dmsk(i) = '0' then
          dbgmode := '1';
          if hclken = '1' then v.act := '1'; end if;
        end if;
        v.bn(i) := '1';
      else
        tstop := '0';
      end if;
    end loop;

    if ((r.dsuen(2) and not tstop) or tr.timeren) = '1' then v.timer := r.timer + 1; end if;
    if (clk2x /= 0) then
      if hclken = '1' then v.tstop := tstop; end if;
      tstop := r.tstop;
    end if;

    cpwd := (others => '0');    
    for i in 0 to NCPU-1 loop
      v.bn(i) := v.bn(i) or (dbgmode and r.bmsk(i)) or (r.dsubre(1) and not r.dsubre(2));
      if TRACEN then v.bn(i) := v.bn(i) or (tr.bphit and not r.ss(i) and not r.act); end if;
      v.pwd(i) := dbgi(i).idle and (not dbgi(i).ipend) and not v.bn(i);
    end loop;
    cpwd(NCPU-1 downto 0) := r.pwd;  

    if (ahbsi2.hready and ahbsi2.hsel(hindex)) = '1' then
      if (ahbsi2.htrans(1) = '1') then
        v.slv.hsel := '1';      
        v.slv.haddr := ahbsi2.haddr(PROC_H downto 0);
        v.slv.hwrite := ahbsi2.hwrite;
        v.cnt := "111";
      end if;
    end if;


    
    for i in 0 to NCPU-1 loop
      v.en(i) := r.dsuen(2) and dbgi(i).dsu;
    end loop;

    rawindex := conv_integer(r.slv.haddr(PROC_H downto PROC_L));    
    if ncpu = 1 then index := 0; else
      if rawindex > ncpu then index := ncpu-1; else index := rawindex; end if;
    end if;

    hasel1 := r.slv.haddr(AREA_H-1 downto AREA_L);
    hasel2 := r.slv.haddr(6 downto 2);
    if r.slv.hsel = '1' then
      case hasel1 is 
        
        when "000" =>  -- DSU registers
          if r.cnt(2 downto 0) = "110" then
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;          
          end if;
          hrdata := (others => '0');          
          case hasel2 is
            when "00000" =>
              if r.slv.hwrite = '1' then
                if hclken = '1' then
                  v.te(index) := hwdata(0);
                  v.be(index) := hwdata(1);
                  v.bw(index) := hwdata(2);
                  v.bs(index) := hwdata(3);
                  v.bx(index) := hwdata(4);                
                  v.bz(index) := hwdata(5);                
                  v.reset(index) := hwdata(9);                
                  v.halt(index) := hwdata(10);                
                else v.reset := r.reset; end if;
              end if;
              hrdata(0) := r.te(index);
              hrdata(1) := r.be(index);
              hrdata(2) := r.bw(index);
              hrdata(3) := r.bs(index);
              hrdata(4) := r.bx(index);
              hrdata(5) := r.bz(index);
              hrdata(6) := dbgi(index).dsumode;
              hrdata(7) := r.dsuen(2);
              hrdata(8) := r.dsubre(2);
              hrdata(9) := not dbgi(index).error;
              hrdata(10) := dbgi(index).halt;
              hrdata(11) := dbgi(index).pwd;
            when "00010" =>  -- timer
              if r.slv.hwrite = '1' then
                if hclken = '1' then
                  v.timer := hwdata(tbits-1 downto 0);
                else v.timer := r.timer; end if;
              end if;
              hrdata(tbits-1 downto 0) := r.timer;
            when "01000" =>
              if r.slv.hwrite = '1' then
                if hclken = '1' then
                  v.bn := hwdata(NCPU-1 downto 0);
                  v.ss := hwdata(16+NCPU-1 downto 16);
                else v.bn := r.bn; v.ss := r.ss; end if;
              end if;
              hrdata(NCPU-1 downto 0) := r.bn;
              hrdata(16+NCPU-1 downto 16) := r.ss; 
            when "01001" =>
              if (r.slv.hwrite and hclken) = '1' then
                v.bmsk(NCPU-1 downto 0) := hwdata(NCPU-1 downto 0);
                v.dmsk(NCPU-1 downto 0) := hwdata(NCPU-1+16 downto 16);
              end if;
              hrdata(NCPU-1 downto 0) := r.bmsk;
              hrdata(NCPU-1+16 downto 16) := r.dmsk;
            when "10000" =>
              if TRACEN then
                hrdata((TBUFABITS + 15) downto 16) := tr.delaycnt;
                hrdata(6 downto 5) := tr.timeren & tr.tforce;
	        hrdata(4 downto 0) := conv_std_logic_vector(log2(bwidth/32), 2) & tr.break & tr.dcnten & tr.enable;
                if r.slv.hwrite = '1' then
                  if hclken = '1' then
                    tv.delaycnt := hwdata((TBUFABITS+ 15) downto 16);
                    tv.sample := hwdata(7);
                    tv.timeren := hwdata(6);
                    tv.tforce := hwdata(5);
                    tv.break  := hwdata(2);                  
                    tv.dcnten := hwdata(1);
                    tv.enable := hwdata(0);
                  else 
                    tv.delaycnt := tr.delaycnt;
                    tv.sample := tr.sample; tv.timeren := tr.timeren;
                    tv.tforce := tr.tforce; tv.break := tr.break;
                    tv.dcnten := tr.dcnten; tv.enable := tr.enable;
                  end if;
                end if;
              end if;
            when "10001" =>
              if TRACEN then
                hrdata((TBUFABITS - 1 + 4) downto 4) := tr.aindex;
                if r.slv.hwrite = '1' then
                  if hclken = '1' then
                    tv.aindex := hwdata((TBUFABITS - 1 + 4) downto 4);
                  else tv.aindex := tr.aindex; end if;
                end if;
              end if;
            when "10010" =>
              if FILTEN then
                hrdata(9 downto 8) := tfr.bpfilt;
                hrdata(3 downto 0) := tfr.pf & tfr.af & tfr.fr & tfr.fw;
                if r.slv.hwrite = '1' then
                  if hclken = '1' then
                    tfv.bpfilt := hwdata(9 downto 8);
                    tfv.pf := hwdata(3);
                    tfv.af := hwdata(2);
                    tfv.fr := hwdata(1);
                    tfv.fw := hwdata(0);
		  else
                    tfv.bpfilt := tfr.bpfilt;
                    tfv.pf := tfr.pf;
                    tfv.af := tfr.af;
                    tfv.fr := tfr.fr;
                    tfv.fw := tfr.fw;
                  end if;
	        end if;
              end if;
            when "10011" =>
              if FILTEN then
                hrdata := tfr.smask & tfr.mmask;
                if r.slv.hwrite = '1' then
                  if hclken = '1' then
                    tfv.smask := hwdata(31 downto 16);
                    tfv.mmask := hwdata(15 downto 0);
		  else
                    tfv.smask := tfr.smask;
                    tfv.mmask := tfr.mmask;
                  end if;
	        end if;
              end if;
            when "10100" =>
              if TRACEN then
                hrdata(31 downto 2) := tr.tbreg1.addr; 
                if (r.slv.hwrite and hclken) = '1' then
                  tv.tbreg1.addr := hwdata(31 downto 2); 
                end if;
              end if;
            when "10101" =>
              if TRACEN then
                hrdata := tr.tbreg1.mask & tr.tbreg1.read & tr.tbreg1.write; 
                if (r.slv.hwrite and hclken) = '1' then
                  tv.tbreg1.mask := hwdata(31 downto 2); 
                  tv.tbreg1.read := hwdata(1); 
                  tv.tbreg1.write := hwdata(0); 
                end if;
              end if;
            when "10110" =>
              if TRACEN then
                hrdata(31 downto 2) := tr.tbreg2.addr; 
                if (r.slv.hwrite and hclken) = '1' then
                  tv.tbreg2.addr := hwdata(31 downto 2); 
                end if;
              end if;
            when "10111" =>
              if TRACEN then
                hrdata := tr.tbreg2.mask & tr.tbreg2.read & tr.tbreg2.write; 
                if (r.slv.hwrite and hclken) = '1' then
                  tv.tbreg2.mask := hwdata(31 downto 2); 
                  tv.tbreg2.read := hwdata(1); 
                  tv.tbreg2.write := hwdata(0); 
                end if;
              end if;
            when others =>
          end case;

        when "010"  =>  -- AHB tbuf
	  if TRACEN then
            if r.cnt(2 downto 0) = "101" then
              if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
            end if;
            vabufi.enable := not atact;
            slvhaddr := r.slv.haddr(4 downto 2);
            case slvhaddr is
            when "000" =>
	      hrdata := tbo.data(127 downto 96);
	      if (r.slv.hwrite and hclken) = '1' then 
	        vabufi.write(3) := vabufi.enable and v.slv.hready;
	      end if;
            when "001" =>
	      hrdata := tbo.data(95 downto 64);
	      if (r.slv.hwrite and hclken) = '1' then 
	        vabufi.write(2) := vabufi.enable and v.slv.hready;
	      end if;
            when "010" =>
	      hrdata := tbo.data(63 downto 32);
	      if (r.slv.hwrite and hclken) = '1' then 
	        vabufi.write(1) := vabufi.enable and v.slv.hready;
	      end if;
            when "011" =>
	      hrdata := tbo.data(31 downto 0);
	      if (r.slv.hwrite and hclken) = '1' then 
	        vabufi.write(0) := vabufi.enable and v.slv.hready;
	      end if;
            when "100" =>
	      if bwidth > 32 then
	        hrdata := tbo.data(159 downto 128);
	        if (r.slv.hwrite and hclken) = '1' then 
	          vabufi.write(7) := vabufi.enable and v.slv.hready;
	        end if;
	      else
	        hrdata := tbo.data(127 downto 96);
	        if (r.slv.hwrite and hclken) = '1' then 
	          vabufi.write(3) := vabufi.enable and v.slv.hready;
	        end if;
	      end if;
            when "101" =>
	      if bwidth > 32 then
	        if bwidth > 64 then
	          hrdata := tbo.data(223 downto 192);
	          if (r.slv.hwrite and hclken) = '1' then 
	            vabufi.write(6) := vabufi.enable and v.slv.hready;
	          end if;
		else hrdata := zero32; end if;
	      else
	        hrdata := tbo.data(95 downto 64);
	        if (r.slv.hwrite and hclken) = '1' then 
	          vabufi.write(2) := vabufi.enable and v.slv.hready;
	        end if;
	      end if;
            when "110" =>
	      if bwidth > 32 then
	        if bwidth > 64 then
	          hrdata := tbo.data(191 downto 160);
	          if (r.slv.hwrite and hclken) = '1' then 
	            vabufi.write(5) := vabufi.enable and v.slv.hready;
	          end if;
		else hrdata := zero32; end if;
	      else
	        hrdata := tbo.data(63 downto 32);
	        if (r.slv.hwrite and hclken) = '1' then 
	          vabufi.write(1) := vabufi.enable and v.slv.hready;
	        end if;
	      end if;
            when others =>
	      if bwidth > 32 then
	        hrdata := zero32;
	      else
	        hrdata := tbo.data(31 downto 0);
	        if (r.slv.hwrite and hclken) = '1' then 
	          vabufi.write(0) := vabufi.enable and v.slv.hready;
	        end if;
	      end if;
	    end case;
	  else
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
	  end if;
        when "011" | "001"  =>  -- IU reg file, IU tbuf
          iuacc := '1';
          hrdata := dbgi(index).data;
          if r.cnt(2 downto 0) = "101" then
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
          end if;
        when "100" =>  -- IU reg access
          iuacc := '1';
          hrdata := dbgi(index).data;
          if r.cnt(1 downto 0) = "11" then
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
          end if;
        when "111" => -- DSU ASI
          if r.cnt(2 downto 1) = "11" then iuacc := '1'; else iuacc := '0'; end if;
          if (dbgi(index).crdy = '1') or (r.cnt = "000") then
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
          end if;
          hrdata := dbgi(index).data;          
        when others =>
          if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
      end case;
      if (r.slv.hready and hclken and not v.slv.hsel) = '1' then v.slv.hready := '0'; end if;
      if (clk2x /= 0) and (r.slv.hready2 and hclken) = '1' then v.slv.hready := '1'; end if;
    end if;

    if r.slv.hsel = '1' then
      if (r.slv.hwrite and hclken) = '1' then v.slv.hwdata := hwdata(31 downto 0); end if;
      if (clk2x = 0) or ((r.slv.hready or r.slv.hready2) = '0') then
        v.slv.hrdata := hrdata;
      end if;
    end if;    
        
    if ((ahbsi2.hready and ahbsi2.hsel(hindex)) = '1') and (ahbsi2.htrans(1) = '0') then
      if (clk2x = 0) or (r.slv.hsel = '0') then  
        v.slv.hready := '1';
      end if;
    end if;

    if (clk2x /= 0) and (r.slv.hready = '1') then v.slv.hready2 := '0'; end if;
    if v.slv.hsel = '0' then v.slv.hready := '1'; end if;
   
    vh.oen := '0';
    if (clk2x /= 0) then
      if (hclken and r.slv.hsel and (r.slv.hready2 or v.slv.hready)) = '1'
      then vh.oen := '1'; end if;
      if (r.slv.hsel = '1') and (r.cnt = "111") and (hclken = '0') then iuacc := '0'; end if;
    end if;

    
    if (not RESET_ALL) and (rst = '0') then
      v.bn := (others => r.dsubre(2)); v.bmsk := (others => '0');
      v.dmsk := (others => '0');
      v.ss := (others => '0'); v.timer := (others => '0'); v.slv.hsel := '0';
      for i in 0 to NCPU-1 loop
        v.bw(i) := r.dsubre(2); v.be(i) := r.dsubre(2); 
        v.bx(i) := r.dsubre(2); v.bz(i) := r.dsubre(2); 
        v.bs(i) := '0'; v.te(i) := '0';
      end loop;
      tv.ahbactive := '0'; tv.enable := '0'; tv.tforce := '0'; tv.timeren := '0';
      tv.dcnten := '0';
      tv.tbreg1.read := '0'; tv.tbreg1.write := '0';
      tv.tbreg2.read := '0'; tv.tbreg2.write := '0';
      v.slv.hready := '1'; v.halt := (others => '0');
      v.act := '0'; v.tstop := '0';
      if FILTEN then
        tfv.pf := '0'; tfv.af := '0'; tfv.fr := '0'; tfv.fw := '0';
        tfv.smask := (others => '0'); tfv.mmask := (others => '0');        
        tfv.bpfilt := (others => '0');
      end if;
      if PERFEN then
        pv.split := '0'; pv.splmst := (others => '0');
      end if;
    end if;
    rin <= v; trin <= tv; tbi <= vabufi; tfrin <= tfv; prin <= pv;

    for i in 0 to NCPU-1 loop
      dbgo(i).tenable <= r.te(i);
      dbgo(i).dsuen <= r.en(i);  
      dbgo(i).dbreak <= r.bn(i); -- or (dbgmode and r.bmsk(i));
      if conv_integer(r.slv.haddr(PROC_H downto PROC_L)) = i then
        dbgo(i).denable <= iuacc;
      else
        dbgo(i).denable <= '0';
      end if;
      dbgo(i).step <= r.ss(i);    
      dbgo(i).berror <= r.be(i);
      dbgo(i).bsoft <= r.bs(i);
      dbgo(i).bwatch <= r.bw(i);
      dbgo(i).btrapa <= r.bx(i);
      dbgo(i).btrape <= r.bz(i);
      dbgo(i).daddr <= r.slv.haddr(PROC_L-1 downto 2);
      dbgo(i).ddata <= r.slv.hwdata(31 downto 0);    
      dbgo(i).dwrite <= r.slv.hwrite;
      dbgo(i).halt <= r.halt(i);
      dbgo(i).reset <= r.reset(i);
      dbgo(i).timer(tbits-1 downto 0) <= r.timer; 
      dbgo(i).timer(30 downto tbits) <= (others => '0');      
    end loop;
    
    ahbso.hconfig <= hconfig;
    ahbso.hresp <= HRESP_OKAY;
    ahbso.hready <= r.slv.hready;
    if (clk2x = 0) then 
      ahbso.hrdata <= ahbdrivedata(r.slv.hrdata);
    else
      ahbso.hrdata <= ahbdrivedata(hrdata2x);
    end if;
    ahbso.hsplit <= (others => '0');
    ahbso.hirq   <= hirq;
    ahbso.hindex <= hindex;    

    dsuo.active <= r.act;
    dsuo.tstop <= tstop;
    dsuo.pwd   <= cpwd;
    if PERFEN then dsuo.astat <= pr.stat; else dsuo.astat <= dsu_astat_none; end if;
    
    rhin <= vh;
    
  end process;   

  comb2gen0 : if (clk2x /= 0) generate    
    -- register i/f
    gen0 : for i in ahbsi.hsel'range generate
      ag0 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hsel(i), hclken, ahbsi2.hsel(i));
    end generate;

    gen1 : for i in ahbsi.haddr'range generate
      ag1 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.haddr(i), hclken, ahbsi2.haddr(i));
    end generate;

    ag2 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hwrite, hclken, ahbsi2.hwrite);

    gen3 : for i in ahbsi.htrans'range generate 
      ag3 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.htrans(i), hclken, ahbsi2.htrans(i));
    end generate;

    gen4 : for i in ahbsi.hwdata'range generate
      ag4 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hwdata(i), hclken, ahbsi2.hwdata(i));
    end generate;
    
    ag5 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hready, hclken, ahbsi2.hready);

    -- not used by register i/f:
    ahbsi2.hsize <= (others => '0');
    ahbsi2.hburst <= (others => '0');
    ahbsi2.hprot <= (others => '0');
    ahbsi2.hmaster <= (others => '0');
    ahbsi2.hmastlock <= '0';
    ahbsi2.hmbsel <= (others => '0');
    ahbsi2.hirq <= (others => '0');
    ahbsi2.testen <= '0';
    ahbsi2.testrst <= '0';
    ahbsi2.scanen <= '0';
    ahbsi2.testoen <= '0';

    -- trace buffer:
    gen6 : for i in tahbsi.haddr'range generate
      ag6 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.haddr(i), hclken, tahbsi2.haddr(i));
    end generate;

    ag7 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.hwrite, hclken, tahbsi2.hwrite);

    gen8 : for i in tahbsi.htrans'range generate 
      ag8 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.htrans(i), hclken, tahbsi2.htrans(i));
    end generate;

    gen9 : for i in tahbsi.hsize'range generate 
      ag9 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.hsize(i), hclken, tahbsi2.hsize(i));
    end generate;

    gen10 : for i in tahbsi.hburst'range generate 
      a10 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.hburst(i), hclken, tahbsi2.hburst(i));
    end generate;

    gen11 : for i in tahbsi.hwdata'range generate
      ag11 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.hwdata(i), hclken, tahbsi2.hwdata(i));
    end generate;

    ag12 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.hready, hclken, tahbsi2.hready);

    gen12 : for i in tahbsi.hmaster'range generate
      ag12 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.hmaster(i), hclken, tahbsi2.hmaster(i));
    end generate;
    
    ag13 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.hmastlock, hclken, tahbsi2.hmastlock);
    
    gen14 : for i in tahbsi.hsel'range generate
      ag14 : clkand generic map (tech => 0, ren => 0) port map (tahbsi.hsel(i), hclken, tahbsi2.hsel(i));
    end generate;
    
    -- not used by trace buffer:
    tahbsi2.hprot <= (others => '0');
    tahbsi2.hmbsel <= (others => '0');
    tahbsi2.hirq <= (others => '0');
    tahbsi2.testen <= '0';
    tahbsi2.testrst <= '0';
    tahbsi2.scanen <= '0';
    tahbsi2.testoen <= '0';
        
    gen15 : for i in hrdata2x'range generate
      ag15 : clkand generic map (tech => 0, ren => 0) port map (r.slv.hrdata(i), rh.oen, hrdata2x(i)); 
    end generate;
    
    reg2 : process(hclk)
    begin
      if rising_edge(hclk) then rh <= rhin; end if;
    end process;
  end generate;

  comb2gen1 : if (clk2x = 0) generate
    ahbsi2 <= ahbsi; rh.irq <= '0'; rh.oen <= '0'; hrdata2x <= (others => '0');
    tahbsi2 <= tahbsi;
  end generate;
    
  reg : process(cpuclk)
  begin
    if rising_edge(cpuclk) then
      r <= rin;
      if RESET_ALL and (rst = '0') then
        r <= RRES;
        for i in 0 to NCPU-1 loop
          r.bn(i) <= r.dsubre(2); r.bw(i) <= r.dsubre(2);
          r.be(i) <= r.dsubre(2); r.bx(i) <= r.dsubre(2);
          r.bz(i) <= r.dsubre(2);
        end loop;
        r.dsubre <= rin.dsubre;         -- Sync. regs.
        r.dsuen <= rin.dsuen;
        r.en <= rin.en;
      end if;
    end if;
  end process;

    
  tb0 : if TRACEN generate
    treg : process(cpuclk)
    begin
      if rising_edge(cpuclk) then
        tr <= trin;
        if RESET_ALL and (rst = '0') then tr <= TRES; end if;
      end if;
    end process;

    tpf : if FILTEN generate
      pfreg : process(cpuclk)
      begin
        if rising_edge(cpuclk) then
          tfr <= tfrin;
          if RESET_ALL and (rst = '0') then tfr <= TFRES; end if;
        end if;
      end process;
    end generate;

    perf : if PERFEN generate
      preg : process(cpuclk)
      begin
        if rising_edge(cpuclk) then
          pr <= prin;
          if RESET_ALL and (rst = '0') then pr <= PRES; end if;
        end if;
      end process;
    end generate;
    
    mem0 : tbufmem
      generic map (tech => tech, tbuf => kbytes, dwidth => bwidth, testen => testen)
      port map (cpuclk, tbi, tbo, ahbsi.testin
                );
    
-- pragma translate_off
    bootmsg : report_version 
    generic map ("dsu3_" & tost(hindex) &
    ": LEON3 Debug support unit + AHB Trace Buffer, " & tost(kbytes) & " kbytes");
-- pragma translate_on
  end generate;
    
  notb : if not TRACEN generate
    tbo.data <= (others => '0');
    tr <= TRES;
-- pragma translate_off
    bootmsg : report_version 
    generic map ("dsu3_" & tost(hindex) &
    ": LEON3 Debug support unit");
-- pragma translate_on
  end generate;

  notpf : if not FILTEN generate
    tfr.shsel  <= (others => '0');
    tfr.pf     <= '0';
    tfr.af     <= '0';
    tfr.fr     <= '0';
    tfr.fw     <= '0';
    tfr.smask  <= (others => '0');
    tfr.mmask  <= (others => '0');
    tfr.bpfilt <= (others => '0');
  end generate;

  noperf : if not PERFEN generate
    pr.stat   <= dsu_astat_none;
    pr.split  <= '0';
    pr.splmst <= (others => '0');
    pr.hready <= '0';
    pr.hresp  <= (others => '0');
  end generate;
  
end;

