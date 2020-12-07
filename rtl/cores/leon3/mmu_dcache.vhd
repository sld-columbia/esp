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
-- Entity:      mmu_dcache
-- File:        mmu_dcache.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Modified:    Edvin Catovic - Gaisler Research
-- Description: This unit implements the data cache controller.
------------------------------------------------------------------------------  

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.sparc.all;
use work.stdlib.all;
use work.libiu.all;
use work.libcache.all;
use work.libmmu.all;
use work.mmuconfig.all;              
use work.mmuiface.all;               

entity mmu_dcache is
  generic (
    dsu        :     integer range 0 to 1     := 0;
    dcen       :     integer range 0 to 1     := 0;
    drepl      :     integer range 0 to 3     := 0;
    dsets      :     integer range 1 to 4     := 1;
    dlinesize  :     integer range 4 to 8     := 4;
    dsetsize   :     integer range 1 to 256   := 1;
    dsetlock   :     integer range 0 to 1     := 0;
    dsnoop     :     integer range 0 to 7     := 0;
    dlram      :     integer range 0 to 2     := 0;
    dlramsize  :     integer range 1 to 512   := 1;
    dlramstart :     integer range 0 to 255   := 16#8f#;
    ilram      :     integer range 0 to 2     := 0;
    ilramstart :     integer range 0 to 255   := 16#8e#;
    itlbnum    :     integer range 2 to 64    := 8;
    dtlbnum    :     integer range 2 to 64    := 8;
    tlb_type   :     integer range 0 to 3     := 1;
    memtech    :     integer range 0 to NTECH := 0;
    cached     :     integer                  := 0;
    mmupgsz    :     integer range 0 to 5     := 0;
    smp        :     integer                  := 0;
    mmuen      :     integer                  := 0;
    icen       :     integer range 0 to 1     := 0);
  port (
    rst        : in  std_ulogic;
    clk        : in  std_ulogic;
    dci        : in  dcache_in_type;
    dco        : out dcache_out_type;
    ico        : in  icache_out_type;
    mcdi       : out memory_dc_in_type;
    mcdo       : in  memory_dc_out_type;
    ahbsi      : in  ahb_slv_in_type;
    dcrami     : out dcram_in_type;
    dcramo     : in  dcram_out_type;
    fpuholdn   : in  std_ulogic;
    mmudci     : out mmudc_in_type;
    mmudco     : in  mmudc_out_type;
    sclk       : in  std_ulogic;
    ahbso      : in  ahb_slv_out_vector   
);


end; 

architecture rtl of mmu_dcache is
  
  constant M_EN : boolean := (mmuen = 1);

  constant DSNOOP2   : integer := dsnoop mod 4;
  constant DSNOOPSEP : boolean := (dsnoop > 3);

  constant M_TLB_TYPE      : integer range 0 to 1 := -- either split or combined
    conv_integer(conv_std_logic_vector(tlb_type, 2) and conv_std_logic_vector(1, 2));  
  constant M_TLB_FASTWRITE : integer range 0 to 3 := -- fast writebuffer
    conv_integer(conv_std_logic_vector(tlb_type, 2) and conv_std_logic_vector(2, 2));

  constant M_ENT_I    : integer range 2 to 64 := itlbnum;  -- icache tlb entries: number
  constant M_ENT_ILOG : integer := log2(M_ENT_I);  -- icache tlb entries: address bits

  constant M_ENT_D    : integer range 2 to 64 := dtlbnum;  -- dcache tlb entries: number
  constant M_ENT_DLOG : integer := log2(M_ENT_D);  -- dcache tlb entries: address bits

  constant M_ENT_C    : integer range 2 to 64 := M_ENT_I;  -- i/dcache tlb entries: number
  constant M_ENT_CLOG : integer := M_ENT_ILOG;  -- i/dcache tlb entries: address bits

  constant DLINE_BITS   : integer := log2(dlinesize);
  constant DOFFSET_BITS : integer := 8 +log2(dsetsize) - DLINE_BITS;
  constant LRR_BIT      : integer := TAG_HIGH + 1;
  constant TAG_LOW      : integer := DOFFSET_BITS + DLINE_BITS + 2;

  constant OFFSET_HIGH     : integer := TAG_LOW - 1;
  constant OFFSET_LOW      : integer := DLINE_BITS + 2;
  constant LINE_HIGH       : integer := OFFSET_LOW - 1;
  constant LINE_LOW        : integer := 2;
  constant LINE_ZERO       : std_logic_vector(DLINE_BITS-1 downto 0) := (others => '0');
  constant SETBITS         : integer := log2x(DSETS);
  constant DLRUBITS        : integer := lru_table(DSETS);
  constant LOCAL_RAM_START : std_logic_vector(7 downto 0) :=
    conv_std_logic_vector(dlramstart, 8);
  constant ILRAM_START     : std_logic_vector(7 downto 0) :=
    conv_std_logic_vector(ilramstart, 8);
  constant DIR_BITS        : integer := log2x(DSETS);
  constant bend            : std_logic_vector(4 downto 2) := "101";
  constant DLRAM_EN        : integer := conv_integer(conv_std_logic(dlram /= 0));

  type rdatatype is (dtag, ddata, dddata, dctx, icache, memory,
                     sysr , misc, mmusnoop_dtag);  -- sources during cache read
  type vmasktype is (clearone, clearall, merge, tnew);    -- valid bits operation

  type valid_type is array (0 to DSETS-1) of std_logic_vector(dlinesize - 1 downto 0);

  type write_buffer_type is record                        -- write buffer 
     addr, data1, data2 : std_logic_vector(31 downto 0);
     size               : std_logic_vector(1 downto 0);
     asi                : std_logic_vector(3 downto 0);
     read               : std_ulogic;
     lock               : std_ulogic;
     lock2              : std_ulogic;
     smask              : std_logic_vector(DSETS-1 downto 0);-- snoop mask
  end record;

  type dstatetype is (idle, wread, rtrans, wwrite, wtrans, wflush,
                      asi_idtag, dblwrite, loadpend);

  type dcache_control_type is record                       -- all registers
     read          : std_ulogic;                            -- access direction
     size          : std_logic_vector(1 downto 0);          -- access size
     req, burst, rburst, holdn, nomds, stpend  : std_ulogic;
     xaddress      : std_logic_vector(31 downto 0);         -- common address buffer
     paddress      : std_logic_vector(31 downto 0);         -- physical address buffer
     faddr         : std_logic_vector(DOFFSET_BITS - 1 downto 0);  -- flush address
     efaddr        : std_logic_vector(DOFFSET_BITS - 1 downto 0); -- error flush address
     dstate        : dstatetype;                           -- FSM vector
     hit, valid    : std_ulogic;
     flush         : std_ulogic;                           -- flush in progress
     flush2        : std_ulogic;                           -- flush in progress
     fflush        : std_ulogic;                           -- first flush
     mexc          : std_ulogic;                           -- latched mexc
     bmexc         : std_ulogic;                           -- latched mexc from burst read
     wb            : write_buffer_type;                    -- write buffer
     asi           : std_logic_vector(4 downto 0);
     icenable      : std_ulogic;                           -- icache diag access
     rndcnt        : std_logic_vector(log2x(DSETS)-1 downto 0); -- replace counter
     setrepl       : std_logic_vector(log2x(DSETS)-1 downto 0); -- set to replace
     lrr           : std_ulogic;            
     dsuset        : std_logic_vector(log2x(DSETS)-1 downto 0);
     lock          : std_ulogic;
     lramrd        : std_ulogic;
     ilramen       : std_ulogic;
     cctrl         : cctrltype;
     cctrlwr       : std_ulogic;
     flushl2       : std_ulogic;
     tadj, dadj, sadj : std_logic_vector(1 downto 0);

     mmctrl1       : mmctrl_type1;
     mmctrl1wr     : std_ulogic;
 
     pflush        : std_logic;
     pflushr       : std_logic;
     pflushaddr    : std_logic_vector(VA_I_U downto VA_I_D);
     pflushtyp     : std_logic;
     vaddr         : std_logic_vector(31 downto 0);
     ready         : std_logic;
     wbinit        : std_logic;
     cache         : std_logic;
     dlock         : std_logic;
     su            : std_logic;
     trans_op      : std_logic;
     flush_op      : std_logic;
     diag_op       : std_logic;
     reqst         : std_logic;
     set           : integer range 0 to DSETS-1;
     noflush       : std_logic;
     cmiss         : std_ulogic;
  end record;

  type snoop_reg_type is record                   -- snoop control registers
     snoop   : std_ulogic;                         -- snoop access to tags
     addr    : std_logic_vector(TAG_HIGH downto OFFSET_LOW);-- snoop tag address
     mask    : std_logic_vector(DSETS-1 downto 0);-- snoop mask
     snhit   : std_logic_vector(0 to MAXSETS-1);
  end record;

  subtype lru_type is std_logic_vector(DLRUBITS-1 downto 0);
  type lru_array  is array (0 to 2**DOFFSET_BITS-1) of lru_type;  -- lru registers

  type lru_reg_type is record
     write : std_ulogic;
     waddr : std_logic_vector(DOFFSET_BITS-1 downto 0);
     set   : std_logic_vector(SETBITS-1 downto 0);
     lru   : lru_array;
   end record;

  subtype lock_type is std_logic_vector(0 to DSETS-1);

  function lru_set (lru : lru_type; lock : lock_type) return std_logic_vector is
    variable xlru : std_logic_vector(4 downto 0);
    variable set  : std_logic_vector(SETBITS-1 downto 0);
    variable xset : std_logic_vector(1 downto 0);
    variable unlocked : integer range 0 to DSETS-1;
  begin
    set := (others => '0'); xlru := (others => '0'); xset := (others => '0');
    xlru(DLRUBITS-1 downto 0) := lru;

    if dsetlock = 1 then 
      unlocked := DSETS-1;
      for i in DSETS-1 downto 0 loop
        if lock(i) = '0' then unlocked := i; end if;
      end loop;
    end if;

    case DSETS is
      when 2 =>
        if dsetlock = 1 then
          if lock(0) = '1' then xset(0) := '1'; else xset(0) := xlru(0); end if;
        else
          xset(0) := xlru(0);
        end if;
      when 3 => 
        if dsetlock = 1 then
          xset := conv_std_logic_vector(lru3_repl_table(conv_integer(xlru)) (unlocked), 2);
        else
          -- xset := conv_std_logic_vector(lru3_repl_table(conv_integer(xlru)) (0), 2);
          xset := xlru(2) & (xlru(1) and not xlru(2));
        end if;
      when 4 =>
        if dsetlock = 1 then
          xset := conv_std_logic_vector(lru4_repl_table(conv_integer(xlru)) (unlocked), 2);
        else
          -- xset := conv_std_logic_vector(lru4_repl_table(conv_integer(xlru)) (0), 2);
          xset := xlru(4 downto 3);
        end if;    
      when others => 
    end case;
    set := xset(SETBITS-1 downto 0);
    return(set);
  end;

  function lru_calc (lru : lru_type; xset : std_logic_vector) return lru_type is
    variable new_lru : lru_type;
    variable xnew_lru: std_logic_vector(4 downto 0);
    variable xlru : std_logic_vector(4 downto 0);
    variable vset: std_logic_vector(SETBITS-1 downto 0);
    variable set: integer;
  begin
    vset := xset; set := conv_integer(vset);
    new_lru := (others => '0'); xnew_lru := (others => '0');
    xlru := (others => '0'); xlru(DLRUBITS-1 downto 0) := lru;
    case DSETS is
      when 2 => 
        if set = 0 then xnew_lru(0) := '1'; else xnew_lru(0) := '0'; end if;
      when 3 =>
        xnew_lru(2 downto 0) := lru_3set_table(conv_integer(lru))(set); 
      when 4 => 
        xnew_lru(4 downto 0) := lru_4set_table(conv_integer(lru))(set);
        xnew_lru(SETBITS-1 downto 0) := vset;
      when others => 
    end case;
    new_lru := xnew_lru(DLRUBITS-1 downto 0);
    return(new_lru);
  end;

  subtype word is std_logic_vector(31 downto 0);

  constant write_buffer_none : write_buffer_type := (
    addr  => (others => '0'),
    data1 => (others => '0'),
    data2 => (others => '0'),
    size  => (others => '0'),
    asi   => (others => '0'),
    read  => '0',
    lock  => '0',
    lock2 => '0',
    smask => (others => '0')
    );
  
  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
  constant RRES : dcache_control_type := (
    read       => '0',
    size       => (others => '0'),
    req        => '0',
    burst      => '0',
    rburst     => '0',
    holdn      => '1',
    nomds      => '0',
    stpend     => '0',
    xaddress   => (others => '0'),
    paddress   => (others => '0'),
    faddr      => (others => '0'),
    efaddr     => (others => '0'),
    dstate     => idle,
    hit        => '0',
    valid      => '0',
    flush      => '0',
    flush2     => '1',
    fflush     => '1',
    mexc       => '0',
    bmexc      => '0',
    wb         => write_buffer_none,
    asi        => (others => '0'),
    icenable   => '0',
    rndcnt     => (others => '0'),
    setrepl    => (others => '0'),
    lrr        => '0',
    dsuset     => (others => '0'),
    lock       => '0',
    lramrd     => '0',
    ilramen    => '0',
    cctrl      => cctrl_none,
    cctrlwr    => '0',
    flushl2    => '0',
    tadj       => (others => '0'),
    dadj       => (others => '0'),
    sadj       => (others => '0'),
    mmctrl1    => mmctrl_type1_none,
    mmctrl1wr  => '0',
    pflush     => '0',
    pflushr    => '0',
    pflushaddr => (others => '0'),
    pflushtyp  => '0',
    vaddr      => (others => '0'),
    ready      => '0',
    wbinit     => '0',
    cache      => '0',
    dlock      => '0',
    su         => '0',
    trans_op   => '0',
    flush_op   => '0',
    diag_op    => '0',
    reqst      => '0',
    set        => 0,
    noflush    => '0',
    cmiss      => '0'
    );
  constant SRES : snoop_reg_type := (
    snoop   => '0',
    addr    => (others => '0'),
    mask    => (others => '0'),
    snhit   => (others => '0')
    );
  constant LRES : lru_reg_type := (
    write => '0',
    waddr => (others => '0'),
    set   => (others => '0'),
    lru   => (others => (others => '0'))
    );
  
  signal r, c : dcache_control_type;      -- r is registers, c is combinational
  signal rs, cs : snoop_reg_type;         -- rs is registers, cs is combinational
  signal rl, cl : lru_reg_type;           -- rl is registers, cl is combinational

