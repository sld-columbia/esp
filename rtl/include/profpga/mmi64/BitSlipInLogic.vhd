---------------------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/    � Copyright 2014 Xilinx, Inc. All rights reserved.
--  \   \        This file contains confidential and proprietary information of Xilinx, Inc.
--  /   /        and is protected under U.S. and international copyright and other
-- /___/   /\    intellectual property laws.
-- \   \  /  \
--  \___\/\___\
--
---------------------------------------------------------------------------------------------
-- Device:              UltraScale, 7-Series
-- Author:              Defossez
-- Entity Name:         BitSlipInLogic
-- Purpose:             Perform bitslip operations on parallel data.
--                      Extended functionality of native Virtex and 7-Series bitslip.
-- Tools:               Vivado_2014.1 or newer
-- Limitations:         none
--
-- Vendor:              Xilinx Inc.
-- Version:             V0.01
-- Filename:            BitSlipInLogic.vhd
-- Date Created:        5 Dec 2014
-- Date Last Modified:  May 2014
---------------------------------------------------------------------------------------------
-- Disclaimer:
--		This disclaimer is not a license and does not grant any rights to the materials
--		distributed herewith. Except as otherwise provided in a valid license issued to you
--		by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE MATERIALS
--		ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL
--		WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED
--		TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR
--		PURPOSE; and (2) Xilinx shall not be liable (whether in contract or tort, including
--		negligence, or under any other theory of liability) for any loss or damage of any
--		kind or nature related to, arising under or in connection with these materials,
--		including for any direct, or any indirect, special, incidental, or consequential
--		loss or damage (including loss of data, profits, goodwill, or any type of loss or
--		damage suffered as a result of any action brought by a third party) even if such
--		damage or loss was reasonably foreseeable or Xilinx had been advised of the
--		possibility of the same.
--
-- CRITICAL APPLICATIONS
--		Xilinx products are not designed or intended to be fail-safe, or for use in any
--		application requiring fail-safe performance, such as life-support or safety devices
--		or systems, Class III medical devices, nuclear facilities, applications related to
--		the deployment of airbags, or any other applications that could lead to death,
--		personal injury, or severe property or environmental damage (individually and
--		collectively, "Critical Applications"). Customer assumes the sole risk and
--		liability of any use of Xilinx products in Critical Applications, subject only to
--		applicable laws and regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
-- Contact:    e-mail  hotline@xilinx.com        phone   + 1 800 255 7778
---------------------------------------------------------------------------------------------
-- Revision History:
--  Rev. May 2014
--  Checked simulations and implementation.
--  Reorganise design to fit Olympus and UltraScale, 7-Series XiPhy / ISERDES.
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
---------------------------------------------------------------------------------------------
-- Entity pin description
-- View also PDF documentation in the /Documents Folder
--  GENERICS / ATTRIBUTES
--  C_Function      :   "Slip" = Normal bitslip. One bit at a time when C_PulsedSlip is 1,
--                  :            else bitslip will happen as long as the BitSlip_Pin is high.
--                  :   "Nmbr" = Perform the given amount of bitslips.
--                  :   "Comp" = Compare. Auto bitslip until the given value is detected.
--                  :   "FstC" = Fast Compare. Different (Low latency) implementation of the 
--                  :            compare bitslip solution.
--  C_DataWidth     :   8, 4
--  C_PulsedSlip    :   If set to 1, bitslip is reduced to a clock period.
--                  :   Leave this at '1', unless you are sure that bitslip given by an
--                  :   application is not longer than one Clk_pin cycle.
--  C_ErrOut        :   1 = ErrOut pin available.
--  C_InputReg      :   0 = No. Provide an extra input register for the module.
--
--  INPUT / OUTPUT PINS
--  DataIn_pin      :   in : Data input 4 or 8-bit wide.
--  Bitslip_pin     :   in : Perform bitslip when high
--  SlipVal_pin     :   in : Given number of bitslips. For 8-bit this is a 3-bit binary value.
--                  :        For 4-bit this is a 2-bit binary value (Pull MSB bit low)
--  CompVal_pin     :   in : Provided value to compare the input data against.
--  Ena_pin         :   in 
--  Rst_pin         :   in 
--  Clk_pin         :   in 
--  DataOut_pin     :   out 4-bit or 8-bit output data.
--  ErrOut_pin      :   out Error or status depending on C_Function.
---------------------------------------------------------------------------------------------
entity BitSlipInLogic is
    generic (
        C_DataWidth     : integer   := 8;       -- 8, 4
        C_InputReg      : integer   := 0        -- 0, No, 1 = Yes
    );
    port (
        DataIn_pin      : in std_logic_vector(C_DataWidth-1 downto 0);
        Bitslip_pin     : in std_logic;
        SlipVal_pin     : in std_logic_vector(2 downto 0);
        CompVal_pin     : in std_logic_vector(C_DataWidth-1 downto 0);
        Ena_pin         : in std_logic;
        Rst_pin         : in std_logic;
        Clk_pin         : in std_logic;
        DataOut_pin     : out std_logic_vector(C_DataWidth-1 downto 0);
        ErrOut_pin      : out std_logic
    );
