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
-- Entity:  grpci2_gen
-- File:    grpci2_gen.vhd
-- Author:  Nils-Johan Wessman - Aeroflex Gaisler
-- Description: Std_logic wrapper for GRPCI2
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba.all;
--use work.stdlib.all;
--use work.devices.all;
use work.gencomp.all;
use work.pci.all;

entity grpci2_gen is
  generic (
    memtech     : integer := DEFMEMTECH;
    tbmemtech   : integer := DEFMEMTECH;  -- For trace buffers
    oepol       : integer := 0;
    hmask       : integer := 0;           -- Need to set according to the size of the decoded AHB address range
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
    conv_endian : integer range 0 to 1 := 1; -- 1: little (PCI) <~> big (AHB), 0: big (PCI) <=> big (AHB)   
    deviceirq   : integer range 0 to 1 := 1;
    deviceirqmask : integer range 0 to 15 := 16#0#;
    hostirq     : integer range 0 to 1 := 1;
    hostirqmask : integer range 0 to 15 := 16#0#;
    nsync       : integer range 0 to 2 := 2; -- with nsync = 0, wrfst needed on syncram...
    hostrst     : integer range 0 to 2 := 0;-- 0: PCI reset is never driven, 1: PCI reset is driven from AHB reset if host, 2: PCI reset is always driven from AHB reset
    bypass      : integer range 0 to 1 := 1;
    ft          : integer range 0 to 1 := 0;
    scantest    : integer range 0 to 1 := 0;
    debug       : integer range 0 to 1 := 0;
    tbapben     : integer range 0 to 1 := 0;
    netlist     : integer range 0 to 1 := 0;  -- Use PHY netlist
    
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
    mf1_masters         : integer := 16#0000#
  ); 
  port(
      rst       : in std_logic;                           -- AMBA reset
      clk       : in std_logic;                           -- AMBA clock
      pciclk    : in std_logic;                           -- PCI clock
      --
      dirq      : in  std_logic_vector(3 downto 0);       -- From interrupt controller to PCI interrupt
      --
      pci_rst_i     : in std_logic;                       -- PCI reset in 
      pci_rst_o     : out std_logic;                      -- PCI reset out
      pci_gnt       : in std_logic;                       -- PCI grant
      pci_req_o     : out std_logic;                      -- PCI request out
      pci_req_oe    : out std_logic;                      -- PCI request output enable
      pci_idsel     : in std_logic;                       -- PCI IDSEL
      pci_ad_i      : in std_logic_vector(31 downto 0);   -- PCI AD in 
      pci_ad_o      : out std_logic_vector(31 downto 0);  -- PCI AD out
      pci_ad_oe     : out std_logic_vector(31 downto 0);  -- PCI AD output enable
      pci_cbe_i     : in std_logic_vector(3 downto 0);    -- PCI CBE in
      pci_cbe_o     : out std_logic_vector(3 downto 0);   -- PCI CBE out
      pci_cbe_oe    : out std_logic_vector(3 downto 0);   -- PCI CBE output enable
      pci_frame_i   : in std_logic;                       -- PCI FRAME in
      pci_frame_o   : out std_logic;                      -- PCI FRAME out
      pci_frame_oe  : out std_logic;                      -- PCI FRAME output enable
      pci_irdy_i    : in std_logic;                       -- PCI IRDY in
      pci_irdy_o    : out std_logic;                      -- PCI IRDY out
      pci_irdy_oe   : out std_logic;                      -- PCI IRDY output enable
      pci_trdy_i    : in std_logic;                       -- PCI TRDY in
      pci_trdy_o    : out std_logic;                      -- PCI TRDY out
      pci_trdy_oe   : out std_logic;                      -- PCI TRDY output enable
      pci_stop_i    : in std_logic;                       -- PCI STOP in
      pci_stop_o    : out std_logic;                      -- PCI STOP out
      pci_stop_oe   : out std_logic;                      -- PCI STOP output enable
      pci_devsel_i  : in std_logic;                       -- PCI DEVSEL in
      pci_devsel_o  : out std_logic;                      -- PCI DEVSEL out
      pci_devsel_oe : out std_logic;                      -- PCI DEVSEL output enable
      pci_perr_i    : in std_logic;                       -- PCI PERR in
      pci_perr_o    : out std_logic;                      -- PCI PERR out
      pci_perr_oe   : out std_logic;                      -- PCI PERR output enable
      pci_serr_i    : in std_logic;                       -- PCI SERR in
      pci_serr_o    : out std_logic;                      -- PCI SERR out
      pci_serr_oe   : out std_logic;                      -- PCI SERR output enable
      pci_par_i     : in std_logic;                       -- PCI PAR in
      pci_par_o     : out std_logic;                      -- PCI PAR out
      pci_par_oe    : out std_logic;                      -- PCI PAR output enable
      pci_int_i     : in std_logic_vector(3 downto 0);    -- PCI INT[D..A] in
      pci_int_oe    : out std_logic_vector(3 downto 0);   -- PCI INT[D..A] output enable
      pci_host      : in std_logic;                       -- GRPCI2 specific, determine host/peripheral mode
      pci_pci66     : in std_logic;                       -- PCI M66EN
      --
      apb_psel      : in  std_logic;                          -- slave select
      apb_penable   : in  std_ulogic;                         -- strobe
      apb_paddr     : in  std_logic_vector(31 downto 0);      -- address bus (byte)
      apb_pwrite    : in  std_ulogic;                         -- write
      apb_pwdata    : in  std_logic_vector(31 downto 0);      -- write data bus
      apb_prdata    : out std_logic_vector(31 downto 0);      -- read data bus
      --
      apb_pirq      : out std_logic_vector(4 downto 0);       -- interrupt bus (GRLIB specific)
      --
      ahbsi_hsel    : in  std_logic;                          -- slave select
      ahbsi_haddr   : in  std_logic_vector(31 downto 0);      -- address bus (byte)
      ahbsi_hwrite  : in  std_ulogic;                         -- read/write
      ahbsi_htrans  : in  std_logic_vector(1 downto 0);       -- transfer type
      ahbsi_hsize   : in  std_logic_vector(2 downto 0);       -- transfer size
      ahbsi_hburst  : in  std_logic_vector(2 downto 0);       -- burst type
      ahbsi_hwdata  : in  std_logic_vector(AHBDW-1 downto 0); -- write data bus
      ahbsi_hprot   : in  std_logic_vector(3 downto 0);       -- protection control
      ahbsi_hready  : in  std_ulogic;                         -- transfer done
      ahbsi_hmaster : in  std_logic_vector(3 downto 0);       -- current master
      ahbsi_hmastlock : in  std_ulogic;                       -- locked access
      --
      ahbsi_hmbsel  : in  std_logic_vector(0 to NAHBAMR-1);   -- memory bank select (GRLIB specific, need to be
                                                          -- decoded for the two address ranges the PCI core 
                                                          -- occupies in the AHB address range.
      --                                                                                              
      ahbso_hready  : out std_ulogic;                         -- transfer done
      ahbso_hresp   : out std_logic_vector(1 downto 0);       -- response type
      ahbso_hrdata  : out std_logic_vector(AHBDW-1 downto 0); -- read data bus
      ahbso_hsplit  : out std_logic_vector(NAHBMST-1 downto 0);      -- split completion
      --
      testen        : in  std_ulogic;                         -- scan test enable
      testrst       : in  std_ulogic;                         -- scan test reset
      scanen        : in  std_ulogic;                         -- scan enable
      testoen       : in  std_ulogic;                         -- test output enable 
      testin        : in  std_logic_vector(NTESTINBITS-1 downto 0); -- test vector for syncrams
      --
      ahbmi_hgrant  : in  std_logic;                          -- bus grant
      ahbmi_hready  : in  std_ulogic;                         -- transfer done
      ahbmi_hresp   : in  std_logic_vector(1 downto 0);       -- response type
      ahbmi_hrdata  : in  std_logic_vector(AHBDW-1 downto 0); -- read data bus
      --
      ahbmo_hbusreq : out std_ulogic;                         -- bus request
      ahbmo_hlock   : out std_ulogic;                         -- lock request
      ahbmo_htrans  : out std_logic_vector(1 downto 0);       -- transfer type
      ahbmo_haddr   : out std_logic_vector(31 downto 0);      -- address bus (byte)
      ahbmo_hwrite  : out std_ulogic;                         -- read/write
      ahbmo_hsize   : out std_logic_vector(2 downto 0);       -- transfer size
      ahbmo_hburst  : out std_logic_vector(2 downto 0);       -- burst type
      ahbmo_hprot   : out std_logic_vector(3 downto 0);       -- protection control
      ahbmo_hwdata  : out std_logic_vector(AHBDW-1 downto 0); -- write data bus
      --
      ahbdmo_hbusreq  : out std_ulogic;                       -- bus request
      ahbdmo_hlock    : out std_ulogic;                       -- lock request
      ahbdmo_htrans   : out std_logic_vector(1 downto 0);     -- transfer type
      ahbdmo_haddr    : out std_logic_vector(31 downto 0);    -- address bus (byte)
      ahbdmo_hwrite   : out std_ulogic;                       -- read/write
      ahbdmo_hsize    : out std_logic_vector(2 downto 0);     -- transfer size
      ahbdmo_hburst   : out std_logic_vector(2 downto 0);     -- burst type
      ahbdmo_hprot    : out std_logic_vector(3 downto 0);     -- protection control
      ahbdmo_hwdata   : out std_logic_vector(AHBDW-1 downto 0); -- write data bus
      --
      ptarst        : out std_logic;                      -- PCI reset to connect to AMBA reset
      --
      tbapb_psel    : in  std_logic;                          -- slave select
      tbapb_penable : in  std_ulogic;                         -- strobe
      tbapb_paddr   : in  std_logic_vector(31 downto 0);      -- address bus (byte)
      tbapb_pwrite  : in  std_ulogic;                         -- write
      tbapb_pwdata  : in  std_logic_vector(31 downto 0);      -- write data bus
      tbapb_prdata  : out std_logic_vector(31 downto 0);      -- read data bus
      --
      debugo        : out std_logic_vector(debug*255 downto 0)  -- DEBUG output 
);
end;

architecture rtl of grpci2_gen is
  signal pcii      : pci_in_type;
  signal pcio      : pci_out_type;
  signal apbi      : apb_slv_in_type;
  signal apbo      : apb_slv_out_type;
  signal ahbsi     : ahb_slv_in_type;
  signal ahbso     : ahb_slv_out_type;
  signal ahbmi     : ahb_mst_in_type;
  signal ahbmo     : ahb_mst_out_type;
  signal ahbdmo    : ahb_mst_out_type;
  signal tbapbi    : apb_slv_in_type;
  signal tbapbo    : apb_slv_out_type;

begin

  pcii.rst        <= pci_rst_i;
  pcii.gnt        <= pci_gnt;
  pcii.idsel      <= pci_idsel;
  pcii.ad         <= pci_ad_i;
  pcii.cbe       <= pci_cbe_i;
  pcii.frame      <= pci_frame_i;
  pcii.irdy       <= pci_irdy_i;
  pcii.trdy       <= pci_trdy_i;
  pcii.devsel     <= pci_devsel_i;
  pcii.stop       <= pci_stop_i;
  pcii.lock       <= '0';
  pcii.perr       <= pci_perr_i;
  pcii.serr       <= pci_serr_i;
  pcii.par        <= pci_par_i;
  pcii.host       <= pci_host;
  pcii.pci66      <= pci_pci66;
  pcii.pme_status <= '0';
  pcii.int        <= pci_int_i;

  pci_ad_oe     <= pcio.vaden;
  --pci_vad_oe    <= pcio.vaden;
  pci_cbe_oe    <= pcio.cbeen;
  pci_frame_oe  <= pcio.frameen;
  pci_irdy_oe   <= pcio.irdyen;
  pci_trdy_oe   <= pcio.trdyen;
  pci_devsel_oe <= pcio.devselen;
  pci_stop_oe   <= pcio.stopen;
  --pci_ctrl_oe   <= pcio.ctrlen;
  pci_perr_oe   <= pcio.perren;
  pci_par_oe    <= pcio.paren;
  pci_req_oe    <= pcio.reqen;
  --pci_lock_oe   <= pcio.locken;
  pci_serr_oe   <= pcio.serren;
  --pci_int_oe    <= pcio.inten;
  pci_int_oe    <= pcio.vinten;
  pci_req_o     <= pcio.req;
  pci_ad_o      <= pcio.ad;
  pci_cbe_o     <= pcio.cbe;
  pci_frame_o   <= pcio.frame;
  pci_irdy_o    <= pcio.irdy;
  pci_trdy_o    <= pcio.trdy;
  pci_devsel_o  <= pcio.devsel;
  pci_stop_o    <= pcio.stop;
  pci_perr_o    <= pcio.perr;
  pci_serr_o    <= pcio.serr;
  pci_par_o     <= pcio.par;
  --pci_lock_o    <= pcio.lock;
  --pci_power_state <= pcio.power_state;
  --pci_pme_enable  <= pcio.pme_enable;
  --pci_pme_clear   <= pcio.pme_clear;
  --pci_int_o     <= pcio.int;
  pci_rst_o     <= pcio.rst;
    
  apbi.psel(0)  <= apb_psel;
  apbi.penable  <= apb_penable;
  apbi.paddr    <= apb_paddr;
  apbi.pwrite   <= apb_pwrite;
  apbi.pwdata   <= apb_pwdata;
  apb_prdata    <= apbo.prdata;
  --
  apb_pirq      <= apbo.pirq(4 downto 0);
  --
  apbi.pirq      <= (others => '0');
  apbi.testen    <= '0';
  apbi.testrst   <= '0';
  apbi.scanen    <= '0';
  apbi.testoen   <= '0';
  apbi.testin    <= (others => '0');

  tbapbi.psel(0)  <= tbapb_psel;
  tbapbi.penable  <= tbapb_penable;
  tbapbi.paddr    <= tbapb_paddr;
  tbapbi.pwrite   <= tbapb_pwrite;
  tbapbi.pwdata   <= tbapb_pwdata;
  tbapb_prdata    <= tbapbo.prdata;
  --
  tbapbi.pirq      <= (others => '0');
  tbapbi.testen    <= '0';
  tbapbi.testrst   <= '0';
  tbapbi.scanen    <= '0';
  tbapbi.testoen   <= '0';
  tbapbi.testin    <= (others => '0');

  ahbmi.hgrant(0) <= ahbmi_hgrant;
  ahbmi.hready    <= ahbmi_hready;
  ahbmi.hresp     <= ahbmi_hresp;
  ahbmi.hrdata    <= ahbmi_hrdata;
  --
  ahbmi.hirq      <= (others => '0');
  ahbmi.testen    <= '0';
  ahbmi.testrst   <= '0';
  ahbmi.scanen    <= '0';
  ahbmi.testoen   <= '0';
  ahbmi.testin    <= (others => '0');

  ahbmo_hbusreq   <= ahbmo.hbusreq;
  ahbmo_hlock     <= ahbmo.hlock;
  ahbmo_htrans    <= ahbmo.htrans;
  ahbmo_haddr     <= ahbmo.haddr;
  ahbmo_hwrite    <= ahbmo.hwrite;
  ahbmo_hsize     <= ahbmo.hsize;
  ahbmo_hburst    <= ahbmo.hburst;
  ahbmo_hprot     <= ahbmo.hprot;
  ahbmo_hwdata    <= ahbmo.hwdata;

  ahbdmo_hbusreq  <= ahbdmo.hbusreq;
  ahbdmo_hlock    <= ahbdmo.hlock;
  ahbdmo_htrans   <= ahbdmo.htrans;
  ahbdmo_haddr    <= ahbdmo.haddr;
  ahbdmo_hwrite   <= ahbdmo.hwrite;
  ahbdmo_hsize    <= ahbdmo.hsize;
  ahbdmo_hburst   <= ahbdmo.hburst;
  ahbdmo_hprot    <= ahbdmo.hprot;
  ahbdmo_hwdata   <= ahbdmo.hwdata;

  ahbsi.hsel(0)   <= ahbsi_hsel;
  ahbsi.haddr     <= ahbsi_haddr;
  ahbsi.hwrite    <= ahbsi_hwrite;
  ahbsi.htrans    <= ahbsi_htrans;
  ahbsi.hsize     <= ahbsi_hsize;
  ahbsi.hburst    <= ahbsi_hburst;
  ahbsi.hwdata    <= ahbsi_hwdata;
  ahbsi.hprot     <= ahbsi_hprot;
  ahbsi.hready    <= ahbsi_hready;
  ahbsi.hmaster   <= ahbsi_hmaster;
  ahbsi.hmastlock <= ahbsi_hmastlock;
  --
  ahbsi.hmbsel    <= ahbsi_hmbsel;
  --
  ahbsi.hirq      <= (others => '0');
  
  ahbsi.testen    <= testen;
  ahbsi.testrst   <= testrst;
  ahbsi.scanen    <= scanen;
  ahbsi.testoen   <= testoen;
  ahbsi.testin    <= testin;

  ahbso_hready    <= ahbso.hready;
  ahbso_hresp     <= ahbso.hresp;
  ahbso_hrdata    <= ahbso.hrdata;
  ahbso_hsplit    <= ahbso.hsplit;

  gen : grpci2 
    generic map(
      memtech             => memtech,
      tbmemtech           => tbmemtech,
      oepol               => oepol,
      hmindex             => 0,
      hdmindex            => 0,
      hsindex             => 0,
      haddr               => 0,
      hmask               => hmask,
      ioaddr              => 0,
      pindex              => 0,
      paddr               => 0,
      pmask               => 0,
      irq                 => 0,
      irqmode             => irqmode,
      master              => master,
      target              => target,
      dma                 => dma,
      tracebuffer         => tracebuffer,
      confspace           => confspace,
      vendorid            => vendorid,
      deviceid            => deviceid,
      classcode           => classcode,
      revisionid          => revisionid,
      cap_pointer         => cap_pointer,
      ext_cap_pointer     => ext_cap_pointer,
      iobase              => iobase,
      extcfg              => extcfg,
      bar0                => bar0,
      bar1                => bar1,
      bar2                => bar2,
      bar3                => bar3,
      bar4                => bar4,
      bar5                => bar5,
      bar0_map            => bar0_map,
      bar1_map            => bar1_map,
      bar2_map            => bar2_map,
      bar3_map            => bar3_map,
      bar4_map            => bar4_map,
      bar5_map            => bar5_map,
      bartype             => bartype,
      barminsize          => barminsize,
      fifo_depth          => fifo_depth,
      fifo_count          => fifo_count,
      conv_endian         => conv_endian,
      deviceirq           => deviceirq,
      deviceirqmask       => deviceirqmask,
      hostirq             => hostirq,
      hostirqmask         => hostirqmask,
      nsync               => nsync,
      hostrst             => hostrst,
      bypass              => bypass,
      ft                  => ft,
      scantest            => scantest,
      debug               => debug,
      tbapben             => tbapben,
      tbpindex            => 0,
      tbpaddr             => 0,
      tbpmask             => 0,
      netlist             => netlist,
                             
      multifunc           => multifunc,
      multiint            => multiint,
      masters             => masters,
      mf1_deviceid        => mf1_deviceid,
      mf1_classcode       => mf1_classcode,
      mf1_revisionid      => mf1_revisionid,
      mf1_bar0            => mf1_bar0,
      mf1_bar1            => mf1_bar1,
      mf1_bar2            => mf1_bar2,
      mf1_bar3            => mf1_bar3,
      mf1_bar4            => mf1_bar4,
      mf1_bar5            => mf1_bar5,
      mf1_bartype         => mf1_bartype,
      mf1_bar0_map        => mf1_bar0_map,
      mf1_bar1_map        => mf1_bar1_map,
      mf1_bar2_map        => mf1_bar2_map,
      mf1_bar3_map        => mf1_bar3_map,
      mf1_bar4_map        => mf1_bar4_map,
      mf1_bar5_map        => mf1_bar5_map,
      mf1_cap_pointer     => mf1_cap_pointer,
      mf1_ext_cap_pointer => mf1_ext_cap_pointer,
      mf1_extcfg          => mf1_extcfg,
      mf1_masters         => mf1_masters) 
    port map(
      rst       => rst,
      clk       => clk,
      pciclk    => pciclk,
      dirq      => dirq,
      pcii      => pcii,
      pcio      => pcio,
      apbi      => apbi,
      apbo      => apbo,
      ahbsi     => ahbsi,
      ahbso     => ahbso,
      ahbmi     => ahbmi,
      ahbmo     => ahbmo,
      ahbdmi    => ahbmi,
      ahbdmo    => ahbdmo,
      ptarst    => ptarst,
      tbapbi    => tbapbi,
      tbapbo    => tbapbo,
      debugo    => debugo);
end;

