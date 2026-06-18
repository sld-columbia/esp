-- Copyright (c) 2011-2025 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
-- pragma translate_on

use work.esp_global.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;
use work.cachepackage.all;

entity noc2ahbmst is
  generic (
    tech                : integer;
    hindex              : integer range 0 to NAHBSLV - 1;
    axitran             : integer range 0 to 1 := 0;
    little_end          : integer range 0 to 1 := 0;
    eth_dma             : integer range 0 to 1 := 0;
    narrow_noc          : integer range 0 to 1 := 0;
    cacheline           : integer;
    l2_cache_en         : integer;
    -- Coherence queues in this proxy carry multiple traffic classes:
    -- coherence messages, CPU DMA in SLM, and remote AHB traffic on NoC5.
    -- This parameter allows instances to connect to NoCs with different widths.
    this_coh_flit_size  : integer);
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    local_y : in  local_yx;
    local_x : in  local_yx;
    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;

    -- NoC1 -> tile.
    coherence_req_rdreq       : out std_ulogic;
    coherence_req_data_out    : in  std_logic_vector(this_coh_flit_size - 1 downto 0);
    coherence_req_empty       : in  std_ulogic;
    -- Tile -> NoC2.
    coherence_fwd_wrreq       : out std_ulogic;
    coherence_fwd_data_in     : out std_logic_vector(this_coh_flit_size - 1 downto 0);
    coherence_fwd_full        : in  std_ulogic;
    -- Tile -> NoC3.
    coherence_rsp_snd_wrreq   : out std_ulogic;
    coherence_rsp_snd_data_in : out std_logic_vector(this_coh_flit_size - 1 downto 0);
    coherence_rsp_snd_full    : in  std_ulogic;
    -- NoC4 -> tile.
    dma_rcv_rdreq             : out std_ulogic;
    dma_rcv_data_out          : in  dma_noc_flit_type;
    dma_rcv_empty             : in  std_ulogic;
    -- Tile -> NoC4.
    dma_snd_wrreq             : out std_ulogic;
    dma_snd_data_in           : out dma_noc_flit_type;
    dma_snd_full              : in  std_ulogic;
    dma_snd_atleast_4slots    : in  std_ulogic;
    dma_snd_exactly_3slots    : in  std_ulogic);

end noc2ahbmst;

