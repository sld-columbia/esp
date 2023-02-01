-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sldfpc
-- File:	sldfpc.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Floating Point Coprocessor for a Sparc V8 IEEE-754
--              compliant floating point unit
------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.gencomp.all;
use work.sldfpp.all;
use work.coretypes.all;
use work.sparc.all;

entity sldfpc is

  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    holdn : in  std_ulogic;
    cpi   : in  fpc_in_type;
    rfi1  : out fp_rf_in_type;
    rfi2  : out fp_rf_in_type;
    rfo1  : in  fp_rf_out_type;
    rfo2  : in  fp_rf_out_type;
    cpo   : out fpc_out_type);

end sldfpc;

architecture rtl of sldfpc is

  -- Decode
  signal op_d     : std_logic_vector(1 downto 0);
  signal op3_d    : std_logic_vector(5 downto 0);
  signal opc_d    : std_logic_vector(8 downto 0);
  signal rs1_d    : std_logic_vector(4 downto 0);
  signal rs2_d    : std_logic_vector(4 downto 0);
  signal rd_d     : std_logic_vector(4 downto 0);

  signal cpins_d  : cpins_type;	        -- FP instruction
  signal rreg1_d  : std_ulogic;		-- using rs1
  signal rreg2_d  : std_ulogic;		-- using rs2
  signal rregd_d  : std_ulogic;         -- usign rd as source (STORE)
  signal rs1d_d   : std_ulogic;		-- rs1 is double (64-bit)
  signal rs2d_d   : std_ulogic;		-- rs2 is double (64-bit)
  signal rdd_d    : std_ulogic;		-- rd is double (64-bit)
  signal wreg_d   : std_ulogic;		-- write FP regfile
  signal wrcc_d   : std_ulogic;		-- write FP condition codes
  signal acsr_d   : std_ulogic;		-- access FP status register
  signal fpill_d  : std_ulogic;

  signal rfo11v_d : std_ulogic;
  signal rfo12v_d : std_ulogic;
  signal rfo21v_d : std_ulogic;
  signal rfo22v_d : std_ulogic;

  signal rf_inv_mask_d  : std_logic_vector(31 downto 0); -- Registers invalid at the next cycle
  signal fsr_inv_mask_d : std_ulogic;                    -- FSR invalid at the next cycle

  signal opid_d : std_logic_vector(5 downto 0);  -- This ID is in syn with actual execution in FPU
  signal next_opid : std_logic_vector(5 downto 0);

  signal lln : std_ulogic;
  signal ldlock   : std_ulogic;

  signal flush_inbuf_d : std_ulogic;

  -- Register file Access
  signal op_a     : std_logic_vector(1 downto 0);
  signal op3_a    : std_logic_vector(5 downto 0);
  signal opc_a    : std_logic_vector(8 downto 0);
  signal rs1_a    : std_logic_vector(4 downto 0);
  signal rs2_a    : std_logic_vector(4 downto 0);
  signal rd_a     : std_logic_vector(4 downto 0);

  signal cpins_a  : cpins_type;	        -- FP instruction
  signal rreg1_a  : std_ulogic;		-- using rs1
  signal rreg2_a  : std_ulogic;		-- using rs2
  signal rregd_a  : std_ulogic;         -- usign rd as source (STORE)
  signal rs1d_a   : std_ulogic;		-- rs1 is double (64-bit)
  signal rs2d_a   : std_ulogic;		-- rs2 is double (64-bit)
  signal rdd_a    : std_ulogic;		-- rd is double (64-bit)
  signal wreg_a   : std_ulogic;		-- write FP regfile
  signal wrcc_a   : std_ulogic;		-- write FP condition codes
  signal acsr_a   : std_ulogic;		-- access FP status register
  signal fpill_a  : std_ulogic;

  signal rfo11v_a : std_ulogic;
  signal rfo12v_a : std_ulogic;
  signal rfo21v_a : std_ulogic;
  signal rfo22v_a : std_ulogic;

  signal opid_a : std_logic_vector(5 downto 0);  -- This ID is in syn with actual execution in FPU
  signal iu_opid_a : std_logic_vector(5 downto 0);  -- This ID is in syn with integer pipeeline

  signal fpu_inbuf_state_a : fpu_inbuf_state_type; -- Feedback to decode stage
  signal fpu_inbuf_a       : fpu_inbuf_type;
  signal fpu_inbuf_next_a  : fpu_inbuf_type;
  signal fpu_inbuf_rdy_a   : std_ulogic;           -- Current FPOP starting now
  signal rf_inuse_mask_a   : std_logic_vector(31 downto 0);  -- Detect ld WAR
  signal rf_dst_mask_a     : std_logic_vector(31 downto 0);  -- Detect st WAW
  signal rf_dst_mask_next_a : std_logic_vector(31 downto 0);
  signal fsr_inuse_a       : std_ulogic;
  signal fsr_dst_a         : std_ulogic;

  signal rf_dst_mask_aemx   : std_logic_vector(31 downto 0);
  signal fsr_dst_aemx       : std_ulogic;
  signal rf_dst_mask_emx    : std_logic_vector(31 downto 0);
  signal fsr_dst_emx        : std_ulogic;

  signal op1_a     : std_logic_vector (63 downto 0); -- operand1
  signal op1_a_reg : std_logic_vector (63 downto 0); -- operand1 registered for
                                                     -- store on holdn asserted
  
  signal op2_a    : std_logic_vector (63 downto 0); -- operand2

  signal flush_fpu_a : std_ulogic;

  -- Execution
  signal rd_e     : std_logic_vector(4 downto 0);

  signal cpins_e  : cpins_type;	        -- FP instruction
  signal rreg1_e  : std_ulogic;		-- using rs1
  signal rreg2_e  : std_ulogic;		-- using rs2
  signal rregd_e  : std_ulogic;         -- usign rd as source (STORE)
  signal rs1d_e   : std_ulogic;		-- rs1 is double (64-bit)
  signal rs2d_e   : std_ulogic;		-- rs2 is double (64-bit)
  signal rdd_e    : std_ulogic;		-- rd is double (64-bit)
  signal wreg_e   : std_ulogic;		-- write FP regfile
  signal wrcc_e   : std_ulogic;		-- write FP condition codes
  signal acsr_e   : std_ulogic;		-- access FP status register 
  signal fpill_e  : std_ulogic;

  signal opid_e : std_logic_vector(5 downto 0);  -- This ID is in syn with actual execution in FPU
  signal iu_opid_e : std_logic_vector(5 downto 0);  -- This ID is in syn with integer pipeeline
  signal iu_cpins_e : cpins_type;

  signal stdata   : std_logic_vector(31 downto 0);

  --SLDFPU signals
  signal start    : std_ulogic;
  signal rdy      : std_ulogic;
  signal allow    : std_logic_vector(2 downto 0);
  signal resid    : std_logic_vector(5 downto 0);
  signal result   : std_logic_vector(63 downto 0);
  signal except   : std_logic_vector(5 downto 0);
  signal cc       : std_logic_vector(1 downto 0);

  -- Memory
  signal rd_m     : std_logic_vector(4 downto 0);

  signal cpins_m  : cpins_type;	        -- FP instruction
  signal rreg1_m  : std_ulogic;		-- using rs1
  signal rreg2_m  : std_ulogic;		-- using rs2
  signal rregd_m  : std_ulogic;         -- usign rd as source (STORE)
  signal rs1d_m   : std_ulogic;		-- rs1 is double (64-bit)
  signal rs2d_m   : std_ulogic;		-- rs2 is double (64-bit)
  signal rdd_m    : std_ulogic;		-- rd is double (64-bit)
  signal wreg_m   : std_ulogic;		-- write FP regfile
  signal wrcc_m   : std_ulogic;		-- write FP condition codes
  signal acsr_m   : std_ulogic;		-- access FP status register
  signal fpill_m  : std_ulogic;

  signal opid_m : std_logic_vector(5 downto 0);  -- This ID is in syn with actual execution in FPU
  signal iu_opid_m : std_logic_vector(5 downto 0);  -- This ID is in syn with integer pipeeline
  signal iu_cpins_m : cpins_type;

  -- Exception
  signal rd_x     : std_logic_vector(4 downto 0);

  signal cpins_x  : cpins_type;	        -- FP instruction
  signal rreg1_x  : std_ulogic;		-- using rs1
  signal rreg2_x  : std_ulogic;		-- using rs2
  signal rregd_x  : std_ulogic;         -- usign rd as source (STORE)
  signal rs1d_x   : std_ulogic;		-- rs1 is double (64-bit)
  signal rs2d_x   : std_ulogic;		-- rs2 is double (64-bit)
  signal rdd_x    : std_ulogic;		-- rd is double (64-bit)
  signal wreg_x   : std_ulogic;		-- write FP regfile
  signal wrcc_x   : std_ulogic;		-- write FP condition codes
  signal acsr_x   : std_ulogic;		-- access FP status register 
  signal fpill_x  : std_ulogic;

  signal opid_x : std_logic_vector(5 downto 0);  -- This ID is in syn with actual execution in FPU
  signal iu_opid_x : std_logic_vector(5 downto 0);  -- This ID is in syn with integer pipeeline
  signal iu_cpins_x : cpins_type;

  signal lddata : std_logic_vector(31 downto 0);

  signal last_fpop_id : std_logic_vector(5 downto 0);
  signal last_fpop_done : std_ulogic;
  signal flush_pending : std_ulogic;

  -- Write Back stage
  signal cnt_wb    : std_logic_vector(1 downto 0);
  signal rd_wb     : std_logic_vector(4 downto 0);

  signal cpins_wb  : cpins_type;	        -- FP instruction
  signal rreg1_wb  : std_ulogic;		-- using rs1
  signal rreg2_wb  : std_ulogic;		-- using rs2
  signal rregd_wb  : std_ulogic;                -- usign rd as source (STORE)
  signal rs1d_wb   : std_ulogic;		-- rs1 is double (64-bit)
  signal rs2d_wb   : std_ulogic;		-- rs2 is double (64-bit)
  signal rdd_wb    : std_ulogic;		-- rd is double (64-bit)
  signal wreg_wb   : std_ulogic;		-- write FP regfile
  signal wrcc_wb   : std_ulogic;		-- write FP condition codes
  signal acsr_wb   : std_ulogic;		-- access FP status register 
  signal fpill_wb  : std_ulogic;

  signal opid_wb : std_logic_vector(5 downto 0);

  signal lddata_wb : std_logic_vector(63 downto 0);

  signal rdy_wb : std_ulogic;
  signal hold_wb : std_ulogic;
  signal fpu_outbuf_state_wb : fpu_outbuf_state_type;
  signal fpu_outbuf_wb : fpu_outbuf_type;

  signal valid_wb_rf : std_ulogic;
  signal valid_wb_cc : std_ulogic;
  signal valid_wb : std_ulogic;                    -- a valid WB is being completed

  signal hold_dst_wb : std_logic_vector(31 downto 0);

  signal flush_outbuf_wb : std_ulogic;
  signal flush_pipe : std_ulogic;

  -- Status Register
  signal fsr      : std_logic_vector(31 downto 0); -- Floating Point Status Register
  signal fsr_rd   : std_logic_vector(1 downto 0);  -- Rounding Direction
  signal fsr_tem  : std_logic_vector(4 downto 0);  -- Trap Exception Mask
  signal fsr_ver  : std_logic_vector(2 downto 0);  -- FPU version
  signal fsr_ftt  : std_logic_vector(2 downto 0);  -- Floating Point Trap Type
  signal fsr_qne  : std_ulogic;                    -- Trap queue not empty
  signal fsr_fcc  : std_logic_vector(1 downto 0);  -- Floating Point Condition Code
  signal fsr_aexc : std_logic_vector(4 downto 0);  -- IEEE 754 accrued exceptions
  signal fsr_cexc : std_logic_vector(4 downto 0);  -- IEEE 754 current exception

  signal fp_trap   : std_ulogic;

  
