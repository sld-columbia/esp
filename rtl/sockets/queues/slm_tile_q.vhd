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

entity slm_tile_q is
  generic (
    tech : integer := virtex7);
  port (
    rst                             : in  std_ulogic;
    clk                             : in  std_ulogic;
    -- NoC6->tile
    dma_rcv_rdreq                   : in  std_ulogic;
    dma_rcv_data_out                : out noc_flit_type;
    dma_rcv_empty                   : out std_ulogic;
    cpu_dma_rcv_rdreq               : in  std_ulogic;
    cpu_dma_rcv_data_out            : out noc_flit_type;
    cpu_dma_rcv_empty               : out std_ulogic;
    -- tile->NoC6
    coherent_dma_snd_wrreq          : in  std_ulogic;
    coherent_dma_snd_data_in        : in  noc_flit_type;
    coherent_dma_snd_full           : out std_ulogic;
    coherent_dma_snd_atleast_4slots : out std_ulogic;
    coherent_dma_snd_exactly_3slots : out std_ulogic;
    -- tile->NoC4
    dma_snd_wrreq                   : in  std_ulogic;
    dma_snd_data_in                 : in  noc_flit_type;
    dma_snd_full                    : out std_ulogic;
    dma_snd_atleast_4slots          : out std_ulogic;
    dma_snd_exactly_3slots          : out std_ulogic;
    cpu_dma_snd_wrreq               : in  std_ulogic;
    cpu_dma_snd_data_in             : in  noc_flit_type;
    cpu_dma_snd_full                : out std_ulogic;
    -- NoC4->tile
    coherent_dma_rcv_rdreq          : in  std_ulogic;
    coherent_dma_rcv_data_out       : out noc_flit_type;
    coherent_dma_rcv_empty          : out std_ulogic;
    -- NoC5->tile
    remote_ahbs_rcv_rdreq           : in  std_ulogic;
    remote_ahbs_rcv_data_out        : out misc_noc_flit_type;
    remote_ahbs_rcv_empty           : out std_ulogic;
    -- tile->NoC5
    remote_ahbs_snd_wrreq           : in  std_ulogic;
    remote_ahbs_snd_data_in         : in  misc_noc_flit_type;
    remote_ahbs_snd_full            : out std_ulogic;
    -- NoC5->tile
    apb_rcv_rdreq                   : in  std_ulogic;
    apb_rcv_data_out                : out misc_noc_flit_type;
    apb_rcv_empty                   : out std_ulogic;
    -- tile->NoC5
    apb_snd_wrreq                   : in  std_ulogic;
    apb_snd_data_in                 : in  misc_noc_flit_type;
    apb_snd_full                    : out std_ulogic;

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

end slm_tile_q;

architecture rtl of slm_tile_q is

  signal fifo_rst : std_ulogic;

  -- NoC6->tile
  signal dma_rcv_wrreq             : std_ulogic;
  signal dma_rcv_data_in           : noc_flit_type;
  signal dma_rcv_full              : std_ulogic;
  signal cpu_dma_rcv_wrreq         : std_ulogic;
  signal cpu_dma_rcv_data_in       : noc_flit_type;
  signal cpu_dma_rcv_full          : std_ulogic;
  -- tile->NoC6
  signal coherent_dma_snd_rdreq    : std_ulogic;
  signal coherent_dma_snd_data_out : noc_flit_type;
  signal coherent_dma_snd_empty    : std_ulogic;
  -- tile->NoC4
  signal dma_snd_rdreq             : std_ulogic;
  signal dma_snd_data_out          : noc_flit_type;
  signal dma_snd_empty             : std_ulogic;
  signal cpu_dma_snd_rdreq         : std_ulogic;
  signal cpu_dma_snd_data_out      : noc_flit_type;
  signal cpu_dma_snd_empty         : std_ulogic;
  -- NoC4->tile
  signal coherent_dma_rcv_wrreq    : std_ulogic;
  signal coherent_dma_rcv_data_in  : noc_flit_type;
  signal coherent_dma_rcv_full     : std_ulogic;
  -- NoC5->tile
  signal remote_ahbs_rcv_wrreq     : std_ulogic;
  signal remote_ahbs_rcv_data_in   : misc_noc_flit_type;
  signal remote_ahbs_rcv_full      : std_ulogic;
  -- tile->NoC5
  signal remote_ahbs_snd_rdreq     : std_ulogic;
  signal remote_ahbs_snd_data_out  : misc_noc_flit_type;
  signal remote_ahbs_snd_empty     : std_ulogic;
  -- NoC5->tile
  signal apb_rcv_wrreq                : std_ulogic;
  signal apb_rcv_data_in              : misc_noc_flit_type;
  signal apb_rcv_full                 : std_ulogic;
  -- tile->NoC5
  signal apb_snd_rdreq                : std_ulogic;
  signal apb_snd_data_out             : misc_noc_flit_type;
  signal apb_snd_empty                : std_ulogic;


  type noc5_packet_fsm is (none, packet_remote_ahbs_rcv, packet_apb_rcv);
  signal noc5_fifos_current, noc5_fifos_next : noc5_packet_fsm;

  type noc6_packet_fsm is (none, packet_dma_rcv, packet_cpu_dma_rcv);
  signal noc6_fifos_current, noc6_fifos_next       : noc6_packet_fsm;

  type to_noc4_packet_fsm is (none, packet_dma_snd, packet_cpu_dma_snd);
  signal to_noc4_fifos_current, to_noc4_fifos_next : to_noc4_packet_fsm;

  type to_noc5_packet_fsm is (none, packet_remote_ahbs_snd, packet_apb_snd);
  signal to_noc5_fifos_current, to_noc5_fifos_next : to_noc5_packet_fsm;

  signal noc5_msg_type : noc_msg_type;
  signal noc5_preamble : noc_preamble_type;

  signal noc6_reserved_field : reserved_field_type;
  signal noc6_preamble : noc_preamble_type;

begin  -- rtl

  fifo_rst <= rst;                      --FIFO rst active low

  -- noc1: unused
  noc1_in_data  <= (others => '0');
  noc1_in_void  <= '1';
  noc1_out_stop <= '0';

  -- noc2: unused
  noc2_in_data  <= (others => '0');
  noc2_in_void  <= '1';
  noc2_out_stop <= '0';

  -- to noc3: unused
  noc3_in_data  <= (others => '0');
  noc3_in_void  <= '1';
  noc3_out_stop <= '0';

  -- From noc6: DMA requests from accelerators and CPUs
  noc6_reserved_field <= get_reserved_field(NOC_FLIT_SIZE, noc6_out_data);
  noc6_preamble <= get_preamble(NOC_FLIT_SIZE, noc6_out_data);

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      noc6_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      noc6_fifos_current <= noc6_fifos_next;
    end if;
  end process;
  noc6_fifos_get_packet : process (noc6_out_data, noc6_out_void, noc6_reserved_field, noc6_preamble, noc6_fifos_current,
                                   dma_rcv_full, cpu_dma_rcv_full)
  begin  -- process noc6_get_packet
    dma_rcv_wrreq   <= '0';
    dma_rcv_data_in <= noc6_out_data;

    cpu_dma_rcv_wrreq   <= '0';
    cpu_dma_rcv_data_in <= noc6_out_data;

    noc6_fifos_next <= noc6_fifos_current;
    noc6_out_stop   <= '0';

    case noc6_fifos_current is
      when none =>
        if noc6_out_void = '0' then
            --reserved(4) is 1 in case of CPU_DMA
            if ((noc6_reserved_field(4) /= '1')
              and noc6_preamble = PREAMBLE_HEADER) then
            if dma_rcv_full = '0' then
              dma_rcv_wrreq   <= '1';
              noc6_fifos_next <= packet_dma_rcv;
            else
              noc6_out_stop <= '1';
            end if;
          elsif (noc6_preamble = PREAMBLE_HEADER) then
            if cpu_dma_rcv_full = '0' then
              cpu_dma_rcv_wrreq <= '1';
              noc6_fifos_next   <= packet_cpu_dma_rcv;
            else
              noc6_out_stop <= '1';
            end if;
          end if;
        end if;

      when packet_dma_rcv =>
        dma_rcv_wrreq <= (not noc6_out_void) and (not dma_rcv_full);
        noc6_out_stop <= dma_rcv_full and (not noc6_out_void);
        if noc6_preamble = PREAMBLE_TAIL and noc6_out_void = '0' and dma_rcv_full = '0' then
          noc6_fifos_next <= none;
        end if;

      when packet_cpu_dma_rcv =>
        cpu_dma_rcv_wrreq <= (not noc6_out_void) and (not cpu_dma_rcv_full);
        noc6_out_stop     <= cpu_dma_rcv_full and (not noc6_out_void);
        if noc6_preamble = PREAMBLE_TAIL and noc6_out_void = '0' and cpu_dma_rcv_full = '0' then
          noc6_fifos_next <= none;
        end if;

      when others => noc6_fifos_next <= none;
    end case;
  end process noc6_fifos_get_packet;


  fifo_13 : fifo0
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

  fifo_13cpu : fifo0
    generic map (
      depth => 18,                      --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => cpu_dma_rcv_rdreq,
      wrreq    => cpu_dma_rcv_wrreq,
      data_in  => cpu_dma_rcv_data_in,
      empty    => cpu_dma_rcv_empty,
      full     => cpu_dma_rcv_full,
      data_out => cpu_dma_rcv_data_out);

  -- From noc4: Coherent DMA requests from Ethernet
  noc4_out_stop            <= coherent_dma_rcv_full and (not noc4_out_void);
  coherent_dma_rcv_data_in <= noc4_out_data;
  coherent_dma_rcv_wrreq   <= (not noc4_out_void) and (not coherent_dma_rcv_full);
  fifo_13c : fifo0
    generic map (
      depth => 8,                       --Header, address, [data]
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

  -- To noc4: DMA response to accelerators and CPUs
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      to_noc4_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      to_noc4_fifos_current <= to_noc4_fifos_next;
    end if;
  end process;

  to_noc4_select_packet : process (noc4_in_stop, to_noc4_fifos_current,
                                   dma_snd_data_out, dma_snd_empty,
                                   cpu_dma_snd_data_out, cpu_dma_snd_empty)
    variable to_noc4_preamble : noc_preamble_type;
  begin  -- process to_noc4_select_packet

    noc4_in_data <= (others => '0');
    noc4_in_void <= '1';

    dma_snd_rdreq     <= '0';
    cpu_dma_snd_rdreq <= '0';

    to_noc4_fifos_next <= to_noc4_fifos_current;
    to_noc4_preamble   := "00";

    case to_noc4_fifos_current is
      when none =>
        if dma_snd_empty = '0' then
          noc4_in_data <= dma_snd_data_out;
          if noc4_in_stop = '0' then
            noc4_in_void       <= '0';
            dma_snd_rdreq      <= '1';
            to_noc4_fifos_next <= packet_dma_snd;
          end if;
        elsif cpu_dma_snd_empty = '0' then
          noc4_in_data <= cpu_dma_snd_data_out;
          if noc4_in_stop = '0' then
            noc4_in_void       <= '0';
            cpu_dma_snd_rdreq  <= '1';
            to_noc4_fifos_next <= packet_cpu_dma_snd;
          end if;
        end if;

      when packet_dma_snd =>
        to_noc4_preamble := get_preamble(NOC_FLIT_SIZE, dma_snd_data_out);
        if (noc4_in_stop = '0' and dma_snd_empty = '0') then
          noc4_in_data  <= dma_snd_data_out;
          noc4_in_void  <= '0';
          dma_snd_rdreq <= '1';
          if to_noc4_preamble = PREAMBLE_TAIL then
            to_noc4_fifos_next <= none;
          end if;
        end if;

      when packet_cpu_dma_snd =>
        to_noc4_preamble := get_preamble(NOC_FLIT_SIZE, cpu_dma_snd_data_out);
        if (noc4_in_stop = '0' and cpu_dma_snd_empty = '0') then
          noc4_in_data      <= cpu_dma_snd_data_out;
          noc4_in_void      <= '0';
          cpu_dma_snd_rdreq <= '1';
          if to_noc4_preamble = PREAMBLE_TAIL then
            to_noc4_fifos_next <= none;
          end if;
        end if;

      when others =>
        to_noc4_fifos_next <= none;
    end case;
  end process to_noc4_select_packet;

  fifo_14 : fifo2
    generic map (
      depth => 18,                      --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk            => clk,
      rst            => fifo_rst,
      rdreq          => dma_snd_rdreq,
      wrreq          => dma_snd_wrreq,
      data_in        => dma_snd_data_in,
      empty          => dma_snd_empty,
      full           => dma_snd_full,
      atleast_4slots => dma_snd_atleast_4slots,
      exactly_3slots => dma_snd_exactly_3slots,
      data_out       => dma_snd_data_out);

  fifo_14cpu : fifo0
    generic map (
      depth => 5,                      --Header, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk            => clk,
      rst            => fifo_rst,
      rdreq          => cpu_dma_snd_rdreq,
      wrreq          => cpu_dma_snd_wrreq,
      data_in        => cpu_dma_snd_data_in,
      empty          => cpu_dma_snd_empty,
      full           => cpu_dma_snd_full,
      data_out       => cpu_dma_snd_data_out);

  -- To noc6: Coherent DMA response to Ethernet
  noc6_in_data           <= coherent_dma_snd_data_out;
  noc6_in_void           <= coherent_dma_snd_empty or noc6_in_stop;
  coherent_dma_snd_rdreq <= (not coherent_dma_snd_empty) and (not noc6_in_stop);
  fifo_14c : fifo2
    generic map (
      depth => 8,                       --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk            => clk,
      rst            => fifo_rst,
      rdreq          => coherent_dma_snd_rdreq,
      wrreq          => coherent_dma_snd_wrreq,
      data_in        => coherent_dma_snd_data_in,
      empty          => coherent_dma_snd_empty,
      full           => coherent_dma_snd_full,
      atleast_4slots => coherent_dma_snd_atleast_4slots,
      exactly_3slots => coherent_dma_snd_exactly_3slots,
      data_out       => coherent_dma_snd_data_out);

  -- From noc5: AHB master requests (debug link)
  -- From noc5: APB requests
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
                     if ((noc5_msg_type /= REQ_REG_RD and noc5_msg_type /= REQ_REG_WR) and noc5_preamble = PREAMBLE_HEADER) then
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
  -- To noc5: AHB master response (debug link)
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
