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
-- Entity:      greths
-- File:        greths.vhd
-- Authors:     Andrea Gianarro
-- Description: Gigabit Ethernet Media Access Controller with Ethernet Debug
--              Communication Link and Serial GMII interface
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.amba.all;
use work.devices.all;
use work.gencomp.all;
use work.net.all;
use work.ethernet_mac.all;
use work.ethcomp.all;

entity greths is
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
    mdcscaler      : integer range 0 to 255 := 25; 
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
end entity;
  
architecture rtl of greths is
  -- GMII and MII signals between MAC and PCS
  signal mac_ethi       : eth_in_type;
  signal pcs_ethi       : eth_in_type;
  signal mac_etho       : eth_out_type;
  signal pcs_etho       : eth_out_type;
  signal int_tx_rstn    : std_logic;
  signal int_rx_rstn    : std_logic;
  -- MDIO signals
  signal mdio_o_pcs     : std_logic;
  signal mdio_oe_pcs    : std_logic;
  signal mdio_i_pcs     : std_logic;
begin
-------------------------------------------------------------------------------
-- Ethernet MAC
-------------------------------------------------------------------------------
  u0 : grethm
    generic map (
      hindex         => hindex,
      pindex         => pindex,
      paddr          => paddr,
      pmask          => pmask,
      pirq           => pirq,
      memtech        => memtech,
      ifg_gap        => ifg_gap,
      attempt_limit  => attempt_limit,
      backoff_limit  => backoff_limit,
      slot_time      => slot_time,
      mdcscaler      => mdcscaler,
      enable_mdio    => enable_mdio,
      fifosize       => fifosize,
      nsync          => nsync,
      edcl           => edcl,
      edclbufsz      => edclbufsz,
      burstlength    => burstlength,
      macaddrh       => macaddrh,
      macaddrl       => macaddrl,
      ipaddrh        => ipaddrh,
      ipaddrl        => ipaddrl,
      phyrstadr      => phyrstadr,
      rmii           => rmii,
      sim            => sim,
      giga           => giga,
      oepol          => oepol,
      scanen         => scanen,
      ft             => ft,
      edclft         => edclft,
      mdint_pol      => mdint_pol,
      enable_mdint   => enable_mdint,
      multicast      => multicast,
      ramdebug       => ramdebug,
      mdiohold       => mdiohold,
      maxsize        => maxsize,
      gmiimode       => 1
    )
    port map (
      rst            => rst,
      clk            => clk,
      ahbmi          => ahbmi,
      ahbmo          => ahbmo,
      apbi           => apbi,
      apbo           => apbo,
      ethi           => mac_ethi,
      etho           => mac_etho
    );
-------------------------------------------------------------------------------
-- 1000baseX-compliant SGMII bridge
-------------------------------------------------------------------------------
  sgmii0: sgmii
    generic map (
      fabtech   => fabtech,
      memtech   => memtech,
      transtech => transtech,
      phy_addr  => pcs_phyaddr
    )
    port map(
      clk_125       => clk_125,
      rst_125       => rst_125,
      ser_rx_p      => eth_rx_p,
      ser_rx_n      => eth_rx_n,
      ser_tx_p      => eth_tx_p,
      ser_tx_n      => eth_tx_n,
      txd           => pcs_etho.txd,
      tx_en         => pcs_etho.tx_en,
      tx_er         => pcs_etho.tx_er,
      tx_clk        => pcs_ethi.gtx_clk,
      tx_rstn       => int_tx_rstn,
      rxd           => pcs_ethi.rxd,
      rx_dv         => pcs_ethi.rx_dv,
      rx_er         => pcs_ethi.rx_er,
      rx_col        => pcs_ethi.rx_col,
      rx_crs        => pcs_ethi.rx_crs,
      rx_clk        => pcs_ethi.rx_clk,
      rx_rstn       => int_rx_rstn,
      -- optional MDIO interface to PCS
      mdc           => pcs_etho.mdc,
      mdio_o        => mdio_o_pcs,
      mdio_oe       => mdio_oe_pcs,
      mdio_i        => mdio_i_pcs,
      -- added for igloo2_serdes
      apbin         => apbin,
      apbout        => apbout,
      m2gl_padin    => m2gl_padin,
      m2gl_padout   => m2gl_padout,
      serdes_clk125 => serdes_clk125,
      rx_aligned    => rx_aligned
    );

  -- 10/100 Mbit GMII to MII adapter
  adapt_10_100_0 : gmii_to_mii 
    port map (
      tx_rstn => int_tx_rstn,
      rx_rstn => int_rx_rstn,
      gmiii   => mac_ethi,  -- OUT
      gmiio   => mac_etho,  -- IN
      miii    => pcs_ethi,  -- IN
      miio    => pcs_etho   -- OUT
    );

  -- Drive MDIO signals (including PCS bypass to MAC)
  reset           <= pcs_etho.reset;
  mdc             <= pcs_etho.mdc;
  mdio_oe         <= '1' when debug_pcs_mdio = '1' else pcs_etho.mdio_oe;
  mdio_o          <= '0' when debug_pcs_mdio = '1' else pcs_etho.mdio_o;
  mdio_oe_pcs     <= pcs_etho.mdio_oe when debug_pcs_mdio = '1' else '1';
  mdio_o_pcs      <= pcs_etho.mdio_o when debug_pcs_mdio = '1' else '0';
  pcs_ethi.mdint  <= mdint;
  pcs_ethi.mdio_i <= mdio_i_pcs when debug_pcs_mdio = '1' else mdio_i;
  -- MAC input signals integration
  pcs_ethi.tx_clk       <= pcs_ethi.gtx_clk;
  pcs_ethi.phyrstaddr   <= phyrstaddr;
  pcs_ethi.edcladdr     <= edcladdr;
  pcs_ethi.edclsepahb   <= edclsepahb;
  pcs_ethi.edcldisable  <= edcldisable;
end architecture;

