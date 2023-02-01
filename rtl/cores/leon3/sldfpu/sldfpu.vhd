-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sldfpu
-- File:	sldfpu.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Floating Point Coprocessor for a Sparc V8
--              compliant floating point unit. The implementation follows the
--              directions given in the GRIP User Guide by Aeroflex Gaisler.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.gencomp.all;
use work.sparc.all;
use work.sldfpp.all;
use work.basic.all;
use work.bw.all;

entity sldfpu is
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
    rdy      : out std_ulogic;                    -- ready
    allow    : out std_logic_vector(2 downto 0);  -- available operations
    resid    : out std_logic_vector(5 downto 0);
    result   : out std_logic_vector(63 downto 0);
    except   : out std_logic_vector(5 downto 0);
    cc       : out std_logic_vector(1 downto 0)); -- condition code

end sldfpu;

architecture rtl of sldfpu is

  --Zero constant
  constant zero : std_logic_vector(63 downto 0) := (others => '0');   -- FPd/s 0

-------------------------------------------------------------------------------
-- Leading zero counter. (Copyright (C) 2002 Martin Kasprzyk)
-------------------------------------------------------------------------------
  procedure lz_counter (
    in_vect       : in  std_logic_vector(55 downto 0);
    leading_zeros : out std_logic_vector(5 downto 0)) is 
    variable pos_mask : std_logic_vector(55 downto 0);
    variable neg_mask : std_logic_vector(55 downto 0);
    variable leading_one : std_logic_vector(55 downto 0);
    variable nr_zeros : std_logic_vector(5 downto 0);
  begin
    -- Find leading one e.g. if in_vect = 00101101 then pos_mask = 00111111
    -- and neg_mask = "11100000, performing and gives leading_one = 00100000
    pos_mask(55) := in_vect(55);
    for i in 54 downto 0 loop
      pos_mask(i) := pos_mask(i+1) or in_vect(i);
    end loop;
    neg_mask := "1" & (not pos_mask(55 downto 1));
    leading_one := pos_mask and neg_mask;

    -- Get number of leading zeros from the leading_one vector
    nr_zeros := "000000";
 
    for i in 1 to 55 loop
      if (i / 32) /= 0 then
        nr_zeros(5) := nr_zeros(5) or leading_one(55-i);
      end if;

      if ((i mod 32) / 16) /= 0  then
        nr_zeros(4) := nr_zeros(4) or leading_one(55-i);
      end if;

      if (((i mod 32) mod 16) / 8) /= 0 then
        nr_zeros(3) := nr_zeros(3) or leading_one(55-i);
      end if;

      if ((((i mod 32) mod 16) mod 8) / 4) /= 0 then
        nr_zeros(2) := nr_zeros(2) or leading_one(55-i);
      end if;

      if (((((i mod 32) mod 16) mod 8) mod 4) / 2) /= 0 then
        nr_zeros(1) := nr_zeros(1) or leading_one(55-i);
      end if;
      
      if (i mod 2) /= 0 then
        nr_zeros(0) := nr_zeros(0) or leading_one(55-i);
      end if;
    end loop;

    -- Return result
    leading_zeros := nr_zeros;
  end lz_counter;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Variable amount left shifter (Copyright (C) 2002 Martin Kasprzyk) - edit
