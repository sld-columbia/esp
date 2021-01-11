-------------------------------------------------------------------------------
-- ahblite_axi_bridge_pkg.vhd - entity/architecture pair
-------------------------------------------------------------------------------
-- ******************************************************************* 
-- ** (c) Copyright [2007] - [2011] Xilinx, Inc. All rights reserved.*
-- **                                                                *
-- ** This file contains confidential and proprietary information    *
-- ** of Xilinx, Inc. and is protected under U.S. and                *
-- ** international copyright and other intellectual property        *
-- ** laws.                                                          *
-- **                                                                *
-- ** DISCLAIMER                                                     *
-- ** This disclaimer is not a license and does not grant any        *
-- ** rights to the materials distributed herewith. Except as        *
-- ** otherwise provided in a valid license issued to you by         *
-- ** Xilinx, and to the maximum extent permitted by applicable      *
-- ** law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND        *
-- ** WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES    *
-- ** AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING      *
-- ** BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-         *
-- ** INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and       *
-- ** (2) Xilinx shall not be liable (whether in contract or tort,   *
-- ** including negligence, or under any other theory of             *
-- ** liability) for any loss or damage of any kind or nature        *
-- ** related to, arising under or in connection with these          *
-- ** materials, including for any direct, or any indirect,          *
-- ** special, incidental, or consequential loss or damage           *
-- ** (including loss of data, profits, goodwill, or any type of     *
-- ** loss or damage suffered as a result of any action brought      *
-- ** by a third party) even if such damage or loss was              *
-- ** reasonably foreseeable or Xilinx had been advised of the       *
-- ** possibility of the same.                                       *
-- **                                                                *
-- ** CRITICAL APPLICATIONS                                          *
-- ** Xilinx products are not designed or intended to be fail-       *
-- ** safe, or for use in any application requiring fail-safe        *
-- ** performance, such as life-support or safety devices or         *
-- ** systems, Class III medical devices, nuclear facilities,        *
-- ** applications related to the deployment of airbags, or any      *
-- ** other applications that could lead to death, personal          *
-- ** injury, or severe property or environmental damage             *
-- ** (individually and collectively, "Critical                      *
-- ** Applications"). Customer assumes the sole risk and             *
-- ** liability of any use of Xilinx products in Critical            *
-- ** Applications, subject only to applicable laws and              *
-- ** regulations governing limitations on product liability.        *
-- **                                                                *
-- ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS       *
-- ** PART OF THIS FILE AT ALL TIMES.                                *
-- ******************************************************************* 
--
-------------------------------------------------------------------------------
-- Filename:        ahblite_axi_bridge_pkg.vhd
-- Version:         v1.00a
-- Description:     This file contains the constants used across 
--                  different files in the IP
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- ahblite_axi_bridge.vhd
--              -- ahblite_axi_bridge_pkg.vhd
--              -- ahblite_axi_control.vhd
--              -- ahb_if.vhd
--              -- ahb_data_counter.vhd
--              -- axi_wchannel.vhd
--              -- axi_rchannel.vhd
--              -- time_out.vhd
--
-------------------------------------------------------------------------------
-- Author:      Kondalarao P( kpolise@xilinx.com ) 
-- History:
-- Kondalarao P          11/24/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------

-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "reset", "resetn"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package ahblite_axi_bridge_pkg is

--------------------------------------------------------------------------------
--Constants declerations
--------------------------------------------------------------------------------
                         -- AHB SIDE --
--------------------------------------------------------------------------------
-- Constants for Burst operation
--------------------------------------------------------------------------------
  constant SINGLE  : std_logic_vector := "000";
  constant INCR    : std_logic_vector := "001";
  constant WRAP4   : std_logic_vector := "010";
  constant INCR4   : std_logic_vector := "011";
  constant WRAP8   : std_logic_vector := "100";
  constant INCR8   : std_logic_vector := "101";
  constant WRAP16  : std_logic_vector := "110";
  constant INCR16  : std_logic_vector := "111";

--------------------------------------------------------------------------------
-- Constants for Transfer type
--------------------------------------------------------------------------------
  constant IDLE   : std_logic_vector := "00";
  constant BUSY   : std_logic_vector := "01";
  constant NONSEQ : std_logic_vector := "10";
  constant SEQ    : std_logic_vector := "11";

--------------------------------------------------------------------------------
--Constants for Burst counts
--------------------------------------------------------------------------------
  constant INCR_WRAP_4  : std_logic_vector := "00011";
  constant INCR_WRAP_8  : std_logic_vector := "00111";
  constant INCR_WRAP_16 : std_logic_vector := "01111";

--------------------------------------------------------------------------------
--Constant for ahb valid data sample counter width
--------------------------------------------------------------------------------
  constant AHB_SAMPLE_CNT_WIDTH : integer := 5;

--------------------------------------------------------------------------------
--Constants for AHB response
--------------------------------------------------------------------------------
  constant AHB_HRESP_OKAY  : std_logic := '0';
  constant AHB_HRESP_ERROR : std_logic := '1';

--------------------------------------------------------------------------------
                         -- AXI SIDE --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Constants for Length on axi interface.
--------------------------------------------------------------------------------
  constant AXI_ARWLEN_1  : std_logic_vector := "0000";
  constant AXI_ARWLEN_4  : std_logic_vector := "0011";
  constant AXI_ARWLEN_8  : std_logic_vector := "0111";
  constant AXI_ARWLEN_16 : std_logic_vector := "1111";

--------------------------------------------------------------------------------
--Constant for axi_write counter width
--------------------------------------------------------------------------------
  constant  AXI_WRITE_CNT_WIDTH : integer := 5; 

--------------------------------------------------------------------------------
--Constants for BURST in AXI side interface
-- Same constants for read and write interfaces.
--------------------------------------------------------------------------------
  constant AXI_ARWBURST_FIXED : std_logic_vector := "00";
  constant AXI_ARWBURST_INCR  : std_logic_vector := "01";
  constant AXI_ARWBURST_WRAP  : std_logic_vector := "10";
  constant AXI_ARWBURST_RSVD  : std_logic_vector := "11";

--------------------------------------------------------------------------------
--Constants for AXI response
--------------------------------------------------------------------------------
  constant AXI_RESP_OKAY   : std_logic_vector := "00";
  constant AXI_RESP_SLVERR : std_logic_vector := "10";
  constant AXI_RESP_DECERR : std_logic_vector := "11";

end package ahblite_axi_bridge_pkg;

package body ahblite_axi_bridge_pkg is
  -- No functions defined.
end package body ahblite_axi_bridge_pkg;



-------------------------------------------------------------------------------
-- counter_f - entity/architecture pair
-------------------------------------------------------------------------------
--
-- *************************************************************************
-- **                                                                     **
-- ** DISCLAIMER OF LIABILITY                                             **
-- **                                                                     **
-- ** This text/file contains proprietary, confidential                   **
-- ** information of Xilinx, Inc., is distributed under                   **
-- ** license from Xilinx, Inc., and may be used, copied                  **
-- ** and/or disclosed only pursuant to the terms of a valid              **
-- ** license agreement with Xilinx, Inc. Xilinx hereby                   **
-- ** grants you a license to use this text/file solely for               **
-- ** design, simulation, implementation and creation of                  **
-- ** design files limited to Xilinx devices or technologies.             **
-- ** Use with non-Xilinx devices or technologies is expressly            **
-- ** prohibited and immediately terminates your license unless           **
-- ** covered by a separate agreement.                                    **
-- **                                                                     **
-- ** Xilinx is providing this design, code, or information               **
-- ** "as-is" solely for use in developing programs and                   **
-- ** solutions for Xilinx devices, with no obligation on the             **
-- ** part of Xilinx to provide support. By providing this design,        **
-- ** code, or information as one possible implementation of              **
-- ** this feature, application or standard, Xilinx is making no          **
-- ** representation that this implementation is free from any            **
-- ** claims of infringement. You are responsible for obtaining           **
-- ** any rights you may require for your implementation.                 **
-- ** Xilinx expressly disclaims any warranty whatsoever with             **
-- ** respect to the adequacy of the implementation, including            **
-- ** but not limited to any warranties or representations that this      **
-- ** implementation is free from claims of infringement, implied         **
-- ** warranties of merchantability or fitness for a particular           **
-- ** purpose.                                                            **
-- **                                                                     **
-- ** Xilinx products are not intended for use in life support            **
-- ** appliances, devices, or systems. Use in such applications is        **
-- ** expressly prohibited.                                               **
-- **                                                                     **
-- ** Any modifications that are made to the Source Code are              **
-- ** done at the user’s sole risk and will be unsupported.               **
-- ** The Xilinx Support Hotline does not have access to source           **
-- ** code and therefore cannot answer specific questions related         **
-- ** to source HDL. The Xilinx Hotline support of original source        **
-- ** code IP shall only address issues and questions related             **
-- ** to the standard Netlist version of the core (and thus               **
-- ** indirectly, the original core source).                              **
-- **                                                                     **
-- ** Copyright (c) 2006-2010 Xilinx, Inc. All rights reserved.           **
-- **                                                                     **
-- ** This copyright and support notice must be retained as part          **
-- ** of this text at all times.                                          **
-- **                                                                     **
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        counter_f.vhd
--
-- Description:     Implements a parameterizable N-bit counter_f
--                      Up/Down Counter
--                      Count Enable
--                      Parallel Load
--                      Synchronous Reset
--                      The structural implementation has incremental cost
--                      of one LUT per bit.
--                      Precedence of operations when simultaneous:
--                        reset, load, count
--
--                  A default inferred-RTL implementation is provided and
--                  is used if the user explicitly specifies C_FAMILY=nofamily
--                  or ommits C_FAMILY (allowing it to default to nofamily).
--                  The default implementation is also used
--                  if needed primitives are not available in FPGAs of the
--                  type given by C_FAMILY.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  counter_f.vhd
--                      family_support.vhd
--
-------------------------------------------------------------------------------
-- Author: FLO & Nitin   06/06/2006   First Version, functional equivalent
--                                    of counter.vhd.
-- History:
--     DET     1/17/2008     v4_0
-- ~~~~~~
-- ^^^^^^
--
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_com"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.unsigned;
use IEEE.numeric_std."+";
use IEEE.numeric_std."-";

library unisim;
use unisim.all;

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity counter_f is
    generic(
            C_NUM_BITS : integer := 9;
            C_FAMILY   : string := "nofamily"
           );

    port(
         Clk           : in  std_logic;
         Rst           : in  std_logic;
         Load_In       : in  std_logic_vector(C_NUM_BITS - 1 downto 0);
         Count_Enable  : in  std_logic;
         Count_Load    : in  std_logic;
         Count_Down    : in  std_logic;
         Count_Out     : out std_logic_vector(C_NUM_BITS - 1 downto 0);
         Carry_Out     : out std_logic
        );
end entity counter_f;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of counter_f is

---------------------------------------------------------------------
-- Begin architecture
---------------------------------------------------------------------
begin

    INFERRED_GEN : if (true) generate

        signal icount_out    : unsigned(C_NUM_BITS downto 0);
        signal icount_out_x  : unsigned(C_NUM_BITS downto 0);
        signal load_in_x     : unsigned(C_NUM_BITS downto 0);

    begin

        load_in_x    <= unsigned('0' & Load_In);

        -- Mask out carry position to retain legacy self-clear on next enable.
 --        icount_out_x <= ('0' & icount_out(C_NUM_BITS-1 downto 0)); -- Echeck WA
         icount_out_x <= unsigned('0' & std_logic_vector(icount_out(C_NUM_BITS-1 downto 0)));

        -----------------------------------------------------------------
        -- Process to generate counter with - synchronous reset, load,
        -- counter enable, count down / up features.
        -----------------------------------------------------------------
        CNTR_PROC : process(Clk)
        begin
            if Clk'event and Clk = '1' then
                if Rst = '1' then
                    icount_out <= (others => '0');
                elsif Count_Load = '1' then
                    icount_out <= load_in_x;
                elsif Count_Down = '1'  and Count_Enable = '1' then
                    icount_out <= icount_out_x - 1;
                elsif Count_Enable = '1' then
                    icount_out <= icount_out_x + 1;
                end if;
            end if;
        end process CNTR_PROC;

        Carry_Out <= icount_out(C_NUM_BITS);
        Count_Out <= std_logic_vector(icount_out(C_NUM_BITS-1 downto 0));

    end generate INFERRED_GEN;


end architecture imp;
---------------------------------------------------------------
-- End of file counter_f.vhd
---------------------------------------------------------------


-------------------------------------------------------------------------------
-- time_out.vhd - entity/architecture pair
-------------------------------------------------------------------------------
-- ******************************************************************* 
-- ** (c) Copyright [2007] - [2011] Xilinx, Inc. All rights reserved.*
-- **                                                                *
-- ** This file contains confidential and proprietary information    *
-- ** of Xilinx, Inc. and is protected under U.S. and                *
-- ** international copyright and other intellectual property        *
-- ** laws.                                                          *
-- **                                                                *
-- ** DISCLAIMER                                                     *
-- ** This disclaimer is not a license and does not grant any        *
-- ** rights to the materials distributed herewith. Except as        *
-- ** otherwise provided in a valid license issued to you by         *
-- ** Xilinx, and to the maximum extent permitted by applicable      *
-- ** law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND        *
-- ** WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES    *
-- ** AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING      *
-- ** BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-         *
-- ** INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and       *
-- ** (2) Xilinx shall not be liable (whether in contract or tort,   *
-- ** including negligence, or under any other theory of             *
-- ** liability) for any loss or damage of any kind or nature        *
-- ** related to, arising under or in connection with these          *
-- ** materials, including for any direct, or any indirect,          *
-- ** special, incidental, or consequential loss or damage           *
-- ** (including loss of data, profits, goodwill, or any type of     *
-- ** loss or damage suffered as a result of any action brought      *
-- ** by a third party) even if such damage or loss was              *
-- ** reasonably foreseeable or Xilinx had been advised of the       *
-- ** possibility of the same.                                       *
-- **                                                                *
-- ** CRITICAL APPLICATIONS                                          *
-- ** Xilinx products are not designed or intended to be fail-       *
-- ** safe, or for use in any application requiring fail-safe        *
-- ** performance, such as life-support or safety devices or         *
-- ** systems, Class III medical devices, nuclear facilities,        *
-- ** applications related to the deployment of airbags, or any      *
-- ** other applications that could lead to death, personal          *
-- ** injury, or severe property or environmental damage             *
-- ** (individually and collectively, "Critical                      *
-- ** Applications"). Customer assumes the sole risk and             *
-- ** liability of any use of Xilinx products in Critical            *
-- ** Applications, subject only to applicable laws and              *
-- ** regulations governing limitations on product liability.        *
-- **                                                                *
-- ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS       *
-- ** PART OF THIS FILE AT ALL TIMES.                                *
-- ******************************************************************* 
--
-------------------------------------------------------------------------------
-- Filename:        time_out.vhd
-- Version:         v1.00a
-- Description:     This file contains the time out counter logic.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- ahblite_axi_bridge.vhd
--              -- ahblite_axi_bridge_pkg.vhd
--              -- ahblite_axi_control.vhd
--              -- ahb_data_counter.vhd
--              -- axi_wchannel.vhd
--              -- axi_rchannel.vhd
--              -- time_out.vhd
--
-------------------------------------------------------------------------------
-- Author:      Kondalarao P( kpolise@xilinx.com ) 
-- History:
-- Kondalarao P          11/24/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------

-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "reset", "resetn"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library ahblite_axi_bridge_v3_0_15;
-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--Important Notes on AXI Valid/Ready Assertion
--------------------------------------------------------------------------------
-- a.Once VALID is asserted it must remain asserted until the handshake 
--  occurs.
-- b.If READY is asserted, it is permitted to deassert READY before 
--  VALID is asserted
----
-- Definition of Ports
--
-- System signals
-- AHB signals
--  S_AHB_HCLK               -- AHB Clock
--  S_AHB_HRESETN            -- AHB Reset Signal - active low
-- Control signals
--  core_is_idle             -- Core is in IDLE state
--  enable_timeout_cnt       -- To start timer count
-- AXI signals
--  M_AXI_BVALID             -- Write response valid - This signal indicates
--                              that a valid write response is available
--  last_axi_rd_sample       -- Read last. This signal indicates the 
--                           -- last transfer in a read burst
--  timeout_o                -- Signal indicating the timeout condition
-------------------------------------------------------------------------------
-- Generics & Signals Description
-------------------------------------------------------------------------------
entity time_out is
  generic (
    C_FAMILY              : string    := "virtex7";
    C_AHB_AXI_TIMEOUT     : integer   := 0
  );
  port (
  -- AHB Signals
     S_AHB_HCLK           : in  std_logic;                           
     S_AHB_HRESETN        : in  std_logic;                           
     core_is_idle         : in  std_logic;
     enable_timeout_cnt   : in  std_logic;
  -- For write transaction
     M_AXI_BVALID         : in  std_logic;
     wr_load_timeout_cntr : in std_logic;
  -- For read transaction  
     last_axi_rd_sample   : in  std_logic;
     rd_load_timeout_cntr : in std_logic;
  -- Time out signal
     timeout_o            : out std_logic
    );

end entity time_out;
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of time_out is
-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

--------------------------------------------------------------------------------
-- Function clog2 - returns the integer ceiling of the base 2 logarithm of x,
--                  i.e., the least integer greater than or equal to log2(x).
--------------------------------------------------------------------------------
function clog2(x : positive) return natural is
  variable r  : natural := 0;
  variable rp : natural := 1; -- rp tracks the value 2**r
begin 
  while rp < x loop -- Termination condition T: x <= 2**r
    -- Loop invariant L: 2**(r-1) < x
    r := r + 1;
    if rp > integer'high - rp then exit; end if;  -- If doubling rp overflows
      -- the integer range, the doubled value would exceed x, so safe to exit.
    rp := rp + rp;
  end loop;
  -- L and T  <->  2**(r-1) < x <= 2**r  <->  (r-1) < log2(x) <= r
  return r; --
end clog2;

begin
-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Declare the signals/constants required when timeout module is required.
-- This is based on the generic choosen whether to implement the timeout logic
-- or not.
--------------------------------------------------------------------------------
 
  GEN_WDT : if (C_AHB_AXI_TIMEOUT /= 0) generate

     constant TIMEOUT_VALUE_TO_USE : integer := C_AHB_AXI_TIMEOUT;
     constant COUNTER_WIDTH        : integer := clog2(TIMEOUT_VALUE_TO_USE);
     constant TIMEOUT_VALUE_VECTOR : std_logic_vector(COUNTER_WIDTH-1 downto 0)
                                   := std_logic_vector(to_unsigned
                                      (TIMEOUT_VALUE_TO_USE-1,COUNTER_WIDTH));
     signal timeout_i              : std_logic;
     signal cntr_rst               : std_logic;
     signal cntr_load              : std_logic;
     signal cntr_enable            : std_logic;

  begin

--------------------------------------------------------------------------------
-- Reeset condition for counter
-- Counter is active high reset, Invert the IP reset.
--------------------------------------------------------------------------------
   cntr_rst    <= not S_AHB_HRESETN ;
--------------------------------------------------------------------------------
--  Load the counter when core is in IDLE state
--------------------------------------------------------------------------------
   cntr_load   <= core_is_idle         or
                  wr_load_timeout_cntr or 
                  rd_load_timeout_cntr;


--------------------------------------------------------------------------------
--Generate the enable signal for the timeout counter.
-- Start counting : When Write / Read addres is placed
-- Stop  counting : Write response detected / Last read data seen or
--                   counter expired.
--------------------------------------------------------------------------------
    COUNTER_ENABLE_REG : process (S_AHB_HCLK) is 
    begin
       if(S_AHB_HCLK'EVENT and S_AHB_HCLK='1')then
         if(S_AHB_HRESETN='0')then
           cntr_enable <= '0';
         else
           if( enable_timeout_cnt = '1' ) then
             cntr_enable <= '1';
           elsif( M_AXI_BVALID = '1' or last_axi_rd_sample ='1' or
                  timeout_i = '1') then
             cntr_enable <= '0';
           else
             cntr_enable <= cntr_enable;
           end if;
         end if;
       end if;
    end process COUNTER_ENABLE_REG;
--------------------------------------------------------------------------------
--Instantiation of the counter module.
-- To count the number of clock pulses lapsed after the transfer is initiated
-- on the AHB side.
--------------------------------------------------------------------------------
    WDT_COUNTER_MODULE : entity ahblite_axi_bridge_v3_0_15.counter_f
       generic map(
         C_NUM_BITS    =>  COUNTER_WIDTH,
         C_FAMILY      =>  C_FAMILY
           )
       port map(
         Clk           =>  S_AHB_HCLK,
         Rst           =>  cntr_rst,
         Load_In       =>  TIMEOUT_VALUE_VECTOR,
         Count_Enable  =>  cntr_enable,
         Count_Load    =>  cntr_load,
         Count_Down    =>  '1',
         Count_Out     =>  open,
         Carry_Out     =>  timeout_i
         );

--------------------------------------------------------------------------------
-- This process is used for registering timeout
-- This timeout signal is used in generating the ready to AHB with
-- error response
--------------------------------------------------------------------------------
    TIMEOUT_REG : process(S_AHB_HCLK) is
    begin
        if(S_AHB_HCLK'EVENT and S_AHB_HCLK='1')then
            if(S_AHB_HRESETN='0')then
                timeout_o <= '0';
            else
                timeout_o <= timeout_i;
            end if;
        end if;
    end process TIMEOUT_REG;
  end generate GEN_WDT;

--------------------------------------------------------------------------------
-- No timeout logic when C_AHB_AXI_TIMEOUT = 0
--------------------------------------------------------------------------------
   GEN_NO_WDT : if (C_AHB_AXI_TIMEOUT = 0) generate
   begin
        timeout_o <= '0';
   end generate GEN_NO_WDT;
end architecture RTL;


-------------------------------------------------------------------------------
-- axi_wchannel.vhd - entity/architecture pair
-------------------------------------------------------------------------------
-- ******************************************************************* 
-- ** (c) Copyright [2007] - [2011] Xilinx, Inc. All rights reserved.*
-- **                                                                *
-- ** This file contains confidential and proprietary information    *
-- ** of Xilinx, Inc. and is protected under U.S. and                *
-- ** international copyright and other intellectual property        *
-- ** laws.                                                          *
-- **                                                                *
-- ** DISCLAIMER                                                     *
-- ** This disclaimer is not a license and does not grant any        *
-- ** rights to the materials distributed herewith. Except as        *
-- ** otherwise provided in a valid license issued to you by         *
-- ** Xilinx, and to the maximum extent permitted by applicable      *
-- ** law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND        *
-- ** WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES    *
-- ** AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING      *
-- ** BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-         *
-- ** INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and       *
-- ** (2) Xilinx shall not be liable (whether in contract or tort,   *
-- ** including negligence, or under any other theory of             *
-- ** liability) for any loss or damage of any kind or nature        *
-- ** related to, arising under or in connection with these          *
-- ** materials, including for any direct, or any indirect,          *
-- ** special, incidental, or consequential loss or damage           *
-- ** (including loss of data, profits, goodwill, or any type of     *
-- ** loss or damage suffered as a result of any action brought      *
-- ** by a third party) even if such damage or loss was              *
-- ** reasonably foreseeable or Xilinx had been advised of the       *
-- ** possibility of the same.                                       *
-- **                                                                *
-- ** CRITICAL APPLICATIONS                                          *
-- ** Xilinx products are not designed or intended to be fail-       *
-- ** safe, or for use in any application requiring fail-safe        *
-- ** performance, such as life-support or safety devices or         *
-- ** systems, Class III medical devices, nuclear facilities,        *
-- ** applications related to the deployment of airbags, or any      *
-- ** other applications that could lead to death, personal          *
-- ** injury, or severe property or environmental damage             *
-- ** (individually and collectively, "Critical                      *
-- ** Applications"). Customer assumes the sole risk and             *
-- ** liability of any use of Xilinx products in Critical            *
-- ** Applications, subject only to applicable laws and              *
-- ** regulations governing limitations on product liability.        *
-- **                                                                *
-- ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS       *
-- ** PART OF THIS FILE AT ALL TIMES.                                *
-- ******************************************************************* 
--
-------------------------------------------------------------------------------
-- Filename:        axi_wchannel.vhd
-- Version:         v1.00a
-- Description:     This module generates the AXI write transactions based on 
--                  the control and ahb information received on ahb-side.
--
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- ahblite_axi_bridge.vhd
--              -- ahblite_axi_bridge_pkg.vhd
--              -- ahblite_axi_control.vhd
--              -- ahb_if.vhd
--              -- ahb_data_counter.vhd
--              -- axi_wchannel.vhd
--              -- axi_rchannel.vhd
--              -- time_out.vhd
--
-------------------------------------------------------------------------------
-- Author:      Kondalarao P( kpolise@xilinx.com ) 
-- History:
-- Kondalarao P          11/24/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------

-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "reset", "resetn"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library ahblite_axi_bridge_v3_0_15;
use ahblite_axi_bridge_v3_0_15.ahblite_axi_bridge_pkg.all;
-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------

--
-- Definition of Generics
--
-- Definition of Ports
--
-- System signals
--
-- AHB signals
--  S_AHB_HCLK               -- AHB Clock
--  S_AHB_HRESETN            -- AHB Reset Signal - active low
--  S_AHB_HWDATA             -- AHB write data
--
-- AXI Write address channel signals
--  M_AXI_AWVALID            -- Write address valid - This signal indicates
--                              that valid write address & control information
--                              are available
--  M_AXI_AWREADY            -- Write address ready - This signal indicates
--                              that the slave is ready to accept an address
--                              and associated control signals
--
-- AXI Write data channel signals
--
--  M_AXI_WDATA              -- Write data bus  
--  M_AXI_WSTRB              -- Write strobes - These signals indicates which
--                              byte lanes to update in memory
--  M_AXI_WLAST              -- Write last. This signal indicates the last 
--                           -- transfer in a write burst
--  M_AXI_WVALID             -- Write valid - This signal indicates that valid
--                              write data and strobes are available
--  M_AXI_WREADY             -- Write ready - This signal indicates that the
--                              slave can accept the write data
-- AXI Write response channel signals
--
--  M_AXI_BVALID             -- Write response valid - This signal indicates
--                              that a valid write response is available
--  M_AXI_BRESP              -- Write response - This signal indicates the
--                              status of the write transaction
--  M_AXI_BREADY             -- Response ready - This signal indicates that
--                              the master can accept the response information
--  axi_wdata_done           -- Asserted when  WVALID = 1 and  WREADY = 1 
--  axi_bresp_ok             -- Asserted when  BVALID = 1
--  axi_bresp_err            -- Asserted when  BVALID = 1 and ERROR = 1
--  set_axi_waddr            -- To set write addr on AXI interface 
--  ahb_wnr                  -- To set first burst write data data on AXI
--                               interface
--  set_axi_wdata_burst      -- To set next burst write data data on AXI
--                               interface
--  ahb_hburst_single        -- Transfer on AHB is SINGLE
--  ahb_hburst_incr          -- Transfer on AHB is INCR
--  ahb_hburst_wrap4         -- Transfer on AHB is WRAP4
--  ahb_haddr_hsize          -- Lower 3-bits of ADDR and lower 2-bits of
--                               HSIZE to determine WSTRB intial value.
--  ahb_hsize                -- Lower 2-bits of HSIZE to determine 
--                              sub sequent values of WSTRB
--  valid_cnt_required       -- Required number of transfers for the selected
--  ahb_data_valid           -- Control signal indicating the data on the AHB
--                              can be used.
--  burst_term               -- Indicates burst termination on AHB side.
--  axi_wr_channel_ready     -- Write channel ready to accept data from AHB
--  timeout_i                -- Timeout signal from the timeout module
-------------------------------------------------------------------------------
-- Generics & Signals Description
-------------------------------------------------------------------------------

entity axi_wchannel is
  generic (
    C_FAMILY                      : string := "virtex7";
    C_S_AHB_ADDR_WIDTH            : integer range 32 to 64    := 32;
    C_M_AXI_ADDR_WIDTH            : integer range 32 to 64    := 32;
    C_S_AHB_DATA_WIDTH            : integer range 32 to 64    := 32;
    C_M_AXI_DATA_WIDTH            : integer range 32 to 64    := 32;
    C_M_AXI_THREAD_ID_WIDTH       : integer                   := 4;
    C_M_AXI_SUPPORTS_NARROW_BURST : integer range 0 to 1      := 0 
    );
  port (
  -- AHB Signals
     S_AHB_HCLK           : in    std_logic;                           
     S_AHB_HRESETN        : in    std_logic;                           
     S_AHB_HWDATA         : in    std_logic_vector
                                  (C_S_AHB_DATA_WIDTH-1 downto 0);

  -- AXI Write Address Channel Signals
     M_AXI_AWVALID        : out   std_logic;
     M_AXI_AWREADY        : in    std_logic;
  -- AXI Write Data Chanel Signals
     M_AXI_WDATA          : out   std_logic_vector
                                  (C_M_AXI_DATA_WIDTH-1 downto 0);
     M_AXI_WSTRB          : out   std_logic_vector
                                  ((C_M_AXI_DATA_WIDTH/8)-1 downto 0);
     M_AXI_WLAST          : out   std_logic;
     M_AXI_WVALID         : out   std_logic;
     M_AXI_WREADY         : in    std_logic;
    
  -- AXI Write Response Channel Signals
     M_AXI_BVALID         : in    std_logic;
     M_AXI_BRESP          : in    std_logic_vector(1 downto 0);
     M_AXI_BREADY         : out   std_logic;

  -- Control state machine
     axi_wdata_done       : out std_logic;    
     axi_bresp_ok         : out std_logic;    
     axi_bresp_err        : out std_logic;    
     set_axi_waddr        : in  std_logic; 
     ahb_wnr              : in  std_logic;
     set_axi_wdata_burst  : in  std_logic;
     ahb_hburst_single    : in  std_logic;
     ahb_hburst_incr      : in  std_logic;
     ahb_hburst_wrap4     : in  std_logic;
     ahb_haddr_hsize      : in  std_logic_vector( 4 downto 0);
     ahb_hsize            : in  std_logic_vector( 1 downto 0);
     valid_cnt_required   : in  std_logic_vector( 4 downto 0);
     burst_term_txer_cnt  : in  std_logic_vector( 4 downto 0);
     ahb_data_valid       : in  std_logic; 
  -- ahb_data_counter module
     burst_term_cur_cnt   : in  std_logic_vector(4 downto 0);
  -- ahb_if module
     burst_term           : in  std_logic;
     nonseq_txfer_pending : in  std_logic;
     init_pending_txfer   : in  std_logic;
     axi_wr_channel_ready : out std_logic;
     axi_wr_channel_busy  : out std_logic;
     placed_on_axi        : out std_logic;
     placed_in_local_buf  : out std_logic;
     timeout_detected     : out std_logic;
  -- Time out module
     timeout_i            : in  std_logic;
     wr_load_timeout_cntr : out std_logic 
    );

--Equivalent register for wdata
  --attribute equivalent_register_removal: string;
  --attribute equivalent_register_removal of axi_wchannel :entity is "no";
end entity axi_wchannel;
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of axi_wchannel is
-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";


-------------------------------------------------------------------------------
 -- Signal declarations(Description of each signal is given in their 
 --    implementation block
-------------------------------------------------------------------------------
signal M_AXI_AWVALID_i        : std_logic;
signal M_AXI_WVALID_i         : std_logic;   
signal M_AXI_WLAST_i          : std_logic;
signal M_AXI_WSTRB_i          : std_logic_vector
                                 ((C_M_AXI_DATA_WIDTH/8)-1 downto 0);
signal M_AXI_WDATA_i          : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
signal local_en               : std_logic;
signal local_wdata            : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
signal axi_cnt_required       : std_logic_vector( 4 downto 0);


signal M_AXI_BREADY_i         : std_logic;

signal axi_waddr_done_i       : std_logic;
signal axi_bresp_ok_i         : std_logic;
signal axi_bresp_err_i        : std_logic;
signal axi_wdata_done_i       : std_logic;

signal axi_write_cnt_i        : std_logic_vector( 4 downto 0);
signal axi_wr_channel_busy_i  : std_logic;
signal axi_wr_channel_ready_i : std_logic;
signal axi_wr_data_sampled_i  : std_logic;

signal next_wr_strobe         : std_logic_vector(1 downto 0);

signal msb_in_wrap4           : std_logic_vector(2 downto 0);
signal axi_penult_beat        : std_logic;
signal axi_last_beat          : std_logic;

-- Signals used during burst termination
signal ahb_data_valid_burst_term : std_logic;
signal dummy_on_axi_init         : std_logic;
signal dummy_on_axi_progress     : std_logic;
signal dummy_on_axi              : std_logic;

signal timeout_in_data_phase     : std_logic;
signal timeout_detected_i        : std_logic;
-- Signals used for counter
signal cntr_rst               : std_logic;
signal cntr_load              : std_logic;
signal cntr_enable            : std_logic;
signal wr_load_timeout_cntr_i : std_logic;
begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
    
--------------------------------------------------------------------------------
--O/P Signal assignements
--------------------------------------------------------------------------------
--Write Address Channel
  M_AXI_AWVALID  <= M_AXI_AWVALID_i;
--Write Data Channel
  M_AXI_WLAST    <= M_AXI_WLAST_i; 
  M_AXI_WVALID   <= M_AXI_WVALID_i;
  M_AXI_WSTRB    <= M_AXI_WSTRB_i;
  M_AXI_WDATA    <= M_AXI_WDATA_i;
-- time_out module
  wr_load_timeout_cntr <= wr_load_timeout_cntr_i;

--------------------------------------------------------------------------------
-- Reset ahb_data_valid when the data on AHB is either placed on AXI or 
-- Stored internally in the local buffer.
-- placed_on_axi:
--  We can place the data from AHB to AXI when there is valid data from
--  AHB interface,AXI interface is ready to accept this data and there is
--  no pending data in the local buffer which is to be transferred to AXI
--------------------------------------------------------------------------------
placed_on_axi  <= axi_wr_channel_ready_i and ahb_data_valid and  not local_en;

--------------------------------------------------------------------------------
-- placed_in_local_buf: Place in local buffer
--    a.Valid data from AHB and Local buffer is empty and Write channel is
--      busy
--    b.Valid data from AHB and Local buffer in not empty but Write channel is
--      about to take that message from local buffer meaning AXI channel is 
--      ready to receive new data.In such case,we have to transfer data from
--      local buffer to AXI interface and AHB data to local buffer.
--      Depicting the case (b) below how the data flow when both 
--        AHB and AXI channels are ready and there is data pending to be 
--        transferred in local buffer
--      =====  Just before AHB and AXI are getting ready at the same time
---        AHB    Local_buf   AXI
--               _________
--               |       | 
--               |       | 
--               | DEAD  | 
--               |       | 
--               |       | 
--               --------
--      =====  When  AHB  ready to give new data
---     ====== When  AXI  ready to accept new data
---        AHB    Local_buf   AXI
--               _________
--               |       | 
--               |       | 
--      CEED     | DEAD  | 
--               |       | 
--               |       | 
--               --------
--      =====  After successfull transfer
---        AHB    Local_buf   AXI
--               _________
--               |       | 
--               |       | 
--               | CEED  |   DEAD
--               |       | 
--               |       | 
--               --------
--------------------------------------------------------------------------------
  placed_in_local_buf <= ahb_data_valid and 
                         (    
                         (not local_en and axi_wr_channel_busy_i) or
                         (local_en     and axi_wr_channel_ready_i)
                         );

  axi_wr_channel_busy  <= axi_wr_channel_busy_i ;
  axi_wr_channel_ready <= axi_wr_channel_ready_i;
--------------------------------------------------------------------------------
-- Accept further data from AHB when no data is placed on AXI(WVALID = 0) or
--  the current data is accepted by AXI(WVALID =1 and WREADY = 1),which 
-- simplifies to WVALID=0 or WREADY =1 [a + a'b = a + b]
--------------------------------------------------------------------------------
  axi_wr_channel_ready_i <= (not M_AXI_WVALID_i) or M_AXI_WREADY;

--------------------------------------------------------------------------------
--Write channel is considered busy when a data placed on AXI(WVALID=1) and 
-- the slave is not able to accept the data(WREADY=0)
--------------------------------------------------------------------------------
  axi_wr_channel_busy_i <= M_AXI_WVALID_i and (not M_AXI_WREADY);

--------------------------------------------------------------------------------
--Current data is said to be accepted by the slave when WVALID=1 and WREADY=1
--------------------------------------------------------------------------------
  axi_wr_data_sampled_i  <=  M_AXI_WVALID_i and M_AXI_WREADY;

--------------------------------------------------------------------------------
--Write response Channel
--------------------------------------------------------------------------------
  M_AXI_BREADY   <= M_AXI_BREADY_i;

  axi_bresp_ok   <= axi_bresp_ok_i;
  axi_bresp_err  <= axi_bresp_err_i;
  axi_wdata_done <= axi_wdata_done_i;

--------------------------------------------------------------------------------
--Update the timeout if detected
-- Will be reset only upon  S_AHB_HRESETN
--------------------------------------------------------------------------------
  timeout_detected  <= timeout_detected_i;

--------------------------------------------------------------------------------
--Data phase is completed when WLAST is detected along with WREADY
-- Also force the data phase to complete when timeout detected.
--------------------------------------------------------------------------------
  axi_wdata_done_i  <= (M_AXI_WREADY and  M_AXI_WLAST_i ) or timeout_detected_i;

--------------------------------------------------------------------------------
-- Write response error detection,consider timeout also as error.
--------------------------------------------------------------------------------
  axi_bresp_err_i   <= '1' when ((M_AXI_BVALID = '1' and
                                 (M_AXI_BRESP  = AXI_RESP_SLVERR or
                                  M_AXI_BRESP  = AXI_RESP_DECERR )) or
                                 timeout_detected_i = '1') 
                           else '0';
--------------------------------------------------------------------------------
-- Write response OK detection.In control state machine,error response is
-- given high priority. So,no need to explicity check for OK response
--------------------------------------------------------------------------------
  axi_bresp_ok_i    <= M_AXI_BVALID;

--------------------------------------------------------------------------------
--Internal signal assignments
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Reeset condition for counter
-- Counter is active high reset, Invert the IP reset.
--------------------------------------------------------------------------------
  cntr_rst         <= not S_AHB_HRESETN;
--------------------------------------------------------------------------------
--Load the counter during start of the write transfer(during address phase)
--------------------------------------------------------------------------------
  cntr_load        <= set_axi_waddr;

--------------------------------------------------------------------------------
-- Increment counter for every transfer sampled by AXI.
--------------------------------------------------------------------------------
  cntr_enable      <= M_AXI_WVALID_i and M_AXI_WREADY;
 
-------------------------------------------------------------------------------
-- Load fresh value to timeout counter once a valid sample is detected on AXI
--  side
--------------------------------------------------------------------------------
  wr_load_timeout_cntr_i <= M_AXI_WVALID_i and M_AXI_WREADY;
--------------------------------------------------------------------------------
--dummy_on_axi: Signal to force write strobes to '0' during burst termination
-- on AHB side.
--------------------------------------------------------------------------------
  dummy_on_axi <= dummy_on_axi_init or dummy_on_axi_progress;

--------------------------------------------------------------------------------
--dummy_on_axi_init: A pulse generated to mark the start of dummy transfer on
-- AXI during burst termination.
-- Dummy transfers should start on AXI when all the AHB samples before
-- burst terminated sequence(IDL/NONSEQ) are successfully transfered on AXI.
-- Logic Description:Dummy transfer has to be initiated in two cases.
--   Pre-conditions: This should be burst_term case and there should be no
--     pending dummy transfers currently happening.
--   Now, when the current transfer count is 1 less than the ahbcount and will
--   incremented immmediately when the current data is sampled or
--   AXI data is already sampled and count reached the number of ahb transfers
--     when the burst terminated.
-- For Ex: For a INCR4 transfer,if we get the following sequence from AHB
--   NONSEQ,SEQ,SEQ,IDL. Here the burst is terminated with IDL instead of
--   getting the next SEQ transfer. So only for the last data beat on
--   AXI we should put WSTROBE as "0". All other transfers before the
--   terminated transfer should be sent with the appropriate write strobe
--   values. 
--------------------------------------------------------------------------------
  dummy_on_axi_init <= '1' when 
                           (burst_term = '1')                       and
                           (dummy_on_axi_progress = '0')            and
                           (
                             ((axi_write_cnt_i = burst_term_cur_cnt-1) and 
                              (axi_wr_data_sampled_i = '1')) or 
                             (axi_write_cnt_i = burst_term_cur_cnt)
                            )
                           else
                       '0';

--------------------------------------------------------------------------------
--dummy_on_axi_progress: Once the dummy trasfer started,till the end of
-- the current transfer ,rest of the transfers on AXI should have write strobes
-- 0. This signal is set when dummy_on_axi_init is detected and set till the
--  last data is sampled on the AXI
--------------------------------------------------------------------------------
  AXI_DUMMY_FOR_BURST_TERM_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        dummy_on_axi_progress <= '0';
      else
        if(dummy_on_axi_init = '1') then
          dummy_on_axi_progress <= '1';
        elsif(axi_wdata_done_i = '1') then
          dummy_on_axi_progress <= '0';
        else
          dummy_on_axi_progress <= dummy_on_axi_progress;
        end if;
      end if;
    end if;
  end process AXI_DUMMY_FOR_BURST_TERM_REG;

--------------------------------------------------------------------------------
--When burst is terminated with NONSEQ, this NONSEQ transfer has to be processed
-- after current transfer(burs_term with write strobes as '0') is completed on 
-- AXI. So,the data on AHB is valid and has to be processed after the current
-- transfer completed.
--------------------------------------------------------------------------------
  BURST_TERM_WITH_NONSEQ_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then  
        ahb_data_valid_burst_term <= '0';
      else
        if(nonseq_txfer_pending = '1') then
          ahb_data_valid_burst_term <= '1';
        elsif(init_pending_txfer = '1') then
          ahb_data_valid_burst_term <= '0';
        else
          ahb_data_valid_burst_term <= ahb_data_valid_burst_term;
        end if;
      end if;
    end if;
  end process BURST_TERM_WITH_NONSEQ_REG;

--------------------------------------------------------------------------------
-- Also latch the ahb_hsize which will be used for
--  write strobe generation.
--  next_wr_strobe : Used to set the further write strobe value during the 
--                   narrow transfer.
-- We cannot use directly the ahb_hsize,since the ahb_hsize will be updated
--  every time a NONSEQ is detected,this will be an issue if there is
--  currently a transfer going on AXI.(This will occur during burst termination
--  case.)
--------------------------------------------------------------------------------
  AXI_NEXT_WR_STROBE_REG : process (S_AHB_HCLK) is 
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        next_wr_strobe     <= (others => '0');
      else
        if(ahb_wnr = '1') then
          next_wr_strobe <= ahb_hsize;
        else
          next_wr_strobe <= next_wr_strobe;
        end if;
      end if;
    end if;
  end process AXI_NEXT_WR_STROBE_REG;

--------------------------------------------------------------------------------
--Address control on AXI interface
--This process places the address control information on the AXI interface
--------------------------------------------------------------------------------
  AXI_AWVALID_REG : process (S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        M_AXI_AWVALID_i <= '0';
      else
        if(set_axi_waddr = '1' ) then
          M_AXI_AWVALID_i <= '1';
        elsif(M_AXI_AWREADY = '1') then
          M_AXI_AWVALID_i <= '0';
        else
          M_AXI_AWVALID_i <= M_AXI_AWVALID_i;
        end if;
      end if;
    end if;
  end process AXI_AWVALID_REG;

--------------------------------------------------------------------------------
--Pulse to indicate the address information PLACED on AXI.
--------------------------------------------------------------------------------
  AXI_AWADDR_DONE_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        axi_waddr_done_i <= '0';
      else
        if(set_axi_waddr = '1') then
          axi_waddr_done_i <= '1';
        else
          axi_waddr_done_i <= '0';
        end if;
      end if;
    end if;
  end process AXI_AWADDR_DONE_REG;
--------------------------------------------------------------------------------
-- Data control on AXI Interface
-- M_AXI_WVALID,M_AXI_WDATA
-- Asssert wvalid when the valid data present on AHB interface or 
-- data stored in local buffer and not yet placed on AXI during back pressure
-- from AXI.
-- Allow WVALID to be asserted during burst termination
-- Allow WVALID to be asserted if the burst-terminated with the NONSEQ,after
--  the current transfer is completed on AXI
--  as this will be the valid data for the pending transfer.
--------------------------------------------------------------------------------
  AXI_WVALID_REG : process ( S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        M_AXI_WVALID_i <= '0';
      else
        if(axi_wdata_done_i = '1') then
          M_AXI_WVALID_i <= '0';
        elsif(M_AXI_WVALID_i = '1' and M_AXI_WREADY = '0') then
          M_AXI_WVALID_i <= M_AXI_WVALID_i;
        elsif((ahb_wnr = '1' or set_axi_wdata_burst = '1')and  --Normal txfers
             (ahb_data_valid = '1' or local_en       = '1' )) or 
             (dummy_on_axi = '1')                             or --complete
                                                                --current burst
              (ahb_wnr = '1' and ahb_data_valid_burst_term = '1') --Pending 
                                                      -- nonseq transfer
              then
          M_AXI_WVALID_i <= '1';
        else
          M_AXI_WVALID_i <= '0';
        end if;
      end if;
    end if; 
  end process AXI_WVALID_REG;

  AXI_WDATA_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        M_AXI_WDATA_i   <= (others => '0');
      elsif(local_en = '1' and axi_wr_channel_ready_i = '1') then
          M_AXI_WDATA_i   <= local_wdata;
      elsif (axi_wr_channel_ready_i = '1') then
          M_AXI_WDATA_i   <= S_AHB_HWDATA;
      end if;
    end if;
  end process AXI_WDATA_REG;

--------------------------------------------------------------------------------
--Local data storage
-- Store the data from AHB if there is back pressure from AXI and a valid 
-- transfer is placed by AHB.
--------------------------------------------------------------------------------
  AXI_LOCAL_EN_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        local_en <= '0';
      else
        if( (axi_wr_channel_busy_i = '1' and
             ahb_data_valid      = '1'  ) or
            (local_en = '1' and
             axi_wr_data_sampled_i = '1' and
             ahb_data_valid        = '1') 
            ) then
          local_en <= '1';
        elsif(M_AXI_WREADY = '1') then
          local_en <= '0';
        end if;
      end if;
    end if;
  end process AXI_LOCAL_EN_REG;
--------------------------------------------------------------------------------
--To minimize the logic for the storage,always load the AHB data to local buffer
-- but limit the storage when the local_en is active.
--------------------------------------------------------------------------------
  AXI_WDATA_LOCAL_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        local_wdata  <= (others => '0');
      else
        if ( local_en   = '0' or
             (local_en = '1' and 
              axi_wr_data_sampled_i = '1' and 
              ahb_data_valid = '1')
           ) then
          local_wdata   <= S_AHB_HWDATA;
        end if; 
      end if;
    end if;
  end process AXI_WDATA_LOCAL_REG;
 
--------------------------------------------------------------------------------
-- Write strobe control on AXI side based on 
--  DATA_WIDTH generic,HSIZE,HADDR.
-- Below is the truth table.
-- D_WIDTH     HSIZE         HADDR  WSTRB
-- 32         000--Byte        0    0001
-- 32         000--Byte        1    0010
-- 32         000--Byte        2    0100
-- 32         000--Byte        3    1000
-- 32         001--Halfword    0    0011
-- 32         001--Halfword    2    1100
-- 32         010--Word        0    1111
-- 64         000--Byte        0    0000_0001
-- 64         000--Byte        1    0000_0010
-- 64         000--Byte        2    0000_0100
-- 64         000--Byte        3    0000_1000
-- 64         000--Byte        4    0001_0000
-- 64         000--Byte        5    0010_0000
-- 64         000--Byte        6    0100_0000
-- 64         000--Byte        7    1000_0000
-- 64         001--Halfword    0    0000_0011
-- 64         001--Halfword    2    0000_1100
-- 64         001--Halfword    4    0011_0000
-- 64         001--Halfword    6    1100_0000
-- 64         010--Word        0    0000_1111
-- 64         010--Word        4    1111_0000
-- 64         011--Doubleword  0    1111_1111
-- Check for NARROW Transfer support generic
-- If narrow transfer not required,force all Write strobes to '1'
-- Else force all write strobes to '0' and update the required fields
--  based on the case index values.
--------------------------------------------------------------------------------
  NARROW_TRANSFER_OFF : if (C_M_AXI_SUPPORTS_NARROW_BURST = 0) generate
  begin
    AXI_WSTRB_REG : process ( S_AHB_HCLK ) is
    begin
      if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
        if(S_AHB_HRESETN = '0') then
          M_AXI_WSTRB_i <= (others => '1');
        else
          if(dummy_on_axi = '1') then
            M_AXI_WSTRB_i <= (others => '0');
          else
            M_AXI_WSTRB_i <= (others => '1');
          end if;
        end if;
      end if;
    end process AXI_WSTRB_REG;
  end generate NARROW_TRANSFER_OFF;

--------------------------------------------------------------------------------
--WSTRB generation when data width is 32 and Narrow burst is 1
-- Init value of WSTRB depends on the lower 2-addr bits and lower 2- hsize bits
--------------------------------------------------------------------------------
  NARROW_TRANSFER_ON_DATA_WIDTH_32 : if ( C_M_AXI_SUPPORTS_NARROW_BURST = 1 and
                                          C_M_AXI_DATA_WIDTH = 32) generate
  begin
    AXI_WSTRB_REG : process ( S_AHB_HCLK ) is
    begin
      if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
        if(S_AHB_HRESETN = '0') then
          M_AXI_WSTRB_i <= (others => '1');
        else
          if(dummy_on_axi = '1' ) then
            M_AXI_WSTRB_i <= (others => '0');
          elsif( ahb_wnr             = '1') then
            M_AXI_WSTRB_i <= (others => '0'); 
            case   ahb_haddr_hsize (3 downto 0) is
              --Byte
              when "0000" =>
                M_AXI_WSTRB_i(3 downto 0) <= "0001";
              when "0100" =>
                M_AXI_WSTRB_i(3 downto 0) <= "0010";
              when "1000" =>
                M_AXI_WSTRB_i(3 downto 0) <= "0100";
              when "1100" =>
                M_AXI_WSTRB_i(3 downto 0) <= "1000";
              --Halfword
              when "0001" =>
                M_AXI_WSTRB_i(3 downto 0)  <= "0011";
              when "1001" =>
                M_AXI_WSTRB_i(3 downto 0)  <= "1100";
              --Word
              when "0010" =>
                M_AXI_WSTRB_i(3 downto 0)  <= "1111";
              when others =>
                M_AXI_WSTRB_i <= (others => '1'); 
            end case;
          elsif( M_AXI_WVALID_i = '1' and M_AXI_WREADY = '1') then
            case next_wr_strobe is
              when "00" =>
                M_AXI_WSTRB_i(3 downto 0) <= M_AXI_WSTRB_i(2 downto 0)&
                                             M_AXI_WSTRB_i(3);
              when "01" =>
                M_AXI_WSTRB_i(3 downto 0) <= M_AXI_WSTRB_i(1 downto 0)&
                                             M_AXI_WSTRB_i(3 downto 2);
              when "10" => 
                M_AXI_WSTRB_i             <= M_AXI_WSTRB_i;
              when others =>
                M_AXI_WSTRB_i <= M_AXI_WSTRB_i; 
            end case;
          end if;
        end if;
      end if;
    end process AXI_WSTRB_REG;
  end generate NARROW_TRANSFER_ON_DATA_WIDTH_32;

--------------------------------------------------------------------------------
--WSTRB generation when data width is 64 and Narrow burst is 1
-- Init value of WSTRB depends on the lower 3-addr bits and lower 2- hsize bits
--------------------------------------------------------------------------------
  NARROW_TRANSFER_ON_DATA_WIDTH_64 : if ( C_M_AXI_SUPPORTS_NARROW_BURST = 1 and
                                          C_M_AXI_DATA_WIDTH = 64) generate
  begin
    AXI_WSTRB_REG : process ( S_AHB_HCLK ) is
    begin
      if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
        if(S_AHB_HRESETN = '0') then
          M_AXI_WSTRB_i <= (others => '1');
          msb_in_wrap4  <= (others => '0');
        else
          if(dummy_on_axi = '1' ) then
            M_AXI_WSTRB_i <= (others => '0');
            msb_in_wrap4  <= (others => '0');
          elsif( ahb_wnr             = '1') then
            M_AXI_WSTRB_i <= (others => '0'); 
            msb_in_wrap4  <= (others => '0');
            case   ahb_haddr_hsize  is
              --Byte
              when "00000" =>
                M_AXI_WSTRB_i(7 downto 0) <= "00000001";
                msb_in_wrap4  <=  "011";
              when "00100" =>
                M_AXI_WSTRB_i(7 downto 0) <= "00000010";
                msb_in_wrap4  <=  "011";
              when "01000" =>
                M_AXI_WSTRB_i(7 downto 0) <= "00000100";
                msb_in_wrap4  <=  "011";
              when "01100" =>
                M_AXI_WSTRB_i(7 downto 0) <= "00001000";
                msb_in_wrap4  <=  "011";
              when "10000" =>
                M_AXI_WSTRB_i(7 downto 0) <= "00010000";
                msb_in_wrap4  <=  "111";
              when "10100" =>
                M_AXI_WSTRB_i(7 downto 0) <= "00100000";
                msb_in_wrap4  <=  "111";
              when "11000" =>
                M_AXI_WSTRB_i(7 downto 0) <= "01000000";
                msb_in_wrap4  <=  "111";
              when "11100" =>
                M_AXI_WSTRB_i(7 downto 0) <= "10000000";
                msb_in_wrap4  <=  "111";
              --Halfword
              when "00001" =>
                M_AXI_WSTRB_i(7 downto 0)  <= "00000011";
              when "01001" =>
                M_AXI_WSTRB_i(7 downto 0)  <= "00001100";
              when "10001" =>
                M_AXI_WSTRB_i(7 downto 0)  <= "00110000";
              when "11001" =>
                M_AXI_WSTRB_i(7 downto 0)  <= "11000000";
              --Word
              when "00010" =>
                M_AXI_WSTRB_i(7 downto 0)  <= "00001111";
              when "10010" =>
                M_AXI_WSTRB_i(7 downto 0)  <= "11110000";
              --Double word
              when "00011" =>
                M_AXI_WSTRB_i(7 downto 0)  <= "11111111";
              when others =>
                M_AXI_WSTRB_i <= (others => '1'); 
            end case;
          elsif( M_AXI_WVALID_i = '1' and M_AXI_WREADY = '1') then
            case next_wr_strobe is
              when "00" =>
                if(ahb_hburst_wrap4 = '0') then
                  M_AXI_WSTRB_i(7 downto 0) <= M_AXI_WSTRB_i(6 downto 0)&
                                               M_AXI_WSTRB_i(7);
                else
                  if(msb_in_wrap4 = "111") then
                    M_AXI_WSTRB_i(7 downto 4) <= M_AXI_WSTRB_i(6 downto 4)&
                                                 M_AXI_WSTRB_i(7);
                  else
                    M_AXI_WSTRB_i(3 downto 0) <= M_AXI_WSTRB_i(2 downto 0)&
                                                 M_AXI_WSTRB_i(3);
                  end if;
                end if;
              when "01" =>
                M_AXI_WSTRB_i(7 downto 0) <= M_AXI_WSTRB_i(5 downto 0)&
                                             M_AXI_WSTRB_i(7 downto 6);
              when "10" =>
                M_AXI_WSTRB_i(7 downto 0) <= M_AXI_WSTRB_i(3 downto 0)&
                                             M_AXI_WSTRB_i(7 downto 4);
              when "11" => 
                M_AXI_WSTRB_i             <= M_AXI_WSTRB_i;
              -- coverage off
              when others =>
                M_AXI_WSTRB_i <= (others => '1'); 
              -- coverage on
            end case;
          end if;
        end if;
      end if;
    end process AXI_WSTRB_REG;
  end generate NARROW_TRANSFER_ON_DATA_WIDTH_64;

--------------------------------------------------------------------------------
--M_AXI_WLAST generation.This signal is generated to indicate the last
-- trnasfer of the burst
-- During penultimate beat of the transfer,assert WLAST if there is already
-- next valid transfer on AHB.
-- Else, asssert WLAST when next valid transfer on AHB is available.
-- Reset WLAST after the last data beat is sampled by the AXI slave.
-- Once set,do not change WLAST till this is sampled by slave.
-- During burst termination assert WVALID for the rest of the transfers.
-- WSTRB  is tied to all zeros when initiating dummy transfer because
-- of burst termination on the AHB interface.
--------------------------------------------------------------------------------
  AXI_WLAST_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        M_AXI_WLAST_i <= '0';
      else
        if(axi_waddr_done_i = '1' and 
           (ahb_hburst_single = '1' or
            ahb_hburst_incr   = '1')) then
          M_AXI_WLAST_i <= '1';
        elsif( M_AXI_WREADY = '0' and M_AXI_WLAST_i = '1') then
          M_AXI_WLAST_i <= M_AXI_WLAST_i;
        elsif( M_AXI_WREADY = '1' and M_AXI_WLAST_i = '1') then
          M_AXI_WLAST_i <= '0';
        elsif(axi_penult_beat   = '1' ) then
          M_AXI_WLAST_i <= (ahb_data_valid or local_en or burst_term )and 
                            axi_wr_data_sampled_i;
        elsif(axi_last_beat = '1') then
          M_AXI_WLAST_i <= (ahb_data_valid  or local_en or burst_term ); 
        else
          M_AXI_WLAST_i <= M_AXI_WLAST_i;
        end if;
      end if;
    end if;
  end process AXI_WLAST_REG;

--------------------------------------------------------------------------------
--Latch the requested count(no.of data to be transferred) when starting a new
-- transaction on AXI
--------------------------------------------------------------------------------
  AXI_CNT_REQUIRED_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        axi_cnt_required  <= (others => '0');
      else
        if(ahb_wnr = '1') then
          axi_cnt_required <= valid_cnt_required;
        else 
          axi_cnt_required <= axi_cnt_required;
        end if;
      end if;
    end if;
  end process AXI_CNT_REQUIRED_REG;
--------------------------------------------------------------------------------
--Generate a penultimate signal to assert WLAST when next valid ahb-sample
-- is received.
-- assert when axi_penult_beat when last but 1 data is placed(NOT ACCEPTED)
-- on the AXI interface.
-- If the subsequent beat is also a valid data from AHB,core can assert
-- WLAST.
-- If the subsequent beat in not a valid data from AHB,WLAST should be delayed
-- till valid data is seen on AHB.WLAST during such situations is taken care
-- using axi_last_beat signal generation
--------------------------------------------------------------------------------
  AXI_PENULT_BEAT_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        axi_penult_beat <= '0';
      else
        if(burst_term = '1') and
          (axi_write_cnt_i = burst_term_txer_cnt-2 ) then
          axi_penult_beat <= axi_wr_data_sampled_i;
        elsif(axi_write_cnt_i = axi_cnt_required-2 ) then
          axi_penult_beat <= axi_wr_data_sampled_i;
        elsif(axi_wr_data_sampled_i = '1') then
          axi_penult_beat <= '0';
        end if;
      end if;
    end if;
  end process AXI_PENULT_BEAT_REG;

--------------------------------------------------------------------------------
--Assert axi_last_beat when N-1 required samples are accepeted by AXI.
-- Now if a further valid data is seen on AHB,this becomes the last
-- transfer of the burst.
-- [NOTES]The generation of the axi_penult_beat and axi_last_beat 
-- improves the timing as the count comparision is done ahead of 1 
-- clock and a single bit is used in the WLAST generation logic.
--------------------------------------------------------------------------------
  AXI_LAST_BEAT_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        axi_last_beat <= '0';
      else
        if(burst_term = '1')and
          (axi_write_cnt_i = burst_term_txer_cnt-1 ) then
          axi_last_beat <= axi_wr_data_sampled_i;
        elsif(axi_write_cnt_i = axi_cnt_required-1 ) then
          axi_last_beat <= axi_wr_data_sampled_i;
        elsif(axi_wr_data_sampled_i = '1') then
          axi_last_beat <= '0';
        end if;
      end if;
    end if;
  end process AXI_LAST_BEAT_REG;
--------------------------------------------------------------------------------
--To count the valid transfer placed on the AXI interface
--------------------------------------------------------------------------------
  AXI_WRITE_CNT_MODULE : entity ahblite_axi_bridge_v3_0_15.counter_f
     generic map(
       C_NUM_BITS    =>  AXI_WRITE_CNT_WIDTH,
       C_FAMILY      =>  C_FAMILY
         )
     port map(
       Clk           =>  S_AHB_HCLK,
       Rst           =>  cntr_rst,
       Load_In       =>  "00000" ,
       Count_Enable  =>  cntr_enable,
       Count_Load    =>  cntr_load,
       Count_Down    =>  '0',
       Count_Out     =>  axi_write_cnt_i,
       Carry_Out     =>  open
       );
     
--------------------------------------------------------------------------------
-- M_AXI_BREADY generation: 
-- Convey to slave that the bridge is ready to accept the transfer response
-- after placing the address information.De-assert after the response is seen
-- from AXI slave interface or timed out beacuse on NO response from AXI slave. 
--------------------------------------------------------------------------------
  AXI_BREADY_REG : process ( S_AHB_HCLK ) is 
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        M_AXI_BREADY_i <= '0';
      else
        if(axi_waddr_done_i = '1') then
          M_AXI_BREADY_i <= '1';
        elsif(M_AXI_BVALID = '1' or timeout_detected_i = '1') then
          M_AXI_BREADY_i <= '0';
        else
          M_AXI_BREADY_i <= M_AXI_BREADY_i;
        end if;
      end if;
    end if;
  end process AXI_BREADY_REG;

--------------------------------------------------------------------------------
-- Latch the timeout_i if occured during DATA or BRESP phases
--------------------------------------------------------------------------------
  TIMEOUT_IN_DATAPHASE_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        timeout_detected_i <= '0';
      else
        if(timeout_i = '1') then
          timeout_detected_i <= '1';
        else
          timeout_detected_i <= timeout_detected_i;
        end if;
      end if;
    end if;
  end process TIMEOUT_IN_DATAPHASE_REG;
end architecture RTL;


-------------------------------------------------------------------------------
-- axi_rchannel.vhd - entity/architecture pair
-------------------------------------------------------------------------------
-- ******************************************************************* 
-- ** (c) Copyright [2007] - [2011] Xilinx, Inc. All rights reserved.*
-- **                                                                *
-- ** This file contains confidential and proprietary information    *
-- ** of Xilinx, Inc. and is protected under U.S. and                *
-- ** international copyright and other intellectual property        *
-- ** laws.                                                          *
-- **                                                                *
-- ** DISCLAIMER                                                     *
-- ** This disclaimer is not a license and does not grant any        *
-- ** rights to the materials distributed herewith. Except as        *
-- ** otherwise provided in a valid license issued to you by         *
-- ** Xilinx, and to the maximum extent permitted by applicable      *
-- ** law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND        *
-- ** WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES    *
-- ** AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING      *
-- ** BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-         *
-- ** INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and       *
-- ** (2) Xilinx shall not be liable (whether in contract or tort,   *
-- ** including negligence, or under any other theory of             *
-- ** liability) for any loss or damage of any kind or nature        *
-- ** related to, arising under or in connection with these          *
-- ** materials, including for any direct, or any indirect,          *
-- ** special, incidental, or consequential loss or damage           *
-- ** (including loss of data, profits, goodwill, or any type of     *
-- ** loss or damage suffered as a result of any action brought      *
-- ** by a third party) even if such damage or loss was              *
-- ** reasonably foreseeable or Xilinx had been advised of the       *
-- ** possibility of the same.                                       *
-- **                                                                *
-- ** CRITICAL APPLICATIONS                                          *
-- ** Xilinx products are not designed or intended to be fail-       *
-- ** safe, or for use in any application requiring fail-safe        *
-- ** performance, such as life-support or safety devices or         *
-- ** systems, Class III medical devices, nuclear facilities,        *
-- ** applications related to the deployment of airbags, or any      *
-- ** other applications that could lead to death, personal          *
-- ** injury, or severe property or environmental damage             *
-- ** (individually and collectively, "Critical                      *
-- ** Applications"). Customer assumes the sole risk and             *
-- ** liability of any use of Xilinx products in Critical            *
-- ** Applications, subject only to applicable laws and              *
-- ** regulations governing limitations on product liability.        *
-- **                                                                *
-- ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS       *
-- ** PART OF THIS FILE AT ALL TIMES.                                *
-- ******************************************************************* 
--
-------------------------------------------------------------------------------
-- Filename:        axi_rchannel.vhd
-- Version:         v1.00a
-- Description:     This module generates the AXI read transactions based on 
--                  the control and ahb information received on ahb-side.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- ahblite_axi_bridge.vhd
--              -- ahblite_axi_bridge_pkg.vhd
--              -- ahblite_axi_control.vhd
--              -- ahb_if.vhd
--              -- ahb_data_counter.vhd
--              -- axi_wchannel.vhd
--              -- axi_rchannel.vhd
--              -- time_out.vhd
--
-------------------------------------------------------------------------------
-- Author:      Kondalarao P( kpolise@xilinx.com ) 
-- History:
-- Kondalarao P          12/22/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "reset", "resetn"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library ahblite_axi_bridge_v3_0_15;
use ahblite_axi_bridge_v3_0_15.ahblite_axi_bridge_pkg.all;
-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------

--
-- Definition of Generics
--
-- System Parameters
--
--  C_S_AHB_ADDR_WIDTH         -- Width of AHBLite address bus
--  C_M_AXI_ADDR_WIDTH         -- Width of AXI address bus
--  C_M_AXI_DATA_WIDTH         -- Width of AXI data buse
--  C_M_AXI_THREAD_ID_WIDTH    -- ID width of read and write channels 
--
-- Definition of Ports
--
-- AHB signals
--  S_AHB_HCLK               -- AHB Clock
--  S_AHB_HRESETN            -- AHB Reset Signal - active low

-- AHB interface signals
--  seq_detected             -- Valid SEQ transaction detected
--  busy_detected            -- Valid BUSY transaction detected
--  rvalid_rready            -- Read valid and can be captured - This signal 
--                              indicates that the required read data is
--                              available and the read
--                              transfer can complete
-- AXI Read address channel signals
--
--  M_AXI_ARVALID            -- Read address valid - This signal indicates,
--                              when HIGH, that the read address and control
--                              information is valid and will remain stable
--                              until the address acknowledge signal,ARREADY,
--                              is high.
--  M_AXI_ARREADY            -- Read address ready - This signal indicates
--                              that the slave is ready to accept an address
--                              and associated control signals:
--
-- AXI Read data channel signals
--
--  M_AXI_RVALID             -- Read valid - This signal indicates that the
--                              required read data is available and the read
--                              transfer can complete
--  M_AXI_RLAST              -- Read last. This signal indicates the 
--                           -- last transfer in a read burst
--  M_AXI_RREADY             -- Read ready - This signal indicates that the
--                              master can accept the read data and response
--                              information
-- Control signals based on state machine states.
--  set_axi_raddr            -- To set read addr on AXI interface
-- Timeout module.

-------------------------------------------------------------------------------
-- Generics & Signals Description
-------------------------------------------------------------------------------

entity axi_rchannel is
  generic (
    C_S_AHB_ADDR_WIDTH            : integer range 32 to 64    := 32;
    C_M_AXI_ADDR_WIDTH            : integer range 32 to 64    := 32;
    C_M_AXI_DATA_WIDTH            : integer range 32 to 64    := 32;
    C_M_AXI_THREAD_ID_WIDTH       : integer                   := 4 
    );
  port (
  -- AHB Signals
     S_AHB_HCLK            : in  std_logic;                           
     S_AHB_HRESETN         : in  std_logic;                           
  -- AHB interface signals
     seq_detected          : in  std_logic;
     busy_detected         : in  std_logic;
     rvalid_rready         : out std_logic;
     axi_rresp_err         : out std_logic_vector(1 downto 0);
     txer_rdata_to_ahb     : out std_logic;

  -- AXI Read Address Channel Signals
     M_AXI_ARVALID         : out std_logic;
     M_AXI_ARREADY         : in  std_logic;
  -- AXI Read Data Channel Signals
     M_AXI_RVALID          : in  std_logic;
     M_AXI_RLAST           : in  std_logic;
     M_AXI_RRESP           : in  std_logic_vector(1 downto 0);
     M_AXI_RREADY          : out std_logic;
  -- Timeout module
     rd_load_timeout_cntr  : out std_logic;
  -- AHB interface module.
     set_hresp_err         : in  std_logic;
  -- Control signals to/from state machine block
     last_axi_rd_sample    : out std_logic;
     set_axi_raddr         : in  std_logic 
    );

end entity axi_rchannel;
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of axi_rchannel is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
 -- Signal declarations(Description of each signal is given in their 
 --    implementation block
-------------------------------------------------------------------------------
signal M_AXI_ARVALID_i        : std_logic;
signal M_AXI_RREADY_i         : std_logic;
signal ahb_rd_txer_pending    : std_logic;
signal ahb_rd_req             : std_logic;
signal axi_rd_avlbl           : std_logic;
signal axi_rlast_valid        : std_logic;
signal axi_last_avlbl         : std_logic;
signal axi_rresp_avlbl        : std_logic_vector(1 downto 0);
signal seq_detected_d1        : std_logic;    
signal bridge_rd_in_progress  : std_logic;
signal rdata_placed_on_ahb    : std_logic;
signal rd_load_timeout_cntr_i : std_logic;
begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
    
--------------------------------------------------------------------------------
--O/P signal assignments
--------------------------------------------------------------------------------
  M_AXI_ARVALID        <= M_AXI_ARVALID_i;
  M_AXI_RREADY         <= M_AXI_RREADY_i;
  rd_load_timeout_cntr <= rd_load_timeout_cntr_i;
--------------------------------------------------------------------------------
-- Sample RDATA when a new sample is detected(RVALID and RREADY are '1'
--------------------------------------------------------------------------------
  rvalid_rready    <=  ((M_AXI_RREADY_i and 
                         M_AXI_RVALID   and
                         not busy_detected   and
                         not ahb_rd_txer_pending) or 
                        (ahb_rd_req and axi_rd_avlbl ));
  
  txer_rdata_to_ahb <= (M_AXI_RREADY_i and M_AXI_RVALID) ;

  -- RLAST is valid only when RVALID is high.This prevent spurious RLASTs 
  -- generated
  axi_rlast_valid   <=  (M_AXI_RLAST and M_AXI_RVALID);

  last_axi_rd_sample <= (axi_rlast_valid and not ahb_rd_txer_pending) or 
                         axi_last_avlbl ;

--------------------------------------------------------------------------------
-- Load fresh value to timeout counter once a valid sample is detected on AXI
--  side
--------------------------------------------------------------------------------
  rd_load_timeout_cntr_i <= (M_AXI_RREADY_i and M_AXI_RVALID);
--------------------------------------------------------------------------------
--Combinatorial block sampling the RRESP 
-- RRESP should be updated with the response from AXI when there are pending 
-- transfers created due to BUSY transfers in between the current transfer.
-- For cases where BUSY transfers are initiated, updated the axi_rresp_err
-- with the value captured when the axi_rd_avlbl is set.
--------------------------------------------------------------------------------
  AXI_RRESP_CMB :  process (M_AXI_RREADY_i      ,
                            M_AXI_RVALID        ,
                            ahb_rd_txer_pending ,
                            busy_detected       ,
                            M_AXI_RRESP         ,
                            ahb_rd_req          ,
                            axi_rd_avlbl        ,
                            axi_rresp_avlbl     
                           ) is
  begin
    if (M_AXI_RREADY_i      = '1' and 
        M_AXI_RVALID        = '1' and 
        busy_detected       = '0' and 
        ahb_rd_txer_pending = '0') then
       axi_rresp_err <= M_AXI_RRESP;
    elsif(ahb_rd_req   = '1' and 
          axi_rd_avlbl = '1' ) then
       axi_rresp_err <= axi_rresp_avlbl;
    else
       axi_rresp_err <= (others => '0');
    end if;
  end process AXI_RRESP_CMB;
--------------------------------------------------------------------------------
--Place address control ARVALID on AXI for read transactions
-- Reset after the address is accepted by AXI Slave.
--------------------------------------------------------------------------------
  AXI_ARVALID_REG : process (S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        M_AXI_ARVALID_i <= '0';
      else
        if(set_axi_raddr = '1' ) then
          M_AXI_ARVALID_i <= '1';
        elsif(M_AXI_ARREADY = '1') then
          M_AXI_ARVALID_i <= '0';
        else
          M_AXI_ARVALID_i <= M_AXI_ARVALID_i;
        end if;
      end if;
    end if;
  end process AXI_ARVALID_REG;

--------------------------------------------------------------------------------
--M_AXI_RREADY signal generation to accept the Read data from AXI interface
-- Start accepting read data after the address is placed on AXI. 
-- Stop accepting of the AHB is not ready to receive the data,conveying this
-- by giving BUSY transfers.
-- Start accepting againg if the SEQ transfer on AHB is detected after the 
-- BUSY transfer.
--------------------------------------------------------------------------------
  AXI_RREADY_REG : process ( S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        M_AXI_RREADY_i <= '0';
      else
        if( M_AXI_ARVALID_i = '1' and M_AXI_ARREADY = '1' ) then
          M_AXI_RREADY_i <= '1';
        elsif((axi_rlast_valid = '1' and M_AXI_RREADY_i = '1') or 
           busy_detected = '1' or
           set_hresp_err = '1' or
           (ahb_rd_txer_pending  = '1' and M_AXI_RVALID = '1' and
                                           M_AXI_RREADY_i = '1') or
            axi_rd_avlbl = '1') then
          M_AXI_RREADY_i <= '0';
         elsif(
                (seq_detected = '1') or
                (axi_rd_avlbl = '0' and ahb_rd_txer_pending = '1')
               ) then 
          M_AXI_RREADY_i <= '1';
        else
          M_AXI_RREADY_i <= M_AXI_RREADY_i;
        end if;
      end if;
    end if;
  end process AXI_RREADY_REG;

--------------------------------------------------------------------------------
--Additional processes to consider the back pressure from AHB by giving busy 
-- transfers in between the read transaction
--------------------------------------------------------------------------------
-- Logic description: 
--  a.Ensure the current request is read
--  b.Hunt for any BUSY transfer from AHB during the read transfer progress
--    phase.
--  c.Once detected - 2 possible case can happen at this instance
--      c.1: Read data from AXI is also received at the same time as busy 
--           detected. So donot allow axi interface to accepte more data
--           by keeping AXI_RREADY low.
--      c.2: Read is not yet available. Allow AXI interface to accept ONE
--           new data by asserting AXI_RREADY 
--  d.Now we need to ensure 2 conditions to happens
--    d.1 There is new sequential request is initiated from AHB and
--    d.2 Read data is available from AXI(following steps c.1 and c.2)
--  e.Once the conditions in (d) are satisfied,transfer the read data from
--    AHB to AXI
--    transfer
-- Following process acheives this functionality
--------------------------------------------------------------------------------

  BRIDGE_RD_IN_PROGRESS_REG: process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        bridge_rd_in_progress <= '0';
      else
        if(M_AXI_ARVALID_i = '1') then
          bridge_rd_in_progress <= '1';
        elsif(axi_rlast_valid = '1' and M_AXI_RREADY_i = '1') then
          bridge_rd_in_progress <= '0';
        else
          bridge_rd_in_progress <= bridge_rd_in_progress;
        end if;
      end if;
    end if;
  end process BRIDGE_RD_IN_PROGRESS_REG;

  AHB_RD_REQ_PENDING_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        ahb_rd_txer_pending <= '0';
      else
        if(ahb_rd_req = '1' and axi_rd_avlbl = '1') then
          ahb_rd_txer_pending <= '0';
        elsif(busy_detected = '1' and bridge_rd_in_progress = '1') then
          ahb_rd_txer_pending <= '1';
        else
          ahb_rd_txer_pending <= ahb_rd_txer_pending;
        end if;
      end if;
    end if;
  end process AHB_RD_REQ_PENDING_REG;

  AHB_RD_REQ_REG : process (S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        ahb_rd_req <= '0';
      else
        if(axi_rd_avlbl        = '1' and
           ahb_rd_txer_pending = '1' and 
           ahb_rd_req          = '1') then
          ahb_rd_req <= '0';
        elsif(seq_detected = '1' and seq_detected_d1 = '0') then
          ahb_rd_req <= ahb_rd_txer_pending;
        else 
          ahb_rd_req <= ahb_rd_req;
        end if;
      end if;
    end if;
  end process AHB_RD_REQ_REG;
 
  AXI_RD_DATA_AVLBL_REG: process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        axi_rd_avlbl    <= '0';
        axi_last_avlbl  <= '0';
        axi_rresp_avlbl <= (others => '0');
      else
        if(ahb_rd_req = '1' and axi_rd_avlbl = '1') then
          axi_rd_avlbl    <= '0';
          axi_last_avlbl  <= '0';
          axi_rresp_avlbl <= (others => '0');
        elsif((ahb_rd_txer_pending = '1' 
           or busy_detected = '1'
          ) and
              (M_AXI_RREADY_i = '1' and M_AXI_RVALID = '1')) then 
          axi_rd_avlbl   <= '1';
          axi_last_avlbl <= axi_rlast_valid;
          axi_rresp_avlbl<= M_AXI_RRESP;
        else
          axi_rd_avlbl   <= axi_rd_avlbl;
          axi_last_avlbl <= axi_last_avlbl;
          axi_rresp_avlbl<= axi_rresp_avlbl;
        end if;
      end if;
    end if;
  end process AXI_RD_DATA_AVLBL_REG;
 
  RDATA_SAMPLED_TO_AXI_REG: process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        rdata_placed_on_ahb <= '0';
      else
        if(busy_detected = '1' and
           (M_AXI_RREADY_i = '1' and M_AXI_RVALID = '1')) then 
          rdata_placed_on_ahb <= '1';
        elsif(ahb_rd_txer_pending = '0') then
          rdata_placed_on_ahb <= '0';
        else
          rdata_placed_on_ahb <= rdata_placed_on_ahb;
        end if; 
      end if;
    end if;
  end process RDATA_SAMPLED_TO_AXI_REG;

  SEQ_DETECTED_D1_REG: process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        seq_detected_d1 <= '0';
      else
        seq_detected_d1 <= seq_detected;
      end if;
    end if;
  end process  SEQ_DETECTED_D1_REG;
end architecture RTL;


-------------------------------------------------------------------------------
-- ahb_if.vhd - entity/architecture pair
-------------------------------------------------------------------------------
-- ******************************************************************* 
-- ** (c) Copyright [2007] - [2011] Xilinx, Inc. All rights reserved.*
-- **                                                                *
-- ** This file contains confidential and proprietary information    *
-- ** of Xilinx, Inc. and is protected under U.S. and                *
-- ** international copyright and other intellectual property        *
-- ** laws.                                                          *
-- **                                                                *
-- ** DISCLAIMER                                                     *
-- ** This disclaimer is not a license and does not grant any        *
-- ** rights to the materials distributed herewith. Except as        *
-- ** otherwise provided in a valid license issued to you by         *
-- ** Xilinx, and to the maximum extent permitted by applicable      *
-- ** law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND        *
-- ** WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES    *
-- ** AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING      *
-- ** BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-         *
-- ** INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and       *
-- ** (2) Xilinx shall not be liable (whether in contract or tort,   *
-- ** including negligence, or under any other theory of             *
-- ** liability) for any loss or damage of any kind or nature        *
-- ** related to, arising under or in connection with these          *
-- ** materials, including for any direct, or any indirect,          *
-- ** special, incidental, or consequential loss or damage           *
-- ** (including loss of data, profits, goodwill, or any type of     *
-- ** loss or damage suffered as a result of any action brought      *
-- ** by a third party) even if such damage or loss was              *
-- ** reasonably foreseeable or Xilinx had been advised of the       *
-- ** possibility of the same.                                       *
-- **                                                                *
-- ** CRITICAL APPLICATIONS                                          *
-- ** Xilinx products are not designed or intended to be fail-       *
-- ** safe, or for use in any application requiring fail-safe        *
-- ** performance, such as life-support or safety devices or         *
-- ** systems, Class III medical devices, nuclear facilities,        *
-- ** applications related to the deployment of airbags, or any      *
-- ** other applications that could lead to death, personal          *
-- ** injury, or severe property or environmental damage             *
-- ** (individually and collectively, "Critical                      *
-- ** Applications"). Customer assumes the sole risk and             *
-- ** liability of any use of Xilinx products in Critical            *
-- ** Applications, subject only to applicable laws and              *
-- ** regulations governing limitations on product liability.        *
-- **                                                                *
-- ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS       *
-- ** PART OF THIS FILE AT ALL TIMES.                                *
-- ******************************************************************* 
--
-------------------------------------------------------------------------------
-- Filename:        ahb_if.vhd
-- Version:         v1.00a
-- Description:     This modules interfaces with the AHB side of the 
--                  bridge and generates/receives AHB signals.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- ahblite_axi_bridge.vhd
--              -- ahblite_axi_bridge_pkg.vhd
--              -- ahblite_axi_control.vhd
--              -- ahb_if.vhd
--              -- ahb_data_counter.vhd
--              -- axi_wchannel.vhd
--              -- axi_rchannel.vhd
--              -- time_out.vhd
-------------------------------------------------------------------------------
-- Author:      Kondalarao P( kpolise@xilinx.com ) 
-- History:
-- Kondalarao P          11/24/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------

-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "reset", "resetn"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library ahblite_axi_bridge_v3_0_15;
use ahblite_axi_bridge_v3_0_15.ahblite_axi_bridge_pkg.all;
-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------

--
-- Definition of Ports
--
-- System signals
-- AHB signals
--  S_AHB_HCLK               -- AHB Clock
--  S_AHB_HRESETN            -- AHB Reset Signal - active low
--  S_AHB_HADDR              -- AHB address bus
--  S_AHB_HSEL               -- Slave select signal for AHB interface
--  S_AHB_HTRANS             -- Indicates the type of the current transfer
--  S_AHB_HSIZE              -- Indicates the size of the transfer 
--  S_AHB_HWRITE             -- Direction indicates an AHB write access when
--                              high and an AHB read access when low
--  S_AHB_HBURST             -- Indicates if the transfer forms part of a burst
--  S_AHB_HREADY_IN          -- Ready signal from the system 
--  S_AHB_HREADY_OUT         -- Ready, AHB slave uses this signal to 
--                               qualify the input signals
--  S_AHB_HPROT              -- This signal indicates the normal,
--                              privileged, or secure protection level of the
--                              transaction and whether the transaction is a
--                              data access or an instruction access.
--  S_AHB_HRESP              -- This signal indicates transfer response.
--  S_AHB_HRDATA             -- AHB read data driven by slave  
-- 
--  ahb_if module
--  core_is_idle             -- Core is in IDLE state
--  nonseq_detected          -- Valid NONSEQ transaction detected
--  seq_detected             -- Valid SEQ transaction detected
--  busy_detected            -- Valid BUSY transaction detected
--  set_hready               -- Assert HREADY_OUT   
--  reset_hready             -- De-assert HREADY_OUT
--  set_hresp_err            -- Assert HRESP as ERROR
--  reset_hresp_err          -- De-assert HRESP as ERROR 

-- Write channel signals
--  M_AXI_AWID               -- Write address ID. This signal is the 
--                           -- identification tag for the write 
--                           -- address group of signals
--  M_AXI_AWLEN              -- Burst length. The burst length gives the
--                           -- exact number of transfers in a burst
--  M_AXI_AWSIZE             -- Burst size. This signal indicates the 
--                           -- size of each transfer in the burst
--  M_AXI_AWBURST            -- Burst type. The burst type, coupled with 
--                           -- the size information, details how the 
--                           -- address for each transfer within the 
--                           -- burst is calculated
--  M_AXI_AWCACHE            -- Cache type. This signal indicates the 
--                           -- bufferable,cacheable, write-through, 
--                           -- write-back,and allocate attributes of the 
--                           -- transaction 
--  M_AXI_AWADDR             -- Write address bus - The write address bus gives
--                              the address of the first transfer in a write
--                              burst transaction - fixed to 32
--  M_AXI_AWPROT             -- Protection type - This signal indicates the
--                              normal, privileged, or secure protection level
--                              of the transaction and whether the transaction
--                              is a data access or an instruction access
--  M_AXI_AWLOCK             -- Lock type. This signal provides additional 
                             -- information about the atomic characteristics
                             -- of the transfer
--  burst_term               -- Indicates burst termination on AHB side.
--  ahb_hburst_single        -- Transfer on AHB is SINGLE
--  ahb_hburst_incr          -- Transfer on AHB is INCR
--  ahb_hburst_wrap4         -- Transfer on AHB is WRAP4
--  ahb_haddr_hsize          -- Lower 3-bits of ADDR and lower 2-bits of
--                               HSIZE to determine WSTRB intial value.
--  ahb_hsize                -- Lower 2-bits of HSIZE to determine 
--                              sub sequent values of WSTRB
--  valid_cnt_required       -- Required number of transfers for the selected
--  ahb_data_valid           -- Control signal indicating the data on the AHB
--                              can be used.
--  M_AXI_ARID               -- Read address ID. This signal is the 
--                           -- identification tag for the read address 
--                           -- group of signals
--  M_AXI_ARLEN              -- Burst length. The burst length gives the exact
--                           --  number of transfers in a burst
--  M_AXI_ARSIZE             -- Burst size. This signal indicates the size of 
                             -- each transfer in the burst
--  M_AXI_ARBURST            -- Burst type. The burst type, coupled with the 
--                           -- size information, details how the address for
                             -- each transfer within the burst is calculated
--  M_AXI_ARPROT             -- Protection type - This signal provides
--                              protection unit information for the transaction
--  M_AXI_ARCACHE            -- Cache type. This signal provides additional 
--                           --  information about the cacheable 
--                           --  characteristics of the transfer
--  M_AXI_ARADDR             -- Read address - The read address bus gives the
--                              initial address of a read burst transaction
--  M_AXI_ARLOCK             -- Lock type. This signal provides additional 
                             -- information about the atomic characteristics
                             -- of the transfer
--  txer_rdata_to_ahb        -- Read valid and can be captured - This signal 
--                              indicates that the required read data is
--                              available and the read
--                              transfer can complete
--  timeout_i                -- Timeout signal from the timeout module
-------------------------------------------------------------------------------
-- Generics & Signals Description
-------------------------------------------------------------------------------

entity ahb_if is
  generic (
    C_S_AHB_ADDR_WIDTH           : integer range 32 to 64  := 32;
    C_M_AXI_ADDR_WIDTH           : integer range 32 to 64  := 32;
    C_S_AHB_DATA_WIDTH           : integer range 32 to 64  := 32;
    C_M_AXI_DATA_WIDTH           : integer range 32 to 64  := 32;
    C_M_AXI_THREAD_ID_WIDTH      : integer                 := 4;  
    C_M_AXI_NON_SECURE           : integer                 := 1  
  );
  port (
  -- AHB Signals
     S_AHB_HCLK             : in  std_logic;                           
     S_AHB_HRESETN          : in  std_logic;                           
     S_AHB_HADDR            : in  std_logic_vector
                                  (C_S_AHB_ADDR_WIDTH-1 downto 0);
     S_AHB_HSEL             : in  std_logic;
     S_AHB_HTRANS           : in  std_logic_vector(1 downto 0); 
     S_AHB_HSIZE            : in  std_logic_vector(2 downto 0); 
     S_AHB_HWRITE           : in  std_logic; 
     S_AHB_HBURST           : in  std_logic_vector(2 downto 0 );
     S_AHB_HREADY_IN        : in  std_logic;  
     S_AHB_HREADY_OUT       : out std_logic; 
     S_AHB_HPROT            : in  std_logic_vector(3 downto 0); 
     S_AHB_HRESP            : out std_logic;
     S_AHB_HRDATA           : out std_logic_vector
                                  (C_S_AHB_DATA_WIDTH-1 downto 0 );
  -- AHB interface module 
     core_is_idle           : in  std_logic;
     ahb_valid_cnt          : in  std_logic_vector(4 downto 0);
     ahb_hwrite             : out std_logic;
  -- control module
     nonseq_detected        : out std_logic;
     seq_detected           : out std_logic;
     busy_detected          : out std_logic;
     set_hready             : in  std_logic;
     reset_hready           : in  std_logic;
     set_hresp_err          : in  std_logic;
     reset_hresp_err        : in  std_logic;
     nonseq_txfer_pending   : out std_logic;
     idle_txfer_pending     : out std_logic;
     burst_term_hwrite      : out std_logic;
     burst_term_single_incr : out std_logic;
     init_pending_txfer     : in  std_logic;
  
  -- AXI Write channel 
     M_AXI_AWID             : out std_logic_vector 
                                  (C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
     M_AXI_AWLEN            : out std_logic_vector (7 downto 0);
     M_AXI_AWSIZE           : out std_logic_vector (2 downto 0);
     M_AXI_AWBURST          : out std_logic_vector (1 downto 0);
     M_AXI_AWCACHE          : out std_logic_vector (3 downto 0);
     M_AXI_AWADDR           : out std_logic_vector
                                  (C_M_AXI_ADDR_WIDTH-1 downto 0);
     M_AXI_AWPROT           : out std_logic_vector(2 downto 0);
     M_AXI_AWLOCK           : out std_logic;
     axi_wdata_done         : in  std_logic;    
     timeout_detected       : in  std_logic;
     last_axi_rd_sample     : in  std_logic;
     burst_term             : out std_logic;
     ahb_hburst_single      : out std_logic;
     ahb_hburst_incr        : out std_logic;
     ahb_hburst_wrap4       : out std_logic;
     ahb_haddr_hsize        : out std_logic_vector( 4 downto 0);
     ahb_hsize              : out std_logic_vector( 1 downto 0);
     valid_cnt_required     : out std_logic_vector(4 downto 0);
     burst_term_txer_cnt    : out std_logic_vector(4 downto 0);
     burst_term_cur_cnt     : out std_logic_vector(4 downto 0);
     ahb_data_valid         : out std_logic;
  
     placed_on_axi          : in  std_logic;
     placed_in_local_buf    : in  std_logic;
  -- AXI Read channel 
     M_AXI_ARID             : out std_logic_vector 
                                  (C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
     M_AXI_ARLEN            : out std_logic_vector(7 downto 0);
     M_AXI_ARSIZE           : out std_logic_vector(2 downto 0);
     M_AXI_ARBURST          : out std_logic_vector(1 downto 0);
     M_AXI_ARPROT           : out std_logic_vector(2 downto 0);
     M_AXI_ARCACHE          : out std_logic_vector(3 downto 0);
     M_AXI_ARADDR           : out std_logic_vector
                                  (C_M_AXI_ADDR_WIDTH-1 downto 0);
     M_AXI_ARLOCK           : out std_logic;
     txer_rdata_to_ahb      : in  std_logic;
     M_AXI_RDATA            : in  std_logic_vector
                                 (C_M_AXI_DATA_WIDTH-1 downto 0 ) 
    );

end entity ahb_if;
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of ahb_if is
-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";


-------------------------------------------------------------------------------
 -- Signal declarations(Description of each signal is given in their 
 --    implementation block
-------------------------------------------------------------------------------
signal S_AHB_HREADY_OUT_i       : std_logic;
signal S_AHB_HRESP_i            : std_logic;
signal S_AHB_HRDATA_i           : std_logic_vector
                                   (C_S_AHB_DATA_WIDTH-1 downto 0 ); 
signal S_AHB_HBURST_i           : std_logic_vector ( 2 downto 0);
signal S_AHB_HSIZE_i            : std_logic_vector ( 2 downto 0);

signal valid_cnt_required_i     : std_logic_vector( 4 downto 0);
signal burst_term_txer_cnt_i    : std_logic_vector( 4 downto 0);
signal burst_term_cur_cnt_i     : std_logic_vector( 4 downto 0);
signal ahb_data_valid_i         : std_logic;
signal burst_term_i             : std_logic;
signal dummy_txfer_in_progress  : std_logic;
signal nonseq_detected_i        : std_logic;
signal seq_detected_i           : std_logic;
signal busy_detected_i          : std_logic;
signal idle_detected_i          : std_logic;
signal ahb_hburst_single_i      : std_logic;
signal ahb_hburst_incr_i        : std_logic;
signal ahb_hburst_wrap4_i       : std_logic;
signal ongoing_burst            : std_logic; 
signal ahb_burst_done           : std_logic;
signal ahb_penult_beat          : std_logic;
signal seq_rd_in_incr           : std_logic;
signal burst_term_with_nonseq   : std_logic;
signal burst_term_with_idle     : std_logic;
signal ahb_wr_burst_done        : std_logic;
signal ahb_done_axi_in_progress : std_logic; 
signal nonseq_txfer_pending_i   : std_logic;

--signal AXI_AID_i       : std_logic_vector  
--                            (C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
signal AXI_ALEN_i      : std_logic_vector (7 downto 0);
signal AXI_ASIZE_i     : std_logic_vector (2 downto 0);
signal AXI_ABURST_i    : std_logic_vector (1 downto 0);
signal AXI_APROT_i     : std_logic_vector(2 downto 0);
signal AXI_ACACHE_i    : std_logic_vector (3 downto 0);
signal AXI_AADDR_i     : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
--signal AXI_ALOCK_i     : std_logic;
begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
    
--------------------------------------------------------------------------------
-- I/O signal assignements
--------------------------------------------------------------------------------
S_AHB_HREADY_OUT     <= S_AHB_HREADY_OUT_i;
S_AHB_HRESP          <= S_AHB_HRESP_i;
S_AHB_HRDATA         <= S_AHB_HRDATA_i;
valid_cnt_required   <= valid_cnt_required_i;
burst_term_txer_cnt  <= burst_term_txer_cnt_i;
burst_term_cur_cnt   <= burst_term_cur_cnt_i;
ahb_data_valid       <= ahb_data_valid_i;
burst_term           <= burst_term_i;
nonseq_detected      <= nonseq_detected_i;
seq_detected         <= seq_detected_i;
busy_detected        <= busy_detected_i;
ahb_hburst_single    <= ahb_hburst_single_i;
ahb_hburst_incr      <= ahb_hburst_incr_i;
ahb_hburst_wrap4     <= ahb_hburst_wrap4_i;


--------------------------------------------------------------------------------
-- Address control information for write and read channel.
-- Address control information is set using the same flop output
-- for both channels, corresponding WVALID will be asserted 
-- based on read or write transaction.(This minimises the flops required
-- on both the channels)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Write channel assignment
--------------------------------------------------------------------------------
M_AXI_AWID       <= (others => '0' );       
M_AXI_AWLEN      <= AXI_ALEN_i;      
M_AXI_AWSIZE     <= AXI_ASIZE_i;     
M_AXI_AWBURST    <= AXI_ABURST_i;    
M_AXI_AWPROT     <= AXI_APROT_i;     
M_AXI_AWCACHE    <= AXI_ACACHE_i;    
M_AXI_AWADDR     <= AXI_AADDR_i;     
M_AXI_AWLOCK     <= '0' ;  

--------------------------------------------------------------------------------
--Signals used to determine the initial and sub-sequent value for WSTRB
-- signals in write channel
--------------------------------------------------------------------------------
ahb_haddr_hsize  <= AXI_AADDR_i(2 downto 0)&S_AHB_HSIZE_i(1 downto 0);
ahb_hsize        <= S_AHB_HSIZE_i(1 downto 0);

--------------------------------------------------------------------------------
-- Read channel assignment
--------------------------------------------------------------------------------
M_AXI_ARID       <= (others => '0' );       
M_AXI_ARLEN      <= AXI_ALEN_i;      
M_AXI_ARSIZE     <= AXI_ASIZE_i;     
M_AXI_ARBURST    <= AXI_ABURST_i;    
M_AXI_ARPROT     <= AXI_APROT_i;     
M_AXI_ARCACHE    <= AXI_ACACHE_i;    
M_AXI_ARADDR     <= AXI_AADDR_i;     
M_AXI_ARLOCK     <= '0' ;     
--------------------------------------------------------------------------------
-- Signal to assert when a valid nonseq transfer on AHB interface is detected.
--------------------------------------------------------------------------------
nonseq_detected_i  <= '1' when 
                          ( S_AHB_HREADY_IN = '1' and 
                            S_AHB_HSEL      = '1' and
                            S_AHB_HTRANS    = NONSEQ)
                          else '0';
--------------------------------------------------------------------------------
-- Signal to assert when a valid seq transfer on AHB interface is detected.
--------------------------------------------------------------------------------
seq_detected_i     <= '1' when 
                          ( S_AHB_HREADY_IN = '1' and
                            S_AHB_HSEL      = '1' and
                            S_AHB_HTRANS    = SEQ)
                          else '0';

--------------------------------------------------------------------------------
-- Signal to assert when a valid busy transfer on AHB interface is detected.
--------------------------------------------------------------------------------
busy_detected_i     <= '1' when 
                          ( S_AHB_HREADY_IN = '1' and
                            S_AHB_HSEL      = '1' and
                            S_AHB_HTRANS    = BUSY)
                          else '0';

--------------------------------------------------------------------------------
-- Signal to assert when a valid idle transfer on AHB interface is detected
--------------------------------------------------------------------------------
idle_detected_i      <= '1' when 
                          ( S_AHB_HREADY_IN = '1' and
                            S_AHB_HSEL      = '1' and
                            S_AHB_HTRANS    = IDLE)
                          else '0';
 
--------------------------------------------------------------------------------
--Sample the HWRITE signal to be used by other modules 
--------------------------------------------------------------------------------
ahb_hwrite <= S_AHB_HWRITE;
 
--------------------------------------------------------------------------------
-- Required number of ahb-samples for a given burst are received
-- when the penultimate beat is set and next valid sequential transfer
-- is detected.
--------------------------------------------------------------------------------
ahb_burst_done <= ahb_penult_beat and seq_detected_i;

--------------------------------------------------------------------------------
--Do not receive further samples from when the required number of samples
-- for the current transfer are received and AXI is still processing the
-- transfer
--------------------------------------------------------------------------------
ahb_wr_burst_done <= (S_AHB_HWRITE and 
                     ahb_burst_done )  or ahb_done_axi_in_progress ;

--------------------------------------------------------------------------------
--Treat INCR READ transfer as SINGLE transfers on AXI.So limit AHB to place
-- further till the current SEQ transfer is processed by AXI
--------------------------------------------------------------------------------
seq_rd_in_incr <= seq_detected_i  and (not S_AHB_HWRITE)  and ahb_hburst_incr_i;

--------------------------------------------------------------------------------
--Burst transfer terminated due new NONSEQ on AHB
--------------------------------------------------------------------------------
burst_term_with_nonseq <= ongoing_burst and nonseq_detected_i;

--------------------------------------------------------------------------------
--Burst transfer terminated due new IDLE on AHB
--------------------------------------------------------------------------------
burst_term_with_idle  <= ongoing_burst and idle_detected_i;

--------------------------------------------------------------------------------
-- Burst is said to be ongoing,once the core started operating
--  (core_is_idle = '0') ,required number of samples from AHB
--  interface are not yet received, for any of the valid burst types.
--  Burst termination for INCR (indefinite length increment) is 
--  considered seperately.For indefinite length increment burst
--  termination,core does not need to send/receive the dummy transfer
--  on AXI,as INCR transfer is mapped to SINGLE transfer on AXI 
--------------------------------------------------------------------------------
ongoing_burst  <= '1' when
            (core_is_idle = '0' and 
             (ahb_burst_done = '0'   or
              ahb_done_axi_in_progress = '0')
            ) else '0';

--------------------------------------------------------------------------------
--Signal to indicate that the burst terminated with NONSEQ and this transfer
-- has to be serviced after the current burst termination transfer is completed.
--------------------------------------------------------------------------------
  nonseq_txfer_pending <= nonseq_txfer_pending_i;

--------------------------------------------------------------------------------
--Sample AHB signals required 
-- These signals are sampled at the start of the transfer and are valid
-- through out the transfer.
-- The sampled signals are used during burst trasfers to count
-- valid number of samples,initialize WSTRB signals etc.,
--------------------------------------------------------------------------------
   AHB_BURST_SIZE_PROT_REG : process ( S_AHB_HCLK ) is 
   begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        S_AHB_HBURST_i <= (others => '0');
        S_AHB_HSIZE_i  <= (others => '0');
        ahb_hburst_single_i <= '0';
        ahb_hburst_incr_i   <= '0';
        ahb_hburst_wrap4_i  <= '0';
      else
        --if (S_AHB_HTRANS    = NONSEQ) then
        if (S_AHB_HTRANS    = NONSEQ and S_AHB_HREADY_OUT_i = '1') then
          S_AHB_HBURST_i <= S_AHB_HBURST;
          S_AHB_HSIZE_i  <= S_AHB_HSIZE;
          if(S_AHB_HBURST = SINGLE) then
            ahb_hburst_single_i <= '1'; 
          else
            ahb_hburst_single_i <= '0';
          end if; 
          if(S_AHB_HBURST = INCR) then
            ahb_hburst_incr_i <= '1'; 
          else
            ahb_hburst_incr_i <= '0';
          end if; 
          if(S_AHB_HBURST = WRAP4) then
            ahb_hburst_wrap4_i <= '1'; 
          else
            ahb_hburst_wrap4_i <= '0';
          end if; 
        else 
          S_AHB_HBURST_i      <= S_AHB_HBURST_i;
          S_AHB_HSIZE_i       <= S_AHB_HSIZE_i;
          ahb_hburst_single_i <= ahb_hburst_single_i;
          ahb_hburst_incr_i   <= ahb_hburst_incr_i  ;
          ahb_hburst_wrap4_i  <= ahb_hburst_wrap4_i ;
        end if;
      end if;
    end if;
   end process AHB_BURST_SIZE_PROT_REG;

--------------------------------------------------------------------------------
--valid_cnt_required:To set the valid count required count for
-- INCR4/8/16 and WRAP 4/8/16 transfers
-- This count is the required number of samples to be received
-- from the AHB side for the current burst.
--------------------------------------------------------------------------------
  VALID_COUNTER_REG : process ( S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        valid_cnt_required_i <= (others => '0');
      else
        if( nonseq_detected_i = '1' ) then
          case S_AHB_HBURST is 
            when INCR4|WRAP4 =>
              valid_cnt_required_i <= INCR_WRAP_4;
            when INCR8|WRAP8 =>
              valid_cnt_required_i <= INCR_WRAP_8;
            when INCR16|WRAP16 =>
              valid_cnt_required_i <= INCR_WRAP_16;
            when others =>
              valid_cnt_required_i <= (others => '0');
          end case;
        else 
          valid_cnt_required_i <= valid_cnt_required_i;
        end if;
      end if;
    end if;
  end process VALID_COUNTER_REG;

--------------------------------------------------------------------------------
-- ahb_data_valid:Generated to indicate the AXI write channel that
-- the valid data present on AHB bus.
--------------------------------------------------------------------------------
  AHB_DATA_VALID_REG : process (S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        ahb_data_valid_i <= '0';
      else
        if (nonseq_detected_i = '1' or seq_detected_i = '1')then
          ahb_data_valid_i <= '1';
        elsif(busy_detected_i     = '1' or 
              idle_detected_i     = '1' or
              placed_on_axi       = '1' or
              placed_in_local_buf = '1'
              ) then
          ahb_data_valid_i <= '0';
        end if;
      end if;
    end if;
  end process AHB_DATA_VALID_REG;

--------------------------------------------------------------------------------
--To detect the penultimate beat of the AHB burst transfer
-- Hold this detection till the next valid sequential transfer is 
-- detected.
--------------------------------------------------------------------------------
  AHB_PENULT_BEAT_REG : process ( S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        ahb_penult_beat <= '0';
      else
        if(ahb_valid_cnt = valid_cnt_required_i-1) then
          ahb_penult_beat <= seq_detected_i;
        elsif(seq_detected_i    = '1' or -- Normal txfers
              nonseq_detected_i = '1' or -- Burst-term
              idle_detected_i   = '1'    -- Burst-term
             ) then
          ahb_penult_beat <= '0';
        end if;
      end if;
    end if;
  end process AHB_PENULT_BEAT_REG;

--------------------------------------------------------------------------------
--To limit acceptance of further samples from AHB after
-- required number of samples for the current burst are received
-- and the transfer on the AXI is in progress
--------------------------------------------------------------------------------
  AHB_DONE_AXI_PENDING_REG : process ( S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        ahb_done_axi_in_progress <= '0';
      else
        if(ahb_burst_done = '1') then
          ahb_done_axi_in_progress <= '1';
        elsif(axi_wdata_done = '1') then
          ahb_done_axi_in_progress <= '0';
        end if;
      end if;
    end if;
  end process AHB_DONE_AXI_PENDING_REG;

--------------------------------------------------------------------------------
--HREADY signal generation: 
-- set_hready and reset_hready are generated from the state machine
-- Before resetting,check for if the current placed transfer on AHB is busy 
-- transfer,in which case bridge needs to zero wait state response to BUSY
-- transfer.
-- To reset on sequential detection during writes and during reads
--  of indefinite length increment trasfer is controlled explicity.
-- When the required number of samples received for a particular burst during 
-- writes,HREADY is forced low till the response is given from the AXI interface
-- During timeout detection close the transaction with ERROR response.
--------------------------------------------------------------------------------
  AHB_HREADY_REG : process ( S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        S_AHB_HREADY_OUT_i <= '1';
      else
        if((timeout_detected = '0') and 
           (seq_rd_in_incr         = '1' or 
            ahb_wr_burst_done      = '1' or
            nonseq_txfer_pending_i = '1' or
            burst_term_with_nonseq = '1'
           )
          ) then
          S_AHB_HREADY_OUT_i <= '0';
        elsif( timeout_detected     = '0' and 
               burst_term_with_idle = '1' ) then
          S_AHB_HREADY_OUT_i <= '1';
        elsif(reset_hready = '1' ) then
          S_AHB_HREADY_OUT_i <= busy_detected_i;
        elsif(set_hready  = '1') then
          S_AHB_HREADY_OUT_i <= '1';
        else
          S_AHB_HREADY_OUT_i <= S_AHB_HREADY_OUT_i;
        end if;
      end if;
    end if;  
  end process AHB_HREADY_REG;

--------------------------------------------------------------------------------
-- HRESP is controlled based on the ERROR detection from AXI interface.
-- In all other cases HRESP is driven as OK.
--------------------------------------------------------------------------------
  AHB_HRESP_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then 
        S_AHB_HRESP_i <= AHB_HRESP_OKAY;
      else
        if(reset_hresp_err = '1') then
          S_AHB_HRESP_i <= AHB_HRESP_OKAY;
        elsif(set_hresp_err = '1') then
          S_AHB_HRESP_i <= AHB_HRESP_ERROR;
        else
          S_AHB_HRESP_i <= S_AHB_HRESP_i;
        end if; 
      end if;
    end if;
  end process AHB_HRESP_REG;
 
--------------------------------------------------------------------------------
--S_AHB_HRDATA: Present RDATA to AHB when valid 
--------------------------------------------------------------------------------
  AHB_HRDATA_REG : process (S_AHB_HCLK ) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        S_AHB_HRDATA_i  <= (others => '0');
      else
        if(txer_rdata_to_ahb = '1') then
          S_AHB_HRDATA_i  <= M_AXI_RDATA;
        end if;
      end if;
    end if;
  end process AHB_HRDATA_REG;
 
--------------------------------------------------------------------------------
--Qualifier for pending transfer when burst terminated with 
-- NONSEQ transfer
-- set was given high priority than the reset of this signal.
-- This will ensure,NONSEQ transfer initiated after 
-- the burst is terminated with IDLE transfer.
-- For IDLE transfer,no need to rise any requests on the AXI side,giving
-- HREADY = 1 to AHB for IDLE is enough.
--------------------------------------------------------------------------------
  AHB_PENDING_NONSEQ_REG : process(S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        nonseq_txfer_pending_i <= '0';
      else
        if(burst_term_with_nonseq = '1') then
          nonseq_txfer_pending_i <= '1';
        elsif(init_pending_txfer = '1') then
          nonseq_txfer_pending_i <= '0';
        end if;
      end if;
    end if;
  end process AHB_PENDING_NONSEQ_REG;
 
--------------------------------------------------------------------------------
--Qualifier for pending transfer when burst terminated with 
-- IDLE transfer
-- Reset is given high priority. Once the IDLE is detected,any number of
-- IDLE transfers after that is not required to be monitored.
-- Reset when the AXI side current trasfer is completed with dummy transfers.
-- If a NONSEQ after the burst termination by IDLE is detected,this will be 
-- handled in the AHB_PENDING_NONSEQ_REG process 
--------------------------------------------------------------------------------
  AHB_PENDING_IDLE_REG : process(S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        idle_txfer_pending <= '0';
      else
        if(init_pending_txfer = '1') then
          idle_txfer_pending <= '0';
        elsif(burst_term_with_idle = '1') then
          idle_txfer_pending <= '1';
        end if;
      end if;
    end if;
  end process AHB_PENDING_IDLE_REG;
 
--------------------------------------------------------------------------------
--Save transfer count for burst termination transfer
-- burst_term_txer_cnt_i: Total transfer required on AXI.
-- This count is used to generate WLAST,if the burst terminated 
-- due to NONSEQ 
-- No need to reset the cnt,again update with a fresh count 
-- when another termination is detected
-- burst_term_cur_cnt_i: Current number of AHB sample received before burst
--  termination
--------------------------------------------------------------------------------
  AHB_BURST_TERM_CNT_REG : process(S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        burst_term_txer_cnt_i <= (others => '0');
        burst_term_cur_cnt_i  <= (others => '0');
      else
        if(ongoing_burst = '1' and  burst_term_i = '0' and
             (nonseq_detected_i = '1' or
              idle_detected_i   = '1')) then
          burst_term_txer_cnt_i <= valid_cnt_required_i;
          burst_term_cur_cnt_i  <= ahb_valid_cnt;
        end if;
      end if;
    end if;
  end process AHB_BURST_TERM_CNT_REG;

--------------------------------------------------------------------------------
--Save the next transfer qualifiers when the burst is terminated
-- with NONSEQ transfer
-- Only two qualifiers are required to initiated the transfer when a burst
-- is terminated by NONSEQ transfer
--------------------------------------------------------------------------------
  AHB_BURST_TERM_QUALS_REG : process(S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
         burst_term_hwrite <= '0';
         burst_term_single_incr <= '0';
      else
        if(burst_term_with_nonseq = '1') then
          burst_term_hwrite <= S_AHB_HWRITE;
          if(S_AHB_HBURST = SINGLE or 
             S_AHB_HBURST = INCR ) then
           burst_term_single_incr <= '1';
          end if;
        end if;
      end if;
    end if;
  end process AHB_BURST_TERM_QUALS_REG;

--------------------------------------------------------------------------------
--Burst termination detection logic.
-- This signal is used in the axi write channel to force
-- write strobse to '0' when the burst termination is detected.
-- During read,this burst_term is used to swallow the read data from AXI
-- by not sending these to AHB.
--------------------------------------------------------------------------------
  AHB_BURST_TERM_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        burst_term_i <= '0';
      else
        if( axi_wdata_done          = '1' or  -- WRITE
            dummy_txfer_in_progress = '1' or  -- WRITE
            last_axi_rd_sample      = '1' or  -- READ
            (init_pending_txfer      = '1' and burst_term_i = '1') -- Initiated
                                            --pending txfers if any  
          ) then 
          burst_term_i <= '0';
        elsif(ongoing_burst = '1' and (idle_detected_i = '1' or
              nonseq_detected_i = '1')) then
          burst_term_i <= '1';
        end if;
      end if;
    end if;
  end process AHB_BURST_TERM_REG;

--------------------------------------------------------------------------------
--This process detects the dummy transfer progress in AXI
-- during burst termination
--------------------------------------------------------------------------------
  AXI_DUMMY_TXFER_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        dummy_txfer_in_progress <= '0';
      else
        if(axi_wdata_done = '1' ) then
          dummy_txfer_in_progress <= burst_term_i;
        elsif(init_pending_txfer = '1') then
          dummy_txfer_in_progress <= '0';
        end if;
      end if;
    end if;
  end process AXI_DUMMY_TXFER_REG;

--------------------------------------------------------------------------------
-- Below set of process blocks for  
-- generating AW* and AR* control signals(except AWVALID and ARVALID).
-- The same flop output is used by both read and write channels.
-- The validity of signals will be based on the AWVALID or ARVALID.
--------------------------------------------------------------------------------
--  AXI_A_ID_LOCK_REG : process (S_AHB_HCLK) is
--  begin
--    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
--      if(S_AHB_HRESETN = '0') then
--        AXI_AID_i <= (others => '0');
--        AXI_ALOCK_i <= '0';
--      else
--        AXI_AID_i <= (others => '0');
--        AXI_ALOCK_i <= '0';
--      end if;
--    end if;
--  end process AXI_A_ID_LOCK_REG;

  AXI_ALEN_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        AXI_ALEN_i <= (others => '0');
      else
        if( nonseq_detected_i = '1' or 
           (seq_detected_i = '1' and ahb_hburst_incr_i = '1')) then
          case S_AHB_HBURST is
            when WRAP4|INCR4 =>
              AXI_ALEN_i(3 downto 0)   <= AXI_ARWLEN_4;
            when WRAP8|INCR8 =>
              AXI_ALEN_i(3 downto 0)   <= AXI_ARWLEN_8;
            when WRAP16|INCR16 =>
              AXI_ALEN_i(3 downto 0)   <= AXI_ARWLEN_16;
            when others =>
              AXI_ALEN_i(3 downto 0)   <= AXI_ARWLEN_1;
          end case;
        end if;
      end if;
    end if;
  end process AXI_ALEN_REG;

  AXI_ASIZE_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        AXI_ASIZE_i   <= (others => '0');
      else
        AXI_ASIZE_i   <= S_AHB_HSIZE;
      end if;
    end if;
  end process AXI_ASIZE_REG;

  AXI_ABURST_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        AXI_ABURST_i <= (others => '0');
      else
        if( nonseq_detected_i = '1' or 
           (seq_detected_i = '1' and ahb_hburst_incr_i = '1')) then
          case S_AHB_HBURST is
            when WRAP4|WRAP8|WRAP16 =>
              AXI_ABURST_i <= AXI_ARWBURST_WRAP;
            when others =>
              AXI_ABURST_i <= AXI_ARWBURST_INCR;
          end case;
        end if;
      end if;
    end if;
  end process AXI_ABURST_REG;


 GEN_1_PROT_CACHE_REG_NON_SECURE : if C_M_AXI_NON_SECURE = 1 generate

  AXI_A_PROT_CACHE_REG_NON_SECURE : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        AXI_APROT_i <= "010";
        AXI_ACACHE_i <= "0011";
      else
        if( nonseq_detected_i = '1' or 
           (seq_detected_i = '1' and ahb_hburst_incr_i = '1')) then
          AXI_APROT_i(2)  <= not S_AHB_HPROT(0);
          AXI_APROT_i(1)  <= '1';
          AXI_APROT_i(0)  <=     S_AHB_HPROT(1);
          AXI_ACACHE_i(3) <= '0';
          AXI_ACACHE_i(2) <= '0';
          AXI_ACACHE_i(1) <= S_AHB_HPROT(3);
          AXI_ACACHE_i(0) <=     S_AHB_HPROT(2);
        end if;
      end if;
    end if;
  end process AXI_A_PROT_CACHE_REG_NON_SECURE;

 end generate GEN_1_PROT_CACHE_REG_NON_SECURE;

GEN_2_PROT_CACHE_REG_NON_SECURE : if C_M_AXI_NON_SECURE = 0 generate

  AXI_A_PROT_CACHE_REG_SECURE : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        AXI_APROT_i <= "000";
        AXI_ACACHE_i <= "0011";
      else
        if( nonseq_detected_i = '1' or 
           (seq_detected_i = '1' and ahb_hburst_incr_i = '1')) then
          AXI_APROT_i(2)  <= not S_AHB_HPROT(0);
          AXI_APROT_i(1)  <= '0';
          AXI_APROT_i(0)  <=     S_AHB_HPROT(1);
          AXI_ACACHE_i(3) <= '0';
          AXI_ACACHE_i(2) <= '0';
          AXI_ACACHE_i(1) <=  S_AHB_HPROT(3);
          AXI_ACACHE_i(0) <=     S_AHB_HPROT(2);
        end if;
      end if;
    end if;
  end process AXI_A_PROT_CACHE_REG_SECURE;

 end generate GEN_2_PROT_CACHE_REG_NON_SECURE;

  AXI_AADDR_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        AXI_AADDR_i  <= (others => '0');
      else
        if( nonseq_detected_i = '1' or 
           (seq_detected_i = '1' and ahb_hburst_incr_i = '1')) then
          AXI_AADDR_i  <= S_AHB_HADDR;
        end if;
      end if;
    end if;
  end process AXI_AADDR_REG;
end architecture RTL;


-------------------------------------------------------------------------------
-- ahb_data_counter.vhd - entity/architecture pair
-------------------------------------------------------------------------------
-- ******************************************************************* 
-- ** (c) Copyright [2007] - [2011] Xilinx, Inc. All rights reserved.*
-- **                                                                *
-- ** This file contains confidential and proprietary information    *
-- ** of Xilinx, Inc. and is protected under U.S. and                *
-- ** international copyright and other intellectual property        *
-- ** laws.                                                          *
-- **                                                                *
-- ** DISCLAIMER                                                     *
-- ** This disclaimer is not a license and does not grant any        *
-- ** rights to the materials distributed herewith. Except as        *
-- ** otherwise provided in a valid license issued to you by         *
-- ** Xilinx, and to the maximum extent permitted by applicable      *
-- ** law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND        *
-- ** WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES    *
-- ** AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING      *
-- ** BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-         *
-- ** INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and       *
-- ** (2) Xilinx shall not be liable (whether in contract or tort,   *
-- ** including negligence, or under any other theory of             *
-- ** liability) for any loss or damage of any kind or nature        *
-- ** related to, arising under or in connection with these          *
-- ** materials, including for any direct, or any indirect,          *
-- ** special, incidental, or consequential loss or damage           *
-- ** (including loss of data, profits, goodwill, or any type of     *
-- ** loss or damage suffered as a result of any action brought      *
-- ** by a third party) even if such damage or loss was              *
-- ** reasonably foreseeable or Xilinx had been advised of the       *
-- ** possibility of the same.                                       *
-- **                                                                *
-- ** CRITICAL APPLICATIONS                                          *
-- ** Xilinx products are not designed or intended to be fail-       *
-- ** safe, or for use in any application requiring fail-safe        *
-- ** performance, such as life-support or safety devices or         *
-- ** systems, Class III medical devices, nuclear facilities,        *
-- ** applications related to the deployment of airbags, or any      *
-- ** other applications that could lead to death, personal          *
-- ** injury, or severe property or environmental damage             *
-- ** (individually and collectively, "Critical                      *
-- ** Applications"). Customer assumes the sole risk and             *
-- ** liability of any use of Xilinx products in Critical            *
-- ** Applications, subject only to applicable laws and              *
-- ** regulations governing limitations on product liability.        *
-- **                                                                *
-- ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS       *
-- ** PART OF THIS FILE AT ALL TIMES.                                *
-- ******************************************************************* 
--
-------------------------------------------------------------------------------
-- Filename:        ahb_data_counter.vhd
-- Version:         v1.00a
-- Description:     This file contains the support logic required
--                   for the state machine.These include
--                  a.AHB valid inputs sample counter
--                    This will count the number of valid data inputs
--                    received till now. This helps in controlling the
--                    HREADY signal which decides the either to allow for
--                    another data to be placed on the bus or not by the 
--                    AHB master.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- ahblite_axi_bridge.vhd
--              -- ahblite_axi_bridge_pkg.vhd
--              -- ahblite_axi_control.vhd
--              -- ahb_if.vhd
--              -- ahb_data_counter.vhd
--              -- axi_wchannel.vhd
--              -- axi_rchannel.vhd
--              -- time_out.vhd
--
-------------------------------------------------------------------------------
-- Author:      Kondalarao P( kpolise@xilinx.com ) 
-- History:
-- Kondalarao P          11/24/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------

-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "reset", "resetn"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


library ahblite_axi_bridge_v3_0_15;
use ahblite_axi_bridge_v3_0_15.ahblite_axi_bridge_pkg.all;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-- Definition of Ports
--
-- System signals
--                              Information
-- AHB signals
--  S_AHB_HCLK               -- AHB Clock
--  S_AHB_HRESETN            -- AHB Reset Signal - active low
--  ahb_valid_cnt            -- Gives the number of valid data sampled
--                              on the AHB interface after the transfer
--                              is initiated.
--  ahb_hburst_incr          -- Indicates INCR transfer on AHB side.
--  nonseq_detected          -- Valid NONSEQ transaction detected
--  seq_detected             -- Valid SEQ transaction detected
-------------------------------------------------------------------------------
-- Generics & Signals Description
-------------------------------------------------------------------------------

entity ahb_data_counter is
  generic (
   C_FAMILY                 : string    := "virtex7" 
   );
  port (
  -- AHB Signals
     S_AHB_HCLK        : in  std_logic;                           
     S_AHB_HRESETN     : in  std_logic;                           

  -- ahb_if module
     ahb_hwrite        : in  std_logic;
     ahb_hburst_incr   : in  std_logic;
     ahb_valid_cnt     : out std_logic_vector(4 downto 0);
     nonseq_detected   : in  std_logic;
     seq_detected      : in  std_logic
    );

end entity ahb_data_counter;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture RTL of ahb_data_counter is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
 -- Signal declarations(Description of each signal is given in their 
 --    implementation block
-------------------------------------------------------------------------------
signal ahb_valid_cnt_i        : std_logic_vector( 4 downto 0);
signal cntr_rst               : std_logic;
signal cntr_load              : std_logic;
signal cntr_load_in           : std_logic_vector(4 downto 0);
signal cntr_enable            : std_logic;
begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- I/O signal assignements
--------------------------------------------------------------------------------
-- Tracks the number of valid samples received for the current transfer
-- on the AHB side.
ahb_valid_cnt        <= ahb_valid_cnt_i; 
--------------------------------------------------------------------------------
--Internal signal assignments
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Reeset condition for counter
-- Counter is active high reset, Invert the IP reset.
--------------------------------------------------------------------------------
cntr_rst       <= not S_AHB_HRESETN;

--------------------------------------------------------------------------------
-- Load the counter when a NONSEQ is detected,as this is start of NEW
-- transfer
--------------------------------------------------------------------------------
cntr_load      <= nonseq_detected ;

--------------------------------------------------------------------------------
--Load an initial value of 1 as nonseq is detected.(1st sample
--  on the AHB is received.
--------------------------------------------------------------------------------
cntr_load_in   <= "00001" ;

--------------------------------------------------------------------------------
-- Enable condition for counter
-- Increment the counter whenever a valid sample on AHB is received.
--  Do NOT count for indefinite length INCR transfer.These are converted
--  to SINGLE transfers on AXI
--------------------------------------------------------------------------------
cntr_enable    <= ahb_hwrite   and 
                  seq_detected and (not ahb_hburst_incr);

--------------------------------------------------------------------------------
--AHB valid inputs sample counter
-- Set the counter to 1 when NONSEQ is detected.
-- Increment for every sequential transfer there after,except
-- for the indefinite length increment transfer.
--------------------------------------------------------------------------------
  AHB_SAMPLE_CNT_MODULE : entity ahblite_axi_bridge_v3_0_15.counter_f
     generic map(
       C_NUM_BITS    =>  AHB_SAMPLE_CNT_WIDTH,
       C_FAMILY      =>  C_FAMILY
         )
     port map(
       Clk           =>  S_AHB_HCLK     ,
       Rst           =>  cntr_rst       ,
       Load_In       =>  cntr_load_in   ,
       Count_Enable  =>  cntr_enable    ,
       Count_Load    =>  cntr_load      ,
       Count_Down    =>  '0'            ,
       Count_Out     =>  ahb_valid_cnt_i,
       Carry_Out     =>  open
       );
end architecture RTL;


-------------------------------------------------------------------------------
-- ahblite_axi_control.vhd - entity/architecture pair
-------------------------------------------------------------------------------
-- ******************************************************************* 
-- ** (c) Copyright [2007] - [2011] Xilinx, Inc. All rights reserved.*
-- **                                                                *
-- ** This file contains confidential and proprietary information    *
-- ** of Xilinx, Inc. and is protected under U.S. and                *
-- ** international copyright and other intellectual property        *
-- ** laws.                                                          *
-- **                                                                *
-- ** DISCLAIMER                                                     *
-- ** This disclaimer is not a license and does not grant any        *
-- ** rights to the materials distributed herewith. Except as        *
-- ** otherwise provided in a valid license issued to you by         *
-- ** Xilinx, and to the maximum extent permitted by applicable      *
-- ** law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND        *
-- ** WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES    *
-- ** AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING      *
-- ** BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-         *
-- ** INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and       *
-- ** (2) Xilinx shall not be liable (whether in contract or tort,   *
-- ** including negligence, or under any other theory of             *
-- ** liability) for any loss or damage of any kind or nature        *
-- ** related to, arising under or in connection with these          *
-- ** materials, including for any direct, or any indirect,          *
-- ** special, incidental, or consequential loss or damage           *
-- ** (including loss of data, profits, goodwill, or any type of     *
-- ** loss or damage suffered as a result of any action brought      *
-- ** by a third party) even if such damage or loss was              *
-- ** reasonably foreseeable or Xilinx had been advised of the       *
-- ** possibility of the same.                                       *
-- **                                                                *
-- ** CRITICAL APPLICATIONS                                          *
-- ** Xilinx products are not designed or intended to be fail-       *
-- ** safe, or for use in any application requiring fail-safe        *
-- ** performance, such as life-support or safety devices or         *
-- ** systems, Class III medical devices, nuclear facilities,        *
-- ** applications related to the deployment of airbags, or any      *
-- ** other applications that could lead to death, personal          *
-- ** injury, or severe property or environmental damage             *
-- ** (individually and collectively, "Critical                      *
-- ** Applications"). Customer assumes the sole risk and             *
-- ** liability of any use of Xilinx products in Critical            *
-- ** Applications, subject only to applicable laws and              *
-- ** regulations governing limitations on product liability.        *
-- **                                                                *
-- ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS       *
-- ** PART OF THIS FILE AT ALL TIMES.                                *
-- ******************************************************************* 
--
-------------------------------------------------------------------------------
-- Filename:        ahblite_axi_control.vhd
-- Version:         v1.00a
-- Description:     This file contains the fsm which tracks, controls
--                   the transfer flow from ahblite interface to axi 
--                   interface.Considers burst termination,
--                   timeout condition for axi slave not responding.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- ahblite_axi_bridge.vhd
--              -- ahblite_axi_bridge_pkg.vhd
--              -- ahblite_axi_control.vhd
--              -- ahb_if.vhd
--              -- ahb_data_counter.vhd
--              -- axi_wchannel.vhd
--              -- axi_rchannel.vhd
--              -- time_out.vhd
--
-------------------------------------------------------------------------------
-- Author:      Kondalarao P( kpolise@xilinx.com ) 
-- History:
-- Kondalarao P          11/24/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------

-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "reset", "resetn"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library ahblite_axi_bridge_v3_0_15;
use ahblite_axi_bridge_v3_0_15.ahblite_axi_bridge_pkg.all;
-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------

--
-- Definition of Generics
--
-- System Parameters
-- C_FAMILY                   -- FPGA Family for which the ahblite_axi_control
--                                is targetted
-- Definition of Ports
--
-- AHB signals
--  S_AHB_HCLK               -- AHB Clock
--  S_AHB_HRESETN            -- AHB Reset Signal - active low
--  S_AHB_HWRITE             -- Direction indicates an AHB write access when
--                              high and an AHB read access when low
--  axi_wr_channel_ready     -- Write channel ready to accept data from AHB
--  axi_wdata_done           -- Asserted when  WVALID = 1 and  WREADY = 1 
--  rvalid_rready            -- RDATA valid
--  last_axi_rd_sample       -- Last read data
--  axi_rresp_err            -- Read response
--  axi_bresp_ok             -- Asserted when  BVALID = 1
--  axi_bresp_err            -- Asserted when  BVALID = 1 and ERROR = 1
--  set_axi_raddr            -- To set read addr on AXI interface
--  set_axi_waddr            -- To set write addr on AXI interface 
--  ahb_wnr                  -- To set first burst write data data on AXI
--                               interface
--  set_axi_wdata_burst      -- To set next burst write data data on AXI
--                               interface
--  set_axi_rdata            -- To set read data on AXI interface
--  timeout_i                -- Timeout signal from the timeout module
--  enable_timeout_cnt       -- To start timer count
--  core_is_idle             -- Core is in IDLE state
--  set_hready               -- Assert S_AHB_HREADY_OUT on AHB interface
--  reset_hready             -- De-assert S_AHB_HREADY_OUT on AHB interface
--  set_hresp_err            -- Assert HRESP as ERROR
--  reset_hresp_err          -- De-assert HRESP as ERROR 
--  axi_bresp_ready          -- Response received from AXI for the current
--                              transfer
--  nonseq_detected          -- Valid NONSEQ transaction detected
--  seq_detected             -- Valid SEQ transaction detected
--  ahb_hburst_single        -- Transfer on AHB is SINGLE
--  ahb_hburst_incr          -- Transfer on AHB is INCR
-------------------------------------------------------------------------------
-- Generics & Signals Description
-------------------------------------------------------------------------------

entity ahblite_axi_control is
  port (
  -- AHB Signals
     S_AHB_HCLK            : in  std_logic;                           
     S_AHB_HRESETN         : in  std_logic;                           
     S_AHB_HWRITE          : in  std_logic;
     S_AHB_HBURST          : in  std_logic_vector(2 downto 0 );
  -- AXI Write/Read channels
     axi_wr_channel_ready  : in  std_logic;
     axi_wr_channel_busy   : in  std_logic;
     axi_wdata_done        : in  std_logic;
     rvalid_rready         : in  std_logic;
     last_axi_rd_sample    : in  std_logic;
     axi_rresp_err         : in  std_logic_vector(1 downto 0);
     axi_bresp_ok          : in  std_logic;
     axi_bresp_err         : in  std_logic;
     set_axi_raddr         : out std_logic;
     set_axi_waddr         : out std_logic; 
     ahb_wnr               : out std_logic;
     set_axi_wdata_burst   : out std_logic;
     set_axi_rdata         : out std_logic;
  -- timout module
     timeout_i             : in  std_logic;
     enable_timeout_cnt    : out std_logic;
  -- AHB interface  module 
     core_is_idle          : out std_logic;
     set_hready            : out std_logic;
     reset_hready          : out std_logic;
     set_hresp_err         : out std_logic;
     reset_hresp_err       : out std_logic;
     nonseq_txfer_pending  : in  std_logic;
     idle_txfer_pending    : in  std_logic;
     burst_term_hwrite     : in  std_logic;
     burst_term_single_incr: in  std_logic;
     init_pending_txfer    : out std_logic;
     axi_bresp_ready       : out std_logic;
     nonseq_detected       : in  std_logic;
     seq_detected          : in  std_logic;
     ahb_hburst_single     : in  std_logic;
     ahb_hburst_incr       : in  std_logic 
    );
end entity ahblite_axi_control;
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of ahblite_axi_control is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

--------------------------------------------------------------------------------
-- State Machine Type Decleration
--------------------------------------------------------------------------------
  type CTL_SM_TYPE is ( 
                      CTL_IDLE     ,
                      CTL_ADDR     ,
                      CTL_WRITE    ,
                      CTL_READ     ,
                      CTL_READ_ERR ,
                      CTL_BRESP    ,
                      CTL_BRESP_ERR                  
                      );

-------------------------------------------------------------------------------
 -- Signal declarations(Description of each signal is given in their 
 --    implementation block
-------------------------------------------------------------------------------
  signal ctl_sm_ns            : CTL_SM_TYPE;
  signal ctl_sm_cs            : CTL_SM_TYPE;
  signal ahb_wnr_i            : std_logic;
  signal M_AXI_RLAST_reg      : std_logic;
  signal enable_timeout_cnt_i : std_logic;
  signal set_axi_waddr_i      : std_logic;
  signal hburst_single_incr   : std_logic;

begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Sample WRITE/READ request.Used to assert first data beat during WRITE 
-- transfers.
--------------------------------------------------------------------------------
  ahb_wnr       <= ahb_wnr_i;

--------------------------------------------------------------------------------
--To assert AWVALID for WRITE transfer.
--------------------------------------------------------------------------------
  set_axi_waddr <= set_axi_waddr_i;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--To limit hready for SINGLE and INCR transfers in the address phase.
-- The registerd signals ahb_hburst_incr and ahb_hburst_single will not be
-- available while placing the address on AXI.So use the HBURST signal from
-- the AHB interface is used during address phases,other phases use the
-- registered version of the signal.
--------------------------------------------------------------------------------
  hburst_single_incr <= '1' when (S_AHB_HBURST = SINGLE or 
                                  S_AHB_HBURST = INCR ) else
                        '0';
 
--------------------------------------------------------------------------------
-- Control state machine:
-- This state machine generates the control signals to transfer
--   the read/writes from AHB to AXI interface.
-- Generates control signals to assert/deassert control
--   signals on AHB and AXI side interfaces.
-- Generates control signals to sample/provide data.
-- Considers the time out of AXI side slave not responding to the 
--   request, ensures clean termination of the request on AHB side.
--------------------------------------------------------------------------------
 
  CTL_SM : process (
                   ctl_sm_cs             ,
                   nonseq_detected       ,
                   seq_detected          ,
                   S_AHB_HWRITE          ,
                   hburst_single_incr    ,
                   nonseq_txfer_pending  , 
                   idle_txfer_pending    ,
                   burst_term_hwrite     ,
                   burst_term_single_incr, 
                   ahb_hburst_incr       ,
                   ahb_hburst_single     ,
                   ahb_wnr_i             ,
                   axi_wr_channel_ready  ,
                   axi_wr_channel_busy   ,
                   axi_wdata_done        ,
                   timeout_i             ,
                   rvalid_rready         ,
                   last_axi_rd_sample    ,
                   M_AXI_RLAST_reg       ,
                   axi_rresp_err         ,
                   axi_bresp_ok          ,     
                   axi_bresp_err           
                   ) is
  begin
    ctl_sm_ns              <= ctl_sm_cs;
    core_is_idle           <= '0';
    set_hready             <= '0';
    reset_hready           <= '0';
    set_hresp_err          <= '0';
    reset_hresp_err        <= '0';
    
    set_axi_waddr_i        <= '0';
    set_axi_wdata_burst    <= '0';
    axi_bresp_ready        <= '0';
    init_pending_txfer     <= '0';
    set_axi_raddr          <= '0';
    set_axi_rdata          <= '0';

    enable_timeout_cnt_i   <= '0';
    case ctl_sm_cs is
    --------------------------------------------------------------------------
    --IDLE: Hunt for fresh transaction. 
    -- Flush all the previous transaction responses
    -- Start counting number of clocks the new transaction is taking to 
    -- timeout if the timeout module is activated.
    --------------------------------------------------------------------------
      when CTL_IDLE =>
        core_is_idle    <= '1';
        reset_hresp_err <= '1'; --Reset HRESP ERR if aleady set because of 
                                -- previous transfer.
        if( nonseq_detected = '1' or 
           (seq_detected = '1' and ahb_hburst_incr = '1')) then
          ctl_sm_ns <= CTL_ADDR; 
          set_axi_raddr   <= not S_AHB_HWRITE;
          set_axi_waddr_i <=     S_AHB_HWRITE;
          reset_hready  <= (not S_AHB_HWRITE ) or
                           (S_AHB_HWRITE and 
                            (hburst_single_incr));
          enable_timeout_cnt_i <= '1';
        end if; 
      
    --------------------------------------------------------------------------
    --Qualify the current transaction(WRITE/READ)
    -- If there is pending transfer which caused due to burst termination,
    -- service such transactions,convey that the pending transaction is being
    -- processed(init_pending_txfer).
    --  There is no check performed to set init_pending_txfer as resetting
    -- the pending transfer qualifiers even if no pending transfers,will not
    -- effect the core operation. This reduces some logic.   
    --------------------------------------------------------------------------
      when CTL_ADDR => 
        init_pending_txfer <= '1'; -- Process pending txfers
                                   -- if any
        if (ahb_wnr_i = '1') then
          ctl_sm_ns     <= CTL_WRITE;
          set_hready    <= '1';
          reset_hready  <= (not S_AHB_HWRITE ) or
                           (S_AHB_HWRITE and 
                            (ahb_hburst_single or 
                            ahb_hburst_incr));
        else 
          ctl_sm_ns <= CTL_READ;
          set_axi_rdata <= '1';
        end if;

    --------------------------------------------------------------------------
    -- Qualify if this is a burst transfer or a signle transfer
    -- set/reset hready based considering back pressure from 
    --  AHB by giving BUSY cycles during the transfer
    --  AXI by keeping WREADY low.
    -- Transition to BRESP when all the AHB samples are successfully placed
    -- and sampled by AXI.
    --------------------------------------------------------------------------
      when CTL_WRITE => 
        set_axi_wdata_burst <= (not ahb_hburst_single) and
                               (not ahb_hburst_incr);
        reset_hready        <= ahb_hburst_single  or 
                               ahb_hburst_incr    or
                               axi_wr_channel_busy   ;
        set_hready          <= axi_wr_channel_ready and (not ahb_hburst_single);
        if (axi_wdata_done = '1') then
          ctl_sm_ns <= CTL_BRESP;
        end if;  

    --------------------------------------------------------------------------
    -- Check if there pending transfers need to be address,which can occur
    --  burst termination.
    -- For normal transfers,pass read data and corresponding response for
    -- each data beat respecting the protocol requirement to have 2 clock
    --  cycle error response on AHB interface.
    -- Limit accepting read data from AXI by keeping RREADY low when
    -- AHB is not able to sample the current read data.
    --------------------------------------------------------------------------
      when CTL_READ => 
        if(nonseq_txfer_pending = '1' or
           nonseq_detected      = '1') then
          if(rvalid_rready = '1' and last_axi_rd_sample = '1') then
            ctl_sm_ns <= CTL_ADDR;
            -- For nonseq_txfer_pending case use burst_term*
            -- For nonseq_detected      case use S_AHB_* signals
            -- No need to explicitly check nonseq is the pending or
            -- the current,as both cases lead to CTL_ADDR
            -- burst_term* signals are 1 clock delayed versions of the S_AHB*
            set_axi_raddr   <= not ( burst_term_hwrite or
                                     S_AHB_HWRITE);
            set_axi_waddr_i <=     burst_term_hwrite or
                                   S_AHB_HWRITE;
            reset_hready  <= (not burst_term_hwrite or
                              not S_AHB_HWRITE)     or
                             ((burst_term_hwrite    or
                               S_AHB_HWRITE)          and 
                              (burst_term_single_incr or
                               hburst_single_incr));
            enable_timeout_cnt_i <= '1';
            init_pending_txfer   <= '1';
          end if;
        elsif(idle_txfer_pending = '1') then
          if(rvalid_rready = '1' and last_axi_rd_sample = '1') then
            ctl_sm_ns         <= CTL_IDLE;
            set_hready        <= '1';
            reset_hresp_err   <= '1';
            init_pending_txfer<= '1';
          end if;
        elsif(((rvalid_rready = '1' ) and
            (axi_rresp_err = AXI_RESP_SLVERR or
              axi_rresp_err = AXI_RESP_DECERR)) or timeout_i = '1') then
            reset_hready <= '1';
            set_hresp_err <= '1';
            ctl_sm_ns       <= CTL_READ_ERR;
        elsif(rvalid_rready = '1') then
            if(last_axi_rd_sample = '1') then
             ctl_sm_ns <= CTL_IDLE;
            end if;
           set_hready <= '1';
           reset_hresp_err <= '1';
        else
           reset_hready <= '1';
           reset_hresp_err <= '1'; --Reset HRESP ERR if aleady set because of 
                                   -- previous transfer.
        end if;


    --------------------------------------------------------------------------
    -- Respect the protocol requirement to have 2 cycle error response on AHB
    -- while presenting a error response.
    -- Move to IDLE if the current error reponse is for last transfer
    -- of the read burst.
    -- Move to READ to accept furnther data after processing the current
    -- data with error response
    --------------------------------------------------------------------------
      when CTL_READ_ERR => 
        set_hready <= '1';
        set_hresp_err <= '1';
        if (M_AXI_RLAST_reg = '1') then
          ctl_sm_ns <= CTL_IDLE;
        else
          ctl_sm_ns <= CTL_READ;
        end if; 

    --------------------------------------------------------------------------
    -- Check if there pending transfers need to be address,which can occur
    --  burst termination.
    -- Respect the protocol requirement to have 2 cycle error response on AHB
    -- while presenting a error response.
    -- Move to IDLE if no pending transfers and hunt for a fresh transfer.
    --------------------------------------------------------------------------
      when CTL_BRESP => 
        if(axi_bresp_ok = '1' and
           (nonseq_txfer_pending = '1' or
            nonseq_detected      = '1')) then
          ctl_sm_ns <= CTL_ADDR;
          -- For nonseq_txfer_pending case use burst_term*
          -- For nonseq_detected      case use S_AHB_* signals
          -- No need to explicitly check nonseq is the pending or
          -- the current,as both cases lead to CTL_ADDR
          -- burst_term* signals are 1 clock delayed versions of the S_AHB*
          set_axi_raddr   <= not burst_term_hwrite or
                             not S_AHB_HWRITE;
          set_axi_waddr_i <=     burst_term_hwrite or
                                 S_AHB_HWRITE;
          reset_hready  <= (not burst_term_hwrite or
                            not S_AHB_HWRITE)     or
                           ((burst_term_hwrite    or
                             S_AHB_HWRITE)          and 
                            (burst_term_single_incr or
                             hburst_single_incr));
          enable_timeout_cnt_i <= '1';
          init_pending_txfer   <= '1';
        elsif(axi_bresp_ok = '1' and
           idle_txfer_pending = '1') then
           ctl_sm_ns         <= CTL_IDLE;
           set_hready        <= '1';
           reset_hresp_err   <= '1';
           init_pending_txfer<= '1';
        elsif (axi_bresp_err = '1') then
          ctl_sm_ns <= CTL_BRESP_ERR;
          axi_bresp_ready   <= '1';
          reset_hready      <= '1';
          set_hresp_err     <= '1';
        elsif(axi_bresp_ok = '1') then
          ctl_sm_ns         <= CTL_IDLE;
          set_hready        <= '1';
          reset_hresp_err   <= '1';
        end if; 

    --------------------------------------------------------------------------
    -- Respect the protocol requirement to have 2 cycle error response on AHB
    -- while presenting a error response.
    --------------------------------------------------------------------------
      when CTL_BRESP_ERR => 
        ctl_sm_ns         <= CTL_IDLE;
        axi_bresp_ready   <= '1';
        set_hready        <= '1';
        set_hresp_err     <= '1';

    --------------------------------------------------------------------------
    -- State machine will not reach others as all the possible combinations
    -- are explicitly mapped . State machines either retains in the current
    -- state or move to any valid state if a specified condition is met.
    --------------------------------------------------------------------------
      -- coverage off
      when others =>
        ctl_sm_ns <= CTL_IDLE; 
      -- coverate on 
    end case;
  end process CTL_SM;

--------------------------------------------------------------------------------
--Register the signals required,along with the current state
-- M_AXI_RLAST_reg used during ERROR response for last read transfer.
-- enable_timeout_cnt: To enable the timeout counter after the trasfer is
-- initiated on AXI.
--------------------------------------------------------------------------------
  CTL_SM_REG : process (S_AHB_HCLK) is
  begin
    if (S_AHB_HCLK'event and S_AHB_HCLK = '1') then
      if(S_AHB_HRESETN = '0') then
        ctl_sm_cs          <= CTL_IDLE;
        ahb_wnr_i          <= '0';
        M_AXI_RLAST_reg    <= '0';
        enable_timeout_cnt <= '0';
      else
        ctl_sm_cs          <= ctl_sm_ns;
        ahb_wnr_i          <= set_axi_waddr_i;
        M_AXI_RLAST_reg    <= last_axi_rd_sample;
        enable_timeout_cnt <= enable_timeout_cnt_i;
      end if;
    end if;
  end process CTL_SM_REG;
end architecture RTL;


-------------------------------------------------------------------------------
-- ahblite_axi_bridge.vhd - entity/architecture pair
-------------------------------------------------------------------------------
-- ******************************************************************* 
-- ** (c) Copyright [2007] - [2011] Xilinx, Inc. All rights reserved.*
-- **                                                                *
-- ** This file contains confidential and proprietary information    *
-- ** of Xilinx, Inc. and is protected under U.S. and                *
-- ** international copyright and other intellectual property        *
-- ** laws.                                                          *
-- **                                                                *
-- ** DISCLAIMER                                                     *
-- ** This disclaimer is not a license and does not grant any        *
-- ** rights to the materials distributed herewith. Except as        *
-- ** otherwise provided in a valid license issued to you by         *
-- ** Xilinx, and to the maximum extent permitted by applicable      *
-- ** law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND        *
-- ** WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES    *
-- ** AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING      *
-- ** BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-         *
-- ** INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and       *
-- ** (2) Xilinx shall not be liable (whether in contract or tort,   *
-- ** including negligence, or under any other theory of             *
-- ** liability) for any loss or damage of any kind or nature        *
-- ** related to, arising under or in connection with these          *
-- ** materials, including for any direct, or any indirect,          *
-- ** special, incidental, or consequential loss or damage           *
-- ** (including loss of data, profits, goodwill, or any type of     *
-- ** loss or damage suffered as a result of any action brought      *
-- ** by a third party) even if such damage or loss was              *
-- ** reasonably foreseeable or Xilinx had been advised of the       *
-- ** possibility of the same.                                       *
-- **                                                                *
-- ** CRITICAL APPLICATIONS                                          *
-- ** Xilinx products are not designed or intended to be fail-       *
-- ** safe, or for use in any application requiring fail-safe        *
-- ** performance, such as life-support or safety devices or         *
-- ** systems, Class III medical devices, nuclear facilities,        *
-- ** applications related to the deployment of airbags, or any      *
-- ** other applications that could lead to death, personal          *
-- ** injury, or severe property or environmental damage             *
-- ** (individually and collectively, "Critical                      *
-- ** Applications"). Customer assumes the sole risk and             *
-- ** liability of any use of Xilinx products in Critical            *
-- ** Applications, subject only to applicable laws and              *
-- ** regulations governing limitations on product liability.        *
-- **                                                                *
-- ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS       *
-- ** PART OF THIS FILE AT ALL TIMES.                                *
-- ******************************************************************* 
--
-------------------------------------------------------------------------------
-- Filename:        ahblite_axi_bridge.vhd
-- Version:         v1.00a
-- Description:     The AHB lite to AXI bridge translates AHB lite
--                  transactions into AXI  transactions. It functions as a
--                  AHB lite slave on the AHB port and an AXI master on
--                  the AXI interface.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- ahblite_axi_bridge.vhd
--              -- ahblite_axi_bridge_pkg.vhd
--              -- ahblite_axi_control.vhd
--              -- ahb_if.vhd
--              -- ahb_data_counter.vhd
--              -- axi_wchannel.vhd
--              -- axi_rchannel.vhd
--              -- time_out.vhd
--
-------------------------------------------------------------------------------
-- Author:  Kondalarao P( kpolise@xilinx.com )      
-- History:
-- Kondalarao P          11/24/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------

-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "reset", "resetn"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library ahblite_axi_bridge_v3_0_15;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------

--
-- Definition of Generics
--
-- System Parameters
-- C_FAMILY                   -- FPGA Family for which the ahblite_axi_bridge is
--                            -- targetted
-- C_INSTANCE                 -- Instance name in the system.
-- C_S_AHB_ADDR_WIDTH         -- Width of AHBLite address bus
-- C_M_AXI_ADDR_WIDTH         -- Width of AXI address bus
-- C_S_AHB_DATA_WIDTH         -- Width of AHBLite data buse
-- C_M_AXI_DATA_WIDTH         -- Width of AXI data buse
-- C_M_AXI_SUPPORTS_NARROW_BURST  -- Generic to select narrow transfer support.
--                                0 - No Narrow transfer support.
--                                1 - Narrow transfer supported.
-- C_M_AXI_NON_SECURE         -- make the ARCACHE/AWCACHE(1) = '1' else '0'
-- AXI Parameters
--
-- C_M_AXI_PROTOCOL           -- axi4lite protocol
-- C_M_AXI_THREAD_ID_WIDTH           -- ID width of read and write channels 
--
-- AHBLite Parameters
--
-- C_AHB_AXI_TIMEOUT          -- Timeout value to count for AXI slave not
--                            -- responding with BVALID during write response
--                            -- or RVALID during read data phases.
--
-- Definition of Ports
--
-- AHB signals
--  s_ahb_hclk               -- AHB Clock
--  s_ahb_hresetn            -- AHB Reset Signal - active low
--  s_ahb_hsel               -- Slave select signal for AHB interface
--  s_ahb_haddr              -- AHB address bus
--  s_ahb_hprot              -- This signal indicates the normal,
--                              privileged, or secure protection level of the
--                              transaction and whether the transaction is a
--                              data access or an instruction access.
--  s_ahb_htrans             -- Indicates the type of the current transfer
--  s_ahb_hsize              -- Indicates the size of the transfer 
--  s_ahb_hwrite             -- Direction indicates an AHB write access when
--                              high and an AHB read access when low
--  s_ahb_hburst             -- Indicates if the transfer forms part of a burst
--  s_ahb_hwdata             -- AHB write data
--  s_ahb_hready_out         -- Ready, the AHB slave uses this signal to
--                              extend an AHB transfer
--  s_ahb_hready_in          -- Ready signal from the system 
--  s_ahb_hrdata             -- AHB read data driven by slave  
--  s_ahb_hresp              -- This signal indicates transfer response.

-- AXI Signals
--
--  m_axi_aclk               -- AXI Clock
--  m_axi_aresetn            -- AXI Reset Signal - active low
--
-- Axi write address channel signals
--  m_axi_awid               -- Write address ID. This signal is the
--                           -- identification tag for the write address 
--                           -- group of signals
--  m_axi_awlen              -- Burst length. The burst length gives the 
--                           -- exact number of transfers in a burst
--  m_axi_awsize             -- Burst size. This signal indicates the size 
--                           -- of each transfer in the burst
--  m_axi_awburst            -- Burst type. The burst type, coupled with
--                           -- the size information, details how the address 
--                           -- for each transfer within the burst is calculated
--  m_axi_awaddr             -- Write address bus - The write address bus gives
--                              the address of the first transfer in a write
--                              burst transaction - fixed to 32
--  m_axi_awcache            -- Cache type. This signal indicates 
--                           -- the bufferable,cacheable, write-through, 
--                           -- write-back,and allocate attributes of the
--                           -- transaction 
--  m_axi_awprot             -- Protection type - This signal indicates the
--                              normal, privileged, or secure protection level
--                              of the transaction and whether the transaction
--                              is a data access or an instruction access
--  m_axi_awvalid            -- Write address valid - This signal indicates
--                              that valid write address & control information
--                              are available
--  m_axi_awready            -- Write address ready - This signal indicates
--                              that the slave is ready to accept an address
--                              and associated control signals
--  m_axi_awlock             -- Lock type. This signal provides additional 
                             -- information about the atomic characteristics
                             -- of the transfer
--
-- Axi write data channel signals
--
--  m_axi_wdata              -- Write data bus  
--  m_axi_wstrb              -- Write strobes - These signals indicates which
--                              byte lanes to update in memory
--  m_axi_wlast              -- Write last. This signal indicates the last 
--                           -- transfer in a write burst
--  m_axi_wvalid             -- Write valid - This signal indicates that valid
--                              write data and strobes are available
--  m_axi_wready             -- Write ready - This signal indicates that the
--                              slave can accept the write data
-- Axi write response channel signals
--
--  m_axi_bid                -- Response ID. The identification tag of the 
--                           -- write response
--  m_axi_bresp              -- Write response - This signal indicates the
--                              status of the write transaction
--  m_axi_bvalid             -- Write response valid - This signal indicates
--                              that a valid write response is available
--  m_axi_bready             -- Response ready - This signal indicates that
--                              the master can accept the response information
--
-- Axi read address channel signals
--
--  m_axi_arid               -- Read address ID. This signal is the 
--                           -- identification tag for the read address group 
--                           -- of signals
--  m_axi_araddr             -- Read address - The read address bus gives the
--                              initial address of a read burst transaction
--  m_axi_arprot             -- Protection type - This signal provides
--                              protection unit information for the transaction
--  m_axi_arcache            -- Cache type. This signal provides additional 
--                              information about the cacheable 
--                           -- characteristics of the transfer
--  m_axi_arvalid            -- Read address valid - This signal indicates,
--                              when HIGH, that the read address and control
--                              information is valid and will remain stable
--                              until the address acknowledge signal,ARREADY,
--                              is high.
--  m_axi_arlen              -- Burst length. The burst length gives the 
--                           -- exact number of transfers in a burst
--  m_axi_arsize             -- Burst size. This signal indicates the size of i
                             -- each transfer in the burst
--  m_axi_arburst            -- Burst type. The burst type, coupled with the 
--                           -- size information, details how the address for
                             -- each transfer within the burst is calculated
--  m_axi_arlock             -- Lock type. This signal provides additional 
                             -- information about the atomic characteristics
                             -- of the transfer
--  m_axi_arready            -- Read address ready - This signal indicates
--                              that the slave is ready to accept an address
--                              and associated control signals:
--
-- Axi read data channel signals
--
--  m_axi_rid                -- Read ID tag. This signal is the ID tag of 
                             -- the read data group of signals
--  m_axi_rdata              -- Read data bus - fixed to 32
--  m_axi_rresp              -- Read response - This signal indicates the
--                              status of the read transfer
--  m_axi_rvalid             -- Read valid - This signal indicates that the
--                              required read data is available and the read
--                              transfer can complete
--  m_axi_rlast              -- Read last. This signal indicates the 
--                           -- last transfer in a read burst
--  m_axi_rready             -- Read ready - This signal indicates that the
--                              master can accept the read data and response
--                              information
-------------------------------------------------------------------------------
-- Generics & Signals Description
-------------------------------------------------------------------------------

entity ahblite_axi_bridge is
  generic (
    C_FAMILY                      : string                    := "virtex7";
    C_INSTANCE                    : string                    := "ahblite_axi_bridge_inst";
    C_M_AXI_SUPPORTS_NARROW_BURST : integer range 0 to 1      := 0;
    C_S_AHB_ADDR_WIDTH            : integer range 32 to 64    := 32;
    C_M_AXI_ADDR_WIDTH            : integer range 32 to 64    := 32;
    C_S_AHB_DATA_WIDTH            : integer range 32 to 64    := 32;
    C_M_AXI_DATA_WIDTH            : integer range 32 to 64    := 32;
    C_M_AXI_PROTOCOL              : string                    := "AXI4";
    C_M_AXI_THREAD_ID_WIDTH       : integer                   := 4;
    C_AHB_AXI_TIMEOUT             : integer                   := 0; 
    C_M_AXI_NON_SECURE             : integer                   := 1 
    );
  port (
  -- AHB Signals
     s_ahb_hclk        : in  std_logic;                           
     s_ahb_hresetn     : in  std_logic;                           
     s_ahb_hsel        : in  std_logic;
       
     --S_AHB_HADDR       : in  std_logic_vector(C_S_AHB_ADDR_WIDTH-1 downto 0); 
     s_ahb_haddr       : in  std_logic_vector(C_S_AHB_ADDR_WIDTH-1 downto 0); 
     s_ahb_hprot       : in  std_logic_vector(3 downto 0); 
     s_ahb_htrans      : in  std_logic_vector(1 downto 0); 
     s_ahb_hsize       : in  std_logic_vector(2 downto 0); 
     s_ahb_hwrite      : in  std_logic; 
     s_ahb_hburst      : in  std_logic_vector(2 downto 0 );
     s_ahb_hwdata      : in  std_logic_vector(C_S_AHB_DATA_WIDTH-1 downto 0 );

     s_ahb_hready_out  : out std_logic; 
     s_ahb_hready_in   : in  std_logic; 
                      
     s_ahb_hrdata      : out std_logic_vector(C_S_AHB_DATA_WIDTH-1 downto 0 );
     s_ahb_hresp       : out std_logic;

  -- AXI signals
--    m_axi_aclk         : out std_logic;
--    m_axi_aresetn      : out std_logic;

  -- AXI Write Address Channel Signals
    m_axi_awid         : out std_logic_vector 
                             (C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
    m_axi_awlen        : out std_logic_vector (7 downto 0);
    m_axi_awsize       : out std_logic_vector (2 downto 0);
    m_axi_awburst      : out std_logic_vector (1 downto 0);
    m_axi_awcache      : out std_logic_vector (3 downto 0);
    --M_AXI_AWADDR       : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    m_axi_awaddr       : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    m_axi_awprot       : out std_logic_vector(2 downto 0);
    m_axi_awvalid      : out std_logic;
    m_axi_awready      : in  std_logic;
    m_axi_awlock       : out std_logic;
 -- AXI Write Data Channel Signals
    m_axi_wdata        : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    m_axi_wstrb        : out std_logic_vector
                             ((C_M_AXI_DATA_WIDTH/8)-1 downto 0);
    m_axi_wlast        : out std_logic;
    m_axi_wvalid       : out std_logic;
    m_axi_wready       : in  std_logic;
    
 -- AXI Write Response Channel Signals
    m_axi_bid          : in  std_logic_vector 
                             (C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
    m_axi_bresp        : in  std_logic_vector(1 downto 0);
    m_axi_bvalid       : in  std_logic;
    m_axi_bready       : out std_logic;

 -- AXI Read Address Channel Signals
    m_axi_arid         : out std_logic_vector 
                             (C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
    m_axi_arlen        : out std_logic_vector(7 downto 0);
    m_axi_arsize       : out std_logic_vector(2 downto 0);
    m_axi_arburst      : out std_logic_vector(1 downto 0);
    m_axi_arprot       : out std_logic_vector(2 downto 0);
    m_axi_arcache      : out std_logic_vector(3 downto 0);
    m_axi_arvalid      : out std_logic;
    --M_AXI_ARADDR       : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    m_axi_araddr       : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    m_axi_arlock       : out std_logic;
    m_axi_arready      : in  std_logic;
 -- AXI Read Data Channel Sigals
    m_axi_rid          : in  std_logic_vector 
                             (C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
    m_axi_rdata        : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    m_axi_rresp        : in  std_logic_vector(1 downto 0);
    m_axi_rvalid       : in  std_logic;
    m_axi_rlast        : in  std_logic;
    m_axi_rready       : out std_logic
    );

end entity ahblite_axi_bridge;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of ahblite_axi_bridge is
-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";



-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------
signal axi_wdata_done         : std_logic;
signal axi_bresp_ok           : std_logic;
signal axi_bresp_err          : std_logic;
signal set_axi_raddr          : std_logic;
signal set_axi_waddr          : std_logic;
signal ahb_wnr                : std_logic;
signal set_axi_wdata_burst    : std_logic;
signal set_axi_rdata          : std_logic;

signal core_is_idle           : std_logic;
signal set_hready             : std_logic;
signal reset_hready           : std_logic;
signal set_hresp_err          : std_logic;
signal reset_hresp_err        : std_logic;
signal nonseq_txfer_pending   : std_logic;
signal idle_txfer_pending     : std_logic;
signal burst_term_hwrite      : std_logic;
signal burst_term_single_incr : std_logic;
signal init_pending_txfer     : std_logic;
signal axi_bresp_ready        : std_logic;
signal rvalid_rready          : std_logic;
signal axi_rresp_err          : std_logic_vector( 1 downto 0);
signal txer_rdata_to_ahb      : std_logic;

signal nonseq_detected        : std_logic;
signal seq_detected           : std_logic;
signal busy_detected          : std_logic;
signal ahb_valid_cnt          : std_logic_vector(4 downto 0);
signal ahb_hwrite             : std_logic;
signal ahb_hburst_single      : std_logic;
signal ahb_hburst_incr        : std_logic;
signal ahb_hburst_wrap4       : std_logic;
signal ahb_haddr_hsize        : std_logic_vector( 4 downto 0);
signal ahb_hsize              : std_logic_vector( 1 downto 0);
signal valid_cnt_required     : std_logic_vector( 4 downto 0);
signal burst_term_txer_cnt    : std_logic_vector( 4 downto 0);
signal burst_term_cur_cnt     : std_logic_vector( 4 downto 0);
signal ahb_data_valid         : std_logic;
    
signal last_axi_rd_sample     : std_logic;

signal timeout_o              : std_logic;
signal wr_load_timeout_cntr   : std_logic;
signal rd_load_timeout_cntr   : std_logic;
signal enable_timeout_cnt     : std_logic;

signal burst_term             : std_logic;
signal axi_wr_channel_ready   : std_logic;
signal axi_wr_channel_busy    : std_logic;
signal placed_on_axi          : std_logic;
signal placed_in_local_buf    : std_logic;
signal timeout_detected       : std_logic;

begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------
--m_axi_aclk and m_axi_aresetn are tied to s_ahb_hclk and s_ahb_hresetn
-- respectively
--------------------------------------------------------------------------------
--  m_axi_aclk     <= s_ahb_hclk;
--  m_axi_aresetn  <= s_ahb_hresetn;
    
-------------------------------------------------------------------------------
-- Instantiate the control module
-------------------------------------------------------------------------------
  AHBLITE_AXI_CONTROL : entity ahblite_axi_bridge_v3_0_15.ahblite_axi_control
  port map
  ( 
  -- AHB Signals
     S_AHB_HCLK             =>    s_ahb_hclk              ,
     S_AHB_HRESETN          =>    s_ahb_hresetn           ,
     S_AHB_HWRITE           =>    s_ahb_hwrite            ,
     S_AHB_HBURST           =>    s_ahb_hburst            ,
  -- AXI Write/Read channels 
     axi_wr_channel_ready   =>    axi_wr_channel_ready    ,
     axi_wr_channel_busy    =>    axi_wr_channel_busy     ,
     axi_wdata_done         =>    axi_wdata_done          ,
     rvalid_rready          =>    rvalid_rready           ,
     last_axi_rd_sample     =>    last_axi_rd_sample      ,
     axi_rresp_err          =>    axi_rresp_err           ,
     axi_bresp_ok           =>    axi_bresp_ok            ,
     axi_bresp_err          =>    axi_bresp_err           ,
     set_axi_raddr          =>    set_axi_raddr           ,
     set_axi_waddr          =>    set_axi_waddr           ,
     ahb_wnr                =>    ahb_wnr                 ,
     set_axi_wdata_burst    =>    set_axi_wdata_burst     ,
     set_axi_rdata          =>    set_axi_rdata           ,
 -- Timeout module    
     enable_timeout_cnt     =>    enable_timeout_cnt      ,
     timeout_i              =>    timeout_o               ,
  -- For AHB interface module  
     core_is_idle           =>    core_is_idle            ,
     set_hready             =>    set_hready              ,
     reset_hready           =>    reset_hready            ,
     set_hresp_err          =>    set_hresp_err           ,
     reset_hresp_err        =>    reset_hresp_err         ,
     nonseq_txfer_pending   =>    nonseq_txfer_pending    ,
     idle_txfer_pending     =>    idle_txfer_pending      ,
     burst_term_hwrite      =>    burst_term_hwrite       ,
     burst_term_single_incr =>    burst_term_single_incr  ,
     init_pending_txfer     =>    init_pending_txfer      ,
     axi_bresp_ready        =>    axi_bresp_ready         ,
     nonseq_detected        =>    nonseq_detected         ,
     seq_detected           =>    seq_detected            ,
     ahb_hburst_single      =>    ahb_hburst_single       ,
     ahb_hburst_incr        =>    ahb_hburst_incr    
  ); -- ahblite_axi_control

--------------------------------------------------------------------------------
-- ahb interface instantiation
--------------------------------------------------------------------------------
  AHB_IF :entity ahblite_axi_bridge_v3_0_15.ahb_if
  generic map (
    C_M_AXI_ADDR_WIDTH            => C_M_AXI_ADDR_WIDTH     ,         
    C_S_AHB_ADDR_WIDTH            => C_S_AHB_ADDR_WIDTH     ,         
    C_S_AHB_DATA_WIDTH            => C_S_AHB_DATA_WIDTH     , 
    C_M_AXI_DATA_WIDTH            => C_M_AXI_DATA_WIDTH     ,
    C_M_AXI_THREAD_ID_WIDTH       => C_M_AXI_THREAD_ID_WIDTH,   
    C_M_AXI_NON_SECURE            => C_M_AXI_NON_SECURE     
  )
  port map
  (
   -- AHB Signals 
      S_AHB_HCLK             =>      s_ahb_hclk             ,
      S_AHB_HRESETN          =>      s_ahb_hresetn          ,
      S_AHB_HADDR            =>      s_ahb_haddr            ,
      S_AHB_HSEL             =>      s_ahb_hsel             ,
      S_AHB_HTRANS           =>      s_ahb_htrans           ,
      S_AHB_HSIZE            =>      s_ahb_hsize            ,
      S_AHB_HWRITE           =>      s_ahb_hwrite           ,
      S_AHB_HBURST           =>      s_ahb_hburst           ,
      S_AHB_HREADY_IN        =>      s_ahb_hready_in        ,
      S_AHB_HREADY_OUT       =>      s_ahb_hready_out       ,
      S_AHB_HPROT            =>      s_ahb_hprot            ,
      S_AHB_HRESP            =>      s_ahb_hresp            ,
      S_AHB_HRDATA           =>      s_ahb_hrdata           ,
   -- AXI-AW Channel
      M_AXI_AWID             =>      m_axi_awid             ,
      M_AXI_AWLEN            =>      m_axi_awlen            ,
      M_AXI_AWSIZE           =>      m_axi_awsize           ,
      M_AXI_AWBURST          =>      m_axi_awburst          ,
      M_AXI_AWCACHE          =>      m_axi_awcache          ,
      M_AXI_AWADDR           =>      m_axi_awaddr           ,
      M_AXI_AWPROT           =>      m_axi_awprot           ,
      M_AXI_AWLOCK           =>      m_axi_awlock           ,
   -- AXI-AR Channel
      M_AXI_ARID             =>      m_axi_arid             ,
      M_AXI_ARLEN            =>      m_axi_arlen            ,
      M_AXI_ARSIZE           =>      m_axi_arsize           ,
      M_AXI_ARBURST          =>      m_axi_arburst          ,
      M_AXI_ARPROT           =>      m_axi_arprot           ,
      M_AXI_ARCACHE          =>      m_axi_arcache          ,
      M_AXI_ARADDR           =>      m_axi_araddr           ,
      M_AXI_ARLOCK           =>      m_axi_arlock           ,
   -- AHB interface module  
      core_is_idle           =>      core_is_idle           ,
      ahb_valid_cnt          =>      ahb_valid_cnt          ,
      ahb_hwrite             =>      ahb_hwrite             ,
      nonseq_detected        =>      nonseq_detected        ,
      seq_detected           =>      seq_detected           ,
      busy_detected          =>      busy_detected          ,
      set_hready             =>      set_hready             ,
      reset_hready           =>      reset_hready           ,
      set_hresp_err          =>      set_hresp_err          ,
      reset_hresp_err        =>      reset_hresp_err        ,
      nonseq_txfer_pending   =>      nonseq_txfer_pending   ,
      idle_txfer_pending     =>      idle_txfer_pending     ,
      burst_term_hwrite      =>      burst_term_hwrite      ,
      burst_term_single_incr =>      burst_term_single_incr ,
      init_pending_txfer     =>      init_pending_txfer     ,
   -- AXI Write/Read channels 
      axi_wdata_done         =>      axi_wdata_done         ,
      timeout_detected       =>      timeout_detected       ,
      last_axi_rd_sample     =>      last_axi_rd_sample     ,
      burst_term             =>      burst_term             , 
      ahb_hburst_single      =>      ahb_hburst_single      ,
      ahb_hburst_incr        =>      ahb_hburst_incr        , 
      ahb_hburst_wrap4       =>      ahb_hburst_wrap4       , 
      ahb_haddr_hsize        =>      ahb_haddr_hsize        ,
      ahb_hsize              =>      ahb_hsize              ,
      valid_cnt_required     =>      valid_cnt_required     ,
      burst_term_txer_cnt    =>      burst_term_txer_cnt    ,
      burst_term_cur_cnt     =>      burst_term_cur_cnt     ,
      ahb_data_valid         =>      ahb_data_valid         ,
      placed_on_axi          =>      placed_on_axi          ,
      placed_in_local_buf    =>      placed_in_local_buf    ,
      txer_rdata_to_ahb      =>      txer_rdata_to_ahb      ,
      M_AXI_RDATA            =>      m_axi_rdata          
  ); -- ahb_if

--------------------------------------------------------------------------------
--AHB data counter to count the number of valid(NONSEQ or SEQ) samples
-- received during a burst.
--------------------------------------------------------------------------------
  AHB_DATA_COUNTER : entity ahblite_axi_bridge_v3_0_15.ahb_data_counter
  port map
  (
  -- AHB Signals
     S_AHB_HCLK         =>      s_ahb_hclk         ,
     S_AHB_HRESETN      =>      s_ahb_hresetn      ,
  -- ahb_if module
     ahb_hwrite         =>      ahb_hwrite         ,
     ahb_hburst_incr    =>      ahb_hburst_incr    ,
     nonseq_detected    =>      nonseq_detected    ,
     seq_detected       =>      seq_detected       ,
     ahb_valid_cnt      =>      ahb_valid_cnt       
  ); -- ahb_data_counter

--------------------------------------------------------------------------------
--axi_wchannel instantiation
--------------------------------------------------------------------------------
  AXI_WCHANNEL : entity ahblite_axi_bridge_v3_0_15.axi_wchannel
  generic map (
    C_S_AHB_ADDR_WIDTH            => C_S_AHB_ADDR_WIDTH           ,         
    C_M_AXI_ADDR_WIDTH            => C_M_AXI_ADDR_WIDTH           ,         
    C_S_AHB_DATA_WIDTH            => C_S_AHB_DATA_WIDTH           ,
    C_M_AXI_DATA_WIDTH            => C_M_AXI_DATA_WIDTH           ,
    C_M_AXI_THREAD_ID_WIDTH       => C_M_AXI_THREAD_ID_WIDTH      ,
    C_M_AXI_SUPPORTS_NARROW_BURST => C_M_AXI_SUPPORTS_NARROW_BURST
              )
  port map
  (
  -- AHB Signals
     S_AHB_HCLK          =>      s_ahb_hclk          ,
     S_AHB_HRESETN       =>      s_ahb_hresetn       ,
     S_AHB_HWDATA        =>      s_ahb_hwdata        ,
  -- AXI Write Address Channel Signals
     M_AXI_AWVALID       =>     m_axi_awvalid        ,
     M_AXI_AWREADY       =>     m_axi_awready        ,
  -- AXI Write Data Channel Signals
     M_AXI_WDATA         =>     m_axi_wdata          ,
     M_AXI_WSTRB         =>     m_axi_wstrb          ,
     M_AXI_WLAST         =>     m_axi_wlast          ,
     M_AXI_WVALID        =>     m_axi_wvalid         ,
     M_AXI_WREADY        =>     m_axi_wready         ,
  -- AXI Write Response Channel signals
     M_AXI_BVALID        =>     m_axi_bvalid         ,
     M_AXI_BRESP         =>     m_axi_bresp          ,
     M_AXI_BREADY        =>     m_axi_bready         ,
  -- Control signals to/from  state machine 
     axi_wdata_done      =>     axi_wdata_done       ,
     axi_bresp_ok        =>     axi_bresp_ok         ,
     axi_bresp_err       =>     axi_bresp_err        ,
     set_axi_waddr       =>     set_axi_waddr        ,
     ahb_wnr             =>     ahb_wnr              ,
     set_axi_wdata_burst =>     set_axi_wdata_burst  ,
  -- ahb_if module
     ahb_hburst_single   =>     ahb_hburst_single    ,
     ahb_hburst_incr     =>     ahb_hburst_incr      ,
     ahb_hburst_wrap4    =>     ahb_hburst_wrap4     , 
     ahb_haddr_hsize     =>     ahb_haddr_hsize      ,
     ahb_hsize           =>     ahb_hsize            ,
     valid_cnt_required  =>     valid_cnt_required   ,
     burst_term_txer_cnt =>     burst_term_txer_cnt  ,
     ahb_data_valid      =>     ahb_data_valid       ,
     burst_term_cur_cnt  =>     burst_term_cur_cnt   ,
     burst_term          =>     burst_term           ,
     nonseq_txfer_pending=>     nonseq_txfer_pending ,
     init_pending_txfer  =>     init_pending_txfer   ,
     axi_wr_channel_ready=>     axi_wr_channel_ready ,
     axi_wr_channel_busy =>     axi_wr_channel_busy  ,
     placed_on_axi       =>     placed_on_axi        ,
     placed_in_local_buf =>     placed_in_local_buf  ,
     timeout_detected    =>     timeout_detected     ,
     timeout_i           =>     timeout_o            , 
     wr_load_timeout_cntr=>     wr_load_timeout_cntr              
  ); -- axi_wchannel

--------------------------------------------------------------------------------
--axi_rchannel instantiation
--------------------------------------------------------------------------------
  AXI_RCHANNEL : entity ahblite_axi_bridge_v3_0_15.axi_rchannel
  generic map (
    C_S_AHB_ADDR_WIDTH            => C_S_AHB_ADDR_WIDTH           ,         
    C_M_AXI_ADDR_WIDTH            => C_M_AXI_ADDR_WIDTH           ,         
    C_M_AXI_DATA_WIDTH            => C_M_AXI_DATA_WIDTH           ,
    C_M_AXI_THREAD_ID_WIDTH       => C_M_AXI_THREAD_ID_WIDTH        
  )
  port map (
  -- AHB Signals 
    S_AHB_HCLK            =>      s_ahb_hclk          ,
    S_AHB_HRESETN         =>      s_ahb_hresetn       ,
  -- AHB interface signals
    seq_detected          =>      seq_detected        , 
    busy_detected         =>      busy_detected       ,
    rvalid_rready         =>      rvalid_rready       ,
    axi_rresp_err         =>      axi_rresp_err       ,
    txer_rdata_to_ahb     =>      txer_rdata_to_ahb   ,
  -- AXI Read Address Channel Signals 
    M_AXI_ARVALID         =>     m_axi_arvalid        ,
    M_AXI_ARREADY         =>     m_axi_arready        ,
  -- AXI Read Data Channel Signals 
    M_AXI_RVALID          =>     m_axi_rvalid         ,
    M_AXI_RLAST           =>     m_axi_rlast          ,
    M_AXI_RRESP           =>     m_axi_rresp          ,
    M_AXI_RREADY          =>     m_axi_rready         ,
  -- Timeout module
     rd_load_timeout_cntr =>     rd_load_timeout_cntr , 
  -- AHB interface module
    set_hresp_err         =>     set_hresp_err        ,
    last_axi_rd_sample    =>     last_axi_rd_sample   ,
  -- Control signals to/from state machine block 
    set_axi_raddr         =>     set_axi_raddr       
  ); -- axi_rchannel

--------------------------------------------------------------------------------
--time_out module instantiation
--------------------------------------------------------------------------------
  TIME_OUT : entity ahblite_axi_bridge_v3_0_15.time_out
  generic map (
    C_FAMILY              => C_FAMILY       ,
    C_AHB_AXI_TIMEOUT     => C_AHB_AXI_TIMEOUT
    )
  port map
  ( 
    S_AHB_HCLK           => s_ahb_hclk           ,
    S_AHB_HRESETN        => s_ahb_hresetn        ,
    enable_timeout_cnt   => enable_timeout_cnt   ,
    M_AXI_BVALID         => m_axi_bvalid         ,
    wr_load_timeout_cntr => wr_load_timeout_cntr ,
    last_axi_rd_sample   => last_axi_rd_sample   ,
    rd_load_timeout_cntr => rd_load_timeout_cntr ,
    core_is_idle         => core_is_idle         ,
    timeout_o            => timeout_o       
  ); -- time_out
end architecture RTL;


