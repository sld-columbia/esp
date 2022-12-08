-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- ESP Accelerator DMA
--
-- The accelerators communicate with memory by issuing DMA requests. This module
-- serves DMA requests by issuing burst transactions over the NoC. Address
-- translation is performed thorugh a dedicated accelerator TLB
--
-- Note that the accelerator interface limits the accelerator virtual memory to
-- at most 4 GB. Therefore, accelerators can process up to 4 GB of data on a
-- single invocation.
--
-- NoC transactions can be non coherent DMA bursts that bypass the cache
-- hierarchy, LLC-coherent DMA bursts, or memory access requests that comply
-- with the MESI coherence protocol. The type of transaction is set at run time
-- by configuring bankreg[COHERENCE_REG]. The fully-coherent model requires a
-- private L2 cache to be instantiated through the ESP SoC generator.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

use work.monitor_pkg.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;

use work.esp_acc_regmap.all;

entity esp_acc_dma is
  generic (
    tech               : integer                              := virtex7;
    extra_clk_buf      : integer range 0 to 1;
    mem_num            : integer                              := 1;
    mem_info           : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE);
    io_y               : local_yx;
    io_x               : local_yx;
    pindex             : integer                              := 0;
    revision           : integer                              := 0;
    devid              : devid_t                              := 16#001#;
    available_reg_mask : std_logic_vector(0 to MAXREGNUM - 1) := (others => '1');
    rdonly_reg_mask    : std_logic_vector(0 to MAXREGNUM - 1) := (others => '0');
    exp_registers      : integer range 0 to 1                 := 0;  -- Not implemented
    scatter_gather     : integer range 0 to 1                 := 1;
    tlb_entries        : integer                              := 256;
    has_dvfs           : integer                              := 1;
    has_pll            : integer);
  port (
    rst           : in  std_ulogic;
    clk           : in  std_ulogic;
    local_y       : in  local_yx;
    local_x       : in  local_yx;
    paddr         : in  integer range 0 to 4095;
    pmask         : in  integer range 0 to 4095;
    pirq          : in  integer range 0 to NAHBIRQ - 1;
    -- APB interface
    apbi          : in  apb_slv_in_type;
    apbo          : out apb_slv_out_type;
    -- Accelerator interface
    bank          : out bank_type(0 to MAXREGNUM - 1);
    bankdef       : in  bank_type(0 to MAXREGNUM - 1);
    acc_rst       : out std_ulogic;
    conf_done     : out std_ulogic;
    rd_request    : in  std_ulogic;
    rd_index      : in  std_logic_vector(31 downto 0);
    rd_length     : in  std_logic_vector(31 downto 0);
    rd_size       : in  std_logic_vector(2 downto 0);
    rd_grant      : out std_ulogic;
    bufdin_ready  : in  std_ulogic;
    bufdin_data   : out std_logic_vector(ARCH_BITS - 1 downto 0);
    bufdin_valid  : out std_ulogic;
    wr_request    : in  std_ulogic;
    wr_index      : in  std_logic_vector(31 downto 0);
    wr_length     : in  std_logic_vector(31 downto 0);
    wr_size       : in  std_logic_vector(2 downto 0);
    wr_grant      : out std_ulogic;
    bufdout_ready : out std_ulogic;
    bufdout_data  : in  std_logic_vector(ARCH_BITS - 1 downto 0);
    bufdout_valid : in  std_ulogic;
    acc_done      : in  std_ulogic;
    flush         : out std_ulogic;
    acc_flush_done: in  std_ulogic;
    mon_dvfs_in   : in  monitor_dvfs_type;
    --Monitor signals
    mon_dvfs      : out monitor_dvfs_type;

    -- Coherent requests parallel control
    coherent_dma_read    : out std_ulogic;
    coherent_dma_write   : out std_ulogic;
    coherent_dma_length  : out addr_t;
    coherent_dma_address : out addr_t;
    coherent_dma_ready   : in  std_ulogic;
    -- NoC6->tile
    llc_coherent_dma_rcv_rdreq          : out std_ulogic;
    llc_coherent_dma_rcv_data_out       : in  noc_flit_type;
    llc_coherent_dma_rcv_empty          : in  std_ulogic;
    -- tile->NoC4
    llc_coherent_dma_snd_wrreq          : out std_ulogic;
    llc_coherent_dma_snd_data_in        : out noc_flit_type;
    llc_coherent_dma_snd_full           : in  std_ulogic;
    -- NoC4->tile
    dma_rcv_rdreq                       : out std_ulogic;
    dma_rcv_data_out                    : in  noc_flit_type;
    dma_rcv_empty                       : in  std_ulogic;
    -- tile->NoC6
    dma_snd_wrreq                       : out std_ulogic;
    dma_snd_data_in                     : out noc_flit_type;
    dma_snd_full                        : in  std_ulogic;
    -- tile->NoC5
    interrupt_wrreq                     : out std_ulogic;
    interrupt_data_in                   : out misc_noc_flit_type;
    interrupt_full                      : in  std_ulogic;
    -- Transient
    dvfs_transient_in                   : in std_ulogic);    --prevent DMA transaction while DVFS is switching

end esp_acc_dma;

