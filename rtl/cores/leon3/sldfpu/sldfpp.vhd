-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0


library ieee;
use ieee.std_logic_1164.all;
use work.coretypes.all;

package sldfpp is

  type cpins_type is (none, fpop, load, store);

  type sldfpu_ctrl is (pip, seq, last, seq_end3, seq_end2, seq_end1);

  type fpu_inbuf_state_type is (empty, first, more, full);

  type fpu_inbuf_type is record
    id    : std_logic_vector(5 downto 0);  -- instruction ID
    ll    : std_ulogic;                    -- long latency instruction
    opc   : std_logic_vector(8 downto 0);  -- FPOP Opcode
    rs1   : std_logic_vector(4 downto 0);  -- source 1
    rs2   : std_logic_vector(4 downto 0);  -- source 2
    rs1d  : std_ulogic;                    -- source 1 is double
    rs2d  : std_ulogic;                    -- source 2 is double
    rreg1 : std_ulogic;                    -- reading rs1
    rreg2 : std_ulogic;                    -- reading rs2
    rd    : std_logic_vector(4 downto 0);  -- destination
    rdd   : std_ulogic;                    -- destination is double
    wreg  : std_ulogic;                    -- istruction writes register
    wrcc  : std_ulogic;                    -- instruction write condition code
  end record;

  constant OUTBUF_SIZE : integer := 4;  -- This number should not be changed!

  constant fpu_inbuf_none : fpu_inbuf_type := (id    => (others => '0'),
                                               ll    => '0',
                                               opc   => (others => '0'),
                                               rs1   => (others => '0'),
                                               rs2   => (others => '0'),
                                               rs1d  => '0',
                                               rs2d  => '0',
                                               rreg1 => '0',
                                               rreg2 => '0',
                                               rd    => (others => '0'),
                                               rdd   => '0',
                                               wreg  => '0',
                                               wrcc  => '0');

  type fpu_outbuf_state_type is (empty, pend1, pend2, pend3, pend4);

  type fpu_outbuf_type is record
                            id  : std_logic_vector(5 downto 0);  -- instruction ID
                            res : std_logic_vector(63 downto 0); -- result
                            exc : std_logic_vector(5 downto 0);  -- exception
                            cc  : std_logic_vector(1 downto 0);  -- condition code
  end record;

  constant fpu_outbuf_none : fpu_outbuf_type := (id  => (others => '0'),
                                                 res => (others => '0'),
                                                 exc => (others => '0'),
                                                 cc  => (others => '0'));

  component sldfpc_dec
    port (
      flush   : in  std_ulogic;
      trap_d  : in  std_ulogic;
      annul_d : in  std_ulogic;
      op_d    : in  std_logic_vector(1 downto 0);
      op3_d   : in  std_logic_vector(5 downto 0);
      opc_d   : in  std_logic_vector(8 downto 0);
      rs1_d   : in  std_logic_vector(4 downto 0);
      rs2_d   : in  std_logic_vector(4 downto 0);
      rd_d    : in  std_logic_vector(4 downto 0);
      cpins_d : out cpins_type;
      rreg1_d : out std_ulogic;
      rreg2_d : out std_ulogic;
      rregd_d : out std_ulogic;
      rs1d_d  : out std_ulogic;
      rs2d_d  : out std_ulogic;
      rdd_d   : out std_ulogic;
      wreg_d  : out std_ulogic;
      wrcc_d  : out std_ulogic;
      acsr_d  : out std_ulogic;
      fpill_d : out std_ulogic);
  end component;

  component sldfpc_rdreg
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
  end component;

  component sldfpc_hazard
    port (
      flush_pending     : in  std_ulogic;
      flush             : in  std_ulogic;
      trap_d            : in  std_ulogic;
      annul_d           : in  std_ulogic;
      pv_d              : in  std_ulogic;
      cnt_d             : in  std_logic_vector(1 downto 0);
      cpins_d           : in  cpins_type;
      rs1_d             : in  std_logic_vector(4 downto 0);
      rs2_d             : in  std_logic_vector(4 downto 0);
      rd_d              : in  std_logic_vector(4 downto 0);
      rs1d_d            : in  std_ulogic;
      rs2d_d            : in  std_ulogic;
      rdd_d             : in  std_ulogic;
      rreg1_d           : in  std_ulogic;
      rreg2_d           : in  std_ulogic;
      rregd_d           : in  std_ulogic;
      acsr_d            : in  std_ulogic;
      wreg_d            : in  std_ulogic;
      wrcc_d            : in  std_ulogic;
      fpu_inbuf_state_a : in  fpu_inbuf_state_type;
      fpu_inbuf_rdy_a   : in  std_ulogic;
      rf_inuse_mask_a   : in  std_logic_vector(31 downto 0);
      rf_dst_mask_a     : in  std_logic_vector(31 downto 0);
      fsr_inuse_a       : in  std_ulogic;
      fsr_dst_a         : in  std_ulogic;
      lln               : in  std_ulogic;
      ldlock            : out std_ulogic);
  end component;

  component sldfpc_fpu_inbuf
    generic (
      bufsize_lg : integer);
    port (
      rst               : in  std_ulogic;
      clk               : in  std_ulogic;
      holdn             : in  std_ulogic;
      flush             : in  std_ulogic;
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
      opid_d            : in  std_logic_vector(5 downto 0);
      opc_d             : in  std_logic_vector(8 downto 0);
      allow             : in  std_logic_vector(2 downto 0);
      rfo11v_a          : in  std_ulogic;
      rfo12v_a          : in  std_ulogic;
      rfo21v_a          : in  std_ulogic;
      rfo22v_a          : in  std_ulogic;
      fpu_inbuf_state_a : out fpu_inbuf_state_type;
      fpu_inbuf_a       : out fpu_inbuf_type;
      fpu_inbuf_next_a  : out fpu_inbuf_type;
      fpu_inbuf_rdy_a   : out std_ulogic;
      rf_inuse_mask_a   : out std_logic_vector(31 downto 0);
      rf_dst_mask_a     : out std_logic_vector(31 downto 0);
      rf_dst_mask_next_a: out std_logic_vector(31 downto 0);
      fsr_inuse_a       : out std_ulogic;
      fsr_dst_a         : out std_ulogic);
  end component;

  component sldfpc_fpu_outbuf
    port (
      rst                 : in  std_ulogic;
      clk                 : in  std_ulogic;
      holdn               : in  std_ulogic;
      flush               : in  std_ulogic;
      rdy                 : in  std_ulogic;
      resid               : in  std_logic_vector(5 downto 0);
      result              : in  std_logic_vector(63 downto 0);
      except              : in  std_logic_vector(5 downto 0);
      cc                  : in  std_logic_vector(1 downto 0);
      cpins_wb            : in  cpins_type;
      opid_wb             : in  std_logic_vector(5 downto 0);
      fpu_outbuf_state_wb : out fpu_outbuf_state_type;
      fpu_outbuf_wb       : out fpu_outbuf_type;
      rdy_wb              : out std_ulogic);
  end component;

  component sldfpc_wreg
    port (
      holdn            : in  std_ulogic;
      flush            : in  std_ulogic;
      cnt_wb           : in  std_logic_vector(1 downto 0);
      cpins_wb         : in  cpins_type;
      rd_wb            : in  std_logic_vector(4 downto 0);
      rdd_wb           : in  std_ulogic;
      wreg_wb          : in  std_ulogic;
      wrcc_wb          : in  std_ulogic;
      acsr_wb          : in  std_ulogic;
      fpu_outbuf_wb    : in  fpu_outbuf_type;
      rdy_wb           : in  std_ulogic;
      lddata_wb        : in  std_logic_vector(63 downto 0);
      debug            : in  fpc_debug_in_type;
      rfi1_wraddr      : out std_logic_vector(3 downto 0);
      rfi1_wrdata      : out std_logic_vector(31 downto 0);
      rfi1_wren        : out std_ulogic;
      rfi2_wraddr      : out std_logic_vector(3 downto 0);
      rfi2_wrdata      : out std_logic_vector(31 downto 0);
      rfi2_wren        : out std_ulogic;
      valid_wb         : out std_ulogic);
  end component;

  component sldfpu
    port (
      rst      : in  std_ulogic;
      clk      : in  std_ulogic;
      start    : in  std_ulogic;
      opcode   : in  std_logic_vector(8 downto 0);
      opid     : in  std_logic_vector(5 downto 0);
      operand0 : in  std_logic_vector(63 downto 0);
      operand1 : in  std_logic_vector(63 downto 0);
      round    : in  std_logic_vector(1 downto 0);
      flush    : in  std_ulogic;
      flushid  : in  std_logic_vector(5 downto 0);
      nonstd   : in  std_ulogic;
      rdy      : out std_ulogic;
      allow    : out std_logic_vector(2 downto 0);
      resid    : out std_logic_vector(5 downto 0);
      result   : out std_logic_vector(63 downto 0);
      except   : out std_logic_vector(5 downto 0);
      cc       : out std_logic_vector(1 downto 0));
  end component;

  component sldfpc
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
  end component;

  component sldfpw
    generic (
      memtech : integer);
    port (
      rst   : in  std_ulogic;
      clk   : in  std_ulogic;
      holdn : in  std_ulogic;
      cpi   : in  fpc_in_type;
      cpo   : out fpc_out_type);
  end component;

  component asu
    port (
      clk      : in  std_ulogic;
      rst      : in  std_ulogic;
      double   : in  std_ulogic;
      add      : in  std_ulogic;
      sub      : in  std_ulogic;
      itofp    : in  std_ulogic;
      fptoi    : in  std_ulogic;
      fptornd  : in  std_ulogic;
      fptofp   : in  std_ulogic;
      cmp      : in  std_ulogic;
      cmpe     : in  std_ulogic;
      absv     : in  std_ulogic;
      neg      : in  std_ulogic;
      mov      : in  std_ulogic;
      round    : in  std_logic_vector(1 downto 0);
      in0      : in  std_logic_vector(63 downto 0);
      in1      : in  std_logic_vector(63 downto 0);
      man0_ldz : in  std_logic_vector(5 downto 0);
      man1_ldz : in  std_logic_vector(5 downto 0);
      in0_zero : in  std_ulogic;
      in1_zero : in  std_ulogic;
      in0_nstd : in  std_ulogic;
      in1_nstd : in  std_ulogic;
      in0_inf  : in  std_ulogic;
      in1_inf  : in  std_ulogic;
      in0_NaN  : in  std_ulogic;
      in1_NaN  : in  std_ulogic;
      in0_SNaN : in  std_ulogic;
      in1_SNaN : in  std_ulogic;
      result   : out std_logic_vector(63 downto 0);
      cc       : out std_logic_vector(1 downto 0);
      flags    : out std_logic_vector(5 downto 0));
  end component;

end sldfpp;
