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
----------------------------------------------------------------------------
-- Entity:      ser_phy
-- File:        ser_phy.vhd
-- Description: Serial wrapper for simulation model of an Ethernet PHY
-- Author:      Andrea Gianarro
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;

use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.net.all;
use work.sim.all;

use work.gencomp.all;

entity ser_phy is
  generic(
    address       : integer range 0 to 31 := 0;
    extended_regs : integer range 0 to 1  := 1;
    aneg          : integer range 0 to 1  := 1;
    base100_t4    : integer range 0 to 1  := 0;
    base100_x_fd  : integer range 0 to 1  := 1;
    base100_x_hd  : integer range 0 to 1  := 1;
    fd_10         : integer range 0 to 1  := 1;
    hd_10         : integer range 0 to 1  := 1;
    base100_t2_fd : integer range 0 to 1  := 1;
    base100_t2_hd : integer range 0 to 1  := 1;
    base1000_x_fd : integer range 0 to 1  := 0;
    base1000_x_hd : integer range 0 to 1  := 0;
    base1000_t_fd : integer range 0 to 1  := 1;
    base1000_t_hd : integer range 0 to 1  := 1;
    rmii          : integer range 0 to 1  := 0;
    rgmii         : integer range 0 to 1  := 0;
    fabtech       : integer := 0;
    memtech       : integer := 0;
    transtech     : integer := 0
    );
  port(
    rstn     : in std_logic;

    clk_125        : in  std_logic;
    rst_125        : in  std_logic;
    eth_rx_p       : out std_logic;
    eth_rx_n       : out std_logic;
    eth_tx_p       : in  std_logic;
    eth_tx_n       : in  std_logic := '0';

    mdio     : inout std_logic;
    mdc      : in std_logic;

    -- added for igloo2_serdes
    apbin         : in apb_in_serdes := apb_in_serdes_none;
    apbout        : out apb_out_serdes;
    m2gl_padin    : in pad_in_serdes := pad_in_serdes_none;
    m2gl_padout   : out pad_out_serdes;
    serdes_clk125 : out std_logic;
    rx_aligned    : out std_logic
  );
end;

architecture behavioral of ser_phy is
  signal int_tx_rstn  : std_logic;
  signal int_rx_rstn  : std_logic;
  signal phy_ethi     : eth_in_type;
  signal pcs_ethi     : eth_in_type;
  signal phy_etho     : eth_out_type;
  signal pcs_etho     : eth_out_type;
begin
  p0: phy
    generic map(
      address       => address,
      extended_regs => extended_regs,
      aneg          => aneg,
      fd_10         => fd_10,
      hd_10         => hd_10,
      base100_t4    => base100_t4,
      base100_x_fd  => base100_x_fd,
      base100_x_hd  => base100_x_hd,
      base100_t2_fd => base100_t2_fd,
      base100_t2_hd => base100_t2_hd,
      base1000_x_fd => base1000_x_fd,
      base1000_x_hd => base1000_x_hd,
      base1000_t_fd => base1000_t_fd,
      base1000_t_hd => base1000_t_hd,
      rmii          => 0,
      rgmii         => 0
    )
    port map(
      rstn    => rstn,
      mdio    => mdio,
      tx_clk  => open,
      rx_clk  => open,
      rxd     => phy_etho.txd,
      rx_dv   => phy_etho.tx_en,
      rx_er   => phy_etho.tx_er,
      rx_col  => open,
      rx_crs  => open,
      txd     => phy_ethi.rxd,
      tx_en   => phy_ethi.rx_dv,
      tx_er   => phy_ethi.rx_er,
      mdc     => mdc,
      gtx_clk => phy_ethi.gtx_clk
    );

  -- GMII to MII adapter fixed to Gigabit mode (disabled)
  phy_etho.gbit  <= '1';
  phy_etho.speed <= '0';

  adapt_10_100_0: gmii_to_mii
    port map (
      tx_rstn => int_tx_rstn,
      rx_rstn => int_rx_rstn,
      gmiii   => phy_ethi,  -- OUT
      gmiio   => phy_etho,  -- IN
      miii    => pcs_ethi,  -- IN
      miio    => pcs_etho   -- OUT
      );

  pcs0: sgmii
    generic map (
      fabtech   => fabtech,
      memtech   => memtech,
      transtech => transtech
    )
    port map(
      clk_125       => clk_125,
      rst_125       => rst_125,

      ser_rx_p      => eth_tx_p,
      ser_rx_n      => eth_tx_n,
      ser_tx_p      => eth_rx_p,
      ser_tx_n      => eth_rx_n,

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

      mdc           => mdc,

      -- added for igloo2_serdes
      apbin        => apbin,
      apbout       => apbout,
      m2gl_padin   => m2gl_padin,
      m2gl_padout  => m2gl_padout,
      serdes_clk125 => serdes_clk125,
      rx_aligned   => rx_aligned
    );

end architecture;
-- pragma translate_on
