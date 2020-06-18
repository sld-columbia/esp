-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Accelerator Tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;
use work.coretypes.all;
use work.acctypes.all;
use work.socmap.all;
use work.grlib_config.all;

entity tile_acc is
  generic (
    tile_id : integer range 0 to CFG_TILES_NUM - 1 := 0;
    HAS_SYNC : integer range 0 to 1 := 0 );
  port (
    rst                : in  std_ulogic;
    refclk             : in  std_ulogic;
    pllbypass          : in  std_ulogic;
    pllclk             : out std_ulogic;
    -- NOC
    sys_clk_int        : in  std_logic;
    noc1_data_n_in     : in  noc_flit_type;
    noc1_data_s_in     : in  noc_flit_type;
    noc1_data_w_in     : in  noc_flit_type;
    noc1_data_e_in     : in  noc_flit_type;
    noc1_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc1_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc1_data_n_out    : out noc_flit_type;
    noc1_data_s_out    : out noc_flit_type;
    noc1_data_w_out    : out noc_flit_type;
    noc1_data_e_out    : out noc_flit_type;
    noc1_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc1_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc2_data_n_in     : in  noc_flit_type;
    noc2_data_s_in     : in  noc_flit_type;
    noc2_data_w_in     : in  noc_flit_type;
    noc2_data_e_in     : in  noc_flit_type;
    noc2_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc2_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc2_data_n_out    : out noc_flit_type;
    noc2_data_s_out    : out noc_flit_type;
    noc2_data_w_out    : out noc_flit_type;
    noc2_data_e_out    : out noc_flit_type;
    noc2_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc2_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc3_data_n_in     : in  noc_flit_type;
    noc3_data_s_in     : in  noc_flit_type;
    noc3_data_w_in     : in  noc_flit_type;
    noc3_data_e_in     : in  noc_flit_type;
    noc3_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc3_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc3_data_n_out    : out noc_flit_type;
    noc3_data_s_out    : out noc_flit_type;
    noc3_data_w_out    : out noc_flit_type;
    noc3_data_e_out    : out noc_flit_type;
    noc3_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc3_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc4_data_n_in     : in  noc_flit_type;
    noc4_data_s_in     : in  noc_flit_type;
    noc4_data_w_in     : in  noc_flit_type;
    noc4_data_e_in     : in  noc_flit_type;
    noc4_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc4_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc4_data_n_out    : out noc_flit_type;
    noc4_data_s_out    : out noc_flit_type;
    noc4_data_w_out    : out noc_flit_type;
    noc4_data_e_out    : out noc_flit_type;
    noc4_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc4_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc5_data_n_in     : in  misc_noc_flit_type;
    noc5_data_s_in     : in  misc_noc_flit_type;
    noc5_data_w_in     : in  misc_noc_flit_type;
    noc5_data_e_in     : in  misc_noc_flit_type;
    noc5_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic; 
    noc5_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc5_data_n_out    : out misc_noc_flit_type;
    noc5_data_s_out    : out misc_noc_flit_type;
    noc5_data_w_out    : out misc_noc_flit_type;
    noc5_data_e_out    : out misc_noc_flit_type;
    noc5_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc5_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc6_data_n_in     : in  noc_flit_type;
    noc6_data_s_in     : in  noc_flit_type;
    noc6_data_w_in     : in  noc_flit_type;
    noc6_data_e_in     : in  noc_flit_type;
    noc6_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc6_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc6_data_n_out    : out noc_flit_type;
    noc6_data_s_out    : out noc_flit_type;
    noc6_data_w_out    : out noc_flit_type;
    noc6_data_e_out    : out noc_flit_type;
    noc6_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc6_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc1_mon_noc_vec   : out monitor_noc_type;
    noc2_mon_noc_vec   : out monitor_noc_type;
    noc3_mon_noc_vec   : out monitor_noc_type;
    noc4_mon_noc_vec   : out monitor_noc_type;
    noc5_mon_noc_vec   : out monitor_noc_type;
    noc6_mon_noc_vec   : out monitor_noc_type;
    mon_dvfs_in        : in  monitor_dvfs_type;
    --Monitor signals
    mon_acc            : out monitor_acc_type;
    mon_cache          : out monitor_cache_type;
    mon_dvfs           : out monitor_dvfs_type
    );

