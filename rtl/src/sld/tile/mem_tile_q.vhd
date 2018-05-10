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
-- Entity:  mem_tile_q
-- File:    mem_tile_q.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description:	FIFO queues for the memory tile.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;
use work.tile.all;

entity mem_tile_q is
  generic (
    tech        : integer := virtex7);
  port (
    rst                                 : in  std_ulogic;
    clk                                 : in  std_ulogic;
    -- NoC1->tile
    coherence_req_rdreq                 : in  std_ulogic;
    coherence_req_data_out              : out noc_flit_type;
    coherence_req_empty                 : out std_ulogic;
    -- tile->NoC2
    coherence_fwd_wrreq             : in  std_ulogic;
    coherence_fwd_data_in           : in  noc_flit_type;
    coherence_fwd_full              : out std_ulogic;
    -- tile->NoC3
    coherence_rsp_snd_wrreq            : in  std_ulogic;
    coherence_rsp_snd_data_in          : in  noc_flit_type;
    coherence_rsp_snd_full             : out std_ulogic;
    -- Noc3->tile
    coherence_rsp_rcv_rdreq                       : in  std_ulogic;
    coherence_rsp_rcv_data_out                    : out noc_flit_type;
    coherence_rsp_rcv_empty                       : out std_ulogic;
    -- tile->NoC4
    dma_snd_wrreq                       : in  std_ulogic;
    dma_snd_data_in                     : in  noc_flit_type;
    dma_snd_full                        : out std_ulogic;
    dma_snd_atleast_4slots              : out std_ulogic;
    dma_snd_exactly_3slots              : out std_ulogic;
    -- tile->NoC4
    coherent_dma_snd_wrreq              : in  std_ulogic;
    coherent_dma_snd_data_in            : in  noc_flit_type;
    coherent_dma_snd_full               : out std_ulogic;
    -- NoC6->tile
    dma_rcv_rdreq                       : in  std_ulogic;
    dma_rcv_data_out                    : out noc_flit_type;
    dma_rcv_empty                       : out std_ulogic;
    -- NoC6->tile
    coherent_dma_rcv_rdreq              : in  std_ulogic;
    coherent_dma_rcv_data_out           : out noc_flit_type;
    coherent_dma_rcv_empty              : out std_ulogic;
    -- NoC5->tile
    remote_ahbs_rcv_rdreq               : in  std_ulogic;
    remote_ahbs_rcv_data_out            : out noc_flit_type;
    remote_ahbs_rcv_empty               : out std_ulogic;
    -- tile->NoC5
    remote_ahbs_snd_wrreq               : in  std_ulogic;
    remote_ahbs_snd_data_in             : in  noc_flit_type;
    remote_ahbs_snd_full                : out std_ulogic;
    -- NoC5->tile
    remote_apb_rcv_rdreq       : in  std_ulogic;
    remote_apb_rcv_data_out    : out noc_flit_type;
    remote_apb_rcv_empty       : out std_ulogic;
    -- tile->NoC5
    remote_apb_snd_wrreq       : in  std_ulogic;
    remote_apb_snd_data_in     : in  noc_flit_type;
    remote_apb_snd_full        : out std_ulogic;
    -- NoC5->tile
    apb_rcv_rdreq                       : in  std_ulogic;
    apb_rcv_data_out                    : out noc_flit_type;
    apb_rcv_empty                       : out std_ulogic;
    -- tile->NoC5
    apb_snd_wrreq                       : in  std_ulogic;
    apb_snd_data_in                     : in  noc_flit_type;
    apb_snd_full                        : out std_ulogic;

    -- Cachable data plane 1 -> request messages
    noc1_out_data : in  noc_flit_type;
    noc1_out_void : in  std_ulogic;
    noc1_out_stop : out std_ulogic;
    noc1_in_data  : out noc_flit_type;
    noc1_in_void  : out std_ulogic;
    noc1_in_stop  : in  std_ulogic;
    -- Cachable data plane 2 -> forwarded messages
    noc2_out_data : in  noc_flit_type;
    noc2_out_void : in  std_ulogic;
    noc2_out_stop : out std_ulogic;
    noc2_in_data  : out noc_flit_type;
    noc2_in_void  : out std_ulogic;
    noc2_in_stop  : in  std_ulogic;
    -- Cachable data plane 3 -> response messages
    noc3_out_data : in  noc_flit_type;
    noc3_out_void : in  std_ulogic;
    noc3_out_stop : out std_ulogic;
    noc3_in_data  : out noc_flit_type;
    noc3_in_void  : out std_ulogic;
    noc3_in_stop  : in  std_ulogic;
    -- Non cachable data data plane 4 -> DMA response
    noc4_out_data : in  noc_flit_type;
    noc4_out_void : in  std_ulogic;
    noc4_out_stop : out std_ulogic;
    noc4_in_data  : out noc_flit_type;
    noc4_in_void  : out std_ulogic;
    noc4_in_stop  : in  std_ulogic;
    -- Configuration plane 5 -> RD/WR registers
    noc5_out_data : in  noc_flit_type;
    noc5_out_void : in  std_ulogic;
    noc5_out_stop : out std_ulogic;
    noc5_in_data  : out noc_flit_type;
    noc5_in_void  : out std_ulogic;
    noc5_in_stop  : in  std_ulogic;
    -- Non cachable data data plane 6 -> DMA requests
    noc6_out_data : in  noc_flit_type;
    noc6_out_void : in  std_ulogic;
    noc6_out_stop : out std_ulogic;
    noc6_in_data  : out noc_flit_type;
    noc6_in_void  : out std_ulogic;
    noc6_in_stop  : in  std_ulogic);

