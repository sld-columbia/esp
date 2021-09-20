-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.monitor_pkg.all;
use work.esp_acc_regmap.all;

package esp_csr_pkg is

  constant ESP_CSR_8_LSB : integer := 71 + CFG_NCPU_TILE * 2 * 3;
  constant ESP_CSR_WIDTH : integer := 96 + ESP_CSR_8_LSB;

  constant ESP_CSR_VALID_ADDR : integer range 0 to 31 := 0;
  constant ESP_CSR_VALID_LSB  : integer range 0 to ESP_CSR_WIDTH-1 := 0;
  constant ESP_CSR_VALID_MSB  : integer range 0 to ESP_CSR_WIDTH-1 := 0;

  constant ESP_CSR_TILE_ID_ADDR : integer range 0 to 31 := 1;
  constant ESP_CSR_TILE_ID_LSB  : integer range 0 to ESP_CSR_WIDTH-1 := 1;
  constant ESP_CSR_TILE_ID_MSB  : integer range 0 to ESP_CSR_WIDTH-1 := 8;

  constant ESP_CSR_PAD_CFG_ADDR : integer range 0 to 31 := 2;
  constant ESP_CSR_PAD_CFG_LSB  : integer range 0 to ESP_CSR_WIDTH-1 := 9;
  constant ESP_CSR_PAD_CFG_MSB  : integer range 0 to ESP_CSR_WIDTH-1 := 11;

  constant ESP_CSR_DCO_CFG_ADDR : integer range 0 to 31 := 3;
  constant ESP_CSR_DCO_CFG_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 12;
  constant ESP_CSR_DCO_CFG_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 34;

  constant ESP_CSR_DCO_NOC_CFG_ADDR : integer range 0 to 31 := 4;
  constant ESP_CSR_DCO_NOC_CFG_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 35;
  constant ESP_CSR_DCO_NOC_CFG_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 53;

  constant ESP_CSR_MDC_SCALER_CFG_ADDR : integer range 0 to 31 := 5;
  constant ESP_CSR_MDC_SCALER_CFG_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 54;
  constant ESP_CSR_MDC_SCALER_CFG_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 64;

  constant ESP_CSR_ARIANE_HARTID_ADDR : integer range 0 to 31 := 6;
  constant ESP_CSR_ARIANE_HARTID_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 65;
  constant ESP_CSR_ARIANE_HARTID_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 69;

  constant ESP_CSR_CPU_LOC_OVR_ADDR : integer range 0 to 31 := 7;
  constant ESP_CSR_CPU_LOC_OVR_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 70;
  constant ESP_CSR_CPU_LOC_OVR_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 70 + CFG_NCPU_TILE * 2 * 3;

  constant ESP_CSR_DDR_CFG0_ADDR : integer range 0 to 31 := 8;
  constant ESP_CSR_DDR_CFG0_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := ESP_CSR_8_LSB;
  constant ESP_CSR_DDR_CFG0_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 31 + ESP_CSR_8_LSB;

  constant ESP_CSR_DDR_CFG1_ADDR : integer range 0 to 31 := 9;
  constant ESP_CSR_DDR_CFG1_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 32 + ESP_CSR_8_LSB;
  constant ESP_CSR_DDR_CFG1_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 63 + ESP_CSR_8_LSB;

  constant ESP_CSR_DDR_CFG2_ADDR : integer range 0 to 31 := 10;
  constant ESP_CSR_DDR_CFG2_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 64 + ESP_CSR_8_LSB;
  constant ESP_CSR_DDR_CFG2_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 95 + ESP_CSR_8_LSB;

  -- Power management
  constant PM_REGNUM_CONFIG : integer range 0 to 31 := 9;
  constant PM_REGNUM_STATUS : integer range 0 to 31 := 2;
  constant PM_REGNUM : integer range 0 to 31 := PM_REGNUM_CONFIG + PM_REGNUM_STATUS;
  constant ESP_CSR_PM_MIN : integer range 0 to 31 := 20;
  constant ESP_CSR_PM_MAX : integer range 0 to 31 := ESP_CSR_PM_MIN + PM_REGNUM - 1;

  -- Soft reset
  constant ESP_CSR_SRST_ADDR : integer range 0 to 31 := 31;  -- reserved address

  -- Power management types
  type pm_csr_type is array (0 to PM_REGNUM - 1) of std_logic_vector(31 downto 0);
  type pm_config_type is array(0 to PM_REGNUM_CONFIG - 1) of std_logic_vector(31 downto 0);
  type pm_status_type is array (0 to PM_REGNUM_STATUS - 1) of std_logic_vector(31 downto 0);

  component esp_tile_csr
    generic (
      pindex : integer range 0 to NAPBSLV - 1;
      dco_rst_cfg : std_logic_vector(22 downto 0) := (others => '0'));
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
      pm_config   : out pm_config_type;
      pm_status   : in pm_status_type;
      srst        : out std_ulogic;
      apbi        : in apb_slv_in_type;
      apbo        : out apb_slv_out_type);
  end component;

end esp_csr_pkg;
