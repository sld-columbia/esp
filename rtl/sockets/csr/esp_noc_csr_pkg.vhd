-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.monitor_pkg.all;
use work.esp_acc_regmap.all;

package esp_noc_csr_pkg is

  constant ESP_NOC_CSR_WIDTH : integer := 170;

  constant ESP_CSR_TILE_ID_NOC_ADDR : integer range 0 to 31 := 16;
  constant ESP_CSR_TILE_ID_NOC_LSB  : integer range 0 to ESP_NOC_CSR_WIDTH-1 := 0;
  constant ESP_CSR_TILE_ID_NOC_MSB  : integer range 0 to ESP_NOC_CSR_WIDTH-1 := 7;

  constant ESP_CSR_PAD_CFG_ADDR : integer range 0 to 31 := 17;
  constant ESP_CSR_PAD_CFG_LSB  : integer range 0 to ESP_NOC_CSR_WIDTH-1 := 8;
  constant ESP_CSR_PAD_CFG_MSB  : integer range 0 to ESP_NOC_CSR_WIDTH-1 := 10;

  constant ESP_CSR_DCO_CFG_ADDR : integer range 0 to 31 := 18;
  constant ESP_CSR_DCO_CFG_LSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 11;
  constant ESP_CSR_DCO_CFG_MSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 34;

  constant ESP_CSR_DCO_NOC_CFG_ADDR : integer range 0 to 31 := 19;
  constant ESP_CSR_DCO_NOC_CFG_LSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 35;
  constant ESP_CSR_DCO_NOC_CFG_MSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 53;

  constant ESP_CSR_LDO_CFG_ADDR : integer range 0 to 31 := 31;
  constant ESP_CSR_LDO_CFG_LSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 54;
  constant ESP_CSR_LDO_CFG_MSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 62;

  constant ESP_CSR_MDC_SCALER_CFG_ADDR : integer range 0 to 31 := 15;
  constant ESP_CSR_MDC_SCALER_CFG_LSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 63;
  constant ESP_CSR_MDC_SCALER_CFG_MSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 73;

  constant ESP_CSR_DDR_CFG0_ADDR : integer range 0 to 31 := 12;
  constant ESP_CSR_DDR_CFG0_LSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 74;
  constant ESP_CSR_DDR_CFG0_MSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 105;

  constant ESP_CSR_DDR_CFG1_ADDR : integer range 0 to 31 := 13;
  constant ESP_CSR_DDR_CFG1_LSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 106;
  constant ESP_CSR_DDR_CFG1_MSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 137;

  constant ESP_CSR_DDR_CFG2_ADDR : integer range 0 to 31 := 14;
  constant ESP_CSR_DDR_CFG2_LSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 138;
  constant ESP_CSR_DDR_CFG2_MSB : integer range 0 to ESP_NOC_CSR_WIDTH - 1 := 169;

  -- Power management
  constant PM_REGNUM_CONFIG : integer range 0 to 31 := 9;
  constant PM_REGNUM_STATUS : integer range 0 to 31 := 2;
  constant PM_REGNUM : integer range 0 to 31 := PM_REGNUM_CONFIG + PM_REGNUM_STATUS;
  constant ESP_CSR_PM_MIN : integer range 0 to 31 := 20;
  constant ESP_CSR_PM_MAX : integer range 0 to 31 := ESP_CSR_PM_MIN + PM_REGNUM - 1;

  -- Power management types
  type pm_csr_type is array (0 to PM_REGNUM - 1) of std_logic_vector(31 downto 0);
  type pm_config_type is array(0 to PM_REGNUM_CONFIG - 1) of std_logic_vector(31 downto 0);
  type pm_status_type is array (0 to PM_REGNUM_STATUS - 1) of std_logic_vector(31 downto 0);

  component esp_noc_csr
    generic (
      pindex       : integer range 0 to NAPBSLV - 1;
      has_token_pm : integer range 0 to 1 := 0;
      has_ddr      : boolean := false);
    port (
      clk         : in std_logic;
      rstn        : in std_logic;
      pconfig     : in apb_config_type;
      tile_config : out std_logic_vector(ESP_NOC_CSR_WIDTH - 1 downto 0);
      pm_config   : out pm_config_type;
      pm_status   : in pm_status_type;
      apbi        : in apb_slv_in_type;
      apbo        : out apb_slv_out_type);
  end component;

end esp_noc_csr_pkg;
