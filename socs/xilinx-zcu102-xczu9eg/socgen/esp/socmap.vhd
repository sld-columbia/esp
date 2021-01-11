-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

------------------------------------------------------------------------------
--  This file is a configuration file for the ESP NoC-based architecture
-----------------------------------------------------------------------------
-- Package:     socmap
-- File:        socmap.vhd
-- Author:      Paolo Mantovani - SLD @ Columbia University
-- Author:      Christian Pilato - SLD @ Columbia University
-- Description: System address mapping and NoC tiles configuration
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.stdlib.all;
use work.grlib_config.all;
use work.gencomp.all;
use work.amba.all;
use work.sld_devices.all;
use work.devices.all;
use work.misc.all;
use work.leon3.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.allcaches.all;

package socmap is

  constant CFG_FABTECH : integer := virtexup;

  ------ Maximum number of slaves on both HP bus and I/O-bus
  constant maxahbm : integer := NAHBMST;
  constant maxahbs : integer := NAHBSLV;

  -- Arrays of Plug&Play info
  subtype apb_l2_pconfig_vector is apb_config_vector_type(0 to CFG_NL2-1);
  subtype apb_llc_pconfig_vector is apb_config_vector_type(0 to CFG_NLLC-1);
  -- Array of design-point or implementation IDs
  type tile_hlscfg_array is array (0 to CFG_TILES_NUM - 1) of hlscfg_t;
  -- Array of attributes for clock regions
  type domain_type_array is array (0 to 0) of integer;
  -- Array of device IDs
  type tile_device_array is array (0 to CFG_TILES_NUM - 1) of devid_t;
  -- Array of I/O-bus indices
  type tile_idx_array is array (0 to CFG_TILES_NUM - 1) of integer range 0 to NAPBSLV - 1;
  -- Array of attributes for I/O-bus slave devices
  type apb_attribute_array is array (0 to NAPBSLV - 1) of integer;
  -- Array of IRQ line numbers
  type tile_irq_array is array (0 to CFG_TILES_NUM - 1) of integer range 0 to NAHBIRQ - 1;
  -- Array of 12-bit addresses
  type tile_addr_array is array (0 to CFG_TILES_NUM - 1) of integer range 0 to 4095;
  -- Array of flags
  type tile_flag_array is array (0 to CFG_TILES_NUM - 1) of integer range 0 to 1;

  ------ Plug&Play info on HP bus
  -- Leon3 CPU cores
  constant leon3_hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LEON3, 0, LEON3_VERSION, 0),
    others => zero32);

  -- Ibex CPU cores
  constant ibex_hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_LOWRISC, LOWRISC_IBEX_SMALL, 0, 0, 0),
    others => zero32);

  -- JTAG master interface, acting as debug access point
  -- Ethernet master interface, acting as debug access point
  constant eth0_hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_ETHMAC, 0, 0, 0),
    others => zero32);

  -- Enable SGMII controller iff needed
  constant CFG_SGMII : integer range 0 to 1 := 1;

  -- SVGA controller, acting as master on a dedicated bus connecte to the frame buffer
  -- BOOT ROM HP slave
  constant ahbrom_hindex  : integer := 0;
  constant ahbrom_haddr   : integer := 16#000#;
  constant ahbrom_hmask   : integer := 16#fff#;
  constant ahbrom_hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBROM, 0, 0, 0),
    4 => ahb_membar(ahbrom_haddr, '1', '1', ahbrom_hmask),
    others => zero32);
  -- AHB2APB bus bridge slave
  constant CFG_APBADDR : integer := 16#600#;
  constant ahb2apb_hindex : integer := 1;
  constant ahb2apb_haddr : integer := CFG_APBADDR;
  constant ahb2apb_hmask : integer := 16#F00#;
  constant ahb2apb_hconfig : ahb_config_type := (
    0 => ahb_device_reg ( 1, 6, 0, 0, 0),
    4 => ahb_membar(CFG_APBADDR, '0', '0', ahb2apb_hmask),
    others => zero32);

  -- RISC-V CLINT
  constant clint_hindex  : integer := 2;
  constant clint_haddr   : integer := 16#020#;
  constant clint_hmask   : integer := 16#fff#;
  constant clint_hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_SIFIVE, SIFIVE_CLINT0, 0, 0, 0),
    4 => ahb_membar(clint_haddr, '0', '0', clint_hmask),
    others => zero32);

  -- Debug access points proxy index
  constant dbg_remote_ahb_hindex : integer := 3;

  ----  Shared Local Memory
  constant slm_hindex : attribute_vector(0 to 0) := (
    others => 0);
  constant slm_haddr : attribute_vector(0 to 0) := (
    others => 0);
  constant slm_hmask : attribute_vector(0 to 0) := (
    others => 0);
  constant slm_hconfig : ahb_slv_config_vector := (
    others => hconfig_none);

  -- CPU tiles don't need to know how the address space is split across shared
  -- local memory tiles and each CPU should be able to address any region
  -- transparently.
  constant cpu_tile_slm_hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_SLD, SLD_SLM, 0, 0, 0),
    4 => ahb_membar(16#040#, '0', '0', 16#FFF#),
    others => zero32);

  ----  Memory controllers
  -- CPU tiles don't need to know how the address space is split across memory tiles
  -- and each CPU should be able to address any region transparently.
  constant cpu_tile_mig7_hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),
    4 => ahb_membar(16#800#, '1', '1', 16#C00#),
    others => zero32);
  -- Network interfaces and ESP proxies, instead, need to know how to route packets
  constant ddr_hindex : attribute_vector(0 to CFG_NMEM_TILE - 1) := (
    0 => 4,
    others => 0);
  constant ddr_haddr : attribute_vector(0 to CFG_NMEM_TILE - 1) := (
    0 => 16#800#,
    others => 0);
  constant ddr_hmask : attribute_vector(0 to CFG_NMEM_TILE - 1) := (
    0 => 16#C00#,
    others => 0);
  -- Create a list of memory controllers info based on the number of memory tiles
  -- We use the MIG interface from GRLIB, which has a device entry for the 7SERIES
  -- Xilinx FPGAs only, however, we provide a patched version of the IP for the
  -- UltraScale(+) FPGAs. The patched intercace shared the same device ID with the
  -- 7SERIES MIG.
  constant mig7_hconfig : ahb_slv_config_vector := (
    0 => (
      0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),
      4 => ahb_membar(ddr_haddr(0), '1', '1', ddr_hmask(0)),
      others => zero32),
    others => hconfig_none);
  -- On-chip frame buffer (GRLIB)
  constant fb_hindex : integer := 12;
  constant fb_hmask : integer := 16#FFF#;
  constant fb_haddr : integer := CFG_SVGA_MEMORY_HADDR;
  constant fb_hconfig : ahb_config_type := hconfig_none;

  -- HP slaves index / memory map
  constant fixed_ahbso_hconfig : ahb_slv_config_vector := (
    0 => ahbrom_hconfig,
    1 => ahb2apb_hconfig,
    2 => clint_hconfig,
    4 => mig7_hconfig(0),
    12 => fb_hconfig,
    others => hconfig_none);

  -- HP slaves index / memory map for CPU tile
  -- CPUs need to see memory as a single address range
  constant cpu_tile_fixed_ahbso_hconfig : ahb_slv_config_vector := (
    0 => ahbrom_hconfig,
    1 => ahb2apb_hconfig,
    2 => clint_hconfig,
    4 => cpu_tile_mig7_hconfig,
    8 => cpu_tile_slm_hconfig,
    12 => fb_hconfig,
    others => hconfig_none);

  ------ Plug&Play info on I/O bus
  -- UART (GRLIB)
  constant uart_pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_APBUART, 0, 1, CFG_UART1_IRQ),
  1 => apb_iobar(16#001#, 16#fff#),
  2 => (others => '0'));

  -- Interrupt controller (Architecture-dependent)
  -- RISC-V PLIC is using the extended APB address space
  constant irqmp_pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_SIFIVE, SIFIVE_PLIC0, 0, 3, 0),
  1 => apb_iobar(16#000#, 16#000#),
  2 => apb_iobar(16#0C0#, 16#FC0#));

  -- Timer (GRLIB)
  constant gptimer_pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_GPTIMER, 0, 1, CFG_GPT_IRQ),
  1 => apb_iobar(16#003#, 16#fff#),
  2 => (others => '0'));

  -- Ibex Timer
  constant ibex_timer_pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_LOWRISC, LOWRISC_IBEX_TIMER, 0, 1, 0),
  1 => apb_iobar(16#003#, 16#fff#),
  2 => (others => '0'));

  -- ESPLink
  constant esplink_pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_SLD, SLD_ESPLINK, 0, 0, 0),
  1 => apb_iobar(16#004#, 16#fff#),
  2 => (others => '0'));

  -- SVGA controler (GRLIB)
  -- Ethernet MAC (GRLIB)
  constant eth0_pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_ETHMAC, 0, 0, 12),
  1 => apb_iobar(16#800#, 16#f00#),
  2 => (others => '0'));

  constant sgmii0_pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_SGMII, 0, 1, 11),
  1 => apb_iobar(16#010#, 16#ff0#),
  2 => (others => '0'));

  -- CPU DVFS controller
  -- Accelerators' power controllers are mapped to the upper half of their I/O
  -- address space. In the future, each DVFS controller should be assigned to an independent
  -- region of the address space, thus allowing discovery from the device tree.
  constant cpu_dvfs_paddr : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);
  constant cpu_dvfs_pmask : integer := 16#fff#;
  constant cpu_dvfs_pconfig : apb_config_vector_type(0 to 3) := (
    others => pconfig_none);

  -- L2
  -- Accelerator's caches cannot be flushed/reset from I/O-bus
  constant l2_cache_pconfig : apb_l2_pconfig_vector := (
    others => pconfig_none);

  -- LLC
  constant llc_cache_pconfig : apb_llc_pconfig_vector := (
    others => pconfig_none);

  -- ESP Tiles CSRs
  constant csr_t_0_pindex : integer range 0 to NAPBSLV - 1 := 20;
  constant csr_t_0_paddr : integer range 0 to 4095 := 16#900#;
  constant csr_t_0_pmask : integer range 0 to 4095 := 16#FFE#;
  constant csr_t_0_pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_SLD, SLD_TILE_CSR, 0, 0, 0),
  1 => apb_iobar(16#900#, 16#FFE#),
  2 => (others => '0'));

  constant csr_t_1_pindex : integer range 0 to NAPBSLV - 1 := 21;
  constant csr_t_1_paddr : integer range 0 to 4095 := 16#902#;
  constant csr_t_1_pmask : integer range 0 to 4095 := 16#FFE#;
  constant csr_t_1_pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_SLD, SLD_TILE_CSR, 0, 0, 0),
  1 => apb_iobar(16#902#, 16#FFE#),
  2 => (others => '0'));

  constant csr_t_2_pindex : integer range 0 to NAPBSLV - 1 := 22;
  constant csr_t_2_paddr : integer range 0 to 4095 := 16#904#;
  constant csr_t_2_pmask : integer range 0 to 4095 := 16#FFE#;
  constant csr_t_2_pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_SLD, SLD_TILE_CSR, 0, 0, 0),
  1 => apb_iobar(16#904#, 16#FFE#),
  2 => (others => '0'));

  constant csr_t_3_pindex : integer range 0 to NAPBSLV - 1 := 23;
  constant csr_t_3_paddr : integer range 0 to 4095 := 16#906#;
  constant csr_t_3_pmask : integer range 0 to 4095 := 16#FFE#;
  constant csr_t_3_pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_SLD, SLD_TILE_CSR, 0, 0, 0),
  1 => apb_iobar(16#906#, 16#FFE#),
  2 => (others => '0'));

  -- Accelerators
  constant accelerators_num : integer := 0;

  -- I/O bus slaves index / memory map
  constant fixed_apbo_pconfig : apb_slv_config_vector := (
    1 => uart_pconfig,
    2 => irqmp_pconfig,
    3 => gptimer_pconfig,
    4 => esplink_pconfig,
    14 => eth0_pconfig,
    15 => sgmii0_pconfig,
    20 => csr_t_0_pconfig,
    21 => csr_t_1_pconfig,
    22 => csr_t_2_pconfig,
    23 => csr_t_3_pconfig,
    others => pconfig_none);

  ------ Cross reference arrays
  -- Get CPU ID from tile ID
  constant tile_cpu_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    1 => 0,
    others => 0);

  -- Get tile ID from CPU ID
  constant cpu_tile_id : attribute_vector(0 to CFG_NCPU_TILE - 1) := (
    0 => 1,
    others => 0);

  -- Get DVFS controller pindex from tile ID
  constant cpu_dvfs_pindex : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);

  -- Get L2 cache ID from tile ID
  constant tile_cache_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);

  -- Get tile ID from L2 cache ID
  constant cache_tile_id : cache_attribute_array := (
    others => 0);

  -- Get L2 pindex from tile ID
  constant l2_cache_pindex : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);

  -- Flag tiles that have a private cache
  constant tile_has_l2 : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    0 => 0,
    1 => 0,
    2 => 0,
    3 => 0,
    others => 0);

  -- Get LLC ID from tile ID
  constant tile_llc_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => -1);

  -- Get tile ID from LLC-split ID
  constant llc_tile_id : attribute_vector(0 to CFG_NMEM_TILE - 1) := (
    others => 0);

  -- Get LLC pindex from tile ID
  constant llc_cache_pindex : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);

  -- Get tile ID from shared-local memory ID ID
  constant slm_tile_id : attribute_vector(0 to 0) := (
    others => 0);

  -- Get shared-local memory tile ID from tile ID
  constant tile_slm_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);

  -- Get tile ID from memory ID
  constant mem_tile_id : attribute_vector(0 to CFG_NMEM_TILE - 1) := (
    0 => 0,
    others => 0);

  -- Get memory tile ID from tile ID
  constant tile_mem_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    0 => 0,
    others => 0);

  -- Get CSR pindex from tile ID
  constant tile_csr_pindex : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    0 => 20,
    1 => 21,
    2 => 22,
    3 => 23,
    others => 0);

  -- Get accelerator ID from tile ID
  constant tile_acc_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);

  -- Get miscellaneous tile ID
  constant io_tile_id : integer := 3;

  -- DMA ID corresponds to accelerator ID for accelerators and nacc for Ethernet
  -- Ethernet must be coherent to avoid flushing private caches every time the
  -- DMA buffer is accessed, but the IP from GRLIB is not coherent. We leverage
  -- LLC-coherent DMA w/ recalls to have Etherent work transparently.
  -- Get DMA ID from tile ID
  constant tile_dma_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    io_tile_id => 0,
    others => -1);

  -- Get tile ID from DMA ID (used for LLC-coherent DMA)
  constant dma_tile_id : dma_attribute_array := (
    0 => io_tile_id,
    others => 0);

  -- Get type of tile from tile ID
  constant tile_type : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    0 => 4,
    1 => 1,
    2 => 0,
    3 => 3,
    others => 0);

  -- Get accelerator's implementation (hlscfg or generic design point) from tile ID
  constant tile_design_point : tile_hlscfg_array := (
    others => 0);

  -- Get accelerator device ID (device tree) from tile ID
  constant tile_device : tile_device_array := (
    others => 0);

  -- Get I/O-bus index line for accelerators from tile ID
  constant tile_apb_idx : tile_idx_array := (
    others => 0);

  -- Get I/O-bus address for accelerators from tile ID
  constant tile_apb_paddr : tile_addr_array := (
    others => 0);

  constant tile_apb_paddr_ext : tile_addr_array := (
    others => 0);

  -- Get I/O-bus address mask for accelerators from tile ID
  constant tile_apb_pmask : tile_addr_array := (
    others => 0);

  constant tile_apb_pmask_ext : tile_addr_array := (
    others => 0);

  -- Get IRQ line for accelerators from tile ID
  constant tile_apb_irq : tile_irq_array := (
    others => 0);

  -- Get IRQ line type for accelerators from tile ID
  -- IRQ line types:
  --     0 : edge-sensitive
  --     1 : level-sensitive
  constant tile_irq_type : tile_irq_array := (
    others => 0);

  -- Get DMA memory allocation from tile ID (this parameter must be the same for every accelerator)
  constant tile_scatter_gather : tile_flag_array := (
    others => 0);

  -- Get number of clock regions (1 if has_dvfs is false)
  constant domains_num : integer := 1;

  -- Flag tiles that belong to a DVFS domain
  constant tile_has_dvfs : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);

  -- Flag tiles that are master of a DVFS domain (have a local PLL)
  constant tile_has_pll : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);

  -- Get clock domain from tile ID
  constant tile_domain : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    others => 0);

  -- Get tile ID of the DVFS domain masters for each clock region (these tiles control the corresponding domain)
  -- Get tile ID of the DVFS domain master from the tile clock region
  constant tile_domain_master : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    0 => 0,
    1 => 0,
    2 => 0,
    3 => 0,
    others => 0);

  -- Get tile ID of the DVFS domain master from the clock region ID
  constant domain_master_tile : domain_type_array := (
    others => 0);

  -- Flag domain master tiles w/ additional clock buffer (these are a limited resource on the FPGA)
  constant extra_clk_buf : attribute_vector(0 to CFG_TILES_NUM - 1) := (
    0 => 0,
    1 => 0,
    2 => 0,
    3 => 0,
    others => 0);

  ---- Get tile ID from I/O-bus index (index 4 is the local DVFS controller to each CPU tile)
  constant apb_tile_id : apb_attribute_array := (
    0 => io_tile_id,
    1 => io_tile_id,
    2 => io_tile_id,
    3 => io_tile_id,
    14 => io_tile_id,
    15 => io_tile_id,
    20 => 0,
    21 => 1,
    22 => 2,
    23 => 3,
    others => 0);

  constant esp_init_sequence : attribute_vector(0 to CFG_TILES_NUM + CFG_NCPU_TILE - 1) := (
    3, 2, 1, 0, 1);

  constant esp_srst_sequence : attribute_vector(0 to CFG_NMEM_TILE + CFG_NCPU_TILE - 1) := (
    0, 1);

  -- Tiles YX coordinates
  constant tile_x : yx_vec(0 to 3) := (
    0 => "000",
    1 => "001",
    2 => "000",
    3 => "001"  );
  constant tile_y : yx_vec(0 to 3) := (
    0 => "000",
    1 => "000",
    2 => "001",
    3 => "001"  );

  -- CPU YX coordinates
  constant cpu_y : yx_vec(0 to CFG_NCPU_TILE - 1) := (
   0 => tile_y(cpu_tile_id(0))  );
  constant cpu_x : yx_vec(0 to CFG_NCPU_TILE - 1) := (
   0 => tile_x(cpu_tile_id(0))  );

  -- L2 YX coordinates
  constant cache_y : yx_vec(0 to 15) := (
   0 => tile_y(cache_tile_id(0)),
   1 => tile_y(cache_tile_id(1)),
   2 => tile_y(cache_tile_id(2)),
   3 => tile_y(cache_tile_id(3)),
   4 => tile_y(cache_tile_id(4)),
   5 => tile_y(cache_tile_id(5)),
   6 => tile_y(cache_tile_id(6)),
   7 => tile_y(cache_tile_id(7)),
   8 => tile_y(cache_tile_id(8)),
   9 => tile_y(cache_tile_id(9)),
   10 => tile_y(cache_tile_id(10)),
   11 => tile_y(cache_tile_id(11)),
   12 => tile_y(cache_tile_id(12)),
   13 => tile_y(cache_tile_id(13)),
   14 => tile_y(cache_tile_id(14)),
   15 => tile_y(cache_tile_id(15))  );
  constant cache_x : yx_vec(0 to 15) := (
   0 => tile_x(cache_tile_id(0)),
   1 => tile_x(cache_tile_id(1)),
   2 => tile_x(cache_tile_id(2)),
   3 => tile_x(cache_tile_id(3)),
   4 => tile_x(cache_tile_id(4)),
   5 => tile_x(cache_tile_id(5)),
   6 => tile_x(cache_tile_id(6)),
   7 => tile_x(cache_tile_id(7)),
   8 => tile_x(cache_tile_id(8)),
   9 => tile_x(cache_tile_id(9)),
   10 => tile_x(cache_tile_id(10)),
   11 => tile_x(cache_tile_id(11)),
   12 => tile_x(cache_tile_id(12)),
   13 => tile_x(cache_tile_id(13)),
   14 => tile_x(cache_tile_id(14)),
   15 => tile_x(cache_tile_id(15))  );

  -- DMA initiators YX coordinates
  constant dma_y : yx_vec(0 to 63) := (
   0 => tile_y(dma_tile_id(0)),
   1 => tile_y(dma_tile_id(1)),
   2 => tile_y(dma_tile_id(2)),
   3 => tile_y(dma_tile_id(3)),
   4 => tile_y(dma_tile_id(4)),
   5 => tile_y(dma_tile_id(5)),
   6 => tile_y(dma_tile_id(6)),
   7 => tile_y(dma_tile_id(7)),
   8 => tile_y(dma_tile_id(8)),
   9 => tile_y(dma_tile_id(9)),
   10 => tile_y(dma_tile_id(10)),
   11 => tile_y(dma_tile_id(11)),
   12 => tile_y(dma_tile_id(12)),
   13 => tile_y(dma_tile_id(13)),
   14 => tile_y(dma_tile_id(14)),
   15 => tile_y(dma_tile_id(15)),
   16 => tile_y(dma_tile_id(16)),
   17 => tile_y(dma_tile_id(17)),
   18 => tile_y(dma_tile_id(18)),
   19 => tile_y(dma_tile_id(19)),
   20 => tile_y(dma_tile_id(20)),
   21 => tile_y(dma_tile_id(21)),
   22 => tile_y(dma_tile_id(22)),
   23 => tile_y(dma_tile_id(23)),
   24 => tile_y(dma_tile_id(24)),
   25 => tile_y(dma_tile_id(25)),
   26 => tile_y(dma_tile_id(26)),
   27 => tile_y(dma_tile_id(27)),
   28 => tile_y(dma_tile_id(28)),
   29 => tile_y(dma_tile_id(29)),
   30 => tile_y(dma_tile_id(30)),
   31 => tile_y(dma_tile_id(31)),
   32 => tile_y(dma_tile_id(32)),
   33 => tile_y(dma_tile_id(33)),
   34 => tile_y(dma_tile_id(34)),
   35 => tile_y(dma_tile_id(35)),
   36 => tile_y(dma_tile_id(36)),
   37 => tile_y(dma_tile_id(37)),
   38 => tile_y(dma_tile_id(38)),
   39 => tile_y(dma_tile_id(39)),
   40 => tile_y(dma_tile_id(40)),
   41 => tile_y(dma_tile_id(41)),
   42 => tile_y(dma_tile_id(42)),
   43 => tile_y(dma_tile_id(43)),
   44 => tile_y(dma_tile_id(44)),
   45 => tile_y(dma_tile_id(45)),
   46 => tile_y(dma_tile_id(46)),
   47 => tile_y(dma_tile_id(47)),
   48 => tile_y(dma_tile_id(48)),
   49 => tile_y(dma_tile_id(49)),
   50 => tile_y(dma_tile_id(50)),
   51 => tile_y(dma_tile_id(51)),
   52 => tile_y(dma_tile_id(52)),
   53 => tile_y(dma_tile_id(53)),
   54 => tile_y(dma_tile_id(54)),
   55 => tile_y(dma_tile_id(55)),
   56 => tile_y(dma_tile_id(56)),
   57 => tile_y(dma_tile_id(57)),
   58 => tile_y(dma_tile_id(58)),
   59 => tile_y(dma_tile_id(59)),
   60 => tile_y(dma_tile_id(60)),
   61 => tile_y(dma_tile_id(61)),
   62 => tile_y(dma_tile_id(62)),
   63 => tile_y(dma_tile_id(63))  );
  constant dma_x : yx_vec(0 to 63) := (
   0 => tile_x(dma_tile_id(0)),
   1 => tile_x(dma_tile_id(1)),
   2 => tile_x(dma_tile_id(2)),
   3 => tile_x(dma_tile_id(3)),
   4 => tile_x(dma_tile_id(4)),
   5 => tile_x(dma_tile_id(5)),
   6 => tile_x(dma_tile_id(6)),
   7 => tile_x(dma_tile_id(7)),
   8 => tile_x(dma_tile_id(8)),
   9 => tile_x(dma_tile_id(9)),
   10 => tile_x(dma_tile_id(10)),
   11 => tile_x(dma_tile_id(11)),
   12 => tile_x(dma_tile_id(12)),
   13 => tile_x(dma_tile_id(13)),
   14 => tile_x(dma_tile_id(14)),
   15 => tile_x(dma_tile_id(15)),
   16 => tile_x(dma_tile_id(16)),
   17 => tile_x(dma_tile_id(17)),
   18 => tile_x(dma_tile_id(18)),
   19 => tile_x(dma_tile_id(19)),
   20 => tile_x(dma_tile_id(20)),
   21 => tile_x(dma_tile_id(21)),
   22 => tile_x(dma_tile_id(22)),
   23 => tile_x(dma_tile_id(23)),
   24 => tile_x(dma_tile_id(24)),
   25 => tile_x(dma_tile_id(25)),
   26 => tile_x(dma_tile_id(26)),
   27 => tile_x(dma_tile_id(27)),
   28 => tile_x(dma_tile_id(28)),
   29 => tile_x(dma_tile_id(29)),
   30 => tile_x(dma_tile_id(30)),
   31 => tile_x(dma_tile_id(31)),
   32 => tile_x(dma_tile_id(32)),
   33 => tile_x(dma_tile_id(33)),
   34 => tile_x(dma_tile_id(34)),
   35 => tile_x(dma_tile_id(35)),
   36 => tile_x(dma_tile_id(36)),
   37 => tile_x(dma_tile_id(37)),
   38 => tile_x(dma_tile_id(38)),
   39 => tile_x(dma_tile_id(39)),
   40 => tile_x(dma_tile_id(40)),
   41 => tile_x(dma_tile_id(41)),
   42 => tile_x(dma_tile_id(42)),
   43 => tile_x(dma_tile_id(43)),
   44 => tile_x(dma_tile_id(44)),
   45 => tile_x(dma_tile_id(45)),
   46 => tile_x(dma_tile_id(46)),
   47 => tile_x(dma_tile_id(47)),
   48 => tile_x(dma_tile_id(48)),
   49 => tile_x(dma_tile_id(49)),
   50 => tile_x(dma_tile_id(50)),
   51 => tile_x(dma_tile_id(51)),
   52 => tile_x(dma_tile_id(52)),
   53 => tile_x(dma_tile_id(53)),
   54 => tile_x(dma_tile_id(54)),
   55 => tile_x(dma_tile_id(55)),
   56 => tile_x(dma_tile_id(56)),
   57 => tile_x(dma_tile_id(57)),
   58 => tile_x(dma_tile_id(58)),
   59 => tile_x(dma_tile_id(59)),
   60 => tile_x(dma_tile_id(60)),
   61 => tile_x(dma_tile_id(61)),
   62 => tile_x(dma_tile_id(62)),
   63 => tile_x(dma_tile_id(63))  );

  -- SLM YX coordinates and tiles routing info
  constant tile_slm_list : tile_mem_info_vector(0 to CFG_NSLM_TILE + CFG_NMEM_TILE - 1):= (
    others => tile_mem_info_none);

  -- LLC YX coordinates and memory tiles routing info
  constant tile_mem_list : tile_mem_info_vector(0 to CFG_NSLM_TILE + CFG_NMEM_TILE - 1) := (
    0 => (
      x => tile_x(mem_tile_id(0)),
      y => tile_y(mem_tile_id(0)),
      haddr => ddr_haddr(0),
      hmask => ddr_hmask(0)
    ),
    others => tile_mem_info_none);

  -- Add the frame buffer and SLM tiles entries for accelerators' DMA.
  -- NB: accelerators can only access the frame buffer and SLM if
  -- non-coherent DMA is selected from software.
  constant tile_acc_mem_list : tile_mem_info_vector(0 to CFG_NSLM_TILE + CFG_NMEM_TILE) := (
    0 => (
      x => tile_x(mem_tile_id(0)),
      y => tile_y(mem_tile_id(0)),
      haddr => ddr_haddr(0),
      hmask => ddr_hmask(0)
    ),
    others => tile_mem_info_none);

  -- I/O-bus devices routing info
  constant apb_slv_y : yx_vec(0 to NAPBSLV - 1) := (
    0 => tile_y(apb_tile_id(0)),
    1 => tile_y(apb_tile_id(1)),
    2 => tile_y(apb_tile_id(2)),
    3 => tile_y(apb_tile_id(3)),
    4 => tile_y(apb_tile_id(4)),
    5 => tile_y(apb_tile_id(5)),
    6 => tile_y(apb_tile_id(6)),
    7 => tile_y(apb_tile_id(7)),
    8 => tile_y(apb_tile_id(8)),
    9 => tile_y(apb_tile_id(9)),
    10 => tile_y(apb_tile_id(10)),
    11 => tile_y(apb_tile_id(11)),
    12 => tile_y(apb_tile_id(12)),
    13 => tile_y(apb_tile_id(13)),
    14 => tile_y(apb_tile_id(14)),
    15 => tile_y(apb_tile_id(15)),
    16 => tile_y(apb_tile_id(16)),
    17 => tile_y(apb_tile_id(17)),
    18 => tile_y(apb_tile_id(18)),
    19 => tile_y(apb_tile_id(19)),
    20 => tile_y(apb_tile_id(20)),
    21 => tile_y(apb_tile_id(21)),
    22 => tile_y(apb_tile_id(22)),
    23 => tile_y(apb_tile_id(23)),
    24 => tile_y(apb_tile_id(24)),
    25 => tile_y(apb_tile_id(25)),
    26 => tile_y(apb_tile_id(26)),
    27 => tile_y(apb_tile_id(27)),
    28 => tile_y(apb_tile_id(28)),
    29 => tile_y(apb_tile_id(29)),
    30 => tile_y(apb_tile_id(30)),
    31 => tile_y(apb_tile_id(31)),
    32 => tile_y(apb_tile_id(32)),
    33 => tile_y(apb_tile_id(33)),
    34 => tile_y(apb_tile_id(34)),
    35 => tile_y(apb_tile_id(35)),
    36 => tile_y(apb_tile_id(36)),
    37 => tile_y(apb_tile_id(37)),
    38 => tile_y(apb_tile_id(38)),
    39 => tile_y(apb_tile_id(39)),
    40 => tile_y(apb_tile_id(40)),
    41 => tile_y(apb_tile_id(41)),
    42 => tile_y(apb_tile_id(42)),
    43 => tile_y(apb_tile_id(43)),
    44 => tile_y(apb_tile_id(44)),
    45 => tile_y(apb_tile_id(45)),
    46 => tile_y(apb_tile_id(46)),
    47 => tile_y(apb_tile_id(47)),
    48 => tile_y(apb_tile_id(48)),
    49 => tile_y(apb_tile_id(49)),
    50 => tile_y(apb_tile_id(50)),
    51 => tile_y(apb_tile_id(51)),
    52 => tile_y(apb_tile_id(52)),
    53 => tile_y(apb_tile_id(53)),
    54 => tile_y(apb_tile_id(54)),
    55 => tile_y(apb_tile_id(55)),
    56 => tile_y(apb_tile_id(56)),
    57 => tile_y(apb_tile_id(57)),
    58 => tile_y(apb_tile_id(58)),
    59 => tile_y(apb_tile_id(59)),
    60 => tile_y(apb_tile_id(60)),
    61 => tile_y(apb_tile_id(61)),
    62 => tile_y(apb_tile_id(62)),
    63 => tile_y(apb_tile_id(63)),
    64 => tile_y(apb_tile_id(64)),
    65 => tile_y(apb_tile_id(65)),
    66 => tile_y(apb_tile_id(66)),
    67 => tile_y(apb_tile_id(67)),
    68 => tile_y(apb_tile_id(68)),
    69 => tile_y(apb_tile_id(69)),
    70 => tile_y(apb_tile_id(70)),
    71 => tile_y(apb_tile_id(71)),
    72 => tile_y(apb_tile_id(72)),
    73 => tile_y(apb_tile_id(73)),
    74 => tile_y(apb_tile_id(74)),
    75 => tile_y(apb_tile_id(75)),
    76 => tile_y(apb_tile_id(76)),
    77 => tile_y(apb_tile_id(77)),
    78 => tile_y(apb_tile_id(78)),
    79 => tile_y(apb_tile_id(79)),
    80 => tile_y(apb_tile_id(80)),
    81 => tile_y(apb_tile_id(81)),
    82 => tile_y(apb_tile_id(82)),
    83 => tile_y(apb_tile_id(83)),
    84 => tile_y(apb_tile_id(84)),
    85 => tile_y(apb_tile_id(85)),
    86 => tile_y(apb_tile_id(86)),
    87 => tile_y(apb_tile_id(87)),
    88 => tile_y(apb_tile_id(88)),
    89 => tile_y(apb_tile_id(89)),
    90 => tile_y(apb_tile_id(90)),
    91 => tile_y(apb_tile_id(91)),
    92 => tile_y(apb_tile_id(92)),
    93 => tile_y(apb_tile_id(93)),
    94 => tile_y(apb_tile_id(94)),
    95 => tile_y(apb_tile_id(95)),
    96 => tile_y(apb_tile_id(96)),
    97 => tile_y(apb_tile_id(97)),
    98 => tile_y(apb_tile_id(98)),
    99 => tile_y(apb_tile_id(99)),
    100 => tile_y(apb_tile_id(100)),
    101 => tile_y(apb_tile_id(101)),
    102 => tile_y(apb_tile_id(102)),
    103 => tile_y(apb_tile_id(103)),
    104 => tile_y(apb_tile_id(104)),
    105 => tile_y(apb_tile_id(105)),
    106 => tile_y(apb_tile_id(106)),
    107 => tile_y(apb_tile_id(107)),
    108 => tile_y(apb_tile_id(108)),
    109 => tile_y(apb_tile_id(109)),
    110 => tile_y(apb_tile_id(110)),
    111 => tile_y(apb_tile_id(111)),
    112 => tile_y(apb_tile_id(112)),
    113 => tile_y(apb_tile_id(113)),
    114 => tile_y(apb_tile_id(114)),
    115 => tile_y(apb_tile_id(115)),
    116 => tile_y(apb_tile_id(116)),
    117 => tile_y(apb_tile_id(117)),
    118 => tile_y(apb_tile_id(118)),
    119 => tile_y(apb_tile_id(119)),
    120 => tile_y(apb_tile_id(120)),
    121 => tile_y(apb_tile_id(121)),
    122 => tile_y(apb_tile_id(122)),
    123 => tile_y(apb_tile_id(123)),
    124 => tile_y(apb_tile_id(124)),
    125 => tile_y(apb_tile_id(125)),
    126 => tile_y(apb_tile_id(126)),
    127 => tile_y(apb_tile_id(127))  );
  constant apb_slv_x : yx_vec(0 to NAPBSLV - 1) := (
    0 => tile_x(apb_tile_id(0)),
    1 => tile_x(apb_tile_id(1)),
    2 => tile_x(apb_tile_id(2)),
    3 => tile_x(apb_tile_id(3)),
    4 => tile_x(apb_tile_id(4)),
    5 => tile_x(apb_tile_id(5)),
    6 => tile_x(apb_tile_id(6)),
    7 => tile_x(apb_tile_id(7)),
    8 => tile_x(apb_tile_id(8)),
    9 => tile_x(apb_tile_id(9)),
    10 => tile_x(apb_tile_id(10)),
    11 => tile_x(apb_tile_id(11)),
    12 => tile_x(apb_tile_id(12)),
    13 => tile_x(apb_tile_id(13)),
    14 => tile_x(apb_tile_id(14)),
    15 => tile_x(apb_tile_id(15)),
    16 => tile_x(apb_tile_id(16)),
    17 => tile_x(apb_tile_id(17)),
    18 => tile_x(apb_tile_id(18)),
    19 => tile_x(apb_tile_id(19)),
    20 => tile_x(apb_tile_id(20)),
    21 => tile_x(apb_tile_id(21)),
    22 => tile_x(apb_tile_id(22)),
    23 => tile_x(apb_tile_id(23)),
    24 => tile_x(apb_tile_id(24)),
    25 => tile_x(apb_tile_id(25)),
    26 => tile_x(apb_tile_id(26)),
    27 => tile_x(apb_tile_id(27)),
    28 => tile_x(apb_tile_id(28)),
    29 => tile_x(apb_tile_id(29)),
    30 => tile_x(apb_tile_id(30)),
    31 => tile_x(apb_tile_id(31)),
    32 => tile_x(apb_tile_id(32)),
    33 => tile_x(apb_tile_id(33)),
    34 => tile_x(apb_tile_id(34)),
    35 => tile_x(apb_tile_id(35)),
    36 => tile_x(apb_tile_id(36)),
    37 => tile_x(apb_tile_id(37)),
    38 => tile_x(apb_tile_id(38)),
    39 => tile_x(apb_tile_id(39)),
    40 => tile_x(apb_tile_id(40)),
    41 => tile_x(apb_tile_id(41)),
    42 => tile_x(apb_tile_id(42)),
    43 => tile_x(apb_tile_id(43)),
    44 => tile_x(apb_tile_id(44)),
    45 => tile_x(apb_tile_id(45)),
    46 => tile_x(apb_tile_id(46)),
    47 => tile_x(apb_tile_id(47)),
    48 => tile_x(apb_tile_id(48)),
    49 => tile_x(apb_tile_id(49)),
    50 => tile_x(apb_tile_id(50)),
    51 => tile_x(apb_tile_id(51)),
    52 => tile_x(apb_tile_id(52)),
    53 => tile_x(apb_tile_id(53)),
    54 => tile_x(apb_tile_id(54)),
    55 => tile_x(apb_tile_id(55)),
    56 => tile_x(apb_tile_id(56)),
    57 => tile_x(apb_tile_id(57)),
    58 => tile_x(apb_tile_id(58)),
    59 => tile_x(apb_tile_id(59)),
    60 => tile_x(apb_tile_id(60)),
    61 => tile_x(apb_tile_id(61)),
    62 => tile_x(apb_tile_id(62)),
    63 => tile_x(apb_tile_id(63)),
    64 => tile_x(apb_tile_id(64)),
    65 => tile_x(apb_tile_id(65)),
    66 => tile_x(apb_tile_id(66)),
    67 => tile_x(apb_tile_id(67)),
    68 => tile_x(apb_tile_id(68)),
    69 => tile_x(apb_tile_id(69)),
    70 => tile_x(apb_tile_id(70)),
    71 => tile_x(apb_tile_id(71)),
    72 => tile_x(apb_tile_id(72)),
    73 => tile_x(apb_tile_id(73)),
    74 => tile_x(apb_tile_id(74)),
    75 => tile_x(apb_tile_id(75)),
    76 => tile_x(apb_tile_id(76)),
    77 => tile_x(apb_tile_id(77)),
    78 => tile_x(apb_tile_id(78)),
    79 => tile_x(apb_tile_id(79)),
    80 => tile_x(apb_tile_id(80)),
    81 => tile_x(apb_tile_id(81)),
    82 => tile_x(apb_tile_id(82)),
    83 => tile_x(apb_tile_id(83)),
    84 => tile_x(apb_tile_id(84)),
    85 => tile_x(apb_tile_id(85)),
    86 => tile_x(apb_tile_id(86)),
    87 => tile_x(apb_tile_id(87)),
    88 => tile_x(apb_tile_id(88)),
    89 => tile_x(apb_tile_id(89)),
    90 => tile_x(apb_tile_id(90)),
    91 => tile_x(apb_tile_id(91)),
    92 => tile_x(apb_tile_id(92)),
    93 => tile_x(apb_tile_id(93)),
    94 => tile_x(apb_tile_id(94)),
    95 => tile_x(apb_tile_id(95)),
    96 => tile_x(apb_tile_id(96)),
    97 => tile_x(apb_tile_id(97)),
    98 => tile_x(apb_tile_id(98)),
    99 => tile_x(apb_tile_id(99)),
    100 => tile_x(apb_tile_id(100)),
    101 => tile_x(apb_tile_id(101)),
    102 => tile_x(apb_tile_id(102)),
    103 => tile_x(apb_tile_id(103)),
    104 => tile_x(apb_tile_id(104)),
    105 => tile_x(apb_tile_id(105)),
    106 => tile_x(apb_tile_id(106)),
    107 => tile_x(apb_tile_id(107)),
    108 => tile_x(apb_tile_id(108)),
    109 => tile_x(apb_tile_id(109)),
    110 => tile_x(apb_tile_id(110)),
    111 => tile_x(apb_tile_id(111)),
    112 => tile_x(apb_tile_id(112)),
    113 => tile_x(apb_tile_id(113)),
    114 => tile_x(apb_tile_id(114)),
    115 => tile_x(apb_tile_id(115)),
    116 => tile_x(apb_tile_id(116)),
    117 => tile_x(apb_tile_id(117)),
    118 => tile_x(apb_tile_id(118)),
    119 => tile_x(apb_tile_id(119)),
    120 => tile_x(apb_tile_id(120)),
    121 => tile_x(apb_tile_id(121)),
    122 => tile_x(apb_tile_id(122)),
    123 => tile_x(apb_tile_id(123)),
    124 => tile_x(apb_tile_id(124)),
    125 => tile_x(apb_tile_id(125)),
    126 => tile_x(apb_tile_id(126)),
    127 => tile_x(apb_tile_id(127))  );

  -- Flag I/O-bus slaves that are remote
  -- Note that all components appear as remote to CPU and I/O tiles even if
  -- located in that tile. This is because local masters still have to go
  -- through ESP proxies to address such devices (e.g. L2 cache and DVFS
  -- controller in CPU tiles). This choice allows any master in the SoC to
  -- access these slaves. For instance, when configuring DVFS, a single CPU
  -- must be able to access all DVFS controllers from other CPUS; another
  -- example is the synchronized flush of all private caches, which is
  -- initiated by a single CPU
  constant remote_apb_slv_mask_cpu : std_logic_vector(0 to NAPBSLV - 1) := (
    1 => '1',
    2 => '1',
    3 => '1',
    13 => to_std_logic(CFG_SVGA_ENABLE),
    14 => to_std_logic(CFG_GRETH),
    15 => to_std_logic(CFG_GRETH),
    20 => '1',
    21 => '1',
    22 => '1',
    23 => '1',
    others => '0');

  constant remote_apb_slv_mask_misc : std_logic_vector(0 to NAPBSLV - 1) := (
    20 => '1',
    21 => '1',
    22 => '1',
    others => '0');
  -- Flag bus slaves that are remote to each tile (request selects slv proxy)
  constant remote_ahb_mask_misc : std_logic_vector(0 to NAHBSLV - 1) := (
    4 => '1',
    others => '0');

  constant remote_ahb_mask_cpu : std_logic_vector(0 to NAHBSLV - 1) := (
    0  => '1',
    4 => to_std_logic(CFG_L2_DISABLE),
    12  => to_std_logic(CFG_SVGA_ENABLE),
    others => '0');

  constant slm_ahb_mask : std_logic_vector(0 to NAHBSLV - 1) := (
    others => '0');

end socmap;
