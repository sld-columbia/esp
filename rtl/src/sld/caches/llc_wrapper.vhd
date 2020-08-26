-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
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
use work.cachepackage.all;              -- contains llc cache component
use work.sldcommon.all;


entity llc_wrapper is
  generic (
    tech          : integer                      := virtex7;
    sets          : integer                      := 256;
    ways          : integer                      := 16;
    nl2           : integer                      := 4;
    nllc          : integer                      := 0;
    noc_xlen      : integer                      := 3;
    hindex        : integer range 0 to NAHBSLV - 1 := 4;
    pindex        : integer range 0 to NAPBSLV - 1 := 5;
    pirq          : integer                      := 4;
    cacheline     : integer;
    l2_cache_en   : integer                      := 0;
    cache_tile_id : cache_attribute_array;
    dma_tile_id   : dma_attribute_array;
    tile_cache_id : attribute_vector(0 to CFG_TILES_NUM - 1);
    tile_dma_id   : attribute_vector(0 to CFG_TILES_NUM - 1);
    dma_y         : yx_vec(0 to 2**NLLC_MAX_LOG2 - 1);
    dma_x         : yx_vec(0 to 2**NLLC_MAX_LOG2 - 1);
    cache_y       : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
    cache_x       : yx_vec(0 to 2**NL2_MAX_LOG2 - 1));
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;

    local_y : in local_yx;
    local_x : in local_yx;
    pconfig : in apb_config_type;

    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    apbi  : in  apb_slv_in_type;
    apbo  : out apb_slv_out_type;

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
    -- NoC6->tile
    dma_rcv_rdreq              : out std_ulogic;
    dma_rcv_data_out           : in  noc_flit_type;
    dma_rcv_empty              : in  std_ulogic;
    -- tile->NoC4
    dma_snd_wrreq              : out std_ulogic;
    dma_snd_data_in            : out noc_flit_type;
    dma_snd_full               : in  std_ulogic;

    mon_cache                  : out monitor_cache_type
    );

end llc_wrapper;

architecture rtl of llc_wrapper is

  -- Interface with LLC cache

  -- NoC to cache
  signal llc_req_in_ready            : std_ulogic;
  signal llc_req_in_valid            : std_ulogic;
  signal llc_req_in_data_coh_msg     : mix_msg_t;
  signal llc_req_in_data_hprot       : hprot_t;
  signal llc_req_in_data_addr        : line_addr_t;
  signal llc_req_in_data_word_offset : word_offset_t;
  signal llc_req_in_data_valid_words : word_offset_t;
  signal llc_req_in_data_line        : line_t;
  signal llc_req_in_data_req_id      : cache_id_t;

  signal llc_dma_req_in_ready            : std_ulogic;
  signal llc_dma_req_in_valid            : std_ulogic;
  signal llc_dma_req_in_data_coh_msg     : mix_msg_t;
  signal llc_dma_req_in_data_hprot       : hprot_t;
  signal llc_dma_req_in_data_addr        : line_addr_t;
  signal llc_dma_req_in_data_word_offset : word_offset_t;
  signal llc_dma_req_in_data_valid_words : word_offset_t;
  signal llc_dma_req_in_data_line        : line_t;
  signal llc_dma_req_in_data_req_id      : llc_coh_dev_id_t;

  signal llc_rsp_in_ready        : std_ulogic;
  signal llc_rsp_in_valid        : std_ulogic;
  signal llc_rsp_in_data_coh_msg : coh_msg_t;
  signal llc_rsp_in_data_addr    : line_addr_t;
  signal llc_rsp_in_data_line    : line_t;
  signal llc_rsp_in_data_req_id  : cache_id_t;

  -- cache to NoC
  signal llc_rsp_out_ready            : std_ulogic;
  signal llc_rsp_out_valid            : std_ulogic;
  signal llc_rsp_out_data_coh_msg     : coh_msg_t;
  signal llc_rsp_out_data_addr        : line_addr_t;
  signal llc_rsp_out_data_line        : line_t;
  signal llc_rsp_out_data_invack_cnt  : invack_cnt_t;
  signal llc_rsp_out_data_req_id      : cache_id_t;
  signal llc_rsp_out_data_dest_id     : cache_id_t;
  signal llc_rsp_out_data_word_offset : word_offset_t;

  signal llc_dma_rsp_out_ready            : std_ulogic;
  signal llc_dma_rsp_out_valid            : std_ulogic;
  signal llc_dma_rsp_out_data_coh_msg     : coh_msg_t;
  signal llc_dma_rsp_out_data_addr        : line_addr_t;
  signal llc_dma_rsp_out_data_line        : line_t;
  signal llc_dma_rsp_out_data_invack_cnt  : invack_cnt_t;
  signal llc_dma_rsp_out_data_req_id      : llc_coh_dev_id_t;
  signal llc_dma_rsp_out_data_dest_id     : cache_id_t;  -- not used
  signal llc_dma_rsp_out_data_word_offset : word_offset_t;

  signal llc_fwd_out_ready        : std_ulogic;
  signal llc_fwd_out_valid        : std_ulogic;
  signal llc_fwd_out_data_coh_msg : mix_msg_t;
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

  -- statistics
  signal llc_stats_ready : std_ulogic;
  signal llc_stats_valid : std_ulogic;
  signal llc_stats_data  : std_ulogic;
  
  --signal led_wrapper_asserts : std_ulogic;

  constant nl2_bits : integer := log2(nl2);
  subtype sharers_t is std_logic_vector(nl2 - 1 downto 0);
  subtype owner_t is std_logic_vector(get_owner_bits(nl2_bits) - 1 downto 0);

  -- cache flush and soft reset
  signal llc_flush_resetn_req     : std_ulogic;
  signal llc_flush_resetn         : std_ulogic;
  signal llc_flush_resetn_ack     : std_ulogic;
  signal llc_flush_resetn_done    : std_ulogic;
  type llc_cmd_state_t is (idle, do_cmd, pending_cmd, wait_irq_clear);
  signal llc_cmd_state, llc_cmd_next : llc_cmd_state_t;

-----------------------------------------------------------------------------
-- APB slave signals
-----------------------------------------------------------------------------

  -- Register bank
  signal cmd_reg       : std_logic_vector(31 downto 0);
  signal status_reg    : std_logic_vector(31 downto 0);
  signal cmd_in        : std_logic_vector(31 downto 0);
  signal cmd_sample    : std_ulogic;
  signal readdata      : std_logic_vector(31 downto 0);

