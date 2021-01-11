-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

------------------------------------------------------------------------------
--  This file is a configuration file for the ESP NoC-based architecture
-----------------------------------------------------------------------------
-- Package:     esp_global
-- File:        esp_global.vhd
-- Author:      Paolo Mantovani - SLD @ Columbia University
-- Author:      Christian Pilato - SLD @ Columbia University
-- Description: System address mapping and NoC tiles configuration
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package esp_global is

  ------ Global architecture parameters
  constant ARCH_BITS : integer := 64;
  constant GLOB_MAXIOSLV : integer := 128;
  constant GLOB_WORD_OFFSET_BITS : integer := 1;
  constant GLOB_BYTE_OFFSET_BITS : integer := 3;
  constant GLOB_OFFSET_BITS : integer := GLOB_WORD_OFFSET_BITS + GLOB_BYTE_OFFSET_BITS;
  constant GLOB_ADDR_INCR : integer := 8;
  constant GLOB_PHYS_ADDR_BITS : integer := 32;
  type cpu_arch_type is (leon3, ariane, ibex);
  constant GLOB_CPU_ARCH : cpu_arch_type := ariane;
  constant GLOB_CPU_AXI : integer range 0 to 1 := 1;
  constant GLOB_CPU_RISCV : integer range 0 to 1 := 1;

  constant CFG_CACHE_RTL   : integer := 1;
  ------ NoC parameters
  constant CFG_XLEN : integer := 2;
  constant CFG_YLEN : integer := 2;
  constant CFG_TILES_NUM : integer := CFG_XLEN * CFG_YLEN;
  ------ DMA memory allocation (contiguous buffer or scatter/gather
  constant CFG_SCATTER_GATHER : integer range 0 to 1 := 1;
  constant CFG_L2_SETS     : integer := 512;
  constant CFG_L2_WAYS     : integer := 4;
  constant CFG_LLC_SETS    : integer := 1024;
  constant CFG_LLC_WAYS    : integer := 16;
  constant CFG_ACC_L2_SETS : integer := 512;
  constant CFG_ACC_L2_WAYS : integer := 4;
  ------ Monitors enable (requires proFPGA MMI64)
  constant CFG_MON_DDR_EN : integer := 0;
  constant CFG_MON_MEM_EN : integer := 0;
  constant CFG_MON_NOC_INJECT_EN : integer := 0;
  constant CFG_MON_NOC_QUEUES_EN : integer := 0;
  constant CFG_MON_ACC_EN : integer := 0;
  constant CFG_MON_L2_EN : integer := 0;
  constant CFG_MON_LLC_EN : integer := 0;
  constant CFG_MON_DVFS_EN : integer := 0;

  ------ Coherence enabled
  constant CFG_L2_ENABLE   : integer := 0;
  constant CFG_L2_DISABLE  : integer := 1;
  constant CFG_LLC_ENABLE  : integer := 0;

  ------ Number of components
  constant CFG_NCPU_TILE : integer := 1;
  constant CFG_NMEM_TILE : integer := 1;
  constant CFG_NSLM_TILE : integer := 0;
  constant CFG_NL2 : integer := 0;
  constant CFG_NLLC : integer := 0;
  constant CFG_NLLC_COHERENT : integer := 0;
  constant CFG_SLM_KBYTES : integer := 256;

  ------ Local-port Synchronizers are always present)
  constant CFG_HAS_SYNC : integer := 1;
  constant CFG_HAS_DVFS : integer := 0;

  ------ Caches interrupt line
  constant CFG_SLD_LLC_CACHE_IRQ : integer := 4;

  constant CFG_SLD_L2_CACHE_IRQ : integer := 3;

end esp_global;
