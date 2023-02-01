-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;



entity apb2noc is
  generic (
    tech        : integer := virtex7;
    ncpu        : integer := 4;
    apb_slv_cfg : apb_slv_config_vector;
    apb_slv_en  : std_logic_vector(0 to NAPBSLV - 1);
    apb_slv_y   : yx_vec(0 to NAPBSLV - 1);
    apb_slv_x   : yx_vec(0 to NAPBSLV - 1));
  port (
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    local_y     : in  local_yx;
    local_x     : in  local_yx;
    apbi     : in  apb_slv_in_type;
    apbo     : out apb_slv_out_vector;
    apb_req  : in  std_ulogic;
    apb_ack  : out std_ulogic;

    -- Packets to remote APB slave (tile->NoC5)
    remote_apb_snd_wrreq      : out std_ulogic;
    remote_apb_snd_data_in    : out misc_noc_flit_type;
    remote_apb_snd_full       : in  std_ulogic;
    -- Packets from remote APB (Noc5->tile)
    remote_apb_rcv_rdreq       : out std_ulogic;
    remote_apb_rcv_data_out    : in  misc_noc_flit_type;
    remote_apb_rcv_empty       : in  std_ulogic);

end apb2noc;

architecture rtl of apb2noc is

  type apb_fsm is (idle, rd_request_flit1, rd_request_flit2,
                   wr_request_flit1, wr_request_flit2, wr_request_flit3,
                   rd_reply_flit1, rd_reply_flit2);
  signal apb_state, apb_next : apb_fsm;

  signal header : misc_noc_flit_type;
  signal payload_address : misc_noc_flit_type;
  signal payload_data : misc_noc_flit_type;
  signal header_reg : misc_noc_flit_type;
  signal payload_address_reg : misc_noc_flit_type;
  signal payload_data_reg : misc_noc_flit_type;
  signal sample_flits : std_ulogic;
  signal pindex : integer range 0 to NAPBSLV - 1;

begin  -- rtl

  -----------------------------------------------------------------------------
  -- APB handling
  --
  -- On this port of the NoC the core can send a REQ_REG_RD or a REQ_REG_WR request.
  -- Since there is no APB peripheral in the CPU tile, the only type of packet
  -- that can be received is a response to RSP_REG_RD request. Moreover, since the
  -- AMBA bus cannot be released until the request has been fulfilled, the tile
  -- sending the response matches necessarily the request destination tile. For
  -- these reasons, we skip parsing the header and we simply forward the
  -- payload, which will always be a single flit, to the APB bus controller.
  -----------------------------------------------------------------------------
  default_apbo: for i in 0 to NAPBSLV - 1 generate
    apbo(i).pirq <= (others => '0');
    apbo(i).pconfig <= apb_slv_cfg(i) when apb_slv_en(i) = '1' else pconfig_none;
    apbo(i).pindex <= i when apb_slv_en(i) = '1' else 0;
    apbo(i).prdata <= remote_apb_rcv_data_out(31 downto 0);
  end generate default_apbo;

  make_packet: process (apbi, local_y, local_x)
    variable msg_type : noc_msg_type;
    variable header_v : misc_noc_flit_type;
    --pragma translate_off
    --variable my_line : LINE;
    --pragma translate_on
  begin  -- process make_packet
    msg_type := REQ_REG_RD;
    header_v := (others => '0');
    payload_address <= (others => '0');
    payload_address(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
    payload_address(31 downto 0) <= apbi.paddr;
    payload_data <= (others => '0');
    payload_data(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
    payload_data(31 downto 0) <= apbi.pwdata;

    pindex <= 0;
    for i in 0 to NAPBSLV - 1 loop

      if apbi.psel(i) = '1' then
        pindex <= i;
        if apbi.pwrite = '1' then
          msg_type := REQ_REG_WR;
          payload_address(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_BODY;
        end if;
        header_v := create_header(MISC_NOC_FLIT_SIZE, local_y, local_x, apb_slv_y(i), apb_slv_x(i), msg_type, (others => '0'))(MISC_NOC_FLIT_SIZE - 1 downto 0);
--pragma translate_off
        --Print("HEADER: ");
        --write(my_line, header_v);
        --writeline(output, my_line);
--pragma translate_on
      end if;
    end loop;  -- i
    header <= header_v;
  end process make_packet;

  -- purpose: Sample flits for APB request packet
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      header_reg <= (others => '0');
      payload_address_reg <= (others => '0');
      payload_data_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_flits = '1' then
        header_reg <= header;
        payload_address_reg <= payload_address;
        payload_data_reg <= payload_data;
      end if;
    end if;
  end process;


  -- This wrapper makes requests and waits for reply, but does not react to
  -- messages from remote masters, such as JTAG.
  apb_roundtrip: process (apb_state, apb_req, apbi, pindex,
                          remote_apb_rcv_empty, remote_apb_snd_full,
                          header_reg, payload_address_reg, payload_data_reg)
  begin  -- process apb_roundtrip
    apb_next <= apb_state;
    apb_ack <= '0';
    sample_flits <= '0';
    remote_apb_snd_data_in <= (others => '0');
    remote_apb_snd_wrreq <= '0';
    remote_apb_rcv_rdreq <= '0';

    case apb_state is
      when idle => if (apb_req and apbi.psel(pindex) and apb_slv_en(pindex)) = '1'then
                     sample_flits <= '1';
                     if apbi.pwrite = '1' then
                       apb_next <= wr_request_flit1;
                     else
                       apb_next <= rd_request_flit1;
                     end if;
                   end if;

      when wr_request_flit1 => if remote_apb_snd_full = '0' then
                                 remote_apb_snd_wrreq <= '1';
                                 remote_apb_snd_data_in <= header_reg;
                                 apb_next <= wr_request_flit2;
                               end if;
      when wr_request_flit2 => if remote_apb_snd_full = '0' then
                                 remote_apb_snd_wrreq <= '1';
                                 remote_apb_snd_data_in <= payload_address_reg;
                                 apb_next <= wr_request_flit3;
                               end if;
      when wr_request_flit3 => if remote_apb_snd_full = '0' then
                                 remote_apb_snd_wrreq <= '1';
                                 remote_apb_snd_data_in <= payload_data_reg;
                                 apb_ack <= '1';  --TODO: Could give ack before...
                                 apb_next <= idle;
                               end if;

      when rd_request_flit1 => if remote_apb_snd_full = '0' then
                                 remote_apb_snd_wrreq <= '1';
                                 remote_apb_snd_data_in <= header_reg;
                                 apb_next <= rd_request_flit2;
                               end if;
      when rd_request_flit2 => if remote_apb_snd_full = '0' then
                                 remote_apb_snd_wrreq <= '1';
                                 remote_apb_snd_data_in <= payload_address_reg;
                                 apb_next <= rd_reply_flit1;
                               end if;
      -- No need to check the header. No other APB reply can arrive here.
      when rd_reply_flit1 => if remote_apb_rcv_empty = '0' then
                               remote_apb_rcv_rdreq <= '1';
                               apb_next <= rd_reply_flit2;
                             end if;
      when rd_reply_flit2 => if remote_apb_rcv_empty = '0' then
                               remote_apb_rcv_rdreq <= '1';
                               apb_ack <= '1';
                               apb_next <= idle;
                             end if;
      when others => apb_next <= idle;
    end case;
  end process apb_roundtrip;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      apb_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      apb_state <= apb_next;
    end if;
  end process;

end rtl;
