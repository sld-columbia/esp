------------------------------------------------------------------------------
--  This file is part of an extension to the GRLIB VHDL IP library.
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
--
--  GRLIP is a Copyright (C) 2008 - 2013, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity:  dvfs_fsm
-- File:    dvfs_fsm.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description:	Accelerator interface to NoC with APB slave port
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.sldcommon.all;
use work.nocpackage.all;
use work.tile.all;

use work.acctypes.all;

entity dvfs_top is

  generic (
    tech : integer := virtex7;
    extra_clk_buf : integer range 0 to 1 := 1;
    pindex                : integer                            := 0;
    paddr                 : integer                            := 0;
    pmask                 : integer                            := 16#fff#;
    revision              : integer                            := 0;
    devid                 : amba_device_type                   := 16#001#);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_ulogic;
    refclk    : in  std_ulogic;
    pllbypass : in  std_ulogic;
    pllclk    : out std_ulogic;
    apbi      : in  apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    acc_idle  : in  std_ulogic;
    traffic   : in  std_ulogic;
    burst     : in  std_ulogic;
    --Monitor signals
    mon_dvfs  : out monitor_dvfs_type;
    vdd_ivr   : in std_ulogic;
    vref      : out std_ulogic);

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
      mon_dvfs      => mon_dvfs,
      vdd_ivr       => VDD_IVR,
      vref          => VREF);

  tile_dvfs_1: tile_dvfs
    generic map (
      tech   => tech,
      pindex => pindex,
      paddr  => paddr,
      pmask  => pmask)
    port map (
      rst           => rst,
      clk           => clk,
      apbi          => apbi,
      apbo          => apbo,
      clear_command => clear_command,
      sample_status => sample_status,
      voltage       => voltage,
      frequency     => frequency,
      qadc          => qadc,
      bank          => bank);

end rtl;
