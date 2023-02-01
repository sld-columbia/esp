-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
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
    tech             : integer;
    nmst             : integer;
    retarget_for_dma : integer range 0 to 1 := 0;
    mem_axi_port     : integer range -1 to NAHBSLV - 1;
    mem_num          : integer;
    mem_info         : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1);
    slv_y            : local_yx;
    slv_x            : local_yx);
  port (
    rst                        : in  std_ulogic;
    clk                        : in  std_ulogic;
    local_y                    : in  local_yx;
    local_x                    : in  local_yx;
    mosi                       : in  axi_mosi_vector(0 to nmst - 1);
    somi                       : out axi_somi_vector(0 to nmst - 1);
    -- tile->NoC1
    coherence_req_wrreq        : out std_ulogic;
    coherence_req_data_in      : out noc_flit_type;
    coherence_req_full         : in  std_ulogic;
    -- Noc3->tile
    coherence_rsp_rcv_rdreq    : out std_ulogic;
    coherence_rsp_rcv_data_out : in  noc_flit_type;
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

  type axi_fsm is (idle, request_header, request_address,
                   request_length, request_data, reply_header,
                   reply_data, request_data_lsb, request_data_msb,
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
    hsize_msb              : std_ulogic;  -- distinguish HSIZE_WORD from HSIZE_DWORD
    dst_is_mem             : std_ulogic;
    -- NoC flits
    header                 : noc_flit_type;
    header_narrow          : misc_noc_flit_type;
    payload_address        : noc_flit_type;
    payload_address_narrow : misc_noc_flit_type;
    payload_length         : noc_flit_type;
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


  signal transaction, transaction_reg : transaction_type;
  signal current_state, next_state    : axi_fsm;
  signal selected                     : std_ulogic;
  signal sample_flits                 : std_ulogic;

  signal remote_ahbs_rcv_data_out_hold  : misc_noc_flit_type;
  signal sample_and_hold : std_ulogic;

  -- attribute mark_debug : string;

  -- attribute mark_debug of coherence_req_wrreq : signal is "true";
  -- attribute mark_debug of coherence_req_data_in : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_rdreq : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_data_out : signal is "true";
  -- attribute mark_debug of remote_ahbs_snd_wrreq : signal is "true";
  -- attribute mark_debug of remote_ahbs_snd_data_in : signal is "true";
  -- attribute mark_debug of remote_ahbs_rcv_rdreq : signal is "true";
  -- attribute mark_debug of remote_ahbs_rcv_data_out : signal is "true";
  -- attribute mark_debug of transaction_reg : signal is "true";
  -- attribute mark_debug of current_state : signal is "true";
  -- attribute mark_debug of selected : signal is "true";
  -- attribute mark_debug of sample_flits : signal is "true";
  -- attribute mark_debug of sample_and_hold : signal is "true";
  -- attribute mark_debug of mosi : signal is "true";
  -- attribute mark_debug of somi : signal is "true";

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
    tran.payload_address(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    tran.payload_address(GLOB_PHYS_ADDR_BITS - 1 downto 0) := tran.addr;

    tran.payload_address_narrow(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    tran.payload_address_narrow(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0) := tran.addr(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);

    -- Set length
    if tran.write = '1' then
      tran.payload_length(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    else
      tran.payload_length(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    end if;
    tran.payload_length(8 downto 0) := tran.len;
    -- (read transaction only)
    tran.payload_length_narrow(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    tran.payload_length_narrow(8 downto 0) := tran.len;

    -- Create header flit
    tran.reserved             := (others => '0');
    tran.reserved(3)          := tran.hsize_msb;
    tran.reserved(2 downto 0) := tran.prot;

    tran.header := create_header(NOC_FLIT_SIZE, local_y, local_x, tran.mem_y, tran.mem_x, tran.msg_type, tran.reserved);
    tran.header_narrow := create_header(MISC_NOC_FLIT_SIZE, local_y, local_x, tran.mem_y, tran.mem_x, tran.msg_type, tran.reserved)(MISC_NOC_FLIT_SIZE - 1 downto 0);

    -- Write signal
    transaction <= tran;
  end process make_packet;



  -- AXI2NOC
  axi_roundtrip: process (transaction_reg, current_state, selected, mosi,
                          coherence_req_full,
                          coherence_rsp_rcv_data_out, coherence_rsp_rcv_empty,
                          remote_ahbs_snd_full,
                          remote_ahbs_rcv_data_out, remote_ahbs_rcv_empty,
                          remote_ahbs_rcv_data_out_hold)
    variable wdata                   : std_logic_vector(AHBDW - 1 downto 0);
    variable payload_data            : noc_flit_type;
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

    -- Response data flit (AXI Read)
    if transaction_reg.dst_is_mem = '1' then
      rsp_preamble := get_preamble(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);
      for i in 0 to nmst - 1 loop
        somi(i).r.data <= (coherence_rsp_rcv_data_out(AHBDW - 1 downto 0));
      end loop;
    else
      rsp_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & remote_ahbs_rcv_data_out);
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
        else -- HSIZE_BYTE
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

    -- Data flit (AXI Write)
    if transaction_reg.size = HSIZE_DWORD then
      wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data);
    elsif transaction_reg.size = HSIZE_WORD then
      if AHBDW = 64 then
        case transaction_reg.addr(2) is
          when '0'    => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(31 downto 0));
          when others => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(ARCH_BITS - 1 downto ARCH_BITS - 32));
        end case;
      else
        wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data);
      end if;
    elsif transaction_reg.size = HSIZE_HWORD then
      if AHBDW = 64 then
        case transaction_reg.addr(2 downto 1) is
          when "00"   => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(15 downto 0));
          when "01"   => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(31 downto 16));
          when "10"   => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(ARCH_BITS - 17 downto ARCH_BITS - 32));
          when others => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(ARCH_BITS - 1 downto ARCH_BITS - 16));
        end case;
      else
        case transaction_reg.addr(1) is
          when '0'    => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(15 downto 0));
          when others => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(31 downto 16));
        end case;
      end if;
    else -- HSIZE_BYTE
      if AHBDW = 64 then
        case transaction_reg.addr(2 downto 0) is
          when "000"  => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(7 downto 0));
          when "001"  => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(15 downto 8));
          when "010"  => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(23 downto 16));
          when "011"  => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(31 downto 24));
          when "100"  => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(ARCH_BITS - 25 downto ARCH_BITS - 32));
          when "101"  => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(ARCH_BITS - 17 downto ARCH_BITS - 24));
          when "110"  => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(ARCH_BITS -  9 downto ARCH_BITS - 16));
          when others => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(ARCH_BITS -  1 downto ARCH_BITS -  8));
        end case;
      else
        case transaction_reg.addr(1 downto 0) is
          when "00"   => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(7 downto 0));
          when "01"   => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(15 downto 8));
          when "10"   => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(23 downto 16));
          when others => wdata := ahbdrivedata(mosi(transaction_reg.xindex).w.data(31 downto 24));
        end case;
      end if;
    end if;

    payload_data            := (others => '0');
    payload_data_narrow_lsb := (others => '0');
    payload_data_narrow_msb := (others => '0');
    payload_data_narrow_lsb(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
    if (mosi(transaction_reg.xindex).w.last = '1') then
      payload_data(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH)                      := PREAMBLE_TAIL;
      payload_data_narrow_msb(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
      last                                                                                     := '1';
    else
      payload_data(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH)                      := PREAMBLE_BODY;
      payload_data_narrow_msb(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
      last                                                                                     := '0';
    end if;
    payload_data(AHBDW - 1 downto 0)                                      := wdata;
    -- TODO: this only works on a 64-bit AXI bus with 32-bit AHB remote slaves
    payload_data_narrow_lsb(31 downto 0) := wdata(31 downto 0);
    payload_data_narrow_msb(31 downto 0) := wdata(ARCH_BITS - 1 downto ARCH_BITS - 32);

    -- Temporary AXI flags
    slv_ready  := '0';
    slv_valid  := '0';
    mst_ready  := mosi(transaction_reg.xindex).r.ready;
    mst_valid  := mosi(transaction_reg.xindex).w.valid;
    mst_bready := mosi(transaction_reg.xindex).b.ready;


    -- FSM
    case current_state is
      when idle =>
        if selected = '1' then
          sample_flits <= '1';
          next_state <= request_header;
        end if;

      when request_header =>
        if transaction_reg.dst_is_mem = '1' then
          if coherence_req_full = '0' then
            coherence_req_data_in <= transaction_reg.header;
            coherence_req_wrreq   <= '1';
            next_state         <= request_address;
            -- Control signals are sampled
            if transaction_reg.write = '1' then
              somi(transaction_reg.xindex).aw.ready <= '1';
            else
              somi(transaction_reg.xindex).ar.ready <= '1';
            end if;
          end if;
        else
          if remote_ahbs_snd_full = '0' then
            remote_ahbs_snd_data_in <= transaction_reg.header_narrow;
            remote_ahbs_snd_wrreq   <= '1';
            next_state           <= request_address;
            -- Control signals are sampled
            if transaction_reg.write = '1' then
              somi(transaction_reg.xindex).aw.ready <= '1';
            else
              somi(transaction_reg.xindex).ar.ready <= '1';
            end if;
          end if;
        end if;

      when request_address =>
        if transaction_reg.dst_is_mem = '1' then
          if coherence_req_full = '0' then
            coherence_req_data_in <= transaction_reg.payload_address;
            coherence_req_wrreq <= '1';
            if transaction_reg.write = '1' and transaction_reg.msg_type /= DMA_FROM_DEV then
              next_state <= request_data;
            else
              next_state <= request_length;
            end if;
          end if;
        else
          if remote_ahbs_snd_full = '0' then
            remote_ahbs_snd_data_in <= transaction_reg.payload_address_narrow;
            remote_ahbs_snd_wrreq <= '1';
            if transaction_reg.write = '1' then
              if transaction_reg.size = HSIZE_DWORD then
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
        if transaction_reg.dst_is_mem = '1' then
          if coherence_req_full = '0' then
            coherence_req_data_in <= transaction_reg.payload_length;
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
            remote_ahbs_snd_data_in <= transaction_reg.payload_length_narrow;
            remote_ahbs_snd_wrreq <= '1';
            -- Ready transaction only
            next_state <= reply_header;
          end if;
        end if;

      when request_data =>
        if transaction_reg.dst_is_mem = '1' then
          if coherence_req_full = '0' and mst_valid = '1' then
            slv_ready := '1';
            coherence_req_data_in <= payload_data;
            coherence_req_wrreq <= '1';
            if last = '1' then
              next_state <= request_data_ack;
            end if;
          end if;
        else
          if remote_ahbs_snd_full = '0' and mst_valid = '1' then
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
        if remote_ahbs_snd_full = '0' and mst_valid = '1' then
          remote_ahbs_snd_data_in <= payload_data_narrow_lsb;
          remote_ahbs_snd_wrreq <= '1';
          next_state <= request_data_msb;
        end if;

      when request_data_msb =>
        if remote_ahbs_snd_full = '0' then
          slv_ready := '1';
          remote_ahbs_snd_data_in <= payload_data_narrow_msb;
          remote_ahbs_snd_wrreq <= '1';
          if last = '1' then
            next_state <= request_data_ack;
          else
            next_state <= request_data_lsb;
          end if;
        end if;

      when request_data_ack =>
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
            next_state <= request_header;
          end if;
        end if;

      when reply_header =>
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
                next_state   <= request_header;
                sample_flits <= '1';
              end if;
            end if;
          end if;
        end if;

      when reply_data_lsb =>
        if remote_ahbs_rcv_empty = '0'then
          remote_ahbs_rcv_rdreq <= '1';
          sample_and_hold <= '1';
          next_state <= reply_data_msb;
        end if;

      when reply_data_msb =>
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
                next_state   <= request_header;
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
    if rst = '0' then                   -- asynchronous reset (active low)
      current_state <= idle;
      transaction_reg <= transaction_none;
      remote_ahbs_rcv_data_out_hold <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      current_state <= next_state;
      if sample_flits = '1' then
        transaction_reg <= transaction;
      end if;
      if sample_and_hold = '1' then
        remote_ahbs_rcv_data_out_hold <= remote_ahbs_rcv_data_out;
      end if;
    end if;
  end process;

end rtl;
