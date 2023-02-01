-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on
use work.esp_global.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;
use work.gencaches.all;

use work.nocpackage.all;
use work.allcaches.all;
use work.cachepackage.all;              -- contains l2 cache component
use work.monitor_pkg.all;
use work.misc.all;
use work.socmap.all;


entity l2_wrapper is
  generic (
    tech        : integer := virtex7;
    sets        : integer := 256;
    ways        : integer := 8;
    hindex_mst  : integer := 0;
    pindex      : integer range 0 to NAPBSLV - 1 := 6;
    pirq        : integer := 4;
    little_end  : integer range 0 to 1 := 1;
    mem_hindex  : integer := 4;
    mem_hconfig : ahb_config_type;
    mem_num     : integer := 1;
    mem_info    : tile_mem_info_vector(0 to MEM_ID_RANGE_MSB);
    cache_y     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
    cache_x     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
    cache_tile_id : cache_attribute_array);
  port (
    rst : in std_ulogic;
    clk : in std_ulogic;

    local_y  : in local_yx;
    local_x  : in local_yx;
    pconfig  : in apb_config_type;
    cache_id : in integer;
    tile_id  : in integer range 0 to CFG_TILES_NUM - 1;

    -- frontend (L2 cache - CPU L1)
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type;
    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    mosi  : in  axi_mosi_type;
    somi  : out axi_somi_type;
    ace_req : out  ace_req_type;
    ace_resp: in ace_resp_type;
    apbi  : in  apb_slv_in_type;
    apbo  : out apb_slv_out_type;
    flush : in  std_ulogic;             -- flush request from CPU
    flush_l1 : out std_ulogic;

    -- fence to L2
    fence_l2 : in std_logic_vector(1 downto 0);

    -- backend (cache - NoC)
    -- tile->NoC1
    coherence_req_wrreq        : out std_ulogic;
    coherence_req_data_in      : out noc_flit_type;
    coherence_req_full         : in  std_ulogic;
    -- NoC2->tile
    coherence_fwd_rdreq        : out std_ulogic;
    coherence_fwd_data_out     : in  noc_flit_type;
    coherence_fwd_empty        : in  std_ulogic;
    -- Noc3->tile
    coherence_rsp_rcv_rdreq    : out std_ulogic;
    coherence_rsp_rcv_data_out : in  noc_flit_type;
    coherence_rsp_rcv_empty    : in  std_ulogic;
    -- tile->Noc3
    coherence_rsp_snd_wrreq    : out std_ulogic;
    coherence_rsp_snd_data_in  : out noc_flit_type;
    coherence_rsp_snd_full     : in  std_ulogic;
    -- tile->Noc2
    coherence_fwd_snd_wrreq    : out std_ulogic;
    coherence_fwd_snd_data_in  : out noc_flit_type;
    coherence_fwd_snd_full     : in  std_ulogic;

    mon_cache                  : out monitor_cache_type
    );

end l2_wrapper;

architecture rtl of l2_wrapper is

  -- AHB to cache
  signal cpu_req_ready          : std_ulogic;
  signal cpu_req_valid          : std_ulogic;
  signal cpu_req_data_cpu_msg   : cpu_msg_t;
  signal cpu_req_data_hsize     : hsize_t;
  signal cpu_req_data_hprot     : hprot_t;
  signal cpu_req_data_addr      : addr_t;
  signal cpu_req_data_word      : word_t;
  signal cpu_req_data_amo       : amo_t;
  signal cpu_req_data_aq        : std_ulogic;
  signal cpu_req_data_rl        : std_ulogic;
  signal cpu_req_data_dcs_en    : std_ulogic;
  signal cpu_req_data_use_owner_pred : std_ulogic;
  signal cpu_req_data_dcs       : dcs_t;
  signal cpu_req_data_pred_cid  : cache_id_t;
  signal flush_ready            : std_ulogic;
  signal flush_valid            : std_ulogic;
  signal flush_data             : std_ulogic;
  -- cache to AHB
  signal rd_rsp_ready           : std_ulogic;
  signal rd_rsp_valid           : std_ulogic;
  signal rd_rsp_data_line       : line_t;
  signal inval_ready            : std_ulogic;
  signal inval_valid            : std_ulogic;
  signal inval_data_addr        : line_addr_t;
  signal inval_data_hprot       : hprot_t;
  signal bresp_ready            : std_ulogic;
  signal bresp_valid            : std_ulogic;
  signal bresp_data             : bresp_t;
  -- cache to NoC
  signal req_out_ready          : std_ulogic;
  signal req_out_valid          : std_ulogic;
  signal req_out_data_coh_msg   : coh_msg_t;
  signal req_out_data_hprot     : hprot_t;
  signal req_out_data_addr      : line_addr_t;
  signal req_out_data_line      : line_t;
  signal req_out_data_word_mask : word_mask_t;
  signal rsp_out_ready          : std_ulogic;
  signal rsp_out_valid          : std_ulogic;
  signal rsp_out_data_coh_msg   : coh_msg_t;
  signal rsp_out_data_req_id    : cache_id_t;
  signal rsp_out_data_to_req    : std_logic_vector(1 downto 0);
  signal rsp_out_data_addr      : line_addr_t;
  signal rsp_out_data_line      : line_t;
  signal rsp_out_data_word_mask : word_mask_t;
  signal fwd_out_ready          : std_ulogic;
  signal fwd_out_valid          : std_ulogic;
  signal fwd_out_data_coh_msg   : coh_msg_t;
  signal fwd_out_data_req_id    : cache_id_t;
  signal fwd_out_data_to_req    : std_logic_vector(1 downto 0);
  signal fwd_out_data_addr      : line_addr_t;
  signal fwd_out_data_line      : line_t;
  signal fwd_out_data_word_mask : word_mask_t;
  -- NoC to cache
  signal fwd_in_ready           : std_ulogic;
  signal fwd_in_valid           : std_ulogic;
  signal fwd_in_data_coh_msg    : mix_msg_t;
  signal fwd_in_data_addr       : line_addr_t;
  signal fwd_in_data_req_id     : cache_id_t;
  signal fwd_in_data_word_mask  : word_mask_t;
  signal fwd_in_data_line       : line_t;
  signal rsp_in_valid           : std_ulogic;
  signal rsp_in_ready           : std_ulogic;
  signal rsp_in_data_coh_msg    : coh_msg_t;
  signal rsp_in_data_addr       : line_addr_t;
  signal rsp_in_data_line       : line_t;
  signal rsp_in_data_invack_cnt : invack_cnt_t;
  signal rsp_in_data_word_mask  : word_mask_t;
  -- debug
  --signal asserts                : asserts_t;
  --signal bookmark               : bookmark_t;
  --signal custom_dbg             : custom_dbg_t;
  signal flush_done             : std_ulogic;
  signal acc_flush_done         : std_ulogic;
  -- statistics
  signal stats_ready            : std_ulogic;
  signal stats_valid            : std_ulogic;
  signal stats_data             : std_ulogic;

  -- fence to L2
  signal fence_l2_ready         : std_logic;
  signal fence_l2_valid         : std_logic;
  signal fence_l2_data          : std_logic_vector(1 downto 0);

  type fence_state_t is (idle, valid_fence);
  signal fence_state, fence_next : fence_state_t;
  signal fence_reg : std_logic_vector(1 downto 0);
  signal sample_fence : std_logic;