end mem_tile_q;

architecture rtl of mem_tile_q is

  signal fifo_rst : std_ulogic;

  -- NoC1->tile
  signal coherence_req_wrreq                 : std_ulogic;
  signal coherence_req_data_in               : noc_flit_type;
  signal coherence_req_full                  : std_ulogic;
  -- tile->NoC2
  signal coherence_fwd_rdreq             : std_ulogic;
  signal coherence_fwd_data_out          : noc_flit_type;
  signal coherence_fwd_empty             : std_ulogic;
  -- tile->NoC3
  signal coherence_rsp_snd_rdreq            : std_ulogic;
  signal coherence_rsp_snd_data_out         : noc_flit_type;
  signal coherence_rsp_snd_empty            : std_ulogic;
  -- NoC3->tile
  signal coherence_rsp_rcv_wrreq                       : std_ulogic;
  signal coherence_rsp_rcv_data_in                     : noc_flit_type;
  signal coherence_rsp_rcv_full                        : std_ulogic;
  -- NoC6->tile
  signal dma_rcv_wrreq                       : std_ulogic;
  signal dma_rcv_data_in                     : noc_flit_type;
  signal dma_rcv_full                        : std_ulogic;
  -- tile->NoC6
  signal coherent_dma_snd_rdreq              : std_ulogic;
  signal coherent_dma_snd_data_out           : noc_flit_type;
  signal coherent_dma_snd_empty              : std_ulogic;
  -- tile->NoC4
  signal dma_snd_rdreq                       : std_ulogic;
  signal dma_snd_data_out                    : noc_flit_type;
  signal dma_snd_empty                       : std_ulogic;
  -- NoC4->tile
  signal coherent_dma_rcv_wrreq              : std_ulogic;
  signal coherent_dma_rcv_data_in            : noc_flit_type;
  signal coherent_dma_rcv_full               : std_ulogic;
  -- NoC5->tile
  signal remote_ahbs_rcv_wrreq        : std_ulogic;
  signal remote_ahbs_rcv_data_in      : noc_flit_type;
  signal remote_ahbs_rcv_full         : std_ulogic;
  -- tile->NoC5
  signal remote_ahbs_snd_rdreq        : std_ulogic;
  signal remote_ahbs_snd_data_out     : noc_flit_type;
  signal remote_ahbs_snd_empty        : std_ulogic;
  -- NoC5->tile
  signal remote_apb_rcv_wrreq                : std_ulogic;
  signal remote_apb_rcv_data_in              : noc_flit_type;
  signal remote_apb_rcv_full                 : std_ulogic;
  -- tile->NoC5
  signal remote_apb_snd_rdreq                : std_ulogic;
  signal remote_apb_snd_data_out             : noc_flit_type;
  signal remote_apb_snd_empty                : std_ulogic;
  -- NoC5->tile
  signal apb_rcv_wrreq                : std_ulogic;
  signal apb_rcv_data_in              : noc_flit_type;
  signal apb_rcv_full                 : std_ulogic;
  -- tile->NoC5
  signal apb_snd_rdreq                : std_ulogic;
  signal apb_snd_data_out             : noc_flit_type;
  signal apb_snd_empty                : std_ulogic;

  -- Local Master -> Local apb slave (request)
  signal local_remote_apb_snd_wrreq                : std_ulogic;
  signal local_remote_apb_snd_data_in              : noc_flit_type;
  signal local_remote_apb_snd_full                 : std_ulogic;
  signal local_remote_apb_rcv_rdreq                : std_ulogic;
  signal local_remote_apb_rcv_data_out             : noc_flit_type;
  signal local_remote_apb_rcv_empty                : std_ulogic;
  -- Local apb slave --> Local Master (response)
  signal local_apb_snd_wrreq                : std_ulogic;
  signal local_apb_snd_data_in              : noc_flit_type;
  signal local_apb_snd_full                 : std_ulogic;
  signal local_apb_rcv_rdreq                : std_ulogic;
  signal local_apb_rcv_data_out             : noc_flit_type;
  signal local_apb_rcv_empty                : std_ulogic;


  signal noc1_dummy_in_stop   : std_ulogic;
  signal noc2_dummy_out_data  : noc_flit_type;
  signal noc2_dummy_out_void  : std_ulogic;
  signal noc4_dummy_out_data  : noc_flit_type;
  signal noc4_dummy_out_void  : std_ulogic;
  signal noc6_dummy_in_stop   : std_ulogic;

  type to_noc4_packet_fsm is (none, packet_dma_snd, packet_coherent_dma_snd);
  signal to_noc4_fifos_current, to_noc4_fifos_next : to_noc4_packet_fsm;

  type noc5_packet_fsm is (none, packet_remote_apb_rcv,
                           packet_remote_ahbs_rcv, packet_apb_rcv,
                           packet_local_remote_apb_rcv, packet_local_apb_rcv);
  signal noc5_fifos_current, noc5_fifos_next : noc5_packet_fsm;

  type to_noc5_packet_fsm is (none, packet_remote_apb_snd, packet_remote_ahbs_snd,
                              packet_apb_snd, packet_local_remote_apb_snd,
                              packet_local_apb_snd);
  signal to_noc5_fifos_current, to_noc5_fifos_next : to_noc5_packet_fsm;

  type noc6_packet_fsm is (none, packet_dma_rcv, packet_coherent_dma_rcv);
  signal noc6_fifos_current, noc6_fifos_next : noc6_packet_fsm;

  signal noc5_msg_type : noc_msg_type;
  signal noc5_preamble : noc_preamble_type;

  signal noc6_msg_type : noc_msg_type;
  signal noc6_preamble : noc_preamble_type;

  signal local_remote_apb_rcv_preamble : noc_preamble_type;
  signal local_apb_rcv_preamble : noc_preamble_type;

