-------------------------------------------------------------------------------
-- Entity: llc_wrapper
-- File: llc_wrapper.vhd
-- Author: Davide Giri - SLD @ Columbia University
-- Description: RTL wrapper for a Last Level Cache (LLC) with directory
-- to be included on a memory tile on an Embedded Scalable Platform.
-- Frontend: Network on Chip to LLC cache wrapper.
-- Backend: LLC cache wrapper to Amba 2.0 AHB.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TODO:
-- + add reset management
-- + reason about non cacheable rd/wr, why doesn't the LEON3 send any?
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    coherence_req_rdreq    : out std_ulogic;
    coherence_req_data_out : in  noc_flit_type;
    coherence_req_empty    : in  std_ulogic;
    -- tile->NoC2
    coherence_fwd_wrreq    : out std_ulogic;
    coherence_fwd_data_in  : out noc_flit_type;
    coherence_fwd_full     : in  std_ulogic;
    -- tile->NoC3
    coherence_rsp_wrreq    : out std_ulogic;
    coherence_rsp_data_in  : out noc_flit_type;
    coherence_rsp_full     : in  std_ulogic;
    -- NoC3->tile
    coherence_rsp_rdreq    : out std_ulogic;
    coherence_rsp_data_out : in  noc_flit_type;
    coherence_rsp_empty    : in  std_ulogic);
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

end llc_wrapper;

