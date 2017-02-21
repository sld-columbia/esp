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
-- Entity:  fpga_q
-- File:    fpga_q.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description:	FIFO queues for the CPU tile.
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

entity fpga_q is
  generic (
    tech        : integer := virtex7);
  port (
    rst                              : in  std_ulogic;
    clk                              : in  std_ulogic;
    -- chip->FPGA
    remote_ahbs_rcv_rdreq            : in  std_ulogic;
    remote_ahbs_rcv_data_out         : out noc_flit_type;
    remote_ahbs_rcv_empty            : out std_ulogic;
    -- FPGA->chip
    remote_ahbs_snd_wrreq            : in  std_ulogic;
    remote_ahbs_snd_data_in          : in  noc_flit_type;
    remote_ahbs_snd_full             : out std_ulogic;
    -- chip->FPGA
    remote_apb_rcv_rdreq             : in  std_ulogic;
    remote_apb_rcv_data_out          : out noc_flit_type;
    remote_apb_rcv_empty             : out std_ulogic;
    -- FPGA->chip
    remote_apb_snd_wrreq             : in  std_ulogic;
    remote_apb_snd_data_in           : in  noc_flit_type;
    remote_apb_snd_full              : out std_ulogic;
    -- chip->FPGA
    coherence_req_rdreq              : in  std_ulogic;
    coherence_req_data_out           : out noc_flit_type;
    coherence_req_empty              : out std_ulogic;
    -- FPGA->chip
    coherence_rsp_line_wrreq         : in  std_ulogic;
    coherence_rsp_line_data_in       : in  noc_flit_type;
    coherence_rsp_line_full           : out std_ulogic;
    -- chip->FPGA
    dma_rcv_rdreq             : in  std_ulogic;
    dma_rcv_data_out          : out noc_flit_type;
    dma_rcv_empty             : out std_ulogic;
    -- FPGA->chip
    dma_snd_wrreq             : in  std_ulogic;
    dma_snd_data_in           : in  noc_flit_type;
    dma_snd_full              : out std_ulogic;
    dma_snd_atleast_4slots    : out std_ulogic;
    dma_snd_exactly_3slots    : out std_ulogic;

    -- Off chip bus
    noc_id_out   : in  std_logic_vector(1 downto 0);
    noc_id_in    : out std_logic_vector(1 downto 0);
    bus_out_data : in  noc_flit_type;
    bus_out_void : in  std_ulogic;
    bus_out_stop : out std_ulogic;
    bus_in_data  : out noc_flit_type;
    bus_in_void  : out std_ulogic;
    bus_in_stop  : in  std_ulogic);

end fpga_q;

architecture rtl of fpga_q is

  signal fifo_rst : std_ulogic;

  signal remote_ahbs_snd_rdreq                 : std_ulogic;
  signal remote_ahbs_snd_data_out              : noc_flit_type;
  signal remote_ahbs_snd_empty                 : std_ulogic;
  signal remote_ahbs_rcv_wrreq            : std_ulogic;
  signal remote_ahbs_rcv_data_in          : noc_flit_type;
  signal remote_ahbs_rcv_full             : std_ulogic;
  signal remote_apb_rcv_wrreq                : std_ulogic;
  signal remote_apb_rcv_data_in              : noc_flit_type;
  signal remote_apb_rcv_full                 : std_ulogic;
  signal remote_apb_snd_rdreq                : std_ulogic;
  signal remote_apb_snd_data_out             : noc_flit_type;
  signal remote_apb_snd_empty                : std_ulogic;
  signal coherence_req_wrreq               : std_ulogic;
  signal coherence_req_data_in             : noc_flit_type;
  signal coherence_req_full                : std_ulogic;
  signal coherence_rsp_line_rdreq               : std_ulogic;
  signal coherence_rsp_line_data_out            : noc_flit_type;
  signal coherence_rsp_line_empty               : std_ulogic;
  signal dma_rcv_wrreq                : std_ulogic;
  signal dma_rcv_data_in              : noc_flit_type;
  signal dma_rcv_full                 : std_ulogic;
  signal dma_snd_rdreq                : std_ulogic;
  signal dma_snd_data_out             : noc_flit_type;
  signal dma_snd_empty                : std_ulogic;

  type bus_packet_fsm is (none, packet_apb_rcv, packet_coherence_req, packet_dma_rcv, packet_ahbs_rcv);
  type to_bus_packet_fsm is (none, packet_apb_snd, packet_coherence_rsp_line, packet_dma_snd, packet_ahbs_snd);
  signal bus_fifos_current, bus_fifos_next : bus_packet_fsm;
  signal to_bus_fifos_current, to_bus_fifos_next : to_bus_packet_fsm;

  signal bus_msg_type : noc_msg_type;
  signal bus_preamble : noc_preamble_type;