----------------------------------------------------------------------------
-- APB slave signals
-----------------------------------------------------------------------------

  signal flush_due : std_ulogic;

  -- Command register
  type cmd_state_t is (idle, do_cmd, pending_cmd, wait_irq_clear, wait_l1_flush);
  signal cmd_state, cmd_next : cmd_state_t;

  -- Register bank
  signal cmd_reg       : std_logic_vector(31 downto 0);
  signal status_reg    : std_logic_vector(31 downto 0);
  signal cmd_in        : std_logic_vector(31 downto 0);
  signal cmd_sample    : std_ulogic;
  signal readdata      : std_logic_vector(31 downto 0);

  -------------------------------------------------------------------------------
  -- AHB slave FSM signals
  -------------------------------------------------------------------------------
  type ahbs_fsm is (idle, load_req, load_rsp, load_alloc, store_req, flush_req, mem_req,
                    send_wr_ack);

  type ahbs_reg_type is record
    state         : ahbs_fsm;
    cpu_msg       : cpu_msg_t;
    hsize         : hsize_t;
    hprot         : hprot_t;
    haddr         : addr_t;
    dcs_en        : std_ulogic;
    use_owner_pred: std_ulogic;
    dcs           : dcs_t;
    pred_cid      : cache_id_t;
    req_memorized : std_ulogic;
    asserts       : asserts_ahbs_t;
  end record;

  constant AHBS_REG_DEFAULT : ahbs_reg_type := (
    state         => idle,
    cpu_msg       => CPU_READ,          -- read
    hsize         => HSIZE_W,           -- 1 word
    hprot         => DEFAULT_HPROT,     -- bufferable, non cacheable
    haddr         => (others => '0'),
    dcs_en        => '0',
    use_owner_pred=> '0',
    dcs           => (others => '0'),
    pred_cid      => (others => '0'),
    req_memorized => '0',
    asserts       => (others => '0'));

  signal ahbs_reg      : ahbs_reg_type;
  signal ahbs_reg_next : ahbs_reg_type;

  -------------------------------------------------------------------------------
  -- AXI slave FSM signals
  -------------------------------------------------------------------------------
  type axi_reg_type is record
    id    : std_logic_vector (XID_WIDTH-1 downto 0);
    len   : std_logic_vector (7 downto 0);
    lock  : std_logic;
    cache : std_logic_vector (3 downto 0);
    atop  : std_logic_vector(5 downto 0);
    aq    : std_logic;
    rl    : std_logic;
  end record;

  constant AXI_REG_DEFAULT : axi_reg_type := (
    id       => (others => '0'),
    len      => (others => '0'),
    lock     => '0',
    cache    => (others => '0'),
    atop     => (others => '0'),
    aq       => '0',
    rl       => '0');

  signal axi_reg      : axi_reg_type := AXI_REG_DEFAULT;
  signal axi_reg_next : axi_reg_type := AXI_REG_DEFAULT;

  constant axi_len_zero : std_logic_vector(7 downto 0) := (others => '0');

  -- address increment
  function addr_incr (
    hsize : hsize_t)
    return addr_t is
    variable incr : addr_t;
  begin
    incr := (others => '0');

    case hsize is
      when HSIZE_BYTE  => incr(3 downto 0) := "0001";
      when HSIZE_HWORD => incr(3 downto 0) := "0010";
      when HSIZE_WORD  => incr(3 downto 0) := "0100";
      when HSIZE_DWORD => incr(3 downto 0) := "1000";
      when others      => incr(3 downto 0) := "0000";
    end case;

    return incr;

  end addr_incr;

  -----------------------------------------------------------------------------
  -- AHB master FSM signals
  -----------------------------------------------------------------------------
  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_SLD, SLD_L2_CACHE, 0, 0, 0),
    others => zero32);

  type ahbm_fsm is (idle, grant_wait, store_req, store_rsp);

  type ahbm_reg_type is record
    state   : ahbm_fsm;
    asserts : asserts_ahbm_t;
  end record;

  constant AHBM_REG_DEFAULT : ahbm_reg_type := (
    state   => idle,
    asserts => (others => '0'));

  signal ahbm_reg      : ahbm_reg_type;
  signal ahbm_reg_next : ahbm_reg_type;

  -- FIFO for invalidation addresses
  signal inv_fifo_rdreq        : std_ulogic;
  signal inv_fifo_wrreq        : std_ulogic;
  signal inv_fifo_data_in      : std_logic_vector((ADDR_BITS - OFFSET_BITS) + HPROT_WIDTH - 1 downto 0);
  signal inv_fifo_empty        : std_ulogic;
  signal inv_fifo_almost_empty : std_ulogic;
  signal inv_fifo_full         : std_ulogic;
  signal inv_fifo_data_out     : std_logic_vector((ADDR_BITS - OFFSET_BITS) + HPROT_WIDTH - 1 downto 0);

  signal inv_fifo_data_in_addr  : line_addr_t;
  signal inv_fifo_data_in_hprot : hprot_t;

  signal inv_fifo_data_out_addr  : line_addr_t;
  signal inv_fifo_data_out_hprot : hprot_t;

  -------------------------------------------------------------------------------
  -- FSM: Request to NoC
  -------------------------------------------------------------------------------
  type req_fsm is (send_header, send_addr, send_data);

  type req_reg_type is record
    state    : req_fsm;
    coh_msg  : coh_msg_t;
    addr     : line_addr_t;
    line     : line_t;
    word_cnt : natural range 0 to 3;
    asserts  : asserts_req_t;
  end record req_reg_type;

  constant REQ_REG_DEFAULT : req_reg_type := (
    state    => send_header,
    coh_msg  => (others => '0'),
    addr     => (others => '0'),
    line     => (others => '0'),
    word_cnt => 0,
    asserts  => (others => '0'));

  signal req_reg      : req_reg_type;
  signal req_reg_next : req_reg_type;

  -------------------------------------------------------------------------------
  -- FSM: Response to NoC
  -------------------------------------------------------------------------------
  type rsp_out_fsm is (send_header, send_addr, send_data);

  type rsp_out_reg_type is record
    state    : rsp_out_fsm;
    coh_msg  : coh_msg_t;
    addr     : line_addr_t;
    line     : line_t;
    word_cnt : natural range 0 to 3;
    asserts  : asserts_rsp_out_t;
  end record rsp_out_reg_type;

  constant RSP_OUT_REG_DEFAULT : rsp_out_reg_type := (
    state    => send_header,
    coh_msg  => (others => '0'),
    addr     => (others => '0'),
    line     => (others => '0'),
    word_cnt => 0,
    asserts  => (others => '0'));

  signal rsp_out_reg      : rsp_out_reg_type;
  signal rsp_out_reg_next : rsp_out_reg_type;

  -------------------------------------------------------------------------------
  -- FSM: Forward to NoC
  -------------------------------------------------------------------------------
  type fwd_out_fsm is (send_header, send_addr, send_data);

  type fwd_out_reg_type is record
    state    : fwd_out_fsm;
    coh_msg  : coh_msg_t;
    addr     : line_addr_t;
    line     : line_t;
    word_cnt : natural range 0 to 3;
    asserts  : asserts_fwd_t;
  end record fwd_out_reg_type;

  constant FWD_OUT_REG_DEFAULT : fwd_out_reg_type := (
    state    => send_header,
    coh_msg  => (others => '0'),
    addr     => (others => '0'),
    line     => (others => '0'),
    word_cnt => 0,
    asserts  => (others => '0'));

  signal fwd_out_reg      : fwd_out_reg_type := FWD_OUT_REG_DEFAULT;
  signal fwd_out_reg_next : fwd_out_reg_type := FWD_OUT_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: Forward from  NoC
  -------------------------------------------------------------------------------

  type fwd_in_fsm is (rcv_header, rcv_addr, rcv_data);

  type fwd_in_reg_type is record
    state   : fwd_in_fsm;
    coh_msg : mix_msg_t;
    req_id  : cache_id_t;
    word_mask : word_mask_t;
    addr    : line_addr_t;
    line    : line_t;
    word_cnt : natural range 0 to 3;
    asserts : asserts_fwd_t;
  end record fwd_in_reg_type;

  constant FWD_IN_REG_DEFAULT : fwd_in_reg_type := (
    state   => rcv_header,
    coh_msg => (others => '0'),
    req_id  => (others => '0'),
    word_mask => (others => '0'),
    addr    => (others => '0'),
    line    => (others => '0'),
    word_cnt => 0,
    asserts => (others => '0'));

  signal fwd_in_reg      : fwd_in_reg_type;
  signal fwd_in_reg_next : fwd_in_reg_type;

  -------------------------------------------------------------------------------
  -- FSM: Response from  NoC
  -------------------------------------------------------------------------------

  type rsp_in_fsm is (rcv_header, rcv_addr, rcv_data);

  type rsp_in_reg_type is record
    state      : rsp_in_fsm;
    coh_msg    : coh_msg_t;
    invack_cnt : invack_cnt_t;
    addr       : line_addr_t;
    line       : line_t;
    word_mask  : word_mask_t;
    word_cnt   : natural range 0 to 3;
    asserts    : asserts_rsp_in_t;
  end record rsp_in_reg_type;

  constant RSP_IN_REG_DEFAULT : rsp_in_reg_type := (
    state      => rcv_header,
    coh_msg    => (others => '0'),
    invack_cnt => (others => '0'),
    addr       => (others => '0'),
    line       => (others => '0'),
    word_mask  => (others => '0'),
    word_cnt   => 0,
    asserts    => (others => '0'));

  signal rsp_in_reg      : rsp_in_reg_type;
  signal rsp_in_reg_next : rsp_in_reg_type;

  -----------------------------------------------------------------------------
  -- Read allocate
  -----------------------------------------------------------------------------
  type load_alloc_reg_type is record
    addr : std_logic_vector(ADDR_BITS-1-OFFSET_BITS downto 0);
    line : line_t;
  end record;

  constant LOAD_ALLOC_REG_DEFAULT : load_alloc_reg_type := (
    addr => (others => '0'),
    line => (others => '0'));

  signal load_alloc_reg      : load_alloc_reg_type;
  signal load_alloc_reg_next : load_alloc_reg_type;


  -------------------------------------------------------------------------------
  -- Others
  -------------------------------------------------------------------------------

  constant empty_offset : std_logic_vector(OFFSET_BITS - 1 downto 0) := (others => '0');

  -------------------------------------------------------------------------------
  -- Debug
  -------------------------------------------------------------------------------

  -- Debug signals
  signal ahbs_reg_state    : ahbs_fsm;
  signal ahbm_reg_state    : ahbm_fsm;
  signal req_reg_state     : req_fsm;
  signal rsp_out_reg_state : req_fsm;
  signal rsp_in_reg_state  : rsp_in_fsm;
  signal ahbs_asserts      : asserts_ahbs_t;
  signal ahbm_asserts      : asserts_ahbm_t;
  signal req_asserts       : asserts_req_t;
  signal rsp_in_asserts    : asserts_rsp_in_t;

  -- Debug LEDs
  --signal led_bookmarks       : std_ulogic;
  --signal led_cache_asserts   : std_ulogic;
  --signal led_wrapper_asserts : std_ulogic;

   --attribute mark_debug : string;
   --attribute mark_debug of somi : signal is "true";
   --attribute mark_debug of mosi : signal is "true";
----
  -- attribute mark_debug of ahbs_reg_state   : signal is "true";
  -- attribute mark_debug of ahbm_reg_state   : signal is "true";
  -- attribute mark_debug of req_reg_state    : signal is "true";
  -- attribute mark_debug of rsp_out_reg_state    : signal is "true";
  -- attribute mark_debug of rsp_in_reg_state : signal is "true";

  -- attribute mark_debug of flush_due   : signal is "true";

  -- -- attribute mark_debug of inv_fifo_empty        : signal is "true";
  -- -- attribute mark_debug of inv_fifo_almost_empty : signal is "true";
  -- attribute mark_debug of inv_fifo_full         : signal is "true";
  -- -- attribute mark_debug of inv_fifo_rdreq        : signal is "true";
  -- -- attribute mark_debug of inv_fifo_wrreq        : signal is "true";
  -- -- attribute mark_debug of inv_fifo_data_in      : signal is "true";
  -- -- attribute mark_debug of inv_fifo_data_out     : signal is "true";

  -- --attribute mark_debug of ahbs_asserts : signal is "true";
  -- -- attribute mark_debug of ahbm_asserts   : signal is "true";
  -- -- attribute mark_debug of req_asserts    : signal is "true";
  -- -- attribute mark_debug of rsp_out_asserts    : signal is "true";
  -- -- attribute mark_debug of rsp_in_asserts : signal is "true";

  -- -- AHB to cache
  -- attribute mark_debug of cpu_req_ready          : signal is "true";
  -- attribute mark_debug of cpu_req_valid          : signal is "true";
  -- attribute mark_debug of cpu_req_data_cpu_msg   : signal is "true";
  -- attribute mark_debug of cpu_req_data_hsize     : signal is "true";
  -- attribute mark_debug of cpu_req_data_hprot     : signal is "true";
  -- attribute mark_debug of cpu_req_data_addr      : signal is "true";
  -- attribute mark_debug of cpu_req_data_word      : signal is "true";
  -- attribute mark_debug of flush_ready            : signal is "true";
  -- attribute mark_debug of flush_valid            : signal is "true";
  -- attribute mark_debug of flush_data             : signal is "true";
  -- -- cache to AHB
  -- attribute mark_debug of rd_rsp_ready           : signal is "true";
  -- attribute mark_debug of rd_rsp_valid           : signal is "true";
  -- -- attribute mark_debug of rd_rsp_data_line       : signal is "true";
  -- attribute mark_debug of inval_ready            : signal is "true";
  -- attribute mark_debug of inval_valid            : signal is "true";
  -- attribute mark_debug of inval_data             : signal is "true";
  -- -- cache to NoC
  -- attribute mark_debug of req_out_ready          : signal is "true";
  -- attribute mark_debug of req_out_valid          : signal is "true";
  -- attribute mark_debug of req_out_data_coh_msg   : signal is "true";
  -- attribute mark_debug of req_out_data_hprot     : signal is "true";
  -- attribute mark_debug of req_out_data_addr      : signal is "true";
  -- -- attribute mark_debug of req_out_data_line      : signal is "true";
  -- attribute mark_debug of rsp_out_ready          : signal is "true";
  -- attribute mark_debug of rsp_out_valid          : signal is "true";
  -- attribute mark_debug of rsp_out_data_coh_msg   : signal is "true";
  -- attribute mark_debug of rsp_out_data_req_id    : signal is "true";
  -- attribute mark_debug of rsp_out_data_to_req    : signal is "true";
  -- attribute mark_debug of rsp_out_data_addr      : signal is "true";
  -- -- attribute mark_debug of rsp_out_data_line      : signal is "true";
  -- -- NoC to cache
  -- attribute mark_debug of fwd_in_ready           : signal is "true";
  -- attribute mark_debug of fwd_in_valid           : signal is "true";
  -- attribute mark_debug of fwd_in_data_coh_msg    : signal is "true";
  -- attribute mark_debug of fwd_in_data_addr       : signal is "true";
  -- attribute mark_debug of fwd_in_data_req_id     : signal is "true";
  -- attribute mark_debug of rsp_in_valid           : signal is "true";
  -- attribute mark_debug of rsp_in_ready           : signal is "true";
  -- attribute mark_debug of rsp_in_data_coh_msg    : signal is "true";
  -- attribute mark_debug of rsp_in_data_addr       : signal is "true";
  -- -- attribute mark_debug of rsp_in_data_line       : signal is "true";
  -- attribute mark_debug of rsp_in_data_invack_cnt : signal is "true";
  -- -- debug
  -- --attribute mark_debug of asserts                : signal is "true";
  -- --attribute mark_debug of bookmark               : signal is "true";
  -- -- attribute mark_debug of custom_dbg             : signal is "true";
  -- attribute mark_debug of flush_done             : signal is "true";
  -- -- statistics
  -- attribute mark_debug of stats_ready            : signal is "true";
  -- attribute mark_debug of stats_valid            : signal is "true";
  -- attribute mark_debug of stats_data             : signal is "true";

