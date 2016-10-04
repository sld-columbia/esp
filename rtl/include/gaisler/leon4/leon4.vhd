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
-- Package: 	leon4
-- File:	leon4.vhd
-- Author:	Cobham Gaisler AB
-- Description:	LEON4 types and components
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.gencomp.all;
use work.leon3.l3_cstat_type;
use work.leon3.cstat_none;
use work.leon3.dsu_astat_type;
use work.leon3.dsu_astat_none;
use work.leon3.l3stat_in_type;
use work.leon3.l3stat_in_none;
use work.coretypes.l3_irq_in_type;
use work.coretypes.l3_irq_out_type;
use work.leon3.grfpu_in_type;
use work.leon3.grfpu_out_type;

package leon4 is

  constant LEON4_VERSION : integer := 0;

  type l4_debug_in_type is record
    dsuen   : std_ulogic;  -- DSU enable
    denable : std_ulogic;  -- diagnostic register access enable
    dbreak  : std_ulogic;  -- debug break-in
    step    : std_ulogic;  -- single step    
    halt    : std_ulogic;  -- halt processor
    reset   : std_ulogic;  -- reset processor
    dwrite  : std_ulogic;  -- read/write
    daddr   : std_logic_vector(23 downto 2); -- diagnostic address
    ddata   : std_logic_vector(31 downto 0); -- diagnostic data
    btrapa  : std_ulogic;	   -- break on IU trap
    btrape  : std_ulogic;	-- break on IU trap
    berror  : std_ulogic;	-- break on IU error mode
    bwatch  : std_ulogic;	-- break on IU watchpoint
    bsoft   : std_ulogic;	-- break on software breakpoint (TA 1)
    tenable : std_ulogic;
    timer   : std_logic_vector(63 downto 0);                                                -- 
  end record;
  
  type l4_debug_out_type is record
    data    : std_logic_vector(31 downto 0);
    crdy    : std_ulogic;
    dsu     : std_ulogic;
    dsumode : std_ulogic;
    error   : std_ulogic;
    halt    : std_ulogic;
    pwd     : std_ulogic;
    idle    : std_ulogic;
    ipend   : std_ulogic;
    icnt    : std_ulogic;
    fcnt    : std_ulogic;
    optype  : std_logic_vector(5 downto 0);	-- instruction type
    bpmiss  : std_ulogic;			-- branch predict miss
    istat   : l3_cstat_type;
    dstat   : l3_cstat_type;
    wbhold  : std_ulogic;			-- write buffer hold
    su      : std_ulogic;			-- supervisor state
    ducnt   : std_ulogic;                       -- disable timer 
  end record;

  type l4_debug_in_vector is array (natural range <>) of l4_debug_in_type;
  type l4_debug_out_vector is array (natural range <>) of l4_debug_out_type;

  constant l4_dbgi_none : l4_debug_in_type := ('0', '0', '0', '0', '0', '0',
       '0', (others => '0'), (others => '0'), '0', '0', '0', '0', '0', '0',
       (others => '0'));
  
  constant l4_dbgo_none : l4_debug_out_type := (X"00000000", '0', '0', '0', '0',
       '0', '0', '0', '0', '0', '0', "000000", '0', cstat_none, cstat_none, '0',
       '0', '0');

  
  component leon4s
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 63 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;    
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram     : integer range 0 to 1 := 0;
    ilramsize : integer range 1 to 512 := 1;
    ilramstart: integer range 0 to 255 := 16#8e#;
    dlram     : integer range 0 to 1 := 0;
    dlramsize : integer range 1 to 512 := 1;
    dlramstart: integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3 := 1;
    tlb_rep   : integer range 0 to 1 := 0;
    lddel     : integer range 1 to 2 := 2;
    disas     : integer range 0 to 2 := 0;
    tbuf      : integer range 0 to 128 := 0;
    pwd       : integer range 0 to 2 := 2;     -- power-down
    svt       : integer range 0 to 1 := 1;     -- single vector trapping
    rstaddr   : integer := 16#00000#;          -- reset vector address [31:12]
    smp       : integer range 0 to 31 := 0;    -- support SMP systems
    cached    : integer               := 0;     -- cacheability table
    scantest  : integer               := 0;
    wbmask    : integer               := 0;    -- Wide-bus mask
    busw      : integer               := 64;   -- AHB/Cache data width (64/128)
    netlist   : integer               := 0;
    ft        : integer               := 0;
    npasi     : integer range 0 to 1  := 0;
    pwrpsr    : integer range 0 to 1  := 0
  );
  port (
    clk    : in  std_ulogic;
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l4_debug_in_type;
    dbgo   : out l4_debug_out_type
  );
  end component; 

  component leon4x
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 63 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2  := 0;
    tbuf      : integer range 0 to 128 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 31 := 0;     -- support SMP systems
    cached    : integer               := 0;	-- cacheability table
    clk2x     : integer               := 0;
    scantest  : integer               := 0;
    wbmask    : integer               := 0;    -- Wide-bus mask
    busw      : integer               := 64;   -- AHB/Cache data width (64/128)
    netlist   : integer               := 0;     -- Use netlist
    ft        : integer               := 0;    -- FT option
    npasi     : integer range 0 to 1  := 0;
    pwrpsr    : integer range 0 to 1  := 0;
    ahbpipe   : integer := 0
  );
  port (
    ahbclk : in  std_ulogic;    -- bus clock
    cpuclk : in  std_ulogic;    -- cpu clock
    gcpuclk: in  std_ulogic;    -- gated cpu clock
    fpuclk : in  std_ulogic;
    hclken : in  std_ulogic;    -- bus clock enable qualifier
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;    
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l4_debug_in_type;
    dbgo   : out l4_debug_out_type;
    fpui   : out grfpu_in_type;
    fpuo   : in  grfpu_out_type
  );
 end component; 

  component leon4sh
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 63 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2  := 0;
    tbuf      : integer range 0 to 128 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 31 := 0;     -- support SMP systems
    cached    : integer               := 0;	-- cacheability table
    scantest  : integer               := 0;
    wbmask    : integer               := 0;    -- Wide-bus mask
    busw      : integer               := 64;   -- AHB/Cache data width (64/128)
    netlist   : integer               := 0;
    ft        : integer               := 0;
    npasi     : integer range 0 to 1  := 0;
    pwrpsr    : integer range 0 to 1  := 0
  );
  port (
    clk    : in  std_ulogic;
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;    
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l4_debug_in_type;
    dbgo   : out l4_debug_out_type;
    fpui   : out grfpu_in_type;
    fpuo   : in  grfpu_out_type
  );
  end component;

  component leon4cg
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 63 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;    
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram     : integer range 0 to 1 := 0;
    ilramsize : integer range 1 to 512 := 1;
    ilramstart: integer range 0 to 255 := 16#8e#;
    dlram     : integer range 0 to 1 := 0;
    dlramsize : integer range 1 to 512 := 1;
    dlramstart: integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3 := 1;
    tlb_rep   : integer range 0 to 1 := 0;
    lddel     : integer range 1 to 2 := 2;
    disas     : integer range 0 to 2 := 0;
    tbuf      : integer range 0 to 128 := 0;
    pwd       : integer range 0 to 2 := 2;     -- power-down
    svt       : integer range 0 to 1 := 1;     -- single vector trapping
    rstaddr   : integer := 16#00000#;          -- reset vector address [31:12]
    smp       : integer range 0 to 31 := 0;    -- support SMP systems
    cached    : integer               := 0;     -- cacheability table
    scantest  : integer               := 0;
    wbmask    : integer               := 0;    -- Wide-bus mask
    busw      : integer               := 64;   -- AHB/Cache data width (64/128)
    netlist   : integer               := 0;
    ft        : integer               := 0;
    npasi     : integer range 0 to 1  := 0;
    pwrpsr    : integer range 0 to 1  := 0
  );
  port (
    clk    : in  std_ulogic;
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l4_debug_in_type;
    dbgo   : out l4_debug_out_type;
    gclk   : in  std_ulogic
  );
  end component; 

  component leon4s2x
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2  := 0;
    tbuf      : integer range 0 to 128 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 15 := 0;     -- support SMP systems
    cached    : integer               := 0;	-- cacheability table
    clk2x     : integer               := 1;
    scantest  : integer               := 0;
    wbmask    : integer               := 0;    -- Wide-bus mask
    busw      : integer               := 64;   -- AHB/Cache data width (64/128)
    netlist   : integer               := 0;
    ft        : integer               := 0;
    npasi     : integer range 0 to 1  := 0;
    pwrpsr    : integer range 0 to 1  := 0
  );
  port (
    clk    : in  std_ulogic;
    gclk2  : in  std_ulogic;    
    clk2   : in  std_ulogic;    		-- snoop clock
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;    
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l4_debug_in_type;
    dbgo   : out l4_debug_out_type;
    clken  : in  std_ulogic
  );
  end component; 

  component leon4ft
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 63 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2  := 0;
    tbuf      : integer range 0 to 128 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 31 := 0;     -- support SMP systems
    cached    : integer               := 0;	-- cacheability table
    scantest  : integer               := 0;
    wbmask    : integer               := 0;    -- Wide-bus mask
    busw      : integer               := 64;   -- AHB/Cache data width (64/128)
    netlist   : integer               := 0;    -- Netlist option
    ft        : integer               := 0;    -- FT option
    npasi     : integer range 0 to 1  := 0;
    pwrpsr    : integer range 0 to 1  := 0
  );
  port (
    clk    : in  std_ulogic;
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;    
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l4_debug_in_type;
    dbgo   : out l4_debug_out_type;
    fpui   : out grfpu_in_type;
    fpuo   : in  grfpu_out_type;
    gclk   : in  std_ulogic	-- gated clock
  );
  end component; 

  type dsu4_in_type is record
    enable  : std_ulogic;
    break   : std_ulogic;
  end record;                        

  constant dsu4_astat_none : dsu_astat_type := dsu_astat_none;
  
  type dsu4_out_type is record
    active          : std_ulogic;
    tstop           : std_ulogic;
    pwd             : std_logic_vector(15 downto 0);
    astat           : dsu_astat_type;
  end record;

  constant dsu4_out_none : dsu4_out_type :=
    ('0', '0', (others => '0'), dsu_astat_none);
  
  component dsu4 
  generic (
    hindex  : integer := 0;
    haddr   : integer := 16#900#;
    hmask   : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0;
    bwidth  : integer := 64;
    ahbpf   : integer := 0;
    ahbwp   : integer := 2;
    scantest: integer := 0;
    pipedbg : integer range 0 to 1 := 0;
    pipeahbt: integer range 0 to 1 := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    dbgi   : in l4_debug_out_vector(0 to NCPU-1);
    dbgo   : out l4_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu4_in_type;
    dsuo   : out dsu4_out_type
  );
  end component;

  component dsu4_2x 
  generic (
    hindex  : integer := 0;
    haddr : integer := 16#900#;
    hmask : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0;
    bwidth  : integer := 64;
    ahbpf   : integer := 0;
    ahbwp   : integer := 2;
    scantest: integer := 0;
    pipedbg : integer range 0 to 1 := 0;
    pipeahbt: integer range 0 to 1 := 0
  );
  port (
    rst    : in  std_ulogic;
    hclk   : in  std_ulogic;
    cpuclk : in std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    dbgi   : in l4_debug_out_vector(0 to NCPU-1);
    dbgo   : out l4_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu4_in_type;
    dsuo   : out dsu4_out_type;
    hclken : in std_ulogic    
  );
  end component;

  component dsu4_mb
  generic (
    hindex  : integer := 0;
    haddr   : integer := 16#900#;
    hmask   : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0;
    bwidth  : integer := 64;
    ahbpf   : integer := 0;
    ahbwp   : integer := 2;
    scantest: integer := 0;
    pipedbg : integer range 0 to 1 := 0;
    pipeahbt: integer range 0 to 1 := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    tahbsi : in  ahb_slv_in_type;
    dbgi   : in l4_debug_out_vector(0 to NCPU-1);
    dbgo   : out l4_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu4_in_type;
    dsuo   : out dsu4_out_type
  );
  end component;
  
  component dsu4x 
  generic (
    hindex  : integer := 0;
    haddr : integer := 16#900#;
    hmask : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0;
    clk2x   : integer range 0 to 1 := 0;
    bwidth  : integer := 64;
    ahbpf   : integer := 0;
    ahbwp   : integer := 2;
    scantest: integer := 0;
    pipedbg : integer := 0;
    pipeahbt: integer := 0
  );
  port (
    rst    : in  std_ulogic;
    hclk   : in  std_ulogic;
    cpuclk : in  std_ulogic;
    fcpuclk: in  std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    tahbsi : in  ahb_slv_in_type;
    dbgi   : in l4_debug_out_vector(0 to NCPU-1);
    dbgo   : out l4_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu4_in_type;
    dsuo   : out dsu4_out_type;
    hclken : in std_ulogic
    );
  end component;
  
  constant l4stat_in_none : l3stat_in_type := l3stat_in_none;
  
  component l4stat
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
    dbgo   : in  l4_debug_out_vector(0 to NCPU-1);
    dsuo   : in  dsu4_out_type := dsu4_out_none;
    stati  : in  l3stat_in_type := l4stat_in_none;
    apb2i  : in  apb_slv_in_type := apb_slv_in_none;
    apb2o  : out apb_slv_out_type;
    astat  : in  amba_stat_type := amba_stat_none);
  end component;

end;

