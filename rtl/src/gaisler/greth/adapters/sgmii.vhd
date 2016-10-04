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
-- Entity:      sgmii
-- File:        sgmii.vhd
-- Author:      Andrea Gianarro - Aeroflex Gaisler AB
-- Description: SGMII to GMII Ethernet bridge
--              Provide a valid MDC clock input for proper functioning
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.net.all;
use work.misc.all;
use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.ge_1000baseX_comp.all;

entity sgmii is
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
    mdc           : in  std_logic;        -- must be provided
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
  ) ;
end entity ;

architecture rtl of sgmii is

  signal tx_in_int_reversed, rx_out_int_reversed, tx_in_int, rx_out_int, rx_out_pll_int : std_logic_vector(9 downto 0);
  signal rx_clk_int, rx_pll_clk_int, tx_pll_clk_int, rx_rstn_int, rx_rst_int, rx_pll_rstn_int, rx_pll_rst_int, tx_pll_rst_int, tx_pll_rstn_int, startup_enable_int : std_logic;
  signal mdio_int, bitslip_int : std_logic;
  signal rx_int_clk : std_logic_vector(0 downto 0) ;
  signal debug_int : std_logic_vector(31 downto 0) ;

  signal ready_sig : std_logic;
  signal mdc_rst, mdc_rstn : std_logic;

begin

  rx_rst_int <= not rx_rstn_int;
  rx_pll_rst_int <= not rx_pll_rstn_int;
  tx_pll_rst_int <= not tx_pll_rstn_int;

  pma0: serdes
    generic map (
      fabtech   => fabtech,
      transtech => transtech
    )
    port map (
      clk_125     => clk_125,
      rst_125     => rst_125,
      rx_in_p     => ser_rx_p,
      rx_in_n     => ser_rx_n,
      rx_out      => rx_out_int,
      rx_clk      => rx_clk_int,
      rx_rstn     => rx_rstn_int,
      rx_pll_clk  => rx_pll_clk_int,
      rx_pll_rstn => rx_pll_rstn_int,
      tx_pll_clk  => tx_pll_clk_int,
      tx_pll_rstn => tx_pll_rstn_int,
      tx_in       => tx_in_int,
      tx_out_p    => ser_tx_p, 
      tx_out_n    => ser_tx_n, 
      bitslip     => bitslip_int,
      apbin       => apbin,
      apbout      => apbout,
      m2gl_padin  => m2gl_padin,
      m2gl_padout  => m2gl_padout,
      serdes_clk125 => serdes_clk125,
      serdes_ready => ready_sig
    );

  str0: if (fabtech = stratix3) or (fabtech = stratix4) or (is_unisim(fabtech) = 1) generate
    -- COMMA DETECTOR WITH BITSLIP LOGIC
    cd0: comma_detect
      generic map (
        bsbreak => 16,
        bswait  => 63
        )
      port map (
        clk     => rx_clk_int,
        rstn    => rx_rstn_int,
        indata  => rx_out_int,
        bitslip => bitslip_int
    );

    -- ELASTIC BUFFER WITH INTERNAL FIFO
    eb0: elastic_buffer
      generic map (
        tech    => memtech,
        abits   => 7
      )
      port map (
        wr_clk  => rx_clk_int,
        wr_rst  => rx_rst_int,
        wr_data => rx_out_int,
        rd_clk  => rx_pll_clk_int,
        rd_rst  => rx_pll_rst_int,
        rd_data => rx_out_pll_int
      );

    pcs0 : ge_1000baseX
      generic map (
        PHY_ADDR => phy_addr,
        BASEX_AN_MODE => mode
      )
      port map(
        rx_ck           => rx_pll_clk_int,
        tx_ck           => tx_pll_clk_int,
        rx_reset        => rx_pll_rst_int,
        tx_reset        => tx_pll_rst_int,
        startup_enable  => startup_enable_int,
        tbi_rxd         => rx_out_pll_int,  -- abcdefghij
        tbi_txd         => tx_in_int,       -- abcdefghij
        gmii_rxd        => rxd,
        gmii_rx_dv      => rx_dv,
        gmii_rx_er      => rx_er,
        gmii_col        => rx_col,
        gmii_cs         => rx_crs,
        gmii_txd        => txd,
        gmii_tx_en      => tx_en,
        gmii_tx_er      => tx_er,
        repeater_mode   => '0',
        mdc_reset       => rst_125,
        mdio_i          => mdio_int,
        mdio_o          => mdio_i,
        mdc             => mdc,
        debug           => debug_int
        );
    
  end generate;

  igl2 : if (fabtech = igloo2) or (fabtech = rtg4) generate
    -- comma detector and word aligner
    wa0: word_aligner
    port map (
      clk => rx_clk_int,
      rstn => rx_rstn_int,
      rx_in => rx_out_int,
      rx_out => rx_out_pll_int);

  rst0 : rstgen     -- reset synchronizer for MDC clock domain in ge_1000baseX
    generic map (syncrst => 1, acthigh => 1)
    port map (rx_pll_rst_int, mdc, '1', mdc_rstn, open);

  mdc_rst <= not(mdc_rstn);

  pcs0 : ge_1000baseX
    generic map (
      PHY_ADDR => phy_addr,
      BASEX_AN_MODE => mode
    )
    port map(
      rx_ck           => rx_pll_clk_int,
      tx_ck           => tx_pll_clk_int,
      rx_reset        => rx_pll_rst_int,
      tx_reset        => tx_pll_rst_int,
      startup_enable  => startup_enable_int,
      tbi_rxd         => rx_out_pll_int,  -- abcdefghij
      tbi_txd         => tx_in_int,       -- abcdefghij
      gmii_rxd        => rxd,
      gmii_rx_dv      => rx_dv,
      gmii_rx_er      => rx_er,
      gmii_col        => rx_col,
      gmii_cs         => rx_crs,
      gmii_txd        => txd,
      gmii_tx_en      => tx_en,
      gmii_tx_er      => tx_er,
      repeater_mode   => '0',
      mdc_reset       => mdc_rst,
      mdio_i          => mdio_int,
      mdio_o          => mdio_i,
      mdc             => mdc,
      debug           => debug_int
      );

  end generate;

  mdio_int <= mdio_o when mdio_oe = '0' else
          '0'; 

  startup_enable_int <= (not rst_125) and ready_sig;

  rx_clk      <= rx_pll_clk_int; --rx_clk_int;
  rx_rstn     <= rx_pll_rstn_int;
  tx_clk      <= tx_pll_clk_int; --clk_125;
  tx_rstn     <= tx_pll_rstn_int;
  rx_aligned  <= ready_sig;

end architecture ; -- rtl
