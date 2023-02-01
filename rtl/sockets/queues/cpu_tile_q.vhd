-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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

entity cpu_tile_q is
  generic (
    tech        : integer := virtex7);
  port (
    rst                        : in  std_ulogic;
    clk                        : in  std_ulogic;
    -- tile->NoC1
    coherence_req_wrreq        : in  std_ulogic;
    coherence_req_data_in      : in  noc_flit_type;
    coherence_req_full         : out std_ulogic;
    -- NoC2->tile
    coherence_fwd_rdreq        : in  std_ulogic;
    coherence_fwd_data_out     : out noc_flit_type;
    coherence_fwd_empty        : out std_ulogic;
    -- Noc3->tile
    coherence_rsp_rcv_rdreq    : in  std_ulogic;
    coherence_rsp_rcv_data_out : out noc_flit_type;
    coherence_rsp_rcv_empty    : out std_ulogic;
    -- tile->Noc3
    coherence_rsp_snd_wrreq    : in  std_ulogic;
    coherence_rsp_snd_data_in  : in  noc_flit_type;
    coherence_rsp_snd_full     : out std_ulogic;
    -- tile->Noc2
    coherence_fwd_snd_wrreq    : in  std_ulogic;
    coherence_fwd_snd_data_in  : in  noc_flit_type;
    coherence_fwd_snd_full     : out std_ulogic;
    -- NoC5->tile
    remote_ahbs_snd_wrreq      : in  std_ulogic;
    remote_ahbs_snd_data_in    : in  misc_noc_flit_type;
    remote_ahbs_snd_full       : out std_ulogic;
    -- NoC4->tile
    dma_rcv_rdreq              : in  std_ulogic;
    dma_rcv_data_out           : out noc_flit_type;
    dma_rcv_empty              : out std_ulogic;
    -- tile->NoC6
    dma_snd_wrreq              : in  std_ulogic;
    dma_snd_data_in            : in  noc_flit_type;
    dma_snd_full               : out std_ulogic;
    -- tile->NoC5
    remote_ahbs_rcv_rdreq      : in  std_ulogic;
    remote_ahbs_rcv_data_out   : out misc_noc_flit_type;
    remote_ahbs_rcv_empty      : out std_ulogic;
    -- NoC5->tile
    apb_rcv_rdreq              : in  std_ulogic;
    apb_rcv_data_out           : out misc_noc_flit_type;
    apb_rcv_empty              : out std_ulogic;
    -- tile->NoC5
    apb_snd_wrreq              : in  std_ulogic;
    apb_snd_data_in            : in  misc_noc_flit_type;
    apb_snd_full               : out std_ulogic;
    -- NoC5->tile
    remote_apb_rcv_rdreq       : in  std_ulogic;
    remote_apb_rcv_data_out    : out misc_noc_flit_type;
    remote_apb_rcv_empty       : out std_ulogic;
    -- tile->NoC5
    remote_apb_snd_wrreq       : in  std_ulogic;
    remote_apb_snd_data_in     : in  misc_noc_flit_type;
    remote_apb_snd_full        : out std_ulogic;
    -- NoC5->tile
    remote_irq_rdreq           : in  std_ulogic;
    remote_irq_data_out        : out misc_noc_flit_type;
    remote_irq_empty           : out std_ulogic;
    -- tile->NoC5
    remote_irq_ack_wrreq       : in  std_ulogic;
    remote_irq_ack_data_in     : in  misc_noc_flit_type;
    remote_irq_ack_full        : out std_ulogic;

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
    noc5_out_data : in  misc_noc_flit_type;
    noc5_out_void : in  std_ulogic;
    noc5_out_stop : out std_ulogic;
    noc5_in_data  : out misc_noc_flit_type;
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
  signal coherence_req_rdreq        : std_ulogic;
  signal coherence_req_data_out     : noc_flit_type;
  signal coherence_req_empty        : std_ulogic;
  -- NoC2->tile
  signal coherence_fwd_wrreq        : std_ulogic;
  signal coherence_fwd_data_in      : noc_flit_type;
  signal coherence_fwd_full         : std_ulogic;
  -- NoC3->tile
  signal coherence_rsp_rcv_wrreq    : std_ulogic;
  signal coherence_rsp_rcv_data_in  : noc_flit_type;
  signal coherence_rsp_rcv_full     : std_ulogic;
  -- tile->NoC3
  signal coherence_rsp_snd_rdreq    : std_ulogic;
  signal coherence_rsp_snd_data_out : noc_flit_type;
  signal coherence_rsp_snd_empty    : std_ulogic;
  -- tile->NoC2
  signal coherence_fwd_snd_rdreq    : std_ulogic;
  signal coherence_fwd_snd_data_out : noc_flit_type;
  signal coherence_fwd_snd_empty    : std_ulogic;
  -- NoC4->tile
  signal dma_rcv_wrreq              : std_ulogic;
  signal dma_rcv_data_in            : noc_flit_type;
  signal dma_rcv_full               : std_ulogic;
  -- tile->NoC6
  signal dma_snd_rdreq              : std_ulogic;
  signal dma_snd_data_out           : noc_flit_type;
  signal dma_snd_empty              : std_ulogic;
  -- tile->NoC5
  signal remote_ahbs_snd_rdreq      : std_ulogic;
  signal remote_ahbs_snd_data_out   : misc_noc_flit_type;
  signal remote_ahbs_snd_empty      : std_ulogic;
  -- NoC5->tile
  signal remote_ahbs_rcv_wrreq      : std_ulogic;
  signal remote_ahbs_rcv_data_in    : misc_noc_flit_type;
  signal remote_ahbs_rcv_full       : std_ulogic;
  -- NoC5->tile
  signal apb_rcv_wrreq              : std_ulogic;
  signal apb_rcv_data_in            : misc_noc_flit_type;
  signal apb_rcv_full               : std_ulogic;
  -- tile->NoC5
  signal apb_snd_rdreq              : std_ulogic;
  signal apb_snd_data_out           : misc_noc_flit_type;
  signal apb_snd_empty              : std_ulogic;
  -- NoC5->tile
  signal remote_apb_rcv_wrreq       : std_ulogic;
  signal remote_apb_rcv_data_in     : misc_noc_flit_type;
  signal remote_apb_rcv_full        : std_ulogic;
  -- tile->NoC5
  signal remote_apb_snd_rdreq       : std_ulogic;
  signal remote_apb_snd_data_out    : misc_noc_flit_type;
  signal remote_apb_snd_empty       : std_ulogic;
  -- NoC5->tile
  signal remote_irq_wrreq           : std_ulogic;
  signal remote_irq_data_in         : misc_noc_flit_type;
  signal remote_irq_full            : std_ulogic;
  -- tile->NoC5
  signal remote_irq_ack_rdreq       : std_ulogic;
  signal remote_irq_ack_data_out    : misc_noc_flit_type;
  signal remote_irq_ack_empty       : std_ulogic;

  -- Local Master -> Local apb slave (request)
  signal local_remote_apb_snd_wrreq    : std_ulogic;
  signal local_remote_apb_snd_data_in  : misc_noc_flit_type;
  signal local_remote_apb_snd_full     : std_ulogic;
  signal local_remote_apb_rcv_rdreq    : std_ulogic;
  signal local_remote_apb_rcv_data_out : misc_noc_flit_type;
  signal local_remote_apb_rcv_empty    : std_ulogic;
  -- Local apb slave --> Local Master (response)
  signal local_apb_snd_wrreq           : std_ulogic;
  signal local_apb_snd_data_in         : misc_noc_flit_type;
  signal local_apb_snd_full            : std_ulogic;
  signal local_apb_rcv_rdreq           : std_ulogic;
  signal local_apb_rcv_data_out        : misc_noc_flit_type;
  signal local_apb_rcv_empty           : std_ulogic;


  type noc2_packet_fsm is (none, packet_inv);
  signal noc2_fifos_current, noc2_fifos_next : noc2_packet_fsm;
  type noc3_packet_fsm is (none, packet_line);
  signal noc3_fifos_current, noc3_fifos_next : noc3_packet_fsm;
  type to_noc3_packet_fsm is (none, packet_coherence_rsp_snd);
  signal to_noc3_fifos_current, to_noc3_fifos_next : to_noc3_packet_fsm;
  type noc5_packet_fsm is (none, packet_remote_apb_rcv, packet_ahbm_rcv, packet_irq,
                           packet_apb_rcv, packet_local_remote_apb_rcv, packet_local_apb_rcv,
                           packet_remote_ahbs_rcv);
  signal noc5_fifos_current, noc5_fifos_next : noc5_packet_fsm;
  type to_noc5_packet_fsm is (none, packet_remote_apb_snd, packet_ahbm_snd, packet_irq_ack,
                              packet_apb_snd, packet_local_remote_apb_snd, packet_local_apb_snd,
                              packet_remote_ahbs_snd);
  signal to_noc5_fifos_current, to_noc5_fifos_next : to_noc5_packet_fsm;


  signal noc3_msg_type : noc_msg_type;
  signal noc3_preamble : noc_preamble_type;
  signal noc5_msg_type : noc_msg_type;
  signal noc5_preamble : noc_preamble_type;
  signal local_remote_apb_rcv_preamble : noc_preamble_type;
  signal local_apb_rcv_preamble : noc_preamble_type;

  signal noc4_dummy_in_stop   : std_ulogic;
  signal noc6_dummy_out_data  : noc_flit_type;
  signal noc6_dummy_out_void  : std_ulogic;

begin  -- rtl

  fifo_rst <= rst;                  --FIFO rst active low

  -- To noc1: coherence requests from CPU to directory (GET/PUT)
  noc1_out_stop         <= '0';
  noc1_in_data          <= coherence_req_data_out;
  noc1_in_void          <= coherence_req_empty or noc1_in_stop;
  coherence_req_rdreq   <= (not coherence_req_empty) and (not noc1_in_stop);
  fifo_1: fifo0
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


  -- From noc2: coherence forwarded messages to CPU (INV, GETS/M)
  noc2_out_stop <= coherence_fwd_full and (not noc2_out_void);
  coherence_fwd_data_in <= noc2_out_data;
  coherence_fwd_wrreq <= (not noc2_out_void) and (not coherence_fwd_full);

  fifo_2: fifo0
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


  
  -- From noc3: coherence response messages to CPU (DATA, INVACK, PUTACK)
  noc3_out_stop <= coherence_rsp_rcv_full and (not noc3_out_void);
  coherence_rsp_rcv_data_in <= noc3_out_data;
  coherence_rsp_rcv_wrreq <= (not noc3_out_void) and (not coherence_rsp_rcv_full);

  fifo_3: fifo0
    generic map (
      depth => 5,                       --Header (use RESERVED field to
                                        --determine  ACK number), cache line
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


  -- To noc3: coherence response messages from CPU (DATA, EDATA, INVACK)
  noc3_in_data          <= coherence_rsp_snd_data_out;
  noc3_in_void          <= coherence_rsp_snd_empty or noc3_in_stop;
  coherence_rsp_snd_rdreq   <= (not coherence_rsp_snd_empty) and (not noc3_in_stop);
  fifo_4: fifo0
    generic map (
      depth => 5,                       --Header
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

  -- To noc2: dcs l2_fwd_out
  noc2_in_data          <= coherence_fwd_snd_data_out;
  noc2_in_void          <= coherence_fwd_snd_empty or noc2_in_stop;
  coherence_fwd_snd_rdreq   <= (not coherence_fwd_snd_empty) and (not noc2_in_stop);
  fifo_5: fifo0
    generic map (
      depth => 5,                       --Header
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_fwd_snd_rdreq,
      wrreq    => coherence_fwd_snd_wrreq,
      data_in  => coherence_fwd_snd_data_in,
      empty    => coherence_fwd_snd_empty,
      full     => coherence_fwd_snd_full,
      data_out => coherence_fwd_snd_data_out);


  -- From noc5: remote APB response to core (APB rcv)
  -- From noc5: remove AHB master request to DSU (AHBM rcv)
  -- From noc5: IRQ
  -- From local_remote_apb_rcv (APB rcv from devices in this tile)
  noc5_msg_type <= get_msg_type(MISC_NOC_FLIT_SIZE, noc_flit_pad & noc5_out_data);
  noc5_preamble <= get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & noc5_out_data);
  local_remote_apb_rcv_preamble <= get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & local_remote_apb_rcv_data_out);
  local_apb_rcv_preamble <= get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & local_apb_rcv_data_out);

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
                                  remote_irq_full,
                                  noc5_fifos_current,
                                  apb_rcv_full, local_remote_apb_rcv_empty,
                                  local_apb_rcv_empty, local_remote_apb_rcv_data_out,
                                  local_apb_rcv_data_out, local_remote_apb_rcv_preamble,
                                  local_apb_rcv_preamble,
                                  remote_ahbs_rcv_full)
  begin  -- process noc5_get_packet
    remote_apb_rcv_wrreq <= '0';
    remote_apb_rcv_data_in <= noc5_out_data;

    remote_irq_wrreq <= '0';

    apb_rcv_wrreq <= '0';
    apb_rcv_data_in <= noc5_out_data;

    remote_ahbs_rcv_wrreq <= '0';
    remote_ahbs_rcv_data_in <= noc5_out_data;

    noc5_fifos_next <= noc5_fifos_current;
    noc5_out_stop <= '0';

    local_remote_apb_rcv_rdreq <= '0';
    local_apb_rcv_rdreq <= '0';

    case noc5_fifos_current is
      when none =>  if local_remote_apb_rcv_empty = '0' then
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
                     if (noc5_msg_type = RSP_REG_RD
                         and noc5_preamble = PREAMBLE_HEADER) then
                       if remote_apb_rcv_full = '0' then
                         remote_apb_rcv_wrreq <= '1';
                         noc5_fifos_next <= packet_remote_apb_rcv;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     elsif (noc5_msg_type = IRQ_MSG and (noc5_preamble = PREAMBLE_HEADER or noc5_preamble = PREAMBLE_1FLIT)) then
                       if remote_irq_full = '0' then
                         remote_irq_wrreq <= '1';
                         if noc5_preamble = PREAMBLE_HEADER then
                           -- Leon3 needs more than single-flit packet
                           noc5_fifos_next <= packet_irq;
                         end if;
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
                     elsif ((noc5_msg_type = RSP_AHB_RD) and noc5_preamble = PREAMBLE_HEADER) then
                       if remote_ahbs_rcv_full = '0' then
                         remote_ahbs_rcv_wrreq <= '1';
                         noc5_fifos_next <= packet_remote_ahbs_rcv;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     end if;

                   end if;

      when packet_remote_apb_rcv => remote_apb_rcv_wrreq <= (not noc5_out_void) and (not remote_apb_rcv_full);
                             noc5_out_stop <= remote_apb_rcv_full and (not noc5_out_void);
                             if noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                             remote_apb_rcv_full = '0' then
                               noc5_fifos_next <= none;
                             end if;

      when packet_local_remote_apb_rcv => noc5_out_stop <= not noc5_out_void;
                                          apb_rcv_wrreq <= not local_remote_apb_rcv_empty and (not apb_rcv_full);
                                          apb_rcv_data_in <= local_remote_apb_rcv_data_out;
                                          if (local_remote_apb_rcv_empty = '0' and apb_rcv_full = '0') then
                                            local_remote_apb_rcv_rdreq <= '1';
                                            if local_remote_apb_rcv_preamble = PREAMBLE_TAIL then
                                                noc5_fifos_next <= none;
                                            end if;
                                          end if;

      when packet_irq => remote_irq_wrreq <= not noc5_out_void and (not remote_irq_full);
                             noc5_out_stop <= remote_irq_full and (not noc5_out_void);
                             if noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                             remote_irq_full = '0' then
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

      when packet_remote_ahbs_rcv => remote_ahbs_rcv_wrreq <= not noc5_out_void and (not remote_ahbs_rcv_full);
                                    noc5_out_stop <= remote_ahbs_rcv_full and (not noc5_out_void);
                                    if (noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                                        remote_ahbs_rcv_full = '0') then
                                      noc5_fifos_next <= none;
                                    end if;

      when others => noc5_fifos_next <= none;
    end case;
  end process noc5_fifos_get_packet;

  fifo_7: fifo0
    generic map (
      depth => 2,                       --Header, data
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_apb_rcv_rdreq,
      wrreq    => remote_apb_rcv_wrreq,
      data_in  => remote_apb_rcv_data_in,
      empty    => remote_apb_rcv_empty,
      full     => remote_apb_rcv_full,
      data_out => remote_apb_rcv_data_out);

  remote_irq_data_in <= noc5_out_data;
  fifo_9: fifo0
    generic map (
      depth => 2,                       --Header, irq level
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_irq_rdreq,
      wrreq    => remote_irq_wrreq,
      data_in  => remote_irq_data_in,
      empty    => remote_irq_empty,
      full     => remote_irq_full,
      data_out => remote_irq_data_out);

  fifo_16: fifo0
    generic map (
      depth => 3,                       --Header, address, data
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_rcv_rdreq,
      wrreq    => apb_rcv_wrreq,
      data_in  => apb_rcv_data_in,
      empty    => apb_rcv_empty,
      full     => apb_rcv_full,
      data_out => apb_rcv_data_out);

  fifo_20: fifo0
    generic map (
      depth => 3,                       --Header, address, data
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_ahbs_rcv_rdreq,
      wrreq    => remote_ahbs_rcv_wrreq,
      data_in  => remote_ahbs_rcv_data_in,
      empty    => remote_ahbs_rcv_empty,
      full     => remote_ahbs_rcv_full,
      data_out => remote_ahbs_rcv_data_out);

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
                                  remote_irq_ack_data_out, remote_irq_ack_empty,
                                  apb_snd_data_out, apb_snd_empty,
                                  local_remote_apb_snd_full, local_apb_snd_full,
                                  remote_ahbs_snd_data_out, remote_ahbs_snd_empty)
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
    remote_irq_ack_rdreq <= '0';
    apb_snd_rdreq <= '0';
    remote_ahbs_snd_rdreq <= '0';
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
                    elsif (remote_apb_snd_empty = '0' and remote_apb_snd_to_local = '0') then
                      if noc5_in_stop = '0' then
                        noc5_in_data <= remote_apb_snd_data_out;
                        noc5_in_void <= remote_apb_snd_empty;
                        remote_apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_remote_apb_snd;
                      end if;
                    elsif (remote_apb_snd_empty = '0' and remote_apb_snd_to_local = '1') then
                      if local_remote_apb_snd_full = '0' then
                        local_remote_apb_snd_wrreq <= '1';
                        remote_apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_local_remote_apb_snd;
                      end if;
                    elsif (apb_snd_empty = '0' and apb_snd_to_local = '0') then
                      if noc5_in_stop = '0' then
                        noc5_in_data <= apb_snd_data_out;
                        noc5_in_void <= apb_snd_empty;
                        apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_apb_snd;
                      end if;
                    elsif (apb_snd_empty = '0' and apb_snd_to_local = '1') then
                      if local_apb_snd_full = '0' then
                        local_apb_snd_wrreq <= '1';
                        apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_local_apb_snd;
                      end if;
                    elsif remote_ahbs_snd_empty = '0' then
                      if noc5_in_stop = '0' then
                        noc5_in_data <= remote_ahbs_snd_data_out;
                        noc5_in_void <= remote_ahbs_snd_empty;
                        remote_ahbs_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_remote_ahbs_snd;
                      end if;

                    end if;

      when packet_remote_apb_snd => to_noc5_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & remote_apb_snd_data_out);
                             if (noc5_in_stop = '0' and remote_apb_snd_empty = '0') then
                               noc5_in_data <= remote_apb_snd_data_out;
                               noc5_in_void <= remote_apb_snd_empty;
                               remote_apb_snd_rdreq <= not noc5_in_stop;
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_local_remote_apb_snd => to_noc5_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & remote_apb_snd_data_out);
                             if (local_remote_apb_snd_full = '0' and remote_apb_snd_empty = '0') then
                               local_remote_apb_snd_wrreq <= '1';
                               remote_apb_snd_rdreq <= '1';
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_irq_ack  => to_noc5_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & remote_irq_ack_data_out);
                              if (noc5_in_stop = '0' and remote_irq_ack_empty = '0') then
                                noc5_in_data <= remote_irq_ack_data_out;
                                noc5_in_void <= remote_irq_ack_empty;
                                remote_irq_ack_rdreq <= not noc5_in_stop;
                                if to_noc5_preamble = PREAMBLE_TAIL then
                                  to_noc5_fifos_next <= none;
                                end if;
                              end if;

      when packet_apb_snd  => to_noc5_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & apb_snd_data_out);
                             if (noc5_in_stop = '0' and apb_snd_empty = '0') then
                               noc5_in_data <= apb_snd_data_out;
                               noc5_in_void <= apb_snd_empty;
                               apb_snd_rdreq <= not noc5_in_stop;
                               if (to_noc5_preamble = PREAMBLE_TAIL) then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_local_apb_snd => to_noc5_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & apb_snd_data_out);
                             if (local_apb_snd_full = '0' and apb_snd_empty = '0') then
                               local_apb_snd_wrreq <= '1';
                               apb_snd_rdreq <= '1';
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_remote_ahbs_snd  => to_noc5_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & remote_ahbs_snd_data_out);
                                      if (noc5_in_stop = '0' and remote_ahbs_snd_empty = '0') then
                                        noc5_in_data <= remote_ahbs_snd_data_out;
                                        noc5_in_void <= remote_ahbs_snd_empty;
                                        remote_ahbs_snd_rdreq <= not noc5_in_stop;
                                        if (to_noc5_preamble = PREAMBLE_TAIL) then
                                          to_noc5_fifos_next <= none;
                                        end if;
                                      end if;

      when others => to_noc5_fifos_next <= none;
    end case;
  end process to_noc5_select_packet;

  fifo_10: fifo0
    generic map (
      depth => 3,                       --Header, address, data (1 word)
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_apb_snd_rdreq,
      wrreq    => remote_apb_snd_wrreq,
      data_in  => remote_apb_snd_data_in,
      empty    => remote_apb_snd_empty,
      full     => remote_apb_snd_full,
      data_out => remote_apb_snd_data_out);

  fifo_12: fifo0
    generic map (
      depth => 2,                       --Header, irq info
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_irq_ack_rdreq,
      wrreq    => remote_irq_ack_wrreq,
      data_in  => remote_irq_ack_data_in,
      empty    => remote_irq_ack_empty,
      full     => remote_irq_ack_full,
      data_out => remote_irq_ack_data_out);

  fifo_17: fifo0
    generic map (
      depth => 6,                       --Header, address, data (up to 4 words)
      width => MISC_NOC_FLIT_SIZE)
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
  fifo_18: fifo0
    generic map (
      depth => 6,                       --Header, address, data (1 word) (2x)
      width => MISC_NOC_FLIT_SIZE)
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
  fifo_19: fifo0
    generic map (
      depth => 6,                       --Header, data (1 word) (2x)
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => local_apb_rcv_rdreq,
      wrreq    => local_apb_snd_wrreq,
      data_in  => local_apb_snd_data_in,
      empty    => local_apb_rcv_empty,
      full     => local_apb_snd_full,
      data_out => local_apb_rcv_data_out);

  fifo_21: fifo0
    generic map (
      depth => 3,                       --Header, address, data
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => remote_ahbs_snd_rdreq,
      wrreq    => remote_ahbs_snd_wrreq,
      data_in  => remote_ahbs_snd_data_in,
      empty    => remote_ahbs_snd_empty,
      full     => remote_ahbs_snd_full,
      data_out => remote_ahbs_snd_data_out);

  -- noc4 does not interact with CPU tiles
  -- From noc4: DMA response to accelerators
  noc4_in_data <= (others => '0');
  noc4_in_void <= '1';
  noc4_dummy_in_stop <= noc4_in_stop;
  noc4_out_stop   <= dma_rcv_full and (not noc4_out_void);
  dma_rcv_data_in <= noc4_out_data;
  dma_rcv_wrreq   <= (not noc4_out_void) and (not dma_rcv_full);
  fifo_14: fifo0
    generic map (
      depth => 6,                      -- same as coherence req for the CPU
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

  -- noc6 does not interact with CPU tiles
  noc6_dummy_out_data <= noc6_out_data;
  noc6_dummy_out_void <= noc6_out_void;
  noc6_out_stop <= '0';
  noc6_in_data <= dma_snd_data_out;
  noc6_in_void <= dma_snd_empty or noc6_in_stop;
  dma_snd_rdreq <= (not dma_snd_empty) and (not noc6_in_stop);
  fifo_13: fifo0
    generic map (
      depth => 5,                       -- same as coherence rsp for the CPU
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

end rtl;
