-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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


entity jtag_apb_config is
  generic (
    DEF_TILE : std_logic_vector(31 downto 0) := (others => '0');
    DEF_TMS : std_logic_vector(31 downto 0) := (others => '0'));
  port (
    rst   : in  std_ulogic;
    main_clk  : in  std_ulogic;
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type;
    out_p : out std_logic_vector(31 downto 0);
    out_p1 : out std_logic_vector(31 downto 0));

end;


architecture rtl of jtag_apb_config is

  constant CFG_APBADDR_FP    : integer := 16#D00#;
  constant ahb2apb_hmask_fp  : integer := 16#FFE#;
  constant ahb2apb_hindex_fp : integer := 1;

  constant apb_slv_mask : std_logic_vector(0 to NAPBSLV - 1) := (
    0      => '1',                      --2
    1      => '1',                      --2
    -- 2      => '1',                      --2
    others => '0');

-- APB BUS
  signal apbi : apb_slv_in_type;
  signal apbo : apb_slv_out_vector;
  signal apbo0 : apb_slv_out_type;
  signal apbo1 : apb_slv_out_type;
  signal ack_r : std_logic;
  signal ack2apb_r, apbreq : std_logic;

begin

  apb_ctrl_norm : patient_apbctrl       -- AHB/APB bridge
    generic map
    (hindex     => ahb2apb_hindex_fp,
     haddr      => CFG_APBADDR_FP,
     hmask      => ahb2apb_hmask_fp,
     nslaves    => NAPBSLV,
     remote_apb => apb_slv_mask)
    port map
    (rst,
     main_clk,
     ahbsi,
     ahbso,
     apbi,
     apbo,
     apbreq,
     ack_r);

  no_pslv_gen : for i in 2 to NAPBSLV - 1 generate
    apbo(i)<=apb_none;
  end generate no_pslv_gen;

  apbo(0)<=apbo0;
  apbo(1)<=apbo1;
  ack_r <= '1';

  tmsregdev : jtag_apb_slv_config
    generic map (
      lpindex => 0,
      DEF_TMS => DEF_TMS)
    port map(
      rst      => rst,
      main_clk => main_clk,
      apbi     => apbi,
      apbo     => apbo0,
      apbreq   => apbreq,
      out_p    => out_p);

  jtag_tileregdev : jtag_apb_slv_config
    generic map (
      lpindex => 1,
      DEF_TMS => DEF_TILE)
    port map(
      rst      => rst,
      main_clk => main_clk,
      apbi     => apbi,
      apbo     => apbo1,
      apbreq   => apbreq,
      out_p    => out_p1);

end;