begin

  dctrl : process(rst, r, rs, rl, dci, mcdo, ico, dcramo, ahbsi, fpuholdn, mmudco, ahbso)
    variable dcramov : dcram_out_type;
    variable rdatasel : rdatatype;
    variable maddress : std_logic_vector(31 downto 0);
    variable maddrlow : std_logic_vector(1 downto 0);
    variable edata : std_logic_vector(31 downto 0);
    variable size : std_logic_vector(1 downto 0);
    variable read : std_ulogic;
    variable twrite, tpwrite, tdiagwrite, ddiagwrite, dwrite : std_ulogic;
    variable taddr : std_logic_vector(OFFSET_HIGH  downto LINE_LOW); -- tag address
    variable newtag : std_logic_vector(TAG_HIGH  downto TAG_LOW); -- new tag
    variable newptag : std_logic_vector(TAG_HIGH  downto TAG_LOW); -- new tag
    variable align_data : std_logic_vector(31 downto 0); -- aligned data
    variable ddatainv, rdatav, align_datav : cdatatype;
    variable rdata : std_logic_vector(31 downto 0);
  
    variable vmask : valid_type; --std_logic_vector((dlinesize -1) downto 0);
    variable enable, senable, scanen : std_logic_vector(0 to 3);
    variable mds : std_ulogic;
    variable mexc : std_ulogic;
    variable hit, valid, forcemiss : std_ulogic;
    variable flush    : std_ulogic;
    variable iflush   : std_ulogic;
    variable v : dcache_control_type;
    variable eholdn : std_ulogic;                         -- external hold
    variable snoopwe  : std_ulogic;
    variable hcache   : std_ulogic;
    variable lramcs, lramen, lramrd, lramwr, ilramen  : std_ulogic;
    variable snoopaddr : std_logic_vector(OFFSET_HIGH downto OFFSET_LOW);
    variable flushaddr : std_logic_vector(OFFSET_HIGH downto OFFSET_LOW);
    variable vs : snoop_reg_type;
    variable dsudata   : std_logic_vector(31 downto 0);
    variable set, eset : integer range 0 to DSETS-1;
    variable ddset : integer range 0 to MAXSETS-1;
    variable snoopset : integer range 0 to DSETS-1;
    variable validraw : std_logic_vector(0 to DSETS-1);
    variable validv, hitv : std_logic_vector(0 to MAXSETS-1);
    variable csnoopwe, snhit : std_logic_vector(0 to MAXSETS-1);
    variable ctwrite, ctpwrite, cdwrite : std_logic_vector(0 to MAXSETS-1);
    variable setrepl  : std_logic_vector(log2x(DSETS)-1 downto 0);
    variable lrusetval: std_logic_vector(SETBITS-1 downto 0);
    variable wlrr : std_logic_vector(0 to 3);
    variable vl : lru_reg_type;
    variable diagset : std_logic_vector(TAG_LOW + SETBITS -1 downto TAG_LOW);
    variable lock : std_logic_vector(0 to DSETS-1);
    variable wlock : std_logic_vector(0 to MAXSETS-1);
    variable laddr : std_logic_vector(31  downto 0); -- local ram addr
    variable tag : cdatatype; --std_logic_vector(31  downto 0);
    variable ptag : cdatatype; --std_logic_vector(31  downto 0);
    variable rlramrd : std_ulogic;
    variable cache : std_ulogic;

    variable ctx : ctxdatatype;
    variable flushl : std_ulogic;
    variable flushlv : std_logic_vector(0 to MAXSETS-1);
 
    variable miscdata  : std_logic_vector(31 downto 0);
    variable pflush : std_logic;
    variable pflushaddr : std_logic_vector(VA_I_U downto VA_I_D);
    variable pflushtyp : std_logic;
    variable pftag : std_logic_vector(31 downto 2);

    variable mmudci_fsread, tagclear : std_logic;
    variable mmudci_trans_op : std_logic;
    variable mmudci_flush_op : std_logic;
    variable mmudci_wb_op : std_logic;
    variable mmudci_diag_op : std_logic;
    variable mmudci_su : std_logic;
    variable mmudci_read : std_logic;
    variable su : std_logic;
  
    variable mmudci_transdata_data : std_logic_vector(31 downto 0);
    variable paddress : std_logic_vector(31 downto 0);            -- physical address buffer
    variable pagesize : integer range 0 to 3;

    variable mhold : std_logic; -- MMU hold
    variable wbhold : std_logic; -- write-buffer hold

  begin

