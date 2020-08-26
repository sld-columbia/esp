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
use work.cachepackage.all;              -- contains l2 cache component
use work.sldcommon.all;


entity l2_wrapper is
  generic (
    tech        : integer := virtex7;
    sets        : integer := 256;
    ways        : integer := 8;
    hindex_mst  : integer := 0;
    pindex      : integer range 0 to NAPBSLV - 1 := 6;
    pirq        : integer := 4;
    mem_hindex  : integer := 4;
    mem_hconfig : ahb_config_type;
    mem_num     : integer := 1;
    mem_info    : tile_mem_info_vector(0 to CFG_NMEM_TILE - 1);
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

    -- frontend (cache - AHB/CPU)
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type;
    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    apbi  : in  apb_slv_in_type;
    apbo  : out apb_slv_out_type;
    flush : in  std_ulogic;             -- flush request from CPU

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

    mon_cache                  : out monitor_cache_type
    );

end l2_wrapper;

architecture rtl of l2_wrapper is

  -- Interface with L2 cache

  -- AHB to cache
  signal cpu_req_ready          : std_ulogic;
  signal cpu_req_valid          : std_ulogic;
  signal cpu_req_data_cpu_msg   : cpu_msg_t;
  signal cpu_req_data_hsize     : hsize_t;
  signal cpu_req_data_hprot     : hprot_t;
  signal cpu_req_data_addr      : addr_t;
  signal cpu_req_data_word      : word_t;
  signal flush_ready            : std_ulogic;
  signal flush_valid            : std_ulogic;
  signal flush_data             : std_ulogic;
  -- cache to AHB
  signal rd_rsp_ready           : std_ulogic;
  signal rd_rsp_valid           : std_ulogic;
  signal rd_rsp_data_line       : line_t;
  signal inval_ready            : std_ulogic;
  signal inval_valid            : std_ulogic;
  signal inval_data             : line_addr_t;
  -- cache to NoC
  signal req_out_ready          : std_ulogic;
  signal req_out_valid          : std_ulogic;
  signal req_out_data_coh_msg   : coh_msg_t;
  signal req_out_data_hprot     : hprot_t;
  signal req_out_data_addr      : line_addr_t;
  signal req_out_data_line      : line_t;
  signal rsp_out_ready          : std_ulogic;
  signal rsp_out_valid          : std_ulogic;
  signal rsp_out_data_coh_msg   : coh_msg_t;
  signal rsp_out_data_req_id    : cache_id_t;
  signal rsp_out_data_to_req    : std_logic_vector(1 downto 0);
  signal rsp_out_data_addr      : line_addr_t;
  signal rsp_out_data_line      : line_t;
  -- NoC to cache
  signal fwd_in_ready           : std_ulogic;
  signal fwd_in_valid           : std_ulogic;
  signal fwd_in_data_coh_msg    : mix_msg_t;
  signal fwd_in_data_addr       : line_addr_t;
  signal fwd_in_data_req_id     : cache_id_t;
  signal rsp_in_valid           : std_ulogic;
  signal rsp_in_ready           : std_ulogic;
  signal rsp_in_data_coh_msg    : coh_msg_t;
  signal rsp_in_data_addr       : line_addr_t;
  signal rsp_in_data_line       : line_t;
  signal rsp_in_data_invack_cnt : invack_cnt_t;
  -- debug
  --signal asserts                : asserts_t;
  --signal bookmark               : bookmark_t;
  --signal custom_dbg             : custom_dbg_t;
  signal flush_done             : std_ulogic;
  -- statistics
  signal stats_ready            : std_ulogic;
  signal stats_valid            : std_ulogic;
  signal stats_data             : std_ulogic;

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
  type ahbs_fsm is (idle, load_req, load_rsp, load_alloc, store_req, flush_req, mem_req);

  type ahbs_reg_type is record
    state         : ahbs_fsm;
    cpu_msg       : cpu_msg_t;
    hsize         : hsize_t;
    hprot         : hprot_t;
    haddr         : addr_t;
    req_memorized : std_ulogic;
    asserts       : asserts_ahbs_t;
  end record;

  constant AHBS_REG_DEFAULT : ahbs_reg_type := (
    state         => idle,
    cpu_msg       => CPU_READ,          -- read
    hsize         => HSIZE_W,           -- 1 word
    hprot         => DEFAULT_HPROT,     -- bufferable, non cacheable
    haddr         => (others => '0'),
    req_memorized => '0',
    asserts       => (others => '0'));

  signal ahbs_reg      : ahbs_reg_type := AHBS_REG_DEFAULT;
  signal ahbs_reg_next : ahbs_reg_type := AHBS_REG_DEFAULT;

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

  signal ahbm_reg      : ahbm_reg_type := AHBM_REG_DEFAULT;
  signal ahbm_reg_next : ahbm_reg_type := AHBM_REG_DEFAULT;

  -- FIFO for invalidation addresses
  signal inv_fifo_rdreq        : std_ulogic;
  signal inv_fifo_wrreq        : std_ulogic;
  signal inv_fifo_data_in      : line_addr_t;
  signal inv_fifo_empty        : std_ulogic;
  signal inv_fifo_almost_empty : std_ulogic;
  signal inv_fifo_full         : std_ulogic;
  signal inv_fifo_data_out     : line_addr_t;

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

  signal req_reg      : req_reg_type := REQ_REG_DEFAULT;
  signal req_reg_next : req_reg_type := REQ_REG_DEFAULT;

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
  -- FSM: Forward from  NoC
  -------------------------------------------------------------------------------

  type fwd_in_fsm is (rcv_header, rcv_addr);

  type fwd_in_reg_type is record
    state   : fwd_in_fsm;
    coh_msg : mix_msg_t;
    req_id  : cache_id_t;
    asserts : asserts_fwd_t;
  end record fwd_in_reg_type;

  constant FWD_IN_REG_DEFAULT : fwd_in_reg_type := (
    state   => rcv_header,
    coh_msg => (others => '0'),
    req_id  => (others => '0'),
    asserts => (others => '0'));

  signal fwd_in_reg      : fwd_in_reg_type := FWD_IN_REG_DEFAULT;
  signal fwd_in_reg_next : fwd_in_reg_type := FWD_IN_REG_DEFAULT;

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
    word_cnt   : natural range 0 to 3;
    asserts    : asserts_rsp_in_t;
  end record rsp_in_reg_type;

  constant RSP_IN_REG_DEFAULT : rsp_in_reg_type := (
    state      => rcv_header,
    coh_msg    => (others => '0'),
    invack_cnt => (others => '0'),
    addr       => (others => '0'),
    line       => (others => '0'),
    word_cnt   => 0,
    asserts    => (others => '0'));

  signal rsp_in_reg      : rsp_in_reg_type := RSP_IN_REG_DEFAULT;
  signal rsp_in_reg_next : rsp_in_reg_type := RSP_IN_REG_DEFAULT;

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

  signal load_alloc_reg      : load_alloc_reg_type := LOAD_ALLOC_REG_DEFAULT;
  signal load_alloc_reg_next : load_alloc_reg_type := LOAD_ALLOC_REG_DEFAULT;


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

  -- attribute mark_debug : string;

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

  l2_cache_i : l2
    generic map (
      use_rtl => CFG_CACHE_RTL,
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
      l2_flush_ready            => flush_ready,
      l2_flush_valid            => flush_valid,
      l2_flush_data             => flush_data,
      -- cache to AHB
      l2_rd_rsp_ready           => rd_rsp_ready,
      l2_rd_rsp_valid           => rd_rsp_valid,
      l2_rd_rsp_data_line       => rd_rsp_data_line,
      l2_inval_ready            => inval_ready,
      l2_inval_valid            => inval_valid,
      l2_inval_data             => inval_data,
      -- cache to NoC
      l2_req_out_ready          => req_out_ready,
      l2_req_out_valid          => req_out_valid,
      l2_req_out_data_coh_msg   => req_out_data_coh_msg,
      l2_req_out_data_hprot     => req_out_data_hprot,
      l2_req_out_data_addr      => req_out_data_addr,
      l2_req_out_data_line      => req_out_data_line,
      l2_rsp_out_ready          => rsp_out_ready,
      l2_rsp_out_valid          => rsp_out_valid,
      l2_rsp_out_data_coh_msg   => rsp_out_data_coh_msg,
      l2_rsp_out_data_req_id    => rsp_out_data_req_id,
      l2_rsp_out_data_to_req    => rsp_out_data_to_req,
      l2_rsp_out_data_addr      => rsp_out_data_addr,
      l2_rsp_out_data_line      => rsp_out_data_line,
      -- NoC to cache
      l2_fwd_in_ready           => fwd_in_ready,
      l2_fwd_in_valid           => fwd_in_valid,
      l2_fwd_in_data_coh_msg    => fwd_in_data_coh_msg,
      l2_fwd_in_data_addr       => fwd_in_data_addr,
      l2_fwd_in_data_req_id     => fwd_in_data_req_id,
      l2_rsp_in_ready           => rsp_in_ready,
      l2_rsp_in_valid           => rsp_in_valid,
      l2_rsp_in_data_coh_msg    => rsp_in_data_coh_msg,
      l2_rsp_in_data_addr       => rsp_in_data_addr,
      l2_rsp_in_data_line       => rsp_in_data_line,
      l2_rsp_in_data_invack_cnt => rsp_in_data_invack_cnt,
      flush_done                => flush_done,
      l2_stats_ready            => stats_ready,
      l2_stats_valid            => stats_valid,
      l2_stats_data             => stats_data
      );

  Invalidate_fifo : fifo_custom
    generic map (
      depth => N_REQS + 12,             -- TODO: what size here?
      width => ADDR_BITS - OFFSET_BITS)
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

    case cmd_state is
      when idle =>
        if cmd_reg(1 downto 0) = "10" then
          cmd_next <= wait_l1_flush;
        end if;

      when wait_l1_flush =>
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

