-- Copyright (c) 2011-2026 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;

package riscv_interrupt_pkg is

  component riscv_plic_apb_wrap is
    generic (
      pindex    : integer;
      pconfig   : apb_config_type;
      NHARTS    : integer;
      NIRQ_SRCS : integer);
    port (
      clk         : in  std_ulogic;
      rstn        : in  std_ulogic;
      irq_sources : in  std_logic_vector(NIRQ_SRCS - 1 downto 0);
      irq         : out std_logic_vector(NHARTS * 2 - 1 downto 0);
      apbi        : in  apb_slv_in_type;
      apbo        : out apb_slv_out_type;
      pready      : out std_ulogic;
      pslverr     : out std_ulogic);
  end component riscv_plic_apb_wrap;

  component riscv_clint_ahb_wrap is
    generic (
      hindex  : integer;
      hconfig : ahb_config_type;
      NHARTS  : integer);
    port (
      clk         : in  std_ulogic;
      rstn        : in  std_ulogic;
      timer_irq   : out std_logic_vector(NHARTS - 1 downto 0);
      ipi         : out std_logic_vector(NHARTS - 1 downto 0);
      ahbsi       : in  ahb_slv_in_type;
      ahbso       : out ahb_slv_out_type);
  end component riscv_clint_ahb_wrap;

end riscv_interrupt_pkg;
