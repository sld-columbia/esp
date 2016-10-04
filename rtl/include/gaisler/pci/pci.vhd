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
-- Entity:      pci
-- File:        pci.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Package with component and type declarations for PCI cores
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;

package pci is

type pci_in_type is record
  rst 	   	: std_ulogic;
  gnt 	   	: std_ulogic;
  idsel 	: std_ulogic;
  ad 	   	: std_logic_vector(31 downto 0);
  cbe 	   	: std_logic_vector(3 downto 0);
  frame		: std_ulogic;
  irdy    	: std_ulogic;
  trdy    	: std_ulogic;
  devsel  	: std_ulogic;
  stop    	: std_ulogic;
  lock    	: std_ulogic;
  perr    	: std_ulogic;
  serr    	: std_ulogic;
  par 	   	: std_ulogic;
  host   	: std_ulogic;
  pci66		: std_ulogic;
  pme_status	: std_ulogic;
  int           : std_logic_vector(3 downto 0);         -- D downto A
end record;

constant pci_in_none : pci_in_type := (
  rst         => '0',
  gnt         => '0',
  idsel       => '0',
  ad          => (others => '0'),
  cbe         => (others => '0'),
  frame       => '0',
  irdy        => '0',
  trdy        => '0',
  devsel      => '0',
  stop        => '0',
  lock        => '0',
  perr        => '0',
  serr        => '0',
  par         => '0',
  host        => '0',
  pci66       => '0',
  pme_status  => '0',
  int         => (others => '0'));

type pci_out_type is record
  aden		: std_ulogic;
  vaden         : std_logic_vector(31 downto 0);
  cbeen    	: std_logic_vector(3 downto 0);
  frameen   	: std_ulogic;
  irdyen    	: std_ulogic;
  trdyen    	: std_ulogic;
  devselen	: std_ulogic;
  stopen   	: std_ulogic;
  ctrlen    	: std_ulogic;
  perren    	: std_ulogic;
  paren 	: std_ulogic;
  reqen		: std_ulogic;
  locken    	: std_ulogic;
  serren    	: std_ulogic;
  inten     	: std_logic;
  vinten     	: std_logic_vector(3 downto 0);
  req    	: std_ulogic;
  ad 	   	: std_logic_vector(31 downto 0);
  cbe 	   	: std_logic_vector(3 downto 0);
  frame  	: std_ulogic;
  irdy   	: std_ulogic;
  trdy   	: std_ulogic;
  devsel 	: std_ulogic;
  stop   	: std_ulogic;
  perr   	: std_ulogic;
  serr   	: std_ulogic;
  par 	   	: std_ulogic;
  lock   	: std_ulogic;
  power_state	: std_logic_vector(1 downto 0);
  pme_enable	: std_ulogic;
  pme_clear	: std_ulogic;
  int		: std_logic;
  rst           : std_ulogic;
end record;

