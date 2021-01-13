--------------------------------------------------------------------------------
-- Author     : Xilinx
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

---------------------------------------------------------------------------------------------
-- Device:              Ultrascale
-- Entity Name:         sgmii_vcu118_clock_reset
-- Purpose:             RX and TX PLL + all reset setup.
--
-- Calculation of the PLL parameters for RX and TX.
-- Input clock 625MHz.
-- PLL_CLK of RX side must run at 625MHz
-- PLL_CLK of TX side must run at 1250MHz.
--
-- XiPhy PLL frequency calculations
-- Component: UltraScale Kintex (-2)
--      Fin_min     = 70 MHz
--      Fin_max     = 933 MHz
--      Fvco_min    = 600 MHz
--      Fvco_max    = 1335 MHz
--      Fout_min    = 4.69 MHz (CLKOUTPHY = 600 MHz in VCO mode)
--      Fout_max    = 725 MHz  (CLKOUTPHY = 2670 MHz)
--      Fpfd_min    = 70 MHz
--      Fpfd_max    = 667.5 MHz
--
--      Dmin = rndup Fin/Fpfd_max               => 1 <==
--      Dmax = Rnddwn Fin/Fpfd_min              => 8
--      Mmin = rndup ((Fvco_min/Fin) * Dmin)    => 1
--      Mmax = rnddwn ((Dmax * Fvco_max)/Fin)   => 11
--      Mideal = (Dmin * Fvco_max) / Fin        => 1.4928 <==
--          Fvco must be maximized for best functioning of the VCO.
--          However, when the PLL is used with a BITSLICE_CONTROL block (XiPhy in native mode)
--          then the VCO must run at the frequency of the PLL_CLK input.
--          For TX the PLL_CLK frequency must be equal to the data rate of the serial output.
--          For RX the PLL_CLK frequency is 1/2 the serial data rate (DDR).
--          The PLL has a CLKOUTPHY_MODE parameter for the CLKOUTPHY frequency.
--              CLKOUTPHY_MODE can be: VCO_2X, VCO or VCO_HALF
--
--          If a transmitter must run at 1250Mbps then the PLL_CLK must be 1250MHz
--              Fvco is thus given, being:          1250MHz, 625MHz or 312.5MHz
--              The input clock is known, being:    625MHz.
--              The clock divider is known, being:  1
--          A PLL runs at its best when the VCO frequency is a high as possible.
--          Fvco_max = 1335MHz, then the VCO runs for this design best at 1250MHz.
--          Thus the multiply factor can be calculated from : Fvco = Fin * (M/D)
--                                           => M = 2 => Fvco = 1250MHz
--  TX
--          Fout = Fin * M/D*O
--                  Fout_Clk0  => D = 8    => 156.25 MHz    -- Tx_SysClk
--                  Fout_Clk1  => D = 10   => 125 MHz       -- Tx_Wr_CLK
--                  CLKOUTPHY  => VCO      => 1250 MHz      -- Tx_Pll_Clk
--  Rx
--          Fout = Fin * M/D*O
--                  Fout_Clk0  => D = 4    => 312.5 MHz     -- RxSysClk
--                  Fout_Clk1  => D = 8    => 156.25 MHz    -- Rx_RIU_CLK
--                  CLKOUTPHY  => VCO_HALF => 625 MHz       -- Rx_Pll_Clk
---------------------------------------------------------------------------------------------
--
-- XiPhy PLL frequency calculations
-- Component: UltraScale Kintex (-1)
--      Fin_min     = 70 MHz
--      Fin_max     = 800 MHz
--      Fvco_min    = 600 MHz
--      Fvco_max    = 1200 MHz
--      Fout_min    = 4.69 MHz (CLKOUTPHY = 600 MHz in VCO mode)
--      Fout_max    = 725 MHz  (CLKOUTPHY = 2400 MHz)
--      Fpfd_min    = 70 MHz
--      Fpfd_max    = 600 MHz
--
--      Dmin = rndup Fin/Fpfd_max               => 2 <==
--      Dmax = Rnddwn Fin/Fpfd_min              => 8
--      Mmin = rndup ((Fvco_min/Fin) * Dmin)    => 2
--      Mmax = rnddwn ((Dmax * Fvco_max)/Fin)   => 15.36
--      Mideal = (Dmin * Fvco_max) / Fin        => 3.84 <==
--          Fvco must be maximized for best functioning of the VCO.
--          However, when the PLL is used with a BITSLICE_CONTROL block (XiPhy in native mode)
--          then the VCO must run at the frequency of the PLL_CLK input.
--          For TX the PLL_CLK frequency must be equal to the data rate of the serial output.
--          For RX the PLL_CLK frequency is 1/2 the serial data rate (DDR).
--          The PLL has a CLKOUTPHY_MODE parameter for the CLKOUTPHY frequency.
--              CLKOUTPHY_MODE can be: VCO_2X, VCO or VCO_HALF
--
--          If a transmitter must run at 1250Mbps then the PLL_CLK must be 1250MHz
--              Fvco is thus given, being:          1250MHz, 625MHz or 312.5MHz
--              The input clock is known, being:    625MHz.
--              The clock divider is known, being:  2
--          A PLL runs at its best when the VCO frequency is a high as possible.
--          Fvco_max = 1200MHz, then the VCO runs for this design best at 625MHz.
--          Thus the multiply factor can be calculated from : Fvco = Fin * (M/D)
--                                           => M = 2 => Fvco = 625Hz
--  TX
--          Fout = Fin * M/D*O
--                  Fout_Clk0  => D = 8    => 156.25 MHz    -- Tx_SysClk
--                  Fout_Clk1  => D = 10   => 125 MHz       -- Tx_Wr_CLK
--                  CLKOUTPHY  => VCO_2X   => 1250 MHz      -- Tx_Pll_Clk
--  Rx
--          Fout = Fin * M/D*O
--                  Fout_Clk0  => D = 2    => 312.5 MHz     -- RxSysClk
--                  Fout_Clk1  => D = 4    => 156.25 MHz    -- Rx_RIU_CLK
--                  CLKOUTPHY  => VCO      => 625 MHz       -- Rx_Pll_Clk
--
--  This design has an add RIU write port.
--      The RIU write port is used to generate an extra reset sequence for the transmitter (TX_BITSLICEs).
--      In the original 1000BaseX/SGMII design the RIU port is already used to write information to the
--      the receiver (RX_BITSLICEs). Transmitter and receiver occupy the same byte (Transmitter placed
--      in upper nibble and receiver place in lower nibble) and two different state machines writing the
--      combined RIU of two nibble in a byte is difficult, Therefore the original RIU writing state machine
--      (From:\Libraries\BaseX_Logic\BaseX_Rx\Verilog\Rx_OneToTen.v) is not used any more and its function
--      is incorporated in this state machine.
--
--      Two PLL are used (one for TX and one for RX) and also two reset sequencers are used.
--      The RIU state machine is originally developed inside the reset sequencer, but that setup cannot be used
--      in this design case.
--      Why:
--          TX occupies the upper nibble of a byte
--          RX occupies the lower nibble of that byte
--          TX uses the RIU of the BITSLICE_CONTROL in its nibble.
--          RX used the RIU of the BITSLICE_CONTROL in its nibble.
--          Because both BITSLICE_CONTROL in a byte use the RIU interface, both RIU are combined into a single RIU.
--
--          Normally each reset sequencer accesses a RIU, but in this case this setup makes it difficult to
--          achieve this goal. Therefore the state machine writing to the RUI is lifted from the reset sequencer
--          and implemented on this level.
--          Due to that, the original state machine has got some modifications.
--              The part writing to the transmitter reset registers already start hen the TX reset sequencer finished.
--              The part writing to the receiver can start when the receiver reset sequencer is done and the TX RIU
--              reset registers are written.
--
--  Design files used:
--
-- Tools:               Vivado_2015.1
-- Limitations:         none
--
-- Vendor:              Xilinx Inc.
-- Version:             0.01
-- Filename:            sgmii_vcu118_clock_reset.vhd
-- Date Created:        Mar 2015
-- Date Last Modified:  Feb 2016
---------------------------------------------------------------------------------------------
-- Revision History:
--  Rev. 27 Jul 2015
--      Addition of a RIU write port.
--      For explication read above.
--
--  Rev 2.0 01-13-2016 - Ed McGettigan
--      Added Tx_Bsc_EnVtc, Tx_Bs_EnVtc ports
--      Added Rx_Bsc_EnVtc, Rx_Bs_EnVtc ports
--      Rename "Btslc" ports to "Bs" ports
--      Rename "BtslceCtrl" ports to "Bsc" ports
--      Changed single RIU Rd_Data and Valid ports with 4 ports
--      Added Rx_BtVal_0:3 ports
--      Changed RIU clock to be always active from ClkIn
--      Combined seperate Tx and Rx delay machines into single state machine
--      Added RIU read for calibrate BTVAL
--
--  Rev 2.0 02-05-2016 - Ed McGettigan
--      Added Debug_Out
--      Added In_Simulation functionality for Rx_BtVal
--
---------------------------------------------------------------------------------------------
-- Naming Conventions:
--  Generics start with:                                    "C_*"
--  Ports
--      All words in the label of a port name start with a upper case, AnInputPort.
--      Active low ports end in                             "*_n"
--      Active high ports of a differential pair end in:    "*_p"
--      Ports being device pins end in _pin                 "*_pin"
--      Reset ports end in:                                 "*Rst"
--      Enable ports end in:                                "*Ena", "*En"
--      Clock ports end in:                                 "*Clk", "ClkDiv", "*Clk#"
--  Signals and constants
--      Signals and constant labels start with              "Int*"
--      Registered signals end in                           "_d#"
--      User defined types:                                 "*_TYPE"
--      State machine next state:                           "*_Ns"
--      State machine current state:                        "*_Cs"
--      Counter signals end in:                             "*Cnt", "*Cnt_n"
--   Processes:                                 "<Entity_><Function>_PROCESS"
--   Component instantiations:                  "<Entity>_I_<Component>_<Function>"
---------------------------------------------------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_UNSIGNED.all;
    use IEEE.std_logic_arith.all;