end;

architecture rtl of tile_acc is

  component sync_noc_set
     generic (
       PORTS     : std_logic_vector(4 downto 0);
--       local_x   : std_logic_vector(2 downto 0);
--       local_y   : std_logic_vector(2 downto 0);
       HAS_SYNC  : integer range 0 to 1 := 0);
     port (
        clk           : in  std_logic;
        clk_tile      : in  std_logic;
        rst           : in  std_logic;
--        CONST_PORTS   : in  std_logic_vector(4 downto 0);
        CONST_local_x : in  std_logic_vector(2 downto 0);
        CONST_local_y : in  std_logic_vector(2 downto 0);
        noc1_data_n_in     : in  noc_flit_type;
        noc1_data_s_in     : in  noc_flit_type;
        noc1_data_w_in     : in  noc_flit_type;
        noc1_data_e_in     : in  noc_flit_type;
        noc1_input_port    : in  noc_flit_type;
        noc1_data_void_in  : in  std_logic_vector(4 downto 0);
        noc1_stop_in       : in  std_logic_vector(4 downto 0);
        noc1_data_n_out    : out noc_flit_type;
        noc1_data_s_out    : out noc_flit_type;
        noc1_data_w_out    : out noc_flit_type;
        noc1_data_e_out    : out noc_flit_type;
        noc1_output_port   : out noc_flit_type;
        noc1_data_void_out : out std_logic_vector(4 downto 0);
        noc1_stop_out      : out std_logic_vector(4 downto 0);
        noc2_data_n_in     : in  noc_flit_type;
        noc2_data_s_in     : in  noc_flit_type;
        noc2_data_w_in     : in  noc_flit_type;
        noc2_data_e_in     : in  noc_flit_type;
        noc2_input_port    : in  noc_flit_type;
        noc2_data_void_in  : in  std_logic_vector(4 downto 0);
        noc2_stop_in       : in  std_logic_vector(4 downto 0);
        noc2_data_n_out    : out noc_flit_type;
        noc2_data_s_out    : out noc_flit_type;
        noc2_data_w_out    : out noc_flit_type;
        noc2_data_e_out    : out noc_flit_type;
        noc2_output_port   : out noc_flit_type;
        noc2_data_void_out : out std_logic_vector(4 downto 0);
        noc2_stop_out      : out std_logic_vector(4 downto 0);
        noc3_data_n_in     : in  noc_flit_type;
        noc3_data_s_in     : in  noc_flit_type;
        noc3_data_w_in     : in  noc_flit_type;
        noc3_data_e_in     : in  noc_flit_type;
        noc3_input_port    : in  noc_flit_type;
        noc3_data_void_in  : in  std_logic_vector(4 downto 0);
        noc3_stop_in       : in  std_logic_vector(4 downto 0);
        noc3_data_n_out    : out noc_flit_type;
        noc3_data_s_out    : out noc_flit_type;
        noc3_data_w_out    : out noc_flit_type;
        noc3_data_e_out    : out noc_flit_type;
        noc3_output_port   : out noc_flit_type;
        noc3_data_void_out : out std_logic_vector(4 downto 0);
        noc3_stop_out      : out std_logic_vector(4 downto 0);
        noc4_data_n_in     : in  noc_flit_type;
        noc4_data_s_in     : in  noc_flit_type;
        noc4_data_w_in     : in  noc_flit_type;
        noc4_data_e_in     : in  noc_flit_type;
        noc4_input_port    : in  noc_flit_type;
        noc4_data_void_in  : in  std_logic_vector(4 downto 0);
        noc4_stop_in       : in  std_logic_vector(4 downto 0);
        noc4_data_n_out    : out noc_flit_type;
        noc4_data_s_out    : out noc_flit_type;
        noc4_data_w_out    : out noc_flit_type;
        noc4_data_e_out    : out noc_flit_type;
        noc4_output_port   : out noc_flit_type;
        noc4_data_void_out : out std_logic_vector(4 downto 0);
        noc4_stop_out      : out std_logic_vector(4 downto 0);
        noc5_data_n_in     : in  misc_noc_flit_type;
        noc5_data_s_in     : in  misc_noc_flit_type;
        noc5_data_w_in     : in  misc_noc_flit_type;
        noc5_data_e_in     : in  misc_noc_flit_type;
        noc5_input_port    : in  misc_noc_flit_type;
        noc5_data_void_in  : in  std_logic_vector(4 downto 0);
        noc5_stop_in       : in  std_logic_vector(4 downto 0);
        noc5_data_n_out    : out misc_noc_flit_type;
        noc5_data_s_out    : out misc_noc_flit_type;
        noc5_data_w_out    : out misc_noc_flit_type;
        noc5_data_e_out    : out misc_noc_flit_type;
        noc5_output_port   : out misc_noc_flit_type;
        noc5_data_void_out : out std_logic_vector(4 downto 0);
        noc5_stop_out      : out std_logic_vector(4 downto 0);
        noc6_data_n_in     : in  noc_flit_type;
        noc6_data_s_in     : in  noc_flit_type;
        noc6_data_w_in     : in  noc_flit_type;
        noc6_data_e_in     : in  noc_flit_type;
        noc6_input_port    : in  noc_flit_type;
        noc6_data_void_in  : in  std_logic_vector(4 downto 0);
        noc6_stop_in       : in  std_logic_vector(4 downto 0);
        noc6_data_n_out    : out noc_flit_type;
        noc6_data_s_out    : out noc_flit_type;
        noc6_data_w_out    : out noc_flit_type;
        noc6_data_e_out    : out noc_flit_type;
        noc6_output_port   : out noc_flit_type;
        noc6_data_void_out : out std_logic_vector(4 downto 0);
        noc6_stop_out      : out std_logic_vector(4 downto 0);

        -- Monitor output. Can be left unconnected
        noc1_mon_noc_vec   : out monitor_noc_type;
        noc2_mon_noc_vec   : out monitor_noc_type;
        noc3_mon_noc_vec   : out monitor_noc_type;
        noc4_mon_noc_vec   : out monitor_noc_type;
        noc5_mon_noc_vec   : out monitor_noc_type;
        noc6_mon_noc_vec   : out monitor_noc_type
    );

  end component;

  signal clk_feedthru : std_ulogic;
  signal apbi         : apb_slv_in_type;
  signal apbo         : apb_slv_out_vector;
  signal pready       : std_ulogic;
  signal mon_dvfs_int : monitor_dvfs_type;

  signal coherence_req_wrreq        : std_ulogic;
  signal coherence_req_data_in      : noc_flit_type;
  signal coherence_req_full         : std_ulogic;
  signal coherence_fwd_rdreq        : std_ulogic;
  signal coherence_fwd_data_out     : noc_flit_type;
  signal coherence_fwd_empty        : std_ulogic;
  signal coherence_rsp_rcv_rdreq    : std_ulogic;
  signal coherence_rsp_rcv_data_out : noc_flit_type;
  signal coherence_rsp_rcv_empty    : std_ulogic;
  signal coherence_rsp_snd_wrreq    : std_ulogic;
  signal coherence_rsp_snd_data_in  : noc_flit_type;
  signal coherence_rsp_snd_full     : std_ulogic;
  signal dma_rcv_rdreq              : std_ulogic;
  signal dma_rcv_data_out           : noc_flit_type;
  signal dma_rcv_empty              : std_ulogic;
  signal dma_snd_wrreq              : std_ulogic;
  signal dma_snd_data_in            : noc_flit_type;
  signal dma_snd_full               : std_ulogic;
  signal coherent_dma_rcv_rdreq     : std_ulogic;
  signal coherent_dma_rcv_data_out  : noc_flit_type;
  signal coherent_dma_rcv_empty     : std_ulogic;
  signal coherent_dma_snd_wrreq     : std_ulogic;
  signal coherent_dma_snd_data_in   : noc_flit_type;
  signal coherent_dma_snd_full      : std_ulogic;
  signal interrupt_wrreq            : std_ulogic;
  signal interrupt_data_in          : misc_noc_flit_type;
  signal interrupt_full             : std_ulogic;
  signal interrupt_ack_rdreq        : std_ulogic;
  signal interrupt_ack_data_out     : misc_noc_flit_type;
  signal interrupt_ack_empty        : std_ulogic;
  signal apb_snd_wrreq              : std_ulogic;
  signal apb_snd_data_in            : misc_noc_flit_type;
  signal apb_snd_full               : std_ulogic;
  signal apb_rcv_rdreq              : std_ulogic;
  signal apb_rcv_data_out           : misc_noc_flit_type;
  signal apb_rcv_empty              : std_ulogic;

  -- Tile parameters
  constant this_hls_conf       : hlscfg_t                           := tile_design_point(tile_id);
  constant this_local_y        : local_yx                           := tile_y(tile_id);
  constant this_local_x        : local_yx                           := tile_x(tile_id);
  constant io_y                : local_yx                           := tile_y(io_tile_id);
  constant io_x                : local_yx                           := tile_x(io_tile_id);
  constant this_device         : devid_t                            := tile_device(tile_id);
  constant this_pindex         : integer                            := tile_apb_idx(tile_id);
  constant this_paddr          : integer                            := tile_apb_paddr(tile_id);
  constant this_pmask          : integer                            := tile_apb_pmask(tile_id);
  constant this_paddr_ext      : integer                            := tile_apb_paddr_ext(tile_id);
  constant this_pmask_ext      : integer                            := tile_apb_pmask_ext(tile_id);
  constant this_pirq           : integer                            := tile_apb_irq(tile_id);
  constant this_irq_type       : integer                            := tile_irq_type(tile_id);
  constant this_scatter_gather : integer range 0 to 1               := tile_scatter_gather(tile_id);
  constant this_local_apb_mask : std_logic_vector(0 to NAPBSLV - 1) := local_apb_mask(tile_id);
  constant this_has_l2         : integer                            := tile_has_l2(tile_id);
  constant this_has_dvfs       : integer                            := tile_has_dvfs(tile_id);
  constant this_has_pll        : integer                            := tile_has_pll(tile_id);
  constant this_extra_clk_buf  : integer                            := extra_clk_buf(tile_id);
  constant this_domain         : integer                            := tile_domain(tile_id);
  constant ROUTER_PORTS        : ports_vec                          := set_router_ports(CFG_XLEN, CFG_YLEN, this_local_x, this_local_y);
