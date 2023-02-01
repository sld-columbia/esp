-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sldfpc_wreg
-- File:	sldfpc_wreg.vhd
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

entity sldfpc_wreg is

  port (
    holdn               : in  std_ulogic;
    flush               : in  std_ulogic;
    cnt_wb              : in  std_logic_vector(1 downto 0);

    cpins_wb            : in  cpins_type;
    rd_wb               : in  std_logic_vector(4 downto 0);
    rdd_wb              : in  std_ulogic;
    wreg_wb             : in  std_ulogic;
    wrcc_wb             : in  std_ulogic;
    acsr_wb             : in  std_ulogic;

    fpu_outbuf_wb       : in  fpu_outbuf_type;
    rdy_wb              : in  std_ulogic;
    lddata_wb           : in  std_logic_vector(63 downto 0);

    debug               : in  fpc_debug_in_type;

    rfi1_wraddr         : out std_logic_vector(3 downto 0);
    rfi1_wrdata         : out std_logic_vector(31 downto 0);
    rfi1_wren           : out std_ulogic;
    rfi2_wraddr         : out std_logic_vector(3 downto 0);
    rfi2_wrdata         : out std_logic_vector(31 downto 0);
    rfi2_wren           : out std_ulogic;

    valid_wb        : out std_ulogic);

end sldfpc_wreg;


architecture rtl of sldfpc_wreg is

  signal dbg_w1addr, dbg_w2addr : std_logic_vector(3 downto 0);
  signal dbg_wren1, dbg_wren2 : std_ulogic;
  signal dbg_wdata : std_logic_vector(31 downto 0);

begin  -- rtl

  write_rf: process (holdn, flush, cnt_wb, cpins_wb, rd_wb,
                     rdd_wb, wreg_wb, wrcc_wb, acsr_wb, fpu_outbuf_wb, rdy_wb,
                     lddata_wb, debug.enable, dbg_wdata, dbg_wren1, dbg_wren2,
                     dbg_w1addr, dbg_w2addr)
    variable dst : integer range 31 downto 0;
    variable dstp1 : integer range 31 downto 0;
    variable wrdata1 : std_logic_vector(31 downto 0);
    variable wrdata2 : std_logic_vector(31 downto 0);
    variable wraddr : std_logic_vector(3 downto 0);
    variable wren1, wren2 : std_ulogic;
    variable fsr_valid : std_ulogic;
  begin  -- process write_rf
    dst := conv_integer(rd_wb);
    dstp1 := conv_integer(rd_wb(4 downto 1) & '1');
    wraddr := rd_wb(4 downto 1);
    wrdata1 := (others => '0');
    wrdata2 := (others => '0');
    wren1 := '0';
    wren2 := '0';
    fsr_valid := '0';

    if holdn = '1' and flush = '0' then
      if cpins_wb = load and acsr_wb = '0' then
        if rdd_wb = '0' then
          if rd_wb(0) = '0' then
            wrdata1 := lddata_wb(31 downto 0);
            wren1 := '1';
          else
            wrdata2 := lddata_wb(31 downto 0);
            wren2 := '1';
          end if;
        elsif cnt_wb = "01" then
          wrdata1 := lddata_wb(63 downto 32);
          wrdata2 := lddata_wb(31 downto 0);
          wren1 := '1';
          wren2 := '1';
        end if;
      elsif cpins_wb = load and acsr_wb = '1' then
        fsr_valid := '1';
      elsif cpins_wb = fpop and wreg_wb = '1' and rdy_wb = '1' then
        if rdd_wb = '0' then
          if rd_wb(0) = '0' then
            wrdata1 := fpu_outbuf_wb.res(31 downto 0);
            wren1   := '1';
          else
            wrdata2 := fpu_outbuf_wb.res(31 downto 0);
            wren2   := '1';
          end if;
        else
          wrdata1 := fpu_outbuf_wb.res(63 downto 32);
          wrdata2 := fpu_outbuf_wb.res(31 downto 0);
          wren1 := '1';
          wren2 := '1';
        end if;
      elsif cpins_wb = fpop and wrcc_wb = '1' and rdy_wb = '1' then
        fsr_valid := '1';
      end if;
    end if;

    if debug.enable = '1' then
      rfi1_wraddr      <= dbg_w1addr;
      rfi1_wrdata      <= dbg_wdata;
      rfi1_wren        <= dbg_wren1;
      rfi2_wraddr      <= dbg_w2addr;
      rfi2_wrdata      <= dbg_wdata;
      rfi2_wren        <= dbg_wren2;
    else
      rfi1_wraddr      <= wraddr;
      rfi1_wrdata      <= wrdata1;
      rfi1_wren        <= wren1;
      rfi2_wraddr      <= wraddr;
      rfi2_wrdata      <= wrdata2;
      rfi2_wren        <= wren2;
    end if;

    valid_wb <= wren1 or wren2;
   
  end process write_rf;


    -- Debug
  dbg_wdata <= debug.data;
  dbg_w1addr <= debug.addr(4 downto 1);
  dbg_w2addr <= debug.addr(4 downto 1);
  dbg_wren1 <= debug.write and (not debug.addr(0)) and (not debug.fsr);
  dbg_wren2 <= debug.write and debug.addr(0) and (not debug.fsr);

end rtl;