-----------------------------------------------------------------------------
-- AHB master FSM signals
-----------------------------------------------------------------------------
  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_SLD, SLD_LLC_CACHE, 0, 0, 0),
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

  signal ahbm_reg      : ahbm_reg_type;
  signal ahbm_reg_next : ahbm_reg_type;

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
  type rsp_out_fsm is (send_header, send_header_stall, send_addr, send_data);

  type dma_rsp_out_fsm is (send_header, send_header_dma_stall, send_data_dma);

  type rsp_out_reg_type is record
    state      : rsp_out_fsm;
    coh_msg    : coh_msg_t;
    addr       : line_addr_t;
    woffset    : word_offset_t;
    line       : line_t;
    word_cnt   : natural range 0 to 3;
    invack_cnt : invack_cnt_t;
    dest_x     : local_yx;
    dest_y     : local_yx;
    reserved   : reserved_field_type;
    stall      : std_ulogic;
    asserts    : asserts_rsp_out_t;
  end record rsp_out_reg_type;

  type dma_rsp_out_reg_type is record
    state      : dma_rsp_out_fsm;
    coh_msg    : coh_msg_t;
    addr       : line_addr_t;
    woffset    : word_offset_t;
    line       : line_t;
    word_cnt   : natural range 0 to 3;
    invack_cnt : invack_cnt_t;
    dest_x     : local_yx;
    dest_y     : local_yx;
    reserved   : reserved_field_type;
    stall      : std_ulogic;
    asserts    : asserts_rsp_out_t;
  end record dma_rsp_out_reg_type;

  constant RSP_OUT_REG_DEFAULT : rsp_out_reg_type := (
    state      => send_header,
    coh_msg    => (others => '0'),
    addr       => (others => '0'),
    woffset    => (others => '0'),
    line       => (others => '0'),
    word_cnt   => 0,
    invack_cnt => (others => '0'),
    dest_x     => (others => '0'),
    dest_y     => (others => '0'),
    reserved   => (others => '0'),
    stall      => '0',
    asserts    => (others => '0'));

  constant DMA_RSP_OUT_REG_DEFAULT : dma_rsp_out_reg_type := (
    state      => send_header,
    coh_msg    => (others => '0'),
    addr       => (others => '0'),
    woffset    => (others => '0'),
    line       => (others => '0'),
    word_cnt   => 0,
    invack_cnt => (others => '0'),
    dest_x     => (others => '0'),
    dest_y     => (others => '0'),
    reserved   => (others => '0'),
    stall      => '0',
    asserts    => (others => '0'));

  signal rsp_out_reg      : rsp_out_reg_type;
  signal rsp_out_reg_next : rsp_out_reg_type;

  signal dma_rsp_out_reg      : dma_rsp_out_reg_type;
  signal dma_rsp_out_reg_next : dma_rsp_out_reg_type;

  -------------------------------------------------------------------------------
  -- FSM: Request from NoC
  -------------------------------------------------------------------------------
  type req_in_fsm is (rcv_header, rcv_addr, rcv_data);

  type dma_req_in_fsm is (rcv_header, rcv_addr_dma, rcv_length_dma, rcv_data_dma);

  type req_in_reg_type is record
    state    : req_in_fsm;
    coh_msg  : mix_msg_t;
    hprot    : hprot_t;
    addr     : line_addr_t;
    woffset  : word_offset_t;
    line     : line_t;
    req_id   : cache_id_t;
    word_cnt : natural range 0 to 3;
    origin_x : local_yx;
    origin_y : local_yx;
    tile_id  : integer;
    asserts  : asserts_req_t;
  end record req_in_reg_type;

  type dma_req_in_reg_type is record
    state    : dma_req_in_fsm;
    coh_msg  : mix_msg_t;
    hprot    : hprot_t;
    addr     : line_addr_t;
    woffset  : word_offset_t;
    line     : line_t;
    req_id   : llc_coh_dev_id_t;
    word_cnt : natural range 0 to 3;
    origin_x : local_yx;
    origin_y : local_yx;
    tile_id  : integer;
    asserts  : asserts_req_t;
  end record dma_req_in_reg_type;

  constant REQ_IN_REG_DEFAULT : req_in_reg_type := (
    state    => rcv_header,
    coh_msg  => (others => '0'),
    hprot    => (others => '0'),
    addr     => (others => '0'),
    woffset  => (others => '0'),
    line     => (others => '0'),
    req_id   => (others => '0'),
    word_cnt => 0,
    origin_x => (others => '0'),
    origin_y => (others => '0'),
    tile_id  => 0,
    asserts  => (others => '0'));

  constant DMA_REQ_IN_REG_DEFAULT : dma_req_in_reg_type := (
    state    => rcv_header,
    coh_msg  => (others => '0'),
    hprot    => (others => '0'),
    addr     => (others => '0'),
    woffset  => (others => '0'),
    line     => (others => '0'),
    req_id   => (others => '0'),
    word_cnt => 0,
    origin_x => (others => '0'),
    origin_y => (others => '0'),
    tile_id  => 0,
    asserts  => (others => '0'));

  signal req_in_reg      : req_in_reg_type;
  signal req_in_reg_next : req_in_reg_type;

  signal dma_req_in_reg      : dma_req_in_reg_type;
  signal dma_req_in_reg_next : dma_req_in_reg_type;

  -------------------------------------------------------------------------------
  -- FSM: Response from NoC
  -------------------------------------------------------------------------------
  type rsp_in_fsm is (rcv_header, rcv_addr, snd_invack, rcv_data);

  type rsp_in_reg_type is record
    state    : rsp_in_fsm;
    coh_msg  : noc_msg_type;
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
    coh_msg  => (others => '0'),
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

  constant empty_offset : std_logic_vector(OFFSET_BITS - 1 downto 0) := (others => '0');

  -------------------------------------------------------------------------------
  -- Debug
  -------------------------------------------------------------------------------

  signal ahbm_asserts : asserts_llc_ahbm_t;

  signal ahbm_reg_state : ahbm_fsm;
  signal fwd_out_state  : fwd_out_fsm;
  signal rsp_out_state  : rsp_out_fsm;
  signal req_in_state   : req_in_fsm;
  signal rsp_in_state   : rsp_in_fsm;

  -- attribute mark_debug : string;

  -- attribute mark_debug of llc_req_in_ready            : signal is "true";
  -- attribute mark_debug of llc_req_in_valid            : signal is "true";
  -- attribute mark_debug of llc_req_in_data_coh_msg     : signal is "true";
  -- attribute mark_debug of llc_req_in_data_hprot       : signal is "true";
  -- attribute mark_debug of llc_req_in_data_addr        : signal is "true";
  -- attribute mark_debug of llc_req_in_data_word_offset : signal is "true";
  -- attribute mark_debug of llc_req_in_data_valid_words : signal is "true";
  -- attribute mark_debug of llc_req_in_data_line        : signal is "true";
  -- attribute mark_debug of llc_req_in_data_req_id      : signal is "true";

  -- attribute mark_debug of llc_dma_req_in_ready            : signal is "true";
  -- attribute mark_debug of llc_dma_req_in_valid            : signal is "true";
  -- attribute mark_debug of llc_dma_req_in_data_coh_msg     : signal is "true";
  -- attribute mark_debug of llc_dma_req_in_data_hprot       : signal is "true";
  -- attribute mark_debug of llc_dma_req_in_data_addr        : signal is "true";
  -- attribute mark_debug of llc_dma_req_in_data_word_offset : signal is "true";
  -- attribute mark_debug of llc_dma_req_in_data_valid_words : signal is "true";
  -- attribute mark_debug of llc_dma_req_in_data_line        : signal is "true";
  -- attribute mark_debug of llc_dma_req_in_data_req_id      : signal is "true";

  -- attribute mark_debug of llc_rsp_in_ready        : signal is "true";
  -- attribute mark_debug of llc_rsp_in_valid        : signal is "true";
  -- attribute mark_debug of llc_rsp_in_data_coh_msg : signal is "true";
  -- attribute mark_debug of llc_rsp_in_data_addr    : signal is "true";
  -- -- attribute mark_debug of llc_rsp_in_data_line   : signal is "true";
  -- attribute mark_debug of llc_rsp_in_data_req_id  : signal is "true";

  -- attribute mark_debug of llc_rsp_out_ready            : signal is "true";
  -- attribute mark_debug of llc_rsp_out_valid            : signal is "true";
  -- attribute mark_debug of llc_rsp_out_data_coh_msg     : signal is "true";
  -- attribute mark_debug of llc_rsp_out_data_addr        : signal is "true";
  -- attribute mark_debug of llc_rsp_out_data_line        : signal is "true";
  -- attribute mark_debug of llc_rsp_out_data_invack_cnt  : signal is "true";
  -- attribute mark_debug of llc_rsp_out_data_req_id      : signal is "true";
  -- attribute mark_debug of llc_rsp_out_data_dest_id     : signal is "true";
  -- attribute mark_debug of llc_rsp_out_data_word_offset : signal is "true";

  -- attribute mark_debug of llc_dma_rsp_out_ready            : signal is "true";
  -- attribute mark_debug of llc_dma_rsp_out_valid            : signal is "true";
  -- attribute mark_debug of llc_dma_rsp_out_data_coh_msg     : signal is "true";
  -- attribute mark_debug of llc_dma_rsp_out_data_addr        : signal is "true";
  -- attribute mark_debug of llc_dma_rsp_out_data_line        : signal is "true";
  -- attribute mark_debug of llc_dma_rsp_out_data_invack_cnt  : signal is "true";
  -- attribute mark_debug of llc_dma_rsp_out_data_req_id      : signal is "true";
  -- attribute mark_debug of llc_dma_rsp_out_data_dest_id     : signal is "true";
  -- attribute mark_debug of llc_dma_rsp_out_data_word_offset : signal is "true";

  -- attribute mark_debug of llc_fwd_out_ready        : signal is "true";
  -- attribute mark_debug of llc_fwd_out_valid        : signal is "true";
  -- attribute mark_debug of llc_fwd_out_data_coh_msg : signal is "true";
  -- attribute mark_debug of llc_fwd_out_data_addr    : signal is "true";
  -- attribute mark_debug of llc_fwd_out_data_req_id  : signal is "true";
  -- attribute mark_debug of llc_fwd_out_data_dest_id : signal is "true";

  -- attribute mark_debug of llc_mem_rsp_ready : signal is "true";
  -- attribute mark_debug of llc_mem_rsp_valid : signal is "true";
  -- -- attribute mark_debug of llc_mem_rsp_data_line : signal is "true";

  -- attribute mark_debug of llc_mem_req_ready       : signal is "true";
  -- attribute mark_debug of llc_mem_req_valid       : signal is "true";
  -- attribute mark_debug of llc_mem_req_data_hwrite : signal is "true";
  -- attribute mark_debug of llc_mem_req_data_hsize  : signal is "true";
  -- attribute mark_debug of llc_mem_req_data_hprot  : signal is "true";
  -- attribute mark_debug of llc_mem_req_data_addr   : signal is "true";
  -- attribute mark_debug of llc_mem_req_data_line   : signal is "true";

  -- -- attribute mark_debug of llc_stats_ready         : signal is "true";
  -- -- attribute mark_debug of llc_stats_valid         : signal is "true";
  -- -- attribute mark_debug of llc_stats_data          : signal is "true";

  -- --attribute mark_debug of asserts    : signal is "true";
  -- --attribute mark_debug of bookmark   : signal is "true";
  -- --attribute mark_debug of custom_dbg : signal is "true";

  -- -- attribute mark_debug of ahbm_asserts : signal is "true";

  -- attribute mark_debug of llc_cmd_state : signal is "true";
  -- attribute mark_debug of llc_cmd_next  : signal is "true";
  -- attribute mark_debug of cmd_reg       : signal is "true";
  -- attribute mark_debug of status_reg    : signal is "true";
  -- attribute mark_debug of cmd_in        : signal is "true";
  -- attribute mark_debug of cmd_sample    : signal is "true";
  -- attribute mark_debug of readdata      : signal is "true";

  -- attribute mark_debug of ahbm_reg_state : signal is "true";
  -- attribute mark_debug of fwd_out_state  : signal is "true";
  -- attribute mark_debug of rsp_out_state  : signal is "true";
  -- attribute mark_debug of req_in_state   : signal is "true";
  -- attribute mark_debug of rsp_in_state   : signal is "true";