begin  -- rtl

  -----------------------------------------------------------------------------
  -- Assign output signals
  -----------------------------------------------------------------------------

  cpo.data <= stdata;
  cpo.exc <= fp_trap;

  assign_cc: process(lddata_wb, fpu_outbuf_wb.cc, wrcc_wb, rdy_wb,
                     fsr_fcc, cpins_wb, acsr_wb, flush_pipe, flush_outbuf_wb)
  begin  -- process assign_cc
    if cpins_wb = load and acsr_wb = '1' and flush_pipe = '0' then
      cpo.cc <= lddata_wb(11 downto 10);
    elsif wrcc_wb = '1' and rdy_wb = '1' and flush_outbuf_wb = '0' then
      cpo.cc <= fpu_outbuf_wb.cc;
    else
      cpo.cc <= fsr_fcc;
    end if;
  end process assign_cc;

  cpo.ccv <= fsr_dst_aemx;
  cpo.ldlock <= ldlock;
  cpo.holdn <= '1';
  

  -----------------------------------------------------------------------------
  -- DECODE STAGE
  -----------------------------------------------------------------------------

  op_d    <= cpi.d.inst(31 downto 30);
  rd_d    <= cpi.d.inst(29 downto 25);
  op3_d   <= cpi.d.inst(24 downto 19);
  rs1_d   <= cpi.d.inst(18 downto 14);
  opc_d   <= cpi.d.inst(13 downto 5);
  rs2_d   <= cpi.d.inst(4 downto 0);

  sldfpc_dec_1: sldfpc_dec
    port map (
      flush   => cpi.flush,
      trap_d  => cpi.d.trap,
      annul_d => cpi.d.annul,
      op_d    => op_d,
      op3_d   => op3_d,
      opc_d   => opc_d,
      rs1_d   => rs1_d,
      rs2_d   => rs2_d,
      rd_d    => rd_d,
      cpins_d => cpins_d,
      rreg1_d => rreg1_d,
      rreg2_d => rreg2_d,
      rregd_d => rregd_d,
      rs1d_d  => rs1d_d,
      rs2d_d  => rs2d_d,
      rdd_d   => rdd_d,
      wreg_d  => wreg_d,
      wrcc_d  => wrcc_d,
      acsr_d  => acsr_d,
      fpill_d => fpill_d);

  lln <= (allow(0)) and (not fpu_inbuf_a.ll);
  sldfpc_hazard_1: sldfpc_hazard
    port map (
      flush_pending     => flush_pending,
      flush             => cpi.flush,
      trap_d            => cpi.d.trap,
      annul_d           => cpi.d.annul,
      pv_d              => cpi.d.pv,
      cnt_d             => cpi.d.cnt,
      cpins_d           => cpins_d,
      rs1_d             => rs1_d,
      rs2_d             => rs2_d,
      rd_d              => rd_d,
      rs1d_d            => rs1d_d,
      rs2d_d            => rs2d_d,
      rdd_d             => rdd_d,
      rreg1_d           => rreg1_d,
      rreg2_d           => rreg2_d,
      rregd_d           => rregd_d,
      acsr_d            => acsr_d,
      wreg_d            => wreg_d,
      wrcc_d            => wrcc_d,
      fpu_inbuf_state_a => fpu_inbuf_state_a,
      fpu_inbuf_rdy_a   => fpu_inbuf_rdy_a,
      rf_inuse_mask_a   => rf_inuse_mask_a,
      rf_dst_mask_a     => rf_dst_mask_aemx,
      fsr_inuse_a       => fsr_inuse_a,
      fsr_dst_a         => fsr_dst_aemx,
      lln               => lln,
      ldlock            => ldlock);

  sldfpc_rdreg_1: sldfpc_rdreg
    port map (
      ldlock            => ldlock,
      flush             => cpi.flush,
      trap_d            => cpi.d.trap,
      annul_d           => cpi.d.annul,
      cnt_d             => cpi.d.cnt,
      cpins_d           => cpins_d,
      rs1_d             => rs1_d,
      rs2_d             => rs2_d,
      rd_d              => rd_d,
      rreg1_d           => rreg1_d,
      rreg2_d           => rreg2_d,
      rregd_d           => rregd_d,
      rs1d_d            => rs1d_d,
      rs2d_d            => rs2d_d,
      rdd_d             => rdd_d,
      wreg_d            => wreg_d,
      wrcc_d            => wrcc_d,
      acsr_d            => acsr_d,
      fpill_d           => fpill_d,
      fpu_inbuf_state_a => fpu_inbuf_state_a,
      fpu_inbuf_a       => fpu_inbuf_a,
      fpu_inbuf_next_a  => fpu_inbuf_next_a,
      fpu_inbuf_rdy_a   => fpu_inbuf_rdy_a,
      rf_dst_mask_emx   => rf_dst_mask_emx,
      rf_dst_mask_next_a => rf_dst_mask_next_a,
      fsr_dst_emx       => fsr_dst_emx,
      debug             => cpi.dbg,
      rfi1_rd1addr      => rfi1.rd1addr,
      rfi1_rd2addr      => rfi1.rd2addr,
      rfi1_ren1         => rfi1.ren1,
      rfi1_ren2         => rfi1.ren2,
      rfi2_rd1addr      => rfi2.rd1addr,
      rfi2_rd2addr      => rfi2.rd2addr,
      rfi2_ren1         => rfi2.ren1,
      rfi2_ren2         => rfi2.ren2,
      rfo11v_d          => rfo11v_d,
      rfo12v_d          => rfo12v_d,
      rfo21v_d          => rfo21v_d,
      rfo22v_d          => rfo22v_d,
      rf_inv_mask_d     => rf_inv_mask_d,
      fsr_inv_mask_d    => fsr_inv_mask_d);



  -- Generate opid
  opid_gen: process (clk, rst)
  begin  -- process opid_gen
    if rst = '0' then                   -- asynchronous reset (active low)
      opid_d <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if holdn = '1' and ldlock = '0' then
        opid_d <= next_opid;
      end if;
    end if;
  end process opid_gen;
  next_opid <= opid_d + conv_std_logic_vector(1, 6);

  
  -- FPU Instruction buffer
  sldfpc_fpu_inbuf_1: sldfpc_fpu_inbuf
    generic map (
      bufsize_lg => 2)                  -- must be at least 2;
    port map (
      rst               => rst,
      clk               => clk,
      holdn             => holdn,
      flush             => flush_inbuf_d,
      cpins_d           => cpins_d,
      rs1_d             => rs1_d,
      rs2_d             => rs2_d,
      rd_d              => rd_d,
      rreg1_d           => rreg1_d,
      rreg2_d           => rreg2_d,
      rregd_d           => rregd_d,
      rs1d_d            => rs1d_d,
      rs2d_d            => rs2d_d,
      rdd_d             => rdd_d,
      wreg_d            => wreg_d,
      wrcc_d            => wrcc_d,
      acsr_d            => acsr_d,
      opid_d            => opid_d,
      opc_d             => opc_d,
      allow             => allow,
      rfo11v_a          => rfo11v_a,
      rfo12v_a          => rfo12v_a,
      rfo21v_a          => rfo21v_a,
      rfo22v_a          => rfo22v_a,
      fpu_inbuf_state_a => fpu_inbuf_state_a,
      fpu_inbuf_a       => fpu_inbuf_a,
      fpu_inbuf_next_a  => fpu_inbuf_next_a,
      fpu_inbuf_rdy_a   => fpu_inbuf_rdy_a,
      rf_inuse_mask_a   => rf_inuse_mask_a,
      rf_dst_mask_a     => rf_dst_mask_a,
      rf_dst_mask_next_a => rf_dst_mask_next_a,
      fsr_inuse_a       => fsr_inuse_a,
      fsr_dst_a         => fsr_dst_a);


  rf_dst_mask_check: process (rf_dst_mask_a, rd_e, rdd_e, rd_m, rdd_m, rd_x,
                              rdd_x, wreg_e, wreg_m, wreg_x, wreg_wb,
                              fsr_dst_a, wrcc_e, wrcc_m, wrcc_x, wrcc_wb,
                              hold_dst_wb, cpins_a, cpins_e, cpins_m,
                              cpins_x, acsr_a, acsr_e, acsr_m, acsr_x,
                              wreg_a, rd_a, rdd_a, fpu_inbuf_state_a)
    variable mask : std_logic_vector(31 downto 0);
    variable dst_a , dstp1_a  : integer range 31 downto 0;
    variable dst_e , dstp1_e  : integer range 31 downto 0;
    variable dst_m , dstp1_m  : integer range 31 downto 0;
    variable dst_x , dstp1_x  : integer range 31 downto 0;
    variable dst_wb, dstp1_wb : integer range 31 downto 0;
    variable fsrdst : std_ulogic;
  begin  -- process rf_dst_mask_check
    mask := (others => '1');
    dst_a    := conv_integer(rd_a);
    dstp1_a  := conv_integer(rd_a(4 downto 1) & '1');
    dst_e    := conv_integer(rd_e);
    dstp1_e  := conv_integer(rd_e(4 downto 1) & '1');
    dst_m    := conv_integer(rd_m);
    dstp1_m  := conv_integer(rd_m(4 downto 1) & '1');
    dst_x    := conv_integer(rd_x);
    dstp1_x  := conv_integer(rd_x(4 downto 1) & '1');
    fsrdst := '1';
    
    if wreg_a = '1' and fpu_inbuf_state_a = empty then
      mask(dst_a) := '0';
      if rdd_a = '1' then
        mask(dstp1_a) := '0';
      end if;
    end if;
    if wreg_e = '1' then
      mask(dst_e) := '0';
      if rdd_e = '1' then
        mask(dstp1_e) := '0';
      end if;
    end if;
    if wreg_m = '1' then
      mask(dst_m) := '0';
      if rdd_m = '1' then
        mask(dstp1_m) := '0';
      end if;
    end if;
    if wreg_x = '1' then
      mask(dst_x) := '0';
      if rdd_x = '1' then
        mask(dstp1_x) := '0';
      end if;
    end if;
    
    if wrcc_e = '1' then
      fsrdst := '0';
    end if;
    if wrcc_m = '1' then
      fsrdst := '0';
    end if;
    if wrcc_x = '1' then
      fsrdst := '0';
    end if;

    if cpins_a = load and acsr_a = '1' and fpu_inbuf_state_a = empty then
      fsrdst := '0';
    end if;
    if cpins_e = load and acsr_e = '1' then
      fsrdst := '0';
    end if;
    if cpins_m = load and acsr_m = '1' then
      fsrdst := '0';
    end if;
    if cpins_x = load and acsr_x = '1' then
      fsrdst := '0';
    end if;

    rf_dst_mask_aemx <= rf_dst_mask_a and mask and hold_dst_wb;
    rf_dst_mask_emx <= mask and hold_dst_wb;
    fsr_dst_aemx <= fsr_dst_a and fsrdst;
    fsr_dst_emx <= fsrdst;
  end process rf_dst_mask_check;

  -----------------------------------------------------------------------------
  -- REGISTER FILE ACCESS STAGE
  -----------------------------------------------------------------------------

  op_a    <= cpi.a.inst(31 downto 30);
  rd_a    <= cpi.a.inst(29 downto 25);
  op3_a   <= cpi.a.inst(24 downto 19);
  rs1_a   <= cpi.a.inst(18 downto 14);
  opc_a   <= cpi.a.inst(13 downto 5);
  rs2_a   <= cpi.a.inst(4 downto 0);

  assign_operands: process(rfo1, rfo2, fpu_inbuf_rdy_a, cpins_a, rs1_a, rs2_a,
                           rd_a, rs1d_a, rs2d_a, rdd_a, rreg1_a, rreg2_a,
                           rregd_a, fpu_inbuf_a)
    variable double : std_ulogic;
    variable cpins : cpins_type;
    variable rs1 : std_logic_vector(4 downto 0);
    variable rs2 : std_logic_vector(4 downto 0);
    variable rd  : std_logic_vector(4 downto 0);
    variable rs1d, rs2d, rdd : std_ulogic;
    variable rreg1, rreg2, rregd : std_ulogic;
  begin  -- process assign_operands
    if fpu_inbuf_rdy_a = '1' then
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
    else
      cpins := cpins_a;
      rs1 := rs1_a;
      rs2 := rs2_a;
      rd  := rd_a;
      rreg1 := rreg1_a;
      rreg2 := rreg2_a;
      rregd := rregd_a;
      rs1d := rs1d_a;
      rs2d := rs2d_a;
      rdd  := rdd_a;
    end if;

    --if Using rs1 then also rs2 is used; rd used as source for STF/STDF
    double := (rreg2 and rs2d) or (rregd and rdd);

    --Default operand assignment for binop. on double operands
    op1_a <= rfo1.data1 & rfo2.data1;
    op2_a <= rfo1.data2 & rfo2.data2;

    if double = '0' then
      if rregd = '1' then
        if rd(0) = '0' then
          --need to reassign op1_a LSBs
          op1_a(31 downto 0) <= rfo1.data1;
        end if;
      elsif rreg1 = '1' then
        if rs1(0) = '0' then
          --need to reassign op1_a and op2_a LSBs
          op1_a(31 downto 0) <= rfo1.data1;
        end if;
        if rs2(0) = '0' then
          op2_a(31 downto 0) <= rfo1.data2;
        end if;
      else
        --need to reassign op1_a LSBs: eventually using rs2 only!
        if rs2(0) = '0' then
          op1_a(31 downto 0) <= rfo1.data2;
        else
          op1_a(31 downto 0) <= rfo2.data2;
        end if;
      end if;
    elsif rreg1 = '0' and rregd = '0' then  --Eventually using rs2 only!
      --need to reassign op1_a
      op1_a <= rfo1.data2 & rfo2.data2;
    end if;

  end process assign_operands;  

  hold_store_data: process (clk, rst)
  begin  -- process hold_store_data
    if rst = '0' then                   -- asynchronous reset (active low)
      op1_a_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if holdn = '1' then
        op1_a_reg <= op1_a;
      end if;
    end if;
  end process hold_store_data;
  
  execute_store: process (clk, rst)
  begin  -- process execute_store
    if rst = '0' then                   -- asynchronous reset (active low)
      stdata <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if holdn = '1' then
        if cpins_a = store then
          if acsr_a = '1' then
            stdata <= fsr;
          else
            if cpi.a.cnt = "00" then
              if rdd_a = '1' then
                stdata <= op1_a(63 downto 32);
              else
                stdata <= op1_a(31 downto 0);
              end if;
            elsif cpi.a.cnt = "01" then
              if rdd_a = '1' then
                stdata <= op1_a_reg(63 downto 32);
              else
                stdata <= op1_a_reg(31 downto 0);
              end if;
            else                        -- no need for another register!
              stdata <= op1_a_reg(31 downto 0);
            end if;
          end if;
        end if;
      end if;
    end if;
  end process execute_store;

  start <= fpu_inbuf_rdy_a and holdn;

  sldfpu_1: sldfpu
    port map (
      rst      => rst,
      clk      => clk,
      start    => start,
      opcode   => fpu_inbuf_a.opc,
      opid     => fpu_inbuf_a.id,
      operand0 => op1_a,
      operand1 => op2_a,
      round    => fsr_rd,               --not implemented yet
      flush    => flush_fpu_a,
      flushid  => opid_x,               --TODO which to flush actually??
      nonstd   => '0',                  --unused
      rdy      => rdy,
      allow    => allow,
      resid    => resid,
      result   => result,
      except   => except,
      cc       => cc);

  -----------------------------------------------------------------------------
  -- EXECUTION STAGE
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- MEMORY STAGE
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- EXCEPTION STAGE
  -----------------------------------------------------------------------------

  lddata <= cpi.lddata;

  save_last_fpop: process (clk, rst)
    variable id : std_logic_vector(5 downto 0);
    variable done : std_ulogic;
  begin  -- process save_last_fpop
    if rst = '0' then                   -- asynchronous reset (active low)
      last_fpop_id <= (others => '0');
      last_fpop_done <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      id := last_fpop_id;
      done := last_fpop_done;
      
      if iu_cpins_x = fpop and cpi.x.pv = '1' and cpi.x.annul = '0'
        and cpi.flush = '0' and cpi.x.trap = '0' and flush_pending = '0' then
        -- this fpop will commit
        id := iu_opid_x;
        done := '0';
      end if;

      if done = '0' then
        if rdy_wb = '1' and valid_wb = '1' and cpins_wb = fpop and
          id = fpu_outbuf_wb.id then
          done := '1';
        end if;
      end if;

      last_fpop_id <= id;
      last_fpop_done <= done;
    end if;
  end process save_last_fpop;

  flush_set: process (clk, rst)
  begin  -- process flush_set
    if rst = '0' then                   -- asynchronous reset (active low)
      flush_pending <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if holdn = '1' then
        if (cpi.flush or (cpi.x.trap and (not cpi.x.annul) )) = '1' then
          flush_pending <= '1';
        elsif (flush_pending and last_fpop_done) = '1' then
          flush_pending <= '0';
        end if;        
      end if;
    end if;
  end process flush_set;

  flush_inbuf_d <= flush_pending and last_fpop_done;
  flush_fpu_a <= flush_pending and last_fpop_done;
  flush_pipe <= flush_pending and last_fpop_done;
  flush_outbuf_wb <= flush_pending and last_fpop_done;


  -----------------------------------------------------------------------------
  -- WRITE BACK STAGE
  -----------------------------------------------------------------------------
  
  -- Hold write back when
  -- cpins_wb is fpop and rdy_wb is low (long latency instructions not complete)

  lock_write_back: process(cpins_wb, rdy_wb)
  begin  -- process lock_write_back
    if cpins_wb = fpop and rdy_wb = '0' then
      hold_wb <= '1';
    else
      hold_wb <= '0';
    end if;
  end process lock_write_back;

  sldfpc_fpu_outbuf_1: sldfpc_fpu_outbuf
    port map (
      rst                 => rst,
      clk                 => clk,
      holdn               => holdn,
      flush               => flush_outbuf_wb,
      rdy                 => rdy,
      resid               => resid,
      result              => result,
      except              => except,
      cc                  => cc,
      cpins_wb            => cpins_wb,
      opid_wb             => opid_wb,
      fpu_outbuf_state_wb => fpu_outbuf_state_wb,
      fpu_outbuf_wb       => fpu_outbuf_wb,
      rdy_wb              => rdy_wb);

  sldfpc_wreg_1: sldfpc_wreg
    port map (
      holdn            => holdn,
      flush            => flush_outbuf_wb,
      cnt_wb           => cnt_wb,
      cpins_wb         => cpins_wb,
      rd_wb            => rd_wb,
      rdd_wb           => rdd_wb,
      wreg_wb          => wreg_wb,
      wrcc_wb          => wrcc_wb,
      acsr_wb          => acsr_wb,
      fpu_outbuf_wb    => fpu_outbuf_wb,
      rdy_wb           => rdy_wb,
      lddata_wb        => lddata_wb,
      debug            => cpi.dbg,
      rfi1_wraddr      => rfi1.wraddr,
      rfi1_wrdata      => rfi1.wrdata,
      rfi1_wren        => rfi1.wren,
      rfi2_wraddr      => rfi2.wraddr,
      rfi2_wrdata      => rfi2.wrdata,
      rfi2_wren        => rfi2.wren,
      valid_wb         => valid_wb_rf);

  -- valid_wb_cc does not account for LDFSR because there is no need to
  valid_wb_cc <= holdn and wrcc_wb and rdy_wb and (not flush_outbuf_wb);
  valid_wb <= valid_wb_rf or valid_wb_cc;

  assing_hold_dst_wb: process (hold_wb, rdd_wb, rd_wb, wreg_wb)
    variable mask : std_logic_vector(31 downto 0);
    variable rd : integer range 31 downto 0;
    variable rdp1 : integer range 31 downto 0;
  begin  -- process assing_hold_dst_wb
    mask := (others => '1');
    rd := conv_integer(rd_wb);
    rdp1 := conv_integer(rd_wb(4 downto 1) & '1');
    if (wreg_wb and hold_wb) = '1' then
      mask(rd) := '0';
      if rdd_wb = '1' then
        mask(rdp1) := '0';
      end if;
    end if;
    hold_dst_wb <= mask;
  end process assing_hold_dst_wb;
  
  -----------------------------------------------------------------------------
  -- Floating Point Status Register
  -----------------------------------------------------------------------------

  fsr_rd   <= fsr(31 downto 30);
  fsr_tem  <= fsr(27 downto 23);
  fsr_ver  <= fsr(19 downto 17);
  fsr_ftt  <= fsr(16 downto 14);
  fsr_qne  <= fsr(13);
  fsr_fcc  <= fsr(11 downto 10);
  fsr_aexc <= fsr(9 downto 5);
  fsr_cexc <= fsr(4 downto 0);

  fsr(19 downto 17) <= "100";           -- (ver) Version: value is 4 (matches
                                        -- SLDFPU in patched Linux: arch/sparc/kernel/cpu.c)
  fp_trap  <= '1' when fsr_ftt /= "000" else '0';
  
  process (clk, rst)
    variable trap : std_logic_vector(4 downto 0);
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      fsr(31 downto 30) <= "00";        -- (RD) Round Direction: default is "Nearest Even"
      fsr(29 downto 28) <= "00";        -- Unused
      fsr(27 downto 23) <= "00000";     -- (TEM) IEEE 754 exception trap mask
                                        -- NVM | OFM | UFM | DZM | NXM
      fsr(22)           <= '0';         -- (NS) Non Standard Mode: always zero
                                        -- because subnormals are handled.
      fsr(21 downto 20) <= "00";        -- Reserved
      fsr(16 downto 14) <= "000";       -- (ftt) Floating Point Trap Type: default none
      fsr(13)           <= '0';         -- (qne) Floating Point Queue Not Empty: not
                                        -- implemented as of now. (TODO?)
      fsr(12)           <= '0';         -- Unused
      fsr(11 downto 10) <= "00";        -- (fcc) Condition Code: default rs1 = rs2;
      fsr( 9 downto  5) <= "00000";     -- (aexc) Accrued exception: accumulate exc
                                        -- when masking occurs
      fsr( 4 downto  0) <= "00000";     -- (cexc) Current exception (IEEE).
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (cpi.dbg.enable and cpi.dbg.fsr and cpi.dbg.write) = '1' then
          fsr(31 downto 30) <= cpi.dbg.data(31 downto 30);
          fsr(27 downto 23) <= cpi.dbg.data(27 downto 23);
          fsr(22)           <= cpi.dbg.data(22);
          fsr(11 downto 10) <= cpi.dbg.data(11 downto 10);
          fsr( 9 downto  5) <= cpi.dbg.data(9 downto 5);
          --fsr <= cpi.dbg.data;
      elsif (holdn = '1') and (flush_outbuf_wb = '0') then
        if fpill_wb = '1' then
          -- sequence_error trapped
          fsr(16 downto 14) <= "100";
        elsif cpins_wb = load and acsr_wb = '1' then  --LDFSR
          -- Some fields are reserved or unused and some others are not affected
          -- by LDFSR, according to sparc v8 ISA.
          fsr(31 downto 30) <= lddata_wb(31 downto 30);
          fsr(27 downto 23) <= lddata_wb(27 downto 23);
          fsr(22)           <= lddata_wb(22);
          fsr(11 downto 10) <= lddata_wb(11 downto 10);
          fsr( 9 downto  5) <= lddata_wb(9 downto 5);
        elsif cpins_wb = store and acsr_wb = '1' then
          -- STFSR clears ftt
          fsr(16 downto 14) <= (others => '0');
        elsif cpins_wb = fpop and rdy_wb = '1' then
          trap := fpu_outbuf_wb.exc(4 downto 0) and fsr_tem;
          if fpu_outbuf_wb.exc(5) = '1' then
            -- unfinished_FPop trapped (never occurs)
            fsr(16 downto 14) <= "010";
          elsif trap /= "000" then
            -- IEEE_754_exception trapped
            fsr(4 downto 0) <= fpu_outbuf_wb.exc(4 downto 0);
            fsr(16 downto 14) <= "001";
          else
            -- Accumulate current exception to previous not trapped
            -- and clear ftt
            fsr(9 downto 5) <= fsr_aexc or fpu_outbuf_wb.exc(4 downto 0);
            fsr(16 downto 14) <= "000";
            if wrcc_wb = '1' then
              -- write condition codes
              fsr(11 downto 10) <= fpu_outbuf_wb.cc;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  --TODO: traps must be set in stage x

  -----------------------------------------------------------------------------
  -- Pipeline Registers
  -----------------------------------------------------------------------------

  pipe_reg: process (clk, rst)
  begin  -- process pipe_reg
    if rst = '0' then                   -- asynchronous reset (active low)
      -- d/a register
      cpins_a <= none;
      rreg1_a <= '0';
      rreg2_a <= '0';
      rregd_a <= '0';
      rs1d_a <= '0';
      rs2d_a <= '0';
      wreg_a <= '0';
      rdd_a <= '0';
      wrcc_a <= '0';
      acsr_a <= '0';
      fpill_a <= '0';
      rfo11v_a <= '0';
      rfo12v_a <= '0';
      rfo21v_a <= '0';
      rfo22v_a <= '0';
      opid_a <= (others => '0');
      iu_opid_a <= (others => '0');
      -- a/e register
      rd_e <= (others => '0');
      cpins_e <= none;
      rreg1_e <= '0';
      rreg2_e <= '0';
      rregd_e <= '0';
      rs1d_e <= '0';
      rs2d_e <= '0';
      wreg_e <= '0';
      rdd_e <= '0';
      wrcc_e <= '0';
      acsr_e <= '0';
      fpill_e <= '0';
      opid_e <= (others => '0');
      iu_opid_e <= (others => '0');
      iu_cpins_e <= none;
      -- e/m register
      rd_m <= (others => '0');
      cpins_m <= none;
      rreg1_m <= '0';
      rreg2_m <= '0';
      rregd_m <= '0';
      rs1d_m <= '0';
      rs2d_m <= '0';
      wreg_m <= '0';
      rdd_m <= '0';
      wrcc_m <= '0';
      acsr_m <= '0';
      fpill_m <= '0';
      opid_m <= (others => '0');
      iu_opid_m <= (others => '0');
      iu_cpins_m <= none;
      -- m/x register
      rd_x <= (others => '0');
      cpins_x <= none;
      rreg1_x <= '0';
      rreg2_x <= '0';
      rregd_x <= '0';
      rs1d_x <= '0';
      rs2d_x <= '0';
      wreg_x <= '0';
      rdd_x <= '0';
      wrcc_x <= '0';
      acsr_x <= '0';
      fpill_x <= '0';
      opid_x <= (others => '0');
      iu_opid_x <= (others => '0');
      iu_cpins_x <= none;
      -- x/wb register
      cnt_wb <= (others => '0');
      rd_wb <= (others => '0');
      cpins_wb <= none;
      rreg1_wb <= '0';
      rreg2_wb <= '0';
      rregd_wb <= '0';
      rs1d_wb <= '0';
      rs2d_wb <= '0';
      wreg_wb <= '0';
      rdd_wb <= '0';
      wrcc_wb <= '0';
      acsr_wb <= '0';
      fpill_wb <= '0';
      opid_wb <= (others => '0');
      lddata_wb <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if holdn = '1' then
        iu_opid_a <= opid_d;
        iu_opid_e <= iu_opid_a;
        iu_opid_m <= iu_opid_e;
        iu_opid_x <= iu_opid_m;
        if flush_pipe = '1' then
          -- d/a register
          cpins_a <= none;
          rreg1_a <= '0';
          rreg2_a <= '0';
          rregd_a <= '0';
          rs1d_a <= '0';
          rs2d_a <= '0';
          wreg_a <= '0';
          rdd_a <= '0';
          wrcc_a <= '0';
          acsr_a <= '0';
          fpill_a <= '0';
          rfo11v_a <= '0';
          rfo12v_a <= '0';
          rfo21v_a <= '0';
          rfo22v_a <= '0';
          opid_a <= (others => '0');
          -- a/e register
          rd_e <= (others => '0');
          cpins_e <= none;
          rreg1_e <= '0';
          rreg2_e <= '0';
          rregd_e <= '0';
          rs1d_e <= '0';
          rs2d_e <= '0';
          wreg_e <= '0';
          rdd_e <= '0';
          wrcc_e <= '0';
          acsr_e <= '0';
          fpill_e <= '0';
          opid_e <= (others => '0');
          iu_cpins_e <= none;
          -- e/m register
          rd_m <= (others => '0');
          cpins_m <= none;
          rreg1_m <= '0';
          rreg2_m <= '0';
          rregd_m <= '0';
          rs1d_m <= '0';
          rs2d_m <= '0';
          wreg_m <= '0';
          rdd_m <= '0';
          wrcc_m <= '0';
          acsr_m <= '0';
          fpill_m <= '0';
          opid_m <= (others => '0');
          iu_cpins_m <= none;
          -- m/x register
          rd_x <= (others => '0');
          cpins_x <= none;
          rreg1_x <= '0';
          rreg2_x <= '0';
          rregd_x <= '0';
          rs1d_x <= '0';
          rs2d_x <= '0';
          wreg_x <= '0';
          rdd_x <= '0';
          wrcc_x <= '0';
          acsr_x <= '0';
          fpill_x <= '0';
          opid_x <= (others => '0');
          iu_cpins_x <= none;
          -- x/wb register
          cnt_wb <= (others => '0');
          rd_wb <= (others => '0');
          cpins_wb <= none;
          rreg1_wb <= '0';
          rreg2_wb <= '0';
          rregd_wb <= '0';
          rs1d_wb <= '0';
          rs2d_wb <= '0';
          wreg_wb <= '0';
          rdd_wb <= '0';
          wrcc_wb <= '0';
          acsr_wb <= '0';
          fpill_wb <= '0';
          opid_wb <= (others => '0');
          lddata_wb <= (others => '0');
        else
          -- d/a register
          if ldlock = '1' then  -- bubble at access stage
            cpins_a <= none;
            wreg_a <= '0';
            rreg1_a <= '0';
            rreg2_a <= '0';
            rregd_a <= '0';
            rs1d_a <= '0';
            rs2d_a <= '0';
            rdd_a <= '0';
            wrcc_a <= '0';
            acsr_a <= '0';
            fpill_a <= '0';
          else
            cpins_a <= cpins_d;
            rreg1_a <= rreg1_d;
            rreg2_a <= rreg2_d;
            rregd_a <= rregd_d;
            rs1d_a <= rs1d_d;
            rs2d_a <= rs2d_d;
            wreg_a <= wreg_d;
            rdd_a <= rdd_d;
            wrcc_a <= wrcc_d;
            acsr_a <= acsr_d;
            fpill_a <= fpill_d;
          end if;
          rfo11v_a <= rfo11v_d;
          rfo12v_a <= rfo12v_d;
          rfo21v_a <= rfo21v_d;
          rfo22v_a <= rfo22v_d;
          opid_a <= opid_d;
          -- a/e register
          iu_cpins_e <= cpins_a;
          if fpu_inbuf_rdy_a = '1' then
            -- Ready FPOP will execute at next cycle
            rd_e <= fpu_inbuf_a.rd;
            cpins_e <= fpop;
            rreg1_e <= fpu_inbuf_a.rreg1;
            rreg2_e <= fpu_inbuf_a.rreg2;
            rregd_e <= '0';
            rs1d_e <= fpu_inbuf_a.rs1d;
            rs2d_e <= fpu_inbuf_a.rs2d;
            wreg_e <= fpu_inbuf_a.wreg;
            rdd_e <= fpu_inbuf_a.rdd;
            wrcc_e <= fpu_inbuf_a.wrcc;
            acsr_e <= '0';
            fpill_e <= '0';
            opid_e <=  fpu_inbuf_a.id;
          elsif cpins_a = fpop then
            -- This fpop is queued, thus we issue in order
            rd_e <= (others => '0');
            cpins_e <= none;
            wreg_e <= '0';
            rreg1_e <= '0';
            rreg2_e <= '0';
            rregd_e <= '0';
            rs1d_e <= '0';
            rs2d_e <= '0';
            rdd_e <= '0';
            wrcc_e <= '0';
            acsr_e <= '0';
            fpill_e <= '0';
            opid_e <= (others => '0');
          else
            -- Something else might run, eventually on the IU
            rd_e <= rd_a;
            cpins_e <= cpins_a;
            rreg1_e <= rreg1_a;
            rreg2_e <= rreg2_a;
            rregd_e <= rregd_a;
            rs1d_e <= rs1d_a;
            rs2d_e <= rs2d_a;
            wreg_e <= wreg_a;
            rdd_e <= rdd_a;
            wrcc_e <= wrcc_a;
            acsr_e <= acsr_a;
            fpill_e <= fpill_a;
            opid_e <= (others => '0');
          end if;
          -- e/m register
          iu_cpins_m <= iu_cpins_e;
          rd_m <= rd_e;
          cpins_m <= cpins_e;
          rreg1_m <= rreg1_e;
          rreg2_m <= rreg2_e;
          rregd_m <= rregd_e;
          rs1d_m <= rs1d_e;
          rs2d_m <= rs2d_e;
          wreg_m <= wreg_e;
          rdd_m <= rdd_e;
          wrcc_m <= wrcc_e;
          acsr_m <= acsr_e;
          fpill_m <= fpill_e;
          opid_m <= opid_e;
          -- m/x register
          iu_cpins_x <= iu_cpins_m;
          rd_x <= rd_m;
          cpins_x <= cpins_m;
          rreg1_x <= rreg1_m;
          rreg2_x <= rreg2_m;
          rregd_x <= rregd_m;
          rs1d_x <= rs1d_m;
          rs2d_x <= rs2d_m;
          wreg_x <= wreg_m;
          rdd_x <= rdd_m;
          wrcc_x <= wrcc_m;
          acsr_x <= acsr_m;
          fpill_x <= fpill_m;
          opid_x <= opid_m;
          -- x/wb register
          if hold_wb = '0' then
            cnt_wb <= cpi.x.cnt;
            rd_wb <= rd_x;
            cpins_wb <= cpins_x;
            rreg1_wb <= rreg1_x;
            rreg2_wb <= rreg2_x;
            rregd_wb <= rregd_x;
            rs1d_wb <= rs1d_x;
            rs2d_wb <= rs2d_x;
            wreg_wb <= wreg_x;
            rdd_wb <= rdd_x;
            wrcc_wb <= wrcc_x;
            acsr_wb <= acsr_x;
            opid_wb <= opid_x;
            fpill_wb <= fpill_x;
            if rdd_x = '1' and cpi.x.cnt /= "01" then
              lddata_wb(63 downto 32) <= lddata;              
            else
              lddata_wb(31 downto 0) <= lddata;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process pipe_reg;


  -----------------------------------------------------------------------------
  -- Debug
  -----------------------------------------------------------------------------
  assign_debug_out: process (clk, rst)
  begin  -- process assign_debug_out
    if rst = '0' then                   -- asynchronous reset (active low)
      cpo.dbg.data <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if cpi.dbg.enable = '1' and cpi.dbg.write = '0' then
        if cpi.dbg.fsr = '1' then
          cpo.dbg.data <= fsr;
        elsif cpi.dbg.addr(0) = '0' then
          cpo.dbg.data <= rfo1.data1;
        else
          cpo.dbg.data <= rfo2.data1;
        end if;
      end if;
    end if;
  end process assign_debug_out;

end rtl;
