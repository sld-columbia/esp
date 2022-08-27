-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.monitor_pkg.all;

package esp_csr_pkg is

  constant ESP_CSR_8_LSB : integer := 79 + CFG_NCPU_TILE * 2 * 3;
  constant ESP_CSR_WIDTH : integer := 100 + ESP_CSR_8_LSB;

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
  constant ESP_CSR_DCO_CFG_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 42;

  constant ESP_CSR_DCO_NOC_CFG_ADDR : integer range 0 to 31 := 4;
  constant ESP_CSR_DCO_NOC_CFG_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 43;
  constant ESP_CSR_DCO_NOC_CFG_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 61;

  constant ESP_CSR_MDC_SCALER_CFG_ADDR : integer range 0 to 31 := 5;
  constant ESP_CSR_MDC_SCALER_CFG_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 62;
  constant ESP_CSR_MDC_SCALER_CFG_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 72;

  constant ESP_CSR_ARIANE_HARTID_ADDR : integer range 0 to 31 := 6;
  constant ESP_CSR_ARIANE_HARTID_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 73;
  constant ESP_CSR_ARIANE_HARTID_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 77;

  constant ESP_CSR_CPU_LOC_OVR_ADDR : integer range 0 to 31 := 7;
  constant ESP_CSR_CPU_LOC_OVR_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 78;
  constant ESP_CSR_CPU_LOC_OVR_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 78 + CFG_NCPU_TILE * 2 * 3;

  constant ESP_CSR_DDR_CFG0_ADDR : integer range 0 to 31 := 8;
  constant ESP_CSR_DDR_CFG0_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := ESP_CSR_8_LSB;
  constant ESP_CSR_DDR_CFG0_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 31 + ESP_CSR_8_LSB;

  constant ESP_CSR_DDR_CFG1_ADDR : integer range 0 to 31 := 9;
  constant ESP_CSR_DDR_CFG1_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 32 + ESP_CSR_8_LSB;
  constant ESP_CSR_DDR_CFG1_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 63 + ESP_CSR_8_LSB;

  constant ESP_CSR_DDR_CFG2_ADDR : integer range 0 to 31 := 10;
  constant ESP_CSR_DDR_CFG2_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 64 + ESP_CSR_8_LSB;
  constant ESP_CSR_DDR_CFG2_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 95 + ESP_CSR_8_LSB;

  constant ESP_CSR_ACC_COH_ADDR : integer range 0 to 31 := 11;
  constant ESP_CSR_ACC_COH_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 96 + ESP_CSR_8_LSB;
  constant ESP_CSR_ACC_COH_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 97 + ESP_CSR_8_LSB;
  
  constant ESP_CSR_ACC_DECOUPLER_ADDR : integer range 0 to 31 := 12;
  constant ESP_CSR_ACC_DECOUPLER_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 98;
  constant ESP_CSR_ACC_DECOUPLER_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 98;
  
  constant ESP_CSR_PRC_INTR_ADDR : integer range 0 to 31 := 13;
  constant ESP_CSR_PRC_INTR_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 99;
  constant ESP_CSR_PRC_INTR_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 99;

  constant ESP_CSR_SRST_ADDR : integer range 0 to 31 := 31;  -- reserved address

  constant DCO_CFG_LPDDR_CTRL_BITS : integer range 0 to 31 := 12;

  component esp_tile_csr
    generic (
      pindex : integer range 0 to NAPBSLV - 1;
      dco_rst_cfg : std_logic_vector(30 downto 0) := (others => '0'));
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
      apbi        : in apb_slv_in_type;
      apbo        : out apb_slv_out_type;
      prc_interrupt : in std_ulogic);
  end component;

end esp_csr_pkg;