begin  -- architecture rtl
-------------------------------------------------------------------------------
-- APB slave interface (flush, soft reset)
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
      cmd_reg    <= (others => '0');
      status_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if llc_flush_resetn_done = '1' then
        status_reg(0) <= '1';
      end if;
      if cmd_reg(1 downto 0) = "00" then
        status_reg(0) <= '0';
      end if;
      if cmd_sample = '1' then
        cmd_reg(1 downto 0) <= cmd_in(1 downto 0);
      end if;
    end if;
  end process cmd_status;

  -- Do flush/resetn
  llc_cmd_state_update: process (clk, rst) is
  begin  -- process llc_cmd_state_update
    if rst = '0' then                   -- asynchronous reset (active low)
      llc_cmd_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      llc_cmd_state <= llc_cmd_next;
    end if;
  end process llc_cmd_state_update;

  llc_cmd_state_fsm: process (llc_cmd_state, llc_flush_resetn_ack, llc_flush_resetn_done, cmd_reg) is
  begin  -- process llc_cmd_state_fsm
    llc_cmd_next <= llc_cmd_state;
    llc_flush_resetn_req <= '0';
    llc_flush_resetn     <= '0';

    case llc_cmd_state is
      when idle =>
        if cmd_reg(1 downto 0) /= "00" then
          -- Reset has priority over flush
          llc_flush_resetn <= (cmd_reg(1) and (not cmd_reg(0)));
          llc_flush_resetn_req <= '1';
          if llc_flush_resetn_ack = '1' then
            llc_cmd_next <= pending_cmd;
          else
            llc_cmd_next <= do_cmd;
          end if;
        end if;

      when do_cmd =>
        llc_flush_resetn <= (cmd_reg(1) and (not cmd_reg(0)));
        llc_flush_resetn_req <= '1';
        if llc_flush_resetn_ack = '1' then
          llc_cmd_next <= pending_cmd;
        end if;

      when pending_cmd =>
        if llc_flush_resetn_done = '1' then
          llc_cmd_next <= wait_irq_clear;
        end if;

      when wait_irq_clear =>
        if cmd_reg(1 downto 0) = "00" then
          llc_cmd_next <= idle;
        end if;

      when others =>
        llc_cmd_next <= idle;
    end case;

  end process llc_cmd_state_fsm;