-- init local variables

    v := r; vs := rs; dcramov := dcramo; vl := rl;
    vl.write := '0'; lramen := '0'; lramrd := '0'; lramwr := '0'; 
    lramcs := '0'; laddr := (others => '0'); v.cctrlwr := '0';
    ilramen := '0'; v.flush2 := r.flush;
    snhit := (others => '0'); v.cmiss := '0'; mhold := '0'; wbhold := '0';
    pagesize := MMU_getpagesize(mmupgsz,r.mmctrl1);

    if ((dci.eenaddr or dci.enaddr) = '1') or (r.dstate /= idle) or 
       ((dsu = 1) and (dci.dsuen = '1')) or (r.flush = '1') or
        (is_fpga(memtech) = 1)
    then
      enable := (others => '1');
    else enable := (others => '0'); end if;

    v.mmctrl1wr := '0';
    tagclear := '0'; paddress := r.paddress;
    if (not M_EN) or ((r.asi(4 downto 0) = ASI_MMU_BP) or (r.mmctrl1.e = '0')) then
      paddress := r.xaddress;
    end if;


    mds := '1'; dwrite := '0'; twrite := '0'; tpwrite := '0'; 
    ddiagwrite := '0'; tdiagwrite := '0'; v.holdn := '1'; mexc := '0';
    flush := '0'; v.icenable := '0'; iflush := '0';
    eholdn := ico.hold and fpuholdn; ddset := 0;
    vs.snoop := '0'; snoopwe := '0';
    snoopaddr := ahbsi.haddr(OFFSET_HIGH downto OFFSET_LOW);
    flushaddr := r.xaddress(OFFSET_HIGH downto OFFSET_LOW);
    hcache := '0'; 
    validv := (others => '0'); hitv := (others => '0'); cache := '0';
    if (dlram /= 0) then rlramrd := r.lramrd; else rlramrd := '0'; end if;

    miscdata := (others => '0'); pflush := '0';
    pflushaddr := dci.maddress(VA_I_U downto VA_I_D); pflushtyp := PFLUSH_PAGE;
    pftag := (others => '0');  
    ctx := (others => (others => '0'));
    mmudci_fsread := '0';

    ddatainv := (others => (others => '0')); tag := (others => (others => '0')); ptag := (others => (others => '0'));
    v.flushl2 := dci.flushl and not r.flush; 
    newptag := (others => '0');
    
    v.trans_op := r.trans_op and (not mmudco.grant);
    v.flush_op := r.flush_op and (not mmudco.grant);
    v.diag_op := r.diag_op and (not mmudco.grant);
    mmudci_trans_op := r.trans_op;
    mmudci_flush_op := r.flush_op;
    mmudci_diag_op := r.diag_op;
    mmudci_wb_op := '0';
    mmudci_transdata_data := r.vaddr;
    mmudci_su := '0'; mmudci_read := '0'; su := '0';
    
    rdatasel := ddata;  -- read data from cache as default
    senable := (others => '0'); scanen := (others => '0');  -- scanen no longer handled here
    
    set := 0; snoopset := 0;  csnoopwe := (others => '0');
    ctwrite := (others => '0'); ctpwrite := (others => '0'); cdwrite := (others => '0');
    wlock := (others => '0');
    for i in 0 to DSETS-1 loop wlock(i) := dcramov.tag(i)(CTAG_LOCKPOS); end loop; 
    wlrr := (others => '0');
    for i in 0 to 3 loop wlrr(i) := dcramov.tag(i)(CTAG_LRRPOS); end loop; 
    
    if (DSETS > 1) then setrepl := r.setrepl; else setrepl := (others => '0'); end if;
    
-- random replacement counter
    if DSETS > 1 then
      if conv_integer(r.rndcnt) = (DSETS - 1) then v.rndcnt := (others => '0');
      else v.rndcnt := r.rndcnt + 1; end if;
    end if;

    
-- generate lock bits
    lock := (others => '0');
    if dsetlock = 1 then 
      for i in 0 to DSETS-1 loop lock(i) := dcramov.tag(i)(CTAG_LOCKPOS); end loop;
    end if;
    
-- AHB snoop handling
    if (DSNOOP2 /= 0) then

      -- snoop on NONSEQ or SEQ and first word in cache line
      -- do not snoop during own transfers or during cache flush
      if (ahbsi.hready and ahbsi.hwrite and (not mcdo.bg or r.mmctrl1.e)) = '1' and
         ((ahbsi.htrans = HTRANS_NONSEQ) or 
            ((ahbsi.htrans = HTRANS_SEQ) and 
             (ahbsi.haddr(LINE_HIGH downto LINE_LOW) = LINE_ZERO)))
      then
        vs.snoop := r.cctrl.dsnoop;
        vs.addr := ahbsi.haddr(TAG_HIGH downto OFFSET_LOW);
        if (r.mmctrl1.e = '1')  and (mcdo.bg = '1') then vs.mask := r.wb.smask;
        else vs.mask := (others => '1'); end if;
      end if;

      if DSNOOP /= 0 then 
        for i in 0 to DSETS-1 loop senable(i) := vs.snoop or rs.snoop; end loop;
      end if;
        
      for i in DSETS-1 downto 0 loop
        if ((rs.snoop and not (r.flush or r.flush2)) = '1') then
          if (DSNOOP2 /= 0) and (rs.mask(i) = '1') and
            ((dcramov.stag(i)(TAG_HIGH downto TAG_LOW) = rs.addr(TAG_HIGH downto TAG_LOW)) 
             )
          then
            if DSNOOP2 /= 3 then
              if DSNOOPSEP then flushaddr := rs.addr(OFFSET_HIGH downto OFFSET_LOW);
              else snoopaddr := rs.addr(OFFSET_HIGH downto OFFSET_LOW); end if;
            end if;
            snoopwe := '1'; snoopset := i; snhit(i) := '1';
          end if;
        end if;
      end loop;
    end if;
    vs.snhit := snhit;
    if DSNOOP2=3 then
      snhit := (others => '0');
      snoopwe := '0';
    end if;
    
-- generate access parameters during pipeline stall

    if ((r.holdn) = '0') or ((dsu = 1) and (dci.dsuen = '1')) then
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW);
    elsif ((dci.enaddr and not dci.read) = '1') or (eholdn = '0')
    then
      taddr := dci.maddress(OFFSET_HIGH downto LINE_LOW);
    else
      taddr := dci.eaddress(OFFSET_HIGH downto LINE_LOW);
    end if;

    if (dci.write or not r.holdn) = '1' then
      maddress := r.xaddress(31 downto 0);
      read := r.read; size := r.size; edata := dci.maddress;
      mmudci_su := r.su; mmudci_read := r.read and not r.dlock;
    else
      maddress := dci.maddress(31 downto 0);
      read := dci.read; size := dci.size; edata := dci.edata;
      mmudci_su := dci.msu; mmudci_read := dci.read and not dci.lock;
    end if;

    newtag := dci.maddress(TAG_HIGH downto TAG_LOW);
    newptag := dci.maddress(TAG_HIGH downto TAG_LOW);
    vl.waddr := maddress(OFFSET_HIGH downto OFFSET_LOW);  -- lru write address
    if (dsnoop = 6) and (r.cctrl.dsnoop = '0') then 
      snoopaddr := taddr(OFFSET_HIGH downto OFFSET_LOW);
      senable := enable;
    end if;

    lrusetval := lru_set(rl.lru(conv_integer(maddress(OFFSET_HIGH downto OFFSET_LOW))), lock(0 to DSETS-1));

-- generate cache hit and valid bits

    if (r.mmctrl1.e = '0') then hcache := ahb_slv_dec_cache(dci.maddress, ahbso, cached);
    else hcache := '1'; end if;
    forcemiss := (not dci.asi(3)) or dci.lock;
    if (dci.asi(4 downto 0) = ASI_MMU_BP) or (r.cctrl.dcs(0) = '0') or
      ((r.flush or r.flush2) = '1')
    then hcache := '0'; end if;

    hit := '0'; set := 0;
    for i in DSETS-1 downto 0 loop
      if (dcramov.tag(i)(TAG_HIGH downto TAG_LOW) = dci.maddress(TAG_HIGH downto TAG_LOW))
        and ((dcramov.ctx(i) = r.mmctrl1.ctx) or (r.mmctrl1.e = '0'))
      then hitv(i) := '1'; end if;
      validv(i) := hcache and hitv(i) and (not r.flush) and (not r.flush2) and dcramov.tag(i)(dlinesize-1);
      validraw(i) := dcramov.tag(i)(dlinesize-1);
    end loop;

    if drepl = dir then 
      hit := hitv(conv_integer(dci.maddress(OFFSET_HIGH+DIR_BITS downto OFFSET_HIGH+1))) and not r.flush and (not r.flush2);
      valid := validv(conv_integer(dci.maddress(OFFSET_HIGH+DIR_BITS downto OFFSET_HIGH+1)));
    else
      hit := orv(hitv) and not r.flush and (not r.flush2);
      valid := orv(validv);
    end if;

    -- force cache miss if mmu-enabled but off or BYPASS, or on flush
    if (dci.asi(4 downto 0) = ASI_MMU_BP) or (r.cctrl.dcs(0) = '0') or ((r.flush or r.flush2) = '1')
    then hit := '0'; end if;
    
    if DSETS > 1 then 
      if drepl = dir then 
        set := conv_integer(dci.maddress(OFFSET_HIGH+DIR_BITS downto OFFSET_HIGH+1));
      else
        for i in DSETS-1 downto 0 loop 
          if (hitv(i) = '1') then set := i; end if;
        end loop;
      end if;
      if rlramrd = '1' then set := 1; end if;
    else set := 0; end if;

    if (dci.dsuen = '1') then diagset := r.xaddress(TAG_LOW+SETBITS-1 downto TAG_LOW);                                                
    else diagset := maddress(TAG_LOW + SETBITS - 1 downto TAG_LOW); end if;
    case DSETS is
    when 1 => ddset := 0;
    when 3 => if conv_integer(diagset) < 3 then ddset := conv_integer(diagset); end if;
    when others => ddset := conv_integer(diagset); 
    end case;

    if ((r.holdn and dci.enaddr) = '1')  and (r.dstate = idle) then
      v.hit := hit; v.xaddress := dci.maddress;      
      v.read := dci.read; v.size := dci.size;
      v.asi := dci.asi(4 downto 0);
      v.su := dci.msu; v.set := set;
      v.valid := valid; v.dlock := dci.lock;
    end if;