architecture rtl of llc_wrapper is

  -- Interface with LLC cache

  -- NoC to cache
  signal llc_req_in_ready        : std_ulogic;
  signal llc_req_in_valid        : std_ulogic;
  signal llc_req_in_data_coh_msg : coh_msg_t;
  signal llc_req_in_data_hprot   : hprot_t;
  signal llc_req_in_data_addr    : addr_t;
  signal llc_req_in_data_line    : line_t;
  signal llc_req_in_data_req_id  : cache_id_t;

  signal llc_rsp_in_ready        : std_ulogic;
  signal llc_rsp_in_valid        : std_ulogic;
  signal llc_rsp_in_data_coh_msg : coh_msg_t;
  signal llc_rsp_in_data_addr    : addr_t;
  signal llc_rsp_in_data_line    : line_t;
  signal llc_rsp_in_data_req_id  : cache_id_t;

  -- cache to NoC
  signal llc_rsp_out_ready           : std_ulogic;
  signal llc_rsp_out_valid           : std_ulogic;
  signal llc_rsp_out_data_coh_msg    : coh_msg_t;
  signal llc_rsp_out_data_addr       : addr_t;
  signal llc_rsp_out_data_line       : line_t;
  signal llc_rsp_out_data_invack_cnt : invack_cnt_t;
  signal llc_rsp_out_data_req_id     : cache_id_t;
  signal llc_rsp_out_data_dest_id    : cache_id_t;

  signal llc_fwd_out_ready        : std_ulogic;
  signal llc_fwd_out_valid        : std_ulogic;
  signal llc_fwd_out_data_coh_msg : coh_msg_t;
  signal llc_fwd_out_data_addr    : addr_t;
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
  signal llc_mem_req_data_addr   : addr_t;
  signal llc_mem_req_data_line   : line_t;

  -- debug
  signal asserts    : llc_asserts_t;
  signal bookmark   : llc_bookmark_t;
  signal custom_dbg : custom_dbg_t;

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
  end record;

  constant AHBM_REG_DEFAULT : ahbm_reg_type := (
    state    => idle,
    hwrite   => '0',
    haddr    => (others => '0'),
    hprot    => (others => '0'),
    line     => (others => '0'),
    word_cnt => 0
    );

  signal ahbm_reg      : ahbm_reg_type := AHBM_REG_DEFAULT;
  signal ahbm_reg_next : ahbm_reg_type := AHBM_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: cache to NoC
  -------------------------------------------------------------------------------
  type cache2noc_fsm is (idle, send_header, send_addr, send_data);

  type cache2noc_reg_type is record
    state    : cache2noc_fsm;
    word_cnt : integer;
  end record cache2noc_reg_type;

  constant CACHE2NOC_REG_DEFAULT : cache2noc_reg_type := (
    state    => idle,
    word_cnt => 0);

  signal cache2noc_reg      : cache2noc_reg_type := CACHE2NOC_REG_DEFAULT;
  signal cache2noc_reg_next : cache2noc_reg_type := CACHE2NOC_REG_DEFAULT;

  type make_packet_reg_type is record
    header       : noc_flit_type;
    payload_addr : noc_flit_type;
    payload_data : noc_flit_type;
    plane        : std_logic_vector(1 downto 0);
    msg_type     : std_logic_vector(2 downto 0);
    dest_init    : integer;
    dest_x_int   : integer;
    dest_y_int   : integer;
    dest_x       : local_yx;
    dest_y       : local_yx;
    orig_x       : local_yx;
    orig_y       : local_yx;
  end record make_packet_reg_type;

  constant MAKE_PACKET_REG_DEFAULT : make_packet_reg_type := (
    header       => (others => '0'),
    payload_addr => (others => '0'),
    payload_data => (others => '0'),
    plane        => MSG_RSP_PLANE,
    msg_type     => RSP_DATA,
    dest_init    => 0,
    dest_x_int   => 0,
    dest_y_int   => 0,
    dest_x       => (others => '0'),
    dest_y       => (others => '0'),
    orig_x       => (others => '0'),
    orig_y       => (others => '0'));

  signal make_packet_reg      : make_packet_reg_type := MAKE_PACKET_REG_DEFAULT;
  signal make_packet_reg_next : make_packet_reg_type := MAKE_PACKET_REG_DEFAULT;

  signal sample_flits : std_ulogic;

  -------------------------------------------------------------------------------
  -- FSM: NoC to cache
  -------------------------------------------------------------------------------
  type channels is (ch_none, ch_req, ch_rsp_line);
  type noc2cache_fsm is (rcv_header, rcv_rsp_addr, rcv_req_addr_putm, rcv_req_addr, rcv_req_first_data_putm, rcv_rsp_first_data, rcv_req_data_putm, rcv_rsp_data);

  type noc2cache_reg_type is record
    state    : noc2cache_fsm;
    ctl      : std_logic_vector(5 downto 0);
    addr     : std_logic_vector(31 downto 0);
    hprot    : std_logic_vector(3 downto 0);
    data     : std_logic_vector(31 downto 0);
    cache_id : std_logic_vector(2 downto 0);
    tile_id  : integer;
    origin_x : local_yx;
    origin_y : local_yx;
  end record noc2cache_reg_type;

  constant NOC2CACHE_REG_DEFAULT : noc2cache_reg_type := (
    state    => rcv_header,
    ctl      => (others => '0'),
    addr     => (others => '0'),
    hprot    => (others => '0'),
    data     => (others => '0'),
    cache_id => (others => '0'),
    tile_id  => 0,
    origin_x => (others => '0'),
    origin_y => (others => '0')
    );

  signal noc2cache_reg      : noc2cache_reg_type := NOC2CACHE_REG_DEFAULT;
  signal noc2cache_reg_next : noc2cache_reg_type := NOC2CACHE_REG_DEFAULT;

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
      ahbm_reg <= AHBM_REG_DEFAULT;
    elsif clk'event and clk = '1' then
      ahbm_reg <= ahbm_reg_next;
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
    reg := ahbm_reg;

    -- default values for output signals
    llc_mem_req_ready     <= '0';
    llc_mem_rsp_valid     <= '0';
    llc_mem_rsp_data_line <= (others => '0');

    ahbmo.hbusreq <= '0';
    ahbmo.htrans  <= HTRANS_IDLE;
    ahbmo.hwrite  <= '0';
    ahbmo.haddr   <= (others => '0');
    ahbmo.hprot   <= (others => '0');
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
          reg.haddr    := llc_mem_req_data_addr;
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
          ahbmo.hbusreq <= '1';
          ahbmo.htrans  <= HTRANS_NONSEQ;
          ahbmo.hwrite  <= '0';
          ahbmo.haddr   <= reg.haddr;
          ahbmo.hprot   <= reg.hprot;
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
              reg.state := idle;
            else
              reg.state := send_mem_rsp;
            end if;
          end if;
        else
          ahbmo.hbusreq <= '1';
          ahbmo.htrans  <= HTRANS_SEQ;
          ahbmo.hwrite  <= '0';
          ahbmo.haddr   <= reg.haddr;
          ahbmo.hprot   <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.line(reg.word_cnt*BITS_PER_WORD-1 downto (reg.word_cnt-1)*BITS_PER_WORD) := ahbmi.hrdata;
            reg.word_cnt := reg.word_cnt + 1;
            reg.haddr    := reg.haddr + 4;
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
          ahbmo.hbusreq <= '1';
          ahbmo.htrans  <= HTRANS_NONSEQ;
          ahbmo.hwrite  <= '1';
          ahbmo.haddr   <= reg.haddr;
          ahbmo.hprot   <= reg.hprot;
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
          ahbmo.hwdata <= reg.line(reg.word_cnt*BITS_PER_WORD-1 downto (reg.word_cnt-1)*BITS_PER_WORD);

          ahbmo.hbusreq <= '1';
          ahbmo.htrans  <= HTRANS_SEQ;
          ahbmo.hwrite  <= '1';
          ahbmo.haddr   <= reg.haddr;
          ahbmo.hprot   <= reg.hprot;
          if ahbmi.hready = '1' then
            reg.word_cnt := reg.word_cnt + 1;
            reg.haddr    := reg.haddr + 4;
          end if;
        end if;

    end case;

    ahbm_reg_next <= reg;

  end process fsm_ahbm;


  
-------------------------------------------------------------------------------
-- Instantiations
-------------------------------------------------------------------------------

  -- instantiation of llc cache on cpu tile
  llc_cache_0 : llc_basic
    port map (
      clk => clk,
      rst => rst,

      -- NoC to cache
      llc_req_in_ready        => llc_req_in_ready,
      llc_req_in_valid        => llc_req_in_valid,
      llc_req_in_data_coh_msg => llc_req_in_data_coh_msg,
      llc_req_in_data_hprot   => llc_req_in_data_hprot,
      llc_req_in_data_addr    => llc_req_in_data_addr,
      llc_req_in_data_line    => llc_req_in_data_line,
      llc_req_in_data_req_id  => llc_req_in_data_req_id,

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

      -- debug
      asserts    => asserts,
      bookmark   => bookmark,
      custom_dbg => custom_dbg
      );

end architecture rtl;