-------------------------------------------------------------------------------
-- Static outputs: AHB slave, AHB master, NoC
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
      ahbm_reg       <= AHBM_REG_DEFAULT;
      req_reg        <= REQ_REG_DEFAULT;
      rsp_out_reg    <= RSP_OUT_REG_DEFAULT;
      fwd_in_reg     <= FWD_IN_REG_DEFAULT;
      rsp_in_reg     <= RSP_IN_REG_DEFAULT;
      load_alloc_reg <= LOAD_ALLOC_REG_DEFAULT;

    elsif clk'event and clk = '1' then

      ahbs_reg       <= ahbs_reg_next;
      ahbm_reg       <= ahbm_reg_next;
      req_reg        <= req_reg_next;
      fwd_in_reg     <= fwd_in_reg_next;
      rsp_out_reg    <= rsp_out_reg_next;
      rsp_in_reg     <= rsp_in_reg_next;
      load_alloc_reg <= load_alloc_reg_next;

    end if;
  end process fsms_state_update;

-------------------------------------------------------------------------------
-- FSM: Bridge from AHB slave to L2 cache frontend input
-------------------------------------------------------------------------------
  flush_data  <= cmd_reg(2);           -- Flush data (0) / flush all (1)

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

    end case;

    ahbs_reg_next       <= reg;
    load_alloc_reg_next <= alloc_reg;

  end process fsm_ahbs;