-- Store buffer

    if mcdo.ready = '1' then
      v.wb.addr(LINE_HIGH downto 2) := r.wb.addr(LINE_HIGH downto 2) + 1;
      if r.stpend = '1' then
        v.stpend := r.req; v.wb.data1 := r.wb.data2; 
        v.wb.lock := r.wb.lock and r.req;
      end if;
    end if;
    if mcdo.grant = '1' then v.req := r.burst; v.burst := '0'; end if;
    if (mcdo.grant and not r.wb.read and r.req) = '1' then v.wb.lock := '0'; end if;
    if (mcdo.grant and r.req) = '1' then v.wb.lock2 := r.wb.lock; end if;
    
    if (dlram /= 0) then
      if ((r.holdn) = '0') or ((dsu = 1) and (dci.dsuen = '1')) then
        laddr := r.xaddress;
      elsif ((dci.enaddr and not dci.read) = '1') or (eholdn = '0') then
        laddr := dci.maddress;
      else laddr := dci.eaddress; end if;
      if  (dci.enaddr = '1') and (dci.maddress(31 downto 24) = LOCAL_RAM_START)
      then lramen := '1'; end if;
      if  ((laddr(31 downto 24) = LOCAL_RAM_START)) or ((dci.dsuen = '1') and (dci.asi(4 downto 1) = "0101"))
      then lramcs := '1'; end if;      
    end if;
    
    if (ilram /= 0) then 
      if  (dci.enaddr = '1') and (dci.maddress(31 downto 24) = ILRAM_START)  then ilramen := '1'; end if;
    end if;

    -- cache freeze operation
    if (r.cctrl.ifrz and dci.intack and r.cctrl.ics(0)) = '1' then
      v.cctrl.ics := "01";
    end if;
    if (r.cctrl.dfrz and dci.intack and r.cctrl.dcs(0)) = '1' then
      v.cctrl.dcs := "01";
    end if;        

    if (r.cctrlwr and not dci.nullify) = '1' then
      if (r.xaddress(7 downto 2) = "000000") and (dci.read = '0') then
        v.noflush := dci.maddress(30);
        v.cctrl.dsnoop := dci.maddress(23);
        flush        := dci.maddress(22);
        iflush       := dci.maddress(21);
        v.cctrl.burst:= dci.maddress(16);
        v.cctrl.dfrz := dci.maddress(5);
        v.cctrl.ifrz := dci.maddress(4);
        v.cctrl.dcs  := dci.maddress(3 downto 2);
        v.cctrl.ics  := dci.maddress(1 downto 0);              
      end if;
    end if;


