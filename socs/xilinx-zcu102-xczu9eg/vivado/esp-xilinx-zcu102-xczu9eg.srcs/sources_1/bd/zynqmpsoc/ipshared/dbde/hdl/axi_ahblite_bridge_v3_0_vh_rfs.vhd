
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
--
--
-- *******************************************************************
-- ** (c) Copyright [2007] - [2012] Xilinx, Inc. All rights reserved.*
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
-- **                                              
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
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Filename     :   time_out.vhd
-- Version      :   v1.01a
-- Description  :   The time_out module generates the timeout signal when 
--                  AHB slave is not responding.When C_DPHASE_TIMEOUT is '0'
--                  the timeout signal is always '0' and this module generates
--                  the timeout signal if C_DPHASE_TIMEOUT is nonzero.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- axi_ahblite_bridge.vhd
--              -- axi_slv_if.vhd 
--              -- ahb_mstr_if.vhd
--              -- time_out.vhd
-------------------------------------------------------------------------------
-- Author:     NLR 
-- History:
--   NLR      12/15/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*N"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      counter signals:                        "*cntr*","*count*"
--      ports:                                  - Names In Uppercase
--      processes:                              "*_REG", "*_CMB"
--      component instantiations:               "<ENTITY_>MODULE<#|_FUNC>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library axi_ahblite_bridge_v3_0_17;

entity time_out is
  generic (
    C_FAMILY              : string    := "virtex7";
    C_DPHASE_TIMEOUT      : integer   := 0
     );
  port (
    -- AXI Signals
    S_AXI_ACLK       : in  std_logic;
    S_AXI_ARESETN    : in  std_logic;
    --AHB Signal
    M_AHB_HREADY     : in std_logic;
    --AHB Master Interface and AXI Slave Interface signals
    load_cntr        : in std_logic;
    cntr_enable      : in std_logic;
    timeout_o        : out std_logic
     );

end entity time_out;

architecture RTL of time_out is

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

-------------------------------------------------------------------------------
-- Pragma Added to supress synth warnings
-------------------------------------------------------------------------------
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";
begin
 -------------------------------------------------------------------------------
   -- This implements the watchdog timeout function.Acknowledge from the 
   -- AHB slave space forces the counter to reload.When the AHB is not 
   -- responding and not generating M_AHB_HREADY within the number of clock 
   -- cycles mentioned in C_DPHASE_TIMEOUT, AXI interface generates ready to
   -- to AXI master so that AXI is not hung. SLVERR response is sent to AXI
   -- when timeout occurs.The below functionality exists when C_DPHASE_TIMEOUT
   -- is nonzero.
   ------------------------------------------------------------------------------- 
    
   GEN_WDT : if (C_DPHASE_TIMEOUT /= 0) generate
    
       constant TIMEOUT_VALUE_TO_USE : integer := C_DPHASE_TIMEOUT;
       constant COUNTER_WIDTH        : Integer := clog2(TIMEOUT_VALUE_TO_USE);
       constant DPTO_LD_VALUE        : std_logic_vector(COUNTER_WIDTH-1 downto 0)
                                     := std_logic_vector(to_unsigned
                                        (TIMEOUT_VALUE_TO_USE-1,COUNTER_WIDTH));
       signal timeout_i              : std_logic;
       signal cntr_rst               : std_logic;
    
   begin
   
   cntr_rst <= not S_AXI_ARESETN or timeout_i;
   
-- ****************************************************************************
-- Instantiation of counter
-- ****************************************************************************

      I_TO_COUNTER_MODULE : entity axi_ahblite_bridge_v3_0_17.counter_f
         generic map(
           C_NUM_BITS    =>  COUNTER_WIDTH,
           C_FAMILY      =>  C_FAMILY
             )
         port map(
           Clk           =>  S_AXI_ACLK,
           Rst           =>  cntr_rst,
           Load_In       =>  DPTO_LD_VALUE,
           Count_Enable  =>  cntr_enable,
           Count_Load    =>  load_cntr,
           Count_Down    =>  '1',
           Count_Out     =>  open,
           Carry_Out     =>  timeout_i
           );
       
-- ****************************************************************************
-- This process is used for registering timeout
-- This timeout signal is used in generating the ready to AXI to complete
-- the AXI transaction.
-- ****************************************************************************

       TIMEOUT_REG : process(S_AXI_ACLK)
       begin
           if(S_AXI_ACLK'EVENT and S_AXI_ACLK='1')then
               if(S_AXI_ARESETN='0')then
                   timeout_o <= '0';
               else
                   timeout_o <= timeout_i and not (M_AHB_HREADY);
               end if;
           end if;
       end process TIMEOUT_REG;
       
   end generate GEN_WDT;
   
-- ****************************************************************************
-- No timeout logic when C_DPHASE_TIMEOUT = 0
-- ****************************************************************************

   GEN_NO_WDT : if (C_DPHASE_TIMEOUT = 0) generate
   begin
        timeout_o <= '0';
   end generate GEN_NO_WDT;
   
end architecture RTL;


-------------------------------------------------------------------------------
-- ahb_skid_buf.vhd
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
--  (c) Copyright 2010-2011, 2013 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES. 
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        ahb_skid_buf.vhd
-- Version:         v3.0
--
-- Description:
--  Implements the AXi Skid Buffer in the Option 2 (Registerd outputs) mode.
--
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- axi_ahblite_bridge.vhd
--              -- ahb_skid_buf.vhd
--              -- axi_slv_if.vhd
--              -- ahb_mstr_if.vhd 
--              -- time_out.vhd
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-------------------------------------------------------------------------------

entity ahb_skid_buf is
  generic (
    C_WDATA_WIDTH : INTEGER range 8 to 1024 := 32;
       --  Width of the Stream Data bus (in bits)
    C_S_AXI_ID_WIDTH              : integer range 1 to 32     := 4;
    C_TUSER_WIDTH : INTEGER range 1 to 128  := 1
       -- Width of tuser bus (in bits)

    );
  port (
  -- System Ports
     ACLK         : In  std_logic ;                                         --
     ARST         : In  std_logic ;                                         --
                                                                            --
   -- Shutdown control (assert for 1 clk pulse)                             --
     skid_stop    : In std_logic  ;                                         --
   -- Slave Side (Stream Data Input)                                        --
     S_VALID      : In  std_logic ;                                         --
     S_READY      : Out std_logic ;                                         --
     S_Data       : In  std_logic_vector(C_WDATA_WIDTH-1 downto 0);         --
     S_STRB       : In  std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0);     --
     S_Last       : In  std_logic ;                                         --
     S_User       : In  std_logic_vector(C_TUSER_WIDTH-1 downto 0);         --
     S_RID        : In std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);       --
     S_RESP       : In std_logic_vector(1 downto 0);                        --
     -- Master Side (Stream Data Output                                     --
     M_RESP       : Out std_logic_vector(1 downto 0);                       --
     M_VALID      : Out std_logic ;                                         --
     M_READY      : In  std_logic ;                                         --
     M_RID        : Out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);      --
     M_Data       : Out std_logic_vector(C_WDATA_WIDTH-1 downto 0);         --
     M_STRB       : Out std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0);     --
     M_Last       : Out std_logic;                                          --
     M_User       : Out std_logic_vector(C_TUSER_WIDTH-1 downto 0)          --
    );

end entity ahb_skid_buf;


architecture implementation of ahb_skid_buf is

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-- Signals decalrations -------------------------

  Signal sig_reset_reg         : std_logic := '0';
  signal sig_spcl_s_ready_set  : std_logic := '0';

  signal sig_data_skid_reg     : std_logic_vector(C_WDATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_strb_skid_reg     : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_last_skid_reg     : std_logic := '0';
  signal sig_skid_reg_en       : std_logic := '0';

  signal sig_data_skid_mux_out : std_logic_vector(C_WDATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_strb_skid_mux_out : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_last_skid_mux_out : std_logic := '0';
  signal sig_skid_mux_sel      : std_logic := '0';

  signal sig_rid_skid_reg      : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0) := (others => '0');
  signal sig_rid_skid_mux_out  : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0) := (others => '0');
  signal sig_resp_reg_out      : std_logic_vector(1 downto 0) := (others => '0');
  signal sig_resp_skid_mux_out : std_logic_vector(1 downto 0) := (others => '0');
  signal sig_resp_skid_reg     : std_logic_vector(1 downto 0) := (others => '0');
  signal sig_rid_reg_out       : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0) := (others => '0');
  signal sig_data_reg_out      : std_logic_vector(C_WDATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_strb_reg_out      : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_last_reg_out      : std_logic := '0';
  signal sig_data_reg_out_en   : std_logic := '0';

  signal sig_m_valid_out       : std_logic := '0';
  signal sig_m_valid_dup       : std_logic := '0';
  signal sig_m_valid_comb      : std_logic := '0';

  signal sig_s_ready_out       : std_logic := '0';
  signal sig_s_ready_dup       : std_logic := '0';
  signal sig_s_ready_comb      : std_logic := '0';

  signal sig_stop_request      : std_logic := '0';
--  signal sig_stopped           : std_logic := '0';
  signal sig_sready_stop       : std_logic := '0';
  signal sig_sready_stop_reg   : std_logic := '0';
  signal sig_s_last_xfered     : std_logic := '0';

  signal sig_m_last_xfered     : std_logic := '0';
  signal sig_mvalid_stop_reg   : std_logic := '0';
  signal sig_mvalid_stop       : std_logic := '0';

  signal sig_slast_with_stop   : std_logic := '0';
  signal sig_sstrb_stop_mask   : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_sstrb_with_stop   : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');


  signal sig_user_skid_mux_out : std_logic_vector(C_TUSER_WIDTH-1 downto 0) := (others => '0');
  signal sig_user_skid_reg     : std_logic_vector(C_TUSER_WIDTH-1 downto 0) := (others => '0');
  signal sig_user_reg_out      : std_logic_vector(C_TUSER_WIDTH-1 downto 0) := (others => '0');


-- Register duplication attribute assignments to control fanout
-- on handshake output signals

  Attribute KEEP : string; -- declaration
  Attribute EQUIVALENT_REGISTER_REMOVAL : string; -- declaration

  Attribute KEEP of sig_m_valid_out : signal is "TRUE"; -- definition
  Attribute KEEP of sig_m_valid_dup : signal is "TRUE"; -- definition
  Attribute KEEP of sig_s_ready_out : signal is "TRUE"; -- definition
  Attribute KEEP of sig_s_ready_dup : signal is "TRUE"; -- definition

  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_m_valid_out : signal is "no";
  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_m_valid_dup : signal is "no";
  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_s_ready_out : signal is "no";
  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_s_ready_dup : signal is "no";


begin --(architecture implementation)

   M_VALID <= sig_m_valid_out;
   S_READY <= sig_s_ready_out;

   M_STRB  <= sig_strb_reg_out;
   M_Last  <= sig_last_reg_out;
   M_Data  <= sig_data_reg_out;
   M_RID   <= sig_rid_reg_out;
   M_RESP  <= sig_resp_reg_out;
   M_User  <= sig_user_reg_out;

  -- Special shutdown logic version od Slast.
  -- A halt request forces a tlast through the skig buffer
  sig_slast_with_stop <= s_last or sig_stop_request;
  sig_sstrb_with_stop <= s_strb or sig_sstrb_stop_mask;
  -- Assign the special S_READY FLOP set signal
  sig_spcl_s_ready_set <= sig_reset_reg;


  -- Generate the ouput register load enable control
   sig_data_reg_out_en <= M_READY or not(sig_m_valid_dup);

  -- Generate the skid input register load enable control
   sig_skid_reg_en     <= sig_s_ready_dup;

  -- Generate the skid mux select control
   sig_skid_mux_sel    <= not(sig_s_ready_dup);


 -- Skid Mux
   sig_data_skid_mux_out <=  sig_data_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  S_Data;

   sig_rid_skid_mux_out <=  sig_rid_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  S_RID;

     sig_resp_skid_mux_out <=  sig_resp_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  S_RESP;

     sig_user_skid_mux_out <= sig_user_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  S_User;


   sig_strb_skid_mux_out <=  sig_strb_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  sig_sstrb_with_stop;

   sig_last_skid_mux_out <=  sig_last_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  sig_slast_with_stop;


   -- m_valid combinational logic
   sig_m_valid_comb <= S_VALID or
                      (sig_m_valid_dup and
                      (not(sig_s_ready_dup) or
                       not(M_READY)));



   -- s_ready combinational logic
   sig_s_ready_comb <= M_READY or
                      (sig_s_ready_dup and
                      (not(sig_m_valid_dup) or
                       not(S_VALID)));



   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: REG_THE_RST
   --
   -- Process Description:
   -- Register input reset
   --
   -------------------------------------------------------------
   REG_THE_RST : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then

            sig_reset_reg <= ARST;

        end if;
      end process REG_THE_RST;




   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: S_READY_FLOP
   --
   -- Process Description:
   -- Registers S_READY handshake signals per Skid Buffer
   -- Option 2 scheme
   --
   -------------------------------------------------------------
   S_READY_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST            = '1' or
               sig_sready_stop = '1') then  -- Special stop condition

             sig_s_ready_out  <= '0';
             sig_s_ready_dup  <= '0';

           Elsif (sig_spcl_s_ready_set = '1') Then

             sig_s_ready_out  <= '1';
             sig_s_ready_dup  <= '1';

           else

             sig_s_ready_out  <= sig_s_ready_comb;
             sig_s_ready_dup  <= sig_s_ready_comb;

           end if;
        end if;
      end process S_READY_FLOP;






   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: M_VALID_FLOP
   --
   -- Process Description:
   -- Registers M_VALID handshake signals per Skid Buffer
   -- Option 2 scheme
   --
   -------------------------------------------------------------
   M_VALID_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST                 = '1' or
               sig_spcl_s_ready_set = '1' or    -- Fix from AXI DMA
               sig_mvalid_stop      = '1') then -- Special stop condition
             sig_m_valid_out  <= '0';
             sig_m_valid_dup  <= '0';

           else

             sig_m_valid_out  <= sig_m_valid_comb;
             sig_m_valid_dup  <= sig_m_valid_comb;

           end if;
        end if;
      end process M_VALID_FLOP;






   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: SKID_REG
   --
   -- Process Description:
   -- This process implements the output registers for the
   -- Skid Buffer Data signals
   --
   -------------------------------------------------------------
   SKID_REG : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then

             sig_data_skid_reg <= (others => '0');
             sig_rid_skid_reg  <= (others => '0');
             sig_resp_skid_reg <= (others => '0');
             sig_strb_skid_reg <= (others => '0');
             sig_last_skid_reg <= '0';
             sig_user_skid_reg <= (others => '0');

           elsif (sig_skid_reg_en = '1') then

             sig_data_skid_reg <= S_Data;
             sig_rid_skid_reg  <= S_RID;
             sig_resp_skid_reg <= S_RESP;
             sig_strb_skid_reg <= sig_sstrb_with_stop;
             sig_last_skid_reg <= sig_slast_with_stop;
             sig_user_skid_reg <= S_User;
           else
             null;  -- hold current state
           end if;
        end if;
      end process SKID_REG;





   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: OUTPUT_REG
   --
   -- Process Description:
   -- This process implements the output registers for the
   -- Skid Buffer Data signals
   --
   -------------------------------------------------------------
   OUTPUT_REG : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST                = '1' or
               sig_mvalid_stop_reg = '1') then

             sig_data_reg_out <= (others => '0');
             sig_rid_reg_out  <= (others => '0');
             sig_resp_reg_out <= (others => '0');
             sig_strb_reg_out <= (others => '0');
             sig_last_reg_out <= '0';
             sig_user_reg_out <= (others => '0');

           elsif (sig_data_reg_out_en = '1') then

             sig_data_reg_out <= sig_data_skid_mux_out;
             sig_rid_reg_out  <= sig_rid_skid_mux_out;
             sig_resp_reg_out <= sig_resp_skid_mux_out;
             sig_strb_reg_out <= sig_strb_skid_mux_out;
             sig_last_reg_out <= sig_last_skid_mux_out;
             sig_user_reg_out <= sig_user_skid_mux_out;

           else
             null;  -- hold current state
           end if;
        end if;
      end process OUTPUT_REG;




   -------- Special Stop Logic --------------------------------------


   sig_s_last_xfered  <=  sig_s_ready_dup and
                          s_valid         and
                          sig_slast_with_stop;


   sig_sready_stop    <=  (sig_s_last_xfered and
                          sig_stop_request) or
                          sig_sready_stop_reg;






   sig_m_last_xfered  <=  sig_m_valid_dup and
                          m_ready         and
                          sig_last_reg_out;


   sig_mvalid_stop    <=  (sig_m_last_xfered and
                          sig_stop_request)  or
                          sig_mvalid_stop_reg;




   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_STOP_REQ_FLOP
   --
   -- Process Description:
   -- This process implements the Stop request flop. It is a
   -- sample and hold register that can only be cleared by reset.
   --
   -------------------------------------------------------------
   IMP_STOP_REQ_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then

             sig_stop_request <= '0';
             sig_sstrb_stop_mask <= (others => '0');

           elsif (skid_stop = '1') then

             sig_stop_request <= '1';
             sig_sstrb_stop_mask <= (others => '1');

           else
             null;  -- hold current state
           end if;
        end if;
      end process IMP_STOP_REQ_FLOP;









   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_CLR_SREADY_FLOP
   --
   -- Process Description:
   -- This process implements the flag to clear the s_ready
   -- flop at a stop condition.
   --
   -------------------------------------------------------------
   IMP_CLR_SREADY_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then

             sig_sready_stop_reg <= '0';

           elsif (sig_s_last_xfered = '1' and
                  sig_stop_request  = '1') then

             sig_sready_stop_reg <= '1';

           else
             null;  -- hold current state
           end if;
        end if;
      end process IMP_CLR_SREADY_FLOP;





   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_CLR_MREADY_FLOP
   --
   -- Process Description:
   -- This process implements the flag to clear the m_ready
   -- flop at a stop condition.
   --
   -------------------------------------------------------------
   IMP_CLR_MVALID_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then

             sig_mvalid_stop_reg <= '0';

           elsif (sig_m_last_xfered = '1' and
                  sig_stop_request  = '1') then

             sig_mvalid_stop_reg <= '1';

           else
             null;  -- hold current state
           end if;
        end if;
      end process IMP_CLR_MVALID_FLOP;



