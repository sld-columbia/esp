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
-- Entity:      iu3
-- File:        iu3.vhd
-- Author:      Jiri Gaisler, Edvin Catovic, Gaisler Research
-- Modified:    Magnus Hjorth, Cobham Gaisler (LEON-REX extension)
-- Description: LEON3 7-stage integer pipline
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_types.all;
use work.config.all;
use work.sparc.all;
use work.stdlib.all;
use work.gencomp.all;
use work.leon3.all;
use work.libiu.all;
use work.libfpu.all;
use work.arith.all;
use work.coretypes.all;
-- pragma translate_off
use work.sparc_disas.all;
-- pragma translate_on

entity iu3 is
  generic (
    nwin     : integer range 2 to 32 := 8;
    isets    : integer range 1 to 4 := 1;
    dsets    : integer range 1 to 4 := 1;
    fpu      : integer range 0 to 15 := 0;
    v8       : integer range 0 to 63 := 0;
    cp, mac  : integer range 0 to 1 := 0;
    dsu      : integer range 0 to 1 := 0;
    nwp      : integer range 0 to 4 := 0;
    pclow    : integer range 0 to 2 := 2;
    notag    : integer range 0 to 1 := 0;
    index    : integer range 0 to 15:= 0;
    lddel    : integer range 1 to 2 := 2;
    irfwt    : integer range 0 to 1 := 0;
    disas    : integer range 0 to 2 := 0;
    tbuf     : integer range 0 to 128 := 0;  -- trace buf size in kB (0 - no trace buffer)
    pwd      : integer range 0 to 2 := 0;   -- power-down
    svt      : integer range 0 to 1 := 0;   -- single-vector trapping
    rstaddr  : integer := 16#00000#;   -- reset vector MSB address
    smp      : integer range 0 to 15 := 0;  -- support SMP systems
    fabtech  : integer range 0 to NTECH := 0;    
    clk2x    : integer := 0;
    bp       : integer range 0 to 2 := 1;
    npasi    : integer range 0 to 1 := 0;
    pwrpsr   : integer range 0 to 1  := 0;
    rex      : integer range 0 to 1 := 0;
    altwin   : integer range 0 to 1 := 0
  );
  port (
    clk   : in  std_ulogic;
    rstn  : in  std_ulogic;
    cpuid : in  integer range 0 to 15:= 0;
    holdn : in  std_ulogic;
    ici   : out icache_in_type;
    ico   : in  icache_out_type;
    dci   : out dcache_in_type;
    dco   : in  dcache_out_type;
    rfi   : out iregfile_in_type;
    rfo   : in  iregfile_out_type;
    irqi  : in  l3_irq_in_type;
    irqo  : out l3_irq_out_type;
    dbgi  : in  l3_debug_in_type;
    dbgo  : out l3_debug_out_type;
    muli  : out mul32_in_type;
    mulo  : in  mul32_out_type;
    divi  : out div32_in_type;
    divo  : in  div32_out_type;
    fpo   : in  fpc_out_type;
    fpi   : out fpc_in_type;
    cpo   : in  fpc_out_type;
    cpi   : out fpc_in_type;
    tbo   : in  tracebuf_out_type;
    tbi   : out tracebuf_in_type;
    tbo_2p : in  tracebuf_2p_out_type;
    tbi_2p : out tracebuf_2p_in_type;
    sclk   : in  std_ulogic
    );


  attribute sync_set_reset of rstn : signal is "true"; 
end;

