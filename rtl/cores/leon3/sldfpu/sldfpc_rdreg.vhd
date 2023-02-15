-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sldfpc_rdreg
-- File:	sldfpc_rdreg.vhd
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

entity sldfpc_rdreg is

  port (
    ldlock            : in  std_ulogic;
    flush             : in  std_ulogic;
    trap_d            : in  std_ulogic;
    annul_d           : in  std_ulogic;
    cnt_d             : in  std_logic_vector(1 downto 0);

    cpins_d           : in  cpins_type;
    rs1_d             : in  std_logic_vector(4 downto 0);
    rs2_d             : in  std_logic_vector(4 downto 0);
    rd_d              : in  std_logic_vector(4 downto 0);
    rreg1_d           : in  std_ulogic;
    rreg2_d           : in  std_ulogic;
    rregd_d           : in  std_ulogic;
    rs1d_d            : in  std_ulogic;
    rs2d_d            : in  std_ulogic;
    rdd_d             : in  std_ulogic;
    wreg_d            : in  std_ulogic;
    wrcc_d            : in  std_ulogic;
    acsr_d            : in  std_ulogic;
    fpill_d           : in  std_ulogic;

    fpu_inbuf_state_a : in  fpu_inbuf_state_type;
    fpu_inbuf_a       : in  fpu_inbuf_type;
    fpu_inbuf_next_a  : in  fpu_inbuf_type;
    fpu_inbuf_rdy_a   : in  std_ulogic;

    rf_dst_mask_emx   : in  std_logic_vector(31 downto 0);
    rf_dst_mask_next_a: in  std_logic_vector(31 downto 0);
    fsr_dst_emx       : in  std_ulogic;

    debug             : in  fpc_debug_in_type;

    rfi1_rd1addr      : out std_logic_vector(3 downto 0);
    rfi1_rd2addr      : out std_logic_vector(3 downto 0);
    rfi1_ren1         : out std_ulogic;
    rfi1_ren2         : out std_ulogic;
    rfi2_rd1addr      : out std_logic_vector(3 downto 0);
    rfi2_rd2addr      : out std_logic_vector(3 downto 0);
    rfi2_ren1         : out std_ulogic;
    rfi2_ren2         : out std_ulogic;

    rfo11v_d          : out std_ulogic;
    rfo12v_d          : out std_ulogic;
    rfo21v_d          : out std_ulogic;
    rfo22v_d          : out std_ulogic;

    rf_inv_mask_d     : out std_logic_vector(31 downto 0);
    fsr_inv_mask_d    : out std_ulogic);

end sldfpc_rdreg;

architecture rtl of sldfpc_rdreg is

  signal dbg_rd1addr, dbg_rd2addr : std_logic_vector(3 downto 0);
  signal dbg_ren1, dbg_ren2 : std_ulogic;