end implementation;



-------------------------------------------------------------------------------
-- axi_slv_if.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- *******************************************************************
-- ** (c) Copyright [2007] - [2012] Xilinx, Inc. All rights reserved.*
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
-- **                                          
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
--
-------------------------------------------------------------------------------
-- Filename     :   axi_slv_if.vhd
-- Version      :   v2.00a
-- Description  :   The AXI4 Slave Interface module provides a
--                  bi-directional slave interface to the AXI. The AXI data
--                  bus width can be 32/64-bits. When both write and
--                  read transfers are simultaneously requested on AXI4,
--                  read request is given more priority than write request.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- axi_ahblite_bridge.vhd
--              -- axi_slv_if.vhd
--              -- ahb_mstr_if.vhd
--              -- time_out.vhd
-------------------------------------------------------------------------------
-- Author:     NLR 
-- History:
--   NLR      12/15/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
--   NLR      04/10/2012   Added the strobe support for single tarnsfers
-- ^^^^^^^
-- ~~~~~~~
--   NLR      09/04/2013   Fixed issue when hready is low during last but one
--            data in burst CR#707167 Fix.
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*N"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      counter signals:                        "*cntr*", "*count*"
--      ports:                                  - Names in Uppercase
--      processes:                              "*_REG", "*_CMB"
--      component instantiations:               "<ENTITY_>MODULE<#|_FUNC>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce;

