-- Copyright (c) 2011-2026 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- This proxy replaces AHB slaves that are hosted in remote tiles and forwards
-- AHB requests from masters to the NoC. Responses from the NoC are returned to
-- the bus master as if the remote device was connected to the local bus.
--
-- This is intended to serve requests from the Leon3 processor, the Ethernet
-- DMA engine and the JTAG or Ethernet debug interfaces. Since these master can
-- only issue requests for up to 32-bits words, ths proxy does not handle
-- larger word sizes.
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

use work.nocpackage.all;
use work.cachepackage.all;

entity axislv2noc is
  generic (
    tech                : integer;
    nmst                : integer;
    retarget_for_dma    : integer range 0 to 1 := 0;
    mem_axi_port        : integer range -1 to NAHBSLV - 1;
    mem_num             : integer;
    mem_info            : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1);
    this_noc_flit_size  : integer;
    slv_y               : local_yx;
    slv_x               : local_yx);
  port (
    rst                        : in  std_ulogic;
    clk                        : in  std_ulogic;
    local_y                    : in  local_yx;
    local_x                    : in  local_yx;
    mosi                       : in  axi_mosi_vector(0 to nmst - 1);
    somi                       : out axi_somi_vector(0 to nmst - 1);
    -- tile->NoC1
    coherence_req_wrreq        : out std_ulogic;
    coherence_req_data_in      : out std_logic_vector(this_noc_flit_size - 1 downto 0);
    coherence_req_full         : in  std_ulogic;
    -- Noc3->tile
    coherence_rsp_rcv_rdreq    : out std_ulogic;
    coherence_rsp_rcv_data_out : in  std_logic_vector(this_noc_flit_size - 1 downto 0);
    coherence_rsp_rcv_empty    : in  std_ulogic;
    -- tile->NoC5
    remote_ahbs_snd_wrreq      : out std_ulogic;
    remote_ahbs_snd_data_in    : out misc_noc_flit_type;
    remote_ahbs_snd_full       : in  std_ulogic;
    -- NoC5->tile
    remote_ahbs_rcv_rdreq      : out std_ulogic;
    remote_ahbs_rcv_data_out   : in  misc_noc_flit_type;
    remote_ahbs_rcv_empty      : in  std_ulogic;
    -- Coherence
    coherence                  : in integer range 0 to 3);
end axislv2noc;

