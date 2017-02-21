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
-- Entity:  mem_q2bus
-- File:    mem_q2bus.vhd
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

entity mem_q2bus is
  generic (
    tech        : integer := virtex7);
  port (
    rst                              : in  std_ulogic;
    clk                              : in  std_ulogic;
    -- chip->FPGA
    remote_ahbs_rcv_rdreq            : out  std_ulogic;
    remote_ahbs_rcv_data_out         : in   noc_flit_type;
    remote_ahbs_rcv_empty            : in   std_ulogic;
    -- FPGA->chip
    remote_ahbs_snd_wrreq            : out std_ulogic;
    remote_ahbs_snd_data_in          : out noc_flit_type;
    remote_ahbs_snd_full             : in  std_ulogic;
    -- chip->FPGA
    remote_apb_rcv_rdreq             : out std_ulogic;
    remote_apb_rcv_data_out          : in  noc_flit_type;
    remote_apb_rcv_empty             : in  std_ulogic;
    -- FPGA->chip
    remote_apb_snd_wrreq             : out std_ulogic;
    remote_apb_snd_data_in           : out noc_flit_type;
    remote_apb_snd_full              : in  std_ulogic;
    -- chip->FPGA
    coherence_req_rdreq              : out std_ulogic;
    coherence_req_data_out           : in  noc_flit_type;
    coherence_req_empty              : in  std_ulogic;
    -- FPGA->chip
    coherence_rsp_line_wrreq         : out std_ulogic;
    coherence_rsp_line_data_in       : out noc_flit_type;
    coherence_rsp_line_full          : in  std_ulogic;
    -- chip->FPGA
    dma_rcv_rdreq             : out std_ulogic;
    dma_rcv_data_out          : in  noc_flit_type;
    dma_rcv_empty             : in  std_ulogic;
    -- FPGA->chip
    dma_snd_wrreq             : out std_ulogic;
    dma_snd_data_in           : out noc_flit_type;
    dma_snd_full              : in  std_ulogic;

    -- Off chip bus
    noc_id_out   : out std_logic_vector(1 downto 0);
    noc_id_in    : in  std_logic_vector(1 downto 0);
    bus_out_data : out noc_flit_type;
    bus_out_void : out std_ulogic;
    bus_out_stop : in  std_ulogic;
    bus_in_data  : in  noc_flit_type;
    bus_in_void  : in  std_ulogic;
    bus_in_stop  : out std_ulogic);

end mem_q2bus;

architecture rtl of mem_q2bus is

  signal fifo_rst : std_ulogic;


  type to_bus_packet_fsm is (none, packet_apb_rcv, packet_coherence_req, packet_dma_rcv, packet_ahbs_rcv);
  type bus_packet_fsm is (none, packet_apb_snd, packet_coherence_rsp_line, packet_dma_snd, packet_ahbs_snd);
  signal bus_fifos_current, bus_fifos_next : bus_packet_fsm;
  signal to_bus_fifos_current, to_bus_fifos_next : to_bus_packet_fsm;

  signal bus_msg_type : noc_msg_type;
  signal bus_preamble : noc_preamble_type;