-- main Dcache state machine

    case r.dstate is
    when idle =>                        -- Idle state
      if (M_TLB_FASTWRITE /= 0) then
        mmudci_transdata_data := dci.maddress;
      end if;
      v.nomds := r.nomds and not eholdn; v.bmexc := '0';
      if ((r.reqst = '0') and (r.stpend = '0')) or ((mcdo.ready and not r.req)= '1') then -- wait for store queue
        v.wb.addr := dci.maddress; v.wb.size := dci.size;
        v.wb.read := dci.read; v.wb.data1 := dci.edata; v.wb.lock := dci.lock and not dci.nullify and ico.hold;
        v.wb.asi := dci.asi(3 downto 0); 
        if ((M_EN) and (dci.asi(4 downto 0) /= ASI_MMU_BP) and (r.mmctrl1.e = '1') and 
           ((M_TLB_FASTWRITE /= 0) or ((dci.enaddr and eholdn and dci.lock and not dci.read) = '1')))
        then
          if (dci.enaddr and eholdn and dci.lock and not dci.read) = '1' then -- skip address translation on store in LDST
            v.wb.addr := r.wb.addr(31 downto 8) & dci.maddress(7 downto 0);
            newptag := r.wb.addr(TAG_HIGH downto TAG_LOW);
          else 
            v.wb.addr := mmudco.wbtransdata.data; 
            newptag := mmudco.wbtransdata.data(TAG_HIGH downto TAG_LOW);
          end if;
        end if;
        if (dci.read and hcache and andv(r.cctrl.dcs)) = '1' then v.wb.addr(LINE_HIGH downto 0) := (others => '0'); end if;
      end if;
      if (eholdn and (not r.nomds)) = '1' then -- avoid false path through nullify
        case dci.asi(4 downto 0) is
        when ASI_SYSR => rdatasel := sysr;      
        when ASI_DTAG => rdatasel := dtag;
        when ASI_DDATA => rdatasel := dddata;
        when ASI_DCTX => if M_EN then rdatasel := dctx; end if;
        when ASI_MMUREGS | ASI_MMUREGS_V8 => if M_EN then rdatasel := misc; end if;
        when ASI_MMUSNOOP_DTAG => rdatasel := mmusnoop_dtag;
        when others =>
        end case;
      end if;
      if (dci.enaddr and eholdn and (not r.nomds) and not dci.nullify) = '1' then
        case dci.asi(4 downto 0) is
        when ASI_SYSR =>                -- system registers
          v.cctrlwr := not dci.read and not (dci.dsuen and not dci.eenaddr);
        when ASI_MMUREGS | ASI_MMUREGS_V8 =>
          if M_EN then
            if (dsu = 0) or dci.dsuen = '0' then
              -- clean fault valid bit
              if dci.read = '1' then
                case dci.maddress(CNR_U downto CNR_D) is
                  when CNR_F =>
                    mmudci_fsread := '1';
                  when others => null;
                end case;
              end if;
            end if;
            v.mmctrl1wr := not dci.read and not (r.mmctrl1wr and dci.dsuen);
          end if;
        when ASI_ITAG | ASI_IDATA | ASI_ICTX =>         -- Read/write Icache tags
          -- CTX write has to be done through ctxnr & ASI_ITAG
          if (ico.flush = '1') or (dci.asi(4) = '1') then mexc := '1';
          else v.dstate := asi_idtag; v.holdn := dci.dsuen; end if;
        when ASI_UINST | ASI_SINST =>
          if (ilram /= 0) then v.dstate := asi_idtag; v.ilramen := '1'; end if;
        when ASI_DFLUSH =>              -- flush data cache
          if dci.read = '0' then flush := '1'; end if;
        when ASI_DDATA =>               -- Read/write Dcache data
          if DSNOOPSEP then flushaddr := taddr(OFFSET_HIGH downto OFFSET_LOW); end if;
          if (r.flush = '1') then -- No access on flush
            mexc := '1';
          elsif (dci.read = '0') then
            dwrite := '1'; ddiagwrite := '1';
          end if;
        when ASI_DTAG =>                -- Read/write Dcache tags
          if DSNOOPSEP then flushaddr := taddr(OFFSET_HIGH downto OFFSET_LOW); end if;
          if (dci.size /= "10") or (r.flush = '1') then -- allow only word access
            mexc := '1';
          elsif (dci.read = '0') then
            twrite := '1'; tdiagwrite := '1';
          end if;
        when ASI_MMUSNOOP_DTAG =>       -- Read/write MMU physical snoop tags
          if DSNOOPSEP then
            snoopaddr := taddr(OFFSET_HIGH downto OFFSET_LOW);
            if (dci.size /= "10") or (r.flush = '1') then -- allow only word access
              mexc := '1';
            elsif (dci.read = '0') then
              tpwrite := '1'; tdiagwrite := '1';
            end if;
          end if;
        when ASI_DCTX =>
          -- write has to be done through ctxnr & ASI_DTAG
          if DSNOOPSEP then flushaddr := taddr(OFFSET_HIGH downto OFFSET_LOW); end if;
          if (dci.size /= "10") or (r.flush = '1') or (dci.read = '0') then -- allow only word access
            mexc := '1';
          end if;
        when ASI_FLUSH_PAGE => -- i/dcache flush page
          if dci.read = '0' then iflush := '1'; end if;
          if M_EN then
            if dci.read = '0' then
              flush := '1'; --pflush := '1'; pflushtyp := PFLUSH_PAGE;
            end if;
          end if;
        when ASI_FLUSH_CTX => -- i/dcache flush ctx
          if M_EN then
            if dci.read = '0' then
              flush := '1'; iflush := '1'; --pflush := '1'; pflushtyp := PFLUSH_CTX;
            end if;
          end if;
        when ASI_MMUFLUSHPROBE | ASI_MMUFLUSHPROBE_V8 =>
          if M_EN then
            if dci.read = '0' then      -- flush
              mmudci_flush_op := '1';
              v.flush_op := not mmudco.grant;
              v.dstate := wflush;
              v.vaddr := dci.maddress; v.holdn := '0'; flush := '1'; iflush := '1';
            end if;
          end if;
        when ASI_MMU_DIAG =>
         if dci.read = '0' then      -- diag access
            mmudci_diag_op := '1';
            v.diag_op := not mmudco.grant;
            v.vaddr := dci.maddress;
          end if;
        when others =>
          if dci.read = '1' then        -- read access
            v.rburst := hcache and andv(r.cctrl.dcs); -- and not forcemiss;
            if (dlram /= 0) and (lramen = '1') then
              lramrd := '1';
            elsif (ilram /= 0) and (ilramen = '1') then
              if (ico.flush = '1') or (dci.size /= "10") then mexc := '1';
              else v.dstate := asi_idtag; v.holdn := dci.dsuen; v.ilramen := '1'; end if;              
            elsif dci.dsuen = '0' then
              if not ((hit and valid and not forcemiss) = '1') then     -- read miss
                v.holdn := '0'; v.dstate := wread; v.ready := '0'; v.cmiss := hcache;
                v.cache := hcache and andv(r.cctrl.dcs);
                if (not M_EN) or ((dci.asi(4 downto 0) = ASI_MMU_BP) or (r.mmctrl1.e = '0')) then
                  -- cache disabled if mmu-enabled but off or BYPASS
                  if ((r.stpend  = '0') or ((mcdo.ready and not r.req) = '1')) then
                    v.req := '1'; v.burst := v.rburst or (andv(dci.size) and not dci.maddress(2));
                  end if;
                else
                  -- ## mmu case >
                  if (r.stpend  = '0') or ((mcdo.ready and not r.req)= '1') then
                    v.wbinit := '1';     -- wb init in idle
                    -- defer or:in in rburst to after mmu lookup since it
                    -- might get cleared
                    v.burst := (andv(dci.size) and not dci.maddress(2));
                  else
                    v.wbinit := '0';
                  end if;
                
                  mmudci_trans_op := '1';  -- start translation
                  v.trans_op := not mmudco.grant;
                  v.vaddr := dci.maddress; 
                  v.dstate := rtrans;
                  -- ## < mmu case 

                end if;
              else       -- read hit
                if (DSETS > 1) and (drepl = lru) then vl.write := '1'; end if;
                cache := '1';
                
              end if;
            end if;
          else                  -- write access
            if (dlram /= 0) and (lramen = '1') then
              lramwr := '1';
              if (dci.size = "11") then -- double store
                v.dstate := dblwrite; v.xaddress(2) := '1';
              end if; 
            elsif (ilram /= 0) and (ilramen = '1') then
              if (ico.flush = '1') or (dci.size /= "10") then mexc := '1';
              else v.dstate := asi_idtag; v.holdn := dci.dsuen; v.ilramen := '1'; end if;
            elsif dci.dsuen = '0' then
              v.ready := '0';
              if (not M_EN) or
                ((dci.asi(4 downto 0) = ASI_MMU_BP) or (r.mmctrl1.e = '0')) then
                if ((r.stpend  = '0') or ((mcdo.ready and not r.req)= '1')) 
                then    -- wait for store queue
                    v.reqst := '1';
                    v.burst := dci.size(1) and dci.size(0);
                  if (dci.size = "11") then v.dstate := dblwrite; end if; -- double store
                  v.wb.smask := (others => '1');
                else            -- wait for store queue
                  v.dstate := wwrite; v.holdn := '0'; v.wb.read := r.wb.read;
                end if;
              else
              -- ## mmu case >  false and
                if  ((r.stpend  = '0') or ((mcdo.ready and not r.req)= '1')) and 
                    (((mmudco.wbtransdata.accexc = '0') and (M_TLB_FASTWRITE /= 0)) or (dci.lock = '1'))
                then
                  v.reqst := '1';
                  v.burst := dci.size(1) and dci.size(0);
                  if (dci.size = "11") then v.dstate := dblwrite; end if; -- double store             
                  v.wb.smask := (others => '1');
                  if hit = '1' then v.wb.smask(set) := '0'; end if;
                else
                  if (r.stpend  = '0') or ((mcdo.ready and not r.req)= '1')
                  then
                    v.wbinit := '1';     -- wb init in idle
                    v.burst := dci.size(1) and dci.size(0);              
                    v.wb.smask := (others => '1');
                    if hit = '1' then v.wb.smask(set) := '0'; end if;
                  else
                    v.wbinit := '0';
                  end if;  
                  mmudci_trans_op := '1';  -- start translation
                  v.trans_op := not mmudco.grant; 
                  v.vaddr := dci.maddress; v.holdn := '0';
                  v.dstate := wtrans;
                  -- ## < mmu case 
                end if;  
              end if;
                
              if (hit and valid) = '1' then  -- write hit
                dwrite := '1'; 
                if (DSETS > 1) and (drepl = lru) then vl.write := '1'; end if;
                setrepl := conv_std_logic_vector(set, SETBITS);
                if DSNOOP2 /= 0 then
                  if ((dci.enaddr and not dci.read) = '1') or (eholdn = '0')
                  then v.xaddress := dci.maddress; else v.xaddress := dci.eaddress; end if;
                end if;
              end if;
              if (dci.size = "11") then v.xaddress(2) := '1'; end if;
            end if;
          end if;

          eset := set;
          if (DSETS > 1) then
            vl.set := conv_std_logic_vector(set, SETBITS);
            v.setrepl := conv_std_logic_vector(set, SETBITS);
            if (andv(validraw) = '0') and (drepl /= dir) and false then
              for i in DSETS-1 downto 0 loop
                 if validraw(i) = '0' then eset := i; end if;
              end loop; 
              v.setrepl := conv_std_logic_vector(eset, SETBITS);
            elsif ((not hit) and (not r.flush)) = '1' then
              case drepl is
              when rnd =>
                if dsetlock = 1 then 
                  if lock(conv_integer(r.rndcnt)) = '0' then v.setrepl := r.rndcnt;
                  else
                    v.setrepl := conv_std_logic_vector(DSETS-1, SETBITS);
                    for i in DSETS-1 downto 0 loop
                      if (lock(i) = '0') and (i>conv_integer(r.rndcnt)) then
                        v.setrepl := conv_std_logic_vector(i, SETBITS);
                      end if;
                    end loop;
                  end if;
                else
                  v.setrepl := r.rndcnt;
                end if;
              when dir =>
                v.setrepl := dci.maddress(OFFSET_HIGH+log2x(DSETS) downto OFFSET_HIGH+1);
              when lru =>
                v.setrepl := lrusetval;
              when lrr =>
                v.setrepl := (others => '0');
                if dsetlock = 1 then 
                  if lock(0) = '1' then v.setrepl(0) := '1';
                  else
                    v.setrepl(0) := dcramov.tag(0)(CTAG_LRRPOS) xor dcramov.tag(1)(CTAG_LRRPOS);
                  end if;
                else
                  v.setrepl(0) := dcramov.tag(0)(CTAG_LRRPOS) xor dcramov.tag(1)(CTAG_LRRPOS);
                end if;
                if v.setrepl(0) = '0' then
                  v.lrr := not dcramov.tag(0)(CTAG_LRRPOS);
                else
                  v.lrr := dcramov.tag(0)(CTAG_LRRPOS);
                end if;
              end case;
            end if;

            if (dsetlock = 1) then
              if (hit and lock(set)) = '1' then v.lock := '1';
              else v.lock := '0'; end if;
            end if;
          end if;
        end case;
      end if;
    when rtrans =>
      if M_EN then
        if r.stpend = '1' then
          if ((mcdo.ready and not r.req) = '1') then    
            v.ready := '1';       -- buffer store finish
          end if;
        end if;
        
        v.holdn := '0';
        if mmudco.transdata.finish = '1' then
          -- translation error, i.e. page fault
          if (mmudco.transdata.accexc) = '1' then
            v.holdn := '1'; v.dstate := idle;
            mds := '0'; mexc := not r.mmctrl1.nf;
          else
            v.dstate := wread;
            v.cache := r.cache and mmudco.transdata.cache;
            v.paddress := mmudco.transdata.data;
            v.rburst := r.rburst and v.cache;
            if r.wbinit = '1' then
              v.wb.addr := v.paddress; --mmudco.transdata.data;
              v.req := '1';
              v.burst := r.burst or v.rburst;
              if v.rburst = '1' then
                v.wb.addr(LINE_HIGH downto 0) := (others => '0');
              end if;
            end if;
          end if;
        end if;
        mhold := '1';
      end if;

    when wread =>               -- read miss, wait for memory data

      if drepl=lru and mcdo.ready='0' and r.hit='0' then
        v.setrepl := lrusetval;
      end if;

      taddr := r.wb.addr(OFFSET_HIGH downto LINE_LOW);
      newtag := r.xaddress(TAG_HIGH downto TAG_LOW);
      newptag := paddress(TAG_HIGH downto TAG_LOW);
      v.nomds := r.nomds and not eholdn;
      v.holdn := v.nomds; rdatasel := memory;
      for i in 0 to DSETS-1 loop wlock(i) := r.lock; end loop;
      for i in 0 to 3 loop wlrr(i) := r.lrr; end loop;
      if (r.stpend = '0') and (r.ready = '0') then
        if (r.rburst) = '1' then
          if (mcdo.grant = '1') and ((r.cctrl.dcs = "01") or
            ((r.wb.addr(LINE_HIGH downto LINE_LOW) >= bend(LINE_HIGH downto LINE_LOW)) and not
              ((r.wb.addr(LINE_HIGH downto LINE_LOW) = bend(LINE_HIGH downto LINE_LOW)) and (mcdo.ready = '0')))) then
            v.burst := '0';
          else v.burst := r.burst; end if;
        end if;
        if mcdo.ready = '1' then
          if r.rburst = '0' then
            mds := r.holdn or r.nomds; v.xaddress(2) := '1'; v.holdn := '1';
          else
            if r.wb.addr(LINE_HIGH downto LINE_LOW) = r.xaddress(LINE_HIGH downto LINE_LOW) then 
              mds := '0';
            end if;
          end if;
          dwrite := r.cache; rdatasel := memory;
          mexc := mcdo.mexc;
          v.bmexc := r.bmexc or mcdo.mexc or dci.flushl;
          if r.req = '0' then
            twrite := r.cache; tagclear := v.bmexc;
            if (((dci.enaddr and not r.holdn) = '1') or (dci.flushl = '1') or ((dci.eenaddr and r.holdn and eholdn) = '1'))
                and ((r.cctrl.dcs(0) = '1') or (dlram /= 0))
            then v.dstate := loadpend; v.holdn := '0';
            else v.dstate := idle; v.holdn := '1'; end if;
          else v.nomds := not r.rburst; end if;
          if DSNOOP2/=3 then
            tpwrite := twrite;
          end if;
          if DSNOOP2=3 and r.req='1' and r.cache='1' then
            tpwrite := '1';
          end if;
        end if;
        v.mexc := mcdo.mexc and not r.rburst; v.wb.data2 := mcdo.data;
      else
        if (r.ready or (mcdo.ready and not r.req)) = '1' then   -- wait for store queue
          v.wb.addr := paddress;
          v.wb.size := r.size;
          v.burst := r.rburst or (r.size(1) and r.size(0) and not r.xaddress(2));
          if r.rburst = '1' then
            v.wb.addr(LINE_HIGH downto 0) := (others => '0');
          end if;
          v.wb.read := r.read; v.wb.data1 := dci.maddress; v.req := '1'; 
          v.wb.lock := dci.lock; v.wb.asi := r.asi(3 downto 0); v.ready := '0';
        end if;
        wbhold := '1';
      end if;
    when loadpend =>            -- return from read miss with load pending
      taddr := dci.maddress(OFFSET_HIGH downto LINE_LOW);
      if (dlram /= 0) then
        laddr := dci.maddress;
        if laddr(31 downto 24) = LOCAL_RAM_START then lramcs := '1'; end if;
      end if;
      if (r.flushl2 and dci.enaddr) = '1' then 
        v.holdn := '0';
      else 
        v.dstate := idle; 
      end if;
    when dblwrite =>            -- second part of double store cycle
      edata := dci.edata;  -- needed for STD store hit
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); 
      if (dlram /= 0) and (rlramrd = '1') then
        laddr := r.xaddress; lramwr := '1';
      else
        if r.hit = '1' then dwrite := r.valid; end if;
        v.wb.data2 := dci.edata; 
      end if;
      if (dci.flushl and ico.hold) = '1' then 
        v.dstate := loadpend; v.holdn := '0';
      elsif ico.hold = '0' then v.reqst := '0';
      else v.dstate := idle; end if;
    when asi_idtag =>           -- icache diag and inst local ram access 
      rdatasel := icache; v.icenable := '1'; v.holdn := dci.dsuen;
      if  ico.diagrdy = '1' then
        v.dstate := loadpend; v.icenable := '0'; v.ilramen := '0';
        if (dsu = 0) or ((dsu = 1) and (dci.dsuen = '0')) then
          mds := not r.read;
        end if;
      end if;

    when wtrans =>
      edata := dci.edata;  -- needed for STD store hit
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); 
      newtag := r.xaddress(TAG_HIGH downto TAG_LOW);

      if M_EN then
        if r.stpend = '1' then
          if ((mcdo.ready and not r.req) = '1') then    
            v.ready := '1';       -- buffer store finish
          end if;
        end if;

        v.holdn := '0';
        if mmudco.transdata.finish = '1' then        
          if (mmudco.transdata.accexc) = '1' then
            v.holdn := '1'; v.dstate := idle;
            mds := '0'; mexc := not r.mmctrl1.nf;
            tagclear := r.hit;
            twrite := tagclear;
            if (twrite = '1') and (((dci.enaddr and not mds) = '1') or 
                ((dci.eenaddr and mds and eholdn) = '1')) and (r.cctrl.dcs(0) = '1') then
              v.dstate := loadpend; v.holdn := '0';
            end if;
          else
            v.dstate := wwrite;
            v.cache := mmudco.transdata.cache;
            v.paddress := mmudco.transdata.data;
            if (r.wbinit) = '1' then
              v.wb.data2 := dci.edata; 
              v.wb.addr := mmudco.transdata.data;
              v.dstate := idle;  v.holdn := '1'; 
              if (dci.nullify = '0') 
              then
                v.req := '1'; v.stpend := '1';
              else v.reqst := '1'; end if;
              v.burst := r.size(1) and r.size(0) and not v.wb.addr(2);

              if (r.hit = '1') and (r.size = "11")  then  -- write hit
                dwrite := r.valid;
              end if;
            end if;
          end if;
        end if;
      end if;
      mhold := '1';
        
    when wwrite =>              -- wait for store buffer to empty (store access)
      edata := dci.edata;  -- needed for STD store hit

      if (
        (dci.lock = '1')) and (dci.nullify = '1') then
        v.dstate := idle; v.wb.lock := '0';
      elsif ((v.ready or (mcdo.ready and not r.req)) = '1') or (
        (dci.lock = '1')) then  -- store queue emptied

        if (r.hit = '1') and (r.size = "11") then  -- write hit
          taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); dwrite := r.valid; 
        end if;
        v.dstate := idle; 

          v.burst := r.size(1) and r.size(0); 
          if (dci.nullify = '0') then v.reqst := '1'; end if;

        v.wb.addr := paddress;
        v.wb.size := r.size;
        v.wb.read := r.read; v.wb.data1 := dci.maddress;
        v.wb.lock := dci.lock; v.wb.data2 := dci.edata;
        v.wb.asi := r.asi(3 downto 0); 
        if r.size = "11" then v.wb.addr(2) := '0'; end if;
        v.wb.smask := (others => '1');
        if r.hit = '1' then v.wb.smask(r.set) := '0'; end if;
      else  -- hold cpu until buffer empty
        v.holdn := '0';
      end if;
      wbhold := '1';
    when wflush => 
      v.holdn := '0';
      if mmudco.transdata.finish = '1' then        
        v.dstate := idle; v.holdn := '1';
      end if;
    when others => v.dstate := idle;
    end case;

      v.req := v.req or v.reqst; v.stpend := v.stpend or v.reqst; v.reqst := '0';

    if (dlram /= 0) then v.lramrd := lramcs; end if; -- read local ram data 
    
