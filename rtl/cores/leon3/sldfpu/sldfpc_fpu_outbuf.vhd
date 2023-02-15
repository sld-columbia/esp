-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sldfpc_fpu_outbuf
-- File:	sldfpc_fpu_outbuf.vhd
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


entity sldfpc_fpu_outbuf is

  port (
    rst                 : in  std_ulogic;
    clk                 : in  std_ulogic;
    holdn               : in  std_ulogic;
    flush               : in  std_ulogic;

    rdy                 : in  std_ulogic;                    -- asserted 1 cycle before result
    resid               : in  std_logic_vector(5 downto 0);  -- asserted 1 cycle before result
    result              : in  std_logic_vector(63 downto 0);
    except              : in  std_logic_vector(5 downto 0);
    cc                  : in  std_logic_vector(1 downto 0);

    cpins_wb            : in  cpins_type;
    opid_wb             : in  std_logic_vector(5 downto 0);

    fpu_outbuf_state_wb : out fpu_outbuf_state_type;
    fpu_outbuf_wb       : out fpu_outbuf_type;
    rdy_wb              : out std_ulogic);

end sldfpc_fpu_outbuf;


architecture rtl of sldfpc_fpu_outbuf is

  type fpu_outbuf_array is array (0 to OUTBUF_SIZE - 1) of fpu_outbuf_type;
  signal fpu_outbuf : fpu_outbuf_array;
  signal fpop_res_in : fpu_outbuf_type;

  signal current_state, next_state : fpu_outbuf_state_type;

  signal resid_reg : std_logic_vector(5 downto 0);
  signal rdy_reg : std_ulogic;

  signal bypass : std_ulogic;
  signal cnt : integer range 0 to OUTBUF_SIZE;
  signal next_cnt : integer range 1 to OUTBUF_SIZE + 1;
  signal prev_cnt : integer range -1 to OUTBUF_SIZE - 1;

  signal inc, dec, equ : std_ulogic;

begin  -- rtl

  -- Assign output
  fpu_outbuf_state_wb <= current_state;
  fpu_outbuf_wb <= fpop_res_in when bypass = '1' else fpu_outbuf(0);
  rdy_wb <= rdy_reg  and (not flush) when bypass = '1' else not flush;
  
  -- Incoming result
  fpop_res_in.id  <= resid_reg;
  fpop_res_in.res <= result;
  fpop_res_in.exc <= except;
  fpop_res_in.cc  <= cc;

  -- Resid is asserted 1 cycle in advance, therefore we must deskew.
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      rdy_reg <= '0';
      resid_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if flush = '1' then
        rdy_reg <= '0';
        resid_reg <= (others => '0');
      else
        rdy_reg <= rdy;
        resid_reg <= resid;
      end if;
    end if;
  end process;

  update_state: process (clk, rst)
  begin  -- process update_state
    if rst = '0' then                  -- asynchronous reset (active low)
      current_state <= empty;
      cnt <= 0;
      fpu_outbuf    <= (others => fpu_outbuf_none);
    elsif clk'event and clk = '1' then  -- rising clock edge
      current_state <= next_state;

      if inc = '1' then
        fpu_outbuf(cnt) <= fpop_res_in;
        cnt <= next_cnt;

      elsif equ = '1' then
        cnt <= cnt;
        for i in 0 to OUTBUF_SIZE - 2 loop
          if i < cnt - 1 then
            fpu_outbuf(i) <= fpu_outbuf(i + 1);
          end if;
        end loop;  -- i
        fpu_outbuf(cnt - 1) <= fpop_res_in;

      elsif dec = '1' then
        cnt <= prev_cnt;
        for i in 0 to OUTBUF_SIZE - 2 loop
          if i < cnt - 1 then
            fpu_outbuf(i) <= fpu_outbuf(i + 1);
          end if;
        end loop;  -- i
        fpu_outbuf(cnt - 1) <= fpu_outbuf_none;

      end if;
      
      if flush = '1' then
          fpu_outbuf    <= (others => fpu_outbuf_none);
          current_state <= empty;
          cnt <= 0;
      end if;
    end if;
  end process update_state;

  next_cnt <= cnt + 1;
  prev_cnt <= cnt - 1;
  
  sm: process (holdn, current_state, rdy_reg, cpins_wb, opid_wb)
  begin  -- process sm

    next_state <= current_state;
    bypass <= '0';
    inc <= '0';
    equ <= '0';
    dec <= '0';
    
    case current_state is
      -- TODO: check if opid test is needed... it shouldn't
      when empty => bypass <= '1';
                    if rdy_reg = '1' then
                      if cpins_wb /= fpop or holdn = '0' then
                        inc <= '1';
                        next_state <= pend1;
                      end if;
                    end if;

      when pend1 => if rdy_reg = '1' then
                      if cpins_wb /= fpop or holdn = '0' then
                        inc <= '1';
                        next_state <= pend2;
                      else
                        equ <= '1';
                      end if;
                    else
                      if cpins_wb = fpop and holdn = '1' then
                        dec <= '1';
                        next_state <= empty;
                      end if;
                    end if;


      when pend2 => if rdy_reg = '1' then
                      if cpins_wb /= fpop or holdn = '0' then
                        inc <= '1';
                        next_state <= pend3;
                      else
                        equ <= '1';
                      end if;
                    else
                      if cpins_wb = fpop and holdn = '1' then
                        dec <= '1';
                        next_state <= pend1;
                      end if;
                    end if;

      when pend3 => if rdy_reg = '1' then
                      if cpins_wb /= fpop or holdn = '0' then
                        inc <= '1';
                        next_state <= pend4;
                      else
                        equ <= '1';
                      end if;
                    else
                      if cpins_wb = fpop and holdn = '1' then
                        dec <= '1';
                        next_state <= pend2;
                      end if;
                    end if;

      when pend4 => if rdy_reg = '1' then
                      equ <= '1';
                    else
                      if cpins_wb = fpop and holdn = '1' then
                        dec <= '1';
                        next_state <= pend3;
                      end if;
                    end if;

      when others => next_state <= empty;
                     bypass <= '1';

    end case;
  end process sm;

end rtl;
