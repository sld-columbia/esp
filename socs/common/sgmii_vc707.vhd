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
-- Entity: 	sgmii
-- File:	sgmii.vhd
-- Author:	Fredrik Ringhage - Aeroflex Gaisler
-- Description: GMII to SGMII interface
------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Description: This is the top level vhdl example design for the
--              Ethernet 1000BASE-X PCS/PMA core.
--
--              This design example instantiates IOB flip-flops
--              and input/output buffers on the GMII.
--
--              A Transmitter Elastic Buffer is instantiated on the Tx
--              GMII path to perform clock compenstation between the
--              core and the external MAC driving the Tx GMII.
--
--              This design example can be synthesised.
--
--
--
--    ----------------------------------------------------------------
--    |                             Example Design                   |
--    |                                                              |
--    |             ----------------------------------------------   |
--    |             |           Core Block (wrapper)             |   |
--    |             |                                            |   |
--    |             |   --------------          --------------   |   |
--    |             |   |    Core    |          | tranceiver |   |   |
--    |             |   |            |          |            |   |   |
--    |  ---------  |   |            |          |            |   |   |
--    |  |       |  |   |            |          |            |   |   |
--    |  |  Tx   |  |   |            |          |            |   |   |
--  ---->|Elastic|----->| GMII       |--------->|        TXP |--------->
--    |  |Buffer |  |   | Tx         |          |        TXN |   |   |
--    |  |       |  |   |            |          |            |   |   |
--    |  ---------  |   |            |          |            |   |   |
--    | GMII        |   |            |          |            |   |   |
--    | IOBs        |   |            |          |            |   |   |
--    |             |   |            |          |            |   |   |
--    |             |   | GMII       |          |        RXP |   |   |
--  <-------------------| Rx         |<---------|        RXN |<---------
--    |             |   |            |          |            |   |   |
--    |             |   --------------          --------------   |   |
--    |             |                                            |   |
--    |             ----------------------------------------------   |
--    |                                                              |
--    ----------------------------------------------------------------
--
--------------------------------------------------------------------------------

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

entity sgmii_vc707 is
      generic(
        pindex          : integer := 0;
        paddr           : integer := 0;
        pmask           : integer := 16#fff#;
        abits           : integer := 8;
        autonegotiation : integer := 1;
        pirq            : integer := 0;
        debugmem        : integer := 0;
        tech            : integer := 0;
        simulation      : boolean := false
      );
        port(
      -- Tranceiver Interface
      sgmiii            :  in  eth_sgmii_in_type;
      sgmiio            :  out eth_sgmii_out_type;
      -- GMII Interface (client MAC <=> PCS)
      gmiii             : out eth_in_type;
      gmiio             : in  eth_out_type;
      -- Asynchronous reset for entire core.
      reset             : in std_logic;
      -- APB Status bus
      apb_clk           : in    std_logic;
      apb_rstn          : in    std_logic;
      apbi              : in    apb_slv_in_type;
      apbo              : out   apb_slv_out_type

      );
end sgmii_vc707;