-- select data to return on read access
-- align if byte/half word read from cache or memory.

    if (dsu = 1) and (dci.dsuen = '1') then
      v.dsuset := conv_std_logic_vector(ddset, SETBITS); 
      case dci.asi(4 downto 0) is
      when ASI_ITAG | ASI_IDATA =>
        v.icenable := not ico.diagrdy;
        rdatasel := icache;
      when ASI_DTAG =>
        tdiagwrite := dci.write;
        twrite := not dci.eenaddr and dci.enaddr and dci.write;
        rdatasel := dtag; 
      when ASI_MMUSNOOP_DTAG =>
        if DSNOOPSEP then snoopaddr := taddr(OFFSET_HIGH downto OFFSET_LOW); end if; 
        tdiagwrite := dci.write;
        tpwrite := not dci.eenaddr and dci.enaddr and dci.write;
        rdatasel := mmusnoop_dtag; senable := (others => '1');
      when ASI_DDATA =>
        if M_EN then
        ddiagwrite := dci.write;
        dwrite := not dci.eenaddr and dci.enaddr and dci.write;
        rdatasel := dddata;
        end if;
       when ASI_UDATA | ASI_SDATA  =>
         lramwr := not dci.eenaddr and dci.enaddr and dci.write;
      when ASI_MMUREGS | ASI_MMUREGS_V8 =>
        rdatasel := misc;  
      when others =>
      end case;
    end if;
    
    -- read
    if M_EN then
      case dci.maddress(CNR_U downto CNR_D) is
      when CNR_CTRL => 
        miscdata(MMCTRL_E) := r.mmctrl1.e; 
        miscdata(MMCTRL_NF) := r.mmctrl1.nf; 
        miscdata(MMCTRL_PSO) := r.mmctrl1.pso;
        miscdata(MMCTRL_VER_U downto MMCTRL_VER_D) := "0001";
        miscdata(MMCTRL_IMPL_U downto MMCTRL_IMPL_D) := "0000";
        miscdata(23 downto 21) := conv_std_logic_vector(M_ENT_ILOG,3);
        miscdata(20 downto 18) := conv_std_logic_vector(M_ENT_DLOG,3);
        if M_TLB_TYPE = 0 then miscdata(MMCTRL_TLBSEP) := '1'; else
          miscdata(23 downto 21) := conv_std_logic_vector(M_ENT_CLOG,3);
          miscdata(20 downto 18) := (others => '0');
        end if;
        miscdata(MMCTRL_TLBDIS) := r.mmctrl1.tlbdis;
        miscdata(MMCTRL_PGSZ_U downto MMCTRL_PGSZ_D) := conv_std_logic_vector(pagesize,2); -- r.mmctrl1.pagesize;
        --custom 
      when CNR_CTXP =>
        miscdata(MMCTXP_U downto MMCTXP_D) := r.mmctrl1.ctxp; 
      when CNR_CTX => 
        miscdata(MMCTXNR_U downto MMCTXNR_D) := r.mmctrl1.ctx; 
      when CNR_F =>
        miscdata(FS_OW) := mmudco.mmctrl2.fs.ow;
        miscdata(FS_FAV) := mmudco.mmctrl2.fs.fav;
        miscdata(FS_FT_U downto FS_FT_D) := mmudco.mmctrl2.fs.ft;
        miscdata(FS_AT_LS) := mmudco.mmctrl2.fs.at_ls;
        miscdata(FS_AT_ID) := mmudco.mmctrl2.fs.at_id;
        miscdata(FS_AT_SU) := mmudco.mmctrl2.fs.at_su;
        miscdata(FS_L_U downto FS_L_D) := mmudco.mmctrl2.fs.l;
        miscdata(FS_EBE_U downto FS_EBE_D) := mmudco.mmctrl2.fs.ebe;
      when CNR_FADDR => 
        miscdata(VA_I_U downto VA_I_D) := mmudco.mmctrl2.fa; 
      when others => null; 
      end case;
    end if;
    

    
    rdata := (others => '0'); rdatav := (others => (others => '0'));
    
    align_data := (others => '0'); align_datav := (others => (others => '0'));
    maddrlow := maddress(1 downto 0); -- stupid Synopsys VSS bug ...

    case rdatasel is
    when misc =>
      if M_EN then set := 0; rdatav(0) := miscdata; end if;
    when dddata =>
        rdatav := dcramov.data;
      if dci.dsuen = '1' then set := conv_integer(r.dsuset);
      else set := ddset; end if; 
    when dtag =>
        rdatav := dcramov.tag;
      if dci.dsuen = '1' then set := conv_integer(r.dsuset);
      else set := ddset; end if;

    when mmusnoop_dtag =>
      rdatav := dcramov.stag; 
      if dci.dsuen = '1' then set := conv_integer(r.dsuset);
      else set := ddset; end if; 
      
    when dctx =>
        --rdata(M_CTX_SZ-1 downto 0) := dcramov.dtramout(ddset).ctx;
    when icache => 
      rdatav(0) := ico.diagdata; set := 0;
    when ddata | memory =>
        if rdatasel = memory then
          rdatav(0) := mcdo.data; set := 0;
        else
          for i in 0 to DSETS-1 loop rdatav(i) := dcramov.data(i); end loop;
        end if;
    when sysr => 
      set := 0;
      case dci.maddress(3 downto 2) is
      when "00" =>
        rdatav(0)(30) := r.noflush;
        rdatav(0)(23) := r.cctrl.dsnoop;
        if dsnoop > 4 then rdatav(0)(17) := '1'; end if;
        rdatav(0)(16 downto 14) := r.cctrl.burst & ico.flush & r.flush;
        rdatav(0)(5 downto 0) := 
            r.cctrl.dfrz & r.cctrl.ifrz & r.cctrl.dcs & r.cctrl.ics;
      when "01" =>
        rdatav(0)(7 downto 0) := "00" & r.tadj & r.sadj & r.dadj;
      when "10" =>
        rdatav(0) := ico.cfg;
      when others =>
        rdatav(0) := cache_cfg(drepl, dsets, dlinesize, dsetsize, dsetlock, 
                dsnoop, DLRAM_EN, dlramsize, dlramstart, mmuen);
      end case;
    end case;

    
