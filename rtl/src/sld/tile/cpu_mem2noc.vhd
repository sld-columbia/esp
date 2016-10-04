------------------------------------------------------------------------------
--  This file is part of an extension to the GRLIB VHDL IP library.
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
--
--  GRLIP is a Copyright (C) 2008 - 2013, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity:  cpu_ahbs2noc
-- File:    cpu_ahbs2noc.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description:	Amba 2.0 AHB Slave to Network Interface wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;


entity cpu_ahbs2noc is
  generic (
    tech        : integer := virtex7;
    ncpu        : integer := 4;
    nslaves     : integer := 1;
    hindex      : hindex_vector(0 to NAHBSLV-1);
    local_y     : local_yx;
    local_x     : local_yx;
    mem_num     : integer := 1;
    mem_info    : tile_mem_info_vector;
    destination : integer := 0);        -- 0: mem
                                        -- 1: DSU

  port (
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    ahbsi    : in  ahb_slv_in_type;
    ahbso    : out ahb_slv_out_type;

    -- tile->NoC1
    coherence_req_wrreq                 : out std_ulogic;
    coherence_req_data_in               : out noc_flit_type;
    coherence_req_full                  : in  std_ulogic;
    -- NoC2->tile
    coherence_fwd_inv_rdreq             : out std_ulogic;
    coherence_fwd_inv_data_out          : in  noc_flit_type;
    coherence_fwd_inv_empty             : in  std_ulogic;
    -- NoC2->tile
    coherence_fwd_put_ack_rdreq         : out std_ulogic;
    coherence_fwd_put_ack_data_out      : in  noc_flit_type;
    coherence_fwd_put_ack_empty         : in  std_ulogic;
    -- Noc3->tile
    coherence_rsp_line_rdreq            : out std_ulogic;
    coherence_rsp_line_data_out         : in  noc_flit_type;
    coherence_rsp_line_empty            : in  std_ulogic;
    -- Noc3->tile
    coherence_rsp_inv_ack_rcv_rdreq     : out std_ulogic;
    coherence_rsp_inv_ack_rcv_data_out  : in  noc_flit_type;
    coherence_rsp_inv_ack_rcv_empty     : in  std_ulogic;
    -- tile->NoC3
    coherence_rsp_inv_ack_snd_wrreq     : out std_ulogic;
    coherence_rsp_inv_ack_snd_data_in   : out noc_flit_type;
    coherence_rsp_inv_ack_snd_full      : in  std_ulogic);

end cpu_ahbs2noc;

architecture rtl of cpu_ahbs2noc is

  type ahbs_fsm is (idle, request_header, request_address,
                    request_data, reply_header, reply_data);
  signal ahbs_state, ahbs_next : ahbs_fsm;

  signal header : noc_flit_type;
  signal payload_address : noc_flit_type;
  signal header_reg : noc_flit_type;
  signal payload_address_reg : noc_flit_type;
  signal sample_flits : std_ulogic;

  signal hwrite_reg : std_ulogic;

  signal load_transaction_active : std_ulogic;
  signal load_start, load_done : std_ulogic;
