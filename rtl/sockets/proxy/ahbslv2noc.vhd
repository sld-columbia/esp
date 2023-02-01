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

entity ahbslv2noc is
  generic (
    tech             : integer;
    hindex           : std_logic_vector(0 to NAHBSLV - 1);
    hconfig          : ahb_slv_config_vector;
    mem_hindex       : integer range -1 to NAHBSLV - 1;
    mem_num          : integer;
    mem_info         : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1);
    slv_y            : local_yx;
    slv_x            : local_yx;
    retarget_for_dma : integer range 0 to 1 := 0;
    dma_length       : integer := 4);
  port (
    rst                        : in  std_ulogic;
    clk                        : in  std_ulogic;
    local_y                    : in  local_yx;
    local_x                    : in  local_yx;
    ahbsi                      : in  ahb_slv_in_type;
    ahbso                      : out ahb_slv_out_vector;
    dma_selected               : in  std_ulogic;
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
    remote_ahbs_rcv_empty      : in  std_ulogic);
end ahbslv2noc;

architecture rtl of ahbslv2noc is

  type ahbs_fsm is (idle, request_header, request_address,
                    request_data, reply_header, reply_data,
                    request_length);
  signal ahbs_state, ahbs_next : ahbs_fsm;

  signal header : misc_noc_flit_type;
  signal payload_address : misc_noc_flit_type;
  signal dst_is_mem : std_ulogic;
  signal header_reg : misc_noc_flit_type;
  signal payload_address_reg : misc_noc_flit_type;
  signal payload_length_reg : misc_noc_flit_type;
  signal dst_is_mem_reg : std_ulogic;
  signal sample_flits : std_ulogic;

  signal hwrite_reg : std_ulogic;
  signal hsel_reg : std_logic_vector(0 to NAHBSLV - 1);

  signal load_transaction_active : std_ulogic;
  signal load_start, load_done : std_ulogic;

  constant zero_ahb_flags : std_logic_vector(0 to NAHBSLV - 1) := (others => '0');

  -- attribute mark_debug : string;
  -- attribute mark_debug of dma_selected               : signal is "true";
  -- attribute mark_debug of coherence_req_wrreq        : signal is "true";
  -- attribute mark_debug of coherence_req_data_in      : signal is "true";
  -- attribute mark_debug of coherence_req_full         : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_rdreq    : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_data_out : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_empty    : signal is "true";
  -- attribute mark_debug of remote_ahbs_snd_wrreq      : signal is "true";
  -- attribute mark_debug of remote_ahbs_snd_data_in    : signal is "true";
  -- attribute mark_debug of remote_ahbs_snd_full       : signal is "true";
  -- attribute mark_debug of remote_ahbs_rcv_rdreq      : signal is "true";
  -- attribute mark_debug of remote_ahbs_rcv_data_out   : signal is "true";
  -- attribute mark_debug of remote_ahbs_rcv_empty      : signal is "true";
  -- attribute mark_debug of load_transaction_active    : signal is "true";
  -- attribute mark_debug of ahbs_state                 : signal is "true";
  -- attribute mark_debug of load_start                 : signal is "true";
  -- attribute mark_debug of load_done                  : signal is "true";

