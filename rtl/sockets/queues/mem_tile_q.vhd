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

entity mem_tile_q is
  generic (
    tech        : integer := virtex7);
  port (
    rst                        : in  std_ulogic;
    clk                        : in  std_ulogic;
    -- NoC1->tile
    coherence_req_rdreq        : in  std_ulogic;
    coherence_req_data_out     : out noc_flit_type;
    coherence_req_empty        : out std_ulogic;
    -- tile->NoC2
    coherence_fwd_wrreq        : in  std_ulogic;
    coherence_fwd_data_in      : in  noc_flit_type;
    coherence_fwd_full         : out std_ulogic;
    -- tile->NoC3
    coherence_rsp_snd_wrreq    : in  std_ulogic;
    coherence_rsp_snd_data_in  : in  noc_flit_type;
    coherence_rsp_snd_full     : out std_ulogic;
    -- Noc3->tile
    coherence_rsp_rcv_rdreq    : in  std_ulogic;
    coherence_rsp_rcv_data_out : out noc_flit_type;
    coherence_rsp_rcv_empty    : out std_ulogic;
    -- NoC6->tile
    dma_rcv_rdreq              : in  std_ulogic;
    dma_rcv_data_out           : out noc_flit_type;
    dma_rcv_empty              : out std_ulogic;
    -- tile->NoC6
    coherent_dma_snd_wrreq     : in  std_ulogic;
    coherent_dma_snd_data_in   : in  noc_flit_type;
    coherent_dma_snd_full      : out std_ulogic;
    coherent_dma_snd_atleast_4slots : out std_ulogic;
    coherent_dma_snd_exactly_3slots : out std_ulogic;
    -- tile->NoC4
    dma_snd_wrreq              : in  std_ulogic;
    dma_snd_data_in            : in  noc_flit_type;
    dma_snd_full               : out std_ulogic;
    dma_snd_atleast_4slots     : out std_ulogic;
    dma_snd_exactly_3slots     : out std_ulogic;
    -- NoC4->tile
    coherent_dma_rcv_rdreq     : in  std_ulogic;
    coherent_dma_rcv_data_out  : out noc_flit_type;
    coherent_dma_rcv_empty     : out std_ulogic;
    -- NoC5->tile
    remote_ahbs_rcv_rdreq      : in  std_ulogic;
    remote_ahbs_rcv_data_out   : out misc_noc_flit_type;
    remote_ahbs_rcv_empty      : out std_ulogic;
    -- tile->NoC5
    remote_ahbs_snd_wrreq      : in  std_ulogic;
    remote_ahbs_snd_data_in    : in  misc_noc_flit_type;
    remote_ahbs_snd_full       : out std_ulogic;
    -- NoC5->tile
    apb_rcv_rdreq              : in  std_ulogic;
    apb_rcv_data_out           : out misc_noc_flit_type;
    apb_rcv_empty              : out std_ulogic;
    -- tile->NoC5
    apb_snd_wrreq              : in  std_ulogic;
    apb_snd_data_in            : in  misc_noc_flit_type;
    apb_snd_full               : out std_ulogic;

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
    noc5_out_data : in  misc_noc_flit_type;
    noc5_out_void : in  std_ulogic;
    noc5_out_stop : out std_ulogic;
    noc5_in_data  : out misc_noc_flit_type;
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
  signal remote_ahbs_rcv_data_in      : misc_noc_flit_type;
  signal remote_ahbs_rcv_full         : std_ulogic;
  -- tile->NoC5
  signal remote_ahbs_snd_rdreq        : std_ulogic;
  signal remote_ahbs_snd_data_out     : misc_noc_flit_type;
  signal remote_ahbs_snd_empty        : std_ulogic;
  -- NoC5->tile
  signal apb_rcv_wrreq                : std_ulogic;
  signal apb_rcv_data_in              : misc_noc_flit_type;
  signal apb_rcv_full                 : std_ulogic;
  -- tile->NoC5
  signal apb_snd_rdreq                : std_ulogic;
  signal apb_snd_data_out             : misc_noc_flit_type;
  signal apb_snd_empty                : std_ulogic;

  signal noc2_dummy_out_data  : noc_flit_type;
  signal noc2_dummy_out_void  : std_ulogic;
  signal noc1_dummy_in_stop   : std_ulogic;

  type noc5_packet_fsm is (none, packet_remote_ahbs_rcv, packet_apb_rcv);
  signal noc5_fifos_current, noc5_fifos_next : noc5_packet_fsm;
  type to_noc5_packet_fsm is (none, packet_remote_ahbs_snd, packet_apb_snd);
  signal to_noc5_fifos_current, to_noc5_fifos_next : to_noc5_packet_fsm;

  signal noc5_msg_type : noc_msg_type;
  signal noc5_preamble : noc_preamble_type;

begin  -- rtl

  fifo_rst <= rst;                  --FIFO rst active low

  -- From noc1: coherence requests from CPU to directory (GET/PUT)
  noc1_in_data          <= (others => '0');
  noc1_in_void          <= '1';
  noc1_dummy_in_stop    <= noc1_in_stop;
  noc1_out_stop         <= coherence_req_full and (not noc1_out_void);
  coherence_req_data_in <= noc1_out_data;
  coherence_req_wrreq   <= (not noc1_out_void) and (not coherence_req_full);

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


  -- To noc2: coherence forwarded messages to CPU (INV)
  -- To noc2: coherence forwarded messages to CPU (PUT_ACK)
  noc2_out_stop <= '0';
  noc2_dummy_out_data <= noc2_out_data;
  noc2_dummy_out_void <= noc2_out_void;
  noc2_in_data <= coherence_fwd_data_out;
  noc2_in_void <= coherence_fwd_empty or noc2_in_stop;
  coherence_fwd_rdreq <= (not coherence_fwd_empty) and (not noc2_in_stop);

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

  -- From noc3: coherence response messages from CPU (LINE on a GETS while
  -- owining the line in modified state)
  noc3_out_stop   <= coherence_rsp_rcv_full and (not noc3_out_void);
  coherence_rsp_rcv_data_in <= noc3_out_data;
  coherence_rsp_rcv_wrreq   <= (not noc3_out_void) and (not coherence_rsp_rcv_full);
  fifo_3: fifo0
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
  fifo_4: fifo0
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


  -- From noc6: DMA requests from accelerators
  noc6_out_stop   <= dma_rcv_full and (not noc6_out_void);
  dma_rcv_data_in <= noc6_out_data;
  dma_rcv_wrreq   <= (not noc6_out_void) and (not dma_rcv_full);
  fifo_13: fifo0
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

  -- From noc4: Coherent DMA requests from accelerators
  noc4_out_stop            <= coherent_dma_rcv_full and (not noc4_out_void);
  coherent_dma_rcv_data_in <= noc4_out_data;
  coherent_dma_rcv_wrreq   <= (not noc4_out_void) and (not coherent_dma_rcv_full);
  fifo_13c: fifo0
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

  -- To noc4: DMA response to accelerators
  noc4_in_data <= dma_snd_data_out;
  noc4_in_void <= dma_snd_empty or noc4_in_stop;
  dma_snd_rdreq <= (not dma_snd_empty) and (not noc4_in_stop);
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

  -- To noc6: Coherent DMA response to accelerators
  noc6_in_data <= coherent_dma_snd_data_out;
  noc6_in_void <= coherent_dma_snd_empty or noc6_in_stop;
  coherent_dma_snd_rdreq <= (not coherent_dma_snd_empty) and (not noc6_in_stop);
  fifo_14c: fifo2
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
      atleast_4slots => coherent_dma_snd_atleast_4slots,
      exactly_3slots => coherent_dma_snd_exactly_3slots,
      data_out => coherent_dma_snd_data_out);

  -- From noc5: AHB slave response from remote DSU (AHBs rcv)
  -- Priority must be respected to avoid deadlock!
  noc5_msg_type <= get_msg_type(MISC_NOC_FLIT_SIZE, noc_flit_pad & noc5_out_data);
  noc5_preamble <= get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & noc5_out_data);
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      noc5_fifos_current <= noc5_fifos_next;
    end if;
  end process;
  noc5_fifos_get_packet: process (noc5_out_data, noc5_out_void, noc5_msg_type,
                                  noc5_preamble,
                                  remote_ahbs_rcv_full, noc5_fifos_current,
                                  apb_rcv_full)
  begin  -- process noc5_get_packet
    remote_ahbs_rcv_data_in <= noc5_out_data;
    remote_ahbs_rcv_wrreq <= '0';

    apb_rcv_wrreq <= '0';
    apb_rcv_data_in <= noc5_out_data;

    noc5_fifos_next <= noc5_fifos_current;
    noc5_out_stop <= '0';

    case noc5_fifos_current is
      when none => if noc5_out_void = '0' then
                     if ((noc5_msg_type = AHB_RD or noc5_msg_type = AHB_WR) and noc5_preamble = PREAMBLE_HEADER) then
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

      when others => noc5_fifos_next <= none;
    end case;
  end process noc5_fifos_get_packet;

  fifo_8: fifo0
    generic map (
      depth => 5,                       --Header, data up to 4 words
                                        --per packet
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

  -- To noc5: APB request to remote (APB snd)
  -- To noc5: AHB master request to DSU (AHBS snd) - TODO: broadcast to all DSUs
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      to_noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      to_noc5_fifos_current <= to_noc5_fifos_next;
    end if;
  end process;

  to_noc5_select_packet: process (noc5_in_stop, to_noc5_fifos_current,
                                  remote_ahbs_snd_data_out, remote_ahbs_snd_empty,
                                  apb_snd_data_out, apb_snd_empty)
    variable to_noc5_preamble : noc_preamble_type;
  begin  -- process to_noc5_select_packet
    noc5_in_data <= (others => '0');
    noc5_in_void <= '1';

    remote_ahbs_snd_rdreq <= '0';
    apb_snd_rdreq <= '0';
    to_noc5_fifos_next <= to_noc5_fifos_current;
    to_noc5_preamble := "00";


    case to_noc5_fifos_current is
      when none  => if remote_ahbs_snd_empty = '0' then
                      noc5_in_data <= remote_ahbs_snd_data_out;
                      if noc5_in_stop = '0' then
                        noc5_in_void <= remote_ahbs_snd_empty;
                        remote_ahbs_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_remote_ahbs_snd;
                      end if;
                    elsif apb_snd_empty = '0' then
                      noc5_in_data <= apb_snd_data_out;
                      if noc5_in_stop = '0' then
                        noc5_in_void <= apb_snd_empty;
                        apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_apb_snd;
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

      when packet_apb_snd  => to_noc5_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & apb_snd_data_out);
                             if (noc5_in_stop = '0' and apb_snd_empty = '0') then
                               noc5_in_data <= apb_snd_data_out;
                               noc5_in_void <= apb_snd_empty;
                               apb_snd_rdreq <= not noc5_in_stop;
                               if (to_noc5_preamble = PREAMBLE_TAIL) then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

  when others => to_noc5_fifos_next <= none;
    end case;
  end process to_noc5_select_packet;

  fifo_11: fifo0
    generic map (
      depth => 6,                       --Header, address, data (up to 4 words)
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

end rtl;
