-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Memory interface tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.ahb2mig_7series_pkg.all;
use work.coretypes.all;

use work.grlib_config.all;
use work.socmap.all;
use work.tiles_pkg.all;

entity asic_tile_mem_ddr is
  generic (
    SIMULATION   : boolean   := false;
    ROUTER_PORTS : ports_vec := "11111";
    this_has_dco : integer range 0 to 1 := 1;
    HAS_SYNC     : integer range 0 to 1 := 1;
    ROUTER_PORTS : ports_vec := "11111");
  port (
    rst                : in  std_ulogic;
    sys_clk            : in  std_ulogic;  -- NoC clock
    sys_clk_lock       : in  std_ulogic;  -- sys_clk_lock
    ext_clk            : in  std_ulogic;  -- backup tile clock
    clk_div            : out std_ulogic;  -- tile clock monitor for testing purposes
    -- LPDDR
    lpddr_o            : out lpddr_out_t;
    lpddr_i            : in  lpddr_in_t;
    -- Test interface
    tdi                : in  std_logic;
    tdo                : out std_logic;
    tms                : in  std_logic;
    tclk               : in  std_logic;
    -- Pad configuratio
    pad_cfg            : out std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
    -- NOC
    noc1_data_n_in     : in  noc_flit_type;
    noc1_data_s_in     : in  noc_flit_type;
    noc1_data_w_in     : in  noc_flit_type;
    noc1_data_e_in     : in  noc_flit_type;
    noc1_data_void_in  : in  std_logic_vector(3 downto 0);
    noc1_stop_in       : in  std_logic_vector(3 downto 0);
    noc1_data_n_out    : out noc_flit_type;
    noc1_data_s_out    : out noc_flit_type;
    noc1_data_w_out    : out noc_flit_type;
    noc1_data_e_out    : out noc_flit_type;
    noc1_data_void_out : out std_logic_vector(3 downto 0);
    noc1_stop_out      : out std_logic_vector(3 downto 0);
    noc2_data_n_in     : in  noc_flit_type;
    noc2_data_s_in     : in  noc_flit_type;
    noc2_data_w_in     : in  noc_flit_type;
    noc2_data_e_in     : in  noc_flit_type;
    noc2_data_void_in  : in  std_logic_vector(3 downto 0);
    noc2_stop_in       : in  std_logic_vector(3 downto 0);
    noc2_data_n_out    : out noc_flit_type;
    noc2_data_s_out    : out noc_flit_type;
    noc2_data_w_out    : out noc_flit_type;
    noc2_data_e_out    : out noc_flit_type;
    noc2_data_void_out : out std_logic_vector(3 downto 0);
    noc2_stop_out      : out std_logic_vector(3 downto 0);
    noc3_data_n_in     : in  noc_flit_type;
    noc3_data_s_in     : in  noc_flit_type;
    noc3_data_w_in     : in  noc_flit_type;
    noc3_data_e_in     : in  noc_flit_type;
    noc3_data_void_in  : in  std_logic_vector(3 downto 0);
    noc3_stop_in       : in  std_logic_vector(3 downto 0);
    noc3_data_n_out    : out noc_flit_type;
    noc3_data_s_out    : out noc_flit_type;
    noc3_data_w_out    : out noc_flit_type;
    noc3_data_e_out    : out noc_flit_type;
    noc3_data_void_out : out std_logic_vector(3 downto 0);
    noc3_stop_out      : out std_logic_vector(3 downto 0);
    noc4_data_n_in     : in  noc_flit_type;
    noc4_data_s_in     : in  noc_flit_type;
    noc4_data_w_in     : in  noc_flit_type;
    noc4_data_e_in     : in  noc_flit_type;
    noc4_data_void_in  : in  std_logic_vector(3 downto 0);
    noc4_stop_in       : in  std_logic_vector(3 downto 0);
    noc4_data_n_out    : out noc_flit_type;
    noc4_data_s_out    : out noc_flit_type;
    noc4_data_w_out    : out noc_flit_type;
    noc4_data_e_out    : out noc_flit_type;
    noc4_data_void_out : out std_logic_vector(3 downto 0);
    noc4_stop_out      : out std_logic_vector(3 downto 0);
    noc5_data_n_in     : in  misc_noc_flit_type;
    noc5_data_s_in     : in  misc_noc_flit_type;
    noc5_data_w_in     : in  misc_noc_flit_type;
    noc5_data_e_in     : in  misc_noc_flit_type;
    noc5_data_void_in  : in  std_logic_vector(3 downto 0);
    noc5_stop_in       : in  std_logic_vector(3 downto 0);
    noc5_data_n_out    : out misc_noc_flit_type;
    noc5_data_s_out    : out misc_noc_flit_type;
    noc5_data_w_out    : out misc_noc_flit_type;
    noc5_data_e_out    : out misc_noc_flit_type;
    noc5_data_void_out : out std_logic_vector(3 downto 0);
    noc5_stop_out      : out std_logic_vector(3 downto 0);
    noc6_data_n_in     : in  noc_flit_type;
    noc6_data_s_in     : in  noc_flit_type;
    noc6_data_w_in     : in  noc_flit_type;
    noc6_data_e_in     : in  noc_flit_type;
    noc6_data_void_in  : in  std_logic_vector(3 downto 0);
    noc6_stop_in       : in  std_logic_vector(3 downto 0);
    noc6_data_n_out    : out noc_flit_type;
    noc6_data_s_out    : out noc_flit_type;
    noc6_data_w_out    : out noc_flit_type;
    noc6_data_e_out    : out noc_flit_type;
    noc6_data_void_out : out std_logic_vector(3 downto 0);
    noc6_stop_out      : out std_logic_vector(3 downto 0));