constant pci_out_none : pci_out_type := (
  aden => '1', vaden => (others => '1'), cbeen => (others => '1'),
  frameen => '1', irdyen => '1', trdyen => '1', devselen => '1',
  stopen => '1', ctrlen => '1', perren => '1', paren => '1', reqen => '1',
  locken => '1', serren => '1', inten => '1', vinten => (others => '1'), req => '1', ad => (others => '0'),
  cbe => (others => '1'), frame => '1', irdy => '1', trdy => '1', devsel => '1',
  stop => '1', perr => '1', serr => '1', par => '1', lock => '1',
  power_state => (others => '1'), pme_enable => '1',pme_clear => '1',
  int => '1', rst => '1');

  component pci_target
  generic (
    hindex    : integer := 0;
    abits     : integer := 21;
    device_id : integer := 0;		-- PCI device ID
    vendor_id : integer := 0;	        -- PCI vendor ID
    nsync : integer range 1 to 2 := 1;	-- 1 or 2 sync regs between clocks
    oepol     : integer := 0
  ); 
   port( 
      rst       : in std_ulogic;   
      clk       : in std_ulogic;   
      pciclk    : in std_ulogic;   
      pcii	: in  pci_in_type;
      pcio	: out pci_out_type;
      ahbmi 	: in  ahb_mst_in_type;
      ahbmo 	: out ahb_mst_out_type
  );
  end component;

  component pci_mt 
  generic (
    hmstndx   : integer := 0;
    abits     : integer := 21;
    device_id : integer := 0;		-- PCI device ID
    vendor_id : integer := 0;	        -- PCI vendor ID
    master    : integer := 1; 		-- Enable PCI Master
    hslvndx   : integer := 0;
    haddr     : integer := 16#F00#;
    hmask     : integer := 16#F00#;
    ioaddr    : integer := 16#000#;
    nsync : integer range 1 to 2 := 1;	-- 1 or 2 sync regs between clocks
    oepol     : integer := 0 
  );
   port(
      rst       : in std_logic;
      clk       : in std_logic;
      pciclk    : in std_logic;
      pcii	: in  pci_in_type;
      pcio	: out pci_out_type;
      ahbmi 	: in  ahb_mst_in_type;
      ahbmo 	: out ahb_mst_out_type;
      ahbsi 	: in  ahb_slv_in_type;
      ahbso 	: out ahb_slv_out_type
  );
  end component;

  component dmactrl
  generic (
    hindex    : integer := 0;
    slvindex  : integer := 0;
    pindex    : integer := 0;
    paddr     : integer := 0;
    pmask     : integer := 16#fff#;
    pirq      : integer := 0;
    blength   : integer := 4);
  port (
    rst       : in std_logic;
    clk       : in std_logic;
    apbi      : in apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    ahbmi     : in ahb_mst_in_type;
    ahbmo     : out ahb_mst_out_type;
    ahbsi0    : in ahb_slv_in_type;
    ahbso0    : out ahb_slv_out_type;
    ahbsi1    : out ahb_slv_in_type;
    ahbso1    : in ahb_slv_out_type);
  end component;

  component pci_mtf
  generic (
    memtech   : integer := DEFMEMTECH;
    hmstndx   : integer := 0;
    dmamst    : integer := NAHBMST;
    readpref  : integer := 0;
    abits     : integer := 21;
    dmaabits  : integer := 26;
    fifodepth : integer := 3; -- FIFO depth
    device_id : integer := 0; -- PCI device ID
    vendor_id : integer := 0; -- PCI vendor ID
    master    : integer := 1; -- Enable PCI Master
    hslvndx   : integer := 0;
    pindex    : integer := 0;
    paddr     : integer := 0;
    pmask     : integer := 16#fff#;
    haddr     : integer := 16#F00#;
    hmask     : integer := 16#F00#;
    ioaddr    : integer := 16#000#;
    irq       : integer := 0;
    irqmask   : integer := 0;
    nsync     : integer range 1 to 2 := 2;	-- 1 or 2 sync regs between clocks
    oepol     : integer := 0;
    endian    : integer := 0;
    class_code: integer := 16#0B4000#;
    rev       : integer := 0;
    scanen    : integer := 0;
    syncrst   : integer := 0;
    hostrst   : integer := 0);
   port(
      rst       : in std_logic;
      clk       : in std_logic;
      pciclk    : in std_logic;
      pcii      : in  pci_in_type;
      pcio      : out pci_out_type;
      apbi      : in apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type;
      ahbsi     : in  ahb_slv_in_type;
      ahbso     : out ahb_slv_out_type
);
end component;

component pcitrace
  generic (
    depth     : integer range 6 to 12 := 8;
    iregs     : integer := 1;
    memtech   : integer := DEFMEMTECH;
    pindex    : integer := 0;
    paddr     : integer := 0;
    pmask     : integer := 16#f00#
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    pciclk : in  std_ulogic;
    pcii   : in  pci_in_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type
  );
end component;