-------------------------------------------------------------------------------
-- FSM: Bridge from L2 cache frontend output to AHB master (L1 invalidation)
-------------------------------------------------------------------------------
  -- put writes of invalidate addresses coming from the L2 cache into a FIFO
  inval_ready      <= inval_valid when inv_fifo_full = '0' else '0';  -- ADD
  inv_fifo_wrreq   <= inval_valid when inv_fifo_full = '0' else '0';  -- ADD
  inv_fifo_data_in <= inval_data;

  fsm_ahbm : process (ahbm_reg, ahbmi, inv_fifo_empty, inv_fifo_almost_empty, inv_fifo_data_out)

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
          ahbmo.haddr(LINE_RANGE_HI downto LINE_RANGE_LO) <= inv_fifo_data_out;
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
        ahbmo.haddr(LINE_RANGE_HI downto LINE_RANGE_LO) <= inv_fifo_data_out;
        ahbmo.haddr(OFFSET_BITS - 1 downto 0) <= (others => '0');

        if (granted = '1' and ahbmi.hready = '1') then
          reg.state := store_req;
        end if;

      -- STORE REQUEST
      when store_req =>
        ahbmo.hbusreq <= '1';
        ahbmo.hlock   <= '1';
        ahbmo.htrans  <= HTRANS_NONSEQ;
        ahbmo.haddr(LINE_RANGE_HI downto LINE_RANGE_LO)   <= inv_fifo_data_out;
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