architecture rtl of noc2ahbmst is

  -- This version complements the WSTRB-aware `axislv2noc` implementation.
  -- When `axislv2noc` splits a DMA beat into subword packets, it annotates the
  -- DMA header reserved field with a size override that is decoded here and
  -- applied to AHB HSIZE and burst behavior.
  -- Delay impact in this block:
  -- - No new FSM states are introduced for WSTRB support.
  -- - Decode is combinational and does not add pipeline stages.
  -- - Extra latency comes indirectly from handling more, smaller DMA packets.

  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_SLD, SLD_MST_PROXY, 0, 0, 0),
    others => zero32);

  -- Default address increment.
  constant default_incr : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0) := conv_std_logic_vector(GLOB_ADDR_INCR, GLOB_PHYS_ADDR_BITS);

  constant this_noc_flit_pad : std_logic_vector(MAX_NOC_FLIT_SIZE - this_coh_flit_size downto 0) := (others => '0');

  function target_word_hsize
    return std_logic_vector is
  begin
    case ARCH_BITS is
      when 64 => return HSIZE_DWORD;
      when others => return HSIZE_WORD;
    end case;
  end target_word_hsize;

  function fix_endian (
    le : std_logic_vector(ARCH_BITS - 1 downto 0))
    return std_logic_vector is
    variable be : std_logic_vector(ARCH_BITS - 1 downto 0);
  begin
    if little_end = 0 then
      be := le;
    else
      for i in 0 to (ARCH_BITS / 8) - 1 loop
        be(8 * (i + 1) - 1 downto 8 * i) := le(ARCH_BITS - 8 * i - 1 downto ARCH_BITS - 8 * (i + 1));
      end loop;  -- i
    end if;
    return be;
  end fix_endian;

  function target_dma_incr
    return std_logic_vector is
  begin
    if eth_dma = 0 then
      return default_incr;
    else
      return conv_std_logic_vector(4, GLOB_PHYS_ADDR_BITS);
    end if;
  end target_dma_incr;

  function target_dma_word_hsize
    return std_logic_vector is
  begin
    if eth_dma = 0 then
      return target_word_hsize;
    else
      return HSIZE_WORD;
    end if;
  end target_dma_word_hsize;

  -- Decode the optional DMA size override encoded by `axislv2noc` when partial
  -- WSTRB causes a beat to be split into subword DMA packets.
  -- Encoding matches `nocpackage` DMA_HDR_SIZE_*:
  -- 00=byte, 01=halfword, 10=word, 11=dword.
  function dma_code_to_hsize (
    code : std_logic_vector(1 downto 0))
    return std_logic_vector is
  begin
    case code is
      when "00" => return HSIZE_BYTE;
      when "01" => return HSIZE_HWORD;
      when "10" => return HSIZE_WORD;
      when others => return HSIZE_DWORD;
    end case;
  end dma_code_to_hsize;


  -- Length handling summary:
  -- - If an AXI-side request supplies length, use it directly.
  -- - If no length flit is provided on coherence traffic, fall back to
  --   cacheline length.
  -- - Protection info is carried in the header reserved field.
  -- - Response destination tile is derived from header origin X/Y.
  --
  -- `ahbm_fsm` groups:
  -- - `receive_*` / `rd_request` / `send_*`: coherence-plane reads.
  -- - `dma_receive_*` / `dma_rd_request` / `dma_send_*`: DMA reads.
  -- - `wr_request` / `write_*`: coherence-plane writes.
  -- - `dma_wr_request` / `dma_write_*`: DMA writes, including WSTRB
  --   size-override compatibility added in this file.
  --
  -- `ahbm_fsm` state guide:
  -- - `receive_header/address/length`: parse incoming request metadata.
  -- - `rd_request`, `wr_request`: arbitrate AHB and issue first access phase.
  -- - `send_header/address/data`: return coherence read responses.
  -- - `dma_receive_address/rdlength/wrlength`: parse DMA request packet shape.
  -- - `dma_rd_request + dma_send_*`: service DMA reads and emit DMA response data.
  -- - `dma_wr_request + dma_write_* + write_last_data`: service DMA writes.
  -- - `write_data/write_busy/write_complete`: service coherence writes.
  -- - `send_put_ack/send_put_ack_address`: emit PUT-ack packets.
  type ahbm_fsm is (receive_header, receive_length,
                    receive_address, rd_request, send_header,
                    send_address, send_data, wr_request, write_data,
                    write_last_data, write_complete,
                    dma_receive_address, dma_rd_request, dma_send_header,
                    dma_send_data, dma_wr_request, dma_write_data,
                    dma_receive_rdlength, dma_receive_wrlength, dma_send_busy, dma_wait_busy,
                    dma_write_busy, write_busy, send_put_ack, send_put_ack_address);

  -- Coherence response header path.
  signal header         : std_logic_vector(this_coh_flit_size - 1 downto 0);
  signal header_reg     : std_logic_vector(this_coh_flit_size - 1 downto 0);
  signal sample_header  : std_ulogic;

  -- DMA response header path.
  signal dma_header         : dma_noc_flit_type;
  signal dma_header_reg     : dma_noc_flit_type;
  signal sample_dma_header  : std_ulogic;

  -- Common request/response state.
  type reg_type is record
    msg     : noc_msg_type;
    hprot   : std_logic_vector(3 downto 0);
    hsize_msb : std_ulogic;
    hsize   : std_logic_vector(2 downto 0);
    -- Optional per-packet size override for DMA writes/reads.
    -- When set, treat this request as one AHB word per DMA flit.
    dma_size_valid : std_ulogic;
    dma_hsize : std_logic_vector(2 downto 0);
    grant   : std_ulogic;
    ready   : std_ulogic;
    resp    : std_logic_vector(1 downto 0);
    addr    : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    incr    : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    coh_flit : std_logic_vector(this_coh_flit_size - 1 downto 0);
    dma_flit : dma_noc_flit_type;
    hwdata  : std_logic_vector(ARCH_BITS - 1 downto 0);
    state   : ahbm_fsm;
    count   : integer;
    bufen   : std_ulogic;
    bufwren : std_ulogic;
    htrans  : std_logic_vector(1 downto 0);
    hburst  : std_logic_vector(2 downto 0);
    hwrite  : std_ulogic;
    hbusreq : std_ulogic;
    word_cnt : integer;
    coh_noc_data : std_logic_vector(this_coh_flit_size - 1 downto 0);
    dma_noc_data : dma_noc_flit_type;
    is_dma  : std_ulogic;
  end record;

  constant reg_none : reg_type := (
    msg     => REQ_GETS_W,
    hprot   => "0011",
    hsize_msb => '0',
    hsize   => target_word_hsize,
    dma_size_valid => '0',
    dma_hsize => target_dma_word_hsize,
    grant   => '0',
    ready   => '0',
    resp    => HRESP_OKAY,
    addr    => (others => '0'),
    incr    => default_incr,
    coh_flit => (others => '0'),
    dma_flit => (others => '0'),
    hwdata  => (others => '0'),
    state   => receive_header,
    count   => 0,
    bufen   => '0',
    bufwren => '0',
    htrans  => HTRANS_IDLE,
    hburst  => HBURST_INCR,
    hwrite  => '0',
    hbusreq => '0',
    word_cnt => 0,
    coh_noc_data => (others => '0'),
    dma_noc_data => (others => '0'),
    is_dma => '0'
  );

  signal r, rin : reg_type;

  signal narrow_coherence_req_rdreq       : std_ulogic;
  signal narrow_coherence_req_data_out    : std_logic_vector(this_coh_flit_size - 1 downto 0);
  signal narrow_coherence_req_empty       : std_ulogic;
  signal narrow_coherence_rsp_snd_wrreq   : std_ulogic;
  signal narrow_coherence_rsp_snd_data_in : std_logic_vector(this_coh_flit_size - 1 downto 0);
  signal narrow_coherence_rsp_snd_full    : std_ulogic;

  type serdes_fsm is (passthru, rsp_msb, req_msb);

  signal serdes_current, serdes_next : serdes_fsm;
  signal sample_req, sample_rsp : std_ulogic;
  -- Hold one extra 64-bit response beat while the SerDes emits the upper half.
  signal load_rsp_buf, sample_rsp_buf, clear_rsp_buf : std_ulogic;
  signal req_reg : std_logic_vector(this_coh_flit_size - 1 downto 0);
  signal rsp_reg : std_logic_vector(this_coh_flit_size - 1 downto 0);
  signal rsp_buf_reg : std_logic_vector(this_coh_flit_size - 1 downto 0);
  signal rsp_buf_valid : std_ulogic;

  -- Optional debug attributes (disabled by default).
  -- attribute mark_debug : string;
  -- attribute mark_debug of dma_rcv_data_out : signal is "true";
  -- attribute mark_debug of dma_rcv_rdreq : signal is "true";
  -- attribute mark_debug of dma_rcv_empty : signal is "true";
  -- attribute mark_debug of dma_snd_data_in : signal is "true";
  -- attribute mark_debug of dma_snd_wrreq : signal is "true";
  -- attribute mark_debug of dma_snd_full : signal is "true";
  -- attribute mark_debug of r : signal is "true";
  -- attribute mark_debug of ahbmi : signal is "true";
  -- attribute mark_debug of ahbmo : signal is "true";