library UNISIM;
    use UNISIM.vcomponents.all;

---------------------------------------------------------------------------------------------
-- Entity pin description
---------------------------------------------------------------------------------------------
entity sgmii_vcu118_clock_reset is
    generic (
        C_Part                      : string  := "XCKU060";
        EXAMPLE_SIMULATION          : boolean := false;
        C_IoBank                    : integer := 44
    );
    port (
        ClockIn_p           : in std_logic;
        ClockIn_n           : in std_logic;
        ClockIn_se_out      : out std_logic;
        ResetIn             : in std_logic;
        Tx_Dly_Rdy          : in std_logic;
        Tx_Vtc_Rdy          : in std_logic;
        Tx_Bsc_EnVtc       : out std_logic;
        Tx_Bs_EnVtc        : out std_logic;
        Rx_Dly_Rdy          : in std_logic;
        Rx_Vtc_Rdy          : in std_logic;
        Rx_Bsc_EnVtc       : out std_logic;
        Rx_Bs_EnVtc        : out std_logic;
        --
        Tx_SysClk           : out std_logic;    --  156.25 MHz
        Tx_WrClk            : out std_logic;    --  125.00 MHz
        Tx_ClkOutPhy        : out std_logic;    -- 1250.00 MHz
        Rx_SysClk           : out std_logic;    --  312.50 MHz
        Rx_RiuClk           : out std_logic;    --  156.25 MHz
        Rx_ClkOutPhy        : out std_logic;    --  625.00 MHz
        --
        Tx_Locked           : out std_logic;
        Tx_Bs_RstDly        : out std_logic;
        Tx_Bs_Rst           : out std_logic;
        Tx_Bsc_Rst          : out std_logic;
        Tx_LogicRst         : out std_logic;
        Rx_Locked           : out std_logic;
        Rx_Bs_RstDly        : out std_logic;
        Rx_Bs_Rst           : out std_logic;
        Rx_Bsc_Rst          : out std_logic;
        Rx_LogicRst         : out std_logic;
        --
        Riu_Addr            : out std_logic_vector(5 downto 0);
        Riu_WrData          : out std_logic_vector(15 downto 0);
        Riu_Wr_En           : out std_logic;
        Riu_Nibble_Sel      : out std_logic_vector(1 downto 0);
        Riu_RdData_3        : in std_logic_vector(15 downto 0);
        Riu_Valid_3         : in std_logic;
        Riu_Prsnt_3         : in std_logic;
        Riu_RdData_2        : in std_logic_vector(15 downto 0);
        Riu_Valid_2         : in std_logic;
        Riu_Prsnt_2         : in std_logic;
        Riu_RdData_1        : in std_logic_vector(15 downto 0);
        Riu_Valid_1         : in std_logic;
        Riu_Prsnt_1         : in std_logic;
        Riu_RdData_0        : in std_logic_vector(15 downto 0);
        Riu_Valid_0         : in std_logic;
        Riu_Prsnt_0         : in std_logic;
        --
        Rx_BtVal_3          : out std_logic_vector(8 downto 0);
        Rx_BtVal_2          : out std_logic_vector(8 downto 0);
        Rx_BtVal_1          : out std_logic_vector(8 downto 0);
        Rx_BtVal_0          : out std_logic_vector(8 downto 0);
        --
        Debug_Out           : out std_logic_vector(7 downto 0)
    );
