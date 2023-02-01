-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-- Note: both APB read and write operations would require a setup state.
-- However, all integrated slaves so far respond to reads without setup, so we
-- are saving one clock cycle per access here.

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;

entity noc2apb is
  generic (
    tech         : integer := virtex7;
    local_apb_en : std_logic_vector(0 to NAPBSLV - 1));
  port (
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    local_y  : in  local_yx;
    local_x  : in  local_yx;
    apbi     : out apb_slv_in_type;
    apbo     : in  apb_slv_out_vector;
    pready   : in  std_ulogic;          -- exteded support for APB3 slaves
    dvfs_transient      : in  std_ulogic;
    -- Packets to local APB slave (tile->NoC5)
    apb_snd_wrreq       : out std_ulogic;
    apb_snd_data_in     : out misc_noc_flit_type;
    apb_snd_full        : in  std_ulogic;
    -- Packets from remote APB (Noc5->tile)
    apb_rcv_rdreq       : out std_ulogic;
    apb_rcv_data_out    : in  misc_noc_flit_type;
    apb_rcv_empty       : in  std_ulogic);

end noc2apb;

architecture rtl of noc2apb is

  type apb_fsm is (rcv_header, rcv_address, apb_write_strobe,
                   rcv_data, snd_data, snd_data_delay);
  signal apb_state, apb_next : apb_fsm;

  signal apbi_in, apbi_reg : apb_slv_in_type;
  signal sample_apbi : std_ulogic;
  signal request_y, request_x : local_yx;
  signal request_msg_type : noc_msg_type;
  signal sample_request : std_ulogic;
  signal header : misc_noc_flit_type;
  signal psel, psel_reg : integer range 0 to NAPBSLV - 1;
  signal sample_psel : std_ulogic;
  signal tail, tail_reg : misc_noc_flit_type;
  signal sample_tail : std_ulogic;
  signal waddr, waddr_reg : std_logic_vector(31 downto 0);
  signal sample_waddr : std_ulogic;
  signal sample_prdata : std_ulogic;
  signal prdata : std_logic_vector(31 downto 0);
  signal prdata_reg : std_logic_vector(31 downto 0);
  signal psel_sig : std_logic_vector(0 to NAPBSLV - 1);

