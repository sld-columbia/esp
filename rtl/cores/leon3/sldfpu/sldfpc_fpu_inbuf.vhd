-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sldfpc_fpu_inbuf
-- File:	sldfpc_fpu_inbuf.vhd
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

entity sldfpc_fpu_inbuf is
  
  generic (
    bufsize_lg : integer := 2);

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
  
end sldfpc_fpu_inbuf;


architecture rtl of sldfpc_fpu_inbuf is

  constant bufsize : integer := 2**bufsize_lg;

  type fpu_inbuf_array is array (0 to bufsize - 1) of fpu_inbuf_type;
  signal fpu_buf : fpu_inbuf_array;

  signal cnt : integer range 0 to bufsize;
  signal next_cnt : integer range 1 to bufsize + 1;
  signal prev_cnt : integer range -1 to bufsize - 1;
  signal inc, equ, dec : std_ulogic;

  signal fpop_in : fpu_inbuf_type;
  signal fpop_ready : std_ulogic;
  signal allow_seq_fpop : std_ulogic;
  signal allow_pip_fpop : std_ulogic;
  
  signal current_state, next_state : fpu_inbuf_state_type;

  type usage_mask_array is array (0 to bufsize - 1) of std_logic_vector(31 downto 0);
  signal inuse_mask : usage_mask_array;
  signal inuse_mask_or : std_logic_vector(31 downto 0);
  signal dst_mask : usage_mask_array;
  signal dst_mask_and : std_logic_vector(31 downto 0);
  signal fsr_inuse_or : std_ulogic;
  signal fsr_dst : std_logic_vector(0 to bufsize - 1);
  signal fsr_dst_and : std_ulogic;

