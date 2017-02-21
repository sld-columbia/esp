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
-- Entity:  acc_tile_q
-- File:    acc_tile_q.vhd
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

entity acc_tile_q is
  generic (
    tech        : integer := virtex7);
  port (
    rst                                 : in  std_ulogic;
    clk                                 : in  std_ulogic;
    -- NoC4->tile
    dma_rcv_rdreq                       : in  std_ulogic;
    dma_rcv_data_out                    : out noc_flit_type;
    dma_rcv_empty                       : out std_ulogic;
    -- tile->NoC6
    dma_snd_wrreq                       : in  std_ulogic;
    dma_snd_data_in                     : in  noc_flit_type;
    dma_snd_full                        : out std_ulogic;
    -- NoC5->tile
    apb_rcv_rdreq                       : in  std_ulogic;
    apb_rcv_data_out                    : out noc_flit_type;
    apb_rcv_empty                       : out std_ulogic;
    -- tile->NoC5
    apb_snd_wrreq                       : in  std_ulogic;
    apb_snd_data_in                     : in  noc_flit_type;
    apb_snd_full                        : out std_ulogic;
    -- tile->NoC5
    interrupt_wrreq                           : in  std_ulogic;
    interrupt_data_in                         : in  noc_flit_type;
    interrupt_full                            : out std_ulogic;

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
    -- Non cachable data data plane 6 -> DMA transfers requests
    noc6_out_data : in  noc_flit_type;
    noc6_out_void : in  std_ulogic;
    noc6_out_stop : out std_ulogic;
    noc6_in_data  : out noc_flit_type;
    noc6_in_void  : out std_ulogic;
    noc6_in_stop  : in  std_ulogic);

end acc_tile_q;

architecture rtl of acc_tile_q is

  signal fifo_rst : std_ulogic;

  -- NoC4->tile
  signal dma_rcv_wrreq                       : std_ulogic;
  signal dma_rcv_data_in                     : noc_flit_type;
  signal dma_rcv_full                        : std_ulogic;
  -- tile->NoC6
  signal dma_snd_rdreq                       : std_ulogic;
  signal dma_snd_data_out                    : noc_flit_type;
  signal dma_snd_empty                       : std_ulogic;
  -- NoC5->tile
  signal apb_rcv_wrreq                : std_ulogic;
  signal apb_rcv_data_in              : noc_flit_type;
  signal apb_rcv_full                 : std_ulogic;
  -- tile->NoC5
  signal apb_snd_rdreq                : std_ulogic;
  signal apb_snd_data_out             : noc_flit_type;
  signal apb_snd_empty                : std_ulogic;
  -- tile->Noc5
  signal interrupt_rdreq                    : std_ulogic;
  signal interrupt_data_out                 : noc_flit_type;
  signal interrupt_empty                    : std_ulogic;

  type to_noc5_packet_fsm is (none, packet_apb_snd);
  signal to_noc5_fifos_current, to_noc5_fifos_next : to_noc5_packet_fsm;

  signal noc1_dummy_in_stop   : std_ulogic;
  signal noc1_dummy_out_data  : noc_flit_type;
  signal noc1_dummy_out_void  : std_ulogic;
  signal noc2_dummy_in_stop   : std_ulogic;
  signal noc2_dummy_out_data  : noc_flit_type;
  signal noc2_dummy_out_void  : std_ulogic;
  signal noc3_dummy_in_stop   : std_ulogic;
  signal noc3_dummy_out_data  : noc_flit_type;
  signal noc3_dummy_out_void  : std_ulogic;
  signal noc4_dummy_in_stop   : std_ulogic;
  signal noc6_dummy_out_data  : noc_flit_type;
  signal noc6_dummy_out_void  : std_ulogic;


