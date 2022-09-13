-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifer: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.ariane_esp_pkg.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.jtag_pkg.all;


entity jtag_apb_slv_config is
  generic (
    lpindex : integer range 0 to 2 := 0;
    DEF_TMS : std_logic_vector(31 downto 0) := (others => '0')) ;
  port (
    rst      : in  std_ulogic;
    main_clk : in  std_logic;
    apbi     : in  apb_slv_in_type;
    apbo     : out apb_slv_out_type;
    apbreq   : in  std_logic;
    out_p    : out std_logic_vector(31 downto 0));
end jtag_apb_slv_config;


architecture rtl of jtag_apb_slv_config is

  constant reg_a2j_pindex : integer range 0 to NAPBSLV - 1 := 0;
  constant reg_a2j_paddr  : integer range 0 to 4095        := 16#200#;
  constant reg_a2j_pmask  : integer range 0 to 4095        := 16#FFF#;
  signal this_paddr, this_pmask : integer range 0 to 4095;
  signal this_pirq              : integer range 0 to 15;
  signal this_pconfig : apb_config_type;

begin

  this_paddr <= reg_a2j_paddr + lpindex;
  this_pmask <= reg_a2j_pmask;
  this_pirq  <= 0;

  this_pconfig(0) <= ahb_device_reg (VENDOR_SLD, 0, 0, 0, 0);
  this_pconfig(1) <= apb_iobar(this_paddr, this_pmask);
  this_pconfig(2) <= (others => '0');

  jtag_apb_slv0 : jtag_apb_slv
    generic map (
      pindex => lpindex,
      DEF_TMS => DEF_TMS
      )                      --2
    port map (
      clk     => main_clk,
      rstn    => rst,
      pconfig => this_pconfig,
      apbi    => apbi,
      apbo    => apbo,
      apbreq  => apbreq,
      out_p   => out_p
    );

end;