architecture rtl of esp_acc_dma is

  -- plug & play info
  signal pconfig : apb_config_type;
  constant hprot : std_logic_vector(7 downto 0) := "00000011";

  constant len_pad : std_logic_vector(GLOB_BYTE_OFFSET_BITS - 1 downto 0) := (others => '0');

  -- Fix endianness
  function fix_endian (
    din : std_logic_vector(ARCH_BITS - 1 downto 0);
    sz  : std_logic_vector(2 downto 0))
  return std_logic_vector is
    variable dout : std_logic_vector(ARCH_BITS - 1 downto 0);
  begin
    -- If architecture is little endian, then return data as is
    if GLOB_CPU_AXI = 1 then
      dout := din;
    else
      case sz is

        when HSIZE_WORD =>
          for i in 0 to (ARCH_BITS / 32) - 1 loop
            dout(32 * (i + 1) - 1 downto 32 * i) := din(ARCH_BITS - 32 * i - 1 downto ARCH_BITS - 32 * (i + 1));
          end loop;

        when HSIZE_HWORD =>
          for i in 0 to (ARCH_BITS / 16) - 1 loop
            dout(16 * (i + 1) - 1 downto 16 * i) := din(ARCH_BITS - 16 * i - 1 downto ARCH_BITS - 16 * (i + 1));
          end loop;

        when HSIZE_BYTE =>
          for i in 0 to (ARCH_BITS / 8) - 1 loop
            dout(8 * (i + 1) - 1 downto 8 * i) := din(ARCH_BITS - 8 * i - 1 downto ARCH_BITS - 8 * (i + 1));
          end loop;

        when others =>
          dout := din;

      end case;
    end if;
    return dout;
  end fix_endian;

  -- Endiannes adapter for big endian 32 bits systems (support up to 64 bits words)
  signal fixen_bypass            : std_ulogic;
  signal fixen_bufdin_data       : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal fixen_bufdin_valid      : std_ulogic;
  signal fixen_bufdin_ready      : std_ulogic;
  signal fixen_bufdout_data      : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal fixen_bufdout_valid     : std_ulogic;
  signal fixen_bufdout_ready     : std_ulogic;
  signal fixen_bufdout_ready_act : std_ulogic;
  signal fixen_out_msg_type      : noc_msg_type;

  -- Register bank
  signal bankreg   : bank_type(0 to MAXREGNUM - 1);
  signal bankin    : bank_type(0 to MAXREGNUM - 1);
  signal sample    : std_logic_vector(0 to MAXREGNUM - 1);
  signal readdata  : std_logic_vector(31 downto 0);
  signal dvfs_apbo : apb_slv_out_type;

  -- Coherence
  signal coherence : integer range 0 to ACC_COH_FULL;

  -- P2P
  signal p2p_src_index_r      : integer range 0 to 3;
  signal p2p_src_index_inc    : std_ulogic;
  signal p2p_dst_y            : local_yx;
  signal p2p_dst_x            : local_yx;
  signal p2p_req_rcv_rdreq    : std_ulogic;
  signal p2p_req_rcv_data_out : noc_flit_type;
  signal p2p_req_rcv_empty    : std_ulogic;
  signal p2p_rsp_snd_wrreq    : std_ulogic;
  signal p2p_rsp_snd_data_in  : noc_flit_type;
  signal p2p_rsp_snd_full     : std_ulogic;

  -- IRQ
  signal irq      : std_ulogic;
  signal irqset   : std_ulogic;
  type irq_fsm is (idle, pending);
  signal irq_state, irq_next : irq_fsm;

  -- NoC flit
  signal header, header_r                    : noc_flit_type;
  signal payload_address, payload_address_r  : noc_flit_type;
  signal payload_length, payload_length_r    : noc_flit_type;
  signal sample_flits                        : std_ulogic;
  signal sample_rd_size, sample_wr_size      : std_ulogic;
  signal size_r                              : std_logic_vector(2 downto 0);
  signal irq_header_i, irq_header            : misc_noc_flit_type;
  signal irq_info                            : std_logic_vector(RESERVED_WIDTH - 1 downto 0);

  -- DMA
  type dma_fsm is (idle, request_header, request_address, request_length,
                   request_data, reply_header, reply_data, config,
                   send_header, rd_handshake, wr_handshake, wait_req_p2p,
                   running, reset, wait_for_completion, wait_flush_done, fully_coherent_request);
  signal acc_rst_next : std_ulogic;
  signal dma_state, dma_next : dma_fsm;
  signal status : std_logic_vector(31 downto 0);
  signal sample_status : std_ulogic;

  -- Internal signals muxed to output queues depending on coherence configuration
  signal dma_rcv_rdreq_int    :  std_ulogic;
  signal dma_rcv_data_out_int :  noc_flit_type;
  signal dma_rcv_empty_int    :  std_ulogic;
  signal dma_snd_wrreq_int    :  std_ulogic;
  signal dma_snd_data_in_int  :  noc_flit_type;
  signal dma_snd_full_int     :  std_ulogic;

  -- DMA word count
  signal count                : std_logic_vector(31 downto 0);
  signal increment_count      : std_ulogic;
  signal clear_count          : std_ulogic;
  signal dma_tran_done        : std_ulogic;
  signal dma_tran_header_sent : std_ulogic;
  signal dma_tran_start       : std_ulogic;
  signal dvfs_transient       : std_ulogic;  -- prevent DMA transaction while DVFS is switching

  -- TLB
  signal pending_dma_read, pending_dma_write : std_ulogic;
  signal tlb_valid, tlb_clear, tlb_empty, tlb_write : std_ulogic;
  signal tlb_wr_address : std_logic_vector((log2xx(tlb_entries) -1) downto 0);
  signal dma_address : addr_t;
  signal dma_length : std_logic_vector(31 downto 0);

  -- Sample acc_done:
  signal pending_acc_done, clear_acc_done : std_ulogic;

  -- DVFS
  signal dma_snd_delay : std_ulogic;
  signal dma_rcv_delay : std_ulogic;
  signal read_burst : std_ulogic;
  signal write_burst : std_ulogic;
  signal noc_delay : std_ulogic;
  signal burst : std_ulogic;
  signal acc_idle : std_ulogic;
  signal mon_dvfs_ctrl : monitor_dvfs_type;

  -----------------------------------------------------------------------------
  -- De-comment signals you wish to debug
  -----------------------------------------------------------------------------
   attribute mark_debug : string;

   attribute mark_debug of apbi    : signal is "true";
   attribute mark_debug of apbo    : signal is "true";
  -- attribute mark_debug of sample    : signal is "true";
  -- attribute mark_debug of readdata  : signal is "true";
  -- attribute mark_debug of dvfs_apbo : signal is "true";
   attribute mark_debug of irq      : signal is "true";
  -- attribute mark_debug of irqset   : signal is "true";
   attribute mark_debug of irq_state: signal is "true";
  -- attribute mark_debug of header                    : signal is "true";
  -- attribute mark_debug of payload_address: signal is "true";
  -- attribute mark_debug of payload_length    : signal is "true";
  -- attribute mark_debug of sample_flits                        : signal is "true";
   attribute mark_debug of irq_header                : signal is "true";
   attribute mark_debug of interrupt_full            : signal is "true";
   attribute mark_debug of interrupt_data_in         : signal is "true";
   attribute mark_debug of interrupt_wrreq           : signal is "true";
