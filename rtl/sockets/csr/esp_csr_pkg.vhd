-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.monitor_pkg.all;
use work.nocpackage.all;

package esp_csr_pkg is

  constant NCPU_TILE_MAX : integer := 16;
  constant ESP_CSR_WIDTH : integer := 143 + 2 * YX_WIDTH * NCPU_TILE_MAX;

  constant ESP_CSR_VALID_ADDR : integer range 0 to 31 := 0;
  constant ESP_CSR_VALID_LSB  : integer range 0 to ESP_CSR_WIDTH-1 := 0;
  constant ESP_CSR_VALID_MSB  : integer range 0 to ESP_CSR_WIDTH-1 := 0;

  constant ESP_CSR_TILE_ID_ADDR : integer range 0 to 31 := 1;
  constant ESP_CSR_TILE_ID_LSB  : integer range 0 to ESP_CSR_WIDTH-1 := 1;
  constant ESP_CSR_TILE_ID_MSB  : integer range 0 to ESP_CSR_WIDTH-1 := 8;

  constant ESP_CSR_ARIANE_HARTID_ADDR : integer range 0 to 31 := 2;
  constant ESP_CSR_ARIANE_HARTID_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 9;
  constant ESP_CSR_ARIANE_HARTID_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 13;

  constant ESP_CSR_ACC_COH_ADDR : integer range 0 to 31 := 3;
  constant ESP_CSR_ACC_COH_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 14;
  constant ESP_CSR_ACC_COH_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 15;

  -- Third party accelerator reset
  constant ESP_CSR_TP_ACC_RST : integer range 0 to 31 := 4;

  -- Soft reset
  constant ESP_CSR_SRST_ADDR : integer range 0 to 31 := 5;

  constant ESP_CSR_DCO_NOC_CFG_ADDR : integer range 0 to 31 := 6;
  constant ESP_CSR_DCO_NOC_CFG_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 16;
  constant ESP_CSR_DCO_NOC_CFG_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 34;

  constant ESP_CSR_MDC_SCALER_CFG_ADDR : integer range 0 to 31 := 7;
  constant ESP_CSR_MDC_SCALER_CFG_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 35;
  constant ESP_CSR_MDC_SCALER_CFG_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 45;

  constant ESP_CSR_DDR_CFG0_ADDR : integer range 0 to 31 := 8;
  constant ESP_CSR_DDR_CFG0_LSB : integer range 0 to ESP_CSR_WIDTH - 1 :=  46;
  constant ESP_CSR_DDR_CFG0_MSB : integer range 0 to ESP_CSR_WIDTH - 1 :=  77;

  constant ESP_CSR_DDR_CFG1_ADDR : integer range 0 to 31 := 9;
  constant ESP_CSR_DDR_CFG1_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 78;
  constant ESP_CSR_DDR_CFG1_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 109;

  constant ESP_CSR_DDR_CFG2_ADDR : integer range 0 to 31 := 10;
  constant ESP_CSR_DDR_CFG2_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 110;
  constant ESP_CSR_DDR_CFG2_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 141;

  constant ESP_CSR_CPU_LOC_OVR_ADDR : integer range 0 to 31 := 11;
  constant ESP_CSR_CPU_LOC_OVR_0_ADDR : integer range 0 to 31 := 12;
  constant ESP_CSR_CPU_LOC_OVR_1_ADDR : integer range 0 to 31 := 13;
  constant ESP_CSR_CPU_LOC_OVR_2_ADDR : integer range 0 to 31 := 14;
  constant ESP_CSR_CPU_LOC_OVR_3_ADDR : integer range 0 to 31 := 15;
  constant ESP_CSR_CPU_LOC_OVR_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 16;
  constant ESP_CSR_CPU_LOC_OVR_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 16 + NCPU_TILE_MAX * 2 * YX_WIDTH;

  component esp_tile_csr
    generic (
      pindex  : integer range 0 to NAPBSLV - 1;
      has_ddr : boolean := false);
    port (
      clk         : in std_logic;
      rstn        : in std_logic;
      pconfig     : in apb_config_type;
      mon_ddr     : in monitor_ddr_type;
      mon_mem     : in monitor_mem_type;
      mon_noc     : in monitor_noc_vector(1 to 6);
      mon_l2      : in monitor_cache_type;
      mon_llc     : in monitor_cache_type;
      mon_acc     : in monitor_acc_type;
      mon_dvfs    : in monitor_dvfs_type;
      tile_config : out std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);
      srst        : out std_ulogic;
      tp_acc_rst  : out std_ulogic;
      apbi        : in apb_slv_in_type;
      apbo        : out apb_slv_out_type);
  end component;

end esp_csr_pkg;