end BitSlipInLogic;

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_UNSIGNED.all;
package BitSlipInLogic_comp is
  component BitSlipInLogic is
    generic (
        C_DataWidth     : integer   := 8;       -- 8, 4
        C_InputReg      : integer   := 0        -- 0, No, 1 = Yes
    );
    port (
        DataIn_pin      : in std_logic_vector(C_DataWidth-1 downto 0);
        Bitslip_pin     : in std_logic;
        SlipVal_pin     : in std_logic_vector(2 downto 0);
        CompVal_pin     : in std_logic_vector(C_DataWidth-1 downto 0);
        Ena_pin         : in std_logic;
        Rst_pin         : in std_logic;
        Clk_pin         : in std_logic;
        DataOut_pin     : out std_logic_vector(C_DataWidth-1 downto 0);
        ErrOut_pin      : out std_logic
    );
  end component BitSlipInLogic;

end BitSlipInLogic_comp;
---------------------------------------------------------------------------------------------
-- Architecture section
---------------------------------------------------------------------------------------------
architecture BitSlipInLogic_arch of BitSlipInLogic is
---------------------------------------------------------------------------------------------
-- Component Instantiation
---------------------------------------------------------------------------------------------
  component BitSlipInLogic_8b is
    generic (
        C_InputReg      : integer   := 0        -- 0, No, 1 = Yes
    );
    port (
        DataIn_pin      : in std_logic_vector(7 downto 0);
        Bitslip_pin     : in std_logic;
        SlipVal_pin     : in std_logic_vector(2 downto 0);
        CompVal_pin     : in std_logic_vector(7 downto 0);
        Ena_pin         : in std_logic;
        Rst_pin         : in std_logic;
        Clk_pin         : in std_logic;
        DataOut_pin     : out std_logic_vector(7 downto 0);
        ErrOut_pin      : out std_logic
    );
  end component BitSlipInLogic_8b;
  component BitSlipInLogic_4b is
    generic (
        C_InputReg      : integer   := 0        -- 0, No, 1 = Yes
    );
    port (
        DataIn_pin      : in std_logic_vector(3 downto 0);
        Bitslip_pin     : in std_logic;
        SlipVal_pin     : in std_logic_vector(1 downto 0);
        CompVal_pin     : in std_logic_vector(3 downto 0);
        Ena_pin         : in std_logic;
        Rst_pin         : in std_logic;
        Clk_pin         : in std_logic;
        DataOut_pin     : out std_logic_vector(3 downto 0);
        ErrOut_pin      : out std_logic
    );
end component BitSlipInLogic_4b;
  
---------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
---------------------------------------------------------------------------------------------
-- Attributes
attribute KEEP_HIERARCHY : string;
  attribute KEEP_HIERARCHY of BitSlipInLogic_arch : architecture is "YES";
---------------------------------------------------------------------------------------------
begin
-----------------------------------------------------------------------------------------
-- 8 BIT
-----------------------------------------------------------------------------------------
  C_DataWidth_8 : if C_DataWidth = 8 generate
    BitslipInLogic_I_Btslp8b : BitSlipInLogic_8b
    generic map (
      C_InputReg      => C_InputReg -- 0, No, 1 = Yes
    )
    port map (
      DataIn_pin      => DataIn_pin, -- in [7:0]
      Bitslip_pin     => Bitslip_pin, -- in 
      SlipVal_pin     => SlipVal_pin(2 downto 0), -- in [2:0]
      CompVal_pin     => CompVal_pin, -- in [7:0]
      Ena_pin         => Ena_pin, -- in
      Rst_pin         => Rst_pin, -- in
      Clk_pin         => Clk_pin, -- in
      DataOut_pin     => DataOut_pin, -- out [7:0]
      ErrOut_pin      => ErrOut_pin
    );
  end generate C_DataWidth_8;

-----------------------------------------------------------------------------------------
-- 4 BIT
-----------------------------------------------------------------------------------------
  C_DataWidth_4 : if C_DataWidth = 4 generate
    BitslipInLogic_I_Btslp4b : BitSlipInLogic_4b
    generic map (
      C_InputReg      => C_InputReg -- 0, No, 1 = Yes
    )
    port map (
      DataIn_pin      => DataIn_pin, -- in [3:0]
      Bitslip_pin     => Bitslip_pin, -- in 
      SlipVal_pin     => SlipVal_pin(1 downto 0), -- in [1:0]
      CompVal_pin     => CompVal_pin, -- in [3:0]
      Ena_pin         => Ena_pin, -- in
      Rst_pin         => Rst_pin, -- in
      Clk_pin         => Clk_pin, -- in
      DataOut_pin     => DataOut_pin, -- out [3:0]
      ErrOut_pin      => ErrOut_pin
    );
  end generate C_DataWidth_4;
---------------------------------------------------------------------------------------------
end BitSlipInLogic_arch;
