-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  NoC domain socket core
--  - This component groups multiple components present in all the tiles
--    in the NoC clock domain
--
--  Author: Davide Giri
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
use work.monitor_pkg.all;
use work.esp_noc_csr_pkg.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;
use work.misc.all;
use work.coretypes.all;
use work.esp_acc_regmap.all;
use work.socmap.all;
use work.grlib_config.all;
use work.tiles_pkg.all;
use work.dvfs.all;

entity noc_domain_socket is
  generic (
    this_has_token_pm : integer range 0 to 1 := 0;
    has_ddr           : boolean              := false;
    is_tile_io        : boolean              := false;
    SIMULATION        : boolean              := false;
    ROUTER_PORTS      : ports_vec            := "11111";
    HAS_SYNC          : integer range 0 to 1 := 1;
    is_asic           : boolean              := false
	);
  port (
    rst                : in  std_ulogic;
    noc_clk_lock       : in  std_ulogic;
    tile_rstn          : in  std_ulogic;
    noc_clk            : in  std_ulogic;  -- NoC clock
    tile_clk           : in  std_ulogic;
    noc_rstn           : out std_ulogic;
    raw_rstn           : out std_ulogic;
    acc_clk            : out std_ulogic;
    -- DCO config
    dco_freq_sel       : out std_logic_vector(1 downto 0);
    dco_div_sel        : out std_logic_vector(2 downto 0);
    dco_fc_sel         : out std_logic_vector(5 downto 0);
    dco_cc_sel         : out std_logic_vector(5 downto 0);
    dco_clk_sel        : out std_ulogic;
    dco_en             : out std_ulogic;
    dco_clk_delay_sel  : out std_logic_vector(11 downto 0);
    -- pad config
    pad_cfg            : out std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
    -- NoC
    noc1_data_n_in     : in  coh_noc_flit_type;
    noc1_data_s_in     : in  coh_noc_flit_type;
    noc1_data_w_in     : in  coh_noc_flit_type;
    noc1_data_e_in     : in  coh_noc_flit_type;
    noc1_data_void_in  : in  std_logic_vector(3 downto 0);
    noc1_stop_in       : in  std_logic_vector(3 downto 0);
    noc1_data_n_out    : out coh_noc_flit_type;
    noc1_data_s_out    : out coh_noc_flit_type;
    noc1_data_w_out    : out coh_noc_flit_type;
    noc1_data_e_out    : out coh_noc_flit_type;
    noc1_data_void_out : out std_logic_vector(3 downto 0);
    noc1_stop_out      : out std_logic_vector(3 downto 0);
    noc2_data_n_in     : in  coh_noc_flit_type;
    noc2_data_s_in     : in  coh_noc_flit_type;
    noc2_data_w_in     : in  coh_noc_flit_type;
    noc2_data_e_in     : in  coh_noc_flit_type;
    noc2_data_void_in  : in  std_logic_vector(3 downto 0);
    noc2_stop_in       : in  std_logic_vector(3 downto 0);
    noc2_data_n_out    : out coh_noc_flit_type;
    noc2_data_s_out    : out coh_noc_flit_type;
    noc2_data_w_out    : out coh_noc_flit_type;
    noc2_data_e_out    : out coh_noc_flit_type;
    noc2_data_void_out : out std_logic_vector(3 downto 0);
    noc2_stop_out      : out std_logic_vector(3 downto 0);
    noc3_data_n_in     : in  coh_noc_flit_type;
    noc3_data_s_in     : in  coh_noc_flit_type;
    noc3_data_w_in     : in  coh_noc_flit_type;
    noc3_data_e_in     : in  coh_noc_flit_type;
    noc3_data_void_in  : in  std_logic_vector(3 downto 0);
    noc3_stop_in       : in  std_logic_vector(3 downto 0);
    noc3_data_n_out    : out coh_noc_flit_type;
    noc3_data_s_out    : out coh_noc_flit_type;
    noc3_data_w_out    : out coh_noc_flit_type;
    noc3_data_e_out    : out coh_noc_flit_type;
    noc3_data_void_out : out std_logic_vector(3 downto 0);
    noc3_stop_out      : out std_logic_vector(3 downto 0);
    noc4_data_n_in     : in  dma_noc_flit_type;
    noc4_data_s_in     : in  dma_noc_flit_type;
    noc4_data_w_in     : in  dma_noc_flit_type;
    noc4_data_e_in     : in  dma_noc_flit_type;
    noc4_data_void_in  : in  std_logic_vector(3 downto 0);
    noc4_stop_in       : in  std_logic_vector(3 downto 0);
    noc4_data_n_out    : out dma_noc_flit_type;
    noc4_data_s_out    : out dma_noc_flit_type;
    noc4_data_w_out    : out dma_noc_flit_type;
    noc4_data_e_out    : out dma_noc_flit_type;
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
    noc6_data_n_in     : in  dma_noc_flit_type;
    noc6_data_s_in     : in  dma_noc_flit_type;
    noc6_data_w_in     : in  dma_noc_flit_type;
    noc6_data_e_in     : in  dma_noc_flit_type;
    noc6_data_void_in  : in  std_logic_vector(3 downto 0);
    noc6_stop_in       : in  std_logic_vector(3 downto 0);
    noc6_data_n_out    : out dma_noc_flit_type;
    noc6_data_s_out    : out dma_noc_flit_type;
    noc6_data_w_out    : out dma_noc_flit_type;
    noc6_data_e_out    : out dma_noc_flit_type;
    noc6_data_void_out : out std_logic_vector(3 downto 0);
    noc6_stop_out      : out std_logic_vector(3 downto 0);

    -- monitors
    mon_noc            : out monitor_noc_vector(1 to 6);
    acc_activity	   : in std_ulogic;
    LDOCTRL			   : out std_logic_vector(7 downto 0);

    -- synchronizers out to tile
    noc1_output_port_tile   : out coh_noc_flit_type;
    noc1_data_void_out_tile : out std_ulogic;
    noc1_stop_in_tile       : in  std_ulogic;
    noc2_output_port_tile   : out coh_noc_flit_type;
    noc2_data_void_out_tile : out std_ulogic;
    noc2_stop_in_tile       : in  std_ulogic;
    noc3_output_port_tile   : out coh_noc_flit_type;
    noc3_data_void_out_tile : out std_ulogic;
    noc3_stop_in_tile       : in  std_ulogic;
    noc4_output_port_tile   : out dma_noc_flit_type;
    noc4_data_void_out_tile : out std_ulogic;
    noc4_stop_in_tile       : in  std_ulogic;
    noc5_output_port_tile   : out misc_noc_flit_type;
    noc5_data_void_out_tile : out std_ulogic;
    noc5_stop_in_tile       : in  std_ulogic;
    noc6_output_port_tile   : out dma_noc_flit_type;
    noc6_data_void_out_tile : out std_ulogic;
    noc6_stop_in_tile       : in  std_ulogic;

    -- tile to synchronizers in
    noc1_input_port_tile   : in  coh_noc_flit_type;
    noc1_data_void_in_tile : in  std_ulogic;
    noc1_stop_out_tile     : out std_ulogic;
    noc2_input_port_tile   : in  coh_noc_flit_type;
    noc2_data_void_in_tile : in  std_ulogic;
    noc2_stop_out_tile     : out std_ulogic;
    noc3_input_port_tile   : in  coh_noc_flit_type;
    noc3_data_void_in_tile : in  std_ulogic;
    noc3_stop_out_tile     : out std_ulogic;
    noc4_input_port_tile   : in  dma_noc_flit_type;
    noc4_data_void_in_tile : in  std_ulogic;
    noc4_stop_out_tile     : out std_ulogic;
    noc5_input_port_tile   : in  misc_noc_flit_type;
    noc5_data_void_in_tile : in  std_ulogic;
    noc5_stop_out_tile     : out std_ulogic;
    noc6_input_port_tile   : in  dma_noc_flit_type;
    noc6_data_void_in_tile : in  std_ulogic;
    noc6_stop_out_tile     : out std_ulogic);
