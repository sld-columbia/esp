-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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
  constant SLD_ESPLINK   : devid_t := 16#017#;
  constant SLD_AHBRAM_DP : devid_t := 16#01f#;
  constant SLD_L2_CACHE  : devid_t := 16#020#;
  constant SLD_LLC_CACHE : devid_t := 16#021#;
  constant SLD_MST_PROXY : devid_t := 16#022#;
  constant SLD_SLM       : devid_t := 16#023#;
  constant SLD_TILE_CSR  : devid_t := 16#024#;
  constant SLD_ESP_INIT  : devid_t := 16#025#;
  constant SLD_EXTMEM_LINK : devid_t := 16#026#;
  --constant SLD_PRC         : devid_t := 16#031#;
  -- <<devid>>

  constant VENDOR_SIFIVE : vendor_t := 16#EC#;

  constant SIFIVE_PLIC0  : devid_t := 16#001#;
  constant SIFIVE_CLINT0 : devid_t := 16#002#;


  constant VENDOR_LOWRISC : vendor_t := 16#ED#;

  constant LOWRISC_IBEX_SMALL : devid_t := 16#001#;
  constant LOWRISC_IBEX_TIMER : devid_t := 16#002#;


  constant VENDOR_UIUC      : vendor_t := 16#EE#;

  constant UIUC_SPANDEX_L2  : devid_t := 16#020#;
  constant UIUC_SPANDEX_LLC : devid_t := 16#021#;

-- pragma translate_off

  constant SLD_DESC : vdesc_t := "Columbia University SLD ";

  constant sld_device_table : dtable_t := (
    SLD_POWERCTRL   => "Voltage and Frequency Scaling  ",
    SLD_ESPLINK     => "ESP SoC Link                   ",
    SLD_AHBRAM_DP   => "On-chip RAM with dual AHB iface",
    SLD_L2_CACHE    => "L2 cache                       ",
    SLD_LLC_CACHE   => "LLC cache                      ",
    SLD_MST_PROXY   => "bus-master proxy               ",
    SLD_SLM         => "Shared-local memory            ",
    SLD_TILE_CSR    => "ESP tile ctrl & stats          ",
    SLD_ESP_INIT    => "ESP self init module           ",
    SLD_EXTMEM_LINK => "FPGA external memory link      ",
    -- <<ddesc>>
    others => "Unknown Device                 ");

  constant sld_lib : vlib_t := (
    vendorid     => VENDOR_SLD,
    vendordesc   => SLD_DESC,
    device_table => sld_device_table
    );

  constant SIFIVE_DESC : vdesc_t := "SiFive                  ";

  constant sifive_device_table : dtable_t := (
    SIFIVE_PLIC0  => "Platform Level Int. Controller ",
    SIFIVE_CLINT0 => "RISC-V CPU Local Interruptor   ",
    others        => "Unknown Device                 ");

  constant sifive_lib : vlib_t := (
    vendorid     => VENDOR_SIFIVE,
    vendordesc   => SIFIVE_DESC,
    device_table => sifive_device_table
    );


  constant LOWRISC_DESC : vdesc_t := "Lowrisc                 ";

  constant lowrisc_device_table : dtable_t := (
    LOWRISC_IBEX_SMALL  => "RISC-V IBEX (small,  RV32IMC)  ",
    LOWRISC_IBEX_TIMER  => "IBEX timer                     ",
    others              => "Unknown Device                 ");

  constant lowrisc_lib : vlib_t := (
    vendorid     => VENDOR_LOWRISC,
    vendordesc   => LOWRISC_DESC,
    device_table => lowrisc_device_table
    );

  constant UIUC_DESC : vdesc_t := "University of Illinois  ";

  constant uiuc_device_table : dtable_t := (
    UIUC_SPANDEX_L2    => "Spandex L2 cache               ",
    UIUC_SPANDEX_LLC   => "Spandex LLC cache              ",
    others => "Unknown Device                 ");

  constant uiuc_lib : vlib_t := (
    vendorid     => VENDOR_UIUC,
    vendordesc   => UIUC_DESC,
    device_table => uiuc_device_table
    );

  constant VENDOR_XIL       : vendor_t := 16#EF#;
  constant XILINX_PRC       : devid_t  := 16#031#;

  constant XILINX_DESC : vdesc_t := "Xilinx                  ";

  constant xil_device_table : dtable_t := (
    XILINX_PRC     => "Reconfiguration Controller     ",
    others => "Unknown Device                 ");

  constant xilinx_dev_lib : vlib_t := (
    vendorid    => VENDOR_XIL,
    vendordesc  => XILINX_DESC,
    device_table => xil_device_table
    );

-- pragma translate_on

end;
