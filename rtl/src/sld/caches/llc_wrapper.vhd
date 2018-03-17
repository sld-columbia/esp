-------------------------------------------------------------------------------
-- Entity: llc_wrapper
-- File: llc_wrapper.vhd
-- Author: Davide Giri - SLD @ Columbia University
-- Description: RTL wrapper for a Last Level Cache (LLC) with directory
-- to be included on a memory tile on an Embedded Scalable Platform.
-- Frontend: Network on Chip to LLC cache wrapper.
-- Backend: LLC cache wrapper to Amba 2.0 AHB.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.socmap_types.all;
use work.nocpackage.all;
use work.cachepackage.all;              -- contains llc cache component


entity llc_wrapper is
  generic (
    tech        : integer                      := virtex7;
    ncpu        : integer                      := 4;
    noc_xlen    : integer                      := 3;
    hindex      : integer range 0 to NAHBSLV-1 := 4;
    local_y     : local_yx;
    local_x     : local_yx;
    cacheline   : integer;
    l2_cache_en : integer                      := 0;
    cpu_tile_id : cpu_info_array;
    tile_cpu_id : tile_cpu_id_array;
    destination : integer                      := 0);  -- 0: mem
  -- 1: DSU
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;

    -- NoC1->tile
    coherence_req_rdreq        : out std_ulogic;
    coherence_req_data_out     : in  noc_flit_type;
    coherence_req_empty        : in  std_ulogic;
    -- tile->NoC2
    coherence_fwd_wrreq        : out std_ulogic;
    coherence_fwd_data_in      : out noc_flit_type;
    coherence_fwd_full         : in  std_ulogic;
    -- tile->NoC3
    coherence_rsp_snd_wrreq    : out std_ulogic;
    coherence_rsp_snd_data_in  : out noc_flit_type;
    coherence_rsp_snd_full     : in  std_ulogic;
    -- NoC3->tile
    coherence_rsp_rcv_rdreq    : out std_ulogic;
    coherence_rsp_rcv_data_out : in  noc_flit_type;
    coherence_rsp_rcv_empty    : in  std_ulogic;
    -- -- NoC4->tile
    -- dma_rcv_rdreq                       : out std_ulogic;
    -- dma_rcv_data_out                    : in  noc_flit_type;
    -- dma_rcv_empty                       : in  std_ulogic;
    -- -- tile->NoC4
    -- dma_snd_wrreq                       : out std_ulogic;
    -- dma_snd_data_in                     : out noc_flit_type;
    -- dma_snd_full                        : in  std_ulogic;
    -- dma_snd_atleast_4slots              : in  std_ulogic;
    -- dma_snd_exactly_3slots              : in  std_ulogic);

    debug_led : out std_ulogic);

end llc_wrapper;

architecture rtl of llc_wrapper is

  -- Interface with LLC cache

  -- NoC to cache
  signal llc_req_in_ready        : std_ulogic;
  signal llc_req_in_valid        : std_ulogic;
  signal llc_req_in_data_coh_msg : coh_msg_t;
  signal llc_req_in_data_hprot   : hprot_t;
  signal llc_req_in_data_addr    : line_addr_t;
  signal llc_req_in_data_line    : line_t;
  signal llc_req_in_data_req_id  : cache_id_t;

  signal llc_rsp_in_ready       : std_ulogic;
  signal llc_rsp_in_valid       : std_ulogic;
  signal llc_rsp_in_data_addr   : line_addr_t;
  signal llc_rsp_in_data_line   : line_t;
  signal llc_rsp_in_data_req_id : cache_id_t;

  -- cache to NoC
  signal llc_rsp_out_ready           : std_ulogic;
  signal llc_rsp_out_valid           : std_ulogic;
  signal llc_rsp_out_data_coh_msg    : coh_msg_t;
  signal llc_rsp_out_data_addr       : line_addr_t;
  signal llc_rsp_out_data_line       : line_t;
  signal llc_rsp_out_data_invack_cnt : invack_cnt_t;
  signal llc_rsp_out_data_req_id     : cache_id_t;
  signal llc_rsp_out_data_dest_id    : cache_id_t;

  signal llc_fwd_out_ready        : std_ulogic;
  signal llc_fwd_out_valid        : std_ulogic;
  signal llc_fwd_out_data_coh_msg : coh_msg_t;
  signal llc_fwd_out_data_addr    : line_addr_t;
  signal llc_fwd_out_data_req_id  : cache_id_t;
  signal llc_fwd_out_data_dest_id : cache_id_t;

  -- AHB to cache
  signal llc_mem_rsp_ready     : std_ulogic;
  signal llc_mem_rsp_valid     : std_ulogic;
  signal llc_mem_rsp_data_line : line_t;

  -- cache to AHB
  signal llc_mem_req_ready       : std_ulogic;
  signal llc_mem_req_valid       : std_ulogic;
  signal llc_mem_req_data_hwrite : std_ulogic;
  signal llc_mem_req_data_hsize  : hsize_t;
  signal llc_mem_req_data_hprot  : hprot_t;
  signal llc_mem_req_data_addr   : line_addr_t;
  signal llc_mem_req_data_line   : line_t;

  -- debug
  --signal asserts    : llc_asserts_t;
  --signal bookmark   : llc_bookmark_t;
  --signal custom_dbg : custom_dbg_t;

  --signal led_wrapper_asserts : std_ulogic;

  constant ncpu_bits : integer := log2(ncpu);
  subtype sharers_t is std_logic_vector(ncpu - 1 downto 0);
  subtype owner_t is std_logic_vector(get_owner_bits(ncpu_bits) - 1 downto 0);
  
  --signal tag_hit_out : std_ulogic;
  --signal hit_way_out : std_logic_vector(ncpu_bits + 2 downto 0);
  --signal empty_way_found_out : std_ulogic;
  --signal empty_way_out : std_logic_vector(ncpu_bits + 2 downto 0);
  --signal evict_out : std_ulogic;
  --signal way_out : std_logic_vector(ncpu_bits + 2 downto 0);
  --signal llc_addr_out : std_logic_vector(ncpu_bits + 10 downto 0);
  --signal req_stall_out : std_ulogic;
  --signal req_in_stalled_valid_out : std_ulogic;
  --signal req_in_stalled_out_coh_msg : std_logic_vector(1 downto 0);
  --signal req_in_stalled_out_hprot : hprot_t;
  --signal req_in_stalled_out_addr : std_logic_vector(31 downto 0);
  --signal req_in_stalled_out_line : std_logic_vector(127 downto 0);
  --signal req_in_stalled_out_req_id : std_logic_vector(1 downto 0);
  --signal is_rsp_to_get_out : std_ulogic;
  --signal is_req_to_get_out : std_ulogic;
  --signal tag_buf_out_0 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_1 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_2 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_3 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_4 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_5 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_6 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_7 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_8 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_9 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_10 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_11 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_12 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_13 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_14 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_15 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_16 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_17 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_18 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_19 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_20 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_21 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_22 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_23 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_24 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_25 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_26 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_27 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_28 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_29 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_30 : std_logic_vector(19 downto 0);
  --signal tag_buf_out_31 : std_logic_vector(19 downto 0);
  --signal state_buf_out_0 : std_logic_vector(2 downto 0);
  --signal state_buf_out_1 : std_logic_vector(2 downto 0);
  --signal state_buf_out_2 : std_logic_vector(2 downto 0);
  --signal state_buf_out_3 : std_logic_vector(2 downto 0);
  --signal state_buf_out_4 : std_logic_vector(2 downto 0);
  --signal state_buf_out_5 : std_logic_vector(2 downto 0);
  --signal state_buf_out_6 : std_logic_vector(2 downto 0);
  --signal state_buf_out_7 : std_logic_vector(2 downto 0);
  --signal state_buf_out_8 : std_logic_vector(2 downto 0);
  --signal state_buf_out_9 : std_logic_vector(2 downto 0);
  --signal state_buf_out_10 : std_logic_vector(2 downto 0);
  --signal state_buf_out_11 : std_logic_vector(2 downto 0);
  --signal state_buf_out_12 : std_logic_vector(2 downto 0);
  --signal state_buf_out_13 : std_logic_vector(2 downto 0);
  --signal state_buf_out_14 : std_logic_vector(2 downto 0);
  --signal state_buf_out_15 : std_logic_vector(2 downto 0);
  --signal state_buf_out_16 : std_logic_vector(2 downto 0);
  --signal state_buf_out_17 : std_logic_vector(2 downto 0);
  --signal state_buf_out_18 : std_logic_vector(2 downto 0);
  --signal state_buf_out_19 : std_logic_vector(2 downto 0);
  --signal state_buf_out_20 : std_logic_vector(2 downto 0);
  --signal state_buf_out_21 : std_logic_vector(2 downto 0);
  --signal state_buf_out_22 : std_logic_vector(2 downto 0);
  --signal state_buf_out_23 : std_logic_vector(2 downto 0);
  --signal state_buf_out_24 : std_logic_vector(2 downto 0);
  --signal state_buf_out_25 : std_logic_vector(2 downto 0);
  --signal state_buf_out_26 : std_logic_vector(2 downto 0);
  --signal state_buf_out_27 : std_logic_vector(2 downto 0);
  --signal state_buf_out_28 : std_logic_vector(2 downto 0);
  --signal state_buf_out_29 : std_logic_vector(2 downto 0);
  --signal state_buf_out_30 : std_logic_vector(2 downto 0);
  --signal state_buf_out_31 : std_logic_vector(2 downto 0);
  --signal sharers_buf_out_0 : sharers_t;
  --signal sharers_buf_out_1 : sharers_t;
  --signal sharers_buf_out_2 : sharers_t;
  --signal sharers_buf_out_3 : sharers_t;
  --signal sharers_buf_out_4 : sharers_t;
  --signal sharers_buf_out_5 : sharers_t;
  --signal sharers_buf_out_6 : sharers_t;
  --signal sharers_buf_out_7 : sharers_t;
  --signal sharers_buf_out_8 : sharers_t;
  --signal sharers_buf_out_9 : sharers_t;
  --signal sharers_buf_out_10 : sharers_t;
  --signal sharers_buf_out_11 : sharers_t;
  --signal sharers_buf_out_12 : sharers_t;
  --signal sharers_buf_out_13 : sharers_t;
  --signal sharers_buf_out_14 : sharers_t;
  --signal sharers_buf_out_15 : sharers_t;
  --signal sharers_buf_out_16 : sharers_t;
  --signal sharers_buf_out_17 : sharers_t;
  --signal sharers_buf_out_18 : sharers_t;
  --signal sharers_buf_out_19 : sharers_t;
  --signal sharers_buf_out_20 : sharers_t;
  --signal sharers_buf_out_21 : sharers_t;
  --signal sharers_buf_out_22 : sharers_t;
  --signal sharers_buf_out_23 : sharers_t;
  --signal sharers_buf_out_24 : sharers_t;
  --signal sharers_buf_out_25 : sharers_t;
  --signal sharers_buf_out_26 : sharers_t;
  --signal sharers_buf_out_27 : sharers_t;
  --signal sharers_buf_out_28 : sharers_t;
  --signal sharers_buf_out_29 : sharers_t;
  --signal sharers_buf_out_30 : sharers_t;
  --signal sharers_buf_out_31 : sharers_t;
  --signal owner_buf_out_0 : owner_t;
  --signal owner_buf_out_1 : owner_t;
  --signal owner_buf_out_2 : owner_t;
  --signal owner_buf_out_3 : owner_t;
  --signal owner_buf_out_4 : owner_t;
  --signal owner_buf_out_5 : owner_t;
  --signal owner_buf_out_6 : owner_t;
  --signal owner_buf_out_7 : owner_t;
  --signal owner_buf_out_8 : owner_t;
  --signal owner_buf_out_9 : owner_t;
  --signal owner_buf_out_10 : owner_t;
  --signal owner_buf_out_11 : owner_t;
  --signal owner_buf_out_12 : owner_t;
  --signal owner_buf_out_13 : owner_t;
  --signal owner_buf_out_14 : owner_t;
  --signal owner_buf_out_15 : owner_t;
  --signal owner_buf_out_16 : owner_t;
  --signal owner_buf_out_17 : owner_t;
  --signal owner_buf_out_18 : owner_t;
  --signal owner_buf_out_19 : owner_t;
  --signal owner_buf_out_20 : owner_t;
  --signal owner_buf_out_21 : owner_t;
  --signal owner_buf_out_22 : owner_t;
  --signal owner_buf_out_23 : owner_t;
  --signal owner_buf_out_24 : owner_t;
  --signal owner_buf_out_25 : owner_t;
  --signal owner_buf_out_26 : owner_t;
  --signal owner_buf_out_27 : owner_t;
  --signal owner_buf_out_28 : owner_t;
  --signal owner_buf_out_29 : owner_t;
  --signal owner_buf_out_30 : owner_t;
  --signal owner_buf_out_31 : owner_t;
  