begin  -- rtl


  -- If no FPOP instruction is pending, then RF inputs are generated according
  -- to the control signals of the current decoded instruction. Otherwise, the
  -- first pending FPOP in the queue will be served, while any new FP non FPOP
  -- instruction will be kept on hold by asserting ldlock.

  fetch_operands: process (cnt_d, cpins_d, rs1_d, rs2_d, rd_d, rreg1_d, rreg2_d,
                           rregd_d, rs1d_d, rs2d_d, rdd_d, wreg_d, wrcc_d,
                           acsr_d, fpu_inbuf_state_a, fpu_inbuf_a, ldlock,
                           fpu_inbuf_rdy_a,
                           rf_dst_mask_emx, fsr_dst_emx, fpu_inbuf_next_a,
                           rf_dst_mask_next_a, dbg_rd1addr, dbg_rd2addr,
                           dbg_ren1, dbg_ren2, debug.enable)
    variable cnt : std_logic_vector(1 downto 0);
    variable cpins : cpins_type;
    variable rs1, rs2, rd : std_logic_vector(4 downto 0);
    variable rs1d, rs2d, rdd, rreg1, rreg2, rregd : std_ulogic;
    variable wreg, wrcc, acsr : std_ulogic;
    
    variable rd11addr, rd21addr, rd12addr, rd22addr : std_logic_vector(3 downto 0);
    variable rf_inv_mask : std_logic_vector(31 downto 0);
    variable fsr_inv_mask : std_ulogic;
    variable rfvalid : std_logic_vector(31 downto 0);
    variable rd11int, rd12int, rd21int, rd22int : integer range 31 downto 0;
    variable dst   : integer range 31 downto 0;
    variable dstp1 : integer range 31 downto 0;
    variable ren11, ren21, ren12, ren22 : std_ulogic;
  begin  -- process fetch_operands
    if fpu_inbuf_state_a = empty or (fpu_inbuf_state_a = first and fpu_inbuf_rdy_a = '1') then
      cnt := cnt_d;
      if ldlock = '1' then
        cpins := none;
      else
        cpins := cpins_d;
      end if;
      rs1 := rs1_d;
      rs2 := rs2_d;
      rd  := rd_d;
      rreg1 := rreg1_d;
      rreg2 := rreg2_d;
      rregd := rregd_d;
      rs1d := rs1d_d;
      rs2d := rs2d_d;
      rdd  := rdd_d;
      wreg := wreg_d;
      wrcc := wrcc_d;
      acsr := acsr_d;
      rfvalid := rf_dst_mask_next_a and rf_dst_mask_emx;
    elsif fpu_inbuf_rdy_a = '1' then
      cnt := "00";
      cpins := fpop;
      rs1 := fpu_inbuf_next_a.rs1;
      rs2 := fpu_inbuf_next_a.rs2;
      rd  := fpu_inbuf_next_a.rd;
      rreg1 := fpu_inbuf_next_a.rreg1;
      rreg2 := fpu_inbuf_next_a.rreg2;
      rregd := '0';
      rs1d := fpu_inbuf_next_a.rs1d;
      rs2d := fpu_inbuf_next_a.rs2d;
      rdd  := fpu_inbuf_next_a.rdd;
      wreg := fpu_inbuf_next_a.wreg;
      wrcc := fpu_inbuf_next_a.wrcc;
      acsr := '0';
      rfvalid := rf_dst_mask_emx and rf_dst_mask_next_a;
    else
      cnt := "00";
      cpins := fpop;
      rs1 := fpu_inbuf_a.rs1;
      rs2 := fpu_inbuf_a.rs2;
      rd  := fpu_inbuf_a.rd;
      rreg1 := fpu_inbuf_a.rreg1;
      rreg2 := fpu_inbuf_a.rreg2;
      rregd := '0';
      rs1d := fpu_inbuf_a.rs1d;
      rs2d := fpu_inbuf_a.rs2d;
      rdd  := fpu_inbuf_a.rdd;
      wreg := fpu_inbuf_a.wreg;
      wrcc := fpu_inbuf_a.wrcc;
      acsr := '0';
      rfvalid := rf_dst_mask_emx;
    end if;

    -- Default Initialization
    rd11addr := rs1(4 downto 1);
    rd21addr := rs1(4 downto 1);
    rd12addr := rs2(4 downto 1);
    rd22addr := rs2(4 downto 1);

    rf_inv_mask := (others => '1');
    fsr_inv_mask := '1';

    ren11 := '0';
    ren12 := '0';
    ren21 := '0';
    ren22 := '0';

    if cpins /= none and cnt = 0 then
      if rregd = '1' then
        rd11addr := rd(4 downto 1);
        rd21addr := rd(4 downto 1);
        if rdd = '1' then
          ren11 := '1';
          ren21 := '1';
        elsif rd(0) = '0' then
          ren11 := '1';
        else
          ren21 := '1';
        end if;
      else
        if rreg1 = '1' then
          if rs1d = '1' then
            ren11 := '1';
            ren21 := '1';
          else
            if rs1(0) = '0' then
              ren11 := '1';
            else
              ren21 := '1';
            end if;
          end if;
        end if;
        if rreg2 = '1' then
          if rs2d = '1' then
            ren12 := '1';
            ren22 := '1';
          else
            if rs2(0) = '0' then
              ren12 := '1';
            else
              ren22 := '1';
            end if;
          end if;
        end if;
      end if;      
    end if;

    dst   := conv_integer(rd);
    dstp1 := conv_integer(rd(4 downto 1) & '1');
    if cpins /= none and cnt = 0 then
      rf_inv_mask(dst) := not wreg;
      if rdd = '1' then --dst must be 0 mod 2!
        rf_inv_mask(dstp1) := not wreg;
      end if;
      if cpins = load then 
        fsr_inv_mask := not acsr;
      else
        fsr_inv_mask := not wrcc;
      end if;
    end if;


    if debug.enable = '1' then
      rfi1_rd1addr <= dbg_rd1addr;
      rfi1_rd2addr <= dbg_rd1addr;
      rfi1_ren1    <= dbg_ren1;
      rfi1_ren2    <= dbg_ren1;
      
      rfi2_rd1addr <= dbg_rd2addr;
      rfi2_rd2addr <= dbg_rd2addr;
      rfi2_ren1    <= dbg_ren2;
      rfi2_ren2    <= dbg_ren2;
    else
      rfi1_rd1addr <= rd11addr;
      rfi1_rd2addr <= rd12addr;
      rfi1_ren1    <= ren11;
      rfi1_ren2    <= ren12;
      
      rfi2_rd1addr <= rd21addr;
      rfi2_rd2addr <= rd22addr;
      rfi2_ren1    <= ren21;
      rfi2_ren2    <= ren22;
    end if;

    rd11int := 2 * conv_integer(rd11addr);
    rd12int := 2 * conv_integer(rd12addr);
    rd21int := 2 * conv_integer(rd21addr) + 1;
    rd22int := 2 * conv_integer(rd22addr) + 1;

    rfo11v_d <= rfvalid(rd11int);
    rfo12v_d <= rfvalid(rd12int);
    rfo21v_d <= rfvalid(rd21int);
    rfo22v_d <= rfvalid(rd22int);
    
    rf_inv_mask_d <= rf_inv_mask;
    fsr_inv_mask_d <= fsr_inv_mask;
  end process fetch_operands;


  -- Debug
  dbg_rd1addr <= debug.addr(4 downto 1);
  dbg_rd2addr <= debug.addr(4 downto 1);
  dbg_ren1 <= '1';
  dbg_ren2 <= '1';
  
end rtl;
