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
-- Package: 	misc
-- File:	misc.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Misc models
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.devices.all;
use work.stdlib.all;
use work.gencomp.all;

package misc is

-- reset generator with filter

  component rstgen
  generic (acthigh : integer := 0; syncrst : integer := 0;
	   scanen : integer := 0; syncin  : integer := 0);
  port (
    rstin     : in  std_ulogic;
    clk       : in  std_ulogic;
    clklock   : in  std_ulogic;
    rstout    : out std_ulogic;
    rstoutraw : out std_ulogic;
    testrst   : in  std_ulogic := '0';
    testen    : in  std_ulogic := '0');
  end component;

  type gptimer_in_type is record
    dhalt    : std_ulogic;
    extclk   : std_ulogic;
    wdogen   : std_ulogic;
    latchv   : std_logic_vector(NAHBIRQ-1 downto 0);
    latchd   : std_logic_vector(NAHBIRQ-1 downto 0);
  end record;

  function gpti_dhalt_drive (dhalt : std_ulogic) return gptimer_in_type;
  
  type gptimer_in_vector is array (natural range <>) of gptimer_in_type;

  type gptimer_out_type is record
    tick     : std_logic_vector(0 to 7);
    timer1   : std_logic_vector(31 downto 0);
    wdogn    : std_ulogic;
    wdog    : std_ulogic;
  end record;

  type gptimer_out_vector is array (natural range <>) of gptimer_out_type;

  constant gptimer_in_none : gptimer_in_type := ('0', '0', '0', zxirq(NAHBIRQ-1 downto 0), zxirq(NAHBIRQ-1 downto 0));

  constant gptimer_out_none : gptimer_out_type :=
    ((others => '0'), (others => '0'), '1', '0');

  component gptimer
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    pirq     : integer := 0;
    sepirq   : integer := 0;	-- use separate interrupts for each timer
    sbits    : integer := 16;			-- scaler bits
    ntimers  : integer range 1 to 7 := 1; 	-- number of timers
    nbits    : integer := 32;			-- timer bits
    wdog     : integer := 0;
    ewdogen  : integer := 0;
    glatch   : integer := 0;
    gextclk  : integer := 0;
    gset     : integer := 0;
    gelatch  : integer range 0 to 2 := 0;
    wdogwin  : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    gpti   : in gptimer_in_type;
    gpto   : out gptimer_out_type
  );
  end component;