-----------------------------------------------------------------------------
-- AHB master FSM signals
-----------------------------------------------------------------------------
  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_SLD, SLD_L3_CACHE, 0, 0, 0),
    others => zero32);

  type ahbm_fsm is (idle, grant_wait, load_line, send_mem_rsp, store_line);

  type ahbm_reg_type is record
    state    : ahbm_fsm;
    hwrite   : std_ulogic;
    haddr    : addr_t;
    hprot    : hprot_t;
    line     : line_t;
    word_cnt : integer;
    asserts  : asserts_llc_ahbm_t;
  end record;

  constant AHBM_REG_DEFAULT : ahbm_reg_type := (
    state    => idle,
    hwrite   => '0',
    haddr    => (others => '0'),
    hprot    => (others => '0'),
    line     => (others => '0'),
    word_cnt => 0,
    asserts  => (others => '0')
    );

  signal ahbm_reg      : ahbm_reg_type := AHBM_REG_DEFAULT;
  signal ahbm_reg_next : ahbm_reg_type := AHBM_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: Forward to NoC
  -------------------------------------------------------------------------------
  type fwd_out_fsm is (send_header, send_addr);

  type fwd_out_reg_type is record
    state   : fwd_out_fsm;
    addr    : line_addr_t;
    asserts : asserts_fwd_t;
  end record fwd_out_reg_type;

  constant FWD_OUT_REG_DEFAULT : fwd_out_reg_type := (
    state   => send_header,
    addr    => (others => '0'),
    asserts => (others => '0'));

  signal fwd_out_reg      : fwd_out_reg_type := FWD_OUT_REG_DEFAULT;
  signal fwd_out_reg_next : fwd_out_reg_type := FWD_OUT_REG_DEFAULT;

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

  signal rsp_out_reg      : rsp_out_reg_type := RSP_OUT_REG_DEFAULT;
  signal rsp_out_reg_next : rsp_out_reg_type := RSP_OUT_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: Request from NoC
  -------------------------------------------------------------------------------
  type req_in_fsm is (rcv_header, rcv_addr, rcv_data);

  type req_in_reg_type is record
    state    : req_in_fsm;
    coh_msg  : coh_msg_t;
    hprot    : hprot_t;
    addr     : line_addr_t;
    line     : line_t;
    req_id   : cache_id_t;
    word_cnt : natural range 0 to 3;
    origin_x : local_yx;
    origin_y : local_yx;
    tile_id  : integer;
    asserts  : asserts_req_t;
  end record req_in_reg_type;

  constant REQ_IN_REG_DEFAULT : req_in_reg_type := (
    state    => rcv_header,
    coh_msg  => (others => '0'),
    hprot    => (others => '0'),
    addr     => (others => '0'),
    line     => (others => '0'),
    req_id   => (others => '0'),
    word_cnt => 0,
    origin_x => (others => '0'),
    origin_y => (others => '0'),
    tile_id  => 0,
    asserts  => (others => '0'));

  signal req_in_reg      : req_in_reg_type := REQ_IN_REG_DEFAULT;
  signal req_in_reg_next : req_in_reg_type := REQ_IN_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: Response from NoC
  -------------------------------------------------------------------------------
  type rsp_in_fsm is (rcv_header, rcv_addr, rcv_data);

  type rsp_in_reg_type is record
    state    : rsp_in_fsm;
    addr     : line_addr_t;
    line     : line_t;
    req_id   : cache_id_t;
    word_cnt : natural range 0 to 3;
    origin_x : local_yx;
    origin_y : local_yx;
    tile_id  : integer;
    asserts  : asserts_rsp_in_t;
  end record rsp_in_reg_type;

  constant RSP_IN_REG_DEFAULT : rsp_in_reg_type := (
    state    => rcv_header,
    addr     => (others => '0'),
    line     => (others => '0'),
    req_id   => (others => '0'),
    word_cnt => 0,
    origin_x => (others => '0'),
    origin_y => (others => '0'),
    tile_id  => 0,
    asserts  => (others => '0'));

  signal rsp_in_reg      : rsp_in_reg_type := RSP_IN_REG_DEFAULT;
  signal rsp_in_reg_next : rsp_in_reg_type := RSP_IN_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- Others
  -------------------------------------------------------------------------------
       
  signal empty_offset : std_logic_vector(OFFSET_BITS - 1 downto 0) := (others => '0');
 
  -------------------------------------------------------------------------------
  -- Debug
  -------------------------------------------------------------------------------
       
  signal ahbm_asserts : asserts_llc_ahbm_t;

  attribute mark_debug : string;

  attribute mark_debug of llc_req_in_ready        : signal is "true";
  attribute mark_debug of llc_req_in_valid        : signal is "true";
  attribute mark_debug of llc_req_in_data_coh_msg : signal is "true";
  attribute mark_debug of llc_req_in_data_hprot   : signal is "true";
  attribute mark_debug of llc_req_in_data_addr    : signal is "true";
  -- attribute mark_debug of llc_req_in_data_line    : signal is "true";
  attribute mark_debug of llc_req_in_data_req_id  : signal is "true";

  attribute mark_debug of llc_rsp_in_ready       : signal is "true";
  attribute mark_debug of llc_rsp_in_valid       : signal is "true";
  attribute mark_debug of llc_rsp_in_data_addr   : signal is "true";
  -- attribute mark_debug of llc_rsp_in_data_line   : signal is "true";
  attribute mark_debug of llc_rsp_in_data_req_id : signal is "true";

  attribute mark_debug of llc_rsp_out_ready           : signal is "true";
  attribute mark_debug of llc_rsp_out_valid           : signal is "true";
  attribute mark_debug of llc_rsp_out_data_coh_msg    : signal is "true";
  attribute mark_debug of llc_rsp_out_data_addr       : signal is "true";
  -- attribute mark_debug of llc_rsp_out_data_line       : signal is "true";
  attribute mark_debug of llc_rsp_out_data_invack_cnt : signal is "true";
  attribute mark_debug of llc_rsp_out_data_req_id     : signal is "true";
  attribute mark_debug of llc_rsp_out_data_dest_id    : signal is "true";

  attribute mark_debug of llc_fwd_out_ready        : signal is "true";
  attribute mark_debug of llc_fwd_out_valid        : signal is "true";
  attribute mark_debug of llc_fwd_out_data_coh_msg : signal is "true";
  attribute mark_debug of llc_fwd_out_data_addr    : signal is "true";
  attribute mark_debug of llc_fwd_out_data_req_id  : signal is "true";
  attribute mark_debug of llc_fwd_out_data_dest_id : signal is "true";

  attribute mark_debug of llc_mem_rsp_ready     : signal is "true";
  attribute mark_debug of llc_mem_rsp_valid     : signal is "true";
  -- attribute mark_debug of llc_mem_rsp_data_line : signal is "true";

  attribute mark_debug of llc_mem_req_ready       : signal is "true";
  attribute mark_debug of llc_mem_req_valid       : signal is "true";
  attribute mark_debug of llc_mem_req_data_hwrite : signal is "true";
  attribute mark_debug of llc_mem_req_data_hsize  : signal is "true";
  attribute mark_debug of llc_mem_req_data_hprot  : signal is "true";
  attribute mark_debug of llc_mem_req_data_addr   : signal is "true";
  attribute mark_debug of llc_mem_req_data_line   : signal is "true";

  --attribute mark_debug of asserts    : signal is "true";
  --attribute mark_debug of bookmark   : signal is "true";
  --attribute mark_debug of custom_dbg : signal is "true";

  attribute mark_debug of ahbm_asserts : signal is "true";