begin  -- rtl

  fifo_rst <= rst;                  --FIFO rst active low

  bus_msg_type <= get_msg_type(bus_out_data);
  bus_preamble <= get_preamble(bus_out_data);
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      bus_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      bus_fifos_current <= bus_fifos_next;
    end if;
  end process;
  bus_fifos_get_packet: process (bus_out_data, bus_out_void, bus_msg_type,
                                 bus_preamble, remote_apb_rcv_full,
                                 coherence_req_full, dma_rcv_full,
                                 remote_ahbs_rcv_full, bus_fifos_current,
                                 noc_id_out)
  begin  -- process bus_get_packet
    remote_apb_rcv_wrreq <= '0';
    coherence_req_wrreq <= '0';
    dma_rcv_wrreq <= '0';
    remote_ahbs_rcv_wrreq <= '0';
    bus_fifos_next <= bus_fifos_current;
    bus_out_stop <= '0';

    case bus_fifos_current is
      when none => if bus_out_void = '0' then
                     if (noc_id_out = ROUTE_NOC5 and
                         (bus_msg_type = RSP_REG_RD and bus_preamble = PREAMBLE_HEADER)) then
                       remote_apb_rcv_wrreq <= not remote_apb_rcv_full;
                       if remote_apb_rcv_full = '0' then
                         bus_fifos_next <= packet_apb_rcv;
                       else
                         bus_out_stop <= '1';
                       end if;
                     elsif (noc_id_out = ROUTE_NOC3 and
                            ((is_gets(bus_msg_type) or is_getm(bus_msg_type))
                            and bus_preamble = PREAMBLE_HEADER)) then
                       coherence_req_wrreq <= not coherence_req_full;
                       if coherence_req_full = '0' then
                         bus_fifos_next <= packet_coherence_req;
                       else
                         bus_out_stop <= '1';
                       end if;
                     elsif (noc_id_out = ROUTE_NOC4 and
                            ((bus_msg_type = DMA_TO_DEV or bus_msg_type = DMA_FROM_DEV)
                            and bus_preamble = PREAMBLE_HEADER)) then
                       dma_rcv_wrreq <= not dma_rcv_full;
                       if dma_rcv_full = '0' then
                         bus_fifos_next <= packet_dma_rcv;
                       else
                         bus_out_stop <= '1';
                       end if;
                     elsif (noc_id_out = ROUTE_NOC5 and
                            (bus_msg_type = AHB_RD and bus_preamble = PREAMBLE_HEADER)) then
                       remote_ahbs_rcv_wrreq <= not remote_ahbs_rcv_full;
                       if remote_ahbs_rcv_full = '0' then
                         bus_fifos_next <= packet_ahbs_rcv;
                       else
                         bus_out_stop <= '1';
                       end if;
                     end if;
                   end if;

      when packet_apb_rcv => remote_apb_rcv_wrreq <= (not bus_out_void) and (not remote_apb_rcv_full);
                             bus_out_stop <= remote_apb_rcv_full and (not bus_out_void);
                             if (bus_preamble = PREAMBLE_TAIL and bus_out_void = '0' and
                                 remote_apb_rcv_full = '0') then
                               bus_fifos_next <= none;
                             end if;

      when packet_coherence_req => coherence_req_wrreq <= (not bus_out_void) and (not coherence_req_full);
                             bus_out_stop <= coherence_req_full and (not bus_out_void);
                             if (bus_preamble = PREAMBLE_TAIL and bus_out_void = '0' and
                                 coherence_req_full = '0') then
                               bus_fifos_next <= none;
                             end if;

     when packet_dma_rcv => dma_rcv_wrreq <= (not bus_out_void) and (not dma_rcv_full);
                             bus_out_stop <= dma_rcv_full and (not bus_out_void);
                             if (bus_preamble = PREAMBLE_TAIL and bus_out_void = '0' and
                                 dma_rcv_full = '0') then
                               bus_fifos_next <= none;
                             end if;

     when packet_ahbs_rcv => remote_ahbs_rcv_wrreq <= (not bus_out_void) and (not remote_ahbs_rcv_full);
                             bus_out_stop <= remote_ahbs_rcv_full and (not bus_out_void);
                             if (bus_preamble = PREAMBLE_TAIL and bus_out_void = '0' and
                                 remote_ahbs_rcv_full = '0') then
                               bus_fifos_next <= none;
                             end if;

     when others => bus_fifos_next <= none;
    end case;
  end process bus_fifos_get_packet;

  remote_apb_rcv_data_in <= bus_out_data;
  fifo_2: fifo
    generic map (
      depth => 3,
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

  coherence_req_data_in <= bus_out_data;
  fifo_3: fifo
    generic map (
      depth => 6,
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

  dma_rcv_data_in <= bus_out_data;
  fifo_4: fifo
    generic map (
      depth => 18,
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

  remote_ahbs_rcv_data_in <= bus_out_data;
  fifo_5: fifo
    generic map (
      depth => 18,
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


  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      to_bus_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      to_bus_fifos_current <= to_bus_fifos_next;
    end if;
  end process;

  to_bus_select_packet: process (bus_in_stop, to_bus_fifos_current,
                                 remote_apb_snd_data_out, remote_apb_snd_empty,
                                 coherence_rsp_line_data_out, coherence_rsp_line_empty,
                                 dma_snd_data_out, dma_snd_empty,
                                 remote_ahbs_snd_data_out, remote_ahbs_snd_empty)
    variable to_bus_preamble : noc_preamble_type;
  begin  -- process to_bus_select_packet
    noc_id_in <= (others => '0');
    bus_in_data <= (others => '0');
    bus_in_void <= '1';
    remote_apb_snd_rdreq <= '0';
    coherence_rsp_line_rdreq <= '0';
    dma_snd_rdreq <= '0';
    remote_ahbs_snd_rdreq <= '0';
    to_bus_fifos_next <= to_bus_fifos_current;
    to_bus_preamble := "00";

    case to_bus_fifos_current is
      when none  => if remote_apb_snd_empty = '0' then
                      if bus_in_stop = '0' then
                        noc_id_in <= ROUTE_NOC5;
                        bus_in_data <= remote_apb_snd_data_out;
                        bus_in_void <= remote_apb_snd_empty;
                        remote_apb_snd_rdreq <= '1';
                        to_bus_fifos_next <= packet_apb_snd;
                      end if;
                    elsif coherence_rsp_line_empty = '0' then
                      if bus_in_stop = '0' then
                        noc_id_in <= ROUTE_NOC3;
                        bus_in_data <= coherence_rsp_line_data_out;
                        bus_in_void <= coherence_rsp_line_empty;
                        coherence_rsp_line_rdreq <= '1';
                        to_bus_fifos_next <= packet_coherence_rsp_line;
                      end if;
                    elsif dma_snd_empty = '0' then
                      if bus_in_stop = '0' then
                        noc_id_in <= ROUTE_NOC4;
                        bus_in_data <= dma_snd_data_out;
                        bus_in_void <= dma_snd_empty;
                        dma_snd_rdreq <= '1';
                        to_bus_fifos_next <= packet_dma_snd;
                      end if;
                    elsif remote_ahbs_snd_empty = '0' then
                      if bus_in_stop = '0' then
                        noc_id_in <= ROUTE_NOC5;
                        bus_in_data <= remote_ahbs_snd_data_out;
                        bus_in_void <= remote_ahbs_snd_empty;
                        remote_ahbs_snd_rdreq <= '1';
                        to_bus_fifos_next <= packet_ahbs_snd;
                      end if;
                    end if;

      when packet_apb_snd => to_bus_preamble := get_preamble(remote_apb_snd_data_out);
                             noc_id_in <= ROUTE_NOC5;
                             if (bus_in_stop = '0' and remote_apb_snd_empty = '0') then
                               bus_in_data <= remote_apb_snd_data_out;
                               bus_in_void <= remote_apb_snd_empty;
                               remote_apb_snd_rdreq <= not bus_in_stop;
                               if to_bus_preamble = PREAMBLE_TAIL then
                                 to_bus_fifos_next <= none;
                               end if;
                             end if;

      when packet_coherence_rsp_line => to_bus_preamble := get_preamble(coherence_rsp_line_data_out);
                                        noc_id_in <= ROUTE_NOC3;
                                        if (bus_in_stop = '0' and coherence_rsp_line_empty = '0') then
                                          bus_in_data <= coherence_rsp_line_data_out;
                                          bus_in_void <= coherence_rsp_line_empty;
                                          coherence_rsp_line_rdreq <= not bus_in_stop;
                                          if to_bus_preamble = PREAMBLE_TAIL then
                                            to_bus_fifos_next <= none;
                                          end if;
                                        end if;

      when packet_dma_snd  => to_bus_preamble := get_preamble(dma_snd_data_out);
                              noc_id_in <= ROUTE_NOC4;
                              if (bus_in_stop = '0' and dma_snd_empty = '0') then
                                bus_in_data <= dma_snd_data_out;
                                bus_in_void <= dma_snd_empty;
                                dma_snd_rdreq <= not bus_in_stop;
                                if to_bus_preamble = PREAMBLE_TAIL then
                                  to_bus_fifos_next <= none;
                                end if;
                              end if;

      when packet_ahbs_snd  => to_bus_preamble := get_preamble(remote_ahbs_snd_data_out);
                               noc_id_in <= ROUTE_NOC5;
                               if (bus_in_stop = '0' and remote_ahbs_snd_empty = '0') then
                                 bus_in_data <= remote_ahbs_snd_data_out;
                                 bus_in_void <= remote_ahbs_snd_empty;
                                 remote_ahbs_snd_rdreq <= not bus_in_stop;
                                 if to_bus_preamble = PREAMBLE_TAIL then
                                   to_bus_fifos_next <= none;
                                 end if;
                               end if;

      when others => to_bus_fifos_next <= none;
    end case;
  end process to_bus_select_packet;

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
      rdreq    => coherence_rsp_line_rdreq,
      wrreq    => coherence_rsp_line_wrreq,
      data_in  => coherence_rsp_line_data_in,
      empty    => coherence_rsp_line_empty,
      full     => coherence_rsp_line_full,
      data_out => coherence_rsp_line_data_out);

  fifo_12: fifo2
    generic map (
      depth => 18,
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

  fifo_13: fifo
    generic map (
      depth => 6,
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


end rtl;