entity axi_slv_if is
  generic (
    C_FAMILY              : string                   := "virtex6";
    C_S_AXI_ID_WIDTH      : integer range 1 to 32    := 4;
    C_S_AXI_ADDR_WIDTH    : integer range 32 to 64   := 32;
    C_S_AXI_DATA_WIDTH    : integer := 32;
    C_DPHASE_TIMEOUT      : integer := 0
    );
  port (
  -- AXI Signals
    S_AXI_ACLK       : in  std_logic;
    S_AXI_ARESETN    : in  std_logic;

    S_AXI_AWID       : in  std_logic_vector 
                           (C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_AWADDR     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT     : in  std_logic_vector(2 downto 0);
    S_AXI_AWCACHE    : in  std_logic_vector(3 downto 0);
    S_AXI_AWLEN      : in  std_logic_vector(7 downto 0);
    S_AXI_AWSIZE     : in  std_logic_vector(2 downto 0);
    S_AXI_AWBURST    : in  std_logic_vector(1 downto 0);
    S_AXI_AWLOCK     : in  std_logic;
    S_AXI_AWVALID    : in  std_logic;
    S_AXI_AWREADY    : out std_logic;
    S_AXI_WDATA      : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB      : in  std_logic_vector(C_S_AXI_DATA_WIDTH/8-1 downto 0);
    S_AXI_WVALID     : in  std_logic;
    S_AXI_WLAST      : in  std_logic;
    S_AXI_WREADY     : out std_logic;
    
    S_AXI_BID        : out std_logic_vector 
                           (C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_BRESP      : out std_logic_vector(1 downto 0);
    S_AXI_BVALID     : out std_logic;
    S_AXI_BREADY     : in  std_logic;

    S_AXI_ARID       : in  std_logic_vector 
                           (C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_ARADDR     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID    : in  std_logic;
    S_AXI_ARPROT     : in  std_logic_vector(2 downto 0);
    S_AXI_ARCACHE    : in  std_logic_vector(3 downto 0);
    S_AXI_ARLEN      : in  std_logic_vector(7 downto 0);
    S_AXI_ARSIZE     : in  std_logic_vector(2 downto 0);
    S_AXI_ARBURST    : in  std_logic_vector(1 downto 0);
    S_AXI_ARLOCK     : in  std_logic;
    S_AXI_ARREADY    : out std_logic;

    S_AXI_RID        : out std_logic_vector 
                           (C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_RDATA      : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP      : out std_logic_vector(1 downto 0);
    S_AXI_RVALID     : out std_logic;
    S_AXI_RLAST      : out  std_logic;
    S_AXI_RREADY     : in  std_logic;

  -- Signals from other modules
    axi_prot         : out std_logic_vector(2 downto 0);
    axi_cache        : out std_logic_vector(3 downto 0);
    axi_size         : out std_logic_vector(2 downto 0);
    axi_lock         : out std_logic;
    axi_wdata        : out  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    ahb_rd_request   : out std_logic;
    ahb_wr_request   : out std_logic;
    slv_err_resp     : in  std_logic;
    rd_data          : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    axi_address      : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    axi_burst        : out std_logic_vector(1 downto 0);
    axi_length       : out std_logic_vector(7 downto 0);
    send_wvalid      : in  std_logic;
    send_ahb_wr      : out std_logic;
    axi_wvalid       : out std_logic;
    single_ahb_wr_xfer  : out std_logic;
    single_ahb_rd_xfer  : out std_logic;
    send_bresp          : in std_logic;
    send_rvalid         : in std_logic;
    send_rlast          : in std_logic;
    axi_rready          : out std_logic;
    timeout_i           : in std_logic;
    timeout_inprogress  : out std_logic
    );

end entity axi_slv_if;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of axi_slv_if is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
-- type declarations for the AXI write and read state machines
-------------------------------------------------------------------------------

    type  AXI_WR_SM_TYPE is (AXI_WR_IDLE,
                             AXI_WRITING,
                             AXI_WVALIDS_WAIT,
                             AXI_WVALID_WAIT,
                             AXI_WRITE_LAST,
                             AXI_WR_RESP_WAIT,
                             AXI_WR_RESP
                            );
                            
    type  AXI_RD_SM_TYPE is (AXI_RD_IDLE,
                             AXI_READ_LAST,
                             AXI_READING,
                             AXI_WAIT_RREADY,
                             RD_RESP
                            );
-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

    signal axi_write_ns     : AXI_WR_SM_TYPE;
    signal axi_write_cs     : AXI_WR_SM_TYPE;
    signal axi_read_ns      : AXI_RD_SM_TYPE;
    signal axi_read_cs      : AXI_RD_SM_TYPE;
    
    signal ARREADY_i        : std_logic;
    signal WREADY_i         : std_logic;
    signal AWREADY_i        : std_logic;
    signal BVALID_i         : std_logic;
    signal BRESP_1_i        : std_logic;
    signal RVALID_i         : std_logic;
    signal RLAST_i          : std_logic;
    signal RRESP_1_i        : std_logic;
    signal write_ready_sm   : std_logic;
    signal wr_addr_ready_sm : std_logic;
    signal rd_addr_ready_sm : std_logic;
    signal BVALID_sm        : std_logic;
    signal RVALID_sm        : std_logic;
    signal RLAST_sm         : std_logic;

    signal wr_request       : std_logic;
    signal rd_request       : std_logic;
    
    signal write_pending    : std_logic;
    signal write_waiting    : std_logic;
    signal write_complete   : std_logic;
    signal BID_i            : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    signal RID_i            : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    signal axi_rid          : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    signal axi_wid          : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);

    signal single_axi_wr_xfer   : std_logic;
    signal single_axi_rd_xfer   : std_logic;
    signal write_in_progress    : std_logic;
    signal read_in_progress     : std_logic;
    signal write_statrted       : std_logic;
    signal send_rd_data         : std_logic;
    signal wr_err_occured       : std_logic;
   
    signal axi_wlast            : std_logic; 
    signal timeout_inprogress_s : std_logic;
   
    signal byte_transfer        : std_logic;
    signal halfword_transfer    : std_logic;
    signal word_transfer        : std_logic;
    signal doubleword_transfer  : std_logic;
 
-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- I/O signal assignments
-------------------------------------------------------------------------------

    S_AXI_AWREADY         <= AWREADY_i;
    S_AXI_BID             <= BID_i;
    S_AXI_RID             <= RID_i;

    S_AXI_WREADY          <= WREADY_i;

    S_AXI_BRESP(0)        <= '0';
    S_AXI_BRESP(1)        <= BRESP_1_i;
    S_AXI_BVALID          <= BVALID_i;

    S_AXI_ARREADY         <= ARREADY_i;

    S_AXI_RRESP(0)        <= '0';
    S_AXI_RRESP(1)        <= RRESP_1_i;
    S_AXI_RVALID          <= RVALID_i;
    S_AXI_RLAST           <= RLAST_i;

   timeout_inprogress     <= timeout_inprogress_s;
-------------------------------------------------------------------------------
-- AHB read and write request assignments
-------------------------------------------------------------------------------
    
    axi_wvalid <= S_AXI_WVALID;
    axi_rready <= S_AXI_RREADY;
    
    single_ahb_wr_xfer <= single_axi_wr_xfer;
    single_ahb_rd_xfer <= single_axi_rd_xfer;
    
-- ****************************************************************************
-- byte/halfword/word transfer signal generation
-- When data width is 32 
-- ****************************************************************************

   GEN_32_NARROW: if (C_S_AXI_DATA_WIDTH = 32 ) generate

   begin

     byte_transfer <= '1' when S_AXI_WSTRB = "0001" or S_AXI_WSTRB = "0010" or
                               S_AXI_WSTRB = "0100" or S_AXI_WSTRB = "1000" 
                          else '0';

     halfword_transfer <= '1' when S_AXI_WSTRB = "0011" or S_AXI_WSTRB ="1100" 
                              else '0';

     word_transfer <= '1' when S_AXI_WSTRB = "1111" 
                          else '0';

     doubleword_transfer <= '0';

  end generate GEN_32_NARROW;


-- ******************************************************************************
-- Byte/halfword/word/doubleword transfer assignement
-- When Data width is 64
-- ******************************************************************************

  GEN_64_NARROW: if (C_S_AXI_DATA_WIDTH = 64 ) generate

  begin

    byte_transfer <= '1' when S_AXI_WSTRB = "00000001" or S_AXI_WSTRB = "00000010" or
                              S_AXI_WSTRB = "00000100" or S_AXI_WSTRB = "00001000" or
                              S_AXI_WSTRB = "00010000" or S_AXI_WSTRB = "00100000" or
                              S_AXI_WSTRB = "01000000" or S_AXI_WSTRB = "10000000" 
                         else '0';

    halfword_transfer <= '1' when S_AXI_WSTRB = "00000011" or S_AXI_WSTRB = "00001100" or
                                  S_AXI_WSTRB = "00110000" or S_AXI_WSTRB = "11000000" 
                             else '0';

    word_transfer   <= '1' when S_AXI_WSTRB = "00001111" or S_AXI_WSTRB = "11110000" 
                           else '0';

    doubleword_transfer <= '1' when S_AXI_WSTRB = "11111111" 
                               else '0';

  end generate GEN_64_NARROW;


-- **************************************************************************
-- Read ID assignment
-- **************************************************************************

   RID_REG : process(S_AXI_ACLK) is
   begin
      if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             RID_i <= (others => '0');
          else
             RID_i <= axi_rid;
          end if;
      end if;
   end process RID_REG;

-- ****************************************************************************
-- This process is used for generating the read response on AXI
-- ****************************************************************************

    RD_RESP_REG : process(S_AXI_ACLK) is
    begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             RRESP_1_i <= '0';
          else
             if (send_rd_data = '1') then
                 RRESP_1_i <= slv_err_resp or timeout_inprogress_s;
             elsif (S_AXI_RREADY = '1') then
                 RRESP_1_i <= '0';
             end if;
          end if;
      end if;
   end process RD_RESP_REG;

-- ****************************************************************************
-- This process is used for generating Read data
-- ****************************************************************************

    RD_DATA_REG : process(S_AXI_ACLK) is
    begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             S_AXI_RDATA <= (others => '0');
          else
             if (send_rd_data = '1') then
                 S_AXI_RDATA <= rd_data;
             elsif (S_AXI_RREADY = '1') then
                 S_AXI_RDATA <= (others => '0');
             end if;
          end if;
      end if;
   end process RD_DATA_REG;

-------------------------------------------------------------------------------
-- Write BID generation
-------------------------------------------------------------------------------

   BID_REG : process(S_AXI_ACLK) is
   begin
      if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             BID_i <= (others => '0');
          else
             BID_i <= axi_wid;
          end if;
      end if;
   end process BID_REG;

-- ****************************************************************************
-- This process is used for registering the AXI ARID when a read 
-- is requested. 
-- ****************************************************************************

       AXI_RID_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_rid <= (others => '0');
              else
                 if (rd_addr_ready_sm = '1') then
                       axi_rid <= S_AXI_ARID;
                 end if;
              end if;
          end if;
       end process AXI_RID_REG;

-- ****************************************************************************
-- This process is used for registering the AXI AWID when a write 
-- is requested. 
-- ****************************************************************************

       AXI_WID_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_wid <= (others => '0');
              else
                 if (wr_addr_ready_sm = '1') then
                       axi_wid <= S_AXI_AWID;
                 end if;
              end if;
          end if;
       end process AXI_WID_REG;

-------------------------------------------------------------------------------
-- Address generation for generating address on ahb
-------------------------------------------------------------------------------

   ADDR_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_address <= (others => '0');
              else
             if (wr_addr_ready_sm = '1') then
                   axi_address <= S_AXI_AWADDR;
             elsif (rd_addr_ready_sm = '1') then
                   axi_address <= S_AXI_ARADDR;
             end if;
              end if;
          end if;
   end process ADDR_REG;

-- ****************************************************************************
-- This process is used for registering the AXI protection when a write/read 
-- is requested. 
-- ****************************************************************************

       AXI_PROT_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_prot <= (others => '0');
              else
                 if (wr_addr_ready_sm = '1') then
                       axi_prot <= S_AXI_AWPROT;
                 elsif (rd_addr_ready_sm = '1') then
                       axi_prot <= S_AXI_ARPROT;
                 end if;
              end if;
          end if;
       end process AXI_PROT_REG;

-- ****************************************************************************
-- This process is used for registering the AXI cache when a write/read 
-- is requested. 
-- ****************************************************************************

       AXI_CACHE_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_cache <= (others => '0');
              else
                 if (wr_addr_ready_sm = '1') then
                       axi_cache <= S_AXI_AWCACHE;
                 elsif (rd_addr_ready_sm = '1') then
                       axi_cache <= S_AXI_ARCACHE;
                 end if;
              end if;
          end if;
       end process AXI_CACHE_REG;

-- ****************************************************************************
-- This process is used for registering the AXI lock when a write/read 
-- is requested. 
-- ****************************************************************************

       AXI_LOCK_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_lock <= '0';
              else
                 if (wr_addr_ready_sm = '1') then
                       axi_lock <= S_AXI_AWLOCK;
                 elsif (rd_addr_ready_sm = '1') then
                       axi_lock <= S_AXI_ARLOCK;
                 end if;
              end if;
          end if;
       end process AXI_LOCK_REG;

-- ****************************************************************************
-- This process is used for registering the AXI size when a write/read 
-- is requested. 
-- ****************************************************************************

       AXI_SIZE_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_size <= (others => '0');
              else
                 if (wr_addr_ready_sm = '1') then
                    if(or_reduce(S_AXI_AWLEN) = '0') then
                      if(byte_transfer = '1') then
                        axi_size <= "000";
                      elsif(halfword_transfer = '1') then
                        axi_size <= "001";
                      elsif(word_transfer = '1') then
                        axi_size <= "010";
                      elsif(doubleword_transfer = '1') then
                        axi_size <= "011";
                      else
                        axi_size <= S_AXI_AWSIZE;
                      end if;
                    else
                      axi_size <= S_AXI_AWSIZE;
                    end if;
                 elsif (rd_addr_ready_sm = '1') then
                       axi_size <= S_AXI_ARSIZE;
                 end if;
              end if;
          end if;
       end process AXI_SIZE_REG;

-- ****************************************************************************
-- This process is used for registering the AXI length when a write/read 
-- is requested. 
-- ****************************************************************************

       AXI_LENGTH_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_length <= (others => '0');
              else
                 if (wr_addr_ready_sm = '1') then
                       axi_length <= S_AXI_AWLEN;
                 elsif (rd_addr_ready_sm = '1') then
                       axi_length <= S_AXI_ARLEN;
                 end if;
              end if;
          end if;
       end process AXI_LENGTH_REG;

-- ****************************************************************************
-- This process is used for registering the AXI burst when a write/read 
-- is requested. 
-- ****************************************************************************

       AXI_BURST_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_burst <= (others => '0');
              else
                 if (wr_addr_ready_sm = '1') then
                       axi_burst <= S_AXI_AWBURST;
                 elsif (rd_addr_ready_sm = '1') then
                       axi_burst <= S_AXI_ARBURST;
                 end if;
              end if;
          end if;
       end process AXI_BURST_REG;

-- ****************************************************************************
-- This process is used for registering the AXI write data to be sent on AHB.
-- ****************************************************************************

       AXI_WR_DATA_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 axi_wdata <= (others => '0');
              else
                 if (write_ready_sm = '1') then
                       axi_wdata <= S_AXI_WDATA;
                 end if;
              end if;
          end if;
       end process AXI_WR_DATA_REG;
    

-- ****************************************************************************
-- This process is used for registering Write response
-- SLVERR response is sent to AXI when AHB save ERROR occured or when
-- timeout occurs
-- ****************************************************************************

   --WR_RESP_REG : process(S_AXI_ACLK) is
   --begin
   --    if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
   --       if (S_AXI_ARESETN = '0') then
   --          BRESP_1_i <= '0';
   --       else
   --          if (BVALID_sm = '1') then
   --              BRESP_1_i <= wr_err_occured or timeout_inprogress_s;
   --          elsif (S_AXI_BREADY = '1') then
   --              BRESP_1_i <= '0';
   --          end if;
   --       end if;
   --   end if;
   --end process WR_RESP_REG;
     BRESP_1_i <= wr_err_occured or timeout_inprogress_s;

-- ****************************************************************************
-- This process is used for generating control signal that write transfer is 
-- in progress
-- ****************************************************************************

   WR_PEND_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             write_in_progress <= '0';
          else
             if (write_statrted = '1') then
                 write_in_progress <= '1';
             elsif (write_complete = '1') then
                 write_in_progress <= '0';
             end if;
          end if;
      end if;
   end process WR_PEND_REG;

-- ****************************************************************************
-- This process is used for generating write error has occured on AHB
-- ****************************************************************************

   WR_ERR_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             wr_err_occured <= '0';
          else
             --if (send_wvalid = '1' and slv_err_resp = '1') then
             if (write_in_progress = '1' and slv_err_resp = '1') then
                 wr_err_occured <= '1';
             elsif (write_complete = '1') then
                 wr_err_occured <= '0';
             end if;
          end if;
      end if;
   end process WR_ERR_REG;

-- ****************************************************************************
-- This process is used for generating read transfer is in progress
-- ****************************************************************************

   RD_PROGRESS_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             read_in_progress <= '0';
          else
             if (rd_addr_ready_sm = '1') then
                 read_in_progress <= '1';
             elsif (RLAST_sm = '1') then
                 read_in_progress <= '0';
             end if;
          end if;
      end if;
   end process RD_PROGRESS_REG;

-- ****************************************************************************
-- This process is used for generating pending write
-- ****************************************************************************

   WR_PROGRESS_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             write_pending <= '0';
          else
             if (write_waiting = '1') then
                 write_pending  <= '1';
             elsif (BVALID_sm = '1') then
                 write_pending <= '0';
             end if;
          end if;
      end if;
   end process WR_PROGRESS_REG;

-- ****************************************************************************
-- This process is used for generating single write transfer on AXI (length 0)
-- ****************************************************************************

   WR_SINGLE_XFER_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
               single_axi_wr_xfer <= '0';
          else
              if (S_AXI_AWVALID = '1') then
                  if (or_reduce(S_AXI_AWLEN) = '0' and 
                      S_AXI_AWBURST(1) = '0') then
                      single_axi_wr_xfer <= '1';
                  else 
                      single_axi_wr_xfer <= '0';
                  end if;
              elsif(BVALID_sm = '1') then
                  single_axi_wr_xfer <= '0';             
             end if;
          end if;
      end if;
   end process WR_SINGLE_XFER_REG;

-- ****************************************************************************
-- This process is used for generating single read transfer on AXI (length 0)
-- ****************************************************************************

   RD_SINGLE_XFER_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             single_axi_rd_xfer <= '0';
          else
             if (S_AXI_ARVALID = '1') then
                if (or_reduce(S_AXI_ARLEN) = '0' and 
                    S_AXI_ARBURST(1) = '0') then
                   single_axi_rd_xfer <= '1';
                else 
                  single_axi_rd_xfer <= '0';
                end if;
             elsif (RLAST_sm = '1') then
                 single_axi_rd_xfer <= '0';
             end if;
          end if;
      end if;
   end process RD_SINGLE_XFER_REG;

-- ****************************************************************************
-- This process is used for registering S_AXI_WLAST
-- This registered S_AXI_WLAST is used in the AXI_WRITE_SM for generating
-- the write_ready_sm for single clock cycle
-- ****************************************************************************

   S_AXI_WLAST_REG: process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             axi_wlast <= '0';
          else
             axi_wlast <= S_AXI_WLAST;
          end if;
      end if;
   end process S_AXI_WLAST_REG;

-- ****************************************************************************
-- This process is used to generate timeout_inprogress
-- Once timeout occurs in any beat of the burst the signal timeout_inprogress_s
-- is '1' till the completion of that access/till AXI reset is asserted.
-- ****************************************************************************
   GEN_TIMEOUT_INPROGRESS : if (C_DPHASE_TIMEOUT /= 0) generate
   begin

     TIMEOUT_PROGRESS_REG:process(S_AXI_ACLK) is
     begin
       if(S_AXI_ACLK'event and S_AXI_ACLK = '1') then
         if(S_AXI_ARESETN = '0') then
            timeout_inprogress_s <= '0';
         else
           if(write_in_progress = '0' and read_in_progress = '0') then
              timeout_inprogress_s <= '0';
           elsif(timeout_i = '1' and (write_in_progress = '1' or 
              read_in_progress = '1')) then
              timeout_inprogress_s <= '1';  
           end if;
         end if;
       end if;
     end process TIMEOUT_PROGRESS_REG;

    END generate GEN_TIMEOUT_INPROGRESS;

-- ****************************************************************************
-- Generate statement works when C_DPHASE_TIMEOUT is always '0'
-- timeout_inprogress_s is always '0' if C_DPHASE_TIMEOUT parameter is '0'
-- ****************************************************************************
   GEN_TIMEOUT_NOTINPROGRESS : if (C_DPHASE_TIMEOUT = 0) generate
   begin

     timeout_inprogress_s <= '0';

   END generate GEN_TIMEOUT_NOTINPROGRESS; 

-- ****************************************************************************
-- AXI Write State Machine -- START
-- this state machine generates the control signals to send the write data
-- and write control signals to AHB.This also generates the control signal
-- to send the write response to AXI after last beat of the transfer.
-- ****************************************************************************

   AXI_WRITE_SM   : process (axi_write_cs,
                             S_AXI_AWVALID,
                             S_AXI_ARVALID,
                             S_AXI_WVALID,
                             S_AXI_WLAST,
                             axi_wlast,
                             S_AXI_BREADY,
                             send_bresp,
                             send_wvalid,
                             single_axi_wr_xfer,
                             write_pending,
                             read_in_progress
                             ) is
   begin

      axi_write_ns     <= axi_write_cs;
      write_ready_sm   <= '0';
      wr_addr_ready_sm <= '0';
      wr_request       <= '0';
      BVALID_sm        <= '0';
      write_complete   <= '0';
      send_ahb_wr      <= '0';
      write_statrted   <= '0'; 
      

      case axi_write_cs is

           when AXI_WR_IDLE =>
              if((S_AXI_AWVALID = '1' or S_AXI_WVALID = '1') and
                   ((write_pending = '0' and S_AXI_ARVALID = '0') or
                    (write_pending = '1')) and read_in_progress = '0') then
                     write_statrted <= '1';     
                     axi_write_ns   <= AXI_WVALIDS_WAIT;
                end if;
           when AXI_WVALIDS_WAIT =>
             if(S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
                   write_ready_sm   <= '1';
                   wr_addr_ready_sm <= '1';
                   wr_request       <= '1';
                   if (single_axi_wr_xfer = '1') then
                       axi_write_ns <= AXI_WRITE_LAST;
                   else
                       axi_write_ns <= AXI_WRITING;
                   end if;
                end if;
           when AXI_WVALID_WAIT =>
                write_ready_sm <= S_AXI_WVALID;
                send_ahb_wr    <= S_AXI_WVALID;
                if(S_AXI_WVALID = '1') then
                  axi_write_ns <= AXI_WRITING;
                end if;

           when AXI_WRITING =>
                if(S_AXI_WVALID = '1' and S_AXI_WLAST = '1') then
                   write_ready_sm <= send_wvalid;
                   send_ahb_wr    <= send_wvalid;
                   if(send_bresp = '1') then
                      axi_write_ns <= AXI_WR_RESP_WAIT;
                   else
                      axi_write_ns <= AXI_WRITE_LAST;
                   end if;
                elsif(send_wvalid = '1') then
                   write_ready_sm <= S_AXI_WVALID;
                   send_ahb_wr    <= S_AXI_WVALID;
                   if(S_AXI_WVALID = '0') then
                      axi_write_ns <= AXI_WVALID_WAIT;
                   end if;
                end if;
           
           when AXI_WR_RESP_WAIT =>
                BVALID_sm    <= '1';
                axi_write_ns <= AXI_WR_RESP;

           when AXI_WRITE_LAST =>
                send_ahb_wr    <= '1';
                write_ready_sm <= send_wvalid; 
                BVALID_sm      <= send_bresp;
                if(send_bresp = '1') then
                   axi_write_ns <= AXI_WR_RESP;
                   write_ready_sm <= '0'; 
                end if;

           when AXI_WR_RESP =>
                write_complete <= S_AXI_BREADY;
                BVALID_sm      <= not S_AXI_BREADY;
                if (S_AXI_BREADY = '1') then
                    axi_write_ns <= AXI_WR_IDLE;
                end if;

          -- coverage off
           when others =>
                axi_write_ns <= AXI_WR_IDLE;
          -- coverage on

       end case;

   end process AXI_WRITE_SM;

-------------------------------------------------------------------------------
-- Registering the signals generated from the AXI_WRITE_SM state machine
-------------------------------------------------------------------------------

   AXI_WRITE_SM_REG : process(S_AXI_ACLK) is
   begin
      if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
         if (S_AXI_ARESETN = '0') then
             axi_write_cs <= AXI_WR_IDLE;
             WREADY_i     <= '0';
             AWREADY_i    <= '0';
             BVALID_i     <= '0';
         else
             axi_write_cs <= axi_write_ns;
             WREADY_i     <= write_ready_sm;
             AWREADY_i    <= wr_addr_ready_sm;
             BVALID_i     <= BVALID_sm;
         end if;
      end if;
   end process AXI_WRITE_SM_REG;
   
-- ****************************************************************************
-- AXI Read State Machine -- START
-- This state machine generates the control signals to send the read data and
-- read response to AXI from AHB.
-- ****************************************************************************

   AXI_READ_SM   : process (axi_read_cs,
                            write_pending,
                            S_AXI_ARVALID,
                            S_AXI_RREADY,
                            S_AXI_AWVALID,
                            S_AXI_WVALID,
                            send_rlast,
                            send_rvalid,
                            single_axi_rd_xfer,
                            write_in_progress
                           ) is
   begin

      axi_read_ns      <= axi_read_cs;
      rd_request       <= '0';
      RVALID_sm        <= '0';
      RLAST_sm         <= '0';
      rd_addr_ready_sm <= '0';
      write_waiting    <= '0';
      send_rd_data     <= '0';

      case axi_read_cs is

           when AXI_RD_IDLE =>
                if (S_AXI_ARVALID = '1' and
                    write_pending = '0' and write_in_progress = '0') then
                    rd_request <= '1';
                    rd_addr_ready_sm <= '1';
                    if (single_axi_rd_xfer = '1') then
                       axi_read_ns <= AXI_READ_LAST;
                    else
                       axi_read_ns <= AXI_READING;
                    end if;
                end if;

           when AXI_READING =>
                send_rd_data <= send_rlast or send_rvalid;
                RVALID_sm    <= send_rlast or send_rvalid;
                if (send_rlast  = '1') then
                    RLAST_sm    <= '1';
                    axi_read_ns <= RD_RESP;                
                elsif(send_rvalid = '1') then
                    if(S_AXI_RREADY = '0') then   
                       axi_read_ns <= AXI_WAIT_RREADY;
                    end if;
                end if;

           when AXI_WAIT_RREADY =>
                if(S_AXI_RREADY = '1' ) then
                   axi_read_ns <= AXI_READING;
                else
                   RVALID_sm <= '1';
                end if;

           when RD_RESP =>                
                if(S_AXI_RREADY = '1') then
                   if(S_AXI_AWVALID = '1' or S_AXI_WVALID = '1') then
                      write_waiting <= '1';
                   end if;
                   axi_read_ns <= AXI_RD_IDLE;
                else
                   RVALID_sm <= '1';
                   RLAST_sm  <= '1';
                end if;

           when AXI_READ_LAST =>
                if(send_rlast = '1') then
                   send_rd_data <= '1';
                   RLAST_sm <= '1';
                   RVALID_sm <= '1';
                   axi_read_ns <= RD_RESP;
                end if;
          
          -- coverage off
           when others =>
                axi_read_ns <= AXI_RD_IDLE;
          -- coverage on

       end case;

   end process AXI_READ_SM;

-------------------------------------------------------------------------------
-- Registering the signals generated from the AXI_READ_SM state machine
-------------------------------------------------------------------------------

   AXI_READ_SM_REG : process(S_AXI_ACLK) is
   begin
      if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
         if (S_AXI_ARESETN = '0') then
             axi_read_cs <= AXI_RD_IDLE;
             ARREADY_i <= '0';
             RVALID_i <= '0';
             RLAST_i <= '0';
             ahb_rd_request <= '0';
             ahb_wr_request <= '0';
         else
             ahb_rd_request <= rd_request;
             ahb_wr_request <= wr_request;
             axi_read_cs <= axi_read_ns;
             ARREADY_i <= rd_addr_ready_sm;
             RVALID_i <= RVALID_sm;
             RLAST_i <= RLAST_sm;
         end if;
      end if;
   end process AXI_READ_SM_REG;
   
end architecture RTL;


-------------------------------------------------------------------------------
-- ahb_mstr_if.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
--
--  *******************************************************************
--  ** (c) Copyright [2007] - [2012] Xilinx, Inc. All rights reserved.*
--  **                                                                *
--  ** This file contains confidential and proprietary information    *
--  ** of Xilinx, Inc. and is protected under U.S. and                *
--  ** international copyright and other intellectual property        *
--  ** laws.                                                          *
--  **                                                                *
--  ** DISCLAIMER                                                     *
--  ** This disclaimer is not a license and does not grant any        *
--  ** rights to the materials distributed herewith. Except as        *
--  ** otherwise provided in a valid license issued to you by         *
--  ** Xilinx, and to the maximum extent permitted by applicable      *
--  ** law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND        *
--  ** WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES    *
--  ** AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING      *
--  ** BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-         *
--  ** INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and       *
--  ** (2) Xilinx shall not be liable (whether in contract or tort,   *
--  ** including negligence, or under any other theory of             *
--  ** liability) for any loss or damage of any kind or nature        *
--  ** related to, arising under or in connection with these          *
--  ** materials, including for any direct, or any indirect,          *
--  ** special, incidental, or consequential loss or damage           *
--  ** (including loss of data, profits, goodwill, or any type of     *
--  ** loss or damage suffered as a result of any action brought      *
--  ** by a third party) even if such damage or loss was              *
--  ** reasonably foreseeable or Xilinx had been advised of the       *
--  ** possibility of the same.                                       *
--  **                                                                *
--  ** CRITICAL APPLICATIONS                                          *
--  ** Xilinx products are not designed or intended to be fail-       *
--  ** safe, or for use in any application requiring fail-safe        *
--  ** performance, such as life-support or safety devices or         *
--  ** systems, Class III medical devices, nuclear facilities,        *
--  ** applications related to the deployment of airbags, or any      *
--  ** other applications that could lead to death, personal          *
--  ** injury, or severe property or environmental damage             *
--  ** (individually and collectively, "Critical                      *
--  ** Applications"). Customer assumes the sole risk and             *
--  ** liability of any use of Xilinx products in Critical            *
--  ** Applications, subject only to applicable laws and              *
--  ** regulations governing limitations on product liability.        *
--  **                                                                *
--  ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS       *
--  ** PART OF THIS FILE AT ALL TIMES.                                *
--  *******************************************************************
--
-------------------------------------------------------------------------------
-- Filename     :   ahb_mstr_if.vhd
-- Version      :   v1.01a
-- Description  :   The AHB Master Interface module provides a bi-directional
--                  AHB master interface on the AHB Lite. 
--                  The AHB data bus width can be 32/64-bits.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Structure:
--           -- axi_ahblite_bridge.vhd
--              -- axi_slv_if.vhd
--              -- ahb_mstr_if.vhd
--              -- time_out.vhd
-------------------------------------------------------------------------------
-- Author:     NLR 
-- History:
--   NLR      12/15/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
--   NLR      04/10/2012    Added the strobe support for single data transfers
-- ^^^^^^^
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*N"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      counter signals:                        "*cntr*", "*count*"
--      ports:                                  - Names in Uppercase
--      processes:                              "*_REG", "*_CMB"
--      component instantiations:               "<ENTITY_>MODULE<#|_FUNC>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ahb_mstr_if is    
  generic (
    C_M_AHB_ADDR_WIDTH   : integer range 32 to 64   := 32;
    C_M_AHB_DATA_WIDTH   : integer := 32;
    C_S_AXI_DATA_WIDTH   : integer := 32;
    C_S_AXI_SUPPORTS_NARROW_BURST : integer range 0 to 1 := 0 
    );
  port (

  -- AHB Signals
    AHB_HCLK           : in std_logic;    
    AHB_HRESETN        : in std_logic;

    M_AHB_HADDR        : out std_logic_vector(C_M_AHB_ADDR_WIDTH-1 downto 0);
    M_AHB_HWRITE       : out std_logic;
    M_AHB_HSIZE        : out std_logic_vector(2 downto 0);
    M_AHB_HBURST       : out std_logic_vector(2 downto 0);
    M_AHB_HPROT        : out std_logic_vector(3 downto 0);
    M_AHB_HTRANS       : out std_logic_vector(1 downto 0);
    M_AHB_HMASTLOCK    : out std_logic;
    M_AHB_HWDATA       : out std_logic_vector(C_M_AHB_DATA_WIDTH-1 downto 0);
    
    M_AHB_HREADY       : in  std_logic;
    M_AHB_HRDATA       : in  std_logic_vector(C_M_AHB_DATA_WIDTH-1 downto 0);
    M_AHB_HRESP        : in  std_logic;

  -- Signals from/to other modules
    ahb_rd_request     : in  std_logic;
    ahb_wr_request     : in  std_logic;
    axi_lock           : in  std_logic;
    rd_data            : out std_logic_vector(C_M_AHB_DATA_WIDTH-1 downto 0);
    slv_err_resp       : out std_logic;
    axi_prot           : in  std_logic_vector(2 downto 0);
    axi_cache          : in  std_logic_vector(3 downto 0);
    axi_wdata          : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    axi_size           : in  std_logic_vector(2 downto 0);
    axi_length         : in  std_logic_vector(7 downto 0);
    axi_address        : in  std_logic_vector(C_M_AHB_ADDR_WIDTH-1 downto 0);
    axi_burst          : in  std_logic_vector(1 downto 0);
    single_ahb_wr_xfer : in  std_logic;
    single_ahb_rd_xfer : in  std_logic;
    send_wvalid        : out std_logic;
    send_ahb_wr        : in  std_logic;
    axi_wvalid         : in  std_logic;
    send_bresp         : out std_logic;
    send_rvalid        : out std_logic;
    send_rlast         : out std_logic;
    axi_rready         : in  std_logic;
    timeout_inprogress : in std_logic;
    load_cntr          : out std_logic;
    cntr_enable        : out std_logic
    );

end entity ahb_mstr_if;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of ahb_mstr_if is
-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
-- State Machine TYPE Declarations
-------------------------------------------------------------------------------

    type  AHB_SM_TYPE is (AHB_IDLE,
                          AHB_RD_ADDR,
                          AHB_RD_SINGLE,
                          AHB_RD_DATA_INCR,
                          AHB_RD_LAST,
                          AHB_RD_WAIT,
                          AHB_WR_ADDR,
                          AHB_WR_SINGLE,
                          AHB_WR_WAIT,
                          AHB_WR_INCR,
                          AHB_INCR_ADDR,
                          AHB_LAST_ADDR,
                          AHB_ONEKB_LAST,
                          AHB_LAST_WAIT,
                          AHB_LAST
                         );

-------------------------------------------------------------------------------
-- constant declarations
-------------------------------------------------------------------------------

    constant IDLE   : std_logic_vector := "00";
    constant BUSY   : std_logic_vector := "01";
    constant NONSEQ : std_logic_vector := "10";
    constant SEQ    : std_logic_vector := "11";

-------------------------------------------------------------------------------
-- Signal declarations
-------------------------------------------------------------------------------

    signal ahb_wr_rd_ns   : AHB_SM_TYPE;
    signal ahb_wr_rd_cs   : AHB_SM_TYPE;

    signal HWRITE_i       : std_logic;
    signal HWDATA_i       : std_logic_vector(C_M_AHB_DATA_WIDTH-1 downto 0);
    signal HADDR_i        : std_logic_vector(C_M_AHB_ADDR_WIDTH-1 downto 0);
    signal HPROT_i        : std_logic_vector(3 downto 0);
    signal HBURST_i       : std_logic_vector(2 downto 0);
    signal HSIZE_i        : std_logic_vector(2 downto 0);
    signal HLOCK_i        : std_logic;

    signal ahb_hslverr    : std_logic;
    signal ahb_hready     : std_logic;
    signal ahb_hrdata     : std_logic_vector(C_M_AHB_DATA_WIDTH-1 downto 0);
    signal ahb_write_sm   : std_logic;
    signal wrap_brst_count: std_logic_vector(7 downto 0);
    signal burst_ready    : std_logic;
    signal wrap_brst_last : std_logic;
    signal ahb_burst      : std_logic_vector(2 downto 0);
    signal send_wr_data   : std_logic;
    signal incr_addr      : std_logic;
    signal load_counter   : std_logic;
    signal load_counter_sm: std_logic;
    signal wrap_brst_one  : std_logic;
    signal send_trans_seq : std_logic;
    signal send_trans_nonseq : std_logic;
    signal send_trans_idle   : std_logic;
    signal send_trans_busy   : std_logic;
    signal send_wrap_burst   : std_logic;
    
    signal wrap_in_progress  : std_logic;
    signal send_rlast_sm     : std_logic;
    signal send_bresp_sm     : std_logic;
    signal one_kb_cross      : std_logic;

    signal addr_all_ones      : std_logic;
    signal one_kb_in_progress : std_logic;
    signal one_kb_splitted    : std_logic;
    signal wrap_2_in_progress : std_logic;
    signal axi_len_les_eq_sixteen : std_logic;
    signal axi_end_address    : std_logic_vector(11 downto 0);    
    signal axi_length_burst   : std_logic_vector(11 downto 0); 
    signal onekb_cross_access : std_logic;    
    signal fixed_burst_access : std_logic;
    signal incr_burst_access  : std_logic;
    signal wrap_burst_access  : std_logic;
    signal wrap_four          : std_logic;
    signal wrap_eight         : std_logic;
    signal wrap_sixteen       : std_logic;
    signal onekb_brst_add     : std_logic;
    signal single_ahb_wr      : std_logic;
begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- AHB I/O signal assignments
-------------------------------------------------------------------------------

    M_AHB_HADDR           <= HADDR_i;
    M_AHB_HWRITE          <= HWRITE_i;
    M_AHB_HWDATA          <= HWDATA_i;
    M_AHB_HPROT           <= HPROT_i;
    M_AHB_HMASTLOCK       <= HLOCK_i;
    M_AHB_HSIZE           <= HSIZE_i;
    M_AHB_HBURST          <= HBURST_i;
    
-------------------------------------------------------------------------------
-- Internal signal assignments
-------------------------------------------------------------------------------

    ahb_hslverr        <= M_AHB_HRESP;
    ahb_hready         <= M_AHB_HREADY;
    ahb_hrdata         <= M_AHB_HRDATA;
    send_rlast         <= send_rlast_sm;
    send_bresp         <= send_bresp_sm;

--*****************************************************************************
-- Combinational logic to generate a fixed burst access signal when AXI 
-- initiated the Fixed burst
--*****************************************************************************

   fixed_burst_access <= '1' when axi_burst = "00" else '0';

--*****************************************************************************
-- Combinational logic to generate a incr burst access signal when AXI
-- initiated the incr burst
--*****************************************************************************

   incr_burst_access <= '1' when axi_burst = "01" else '0';

--*****************************************************************************
-- Combinational logic to generate a wrap burst access signal when AXI
-- initiated the wrap burst
--*****************************************************************************

   wrap_burst_access <= '1' when axi_burst = "10" else '0';

--*****************************************************************************
-- Combinational logic to generate wrap_four, wrap_eight,wrap_sixteen signals
-- These signals are used in the address generation logic
--*****************************************************************************

   wrap_four <= '1' when axi_length(3 downto 0) ="0011" and 
                         wrap_in_progress = '1' else '0';

   wrap_eight <= '1' when axi_length(3 downto 0) ="0111" and
                         wrap_in_progress = '1' else '0';
   
   wrap_sixteen <= '1' when axi_length(3 downto 0) ="1111" and
                         wrap_in_progress = '1' else '0';

-- ****************************************************************************
-- This process is used for driving the AHB write data when the control signal
-- is sent from AHB state machine
-- ****************************************************************************

       AHB_WDATA_REG : process(AHB_HCLK) is
       begin
          if (AHB_HCLK'event and AHB_HCLK = '1') then
              if (AHB_HRESETN = '0') then
                  HWDATA_i <= (others => '0');
              else
                  if (send_wr_data = '1') then
                     HWDATA_i <= axi_wdata;                       
                  end if;
             end if;
          end if;
       end process AHB_WDATA_REG;

-- ****************************************************************************
-- This process is used for driving the AHB TRANS signal. Depending on the
-- control signals from AHB state machine, the type of transfer is sent.
-- If timeout occurs and AXI timeout transfer is in progress then
-- sending the IDLE on M_AHB_HTRANS.
-- ****************************************************************************

       AHB_TRANS_REG : process(AHB_HCLK) is
       begin
         if (AHB_HCLK'event and AHB_HCLK = '1') then
            if (AHB_HRESETN = '0') then
               M_AHB_HTRANS <= (others => '0');
            else
               if (send_trans_nonseq = '1' and timeout_inprogress = '0') then
                  M_AHB_HTRANS <= NONSEQ;                       
               elsif (send_trans_seq = '1' and timeout_inprogress = '0') then
                  M_AHB_HTRANS <= SEQ;                       
               elsif (send_trans_idle = '1' and timeout_inprogress = '0') then
                  M_AHB_HTRANS <= IDLE;                       
               elsif (send_trans_busy = '1' and timeout_inprogress = '0') then
                  M_AHB_HTRANS <= BUSY;       
               elsif(timeout_inprogress = '1') then
                  M_AHB_HTRANS <= IDLE;                
               end if;
            end if;
         end if;
       end process AHB_TRANS_REG;

-- ****************************************************************************
-- This process is used for driving the AHB WRITE control signal.
-- ****************************************************************************

       AHB_WRITE_REG : process(AHB_HCLK) is
       begin
          if (AHB_HCLK'event and AHB_HCLK = '1') then
              if (AHB_HRESETN = '0') then
                 HWRITE_i <= '0';
              else
                 if (ahb_rd_request = '1') then 
                       HWRITE_i <= '0';                       
                 elsif (ahb_wr_request = '1') then 
                       HWRITE_i <= '1';                       
                 end if;
              end if;
          end if;
       end process AHB_WRITE_REG;

-- ****************************************************************************
-- This process is used for generating the control signal that says WRAP 
-- transfer is in progress. This is used in AHB state machine for driving
-- the kind of AHB transfer type.
-- ****************************************************************************

       AHB_WRAP_REG : process(AHB_HCLK) is
       begin
          if (AHB_HCLK'event and AHB_HCLK = '1') then
              if (AHB_HRESETN = '0') then
                 wrap_in_progress <= '0';
              else
                 if (send_wrap_burst = '1') then 
                       wrap_in_progress <= '1';                       
                 elsif (send_rlast_sm = '1' or send_bresp_sm = '1') then 
                       wrap_in_progress <= '0';                       
                 end if;
              end if;
          end if;
       end process AHB_WRAP_REG;

-- ****************************************************************************
-- This combo is used for generating the control signal that says WRAP 2
-- transfer is in progress. This is used in AHB state machine for converting
-- WRAP 2 on AXI to 2 single transfers on AHB since WRAP2 is not available 
-- on AHB
-- ****************************************************************************
     
     wrap_2_in_progress <= '1' when (wrap_in_progress = '1') and 
                               (axi_length(3 downto 0) = "0001")
                               else
                           '0';
-- ****************************************************************************
-- This process is used for driving the AHB address signal for 32-bit AHB data
-- and when Narrow burst enabled. Either 8/16/32 data bits can be tranferred in
-- each beat when C_M_AHB_DATA_WIDTH=32 and C_S_AXI_SUPPORTS_NARROW_BURST=1
-- ****************************************************************************

    GEN_32_DATA_WIDTH_NARROW: if (C_M_AHB_DATA_WIDTH = 32  and  
                              C_S_AXI_SUPPORTS_NARROW_BURST = 1) generate

    begin
    
-- ****************************************************************************
-- This process is used for driving the AHB address signal AHB_HADDR 
-- address will be incremented or wrapped depending on the control signal from
-- the AHB state machine.
-- ****************************************************************************

       AHB_ADDRESS_REG : process(AHB_HCLK) is
       begin
          if (AHB_HCLK'event and AHB_HCLK = '1') then
              if (AHB_HRESETN = '0') then
                 HADDR_i <= (others => '0');
              else
                 if (ahb_wr_request = '1' or ahb_rd_request = '1') then
                     if(axi_size = "010") then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2) <= axi_address(C_M_AHB_ADDR_WIDTH-1 downto 2);
                        HADDR_i(1 downto 0)  <= "00";
                     elsif(axi_size = "001" ) then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 1) <= axi_address(C_M_AHB_ADDR_WIDTH-1 downto 1);
                        HADDR_i(0)           <= '0'; 
                     else
                        HADDR_i              <= axi_address;
                     end if;
                 elsif (incr_addr = '1' and fixed_burst_access = '0' ) then
                     case axi_size is
                     when "000" => -- 8-bit access
                       if(wrap_2_in_progress = '1') then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 1) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 1);
                         HADDR_i(0) <= not (HADDR_i(0)); 
                       elsif(wrap_four = '1') then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2);
                         HADDR_i(1 downto 0) <= HADDR_i(1 downto 0) + "01";
                       elsif(wrap_eight = '1') then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3);
                         HADDR_i(2 downto 0) <= HADDR_i(2 downto 0) + "001";
                       elsif(wrap_sixteen = '1') then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4);
                         HADDR_i(3 downto 0) <= HADDR_i(3 downto 0) + "0001";
                       else
                         HADDR_i <= HADDR_i + "0001";
                       end if;
                     when "001" => -- 16-bit access
                       if(wrap_2_in_progress = '1') then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2);
                         HADDR_i(1 downto 0) <= HADDR_i(1 downto 0) + "10";
                       elsif(wrap_four = '1') then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3);
                         HADDR_i(2 downto 0) <= HADDR_i(2 downto 0) + "010";
                       elsif(wrap_eight = '1') then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4);
                         HADDR_i(3 downto 0) <= HADDR_i(3 downto 0) + "0010";
                       elsif(wrap_sixteen = '1') then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5);
                         HADDR_i(4 downto 0) <= HADDR_i(4 downto 0) + "00010";
                       else
                         HADDR_i <= HADDR_i + "0010";
                       end if;
                     when "010" => -- 32-bit access
                       if(wrap_2_in_progress = '1') then
                          HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3);
                          HADDR_i(2 downto 0)<=HADDR_i(2 downto 0) + "100";
                       elsif(wrap_four = '1') then
                          HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4);
                          HADDR_i(3 downto 0)<=HADDR_i(3 downto 0) + "0100";
                       elsif(wrap_eight = '1') then
                          HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5);
                          HADDR_i(4 downto 0)<=HADDR_i(4 downto 0) + "00100";
                       elsif(wrap_sixteen = '1') then
                          HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6);
                          HADDR_i(5 downto 0)<=HADDR_i(5 downto 0) + "000100";
                       else
                          HADDR_i <= HADDR_i + "0100";
                       end if;
                     -- coverage off
                     when others => 
                       HADDR_i <= HADDR_i;
                     -- coverage on
                     end case;
                 else
                       HADDR_i <= HADDR_i;
                 end if;
              end if;
          end if;
       end process AHB_ADDRESS_REG;

    end generate GEN_32_DATA_WIDTH_NARROW;
    