begin  -- architecture rtl of l2_wrapper

  -----------------------------------------------------------------------------
  -- Instantiations
  -----------------------------------------------------------------------------
  l2_gen: if USE_SPANDEX = 0 generate
    l2_cache_i : l2
    generic map (
      use_rtl => CFG_CACHE_RTL,
      little_end => little_end,
      llsc => GLOB_CPU_LLSC,
      sets => sets,
      ways => ways)
    port map (
      clk => clk,
      rst => rst,

      -- AHB to cache
      l2_cpu_req_ready          => cpu_req_ready,
      l2_cpu_req_valid          => cpu_req_valid,
      l2_cpu_req_data_cpu_msg   => cpu_req_data_cpu_msg,
      l2_cpu_req_data_hsize     => cpu_req_data_hsize,
      l2_cpu_req_data_hprot     => cpu_req_data_hprot,
      l2_cpu_req_data_addr      => cpu_req_data_addr,
      l2_cpu_req_data_word      => cpu_req_data_word,
      l2_cpu_req_data_amo       => cpu_req_data_amo,
      l2_flush_ready            => flush_ready,
      l2_flush_valid            => flush_valid,
      l2_flush_data             => flush_data,
      -- cache to AHB
      l2_rd_rsp_ready           => rd_rsp_ready,
      l2_rd_rsp_valid           => rd_rsp_valid,
      l2_rd_rsp_data_line       => rd_rsp_data_line,
      l2_inval_ready            => inval_ready,
      l2_inval_valid            => inval_valid,
      l2_inval_data_addr        => inval_data_addr,
      l2_inval_data_hprot       => inval_data_hprot,
      l2_bresp_ready            => bresp_ready,
      l2_bresp_valid            => bresp_valid,
      l2_bresp_data             => bresp_data,
      -- cache to NoC
      l2_req_out_ready          => req_out_ready,
      l2_req_out_valid          => req_out_valid,
      l2_req_out_data_coh_msg   => req_out_data_coh_msg(1 downto 0),
      l2_req_out_data_hprot     => req_out_data_hprot,
      l2_req_out_data_addr      => req_out_data_addr,
      l2_req_out_data_line      => req_out_data_line,
      l2_rsp_out_ready          => rsp_out_ready,
      l2_rsp_out_valid          => rsp_out_valid,
      l2_rsp_out_data_coh_msg   => rsp_out_data_coh_msg(1 downto 0),
      l2_rsp_out_data_req_id    => rsp_out_data_req_id,
      l2_rsp_out_data_to_req    => rsp_out_data_to_req,
      l2_rsp_out_data_addr      => rsp_out_data_addr,
      l2_rsp_out_data_line      => rsp_out_data_line,
      -- NoC to cache
      l2_fwd_in_ready           => fwd_in_ready,
      l2_fwd_in_valid           => fwd_in_valid,
      l2_fwd_in_data_coh_msg    => fwd_in_data_coh_msg(2 downto 0),
      l2_fwd_in_data_addr       => fwd_in_data_addr,
      l2_fwd_in_data_req_id     => fwd_in_data_req_id,
      l2_rsp_in_ready           => rsp_in_ready,
      l2_rsp_in_valid           => rsp_in_valid,
      l2_rsp_in_data_coh_msg    => rsp_in_data_coh_msg(1 downto 0),
      l2_rsp_in_data_addr       => rsp_in_data_addr,
      l2_rsp_in_data_line       => rsp_in_data_line,
      l2_rsp_in_data_invack_cnt => rsp_in_data_invack_cnt,
      flush_done                => flush_done,
      l2_stats_ready            => stats_ready,
      l2_stats_valid            => stats_valid,
      l2_stats_data             => stats_data
    );

    -- ESP (USE_SPANDEX = 0) cache coherence messages begin with "110" on the NoC
    -- We append the additional '1' in the FSM based on USE_SPANDEX
    req_out_data_coh_msg(COH_MSG_TYPE_WIDTH - 1 downto 2) <= "10";
    rsp_out_data_coh_msg(COH_MSG_TYPE_WIDTH - 1 downto 2) <= "10";

    -- Spandex concatenates hprot with a word mask to forward writes of
    -- granularity smaller than a cache line to the next levels of hierarchy.
    -- When USE_SPANDEX is set to zero, word_mask is ignored, but we set all
    -- bits to '1' to indicate that the entire line is going to be written.
    req_out_data_word_mask <= (others => '1');
    rsp_out_data_word_mask <= (others => '1');

    -- Spandex uses forward messages from the L2 for peer-to-peer communication.
    -- Disabling this queue when USE_SPANDEX is 0
    fwd_out_valid          <= '0';
    fwd_out_data_coh_msg   <= (others => '0');
    fwd_out_data_req_id    <= (others => '0');
    fwd_out_data_to_req    <= (others => '0');
    fwd_out_data_addr      <= (others => '0');
    fwd_out_data_line      <= (others => '0');
    fwd_out_data_word_mask <= (others => '0');

  end generate l2_gen;

  l2_spandex_gen: if USE_SPANDEX = 1 generate
    l2_cache_i : l2_spandex
    generic map (
      use_rtl => CFG_CACHE_RTL,
      little_end => little_end,
      sets => sets,
      ways => ways)
    port map (
      clk => clk,
      rst => rst,

      -- AHB to cache
      l2_cpu_req_ready          => cpu_req_ready,
      l2_cpu_req_valid          => cpu_req_valid,
      l2_cpu_req_data_cpu_msg   => cpu_req_data_cpu_msg,
      l2_cpu_req_data_hsize     => cpu_req_data_hsize,
      l2_cpu_req_data_hprot     => cpu_req_data_hprot,
      l2_cpu_req_data_addr      => cpu_req_data_addr,
      l2_cpu_req_data_dcs_en    => cpu_req_data_dcs_en,
      l2_cpu_req_data_use_owner_pred => cpu_req_data_use_owner_pred,
      l2_cpu_req_data_dcs       => cpu_req_data_dcs,
      l2_cpu_req_data_pred_cid  => cpu_req_data_pred_cid,
      l2_cpu_req_data_word      => cpu_req_data_word,
      l2_cpu_req_data_amo       => cpu_req_data_amo,
      l2_cpu_req_data_aq        => cpu_req_data_aq,
      l2_cpu_req_data_rl        => cpu_req_data_rl,
      l2_flush_ready            => flush_ready,
      l2_flush_valid            => flush_valid,
      l2_flush_data             => flush_data,
      -- cache to AHB
      l2_rd_rsp_ready           => rd_rsp_ready,
      l2_rd_rsp_valid           => rd_rsp_valid,
      l2_rd_rsp_data_line       => rd_rsp_data_line,
      l2_inval_ready            => inval_ready,
      l2_inval_valid            => inval_valid,
      l2_inval_data_addr        => inval_data_addr,
      l2_inval_data_hprot       => inval_data_hprot,
      l2_bresp_ready            => bresp_ready,
      l2_bresp_valid            => bresp_valid,
      l2_bresp_data             => bresp_data,
      -- cache to NoC
      l2_req_out_ready          => req_out_ready,
      l2_req_out_valid          => req_out_valid,
      l2_req_out_data_coh_msg   => req_out_data_coh_msg,
      l2_req_out_data_hprot     => req_out_data_hprot,
      l2_req_out_data_addr      => req_out_data_addr,
      l2_req_out_data_line      => req_out_data_line,
      l2_req_out_data_word_mask => req_out_data_word_mask,
      l2_rsp_out_ready          => rsp_out_ready,
      l2_rsp_out_valid          => rsp_out_valid,
      l2_rsp_out_data_coh_msg   => rsp_out_data_coh_msg,
      l2_rsp_out_data_req_id    => rsp_out_data_req_id,
      l2_rsp_out_data_to_req    => rsp_out_data_to_req,
      l2_rsp_out_data_addr      => rsp_out_data_addr,
      l2_rsp_out_data_line      => rsp_out_data_line,
      l2_rsp_out_data_word_mask => rsp_out_data_word_mask,
      l2_fwd_out_ready          => fwd_out_ready,
      l2_fwd_out_valid          => fwd_out_valid,
      l2_fwd_out_data_coh_msg   => fwd_out_data_coh_msg,
      l2_fwd_out_data_req_id    => fwd_out_data_req_id,
      l2_fwd_out_data_to_req    => fwd_out_data_to_req,
      l2_fwd_out_data_addr      => fwd_out_data_addr,
      l2_fwd_out_data_line      => fwd_out_data_line,
      l2_fwd_out_data_word_mask => fwd_out_data_word_mask,
      -- NoC to cache
      l2_fwd_in_ready           => fwd_in_ready,
      l2_fwd_in_valid           => fwd_in_valid,
      l2_fwd_in_data_coh_msg    => fwd_in_data_coh_msg,
      l2_fwd_in_data_addr       => fwd_in_data_addr,
      l2_fwd_in_data_req_id     => fwd_in_data_req_id,
      l2_fwd_in_data_word_mask  => fwd_in_data_word_mask,
      l2_fwd_in_data_line       => fwd_in_data_line,
      l2_rsp_in_ready           => rsp_in_ready,
      l2_rsp_in_valid           => rsp_in_valid,
      l2_rsp_in_data_coh_msg    => rsp_in_data_coh_msg,
      l2_rsp_in_data_addr       => rsp_in_data_addr,
      l2_rsp_in_data_line       => rsp_in_data_line,
      l2_rsp_in_data_word_mask  => rsp_in_data_word_mask,
      l2_rsp_in_data_invack_cnt => rsp_in_data_invack_cnt,
      flush_done                => flush_done,
      acc_flush_done            => acc_flush_done,
      l2_stats_ready            => stats_ready,
      l2_stats_valid            => stats_valid,
      l2_stats_data             => stats_data,
      l2_fence_ready            => fence_l2_ready,
      l2_fence_valid            => fence_l2_valid,
      l2_fence_data             => fence_l2_data
      );
  end generate l2_spandex_gen;

  fence_ready_gen: if USE_SPANDEX = 0 generate
    fence_l2_ready <= '0';
  end generate fence_ready_gen;

  Invalidate_fifo : fifo_custom
    generic map (
      depth => N_REQS + 12,             -- TODO: what size here?
      width => ADDR_BITS - OFFSET_BITS + HPROT_WIDTH)
    port map (
      clk          => clk,
      rst          => rst,
      rdreq        => inv_fifo_rdreq,
      wrreq        => inv_fifo_wrreq,
      data_in      => inv_fifo_data_in,
      empty        => inv_fifo_empty,
      almost_empty => inv_fifo_almost_empty,
      full         => inv_fifo_full,
      data_out     => inv_fifo_data_out);

  inv_fifo_data_in        <= inv_fifo_data_in_hprot & inv_fifo_data_in_addr;
  inv_fifo_data_out_hprot <= inv_fifo_data_out(ADDR_BITS - OFFSET_BITS + HPROT_WIDTH - 1 downto ADDR_BITS - OFFSET_BITS);
  inv_fifo_data_out_addr  <= inv_fifo_data_out(ADDR_BITS - OFFSET_BITS - 1 downto 0);

  ----------------------------------------------------------------------------
  -- Fence signal state
  -----------------------------------------------------------------------------
  fence_update : process (clk, rst) is
  begin
    if rst = '0' then
      fence_state <= idle;
      fence_reg   <= (others => '0');
    elsif clk'event and clk = '1' then
      fence_state <= fence_next;
      if sample_fence = '1' then
        fence_reg <= fence_l2_data;
      end if;
    end if;
  end process fence_update;

  fence_state_fsm : process (fence_l2, fence_l2_ready, fence_state, fence_reg) is
  begin
    fence_next     <= fence_state;
    fence_l2_valid <= '0';
    fence_l2_data  <= (others => '0');
    sample_fence   <= '0';

    case fence_state is
      when idle =>
        fence_l2_data <= fence_l2;
        if fence_l2 /= "00" and USE_SPANDEX /= 0 then
          fence_l2_valid <= '1';
          if fence_l2_ready = '0' then
            fence_next   <= valid_fence;
            sample_fence <= '1';
          end if;
        end if;

      when valid_fence =>
        fence_l2_data  <= fence_reg;
        fence_l2_valid <= '1';
        if fence_l2_ready = '1' then
          fence_next <= idle;
        end if;

      when others =>
        fence_next <= idle;
    end case;
  end process fence_state_fsm;

-------------------------------------------------------------------------------
-- APB slave interface (flush)
-------------------------------------------------------------------------------

  -- APB Interface
  apbo.prdata  <= readdata;
  apbo.pirq    <= (others => '0');
  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  -- rd/wr registers
  process(apbi, status_reg, cmd_reg)
  begin

    cmd_in     <= apbi.pwdata;
    cmd_sample <= apbi.psel(pindex) and apbi.penable and apbi.pwrite and (not apbi.paddr(2));

    case apbi.paddr(2) is
      when '0' =>
        readdata <= cmd_reg;
      when others =>
        readdata <= status_reg;
    end case;

  end process;

  -- Command and status register
  cmd_status: process (clk, rst)
  begin  -- process cmd_status
    if rst = '0' then                   -- asynchronous reset (active low)
      cmd_reg     <= (others => '0');
      status_reg  <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      status_reg(31 downto 28) <= std_logic_vector(to_unsigned(cache_id, 4));
      if flush_done = '1' then
        status_reg(0) <= '1';
      end if;
      if cmd_reg(1 downto 0) = "00" then
        status_reg(0) <= '0';
      end if;
      if cmd_sample = '1' then
        cmd_reg(2 downto 0) <= cmd_in(2 downto 0);
      end if;
    end if;
  end process cmd_status;

  -- Do flush
  cmd_state_update: process (clk, rst) is
  begin  -- process cmd_state_update
    if rst = '0' then                   -- asynchronous reset (active low)
      cmd_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      cmd_state <= cmd_next;
    end if;
  end process cmd_state_update;

  cmd_state_fsm: process (cmd_state, flush_valid, flush_ready, flush_done, flush, cmd_reg) is
  begin  -- process cmd_state_fsm
    cmd_next <= cmd_state;
    flush_due <= '0';
    flush_l1 <= '0';

    case cmd_state is
      when idle =>
        if cmd_reg(1 downto 0) = "10" then
          cmd_next <= wait_l1_flush;
          flush_l1 <= '1';
        end if;

      when wait_l1_flush =>
        flush_l1 <= '1';
        if flush = '1' then
          flush_due <= '1';
          if (flush_valid and flush_ready) = '1' then
            cmd_next <= pending_cmd;
          else
            cmd_next <= do_cmd;
          end if;
        end if;

      when do_cmd =>
        flush_due <= '1';
        if (flush_valid and flush_ready) = '1' then
          cmd_next <= pending_cmd;
        end if;

      when pending_cmd =>
        if flush_done = '1' then
          cmd_next <= wait_irq_clear;
        end if;

      when wait_irq_clear =>
        if cmd_reg(1 downto 0) = "00" then
          cmd_next <= idle;
        end if;

      when others =>
        cmd_next <= idle;
    end case;

  end process cmd_state_fsm;

  flush_data  <= cmd_reg(2);           -- Flush data (0) / flush all (1)

