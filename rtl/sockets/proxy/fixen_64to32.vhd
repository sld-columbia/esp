-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- NoC to DMA adapter for 32-bits big-endian systems (e.g. Leon3) and
-- accelerators operating on 64-bits data.
--
-- This module has a bypass pin that disables the logic when the acceleraotr is
-- requesting transactions for data that are smaller than a double word.
-- The bypass is always active for little-endian systems, which require no
-- alteration to the DMA transfers.
--
-- Note that this logic can only correct transactions for which the
-- data token word width is exactly two times the width of the NoC
-- link. Any other scenario is not supported at the moment. This means
-- that for LEON3 based instances of ESP accelerators can only process
-- data types with a width that is at most 64 bits.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.esp_global.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;

use work.esp_acc_regmap.all;

entity fixen_64to32 is

  port (
    clk         : in  std_ulogic;
    rstn        : in  std_ulogic;
    bypass_i    : in  std_ulogic;
    in_data_i   : in  std_logic_vector(ARCH_BITS - 1 downto 0);
    in_valid_i  : in  std_ulogic;
    in_ready_o  : out std_ulogic;
    out_data_o  : out std_logic_vector(ARCH_BITS - 1 downto 0);
    out_valid_o : out std_ulogic;
    out_ready_i : in  std_ulogic);

end entity fixen_64to32;


architecture rtl of fixen_64to32 is

  signal in_data   : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal in_valid  : std_ulogic;
  signal in_ready  : std_ulogic;
  signal out_data  : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal out_valid : std_ulogic;
  signal out_ready : std_ulogic;

  -- shadow selector
  signal sel : std_ulogic;
  signal toggle : std_ulogic;
  -- shadow data
  signal shadow : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal wen : std_ulogic;
  -- shadow valid
  signal valid : std_ulogic;
  signal set : std_ulogic;
  signal reset : std_ulogic;
  -- shadow ready
  signal ready : std_ulogic;

begin  -- architecture rtl

  main_io: process (bypass_i, out_ready_i, in_data_i, in_valid_i, in_ready, out_data, out_valid) is
    -- Writes internal signals in_data, in_valid, out_ready
    -- Writes output ports in_read_o, out_data_o, out_valid_o
  begin  -- process main_io

    if ARCH_BITS /= 32 or GLOB_CPU_AXI /= 0 or bypass_i = '1' then
      -- Ariane little endian or word size smaller than 64 bits
      in_ready_o <= out_ready_i;
      out_data_o <= in_data_i;
      out_valid_o <= in_valid_i;
    else
      in_ready_o <= in_ready;
      out_data_o <= out_data;
      out_valid_o <= out_valid;
    end if;

    out_ready <= out_ready_i;
    in_data <= in_data_i;
    in_valid <= in_valid_i;

  end process main_io;


  -- State
  fixen_state: process (clk, rstn) is
  begin  -- process fixen_state
    if rstn = '0' then                  -- asynchronous reset (active low)
      sel <= '1';
      valid <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if toggle = '1' then
        sel <= not sel;
      end if;

      if wen = '1' then
        shadow <= in_data;
      end if;

      if set = '1' then
        valid <= '1';
      elsif reset = '1' then
        valid <= '0';
      end if;

    end if;
  end process fixen_state;

  -- MUX
  in_ready <= out_ready when sel = '0' else ready;
  out_data <= in_data when sel = '0' else shadow;
  out_valid <= in_valid when sel = '0' else valid;
  toggle <= in_valid and out_ready when sel = '0' else wen;

  -- Control
  wen <= sel and in_valid and out_ready;
  set <= wen;
  reset <= sel and out_ready and (not in_valid);
  ready <= out_ready;

end architecture rtl;
