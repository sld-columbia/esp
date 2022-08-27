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
-- Entity:      net
-- File:        net.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Package with component and type declarations for network cores
------------------------------------------------------------------------------
  
library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.gencomp.all;

package net is

  type eth_in_type is record
    gtx_clk    : std_ulogic;                     
    rmii_clk   : std_ulogic;
    tx_clk     : std_ulogic;
    tx_clk_90  : std_ulogic;
    tx_dv      : std_ulogic;
    rx_clk     : std_ulogic;
    rxd        : std_logic_vector(7 downto 0);   
    rx_dv      : std_ulogic; 
    rx_er      : std_ulogic; 
    rx_col     : std_ulogic;
    rx_crs     : std_ulogic;
    rx_en      : std_ulogic;
    mdio_i     : std_ulogic;
    mdint      : std_ulogic;
    phyrstaddr : std_logic_vector(4 downto 0);
    edcladdr   : std_logic_vector(3 downto 0);
    edclsepahb : std_ulogic;
    edcldisable: std_ulogic;
  end record;

  constant eth_in_none : eth_in_type :=
    ('0', '0', '0', '0', '0', '0', (others => '0'), '0', '0', '0', '0', '0',
     '0', '0', (others => '0'), (others => '0'), '0', '0');
  type eth_in_vector is array (natural range <>) of eth_in_type;
  
  type eth_out_type is record
    reset          : std_ulogic;
    txd            : std_logic_vector(7 downto 0);   
    tx_en          : std_ulogic; 
    tx_er          : std_ulogic;
    tx_clk         : std_ulogic; 
    mdc            : std_ulogic;
    mdio_o         : std_ulogic; 
    mdio_oe        : std_ulogic;
    gbit           : std_ulogic;
    speed          : std_ulogic;
  end record;

  constant eth_out_none : eth_out_type :=
    ('0', (others => '0'), '0', '0', '0', '0', '0', '1', '0', '0');
  type eth_out_vector is array (natural range <>) of eth_out_type;

  type eth_sgmii_in_type is record
    clkp           : std_ulogic;
    clkn           : std_ulogic;
    rxp            : std_ulogic;
    rxn            : std_ulogic;
    mdio_i         : std_ulogic;
    mdint          : std_ulogic;
  end record;

  type eth_sgmii_out_type is record
    reset          : std_ulogic;
    txp            : std_ulogic;
    txn            : std_ulogic;
    mdc            : std_ulogic;
    mdio_o         : std_ulogic;
    mdio_oe        : std_ulogic;
  end record;


  type greth_mdiochain_down_type is record
    first  : std_ulogic;
    tick   : std_ulogic;
    mdio_i : std_ulogic;
  end record;

  type greth_mdiochain_up_type is record
    lock   : std_ulogic;
    mdio_o : std_ulogic;
    mdio_oe: std_ulogic;
  end record;

  constant greth_mdiochain_down_first: greth_mdiochain_down_type :=
    (first => '1', tick => '0', mdio_i => '0');
  constant greth_mdiochain_up_last: greth_mdiochain_up_type :=
    (lock => '0', mdio_o => '0', mdio_oe => '0');

  component eth_arb
    generic(
      fullduplex : integer := 0;
      mdiomaster : integer := 0);
    port(
      rst   : in std_logic;
      clk   : in std_logic; 
      ethi  : in eth_in_type;
      etho  : out eth_out_type;
      methi : in eth_out_type;
      metho : out eth_in_type; 
      dethi : in eth_out_type;
      detho : out eth_in_type
      );
  end component;


  component greth is
    generic(
      hindex         : integer := 0;
      ehindex        : integer := 1;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      memtech        : integer := 0;
      little_end     : integer range 0 to 1 := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      enable_mdio    : integer range 0 to 1 := 0;
      fifosize       : integer range 4 to 512 := 8;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      vcu118         : integer range 0 to 1  := 0;
      rmii           : integer range 0 to 1  := 0; 
      oepol          : integer range 0 to 1  := 0; 
      scanen         : integer range 0 to 1  := 0;
      ft             : integer range 0 to 2  := 0;
      edclsepahbg    : integer range 0 to 1  := 0;
      edclft         : integer range 0 to 2  := 0;
      mdint_pol      : integer range 0 to 1  := 0;
      enable_mdint   : integer range 0 to 1  := 0;
      multicast      : integer range 0 to 1  := 0;
      ramdebug       : integer range 0 to 2  := 0;
      mdiohold       : integer := 1;
      maxsize        : integer := 1500;
      gmiimode       : integer range 0 to 1  := 0
      );
    port(
     rst            : in  std_ulogic;
     clk            : in  std_ulogic;
     mdcscaler      : in  integer range 0 to 2047 := 25; 
     ahbmi          : in  ahb_mst_in_type;
     ahbmo          : out ahb_mst_out_type;
     eahbmo         : out ahb_mst_out_type;
     apbi           : in  apb_slv_in_type;
     apbo           : out apb_slv_out_type;
     ethi           : in  eth_in_type;
     etho           : out eth_out_type
    );
  end component;

  component greth_mb is
    generic(
      hindex         : integer := 0;
      ehindex        : integer := 0;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      memtech        : integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      mdcscaler      : integer range 0 to 2047 := 25; 
      enable_mdio    : integer range 0 to 1 := 0;
      fifosize       : integer range 4 to 512 := 8;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      rmii           : integer range 0 to 1  := 0;
      oepol	     : integer range 0 to 1  := 0; 
      scanen	     : integer range 0 to 1  := 0;
      ft             : integer range 0 to 2  := 0;
      edclft         : integer range 0 to 2  := 0;
      mdint_pol      : integer range 0 to 1  := 0;
      enable_mdint   : integer range 0 to 1  := 0;
      multicast      : integer range 0 to 1  := 0;
      edclsepahb     : integer range 0 to 1  := 0;
      ramdebug       : integer range 0 to 2  := 0;
      mdiohold       : integer := 1;
      maxsize        : integer := 1500;
      gmiimode       : integer range 0 to 1  := 0
      );
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      ahbmi          : in  ahb_mst_in_type;
      ahbmo          : out ahb_mst_out_type;
      ahbmi2         : in  ahb_mst_in_type;
      ahbmo2         : out ahb_mst_out_type;
      apbi           : in  apb_slv_in_type;
      apbo           : out apb_slv_out_type;
      ethi           : in  eth_in_type;
      etho           : out eth_out_type
    );
  end component;

  component greth_gbit_mb is
    generic(
      hindex         : integer := 0;
      ehindex        : integer := 0;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      memtech        : in  integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      burstlength    : integer range 4 to 128 := 32;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      sim            : integer range 0 to 1 := 0;
      oepol          : integer range 0 to 1  := 0; 
      scanen         : integer range 0 to 1  := 0;
      ft             : integer range 0 to 2 := 0;
      edclft         : integer range 0 to 2 := 0;
      mdint_pol      : integer range 0 to 1  := 0;
      enable_mdint   : integer range 0 to 1  := 0;
      multicast      : integer range 0 to 1  := 0;
      edclsepahb     : integer range 0 to 1  := 0;
      ramdebug       : integer range 0 to 2  := 0;
      mdiohold       : integer := 1;
      gmiimode       : integer range 0 to 1  := 0;
      mdiochain      : integer range 0 to 1  := 0;
      iotest         : integer range 0 to 1  := 0
    ); 
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      mdcscaler      : in  integer range 0 to 2047 := 25; 
      ahbmi          : in  ahb_mst_in_type;
      ahbmo          : out ahb_mst_out_type;
      ahbmi2         : in  ahb_mst_in_type;
      ahbmo2         : out ahb_mst_out_type;
      apbi           : in  apb_slv_in_type;
      apbo           : out apb_slv_out_type;
      ethi           : in  eth_in_type;
      etho           : out eth_out_type;
      mdchain_ui     : in  greth_mdiochain_down_type := greth_mdiochain_down_first;
      mdchain_uo     : out greth_mdiochain_up_type;
      mdchain_di     : out greth_mdiochain_down_type;
      mdchain_do     : in  greth_mdiochain_up_type := greth_mdiochain_up_last
    );
  end component;

  component greth_gbit is
    generic(
      hindex         : integer := 0;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      memtech        : integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      burstlength    : integer range 4 to 128 := 32;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      sim            : integer range 0 to 1 := 0;
      oepol          : integer range 0 to 1  := 0; 
      scanen         : integer range 0 to 1  := 0;
      ft             : integer range 0 to 2 := 0;
      edclft         : integer range 0 to 2 := 0;
      mdint_pol      : integer range 0 to 1  := 0;
      enable_mdint   : integer range 0 to 1  := 0;
      multicast      : integer range 0 to 1  := 0;
      ramdebug       : integer range 0 to 2  := 0;
      mdiohold       : integer := 1;
      gmiimode       : integer range 0 to 1  := 0
      ); 
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      mdcscaler      : in  integer range 0 to 2047 := 25; 
      ahbmi          : in  ahb_mst_in_type;
      ahbmo          : out ahb_mst_out_type;
      apbi           : in  apb_slv_in_type;
      apbo           : out apb_slv_out_type;
      ethi           : in  eth_in_type;
      etho           : out eth_out_type
    );
  end component;

  component grethm
  generic(
    hindex         : integer := 0;
    ehindex        : integer := 1;
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#FFF#;
    pirq           : integer := 0;
    memtech        : integer := 0;
    little_end     : integer range 0 to 1 := 0;
    ifg_gap        : integer := 24; 
    attempt_limit  : integer := 16;
    backoff_limit  : integer := 10;
    slot_time      : integer := 128;
    enable_mdio    : integer range 0 to 1 := 0;
    fifosize       : integer range 4 to 64 := 8;
    nsync          : integer range 1 to 2 := 2;
    edcl           : integer range 0 to 3 := 0;
    edclbufsz      : integer range 1 to 64 := 1;
    burstlength    : integer range 4 to 128 := 32;
    macaddrh       : integer := 16#00005E#;
    macaddrl       : integer := 16#000000#;
    ipaddrh        : integer := 16#c0a8#;
    ipaddrl        : integer := 16#0035#;
    phyrstadr      : integer range 0 to 32 := 0;
    vcu118         : integer range 0 to 1  := 0;
    rmii           : integer range 0 to 1 := 0;
    sim            : integer range 0 to 1 := 0;
    giga           : integer range 0 to 1  := 0;
    oepol          : integer range 0 to 1  := 0;
    scanen         : integer range 0 to 1  := 0;
    ft             : integer range 0 to 2  := 0;
    edclsepahbg    : integer range 0 to 1  := 0;
    edclft         : integer range 0 to 1  := 0;
    mdint_pol      : integer range 0 to 1  := 0;
    enable_mdint   : integer range 0 to 1  := 0;
    multicast      : integer range 0 to 1  := 0;
    ramdebug       : integer range 0 to 2  := 0;
    mdiohold       : integer := 1;
    maxsize        : integer := 1500;
    gmiimode       : integer range 0 to 1  := 0
    ); 
  port(
    rst            : in  std_ulogic;
    clk            : in  std_ulogic;
    mdcscaler      : in  integer range 0 to 2047 := 25; 
    ahbmi          : in  ahb_mst_in_type;
    ahbmo          : out ahb_mst_out_type;
    eahbmo         : out ahb_mst_out_type;
    apbi           : in  apb_slv_in_type;
    apbo           : out apb_slv_out_type;
    ethi           : in  eth_in_type;
    etho           : out eth_out_type
  );
  end component;

  component grethm_mb
    generic (
      hindex         : integer := 0;
      ehindex        : integer := 0;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      memtech        : integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      mdcscaler      : integer range 0 to 2047 := 25; 
      enable_mdio    : integer range 0 to 1 := 0;
      fifosize       : integer range 4 to 64 := 8;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      burstlength    : integer range 4 to 128 := 32;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      rmii           : integer range 0 to 1 := 0;
      sim            : integer range 0 to 1 := 0;
      giga           : integer range 0 to 1  := 0;
      oepol          : integer range 0 to 1  := 0;
      scanen         : integer range 0 to 1  := 0;
      ft             : integer range 0 to 2  := 0;
      edclft         : integer range 0 to 1  := 1;
      mdint_pol      : integer range 0 to 1  := 0;
      enable_mdint   : integer range 0 to 1  := 0;
      multicast      : integer range 0 to 1  := 0;
      edclsepahb     : integer range 0 to 1 := 0;
      ramdebug       : integer range 0 to 2  := 0;
      mdiohold       : integer := 1;
      maxsize        : integer := 1500;
      gmiimode       : integer range 0 to 1  := 0
      );
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      ahbmi          : in  ahb_mst_in_type;
      ahbmo          : out ahb_mst_out_type;
      ahbmi2         : in  ahb_mst_in_type;
      ahbmo2         : out ahb_mst_out_type;
      apbi           : in  apb_slv_in_type;
      apbo           : out apb_slv_out_type;
      ethi           : in  eth_in_type;
      etho           : out eth_out_type
    );
  end component;

  component greths is
    generic(
      hindex         : integer := 0;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      fabtech        : integer := 0;
      memtech        : integer := 0;
      transtech      : integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      mdcscaler      : integer range 0 to 2047 := 25; 
      enable_mdio    : integer range 0 to 1 := 0;
      fifosize       : integer range 4 to 64 := 8;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      burstlength    : integer range 4 to 128 := 32;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      rmii           : integer range 0 to 1 := 0;
      sim            : integer range 0 to 1 := 0;
      giga           : integer range 0 to 1  := 0;
      oepol          : integer range 0 to 1  := 0;
      scanen         : integer range 0 to 1  := 0;
      ft             : integer range 0 to 2  := 0;
      edclft         : integer range 0 to 2  := 0;
      mdint_pol      : integer range 0 to 1  := 0;
      enable_mdint   : integer range 0 to 1  := 0;
      multicast      : integer range 0 to 1  := 0;
      ramdebug       : integer range 0 to 2  := 0;
      mdiohold       : integer := 1;
      maxsize        : integer := 1500;
      pcs_phyaddr    : integer range 0 to 32 := 0
      );
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      ahbmi          : in  ahb_mst_in_type;
      ahbmo          : out ahb_mst_out_type;
      apbi           : in  apb_slv_in_type;
      apbo           : out apb_slv_out_type;
      -- High-speed Serial Interface
      clk_125        : in  std_logic;
      rst_125        : in  std_logic;
      eth_rx_p       : in  std_logic;
      eth_rx_n       : in  std_logic := '0';
      eth_tx_p       : out std_logic;
      eth_tx_n       : out std_logic;
      -- MDIO interface
      reset          : out std_logic;
      mdio_o         : out std_logic;
      mdio_oe        : out std_logic;
      mdio_i         : in  std_logic;
      mdc            : out std_logic;
      mdint          : in  std_logic;
      -- Control signals
      phyrstaddr     : in std_logic_vector(4 downto 0);
      edcladdr       : in std_logic_vector(3 downto 0);
      edclsepahb     : in std_logic;
      edcldisable    : in std_logic;
      debug_pcs_mdio : in std_logic := '0';
      -- added for igloo2_serdes
      apbin         : in apb_in_serdes := apb_in_serdes_none;
      apbout        : out apb_out_serdes;
      m2gl_padin    : in pad_in_serdes := pad_in_serdes_none;
      m2gl_padout   : out pad_out_serdes;
      serdes_clk125 : out std_logic;
      rx_aligned    : out std_logic
    );
  end component;

  component greths_mb is
    generic(
      hindex         : integer := 0;
      ehindex        : integer := 0;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      fabtech        : integer := 0;
      memtech        : integer := 0;
      transtech      : integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      mdcscaler      : integer range 0 to 2047 := 25; 
      enable_mdio    : integer range 0 to 1 := 0;
      fifosize       : integer range 4 to 64 := 8;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      burstlength    : integer range 4 to 128 := 32;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      rmii           : integer range 0 to 1 := 0;
      sim            : integer range 0 to 1 := 0;
      giga           : integer range 0 to 1  := 0;
      oepol          : integer range 0 to 1  := 0;
      scanen         : integer range 0 to 1  := 0;
      ft             : integer range 0 to 2  := 0;
      edclft         : integer range 0 to 2  := 0;
      mdint_pol      : integer range 0 to 1  := 0;
      enable_mdint   : integer range 0 to 1  := 0;
      multicast      : integer range 0 to 1  := 0;
      edclsepahbg    : integer range 0 to 1 := 0;
      ramdebug       : integer range 0 to 2  := 0;
      mdiohold       : integer := 1;
      maxsize        : integer := 1500;
      pcs_phyaddr    : integer range 0 to 32 := 0
    );
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      ahbmi          : in  ahb_mst_in_type;
      ahbmo          : out ahb_mst_out_type;
      ahbmi2         : in  ahb_mst_in_type;
      ahbmo2         : out ahb_mst_out_type;
      apbi           : in  apb_slv_in_type;
      apbo           : out apb_slv_out_type;
      -- High-speed Serial Interface
      clk_125        : in  std_logic;
      rst_125        : in  std_logic;
      eth_rx_p       : in  std_logic;
      eth_rx_n       : in  std_logic := '0';
      eth_tx_p       : out std_logic;
      eth_tx_n       : out std_logic;
      -- MDIO interface
      reset          : out std_logic;
      mdio_o         : out std_logic;
      mdio_oe        : out std_logic;
      mdio_i         : in  std_logic;
      mdc            : out std_logic;
      mdint          : in  std_logic;
      -- Control signals
      phyrstaddr     : in std_logic_vector(4 downto 0);
      edcladdr       : in std_logic_vector(3 downto 0);
      edclsepahb     : in std_logic;
      edcldisable    : in std_logic;
      debug_pcs_mdio : in std_logic := '0';
      -- added for igloo2_serdes
      apbin         : in apb_in_serdes := apb_in_serdes_none;
      apbout        : out apb_out_serdes;
      m2gl_padin    : in pad_in_serdes := pad_in_serdes_none;
      m2gl_padout   : out pad_out_serdes;
      serdes_clk125 : out std_logic;
      rx_aligned    : out std_logic
    );
  end component;
  
  component rgmii is
  generic (
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#fff#;
    tech           : integer := 0;
    gmii           : integer := 0;
    debugmem       : integer := 0;
    abits          : integer := 8;
    no_clk_mux     : integer := 0;
    pirq           : integer := 0;
    use90degtxclk  : integer := 0;
    mode100        : integer := 0
    );
  port (
    rstn     : in  std_ulogic;
    gmiii    : out eth_in_type;
    gmiio    : in  eth_out_type;
    rgmiii   : in  eth_in_type;
    rgmiio   : out eth_out_type ;
    -- APB Status bus
    apb_clk  : in  std_logic;
    apb_rstn : in  std_logic;
    apbi     : in  apb_slv_in_type;
    apbo     : out apb_slv_out_type
    );
  end component;
  
  component sgmii is
    generic (
      fabtech   : integer := 0;
      memtech   : integer := 0;
      transtech : integer := 0;
      phy_addr  : integer := 0;
      mode      : integer := 0  -- unused
    );
    port (
      clk_125       : in  std_logic;
      rst_125       : in  std_logic;

      ser_rx_p      : in  std_logic;
      ser_rx_n      : in  std_logic;
      ser_tx_p      : out std_logic;
      ser_tx_n      : out std_logic;

      txd           : in  std_logic_vector(7 downto 0);
      tx_en         : in  std_logic;
      tx_er         : in  std_logic;
      tx_clk        : out std_logic;
      tx_rstn       : out std_logic;

      rxd           : out std_logic_vector(7 downto 0);
      rx_dv         : out std_logic;
      rx_er         : out std_logic;
      rx_col        : out std_logic;
      rx_crs        : out std_logic;
      rx_clk        : out std_logic;
      rx_rstn       : out std_logic;

      -- optional MDIO interface to PCS
      mdc           : in  std_logic;
      mdio_o        : in  std_logic         := '0';
      mdio_oe       : in  std_logic         := '1';
      mdio_i        : out std_logic;

      -- added for igloo2_serdes
      apbin         : in apb_in_serdes := apb_in_serdes_none;
      apbout        : out apb_out_serdes;
      m2gl_padin    : in pad_in_serdes := pad_in_serdes_none;
      m2gl_padout   : out pad_out_serdes;
      serdes_clk125 : out std_logic;
      rx_aligned    : out std_logic
    );
  end component ;

  component comma_detect is
    generic (
      bsbreak : integer range 0 to 31  := 0;   -- number of extra deassertion cycles between bitslip assertions in a sequence
      bswait  : integer range 0 to 127 := 7    -- number of cycles to pause recognition after a sequence is issued
    );
    port (
      clk   : in std_logic;
      rstn   : in std_logic;
      indata  : in std_logic_vector(9 downto 0);
      bitslip : out std_logic
    );
  end component;

  component word_aligner is
    generic(
      comma : std_logic_vector(9 downto 3) := "0011111");
    port(
      clk   : in std_logic;                      -- rx clock
      rstn  : in std_logic;                      -- asynchronous reset
      rx_in : in std_logic_vector(9 downto 0);   -- Data in
      rx_out : out std_logic_vector(9 downto 0)  -- Data out
      );
  end component;

  component elastic_buffer is
    generic (
      tech    : integer := 0;
      abits   : integer := 7
    );
    port (
      wr_clk  : in  std_logic;
      wr_rst  : in  std_logic;
      wr_data : in  std_logic_vector(9 downto 0);
      rd_clk  : in  std_logic;
      rd_rst  : in  std_logic;
      rd_data : out std_logic_vector(9 downto 0)
    ) ;
  end component ;

  component gmii_to_mii is
    port (
      tx_rstn : in std_logic;
      rx_rstn : in std_logic;
      -- MAC SIDE
      gmiii : out eth_in_type;
      gmiio : in  eth_out_type;
      -- PHY SIDE
      miii  : in  eth_in_type;
      miio  : out eth_out_type
    ) ;
  end component ;
end;