begin  -- rtl

  -----------------------------------------------------------------------------
  -- AHB handling
  -----------------------------------------------------------------------------

  make_packet: process (ahbsi, dma_selected, local_y, local_x)
    variable msg_type : noc_msg_type;
    variable header_v : misc_noc_flit_type;
    variable reserved : reserved_field_type;
    variable mem_x, mem_y : local_yx;
    variable snd_to_mem : std_ulogic;
    variable adj_mem_hindex : integer range 0 to NAHBSLV - 1;
  begin  -- process make_packet
    -- Get routing info
    mem_x := mem_info(0).x;
    mem_y := mem_info(0).y;
    if mem_num > 1 then
      for i in 0 to mem_num - 1 loop
        -- Need to match which memory split is selected
        if ((ahbsi.haddr(31 downto 20) xor conv_std_logic_vector(mem_info(i).haddr, 12))
            and conv_std_logic_vector(mem_info(i).hmask, 12)) = X"000" then
          mem_x := mem_info(i).x;
          mem_y := mem_info(i).y;
        end if;
      end loop;  -- i
    end if;

    -- Determine whether memory is selected
    if mem_hindex = -1 then
      adj_mem_hindex := 0;
    else
      adj_mem_hindex := mem_hindex;
    end if;

    if retarget_for_dma = 1 then
      snd_to_mem := dma_selected;
    elsif mem_hindex = -1 then
      snd_to_mem := '1';
    else
      if ahbsi.hsel(adj_mem_hindex) = '1' and mem_num /= 0 then
        snd_to_mem := '1';
      else
        snd_to_mem := '0';
        mem_x := slv_x;
        mem_y := slv_y;
      end if;
    end if;
    dst_is_mem <= snd_to_mem;


    -- Set message type
    if ahbsi.hwrite = '1' then
      if snd_to_mem = '1' then
        -- Send to Memory
        if retarget_for_dma = 1 then
          msg_type := REQ_DMA_WRITE;
        elsif ahbsi.hsize = HSIZE_BYTE then
          msg_type := REQ_GETM_B;
        elsif ahbsi.hsize = HSIZE_HWORD then
          msg_type := REQ_GETM_HW;
        else
          msg_type := REQ_GETM_W;
        end if;
      else
        -- Send to remote slave uncached
        msg_type := AHB_WR;
      end if;
      -- Address flit is followed by data flits
      payload_address(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_BODY;
    else
      if snd_to_mem = '1' then
        -- Send to Memory
        if retarget_for_dma = 1 then
          msg_type := REQ_DMA_READ;
        elsif ahbsi.hsize = HSIZE_BYTE then
          msg_type := REQ_GETS_B;
        elsif ahbsi.hsize = HSIZE_HWORD then
          msg_type := REQ_GETS_HW;
        else
          msg_type := REQ_GETS_W;
        end if;
      else
        -- Send to remote slave uncached
        msg_type := AHB_RD;
      end if;
      -- Address flit is the last flit; Lenght is assumed cacheline for memory
      -- accesses and one word for remote slave accesses, unless the
      -- transaction is retargeted for coherent DMA. In this case we must add
      -- the read length.
      if retarget_for_dma /= 0 and dma_selected = '1' then
        payload_address(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_BODY;
      else
        payload_address(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
      end if;
    end if;

    -- Set address flit
    payload_address(MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) <= ahbsi.haddr;

    -- Create header flit
    reserved := (others => '0');
    reserved(3 downto 0) := ahbsi.hprot;
    header_v := (others => '0');
    header_v := create_header(MISC_NOC_FLIT_SIZE, local_y, local_x, mem_y, mem_x, msg_type, reserved)(MISC_NOC_FLIT_SIZE - 1 downto 0);
    header <= header_v;

  end process make_packet;

  -- Set length flit
  payload_length_reg(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
  payload_length_reg(MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) <= conv_std_logic_vector(dma_length, MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH);

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      header_reg <= (others => '0');
      payload_address_reg <= (others => '0');
      dst_is_mem_reg <= '0';
      hwrite_reg <= '0';
      hsel_reg <= (others => '0');
      load_transaction_active <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_flits = '1' then
        header_reg <= header;
        payload_address_reg <= payload_address;
        dst_is_mem_reg <= dst_is_mem;
        hwrite_reg <= ahbsi.hwrite;
        hsel_reg <= ahbsi.hsel;
      end if;
      if load_start = '1' then
        load_transaction_active <= '1';
      elsif load_done = '1' then
        load_transaction_active <= '0';
      end if;
    end if;
  end process;


  ahb_roundtrip: process (ahbs_state, ahbsi, load_transaction_active, dst_is_mem_reg,
                          coherence_req_full,
                          coherence_rsp_rcv_data_out, coherence_rsp_rcv_empty,
                          remote_ahbs_snd_full,
                          remote_ahbs_rcv_data_out, remote_ahbs_rcv_empty,
                          header_reg, payload_address_reg, payload_length_reg,
                          hwrite_reg, hsel_reg)
    variable payload_data : misc_noc_flit_type;
    variable sequential : std_ulogic;
    variable selected : std_ulogic;
    variable rsp_preamble : noc_preamble_type;
    variable coherence_rsp_rcv_preamble : noc_preamble_type;
    variable hrdata : std_logic_vector(AHBDW-1 downto 0);
    variable hready : std_ulogic;
  begin  -- process ahb_roundtrip
    ahbs_next <= ahbs_state;
    sample_flits <= '0';
    coherence_req_data_in <= (others => '0');
    coherence_req_wrreq <= '0';
    coherence_rsp_rcv_rdreq <= '0';
    remote_ahbs_snd_data_in <= (others => '0');
    remote_ahbs_snd_wrreq <= '0';
    remote_ahbs_rcv_rdreq <= '0';

    selected := '0';
    if (ahbsi.hsel and hindex) /= zero_ahb_flags then
      selected := '1';
    end if;

    if (ahbsi.htrans /= HTRANS_SEQ or selected = '0') then
      payload_data(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
      sequential := '0';
    else
      payload_data(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
      sequential := '1';
    end if;
    payload_data(31 downto 0) := ahbreadword(ahbsi.hwdata);

    if dst_is_mem_reg = '1' then
      rsp_preamble := get_preamble(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);
    else
      rsp_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & remote_ahbs_rcv_data_out);
    end if;
    coherence_rsp_rcv_preamble := get_preamble(NOC_FLIT_SIZE, coherence_rsp_rcv_data_out);

    -- Default ahbso assignment
    for i in 0 to NAHBSLV - 1 loop
      ahbso(i).hready <= '1';
      ahbso(i).hrdata <= (others => '0');
      ahbso(i).hresp <= HRESP_OKAY;
      ahbso(i).hsplit <= (others => '0');
      ahbso(i).hirq <= (others => '0');
      if hindex(i) /= '0' then
        ahbso(i).hconfig <= hconfig(i);
        ahbso(i).hindex <= i;
      else
        ahbso(i).hconfig <= hconfig_none;
        ahbso(i).hindex <= 0;
      end if;
    end loop;

    load_start <= '0';
    load_done <= '0';

    hready := '1';
    hrdata := (others => '0');

    case ahbs_state is
      when idle =>
        if load_transaction_active = '1' then
          if coherence_rsp_rcv_empty = '0' then
            coherence_rsp_rcv_rdreq <= '1';
            if coherence_rsp_rcv_preamble = PREAMBLE_TAIL then
              load_done <= '1';
            end if;
          end if;
        end if;
        if (selected = '1' and ahbsi.hready = '1' and ahbsi.htrans = HTRANS_NONSEQ) then
          sample_flits <= '1';
          ahbs_next <= request_header;
        end if;

      when request_header =>
        hready := '0';
        if load_transaction_active = '1' then
          if coherence_rsp_rcv_empty = '0' then
            coherence_rsp_rcv_rdreq <= '1';
            if coherence_rsp_rcv_preamble = PREAMBLE_TAIL then
              load_done <= '1';
            end if;
          end if;
        elsif dst_is_mem_reg = '1' then
          if coherence_req_full = '0' then
            coherence_req_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - MISC_NOC_FLIT_SIZE + NEXT_ROUTING_WIDTH) <=
              header_reg(MISC_NOC_FLIT_SIZE - 1 downto NEXT_ROUTING_WIDTH);
            coherence_req_data_in(NEXT_ROUTING_WIDTH - 1 downto 0) <=
              header_reg(NEXT_ROUTING_WIDTH - 1 downto 0);
            coherence_req_wrreq <= '1';
            ahbs_next <= request_address;
          end if;
        else
          if remote_ahbs_snd_full = '0' then
            remote_ahbs_snd_data_in <= header_reg;
            remote_ahbs_snd_wrreq <= '1';
            ahbs_next <= request_address;
          end if;
        end if;

      when request_address =>
        hready := '0';
        if dst_is_mem_reg = '1' then
          if coherence_req_full = '0' then
            coherence_req_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <=
              payload_address_reg(MISC_NOC_FLIT_SIZE - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH);
            coherence_req_data_in(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0) <=
              payload_address_reg(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);
            coherence_req_wrreq <= '1';
            if hwrite_reg = '1' then
              ahbs_next <= request_data;
            else
              if retarget_for_dma = 1 then
                ahbs_next <= request_length;
              else
                ahbs_next <= reply_header;
              end if;
            end if;
          end if;
        else
          if remote_ahbs_snd_full = '0' then
            remote_ahbs_snd_data_in <= payload_address_reg;
            remote_ahbs_snd_wrreq <= '1';
            if hwrite_reg = '1' then
              ahbs_next <= request_data;
            else
              ahbs_next <= reply_header;
            end if;
          end if;
        end if;

      when request_length =>
        hready := '0';
        if coherence_req_full = '0' then
          coherence_req_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <=
            payload_length_reg(MISC_NOC_FLIT_SIZE - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH);
          coherence_req_data_in(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0) <=
            payload_length_reg(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);
          coherence_req_wrreq <= '1';
          ahbs_next <= reply_header;
        end if;

      when request_data =>
        hready := '0';
        if dst_is_mem_reg = '1' then
          if coherence_req_full = '0' then
            hready := '1';
            coherence_req_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) <=
              payload_data(MISC_NOC_FLIT_SIZE - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH);
            coherence_req_data_in(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0) <=
              payload_data(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);
            coherence_req_wrreq <= '1';
            if selected = '0' or ahbsi.htrans = HTRANS_IDLE then
              ahbs_next <= idle;
            elsif sequential = '0' then
              sample_flits <= '1';
              ahbs_next <= request_header;
            end if;
          end if;
        else
          if remote_ahbs_snd_full = '0' then
            hready := '1';
            if ahbsi.htrans /= HTRANS_BUSY then
              remote_ahbs_snd_data_in <= payload_data;
              remote_ahbs_snd_wrreq <= '1';
              if selected = '0' or ahbsi.htrans = HTRANS_IDLE then
                ahbs_next <= idle;
              elsif sequential = '0' then
                sample_flits <= '1';
                ahbs_next <= request_header;
              end if;
            end if;
          end if;
        end if;

      when reply_header =>
        hready := '0';
        if dst_is_mem_reg = '1' then
          if coherence_rsp_rcv_empty = '0' then
            load_start <= '1';
            coherence_rsp_rcv_rdreq <= '1';
            ahbs_next <= reply_data;
          end if;
        else
          if remote_ahbs_rcv_empty = '0' then
            remote_ahbs_rcv_rdreq <= '1';
            ahbs_next <= reply_data;
          end if;
        end if;

      when reply_data =>
        hready := '0';
        if coherence_rsp_rcv_empty = '0' then
          if coherence_rsp_rcv_preamble = PREAMBLE_TAIL then
            load_done <= '1';
          end if;
          coherence_rsp_rcv_rdreq <= '1';
          hrdata := ahbdrivedata(coherence_rsp_rcv_data_out(31 downto 0));
          hready := '1';
        elsif remote_ahbs_rcv_empty = '0' then
          remote_ahbs_rcv_rdreq <= '1';
          hrdata := ahbdrivedata(remote_ahbs_rcv_data_out(31 downto 0));
          hready := '1';
        end if;
        if coherence_rsp_rcv_empty = '0' or remote_ahbs_rcv_empty = '0' then
          if selected = '0' or ahbsi.htrans = HTRANS_IDLE then
            ahbs_next <= idle;
          elsif sequential = '0' or rsp_preamble = PREAMBLE_TAIL then
            sample_flits <= '1';
            ahbs_next <= request_header;
          end if;
        end if;

      when others =>
        hready := '0';
        ahbs_next <= idle;

    end case;

    for i in 0 to NAHBSLV - 1 loop
      if hsel_reg(i) = '1' then
        ahbso(i).hrdata <= hrdata;
        ahbso(i).hready <= hready;
      end if;
    end loop;  -- i

  end process ahb_roundtrip;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      ahbs_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      ahbs_state <= ahbs_next;
    end if;
  end process;

end rtl;