end;


architecture rtl of asic_tile_mem_ddr is

  component ahb2bsg_dmc is
    port (
      hindex          : in  integer;
      haddr           : in  integer;
      hmask           : in  integer;
      lpddr_ck_p      : out std_logic;
      lpddr_ck_n      : out std_logic;
      lpddr_cke       : out std_logic;
      lpddr_ba        : out std_logic_vector(2 downto 0);
      lpddr_addr      : out std_logic_vector(15 downto 0);
      lpddr_cs_n      : out std_logic;
      lpddr_ras_n     : out std_logic;
      lpddr_cas_n     : out std_logic;
      lpddr_we_n      : out std_logic;
      lpddr_reset_n   : out std_logic;
      lpddr_odt       : out std_logic;
      lpddr_dm_oen    : out std_logic_vector(3 downto 0);
      lpddr_dm        : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_oen : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_ien : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_o   : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_i   : in  std_logic_vector(3 downto 0);
      lpddr_dqs_n_oen : out std_logic_vector(3 downto 0);
      lpddr_dqs_n_ien : out std_logic_vector(3 downto 0);
      lpddr_dqs_n_o   : out std_logic_vector(3 downto 0);
      lpddr_dqs_n_i   : in  std_logic_vector(3 downto 0);
      lpddr_dq_oen    : out std_logic_vector(31 downto 0);
      lpddr_dq_o      : out std_logic_vector(31 downto 0);
      lpddr_dq_i      : in  std_logic_vector(31 downto 0);
      ddr_cfg0        : in  std_logic_vector(31 downto 0);
      ddr_cfg1        : in  std_logic_vector(31 downto 0);
      ddr_cfg2        : in  std_logic_vector(31 downto 0);
      ahbso           : out ahb_slv_out_type;
      ahbsi           : in  ahb_slv_in_type;
      calib_done      : out std_logic;
      ui_clk          : in  std_logic;
      ui_rstn         : in  std_logic;
      phy_clk_1x      : in  std_logic;
      phy_clk_2x      : in  std_logic;
      phy_rstn        : in  std_logic);
  end component ahb2bsg_dmc;

  signal ddr_cfg0 : std_logic_vector(31 downto 0);
  signal ddr_cfg1 : std_logic_vector(31 downto 0);
  signal ddr_cfg1 : std_logic_vector(31 downto 0);

  signal ddr_id : integer range 0 to CFG_NDDR_TILE - 1;

  constant ext_clk_sel_default : std_ulogic := '0';

  constant DEFAULT_DCO_LPDDR_CFG : std_logic_vector(18 downto 0) :=
    "00" & "001" & "000000" & "110010" & "0" & "1";
  -- FREQ_SEL    DIV_SEL    FC_SEL      CC_SEL    CLK_SEL   EN

  -- Tile clock and reset (only for I/O tile)
  signal raw_rstn     : std_ulogic;
  signal dco_clk      : std_ulogic;
  signal dco_rstn     : std_ulogic;
  signal tile_rst     : std_ulogic;