-------------------------------------------------------------------------------
-- Static outputs: AHB/AXI slave, AHB master, ACE, NoC
-------------------------------------------------------------------------------
  ahbso.hresp   <= HRESP_OKAY;
  ahbso.hsplit  <= (others => '0');
  ahbso.hirq    <= (others => '0');
  ahbso.hconfig <= mem_hconfig;
  ahbso.hindex  <= mem_hindex;

  ahbmo.hwrite  <= '1';
  ahbmo.hsize   <= HSIZE_W;
  ahbmo.hprot   <= "1101";
  wide_bus: if ARCH_BITS /= 32 generate
    ahbmo.hwdata(ARCH_BITS - 1 downto 32) <= (others => '0');
  end generate wide_bus;
  ahbmo.hwdata(31 downto 0)  <= x"cacedade";
  ahbmo.hburst  <= HBURST_SINGLE;
  ahbmo.hirq    <= (others => '0');
  ahbmo.hconfig <= hconfig;
  ahbmo.hindex  <= hindex_mst;

  stats_ready    <= '1';
  mon_cache.clk  <= clk;
  mon_cache.miss <= stats_valid and (not stats_data);
  mon_cache.hit  <= stats_valid and stats_data;

-------------------------------------------------------------------------------
-- State update for all the FSMs
-------------------------------------------------------------------------------
  fsms_state_update : process (clk, rst)
  begin
    if rst = '0' then

      ahbs_reg       <= AHBS_REG_DEFAULT;
      axi_reg        <= AXI_REG_DEFAULT;
      ahbm_reg       <= AHBM_REG_DEFAULT;
      req_reg        <= REQ_REG_DEFAULT;
      rsp_out_reg    <= RSP_OUT_REG_DEFAULT;
      fwd_in_reg     <= FWD_IN_REG_DEFAULT;
      rsp_in_reg     <= RSP_IN_REG_DEFAULT;
      fwd_out_reg    <= FWD_OUT_REG_DEFAULT;
      load_alloc_reg <= LOAD_ALLOC_REG_DEFAULT;

    elsif clk'event and clk = '1' then

      ahbs_reg       <= ahbs_reg_next;
      axi_reg        <= axi_reg_next;
      ahbm_reg       <= ahbm_reg_next;
      req_reg        <= req_reg_next;
      fwd_in_reg     <= fwd_in_reg_next;
      rsp_out_reg    <= rsp_out_reg_next;
      fwd_out_reg    <= fwd_out_reg_next;
      rsp_in_reg     <= rsp_in_reg_next;
      load_alloc_reg <= load_alloc_reg_next;

    end if;
  end process fsms_state_update;

  ahb_frontend_gen: if GLOB_CPU_AXI = 0 generate
    -- Set unused AXI outputs
    -- aw
    somi.aw.ready <= '0';
    -- ar
    somi.ar.ready <= '0';
    -- w
    somi.w.ready <= '0';
    -- r
    somi.r.id    <= (others => '0');
    somi.r.resp  <= RBRESP_OKAY;
    somi.r.last  <= '0';
    somi.r.user  <= (others => '0');
    somi.r.valid <= '0';
    somi.r.data(ARCH_BITS - 1 downto 0) <= (others => '0');
    somi.r.data(31 downto 0) <= x"dadecace";
    -- b
    somi.b.id    <= (others => '0');
    somi.b.resp  <= RBRESP_OKAY;
    somi.b.user  <= (others => '0');
    somi.b.valid <= '0';

    -- Set L2 cache bresp channel as always ready
    bresp_ready <= '1';

    ace_req.ac.addr  <= (others => '0');
    ace_req.ac.prot  <= (others => '0');
    ace_req.ac.snoop <= (others => '0');
    ace_req.ac.valid <= '0';

-------------------------------------------------------------------------------
-- FSM: Bridge from AHB slave to L2 cache frontend input
-------------------------------------------------------------------------------
  fsm_ahbs : process (ahbsi, flush, ahbs_reg,
                      cpu_req_ready, flush_ready, flush_due,
                      rd_rsp_valid, rd_rsp_data_line, load_alloc_reg,
                      inv_fifo_full)

    variable reg           : ahbs_reg_type;
    variable alloc_reg     : load_alloc_reg_type;
    variable selected      : std_ulogic;
    variable valid_ahb_req : std_ulogic;

  begin
    -- copy current state into a variable
    reg         := ahbs_reg;
    reg.asserts := (others => '0');
    alloc_reg   := load_alloc_reg;

    -- default values of output signals
    ahbso.hready <= '0';
    ahbso.hrdata <= (others => '0');
    ahbso.hrdata(31 downto 0) <= x"dadecace";

    cpu_req_valid        <= '0';
    cpu_req_data_cpu_msg <= (others => '0');
    cpu_req_data_hsize   <= (others => '0');
    cpu_req_data_hprot   <= (others => '0');
    cpu_req_data_addr    <= (others => '0');
    cpu_req_data_word    <= (others => '0');
    cpu_req_data_amo     <= (others => '0');

    flush_valid <= '0';

    rd_rsp_ready <= '0';

    -- check if memory is selected
    selected := ahbsi.hsel(mem_hindex);

    -- check for valid requests on AHB bus
    if (selected = '1' and ahbsi.hready = '1' and ahbsi.htrans /= HTRANS_IDLE and
        (to_integer(unsigned(ahbsi.hmaster)) /= hindex_mst)) then
      valid_ahb_req := '1';
    else
      valid_ahb_req := '0';
    end if;

    if valid_ahb_req = '1' and not (ahbsi.hsize = "000" or ahbsi.hsize = "001" or ahbsi.hsize = "010") then
      reg.asserts(AS_AHBS_HSIZE) := '1';
    end if;

    if valid_ahb_req = '1' and ahbsi.hprot(3 downto 2) /= "11" then
      reg.asserts(AS_AHBS_CACHEABLE) := '1';
    end if;

    if valid_ahb_req = '1' and ahbsi.hprot(0) = '0' and
      (ahbsi.hsize /= HSIZE_W or ahbsi.hwrite = '1') then
      reg.asserts(AS_AHBS_OPCODE) := '1';
    end if;

    if inv_fifo_full = '1' then
      reg.asserts(AS_AHBS_INV_FIFO) := '1';
    end if;

    case ahbs_reg.state is

      -- IDLE
      when idle =>
        -- always acknowledge transaction requests as soon as they appear on the bus
        ahbso.hready <= '1';

        cpu_req_data_cpu_msg <= ahbsi.hwrite & ahbsi.hmastlock;
        cpu_req_data_hsize   <= ahbsi.hsize;
        cpu_req_data_hprot   <= '0' & ahbsi.hprot(0);
        cpu_req_data_addr    <= ahbsi.haddr;

        if flush_due = '1' and ahbsi.hmastlock = '0' then
          flush_valid <= '1';

          if valid_ahb_req = '1' then
            reg.cpu_msg := ahbsi.hwrite & ahbsi.hmastlock;
            reg.hsize   := ahbsi.hsize;
            reg.hprot   := '0' & ahbsi.hprot(0);
            reg.haddr   := ahbsi.haddr;

            if flush_ready = '0' then
              reg.state := flush_req;
            else
              reg.state := mem_req;
            end if;
          end if;

        elsif valid_ahb_req = '1' then
          reg.cpu_msg := ahbsi.hwrite & ahbsi.hmastlock;
          reg.hsize   := ahbsi.hsize;
          reg.hprot   := '0' & ahbsi.hprot(0);
          reg.haddr   := ahbsi.haddr;

          if ahbsi.hwrite = '0' then

            cpu_req_valid  <= '1';
            alloc_reg.addr := ahbsi.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);

            if cpu_req_ready = '1' then
              reg.state := load_rsp;
            else
              reg.state := load_req;
            end if;

          else

            reg.state := store_req;

          end if;
        end if;

        if valid_ahb_req = '1' and ahbsi.htrans /= "10" then
          reg.asserts(AS_AHBS_IDLE_HTRANS) := '1';
        end if;

      -- LOAD REQUEST
      when load_req =>
        cpu_req_data_cpu_msg <= reg.cpu_msg;
        cpu_req_data_hsize   <= reg.hsize;
        cpu_req_data_hprot   <= reg.hprot;
        cpu_req_data_addr    <= reg.haddr;

        cpu_req_valid <= '1';

        if cpu_req_ready = '1' then
          reg.state := load_rsp;
        end if;

        if ahbsi.hready = '1' then
          reg.asserts(AS_AHBS_LDREQ_HREADY) := '1';
        end if;

      -- LOAD RESPONSE
      when load_rsp =>
        rd_rsp_ready <= '1';

        cpu_req_data_cpu_msg <= ahbsi.hwrite & ahbsi.hmastlock;
        cpu_req_data_hsize   <= ahbsi.hsize;
        cpu_req_data_hprot   <= '0' & ahbsi.hprot(0);
        cpu_req_data_addr    <= ahbsi.haddr;

        alloc_reg.line := rd_rsp_data_line;

        if rd_rsp_valid = '1' then

          ahbso.hrdata <= read_from_line(reg.haddr, rd_rsp_data_line);
          ahbso.hready <= '1';

          reg.cpu_msg := ahbsi.hwrite & ahbsi.hmastlock;
          reg.hsize   := ahbsi.hsize;
          reg.hprot   := '0' & ahbsi.hprot(0);
          reg.haddr   := ahbsi.haddr;

          if (flush_due = '1' and not (ahbsi.hprot(0) = '0' and valid_ahb_req = '1') and
              ahbsi.hmastlock = '0') then

            flush_valid <= '1';

            if valid_ahb_req = '1' then
              if flush_ready = '0' then
                reg.state := flush_req;
              else
                reg.state := mem_req;
              end if;
            else
              reg.state := idle;
            end if;

          elsif valid_ahb_req = '1' then
            if ahbsi.hwrite = '0' then

              if load_alloc_reg.addr = ahbsi.haddr(LINE_RANGE_HI downto LINE_RANGE_LO) then

                reg.state := load_alloc;

              else

                cpu_req_valid  <= '1';
                alloc_reg.addr := ahbsi.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);

                if cpu_req_ready = '1' then
                  reg.state := load_rsp;
                else
                  reg.state := load_req;
                end if;
              end if;

            else

              reg.state := store_req;

            end if;

          else

            reg.state := idle;

          end if;
        elsif ahbsi.hready = '1' then
          reg.asserts(AS_AHBS_LDRSP_HREADY) := '1';
        end if;


      -- LOAD_ALLOC
      when load_alloc =>

        ahbso.hrdata <= read_from_line(reg.haddr, load_alloc_reg.line);
        ahbso.hready <= '1';

        cpu_req_data_cpu_msg <= ahbsi.hwrite & ahbsi.hmastlock;
        cpu_req_data_hsize   <= ahbsi.hsize;
        cpu_req_data_hprot   <= '0' & ahbsi.hprot(0);
        cpu_req_data_addr    <= ahbsi.haddr;

        reg.cpu_msg := ahbsi.hwrite & ahbsi.hmastlock;
        reg.hsize   := ahbsi.hsize;
        reg.hprot   := '0' & ahbsi.hprot(0);
        reg.haddr   := ahbsi.haddr;

        if (flush_due = '1' and not (ahbsi.hprot(0) = '0' and valid_ahb_req = '1') and ahbsi.hmastlock = '0') then

          flush_valid <= '1';

          if valid_ahb_req = '1' then

            if flush_ready = '0' then
              reg.state := flush_req;
            else
              reg.state := mem_req;
            end if;

          else

            reg.state := idle;

          end if;

        elsif valid_ahb_req = '1' then

          if ahbsi.hwrite = '0' then

            if load_alloc_reg.addr = ahbsi.haddr(LINE_RANGE_HI downto LINE_RANGE_LO) then

              reg.state := load_alloc;

            else

              cpu_req_valid  <= '1';
              alloc_reg.addr := ahbsi.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);

              if cpu_req_ready = '1' then
                reg.state := load_rsp;
              else
                reg.state := load_req;
              end if;
            end if;

          else

            reg.state := store_req;

          end if;

        else

          reg.state := idle;

        end if;


      -- STORE REQUEST
      -- TODO: we don't check for htrans = HTRANS_BUSY because Leon3 never sets
      -- it, however this would be necessary to be AHB 2.0 compliant.
      when store_req =>

        cpu_req_data_cpu_msg <= reg.cpu_msg;
        cpu_req_data_hsize   <= reg.hsize;
        cpu_req_data_hprot   <= reg.hprot;
        cpu_req_data_addr    <= reg.haddr;
        cpu_req_data_word    <= ahbreadword(ahbsi.hwdata);

        cpu_req_valid <= '1';

        if cpu_req_ready = '1' then
          reg.cpu_msg := ahbsi.hwrite & ahbsi.hmastlock;
          reg.hsize   := ahbsi.hsize;
          reg.hprot   := '0' & ahbsi.hprot(0);
          reg.haddr   := ahbsi.haddr;

          ahbso.hready <= '1';

          if (flush_due = '1' and not (ahbsi.hprot(0) = '0' and valid_ahb_req = '1') and ahbsi.hmastlock = '0') then

            flush_valid <= '1';

            if valid_ahb_req = '1' then
              if flush_ready = '0' then
                reg.state := flush_req;
              else
                reg.state := mem_req;
              end if;
            else
              reg.state := idle;
            end if;

          elsif valid_ahb_req = '1' then
            if ahbsi.hwrite = '0' then

              alloc_reg.addr := ahbsi.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);
              reg.state      := load_req;

            else

              reg.state := store_req;

            end if;

          else

            reg.state := idle;

          end if;

        elsif ahbsi.hready = '1' then
          reg.asserts(AS_AHBS_STRSP_HREADY) := '1';
        end if;

      -- FLUSH REQUEST
      when flush_req =>
        ahbso.hready <= '0';

        flush_valid <= '1';

        if flush_ready = '1' then
          reg.state := mem_req;
        end if;

        if ahbsi.hready = '1' then
          reg.asserts(AS_AHBS_FLUSH_HREADY) := '1';
        end if;

        if flush_due = '0' then
          reg.asserts(AS_AHBS_FLUSH_DUE) := '1';
        end if;

      -- MEMORIZED REQUEST
      when mem_req =>
        ahbso.hready <= '0';

        if reg.cpu_msg = CPU_READ or reg.cpu_msg = CPU_READ_ATOM then
          alloc_reg.addr := reg.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);
          reg.state      := load_req;
        else
          reg.state := store_req;
        end if;

        if ahbsi.hready = '1' then
          reg.asserts(AS_AHBS_MEM_HREADY) := '1';
        end if;

        if flush_due = '1' then
          reg.asserts(AS_AHBS_MEM_DUE) := '1';
        end if;

      when send_wr_ack =>
        reg.asserts(AS_INV_STATE) := '1';
        reg.state := idle;

    end case;

    ahbs_reg_next       <= reg;
    load_alloc_reg_next <= alloc_reg;

  end process fsm_ahbs;