-- attribute mark_debug of dma_state : signal is "true";
  -- attribute mark_debug of status : signal is "true";
  -- attribute mark_debug of sample_status : signal is "true";
  -- attribute mark_debug of count                : signal is "true";
  -- attribute mark_debug of increment_count      : signal is "true";
  -- attribute mark_debug of clear_count          : signal is "true";
  -- attribute mark_debug of dma_tran_done        : signal is "true";
  -- attribute mark_debug of dma_tran_header_sent : signal is "true";
  -- attribute mark_debug of dma_tran_start       : signal is "true";
  -- attribute mark_debug of dvfs_transient       : signal is "true";
  -- attribute mark_debug of pending_dma_read : signal is "true";
  -- attribute mark_debug of pending_dma_write : signal is "true";
  -- attribute mark_debug of tlb_valid : signal is "true";
  -- attribute mark_debug of tlb_clear : signal is "true";
  -- attribute mark_debug of tlb_empty : signal is "true";
  -- attribute mark_debug of tlb_write : signal is "true";
  -- attribute mark_debug of tlb_wr_address : signal is "true";
  -- attribute mark_debug of dma_address : signal is "true";
  -- attribute mark_debug of dma_length : signal is "true";
  -- attribute mark_debug of pending_acc_done : signal is "true";
  -- attribute mark_debug of clear_acc_done : signal is "true";
  -- attribute mark_debug of dma_snd_delay : signal is "true";
  -- attribute mark_debug of dma_rcv_delay : signal is "true";
  -- attribute mark_debug of read_burst : signal is "true";
  -- attribute mark_debug of write_burst : signal is "true";
  -- attribute mark_debug of noc_delay : signal is "true";
  -- attribute mark_debug of burst : signal is "true";
  -- attribute mark_debug of acc_idle : signal is "true";
  -- attribute mark_debug of mon_dvfs_ctrl : signal is "true";