-- select which data to update the data cache with

      for i in 0 to DSETS-1 loop
        case size is            -- merge data during partial write
        when "00" =>
          case maddrlow is
          when "00" =>
            ddatainv(i) := edata(7 downto 0) & dcramov.data(i)(23 downto 0);
          when "01" =>
            ddatainv(i) := dcramov.data(i)(31 downto 24) & edata(7 downto 0) & 
                     dcramov.data(i)(15 downto 0);
          when "10" =>
            ddatainv(i) := dcramov.data(i)(31 downto 16) & edata(7 downto 0) & 
                     dcramov.data(i)(7 downto 0);
          when others =>
            ddatainv(i) := dcramov.data(i)(31 downto 8) & edata(7 downto 0);
          end case;
        when "01" =>
          if maddress(1) = '0' then
            ddatainv(i) := edata(15 downto 0) & dcramov.data(i)(15 downto 0);
          else
            ddatainv(i) := dcramov.data(i)(31 downto 16) & edata(15 downto 0);
          end if;
        when others => 
          ddatainv(i) := edata;
        end case;

      end loop;

    
-- handle double load with pipeline hold

    if (r.dstate = idle) and (r.nomds = '1') then
      rdatav(0) := r.wb.data2; mexc := r.mexc; set := 0;
    end if;

-- Handle AHB retry. Re-generate bus request and burst

    if mcdo.retry = '1' then
      v.req := '1';
      if r.wb.read = '0' then
        v.burst := r.wb.size(0) and r.wb.size(1) and not r.wb.addr(2);
      else
        v.burst := ((r.rburst) and not andv(r.wb.addr(LINE_HIGH downto LINE_LOW))) or
                (not r.rburst and r.wb.size(0) and r.wb.size(1) and not r.wb.addr(2));
      end if;
      v.wb.lock := r.wb.lock2;
    end if;

-- Generate new valid bits

    if r.flush = '1' then twrite := '0'; dwrite := '0'; end if;
    vmask := (others => (others => '1')); 
    if twrite = '1' then
      if tagclear = '1' then vmask := (others => (others => '0')); end if;
      if (DSETS>1) and (drepl = lru) and (tdiagwrite = '0') then
        vl.write := '1'; vl.set := setrepl;
      end if;
    end if;

    if (DSETS>1) and (drepl = lru) and (rl.write = '1') then
      vl.lru(conv_integer(rl.waddr)) :=
        lru_calc(rl.lru(conv_integer(rl.waddr)), rl.set);
    end if;

    if tdiagwrite = '1' then -- diagnostic tag write
      if (dsu = 1) and (dci.dsuen = '1') then
        vmask := (others => dci.maddress(dlinesize - 1 downto 0));
      else
        vmask := (others => dci.edata(dlinesize - 1 downto 0));
        newtag(TAG_HIGH downto TAG_LOW) := dci.edata(TAG_HIGH downto TAG_LOW);
        newptag(TAG_HIGH downto TAG_LOW) := dci.edata(TAG_HIGH downto TAG_LOW);
        for i in 0 to 3 loop wlrr(i)  := dci.edata(CTAG_LRRPOS); end loop;
        for i in 0 to DSETS-1 loop wlock(i) := dci.edata(CTAG_LOCKPOS); end loop;
      end if;
    end if;

    -- mmureg write
    if r.mmctrl1wr = '1' then
      case r.xaddress(CNR_U downto CNR_D) is
        when CNR_CTRL =>
          v.mmctrl1.e      := dci.maddress(MMCTRL_E);
          v.mmctrl1.nf     := dci.maddress(MMCTRL_NF);
          v.mmctrl1.pso    := dci.maddress(MMCTRL_PSO);
          v.mmctrl1.tlbdis := dci.maddress(MMCTRL_TLBDIS);
          v.mmctrl1.pagesize := dci.maddress(MMCTRL_PGSZ_U downto MMCTRL_PGSZ_D);
          --custom 
          -- Note: before tlb disable tlb flush is required !!!  
        when CNR_CTXP =>
          v.mmctrl1.ctxp := dci.maddress(MMCTXP_U downto MMCTXP_D);
        when CNR_CTX =>
          v.mmctrl1.ctx  := dci.maddress(MMCTXNR_U downto MMCTXNR_D);
        when CNR_F => null;
        when CNR_FADDR => null;
       when others => null;
      end case;
   end if;
    
-- cache flush

    if ((dci.flush or dci.flushl or flush) = '1') and (dcen /= 0) then
      v.flush := not r.noflush; v.faddr := (others => '0');
      if (dci.flushl = '1') then v.flush := '1'; v.faddr := r.efaddr; end if;
    end if;
    if eholdn = '1' then v.efaddr := v.xaddress(OFFSET_HIGH downto OFFSET_LOW); end if;

    if (r.flush = '1') and (dcen /= 0) then
      twrite := '1'; vmask := (others => (others => '0')); 
      v.faddr := r.faddr +1; newtag(TAG_HIGH downto TAG_LOW) := (others => '0');
      newptag := (others => '0');
      if DSNOOPSEP then flushaddr := r.faddr; end if;
      taddr(OFFSET_HIGH downto OFFSET_LOW) := r.faddr;
      wlrr := (others => '0');
      if ((r.faddr(DOFFSET_BITS -1) and not v.faddr(DOFFSET_BITS -1)) or r.flushl2) = '1' and (DSNOOP2/=3 or r.fflush='1')
      then
        v.flush := '0';
        v.fflush := '0';
      end if;
    end if;

    if DSNOOP2=3 and DCEN/=0 and r.fflush='0' and r.flush='1' and r.flush2='1' and dci.flush='0' and dci.flushl='0' then
      v.flush:='0';
      v.flush2:='0';
    end if;

-- update cache with memory data during read miss

    if read = '1' then
      for i in 0 to DSETS-1 loop
        ddatainv(i) := mcdo.data; 
      end loop;
    end if;

-- cache write signals

    if twrite = '1' then
      if tdiagwrite = '1' then ctwrite(ddset) := '1';
      else ctwrite(conv_integer(setrepl)) := '1'; end if;
    end if;
    if DSNOOPSEP then
      if tpwrite = '1' then
        if tdiagwrite = '1' then ctpwrite(ddset) := '1';
        else ctpwrite(conv_integer(setrepl)) := '1'; end if;
      end if;
    end if;
    if dwrite = '1' then
      if ddiagwrite = '1' then cdwrite(ddset) := '1';
      else cdwrite(conv_integer(setrepl)) := '1'; end if;
    end if;
      
    if (r.flush and twrite) = '1' then   -- flush 
      ctwrite := (others => '1'); wlrr := (others => '0'); wlock := (others => '0');
      if DSNOOPSEP then
        ctpwrite := (others => '1');
      end if;
    end if;

    csnoopwe := (others => '0'); flushl := '0';
    flushlv := (others => r.flush);
    if (snoopwe = '1') then csnoopwe := snhit; end if;
    if DSNOOPSEP then
      csnoopwe := csnoopwe or ctwrite;
      flushlv := flushlv or snhit; -- flush tag on snoop hit
    end if;

    if r.flush2 = '1' then
      vl.lru := (others => (others => '0'));
    end if;

    

    if dci.mmucacheclr='1' then
      v.cctrl.dcs := "00";
      v.cctrl.ics := "00";
      v.cctrl.burst := '0';
      v.mmctrl1.e := '0';
    end if;