-------------------------------------------------------------------------------
  procedure left_shifter (
    in_vect  : in  std_logic_vector(51 downto 0);
    amount   : in  std_logic_vector(5 downto 0);
    out_vect : out std_logic_vector(51 downto 0)) is
    variable after32 : std_logic_vector(51 downto 0);
    variable after16 : std_logic_vector(51 downto 0);
    variable after8  : std_logic_vector(51 downto 0);
    variable after4  : std_logic_vector(51 downto 0);
    variable after2  : std_logic_vector(51 downto 0);
    variable after1  : std_logic_vector(51 downto 0);
  begin
    -- If amount(5) = '1' then shift vector 32 positions left
    if amount(5) = '1' then
      after32 := in_vect(19 downto 0) & zero(31 downto 0);
    else
      after32 := in_vect;
    end if;

    -- If amount(4) = '1' then shift vector 16 positions left
    if amount(4) = '1' then
      after16 :=  after32(35 downto 0) & zero(15 downto 0);
    else
      after16 := after32;
    end if;

    -- If amount(3) = '1' then shift vector 8 positions left
    if amount(3) = '1' then
      after8 := after16(43 downto 0) & zero(7 downto 0);
    else
      after8 := after16;
    end if;

    -- If amount(2) = '1' then shift vector 4 positions left
    if amount(2) = '1' then
      after4 := after8(47 downto 0) & zero(3 downto 0);
    else
      after4 := after8;
    end if;

    -- If amount(1) = '1' then shift vector 2 positions left
    if amount(1) = '1' then
      after2 := after4(49 downto 0) & "00";
    else
      after2 := after4;
    end if;

    -- If amount(0) = '1' then shift vector 1 positions left
    if amount(0) = '1' then
      after1 := after2(50 downto 0) & "0";
    else
      after1 := after2;
    end if;

    -- Return value
    out_vect := after1;
  end left_shifter;
  
-------------------------------------------------------------------------------
  
  -- SDMU signals
  signal opc        : std_logic_vector(2 downto 0);
  signal sdmu_flush : std_ulogic;
  signal sdmu_in0   : std_logic_vector(63 downto 0);
  signal sdmu_in1   : std_logic_vector(63 downto 0);
  signal sdmu_out   : std_logic_vector(63 downto 0);
  signal sdmu_flags : std_logic_vector(5 downto 0);

  -- ASU signals
  signal asu_double : std_ulogic;
  signal add      : std_ulogic;
  signal sub      : std_ulogic;
  signal itofp    : std_ulogic;
  signal fptoi    : std_ulogic;
  signal fptornd  : std_ulogic;
  signal fptofp   : std_ulogic;
  signal cmp      : std_ulogic;
  signal cmpe     : std_ulogic;
  signal absv     : std_ulogic;
  signal neg      : std_ulogic;
  signal mov      : std_ulogic;
  signal asu_in0      : std_logic_vector(63 downto 0);
  signal asu_in1      : std_logic_vector(63 downto 0);
  signal asu_result   : std_logic_vector(63 downto 0);
  signal asu_cc       : std_logic_vector(1 downto 0);
  signal asu_flags    : std_logic_vector(5 downto 0);
  -- Caveat: itod has single input, but double output!
  signal itod : std_ulogic;

  -- Input Operands Type
  signal double     : std_ulogic;
  signal man0_ldz   : std_logic_vector(5 downto 0);
  signal man1_ldz   : std_logic_vector(5 downto 0);
  signal in0_zero   : std_ulogic;
  signal in1_zero   : std_ulogic;
  signal in0_nstd   : std_ulogic;
  signal in1_nstd   : std_ulogic;
  signal in0_inf    : std_ulogic;
  signal in1_inf    : std_ulogic;
  signal in0_NaN    : std_ulogic;
  signal in1_NaN    : std_ulogic;
  signal in0_SNaN   : std_ulogic;
  signal in1_SNaN   : std_ulogic;

  -- Auxiliary signals
  signal man0_prenorm : std_logic_vector(51 downto 0);
  signal man1_prenorm : std_logic_vector(51 downto 0);

  -- Controller signals
  signal sdmu_op: std_ulogic;
  signal sdmu_opid : std_logic_vector(5 downto 0);
  signal sdmu_hold16, sdmu_hold25 : std_ulogic;
  signal sdmu_running : std_ulogic;
  signal sample_opid : std_ulogic;

  signal cstate, nstate : sldfpu_ctrl;
  signal count, next_count : std_logic_vector(4 downto 0);
  constant DIV_STATES : std_logic_vector(4 downto 0)  := "01100";
  constant SQRT_STATES : std_logic_vector(4 downto 0) := "10101";

  signal dummy : std_ulogic;

  signal valid_in : std_ulogic;
  signal opid_in : std_logic_vector(5 downto 0);
  signal sdmu_op_in : std_ulogic;
  
  signal valid_reg, valid1_reg, valid2_reg : std_ulogic;
  signal opid_reg, opid1_reg, opid2_reg : std_logic_vector(5 downto 0);
  signal sdmu_op_reg, sdmu_op1_reg, sdmu_op2_reg, sdmu_op_out : std_ulogic;
  signal flush_stage0l, flush_stage1l, flush_stage2l, flush_sdmul : std_ulogic;