end sgmii_vcu118_clock_reset;
---------------------------------------------------------------------------------------------
-- Architecture section
---------------------------------------------------------------------------------------------
architecture Clock_Reset_arch of sgmii_vcu118_clock_reset is
---------------------------------------------------------------------------------------------
-- Component Instantiation
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
---------------------------------------------------------------------------------------------
-- Functions
-- Constants
constant Low  : std_logic	:= '0';
constant LowVec : std_logic_vector(15 downto 0) := X"0000";
constant High : std_logic	:= '1';

--
-- Flag to determine Simulation vs Synthesis
--
constant In_Simulation : boolean := false or EXAMPLE_SIMULATION
--synthesis translate_off
                                    or true
--synthesis translate_on
;

component sgmii_vcu118_reset_sync

port (
   reset_in             : in  std_logic;
   clk                  : in  std_logic;
   reset_out            : out std_logic
);
end component;

-- Signals
signal IntTx_FdbckClkIn         : std_logic;
signal IntTx_FdbckClkOut        : std_logic;
signal IntTx_ClkOut0            : std_logic;
signal IntTx_ClkOut1            : std_logic;
signal IntTx_Locked             : std_logic;
signal IntTx_SysClk             : std_logic;
signal IntTx_WrClk              : std_logic;
signal IntTx_DlySeqClk          : std_logic;
signal IntRx_FdbckClkIn         : std_logic;
signal IntRx_FdbckClkOut        : std_logic;
signal IntRx_ClkOut0            : std_logic;
signal IntRx_ClkOut1            : std_logic;
signal IntRx_Locked             : std_logic;
signal IntRx_SysClk             : std_logic;
signal IntRx_RiuClk             : std_logic;
signal IntRx_DlySeqClk          : std_logic;
signal IntTx_DlyVtc_Rdy         : std_logic;
signal IntRx_DlyVtc_Rdy         : std_logic;
signal IntTx_EnaClkBufs         : std_logic;
signal IntRx_EnaClkBufs         : std_logic;
signal IntTx_LogicRst           : std_logic;
signal IntRx_LogicRst           : std_logic;
--
signal IntRx_DlyFivOut          : std_logic;
signal IntTx_DlyFivOut          : std_logic;
--
signal IntCtrl_Clk              : std_logic;
signal IntCtrl_State            : integer range 0 to 511 := 0;
signal IntCtrl_Reset            : std_logic;
signal IntCtrl_TxLocked         : std_logic_vector(1 downto 0);
signal IntCtrl_TxDlyRdy         : std_logic_vector(1 downto 0);
signal IntCtrl_TxVtcRdy         : std_logic_vector(1 downto 0);
signal IntCtrl_TxPllRst         : std_logic;
signal IntCtrl_TxPllClkOutPhyEn : std_logic;
signal IntCtrl_TxLogicRst       : std_logic;
signal IntCtrl_RxLocked         : std_logic_vector(1 downto 0);
signal IntCtrl_RxDlyRdy         : std_logic_vector(1 downto 0);
signal IntCtrl_RxVtcRdy         : std_logic_vector(1 downto 0);
signal IntCtrl_RxPllRst         : std_logic;
signal IntCtrl_RxPllClkOutPhyEn : std_logic;
signal IntCtrl_RxLogicRst       : std_logic;