end entity noc_domain_socket;

architecture rtl of noc_domain_socket is

  -- Tile parameters
  signal this_local_y : local_yx;
  signal this_local_x : local_yx;

  -- Token-based power management config and status
  signal pm_config : pm_config_type;
  signal pm_status : pm_status_type;

  -- Tile parameters
  signal tile_config_int : std_logic_vector(ESP_NOC_CSR_WIDTH - 1 downto 0);

  signal tile_id : integer range 0 to CFG_TILES_NUM - 1;

  signal this_pindex    : integer range 0 to NAPBSLV - 1;
  signal this_paddr     : integer range 0 to 4095;
  signal this_pmask     : integer range 0 to 4095;
  signal this_paddr_ext : integer range 0 to 4095;
  signal this_pmask_ext : integer range 0 to 4095;
  signal this_pirq      : integer range 0 to NAHBIRQ - 1;

  signal this_csr_pindex  : integer range 0 to NAPBSLV - 1;
  signal this_csr_pconfig : apb_config_type;

  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := (
    0      => '1',                      -- CSRs
    1      => '1',                      -- ESP accelerator w/ DVFS controller
    others => '0');

  -- BUS
  signal apbi       : apb_slv_in_type;
  signal apbo       : apb_slv_out_vector;
  signal pready     : std_ulogic;
  signal pready_noc : std_ulogic;

  signal apb_snd_wrreq : std_ulogic;
  signal apb_rcv_rdreq : std_ulogic;

  -- NoC reset
  signal noc_rstn_s : std_ulogic;
  signal raw_rstn_s : std_ulogic;

  -- NoC signals
  signal noc1_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc1_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc1_stop_in_noc            : std_ulogic;
  signal noc1_stop_out_noc           : std_ulogic;
  signal noc1_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc1_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc1_data_void_in_noc       : std_ulogic;
  signal noc1_data_void_out_noc      : std_ulogic;
  signal noc2_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc2_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc2_stop_in_noc            : std_ulogic;
  signal noc2_stop_out_noc           : std_ulogic;
  signal noc2_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc2_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc2_data_void_in_noc       : std_ulogic;
  signal noc2_data_void_out_noc      : std_ulogic;
  signal noc3_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc3_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc3_stop_in_noc            : std_ulogic;
  signal noc3_stop_out_noc           : std_ulogic;
  signal noc3_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc3_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc3_data_void_in_noc       : std_ulogic;
  signal noc3_data_void_out_noc      : std_ulogic;
  signal noc4_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc4_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc4_stop_in_noc            : std_ulogic;
  signal noc4_stop_out_noc           : std_ulogic;
  signal noc4_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc4_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc4_data_void_in_noc       : std_ulogic;
  signal noc4_data_void_out_noc      : std_ulogic;
  signal noc5_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc5_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc5_stop_in_noc            : std_ulogic;
  signal noc5_stop_in_pm             : std_ulogic;
  signal noc5_stop_in_csr            : std_ulogic;
  signal noc5_stop_in_tile_int       : std_ulogic;
  signal noc5_stop_out_noc           : std_ulogic;
  signal noc5_stop_out_pm            : std_ulogic;
  signal noc5_stop_out_csr           : std_ulogic;
  signal noc5_stop_out_tile_int      : std_ulogic;
  signal noc5_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc5_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc5_data_void_in_noc       : std_ulogic;
  signal noc5_data_void_in_pm        : std_ulogic;
  signal noc5_data_void_in_csr       : std_ulogic;
  signal noc5_data_void_in_tile_int  : std_ulogic;
  signal noc5_data_void_out_noc      : std_ulogic;
  signal noc5_data_void_out_pm       : std_ulogic;
  signal noc5_data_void_out_csr      : std_ulogic;
  signal noc5_data_void_out_tile_int : std_ulogic;
  signal noc6_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc6_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc6_stop_in_noc            : std_ulogic;
  signal noc6_stop_out_noc           : std_ulogic;
  signal noc6_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc6_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc6_data_void_in_noc       : std_ulogic;
  signal noc6_data_void_out_noc      : std_ulogic;
  signal noc1_input_port             : coh_noc_flit_type;
  signal noc2_input_port             : coh_noc_flit_type;
  signal noc3_input_port             : coh_noc_flit_type;
  signal noc4_input_port             : dma_noc_flit_type;
  signal noc5_input_port             : misc_noc_flit_type;
  signal noc5_input_port_pm          : misc_noc_flit_type;
  signal noc5_input_port_csr         : misc_noc_flit_type;
  signal noc5_input_port_tile_int    : misc_noc_flit_type;
  signal noc6_input_port             : dma_noc_flit_type;
  signal noc1_output_port            : coh_noc_flit_type;
  signal noc2_output_port            : coh_noc_flit_type;
  signal noc3_output_port            : coh_noc_flit_type;
  signal noc4_output_port            : dma_noc_flit_type;
  signal noc5_output_port            : misc_noc_flit_type;
  signal noc5_output_port_pm         : misc_noc_flit_type;
  signal noc5_output_port_csr        : misc_noc_flit_type;
  signal noc5_output_port_tile_int   : misc_noc_flit_type;
  signal noc6_output_port            : dma_noc_flit_type;

  attribute keep : string;
  attribute keep of this_local_y                 : signal is "true";
  attribute keep of this_local_x                 : signal is "true";
  attribute keep of tile_config_int              : signal is "true";
  attribute keep of tile_id                      : signal is "true";
  attribute keep of apbi                         : signal is "true";
  attribute keep of apbo                         : signal is "true";
  attribute keep of pready                       : signal is "true";
  attribute keep of pready_noc                   : signal is "true";
  attribute keep of apb_snd_wrreq                : signal is "true";
  attribute keep of apb_rcv_rdreq                : signal is "true";
  attribute keep of noc1_stop_in_s               : signal is "true";
  attribute keep of noc1_stop_out_s              : signal is "true";
  attribute keep of noc1_stop_in_noc             : signal is "true";
  attribute keep of noc1_stop_out_noc            : signal is "true";
  attribute keep of noc1_data_void_in_s          : signal is "true";
  attribute keep of noc1_data_void_out_s         : signal is "true";
  attribute keep of noc1_data_void_in_noc        : signal is "true";
  attribute keep of noc1_data_void_out_noc       : signal is "true";
  attribute keep of noc2_stop_in_s               : signal is "true";
  attribute keep of noc2_stop_out_s              : signal is "true";
  attribute keep of noc2_stop_in_noc             : signal is "true";
  attribute keep of noc2_stop_out_noc            : signal is "true";
  attribute keep of noc2_data_void_in_s          : signal is "true";
  attribute keep of noc2_data_void_out_s         : signal is "true";
  attribute keep of noc2_data_void_in_noc        : signal is "true";
  attribute keep of noc2_data_void_out_noc       : signal is "true";
  attribute keep of noc3_stop_in_s               : signal is "true";
  attribute keep of noc3_stop_out_s              : signal is "true";
  attribute keep of noc3_stop_in_noc             : signal is "true";
  attribute keep of noc3_stop_out_noc            : signal is "true";
  attribute keep of noc3_data_void_in_s          : signal is "true";
  attribute keep of noc3_data_void_out_s         : signal is "true";
  attribute keep of noc3_data_void_in_noc        : signal is "true";
  attribute keep of noc3_data_void_out_noc       : signal is "true";
  attribute keep of noc4_stop_in_s               : signal is "true";
  attribute keep of noc4_stop_out_s              : signal is "true";
  attribute keep of noc4_stop_in_noc             : signal is "true";
  attribute keep of noc4_stop_out_noc            : signal is "true";
  attribute keep of noc4_data_void_in_s          : signal is "true";
  attribute keep of noc4_data_void_out_s         : signal is "true";
  attribute keep of noc4_data_void_in_noc        : signal is "true";
  attribute keep of noc4_data_void_out_noc       : signal is "true";
  attribute keep of noc5_stop_in_s               : signal is "true";
  attribute keep of noc5_stop_out_s              : signal is "true";
  attribute keep of noc5_stop_in_noc             : signal is "true";
  attribute keep of noc5_stop_in_pm              : signal is "true";
  attribute keep of noc5_stop_in_csr             : signal is "true";
  attribute keep of noc5_stop_in_tile_int        : signal is "true";
  attribute keep of noc5_stop_out_noc            : signal is "true";
  attribute keep of noc5_stop_out_pm             : signal is "true";
  attribute keep of noc5_stop_out_csr            : signal is "true";
  attribute keep of noc5_stop_out_tile_int       : signal is "true";
  attribute keep of noc5_data_void_in_s          : signal is "true";
  attribute keep of noc5_data_void_out_s         : signal is "true";
  attribute keep of noc5_data_void_in_noc        : signal is "true";
  attribute keep of noc5_data_void_in_pm         : signal is "true";
  attribute keep of noc5_data_void_in_csr        : signal is "true";
  attribute keep of noc5_data_void_in_tile_int   : signal is "true";
  attribute keep of noc5_data_void_out_noc       : signal is "true";
  attribute keep of noc5_data_void_out_pm        : signal is "true";
  attribute keep of noc5_data_void_out_csr       : signal is "true";
  attribute keep of noc5_data_void_out_tile_int  : signal is "true";
  attribute keep of noc6_stop_in_s               : signal is "true";
  attribute keep of noc6_stop_out_s              : signal is "true";
  attribute keep of noc6_stop_in_noc             : signal is "true";
  attribute keep of noc6_stop_out_noc            : signal is "true";
  attribute keep of noc6_data_void_in_s          : signal is "true";
  attribute keep of noc6_data_void_out_s         : signal is "true";
  attribute keep of noc6_data_void_in_noc        : signal is "true";
  attribute keep of noc6_data_void_out_noc       : signal is "true";
  attribute keep of noc1_input_port              : signal is "true";
  attribute keep of noc2_input_port              : signal is "true";
  attribute keep of noc3_input_port              : signal is "true";
  attribute keep of noc4_input_port              : signal is "true";
  attribute keep of noc5_input_port              : signal is "true";
  attribute keep of noc5_input_port_pm           : signal is "true";
  attribute keep of noc5_input_port_csr          : signal is "true";
  attribute keep of noc5_input_port_tile_int     : signal is "true";
  attribute keep of noc6_input_port              : signal is "true";
  attribute keep of noc1_output_port             : signal is "true";
  attribute keep of noc2_output_port             : signal is "true";
  attribute keep of noc3_output_port             : signal is "true";
  attribute keep of noc4_output_port             : signal is "true";
  attribute keep of noc5_output_port             : signal is "true";
  attribute keep of noc5_output_port_pm          : signal is "true";
  attribute keep of noc5_output_port_csr         : signal is "true";
  attribute keep of noc5_output_port_tile_int    : signal is "true";
  attribute keep of noc6_output_port             : signal is "true";

begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- NOC RESET
  -----------------------------------------------------------------------------
  rst_noc : rstgen
    generic map (acthigh => 1, syncin => 0)
    port map (rst, noc_clk, noc_clk_lock, noc_rstn_s, raw_rstn_s);

  noc_rstn <= noc_rstn_s;
  raw_rstn <= raw_rstn_s;

  -----------------------------------------------------------------------------
  -- NOC Connections
  ----------------------------------------------------------------------------
  noc1_stop_in_s         <= noc1_stop_in_noc & noc1_stop_in;
  noc1_stop_out          <= noc1_stop_out_s(3 downto 0);
  noc1_stop_out_noc      <= noc1_stop_out_s(4);
  noc1_data_void_in_s    <= noc1_data_void_in_noc & noc1_data_void_in;
  noc1_data_void_out     <= noc1_data_void_out_s(3 downto 0);
  noc1_data_void_out_noc <= noc1_data_void_out_s(4);
  noc2_stop_in_s         <= noc2_stop_in_noc & noc2_stop_in;
  noc2_stop_out          <= noc2_stop_out_s(3 downto 0);
  noc2_stop_out_noc      <= noc2_stop_out_s(4);
  noc2_data_void_in_s    <= noc2_data_void_in_noc & noc2_data_void_in;
  noc2_data_void_out     <= noc2_data_void_out_s(3 downto 0);
  noc2_data_void_out_noc <= noc2_data_void_out_s(4);
  noc3_stop_in_s         <= noc3_stop_in_noc & noc3_stop_in;
  noc3_stop_out          <= noc3_stop_out_s(3 downto 0);
  noc3_stop_out_noc      <= noc3_stop_out_s(4);
  noc3_data_void_in_s    <= noc3_data_void_in_noc & noc3_data_void_in;
  noc3_data_void_out     <= noc3_data_void_out_s(3 downto 0);
  noc3_data_void_out_noc <= noc3_data_void_out_s(4);
  noc4_stop_in_s         <= noc4_stop_in_noc & noc4_stop_in;
  noc4_stop_out          <= noc4_stop_out_s(3 downto 0);
  noc4_stop_out_noc      <= noc4_stop_out_s(4);
  noc4_data_void_in_s    <= noc4_data_void_in_noc & noc4_data_void_in;
  noc4_data_void_out     <= noc4_data_void_out_s(3 downto 0);
  noc4_data_void_out_noc <= noc4_data_void_out_s(4);
  noc5_stop_in_s         <= noc5_stop_in_noc & noc5_stop_in;
  noc5_stop_out          <= noc5_stop_out_s(3 downto 0);
  noc5_stop_out_noc      <= noc5_stop_out_s(4);
  noc5_data_void_in_s    <= noc5_data_void_in_noc & noc5_data_void_in;
  noc5_data_void_out     <= noc5_data_void_out_s(3 downto 0);
  noc5_data_void_out_noc <= noc5_data_void_out_s(4);
  noc6_stop_in_s         <= noc6_stop_in_noc & noc6_stop_in;
  noc6_stop_out          <= noc6_stop_out_s(3 downto 0);
  noc6_stop_out_noc      <= noc6_stop_out_s(4);
  noc6_data_void_in_s    <= noc6_data_void_in_noc & noc6_data_void_in;
  noc6_data_void_out     <= noc6_data_void_out_s(3 downto 0);
  noc6_data_void_out_noc <= noc6_data_void_out_s(4);

  noc1_output_port_tile   <= noc1_output_port;
  noc1_data_void_out_tile <= noc1_data_void_out_noc;
  noc1_stop_in_noc        <= noc1_stop_in_tile;
  noc2_output_port_tile   <= noc2_output_port;
  noc2_data_void_out_tile <= noc2_data_void_out_noc;
  noc2_stop_in_noc        <= noc2_stop_in_tile;
  noc3_output_port_tile   <= noc3_output_port;
  noc3_data_void_out_tile <= noc3_data_void_out_noc;
  noc3_stop_in_noc        <= noc3_stop_in_tile;
  noc4_output_port_tile   <= noc4_output_port;
  noc4_data_void_out_tile <= noc4_data_void_out_noc;
  noc4_stop_in_noc        <= noc4_stop_in_tile;
  noc6_output_port_tile   <= noc6_output_port;
  noc6_data_void_out_tile <= noc6_data_void_out_noc;
  noc6_stop_in_noc        <= noc6_stop_in_tile;

  noc1_input_port       <= noc1_input_port_tile;
  noc1_data_void_in_noc <= noc1_data_void_in_tile;
  noc1_stop_out_tile    <= noc1_stop_out_noc;
  noc2_input_port       <= noc2_input_port_tile;
  noc2_data_void_in_noc <= noc2_data_void_in_tile;
  noc2_stop_out_tile    <= noc2_stop_out_noc;
  noc3_input_port       <= noc3_input_port_tile;
  noc3_data_void_in_noc <= noc3_data_void_in_tile;
  noc3_stop_out_tile    <= noc3_stop_out_noc;
  noc4_input_port       <= noc4_input_port_tile;
  noc4_data_void_in_noc <= noc4_data_void_in_tile;
  noc4_stop_out_tile    <= noc4_stop_out_noc;
  noc6_input_port       <= noc6_input_port_tile;
  noc6_data_void_in_noc <= noc6_data_void_in_tile;
  noc6_stop_out_tile    <= noc6_stop_out_noc;

  no_noc_tile_sync_gen : if HAS_SYNC = 0 generate
    noc5_output_port_tile   <= noc5_output_port_tile_int;
    noc5_data_void_out_tile <= noc5_data_void_out_tile_int;
    noc5_stop_in_tile_int   <= noc5_stop_in_tile;

    noc5_input_port_tile_int   <= noc5_input_port_tile;
    noc5_data_void_in_tile_int <= noc5_data_void_in_tile;
    noc5_stop_out_tile         <= noc5_stop_out_tile_int;
  end generate;

  -- The noc_synchronizers component adds synchronizers between NoC and tile
  -- for NoC plane 5. The synchronizers for the other planes are instantiated inside the NoC (when the
  -- generic HAS_SYNC=1). For NoC plane 5 however, there is some logic that
  -- needs to sit in the NoC domain, between the NoC and the synchronizers. For
  -- that reason the synchronizers (noc_synchronizers component) are
  -- instantiated here instead of inside the NoC.
  noc_tile_sync_gen : if HAS_SYNC = 1 generate
    noc5_tile_synchronizers : noc32_synchronizers
      port map (
        noc_rstn  => noc_rstn_s,  -- noc_rstn for asic, rst for fpga
        tile_rstn => tile_rstn,  -- same
        noc_clk   => noc_clk,   -- noc_clk for asic, noc_clk_int for fpga
        tile_clk  => tile_clk,   -- tile_clk for asic, acc_clk for fpga

        output_port   => noc5_output_port_tile_int,
        data_void_out => noc5_data_void_out_tile_int,
        stop_in       => noc5_stop_in_tile_int,

        input_port   => noc5_input_port_tile_int,
        data_void_in => noc5_data_void_in_tile_int,
        stop_out     => noc5_stop_out_tile_int,

        output_port_tile   => noc5_output_port_tile,
        data_void_out_tile => noc5_data_void_out_tile,
        stop_in_tile       => noc5_stop_in_tile,

        input_port_tile   => noc5_input_port_tile,
        data_void_in_tile => noc5_data_void_in_tile,
        stop_out_tile     => noc5_stop_out_tile);
  end generate;

  -- HAS_SYNC = 0: no synchronizers in the NoC because
  -- they are already explicitly added in
  -- this asic_tile_acc entity (noc_synchronizers)
  sync_noc_set_acc : sync_noc_set
    generic map (
      PORTS    => ROUTER_PORTS,
      HAS_SYNC => HAS_SYNC)
    port map (
      clk                => noc_clk,    -- noc_clk_int
      clk_tile           => tile_clk,    -- acc_clk
      rst                => noc_rstn_s,   -- rst
      rst_tile           => tile_rstn,   -- tile_rstn
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
      noc1_mon_noc_vec   => mon_noc(1),
      noc2_mon_noc_vec   => mon_noc(2),
      noc3_mon_noc_vec   => mon_noc(3),
      noc4_mon_noc_vec   => mon_noc(4),
      noc5_mon_noc_vec   => mon_noc(5),
      noc6_mon_noc_vec   => mon_noc(6));

  token_pm_gen : if this_has_token_pm = 1 generate

    token_pm_i : token_pm
      generic map (
        SIMULATION => SIMULATION,
        is_asic    => true)
      port map (
        noc_rstn           => noc_rstn_s,
        tile_rstn          => tile_rstn,
        noc_clk            => noc_clk,
        tile_clk           => tile_clk,
        local_x            => this_local_x,
        local_y            => this_local_y,
        pm_config          => pm_config,
        pm_status          => pm_status,
        noc5_input_port    => noc5_input_port_pm,
        noc5_data_void_in  => noc5_data_void_in_pm,
        noc5_stop_out      => noc5_stop_out_pm,
        noc5_output_port   => noc5_output_port_pm,
        noc5_data_void_out => noc5_data_void_out_pm,
        noc5_stop_in       => noc5_stop_in_pm,
        acc_clk            => acc_clk,
        acc_activity       => acc_activity,
        LDOCTRL 		   => LDOCTRL
    );
  end generate;

  no_token_pm_gen : if this_has_token_pm = 0 generate
    acc_clk              <= tile_clk;
    pm_status            <= (others => (others => '0'));
    noc5_input_port_pm   <= (others => '0');
    noc5_data_void_in_pm <= '1';
    noc5_stop_in_pm      <= '0';
    LDOCTRL <= (others => '0');
  end generate;

  noc5_mux_i : noc5_mux
    port map (
      rstn                    => noc_rstn_s,
      clk                     => noc_clk,
      noc5_input_port         => noc5_input_port,
      noc5_data_void_in       => noc5_data_void_in_noc,
      noc5_stop_out           => noc5_stop_out_noc,
      noc5_output_port        => noc5_output_port,
      noc5_data_void_out      => noc5_data_void_out_noc,
      noc5_stop_in            => noc5_stop_in_noc,
      noc5_input_port_tile    => noc5_input_port_tile_int,
      noc5_data_void_in_tile  => noc5_data_void_in_tile_int,
      noc5_stop_out_tile      => noc5_stop_out_tile_int,
      noc5_output_port_tile   => noc5_output_port_tile_int,
      noc5_data_void_out_tile => noc5_data_void_out_tile_int,
      noc5_stop_in_tile       => noc5_stop_in_tile_int,
      noc5_input_port_csr     => noc5_input_port_csr,
      noc5_data_void_in_csr   => noc5_data_void_in_csr,
      noc5_stop_out_csr       => noc5_stop_out_csr,
      noc5_output_port_csr    => noc5_output_port_csr,
      noc5_data_void_out_csr  => noc5_data_void_out_csr,
      noc5_stop_in_csr        => noc5_stop_in_csr,
      noc5_input_port_pm      => noc5_input_port_pm,
      noc5_data_void_in_pm    => noc5_data_void_in_pm,
      noc5_stop_out_pm        => noc5_stop_out_pm,
      noc5_output_port_pm     => noc5_output_port_pm,
      noc5_data_void_out_pm   => noc5_data_void_out_pm,
      noc5_stop_in_pm         => noc5_stop_in_pm);

  -----------------------------------------------------------------------------
  -- Tile parameters
  -----------------------------------------------------------------------------

  is_tile_io_gen: if is_tile_io = true generate
    tile_id <= io_tile_id;
  end generate;
  is_not_tile_io_gen: if is_tile_io = false generate
    tile_id <= to_integer(unsigned(tile_config_int(ESP_CSR_TILE_ID_NOC_MSB downto ESP_CSR_TILE_ID_NOC_LSB)));    
  end generate;

  pad_cfg <= tile_config_int(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB);

  this_pindex    <= tile_apb_idx(tile_id);
  this_paddr     <= tile_apb_paddr(tile_id);
  this_pmask     <= tile_apb_pmask(tile_id);
  this_paddr_ext <= tile_apb_paddr_ext(tile_id);
  this_pmask_ext <= tile_apb_pmask_ext(tile_id);
  this_pirq      <= tile_apb_irq(tile_id);

  this_csr_pindex  <= tile_csr_pindex(tile_id);
  this_csr_pconfig <= fixed_apbo_pconfig(this_csr_pindex);

  this_local_y <= tile_y(tile_id);
  this_local_x <= tile_x(tile_id);

  dco_clk_delay_sel <= tile_config_int(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_MSB - 11);
  dco_freq_sel <= tile_config_int(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 0  downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 0  - 1);
  dco_div_sel  <= tile_config_int(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 2  downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 2  - 2);
  dco_fc_sel   <= tile_config_int(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 5  downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 5  - 5);
  dco_cc_sel   <= tile_config_int(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 11 downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 11 - 5);
  dco_clk_sel  <= tile_config_int(ESP_CSR_DCO_CFG_LSB + 1);
  dco_en       <= raw_rstn_s and tile_config_int(ESP_CSR_DCO_CFG_LSB);

  -- Using only one apbo signal
  no_apb : for i in 0 to NAPBSLV - 1 generate
    local_apb : if this_local_apb_en(i) = '0' generate
      apbo(i)      <= apb_none;
      apbo(i).pirq <= (others => '0');
    end generate local_apb;
  end generate no_apb;

  -- Connect pready for APB3 accelerators
  pready_gen : process (pready, apbi) is
  begin  -- process pready_gen
    if apbi.psel(1) = '1' then
      pready_noc <= pready;
    else
      pready_noc <= '1';
    end if;
  end process pready_gen;

  -- Memory mapped registers
  tile_csr_gen : esp_noc_csr
    generic map(
      pindex  => 0,
      has_token_pm => this_has_token_pm,
      has_ddr => has_ddr)
    port map(
      clk         => noc_clk,           -- noc_clk_int
      rstn        => noc_rstn_s,        -- rst
      pconfig     => this_csr_pconfig,
      tile_config => tile_config_int,
      pm_config   => pm_config,
      pm_status   => pm_status,
      apbi        => apbi,
      apbo        => apbo(0));

  -- APB proxy
  noc2apb_1 : noc2apb
    generic map (
      tech         => CFG_FABTECH,
      local_apb_en => this_local_apb_en)
    port map (
      rst              => noc_rstn_s,   -- rst
      clk              => noc_clk,      -- noc_clk_int
      local_y          => this_local_y,
      local_x          => this_local_x,
      apbi             => apbi,
      apbo             => apbo,
      pready           => pready_noc,
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => noc5_input_port_csr,
      apb_snd_full     => noc5_stop_out_csr,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => noc5_output_port_csr,
      apb_rcv_empty    => noc5_data_void_out_csr
      );

  noc5_data_void_in_csr <= not apb_snd_wrreq;
  noc5_stop_in_csr      <= not apb_rcv_rdreq;

end architecture rtl;