--  constant ROUTER_PORTS        : ports_vec                          := set_router_ports(CFG_XLEN, CFG_YLEN);

 -- Noc signals
  signal noc1_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc1_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc1_acc_stop_in       : std_ulogic;
  signal noc1_acc_stop_out      : std_ulogic;
  signal noc1_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc1_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc1_acc_data_void_in  : std_ulogic;
  signal noc1_acc_data_void_out : std_ulogic;
  signal noc2_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc2_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc2_acc_stop_in       : std_ulogic;
  signal noc2_acc_stop_out      : std_ulogic;
  signal noc2_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc2_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc2_acc_data_void_in  : std_ulogic;
  signal noc2_acc_data_void_out : std_ulogic;
  signal noc3_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc3_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc3_acc_stop_in       : std_ulogic;
  signal noc3_acc_stop_out      : std_ulogic;
  signal noc3_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc3_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc3_acc_data_void_in  : std_ulogic;
  signal noc3_acc_data_void_out : std_ulogic;
  signal noc4_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc4_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc4_acc_stop_in       : std_ulogic;
  signal noc4_acc_stop_out      : std_ulogic;
  signal noc4_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc4_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc4_acc_data_void_in  : std_ulogic;
  signal noc4_acc_data_void_out : std_ulogic;
  signal noc5_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc5_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc5_acc_stop_in       : std_ulogic;
  signal noc5_acc_stop_out      : std_ulogic;
  signal noc5_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc5_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc5_acc_data_void_in  : std_ulogic;
  signal noc5_acc_data_void_out : std_ulogic;
  signal noc6_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc6_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc6_acc_stop_in       : std_ulogic;
  signal noc6_acc_stop_out      : std_ulogic;
  signal noc6_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc6_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc6_acc_data_void_in  : std_ulogic;
  signal noc6_acc_data_void_out : std_ulogic;
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


  -- add attribute 'keep' to fix a bug with Vivado HLS accelerators
  attribute keep : string;

  attribute keep of coherence_req_wrreq        : signal is "true";
  attribute keep of coherence_req_data_in      : signal is "true";
  attribute keep of coherence_req_full         : signal is "true";
  attribute keep of coherence_fwd_rdreq        : signal is "true";
  attribute keep of coherence_fwd_data_out     : signal is "true";
  attribute keep of coherence_fwd_empty        : signal is "true";
  attribute keep of coherence_rsp_rcv_rdreq    : signal is "true";
  attribute keep of coherence_rsp_rcv_data_out : signal is "true";
  attribute keep of coherence_rsp_rcv_empty    : signal is "true";
  attribute keep of coherence_rsp_snd_wrreq    : signal is "true";
  attribute keep of coherence_rsp_snd_data_in  : signal is "true";
  attribute keep of coherence_rsp_snd_full     : signal is "true";
  attribute keep of dma_rcv_rdreq              : signal is "true";
  attribute keep of dma_rcv_data_out           : signal is "true";
  attribute keep of dma_rcv_empty              : signal is "true";
  attribute keep of dma_snd_wrreq              : signal is "true";
  attribute keep of dma_snd_data_in            : signal is "true";
  attribute keep of dma_snd_full               : signal is "true";
  attribute keep of coherent_dma_rcv_rdreq     : signal is "true";
  attribute keep of coherent_dma_rcv_data_out  : signal is "true";
  attribute keep of coherent_dma_rcv_empty     : signal is "true";
  attribute keep of coherent_dma_snd_wrreq     : signal is "true";
  attribute keep of coherent_dma_snd_data_in   : signal is "true";
  attribute keep of coherent_dma_snd_full      : signal is "true";
  attribute keep of interrupt_wrreq            : signal is "true";
  attribute keep of interrupt_data_in          : signal is "true";
  attribute keep of interrupt_full             : signal is "true";
  attribute keep of interrupt_ack_rdreq        : signal is "true";
  attribute keep of interrupt_ack_data_out     : signal is "true";
  attribute keep of interrupt_ack_empty        : signal is "true";
  attribute keep of apb_snd_wrreq              : signal is "true";
  attribute keep of apb_snd_data_in            : signal is "true";
  attribute keep of apb_snd_full               : signal is "true";
  attribute keep of apb_rcv_rdreq              : signal is "true";
  attribute keep of apb_rcv_data_out           : signal is "true";
  attribute keep of apb_rcv_empty              : signal is "true";