architecture rtl of axislv2noc is

  -- `axi_fsm` organization (delta from the original implementation):
  -- - `idle`/`request_*`/`reply_*` are the original request/response pipeline.
  -- - `wait_wdata` and buffered-write bookkeeping decouple AW and W so memory
  --   writes can be inspected before emitting NoC flits.
  -- - `rmw_*` states implement partial-WSTRB coherent writes through
  --   read-modify-write.
  -- - `dma_write_*` states implement one-beat DMA writes from buffered AXI data.
  --
  -- `axi_fsm` state reference (enum order):
  -- - `idle`: Select the next AXI request and snapshot control in `transaction_reg`.
  -- - `wait_wdata`: Stage memory writes and dispatch based on WSTRB policy.
  -- - `rmw_read_header/address/length`: Emit the read command for coherent
  --   partial-write RMW.
  -- - `rmw_read_reply_header/data`: Consume readback data used for byte-lane merge.
  -- - `rmw_write_header/address/length/data`: Emit the merged write to complete RMW.
  -- - `dma_write_header/address/length/data`: Emit one buffered DMA write beat.
  -- - `request_header/address/length/data`: Baseline request path, also reused
  --   by split segments.
  -- - `reply_header/data`: Baseline read-reply path for memory and narrow remote
  --   replies.
  -- - `request_data_lsb/msb`: Send a 64-bit remote-AHB write as two 32-bit misc
  --   flits.
  -- - `reply_data_lsb/msb`: Reassemble a 64-bit remote-AHB read from two 32-bit
  --   misc flits.
  -- - `request_data_ack`: Complete AXI write response on channel B.
  type axi_fsm is (idle, wait_wdata,
                   rmw_read_header, rmw_read_address, rmw_read_length,
                   rmw_read_reply_header, rmw_read_reply_data,
                   rmw_write_header, rmw_write_address, rmw_write_length, rmw_write_data,
                   dma_write_header, dma_write_address, dma_write_length, dma_write_data,
                   request_header, request_address, request_length, request_data,
                   reply_header, reply_data, request_data_lsb, request_data_msb,
                   reply_data_lsb, reply_data_msb, request_data_ack);

  type transaction_type is record
    -- Selected master interfaces
    xindex                 : integer range 0 to nmst - 1;
    -- Transaction info from AXI
    write                  : std_ulogic;
    id                     : std_logic_vector (XID_WIDTH-1 downto 0);
    addr                   : std_logic_vector (GLOB_PHYS_ADDR_BITS - 1 downto 0);
    len                    : std_logic_vector (8 downto 0);
    size                   : std_logic_vector (2 downto 0);
    burst                  : std_logic_vector (1 downto 0);
    lock                   : std_logic;
    cache                  : std_logic_vector (3 downto 0);
    prot                   : std_logic_vector (2 downto 0);
    qos                    : std_logic_vector (3 downto 0);
    atop                   : std_logic_vector(5 downto 0);
    region                 : std_logic_vector(3 downto 0);
    user                   : std_logic_vector(XUSER_WIDTH-1 downto 0);
    -- NoC transaction info
    msg_type               : noc_msg_type;
    reserved               : reserved_field_type;
    mem_x                  : local_yx;
    mem_y                  : local_yx;
    addr_msb               : std_logic_vector(11 downto 0);
    hsize_msb              : std_ulogic;  -- Distinguishes HSIZE_WORD from HSIZE_DWORD.
    dst_is_mem             : std_ulogic;
    -- NoC flits
    header                 : std_logic_vector(this_noc_flit_size - 1 downto 0);
    header_narrow          : misc_noc_flit_type;
    payload_address        : std_logic_vector(this_noc_flit_size - 1 downto 0);
    payload_address_narrow : misc_noc_flit_type;
    payload_length         : std_logic_vector(this_noc_flit_size - 1 downto 0);
    payload_length_narrow  : misc_noc_flit_type;
  end record transaction_type;

  constant transaction_none : transaction_type := (
    xindex                 => 0,
    write                  => '0',
    id                     => (others => '0'),
    addr                   => (others => '0'),
    len                    => (others => '0'),
    size                   => (others => '0'),
    burst                  => (others => '0'),
    lock                   => '0',
    cache                  => (others => '0'),
    prot                   => (others => '0'),
    qos                    => (others => '0'),
    atop                   => (others => '0'),
    region                 => (others => '0'),
    user                   => (others => '0'),
    msg_type               => (others => '0'),
    reserved               => (others => '0'),
    mem_x                  => (others => '0'),
    mem_y                  => (others => '0'),
    addr_msb               => (others => '0'),
    hsize_msb              => '0',
    dst_is_mem             => '0',
    header                 => (others => '0'),
    header_narrow          => (others => '0'),
    payload_address        => (others => '0'),
    payload_address_narrow => (others => '0'),
    payload_length         => (others => '0'),
    payload_length_narrow  => (others => '0')
    );

  constant AXI_STRB_WIDTH     : integer := AXIDW / 8;
  constant AXI_STRB_LSB_BITS  : integer := ncpu_log(AXI_STRB_WIDTH);

  type int_array is array (natural range <>) of integer;
  -- WSTRB segmentation sizes. This list assumes up to a 64-bit AXI data bus.
  -- The order is intentional: the splitter is greedy and always tries the
  -- largest naturally aligned chunk first. That means one mask can produce a
  -- mix of segment sizes, but each segment is maximal for its starting lane.
  -- Example on an 8-byte beat:
  -- - WSTRB = 11110000 -> one 4-byte segment at offset 4.
  -- - WSTRB = 00111100 -> one 2-byte segment at offset 2, then one 2-byte
  --   segment at offset 4 (cannot emit one 4-byte segment at offset 2 because
  --   it is not 4-byte aligned).
  constant WSTRB_SIZES : int_array(0 to 3) := (8, 4, 2, 1);
  constant WSTRB_ALL_ZERO : std_logic_vector(AXI_STRB_WIDTH - 1 downto 0) := (others => '0');
  constant WSTRB_ALL_ONE  : std_logic_vector(AXI_STRB_WIDTH - 1 downto 0) := (others => '1');

  type wstrb_seg_type is record
    -- `valid=1` means at least one enabled byte remains in the current mask.
    valid      : std_ulogic;
    -- Byte-lane offset from the aligned beat base (`align_addr_to_strb` output).
    offset     : integer range 0 to AXI_STRB_WIDTH - 1;
    -- Segment width in bytes (1/2/4/8 for AXI64).
    size_bytes : integer range 1 to AXI_STRB_WIDTH;
    -- Remaining bytes after removing the selected segment.
    mask_next  : std_logic_vector(AXI_STRB_WIDTH - 1 downto 0);
  end record wstrb_seg_type;

  function size_bytes_to_hsize (size_bytes : integer) return std_logic_vector is
  begin
    case size_bytes is
      when 1      => return HSIZE_BYTE;
      when 2      => return HSIZE_HWORD;
      when 4      => return HSIZE_WORD;
      when others => return HSIZE_DWORD;
    end case;
  end function size_bytes_to_hsize;

  -- Encode HSIZE into the DMA header size field (`nocpackage` DMA_HDR_SIZE_*).
  -- Encoding: 00=byte, 01=halfword, 10=word, 11=dword.
  function hsize_to_dma_code (size : std_logic_vector(2 downto 0)) return std_logic_vector is
  begin
    if size = HSIZE_BYTE then
      return "00";
    elsif size = HSIZE_HWORD then
      return "01";
    elsif size = HSIZE_WORD then
      return "10";
    else
      return "11";
    end if;
  end function hsize_to_dma_code;

  -- Convert any byte address in the beat to the beat base by clearing the
  -- low AXI_STRB_LSB_BITS address bits. Split segments then add `offset` to
  -- this aligned base so each sub-transaction points at the correct lane.
  function align_addr_to_strb (addr : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0)) return std_logic_vector is
    variable aligned : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0) := addr;
  begin
    if AXI_STRB_LSB_BITS > 0 then
      for i in 0 to AXI_STRB_LSB_BITS - 1 loop
        aligned(i) := '0';
      end loop;
    end if;
    return aligned;
  end function align_addr_to_strb;

  -- Extract the next contiguous, naturally aligned WSTRB segment from a mask.
  -- Algorithm:
  -- 1) Find the first set bit (LSB) in the mask.
  -- 2) Try the largest supported size (8/4/2/1 bytes) that is aligned and fully set.
  -- 3) Return the segment offset/size and clear those bits in `mask_next`.
  -- Repeated calls walk a beat until `mask_next` is all zeros.
  -- Important behavioral details:
  -- - This function does not mutate state. The caller decides when to commit
  --   `mask_next` (here this only happens after a data flit is accepted).
  -- - The first set bit anchors each step, so emission order always moves from
  --   lower byte lanes to higher byte lanes.
  -- - "Naturally aligned" means `offset mod size_bytes = 0`, which guarantees
  --   each segment maps to a legal AHB/NoC access width at that address.
  function next_wstrb_segment (mask : std_logic_vector(AXI_STRB_WIDTH - 1 downto 0)) return wstrb_seg_type is
    variable seg       : wstrb_seg_type;
    variable lsb       : integer := 0;
    variable found     : boolean := false;
    variable size_bytes: integer := 1;
    variable all_set   : boolean := false;
    variable mask_next : std_logic_vector(AXI_STRB_WIDTH - 1 downto 0);
  begin
    seg.valid      := '0';
    seg.offset     := 0;
    seg.size_bytes := 1;
    seg.mask_next  := mask;

    -- Find the lowest enabled byte lane that still needs to be emitted.
    for i in 0 to AXI_STRB_WIDTH - 1 loop
      if (mask(i) = '1') and (not found) then
        lsb := i;
        found := true;
      end if;
    end loop;

    if found then
      seg.valid  := '1';
      seg.offset := lsb;
      mask_next  := mask;
      -- Greedy width selection at this lane: 8B, then 4B, then 2B, then 1B.
      for idx in WSTRB_SIZES'range loop
        size_bytes := WSTRB_SIZES(idx);
        if size_bytes <= AXI_STRB_WIDTH and (lsb mod size_bytes) = 0 and (lsb + size_bytes - 1) < AXI_STRB_WIDTH then
          all_set := true;
          -- Candidate width is usable only if every byte in the window is set.
          for j in 0 to size_bytes - 1 loop
            if mask(lsb + j) = '0' then
              all_set := false;
            end if;
          end loop;
          if all_set then
            seg.size_bytes := size_bytes;
            -- Consume this segment from the mask; remaining bits drive next loop.
            for j in 0 to size_bytes - 1 loop
              mask_next(lsb + j) := '0';
            end loop;
            seg.mask_next := mask_next;
            exit;
          end if;
        end if;
      end loop;
    end if;
    return seg;
  end function next_wstrb_segment;

  -- NoC flit conventions used in this block (`nocpackage` header diagrams):
  -- - Header flits are produced by `create_header`/`create_header_misc`.
  -- - Address flits use `PREAMBLE_BODY` and carry the target address.
  -- - Length flits are used for reads and non-coherent DMA writes
  --   (`DMA_FROM_DEV`); other writes omit the length flit.
  -- - Write data flits use `PREAMBLE_TAIL` on the last beat. Segmented writes
  --   treat each segment as a single-beat tail.
  constant this_noc_flit_pad : std_logic_vector(MAX_NOC_FLIT_SIZE - this_noc_flit_size downto 0) := (others => '0');

  signal transaction, transaction_reg : transaction_type;
  signal current_state, next_state    : axi_fsm;
  signal selected                     : std_ulogic;
  signal sample_flits                 : std_ulogic;

  signal remote_ahbs_rcv_data_out_hold  : misc_noc_flit_type;
  signal sample_and_hold : std_ulogic;

  -- WSTRB-aware write control signals:
  -- - `split_active`: Always split CPU-style memory writes by WSTRB.
  --   This path intentionally treats every beat as a mask-driven sequence, even
  --   when WSTRB is full, so all write widths are derived from the same logic.
  -- - `dma_split_active`: Split non-coherent DMA writes only when WSTRB is
  --   partial. Full-WSTRB DMA uses a dedicated one-beat fast path.
  -- - `segment_active`: Effective per-segment mode for the current buffered beat.
  -- - `write_hold_active`: Enable AW/W decoupling only on memory writes.
  --   This isolates NoC scheduling from AXI channel skew (AW can arrive before W).
  signal split_active        : std_ulogic;
  signal dma_split_active    : std_ulogic;
  signal segment_active      : std_ulogic;
  signal write_hold_active   : std_ulogic;
  signal aw_accepted         : std_ulogic;
  signal wdata_valid         : std_ulogic;
  signal wdata_reg           : std_logic_vector(AXIDW - 1 downto 0);
  signal wstrb_reg           : std_logic_vector(AXI_STRB_WIDTH - 1 downto 0);
  signal wlast_reg           : std_ulogic;
  signal beat_index_reg      : integer range 0 to 255;
  signal beat_addr_reg       : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  signal seg_mask_reg        : std_logic_vector(AXI_STRB_WIDTH - 1 downto 0);

  -- Current segment extracted from `seg_mask_reg` (offset, size, and `mask_next`).
  signal seg_info            : wstrb_seg_type;
  signal seg_size            : std_logic_vector(2 downto 0);
  signal seg_addr            : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  signal seg_mask_next       : std_logic_vector(AXI_STRB_WIDTH - 1 downto 0);
  signal seg_has_data        : std_ulogic;
  signal seg_last_in_beat    : std_ulogic;
  -- RMW staging signals:
  -- - `rmw_read_sample` captures the readback word used for merge.
  -- - `rmw_write_done` marks completion of the merged write beat.
  signal rmw_read_sample     : std_ulogic;
  signal rmw_write_done      : std_ulogic;
  signal buffered_write_done : std_ulogic;
  signal rmw_read_data_reg   : std_logic_vector(AHBDW - 1 downto 0);
  signal rmw_mask_data       : std_logic_vector(AHBDW - 1 downto 0);
  signal rmw_merge_data      : std_logic_vector(AHBDW - 1 downto 0);
  signal rmw_addr_aligned    : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  signal rmw_read_header_flit   : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal rmw_read_address_flit  : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal rmw_read_length_flit   : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal rmw_write_header_flit  : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal rmw_write_address_flit : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal rmw_write_length_flit  : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal rmw_write_needs_length : std_ulogic;
  signal rmw_payload_data       : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal dma_write_header_flit  : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal dma_write_address_flit : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal dma_write_length_flit  : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal dma_write_payload_data : std_logic_vector(this_noc_flit_size - 1 downto 0);

  -- Active packet fields mirror `transaction_reg` and are optionally overridden
  -- by per-segment address/size/message metadata while splitting a write beat.
  signal active_addr               : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  signal active_size               : std_logic_vector(2 downto 0);
  signal active_msg_type           : noc_msg_type;
  signal active_hsize_msb          : std_ulogic;
  signal active_header             : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal active_header_narrow      : misc_noc_flit_type;
  signal active_payload_address    : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal active_payload_address_narrow : misc_noc_flit_type;
  signal active_payload_length     : std_logic_vector(this_noc_flit_size - 1 downto 0);
  signal active_payload_length_narrow : misc_noc_flit_type;

  -- One-cycle control strobes consumed by the sequential state/buffer process.
  signal latch_wbeat         : std_ulogic;
  signal advance_segment     : std_ulogic;
  signal skip_beat           : std_ulogic;
  signal skip_last           : std_ulogic;
  signal aw_handshake        : std_ulogic;

  -----------------------------------------------------------------------------
  -- Multi-outstanding support (enabled only when retarget_for_dma = 1).
  -----------------------------------------------------------------------------
  -- Architecture decision:
  -- - The CPU instantiations of this proxy (`tile_cpu.vhd`, retarget_for_dma=0)
  --   keep the legacy single-FSM behavior bit-identical -- they sit in
  --   `gen_legacy` below.
  -- - The AXI-accelerator instantiation (`noc2axi_interface.vhd`,
  --   retarget_for_dma=1, i.e. every generated AXI-accelerator socket) gets
  --   the new design: a request FSM
  --   that issues + retires reads through an outstanding table, and a
  --   separate response FSM that matches returning DMA flits to slots via
  --   `get_dma_tran_id` and drives `somi.r.*` with the matched AXI ID.
  --
  -- Concurrency policy enforced by the new request FSM:
  -- 1) Stall a new read if the same AXI ID has an outstanding read in flight
  --    (AXI same-ID read-ordering rule -- simplest correct option).
  -- 2) Stall a new read if the outstanding table is full.
  -- 3) When `coherence = ACC_COH_LLC or ACC_COH_RECALL`, allow at most one
  --    outstanding read (LLC does not echo DMA_TRAN_ID, so matching falls
  --    back to "the only in-flight read"). This is the deferred-LLC fallback.
  -- 4) Writes do NOT enter the outstanding table; the request FSM acks B
  --    locally just like the legacy `request_data_ack` (writes are
  --    fire-and-forget on the NoC for DMA).
  --
  -- Reordering correctness:
  -- - Request packets are emitted whole and in program order on `dma_snd`,
  --   so per-destination NoC ordering preserves RAW/WAR/WAW hazards.
  -- - Reordering of *responses* across memory tiles is resolved by the
  --   response FSM via the per-slot DMA_TRAN_ID echoed in the response
  --   header by `noc2aximst`.
  -- Sized for an accelerator with a deep miss pipeline; the driving case was
  -- Vortex, whose per-core icache MSHR fan-out is 16 with comparable per-bank
  -- dcache MSHRs. End-to-end concurrency is still capped
  -- at MAX_DMA_OT * num_memory_tiles on the memory side; the extra slots
  -- here just smooth issue/NoC pipeline latency so the accelerator's AR doesn't
  -- stall before memory saturates. Must remain <= 2**DMA_TRAN_ID_WIDTH.
  constant OUTSTANDING_DEPTH : integer := 8;
  -- Sanity: the local slot index must fit in the wire field width.
  -- DMA_TRAN_ID_WIDTH = 4 gives 16 contexts; we use 4 here. Add a constant
  -- check that elaboration fails loudly if either side is misconfigured.
  -- (VHDL: a function-call-based static check would be cleaner; this
  -- comment documents the invariant -- ceil(log2(OUTSTANDING_DEPTH)) <=
  -- DMA_TRAN_ID_WIDTH.)

  subtype outstanding_idx_t is integer range 0 to OUTSTANDING_DEPTH - 1;

  -- One outstanding-table entry captures the per-read context needed by the
  -- response FSM to drive somi.r.* correctly when the response arrives.
  type outstanding_entry_type is record
    valid    : std_ulogic;
    id       : std_logic_vector(XID_WIDTH - 1 downto 0);
    xindex   : integer range 0 to nmst - 1;
    size     : std_logic_vector(2 downto 0);
    addr     : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    dst_is_mem : std_ulogic;
  end record outstanding_entry_type;

  constant outstanding_entry_none : outstanding_entry_type := (
    valid      => '0',
    id         => (others => '0'),
    xindex     => 0,
    size       => (others => '0'),
    addr       => (others => '0'),
    dst_is_mem => '0');

  type outstanding_array_type is array (0 to OUTSTANDING_DEPTH - 1) of outstanding_entry_type;
  signal outstanding_reg : outstanding_array_type;

  -- Request FSM: legacy issue states + a `req_commit` state that pushes a
  -- newly-issued read into the outstanding table and returns to idle (so
  -- the FSM doesn't park waiting for the response). Writes never enter
  -- `req_commit`; they use the existing `request_data_ack`.
  type req_fsm_type is (
    req_idle, req_wait_wdata,
    req_rmw_read_header, req_rmw_read_address, req_rmw_read_length,
    req_rmw_read_reply_header, req_rmw_read_reply_data,
    req_rmw_write_header, req_rmw_write_address, req_rmw_write_length, req_rmw_write_data,
    req_dma_write_header, req_dma_write_address, req_dma_write_length, req_dma_write_data,
    req_header, req_address, req_length, req_data,
    req_data_lsb, req_data_msb, req_data_ack,
    req_commit);
  signal req_state, req_next : req_fsm_type;

  -- Per-request latched allocation index. `ot_alloc_idx` is a *live*
  -- combinational function of `outstanding_reg`, so reading it separately in
  -- `req_header` (tran_id stamp) and `req_commit` (table push) can yield two
  -- different slots for one read when responses free slots in between -- the
  -- on-wire DMA_TRAN_ID then disagrees with the slot the context lands in, and
  -- two reads can even stamp the same ID. Latch the index once when the read
  -- is sampled (see ot_seq) and reuse it for both, so stamp == slot always.
  signal req_alloc_idx_reg : outstanding_idx_t;

  -- Response FSM: independent of the request FSM. Drains the DMA receive
  -- queue, matches the header's DMA_TRAN_ID to an outstanding slot, then
  -- streams data flits to somi.r.* with somi.r.id from that slot.
  -- `rsp_drop` is a defensive state for an unmatched response (e.g. stale
  -- flit during slot reuse) -- it consumes flits to the tail and returns
  -- to idle. With the same-id guard and slot-free-on-tail, this should
  -- never fire in practice.
  type rsp_fsm_type is (rsp_idle, rsp_data, rsp_drop);
  signal rsp_state, rsp_next : rsp_fsm_type;
  signal rsp_active_valid_reg : std_ulogic;
  signal rsp_active_idx_reg   : outstanding_idx_t;
  signal load_rsp_active      : std_ulogic;
  signal load_rsp_active_idx  : outstanding_idx_t;
  signal clear_rsp_active     : std_ulogic;

  -- One-cycle control strobes for the outstanding table sequential block.
  signal push_outstanding         : std_ulogic;
  signal push_outstanding_entry   : outstanding_entry_type;
  signal push_outstanding_idx     : outstanding_idx_t;
  signal free_outstanding         : std_ulogic;
  signal free_outstanding_idx     : outstanding_idx_t;

  -- Combinational pre-issue checks (computed in the request FSM process).
  signal ot_alloc_idx          : outstanding_idx_t;
  signal ot_alloc_avail        : std_ulogic;
  signal ot_same_read_id_busy  : std_ulogic;
  signal ot_any_read_busy      : std_ulogic;

  -- Two intermediates to avoid VHDL "two-process partial-record multi-driver"
  -- on `somi`. In gen_dma_ot the req FSM drives `req_somi` (aw/ar/w/b) and the
  -- rsp FSM drives `rsp_somi.r`; a single concurrent merge inside the generate
  -- combines them into the actual `somi` output port, so there is exactly one
  -- driver per signal regardless of how many subfields each FSM touches.
  -- (In gen_legacy these intermediates are unused.)
  signal req_somi : axi_somi_vector(0 to nmst - 1);
  signal rsp_somi : axi_somi_vector(0 to nmst - 1);

  -- Same idea for coherence_rsp_rcv_rdreq, which both the request FSM
  -- (req_rmw_read_reply_* states, when LLC RMW is consuming its sub-read
  -- response) and the response FSM dequeue from. They are mutually exclusive
  -- by the LLC-fallback issue guard (LLC mode = single-outstanding), but VHDL
  -- still forbids two drivers on the same std_ulogic port. A combine
  -- concurrent assignment inside gen_dma_ot ORs the two strobes.
  signal req_coh_rsp_rdreq : std_ulogic;
  signal rsp_coh_rsp_rdreq : std_ulogic;

begin  -- rtl

  make_packet: process (mosi, local_y, local_x)
    variable tran : transaction_type;
    variable adj_mem_axi_port : integer range 0 to NAHBSLV - 1;
  begin  -- process make_packet

    -- Default
    tran := transaction_none;
    selected <= '0';

    -- Prioritize masters (0 highest priority) and set xindex
    for i in  nmst - 1 downto 0 loop
      -- Higher priority to master with low index
      if (mosi(i).aw.valid or mosi(i).ar.valid) = '1' then
        tran.xindex := i;
        selected <= '1';
      end if;
    end loop;  -- i

    -- Set write
    tran.write := mosi(tran.xindex).aw.valid;

    -- set ctrl
    if tran.write = '1' then
      tran.id     := mosi(tran.xindex).aw.id;
      tran.addr   := mosi(tran.xindex).aw.addr;
      tran.len    := ('0' & mosi(tran.xindex).aw.len) + "0000001";
      tran.size   := mosi(tran.xindex).aw.size;
      tran.burst  := mosi(tran.xindex).aw.burst;
      tran.lock   := mosi(tran.xindex).aw.lock;
      tran.cache  := mosi(tran.xindex).aw.cache;
      tran.prot   := mosi(tran.xindex).aw.prot;
      tran.qos    := mosi(tran.xindex).aw.qos;
      tran.atop   := mosi(tran.xindex).aw.atop;
      tran.region := mosi(tran.xindex).aw.region;
      tran.user   := mosi(tran.xindex).aw.user;
    else
      tran.id     := mosi(tran.xindex).ar.id;
      tran.addr   := mosi(tran.xindex).ar.addr;
      tran.len    := ('0' & mosi(tran.xindex).ar.len) + "0000001";
      tran.size   := mosi(tran.xindex).ar.size;
      tran.burst  := mosi(tran.xindex).ar.burst;
      tran.lock   := mosi(tran.xindex).ar.lock;
      tran.cache  := mosi(tran.xindex).ar.cache;
      tran.prot   := mosi(tran.xindex).ar.prot;
      tran.qos    := mosi(tran.xindex).ar.qos;
      tran.region := mosi(tran.xindex).ar.region;
      tran.user   := mosi(tran.xindex).ar.user;
    end if;

    -- Get routing info
    tran.mem_x := mem_info(0).x;
    tran.mem_y := mem_info(0).y;

    -- TODO: support larger address space / regions
    tran.addr_msb := tran.addr(GLOB_PHYS_ADDR_BITS - 1 downto GLOB_PHYS_ADDR_BITS - 12);

    if mem_num /= 1 then
      for i in 0 to mem_num - 1 loop
        -- Need to match which memory split is selected
        if ((tran.addr_msb xor conv_std_logic_vector(mem_info(i).haddr, 12))
            and conv_std_logic_vector(mem_info(i).hmask, 12)) = X"000" then
          tran.mem_x := mem_info(i).x;
          tran.mem_y := mem_info(i).y;
        end if;
      end loop;  -- i
    end if;

    -- Determine whether memory is selected
    if mem_axi_port = -1 then
      adj_mem_axi_port := 0;
    else
      adj_mem_axi_port := mem_axi_port;
    end if;
    if tran.xindex = adj_mem_axi_port or mem_axi_port = -1 then
      tran.dst_is_mem :=  '1';
    else
      tran.mem_x := slv_x;
      tran.mem_y := slv_y;
    end if;

    -- Set message type
    if tran.size = HSIZE_DWORD then
      tran.hsize_msb := '1';
    end if;

    if tran.write = '1' then
      if retarget_for_dma = 1 then
        if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
          tran.msg_type := REQ_DMA_WRITE;
        else
          tran.msg_type := DMA_FROM_DEV;   -- This request is non coherent, but
                                           -- noc2ahbmst must skip
                                           -- receive_wrlength, which only exists
                                           -- for DMA_FROM_DEV from accelerators.
                                           -- We use this workaround because
                                           -- systems without DDR controller are
                                           -- using a FPGA-to-memory link on
                                           -- which we do not send the tail bit
                                           -- to save some I/O pads.
        end if;
      else -- Processor core request
        if tran.dst_is_mem = '1' then
          -- Send to Memory
          if tran.size = HSIZE_BYTE then
            tran.msg_type := REQ_GETM_B;
          elsif tran.size = HSIZE_HWORD then
            tran.msg_type := REQ_GETM_HW;
          else
            tran.msg_type := REQ_GETM_W;
          end if;
        else
          -- Send to remote slave uncached
          tran.msg_type := AHB_WR;
        end if;
      end if;
    else
      if retarget_for_dma = 1 then
        if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
          tran.msg_type := REQ_DMA_READ;
        else
          tran.msg_type := DMA_TO_DEV;
        end if;
      else -- Processor core request
        if tran.dst_is_mem = '1' then
          -- Send to Memory
          if tran.size = HSIZE_BYTE then
            tran.msg_type := REQ_GETS_B;
          elsif tran.size = HSIZE_HWORD then
            tran.msg_type := REQ_GETS_HW;
          else
            tran.msg_type := REQ_GETS_W;
          end if;
        else
          -- Send to remote slave uncached
          tran.msg_type := AHB_RD;
        end if;
      end if;
    end if;

    -- Set address
    tran.payload_address(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    tran.payload_address(GLOB_PHYS_ADDR_BITS - 1 downto 0) := tran.addr;

    tran.payload_address_narrow(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    tran.payload_address_narrow(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0) := tran.addr(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);

    -- Set length
    if tran.write = '1' then
      tran.payload_length(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    else
      tran.payload_length(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    end if;
    tran.payload_length(8 downto 0) := tran.len;
    -- (read transaction only)
    tran.payload_length_narrow(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    tran.payload_length_narrow(8 downto 0) := tran.len;

    -- Create header flit
    tran.reserved             := (others => '0');
    tran.reserved(3)          := tran.hsize_msb;
    tran.reserved(2 downto 0) := tran.prot;

    tran.header := create_header(this_noc_flit_size, local_y, local_x, tran.mem_y, tran.mem_x, tran.msg_type, tran.reserved);
    tran.header_narrow := create_header_misc(MISC_NOC_FLIT_SIZE, local_y, local_x, tran.mem_y, tran.mem_x, tran.msg_type, tran.reserved(RESERVED_WIDTH_MISC-1 downto 0))(MISC_NOC_FLIT_SIZE - 1 downto 0);

    -- Write signal
    transaction <= tran;
  end process make_packet;

  -- WSTRB handling summary by transaction class:
  -- - Reads (any destination): Use the baseline read states unchanged.
  -- - Remote AHB writes (`dst_is_mem='0'`): No WSTRB splitting or RMW support;
  --   path is `request_header -> request_address -> request_data[_lsb/_msb]
  --   -> request_data_ack`.
  -- - Non-DMA memory writes (`retarget_for_dma=0`): Always split by WSTRB;
  --   `wait_wdata -> request_header/address/data` (loop per segment)
  --   -> `request_data_ack`.
  -- - Non-coherent DMA memory writes (`retarget_for_dma=1`, non-LLC):
  --   - Full WSTRB: `wait_wdata -> dma_write_header/address/[length]/data`
  --     -> `request_data_ack`.
  --   - Partial WSTRB: `wait_wdata -> request_header/address/[length]/data`
  --     (loop per segment) -> `request_data_ack`, with per-segment size encoded
  --     in DMA header reserved bits.
  -- - Coherent DMA memory writes (`retarget_for_dma=1`, LLC/RECALL):
  --   - Full WSTRB: `wait_wdata -> dma_write_header/address/data`
  --     -> `request_data_ack`.
  --   - Partial WSTRB: `wait_wdata -> rmw_read_* -> rmw_write_*`
  --     -> `request_data_ack`.
  -- Why the coherent partial path is different:
  -- - Coherent writes cannot emit independent byte/halfword NoC writes directly
  --   without risking stale bytes in untouched lanes.
  -- - The proxy therefore fetches the full aligned word, merges with AXI data
  --   using WSTRB, and writes back one full-word result.
  -- Delay summary:
  -- - Non-memory traffic is unchanged by this logic.
  -- - A memory-write beat is first buffered (`wait_wdata`) before emission.
  -- - Partial masks can expand one AXI beat into N NoC write micro-transactions.
  -- - A `WSTRB=0` beat is dropped locally (no NoC delay for that beat).
  split_active <= '1' when (retarget_for_dma = 0 and transaction_reg.write = '1' and transaction_reg.dst_is_mem = '1') else '0';
  dma_split_active <= '1' when (retarget_for_dma = 1 and transaction_reg.write = '1' and transaction_reg.dst_is_mem = '1'
                                and wdata_valid = '1' and wstrb_reg /= WSTRB_ALL_ONE
                                and coherence /= ACC_COH_LLC and coherence /= ACC_COH_RECALL) else '0';
  segment_active <= split_active or dma_split_active;
  write_hold_active <= '1' when (transaction_reg.write = '1' and transaction_reg.dst_is_mem = '1') else '0';

  -- Drive a single write segment from the current WSTRB mask.
  -- Split mechanics:
  -- 1) `latch_wbeat` (clocked process) seeds `seg_mask_reg` from WSTRB for beats
  --    that are allowed to segment; otherwise it seeds all ones for full-beat
  --    handling.
  -- 2) `next_wstrb_segment(seg_mask_reg)` chooses the next naturally aligned
  --    chunk (prefers 8B, then 4B, then 2B, then 1B), and returns offset, size,
  --    and `mask_next`.
  -- 3) `active_addr`/`active_size` override `transaction_reg` for that chunk.
  -- 4) `request_header/address/data` emit one NoC micro-transaction for that chunk.
  -- 5) `advance_segment` (clocked process) commits
  --    `seg_mask_reg := seg_mask_next`. If `seg_last_in_beat='1'`, the buffered
  --    beat retires; otherwise the FSM loops to `request_header` for the next
  --    chunk from the same AXI beat.
  -- Segment correctness guarantees:
  -- - Address: `seg_addr = align_addr_to_strb(beat_addr_reg) + offset`.
  -- - Width:   `seg_size = size_bytes_to_hsize(seg_info.size_bytes)`.
  -- - Data:    `request_data` selects byte lanes from `wdata_reg` using the
  --   same `active_addr/active_size` pair, so payload lanes match the header.
  -- `next_wstrb_segment()` is purely combinational. Advancing to `mask_next` is
  -- sequenced in the clocked process when a segment is actually emitted.
  seg_info      <= next_wstrb_segment(seg_mask_reg);
  seg_size      <= size_bytes_to_hsize(seg_info.size_bytes);
  seg_mask_next <= seg_info.mask_next;
  seg_has_data  <= seg_info.valid;
  seg_last_in_beat <= '1' when (seg_has_data = '1' and seg_mask_next = WSTRB_ALL_ZERO) else '0';

  seg_addr <= std_logic_vector(unsigned(align_addr_to_strb(beat_addr_reg)) + to_unsigned(seg_info.offset, GLOB_PHYS_ADDR_BITS));
  rmw_addr_aligned <= align_addr_to_strb(beat_addr_reg);

  -- While segmenting, drive per-segment address/size so headers and payloads
  -- stay aligned. For non-segmented transfers, `active_*` aliases
  -- `transaction_reg` fields.
  active_addr <= seg_addr when (segment_active = '1' and wdata_valid = '1' and seg_has_data = '1') else transaction_reg.addr;
  active_size <= seg_size when (segment_active = '1' and wdata_valid = '1' and seg_has_data = '1') else transaction_reg.size;

  -- Build packet/flits for the active transfer unit: either the full original
  -- beat or one WSTRB-derived segment.
  make_active_packet: process (transaction_reg, active_addr, active_size, local_y, local_x, segment_active, dma_split_active)
    variable msg_type   : noc_msg_type;
    variable reserved   : reserved_field_type;
    variable hsize_msb  : std_ulogic;
    variable header_v   : std_logic_vector(this_noc_flit_size - 1 downto 0);
    variable header_n_v : misc_noc_flit_type;
    variable addr_v     : std_logic_vector(this_noc_flit_size - 1 downto 0);
    variable addr_n_v   : misc_noc_flit_type;
    variable len_v      : std_logic_vector(this_noc_flit_size - 1 downto 0);
    variable len_n_v    : misc_noc_flit_type;
  begin
    msg_type  := transaction_reg.msg_type;
    hsize_msb := transaction_reg.hsize_msb;

    if segment_active = '1' then
      -- For non-DMA split writes, rewrite message type so `noc2ahbmst` sees the
      -- segment width (B/HW/W) instead of the original beat width.
      hsize_msb := '0';
      if active_size = HSIZE_DWORD then
        hsize_msb := '1';
      end if;
      if retarget_for_dma = 0 then
        if transaction_reg.write = '1' then
          if transaction_reg.dst_is_mem = '1' then
            if active_size = HSIZE_BYTE then
              msg_type := REQ_GETM_B;
            elsif active_size = HSIZE_HWORD then
              msg_type := REQ_GETM_HW;
            else
              msg_type := REQ_GETM_W;
            end if;
          else
            msg_type := AHB_WR;
          end if;
        end if;
      end if;
    end if;

    -- Reserved-field usage in this proxy (`nocpackage` DMA header layout):
    -- - `reserved[2:0]`: AXI PROT (mapped into HPROT[2:0]).
    -- - `reserved[3]`: HSIZE MSB for non-DMA (WORD vs DWORD).
    -- - `reserved[6:4]`: DMA size override when enabled (`sizev + size[1:0]`).
    reserved             := (others => '0');
    reserved(3)          := hsize_msb;
    reserved(2 downto 0) := transaction_reg.prot;
    if retarget_for_dma = 1 and dma_split_active = '1' then
      -- DMA header size override (`nocpackage` DMA_HDR_* constants). Used when
      -- partial WSTRB splits a beat into subword DMA packets.
      reserved(DMA_HDR_SIZE_VALID_BIT) := '1';
      reserved(DMA_HDR_SIZE_MSB downto DMA_HDR_SIZE_LSB) := hsize_to_dma_code(active_size);
    end if;

    header_v   := create_header(this_noc_flit_size, local_y, local_x, transaction_reg.mem_y, transaction_reg.mem_x, msg_type, reserved);
    header_n_v := create_header_misc(MISC_NOC_FLIT_SIZE, local_y, local_x, transaction_reg.mem_y, transaction_reg.mem_x, msg_type, reserved(RESERVED_WIDTH_MISC-1 downto 0))(MISC_NOC_FLIT_SIZE - 1 downto 0);

    addr_v := (others => '0');
    addr_v(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    addr_v(GLOB_PHYS_ADDR_BITS - 1 downto 0) := active_addr;

    addr_n_v := (others => '0');
    addr_n_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    addr_n_v(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0) := active_addr(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);

    len_v := (others => '0');
    if transaction_reg.write = '1' then
      len_v(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    else
      len_v(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    end if;
    if retarget_for_dma = 1 then
      -- DMA length semantics:
      -- - `DMA_FROM_DEV` writes always carry a single-beat length in this path.
      -- - Other requests carry transaction length from the AXI command.
      if transaction_reg.write = '1' and transaction_reg.msg_type = DMA_FROM_DEV then
        len_v(31 downto 0) := conv_std_logic_vector(1, 32);
      else
        len_v(31 downto 0) := conv_std_logic_vector(to_integer(unsigned(transaction_reg.len)), 32);
      end if;
    else
      len_v(8 downto 0) := transaction_reg.len;
    end if;

    len_n_v := (others => '0');
    len_n_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    len_n_v(8 downto 0) := transaction_reg.len;

    active_msg_type              <= msg_type;
    active_hsize_msb             <= hsize_msb;
    active_header                <= header_v;
    active_header_narrow         <= header_n_v;
    active_payload_address       <= addr_v;
    active_payload_address_narrow <= addr_n_v;
    active_payload_length        <= len_v;
    active_payload_length_narrow <= len_n_v;
  end process make_active_packet;

  -- Expand byte-level WSTRB bits into a full-width mask for merge.
  -- Byte `i` is `0xFF` when `WSTRB(i)=1`; otherwise it is `0x00`.
  rmw_mask_gen: process (wstrb_reg)
  begin
    for i in 0 to AXI_STRB_WIDTH - 1 loop
      rmw_mask_data(8 * (i + 1) - 1 downto 8 * i) <= (others => wstrb_reg(i));
    end loop;
  end process rmw_mask_gen;

  -- Preserve bytes masked off by WSTRB and overwrite selected bytes from `wdata_reg`.
  rmw_merge_data <= (rmw_read_data_reg and not rmw_mask_data) or (wdata_reg and rmw_mask_data);

  rmw_payload_gen: process (rmw_merge_data)
    variable payload_v : std_logic_vector(this_noc_flit_size - 1 downto 0);
  begin
    payload_v := (others => '0');
    payload_v(this_noc_flit_size-1 downto this_noc_flit_size - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    payload_v(AHBDW - 1 downto 0) := rmw_merge_data;
    rmw_payload_data <= payload_v;
  end process rmw_payload_gen;

  -- Build RMW packets for coherent partial-WSTRB writes:
  -- read one full aligned word, merge with buffered AXI data, then write back.
  make_rmw_packet: process (transaction_reg, coherence, local_y, local_x, rmw_addr_aligned)
    variable read_msg  : noc_msg_type;
    variable write_msg : noc_msg_type;
    variable reserved  : reserved_field_type;
    variable header_v  : std_logic_vector(this_noc_flit_size - 1 downto 0);
    variable addr_v    : std_logic_vector(this_noc_flit_size - 1 downto 0);
    variable len_v     : std_logic_vector(this_noc_flit_size - 1 downto 0);
  begin
    if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
      read_msg  := REQ_DMA_READ;
      write_msg := REQ_DMA_WRITE;
    else
      read_msg  := DMA_TO_DEV;
      write_msg := DMA_FROM_DEV;
    end if;

    reserved := (others => '0');

    header_v := create_header(this_noc_flit_size, local_y, local_x, transaction_reg.mem_y, transaction_reg.mem_x, read_msg, reserved);
    rmw_read_header_flit <= header_v;
    rmw_write_header_flit <= create_header(this_noc_flit_size, local_y, local_x, transaction_reg.mem_y, transaction_reg.mem_x, write_msg, reserved);

    addr_v := (others => '0');
    addr_v(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    addr_v(GLOB_PHYS_ADDR_BITS - 1 downto 0) := rmw_addr_aligned;
    rmw_read_address_flit <= addr_v;
    rmw_write_address_flit <= addr_v;

    len_v := (others => '0');
    len_v(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    len_v(31 downto 0) := conv_std_logic_vector(1, 32);
    rmw_read_length_flit <= len_v;

    len_v := (others => '0');
    len_v(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    len_v(31 downto 0) := conv_std_logic_vector(1, 32);
    rmw_write_length_flit <= len_v;

    -- Non-coherent DMA writes (`DMA_FROM_DEV`) require a length flit.
    -- Coherent DMA writes (`REQ_DMA_WRITE`) do not.
    if write_msg = DMA_FROM_DEV then
      rmw_write_needs_length <= '1';
    else
      rmw_write_needs_length <= '0';
    end if;
  end process make_rmw_packet;

  -- Build one-beat DMA write packet from buffered AXI write data.
  -- Used when `retarget_for_dma=1` and WSTRB is full (or in the
  -- non-coherent split path).
  make_dma_write_packet: process (transaction_reg, coherence, local_y, local_x, beat_addr_reg, wdata_reg)
    variable write_msg : noc_msg_type;
    variable reserved  : reserved_field_type;
    variable header_v  : std_logic_vector(this_noc_flit_size - 1 downto 0);
    variable addr_v    : std_logic_vector(this_noc_flit_size - 1 downto 0);
    variable len_v     : std_logic_vector(this_noc_flit_size - 1 downto 0);
    variable payload_v : std_logic_vector(this_noc_flit_size - 1 downto 0);
  begin
    if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
      write_msg := REQ_DMA_WRITE;
    else
      write_msg := DMA_FROM_DEV;
    end if;

    reserved := (others => '0');
    header_v := create_header(this_noc_flit_size, local_y, local_x, transaction_reg.mem_y, transaction_reg.mem_x, write_msg, reserved);
    dma_write_header_flit <= header_v;

    addr_v := (others => '0');
    addr_v(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    addr_v(GLOB_PHYS_ADDR_BITS - 1 downto 0) := beat_addr_reg;
    dma_write_address_flit <= addr_v;

    len_v := (others => '0');
    len_v(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    len_v(31 downto 0) := conv_std_logic_vector(1, 32);
    dma_write_length_flit <= len_v;

    payload_v := (others => '0');
    payload_v(this_noc_flit_size-1 downto this_noc_flit_size-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    payload_v(AHBDW - 1 downto 0) := wdata_reg;
    dma_write_payload_data <= payload_v;
  end process make_dma_write_packet;


  -- AXI-to-NoC combinational datapath and next-state logic.
  -- `axi_roundtrip` responsibilities:
  -- - Compute `next_state` from `current_state` and interface status.
  -- - Drive AXI and NoC outputs for the current cycle.
  -- - Raise one-cycle control strobes consumed by the clocked commit process.
  -- State semantics live in the `axi_fsm` comments above. The per-state comments
  -- below focus on transition behavior and protocol actions inside this process.
  --
  -- gen_legacy is the unmodified single-FSM design. It owns `axi_roundtrip`
  -- and the legacy clocked process (current_state + buffered-write context).
  -- It is the active code path for `retarget_for_dma = 0` (CPU sockets in
  -- `tile_cpu.vhd`). For `retarget_for_dma = 1` (the AXI-accelerator socket
  -- in `noc2axi_interface.vhd`, used by every AXI accelerator), `gen_dma_ot`
  -- further below
  -- replaces these processes with a split request/response design.
  gen_legacy: if retarget_for_dma /= 1 generate
  axi_roundtrip: process (transaction, transaction_reg, current_state, selected, mosi, coherence,
                          coherence_req_full,
                          coherence_rsp_rcv_data_out, coherence_rsp_rcv_empty,
                          remote_ahbs_snd_full,
                          remote_ahbs_rcv_data_out, remote_ahbs_rcv_empty,
                          remote_ahbs_rcv_data_out_hold,
                          split_active, segment_active, write_hold_active,
                          wdata_valid, wdata_reg, wstrb_reg, wlast_reg,
                          seg_has_data, seg_last_in_beat, seg_mask_next, active_addr, active_size,
                          active_header, active_header_narrow, active_payload_address,
                          active_payload_address_narrow, active_payload_length, active_payload_length_narrow,
                          rmw_read_header_flit, rmw_read_address_flit, rmw_read_length_flit,
                          rmw_write_header_flit, rmw_write_address_flit, rmw_write_length_flit,
                          rmw_write_needs_length, rmw_payload_data,
                          dma_write_header_flit, dma_write_address_flit, dma_write_length_flit,
                          dma_write_payload_data,
                          aw_accepted)
    variable wdata                   : std_logic_vector(AHBDW - 1 downto 0);
    variable wdata_src               : std_logic_vector(AXIDW - 1 downto 0);
    variable addr_for_data           : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    variable size_for_data           : std_logic_vector(2 downto 0);
    variable payload_data            : std_logic_vector(this_noc_flit_size - 1 downto 0);
    variable payload_data_narrow_lsb : misc_noc_flit_type;
    variable payload_data_narrow_msb : misc_noc_flit_type;
    variable rsp_preamble            : noc_preamble_type;
    variable slv_ready               : std_ulogic;
    variable slv_valid               : std_ulogic;
    variable mst_ready               : std_ulogic;
    variable mst_valid               : std_ulogic;
    variable mst_bready              : std_ulogic;
    variable last                    : std_ulogic;
  begin  -- process axi_roundtrip

    -- Default internal state
    next_state <= current_state;
    sample_flits <= '0';
    sample_and_hold <= '0';
    latch_wbeat <= '0';
    advance_segment <= '0';
    skip_beat <= '0';
    skip_last <= '0';
    aw_handshake <= '0';
    rmw_read_sample <= '0';
    rmw_write_done <= '0';
    buffered_write_done <= '0';

    -- Build AXI read data from the selected response path.
    if transaction_reg.dst_is_mem = '1' then
      rsp_preamble := get_preamble(this_noc_flit_size, this_noc_flit_pad & coherence_rsp_rcv_data_out);
      for i in 0 to nmst - 1 loop
        somi(i).r.data <= (coherence_rsp_rcv_data_out(AHBDW - 1 downto 0));
      end loop;
    else
      rsp_preamble := get_preamble(MISC_NOC_FLIT_SIZE, misc_noc_flit_pad & remote_ahbs_rcv_data_out);
      for i in 0 to nmst - 1 loop
        somi(i).r.data <= (others => '0');
        if transaction_reg.size = HSIZE_DWORD then
          somi(i).r.data(31 downto 0) <= remote_ahbs_rcv_data_out_hold(31 downto 0);
          somi(i).r.data(ARCH_BITS - 1 downto ARCH_BITS - 32) <= (remote_ahbs_rcv_data_out(31 downto 0));
        elsif transaction_reg.size = HSIZE_WORD then
          somi(i).r.data <= ahbdrivedata(remote_ahbs_rcv_data_out(31 downto 0));
        elsif transaction_reg.size = HSIZE_HWORD then
          case transaction_reg.addr(1) is
            when '0'    => somi(i).r.data <= ahbdrivedata(remote_ahbs_rcv_data_out(15 downto 0));
            when others => somi(i).r.data <= ahbdrivedata(remote_ahbs_rcv_data_out(31 downto 16));
          end case;
        else  -- HSIZE_BYTE
          case transaction_reg.addr(1 downto 0) is
            when "00"   => somi(i).r.data <= ahbdrivedata(remote_ahbs_rcv_data_out(7 downto 0));
            when "01"   => somi(i).r.data <= ahbdrivedata(remote_ahbs_rcv_data_out(15 downto 8));
            when "10"   => somi(i).r.data <= ahbdrivedata(remote_ahbs_rcv_data_out(23 downto 16));
            when others => somi(i).r.data <= ahbdrivedata(remote_ahbs_rcv_data_out(31 downto 24));
          end case;
        end if;
      end loop;
    end if;



    -- Default bus slave response
    for i in 0 to nmst - 1 loop
      -- aw
      somi(i).aw.ready <= '0';
      -- ar
      somi(i).ar.ready <= '0';
      -- w
      somi(i).w.ready <= '0';
      -- r
      somi(i).r.id    <= transaction_reg.id;
      somi(i).r.resp  <= RBRESP_OKAY;
      if rsp_preamble = PREAMBLE_TAIL then
        somi(i).r.last  <= '1';
      else
        somi(i).r.last  <= '0';
      end if;
      somi(i).r.user  <= (others => '0');
      somi(i).r.valid <= '0';
      -- b
      somi(i).b.id    <= transaction_reg.id;
      somi(i).b.resp  <= RBRESP_OKAY;
      somi(i).b.user  <= (others => '0');
      somi(i).b.valid <= '0';
    end loop;

    -- Default NoC input port
    coherence_req_data_in   <= (others => '0');
    coherence_req_wrreq     <= '0';
    coherence_rsp_rcv_rdreq <= '0';

    remote_ahbs_snd_data_in <= (others => '0');
    remote_ahbs_snd_wrreq   <= '0';
    remote_ahbs_rcv_rdreq   <= '0';

    if wdata_valid = '1' then
      wdata_src     := wdata_reg;
      addr_for_data := active_addr;
      size_for_data := active_size;
    else
      wdata_src     := mosi(transaction_reg.xindex).w.data;
      addr_for_data := transaction_reg.addr;
      size_for_data := transaction_reg.size;
    end if;

    -- Build write payload data from AXI W data and active size/address.
    if size_for_data = HSIZE_DWORD then
      wdata := ahbdrivedata(wdata_src);
    elsif size_for_data = HSIZE_WORD then
      if AHBDW = 64 then
        case addr_for_data(2) is
          when '0'    => wdata := ahbdrivedata(wdata_src(31 downto 0));
          when others => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 1 downto ARCH_BITS - 32));
        end case;
      else
        wdata := ahbdrivedata(wdata_src);
      end if;
    elsif size_for_data = HSIZE_HWORD then
      if AHBDW = 64 then
        case addr_for_data(2 downto 1) is
          when "00"   => wdata := ahbdrivedata(wdata_src(15 downto 0));
          when "01"   => wdata := ahbdrivedata(wdata_src(31 downto 16));
          when "10"   => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 17 downto ARCH_BITS - 32));
          when others => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 1 downto ARCH_BITS - 16));
        end case;
      else
        case addr_for_data(1) is
          when '0'    => wdata := ahbdrivedata(wdata_src(15 downto 0));
          when others => wdata := ahbdrivedata(wdata_src(31 downto 16));
        end case;
      end if;
    else  -- HSIZE_BYTE
      if AHBDW = 64 then
        case addr_for_data(2 downto 0) is
          when "000"  => wdata := ahbdrivedata(wdata_src(7 downto 0));
          when "001"  => wdata := ahbdrivedata(wdata_src(15 downto 8));
          when "010"  => wdata := ahbdrivedata(wdata_src(23 downto 16));
          when "011"  => wdata := ahbdrivedata(wdata_src(31 downto 24));
          when "100"  => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 25 downto ARCH_BITS - 32));
          when "101"  => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 17 downto ARCH_BITS - 24));
          when "110"  => wdata := ahbdrivedata(wdata_src(ARCH_BITS -  9 downto ARCH_BITS - 16));
          when others => wdata := ahbdrivedata(wdata_src(ARCH_BITS -  1 downto ARCH_BITS -  8));
        end case;
      else
        case addr_for_data(1 downto 0) is
          when "00"   => wdata := ahbdrivedata(wdata_src(7 downto 0));
          when "01"   => wdata := ahbdrivedata(wdata_src(15 downto 8));
          when "10"   => wdata := ahbdrivedata(wdata_src(23 downto 16));
          when others => wdata := ahbdrivedata(wdata_src(31 downto 24));
        end case;
      end if;
    end if;

    payload_data            := (others => '0');
    payload_data_narrow_lsb := (others => '0');
    payload_data_narrow_msb := (others => '0');
    -- Remote AHB path uses the 32-bit misc-flit format:
    -- - For 64-bit AXI/AHB data, split into two 32-bit flits (LSB then MSB).
    -- - For <=32-bit writes, only the LSB flit is sent.
    -- - The LSB flit starts as PREAMBLE_BODY and becomes PREAMBLE_TAIL when it
    --   is the last (or only) flit of the beat.
    payload_data_narrow_lsb(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
    if segment_active = '1' then
      last := '1';
    elsif wdata_valid = '1' then
      last := wlast_reg;
    else
      last := mosi(transaction_reg.xindex).w.last;
    end if;

    if last = '1' then
      payload_data(this_noc_flit_size-1 downto this_noc_flit_size - PREAMBLE_WIDTH)                      := PREAMBLE_TAIL;
      payload_data_narrow_msb(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    else
      payload_data(this_noc_flit_size-1 downto this_noc_flit_size - PREAMBLE_WIDTH)                      := PREAMBLE_BODY;
      payload_data_narrow_msb(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
    end if;
    payload_data(AHBDW - 1 downto 0)                                      := wdata;
    -- TODO: this only works on a 64-bit AXI bus with 32-bit AHB remote slaves
    payload_data_narrow_lsb(31 downto 0) := wdata(31 downto 0);
    payload_data_narrow_msb(31 downto 0) := wdata(ARCH_BITS - 1 downto ARCH_BITS - 32);

    -- pragma translate_off
    if transaction_reg.write = '1' and transaction_reg.dst_is_mem = '0' and mosi(transaction_reg.xindex).w.valid = '1' then
      assert mosi(transaction_reg.xindex).w.strb = WSTRB_ALL_ONE
        report "axislv2noc: partial WSTRB not supported for remote AHB writes"
        severity warning;
    end if;
    -- pragma translate_on

    -- Temporary AXI handshake flags.
    slv_ready  := '0';
    slv_valid  := '0';
    mst_ready  := mosi(transaction_reg.xindex).r.ready;
    if wdata_valid = '1' then
      mst_valid  := '1';
    else
      mst_valid  := mosi(transaction_reg.xindex).w.valid;
    end if;
    mst_bready := mosi(transaction_reg.xindex).b.ready;


    -- FSM
    case current_state is
      when idle =>
        -- Select the next transaction and snapshot control in `sample_flits`.
        -- Memory writes enter `wait_wdata` first so WSTRB can drive policy.
        if selected = '1' then
          sample_flits <= '1';
          if transaction.write = '1' and transaction.dst_is_mem = '1' then
            next_state <= wait_wdata;
          else
            next_state <= request_header;
          end if;
        end if;

      when wait_wdata =>
        -- Hold AW context, accept exactly one W beat into local registers, then
        -- dispatch by WSTRB, coherence, and retarget mode:
        -- - `WSTRB=0x00`: Skip the beat locally (no NoC write) and update index/last.
        -- - Non-DMA memory write: Go to `request_header`; `split_active` can run
        --   this beat as one or more segments through `request_header/address/data`.
        -- - Non-coherent DMA + full WSTRB: Use `dma_write_*` fast path (no segment loop).
        -- - Non-coherent DMA + partial WSTRB: Use `request_*` segment loop with
        --   per-segment DMA size override in header reserved bits.
        -- - Coherent DMA + partial WSTRB: Use `rmw_*` sequence (read/merge/write).
        -- - Coherent DMA + full WSTRB: Use `dma_write_*` fast path.
        -- This staging adds local scheduling delay before the first request flit
        -- for memory writes because AW may be accepted before W.
        -- The beat is not consumed from AXI until `latch_wbeat=1`. After that,
        -- all split activity runs from local registers (`wdata_reg`, `wstrb_reg`,
        -- `seg_mask_reg`) and does not depend on W channel timing anymore.
        -- This prevents partial progress when downstream NoC backpressure occurs.
        if write_hold_active = '1' then
          if aw_accepted = '0' then
            somi(transaction_reg.xindex).aw.ready <= '1';
            if mosi(transaction_reg.xindex).aw.valid = '1' then
              aw_handshake <= '1';
            end if;
          end if;
          if wdata_valid = '0' then
            slv_ready := '1';
            if mosi(transaction_reg.xindex).w.valid = '1' then
              latch_wbeat <= '1';
              if mosi(transaction_reg.xindex).w.strb = WSTRB_ALL_ZERO then
                skip_beat <= '1';
                skip_last <= mosi(transaction_reg.xindex).w.last;
                if mosi(transaction_reg.xindex).w.last = '1' then
                  next_state <= request_data_ack;
                else
                  next_state <= wait_wdata;
                end if;
              else
                if retarget_for_dma = 1 then
                  if mosi(transaction_reg.xindex).w.strb /= WSTRB_ALL_ONE then
                    if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
                      next_state <= rmw_read_header;
                    else
                      next_state <= request_header;
                    end if;
                  else
                    next_state <= dma_write_header;
                  end if;
                else
                  next_state <= request_header;
                end if;
              end if;
            end if;
          end if;
        else
          next_state <= request_header;
        end if;

      when rmw_read_header =>
        -- RMW step 1/6: Send read header.
        -- Partial coherent-write latency is dominated by this extra read round trip.
        if coherence_req_full = '0' then
          coherence_req_data_in <= rmw_read_header_flit;
          coherence_req_wrreq   <= '1';
          next_state            <= rmw_read_address;
        end if;

      when rmw_read_address =>
        -- RMW step 2/6: Send aligned read address.
        if coherence_req_full = '0' then
          coherence_req_data_in <= rmw_read_address_flit;
          coherence_req_wrreq   <= '1';
          next_state            <= rmw_read_length;
        end if;

      when rmw_read_length =>
        -- RMW step 3/6: Send read length (1 beat).
        if coherence_req_full = '0' then
          coherence_req_data_in <= rmw_read_length_flit;
          coherence_req_wrreq   <= '1';
          next_state            <= rmw_read_reply_header;
        end if;

      when rmw_read_reply_header =>
        -- RMW step 4/6: Consume read-response header.
        if coherence_rsp_rcv_empty = '0' then
          coherence_rsp_rcv_rdreq <= '1';
          next_state              <= rmw_read_reply_data;
        end if;

      when rmw_read_reply_data =>
        -- RMW step 5/6: Capture read data used for byte-lane merge.
        if coherence_rsp_rcv_empty = '0' then
          coherence_rsp_rcv_rdreq <= '1';
          rmw_read_sample <= '1';
          if rsp_preamble = PREAMBLE_TAIL then
            next_state <= rmw_write_header;
          end if;
        end if;

      when rmw_write_header =>
        -- RMW step 6/6a: Send merged write header.
        if coherence_req_full = '0' then
          coherence_req_data_in <= rmw_write_header_flit;
          coherence_req_wrreq   <= '1';
          next_state            <= rmw_write_address;
        end if;

      when rmw_write_address =>
        -- RMW step 6/6b: Send write address, with optional length for `DMA_FROM_DEV`.
        if coherence_req_full = '0' then
          coherence_req_data_in <= rmw_write_address_flit;
          coherence_req_wrreq   <= '1';
          -- Length flit is required only for non-coherent DMA writes.
          if rmw_write_needs_length = '1' then
            next_state <= rmw_write_length;
          else
            next_state <= rmw_write_data;
          end if;
        end if;

      when rmw_write_length =>
        -- RMW step 6/6c: Send optional write-length flit.
        if coherence_req_full = '0' then
          coherence_req_data_in <= rmw_write_length_flit;
          coherence_req_wrreq   <= '1';
          next_state            <= rmw_write_data;
        end if;

      when rmw_write_data =>
        -- RMW step 6/6d: Send merged payload and retire buffered beat.
        if coherence_req_full = '0' then
          coherence_req_data_in <= rmw_payload_data;
          coherence_req_wrreq   <= '1';
          rmw_write_done        <= '1';
          if wlast_reg = '1' then
            next_state <= request_data_ack;
          else
            next_state <= wait_wdata;
          end if;
        end if;

      when dma_write_header =>
        -- Buffered one-beat DMA write (non-RMW path): header flit.
        if coherence_req_full = '0' then
          coherence_req_data_in <= dma_write_header_flit;
          coherence_req_wrreq   <= '1';
          next_state            <= dma_write_address;
        end if;

      when dma_write_address =>
        -- Buffered DMA address flit, with optional length by message type.
        if coherence_req_full = '0' then
          coherence_req_data_in <= dma_write_address_flit;
          coherence_req_wrreq   <= '1';
          -- Length flit is required only for non-coherent DMA writes.
          if rmw_write_needs_length = '1' then
            next_state <= dma_write_length;
          else
            next_state <= dma_write_data;
          end if;
        end if;

      when dma_write_length =>
        -- Optional DMA write-length flit.
        if coherence_req_full = '0' then
          coherence_req_data_in <= dma_write_length_flit;
          coherence_req_wrreq   <= '1';
          next_state            <= dma_write_data;
        end if;

      when dma_write_data =>
        -- Buffered DMA payload flit. Beat completion mirrors the generic buffered path.
        if coherence_req_full = '0' then
          coherence_req_data_in <= dma_write_payload_data;
          coherence_req_wrreq   <= '1';
          buffered_write_done   <= '1';
          if wlast_reg = '1' then
            next_state <= request_data_ack;
          else
            next_state <= wait_wdata;
          end if;
        end if;

      when request_header =>
        -- Common request-header state for the baseline and WSTRB-aware flow.
        -- `active_header` can represent one split sub-transaction.
        if transaction_reg.dst_is_mem = '1' then
          if coherence_req_full = '0' then
            coherence_req_data_in <= active_header;
            coherence_req_wrreq   <= '1';
            next_state         <= request_address;
            -- Control signals are sampled
            if transaction_reg.write = '1' then
              if split_active = '1' then
                if aw_accepted = '0' then
                  somi(transaction_reg.xindex).aw.ready <= '1';
                  if mosi(transaction_reg.xindex).aw.valid = '1' then
                    aw_handshake <= '1';
                  end if;
                end if;
              else
                if aw_accepted = '0' then
                  somi(transaction_reg.xindex).aw.ready <= '1';
                  if mosi(transaction_reg.xindex).aw.valid = '1' then
                    aw_handshake <= '1';
                  end if;
                end if;
              end if;
            else
              somi(transaction_reg.xindex).ar.ready <= '1';
            end if;
          end if;
        else
          if remote_ahbs_snd_full = '0' then
            remote_ahbs_snd_data_in <= active_header_narrow;
            remote_ahbs_snd_wrreq   <= '1';
            next_state           <= request_address;
            -- Control signals are sampled
            if transaction_reg.write = '1' then
              if split_active = '1' then
                if aw_accepted = '0' then
                  somi(transaction_reg.xindex).aw.ready <= '1';
                  if mosi(transaction_reg.xindex).aw.valid = '1' then
                    aw_handshake <= '1';
                  end if;
                end if;
              else
                if aw_accepted = '0' then
                  somi(transaction_reg.xindex).aw.ready <= '1';
                  if mosi(transaction_reg.xindex).aw.valid = '1' then
                    aw_handshake <= '1';
                  end if;
                end if;
              end if;
            else
              somi(transaction_reg.xindex).ar.ready <= '1';
            end if;
          end if;
        end if;

      when request_address =>
        -- Common address state. Active address may be per-segment.
        if transaction_reg.dst_is_mem = '1' then
          if coherence_req_full = '0' then
            coherence_req_data_in <= active_payload_address;
            coherence_req_wrreq <= '1';
            -- `DMA_FROM_DEV` writes include a length flit; other writes go directly
            -- to payload data.
            if transaction_reg.write = '1' and transaction_reg.msg_type /= DMA_FROM_DEV then
              next_state <= request_data;
            else
              next_state <= request_length;
            end if;
          end if;
        else
          if remote_ahbs_snd_full = '0' then
            remote_ahbs_snd_data_in <= active_payload_address_narrow;
            remote_ahbs_snd_wrreq <= '1';
            if transaction_reg.write = '1' then
              if active_size = HSIZE_DWORD then
                next_state <= request_data_lsb;
              else
                next_state <= request_data;
              end if;
            else
              next_state <= request_length;
            end if;
          end if;
        end if;

      when request_length =>
        -- Common length state. Writes usually bypass this unless required by protocol.
        if transaction_reg.dst_is_mem = '1' then
          if coherence_req_full = '0' then
            coherence_req_data_in <= active_payload_length;
            coherence_req_wrreq <= '1';
            -- Ready transaction only
            if transaction_reg.write = '1' then
              next_state <= request_data;
            else
              next_state <= reply_header;
            end if;
          end if;
        else
          if remote_ahbs_snd_full = '0' then
            remote_ahbs_snd_data_in <= active_payload_length_narrow;
            remote_ahbs_snd_wrreq <= '1';
            -- Ready transaction only
            next_state <= reply_header;
          end if;
        end if;

      when request_data =>
        -- Common data state with two write modes:
        -- - Segmented mode: Emit one segment, assert `advance_segment`, then
        --   either loop `request_data -> request_header` (more segments in this beat)
        --   or retire the beat and move to `wait_wdata`/`request_data_ack`.
        -- - Non-segmented mode: Emit the full beat once (buffered or direct).
        -- Segment-loop detail:
        -- - Segment `i` uses `active_addr/active_size` derived from `seg_mask_reg(i)`.
        -- - Header/address are re-emitted per segment so downstream sees each as
        --   an independent legal subword transaction.
        -- - `seg_last_in_beat` closes the loop and releases buffered beat context.
        -- Timing impact:
        -- - Non-segmented path matches baseline data emission in this state.
        -- - Each additional segment revisits `request_header/address/data`, adding
        --   per-segment arbitration and NoC queueing delay.
        -- Segment-commit contract:
        -- - `advance_segment` is raised only in the cycle where the segment data
        --   flit is accepted by the NoC output FIFO.
        -- - The clocked process applies `seg_mask_reg := seg_mask_next` on that
        --   strobe, so a stalled FIFO cannot accidentally skip segments.
        -- - `seg_last_in_beat` is evaluated from the *current* segment and decides
        --   whether the beat context is retired or another segment loop begins.
        if transaction_reg.dst_is_mem = '1' then
          if coherence_req_full = '0' and mst_valid = '1' then
            if segment_active = '1' then
              if seg_has_data = '1' then
                coherence_req_data_in <= payload_data;
                coherence_req_wrreq <= '1';
                advance_segment <= '1';
                if seg_last_in_beat = '1' then
                  if wlast_reg = '1' then
                    next_state <= request_data_ack;
                  else
                    next_state <= wait_wdata;
                  end if;
                else
                  next_state <= request_header;
                end if;
              end if;
            else
              coherence_req_data_in <= payload_data;
              coherence_req_wrreq <= '1';
              if wdata_valid = '1' then
                buffered_write_done <= '1';
              else
                slv_ready := '1';
              end if;
              if last = '1' then
                next_state <= request_data_ack;
              end if;
            end if;
          end if;
        else
          if remote_ahbs_snd_full = '0' and mst_valid = '1' then
            -- Remote AHB narrow write:
            -- - WORD/HWORD/BYTE use a single LSB flit.
            -- - DWORD uses the LSB flit here, then MSB in `request_data_msb`.
            if last = '1' then
              payload_data_narrow_lsb(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
              next_state <= request_data_ack;
            end if;
            slv_ready := '1';
            remote_ahbs_snd_data_in <= payload_data_narrow_lsb;
            remote_ahbs_snd_wrreq <= '1';
          end if;
        end if;

      when request_data_lsb =>
        -- Remote AHB 64-bit write path: first narrow flit (LSB).
        if remote_ahbs_snd_full = '0' and mst_valid = '1' then
          remote_ahbs_snd_data_in <= payload_data_narrow_lsb;
          remote_ahbs_snd_wrreq <= '1';
          next_state <= request_data_msb;
        end if;

      when request_data_msb =>
        -- Remote AHB 64-bit write path: second narrow flit (MSB).
        if remote_ahbs_snd_full = '0' then
          slv_ready := '1';
          -- The MSB flit carries the preamble (BODY/TAIL) selected by `last`.
          remote_ahbs_snd_data_in <= payload_data_narrow_msb;
          remote_ahbs_snd_wrreq <= '1';
          if last = '1' then
            next_state <= request_data_ack;
          else
            next_state <= request_data_lsb;
          end if;
        end if;

      when request_data_ack =>
        -- Return AXI write response; the next command may start immediately.
        somi(transaction_reg.xindex).b.valid <= '1';
        if transaction_reg.lock = '1' then
          -- always return success on RISC-V store conditional
          somi(transaction_reg.xindex).b.resp <= RBRESP_EXOKAY;
        end if;
        if mst_bready = '1' then
          if selected = '0' then
            next_state <= idle;
          else
            sample_flits <= '1';
            if transaction.write = '1' and transaction.dst_is_mem = '1' then
              next_state <= wait_wdata;
            else
              next_state <= request_header;
            end if;
          end if;
        end if;

      when reply_header =>
        -- Consume read-response header.
        if transaction_reg.dst_is_mem = '1' then
          if coherence_rsp_rcv_empty = '0' then
            coherence_rsp_rcv_rdreq <= '1';
            next_state              <= reply_data;
          end if;
        else
          if remote_ahbs_rcv_empty = '0' then
            remote_ahbs_rcv_rdreq <= '1';
            if transaction_reg.size = HSIZE_DWORD then
              next_state <= reply_data_lsb;
            else
              next_state <= reply_data;
            end if;
          end if;
        end if;

      when reply_data =>
        -- Forward read-response data (single-flit or memory-stream case).
        if coherence_rsp_rcv_empty = '0' and mst_ready = '1' then
          coherence_rsp_rcv_rdreq <= '1';
        elsif remote_ahbs_rcv_empty = '0'and mst_ready = '1' then
          remote_ahbs_rcv_rdreq <= '1';
        end if;
        if (coherence_rsp_rcv_empty = '0' or remote_ahbs_rcv_empty = '0') then
          slv_valid := '1';
          if mst_ready = '1' then
            if rsp_preamble = PREAMBLE_TAIL then
              if selected = '0' then
                next_state <= idle;
              else
                if transaction.write = '1' and transaction.dst_is_mem = '1' then
                  next_state <= wait_wdata;
                else
                  next_state <= request_header;
                end if;
                sample_flits <= '1';
              end if;
            end if;
          end if;
        end if;

      when reply_data_lsb =>
        -- Remote AHB 64-bit read path: capture first 32 bits (LSB).
        if remote_ahbs_rcv_empty = '0'then
          remote_ahbs_rcv_rdreq <= '1';
          sample_and_hold <= '1';
          next_state <= reply_data_msb;
        end if;

      when reply_data_msb =>
        -- Remote AHB 64-bit read path: combine held LSB and current MSB to AXI.
        if remote_ahbs_rcv_empty = '0'and mst_ready = '1' then
          remote_ahbs_rcv_rdreq <= '1';
        end if;
        if remote_ahbs_rcv_empty = '0' then
          slv_valid := '1';
          if mst_ready = '1' then
            if rsp_preamble = PREAMBLE_TAIL then
              if selected = '0' then
                next_state <= idle;
              else
                if transaction.write = '1' and transaction.dst_is_mem = '1' then
                  next_state <= wait_wdata;
                else
                  next_state <= request_header;
                end if;
                sample_flits <= '1';
              end if;
            else
              next_state <= reply_data_lsb;
            end if;
          end if;
        end if;

      when others =>
        next_state <= idle;

    end case;

    somi(transaction_reg.xindex).w.ready <= slv_ready;
    somi(transaction_reg.xindex).r.valid <= slv_valid;

  end process axi_roundtrip;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- Asynchronous reset (active low).
      current_state <= idle;
      transaction_reg <= transaction_none;
      remote_ahbs_rcv_data_out_hold <= (others => '0');
      aw_accepted    <= '0';
      wdata_valid    <= '0';
      wdata_reg      <= (others => '0');
      wstrb_reg      <= (others => '0');
      wlast_reg      <= '0';
      beat_index_reg <= 0;
      beat_addr_reg  <= (others => '0');
      seg_mask_reg   <= (others => '0');
      rmw_read_data_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- Rising clock edge.
      current_state <= next_state;
      if sample_flits = '1' then
        -- Sample a new transaction control header (AW/AR side).
        transaction_reg <= transaction;
        aw_accepted    <= '0';
        wdata_valid    <= '0';
        wlast_reg      <= '0';
        beat_index_reg <= 0;
        seg_mask_reg   <= (others => '0');
      end if;
      if sample_and_hold = '1' then
        -- Remote narrow-read helper register (64-bit read on 32-bit misc flits).
        remote_ahbs_rcv_data_out_hold <= remote_ahbs_rcv_data_out;
      end if;
      if rmw_read_sample = '1' then
        -- Capture the RMW readback word for combinational merge.
        rmw_read_data_reg <= coherence_rsp_rcv_data_out(AHBDW - 1 downto 0);
      end if;
      if aw_handshake = '1' then
        -- Remember AW acceptance so split sub-transfers do not re-handshake.
        aw_accepted <= '1';
      end if;
      if latch_wbeat = '1' then
        -- Capture one AXI W beat and initialize segmentation state.
        wdata_reg <= mosi(transaction_reg.xindex).w.data;
        wstrb_reg <= mosi(transaction_reg.xindex).w.strb;
        wlast_reg <= mosi(transaction_reg.xindex).w.last;
        wdata_valid <= '1';
        beat_addr_reg <= std_logic_vector(unsigned(transaction_reg.addr) +
                                          to_unsigned(beat_index_reg * (2 ** to_integer(unsigned(transaction_reg.size))), GLOB_PHYS_ADDR_BITS));
        -- Seed the per-beat mask used by `next_wstrb_segment`.
        -- - Split-enabled paths copy the exact AXI WSTRB bits.
        -- - Non-split paths force all ones so combinational `active_*` logic
        --   resolves to one full-beat transfer.
        if (retarget_for_dma = 0) or
           (retarget_for_dma = 1 and coherence /= ACC_COH_LLC and coherence /= ACC_COH_RECALL and
            mosi(transaction_reg.xindex).w.strb /= WSTRB_ALL_ONE) then
          seg_mask_reg <= mosi(transaction_reg.xindex).w.strb;
        else
          -- Full-beat or coherent DMA path: treat all byte lanes as enabled.
          seg_mask_reg <= (others => '1');
        end if;
      end if;
      if skip_beat = '1' then
        -- Beat had `WSTRB=0x00`, so retire locally without NoC traffic.
        wdata_valid <= '0';
        seg_mask_reg <= (others => '0');
        if skip_last = '0' then
          beat_index_reg <= beat_index_reg + 1;
        end if;
      elsif advance_segment = '1' then
        -- One segment was sent. Commit `mask_next` and either:
        -- - Stay on the same buffered beat (set bits remain in `seg_mask_reg`), or
        -- - Retire the beat when `seg_last_in_beat='1'`.
        -- `request_data` decides whether to loop to `request_header` (more segments)
        -- or move to `wait_wdata`/`request_data_ack` (beat complete).
        -- This is the only state transition that mutates split progress. Every
        -- emitted sub-transaction consumes exactly one contiguous aligned segment.
        seg_mask_reg <= seg_mask_next;
        if seg_last_in_beat = '1' then
          wdata_valid <= '0';
          if wlast_reg = '0' then
            beat_index_reg <= beat_index_reg + 1;
          end if;
        end if;
      elsif rmw_write_done = '1' then
        -- RMW beat fully committed.
        wdata_valid <= '0';
        seg_mask_reg <= (others => '0');
        if wlast_reg = '0' then
          beat_index_reg <= beat_index_reg + 1;
        end if;
      elsif buffered_write_done = '1' then
        -- Buffered non-RMW beat committed (full beat or DMA fast path).
        wdata_valid <= '0';
        seg_mask_reg <= (others => '0');
        if wlast_reg = '0' then
          beat_index_reg <= beat_index_reg + 1;
        end if;
      end if;
    end if;
  end process;
  end generate gen_legacy;

  -----------------------------------------------------------------------------
  -- Multi-outstanding generate (retarget_for_dma = 1: the AXI-accelerator
  -- socket, whatever accelerator is attached to it).
  -----------------------------------------------------------------------------
  -- Layout:
  -- - `req_roundtrip`: request FSM. Mirrors the legacy request states
  --   (wait_wdata, rmw_*, dma_write_*, request_*) but for READS, after the
  --   request flits are pushed, it transitions to `req_commit` which pushes
  --   the per-read context into the outstanding table and returns to
  --   `req_idle`. Writes keep using `req_data_ack` to drive `somi.b.valid`
  --   locally (DMA writes are fire-and-forget on the NoC).
  -- - `rsp_roundtrip`: response FSM. Owns `coherence_rsp_rcv_*` and the
  --   `somi.r.*` channel. On a header flit, extracts the DMA_TRAN_ID and
  --   looks up the matching slot; on `PREAMBLE_TAIL`, frees it. Independent
  --   of `req_roundtrip` so the request FSM can issue new transactions
  --   while previous reads are still being drained.
  -- - `ot_seq`: clocked block that updates `req_state`, `rsp_state`,
  --   `transaction_reg`, the WSTRB/RMW buffering signals (latch_wbeat,
  --   advance_segment, etc.) reused from the legacy design, AND the
  --   outstanding-table arrays.
  --
  -- Note: the shared combinational helpers (`make_packet`,
  -- `make_active_packet`, `make_rmw_packet`, `make_dma_write_packet`,
  -- `rmw_mask_gen`, `rmw_payload_gen`, `seg_info`, `seg_addr`, etc.) live
  -- outside both generates and feed the request FSM in either mode.
  gen_dma_ot: if retarget_for_dma = 1 generate

    -- Static check: the local slot index must fit in the on-wire DMA_TRAN_ID
    -- field. Fires at elaboration if a future code change widens the table
    -- past the NoC field without bumping DMA_TRAN_ID_WIDTH first.
    assert OUTSTANDING_DEPTH <= 2**DMA_TRAN_ID_WIDTH
      report "axislv2noc: OUTSTANDING_DEPTH > 2**DMA_TRAN_ID_WIDTH"
      severity failure;

    -- Convenience: derive the same-id and table-full guards combinationally
    -- from the registered outstanding table. `ot_alloc_idx` picks the
    -- lowest-index free slot.
    ot_lookups: process (outstanding_reg, transaction)
      variable alloc_found   : boolean;
      variable alloc_idx_v   : outstanding_idx_t;
      variable same_id_v     : std_ulogic;
      variable any_busy_v    : std_ulogic;
    begin
      alloc_found := false;
      alloc_idx_v := 0;
      same_id_v   := '0';
      any_busy_v  := '0';
      for i in 0 to OUTSTANDING_DEPTH - 1 loop
        if outstanding_reg(i).valid = '1' then
          any_busy_v := '1';
          if transaction.write = '0' and outstanding_reg(i).id = transaction.id then
            same_id_v := '1';
          end if;
        elsif not alloc_found then
          alloc_found := true;
          alloc_idx_v := i;
        end if;
      end loop;
      ot_alloc_idx         <= alloc_idx_v;
      if alloc_found then
        ot_alloc_avail <= '1';
      else
        ot_alloc_avail <= '0';
      end if;
      ot_same_read_id_busy <= same_id_v;
      ot_any_read_busy     <= any_busy_v;

      -- Sim-only invariant: the same-id guard should keep at most one
      -- outstanding entry per (xindex, axi_id) pair. If this assertion
      -- ever fires, ordering of same-id responses to AXI is undefined.
      -- pragma translate_off
      for i in 0 to OUTSTANDING_DEPTH - 1 loop
        for j in i + 1 to OUTSTANDING_DEPTH - 1 loop
          if outstanding_reg(i).valid = '1' and outstanding_reg(j).valid = '1' then
            assert not (outstanding_reg(i).id     = outstanding_reg(j).id
                    and outstanding_reg(i).xindex = outstanding_reg(j).xindex)
              report "axislv2noc: duplicate (xindex, axi_id) in outstanding table"
              severity failure;
          end if;
        end loop;
      end loop;
      -- pragma translate_on
    end process ot_lookups;

    -----------------------------------------------------------------------
    -- Request FSM
    -----------------------------------------------------------------------
    -- Structure: same shape as the legacy `axi_roundtrip`, with:
    --  - `idle` -> `req_idle` (selection gated by ot_alloc_avail +
    --    same-id + LLC-single guards).
    --  - For READS, after request flits are pushed (the legacy went to
    --    `reply_header`), this FSM goes to `req_commit` which raises
    --    `push_outstanding` and returns to `req_idle`.
    --  - For WRITES, identical to legacy: `req_data_ack` mirrors
    --    `request_data_ack`.
    --  - When `dst_is_mem = '1'` the `remote_ahbs_*` branches are dead, but
    --    they are kept for accelerators that do target remote AHB.
    req_roundtrip: process (transaction, transaction_reg, req_state, selected, mosi, coherence,
                            coherence_req_full,
                            remote_ahbs_snd_full,
                            split_active, segment_active, write_hold_active,
                            wdata_valid, wdata_reg, wstrb_reg, wlast_reg,
                            seg_has_data, seg_last_in_beat, seg_mask_next, active_addr, active_size,
                            active_header, active_header_narrow, active_payload_address,
                            active_payload_address_narrow, active_payload_length, active_payload_length_narrow,
                            rmw_read_header_flit, rmw_read_address_flit, rmw_read_length_flit,
                            rmw_write_header_flit, rmw_write_address_flit, rmw_write_length_flit,
                            rmw_write_needs_length, rmw_payload_data,
                            dma_write_header_flit, dma_write_address_flit, dma_write_length_flit,
                            dma_write_payload_data,
                            aw_accepted,
                            coherence_rsp_rcv_data_out, coherence_rsp_rcv_empty,
                            ot_alloc_avail, ot_alloc_idx, ot_same_read_id_busy, ot_any_read_busy,
                            req_alloc_idx_reg)
      variable wdata           : std_logic_vector(AHBDW - 1 downto 0);
      variable wdata_src       : std_logic_vector(AXIDW - 1 downto 0);
      variable addr_for_data   : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
      variable size_for_data   : std_logic_vector(2 downto 0);
      variable payload_data    : std_logic_vector(this_noc_flit_size - 1 downto 0);
      variable header_with_id  : std_logic_vector(this_noc_flit_size - 1 downto 0);
      variable mst_valid       : std_ulogic;
      variable mst_bready      : std_ulogic;
      variable slv_ready_v     : std_ulogic;
      variable last            : std_ulogic;
      variable issue_ok        : std_ulogic;
      variable llc_mode        : std_ulogic;
      variable txn_id_v        : dma_tran_id_type;
      variable remote_v        : misc_noc_flit_type;
    begin
      -- Defaults.
      req_next <= req_state;
      sample_flits        <= '0';
      latch_wbeat         <= '0';
      advance_segment     <= '0';
      skip_beat           <= '0';
      skip_last           <= '0';
      aw_handshake        <= '0';
      rmw_read_sample     <= '0';
      rmw_write_done      <= '0';
      buffered_write_done <= '0';
      push_outstanding         <= '0';
      push_outstanding_entry   <= outstanding_entry_none;
      push_outstanding_idx     <= req_alloc_idx_reg;

      coherence_req_data_in <= (others => '0');
      coherence_req_wrreq   <= '0';
      req_coh_rsp_rdreq     <= '0';
      -- The response FSM owns rsp_coh_rsp_rdreq and rsp_somi.r.*.
      -- Tie off remote AHB outputs; this proxy instance does not route
      -- replies through the remote AHB path in DMA-OT mode.
      remote_ahbs_snd_data_in <= (others => '0');
      remote_ahbs_snd_wrreq   <= '0';

      -- Drive req_somi (aw/ar/w/b channels). The architecture-level merge
      -- combines this with rsp_somi.r into the actual somi output port.
      -- Initialize all req_somi fields so the merge process never sees
      -- 'U'/'X' on subfields the request FSM doesn't touch.
      for i in 0 to nmst - 1 loop
        req_somi(i).aw.ready <= '0';
        req_somi(i).ar.ready <= '0';
        req_somi(i).w.ready  <= '0';
        req_somi(i).b.id     <= transaction_reg.id;
        req_somi(i).b.resp   <= RBRESP_OKAY;
        req_somi(i).b.user   <= (others => '0');
        req_somi(i).b.valid  <= '0';
        -- r fields are driven by rsp_roundtrip; initialize req_somi.r so
        -- this process has a defined value for the full record (defensive,
        -- the merge ignores req_somi.r anyway).
        req_somi(i).r.id    <= (others => '0');
        req_somi(i).r.data  <= (others => '0');
        req_somi(i).r.resp  <= RBRESP_OKAY;
        req_somi(i).r.last  <= '0';
        req_somi(i).r.user  <= (others => '0');
        req_somi(i).r.valid <= '0';
      end loop;

      slv_ready_v := '0';
      mst_bready  := mosi(transaction_reg.xindex).b.ready;
      if wdata_valid = '1' then
        mst_valid := '1';
      else
        mst_valid := mosi(transaction_reg.xindex).w.valid;
      end if;

      -- LLC fallback: if coherent DMA, allow at most one outstanding read.
      if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
        llc_mode := '1';
      else
        llc_mode := '0';
      end if;

      -- Combined issue guard. In LLC mode we collapse to single-outstanding
      -- (any in-flight read blocks both new reads AND new writes) because
      -- the LLC path's RMW (partial coherent write) consumes responses from
      -- the same coherence_rsp_rcv queue the response FSM watches -- mixing
      -- the two would risk one side stealing the other's response. In
      -- non-LLC mode reads block on table-full or same-id; writes only
      -- block when there is no free slot at all (cheap conservatism).
      if transaction.write = '1' then
        if llc_mode = '1' and ot_any_read_busy = '1' then
          issue_ok := '0';
        else
          issue_ok := ot_alloc_avail;
        end if;
      else
        if ot_alloc_avail = '1' and ot_same_read_id_busy = '0'
          and (llc_mode = '0' or ot_any_read_busy = '0') then
          issue_ok := '1';
        else
          issue_ok := '0';
        end if;
      end if;

      -- Build write payload (copied from legacy `axi_roundtrip`).
      if wdata_valid = '1' then
        wdata_src     := wdata_reg;
        addr_for_data := active_addr;
        size_for_data := active_size;
      else
        wdata_src     := mosi(transaction_reg.xindex).w.data;
        addr_for_data := transaction_reg.addr;
        size_for_data := transaction_reg.size;
      end if;
      if size_for_data = HSIZE_DWORD then
        wdata := ahbdrivedata(wdata_src);
      elsif size_for_data = HSIZE_WORD then
        if AHBDW = 64 then
          case addr_for_data(2) is
            when '0'    => wdata := ahbdrivedata(wdata_src(31 downto 0));
            when others => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 1 downto ARCH_BITS - 32));
          end case;
        else
          wdata := ahbdrivedata(wdata_src);
        end if;
      elsif size_for_data = HSIZE_HWORD then
        if AHBDW = 64 then
          case addr_for_data(2 downto 1) is
            when "00"   => wdata := ahbdrivedata(wdata_src(15 downto 0));
            when "01"   => wdata := ahbdrivedata(wdata_src(31 downto 16));
            when "10"   => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 17 downto ARCH_BITS - 32));
            when others => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 1 downto ARCH_BITS - 16));
          end case;
        else
          case addr_for_data(1) is
            when '0'    => wdata := ahbdrivedata(wdata_src(15 downto 0));
            when others => wdata := ahbdrivedata(wdata_src(31 downto 16));
          end case;
        end if;
      else  -- HSIZE_BYTE
        if AHBDW = 64 then
          case addr_for_data(2 downto 0) is
            when "000"  => wdata := ahbdrivedata(wdata_src(7 downto 0));
            when "001"  => wdata := ahbdrivedata(wdata_src(15 downto 8));
            when "010"  => wdata := ahbdrivedata(wdata_src(23 downto 16));
            when "011"  => wdata := ahbdrivedata(wdata_src(31 downto 24));
            when "100"  => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 25 downto ARCH_BITS - 32));
            when "101"  => wdata := ahbdrivedata(wdata_src(ARCH_BITS - 17 downto ARCH_BITS - 24));
            when "110"  => wdata := ahbdrivedata(wdata_src(ARCH_BITS -  9 downto ARCH_BITS - 16));
            when others => wdata := ahbdrivedata(wdata_src(ARCH_BITS -  1 downto ARCH_BITS -  8));
          end case;
        else
          case addr_for_data(1 downto 0) is
            when "00"   => wdata := ahbdrivedata(wdata_src(7 downto 0));
            when "01"   => wdata := ahbdrivedata(wdata_src(15 downto 8));
            when "10"   => wdata := ahbdrivedata(wdata_src(23 downto 16));
            when others => wdata := ahbdrivedata(wdata_src(31 downto 24));
          end case;
        end if;
      end if;

      -- Pick `last` from the appropriate source (mirrors legacy).
      if segment_active = '1' then
        last := '1';
      elsif wdata_valid = '1' then
        last := wlast_reg;
      else
        last := mosi(transaction_reg.xindex).w.last;
      end if;

      -- Construct the payload-data flit with the right preamble.
      payload_data := (others => '0');
      if last = '1' then
        payload_data(this_noc_flit_size-1 downto this_noc_flit_size - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
      else
        payload_data(this_noc_flit_size-1 downto this_noc_flit_size - PREAMBLE_WIDTH) := PREAMBLE_BODY;
      end if;
      payload_data(AHBDW - 1 downto 0) := wdata;

      -- Helper for stamping the DMA tran_id into a header flit. Operates on
      -- the generic `this_noc_flit_size` slice but uses the same bit window
      -- as `set_dma_tran_id` (anchored just below the reserved field). This
      -- branch only executes when retarget_for_dma=1 so DMA flit widths
      -- guarantee the slice is in range.
      txn_id_v := std_logic_vector(to_unsigned(req_alloc_idx_reg, DMA_TRAN_ID_WIDTH));

      -- Main case: structurally same as legacy. Reads diverge at
      -- request_length -> req_commit. Writes converge at req_data_ack.
      case req_state is
        when req_idle =>
          -- Sample next transaction when allowed.
          if selected = '1' and issue_ok = '1' then
            sample_flits <= '1';
            if transaction.write = '1' and transaction.dst_is_mem = '1' then
              req_next <= req_wait_wdata;
            else
              req_next <= req_header;
            end if;
          end if;

        when req_wait_wdata =>
          -- Identical staging as legacy `wait_wdata`. We accept exactly one
          -- W beat and dispatch to the right write path.
          if write_hold_active = '1' then
            if aw_accepted = '0' then
              req_somi(transaction_reg.xindex).aw.ready <= '1';
              if mosi(transaction_reg.xindex).aw.valid = '1' then
                aw_handshake <= '1';
              end if;
            end if;
            if wdata_valid = '0' then
              slv_ready_v := '1';
              if mosi(transaction_reg.xindex).w.valid = '1' then
                latch_wbeat <= '1';
                if mosi(transaction_reg.xindex).w.strb = WSTRB_ALL_ZERO then
                  skip_beat <= '1';
                  skip_last <= mosi(transaction_reg.xindex).w.last;
                  if mosi(transaction_reg.xindex).w.last = '1' then
                    req_next <= req_data_ack;
                  else
                    req_next <= req_wait_wdata;
                  end if;
                else
                  if mosi(transaction_reg.xindex).w.strb /= WSTRB_ALL_ONE then
                    if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
                      req_next <= req_rmw_read_header;
                    else
                      req_next <= req_header;
                    end if;
                  else
                    req_next <= req_dma_write_header;
                  end if;
                end if;
              end if;
            end if;
          else
            req_next <= req_header;
          end if;

        -- RMW path (coherent partial-WSTRB) mirrors legacy semantics.
        -- For LLC mode this sequence keeps the proxy single-outstanding
        -- because the same-id / any-busy guard blocks new reads while RMW
        -- consumes coherence_rsp_rcv directly.
        when req_rmw_read_header =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= rmw_read_header_flit;
            coherence_req_wrreq   <= '1';
            req_next              <= req_rmw_read_address;
          end if;
        when req_rmw_read_address =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= rmw_read_address_flit;
            coherence_req_wrreq   <= '1';
            req_next              <= req_rmw_read_length;
          end if;
        when req_rmw_read_length =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= rmw_read_length_flit;
            coherence_req_wrreq   <= '1';
            req_next              <= req_rmw_read_reply_header;
          end if;
        when req_rmw_read_reply_header =>
          if coherence_rsp_rcv_empty = '0' then
            req_coh_rsp_rdreq <= '1';
            req_next          <= req_rmw_read_reply_data;
          end if;
        when req_rmw_read_reply_data =>
          if coherence_rsp_rcv_empty = '0' then
            req_coh_rsp_rdreq <= '1';
            rmw_read_sample   <= '1';
            if get_preamble(this_noc_flit_size,
                this_noc_flit_pad & coherence_rsp_rcv_data_out) = PREAMBLE_TAIL then
              req_next <= req_rmw_write_header;
            end if;
          end if;
        when req_rmw_write_header =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= rmw_write_header_flit;
            coherence_req_wrreq   <= '1';
            req_next              <= req_rmw_write_address;
          end if;
        when req_rmw_write_address =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= rmw_write_address_flit;
            coherence_req_wrreq   <= '1';
            if rmw_write_needs_length = '1' then
              req_next <= req_rmw_write_length;
            else
              req_next <= req_rmw_write_data;
            end if;
          end if;
        when req_rmw_write_length =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= rmw_write_length_flit;
            coherence_req_wrreq   <= '1';
            req_next              <= req_rmw_write_data;
          end if;
        when req_rmw_write_data =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= rmw_payload_data;
            coherence_req_wrreq   <= '1';
            rmw_write_done        <= '1';
            if wlast_reg = '1' then
              req_next <= req_data_ack;
            else
              req_next <= req_wait_wdata;
            end if;
          end if;

        -- DMA fast-path write (full WSTRB) mirrors legacy.
        when req_dma_write_header =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= dma_write_header_flit;
            coherence_req_wrreq   <= '1';
            req_next              <= req_dma_write_address;
          end if;
        when req_dma_write_address =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= dma_write_address_flit;
            coherence_req_wrreq   <= '1';
            if rmw_write_needs_length = '1' then
              req_next <= req_dma_write_length;
            else
              req_next <= req_dma_write_data;
            end if;
          end if;
        when req_dma_write_length =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= dma_write_length_flit;
            coherence_req_wrreq   <= '1';
            req_next              <= req_dma_write_data;
          end if;
        when req_dma_write_data =>
          if coherence_req_full = '0' then
            coherence_req_data_in <= dma_write_payload_data;
            coherence_req_wrreq   <= '1';
            buffered_write_done   <= '1';
            if wlast_reg = '1' then
              req_next <= req_data_ack;
            else
              req_next <= req_wait_wdata;
            end if;
          end if;

        when req_header =>
          -- Stamp the DMA tran_id into the header for reads (so the
          -- response FSM at this side can match the echoed ID back to a
          -- slot). For writes we still stamp the field but it's never
          -- consumed (writes carry no NoC response).
          header_with_id := active_header;
          header_with_id(DMA_TRAN_ID_MSB downto DMA_TRAN_ID_LSB) := txn_id_v;
          if transaction_reg.dst_is_mem = '1' then
            if coherence_req_full = '0' then
              coherence_req_data_in <= header_with_id;
              coherence_req_wrreq   <= '1';
              req_next              <= req_address;
              if transaction_reg.write = '1' then
                if aw_accepted = '0' then
                  req_somi(transaction_reg.xindex).aw.ready <= '1';
                  if mosi(transaction_reg.xindex).aw.valid = '1' then
                    aw_handshake <= '1';
                  end if;
                end if;
              else
                req_somi(transaction_reg.xindex).ar.ready <= '1';
              end if;
            end if;
          else
            -- Remote AHB path (unused when dst_is_mem = '1'). Forward to misc NoC.
            if remote_ahbs_snd_full = '0' then
              remote_ahbs_snd_data_in <= active_header_narrow;
              remote_ahbs_snd_wrreq   <= '1';
              req_next                <= req_address;
              if transaction_reg.write = '1' then
                if aw_accepted = '0' then
                  req_somi(transaction_reg.xindex).aw.ready <= '1';
                  if mosi(transaction_reg.xindex).aw.valid = '1' then
                    aw_handshake <= '1';
                  end if;
                end if;
              else
                req_somi(transaction_reg.xindex).ar.ready <= '1';
              end if;
            end if;
          end if;

        when req_address =>
          if transaction_reg.dst_is_mem = '1' then
            if coherence_req_full = '0' then
              coherence_req_data_in <= active_payload_address;
              coherence_req_wrreq   <= '1';
              if transaction_reg.write = '1' and transaction_reg.msg_type /= DMA_FROM_DEV then
                req_next <= req_data;
              else
                req_next <= req_length;
              end if;
            end if;
          else
            if remote_ahbs_snd_full = '0' then
              remote_ahbs_snd_data_in <= active_payload_address_narrow;
              remote_ahbs_snd_wrreq   <= '1';
              if transaction_reg.write = '1' then
                if active_size = HSIZE_DWORD then
                  req_next <= req_data_lsb;
                else
                  req_next <= req_data;
                end if;
              else
                req_next <= req_length;
              end if;
            end if;
          end if;

        when req_length =>
          if transaction_reg.dst_is_mem = '1' then
            if coherence_req_full = '0' then
              coherence_req_data_in <= active_payload_length;
              coherence_req_wrreq   <= '1';
              if transaction_reg.write = '1' then
                req_next <= req_data;
              else
                -- READ: request fully emitted -> push to outstanding table
                -- via req_commit, then return to idle.
                req_next <= req_commit;
              end if;
            end if;
          else
            if remote_ahbs_snd_full = '0' then
              remote_ahbs_snd_data_in <= active_payload_length_narrow;
              remote_ahbs_snd_wrreq   <= '1';
              req_next <= req_commit;
            end if;
          end if;

        when req_data =>
          if transaction_reg.dst_is_mem = '1' then
            if coherence_req_full = '0' and mst_valid = '1' then
              if segment_active = '1' then
                if seg_has_data = '1' then
                  coherence_req_data_in <= payload_data;
                  coherence_req_wrreq   <= '1';
                  advance_segment       <= '1';
                  if seg_last_in_beat = '1' then
                    if wlast_reg = '1' then
                      req_next <= req_data_ack;
                    else
                      req_next <= req_wait_wdata;
                    end if;
                  else
                    req_next <= req_header;
                  end if;
                end if;
              else
                coherence_req_data_in <= payload_data;
                coherence_req_wrreq   <= '1';
                if wdata_valid = '1' then
                  buffered_write_done <= '1';
                else
                  slv_ready_v := '1';
                end if;
                if last = '1' then
                  req_next <= req_data_ack;
                end if;
              end if;
            end if;
          else
            if remote_ahbs_snd_full = '0' and mst_valid = '1' then
              if last = '1' then
                req_next <= req_data_ack;
              end if;
              slv_ready_v := '1';
              remote_v := (others => '0');
              remote_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
              remote_v(31 downto 0) := wdata(31 downto 0);
              remote_ahbs_snd_data_in <= remote_v;
              remote_ahbs_snd_wrreq <= '1';
            end if;
          end if;

        when req_data_lsb =>
          if remote_ahbs_snd_full = '0' and mst_valid = '1' then
            remote_v := (others => '0');
            remote_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
            remote_v(31 downto 0) := wdata(31 downto 0);
            remote_ahbs_snd_data_in <= remote_v;
            remote_ahbs_snd_wrreq <= '1';
            req_next <= req_data_msb;
          end if;

        when req_data_msb =>
          if remote_ahbs_snd_full = '0' then
            slv_ready_v := '1';
            remote_v := (others => '0');
            if last = '1' then
              remote_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
            else
              remote_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
            end if;
            remote_v(31 downto 0) := wdata(ARCH_BITS - 1 downto ARCH_BITS - 32);
            remote_ahbs_snd_data_in <= remote_v;
            remote_ahbs_snd_wrreq <= '1';
            if last = '1' then
              req_next <= req_data_ack;
            else
              req_next <= req_data_lsb;
            end if;
          end if;

        when req_data_ack =>
          -- WRITE complete: drive AXI B locally and return to idle/next.
          req_somi(transaction_reg.xindex).b.valid <= '1';
          if transaction_reg.lock = '1' then
            req_somi(transaction_reg.xindex).b.resp <= RBRESP_EXOKAY;
          end if;
          if mst_bready = '1' then
            if selected = '1' and issue_ok = '1' then
              sample_flits <= '1';
              if transaction.write = '1' and transaction.dst_is_mem = '1' then
                req_next <= req_wait_wdata;
              else
                req_next <= req_header;
              end if;
            else
              req_next <= req_idle;
            end if;
          end if;

        when req_commit =>
          -- READ complete (issue side): record context for the response FSM.
          -- Sim-only: pushing must target a free slot. ot_alloc_idx tracks
          -- the lowest-index free slot, so the entry must be invalid here.
          -- pragma translate_off
          assert outstanding_reg(req_alloc_idx_reg).valid = '0'
            report "axislv2noc: req_commit pushing to an already-valid slot"
            severity failure;
          -- pragma translate_on
          push_outstanding       <= '1';
          push_outstanding_idx   <= req_alloc_idx_reg;
          push_outstanding_entry <= (
            valid      => '1',
            id         => transaction_reg.id,
            xindex     => transaction_reg.xindex,
            size       => transaction_reg.size,
            addr       => transaction_reg.addr,
            dst_is_mem => transaction_reg.dst_is_mem);
          -- Return to idle so the next transaction is re-sampled there, on a
          -- cycle where this push has already updated `outstanding_reg`.
          -- Re-sampling directly here would latch `req_alloc_idx_reg` from a
          -- stale `ot_alloc_idx` (this push not yet visible), letting the next
          -- read alias the slot just allocated. Costs one issue cycle per
          -- back-to-back read; memory round-trip latency dominates and up to
          -- OUTSTANDING_DEPTH reads still pipeline, so throughput is unaffected.
          req_next <= req_idle;

        when others =>
          req_next <= req_idle;
      end case;

      req_somi(transaction_reg.xindex).w.ready <= slv_ready_v;
    end process req_roundtrip;

    -----------------------------------------------------------------------
    -- Response FSM
    -----------------------------------------------------------------------
    -- Owns coherence_rsp_rcv_rdreq, somi.r.*, and the active-slot register.
    -- On a fresh header flit, extracts get_dma_tran_id and either matches a
    -- slot (rsp_data) or drops the response (rsp_drop, defensive).
    rsp_roundtrip: process (rsp_state, coherence_rsp_rcv_data_out, coherence_rsp_rcv_empty,
                            outstanding_reg, rsp_active_valid_reg, rsp_active_idx_reg, mosi)
      variable rsp_id_v         : dma_tran_id_type;
      variable rsp_id_int       : integer range 0 to (2**DMA_TRAN_ID_WIDTH) - 1;
      variable match_v          : std_ulogic;
      variable match_idx_v      : outstanding_idx_t;
      variable rsp_preamble_v   : noc_preamble_type;
      variable mst_ready_v      : std_ulogic;
      variable any_outstanding_v : std_ulogic;
    begin
      rsp_next               <= rsp_state;
      load_rsp_active        <= '0';
      load_rsp_active_idx    <= rsp_active_idx_reg;
      clear_rsp_active       <= '0';
      free_outstanding       <= '0';
      free_outstanding_idx   <= rsp_active_idx_reg;
      rsp_coh_rsp_rdreq      <= '0';

      -- Default rsp_somi. Drive r.* based on the active slot when valid, so
      -- the AXI master sees the correct r.id even mid-burst. Also initialize
      -- the aw/ar/w/b fields (which the merge process discards) so this
      -- process has a defined value across the full record.
      for i in 0 to nmst - 1 loop
        rsp_somi(i).r.id    <= outstanding_reg(rsp_active_idx_reg).id;
        rsp_somi(i).r.resp  <= RBRESP_OKAY;
        rsp_somi(i).r.user  <= (others => '0');
        rsp_somi(i).r.last  <= '0';
        rsp_somi(i).r.valid <= '0';
        rsp_somi(i).r.data  <= coherence_rsp_rcv_data_out(AHBDW - 1 downto 0);
        rsp_somi(i).aw.ready <= '0';
        rsp_somi(i).ar.ready <= '0';
        rsp_somi(i).w.ready  <= '0';
        rsp_somi(i).b.id     <= (others => '0');
        rsp_somi(i).b.resp   <= RBRESP_OKAY;
        rsp_somi(i).b.user   <= (others => '0');
        rsp_somi(i).b.valid  <= '0';
      end loop;

      mst_ready_v := mosi(outstanding_reg(rsp_active_idx_reg).xindex).r.ready;
      rsp_preamble_v := get_preamble(this_noc_flit_size,
                                     this_noc_flit_pad & coherence_rsp_rcv_data_out);

      -- Defensive guard: only drain the coherence_rsp_rcv queue when we
      -- actually have an outstanding read to match against. This prevents
      -- the response FSM from stealing the RMW sub-read response that the
      -- legacy/req-side RMW path consumes directly. Combined with the LLC
      -- issue guard above (LLC mode = single-outstanding) this guarantees
      -- rsp/RMW never contend.
      any_outstanding_v := '0';
      for i in 0 to OUTSTANDING_DEPTH - 1 loop
        if outstanding_reg(i).valid = '1' then
          any_outstanding_v := '1';
        end if;
      end loop;

      if any_outstanding_v = '1' then
      case rsp_state is
        when rsp_idle =>
          -- Look for an incoming header on the DMA response queue. Match
          -- by DMA_TRAN_ID against the outstanding table.
          if coherence_rsp_rcv_empty = '0' then
            rsp_id_v := get_dma_tran_id(
              dma_noc_flit_type(coherence_rsp_rcv_data_out(DMA_NOC_FLIT_SIZE - 1 downto 0)));
            rsp_id_int := to_integer(unsigned(rsp_id_v));
            match_v := '0';
            match_idx_v := 0;
            if rsp_id_int < OUTSTANDING_DEPTH then
              if outstanding_reg(rsp_id_int).valid = '1'
                then
                match_v := '1';
                match_idx_v := rsp_id_int;
              end if;
            end if;
            -- LLC fallback: if no match by ID and exactly one slot is
            -- outstanding, take that one (LLC strips the tran_id).
            if match_v = '0' then
              for i in 0 to OUTSTANDING_DEPTH - 1 loop
                if outstanding_reg(i).valid = '1' then
                  if match_v = '0' then
                    match_v := '1';
                    match_idx_v := i;
                  else
                    match_v := '0';      -- ambiguous -> drop
                    exit;
                  end if;
                end if;
              end loop;
            end if;
            rsp_coh_rsp_rdreq <= '1';      -- consume the header
            if match_v = '1' then
              -- Sim-only: the matched slot must be live (not freed) when
              -- we route to rsp_data. Catches the
              -- stale-flit / slot-reuse race if it ever happens.
              -- pragma translate_off
              assert outstanding_reg(match_idx_v).valid = '1'
                report "axislv2noc: matched response to an invalid slot"
                severity failure;
              -- pragma translate_on
              load_rsp_active     <= '1';
              load_rsp_active_idx <= match_idx_v;
              rsp_next            <= rsp_data;
            else
              rsp_next <= rsp_drop;
            end if;
          end if;

        when rsp_data =>
          -- Stream body/tail flits to AXI R channel using the active slot.
          if coherence_rsp_rcv_empty = '0' then
            for i in 0 to nmst - 1 loop
              if i = outstanding_reg(rsp_active_idx_reg).xindex then
                rsp_somi(i).r.valid <= '1';
                if rsp_preamble_v = PREAMBLE_TAIL then
                  rsp_somi(i).r.last <= '1';
                end if;
              end if;
            end loop;
            if mst_ready_v = '1' then
              rsp_coh_rsp_rdreq <= '1';
              if rsp_preamble_v = PREAMBLE_TAIL then
                free_outstanding     <= '1';
                free_outstanding_idx <= rsp_active_idx_reg;
                clear_rsp_active     <= '1';
                rsp_next             <= rsp_idle;
              end if;
            end if;
          end if;

        when rsp_drop =>
          -- Defensive: consume the unmatched packet to its tail and idle.
          if coherence_rsp_rcv_empty = '0' then
            rsp_coh_rsp_rdreq <= '1';
            if rsp_preamble_v = PREAMBLE_TAIL then
              rsp_next <= rsp_idle;
            end if;
          end if;

        when others =>
          rsp_next <= rsp_idle;
      end case;
      end if;  -- any_outstanding_v
    end process rsp_roundtrip;

    -----------------------------------------------------------------------
    -- OT sequential block: state + WSTRB buffering + outstanding table.
    -----------------------------------------------------------------------
    -- Reuses the same control strobes as the legacy clocked process
    -- (latch_wbeat, advance_segment, etc.) so the existing combinational
    -- WSTRB/RMW/DMA-write helpers operate unchanged. Adds outstanding-table
    -- push/done/free and the response-active-slot register.
    ot_seq: process (clk, rst)
    begin
      if rst = '0' then
        req_state            <= req_idle;
        req_alloc_idx_reg    <= 0;
        rsp_state            <= rsp_idle;
        transaction_reg      <= transaction_none;
        rsp_active_valid_reg <= '0';
        rsp_active_idx_reg   <= 0;
        aw_accepted          <= '0';
        wdata_valid          <= '0';
        wdata_reg            <= (others => '0');
        wstrb_reg            <= (others => '0');
        wlast_reg            <= '0';
        beat_index_reg       <= 0;
        beat_addr_reg        <= (others => '0');
        seg_mask_reg         <= (others => '0');
        rmw_read_data_reg    <= (others => '0');
        remote_ahbs_rcv_data_out_hold <= (others => '0');
        for i in 0 to OUTSTANDING_DEPTH - 1 loop
          outstanding_reg(i) <= outstanding_entry_none;
        end loop;
      elsif clk'event and clk = '1' then
        req_state <= req_next;
        rsp_state <= rsp_next;

        if sample_flits = '1' then
          transaction_reg <= transaction;
          -- Latch the allocation index for this request exactly once, here at
          -- sample time, and reuse it for both the req_header stamp and the
          -- req_commit push so the two can never disagree. Safe because the
          -- request FSM is the only allocator and handles one request at a
          -- time, and responses only ever *free* slots -- so the chosen free
          -- slot stays free until this request's req_commit fills it.
          req_alloc_idx_reg <= ot_alloc_idx;
          aw_accepted     <= '0';
          wdata_valid     <= '0';
          wlast_reg       <= '0';
          beat_index_reg  <= 0;
          seg_mask_reg    <= (others => '0');
        end if;
        if rmw_read_sample = '1' then
          rmw_read_data_reg <= coherence_rsp_rcv_data_out(AHBDW - 1 downto 0);
        end if;
        if aw_handshake = '1' then
          aw_accepted <= '1';
        end if;
        if latch_wbeat = '1' then
          wdata_reg     <= mosi(transaction_reg.xindex).w.data;
          wstrb_reg     <= mosi(transaction_reg.xindex).w.strb;
          wlast_reg     <= mosi(transaction_reg.xindex).w.last;
          wdata_valid   <= '1';
          beat_addr_reg <= std_logic_vector(unsigned(transaction_reg.addr) +
                                            to_unsigned(beat_index_reg * (2 ** to_integer(unsigned(transaction_reg.size))), GLOB_PHYS_ADDR_BITS));
          if (coherence /= ACC_COH_LLC and coherence /= ACC_COH_RECALL and
              mosi(transaction_reg.xindex).w.strb /= WSTRB_ALL_ONE) then
            seg_mask_reg <= mosi(transaction_reg.xindex).w.strb;
          else
            seg_mask_reg <= (others => '1');
          end if;
        end if;
        if skip_beat = '1' then
          wdata_valid  <= '0';
          seg_mask_reg <= (others => '0');
          if skip_last = '0' then
            beat_index_reg <= beat_index_reg + 1;
          end if;
        elsif advance_segment = '1' then
          seg_mask_reg <= seg_mask_next;
          if seg_last_in_beat = '1' then
            wdata_valid <= '0';
            if wlast_reg = '0' then
              beat_index_reg <= beat_index_reg + 1;
            end if;
          end if;
        elsif rmw_write_done = '1' then
          wdata_valid  <= '0';
          seg_mask_reg <= (others => '0');
          if wlast_reg = '0' then
            beat_index_reg <= beat_index_reg + 1;
          end if;
        elsif buffered_write_done = '1' then
          wdata_valid  <= '0';
          seg_mask_reg <= (others => '0');
          if wlast_reg = '0' then
            beat_index_reg <= beat_index_reg + 1;
          end if;
        end if;

        -- Outstanding-table maintenance.
        if push_outstanding = '1' then
          outstanding_reg(push_outstanding_idx) <= push_outstanding_entry;
        end if;
        if free_outstanding = '1' then
          outstanding_reg(free_outstanding_idx) <= outstanding_entry_none;
        end if;

        -- Response-active-slot register.
        if load_rsp_active = '1' then
          rsp_active_idx_reg   <= load_rsp_active_idx;
          rsp_active_valid_reg <= '1';
        elsif clear_rsp_active = '1' then
          rsp_active_valid_reg <= '0';
        end if;
      end if;
    end process ot_seq;

    -- Merge req_somi (aw/ar/w/b) and rsp_somi.r into the actual `somi`
    -- output port. Single driver per signal -- the second assignment
    -- inside the same process overrides .r last-wins.
    merge_somi: process (req_somi, rsp_somi)
    begin
      for i in 0 to nmst - 1 loop
        somi(i)   <= req_somi(i);
        somi(i).r <= rsp_somi(i).r;
      end loop;
    end process merge_somi;

    -- Combine the two queue-dequeue strobes. They are mutex by the LLC
    -- single-outstanding fallback (RMW only runs when no reads are in
    -- flight, so rsp_coh_rsp_rdreq is '0' while req_coh_rsp_rdreq pulses,
    -- and vice versa). OR is the right combine.
    coherence_rsp_rcv_rdreq <= req_coh_rsp_rdreq or rsp_coh_rsp_rdreq;

    -- Remote-AHB receive path is unused in DMA-OT mode (the AXI-accelerator
    -- socket ties off remote_ahbs_rcv_data_out='0'/empty='1'). Drive the rdreq
    -- to a known value so the port has exactly one driver.
    remote_ahbs_rcv_rdreq <= '0';

    -- Tie off legacy-only signals that gen_legacy would have driven.
    -- (current_state belongs to the legacy axi_fsm; in gen_dma_ot the
    -- request FSM uses req_state instead.)
    current_state <= idle;
    next_state    <= idle;
    sample_and_hold <= '0';

  end generate gen_dma_ot;

end rtl;