-------------------------------------------------------------------------------
-- FSM: Bridge from L2 cache frontend output to AHB master (L1 invalidation)
-------------------------------------------------------------------------------
  ahb_no_inval_gen: if GLOB_CPU_ARCH = ibex generate
    inval_ready      <= '1';
    inv_fifo_rdreq   <= '0';
    inv_fifo_wrreq   <= '0';
    inv_fifo_data_in_addr  <= (others => '0');
    inv_fifo_data_in_hprot <= (others => '0');

    ahbmo.hbusreq    <= '0';
    ahbmo.htrans     <=  HTRANS_IDLE;
    ahbmo.hlock      <= '0';
    ahbmo.haddr      <= (others => '0');
  end generate ahb_no_inval_gen;

  ahb_inval_gen: if GLOB_CPU_ARCH /= ibex generate
    -- put writes of invalidate addresses coming from the L2 cache into a FIFO
    inval_ready      <= inval_valid when inv_fifo_full = '0' else '0';  -- ADD
    inv_fifo_wrreq   <= inval_valid when inv_fifo_full = '0' else '0';  -- ADD
    inv_fifo_data_in_addr  <= inval_data_addr;
    inv_fifo_data_in_hprot <= inval_data_hprot;

  fsm_ahbm : process (ahbm_reg, ahbmi, inv_fifo_empty, inv_fifo_almost_empty, inv_fifo_data_out_addr)

    variable granted : std_ulogic;
    variable reg     : ahbm_reg_type;

  begin

    -- save current state into a variable
    reg         := ahbm_reg;
    reg.asserts := (others => '0');

    -- default output signals
    ahbmo.hbusreq  <= '0';
    ahbmo.htrans   <= HTRANS_IDLE;
    ahbmo.haddr    <= x"43214321";
    ahbmo.hburst  <= HBURST_SINGLE;
    inv_fifo_rdreq <= '0';
    ahbmo.hlock   <= '0';

    -- check if bus has been granted
    granted := ahbmi.hgrant(hindex_mst);

    -- select next state and set outputs
    case ahbm_reg.state is

      -- IDLE
      when idle =>

        if inv_fifo_empty = '0' then

          ahbmo.hbusreq <= '1';
          ahbmo.hlock   <= '1';
          ahbmo.htrans  <= HTRANS_NONSEQ;
          ahbmo.haddr(LINE_RANGE_HI downto LINE_RANGE_LO) <= inv_fifo_data_out_addr;
          ahbmo.haddr(OFFSET_BITS - 1 downto 0) <= (others => '0');

          if granted = '1' and ahbmi.hready = '1' then
            reg.state := store_req;
          else
            reg.state := grant_wait;
          end if;

        end if;

      -- GRANT WAIT
      when grant_wait =>
        ahbmo.hbusreq <= '1';
        ahbmo.hlock   <= '1';
        ahbmo.htrans  <= HTRANS_NONSEQ;
        ahbmo.haddr(LINE_RANGE_HI downto LINE_RANGE_LO) <= inv_fifo_data_out_addr;
        ahbmo.haddr(OFFSET_BITS - 1 downto 0) <= (others => '0');

        if (granted = '1' and ahbmi.hready = '1') then
          reg.state := store_req;
        end if;

      -- STORE REQUEST
      when store_req =>
        ahbmo.hbusreq <= '1';
        ahbmo.hlock   <= '1';
        ahbmo.htrans  <= HTRANS_NONSEQ;
        ahbmo.haddr(LINE_RANGE_HI downto LINE_RANGE_LO)   <= inv_fifo_data_out_addr;
        ahbmo.haddr(OFFSET_BITS - 1 downto 0) <= (others => '0');

        if (ahbmi.hready = '1') then
          inv_fifo_rdreq <= '1';
          if granted = '1' and inv_fifo_almost_empty = '0' then
            reg.state := store_req;
          else
            reg.state := store_rsp;
          end if;
        end if;

      -- STORE RESPONSE
      when store_rsp =>
        reg.state := idle;

    end case;

    ahbm_reg_next <= reg;

  end process fsm_ahbm;
  end generate ahb_inval_gen;
  end generate ahb_frontend_gen;

-------------------------------------------------------------------------------
-- FSM: Requests to NoC
-------------------------------------------------------------------------------
  fsm_req : process (req_reg, coherence_req_full,
                     req_out_valid, req_out_data_coh_msg, req_out_data_hprot,
                     req_out_data_addr, req_out_data_line,
                     req_out_data_word_mask, local_x, local_y) is

    variable reg    : req_reg_type;
    variable req_id : cache_id_t;
    variable mix_msg : mix_msg_t;

  begin  -- process fsm_cache2noc

    -- initialize variables
    reg         := req_reg;
    reg.asserts := (others => '0');
    req_id      := (others => '0');

    -- initialize signals toward cache (receive from cache)
    req_out_ready <= '0';

    -- initialize signals toward noc
    coherence_req_wrreq   <= '0';
    coherence_req_data_in <= (others => '0');


    case reg.state is

      -- SEND HEADER
      when send_header =>

        if coherence_req_full = '0' then

          req_out_ready <= '1';

          if req_out_valid = '1' then

            reg.coh_msg := req_out_data_coh_msg;
            reg.addr    := req_out_data_addr;
            reg.line    := req_out_data_line;

            coherence_req_wrreq <= '1';
            coherence_req_data_in <= make_header(req_out_data_coh_msg, mem_info,
                                                 mem_num, req_out_data_hprot,
                                                 req_out_data_addr, local_x, local_y,
                                                 '0', req_id,
                                                 cache_x, cache_y, req_out_data_word_mask);

            reg.state := send_addr;

          end if;
        end if;

      -- SEND ADDRESS
      when send_addr =>

        if coherence_req_full = '0' then

          coherence_req_wrreq <= '1';

          if USE_SPANDEX = 0 then
            -- Set ESP legacy coherence message types
            mix_msg := '1' & reg.coh_msg;
          else
            -- Use Spandex coherence message types
            mix_msg := '0' & reg.coh_msg;
          end if;

          case mix_msg is

            when REQ_PUTM | REQ_WB | REQ_WTdata | REQ_WT | REQ_WTfwd | REQ_AMO_ADD | REQ_AMO_AND | REQ_AMO_OR | REQ_AMO_XOR | REQ_AMO_MAX | REQ_AMO_MAXU | REQ_AMO_MIN | REQ_AMO_MINU =>

            coherence_req_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
            coherence_req_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state             := send_data;
            reg.word_cnt          := 0;

            when others =>

            coherence_req_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
            coherence_req_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state             := send_header;

          end case;
          end if;

      -- SEND DATA
      when send_data =>

        if coherence_req_full = '0' then

          coherence_req_wrreq <= '1';

          if reg.word_cnt = WORDS_PER_LINE - 1 then

            coherence_req_data_in <= PREAMBLE_TAIL & reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                                                              (BITS_PER_WORD * reg.word_cnt));

            reg.state := send_header;

          else

            coherence_req_data_in <= PREAMBLE_BODY & reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                                                              (BITS_PER_WORD * reg.word_cnt));

            reg.word_cnt := reg.word_cnt + 1;

          end if;

        end if;

    end case;

    req_reg_next <= reg;

  end process fsm_req;