-- reset

    if (not RESET_ALL) and (rst = '0') then 
      v.dstate := idle; v.stpend  := '0'; v.req := '0'; v.burst := '0';
      v.read := '0'; v.flush := '0'; v.nomds := '0'; v.holdn := '1';
      v.rndcnt := (others => '0'); v.setrepl := (others => '0');
      v.dsuset := (others => '0'); v.flush2 := '1'; v.fflush:='1';
      v.lrr := '0'; v.lock := '0'; v.ilramen := '0';
      v.cctrl.dcs := "00"; v.cctrl.ics := "00";
      v.cctrl.burst := '0'; v.cctrl.dsnoop := '0';
      v.tadj := (others => '0'); v.dadj := (others => '0');     
      v.sadj := (others => '0');
      --if M_EN then
        v.mmctrl1.e := '0'; v.mmctrl1.nf := '0'; v.mmctrl1.ctx := (others => '0');
        v.mmctrl1.tlbdis := '0';
        v.mmctrl1.pso := '0';
        v.trans_op := '0'; 
        v.flush_op := '0'; 
        v.diag_op := '0';
        v.pflush := '0';
        v.pflushr := '0';
        v.mmctrl1.pagesize := (others => '0');
      --end if;
      v.mmctrl1.bar := (others => '0');
      v.faddr := (others => '0');
      v.reqst := '0';
      v.cache := '0'; v.wb.lock := '0'; v.wb.lock2 := '0';
      v.wb.data1 := (others => '0'); v.wb.data2 := (others => '0');     
      v.noflush := '0'; v.mexc := '0';
    end if;

    if dsnoop = 0 then v.cctrl.dsnoop := '0'; end if;
    if not M_EN then v.mmctrl1 := mmctrl_type1_none; end if; -- kill MMU regs if not enabled

    -- Force cache control reg to off state if disabled
    if dcen=0 then v.cctrl.dcs := "00"; end if;
    if icen=0 then v.cctrl.ics := "00"; end if;

-- Drive signals
    c <= v; cs <= vs;   -- register inputs
    cl <= vl;

    
    -- tag ram inputs
    senable := senable and not scanen; enable := enable and not scanen;

    for i in 0 to DSETS-1 loop
      tag(i)(dlinesize-1 downto 0) := vmask(i);
      tag(i)(TAG_HIGH downto TAG_LOW) := newtag(TAG_HIGH downto TAG_LOW);
      tag(i)(CTAG_LRRPOS) := wlrr(i);
      tag(i)(CTAG_LOCKPOS) := wlock(i);
      ctx(i) := r.mmctrl1.ctx;
      ptag(i)(TAG_HIGH downto TAG_LOW) := newptag(TAG_HIGH downto TAG_LOW);
    end loop;
    dcrami.tag <= tag;          -- virtual tag
    dcrami.ptag <= ptag;        -- physical tag
    dcrami.ctx <= ctx;          -- context
    dcrami.tenable   <= enable;         -- virtual tag ram enable
    dcrami.twrite    <= ctwrite;        -- virtual tag ram write (port 1)
    dcrami.tpwrite   <= ctpwrite;       -- virtual tag ram write (port 2)
    dcrami.flush    <= flushlv;
    dcrami.flushc   <= r.flush;
    dcrami.flushl   <= flushl;
    dcrami.senable <= senable;          -- physical tag ram enable
    dcrami.swrite  <= csnoopwe;         -- physical tag ram write
    dcrami.saddress(19 downto (OFFSET_HIGH - OFFSET_LOW +1)) <= 
        zero32(19 downto (OFFSET_HIGH - OFFSET_LOW +1));
    dcrami.saddress(OFFSET_HIGH - OFFSET_LOW downto 0) <= snoopaddr;
    dcrami.faddress(19 downto (OFFSET_HIGH - OFFSET_LOW +1)) <= 
        zero32(19 downto (OFFSET_HIGH - OFFSET_LOW +1));
    dcrami.faddress(OFFSET_HIGH - OFFSET_LOW downto 0) <= flushaddr;
    dcrami.snhit <= rs.snhit;
    dcrami.snhitaddr(19 downto (OFFSET_HIGH - OFFSET_LOW +1)) <=
      zero32(19 downto (OFFSET_HIGH - OFFSET_LOW +1));
    dcrami.snhitaddr(OFFSET_HIGH - OFFSET_LOW downto 0) <= rs.addr(OFFSET_HIGH downto OFFSET_LOW);
    dcrami.flushall <= r.flush2;
    
    -- data ram inputs
    dcrami.denable   <= enable;
    dcrami.address(19 downto (OFFSET_HIGH - LINE_LOW + 1)) <= zero32(19 downto (OFFSET_HIGH - LINE_LOW + 1));
    dcrami.address(OFFSET_HIGH - LINE_LOW downto 0) <= taddr;
    dcrami.data <= ddatainv;
    dcrami.dwrite    <= cdwrite;
    dcrami.ldramin.address(23 downto 2) <= laddr(23 downto 2);
    dcrami.ldramin.enable <= (lramcs or lramwr);
    dcrami.ldramin.read   <= rlramrd;
    dcrami.ldramin.write  <= lramwr;


    -- memory controller inputs
    mcdi.address  <= r.wb.addr;
    mcdi.data     <= r.wb.data1;
    mcdi.burst    <= r.burst;
    mcdi.size     <= r.wb.size;
    mcdi.read     <= r.wb.read;
    mcdi.asi      <= r.wb.asi;
    mcdi.lock     <= r.wb.lock;
    mcdi.req      <= r.req;
    mcdi.cache    <= r.cache;

    -- diagnostic instruction cache access
    dco.icdiag.flush  <= iflush;
    dco.icdiag.pflush <= pflush;
    dco.icdiag.pflushaddr <= pflushaddr;
    dco.icdiag.pflushtyp <= pflushtyp;
    dco.icdiag.read   <= read;
    dco.icdiag.tag    <= not r.asi(0);
    dco.icdiag.ctx    <= r.asi(4); --ASI_ICTX "10101"
    dco.icdiag.addr   <= r.xaddress;
    dco.icdiag.enable <= r.icenable;
    dco.icdiag.ilramen <= r.ilramen;    
    dco.icdiag.cctrl <= r.cctrl;
    
 
    -- IU data cache inputs
    dco.data <= rdatav;
    dco.mexc <= mexc;
    dco.set  <= conv_std_logic_vector(set, 2);
    dco.hold <= r.holdn;
    dco.mds  <= mds;
    dco.werr <= mcdo.werr;
    dco.cache <= cache;
    dco.hit <= r.hit;
    if r.dstate = idle then dco.idle <= not r.stpend;
    else  dco.idle <= '0'; end if;
    dco.cstat.cmiss  <= r.cmiss;
    dco.cstat.chold  <= not r.holdn;
    dco.cstat.tmiss  <= mmudco.tlbmiss;
    dco.cstat.mhold  <= mhold;
    dco.wbhold  <= wbhold;
    
    -- MMU
    mmudci.trans_op <= mmudci_trans_op;    
    mmudci.transdata.data <= mmudci_transdata_data; --r.vaddr;
    mmudci.transdata.su <= mmudci_su;
    mmudci.transdata.read <= mmudci_read;
    mmudci.transdata.isid <= id_dcache;
    mmudci.transdata.wb_data <= dci.maddress;
    
    mmudci.flush_op <= mmudci_flush_op;
    mmudci.wb_op <= mmudci_wb_op;
    mmudci.diag_op <= mmudci_diag_op;
    mmudci.fsread <= mmudci_fsread;
    mmudci.mmctrl1 <= r.mmctrl1;

  end process;

-- Local registers

    reg1 : process(clk)
    begin
      if rising_edge(clk) then
        r <= c;
        if RESET_ALL and (rst = '0') then r <= RRES; end if;
      end if;
    end process;

    sn2 : if DSNOOP2 /= 0 generate
      reg2 : process(sclk)
      begin
        if rising_edge(sclk) then
          rs <= cs;
          if RESET_ALL and (rst = '0') then rs <= SRES; end if;
        end if;
      end process;
    end generate;

    nosn2 : if DSNOOP2 = 0 generate
      rs.snoop <= '0'; rs.addr <= (others => '0'); 
      rs.snhit <= (others => '0'); rs.mask <= (others => '0'); 
    end generate;

    reg2 : if (DSETS>1) and (drepl = lru) generate
      reg2 : process(clk)
      begin
        if rising_edge(clk) then
          rl <= cl;
          if RESET_ALL and (rst = '0') then rl <= LRES; end if;
        end if;
      end process;
    end generate;   

    noreg2 : if (DSETS = 1) or (drepl /= lru) generate
      rl.write <= '0'; rl.waddr <= (others => '0');
      rl.set <= (others => '0'); rl.lru <= (others => (others => '0'));
    end generate;   
    
-- pragma translate_off
  chk : process
  begin
    assert not ((DSETS > 2) and (drepl = lrr)) report
        "Wrong data cache configuration detected: LRR replacement requires 2 ways"
    severity failure;
    assert not ((DSETS = 3) and (drepl = dir)) report
        "Wrong data cache configuration detected: Direct replacement requires 2 or 4 ways"
    severity failure;
    wait;
  end process;
-- pragma translate_on

end ;