begin  -- rtl

  -----------------------------------------------------------------------------
  -- Build response packet for GETS-family requests.
  -----------------------------------------------------------------------------
  make_rsp_snd_packet : process (narrow_coherence_req_data_out, local_y, local_x)
    variable input_msg_type     : noc_msg_type;
    variable preamble           : noc_preamble_type;
    variable msg_type           : noc_msg_type;
    variable header_v           : std_logic_vector(this_coh_flit_size - 1 downto 0);
    variable reserved           : reserved_field_type;
    variable origin_y, origin_x : local_yx;
  begin  -- process make_rsp_snd_packet
    input_msg_type := get_msg_type(this_coh_flit_size, this_noc_flit_pad & narrow_coherence_req_data_out);
    if input_msg_type = AHB_RD then
      -- Uncached request from a generic master.
      msg_type := RSP_AHB_RD;
    elsif l2_cache_en = 1 then
      -- L2 cache enabled, but no LLC present.
      if input_msg_type = REQ_PUTS or input_msg_type = REQ_PUTM then
        msg_type := FWD_PUT_ACK;        -- TODO: Send on FWD plane.
      elsif input_msg_type = REQ_GETS_W then
        msg_type := RSP_EDATA;
      else
        msg_type := RSP_DATA;
      end if;
    else
      -- No L2 cache; request comes from write-through L1.
      msg_type := RSP_DATA;
    end if;

    reserved := (others => '0');
    header_v := (others => '0');
    origin_y := get_origin_y(this_coh_flit_size, this_noc_flit_pad & narrow_coherence_req_data_out);
    origin_x := get_origin_x(this_coh_flit_size, this_noc_flit_pad & narrow_coherence_req_data_out);
    header_v := create_header(this_coh_flit_size, local_y, local_x, origin_y, origin_x, msg_type, reserved);
    header   <= header_v;
  end process make_rsp_snd_packet;
  -----------------------------------------------------------------------------
  -- Build response packet for DMA traffic.
  -----------------------------------------------------------------------------
  make_dma_packet : process (dma_rcv_data_out, local_y, local_x)
    variable msg_type_req       : noc_msg_type;
    variable msg_type_rsp       : noc_msg_type;
    variable header_v           : dma_noc_flit_type;
    variable reserved           : reserved_field_type;
    variable origin_y, origin_x : local_yx;
  begin  -- process make_dma_packet
    msg_type_req := get_msg_type(DMA_NOC_FLIT_SIZE, dma_noc_flit_pad & dma_rcv_data_out);
    if msg_type_req = REQ_DMA_READ then
      msg_type_rsp := RSP_DATA_DMA;
    else
      msg_type_rsp := DMA_TO_DEV;
    end if;

    reserved   := (others => '0');
    header_v   := (others => '0');
    origin_y   := get_origin_y(DMA_NOC_FLIT_SIZE, dma_noc_flit_pad & dma_rcv_data_out);
    origin_x   := get_origin_x(DMA_NOC_FLIT_SIZE, dma_noc_flit_pad & dma_rcv_data_out);
    header_v   := create_header(DMA_NOC_FLIT_SIZE, local_y, local_x, origin_y, origin_x, msg_type_rsp, reserved);
    dma_header <= header_v;
  end process make_dma_packet;


  -----------------------------------------------------------------------------
  -- Header-register sampling.
  -----------------------------------------------------------------------------
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- Asynchronous reset (active low).
      header_reg        <= (others => '0');
      dma_header_reg    <= (others => '0');
    elsif clk'event and clk = '1' then  -- Rising clock edge.
      if sample_header = '1' then
        header_reg      <= header;
      end if;
      if sample_dma_header = '1' then
        dma_header_reg  <= dma_header;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- AHB handling.
  -----------------------------------------------------------------------------

  -- TODO: Handle additional services.
  -- Currently, coherence_req_* and coherence_rsp_snd_full are handled.
  ahb_roundtrip : process (ahbmi, r,
                           narrow_coherence_req_empty, narrow_coherence_req_data_out,
                           narrow_coherence_rsp_snd_full,
                           header_reg, dma_header_reg,
                           dma_rcv_empty, dma_rcv_data_out,
                           dma_snd_full, dma_snd_atleast_4slots, dma_snd_exactly_3slots,
                           coherence_fwd_full)
    variable v                      : reg_type;
    variable reserved               : reserved_field_type;
    variable preamble, dma_preamble : noc_preamble_type;
    variable hwdata_be : std_logic_vector(ARCH_BITS - 1 downto 0);
    variable word_rem               : integer;
    variable dma_words_per_flit     : integer;
  begin  -- process ahb_roundtrip
    -- Default AHB-master shadow-state assignment.
    v       := r;
    v.grant := ahbmi.hgrant(hindex);
    v.ready := ahbmi.hready;
    v.resp  := ahbmi.hresp;

    -- Default packing uses the architectural DMA flit width.
    -- If size override is active, each DMA packet generated by `axislv2noc`
    -- carries only one logical AHB word (possibly byte/halfword/word).
    -- This does not insert new internal cycles here, but can reduce effective
    -- throughput because more packet boundaries imply more AHB burst restarts.
    dma_words_per_flit := DMA_NOC_WIDTH / ARCH_BITS;
    if r.dma_size_valid = '1' then
      dma_words_per_flit := 1;
    end if;

    reserved     := (others => '0');
    preamble     := get_preamble(this_coh_flit_size, this_noc_flit_pad & narrow_coherence_req_data_out);
    dma_preamble := get_preamble(DMA_NOC_FLIT_SIZE, dma_noc_flit_pad & dma_rcv_data_out);

    sample_header     <= '0';
    sample_dma_header <= '0';

    narrow_coherence_req_rdreq       <= '0';
    narrow_coherence_rsp_snd_data_in <= (others => '0');
    narrow_coherence_rsp_snd_wrreq   <= '0';

    coherence_fwd_data_in <= (others => '0');
    coherence_fwd_wrreq   <= '0';

    dma_rcv_rdreq   <= '0';
    dma_snd_data_in <= (others => '0');
    dma_snd_wrreq   <= '0';

    case r.state is
      when receive_header =>
        -- Header-decode entry point for both coherence and DMA planes.
        v.coh_noc_data := (others => '0');
        v.dma_noc_data := (others => '0');
        if narrow_coherence_req_empty = '0' then
          narrow_coherence_req_rdreq <= '1';
          -- Sample coherence request info.
          v.msg               := get_msg_type(this_coh_flit_size, this_noc_flit_pad & narrow_coherence_req_data_out);
          reserved            := get_reserved_field(this_coh_flit_size, this_noc_flit_pad & narrow_coherence_req_data_out);
          if axitran = 0 then
            v.hprot             := reserved(3 downto 0);
            v.hsize_msb         := '0';
          else
            v.hprot             := '0' & reserved(2 downto 0);
            v.hsize_msb         := reserved(3);
          end if;
          -- Coherence-plane headers do not carry DMA size-override metadata.
          v.dma_size_valid    := '0';
          v.dma_hsize         := target_dma_word_hsize;
          sample_header       <= '1';
          v.state             := receive_address;
        elsif dma_rcv_empty = '0' then
          dma_rcv_rdreq     <= '1';
          -- Sample DMA request info.
          v.msg             := get_msg_type(DMA_NOC_FLIT_SIZE, dma_noc_flit_pad & dma_rcv_data_out);
          reserved          := get_reserved_field(DMA_NOC_FLIT_SIZE, dma_noc_flit_pad & dma_rcv_data_out);
          v.hprot           := reserved(3 downto 0);
          -- WSTRB support handshake:
          -- `axislv2noc` sets `reserved(DMA_HDR_SIZE_VALID_BIT)` and size bits when
          -- it emits partial-WSTRB DMA segments. Decode and carry into request states.
          -- Decode itself is immediate; timing impact appears later as smaller
          -- DMA write/read units on the AHB side.
          v.dma_size_valid  := reserved(DMA_HDR_SIZE_VALID_BIT);
          if reserved(DMA_HDR_SIZE_VALID_BIT) = '1' then
            v.dma_hsize := dma_code_to_hsize(reserved(DMA_HDR_SIZE_MSB downto DMA_HDR_SIZE_LSB));
          else
            v.dma_hsize := target_dma_word_hsize;
          end if;
          sample_dma_header <= '1';
          v.state           := dma_receive_address;
        end if;

      when receive_address =>
        if narrow_coherence_req_empty = '0' then
          narrow_coherence_req_rdreq <= '1';
          v.addr              := narrow_coherence_req_data_out(GLOB_PHYS_ADDR_BITS - 1 downto 0);
          if (r.msg = REQ_GETS_W or r.msg = REQ_GETS_HW or r.msg = REQ_GETS_B or r.msg = AHB_RD)
            or ((r.msg = REQ_GETM_W) and (l2_cache_en /= 0)) then
            if axitran = 0 then
              -- For AHB masters, read length is unknown here; use cacheline length.
              v.count := cacheline;
            end if;
            if l2_cache_en = 0 then
              -- With L2 disabled, first acquire the address bus for memory access.
              -- Then overlap data-bus handover with `send_header`.
              if axitran = 0 then
                v.state := rd_request;
              else
                v.state := receive_length;
              end if;
            else
              -- With L2 enabled (and no LLC), this proxy handles L2 requests.
              -- Read responses must return address before data, so send header
              -- first and defer bus handover to `send_address`.
              -- Flow is `send_header -> rd_request`, then to `send_address`
              -- once address-bus ownership is acquired.
              if axitran = 0 then
                v.state := send_header;
              else
                v.state := receive_length;
              end if;
            end if;
          elsif ((r.msg = REQ_GETM_W or r.msg = REQ_GETM_HW or r.msg = REQ_GETM_B) and (l2_cache_en = 0)) or (r.msg = AHB_WR) then
            -- Writes do not need length here; stop when TAIL appears.
            v.state := wr_request;
          elsif r.msg = REQ_PUTS or r.msg = REQ_PUTM then
            v.state := send_put_ack;
          else
            v.state := receive_header;
          end if;
        end if;

      when receive_length =>
        -- For AXI masters, read length is explicitly provided.
        if narrow_coherence_req_empty = '0' then
          narrow_coherence_req_rdreq <= '1';
          v.count := to_integer(unsigned(narrow_coherence_req_data_out(11 downto 0)));
          if l2_cache_en = 0 then
            v.state := rd_request;
          else
            v.state := send_header;
          end if;
        end if;

      when dma_receive_address =>
        -- DMA request address phase. Message type determines whether a separate
        -- length flit follows (non-coherent write/read) or tail marks completion.
        if dma_rcv_empty = '0' then
          dma_rcv_rdreq <= '1';
          v.addr        := dma_rcv_data_out(GLOB_PHYS_ADDR_BITS - 1 downto 0);
          if r.msg = DMA_TO_DEV or r.msg = REQ_DMA_READ then
            v.state := dma_receive_rdlength;
          elsif r.msg = DMA_FROM_DEV then
            -- Note: to support ESP instances without a DDR controller,
            -- non-coherent DMA sends transaction length for the FPGA-based
            -- `mem2ext` memory proxy, where payload length must be known
            -- at transaction start. The external link can only handle
            -- non-coherent DMA and LLC requests (i.e. it assumes LLC is present),
            -- therefore coherent DMA requests do not send the transaction
            -- length to reduce NoC packet overhead.
            v.state := dma_receive_wrlength;
          else
            -- Coherent writes do not send length; stop when TAIL appears.
            v.state := dma_wr_request;
          end if;
        end if;

      when dma_receive_wrlength =>
        -- Non-coherent DMA write-length flit is consumed for protocol alignment.
        -- This proxy does not need the value itself for internal counting here.
        if dma_rcv_empty = '0' then
          -- Ignore length. DMA length is only required by the
          -- `mem2ext` proxy (see note above).
          dma_rcv_rdreq <= '1';
          v.state := dma_wr_request;
        end if;

      when dma_receive_rdlength =>
        -- DMA read length is used to size the AHB burst/read response stream.
        if dma_rcv_empty = '0' then
          dma_rcv_rdreq <= '1';
          v.count       := to_integer(unsigned(dma_rcv_data_out(31 downto 0)));
          v.state       := dma_rd_request;
        end if;

      when rd_request =>
        if r.msg = REQ_GETS_B then
          v.hsize := HSIZE_BYTE;
        elsif r.msg = REQ_GETS_HW then
          v.hsize := HSIZE_HWORD;
        elsif ARCH_BITS /= 32 and v.hsize_msb = '1' then
          v.hsize := target_word_hsize;
        else
          v.hsize := HSIZE_WORD;
        end if;
        if narrow_coherence_rsp_snd_full = '0' then
          if ((r.count = 1) and (v.grant = '1')
              and (v.ready = '1')) then
            -- Address bus already owned; single-word transfer.
            v.hburst := HBURST_SINGLE;
            v.htrans := HTRANS_NONSEQ;
            if l2_cache_en = 0 then
              v.state := send_header;
            else
              v.state := send_address;
            end if;
          elsif ((v.grant = '1') and (v.ready = '1')) then
            -- Address bus already owned; multi-word burst transfer.
            v.hbusreq := '1';
            v.hburst  := HBURST_INCR;
            v.htrans  := HTRANS_NONSEQ;
            if l2_cache_en = 0 then
              v.state := send_header;
            else
              v.state := send_address;
            end if;
          else
            -- Need to acquire bus ownership.
            if r.count = 1 then
              v.hburst := HBURST_SINGLE;
            else
              v.hburst := HBURST_INCR;
            end if;
            v.hbusreq := '1';
            v.htrans  := HTRANS_NONSEQ;
          end if;
        end if;

      when dma_rd_request =>
        -- DMA read request issue. Override HSIZE when packet explicitly asks for it.
        -- If override is not set, this path is timing-equivalent to the original.
        v.hsize := target_dma_word_hsize;
        if r.dma_size_valid = '1' then
          v.hsize := r.dma_hsize;
        end if;
        if dma_snd_atleast_4slots = '1' then
          if ((r.count = 1) and (v.grant = '1')
              and (v.ready = '1')) then
            -- Address bus already owned; single-word transfer.
            v.hburst := HBURST_SINGLE;
            v.htrans := HTRANS_NONSEQ;
            v.state  := dma_send_header;
          elsif ((v.grant = '1') and (v.ready = '1')) then
            -- Address bus already owned; multi-word burst transfer.
            v.hbusreq := '1';
            v.hburst  := HBURST_INCR;
            v.htrans  := HTRANS_NONSEQ;
            v.state   := dma_send_header;
          else
            -- Need to acquire bus ownership.
            if r.count = 1 then
              v.hburst := HBURST_SINGLE;
            else
              v.hburst := HBURST_INCR;
            end if;
            v.hbusreq := '1';
            v.htrans  := HTRANS_NONSEQ;
          end if;
        end if;

      when send_header =>
        if l2_cache_en = 0 then
          if (v.ready = '1') then
            -- Data bus granted; send response header.
            narrow_coherence_rsp_snd_data_in <= header_reg;
            narrow_coherence_rsp_snd_wrreq   <= '1';
            -- Update address and control bus.
            if r.hsize = HSIZE_WORD then
              -- EDCL always requests 32-bit bursts.
              v.addr := r.addr + 4;
            else
              -- Processors request bursts only when HSIZE equals data width.
              v.addr := r.addr + default_incr;
            end if;
            v.count                   := r.count - 1;
            if r.count = 1 then
              v.hbusreq := '0';
              v.htrans  := HTRANS_IDLE;
            else
              if r.count = 2 then
                v.hbusreq := '0';
              end if;
              v.htrans := HTRANS_SEQ;
            end if;
            v.state := send_data;
          end if;
        else
          if narrow_coherence_rsp_snd_full = '0' then
            narrow_coherence_rsp_snd_data_in <= header_reg;
            narrow_coherence_rsp_snd_wrreq   <= '1';
            v.state                   := rd_request;
          end if;
        end if;

      when send_put_ack =>
        if (narrow_coherence_rsp_snd_full = '0') then
          narrow_coherence_rsp_snd_data_in <= header_reg;
          narrow_coherence_rsp_snd_wrreq   <= '1';
          v.state                   := send_put_ack_address;
        end if;

      when send_put_ack_address =>
        if (narrow_coherence_rsp_snd_full = '0') then
          narrow_coherence_rsp_snd_data_in(this_coh_flit_size - 1 downto this_coh_flit_size - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
          narrow_coherence_rsp_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= r.addr;
          narrow_coherence_rsp_snd_wrreq   <= '1';
          if r.msg = REQ_PUTM then
            v.state := wr_request;
          else
            v.state := receive_header;
          end if;
        end if;

      when dma_send_header =>
        if (v.ready = '1') then
          -- Data bus granted; send DMA response header.
          dma_snd_data_in <= dma_header_reg;
          dma_snd_wrreq   <= '1';
          -- Accelerators use data width equal to the selected processor.
          -- Non-coherent Ethernet DMA uses 32-bit bursts.
          v.addr          := r.addr + target_dma_incr;
          v.count         := r.count - 1;
          word_rem := r.count;
          if word_rem = 1 then
            v.hbusreq := '0';
            v.htrans  := HTRANS_IDLE;
          else
            if word_rem = 2 then
              v.hbusreq := '0';
            end if;
            v.htrans := HTRANS_SEQ;
          end if;
          v.state := dma_send_data;
        end if;

      when send_address =>
        if v.ready = '1' then
          narrow_coherence_rsp_snd_data_in(this_coh_flit_size - 1 downto this_coh_flit_size - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
          narrow_coherence_rsp_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= r.addr;
          narrow_coherence_rsp_snd_wrreq   <= '1';
          v.count                   := r.count - 1;
          -- L2 cache always uses HSIZE equal to data width, so use default increment.
          v.addr                    := r.addr + default_incr;
          v.state                   := send_data;
          v.htrans                  := HTRANS_SEQ;
        end if;

      when send_data =>
        if (v.ready = '1') then
          if narrow_coherence_rsp_snd_full = '1' then
            v.htrans := HTRANS_BUSY;
          else
            -- Send data flit to NoC.
            narrow_coherence_rsp_snd_wrreq   <= '1';
            v.coh_noc_data(this_coh_flit_size -1 downto this_coh_flit_size - PREAMBLE_WIDTH) := PREAMBLE_BODY;
            for i in 1 to (this_coh_flit_size - PREAMBLE_WIDTH) / ARCH_BITS loop
                v.coh_noc_data(ARCH_BITS * i - 1 downto ARCH_BITS * (i -1)) := fix_endian(ahbmi.hrdata);
            end loop;
            narrow_coherence_rsp_snd_data_in <= v.coh_noc_data;
            -- Update address and control bus.
            if r.hsize = HSIZE_WORD then
              -- EDCL burst.
              v.addr := r.addr + 4;
            else
              -- Processor burst.
              v.addr := r.addr + default_incr;
            end if;
            v.count                   := r.count - 1;
            if r.count = 2 then
              v.hbusreq := '0';
              v.htrans  := HTRANS_SEQ;
            elsif r.count = 1 then
              v.hbusreq := '0';
              v.htrans  := HTRANS_IDLE;
            elsif r.count = 0 then
              v.coh_noc_data(this_coh_flit_size -1 downto this_coh_flit_size - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
              for i in 1 to (this_coh_flit_size - PREAMBLE_WIDTH) / ARCH_BITS loop
                  v.coh_noc_data(ARCH_BITS * i - 1 downto ARCH_BITS * (i -1)) := fix_endian(ahbmi.hrdata);
              end loop;
              narrow_coherence_rsp_snd_data_in <= v.coh_noc_data;
              v.state                   := receive_header;
            else
              v.htrans := HTRANS_SEQ;
            end if;
          end if;
        end if;

      when dma_send_data =>
        if (v.ready = '1') then
          -- Send DMA data flit to NoC.
          v.dma_noc_data(DMA_NOC_FLIT_SIZE -1 downto DMA_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
          v.dma_noc_data(ARCH_BITS * (r.word_cnt + 1) - 1 downto ARCH_BITS * r.word_cnt) := fix_endian(ahbmi.hrdata);
          dma_snd_data_in <= v.dma_noc_data;
          word_rem := r.count;
          v.word_cnt := r.word_cnt + 1;
          v.count     := r.count - 1;
          -- Accelerators use data width equal to the selected processor.
          -- Non-coherent Ethernet DMA uses 32-bit bursts.
          v.addr          := r.addr + target_dma_incr;
          if v.word_cnt = DMA_NOC_WIDTH / ARCH_BITS or word_rem = 0 or eth_dma = 1 then
            v.word_cnt := 0;
            dma_snd_wrreq   <= '1';
          end if;
          if word_rem = 2 then
            v.hbusreq := '0';
            v.htrans  := HTRANS_SEQ;
          elsif word_rem = 1 then
            v.hbusreq := '0';
            v.htrans  := HTRANS_IDLE;
          elsif word_rem = 0 then
            v.dma_noc_data(DMA_NOC_FLIT_SIZE -1 downto DMA_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
            dma_snd_data_in <= v.dma_noc_data;
            v.state         := receive_header;
          else
            if dma_snd_exactly_3slots = '1' and v.word_cnt = DMA_NOC_WIDTH / ARCH_BITS - 1 then
              v.htrans := HTRANS_BUSY;
              v.state  := dma_send_busy;
            else
              v.htrans := HTRANS_SEQ;
            end if;
          end if;
        end if;

      when dma_send_busy =>
        if (v.ready = '1') then
          dma_snd_wrreq   <= '1';
          v.dma_noc_data(DMA_NOC_FLIT_SIZE -1 downto DMA_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
          v.dma_noc_data(ARCH_BITS * (r.word_cnt + 1) - 1 downto ARCH_BITS * r.word_cnt) := fix_endian(ahbmi.hrdata);
          dma_snd_data_in <= v.dma_noc_data;
          v.count         := r.count - 1;
          v.word_cnt      := 0;
          v.state := dma_wait_busy;
        end if;

      when dma_wait_busy =>
        if dma_snd_exactly_3slots = '1' or dma_snd_atleast_4slots = '1' then
          v.htrans := HTRANS_SEQ;
        end if;
        if (r.htrans = HTRANS_SEQ and v.ready = '1') then
          v.addr  := r.addr + target_dma_incr;
          v.state := dma_send_data;
        end if;

      when wr_request =>
        if r.msg = REQ_GETM_B then
          v.hsize := HSIZE_BYTE;
        elsif r.msg = REQ_GETM_HW then
          v.hsize := HSIZE_HWORD;
        elsif ARCH_BITS /= 32 and v.hsize_msb = '1' then
          v.hsize := target_word_hsize;
        else
          v.hsize := HSIZE_WORD;
        end if;
        if narrow_coherence_req_empty = '0' then
          if ((preamble = PREAMBLE_TAIL) and
              (v.grant = '1') and (v.ready = '1')) then
            -- Address bus already owned; single-word transfer. Prefetch first data flit.
            narrow_coherence_req_rdreq <= '1';
            v.coh_flit          := narrow_coherence_req_data_out;
            v.hburst            := HBURST_SINGLE;
            v.htrans            := HTRANS_NONSEQ;
            v.hwrite            := '1';
            v.state             := write_last_data;
            v.is_dma            := '0';
          elsif ((v.grant = '1') and (v.ready = '1')) then
            -- Address bus already owned; burst transfer. Prefetch first data flit.
            narrow_coherence_req_rdreq <= '1';
            v.coh_flit          := narrow_coherence_req_data_out;
            v.hbusreq           := '1';
            v.hburst            := HBURST_INCR;
            v.htrans            := HTRANS_NONSEQ;
            v.hwrite            := '1';
            v.state             := write_data;
          else
            -- Need to acquire bus ownership.
            if (preamble = PREAMBLE_TAIL) then
              v.hburst := HBURST_SINGLE;
            else
              v.hburst := HBURST_INCR;
            end if;
            v.hbusreq := '1';
            v.htrans  := HTRANS_NONSEQ;
            v.hwrite  := '1';
          end if;
        end if;

      when dma_wr_request =>
        -- DMA write request issue. Override HSIZE and burst heuristics when
        -- segmented WSTRB traffic forces one logical word per DMA packet.
        -- No extra state transitions vs baseline; delay grows only if traffic is
        -- split into more single-word packets (more grant/address phases).
        v.hsize := target_dma_word_hsize;
        if r.dma_size_valid = '1' then
          v.hsize := r.dma_hsize;
        end if;
        if dma_rcv_empty = '0' then
          if ((dma_preamble = PREAMBLE_TAIL) and
              (v.grant = '1') and (v.ready = '1')) then
            -- Address bus already owned; single-word transfer. Prefetch first flit.
            dma_rcv_rdreq <= '1';
            v.dma_flit    := dma_rcv_data_out;
            if (dma_words_per_flit = 1) then
              v.hburst      := HBURST_SINGLE;
            else
              v.hburst      := HBURST_INCR;
            end if;
            v.htrans      := HTRANS_NONSEQ;
            v.hwrite      := '1';
            v.state       := write_last_data;
            v.is_dma      := '1';
          elsif ((v.grant = '1') and (v.ready = '1')) then
            -- Address bus already owned; burst transfer. Prefetch first flit.
            dma_rcv_rdreq <= '1';
            v.dma_flit    := dma_rcv_data_out;
            v.hbusreq     := '1';
            v.hburst      := HBURST_INCR;
            v.htrans      := HTRANS_NONSEQ;
            v.hwrite      := '1';
            v.state       := dma_write_data;
          else
            -- Need to acquire bus ownership.
            if (dma_preamble = PREAMBLE_TAIL and dma_words_per_flit = 1) then
              v.hburst := HBURST_SINGLE;
            else
              v.hburst := HBURST_INCR;
            end if;
            v.hbusreq := '1';
            v.htrans  := HTRANS_NONSEQ;
            v.hwrite  := '1';
          end if;
        end if;

      when write_data =>
        if (v.ready = '1') then
          -- Write data word to memory.
          v.hwdata := r.coh_flit(ARCH_BITS - 1 downto 0);
          -- Update address and bus-control signals.
          if r.hsize = HSIZE_WORD then
            v.addr := r.addr + 4;
          else
            v.addr := r.addr + default_incr;
          end if;
          if narrow_coherence_req_empty = '1' then
            v.htrans := HTRANS_BUSY;
            v.state  := write_busy;
          else
            v.htrans := HTRANS_SEQ;
            if (preamble = PREAMBLE_TAIL) then
              v.hbusreq := '0';
              v.state   := write_last_data;
              v.is_dma  := '0';
            end if;
            -- Prefetch next flit.
            narrow_coherence_req_rdreq <= '1';
            v.coh_flit          := narrow_coherence_req_data_out;
          end if;
        end if;

      when dma_write_data =>
        -- Stream DMA payload words onto AHB. dma_words_per_flit can collapse to
        -- 1 for WSTRB-derived subword packets, so fetch cadence follows override.
        -- With dma_words_per_flit=1 this loop exits per packet sooner, so total
        -- transaction latency depends on upstream packet count, not new local states.
        if (v.ready = '1') then
          -- Write data word to memory.
          v.hwdata := r.dma_flit((r.word_cnt + 1) * ARCH_BITS - 1 downto r.word_cnt * ARCH_BITS);
          -- Update address and bus-control signals.
          v.addr   := r.addr + target_dma_incr;
          v.word_cnt := r.word_cnt + 1;
          v.htrans := HTRANS_SEQ;
          if v.word_cnt = dma_words_per_flit or eth_dma = 1 then
            v.word_cnt := 0;
            if dma_rcv_empty = '1' then
              v.htrans := HTRANS_BUSY;
              v.state  := dma_write_busy;
            else
              if (dma_preamble = PREAMBLE_TAIL) then
                if (dma_words_per_flit = 1 or eth_dma = 1) then
                  v.hbusreq := '0';
                end if;
                v.state   := write_last_data;
                v.is_dma  := '1';
              end if;
              -- Prefetch next DMA flit.
              dma_rcv_rdreq <= '1';
              v.dma_flit    := dma_rcv_data_out;
            end if;
          end if;
        end if;

      when write_busy =>
        if (v.ready = '1' and narrow_coherence_req_empty = '0') then
          v.htrans := HTRANS_SEQ;
          if (preamble = PREAMBLE_TAIL) then
            v.hbusreq := '0';
            v.state   := write_last_data;
            v.is_dma  := '0';
          else
            v.state := write_data;
          end if;
          -- Prefetch next flit.
          narrow_coherence_req_rdreq <= '1';
          v.coh_flit          := narrow_coherence_req_data_out;
        end if;

      when dma_write_busy =>
        -- Resume DMA write stream after temporary HTRANS_BUSY backpressure.
        if (v.ready = '1' and dma_rcv_empty = '0') then
          v.htrans := HTRANS_SEQ;
          if (dma_preamble = PREAMBLE_TAIL) then
            if (dma_words_per_flit = 1 or eth_dma = 1) then
              v.hbusreq := '0';
            end if;
            v.state   := write_last_data;
            v.is_dma  := '1';
          else
            v.state := dma_write_data;
          end if;
          -- Prefetch next DMA flit.
          dma_rcv_rdreq <= '1';
          v.dma_flit    := dma_rcv_data_out;
        end if;

      when write_last_data =>
        -- Final data phase. DMA path also uses dma_words_per_flit so bus release
        -- remains correct for both full-width and size-overridden packets.
        -- For size-overridden packets this state usually retires after one word,
        -- which is correct but increases per-packet overhead across a whole beat.
        if (v.ready = '1') then
          v.word_cnt := r.word_cnt + 1;
          v.hwrite := '1';
          v.htrans := HTRANS_SEQ;
          v.addr   := r.addr + target_dma_incr;
          if r.is_dma = '1' then
            v.hwdata := r.dma_flit((r.word_cnt + 1) * ARCH_BITS - 1 downto r.word_cnt * ARCH_BITS);
            if v.word_cnt = dma_words_per_flit - 1 then
              v.hbusreq := '0';
            end if;
            if v.word_cnt = dma_words_per_flit or eth_dma = 1 then
              v.htrans := HTRANS_IDLE;
              v.hwrite := '0';
              v.state  := write_complete;
              v.word_cnt := 0;
            end if;
          else
            v.hwdata := r.coh_flit((r.word_cnt + 1) * ARCH_BITS - 1 downto r.word_cnt * ARCH_BITS);
            if v.word_cnt = (this_coh_flit_size - PREAMBLE_WIDTH) / ARCH_BITS - 1 then
              v.hbusreq := '0';
            end if;
            if v.word_cnt = (this_coh_flit_size - PREAMBLE_WIDTH) / ARCH_BITS then
              v.htrans := HTRANS_IDLE;
              v.hwrite := '0';
              v.state  := write_complete;
              v.word_cnt := 0;
            end if;
          end if;
        end if;

      when write_complete =>
        if (v.ready = '1') then
          v.state := receive_header;
        end if;

      when others =>
        v.state := receive_header;

    end case;

    rin           <= v;
    ahbmo.hbusreq <= r.hbusreq;
    ahbmo.hlock   <= '0';
    ahbmo.htrans  <= r.htrans;
    ahbmo.haddr   <= r.addr;
    ahbmo.hwrite  <= r.hwrite;
    ahbmo.hsize   <= r.hsize;
    ahbmo.hburst  <= r.hburst;
    ahbmo.hprot   <= r.hprot;
    -- Convert between little-endian and big-endian data views.
    if r.hsize = HSIZE_BYTE then
      hwdata_be := ahbdrivedata(r.hwdata(7 downto 0));
    elsif r.hsize = HSIZE_HWORD then
      hwdata_be := ahbdrivedata(r.hwdata(15 downto 0));
    elsif r.hsize = HSIZE_WORD then
      hwdata_be := ahbdrivedata(r.hwdata(31 downto 0));
    else
      hwdata_be := ahbdrivedata(r.hwdata(ARCH_BITS - 1 downto 0));
    end if;
    ahbmo.hwdata  <= fix_endian(hwdata_be);
    ahbmo.hirq    <= (others => '0');
    ahbmo.hconfig <= hconfig;
    ahbmo.hindex  <= hindex;

  end process ahb_roundtrip;

  -- Update main FSM state.
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- Asynchronous reset (active low).
      r <= reg_none;
    elsif clk'event and clk = '1' then  -- Rising clock edge.
      r <= rin;
    end if;
  end process;

  -- SerDes for narrow NoC.
  serdes_gen: if narrow_noc /= 0 and ARCH_BITS /= 32 generate

    serdes_beh: process (serdes_current, r, ahbmi, rsp_reg, req_reg,
                         rsp_buf_reg, rsp_buf_valid,
                         narrow_coherence_req_rdreq,
                         coherence_req_data_out,
                         coherence_req_empty,
                         narrow_coherence_rsp_snd_wrreq,
                         narrow_coherence_rsp_snd_data_in,
                         coherence_rsp_snd_full)
    variable wide_noc_data : std_logic_vector(this_coh_flit_size - 1 downto 0);
    begin  -- process serdes_beh

      serdes_next <= serdes_current;
      sample_rsp <= '0';
      sample_req <= '0';
      load_rsp_buf <= '0';
      sample_rsp_buf <= '0';
      clear_rsp_buf <= '0';

      -- Passthrough by default.
      coherence_req_rdreq           <= narrow_coherence_req_rdreq;
      narrow_coherence_req_data_out <= coherence_req_data_out;
      narrow_coherence_req_empty    <= coherence_req_empty;
      coherence_rsp_snd_wrreq       <= narrow_coherence_rsp_snd_wrreq;
      coherence_rsp_snd_data_in     <= narrow_coherence_rsp_snd_data_in;
      narrow_coherence_rsp_snd_full <= coherence_rsp_snd_full;

      case serdes_current is

        when passthru =>
          if rsp_buf_valid = '1' and coherence_rsp_snd_full = '0' then
            coherence_rsp_snd_wrreq <= '1';
            wide_noc_data(this_coh_flit_size - 1 downto this_coh_flit_size - PREAMBLE_WIDTH) := PREAMBLE_BODY;
            for i in 1 to this_coh_flit_size / 32 loop
              wide_noc_data(32 * i - 1 downto 32 * (i - 1)) :=
                rsp_buf_reg(31 downto 0);
            end loop;
            coherence_rsp_snd_data_in <= wide_noc_data;
            load_rsp_buf <= '1';
            if r.state = send_data and r.hsize = HSIZE_DWORD and ahbmi.hready = '1' and
              narrow_coherence_rsp_snd_wrreq = '1' then
              sample_rsp_buf <= '1';
            else
              clear_rsp_buf <= '1';
            end if;
            serdes_next <= rsp_msb;
          elsif r.state = send_data and r.hsize = HSIZE_DWORD and ahbmi.hready = '1' and coherence_rsp_snd_full = '0' then
            sample_rsp <= '1';
            coherence_rsp_snd_wrreq <= '1';
            wide_noc_data(this_coh_flit_size - 1 downto this_coh_flit_size - PREAMBLE_WIDTH) := PREAMBLE_BODY;
            for i in 1 to this_coh_flit_size / 32 loop
              wide_noc_data(32 * i - 1 downto 32 * (i - 1)) :=
                narrow_coherence_rsp_snd_data_in(31 downto 0);
            end loop;
            coherence_rsp_snd_data_in <= wide_noc_data;
            serdes_next <= rsp_msb;
          elsif (r.state = wr_request or r.state = write_data or r.state = write_busy) and
            (r.hsize_msb = '1' and ARCH_BITS /= 32) and
            coherence_req_empty = '0' then
            sample_req <= '1';
            narrow_coherence_req_empty <= '1';
            coherence_req_rdreq <= '1';
            serdes_next <= req_msb;
          end if;

        when rsp_msb =>
          if rsp_buf_valid = '1' then
            narrow_coherence_rsp_snd_full <= '1';
          else
            narrow_coherence_rsp_snd_full <= coherence_rsp_snd_full;
          end if;
          wide_noc_data(this_coh_flit_size - 1 downto this_coh_flit_size - PREAMBLE_WIDTH) :=
            rsp_reg(this_coh_flit_size - 1 downto this_coh_flit_size - PREAMBLE_WIDTH);
          for i in 1 to this_coh_flit_size / 32 loop
            wide_noc_data(32 * i - 1 downto 32 * (i - 1)) :=
              rsp_reg(ARCH_BITS - 1 downto ARCH_BITS - 32);
          end loop;
          coherence_rsp_snd_data_in <= wide_noc_data;
          if coherence_rsp_snd_full = '0' then
            coherence_rsp_snd_wrreq <= '1';
            if rsp_buf_valid = '0' and r.state = send_data and r.hsize = HSIZE_DWORD and
              ahbmi.hready = '1' and narrow_coherence_rsp_snd_wrreq = '1' then
              sample_rsp_buf <= '1';
            end if;
            serdes_next <= passthru;
          else
            coherence_rsp_snd_wrreq <= '0';
            serdes_next <= rsp_msb;
          end if;

        when req_msb =>
          narrow_coherence_req_data_out(this_coh_flit_size - 1 downto 64) <= coherence_req_data_out(this_coh_flit_size - 1 downto 64);
          narrow_coherence_req_data_out(ARCH_BITS - 1 downto ARCH_BITS - 32) <= coherence_req_data_out(31 downto 0);
          narrow_coherence_req_data_out(31 downto 0) <= req_reg(31 downto 0);
          if coherence_req_empty = '0' and narrow_coherence_req_rdreq = '1'  then
            serdes_next <= passthru;
          end if;

        when others =>
          serdes_next <= passthru;

      end case;

    end process serdes_beh;

    -- Update SerDes FSM state.
    process (clk, rst)
    begin  -- process
      if rst = '0' then                   -- Asynchronous reset (active low).
        serdes_current <= passthru;
        rsp_reg <= (others => '0');
        rsp_buf_reg <= (others => '0');
        rsp_buf_valid <= '0';
        req_reg <= (others => '0');
      elsif clk'event and clk = '1' then  -- Rising clock edge.
        serdes_current <= serdes_next;
        if sample_rsp = '1' then
          rsp_reg <= narrow_coherence_rsp_snd_data_in;
        elsif load_rsp_buf = '1' then
          rsp_reg <= rsp_buf_reg;
        end if;
        if sample_rsp_buf = '1' then
          rsp_buf_reg <= narrow_coherence_rsp_snd_data_in;
          rsp_buf_valid <= '1';
        elsif clear_rsp_buf = '1' then
          rsp_buf_valid <= '0';
        end if;
        if sample_req = '1' then
          req_reg <= coherence_req_data_out;
        end if;
      end if;
    end process;

  end generate serdes_gen;


  no_serdes_gen: if narrow_noc = 0 or ARCH_BITS = 32 generate
    coherence_req_rdreq           <= narrow_coherence_req_rdreq;
    narrow_coherence_req_data_out <= coherence_req_data_out;
    narrow_coherence_req_empty    <= coherence_req_empty;
    coherence_rsp_snd_wrreq       <= narrow_coherence_rsp_snd_wrreq;
    coherence_rsp_snd_data_in     <= narrow_coherence_rsp_snd_data_in;
    narrow_coherence_rsp_snd_full <= coherence_rsp_snd_full;
  end generate no_serdes_gen;

end rtl;