begin  -- rtl

  fifo_rst <= rst;                  --FIFO rst active low

  bus_msg_type <= get_msg_type(bus_in_data);
  bus_preamble <= get_preamble(bus_in_data);
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      bus_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      bus_fifos_current <= bus_fifos_next;
    end if;
  end process;
  bus_fifos_get_packet: process (bus_in_data, bus_in_void, bus_msg_type,
                                 bus_preamble, remote_apb_snd_full,
                                 coherence_rsp_line_full, dma_snd_full,
                                 remote_ahbs_snd_full, bus_fifos_current,
                                 noc_id_in)
  begin  -- process bus_get_packet
    remote_apb_snd_wrreq <= '0';
    coherence_rsp_line_wrreq <= '0';
    dma_snd_wrreq <= '0';
    remote_ahbs_snd_wrreq <= '0';
    bus_fifos_next <= bus_fifos_current;
    bus_in_stop <= '0';

    case bus_fifos_current is
      when none => if bus_in_void = '0' then
                     if (noc_id_in = ROUTE_NOC5 and
                         ((bus_msg_type = REQ_REG_RD or bus_msg_type = REQ_REG_WR) and
                          bus_preamble = PREAMBLE_HEADER)) then
                       remote_apb_snd_wrreq <= not remote_apb_snd_full;
                       if remote_apb_snd_full = '0' then
                         bus_fifos_next <= packet_apb_snd;
                       else
                         bus_in_stop <= '1';
                       end if;
                     elsif ((noc_id_in = ROUTE_NOC3 and
                             (is_gets(bus_msg_type) or is_getm(bus_msg_type)))
                            and bus_preamble = PREAMBLE_HEADER) then
                       coherence_rsp_line_wrreq <= not coherence_rsp_line_full;
                       if coherence_rsp_line_full = '0' then
                         bus_fifos_next <= packet_coherence_rsp_line;
                       else
                         bus_in_stop <= '1';
                       end if;
                     elsif (noc_id_in = ROUTE_NOC4 and
                            ((bus_msg_type = DMA_TO_DEV or bus_msg_type = DMA_FROM_DEV)
                            and bus_preamble = PREAMBLE_HEADER)) then
                       dma_snd_wrreq <= not dma_snd_full;
                       if dma_snd_full = '0' then
                         bus_fifos_next <= packet_dma_snd;
                       else
                         bus_in_stop <= '1';
                       end if;
                     elsif (noc_id_in = ROUTE_NOC5 and
                            ((bus_msg_type = AHB_RD or bus_msg_type = AHB_WR)
                             and bus_preamble = PREAMBLE_HEADER)) then
                       remote_ahbs_snd_wrreq <= not remote_ahbs_snd_full;
                       if remote_ahbs_snd_full = '0' then
                         bus_fifos_next <= packet_ahbs_snd;
                       else
                         bus_in_stop <= '1';
                       end if;
                     end if;
                   end if;

      when packet_apb_snd => remote_apb_snd_wrreq <= (not bus_in_void) and (not remote_apb_snd_full);
                             bus_in_stop <= remote_apb_snd_full and (not bus_in_void);
                             if (bus_preamble = PREAMBLE_TAIL and bus_in_void = '0' and
                                 remote_apb_snd_full = '0') then
                               bus_fifos_next <= none;
                             end if;

      when packet_coherence_rsp_line => coherence_rsp_line_wrreq <= (not bus_in_void) and (not coherence_rsp_line_full);
                             bus_in_stop <= coherence_rsp_line_full and (not bus_in_void);
                             if (bus_preamble = PREAMBLE_TAIL and bus_in_void = '0' and
                                 coherence_rsp_line_full = '0') then
                               bus_fifos_next <= none;
                             end if;

     when packet_dma_snd => dma_snd_wrreq <= (not bus_in_void) and (not dma_snd_full);
                             bus_in_stop <= dma_snd_full and (not bus_in_void);
                             if (bus_preamble = PREAMBLE_TAIL and bus_in_void = '0' and
                                 dma_snd_full = '0') then
                               bus_fifos_next <= none;
                             end if;

     when packet_ahbs_snd => remote_ahbs_snd_wrreq <= (not bus_in_void) and (not remote_ahbs_snd_full);
                             bus_in_stop <= remote_ahbs_snd_full and (not bus_in_void);
                             if (bus_preamble = PREAMBLE_TAIL and bus_in_void = '0' and
                                 remote_ahbs_snd_full = '0') then
                               bus_fifos_next <= none;
                             end if;

     when others => bus_fifos_next <= none;
    end case;
  end process bus_fifos_get_packet;

  remote_apb_snd_data_in <= bus_in_data;

  coherence_rsp_line_data_in <= bus_in_data;

  dma_snd_data_in <= bus_in_data;

  remote_ahbs_snd_data_in <= bus_in_data;


  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      to_bus_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      to_bus_fifos_current <= to_bus_fifos_next;
    end if;
  end process;

  to_bus_select_packet: process (bus_out_stop, to_bus_fifos_current,
                                 remote_apb_rcv_data_out, remote_apb_rcv_empty,
                                 coherence_req_data_out, coherence_req_empty,
                                 dma_rcv_data_out, dma_rcv_empty,
                                 remote_ahbs_rcv_data_out, remote_ahbs_rcv_empty)
    variable to_bus_preamble : noc_preamble_type;
  begin  -- process to_bus_select_packet
    noc_id_out <= (others => '0');
    bus_out_data <= (others => '0');
    bus_out_void <= '1';
    remote_apb_rcv_rdreq <= '0';
    coherence_req_rdreq <= '0';
    dma_rcv_rdreq <= '0';
    remote_ahbs_rcv_rdreq <= '0';
    to_bus_fifos_next <= to_bus_fifos_current;
    to_bus_preamble := "00";

    case to_bus_fifos_current is
      when none  => if remote_apb_rcv_empty = '0' then
                      if bus_out_stop = '0' then
                        noc_id_out <= ROUTE_NOC5;
                        bus_out_data <= remote_apb_rcv_data_out;
                        bus_out_void <= remote_apb_rcv_empty;
                        remote_apb_rcv_rdreq <= '1';
                        to_bus_fifos_next <= packet_apb_rcv;
                      end if;
                    elsif coherence_req_empty = '0' then
                      if bus_out_stop = '0' then
                        noc_id_out <= ROUTE_NOC3;
                        bus_out_data <= coherence_req_data_out;
                        bus_out_void <= coherence_req_empty;
                        coherence_req_rdreq <= '1';
                        to_bus_fifos_next <= packet_coherence_req;
                      end if;
                    elsif dma_rcv_empty = '0' then
                      if bus_out_stop = '0' then
                        noc_id_out <= ROUTE_NOC4;
                        bus_out_data <= dma_rcv_data_out;
                        bus_out_void <= dma_rcv_empty;
                        dma_rcv_rdreq <= '1';
                        to_bus_fifos_next <= packet_dma_rcv;
                      end if;
                    elsif remote_ahbs_rcv_empty = '0' then
                      if bus_out_stop = '0' then
                        noc_id_out <= ROUTE_NOC5;
                        bus_out_data <= remote_ahbs_rcv_data_out;
                        bus_out_void <= remote_ahbs_rcv_empty;
                        remote_ahbs_rcv_rdreq <= '1';
                        to_bus_fifos_next <= packet_ahbs_rcv;
                      end if;
                    end if;

      when packet_apb_rcv => to_bus_preamble := get_preamble(remote_apb_rcv_data_out);
                             noc_id_out <= ROUTE_NOC5;
                             if (bus_out_stop = '0' and remote_apb_rcv_empty = '0') then
                               bus_out_data <= remote_apb_rcv_data_out;
                               bus_out_void <= remote_apb_rcv_empty;
                               remote_apb_rcv_rdreq <= not bus_out_stop;
                               if to_bus_preamble = PREAMBLE_TAIL then
                                 to_bus_fifos_next <= none;
                               end if;
                             end if;

      when packet_coherence_req => to_bus_preamble := get_preamble(coherence_req_data_out);
                                   noc_id_out <= ROUTE_NOC3;
                                   if (bus_out_stop = '0' and coherence_req_empty = '0') then
                                     bus_out_data <= coherence_req_data_out;
                                     bus_out_void <= coherence_req_empty;
                                     coherence_req_rdreq <= not bus_out_stop;
                                     if to_bus_preamble = PREAMBLE_TAIL then
                                       to_bus_fifos_next <= none;
                                     end if;
                                   end if;

      when packet_dma_rcv  => to_bus_preamble := get_preamble(dma_rcv_data_out);
                              noc_id_out <= ROUTE_NOC4;
                              if (bus_out_stop = '0' and dma_rcv_empty = '0') then
                                bus_out_data <= dma_rcv_data_out;
                                bus_out_void <= dma_rcv_empty;
                                dma_rcv_rdreq <= not bus_out_stop;
                                if to_bus_preamble = PREAMBLE_TAIL then
                                  to_bus_fifos_next <= none;
                                end if;
                              end if;

      when packet_ahbs_rcv  => to_bus_preamble := get_preamble(remote_ahbs_rcv_data_out);
                               noc_id_out <= ROUTE_NOC5;
                               if (bus_out_stop = '0' and remote_ahbs_rcv_empty = '0') then
                                 bus_out_data <= remote_ahbs_rcv_data_out;
                                 bus_out_void <= remote_ahbs_rcv_empty;
                                 remote_ahbs_rcv_rdreq <= not bus_out_stop;
                                 if to_bus_preamble = PREAMBLE_TAIL then
                                   to_bus_fifos_next <= none;
                                 end if;
                               end if;

      when others => to_bus_fifos_next <= none;
    end case;
  end process to_bus_select_packet;


end rtl;