signal ClockIn                  : std_logic;
-- Attributes
attribute ASYNC_REG : string;
    attribute ASYNC_REG of IntCtrl_TxLocked  : signal is "TRUE";
    attribute ASYNC_REG of IntCtrl_TxDlyRdy  : signal is "TRUE";
    attribute ASYNC_REG of IntCtrl_TxVtcRdy  : signal is "TRUE";
    attribute ASYNC_REG of IntCtrl_RxLocked  : signal is "TRUE";
    attribute ASYNC_REG of IntCtrl_RxDlyRdy  : signal is "TRUE";
    attribute ASYNC_REG of IntCtrl_RxVtcRdy  : signal is "TRUE";
attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of Clock_Reset_arch : architecture is "YES";
--attribute LOC : string;
--    attribute LOC of Clk_Rst_I_Plle3_Tx : label is
--    "PLLE3_ADV_X" & integer'image(Calc_RiuOrX(C_IoBank, C_Part)) & "Y" & integer'image(Calc_PllY(C_IoBank));
--    --
--    attribute LOC of Clk_Rst_I_Plle3_Rx : label is
--    "PLLE3_ADV_X" & integer'image(Calc_RiuOrX(C_IoBank, C_Part)) & "Y" & integer'image((Calc_PllY(C_IoBank))+1);
---------------------------------------------------------------------------------------------
begin


iclkbuf : IBUFGDS
generic map(
      IBUF_LOW_PWR => FALSE
)
port map (
  I  => ClockIn_p,
  IB => ClockIn_n,
  O  => ClockIn
);
--
---------------------------------------------------------------------------------------------
-- Control Clock - Free Running RIU CLOCK
---------------------------------------------------------------------------------------------
Bufg_CtrlClk : BUFGCE_DIV
    generic map (BUFGCE_DIVIDE => 4, IS_CE_INVERTED => '0', IS_I_INVERTED  => '0', IS_CLR_INVERTED => '0')
    port map (I => ClockIn, CE => '1', CLR => '0', O  => IntCtrl_Clk);
