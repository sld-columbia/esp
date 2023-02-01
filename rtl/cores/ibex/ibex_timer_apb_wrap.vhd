-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.stdlib.all;
use work.amba.all;
use work.ibex_esp_pkg.all;

entity ibex_timer_apb_wrap is

  generic (
    pindex    : integer := 3;
    pconfig   : apb_config_type);
  port (
    clk         : in  std_ulogic;
    rstn        : in  std_ulogic;
    timer_irq   : out std_ulogic;
    apbi        : in  apb_slv_in_type;
    apbo        : out apb_slv_out_type;
    pready      : out std_ulogic;
    pslverr     : out std_ulogic);

end entity ibex_timer_apb_wrap;

architecture rtl of ibex_timer_apb_wrap is

  component ibex_timer_wrap is
    port (
      clk     : in  std_ulogic;
      rstn    : in  std_ulogic;
      penable : in  std_ulogic;
      pwrite  : in  std_ulogic;
      paddr   : in  std_logic_vector(31 downto 0);
      psel    : in  std_ulogic;
      pwdata  : in  std_logic_vector(31 downto 0);
      prdata  : out std_logic_vector(31 downto 0);
      pready  : out std_ulogic;
      pslverr : out std_ulogic;
      timer_irq : out std_ulogic);
  end component ibex_timer_wrap;

  signal penable : std_ulogic;
  signal pwrite  : std_ulogic;
  signal paddr   : std_logic_vector(31 downto 0);
  signal psel    : std_ulogic;
  signal pwdata  : std_logic_vector(31 downto 0);
  signal prdata  : std_logic_vector(31 downto 0);

begin

  penable <= apbi.penable;
  pwrite  <= apbi.pwrite;
  paddr   <= apbi.paddr and X"0fffffff";
  psel    <= apbi.psel(pindex);
  pwdata  <= apbi.pwdata;

  apbo.prdata <= prdata;

  -- Unused outputs
  apbo.pirq    <= (others => '0');
  apbo.pconfig <= pconfig;
  apbo.pindex  <= pindex;

  ibex_timer_wrap_i : ibex_timer_wrap
    port map (
      clk       => clk,
      rstn      => rstn,
      penable   => penable,
      pwrite    => pwrite,
      paddr     => paddr,
      psel      => psel,
      pwdata    => pwdata,
      prdata    => prdata,
      pready    => pready,
      pslverr   => pslverr,
      timer_irq => timer_irq);

end;