--  signal dco_clk_lock : std_ulogic;

  -- Tile parameters
  signal this_local_y : local_yx;
  signal this_local_x : local_yx;

  signal phy_rstn, phy_raw_rstn : std_logic;

  signal test_rstn             : std_ulogic;
  signal test1_output_port_s   : noc_flit_type;
  signal test1_data_void_out_s : std_ulogic;
  signal test1_stop_in_s       : std_ulogic;
  signal test2_output_port_s   : noc_flit_type;
  signal test2_data_void_out_s : std_ulogic;
  signal test2_stop_in_s       : std_ulogic;
  signal test3_output_port_s   : noc_flit_type;
  signal test3_data_void_out_s : std_ulogic;
  signal test3_stop_in_s       : std_ulogic;
  signal test4_output_port_s   : noc_flit_type;
  signal test4_data_void_out_s : std_ulogic;
  signal test4_stop_in_s       : std_ulogic;
  signal test5_output_port_s   : misc_noc_flit_type;
  signal test5_data_void_out_s : std_ulogic;
  signal test5_stop_in_s       : std_ulogic;
  signal test6_output_port_s   : noc_flit_type;
  signal test6_data_void_out_s : std_ulogic;
  signal test6_stop_in_s       : std_ulogic;
  signal test1_input_port_s    : noc_flit_type;
  signal test1_data_void_in_s  : std_ulogic;
  signal test1_stop_out_s      : std_ulogic;
  signal test2_input_port_s    : noc_flit_type;
  signal test2_data_void_in_s  : std_ulogic;
  signal test2_stop_out_s      : std_ulogic;
  signal test3_input_port_s    : noc_flit_type;
  signal test3_data_void_in_s  : std_ulogic;
  signal test3_stop_out_s      : std_ulogic;
  signal test4_input_port_s    : noc_flit_type;
  signal test4_data_void_in_s  : std_ulogic;
  signal test4_stop_out_s      : std_ulogic;
  signal test5_input_port_s    : misc_noc_flit_type;
  signal test5_data_void_in_s  : std_ulogic;
  signal test5_stop_out_s      : std_ulogic;
  signal test6_input_port_s    : noc_flit_type;
  signal test6_data_void_in_s  : std_ulogic;
  signal test6_stop_out_s      : std_ulogic;

  signal noc1_mon_noc_vec_int  : monitor_noc_type;
  signal noc2_mon_noc_vec_int  : monitor_noc_type;
  signal noc3_mon_noc_vec_int  : monitor_noc_type;
  signal noc4_mon_noc_vec_int  : monitor_noc_type;
  signal noc5_mon_noc_vec_int  : monitor_noc_type;
  signal noc6_mon_noc_vec_int  : monitor_noc_type;

  -- Noc signals
  signal noc_rstn               : std_ulogic;
  signal noc1_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc1_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc1_mem_stop_in       : std_ulogic;
  signal noc1_mem_stop_out      : std_ulogic;
  signal noc1_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc1_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc1_mem_data_void_in  : std_ulogic;
  signal noc1_mem_data_void_out : std_ulogic;
  signal noc2_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc2_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc2_mem_stop_in       : std_ulogic;
  signal noc2_mem_stop_out      : std_ulogic;
  signal noc2_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc2_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc2_mem_data_void_in  : std_ulogic;
  signal noc2_mem_data_void_out : std_ulogic;
  signal noc3_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc3_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc3_mem_stop_in       : std_ulogic;
  signal noc3_mem_stop_out      : std_ulogic;
  signal noc3_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc3_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc3_mem_data_void_in  : std_ulogic;
  signal noc3_mem_data_void_out : std_ulogic;
  signal noc4_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc4_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc4_mem_stop_in       : std_ulogic;
  signal noc4_mem_stop_out      : std_ulogic;
  signal noc4_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc4_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc4_mem_data_void_in  : std_ulogic;
  signal noc4_mem_data_void_out : std_ulogic;
  signal noc5_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc5_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc5_mem_stop_in       : std_ulogic;
  signal noc5_mem_stop_out      : std_ulogic;
  signal noc5_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc5_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc5_mem_data_void_in  : std_ulogic;
  signal noc5_mem_data_void_out : std_ulogic;
  signal noc6_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc6_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc6_mem_stop_in       : std_ulogic;
  signal noc6_mem_stop_out      : std_ulogic;
  signal noc6_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc6_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc6_mem_data_void_in  : std_ulogic;
  signal noc6_mem_data_void_out : std_ulogic;
  signal noc1_input_port        : noc_flit_type;
  signal noc2_input_port        : noc_flit_type;
  signal noc3_input_port        : noc_flit_type;
  signal noc4_input_port        : noc_flit_type;
  signal noc5_input_port        : misc_noc_flit_type;
  signal noc6_input_port        : noc_flit_type;
  signal noc1_output_port       : noc_flit_type;
  signal noc2_output_port       : noc_flit_type;
  signal noc3_output_port       : noc_flit_type;
  signal noc4_output_port       : noc_flit_type;
  signal noc5_output_port       : misc_noc_flit_type;
  signal noc6_output_port       : noc_flit_type;

  attribute keep              : string;
  attribute keep of noc1_mem_stop_in       : signal is "true";
  attribute keep of noc1_mem_stop_out      : signal is "true";
  attribute keep of noc1_mem_data_void_in  : signal is "true";
  attribute keep of noc1_mem_data_void_out : signal is "true";
  attribute keep of noc1_input_port        : signal is "true";
  attribute keep of noc1_output_port       : signal is "true";
  attribute keep of noc1_data_n_in     : signal is "true";
  attribute keep of noc1_data_s_in     : signal is "true";
  attribute keep of noc1_data_w_in     : signal is "true";
  attribute keep of noc1_data_e_in     : signal is "true";
  attribute keep of noc1_data_void_in  : signal is "true";
  attribute keep of noc1_stop_in       : signal is "true";
  attribute keep of noc1_data_n_out    : signal is "true";
  attribute keep of noc1_data_s_out    : signal is "true";
  attribute keep of noc1_data_w_out    : signal is "true";
  attribute keep of noc1_data_e_out    : signal is "true";
  attribute keep of noc1_data_void_out : signal is "true";
  attribute keep of noc1_stop_out      : signal is "true";
  attribute keep of noc2_mem_stop_in       : signal is "true";
  attribute keep of noc2_mem_stop_out      : signal is "true";
  attribute keep of noc2_mem_data_void_in  : signal is "true";
  attribute keep of noc2_mem_data_void_out : signal is "true";
  attribute keep of noc2_input_port        : signal is "true";
  attribute keep of noc2_output_port       : signal is "true";
  attribute keep of noc2_data_n_in     : signal is "true";
  attribute keep of noc2_data_s_in     : signal is "true";
  attribute keep of noc2_data_w_in     : signal is "true";
  attribute keep of noc2_data_e_in     : signal is "true";
  attribute keep of noc2_data_void_in  : signal is "true";
  attribute keep of noc2_stop_in       : signal is "true";
  attribute keep of noc2_data_n_out    : signal is "true";
  attribute keep of noc2_data_s_out    : signal is "true";
  attribute keep of noc2_data_w_out    : signal is "true";
  attribute keep of noc2_data_e_out    : signal is "true";
  attribute keep of noc2_data_void_out : signal is "true";
  attribute keep of noc2_stop_out      : signal is "true";
  attribute keep of noc3_mem_stop_in       : signal is "true";
  attribute keep of noc3_mem_stop_out      : signal is "true";
  attribute keep of noc3_mem_data_void_in  : signal is "true";
  attribute keep of noc3_mem_data_void_out : signal is "true";
  attribute keep of noc3_input_port        : signal is "true";
  attribute keep of noc3_output_port       : signal is "true";
  attribute keep of noc3_data_n_in     : signal is "true";
  attribute keep of noc3_data_s_in     : signal is "true";
  attribute keep of noc3_data_w_in     : signal is "true";
  attribute keep of noc3_data_e_in     : signal is "true";
  attribute keep of noc3_data_void_in  : signal is "true";
  attribute keep of noc3_stop_in       : signal is "true";
  attribute keep of noc3_data_n_out    : signal is "true";
  attribute keep of noc3_data_s_out    : signal is "true";
  attribute keep of noc3_data_w_out    : signal is "true";
  attribute keep of noc3_data_e_out    : signal is "true";
  attribute keep of noc3_data_void_out : signal is "true";
  attribute keep of noc3_stop_out      : signal is "true";
  attribute keep of noc4_mem_stop_in       : signal is "true";
  attribute keep of noc4_mem_stop_out      : signal is "true";
  attribute keep of noc4_mem_data_void_in  : signal is "true";
  attribute keep of noc4_mem_data_void_out : signal is "true";
  attribute keep of noc4_input_port        : signal is "true";
  attribute keep of noc4_output_port       : signal is "true";
  attribute keep of noc4_data_n_in     : signal is "true";
  attribute keep of noc4_data_s_in     : signal is "true";
  attribute keep of noc4_data_w_in     : signal is "true";
  attribute keep of noc4_data_e_in     : signal is "true";
  attribute keep of noc4_data_void_in  : signal is "true";
  attribute keep of noc4_stop_in       : signal is "true";
  attribute keep of noc4_data_n_out    : signal is "true";
  attribute keep of noc4_data_s_out    : signal is "true";
  attribute keep of noc4_data_w_out    : signal is "true";
  attribute keep of noc4_data_e_out    : signal is "true";
  attribute keep of noc4_data_void_out : signal is "true";
  attribute keep of noc4_stop_out      : signal is "true";
  attribute keep of noc5_mem_stop_in       : signal is "true";
  attribute keep of noc5_mem_stop_out      : signal is "true";
  attribute keep of noc5_mem_data_void_in  : signal is "true";
  attribute keep of noc5_mem_data_void_out : signal is "true";
  attribute keep of noc5_input_port        : signal is "true";
  attribute keep of noc5_output_port       : signal is "true";
  attribute keep of noc5_data_n_in     : signal is "true";
  attribute keep of noc5_data_s_in     : signal is "true";
  attribute keep of noc5_data_w_in     : signal is "true";
  attribute keep of noc5_data_e_in     : signal is "true";
  attribute keep of noc5_data_void_in  : signal is "true";
  attribute keep of noc5_stop_in       : signal is "true";
  attribute keep of noc5_data_n_out    : signal is "true";
  attribute keep of noc5_data_s_out    : signal is "true";
  attribute keep of noc5_data_w_out    : signal is "true";
  attribute keep of noc5_data_e_out    : signal is "true";
  attribute keep of noc5_data_void_out : signal is "true";
  attribute keep of noc5_stop_out      : signal is "true";
  attribute keep of noc6_mem_stop_in       : signal is "true";
  attribute keep of noc6_mem_stop_out      : signal is "true";
  attribute keep of noc6_mem_data_void_in  : signal is "true";
  attribute keep of noc6_mem_data_void_out : signal is "true";
  attribute keep of noc6_input_port        : signal is "true";
  attribute keep of noc6_output_port       : signal is "true";
  attribute keep of noc6_data_n_in     : signal is "true";
  attribute keep of noc6_data_s_in     : signal is "true";
  attribute keep of noc6_data_w_in     : signal is "true";
  attribute keep of noc6_data_e_in     : signal is "true";
  attribute keep of noc6_data_void_in  : signal is "true";
  attribute keep of noc6_stop_in       : signal is "true";
  attribute keep of noc6_data_n_out    : signal is "true";
  attribute keep of noc6_data_s_out    : signal is "true";
  attribute keep of noc6_data_w_out    : signal is "true";
  attribute keep of noc6_data_e_out    : signal is "true";
  attribute keep of noc6_data_void_out : signal is "true";
  attribute keep of noc6_stop_out      : signal is "true";