begin  -- architecture rtl
-------------------------------------------------------------------------------
-- Static outputs: AHB master, NoC
-------------------------------------------------------------------------------

  ahbmo.hsize   <= HSIZE_WORD;
  ahbmo.hlock   <= '0';
  ahbmo.hirq    <= (others => '0');
  ahbmo.hconfig <= hconfig;
  ahbmo.hindex  <= hindex;
  ahbmo.hburst  <= HBURST_INCR;

-------------------------------------------------------------------------------
-- State update for all the FSMs
-------------------------------------------------------------------------------
  fsms_state_update : process (clk, rst)
  begin
    if rst = '0' then
      ahbm_reg    <= AHBM_REG_DEFAULT;
      req_in_reg  <= REQ_IN_REG_DEFAULT;
      rsp_in_reg  <= RSP_IN_REG_DEFAULT;
      fwd_out_reg <= FWD_OUT_REG_DEFAULT;
      rsp_out_reg <= RSP_OUT_REG_DEFAULT;
    elsif clk'event and clk = '1' then
      ahbm_reg    <= ahbm_reg_next;
      req_in_reg  <= req_in_reg_next;
      rsp_in_reg  <= rsp_in_reg_next;
      fwd_out_reg <= fwd_out_reg_next;
      rsp_out_reg <= rsp_out_reg_next;
    end if;
  end process fsms_state_update;

-------------------------------------------------------------------------------
-- FSM: Bridge from LLC cache to AHB bus
-------------------------------------------------------------------------------
  fsm_ahbm : process (ahbm_reg, ahbmi,
                      llc_mem_req_valid, llc_mem_req_data_hwrite,
                      llc_mem_req_data_hprot, llc_mem_req_data_addr,
                      llc_mem_req_data_line, llc_mem_rsp_ready) is

    variable reg     : ahbm_reg_type;
    variable granted : std_ulogic;

  begin  -- process fsm_ahbm

    -- save current state into a variable
    reg         := ahbm_reg;
    reg.asserts := (others => '0');

    -- default values for output signals
    llc_mem_req_ready     <= '0';
    llc_mem_rsp_valid     <= '0';
    llc_mem_rsp_data_line <= (others => '0');

    ahbmo.hbusreq <= '0';
    ahbmo.htrans  <= HTRANS_IDLE;
    ahbmo.hwrite  <= '0';
    ahbmo.haddr   <= (others => '0');
    ahbmo.hprot   <= "1100";
    ahbmo.hwdata  <= (others => '0');

    -- check if the bus has been granted
    granted := ahbmi.hgrant(hindex);

    -- select next state and set outputs
    case ahbm_reg.state is

      -- IDLE
      when idle =>
        llc_mem_req_ready <= '1';

        if llc_mem_req_valid = '1' then
          reg.hwrite   := llc_mem_req_data_hwrite;
          reg.hprot    := llc_mem_req_data_hprot;
          reg.haddr    := llc_mem_req_data_addr & empty_offset;
          reg.line     := llc_mem_req_data_line;
          reg.word_cnt := 0;

          ahbmo.hbusreq <= '1';
          if (granted = '1' and ahbmi.hready = '1') then
            if llc_mem_req_data_hwrite = '0' then
              reg.state := load_line;
            else
              reg.state := store_line;
            end if;
          else
            reg.state := grant_wait;
          end if;
        end if;

      -- GRANT WAIT
      when grant_wait =>
        ahbmo.hbusreq <= '1';
        if (granted = '1' and ahbmi.hready = '1') then
          if reg.hwrite = '0' then
            reg.state := load_line;
          else
            reg.state := store_line;
          end if;
        end if;

      -- LOAD LINE
      when load_line =>
        if reg.word_cnt = 0 then

          if granted = '0' then
            reg.asserts(AS_AHBM_LOAD_NOT_GRANTED) := '1';
          end if;

          ahbmo.hbusreq <= '1';
          ahbmo.htrans  <= HTRANS_NONSEQ;
          ahbmo.hwrite  <= '0';
          ahbmo.haddr   <= reg.haddr;
          ahbmo.hprot(HPROT_WIDTH - 1 downto 0)   <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.word_cnt := reg.word_cnt + 1;
            reg.haddr    := reg.haddr + 4;
          end if;

        elsif reg.word_cnt = WORDS_PER_LINE then

          if ahbmi.hready = '1' then
            reg.line(WORDS_PER_LINE*BITS_PER_WORD-1 downto (WORDS_PER_LINE-1)*BITS_PER_WORD) := ahbmi.hrdata;

            llc_mem_rsp_valid <= '1';
            if llc_mem_rsp_ready = '1' then
              llc_mem_rsp_data_line <= ahbmi.hrdata & reg.line((WORDS_PER_LINE-1)*BITS_PER_WORD-1 downto 0);
              reg.state             := idle;
            else
              reg.state := send_mem_rsp;
            end if;
          end if;

        else

          if granted = '0' then
            reg.asserts(AS_AHBM_LOAD_NOT_GRANTED) := '1';
          end if;

          ahbmo.hbusreq <= '1';         -- put to 0 when WORDS_PER_LINE - 1
          ahbmo.htrans  <= HTRANS_SEQ;
          ahbmo.hwrite  <= '0';
          ahbmo.haddr   <= reg.haddr;
          ahbmo.hprot(HPROT_WIDTH - 1 downto 0) <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.line(reg.word_cnt*BITS_PER_WORD-1 downto (reg.word_cnt-1)*BITS_PER_WORD) := ahbmi.hrdata;
            reg.word_cnt := reg.word_cnt + 1;
            reg.haddr := reg.haddr + 4;
          end if;
        end if;

      -- SEND MEM RSP
      when send_mem_rsp =>
        llc_mem_rsp_valid <= '1';
        if llc_mem_rsp_ready = '1' then
          llc_mem_rsp_data_line <= reg.line;

          reg.state := idle;
        end if;

      -- STORE LINE
      when store_line =>
        if reg.word_cnt = 0 then

          if granted = '0' then
            reg.asserts(AS_AHBM_STORE_NOT_GRANTED) := '1';
          end if;

          ahbmo.hbusreq <= '1';
          ahbmo.htrans  <= HTRANS_NONSEQ;
          ahbmo.hwrite  <= '1';
          ahbmo.haddr   <= reg.haddr;
          ahbmo.hprot(HPROT_WIDTH - 1 downto 0) <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.word_cnt := reg.word_cnt + 1;
            reg.haddr    := reg.haddr + 4;
          end if;

        elsif reg.word_cnt = WORDS_PER_LINE then

          ahbmo.hwdata <= reg.line(WORDS_PER_LINE*BITS_PER_WORD-1 downto (WORDS_PER_LINE-1)*BITS_PER_WORD);
          if ahbmi.hready = '1' then
            reg.state := idle;
          end if;

        else

          if granted = '0' then
            reg.asserts(AS_AHBM_STORE_NOT_GRANTED) := '1';
          end if;

          ahbmo.hwdata <= reg.line(reg.word_cnt*BITS_PER_WORD-1 downto (reg.word_cnt-1)*BITS_PER_WORD);

          ahbmo.hbusreq <= '1';
          ahbmo.htrans  <= HTRANS_SEQ;
          ahbmo.hwrite  <= '1';
          ahbmo.haddr   <= reg.haddr;
          ahbmo.hprot(HPROT_WIDTH - 1 downto 0) <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.word_cnt := reg.word_cnt + 1;
            reg.haddr    := reg.haddr + 4;
          end if;

        end if;

    end case;

    ahbm_reg_next <= reg;

  end process fsm_ahbm;