-- ****************************************************************************
-- This process is used for driving the AHB address signal for 64-bit AHB data
-- and when Narrow burst enabled.Either 8/16/32/64data bits can be tranferred in
-- each beat when C_M_AHB_DATA_WIDTH=64 and C_S_AXI_SUPPORTS_NARROW_BURST=1
-- ****************************************************************************

    GEN_64_DATA_WIDTH_NARROW : if (C_M_AHB_DATA_WIDTH = 64 and  
                              C_S_AXI_SUPPORTS_NARROW_BURST = 1) generate

    begin
    
-- ****************************************************************************
-- This process is used for driving the AHB address signal AHB_HADDR. The
-- address will be incremented or wrapped depending on the control signal from
-- the AHB state machine.
-- ****************************************************************************

       AHB_ADDRESS_REG : process(AHB_HCLK) is
       begin
          if (AHB_HCLK'event and AHB_HCLK = '1') then
              if (AHB_HRESETN = '0') then
                 HADDR_i <= (others => '0');
              else
                 if (ahb_wr_request = '1' or ahb_rd_request = '1') then
                       if(axi_size = "011") then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3) <= axi_address(C_M_AHB_ADDR_WIDTH-1 downto 3);
                         HADDR_i(2 downto 0)  <= "000";
                       elsif(axi_size = "010") then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2) <= axi_address(C_M_AHB_ADDR_WIDTH-1 downto 2);
                         HADDR_i(1 downto 0)  <= "00";
                       elsif(axi_size = "001") then
                         HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 1) <= axi_address(C_M_AHB_ADDR_WIDTH-1 downto 1);
                         HADDR_i(0)           <= '0';
                       else
                         HADDR_i              <= axi_address;
                       end if;
                 elsif (incr_addr = '1' and fixed_burst_access = '0') then
                   case axi_size is
                     when "000" =>   -- 8-bit access
                        if(wrap_2_in_progress = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 1) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 1);
                           HADDR_i(0) <= not (HADDR_i(0)) ;
                        elsif( wrap_four = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2);
                           HADDR_i(1 downto 0) <= HADDR_i(1 downto 0) + "01";
                        elsif(wrap_eight = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3);
                           HADDR_i(2 downto 0) <= HADDR_i(2 downto 0) + "001";
                        elsif(wrap_sixteen = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4);
                           HADDR_i(3 downto 0) <= HADDR_i(3 downto 0) + "0001";
                        else
                           HADDR_i <= HADDR_i + "0001";
                        end if;
                     when "001" =>  --16 -bit access
                         if(wrap_2_in_progress = '1') then
                            HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2);
                            HADDR_i(1 downto 0) <= HADDR_i(1 downto 0) + "10";
                         elsif(wrap_four = '1') then
                            HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3);
                            HADDR_i(2 downto 0) <= HADDR_i(2 downto 0) + "010";
                         elsif(wrap_eight = '1') then
                            HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4);
                            HADDR_i(3 downto 0) <= HADDR_i(3 downto 0) + "0010";
                         elsif(wrap_sixteen = '1') then
                            HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5);
                            HADDR_i(4 downto 0)<=HADDR_i(4 downto 0) + "00010";
                         else
                            HADDR_i <= HADDR_i + "0010";
                         end if;
                      when "010" => -- 32-bit access
                         if(wrap_2_in_progress = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3);
                           HADDR_i(2 downto 0)<=HADDR_i(2 downto 0) + "100";
                         elsif(wrap_four = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4);
                           HADDR_i(3 downto 0)<=HADDR_i(3 downto 0) + "0100";
                         elsif(wrap_eight = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5);
                           HADDR_i(4 downto 0)<=HADDR_i(4 downto 0) + "00100";
                         elsif(wrap_sixteen = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6);
                           HADDR_i(5 downto 0)<=HADDR_i(5 downto 0) + "000100";
                         else
                            HADDR_i <= HADDR_i + "0100";
                         end if;
                      when "011" => -- 64-bit access
                         if(wrap_2_in_progress = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4);
                           HADDR_i(3 downto 0)  <= HADDR_i(3 downto 0) + "1000";
                         elsif(wrap_four = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5);
                           HADDR_i(4 downto 0)  <= HADDR_i(4 downto 0) + "01000";
                         elsif(wrap_eight = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6);
                           HADDR_i(5 downto 0)  <= HADDR_i(5 downto 0) + "001000";
                         elsif(wrap_sixteen = '1') then
                           HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 7) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 7);
                           HADDR_i(6 downto 0)  <= HADDR_i(6 downto 0) + "0001000";
                         else
                            HADDR_i <= HADDR_i + "1000";
                       end if;

                       -- coverage off
                      when others => 
                          HADDR_i <= HADDR_i;
                       -- coverage on
                     end case;
                 else
                       HADDR_i <= HADDR_i;
                 end if;
              end if;
          end if;
       end process AHB_ADDRESS_REG;

    end generate GEN_64_DATA_WIDTH_NARROW;