architecture top_level of sgmii_vc707 is

  ------------------------------------------------------------------------------
  -- Component Declaration for the Core Block (core wrapper).
  ------------------------------------------------------------------------------
   component sgmii
      port(
      -- Transceiver Interface
      ------------------------

      gtrefclk             : in std_logic;                     -- Very high quality 125MHz clock for GT transceiver
      gtrefclk_bufg        : in std_logic;
      txp                  : out std_logic;                    -- Differential +ve of serial transmission from PMA to PMD.
      txn                  : out std_logic;                    -- Differential -ve of serial transmission from PMA to PMD.
      rxp                  : in std_logic;                     -- Differential +ve for serial reception from PMD to PMA.
      rxn                  : in std_logic;                     -- Differential -ve for serial reception from PMD to PMA.
      resetdone            : out std_logic;                    -- The GT transceiver has completed its reset cycle
      cplllock             : out std_logic;
      mmcm_reset           : out std_logic;
      txoutclk             : out std_logic;                    -- txoutclk from GT transceiver (62.5MHz)
      rxoutclk             : out std_logic;                    -- txoutclk from GT transceiver (62.5MHz)
      userclk              : in std_logic;                     -- 62.5MHz clock.
      userclk2             : in std_logic;                     -- 125MHz clock.
      rxuserclk            : in std_logic;                     -- 125MHz clock.
      rxuserclk2           : in std_logic;                     -- 125MHz clock.
      independent_clock_bufg : in std_logic;
      pma_reset            : in std_logic;                     -- transceiver PMA reset signal
      mmcm_locked          : in std_logic;                     -- Locked signal from MMCM
      -- GMII Interface
      -----------------
      sgmii_clk_r          : out std_logic;                    -- Clock for client MAC (125Mhz, 12.5MHz or 1.25MHz).
      sgmii_clk_f          : out std_logic;                    -- Clock for client MAC (125Mhz, 12.5MHz or 1.25MHz).
      sgmii_clk_en         : out std_logic;                    -- Clock enable for client MAC
      gmii_txd             : in std_logic_vector(7 downto 0);  -- Transmit data from client MAC.
      gmii_tx_en           : in std_logic;                     -- Transmit control signal from client MAC.
      gmii_tx_er           : in std_logic;                     -- Transmit control signal from client MAC.
      gmii_rxd             : out std_logic_vector(7 downto 0); -- Received Data to client MAC.
      gmii_rx_dv           : out std_logic;                    -- Received control signal to client MAC.
      gmii_rx_er           : out std_logic;                    -- Received control signal to client MAC.
      gmii_isolate         : out std_logic;                    -- Tristate control to electrically isolate GMII.

      -- Management: MDIO Interface
      -----------------------------

      configuration_vector : in std_logic_vector(4 downto 0);  -- Alternative to MDIO interface.

      an_interrupt         : out std_logic;                    -- Interrupt to processor to signal that Auto-Negotiation has completed
      an_adv_config_vector : in std_logic_vector(15 downto 0); -- Alternate interface to program REG4 (AN ADV)
      an_restart_config    : in std_logic;                     -- Alternate signal to modify AN restart bit in REG0

      -- Speed Control
      ----------------
      speed_is_10_100      : in std_logic;                     -- Core should operate at either 10Mbps or 100Mbps speeds
      speed_is_100         : in std_logic;                     -- Core should operate at 100Mbps speed

      -- General IO's
      ---------------
      status_vector        : out std_logic_vector(15 downto 0); -- Core status.
      reset                : in std_logic;                      -- Asynchronous reset for entire core.
      signal_detect        : in std_logic;                      -- Input from PMD to indicate presence of optical input.
      gt0_qplloutclk_in    : in std_logic;                      -- Input from PMD to indicate presence of optical input.
      gt0_qplloutrefclk_in : in std_logic                       -- Input from PMD to indicate presence of optical input.

      );

   end component;