begin

  pllclk <= clk_feedthru;

  -----------------------------------------------------------------------------
  -- NOC Connections
  ----------------------------------------------------------------------------
  noc1_stop_in_s         <= noc1_acc_stop_in  & noc1_stop_in;
  noc1_stop_out          <= noc1_stop_out_s(3 downto 0);
  noc1_acc_stop_out      <= noc1_stop_out_s(4);
  noc1_data_void_in_s    <= noc1_acc_data_void_in & noc1_data_void_in;
  noc1_data_void_out     <= noc1_data_void_out_s(3 downto 0);
  noc1_acc_data_void_out <= noc1_data_void_out_s(4);
  noc2_stop_in_s         <= noc2_acc_stop_in  & noc2_stop_in;
  noc2_stop_out          <= noc2_stop_out_s(3 downto 0);
  noc2_acc_stop_out      <= noc2_stop_out_s(4);
  noc2_data_void_in_s    <= noc2_acc_data_void_in & noc2_data_void_in;
  noc2_data_void_out     <= noc2_data_void_out_s(3 downto 0);
  noc2_acc_data_void_out <= noc2_data_void_out_s(4);
  noc3_stop_in_s         <= noc3_acc_stop_in  & noc3_stop_in;
  noc3_stop_out          <= noc3_stop_out_s(3 downto 0);
  noc3_acc_stop_out      <= noc3_stop_out_s(4);
  noc3_data_void_in_s    <= noc3_acc_data_void_in & noc3_data_void_in;
  noc3_data_void_out     <= noc3_data_void_out_s(3 downto 0);
  noc3_acc_data_void_out <= noc3_data_void_out_s(4);
  noc4_stop_in_s         <= noc4_acc_stop_in  & noc4_stop_in;
  noc4_stop_out          <= noc4_stop_out_s(3 downto 0);
  noc4_acc_stop_out      <= noc4_stop_out_s(4);
  noc4_data_void_in_s    <= noc4_acc_data_void_in & noc4_data_void_in;
  noc4_data_void_out     <= noc4_data_void_out_s(3 downto 0);
  noc4_acc_data_void_out <= noc4_data_void_out_s(4);
  noc5_stop_in_s         <= noc5_acc_stop_in  & noc5_stop_in;
  noc5_stop_out          <= noc5_stop_out_s(3 downto 0);
  noc5_acc_stop_out      <= noc5_stop_out_s(4);
  noc5_data_void_in_s    <= noc5_acc_data_void_in & noc5_data_void_in;
  noc5_data_void_out     <= noc5_data_void_out_s(3 downto 0);
  noc5_acc_data_void_out <= noc5_data_void_out_s(4);
  noc6_stop_in_s         <= noc6_acc_stop_in  & noc6_stop_in;
  noc6_stop_out          <= noc6_stop_out_s(3 downto 0);
  noc6_acc_stop_out      <= noc6_stop_out_s(4);
  noc6_data_void_in_s    <= noc6_acc_data_void_in & noc6_data_void_in;
  noc6_data_void_out     <= noc6_data_void_out_s(3 downto 0);
  noc6_acc_data_void_out <= noc6_data_void_out_s(4);

 sync_noc_set_acc: sync_noc_set
  generic map (
     PORTS    => ROUTER_PORTS,
--     local_x  => this_local_x,
--     local_y  => this_local_y,
     HAS_SYNC => HAS_SYNC )
   port map (
     clk                => sys_clk_int,
     clk_tile           => clk_feedthru,
     rst                => rst,
--     CONST_PORTS        => ROUTER_PORTS,
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
     noc1_mon_noc_vec   => noc1_mon_noc_vec,
     noc2_mon_noc_vec   => noc2_mon_noc_vec,
     noc3_mon_noc_vec   => noc3_mon_noc_vec,
     noc4_mon_noc_vec   => noc4_mon_noc_vec,
     noc5_mon_noc_vec   => noc5_mon_noc_vec,
     noc6_mon_noc_vec   => noc6_mon_noc_vec

     );

