-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  CPU tile
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
use work.ariane_esp_pkg.all;
use work.ibex_esp_pkg.all;
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
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity tile_cpu is
  generic (
    SIMULATION         : boolean              := false;
    this_has_dvfs      : integer range 0 to 1 := 0;
    this_has_pll       : integer range 0 to 1 := 0;
    this_has_dco       : integer range 0 to 1 := 0;
    this_extra_clk_buf : integer range 0 to 1 := 0;
    test_if_en         : integer range 0 to 1 := 0;
    ROUTER_PORTS       : ports_vec := "11111";
    HAS_SYNC           : integer range 0 to 1 := 1);
  port (
    raw_rstn           : in  std_ulogic;
    rst                : in  std_ulogic;
    refclk             : in  std_ulogic;
    pllbypass          : in  std_ulogic;
    pllclk             : out std_ulogic;
    dco_clk            : out std_ulogic;
    dco_clk_lock       : out std_ulogic;
    cpuerr             : out std_ulogic;
    -- Test interface
    tdi                : in  std_logic;
    tdo                : out std_logic;
    tms                : in  std_logic;
    tclk               : in  std_logic;
    -- Pads configuration
    pad_cfg            : out std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
    -- NOC
    sys_clk_int        : in  std_logic;
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
    noc6_stop_out      : out std_logic_vector(3 downto 0);
    noc1_mon_noc_vec   : out monitor_noc_type;
    noc2_mon_noc_vec   : out monitor_noc_type;
    noc3_mon_noc_vec   : out monitor_noc_type;
    noc4_mon_noc_vec   : out monitor_noc_type;
    noc5_mon_noc_vec   : out monitor_noc_type;
    noc6_mon_noc_vec   : out monitor_noc_type;
    mon_cache          : out monitor_cache_type;
    mon_dvfs_in        : in  monitor_dvfs_type;
    mon_dvfs           : out monitor_dvfs_type);
end;