component MMCME2_ADV
  generic (
     BANDWIDTH : string := "OPTIMIZED";
     CLKFBOUT_MULT_F : real := 5.000;
     CLKFBOUT_PHASE : real := 0.000;
     CLKFBOUT_USE_FINE_PS : string := "FALSE";
     CLKIN1_PERIOD : real := 0.000;
     CLKIN2_PERIOD : real := 0.000;
     CLKOUT0_DIVIDE_F : real := 1.000;
     CLKOUT0_DUTY_CYCLE : real := 0.500;
     CLKOUT0_PHASE : real := 0.000;
     CLKOUT0_USE_FINE_PS : string := "FALSE";
     CLKOUT1_DIVIDE : integer := 1;
     CLKOUT1_DUTY_CYCLE : real := 0.500;
     CLKOUT1_PHASE : real := 0.000;
     CLKOUT1_USE_FINE_PS : string := "FALSE";
     CLKOUT2_DIVIDE : integer := 1;
     CLKOUT2_DUTY_CYCLE : real := 0.500;
     CLKOUT2_PHASE : real := 0.000;
     CLKOUT2_USE_FINE_PS : string := "FALSE";
     CLKOUT3_DIVIDE : integer := 1;
     CLKOUT3_DUTY_CYCLE : real := 0.500;
     CLKOUT3_PHASE : real := 0.000;
     CLKOUT3_USE_FINE_PS : string := "FALSE";
     CLKOUT4_CASCADE : string := "FALSE";
     CLKOUT4_DIVIDE : integer := 1;
     CLKOUT4_DUTY_CYCLE : real := 0.500;
     CLKOUT4_PHASE : real := 0.000;
     CLKOUT4_USE_FINE_PS : string := "FALSE";
     CLKOUT5_DIVIDE : integer := 1;
     CLKOUT5_DUTY_CYCLE : real := 0.500;
     CLKOUT5_PHASE : real := 0.000;
     CLKOUT5_USE_FINE_PS : string := "FALSE";
     CLKOUT6_DIVIDE : integer := 1;
     CLKOUT6_DUTY_CYCLE : real := 0.500;
     CLKOUT6_PHASE : real := 0.000;
     CLKOUT6_USE_FINE_PS : string := "FALSE";
     COMPENSATION : string := "ZHOLD";
     DIVCLK_DIVIDE : integer := 1;
     IS_CLKINSEL_INVERTED : std_logic := std_logic' ('0');
     IS_PSEN_INVERTED : std_logic := std_logic' ('0');
     IS_PSINCDEC_INVERTED : std_logic := std_logic' ('0');
     IS_PWRDWN_INVERTED : std_logic := std_logic' ('0');
     IS_RST_INVERTED : std_logic := std_logic' ('0');
     REF_JITTER1 : real := 0.0;
     REF_JITTER2 : real := 0.0;
     SS_EN : string := "FALSE";
     SS_MODE : string := "CENTER_HIGH";
     SS_MOD_PERIOD : integer := 10000
  );
  port (
     CLKFBOUT : out std_ulogic := '0';
     CLKFBOUTB : out std_ulogic := '0';
     CLKFBSTOPPED : out std_ulogic := '0';
     CLKINSTOPPED : out std_ulogic := '0';
     CLKOUT0 : out std_ulogic := '0';
     CLKOUT0B : out std_ulogic := '0';
     CLKOUT1 : out std_ulogic := '0';
     CLKOUT1B : out std_ulogic := '0';
     CLKOUT2 : out std_ulogic := '0';
     CLKOUT2B : out std_ulogic := '0';
     CLKOUT3 : out std_ulogic := '0';
     CLKOUT3B : out std_ulogic := '0';
     CLKOUT4 : out std_ulogic := '0';
     CLKOUT5 : out std_ulogic := '0';
     CLKOUT6 : out std_ulogic := '0';
     DO : out std_logic_vector (15 downto 0);
     DRDY : out std_ulogic := '0';
     LOCKED : out std_ulogic := '0';
     PSDONE : out std_ulogic := '0';
     CLKFBIN : in std_ulogic;
     CLKIN1 : in std_ulogic;
     CLKIN2 : in std_ulogic;
     CLKINSEL : in std_ulogic;
     DADDR : in std_logic_vector(6 downto 0);
     DCLK : in std_ulogic;
     DEN : in std_ulogic;
     DI : in std_logic_vector(15 downto 0);
     DWE : in std_ulogic;
     PSCLK : in std_ulogic;
     PSEN : in std_ulogic;
     PSINCDEC : in std_ulogic;
     PWRDWN : in std_ulogic;
     RST : in std_ulogic
  );
end component;

----- component IBUFDS_GTE2 -----
component IBUFDS_GTE2
  port (
     O : out std_ulogic;
     ODIV2 : out std_ulogic;
     CEB : in std_ulogic;
     I : in std_ulogic;
     IB : in std_ulogic
  );
end component;

----- component BUFHCE -----
component BUFHCE
  generic (
     CE_TYPE : string := "SYNC";
     INIT_OUT : integer := 0
  );
  port (
     O : out std_ulogic;
     CE : in std_ulogic;
     I : in std_ulogic
  );
end component;


----- component BUFG -----
component BUFG
  port (
    O : out std_logic;
    I : in std_logic);
end component;

----- component BUFGMUX -----
component BUFGMUX
  generic (
     CLK_SEL_TYPE : string := "ASYNC"
  );
  port (
     O : out std_ulogic := '0';
     I0 : in std_ulogic := '0';
     I1 : in std_ulogic := '0';
     S : in std_ulogic := '0'
  );
end component;

----- component ODDR -----
component ODDR
  generic (
     DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
     INIT : bit := '0';
     SRTYPE : string := "SYNC"
  );
  port (
     Q : out std_ulogic;
     C : in std_ulogic;
     CE : in std_ulogic;
     D1 : in std_ulogic;
     D2 : in std_ulogic;
     R : in std_ulogic := 'L';
     S : in std_ulogic := 'L'
  );
end component;

