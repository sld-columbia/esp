---------------------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/    © Copyright 2014 Xilinx, Inc. All rights reserved.
--  \   \        This file contains confidential and proprietary information of Xilinx, Inc.
--  /   /        and is protected under U.S. and international copyright and other
-- /___/   /\    intellectual property laws.
-- \   \  /  \
--  \___\/\___\
--
---------------------------------------------------------------------------------------------
-- Device:              UltraScale, 7-Series
-- Author:              Defossez
-- Entity Name:         BitSlipInLogic_4b
-- Purpose:             Perform bitslip operations on parallel data.
--                      Extended functionality than native Virtex and 7-Series bitslip.
-- Tools:               Vivado_2014.1 or newer
-- Limitations:         none
--
-- Vendor:              Xilinx Inc.
-- Version:             V0.01
-- Filename:            BitSlipInLogic_4b.vhd
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
---------------------------------------------------------------------------------------------
entity BitSlipInLogic_4b is
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
end BitSlipInLogic_4b;
---------------------------------------------------------------------------------------------
-- Architecture section
---------------------------------------------------------------------------------------------
architecture BitSlipInLogic_4b_arch of BitSlipInLogic_4b is
---------------------------------------------------------------------------------------------
-- Component Instantiation
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
---------------------------------------------------------------------------------------------
-- Functions
-- Constants
constant Low  : std_logic	:= '0';
constant High : std_logic	:= '1';
-- Signals
signal IntBitSlipPosition   : std_logic_vector(3 downto 0);
signal IntFrstBitSlipPstn   : std_logic;
signal IntBitSlipData       : std_logic_vector(3 downto 0);
signal IntRankOne           : std_logic_vector(3 downto 0);
signal IntRankTwo           : std_logic_vector(3 downto 0);
signal IntRankTre           : std_logic_vector(3 downto 0);
signal IntEnaReg            : std_logic;
signal IntEnaReg_d          : std_logic;
signal IntShftSlipReg       : std_logic;
signal IntSlipPulse_d       : std_logic;
signal IntShiftEna_d        : std_logic;
signal IntSlipPulse         : std_logic;
signal IntShiftEna          : std_logic;
signal IntShftCntTc         : std_logic;
signal IntShftCntEna        : std_logic;
signal IntCompEqu           : std_logic;
signal IntCompEqu_d         : std_logic;
signal IntCompEqu_Rst       : std_logic;
signal IntShftCntRst        : std_logic;
signal IntBitSlipCntOut     : std_logic_vector(1 downto 0);
signal IntErrOut            : std_logic;
signal IntErrOut_d          : std_logic;
-- Attributes
attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of BitSlipInLogic_4b_arch : architecture is "YES";
attribute LOC : string;
--        attribute LOC of  : label is ;
---------------------------------------------------------------------------------------------
begin
---------------------------------------------------------------------------------------------
-- Extra front input register.
-- Adds one pipeline stage!
-----------------------------------------------------------------------------------------
--DDGen_1_0 : if (C_InputReg = 1) generate
--DD    BitSlipInLogic_4b_PROCESS_Rnk1 : process (Clk_pin, Rst_pin, dataIn_pin, IntRankTwo)
--DD    begin
--DD        if (Rst_pin = '1') then 
--DD            IntRankOne <= (others => '0');
--DD        elsif (Clk_pin'event and Clk_pin = '1') then
--DD            If (Ena_pin = '1') then
--DD                IntRankOne <= DataIn_pin;
--DD            end if;
--DD        end if;
--DD    end process;
--DDend generate Gen_1_0;
Gen_1_0 : if (C_InputReg = 1) generate
    BitSlipInLogic_4b_PROCESS_Rnk1 : process (Clk_pin)
    begin
      if (Clk_pin'event and Clk_pin = '1') then  
        if (Rst_pin = '1') then 
          IntRankOne <= (others => '0');
        elsif (Ena_pin = '1') then
          IntRankOne <= DataIn_pin;
        end if;
      end if;
    end process;
end generate Gen_1_0;



--
Gen_1_1 : if (C_InputReg = 0) generate
    IntRankOne <= DataIn_pin;
end generate Gen_1_1;
-----------------------------------------------------------------------------------------
-- These are the bitslip registers.
-----------------------------------------------------------------------------------------
--DDBitSlipInLogic_4b_PROCESS_Data : process (Clk_pin, Rst_pin, dataIn_pin, IntRankTwo)
--DDbegin
--DD    if (Rst_pin = '1') then 
--DD        IntRankTwo <= (others => '0');
--DD        IntRankTre <= (others => '0');
--DD    elsif (Clk_pin'event and Clk_pin = '1') then
--DD        If (Ena_pin = '1') then
--DD            IntRankTwo <= IntRankOne;
--DD         end if;
--DD         if (IntEnaReg = '1') then
--DD            IntRankTre <= IntBitSlipData;
--DD        end if;
--DD    end if;
--DDend process;
BitSlipInLogic_4b_PROCESS_Data : process (Clk_pin)
begin
  if (Clk_pin'event and Clk_pin = '1') then  
    if (Rst_pin = '1') then 
      IntRankTwo <= (others => '0');
      IntRankTre <= (others => '0');
    elsif (Ena_pin = '1') then
      IntRankTwo <= IntRankOne;
    end if;
    if (IntEnaReg = '1') then
      IntRankTre <= IntBitSlipData;
    end if;
  end if;
end process;

--
DataOut_pin <= IntRankTre; 
--
BitSlipInLogic_4b_PROCESS_Mux : process (IntBitSlipPosition, Ena_pin, IntRankOne, IntRankTwo)
subtype Sel is std_logic_vector (4 downto 0);
begin
    case Sel'(Ena_pin & IntBitSlipPosition) is
        when "10000" => IntBitSlipData <= IntRankOne(3 downto 0);
        when "10001" => IntBitSlipData <= IntRankOne(0) & IntRankTwo(3 downto 1);
        when "10010" => IntBitSlipData <= IntRankOne(1 downto 0) & IntRankTwo(3 downto 2);
        when "10100" => IntBitSlipData <= IntRankOne(2 downto 0) & IntRankTwo(3); 
        when "11000" => IntBitSlipData <= IntRankOne(3 downto 0);
        when others => IntBitSlipData <= "0000";
    end case;
end process;
-----------------------------------------------------------------------------------------
-- This is the bitslip controller.
-- When the attribute is set to "Slip" the generated controller is simple.
-- When the attribute is set to "Nmbr" the controller is more complex.
-----------------------------------------------------------------------------------------
--DDBitSlipInLogic_4b_PROCESS_Bitslip : process (Clk_pin, Rst_pin, Ena_pin)
--DDbegin
--DD    if (Rst_pin = '1') then
--DD        IntBitSlipPosition <= (others => '0');
--DD        IntFrstBitSlipPstn <= '0';
--DD    elsif (Clk_pin'event and Clk_pin = '1') then
--DD        if (Ena_pin = '1' ) then
--DD            if (IntShftSlipReg = '1' and IntFrstBitSlipPstn = '0') then
--DD                IntBitSlipPosition <= IntBitSlipPosition(2 downto 0) & not IntBitSlipPosition(3);
--DD            elsif (IntShftSlipReg = '1' and IntFrstBitSlipPstn /= '0') then 
--DD                IntBitSlipPosition <= IntBitSlipPosition(2 downto 0) & IntBitSlipPosition(3);
--DD            end if;
--DD            if (IntShftSlipReg = '1') then
--DD                IntFrstBitSlipPstn <= High;
--DD            end if;
--DD        end if;
--DD    end if;
--DDend process;

BitSlipInLogic_4b_PROCESS_Bitslip : process (Clk_pin)
begin
    if (Clk_pin'event and Clk_pin = '1') then
      if (Rst_pin = '1') then
        IntBitSlipPosition <= (others => '0');
        IntFrstBitSlipPstn <= '0';
      elsif (Ena_pin = '1' ) then
        if (IntShftSlipReg = '1' and IntFrstBitSlipPstn = '0') then
            IntBitSlipPosition <= IntBitSlipPosition(2 downto 0) & not IntBitSlipPosition(3);
        elsif (IntShftSlipReg = '1' and IntFrstBitSlipPstn /= '0') then 
            IntBitSlipPosition <= IntBitSlipPosition(2 downto 0) & IntBitSlipPosition(3);
        end if;
        if (IntShftSlipReg = '1') then
            IntFrstBitSlipPstn <= High;
        end if;
      end if;
    end if;
end process;
-----------------------------------------------------------------------------------------
    IntShftSlipReg <= Bitslip_pin;
    IntEnaReg <= High;
    ErrOut_pin <= Low;
-----------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
end BitSlipInLogic_4b_arch;
--