-- 32-bit ram with AHB interface

  component ahbram
  generic (
    hindex  : integer := 0;
    tech    : integer := DEFMEMTECH;
    kbytes  : integer := 1;
    pipe    : integer := 0;
    maccsz  : integer := AHBDW;
    scantest: integer := 0);
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    haddr  : in  integer;
    hmask  : in  integer;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type);
  end component;

  type ahbram_out_type is record
    ce : std_ulogic;
  end record;

  component ftahbram
    generic (
      hindex    : integer := 0;
      haddr     : integer := 0;
      hmask     : integer := 16#fff#;
      tech      : integer := DEFMEMTECH;
      kbytes    : integer := 1;
      pindex    : integer := 0;
      paddr     : integer := 0;
      pmask     : integer := 16#fff#;
      edacen    : integer range 0 to 3 := 1;  --enable EDAC
      autoscrub : integer range 0 to 1 := 0;  --enable auto-scrubbing    
      errcnten  : integer range 0 to 1 := 0;  --enable error counter in stat.reg
      cntbits   : integer range 1 to 8 := 1; --errcnt size in bits
      ahbpipe   : integer range 0 to 1 := 0;
      testen    : integer := 0);
    port (
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      aramo   : out ahbram_out_type
    );
  end component;

  component ftahbram1 is
    generic (
      hindex    : integer := 0;
      haddr     : integer := 0;
      hmask     : integer := 16#fff#;
      tech      : integer := DEFMEMTECH;
      kbytes    : integer := 1;
      pindex    : integer := 0;
      paddr     : integer := 0;
      pmask     : integer := 16#fff#;
      edacen    : integer range 0 to 3 := 1;
      autoscrub : integer range 0 to 1 := 0;
      errcnten  : integer range 0 to 1 := 0;
      cntbits   : integer range 1 to 8 := 1;
      ahbpipe   : integer range 0 to 1 := 0;
      testen    : integer := 0);
    port (
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      aramo   : out ahbram_out_type
    );
  end component;

  component ftahbram2 is
    generic (
      hindex    : integer := 0;
      haddr     : integer := 0;
      hmask     : integer := 16#fff#;
      tech      : integer := DEFMEMTECH;
      kbytes    : integer := 1;
      pindex    : integer := 0;
      paddr     : integer := 0;
      pmask     : integer := 16#fff#;
      testen    : integer := 0;
      edacen    : integer range 1 to 3 := 1);
    port (
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      aramo   : out ahbram_out_type
    );
  end component;

  component ahbdpram
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    tech    : integer := 2;
    abits   : integer range 8 to 19 := 8;
    bytewrite : integer range 0 to 1 := 0
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    clkdp   : in std_ulogic;
    address : in std_logic_vector((abits -1) downto 0);
    datain  : in std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0);
    enable  : in std_ulogic;			-- active high chip select
    write  : in std_logic_vector(0 to 3)	-- active high byte write enable
  );						-- big-endian write: bwrite(0) => data(31:24)
  end component;


  component ahbtrace is
  generic (
    hindex   : integer := 0;
    ioaddr   : integer := 16#000#;
    iomask   : integer := 16#E00#;
    tech     : integer := DEFMEMTECH;
    irq      : integer := 0;
    kbytes   : integer := 1;
    bwidth   : integer := 32;
    ahbfilt  : integer := 0;
    scantest : integer range 0 to 1 := 0;
    exttimer : integer range 0 to 1 := 0;
    exten    : integer range 0 to 1 := 0);
  port (
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    ahbmi    : in  ahb_mst_in_type;
    ahbsi    : in  ahb_slv_in_type;
    ahbso    : out ahb_slv_out_type;
    timer    : in  std_logic_vector(30 downto 0) := (others => '0');
    astat    : out amba_stat_type;
    resen    : in  std_ulogic := '0'
  );
  end component;

  component ahbtrace_mb is
  generic (
    hindex   : integer := 0;
    ioaddr   : integer := 16#000#;
    iomask   : integer := 16#E00#;
    tech     : integer := DEFMEMTECH;
    irq      : integer := 0;
    kbytes   : integer := 1;
    bwidth   : integer := 32;
    ahbfilt  : integer := 0;
    scantest : integer range 0 to 1 := 0;
    exttimer : integer range 0 to 1 := 0;
    exten    : integer range 0 to 1 := 0);
  port (
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    ahbsi    : in  ahb_slv_in_type;       -- Register interface
    ahbso    : out ahb_slv_out_type;
    tahbmi   : in  ahb_mst_in_type;       -- Trace
    tahbsi   : in  ahb_slv_in_type;
    timer    : in  std_logic_vector(30 downto 0) := (others => '0');
    astat    : out amba_stat_type;
    resen    : in  std_ulogic := '0'
  );
  end component;

  component ahbtrace_mmb is
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
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    ahbsi    : in  ahb_slv_in_type;       -- Register interface
    ahbso    : out ahb_slv_out_type;
    tahbmiv  : in  ahb_mst_in_vector_type(0 to ntrace-1);       -- Trace
    tahbsiv  : in  ahb_slv_in_vector_type(0 to ntrace-1);
    timer    : in  std_logic_vector(30 downto 0) := (others => '0');
    astat    : out amba_stat_type;
    resen    : in  std_ulogic := '0'
  );
  end component;

  type ahbmst2_request is record
    req: std_logic;        -- Request enable bit
    wr: std_logic;
    hsize: std_logic_vector(2 downto 0);
    hburst: std_logic_vector(2 downto 0);
    hprot: std_logic_vector(3 downto 0);
    addr: std_logic_vector(32-1 downto 0);
    burst_cont: std_logic; -- Set for all except the first request in a burst
    burst_wrap: std_logic; -- High for the request where wrap occurs
  end record;

  constant ahbmst2_request_none: ahbmst2_request := (
    req => '0', wr => '0', hsize => "010", hburst => "000", burst_cont => '0',
    burst_wrap => '0', addr => (others => '0'), hprot => "0011");

  type ahbmst2_in_type is record
    request: ahbmst2_request;
    wrdata: std_logic_vector(AHBDW-1 downto 0);
    -- For back-to-back transfers or bursts, this must be set when done is high
    -- and then copied over to request after the rising edge of clk.
    next_request: ahbmst2_request;
    -- Insert busy cycle, must only be asserted when request and next_request
    -- are both part of the same burst.
    busy: std_logic;
    hlock: std_logic; -- Lock signal, passed through directly to AMBA.
    keepreq: std_logic;  -- Keep bus request high even when no request needs it.
  end record;

  type ahbmst2_out_type is record
    done: std_logic;
    flip: std_logic;
    fail: std_logic;
    rddata: std_logic_vector(AHBDW-1 downto 0);
  end record;

  component ahbmst2 is
    generic (
      hindex: integer := 0;
      venid: integer;
      devid: integer;
      version: integer;
      dmastyle: integer range 1 to 3 := 3;
      syncrst: integer range 0 to 1 := 1
      );
    port (
      clk: in std_logic;
      rst: in std_logic;
      ahbi: in ahb_mst_in_type;
      ahbo: out ahb_mst_out_type;
      m2i: in ahbmst2_in_type;
      m2o: out ahbmst2_out_type
      );
  end component;

  type gpio_in_type is record
    din      : std_logic_vector(31 downto 0);
    sig_in   : std_logic_vector(31 downto 0);
    sig_en   : std_logic_vector(31 downto 0);
  end record;

  type gpio_in_vector is array (natural range <>) of gpio_in_type;

  type gpio_out_type is record
    dout     : std_logic_vector(31 downto 0);
    oen      : std_logic_vector(31 downto 0);
    val      : std_logic_vector(31 downto 0);
    sig_out  : std_logic_vector(31 downto 0);
  end record;

  type gpio_out_vector is array (natural range <>) of gpio_out_type;

 component grgpio
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    imask    : integer := 16#0000#;
    nbits    : integer := 16;			-- GPIO bits
    oepol    : integer := 0;                    -- Output enable polarity
    syncrst  : integer := 0;
    bypass   : integer := 16#0000#;
    scantest : integer := 0;
    bpdir    : integer := 16#0000#;
    pirq     : integer := 0;
    irqgen   : integer := 0;
    iflagreg : integer range 0 to 1:= 0;
    bpmode   : integer range 0 to 1 := 0;
    inpen    : integer range 0 to 1 := 0;
    doutresv : integer := 0;
    dirresv  : integer := 0;
    bpresv   : integer := 0;
    inpresv  : integer := 0;
    pulse    : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    gpioi  : in  gpio_in_type;
    gpioo  : out gpio_out_type
  );
  end component;

  type ahb2ahb_ctrl_type is record
    slck  : std_ulogic;
    blck  : std_ulogic;
    mlck  : std_ulogic;
  end record;

  constant ahb2ahb_ctrl_none : ahb2ahb_ctrl_type := ('0', '0', '0');

  type ahb2ahb_ifctrl_type is record
    mstifen : std_ulogic;
    slvifen : std_ulogic;
  end record;

  constant ahb2ahb_ifctrl_none : ahb2ahb_ifctrl_type := ('1', '1');

  component ahb2ahb
  generic(
    memtech     : integer := 0;
    hsindex     : integer := 0;
    hmindex     : integer := 0;
    slv         : integer range 0 to 1 := 0;
    dir         : integer range 0 to 1 := 0;   -- 0 - down, 1 - up
    ffact       : integer range 0 to 15:= 2;
    pfen        : integer range 0 to 1 := 0;
    wburst      : integer range 2 to 32 := 8;
    iburst      : integer range 4 to 8 :=  8;
    rburst      : integer range 2 to 32 := 8;
    irqsync     : integer range 0 to 3 := 0;
    bar0        : integer range 0 to 1073741823 := 0;
    bar1        : integer range 0 to 1073741823 := 0;
    bar2        : integer range 0 to 1073741823 := 0;
    bar3        : integer range 0 to 1073741823 := 0;
    sbus        : integer := 0;
    mbus        : integer := 0;
    ioarea      : integer := 0;
    ibrsten     : integer := 0;
    lckdac      : integer range 0 to 2 := 0;
    slvmaccsz   : integer range 32 to 256 := 32;
    mstmaccsz   : integer range 32 to 256 := 32;
    rdcomb      : integer range 0 to 2 := 0;
    wrcomb      : integer range 0 to 2 := 0;
    combmask    : integer := 16#ffff#;
    allbrst     : integer range 0 to 2 := 0;
    ifctrlen    : integer range 0 to 1 := 0;
    fcfs        : integer range 0 to NAHBMST := 0;
    fcfsmtech   : integer range 0 to NTECH := inferred;
    scantest    : integer range 0 to 1 := 0;
    split       : integer range 0 to 1 := 1;
    pipe        : integer range 0 to 128 := 0);
  port (
    rstn        : in  std_ulogic;
    hclkm       : in  std_ulogic;
    hclks       : in  std_ulogic;
    ahbsi       : in  ahb_slv_in_type;
    ahbso       : out ahb_slv_out_type;
    ahbmi       : in  ahb_mst_in_type;
    ahbmo       : out ahb_mst_out_type;
    ahbso2      : in  ahb_slv_out_vector;
    lcki        : in  ahb2ahb_ctrl_type;
    lcko        : out ahb2ahb_ctrl_type;
    ifctrl      : in  ahb2ahb_ifctrl_type := ahb2ahb_ifctrl_none
    );
  end component;

  component ahbbridge
  generic(
    memtech     : integer := 0;
    ffact       : integer range 0 to 15 := 2;
    -- high-speed bus
    hsb_hsindex : integer := 0;
    hsb_hmindex : integer := 0;
    hsb_iclsize : integer range 4 to 8 := 8;
    hsb_bank0   : integer range 0 to 1073741823 := 0;
    hsb_bank1   : integer range 0 to 1073741823 := 0;
    hsb_bank2   : integer range 0 to 1073741823 := 0;
    hsb_bank3   : integer range 0 to 1073741823 := 0;
    hsb_ioarea  : integer := 0;
    -- low-speed bus
    lsb_hsindex : integer := 0;
    lsb_hmindex : integer := 0;
    lsb_rburst  : integer range 16 to 32 := 16;
    lsb_wburst  : integer range 2 to 32 :=  8;
    lsb_bank0   : integer range 0 to 1073741823 := 0;
    lsb_bank1   : integer range 0 to 1073741823 := 0;
    lsb_bank2   : integer range 0 to 1073741823 := 0;
    lsb_bank3   : integer range 0 to 1073741823 := 0;
    lsb_ioarea  : integer := 0;
    --
    lckdac      : integer range 0 to 2 := 2;
    maccsz      : integer range 32 to 256 := 32;
    rdcomb      : integer range 0 to 2 := 0;
    wrcomb      : integer range 0 to 2 := 0;
    combmask    : integer := 16#ffff#;
    allbrst     : integer range 0 to 2 := 0;
    fcfs        : integer range 0 to NAHBMST := 0;
    scantest    : integer range 0 to 1 := 0);
  port (
    rstn        : in  std_ulogic;
    hsb_clk     : in  std_ulogic;
    lsb_clk     : in  std_ulogic;
    hsb_ahbsi   : in  ahb_slv_in_type;
    hsb_ahbso   : out ahb_slv_out_type;
    hsb_ahbsov  : in  ahb_slv_out_vector;
    hsb_ahbmi   : in  ahb_mst_in_type;
    hsb_ahbmo   : out ahb_mst_out_type;
    lsb_ahbsi   : in  ahb_slv_in_type;
    lsb_ahbso   : out ahb_slv_out_type;
    lsb_ahbsov  : in  ahb_slv_out_vector;
    lsb_ahbmi   : in  ahb_mst_in_type;
    lsb_ahbmo   : out ahb_mst_out_type);
  end component;

  function ahb2ahb_membar(memaddr : ahb_addr_type; prefetch, cache : std_ulogic;
                          addrmask : ahb_addr_type)
  return integer;

  function ahb2ahb_iobar(memaddr : ahb_addr_type; addrmask : ahb_addr_type)
  return integer;

  type ahbstat_in_type is record
    cerror : std_logic_vector(0 to NAHBSLV-1);
  end record;

  constant ahbstat_in_none : ahbstat_in_type :=
    (cerror => zero32(NAHBSLV-1 downto 0));

  component ahbstat is
    generic(
      pindex : integer := 0;
      paddr  : integer := 0;
      pmask  : integer := 16#FFF#;
      pirq   : integer := 0;
      nftslv : integer range 1 to NAHBSLV - 1 := 3);
    port(
      rst   : in std_ulogic;
      clk   : in std_ulogic;
      ahbmi : in ahb_mst_in_type;
      ahbsi : in ahb_slv_in_type;
      stati : in ahbstat_in_type;
      apbi  : in apb_slv_in_type;
      apbo  : out apb_slv_out_type
    );
  end component;

  type nuhosp3_in_type is record
    flash_d	: std_logic_vector(15 downto 0);
    smsc_data 	: std_logic_vector(31 downto 0);
    smsc_ardy  	: std_ulogic;
    smsc_intr  	: std_ulogic;
    smsc_nldev 	: std_ulogic;
    lcd_data 	: std_logic_vector(7 downto 0);
  end record;

  type nuhosp3_out_type is record
    flash_a 	: std_logic_vector(20 downto 0);
    flash_d	: std_logic_vector(15 downto 0);
    flash_oen  	: std_ulogic;
    flash_wen 	: std_ulogic;
    flash_cen  	: std_ulogic;
    smsc_addr 	: std_logic_vector(14 downto 0);
    smsc_data 	: std_logic_vector(31 downto 0);
    smsc_nbe  	: std_logic_vector(3 downto 0);
    smsc_resetn	: std_ulogic;
    smsc_nrd   	: std_ulogic;
    smsc_nwr   	: std_ulogic;
    smsc_ncs   	: std_ulogic;
    smsc_aen   	: std_ulogic;
    smsc_lclk  	: std_ulogic;
    smsc_wnr   	: std_ulogic;
    smsc_rdyrtn	: std_ulogic;
    smsc_cycle 	: std_ulogic;
    smsc_nads  	: std_ulogic;
    smsc_ben   	: std_ulogic;
    lcd_data 	: std_logic_vector(7 downto 0);
    lcd_rs	: std_ulogic;
    lcd_rw	: std_ulogic;
    lcd_en	: std_ulogic;
    lcd_backl	: std_ulogic;
    lcd_ben	: std_ulogic;
  end record;

  component nuhosp3
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    ioaddr : integer := 16#200#;
    iomask : integer := 16#fff#);
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    nui    : in  nuhosp3_in_type;
    nuo    : out nuhosp3_out_type
  );
  end component;