---------------------------------------------------------------------------------------------
-- TX PLL
---------------------------------------------------------------------------------------------
Clk_Rst_I_Plle3_Tx : PLLE3_ADV
    generic map (
        CLKFBOUT_PHASE      => 0.000,       -- real
        CLKFBOUT_MULT       => 2,
        CLKIN_PERIOD        => 1.60,        -- real
        CLKOUTPHY_MODE      => "VCO",       -- string
        CLKOUT0_DIVIDE      => 8,           -- integer
        CLKOUT1_DIVIDE      => 10,          -- integer
        DIVCLK_DIVIDE       => 1,           -- integer

        CLKOUT0_DUTY_CYCLE  => 0.500,       -- real
        CLKOUT0_PHASE       => 0.000,       -- real
        CLKOUT1_DUTY_CYCLE  => 0.500,       -- real
        CLKOUT1_PHASE       => 0.000,       -- real

        COMPENSATION        => "AUTO",      -- string
        IS_CLKFBIN_INVERTED => '0',         -- std_ulogic
        IS_CLKIN_INVERTED   => '0',         -- std_ulogic
        IS_PWRDWN_INVERTED  => '0',         -- std_ulogic
        IS_RST_INVERTED     => '0',         -- std_ulogic
        REF_JITTER          => 0.010,       -- real
        STARTUP_WAIT        => "FALSE"      -- string
    )
    port map (
        CLKIN       => ClockIn, -- in
        CLKFBIN     => IntTx_FdbckClkIn, -- in
        RST         => IntCtrl_TxPllRst, -- in
        PWRDWN      => Low, -- in
        CLKOUTPHYEN => IntCtrl_TxPllClkOutPhyEn, -- in
        CLKFBOUT    => IntTx_FdbckClkOut, -- out
        CLKOUT0     => IntTx_ClkOut0, -- out
        CLKOUT0B    => open, -- out
        CLKOUT1     => IntTx_ClkOut1, -- out
        CLKOUT1B    => open, -- out
        CLKOUTPHY   => Tx_ClkOutPhy, -- out
        DCLK        => Low, -- in
        DI          => LowVec(15 downto 0), -- in [15:0]
        DADDR       => lowVec(6 downto 0), -- in [6:0]
        DEN         => Low, -- in
        DWE         => Low, -- in
        DO          => open, -- out [15:0]
        DRDY        => open, -- out
        LOCKED      => IntTx_Locked -- out
    );
--
IntTx_FdbckClkIn <= IntTx_FdbckClkOut;

---------------------------------------------------------------------------------------------
-- TX Clock Buffers
---------------------------------------------------------------------------------------------
Clk_Rst_I_Bufg_TxSysClk : BUFGCE
    generic map (CE_TYPE => "SYNC", IS_CE_INVERTED => '0', IS_I_INVERTED  => '0')
    port map (I => IntTx_ClkOut0, CE => IntTx_Locked, O  => IntTx_SysClk);
Clk_Rst_I_Bufg_TxWrClk : BUFGCE
    generic map (CE_TYPE => "SYNC", IS_CE_INVERTED => '0', IS_I_INVERTED  => '0')
    port map (I => IntTx_ClkOut1, CE => IntTx_Locked, O  => IntTx_WrClk);

---------------------------------------------------------------------------------------------
-- TX Output Port Assignments
---------------------------------------------------------------------------------------------
Tx_SysClk         <= IntTx_SysClk;
Tx_WrClk          <= IntTx_WrClk;
Tx_Locked         <= IntTx_Locked;

---------------------------------------------------------------------------------------------
-- RX PLL
---------------------------------------------------------------------------------------------
Clk_Rst_I_Plle3_Rx : PLLE3_ADV
    generic map (
        CLKFBOUT_PHASE      => 0.000,       -- real
        CLKOUT0_DUTY_CYCLE  => 0.500,       -- real
        CLKOUT0_PHASE       => 0.000,       -- real
        CLKOUT1_DUTY_CYCLE  => 0.500,       -- real
        CLKOUT1_PHASE       => 0.000,       -- real
        CLKIN_PERIOD        => 1.60,        -- real
        CLKFBOUT_MULT       => 2,           -- integer
        CLKOUTPHY_MODE      => "VCO_HALF",  -- string
        CLKOUT0_DIVIDE      => 4,           -- integer
        CLKOUT1_DIVIDE      => 8,           -- integer
        DIVCLK_DIVIDE       => 1,           -- integer


        COMPENSATION        => "AUTO",      -- string
        IS_CLKFBIN_INVERTED => '0',         -- std_ulogic
        IS_CLKIN_INVERTED   => '0',         -- std_ulogic
        IS_PWRDWN_INVERTED  => '0',         -- std_ulogic
        IS_RST_INVERTED     => '0',         -- std_ulogic
        REF_JITTER          => 0.010,       -- real
        STARTUP_WAIT        => "FALSE"      -- string
    )
    port map (
        CLKIN       => ClockIn, -- in
        CLKFBIN     => IntRx_FdbckClkIn, -- in
        RST         => ResetIn, -- in
        PWRDWN      => Low, -- in
        CLKOUTPHYEN => IntCtrl_RxPllClkOutPhyEn, -- in
        CLKFBOUT    => IntRx_FdbckClkOut, -- out
        CLKOUT0     => IntRx_ClkOut0, -- out
        CLKOUT0B    => open, -- out
        CLKOUT1     => IntRx_ClkOut1, -- out
        CLKOUT1B    => open, -- out
        CLKOUTPHY   => Rx_ClkOutPhy, -- out
        DCLK        => Low, -- in
        DI          => LowVec(15 downto 0), -- in [15:0]
        DADDR       => lowVec(6 downto 0), -- in [6:0]
        DEN         => Low, -- in
        DWE         => Low, -- in
        DO          => open, -- out [15:0]
        DRDY        => open, -- out
        LOCKED      => IntRx_Locked -- out
    );