begin  -- rtl

  -----------------------------------------------------------------------------
  -- APB handling
  -----------------------------------------------------------------------------

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      request_y <= (others => '0');
      request_x <= (others => '0');
      request_msg_type <= REQ_REG_RD;
      psel_reg <= 0;
      tail_reg <= (others => '0');
      waddr_reg <= (others => '0');
      prdata_reg <= (others => '0');
      apbi_reg <= apb_slv_in_none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_request = '1' then
        request_y <= get_origin_y(MISC_NOC_FLIT_SIZE, noc_flit_pad & apb_rcv_data_out);
        request_x <= get_origin_x(MISC_NOC_FLIT_SIZE, noc_flit_pad & apb_rcv_data_out);
        request_msg_type <= get_msg_type(MISC_NOC_FLIT_SIZE, noc_flit_pad & apb_rcv_data_out);
      end if;
      if sample_psel = '1' then
        psel_reg <= psel;
      end if;
      if sample_tail = '1' then
        tail_reg <= tail;
      end if;
      if sample_waddr = '1' then
        waddr_reg <= waddr;
      end if;
      if sample_prdata = '1' then
        prdata_reg <= prdata;
      end if;
      if sample_apbi = '1' then
        apbi_reg <= apbi_in;
      end if;
    end if;
  end process;
  header <= create_header(MISC_NOC_FLIT_SIZE, local_y, local_x, request_y, request_x, RSP_REG_RD, (others => '0'))(MISC_NOC_FLIT_SIZE - 1 downto 0);

  -- This wrapper makes requests and waits for reply, but does not react to
  -- messages from remote masters, such as JTAG.
  psel_gen: for i in 0 to NAPBSLV - 1 generate
    psel_sig(i) <= apb_slv_decode(apbo(i).pconfig, apb_rcv_data_out(19 downto  8), apb_rcv_data_out(27 downto 20));
  end generate psel_gen;

  -- This wrapper makes requests and waits for reply, but does not react to
  -- messages from remote masters, such as JTAG.
  apb_roundtrip: process (apb_state, apbo, apb_rcv_empty, apb_rcv_data_out,
                          apb_snd_full, request_y, request_x, request_msg_type,
                          header, psel_reg, tail_reg, waddr_reg, prdata_reg,
                          apbi_reg, dvfs_transient, pready, psel_sig)
    variable msg_type_v : noc_msg_type;
    variable addr_v : std_logic_vector(31 downto 0);
    variable data_v : std_logic_vector(31 downto 0);
    variable psel_v : integer range 0 to NAPBSLV - 1;
    variable pirq_v : std_logic_vector(NAHBIRQ-1 downto 0);

    variable reply_v : std_logic_vector(31 downto 0);
    variable tail_v : misc_noc_flit_type;
    variable apbi_V : apb_slv_in_type;
  begin  -- process apb_roundtrip
    apb_next <= apb_state;
    sample_request <= '0';
    sample_psel <= '0';
    sample_tail <= '0';
    sample_waddr <= '0';
    sample_prdata <= '0';
    sample_apbi <= '0';
    apbi_in <= apb_slv_in_none;
    apbi <= apb_slv_in_none; -- only IRQ from local devices are driven here
    apbi_v := apb_slv_in_none;
    -- driving psel, penable, paddr, pwrite, pwdata

    apb_snd_data_in <= (others => '0');
    apb_snd_wrreq <= '0';
    apb_rcv_rdreq <= '0';

    -- Get message type (valid during rcv_header state)
    msg_type_v := get_msg_type(MISC_NOC_FLIT_SIZE, noc_flit_pad & apb_rcv_data_out);
    -- Select slave (valid during rcv_address state)
    addr_v := apb_rcv_data_out(31 downto 0);
    waddr <= addr_v;
    -- When no slave matches, select CSRs on pindex 0. This enables
    -- setting tile_id after reset before all pconfig entries are
    -- configured correctly
    psel_v := 0;
    pirq_v := (others => '0');
    for i in 0 to NAPBSLV - 1 loop
      if local_apb_en(i) = '1' then
        -- Select
        if psel_sig(i) = '1' then
          psel_v := i;
        end if;

        -- local IRQ
        pirq_v := pirq_v or apbo(i).pirq;

      end if;
    end loop;
    psel <= psel_v;
    apbi.pirq <= pirq_v;
    -- Get data (valid during rcv_data_or_snd_header if request_msg_type = REQ_REG_WR)
    data_v := apb_rcv_data_out(31 downto 0);

    -- Get data from APB device (valid during snd_data)
    prdata <= (others => '0');
    reply_v := prdata_reg;
    tail_v := PREAMBLE_TAIL & reply_v;
    tail <= tail_v;

    case apb_state is
      when rcv_header => if apb_rcv_empty = '0' and dvfs_transient = '0' then
                           -- Pop from queue
                           apb_rcv_rdreq <= '1';
                           -- Remember request and prepare header for reply
                           sample_request <= '1';
                           -- Update state
                           apb_next <= rcv_address;
                         end if;

      when rcv_address => if apb_rcv_empty = '0' and dvfs_transient = '0' then
                            sample_psel <= '1';
                            if request_msg_type = REQ_REG_RD then
                              if apb_snd_full = '0' then
                                -- Read from device
                                apbi.psel(psel_v) <= '1';
                                apbi.penable <= '1';
                                apbi.paddr <= addr_v;
                                -- Remember APB psel for reply
                                sample_prdata <= '1';
                                prdata <= apbo(psel_v).prdata;
                                -- Update state
                                if pready = '1' then
                                  -- Pop from queue
                                  apb_rcv_rdreq <= '1';
                                  -- Send header to queue
                                  apb_snd_data_in <= header;
                                  apb_snd_wrreq <= '1';
                                  apb_next <= snd_data;
                                end if;
                              end if;
                            else
                              -- Sample write address
                              sample_waddr <= '1';
                              -- Pop from queue
                              apb_rcv_rdreq <= '1';
                              -- Update state
                              apb_next <= rcv_data;
                            end if;
                          end if;


      when rcv_data => if apb_rcv_empty = '0' and dvfs_transient = '0' then
                         -- Pop from queue
                         apb_rcv_rdreq <= '1';
                         -- Write to device
                         apbi_v.psel(psel_reg) := '1';
                         apbi_v.paddr := waddr_reg;
                         apbi_v.pwrite := '1';
                         apbi_v.pwdata := apb_rcv_data_out(31 downto 0);
                         apbi_v.penable := '0';

                         apbi <= apbi_v;
                         apbi_v.penable := '1';
                         apbi_in <= apbi_v;
                         sample_apbi <= '1';
                         apb_next <= apb_write_strobe;
                       end if;

      when apb_write_strobe => apbi <= apbi_reg;
                               if pready = '1' then
                                 apb_next <= rcv_header;
                               end if;

      when snd_data => -- Send data to queue
                       if apb_snd_full = '0' and dvfs_transient = '0' then
                         -- Reply
                         apb_snd_wrreq <= '1';
                         apb_snd_data_in <= tail_v;
                         apb_next <= rcv_header;
                       else
                         -- Keep trying
                         sample_tail <= '1';
                         apb_next <= snd_data_delay;
                       end if;

      when snd_data_delay => if apb_snd_full = '0' and dvfs_transient = '0' then
                               apb_snd_wrreq <= '1';
                               -- Use sampled tail. APB out is not guaranteed to
                               -- be stable
                               apb_snd_data_in <= tail_reg;
                               apb_next <= rcv_header;
                             end if;

      when others => apb_next <= rcv_header;
    end case;
  end process apb_roundtrip;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      apb_state <= rcv_header;
    elsif clk'event and clk = '1' then  -- rising clock edge
      apb_state <= apb_next;
    end if;
  end process;

end rtl;
