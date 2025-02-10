-- Copyright (c) 2011-2025 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.monitor_pkg.all;
use work.esp_noc_csr_pkg.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.socmap.all;

package tiles_fpga_pkg is

  component fpga_tile_cpu is
    generic (
      SIMULATION         : boolean              := false;
      ROUTER_PORTS       : ports_vec            := "11111";
      HAS_SYNC           : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      noc_clk            : in  std_logic;
      tile_clk           : out std_ulogic;
      tile_rstn          : out std_ulogic;
      cpuerr             : out std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      -- NOC
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc            : in  monitor_noc_vector(1 to 6);
      mon_cache          : out monitor_cache_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component fpga_tile_cpu;

  component fpga_tile_acc is
    generic (
      SIMULATION         : boolean              := false;
      this_hls_conf      : hlscfg_t             := 0;
      this_device        : devid_t              := 0;
      this_irq_type      : integer              := 0;
      this_has_l2        : integer range 0 to 1 := 0;
      this_has_token_pm  : integer range 0 to 1 := 0;
      ROUTER_PORTS       : ports_vec            := "11111";
      HAS_SYNC           : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      noc_clk            : in  std_logic;
      tile_clk           : out std_ulogic;
      tile_rstn          : out std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      -- NOC
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc            : in  monitor_noc_vector(1 to 6);
      --Monitor signals
      mon_acc            : out monitor_acc_type;
      mon_cache          : out monitor_cache_type;
      mon_dvfs           : out monitor_dvfs_type
      );
  end component fpga_tile_acc;

  component fpga_tile_io is
    generic (
      SIMULATION   : boolean              := false;
      ROUTER_PORTS : ports_vec            := "11111";
      HAS_SYNC     : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      noc_clk            : in  std_ulogic;
      tile_clk           : out std_ulogic;
      tile_rstn          : out std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- I/O bus interfaces
      eth0_apbi          : out apb_slv_in_type;
      eth0_apbo          : in  apb_slv_out_type;
      sgmii0_apbi        : out apb_slv_in_type;
      sgmii0_apbo        : in  apb_slv_out_type;
      eth0_ahbmi         : out ahb_mst_in_type;
      eth0_ahbmo         : in  ahb_mst_out_type;
      edcl_ahbmo         : in  ahb_mst_out_type;
      dvi_apbi           : out apb_slv_in_type;
      dvi_apbo           : in  apb_slv_out_type;
      dvi_ahbmi          : out ahb_mst_in_type;
      dvi_ahbmo          : in  ahb_mst_out_type;
      uart_rxd           : in  std_ulogic;
      uart_txd           : out std_ulogic;
      uart_ctsn          : in  std_ulogic;
      uart_rtsn          : out std_ulogic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      -- NOC
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc            : in  monitor_noc_vector(1 to 6);
      mon_dvfs           : out monitor_dvfs_type);
  end component fpga_tile_io;

  component fpga_tile_mem is
    generic (
      SIMULATION   : boolean  := false;
      ROUTER_PORTS : ports_vec := "11111";
      HAS_SYNC     : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      noc_clk            : in  std_logic;
      tile_clk           : out std_ulogic;
      tile_rstn          : out std_ulogic;
      -- DDR controller ports (this_has_ddr -> 1)
      ddr_ahbsi          : out ahb_slv_in_type;
      ddr_ahbso          : in  ahb_slv_out_type;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      -- NOC
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc            : in  monitor_noc_vector(1 to 6);
      mon_mem            : out monitor_mem_type;
      mon_cache          : out monitor_cache_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component fpga_tile_mem;

  component fpga_tile_empty is
    generic (
      SIMULATION   : boolean              := false;
      ROUTER_PORTS : ports_vec            := "11111";
      HAS_SYNC     : integer range 0 to 1 := 1);
    port (
      rst                : in  std_logic;
      clk                : in  std_logic;
      noc_clk            : in  std_logic;
      tile_clk           : out std_ulogic;
      tile_rstn          : out std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      -- NoC
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc            : in  monitor_noc_vector(1 to 6);
      mon_dvfs_out       : out monitor_dvfs_type);
  end component fpga_tile_empty;

  component fpga_tile_slm is
    generic (
      SIMULATION   : boolean := false;
      ROUTER_PORTS : ports_vec            := "11111";
      HAS_SYNC     : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      noc_clk            : in  std_logic;
      tile_rstn          : out std_ulogic;
      tile_clk           : out std_ulogic;
      -- DDR controller ports (this_has_ddr -> 1)
      ddr_ahbsi          : out ahb_slv_in_type;
      ddr_ahbso          : in  ahb_slv_out_type;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      -- NoC
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc            : in  monitor_noc_vector(1 to 6);
      mon_mem            : out monitor_mem_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component fpga_tile_slm;

end tiles_fpga_pkg;