begin  -- rtl

  -----------------------------------------------------------------------------
  -- Input from decode stage
  -----------------------------------------------------------------------------
  -- Build fpop_in 
  fpop_in.id    <= opid_d;
  fpop_in.ll    <= '1' when opc_d(8 downto 2) = "0001010" or opc_d(8 downto 2) = "0010011" else '0';
  fpop_in.opc   <= opc_d;
  fpop_in.rs1   <= rs1_d;
  fpop_in.rs2   <= rs2_d;
  fpop_in.rs1d  <= rs1d_d;
  fpop_in.rs2d  <= rs2d_d;
  fpop_in.rreg1 <= rreg1_d;
  fpop_in.rreg2 <= rreg2_d;
  fpop_in.rd    <= rd_d;
  fpop_in.rdd   <= rdd_d;
  fpop_in.wreg  <= wreg_d;
  fpop_in.wrcc  <= wrcc_d;

  -----------------------------------------------------------------------------
  -- Back pressure from access stage (FPU)
  -----------------------------------------------------------------------------
  allow_pip_fpop <= '1' when allow(1 downto 0) = "11" else '0';
  allow_seq_fpop <= '1' when allow(2) = '1' else '0';

  -----------------------------------------------------------------------------
  -- Output to access stage (with feedback for decode)
  -----------------------------------------------------------------------------
  fpu_inbuf_state_a <= current_state;
  fpu_inbuf_a <= fpu_buf(0);
  fpu_inbuf_next_a <= fpu_buf(1);
  rf_inuse_mask_a <= inuse_mask_or;
  rf_dst_mask_a <= dst_mask_and;
  rf_dst_mask_next_a <= dst_mask(0);
  fsr_inuse_a <= fsr_inuse_or;
  fsr_dst_a <= fsr_dst_and;

  -----------------------------------------------------------------------------
  -- Buffer: when empty register fpu_buf(0) is d/a register
  -----------------------------------------------------------------------------
  
  update_count: process (clk, rst)
  begin  -- process update_count
    if rst = '0' then                   -- asynchronous reset (active low)
      fpu_buf       <= (others => fpu_inbuf_none);
      cnt           <= 0;
      current_state <= empty;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if holdn = '1' then

        if  inc = '1' and current_state /= full then
            cnt <= next_cnt;
            fpu_buf(cnt) <= fpop_in;

        elsif equ = '1' then
          cnt <= cnt;
          for i in 0 to bufsize - 2 loop
            if i < cnt - 1 then
              fpu_buf(i) <= fpu_buf(i + 1);
            end if;
          end loop;  -- i
          fpu_buf(cnt - 1) <= fpop_in;

        elsif dec = '1' and current_state /= empty then
          cnt <= prev_cnt;
          for i in 0 to bufsize - 2 loop
            if i < cnt - 1 then
              fpu_buf(i) <= fpu_buf(i + 1);
            end if;
          end loop;  -- i
          fpu_buf(cnt - 1) <= fpu_inbuf_none;
        end if;

        current_state <= next_state;

        if flush = '1' then
          fpu_buf       <= (others => fpu_inbuf_none);
          cnt           <= 0;
          current_state <= empty;
        end if;

      end if;
    end if;
  end process update_count;

  next_cnt <= cnt + 1;
  prev_cnt <= cnt - 1;


  -----------------------------------------------------------------------------
  -- is Fpop, currently in fpu_buf(0), ready?
  -----------------------------------------------------------------------------
  fpop_rdy: process(fpu_buf(0), rfo11v_a, rfo12v_a, rfo21v_a, rfo22v_a,
                    allow_seq_fpop, allow_pip_fpop)
    variable op1v, op2v : std_ulogic;
    variable ready : std_ulogic;
  begin  -- process incoming_fpop_rdy
    if fpu_buf(0).rreg1 = '1' then
      if fpu_buf(0).rs1d = '1' then
        op1v := rfo11v_a and rfo21v_a;
      else
        if fpu_buf(0).rs1(0) = '0' then
          op1v := rfo11v_a;
        else
          op1v := rfo21v_a;
        end if;
      end if;
    else
      op1v := '1';
    end if;

    if fpu_buf(0).rreg2 = '1' then
      if fpu_buf(0).rs2d = '1' then
        op2v := rfo12v_a and rfo22v_a;
      else
        if fpu_buf(0).rs2(0) = '0' then
          op2v := rfo12v_a;
        else
          op2v := rfo22v_a;
        end if;
      end if;
    else
      op2v := '1';
    end if;
    
    ready := op1v and op2v;

    if fpu_buf(0).ll = '1' then
      fpop_ready <= ready and allow_seq_fpop;
    else
      fpop_ready <= ready and allow_pip_fpop;
    end if;
  end process fpop_rdy;


  fsm: process (current_state, cnt, fpop_ready, cpins_d, allow_seq_fpop, fpu_buf(0).ll, holdn)
    variable inbuf_rdy_a : std_ulogic;
  begin  -- process fsm
    next_state <= current_state;
    inbuf_rdy_a := '0';
    inc <= '0';
    dec <= '0';
    equ <= '0';
    fsr_inuse_or <= (not allow_seq_fpop) or fpu_buf(0).ll;

    case current_state is
      when empty => if cpins_d = fpop then
                      next_state <= first;
                      inc <= '1';
                    end if;

      when first  => if fpop_ready = '1' then
                       inbuf_rdy_a := '1';
                     else
                       fsr_inuse_or <= '1';
                     end if;
                     
                     if cpins_d = fpop then
                       if fpop_ready = '1' then
                         equ <= '1';
                       else
                         next_state <= more;
                         inc <= '1';
                       end if;
                     else
                       if fpop_ready = '1' then
                         next_state <= empty;
                         dec <= '1';
                       end if;
                     end if;

      when more   => fsr_inuse_or <= '1';
                     if fpop_ready = '1' then
                       inbuf_rdy_a := '1';
                     end if;

                     if cpins_d = fpop then
                       if fpop_ready = '1' then
                         equ <= '1';
                       else
                         if cnt = bufsize - 1 then
                           next_state <= full;
                         end if;
                         inc <= '1';
                       end if;
                     else
                       if fpop_ready = '1' then
                         if cnt = 2 then
                           next_state <= first;
                         end if;
                           dec <= '1';
                       end if;
                     end if;

      when full   => fsr_inuse_or <= '1';
                     if fpop_ready = '1' then
                       inbuf_rdy_a := '1';
                       next_state <= more;
                       dec <= '1';
                     end if;

      when others => next_state <= empty;
                     inbuf_rdy_a := '0';
                     inc <= '0';
                     dec <= '0';
                     equ <= '0';

    end case;

    fpu_inbuf_rdy_a <= inbuf_rdy_a and holdn;

  end process fsm;


  usage: for i in 0 to bufsize - 1 generate
    process (fpu_buf(i), cnt)
      variable mask : std_logic_vector(31 downto 0);
      variable rs1, rs2 : integer range 0 to 31;
    begin  -- process
      rs1 := conv_integer(fpu_buf(i).rs1);
      rs2 := conv_integer(fpu_buf(i).rs2);
      mask := (others => '0');

      if i < cnt then
        if fpu_buf(i).rreg1 = '1' then
          mask(rs1) := '1';
          if fpu_buf(i).rs1d = '1' then
            mask(rs1 + 1) := '1';
          end if;    
        end if;
        if fpu_buf(i).rreg2 = '1' then
          mask(rs2) := '1';
          if fpu_buf(i).rs2d = '1' then
            mask(rs2 + 1) := '1';
          end if;    
        end if;
      end if;
      inuse_mask(i) <= mask;
    end process;

    process (fpu_buf(i), cnt)
      variable mask : std_logic_vector(31 downto 0);
      variable rd : integer range 0 to 31;
      variable fsrdst : std_ulogic;
    begin  -- process
      rd := conv_integer(fpu_buf(i).rd);
      mask := (others => '1');
      fsrdst := '1';

      if i < cnt then
        if fpu_buf(i).wrcc = '1' then
          fsrdst := '0';
        end if;
        if fpu_buf(i).wreg = '1' then
          mask(rd) := '0';
          if fpu_buf(i).rdd = '1' then
            mask(rd + 1) := '0';
          end if;    
        end if;
      end if;
      dst_mask(i) <= mask;
      fsr_dst(i) <= fsrdst;
    end process;
  end generate usage;  

  usage_or: process (inuse_mask)
    variable mask : std_logic_vector(31 downto 0);
  begin  -- process usage_or
    mask := (others => '0');
    for i in 0 to bufsize - 1 loop
      mask := mask or inuse_mask(i);
    end loop;  -- i
    inuse_mask_or <= mask;
  end process usage_or;

  dst_and: process (dst_mask, fsr_dst)
    variable mask : std_logic_vector(31 downto 0);
    variable fsrdst : std_ulogic;
  begin  -- process dst_and
    mask := (others => '1');
    fsrdst := '1';
    for i in 0 to bufsize - 1 loop
      mask := mask and dst_mask(i);
      fsrdst := fsrdst and fsr_dst(i);
    end loop;  -- i
    dst_mask_and <= mask;
    fsr_dst_and <= fsrdst;
  end process dst_and;
  
end rtl;
