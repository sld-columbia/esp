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
-- Entity:  cpu_tile_q
-- File:    cpu_tile_q.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description:	FIFO queues for the CPU tile.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;
use work.tile.all;

entity cpu_tile_q is
  generic (
    tech        : integer := virtex7);
  port (
    rst                                 : in  std_ulogic;
    clk                                 : in  std_ulogic;
    -- tile->NoC1
    coherence_req_wrreq                 : in  std_ulogic;
    coherence_req_data_in               : in  noc_flit_type;
    coherence_req_full                  : out std_ulogic;
    -- NoC2->tile
    coherence_fwd_inv_rdreq             : in  std_ulogic;
    coherence_fwd_inv_data_out          : out noc_flit_type;
    coherence_fwd_inv_empty             : out std_ulogic;
    -- NoC2->tile
    coherence_fwd_put_ack_rdreq         : in  std_ulogic;
    coherence_fwd_put_ack_data_out      : out noc_flit_type;
    coherence_fwd_put_ack_empty         : out std_ulogic;
    -- Noc3->tile
    coherence_rsp_line_rdreq            : in  std_ulogic;
    coherence_rsp_line_data_out         : out noc_flit_type;
    coherence_rsp_line_empty            : out std_ulogic;
    -- Noc3->tile
    coherence_rsp_inv_ack_rcv_rdreq     : in  std_ulogic;
    coherence_rsp_inv_ack_rcv_data_out  : out noc_flit_type;
    coherence_rsp_inv_ack_rcv_empty     : out std_ulogic;
    -- tile->NoC3
    coherence_rsp_inv_ack_snd_wrreq     : in  std_ulogic;
    coherence_rsp_inv_ack_snd_data_in   : in  noc_flit_type;
    coherence_rsp_inv_ack_snd_full      : out std_ulogic;
    -- NoC5->tile
    remote_apb_rcv_rdreq                : in  std_ulogic;
    remote_apb_rcv_data_out             : out noc_flit_type;
    remote_apb_rcv_empty                : out std_ulogic;
    -- tile->NoC5
    remote_apb_snd_wrreq                : in  std_ulogic;
    remote_apb_snd_data_in              : in  noc_flit_type;
    remote_apb_snd_full                 : out std_ulogic;
    -- NoC5->tile
    remote_ahbm_rcv_rdreq               : in  std_ulogic;
    remote_ahbm_rcv_data_out            : out noc_flit_type;
    remote_ahbm_rcv_empty               : out std_ulogic;
    -- tile->NoC5
    remote_ahbm_snd_wrreq               : in  std_ulogic;
    remote_ahbm_snd_data_in             : in  noc_flit_type;
    remote_ahbm_snd_full                : out std_ulogic;
    -- NoC5->tile
    remote_irq_rdreq                    : in  std_ulogic;
    remote_irq_data_out                 : out noc_flit_type;
    remote_irq_empty                    : out std_ulogic;
    -- tile->NoC5
    remote_irq_ack_wrreq                : in  std_ulogic;
    remote_irq_ack_data_in              : in  noc_flit_type;
    remote_irq_ack_full                 : out std_ulogic;

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
    -- Non cachable data data plane 4 -> DMA transfers response
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
    -- Non cachable data data plane 6 -> DMA transfers request
    noc6_out_data : in  noc_flit_type;
    noc6_out_void : in  std_ulogic;
    noc6_out_stop : out std_ulogic;
    noc6_in_data  : out noc_flit_type;
    noc6_in_void  : out std_ulogic;
    noc6_in_stop  : in  std_ulogic);

end cpu_tile_q;