-------------------------------------------------------------------------------
-- FSM: Requests to NoC
-------------------------------------------------------------------------------
  fsm_req : process (req_reg, coherence_req_full,
                     req_out_valid, req_out_data_coh_msg, req_out_data_hprot,
                     req_out_data_addr, req_out_data_line,
                     local_x, local_y) is

    variable reg    : req_reg_type;
    variable req_id : cache_id_t;

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
                                                 cache_x, cache_y);

            reg.state := send_addr;

          end if;
        end if;

      -- SEND ADDRESS
      when send_addr =>

        if coherence_req_full = '0' then

          coherence_req_wrreq <= '1';

          if '0' & reg.coh_msg = REQ_PUTM then

            coherence_req_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
            coherence_req_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state             := send_data;
            reg.word_cnt          := 0;

          else

            coherence_req_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
            coherence_req_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state             := send_header;

          end if;
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
                         local_x, local_y) is

    variable reg   : rsp_out_reg_type;
    variable hprot : hprot_t := (others => '0');

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
                                                     cache_x, cache_y);
            reg.state := send_addr;

          end if;
        end if;

      -- SEND ADDRESS
      when send_addr =>

        if coherence_rsp_snd_full = '0' then

          coherence_rsp_snd_wrreq <= '1';

          if '0' & reg.coh_msg = RSP_DATA then

            coherence_rsp_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
            coherence_rsp_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state                 := send_data;
            reg.word_cnt              := 0;

          else

            coherence_rsp_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
            coherence_rsp_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= reg.addr & empty_offset;
            reg.state                 := send_header;

          end if;
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

-----------------------------------------------------------------------------
-- FSM: Forwards from NoC
-----------------------------------------------------------------------------
  fsm_fwd_in : process (fwd_in_reg, fwd_in_ready,
                        coherence_fwd_empty, coherence_fwd_data_out) is

    variable reg          : fwd_in_reg_type;
    variable rsp_preamble : noc_preamble_type;
    variable msg_type     : noc_msg_type;
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

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>
        if coherence_fwd_empty = '0' and fwd_in_ready = '1' then

          coherence_fwd_rdreq <= '1';

          fwd_in_valid        <= '1';
          fwd_in_data_coh_msg <= reg.coh_msg;
          fwd_in_data_addr    <= coherence_fwd_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
          fwd_in_data_req_id  <= reg.req_id;

          reg.state := rcv_header;

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
    variable reserved     : reserved_field_type;

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

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>
        if coherence_rsp_rcv_empty = '0' then

          if ('0' & reg.coh_msg = RSP_INV_ACK) then

            if rsp_in_ready = '1' then

              coherence_rsp_rcv_rdreq <= '1';
              rsp_in_valid            <= '1';
              rsp_in_data_coh_msg     <= reg.coh_msg;
              rsp_in_data_addr        <= coherence_rsp_rcv_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
              reg.state               := rcv_header;

            end if;

          else
            -- RSP_DATA, RSP_EDATA

            coherence_rsp_rcv_rdreq <= '1';
            reg.addr                := coherence_rsp_rcv_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
            reg.word_cnt            := 0;
            reg.state               := rcv_data;

          end if;

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
