-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;

package ibex_esp_pkg is

  component ibex_ahb_wrap is
    generic (
      hindex     : integer range 0 to NAHBSLV - 1;
      ROMBase    : std_logic_vector(31 downto 0));
    port (
      rstn      : in  std_ulogic;
      clk       : in  std_ulogic;
      HART_ID   : in  std_logic_vector(31 downto 0);
      irq       : in  std_logic_vector(1 downto 0);
      timer_irq : in  std_ulogic;
      ipi       : in  std_ulogic;
      core_idle : out std_ulogic;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type);
  end component ibex_ahb_wrap;

  component ibex_timer_apb_wrap is
    generic (
      pindex  : integer;
      pconfig : apb_config_type);
    port (
      clk       : in  std_ulogic;
      rstn      : in  std_ulogic;
      timer_irq : out std_ulogic;
      apbi      : in  apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      pready    : out std_ulogic;
      pslverr   : out std_ulogic);
  end component ibex_timer_apb_wrap;

end package ibex_esp_pkg;
