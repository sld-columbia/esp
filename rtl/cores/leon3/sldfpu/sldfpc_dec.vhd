-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sldfpc_dec
-- File:	sldfpc_dec.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Floating Point Coprocessor for a Sparc V8 IEEE-754
--              compliant floating point unit
------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.gencomp.all;
use work.sldfpp.all;
use work.coretypes.all;
use work.sparc.all;


entity sldfpc_dec is
  
  port (
    flush             : in  std_ulogic;
    trap_d            : in  std_ulogic;
    annul_d           : in  std_ulogic;

    op_d              : in  std_logic_vector(1 downto 0);
    op3_d             : in  std_logic_vector(5 downto 0);
    opc_d             : in  std_logic_vector(8 downto 0);
    rs1_d             : in  std_logic_vector(4 downto 0);
    rs2_d             : in  std_logic_vector(4 downto 0);
    rd_d              : in  std_logic_vector(4 downto 0);

    cpins_d           : out cpins_type;
    rreg1_d           : out std_ulogic;
    rreg2_d           : out std_ulogic;
    rregd_d           : out std_ulogic;
    rs1d_d            : out std_ulogic;
    rs2d_d            : out std_ulogic;
    rdd_d             : out std_ulogic;
    wreg_d            : out std_ulogic;
    wrcc_d            : out std_ulogic;
    acsr_d            : out std_ulogic;
    fpill_d           : out std_ulogic);

end sldfpc_dec;


architecture rtl of sldfpc_dec is

begin  -- rtl

  decode_inst: process (op_d, op3_d, opc_d, flush, trap_d, annul_d)
  begin  -- process decode_inst

    cpins_d <= none;
    wreg_d <= '0';
    rreg1_d <= '0';
    rreg2_d <= '0';
    rregd_d <= '0';
    rs1d_d <= '0';
    rs2d_d <= '0';
    rdd_d <= '0';
    wrcc_d <= '0';
    acsr_d <= '0';
    fpill_d <= '0';

    if ((flush or trap_d or annul_d) = '0') then
      case op_d is
      
        when FMT3 =>
          case op3_d is
            when FPOP1 => cpins_d <= fpop;
                          wreg_d <= '1';   --Will write fp regfile
                          case opc_d is
                            when FMOVS | FABSS | FNEGS         => rreg2_d <= '1';
                            when FITOS | FSTOI | FSTOI_RND     => rreg2_d <= '1';
                            when FITOD | FSTOD                 => rreg2_d <= '1';
                                                                  rdd_d   <= '1';
                            when FDTOI | FDTOI_RND | FDTOS     => rreg2_d <= '1';
                                                                  rs2d_d  <= '1';
                            when FSQRTS                        => rreg2_d <= '1';
                            when FSQRTD                        => rreg2_d <= '1';
                                                                  rs2d_d  <= '1';
                                                                  rdd_d   <= '1';
                            when FADDS | FSUBS | FMULS | FDIVS => rreg1_d <= '1';
                                                                  rreg2_d <= '1';
                            when FSMULD                        => rreg1_d <= '1';
                                                                  rreg2_d <= '1';
                                                                  rdd_d   <= '1';
                            when FADDD | FSUBD | FMULD | FDIVD => rreg1_d <= '1';
                                                                  rreg2_d <= '1';
                                                                  rs1d_d  <= '1'; 
                                                                  rs2d_d  <= '1';
                                                                  rdd_d   <= '1';
                            when others => fpill_d <= '1'; -- illegal instuction
                          end case;

            when FPOP2 => cpins_d <= fpop;
                          wrcc_d  <= '1';   --Will write condition case
                          rreg1_d <= '1';
                          rreg2_d <= '1';
                          case opc_d is
                            when FCMPD | FCMPED => rs1d_d <= '1';
                                                   rs2d_d <= '1';
                            when FCMPS | FCMPES => null;
                            when others => fpill_d <= '1'; -- illegal instuction
                          end case;

            when others => null;
          end case;

        
        when LDST =>
          case op3_d is
            when LDF | LDDF    => cpins_d <= load;
                                  rdd_d   <= op3_d(1) and op3_d(0);
                                  wreg_d  <= '1';
            when STF | STDF    => cpins_d <= store;
                                  rregd_d <= '1';
                                  rdd_d   <= op3_d(1) and op3_d(0);
            when STFSR         => cpins_d <= store;
                                  acsr_d  <= '1';
            when LDFSR         => cpins_d <= load;
                                  acsr_d  <= '1';
            when others => cpins_d <= none;
                           --fpill_d <= '1';  --Deferred trap queue not implemented

          end case;
        when others => null;

      end case;
    end if;
  end process decode_inst;


end rtl;