-----------------------------------------------------------------------------
-- FSM: Requests from NoC
-----------------------------------------------------------------------------
  fsm_req_in : process (req_in_reg, llc_req_in_ready,
                        coherence_req_empty, coherence_req_data_out) is

    variable reg      : req_in_reg_type;
    variable msg_type : noc_msg_type;
    variable reserved : reserved_field_type;

  begin  -- process fsm_req_in
    -- initialize variables
    reg         := req_in_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (send to cache)
    llc_req_in_valid        <= '0';
    llc_req_in_data_coh_msg <= (others => '0');
    llc_req_in_data_hprot   <= (others => '0');
    llc_req_in_data_addr    <= (others => '0');
    llc_req_in_data_line    <= (others => '0');
    llc_req_in_data_req_id  <= (others => '0');

    -- initialize signals toward noc (receive from noc)
    coherence_req_rdreq <= '0';

    -- fsm states
    case reg.state is

      -- RECEIVE HEADER
      when rcv_header =>
        if coherence_req_empty = '0' then
          coherence_req_rdreq <= '1';

          msg_type    := get_msg_type(coherence_req_data_out);
          reg.coh_msg := msg_type(COH_MSG_TYPE_WIDTH - 1 downto 0);
          reserved    := get_reserved_field(coherence_req_data_out);
          reg.hprot   := reserved(HPROT_WIDTH - 1 downto 0);
          
          reg.origin_x := get_origin_x(coherence_req_data_out);
          reg.origin_y := get_origin_y(coherence_req_data_out);
          if unsigned(reg.origin_x) >= 0 and unsigned(reg.origin_x) <= noc_xlen and
             unsigned(reg.origin_y) >= 0 and unsigned(reg.origin_y) <= noc_xlen
          then
            reg.tile_id := to_integer(unsigned(reg.origin_x)) + to_integer(unsigned(reg.origin_y)) * noc_xlen;
            if tile_cpu_id(reg.tile_id) >= 0 then
              reg.req_id := std_logic_vector(to_unsigned(tile_cpu_id(reg.tile_id), NCPU_MAX_LOG2));
            end if;
          end if;

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>
        if coherence_req_empty = '0' then
          if '0' & reg.coh_msg = REQ_PUTM then

            coherence_req_rdreq <= '1';
            reg.addr            := coherence_req_data_out(ADDR_BITS - 1 downto SET_RANGE_LO);
            reg.word_cnt        := 0;
            reg.state           := rcv_data;

          elsif llc_req_in_ready = '1' then
            coherence_req_rdreq     <= '1';
            llc_req_in_valid        <= '1';
            llc_req_in_data_coh_msg <= reg.coh_msg;
            llc_req_in_data_addr    <= coherence_req_data_out(ADDR_BITS - 1 downto SET_RANGE_LO);
            llc_req_in_data_hprot   <= reg.hprot;
            llc_req_in_data_req_id  <= reg.req_id;
            reg.state               := rcv_header;
          end if;
        end if;

      -- RECEIVE DATA
      when rcv_data =>
        if coherence_req_empty = '0' then
          if reg.word_cnt = WORDS_PER_LINE - 1 then
            if llc_req_in_ready = '1' then
              coherence_req_rdreq <= '1';

              reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                       BITS_PER_WORD * reg.word_cnt)
                := coherence_req_data_out(BITS_PER_WORD - 1 downto 0);
              reg.state := rcv_header;

              llc_req_in_valid        <= '1';
              llc_req_in_data_coh_msg <= reg.coh_msg;
              llc_req_in_data_hprot   <= reg.hprot;
              llc_req_in_data_addr    <= reg.addr;
              llc_req_in_data_line    <= reg.line;
              llc_req_in_data_req_id  <= reg.req_id;
            end if;

          else
            coherence_req_rdreq <= '1';

            reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                     (BITS_PER_WORD * reg.word_cnt))
              := coherence_req_data_out(BITS_PER_WORD - 1 downto 0);

            reg.word_cnt := reg.word_cnt + 1;
          end if;
        end if;

    end case;

    req_in_reg_next <= reg;

  end process fsm_req_in;

-----------------------------------------------------------------------------
-- FSM: Responses from NoC
-----------------------------------------------------------------------------
  fsm_rsp_in : process (rsp_in_reg, llc_rsp_in_ready,
                        coherence_rsp_rcv_empty, coherence_rsp_rcv_data_out) is

    variable reg      : rsp_in_reg_type;

  begin  -- process fsm_rsp_in
    -- initialize variables
    reg         := rsp_in_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (send to cache)
    llc_rsp_in_valid       <= '0';
    llc_rsp_in_data_addr   <= (others => '0');
    llc_rsp_in_data_line   <= (others => '0');
    llc_rsp_in_data_req_id <= (others => '0');

    -- initialize signals toward noc (receive from noc)
    coherence_rsp_rcv_rdreq <= '0';

    -- fsm states
    case reg.state is

      -- RECEIVE HEADER
      when rcv_header =>
        if coherence_rsp_rcv_empty = '0' then

          coherence_rsp_rcv_rdreq <= '1';

          reg.origin_x := get_origin_x(coherence_rsp_rcv_data_out);
          reg.origin_y := get_origin_y(coherence_rsp_rcv_data_out);

          if unsigned(reg.origin_x) >= 0 and unsigned(reg.origin_x) <= noc_xlen and
             unsigned(reg.origin_y) >= 0 and unsigned(reg.origin_y) <= noc_xlen
          then
            reg.tile_id := to_integer(unsigned(reg.origin_x)) + to_integer(unsigned(reg.origin_y)) * noc_xlen;
            if tile_cpu_id(reg.tile_id) >= 0 then
              reg.req_id := std_logic_vector(to_unsigned(tile_cpu_id(reg.tile_id), NCPU_MAX_LOG2));
            end if;
          end if;

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>
        if coherence_rsp_rcv_empty = '0' then

          coherence_rsp_rcv_rdreq <= '1';

          reg.addr     := coherence_rsp_rcv_data_out(ADDR_BITS - 1 downto SET_RANGE_LO);
          reg.word_cnt := 0;
          reg.state    := rcv_data;

        end if;

      -- RECEIVE DATA
      when rcv_data =>
        if coherence_rsp_rcv_empty = '0' then
          if reg.word_cnt = WORDS_PER_LINE - 1 then
            if llc_rsp_in_ready = '1' then

              coherence_rsp_rcv_rdreq <= '1';

              reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                       BITS_PER_WORD * reg.word_cnt)
                := coherence_rsp_rcv_data_out(BITS_PER_WORD - 1 downto 0);

              reg.state := rcv_header;

              llc_rsp_in_valid       <= '1';
              llc_rsp_in_data_addr   <= reg.addr;
              llc_rsp_in_data_line   <= reg.line;
              llc_rsp_in_data_req_id <= reg.req_id;
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