-------------------------------------------------------------------------------
-- Static outputs: AHB master, NoC
-------------------------------------------------------------------------------

  ahbmo.hsize   <= HSIZE_WORD;
  ahbmo.hlock   <= '0';
  ahbmo.hirq    <= (others => '0');
  ahbmo.hconfig <= hconfig;
  ahbmo.hindex  <= hindex;
  ahbmo.hburst  <= HBURST_INCR;

  llc_stats_ready <= '1';
  mon_cache.clk  <= clk;
  mon_cache.miss <= llc_stats_valid and (not llc_stats_data);
  mon_cache.hit  <= llc_stats_valid and llc_stats_data;

-------------------------------------------------------------------------------
-- State update for all the FSMs
-------------------------------------------------------------------------------
  fsms_state_update : process (clk, rst)
  begin
    if rst = '0' then
      ahbm_reg    <= AHBM_REG_DEFAULT;
      req_in_reg  <= REQ_IN_REG_DEFAULT;
      dma_req_in_reg  <= DMA_REQ_IN_REG_DEFAULT;
      rsp_in_reg  <= RSP_IN_REG_DEFAULT;
      fwd_out_reg <= FWD_OUT_REG_DEFAULT;
      rsp_out_reg <= RSP_OUT_REG_DEFAULT;
      dma_rsp_out_reg <= DMA_RSP_OUT_REG_DEFAULT;
    elsif clk'event and clk = '1' then
      ahbm_reg    <= ahbm_reg_next;
      req_in_reg  <= req_in_reg_next;
      dma_req_in_reg  <= dma_req_in_reg_next;
      rsp_in_reg  <= rsp_in_reg_next;
      fwd_out_reg <= fwd_out_reg_next;
      rsp_out_reg <= rsp_out_reg_next;
      dma_rsp_out_reg <= dma_rsp_out_reg_next;
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

          ahbmo.hbusreq                         <= '1';
          ahbmo.htrans                          <= HTRANS_NONSEQ;
          ahbmo.hwrite                          <= '0';
          ahbmo.haddr                           <= reg.haddr;
          ahbmo.hprot(HPROT_WIDTH - 1 downto 0) <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.word_cnt := reg.word_cnt + 1;
            reg.haddr    := reg.haddr + GLOB_ADDR_INCR;
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

          ahbmo.hbusreq                         <= '1';  -- put to 0 when WORDS_PER_LINE - 1
          ahbmo.htrans                          <= HTRANS_SEQ;
          ahbmo.hwrite                          <= '0';
          ahbmo.haddr                           <= reg.haddr;
          ahbmo.hprot(HPROT_WIDTH - 1 downto 0) <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.line(reg.word_cnt*BITS_PER_WORD-1 downto (reg.word_cnt-1)*BITS_PER_WORD) := ahbmi.hrdata;
            reg.word_cnt                                                                 := reg.word_cnt + 1;
            reg.haddr                                                                    := reg.haddr  + GLOB_ADDR_INCR;
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

          ahbmo.hbusreq                         <= '1';
          ahbmo.htrans                          <= HTRANS_NONSEQ;
          ahbmo.hwrite                          <= '1';
          ahbmo.haddr                           <= reg.haddr;
          ahbmo.hprot(HPROT_WIDTH - 1 downto 0) <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.word_cnt := reg.word_cnt + 1;
            reg.haddr    := reg.haddr  + GLOB_ADDR_INCR;
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

          ahbmo.hbusreq                         <= '1';
          ahbmo.htrans                          <= HTRANS_SEQ;
          ahbmo.hwrite                          <= '1';
          ahbmo.haddr                           <= reg.haddr;
          ahbmo.hprot(HPROT_WIDTH - 1 downto 0) <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.word_cnt := reg.word_cnt + 1;
            reg.haddr    := reg.haddr  + GLOB_ADDR_INCR;
          end if;

        end if;

    end case;

    ahbm_reg_next <= reg;

  end process fsm_ahbm;

