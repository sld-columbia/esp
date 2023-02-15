-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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

entity noc2ahbmst is
  generic (
    tech        : integer;
    hindex      : integer range 0 to NAHBSLV - 1;
    axitran     : integer range 0 to 1 := 0;
    little_end  : integer range 0 to 1 := 0;
    eth_dma     : integer range 0 to 1 := 0;
    narrow_noc  : integer range 0 to 1 := 0;
    cacheline   : integer;
    l2_cache_en : integer);
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    local_y : in  local_yx;
    local_x : in  local_yx;
    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;

    -- NoC1->tile
    coherence_req_rdreq       : out std_ulogic;
    coherence_req_data_out    : in  noc_flit_type;
    coherence_req_empty       : in  std_ulogic;
    -- tile->NoC2
    coherence_fwd_wrreq       : out std_ulogic;
    coherence_fwd_data_in     : out noc_flit_type;
    coherence_fwd_full        : in  std_ulogic;
    -- tile->NoC3
    coherence_rsp_snd_wrreq   : out std_ulogic;
    coherence_rsp_snd_data_in : out noc_flit_type;
    coherence_rsp_snd_full    : in  std_ulogic;
    -- NoC4->tile
    dma_rcv_rdreq             : out std_ulogic;
    dma_rcv_data_out          : in  noc_flit_type;
    dma_rcv_empty             : in  std_ulogic;
    -- tile->NoC4
    dma_snd_wrreq             : out std_ulogic;
    dma_snd_data_in           : out noc_flit_type;
    dma_snd_full              : in  std_ulogic;
    dma_snd_atleast_4slots    : in  std_ulogic;
    dma_snd_exactly_3slots    : in  std_ulogic);

end noc2ahbmst;

architecture rtl of noc2ahbmst is

  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_SLD, SLD_MST_PROXY, 0, 0, 0),
    others => zero32);

  -- Default address increment
  constant default_incr : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0) := conv_std_logic_vector(GLOB_ADDR_INCR, GLOB_PHYS_ADDR_BITS);

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


  -- If length is not received, then use fix length of cacheline words.
  -- The accelerators and masters on AXI will always provide a length.
  -- Protection info is in the reserved field of the header
  -- determine the destination tile for the response based on the header origin
  -- x and y info
  type ahbm_fsm is (receive_header, receive_length,
                    receive_address, rd_request, send_header,
                    send_address, send_data, wr_request, write_data,
                    write_last_data, write_complete,
                    dma_receive_address, dma_rd_request, dma_send_header,
                    dma_send_data, dma_wr_request, dma_write_data,
                    dma_receive_rdlength, dma_receive_wrlength, dma_send_busy, dma_wait_busy,
                    dma_write_busy, write_busy, send_put_ack, send_put_ack_address);

  -- RSP_DATA
  signal header        : noc_flit_type;
  signal header_reg    : noc_flit_type;
  signal sample_header : std_ulogic;

  -- DMA_TO_DEV
  signal dma_header        : noc_flit_type;
  signal sample_dma_header : std_ulogic;

  -- common
  type reg_type is record
    msg     : noc_msg_type;
    hprot   : std_logic_vector(3 downto 0);
    hsize_msb : std_ulogic;
    hsize   : std_logic_vector(2 downto 0);
    grant   : std_ulogic;
    ready   : std_ulogic;
    resp    : std_logic_vector(1 downto 0);
    addr    : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    incr    : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    flit    : noc_flit_type;
    hwdata  : std_logic_vector(ARCH_BITS - 1 downto 0);
    state   : ahbm_fsm;
    count   : integer;
    bufen   : std_ulogic;
    bufwren : std_ulogic;
    htrans  : std_logic_vector(1 downto 0);
    hburst  : std_logic_vector(2 downto 0);
    hwrite  : std_ulogic;
    hbusreq : std_ulogic;
  end record;
  constant reg_none : reg_type := (
    msg     => REQ_GETS_W,
    hprot   => "0011",
    hsize_msb => '0',
    hsize   => target_word_hsize,
    grant   => '0',
    ready   => '0',
    resp    => HRESP_OKAY,
    addr    => (others => '0'),
    incr    => default_incr,
    flit    => (others => '0'),
    hwdata  => (others => '0'),
    state   => receive_header,
    count   => 0,
    bufen   => '0',
    bufwren => '0',
    htrans  => HTRANS_IDLE,
    hburst  => HBURST_INCR,
    hwrite  => '0',
    hbusreq => '0');

  signal r, rin : reg_type;

  signal narrow_coherence_req_rdreq       : std_ulogic;
  signal narrow_coherence_req_data_out    : noc_flit_type;
  signal narrow_coherence_req_empty       : std_ulogic;
  signal narrow_coherence_rsp_snd_wrreq   : std_ulogic;
  signal narrow_coherence_rsp_snd_data_in : noc_flit_type;
  signal narrow_coherence_rsp_snd_full    : std_ulogic;

  type serdes_fsm is (passthru, rsp_msb, req_msb);

  signal serdes_current, serdes_next : serdes_fsm;
  signal sample_req, sample_rsp : std_ulogic;
  signal req_reg : noc_flit_type;
  signal rsp_reg : noc_flit_type;

  attribute mark_debug : string;
  -- attribute mark_debug of coherence_req_data_out : signal is "true";
  -- attribute mark_debug of coherence_req_rdreq : signal is "true";
  -- attribute mark_debug of coherence_rsp_snd_wrreq : signal is"true";
  -- attribute mark_debug of coherence_rsp_snd_data_in : signal is"true";
  -- attribute mark_debug of r : signal is"true";
  -- attribute mark_debug of ahbmi : signal is"true";
  -- attribute mark_debug of ahbmo : signal is"true";

