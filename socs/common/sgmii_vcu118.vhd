--------------------------------------------------------------------------------
--  Etherent PHY Interface Wrapper for Xilinx VCU118 (based on example design)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  A portion of this file is a part of the GRLIB VHDL IP LIBRARY
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
-------------------------------------------------------------------------------
-- Entity:      sgmii
-- File:        sgmii.vhd
-- Author:      Fredrik Ringhage - Aeroflex Gaisler
-- Description: GMII to SGMII interface
-- Author:      Paolo Mantovani - Columbia University
-- Description: Adapted interface to Xilinx VCU118
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Porting for Xilinx VCU118 Evaluation Board
--
-- Copyright (C) 2018 - 2019, Columbia University, System Level Design Group
--
-- Author: Paolo Mantovani @ Columbia University
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- File       : sgmii_example_design.v
-- Author     : Xilinx Inc.
--------------------------------------------------------------------------------
-- (c) Copyright 2015 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.net.all;
use work.misc.all;

use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;

use work.grethpkg.all;

--------------------------------------------------------------------------------
-- The entity declaration for the example design
--------------------------------------------------------------------------------

entity sgmii_vcu118 is
  generic(
    pindex          : integer := 0;
    paddr           : integer := 0;
    pmask           : integer := 16#fff#;
    abits           : integer := 8;
    autonegotiation : integer := 1;
    pirq            : integer := 0;
    debugmem        : integer := 0;
    tech            : integer := 0;
    vcu128          : integer range 0 to 1 := 0;
    simulation      : boolean := false
    );
  port(
    -- Tranceiver Interface
    sgmiii   : in  eth_sgmii_in_type;
    sgmiio   : out eth_sgmii_out_type;
    sgmii_dummy : in std_logic;
    -- GMII Interface (client MAC <=> PCS)
    gmiii    : out eth_in_type;
    gmiio    : in  eth_out_type;
    -- Asynchronous reset for entire core.
    reset    : in  std_logic;
    -- APB Status bus
    apb_clk  : in  std_logic;
    apb_rstn : in  std_logic;
    apbi     : in  apb_slv_in_type;
    apbo     : out apb_slv_out_type

    );
end sgmii_vcu118;