-----------------------------------------------------------------------------
-- FSM: Requests from NoC (from private caches only)
-----------------------------------------------------------------------------
  fsm_req_in : process (req_in_reg, llc_req_in_ready,
                        coherence_req_empty, coherence_req_data_out) is

    variable reg      : req_in_reg_type;
    variable msg_type : noc_msg_type;
    variable reserved : reserved_field_type;
    variable preamble : noc_preamble_type;

  begin  -- process fsm_req_in
    -- initialize variables
    reg         := req_in_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (send to cache)
    llc_req_in_valid            <= '0';
    llc_req_in_data_coh_msg     <= (others => '0');
    llc_req_in_data_hprot       <= (others => '0');
    llc_req_in_data_addr        <= (others => '0');
    llc_req_in_data_word_offset <= (others => '0');
    llc_req_in_data_valid_words <= (others => '0');
    llc_req_in_data_line        <= (others => '0');
    llc_req_in_data_req_id      <= (others => '0');

    -- initialize signals toward noc (receive from noc)
    coherence_req_rdreq <= '0';

    -- incoming NoC messages parsing
    preamble     := get_preamble(NOC_FLIT_SIZE, coherence_req_data_out);

    -- fsm states
    case reg.state is

      -- RECEIVE HEADER
      when rcv_header =>

        -- coherence requests
        if coherence_req_empty = '0' and preamble(1) = '1' then

          coherence_req_rdreq <= '1';

          reg.coh_msg := get_msg_type(NOC_FLIT_SIZE, coherence_req_data_out);
          reserved    := get_reserved_field(NOC_FLIT_SIZE, coherence_req_data_out);
          reg.hprot   := reserved(HPROT_WIDTH - 1 downto 0);

          reg.origin_x                                              := get_origin_x(NOC_FLIT_SIZE, coherence_req_data_out);
          reg.origin_y                                              := get_origin_y(NOC_FLIT_SIZE, coherence_req_data_out);
          if unsigned(reg.origin_x) >= 0 and unsigned(reg.origin_x) <= noc_xlen and
             unsigned(reg.origin_y) >= 0 and unsigned(reg.origin_y) <= noc_xlen
          then

            reg.tile_id := to_integer(unsigned(reg.origin_x)) +
                           to_integer(unsigned(reg.origin_y)) * noc_xlen;

            if tile_cache_id(reg.tile_id) >= 0 then
              reg.req_id := std_logic_vector(to_unsigned(tile_cache_id(reg.tile_id), NL2_MAX_LOG2));
            end if;

          end if;

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>

        if coherence_req_empty = '0' then

          if reg.coh_msg = REQ_PUTM then

            coherence_req_rdreq <= '1';

            reg.addr     := coherence_req_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
            reg.word_cnt := 0;
            reg.state    := rcv_data;

          elsif llc_req_in_ready = '1' then

            coherence_req_rdreq <= '1';

            llc_req_in_valid        <= '1';
            llc_req_in_data_coh_msg <= reg.coh_msg;
            llc_req_in_data_addr    <= coherence_req_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
            llc_req_in_data_hprot   <= reg.hprot;
            llc_req_in_data_req_id  <= reg.req_id;

            reg.state := rcv_header;

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
-- FSM: Requests from NoC (from DMA controllers only)
-----------------------------------------------------------------------------
  fsm_dma_req_in : process (dma_req_in_reg, llc_dma_req_in_ready,
                            dma_rcv_data_out, dma_rcv_empty) is

    variable reg          : dma_req_in_reg_type;
    variable msg_type     : noc_msg_type;
    variable reserved     : reserved_field_type;
    variable dma_preamble : noc_preamble_type;

  begin  -- process fsm_dma_req_in
    -- initialize variables
    reg         := dma_req_in_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (send to cache)
    llc_dma_req_in_valid            <= '0';
    llc_dma_req_in_data_coh_msg     <= (others => '0');
    llc_dma_req_in_data_hprot       <= (others => '0');
    llc_dma_req_in_data_addr        <= (others => '0');
    llc_dma_req_in_data_word_offset <= (others => '0');
    llc_dma_req_in_data_valid_words <= (others => '0');
    llc_dma_req_in_data_line        <= (others => '0');
    llc_dma_req_in_data_req_id      <= (others => '0');

    -- initialize signals toward noc (receive from noc)
    dma_rcv_rdreq       <= '0';

    -- incoming NoC messages parsing
    dma_preamble := get_preamble(NOC_FLIT_SIZE, dma_rcv_data_out);

    -- fsm states
    case reg.state is

      -- RECEIVE HEADER
      when rcv_header =>

        -- dma requests coherent with LLC
        if dma_rcv_empty = '0' and dma_preamble(1) = '1' then

          dma_rcv_rdreq <= '1';

          reg.coh_msg := get_msg_type(NOC_FLIT_SIZE, dma_rcv_data_out);

          reg.origin_x := get_origin_x(NOC_FLIT_SIZE, dma_rcv_data_out);
          reg.origin_y := get_origin_y(NOC_FLIT_SIZE, dma_rcv_data_out);

          if unsigned(reg.origin_x) >= 0 and unsigned(reg.origin_x) <= noc_xlen and
             unsigned(reg.origin_y) >= 0 and unsigned(reg.origin_y) <= noc_xlen
          then
            reg.tile_id := to_integer(unsigned(reg.origin_x)) +
                           to_integer(unsigned(reg.origin_y)) * noc_xlen;

            if tile_dma_id(reg.tile_id) >= 0 then
              reg.req_id := std_logic_vector(to_unsigned(tile_dma_id(reg.tile_id), NLLC_MAX_LOG2));
            end if;

          end if;

          reg.state := rcv_addr_dma;

        end if;

      -- RECEIVE ADDRESS DMA
      when rcv_addr_dma =>

        if dma_rcv_empty = '0' then

          dma_rcv_rdreq <= '1';

          reg.addr    := dma_rcv_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
          reg.woffset := dma_rcv_data_out(W_OFF_RANGE_HI downto W_OFF_RANGE_LO);
          reg.line    := (others => '0');

          if reg.coh_msg = REQ_DMA_READ then

            reg.state := rcv_length_dma;

          else

            reg.word_cnt := to_integer(unsigned(reg.woffset));
            reg.state    := rcv_data_dma;

          end if;

        end if;

      -- RECEIVE DMA READ LENGTH
      when rcv_length_dma =>

        if dma_rcv_empty = '0' then

          if llc_dma_req_in_ready = '1' then

            dma_rcv_rdreq <= '1';

            llc_dma_req_in_valid            <= '1';
            llc_dma_req_in_data_coh_msg     <= reg.coh_msg;
            llc_dma_req_in_data_addr        <= reg.addr;
            llc_dma_req_in_data_word_offset <= reg.woffset;
            llc_dma_req_in_data_req_id      <= reg.req_id;
            -- Save DMA read length to most significant word in line field
            reg.line(BITS_PER_LINE - 1 downto BITS_PER_LINE - ADDR_BITS) := dma_rcv_data_out(ADDR_BITS -1 downto 0);
            llc_dma_req_in_data_line <= reg.line;

            reg.state := rcv_header;

          end if;

        end if;

      -- RECEIVE DMA WRITE DATA
      when rcv_data_dma =>

        if dma_rcv_empty = '0' then

          if reg.word_cnt = WORDS_PER_LINE - 1 or dma_preamble = PREAMBLE_TAIL then

            if llc_dma_req_in_ready = '1' then

              dma_rcv_rdreq <= '1';

              reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                       BITS_PER_WORD * reg.word_cnt) :=
                dma_rcv_data_out(BITS_PER_WORD - 1 downto 0);

              llc_dma_req_in_valid            <= '1';
              llc_dma_req_in_data_coh_msg     <= reg.coh_msg;
              llc_dma_req_in_data_addr        <= reg.addr;
              llc_dma_req_in_data_word_offset <= reg.woffset;
              llc_dma_req_in_data_valid_words <= std_logic_vector(to_unsigned(reg.word_cnt, WORD_OFFSET_BITS)) - reg.woffset;
              llc_dma_req_in_data_line        <= reg.line;
              llc_dma_req_in_data_req_id      <= reg.req_id;

              -- Let LLC know it's the last line to be written
              if dma_preamble = PREAMBLE_TAIL then

                llc_dma_req_in_data_hprot(0) <= '1';

                reg.state := rcv_header;

              end if;

              reg.word_cnt := 0;
              reg.woffset  := (others => '0');

            end if;

          else

            dma_rcv_rdreq <= '1';

            reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                     (BITS_PER_WORD * reg.word_cnt)) :=
              dma_rcv_data_out(BITS_PER_WORD - 1 downto 0);

            reg.word_cnt := reg.word_cnt + 1;

          end if;

        end if;

    end case;

    dma_req_in_reg_next <= reg;

  end process fsm_dma_req_in;


