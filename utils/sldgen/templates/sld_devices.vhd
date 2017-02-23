------------------------------------------------------------------------------
--  Copyright (C) 2015-2017, System Level Design (SLD) @ Columbia University
-----------------------------------------------------------------------------
-- Package:     sld_devices
-- File:        sld_devices.vhd
-- Authors:     Paolo Mantovani
--              Christian Pilato
-- Description: Defines unique IDs for SLD devices
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on

package sld_devices is

  subtype hlscfg_t is integer range 0 to 1024;

  -- <<hlscfg>>

  subtype vendor_t is integer range 0 to 16#ff#;
  subtype devid_t is integer range 0 to 16#3ff#;
  subtype vdesc_t is string(1 to 24);
  subtype ddesc_t is string(1 to 31);
  type dtable_t is array (0 to 1023) of ddesc_t;
  type vlib_t is record
    vendorid     : vendor_t;
    vendordesc   : vdesc_t;
    device_table : dtable_t;
  end record;
  type device_array is array (0 to 255) of vlib_t;

  constant VENDOR_SLD : vendor_t := 16#EB#;

  constant SLD_POWERCTRL : devid_t := 16#00F#;
  constant SLD_AHBRAM_DP : devid_t := 16#01f#;

  -- <<devid>>

-- pragma translate_off

  constant SLD_DESC : vdesc_t := "Columbia University SLD ";

  constant sld_device_table : dtable_t := (
    SLD_POWERCTRL => "Voltage and Frequency Scaling  ",
    SLD_AHBRAM_DP => "On-chip RAM with dual AHB iface",
    -- <<ddesc>>
    others => "Unknown Device                 ");

  constant sld_lib : vlib_t := (
    vendorid     => VENDOR_SLD,
    vendordesc   => SLD_DESC,
    device_table => sld_device_table
    );

-- pragma translate_on

end;