constant REVISION : integer := 1;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_SGMII, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask),
  2 => (others => '0'));

  type sgmiiregs is record
    irq                  :  std_logic_vector(31 downto 0); -- interrupt
    mask                 :  std_logic_vector(31 downto 0); -- interrupt enable
    configuration_vector :  std_logic_vector( 4 downto 0);
    an_adv_config_vector :  std_logic_vector(15 downto 0);
  end record;

  -- APB and RGMII control register
  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;

  constant RES_configuration_vector : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(autonegotiation,1)) & "0000";

  constant RES : sgmiiregs :=
  ( irq => (others => '0'), mask => (others => '0'),
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
  ( gmii_rxd => (others => '0'), gmii_rxd_int => (others => '0'),
    gmii_rx_dv => '0', gmii_rx_er => '0',
    count => 0, gmii_dv => '0', keepalive => 0
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
  ( gmii_txd => (others => '0'), gmii_txd_int => (others => '0'),
    gmii_tx_en => '0', gmii_tx_en_int => '0', gmii_tx_er => '0',
    count => 0, cnt_en => '0', keepalive => 0
  );

  ------------------------------------------------------------------------------
  -- internal signals used in this top level example design.
  ------------------------------------------------------------------------------

  -- clock generation signals for tranceiver
  signal gtrefclk              : std_logic;
  signal txoutclk              : std_logic;
  signal rxoutclk              : std_logic;
  signal resetdone             : std_logic;
  signal mmcm_locked           : std_logic;
  signal mmcm_reset            : std_logic;
  signal clkfbout              : std_logic;
  signal clkout0               : std_logic;
  signal clkout1               : std_logic;
  signal userclk               : std_logic;
  signal userclk2              : std_logic;
  signal rxuserclk               : std_logic;

  -- PMA reset generation signals for tranceiver
  signal pma_reset_pipe        : std_logic_vector(3 downto 0);
  signal pma_reset             : std_logic;

  -- clock generation signals for SGMII clock
  signal sgmii_clk_r           : std_logic;
  signal sgmii_clk_f           : std_logic;
  signal sgmii_clk_en          : std_logic;

  -- GMII signals
  signal gmii_txd              : std_logic_vector(7 downto 0);
  signal gmii_tx_en            : std_logic;
  signal gmii_tx_er            : std_logic;
  signal gmii_rxd              : std_logic_vector(7 downto 0);
  signal gmii_rx_dv            : std_logic;
  signal gmii_rx_er            : std_logic;
  signal gmii_isolate          : std_logic;

  -- Internal GMII signals from Xilinx SGMII block
  signal gmii_rxd_int          : std_logic_vector(7 downto 0);
  signal gmii_rx_dv_int        : std_logic;
  signal gmii_rx_er_int        : std_logic;

  -- Extra registers to ease IOB placement
  signal status_vector_int  : std_logic_vector(15 downto 0);
  signal status_vector_apb  : std_logic_vector(15 downto 0);
  signal status_vector_apb1 : std_logic_vector(31 downto 0);
  signal status_vector_apb2 : std_logic_vector(31 downto 0);

  -- These attributes will stop timing errors being reported in back annotated
  -- SDF simulation.
  attribute ASYNC_REG                   : string;
  attribute ASYNC_REG of pma_reset_pipe : signal is "TRUE";

  -- Configuration register

  signal speed_is_10_100      : std_logic;
  signal speed_is_100         : std_logic;

  signal configuration_vector : std_logic_vector(4 downto 0);

  signal an_interrupt         : std_logic;
  signal an_adv_config_vector : std_logic_vector(15 downto 0);
  signal an_restart_config    : std_logic;
  signal link_timer_value     : std_logic_vector(8 downto 0);

  signal synchronization_done : std_logic;
  signal linkup               : std_logic;
  signal signal_detect        : std_logic;

  -- Route gtrefclk through an IBUFG.
  signal gtrefclk_buf_i              : std_logic;

  signal r, rin : sgmiiregs;
  signal rrx,rinrx : rxregs;
  signal rtx, rintx : txregs;

  signal cnt_en               : std_logic;

  signal usr2rstn             : std_logic;

  -- debug signal
  signal WMemRgmiioData       : std_logic_vector(15 downto 0);
  signal RMemRgmiioData       : std_logic_vector(15 downto 0);
  signal RMemRgmiioAddr       : std_logic_vector(9 downto 0);
  signal WMemRgmiioAddr       : std_logic_vector(9 downto 0);
  signal WMemRgmiioWrEn       : std_logic;
  signal WMemRgmiiiData       : std_logic_vector(15 downto 0);
  signal RMemRgmiiiData       : std_logic_vector(15 downto 0);
  signal RMemRgmiiiAddr       : std_logic_vector(9 downto 0);
  signal WMemRgmiiiAddr       : std_logic_vector(9 downto 0);
  signal WMemRgmiiiWrEn       : std_logic;
  signal RMemRgmiiiRead       : std_logic;
  signal RMemRgmiioRead       : std_logic;

  attribute keep         : boolean;
  attribute syn_keep     : string;
  attribute keep of userclk2 : signal is true;
  attribute syn_keep of userclk2 : signal is "true";

begin

   -----------------------------------------------------------------------------
   -- Default for VC707
   -----------------------------------------------------------------------------

  -- Remove AN during simulation i.e. "00000"
  configuration_vector <= "10000" when (autonegotiation = 1) else "00000";

  -- Configuration for Xilinx SGMII IP. See doc for SGMII IP for more information
  an_adv_config_vector <= "0001100000000001";
  an_restart_config    <= '0';
  link_timer_value     <= "000110010";

  --  Core Status vector outputs
  synchronization_done <= status_vector_int(1);
  linkup               <= status_vector_int(0);
  signal_detect        <= '1';

  gmiii.gtx_clk <= userclk2;
  gmiii.tx_clk  <= userclk2;
  gmiii.rx_clk  <= userclk2;
  gmiii.rmii_clk <= userclk2;
  gmiii.rxd     <= gmii_rxd;
  gmiii.rx_dv   <= gmii_rx_dv;
  gmiii.rx_er   <= gmii_rx_er;
  gmiii.rx_en   <= gmii_rx_dv or sgmii_clk_en;

  --gmiii.tx_dv <= '1';
  gmiii.tx_dv <= cnt_en when gmiio.tx_en = '1' else '1';

  -- GMII output controlled via generics
  gmiii.edclsepahb <= '1';
  gmiii.edcldisable <= '0';
  gmiii.phyrstaddr <= (others => '0');
  gmiii.edcladdr <= (others => '0');

  -- Not used
  gmiii.rx_col <= '0';
  gmiii.rx_crs <= '0';
  gmiii.tx_clk_90 <= '0';

  sgmiio.mdio_o   <= gmiio.mdio_o;
  sgmiio.mdio_oe  <= gmiio.mdio_oe;
  gmiii.mdio_i    <= sgmiii.mdio_i;
  sgmiio.mdc      <= gmiio.mdc;
  gmiii.mdint     <= sgmiii.mdint;
  sgmiio.reset    <= apb_rstn;

   -----------------------------------------------------------------------------
   -- Transceiver Clock Management
   -----------------------------------------------------------------------------

   sgmii1 : if simulation  generate

   end generate;

   sgmii0 : if not simulation  generate

       -- Clock circuitry for the GT Transceiver uses a differential input clock.
       -- gtrefclk is routed to the tranceiver.
       ibufds_gtrefclk : IBUFDS_GTE2
       port map (
          I     => sgmiii.clkp,
          IB    => sgmiii.clkn,
          CEB   => '0',
          O     => gtrefclk_buf_i,
          ODIV2 => open
       );

       bufhce_gtrefclk : BUFHCE
       port map (
          I         => gtrefclk_buf_i,
          CE        => '1',
          O         => gtrefclk
       );

      -- The GT transceiver provides a 62.5MHz clock to the FPGA fabrix.  This is
      -- routed to an MMCM module where it is used to create phase and frequency
      -- related 62.5MHz and 125MHz clock sources
      mmcm_adv_inst : MMCME2_ADV
      generic map
       (BANDWIDTH            => "OPTIMIZED",
        --CLKOUT4_CASCADE      => FALSE,
        COMPENSATION         => "ZHOLD",
    --    STARTUP_WAIT         => FALSE,
        DIVCLK_DIVIDE        => 1,
        CLKFBOUT_MULT_F      => 16.000,
        CLKFBOUT_PHASE       => 0.000,
        --CLKFBOUT_USE_FINE_PS => FALSE,
        CLKOUT0_DIVIDE_F     => 8.000,
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.5,
        --CLKOUT0_USE_FINE_PS  => FALSE,
        CLKOUT1_DIVIDE       => 16,
        CLKOUT1_PHASE        => 0.000,
        CLKOUT1_DUTY_CYCLE   => 0.5,
        --CLKOUT1_USE_FINE_PS  => FALSE,
        CLKIN1_PERIOD        => 16.0,
        REF_JITTER1          => 0.010)
      port map
        -- Output clocks
       (CLKFBOUT             => clkfbout,
        CLKFBOUTB            => open,
        CLKOUT0              => clkout0,
        CLKOUT0B             => open,
        CLKOUT1              => clkout1,
        CLKOUT1B             => open,
        CLKOUT2              => open,
        CLKOUT2B             => open,
        CLKOUT3              => open,
        CLKOUT3B             => open,
        CLKOUT4              => open,
        CLKOUT5              => open,
        CLKOUT6              => open,
        -- Input clock control
        CLKFBIN              => clkfbout,
        CLKIN1               => txoutclk,
        CLKIN2               => '0',
        -- Tied to always select the primary input clock
        CLKINSEL             => '1',
        -- Ports for dynamic reconfiguration
        DADDR                => (others => '0'),
        DCLK                 => '0',
        DEN                  => '0',
        DI                   => (others => '0'),
        DO                   => open,
        DRDY                 => open,
        DWE                  => '0',
        -- Ports for dynamic phase shift
        PSCLK                => '0',
        PSEN                 => '0',
        PSINCDEC             => '0',
        PSDONE               => open,
        -- Other control and status signals
        LOCKED               => mmcm_locked,
        CLKINSTOPPED         => open,
        CLKFBSTOPPED         => open,
        PWRDWN               => '0',
        RST                  => mmcm_reset);

        --mmcm_reset <= reset or (not resetdone);
        mmcm_reset <= reset;

       -- This 62.5MHz clock is placed onto global clock routing and is then used
       -- for tranceiver TXUSRCLK/RXUSRCLK.
       bufg_userclk: BUFG
       port map (
          I     => clkout1,
          O     => userclk
       );

       -- This 125MHz clock is placed onto global clock routing and is then used
       -- to clock all Ethernet core logic.
       bufg_userclk2: BUFG
       port map (
          I     => clkout0,
          O     => userclk2
       );


       -- This 62.5MHz clock is placed onto global clock routing and is then used
       -- for tranceiver TXUSRCLK/RXUSRCLK.
       bufg_rxuserclk: BUFG
       port map (
          I     => rxoutclk,
          O     => rxuserclk
       );
   end generate;

   -----------------------------------------------------------------------------
   -- Sync Reset for user clock
   -----------------------------------------------------------------------------

   userclk2_rst : rstgen
    generic map(syncin => 1, syncrst => 1)
    port map(apb_rstn, userclk2, '1', usr2rstn, open);

   -----------------------------------------------------------------------------
   -- Transceiver PMA reset circuitry
   -----------------------------------------------------------------------------

   -- Create a reset pulse of a decent length
   process(reset, apb_clk)
   begin
     if (reset = '1') then
       pma_reset_pipe <= "1111";
     elsif apb_clk'event and apb_clk = '1' then
       pma_reset_pipe <= pma_reset_pipe(2 downto 0) & reset;
     end if;
   end process;

   pma_reset <= pma_reset_pipe(3);

  ------------------------------------------------------------------------------
  -- GMII (Aeroflex Gaisler) to GMII (Xilinx) style
  ------------------------------------------------------------------------------

   -- 10/100Mbit TX Loic
   process (usr2rstn,rtx,gmiio)
   variable v  : txregs;
   begin
      v := rtx;
      v.cnt_en := '0';
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
         v.cnt_en := '1';

      when 5 =>
        if gmiio.speed = '1' then
          v.gmii_txd_int(7 downto 4) := gmiio.txd(3 downto 0);
          v.cnt_en := '1';
        end if;

      when 50=>
        if gmiio.speed = '0' then
          v.gmii_txd_int(7 downto 4) := gmiio.txd(3 downto 0);
          v.cnt_en := '1';
        end if;


      when 9 =>
        if gmiio.speed = '1' then
          v.gmii_txd   := v.gmii_txd_int;
          v.gmii_tx_en := '1';
          v.gmii_tx_er := gmiio.tx_er;
          if (gmiio.tx_en = '0' and rtx.keepalive <= 1) then v.gmii_tx_en := '0'; end if;
          if (rtx.keepalive > 0) then v.keepalive := rtx.keepalive - 1; end if;
        end if;

      when 99 =>
        if gmiio.speed = '0' then
          v.gmii_txd   := v.gmii_txd_int;
          v.gmii_tx_en := '1';
          v.gmii_tx_er := gmiio.tx_er;
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
      if (not RESET_ALL) and (usr2rstn = '0') then
         v := RESTX;
      end if;

      -- update registers
      rintx <= v;
   end process;

   txegs : process(userclk2)
   begin
     if rising_edge(userclk2) then
       rtx <= rintx;
       if RESET_ALL and usr2rstn = '0' then
          rtx <= RESTX;
       end if;
     end if;
   end process;

   -- 1000Mbit TX Logic (Bypass)
   -- n/a

   -- TX Mux Select
   cnt_en <= '1' when (gmiio.gbit = '1') else rtx.cnt_en;

   gmii_txd   <= gmiio.txd    when (gmiio.gbit = '1') else rtx.gmii_txd;
   gmii_tx_en <= gmiio.tx_en  when (gmiio.gbit = '1') else rtx.gmii_tx_en;
   gmii_tx_er <= gmiio.tx_er  when (gmiio.gbit = '1') else rtx.gmii_tx_er;

  ------------------------------------------------------------------------------
  -- Instantiate the Core Block (core wrapper).
  ------------------------------------------------------------------------------

  speed_is_10_100 <= not gmiio.gbit;
  speed_is_100    <= gmiio.speed;

  core_wrapper : sgmii
    port map (
      gtrefclk               => gtrefclk,
      gtrefclk_bufg          => gtrefclk,
      txp                    => sgmiio.txp,
      txn                    => sgmiio.txn,
      rxp                    => sgmiii.rxp,
      rxn                    => sgmiii.rxn,
      resetdone              => resetdone,
      cplllock               => OPEN ,
      mmcm_reset             => OPEN ,
      txoutclk               => txoutclk,
      rxoutclk               => rxoutclk ,
      userclk                => userclk,
      userclk2               => userclk2,
      rxuserclk              => rxuserclk ,
      rxuserclk2             => rxuserclk ,
      independent_clock_bufg => apb_clk,
      pma_reset              => pma_reset,
      mmcm_locked            => mmcm_locked,
      sgmii_clk_r            => sgmii_clk_r,
      sgmii_clk_f            => sgmii_clk_f,
      sgmii_clk_en           => sgmii_clk_en,
      gmii_txd               => gmii_txd,
      gmii_tx_en             => gmii_tx_en,
      gmii_tx_er             => gmii_tx_er,
      gmii_rxd               => gmii_rxd_int,
      gmii_rx_dv             => gmii_rx_dv_int,
      gmii_rx_er             => gmii_rx_er_int,
      gmii_isolate           => gmii_isolate,
      configuration_vector   => configuration_vector,
      an_interrupt           => an_interrupt,
      an_adv_config_vector   => an_adv_config_vector,
      an_restart_config      => an_restart_config,
      speed_is_10_100        => speed_is_10_100,
      speed_is_100           => speed_is_100,
      status_vector          => status_vector_int,
      reset                  => reset,
      signal_detect          => signal_detect,
      gt0_qplloutclk_in      => '0',
      gt0_qplloutrefclk_in   => '0'
     );

  ------------------------------------------------------------------------------
  -- GMII (Xilinx) to GMII (Aeroflex Gailers) style
  ------------------------------------------------------------------------------

   ---- 10/100Mbit RX Loic
   process (usr2rstn,rrx,gmii_rx_dv_int,gmii_rxd_int,gmii_rx_er_int,sgmii_clk_en)
   variable v  : rxregs;
   begin
      v := rrx;

      if (gmii_rx_dv_int = '1' and sgmii_clk_en = '1') then
        v.count := 0;
        v.gmii_rxd_int := gmii_rxd_int;
        v.gmii_dv := '1';
        v.keepalive := 1;
      elsif (v.count >= 9) and gmiio.speed = '1' then
        v.count := 0;
        v.keepalive := rrx.keepalive - 1;
      elsif (v.count >= 99) and gmiio.speed = '0' then
        v.count := 0;
        v.keepalive := rrx.keepalive - 1;
      else
        v.count := rrx.count + 1;
      end if;

      case v.count is
      when 0 =>
         v.gmii_rxd   := v.gmii_rxd_int(3 downto 0) &  v.gmii_rxd_int(3 downto 0);
         v.gmii_rx_dv := v.gmii_dv;
      when 5 =>
        if gmiio.speed = '1' then
         v.gmii_rxd   := v.gmii_rxd_int(7 downto 4) &  v.gmii_rxd_int(7 downto 4);
         v.gmii_rx_dv := v.gmii_dv;
         v.gmii_dv    := '0';
        end if;
      when 50 =>
        if gmiio.speed = '0' then
         v.gmii_rxd   := v.gmii_rxd_int(7 downto 4) &  v.gmii_rxd_int(7 downto 4);
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
      if (not RESET_ALL) and (usr2rstn = '0') then
         v := RESRX;
      end if;

      -- update registers
      rinrx <= v;
   end process;

   rx100regs : process(userclk2)
   begin
     if rising_edge(userclk2) then
       rrx <= rinrx;
       if RESET_ALL and usr2rstn = '0' then
          rrx <= RESRX;
       end if;
     end if;
   end process;

   ---- 1000Mbit RX Logic (Bypass)
   -- n/a

   ---- RX Mux Select
   gmii_rxd   <= gmii_rxd_int    when (gmiio.gbit = '1') else rinrx.gmii_rxd;
   gmii_rx_dv <= gmii_rx_dv_int  when (gmiio.gbit = '1') else rinrx.gmii_rx_dv;
   gmii_rx_er <= gmii_rx_er_int  when (gmiio.gbit = '1') else rinrx.gmii_rx_er;

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
        status_vector_apb1 <= (others => '0');
        status_vector_apb2 <= (others => '0');
        -- Register to detect a speed change
        status_vector_apb1(15 downto 0) <= status_vector_apb;
        status_vector_apb2 <= status_vector_apb1;
     end if;
  end process;

  rgmiiapb : process(apb_rstn, r, apbi, status_vector_apb1, status_vector_apb2, RMemRgmiiiData, RMemRgmiiiRead, RMemRgmiioRead )
  variable rdata    : std_logic_vector(31 downto 0);
  variable paddress : std_logic_vector(7 downto 2);
  variable v        : sgmiiregs;
  begin

    v := r;
    paddress := (others => '0');
    paddress(abits-1 downto 2) := apbi.paddr(abits-1 downto 2);
    rdata := (others => '0');

    -- read/write registers

    if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
      case paddress(7 downto 2) is
      when "000000" =>
        rdata(31 downto 0) := status_vector_apb2;
      when "000001" =>
        rdata(31 downto 0) := r.irq;
        v.irq := (others => '0');  -- Interrupt is clear on read
      when "000010" =>
        rdata(31 downto 0) := r.mask;
      when "000011" =>
        rdata(4 downto 0) := r.configuration_vector;
      when "000100" =>
        rdata(15 downto 0) := r.an_adv_config_vector;
      when "000101" =>
        if (autonegotiation /= 0) then rdata(0) := '1'; else rdata(0) := '0'; end if;
        if (debugmem /= 0)        then rdata(1) := '1'; else rdata(1) := '0'; end if;
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
     if  ((status_vector_apb1(i) xor status_vector_apb2(i)) and v.mask(i)) = '1' then
       v.irq(i) :=  '1';
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
     apbo.prdata  <= (others => '0');
    elsif RMemRgmiiiRead = '1' then
     apbo.prdata(31 downto 16)  <= (others => '0');
     apbo.prdata(15 downto 0)   <= RMemRgmiiiData;
    elsif RMemRgmiioRead = '1' then
     apbo.prdata(31 downto 16)  <= (others => '0');
     apbo.prdata(15 downto 0)   <= RMemRgmiioData;
    else
     apbo.prdata  <= rdata;
    end if;

    apbo.pirq <= (others => '0');
    apbo.pirq(pirq) <=  orv(v.irq);

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
    process (userclk2)
    begin  -- process
      if rising_edge(userclk2) then
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

       if usr2rstn = '0' then
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
      userclk2, WMemRgmiioWrEn, WMemRgmiioAddr(10-1 downto 0), WMemRgmiioData);

    -- Write GMII IN data
    process (userclk2)
    begin  -- process
      if rising_edge(userclk2) then

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

       if usr2rstn = '0' then
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
      userclk2, WMemRgmiiiWrEn, WMemRgmiiiAddr(10-1 downto 0), WMemRgmiiiData);

  end generate;

-- pragma translate_off
    bootmsg : report_version
    generic map ("sgmii" & tost(pindex) &
        ": SGMII rev " & tost(REVISION) & ", irq " & tost(pirq));
-- pragma translate_on

end top_level;