architecture top_level of sgmii_vcu118 is

  constant REVISION : integer := 1;

  constant pconfig : apb_config_type := (
    0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_SGMII, 0, REVISION, pirq),
    1 => apb_iobar(paddr, pmask),
    2 => (others => '0'));

  component sgmii is
    port (
      txp_0                  : out std_logic;
      txn_0                  : out std_logic;
      rxp_0                  : in  std_logic;
      rxn_0                  : in  std_logic;
      signal_detect_0        : in  std_logic;
      gmii_txd_0             : in  std_logic_vector (7 downto 0);
      gmii_tx_en_0           : in  std_logic;
      gmii_tx_er_0           : in  std_logic;
      gmii_rxd_0             : out std_logic_vector (7 downto 0);
      gmii_rx_dv_0           : out std_logic;
      gmii_rx_er_0           : out std_logic;
      gmii_isolate_0         : out std_logic;
      sgmii_clk_r_0          : out std_logic;
      sgmii_clk_f_0          : out std_logic;
      sgmii_clk_en_0         : out std_logic;
      speed_is_10_100_0      : in  std_logic;
      speed_is_100_0         : in  std_logic;
      an_interrupt_0         : out std_logic;
      an_adv_config_vector_0 : in  std_logic_vector (15 downto 0);
      an_restart_config_0    : in  std_logic;
      status_vector_0        : out std_logic_vector (15 downto 0);
      configuration_vector_0 : in  std_logic_vector (4 downto 0);
      clk125m                : in  std_logic;
      clk312                 : in  std_logic;
      rx_btval               : in  std_logic_vector (8 downto 0);
      tx_bsc_rst             : in  std_logic;
      rx_bsc_rst             : in  std_logic;
      tx_bs_rst              : in  std_logic;
      rx_bs_rst              : in  std_logic;
      tx_rst_dly             : in  std_logic;
      rx_rst_dly             : in  std_logic;
      tx_bsc_en_vtc          : in  std_logic;
      rx_bsc_en_vtc          : in  std_logic;
      tx_bs_en_vtc           : in  std_logic;
      rx_bs_en_vtc           : in  std_logic;
      riu_clk                : in  std_logic;
      riu_addr               : in  std_logic_vector (5 downto 0);
      riu_wr_data            : in  std_logic_vector (15 downto 0);
      riu_wr_en              : in  std_logic;
      riu_nibble_sel         : in  std_logic_vector (1 downto 0);
      riu_prsnt              : out std_logic;
      riu_valid              : out std_logic;
      riu_rd_data            : out std_logic_vector (15 downto 0);
      tx_pll_clk             : in  std_logic;
      rx_pll_clk             : in  std_logic;
      tx_rdclk               : in  std_logic;
      tx_dly_rdy             : out std_logic;
      tx_vtc_rdy             : out std_logic;
      rx_dly_rdy             : out std_logic;
      rx_vtc_rdy             : out std_logic;
      reset                  : in  std_logic);
  end component sgmii;

  component sgmii_vcu128 is
    port (
      dummy_port_in          : in  std_logic;
      txp_0                  : out std_logic;
      txn_0                  : out std_logic;
      rxp_0                  : in  std_logic;
      rxn_0                  : in  std_logic;
      signal_detect_0        : in  std_logic;
      gmii_txd_0             : in  std_logic_vector (7 downto 0);
      gmii_tx_en_0           : in  std_logic;
      gmii_tx_er_0           : in  std_logic;
      gmii_rxd_0             : out std_logic_vector (7 downto 0);
      gmii_rx_dv_0           : out std_logic;
      gmii_rx_er_0           : out std_logic;
      gmii_isolate_0         : out std_logic;
      sgmii_clk_r_0          : out std_logic;
      sgmii_clk_f_0          : out std_logic;
      sgmii_clk_en_0         : out std_logic;
      speed_is_10_100_0      : in  std_logic;
      speed_is_100_0         : in  std_logic;
      an_interrupt_0         : out std_logic;
      an_adv_config_vector_0 : in  std_logic_vector (15 downto 0);
      an_restart_config_0    : in  std_logic;
      status_vector_0        : out std_logic_vector (15 downto 0);
      configuration_vector_0 : in  std_logic_vector (4 downto 0);
      clk125m                : in  std_logic;
      clk312                 : in  std_logic;
      rx_btval               : in  std_logic_vector (8 downto 0);
      tx_bsc_rst             : in  std_logic;
      rx_bsc_rst             : in  std_logic;
      tx_bs_rst              : in  std_logic;
      rx_bs_rst              : in  std_logic;
      tx_rst_dly             : in  std_logic;
      rx_rst_dly             : in  std_logic;
      tx_bsc_en_vtc          : in  std_logic;
      rx_bsc_en_vtc          : in  std_logic;
      tx_bs_en_vtc           : in  std_logic;
      rx_bs_en_vtc           : in  std_logic;
      riu_clk                : in  std_logic;
      riu_addr               : in  std_logic_vector (5 downto 0);
      riu_wr_data            : in  std_logic_vector (15 downto 0);
      riu_wr_en              : in  std_logic;
      riu_nibble_sel         : in  std_logic_vector (1 downto 0);
      riu_prsnt              : out std_logic;
      riu_valid              : out std_logic;
      riu_rd_data            : out std_logic_vector (15 downto 0);
      tx_pll_clk             : in  std_logic;
      rx_pll_clk             : in  std_logic;
      tx_rdclk               : in  std_logic;
      tx_dly_rdy             : out std_logic;
      tx_vtc_rdy             : out std_logic;
      rx_dly_rdy             : out std_logic;
      rx_vtc_rdy             : out std_logic;
      reset                  : in  std_logic);
  end component sgmii_vcu128;

  component sgmii_vcu118_clock_reset is
    generic (
      C_Part             : string;
      EXAMPLE_SIMULATION : boolean;
      C_IoBank           : integer);
    port (
      ClockIn_p      : in  std_logic;
      ClockIn_n      : in  std_logic;
      ClockIn_se_out : out std_logic;
      ResetIn        : in  std_logic;
      Tx_Dly_Rdy     : in  std_logic;
      Tx_Vtc_Rdy     : in  std_logic;
      Tx_Bsc_EnVtc   : out std_logic;
      Tx_Bs_EnVtc    : out std_logic;
      Rx_Dly_Rdy     : in  std_logic;
      Rx_Vtc_Rdy     : in  std_logic;
      Rx_Bsc_EnVtc   : out std_logic;
      Rx_Bs_EnVtc    : out std_logic;
      Tx_SysClk      : out std_logic;
      Tx_WrClk       : out std_logic;
      Tx_ClkOutPhy   : out std_logic;
      Rx_SysClk      : out std_logic;
      Rx_RiuClk      : out std_logic;
      Rx_ClkOutPhy   : out std_logic;
      Tx_Locked      : out std_logic;
      Tx_Bs_RstDly   : out std_logic;
      Tx_Bs_Rst      : out std_logic;
      Tx_Bsc_Rst     : out std_logic;
      Tx_LogicRst    : out std_logic;
      Rx_Locked      : out std_logic;
      Rx_Bs_RstDly   : out std_logic;
      Rx_Bs_Rst      : out std_logic;
      Rx_Bsc_Rst     : out std_logic;
      Rx_LogicRst    : out std_logic;
      Riu_Addr       : out std_logic_vector(5 downto 0);
      Riu_WrData     : out std_logic_vector(15 downto 0);
      Riu_Wr_En      : out std_logic;
      Riu_Nibble_Sel : out std_logic_vector(1 downto 0);
      Riu_RdData_3   : in  std_logic_vector(15 downto 0);
      Riu_Valid_3    : in  std_logic;
      Riu_Prsnt_3    : in  std_logic;
      Riu_RdData_2   : in  std_logic_vector(15 downto 0);
      Riu_Valid_2    : in  std_logic;
      Riu_Prsnt_2    : in  std_logic;
      Riu_RdData_1   : in  std_logic_vector(15 downto 0);
      Riu_Valid_1    : in  std_logic;
      Riu_Prsnt_1    : in  std_logic;
      Riu_RdData_0   : in  std_logic_vector(15 downto 0);
      Riu_Valid_0    : in  std_logic;
      Riu_Prsnt_0    : in  std_logic;
      Rx_BtVal_3     : out std_logic_vector(8 downto 0);
      Rx_BtVal_2     : out std_logic_vector(8 downto 0);
      Rx_BtVal_1     : out std_logic_vector(8 downto 0);
      Rx_BtVal_0     : out std_logic_vector(8 downto 0);
      Debug_Out      : out std_logic_vector(7 downto 0));
  end component sgmii_vcu118_clock_reset;

  component sgmii_vcu118_reset_sync is
    port (
      reset_in  : in  std_logic;
      clk       : in  std_logic;
      reset_out : out std_logic);
  end component sgmii_vcu118_reset_sync;

  type sgmiiregs is record
    irq                  : std_logic_vector(31 downto 0);  -- interrupt
    mask                 : std_logic_vector(31 downto 0);  -- interrupt enable
    configuration_vector : std_logic_vector(4 downto 0);
    an_adv_config_vector : std_logic_vector(15 downto 0);
  end record;

  -- APB and RGMII control register
  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;

  constant RES_configuration_vector : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(autonegotiation, 1)) & "0000";

  constant RES : sgmiiregs :=
    (irq                  => (others => '0'), mask => (others => '0'),
     configuration_vector => RES_configuration_vector, an_adv_config_vector => "0001100000000001");

  type rxregs is record
    gmii_rxd     : std_logic_vector(7 downto 0);
    gmii_rxd_int : std_logic_vector(7 downto 0);
    gmii_rx_dv   : std_logic;
    gmii_rx_er   : std_logic;
    count        : integer;
    gmii_dv      : std_logic;
    keepalive    : integer;
  end record;

  constant RESRX : rxregs :=
    (gmii_rxd   => (others => '0'), gmii_rxd_int => (others => '0'),
     gmii_rx_dv => '0', gmii_rx_er => '0',
     count      => 0, gmii_dv => '0', keepalive => 0
     );

  type txregs is record
    gmii_txd       : std_logic_vector(7 downto 0);
    gmii_txd_int   : std_logic_vector(7 downto 0);
    gmii_tx_en     : std_logic;
    gmii_tx_en_int : std_logic;
    gmii_tx_er     : std_logic;
    count          : integer;
    cnt_en         : std_logic;
    keepalive      : integer;
  end record;

  constant RESTX : txregs :=
    (gmii_txd   => (others => '0'), gmii_txd_int => (others => '0'),
     gmii_tx_en => '0', gmii_tx_en_int => '0', gmii_tx_er => '0',
     count      => 0, cnt_en => '0', keepalive => 0
     );

  -- clock generation signals for tranceiver
  signal clk125m    : std_logic;
  signal clk312     : std_logic;

  -- clock generation signals for SGMII clock
  signal tx_logic_reset, rx_logic_reset     : std_logic;
  signal tx_logic_rst_int, rx_logic_rst_int : std_logic;
  signal logic_reset                        : std_logic;
  signal rst125m                            : std_logic;
  signal sgmii_clk_r                        : std_logic;
  signal sgmii_clk_f                        : std_logic;
  signal sgmii_clk_en                       : std_logic;

  -- GMII signals
  signal gmii_txd     : std_logic_vector(7 downto 0);
  signal gmii_tx_en   : std_logic;
  signal gmii_tx_er   : std_logic;
  signal gmii_rxd     : std_logic_vector(7 downto 0);
  signal gmii_rx_dv   : std_logic;
  signal gmii_rx_er   : std_logic;
  signal gmii_isolate : std_logic;

  -- Internal GMII signals from Xilinx SGMII block
  signal gmii_rxd_int   : std_logic_vector(7 downto 0);
  signal gmii_rx_dv_int : std_logic;
  signal gmii_rx_er_int : std_logic;

  -- Extra registers to ease IOB placement
  signal status_vector_int  : std_logic_vector(15 downto 0);
  signal status_vector_apb  : std_logic_vector(15 downto 0);
  signal status_vector_apb1 : std_logic_vector(31 downto 0);
  signal status_vector_apb2 : std_logic_vector(31 downto 0);

  -- Configuration register
  signal speed_is_10_100      : std_logic;
  signal speed_is_100         : std_logic;
  signal configuration_vector : std_logic_vector(4 downto 0);
  signal an_interrupt         : std_logic;
  signal an_adv_config_vector : std_logic_vector(15 downto 0);
  signal an_restart_config    : std_logic;

  signal synchronization_done : std_logic;
  signal linkup               : std_logic;
  signal signal_detect        : std_logic;

  -- Multi SGMII core interface (unused, but necessary for reset)
  signal rx_btval       : std_logic_vector (8 downto 0);
  signal tx_bsc_rst     : std_logic;
  signal rx_bsc_rst     : std_logic;
  signal tx_bs_rst      : std_logic;
  signal rx_bs_rst      : std_logic;
  signal tx_rst_dly     : std_logic;
  signal rx_rst_dly     : std_logic;
  signal tx_bsc_en_vtc  : std_logic;
  signal rx_bsc_en_vtc  : std_logic;
  signal tx_bs_en_vtc   : std_logic;
  signal rx_bs_en_vtc   : std_logic;
  signal riu_clk        : std_logic;
  signal riu_addr       : std_logic_vector (5 downto 0);
  signal riu_wr_data    : std_logic_vector (15 downto 0);
  signal riu_wr_en      : std_logic;
  signal riu_nibble_sel : std_logic_vector (1 downto 0);
  signal riu_prsnt      : std_logic;
  signal riu_valid      : std_logic;
  signal riu_rd_data    : std_logic_vector (15 downto 0);
  signal tx_pll_clk     : std_logic;
  signal rx_pll_clk     : std_logic;
  signal tx_rdclk       : std_logic;
  signal tx_dly_rdy     : std_logic;
  signal tx_vtc_rdy     : std_logic;
  signal rx_dly_rdy     : std_logic;
  signal rx_vtc_rdy     : std_logic;

  -- GMII adapter signals
  signal r, rin     : sgmiiregs;
  signal rrx, rinrx : rxregs;
  signal rtx, rintx : txregs;

  signal cnt_en : std_logic;

  -- debug signals
  signal WMemRgmiioData : std_logic_vector(15 downto 0);
  signal RMemRgmiioData : std_logic_vector(15 downto 0);
  signal RMemRgmiioAddr : std_logic_vector(9 downto 0);
  signal WMemRgmiioAddr : std_logic_vector(9 downto 0);
  signal WMemRgmiioWrEn : std_logic;
  signal WMemRgmiiiData : std_logic_vector(15 downto 0);
  signal RMemRgmiiiData : std_logic_vector(15 downto 0);
  signal RMemRgmiiiAddr : std_logic_vector(9 downto 0);
  signal WMemRgmiiiAddr : std_logic_vector(9 downto 0);
  signal WMemRgmiiiWrEn : std_logic;
  signal RMemRgmiiiRead : std_logic;
  signal RMemRgmiioRead : std_logic;

  attribute keep         : boolean;
  attribute syn_keep     : string;
  attribute keep of clk125m : signal is true;
  attribute syn_keep of clk125m : signal is "true";