-------------------------------------------------------------------------------
-- ACCELERATOR ----------------------------------------------------------------
-------------------------------------------------------------------------------

  -- <<accelerator-wrappers-gen>>

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  -- APB proxy
  misc_noc2apb_1 : misc_noc2apb
    generic map (
      tech         => CFG_MEMTECH,
      local_y      => this_local_y,
      local_x      => this_local_x,
      local_apb_en => this_local_apb_mask)
    port map (
      rst              => rst,
      clk              => clk_feedthru,
      apbi             => apbi,
      apbo             => apbo,
      pready           => pready,
      dvfs_transient   => mon_dvfs_int.transient,
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty
    );
  mon_dvfs <= mon_dvfs_int;

  acc_tile_q_1 : acc_tile_q
    generic map (
      tech => CFG_FABTECH)
    port map (
      rst                        => rst,
      clk                        => clk_feedthru,
      coherence_req_wrreq        => coherence_req_wrreq,
      coherence_req_data_in      => coherence_req_data_in,
      coherence_req_full         => coherence_req_full,
      coherence_fwd_rdreq        => coherence_fwd_rdreq,
      coherence_fwd_data_out     => coherence_fwd_data_out,
      coherence_fwd_empty        => coherence_fwd_empty,
      coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,
      coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
      coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,
      coherence_rsp_snd_wrreq    => coherence_rsp_snd_wrreq,
      coherence_rsp_snd_data_in  => coherence_rsp_snd_data_in,
      coherence_rsp_snd_full     => coherence_rsp_snd_full,
      dma_rcv_rdreq              => dma_rcv_rdreq,
      dma_rcv_data_out           => dma_rcv_data_out,
      dma_rcv_empty              => dma_rcv_empty,
      coherent_dma_snd_wrreq     => coherent_dma_snd_wrreq,
      coherent_dma_snd_data_in   => coherent_dma_snd_data_in,
      coherent_dma_snd_full      => coherent_dma_snd_full,
      dma_snd_wrreq              => dma_snd_wrreq,
      dma_snd_data_in            => dma_snd_data_in,
      dma_snd_full               => dma_snd_full,
      coherent_dma_rcv_rdreq     => coherent_dma_rcv_rdreq,
      coherent_dma_rcv_data_out  => coherent_dma_rcv_data_out,
      coherent_dma_rcv_empty     => coherent_dma_rcv_empty,
      apb_rcv_rdreq              => apb_rcv_rdreq,
      apb_rcv_data_out           => apb_rcv_data_out,
      apb_rcv_empty              => apb_rcv_empty,
      apb_snd_wrreq              => apb_snd_wrreq,
      apb_snd_data_in            => apb_snd_data_in,
      apb_snd_full               => apb_snd_full,
      interrupt_wrreq            => interrupt_wrreq,
      interrupt_data_in          => interrupt_data_in,
      interrupt_full             => interrupt_full,
      interrupt_ack_rdreq        => interrupt_ack_rdreq,
      interrupt_ack_data_out     => interrupt_ack_data_out,
      interrupt_ack_empty        => interrupt_ack_empty,
      noc1_out_data              => noc1_output_port,
      noc1_out_void              => noc1_acc_data_void_out,
      noc1_out_stop              => noc1_acc_stop_in,
      noc1_in_data               => noc1_input_port,
      noc1_in_void               => noc1_acc_data_void_in,
      noc1_in_stop               => noc1_acc_stop_out,
      noc2_out_data              => noc2_output_port,
      noc2_out_void              => noc2_acc_data_void_out,
      noc2_out_stop              => noc2_acc_stop_in,
      noc2_in_data               => noc2_input_port,
      noc2_in_void               => noc2_acc_data_void_in,
      noc2_in_stop               => noc1_acc_stop_out,
      noc3_out_data              => noc3_output_port,
      noc3_out_void              => noc3_acc_data_void_out,
      noc3_out_stop              => noc3_acc_stop_in,
      noc3_in_data               => noc3_input_port,
      noc3_in_void               => noc3_acc_data_void_in,
      noc3_in_stop               => noc3_acc_stop_out,
      noc4_out_data              => noc4_output_port,
      noc4_out_void              => noc4_acc_data_void_out,
      noc4_out_stop              => noc4_acc_stop_in,
      noc4_in_data               => noc4_input_port,
      noc4_in_void               => noc4_acc_data_void_in,
      noc4_in_stop               => noc4_acc_stop_out,
      noc5_out_data              => noc5_output_port,
      noc5_out_void              => noc5_acc_data_void_out,
      noc5_out_stop              => noc5_acc_stop_in,
      noc5_in_data               => noc5_input_port,
      noc5_in_void               => noc5_acc_data_void_in,
      noc5_in_stop               => noc5_acc_stop_out,
      noc6_out_data              => noc6_output_port,
      noc6_out_void              => noc6_acc_data_void_out,
      noc6_out_stop              => noc6_acc_stop_in,
      noc6_in_data               => noc6_input_port,
      noc6_in_void               => noc6_acc_data_void_in,
      noc6_in_stop               => noc6_acc_stop_out);

end;