-------------------------------------------------------------------------------
-- FSM: Forwards to NoC
-------------------------------------------------------------------------------
  fsm_fwd_out : process (fwd_out_reg, coherence_fwd_full,
                         llc_fwd_out_valid, llc_fwd_out_data_coh_msg, llc_fwd_out_data_addr,
                         llc_fwd_out_data_req_id, llc_fwd_out_data_dest_id) is

    variable reg       : fwd_out_reg_type;
    variable dest_init : integer;
    variable dest_x    : local_yx;
    variable dest_y    : local_yx;
    variable req_id    : reserved_field_type;

  begin  -- process fsm_cache2noc
    -- initialize variables
    reg         := fwd_out_reg;
    reg.asserts := (others => '0');

    dest_init := 0;
    dest_x := (others => '0');
    dest_y := (others => '0');
    req_id := (others => '0');

    -- initialize signals toward cache (receive from cache)
    llc_fwd_out_ready <= '0';

    -- initialize signals toward noc
    coherence_fwd_wrreq   <= '0';
    coherence_fwd_data_in <= (others => '0');

    case reg.state is

      -- SEND HEADER
      when send_header =>
        if coherence_fwd_full = '0' then

          llc_fwd_out_ready <= '1';

          if llc_fwd_out_valid = '1' then

            reg.addr := llc_fwd_out_data_addr;

            if llc_fwd_out_data_dest_id >= "0" then
              dest_init := cpu_tile_id(to_integer(unsigned(llc_fwd_out_data_dest_id)));
              if dest_init >= 0 then
                dest_x := std_logic_vector(to_unsigned((dest_init mod noc_xlen), 3));
                dest_y := std_logic_vector(to_unsigned((dest_init / noc_xlen), 3));
              end if;
            end if;

            req_id(RESERVED_WIDTH-1 downto llc_fwd_out_data_req_id'length) := (others => '0');
            req_id(llc_fwd_out_data_req_id'length - 1 downto 0)            := llc_fwd_out_data_req_id;

            coherence_fwd_wrreq <= '1';
            coherence_fwd_data_in <= create_header(local_y, local_x, dest_y, dest_x,
                                                       '0' & llc_fwd_out_data_coh_msg, req_id);

            reg.state := send_addr;

          end if;
        end if;

      -- SEND ADDRESS
      when send_addr =>
        if coherence_fwd_full = '0' then

          coherence_fwd_wrreq   <= '1';
          coherence_fwd_data_in <= PREAMBLE_TAIL & reg.addr & empty_offset;
          reg.state                 := send_header;

        end if;

    end case;

    fwd_out_reg_next <= reg;

  end process fsm_fwd_out;

-------------------------------------------------------------------------------
-- FSM: Responses to NoC
-------------------------------------------------------------------------------
  fsm_rsp_out : process (rsp_out_reg, coherence_rsp_snd_full,
                         llc_rsp_out_valid, llc_rsp_out_data_coh_msg, llc_rsp_out_data_addr,
                         llc_rsp_out_data_line, llc_rsp_out_data_invack_cnt,
                         llc_rsp_out_data_req_id, llc_rsp_out_data_dest_id) is

    variable reg       : rsp_out_reg_type;
    variable dest_init : integer;
    variable dest_x    : local_yx;
    variable dest_y    : local_yx;

  begin  -- process fsm_cache2noc
    -- initialize variables
    reg         := rsp_out_reg;
    reg.asserts := (others => '0');

    dest_init := 0;
    dest_x := (others => '0');
    dest_y := (others => '0');
    
    -- initialize signals toward cache (receive from cache)
    llc_rsp_out_ready <= '0';

    -- initialize signals toward noc
    coherence_rsp_snd_wrreq   <= '0';
    coherence_rsp_snd_data_in <= (others => '0');

    case reg.state is

      -- SEND HEADER
      when send_header =>
        if coherence_rsp_snd_full = '0' then

          llc_rsp_out_ready <= '1';

          if llc_rsp_out_valid = '1' then

            reg.coh_msg := llc_rsp_out_data_coh_msg;
            reg.addr    := llc_rsp_out_data_addr;
            reg.line    := llc_rsp_out_data_line;

            if llc_rsp_out_data_req_id >= "0" then
              dest_init := cpu_tile_id(to_integer(unsigned(llc_rsp_out_data_req_id)));
              if dest_init >= 0 then
                dest_x := std_logic_vector(to_unsigned((dest_init mod noc_xlen), 3));
                dest_y := std_logic_vector(to_unsigned((dest_init / noc_xlen), 3));
              end if;
            end if;

            coherence_rsp_snd_wrreq <= '1';
            coherence_rsp_snd_data_in <= create_header(local_y, local_x, dest_y, dest_x,
                                                       '0' & reg.coh_msg, "00" & llc_rsp_out_data_invack_cnt);

            reg.state := send_addr;

          end if;
        end if;

      -- SEND ADDRESS
      when send_addr =>
        if coherence_rsp_snd_full = '0' then

          coherence_rsp_snd_wrreq <= '1';
          coherence_rsp_snd_data_in <= PREAMBLE_BODY & reg.addr & empty_offset;
          reg.state                 := send_data;
          reg.word_cnt              := 0;

        end if;

      -- SEND DATA
      when send_data =>
        if coherence_rsp_snd_full = '0' then
          coherence_rsp_snd_wrreq <= '1';

          if reg.word_cnt = WORDS_PER_LINE - 1 then
            coherence_rsp_snd_data_in <=
              PREAMBLE_TAIL & reg.line((BITS_PER_WORD * reg.word_cnt) +
                                       BITS_PER_WORD - 1 downto (BITS_PER_WORD * reg.word_cnt));
            reg.state := send_header;
          else
            coherence_rsp_snd_data_in <=
              PREAMBLE_BODY & reg.line((BITS_PER_WORD * reg.word_cnt) +
                                       BITS_PER_WORD - 1 downto (BITS_PER_WORD * reg.word_cnt));
            reg.word_cnt := reg.word_cnt + 1;
          end if;
        end if;

    end case;

    rsp_out_reg_next <= reg;

  end process fsm_rsp_out;

-------------------------------------------------------------------------------
-- Instantiations
-------------------------------------------------------------------------------

  llc_cpus_1 : if ncpu = 1 generate
  
  -- instantiation of llc cache on cpu tile
  llc_cache_1cpus : llc_basic_1
    port map (
      clk => clk,
      rst => rst,

      llc_rst_tb_valid      => '0',
      llc_rst_tb_data       => '0',
      llc_rst_tb_done_ready => '0',
      llc_rst_tb_ready      => open,
      llc_rst_tb_done_valid => open,
      llc_rst_tb_done_data  => open,

      -- NoC to cache
      llc_req_in_ready        => llc_req_in_ready,
      llc_req_in_valid        => llc_req_in_valid,
      llc_req_in_data_coh_msg => llc_req_in_data_coh_msg,
      llc_req_in_data_hprot   => llc_req_in_data_hprot,
      llc_req_in_data_addr    => llc_req_in_data_addr,
      llc_req_in_data_line    => llc_req_in_data_line,
      llc_req_in_data_req_id  => llc_req_in_data_req_id,

      llc_rsp_in_ready       => llc_rsp_in_ready,
      llc_rsp_in_valid       => llc_rsp_in_valid,
      llc_rsp_in_data_addr   => llc_rsp_in_data_addr,
      llc_rsp_in_data_line   => llc_rsp_in_data_line,
      llc_rsp_in_data_req_id => llc_rsp_in_data_req_id,

      -- cache to NoC
      llc_rsp_out_ready           => llc_rsp_out_ready,
      llc_rsp_out_valid           => llc_rsp_out_valid,
      llc_rsp_out_data_coh_msg    => llc_rsp_out_data_coh_msg,
      llc_rsp_out_data_addr       => llc_rsp_out_data_addr,
      llc_rsp_out_data_line       => llc_rsp_out_data_line,
      llc_rsp_out_data_invack_cnt => llc_rsp_out_data_invack_cnt,
      llc_rsp_out_data_req_id     => llc_rsp_out_data_req_id,
      llc_rsp_out_data_dest_id    => llc_rsp_out_data_dest_id,

      llc_fwd_out_ready        => llc_fwd_out_ready,
      llc_fwd_out_valid        => llc_fwd_out_valid,
      llc_fwd_out_data_coh_msg => llc_fwd_out_data_coh_msg,
      llc_fwd_out_data_addr    => llc_fwd_out_data_addr,
      llc_fwd_out_data_req_id  => llc_fwd_out_data_req_id,
      llc_fwd_out_data_dest_id => llc_fwd_out_data_dest_id,

      -- AHB to cache
      llc_mem_rsp_ready     => llc_mem_rsp_ready,
      llc_mem_rsp_valid     => llc_mem_rsp_valid,
      llc_mem_rsp_data_line => llc_mem_rsp_data_line,

      -- cache to AHB
      llc_mem_req_ready       => llc_mem_req_ready,
      llc_mem_req_valid       => llc_mem_req_valid,
      llc_mem_req_data_hwrite => llc_mem_req_data_hwrite,
      llc_mem_req_data_hsize  => llc_mem_req_data_hsize,
      llc_mem_req_data_hprot  => llc_mem_req_data_hprot,
      llc_mem_req_data_addr   => llc_mem_req_data_addr,
      llc_mem_req_data_line   => llc_mem_req_data_line

      -- debug
      --asserts    => asserts,
      --bookmark   => bookmark,
      --custom_dbg => custom_dbg,

      --tag_hit_out => tag_hit_out,
      --hit_way_out => hit_way_out,
      --empty_way_found_out => empty_way_found_out,
      --empty_way_out => empty_way_out,
      --evict_out => evict_out,
      --way_out => way_out,
      --llc_addr_out => llc_addr_out,
      --req_stall_out => req_stall_out,
      --req_in_stalled_valid_out => req_in_stalled_valid_out,
      --req_in_stalled_out_coh_msg => req_in_stalled_out_coh_msg,
      --req_in_stalled_out_hprot => req_in_stalled_out_hprot,
      --req_in_stalled_out_addr => req_in_stalled_out_addr,
      --req_in_stalled_out_line => req_in_stalled_out_line,
      --req_in_stalled_out_req_id => req_in_stalled_out_req_id,
      --is_rsp_to_get_out => is_rsp_to_get_out,
      --is_req_to_get_out => is_req_to_get_out,
      --tag_buf_out_0 => tag_buf_out_0,
      --tag_buf_out_1 => tag_buf_out_1,
      --tag_buf_out_2 => tag_buf_out_2,
      --tag_buf_out_3 => tag_buf_out_3,
      --tag_buf_out_4 => tag_buf_out_4,
      --tag_buf_out_5 => tag_buf_out_5,
      --tag_buf_out_6 => tag_buf_out_6,
      --tag_buf_out_7 => tag_buf_out_7,
      --state_buf_out_0 => state_buf_out_0,
      --state_buf_out_1 => state_buf_out_1,
      --state_buf_out_2 => state_buf_out_2,
      --state_buf_out_3 => state_buf_out_3,
      --state_buf_out_4 => state_buf_out_4,
      --state_buf_out_5 => state_buf_out_5,
      --state_buf_out_6 => state_buf_out_6,
      --state_buf_out_7 => state_buf_out_7,
      --sharers_buf_out_0 => sharers_buf_out_0,
      --sharers_buf_out_1 => sharers_buf_out_1,
      --sharers_buf_out_2 => sharers_buf_out_2,
      --sharers_buf_out_3 => sharers_buf_out_3,
      --sharers_buf_out_4 => sharers_buf_out_4,
      --sharers_buf_out_5 => sharers_buf_out_5,
      --sharers_buf_out_6 => sharers_buf_out_6,
      --sharers_buf_out_7 => sharers_buf_out_7,
      --owner_buf_out_0 => owner_buf_out_0,
      --owner_buf_out_1 => owner_buf_out_1,
      --owner_buf_out_2 => owner_buf_out_2,
      --owner_buf_out_3 => owner_buf_out_3,
      --owner_buf_out_4 => owner_buf_out_4,
      --owner_buf_out_5 => owner_buf_out_5,
      --owner_buf_out_6 => owner_buf_out_6,
      --owner_buf_out_7 => owner_buf_out_7
      );

  end generate llc_cpus_1;
  
  llc_cpus_2 : if ncpu = 2 generate
  
  -- instantiation of llc cache on cpu tile
  llc_cache_2cpus : llc_basic_2
    port map (
      clk => clk,
      rst => rst,

      llc_rst_tb_valid      => '0',
      llc_rst_tb_data       => '0',
      llc_rst_tb_done_ready => '0',
      llc_rst_tb_ready      => open,
      llc_rst_tb_done_valid => open,
      llc_rst_tb_done_data  => open,

      -- NoC to cache
      llc_req_in_ready        => llc_req_in_ready,
      llc_req_in_valid        => llc_req_in_valid,
      llc_req_in_data_coh_msg => llc_req_in_data_coh_msg,
      llc_req_in_data_hprot   => llc_req_in_data_hprot,
      llc_req_in_data_addr    => llc_req_in_data_addr,
      llc_req_in_data_line    => llc_req_in_data_line,
      llc_req_in_data_req_id  => llc_req_in_data_req_id,

      llc_rsp_in_ready       => llc_rsp_in_ready,
      llc_rsp_in_valid       => llc_rsp_in_valid,
      llc_rsp_in_data_addr   => llc_rsp_in_data_addr,
      llc_rsp_in_data_line   => llc_rsp_in_data_line,
      llc_rsp_in_data_req_id => llc_rsp_in_data_req_id,

      -- cache to NoC
      llc_rsp_out_ready           => llc_rsp_out_ready,
      llc_rsp_out_valid           => llc_rsp_out_valid,
      llc_rsp_out_data_coh_msg    => llc_rsp_out_data_coh_msg,
      llc_rsp_out_data_addr       => llc_rsp_out_data_addr,
      llc_rsp_out_data_line       => llc_rsp_out_data_line,
      llc_rsp_out_data_invack_cnt => llc_rsp_out_data_invack_cnt,
      llc_rsp_out_data_req_id     => llc_rsp_out_data_req_id,
      llc_rsp_out_data_dest_id    => llc_rsp_out_data_dest_id,

      llc_fwd_out_ready        => llc_fwd_out_ready,
      llc_fwd_out_valid        => llc_fwd_out_valid,
      llc_fwd_out_data_coh_msg => llc_fwd_out_data_coh_msg,
      llc_fwd_out_data_addr    => llc_fwd_out_data_addr,
      llc_fwd_out_data_req_id  => llc_fwd_out_data_req_id,
      llc_fwd_out_data_dest_id => llc_fwd_out_data_dest_id,

      -- AHB to cache
      llc_mem_rsp_ready     => llc_mem_rsp_ready,
      llc_mem_rsp_valid     => llc_mem_rsp_valid,
      llc_mem_rsp_data_line => llc_mem_rsp_data_line,

      -- cache to AHB
      llc_mem_req_ready       => llc_mem_req_ready,
      llc_mem_req_valid       => llc_mem_req_valid,
      llc_mem_req_data_hwrite => llc_mem_req_data_hwrite,
      llc_mem_req_data_hsize  => llc_mem_req_data_hsize,
      llc_mem_req_data_hprot  => llc_mem_req_data_hprot,
      llc_mem_req_data_addr   => llc_mem_req_data_addr,
      llc_mem_req_data_line   => llc_mem_req_data_line

      -- debug
      --asserts    => asserts,
      --bookmark   => bookmark,
      --custom_dbg => custom_dbg,

      --tag_hit_out => tag_hit_out,
      --hit_way_out => hit_way_out,
      --empty_way_found_out => empty_way_found_out,
      --empty_way_out => empty_way_out,
      --evict_out => evict_out,
      --way_out => way_out,
      --llc_addr_out => llc_addr_out,
      --req_stall_out => req_stall_out,
      --req_in_stalled_valid_out => req_in_stalled_valid_out,
      --req_in_stalled_out_coh_msg => req_in_stalled_out_coh_msg,
      --req_in_stalled_out_hprot => req_in_stalled_out_hprot,
      --req_in_stalled_out_addr => req_in_stalled_out_addr,
      --req_in_stalled_out_line => req_in_stalled_out_line,
      --req_in_stalled_out_req_id => req_in_stalled_out_req_id,
      --is_rsp_to_get_out => is_rsp_to_get_out,
      --is_req_to_get_out => is_req_to_get_out,
      --tag_buf_out_0 => tag_buf_out_0,
      --tag_buf_out_1 => tag_buf_out_1,
      --tag_buf_out_2 => tag_buf_out_2,
      --tag_buf_out_3 => tag_buf_out_3,
      --tag_buf_out_4 => tag_buf_out_4,
      --tag_buf_out_5 => tag_buf_out_5,
      --tag_buf_out_6 => tag_buf_out_6,
      --tag_buf_out_7 => tag_buf_out_7,
      --tag_buf_out_8 => tag_buf_out_8,
      --tag_buf_out_9 => tag_buf_out_9,
      --tag_buf_out_10 => tag_buf_out_10,
      --tag_buf_out_11 => tag_buf_out_11,
      --tag_buf_out_12 => tag_buf_out_12,
      --tag_buf_out_13 => tag_buf_out_13,
      --tag_buf_out_14 => tag_buf_out_14,
      --tag_buf_out_15 => tag_buf_out_15,
      --state_buf_out_0 => state_buf_out_0,
      --state_buf_out_1 => state_buf_out_1,
      --state_buf_out_2 => state_buf_out_2,
      --state_buf_out_3 => state_buf_out_3,
      --state_buf_out_4 => state_buf_out_4,
      --state_buf_out_5 => state_buf_out_5,
      --state_buf_out_6 => state_buf_out_6,
      --state_buf_out_7 => state_buf_out_7,
      --state_buf_out_8 => state_buf_out_8,
      --state_buf_out_9 => state_buf_out_9,
      --state_buf_out_10 => state_buf_out_10,
      --state_buf_out_11 => state_buf_out_11,
      --state_buf_out_12 => state_buf_out_12,
      --state_buf_out_13 => state_buf_out_13,
      --state_buf_out_14 => state_buf_out_14,
      --state_buf_out_15 => state_buf_out_15,
      --sharers_buf_out_0 => sharers_buf_out_0,
      --sharers_buf_out_1 => sharers_buf_out_1,
      --sharers_buf_out_2 => sharers_buf_out_2,
      --sharers_buf_out_3 => sharers_buf_out_3,
      --sharers_buf_out_4 => sharers_buf_out_4,
      --sharers_buf_out_5 => sharers_buf_out_5,
      --sharers_buf_out_6 => sharers_buf_out_6,
      --sharers_buf_out_7 => sharers_buf_out_7,
      --sharers_buf_out_8 => sharers_buf_out_8,
      --sharers_buf_out_9 => sharers_buf_out_9,
      --sharers_buf_out_10 => sharers_buf_out_10,
      --sharers_buf_out_11 => sharers_buf_out_11,
      --sharers_buf_out_12 => sharers_buf_out_12,
      --sharers_buf_out_13 => sharers_buf_out_13,
      --sharers_buf_out_14 => sharers_buf_out_14,
      --sharers_buf_out_15 => sharers_buf_out_15,
      --owner_buf_out_0 => owner_buf_out_0,
      --owner_buf_out_1 => owner_buf_out_1,
      --owner_buf_out_2 => owner_buf_out_2,
      --owner_buf_out_3 => owner_buf_out_3,
      --owner_buf_out_4 => owner_buf_out_4,
      --owner_buf_out_5 => owner_buf_out_5,
      --owner_buf_out_6 => owner_buf_out_6,
      --owner_buf_out_7 => owner_buf_out_7,
      --owner_buf_out_8 => owner_buf_out_8,
      --owner_buf_out_9 => owner_buf_out_9,
      --owner_buf_out_10 => owner_buf_out_10,
      --owner_buf_out_11 => owner_buf_out_11,
      --owner_buf_out_12 => owner_buf_out_12,
      --owner_buf_out_13 => owner_buf_out_13,
      --owner_buf_out_14 => owner_buf_out_14,
      --owner_buf_out_15 => owner_buf_out_15
      );

  end generate llc_cpus_2;

  llc_cpus_4 : if ncpu = 4 generate
  
  -- instantiation of llc cache on cpu tile
  llc_cache_4cpus : llc_basic_4
    port map (
      clk => clk,
      rst => rst,

      llc_rst_tb_valid      => '0',
      llc_rst_tb_data       => '0',
      llc_rst_tb_done_ready => '0',
      llc_rst_tb_ready      => open,
      llc_rst_tb_done_valid => open,
      llc_rst_tb_done_data  => open,

      -- NoC to cache
      llc_req_in_ready        => llc_req_in_ready,
      llc_req_in_valid        => llc_req_in_valid,
      llc_req_in_data_coh_msg => llc_req_in_data_coh_msg,
      llc_req_in_data_hprot   => llc_req_in_data_hprot,
      llc_req_in_data_addr    => llc_req_in_data_addr,
      llc_req_in_data_line    => llc_req_in_data_line,
      llc_req_in_data_req_id  => llc_req_in_data_req_id,

      llc_rsp_in_ready       => llc_rsp_in_ready,
      llc_rsp_in_valid       => llc_rsp_in_valid,
      llc_rsp_in_data_addr   => llc_rsp_in_data_addr,
      llc_rsp_in_data_line   => llc_rsp_in_data_line,
      llc_rsp_in_data_req_id => llc_rsp_in_data_req_id,

      -- cache to NoC
      llc_rsp_out_ready           => llc_rsp_out_ready,
      llc_rsp_out_valid           => llc_rsp_out_valid,
      llc_rsp_out_data_coh_msg    => llc_rsp_out_data_coh_msg,
      llc_rsp_out_data_addr       => llc_rsp_out_data_addr,
      llc_rsp_out_data_line       => llc_rsp_out_data_line,
      llc_rsp_out_data_invack_cnt => llc_rsp_out_data_invack_cnt,
      llc_rsp_out_data_req_id     => llc_rsp_out_data_req_id,
      llc_rsp_out_data_dest_id    => llc_rsp_out_data_dest_id,

      llc_fwd_out_ready        => llc_fwd_out_ready,
      llc_fwd_out_valid        => llc_fwd_out_valid,
      llc_fwd_out_data_coh_msg => llc_fwd_out_data_coh_msg,
      llc_fwd_out_data_addr    => llc_fwd_out_data_addr,
      llc_fwd_out_data_req_id  => llc_fwd_out_data_req_id,
      llc_fwd_out_data_dest_id => llc_fwd_out_data_dest_id,

      -- AHB to cache
      llc_mem_rsp_ready     => llc_mem_rsp_ready,
      llc_mem_rsp_valid     => llc_mem_rsp_valid,
      llc_mem_rsp_data_line => llc_mem_rsp_data_line,

      -- cache to AHB
      llc_mem_req_ready       => llc_mem_req_ready,
      llc_mem_req_valid       => llc_mem_req_valid,
      llc_mem_req_data_hwrite => llc_mem_req_data_hwrite,
      llc_mem_req_data_hsize  => llc_mem_req_data_hsize,
      llc_mem_req_data_hprot  => llc_mem_req_data_hprot,
      llc_mem_req_data_addr   => llc_mem_req_data_addr,
      llc_mem_req_data_line   => llc_mem_req_data_line

      -- debug
      --asserts    => asserts,
      --bookmark   => bookmark,
      --custom_dbg => custom_dbg,

      --tag_hit_out => tag_hit_out,
      --hit_way_out => hit_way_out,
      --empty_way_found_out => empty_way_found_out,
      --empty_way_out => empty_way_out,
      --evict_out => evict_out,
      --way_out => way_out,
      --llc_addr_out => llc_addr_out,
      --req_stall_out => req_stall_out,
      --req_in_stalled_valid_out => req_in_stalled_valid_out,
      --req_in_stalled_out_coh_msg => req_in_stalled_out_coh_msg,
      --req_in_stalled_out_hprot => req_in_stalled_out_hprot,
      --req_in_stalled_out_addr => req_in_stalled_out_addr,
      --req_in_stalled_out_line => req_in_stalled_out_line,
      --req_in_stalled_out_req_id => req_in_stalled_out_req_id,
      --is_rsp_to_get_out => is_rsp_to_get_out,
      --is_req_to_get_out => is_req_to_get_out,
      --tag_buf_out_0 => tag_buf_out_0,
      --tag_buf_out_1 => tag_buf_out_1,
      --tag_buf_out_2 => tag_buf_out_2,
      --tag_buf_out_3 => tag_buf_out_3,
      --tag_buf_out_4 => tag_buf_out_4,
      --tag_buf_out_5 => tag_buf_out_5,
      --tag_buf_out_6 => tag_buf_out_6,
      --tag_buf_out_7 => tag_buf_out_7,
      --tag_buf_out_8 => tag_buf_out_8,
      --tag_buf_out_9 => tag_buf_out_9,
      --tag_buf_out_10 => tag_buf_out_10,
      --tag_buf_out_11 => tag_buf_out_11,
      --tag_buf_out_12 => tag_buf_out_12,
      --tag_buf_out_13 => tag_buf_out_13,
      --tag_buf_out_14 => tag_buf_out_14,
      --tag_buf_out_15 => tag_buf_out_15,
      --tag_buf_out_16 => tag_buf_out_16,
      --tag_buf_out_17 => tag_buf_out_17,
      --tag_buf_out_18 => tag_buf_out_18,
      --tag_buf_out_19 => tag_buf_out_19,
      --tag_buf_out_20 => tag_buf_out_20,
      --tag_buf_out_21 => tag_buf_out_21,
      --tag_buf_out_22 => tag_buf_out_22,
      --tag_buf_out_23 => tag_buf_out_23,
      --tag_buf_out_24 => tag_buf_out_24,
      --tag_buf_out_25 => tag_buf_out_25,
      --tag_buf_out_26 => tag_buf_out_26,
      --tag_buf_out_27 => tag_buf_out_27,
      --tag_buf_out_28 => tag_buf_out_28,
      --tag_buf_out_29 => tag_buf_out_29,
      --tag_buf_out_30 => tag_buf_out_30,
      --tag_buf_out_31 => tag_buf_out_31,
      --state_buf_out_0 => state_buf_out_0,
      --state_buf_out_1 => state_buf_out_1,
      --state_buf_out_2 => state_buf_out_2,
      --state_buf_out_3 => state_buf_out_3,
      --state_buf_out_4 => state_buf_out_4,
      --state_buf_out_5 => state_buf_out_5,
      --state_buf_out_6 => state_buf_out_6,
      --state_buf_out_7 => state_buf_out_7,
      --state_buf_out_8 => state_buf_out_8,
      --state_buf_out_9 => state_buf_out_9,
      --state_buf_out_10 => state_buf_out_10,
      --state_buf_out_11 => state_buf_out_11,
      --state_buf_out_12 => state_buf_out_12,
      --state_buf_out_13 => state_buf_out_13,
      --state_buf_out_14 => state_buf_out_14,
      --state_buf_out_15 => state_buf_out_15,
      --state_buf_out_16 => state_buf_out_16,
      --state_buf_out_17 => state_buf_out_17,
      --state_buf_out_18 => state_buf_out_18,
      --state_buf_out_19 => state_buf_out_19,
      --state_buf_out_20 => state_buf_out_20,
      --state_buf_out_21 => state_buf_out_21,
      --state_buf_out_22 => state_buf_out_22,
      --state_buf_out_23 => state_buf_out_23,
      --state_buf_out_24 => state_buf_out_24,
      --state_buf_out_25 => state_buf_out_25,
      --state_buf_out_26 => state_buf_out_26,
      --state_buf_out_27 => state_buf_out_27,
      --state_buf_out_28 => state_buf_out_28,
      --state_buf_out_29 => state_buf_out_29,
      --state_buf_out_30 => state_buf_out_30,
      --state_buf_out_31 => state_buf_out_31,
      --sharers_buf_out_0 => sharers_buf_out_0,
      --sharers_buf_out_1 => sharers_buf_out_1,
      --sharers_buf_out_2 => sharers_buf_out_2,
      --sharers_buf_out_3 => sharers_buf_out_3,
      --sharers_buf_out_4 => sharers_buf_out_4,
      --sharers_buf_out_5 => sharers_buf_out_5,
      --sharers_buf_out_6 => sharers_buf_out_6,
      --sharers_buf_out_7 => sharers_buf_out_7,
      --sharers_buf_out_8 => sharers_buf_out_8,
      --sharers_buf_out_9 => sharers_buf_out_9,
      --sharers_buf_out_10 => sharers_buf_out_10,
      --sharers_buf_out_11 => sharers_buf_out_11,
      --sharers_buf_out_12 => sharers_buf_out_12,
      --sharers_buf_out_13 => sharers_buf_out_13,
      --sharers_buf_out_14 => sharers_buf_out_14,
      --sharers_buf_out_15 => sharers_buf_out_15,
      --sharers_buf_out_16 => sharers_buf_out_16,
      --sharers_buf_out_17 => sharers_buf_out_17,
      --sharers_buf_out_18 => sharers_buf_out_18,
      --sharers_buf_out_19 => sharers_buf_out_19,
      --sharers_buf_out_20 => sharers_buf_out_20,
      --sharers_buf_out_21 => sharers_buf_out_21,
      --sharers_buf_out_22 => sharers_buf_out_22,
      --sharers_buf_out_23 => sharers_buf_out_23,
      --sharers_buf_out_24 => sharers_buf_out_24,
      --sharers_buf_out_25 => sharers_buf_out_25,
      --sharers_buf_out_26 => sharers_buf_out_26,
      --sharers_buf_out_27 => sharers_buf_out_27,
      --sharers_buf_out_28 => sharers_buf_out_28,
      --sharers_buf_out_29 => sharers_buf_out_29,
      --sharers_buf_out_30 => sharers_buf_out_30,
      --sharers_buf_out_31 => sharers_buf_out_31,
      --owner_buf_out_0 => owner_buf_out_0,
      --owner_buf_out_1 => owner_buf_out_1,
      --owner_buf_out_2 => owner_buf_out_2,
      --owner_buf_out_3 => owner_buf_out_3,
      --owner_buf_out_4 => owner_buf_out_4,
      --owner_buf_out_5 => owner_buf_out_5,
      --owner_buf_out_6 => owner_buf_out_6,
      --owner_buf_out_7 => owner_buf_out_7,
      --owner_buf_out_8 => owner_buf_out_8,
      --owner_buf_out_9 => owner_buf_out_9,
      --owner_buf_out_10 => owner_buf_out_10,
      --owner_buf_out_11 => owner_buf_out_11,
      --owner_buf_out_12 => owner_buf_out_12,
      --owner_buf_out_13 => owner_buf_out_13,
      --owner_buf_out_14 => owner_buf_out_14,
      --owner_buf_out_15 => owner_buf_out_15,
      --owner_buf_out_16 => owner_buf_out_16,
      --owner_buf_out_17 => owner_buf_out_17,
      --owner_buf_out_18 => owner_buf_out_18,
      --owner_buf_out_19 => owner_buf_out_19,
      --owner_buf_out_20 => owner_buf_out_20,
      --owner_buf_out_21 => owner_buf_out_21,
      --owner_buf_out_22 => owner_buf_out_22,
      --owner_buf_out_23 => owner_buf_out_23,
      --owner_buf_out_24 => owner_buf_out_24,
      --owner_buf_out_25 => owner_buf_out_25,
      --owner_buf_out_26 => owner_buf_out_26,
      --owner_buf_out_27 => owner_buf_out_27,
      --owner_buf_out_28 => owner_buf_out_28,
      --owner_buf_out_29 => owner_buf_out_29,
      --owner_buf_out_30 => owner_buf_out_30,
      --owner_buf_out_31 => owner_buf_out_31
      );

  end generate llc_cpus_4;
  
-------------------------------------------------------------------------------
-- Debug
-------------------------------------------------------------------------------

  ahbm_asserts <= ahbm_reg.asserts;

  --led_wrapper_asserts <= or_reduce(ahbm_reg.asserts);

  --debug_led <= or_reduce(bookmark) or or_reduce(asserts) or led_wrapper_asserts;

end architecture rtl;