-- ****************************************************************************
-- This process is used for driving the AHB address signal for 32-bit AHB data
-- width with out narrow burst transfers
-- ****************************************************************************

    GEN_32_DATA_WIDTH : if (C_M_AHB_DATA_WIDTH = 32 and  
                              C_S_AXI_SUPPORTS_NARROW_BURST = 0) generate

    begin
    
-- ****************************************************************************
-- This process is used for driving the AHB address signal AHB_HADDR. The
-- address will be incremented or wrapped depending on the control signal from
-- the AHB state machine.
-- ****************************************************************************

       AHB_ADDRESS_REG : process(AHB_HCLK) is
       begin
          if (AHB_HCLK'event and AHB_HCLK = '1') then
              if (AHB_HRESETN = '0') then
                 HADDR_i <= (others => '0');
              else
                 if (ahb_wr_request = '1' or ahb_rd_request = '1') then
                       HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 2) <= axi_address(C_M_AHB_ADDR_WIDTH-1 downto 2);
                       HADDR_i(1 downto 0) <= "00";
                 elsif (incr_addr = '1' and fixed_burst_access = '0' ) then
                     if (wrap_2_in_progress = '1') then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3);
                        HADDR_i(2 downto 0) <= HADDR_i(2 downto 0) + "100";
                     elsif( wrap_four = '1') then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4);
                        HADDR_i(3 downto 0) <= HADDR_i(3 downto 0) + "0100";
                     elsif(wrap_eight = '1') then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5);
                        HADDR_i(4 downto 0) <= HADDR_i(4 downto 0) + "00100";
                     elsif(wrap_sixteen = '1') then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6);
                        HADDR_i(5 downto 0) <= HADDR_i(5 downto 0) + "000100";
                     else
                        HADDR_i <= HADDR_i + "0100";
                     end if;
                 else
                       HADDR_i <= HADDR_i;
                 end if;
              end if;
          end if;
       end process AHB_ADDRESS_REG;

    end generate GEN_32_DATA_WIDTH;
    
-- ****************************************************************************
-- This process is used for driving the AHB address signal for 64-bit AHB data
-- width with out narrow burst transfers
-- ****************************************************************************

    GEN_64_DATA_WIDTH : if (C_M_AHB_DATA_WIDTH = 64 and  
                              C_S_AXI_SUPPORTS_NARROW_BURST = 0) generate

    begin
    
-- ****************************************************************************
-- This process is used for driving the AHB address signal AHB_HADDR. The
-- address will be incremented or wrapped depending on the control signal from
-- the AHB state machine.
-- ****************************************************************************

       AHB_ADDRESS_REG : process(AHB_HCLK) is
       begin
          if (AHB_HCLK'event and AHB_HCLK = '1') then
              if (AHB_HRESETN = '0') then
                 HADDR_i <= (others => '0');
              else
                 if (ahb_wr_request = '1' or ahb_rd_request = '1') then
                       HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 3) <= axi_address(C_M_AHB_ADDR_WIDTH-1 downto 3);
                       HADDR_i(2 downto 0) <= "000";
                 elsif (incr_addr = '1' and fixed_burst_access = '0') then
                     if (wrap_2_in_progress = '1') then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 4);
                        HADDR_i(3 downto 0) <= HADDR_i(3 downto 0) + "1000";
                     elsif(wrap_four = '1') then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 5);
                        HADDR_i(4 downto 0) <= HADDR_i(4 downto 0) + "01000";
                     elsif(wrap_eight = '1') then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 6);
                        HADDR_i(5 downto 0) <= HADDR_i(5 downto 0) + "001000";
                     elsif(wrap_sixteen = '1') then
                        HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 7) <= HADDR_i(C_M_AHB_ADDR_WIDTH-1 downto 7);
                        HADDR_i(6 downto 0) <= HADDR_i(6 downto 0) + "0001000";
                     else
                        HADDR_i <= HADDR_i + "1000";
                     end if;
                 else
                       HADDR_i <= HADDR_i;
                 end if;
              end if;
          end if;
       end process AHB_ADDRESS_REG;

    end generate GEN_64_DATA_WIDTH;