-------------------------------------------------------------------------------
-- FSM: Responses to NoC
-------------------------------------------------------------------------------
  fsm_rsp_out : process (rsp_out_reg, coherence_rsp_snd_full,
                         rsp_out_valid, rsp_out_data_coh_msg, rsp_out_data_req_id,
                         rsp_out_data_to_req, rsp_out_data_addr, rsp_out_data_line,
                         rsp_out_data_word_mask, local_x, local_y) is

    variable reg   : rsp_out_reg_type;
    variable hprot : hprot_t := (others => '0');
    variable mix_msg : mix_msg_t;

  begin  -- process fsm_cache2noc

    -- initialize variables
    reg         := rsp_out_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (receive from cache)
    rsp_out_ready <= '0';

    -- initialize signals toward noc
    coherence_rsp_snd_wrreq   <= '0';
    coherence_rsp_snd_data_in <= (others => '0');


    case reg.state is

      -- SEND HEADER
      when send_header =>

        if coherence_rsp_snd_full = '0' then

          rsp_out_ready <= '1';

          if rsp_out_valid = '1' then

            reg.coh_msg := rsp_out_data_coh_msg;
            reg.addr    := rsp_out_data_addr;
            reg.line    := rsp_out_data_line;

            coherence_rsp_snd_wrreq <= '1';

            coherence_rsp_snd_data_in <= make_header(rsp_out_data_coh_msg, mem_info,
                                                     mem_num, hprot, rsp_out_data_addr, local_x,
                                                     local_y, rsp_out_data_to_req(0),
                                                     rsp_out_data_req_id,
                                                     cache_x, cache_y, rsp_out_data_word_mask);
            reg.state := send_addr;

          end if;
        end if;

      -- SEND ADDRESS
      when send_addr =>

        if coherence_rsp_snd_full = '0' then

          coherence_rsp_snd_wrreq <= '1';

          if USE_SPANDEX = 0 then
            -- Set ESP legacy coherence message types
            mix_msg := '1' & reg.coh_msg;
          else
            -- Use Spandex coherence message types
            mix_msg := '0' & reg.coh_msg;
          end if;

          case mix_msg is

            when RSP_DATA | RSP_S | RSP_Odata | RSP_RVK_O | RSP_WTdata | RSP_V =>

            coherence_rsp_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
            coherence_rsp_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state                 := send_data;
            reg.word_cnt              := 0;

            when others =>

            coherence_rsp_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
            coherence_rsp_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state                 := send_header;

          end case;
          end if;

      -- SEND DATA
      when send_data =>

        if coherence_rsp_snd_full = '0' then

          coherence_rsp_snd_wrreq <= '1';

          if reg.word_cnt = WORDS_PER_LINE - 1 then

            coherence_rsp_snd_data_in <=
              PREAMBLE_TAIL & reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1
                                       downto (BITS_PER_WORD * reg.word_cnt));

            reg.state := send_header;

          else

            coherence_rsp_snd_data_in <=
              PREAMBLE_BODY & reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1
                                       downto (BITS_PER_WORD * reg.word_cnt));

            reg.word_cnt := reg.word_cnt + 1;

          end if;

        end if;

    end case;

    rsp_out_reg_next <= reg;

  end process fsm_rsp_out;


-------------------------------------------------------------------------------
-- FSM: Forwards to NoC -- DCS hprot == DATA Only
-------------------------------------------------------------------------------
fsm_fwd_out : process (tile_id, fwd_out_reg, coherence_fwd_snd_full,
fwd_out_valid, fwd_out_data_coh_msg, fwd_out_data_req_id,
fwd_out_data_to_req, fwd_out_data_addr, fwd_out_data_line, fwd_out_data_word_mask,
local_x, local_y) is

variable reg   : fwd_out_reg_type;
variable hprot : hprot_t := (others => '0');
variable mix_msg : mix_msg_t;

begin  -- process fsm_cache2noc

  -- initialize variables
  reg         := fwd_out_reg;
  reg.asserts := (others => '0');

  -- initialize signals toward cache (receive from cache)
  fwd_out_ready <= '0';

  -- initialize signals toward noc
  coherence_fwd_snd_wrreq   <= '0';
  coherence_fwd_snd_data_in <= (others => '0');


  case reg.state is

    -- SEND HEADER
    when send_header =>

      if coherence_fwd_snd_full = '0' then

        fwd_out_ready <= '1';

        if fwd_out_valid = '1' then

          reg.coh_msg := fwd_out_data_coh_msg;
          reg.addr    := fwd_out_data_addr;
          reg.line    := fwd_out_data_line;

          coherence_fwd_snd_wrreq <= '1';

          coherence_fwd_snd_data_in <= make_dcs_header(fwd_out_data_coh_msg, mem_info,
                                      mem_num, hprot, fwd_out_data_addr, local_x,
                                      local_y, fwd_out_data_to_req(0),
                                      fwd_out_data_req_id, std_logic_vector(to_unsigned(tile_cache_id(tile_id), NL2_MAX_LOG2)),
                                      cache_x, cache_y, fwd_out_data_word_mask);
          reg.state := send_addr;

        end if;
      end if;

    -- SEND ADDRESS
    when send_addr =>

      if coherence_fwd_snd_full = '0' then

        coherence_fwd_snd_wrreq <= '1';
        mix_msg := '0' & reg.coh_msg;

        case mix_msg is

          when FWD_WTfwd =>

            coherence_fwd_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
            coherence_fwd_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state                 := send_data;
            reg.word_cnt              := 0;

          when others =>

            coherence_fwd_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
            coherence_fwd_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state                 := send_header;

        end case;


        -- always send data

        -- coherence_fwd_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
        -- coherence_fwd_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
        -- reg.state                 := send_data;
        -- reg.word_cnt              := 0;

        -- always not send data
        -- coherence_fwd_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
        -- coherence_fwd_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
        -- reg.state                 := send_header;


      end if;

    -- SEND DATA
    when send_data =>

      if coherence_fwd_snd_full = '0' then

        coherence_fwd_snd_wrreq <= '1';

      if reg.word_cnt = WORDS_PER_LINE - 1 then

        coherence_fwd_snd_data_in <=
        PREAMBLE_TAIL & reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1
                      downto (BITS_PER_WORD * reg.word_cnt));

        reg.state := send_header;

      else

        coherence_fwd_snd_data_in <=
        PREAMBLE_BODY & reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1
                      downto (BITS_PER_WORD * reg.word_cnt));

        reg.word_cnt := reg.word_cnt + 1;

      end if;

      end if;

  end case;

  fwd_out_reg_next <= reg;

end process fsm_fwd_out;

-----------------------------------------------------------------------------
-- FSM: Forwards from NoC
-----------------------------------------------------------------------------
  fsm_fwd_in : process (fwd_in_reg, fwd_in_ready,
                        coherence_fwd_empty, coherence_fwd_data_out) is

    variable reg          : fwd_in_reg_type;
    variable rsp_preamble : noc_preamble_type;
    variable msg_type     : noc_msg_type;
    variable word_mask    : word_mask_t;
    variable reserved     : reserved_field_type;

  begin  -- process fsm_fwd_in

    -- initialize variables
    reg         := fwd_in_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (send to cache)
    fwd_in_valid        <= '0';
    fwd_in_data_coh_msg <= (others => '0');
    fwd_in_data_addr    <= (others => '0');
    fwd_in_data_req_id  <= (others => '0');
    fwd_in_data_word_mask    <= (others => '0');
    fwd_in_data_line    <= (others => '0');

    -- initialize signals toward noc (receive from noc)
    coherence_fwd_rdreq <= '0';

    -- get preambles
    rsp_preamble := get_preamble(NOC_FLIT_SIZE, coherence_fwd_data_out);

    -- fsm states
    case reg.state is

      -- RECEIVE HEADER
      when rcv_header =>

        if coherence_fwd_empty = '0' then

          coherence_fwd_rdreq <= '1';

          msg_type    := get_msg_type(NOC_FLIT_SIZE, coherence_fwd_data_out);
          reg.coh_msg := msg_type(reg.coh_msg'length - 1 downto 0);
          reserved    := get_reserved_field(NOC_FLIT_SIZE, coherence_fwd_data_out);
          reg.req_id  := reserved(reg.req_id'length - 1 downto 0);
          reg.word_mask := reserved(RESERVED_WIDTH - 1 downto RESERVED_WIDTH - WORDS_PER_LINE);

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>
        if coherence_fwd_empty = '0' then

          case reg.coh_msg is
            when FWD_WTfwd =>

          coherence_fwd_rdreq <= '1';

              reg.addr     := coherence_fwd_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
              reg.word_cnt := 0;
              reg.state    := rcv_data;

            when others =>

              if fwd_in_ready = '1' then

          coherence_fwd_rdreq <= '1';

          fwd_in_valid        <= '1';
          fwd_in_data_coh_msg <= reg.coh_msg;
          fwd_in_data_addr    <= coherence_fwd_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
          fwd_in_data_req_id  <= reg.req_id;
                fwd_in_data_word_mask    <= reg.word_mask;

          reg.state := rcv_header;

        end if;
          end case;
        end if;

      when rcv_data =>
        if coherence_fwd_empty = '0' then
          if reg.word_cnt = WORDS_PER_LINE - 1 then
            if fwd_in_ready = '1' then
              coherence_fwd_rdreq <= '1';

              reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                      BITS_PER_WORD * reg.word_cnt)
                := coherence_fwd_data_out(BITS_PER_WORD - 1 downto 0);
          reg.state := rcv_header;

              fwd_in_valid        <= '1';
              fwd_in_data_coh_msg <= reg.coh_msg;
              fwd_in_data_addr    <= reg.addr;
              fwd_in_data_line    <= reg.line;
              fwd_in_data_req_id  <= reg.req_id;
              fwd_in_data_word_mask    <= reg.word_mask;
            end if;

          else
            coherence_fwd_rdreq <= '1';

            reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                    (BITS_PER_WORD * reg.word_cnt))
              := coherence_fwd_data_out(BITS_PER_WORD - 1 downto 0);

            reg.word_cnt := reg.word_cnt + 1;
          end if;
        end if;

    end case;

    fwd_in_reg_next <= reg;

  end process fsm_fwd_in;

-----------------------------------------------------------------------------
-- FSM: Responses from NoC
-----------------------------------------------------------------------------
  fsm_rsp_in : process (rsp_in_reg, rsp_in_ready,
                        coherence_rsp_rcv_empty, coherence_rsp_rcv_data_out) is

    variable reg          : rsp_in_reg_type;
    variable rsp_preamble : noc_preamble_type;
    variable msg_type     : noc_msg_type;
    variable word_mask    : word_mask_t;
    variable reserved     : reserved_field_type;
    variable mix_msg      : mix_msg_t;

  begin  -- process fsm_rsp_in

    -- initialize variables
    reg         := rsp_in_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (send to cache)
    rsp_in_valid           <= '0';
    rsp_in_data_coh_msg    <= (others => '0');
    rsp_in_data_addr       <= (others => '0');
    rsp_in_data_line       <= (others => '0');
    rsp_in_data_invack_cnt <= (others => '0');
    rsp_in_data_word_mask       <= (others => '0');

    -- initialize signals toward noc (receive from noc)
    coherence_rsp_rcv_rdreq <= '0';

    -- get preambles
    rsp_preamble := get_preamble(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);

    -- fsm states
    case reg.state is

      -- RECEIVE HEADER
      when rcv_header =>

        if coherence_rsp_rcv_empty = '0' then

          coherence_rsp_rcv_rdreq <= '1';

          msg_type       := get_msg_type(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);
          reg.coh_msg    := msg_type(reg.coh_msg'length - 1 downto 0);
          reserved       := get_reserved_field(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);
          reg.invack_cnt := reserved(reg.invack_cnt'length - 1 downto 0);
          reg.word_mask := reserved(RESERVED_WIDTH - 1 downto RESERVED_WIDTH - WORDS_PER_LINE);

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>
        if coherence_rsp_rcv_empty = '0' then

          if USE_SPANDEX = 0 then
            -- Set ESP legacy coherence message types
            mix_msg := '1' & reg.coh_msg;
          else
            -- Use Spandex coherence message types
            mix_msg := '0' & reg.coh_msg;
          end if;

          case mix_msg is

            when RSP_DATA | RSP_EDATA | RSP_S | RSP_Odata | RSP_RVK_O | RSP_WTdata | RSP_V =>

              coherence_rsp_rcv_rdreq <= '1';
              reg.addr                := coherence_rsp_rcv_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
              reg.word_cnt            := 0;
              reg.state               := rcv_data;

            when others =>

            if rsp_in_ready = '1' then
              -- RSP_INV_ACK

              coherence_rsp_rcv_rdreq <= '1';
              rsp_in_valid            <= '1';
              rsp_in_data_coh_msg     <= reg.coh_msg;
              rsp_in_data_addr        <= coherence_rsp_rcv_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
                rsp_in_data_word_mask   <= reg.word_mask;
              reg.state               := rcv_header;

            end if;

          end case;

          end if;

      -- RECEIVE DATA
      when rcv_data =>
        if coherence_rsp_rcv_empty = '0' then

          if reg.word_cnt = WORDS_PER_LINE - 1 then

            if rsp_in_ready = '1' then

              coherence_rsp_rcv_rdreq <= '1';

              reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                       BITS_PER_WORD * reg.word_cnt)
                := coherence_rsp_rcv_data_out(BITS_PER_WORD - 1 downto 0);

              reg.state := rcv_header;

              rsp_in_valid           <= '1';
              rsp_in_data_coh_msg    <= reg.coh_msg;
              rsp_in_data_invack_cnt <= reg.invack_cnt;
              rsp_in_data_addr       <= reg.addr;
              rsp_in_data_line       <= reg.line;
              rsp_in_data_word_mask  <= reg.word_mask;
            end if;

          else

            coherence_rsp_rcv_rdreq <= '1';

            reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                     (BITS_PER_WORD * reg.word_cnt))
              := coherence_rsp_rcv_data_out(BITS_PER_WORD - 1 downto 0);

            reg.word_cnt := reg.word_cnt + 1;

          end if;

        end if;

    end case;

    rsp_in_reg_next <= reg;

  end process fsm_rsp_in;



  axi_frontend_gen: if GLOB_CPU_AXI /= 0 generate

    -- Set unused outputs for AHB BUS
    ahbso.hready <= '0';
    unused_large_hrdata_gen: if ARCH_BITS > 32 generate
      ahbso.hrdata(ARCH_BITS - 1 downto 32) <= (others => '0');
    end generate unused_large_hrdata_gen;
    ahbso.hrdata(31 downto 0) <= x"dadecace";