begin  -- rtl

  -----------------------------------------------------------------------------
  -- Output
  -----------------------------------------------------------------------------
  rdy <= valid2_reg;                    -- asserted 1 cyle before output
  resid <= opid2_reg;                   -- asserted 1 cyle before output
  result <= sdmu_out when sdmu_op_out = '1' else asu_result;
  except <= sdmu_flags when sdmu_op_out = '1' else asu_flags;
  cc <= asu_cc;

  -----------------------------------------------------------------------------
  -- Controller
  -----------------------------------------------------------------------------
  
  --Count SQRT and DIV states
  ppadd_1: ppadd
    generic map (
      n    => 5,
      logn => 3)
    port map (
      add0_in   => count,
      add1_in   => "11111",
      carry_in  => '0',
      sum_out   => next_count,
      carry_out => dummy);
  state_counter: process (clk, rst)
  begin  -- process state_counter
    if rst = '0' then                   -- asynchronous reset (active low)
      count <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sdmu_running = '1' then
        count <= next_count;
      elsif sdmu_hold16 = '1' and start = '1' then
        count <= DIV_STATES;
      elsif sdmu_hold25 = '1' and start = '1' then
        count <= SQRT_STATES;
      else
        count <= (others => '0');
      end if;
    end if;
  end process state_counter;

  update_state: process (clk, rst)
  begin  -- process update_state
    if rst = '0' then                   -- asynchronous reset (active low)
      cstate <= pip;
    elsif clk'event and clk = '1' then  -- rising clock edge
      cstate <= nstate;
    end if;
  end process update_state;

  
  sdmu_opid_sample: process (clk, rst)
  begin  -- process sdmu_opid_sample
    if rst = '0' then                   -- asynchronous reset (active low)
      sdmu_opid <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_opid = '1' then
        sdmu_opid <= opid;
      end if;
    end if;
  end process sdmu_opid_sample;

  fsm: process (cstate, start, sdmu_op, flush_stage0l, sdmu_opid, flush_sdmul,
                opid, sdmu_hold25, sdmu_hold16, next_count)
  begin  -- process fsm
    nstate <= pip;
    allow <= "000";
    valid_in <= '0';
    opid_in <= "000000";
    sdmu_running <= '0';
    sdmu_op_in <= '0';
    sample_opid <= '0';
    case cstate is
      when pip    => allow <= "111";
                     if  start = '1' and flush_stage0l = '1' then
                       if (sdmu_hold16 or sdmu_hold25) = '1' then
                         nstate <= seq;
                         sample_opid <= '1';
                       else
                         nstate <= pip;
                         valid_in <= '1';
                         opid_in <= opid;
                         sdmu_op_in <= sdmu_op;
                       end if;
                     else
                       nstate <= pip;
                     end if;

      when seq    => sdmu_running <= '1';
                     if flush_sdmul = '0' then
                       nstate <= pip;
                     elsif next_count = "00000" then
                       nstate <= last;
                     else
                       nstate <= seq;
                     end if;

      when last   => if flush_sdmul = '1' then
                       valid_in <= '1';
                       opid_in <= sdmu_opid;
                       sdmu_op_in <= '1';
                     end if;
                     nstate <= seq_end3;

      when seq_end3  => allow <= "011";  --Only pipelined fpop allowed
                        nstate <= seq_end2;
                        if  start = '1' and flush_stage0l = '1' then
                          if (sdmu_hold16 nor sdmu_hold25) = '1' then
                            sample_opid <= '1';
                            valid_in <= '1';
                            opid_in <= opid;
                            sdmu_op_in <= sdmu_op;
                          end if;
                        end if;

      when seq_end2  => allow <= "011";  --Only pipelined fpop allowed
                        nstate <= seq_end1;
                        if  start = '1' and flush_stage0l = '1' then
                          if (sdmu_hold16 nor sdmu_hold25) = '1' then
                            sample_opid <= '1';
                            valid_in <= '1';
                            opid_in <= opid;
                            sdmu_op_in <= sdmu_op;
                          end if;
                        end if;

      when seq_end1  => allow <= "011";  --Only pipelined fpop allowed
                        nstate <= pip;
                        if  start = '1' and flush_stage0l = '1' then
                          if (sdmu_hold16 nor sdmu_hold25) = '1' then
                            sample_opid <= '1';
                            valid_in <= '1';
                            opid_in <= opid;
                            sdmu_op_in <= sdmu_op;
                          end if;
                        end if;

      when others => nstate <= pip;
    end case;
  end process fsm;


  --flush signals (ACTIVE LOW!)
  --Trying to simplify flush logic. Check on timing is done outside the FPU core.
  --When flush is high, all stages of the FPU have to be flushed.
  flush_stage0l <= not flush;--'0' when flush = '1' and flushid = opid      else '1';
  flush_stage1l <= not flush;--'0' when flush = '1' and flushid = opid_reg  else '1';
  flush_stage2l <= not flush;--'0' when flush = '1' and flushid = opid1_reg else '1';
  flush_sdmul   <= not flush;--'0' when flush = '1' and flushid = sdmu_opid else '1';
  --reset SDMU FSM. Active high
  sdmu_flush    <= (not flush_sdmul) or ((not flush_stage0l) and sdmu_op)
                   or ((not flush_stage1l) and sdmu_op_reg)
                   or ((not flush_stage2l) and sdmu_op1_reg);
                   
  
  --Controls pipelin
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      valid_reg <= '0';
      valid1_reg <= '0';
      valid2_reg <= '0';
      opid_reg <= (others => '0');
      opid1_reg <= (others => '0');
      opid2_reg <= (others => '0');
      sdmu_op_reg <= '0';
      sdmu_op1_reg <= '0';
      sdmu_op2_reg <= '0';
      sdmu_op_out <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      valid_reg <= valid_in and flush_stage0l;
      valid1_reg <= valid_reg and flush_stage1l;
      valid2_reg <= valid1_reg and flush_stage2l;
      opid_reg <= opid_in;
      opid1_reg <= opid_reg;
      opid2_reg <= opid1_reg;
      sdmu_op_reg <= sdmu_op_in;
      sdmu_op1_reg <= sdmu_op_reg;
      sdmu_op2_reg <= sdmu_op1_reg;
      sdmu_op_out <= sdmu_op2_reg;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- FPU
  -----------------------------------------------------------------------------

  -- Decode
  decode_opc: process (opcode)
  begin  -- process decode_opc
    double   <= '0';
    opc      <= "000";
    add      <= '0';
    sub      <= '0';
    itofp    <= '0';
    itod     <= '0';
    fptoi    <= '0';
    fptornd  <= '0';
    fptofp   <= '0';
    cmp      <= '0';
    cmpe     <= '0';
    absv     <= '0';
    neg      <= '0';
    mov      <= '0';
    sdmu_op  <= '0';
    sdmu_hold25 <= '0';
    sdmu_hold16 <= '0';
    case opcode is
      when FITOS     => itofp <= '1';
      when FITOD     => itofp <= '1';
                        itod <= '1';
      when FSTOI     => fptoi <= '1';
      when FDTOI     => fptoi <= '1';
                        double <= '1';
      when FSTOI_RND => fptornd <= '1';  --TODO: IMPLEMENT THIS ONE AND RND MODES
      when FDTOI_RND => fptornd <= '1';
                        double <= '1';
      when FSTOD     => fptofp <= '1';
      when FDTOS     => fptofp <= '1';
                        double <= '1';
      when FMOVS     => mov <= '1';
      when FNEGS     => neg <= '1';
      when FABSS     => absv <= '1';
      when FSQRTS    => opc <= "011";
                        sdmu_op <= '1';
                        sdmu_hold25 <= '1';
      when FSQRTD    => opc <= "111";
                        double <= '1';
                        sdmu_op <= '1';
                        sdmu_hold25 <= '1';                        
      when FADDS     => add <= '1';
      when FADDD     => add <= '1';
                        double <= '1';
      when FSUBS     => sub <= '1';
      when FSUBD     => sub <= '1';
                        double <= '1';
      when FMULS     => opc <= "001";
                        sdmu_op <= '1';
      when FMULD     => opc <= "101";
                        double <= '1';
                        sdmu_op <= '1';
      when FSMULD    => opc <= "001";    --TODO: IMPLEMENT THIS ONE!!!!
                        sdmu_op <= '1';
      when FDIVS     => opc <= "010";
                        sdmu_op <= '1';
                        sdmu_hold16 <= '1';
      when FDIVD     => opc <= "110";
                        double <= '1';
                        sdmu_op <= '1';
                        sdmu_hold16 <= '1';
      when FCMPS     => cmp <= '1';
      when FCMPD     => cmp <= '1';
                        double <= '1';
      when FCMPES    => cmpe <= '1';
      when FCMPED    => cmpe <= '1';
                        double <= '1';
      when others    => null;
    end case;
  end process decode_opc;
  asu_double <= (double xor fptofp) or itod;
  
  -- Leading Zero Count and mantissa left shift
  zero_cnt: process (operand0, operand1, double, in0_nstd, in1_nstd)
    variable m0z, m1z : std_logic_vector(5 downto 0);
    variable man0_in, man1_in : std_logic_vector(51 downto 0);
    variable man0_ls, man1_ls : std_logic_vector(51 downto 0);
  begin  -- process zero_cnt
    if double = '1' then
      man0_in := operand0(51 downto 0);
      man1_in := operand1(51 downto 0);
      lz_counter(operand0(51 downto 0) & zero(3 downto 0), m0z);
      lz_counter(operand1(51 downto 0) & zero(3 downto 0), m1z);
    else
      man0_in := operand0(22 downto 0) & zero(51 downto 23);
      man1_in := operand1(22 downto 0) & zero(51 downto 23);
      lz_counter(operand0(22 downto 0) & zero(32 downto 0), m0z);
      lz_counter(operand1(22 downto 0) & zero(32 downto 0), m1z);
    end if;
    man0_ldz <= m0z;
    man1_ldz <= m1z;
    
    if in0_nstd = '1' then
      left_shifter(man0_in, m0z, man0_ls);
      man0_ls := man0_ls(50 downto 0) & '0';
    else
      man0_ls := man0_in;
    end if;
    if in1_nstd = '1' then
      left_shifter(man1_in, m1z, man1_ls);
      man1_ls := man1_ls(50 downto 0) & '0';
    else
      man1_ls := man1_in;
    end if;
    man0_prenorm <= man0_ls;
    man1_prenorm <= man1_ls;
  end process zero_cnt;

  -- Zero and Subnormal numbers Detection
  zero_nstd_detect: process (operand0, operand1, double)
  begin  -- process zero_nstd_detect
    in0_zero <= '0';
    in1_zero <= '0';
    in0_nstd <= '0';
    in1_nstd <= '0';
    if double = '1' then
      if operand0(62 downto 52) = zero(62 downto 52) then
        if operand0(51 downto 0) = zero(51 downto 0) then
          in0_zero <= '1';
        else
          in0_nstd <= '1';
        end if;
      end if;
      if operand1(62 downto 52) = zero(62 downto 52) then
        if operand1(51 downto 0) = zero(51 downto 0) then
          in1_zero <= '1';
        else
          in1_nstd <= '1';
        end if;
      end if;
    else
      if operand0(30 downto 23) = zero(30 downto 23) then
        if operand0(22 downto 0) = zero(22 downto 0) then
          in0_zero <= '1';
        else
          in0_nstd <= '1';
        end if;
      end if;
      if operand1(30 downto 23) = zero(30 downto 23) then
        if operand1(22 downto 0) = zero(22 downto 0) then
          in1_zero <= '1';
        else
          in1_nstd <= '1';
        end if;
      end if;      
    end if;
  end process zero_nstd_detect;

  -- NaN and Inf Detection
  nan_inf_detect: process (operand0, operand1, double)
  begin  -- process nan_inf_detect
    in0_inf <= '0';
    in1_inf <= '0';
    in0_NaN <= '0';
    in1_NaN <= '0';
    in0_SNaN <= '0';
    in1_SNaN <= '0';
    if double = '1' then
      if operand0(62 downto 52) = "11111111111" then
        if operand0(51 downto 0) = zero(51 downto 0) then
          in0_inf <= '1';
        elsif operand0(51) = '1' then
          in0_NaN <= '1';
        else
          in0_SNaN <= '1';
        end if;
      end if;
      if operand1(62 downto 52) = "11111111111" then
        if operand1(51 downto 0) = zero(51 downto 0) then
          in1_inf <= '1';
        elsif operand1(51) = '1' then
          in1_NaN <= '1';
        else
          in1_SNaN <= '1';
        end if;
      end if;
    else
      if operand0(30 downto 23) = "11111111" then
        if operand0(22 downto 0) = zero(22 downto 0) then
          in0_inf <= '1';
        elsif operand0(22) = '1' then
          in0_NaN <= '1';
        else
          in0_SNaN <= '1';
        end if;
      end if;
      if operand1(30 downto 23) = "11111111" then
        if operand1(22 downto 0) = zero(22 downto 0) then
          in1_inf <= '1';
        elsif operand1(22) = '1' then
          in1_NaN <= '1';
        else
          in1_SNaN <= '1';
        end if;
      end if;      
    end if;
  end process nan_inf_detect;

  sdmu_input: process (double, operand0, man0_prenorm, operand1, man1_prenorm)
  begin  -- process sdmu_input
    if double = '1' then
      sdmu_in0 <= operand0(63 downto 52) & man0_prenorm;
      sdmu_in1 <= operand1(63 downto 52) & man1_prenorm;
    else
      sdmu_in0 <= operand0(63 downto 23) & man0_prenorm(51 downto 29);
      sdmu_in1 <= operand1(63 downto 23) & man1_prenorm(51 downto 29);
    end if;
  end process sdmu_input;
  sdmu_1: sdmu
    port map (
      clk      => clk,
      rst      => rst,
      start    => start,
      opc      => opc,
      flush    => sdmu_flush,
      in0      => sdmu_in0,
      in1      => sdmu_in1,
      man0_ldz => man0_ldz,
      man1_ldz => man1_ldz,
      in0_zero => in0_zero,
      in1_zero => in1_zero,
      in0_nstd => in0_nstd,
      in1_nstd => in1_nstd,
      in0_inf  => in0_inf,
      in1_inf  => in1_inf,
      in0_NaN  => in0_NaN,
      in1_NaN  => in1_NaN,
      in0_SNaN => in0_SNaN,
      in1_SNaN => in1_SNaN,
      round    => round,
      result   => sdmu_out,
      flags    => sdmu_flags);


  asu_in0 <= operand0;
  asu_in1 <= operand1;

  asu_1: asu
    port map (
      clk      => clk,
      rst      => rst,
      double   => asu_double,
      add      => add,
      sub      => sub,
      itofp    => itofp,
      fptoi    => fptoi,
      fptornd  => fptornd,
      fptofp   => fptofp,
      cmp      => cmp,
      cmpe     => cmpe,
      absv     => absv,
      neg      => neg,
      mov      => mov,
      round    => round,
      in0      => asu_in0,
      in1      => asu_in1,
      man0_ldz => man0_ldz,
      man1_ldz => man1_ldz,
      in0_zero => in0_zero,
      in1_zero => in1_zero,
      in0_nstd => in0_nstd,
      in1_nstd => in1_nstd,
      in0_inf  => in0_inf,
      in1_inf  => in1_inf,
      in0_NaN  => in0_NaN,
      in1_NaN  => in1_NaN,
      in0_SNaN => in0_SNaN,
      in1_SNaN => in1_SNaN,
      result   => asu_result,
      cc       => asu_cc,
      flags    => asu_flags);


end rtl;
