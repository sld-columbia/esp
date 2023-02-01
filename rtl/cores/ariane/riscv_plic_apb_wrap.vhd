-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.stdlib.all;
use work.amba.all;
use work.ariane_esp_pkg.all;

entity riscv_plic_apb_wrap is

  generic (
    pindex    : integer := 2;
    pconfig   : apb_config_type;
    NHARTS    : integer := 1;
    NIRQ_SRCS : integer := 30);
  port (
    clk         : in  std_ulogic;
    rstn        : in  std_ulogic;
    irq_sources : in  std_logic_vector(NIRQ_SRCS - 1 downto 0);
    irq         : out std_logic_vector(NHARTS * 2 - 1 downto 0);
    apbi        : in  apb_slv_in_type;
    apbo        : out apb_slv_out_type;
    pready      : out std_ulogic;
    pslverr     : out std_ulogic);

end entity riscv_plic_apb_wrap;

architecture rtl of riscv_plic_apb_wrap is

  component riscv_plic_wrap is
    generic (
      NHARTS    : integer;
      NIRQ_SRCS : integer);
    port (
      clk          : in  std_ulogic;
      rstn         : in  std_ulogic;
      irq_sources  : in  std_logic_vector(NIRQ_SRCS - 1 downto 0);
      irq          : out std_logic_vector(NHARTS * 2 - 1 downto 0);
      plic_penable : in  std_ulogic;
      plic_pwrite  : in  std_ulogic;
      plic_paddr   : in  std_logic_vector(31 downto 0);
      plic_psel    : in  std_ulogic;
      plic_pwdata  : in  std_logic_vector(31 downto 0);
      plic_prdata  : out std_logic_vector(31 downto 0);
      plic_pready  : out std_ulogic;
      plic_pslverr : out std_ulogic);
  end component riscv_plic_wrap;

  signal plic_penable : std_ulogic;
  signal plic_pwrite  : std_ulogic;
  signal plic_paddr   : std_logic_vector(31 downto 0);
  signal plic_psel    : std_ulogic;
  signal plic_pwdata  : std_logic_vector(31 downto 0);
  signal plic_prdata  : std_logic_vector(31 downto 0);

  attribute mark_debug : string;

  -- attribute mark_debug of plic_penable : signal is "true";
  -- attribute mark_debug of plic_pwrite : signal is "true";
  -- attribute mark_debug of plic_paddr : signal is "true";
  -- attribute mark_debug of plic_psel : signal is "true";
  -- attribute mark_debug of plic_pwdata : signal is "true";
  -- attribute mark_debug of plic_prdata : signal is "true";
  -- attribute mark_debug of pready : signal is "true";
  -- attribute mark_debug of pslverr : signal is "true";

begin  -- architecture rtl

  plic_penable <= apbi.penable;
  plic_pwrite  <= apbi.pwrite;
  plic_paddr   <= apbi.paddr and X"0fffffff";
  plic_psel    <= apbi.psel(pindex);
  plic_pwdata  <= apbi.pwdata;

  apbo.prdata <= plic_prdata;

  -- Unused outputs
  apbo.pirq    <= (others => '0');
  apbo.pconfig <= pconfig;
  apbo.pindex  <= pindex;


  riscv_plic_wrap_1 : riscv_plic_wrap
    generic map (
      NHARTS    => NHARTS,
      NIRQ_SRCS => NIRQ_SRCS)
    port map (
      clk          => clk,
      rstn         => rstn,
      irq_sources  => irq_sources,
      irq          => irq,
      plic_penable => plic_penable,
      plic_pwrite  => plic_pwrite,
      plic_paddr   => plic_paddr,
      plic_psel    => plic_psel,
      plic_pwdata  => plic_pwdata,
      plic_prdata  => plic_prdata,
      plic_pready  => pready,
      plic_pslverr => pslverr);

end architecture rtl;