begin  -- rtl

  fifo_rst <= rst;                  --FIFO rst active low

  -- From noc4: DMA response to accelerators
  noc4_in_data          <= (others => '0');
  noc4_in_void          <= '1';
  noc4_dummy_in_stop    <= noc4_in_stop;
  noc4_out_stop   <= dma_rcv_full and (not noc4_out_void);
  dma_rcv_data_in <= noc4_out_data;
  dma_rcv_wrreq   <= (not noc4_out_void) and (not dma_rcv_full);
  fifo_14: fifo
    generic map (
      depth => 18,                      --Header, [data]
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

  -- To noc6: DMA requests from accelerators
  noc6_out_stop <= '0';
  noc6_dummy_out_data <= noc6_out_data;
  noc6_dummy_out_void <= noc6_out_void;
  noc6_in_data <= dma_snd_data_out;
  noc6_in_void <= dma_snd_empty or noc6_in_stop;
  dma_snd_rdreq <= (not dma_snd_empty) and (not noc6_in_stop);
  fifo_13: fifo
    generic map (
      depth => 18,                      --Header, address, length or data
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => dma_snd_rdreq,
      wrreq    => dma_snd_wrreq,
      data_in  => dma_snd_data_in,
      empty    => dma_snd_empty,
      full     => dma_snd_full,
      data_out => dma_snd_data_out);

  -- From noc5: APB requests from cores
  noc5_out_stop   <= apb_rcv_full and (not noc5_out_void);
  apb_rcv_data_in <= noc5_out_data;
  apb_rcv_wrreq   <= (not noc5_out_void) and (not apb_rcv_full);
  fifo_10: fifo
    generic map (
      depth => 3,                      --Header, address, [data]
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


  -- To noc5: APB response from accelerators
  -- To noc5: interrupts from accelerators
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      to_noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      to_noc5_fifos_current <= to_noc5_fifos_next;
    end if;
  end process;
  noc5_fifos_put_packet: process (noc5_in_stop, to_noc5_fifos_current,
                                  apb_snd_data_out, apb_snd_empty,
                                  interrupt_data_out, interrupt_empty)
    variable to_noc5_preamble : noc_preamble_type;
  begin  -- process noc5_get_packet
    noc5_in_data <= (others => '0');
    noc5_in_void <= '1';
    apb_snd_rdreq <= '0';
    interrupt_rdreq <= '0';
    to_noc5_fifos_next <= to_noc5_fifos_current;
    to_noc5_preamble := "00";

    case to_noc5_fifos_current is
      when none => if apb_snd_empty = '0' then
                     if noc5_in_stop = '0' then
                       noc5_in_data <= apb_snd_data_out;
                       noc5_in_void <= apb_snd_empty;
                       apb_snd_rdreq <= '1';
                       to_noc5_fifos_next <= packet_apb_snd;
                     end if;
                   elsif interrupt_empty = '0' then
                     if noc5_in_stop = '0' then
                       noc5_in_data <= interrupt_data_out;
                       noc5_in_void <= interrupt_empty;
                       interrupt_rdreq <= '1';
                     end if;
                   end if;

      when packet_apb_snd => to_noc5_preamble := get_preamble(apb_snd_data_out);
                             if (noc5_in_stop = '0' and apb_snd_empty = '0') then
                               noc5_in_data <= apb_snd_data_out;
                               noc5_in_void <= apb_snd_empty;
                               apb_snd_rdreq <= not noc5_in_stop;
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when others => to_noc5_fifos_next <= none;
    end case;
  end process noc5_fifos_put_packet;

  fifo_7: fifo
    generic map (
      depth => 2,                       --Header, data (1 Word)
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

  fifo_15: fifo
    generic map (
      depth => 1,                       --Header only x possible sharers
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => interrupt_rdreq,
      wrreq    => interrupt_wrreq,
      data_in  => interrupt_data_in,
      empty    => interrupt_empty,
      full     => interrupt_full,
      data_out => interrupt_data_out);



  -- noc1,2,3 do not interact with misc. tiles
  noc1_dummy_out_data <= noc1_out_data;
  noc1_dummy_out_void <= noc1_out_void;
  noc1_out_stop <= '0';
  noc1_in_data <= (others => '0');
  noc1_in_void <= '1';
  noc1_dummy_in_stop <= noc1_in_stop;

  noc2_dummy_out_data <= noc2_out_data;
  noc2_dummy_out_void <= noc2_out_void;
  noc2_out_stop <= '0';
  noc2_in_data <= (others => '0');
  noc2_in_void <= '1';
  noc2_dummy_in_stop <= noc2_in_stop;

  noc3_dummy_out_data <= noc3_out_data;
  noc3_dummy_out_void <= noc3_out_void;
  noc3_out_stop <= '0';
  noc3_in_data <= (others => '0');
  noc3_in_void <= '1';
  noc3_dummy_in_stop <= noc3_in_stop;

end rtl;