architecture rtl of iu3 is

  function get_tbuf(tracebuf_2p: boolean; tbuf: integer) return integer is 
  begin 
    if (TRACEBUF_2P) then 
        return(tbuf-64); 
    else 
        return(tbuf); 
    end if; 
  end function get_tbuf;
  
  constant ISETMSB : integer := log2x(isets)-1;
  constant DSETMSB : integer := log2x(dsets)-1;
  constant RFBITS : integer range 6 to 10 := log2(NWIN+1) + 4;
  constant NWINLOG2   : integer range 1 to 5 := log2(NWIN);
  constant CWPOPT : boolean := (NWIN = (2**NWINLOG2));
  constant CWPMIN : std_logic_vector(NWINLOG2-1 downto 0) := (others => '0');
  constant CWPMAX : std_logic_vector(NWINLOG2-1 downto 0) := 
        conv_std_logic_vector(NWIN-1, NWINLOG2);
  constant CWPGLB : std_logic_vector(NWINLOG2-1 downto 0) :=
        conv_std_logic_vector(NWIN, NWINLOG2);
  constant FPEN   : boolean := (fpu /= 0);
  constant CPEN   : boolean := (cp = 1);
  constant MULEN  : boolean := (v8 /= 0);
  constant MULTYPE: integer := (v8 / 16);
  constant DIVEN  : boolean := (v8 /= 0);
  constant MACEN  : boolean := (mac = 1);
  constant MACPIPE: boolean := (mac = 1) and (v8/2 = 1);
  constant IMPL   : integer := 15;
  constant VER    : integer := 3;
  constant DBGUNIT : boolean := (dsu = 1);
  constant TRACEBUF    : boolean := (tbuf /= 0);
  constant TRACEBUF_2P : boolean := (tbuf > 64);
  constant TBUFBITS : integer := 10 + log2(get_tbuf(TRACEBUF_2P, tbuf)) - 4;
  constant PWRD1  : boolean := false; --(pwd = 1) and not (index /= 0);
  constant PWRD2  : boolean := (pwd /= 0); --(pwd = 2) or (index /= 0);
  constant RS1OPT : boolean := (is_fpga(FABTECH) /= 0);
  constant DYNRST : boolean := (rstaddr = 16#FFFFF#);

  constant CASAEN : boolean := (notag = 0);
  signal BPRED : std_logic;
  signal BLOCKBPMISS: std_logic;
  constant REXPIPE : boolean := (REX=1) and (is_fpga(FABTECH)/=0);
  constant AWPEN : boolean := (altwin /= 0);
  constant RFPART : boolean := (altwin /= 0);

  subtype word is std_logic_vector(31 downto 0);
  subtype pctype is std_logic_vector(31 downto PCLOW);
  subtype rfatype is std_logic_vector(RFBITS-1 downto 0);
  subtype cwptype is std_logic_vector(NWINLOG2-1 downto 0);
  type icdtype is array (0 to isets-1) of word;
  type dcdtype is array (0 to dsets-1) of word;
  
  
  type dc_in_type is record
    signed, enaddr, read, write, lock, dsuen : std_ulogic;
    size : std_logic_vector(1 downto 0);
    asi  : std_logic_vector(7 downto 0);    
  end record;
  
  type pipeline_ctrl_type is record
    pc    : pctype;
    inst  : word;
    cnt   : std_logic_vector(1 downto 0);
    rd    : rfatype;
    tt    : std_logic_vector(5 downto 0);
    trap  : std_ulogic;
    annul : std_ulogic;
    wreg  : std_ulogic;
    wicc  : std_ulogic;
    wy    : std_ulogic;
    ld    : std_ulogic;
    pv    : std_ulogic;
    rett  : std_ulogic;
    itovr : std_ulogic;
  end record;
  
  type fetch_reg_type is record
    pc     : pctype;
    branch : std_ulogic;
  end record;
  
  type rex_pipeline_reg_type is record
    opout: std_logic_vector(31 downto 0);
    szout: std_logic_vector(1 downto 0);
    ncntout: std_logic_vector(0 downto 0);
    baddr1: std_ulogic;
    immexp: std_ulogic;
    immval: std_logic_vector(31 downto 13);
    getpc: std_ulogic;
    maskpv: std_ulogic;
    illinst: std_ulogic;
    nostep: std_ulogic;
    itovr: std_ulogic;
    leave: std_ulogic;
  end record;

  type decode_reg_type is record
    pc    : pctype;
    inst  : icdtype;
    cwp   : cwptype;
    awp   : cwptype;
    aw    : std_ulogic;
    paw   : std_ulogic;
    stwin : cwptype;
    cwpmax: cwptype;
    set   : std_logic_vector(ISETMSB downto 0);
    mexc  : std_ulogic;
    cnt   : std_logic_vector(1 downto 0);
    pv    : std_ulogic;
    annul : std_ulogic;
    inull : std_ulogic;
    step  : std_ulogic;
    divrdy: std_ulogic;
    pcheld: std_ulogic;
    rexen : std_ulogic;
    rexpos: std_logic_vector(1 downto 0);
    rexbuf: std_logic_vector(31 downto 0);
    rexcnt: std_logic_vector(0 downto 0);
    rexpl : rex_pipeline_reg_type;
  end record;
  
  type regacc_reg_type is record
    ctrl  : pipeline_ctrl_type;
    rs1   : std_logic_vector(4 downto 0);
    rfa1, rfa2 : rfatype;
    rsel1, rsel2 : std_logic_vector(2 downto 0);
    rfe1, rfe2 : std_ulogic;
    cwp   : cwptype;
    awp   : cwptype;
    aw    : std_ulogic;
    paw   : std_ulogic;
    imm   : word;
    ldcheck1 : std_ulogic;
    ldcheck2 : std_ulogic;
    ldchkra : std_ulogic;
    ldchkex : std_ulogic;
    su : std_ulogic;
    et : std_ulogic;
    wovf : std_ulogic;
    wunf : std_ulogic;
    ticc : std_ulogic;
    jmpl : std_ulogic;
    step  : std_ulogic;            
    mulstart : std_ulogic;            
    divstart : std_ulogic;
    bp, nobp : std_ulogic;
    bpimiss : std_ulogic;
    getpc : std_ulogic;
    decill: std_ulogic;
  end record;
  
  type execute_reg_type is record
    ctrl   : pipeline_ctrl_type;
    op1    : word;
    op2    : word;
    aluop  : std_logic_vector(2 downto 0);      -- Alu operation
    alusel : std_logic_vector(1 downto 0);      -- Alu result select
    aluadd : std_ulogic;
    alucin : std_ulogic;
    ldbp1, ldbp2 : std_ulogic;
    invop2 : std_ulogic;
    shcnt  : std_logic_vector(4 downto 0);      -- shift count
    sari   : std_ulogic;                                -- shift msb
    shleft : std_ulogic;                                -- shift left/right
    ymsb   : std_ulogic;                                -- shift left/right
    rd     : std_logic_vector(4 downto 0);
    jmpl   : std_ulogic;
    su     : std_ulogic;
    et     : std_ulogic;
    cwp    : cwptype;
    awp    : cwptype;
    aw     : std_ulogic;
    paw    : std_ulogic;
    icc    : std_logic_vector(3 downto 0);
    mulstep: std_ulogic;            
    mul    : std_ulogic;            
    mac    : std_ulogic;
    bp     : std_ulogic;
    rfe1, rfe2 : std_ulogic;
  end record;
  
  type memory_reg_type is record
    ctrl   : pipeline_ctrl_type;
    result : word;
    y      : word;
    icc    : std_logic_vector(3 downto 0);
    nalign : std_ulogic;
    dci    : dc_in_type;
    werr   : std_ulogic;
    wcwp   : std_ulogic;
    wawp   : std_ulogic;
    irqen  : std_ulogic;
    irqen2 : std_ulogic;
    mac    : std_ulogic;
    divz   : std_ulogic;
    su     : std_ulogic;
    mul    : std_ulogic;
    casa   : std_ulogic;
    casaz  : std_ulogic;
    rexnalign : std_ulogic;
  end record;
  
  type exception_state is (run, trap, dsu1, dsu2);
  
  type exception_reg_type is record
    ctrl   : pipeline_ctrl_type;
    result : word;
    y      : word;
    icc    : std_logic_vector( 3 downto 0);
    annul_all : std_ulogic;
    data   : dcdtype;
    set    : std_logic_vector(DSETMSB downto 0);
    mexc   : std_ulogic;
    dci    : dc_in_type;
    laddr  : std_logic_vector(1 downto 0);
    rstate : exception_state;
    npc    : std_logic_vector(2 downto 0);
    intack : std_ulogic;
    ipend  : std_ulogic;
    mac    : std_ulogic;
    debug  : std_ulogic;
    nerror : std_ulogic;
  end record;
  
  type dsu_registers is record
    tt      : std_logic_vector(7 downto 0);
    err     : std_ulogic;
    tbufcnt : std_logic_vector(TBUFBITS-1 downto 0);
    asi     : std_logic_vector(7 downto 0);
    crdy    : std_logic_vector(2 downto 1);  -- diag cache access ready
    tfilt   : std_logic_vector(3 downto 0);  -- trace filter
    cfc     : std_logic_vector(4 downto 0);  -- control-flow change
    tlim    : std_logic_vector(2 downto 0);
    tov     : std_ulogic;
    tovb    : std_ulogic;
  end record;
  
  type irestart_register is record
    addr   : pctype;
    pwd    : std_ulogic;
  end record;
  
 
  type pwd_register_type is record
    pwd    : std_ulogic;
    error  : std_ulogic;
  end record;

  type special_register_type is record
    cwp    : cwptype;                                -- current window pointer
    icc    : std_logic_vector(3 downto 0);        -- integer condition codes
    tt     : std_logic_vector(7 downto 0);        -- trap type
    tba    : std_logic_vector(19 downto 0);       -- trap base address
    wim    : std_logic_vector(NWIN-1 downto 0);       -- window invalid mask
    pil    : std_logic_vector(3 downto 0);        -- processor interrupt level
    ec     : std_ulogic;                                  -- enable CP 
    ef     : std_ulogic;                                  -- enable FP 
    ps     : std_ulogic;                                  -- previous supervisor flag
    s      : std_ulogic;                                  -- supervisor flag
    et     : std_ulogic;                                  -- enable traps
    y      : word;
    asr18  : word;
    svt    : std_ulogic;                                  -- enable traps
    dwt    : std_ulogic;                           -- disable write error trap
    dbp    : std_ulogic;                           -- disable branch prediction
    dbprepl: std_ulogic;                -- Disable speculative Icache miss/replacement
    rexdis : std_ulogic;                -- allow entering REX mode
    rextrap: std_ulogic;                -- trap on saverex/addrex instructions
    aw     : std_ulogic;                -- use alternative window pointer
    paw    : std_ulogic;                -- previous aw (for trap handler)
    awp    : cwptype;                   -- alternative window pointer
    stwin  : cwptype;                   -- starting window
    cwpmax : cwptype;                   -- max cwp value
  end record;
  
  type write_reg_type is record
    s      : special_register_type;
    result : word;
    wa     : rfatype;
    wreg   : std_ulogic;
    except : std_ulogic;
    twcwp  : cwptype;                   -- trap wrap CWP (for regfile partitioning)
  end record;

  type registers is record
    f  : fetch_reg_type;
    d  : decode_reg_type;
    a  : regacc_reg_type;
    e  : execute_reg_type;
    m  : memory_reg_type;
    x  : exception_reg_type;
    w  : write_reg_type;
  end record;

  type exception_type is record
    pri   : std_ulogic;
    ill   : std_ulogic;
    fpdis : std_ulogic;
    cpdis : std_ulogic;
    wovf  : std_ulogic;
    wunf  : std_ulogic;
    ticc  : std_ulogic;
  end record;

  type watchpoint_register is record
    addr    : std_logic_vector(31 downto 2);  -- watchpoint address
    mask    : std_logic_vector(31 downto 2);  -- watchpoint mask
    exec    : std_ulogic;                           -- trap on instruction
    load    : std_ulogic;                           -- trap on load
    store   : std_ulogic;                           -- trap on store
  end record;

  type watchpoint_registers is array (0 to 3) of watchpoint_register;

  function dbgexc(
    r     : registers; dbgi : l3_debug_in_type;
    trap  : std_ulogic;
    tt    : std_logic_vector(7 downto 0);
    dsur  : dsu_registers) return std_ulogic is
    variable dmode : std_ulogic;
  begin
    dmode := '0';
    if (not r.x.ctrl.annul and trap) = '1' then
      if (((tt = "00" & TT_WATCH) and (dbgi.bwatch = '1')) or
          ((dbgi.bsoft = '1') and (tt = "10000001")) or
          (dbgi.btrapa = '1') or
          ((dbgi.btrape = '1') and not ((tt(5 downto 0) = TT_PRIV) or 
            (tt(5 downto 0) = TT_FPDIS) or (tt(5 downto 0) = TT_WINOF) or
            (tt(5 downto 0) = TT_WINUF) or (tt(5 downto 4) = "01") or (tt(7) = '1'))) or 
          (((not r.w.s.et) and dbgi.berror) = '1')) then
        dmode := '1';
      end if;
    end if;
    return(dmode);
  end;
                    
  function dbgerr(r : registers; dbgi : l3_debug_in_type;
                  tt : std_logic_vector(7 downto 0))
  return std_ulogic is
    variable err : std_ulogic;
  begin
    err := not r.w.s.et;
    if (((dbgi.dbreak = '1') and (tt = ("00" & TT_WATCH))) or
        ((dbgi.bsoft = '1') and (tt = ("10000001")))) then
      err := '0';
    end if;
    return(err);
  end;


  procedure diagwr(r    : in registers;
                   dsur : in dsu_registers;
                   ir   : in irestart_register;
                   dbg  : in l3_debug_in_type;
                   wpr  : in watchpoint_registers;
                   s    : out special_register_type;
                   vwpr : out watchpoint_registers;
                   asi : out std_logic_vector(7 downto 0);
                   pc, npc  : out pctype;
                   tbufcnt : out std_logic_vector(TBUFBITS-1 downto 0);
                   tfilt : out std_logic_vector(3 downto 0);
                   wr : out std_ulogic;
                   addr : out std_logic_vector(9 downto 0);
                   data : out word;
                   fpcwr : out std_ulogic) is
  variable i : integer range 0 to 3;
  begin
    s := r.w.s; pc := r.f.pc; npc := ir.addr; wr := '0';
    vwpr := wpr; asi := dsur.asi; addr := (others => '0');
    data := dbg.ddata;
    tbufcnt := dsur.tbufcnt; fpcwr := '0'; tfilt := dsur.tfilt; 
      if (dbg.dsuen and dbg.denable and dbg.dwrite) = '1' then
        case dbg.daddr(23 downto 20) is
          when "0001" =>
            if (dbg.daddr(16) = '1' and dbg.daddr(2) = '0' ) and TRACEBUF then -- trace buffer control reg
              tbufcnt := dbg.ddata(TBUFBITS-1 downto 0);
              tfilt   := dbg.ddata(31 downto 28);
            end if;
          when "0011" => -- IU reg file
            if dbg.daddr(12) = '0' then
              wr := '1';
              addr := (others => '0');
              addr(RFBITS-1 downto 0) := dbg.daddr(RFBITS+1 downto 2);
            else  -- FPC
              fpcwr := '1';
            end if;
          when "0100" => -- IU special registers
            case dbg.daddr(7 downto 6) is
              when "00" => -- IU regs Y - TBUF ctrl reg
                case dbg.daddr(5 downto 2) is
                  when "0000" => -- Y
                    s.y := dbg.ddata;
                  when "0001" => -- PSR
                    s.cwp := dbg.ddata(NWINLOG2-1 downto 0);
                    s.icc := dbg.ddata(23 downto 20);
                    s.ec  := dbg.ddata(13);
                    if FPEN then s.ef := dbg.ddata(12); end if;
                    s.pil := dbg.ddata(11 downto 8);
                    s.s   := dbg.ddata(7);
                    s.ps  := dbg.ddata(6);
                    s.et  := dbg.ddata(5);
                    if AWPEN then
                      s.aw := dbg.ddata(15);
                      s.paw := dbg.ddata(14);
                    end if;
                  when "0010" => -- WIM
                    s.wim := dbg.ddata(NWIN-1 downto 0);
                  when "0011" => -- TBR
                    s.tba := dbg.ddata(31 downto 12);
                    s.tt  := dbg.ddata(11 downto 4);
                  when "0100" => -- PC
                    pc := dbg.ddata(31 downto PCLOW);
                  when "0101" => -- NPC
                    npc := dbg.ddata(31 downto PCLOW);
                  when "0110" => --FSR
                    fpcwr := '1';
                  when "0111" => --CFSR
                  when "1001" => -- ASI reg
                    asi := dbg.ddata(7 downto 0);
                  when others =>
                end case;
              when "01" => -- ASR16 - ASR31
                case dbg.daddr(5 downto 2) is
                when "0001" =>  -- %ASR17
                  if bp = 2 then s.dbp := dbg.ddata(27); end if;
                  if bp = 2 then s.dbprepl := dbg.ddata(25); end if;
                  if rex=1 then
                    s.rexdis := dbg.ddata(22);
                    s.rextrap := dbg.ddata(21);
                  end if;
                  s.dwt := dbg.ddata(14);
                  s.svt := dbg.ddata(13);
                when "0010" =>  -- %ASR18
                  if MACEN then s.asr18 := dbg.ddata; end if;
                when "0100" =>  -- %ASR20
                  if AWPEN then
                    s.awp := dbg.ddata(NWINLOG2-1 downto 0);
                  end if;
                  if RFPART then
                    if dbg.ddata(15+NWINLOG2 downto 16) /= CWPMIN then
                      s.stwin := dbg.ddata(20+NWINLOG2 downto 21);
                      s.cwpmax := dbg.ddata(15+NWINLOG2 downto 16);
                    end if;
                  end if;
                when "1000" =>          -- %ASR24 - %ASR31
                  vwpr(0).addr := dbg.ddata(31 downto 2);
                  vwpr(0).exec := dbg.ddata(0); 
                when "1001" =>
                  vwpr(0).mask := dbg.ddata(31 downto 2);
                  vwpr(0).load := dbg.ddata(1);
                  vwpr(0).store := dbg.ddata(0);              
                when "1010" =>
                  vwpr(1).addr := dbg.ddata(31 downto 2);
                  vwpr(1).exec := dbg.ddata(0); 
                when "1011" =>
                  vwpr(1).mask := dbg.ddata(31 downto 2);
                  vwpr(1).load := dbg.ddata(1);
                  vwpr(1).store := dbg.ddata(0);              
                when "1100" =>
                  vwpr(2).addr := dbg.ddata(31 downto 2);
                  vwpr(2).exec := dbg.ddata(0); 
                when "1101" =>
                  vwpr(2).mask := dbg.ddata(31 downto 2);
                  vwpr(2).load := dbg.ddata(1);
                  vwpr(2).store := dbg.ddata(0);              
                when "1110" =>
                  vwpr(3).addr := dbg.ddata(31 downto 2);
                  vwpr(3).exec := dbg.ddata(0); 
                when "1111" => -- 
                  vwpr(3).mask := dbg.ddata(31 downto 2);
                  vwpr(3).load := dbg.ddata(1);
                  vwpr(3).store := dbg.ddata(0);              
                when others => -- 
                end case;
-- disabled due to bug in XST
--                  i := conv_integer(dbg.daddr(4 downto 3)); 
--                  if dbg.daddr(2) = '0' then
--                    vwpr(i).addr := dbg.ddata(31 downto 2);
--                    vwpr(i).exec := dbg.ddata(0); 
--                  else
--                    vwpr(i).mask := dbg.ddata(31 downto 2);
--                    vwpr(i).load := dbg.ddata(1);
--                    vwpr(i).store := dbg.ddata(0);              
--                  end if;                    
              when others =>
            end case;
          when others =>
        end case;
      end if;
  end;

  function asr17_gen (
    r : in registers;
    core_id : in integer range 0 to 15)
    return word is
  variable asr17 : word;
  variable fpu2 : integer range 0 to 3;
  begin
    asr17 := zero32;
    asr17(31 downto 28) := conv_std_logic_vector(core_id, 4);
    if bp = 2 then asr17(27) := r.w.s.dbp; end if;
    if notag = 0 then asr17(26) := '1'; end if; -- CASA and tagged arith
    if bp = 2 then asr17(25) := r.w.s.dbprepl;
    elsif bp = 1 then asr17(25) := '1'; end if;
    if rex=1 then
      asr17(24 downto 23) := "01";
      asr17(22) := r.w.s.rexdis;
      asr17(21) := r.w.s.rextrap;
    else
      asr17(24 downto 23) := "00";
    end if;
    if (clk2x > 8) then
      asr17(16 downto 15) := conv_std_logic_vector(clk2x-8, 2);
      asr17(17) := '1'; 
    elsif (clk2x > 0) then
      asr17(16 downto 15) := conv_std_logic_vector(clk2x, 2);
    end if;
    asr17(14) := r.w.s.dwt;
    if svt = 1 then asr17(13) := r.w.s.svt; end if;
    if lddel = 2 then asr17(12) := '1'; end if;
    if (fpu > 0) and (fpu < 8) then fpu2 := 1;
    elsif (fpu >= 8) and (fpu < 15) then fpu2 := 3;
    elsif fpu = 15 then fpu2 := 2;
    else fpu2 := 0; end if;
    asr17(11 downto 10) := conv_std_logic_vector(fpu2, 2);                       
    if mac = 1 then asr17(9) := '1'; end if;
    if v8 /= 0 then asr17(8) := '1'; end if;
    asr17(7 downto 5) := conv_std_logic_vector(nwp, 3);                       
    asr17(4 downto 0) := conv_std_logic_vector(nwin-1, 5);       
    return(asr17);
  end;

  procedure diagread(dbgi   : in l3_debug_in_type;
                     r      : in registers;
                     dsur   : in dsu_registers;
                     ir     : in irestart_register;
                     wpr    : in watchpoint_registers;
                     dco    : in  dcache_out_type;                          
                     tbufo  : in tracebuf_out_type;
                     tbufo_2p : in tracebuf_2p_out_type;
                     xc_wimmask: in std_logic_vector;
                     core_id : in integer range 0 to 15;
                     data : out word) is
    variable cwp : std_logic_vector(4 downto 0);
    variable rd : std_logic_vector(4 downto 0);
    variable i : integer range 0 to 3;    
  begin
    data := (others => '0'); cwp := (others => '0');
    cwp(NWINLOG2-1 downto 0) := r.w.s.cwp;
      case dbgi.daddr(22 downto 20) is
        when "001" => -- trace buffer
          if TRACEBUF then
            if dbgi.daddr(16) = '1' then -- trace buffer control reg
              if dbgi.daddr(2) = '0' then
                data(TBUFBITS-1 downto 0) := dsur.tbufcnt;
                data(31 downto 28) := dsur.tfilt;
              else
                data(23) := dsur.tov;
                data(26 downto 24) := dsur.tlim;
                data(27) := dsur.tovb;
              end if;
            else
              if TRACEBUF_2P then
                case dbgi.daddr(3 downto 2) is
                when "00" => data := tbufo_2p.data(127 downto 96);
                when "01" => data := tbufo_2p.data(95 downto 64);
                when "10" => data := tbufo_2p.data(63 downto 32);
                when others => data := tbufo_2p.data(31 downto 0);
                end case;
              else
                case dbgi.daddr(3 downto 2) is
                when "00" => data := tbufo.data(127 downto 96);
                when "01" => data := tbufo.data(95 downto 64);
                when "10" => data := tbufo.data(63 downto 32);
                when others => data := tbufo.data(31 downto 0);
                end case;
              end if;
            end if;
          end if;
        when "011" => -- IU reg file
          if dbgi.daddr(12) = '0' then
            if dbgi.daddr(11) = '0' then
                data := rfo.data1(31 downto 0);
              else data := rfo.data2(31 downto 0); end if;
          else
              data := fpo.dbg.data;
          end if;
        when "100" => -- IU regs
          case dbgi.daddr(7 downto 6) is
            when "00" => -- IU regs Y - TBUF ctrl reg
              case dbgi.daddr(5 downto 2) is
                when "0000" =>
                  data := r.w.s.y;
                when "0001" =>
                  data := conv_std_logic_vector(IMPL, 4) & conv_std_logic_vector(VER, 4) &
                          r.w.s.icc & "000000" & r.w.s.ec & r.w.s.ef & r.w.s.pil &
                          r.w.s.s & r.w.s.ps & r.w.s.et & cwp;
                  if AWPEN then
                    data(15) := r.w.s.aw;
                    data(14) := r.w.s.paw;
                  end if;
                when "0010" =>
                  data(NWIN-1 downto 0) := r.w.s.wim;
                  if RFPART then data(NWIN-1 downto 0) := r.w.s.wim and not xc_wimmask; end if;
                when "0011" =>
                  data := r.w.s.tba & r.w.s.tt & "0000";
                when "0100" =>
                  data(31 downto PCLOW) := r.f.pc;
                when "0101" =>
                  data(31 downto PCLOW) := ir.addr;
                when "0110" => -- FSR
                  data := fpo.dbg.data;
                when "0111" => -- CPSR
                when "1000" => -- TT reg
                  data(12 downto 4) := dsur.err & dsur.tt;
                when "1001" => -- ASI reg
                  data(7 downto 0) := dsur.asi;
                when others =>
              end case;
            when "01" =>
              if dbgi.daddr(5) = '0' then 
                if dbgi.daddr(4 downto 2) = "001" then -- %ASR17
                  data := asr17_gen(r, core_id);
                elsif MACEN and  dbgi.daddr(4 downto 2) = "010" then -- %ASR18
                  data := r.w.s.asr18;
                elsif (AWPEN or RFPART) and dbgi.daddr(4 downto 2) = "100" then  -- %ASR20
                  if AWPEN then
                    data(NWINLOG2-1 downto 0) := r.w.s.awp;
                  end if;
                  if RFPART then
                    data(15+NWINLOG2 downto 16) := r.w.s.cwpmax;
                    data(20+NWINLOG2 downto 21) := r.w.s.stwin;
                  end if;
                end if;
              else  -- %ASR24 - %ASR31
                i := conv_integer(dbgi.daddr(4 downto 3));                                           -- 
                if dbgi.daddr(2) = '0' then
                  data(31 downto 2) := wpr(i).addr;
                  data(0) := wpr(i).exec;
                else
                  data(31 downto 2) := wpr(i).mask;
                  data(1) := wpr(i).load;
                  data(0) := wpr(i).store; 
                end if;
              end if;
            when others =>
          end case;
        when "111" =>
          data := r.x.data(conv_integer(r.x.set));
        when others =>
      end case;
  end;
  
  function itfilt (inst : word; filter : std_logic_vector(3 downto 0); trap, cfc : std_logic) return std_ulogic is
  variable tren : std_ulogic;
  begin
    tren := '0';
    case filter is
    when "0001" => 	-- Bicc, SETHI
      if inst(31 downto 30) = "00" then tren := '1'; end if;
    when "0010" => 	-- Control-flow change
      if (inst(31 downto 30) = "01") -- Call
      or ((inst(31 downto 30) = "00") and (inst(23 downto 22) /= "00")) --Bicc
      or ((inst(31 downto 30) = "10") and (inst(24 downto 19) = JMPL)) --Jmpl
      or ((inst(31 downto 30) = "10") and (inst(24 downto 19) = RETT)) --Rett
      or (trap = '1') or (cfc = '1')
      then tren := '1'; end if;
    when "0100" => 	-- Call
      if inst(31 downto 30) = "01" then tren := '1'; end if;
    when "1000" => 	-- Normal instructions
      if inst(31 downto 30) = "10" then tren := '1'; end if;
    when "1100" => 	-- LDST
      if inst(31 downto 30) = "11" then tren := '1'; end if;
    when "1101" =>      -- LDST from alternate space
      if inst(31 downto 30) = "11" and inst(24 downto 23) = "01" then tren := '1'; end if;
    when "1110" =>      -- LDST from alternate space 0x80 - 0xFF
      if inst(31 downto 30) = "11" and inst(24 downto 23) = "01" and inst(12) = '1' then tren := '1'; end if;
    when others => tren := '1';
    end case;
    return(tren);
  end;

  procedure itrace(r        : in registers;
                   dsur     : in dsu_registers;
                   vdsu     : in dsu_registers;
                   res      : in word;
                   exc      : in std_ulogic;
                   dbgi     : in l3_debug_in_type;
                   error    : in std_ulogic;
                   trap     : in std_ulogic;                          
                   tbufcnt  : out std_logic_vector(TBUFBITS-1 downto 0); 
                   ov       : out std_ulogic;
                   di       : out tracebuf_in_type;
                   di_2p    : out tracebuf_2p_in_type;
                   ierr     : in std_ulogic;
                   derr     : in std_ulogic
                   ) is
  variable meminst : std_ulogic;
  variable tfen    : std_ulogic;
  variable vdi_2p  : tracebuf_2p_in_type;
  variable vdi     : tracebuf_in_type;
  variable indata  : std_logic_vector(255 downto 0);
  variable write   : std_logic_vector(7 downto 0);
  variable tov     : std_ulogic;
  begin
    vdi_2p := tracebuf_2p_in_type_none;
    vdi    := tracebuf_in_type_none;
    indata := (others => '0');
    write  := (others => '0');
    tbufcnt := vdsu.tbufcnt;
    meminst := r.x.ctrl.inst(31) and r.x.ctrl.inst(30);
    tov    := vdsu.tov;
    if TRACEBUF then
      if dbgi.tenable = '1' then
        if dsur.tbufcnt(TBUFBITS-1 downto TBUFBITS-3) = dsur.tlim(2 downto 0) then
          tov := '1';
        end if;
      end if;
      indata(127) := tov;
      indata(126) := not r.x.ctrl.pv;
      indata(125 downto 96) := dbgi.timer(29 downto 0);
      if REX=1 then
        indata(125) := r.x.ctrl.pc(2-2*REX);
        indata(124) := r.x.ctrl.pc(2-1*REX);
      end if;
      indata(95 downto 64) := res;
      indata(63 downto 34) := r.x.ctrl.pc(31 downto 2);
      indata(33) := trap;
      indata(32) := error;
      indata(31 downto 0) := r.x.ctrl.inst;
      vdi.addr(TBUFBITS-1 downto 0) := dsur.tbufcnt;
      vdi.data := indata;
      if (dbgi.tenable = '0') or (r.x.rstate = dsu2) then
        if ((dbgi.dsuen and dbgi.denable) = '1') and (dbgi.daddr(23 downto 20) & dbgi.daddr(16) = "00010") then
          vdi.enable := '1'; 
          vdi.addr(TBUFBITS-1 downto 0) := dbgi.daddr(TBUFBITS-1+4 downto 4);
          vdi_2p.renable := '1';
          vdi_2p.raddr(TBUFBITS-1 downto 0) := dbgi.daddr(TBUFBITS-1+4 downto 4);
          if dbgi.dwrite = '1' then            
            case dbgi.daddr(3 downto 2) is
              when "00" => write(3) := '1';
              when "01" => write(2) := '1';
              when "10" => write(1) := '1';
              when others => write(0) := '1';
            end case;
            indata(127 downto 0) := dbgi.ddata & dbgi.ddata & dbgi.ddata & dbgi.ddata;
            vdi.write   := write;
            vdi.data    := indata;
            vdi_2p.renable  := '0';
            vdi_2p.write    := write;
            vdi_2p.waddr(TBUFBITS-1 downto 0) := dbgi.daddr(TBUFBITS-1+4 downto 4);
            vdi_2p.data     := indata;
          end if;
        end if;
      elsif (not r.x.ctrl.annul and (r.x.ctrl.pv or meminst or r.x.ctrl.itovr) and not r.x.debug and
              itfilt(r.x.ctrl.inst, dsur.tfilt, trap, dsur.cfc(4))) = '1' then
        vdi.enable      := holdn;
        vdi.write       := (others => '1');
        vdi_2p.write    := (others => '1');
        vdi_2p.waddr(TBUFBITS-1 downto 0) := dsur.tbufcnt;
        vdi_2p.data     := indata;
        tbufcnt := dsur.tbufcnt + 1;
      end if;
      if TRACEBUF_2P and ((dbgi.dsuen and dbgi.denable) = '1') and (dbgi.daddr(23 downto 20) & dbgi.daddr(16) = "00010") then
        vdi_2p.renable := '1';
        vdi_2p.raddr(TBUFBITS-1 downto 0) := dbgi.daddr(TBUFBITS-1+4 downto 4);
      end if;
    end if;
    ov    := tov;
    di    := vdi;
    di_2p := vdi_2p;
  end;

  procedure dbg_cache(holdn    : in std_ulogic;
                      dbgi     :  in l3_debug_in_type;
                      r        : in registers;
                      dsur     : in dsu_registers;
                      mresult  : in word;
                      dci      : in dc_in_type;
                      mresult2 : out word;
                      dci2     : out dc_in_type
                      ) is
  begin
    mresult2 := mresult; dci2 := dci; dci2.dsuen := '0'; 
    if DBGUNIT then
      if (r.x.rstate = dsu2)
      then
        dci2.asi := dsur.asi;
        if (dbgi.daddr(22 downto 20) = "111") and (dbgi.dsuen = '1') then
          dci2.dsuen := (dbgi.denable or r.m.dci.dsuen) and not dsur.crdy(2);
          dci2.enaddr := dbgi.denable;
          dci2.size := "10"; dci2.read := '1'; dci2.write := '0';
          if (dbgi.denable and not r.m.dci.enaddr) = '1' then            
            mresult2 := (others => '0'); mresult2(19 downto 2) := dbgi.daddr(19 downto 2);
          else
            mresult2 := dbgi.ddata;            
          end if;
          if dbgi.dwrite = '1' then
            dci2.read := '0'; dci2.write := '1';
          end if;
        end if;
      end if;
    end if;
  end;
    
  procedure fpexack(r : in registers; fpexc : out std_ulogic) is
  begin
    fpexc := '0';
    if FPEN then 
      if r.x.ctrl.tt = TT_FPEXC then fpexc := '1'; end if;
    end if;
  end;

  procedure diagrdy(denable : in std_ulogic;
                    dsur : in dsu_registers;
                    dci   : in dc_in_type;
                    mds : in std_ulogic;
                    ico : in icache_out_type;
                    crdy : out std_logic_vector(2 downto 1)) is                   
  begin
    crdy := dsur.crdy(1) & '0';    
    if dci.dsuen = '1' then
      case dsur.asi(4 downto 0) is
        when ASI_ITAG | ASI_IDATA | ASI_UINST | ASI_SINST =>
          crdy(2) := ico.diagrdy and not dsur.crdy(2);
        when ASI_DTAG | ASI_MMUSNOOP_DTAG | ASI_DDATA | ASI_UDATA | ASI_SDATA =>
          crdy(1) := not denable and dci.enaddr and not dsur.crdy(1);
        when others =>
          crdy(2) := dci.enaddr and denable;
      end case;
    end if;
  end;


  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
  constant dc_in_res : dc_in_type := (
    signed => '0',
    enaddr => '0',
    read   => '0',
    write  => '0',
    lock   => '0',
    dsuen  => '0',
    size   => (others => '0'),
    asi    => (others => '0'));
  constant pipeline_ctrl_res :  pipeline_ctrl_type := (
    pc    => (others => '0'),
    inst  => (others => '0'),
    cnt   => (others => '0'),
    rd    => (others => '0'),
    tt    => (others => '0'),
    trap  => '0',
    annul => '1',
    wreg  => '0',
    wicc  => '0',
    wy    => '0',
    ld    => '0',
    pv    => '0',
    rett  => '0',
    itovr => '0');
  constant fpc_res : pctype := conv_std_logic_vector(rstaddr, 20) & zero32(11 downto PCLOW);
  
  constant fetch_reg_res : fetch_reg_type := (
    pc     => fpc_res,  -- Needs special handling
    branch => '0'
    );
  constant decode_reg_res : decode_reg_type := (
    pc     => (others => '0'),
    inst   => (others => (others => '0')),
    cwp    => (others => '0'),
    awp    => (others => '0'),
    aw     => '0',
    paw    => '0',
    stwin  => (others => '0'),
    cwpmax => CWPMAX,
    set    => (others => '0'),
    mexc   => '0',
    cnt    => (others => '0'),
    pv     => '0',
    annul  => '1',
    inull  => '0',
    step   => '0',
    divrdy => '0',
    pcheld => '0',
    rexen  => '0',
    rexpos => "10",
    rexbuf => (others => '0'),
    rexcnt => (others => '0'),
    rexpl => ((others => '0'),"00","0",'0','0',(others => '0'),'0','0','0','0','0','0')
    );
  constant regacc_reg_res : regacc_reg_type := (
    ctrl     => pipeline_ctrl_res,
    rs1      => (others => '0'),
    rfa1     => (others => '0'),
    rfa2     => (others => '0'),
    rsel1    => (others => '0'),
    rsel2    => (others => '0'),
    rfe1     => '0',
    rfe2     => '0',
    cwp      => (others => '0'),
    awp      => (others => '0'),
    aw       => '0',
    paw      => '0',
    imm      => (others => '0'),
    ldcheck1 => '0',
    ldcheck2 => '0',
    ldchkra  => '1',
    ldchkex  => '1',
    su       => '1',
    et       => '0',
    wovf     => '0',
    wunf     => '0',
    ticc     => '0',
    jmpl     => '0',
    step     => '0',
    mulstart => '0',
    divstart => '0',
    bp       => '0',
    nobp     => '0',
    bpimiss  => '0',
    getpc    => '0',
    decill   => '0'
    );
  constant execute_reg_res : execute_reg_type := (
    ctrl    =>  pipeline_ctrl_res,
    op1     => (others => '0'),
    op2     => (others => '0'),
    aluop   => (others => '0'),
    alusel  => "11",
    aluadd  => '1',
    alucin  => '0',
    ldbp1   => '0',
    ldbp2   => '0',
    invop2  => '0',
    shcnt   => (others => '0'),
    sari    => '0',
    shleft  => '0',
    ymsb    => '0',
    rd      => (others => '0'),
    jmpl    => '0',
    su      => '0',
    et      => '0',
    cwp     => (others => '0'),
    awp      => (others => '0'),
    aw       => '0',
    paw      => '0',
    icc     => (others => '0'),
    mulstep => '0',
    mul     => '0',
    mac     => '0',
    bp      => '0',
    rfe1    => '0',
    rfe2    => '0'
    );
  constant memory_reg_res : memory_reg_type := (
    ctrl   => pipeline_ctrl_res,
    result => (others => '0'),
    y      => (others => '0'),
    icc    => (others => '0'),
    nalign => '0',
    dci    => dc_in_res,
    werr   => '0',
    wcwp   => '0',
    wawp   => '0',
    irqen  => '0',
    irqen2 => '0',
    mac    => '0',
    divz   => '0',
    su     => '0',
    mul    => '0',
    casa   => '0',
    casaz  => '0',
    rexnalign => '0'
    );
  function xnpc_res return std_logic_vector is
  begin
    if v8 /= 0 then return "100"; end if;
    return "011";
  end function xnpc_res;
  constant exception_reg_res : exception_reg_type := (
    ctrl      => pipeline_ctrl_res,
    result    => (others => '0'),
    y         => (others => '0'),
    icc       => (others => '0'),
    annul_all => '1',
    data      => (others => (others => '0')),
    set       => (others => '0'),
    mexc      => '0',
    dci       => dc_in_res,
    laddr     => (others => '0'),
    rstate    => run,                   -- Has special handling
    npc       => xnpc_res,
    intack    => '0',
    ipend     => '0',
    mac       => '0',
    debug     => '0',                   -- Has special handling
    nerror    => '0'
    );
  constant DRES : dsu_registers := (
    tt      => (others => '0'),
    err     => '0',
    tbufcnt => (others => '0'),
    asi     => (others => '0'),
    crdy    => (others => '0'),
    tfilt => (others => '0'),
    cfc => (others => '0'),
    tlim => (others => '0'),
    tov => '0',
    tovb => '0'
    );
  constant IRES : irestart_register := (
    addr => (others => '0'), pwd => '0'
    );
  constant PRES : pwd_register_type := (
    pwd => '0',                         -- Needs special handling
    error => '0'
    );
  --constant special_register_res : special_register_type := (
  --  cwp    => zero32(NWINLOG2-1 downto 0),
  --  icc    => (others => '0'),
  --  tt     => (others => '0'),
  --  tba    => fpc_res(31 downto 12),
  --  wim    => (others => '0'),
  --  pil    => (others => '0'),
  --  ec     => '0',
  --  ef     => '0',
  --  ps     => '1',
  --  s      => '1',
  --  et     => '0',
  --  y      => (others => '0'),
  --  asr18  => (others => '0'),
  --  svt    => '0',
  --  dwt    => '0',
  --  dbp    => '0'
  --  );
  --XST workaround:
  function special_register_res return special_register_type is
    variable s : special_register_type;
  begin
    s.cwp   := zero32(NWINLOG2-1 downto 0);
    s.icc   := (others => '0');
    s.tt    := (others => '0');
    s.tba   := fpc_res(31 downto 12);
    s.wim   := (others => '0');
    s.pil   := (others => '0');
    s.ec    := '0';
    s.ef    := '0';
    s.ps    := '1';
    s.s     := '1';
    s.et    := '0';
    s.y     := (others => '0');
    s.asr18 := (others => '0');
    s.svt   := '0';
    s.dwt   := '0';
    s.dbp   := '0';
    s.dbprepl := '1';
    s.rexdis :='1';
    s.rextrap:='1';
    s.aw     := '0';
    s.paw    := '0';
    s.awp    := (others => '0');
    s.stwin  := (others => '0');
    s.cwpmax := CWPMAX;
    return s;
  end function special_register_res;
  --constant write_reg_res : write_reg_type := (
  --  s      => special_register_res,
  --  result => (others => '0'),
  --  wa     => (others => '0'),
  --  wreg   => '0',
  --  except => '0'
  --  );
  -- XST workaround:
  function write_reg_res return write_reg_type is
    variable w : write_reg_type;
  begin
    w.s      := special_register_res;
    w.result := (others => '0');
    w.wa     := (others => '0');
    w.wreg   := '0';
    w.except := '0';
    w.twcwp:= (others => '0');
    return w;
  end function write_reg_res;
  constant RRES : registers := (
    f => fetch_reg_res,
    d => decode_reg_res,
    a => regacc_reg_res,
    e => execute_reg_res,
    m => memory_reg_res,
    x => exception_reg_res,
    w => write_reg_res
    );
  constant exception_res : exception_type := (
    pri   => '0',
    ill   => '0',
    fpdis => '0',
    cpdis => '0',
    wovf  => '0',
    wunf  => '0',
    ticc  => '0'
    );
  constant wpr_none : watchpoint_register := (
    addr  => zero32(31 downto 2),
    mask  => zero32(31 downto 2),
    exec  => '0',
    load  => '0',
    store => '0');

  signal r, rin : registers;
  signal wpr, wprin : watchpoint_registers;
  signal dsur, dsuin : dsu_registers;
  signal ir, irin : irestart_register;
  signal rp, rpin : pwd_register_type;

  signal program_counter : pctype;
  signal pv : std_ulogic;
  signal psr : special_register_type;
  signal inst0 : word;
  signal inst1 : word;
  signal m_addr : word;

  attribute mark_debug : string;

  -- attribute mark_debug of program_counter : signal is "true";
  -- attribute mark_debug of pv : signal is "true";
  -- attribute mark_debug of psr : signal is "true";
  -- attribute mark_debug of inst0 : signal is "true";
  -- attribute mark_debug of inst1 : signal is "true";
  -- attribute mark_debug of m_addr : signal is "true";

-- execute stage operations

  constant EXE_AND   : std_logic_vector(2 downto 0) := "000";
  constant EXE_XOR   : std_logic_vector(2 downto 0) := "001"; -- must be equal to EXE_PASS2
  constant EXE_OR    : std_logic_vector(2 downto 0) := "010";
  constant EXE_XNOR  : std_logic_vector(2 downto 0) := "011";
  constant EXE_ANDN  : std_logic_vector(2 downto 0) := "100";
  constant EXE_ORN   : std_logic_vector(2 downto 0) := "101";
  constant EXE_DIV   : std_logic_vector(2 downto 0) := "110";

  constant EXE_PASS1 : std_logic_vector(2 downto 0) := "000";
  constant EXE_PASS2 : std_logic_vector(2 downto 0) := "001";
  constant EXE_STB   : std_logic_vector(2 downto 0) := "010";
  constant EXE_STH   : std_logic_vector(2 downto 0) := "011";
  constant EXE_ONES  : std_logic_vector(2 downto 0) := "100";
  constant EXE_RDY   : std_logic_vector(2 downto 0) := "101";
  constant EXE_SPR   : std_logic_vector(2 downto 0) := "110";
  constant EXE_LINK  : std_logic_vector(2 downto 0) := "111";

  constant EXE_SLL   : std_logic_vector(2 downto 0) := "001";
  constant EXE_SRL   : std_logic_vector(2 downto 0) := "010";
  constant EXE_SRA   : std_logic_vector(2 downto 0) := "100";

  constant EXE_NOP   : std_logic_vector(2 downto 0) := "000";

-- EXE result select

  constant EXE_RES_ADD   : std_logic_vector(1 downto 0) := "00";
  constant EXE_RES_SHIFT : std_logic_vector(1 downto 0) := "01";
  constant EXE_RES_LOGIC : std_logic_vector(1 downto 0) := "10";
  constant EXE_RES_MISC  : std_logic_vector(1 downto 0) := "11";

-- Load types

  constant SZBYTE    : std_logic_vector(1 downto 0) := "00";
  constant SZHALF    : std_logic_vector(1 downto 0) := "01";
  constant SZWORD    : std_logic_vector(1 downto 0) := "10";
  constant SZDBL     : std_logic_vector(1 downto 0) := "11";

-- calculate register file address

  procedure regaddr(cwp : std_logic_vector; reg : std_logic_vector(4 downto 0);
         stwin, de_cwpmax: std_logic_vector;
         rao : out rfatype) is
  variable ra : rfatype;
  constant globals : std_logic_vector(RFBITS-5  downto 0) := 
        conv_std_logic_vector(NWIN, RFBITS-4);
    variable vcwp: cwptype;
  begin
    vcwp := cwp;
    ra := (others => '0'); ra(4 downto 0) := reg;
    if RFPART then
      if ra(4)='0' and cwp=CWPMIN then
        ra(4):='1';
        vcwp := std_logic_vector(unsigned(de_cwpmax) + unsigned(stwin));
      else
        vcwp := std_logic_vector(unsigned(cwp) + unsigned(stwin));
      end if;
    end if;
    if reg(4 downto 3) = "00" then ra(RFBITS -1 downto 4) := globals;
    else
      ra(NWINLOG2+3 downto 4) := vcwp + ra(4);
      if ra(RFBITS-1 downto 4) = globals then
        ra(RFBITS-1 downto 4) := (others => '0');
      end if;
    end if;
    rao := ra;
  end;

-- branch adder

  function branch_address(inst : word; pc : pctype; de_rexbaddr1, de_rexen: std_logic) return std_logic_vector is
    variable baddr: std_logic_vector(31 downto 0);
    variable caddr, tmp : pctype;
  begin
    caddr := (others => '0'); caddr(31 downto 2) := inst(29 downto 0);
    caddr(31 downto 2) := caddr(31 downto 2) + pc(31 downto 2);
    baddr := (others => '0'); baddr(31 downto 24) := (others => inst(21)); 
    baddr(23 downto 2) := inst(21 downto 0);
    baddr(1) := de_rexbaddr1;
    baddr(0) := de_rexen;
    baddr(31 downto 1+(1-REX)) := baddr(31 downto 1+(1-REX)) + pc(31 downto 1+(1-REX));
    if inst(30) = '1' then tmp := caddr; else tmp := baddr(31 downto PCLOW); end if;
    return(tmp);
  end;

-- evaluate branch condition

  function branch_true(icc : std_logic_vector(3 downto 0); inst : word) 
        return std_ulogic is
  variable n, z, v, c, branch : std_ulogic;
  begin
    n := icc(3); z := icc(2); v := icc(1); c := icc(0);
    case inst(27 downto 25) is
    when "000" =>  branch := inst(28) xor '0';                  -- bn, ba
    when "001" =>  branch := inst(28) xor z;                    -- be, bne
    when "010" =>  branch := inst(28) xor (z or (n xor v));     -- ble, bg
    when "011" =>  branch := inst(28) xor (n xor v);            -- bl, bge
    when "100" =>  branch := inst(28) xor (c or z);             -- bleu, bgu
    when "101" =>  branch := inst(28) xor c;                    -- bcs, bcc 
    when "110" =>  branch := inst(28) xor n;                    -- bneg, bpos
    when others => branch := inst(28) xor v;                    -- bvs, bvc   
    end case;
    return(branch);
  end;

-- detect RETT instruction in the pipeline and set the local psr.su and psr.et

  procedure su_et_select(r : in registers; xc_ps, xc_s, xc_et : in std_ulogic;
                       su, et : out std_ulogic) is
  begin
   if ((r.a.ctrl.rett or r.e.ctrl.rett or r.m.ctrl.rett or r.x.ctrl.rett) = '1')
     and (r.x.annul_all = '0')
   then su := xc_ps; et := '1';
   else su := xc_s; et := xc_et; end if;
  end;

-- detect watchpoint trap

  function wphit(r : registers; wpr : watchpoint_registers; debug : l3_debug_in_type;
                 dsur : dsu_registers)
    return std_ulogic is
  variable exc : std_ulogic;
  begin
    exc := '0';
    for i in 1 to NWP loop
      if ((wpr(i-1).exec and r.a.ctrl.pv and not r.a.ctrl.annul) = '1') then
         if (((wpr(i-1).addr xor r.a.ctrl.pc(31 downto 2)) and wpr(i-1).mask) = Zero32(31 downto 2)) then
           exc := '1';
         end if;
      end if;
    end loop;

   if DBGUNIT then
     if (debug.dsuen and not r.a.ctrl.annul) = '1' then
       exc := exc or (r.a.ctrl.pv and ((((debug.dbreak and debug.bwatch) or r.a.step)) or
                                       (debug.bwatch and dsur.tovb and dsur.tov)));
     end if;
   end if;
    return(exc);
  end;

-- 32-bit shifter

  function shift3(r : registers; aluin1, aluin2 : word) return word is
  variable shiftin : unsigned(63 downto 0);
  variable shiftout : unsigned(63 downto 0);
  variable cnt : natural range 0 to 31;
  begin

    cnt := conv_integer(r.e.shcnt);
    if r.e.shleft = '1' then
      shiftin(30 downto 0) := (others => '0');
      shiftin(63 downto 31) := '0' & unsigned(aluin1);
    else
      shiftin(63 downto 32) := (others => r.e.sari);
      shiftin(31 downto 0) := unsigned(aluin1);
    end if;
    shiftout := SHIFT_RIGHT(shiftin, cnt);
    return(std_logic_vector(shiftout(31 downto 0)));
     
  end;

  function shift2(r : registers; aluin1, aluin2 : word) return word is
  variable ushiftin : unsigned(31 downto 0);
  variable sshiftin : signed(32 downto 0);
  variable cnt : natural range 0 to 31;
  variable resleft, resright : word;
  begin

    cnt := conv_integer(r.e.shcnt);
    ushiftin := unsigned(aluin1);
    sshiftin := signed('0' & aluin1);
    if r.e.shleft = '1' then
      resleft := std_logic_vector(SHIFT_LEFT(ushiftin, cnt));
      return(resleft);
    else
      if r.e.sari = '1' then sshiftin(32) := aluin1(31); end if;
      sshiftin := SHIFT_RIGHT(sshiftin, cnt);
      resright := std_logic_vector(sshiftin(31 downto 0));
      return(resright);
    end if;
     
  end;

  function shift(r : registers; aluin1, aluin2 : word;
                 shiftcnt : std_logic_vector(4 downto 0); sari : std_ulogic ) return word is
  variable shiftin : std_logic_vector(63 downto 0);
  begin
    shiftin := zero32 & aluin1;
    if r.e.shleft = '1' then
      shiftin(31 downto 0) := zero32; shiftin(63 downto 31) := '0' & aluin1;
    else shiftin(63 downto 32) := (others => sari); end if;
    if shiftcnt (4) = '1' then shiftin(47 downto 0) := shiftin(63 downto 16); end if;
    if shiftcnt (3) = '1' then shiftin(39 downto 0) := shiftin(47 downto 8); end if;
    if shiftcnt (2) = '1' then shiftin(35 downto 0) := shiftin(39 downto 4); end if;
    if shiftcnt (1) = '1' then shiftin(33 downto 0) := shiftin(35 downto 2); end if;
    if shiftcnt (0) = '1' then shiftin(31 downto 0) := shiftin(32 downto 1); end if;
    return(shiftin(31 downto 0));
  end;

-- Check for illegal and privileged instructions

procedure exception_detect(r : registers; wpr : watchpoint_registers; dbgi : l3_debug_in_type;
        trapin : in std_ulogic; ttin : in std_logic_vector(5 downto 0); 
        trap : out std_ulogic; tt : out std_logic_vector(5 downto 0)) is
variable illegal_inst, privileged_inst : std_ulogic;
variable cp_disabled, fp_disabled, fpop : std_ulogic;
variable op : std_logic_vector(1 downto 0);
variable op2 : std_logic_vector(2 downto 0);
variable op3 : std_logic_vector(5 downto 0);
variable rd  : std_logic_vector(4 downto 0);
variable inst : word;
variable wph : std_ulogic;
begin
  inst := r.a.ctrl.inst; trap := trapin; tt := ttin;
  if r.a.ctrl.annul = '0' then
    op  := inst(31 downto 30); op2 := inst(24 downto 22);
    op3 := inst(24 downto 19); rd  := inst(29 downto 25);
    illegal_inst := '0'; privileged_inst := '0'; cp_disabled := '0'; 
    fp_disabled := '0'; fpop := '0'; 
    case op is
    when CALL => null;
    when FMT2 =>
      case op2 is
      when SETHI | BICC => null;
      when FBFCC => 
        if FPEN then fp_disabled := not r.w.s.ef; else fp_disabled := '1'; end if;
      when CBCCC =>
        if (not CPEN) or (r.w.s.ec = '0') then cp_disabled := '1'; end if;
      when others => illegal_inst := '1';
      end case;
    when FMT3 =>
      case op3 is
      when IAND | ANDCC | ANDN | ANDNCC | IOR | ORCC | ORN | ORNCC | IXOR |
        XORCC | IXNOR | XNORCC | ISLL | ISRL | ISRA | MULSCC | IADD | ADDX |
        ADDCC | ADDXCC | ISUB | SUBX | SUBCC | SUBXCC | FLUSH | JMPL | TICC | 
        SAVE | RESTORE | RDY => null;
      when TADDCC | TADDCCTV | TSUBCC | TSUBCCTV => 
        if notag = 1 then illegal_inst := '1'; end if;
      when UMAC | SMAC => 
        if not MACEN then illegal_inst := '1'; end if;
      when UMUL | SMUL | UMULCC | SMULCC => 
        if not MULEN then illegal_inst := '1'; end if;
      when UDIV | SDIV | UDIVCC | SDIVCC => 
        if not DIVEN then illegal_inst := '1'; end if;
      when RETT => illegal_inst := r.a.et; privileged_inst := not r.a.su;
      when RDPSR | RDTBR | RDWIM => privileged_inst := not r.a.su;
      when WRY =>
        if rd(4) = '1' and rd(3 downto 0) /= "0010" then -- %ASR16-17, %ASR19-31
          privileged_inst := not r.a.su;
        end if;
      when WRPSR => 
        privileged_inst := not r.a.su; 
      when WRWIM | WRTBR  => privileged_inst := not r.a.su;
      when FPOP1 | FPOP2 => 
        if FPEN then fp_disabled := not r.w.s.ef; fpop := '1';
        else fp_disabled := '1'; fpop := '0'; end if;
      when CPOP1 | CPOP2 =>
        if (not CPEN) or (r.w.s.ec = '0') then cp_disabled := '1'; end if;
      when others => illegal_inst := '1';
      end case;
    when others =>      -- LDST
      case op3 is
      when LDD | ISTD => illegal_inst := rd(0); -- trap if odd destination register
      when LD | LDUB | LDSTUB | LDUH | LDSB | LDSH | ST | STB | STH | SWAP =>
        null;
      when LDDA | STDA =>
        illegal_inst := inst(13) or rd(0);
        if (npasi = 0) or (inst(12) = '0') then
          privileged_inst := not r.a.su;
        end if;
      when LDA | LDUBA| LDSTUBA | LDUHA | LDSBA | LDSHA | STA | STBA | STHA |
           SWAPA => 
        illegal_inst := inst(13);
        if (npasi = 0) or (inst(12) = '0') then
          privileged_inst := not r.a.su;
        end if;
      when CASA =>
        if CASAEN then
          illegal_inst := inst(13); 
          if (inst(12 downto 5) /= X"0A") then privileged_inst := not r.a.su; end if;
        else illegal_inst := '1'; end if;
      when LDDF | STDF | LDF | LDFSR | STF | STFSR => 
        if FPEN then fp_disabled := not r.w.s.ef;
        else fp_disabled := '1'; end if;
      when STDFQ => 
        privileged_inst := not r.a.su; 
        if (not FPEN) or (r.w.s.ef = '0') then fp_disabled := '1'; end if;
      when STDCQ => 
        privileged_inst := not r.a.su;
        if (not CPEN) or (r.w.s.ec = '0') then cp_disabled := '1'; end if;
      when LDC | LDCSR | LDDC | STC | STCSR | STDC => 
        if (not CPEN) or (r.w.s.ec = '0') then cp_disabled := '1'; end if;
      when others => illegal_inst := '1';
      end case;
    end case;

    wph := wphit(r, wpr, dbgi, dsur);
    
    trap := '1';
    if r.a.ctrl.trap = '1' then tt := r.a.ctrl.tt;
    elsif privileged_inst = '1' then tt := TT_PRIV; 
    elsif illegal_inst = '1' or r.a.decill = '1' then tt := TT_IINST;
    elsif fp_disabled = '1' then tt := TT_FPDIS;
    elsif cp_disabled = '1' then tt := TT_CPDIS;
    elsif wph = '1' then tt := TT_WATCH;
    elsif r.a.wovf= '1' then tt := TT_WINOF;
    elsif r.a.wunf= '1' then tt := TT_WINUF;
    elsif r.a.ticc= '1' then tt := TT_TICC;
    else trap := '0'; tt:= (others => '0'); end if;
  end if;
end;

-- instructions that write the condition codes (psr.icc)

procedure wicc_y_gen(inst : word; wicc, wy : out std_ulogic) is
begin
  wicc := '0'; wy := '0';
  if inst(31 downto 30) = FMT3 then
    case inst(24 downto 19) is
    when SUBCC | TSUBCC | TSUBCCTV | ADDCC | ANDCC | ORCC | XORCC | ANDNCC |
         ORNCC | XNORCC | TADDCC | TADDCCTV | ADDXCC | SUBXCC | WRPSR => 
      wicc := '1';
    when WRY =>
      if r.d.inst(conv_integer(r.d.set))(29 downto 25) = "00000" then wy := '1'; end if;
    when MULSCC =>
      wicc := '1'; wy := '1';
    when  UMAC | SMAC  =>
      if MACEN then wy := '1'; end if;
    when UMULCC | SMULCC => 
      if MULEN and (((mulo.nready = '1') and (r.d.cnt /= "00")) or (MULTYPE /= 0)) then
        wicc := '1'; wy := '1';
      end if;
    when UMUL | SMUL => 
      if MULEN and (((mulo.nready = '1') and (r.d.cnt /= "00")) or (MULTYPE /= 0)) then
        wy := '1';
      end if;
    when UDIVCC | SDIVCC => 
      if DIVEN and (divo.nready = '1') and (r.d.cnt /= "00") then
        wicc := '1';
      end if;
    when others =>
    end case;
  end if;
end;

-- select cwp 

procedure cwp_gen(r, v : registers; annul, wcwp : std_ulogic; ncwp : cwptype;
                  cwp : out cwptype; awp: out cwptype; aw,paw: out std_ulogic;
                  stwin,de_cwpmax: out cwptype) is
begin
  if (r.x.rstate = trap) or
      (r.x.rstate = dsu2) 
     or (rstn = '0') then cwp := v.w.s.cwp;                                                                     
  elsif (wcwp = '1') and (annul = '0') and ((not AWPEN) or r.d.aw='0') then cwp := ncwp;
  elsif r.m.wcwp = '1' then cwp := r.m.result(NWINLOG2-1 downto 0);
  else cwp := r.d.cwp; end if;

  if AWPEN and ((r.x.rstate = trap) or
      (r.x.rstate = dsu2)
     or (rstn = '0')) then awp := v.w.s.awp;
  elsif AWPEN and r.d.aw='1' and (wcwp = '1') and (annul = '0') then awp := ncwp;
  elsif AWPEN and r.m.wawp = '1' then awp := r.m.result(NWINLOG2-1 downto 0);
  elsif AWPEN and (r.d.aw='0' and r.d.paw='0') then awp := r.d.cwp;
  else awp := r.d.awp; end if;

  if AWPEN and (
    (r.x.rstate = trap) or
      (r.x.rstate = dsu2)
     or (rstn = '0') ) then aw := v.w.s.aw; paw := v.w.s.paw;
  elsif AWPEN and (v.a.ctrl.rett='1') then
    aw := r.d.paw; paw := r.d.paw;
  elsif AWPEN and r.m.wcwp='1' then aw:=r.m.result(15); paw:=r.m.result(14);
  else aw:=r.d.aw; paw:=r.d.paw; end if;

  if RFPART and (
    (r.x.rstate = trap) or
      (r.x.rstate = dsu2)
     or (rstn = '0') ) then
    stwin := v.w.s.stwin; de_cwpmax:=v.w.s.cwpmax;
  elsif RFPART and r.m.wawp='1' and r.m.result(15+NWINLOG2 downto 16)/=CWPMIN then
    stwin:=r.m.result(20+NWINLOG2 downto 21); de_cwpmax:=r.m.result(15+NWINLOG2 downto 16);
  else
    stwin := r.d.stwin; de_cwpmax:=r.d.cwpmax;
  end if;
end;

-- generate wcwp in ex stage

procedure cwp_ex(r : in  registers; wcwp : out std_ulogic; wawp : out std_ulogic) is
  variable vwcwp, vwawp: std_ulogic;
begin
  vwcwp := '0'; vwawp := '0';
  if (r.e.ctrl.inst(31 downto 30) = FMT3) and 
     (r.e.ctrl.inst(24 downto 19) = WRPSR)
  then vwcwp := not r.e.ctrl.annul; else vwcwp := '0'; end if;
  if AWPEN and
    (r.e.ctrl.inst(31 downto 30) = FMT3) and
    (r.e.ctrl.inst(24 downto 19) = WRY) and
    (r.e.ctrl.inst(29 downto 25) = "10100")
  then
    vwawp := not r.e.ctrl.annul;
    vwcwp := vwcwp or (r.e.op1(5) and not r.e.ctrl.annul);
  else vwawp := '0';
  end if;
  wcwp := vwcwp;
  wawp := vwawp;
end;

-- generate next cwp & window under- and overflow traps

procedure cwp_ctrl(r : in registers; rcwp: in cwptype; xc_wim : in std_logic_vector(NWIN-1 downto 0);
        inst : word; de_cwp : out cwptype; wovf_exc, wunf_exc, wcwp : out std_ulogic) is
variable op : std_logic_vector(1 downto 0);
variable op3 : std_logic_vector(5 downto 0);
variable wim : word;
variable ncwp : cwptype;
begin
  op := inst(31 downto 30); op3 := inst(24 downto 19); 
  wovf_exc := '0'; wunf_exc := '0'; wim := (others => '0'); 
  wim(NWIN-1 downto 0) := xc_wim; wcwp := '0';
  ncwp := rcwp;
  if (op = FMT3) and ((op3 = RETT) or (op3 = RESTORE) or (op3 = SAVE)) then
    wcwp := '1';
    if (op3 = SAVE) then
      if RFPART and (rcwp=CWPMIN) then ncwp := r.w.s.cwpmax;
      elsif (not CWPOPT) and (rcwp = CWPMIN) then ncwp := CWPMAX;
      else ncwp := rcwp - 1 ; end if;
    else
      if RFPART and (rcwp = r.w.s.cwpmax) then ncwp := CWPMIN;
      elsif (not CWPOPT) and (rcwp = CWPMAX) then ncwp := CWPMIN;
      else ncwp := rcwp + 1; end if;
    end if;
    if wim(conv_integer(ncwp)) = '1' then
      if op3 = SAVE then wovf_exc := '1'; else wunf_exc := '1'; end if;
    end if;
  end if;
  de_cwp := ncwp;
end;

-- generate register read address 1

procedure rs1_gen(r : registers; inst : word;  rs1 : out std_logic_vector(4 downto 0);
        rs1mod : out std_ulogic) is
variable op : std_logic_vector(1 downto 0);
variable op3 : std_logic_vector(5 downto 0);
begin
  op := inst(31 downto 30); op3 := inst(24 downto 19); 
  rs1 := inst(18 downto 14); rs1mod := '0';
  if (op = LDST) then
    if ((r.d.cnt = "01") and ((op3(2) and not op3(3)) = '1')) or
      ((r.d.cnt = "10") and (not (CASAEN and LDDEL=2 and op3(5 downto 3)="111"))) or
      ((r.d.cnt = "11") and (    (CASAEN and LDDEL=2)))
    then rs1mod := '1'; rs1 := inst(29 downto 25); end if;
    if ((r.d.cnt = "10") and (op3(3 downto 0) = "0111")) then
      rs1(0) := '1';
    end if;
  end if;
end;

-- load/icc interlock detection

  function icc_valid(r : registers) return std_logic is
  variable not_valid : std_logic;
  begin
    not_valid := '0';
    if MULEN or DIVEN then 
      not_valid := r.m.ctrl.wicc and (r.m.ctrl.cnt(0) or r.m.mul);
    end if;
    not_valid := not_valid or (r.a.ctrl.wicc or r.e.ctrl.wicc);
    return(not not_valid);
  end;

  procedure bp_miss_ex(r : registers; icc : std_logic_vector(3 downto 0); 
        ex_bpmiss, ra_bpannul : out std_logic) is
  variable miss : std_logic;
  begin
    miss := (not r.e.ctrl.annul) and r.e.bp and not branch_true(icc, r.e.ctrl.inst);
    ra_bpannul := miss and r.e.ctrl.inst(29);
    ex_bpmiss := miss;
  end;

  procedure bp_miss_ra(r : registers; ra_bpmiss, de_bpannul : out std_logic) is
  variable miss : std_logic;
  begin
    miss := ((not r.a.ctrl.annul) and r.a.bp and icc_valid(r) and not branch_true(r.m.icc, r.a.ctrl.inst));
    de_bpannul := miss and r.a.ctrl.inst(29);
    ra_bpmiss := miss;
  end;

  procedure lock_gen(r : registers; rs2, rd : std_logic_vector(4 downto 0);
        rfa1, rfa2, rfrd : rfatype; inst : word; fpc_lock, mulinsn, divinsn, de_wcwp : std_ulogic;
        lldcheck1, lldcheck2, lldlock, lldchkra, lldchkex, bp, nobp, de_fins_hold : out std_ulogic;
        iperr : std_logic; icbpmiss: std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable cond : std_logic_vector(3 downto 0);
  variable rs1  : std_logic_vector(4 downto 0);
  variable i, ldcheck1, ldcheck2, ldchkra, ldchkex, ldcheck3 : std_ulogic;
  variable ldlock, icc_check, bicc_hold, chkmul, y_check : std_logic;
  variable icc_check_bp, y_hold, mul_hold, bicc_hold_bp, fins, call_hold  : std_ulogic;
  variable de_fins_holdx : std_ulogic;
  begin
    op := inst(31 downto 30); op3 := inst(24 downto 19); 
    op2 := inst(24 downto 22); cond := inst(28 downto 25); 
    rs1 := inst(18 downto 14); i := inst(13);
    ldcheck1 := '0'; ldcheck2 := '0'; ldcheck3 := '0'; ldlock := '0';
    ldchkra := '1'; ldchkex := '1'; icc_check := '0'; bicc_hold := '0';
    y_check := '0'; y_hold := '0'; bp := '0'; mul_hold := '0';
    icc_check_bp := '0'; nobp := '0'; fins := '0'; call_hold := '0';

    if (r.d.annul = '0') and (icbpmiss='0')
    then
      case op is
      when CALL =>
        call_hold := '1'; nobp := BPRED;
      when FMT2 =>
        if (op2 = BICC) and (cond(2 downto 0) /= "000") then 
          icc_check_bp := '1';
        end if;
        if (op2 = BICC) then nobp := BPRED; end if;
      when FMT3 =>
        ldcheck1 := '1'; ldcheck2 := not i;
        case op3 is
        when TICC =>
          if (cond(2 downto 0) /= "000") then icc_check := '1'; end if;
          nobp := BPRED;
        when RDY => 
          ldcheck1 := '0'; ldcheck2 := '0';
          if MACPIPE then y_check := '1'; end if;
        when RDWIM | RDTBR => 
          ldcheck1 := '0'; ldcheck2 := '0';
        when RDPSR => 
          ldcheck1 := '0'; ldcheck2 := '0'; icc_check := '1';
        when SDIV | SDIVCC | UDIV | UDIVCC =>
          if DIVEN then y_check := '1'; nobp := op3(4); end if; -- no BP on divcc
        when FPOP1 | FPOP2 => ldcheck1:= '0'; ldcheck2 := '0'; fins := BPRED;
        when JMPL => call_hold := '1'; nobp := BPRED;
        when others => 
        end case;
      when LDST =>
        ldcheck1 := '1'; ldchkra := '0';
        case r.d.cnt is
        when "00" =>
          if (lddel = 2) and (op3(2) = '1') and (op3(5) = '0') then ldcheck3 := '1'; end if; 
          ldcheck2 := not i; ldchkra := '1';
        when "01" =>
          ldcheck2 := not i;
          if (op3(5) and op3(2) and not op3(3)) = '1' then ldcheck1 := '0'; ldcheck2 := '0'; end if;  -- STF/STC
        when others => ldchkex := '0';
          if CASAEN and (op3(5 downto 3) = "111") then
            if lddel=2 then
              ldcheck2 := r.d.cnt(0);
            else
              ldcheck2 := '1';
            end if;
          elsif (op3(5) = '1') or ((op3(5) & op3(3 downto 1)) = "0110") -- LDST
          then ldcheck1 := '0'; ldcheck2 := '0'; end if;
        end case;
        if op3(5) = '1' then fins := BPRED; end if; -- no BP on FPU/CP LD/ST
      when others => null;
      end case;
    end if;

    if MULEN or DIVEN then 
      chkmul := mulinsn;
      mul_hold := (r.a.mulstart and r.a.ctrl.wicc) or (r.m.ctrl.wicc and (r.m.ctrl.cnt(0) or r.m.mul));
      if (MULTYPE = 0) and ((icc_check_bp and BPRED and r.a.ctrl.wicc and r.a.ctrl.wy) = '1')
      then mul_hold := '1'; end if;
    else chkmul := '0'; end if;
    if DIVEN then 
      y_hold := y_check and (r.a.ctrl.wy or r.e.ctrl.wy);
      chkmul := chkmul or divinsn;
    end if;

    bicc_hold := icc_check and not icc_valid(r);
    bicc_hold_bp := icc_check_bp and not icc_valid(r);

    if (((r.a.ctrl.ld or chkmul) and r.a.ctrl.wreg and ldchkra) = '1') and
       (((ldcheck1 = '1') and (r.a.ctrl.rd = rfa1)) or
        ((ldcheck2 = '1') and (r.a.ctrl.rd = rfa2)) or
        ((ldcheck3 = '1') and (r.a.ctrl.rd = rfrd)))
    then ldlock := '1'; end if;

    if (((r.e.ctrl.ld or r.e.mac) and r.e.ctrl.wreg and ldchkex) = '1') and 
        ((lddel = 2) or (MACPIPE and (r.e.mac = '1')) or ((MULTYPE = 3) and (r.e.mul = '1'))) and
       (((ldcheck1 = '1') and (r.e.ctrl.rd = rfa1)) or
        ((ldcheck2 = '1') and (r.e.ctrl.rd = rfa2)))
    then ldlock := '1'; end if;

    de_fins_holdx := BPRED and fins and (r.a.bp or r.e.bp); -- skip BP on FPU inst in branch target address
    de_fins_hold := de_fins_holdx;
    ldlock := ldlock or y_hold or fpc_lock or (BPRED and r.a.bp and r.a.ctrl.inst(29) and de_wcwp) or de_fins_holdx;
    if ((icc_check_bp and BPRED) = '1') and ((r.a.nobp or mul_hold) = '0') then 
      bp := bicc_hold_bp;
    else ldlock := ldlock or bicc_hold or bicc_hold_bp; end if;
    lldcheck1 := ldcheck1; lldcheck2:= ldcheck2; lldlock := ldlock;
    lldchkra := ldchkra; lldchkex := ldchkex;
  end;

  procedure fpbranch(inst : in word; fcc  : in std_logic_vector(1 downto 0);
                      branch : out std_ulogic) is
  variable cond : std_logic_vector(3 downto 0);
  variable fbres : std_ulogic;
  begin
    cond := inst(28 downto 25);
    case cond(2 downto 0) is
      when "000" => fbres := '0';                       -- fba, fbn
      when "001" => fbres := fcc(1) or fcc(0);
      when "010" => fbres := fcc(1) xor fcc(0);
      when "011" => fbres := fcc(0);
      when "100" => fbres := (not fcc(1)) and fcc(0);
      when "101" => fbres := fcc(1);
      when "110" => fbres := fcc(1) and not fcc(0);
      when others => fbres := fcc(1) and fcc(0);
    end case;
    branch := cond(3) xor fbres;     
  end;

-- PC generation

  procedure ic_ctrl(r : registers; inst : word; annul_all, ldlock, de_rexhold, de_rexbubble, de_rexmaskpv, de_rexillinst, branch_true,
        fbranch_true, cbranch_true, fccv, cccv : in std_ulogic; 
        cnt : out std_logic_vector(1 downto 0); 
        de_pc : out pctype; de_branch, ctrl_annul, de_annul, jmpl_inst, inull, 
        de_pv, ctrl_pv, de_hold_pc, ticc_exception, rett_inst, mulstart,
        divstart : out std_ulogic; rabpmiss, exbpmiss, iperr : std_logic;
        icbpmiss, eocl: std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable cond : std_logic_vector(3 downto 0);
  variable hold_pc, annul_current, annul_next, branch, annul, pv : std_ulogic;
  variable de_jmpl, inhibit_current : std_ulogic;
  begin
    branch := '0'; annul_next := '0'; annul_current := '0'; pv := '1';
    hold_pc := '0'; ticc_exception := '0'; rett_inst := '0';
    op := inst(31 downto 30); op3 := inst(24 downto 19); 
    op2 := inst(24 downto 22); cond := inst(28 downto 25); 
    annul := inst(29); de_jmpl := '0'; cnt := "00";
    mulstart := '0'; divstart := '0'; inhibit_current := '0';
    if (r.d.annul = '0') and not (icbpmiss = '1' and r.d.pcheld='0') and (REX=0 or de_rexbubble='0')
    then
      case inst(31 downto 30) is
      when CALL =>
        branch := '1';
        if r.d.inull = '1' then 
          hold_pc := '1'; annul_current := '1';
        end if;
      when FMT2 =>
        if (op2 = BICC) or (FPEN and (op2 = FBFCC)) or (CPEN and (op2 = CBCCC)) then
          if (FPEN and (op2 = FBFCC)) then 
            branch := fbranch_true;
            if fccv /= '1' then hold_pc := '1'; annul_current := '1'; end if;
          elsif (CPEN and (op2 = CBCCC)) then 
            branch := cbranch_true;
            if cccv /= '1' then hold_pc := '1'; annul_current := '1'; end if;
          else branch := branch_true or (BPRED and orv(cond) and not icc_valid(r)); end if;
          if hold_pc = '0' then
            if (branch = '1') then
              if (cond = BA) and (annul = '1') then annul_next := '1'; end if;
            else annul_next := annul_next or annul; end if;
            if r.d.inull = '1' then -- contention with JMPL
              hold_pc := '1'; annul_current := '1'; annul_next := '0';
            end if;
          end if;
        end if;
      when FMT3 =>
        case op3 is
        when UMUL | SMUL | UMULCC | SMULCC =>
          if MULEN and (MULTYPE /= 0) then mulstart := '1'; end if;
          if MULEN and (MULTYPE = 0) then
            case r.d.cnt is
            when "00" =>
              cnt := "01"; hold_pc := '1'; pv := '0'; mulstart := '1';
            when "01" =>
              if mulo.nready = '1' then cnt := "00";
              else cnt := "01"; pv := '0'; hold_pc := '1'; end if;
            when others => null;
            end case;
          end if;
        when UDIV | SDIV | UDIVCC | SDIVCC =>
          if DIVEN then
            case r.d.cnt is
            when "00" =>
              hold_pc := '1'; pv := '0';
              if r.d.divrdy = '0' then
                cnt := "01"; divstart := '1';
              end if;
            when "01" =>
              if divo.nready = '1' then cnt := "00"; 
              else cnt := "01"; pv := '0'; hold_pc := '1'; end if;
            when others => null;
            end case;
          end if;
        when TICC =>
          if branch_true = '1' then ticc_exception := '1'; end if;
        when RETT =>
          rett_inst := '1'; --su := sregs.ps; 
        when JMPL =>
          de_jmpl := '1';
          if (BLOCKBPMISS and (eocl or r.f.branch) and r.e.bp)='1' then
            hold_pc := '1'; annul_current := '1';
          end if;
        when WRY =>
          if PWRD1 then 
            if inst(29 downto 25) = "10011" then -- %ASR19
              case r.d.cnt is
              when "00" =>
                pv := '0'; cnt := "00"; hold_pc := '1';
                if r.x.ipend = '1' then cnt := "01"; end if;              
              when "01" =>
                cnt := "00";
              when others =>
              end case;
            end if;
          end if;
        when others => null;
        end case;
      when others =>  -- LDST 
        case r.d.cnt is
        when "00" =>
          if (op3(2) = '1') or (op3(1 downto 0) = "11") then -- ST/LDST/SWAP/LDD/CASA
            cnt := "01"; hold_pc := '1'; pv := '0';
          end if;
        when "01" =>
          if (op3(2 downto 0) = "111") or (op3(3 downto 0) = "1101") or
             (CASAEN and (op3(5 downto 4) = "11")) or   -- CASA
             ((CPEN or FPEN) and ((op3(5) & op3(2 downto 0)) = "1110"))
          then  -- LDD/STD/LDSTUB/SWAP
            cnt := "10"; pv := '0'; hold_pc := '1';
          else
            cnt := "00";
          end if;
        when "10" =>
          if (CASAEN and LDDEL=2 and op3(5 downto 4)="11") then  -- CASA
            cnt := "11"; hold_pc := '1'; pv := '0';
          else
            cnt := "00";
          end if;
        when others => null;
        end case;
      end case;
    end if;

    if ldlock = '1' then
      cnt := r.d.cnt; annul_next := '0'; pv := '1';
    end if;
    hold_pc := (hold_pc or ldlock) and not annul_all;

    if icbpmiss='1' and r.d.annul='0' then
      annul_current := '1'; annul_next := '1'; pv := '0'; hold_pc := '0';
    end if;
    if ((exbpmiss and r.a.ctrl.annul and r.d.pv and not hold_pc) = '1') then
        annul_next := '1'; pv := '0';
    end if;
    if ((exbpmiss and not r.a.ctrl.annul and r.d.pv) = '1') then
        annul_next := '1'; pv := '0'; annul_current := '1';
    end if;
    if ((exbpmiss and not r.a.ctrl.annul and not r.d.pv and not hold_pc) = '1') then
        annul_next := '1'; pv := '0';
    end if;
    if ((exbpmiss and r.e.ctrl.inst(29) and not r.a.ctrl.annul and not r.d.pv ) = '1') 
        and (r.d.cnt = "01") then
        annul_next := '1'; annul_current := '1'; pv := '0';
    end if;
    if (exbpmiss and r.e.ctrl.inst(29) and r.a.ctrl.annul and r.d.pv) = '1' then
      annul_next := '1'; pv := '0'; inhibit_current := '1';
    end if;
    if (exbpmiss and r.e.ctrl.inst(29) and BLOCKBPMISS and r.a.bpimiss) = '1' then
      annul_next := '1'; pv := '0';
    end if;
    if (rabpmiss and not r.a.ctrl.inst(29) and not r.d.annul and r.d.pv and not hold_pc) = '1' then
        annul_next := '1'; pv := '0';
    end if;
    if (rabpmiss and r.a.ctrl.inst(29) and not r.d.annul and r.d.pv ) = '1' then
        annul_next := '1'; pv := '0'; inhibit_current := '1';
    end if;

    if (hold_pc or de_rexhold) = '1' then de_pc := r.d.pc; else de_pc := r.f.pc; end if;

    annul_current := (annul_current or (ldlock and not inhibit_current) or annul_all or de_rexbubble);
    annul_current := annul_current and not de_rexillinst;
    ctrl_annul := r.d.annul or annul_all or annul_current or inhibit_current;
    pv := pv and not ((r.d.inull and not hold_pc) or annul_all or de_rexmaskpv);
    jmpl_inst := de_jmpl and not annul_current and not inhibit_current;
    annul_next := (r.d.inull and not hold_pc) or annul_next or annul_all;
    if (annul_next = '1') or (rstn = '0') then
      cnt := (others => '0'); 
    end if;

    de_hold_pc := hold_pc; de_branch := branch; de_annul := annul_next;
    de_pv := pv; ctrl_pv := r.d.pv and 
        not ((r.d.annul and not r.d.pv) or annul_all or annul_current);
    inull := (not rstn) or r.d.inull or hold_pc or annul_all;

  end;

-- register write address generation

  procedure rd_gen(r : registers; inst : word; wreg, ld : out std_ulogic; 
        rdo : out std_logic_vector(4 downto 0); rexen: out std_ulogic) is
  variable write_reg : std_ulogic;
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable rd  : std_logic_vector(4 downto 0);
  variable vrexen: std_ulogic;
  begin

    op    := inst(31 downto 30);
    op2   := inst(24 downto 22);
    op3   := inst(24 downto 19);

    write_reg := '0'; rd := inst(29 downto 25); ld := '0';
    vrexen := '0';

    case op is
    when CALL =>
        write_reg := '1'; rd := "01111";    -- CALL saves PC in r[15] (%o7)
    when FMT2 => 
        if (op2 = SETHI) then write_reg := '1'; end if;
    when FMT3 =>
        case op3 is
        when UMUL | SMUL | UMULCC | SMULCC => 
          if MULEN then
            if (((mulo.nready = '1') and (r.d.cnt /= "00")) or (MULTYPE /= 0)) then
              write_reg := '1'; 
            end if;
          else write_reg := '1'; end if;
        when UDIV | SDIV | UDIVCC | SDIVCC => 
          if DIVEN then
            if (divo.nready = '1') and (r.d.cnt /= "00") then
              write_reg := '1'; 
            end if;
          else write_reg := '1'; end if;
        when RETT | WRPSR | WRY | WRWIM | WRTBR | TICC | FLUSH => null;
        when FPOP1 | FPOP2 => null;
        when CPOP1 | CPOP2 => null;
        when SAVE | IADD =>
          write_reg := '1';
          if REX /= 0 and inst(13)='0' and inst(12)='1' then
            vrexen := '1';
          end if;
        when others => write_reg := '1';
        end case;
      when others =>   -- LDST
        ld := not op3(2);
        if (op3(2) = '0') and not ((CPEN or FPEN) and (op3(5) = '1')) 
        then write_reg := '1'; end if;
        case op3 is
        when SWAP | SWAPA | LDSTUB | LDSTUBA | CASA =>
          if r.d.cnt = "00" then write_reg := '1'; ld := '1'; end if;
        when others => null;
        end case;
        if r.d.cnt = "01" then
          case op3 is
          when LDD | LDDA | LDDC | LDDF => rd(0) := '1';
          when others =>
          end case;
        end if;
    end case;

    if (rd = "00000") then write_reg := '0'; end if;
    wreg := write_reg; rdo := rd; rexen := vrexen;
  end;

-- immediate data generation

  function imm_data (r : registers; insn : word; de_reximmexp: std_ulogic; de_reximmval: std_logic_vector(31 downto 13))
        return word is
  variable immediate_data, inst : word;
  begin
    immediate_data := (others => '0'); inst := insn;
    case inst(31 downto 30) is
    when FMT2 =>
      immediate_data := inst(21 downto 0) & "0000000000";
    when others =>      -- LDST
      immediate_data(31 downto 13) := (others => inst(12));
      immediate_data(12 downto 0) := inst(12 downto 0);
    end case;
    if REX=1 and de_reximmexp='1' then
      immediate_data(31 downto 13) := de_reximmval(31 downto 13);
    end if;
    return(immediate_data);
  end;

-- read special registers
  function get_spr (r : registers; xc_wimmask: std_logic_vector) return word is
  variable spr : word;
  begin
    spr := (others => '0');
      case r.e.ctrl.inst(24 downto 19) is
      when RDPSR => spr(31 downto 5) := conv_std_logic_vector(IMPL,4) &
        conv_std_logic_vector(VER,4) & r.m.icc & "000000" & r.w.s.ec & r.w.s.ef & 
        r.w.s.pil & r.e.su & r.w.s.ps & r.e.et;
        spr(NWINLOG2-1 downto 0) := r.e.cwp;
        if AWPEN then spr(15 downto 14) := r.e.aw & r.e.paw; end if;
      when RDTBR => spr(31 downto 4) := r.w.s.tba & r.w.s.tt;
      when RDWIM => spr(NWIN-1 downto 0) := r.w.s.wim;
                    if RFPART then spr(NWIN-1 downto 0) := r.w.s.wim and not xc_wimmask; end if;
      when others =>
      end case;
    return(spr);
  end;

-- immediate data select

  function imm_select(inst : word; de_rexen: std_ulogic) return boolean is
  variable imm : boolean;
  begin
    imm := false;
    if REX=1 and de_rexen='1' then imm:=true; end if;
    case inst(31 downto 30) is
    when FMT2 =>
      case inst(24 downto 22) is
      when SETHI => imm := true;
      when others => 
      end case;
    when FMT3 =>
      case inst(24 downto 19) is
      when RDWIM | RDPSR | RDTBR => imm := true;
      when others => if (inst(13) = '1') then imm := true; end if;
      end case;
    when LDST => 
      if (inst(13) = '1') then imm := true; end if;
    when others => 
    end case;
    return(imm);
  end;

-- EXE operation

  procedure alu_op(r : in registers; iop1, iop2 : in word; me_icc : std_logic_vector(3 downto 0);
        my, ldbp : std_ulogic; aop1, aop2 : out word; aluop  : out std_logic_vector(2 downto 0);
        alusel : out std_logic_vector(1 downto 0); aluadd : out std_ulogic;
        shcnt : out std_logic_vector(4 downto 0); sari, shleft, ymsb, 
        mulins, divins, mulstep, macins, ldbp2, invop2 : out std_logic
        ) is
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable rs1, rs2, rd  : std_logic_vector(4 downto 0);
  variable icc : std_logic_vector(3 downto 0);
  variable y0, i  : std_ulogic;
  begin

    op   := r.a.ctrl.inst(31 downto 30);
    op2  := r.a.ctrl.inst(24 downto 22);
    op3  := r.a.ctrl.inst(24 downto 19);
    rs1 := r.a.ctrl.inst(18 downto 14); i := r.a.ctrl.inst(13);
    rs2 := r.a.ctrl.inst(4 downto 0); rd := r.a.ctrl.inst(29 downto 25);
    aop1 := iop1; aop2 := iop2; ldbp2 := ldbp;
    aluop := EXE_NOP; alusel := EXE_RES_MISC; aluadd := '1'; 
    shcnt := iop2(4 downto 0); sari := '0'; shleft := '0'; invop2 := '0';
    ymsb := iop1(0); mulins := '0'; divins := '0'; mulstep := '0';
    macins := '0';

    if r.e.ctrl.wy = '1' then y0 := my;
    elsif r.m.ctrl.wy = '1' then y0 := r.m.y(0);
    elsif r.x.ctrl.wy = '1' then y0 := r.x.y(0);
    else y0 := r.w.s.y(0); end if;

    if r.e.ctrl.wicc = '1' then icc := me_icc;
    elsif r.m.ctrl.wicc = '1' then icc := r.m.icc;
    elsif r.x.ctrl.wicc = '1' then icc := r.x.icc;
    else icc := r.w.s.icc; end if;

    case op is
    when CALL =>
      aluop := EXE_LINK;
    when FMT2 =>
      case op2 is
      when SETHI => aluop := EXE_PASS2;
      when others =>
      end case;
    when FMT3 =>
      case op3 is
      when IADD | ADDX | ADDCC | ADDXCC | TADDCC | TADDCCTV | SAVE | RESTORE |
           TICC | JMPL | RETT  => alusel := EXE_RES_ADD;
      when ISUB | SUBX | SUBCC | SUBXCC | TSUBCC | TSUBCCTV  => 
        alusel := EXE_RES_ADD; aluadd := '0'; aop2 := not iop2; invop2 := '1';
      when MULSCC => alusel := EXE_RES_ADD;
        aop1 := (icc(3) xor icc(1)) & iop1(31 downto 1);
        if y0 = '0' then aop2 := (others => '0'); ldbp2 := '0'; end if;
        mulstep := '1';
      when UMUL | UMULCC | SMUL | SMULCC => 
        if MULEN then mulins := '1'; end if;
      when UMAC | SMAC => 
        if MACEN then mulins := '1'; macins := '1'; end if;
      when UDIV | UDIVCC | SDIV | SDIVCC => 
        if DIVEN then 
          aluop := EXE_DIV; alusel := EXE_RES_LOGIC; divins := '1';
        end if;
      when IAND | ANDCC => aluop := EXE_AND; alusel := EXE_RES_LOGIC;
      when ANDN | ANDNCC => aluop := EXE_ANDN; alusel := EXE_RES_LOGIC;
      when IOR | ORCC  => aluop := EXE_OR; alusel := EXE_RES_LOGIC;
      when ORN | ORNCC  => aluop := EXE_ORN; alusel := EXE_RES_LOGIC;
      when IXNOR | XNORCC  => aluop := EXE_XNOR; alusel := EXE_RES_LOGIC;
      when XORCC | IXOR | WRPSR | WRWIM | WRTBR | WRY  => 
        aluop := EXE_XOR; alusel := EXE_RES_LOGIC;
      when RDPSR | RDTBR | RDWIM => aluop := EXE_SPR;
      when RDY => aluop := EXE_RDY;
      when ISLL => aluop := EXE_SLL; alusel := EXE_RES_SHIFT; shleft := '1'; 
                   shcnt := not iop2(4 downto 0); invop2 := '1';
      when ISRL => aluop := EXE_SRL; alusel := EXE_RES_SHIFT; 
      when ISRA => aluop := EXE_SRA; alusel := EXE_RES_SHIFT; sari := iop1(31);
      when FPOP1 | FPOP2 =>
      when others =>
      end case;
    when others =>      -- LDST
      case r.a.ctrl.cnt is
      when "00" =>
        alusel := EXE_RES_ADD;
      when "01" =>
        case op3 is
        when LDD | LDDA | LDDC => alusel := EXE_RES_ADD;
        when LDDF => alusel := EXE_RES_ADD;
        when SWAP | SWAPA | LDSTUB | LDSTUBA | CASA => alusel := EXE_RES_ADD;
        when STF | STDF =>
        when others =>
          aluop := EXE_PASS1;
          if op3(2) = '1' then 
            if op3(1 downto 0) = "01" then aluop := EXE_STB;
            elsif op3(1 downto 0) = "10" then aluop := EXE_STH; end if;
          end if;
        end case;
      when "10" =>
        aluop := EXE_PASS1;
        if op3(2) = '1' then  -- ST
          if (op3(3) and not op3(5) and not op3(1))= '1' then aluop := EXE_ONES; end if; -- LDSTUB
        end if;
        if CASAEN and (r.m.casa = '1') and LDDEL=1 then
          alusel := EXE_RES_ADD; aluadd := '0'; aop2 := not iop2; invop2 := '1';
        end if;
      when others =>
      end case;
    end case;
  end;

  function ra_inull_gen(r, v : registers) return std_ulogic is
  variable de_inull : std_ulogic;
  begin
    de_inull := '0';
    if ((v.e.jmpl or v.e.ctrl.rett) and not v.e.ctrl.annul and not (r.e.jmpl and not r.e.ctrl.annul)) = '1' then de_inull := '1'; end if;
    if ((v.a.jmpl or v.a.ctrl.rett) and not v.a.ctrl.annul and not (r.a.jmpl and not r.a.ctrl.annul)) = '1' then de_inull := '1'; end if;
    return(de_inull);    
  end;

-- operand generation

  procedure op_mux(r : in registers; rfd, ed, md, xd, im : in word; 
        rsel : in std_logic_vector(2 downto 0); 
        ldbp : out std_ulogic; d : out word; id : std_logic) is
  begin
    ldbp := '0';
    case rsel is
    when "000" => d := rfd;
    when "001" => d := ed;
    when "010" => d := md; if lddel = 1 then ldbp := r.m.ctrl.ld; end if;
    when "011" => d := xd;
                  if (CASAEN and lddel=2) and (r.m.casa='1' and r.a.ctrl.cnt="11" and id='1') then d:=xd xor rfd; end if;
    when "100" => d := im;
    when "101" => d := (others => '0');
    when "110" => d := r.w.result;
    when others => d := (others => '-');
    end case;
    if CASAEN and (r.a.ctrl.cnt = "10") and ((r.m.casa and not id) = '1') then ldbp := '1'; end if;
    if REX=1 and r.a.getpc='1' and id='0' then
      d := r.a.ctrl.pc;
      d(0) := '0';
    end if;
  end;

  procedure op_find(r : in registers; ldchkra : std_ulogic; ldchkex : std_ulogic;
         rs1 : std_logic_vector(4 downto 0); ra : rfatype; im : boolean; rfe : out std_ulogic; 
        osel : out std_logic_vector(2 downto 0); ldcheck : std_ulogic) is
  begin
    rfe := '0';
    if im then osel := "100";
    elsif rs1 = "00000" then osel := "101";     -- %g0
    elsif ((r.a.ctrl.wreg and ldchkra) = '1') and (ra = r.a.ctrl.rd) then osel := "001";
    elsif ((r.e.ctrl.wreg and ldchkex) = '1') and (ra = r.e.ctrl.rd) then osel := "010";                                        
    elsif (r.m.ctrl.wreg = '1') and (ra = r.m.ctrl.rd) then osel := "011";             
    elsif (irfwt = 0) and (r.x.ctrl.wreg = '1') and (ra = r.x.ctrl.rd) then osel := "110"; 
    else  osel := "000"; rfe := ldcheck; end if;
  end;

-- generate carry-in for alu

  procedure cin_gen(r : registers; me_cin : in std_ulogic; cin : out std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable ncin : std_ulogic;
  begin

    op := r.a.ctrl.inst(31 downto 30); op3 := r.a.ctrl.inst(24 downto 19);
    if r.e.ctrl.wicc = '1' then ncin := me_cin;
    else ncin := r.m.icc(0); end if;
    cin := '0';
    case op is
    when FMT3 =>
      case op3 is
      when ISUB | SUBCC | TSUBCC | TSUBCCTV => cin := '1';
      when ADDX | ADDXCC => cin := ncin; 
      when SUBX | SUBXCC => cin := not ncin; 
      when others => null;
      end case;
    when LDST =>
      if CASAEN and (r.m.casa = '1') and
        ((r.a.ctrl.cnt = "10" and LDDEL=1) or (r.a.ctrl.cnt = "11" and LDDEL=2)) then
        cin := '1';
      end if;
    when others => null;
    end case;
  end;

  procedure logic_op(r : registers; aluin1, aluin2, mey : word; 
        ymsb : std_ulogic; logicres, y : out word) is
  variable logicout : word;
  begin
    case r.e.aluop is
    when EXE_AND   => logicout := aluin1 and aluin2;
    when EXE_ANDN  => logicout := aluin1 and not aluin2;
    when EXE_OR    => logicout := aluin1 or aluin2;
    when EXE_ORN   => logicout := aluin1 or not aluin2;
    when EXE_XOR   => logicout := aluin1 xor aluin2;
    when EXE_XNOR  => logicout := aluin1 xor not aluin2;
    when EXE_DIV   => 
      if DIVEN then logicout := aluin2;
      else logicout := (others => '-'); end if;
    when others => logicout := (others => '-');
    end case;
    if (r.e.ctrl.wy and r.e.mulstep) = '1' then 
      y := ymsb & r.m.y(31 downto 1); 
    elsif r.e.ctrl.wy = '1' then y := logicout;
    elsif r.m.ctrl.wy = '1' then y := mey; 
    elsif MACPIPE and (r.x.mac = '1') then y := mulo.result(63 downto 32);
    elsif r.x.ctrl.wy = '1' then y := r.x.y; 
    else y := r.w.s.y; end if;
    logicres := logicout;
  end;

  function st_align(size : std_logic_vector(1 downto 0); bpdata : word) return word is
  variable edata : word;
  begin
    case size is
    when "01"   => edata := bpdata(7 downto 0) & bpdata(7 downto 0) &
                             bpdata(7 downto 0) & bpdata(7 downto 0);
    when "10"   => edata := bpdata(15 downto 0) & bpdata(15 downto 0);
    when others    => edata := bpdata;
    end case;
    return(edata);
  end;

  procedure misc_op(r : registers; wpr : watchpoint_registers; 
        aluin1, aluin2, ldata, mey : word; xc_wimmask: std_logic_vector;
        core_id : integer range 0 to 15;
        mout, edata : out word) is
  variable miscout, bpdata, stdata : word;
  variable wpi : integer;
  begin
    wpi := 0;
    miscout := (others => '0');
    miscout(31 downto PCLOW) := r.e.ctrl.pc(31 downto PCLOW);
    if REX/=0 and r.e.ctrl.pc(PCLOW)='1' then
      miscout(31 downto 2) := miscout(31 downto 2)-1;
    end if;
    edata := aluin1; bpdata := aluin1;
    if ((r.x.ctrl.wreg and r.x.ctrl.ld and not r.x.ctrl.annul) = '1') and
       (r.x.ctrl.rd = r.e.ctrl.rd) and (r.e.ctrl.inst(31 downto 30) = LDST) and
        (r.e.ctrl.cnt /= "10")
    then bpdata := ldata; end if;

    case r.e.aluop is
    when EXE_STB   => miscout := bpdata(7 downto 0) & bpdata(7 downto 0) &
                             bpdata(7 downto 0) & bpdata(7 downto 0);
                      edata := miscout;
    when EXE_STH   => miscout := bpdata(15 downto 0) & bpdata(15 downto 0);
                      edata := miscout;
    when EXE_PASS1 => miscout := bpdata; edata := miscout;
    when EXE_PASS2 => miscout := aluin2;
    when EXE_ONES  => miscout := (others => '1');
                      edata := miscout;
    when EXE_RDY  => 
      if MULEN and (r.m.ctrl.wy = '1') then miscout := mey;
      else miscout := r.m.y; end if;
      if (NWP > 0) and (r.e.ctrl.inst(18 downto 17) = "11") then
        wpi := conv_integer(r.e.ctrl.inst(16 downto 15));
        if r.e.ctrl.inst(14) = '0' then miscout := wpr(wpi).addr & '0' & wpr(wpi).exec;
        else miscout := wpr(wpi).mask & wpr(wpi).load & wpr(wpi).store; end if;
      end if;
      if (r.e.ctrl.inst(18 downto 17) = "10") and (r.e.ctrl.inst(14) = '1') then --%ASR17
        miscout := asr17_gen(r, core_id);
      end if;

      if MACEN then
        if (r.e.ctrl.inst(18 downto 14) = "10010") then --%ASR18
          if ((r.m.mac = '1') and not MACPIPE) or ((r.x.mac = '1') and MACPIPE) then
            miscout := mulo.result(31 downto 0);        -- data forward of asr18
          else miscout := r.w.s.asr18; end if;
        else
          if ((r.m.mac = '1') and not MACPIPE) or ((r.x.mac = '1') and MACPIPE) then
            miscout := mulo.result(63 downto 32);   -- data forward Y
          end if;
        end if;
      end if;

      if AWPEN or RFPART then
        if (r.e.ctrl.inst(18 downto 14) = "10100") then  -- %asr20
          miscout := (others => '0');
          if AWPEN then
            miscout(NWINLOG2-1 downto 0) := r.e.awp;
          end if;
          if RFPART then
            miscout(20+NWINLOG2 downto 21) := r.w.s.stwin;
            miscout(15+NWINLOG2 downto 16) := r.w.s.cwpmax;
          end if;
        end if;
      end if;
    when EXE_SPR  => 
      miscout := get_spr(r, xc_wimmask);
    when others => null;
    end case;
    mout := miscout;
  end;

  procedure alu_select(r : registers; addout : std_logic_vector(32 downto 0);
        op1, op2 : word; shiftout, logicout, miscout : word; res : out word; 
        me_icc : std_logic_vector(3 downto 0);
        icco : out std_logic_vector(3 downto 0); divz, mzero : out std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable icc : std_logic_vector(3 downto 0);
  variable aluresult : word;
  variable azero : std_logic;
  begin
    op   := r.e.ctrl.inst(31 downto 30); op3  := r.e.ctrl.inst(24 downto 19);
    icc := (others => '0');
    if addout(32 downto 1) = zero32 then azero := '1'; else azero := '0'; end if;
    mzero := azero;
    case r.e.alusel is
    when EXE_RES_ADD => 
      aluresult := addout(32 downto 1);
      if r.e.aluadd = '0' then
        icc(0) := ((not op1(31)) and not op2(31)) or    -- Carry
                 (addout(32) and ((not op1(31)) or not op2(31)));
        icc(1) := (op1(31) and (op2(31)) and not addout(32)) or         -- Overflow
                 (addout(32) and (not op1(31)) and not op2(31));
      else
        icc(0) := (op1(31) and op2(31)) or      -- Carry
                 ((not addout(32)) and (op1(31) or op2(31)));
        icc(1) := (op1(31) and op2(31) and not addout(32)) or   -- Overflow
                 (addout(32) and (not op1(31)) and (not op2(31)));
      end if;
      if notag = 0 then
        case op is 
        when FMT3 =>
          case op3 is
          when TADDCC | TADDCCTV =>
            icc(1) := op1(0) or op1(1) or op2(0) or op2(1) or icc(1);
          when TSUBCC | TSUBCCTV =>
            icc(1) := op1(0) or op1(1) or (not op2(0)) or (not op2(1)) or icc(1);
          when others => null;
          end case;
        when others => null;
        end case;
      end if;

--      if aluresult = zero32 then icc(2) := '1'; end if;
      icc(2) := azero;
    when EXE_RES_SHIFT => aluresult := shiftout;
    when EXE_RES_LOGIC => aluresult := logicout;
      if aluresult = zero32 then icc(2) := '1'; end if;
    when others => aluresult := miscout;
    end case;
    if r.e.jmpl = '1' then aluresult := r.e.ctrl.pc(31 downto 2) & "00"; end if;
    icc(3) := aluresult(31); divz := icc(2);
    if r.e.ctrl.wicc = '1' then
      if (op = FMT3) and (op3 = WRPSR) then icco := logicout(23 downto 20);
      else icco := icc; end if;
    elsif r.m.ctrl.wicc = '1' then icco := me_icc;
    elsif r.x.ctrl.wicc = '1' then icco := r.x.icc;
    else icco := r.w.s.icc; end if;
    res := aluresult;
  end;

  procedure dcache_gen(r, v : registers; dci : out dc_in_type; 
        link_pc, jump, force_a2, load, mcasa : out std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable su, lock : std_ulogic;
  begin
    op := r.e.ctrl.inst(31 downto 30); op3 := r.e.ctrl.inst(24 downto 19);
    dci.signed := '0'; dci.lock := '0'; dci.dsuen := '0'; dci.size := SZWORD;
    mcasa := '0';
    if op = LDST then
    case op3 is
      when LDUB | LDUBA => dci.size := SZBYTE;
      when LDSTUB | LDSTUBA => dci.size := SZBYTE; dci.lock := '1'; 
      when LDUH | LDUHA => dci.size := SZHALF;
      when LDSB | LDSBA => dci.size := SZBYTE; dci.signed := '1';
      when LDSH | LDSHA => dci.size := SZHALF; dci.signed := '1';
      when LD | LDA | LDF | LDC => dci.size := SZWORD;
      when SWAP | SWAPA => dci.size := SZWORD; dci.lock := '1'; 
      when CASA => if CASAEN then dci.size := SZWORD; dci.lock := '1'; end if;
      when LDD | LDDA | LDDF | LDDC => dci.size := SZDBL;
      when STB | STBA => dci.size := SZBYTE;
      when STH | STHA => dci.size := SZHALF;
      when ST | STA | STF => dci.size := SZWORD;
      when ISTD | STDA => dci.size := SZDBL;
      when STDF | STDFQ => if FPEN then dci.size := SZDBL; end if;
      when STDC | STDCQ => if CPEN then dci.size := SZDBL; end if;
      when others => dci.size := SZWORD; dci.lock := '0'; dci.signed := '0';
    end case;
    end if;

    link_pc := '0'; jump:= '0'; force_a2 := '0'; load := '0';
    dci.write := '0'; dci.enaddr := '0'; dci.read := not op3(2);

-- load/store control decoding

    if (r.e.ctrl.annul or r.e.ctrl.trap) = '0' then
      case op is
      when CALL => link_pc := '1';
      when FMT3 =>
        if r.e.ctrl.trap = '0' then
          case op3 is
          when JMPL => jump := '1'; link_pc := '1'; 
          when RETT => if REX=0 or r.f.pc(0+2*(1-REX))='0' then jump := '1'; end if;
          when others => null;
          end case;
        end if;
      when LDST =>
          case r.e.ctrl.cnt is
          when "00" =>
            dci.read := op3(3) or not op3(2);   -- LD/LDST/SWAP/CASA
            load := op3(3) or not op3(2);
            --dci.enaddr := '1';
            dci.enaddr := (not op3(2)) or op3(2)
                          or (op3(3) and op3(2));
          when "01" =>
            force_a2 := not op3(2);     -- LDD
            load := not op3(2); dci.enaddr := not op3(2);
            if op3(3 downto 2) = "01" then              -- ST/STD
              dci.write := '1';              
            end if;
            if (op3(3 downto 2) = "11") and -- LDST/SWAP/CASA
              not (CASAEN and LDDEL=2 and op3(5 downto 4)="11")
            then
              dci.enaddr := '1';
            end if;
            if (CASAEN and LDDEL=2 and op3(5 downto 4)="11") then
              dci.read := '1';
            end if;
          when "10" =>                                  -- STD/LDST/SWAP/CASA
            dci.write := '1';
            if (CASAEN and LDDEL=2 and (op3(5 downto 4) = "11")) then -- CASA
              dci.enaddr := '1';
              dci.write := '0';
            end if;
          when others =>
            if (CASAEN and LDDEL=2 and (op3(5 downto 4) = "11")) then -- CASA
              dci.write := '1';
            end if;
          end case;
          if (r.e.ctrl.trap or (v.x.ctrl.trap and not v.x.ctrl.annul)) = '1' then 
            dci.enaddr := '0';
          end if;
          if (CASAEN and (op3(5 downto 4) = "11")) then mcasa := '1'; end if;
      when others => null;
      end case;
    end if;

    if ((r.x.ctrl.rett and not r.x.ctrl.annul) = '1') then su := r.w.s.ps;
    else su := r.w.s.s; end if;
    if su = '1' then dci.asi := "00001011"; else dci.asi := "00001010"; end if;
    if (op3(4) = '1') and ((op3(5) = '0') or not CPEN) then
      dci.asi := r.e.ctrl.inst(12 downto 5);
      if r.e.ctrl.inst(12 downto 10) /= "000" then dci.enaddr := '0'; end if;
    end if;

  end;

  procedure fpstdata(r : in registers; edata, eres : in word; fpstdata : in std_logic_vector(31 downto 0);
                       edata2, eres2 : out word) is
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
  begin
    edata2 := edata; eres2 := eres;
    op := r.e.ctrl.inst(31 downto 30); op3 := r.e.ctrl.inst(24 downto 19);
    if FPEN then
      if FPEN and (op = LDST) and  ((op3(5 downto 4) & op3(2)) = "101") and (r.e.ctrl.cnt /= "00") then
        edata2 := fpstdata; eres2 := fpstdata;
      end if;
    end if;
    if CASAEN and (r.m.casa = '1') and r.e.ctrl.cnt(1)='1' then
      edata2 := r.e.op1; eres2 := r.e.op1;
    end if;
  end;
  
  function ld_align(data : dcdtype; set : std_logic_vector(DSETMSB downto 0);
        size, laddr : std_logic_vector(1 downto 0); signed : std_ulogic) return word is
  variable align_data, rdata : word;
  begin
    align_data := data(conv_integer(set)); rdata := (others => '0');
    case size is
    when "00" =>                        -- byte read
      case laddr is
      when "00" => 
        rdata(7 downto 0) := align_data(31 downto 24);
        if signed = '1' then rdata(31 downto 8) := (others => align_data(31)); end if;
      when "01" => 
        rdata(7 downto 0) := align_data(23 downto 16);
        if signed = '1' then rdata(31 downto 8) := (others => align_data(23)); end if;
      when "10" => 
        rdata(7 downto 0) := align_data(15 downto 8);
        if signed = '1' then rdata(31 downto 8) := (others => align_data(15)); end if;
      when others => 
        rdata(7 downto 0) := align_data(7 downto 0);
        if signed = '1' then rdata(31 downto 8) := (others => align_data(7)); end if;
      end case;
    when "01" =>                        -- half-word read
      if  laddr(1) = '1' then 
        rdata(15 downto 0) := align_data(15 downto 0);
        if signed = '1' then rdata(31 downto 15) := (others => align_data(15)); end if;
      else
        rdata(15 downto 0) := align_data(31 downto 16);
        if signed = '1' then rdata(31 downto 15) := (others => align_data(31)); end if;
      end if;
    when others =>                      -- single and double word read
      rdata := align_data;
    end case;
    return(rdata);
  end;

  
  procedure mem_trap(r : registers; wpr : watchpoint_registers;
                     annul, holdn : in std_ulogic;
                     trapout, iflush, nullify, werrout : out std_ulogic;
                     tt : out std_logic_vector(5 downto 0)) is
  variable cwp   : std_logic_vector(NWINLOG2-1 downto 0);
  variable cwpx  : std_logic_vector(5 downto NWINLOG2);
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable nalign_d : std_ulogic;
  variable trap, werr : std_ulogic;
  begin
    op := r.m.ctrl.inst(31 downto 30); op2  := r.m.ctrl.inst(24 downto 22);
    op3 := r.m.ctrl.inst(24 downto 19);
    cwpx := r.m.result(5 downto NWINLOG2); cwpx(5) := '0';
    iflush := '0'; trap := r.m.ctrl.trap; nullify := annul;
    tt := r.m.ctrl.tt; werr := (dco.werr or r.m.werr) and not r.w.s.dwt;
    nalign_d := r.m.nalign or r.m.result(2); 
    if (trap = '1') and (r.m.ctrl.pv = '1') then
      if op = LDST then nullify := '1'; end if;
    end if;
    if ((annul or trap) /= '1') and (r.m.ctrl.pv = '1') then
      if (werr and holdn) = '1' then
        trap := '1'; tt := TT_DSEX; werr := '0';
        if op = LDST then nullify := '1'; end if;
      end if;
    end if;
    if ((annul or trap) /= '1') then      
      case op is
      when FMT2 =>
        case op2 is
        when FBFCC => 
          if FPEN and (fpo.exc = '1') then trap := '1'; tt := TT_FPEXC; end if;
        when CBCCC =>
          if CPEN and (cpo.exc = '1') then trap := '1'; tt := TT_CPEXC; end if;
        when others => null;
        end case;
      when FMT3 =>
        case op3 is
        when WRPSR =>
          if (orv(cwpx) = '1') then trap := '1'; tt := TT_IINST; end if;
        when UDIV | SDIV | UDIVCC | SDIVCC =>
          if DIVEN then 
            if r.m.divz = '1' then trap := '1'; tt := TT_DIV; end if;
          end if;
        when JMPL | RETT =>
          if (REX=1 and r.m.rexnalign='1') or (REX=0 and r.m.nalign = '1') then
            trap := '1'; tt := TT_UNALA;
          end if;
        when TADDCCTV | TSUBCCTV =>
          if (notag = 0) and (r.m.icc(1) = '1') then
            trap := '1'; tt := TT_TAG;
          end if;
        when FLUSH => iflush := '1';
        when FPOP1 | FPOP2 =>
          if FPEN and (fpo.exc = '1') then trap := '1'; tt := TT_FPEXC; end if;
        when CPOP1 | CPOP2 =>
          if CPEN and (cpo.exc = '1') then trap := '1'; tt := TT_CPEXC; end if;
        when others => null;
        end case;
      when LDST =>
        if r.m.ctrl.cnt = "00" then
          case op3 is
            when LDDF | STDF | STDFQ =>
            if FPEN then
              if nalign_d = '1' then
                trap := '1'; tt := TT_UNALA; nullify := '1';
              elsif (fpo.exc and r.m.ctrl.pv) = '1' 
              then trap := '1'; tt := TT_FPEXC; nullify := '1'; end if;
            end if;
          when LDDC | STDC | STDCQ =>
            if CPEN then
              if nalign_d = '1' then
                trap := '1'; tt := TT_UNALA; nullify := '1';
              elsif ((cpo.exc and r.m.ctrl.pv) = '1') 
              then trap := '1'; tt := TT_CPEXC; nullify := '1'; end if;
            end if;
          when LDD | ISTD | LDDA | STDA =>
            if r.m.result(2 downto 0) /= "000" then
              trap := '1'; tt := TT_UNALA; nullify := '1';
            end if;
          when LDF | LDFSR | STFSR | STF =>
            if FPEN and (r.m.nalign = '1') then
              trap := '1'; tt := TT_UNALA; nullify := '1';
            elsif FPEN and ((fpo.exc and r.m.ctrl.pv) = '1')
            then trap := '1'; tt := TT_FPEXC; nullify := '1'; end if;
          when LDC | LDCSR | STCSR | STC =>
            if CPEN and (r.m.nalign = '1') then 
              trap := '1'; tt := TT_UNALA; nullify := '1';
            elsif CPEN and ((cpo.exc and r.m.ctrl.pv) = '1') 
            then trap := '1'; tt := TT_CPEXC; nullify := '1'; end if;
          when LD | LDA | ST | STA | SWAP | SWAPA | CASA =>
            if r.m.result(1 downto 0) /= "00" then
              trap := '1'; tt := TT_UNALA; nullify := '1';
            end if;
          when LDUH | LDUHA | LDSH | LDSHA | STH | STHA =>
            if r.m.result(0) /= '0' then
              trap := '1'; tt := TT_UNALA; nullify := '1';
            end if;
          when others => null;
          end case;
          for i in 1 to NWP loop
            if ((((wpr(i-1).load and not op3(2)) or (wpr(i-1).store and op3(2))) = '1') and
                (((wpr(i-1).addr xor r.m.result(31 downto 2)) and wpr(i-1).mask) = zero32(31 downto 2)))
            then trap := '1'; tt := TT_WATCH; nullify := '1'; end if;
          end loop;
        end if;
      when others => null;
      end case;
    end if;
    if (rstn = '0') or (r.x.rstate = dsu2) then werr := '0'; end if;
    trapout := trap; werrout := werr;
  end;

  procedure irq_trap(r       : in registers;
                     ir      : in irestart_register;
                     irl     : in std_logic_vector(3 downto 0);
                     annul   : in std_ulogic;
                     pv      : in std_ulogic;
                     trap    : in std_ulogic;
                     tt      : in std_logic_vector(5 downto 0);
                     nullify : in std_ulogic;
                     irqen   : out std_ulogic;
                     irqen2  : out std_ulogic;
                     nullify2 : out std_ulogic;
                     trap2, ipend  : out std_ulogic;
                     tt2      : out std_logic_vector(5 downto 0)) is
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
    variable pend : std_ulogic;
  begin
    nullify2 := nullify; trap2 := trap; tt2 := tt; 
    op := r.m.ctrl.inst(31 downto 30); op3 := r.m.ctrl.inst(24 downto 19);
    irqen := '1'; irqen2 := r.m.irqen;

    if (annul or trap) = '0' then
      if ((op = FMT3) and (op3 = WRPSR)) then irqen := '0'; end if;    
    end if;

    if (irl = "1111") or (irl > r.w.s.pil) then
      pend := r.m.irqen and r.m.irqen2 and r.w.s.et and not ir.pwd
      ;
    else pend := '0'; end if;
    ipend := pend;

    if ((not annul) and pv and (not trap) and pend) = '1' then
      trap2 := '1'; tt2 := "01" & irl;
      if op = LDST then nullify2 := '1'; end if;
    end if;
  end;

  procedure irq_intack(r : in registers; holdn : in std_ulogic; intack: out std_ulogic) is 
  begin
    intack := '0';
    if r.x.rstate = trap then 
      if r.w.s.tt(7 downto 4) = "0001" then intack := '1'; end if;
    end if;
  end;
  
-- write special registers

  procedure sp_write (r : registers; wpr : watchpoint_registers;
        s : out special_register_type; vwpr : out watchpoint_registers) is
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable rd  : std_logic_vector(4 downto 0);
  variable i   : integer range 0 to 3;
  begin

    op  := r.x.ctrl.inst(31 downto 30);
    op2 := r.x.ctrl.inst(24 downto 22);
    op3 := r.x.ctrl.inst(24 downto 19);
    s   := r.w.s;
    rd  := r.x.ctrl.inst(29 downto 25);
    vwpr := wpr;

    if AWPEN then
      if r.w.s.aw='0' and r.w.s.paw='0' then
        s.awp := r.w.s.cwp;
      end if;
    end if;

      case op is
      when FMT3 =>
        case op3 is
        when WRY =>
          if rd = "00000" then
            s.y := r.x.result;
          elsif MACEN and (rd = "10010") then
            s.asr18 := r.x.result;
          elsif (rd = "10001") then
            if bp = 2 then s.dbp := r.x.result(27); end if;
            if bp = 2 then s.dbprepl := r.x.result(25); end if;
            s.dwt := r.x.result(14);
            if (svt = 1) then s.svt := r.x.result(13); end if;
            if rex=1 then
              s.rexdis:=r.x.result(22);
              s.rextrap:=r.x.result(21);
            end if;
          elsif (AWPEN or RFPART) and rd="10100" then  -- %ASR20
            if AWPEN then
              s.awp := r.x.result(NWINLOG2-1 downto 0);
              if r.x.result(5)='1' then
                s.cwp := r.x.result(NWINLOG2-1 downto 0);
              end if;
            end if;
            if RFPART then
              if r.x.result(15+NWINLOG2 downto 16)/=CWPMIN then
                s.stwin := r.x.result(20+NWINLOG2 downto 21);
                s.cwpmax := r.x.result(15+NWINLOG2 downto 16);
              end if;
            end if;
          elsif rd(4 downto 3) = "11" then -- %ASR24 - %ASR31
            case rd(2 downto 0) is
            when "000" => 
              vwpr(0).addr := r.x.result(31 downto 2);
              vwpr(0).exec := r.x.result(0); 
            when "001" => 
              vwpr(0).mask := r.x.result(31 downto 2);
              vwpr(0).load := r.x.result(1);
              vwpr(0).store := r.x.result(0);              
            when "010" => 
              vwpr(1).addr := r.x.result(31 downto 2);
              vwpr(1).exec := r.x.result(0); 
            when "011" => 
              vwpr(1).mask := r.x.result(31 downto 2);
              vwpr(1).load := r.x.result(1);
              vwpr(1).store := r.x.result(0);              
            when "100" => 
              vwpr(2).addr := r.x.result(31 downto 2);
              vwpr(2).exec := r.x.result(0); 
            when "101" => 
              vwpr(2).mask := r.x.result(31 downto 2);
              vwpr(2).load := r.x.result(1);
              vwpr(2).store := r.x.result(0);              
            when "110" => 
              vwpr(3).addr := r.x.result(31 downto 2);
              vwpr(3).exec := r.x.result(0); 
            when others =>   -- "111"
              vwpr(3).mask := r.x.result(31 downto 2);
              vwpr(3).load := r.x.result(1);
              vwpr(3).store := r.x.result(0);              
            end case;
          end if;
        when WRPSR =>
          if pwrpsr = 0 or rd = "00000" then
            s.cwp := r.x.result(NWINLOG2-1 downto 0);
            s.icc := r.x.result(23 downto 20);
            s.ec  := r.x.result(13);
            if FPEN then s.ef  := r.x.result(12); end if;
            s.pil := r.x.result(11 downto 8);
            s.s   := r.x.result(7);
            s.ps  := r.x.result(6);
            if AWPEN then
              s.aw := r.x.result(15);
              s.paw := r.x.result(14);
            end if;
          end if;
          s.et  := r.x.result(5);
        when WRWIM =>
          s.wim := r.x.result(NWIN-1 downto 0);
        when WRTBR =>
          s.tba := r.x.result(31 downto 12);
        when SAVE =>
          if (not AWPEN) or r.w.s.aw='0' then
            if RFPART and (r.w.s.cwp=CWPMIN) then s.cwp := r.w.s.cwpmax;
            elsif (not CWPOPT) and (r.w.s.cwp = CWPMIN) then s.cwp := CWPMAX;
            else s.cwp := r.w.s.cwp - 1 ; end if;
          end if;
          if AWPEN and r.w.s.aw='1' then
            if RFPART and (r.w.s.awp=CWPMIN) then s.awp := r.w.s.cwpmax;
            elsif (not CWPOPT) and (r.w.s.awp = CWPMIN) then s.awp := CWPMAX;
            else s.awp := r.w.s.awp - 1 ; end if;
          end if;
        when RESTORE =>
          if (not AWPEN) or r.w.s.aw='0' then
            if RFPART and (r.w.s.cwp=r.w.s.cwpmax) then s.cwp := CWPMIN;
            elsif (not CWPOPT) and (r.w.s.cwp = CWPMAX) then s.cwp := CWPMIN;
            else s.cwp := r.w.s.cwp + 1; end if;
          end if;
          if AWPEN and r.w.s.aw='1' then
            if RFPART and (r.w.s.awp=r.w.s.cwpmax) then s.awp := CWPMIN;
            elsif (not CWPOPT) and (r.w.s.awp = CWPMAX) then s.awp := CWPMIN;
            else s.awp := r.w.s.awp + 1; end if;
          end if;
        when RETT =>
          if ((not CWPOPT) and (r.w.s.cwp = CWPMAX)) or (RFPART and (r.w.s.cwp=r.w.s.cwpmax)) then s.cwp := CWPMIN;
          else s.cwp := r.w.s.cwp + 1; end if;
          s.s := r.w.s.ps;
          s.et := '1';
          if AWPEN then
            s.aw := r.w.s.paw;
          end if;
        when others => null;
        end case;
      when others => null;
      end case;
      if r.x.ctrl.wicc = '1' then s.icc := r.x.icc; end if;
      if r.x.ctrl.wy = '1' then s.y := r.x.y; end if;
      if MACPIPE and (r.x.mac = '1') then 
        s.asr18 := mulo.result(31 downto 0);
        s.y := mulo.result(63 downto 32);
      end if;
  end;

  function npc_find (r : registers) return std_logic_vector is
  variable npc : std_logic_vector(2 downto 0);
  begin
    npc := "011";
    if r.m.ctrl.pv = '1' then npc := "000";
    elsif r.e.ctrl.pv = '1' then npc := "001";
    elsif r.a.ctrl.pv = '1' then npc := "010";
    elsif r.d.pv = '1' then npc := "011";
    elsif v8 /= 0 then npc := "100"; end if;
    return(npc);
  end;

  function npc_gen (r : registers; de_pcout: std_logic_vector) return word is
  variable npc : std_logic_vector(31 downto 0);
  begin
    npc := (others => '0');
    npc(31 downto PCLOW) :=  r.a.ctrl.pc(31 downto PCLOW);
    case r.x.npc is
    when "000" => npc(31 downto PCLOW) := r.x.ctrl.pc(31 downto PCLOW);
    when "001" => npc(31 downto PCLOW) := r.m.ctrl.pc(31 downto PCLOW);
    when "010" => npc(31 downto PCLOW) := r.e.ctrl.pc(31 downto PCLOW);
    when "011" => npc(31 downto PCLOW) := r.a.ctrl.pc(31 downto PCLOW);
    when others => 
        if v8 /= 0 then npc(31 downto PCLOW) := de_pcout(31 downto PCLOW); end if;
    end case;
    return(npc);
  end;

  procedure mul_res(r : registers; asr18in : word; result, y, asr18 : out word; 
          icc : out std_logic_vector(3 downto 0)) is
  variable op  : std_logic_vector(1 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  begin
    op    := r.m.ctrl.inst(31 downto 30); op3   := r.m.ctrl.inst(24 downto 19);
    result := r.m.result; y := r.m.y; icc := r.m.icc; asr18 := asr18in;
    case op is
    when FMT3 =>
      case op3 is
      when UMUL | SMUL =>
        if MULEN then 
          result := mulo.result(31 downto 0);
          y := mulo.result(63 downto 32);
        end if;
      when UMULCC | SMULCC =>
        if MULEN then 
          result := mulo.result(31 downto 0); icc := mulo.icc;
          y := mulo.result(63 downto 32);
        end if;
      when UMAC | SMAC =>
        if MACEN and not MACPIPE then
          result := mulo.result(31 downto 0);
          asr18  := mulo.result(31 downto 0);
          y := mulo.result(63 downto 32);
        end if;
      when UDIV | SDIV =>
        if DIVEN then 
          result := divo.result(31 downto 0);
        end if;
      when UDIVCC | SDIVCC =>
        if DIVEN then 
          result := divo.result(31 downto 0); icc := divo.icc;
        end if;
      when others => null;
      end case;
    when others => null;
    end case;
  end;

  function powerdwn(r : registers; trap : std_ulogic; rp : pwd_register_type) return std_ulogic is
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
    variable rd  : std_logic_vector(4 downto 0);
    variable pd  : std_ulogic;
  begin
    op := r.x.ctrl.inst(31 downto 30);
    op3 := r.x.ctrl.inst(24 downto 19);
    rd  := r.x.ctrl.inst(29 downto 25);    
    pd := '0';
    if (not (r.x.ctrl.annul or trap) and r.x.ctrl.pv) = '1' then
      if ((op = FMT3) and (op3 = WRY) and (rd = "10011")) then pd := '1'; end if;
      pd := pd or rp.pwd;
    end if;
    return(pd);
  end;


  function rex_dpc(pcin: pctype; rexen: std_ulogic; rexpos: std_logic_vector(1 downto 0))
    return std_logic_vector is
    variable vpcout: std_logic_vector(31 downto 0);
  begin
    vpcout := pcin(31 downto 2) & rexpos(0) & rexen;
    if rexpos(1)='0' then
      vpcout(31 downto 2) := vpcout(31 downto 2)-1;
    end if;
    return vpcout;
  end;

  function rex_regunp(rn: std_logic_vector(3 downto 0))
    return std_logic_vector is
    variable y: std_logic_vector(4 downto 0);
  begin
    y := "00" & rn(2 downto 0);
    y(4) := rn(3) or rn(2);
    y(3) := rn(3) or (not rn(2));
    return y;
  end rex_regunp;

  procedure rex_decode_main(opin: std_logic_vector(47 downto 0);
                            cntin: std_logic_vector(0 downto 0);
                            opout: out std_logic_vector(31 downto 0);
                            szout: out std_logic_vector(1 downto 0);
                            ncntout: out std_logic_vector(0 downto 0);
                            baddr1: out std_ulogic;
                            immexp: out std_ulogic;
                            immval: out std_logic_vector(31 downto 13);
                            getpc: out std_ulogic;
                            maskpv: out std_ulogic;
                            illinst: out std_ulogic;
                            nostep: out std_ulogic;
                            itovr: out std_ulogic;
                            leave: out std_ulogic) is
    variable vinst48 : std_logic_vector(47 downto 0);
    variable vinst   : std_logic_vector(31 downto 0);
    -- fields extracted from vinst48
    variable rop: std_logic_vector(1 downto 0);
    variable rimm: std_ulogic;
    variable rop3: std_logic_vector(3 downto 0);
    variable rop4: std_logic_vector(4 downto 0);
    variable rop4_4: std_logic_vector(3 downto 0);
    variable rop3l: std_ulogic;
    variable rrd,rrs: std_logic_vector(3 downto 0);
    variable ximm: std_ulogic;
    variable xop3: std_logic_vector(5 downto 0);
    variable xfpop: std_logic_vector(6 downto 0);
    variable xrdalt: std_ulogic;
    variable xrs1alt: std_ulogic;
    variable xrs2imm: std_logic_vector(6 downto 0);
    -- computed from fields
    variable isz: std_logic_vector(1 downto 0);
    variable vpos: std_logic_vector(1 downto 0);
    variable vhold,vbubble,vexpand,villinst,vnostep: std_ulogic;
    variable vbaddr1, vbitop, veximm, vmask, vgetpc: std_ulogic;
    variable eximmval: std_logic_vector(31 downto 13);
    variable dop: std_logic_vector(1 downto 0);
    variable drd, drs1, drs2: std_logic_vector(4 downto 0);
    variable drs1_ldst, drs2_ldst, drd_ldst: std_logic_vector(4 downto 0);
    variable vexpand_ldst, dimm_ldst: std_ulogic;
    variable ncnt_ldst: std_logic_vector(0 downto 0);
    variable drs2i: std_logic_vector(12 downto 5);
    variable dop3: std_logic_vector(5 downto 0);
    variable dimm: std_ulogic;
    variable dbaddr: std_logic_vector(21 downto 0);
    variable ncnt: std_logic_vector(0 downto 0);
    variable opvec: std_logic_vector(6 downto 0);
    variable bitop_imm, maskop_imm, bit_mask_imm: std_logic_vector(31 downto 0);
    variable vmaskpv, vitovr: std_ulogic;
    variable vleave: std_ulogic;
  begin
    vinst48 := opin;

    rop := vinst48(47 downto 46);
    rrd := vinst48(45 downto 42);
    rimm := vinst48(41);
    rop3 := vinst48(40 downto 37);
    rop3l := vinst48(36);
    rrs := vinst48(35 downto 32);
    rop4 := vinst48(36 downto 32);
    rop4_4 := rop4(3 downto 0);
    ximm := vinst48(31);
    xop3 := vinst48(30 downto 25);
    xfpop := vinst48(31 downto 25);
    xrdalt := vinst48(24);
    xrs1alt := vinst48(23);
    xrs2imm := vinst48(22 downto 16);
    vbaddr1 := vinst48(32);
    vbitop := '0';
    vmask := '0';
    vgetpc := '0';
    veximm := '0';
    eximmval := vinst48(31 downto 13);
    dimm := '0';
    ncnt := "0";
    vexpand := '0';
    vmaskpv := not cntin(0) and rop(1) and rop(0) and rop3l;
    vitovr := cntin(0) and rop(1) and rop(0) and rop3l;
    villinst := '0';
    vnostep := '0';
    vleave := '0';

    -- Generate unpacked op parts for ALU / LDST instructions
    drd := rex_regunp(rrd);
    drs1 := drd;
    dimm := rimm;
    drs2 := rop3l & rrs;
    -- Generate immediate for bit/mask operations */
    bitop_imm := (others => '0');
    bitop_imm(to_integer(unsigned(drs2))) := '1';
    maskop_imm := (others => '0');
    for x in 0 to 31 loop
      if unsigned(drs2) >= to_unsigned(x,5) then
        maskop_imm(x) := '1';
      end if;
    end loop;
    bit_mask_imm := bitop_imm;
    if rop3="0010" then bit_mask_imm := maskop_imm; end if;
    if rimm='0' then
      drs2 := rex_regunp(rrs);
    end if;
    drs2i := (others => rop3l);
    if rimm='0' then
      -- Set drs2i(12) to 0 Prevent decoding to saverex/addrex ops
      -- Also set whole vector to ensure offset calc for self-inc ops
      drs2i(12 downto 5):=(others => '0');
    end if;
    dop3 := (rop3(0) and rop(0)) & (rop3l and not rimm and not rop(0)) & "0" & rop3(3) & rop3(2) & rop3(1);
    dop := rop;
    opvec := rop(0) & rimm & rop3 & rop3l;
    -- Common subexpr for LDST with rimm='0'
    drs1_ldst := "00000";
    ncnt_ldst := (others => '0');
    ncnt_ldst(0) := opvec(0) and not cntin(0);
    vexpand_ldst := opvec(0) and not cntin(0);
    dimm_ldst := dimm or cntin(0);
    drs2_ldst := drs2;
    drd_ldst := drd;
    drd_ldst(4) := drd_ldst(4) xor rop3(0);
    drd_ldst(3) := drd_ldst(3) xor rop3(0);
    if cntin/="0" then
      drs1_ldst := drs2;
      drs2_ldst := "0" & (rop3(2) and rop3(1)) & (not rop3(2) and not rop3(1)) & (rop3(2) and not rop3(1)) & (not rop3(2) and rop3(1));
      drd_ldst := drs2;
    end if;
    
    case opvec is
      -------------------------------------------------------------------------
      -- ALU with reg operand
      when "0000000" | "0000001" => null;  -- r_add(cc)
      when "0000010" | "0000011" => dop3(2):='1'; -- r_sub(cc)
      when "0000100" | "0000101" => null;  -- r_and(cc)
      when "0000110" | "0000111" => villinst := '1';  -- undef
      when "0001000" | "0001001" => null;    -- r_or(cc)
      when "0001010" | "0001011" => villinst:='1';    -- undef
      when "0001100" | "0001101" => null;    -- r_xor(cc)
      when "0001110" | "0001111" | "1001110" | "1001111" =>     -- r_iop /r_flop / r_ldop (32-bit!)
        drs1 := drs2;
        drs2 := xrs2imm(4 downto 0);
        drs2i(6 downto 5) := xrs2imm(6 downto 5);
        if ximm='1' then
          drs2i(12 downto 7) := (others => xrs2imm(6));
        end if;
        dop3 := xop3;
        dimm := ximm;
        if opvec(0)='1' then
          dop3(5 downto 1) := "11010";
          dop3(0) := xfpop(6) and (not xfpop(5)) and (not xfpop(4));
          dimm := '0';
          drs2i(12) := xfpop(6) and (xfpop(5) or xfpop(4));
          drs2i(11) := xfpop(5) or xfpop(6);
          drs2i(10) := xfpop(4) and not xfpop(6);
          drs2i(9) := xfpop(6) and xfpop(4);
          drs2i(8 downto 5) := xfpop(3 downto 0);
        end if;
        drd(4) := drd(4) xor (opvec(0) xor xrdalt);
        drd(3) := drd(3) xor (opvec(0) xor xrdalt);
        drs1(4) := drs1(4) xor (opvec(0) xor xrs1alt);
        drs1(3) := drs1(3) xor (opvec(0) xor xrs1alt);
        villinst := opvec(0) and opvec(6);
      when "0010000" | "0010001" | "0010010" | "0010011" => -- r_mov
        dop3 := "000000";
        drs1 := "00000";
        drs2(4) := drs2(4) xor opvec(0);
        drs2(3) := drs2(3) xor opvec(0);
        drd(4) := drd(4) xor opvec(1);
        drd(3) := drd(3) xor opvec(1);
      when "0010100" | "0010101" => null;    -- r_andn(cc)
      when "0010110" => dop3(5):='1';   -- r_sll
      when "0010111" =>                 -- r_cmp
        dop3(0):='0';
        drd := "00000";
      when "0011000" | "0011001" => null;    -- r_orn(cc)
      when "0011010" | "0011011" => dop3(5):='1'; villinst:=opvec(0);    -- r_srl / undef
      when "0011100" | "0011101" => null;    -- r_xnor(cc)
      when "0011110" | "0011111" => villinst:='1';    -- undef
      -------------------------------------------------------------------------
      -- ALU with imm operand (note opvec(0) is top of immediate, so both opvec(0)=0 and
      -- opvec(0)=1 cases must be decoded the same way)
      when "0100000" | "0100001" =>     -- r_addcc(imm)
        dop3(4) := '1';
      when "0100010" | "0100011" =>     -- r_set5
        drs1 := "00000";
      when "0100100" | "0100101" =>     -- r_masklo
        vmask := '1';
        vbitop := '1';
      when "0100110" | "0100111" =>     -- r_tstbit
        dop3(4) := '1';
        drd := "00000";
        vbitop := '1';
      when "0101000" | "0101001" =>     -- r_setbit
        vbitop := '1';
      when "0101010" | "0101011" =>     -- r_one
        vbitop := '1';
        drs1 := "00000";
      when "0101100" | "0101101" =>     -- r_invbit
        vbitop := '1';
      when "0101110" | "0101111" =>     -- r_set21 (32-bit!)
        dop3 := "000000";
        drs1 := "00000";
        veximm := '1';
        eximmval(31 downto 21) := (others => vinst48(31));
        eximmval(20 downto 13) := vinst48(31 downto 24);
        drs2i(12 downto 5) := vinst48(23 downto 16);
      when "0110000" | "0110001" =>     -- r_cmp(imm)
        drd := "00000";
        dop3(4):='1';
      when "0110010" | "0110011" =>     -- undef
        villinst := '1';
      when "0110100" | "0110101" =>     -- r_clrbit
        vbitop := '1';
      when "0110110" | "0110111" => dop3(5):='1';   -- r_sll(imm)
      when "0111000" | "0111001" => villinst:='1';   -- undef
      when "0111010" | "0111011" => dop3(5):='1';  -- r_srl(imm)
      when "0111100" | "0111101" =>     -- Misc ops
        if rop4(4)='1' then
          villinst := '1';
        end if;
        vgetpc := rop4(3) and rop4(0);
        case rop4_4 is
          when "0000" =>                 -- r_retrest
            drd := "00000";
            drs1 := "11111";
            drs2 := "01000";
            if cntin="0" then
              dop3 := "111000";   -- ret
              vexpand := '1';
              ncnt := "1";
              vnostep := '1';
            else
              dop3 := "111101";   -- restore
            end if;
          when "0001" =>                 -- r_retl
            drd := "00000";
            drs1 := "01111";
            drs2 := "01000";
            if cntin="0" then
              dop3 := "111000";   -- ret
              vexpand := '1';
              ncnt := "1";
              vnostep := '1';
            end if;
          when "0010" =>                 -- r_push
            drs2i := "11111111";
            drs2 := "11100";
            drs1 := "01110";
            if cntin="0" then
              ncnt := "1";
              vexpand := '1';
              dop3 := "000100";         -- Store
              dop(0) := '1';
              vmaskpv := '1';
            else
              dop3 := "000000";         -- Add
              drd := "01110";
              vitovr := '1';
            end if;
          when "0011" =>                 -- r_pop
            drs1 := "01110"; -- %sp=%r14
            drs2i := "00000000";
            drs2 := "00000";
            if cntin="0" then
              ncnt := "1";
              vexpand := '1';
              dop3 := "000000";         -- Load
              dop(0) := '1';
              vmaskpv := '1';
            else
              dop3 := "000000";         -- Add
              drs2 := "00100";
              drd := "01110";
              vitovr := '1';
            end if;
          when "0100" =>                 -- r_neg
            drs2 := drs1;
            drs1 := "00000";
            dimm := '0';
            dop3 := "000100";
          when "0101" =>                 -- r_not
            drs2 := drs1;
            drs1 := "00000";
            dimm := '0';
            dop3 := "000110";
          when "0110" =>                 -- r_ta0..7
            drs2 := drs1;
            drs2(4 downto 3) := "00";
            drd := "01000";
            drs1 := "00000";
            dop3 := "111010";
          when "0111" =>                 -- r_leave
            vleave := '1';
            -- vbubbble := '1';
            drd := "00000";
            dop3 := "000000";
          when "1001" =>                 -- r_getpc
            dop3 := "000000";           -- Add
            drs2 := "00000";
          when others => villinst := '1';
        end case;

      when "0111110" | "0111111" =>     -- Big ops (48-bit!)
        -- r_set32/set32pc/ld32/ld32pc
        if rop4(4 downto 2)/="010" then villinst:='1'; end if;
        drs2i := vinst48(12 downto 5);
        drs2 := vinst48(4 downto 0);
        vgetpc := rop4(3) and rop4(0);
        veximm := '1';
        dop3 := "000000";
        drs1 := "00000";
        if rop4(1)='1' then dop(0):='1'; end if;

      -------------------------------------------------------------------------
      -- LDST with reg operand
      when "1000000" | "1000001" =>     -- r_ld / r_ldinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1000010" | "1000011" =>     -- r_ldf / r_ldfinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1000100" | "1000101" =>     -- r_ldub / r_ldubinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1000110" | "1000111" =>     -- Undef
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1001000" | "1001001" =>     -- p_lduh / p_lduhinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1001010" | "1001011" =>     -- p_lddf / p_lddfinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
        dop3(0):='1';
      when "1001100" | "1001101" =>     -- p_ldd / p_lddinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      --  when "1001110" | "1001111" =>   -- r_ldop covered in same case as iop
      when "1010000" | "1010001" =>     -- p_st / p_stinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1010010" | "1010011" =>     -- p_stf / p_stfinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1010100" | "1010101" =>     -- p_stb / p_stbinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1010110" | "1010111" =>     -- Undef
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
        villinst := '1';
      when "1011000" | "1011001" =>     -- p_sth / p_sthinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1011010" | "1011011" =>     -- p_stdf / p_stdfinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
        dop3(0) := '1';
      when "1011100" | "1011101" =>     -- p_std / p_stdinc
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
      when "1011110" | "1011111" =>     -- Undef
        drs1:=drs1_ldst; drs2:=drs2_ldst; drd:=drd_ldst; dimm:=dimm_ldst;
        vexpand:=vexpand_ldst; ncnt:=ncnt_ldst;
        if cntin/="0" then dop3 := "000000"; dop(0):='0'; end if;
        villinst := '1';
      -------------------------------------------------------------------------
      -- LDST with imm operand
      when "1100000" | "1100001" | "1100010" | "1100011" => -- p_ldfp / p_ldffp
        dop3(1 downto 0) := "00";
        drs1 := "11110";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1100100" | "1100101" | "1100110" | "1100111" =>     -- p_ldsp / p_ldfsp
        dop3(1 downto 0) := "00";
        drs1 := "01110";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1101000" | "1101001" | "1101010" | "1101011" =>     -- p_ldi0 / p_ldfi0
        dop3(1 downto 0) := "00";
        drs1 := "11000";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1101100" | "1101101" =>     -- p_ldo0
        dop3(1 downto 0) := "00";
        drs1 := "01000";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1101110" | "1101111" =>     -- Undef (32-bit!)
        dop3(1 downto 0) := "00";
        drs1 := "01000";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
        villinst := '1';
      when "1110000" | "1110001" =>     -- p_stfp
        dop3(1 downto 0) := "00";
        drs1 := "11110";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1110010" | "1110011" =>     -- p_stffp
        dop3(1 downto 0) := "00";
        drs1 := "11110";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1110100" | "1110101" =>     -- p_stsp
        dop3(1 downto 0) := "00";
        drs1 := "01110";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1110110" | "1110111" =>     -- p_stfsp
        dop3(1 downto 0) := "00";
        drs1 := "01110";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1111000" | "1111001" =>     -- p_sti0
        dop3(1 downto 0) := "00";
        drs1 := "11000";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1111010" | "1111011" =>     -- p_stfi0
        dop3(1 downto 0) := "00";
        drs1 := "11000";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when "1111100" | "1111101" =>     -- p_sto0
        dop3(1 downto 0) := "00";
        drs1 := "01000";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
      when others =>                    -- Undef (48-bit!)
        dop3(1 downto 0) := "00";
        drs1 := "01000";
        drs2i := "000000" & drs2(4 downto 3);
        drs2 := drs2(2 downto 0) & "00";
        drd(4) := drd(4) xor opvec(1); drd(3) := drd(3) xor opvec(1);
        villinst := '1';
    end case;
    if vbitop='1' then
      veximm := '1';
      eximmval(31 downto 13) := bit_mask_imm(31 downto 13);
      drs2i(12 downto 5) := bit_mask_imm(12 downto 5);
      drs2 := bit_mask_imm(4 downto 0);
    end if;
    -- Generate unpacked op parts for branch
    dbaddr := vinst48(30 downto 16) & vinst48(39 downto 33);
    if rimm='0' then
      dbaddr(21 downto 7) := (others => vinst48(39));
    end if;
    -- Generate instruction and calculate packed insn size for buffer mgmt
    vinst := vinst48(47 downto 16);
    isz := "01";                        -- 00=16, 01=32, 10=48
    case rop is
      when "00" =>
        -- Branch
        -- 765 4321 0
        -- 00x<cond>0<disp8>
        -- 00x<cond>1<disp24>
        isz := "0" & rimm;
        vinst := vinst48(47 downto 46) & '0' & vinst48(45 downto 42) & vinst48(40) & "10" & dbaddr;
        villinst := '0';
      when "01" =>
        -- Call
        villinst := '0';
      when others =>
        -- ALU / LDST
        -- 10<rd>01110x<rs1><+16> - 32-bit
        -- 10<rd>01111<imm21> - 32-bit
        -- 10<rd>11111<arg><+32> -48-bit
        isz := "00";
        if rop3(2 downto 0)="111" then
          isz := rop3(3) & (not rop3(3));
        end if;
        vinst := dop & drd & dop3 & drs1 & dimm & drs2i & drs2;
    end case;

    opout := vinst;
    szout := isz;
    ncntout := ncnt;
    baddr1 := vbaddr1;
    immexp := veximm;
    immval := eximmval;
    getpc := vgetpc;
    maskpv := vmaskpv;
    illinst := villinst;
    nostep := vnostep;
    itovr := vitovr;
    leave := vleave;
  end rex_decode_main;

  procedure rex_decode(r: registers;
                         de_inst1: std_logic_vector(31 downto 0);
                         de_inst: out std_logic_vector(31 downto 0);
                         de_nrexen: out std_ulogic;
                         de_nbufpos16: out std_logic_vector(1 downto 0);
                         de_ncnt16: out std_logic_vector(0 downto 0);
                         de_rexhold,de_rexbubble: out std_ulogic;
                         de_rexbaddr1: out std_ulogic;
                         de_reximmexp: out std_ulogic;
                         de_reximmval: out std_logic_vector(31 downto 13);
                         de_rexgetpc:  out std_ulogic;
                         de_rexmaskpv: out std_ulogic;
                         de_rexillinst: out std_ulogic;
                         de_rexnostep: out std_ulogic;
                         de_rexitovr: out std_ulogic) is
    variable vinst: std_logic_vector(31 downto 0);  -- inst going out
    variable vinst48: std_logic_vector(47 downto 0);  -- raw inst buffer
    variable nrexen: std_ulogic;
    -- computed from fields
    variable isz: std_logic_vector(1 downto 0);
    variable vpos: std_logic_vector(1 downto 0);
    variable vexpand,villinst,vnostep: std_ulogic;
    variable vbaddr1, vbitop, veximm, vmask, vgetpc: std_ulogic;
    variable eximmval: std_logic_vector(31 downto 13);
    variable ncnt: std_logic_vector(0 downto 0);
    variable vmaskpv, vitovr, vleave: std_ulogic;
    -- Flow control
    variable vhold,vbubble: std_ulogic;
  begin
    nrexen := r.d.rexen;
    case r.d.rexpos is
      when "00"   => vinst48 := r.d.rexbuf(31 downto 16) & r.d.rexbuf(15 downto 0) & de_inst1(31 downto 16);
      when "01"   => vinst48 := r.d.rexbuf(15 downto 0)  & de_inst1(31 downto 16)  & de_inst1(15 downto 0);
      when "10"   => vinst48 := de_inst1(31 downto 16)   & de_inst1(15 downto 0)   & de_inst1(31 downto 16);
      when others => vinst48 := de_inst1(15 downto 0)   & de_inst1(15 downto 0)   & de_inst1(15 downto 0);
    end case;

    vinst := vinst48(47 downto 16);
    if REXPIPE then vinst:=de_inst1; end if;
    isz := "01";
    ncnt := "0";
    vbaddr1 := '0';
    veximm := '0';
    if REXPIPE then
      eximmval := r.d.rexpl.immval;
    else
      eximmval := vinst48(31 downto 13);
    end if;
    vgetpc := '0';
    vmaskpv := '0';
    villinst := '0';
    vnostep := '0';
    vitovr := '0';
    vleave := '0';
    vexpand := '0';
    if r.d.rexen='1' then
      if REXPIPE then
        vinst := r.d.rexpl.opout;
        isz := r.d.rexpl.szout;
        ncnt := r.d.rexpl.ncntout;
        vbaddr1 := r.d.rexpl.baddr1;
        veximm := r.d.rexpl.immexp;
        eximmval := r.d.rexpl.immval;
        vgetpc := r.d.rexpl.getpc;
        vmaskpv := r.d.rexpl.maskpv;
        villinst := r.d.rexpl.illinst;
        vnostep := r.d.rexpl.nostep;
        vitovr := r.d.rexpl.itovr;
        vleave := r.d.rexpl.leave;
      else
        rex_decode_main(vinst48, r.d.rexcnt, vinst, isz, ncnt,
                        vbaddr1, veximm, eximmval, vgetpc, vmaskpv,
                        villinst, vnostep, vitovr, vleave);
      end if;
    end if;
    nrexen := nrexen and not vleave;
    vexpand := ncnt(0);

    -- Check size and current buffer loc. and decide on bubble or hold
    --   bubble will insert annuled cycle in regfile stage
    --   hold will hold the fetch,decode stages and insert vinst into regfile stage
    -- rexpos isz | bubble hold n16pos
    -- 00     00  |      0    1     01  (already has 48 bits left to process)
    -- 00     01  |      0    0     00
    -- 00     10  |      0    0     01
    -- 01     00  |      0    0     00
    -- 01     01  |      0    0     01
    -- 01     10  |      0    0     10
    -- 10     00  |      0    0     01
    -- 10     01  |      0    0     10
    -- 10     10  |      1    0     00 (need more data, 48 bit insn got 32)
    -- 11     00  |      0    0     10 (special case after branch to "odd" addr)
    -- 11     01  |      1    0     01 (special case after branch to "odd" addr)
    -- 11     10  |      1    0     01 (special case after branch to "odd" addr)
    vhold := '0'; vbubble := '0';
    if r.d.rexpos="00" and isz="00" then vhold := '1'; end if;
    if r.d.rexpos(1)='1' and (isz(1)='1' or (isz(0)='1' and r.d.rexpos(0)='1')) then vbubble:='1'; end if;
    vpos := "00";

    if (r.d.rexpos="11" and isz="00") or (r.d.rexpos="10"  and isz(0)='1') or (isz(1)='1' and r.d.rexpos="01") then
      vpos(1) := '1';
    end if;
    vpos(0) := r.d.rexpos(0) xor ((not isz(0)) and (not vbubble));
    if REXPIPE and vleave='1' and r.d.rexpos(1)='0' then vhold:='1'; vpos(1):='1'; end if;

    if REX=1 and r.f.branch='1' then
      vpos := "1" & r.f.pc(1+(1-REX));
      nrexen := r.f.pc(0);
      -- Drop delay slot insn on taken branch
      if r.d.rexen='1' then
        vbubble := '1';
        vhold := '0';
      end if;
    elsif r.d.rexen='1' and vexpand='1' then
      vhold := '1';
      vbubble := '0';
      vpos := r.d.rexpos;
    end if;

    if vbubble='1' or r.d.annul='1' then ncnt:="0"; villinst:='0'; vnostep:='1'; end if;
    if r.d.cnt/="00" then vitovr:='0'; end if;
    if r.d.rexen='0' then vgetpc:='0'; villinst:='0'; vnostep:='0'; vmaskpv:='0'; vitovr:='0'; end if;

    de_inst := vinst;
    de_nrexen := nrexen;
    de_nbufpos16 := vpos;
    de_ncnt16 := ncnt;
    de_rexhold := vhold;
    de_rexbubble := vbubble;
    de_rexbaddr1 := vbaddr1;
    de_reximmexp := r.d.rexen and veximm;
    de_reximmval := eximmval;
    de_rexgetpc := vgetpc;
    de_rexmaskpv := vmaskpv;
    de_rexillinst := villinst;
    de_rexnostep := vnostep;
    de_rexitovr := vitovr;
  end rex_decode;

  procedure rex_pl_fetch(ndregs: decode_reg_type;
                         dregs: decode_reg_type;
                         holdn: std_ulogic;
                         plreg: out rex_pipeline_reg_type) is
    variable ninst, oinst: std_logic_vector(31 downto 0);
    variable pos: std_logic_vector(1 downto 0);
    variable cnt: std_logic_vector(0 downto 0);
    variable vinst48: std_logic_vector(47 downto 0);  -- raw inst buffer
  begin
    if ISETS > 1 then ninst := ndregs.inst(conv_integer(ndregs.set));
    else ninst := ndregs.inst(0); end if;
    oinst := ndregs.rexbuf;
    pos := ndregs.rexpos;
    cnt := ndregs.rexcnt;
    if holdn='0' then
      oinst := dregs.rexbuf;
      pos := dregs.rexpos;
      cnt := dregs.rexcnt;
    end if;

    case pos is
      when "00"   => vinst48 := oinst(31 downto 16) & oinst(15 downto 0)  & ninst(31 downto 16);
      when "01"   => vinst48 := oinst(15 downto 0)  & ninst(31 downto 16) & ninst(15 downto 0);
      when "10"   => vinst48 := ninst(31 downto 16) & ninst(15 downto 0)  & ninst(31 downto 16);
      when others => vinst48 := ninst(15 downto 0)  & ninst(31 downto 16) & ninst(15 downto 0);
    end case;

    rex_decode_main(vinst48, cnt,
                    plreg.opout, plreg.szout, plreg.ncntout,
                    plreg.baddr1, plreg.immexp, plreg.immval,
                    plreg.getpc, plreg.maskpv, plreg.illinst, plreg.nostep, plreg.itovr, plreg.leave);
  end rex_pl_fetch;

  signal dummy : std_ulogic;
  signal cpu_index : std_logic_vector(3 downto 0);
  signal disasen : std_ulogic;

begin

  BPRED <= '0' when bp = 0 else not r.d.rexen when bp = 1 else not (r.w.s.dbp or r.d.rexen);
  BLOCKBPMISS <= '0' when bp = 0 else '1' when bp = 1 else r.w.s.dbprepl;

  comb : process(ico, dco, rfo, r, wpr, ir, dsur, rstn, holdn, irqi, dbgi, fpo, cpo, tbo, tbo_2p,
                 mulo, divo, dummy, rp, BPRED, BLOCKBPMISS, cpuid)

  variable v    : registers;
  variable vp  : pwd_register_type;
  variable vwpr : watchpoint_registers;
  variable vdsu : dsu_registers;
  variable fe_pc, fe_npc :  std_logic_vector(31 downto PCLOW);
  variable npc  : std_logic_vector(31 downto PCLOW);
  variable de_raddr1, de_raddr2 : std_logic_vector(9 downto 0);
  variable de_rs2, de_rd : std_logic_vector(4 downto 0);
  variable de_hold_pc, de_branch, de_ldlock : std_ulogic;
  variable de_cwp, de_rcwp : cwptype;
  variable de_inull : std_ulogic;
  variable de_ren1, de_ren2 : std_ulogic;
  variable de_wcwp : std_ulogic;
  variable de_inst1, de_inst : word;
  variable de_icc : std_logic_vector(3 downto 0);
  variable de_fbranch, de_cbranch : std_ulogic;
  variable de_rs1mod : std_ulogic;
  variable de_bpannul : std_ulogic;
  variable de_fins_hold : std_ulogic;
  variable de_iperr : std_ulogic;
  variable de_rexen, de_nrexen, de_rexhold, de_rexbubble, de_rexbaddr1 : std_ulogic;
  variable de_rexmaskpv, de_rexnostep : std_ulogic;
  variable de_rexillinst: std_ulogic;
  variable de_nbufpos16: std_logic_vector(1 downto 0);
  variable de_ncnt16: std_logic_vector(0 downto 0);
  variable de_pcout: std_logic_vector(31 downto 0);
  variable de_reximmexp: std_ulogic;
  variable de_reximmval: std_logic_vector(31 downto 13);

  variable ra_op1, ra_op2 : word;
  variable ra_div : std_ulogic;
  variable ra_bpmiss : std_ulogic;
  variable ra_bpannul : std_ulogic;

  variable ex_jump, ex_link_pc : std_ulogic;
  variable ex_jump_address : pctype;
  variable ex_add_res : std_logic_vector(32 downto 0);
  variable ex_shift_res, ex_logic_res, ex_misc_res : word;
  variable ex_edata, ex_edata2 : word;
  variable ex_dci : dc_in_type;
  variable ex_force_a2, ex_load, ex_ymsb : std_ulogic;
  variable ex_op1, ex_op2, ex_result, ex_result2, ex_result3, mul_op2 : word;
  variable ex_shcnt : std_logic_vector(4 downto 0);
  variable ex_dsuen : std_ulogic;
  variable ex_ldbp2 : std_ulogic;
  variable ex_sari : std_ulogic;
  variable ex_bpmiss : std_ulogic;

  variable ex_cdata : std_logic_vector(31 downto 0);
  variable ex_mulop1, ex_mulop2 : std_logic_vector(32 downto 0);
  
  variable me_bp_res : word;
  variable me_inull, me_nullify, me_nullify2 : std_ulogic;
  variable me_iflush : std_ulogic;
  variable me_newtt : std_logic_vector(5 downto 0);
  variable me_asr18 : word;
  variable me_signed : std_ulogic;
  variable me_size, me_laddr : std_logic_vector(1 downto 0);
  variable me_icc : std_logic_vector(3 downto 0);

  
  variable xc_result : word;
  variable xc_df_result : word;
  variable xc_waddr : std_logic_vector(9 downto 0);
  variable xc_exception, xc_wreg : std_ulogic;
  variable xc_trap_address : pctype;
  variable xc_newtt, xc_vectt : std_logic_vector(7 downto 0);
  variable xc_trap : std_ulogic;
  variable xc_fpexack : std_ulogic;  
  variable xc_rstn, xc_halt : std_ulogic;
  variable xc_inull : std_ulogic;
  variable xc_mmucacheclr : std_ulogic;
  variable xc_wimmask: std_logic_vector(NWIN-1 downto 0);
  variable xc_trapcwp: cwptype;

  variable diagdata : word;
  variable tbufi : tracebuf_in_type;
  variable tbufi_2p : tracebuf_2p_in_type;
  variable dbgm : std_ulogic;
  variable fpcdbgwr : std_ulogic;
  variable vfpi : fpc_in_type;
  variable dsign : std_ulogic;
  variable pwrd, sidle : std_ulogic;
  variable vir : irestart_register;
  variable xc_dflushl  : std_ulogic;
  variable xc_dcperr : std_ulogic;
  variable st : std_ulogic;
  variable icnt, fcnt : std_ulogic;
  variable tbufcntx : std_logic_vector(TBUFBITS-1 downto 0);
  variable tovx : std_ulogic;
  variable bpmiss : std_ulogic;
  
  begin

    v := r; vwpr := wpr; vdsu := dsur; vp := rp;
    xc_fpexack := '0'; sidle := '0';
    fpcdbgwr := '0'; vir := ir; xc_rstn := rstn;
    de_pcout := rex_dpc(r.d.pc, r.d.rexen, r.d.rexpos);
    
-----------------------------------------------------------------------
-- EXCEPTION STAGE
-----------------------------------------------------------------------

    xc_exception := '0'; xc_halt := '0'; icnt := '0'; fcnt := '0';
    xc_waddr := (others => '0');
    xc_waddr(RFBITS-1 downto 0) := r.x.ctrl.rd(RFBITS-1 downto 0);
    xc_trap := r.x.mexc or r.x.ctrl.trap;
    v.x.nerror := rp.error; xc_dflushl := '0';
    xc_mmucacheclr := '0';
    xc_inull := '0';

    if r.x.mexc = '1' then xc_vectt := "00" & TT_DAEX;
    elsif r.x.ctrl.tt = TT_TICC then
      xc_vectt := '1' & r.x.result(6 downto 0);
    else xc_vectt := "00" & r.x.ctrl.tt; end if;

    if r.w.s.svt = '0' then
      xc_trap_address(31 downto 2) := r.w.s.tba & xc_vectt & "00"; 
    else
      xc_trap_address(31 downto 2) := r.w.s.tba & "00000000" & "00"; 
    end if;
    xc_trap_address(2 downto PCLOW) := (others => '0');
    xc_wreg := '0'; v.x.annul_all := '0'; 

    if (not r.x.ctrl.annul and r.x.ctrl.ld) = '1' then 
      if (lddel = 2) then 
        xc_result := ld_align(r.x.data, r.x.set, r.x.dci.size, r.x.laddr, r.x.dci.signed);
      else
        xc_result := r.x.data(0); 
      end if;
    elsif MACEN and MACPIPE and ((not r.x.ctrl.annul and r.x.mac) = '1') then
      xc_result := mulo.result(31 downto 0);
    else xc_result := r.x.result; end if;
    xc_df_result := xc_result;

    xc_wimmask := (others => '0');
    if RFPART then
      for x in NWIN-1 downto 1 loop
        if unsigned(r.w.s.cwpmax) < to_unsigned(x,NWINLOG2) then xc_wimmask(x) := '1'; end if;
      end loop;
    end if;

    xc_trapcwp := r.w.s.cwp;
    if RFPART then
      if r.w.s.cwp=CWPMIN then
        xc_trapcwp := r.w.twcwp;
      else
        xc_trapcwp := std_logic_vector(unsigned(r.w.s.stwin) + unsigned(r.w.s.cwp));
      end if;
    end if;

    
    if DBGUNIT
    then 
      dbgm := dbgexc(r, dbgi, xc_trap, xc_vectt, dsur);
      if (dbgi.dsuen and dbgi.dbreak) = '0'then v.x.debug := '0'; end if;
    else dbgm := '0'; v.x.debug := '0'; end if;
    if PWRD2 then pwrd := powerdwn(r, xc_trap, rp); else pwrd := '0'; end if;
    
    case r.x.rstate is
    when run =>
      if (dbgm 
      ) /= '0' then        
        v.x.annul_all := '1'; vir.addr := r.x.ctrl.pc;
        v.x.rstate := dsu1;
          v.x.debug := '1'; 
        v.x.npc := npc_find(r);
        vdsu.tt := xc_vectt; vdsu.err := dbgerr(r, dbgi, xc_vectt);
      elsif ((pwrd = '1') or (smp/=0 and irqi.forceerr='1')) and (ir.pwd = '0') then
        v.x.annul_all := '1'; vir.addr := r.x.ctrl.pc;
        v.x.rstate := dsu1; v.x.npc := npc_find(r); vp.pwd := '1';
      elsif (r.x.ctrl.annul or xc_trap) = '0' then
        xc_wreg := r.x.ctrl.wreg;
        sp_write (r, wpr, v.w.s, vwpr);        
        vir.pwd := '0';
        if (r.x.ctrl.pv and not r.x.debug) = '1' then
          icnt := holdn;
          if (r.x.ctrl.inst(31 downto 30) = FMT3) and 
                ((r.x.ctrl.inst(24 downto 19) = FPOP1) or 
                 (r.x.ctrl.inst(24 downto 19) = FPOP2))
          then fcnt := holdn; end if;
        end if;
      elsif ((not r.x.ctrl.annul) and xc_trap) = '1' then
        xc_exception := '1';
        xc_result := (others => '0'); xc_result(31 downto PCLOW) := r.x.ctrl.pc(31 downto PCLOW);
        xc_wreg := '1'; v.w.s.tt := xc_vectt; v.w.s.ps := r.w.s.s;
        v.w.s.s := '1'; v.x.annul_all := '1'; v.x.rstate := trap;
        xc_waddr := (others => '0');
        xc_waddr(NWINLOG2 + 3  downto 0) :=  xc_trapcwp & "0001";
        v.x.npc := npc_find(r);
        fpexack(r, xc_fpexack);
        if r.w.s.et = '0' then
--        v.x.rstate := dsu1; xc_wreg := '0'; vp.error := '1';
          xc_wreg := '0';
        end if;
      end if;
    when trap =>
      xc_result := npc_gen(r,de_pcout); xc_wreg := '1';
      xc_waddr := (others => '0');
      xc_waddr(NWINLOG2 + 3  downto 0) :=  xc_trapcwp & "0010";
      if r.w.s.et = '1' then
        v.w.s.et := '0'; v.x.rstate := run;
        if RFPART and (r.w.s.cwp = CWPMIN) then v.w.s.cwp := r.w.s.cwpmax;
        elsif (not CWPOPT) and (r.w.s.cwp = CWPMIN) then v.w.s.cwp := CWPMAX;
        else v.w.s.cwp := r.w.s.cwp - 1 ; end if;
        if AWPEN then
          v.w.s.aw := '0';
          v.w.s.paw := r.w.s.aw;
        end if;
      else
        xc_inull := '1';
        v.x.rstate := dsu1; xc_wreg := '0'; vp.error := '1';
      end if;
    when dsu1 =>
      xc_exception := '1'; v.x.annul_all := '1';
      xc_trap_address(31 downto PCLOW) := r.f.pc;
      if DBGUNIT or PWRD2 or (smp /= 0)
      then 
        xc_trap_address(31 downto PCLOW) := ir.addr; 
        vir.addr := npc_gen(r,de_pcout)(31 downto PCLOW);
        v.x.rstate := dsu2;
      end if;
      if DBGUNIT then v.x.debug := r.x.debug; end if;
    when dsu2 =>      
      xc_exception := '1'; v.x.annul_all := '1';
      xc_trap_address(31 downto PCLOW) := r.f.pc;
      if DBGUNIT or PWRD2 or (smp /= 0)
      then
        sidle := (rp.pwd or rp.error) and ico.idle and dco.idle and not r.x.debug;
        if DBGUNIT then
          if dbgi.reset = '1' then 
            if smp /=0 then vp.pwd := not irqi.rstrun; else vp.pwd := '0'; end if;
            vp.error := '0';
          end if;
          if (dbgi.dsuen and dbgi.dbreak) = '1'then v.x.debug := '1'; end if;
          diagwr(r, dsur, ir, dbgi, wpr, v.w.s, vwpr, vdsu.asi, xc_trap_address,
               vir.addr, vdsu.tbufcnt, vdsu.tfilt, xc_wreg, xc_waddr, xc_result, fpcdbgwr);
          xc_halt := dbgi.halt;
        end if;
        if smp/=0 and (rp.pwd or rp.error)='1' and irqi.pwdsetaddr='1' then
          xc_trap_address(31 downto PCLOW) := ir.addr;
          vir.addr := (others => '0');
          vir.addr(31 downto 2) := irqi.pwdnewaddr;
        end if;
        if (smp /= 0) and irqi.forceerr='1' then
          vp.error := '1'; v.w.s.et := '0'; v.w.s.s := '1';
          xc_mmucacheclr := '1';
        end if;
        if r.x.ipend = '1' then vp.pwd := '0'; end if;
        if (rp.error or rp.pwd or r.x.debug or xc_halt) = '0' then
          v.x.rstate := run; v.x.annul_all := '0'; vp.error := '0';
          xc_trap_address(31 downto PCLOW) := ir.addr; v.x.debug := '0';
          vir.pwd := '1';
          if REX=1 and r.f.pc(2-2*REX)='1' then xc_exception:='0'; end if;
        end if;
        if (smp /= 0) and (irqi.resume = '1') then
          vp.pwd := '0'; vp.error := '0';
        end if;
      end if;
    when others =>
    end case;

    if DBGUNIT and TRACEBUF then
      if (dbgi.dsuen and dbgi.denable and dbgi.dwrite) = '1' then
        if (dbgi.daddr(23 downto 20) = "0001" and dbgi.daddr(16) = '1' and
            dbgi.daddr(2) = '1') then
          vdsu.tov     := dbgi.ddata(23);
          vdsu.tlim    := dbgi.ddata(26 downto 24);
          vdsu.tovb    := dbgi.ddata(27);
        end if;
      end if;
    end if;

    dci.flushl <= xc_dflushl;
    dci.mmucacheclr <= xc_mmucacheclr;

    
    irq_intack(r, holdn, v.x.intack);          
    itrace(r, dsur, vdsu, xc_result, xc_exception, dbgi, rp.error, xc_trap, tbufcntx, tovx, tbufi, tbufi_2p, '0', xc_dcperr);    
    vdsu.tbufcnt := tbufcntx; vdsu.tov := tovx;
    
    v.w.except := xc_exception; v.w.result := xc_result;
    if (r.x.rstate = dsu2) then v.w.except := '0'; end if;
    v.w.wa := xc_waddr(RFBITS-1 downto 0); v.w.wreg := xc_wreg and holdn;

    if RFPART then
      v.w.twcwp := std_logic_vector(unsigned(v.w.s.stwin) + unsigned(v.w.s.cwpmax) + 1);
      if (not CWPOPT) and v.w.twcwp=CWPGLB then v.w.twcwp:=CWPMIN; end if;
    end if;

    rfi.wdata <= xc_result; rfi.waddr <= xc_waddr;

    irqo.intack <= r.x.intack and holdn;
    irqo.irl <= r.w.s.tt(3 downto 0);
    irqo.pwd <= rp.pwd;
    irqo.fpen <= r.w.s.ef;
    irqo.err <= r.x.nerror;
    dbgo.halt <= xc_halt;
    dbgo.pwd  <= rp.pwd;
    dbgo.idle <= sidle;
    dbgo.icnt <= icnt;
    dbgo.fcnt <= fcnt;
    dbgo.optype <= r.x.ctrl.inst(31 downto 30) & r.x.ctrl.inst(24 downto 21);
    dci.intack <= r.x.intack and holdn;    
    
    if (not RESET_ALL) and (xc_rstn = '0') then 
      v.w.except := RRES.w.except; v.w.s.et := RRES.w.s.et;
      v.w.s.svt := RRES.w.s.svt; v.w.s.dwt := RRES.w.s.dwt;
      v.w.s.ef := RRES.w.s.ef;
      if RFPART then
        v.w.s.stwin := RRES.w.s.stwin;
        v.w.s.cwpmax := RRES.w.s.cwpmax;
      end if;
      if need_extra_sync_reset(fabtech) /= 0 then 
        v.w.s.cwp := RRES.w.s.cwp;
        v.w.s.icc := RRES.w.s.icc;
      end if;
      v.w.s.dbp := RRES.w.s.dbp;
      v.w.s.dbprepl := RRES.w.s.dbprepl;
      v.w.s.rexdis := RRES.w.s.rexdis;
      v.w.s.rextrap := RRES.w.s.rextrap;
      v.w.s.tba := RRES.w.s.tba;
      v.x.annul_all := RRES.x.annul_all;
      v.x.rstate := RRES.x.rstate; vir.pwd := IRES.pwd; 
      vp.pwd := PRES.pwd; v.x.debug := RRES.x.debug; 
      v.x.nerror := RRES.x.nerror;
      if svt = 1 then v.w.s.tt := RRES.w.s.tt; end if;
      if DBGUNIT then
        if (dbgi.dsuen and dbgi.dbreak) = '1' then
          v.x.rstate := dsu1; v.x.debug := '1';
        end if;
        vdsu.tfilt := DRES.tfilt; vdsu.tovb := DRES.tovb;
      end if;
      if (smp /= 0) and (irqi.rstrun = '0') and (rstn = '0') then
        v.x.rstate := dsu1; vp.pwd := '1'; 
      end if;
      v.x.npc := "100";
    end if;
    
    -- kill off unused regs
    if not FPEN then v.w.s.ef := '0'; end if;
    if not CPEN then v.w.s.ec := '0'; end if;

    
-----------------------------------------------------------------------
-- MEMORY STAGE
-----------------------------------------------------------------------

    v.x.ctrl := r.m.ctrl; v.x.dci := r.m.dci;
    v.x.ctrl.rett := r.m.ctrl.rett and not r.m.ctrl.annul;
    v.x.mac := r.m.mac; v.x.laddr := r.m.result(1 downto 0);
    v.x.ctrl.annul := r.m.ctrl.annul or v.x.annul_all; 
    st := '0'; 
    
    if CASAEN and (r.m.casa = '1') and (r.m.ctrl.cnt = "00") then
      v.x.ctrl.inst(4 downto 0) := r.a.ctrl.inst(4 downto 0); -- restore rs2 for trace log
    end if;

    mul_res(r, v.w.s.asr18, v.x.result, v.x.y, me_asr18, me_icc);


    mem_trap(r, wpr, v.x.ctrl.annul, holdn, v.x.ctrl.trap, me_iflush,
             me_nullify, v.m.werr, v.x.ctrl.tt);
    me_newtt := v.x.ctrl.tt;

    irq_trap(r, ir, irqi.irl, v.x.ctrl.annul, v.x.ctrl.pv, v.x.ctrl.trap, me_newtt, me_nullify,
             v.m.irqen, v.m.irqen2, me_nullify2, v.x.ctrl.trap,
             v.x.ipend, v.x.ctrl.tt);   

      
    if (r.m.ctrl.ld or st or not dco.mds) = '1' then          
      for i in 0 to dsets-1 loop
        v.x.data(i) := dco.data(i);
      end loop;
      v.x.set := dco.set(DSETMSB downto 0); 
      if dco.mds = '0' then
        me_size := r.x.dci.size; me_laddr := r.x.laddr; me_signed := r.x.dci.signed;
      else
        me_size := v.x.dci.size; me_laddr := v.x.laddr; me_signed := v.x.dci.signed;
      end if;
      if (lddel /= 2) then
        v.x.data(0) := ld_align(v.x.data, v.x.set, me_size, me_laddr, me_signed);
      end if;
    end if;
    if (not RESET_ALL) and (is_fpga(fabtech) = 0) and (xc_rstn = '0') then
      v.x.data := (others => (others => '0')); --v.x.ldc := '0';
    end if;
    v.x.mexc := dco.mexc;

    v.x.icc := me_icc;
    v.x.ctrl.wicc := r.m.ctrl.wicc and not v.x.annul_all;
    
    if MACEN and ((v.x.ctrl.annul or v.x.ctrl.trap) = '0') then
      v.w.s.asr18 := me_asr18;
    end if;

    if (r.x.rstate = dsu2)
    then      
      me_nullify2 := '0'; v.x.set := dco.set(DSETMSB downto 0);
    end if;


    if (not RESET_ALL) and (xc_rstn = '0') then 
        v.x.ctrl.trap := '0'; v.x.ctrl.annul := '1';
    end if;
    
      dci.maddress <= r.m.result;
    dci.enaddr   <= r.m.dci.enaddr;
    dci.asi      <= r.m.dci.asi;
    dci.size     <= r.m.dci.size;
    dci.lock     <= (r.m.dci.lock and not r.m.ctrl.annul);
    dci.read     <= r.m.dci.read;
    dci.write    <= r.m.dci.write;
    dci.flush    <= me_iflush;
    dci.dsuen    <= r.m.dci.dsuen;
    dci.msu    <= r.m.su;
    dci.esu    <= r.e.su;
    dbgo.ipend <= v.x.ipend or irqi.forceerr or irqi.pwdsetaddr;
    
-----------------------------------------------------------------------
-- EXECUTE STAGE
-----------------------------------------------------------------------

    v.m.ctrl := r.e.ctrl; ex_op1 := r.e.op1; ex_op2 := r.e.op2;
    v.m.ctrl.rett := r.e.ctrl.rett and not r.e.ctrl.annul;
    v.m.ctrl.wreg := r.e.ctrl.wreg and not v.x.annul_all;
    ex_ymsb := r.e.ymsb; mul_op2 := ex_op2; ex_shcnt := r.e.shcnt;
    v.e.cwp := r.a.cwp; ex_sari := r.e.sari;
    v.m.su := r.e.su;
    if MULTYPE = 3 then v.m.mul := r.e.mul; else v.m.mul := '0'; end if;
    if lddel = 1 then
      if r.e.ldbp1 = '1' then 
        ex_op1 := r.x.data(0); 
        ex_sari := r.x.data(0)(31) and r.e.ctrl.inst(19) and r.e.ctrl.inst(20);
      end if;
      if r.e.ldbp2 = '1' then 
        ex_op2 := r.x.data(0); ex_ymsb := r.x.data(0)(0); 
        mul_op2 := ex_op2; ex_shcnt := r.x.data(0)(4 downto 0);
        if r.e.invop2 = '1' then 
          ex_op2 := not ex_op2; ex_shcnt := not ex_shcnt;
        end if;
      end if;
    end if;


    ex_add_res := (ex_op1 & '1') + (ex_op2 & r.e.alucin);

    if ex_add_res(2 downto 1) = "00" then v.m.nalign := '0';
    else v.m.nalign := '1'; end if;
    if REX=1 then
      if ex_add_res(2 downto 1) /= "10" then v.m.rexnalign := '0';
      else v.m.rexnalign := '1'; end if;
    end if;

    dcache_gen(r, v, ex_dci, ex_link_pc, ex_jump, ex_force_a2, ex_load, v.m.casa);
    ex_jump_address := ex_add_res(32 downto PCLOW+1);
    logic_op(r, ex_op1, ex_op2, v.x.y, ex_ymsb, ex_logic_res, v.m.y);
    ex_shift_res := shift(r, ex_op1, ex_op2, ex_shcnt, ex_sari);
    misc_op(r, wpr, ex_op1, ex_op2, xc_df_result, v.x.y, xc_wimmask, cpuid, ex_misc_res, ex_edata);
    ex_add_res(3):= ex_add_res(3) or ex_force_a2;
    if CASAEN and LDDEL=2 and (r.m.casa='1' and r.e.ctrl.cnt="11") then
      ex_add_res(32 downto 1) := r.e.op2;
    end if;
    alu_select(r, ex_add_res, ex_op1, ex_op2, ex_shift_res, ex_logic_res,
        ex_misc_res, ex_result, me_icc, v.m.icc, v.m.divz, v.m.casaz);    
    dbg_cache(holdn, dbgi, r, dsur, ex_result, ex_dci, ex_result2, v.m.dci);
    fpstdata(r, ex_edata, ex_result2, fpo.data, ex_edata2, ex_result3);
    v.m.result := ex_result3;
    cwp_ex(r, v.m.wcwp, v.m.wawp);

    if CASAEN and ( (LDDEL=1 and (r.m.casa='1' and r.e.ctrl.cnt="10")) or
                    (LDDEL=2 and (r.m.casa='1' and r.e.ctrl.cnt="11")))
      and v.m.casaz='0' then
      me_nullify2 := '1';
    end if;
    dci.nullify  <= me_nullify2;

    ex_mulop1 := (ex_op1(31) and r.e.ctrl.inst(19)) & ex_op1;
    ex_mulop2 := (mul_op2(31) and r.e.ctrl.inst(19)) & mul_op2;

    if is_fpga(fabtech) = 0 and (r.e.mul = '0') then     -- power-save for mul
--    if (r.e.mul = '0') then
        ex_mulop1 := (others => '0'); ex_mulop2 := (others => '0');
    end if;

      
    v.m.ctrl.annul := v.m.ctrl.annul or v.x.annul_all;
    v.m.ctrl.wicc := r.e.ctrl.wicc and not v.x.annul_all; 
    v.m.mac := r.e.mac;
    if (DBGUNIT and (r.x.rstate = dsu2)) then v.m.ctrl.ld := '1'; end if;
    dci.eenaddr  <= v.m.dci.enaddr;
    dci.eaddress <= ex_add_res(32 downto 1);
    dci.edata <= ex_edata2;
    bp_miss_ex(r, r.m.icc, ex_bpmiss, ra_bpannul);
    
-----------------------------------------------------------------------
-- REGFILE STAGE
-----------------------------------------------------------------------

    v.e.ctrl := r.a.ctrl; v.e.jmpl := r.a.jmpl and not r.a.ctrl.trap;
    v.e.ctrl.annul := r.a.ctrl.annul or ra_bpannul or v.x.annul_all;
    v.e.ctrl.rett := r.a.ctrl.rett and not r.a.ctrl.annul and not r.a.ctrl.trap;
    v.e.ctrl.wreg := r.a.ctrl.wreg and not (ra_bpannul or v.x.annul_all);    
    v.e.su := r.a.su; v.e.et := r.a.et;
    v.e.ctrl.wicc := r.a.ctrl.wicc and not (ra_bpannul or v.x.annul_all);
    v.e.rfe1 := r.a.rfe1; v.e.rfe2 := r.a.rfe2;
    
    exception_detect(r, wpr, dbgi, r.a.ctrl.trap, r.a.ctrl.tt, 
                     v.e.ctrl.trap, v.e.ctrl.tt);
    op_mux(r, rfo.data1, ex_result3, v.x.result, xc_df_result, zero32, 
        r.a.rsel1, v.e.ldbp1, ra_op1, '0');
    op_mux(r, rfo.data2,  ex_result3, v.x.result, xc_df_result, r.a.imm, 
        r.a.rsel2, ex_ldbp2, ra_op2, '1');
    alu_op(r, ra_op1, ra_op2, v.m.icc, v.m.y(0), ex_ldbp2, v.e.op1, v.e.op2,
           v.e.aluop, v.e.alusel, v.e.aluadd, v.e.shcnt, v.e.sari, v.e.shleft,
           v.e.ymsb, v.e.mul, ra_div, v.e.mulstep, v.e.mac, v.e.ldbp2, v.e.invop2
    );
    cin_gen(r, v.m.icc(0), v.e.alucin);
    bp_miss_ra(r, ra_bpmiss, de_bpannul);
    v.e.bp := r.a.bp and not ra_bpmiss;

    
-----------------------------------------------------------------------
-- DECODE STAGE
-----------------------------------------------------------------------

    if ISETS > 1 then de_inst1 := r.d.inst(conv_integer(r.d.set));
    else de_inst1 := r.d.inst(0); end if;

    de_nrexen := '0'; de_nbufpos16:="10"; de_ncnt16:="0"; de_rexhold:='0';
    de_rexbubble := '0'; de_rexbaddr1:='0'; de_reximmexp:='0'; de_reximmval:=(others => '0');
    de_rexmaskpv := '0'; de_rexillinst:='0'; de_rexnostep:='0';
    if REX=1 then
      rex_decode(r, de_inst1, de_inst, de_nrexen, de_nbufpos16, de_ncnt16,
                 de_rexhold, de_rexbubble, de_rexbaddr1, de_reximmexp,
                 de_reximmval, v.a.getpc, de_rexmaskpv, de_rexillinst,
                 de_rexnostep, v.a.ctrl.itovr);
    else
      de_inst := de_inst1;
    end if;
    
    de_icc := r.m.icc; v.a.cwp := r.d.cwp;
    if AWPEN then
      v.a.awp:=r.d.awp; v.a.aw:=r.d.aw; v.a.paw:=r.d.paw;
      v.e.awp:=r.a.awp; v.e.aw:=r.a.aw; v.e.paw:=r.a.paw;
    end if;
    su_et_select(r, v.w.s.ps, v.w.s.s, v.w.s.et, v.a.su, v.a.et);
    wicc_y_gen(de_inst, v.a.ctrl.wicc, v.a.ctrl.wy);
    de_rcwp := r.d.cwp;
    if AWPEN and r.d.aw='1' then de_rcwp := r.d.awp; end if;
    cwp_ctrl(r, de_rcwp, v.w.s.wim, de_inst, de_cwp, v.a.wovf, v.a.wunf, de_wcwp);
    if AWPEN and (r.d.aw='1' or (r.d.paw='1' and de_inst(24 downto 19)=RETT)) then v.a.wovf:='0'; v.a.wunf:='0'; end if;
    if CASAEN and (de_inst(31 downto 30) = LDST) and (de_inst(24 downto 19) = CASA) then
      case r.d.cnt is
      when "00" | "01" => de_inst(4 downto 0) := "00000"; -- rs2=0
      when others =>
      end case;
    end if;
    rs1_gen(r, de_inst, v.a.rs1, de_rs1mod); 
    de_rs2 := de_inst(4 downto 0);
    de_raddr1 := (others => '0'); de_raddr2 := (others => '0');
    
    if RS1OPT then
      if de_rs1mod = '1' then
        regaddr(de_rcwp, de_inst(29 downto 26) & v.a.rs1(0), r.d.stwin, r.d.cwpmax, de_raddr1(RFBITS-1 downto 0));
      else
        regaddr(de_rcwp, de_inst(18 downto 15) & v.a.rs1(0), r.d.stwin, r.d.cwpmax, de_raddr1(RFBITS-1 downto 0));
      end if;
    else
      regaddr(de_rcwp, v.a.rs1, r.d.stwin, r.d.cwpmax, de_raddr1(RFBITS-1 downto 0));
    end if;
    regaddr(de_rcwp, de_rs2, r.d.stwin, r.d.cwpmax, de_raddr2(RFBITS-1 downto 0));
    v.a.rfa1 := de_raddr1(RFBITS-1 downto 0); 
    v.a.rfa2 := de_raddr2(RFBITS-1 downto 0); 

    rd_gen(r, de_inst, v.a.ctrl.wreg, v.a.ctrl.ld, de_rd, de_rexen);
    if r.d.annul='1' then de_rexen:='0'; end if;
    regaddr(de_cwp, de_rd, r.d.stwin, r.d.cwpmax, v.a.ctrl.rd);
    
    fpbranch(de_inst, fpo.cc, de_fbranch);
    fpbranch(de_inst, cpo.cc, de_cbranch);
    v.a.imm := imm_data(r, de_inst, de_reximmexp, de_reximmval);
      de_iperr := '0';
    lock_gen(r, de_rs2, de_rd, v.a.rfa1, v.a.rfa2, v.a.ctrl.rd, de_inst, 
        fpo.ldlock, v.e.mul, ra_div, de_wcwp, v.a.ldcheck1, v.a.ldcheck2, de_ldlock, 
        v.a.ldchkra, v.a.ldchkex, v.a.bp, v.a.nobp, de_fins_hold, de_iperr, ico.bpmiss);
    ic_ctrl(r, de_inst, v.x.annul_all, de_ldlock, de_rexhold, de_rexbubble, de_rexmaskpv, de_rexillinst, branch_true(de_icc, de_inst),
        de_fbranch, de_cbranch, fpo.ccv, cpo.ccv, v.d.cnt, v.d.pc, de_branch,
        v.a.ctrl.annul, v.d.annul, v.a.jmpl, de_inull, v.d.pv, v.a.ctrl.pv,
        de_hold_pc, v.a.ticc, v.a.ctrl.rett, v.a.mulstart, v.a.divstart, 
        ra_bpmiss, ex_bpmiss, de_iperr, ico.bpmiss, ico.eocl);
    v.d.pcheld := de_hold_pc;

    v.a.bp := v.a.bp and not v.a.ctrl.annul;
    v.a.nobp := v.a.nobp and not v.a.ctrl.annul;

    v.a.ctrl.inst := de_inst;
    v.a.decill := de_rexillinst or (de_rexen and r.w.s.rextrap);

    cwp_gen(r, v, v.a.ctrl.annul, de_wcwp, de_cwp, v.d.cwp, v.d.awp, v.d.aw, v.d.paw, v.d.stwin, v.d.cwpmax);
    
    v.d.inull := ra_inull_gen(r, v);
    
    op_find(r, v.a.ldchkra, v.a.ldchkex, v.a.rs1, v.a.rfa1, 
            false, v.a.rfe1, v.a.rsel1, v.a.ldcheck1);
    op_find(r, v.a.ldchkra, v.a.ldchkex, de_rs2, v.a.rfa2, 
            imm_select(de_inst,(de_rexen and not r.w.s.rexdis)), v.a.rfe2, v.a.rsel2, v.a.ldcheck2);
    if CASAEN and lddel=2 and r.a.ctrl.cnt="10" and v.m.casa='1' then
      v.a.rsel1 := "000";
      v.a.rsel2 := "011";
      v.a.rfe1 := '1';
    end if;


    v.a.ctrl.wicc := v.a.ctrl.wicc and (not v.a.ctrl.annul) 
    ;
    v.a.ctrl.wreg := v.a.ctrl.wreg and (not v.a.ctrl.annul) 
    ;
    v.a.ctrl.rett := v.a.ctrl.rett and (not v.a.ctrl.annul) 
    ;
    v.a.ctrl.wy := v.a.ctrl.wy and (not v.a.ctrl.annul) 
    ;

    v.a.ctrl.trap := r.d.mexc 
    ;
    v.a.ctrl.tt := "000000";
      if r.d.mexc = '1' then
        v.a.ctrl.tt := "000001";
      end if;
    v.a.ctrl.pc := de_pcout(31 downto PCLOW);
    v.a.ctrl.cnt := r.d.cnt;
    v.a.step := r.d.step;
    
    if holdn = '0' then 
      de_raddr1(RFBITS-1 downto 0) := r.a.rfa1;
      de_raddr2(RFBITS-1 downto 0) := r.a.rfa2;
      de_ren1 := r.a.rfe1; de_ren2 := r.a.rfe2;
    else
      de_ren1 := v.a.rfe1; de_ren2 := v.a.rfe2;
    end if;

    if DBGUNIT then
      if (dbgi.denable = '1') and (r.x.rstate = dsu2) then        
        de_raddr1(RFBITS-1 downto 0) := dbgi.daddr(RFBITS+1 downto 2); de_ren1 := '1';
        de_raddr2 := de_raddr1; de_ren2 := '1';
      end if;
      v.d.step := dbgi.step and not r.d.annul and not de_rexnostep;
    end if;

    if de_hold_pc='0' then
      v.d.rexen := de_nrexen or de_rexen;
      v.d.rexpos := de_nbufpos16;
      v.d.rexcnt := de_ncnt16;
    end if;
    if (de_rexhold='1' and de_branch='0') then de_hold_pc:='1'; de_inull:='1'; end if;
    if v.x.annul_all='1' then
      v.d.rexen := '0';
      v.d.rexpos := "10";
    end if;

    rfi.wren <= (xc_wreg and holdn);
    rfi.raddr1 <= de_raddr1; rfi.raddr2 <= de_raddr2;
    rfi.ren1 <= de_ren1;
    rfi.ren2 <= de_ren2;
    ici.inull <= de_inull or xc_inull
    ;
    ici.flush <= me_iflush;
    v.d.divrdy := divo.nready;
    ici.fline <= r.x.ctrl.pc(31 downto 3);
    ici.nobpmiss <= (r.a.bp or r.e.bp) and BLOCKBPMISS;
    dbgo.bpmiss <= bpmiss and holdn;
    if (xc_rstn = '0') then
      v.d.cnt := (others => '0');
      v.d.rexen := '0';
      v.d.rexpos := "10";
      if need_extra_sync_reset(fabtech) /= 0 then 
        v.d.cwp := (others => '0');
      end if;
    end if;

-----------------------------------------------------------------------
-- FETCH STAGE
-----------------------------------------------------------------------

    bpmiss := ex_bpmiss or ra_bpmiss;
    npc := r.f.pc; fe_pc := r.f.pc;
    if ra_bpmiss = '1' then fe_pc := r.d.pc; end if;
    if ex_bpmiss = '1' then fe_pc := r.a.ctrl.pc; end if;
    fe_npc := zero32(31 downto PCLOW);
    fe_npc(31 downto 2) := fe_pc(31 downto 2) + 1;    -- Address incrementer

    v.a.bpimiss := '0';
    if (xc_rstn = '0') then
      if (not RESET_ALL) then 
        v.f.pc := (others => '0'); v.f.branch := '0';
        if DYNRST then v.f.pc(31 downto 12) := irqi.rstvec;
        else
          v.f.pc(31 downto 12) := conv_std_logic_vector(rstaddr, 20);
        end if;
      end if;
    elsif xc_exception = '1' then       -- exception
      v.f.branch := '1'; v.f.pc := xc_trap_address;
      npc := v.f.pc;
    elsif de_hold_pc = '1' then
      v.f.pc := r.f.pc; v.f.branch := r.f.branch;
      if bpmiss = '1' then
        v.f.pc := fe_npc; v.f.branch := '1';
        npc := v.f.pc;
      elsif ex_jump = '1' then
        v.f.pc := ex_jump_address; v.f.branch := '1';
        npc := v.f.pc;
      end if;
    elsif (ex_jump and not bpmiss) = '1' then
      v.f.pc := ex_jump_address; v.f.branch := '1';
      npc := v.f.pc;
    elsif (((ico.bpmiss and not r.d.annul) or r.a.bpimiss) and not bpmiss) = '1' then
      v.f.pc := r.d.pc; v.f.branch := '1';
      npc := v.f.pc;
      v.a.bpimiss := ico.bpmiss and not r.d.annul;
    elsif (de_branch and not bpmiss
        ) = '1'
    then
      v.f.pc := branch_address(de_inst, de_pcout(31 downto PCLOW), de_rexbaddr1, r.d.rexen); v.f.branch := '1';
      npc := v.f.pc;
    else
      v.f.branch := bpmiss; v.f.pc := fe_npc; npc := v.f.pc;
    end if;
    
    ici.dpc <= r.d.pc(31 downto 2) & "00";
    ici.fpc <= r.f.pc(31 downto 2) & "00";
    ici.rpc <= npc(31 downto 2) & "00";
    ici.fbranch <= r.f.branch;
    ici.rbranch <= v.f.branch;
    ici.su <= v.a.su;

    
    if (ico.mds and de_hold_pc) = '0' then
      v.d.rexbuf := de_inst1;
      for i in 0 to isets-1 loop
        v.d.inst(i) := ico.data(i);                     -- latch instruction
      end loop;
      v.d.set := ico.set(ISETMSB downto 0);             -- latch instruction
      v.d.mexc := ico.mexc;                             -- latch instruction

    end if;

    -- For pipelined REX implementation
    if REX/=0 and REXPIPE then
      rex_pl_fetch(v.d,r.d,holdn,
                   v.d.rexpl);
    end if;
-----------------------------------------------------------------------
-----------------------------------------------------------------------

    if DBGUNIT then -- DSU diagnostic read    
      diagread(dbgi, r, dsur, ir, wpr, dco, tbo, tbo_2p, xc_wimmask, cpuid, diagdata);
      diagrdy(dbgi.denable, dsur, r.m.dci, dco.mds, ico, vdsu.crdy);
      vdsu.cfc := dsur.cfc(3 downto 0) & r.f.branch;
    end if;
    
-----------------------------------------------------------------------
-- OUTPUTS
-----------------------------------------------------------------------

    rin <= v; wprin <= vwpr; dsuin <= vdsu; irin <= vir;
    muli.start <= r.a.mulstart and not r.a.ctrl.annul and 
        not r.a.ctrl.trap and not ra_bpannul;
    muli.signed <= r.e.ctrl.inst(19);
    muli.op1 <= ex_mulop1; --(ex_op1(31) and r.e.ctrl.inst(19)) & ex_op1;
    muli.op2 <= ex_mulop2; --(mul_op2(31) and r.e.ctrl.inst(19)) & mul_op2;
    muli.mac <= r.e.ctrl.inst(24);
    if MACPIPE then muli.acc(39 downto 32) <= r.w.s.y(7 downto 0);
    else muli.acc(39 downto 32) <= r.x.y(7 downto 0); end if;
    muli.acc(31 downto 0) <= r.w.s.asr18;
    muli.flush <= r.x.annul_all;
    divi.start <= r.a.divstart and not r.a.ctrl.annul and 
        not r.a.ctrl.trap and not ra_bpannul;
    divi.signed <= r.e.ctrl.inst(19);
    divi.flush <= r.x.annul_all;
    divi.op1 <= (ex_op1(31) and r.e.ctrl.inst(19)) & ex_op1;
    divi.op2 <= (ex_op2(31) and r.e.ctrl.inst(19)) & ex_op2;
    if (r.a.divstart and not r.a.ctrl.annul) = '1' then 
      dsign :=  r.a.ctrl.inst(19);
    else dsign := r.e.ctrl.inst(19); end if;
    divi.y <= (r.m.y(31) and dsign) & r.m.y;
    rpin <= vp;

    if DBGUNIT then
      dbgo.dsu <= '1'; dbgo.dsumode <= r.x.debug; dbgo.crdy <= dsur.crdy(2);
      dbgo.data <= diagdata;
      if TRACEBUF then
        tbi <= tbufi;
        if TRACEBUF_2P then tbi_2p <= tbufi_2p; else tbi_2p <= tracebuf_2p_in_type_none; end if;
      else
        tbi <= tracebuf_in_type_none;
        tbi_2p <= tracebuf_2p_in_type_none;
      end if;
    else
      dbgo.dsu <= '0'; dbgo.data <= (others => '0'); dbgo.crdy  <= '0';
      dbgo.dsumode <= '0'; tbi.addr <= (others => '0'); 
      tbi.data <= (others => '0'); tbi.enable <= '0';
      tbi.write <= (others => '0');
    end if;
    dbgo.error <= dummy and not r.x.nerror;
    dbgo.istat <= ico.cstat;
    dbgo.dstat <= dco.cstat;
    dbgo.wbhold <= dco.wbhold;
    dbgo.su <= r.w.s.s;


    if FPEN then
      if (r.x.rstate = dsu2) then vfpi.flush := '1'; else vfpi.flush := v.x.annul_all and holdn; end if;
      vfpi.exack := xc_fpexack; vfpi.a_rs1 := r.a.rs1; vfpi.d.inst := de_inst;
      vfpi.d.cnt := r.d.cnt;
      vfpi.d.annul := v.x.annul_all or de_bpannul or r.d.annul or de_fins_hold or (ico.bpmiss and not r.d.pcheld)
        ;
      vfpi.d.trap := r.d.mexc;
      vfpi.d.pc(1 downto 0) := (others => '0'); vfpi.d.pc(31 downto PCLOW) := r.d.pc(31 downto PCLOW); 
      vfpi.d.pv := r.d.pv;
      vfpi.a.pc(1 downto 0) := (others => '0'); vfpi.a.pc(31 downto PCLOW) := r.a.ctrl.pc(31 downto PCLOW); 
      vfpi.a.inst := r.a.ctrl.inst; vfpi.a.cnt := r.a.ctrl.cnt; vfpi.a.trap := r.a.ctrl.trap;
      vfpi.a.annul := r.a.ctrl.annul or (ex_bpmiss and r.e.ctrl.inst(29))
        ;
      vfpi.a.pv := r.a.ctrl.pv;
      vfpi.e.pc(1 downto 0) := (others => '0'); vfpi.e.pc(31 downto PCLOW) := r.e.ctrl.pc(31 downto PCLOW); 
      vfpi.e.inst := r.e.ctrl.inst; vfpi.e.cnt := r.e.ctrl.cnt; vfpi.e.trap := r.e.ctrl.trap; vfpi.e.annul := r.e.ctrl.annul;
      vfpi.e.pv := r.e.ctrl.pv;
      vfpi.m.pc(1 downto 0) := (others => '0'); vfpi.m.pc(31 downto PCLOW) := r.m.ctrl.pc(31 downto PCLOW); 
      vfpi.m.inst := r.m.ctrl.inst; vfpi.m.cnt := r.m.ctrl.cnt; vfpi.m.trap := r.m.ctrl.trap; vfpi.m.annul := r.m.ctrl.annul;
      vfpi.m.pv := r.m.ctrl.pv;
      vfpi.x.pc(1 downto 0) := (others => '0'); vfpi.x.pc(31 downto PCLOW) := r.x.ctrl.pc(31 downto PCLOW); 
      vfpi.x.inst := r.x.ctrl.inst; vfpi.x.cnt := r.x.ctrl.cnt; vfpi.x.trap := xc_trap;
      vfpi.x.annul := r.x.ctrl.annul; vfpi.x.pv := r.x.ctrl.pv;
      if (lddel = 2) then vfpi.lddata := r.x.data(conv_integer(r.x.set)); else vfpi.lddata := r.x.data(0); end if;
      if (r.x.rstate = dsu2)
      then vfpi.dbg.enable := dbgi.denable;
      else vfpi.dbg.enable := '0'; end if;      
      vfpi.dbg.write := fpcdbgwr;
      vfpi.dbg.fsr := dbgi.daddr(22); -- IU reg access
      vfpi.dbg.addr := dbgi.daddr(6 downto 2);
      vfpi.dbg.data := dbgi.ddata;      
      fpi <= vfpi;
      cpi <= vfpi;      -- dummy, just to kill some warnings ...
    end if;

  end process;

  preg : process (sclk)
  begin 
    if rising_edge(sclk) then 
      rp <= rpin;
      if rstn = '0' then
        rp.error <= PRES.error;
        if RESET_ALL then
          if (smp /= 0) and (irqi.rstrun = '0') then
            rp.pwd <= '1';
          else
            rp.pwd <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  reg : process (clk)
  begin
    if rising_edge(clk) then
      if (holdn = '1') then
        r <= rin;
      else
        r.x.ipend <= rin.x.ipend;
        r.m.werr <= rin.m.werr;
        if (holdn or ico.mds) = '0' then
          r.d.inst <= rin.d.inst; r.d.mexc <= rin.d.mexc; 
          r.d.set <= rin.d.set;
          r.d.rexpl <= rin.d.rexpl;
        end if;
        if (holdn or dco.mds) = '0' then
          r.x.data <= rin.x.data; r.x.mexc <= rin.x.mexc; 
          r.x.set <= rin.x.set;
        end if;
      end if;
      if rstn = '0' then
        if RESET_ALL then
          r <= RRES;
          if DYNRST then
            r.f.pc(31 downto 12) <= irqi.rstvec;
            r.w.s.tba <= irqi.rstvec;
          end if;
          if DBGUNIT then
            if (dbgi.dsuen and dbgi.dbreak) = '1' then
              r.x.rstate <= dsu1; r.x.debug <= '1';
            end if;
          end if;
          if (smp /= 0) and irqi.rstrun = '0' then
            r.x.rstate <= dsu1;
          end if;
        else  
          r.w.s.s <= '1'; r.w.s.ps <= '1'; 
          if need_extra_sync_reset(fabtech) /= 0 then 
            r.d.inst <= (others => (others => '0'));
            r.x.mexc <= '0';
          end if; 
        end if;
      end if;
      if REX=0 then
        r.d.rexen <= RRES.d.rexen;
        r.d.rexpos <= RRES.d.rexpos;
        r.d.rexbuf <= RRES.d.rexbuf;
        r.d.rexcnt <= RRES.d.rexcnt;
        r.a.getpc <= RRES.a.getpc;
        r.a.decill <= RRES.a.decill;
        r.m.rexnalign <= RRES.m.rexnalign;
        r.a.ctrl.itovr <= RRES.a.ctrl.itovr;
        r.e.ctrl.itovr <= RRES.e.ctrl.itovr;
        r.m.ctrl.itovr <= RRES.m.ctrl.itovr;
        r.x.ctrl.itovr <= RRES.x.ctrl.itovr;
      end if;
      if not REXPIPE then r.d.rexpl <= RRES.d.rexpl; end if;
      if not AWPEN then
        r.w.s.aw <= RRES.w.s.aw;
        r.w.s.paw <= RRES.w.s.paw;
        r.w.s.awp <= RRES.w.s.awp;
        r.d.awp <= RRES.d.awp;
        r.d.aw <= RRES.d.aw;
        r.d.paw <= RRES.d.paw;
        r.a.awp <= RRES.a.awp;
        r.a.aw <= RRES.a.aw;
        r.a.paw <= RRES.a.paw;
        r.m.wawp <= RRES.m.wawp;
      end if;
      if not RFPART then
        r.w.s.stwin <= RRES.w.s.stwin;
        r.w.s.cwpmax <= RRES.w.s.cwpmax;
        r.w.twcwp <= RRES.w.twcwp;
        r.d.stwin <= RRES.d.stwin;
        r.d.cwpmax <= RRES.d.cwpmax;
      end if;
    end if;
  end process;


  dsugen : if DBGUNIT generate
    dsureg : process(clk) begin
      if rising_edge(clk) then 
        if holdn = '1' then
          dsur <= dsuin;
        else
          dsur.crdy <= dsuin.crdy;
        end if;
        if rstn = '0' then
          if RESET_ALL then
            dsur <= DRES;
          elsif need_extra_sync_reset(fabtech) /= 0 then
            dsur.err <= '0'; dsur.tbufcnt <= (others => '0'); dsur.tt <= (others => '0');
            dsur.asi <= (others => '0'); dsur.crdy <= (others => '0');
          end if;
        end if;
      end if;
    end process;
  end generate;

  nodsugen : if not DBGUNIT generate
    dsur.err <= '0'; dsur.tbufcnt <= (others => '0'); dsur.tt <= (others => '0');
    dsur.asi <= (others => '0'); dsur.crdy <= (others => '0');
    dsur.tfilt <= (others => '0'); dsur.cfc <= (others => '0');
    dsur.tlim <= (others => '0'); dsur.tov <= '0'; dsur.tovb <= '0';
  end generate;

  irreg : if DBGUNIT or PWRD2
  generate
    dsureg : process(clk) begin
      if rising_edge(clk) then 
        if holdn = '1' then ir <= irin; end if;
        if RESET_ALL and rstn = '0' then ir <= IRES; end if;
      end if;
    end process;
  end generate;

  nirreg : if not (DBGUNIT or PWRD2
    )
  generate
    ir.pwd <= '0'; ir.addr <= (others => '0');
  end generate;
  
  wpgen : for i in 0 to 3 generate
    wpg0 : if nwp > i generate
      wpreg : process(clk) begin
        if rising_edge(clk) then
          if holdn = '1' then wpr(i) <= wprin(i); end if;
          if rstn = '0' then
            if RESET_ALL then
              wpr(i) <= wpr_none;
            else
              wpr(i).exec <= '0'; wpr(i).load <= '0'; wpr(i).store <= '0';
            end if;
          end if;
        end if;
      end process;
    end generate;
    wpg1 : if nwp <= i generate
      wpr(i) <= wpr_none;
    end generate;
  end generate;

-- pragma translate_off
  trc : process(clk)
    variable valid : boolean;
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
    variable fpins, fpld : boolean;
    variable pc: std_logic_vector(31 downto 0);
    variable rexen: boolean;
  begin
    if (fpu /= 0) then
      op := r.x.ctrl.inst(31 downto 30); op3 := r.x.ctrl.inst(24 downto 19);
      fpins := (op = FMT3) and ((op3 = FPOP1) or (op3 = FPOP2));
      fpld := (op = LDST) and ((op3 = LDF) or (op3 = LDDF) or (op3 = LDFSR));
    else
      fpins := false; fpld := false;
    end if;
      valid := (((not r.x.ctrl.annul) and (r.x.ctrl.pv or r.x.ctrl.itovr)) = '1') and (not ((fpins or fpld) and (r.x.ctrl.trap = '0')));
      valid := valid and (holdn = '1');
    pc := r.x.ctrl.pc(31 downto 2) & "00";
    rexen:=false;
    if rex=1 then pc(1):=r.x.ctrl.pc(2-1*REX); rexen:=(r.x.ctrl.pc(2-2*REX)='1'); end if;
    if (disas = 1) and rising_edge(clk) and (rstn = '1') then
      print_insn(cpuid, pc, r.x.ctrl.inst,
                  rin.w.result, valid, r.x.ctrl.trap = '1', rin.w.wreg = '1',
                  rexen);
    end if;
  end process;
-- pragma translate_on

  dis0 : if disas < 2 generate dummy <= '1'; end generate;

  dis2 : if disas > 1 generate
      disasen <= '1' when disas /= 0 else '0';
      cpu_index <= conv_std_logic_vector(cpuid, 4);
      x0 : cpu_disasx
      port map (clk, rstn, dummy, r.x.ctrl.inst, r.x.ctrl.pc(31 downto 2),
        rin.w.result, cpu_index, rin.w.wreg, r.x.ctrl.annul, holdn,
        r.x.ctrl.pv, r.x.ctrl.trap, disasen);
  end generate;

  program_counter <= r.d.pc;
  pv <= r.d.pv;
  inst0 <= r.d.inst(0);
  inst1 <= r.d.inst(1);
  m_addr <= r.m.result;
  psr <= r.w.s;
  
end;