-- ****************************************************************************
-- This process is used for driving the AHB PROT when a write or a read
-- is requested.default value "0011" is driving on to HPROT_i as per the
-- ARM recommendation. There is no cacheble in AXI always sending non_cacheble
-- transaction on AHB. 
-- ****************************************************************************

       AHB_PROT_REG : process(AHB_HCLK) is
       begin
          if (AHB_HCLK'event and AHB_HCLK = '1') then
              if (AHB_HRESETN = '0') then
                 HPROT_i <= "0011";
              else
                 if (ahb_wr_request = '1' or ahb_rd_request = '1') then
                       HPROT_i(3) <= '0';
                       HPROT_i(2) <= axi_cache(0) and not(axi_cache(2)) and
                                     not(axi_cache(3));
                       HPROT_i(1) <= axi_prot(0);
                       HPROT_i(0) <= not axi_prot(2);
                 end if;
              end if;
          end if;
       end process AHB_PROT_REG;
       
-------------------------------------------------------------------------------
-- Counter for generating the count for INCR/WRAP burst transfers. Same counter
-- is used for both WRAP and INCR burst transfers.
-------------------------------------------------------------------------------

   WRAP_BURST_COUNTER_REG : process(AHB_HCLK) is
   begin
      if (AHB_HCLK'event and AHB_HCLK = '1') then
          if (AHB_HRESETN = '0') then
            wrap_brst_count <= (others => '0');
          else
              if (load_counter = '1' ) then
                  wrap_brst_count <= axi_length +  1;
              elsif (burst_ready = '1' ) then
                  wrap_brst_count <= wrap_brst_count - 1;
              end if;
          end if;
      end if;
   end process WRAP_BURST_COUNTER_REG;

-------------------------------------------------------------------------------
-- Control signals to generate the last signal of burst transfers. This logic
-- Uses the wrap_brst_count generated by the WRAP_BURST_COUNTER_REG process
-------------------------------------------------------------------------------

   wrap_brst_last <= '1' when wrap_brst_count = "0000001" else '0';
   wrap_brst_one <= '1' when wrap_brst_count = "0000010" else '0';

-------------------------------------------------------------------------------
-- Control signal generated when the axi length less than or equal to 16. This
-- Control signal is used in generating the ahb_burst signal generation
-------------------------------------------------------------------------------

   axi_len_les_eq_sixteen <= '1' when axi_length(7 downto 4) = "0000" else '0';

-------------------------------------------------------------------------------
-- This combinational process generates the AHB BURST type signal
-- Based on axi_length, wrap/incr burst access and onekb_cross_access the
-- ahb_burst is generated.
-------------------------------------------------------------------------------

   onekb_brst_add <= axi_end_address(10) or axi_end_address(11);

   AHB_BURST_LENGTH_CMB : process(incr_burst_access, axi_length(3 downto 0),
                                  axi_len_les_eq_sixteen,onekb_brst_add,
                                  wrap_burst_access) is
   begin
     if(axi_length(3 downto 0) = "1111" and axi_len_les_eq_sixteen = '1') then
         if(wrap_burst_access = '1' ) then
            ahb_burst <= "110";
         elsif(incr_burst_access = '1' and onekb_brst_add = '0' ) then
            ahb_burst <= "111";
         elsif(incr_burst_access = '1' and onekb_brst_add = '1' ) then
            ahb_burst <= "001";
         else
            ahb_burst <= "000";
         end if;
     elsif(axi_length(2 downto 0) = "111" and axi_len_les_eq_sixteen='1') then
         if(wrap_burst_access = '1' ) then
            ahb_burst <= "100";
         elsif(incr_burst_access = '1'  and onekb_brst_add = '0') then
            ahb_burst <= "101";
         elsif(incr_burst_access = '1'  and onekb_brst_add = '1') then
            ahb_burst <= "001";
         else
            ahb_burst <= "000";
         end if;
     elsif(axi_length(3 downto 0) = "0011" and axi_len_les_eq_sixteen='1') then
         if (wrap_burst_access = '1' ) then
            ahb_burst <= "010";
         elsif(incr_burst_access = '1' and onekb_brst_add = '0' ) then
            ahb_burst <= "011";
         elsif(incr_burst_access = '1'  and onekb_brst_add = '1') then
            ahb_burst <= "001";
         else
            ahb_burst <= "000";
         end if;
     else
         if(incr_burst_access = '1' and axi_length(3 downto 0) = "0000" and
            axi_len_les_eq_sixteen = '1') then
           ahb_burst <= "000";
         elsif(incr_burst_access = '1') then
           ahb_burst <= "001";
         else
           ahb_burst <= "000";
         end if;
     end if;
   end process AHB_BURST_LENGTH_CMB;

-- ****************************************************************************
-- This process is used for registering the AHB HBURST. 
-- ****************************************************************************

   AHB_BURST_REG : process(AHB_HCLK) is
   begin
        if (AHB_HCLK'event and AHB_HCLK = '1') then
           if (AHB_HRESETN = '0') then
               HBURST_i <= (others => '0');
           else
               HBURST_i <= ahb_burst;
           end if;
        end if;
   end process AHB_BURST_REG;
   
-- ****************************************************************************
-- This process is used for registering the axi_size. 
-- ****************************************************************************
   
   AHB_SIZE_REG : process(AHB_HCLK) is
      begin
           if (AHB_HCLK'event and AHB_HCLK = '1') then
              if (AHB_HRESETN = '0') then
                  HSIZE_i <= (others => '0');
              else 
                  HSIZE_i <= axi_size;
              end if;
           end if;
   end process AHB_SIZE_REG;
   
-- ****************************************************************************
-- This process is used for registering the axi_lock. 
-- ****************************************************************************
      
      AHB_LOCK_REG : process(AHB_HCLK) is
      begin
            if (AHB_HCLK'event and AHB_HCLK = '1') then
               if (AHB_HRESETN = '0') then
                   HLOCK_i <= '0';
               else
                   HLOCK_i <= axi_lock;
               end if;
            end if;
   end process AHB_LOCK_REG;
   
-------------------------------------------------------------------------------
-- process to register the single write transfer during start of each access
-------------------------------------------------------------------------------

  SINGLE_WRITE_REG : process(AHB_HCLK) is
     begin
       if (AHB_HCLK'event and AHB_HCLK = '1') then
          if (AHB_HRESETN = '0') then
            single_ahb_wr <= '0';
          else
            if(ahb_wr_request = '1') then
              single_ahb_wr <= single_ahb_wr_xfer; 
            end if;
          end if;
       end if;
   end process SINGLE_WRITE_REG;

-- ****************************************************************************
-- AHB State Machine -- START
-- This state machine generates the read and write control signals for
-- transferring the data to/from AHB slave.M_AHB_HTRANS i.e.i AHB transfer type
-- signal is also driven by the control signal generated in this state machine 
-- ****************************************************************************

   AHB_WR_RD_SM   : process (ahb_wr_rd_cs,
                             ahb_wr_request,
                             ahb_rd_request,
                             ahb_hslverr,
                             ahb_hready,
                             ahb_hrdata,
                             axi_burst,
                             fixed_burst_access,
                             single_ahb_wr,
                             single_ahb_rd_xfer,
                             wrap_brst_last,
                             send_ahb_wr,
                             axi_wvalid,
                             wrap_brst_one,
                             axi_rready,
                             one_kb_cross,
                             one_kb_in_progress,
                             wrap_2_in_progress,
                             timeout_inprogress
                            ) is
   begin

     ahb_wr_rd_ns <= ahb_wr_rd_cs;
     rd_data      <= (others => '0');
     slv_err_resp <= '0';
     burst_ready  <= '0';
     send_wr_data <= '0';
     send_wvalid  <= '0';
     incr_addr    <= '0';
     ahb_write_sm <= '0';
     send_bresp_sm     <= '0';
     load_counter_sm   <= '0';
     send_rvalid       <= '0';
     send_rlast_sm     <= '0';
     send_trans_nonseq <= '0';
     send_trans_seq  <= '0';
     send_trans_idle <= '0';
     send_trans_busy <= '0';
     send_wrap_burst <= '0';
     one_kb_splitted <= '0';
     load_cntr       <= '0';
     cntr_enable     <= '0';

      case ahb_wr_rd_cs is

           when AHB_IDLE =>
                if(ahb_wr_request = '1' ) then
                   send_wrap_burst   <= axi_burst(1) and (not axi_burst(0));                        
                   load_counter_sm   <= '1';
                   load_cntr         <= '1';
                   send_trans_nonseq <= '1';
                   ahb_wr_rd_ns <= AHB_WR_ADDR;
                elsif (ahb_rd_request = '1') then
                   send_trans_nonseq <= '1';
                   load_cntr         <= '1';
                   if (single_ahb_rd_xfer = '1') then
                      ahb_wr_rd_ns   <= AHB_RD_SINGLE;
                   elsif(axi_burst(1) = '0') then
                      load_counter_sm <= '1';
                      ahb_wr_rd_ns    <= AHB_RD_ADDR;
                   elsif(axi_burst = "10" ) then
                      send_wrap_burst <= '1';
                      load_counter_sm <= '1';
                      ahb_wr_rd_ns    <= AHB_RD_ADDR;
                   end if;
                end if;

           when AHB_WR_SINGLE =>
                cntr_enable <= '1';
                if(ahb_hready = '1' or timeout_inprogress = '1') then
                   cntr_enable   <= timeout_inprogress;
                   load_cntr     <= not timeout_inprogress;
                   send_bresp_sm <= '1';
                   slv_err_resp  <= ahb_hslverr;
                   burst_ready   <= '1';
                   ahb_wr_rd_ns  <= AHB_IDLE;
                end if;                
           
           when AHB_WR_WAIT =>
                if(send_ahb_wr = '1') then
                   if (one_kb_in_progress = '1' and one_kb_cross = '0') then
                      send_trans_nonseq <= '1';
                      one_kb_splitted   <= '1';
                   elsif(fixed_burst_access = '1') then
                      send_trans_nonseq <= '1';
                   else
                      send_trans_seq    <= '1';
                   end if;                              
                   ahb_wr_rd_ns <= AHB_INCR_ADDR;
                else
                   send_trans_idle <= fixed_burst_access;
                end if;

           when AHB_INCR_ADDR =>
                cntr_enable <= '1';
                if(ahb_hready = '1' or timeout_inprogress = '1') then
                   cntr_enable  <= timeout_inprogress;
                   load_cntr    <= not timeout_inprogress;
                   send_wr_data <= '1';
                   incr_addr    <= '1';
                   if(one_kb_in_progress='1' or fixed_burst_access='1') then
                      send_trans_idle <= '1';
                   else
                      send_trans_busy <= '1';
                   end if;
                   ahb_wr_rd_ns <= AHB_WR_INCR; 
                end if;                

           when AHB_LAST_ADDR =>
                cntr_enable <= '1';
                if(ahb_hready = '1' or timeout_inprogress = '1') then
                   cntr_enable     <= timeout_inprogress;
                   load_cntr       <= not timeout_inprogress;     
                   send_wr_data    <= '1';
                   send_trans_idle <= '1';
                   ahb_wr_rd_ns    <= AHB_WR_INCR;
                end if;                
           
           when AHB_LAST_WAIT =>
                if(send_ahb_wr = '1') then
                  if(one_kb_in_progress = '1' and one_kb_cross = '0') then
                     send_trans_nonseq <= '1';
                     one_kb_splitted   <= '1';
                  elsif(fixed_burst_access='1' or wrap_2_in_progress='1' ) then
                     send_trans_nonseq <= '1';
                  else
                     send_trans_seq <= '1';
                  end if;
                  ahb_wr_rd_ns <= AHB_LAST_ADDR;
                elsif(one_kb_in_progress = '1' and one_kb_cross  = '0') then
                  ahb_wr_rd_ns <= AHB_ONEKB_LAST;
                end if;
           when AHB_LAST =>
                if(send_ahb_wr = '1') then
                  if(fixed_burst_access='1' or wrap_2_in_progress='1' ) then
                     send_trans_nonseq <= '1';
                  else
                     send_trans_seq <= '1';
                  end if;
                  ahb_wr_rd_ns <= AHB_LAST_ADDR;
                end if;
           when AHB_ONEKB_LAST =>
                if(send_ahb_wr = '1') then
                   send_trans_nonseq <= '1';
                   one_kb_splitted <= '1';
                   ahb_wr_rd_ns <= AHB_LAST_ADDR;
                end if;                
           when AHB_WR_INCR =>
                cntr_enable <= '1';
                if(ahb_hready = '1' or timeout_inprogress = '1') then
                  cntr_enable  <= timeout_inprogress;
                  load_cntr    <= not timeout_inprogress;
                  burst_ready  <= '1';
                  send_wvalid  <= '1';
                  slv_err_resp <= ahb_hslverr;                     
                  if(wrap_brst_last = '1') then
                    send_bresp_sm   <= '1';
                    send_trans_idle <= '1';
                    ahb_wr_rd_ns    <= AHB_IDLE;
                  elsif (wrap_brst_one = '1') then
                    if(axi_wvalid = '1') then
                      if(one_kb_in_progress = '1' and one_kb_cross = '0') then
                        send_trans_nonseq <= '1';
                        one_kb_splitted   <= '1';
                      elsif(fixed_burst_access='1' or 
                            wrap_2_in_progress='1') then
                        send_trans_nonseq <= '1';
                      else
                        send_trans_seq <= '1';
                      end if;
                      ahb_wr_rd_ns <= AHB_LAST_ADDR;
                    else
                      if((one_kb_in_progress = '1' and one_kb_cross = '0') or
                         fixed_burst_access='1' or wrap_2_in_progress='1') then
                         send_trans_idle <= '1';
                         ahb_wr_rd_ns <= AHB_LAST_WAIT;
                      else
                         send_trans_busy <= '1';
                         ahb_wr_rd_ns <= AHB_LAST;
                      end if;
                  end if;  
                  else                             
                    if(axi_wvalid = '1') then
                      if(one_kb_in_progress = '1' and one_kb_cross = '0') then
                        send_trans_nonseq <= '1';
                        one_kb_splitted <= '1';
                      elsif(fixed_burst_access = '1') then
                        send_trans_nonseq <= '1';
                      else
                        send_trans_seq <= '1';
                      end if;
                      ahb_wr_rd_ns <= AHB_INCR_ADDR;                              
                    else
                      send_trans_idle <= fixed_burst_access;
                      ahb_wr_rd_ns    <= AHB_WR_WAIT;
                    end if;
                  end if;
                end if;                           

           when AHB_WR_ADDR =>
                cntr_enable <= '1';
                if(ahb_hready = '1' or timeout_inprogress = '1') then
                   cntr_enable  <= timeout_inprogress;
                   load_cntr    <= not timeout_inprogress;
                   send_wr_data <= '1';
                   if (single_ahb_wr = '1') then
                      send_trans_idle <= '1';
                      ahb_wr_rd_ns    <= AHB_WR_SINGLE;
                   elsif (wrap_2_in_progress = '1' or fixed_burst_access = '1'
                          or one_kb_in_progress = '1' or one_kb_cross='1') then
                      send_trans_idle <= '1';
                      incr_addr       <= '1';
                      ahb_wr_rd_ns    <= AHB_WR_INCR;   
                   else                      
                      incr_addr       <= '1';
                      send_trans_busy <= '1';
                      ahb_wr_rd_ns    <= AHB_WR_INCR;                     
                   end if;               
                end if;                

           when AHB_RD_SINGLE =>
                cntr_enable <= '1';
                if(ahb_hready = '1' or timeout_inprogress = '1') then
                   cntr_enable     <= timeout_inprogress;
                   load_cntr       <= not timeout_inprogress;
                   send_trans_idle <= '1';
                   ahb_wr_rd_ns    <= AHB_RD_LAST;
                end if;

           when AHB_RD_LAST =>
                cntr_enable <= '1';
                if(ahb_hready = '1' or timeout_inprogress = '1') then
                   cntr_enable   <= timeout_inprogress;
                   load_cntr     <= not timeout_inprogress;
                   burst_ready   <= '1';
                   slv_err_resp  <= ahb_hslverr;
                   rd_data       <= ahb_hrdata;
                   send_rvalid   <= '1';
                   send_rlast_sm <= '1';
                   ahb_wr_rd_ns  <= AHB_IDLE;
                end if;
           
           when AHB_RD_ADDR =>
                cntr_enable <= '1';
                if(ahb_hready = '1' or timeout_inprogress = '1') then
                   cntr_enable <= timeout_inprogress;
                   load_cntr   <= not timeout_inprogress; 
                   if (wrap_brst_last = '1') then                         
                       send_trans_idle <= '1';
                       ahb_wr_rd_ns    <= AHB_RD_LAST;
                   elsif (wrap_2_in_progress = '1' or fixed_burst_access = '1'
                          or one_kb_in_progress = '1' or one_kb_cross='1') then
                       send_trans_idle <= '1';
                       incr_addr       <= '1';
                       ahb_wr_rd_ns    <= AHB_RD_DATA_INCR;                     
                   else 
                       incr_addr       <= '1';
                       send_trans_busy <= '1';
                       ahb_wr_rd_ns    <= AHB_RD_DATA_INCR;
                   end if;
                end if;

           when AHB_RD_WAIT =>
                if(axi_rready = '1') then
                  if (wrap_brst_last = '1') then
                      ahb_wr_rd_ns <= AHB_IDLE;
                      send_trans_seq    <= '1';
                  elsif (one_kb_in_progress = '1' and one_kb_cross = '0') then
                      send_trans_nonseq <= '1';
                      one_kb_splitted   <= '1';
                  elsif(fixed_burst_access='1' or wrap_2_in_progress='1') then
                      send_trans_nonseq <= '1';
                  else
                      send_trans_seq    <= '1';
                  end if; 
                  ahb_wr_rd_ns <= AHB_RD_ADDR;
                end if;
          
           when AHB_RD_DATA_INCR =>
                cntr_enable <= '1';
                if(ahb_hready = '1' or timeout_inprogress = '1') then
                   cntr_enable  <= timeout_inprogress;
                   load_cntr    <= not timeout_inprogress;
                   burst_ready  <= '1';
                   slv_err_resp <= ahb_hslverr;
                   rd_data      <= ahb_hrdata;
                   send_rvalid  <= '1';
                   if (axi_rready = '1') then
                      if (one_kb_in_progress = '1' and one_kb_cross = '0') then
                          send_trans_nonseq <= '1';
                          one_kb_splitted   <= '1';
                      elsif(wrap_2_in_progress='1' or
                            fixed_burst_access='1') then
                          send_trans_nonseq <= '1';
                      else
                          send_trans_seq <= '1';
                      end if;                              
                      ahb_wr_rd_ns <= AHB_RD_ADDR;
                   else
                      ahb_wr_rd_ns <= AHB_RD_WAIT;
                   end if;
                end if;                

          -- coverage off
            when others =>
                ahb_wr_rd_ns <= AHB_IDLE;
          -- coverage on

       end case;

   end process AHB_WR_RD_SM;

-------------------------------------------------------------------------------
-- Registering the current state and load_counter signals generated from the 
-- AHB state machine
-------------------------------------------------------------------------------

   AHB_WR_RD_SM_REG : process(AHB_HCLK) is
   begin
      if (AHB_HCLK'event and AHB_HCLK = '1') then
         if (AHB_HRESETN = '0') then
             ahb_wr_rd_cs <= AHB_IDLE;
             load_counter <= '0';
         else
             ahb_wr_rd_cs <= ahb_wr_rd_ns;
             load_counter <= load_counter_sm;
         end if;
      end if;
   end process AHB_WR_RD_SM_REG;
   
  
-------------------------------------------------------------------------------
-- 1 KB Crossing logic
-- Based on axi_address, axi_length and axi_size the axi_end_address
-- signal is generated at the the start of access and this signal is used
-- for generating the AHB_HBURST and in the AHB write read statemachine
-------------------------------------------------------------------------------

  axi_end_address <= "00"&axi_address(9 downto 0)+axi_length_burst;

  axi_length_burst <= "000"&axi_length&'0' when axi_size = "001" else
                    "00"&axi_length&"00" when axi_size = "010" else
                     '0'&axi_length&"000" when axi_size = "011" else
                     "0000"&axi_length;

-------------------------------------------------------------------------------
-- process to register the onekb_cross_access during start of each access
-- This is calculated based on axi_end_address
-------------------------------------------------------------------------------

  ONEKB_CROSS_ACCESS_REG : process(AHB_HCLK) is
     begin
       if (AHB_HCLK'event and AHB_HCLK = '1') then
          if (AHB_HRESETN = '0') then
            onekb_cross_access <= '0';
          else
            if(ahb_wr_request = '1' or ahb_rd_request = '1') then
              onekb_cross_access <= axi_end_address(10) or axi_end_address(11);
            elsif(wrap_brst_last = '1') then
              onekb_cross_access <= '0';
            end if;
          end if;
       end if;
   end process ONEKB_CROSS_ACCESS_REG;
  
-------------------------------------------------------------------------------
-- The registered onekb_cross_access along with the current AHB address
-- one_kb_cross is generated.
-------------------------------------------------------------------------------

  addr_all_ones <= '1' when (HADDR_i(9 downto 2) = "11111111" and 
                     HSIZE_i = "010") or (HADDR_i(9 downto 1) = "111111111" and 
                     HSIZE_i = "001") or (HADDR_i(9 downto 3) = "1111111" and 
                     HSIZE_i = "011") or (HADDR_i(9 downto 0) = "1111111111"
                     and HSIZE_i = "000") else
                 '0';
                        
  one_kb_cross <= onekb_cross_access and addr_all_ones and 
                (not wrap_in_progress) and (not fixed_burst_access);

-- ****************************************************************************
-- This process is used for generating the control signal that reflects the
-- one KB crossing is in progress.
-- ****************************************************************************

   ONE_KB_CROSS_REG : process(AHB_HCLK) is
   begin
      if (AHB_HCLK'event and AHB_HCLK = '1') then
         if (AHB_HRESETN = '0') then
             one_kb_in_progress <= '0';
         else
             if (one_kb_cross = '1') then 
                 one_kb_in_progress <= '1';                       
             --elsif (one_kb_splitted = '1' or wrap_brst_last = '1') then 
             elsif (one_kb_splitted = '1' or ahb_wr_rd_cs = AHB_IDLE) then 
                 one_kb_in_progress <= '0';   
             end if;
          end if;
       end if;
   end process ONE_KB_CROSS_REG;

end architecture RTL;


-------------------------------------------------------------------------------
-- axi_ahblite_bridge.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- *******************************************************************
-- ** (c) Copyright [2007] - [2012] Xilinx, Inc. All rights reserved.*
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
-- Filename:        axi_ahblite_bridge.vhd
-- Version:         v1.01a
-- Description:     The AXI to External AHB  Slave Connector translates AXI
--                  transactions into AHB  transactions. It functions as a
--                  AXI slave on the AXI port and an AHB master on
--                  the AHB Lite interface.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--           -- axi_ahblite_bridge.vhd
--              -- axi_slv_if.vhd
--              -- ahb_mstr_if.vhd 
--              -- time_out.vhd
--
-------------------------------------------------------------------------------
-- Author:     NLR 
-- History:
--   NLR      12/15/2010   Initial version
-- ^^^^^^^
--   NLR      04/10/2012   Added the strobe support for single transfers
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*N"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      counter signals:                        "*cntr*", "*count*"
--      ports:                                  - Names in Uppercase
--      processes:                              "*_REG", "*_CMB"
--      component instantiations:               "<ENTITY_>MODULE<#|_FUNC>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library axi_ahblite_bridge_v3_0_17;

-------------------------------------------------------------------------------
-- Generics and Port Declaration
-------------------------------------------------------------------------------
--
-- Definition of Generics
--
-- System Parameters
--
-- C_FAMILY                 -- FPGA Family for which the axi_ahblite_bridge is
--                          -- targeted
-- C_INSTANCE               -- Instance name of the axi_ahblite_bridge in system
--
-- AXI Parameters
--
-- C_S_AXI_ADDR_WIDTH       -- Width of the AXI address bus (in bits)
--                             fixed to 32
-- C_S_AXI_DATA_WIDTH       -- Width of the AXI data bus (in bits)
--                             Either 32 or 64 
-- C_S_AXI_SUPPORTS_NARROW_BURST  -- Support for the Narrow burst access 
--                                   1 supports and 0 does not support
-- C_S_AXI_PROTOCOL         -- AXI Protocol Version i.e. AXI4
--                             fixed to AXI4
-- C_S_AXI_ID_WIDTH         -- Width of AXI ID     
-- C_BASEADDR               -- AXI base address for address range 1
-- C_HIGHADDR               -- AXI high address for address range 1
-- C_DPHASE_TIMEOUT         -- Time out value
--
-- AHB Parameters
--
-- C_M_AHB_ADDR_WIDTH       -- Width of the AHB address bus (in bits)
--                             fixed to 32
-- C_M_AHB_DATA_WIDTH       -- Width of the AHB data bus (in bits)
--                             Either 32 or 64 
-- Definition of Ports
--
-- System signals
-- s_axi_aclk               -- AXI Clock
-- s_axi_aresetn            -- AXI Reset Signal - active low
--
-- axi write address channel signals
--
-- s_axi_awaddr             -- Write address bus - The write address bus gives
--                             the address of the first transfer in a write
--                             burst transaction - fixed to 32
-- s_axi_awprot             -- Protection type - This signal indicates the
--                             normal, privileged, or secure protection level
--                             of the transaction and whether the transaction
--                             is a data access or an instruction access
-- s_axi_awvalid            -- Write address valid - This signal indicates
--                             that valid write address & control information
--                             are available
-- s_axi_awready            -- Write address ready - This signal indicates
--                             that the slave is ready to accept an address
--                             and associated control signals
-- s_axi_awid               -- Write address ID. This signal is the identification 
--                             tag for the write address group of signals
-- s_axi_awlen              -- Burst length. The burst length gives the exact 
--                             number of transfers in a burst 
-- s_axi_awsize             -- Burst size. This signal indicates the size of 
--                             each transfer in the burst.
-- s_axi_awburst            -- Burst type. The burst type, coupled with the size 
--                             information, details how the address for
--                             each transfer within the burst is calculated. 
-- s_axi_awcache            -- Cache type. This signal indicates the bufferable, 
--                             cacheable, write-through, write-back, and
--                             allocate attributes of the transaction.
-- s_axi_awlock             -- Lock type. This signal provides additional information 
--                             about the atomic characteristics of the transfer
--
-- axi write data channel signals
--
-- s_axi_wdata             -- Write data bus - Supports 32/64
-- s_axi_wstrb             -- Write strobes - These signals indicates which
--                            byte lanes to update in memory
-- s_axi_wlast             -- Write last. This signal indicates the last transfer 
--                            in a write burst
-- s_axi_wvalid            -- Write valid - This signal indicates that valid
--                            write data and strobes are available
-- s_axi_wready            -- Write ready - This signal indicates that the
--                            slave can accept the write data
--
-- axi write response channel signals
--
-- s_axi_bid                -- Response ID. The identification tag of the write 
--                             response. 
-- s_axi_bresp              -- Write response - This signal indicates the
--                             status of the write transaction
-- s_axi_bvalid             -- Write response valid - This signal indicates
--                             that a valid write response is available
-- s_axi_bready             -- Response ready - This signal indicates that
--                             the master can accept the response information
--
-- axi read address channel signals
--
-- s_axi_arid              -- Read address ID. This signal is the identification 
--                            tag for the read address group of signals
-- s_axi_araddr            -- Read address - The read address bus gives the
--                            initial address of a read burst transaction
-- s_axi_arprot            -- Protection type - This signal provides
--                            protection unit information for the transaction
-- s_axi_arcache           -- Cache type. This signal provides additional 
--                            information about the cacheable
--                            characteristics of the transfer
-- s_axi_arvalid           -- Read address valid - This signal indicates,
--                            when HIGH, that the read address and control
--                            information is valid and will remain stable
--                            until the address acknowledge signal,ARREADY,
--                            is high.
-- s_axi_arlen             -- Burst length. The burst length gives the exact 
--                            number of transfers in a burst.
-- s_axi_arsize            -- Burst size.This signal indicates the size of each 
--                            transfer in the burst
-- s_axi_arburst           -- Burst type.The burst type, coupled with the size 
--                            information, details how the address for each
--                            transfer within the burst is calculated
-- s_axi_arlock            -- Lock type.This signal provides additional  
--                            information about the atomic characteristics 
--                            of the transfer
-- s_axi_arready           -- Read address ready.This signal indicates
--                            that the slave is ready to accept an address
--                            and associated control signals:
--
-- axi read data channel signals
--
-- s_axi_rid               -- Read ID tag. This signal is the ID tag of the 
--                            read data group of signals  
-- s_axi_rdata             -- Read data bus - Either 32/64
-- s_axi_rresp             -- Read response - This signal indicates the
--                            status of the read transfer
-- s_axi_rvalid            -- Read valid - This signal indicates that the
--                            required read data is available and the read
--                            transfer can complete
-- s_axi_rready            -- Read ready - This signal indicates that the
--                            master can accept the read data and response
--                            information
-- s_axi_rlast             -- Read last. This signal indicates the last 
--                            transfer in a read burst.
-- AHB signals
--
-- m_ahb_hclk             -- AHB Clock
-- m_ahb_hresetn          -- AHB Reset Signal - active low
-- m_ahb_haddr            -- AHB address bus
-- m_ahb_hwrite           -- Direction indicates an AHB write access when
--                           high and an AHB read access when low
-- m_ahb_hsize            -- Indicates the size of the transfer
-- m_ahb_hburst           -- Indicates if the transfer forms part of a burst
--                           Four,eight and sixteen beat bursts are supported
--                           and the burst may be either incrementing or 
--                           wrapping.
-- m_ahb_htrans           -- Indicates the type of the current transfer, 
--                           which can be NONSEQUENTIAL, SEQUENTIAL, IDLE 
--                           or BUSY.
-- m_ahb_hmastlock        -- Indicates that the current master is performing a 
--                           locked sequence of transfers. 
-- m_ahb_hwdata           -- AHB write data
-- m_ahb_hready           -- Ready, the AHB slave uses this signal to
--                           extend an AHB transfer
-- m_ahb_hrdata           -- AHB read data driven by slave 1
-- m_ahb_pslverr          -- This signal indicates transfer failure
-- m_ahb_hprot            -- This signal indicates the normal,
--                           privileged, or secure protection level of the
--                           transaction and whether the transaction is a
--                           data access or an instruction access.
-------------------------------------------------------------------------------

entity axi_ahblite_bridge is
  generic (
    C_FAMILY                      : string                    := "virtex7";
    C_INSTANCE                    : string                    := "axi_ahblite_bridge_inst";
    C_S_AXI_ADDR_WIDTH            : integer range 32 to 64    := 32;
    C_S_AXI_DATA_WIDTH            : integer                   := 32;
    C_S_AXI_SUPPORTS_NARROW_BURST : integer range 0 to 1      := 0;
    C_S_AXI_ID_WIDTH              : integer range 1 to 32     := 4;
    C_M_AHB_ADDR_WIDTH            : integer range 32 to 64    := 32;
    C_M_AHB_DATA_WIDTH            : integer                   := 32;
    C_DPHASE_TIMEOUT              : integer                   := 0
    );
  port (
  -- AXI signals
    s_axi_aclk         : in  std_logic;
    s_axi_aresetn      : in  std_logic := '1';

--   -- AXI Write Address Channel Signals
    s_axi_awid         : in  std_logic_vector 
                             (C_S_AXI_ID_WIDTH-1 downto 0);
    s_axi_awlen        : in  std_logic_vector (7 downto 0);
    s_axi_awsize       : in  std_logic_vector (2 downto 0);
    s_axi_awburst      : in  std_logic_vector (1 downto 0);
    s_axi_awcache      : in  std_logic_vector (3 downto 0);
    s_axi_awaddr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awprot       : in  std_logic_vector(2 downto 0);
    s_axi_awvalid      : in  std_logic;
    s_axi_awready      : out std_logic;
    s_axi_awlock       : in  std_logic;
--   -- AXI Write Channel Signals
    s_axi_wdata        : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_wstrb        : in  std_logic_vector
                             ((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    s_axi_wlast        : in  std_logic;
    s_axi_wvalid       : in  std_logic;
    s_axi_wready       : out std_logic;
    
--   -- AXI Write Response Channel Signals
    s_axi_bid          : out std_logic_vector 
                             (C_S_AXI_ID_WIDTH-1 downto 0);
    s_axi_bresp        : out std_logic_vector(1 downto 0);
    s_axi_bvalid       : out std_logic;
    s_axi_bready       : in  std_logic;

--   -- AXI Read Address Channel Signals
    s_axi_arid         : in  std_logic_vector 
                             (C_S_AXI_ID_WIDTH-1 downto 0);
    s_axi_araddr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arprot       : in  std_logic_vector(2 downto 0);
    s_axi_arcache      : in  std_logic_vector(3 downto 0);
    s_axi_arvalid      : in  std_logic;
    s_axi_arlen        : in  std_logic_vector(7 downto 0);
    s_axi_arsize       : in  std_logic_vector(2 downto 0);
    s_axi_arburst      : in  std_logic_vector(1 downto 0);
    s_axi_arlock       : in  std_logic;
    s_axi_arready      : out std_logic;
--   -- AXI Read Data Channel Signals
    s_axi_rid          : out std_logic_vector 
                             (C_S_AXI_ID_WIDTH-1 downto 0);
    s_axi_rdata        : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_rresp        : out std_logic_vector(1 downto 0);
    s_axi_rvalid       : out std_logic;
    s_axi_rlast        : out std_logic;
    s_axi_rready       : in  std_logic;

-- AHB signals
    
--    m_ahb_hclk         : out  std_logic; removing to address cr 734467
--    m_ahb_hresetn      : out  std_logic;
    
    m_ahb_haddr        : out std_logic_vector(C_M_AHB_ADDR_WIDTH-1 downto 0);
    m_ahb_hwrite       : out std_logic;
    m_ahb_hsize        : out std_logic_vector(2 downto 0);
    m_ahb_hburst       : out std_logic_vector(2 downto 0);
    m_ahb_hprot        : out std_logic_vector(3 downto 0);
    m_ahb_htrans       : out std_logic_vector(1 downto 0);
    m_ahb_hmastlock    : out std_logic;
    m_ahb_hwdata       : out std_logic_vector(C_M_AHB_DATA_WIDTH-1 downto 0);
    
    m_ahb_hready       : in  std_logic;
    m_ahb_hrdata       : in  std_logic_vector(C_M_AHB_DATA_WIDTH-1 downto 0);
    m_ahb_hresp        : in  std_logic
    );

-------------------------------------------------------------------------------
-- Attributes
-------------------------------------------------------------------------------


end entity axi_ahblite_bridge;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of axi_ahblite_bridge is
-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";


 
-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

    signal axi_address    : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal ahb_rd_request : std_logic;
    signal ahb_wr_request : std_logic;
    signal rd_data        : std_logic_vector(C_M_AHB_DATA_WIDTH-1 downto 0);
    signal slv_err_resp   : std_logic;
    signal axi_lock       : std_logic;
    signal axi_prot       : std_logic_vector(2 downto 0);
    signal axi_cache      : std_logic_vector(3 downto 0);
    signal axi_size       : std_logic_vector(2 downto 0);
    signal axi_burst      : std_logic_vector(1 downto 0);
    signal axi_length     : std_logic_vector(7 downto 0);
    signal axi_wdata      : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal send_wvalid    : std_logic;
    signal send_ahb_wr    : std_logic;
    signal axi_wvalid     : std_logic;
    signal send_bresp     : std_logic;
    signal send_rvalid    : std_logic;
    signal send_rlast     : std_logic;
    signal axi_rready     : std_logic;
    signal single_ahb_wr_xfer  : std_logic;
    signal single_ahb_rd_xfer  : std_logic;
    signal load_cntr           : std_logic;
    signal cntr_enable         : std_logic;
    signal timeout_s           : std_logic;
    signal timeout_inprogress  : std_logic; 
    signal s_axi_aresetn_int   : std_logic:= '0';
    signal s_axi_rdata_int     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal s_axi_rvalid_int    : std_logic;
    signal s_axi_rlast_int     : std_logic;
    signal s_axi_rready_int    : std_logic;
    signal s_axi_rid_int       : std_logic_vector (C_S_AXI_ID_WIDTH-1 downto 0);
    signal s_axi_rresp_int     : std_logic_vector (1 downto 0);
begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
    
-------------------------------------------------------------------------------
-- AHB clock and reset assignments
-- AXI clock and AXI reset are assigned to the AHB clock and AHB reset
-- Respectively
-------------------------------------------------------------------------------
      s_axi_aresetn_int <= not(s_axi_aresetn);
--    M_AHB_HCLK    <= s_axi_aclk;
    
--    M_AHB_HRESETN <= s_axi_aresetn;

   --*********************************************************--
    --**               S2MM SLAVE SKID BUFFER                **--
    --*********************************************************--
    VALID_READY_SKID : entity axi_ahblite_bridge_v3_0_17.ahb_skid_buf
        generic map(
            C_WDATA_WIDTH           => C_S_AXI_DATA_WIDTH,
            C_S_AXI_ID_WIDTH        => C_S_AXI_ID_WIDTH

        )
        port map(
            -- System Ports
            ACLK                   => s_axi_aclk,
            ARST                   => s_axi_aresetn_int,

            -- Shutdown control (assert for 1 clk pulse)
            skid_stop              => '0',

            -- Slave Side (AXI4 Data Input)
            S_VALID                => s_axi_rvalid_int,
            S_READY                => s_axi_rready_int,
            S_Data                 => s_axi_rdata_int,
            S_Last                 => s_axi_rlast_int,
            S_STRB                 => (others => '0'),
            S_User                 => (others => '0'),
            S_RID                  => s_axi_rid_int,
            S_RESP                 => s_axi_rresp_int,
            --S_B_VALID              => s_axi_bvalid_int,
            --S_B_READY              => s_axi_bready_int,
            --S_B_Data               => s_axi_bresp_int,
            --S_BID                  => s_axi_bid_int,

            ---- Master Side (AXI4 Data Output)
            --M_B_VALID              => s_axi_bvalid,
            --M_BID                  => s_axi_bid,
            --M_B_READY              => s_axi_bready,
            --M_B_Data               => s_axi_bresp,
            M_RID                  => s_axi_rid,
            M_RESP                 => s_axi_rresp,
            M_VALID                => s_axi_rvalid,
            M_READY                => s_axi_rready,
            M_Data                 => s_axi_rdata,
            M_STRB                 => open,
            M_User                 => open,
            M_Last                 => s_axi_rlast
        );

    
-------------------------------------------------------------------------------
-- Instantiation of the AXI Slave Interface module
-------------------------------------------------------------------------------

    AXI_SLV_IF_MODULE : entity axi_ahblite_bridge_v3_0_17.axi_slv_if
        generic map
        (
         C_FAMILY                         => C_FAMILY,
         C_S_AXI_ID_WIDTH                 => C_S_AXI_ID_WIDTH,
         C_S_AXI_ADDR_WIDTH               => C_S_AXI_ADDR_WIDTH,
         C_S_AXI_DATA_WIDTH               => C_S_AXI_DATA_WIDTH,
         C_DPHASE_TIMEOUT                 => C_DPHASE_TIMEOUT
        )
        port map
        (
         S_AXI_ACLK                       => s_axi_aclk,
         S_AXI_ARESETN                    => s_axi_aresetn,

         S_AXI_AWID                       => s_axi_awid,
         S_AXI_AWADDR                     => s_axi_awaddr,
         S_AXI_AWPROT                     => s_axi_awprot,
         S_AXI_AWCACHE                    => s_axi_awcache,
         S_AXI_AWLEN                      => s_axi_awlen,
         S_AXI_AWSIZE                     => s_axi_awsize,
         S_AXI_AWBURST                    => s_axi_awburst,
         S_AXI_AWVALID                    => s_axi_awvalid,
         S_AXI_AWLOCK                     => s_axi_awlock,
         S_AXI_AWREADY                    => s_axi_awready,
         S_AXI_WDATA                      => s_axi_wdata,
         S_AXI_WSTRB                      => s_axi_wstrb,
         S_AXI_WVALID                     => s_axi_wvalid,
         S_AXI_WLAST                      => s_axi_wlast,
         S_AXI_WREADY                     => s_axi_wready,
         S_AXI_BID                        => s_axi_bid,
         S_AXI_BRESP                      => s_axi_bresp,
         S_AXI_BVALID                     => s_axi_bvalid,
         S_AXI_BREADY                     => s_axi_bready,

         S_AXI_ARID                       => s_axi_arid,
         S_AXI_ARADDR                     => s_axi_araddr,
         S_AXI_ARVALID                    => s_axi_arvalid,
         S_AXI_ARPROT                     => s_axi_arprot,
         S_AXI_ARCACHE                    => s_axi_arcache,
         S_AXI_ARLEN                      => s_axi_arlen,
         S_AXI_ARSIZE                     => s_axi_arsize,
         S_AXI_ARBURST                    => s_axi_arburst,
         S_AXI_ARLOCK                     => s_axi_arlock,
         S_AXI_ARREADY                    => s_axi_arready,
         S_AXI_RID                        => s_axi_rid_int,
         S_AXI_RDATA                      => s_axi_rdata_int,
         S_AXI_RRESP                      => s_axi_rresp_int,
         S_AXI_RVALID                     => s_axi_rvalid_int,
         S_AXI_RLAST                      => s_axi_rlast_int,
         S_AXI_RREADY                     => s_axi_rready_int,
        
         axi_prot                         => axi_prot,
         axi_cache                        => axi_cache,
         axi_wdata                        => axi_wdata,
         axi_size                         => axi_size,
         axi_lock                         => axi_lock,
         axi_address                      => axi_address,
         ahb_rd_request                   => ahb_rd_request,
         ahb_wr_request                   => ahb_wr_request,
         slv_err_resp                     => slv_err_resp,
         rd_data                          => rd_data,
         axi_burst                        => axi_burst,
         axi_length                       => axi_length,
         send_wvalid                      => send_wvalid,
         send_ahb_wr                      => send_ahb_wr,
         single_ahb_wr_xfer               => single_ahb_wr_xfer,
         single_ahb_rd_xfer               => single_ahb_rd_xfer,
         send_bresp                       => send_bresp,
         axi_wvalid                       => axi_wvalid,
         send_rvalid                      => send_rvalid,
         send_rlast                       => send_rlast,
         axi_rready                       => axi_rready,
         timeout_i                        => timeout_s,
         timeout_inprogress               => timeout_inprogress
        );

-------------------------------------------------------------------------------
-- Instantiation of the AHB Master Interface module
-------------------------------------------------------------------------------

    AHB_MSTR_IF_MODULE : entity axi_ahblite_bridge_v3_0_17.ahb_mstr_if
        generic map
        (
         C_M_AHB_ADDR_WIDTH               => C_M_AHB_ADDR_WIDTH,
         C_M_AHB_DATA_WIDTH               => C_M_AHB_DATA_WIDTH,
         C_S_AXI_DATA_WIDTH               => C_S_AXI_DATA_WIDTH,
         C_S_AXI_SUPPORTS_NARROW_BURST    => C_S_AXI_SUPPORTS_NARROW_BURST 
        )
        port map
        (
         AHB_HCLK                         => s_axi_aclk,
         AHB_HRESETN                      => s_axi_aresetn,
         M_AHB_HADDR                      => m_ahb_haddr,
         M_AHB_HWRITE                     => m_ahb_hwrite,
         M_AHB_HSIZE                      => m_ahb_hsize,
         M_AHB_HBURST                     => m_ahb_hburst,
         M_AHB_HPROT                      => m_ahb_hprot,
         M_AHB_HTRANS                     => m_ahb_htrans,
         M_AHB_HMASTLOCK                  => m_ahb_hmastlock,
         M_AHB_HWDATA                     => m_ahb_hwdata,
         M_AHB_HREADY                     => m_ahb_hready,
         M_AHB_HRDATA                     => m_ahb_hrdata,
         M_AHB_HRESP                      => m_ahb_hresp,
       
         ahb_rd_request                   => ahb_rd_request,
         ahb_wr_request                   => ahb_wr_request,
         axi_lock                         => axi_lock,
         rd_data                          => rd_data,
         slv_err_resp                     => slv_err_resp,
         axi_prot                         => axi_prot,
         axi_wdata                        => axi_wdata,
         axi_cache                        => axi_cache,
         axi_size                         => axi_size,
         axi_address                      => axi_address,
         axi_burst                        => axi_burst,
         axi_length                       => axi_length,
         send_wvalid                      => send_wvalid,
         send_ahb_wr                      => send_ahb_wr,
         single_ahb_wr_xfer               => single_ahb_wr_xfer,
         single_ahb_rd_xfer               => single_ahb_rd_xfer,
         send_bresp                       => send_bresp,
         axi_wvalid                       => axi_wvalid,
         send_rvalid                      => send_rvalid,
         send_rlast                       => send_rlast,
         axi_rready                       => axi_rready,
         timeout_inprogress               => timeout_inprogress,
         load_cntr                        => load_cntr,
         cntr_enable                      => cntr_enable
        );

-------------------------------------------------------------------------------
-- Instantiation of the timeout module
-------------------------------------------------------------------------------

    TIME_OUT_MODULE : entity axi_ahblite_bridge_v3_0_17.time_out
        generic map
        (
         C_FAMILY               => C_FAMILY,
         C_DPHASE_TIMEOUT       => C_DPHASE_TIMEOUT
        )
        port map
        (
         S_AXI_ACLK       => s_axi_aclk, 
         S_AXI_ARESETN    => s_axi_aresetn, 
      
         M_AHB_HREADY     => m_ahb_hready, 
       
         load_cntr        => load_cntr, 
         cntr_enable      => cntr_enable, 
         timeout_o        => timeout_s 
        );

end architecture RTL;