architecture rtl of cpu_tile_q is

  signal fifo_rst : std_ulogic;

  -- tile->NoC1
  signal coherence_req_rdreq                 : std_ulogic;
  signal coherence_req_data_out              : noc_flit_type;
  signal coherence_req_empty                 : std_ulogic;
  -- NoC2->tile
  signal coherence_fwd_inv_wrreq             : std_ulogic;
  signal coherence_fwd_inv_data_in           : noc_flit_type;
  signal coherence_fwd_inv_full              : std_ulogic;
  -- NoC2->tile
  signal coherence_fwd_put_ack_wrreq         : std_ulogic;
  signal coherence_fwd_put_ack_data_in       : noc_flit_type;
  signal coherence_fwd_put_ack_full          : std_ulogic;
  -- NoC3->tile
  signal coherence_rsp_line_wrreq            : std_ulogic;
  signal coherence_rsp_line_data_in          : noc_flit_type;
  signal coherence_rsp_line_full             : std_ulogic;
  -- NoC3->tile
  signal coherence_rsp_inv_ack_rcv_wrreq     : std_ulogic;
  signal coherence_rsp_inv_ack_rcv_data_in   : noc_flit_type;
  signal coherence_rsp_inv_ack_rcv_full      : std_ulogic;
  -- tile->NoC3
  signal coherence_rsp_inv_ack_snd_rdreq     : std_ulogic;
  signal coherence_rsp_inv_ack_snd_data_out  : noc_flit_type;
  signal coherence_rsp_inv_ack_snd_empty     : std_ulogic;
  -- NoC5->tile
  signal remote_apb_rcv_wrreq                : std_ulogic;
  signal remote_apb_rcv_data_in              : noc_flit_type;
  signal remote_apb_rcv_full                 : std_ulogic;
  -- tile->NoC5
  signal remote_apb_snd_rdreq                : std_ulogic;
  signal remote_apb_snd_data_out             : noc_flit_type;
  signal remote_apb_snd_empty                : std_ulogic;
  -- NoC5->tile
  signal remote_ahbm_rcv_wrreq               : std_ulogic;
  signal remote_ahbm_rcv_data_in             : noc_flit_type;
  signal remote_ahbm_rcv_full                : std_ulogic;
  -- tile->NoC5
  signal remote_ahbm_snd_rdreq               : std_ulogic;
  signal remote_ahbm_snd_data_out            : noc_flit_type;
  signal remote_ahbm_snd_empty               : std_ulogic;
  -- NoC5->tile
  signal remote_irq_wrreq                    : std_ulogic;
  signal remote_irq_data_in                  : noc_flit_type;
  signal remote_irq_full                     : std_ulogic;
  -- tile->NoC5
  signal remote_irq_ack_rdreq                : std_ulogic;
  signal remote_irq_ack_data_out             : noc_flit_type;
  signal remote_irq_ack_empty                : std_ulogic;

  type noc2_packet_fsm is (none, packet_inv);
  signal noc2_fifos_current, noc2_fifos_next : noc2_packet_fsm;
  type noc3_packet_fsm is (none, packet_line);
  signal noc3_fifos_current, noc3_fifos_next : noc3_packet_fsm;
  type noc5_packet_fsm is (none, packet_apb_rcv, packet_ahbm_rcv, packet_irq);
  signal noc5_fifos_current, noc5_fifos_next : noc5_packet_fsm;
  type to_noc5_packet_fsm is (none, packet_apb_snd, packet_ahbm_snd, packet_irq_ack);
  signal to_noc5_fifos_current, to_noc5_fifos_next : to_noc5_packet_fsm;


  signal noc2_msg_type : noc_msg_type;
  signal noc2_preamble : noc_preamble_type;
  signal noc3_msg_type : noc_msg_type;
  signal noc3_preamble : noc_preamble_type;
  signal noc5_msg_type : noc_msg_type;
  signal noc5_preamble : noc_preamble_type;

  signal noc4_dummy_in_stop   : std_ulogic;
  signal noc4_dummy_out_data  : noc_flit_type;
  signal noc4_dummy_out_void  : std_ulogic;
  signal noc6_dummy_in_stop   : std_ulogic;
  signal noc6_dummy_out_data  : noc_flit_type;
  signal noc6_dummy_out_void  : std_ulogic;