begin  -- rtl

  -- TODO: cache coherency!
  coherence_fwd_inv_rdreq <= '0';
  coherence_fwd_put_ack_rdreq <= '0';
  coherence_rsp_inv_ack_rcv_rdreq <= '0';
  coherence_rsp_inv_ack_snd_wrreq <= '0';
  coherence_rsp_inv_ack_snd_data_in <= (others => '0');

  -----------------------------------------------------------------------------
  -- AHB handling
  -----------------------------------------------------------------------------

  make_packet: process (ahbsi)
    variable msg_type : noc_msg_type;
    variable header_v : noc_flit_type;
    variable reserved : reserved_field_type;
    variable mem_x, mem_y : local_yx;
  begin  -- process make_packet
    mem_x := mem_info(0).x;
    mem_y := mem_info(0).y;
    if mem_num /= 1 then
      for i in 0 to mem_num - 1 loop
        if ((ahbsi.haddr(31 downto 20) xor conv_std_logic_vector(mem_info(i).haddr, 12))
            and conv_std_logic_vector(mem_info(i).hmask, 12)) = X"000" then
          mem_x := mem_info(i).x;
          mem_y := mem_info(i).y;
        end if;
      end loop;  -- i
    end if;

    if destination = 0 then
      -- Send to Memory
      if ahbsi.hsize = HSIZE_BYTE then
        msg_type := REQ_GETS_B;
      elsif ahbsi.hsize = HSIZE_HWORD then
        msg_type := REQ_GETS_HW;
      else
        msg_type := REQ_GETS_W;
      end if;
    else
      -- Send to DSU
      msg_type := AHB_RD;
    end if;
    reserved := (others => '0');
    reserved(3 downto 0) := ahbsi.hprot;
    header_v := (others => '0');

    payload_address(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
    payload_address(NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) <= ahbsi.haddr;

    if ahbsi.hwrite = '1' then
      if destination = 0 then
        -- Send to Memory
        if ahbsi.hsize = HSIZE_BYTE then
          msg_type := REQ_GETM_B;
        elsif ahbsi.hsize = HSIZE_HWORD then
          msg_type := REQ_GETM_HW;
        else
          msg_type := REQ_GETM_W;
        end if;
      else
        -- Send to DSU
        msg_type := AHB_WR;
      end if;
      payload_address(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_BODY;
    end if;
    header_v := create_header(local_y, local_x, mem_y, mem_x, msg_type, reserved);
    header <= header_v;
  end process make_packet;

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      header_reg <= (others => '0');
      payload_address_reg <= (others => '0');
      hwrite_reg <= '0';
      load_transaction_active <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_flits = '1' then
        header_reg <= header;
        payload_address_reg <= payload_address;
        hwrite_reg <= ahbsi.hwrite;
      end if;
      if load_start = '1' then
        load_transaction_active <= '1';
      elsif load_done = '1' then
        load_transaction_active <= '0';
      end if;
    end if;
  end process;


  ahb_roundtrip: process (ahbs_state, ahbsi, load_transaction_active,
                          coherence_req_full,
                          coherence_rsp_line_data_out, coherence_rsp_line_empty,
                          header_reg, payload_address_reg, hwrite_reg)
    variable payload_data : noc_flit_type;
    variable sequential : std_ulogic;
    variable selected : std_ulogic;
    variable rsp_preamble : noc_preamble_type;
  begin  -- process ahb_roundtrip
    ahbs_next <= ahbs_state;
    sample_flits <= '0';
    coherence_req_data_in <= (others => '0');
    coherence_req_wrreq <= '0';
    coherence_rsp_line_rdreq <= '0';

    selected := '0';
    for i in 0 to nslaves-1 loop
      if ahbsi.hsel(hindex(i)) = '1' then
        selected := '1';
      end if;
    end loop;  -- i

    if (ahbsi.htrans /= HTRANS_SEQ or selected = '0') then
      payload_data(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_TAIL;
      sequential := '0';
    else
      payload_data(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_BODY;
      sequential := '1';
    end if;
    payload_data(31 downto 0) := ahbreadword(ahbsi.hwdata);

    rsp_preamble := get_preamble(coherence_rsp_line_data_out);

    -- Default ahbso assignment
    ahbso <= ahbs_none;
    ahbso.hready <= '0';
    ahbso.hresp <= HRESP_OKAY;
    ahbso.hindex <= hindex(0);

    load_start <= '0';
    load_done <= '0';

    case ahbs_state is
      when idle =>
        ahbso.hready <= '1';
        if load_transaction_active = '1' then
          if coherence_rsp_line_empty = '0' then
            coherence_rsp_line_rdreq <= '1';
            if rsp_preamble = PREAMBLE_TAIL then
              load_done <= '1';
            end if;
          end if;
        end if;
        if (selected = '1' and ahbsi.hready = '1' and ahbsi.htrans = HTRANS_NONSEQ) then
          sample_flits <= '1';
          ahbs_next <= request_header;
        end if;

      when request_header => if load_transaction_active = '1' then
                               if coherence_rsp_line_empty = '0' then
                                 coherence_rsp_line_rdreq <= '1';
                                 if rsp_preamble = PREAMBLE_TAIL then
                                   load_done <= '1';
                                 end if;
                               end if;
                             else
                               if coherence_req_full = '0' then
                                 coherence_req_data_in <= header_reg;
                                 coherence_req_wrreq <= '1';
                                 ahbs_next <= request_address;
                               end if;
                             end if;

      when request_address => if coherence_req_full = '0' then
                                coherence_req_data_in <= payload_address_reg;
                                coherence_req_wrreq <= '1';
                                if hwrite_reg = '1' then
                                  ahbs_next <= request_data;
                                else
                                  ahbs_next <= reply_header;
                                end if;
                              end if;

      when request_data => if coherence_req_full = '0' then
                             ahbso.hready <= '1';
                             coherence_req_data_in <= payload_data;
                             coherence_req_wrreq <= '1';
                             if selected = '0' or ahbsi.htrans = HTRANS_IDLE then
                               ahbs_next <= idle;
                             elsif sequential = '0' then
                               sample_flits <= '1';
                               ahbs_next <= request_header;
                             end if;
                           end if;

      when reply_header => if coherence_rsp_line_empty = '0' then
                             load_start <= '1';
                             coherence_rsp_line_rdreq <= '1';
                             ahbs_next <= reply_data;
                           end if;

      when reply_data => if coherence_rsp_line_empty = '0' then
                           if rsp_preamble = PREAMBLE_TAIL then
                             load_done <= '1';
                           end if;
                           coherence_rsp_line_rdreq <= '1';
                           ahbso.hrdata <= ahbdrivedata(coherence_rsp_line_data_out(31 downto 0));
                           ahbso.hready <= '1';
                           if selected = '0' or ahbsi.htrans = HTRANS_IDLE then
                             ahbs_next <= idle;
                           elsif sequential = '0' or rsp_preamble = PREAMBLE_TAIL then
                             sample_flits <= '1';
                             ahbs_next <= request_header;
                           end if;
                         end if;

      when others => ahbs_next <= idle;

    end case;
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