architecture rtl of tile_cpu is

  signal clk_feedthru : std_ulogic;
  signal dvfs_clk : std_ulogic;

  -- DCO
  signal dco_clk_int  : std_ulogic;
  signal dco_en       : std_ulogic;
  signal dco_clk_sel  : std_ulogic;
  signal dco_cc_sel   : std_logic_vector(5 downto 0);
  signal dco_fc_sel   : std_logic_vector(5 downto 0);
  signal dco_div_sel  : std_logic_vector(2 downto 0);
  signal dco_freq_sel : std_logic_vector(1 downto 0);

  -- Test interface / bypass
  signal test1_output_port   : noc_flit_type;
  signal test1_data_void_out : std_ulogic;
  signal test1_stop_in       : std_ulogic;
  signal test2_output_port   : noc_flit_type;
  signal test2_data_void_out : std_ulogic;
  signal test2_stop_in       : std_ulogic;
  signal test3_output_port   : noc_flit_type;
  signal test3_data_void_out : std_ulogic;
  signal test3_stop_in       : std_ulogic;
  signal test4_output_port   : noc_flit_type;
  signal test4_data_void_out : std_ulogic;
  signal test4_stop_in       : std_ulogic;
  signal test5_output_port   : misc_noc_flit_type;
  signal test5_data_void_out : std_ulogic;
  signal test5_stop_in       : std_ulogic;
  signal test6_output_port   : noc_flit_type;
  signal test6_data_void_out : std_ulogic;
  signal test6_stop_in       : std_ulogic;
  signal test1_input_port    : noc_flit_type;
  signal test1_data_void_in  : std_ulogic;
  signal test1_stop_out      : std_ulogic;
  signal test2_input_port    : noc_flit_type;
  signal test2_data_void_in  : std_ulogic;
  signal test2_stop_out      : std_ulogic;
  signal test3_input_port    : noc_flit_type;
  signal test3_data_void_in  : std_ulogic;
  signal test3_stop_out      : std_ulogic;
  signal test4_input_port    : noc_flit_type;
  signal test4_data_void_in  : std_ulogic;
  signal test4_stop_out      : std_ulogic;
  signal test5_input_port    : misc_noc_flit_type;
  signal test5_data_void_in  : std_ulogic;
  signal test5_stop_out      : std_ulogic;
  signal test6_input_port    : noc_flit_type;
  signal test6_data_void_in  : std_ulogic;
  signal test6_stop_out      : std_ulogic;


  -- Monitor CPU idle
  signal irqo_int      : l3_irq_out_type;
  signal mon_dvfs_ctrl : monitor_dvfs_type;

  -- Leon3 debug signals
  signal dbgi : l3_debug_in_type;
  signal dbgo : l3_debug_out_type;

  -- CPU Reset
  signal cleanrstn : std_ulogic;  -- deassert when tile config is valid
  signal cpurstn   : std_ulogic;  -- in simulation, allow mininum delay from cleanrstn;
                                  -- Leon3 SMP reads irqi while cpurstn is
                                  -- active and irqi depends on tile config.
  type cpu_rstn_state_type is (por, soft_reset_1_h, soft_reset_1_l,
                               soft_reset_2_h, soft_reset_2_l,
                               soft_reset_3_h, soft_reset_3_l,
                               soft_reset_4_h, run);
  signal cpu_rstn_state, cpu_rstn_next : cpu_rstn_state_type;

  -- L1 data-cache flush
  signal dflush : std_ulogic;

  -- L2 wrapper and cache debug reset
  signal l2_rstn : std_ulogic;

  -- Interrupt controller
  signal irqi : l3_irq_in_type;
  signal irqo : l3_irq_out_type;

  -- RISC-V PLIC/CLINT outputs
  signal irq       : std_logic_vector(1 downto 0);
  signal timer_irq : std_ulogic;
  signal ipi       : std_ulogic;

  -- IBEX Idle
  signal core_idle : std_ulogic;


  -- Queues
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
  signal dma_snd_data_in_cpu        : noc_flit_type;
  signal dma_snd_data_in            : noc_flit_type;
  signal dma_snd_full               : std_ulogic;
  signal remote_ahbs_snd_wrreq      : std_ulogic;
  signal remote_ahbs_snd_data_in    : misc_noc_flit_type;
  signal remote_ahbs_snd_full       : std_ulogic;
  signal remote_ahbs_rcv_rdreq      : std_ulogic;
  signal remote_ahbs_rcv_data_out   : misc_noc_flit_type;
  signal remote_ahbs_rcv_empty      : std_ulogic;
  signal apb_rcv_rdreq              : std_ulogic;
  signal apb_rcv_data_out           : misc_noc_flit_type;
  signal apb_rcv_empty              : std_ulogic;
  signal apb_snd_wrreq              : std_ulogic;
  signal apb_snd_data_in            : misc_noc_flit_type;
  signal apb_snd_full               : std_ulogic;
  signal remote_apb_rcv_rdreq       : std_ulogic;
  signal remote_apb_rcv_data_out    : misc_noc_flit_type;
  signal remote_apb_rcv_empty       : std_ulogic;
  signal remote_apb_snd_wrreq       : std_ulogic;
  signal remote_apb_snd_data_in     : misc_noc_flit_type;
  signal remote_apb_snd_full        : std_ulogic;
  signal remote_irq_rdreq           : std_ulogic;
  signal remote_irq_data_out        : misc_noc_flit_type;
  signal remote_irq_empty           : std_ulogic;
  signal remote_irq_ack_wrreq       : std_ulogic;
  signal remote_irq_ack_data_in     : misc_noc_flit_type;
  signal remote_irq_ack_full        : std_ulogic;

  -- Bus (AHB-based processor core)
  signal ahbsi      : ahb_slv_in_type;
  signal ahbso      : ahb_slv_out_vector;
  signal noc_ahbso  : ahb_slv_out_vector;
  signal noc_ahbso_2  : ahb_slv_out_vector;
  signal ctrl_ahbso : ahb_slv_out_vector;
  signal ahbmi      : ahb_mst_in_type;
  signal ahbmo      : ahb_mst_out_vector;
  signal apbi       : apb_slv_in_type;
  signal apbo       : apb_slv_out_vector;
  signal noc_apbi   : apb_slv_in_type;
  signal noc_apbo   : apb_slv_out_vector;
  signal apb_req    : std_ulogic;
  signal apb_ack    : std_ulogic;
  signal mosi       : axi_mosi_vector(0 to 3);
  signal somi       : axi_somi_vector(0 to 3);

  signal ariane_drami : axi_mosi_type;
  signal ariane_dramo : axi_somi_type;

  signal cache_drami : axi_mosi_type;
  signal cache_dramo : axi_somi_type;

  signal cache_ahbsi : ahb_slv_in_type;
  signal cache_ahbso : ahb_slv_out_type;

  -- Mon
  signal mon_cache_int  : monitor_cache_type;
  signal mon_dvfs_int   : monitor_dvfs_type;
  signal mon_noc        : monitor_noc_vector(1 to 6);
  signal noc1_mon_noc_vec_int  : monitor_noc_type;
  signal noc2_mon_noc_vec_int  : monitor_noc_type;
  signal noc3_mon_noc_vec_int  : monitor_noc_type;
  signal noc4_mon_noc_vec_int  : monitor_noc_type;
  signal noc5_mon_noc_vec_int  : monitor_noc_type;
  signal noc6_mon_noc_vec_int  : monitor_noc_type;

  -- GRLIB parameters
  constant disas : integer := CFG_DISAS;
  constant pclow : integer := CFG_PCLOW;

  -- Soft reset
  signal srst : std_ulogic;

  -- Tile parameters
  signal tile_config : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);

  signal tile_id : integer range 0 to CFG_TILES_NUM - 1;

  signal this_cpu_id            : integer range 0 to CFG_NCPU_TILE - 1;
  signal this_ariane_hartid_cfg : std_logic_vector(ESP_CSR_ARIANE_HARTID_MSB downto ESP_CSR_ARIANE_HARTID_LSB + 1);
  signal this_cpu_id_lv         : std_logic_vector(63 downto 0);

  signal this_dvfs_pindex       : integer range 0 to NAPBSLV - 1;
  signal this_dvfs_paddr        : integer;
  signal this_dvfs_pmask        : integer;
  signal this_dvfs_pconfig      : apb_config_type;

  signal this_cache_id          : integer;
  signal this_l2_pindex         : integer range 0 to NAPBSLV - 1;
  signal this_l2_pconfig        : apb_config_type;

  signal this_csr_pindex        : integer range 0 to NAPBSLV - 1;
  signal this_csr_pconfig       : apb_config_type;

  signal this_local_y : local_yx;
  signal this_local_x : local_yx;

  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := (
    0 => '1',                           -- CSRs
    1 => to_std_logic(CFG_L2_ENABLE),   -- write-back L2 private cache
    2 => to_std_logic(this_has_pll),    -- DVFS controller
    others => '0');

  constant this_local_ahb_en : std_logic_vector(0 to NAHBSLV - 1) := (
    1      => '1',                         -- ahb2apb
    4      => to_std_logic(CFG_L2_ENABLE), -- write-back L2 private cache
    others => '0');

  constant this_remote_apb_slv_en : std_logic_vector(0 to NAPBSLV - 1) := remote_apb_slv_mask_cpu;
  constant this_remote_ahb_slv_en : std_logic_vector(0 to NAHBSLV - 1) := remote_ahb_mask_cpu;


  attribute mark_debug : string;

  -- attribute mark_debug of irq : signal is "true";
  -- attribute mark_debug of timer_irq : signal is "true";
  -- attribute mark_debug of ipi : signal is "true";

  -- attribute mark_debug of apbi : signal is "true";
  -- attribute mark_debug of apbo : signal is "true";
  -- attribute mark_debug of apb_req : signal is "true";
  -- attribute mark_debug of apb_ack : signal is "true";
  -- attribute mark_debug of remote_apb_snd_wrreq : signal is "true";
  -- attribute mark_debug of remote_apb_snd_data_in : signal is "true";
  -- attribute mark_debug of remote_apb_snd_full : signal is "true";
  -- attribute mark_debug of remote_apb_rcv_rdreq : signal is "true";
  -- attribute mark_debug of remote_apb_rcv_data_out : signal is "true";
  -- attribute mark_debug of remote_apb_rcv_empty : signal is "true";

  -- Noc signals
  signal noc1_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc1_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc1_cpu_stop_in       : std_ulogic;
  signal noc1_cpu_stop_out      : std_ulogic;
  signal noc1_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc1_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc1_cpu_data_void_in  : std_ulogic;
  signal noc1_cpu_data_void_out : std_ulogic;
  signal noc2_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc2_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc2_cpu_stop_in       : std_ulogic;
  signal noc2_cpu_stop_out      : std_ulogic;
  signal noc2_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc2_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc2_cpu_data_void_in  : std_ulogic;
  signal noc2_cpu_data_void_out : std_ulogic;
  signal noc3_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc3_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc3_cpu_stop_in       : std_ulogic;
  signal noc3_cpu_stop_out      : std_ulogic;
  signal noc3_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc3_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc3_cpu_data_void_in  : std_ulogic;
  signal noc3_cpu_data_void_out : std_ulogic;
  signal noc4_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc4_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc4_cpu_stop_in       : std_ulogic;
  signal noc4_cpu_stop_out      : std_ulogic;
  signal noc4_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc4_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc4_cpu_data_void_in  : std_ulogic;
  signal noc4_cpu_data_void_out : std_ulogic;
  signal noc5_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc5_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc5_cpu_stop_in       : std_ulogic;
  signal noc5_cpu_stop_out      : std_ulogic;
  signal noc5_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc5_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc5_cpu_data_void_in  : std_ulogic;
  signal noc5_cpu_data_void_out : std_ulogic;
  signal noc6_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc6_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc6_cpu_stop_in       : std_ulogic;
  signal noc6_cpu_stop_out      : std_ulogic;
  signal noc6_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc6_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc6_cpu_data_void_in  : std_ulogic;
  signal noc6_cpu_data_void_out : std_ulogic;
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
  attribute keep of noc1_cpu_stop_in       : signal is "true";
  attribute keep of noc1_cpu_stop_out      : signal is "true";
  attribute keep of noc1_cpu_data_void_in  : signal is "true";
  attribute keep of noc1_cpu_data_void_out : signal is "true";
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
  attribute keep of noc2_cpu_stop_in       : signal is "true";
  attribute keep of noc2_cpu_stop_out      : signal is "true";
  attribute keep of noc2_cpu_data_void_in  : signal is "true";
  attribute keep of noc2_cpu_data_void_out : signal is "true";
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
  attribute keep of noc3_cpu_stop_in       : signal is "true";
  attribute keep of noc3_cpu_stop_out      : signal is "true";
  attribute keep of noc3_cpu_data_void_in  : signal is "true";
  attribute keep of noc3_cpu_data_void_out : signal is "true";
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
  attribute keep of noc4_cpu_stop_in       : signal is "true";
  attribute keep of noc4_cpu_stop_out      : signal is "true";
  attribute keep of noc4_cpu_data_void_in  : signal is "true";
  attribute keep of noc4_cpu_data_void_out : signal is "true";
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
  attribute keep of noc5_cpu_stop_in       : signal is "true";
  attribute keep of noc5_cpu_stop_out      : signal is "true";
  attribute keep of noc5_cpu_data_void_in  : signal is "true";
  attribute keep of noc5_cpu_data_void_out : signal is "true";
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
  attribute keep of noc6_cpu_stop_in       : signal is "true";
  attribute keep of noc6_cpu_stop_out      : signal is "true";
  attribute keep of noc6_cpu_data_void_in  : signal is "true";
  attribute keep of noc6_cpu_data_void_out : signal is "true";
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

  attribute keep of  apb_rcv_rdreq              : signal is "true";
  attribute keep of  apb_rcv_data_out           : signal is "true";
  attribute keep of  apb_rcv_empty              : signal is "true";
  attribute keep of  apb_snd_wrreq              : signal is "true";
  attribute keep of  apb_snd_data_in            : signal is "true";
  attribute keep of  apb_snd_full               : signal is "true";
  attribute keep of  remote_apb_rcv_rdreq       : signal is "true";
  attribute keep of  remote_apb_rcv_data_out    : signal is "true";
  attribute keep of  remote_apb_rcv_empty       : signal is "true";
  attribute keep of  remote_apb_snd_wrreq       : signal is "true";
  attribute keep of  remote_apb_snd_data_in     : signal is "true";
  attribute keep of  remote_apb_snd_full        : signal is "true";
  attribute keep of  remote_irq_rdreq           : signal is "true";
  attribute keep of  remote_irq_data_out        : signal is "true";
  attribute keep of  remote_irq_empty           : signal is "true";
  attribute keep of  remote_irq_ack_wrreq       : signal is "true";
  attribute keep of  remote_irq_ack_data_in     : signal is "true";
  attribute keep of  remote_irq_ack_full        : signal is "true";

