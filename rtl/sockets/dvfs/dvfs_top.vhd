-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.monitor_pkg.all;
use work.nocpackage.all;
use work.tile.all;

use work.esp_acc_regmap.all;

entity dvfs_top is

  generic (
    tech          : integer              := virtex7;
    extra_clk_buf : integer range 0 to 1 := 1;
    pindex        : integer              := 0);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_ulogic;
    paddr     : in integer;
    pmask     : in integer;
    refclk    : in std_ulogic;
    pllbypass : in std_ulogic;
    pllclk    : out std_ulogic;
    apbi      : in  apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    acc_idle  : in  std_ulogic;
    traffic   : in  std_ulogic;
    burst     : in  std_ulogic;
    --Monitor signals
    mon_dvfs  : out monitor_dvfs_type);

end dvfs_top;

architecture rtl of dvfs_top is

  constant regnum : integer := 23;
  signal voltage : std_logic_vector(31 downto 0);
  signal frequency : std_logic_vector(31 downto 0);
  signal qadc          : std_logic_vector(31 downto 0);
  signal clear_command : std_ulogic;
  signal sample_status : std_ulogic;
  signal bank          : bank_type(0 to MAXREGNUM - 1);


begin  -- rtl

  dvfs_fsm_1: dvfs_fsm
    generic map (
      tech => tech,
      extra_clk_buf => extra_clk_buf)
    port map (
      rst           => rst,
      refclk        => refclk,
      pllbypass     => pllbypass,
      pllclk        => pllclk,
      clear_command => clear_command,
      sample_status => sample_status,
      voltage       => voltage,
      frequency     => frequency,
      qadc          => qadc,
      bank          => bank,
      acc_idle      => acc_idle,
      traffic       => traffic,
      burst         => burst,
      mon_dvfs      => mon_dvfs);

  tile_dvfs_1: tile_dvfs
    generic map (
      tech   => tech,
      pindex => pindex)
    port map (
      rst           => rst,
      clk           => clk,
      paddr         => paddr,
      pmask         => pmask,
      apbi          => apbi,
      apbo          => apbo,
      clear_command => clear_command,
      sample_status => sample_status,
      voltage       => voltage,
      frequency     => frequency,
      qadc          => qadc,
      bank          => bank);

end rtl;