begin  -- rtl

  -----------------------------------------------------------------------------
  -- IRQ packet
  -----------------------------------------------------------------------------
  irq_info <= conv_std_logic_vector(pirq, RESERVED_WIDTH);
  irq_header_i <= create_header(MISC_NOC_FLIT_SIZE, local_y, local_x, io_y, io_x, INTERRUPT, irq_info)(MISC_NOC_FLIT_SIZE - 1 downto 0);
  irq_header(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_1FLIT;
  irq_header(MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) <=
    irq_header_i(MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0);

  ----------------------------------------------------------------------------- 
  -- DVFS transient init
  ----------------------------------------------------------------------------- 
    dvfs_transient  <= dvfs_transient_in;

  -----------------------------------------------------------------------------
  -- TLB
  -----------------------------------------------------------------------------

  tlb_gen: if tlb_entries /= 0 generate
    esp_acc_tlb_1 : esp_acc_tlb
      generic map (
        tech           => tech,
        scatter_gather => scatter_gather,
        tlb_entries    => tlb_entries)
      port map (
        clk                  => clk,
        rst                  => rst,
        bankreg              => bankreg,
        rd_request           => rd_request,
        rd_index             => rd_index,
        rd_length            => rd_length,
        wr_request           => wr_request,
        wr_index             => wr_index,
        wr_length            => wr_length,
        dma_tran_start       => dma_tran_start,
        dma_tran_header_sent => dma_tran_header_sent,
        dma_tran_done        => dma_tran_done,
        pending_dma_write    => pending_dma_write,
        pending_dma_read     => pending_dma_read,
        tlb_empty            => tlb_empty,
        tlb_clear            => tlb_clear,
        tlb_valid            => tlb_valid,
        tlb_write            => tlb_write,
        tlb_wr_address       => tlb_wr_address,
        tlb_datain           => dma_rcv_data_out_int(GLOB_PHYS_ADDR_BITS - 1 downto 0),
        dma_address          => dma_address,
        dma_length           => dma_length);
  end generate tlb_gen;

  no_tlb_gen: if tlb_entries = 0 generate
    -- No DMA transaction can occur
    dma_tran_start <= '0';
    pending_dma_write <= '0';
    pending_dma_read <= '0';
    -- Skip page-table fetch into the TLB
    tlb_empty <= '0';
    -- Don't care
    dma_address <= (others => '0');
    dma_length <= (others => '0');
  end generate no_tlb_gen;


  -----------------------------------------------------------------------------
  -- DMA packet
  -----------------------------------------------------------------------------
  coherence <= conv_integer(bankreg(COHERENCE_REG)(COH_T_LOG2 - 1 downto 0));

  coherence_model_select: process (bankreg, dma_rcv_rdreq_int, dma_rcv_data_out, dma_rcv_empty,
                                   dma_snd_wrreq_int, dma_snd_data_in_int, dma_snd_full,
                                   llc_coherent_dma_rcv_data_out, llc_coherent_dma_rcv_empty,
                                   llc_coherent_dma_snd_full, p2p_req_rcv_rdreq,
                                   p2p_rsp_snd_wrreq, p2p_rsp_snd_data_in, coherence) is
  begin  -- process coherence_model_select

    if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
      -- P2P requests (1 flit each) share the LLC-coherent DMA queues in output
      -- from the tile. Given the NoC plane assignment to prevent deadlock,
      -- these P2P requests are received on the non-coherent DMA queues, which
      -- are otherwise not in use if coherence is set to LLC-coherent.
      -- P2P resposnes use the non-coherent DMA request queues in
      -- output, which are otherwise not in use if coherence is set to
      -- LLC-coherent. These P2P responses are received on the shared queues
      -- for LLC-coherent DMA as if memory replied.
      llc_coherent_dma_rcv_rdreq   <= dma_rcv_rdreq_int;
      dma_rcv_data_out_int         <= llc_coherent_dma_rcv_data_out;
      dma_rcv_empty_int            <= llc_coherent_dma_rcv_empty;
      llc_coherent_dma_snd_wrreq   <= dma_snd_wrreq_int;
      llc_coherent_dma_snd_data_in <= dma_snd_data_in_int;
      dma_snd_full_int             <= llc_coherent_dma_snd_full;
      dma_rcv_rdreq                <= p2p_req_rcv_rdreq;
      p2p_req_rcv_data_out         <= dma_rcv_data_out;
      p2p_req_rcv_empty            <= dma_rcv_empty;
      dma_snd_wrreq                <= p2p_rsp_snd_wrreq;
      dma_snd_data_in              <= p2p_rsp_snd_data_in;
      p2p_rsp_snd_full             <= dma_snd_full;
    else
      -- Symmetrically P2P requeusts share the non-coherent DMA queues in
      -- output, but are received on the LLC-coherent response queues.
      -- P2P responses use the LLC-coherent DMA request queues in output and
      -- are received on the non-coherent DMA queues.
      dma_rcv_rdreq                <= dma_rcv_rdreq_int;
      dma_rcv_data_out_int         <= dma_rcv_data_out;
      dma_rcv_empty_int            <= dma_rcv_empty;
      dma_snd_wrreq                <= dma_snd_wrreq_int;
      dma_snd_data_in              <= dma_snd_data_in_int;
      dma_snd_full_int             <= dma_snd_full;
      llc_coherent_dma_rcv_rdreq   <= p2p_req_rcv_rdreq;
      p2p_req_rcv_data_out         <= llc_coherent_dma_rcv_data_out;
      p2p_req_rcv_empty            <= llc_coherent_dma_rcv_empty;
      llc_coherent_dma_snd_wrreq   <= p2p_rsp_snd_wrreq;
      llc_coherent_dma_snd_data_in <= p2p_rsp_snd_data_in;
      p2p_rsp_snd_full             <= llc_coherent_dma_snd_full;
    end if;
  end process coherence_model_select;

  p2p_dst_y <= get_origin_y(NOC_FLIT_SIZE, p2p_req_rcv_data_out);
  p2p_dst_x <= get_origin_x(NOC_FLIT_SIZE, p2p_req_rcv_data_out);

  make_packet: process (bankreg, pending_dma_write, tlb_empty, dma_address, dma_length,
                        p2p_src_index_r, p2p_dst_y, p2p_dst_x, coherence, local_y, local_x)
    variable msg_type : noc_msg_type;
    variable header_v : noc_flit_type;
    variable tmp : std_logic_vector(63 downto 0);
    variable address : addr_t;
    variable length : std_logic_vector(31 downto 0);
    variable mem_x, mem_y : local_yx;
    variable is_p2p : std_ulogic;
    variable p2p_src_x, p2p_src_y : local_yx;
    variable p2p_header_v : noc_flit_type;
  begin  -- process make_packet

    is_p2p := '0';

    if tlb_empty = '1' then
      -- fetch page table
      if GLOB_PHYS_ADDR_BITS > 32 then
        tmp(63 downto 32) := bankreg(PT_ADDRESS_EXTENDED_REG);
      else
        tmp(63 downto 32) := (others => '0');
      end if;
      tmp(31 downto 0) := bankreg(PT_ADDRESS_REG);
      address := tmp(GLOB_PHYS_ADDR_BITS - 1 downto 0);
      length  := bankreg(PT_NCHUNK_REG);
      if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
        msg_type := REQ_DMA_READ;
      else
        msg_type := DMA_TO_DEV;
      end if;
    elsif pending_dma_write = '1' then
      -- accelerator write burst
      address := dma_address;
      length  := len_pad & dma_length(31 downto GLOB_BYTE_OFFSET_BITS);
      if bankreg(P2P_REG)(P2P_BIT_DST_IS_P2P) = '1' then
        msg_type := RSP_P2P;
        is_p2p := '1';
      else
        if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
          msg_type := REQ_DMA_WRITE;
        else
          msg_type := DMA_FROM_DEV;
        end if;
      end if;
    else
      -- accelerator read burst
      address := dma_address;
      length  := len_pad & dma_length(31 downto GLOB_BYTE_OFFSET_BITS);
      if bankreg(P2P_REG)(P2P_BIT_SRC_IS_P2P) = '1' then
        msg_type := REQ_P2P;
        is_p2p := '1';
      else
        if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
          msg_type := REQ_DMA_READ;
        else
          msg_type := DMA_TO_DEV;
        end if;
      end if;
    end if;

    mem_x := mem_info(0).x;
    mem_y := mem_info(0).y;
    if mem_num /= 1 then
      for i in 0 to mem_num - 1 loop
        if ((address(31 downto 20) xor conv_std_logic_vector(mem_info(i).haddr, 12))
            and conv_std_logic_vector(mem_info(i).hmask, 12)) = X"000" then
          mem_x := mem_info(i).x;
          mem_y := mem_info(i).y;
        end if;
      end loop;  -- i
    end if;

    p2p_src_y := bankreg(P2P_REG)(9 + 6 * p2p_src_index_r downto 7 + 6 * p2p_src_index_r);
    p2p_src_x := bankreg(P2P_REG)(6 + 6 * p2p_src_index_r downto 4 + 6 * p2p_src_index_r);

    if msg_type = REQ_P2P then
      p2p_header_v := create_header(NOC_FLIT_SIZE, local_y, local_x, p2p_src_y, p2p_src_x, msg_type, hprot);
      p2p_header_v(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_1FLIT;
    else
      p2p_header_v := create_header(NOC_FLIT_SIZE, local_y, local_x, p2p_dst_y, p2p_dst_x, msg_type, hprot);
    end if;

    header_v := (others => '0');
    header_v := create_header(NOC_FLIT_SIZE, local_y, local_x, mem_y, mem_x, msg_type, hprot);
    if is_p2p = '0' then
      header <= header_v;
    else
      header <= p2p_header_v;
    end if;

    payload_address <= (others => '0');
    payload_address(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_BODY;
    payload_address(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= address;

    payload_length <= (others => '0');
    payload_length(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
    payload_length(31 downto 0) <= length;

  end process make_packet;

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      header_r <= (others => '0');
      payload_address_r <= (others => '0');
      payload_length_r <= (others => '0');
      count <= conv_std_logic_vector(1, 32);
      size_r <= HSIZE_WORD;
      p2p_src_index_r <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_flits = '1' then
        header_r <= header;
        payload_address_r <= payload_address;
        payload_length_r <= payload_length;
      end if;
      if increment_count = '1' then
        count <= count + 1;
      end if;
      if clear_count = '1' then
        count <= conv_std_logic_vector(1, 32);
      end if;
      if sample_rd_size = '1' then
        size_r <= rd_size;
      elsif sample_wr_size = '1' then
        size_r <= wr_size;
      end if;
      if p2p_src_index_inc = '1' then
        if p2p_src_index_r = conv_integer(bankreg(P2P_REG)(P2P_BIT_NSRCS + P2P_WIDTH_NSRCS - 1 downto P2P_BIT_NSRCS)) then
          p2p_src_index_r <= 0;
        else
          p2p_src_index_r <= p2p_src_index_r + 1;
        end if;
      end if;
    end if;
  end process;

  fill_coherent_dma_req: process (payload_address_r, payload_length_r) is
  begin  -- process fill_coherent_dma_req
    coherent_dma_address <= payload_address_r(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    coherent_dma_length <= (others => '0');
    coherent_dma_length(31 downto 0) <= payload_length_r(31 downto 0);
  end process fill_coherent_dma_req;

  -----------------------------------------------------------------------------
  -- Endianness on narrow NoC
  -----------------------------------------------------------------------------
  fixen_bypass <= '1' when size_r /= HSIZE_DWORD else '0';

  fixen_64to32_in: fixen_64to32
    port map (
      clk         => clk,
      rstn        => rst,
      bypass_i    => fixen_bypass,
      in_data_i   => fixen_bufdin_data,
      in_valid_i  => fixen_bufdin_valid,
      in_ready_o  => fixen_bufdin_ready,
      out_data_o  => bufdin_data,
      out_valid_o => bufdin_valid,
      out_ready_i => bufdin_ready);

  fixen_64to32_ou: fixen_64to32
    port map (
      clk         => clk,
      rstn        => rst,
      bypass_i    => fixen_bypass,
      in_data_i   => bufdout_data,
      in_valid_i  => bufdout_valid,
      in_ready_o  => bufdout_ready,
      out_data_o  => fixen_bufdout_data,
      out_valid_o => fixen_bufdout_valid,
      out_ready_i => fixen_bufdout_ready_act);

  fixen_out_msg_type <= get_msg_type(NOC_FLIT_SIZE, header_r);

  fixen_bufdout_ready_fix: process (fixen_bufdout_ready, fixen_bypass, fixen_out_msg_type,
                                    p2p_rsp_snd_full, dma_snd_full_int, dvfs_transient,
                                    dma_state) is
  begin  -- process fixen_bufdout_ready_fix
    if ARCH_BITS /= 32 or GLOB_CPU_AXI /= 0 or fixen_bypass = '1' then
      fixen_bufdout_ready_act <= fixen_bufdout_ready;
    elsif (dvfs_transient = '0' and dma_state = request_data and
           ((fixen_out_msg_type  = RSP_P2P and p2p_rsp_snd_full = '0') or
            (fixen_out_msg_type /= RSP_P2P and dma_snd_full_int = '0'))) then
      fixen_bufdout_ready_act <= '1';
    else
      fixen_bufdout_ready_act <= '0';
    end if;
  end process fixen_bufdout_ready_fix;

  -----------------------------------------------------------------------------
  -- DMA
  -----------------------------------------------------------------------------
  acc_rst_reg : process (clk)
  begin
    if clk'event and clk = '1' then -- rising clock edge
        acc_rst <= acc_rst_next;
    end if;
  end process acc_rst_reg;

  sample_acc_done: process (clk, rst)
  begin  -- process sample_acc_done
    if rst = '0' then                   -- asynchronous reset (active low)
      pending_acc_done <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if acc_done = '1' then
        pending_acc_done <= '1';
      end if;
      if clear_acc_done = '1' then
        pending_acc_done <= '0';
      end if;
    end if;
  end process sample_acc_done;

  dma_roundtrip: process (dma_state, rst, count, rd_request, fixen_bufdin_ready,
                          wr_request, fixen_bufdout_valid, fixen_bufdout_data, bankreg,
                          pending_acc_done, dma_snd_full_int, dma_rcv_empty_int, dma_rcv_data_out_int,
                          header_r, payload_address_r, payload_length_r,
                          dma_tran_start, tlb_empty, pending_dma_write,
                          pending_dma_read, coherent_dma_ready, dvfs_transient,
                          size_r, coherence,
                          p2p_req_rcv_empty, p2p_req_rcv_data_out, p2p_rsp_snd_full, acc_flush_done)
    variable payload_data : noc_flit_type;
    variable preamble : noc_preamble_type;
    variable msg : noc_msg_type;
    variable len : std_logic_vector(31 downto 0);
    variable tlb_wr_address_next : std_logic_vector(31 downto 0);
  begin  -- process dma_roundtrip

    dma_next <= dma_state;
    sample_flits <= '0';
    sample_rd_size <= '0';
    sample_wr_size <= '0';
    increment_count <= '0';
    clear_count <= '0';
    --TLB
    tlb_wr_address_next := count - 1;
    tlb_wr_address <= tlb_wr_address_next(log2xx(tlb_entries) - 1 downto 0);
    tlb_write <= '0';
    tlb_valid <= '0';

    -- Change DMA status
    status <= (others => '0');
    sample_status <= '0';
    dma_tran_done <= '0';
    dma_tran_header_sent <= '0';

    dma_snd_data_in_int <= (others => '0');
    dma_snd_wrreq_int <= '0';
    dma_rcv_rdreq_int <= '0';

    p2p_rsp_snd_data_in <= (others => '0');
    p2p_rsp_snd_wrreq <= '0';
    p2p_req_rcv_rdreq <= '0';

    p2p_src_index_inc <= '0';

    preamble := get_preamble(NOC_FLIT_SIZE, dma_rcv_data_out_int);
    msg := get_msg_type(NOC_FLIT_SIZE, header_r);
    len := payload_length_r(31 downto 0);
    if count /= len then
      payload_data(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    else
      payload_data(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    end if;
    -- Note that NOC_FLIT_SIZE os ARCH_BITS + PREAMBLE_WIDTH
    payload_data(ARCH_BITS - 1 downto 0) := fix_endian(fixen_bufdout_data, size_r);

    -- Default private cache inputs
    coherent_dma_read  <= '0';
    coherent_dma_write <= '0';

    -- Default accelerator inputs
    acc_rst_next <= rst;
    conf_done <= '0';
    rd_grant <= '0';
    fixen_bufdin_data <= fix_endian(dma_rcv_data_out_int(ARCH_BITS - 1 downto 0), size_r);
    fixen_bufdin_valid <= '0';
    wr_grant <= '0';
    fixen_bufdout_ready <= '0';

    clear_acc_done <= '0';
    flush <= '0';

    -- Default DVFS controller info
    dma_snd_delay <= '0';
    dma_rcv_delay <= '0';
    read_burst <= '0';
    write_burst <= '0';
    burst <= '0';

    case dma_state is
      when idle =>
        -- When TLB is empty, we need to fetch the page table. We wait for the
        -- command, because the driver should write all PT_* registers. This
        -- check could be done in hardware with multiple flags.
        -- There is no need to check the status register, because whenever the
        -- FSM returns to idle, the status register is set to zero.
        clear_acc_done <= '1';
        if bankreg(CMD_REG)(CMD_BIT_START) = '1' and tlb_empty = '1' and scatter_gather /= 0 then
          sample_flits <= '1';
          if coherence /= ACC_COH_FULL then
            dma_next <= send_header;
          else
            dma_next <= fully_coherent_request;
          end if;
        elsif bankreg(CMD_REG)(CMD_BIT_START) = '1' and (tlb_empty = '0' or scatter_gather = 0) then
          dma_next <= config;
          status <= (others => '0');
          status(STATUS_BIT_RUN) <= '1';
          sample_status <= '1';
        end if;

      when fully_coherent_request =>
        burst <= '1';
        if msg = DMA_TO_DEV then
          coherent_dma_read <= '1';
          if coherent_dma_ready = '1' then
            dma_tran_header_sent <= '1';
            dma_next <= reply_data;
          end if;
        else
          coherent_dma_write <= '1';
          if coherent_dma_ready = '1' then
            dma_tran_header_sent <= '1';
            dma_next <= request_data;
          end if;
        end if;

      when running =>
        -- Evaluation of inputs is done in the following order:
        -- 1) If there is a DMA transaction split across multiple chunks
        --    (scattered), we must first complete the transaction, because the
        --    length has been sent to the memory tile. If not completed deadlock
        --    will occur on the NoC.
        -- 2) If the software sends a reset command, both the accelerator and
        --    the FSM are reset during the next clock cycle (goto reset state)
        -- 3) If the accelerator has completed, the status register is updated;
        --    this causes an interrupt. At this point we wait for the software to
        --    reset the FSM and the accelerator by writing a 0 to the command
        --    register (goto wait_for_completion).
        -- 4) If there is a rd_request, a read transaction is initiated.
        -- 5) If there a wr_request, a write transaction is initiated. Read has
        --    priority over write regardless of P2P configuration.
        if (pending_dma_read or pending_dma_write) = '1' and scatter_gather /= 0 then
          if dma_tran_start = '1' then
            sample_flits <= '1';
            if coherence /= ACC_COH_FULL then
              dma_next <= send_header;
            else
              dma_next <= fully_coherent_request;
            end if;
          end if;
        elsif bankreg(CMD_REG)(CMD_BIT_LAST downto 0) = zero(CMD_BIT_LAST downto 0) then
          dma_next <= reset;
        elsif pending_acc_done = '1' then
          if USE_SPANDEX /= 0 and coherence = ACC_COH_FULL then
            flush <= '1';
            dma_next <= wait_flush_done; 
          else
            status <= (others => '0');
            status(STATUS_BIT_DONE) <= '1';
            sample_status <= '1';
            if coherence = ACC_COH_FULL then
              flush <= '1';
            end if;
            dma_next <= wait_for_completion; 
          end if;
        elsif rd_request = '1' then
          if scatter_gather = 0 then
            sample_flits <= '1';
          end if;
          sample_rd_size <= '1';
          dma_next <= rd_handshake;
        elsif wr_request = '1' then
          if scatter_gather = 0 then
            sample_flits <= '1';
          end if;
          sample_wr_size <= '1';
          dma_next <= wr_handshake;
        end if;

      when wait_flush_done =>
        if acc_flush_done = '1' and USE_SPANDEX /= 0 then
          status <= (others => '0');
          status(STATUS_BIT_DONE) <= '1';
          sample_status <= '1';
          dma_next <= wait_for_completion; 
        end if;

      when wait_for_completion =>
        -- The software must reset the accelerator on completion by writing a 0
        -- to the command register
        if bankreg(CMD_REG)(CMD_BIT_LAST downto 0) = zero(CMD_BIT_LAST downto 0) then
          dma_next <= reset;
        end if;

      when reset =>
        -- Reset the accelerator and go back to idle. Note that the TLB is
        -- still valid until the register PT_ADDRESS is written again.
        acc_rst_next <= '0';
        status <= (others => '0');
        sample_status <= '1';
        clear_acc_done <= '1';
        dma_next <= idle;

      when config =>
        -- Set conf_done to start the accelerator.
        conf_done <= '1';
        dma_next <= running;

      when rd_handshake =>
        burst <= '1';
        if dma_snd_full_int = '0' or coherence = ACC_COH_FULL then
          if rd_request = '1' then
            rd_grant <= '1';
          elsif dma_tran_start = '1' and scatter_gather /= 0 then
            sample_flits <= '1';
            if coherence /= ACC_COH_FULL then
              dma_next <= send_header;
            else
              dma_next <= fully_coherent_request;
            end if;
          elsif scatter_gather = 0 then
            if coherence /= ACC_COH_FULL then
              dma_next <= send_header;
            else
              dma_next <= fully_coherent_request;
            end if;
          end if;
        end if;

      when wr_handshake =>
        burst <= '1';
        if dma_snd_full_int = '0' or coherence = ACC_COH_FULL then
          if wr_request = '1' then
            wr_grant <= '1';
          elsif dma_tran_start = '1' and scatter_gather /= 0 then
            sample_flits <= '1';
            if coherence /= ACC_COH_FULL then
              if bankreg(P2P_REG)(P2P_BIT_DST_IS_P2P) = '1' then
                dma_next <= wait_req_p2p;
              else
                dma_next <= send_header;
              end if;
            else
              dma_next <= fully_coherent_request;
            end if;
          elsif scatter_gather = 0 then
            if coherence /= ACC_COH_FULL then
              if bankreg(P2P_REG)(P2P_BIT_DST_IS_P2P) = '1' then
                dma_next <= wait_req_p2p;
              else
                dma_next <= send_header;
              end if;
            else
              dma_next <= fully_coherent_request;
            end if;
          end if;
        end if;

      when wait_req_p2p =>
        burst <= '1';
        if p2p_req_rcv_empty = '0' and dvfs_transient = '0' then
          p2p_req_rcv_rdreq <= '1';
          sample_flits <= '1';
          dma_next <= send_header;
        end if;

      when send_header =>
        burst <= '1';
        if dma_snd_full_int = '0' and dvfs_transient = '0' and msg /= RSP_P2P then
          dma_snd_data_in_int <= header_r;
          dma_snd_wrreq_int <= '1';
          dma_tran_header_sent <= '1';
          if msg = REQ_P2P then
            dma_next <= reply_header;
            p2p_src_index_inc <= '1';
          else
            dma_next <= request_address;
          end if;
        elsif p2p_rsp_snd_full = '0' and dvfs_transient = '0' and msg = RSP_P2P then
          p2p_rsp_snd_data_in <= header_r;
          p2p_rsp_snd_wrreq <= '1';
          dma_tran_header_sent <= '1';
          dma_next <= request_data;
        end if;

      when request_address =>
        burst <= '1';
        if dma_snd_full_int = '0' and dvfs_transient = '0' then
          dma_snd_data_in_int <= payload_address_r;
          dma_snd_wrreq_int <= '1';
          if msg = DMA_TO_DEV or msg = REQ_DMA_READ or msg = DMA_FROM_DEV then
            dma_next <= request_length;
          else
            dma_next <= request_data;
          end if;
        end if;

      when request_length =>
        burst <= '1';
        if dma_snd_full_int = '0' and dvfs_transient = '0' then
          dma_snd_data_in_int <= payload_length_r;
          dma_snd_wrreq_int <= '1';
          if msg = DMA_FROM_DEV then
            -- In case of a write, length is not the tail!
            dma_snd_data_in_int(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
            dma_next <= request_data;
          else
            dma_next <= reply_header;
          end if;
        end if;

      when request_data =>
        burst <= '1';
        if msg = RSP_P2P then
          dma_snd_delay <= p2p_rsp_snd_full;       -- for DVFS TRAFFIC policy
        else
          dma_snd_delay <= dma_snd_full_int;       -- for DVFS TRAFFIC policy
        end if;
        if ((dvfs_transient = '0') and
            ((msg = RSP_P2P and p2p_rsp_snd_full = '0') or
             (msg /= RSP_P2P and dma_snd_full_int = '0'))) then
          write_burst <= '1';
          fixen_bufdout_ready <= '1';
          if fixen_bufdout_valid = '1' then
            if msg = RSP_P2P  then
              p2p_rsp_snd_data_in <= payload_data;
              p2p_rsp_snd_wrreq <= '1';
            else
              dma_snd_data_in_int <= payload_data;
              dma_snd_wrreq_int <= '1';
            end if;
            if count = len then
              clear_count <= '1';
              dma_tran_done <= '1';
              dma_next <= running;
            else
              increment_count <= '1';
            end if;
          end if;
        end if;

      when reply_header =>
        burst <= '1';
        dma_rcv_delay <= dma_rcv_empty_int;       -- for DVFS TRAFFIC policy
        if dma_rcv_empty_int = '0' and dvfs_transient = '0' then
          dma_rcv_rdreq_int <= '1';
          dma_next <= reply_data;
        end if;

      when reply_data =>
        burst <= '1';
        dma_rcv_delay <= dma_rcv_empty_int;       -- for DVFS TRAFFIC policy
        if dma_rcv_empty_int = '0' and tlb_empty = '1' and dvfs_transient = '0' then
          dma_rcv_rdreq_int <= '1';
          tlb_write <= '1';
          increment_count <= '1';
          if preamble = PREAMBLE_TAIL then
            clear_count <= '1';
            tlb_valid <= '1';
            dma_next <= idle;
          end if;
        elsif dma_rcv_empty_int = '0' and dvfs_transient = '0' then
          fixen_bufdin_valid <= '1';
          read_burst <= '1';
          if fixen_bufdin_ready = '1' then
            dma_rcv_rdreq_int <= '1';
            if preamble = PREAMBLE_TAIL then
              dma_tran_done <= '1';
              dma_next <= running;
            end if;
          end if;
        end if;

      when others =>
        dma_next <= idle;

    end case;
  end process dma_roundtrip;

  -- Interrupt over NoC
  irq_send: process (irq, interrupt_full, irq_state, irq_header)
  begin  -- process irq_send
    interrupt_data_in <= irq_header;
    interrupt_wrreq <= '0';
    irq_next <= irq_state;

    case irq_state is
      when idle =>
        if irq = '1' then
          if interrupt_full = '1' then
            irq_next <= pending;
          else
            interrupt_wrreq <= '1';
          end if;
        end if;

      when pending =>
          if interrupt_full = '0' then
            interrupt_wrreq <= '1';
            irq_next <= idle;
          end if;

      when others =>
        irq_next <= idle;
    end case;
  end process irq_send;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      dma_state <= idle;
      irq_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      dma_state <= dma_next;
      irq_state <= irq_next;
    end if;
  end process;

  -------------------------------------------------------------------------------
  -- DMA Controller APB Slave
  -------------------------------------------------------------------------------

  -- APB Interface
  pconfig(0) <=  ahb_device_reg (VENDOR_SLD, devid, 0, revision, pirq);
  pconfig(1) <=  apb_iobar(paddr, pmask);
  pconfig(2) <=  (others => '0');

  process (apbi, readdata, dvfs_apbo)
  begin  -- process
    if apbi.paddr(7) = '1' then
      apbo.prdata <= dvfs_apbo.prdata;
    else
      apbo.prdata <= readdata;
    end if;
  end process;
  apbo.pirq    <= (others => '0');      -- IRQ forwarded to the NoC directly
  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  reg_out: for i in 0 to MAXREGNUM - 1 generate
    bank(i) <= bankreg(i);
  end generate reg_out;

  drive_irq: process (clk, rst)
  begin  -- process drive_irq
    if rst = '0' then                   -- asynchronous reset (active low)
      irq <= '0';
      irqset <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if irqset = '1' then
        irq <= '0';
      elsif ((bankreg(STATUS_REG)(STATUS_BIT_DONE) or
              bankreg(STATUS_REG)(STATUS_BIT_ERR)) = '1' and
             irqset = '0') then
        irq <= '1';
        irqset <=  '1';
      end if;
      if ((bankreg(STATUS_REG)(STATUS_BIT_RUN) or
           bankreg(STATUS_REG)(STATUS_BIT_DONE) or
           bankreg(STATUS_REG)(STATUS_BIT_ERR)) = '0') then
        -- Equivalent to clear IRQ
        irqset <= '0';
      end if;
    end if;
  end process drive_irq;

  -- rd/wr registers
  process(apbi, bankreg)
    variable addr : integer range 0 to MAXREGNUM - 1;
  begin
    addr := conv_integer(apbi.paddr(7 downto 2));

    bankin <= (others => (others => '0'));
    sample <= (others => '0');

    -- Clear TLB when page table address is updated
    tlb_clear <= '0';

    -- if apbi.paddr(7) = '0' then
      sample(addr) <= apbi.psel(pindex) and apbi.penable and apbi.pwrite;
      if addr = PT_ADDRESS_REG then
        tlb_clear <= '1';
      end if;
    -- end if;
    bankin(addr) <= apbi.pwdata;
    readdata <= bankreg(addr);
  end process;

  -- Status register
  cmd_status: process (clk, rst)
  begin  -- process cmd_status
    if clk'event and clk = '1' then  -- rising clock edge
      if rst = '0' then                   -- asynchronous reset (active low)
        bankreg(STATUS_REG) <= (others => '0');
      elsif sample_status = '1' then
        bankreg(STATUS_REG) <= status;
      end if;
    end if;
  end process cmd_status;

  -- Other registers
  registers: for i in 0 to MAXREGNUM - 1 generate
    written_from_noc: if i /= STATUS_REG and available_reg_mask(i) = '1' generate
      process (clk)
      begin  -- process
        if clk'event and clk = '1' then  -- rising clock edge
          if rst = '0' then                   -- synchronous reset (active low)
            bankreg(i) <= bankdef(i);
          elsif sample(i) = '1' and rdonly_reg_mask(i) = '0' then
            bankreg(i) <= bankin(i);
          elsif i = YX_REG then
            bankreg(i) <=  "0000000000000" & local_y & "0000000000000" & local_x;
          end if;
        end if;
      end process;
    end generate written_from_noc;
  end generate registers;

  unused_registers: for i in 0 to MAXREGNUM - 1 generate
    not_available: if available_reg_mask(i) = '0' generate
      bankreg(i) <= (others => '0');
    end generate not_available;
  end generate unused_registers;
end rtl;