-- On-chip Logic Analyzer

  component logan is

  generic (
    dbits   : integer range 0 to 256 := 32;        -- Number of traced signals
    depth   : integer range 256 to 16384 := 1024;  -- Depth of trace buffer
    trigl   : integer range 1 to 63 := 1;          -- Number of trigger levels
    usereg  : integer range 0 to 1 := 1;           -- Use input register
    usequal : integer range 0 to 1 := 0;
    usediv  : integer range 0 to 1 := 1;
    pindex  : integer := 0;
    paddr   : integer := 0;
    pmask   : integer := 16#F00#;
    memtech : integer := DEFMEMTECH);
  port (
    rstn    : in  std_logic;
    clk     : in  std_logic;
    tclk    : in  std_logic;
    apbi    : in  apb_slv_in_type;                        -- APB in record
    apbo    : out apb_slv_out_type;                       -- APB out record
    signals : in  std_logic_vector(dbits - 1 downto 0));  -- Traced signals

  end component;

  type ps2_in_type is record
    ps2_clk_i      : std_ulogic;
    ps2_data_i     : std_ulogic;
  end record;

  type ps2_out_type is record
    ps2_clk_o      : std_ulogic;
    ps2_clk_oe     : std_ulogic;
    ps2_data_o     : std_ulogic;
    ps2_data_oe    : std_ulogic;
  end record;

  component apbps2
  generic(
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#fff#;
    pirq        : integer := 0;
    fKHz        : integer := 50000;
    fixed       : integer := 0;
    oepol       : integer range 0 to 1 := 0);
  port(
    rst         : in std_ulogic;                -- Global asynchronous reset
    clk         : in std_ulogic;                -- Global clock
    apbi        : in apb_slv_in_type;
    apbo        : out apb_slv_out_type;
    ps2i        : in ps2_in_type;
    ps2o        : out ps2_out_type
    );
  end component;

  type apbvga_out_type is record
    hsync           : std_ulogic;                       -- horizontal sync
    vsync           : std_ulogic;                       -- vertical sync
    comp_sync       : std_ulogic;                       -- composite sync
    blank           : std_ulogic;                       -- blank signal
    video_out_r     : std_logic_vector(7 downto 0);     -- red channel
    video_out_g     : std_logic_vector(7 downto 0);     -- green channel
    video_out_b     : std_logic_vector(7 downto 0);     -- blue channel
    bitdepth        : std_logic_vector(1 downto 0);     -- Bith depth
  end record;

  component apbvga
  generic(
    memtech     : integer := DEFMEMTECH;
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#fff#);
  port(
    rst             : in std_ulogic;                        -- Global asynchronous reset
    clk             : in std_ulogic;                        -- Global clock
    vgaclk          : in std_ulogic;                        -- VGA clock
    apbi            : in apb_slv_in_type;
    apbo            : out apb_slv_out_type;
    vgao            : out apbvga_out_type
    );
  end component;

  component svgactrl
  generic(
    length      : integer := 384;        -- Fifo-length
    part        : integer := 128;        -- Fifo-part lenght
    memtech     : integer := DEFMEMTECH;
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#fff#;
    hindex      : integer := 0;
    hirq        : integer := 0;
    clk0        : integer := 40000;
    clk1        : integer := 20000;
    clk2        : integer := 15385;
    clk3        : integer := 0;
    burstlen    : integer range 2 to 8 := 8;
    ahbaccsz    : integer := 32;
    asyncrst    : integer range 0 to 1 := 0
    );
  port (
    rst       : in std_logic;
    clk       : in std_logic;
    vgaclk    : in std_logic;
    apbi      : in apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    vgao      : out apbvga_out_type;
    ahbi      : in  ahb_mst_in_type;
    ahbo      : out ahb_mst_out_type;
    clk_sel   : out std_logic_vector(1 downto 0);
    arst      : in  std_ulogic := '1'
    );

  end component;

  constant vgao_none : apbvga_out_type :=
	('0', '0', '0', '0', "00000000", "00000000", "00000000", "00");
  constant ps2o_none : ps2_out_type := ('1', '1', '1', '1');

--  component ahbrom
--  generic (
--    hindex  : integer := 0;
--    haddr   : integer := 0;
--    hmask   : integer := 16#fff#;
--    pipe    : integer := 0;
--    tech    : integer := 0;
--    kbytes  : integer := 1);
--  port (
--    rst     : in  std_ulogic;
--    clk     : in  std_ulogic;
--    ahbsi   : in  ahb_slv_in_type;
--    ahbso   : out ahb_slv_out_type
--  );
--  end component;

  component ahbdma
   generic (
     hindex : integer := 0;
     pindex : integer := 0;
     paddr  : integer := 0;
     pmask  : integer := 16#fff#;
     pirq   : integer := 0;
     dbuf   : integer := 0);
   port (
      rst  : in  std_logic;
      clk  : in  std_ulogic;
      apbi : in  apb_slv_in_type;
      apbo : out apb_slv_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type
      );
  end component;

   -----------------------------------------------------------------------------
   -- Interface type declarations for FIFO controller
   -----------------------------------------------------------------------------
   type FIFO_In_Type is record
      Din:                 Std_Logic_Vector(31 downto 0); -- data input
      Pin:                 Std_Logic_Vector( 3 downto 0); -- parity input
      EFn:                 Std_ULogic;                    -- empty flag
      FFn:                 Std_ULogic;                    -- full flag
      HFn:                 Std_ULogic;                    -- half flag
   end record;

   type FIFO_Out_Type is record
      Dout:                Std_Logic_Vector(31 downto 0); -- data output
      Den:                 Std_Logic_Vector(31 downto 0); -- data enable
      Pout:                Std_Logic_Vector( 3 downto 0); -- parity output
      Pen:                 Std_Logic_Vector( 3 downto 0); -- parity enable
      WEn:                 Std_ULogic;                    -- write enable
      REn:                 Std_ULogic;                    -- read enable
   end record;

   -----------------------------------------------------------------------------
   -- Component declaration for GR FIFO Interface
   -----------------------------------------------------------------------------
   component grfifo is
      generic (
         hindex:           Integer := 0;
         pindex:           Integer := 0;
         paddr:            Integer := 0;
         pmask:            Integer := 16#FFF#;
         pirq:             Integer := 1;                 -- index of first irq
         dwidth:           Integer := 16;                -- data width
         ptrwidth:         Integer range 16 to 16 := 16; --  16 to  64k bytes
                                                         -- 128 to 512k bits
         singleirq:        Integer range 0 to 1 := 0;    -- single irq output
         oepol:            Integer := 1);                -- output enable polarity
      port (
         rstn:       in    Std_ULogic;
         clk:        in    Std_ULogic;
         apbi:       in    APB_Slv_In_Type;
         apbo:       out   APB_Slv_Out_Type;
         ahbi:       in    AHB_Mst_In_Type;
         ahbo:       out   AHB_Mst_Out_Type;
         fifoi:      in    FIFO_In_Type;
         fifoo:      out   FIFO_Out_Type);
   end component;

   -----------------------------------------------------------------------------
   -- Interface type declarations for CAN controllers
   -----------------------------------------------------------------------------
   type Analog_In_Type is record
      Ain:                 Std_Logic_Vector(31 downto 0); -- address input
      Din:                 Std_Logic_Vector(31 downto 0); -- data input
      Rdy:                 Std_ULogic;                    -- adc ready input
      Trig:                Std_Logic_Vector( 2 downto 0); -- adc trigger inputs
   end record;

   type Analog_Out_Type is record
      Aout:                Std_Logic_Vector(31 downto 0); -- address output
      Aen:                 Std_Logic_Vector(31 downto 0); -- address enable
      Dout:                Std_Logic_Vector(31 downto 0); -- dac data output
      Den:                 Std_Logic_Vector(31 downto 0); -- dac data enable
      Wr:                  Std_ULogic;                    -- dac write strobe
      CS:                  Std_ULogic;                    -- adc chip select
      RC:                  Std_ULogic;                    -- adc read/convert
   end record;

   -----------------------------------------------------------------------------
   -- Component declaration for GR ADC/DAC Interface
   -----------------------------------------------------------------------------
   component gradcdac is
      generic (
         pindex:           Integer := 0;
         paddr:            Integer := 0;
         pmask:            Integer := 16#FFF#;
         pirq:             Integer := 1;                 -- index of first irq
         awidth:           Integer := 8;                 -- address width
         dwidth:           Integer := 16;                -- data width
         oepol:            Integer := 1);                -- output enable polarity
      port (
         rstn:       in    Std_ULogic;
         clk:        in    Std_ULogic;
         apbi:       in    APB_Slv_In_Type;
         apbo:       out   APB_Slv_Out_Type;
         adi:        in    Analog_In_Type;
         ado:        out   Analog_Out_Type);
   end component;

  -----------------------------------------------------------------------------
  -- AMBA wrapper for System Monitor
  -----------------------------------------------------------------------------
  type grsysmon_in_type is record
     convst       : std_ulogic;
     convstclk    : std_ulogic;
     vauxn        : std_logic_vector(15 downto 0);
     vauxp        : std_logic_vector(15 downto 0);
     vn           : std_ulogic;
     vp           : std_ulogic;
  end record;

  type grsysmon_out_type is record
     alm          : std_logic_vector(2 downto 0);
     ot           : std_ulogic;
     eoc          : std_ulogic;
     eos          : std_ulogic;
     channel      : std_logic_vector(4 downto 0);
  end record;

  constant grsysmon_in_gnd : grsysmon_in_type :=
    ('0', '0', (others => '0'), (others => '0'), '0', '0');

  component grsysmon
  generic (
    -- GRLIB generics
    tech      : integer := DEFFABTECH;
    hindex    : integer := 0;             -- AHB slave index
    hirq      : integer := 0;             -- Interrupt line
    caddr     : integer := 16#000#;       -- Base address for configuration area
    cmask     : integer := 16#fff#;       -- Area mask
    saddr     : integer := 16#001#;       -- Base address for sysmon register area
    smask     : integer := 16#fff#;       -- Area mask
    split     : integer := 0;             -- Enable AMBA SPLIT support
    extconvst : integer := 0;             -- Use external CONVST signal
    wrdalign  : integer := 0;             -- Word align System Monitor registers
    -- Virtex 5 SYSMON generics
    INIT_40 : bit_vector := X"0000";
    INIT_41 : bit_vector := X"0000";
    INIT_42 : bit_vector := X"0800";
    INIT_43 : bit_vector := X"0000";
    INIT_44 : bit_vector := X"0000";
    INIT_45 : bit_vector := X"0000";
    INIT_46 : bit_vector := X"0000";
    INIT_47 : bit_vector := X"0000";
    INIT_48 : bit_vector := X"0000";
    INIT_49 : bit_vector := X"0000";
    INIT_4A : bit_vector := X"0000";
    INIT_4B : bit_vector := X"0000";
    INIT_4C : bit_vector := X"0000";
    INIT_4D : bit_vector := X"0000";
    INIT_4E : bit_vector := X"0000";
    INIT_4F : bit_vector := X"0000";
    INIT_50 : bit_vector := X"0000";
    INIT_51 : bit_vector := X"0000";
    INIT_52 : bit_vector := X"0000";
    INIT_53 : bit_vector := X"0000";
    INIT_54 : bit_vector := X"0000";
    INIT_55 : bit_vector := X"0000";
    INIT_56 : bit_vector := X"0000";
    INIT_57 : bit_vector := X"0000";
    SIM_MONITOR_FILE : string := "sysmon.txt");
  port (
    rstn    : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    sysmoni : in  grsysmon_in_type;
    sysmono : out grsysmon_out_type
    );
  end component;

  -----------------------------------------------------------------------------
  -- AMBA System ACE Interface Controller
  -----------------------------------------------------------------------------
  type gracectrl_in_type is record
     di   : std_logic_vector(15 downto 0);
--     brdy : std_ulogic;
     irq  : std_ulogic;
  end record;

  type gracectrl_out_type is record
     addr : std_logic_vector(6 downto 0);
     do   : std_logic_vector(15 downto 0);
     cen  : std_ulogic;
     wen  : std_ulogic;
     oen  : std_ulogic;
     doen : std_ulogic;                 -- Data output enable to pad
  end record;

  constant gracectrl_none : gracectrl_out_type :=
    ((others => '1'), (others => '1'), '1', '1', '1', '1');

  component gracectrl
  generic (
    hindex  : integer := 0;              -- AHB slave index
    hirq    : integer := 0;              -- Interrupt line
    haddr   : integer := 16#000#;        -- Base address
    hmask   : integer := 16#fff#;        -- Area mask
    split   : integer range 0 to 1 := 0; -- Enable AMBA SPLIT support
    swap    : integer range 0 to 1 := 0;
    oepol   : integer range 0 to 1 := 0; -- Output enable polarity
    mode    : integer range 0 to 2 := 0  -- 16/8-bit mode
    );
  port (
    rstn    : in  std_ulogic;
    clk     : in  std_ulogic;
    clkace  : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    acei    : in  gracectrl_in_type;
    aceo    : out gracectrl_out_type
    );
  end component;

  -----------------------------------------------------------------------------
  -- General purpose register
  -----------------------------------------------------------------------------
  component grgpreg is
    generic (
        pindex   : integer := 0;
        paddr    : integer := 0;
        pmask    : integer := 16#fff#;
        nbits    : integer range 1 to 64 := 16;
        rstval   : integer := 0;
        rstval2  : integer := 0;
        extrst   : integer := 0
        );
    port (
        rst    : in  std_ulogic;
        clk    : in  std_ulogic;
        apbi   : in  apb_slv_in_type;
        apbo   : out apb_slv_out_type;
        gprego : out std_logic_vector(nbits-1 downto 0);
        resval : in std_logic_vector(nbits-1 downto 0) := (others => '0')
        );
  end component;

  component grgprbank is
    generic (
      pindex: integer := 0;
      paddr : integer := 0;
      pmask : integer := 16#fff#;
      regbits: integer range 1 to 32 := 32;
      nregs : integer  range 1 to 32 := 1;
      rstval: integer := 0;
      extrst: integer := 0;
      rdataen: integer := 0;
      wproten: integer := 0;
      partrstmsk: integer := 0
      );
    port (
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      rego    : out std_logic_vector(nregs*regbits-1 downto 0);
      resval : in std_logic_vector(nregs*regbits-1 downto 0) := (others => '0');
      rdata   : in std_logic_vector(nregs*regbits-1 downto 0) := (others => '0');
      wprot   : in std_logic_vector(nregs-1 downto 0) := (others => '0');
      partrst : in std_ulogic := '1'
      );
  end component;

  -----------------------------------------------------------------------------
  -- EDAC Memory scrubber
  -----------------------------------------------------------------------------

  type memscrub_in_type is record
    cerror  : std_logic_vector(0 to NAHBSLV-1);
    clrcount: std_logic;
    start   : std_logic;
  end record;

  component memscrub is
    generic(
      hmindex : integer := 0;
      hsindex : integer := 0;
      ioaddr  : integer := 0;
      iomask  : integer := 16#FFF#;
      hirq    : integer := 0;
      nftslv  : integer range 1 to NAHBSLV - 1 := 3;
      memwidth: integer := AHBDW;
      -- Read block (cache line) burst size, must be even mult of 2
      burstlen: integer := 2;
      countlen: integer := 8
      );
    port(
      rst   : in std_ulogic;
      clk   : in std_ulogic;
      ahbmi : in ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
      ahbsi : in ahb_slv_in_type;
      ahbso : out ahb_slv_out_type;
      scrubi: in memscrub_in_type
      );
  end component;

  type ahb_mst_iface_in_type is record
    req     : std_ulogic;
    write   : std_ulogic;
    addr    : std_logic_vector(31 downto 0);
    data    : std_logic_vector(31 downto 0);
    size    : std_logic_vector(1 downto 0);
  end record;

  type ahb_mst_iface_out_type is record
    grant   : std_ulogic;
    ready   : std_ulogic;
    error   : std_ulogic;
    retry   : std_ulogic;
    data    : std_logic_vector(31 downto 0);
  end record;

  component ahb_mst_iface is
    generic(
      hindex      : integer;
      vendor      : integer;
      device      : integer;
      revision    : integer);
    port(
      rst         : in  std_ulogic;
      clk         : in  std_ulogic;
      ahbmi       : in  ahb_mst_in_type;
      ahbmo       : out ahb_mst_out_type;
      msti        : in  ahb_mst_iface_in_type;
      msto        : out ahb_mst_iface_out_type
    );
  end component;

  -----------------------------------------------------------------------------
  -- Clock gate unit
  -----------------------------------------------------------------------------
  component grclkgate
    generic (
      tech     : integer := 0;
      pindex   : integer := 0;
      paddr    : integer := 0;
      pmask    : integer := 16#fff#;
      ncpu     : integer := 1;
      nclks    : integer := 8;
      emask    : integer := 0;
      extemask : integer := 0;
      scantest : integer := 0;
      edges    : integer := 0;
      noinv    : integer := 0; -- Do not use inverted clock on gate enable
      fpush    : integer range 0 to 2 := 0;
      ungateen : integer := 0);
    port (
      rst    : in  std_ulogic;
      clkin  : in  std_ulogic;
      pwd    : in  std_logic_vector(ncpu-1 downto 0);
      fpen   : in  std_logic_vector(ncpu-1 downto 0);  -- Only used with shared FPU
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      gclk   : out std_logic_vector(nclks-1 downto 0);
      reset  : out std_logic_vector(nclks-1 downto 0);
      clkahb : out std_ulogic;
      clkcpu : out std_logic_vector(ncpu-1 downto 0);
      enable : out std_logic_vector(nclks-1 downto 0);
      clkfpu : out std_logic_vector((fpush/2)*(ncpu/2-1) downto 0); -- Only used with shared FPU
      epwen  : in  std_logic_vector(nclks-1 downto 0);
      ungate : in  std_ulogic);
  end component;

  component grclkgate2x
    generic (
      tech     : integer := 0;
      pindex   : integer := 0;
      paddr    : integer := 0;
      pmask    : integer := 16#fff#;
      ncpu     : integer := 1;
      nclks    : integer := 8;
      emask    : integer := 0;
      extemask : integer := 0;
      scantest : integer := 0;
      edges    : integer := 0;
      noinv    : integer := 0; -- Do not use inverted clock on gate enable
      fpush    : integer range 0 to 2 := 0;
      clk2xen  : integer := 0;  -- Enable double clocking
      ungateen : integer := 0;
      fpuclken : integer := 0;
      nahbclk  : integer := 1;
      nahbclk2x: integer := 1;
      balance  : integer range 0 to 1 := 1
      );
    port (
      rst      : in  std_ulogic;
      clkin    : in  std_ulogic;
      clkin2x  : in std_ulogic;
      pwd      : in  std_logic_vector(ncpu-1 downto 0);
      fpen     : in  std_logic_vector(ncpu-1 downto 0);
      apbi     : in  apb_slv_in_type;
      apbo     : out apb_slv_out_type;
      gclk     : out std_logic_vector(nclks-1 downto 0);
      reset    : out std_logic_vector(nclks-1 downto 0);
      clkahb   : out std_logic_vector(nahbclk-1 downto 0);
      clkahb2x : out std_logic_vector(nahbclk2x-1 downto 0);
      clkcpu   : out std_logic_vector(ncpu-1 downto 0);
      enable   : out std_logic_vector(nclks-1 downto 0);
      clkfpu   : out std_logic_vector((fpush/2+fpuclken)*(ncpu/(2-fpuclken)-1) downto 0);
      epwen    : in  std_logic_vector(nclks-1 downto 0);
      ungate   : in  std_ulogic
      );
  end component;

  component grclkgatex
    generic (
      tech     : integer := 0;
      pindex   : integer := 0;
      paddr    : integer := 0;
      pmask    : integer := 16#fff#;
      ncpu     : integer := 1;
      nclks    : integer := 8;
      emask    : integer := 0;
      extemask : integer := 0;
      scantest : integer := 0;
      edges    : integer := 0;
      noinv    : integer := 0; -- Do not use inverted clock on gate enable
      fpush    : integer range 0 to 2 := 0;
      clk2xen  : integer := 0;  -- Enable double clocking
      ungateen : integer := 0;
      fpuclken : integer := 0;
      nahbclk  : integer := 1;
      nahbclk2x: integer := 1;
      balance  : integer range 0 to 1 := 1
      );
    port (
      rst      : in  std_ulogic;
      clkin    : in  std_ulogic;
      clkin2x  : in std_ulogic;
      pwd      : in  std_logic_vector(ncpu-1 downto 0);
      fpen     : in  std_logic_vector(ncpu-1 downto 0);
      apbi     : in  apb_slv_in_type;
      apbo     : out apb_slv_out_type;
      gclk     : out std_logic_vector(nclks-1 downto 0);
      reset    : out std_logic_vector(nclks-1 downto 0);
      clkahb   : out std_logic_vector(nahbclk-1 downto 0);
      clkahb2x : out std_logic_vector(nahbclk2x-1 downto 0);
      clkcpu   : out std_logic_vector(ncpu-1 downto 0);
      enable   : out std_logic_vector(nclks-1 downto 0);
      clkfpu   : out std_logic_vector((fpush/2+fpuclken)*(ncpu/(2-fpuclken)-1) downto 0);
      epwen    : in  std_logic_vector(nclks-1 downto 0);
      ungate   : in  std_ulogic
      );
  end component;

  component ahbwbax is
    generic (
      ahbbits: integer;
      blocksz: integer := 16;
      mstmode: integer := 0
      );
    port (
      clk: in std_ulogic;
      rst: in std_ulogic;
      -- Wide-side slave inputs
      wi_hready:    in  std_ulogic;
      wi_hsel:      in  std_ulogic;
      wi_htrans:    in  std_logic_vector(1 downto 0);
      wi_hsize:     in  std_logic_vector(2 downto 0);
      wi_hburst:    in  std_logic_vector(2 downto 0);
      wi_hwrite:    in  std_ulogic;
      wi_haddr:     in  std_logic_vector(31 downto 0);
      wi_hwdata:    in  std_logic_vector(AHBDW-1 downto 0);
      wi_hmbsel:    in  std_logic_vector(0 to NAHBAMR-1);
      wi_hmaster:   in  std_logic_vector(3 downto 0);
      wi_hprot:     in  std_logic_vector(3 downto 0);
      wi_hmastlock: in  std_ulogic;
      -- Wide-side slave outputs
      wo_hready:    out std_ulogic;
      wo_hresp :    out std_logic_vector(1 downto 0);
      wo_hrdata:    out std_logic_vector(AHBDW-1 downto 0);
      -- Narrow-side slave inputs
      ni_hready:    out std_ulogic;
      ni_htrans:    out std_logic_vector(1 downto 0);
      ni_hsize:     out std_logic_vector(2 downto 0);
      ni_hburst:    out std_logic_vector(2 downto 0);
      ni_hwrite:    out std_ulogic;
      ni_haddr:     out std_logic_vector(31 downto 0);
      ni_hwdata:    out std_logic_vector(31 downto 0);
      ni_hmbsel:    out std_logic_vector(0 to NAHBAMR-1);
      ni_hmaster:   out std_logic_vector(3 downto 0);
      ni_hprot :    out std_logic_vector(3 downto 0);
      ni_hmastlock: out std_ulogic;
      -- Narrow-side slave outputs
      no_hready:    in  std_ulogic;
      no_hresp:     in  std_logic_vector(1 downto 0);
      no_hrdata:    in  std_logic_vector(31 downto 0)
      );
  end component;

  component ahbswba is
    generic (
      hindex: integer;
      ahbbits: integer;
      blocksz: integer := 16
      );
    port (
      clk: in std_ulogic;
      rst: in std_ulogic;
      ahbsi_bus: in ahb_slv_in_type;
      ahbso_bus: out ahb_slv_out_type;
      ahbsi_slv: out ahb_slv_in_type;
      ahbso_slv: in ahb_slv_out_type
      );
  end component;

  component ahbswbav is
    generic (
      slvmask: integer;
      ahbbits: integer;
      blocksz: integer
      );
    port (
      clk: in std_ulogic;
      rst: in std_ulogic;
      ahbsi_bus: in ahb_slv_in_type;
      ahbso_bus: out ahb_slv_out_vector;
      ahbsi_slv: out ahb_slv_in_vector_type(NAHBSLV-1 downto 0);
      ahbso_slv: in ahb_slv_out_vector
      );
  end component;

  component ahbmwba is
    generic (
      hindex: integer;
      ahbbits: integer;
      blocksz: integer := 16
      );
    port (
      clk: in std_ulogic;
      rst: in std_ulogic;
      ahbmo_mst : in ahb_mst_out_type;
      ahbmi_mst: out ahb_mst_in_type;
      ahbmo_bus: out ahb_mst_out_type;
      ahbmi_bus: in ahb_mst_in_type
      );
  end component;

  component ahbpl is
    generic (
      ahbbits: integer;
      blocksz: integer := 16;
      prefmask: integer := 16#ffff#;
      wrretry: integer range 0 to 2 := 2
      );
    port (
      clk: in std_ulogic;
      rst: in std_ulogic;
      -- Bus-side slave inputs
      bi_hready:    in  std_ulogic;
      bi_hsel:      in  std_ulogic;
      bi_htrans:    in  std_logic_vector(1 downto 0);
      bi_hsize:     in  std_logic_vector(2 downto 0);
      bi_hburst:    in  std_logic_vector(2 downto 0);
      bi_hwrite:    in  std_ulogic;
      bi_haddr:     in  std_logic_vector(31 downto 0);
      bi_hwdata:    in  std_logic_vector(ahbbits-1 downto 0);
      bi_hmbsel:    in  std_logic_vector(0 to NAHBAMR-1);
      bi_hmaster:   in  std_logic_vector(3 downto 0);
      bi_hprot:     in  std_logic_vector(3 downto 0);
      bi_hmastlock: in std_ulogic;
      -- Bus-side slave outputs
      bo_hready:    out std_ulogic;
      bo_hresp :    out std_logic_vector(1 downto 0);
      bo_hrdata:    out std_logic_vector(ahbbits-1 downto 0);
      -- Slave-side slave inputs
      si_hready:    out std_ulogic;
      si_htrans:    out std_logic_vector(1 downto 0);
      si_hsize:     out std_logic_vector(2 downto 0);
      si_hburst:    out std_logic_vector(2 downto 0);
      si_hwrite:    out std_ulogic;
      si_haddr:     out std_logic_vector(31 downto 0);
      si_hwdata:    out std_logic_vector(ahbbits-1 downto 0);
      si_hmbsel:    out std_logic_vector(0 to NAHBAMR-1);
      si_hmaster:   out std_logic_vector(3 downto 0);
      si_hprot :    out std_logic_vector(3 downto 0);
      si_hmastlock: out std_ulogic;
      -- Slave-side slave outputs
      so_hready:    in  std_ulogic;
      so_hresp:     in  std_logic_vector(1 downto 0);
      so_hrdata:    in  std_logic_vector(ahbbits-1 downto 0);
      -- For use in master mode
      mi_hgrant:    in  std_ulogic;
      mo_hbusreq:   out std_ulogic
      );
  end component;

  component ahbpls is
    generic (
      hindex: integer;
      ahbbits: integer;
      blocksz: integer := 16;
      prefmask: integer := 16#ffff#
      );
    port (
      clk: in std_ulogic;
      rst: in std_ulogic;
      bi: in ahb_slv_in_type;
      bo: out ahb_slv_out_type;
      si: out ahb_slv_in_type;
      so: in ahb_slv_out_type
      );
  end component;

  component ahbplm is
    generic (
      hindex: integer;
      ahbbits: integer;
      blocksz: integer := 16;
      prefmask: integer := 16#ffff#
      );
    port (
      clk: in std_ulogic;
      rst: in std_ulogic;
      mi: out ahb_mst_in_type;
      mo: in ahb_mst_out_type;
      bi: in ahb_mst_in_type;
      bo: out ahb_mst_out_type
      );
  end component;

  -----------------------------------------------------------------------------
  -- GRPULSE
  -----------------------------------------------------------------------------
  component grpulse
    generic (
      pindex:           Integer :=  0;
      paddr:            Integer :=  0;
      pmask:            Integer := 16#fff#;
      pirq:             Integer :=  1;                -- Interrupt index
      nchannel:         Integer := 24;                -- Number of channels
      npulse:           Integer :=  8;                -- Channels with pulses
      imask:            Integer := 16#ff0000#;        -- Interrupt mask
      ioffset:          Integer :=  8;                -- Interrupt offset
      invertpulse:      Integer :=  0;                -- Invert pulses
      cntrwidth:        Integer := 10;                -- Width of counter
      syncrst:          Integer :=  1;                -- Only synchronous reset
      oepol:            Integer :=  1);               -- Output enable polarity
    port (
      rstn:       in    Std_ULogic;
      clk:        in    Std_ULogic;
      apbi:       in    apb_slv_in_type;
      apbo:       out   apb_slv_out_type;
      gpioi:      in    gpio_in_type;
      gpioo:      out   gpio_out_type);
  end component;

  -----------------------------------------------------------------------------
  -- GRTIMER
  -----------------------------------------------------------------------------
  component grtimer is
    generic (
      pindex:           Integer := 0;
      paddr:            Integer := 0;
      pmask:            Integer := 16#fff#;
      pirq:             Integer := 1;
      sepirq:           Integer := 1;                 -- separate interrupts
      sbits:            Integer := 10;                -- scaler bits
      ntimers:          Integer range 1 to 7 := 2;    -- number of timers
      nbits:            Integer := 32;                -- timer bits
      wdog:             Integer := 0;
      glatch:           Integer := 0;
      gextclk:          Integer := 0;
      gset:             Integer := 0);
    port (
      rst:        in    Std_ULogic;
      clk:        in    Std_ULogic;
      apbi:       in    apb_slv_in_type;
      apbo:       out   apb_slv_out_type;
      gpti:       in    gptimer_in_type;
      gpto:       out   gptimer_out_type);
  end component;

  -----------------------------------------------------------------------------
  -- GRVERSION
  -----------------------------------------------------------------------------
  component grversion
    generic (
      pindex:           Integer :=  0;
      paddr:            Integer :=  0;
      pmask:            Integer := 16#fff#;
      versionnr:        Integer := 16#0123#;
      revisionnr:       Integer := 16#4567#);
    port (
      rstn:       in    Std_ULogic;
      clk:        in    Std_ULogic;
      apbi:       in    APB_Slv_In_Type;
      apbo:       out   APB_Slv_Out_Type);
  end component;


   -----------------------------------------------------------------------------
   -- AHBFROM - Microsemi/Actel Flash ROM
   -----------------------------------------------------------------------------
   component ahbfrom is
   generic (
      tech:          integer := 0;
      hindex:        integer := 0;
      haddr:         integer := 0;
      hmask:         integer := 16#fff#;
      width8:        integer  := 0;
      memoryfile:    string := "from.mem";
      progfile:      string := "from.ufc");
   port (
      rstn:    in    std_ulogic;
      clk:     in    std_ulogic;
      ahbi:    in    ahb_slv_in_type;
      ahbo:    out   ahb_slv_out_type);
   end component;

  -----------------------------------------------------------------------------
  -- Interrupt generator
  -----------------------------------------------------------------------------
  component irqgen
    generic (
      pindex   : integer := 0;
      paddr    : integer := 0;
      pmask    : integer := 16#fff#;
      ngen     : integer range 1 to 15 := 1
      );
    port (
      rstn   : in  std_ulogic;
      clk    : in  std_ulogic;
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type
      );
  end component;
  
  -----------------------------------------------------------------------------
  -- Function declarations
  -----------------------------------------------------------------------------

--  function nandtree(v : std_logic_vector) return std_ulogic;

end;


package body misc is

  function gpti_dhalt_drive (dhalt : std_ulogic) return gptimer_in_type is
    variable gpti : gptimer_in_type;
  begin
    gpti := (dhalt, '0', '0', zxirq, zxirq);
    return gpti;
  end;

  
  function ahb2ahb_membar(memaddr : ahb_addr_type; prefetch, cache : std_ulogic;
                          addrmask : ahb_addr_type)
  return integer is
    variable tmp : std_logic_vector(29 downto 0);
    variable bar : std_logic_vector(31 downto 0);
    variable res : integer range 0 to 1073741823;
  begin
    bar := ahb_membar(memaddr, prefetch, cache, addrmask);
    tmp := (others => '0');
    tmp(29 downto 18) := bar(31 downto 20);
    tmp(17 downto 0) := bar(17 downto 0);
    res := conv_integer(tmp);
    return(res);
  end;

  function ahb2ahb_iobar(memaddr : ahb_addr_type; addrmask : ahb_addr_type)
  return integer is
    variable tmp : std_logic_vector(29 downto 0);
    variable bar : std_logic_vector(31 downto 0);
    variable res : integer range 0 to 1073741823;
  begin
    bar := ahb_iobar(memaddr, addrmask);
    tmp := (others => '0');
    tmp(29 downto 18) := bar(31 downto 20);
    tmp(17 downto 0) := bar(17 downto 0);
    res := conv_integer(tmp);
    return(res);
  end;

--  function nandtree(v : std_logic_vector) return std_ulogic is
--  variable a : std_logic_vector(v'length-1 downto 0);
--  variable b : std_logic_vector(v'length downto 0);
--  begin
--
--    a := v; b(0) := '1';
--
--    for i in 0 to v'length-1 loop
--      b(i+1) := a(i) nand b(i);
--    end loop;
--
--    return b(v'length);
--
--  end;


end;