IntRx_FdbckClkIn  <= IntRx_FdbckClkOut;
ClockIn_se_out    <= ClockIn;

---------------------------------------------------------------------------------------------
-- RX Clock Buffers
---------------------------------------------------------------------------------------------
Clk_Rst_I_Bufg_RxSysClk : BUFGCE
    generic map (CE_TYPE => "SYNC", IS_CE_INVERTED => '0', IS_I_INVERTED  => '0')
    port map (I => IntRx_ClkOut0, CE => IntRx_Locked, O  => IntRx_SysClk);

---------------------------------------------------------------------------------------------
-- RX Output Port Assignments
---------------------------------------------------------------------------------------------
Rx_SysClk         <= IntRx_SysClk;
Rx_RiuClk         <= IntCtrl_Clk;
Rx_Locked         <= IntRx_Locked;


---------------------------------------------------------------------------------------------
-- Control CDC Synchronizers
---------------------------------------------------------------------------------------------




reset_sync_tx_cdc_rst : sgmii_vcu118_reset_sync
port map(
   clk               => IntTx_WrClk,
   reset_in          => IntCtrl_TxLogicRst,
   reset_out         => IntTx_LogicRst
);
Tx_LogicRst <= IntTx_LogicRst;


reset_sync_rx_cdc_rst : sgmii_vcu118_reset_sync
port map(
   clk               => IntRx_SysClk,
   reset_in          => IntCtrl_RxLogicRst,
   reset_out         => IntRx_LogicRst
);
Rx_LogicRst <= IntRx_LogicRst;

reset_sync_ctrl_rst : sgmii_vcu118_reset_sync
port map(
   clk               => IntCtrl_Clk,
   reset_in          => ResetIn,
   reset_out         => IntCtrl_Reset
);
Ctrl_CDC_Gen : process (IntCtrl_Clk)
begin
    if (rising_edge(IntCtrl_Clk)) then
        IntCtrl_TxLocked(1 downto 0) <= (IntCtrl_TxLocked(0 downto 0) & IntTx_Locked);
        IntCtrl_TxDlyRdy(1 downto 0) <= (IntCtrl_TxDlyRdy(0 downto 0) & Tx_Dly_Rdy);
        IntCtrl_TxVtcRdy(1 downto 0) <= (IntCtrl_TxVtcRdy(0 downto 0) & Tx_Vtc_Rdy);
        IntCtrl_RxLocked(1 downto 0) <= (IntCtrl_RxLocked(0 downto 0) & IntRx_Locked);
        IntCtrl_RxDlyRdy(1 downto 0) <= (IntCtrl_RxDlyRdy(0 downto 0) & Rx_Dly_Rdy);
        IntCtrl_RxVtcRdy(1 downto 0) <= (IntCtrl_RxVtcRdy(0 downto 0) & Rx_Vtc_Rdy);
    end if;
end process;

---------------------------------------------------------------------------------------------
-- Control State Machine
---------------------------------------------------------------------------------------------