begin  -- rtl

  -----------------------------------------------------------------------------
  -- Create packet for response messages to GETS
  -----------------------------------------------------------------------------
  make_rsp_snd_packet : process (narrow_coherence_req_data_out, local_y, local_x)
    variable input_msg_type     : noc_msg_type;
    variable preamble           : noc_preamble_type;
    variable msg_type           : noc_msg_type;
    variable header_v           : noc_flit_type;
    variable reserved           : reserved_field_type;
    variable origin_y, origin_x : local_yx;
  begin  -- process make_packet
    input_msg_type := get_msg_type(NOC_FLIT_SIZE, narrow_coherence_req_data_out);
    if input_msg_type = AHB_RD then
      -- Uncached request from generic master
      msg_type := RSP_AHB_RD;
    elsif l2_cache_en = 1 then
      -- L2 cache enabled, but no LLC present
      if input_msg_type = REQ_PUTS or input_msg_type = REQ_PUTM then
        msg_type := FWD_PUT_ACK;        -- TODO: send on FWD plane
      elsif input_msg_type = REQ_GETS_W then
        msg_type := RSP_EDATA;
      else
        msg_type := RSP_DATA;
      end if;
    else
      -- no L2 cache; request is from write-through L1
      msg_type := RSP_DATA;
    end if;

    reserved := (others => '0');
    header_v := (others => '0');
    origin_y := get_origin_y(NOC_FLIT_SIZE, narrow_coherence_req_data_out);
    origin_x := get_origin_x(NOC_FLIT_SIZE, narrow_coherence_req_data_out);
    header_v := create_header(NOC_FLIT_SIZE, local_y, local_x, origin_y, origin_x, msg_type, reserved);
    header   <= header_v;
  end process make_rsp_snd_packet;
  -----------------------------------------------------------------------------
  -- Create packet for DMA response message
  -----------------------------------------------------------------------------
  make_dma_packet : process (dma_rcv_data_out, local_y, local_x)
    variable msg_type_req       : noc_msg_type;
    variable msg_type_rsp       : noc_msg_type;
    variable header_v           : noc_flit_type;
    variable reserved           : reserved_field_type;
    variable origin_y, origin_x : local_yx;
  begin  -- process make_packet
    msg_type_req := get_msg_type(NOC_FLIT_SIZE, dma_rcv_data_out);
    if msg_type_req = REQ_DMA_READ then
      msg_type_rsp := RSP_DATA_DMA;
    else
      msg_type_rsp := DMA_TO_DEV;
    end if;

    reserved   := (others => '0');
    header_v   := (others => '0');
    origin_y   := get_origin_y(NOC_FLIT_SIZE, dma_rcv_data_out);
    origin_x   := get_origin_x(NOC_FLIT_SIZE, dma_rcv_data_out);
    header_v   := create_header(NOC_FLIT_SIZE, local_y, local_x, origin_y, origin_x, msg_type_rsp, reserved);
    dma_header <= header_v;
  end process make_dma_packet;


  -----------------------------------------------------------------------------
  -- Registers
  -----------------------------------------------------------------------------
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      header_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_header = '1' then
        header_reg <= header;
      elsif sample_dma_header = '1' then
        header_reg <= dma_header;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- AHB handling
  -----------------------------------------------------------------------------

  --TODO: handle other services
  -- so far coherence_req_, coherence_rsp_snd_full are handled
  ahb_roundtrip : process (ahbmi, r,
                           narrow_coherence_req_empty, narrow_coherence_req_data_out,
                           narrow_coherence_rsp_snd_full,
                           header_reg,
                           dma_rcv_empty, dma_rcv_data_out,
                           dma_snd_full, dma_snd_atleast_4slots, dma_snd_exactly_3slots,
                           coherence_fwd_full)
    variable v                      : reg_type;
    variable reserved               : reserved_field_type;
    variable preamble, dma_preamble : noc_preamble_type;
    variable hwdata_be : std_logic_vector(ARCH_BITS - 1 downto 0);
  begin  -- process ahb_roundtrip
    -- Default ahbmo assignment
    v       := r;
    v.grant := ahbmi.hgrant(hindex);
    v.ready := ahbmi.hready;
    v.resp  := ahbmi.hresp;

    reserved     := (others => '0');
    preamble     := get_preamble(NOC_FLIT_SIZE, narrow_coherence_req_data_out);
    dma_preamble := get_preamble(NOC_FLIT_SIZE, dma_rcv_data_out);

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
        if narrow_coherence_req_empty = '0' then
          narrow_coherence_req_rdreq <= '1';
          -- Sample request info
          v.msg               := get_msg_type(NOC_FLIT_SIZE, narrow_coherence_req_data_out);
          reserved            := get_reserved_field(NOC_FLIT_SIZE, narrow_coherence_req_data_out);
          if axitran = 0 then
            v.hprot             := reserved(3 downto 0);
            v.hsize_msb         := '0';
          else
            v.hprot             := '0' & reserved(2 downto 0);
            v.hsize_msb         := reserved(3);
          end if;
          sample_header       <= '1';
          v.state             := receive_address;
        elsif dma_rcv_empty = '0' then
          dma_rcv_rdreq     <= '1';
          -- Sample DMA request
          v.msg             := get_msg_type(NOC_FLIT_SIZE, dma_rcv_data_out);
          reserved          := get_reserved_field(NOC_FLIT_SIZE, dma_rcv_data_out);
          v.hprot           := reserved(3 downto 0);
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
              -- If master is on AHB, we don't know the lenght of a read transaction
              -- Use default size: cacheline
              v.count := cacheline;
            end if;
            if l2_cache_en = 0 then
              -- NB: when the L2 cache is not enabled, we first initiate the
              -- bus handover to access memory and wait until the address bus
              -- is granted. Then we overlap the data bus handover with the
              -- send_header state.
              if axitran = 0 then
                v.state := rd_request;
              else
                v.state := receive_length;
              end if;
            else
              -- NB: when L2 cache is enabled, but LLC is not, this proxy
              -- handles L2 requests, which imply read requests must return the
              -- address before the data. In this case we send the header right
              -- away and defer the bus handover to the next state (i.e. send_address).
              -- As a result we traverse send_header first and
              -- rd_request right after. We move to send_address when
              -- the address bus is acquired overlapping the data bus handover
              -- with this new state.
              if axitran = 0 then
                v.state := send_header;
              else
                v.state := receive_length;
              end if;
            end if;
          elsif ((r.msg = REQ_GETM_W or r.msg = REQ_GETM_HW or r.msg = REQ_GETM_B) and (l2_cache_en = 0)) or (r.msg = AHB_WR) then
            -- Writes don't need size. Stop when tail appears.
            v.state := wr_request;
          elsif r.msg = REQ_PUTS or r.msg = REQ_PUTM then
            v.state := send_put_ack;
          else
            v.state := receive_header;
          end if;
        end if;

      when receive_length =>
        -- If master is on AXI, we know the length of the read transaction
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
        if dma_rcv_empty = '0' then
          dma_rcv_rdreq <= '1';
          v.addr        := dma_rcv_data_out(GLOB_PHYS_ADDR_BITS - 1 downto 0);
          if r.msg = DMA_TO_DEV or r.msg = REQ_DMA_READ then
            v.state := dma_receive_rdlength;
          elsif r.msg = DMA_FROM_DEV then
            -- Note: in order to support ESP instances withouth DDR controller,
            -- non coherent DMA is sending the transaction length to work with FPGA-based
            -- memory proxy (mem2ext) for which the lenght of the payload must be known
            -- when the transaction begins. The external link can only handle
            -- non-coherent DMA and LLC requests (i.e. it assumes LLC is present),
            -- therefore coherent DMA requests do not send the transaction
            -- lenght to reduce the NoC packet overhead.
            v.state := dma_receive_wrlength;
          else
            -- Coherent writes do not send length. Stop when tail appears.
            v.state := dma_wr_request;
          end if;
        end if;

      when dma_receive_wrlength =>
        if dma_rcv_empty = '0' then
          -- Ignore lenght. DMA Length is only required for the
          -- mem2ext proxy (see commet above)
          dma_rcv_rdreq <= '1';
          v.state := dma_wr_request;
        end if;

      when dma_receive_rdlength =>
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
            -- Owning already address
            -- Single word transfer: no request
            -- Send header
            v.hburst := HBURST_SINGLE;
            v.htrans := HTRANS_NONSEQ;
            if l2_cache_en = 0 then
              v.state := send_header;
            else
              v.state := send_address;
            end if;
          elsif ((v.grant = '1') and (v.ready = '1')) then
            -- Owning already address
            -- More than one element burst
            -- Send header
            v.hbusreq := '1';
            v.hburst  := HBURST_INCR;
            v.htrans  := HTRANS_NONSEQ;
            if l2_cache_en = 0 then
              v.state := send_header;
            else
              v.state := send_address;
            end if;
          else
            -- Need to get ownership of the bus
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
        v.hsize := target_dma_word_hsize;
        if dma_snd_atleast_4slots = '1' then
          if ((r.count = 1) and (v.grant = '1')
              and (v.ready = '1')) then
            -- Owning already address
            -- Single word transfer: no request
            -- Send header
            v.hburst := HBURST_SINGLE;
            v.htrans := HTRANS_NONSEQ;
            v.state  := dma_send_header;
          elsif ((v.grant = '1') and (v.ready = '1')) then
            -- Owning already address
            -- More than one element burst
            -- Send header
            v.hbusreq := '1';
            v.hburst  := HBURST_INCR;
            v.htrans  := HTRANS_NONSEQ;
            v.state   := dma_send_header;
          else
            -- Need to get ownership of the bus
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
            -- Data bus granted
            -- Send header
            narrow_coherence_rsp_snd_data_in <= header_reg;
            narrow_coherence_rsp_snd_wrreq   <= '1';
            -- Updated address and control bus
            if r.hsize = HSIZE_WORD then
              -- EDCL always requests 32-bits bursts
              v.addr := r.addr + 4;
            else
              -- Processors will only request bursts for hsize euqual to data width
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
          narrow_coherence_rsp_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
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
          -- Data bus granted
          -- Send header
          dma_snd_data_in <= header_reg;
          dma_snd_wrreq   <= '1';
          -- Accelerators work with data widht equal to the selected processor,
          -- however, non-coherent Ethernet DMA makes 32-bits bursts
          v.addr          := r.addr + target_dma_incr;
          v.count         := r.count - 1;
          if r.count = 1 then
            v.hbusreq := '0';
            v.htrans  := HTRANS_IDLE;
          else
            if r.count = 2 then
              v.hbusreq := '0';
            end if;
            v.htrans := HTRANS_SEQ;
          end if;
          v.state := dma_send_data;
        end if;

      when send_address =>
        if v.ready = '1' then
          narrow_coherence_rsp_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_BODY;
          narrow_coherence_rsp_snd_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= r.addr;
          narrow_coherence_rsp_snd_wrreq   <= '1';
          v.count                   := r.count - 1;
          -- L2 cache alwasy uses hsize equal to data widht. So use deafult incr
          v.addr                    := r.addr + default_incr;
          v.state                   := send_data;
          v.htrans                  := HTRANS_SEQ;
        end if;

      when send_data =>
        if (v.ready = '1') then
          if narrow_coherence_rsp_snd_full = '1' then
            v.htrans := HTRANS_BUSY;
          else
            -- Send data to noc
            narrow_coherence_rsp_snd_wrreq   <= '1';
            narrow_coherence_rsp_snd_data_in <= PREAMBLE_BODY & fix_endian(ahbmi.hrdata);
            -- Update address and control bus
            if r.hsize = HSIZE_WORD then
              -- EDCL burst
              v.addr := r.addr + 4;
            else
              -- Processor burst
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
              narrow_coherence_rsp_snd_data_in <= PREAMBLE_TAIL & fix_endian(ahbmi.hrdata);
              v.state                   := receive_header;
            else
              v.htrans := HTRANS_SEQ;
            end if;
          end if;
        end if;

      when dma_send_data =>
        if (v.ready = '1') then
          -- Send data to noc
          dma_snd_wrreq   <= '1';
          dma_snd_data_in <= PREAMBLE_BODY & fix_endian(ahbmi.hrdata);
          -- Accelerators work with data widht equal to the selected processor,
          -- however, non-coherent Ethernet DMA makes 32-bits bursts
          v.addr          := r.addr + target_dma_incr;
          v.count         := r.count - 1;
          if r.count = 2 then
            v.hbusreq := '0';
            v.htrans  := HTRANS_SEQ;
          elsif r.count = 1 then
            v.hbusreq := '0';
            v.htrans  := HTRANS_IDLE;
          elsif r.count = 0 then
            dma_snd_data_in <= PREAMBLE_TAIL & fix_endian(ahbmi.hrdata);
            v.state         := receive_header;
          else
            if dma_snd_exactly_3slots = '1' then
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
          dma_snd_data_in <= PREAMBLE_BODY & fix_endian(ahbmi.hrdata);
          v.count         := r.count - 1;
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
            -- Owning already address bus
            -- Single word transfer: no request
            -- Prefetch
            narrow_coherence_req_rdreq <= '1';
            v.flit              := narrow_coherence_req_data_out;
            v.hburst            := HBURST_SINGLE;
            v.htrans            := HTRANS_NONSEQ;
            v.hwrite            := '1';
            v.state             := write_last_data;
          elsif ((v.grant = '1') and (v.ready = '1')) then
            -- Owning already address bus
            -- More than one element burst
            -- Prefetch
            narrow_coherence_req_rdreq <= '1';
            v.flit              := narrow_coherence_req_data_out;
            v.hbusreq           := '1';
            v.hburst            := HBURST_INCR;
            v.htrans            := HTRANS_NONSEQ;
            v.hwrite            := '1';
            v.state             := write_data;
          else
            -- Need to get ownership of the bus
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
        v.hsize := target_dma_word_hsize;
        if dma_rcv_empty = '0' then
          if ((dma_preamble = PREAMBLE_TAIL) and
              (v.grant = '1') and (v.ready = '1')) then
            -- Owning already address bus
            -- Single word transfer: no request
            -- Prefetch
            dma_rcv_rdreq <= '1';
            v.flit        := dma_rcv_data_out;
            v.hburst      := HBURST_SINGLE;
            v.htrans      := HTRANS_NONSEQ;
            v.hwrite      := '1';
            v.state       := write_last_data;
          elsif ((v.grant = '1') and (v.ready = '1')) then
            -- Owning already address bus
            -- More than one element burst
            -- Prefetch
            dma_rcv_rdreq <= '1';
            v.flit        := dma_rcv_data_out;
            v.hbusreq     := '1';
            v.hburst      := HBURST_INCR;
            v.htrans      := HTRANS_NONSEQ;
            v.hwrite      := '1';
            v.state       := dma_write_data;
          else
            -- Need to get ownership of the bus
            if (dma_preamble = PREAMBLE_TAIL) then
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
          -- Write data to memory
          v.hwdata := r.flit(ARCH_BITS - 1 downto 0);
          -- Update address and control
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
            end if;
            -- Prefetch
            narrow_coherence_req_rdreq <= '1';
            v.flit              := narrow_coherence_req_data_out;
          end if;
        end if;

      when dma_write_data =>
        if (v.ready = '1') then
          -- Write data to memory
          v.hwdata := r.flit(ARCH_BITS - 1 downto 0);
          -- Update address and control
          v.addr   := r.addr + target_dma_incr;
          if dma_rcv_empty = '1' then
            v.htrans := HTRANS_BUSY;
            v.state  := dma_write_busy;
          else
            v.htrans := HTRANS_SEQ;
            if (dma_preamble = PREAMBLE_TAIL) then
              v.hbusreq := '0';
              v.state   := write_last_data;
            end if;
            -- Prefetch
            dma_rcv_rdreq <= '1';
            v.flit        := dma_rcv_data_out;
          end if;
        end if;

      when write_busy =>
        if (v.ready = '1' and narrow_coherence_req_empty = '0') then
          v.htrans := HTRANS_SEQ;
          if (preamble = PREAMBLE_TAIL) then
            v.hbusreq := '0';
            v.state   := write_last_data;
          else
            v.state := write_data;
          end if;
          -- Prefetch
          narrow_coherence_req_rdreq <= '1';
          v.flit              := narrow_coherence_req_data_out;
        end if;

      when dma_write_busy =>
        if (v.ready = '1' and dma_rcv_empty = '0') then
          v.htrans := HTRANS_SEQ;
          if (dma_preamble = PREAMBLE_TAIL) then
            v.hbusreq := '0';
            v.state   := write_last_data;
          else
            v.state := dma_write_data;
          end if;
          -- Prefetch
          dma_rcv_rdreq <= '1';
          v.flit        := dma_rcv_data_out;
        end if;

      when write_last_data =>
        if (v.ready = '1') then
          v.hwdata := r.flit(ARCH_BITS - 1 downto 0);
          v.htrans := HTRANS_IDLE;
          v.hwrite := '0';
          v.state  := write_complete;
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
    -- Fix little vs. big endian ... !
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

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      r <= reg_none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      r <= rin;
    end if;
  end process;

  -- SerDes for narrow NoC
  serdes_gen: if narrow_noc /= 0 and ARCH_BITS /= 32 generate

    serdes_beh: process (serdes_current, r, ahbmi, rsp_reg, req_reg,
                         narrow_coherence_req_rdreq,
                         coherence_req_data_out,
                         coherence_req_empty,
                         narrow_coherence_rsp_snd_wrreq,
                         narrow_coherence_rsp_snd_data_in,
                         coherence_rsp_snd_full)
    begin  -- process serdes_beh

      serdes_next <= serdes_current;
      sample_rsp <= '0';
      sample_req <= '0';

      -- passthru by default
      coherence_req_rdreq           <= narrow_coherence_req_rdreq;
      narrow_coherence_req_data_out <= coherence_req_data_out;
      narrow_coherence_req_empty    <= coherence_req_empty;
      coherence_rsp_snd_wrreq       <= narrow_coherence_rsp_snd_wrreq;
      coherence_rsp_snd_data_in     <= narrow_coherence_rsp_snd_data_in;
      narrow_coherence_rsp_snd_full <= coherence_rsp_snd_full;

      case serdes_current is

        when passthru =>
          if r.state = send_data and r.hsize = HSIZE_DWORD and ahbmi.hready = '1' and coherence_rsp_snd_full = '0'then
            sample_rsp <= '1';
            coherence_rsp_snd_wrreq <= '1';
            coherence_rsp_snd_data_in <=
              PREAMBLE_BODY &
              narrow_coherence_rsp_snd_data_in(31 downto 0) &
              narrow_coherence_rsp_snd_data_in(31 downto 0);
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
          narrow_coherence_rsp_snd_full <= '1';
          coherence_rsp_snd_data_in <=
            rsp_reg(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) &
            rsp_reg(ARCH_BITS - 1 downto ARCH_BITS - 32) & rsp_reg(ARCH_BITS - 1 downto ARCH_BITS - 32);
          if coherence_rsp_snd_full = '0' then
            coherence_rsp_snd_wrreq <= '1';
            serdes_next <= passthru;
          else
            coherence_rsp_snd_wrreq <= '0';
            serdes_next <= rsp_msb;
          end if;

        when req_msb =>
          narrow_coherence_req_data_out(NOC_FLIT_SIZE - 1 downto 64) <= coherence_req_data_out(NOC_FLIT_SIZE - 1 downto 64);
          narrow_coherence_req_data_out(ARCH_BITS - 1 downto ARCH_BITS - 32) <= coherence_req_data_out(31 downto 0);
          narrow_coherence_req_data_out(31 downto 0) <= req_reg(31 downto 0);
          if coherence_req_empty = '0' and narrow_coherence_req_rdreq = '1'  then
            serdes_next <= passthru;
          end if;

        when others =>
          serdes_next <= passthru;

      end case;

    end process serdes_beh;

    -- Update FSM state
    process (clk, rst)
    begin  -- process
      if rst = '0' then                   -- asynchronous reset (active low)
        serdes_current <= passthru;
        rsp_reg <= (others => '0');
        req_reg <= (others => '0');
      elsif clk'event and clk = '1' then  -- rising clock edge
        serdes_current <= serdes_next;
        if sample_rsp = '1' then
          rsp_reg <= narrow_coherence_rsp_snd_data_in;
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