-----------------------------------------------------------------------------
-- FSM: Responses from NoC
-----------------------------------------------------------------------------
  fsm_rsp_in : process (rsp_in_reg, llc_rsp_in_ready,
                        coherence_rsp_rcv_empty, coherence_rsp_rcv_data_out) is

    variable reg : rsp_in_reg_type;
    variable msg : noc_msg_type;
    variable preamble : noc_preamble_type;
    
  begin  -- process fsm_rsp_in
    -- initialize variables
    reg         := rsp_in_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (send to cache)
    llc_rsp_in_valid        <= '0';
    llc_rsp_in_data_coh_msg <= (others => '0');
    llc_rsp_in_data_addr    <= (others => '0');
    llc_rsp_in_data_line    <= (others => '0');
    llc_rsp_in_data_req_id  <= (others => '0');

    -- initialize signals toward noc (receive from noc)
    coherence_rsp_rcv_rdreq <= '0';

    -- incoming NoC messages parsing
    preamble     := get_preamble(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);

    -- fsm states
    case reg.state is

      -- RECEIVE HEADER
      when rcv_header =>

        if coherence_rsp_rcv_empty = '0' and preamble(1) = '1' then

          coherence_rsp_rcv_rdreq <= '1';

          reg.coh_msg := get_msg_type(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);
          reg.origin_x := get_origin_x(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);
          reg.origin_y := get_origin_y(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);

          if unsigned(reg.origin_x) >= 0 and unsigned(reg.origin_x) <= noc_xlen and
             unsigned(reg.origin_y) >= 0 and unsigned(reg.origin_y) <= noc_xlen
          then
            reg.tile_id := to_integer(unsigned(reg.origin_x)) + to_integer(unsigned(reg.origin_y)) * noc_xlen;
            if tile_cache_id(reg.tile_id) >= 0 then
              reg.req_id := std_logic_vector(to_unsigned(tile_cache_id(reg.tile_id), NL2_MAX_LOG2));
            end if;
          end if;

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>
        if coherence_rsp_rcv_empty = '0' then

          coherence_rsp_rcv_rdreq <= '1';

            reg.addr := coherence_rsp_rcv_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);

          if reg.coh_msg = RSP_DATA then
          
            reg.word_cnt := 0;
            reg.state    := rcv_data;

          else

            llc_rsp_in_valid        <= '1';
            llc_rsp_in_data_coh_msg <= reg.coh_msg(COH_MSG_TYPE_WIDTH - 1 downto 0);
            llc_rsp_in_data_addr    <= reg.addr;
            llc_rsp_in_data_req_id  <= reg.req_id;

            if llc_rsp_in_ready = '1' then

              reg.state := rcv_header;
                          
            else

              reg.state := snd_invack;
                
            end if;

          end if;

        end if;

      -- SEND RSP INVACK
      when snd_invack =>

        llc_rsp_in_valid        <= '1';
        llc_rsp_in_data_coh_msg <= reg.coh_msg(COH_MSG_TYPE_WIDTH - 1 downto 0);
        llc_rsp_in_data_addr    <= reg.addr;
        llc_rsp_in_data_req_id  <= reg.req_id;

        if llc_rsp_in_ready = '1' then

          reg.state := rcv_header;

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

              llc_rsp_in_valid        <= '1';
              llc_rsp_in_data_coh_msg <= reg.coh_msg(COH_MSG_TYPE_WIDTH - 1 downto 0);
              llc_rsp_in_data_addr    <= reg.addr;
              llc_rsp_in_data_line    <= reg.line;
              llc_rsp_in_data_req_id  <= reg.req_id;
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
                         llc_fwd_out_data_req_id, llc_fwd_out_data_dest_id,
                         local_y, local_x) is

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
    dest_x    := (others => '0');
    dest_y    := (others => '0');
    req_id    := (others => '0');

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
              dest_init := to_integer(unsigned(llc_fwd_out_data_dest_id));
              if dest_init >= 0 then
                dest_x := cache_x(dest_init);
                dest_y := cache_y(dest_init);
              end if;
            end if;

            req_id(RESERVED_WIDTH-1 downto llc_fwd_out_data_req_id'length) := (others => '0');
            req_id(llc_fwd_out_data_req_id'length - 1 downto 0)            := llc_fwd_out_data_req_id;

            coherence_fwd_wrreq <= '1';
            coherence_fwd_data_in <= create_header(NOC_FLIT_SIZE, local_y, local_x, dest_y, dest_x,
                                                   llc_fwd_out_data_coh_msg, req_id);

            reg.state := send_addr;

          end if;
        end if;

      -- SEND ADDRESS
      when send_addr =>
        if coherence_fwd_full = '0' then

          coherence_fwd_wrreq <= '1';
          coherence_fwd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
          coherence_fwd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
          reg.state := send_header;

        end if;

    end case;

    fwd_out_reg_next <= reg;

  end process fsm_fwd_out;

-------------------------------------------------------------------------------
-- FSM: Responses to NoC (to private caches only)
-------------------------------------------------------------------------------
  fsm_rsp_out : process (rsp_out_reg, coherence_rsp_snd_full,
                         llc_rsp_out_valid, llc_rsp_out_data_coh_msg, llc_rsp_out_data_addr,
                         llc_rsp_out_data_line, llc_rsp_out_data_invack_cnt, llc_rsp_out_data_word_offset,
                         llc_rsp_out_data_req_id, llc_rsp_out_data_dest_id,
                         local_y, local_x) is

    variable reg       : rsp_out_reg_type;
    variable dest_init : integer;
    variable dest_x    : local_yx;
    variable dest_y    : local_yx;
    variable reserved  : reserved_field_type;
    variable preamble  : noc_preamble_type;
    variable last_lv   : std_logic_vector(WORD_OFFSET_BITS - 1 downto 0);
    variable last      : integer range 0 to WORDS_PER_LINE - 1;

  begin  -- process fsm_rsp_out
    -- initialize variables
    reg         := rsp_out_reg;
    reg.asserts := (others => '0');

    last        := WORDS_PER_LINE - 1;
    last_lv     := std_logic_vector(to_unsigned(last, WORD_OFFSET_BITS));

    dest_init := 0;
    dest_x    := (others => '0');
    dest_y    := (others => '0');

    -- initialize signals toward cache (receive from cache)
    llc_rsp_out_ready <= '0';

    -- initialize signals toward noc
    coherence_rsp_snd_wrreq   <= '0';
    coherence_rsp_snd_data_in <= (others => '0');

    case reg.state is

      -- SEND HEADER
      when send_header =>

        llc_rsp_out_ready <= '1';

        if llc_rsp_out_valid = '1' then

          reg.coh_msg := llc_rsp_out_data_coh_msg;
          reg.addr    := llc_rsp_out_data_addr;
          reg.line    := llc_rsp_out_data_line;

          dest_init := to_integer(unsigned(llc_rsp_out_data_req_id));
          dest_x := cache_x(dest_init);
          dest_y := cache_y(dest_init);

          reserved := std_logic_vector(resize(unsigned(
            llc_rsp_out_data_invack_cnt), RESERVED_WIDTH));

          if coherence_rsp_snd_full = '0' then

            coherence_rsp_snd_wrreq <= '1';
            coherence_rsp_snd_data_in <=
              create_header(NOC_FLIT_SIZE, local_y, local_x, dest_y, dest_x,
                            '0' & reg.coh_msg, reserved);

            reg.state := send_addr;

          else

            reg.dest_x   := dest_x;
            reg.dest_y   := dest_y;
            reg.reserved := reserved;

            reg.state := send_header_stall;

          end if;

        end if;

      -- SEND HEADER STALL
      when send_header_stall =>

        if coherence_rsp_snd_full = '0' then

          coherence_rsp_snd_wrreq <= '1';
          coherence_rsp_snd_data_in <=
            create_header(NOC_FLIT_SIZE, local_y, local_x, reg.dest_y, reg.dest_x,
                          '0' & reg.coh_msg, reg.reserved);

          reg.state := send_addr;

        end if;

      -- SEND ADDRESS
      when send_addr =>
        if coherence_rsp_snd_full = '0' then

          coherence_rsp_snd_wrreq   <= '1';
          coherence_rsp_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
          coherence_rsp_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
          reg.state                 := send_data;
          reg.word_cnt              := 0;

        end if;

      -- SEND DATA
      when send_data =>

        if coherence_rsp_snd_full = '0' then

          coherence_rsp_snd_wrreq <= '1';

          if reg.word_cnt = WORDS_PER_LINE - 1 then

            coherence_rsp_snd_data_in <=
              PREAMBLE_TAIL & read_word(reg.line, reg.word_cnt);

            reg.state := send_header;

          else

            coherence_rsp_snd_data_in <=
              PREAMBLE_BODY & read_word(reg.line, reg.word_cnt);

            reg.word_cnt := reg.word_cnt + 1;

          end if;

        end if;

    end case;

    rsp_out_reg_next <= reg;

  end process fsm_rsp_out;

-------------------------------------------------------------------------------
-- FSM: Responses to NoC (to DMA controllers only)
-------------------------------------------------------------------------------
  dma_fsm_rsp_out : process (dma_rsp_out_reg, dma_snd_full,
                             llc_dma_rsp_out_valid, llc_dma_rsp_out_data_coh_msg, llc_dma_rsp_out_data_addr,
                             llc_dma_rsp_out_data_line, llc_dma_rsp_out_data_invack_cnt, llc_dma_rsp_out_data_word_offset,
                             llc_dma_rsp_out_data_req_id, llc_dma_rsp_out_data_dest_id,
                             local_y, local_x) is

    variable reg       : dma_rsp_out_reg_type;
    variable dest_init : integer;
    variable dest_x    : local_yx;
    variable dest_y    : local_yx;
    variable reserved  : reserved_field_type;
    variable preamble  : noc_preamble_type;
    variable last_lv   : std_logic_vector(WORD_OFFSET_BITS - 1 downto 0);
    variable last      : integer range 0 to WORDS_PER_LINE - 1;

  begin  -- process dma_fsm_rsp_out
    -- initialize variables
    reg         := dma_rsp_out_reg;
    reg.asserts := (others => '0');

    last        := WORDS_PER_LINE - 1;
    last_lv     := std_logic_vector(to_unsigned(last, WORD_OFFSET_BITS));

    dest_init := 0;
    dest_x    := (others => '0');
    dest_y    := (others => '0');

    -- initialize signals toward cache (receive from cache)
    llc_dma_rsp_out_ready <= '0';

    -- initialize signals toward noc
    dma_snd_wrreq             <= '0';
    dma_snd_data_in           <= (others => '0');

    case reg.state is

      -- SEND HEADER
      when send_header =>

        llc_dma_rsp_out_ready <= '1';

        if llc_dma_rsp_out_valid = '1' then

          reg.coh_msg := llc_dma_rsp_out_data_coh_msg;
          reg.addr    := llc_dma_rsp_out_data_addr;
          reg.line    := llc_dma_rsp_out_data_line;
          -- invack_cnt(0) => DMA read last
          -- invack_cnt(WORD_OFFSET_BITS downto 1) => valid word count
          reg.invack_cnt := llc_dma_rsp_out_data_invack_cnt;
          reg.woffset    := llc_dma_rsp_out_data_word_offset;
          reg.word_cnt   := to_integer(unsigned(reg.woffset));

          if llc_dma_rsp_out_data_req_id >= "0" then
            dest_init := to_integer(unsigned(llc_dma_rsp_out_data_req_id));
            if dest_init >= 0 then
              dest_x := dma_x(dest_init);
              dest_y := dma_y(dest_init);
            end if;
          end if;

          --reserved := std_logic_vector(0, RESERVED_WIDTH);

          if dma_snd_full = '0' then

            dma_snd_wrreq <= '1';
            dma_snd_data_in <= create_header(NOC_FLIT_SIZE, local_y, local_x, dest_y,
                                             dest_x, '0' & reg.coh_msg, (others => '0'));

            reg.state := send_data_dma;

          else

            reg.dest_x := dest_x;
            reg.dest_y := dest_y;

            reg.state := send_header_dma_stall;

          end if;

        end if;

      -- SEND HEADER DMA STALL
      when send_header_dma_stall =>

        if dma_snd_full = '0' then

          dma_snd_wrreq   <= '1';
          dma_snd_data_in <= create_header(NOC_FLIT_SIZE, local_y, local_x, reg.dest_y, reg.dest_x, '0' & reg.coh_msg, (others => '0'));

          reg.state := send_data_dma;

        end if;

      -- SEND DATA DMA
      when send_data_dma =>

        last_lv := reg.woffset + reg.invack_cnt(WORD_OFFSET_BITS downto 1);
        last    := to_integer(unsigned(last_lv));

        if reg.invack_cnt(0) = '1' and reg.word_cnt = last then
          preamble := PREAMBLE_TAIL;
        else
          preamble := PREAMBLE_BODY;
        end if;
        dma_snd_data_in <= preamble & read_word(reg.line, reg.word_cnt);

        if dma_snd_full = '0' then

          if reg.word_cnt = last then
            dma_snd_wrreq <= '1';       -- send last word from this cache line
            reg.word_cnt := 0;

            if reg.invack_cnt(0) = '0' then
              llc_dma_rsp_out_ready <= '1';  -- get new line from cache

              if llc_dma_rsp_out_valid = '1' then
                reg.line       := llc_dma_rsp_out_data_line;
                reg.invack_cnt := llc_dma_rsp_out_data_invack_cnt;
                reg.woffset    := llc_dma_rsp_out_data_word_offset;
                reg.stall      := '0';
              else
                reg.stall := '1';
              end if;

            else
              reg.state := send_header;  -- DMA read done
              reg.stall := '0';

            end if;

          else

            if reg.stall = '1' then
              llc_dma_rsp_out_ready <= '1';  -- get new line from cache

              if llc_dma_rsp_out_valid = '1' then
                reg.line       := llc_dma_rsp_out_data_line;
                reg.invack_cnt := llc_dma_rsp_out_data_invack_cnt;
                reg.woffset    := llc_dma_rsp_out_data_word_offset;
                reg.stall      := '0';
              end if;

            else
              dma_snd_wrreq   <= '1';   -- send current word from this cache line
              reg.word_cnt := reg.word_cnt + 1;

            end if;

          end if;

        end if;

    end case;

    dma_rsp_out_reg_next <= reg;

  end process dma_fsm_rsp_out;

-------------------------------------------------------------------------------
-- Instantiations
-------------------------------------------------------------------------------

  -- instantiation of llc cache on cpu tile
  llc_cache_i : llc
    generic map (
      use_rtl => CFG_CACHE_RTL,
      sets => sets,
      ways => ways)
    port map (
      clk => clk,
      rst => rst,

      llc_rst_tb_valid      => llc_flush_resetn_req,
      llc_rst_tb_data       => llc_flush_resetn,
      llc_rst_tb_ready      => llc_flush_resetn_ack,
      llc_rst_tb_done_valid => llc_flush_resetn_done,
      llc_rst_tb_done_data  => open,
      llc_rst_tb_done_ready => std_logic' ('1'),

      -- NoC to cache
      llc_req_in_ready        => llc_req_in_ready,
      llc_req_in_valid        => llc_req_in_valid,
      llc_req_in_data_coh_msg => llc_req_in_data_coh_msg,
      llc_req_in_data_hprot   => llc_req_in_data_hprot,
      llc_req_in_data_addr    => llc_req_in_data_addr,
      llc_req_in_data_line    => llc_req_in_data_line,
      llc_req_in_data_req_id  => llc_req_in_data_req_id,
      llc_req_in_data_word_offset => llc_req_in_data_word_offset,
      llc_req_in_data_valid_words => llc_req_in_data_valid_words,

      llc_dma_req_in_ready        => llc_dma_req_in_ready,
      llc_dma_req_in_valid        => llc_dma_req_in_valid,
      llc_dma_req_in_data_coh_msg => llc_dma_req_in_data_coh_msg,
      llc_dma_req_in_data_hprot   => llc_dma_req_in_data_hprot,
      llc_dma_req_in_data_addr    => llc_dma_req_in_data_addr,
      llc_dma_req_in_data_line    => llc_dma_req_in_data_line,
      llc_dma_req_in_data_req_id  => llc_dma_req_in_data_req_id,
      llc_dma_req_in_data_word_offset => llc_dma_req_in_data_word_offset,
      llc_dma_req_in_data_valid_words => llc_dma_req_in_data_valid_words,

      llc_rsp_in_ready        => llc_rsp_in_ready,
      llc_rsp_in_valid        => llc_rsp_in_valid,
      llc_rsp_in_data_coh_msg => llc_rsp_in_data_coh_msg,
      llc_rsp_in_data_addr    => llc_rsp_in_data_addr,
      llc_rsp_in_data_line    => llc_rsp_in_data_line,
      llc_rsp_in_data_req_id  => llc_rsp_in_data_req_id,

      -- cache to NoC
      llc_rsp_out_ready           => llc_rsp_out_ready,
      llc_rsp_out_valid           => llc_rsp_out_valid,
      llc_rsp_out_data_coh_msg    => llc_rsp_out_data_coh_msg,
      llc_rsp_out_data_addr       => llc_rsp_out_data_addr,
      llc_rsp_out_data_line       => llc_rsp_out_data_line,
      llc_rsp_out_data_invack_cnt => llc_rsp_out_data_invack_cnt,
      llc_rsp_out_data_req_id     => llc_rsp_out_data_req_id,
      llc_rsp_out_data_dest_id    => llc_rsp_out_data_dest_id,
      llc_rsp_out_data_word_offset => llc_rsp_out_data_word_offset,

      llc_dma_rsp_out_ready           => llc_dma_rsp_out_ready,
      llc_dma_rsp_out_valid           => llc_dma_rsp_out_valid,
      llc_dma_rsp_out_data_coh_msg    => llc_dma_rsp_out_data_coh_msg,
      llc_dma_rsp_out_data_addr       => llc_dma_rsp_out_data_addr,
      llc_dma_rsp_out_data_line       => llc_dma_rsp_out_data_line,
      llc_dma_rsp_out_data_invack_cnt => llc_dma_rsp_out_data_invack_cnt,
      llc_dma_rsp_out_data_req_id     => llc_dma_rsp_out_data_req_id,
      llc_dma_rsp_out_data_dest_id    => llc_dma_rsp_out_data_dest_id,
      llc_dma_rsp_out_data_word_offset => llc_dma_rsp_out_data_word_offset,

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
      llc_mem_req_data_line   => llc_mem_req_data_line,

      -- statistics
      llc_stats_ready         => llc_stats_ready,
      llc_stats_valid         => llc_stats_valid,
      llc_stats_data          => llc_stats_data
      );

-------------------------------------------------------------------------------
-- Debug
-------------------------------------------------------------------------------

  ahbm_reg_state   <= ahbm_reg.state;
  fwd_out_state    <= fwd_out_reg.state;
  rsp_out_state    <= rsp_out_reg.state;
  req_in_state     <= req_in_reg.state;
  rsp_in_state     <= rsp_in_reg.state;
  
  ahbm_asserts <= ahbm_reg.asserts;

  --led_wrapper_asserts <= or_reduce(ahbm_reg.asserts);

end architecture rtl;