component pcipads 
  generic (
    padtech      : integer := 0;
    noreset      : integer := 0;
    oepol        : integer := 0;
    host         : integer := 1;
    int          : integer := 0;
    no66         : integer := 0;
    onchipreqgnt : integer := 0;
    drivereset   : integer := 0;
    constidsel   : integer := 0;
    level        : integer := pci33;
    voltage      : integer := x33v;
    nolock       : integer := 0
  );
  port (
    pci_rst     : inout std_logic;
    pci_gnt     : in std_ulogic;
    pci_idsel   : in std_ulogic;
    pci_lock    : inout std_ulogic;
    pci_ad 	: inout std_logic_vector(31 downto 0);
    pci_cbe 	: inout std_logic_vector(3 downto 0);
    pci_frame   : inout std_logic;
    pci_irdy 	: inout std_logic;
    pci_trdy 	: inout std_logic;
    pci_devsel  : inout std_logic;
    pci_stop 	: inout std_logic;
    pci_perr 	: inout std_logic;
    pci_par 	: inout std_logic;    
    pci_req 	: inout std_logic;  -- tristate pad but never read
    pci_serr    : inout std_logic;  -- open drain output
    pci_host   	: in std_ulogic;
    pci_66	: in std_ulogic;
    pcii   	: out pci_in_type;
    pcio   	: in  pci_out_type;
    pci_int     : inout std_logic_vector(3 downto 0)
  );
end component;

component pcidma
  generic (
    memtech   : integer := DEFMEMTECH;
    dmstndx   : integer := 0;
    dapbndx   : integer := 0;
    dapbaddr  : integer := 0;
    dapbmask  : integer := 16#fff#;
    dapbirq   : integer := 0;
    blength   : integer := 16;
    mstndx    : integer := 0;
    abits     : integer := 21;
    dmaabits  : integer := 26;
    fifodepth : integer := 3; -- FIFO depth
    device_id : integer := 0; -- PCI device ID
    vendor_id : integer := 0; -- PCI vendor ID
    slvndx    : integer := 0;
    apbndx    : integer := 0;
    apbaddr   : integer := 0;
    apbmask   : integer := 16#fff#;
    haddr     : integer := 16#F00#;
    hmask     : integer := 16#F00#;
    ioaddr    : integer := 16#000#;
    nsync     : integer range 1 to 2 := 2;	-- 1 or 2 sync regs between clocks
    oepol     : integer := 0;
    endian    : integer := 0;   -- 0 little, 1 big
    class_code: integer := 16#0B4000#;
    rev       : integer := 0;
    irq       : integer := 0;
    irqmask   : integer := 0;
    scanen    : integer := 0;
    hostrst   : integer := 0;
    syncrst   : integer := 0);
   port(
      rst       : in std_logic;
      clk       : in std_logic;
      pciclk    : in std_logic;
      pcii      : in  pci_in_type;
      pcio      : out pci_out_type;
      dapbo     : out apb_slv_out_type;
      dahbmo    : out ahb_mst_out_type;
      apbi      : in apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type;
      ahbsi     : in  ahb_slv_in_type;
      ahbso     : out ahb_slv_out_type
);
end component;

  type pci_ahb_dma_in_type is record
    address         : std_logic_vector(31 downto 0);
    wdata           : std_logic_vector(31 downto 0);
    start           : std_ulogic;
    burst           : std_ulogic;
    write           : std_ulogic;
    busy            : std_ulogic;
    irq             : std_ulogic;
    size            : std_logic_vector(1 downto 0);
  end record;

  type pci_ahb_dma_out_type is record
    start           : std_ulogic;
    active          : std_ulogic;
    ready           : std_ulogic;
    retry           : std_ulogic;
    mexc            : std_ulogic;
    haddr           : std_logic_vector(9 downto 0);
    rdata           : std_logic_vector(31 downto 0);
  end record;

  component pciahbmst
  generic (
    hindex  : integer := 0;
    hirq    : integer := 0;
    venid   : integer := VENDOR_GAISLER;
    devid   : integer := 0;
    version : integer := 0;
    chprot  : integer := 3;
    incaddr : integer := 0);
   port (
      rst  : in  std_ulogic;
      clk  : in  std_ulogic;
      dmai : in  pci_ahb_dma_in_type;
      dmao : out pci_ahb_dma_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type
      );
  end component;

  component pcif 
  generic (
    device_id   : integer := 0; -- PCI device ID
    vendor_id   : integer := 0; -- PCI vendor ID
    class       : integer := 0;
    revision_id : integer := 0;
    aaddr_width : integer := 28;
    maddr_width : integer := 28;
    pcibars     : integer := 1;
    ahbmasters  : integer := 8;
    fifo_depth  : integer := 3;
    ft          : integer := 0;

    memtech   : integer := 0;
    hmstndx   : integer := 0;
    hslvndx   : integer := 0;
    pindex    : integer := 0;
    paddr     : integer := 0;
    pmask     : integer := 16#fff#;
    haddr     : integer := 16#F00#;
    hmask     : integer := 16#F00#);
  port(
      rst       : in std_logic;
      pciclk    : in std_logic;
      pcii      : in  pci_in_type;
      pcio      : out pci_out_type;
      apbi      : in  apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type;
      ahbsi     : in  ahb_slv_in_type;
      ahbso     : out ahb_slv_out_type);
      --debug     : out std_logic_vector(233 downto 0));
  end component;

  component pcif_async 
  generic (
    device_id   : integer := 0;  -- PCI device ID
    vendor_id   : integer := 0;  -- PCI vendor ID
    class       : integer := 0; 
    revision_id : integer := 0; 
    bar1        : integer := 20;
    bar2        : integer := 24;
    bar3        : integer := 0;
    bar4        : integer := 0;
    ahbmasters  : integer := 28;
    fifo_depth  : integer := 1; 
    ft          : integer := 0; 
    nsync       : integer := 2;
    irqctrl     : integer := 0;
    host        : integer := 0;

    memtech   : integer := 0;       
    hmstndx   : integer := 0;       
    hslvndx   : integer := 0;       
    pindex    : integer := 0;       
    paddr     : integer := 0;       
    pmask     : integer := 16#fff#; 
    haddr     : integer := 16#F00#; 
    hmask     : integer := 16#F00#;
    ioaddr    : integer := 16#000#;
    pirq      : integer := 0;
    netlist   : integer := 0;
    debugen   : integer := 0;
    hostrst   : integer := 0
  );
   port(
      rst       : in std_logic;
      clk       : in std_logic;
      pcirst    : in std_logic;
      pciclk    : in std_logic;
      pcii      : in  pci_in_type;
      pcio      : out pci_out_type;
      apbi      : in  apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type;
      ahbsi     : in  ahb_slv_in_type;
      ahbso     : out ahb_slv_out_type--;
      --debug     : out std_logic_vector(255 downto 0)
   );