Ctrl_SM : process (IntCtrl_Clk)
begin
   if (rising_edge(IntCtrl_Clk)) then
      if (IntCtrl_Reset = '1') then
         IntCtrl_State  <= 0;
         --
         Riu_Addr         <= "000000";
         Riu_WrData       <=x"0000";
         Riu_Wr_En        <= '0';
         Riu_Nibble_sel   <= "00";
         --
         Tx_Bsc_EnVtc     <= '0';
         Tx_Bsc_Rst       <= '1';
         Tx_Bs_EnVtc      <= '1';
         Tx_Bs_RstDly     <= '1';
         Tx_Bs_Rst        <= '1';
         IntCtrl_TxLogicRst       <= '1';
         IntCtrl_TxPllClkOutPhyEn <= '0';
         IntCtrl_TxPllRst <= '0';
         --
         Rx_Bsc_EnVtc     <= '0';
         Rx_Bsc_Rst       <= '1';
         Rx_Bs_EnVtc      <= '1';
         Rx_Bs_RstDly     <= '1';
         Rx_Bs_Rst        <= '1';
         IntCtrl_RxLogicRst       <= '1';
         IntCtrl_RxPllClkOutPhyEn <= '0';
         IntCtrl_RxPllRst <= '0';
         --
         Rx_BtVal_3     <= (others => '0');
         Rx_BtVal_2     <= (others => '0');
         Rx_BtVal_1     <= (others => '0');
         Rx_BtVal_0     <= (others => '0');
      else
         case (IntCtrl_State) is
            when  0 =>    -- Reset Seq Step 1
                 Tx_Bs_EnVtc <= '1';
                 Rx_Bs_EnVtc <= '1';
                 IntCtrl_State <= IntCtrl_State + 1;
            when  4 =>    -- Reset Seq Step 2
                 -- BITSLICE_CONTROL.SELF_CALIBRATE = ENABLE
                 IntCtrl_State <= IntCtrl_State + 1;
            when  8 =>    -- Reset Seq Step 3
                 IntCtrl_TxPllRst   <= '1';
                 IntCtrl_RxPllRst   <= '1';
                 IntCtrl_State <= IntCtrl_State + 1;
            when 16 =>    -- Reset Seq Step 4
                 Tx_Bs_Rst    <= '1';
                 Tx_Bs_RstDly <= '1';
                 Tx_Bsc_Rst   <= '1';
                 Rx_Bs_Rst    <= '1';
                 Rx_Bs_RstDly <= '1';
                 Rx_Bsc_Rst   <= '1';
                 IntCtrl_State <= IntCtrl_State + 1;
            when 20 =>    -- Reset Seq Step 5/6
                 IntCtrl_TxPllRst   <= '0';
                 IntCtrl_RxPllRst   <= '0';
                 IntCtrl_State <= IntCtrl_State + 1;
            when 24 =>    -- Reset Seq Step 7
                 if (IntCtrl_TxLocked(1) = '1' AND IntCtrl_RxLocked(1) = '1') then
                    IntCtrl_State <= IntCtrl_State + 1;
                 end if;
            when 56 =>     -- Reset Seq Step  8 -- Wait 32 Cycles
                 Tx_Bs_RstDly <= '0';
                 Rx_Bs_RstDly <= '0';
                 IntCtrl_State <= IntCtrl_State + 1;
            when 60 =>     -- Reset Seq Step  8 -- Wait  4 Cycles
                 Tx_Bs_Rst   <= '0';
                 Rx_Bs_Rst   <= '0';
                 IntCtrl_State <= IntCtrl_State + 1;
            when 64 =>     -- Reset Seq Step  8 -- Wait  4 Cycles
                 Tx_Bsc_Rst  <= '0';
                 Rx_Bsc_Rst  <= '0';
                 IntCtrl_State <= IntCtrl_State + 1;
            when 128 =>    -- Reset Seq Step  9 -- Wait 64 Cycles
                 IntCtrl_TxPllClkOutPhyEn <= '1';
                 IntCtrl_RxPllClkOutPhyEn <= '1';
                 IntCtrl_State <= IntCtrl_State + 1;
            when 172 =>    -- Post Reset Seq Step 1 -- Wait 64 Cycles
                 if (IntCtrl_TxDlyRdy(1) = '1' AND IntCtrl_RxDlyRdy(1) = '1' ) then
                   Tx_Bsc_EnVtc <= '1';
                   Rx_Bsc_EnVtc <= '0';
                   IntCtrl_State<= IntCtrl_State + 1;
                 end if;
            when 176 =>    -- Post Reset Seq Step 3 -- Wait 4 Cycles
                 if (IntCtrl_TxVtcRdy(1) = '1') then
                   IntCtrl_State<= IntCtrl_State + 1;
                 end if;
            when 180 =>    -- Post Reset Seq Step   -- Wait 4 Cycles
                 Riu_Addr       <= "000010"; -- Addr 0x02 - CALIB_CTRL
                 Riu_WrData     <=x"0000";
                 Riu_Wr_En      <= '0'; -- Don't Write
                 Riu_Nibble_sel <= "01";
                 IntCtrl_TxLogicRst <= '0';
                 IntCtrl_State <= IntCtrl_State + 1;
            when 181 =>    -- BISC Read Calibration Register
                 Riu_Addr       <= "000010"; -- Addr 0x02 - CALIB_CTRL
                 Riu_WrData     <=x"0000";
                 Riu_Wr_En      <= '0'; -- Don't Write
                 Riu_Nibble_sel <= "01";
                 --
                 -- Wait for FIXDLY_RDY
                 --
                 if ((Riu_RdData_3(11) = '1' OR Riu_Prsnt_3 = '0') AND (Riu_RdData_2(11) = '1' or Riu_Prsnt_2 = '0') AND
                     (Riu_RdData_1(11) = '1' OR Riu_Prsnt_1 = '0') AND (Riu_RdData_0(11) = '1' or Riu_Prsnt_0 = '0')) then
                     Rx_Bsc_EnVtc  <= '0';
                     Rx_Bs_EnVtc   <= '0';
                     IntCtrl_State <= IntCtrl_State + 1;
                 end if;
            when 182 =>    -- BISC Write to Debug Index
                 Riu_Addr       <= "111000"; -- Addr 0x38 - DBG_RW_INDEX
                 Riu_WrData     <=x"000C";  -- Write=0, Read=12
                 Riu_Wr_En      <= '1';
                 Riu_Nibble_sel <= "01";
                 IntCtrl_State  <= IntCtrl_State + 1;
            when 186 =>    -- BISC Wait 4 cyles then Pre-read HALFT_DQSM data
                 Riu_Addr       <= "111001"; -- Addr 0x39 - DBG_RD_STATUS
                 Riu_WrData     <=x"0000";   -- 8'h00, 8'h00
                 Riu_Wr_En      <= '0';
                 Riu_Nibble_sel <= "01";
                 IntCtrl_State  <= IntCtrl_State + 1;
            when 187 =>    -- BISC Read data and wait for valid HALFT_DQSM data
                 Riu_Addr       <= "111001"; -- Addr 0x39 - DBG_RD_STATUS
                 Riu_WrData     <=x"0000";   -- 8'h00, 8'h00
                 Riu_Wr_En      <= '0';
                 Riu_Nibble_sel <= "01";
                 if ((Riu_RdData_3 /= "00000000000" OR Riu_Prsnt_3 = '0') AND
                     (Riu_RdData_2 /= "00000000000" OR Riu_Prsnt_2 = '0') AND
                     (Riu_RdData_1 /= "00000000000" OR Riu_Prsnt_1 = '0') AND
                     (Riu_RdData_0 /= "00000000000" OR Riu_Prsnt_0 = '0')) then
                     Rx_BtVal_3     <= Riu_RdData_3(9 downto 1);  -- Divide by two for DDR Clock
                     Rx_BtVal_2     <= Riu_RdData_2(9 downto 1);
                     Rx_BtVal_1     <= Riu_RdData_1(9 downto 1);
                     Rx_BtVal_0     <= Riu_RdData_0(9 downto 1);
                     IntCtrl_State  <= IntCtrl_State + 1;
                 elsif (In_Simulation ) then
                     --
                     -- Simulation behavioral model of BITSLICE_CONTROL does not support
                     -- read of the self calibrated tap value stored in HALFT_DQSM
                     --
                     Rx_BtVal_3     <= "010100000";  -- 160
                     Rx_BtVal_2     <= "010100000";  -- 160
                     Rx_BtVal_1     <= "010100000";  -- 160
                     Rx_BtVal_0     <= "010100000";  -- 160
                     IntCtrl_State  <= IntCtrl_State + 1;
                 end if;
            when 188 =>    -- Rx PLL CLKOUTPHY Deassert
                 Riu_Addr       <= "000000"; -- Addr 0x00 - Default
                 Riu_WrData     <=x"0000";  -- 8'h00, 8'00
                 Riu_Wr_En      <= '0';
                 Riu_Nibble_sel <= "00";
                 IntCtrl_RxPllClkOutPhyEn <= '0';
                 IntCtrl_State            <= IntCtrl_State + 1;
            when 252 =>   --  RX BitSlice Reset Assert - Wait 64 Cycles
                 Rx_Bs_Rst      <= '1';
                 IntCtrl_State  <= IntCtrl_State + 1;
            when 316 =>   --  RX BitSlice Reset Deassert - Wait 64 Cycles
                 Rx_Bs_Rst      <= '0';
                 IntCtrl_State  <= IntCtrl_State + 1;
            when 380 =>   -- Rx PLL CLKOUTPHY Assert - Wait 64 Cyles
                 IntCtrl_RxPllClkOutPhyEn <= '1';
                 IntCtrl_State            <= IntCtrl_State + 1;
            when 511 =>   -- Rx LogicReset Deassert - Wait 131 Cycles
                 IntCtrl_RxLogicRst <= '0';
                 IntCtrl_State      <= 511;   -- Stall State
            when others =>
                 Riu_Addr       <= "000000";  -- Addr 0x00 - Default
                 Riu_WrData     <=x"0000";  -- 8'h00, 8'00
                 Riu_Wr_En      <= '0';
                 Riu_Nibble_sel <= "00";
                 IntCtrl_State  <= IntCtrl_State + 1;
         end case;
      end if;
   end if;
end process;
---------------------------------------------------------------------------------------------
Debug_Out <= conv_std_logic_vector(IntCtrl_State,8);
end Clock_Reset_arch;
--