begin

  -- DCO
  dco_gen: if this_has_dco /= 0 generate

    dco_i: dco
      generic map (
        tech => CFG_FABTECH,
        dlog => 9)                      -- come out of reset after NoC, but
                                        -- before tile_io.
      port map (
        rstn     => raw_rstn,
        ext_clk  => refclk,
        en       => dco_en,
        clk_sel  => dco_clk_sel,
        cc_sel   => dco_cc_sel,
        fc_sel   => dco_fc_sel,
        div_sel  => dco_div_sel,
        freq_sel => dco_freq_sel,
        clk      => dco_clk_int,
        clk_div  => pllclk,
        lock     => dco_clk_lock);

    dco_freq_sel <= tile_config(ESP_CSR_DCO_CFG_MSB - 0  downto ESP_CSR_DCO_CFG_MSB - 0  - 1);
    dco_div_sel  <= tile_config(ESP_CSR_DCO_CFG_MSB - 2  downto ESP_CSR_DCO_CFG_MSB - 2  - 2);
    dco_fc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - 5  downto ESP_CSR_DCO_CFG_MSB - 5  - 5);
    dco_cc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - 11 downto ESP_CSR_DCO_CFG_MSB - 11 - 5);
    dco_clk_sel  <= tile_config(ESP_CSR_DCO_CFG_LSB + 1);
    dco_en       <= raw_rstn and tile_config(ESP_CSR_DCO_CFG_LSB);

    -- PLL reference clock comes from DCO
    dvfs_clk <= dco_clk_int;
    dco_clk <= dco_clk_int;
  end generate dco_gen;

  no_dco_gen: if this_has_dco = 0 generate
    dco_clk <= '0';
    -- clk_feedthru is generated by PLL if present, or connected to refclk
    pllclk <= clk_feedthru;
    -- PLL reference clock comes form refclk pin
    dvfs_clk <= refclk;
  end generate no_dco_gen;

  -----------------------------------------------------------------------------
  -- JTAG for single tile testing / bypass when test_if_en = 0
  -----------------------------------------------------------------------------
  jtag_test_i : jtag_test
    generic map (
      test_if_en => test_if_en)
    port map (
      rst                 => rst,
      refclk              => clk_feedthru,
      tdi                 => tdi,
      tdo                 => tdo,
      tms                 => tms,
      tclk                => tclk,
      noc1_output_port    => noc1_output_port,
      noc1_data_void_out  => noc1_cpu_data_void_out,
      noc1_stop_in        => noc1_cpu_stop_in,
      noc2_output_port    => noc2_output_port,
      noc2_data_void_out  => noc2_cpu_data_void_out,
      noc2_stop_in        => noc2_cpu_stop_in,
      noc3_output_port    => noc3_output_port,
      noc3_data_void_out  => noc3_cpu_data_void_out,
      noc3_stop_in        => noc3_cpu_stop_in,
      noc4_output_port    => noc4_output_port,
      noc4_data_void_out  => noc4_cpu_data_void_out,
      noc4_stop_in        => noc4_cpu_stop_in,
      noc5_output_port    => noc5_output_port,
      noc5_data_void_out  => noc5_cpu_data_void_out,
      noc5_stop_in        => noc5_cpu_stop_in,
      noc6_output_port    => noc6_output_port,
      noc6_data_void_out  => noc6_cpu_data_void_out,
      noc6_stop_in        => noc6_cpu_stop_in,
      test1_output_port   => test1_output_port,
      test1_data_void_out => test1_data_void_out,
      test1_stop_in       => test1_stop_in,
      test2_output_port   => test2_output_port,
      test2_data_void_out => test2_data_void_out,
      test2_stop_in       => test2_stop_in,
      test3_output_port   => test3_output_port,
      test3_data_void_out => test3_data_void_out,
      test3_stop_in       => test3_stop_in,
      test4_output_port   => test4_output_port,
      test4_data_void_out => test4_data_void_out,
      test4_stop_in       => test4_stop_in,
      test5_output_port   => test5_output_port,
      test5_data_void_out => test5_data_void_out,
      test5_stop_in       => test5_stop_in,
      test6_output_port   => test6_output_port,
      test6_data_void_out => test6_data_void_out,
      test6_stop_in       => test6_stop_in,
      test1_input_port    => test1_input_port,
      test1_data_void_in  => test1_data_void_in,
      test1_stop_out      => test1_stop_out,
      test2_input_port    => test2_input_port,
      test2_data_void_in  => test2_data_void_in,
      test2_stop_out      => test2_stop_out,
      test3_input_port    => test3_input_port,
      test3_data_void_in  => test3_data_void_in,
      test3_stop_out      => test3_stop_out,
      test4_input_port    => test4_input_port,
      test4_data_void_in  => test4_data_void_in,
      test4_stop_out      => test4_stop_out,
      test5_input_port    => test5_input_port,
      test5_data_void_in  => test5_data_void_in,
      test5_stop_out      => test5_stop_out,
      test6_input_port    => test6_input_port,
      test6_data_void_in  => test6_data_void_in,
      test6_stop_out      => test6_stop_out,
      noc1_input_port     => noc1_input_port,
      noc1_data_void_in   => noc1_cpu_data_void_in,
      noc1_stop_out       => noc1_cpu_stop_out,
      noc2_input_port     => noc2_input_port,
      noc2_data_void_in   => noc2_cpu_data_void_in,
      noc2_stop_out       => noc2_cpu_stop_out,
      noc3_input_port     => noc3_input_port,
      noc3_data_void_in   => noc3_cpu_data_void_in,
      noc3_stop_out       => noc3_cpu_stop_out,
      noc4_input_port     => noc4_input_port,
      noc4_data_void_in   => noc4_cpu_data_void_in,
      noc4_stop_out       => noc4_cpu_stop_out,
      noc5_input_port     => noc5_input_port,
      noc5_data_void_in   => noc5_cpu_data_void_in,
      noc5_stop_out       => noc5_cpu_stop_out,
      noc6_input_port     => noc6_input_port,
      noc6_data_void_in   => noc6_cpu_data_void_in,
      noc6_stop_out       => noc6_cpu_stop_out);

  -----------------------------------------------------------------------------
  -- Tile parameters
  -----------------------------------------------------------------------------
  tile_id                <= to_integer(unsigned(tile_config(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB)));
  pad_cfg                <= tile_config(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB);

  this_cpu_id            <= tile_cpu_id(tile_id);
  this_ariane_hartid_cfg <= tile_config(ESP_CSR_ARIANE_HARTID_MSB downto ESP_CSR_ARIANE_HARTID_LSB + 1);
  this_cpu_id_lv         <= conv_std_logic_vector(this_cpu_id, 64) when tile_config(ESP_CSR_ARIANE_HARTID_LSB) = '0' else X"0000_0000_0000_000" & this_ariane_hartid_cfg;

  this_dvfs_pindex       <= cpu_dvfs_pindex(tile_id);
  this_dvfs_paddr        <= cpu_dvfs_paddr(tile_id);
  this_dvfs_pmask        <= cpu_dvfs_pmask;
  this_dvfs_pconfig      <= cpu_dvfs_pconfig(tile_id);

  this_cache_id          <= tile_cache_id(tile_id);
  this_l2_pindex         <= l2_cache_pindex(tile_id);
  this_l2_pconfig        <= fixed_apbo_pconfig(this_l2_pindex);

  this_csr_pindex        <= tile_csr_pindex(tile_id);
  this_csr_pconfig       <= fixed_apbo_pconfig(this_csr_pindex);

  this_local_y           <= tile_y(tile_id);
  this_local_x           <= tile_x(tile_id);

  -----------------------------------------------------------------------------
  -- NOC Connections
  ----------------------------------------------------------------------------
  noc1_stop_in_s         <= noc1_cpu_stop_in  & noc1_stop_in;
  noc1_stop_out          <= noc1_stop_out_s(3 downto 0);
  noc1_cpu_stop_out      <= noc1_stop_out_s(4);
  noc1_data_void_in_s    <= noc1_cpu_data_void_in & noc1_data_void_in;
  noc1_data_void_out     <= noc1_data_void_out_s(3 downto 0);
  noc1_cpu_data_void_out <= noc1_data_void_out_s(4);
  noc2_stop_in_s         <= noc2_cpu_stop_in  & noc2_stop_in;
  noc2_stop_out          <= noc2_stop_out_s(3 downto 0);
  noc2_cpu_stop_out      <= noc2_stop_out_s(4);
  noc2_data_void_in_s    <= noc2_cpu_data_void_in & noc2_data_void_in;
  noc2_data_void_out     <= noc2_data_void_out_s(3 downto 0);
  noc2_cpu_data_void_out <= noc2_data_void_out_s(4);
  noc3_stop_in_s         <= noc3_cpu_stop_in  & noc3_stop_in;
  noc3_stop_out          <= noc3_stop_out_s(3 downto 0);
  noc3_cpu_stop_out      <= noc3_stop_out_s(4);
  noc3_data_void_in_s    <= noc3_cpu_data_void_in & noc3_data_void_in;
  noc3_data_void_out     <= noc3_data_void_out_s(3 downto 0);
  noc3_cpu_data_void_out <= noc3_data_void_out_s(4);
  noc4_stop_in_s         <= noc4_cpu_stop_in  & noc4_stop_in;
  noc4_stop_out          <= noc4_stop_out_s(3 downto 0);
  noc4_cpu_stop_out      <= noc4_stop_out_s(4);
  noc4_data_void_in_s    <= noc4_cpu_data_void_in & noc4_data_void_in;
  noc4_data_void_out     <= noc4_data_void_out_s(3 downto 0);
  noc4_cpu_data_void_out <= noc4_data_void_out_s(4);
  noc5_stop_in_s         <= noc5_cpu_stop_in  & noc5_stop_in;
  noc5_stop_out          <= noc5_stop_out_s(3 downto 0);
  noc5_cpu_stop_out      <= noc5_stop_out_s(4);
  noc5_data_void_in_s    <= noc5_cpu_data_void_in & noc5_data_void_in;
  noc5_data_void_out     <= noc5_data_void_out_s(3 downto 0);
  noc5_cpu_data_void_out <= noc5_data_void_out_s(4);
  noc6_stop_in_s         <= noc6_cpu_stop_in  & noc6_stop_in;
  noc6_stop_out          <= noc6_stop_out_s(3 downto 0);
  noc6_cpu_stop_out      <= noc6_stop_out_s(4);
  noc6_data_void_in_s    <= noc6_cpu_data_void_in & noc6_data_void_in;
  noc6_data_void_out     <= noc6_data_void_out_s(3 downto 0);
  noc6_cpu_data_void_out <= noc6_data_void_out_s(4);

  sync_noc_set_cpu: sync_noc_set
  generic map (
     PORTS    => ROUTER_PORTS,
     HAS_SYNC => HAS_SYNC )
   port map (
     clk                => sys_clk_int,
     clk_tile           => clk_feedthru,
     rst                => rst,
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

  -----------------------------------------------------------------------------
  -- Bus
  -----------------------------------------------------------------------------

  leon3_bus_gen: if GLOB_CPU_ARCH = leon3 or GLOB_CPU_ARCH = ibex generate

  hbus_pnp_gen : process (ahbso, noc_ahbso, noc_ahbso_2) is
  begin  -- process hbus_pnp_gen
    ctrl_ahbso <= noc_ahbso;

    for i in 0 to NAHBSLV - 1 loop
      if slm_ahb_mask(i) = '1' then
        ctrl_ahbso(i) <= noc_ahbso_2(i);
      end if;

      if this_local_ahb_en(i) = '1' then
        ctrl_ahbso(i) <= ahbso(i);
      end if;
    end loop;  -- i

  end process hbus_pnp_gen;

  ahb0 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => maxahbm, nahbs => maxahbs)
    port map (rst, clk_feedthru, ahbmi, ahbmo, ahbsi, ctrl_ahbso);


  -- apb2noc proxy handles pindex and pconfig assignments
  -- All APB slaves in the CPU tile are seen as remote for the CPU, even those
  -- that are local to the tile. This allows any SoC master to access these slaves.
  -- Requests from the CPU are forwarded to an apb2noc proxy, then to the
  -- router. Requests for local slaves reenter immediately the tile and are
  -- served by a noc2apb proxy. All other requests will reach the destination
  -- tile. The AHB2APB bridge has been modified to be latency insensitive.
  apb0 : patient_apbctrl                -- AHB/APB bridge
    generic map (hindex     => ahb2apb_hindex, haddr => CFG_APBADDR, hmask => ahb2apb_hmask, nslaves => NAPBSLV,
                 remote_apb => this_remote_apb_slv_en)
    port map (rst, clk_feedthru, ahbsi, ahbso(ahb2apb_hindex), apbi, apbo, apb_req, apb_ack);

  end generate leon3_bus_gen;

  -----------------------------------------------------------------------------
  -- Drive unused bus ports
  -----------------------------------------------------------------------------

  leon3_bus_not_driven_gen: if GLOB_CPU_ARCH = leon3 or GLOB_CPU_ARCH = ibex generate

  -- Master hindex must match cpu_id. This restriction only applies to LEON3
  nam1 : for i in 1 to CFG_NCPU_TILE - 1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

  nam2 : for i in CFG_NCPU_TILE + CFG_L2_ENABLE to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

  no_hslv_gen : for i in 0 to NAHBSLV - 1 generate
    no_hslv_i_gen : if this_local_ahb_en(i) = '0' generate
      ahbso(i) <= ahbs_none;
    end generate no_hslv_i_gen;
  end generate no_hslv_gen;

  end generate leon3_bus_not_driven_gen;

  no_pslv_gen : for i in 0 to NAPBSLV - 1 generate
    -- NB: all local I/O-bus slaves are accessed through proxy as if they were
    -- remote. This allows any master in the system to access them
    no_pslv_i_gen : if this_local_apb_en(i) = '0' generate
      noc_apbo(i) <= apb_none;
    end generate no_pslv_i_gen;
  end generate no_pslv_gen;


  -----------------------------------------------------------------------------
  ---  Processor core
  -----------------------------------------------------------------------------

  --pragma translate_off
  process(clk_feedthru, rst)
  begin  -- process
    if rst = '1' then
      assert (GLOB_CPU_ARCH = leon3 or GLOB_CPU_ARCH = ariane or GLOB_CPU_ARCH = ibex) report "Processor core architecture not supported!" severity failure;
    end if;
  end process;
  --pragma translate_on

  -- Processor core reset
  cleanrstn <= rst and tile_config(ESP_CSR_VALID_LSB);

  -- SRST (soft reset) must be asserted twice:
  -- In between the two reset period, a program can be loaded to both the
  -- bootrom and the system main memory.
  -- The reset pulse is longer than one cycle, so we need to detect both edges
  cpu_rstn_state_update: process (clk_feedthru, rst) is
  begin  -- process cpu_rstn_gen
    if rst = '0' then                 -- asynchronous reset (active low)
      cpu_rstn_state <= por;
    elsif clk_feedthru'event and clk_feedthru = '1' then  -- rising clock edge
      cpu_rstn_state <= cpu_rstn_next;
    end if;
  end process cpu_rstn_state_update;

  cpu_rstn_gen_sim: if SIMULATION = true generate

    cpu_rstn_sim_fsm: process (cpu_rstn_state, cleanrstn) is
    begin
      cpu_rstn_next <= cpu_rstn_state;
      cpurstn <= '0';

      case cpu_rstn_state is

        when por =>
          if cleanrstn = '1' then
            cpu_rstn_next <= soft_reset_1_h;
          end if;

        when soft_reset_1_h =>
          cpu_rstn_next <= soft_reset_1_l;

        when soft_reset_1_l =>
          cpu_rstn_next <= soft_reset_2_h;

        when soft_reset_2_h =>
          cpu_rstn_next <= soft_reset_2_l;

        when soft_reset_2_l =>
          cpu_rstn_next <= soft_reset_3_h;

        when soft_reset_3_h =>
          cpu_rstn_next <= soft_reset_3_l;

        when soft_reset_3_l =>
          cpu_rstn_next <= soft_reset_4_h;

        when soft_reset_4_h =>
          cpu_rstn_next <= run;

        when run =>
          cpurstn <= '1';

        when others =>
          cpu_rstn_next <= por;

      end case;
    end process cpu_rstn_sim_fsm;

  end generate cpu_rstn_gen_sim;

  cpu_rstn_gen: if SIMULATION = false generate

    cpu_rstn_fsm: process (cpu_rstn_state, srst) is
    begin  -- process cpu_rstn_fsm

      cpu_rstn_next <= cpu_rstn_state;
      cpurstn <= '0';

      case cpu_rstn_state is

        when por =>
          if srst = '1' then
            cpu_rstn_next <= soft_reset_1_h;
          end if;

        when soft_reset_1_h =>
          if srst = '0' then
            cpu_rstn_next <= soft_reset_1_l;
          end if;

        when soft_reset_1_l =>
          if srst = '1' then
            cpu_rstn_next <= soft_reset_2_h;
          end if;

        when soft_reset_2_h =>
          if srst = '0' then
            cpu_rstn_next <= soft_reset_2_l;
          end if;

        when soft_reset_2_l =>
          if srst = '1' then
            cpu_rstn_next <= soft_reset_3_h;
          end if;

        when soft_reset_3_h =>
          if srst = '0' then
            cpu_rstn_next <= soft_reset_3_l;
          end if;

        when soft_reset_3_l =>
          if srst = '1' then
            cpu_rstn_next <= soft_reset_4_h;
          end if;

        when soft_reset_4_h =>
          if srst = '0' then
            cpu_rstn_next <= run;
          end if;

        when run =>
          cpurstn <= '1';
          if srst = '1' then
            cpu_rstn_next <= soft_reset_1_h;
          end if;

        when others =>
          cpu_rstn_next <= por;

      end case;
    end process cpu_rstn_fsm;

  end generate cpu_rstn_gen;


  -- Leon3
  leon3_cpu_gen: if GLOB_CPU_ARCH = leon3 generate

  leon3_0 : leon3s
    generic map (0, CFG_FABTECH, CFG_FABTECH, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8,
                 0, CFG_MAC, pclow, CFG_NOTAG, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
                 CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
                 CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
                 CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
                 CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU_TILE-1,
                 CFG_DFIXED, CFG_SCAN, CFG_MMU_PAGE, CFG_BP)
    port map (clk_feedthru, cpurstn, this_cpu_id, ahbmi, ahbmo(0), ahbsi, ahbso, dflush,
              irqi, irqo_int, dbgi, dbgo);

  dbgi <= dbgi_none;
  cpuerr <= not dbgo.error;
  irqo <= irqo_int;

  end generate leon3_cpu_gen;

  -- Ibex
  ibex_cpu_gen: if GLOB_CPU_ARCH = ibex generate
    ibex_ahb_wrap_1: ibex_ahb_wrap
      generic map (
        hindex     => 0,
        ROMBase    => X"0000_0000")
      port map (
        rstn      => cpurstn,
        clk       => clk_feedthru,
        HART_ID   => this_cpu_id_lv(31 downto 0),
        irq       => irq,
        timer_irq => timer_irq,
        ipi       => ipi,
        core_idle => core_idle,
        ahbmi     => ahbmi,
        ahbmo     => ahbmo(0));

    -- We handle I/O with a model of the UART. Therefore when core writes
    -- `to_host` we've reached the call to exit
    cpuerr <= '1' when  ahbmo(0).htrans /= HTRANS_IDLE and ahbmo(0).haddr = X"8000149C" else '0';

    -- L1 is only present optionally for instructions; no need to flush it
    -- L2 can be flushed immediately when necessary.
    dflush <= '1';

    -- RISC-V PLIC/CLINT outputs
    irq       <= irqi.irl(1 downto 0);
    timer_irq <= irqi.irl(2);
    ipi       <= irqi.irl(3);

    -- IRQ claim/ack occurs via memory-mapped registers
    irqo <= irq_out_none;
  end generate ibex_cpu_gen;

  -- Ariane
  ariane_cpu_gen: if GLOB_CPU_ARCH = ariane generate

    ariane_axi_wrap_1: ariane_axi_wrap
      generic map (
        NMST             => 2,
        NSLV             => 5,
        ROMBase          => X"0000_0000_0001_0000",
        ROMLength        => X"0000_0000_0001_0000",
        APBBase          => X"0000_0000" & conv_std_logic_vector(CFG_APBADDR, 12) & X"0_0000",
        APBLength        => X"0000_0000_1000_0000",
        CLINTBase        => X"0000_0000_0200_0000",
        CLINTLength      => X"0000_0000_000C_0000",
        SLMBase          => X"0000_0000_0400_0000",
        SLMLength        => X"0000_0000_0400_0000",  -- Reserving up to 64MB; devtree can set less
        DRAMBase         => X"0000_0000" & conv_std_logic_vector(ddr_haddr(0), 12) & X"0_0000",
        DRAMLength       => X"0000_0000_6000_0000",
        DRAMCachedLength => X"0000_0000_2000_0000")  -- TODO: length set automatically to match devtree
      port map (
        clk         => clk_feedthru,
        rstn        => cpurstn,
        HART_ID     => this_cpu_id_lv,
        irq         => irq,
        timer_irq   => timer_irq,
        ipi         => ipi,
        romi        => mosi(0),
        romo        => somi(0),
        drami       => ariane_drami,
        dramo       => ariane_dramo,
        clinti      => mosi(2),
        clinto      => somi(2),
        slmi        => mosi(3),
        slmo        => somi(3),
        apbi        => apbi,
        apbo        => apbo,
        apb_req     => apb_req,
        apb_ack     => apb_ack);

    -- exit() writes to this address right before completing the program
    -- Next instruction is a jump to current PC.
    cpuerr <= '1' when ariane_drami.aw.addr = X"80001000" and ariane_drami.aw.valid = '1' else '0';

    -- L1 can't be flushed on Ariane. So flush upon command.
    dflush <= '1';

    -- RISC-V PLIC/CLINT outputs
    irq       <= irqi.irl(1 downto 0);
    timer_irq <= irqi.irl(2);
    ipi       <= irqi.irl(3);

    -- IRQ claim/ack occurs via memory-mapped registers
    irqo <= irq_out_none;

  end generate ariane_cpu_gen;

  -----------------------------------------------------------------------------
  -- Services
  -----------------------------------------------------------------------------

  l2_rstn <= cpurstn and rst;

  with_cache_coherence : if CFG_L2_ENABLE /= 0 generate

    -- Memory access w/ cache coherence (write-back L2 cache)
    l2_wrapper_1 : l2_wrapper
      generic map (
        tech          => CFG_FABTECH,
        sets          => CFG_L2_SETS,
        ways          => CFG_L2_WAYS,
        little_end    => GLOB_CPU_RISCV,
        hindex_mst    => CFG_NCPU_TILE,
        pindex        => 1,
        pirq          => CFG_SLD_L2_CACHE_IRQ,
        mem_hindex    => ddr_hindex(0),
        mem_hconfig   => cpu_tile_mig7_hconfig,
        mem_num       => CFG_NMEM_TILE,
        mem_info      => tile_mem_list(0 to MEM_ID_RANGE_MSB),
        cache_y       => cache_y,
        cache_x       => cache_x,
        cache_tile_id => cache_tile_id)
      port map (
        rst                        => l2_rstn,
        clk                        => clk_feedthru,
        local_y                    => this_local_y,
        local_x                    => this_local_x,
        pconfig                    => this_l2_pconfig,
        cache_id                   => this_cache_id,
        ahbsi                      => cache_ahbsi,
        ahbso                      => cache_ahbso,
        ahbmi                      => ahbmi,
        ahbmo                      => ahbmo(CFG_NCPU_TILE),
        mosi                       => cache_drami,
        somi                       => cache_dramo,
        apbi                       => noc_apbi,
        apbo                       => noc_apbo(1),
        flush                      => dflush,
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
        mon_cache                  => mon_cache_int
        );

  end generate with_cache_coherence;

  leon3_cpu_tile_services_gen: if GLOB_CPU_ARCH = leon3 or GLOB_CPU_ARCH = ibex generate

  leon3_no_cache_coherence : if CFG_L2_ENABLE = 0 generate
    coherence_rsp_snd_data_in <= (others => '0');
    coherence_rsp_snd_wrreq   <= '0';
    coherence_fwd_rdreq       <= '0';
    mon_cache_int                 <= monitor_cache_none;

    -- Remote uncached slaves, including memory
    -- Memory request/response sue planes 1 and 3; other slaves use plane 5
    ahbslv2noc_1 : ahbslv2noc
      generic map (
        tech             => CFG_FABTECH,
        hindex           => this_remote_ahb_slv_en,
        hconfig          => cpu_tile_fixed_ahbso_hconfig,
        mem_hindex       => ddr_hindex(0),
        mem_num          => CFG_NMEM_TILE,
        mem_info         => tile_mem_list,
        slv_y            => tile_y(io_tile_id),
        slv_x            => tile_x(io_tile_id),
        retarget_for_dma => 0,
        dma_length       => CFG_DLINE)
      port map (
        rst                        => cleanrstn,
        clk                        => clk_feedthru,
        local_y                    => this_local_y,
        local_x                    => this_local_x,
        ahbsi                      => ahbsi,
        ahbso                      => noc_ahbso,
        dma_selected               => '0',
        coherence_req_wrreq        => coherence_req_wrreq,
        coherence_req_data_in      => coherence_req_data_in,
        coherence_req_full         => coherence_req_full,
        coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,
        coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
        coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,
        remote_ahbs_snd_wrreq      => remote_ahbs_snd_wrreq,
        remote_ahbs_snd_data_in    => remote_ahbs_snd_data_in,
        remote_ahbs_snd_full       => remote_ahbs_snd_full,
        remote_ahbs_rcv_rdreq      => remote_ahbs_rcv_rdreq,
        remote_ahbs_rcv_data_out   => remote_ahbs_rcv_data_out,
        remote_ahbs_rcv_empty      => remote_ahbs_rcv_empty);

  end generate leon3_no_cache_coherence;

  leon3_with_cache_coherence : if CFG_L2_ENABLE /= 0 generate

    ahbso(ddr_hindex(0)) <= cache_ahbso;
    cache_ahbsi <= ahbsi;


    -- Remote uncached slaves
    ahbslv2noc_1 : ahbslv2noc
      generic map (
        tech             => CFG_FABTECH,
        hindex           => this_remote_ahb_slv_en,
        hconfig          => cpu_tile_fixed_ahbso_hconfig,
        mem_hindex       => ddr_hindex(0),
        mem_num          => CFG_NMEM_TILE,
        mem_info         => tile_mem_list,
        slv_y            => tile_y(io_tile_id),
        slv_x            => tile_x(io_tile_id),
        retarget_for_dma => 0,
        dma_length       => CFG_DLINE)
      port map (
        rst                        => cleanrstn,
        clk                        => clk_feedthru,
        local_y                    => this_local_y,
        local_x                    => this_local_x,
        ahbsi                      => ahbsi,
        ahbso                      => noc_ahbso,
        dma_selected               => '0',
        coherence_req_wrreq        => open,
        coherence_req_data_in      => open,
        coherence_req_full         => '0',
        coherence_rsp_rcv_rdreq    => open,
        coherence_rsp_rcv_data_out => (others => '0'),
        coherence_rsp_rcv_empty    => '1',
        remote_ahbs_snd_wrreq      => remote_ahbs_snd_wrreq,
        remote_ahbs_snd_data_in    => remote_ahbs_snd_data_in,
        remote_ahbs_snd_full       => remote_ahbs_snd_full,
        remote_ahbs_rcv_rdreq      => remote_ahbs_rcv_rdreq,
        remote_ahbs_rcv_data_out   => remote_ahbs_rcv_data_out,
        remote_ahbs_rcv_empty      => remote_ahbs_rcv_empty);

  end generate leon3_with_cache_coherence;

  -- Remote uncached slaves: shared-local memory; using DMA planes
  ahbslv2noc_3 : ahbslv2noc
    generic map (
      tech             => CFG_FABTECH,
      hindex           => slm_ahb_mask,
      hconfig          => cpu_tile_fixed_ahbso_hconfig,
      mem_hindex       => slm_hindex(0),
      mem_num          => CFG_NSLM_TILE,
      mem_info         => tile_slm_list,
      slv_y            => tile_y(io_tile_id),
      slv_x            => tile_x(io_tile_id),
      retarget_for_dma => 0,
      dma_length       => CFG_DLINE)
    port map (
      rst                        => cleanrstn,
      clk                        => clk_feedthru,
      local_y                    => this_local_y,
      local_x                    => this_local_x,
      ahbsi                      => ahbsi,
      ahbso                      => noc_ahbso_2,
      dma_selected               => '0',
      coherence_req_wrreq        => dma_snd_wrreq,
      coherence_req_data_in      => dma_snd_data_in_cpu,
      coherence_req_full         => dma_snd_full,
      coherence_rsp_rcv_rdreq    => dma_rcv_rdreq,
      coherence_rsp_rcv_data_out => dma_rcv_data_out,
      coherence_rsp_rcv_empty    => dma_rcv_empty,
      remote_ahbs_snd_wrreq      => open,
      remote_ahbs_snd_data_in    => open,
      remote_ahbs_snd_full       => '0',
      remote_ahbs_rcv_rdreq      => open,
      remote_ahbs_rcv_data_out   => (others => '0'),
      remote_ahbs_rcv_empty      => '1');

  end generate leon3_cpu_tile_services_gen;


  ariane_cpu_tile_services_gen: if GLOB_CPU_ARCH = ariane generate

    ariane_with_cache_coherence: if CFG_L2_ENABLE /= 0 generate
      cache_drami <= ariane_drami;
      ariane_dramo <= cache_dramo;

      mosi(1) <= axi_mosi_none;

      cache_ahbsi <= ahbs_in_none;

      axislv2noc_1: axislv2noc
        generic map (
          tech         => CFG_FABTECH,
          nmst         => 3,
          retarget_for_dma => 0,
          mem_axi_port => 1,
          mem_num      => CFG_NMEM_TILE,
          mem_info     => tile_mem_list,
          slv_y        => tile_y(io_tile_id),
          slv_x        => tile_x(io_tile_id))
        port map (
          rst                        => rst,
          clk                        => clk_feedthru,
          local_y                    => this_local_y,
          local_x                    => this_local_x,
          mosi                       => mosi(0 to 2),
          somi                       => somi(0 to 2),
          coherence_req_wrreq        => open,
          coherence_req_data_in      => open,
          coherence_req_full         => '0',
          coherence_rsp_rcv_rdreq    => open,
          coherence_rsp_rcv_data_out => (others => '0'),
          coherence_rsp_rcv_empty    => '1',
          remote_ahbs_snd_wrreq      => remote_ahbs_snd_wrreq,
          remote_ahbs_snd_data_in    => remote_ahbs_snd_data_in,
          remote_ahbs_snd_full       => remote_ahbs_snd_full,
          remote_ahbs_rcv_rdreq      => remote_ahbs_rcv_rdreq,
          remote_ahbs_rcv_data_out   => remote_ahbs_rcv_data_out,
          remote_ahbs_rcv_empty      => remote_ahbs_rcv_empty);

    end generate ariane_with_cache_coherence;

    ariane_no_cache_coherence : if CFG_L2_ENABLE = 0 generate
      cache_drami <= axi_mosi_none;

      mosi(1) <= ariane_drami;
      ariane_dramo <= somi(1);

      coherence_rsp_snd_data_in <= (others => '0');
      coherence_rsp_snd_wrreq   <= '0';
      coherence_fwd_rdreq       <= '0';
      mon_cache_int             <= monitor_cache_none;

      axislv2noc_1: axislv2noc
        generic map (
          tech         => CFG_FABTECH,
          nmst         => 3,
          retarget_for_dma => 0,
          mem_axi_port => 1,
          mem_num      => CFG_NMEM_TILE,
          mem_info     => tile_mem_list,
          slv_y        => tile_y(io_tile_id),
          slv_x        => tile_x(io_tile_id))
        port map (
          rst                        => cleanrstn,
          clk                        => clk_feedthru,
          local_y                    => this_local_y,
          local_x                    => this_local_x,
          mosi                       => mosi(0 to 2),
          somi                       => somi(0 to 2),
          coherence_req_wrreq        => coherence_req_wrreq,
          coherence_req_data_in      => coherence_req_data_in,
          coherence_req_full         => coherence_req_full,
          coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,
          coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
          coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,
          remote_ahbs_snd_wrreq      => remote_ahbs_snd_wrreq,
          remote_ahbs_snd_data_in    => remote_ahbs_snd_data_in,
          remote_ahbs_snd_full       => remote_ahbs_snd_full,
          remote_ahbs_rcv_rdreq      => remote_ahbs_rcv_rdreq,
          remote_ahbs_rcv_data_out   => remote_ahbs_rcv_data_out,
          remote_ahbs_rcv_empty      => remote_ahbs_rcv_empty);

    end generate ariane_no_cache_coherence;

    -- Remote uncached slaves: shared-local memory; using DMA planes
    axislv2noc_3: axislv2noc
      generic map (
        tech         => CFG_FABTECH,
        nmst         => 1,
        retarget_for_dma => 0,
        mem_axi_port => 0,
        mem_num      => CFG_NSLM_TILE,
        mem_info     => tile_slm_list,
        slv_y        => tile_y(io_tile_id),
        slv_x        => tile_x(io_tile_id))
      port map (
        rst                        => cleanrstn,
        clk                        => clk_feedthru,
        local_y                    => this_local_y,
        local_x                    => this_local_x,
        mosi                       => mosi(3 to 3),
        somi                       => somi(3 to 3),
        coherence_req_wrreq        => dma_snd_wrreq,
        coherence_req_data_in      => dma_snd_data_in_cpu,
        coherence_req_full         => dma_snd_full,
        coherence_rsp_rcv_rdreq    => dma_rcv_rdreq,
        coherence_rsp_rcv_data_out => dma_rcv_data_out,
        coherence_rsp_rcv_empty    => dma_rcv_empty,
        remote_ahbs_snd_wrreq      => open,
        remote_ahbs_snd_data_in    => open,
        remote_ahbs_snd_full       => '0',
        remote_ahbs_rcv_rdreq      => open,
        remote_ahbs_rcv_data_out   => (others => '0'),
        remote_ahbs_rcv_empty      => '1');

  end generate ariane_cpu_tile_services_gen;

  mon_cache <= mon_cache_int;

  -- DVFS
  dvfs_gen : if this_has_dvfs /= 0 and this_has_pll /= 0 generate
    dvfs_top_1 : dvfs_top
      generic map (
        tech          => CFG_FABTECH,
        extra_clk_buf => this_extra_clk_buf,
        pindex        => 2)
      port map (
        rst       => cleanrstn,
        clk       => clk_feedthru,
        paddr     => this_dvfs_paddr,
        pmask     => this_dvfs_pmask,
        refclk    => dvfs_clk,
        pllbypass => pllbypass,
        pllclk    => clk_feedthru,
        apbi      => noc_apbi,
        apbo      => noc_apbo(2),
        acc_idle  => mon_dvfs_in.acc_idle,
        traffic   => mon_dvfs_in.traffic,
        burst     => mon_dvfs_in.burst,
        mon_dvfs  => mon_dvfs_ctrl
        );

    mon_dvfs_int.clk       <= mon_dvfs_ctrl.clk;
    mon_dvfs_int.vf        <= mon_dvfs_ctrl.vf;
    mon_dvfs_int.transient <= mon_dvfs_ctrl.transient;
  end generate dvfs_gen;

  dvfs_no_master_or_no_dvfs : if this_has_dvfs = 0 or this_has_pll = 0 generate
      clk_feedthru <= dvfs_clk;

    process (clk_feedthru, rst)
    begin  -- process
      if rst = '0' then                 -- asynchronous reset (active low)
        mon_dvfs_int.vf <= "1000";
      elsif clk_feedthru'event and clk_feedthru = '1' then  -- rising clock edge
        if this_has_dvfs /= 0 then
          mon_dvfs_int.vf <= mon_dvfs_in.vf;
        end if;
      end if;
    end process;
    process (mon_dvfs_in)
    begin  -- process
      if this_has_dvfs = 1 then
        mon_dvfs_int.transient <= mon_dvfs_in.transient;
      else
        mon_dvfs_int.transient <= '0';
      end if;
    end process;
    mon_dvfs_int.clk <= clk_feedthru;
  end generate dvfs_no_master_or_no_dvfs;

  --Monitors
  cpu_monitor_gen: process (irqo_int, core_idle) is
  begin  -- process cpu_monitor_gen
    if GLOB_CPU_ARCH = leon3 then
      mon_dvfs_int.acc_idle <= irqo_int.pwd;
    elsif GLOB_CPU_ARCH = ibex then
      mon_dvfs_int.acc_idle <= core_idle;
    else
      mon_dvfs_int.acc_idle <= '0';
    end if;
  end process cpu_monitor_gen;
  mon_dvfs_int.traffic  <= '0';
  mon_dvfs_int.burst    <= '0';

  mon_dvfs <= mon_dvfs_int;

  noc1_mon_noc_vec <= noc1_mon_noc_vec_int;
  noc2_mon_noc_vec <= noc2_mon_noc_vec_int;
  noc3_mon_noc_vec <= noc3_mon_noc_vec_int;
  noc4_mon_noc_vec <= noc4_mon_noc_vec_int;
  noc5_mon_noc_vec <= noc5_mon_noc_vec_int;
  noc6_mon_noc_vec <= noc6_mon_noc_vec_int;

  mon_noc(1) <= noc1_mon_noc_vec_int;
  mon_noc(2) <= noc2_mon_noc_vec_int;
  mon_noc(3) <= noc3_mon_noc_vec_int;
  mon_noc(4) <= noc4_mon_noc_vec_int;
  mon_noc(5) <= noc5_mon_noc_vec_int;
  mon_noc(6) <= noc6_mon_noc_vec_int;

  -- Memory mapped registers
  cpu_tile_csr : esp_tile_csr
    generic map(
      pindex  => 0)
    port map(
      clk => clk_feedthru,
      rstn => rst,
      pconfig => this_csr_pconfig,
      mon_ddr => monitor_ddr_none,
      mon_mem => monitor_mem_none,
      mon_noc => mon_noc,
      mon_l2 => mon_cache_int,
      mon_llc => monitor_cache_none,
      mon_acc => monitor_acc_none,
      mon_dvfs => mon_dvfs_int,
      tile_config => tile_config,
      srst => srst,
      apbi => noc_apbi,
      apbo => noc_apbo(0)
    );

  -- I/O bus proxy - remote memory-mapped I/O accessed from local masters
  apb2noc_1 : apb2noc
    generic map (
      tech        => CFG_FABTECH,
      ncpu        => CFG_NCPU_TILE,
      apb_slv_en  => this_remote_apb_slv_en,
      apb_slv_cfg => fixed_apbo_pconfig,
      apb_slv_y   => apb_slv_y,
      apb_slv_x   => apb_slv_x)
    port map (
      rst                     => rst,
      clk                     => clk_feedthru,
      local_y                 => this_local_y,
      local_x                 => this_local_x,
      apbi                    => apbi,
      apbo                    => apbo,
      apb_req                 => apb_req,
      apb_ack                 => apb_ack,
      remote_apb_snd_wrreq    => remote_apb_snd_wrreq,
      remote_apb_snd_data_in  => remote_apb_snd_data_in,
      remote_apb_snd_full     => remote_apb_snd_full,
      remote_apb_rcv_rdreq    => remote_apb_rcv_rdreq,
      remote_apb_rcv_data_out => remote_apb_rcv_data_out,
      remote_apb_rcv_empty    => remote_apb_rcv_empty);

  -- I/O bus proxy - local memory-mapped I/O accessed from remote masters
  noc2apb_1 : noc2apb
    generic map (
      tech         => CFG_FABTECH,
      local_apb_en => this_local_apb_en)
    port map (
      rst              => rst,
      clk              => clk_feedthru,
      local_y          => this_local_y,
      local_x          => this_local_x,
      apbi             => noc_apbi,
      apbo             => noc_apbo,
      pready           => '1',
      dvfs_transient   => '0',
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty);

  -- Interrupt level acknowledge - remote interrupt controller
  intack2noc_1 : intack2noc
    generic map (
      tech  => CFG_FABTECH,
      irq_y => tile_y(io_tile_id),
      irq_x => tile_x(io_tile_id))
    port map (
      rst                    => cleanrstn,
      clk                    => clk_feedthru,
      cpu_id                 => this_cpu_id,
      local_y                => this_local_y,
      local_x                => this_local_x,
      irqi                   => irqi,
      irqo                   => irqo,
      irqo_fifo_overflow     => open,
      remote_irq_rdreq       => remote_irq_rdreq,
      remote_irq_data_out    => remote_irq_data_out,
      remote_irq_empty       => remote_irq_empty,
      remote_irq_ack_wrreq   => remote_irq_ack_wrreq,
      remote_irq_ack_data_in => remote_irq_ack_data_in,
      remote_irq_ack_full    => remote_irq_ack_full);

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  -- Mark CPU DMA
  set_cpu_dma: process (dma_snd_data_in_cpu) is
  begin
    dma_snd_data_in <= dma_snd_data_in_cpu;
    if get_preamble(NOC_FLIT_SIZE, dma_snd_data_in_cpu) = PREAMBLE_HEADER then
      dma_snd_data_in(NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - 2 downto
                      NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH) <= CPU_DMA;
    end if;
  end process set_cpu_dma;

  cpu_tile_q_1 : cpu_tile_q
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
      dma_snd_wrreq              => dma_snd_wrreq,
      dma_snd_data_in            => dma_snd_data_in,
      dma_snd_full               => dma_snd_full,
      remote_ahbs_snd_wrreq      => remote_ahbs_snd_wrreq,
      remote_ahbs_snd_data_in    => remote_ahbs_snd_data_in,
      remote_ahbs_snd_full       => remote_ahbs_snd_full,
      remote_ahbs_rcv_rdreq      => remote_ahbs_rcv_rdreq,
      remote_ahbs_rcv_data_out   => remote_ahbs_rcv_data_out,
      remote_ahbs_rcv_empty      => remote_ahbs_rcv_empty,
      apb_rcv_rdreq              => apb_rcv_rdreq,
      apb_rcv_data_out           => apb_rcv_data_out,
      apb_rcv_empty              => apb_rcv_empty,
      apb_snd_wrreq              => apb_snd_wrreq,
      apb_snd_data_in            => apb_snd_data_in,
      apb_snd_full               => apb_snd_full,
      remote_apb_rcv_rdreq       => remote_apb_rcv_rdreq,
      remote_apb_rcv_data_out    => remote_apb_rcv_data_out,
      remote_apb_rcv_empty       => remote_apb_rcv_empty,
      remote_apb_snd_wrreq       => remote_apb_snd_wrreq,
      remote_apb_snd_data_in     => remote_apb_snd_data_in,
      remote_apb_snd_full        => remote_apb_snd_full,
      remote_irq_rdreq           => remote_irq_rdreq,
      remote_irq_data_out        => remote_irq_data_out,
      remote_irq_empty           => remote_irq_empty,
      remote_irq_ack_wrreq       => remote_irq_ack_wrreq,
      remote_irq_ack_data_in     => remote_irq_ack_data_in,
      remote_irq_ack_full        => remote_irq_ack_full,
      noc1_out_data              => test1_output_port,
      noc1_out_void              => test1_data_void_out,
      noc1_out_stop              => test1_stop_in,
      noc1_in_data               => test1_input_port,
      noc1_in_void               => test1_data_void_in,
      noc1_in_stop               => test1_stop_out,
      noc2_out_data              => test2_output_port,
      noc2_out_void              => test2_data_void_out,
      noc2_out_stop              => test2_stop_in,
      noc2_in_data               => test2_input_port,
      noc2_in_void               => test2_data_void_in,
      noc2_in_stop               => test2_stop_out,
      noc3_out_data              => test3_output_port,
      noc3_out_void              => test3_data_void_out,
      noc3_out_stop              => test3_stop_in,
      noc3_in_data               => test3_input_port,
      noc3_in_void               => test3_data_void_in,
      noc3_in_stop               => test3_stop_out,
      noc4_out_data              => test4_output_port,
      noc4_out_void              => test4_data_void_out,
      noc4_out_stop              => test4_stop_in,
      noc4_in_data               => test4_input_port,
      noc4_in_void               => test4_data_void_in,
      noc4_in_stop               => test4_stop_out,
      noc5_out_data              => test5_output_port,
      noc5_out_void              => test5_data_void_out,
      noc5_out_stop              => test5_stop_in,
      noc5_in_data               => test5_input_port,
      noc5_in_void               => test5_data_void_in,
      noc5_in_stop               => test5_stop_out,
      noc6_out_data              => test6_output_port,
      noc6_out_void              => test6_data_void_out,
      noc6_out_stop              => test6_stop_in,
      noc6_in_data               => test6_input_port,
      noc6_in_void               => test6_data_void_in,
      noc6_in_stop               => test6_stop_out);

end;
