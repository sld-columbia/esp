-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sldfpc_hazard
-- File:	sldfpc_hazard.vhd
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


entity sldfpc_hazard is
  
  port (
    flush_pending      : in  std_ulogic;
    flush              : in  std_ulogic;
    trap_d             : in  std_ulogic;
    annul_d            : in  std_ulogic;
    pv_d               : in  std_ulogic;
    cnt_d              : in  std_logic_vector(1 downto 0);
    cpins_d            : in  cpins_type;
    rs1_d              : in  std_logic_vector(4 downto 0);
    rs2_d              : in  std_logic_vector(4 downto 0);
    rd_d               : in  std_logic_vector(4 downto 0);
    rs1d_d             : in  std_ulogic;
    rs2d_d             : in  std_ulogic;
    rdd_d              : in  std_ulogic;
    rreg1_d            : in  std_ulogic;
    rreg2_d            : in  std_ulogic;
    rregd_d            : in  std_ulogic;
    acsr_d             : in  std_ulogic;
    wreg_d             : in  std_ulogic;
    wrcc_d             : in  std_ulogic;
    fpu_inbuf_state_a  : in  fpu_inbuf_state_type;
    fpu_inbuf_rdy_a    : in  std_ulogic;
    rf_inuse_mask_a    : in  std_logic_vector(31 downto 0);
    rf_dst_mask_a      : in  std_logic_vector(31 downto 0);
    fsr_inuse_a        : in  std_ulogic;
    fsr_dst_a          : in  std_ulogic;
    lln                : in  std_ulogic;
    ldlock             : out std_ulogic);

end sldfpc_hazard;


architecture rtl of sldfpc_hazard is

begin  -- rtl

  -----------------------------------------------------------------------------
  -- Handle Pipeline Hazards
  -----------------------------------------------------------------------------
  -- Drive ldlock high until hazard is resolved
  -- cpins = store
  -- 1. Missing operand: RAW
  -- 2. fpu_inbuff is not empty or single FPOP is not ready: in order issue/commit
  --
  -- cpins = load
  -- 3. Writing to invalid or in use register: WAW or WAR
  -- 4. fpu_inbuff is not empty or single FPOP is not ready: in order issue/commit
  --
  -- cpins = fpop
  -- 5. fpu_inbuff is full: structural
  --
  -- Notice that the buffer maintains FPOP instructions ordering.

  drive_ldlock: process (flush, trap_d, annul_d, pv_d, cnt_d, fpu_inbuf_rdy_a,
                         cpins_d, rs1_d, rs2_d, rd_d, rs1d_d, rs2d_d, rdd_d,
                         rreg1_d, rreg2_d, rregd_d, acsr_d, wreg_d, wrcc_d,
                         fpu_inbuf_state_a, rf_inuse_mask_a, rf_dst_mask_a,
                         fsr_inuse_a, fsr_dst_a, lln, flush_pending)
    variable rs1      : integer range 31 downto 0;
    variable rs1p1    : integer range 31 downto 0;
    variable rs2      : integer range 31 downto 0;
    variable rs2p1    : integer range 31 downto 0;
    variable rd       : integer range 31 downto 0;
    variable rdp1     : integer range 31 downto 0;
    variable rfvalid  : std_logic_vector(31 downto 0);
    variable rfinuse  : std_logic_vector(31 downto 0);
    variable fsrvalid : std_ulogic;
    variable fsrinuse : std_ulogic;
  begin  -- process drive_ldlock
    rfvalid  := rf_dst_mask_a;
    rfinuse  := rf_inuse_mask_a;
    fsrvalid := fsr_dst_a;
    fsrinuse := fsr_inuse_a;
    
    -- Default src and destination
    rs1   := conv_integer(rs1_d);
    rs1p1 := conv_integer(rs1_d(4 downto 1) & '1');
    rs2   := conv_integer(rs2_d);
    rs2p1 := conv_integer(rs2_d(4 downto 1) & '1');
    rd    := conv_integer(rd_d);
    rdp1  := conv_integer(rd_d(4 downto 1) & '1');

    ldlock <= '0';

    if cpins_d = fpop then
      if fpu_inbuf_state_a = full then -- Hazard 5
        ldlock <= '1';
      end if;
    elsif cpins_d = store and cnt_d = "00" then -- Hazard 1.
      if rregd_d = '1' then  --STD/STDF
        if rdd_d = '1' then
          ldlock <= rfvalid(rd) nand rfvalid(rdp1);
        else
          ldlock <= not rfvalid(rd);
        end if;
      elsif acsr_d = '1' then  --STFSR
        ldlock <= not fsrvalid;
      end if;
    elsif cpins_d = load and cnt_d = "00" then  -- Hazard 3.
      if acsr_d = '1' then  --LDFSR
        ldlock <= (not fsrvalid) or fsrinuse;
      else                  --LDF/LDDF
        if rdd_d = '1' then  --LDF
          ldlock <= (rfvalid(rd) nand rfvalid(rdp1)) or rfinuse(rd) or rfinuse(rdp1);
        else  -- LDDF
          ldlock <= (not rfvalid(rd)) or rfinuse(rd);
        end if;
      end if;
    end if;

    if cpins_d = none then
      ldlock <= '0';
    elsif cpins_d /= fpop and lln = '0' then
      ldlock <= '1';
    elsif cpins_d /= fpop and fpu_inbuf_state_a /= empty then
      if fpu_inbuf_state_a /= first or fpu_inbuf_rdy_a = '0' then -- Hazard 2, 4.
        ldlock <= '1';
      end if;
    end if;

    -- If any of the following, then release ldlock.
    if ((flush or trap_d or annul_d) = '1') or pv_d = '0' then
      ldlock <= '0';
    elsif flush_pending = '1' then
      ldlock <= '1';
    end if;
    
  end process drive_ldlock;

end rtl;