begin

  -----------------------------------------------------------------------------
  -- Default for VCU118
  -----------------------------------------------------------------------------

  -- Remove AN during simulation i.e. "00000"
  configuration_vector <= "10000" when (autonegotiation = 1) else "00000";

  -- Configuration for Xilinx SGMII IP. See doc for SGMII IP for more information
  an_adv_config_vector <= "0001100000000001";
  an_restart_config    <= '0';

  --  Core Status vector outputs
  synchronization_done <= status_vector_int(1);
  linkup               <= status_vector_int(0);
  signal_detect        <= '1';

  gmiii.gtx_clk  <= clk125m;
  gmiii.tx_clk   <= clk125m;
  gmiii.rx_clk   <= clk125m;
  gmiii.rmii_clk <= clk125m;
  gmiii.rxd      <= gmii_rxd;
  gmiii.rx_dv    <= gmii_rx_dv;
  gmiii.rx_er    <= gmii_rx_er;
  gmiii.rx_en    <= gmii_rx_dv or sgmii_clk_en;

  --gmiii.tx_dv <= '1';
  gmiii.tx_dv <= cnt_en when gmiio.tx_en = '1' else '1';

  -- GMII output controlled via generics
  gmiii.edclsepahb  <= '1';
  gmiii.edcldisable <= '0';
  gmiii.phyrstaddr  <= (others => '0');
  gmiii.edcladdr    <= (others => '0');

  -- Not used
  gmiii.rx_col    <= '0';
  gmiii.rx_crs    <= '0';
  gmiii.tx_clk_90 <= '0';

  sgmiio.mdio_o  <= gmiio.mdio_o;
  sgmiio.mdio_oe <= gmiio.mdio_oe;
  gmiii.mdio_i   <= sgmiii.mdio_i;
  sgmiio.mdc     <= gmiio.mdc;
  gmiii.mdint    <= sgmiii.mdint;
  sgmiio.reset   <= apb_rstn;

  -----------------------------------------------------------------------------
  -- Transceiver Clock Management
  -----------------------------------------------------------------------------

  sgmii_vcu118_clock_reset_1 : sgmii_vcu118_clock_reset
    generic map (
      C_Part             => "XCVU9P",
      EXAMPLE_SIMULATION => simulation,
      C_IoBank           => 64)
    port map (
      ClockIn_p      => sgmiii.clkp,
      ClockIn_n      => sgmiii.clkn,
      ClockIn_se_out => open,
      ResetIn        => reset,
      Tx_Dly_Rdy     => '1',
      Tx_Vtc_Rdy     => '1',
      Tx_Bsc_EnVtc   => tx_bsc_en_vtc,
      Tx_Bs_EnVtc    => tx_bs_en_vtc,
      Rx_Dly_Rdy     => '1',
      Rx_Vtc_Rdy     => '1',
      Rx_Bsc_EnVtc   => rx_bsc_en_vtc,
      Rx_Bs_EnVtc    => rx_bs_en_vtc,
      Tx_SysClk      => tx_rdclk,       -- 312.5MHZ
      Tx_WrClk       => clk125m,        -- 125 MHz
      Tx_ClkOutPhy   => tx_pll_clk,     -- 1250 MHz
      Rx_SysClk      => clk312,         -- 312.5 MHz
      Rx_RiuClk      => riu_clk,        -- 208 MHz
      Rx_ClkOutPhy   => rx_pll_clk,     -- 625 MHz
      Tx_Locked      => open,
      Tx_Bs_RstDly   => tx_rst_dly,
      Tx_Bs_Rst      => tx_bs_rst,
      Tx_Bsc_Rst     => tx_bsc_rst,
      Tx_LogicRst    => tx_logic_rst_int,
      Rx_Locked      => open,
      Rx_Bs_RstDly   => rx_rst_dly,
      Rx_Bs_Rst      => rx_bs_rst,
      Rx_Bsc_Rst     => rx_bsc_rst,
      Rx_LogicRst    => rx_logic_rst_int,
      Riu_Addr       => riu_addr,
      Riu_WrData     => riu_wr_data,
      Riu_Wr_En      => riu_wr_en,
      Riu_Nibble_Sel => riu_nibble_sel,
      Riu_RdData_3   => (others => '0'),
      Riu_Valid_3    => '0',
      Riu_Prsnt_3    => '0',
      Riu_RdData_2   => (others => '0'),
      Riu_Valid_2    => '0',
      Riu_Prsnt_2    => '0',
      Riu_RdData_1   => (others => '0'),
      Riu_Valid_1    => '0',
      Riu_Prsnt_1    => '0',
      Riu_RdData_0   => riu_rd_data,
      Riu_Valid_0    => riu_valid,
      Riu_Prsnt_0    => riu_prsnt,
      Rx_BtVal_3     => open,
      Rx_BtVal_2     => open,
      Rx_BtVal_1     => open,
      Rx_BtVal_0     => rx_btval,
      Debug_Out      => open);

  tx_logic_reset <= tx_logic_rst_int;
  rx_logic_reset <= rx_logic_rst_int;
  logic_reset    <= tx_logic_rst_int or rx_logic_rst_int;

  reset_sync_clk125m : sgmii_vcu118_reset_sync
    port map (
      reset_in  => logic_reset,
      clk       => clk125m,
      reset_out => rst125m);

  ------------------------------------------------------------------------------
  -- Instantiate the Core Block (core wrapper).
  ------------------------------------------------------------------------------

  speed_is_10_100 <= not gmiio.gbit;
  speed_is_100    <= gmiio.speed;

  vcu118_gen: if vcu128 = 0 generate
    core_wrapper : sgmii
      port map (
        txp_0                  => sgmiio.txp,
        txn_0                  => sgmiio.txn,
        rxp_0                  => sgmiii.rxp,
        rxn_0                  => sgmiii.rxn,
        signal_detect_0        => signal_detect,
        gmii_txd_0             => gmii_txd,
        gmii_tx_en_0           => gmii_tx_en,
        gmii_tx_er_0           => gmii_tx_er,
        gmii_rxd_0             => gmii_rxd_int,
        gmii_rx_dv_0           => gmii_rx_dv_int,
        gmii_rx_er_0           => gmii_rx_er_int,
        gmii_isolate_0         => gmii_isolate,
        sgmii_clk_r_0          => sgmii_clk_r,
        sgmii_clk_f_0          => sgmii_clk_f,
        sgmii_clk_en_0         => sgmii_clk_en,
        speed_is_10_100_0      => speed_is_10_100,
        speed_is_100_0         => speed_is_100,
        an_interrupt_0         => an_interrupt,
        an_adv_config_vector_0 => an_adv_config_vector,
        an_restart_config_0    => an_restart_config,
        status_vector_0        => status_vector_int,
        configuration_vector_0 => configuration_vector,
        clk125m                => clk125m,
        clk312                 => clk312,
        rx_btval               => rx_btval,
        tx_bsc_rst             => tx_bsc_rst,
        rx_bsc_rst             => rx_bsc_rst,
        tx_bs_rst              => tx_bs_rst,
        rx_bs_rst              => rx_bs_rst,
        tx_rst_dly             => tx_rst_dly,
        rx_rst_dly             => rx_rst_dly,
        tx_bsc_en_vtc          => tx_bsc_en_vtc,
        rx_bsc_en_vtc          => rx_bsc_en_vtc,
        tx_bs_en_vtc           => tx_bs_en_vtc,
        rx_bs_en_vtc           => rx_bs_en_vtc,
        riu_clk                => riu_clk,
        riu_addr               => riu_addr,
        riu_wr_data            => riu_wr_data,
        riu_wr_en              => riu_wr_en,
        riu_nibble_sel         => riu_nibble_sel,
        riu_prsnt              => riu_prsnt,
        riu_valid              => riu_valid,
        riu_rd_data            => riu_rd_data,
        tx_pll_clk             => tx_pll_clk,
        rx_pll_clk             => rx_pll_clk,
        tx_rdclk               => tx_rdclk,
        tx_dly_rdy             => tx_dly_rdy,
        tx_vtc_rdy             => tx_vtc_rdy,
        rx_dly_rdy             => rx_dly_rdy,
        rx_vtc_rdy             => rx_vtc_rdy,
        reset                  => rst125m);
  end generate vcu118_gen;

  vcu128_gen: if vcu128 /= 0 generate
    core_wrapper : sgmii_vcu128
      port map (
        dummy_port_in          => sgmii_dummy,
        txp_0                  => sgmiio.txp,
        txn_0                  => sgmiio.txn,
        rxp_0                  => sgmiii.rxp,
        rxn_0                  => sgmiii.rxn,
        signal_detect_0        => signal_detect,
        gmii_txd_0             => gmii_txd,
        gmii_tx_en_0           => gmii_tx_en,
        gmii_tx_er_0           => gmii_tx_er,
        gmii_rxd_0             => gmii_rxd_int,
        gmii_rx_dv_0           => gmii_rx_dv_int,
        gmii_rx_er_0           => gmii_rx_er_int,
        gmii_isolate_0         => gmii_isolate,
        sgmii_clk_r_0          => sgmii_clk_r,
        sgmii_clk_f_0          => sgmii_clk_f,
        sgmii_clk_en_0         => sgmii_clk_en,
        speed_is_10_100_0      => speed_is_10_100,
        speed_is_100_0         => speed_is_100,
        an_interrupt_0         => an_interrupt,
        an_adv_config_vector_0 => an_adv_config_vector,
        an_restart_config_0    => an_restart_config,
        status_vector_0        => status_vector_int,
        configuration_vector_0 => configuration_vector,
        clk125m                => clk125m,
        clk312                 => clk312,
        rx_btval               => rx_btval,
        tx_bsc_rst             => tx_bsc_rst,
        rx_bsc_rst             => rx_bsc_rst,
        tx_bs_rst              => tx_bs_rst,
        rx_bs_rst              => rx_bs_rst,
        tx_rst_dly             => tx_rst_dly,
        rx_rst_dly             => rx_rst_dly,
        tx_bsc_en_vtc          => tx_bsc_en_vtc,
        rx_bsc_en_vtc          => rx_bsc_en_vtc,
        tx_bs_en_vtc           => tx_bs_en_vtc,
        rx_bs_en_vtc           => rx_bs_en_vtc,
        riu_clk                => riu_clk,
        riu_addr               => riu_addr,
        riu_wr_data            => riu_wr_data,
        riu_wr_en              => riu_wr_en,
        riu_nibble_sel         => riu_nibble_sel,
        riu_prsnt              => riu_prsnt,
        riu_valid              => riu_valid,
        riu_rd_data            => riu_rd_data,
        tx_pll_clk             => tx_pll_clk,
        rx_pll_clk             => rx_pll_clk,
        tx_rdclk               => tx_rdclk,
        tx_dly_rdy             => tx_dly_rdy,
        tx_vtc_rdy             => tx_vtc_rdy,
        rx_dly_rdy             => rx_dly_rdy,
        rx_vtc_rdy             => rx_vtc_rdy,
        reset                  => rst125m);
  end generate vcu128_gen;

  ------------------------------------------------------------------------------
  -- GMII (Aeroflex Gaisler) to GMII (Xilinx) style
  ------------------------------------------------------------------------------

  -- 10/100Mbit TX Loic
  process (rst125m, rtx, gmiio)
    variable v : txregs;
  begin
    v                := rtx;
    v.cnt_en         := '0';
    v.gmii_tx_en_int := gmiio.tx_en;

    if (gmiio.tx_en = '1' and rtx.gmii_tx_en_int = '0') then
      v.count := 0;
    elsif (v.count >= 9) and gmiio.speed = '1' then
      v.count := 0;
    elsif (v.count >= 99) and gmiio.speed = '0' then
      v.count := 0;
    else
      v.count := rtx.count + 1;
    end if;

    case v.count is
      when 0 =>
        v.gmii_txd_int(3 downto 0) := gmiio.txd(3 downto 0);
        v.cnt_en                   := '1';

      when 5 =>
        if gmiio.speed = '1' then
          v.gmii_txd_int(7 downto 4) := gmiio.txd(3 downto 0);
          v.cnt_en                   := '1';
        end if;

      when 50 =>
        if gmiio.speed = '0' then
          v.gmii_txd_int(7 downto 4) := gmiio.txd(3 downto 0);
          v.cnt_en                   := '1';
        end if;


      when 9 =>
        if gmiio.speed = '1' then
          v.gmii_txd                              := v.gmii_txd_int;
          v.gmii_tx_en                            := '1';
          v.gmii_tx_er                            := gmiio.tx_er;
          if (gmiio.tx_en = '0' and rtx.keepalive <= 1) then v.gmii_tx_en := '0'; end if;
          if (rtx.keepalive > 0) then v.keepalive := rtx.keepalive - 1; end if;
        end if;

      when 99 =>
        if gmiio.speed = '0' then
          v.gmii_txd                              := v.gmii_txd_int;
          v.gmii_tx_en                            := '1';
          v.gmii_tx_er                            := gmiio.tx_er;
          if (gmiio.tx_en = '0' and rtx.keepalive <= 1) then v.gmii_tx_en := '0'; end if;
          if (rtx.keepalive > 0) then v.keepalive := rtx.keepalive - 1; end if;
        end if;

      when others =>
        null;

    end case;

    if (gmiio.tx_en = '0' and rtx.gmii_tx_en_int = '1') then
      v.keepalive := 2;
    end if;

    if (gmiio.tx_en = '0' and rtx.gmii_tx_en_int = '0' and rtx.keepalive = 0) then
      v := RESTX;
    end if;

    -- reset operation
    if (not RESET_ALL) and (rst125m = '1') then
      v := RESTX;
    end if;

    -- update registers
    rintx <= v;
  end process;

  txegs : process(clk125m)
  begin
    if rising_edge(clk125m) then
      rtx <= rintx;
      if RESET_ALL and rst125m = '1' then
        rtx <= RESTX;
      end if;
    end if;
  end process;

  -- 1000Mbit TX Logic (Bypass)
  -- n/a

  -- TX Mux Select
  cnt_en <= '1' when (gmiio.gbit = '1') else rtx.cnt_en;

  gmii_txd   <= gmiio.txd   when (gmiio.gbit = '1') else rtx.gmii_txd;
  gmii_tx_en <= gmiio.tx_en when (gmiio.gbit = '1') else rtx.gmii_tx_en;
  gmii_tx_er <= gmiio.tx_er when (gmiio.gbit = '1') else rtx.gmii_tx_er;

  ------------------------------------------------------------------------------
  -- GMII (Xilinx) to GMII (Aeroflex Gailers) style
  ------------------------------------------------------------------------------

  ---- 10/100Mbit RX Loic
  process (rst125m, rrx, gmii_rx_dv_int, gmii_rxd_int, gmii_rx_er_int, sgmii_clk_en)
    variable v : rxregs;
  begin
    v := rrx;

    if (gmii_rx_dv_int = '1' and sgmii_clk_en = '1') then
      v.count        := 0;
      v.gmii_rxd_int := gmii_rxd_int;
      v.gmii_dv      := '1';
      v.keepalive    := 1;
    elsif (v.count >= 9) and gmiio.speed = '1' then
      v.count     := 0;
      v.keepalive := rrx.keepalive - 1;
    elsif (v.count >= 99) and gmiio.speed = '0' then
      v.count     := 0;
      v.keepalive := rrx.keepalive - 1;
    else
      v.count := rrx.count + 1;
    end if;

    case v.count is
      when 0 =>
        v.gmii_rxd   := v.gmii_rxd_int(3 downto 0) & v.gmii_rxd_int(3 downto 0);
        v.gmii_rx_dv := v.gmii_dv;
      when 5 =>
        if gmiio.speed = '1' then
          v.gmii_rxd   := v.gmii_rxd_int(7 downto 4) & v.gmii_rxd_int(7 downto 4);
          v.gmii_rx_dv := v.gmii_dv;
          v.gmii_dv    := '0';
        end if;
      when 50 =>
        if gmiio.speed = '0' then
          v.gmii_rxd   := v.gmii_rxd_int(7 downto 4) & v.gmii_rxd_int(7 downto 4);
          v.gmii_rx_dv := v.gmii_dv;
          v.gmii_dv    := '0';
        end if;
      when others =>
        v.gmii_rxd   := v.gmii_rxd;
        v.gmii_rx_dv := '0';
    end case;

    v.gmii_rx_er := gmii_rx_er_int;

    if (rrx.keepalive = 0 and gmii_rx_dv_int = '0') then
      v := RESRX;
    end if;

    -- reset operation
    if (not RESET_ALL) and (rst125m = '1') then
      v := RESRX;
    end if;

    -- update registers
    rinrx <= v;
  end process;

  rx100regs : process(clk125m)
  begin
    if rising_edge(clk125m) then
      rrx <= rinrx;
      if RESET_ALL and rst125m = '1' then
        rrx <= RESRX;
      end if;
    end if;
  end process;

  ---- 1000Mbit RX Logic (Bypass)
  -- n/a

  ---- RX Mux Select
  gmii_rxd   <= gmii_rxd_int   when (gmiio.gbit = '1') else rinrx.gmii_rxd;
  gmii_rx_dv <= gmii_rx_dv_int when (gmiio.gbit = '1') else rinrx.gmii_rx_dv;
  gmii_rx_er <= gmii_rx_er_int when (gmiio.gbit = '1') else rinrx.gmii_rx_er;

  -----------------------------------------------------------------------------
  -- Extra registers to ease CDC placement
  -----------------------------------------------------------------------------
  process (apb_clk)
  begin
    if apb_clk'event and apb_clk = '1' then
      status_vector_apb <= status_vector_int;
    end if;
  end process;

  ---------------------------------------------------------------------------------------
  -- APB Section
  ---------------------------------------------------------------------------------------

  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  -- Extra registers to ease CDC placement
  process (apb_clk)
  begin
    if apb_clk'event and apb_clk = '1' then
      status_vector_apb1              <= (others => '0');
      status_vector_apb2              <= (others => '0');
      -- Register to detect a speed change
      status_vector_apb1(15 downto 0) <= status_vector_apb;
      status_vector_apb2              <= status_vector_apb1;
    end if;
  end process;

  rgmiiapb : process(apb_rstn, r, apbi, status_vector_apb1, status_vector_apb2, RMemRgmiiiData, RMemRgmiiiRead, RMemRgmiioRead)
    variable rdata    : std_logic_vector(31 downto 0);
    variable paddress : std_logic_vector(7 downto 2);
    variable v        : sgmiiregs;
  begin

    v                          := r;
    paddress                   := (others => '0');
    paddress(abits-1 downto 2) := apbi.paddr(abits-1 downto 2);
    rdata                      := (others => '0');

    -- read/write registers

    if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
      case paddress(7 downto 2) is
        when "000000" =>
          rdata(31 downto 0) := status_vector_apb2;
        when "000001" =>
          rdata(31 downto 0) := r.irq;
          v.irq              := (others => '0');  -- Interrupt is clear on read
        when "000010" =>
          rdata(31 downto 0) := r.mask;
        when "000011" =>
          rdata(4 downto 0) := r.configuration_vector;
        when "000100" =>
          rdata(15 downto 0) := r.an_adv_config_vector;
        when "000101" =>
          if (autonegotiation /= 0) then rdata(0) := '1'; else rdata(0) := '0'; end if;
          if (debugmem /= 0) then rdata(1)        := '1'; else rdata(1) := '0'; end if;
        when others =>
          null;
      end case;
    end if;

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case paddress(7 downto 2) is
        when "000000" =>
          null;
        when "000001" =>
          null;
        when "000010" =>
          v.mask := apbi.pwdata(31 downto 0);
        when "000011" =>
          v.configuration_vector := apbi.pwdata(4 downto 0);
        when "000100" =>
          v.an_adv_config_vector := apbi.pwdata(15 downto 0);
        when "000101" =>
          null;
        when others =>
          null;
      end case;
    end if;

    -- Check interrupts
    for i in 0 to status_vector_apb2'length-1 loop
      if ((status_vector_apb1(i) xor status_vector_apb2(i)) and v.mask(i)) = '1' then
        v.irq(i) := '1';
      end if;
    end loop;

    -- reset operation
    if (not RESET_ALL) and (apb_rstn = '0') then
      v := RES;
    end if;

    -- update registers
    rin <= v;

    -- drive outputs
    if apbi.psel(pindex) = '0' then
      apbo.prdata <= (others => '0');
    elsif RMemRgmiiiRead = '1' then
      apbo.prdata(31 downto 16) <= (others => '0');
      apbo.prdata(15 downto 0)  <= RMemRgmiiiData;
    elsif RMemRgmiioRead = '1' then
      apbo.prdata(31 downto 16) <= (others => '0');
      apbo.prdata(15 downto 0)  <= RMemRgmiioData;
    else
      apbo.prdata <= rdata;
    end if;

    apbo.pirq       <= (others => '0');
    apbo.pirq(pirq) <= orv(v.irq);

  end process;

  regs : process(apb_clk)
  begin
    if rising_edge(apb_clk) then
      r <= rin;
      if RESET_ALL and apb_rstn = '0' then
        r <= RES;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------------------
  --  Debug Mem
  ---------------------------------------------------------------------------------------

  debugmem1 : if (debugmem /= 0) generate

    -- Write GMII IN data
    process (clk125m)
    begin  -- process
      if rising_edge(clk125m) then
        WMemRgmiioData(15 downto 0) <= '0' & '0' & '0' & sgmii_clk_en & '0' & '0' & gmii_tx_er & gmii_tx_en & gmii_txd;
        if (gmii_tx_en = '1') and ((WMemRgmiioAddr < "0111111110") or (WMemRgmiioAddr = "1111111111")) then
          WMemRgmiioAddr <= WMemRgmiioAddr + 1;
          WMemRgmiioWrEn <= '1';
        else
          if (gmii_tx_en = '0') then
            WMemRgmiioAddr <= (others => '1');
          else
            WMemRgmiioAddr <= WMemRgmiioAddr;
          end if;
          WMemRgmiioWrEn <= '0';
        end if;

        if rst125m = '1' then
          WMemRgmiioAddr <= (others => '0');
          WMemRgmiioWrEn <= '0';
        end if;

      end if;
    end process;

    -- Read
    RMemRgmiioRead <= apbi.paddr(10) and apbi.psel(pindex);
    RMemRgmiioAddr <= "00" & apbi.paddr(10-1 downto 2);

    gmiii0 : syncram_2p generic map (tech, 10, 16, 1, 0, 0) port map(
      apb_clk, RMemRgmiioRead, RMemRgmiioAddr, RMemRgmiioData,
      clk125m, WMemRgmiioWrEn, WMemRgmiioAddr(10-1 downto 0), WMemRgmiioData);

    -- Write GMII IN data
    process (clk125m)
    begin  -- process
      if rising_edge(clk125m) then

        if (gmii_rx_dv = '1') then
          WMemRgmiiiData(15 downto 0) <= '0' & '0' & '0' &sgmii_clk_en & "00" & gmii_rx_er & gmii_rx_dv & gmii_rxd;
        elsif (gmii_rx_dv_int = '0') then
          WMemRgmiiiData(15 downto 0) <= (others => '0');
        else
          WMemRgmiiiData <= WMemRgmiiiData;
        end if;

        if (gmii_rx_dv = '1') and ((WMemRgmiiiAddr < "0111111110") or (WMemRgmiiiAddr = "1111111111")) then
          WMemRgmiiiAddr <= WMemRgmiiiAddr + 1;
          WMemRgmiiiWrEn <= '1';
        else
          if (gmii_rx_dv_int = '0') then
            WMemRgmiiiAddr <= (others => '1');
            WMemRgmiiiWrEn <= '0';
          else
            WMemRgmiiiAddr <= WMemRgmiiiAddr;
            WMemRgmiiiWrEn <= '0';
          end if;
        end if;

        if rst125m = '1' then
          WMemRgmiiiAddr <= (others => '0');
          WMemRgmiiiWrEn <= '0';
        end if;

      end if;
    end process;

    -- Read
    RMemRgmiiiRead <= apbi.paddr(11) and apbi.psel(pindex);
    RMemRgmiiiAddr <= "00" & apbi.paddr(10-1 downto 2);

    rgmiii0 : syncram_2p generic map (tech, 10, 16, 1, 0, 0) port map(
      apb_clk, RMemRgmiiiRead, RMemRgmiiiAddr, RMemRgmiiiData,
      clk125m, WMemRgmiiiWrEn, WMemRgmiiiAddr(10-1 downto 0), WMemRgmiiiData);

  end generate;

-- pragma translate_off
  bootmsg : report_version
    generic map ("sgmii" & tost(pindex) &
                 ": SGMII rev " & tost(REVISION) & ", irq " & tost(pirq));
-- pragma translate_on

end top_level;