end component;


component grpci2
  generic (
    memtech     : integer := DEFMEMTECH;
    tbmemtech   : integer := DEFMEMTECH;
    oepol       : integer := 0;
    hmindex     : integer := 0;
    hdmindex    : integer := 0;
    hsindex     : integer := 0;
    haddr       : integer := 0;
    hmask       : integer := 0;
    ioaddr      : integer := 0;
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#FFF#;
    irq         : integer := 0;
    irqmode     : integer range 0 to 3 := 0;
    master      : integer range 0 to 1 := 1;
    target      : integer range 0 to 1 := 1;
    dma         : integer range 0 to 1 := 1;
    tracebuffer : integer range 0 to 16384 := 0;
    confspace   : integer range 0 to 1 := 1;
    vendorid    : integer := 16#0000#;
    deviceid    : integer := 16#0000#;
    classcode   : integer := 16#000000#;
    revisionid  : integer := 16#00#;
    cap_pointer : integer := 16#40#;
    ext_cap_pointer : integer := 16#00#;
    iobase      : integer := 16#FFF#;
    extcfg      : integer := 16#0000000#;
    bar0        : integer range 0 to 31 := 28;
    bar1        : integer range 0 to 31 := 0;
    bar2        : integer range 0 to 31 := 0;
    bar3        : integer range 0 to 31 := 0;
    bar4        : integer range 0 to 31 := 0;
    bar5        : integer range 0 to 31 := 0;
    bar0_map    : integer := 16#000000#;
    bar1_map    : integer := 16#000000#;
    bar2_map    : integer := 16#000000#;
    bar3_map    : integer := 16#000000#;
    bar4_map    : integer := 16#000000#;
    bar5_map    : integer := 16#000000#;
    bartype     : integer range 0 to 65535 := 16#0000#;
    barminsize  : integer range 5 to 31 := 12;
    fifo_depth  : integer range 3 to 7 := 3;
    fifo_count  : integer range 2 to 4 := 2; 
    conv_endian : integer range 0 to 1 := 0; -- 1: little (PCI) <~> big (AHB), 0: big (PCI) <=> big (AHB)   
    deviceirq   : integer range 0 to 1 := 1;
    deviceirqmask : integer range 0 to 15 := 16#0#;
    hostirq     : integer range 0 to 1 := 1;
    hostirqmask : integer range 0 to 15 := 16#0#;
    nsync       : integer range 0 to 2 := 2; 
    hostrst     : integer range 0 to 2 := 0;-- 0: PCI reset is never driven, 1: PCI reset is driven from AHB reset if host, 2: PCI reset is always driven from AHB reset
    bypass      : integer range 0 to 1 := 1;
    ft          : integer range 0 to 1 := 0;
    scantest    : integer range 0 to 1 := 0;
    debug       : integer range 0 to 1 := 0;
    tbapben     : integer range 0 to 1 := 0;
    tbpindex    : integer := 0;
    tbpaddr     : integer := 0;
    tbpmask     : integer := 16#F00#;
    netlist     : integer range 0 to 1 := 0;
    multifunc   : integer range 0 to 1 := 0; -- Enables Multi-function support
    multiint    : integer range 0 to 1 := 0;
    masters     : integer := 16#FFFF#;
    mf1_deviceid        : integer := 16#0000#;
    mf1_classcode       : integer := 16#000000#;
    mf1_revisionid      : integer := 16#00#;
    mf1_bar0            : integer range 0 to 31 := 0;
    mf1_bar1            : integer range 0 to 31 := 0;
    mf1_bar2            : integer range 0 to 31 := 0;
    mf1_bar3            : integer range 0 to 31 := 0;
    mf1_bar4            : integer range 0 to 31 := 0;
    mf1_bar5            : integer range 0 to 31 := 0;
    mf1_bartype         : integer range 0 to 65535 := 16#0000#;
    mf1_bar0_map        : integer := 16#000000#;
    mf1_bar1_map        : integer := 16#000000#;
    mf1_bar2_map        : integer := 16#000000#;
    mf1_bar3_map        : integer := 16#000000#;
    mf1_bar4_map        : integer := 16#000000#;
    mf1_bar5_map        : integer := 16#000000#;
    mf1_cap_pointer     : integer := 16#40#;
    mf1_ext_cap_pointer : integer := 16#00#;
    mf1_extcfg          : integer := 16#0000000#;
    mf1_masters         : integer := 16#0000#;
    iotest              : integer := 0);
   port(
      rst       : in std_logic;
      clk       : in std_logic;
      pciclk    : in std_logic;
      dirq      : in  std_logic_vector(3 downto 0);
      pcii      : in  pci_in_type;
      pcio      : out pci_out_type;
      apbi      : in apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      ahbsi     : in  ahb_slv_in_type;
      ahbso     : out ahb_slv_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type;
      ahbdmi    : in  ahb_mst_in_type;
      ahbdmo    : out ahb_mst_out_type;
      ptarst    : out std_logic;
      tbapbi    : in apb_slv_in_type := apb_slv_in_none;
      tbapbo    : out apb_slv_out_type;
      debugo    : out std_logic_vector(debug*255 downto 0)
);
end component;

  constant PCI_VENDOR_ESA      : integer := 16#16E3#;
  constant PCI_VENDOR_GAISLER  : integer := 16#1AC8#;
  constant PCI_VENDOR_AEROFLEX : integer := 16#1AD0#;

end;