begin  -- rtl

  fifo_rst <= rst;                  --FIFO rst active low

  -- To noc1: coherence requests from CPU to directory (GET/PUT)
  noc1_out_stop         <= '0';
  noc1_in_data          <= coherence_req_data_out;
  noc1_in_void          <= coherence_req_empty or noc1_in_stop;
  coherence_req_rdreq   <= (not coherence_req_empty) and (not noc1_in_stop);
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


  -- From noc2: coherence forwarded messages to CPU (INV)
  -- From noc2: coherence forwarded messages to CPU (PUT_ACK)
  noc2_in_data <= (others => '0');
  noc2_in_void <= '1';
  noc2_msg_type <= get_msg_type(noc2_out_data);
  noc2_preamble <= get_preamble(noc2_out_data);
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      noc2_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      noc2_fifos_current <= noc2_fifos_next;
    end if;
  end process;
  noc2_fifos_get_packet: process (noc2_out_data, noc2_out_void, noc2_msg_type,
                                  noc2_preamble, coherence_fwd_inv_full,
                                  coherence_fwd_put_ack_full, noc2_fifos_current)
  begin  -- process noc2_get_packet
    coherence_fwd_inv_wrreq <= '0';
    coherence_fwd_put_ack_wrreq <= '0';
    noc2_fifos_next <= noc2_fifos_current;
    noc2_out_stop <= '0';

    case noc2_fifos_current is
      when none => if noc2_out_void = '0' then
                     if (noc2_msg_type = FWD_INV and noc2_preamble = PREAMBLE_HEADER) then
                       coherence_fwd_inv_wrreq <= not coherence_fwd_inv_full;
                       if coherence_fwd_inv_full = '0' then
                         noc2_fifos_next <= packet_inv;
                       else
                         noc2_out_stop <= '1';
                       end if;
                     elsif (noc2_msg_type = FWD_PUT_ACK and noc2_preamble = PREAMBLE_1FLIT) then
                       coherence_fwd_put_ack_wrreq <= not coherence_fwd_put_ack_full;
                       noc2_out_stop <= coherence_fwd_put_ack_full;
                     end if;
                   end if;

      when packet_inv => coherence_fwd_inv_wrreq <= (not noc2_out_void) and (not coherence_fwd_inv_full);
                         noc2_out_stop <= coherence_fwd_inv_full and (not noc2_out_void);
                         if (noc2_preamble = PREAMBLE_TAIL and noc2_out_void = '0' and
                             coherence_fwd_inv_full = '0') then
                           noc2_fifos_next <= none;
                         end if;

      when others => noc2_fifos_next <= none;
    end case;
  end process noc2_fifos_get_packet;

  coherence_fwd_inv_data_in <= noc2_out_data;
  fifo_2: fifo
    generic map (
      depth => 2,                       --Header, address
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_fwd_inv_rdreq,
      wrreq    => coherence_fwd_inv_wrreq,
      data_in  => coherence_fwd_inv_data_in,
      empty    => coherence_fwd_inv_empty,
      full     => coherence_fwd_inv_full,
      data_out => coherence_fwd_inv_data_out);

  coherence_fwd_put_ack_data_in <= noc2_out_data;
  fifo_3: fifo
    generic map (
      depth => 1,                       --Header only
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_fwd_put_ack_rdreq,
      wrreq    => coherence_fwd_put_ack_wrreq,
      data_in  => coherence_fwd_put_ack_data_in,
      empty    => coherence_fwd_put_ack_empty,
      full     => coherence_fwd_put_ack_full,
      data_out => coherence_fwd_put_ack_data_out);


  -- From noc3: coherence response messages to CPU (LINE)
  -- From noc3: coherence response messages to CPU (INV_ACK rcv)
  noc3_msg_type <= get_msg_type(noc3_out_data);
  noc3_preamble <= get_preamble(noc3_out_data);
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      noc3_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      noc3_fifos_current <= noc3_fifos_next;
    end if;
  end process;
  noc3_fifos_get_packet: process (noc3_out_data, noc3_out_void, noc3_msg_type,
                                  noc3_preamble, coherence_rsp_inv_ack_rcv_full,
                                  coherence_rsp_line_full, noc3_fifos_current)
  begin  -- process noc3_get_packet
    coherence_rsp_line_wrreq <= '0';
    coherence_rsp_inv_ack_rcv_wrreq <= '0';
    noc3_fifos_next <= noc3_fifos_current;
    noc3_out_stop <= '0';

    case noc3_fifos_current is
      when none => if noc3_out_void = '0' then
                     if (noc3_msg_type = RSP_DATA and noc3_preamble = PREAMBLE_HEADER) then
                       coherence_rsp_line_wrreq <= not coherence_rsp_line_full;
                       if coherence_rsp_line_full = '0' then
                         noc3_fifos_next <= packet_line;
                       else
                         noc3_out_stop <= '1';
                       end if;
                     elsif (noc3_msg_type = RSP_INV_ACK and noc3_preamble = PREAMBLE_1FLIT) then
                       coherence_rsp_inv_ack_rcv_wrreq <= not coherence_rsp_inv_ack_rcv_full;
                       noc3_out_stop <= coherence_rsp_inv_ack_rcv_full;
                     end if;
                   end if;

      when packet_line => coherence_rsp_line_wrreq <= (not noc3_out_void) and (not coherence_rsp_line_full);
                          noc3_out_stop <= coherence_rsp_line_full and (not noc3_out_void);
                          if noc3_preamble = PREAMBLE_TAIL and noc3_out_void = '0' and
                             coherence_rsp_line_full = '0' then
                            noc3_fifos_next <= none;
                          end if;

      when others => noc3_fifos_next <= none;
    end case;
  end process noc3_fifos_get_packet;

  coherence_rsp_line_data_in <= noc3_out_data;
  fifo_4: fifo
    generic map (
      depth => 5,                       --Header (use RESERVED field to
                                        --determine  ACK number), cache line
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_rsp_line_rdreq,
      wrreq    => coherence_rsp_line_wrreq,
      data_in  => coherence_rsp_line_data_in,
      empty    => coherence_rsp_line_empty,
      full     => coherence_rsp_line_full,
      data_out => coherence_rsp_line_data_out);

  coherence_rsp_inv_ack_rcv_data_in <= noc3_out_data;
  fifo_5: fifo
    generic map (
      depth => 1,                       --Header only
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_rsp_inv_ack_rcv_rdreq,
      wrreq    => coherence_rsp_inv_ack_rcv_wrreq,
      data_in  => coherence_rsp_inv_ack_rcv_data_in,
      empty    => coherence_rsp_inv_ack_rcv_empty,
      full     => coherence_rsp_inv_ack_rcv_full,
      data_out => coherence_rsp_inv_ack_rcv_data_out);


  -- To noc3: coherence response messages from CPU (INV_ACK snd)
  noc3_in_data <= coherence_rsp_inv_ack_snd_data_out;
  noc3_in_void <= coherence_rsp_inv_ack_snd_empty or noc3_in_stop;
  coherence_rsp_inv_ack_snd_rdreq <= (not coherence_rsp_inv_ack_snd_empty) and (not noc3_in_stop);
  fifo_6: fifo
    generic map (
      depth => 1,                       --Header only
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_rsp_inv_ack_snd_rdreq,
      wrreq    => coherence_rsp_inv_ack_snd_wrreq,
      data_in  => coherence_rsp_inv_ack_snd_data_in,
      empty    => coherence_rsp_inv_ack_snd_empty,
      full     => coherence_rsp_inv_ack_snd_full,
      data_out => coherence_rsp_inv_ack_snd_data_out);


  -- From noc5: remote APB response to core (APB rcv)
  -- From noc5: remove AHB master request to DSU (AHBM rcv)
  -- From noc5: IRQ
  noc5_msg_type <= get_msg_type(noc5_out_data);
  noc5_preamble <= get_preamble(noc5_out_data);
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
                                  remote_ahbm_rcv_full, remote_irq_full,
                                  noc5_fifos_current)
  begin  -- process noc5_get_packet
    remote_apb_rcv_wrreq <= '0';
    remote_ahbm_rcv_wrreq <= '0';
    remote_irq_wrreq <= '0';
    noc5_fifos_next <= noc5_fifos_current;
    noc5_out_stop <= '0';

    case noc5_fifos_current is
      when none => if noc5_out_void = '0' then
                     if (noc5_msg_type = RSP_REG_RD and noc5_preamble = PREAMBLE_HEADER) then
                       remote_apb_rcv_wrreq <= not remote_apb_rcv_full;
                       if remote_apb_rcv_full = '0' then
                         noc5_fifos_next <= packet_apb_rcv;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     elsif ((noc5_msg_type = AHB_RD or noc5_msg_type = AHB_WR)
                            and noc5_preamble = PREAMBLE_HEADER) then
                       remote_ahbm_rcv_wrreq <= not remote_ahbm_rcv_full;
                       if remote_ahbm_rcv_full = '0' then
                         noc5_fifos_next <= packet_ahbm_rcv;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     elsif (noc5_msg_type = IRQ_MSG and noc5_preamble = PREAMBLE_HEADER) then
                       remote_irq_wrreq <= not remote_irq_full;
                       if remote_irq_full = '0' then
                         noc5_fifos_next <= packet_irq;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     end if;
                   end if;

      when packet_apb_rcv => remote_apb_rcv_wrreq <= (not noc5_out_void) and (not remote_apb_rcv_full);
                             noc5_out_stop <= remote_apb_rcv_full and (not noc5_out_void);
                             if noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                             remote_apb_rcv_full = '0' then
                               noc5_fifos_next <= none;
                             end if;

      when packet_ahbm_rcv => remote_ahbm_rcv_wrreq <= not noc5_out_void and (not remote_ahbm_rcv_full);
                             noc5_out_stop <= remote_ahbm_rcv_full and (not noc5_out_void);
                             if noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                             remote_ahbm_rcv_full = '0' then
                               noc5_fifos_next <= none;
                             end if;

      when packet_irq => remote_irq_wrreq <= not noc5_out_void and (not remote_irq_full);
                             noc5_out_stop <= remote_irq_full and (not noc5_out_void);
                             if noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                             remote_irq_full = '0' then
                               noc5_fifos_next <= none;
                             end if;

      when others => noc5_fifos_next <= none;
    end case;
  end process noc5_fifos_get_packet;

  remote_apb_rcv_data_in <= noc5_out_data;
  fifo_7: fifo
    generic map (
      depth => 2,                       --Header, data
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

  remote_ahbm_rcv_data_in <= noc5_out_data;
  fifo_8: fifo
    generic map (
      depth => 6,                       --Header, address, data up to 4 words
                                        --per packet
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_ahbm_rcv_rdreq,
      wrreq    => remote_ahbm_rcv_wrreq,
      data_in  => remote_ahbm_rcv_data_in,
      empty    => remote_ahbm_rcv_empty,
      full     => remote_ahbm_rcv_full,
      data_out => remote_ahbm_rcv_data_out);

  remote_irq_data_in <= noc5_out_data;
  fifo_9: fifo
    generic map (
      depth => 2,                       --Header, irq level
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_irq_rdreq,
      wrreq    => remote_irq_wrreq,
      data_in  => remote_irq_data_in,
      empty    => remote_irq_empty,
      full     => remote_irq_full,
      data_out => remote_irq_data_out);

  -- To noc5: remote APB request from core (APB snd)
  -- To noc5: remote AHB master response from DSU (AHBM snd) - CPU0 tile only
  -- To noc5: remote irq acknowledge response from CPU (IRQ)
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
                                  remote_ahbm_snd_data_out, remote_ahbm_snd_empty,
                                  remote_irq_ack_data_out, remote_irq_ack_empty)
    variable to_noc5_preamble : noc_preamble_type;
  begin  -- process to_noc5_select_packet
    noc5_in_data <= (others => '0');
    noc5_in_void <= '1';
    remote_apb_snd_rdreq <= '0';
    remote_ahbm_snd_rdreq <= '0';
    remote_irq_ack_rdreq <= '0';
    to_noc5_fifos_next <= to_noc5_fifos_current;
    to_noc5_preamble := "00";

    case to_noc5_fifos_current is
      when none  => if remote_irq_ack_empty = '0' then
                      if noc5_in_stop = '0' then
                        noc5_in_Data <= remote_irq_ack_data_out;
                        noc5_in_void <= remote_irq_ack_empty;
                        remote_irq_ack_rdreq <= '1';
                        to_noc5_fifos_next <= packet_irq_ack;
                      end if;
                    elsif remote_apb_snd_empty = '0' then
                      if noc5_in_stop = '0' then
                        noc5_in_data <= remote_apb_snd_data_out;
                        noc5_in_void <= remote_apb_snd_empty;
                        remote_apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_apb_snd;
                      end if;
                    elsif remote_ahbm_snd_empty = '0' then
                      if noc5_in_stop = '0' then
                        noc5_in_data <= remote_ahbm_snd_data_out;
                        noc5_in_void <= remote_ahbm_snd_empty;
                        remote_ahbm_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_ahbm_snd;
                      end if;
                    end if;

      when packet_apb_snd => to_noc5_preamble := get_preamble(remote_apb_snd_data_out);
                             if (noc5_in_stop = '0' and remote_apb_snd_empty = '0') then
                               noc5_in_data <= remote_apb_snd_data_out;
                               noc5_in_void <= remote_apb_snd_empty;
                               remote_apb_snd_rdreq <= not noc5_in_stop;
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_ahbm_snd => to_noc5_preamble := get_preamble(remote_ahbm_snd_data_out);
                              if (noc5_in_stop = '0' and remote_ahbm_snd_empty = '0') then
                                noc5_in_data <= remote_ahbm_snd_data_out;
                                noc5_in_void <= remote_ahbm_snd_empty;
                                remote_ahbm_snd_rdreq <= not noc5_in_stop;
                                if to_noc5_preamble = PREAMBLE_TAIL then
                                  to_noc5_fifos_next <= none;
                                end if;
                              end if;

      when packet_irq_ack  => to_noc5_preamble := get_preamble(remote_irq_ack_data_out);
                              if (noc5_in_stop = '0' and remote_irq_ack_empty = '0') then
                                noc5_in_data <= remote_irq_ack_data_out;
                                noc5_in_void <= remote_irq_ack_empty;
                                remote_irq_ack_rdreq <= not noc5_in_stop;
                                if to_noc5_preamble = PREAMBLE_TAIL then
                                  to_noc5_fifos_next <= none;
                                end if;
                              end if;

      when others => to_noc5_fifos_next <= none;
    end case;
  end process to_noc5_select_packet;

  fifo_10: fifo
    generic map (
      depth => 3,                       --Header, address, data (1 word)
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
      depth => 5,                       --Header, data (up to 4 words)
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_ahbm_snd_rdreq,
      wrreq    => remote_ahbm_snd_wrreq,
      data_in  => remote_ahbm_snd_data_in,
      empty    => remote_ahbm_snd_empty,
      full     => remote_ahbm_snd_full,
      data_out => remote_ahbm_snd_data_out);

  fifo_12: fifo
    generic map (
      depth => 2,                       --Header, irq info
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_irq_ack_rdreq,
      wrreq    => remote_irq_ack_wrreq,
      data_in  => remote_irq_ack_data_in,
      empty    => remote_irq_ack_empty,
      full     => remote_irq_ack_full,
      data_out => remote_irq_ack_data_out);


  -- noc4 does not interact with CPU tiles
  noc4_dummy_out_data <= noc4_out_data;
  noc4_dummy_out_void <= noc4_out_void;
  noc4_out_stop <= '0';
  noc4_in_data <= (others => '0');
  noc4_in_void <= '1';
  noc4_dummy_in_stop <= noc4_in_stop;
  -- noc6 does not interact with CPU tiles
  noc6_dummy_out_data <= noc6_out_data;
  noc6_dummy_out_void <= noc6_out_void;
  noc6_out_stop <= '0';
  noc6_in_data <= (others => '0');
  noc6_in_void <= '1';
  noc6_dummy_in_stop <= noc6_in_stop;

end rtl;