begin

  rst_noc : rstgen
    generic map (acthigh => 1, syncin => 0)
    port map (rst, sys_clk, sys_clk_lock, noc_rstn, raw_rstn);

  rst_jtag : rstgen
    generic map (acthigh => 1, syncin => 0)
    port map (rst, tclk, '1', test_rstn, open);

  has_dco_rst : if this_has_dco = 1 generate
    tile_rst <= rst;
  end generate has_dco_rst;

  no_dco_rst : if this_has_dco /= 1 generate
    tile_rst <= noc_rstn;
  end generate no_dco_rst;

  -- DDR controller
  ahb2bsg_dmc_1 : ahb2bsg_dmc
    port map (
      hindex          => ddr_hindex(ddr_id),
      haddr           => ddr_haddr(ddr_id),
      hmask           => ddr_hmask(ddr_id),
      lpddr_ck_p      => lpddr_o.lpddr_ck_p,
      lpddr_ck_n      => lpddr_o.lpddr_ck_n,
      lpddr_cke       => lpddr_o.lpddr_cke,
      lpddr_ba        => lpddr_o.lpddr_ba,
      lpddr_addr      => lpddr_o.lpddr_addr,
      lpddr_cs_n      => lpddr_o.lpddr_cs_n,
      lpddr_ras_n     => lpddr_o.lpddr_ras_n,
      lpddr_cas_n     => lpddr_o.lpddr_cas_n,
      lpddr_we_n      => lpddr_o.lpddr_we_n,
      lpddr_reset_n   => lpddr_o.lpddr_reset_n,
      lpddr_odt       => lpddr_o.lpddr_odt,
      lpddr_dm_oen    => lpddr_o.lpddr_dm_oen,
      lpddr_dm        => lpddr_o.lpddr_dm,
      lpddr_dqs_p_oen => lpddr_o.lpddr_dqs_p_oen,
      lpddr_dqs_p_ien => lpddr_o.lpddr_dqs_p_ien,
      lpddr_dqs_p_o   => lpddr_o.lpddr_dqs_p_o,
      lpddr_dqs_p_i   => lpddr_i.lpddr_dqs_p_i,
      lpddr_dqs_n_oen => lpddr_o.lpddr_dqs_n_oen,
      lpddr_dqs_n_ien => lpddr_o.lpddr_dqs_n_ien,
      lpddr_dqs_n_o   => lpddr_o.lpddr_dqs_n_o,
      lpddr_dqs_n_i   => lpddr_i.lpddr_dqs_n_i,
      lpddr_dq_oen    => lpddr_o.lpddr_dq_oen,
      lpddr_dq_o      => lpddr_o.lpddr_dq_o,
      lpddr_dq_i      => lpddr_i.lpddr_dq_i,
      ahbso           => ahbso,
      ahbsi           => ahbsi,
      calib_done      => calib_done,
      ui_clk          => dco_clk_div2_90,
      ui_rstn         => dco_rstn,
      phy_clk_1x      => dco_clk_div2,
      phy_clk_2x      => dco_clk,
      phy_rstn        => phy_rstn);

  -----------------------------------------------------------------------------
  -- JTAG for single tile testing / bypass when test_if_en = 0
  -----------------------------------------------------------------------------
  jtag_test_i : jtag_test
    generic map (
      test_if_en => CFG_JTAG_EN)
    port map (
      rst                 => test_rstn,
      --refclk              => clk_feedthru,
      refclk              => dco_clk,
      tile_rst            => dco_rstn,
      tdi                 => tdi,
      tdo                 => tdo,
      tms                 => tms,
      tclk                => tclk,
      noc1_output_port    => noc1_output_port,
      noc1_data_void_out  => noc1_mem_data_void_out,
      noc1_stop_in        => noc1_mem_stop_in,
      noc2_output_port    => noc2_output_port,
      noc2_data_void_out  => noc2_mem_data_void_out,
      noc2_stop_in        => noc2_mem_stop_in,
      noc3_output_port    => noc3_output_port,
      noc3_data_void_out  => noc3_mem_data_void_out,
      noc3_stop_in        => noc3_mem_stop_in,
      noc4_output_port    => noc4_output_port,
      noc4_data_void_out  => noc4_mem_data_void_out,
      noc4_stop_in        => noc4_mem_stop_in,
      noc5_output_port    => noc5_output_port,
      noc5_data_void_out  => noc5_mem_data_void_out,
      noc5_stop_in        => noc5_mem_stop_in,
      noc6_output_port    => noc6_output_port,
      noc6_data_void_out  => noc6_mem_data_void_out,
      noc6_stop_in        => noc6_mem_stop_in,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_in_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_out_s,
      noc1_input_port     => noc1_input_port,
      noc1_data_void_in   => noc1_mem_data_void_in,
      noc1_stop_out       => noc1_mem_stop_out,
      noc2_input_port     => noc2_input_port,
      noc2_data_void_in   => noc2_mem_data_void_in,
      noc2_stop_out       => noc2_mem_stop_out,
      noc3_input_port     => noc3_input_port,
      noc3_data_void_in   => noc3_mem_data_void_in,
      noc3_stop_out       => noc3_mem_stop_out,
      noc4_input_port     => noc4_input_port,
      noc4_data_void_in   => noc4_mem_data_void_in,
      noc4_stop_out       => noc4_mem_stop_out,
      noc5_input_port     => noc5_input_port,
      noc5_data_void_in   => noc5_mem_data_void_in,
      noc5_stop_out       => noc5_mem_stop_out,
      noc6_input_port     => noc6_input_port,
      noc6_data_void_in   => noc6_mem_data_void_in,
      noc6_stop_out       => noc6_mem_stop_out);

  -----------------------------------------------------------------------------
  -- NOC Connections
  ----------------------------------------------------------------------------
  noc1_stop_in_s         <= noc1_mem_stop_in  & noc1_stop_in;
  noc1_stop_out          <= noc1_stop_out_s(3 downto 0);
  noc1_mem_stop_out      <= noc1_stop_out_s(4);
  noc1_data_void_in_s    <= noc1_mem_data_void_in & noc1_data_void_in;
  noc1_data_void_out     <= noc1_data_void_out_s(3 downto 0);
  noc1_mem_data_void_out <= noc1_data_void_out_s(4);
  noc2_stop_in_s         <= noc2_mem_stop_in  & noc2_stop_in;
  noc2_stop_out          <= noc2_stop_out_s(3 downto 0);
  noc2_mem_stop_out      <= noc2_stop_out_s(4);
  noc2_data_void_in_s    <= noc2_mem_data_void_in & noc2_data_void_in;
  noc2_data_void_out     <= noc2_data_void_out_s(3 downto 0);
  noc2_mem_data_void_out <= noc2_data_void_out_s(4);
  noc3_stop_in_s         <= noc3_mem_stop_in  & noc3_stop_in;
  noc3_stop_out          <= noc3_stop_out_s(3 downto 0);
  noc3_mem_stop_out      <= noc3_stop_out_s(4);
  noc3_data_void_in_s    <= noc3_mem_data_void_in & noc3_data_void_in;
  noc3_data_void_out     <= noc3_data_void_out_s(3 downto 0);
  noc3_mem_data_void_out <= noc3_data_void_out_s(4);
  noc4_stop_in_s         <= noc4_mem_stop_in  & noc4_stop_in;
  noc4_stop_out          <= noc4_stop_out_s(3 downto 0);
  noc4_mem_stop_out      <= noc4_stop_out_s(4);
  noc4_data_void_in_s    <= noc4_mem_data_void_in & noc4_data_void_in;
  noc4_data_void_out     <= noc4_data_void_out_s(3 downto 0);
  noc4_mem_data_void_out <= noc4_data_void_out_s(4);
  noc5_stop_in_s         <= noc5_mem_stop_in  & noc5_stop_in;
  noc5_stop_out          <= noc5_stop_out_s(3 downto 0);
  noc5_mem_stop_out      <= noc5_stop_out_s(4);
  noc5_data_void_in_s    <= noc5_mem_data_void_in & noc5_data_void_in;
  noc5_data_void_out     <= noc5_data_void_out_s(3 downto 0);
  noc5_mem_data_void_out <= noc5_data_void_out_s(4);
  noc6_stop_in_s         <= noc6_mem_stop_in  & noc6_stop_in;
  noc6_stop_out          <= noc6_stop_out_s(3 downto 0);
  noc6_mem_stop_out      <= noc6_stop_out_s(4);
  noc6_data_void_in_s    <= noc6_mem_data_void_in & noc6_data_void_in;
  noc6_data_void_out     <= noc6_data_void_out_s(3 downto 0);
  noc6_mem_data_void_out <= noc6_data_void_out_s(4);

  sync_noc_set_mem: sync_noc_set
  generic map (
     PORTS    => ROUTER_PORTS,
     HAS_SYNC => HAS_SYNC)
   port map (
     clk                => sys_clk,
     clk_tile           => dco_clk,
     rst                => noc_rstn,
     rst_tile           => dco_rstn,
     CONST_local_x      => this_local_x,
     CONST_local_y      => this_local_y,
     noc1_data_n_in     => noc1_data_n_in,
     noc1_data_s_in     => noc1_data_s_in,
     noc1_data_w_in     => noc1_data_w_in,
     noc1_data_e_in     => noc1_data_e_in,
     noc1_input_port    => noc1_input_port,
     noc1_data_void_in  => noc1_data_void_in_s,
     noc1_stop_in       => noc1_stop_in_s,
     noc1_data_n_out    => noc1_data_n_out,
     noc1_data_s_out    => noc1_data_s_out,
     noc1_data_w_out    => noc1_data_w_out,
     noc1_data_e_out    => noc1_data_e_out,
     noc1_output_port   => noc1_output_port,
     noc1_data_void_out => noc1_data_void_out_s,
     noc1_stop_out      => noc1_stop_out_s,
     noc2_data_n_in     => noc2_data_n_in,
     noc2_data_s_in     => noc2_data_s_in,
     noc2_data_w_in     => noc2_data_w_in,
     noc2_data_e_in     => noc2_data_e_in,
     noc2_input_port    => noc2_input_port,
     noc2_data_void_in  => noc2_data_void_in_s,
     noc2_stop_in       => noc2_stop_in_s,
     noc2_data_n_out    => noc2_data_n_out,
     noc2_data_s_out    => noc2_data_s_out,
     noc2_data_w_out    => noc2_data_w_out,
     noc2_data_e_out    => noc2_data_e_out,
     noc2_output_port   => noc2_output_port,
     noc2_data_void_out => noc2_data_void_out_s,
     noc2_stop_out      => noc2_stop_out_s,
     noc3_data_n_in     => noc3_data_n_in,
     noc3_data_s_in     => noc3_data_s_in,
     noc3_data_w_in     => noc3_data_w_in,
     noc3_data_e_in     => noc3_data_e_in,
     noc3_input_port    => noc3_input_port,
     noc3_data_void_in  => noc3_data_void_in_s,
     noc3_stop_in       => noc3_stop_in_s,
     noc3_data_n_out    => noc3_data_n_out,
     noc3_data_s_out    => noc3_data_s_out,
     noc3_data_w_out    => noc3_data_w_out,
     noc3_data_e_out    => noc3_data_e_out,
     noc3_output_port   => noc3_output_port,
     noc3_data_void_out => noc3_data_void_out_s,
     noc3_stop_out      => noc3_stop_out_s,
     noc4_data_n_in     => noc4_data_n_in,
     noc4_data_s_in     => noc4_data_s_in,
     noc4_data_w_in     => noc4_data_w_in,
     noc4_data_e_in     => noc4_data_e_in,
     noc4_input_port    => noc4_input_port,
     noc4_data_void_in  => noc4_data_void_in_s,
     noc4_stop_in       => noc4_stop_in_s,
     noc4_data_n_out    => noc4_data_n_out,
     noc4_data_s_out    => noc4_data_s_out,
     noc4_data_w_out    => noc4_data_w_out,
     noc4_data_e_out    => noc4_data_e_out,
     noc4_output_port   => noc4_output_port,
     noc4_data_void_out => noc4_data_void_out_s,
     noc4_stop_out      => noc4_stop_out_s,
     noc5_data_n_in     => noc5_data_n_in,
     noc5_data_s_in     => noc5_data_s_in,
     noc5_data_w_in     => noc5_data_w_in,
     noc5_data_e_in     => noc5_data_e_in,
     noc5_input_port    => noc5_input_port,
     noc5_data_void_in  => noc5_data_void_in_s,
     noc5_stop_in       => noc5_stop_in_s,
     noc5_data_n_out    => noc5_data_n_out,
     noc5_data_s_out    => noc5_data_s_out,
     noc5_data_w_out    => noc5_data_w_out,
     noc5_data_e_out    => noc5_data_e_out,
     noc5_output_port   => noc5_output_port,
     noc5_data_void_out => noc5_data_void_out_s,
     noc5_stop_out      => noc5_stop_out_s,
     noc6_data_n_in     => noc6_data_n_in,
     noc6_data_s_in     => noc6_data_s_in,
     noc6_data_w_in     => noc6_data_w_in,
     noc6_data_e_in     => noc6_data_e_in,
     noc6_input_port    => noc6_input_port,
     noc6_data_void_in  => noc6_data_void_in_s,
     noc6_stop_in       => noc6_stop_in_s,
     noc6_data_n_out    => noc6_data_n_out,
     noc6_data_s_out    => noc6_data_s_out,
     noc6_data_w_out    => noc6_data_w_out,
     noc6_data_e_out    => noc6_data_e_out,
     noc6_output_port   => noc6_output_port,
     noc6_data_void_out => noc6_data_void_out_s,
     noc6_stop_out      => noc6_stop_out_s,
     noc1_mon_noc_vec   => noc1_mon_noc_vec_int,
     noc2_mon_noc_vec   => noc2_mon_noc_vec_int,
     noc3_mon_noc_vec   => noc3_mon_noc_vec_int,
     noc4_mon_noc_vec   => noc4_mon_noc_vec_int,
     noc5_mon_noc_vec   => noc5_mon_noc_vec_int,
     noc6_mon_noc_vec   => noc6_mon_noc_vec_int
     );


  tile_mem_1 : tile_mem
    generic map (
      SIMULATION   => SIMULATION,
      this_has_dco => this_has_dco,
      this_has_ddr => 1,
      dco_rst_cfg  => DEFAULT_DCO_LPDDR_CFG)
    port map (
      raw_rstn           => raw_rstn,   -- DCO raw reset
      tile_rst           => tile_rst,   -- tile main synchronouse reset
      refclk             => ext_clk,    -- external backup clock
      clk                => dco_clk_div2_90,      -- tile main clock
      pllbypass          => ext_clk_sel_default,  -- ext_clk_sel,
      pllclk             => clk_div,    -- test clock output to PCB
      dco_clk            => dco_clk,    -- DDR PHY 2x clock
      dco_rstn           => dco_rstn,
      phy_rstn           => phy_rstn,
      dco_clk_div2       => dco_clk_div2,         -- DDR PHY 1x clock
      dco_clk_div2_90    => dco_clk_div2_90,      -- user clock
      ddr_ahbsi          => ddr_ahbsi,
      ddr_ahbso          => ddr_ahbso,
      ddr_cfg0           => ddr_cfg0,
      ddr_cfg1           => ddr_cfg1,
      ddr_cfg2           => ddr_cfg2,
      ddr_id             => ddr_id,
      fpga_data_in       => (others => '0'),
      fpga_data_out      => open,
      fpga_oen           => open,
      fpga_valid_in      => '0',
      fpga_valid_out     => open,
      fpga_clk_in        => '0',
      fpga_clk_out       => open,
      fpga_credit_in     => '0',
      fpga_credit_out    => open,
      pad_cfg            => pad_cfg,
      local_x            => this_local_x,
      local_y            => this_local_y,
      noc1_mon_noc_vec   => noc1_mon_noc_vec_int,
      noc2_mon_noc_vec   => noc2_mon_noc_vec_int,
      noc3_mon_noc_vec   => noc3_mon_noc_vec_int,
      noc4_mon_noc_vec   => noc4_mon_noc_vec_int,
      noc5_mon_noc_vec   => noc5_mon_noc_vec_int,
      noc6_mon_noc_vec   => noc6_mon_noc_vec_int,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_out_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_in_s,
      mon_mem            => open,
      mon_cache          => open,
      mon_dvfs           => open);

end;