begin  -- rtl

  fifo_rst <= rst;                  --FIFO rst active low

  -- From noc1: coherence requests from CPU to directory (GET/PUT)
  noc1_in_data          <= (others => '0');
  noc1_in_void          <= '1';
  noc1_dummy_in_stop    <= noc1_in_stop;
  noc1_out_stop         <= coherence_req_full and (not noc1_out_void);
  coherence_req_data_in <= noc1_out_data;
  coherence_req_wrreq   <= (not noc1_out_void) and (not coherence_req_full);

  fifo_1: fifo
    generic map (
      depth => 6,                       --Header, address, [cache line]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_req_rdreq,
      wrreq    => coherence_req_wrreq,
      data_in  => coherence_req_data_in,
      empty    => coherence_req_empty,
      full     => coherence_req_full,
      data_out => coherence_req_data_out);


  -- To noc2: coherence forwarded messages to CPU (INV)
  -- To noc2: coherence forwarded messages to CPU (PUT_ACK)
  noc2_out_stop <= '0';
  noc2_dummy_out_data <= noc2_out_data;
  noc2_dummy_out_void <= noc2_out_void;
  noc2_in_data <= coherence_fwd_data_out;
  noc2_in_void <= coherence_fwd_empty or noc2_in_stop;
  coherence_fwd_rdreq <= (not coherence_fwd_empty) and (not noc2_in_stop);

  fifo_2: fifo
    generic map (
      depth => 4,                       --Header, address (x2)
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_fwd_rdreq,
      wrreq    => coherence_fwd_wrreq,
      data_in  => coherence_fwd_data_in,
      empty    => coherence_fwd_empty,
      full     => coherence_fwd_full,
      data_out => coherence_fwd_data_out);

  -- From noc3: coherence response messages from CPU (LINE on a GETS while
  -- owining the line in modified state)
  noc3_out_stop   <= coherence_rsp_rcv_full and (not noc3_out_void);
  coherence_rsp_rcv_data_in <= noc3_out_data;
  coherence_rsp_rcv_wrreq   <= (not noc3_out_void) and (not coherence_rsp_rcv_full);
  fifo_3: fifo
    generic map (
      depth => 18,                      --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_rsp_rcv_rdreq,
      wrreq    => coherence_rsp_rcv_wrreq,
      data_in  => coherence_rsp_rcv_data_in,
      empty    => coherence_rsp_rcv_empty,
      full     => coherence_rsp_rcv_full,
      data_out => coherence_rsp_rcv_data_out);

  -- to noc3: coherence response messages to CPU (LINE)
  noc3_in_data <= coherence_rsp_snd_data_out;
  noc3_in_void <= coherence_rsp_snd_empty or noc3_in_stop;
  coherence_rsp_snd_rdreq <= (not coherence_rsp_snd_empty) and (not noc3_in_stop);
  fifo_4: fifo
    generic map (
      depth => 5,                       --Header, cache line
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_rsp_snd_rdreq,
      wrreq    => coherence_rsp_snd_wrreq,
      data_in  => coherence_rsp_snd_data_in,
      empty    => coherence_rsp_snd_empty,
      full     => coherence_rsp_snd_full,
      data_out => coherence_rsp_snd_data_out);


  -- From noc6: [LLC|Non]-coherent DMA requests from accelerators
  noc6_in_data       <= (others => '0');
  noc6_in_void       <= '1';
  noc6_dummy_in_stop <=  noc6_in_stop;

  noc6_msg_type <= get_msg_type(noc6_out_data);
  noc6_preamble <= get_preamble(noc6_out_data);

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      noc6_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      noc6_fifos_current <= noc6_fifos_next;
    end if;
  end process;
  noc6_fifos_get_packet: process (noc6_out_data, noc6_out_void, noc6_msg_type,
                                  noc6_preamble, noc6_fifos_current,
                                  dma_rcv_full, coherent_dma_rcv_full)
  begin
    dma_rcv_wrreq <= '0';
    dma_rcv_data_in <= noc6_out_data;

    coherent_dma_rcv_wrreq <= '0';
    coherent_dma_rcv_data_in <= noc6_out_data;

    noc6_fifos_next <= noc6_fifos_current;
    noc6_out_stop <= '0';

    case noc6_fifos_current is
      when none =>
        if noc6_out_void = '0' then
          if ((noc6_msg_type = DMA_TO_DEV or noc6_msg_type = DMA_FROM_DEV)
              and noc6_preamble = PREAMBLE_HEADER) then
            if dma_rcv_full = '0' then
              dma_rcv_wrreq <= '1';
              noc6_fifos_next <= packet_dma_rcv;
            else
              noc6_out_stop <= '1';
            end if;
          elsif ((noc6_msg_type = REQ_DMA_READ or noc6_msg_type = REQ_DMA_WRITE)
              and noc6_preamble = PREAMBLE_HEADER) then
            if coherent_dma_rcv_full = '0' then
              coherent_dma_rcv_wrreq <= '1';
              noc6_fifos_next <= packet_coherent_dma_rcv;
            else
              noc6_out_stop <= '1';
            end if;
          end if;
        end if;

      when packet_dma_rcv =>
        dma_rcv_wrreq <= not noc6_out_void and (not dma_rcv_full);
        noc6_out_stop <= dma_rcv_full and (not noc6_out_void);
        if (noc6_preamble = PREAMBLE_TAIL and noc6_out_void = '0' and
            dma_rcv_full = '0') then
          noc6_fifos_next <= none;
        end if;

      when packet_coherent_dma_rcv =>
        coherent_dma_rcv_wrreq <= not noc6_out_void and (not coherent_dma_rcv_full);
        noc6_out_stop <= coherent_dma_rcv_full and (not noc6_out_void);
        if (noc6_preamble = PREAMBLE_TAIL and noc6_out_void = '0' and
            coherent_dma_rcv_full = '0') then
          noc6_fifos_next <= none;
        end if;

      when others => noc6_fifos_next <= none;
    end case;
  end process noc6_fifos_get_packet;

  fifo_13: fifo
    generic map (
      depth => 18,                      --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => dma_rcv_rdreq,
      wrreq    => dma_rcv_wrreq,
      data_in  => dma_rcv_data_in,
      empty    => dma_rcv_empty,
      full     => dma_rcv_full,
      data_out => dma_rcv_data_out);

  fifo_13c: fifo
    generic map (
      depth => 18,                      --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherent_dma_rcv_rdreq,
      wrreq    => coherent_dma_rcv_wrreq,
      data_in  => coherent_dma_rcv_data_in,
      empty    => coherent_dma_rcv_empty,
      full     => coherent_dma_rcv_full,
      data_out => coherent_dma_rcv_data_out);

  -- To noc4: [LLC|Non]-Coherent DMA response to accelerators
  noc4_out_stop       <= '0';
  noc4_dummy_out_data <= noc4_out_data;
  noc4_dummy_out_void <= noc4_out_void;
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      to_noc4_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      to_noc4_fifos_current <= to_noc4_fifos_next;
    end if;
  end process;

  to_noc4_select_packet: process (noc4_in_stop, to_noc4_fifos_current,
                                  dma_snd_data_out, dma_snd_empty,
                                  coherent_dma_snd_data_out, coherent_dma_snd_empty)
    variable to_noc4_preamble : noc_preamble_type;
  begin  -- process to_noc4_select_packet
    noc4_in_data <= (others => '0');
    noc4_in_void <= '1';

    dma_snd_rdreq <= '0';
    coherent_dma_snd_rdreq <= '0';

    to_noc4_fifos_next <= to_noc4_fifos_current;
    to_noc4_preamble := "00";

    case to_noc4_fifos_current is
      when none =>
        if dma_snd_empty = '0' then
          noc4_in_data <= dma_snd_data_out;
          noc4_in_void <= dma_snd_empty and (not noc4_in_stop);
          if noc4_in_stop = '0' then
            dma_snd_rdreq <= '1';
            to_noc4_fifos_next <= packet_dma_snd;
          end if;
        elsif coherent_dma_snd_empty = '0' then
          noc4_in_data <= coherent_dma_snd_data_out;
          noc4_in_void <= coherent_dma_snd_empty and (not noc4_in_stop);
          if noc4_in_stop = '0' then
            coherent_dma_snd_rdreq <= '1';
            to_noc4_fifos_next <= packet_coherent_dma_snd;
          end if;

        end if;

      when packet_dma_snd  =>
        to_noc4_preamble := get_preamble(dma_snd_data_out);
        if (noc4_in_stop = '0' and dma_snd_empty = '0') then
          noc4_in_data <= dma_snd_data_out;
          noc4_in_void <= dma_snd_empty;
          dma_snd_rdreq <= '1';
          if (to_noc4_preamble = PREAMBLE_TAIL) then
            to_noc4_fifos_next <= none;
          end if;
        end if;

      when packet_coherent_dma_snd  =>
        to_noc4_preamble := get_preamble(coherent_dma_snd_data_out);
        if (noc4_in_stop = '0' and coherent_dma_snd_empty = '0') then
          noc4_in_data <= coherent_dma_snd_data_out;
          noc4_in_void <= coherent_dma_snd_empty;
          coherent_dma_snd_rdreq <= '1';
          if (to_noc4_preamble = PREAMBLE_TAIL) then
            to_noc4_fifos_next <= none;
          end if;
        end if;

      when others => to_noc4_fifos_next <= none;
    end case;
  end process to_noc4_select_packet;

  fifo_14: fifo2
    generic map (
      depth => 18,                      --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => dma_snd_rdreq,
      wrreq    => dma_snd_wrreq,
      data_in  => dma_snd_data_in,
      empty    => dma_snd_empty,
      full     => dma_snd_full,
      atleast_4slots => dma_snd_atleast_4slots,
      exactly_3slots => dma_snd_exactly_3slots,
      data_out => dma_snd_data_out);

  fifo_14c: fifo
    generic map (
      depth => 18,                      --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherent_dma_snd_rdreq,
      wrreq    => coherent_dma_snd_wrreq,
      data_in  => coherent_dma_snd_data_in,
      empty    => coherent_dma_snd_empty,
      full     => coherent_dma_snd_full,
      data_out => coherent_dma_snd_data_out);

  -- From noc5: APB slave response (APBs rcv)
  -- From noc5: AHB slave response from remote DSU (AHBs rcv)
  -- From local_remote_apb_rcv (APB rcv from devicess in this tile)
  -- Priority must be respected to avoid deadlock!
  noc5_msg_type <= get_msg_type(noc5_out_data);
  noc5_preamble <= get_preamble(noc5_out_data);
  local_remote_apb_rcv_preamble <= get_preamble(local_remote_apb_rcv_data_out);
  local_apb_rcv_preamble <= get_preamble(local_apb_rcv_data_out);
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      noc5_fifos_current <= noc5_fifos_next;
    end if;
  end process;
  noc5_fifos_get_packet: process (noc5_out_data, noc5_out_void, noc5_msg_type,
                                  noc5_preamble, remote_apb_rcv_full,
                                  remote_ahbs_rcv_full, noc5_fifos_current,
                                  apb_rcv_full, local_remote_apb_rcv_empty,
                                  local_apb_rcv_empty, local_remote_apb_rcv_data_out,
                                  local_apb_rcv_data_out, local_remote_apb_rcv_preamble,
                                  local_apb_rcv_preamble)
  begin  -- process noc5_get_packet
    remote_apb_rcv_wrreq <= '0';
    remote_apb_rcv_data_in <= noc5_out_data;

    remote_ahbs_rcv_data_in <= noc5_out_data;
    remote_ahbs_rcv_wrreq <= '0';

    apb_rcv_wrreq <= '0';
    apb_rcv_data_in <= noc5_out_data;

    noc5_fifos_next <= noc5_fifos_current;
    noc5_out_stop <= '0';


    local_remote_apb_rcv_rdreq <= '0';
    local_apb_rcv_rdreq <= '0';

    case noc5_fifos_current is
      when none => if local_remote_apb_rcv_empty = '0' then
                     noc5_out_stop <= not noc5_out_void;
                     if apb_rcv_full = '0' then
                       local_remote_apb_rcv_rdreq <= '1';
                       apb_rcv_wrreq <= '1';
                       apb_rcv_data_in <= local_remote_apb_rcv_data_out;
                       noc5_fifos_next <= packet_local_remote_apb_rcv;
                     end if;
                   elsif local_apb_rcv_empty = '0' then
                     noc5_out_stop <= not noc5_out_void;
                     if remote_apb_rcv_full = '0' then
                       local_apb_rcv_rdreq <= '1';
                       remote_apb_rcv_wrreq <= '1';
                       remote_apb_rcv_data_in <= local_apb_rcv_data_out;
                       noc5_fifos_next <= packet_local_apb_rcv;
                     end if;
                   elsif noc5_out_void = '0' then
                     if ((noc5_msg_type = RSP_REG_RD)
                         and noc5_preamble = PREAMBLE_HEADER) then
                       if remote_apb_rcv_full = '0' then
                         remote_apb_rcv_wrreq <= '1';
                         noc5_fifos_next <= packet_remote_apb_rcv;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     elsif ((noc5_msg_type = AHB_RD or noc5_msg_type = AHB_WR) and noc5_preamble = PREAMBLE_HEADER) then
                       if remote_ahbs_rcv_full = '0' then
                         remote_ahbs_rcv_wrreq <= '1';
                         noc5_fifos_next <= packet_remote_ahbs_rcv;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     elsif ((noc5_msg_type = REQ_REG_RD or noc5_msg_type = REQ_REG_WR) and noc5_preamble = PREAMBLE_HEADER) then
                       if apb_rcv_full = '0' then
                         apb_rcv_wrreq <= '1';
                         noc5_fifos_next <= packet_apb_rcv;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     end if;

                   end if;

      when packet_remote_apb_rcv => remote_apb_rcv_wrreq <= not noc5_out_void and (not remote_apb_rcv_full);
                             noc5_out_stop <= remote_apb_rcv_full and (not noc5_out_void);
                             if (noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                                 remote_apb_rcv_full = '0') then
                               noc5_fifos_next <= none;
                             end if;

      when packet_local_remote_apb_rcv => noc5_out_stop <= not noc5_out_void;
                                          apb_rcv_wrreq <= not local_remote_apb_rcv_empty and (not apb_rcv_full);
                                          apb_rcv_data_in <= local_remote_apb_rcv_data_out;
                                          local_remote_apb_rcv_rdreq <= (not apb_rcv_full);
                                          if (local_remote_apb_rcv_preamble = PREAMBLE_TAIL and local_remote_apb_rcv_empty = '0' and
                                              apb_rcv_full = '0') then
                                            noc5_fifos_next <= none;
                                          end if;

      when packet_remote_ahbs_rcv => remote_ahbs_rcv_wrreq <= not noc5_out_void and (not remote_ahbs_rcv_full);
                             noc5_out_stop <= remote_ahbs_rcv_full and (not noc5_out_void);
                             if (noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                                 remote_ahbs_rcv_full = '0') then
                               noc5_fifos_next <= none;
                             end if;

      when packet_apb_rcv => apb_rcv_wrreq <= not noc5_out_void and (not apb_rcv_full);
                             noc5_out_stop <= apb_rcv_full and (not noc5_out_void);
                             if (noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                                 apb_rcv_full = '0') then
                               noc5_fifos_next <= none;
                             end if;

      when packet_local_apb_rcv => noc5_out_stop <= not noc5_out_void;
                                   remote_apb_rcv_wrreq <= not local_apb_rcv_empty and (not remote_apb_rcv_full);
                                   local_apb_rcv_rdreq <= (not remote_apb_rcv_full);
                                   remote_apb_rcv_data_in <= local_apb_rcv_data_out;
                                   if (local_apb_rcv_preamble = PREAMBLE_TAIL and local_apb_rcv_empty = '0' and
                                       remote_apb_rcv_full = '0') then
                                     noc5_fifos_next <= none;
                                   end if;

      when others => noc5_fifos_next <= none;
    end case;
  end process noc5_fifos_get_packet;

  fifo_7: fifo
    generic map (
      depth => 3,                       --Header, address, data
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_apb_rcv_rdreq,
      wrreq    => remote_apb_rcv_wrreq,
      data_in  => remote_apb_rcv_data_in,
      empty    => remote_apb_rcv_empty,
      full     => remote_apb_rcv_full,
      data_out => remote_apb_rcv_data_out);

  fifo_8: fifo
    generic map (
      depth => 5,                       --Header, data up to 4 words
                                        --per packet
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_ahbs_rcv_rdreq,
      wrreq    => remote_ahbs_rcv_wrreq,
      data_in  => remote_ahbs_rcv_data_in,
      empty    => remote_ahbs_rcv_empty,
      full     => remote_ahbs_rcv_full,
      data_out => remote_ahbs_rcv_data_out);

  fifo_16: fifo
    generic map (
      depth => 3,                       --Header, address, data
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_rcv_rdreq,
      wrreq    => apb_rcv_wrreq,
      data_in  => apb_rcv_data_in,
      empty    => apb_rcv_empty,
      full     => apb_rcv_full,
      data_out => apb_rcv_data_out);

  -- To noc5: APB request to remote (APB snd)
  -- To noc5: AHB master request to DSU (AHBS snd) - TODO: broadcast to all DSUs
  -- To local_remote_apb_snd (APB snd to devicess in this tile)
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      to_noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      to_noc5_fifos_current <= to_noc5_fifos_next;
    end if;
  end process;

  to_noc5_select_packet: process (noc5_in_stop, to_noc5_fifos_current,
                                  remote_apb_snd_data_out, remote_apb_snd_empty,
                                  remote_ahbs_snd_data_out, remote_ahbs_snd_empty,
                                  apb_snd_data_out, apb_snd_empty,
                                  local_remote_apb_snd_full, local_apb_snd_full)
    variable to_noc5_preamble : noc_preamble_type;
    variable remote_apb_snd_to_local : std_ulogic;
    variable apb_snd_to_local : std_ulogic;
  begin  -- process to_noc5_select_packet
    remote_apb_snd_to_local := remote_apb_snd_data_out(HEADER_ROUTE_L);
    apb_snd_to_local        := apb_snd_data_out(HEADER_ROUTE_L);
    local_remote_apb_snd_wrreq <= '0';
    local_apb_snd_wrreq <= '0';

    noc5_in_data <= (others => '0');
    noc5_in_void <= '1';

    remote_apb_snd_rdreq <= '0';
    remote_ahbs_snd_rdreq <= '0';
    apb_snd_rdreq <= '0';
    to_noc5_fifos_next <= to_noc5_fifos_current;
    to_noc5_preamble := "00";


    case to_noc5_fifos_current is
      when none  => if (remote_apb_snd_empty = '0' and remote_apb_snd_to_local = '0') then
                      noc5_in_data <= remote_apb_snd_data_out;
                      noc5_in_void <= remote_apb_snd_empty;
                      if noc5_in_stop = '0' then
                        remote_apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_remote_apb_snd;
                      end if;
                    elsif (remote_apb_snd_empty = '0' and remote_apb_snd_to_local = '1') then
                      if local_remote_apb_snd_full = '0' then
                        local_remote_apb_snd_wrreq <= '1';
                        remote_apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_local_remote_apb_snd;
                      end if;
                    elsif remote_ahbs_snd_empty = '0' then
                      noc5_in_data <= remote_ahbs_snd_data_out;
                      noc5_in_void <= remote_ahbs_snd_empty;
                      if noc5_in_stop = '0' then
                        remote_ahbs_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_remote_ahbs_snd;
                      end if;
                    elsif (apb_snd_empty = '0' and apb_snd_to_local = '0') then
                      noc5_in_data <= apb_snd_data_out;
                      noc5_in_void <= apb_snd_empty;
                      if noc5_in_stop = '0' then
                        apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_apb_snd;
                      end if;
                    elsif (apb_snd_empty = '0' and apb_snd_to_local = '1') then
                      if local_apb_snd_full = '0' then
                        local_apb_snd_wrreq <= '1';
                        apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_local_apb_snd;
                      end if;

                    end if;

      when packet_remote_apb_snd => to_noc5_preamble := get_preamble(remote_apb_snd_data_out);
                             if (noc5_in_stop = '0' and remote_apb_snd_empty = '0') then
                               noc5_in_data <= remote_apb_snd_data_out;
                               noc5_in_void <= remote_apb_snd_empty;
                               remote_apb_snd_rdreq <= not noc5_in_stop;
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_local_remote_apb_snd => to_noc5_preamble := get_preamble(remote_apb_snd_data_out);
                             if (local_remote_apb_snd_full = '0' and remote_apb_snd_empty = '0') then
                               local_remote_apb_snd_wrreq <= '1';
                               remote_apb_snd_rdreq <= '1';
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_remote_ahbs_snd  => to_noc5_preamble := get_preamble(remote_ahbs_snd_data_out);
                             if (noc5_in_stop = '0' and remote_ahbs_snd_empty = '0') then
                               noc5_in_data <= remote_ahbs_snd_data_out;
                               noc5_in_void <= remote_ahbs_snd_empty;
                               remote_ahbs_snd_rdreq <= not noc5_in_stop;
                               if (to_noc5_preamble = PREAMBLE_TAIL) then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_apb_snd  => to_noc5_preamble := get_preamble(apb_snd_data_out);
                             if (noc5_in_stop = '0' and apb_snd_empty = '0') then
                               noc5_in_data <= apb_snd_data_out;
                               noc5_in_void <= apb_snd_empty;
                               apb_snd_rdreq <= not noc5_in_stop;
                               if (to_noc5_preamble = PREAMBLE_TAIL) then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_local_apb_snd => to_noc5_preamble := get_preamble(apb_snd_data_out);
                             if (local_apb_snd_full = '0' and apb_snd_empty = '0') then
                               local_apb_snd_wrreq <= '1';
                               apb_snd_rdreq <= '1';
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

  when others => to_noc5_fifos_next <= none;
    end case;
  end process to_noc5_select_packet;

  fifo_10: fifo
    generic map (
      depth => 2,                       --Header, data (1 word)
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_apb_snd_rdreq,
      wrreq    => remote_apb_snd_wrreq,
      data_in  => remote_apb_snd_data_in,
      empty    => remote_apb_snd_empty,
      full     => remote_apb_snd_full,
      data_out => remote_apb_snd_data_out);

  fifo_11: fifo
    generic map (
      depth => 6,                       --Header, address, data (up to 4 words)
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_ahbs_snd_rdreq,
      wrreq    => remote_ahbs_snd_wrreq,
      data_in  => remote_ahbs_snd_data_in,
      empty    => remote_ahbs_snd_empty,
      full     => remote_ahbs_snd_full,
      data_out => remote_ahbs_snd_data_out);

  fifo_17: fifo
    generic map (
      depth => 6,                       --Header, address, data (up to 4 words)
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_snd_rdreq,
      wrreq    => apb_snd_wrreq,
      data_in  => apb_snd_data_in,
      empty    => apb_snd_empty,
      full     => apb_snd_full,
      data_out => apb_snd_data_out);

  local_remote_apb_snd_data_in <= remote_apb_snd_data_out;
  fifo_18: fifo
    generic map (
      depth => 6,                       --Header, address, data (1 word) (2x)
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => local_remote_apb_rcv_rdreq,
      wrreq    => local_remote_apb_snd_wrreq,
      data_in  => local_remote_apb_snd_data_in,
      empty    => local_remote_apb_rcv_empty,
      full     => local_remote_apb_snd_full,
      data_out => local_remote_apb_rcv_data_out);

  local_apb_snd_data_in <= apb_snd_data_out;
  fifo_19: fifo
    generic map (
      depth => 6,                       --Header, data (1 word) (2x)
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => local_apb_rcv_rdreq,
      wrreq    => local_apb_snd_wrreq,
      data_in  => local_apb_snd_data_in,
      empty    => local_apb_rcv_empty,
      full     => local_apb_snd_full,
      data_out => local_apb_rcv_data_out);

end rtl;