-------------------------------------------------------------------------------
-- FSM: Bridge from AXI slave to L2 cache frontend input
-------------------------------------------------------------------------------
  fsm_axi : process (mosi, flush, ahbs_reg, axi_reg,
                     cpu_req_ready, flush_ready, flush_due,
                     rd_rsp_valid, rd_rsp_data_line, load_alloc_reg,
                     inv_fifo_full, bresp_valid, bresp_data)

    variable reg           : ahbs_reg_type;
    variable xreg          : axi_reg_type;
    variable alloc_reg     : load_alloc_reg_type;
    variable selected      : std_ulogic;
    variable valid_axi_req : std_ulogic;
    constant err_marker    : std_logic_vector(31 downto 0) := x"dadecace";

  begin
    -- copy current state into a variable
    reg         := ahbs_reg;
    xreg        := axi_reg;
    reg.asserts := (others => '0');
    alloc_reg   := load_alloc_reg;

    -- Default bus slave response
    -- aw
    somi.aw.ready <= '0';
    -- ar
    somi.ar.ready <= '0';
    -- w
    somi.w.ready <= '0';
    -- r
    somi.r.id    <= axi_reg.id;
    somi.r.resp  <= RBRESP_OKAY;
    somi.r.last  <= '0';
    somi.r.user  <= (others => '0');
    somi.r.valid <= '0';
    somi.r.data  <= ahbdrivedata(err_marker);
    -- b
    somi.b.id    <= axi_reg.id;
    somi.b.resp  <= RBRESP_OKAY;
    somi.b.user  <= (others => '0');
    somi.b.valid <= '0';

    -- Default cache request
    cpu_req_valid        <= '0';
    cpu_req_data_cpu_msg <= (others => '0');
    cpu_req_data_hsize   <= (others => '0');
    cpu_req_data_hprot   <= (others => '0');
    cpu_req_data_addr    <= (others => '0');
    cpu_req_data_dcs_en  <= '0';
    cpu_req_data_use_owner_pred <= '0';
    cpu_req_data_dcs     <= (others => '0');
    cpu_req_data_pred_cid<= (others => '0');
    cpu_req_data_word    <= (others => '0');
    cpu_req_data_amo     <= (others => '0');
    cpu_req_data_aq      <= '0';
    cpu_req_data_rl      <= '0';

    flush_valid <= '0';

    rd_rsp_ready <= '0';
    
    bresp_ready <= mosi.b.ready;

    -- check if memory is selected
    selected := mosi.aw.valid or mosi.ar.valid;
    valid_axi_req := selected;

    case ahbs_reg.state is

      -- IDLE
      when idle =>

        if valid_axi_req = '1' then
          if mosi.aw.valid = '0' then
            reg.cpu_msg := '0' & mosi.ar.lock;
            reg.hsize   := mosi.ar.size;
            reg.hprot   := '0' & not mosi.ar.prot(2);
            reg.haddr   := mosi.ar.addr;
            reg.dcs_en  := mosi.ar.user(7);
            reg.use_owner_pred := mosi.ar.user(6);
            reg.dcs     := mosi.ar.user(5 downto 4);
            reg.pred_cid:= mosi.ar.user(3 downto 0);
            xreg.id     := mosi.ar.id;
            xreg.len    := mosi.ar.len;
            xreg.lock   := mosi.ar.lock;
            xreg.cache  := mosi.ar.cache;
            if USE_SPANDEX /= 0 then
                xreg.atop   := (others => '0');
            else
                xreg.atop   := mosi.ar.user(5 downto 0);
            end if;
            xreg.aq     := '0';
            xreg.rl     := '0';

            somi.ar.ready <= '1';
          else
            reg.cpu_msg := '1' & mosi.aw.lock;
            reg.hsize   := mosi.aw.size;
            reg.hprot   := '0' & not mosi.aw.prot(2);
            reg.haddr   := mosi.aw.addr;
            reg.dcs_en  := mosi.aw.user(7);
            reg.use_owner_pred := mosi.aw.user(6);
            reg.dcs     := mosi.aw.user(5 downto 4);
            reg.pred_cid:= mosi.aw.user(3 downto 0);
            xreg.id     := mosi.aw.id;
            xreg.len    := mosi.aw.len;
            xreg.lock   := mosi.aw.lock;
            xreg.cache  := mosi.aw.cache;
            xreg.atop   := mosi.aw.atop;
            xreg.aq     := mosi.aw.user(9);
            xreg.rl     := mosi.aw.user(8);

            somi.aw.ready <= '1';
          end if;
        end if;

        if flush_due = '1' and xreg.lock = '0' then
          flush_valid <= '1';

          if valid_axi_req = '1' then

            if flush_ready = '0' then
              reg.state := flush_req;
            else
              reg.state := mem_req;
            end if;

          end if;

        elsif valid_axi_req = '1' then

          if mosi.aw.valid = '0' then

            cpu_req_valid  <= '1';
            alloc_reg.addr := reg.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);

            if cpu_req_ready = '1' then
              reg.state := load_rsp;
            else
              reg.state := load_req;
            end if;

          else

            reg.state := store_req;

          end if;
        end if;

        cpu_req_data_cpu_msg <= reg.cpu_msg;
        cpu_req_data_hsize   <= reg.hsize;
        cpu_req_data_hprot   <= reg.hprot;
        cpu_req_data_addr    <= reg.haddr;
        cpu_req_data_dcs_en  <= reg.dcs_en;
        cpu_req_data_use_owner_pred <= reg.use_owner_pred;
        cpu_req_data_dcs     <= reg.dcs;
        cpu_req_data_pred_cid<= reg.pred_cid;
        cpu_req_data_amo     <= xreg.atop;

      -- LOAD REQUEST
      when load_req =>
        cpu_req_data_cpu_msg <= reg.cpu_msg;
        cpu_req_data_hsize   <= reg.hsize;
        cpu_req_data_hprot   <= reg.hprot;
        cpu_req_data_addr    <= reg.haddr;
        cpu_req_data_dcs_en  <= reg.dcs_en;
        cpu_req_data_use_owner_pred <= reg.use_owner_pred;
        cpu_req_data_dcs     <= reg.dcs;
        cpu_req_data_pred_cid<= reg.pred_cid;
        cpu_req_data_amo     <= xreg.atop;
        cpu_req_valid <= '1';

        if cpu_req_ready = '1' then
          reg.state := load_rsp;
        end if;


      -- LOAD RESPONSE
      when load_rsp =>
        rd_rsp_ready <= mosi.r.ready;

        alloc_reg.line := rd_rsp_data_line;

        if rd_rsp_valid = '1' then
          somi.r.data <= read_from_line(reg.haddr, rd_rsp_data_line);
          somi.r.valid <= '1';
        end if;

        if rd_rsp_valid = '1' and mosi.r.ready = '1' then

          if xreg.len = axi_len_zero then
            somi.r.last <= '1';

            if valid_axi_req = '1' then
              if mosi.aw.valid = '0' then
                reg.cpu_msg := '0' & mosi.ar.lock;
                reg.hsize   := mosi.ar.size;
                reg.hprot   := '0' & not mosi.ar.prot(2);
                reg.haddr   := mosi.ar.addr;
                reg.dcs_en  := mosi.ar.user(7);
                reg.use_owner_pred := mosi.ar.user(6);
                reg.dcs     := mosi.ar.user(5 downto 4);
                reg.pred_cid:= mosi.ar.user(3 downto 0);
                xreg.id     := mosi.ar.id;
                xreg.len    := mosi.ar.len;
                xreg.lock   := mosi.ar.lock;
                xreg.cache  := mosi.ar.cache;
                if USE_SPANDEX /= 0 then
                    xreg.atop   := (others => '0');
                else
                    xreg.atop   := mosi.ar.user(5 downto 0);
                end if;
                xreg.aq     := '0';
                xreg.rl     := '0';

                somi.ar.ready <= '1';
              else
                reg.cpu_msg := '1' & mosi.aw.lock;
                reg.hsize   := mosi.aw.size;
                reg.hprot   := '0' & not mosi.aw.prot(2);
                reg.haddr   := mosi.aw.addr;
                reg.dcs_en  := mosi.aw.user(7);
                reg.use_owner_pred := mosi.aw.user(6);
                reg.dcs     := mosi.aw.user(5 downto 4);
                reg.pred_cid:= mosi.aw.user(3 downto 0);
                xreg.id     := mosi.aw.id;
                xreg.len    := mosi.aw.len;
                xreg.lock   := mosi.aw.lock;
                xreg.cache  := mosi.aw.cache;
                xreg.atop   := mosi.aw.atop;
                xreg.aq     := mosi.aw.user(9);
                xreg.rl     := mosi.aw.user(8);

                somi.aw.ready <= '1';
              end if;

            end if;

          else

            valid_axi_req := '1';

          end if;

          if flush_due = '1' and xreg.lock = '0' and
            not (reg.hprot(0) = '0' and valid_axi_req = '1') then

            flush_valid <= '1';

            if valid_axi_req = '1' then
              if flush_ready = '0' then
                reg.state := flush_req;
              else
                reg.state := mem_req;
              end if;
            else
              reg.state := idle;
            end if;

          elsif valid_axi_req = '1' then

            if mosi.aw.valid = '0' or xreg.len /= axi_len_zero then

              if load_alloc_reg.addr = reg.haddr(LINE_RANGE_HI downto LINE_RANGE_LO) then

                reg.state := load_alloc;

              else

                cpu_req_valid  <= '1';
                alloc_reg.addr := reg.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);

                if cpu_req_ready = '1' then
                  reg.state := load_rsp;
                else
                  reg.state := load_req;
                end if;
              end if;

            else

              reg.state := store_req;

            end if;

          else

            reg.state := idle;

          end if;

          if xreg.len /= axi_len_zero then
            reg.haddr := reg.haddr + addr_incr(reg.hsize);
            xreg.len := xreg.len - 1;
          end if;

        end if;


      -- LOAD_ALLOC
      -- TODO: invalidate load_alloc if invalidation is issued for the same
      -- cache line cached in the read buffer. (never happens on AHB w/ Leon3
      -- because L1 always reads a full line with HTRANS set to HTRANS_SEQ, so
      -- the bus arbiter won't allow the invalidation to go through becore the
      -- entire read buffer has been read.
      when load_alloc =>

        somi.r.data <= read_from_line(reg.haddr, load_alloc_reg.line);
        somi.r.valid <= '1';

        if mosi.r.ready = '1' then

          if xreg.len = axi_len_zero then
            somi.r.last <= '1';

            if valid_axi_req = '1' then
              if mosi.aw.valid = '0' then
                reg.cpu_msg := '0' & mosi.ar.lock;
                reg.hsize   := mosi.ar.size;
                reg.hprot   := '0' & not mosi.ar.prot(2);
                reg.haddr   := mosi.ar.addr;
                reg.dcs_en  := mosi.ar.user(7);
                reg.use_owner_pred := mosi.ar.user(6);
                reg.dcs     := mosi.ar.user(5 downto 4);
                reg.pred_cid:= mosi.ar.user(3 downto 0);
                xreg.id     := mosi.ar.id;
                xreg.len    := mosi.ar.len;
                xreg.lock   := mosi.ar.lock;
                xreg.cache  := mosi.ar.cache;
                if USE_SPANDEX /= 0 then
                    xreg.atop   := (others => '0');
                else
                    xreg.atop   := mosi.ar.user(5 downto 0);
                end if;
                xreg.aq     := '0';
                xreg.rl     := '0';

                somi.ar.ready <= '1';
              else
                reg.cpu_msg := '1' & mosi.aw.lock;
                reg.hsize   := mosi.aw.size;
                reg.hprot   := '0' & not mosi.aw.prot(2);
                reg.haddr   := mosi.aw.addr;
                reg.dcs_en  := mosi.aw.user(7);
                reg.use_owner_pred := mosi.aw.user(6);
                reg.dcs     := mosi.aw.user(5 downto 4);
                reg.pred_cid:= mosi.aw.user(3 downto 0);
                xreg.id     := mosi.aw.id;
                xreg.len    := mosi.aw.len;
                xreg.lock   := mosi.aw.lock;
                xreg.cache  := mosi.aw.cache;
                xreg.atop   := mosi.aw.atop;
                xreg.aq     := mosi.aw.user(9);
                xreg.rl     := mosi.aw.user(8);

                somi.aw.ready <= '1';
              end if;
            end if;

          else

            valid_axi_req := '1';

          end if;

          if flush_due = '1' and xreg.lock = '0' and
            not (reg.hprot(0) = '0' and valid_axi_req = '1') then

            flush_valid <= '1';

            if valid_axi_req = '1' then

              if flush_ready = '0' then
                reg.state := flush_req;
              else
                reg.state := mem_req;
              end if;

            else

              reg.state := idle;

            end if;

          elsif valid_axi_req = '1' then

            if mosi.aw.valid = '0' or xreg.len /= axi_len_zero then

              if load_alloc_reg.addr = reg.haddr(LINE_RANGE_HI downto LINE_RANGE_LO) then

                reg.state := load_alloc;

              else

                cpu_req_valid  <= '1';
                alloc_reg.addr := reg.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);

                if cpu_req_ready = '1' then
                  reg.state := load_rsp;
                else
                  reg.state := load_req;
                end if;
              end if;

            else

              reg.state := store_req;

            end if;

          else

            reg.state := idle;

          end if;

          if xreg.len /= axi_len_zero then
            reg.haddr := reg.haddr + addr_incr(reg.hsize);
            xreg.len := xreg.len - 1;
          end if;

        end if;


      -- STORE REQUEST
      when store_req =>

        somi.w.ready <= cpu_req_ready;

        if mosi.w.valid = '1' then

          if mosi.w.last = '1' then
            if reg.cpu_msg /= CPU_WRITE_ATOM then
              somi.b.valid <= '1';
            elsif (reg.cpu_msg = CPU_WRITE_ATOM and bresp_valid = '1') then
              somi.b.valid <= '1';
              if USE_SPANDEX = 0 then
                somi.b.resp <= bresp_data;
              else
                somi.b.resp <= RBRESP_EXOKAY;
              end if;
            end if;
          end if;

          cpu_req_data_cpu_msg <= reg.cpu_msg;
          cpu_req_data_hsize   <= reg.hsize;
          cpu_req_data_hprot   <= reg.hprot;
          cpu_req_data_addr    <= reg.haddr;
          cpu_req_data_dcs_en  <= reg.dcs_en;
          cpu_req_data_use_owner_pred <= reg.use_owner_pred;
          cpu_req_data_dcs     <= reg.dcs;
          cpu_req_data_pred_cid<= reg.pred_cid;
          cpu_req_data_word    <= mosi.w.data;
          cpu_req_data_amo     <= xreg.atop;
          cpu_req_data_aq      <= xreg.aq;
          cpu_req_data_rl      <= xreg.rl;
          cpu_req_valid <= '1';

          if cpu_req_ready = '1' then

            if valid_axi_req = '1' and mosi.w.last = '1' and mosi.b.ready = '1' and (reg.cpu_msg /= CPU_WRITE_ATOM or bresp_valid  = '1') then
              if valid_axi_req = '1' then
                if mosi.aw.valid = '0' then
                  reg.cpu_msg := '0' & mosi.ar.lock;
                  reg.hsize   := mosi.ar.size;
                  reg.hprot   := '0' & not mosi.ar.prot(2);
                  reg.haddr   := mosi.ar.addr;
                  reg.dcs_en  := mosi.ar.user(7);
                  reg.use_owner_pred := mosi.ar.user(6);
                  reg.dcs     := mosi.ar.user(5 downto 4);
                  reg.pred_cid:= mosi.ar.user(3 downto 0);
                  xreg.id     := mosi.ar.id;
                  xreg.len    := mosi.ar.len;
                  xreg.lock   := mosi.ar.lock;
                  xreg.cache  := mosi.ar.cache;
                  if USE_SPANDEX /= 0 then
                    xreg.atop   := (others => '0');
                  else
                    xreg.atop   := mosi.ar.user(5 downto 0);
                  end if;
                  xreg.aq     := '0';
                  xreg.rl     := '0';

                  somi.ar.ready <= '1';
                else
                  reg.cpu_msg := '1' & mosi.aw.lock;
                  reg.hsize   := mosi.aw.size;
                  reg.hprot   := '0' & not mosi.aw.prot(2);
                  reg.haddr   := mosi.aw.addr;
                  reg.dcs_en  := mosi.aw.user(7);
                  reg.use_owner_pred := mosi.aw.user(6);
                  reg.dcs     := mosi.aw.user(5 downto 4);
                  reg.pred_cid:= mosi.aw.user(3 downto 0);
                  xreg.id     := mosi.aw.id;
                  xreg.len    := mosi.aw.len;
                  xreg.lock   := mosi.aw.lock;
                  xreg.cache  := mosi.aw.cache;
                  xreg.atop   := mosi.aw.atop;
                  xreg.aq     := mosi.aw.user(9);
                  xreg.rl     := mosi.aw.user(8);

                  somi.aw.ready <= '1';
                end if;
              end if;

            end if;

            if mosi.w.last = '1' then

              if mosi.b.ready = '0' or (reg.cpu_msg = CPU_WRITE_ATOM and bresp_valid = '0') then
                reg.state := send_wr_ack;

              elsif flush_due = '1' and xreg.lock = '0' and
                not (reg.hprot(0) = '0' and valid_axi_req = '1') then

                flush_valid <= '1';

                if valid_axi_req = '1' then
                  if flush_ready = '0' then
                    reg.state := flush_req;
                  else
                    reg.state := mem_req;
                  end if;
                else
                  reg.state := idle;
                end if;

              elsif valid_axi_req = '1' then

                if mosi.ar.valid = '1' then

                  alloc_reg.addr := reg.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);
                  reg.state      := load_req;

                else

                  reg.state := store_req;

                end if;

              else

                reg.state := idle;

              end if;

            else                        -- mosi.w.last = '0'
              reg.haddr := reg.haddr + addr_incr(reg.hsize);
              xreg.len := xreg.len - 1;
            end if;

          end if;

        end if;

      -- STORE ACK
      when send_wr_ack =>
        if reg.cpu_msg /= CPU_WRITE_ATOM or bresp_valid = '1' then
            somi.b.valid <= '1';
        end if;

        if reg.cpu_msg = CPU_WRITE_ATOM then
            somi.b.resp <= bresp_data;
        end if;
        
        if mosi.b.ready = '1' and (reg.cpu_msg /= CPU_WRITE_ATOM or bresp_valid = '1') then
        
          if unsigned(xreg.atop) > 0 and USE_SPANDEX /= 0 then
            reg.state := load_rsp;
          else

          if valid_axi_req = '1' then
            if mosi.aw.valid = '0' then
              reg.cpu_msg := '0' & mosi.ar.lock;
              reg.hsize   := mosi.ar.size;
              reg.hprot   := '0' & not mosi.ar.prot(2);
              reg.haddr   := mosi.ar.addr;
              reg.dcs_en  := mosi.ar.user(7);
              reg.use_owner_pred := mosi.ar.user(6);
              reg.dcs     := mosi.ar.user(5 downto 4);
              reg.pred_cid:= mosi.ar.user(3 downto 0);
              xreg.id     := mosi.ar.id;
              xreg.len    := mosi.ar.len;
              xreg.lock   := mosi.ar.lock;
              xreg.cache  := mosi.ar.cache;
              if USE_SPANDEX /= 0 then
                xreg.atop   := (others => '0');
              else
                xreg.atop   := mosi.ar.user(5 downto 0);
              end if;
              xreg.aq     := '0';
              xreg.rl     := '0';

              somi.ar.ready <= '1';
            else
              reg.cpu_msg := '1' & mosi.aw.lock;
              reg.hsize   := mosi.aw.size;
              reg.hprot   := '0' & not mosi.aw.prot(2);
              reg.haddr   := mosi.aw.addr;
              reg.dcs_en  := mosi.aw.user(7);
              reg.use_owner_pred := mosi.aw.user(6);
              reg.dcs     := mosi.aw.user(5 downto 4);
              reg.pred_cid:= mosi.aw.user(3 downto 0);
              xreg.id     := mosi.aw.id;
              xreg.len    := mosi.aw.len;
              xreg.lock   := mosi.aw.lock;
              xreg.cache  := mosi.aw.cache;
              xreg.atop   := mosi.aw.atop;
              xreg.aq     := mosi.aw.user(9);
              xreg.rl     := mosi.aw.user(8);

              somi.aw.ready <= '1';
            end if;
          end if;

          if flush_due = '1' and xreg.lock = '0' then
            flush_valid <= '1';

            if valid_axi_req = '1' then

              if flush_ready = '0' then
                reg.state := flush_req;
              else
                reg.state := mem_req;
              end if;

            end if;

          elsif valid_axi_req = '1' then

            if mosi.aw.valid = '0' then

              cpu_req_valid  <= '1';
              alloc_reg.addr := reg.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);

              if cpu_req_ready = '1' then
                reg.state := load_rsp;
              else
                reg.state := load_req;
              end if;

            else

              reg.state := store_req;

            end if;
          else
            reg.state := idle;
        
          end if;

          cpu_req_data_cpu_msg <= reg.cpu_msg;
          cpu_req_data_hsize   <= reg.hsize;
          cpu_req_data_hprot   <= reg.hprot;
          cpu_req_data_addr    <= reg.haddr;
          cpu_req_data_dcs_en  <= reg.dcs_en;
          cpu_req_data_use_owner_pred <= reg.use_owner_pred;
          cpu_req_data_dcs     <= reg.dcs;
          cpu_req_data_pred_cid<= reg.pred_cid;
          cpu_req_data_amo     <= xreg.atop;

          end if;

        end if;

      -- FLUSH REQUEST
      when flush_req =>

        flush_valid <= '1';

        if flush_ready = '1' then
          reg.state := mem_req;
        end if;


      -- MEMORIZED REQUEST
      when mem_req =>

        if reg.cpu_msg = CPU_READ or reg.cpu_msg = CPU_READ_ATOM then
          alloc_reg.addr := reg.haddr(LINE_RANGE_HI downto LINE_RANGE_LO);
          reg.state      := load_req;
        else
          reg.state := store_req;
        end if;

    end case;

    axi_reg_next        <= xreg;
    ahbs_reg_next       <= reg;
    load_alloc_reg_next <= alloc_reg;

  end process fsm_axi;

  -- forward invalidate from the L2 cache to L1
  inval_ready            <= inval_valid when inv_fifo_full = '0' else '0';
  inv_fifo_wrreq         <= inval_valid when inv_fifo_full = '0' else '0';
  inv_fifo_data_in_addr  <= inval_data_addr;
  inv_fifo_data_in_hprot <= inval_data_hprot;
  inv_fifo_rdreq         <= ace_resp.ac.ready when inv_fifo_empty = '0' else '0';

  ace_req.ac.addr  <= inv_fifo_data_out_addr & empty_offset;
  ace_req.ac.prot  <= (not inv_fifo_data_out_hprot(0)) & "01";
  ace_req.ac.snoop <= XSNOOP_MAKEINVALID;
  ace_req.ac.valid <= not inv_fifo_empty;

  -- Disable AHB outputs
  ahbmo.hbusreq    <= '0';
  ahbmo.htrans     <=  HTRANS_IDLE;
  ahbmo.hlock      <= '0';
  ahbmo.haddr      <= (others => '0');

  end generate axi_frontend_gen;


-------------------------------------------------------------------------------
-- Debug
-------------------------------------------------------------------------------

  ahbs_reg_state   <= ahbs_reg.state;
  ahbm_reg_state   <= ahbm_reg.state;
  req_reg_state    <= req_reg.state;
  rsp_in_reg_state <= rsp_in_reg.state;

  --ahbs_asserts   <= ahbs_reg.asserts;
  --ahbm_asserts   <= ahbm_reg.asserts;
  --req_asserts    <= req_reg.asserts;
  --rsp_in_asserts <= rsp_in_reg.asserts;

  --led_wrapper_asserts <= or_reduce(ahbs_reg.asserts) or or_reduce(ahbm_reg.asserts) or
  --                       or_reduce(req_reg.asserts) or or_reduce(rsp_in_reg.asserts);

end rtl;
