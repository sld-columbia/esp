-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;

use work.coretypes.all;

use work.esp_global.all;

entity intack2noc is
  generic (
    tech  : integer := virtex7;
    irq_y : local_yx;
    irq_x : local_yx);
  port (
    rst : in std_ulogic;
    clk : in std_ulogic;

    cpu_id  : in integer range 0 to CFG_NCPU_TILE - 1;
    local_y : in local_yx;
    local_x : in local_yx;

    irqi : out l3_irq_in_type;
    irqo : in  l3_irq_out_type;

    irqo_fifo_overflow : out std_ulogic;  -- Increase queue if asserted

    -- NoC5->tile
    remote_irq_rdreq       : out std_ulogic;
    remote_irq_data_out    : in  misc_noc_flit_type;
    remote_irq_empty       : in  std_ulogic;
    -- tile->NoC5
    remote_irq_ack_wrreq   : out std_ulogic;
    remote_irq_ack_data_in : out misc_noc_flit_type;
    remote_irq_ack_full    : in  std_ulogic);

end intack2noc;

architecture rtl of intack2noc is

  constant IRQ_FIFO_DEPTH : integer := 8;

  type irq_snd_fsm is (idle, irq_snd_header, irq_snd_payload_1);
  type irq_rcv_fsm is (reset_active, reset_released, idle, irq_rcv_req_1, irq_rcv_req_2);
  signal irq_snd_state, irq_snd_next : irq_snd_fsm;
  signal irq_rcv_state, irq_rcv_next : irq_rcv_fsm;

  signal irqo_reg     : l3_irq_out_type;
  signal irqo_changed : std_ulogic;

  signal irqi_noc : l3_irq_in_type;
  signal irqi_reg : l3_irq_in_type;

  signal header    : misc_noc_flit_type;
  signal payload_1 : misc_noc_flit_type;

  signal fifo_header    : misc_noc_flit_type;
  signal fifo_payload_1 : misc_noc_flit_type;

  signal irqo_send_header    : std_ulogic;
  signal irqo_send_payload_1 : std_ulogic;

  signal fifo_full  : std_ulogic;
  signal fifo_empty : std_ulogic;
  signal overflow   : std_ulogic;

  signal sample_irq_1 : std_ulogic;
  signal sample_irq_2 : std_ulogic;

  signal rst_int : std_ulogic;

  -- attribute mark_debug : string;

  -- attribute mark_debug of irqi                   : signal is "true";
  -- attribute mark_debug of irqo                   : signal is "true";
  -- attribute mark_debug of remote_irq_rdreq       : signal is "true";
  -- attribute mark_debug of remote_irq_data_out    : signal is "true";
  -- attribute mark_debug of remote_irq_empty       : signal is "true";
  -- attribute mark_debug of remote_irq_ack_wrreq   : signal is "true";
  -- attribute mark_debug of remote_irq_ack_data_in : signal is "true";
  -- attribute mark_debug of remote_irq_ack_full    : signal is "true";
  -- attribute mark_debug of irqo_changed           : signal is "true";
  -- attribute mark_debug of fifo_full              : signal is "true";
  -- attribute mark_debug of fifo_empty             : signal is "true";
  -- attribute mark_debug of overflow               : signal is "true";
  -- attribute mark_debug of irq_snd_state          : signal is "true";
  -- attribute mark_debug of irq_rcv_state          : signal is "true";

begin  -- rtl

  -- Check for overflow, which must never occur!
  irqo_fifo_overflow <= overflow;
--pragma translate_off
  die_on_overflow : process (clk) is
  begin  -- process die_on_overflow
    if clk'event and clk = '1' then
      if rst /= '0' then
        assert overflow = '0' report "IRQ acknowledge FIFO overflow" severity failure;
      end if;
    end if;
  end process die_on_overflow;
--pragma translate_on

  detect_fifo_overflow : process (clk, rst) is
  begin  -- process detect_fifo_overflow
    if rst = '0' then                   -- asynchronous reset (active low)
      overflow <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if fifo_full = '1' and irqo_changed = '1' then
        overflow <= '1';
      end if;
    end if;
  end process detect_fifo_overflow;

  -- Make a packet for interrupt acknowledge
  make_packet : process (irqo, cpu_id, local_y, local_x)
    variable msg_type    : noc_msg_type;
    variable header_v    : misc_noc_flit_type;
    variable payload_1_v : misc_noc_flit_type;
  begin  -- process make_packet
    msg_type := IRQ_MSG;

    header_v := (others                                                         => '0');
    header_v := create_header(MISC_NOC_FLIT_SIZE, local_y, local_x, irq_y, irq_x, msg_type, (others => '0'))(MISC_NOC_FLIT_SIZE - 1 downto 0);

    payload_1_v                                                      := (others => '0');
    payload_1_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    payload_1_v(IRQ_IRL_MSB downto IRQ_IRL_LSB)                      := irqo.irl;
    payload_1_v(IRQ_INTACK_BIT)                                      := irqo.intack;
    payload_1_v(IRQ_PWD_BIT)                                         := irqo.pwd;
    payload_1_v(IRQ_FPEN_BIT)                                        := irqo.fpen;
    payload_1_v(IRQ_ERR_BIT)                                         := irqo.err;
    payload_1_v(IRQ_INDEX_MSB downto IRQ_INDEX_LSB)                  := conv_std_logic_vector(cpu_id, 4);

    header    <= header_v;
    payload_1 <= payload_1_v;
  end process make_packet;

  -- Sample interrupt output from CPU and determine if it changed
  irqo_sample : process (clk) is
  begin  -- process irqo_sample
    if clk'event and clk = '1' then  -- rising clock edge
      irqo_reg <= irqo;
    end if;
  end process irqo_sample;

  irqo_diff : process (irqo, irqo_reg) is
  begin  -- process irqo_diff
    if irqo /= irqo_reg then
      irqo_changed <= '1';
    else
      irqo_changed <= '0';
    end if;
  end process irqo_diff;

  fifo_header_i : fifo0
    generic map (
      depth => IRQ_FIFO_DEPTH,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => rst,
      rdreq    => irqo_send_header,
      wrreq    => irqo_changed,
      data_in  => header,
      empty    => fifo_empty,
      full     => fifo_full,
      data_out => fifo_header);

  fifo_payload_1_i : fifo0
    generic map (
      depth => IRQ_FIFO_DEPTH,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => rst,
      rdreq    => irqo_send_payload_1,
      wrreq    => irqo_changed,
      data_in  => payload_1,
      empty    => open,
      full     => open,
      data_out => fifo_payload_1);

  -- Sample reset
  rst_int_gen: process (clk) is
  begin  -- process rst_int_gen
    if clk'event and clk = '1' then  -- rising clock edge
      rst_int <= rst;
    end if;
  end process rst_int_gen;

  -- Sample interrupt to CPU
  leon3_irqi_gen: if GLOB_CPU_ARCH = leon3 generate
    process (clk)
      variable irqi_v : l3_irq_in_type;
    begin  -- process
      if clk'event and clk = '1' then  -- rising clock edge
        irqi_v.irl        := irqi_noc.irl;
        irqi_v.resume     := irqi_noc.resume;
        irqi_v.rstvec     := irqi_noc.rstvec;
        irqi_v.rstrun     := irqi_noc.rstrun;
        irqi_v.forceerr   := irqi_noc.forceerr;
        irqi_v.pwdsetaddr := irqi_noc.pwdsetaddr;
        irqi_v.index      := irqi_noc.index;

        if sample_irq_1 = '1' then
          -- Save partial IRQ request info (first flit)
          irqi_reg <= irqi_v;
        end if;

        if rst = '0' then
          irqi             <= irq_in_none;
        elsif sample_irq_2 = '1' then
          -- Complete IRQ request info (second flit)
          irqi_v            := irqi_reg;
          irqi_v.pwdnewaddr := irqi_noc.pwdnewaddr;
          irqi              <= irqi_v;
        elsif irqo.intack = '1' then
          -- When intack is asserted, previous irl should be cleared (TODO: check!)
          irqi.irl <= (others => '0');
        end if;
      end if;
    end process;
  end generate leon3_irqi_gen;

  geneirc_irqi_gen: if GLOB_CPU_ARCH /= leon3 generate
    irqi <= irqi_reg;

    process (clk, rst) is
    begin  -- process
      if rst = '0' then             -- asynchronous reset (active low)
        irqi_reg <= irq_in_none;
        -- RISC-V CLINT timer_irq is set high after reset
        irqi_reg.irl(2) <= '1';
      elsif clk'event and clk = '1' then  -- rising clock edge
        if sample_irq_1 = '1' then
          irqi_reg <= irqi_noc;
        end if;
      end if;
    end process;
  end generate geneirc_irqi_gen;

  -- Send interrupt acknowledge
  noc_irq_snd : process (irq_snd_state, remote_irq_ack_full, fifo_header,
                         fifo_payload_1, fifo_empty)
  begin
    irq_snd_next <= irq_snd_state;

    remote_irq_ack_data_in <= (others => '0');
    remote_irq_ack_wrreq   <= '0';

    irqo_send_header    <= '0';
    irqo_send_payload_1 <= '0';

    case irq_snd_state is
      when idle =>
        if fifo_empty /= '1' and GLOB_CPU_ARCH = leon3 then
          irq_snd_next <= irq_snd_header;
        end if;

      when irq_snd_header =>
        if remote_irq_ack_full = '0' then
          irqo_send_header       <= '1';
          remote_irq_ack_wrreq   <= '1';
          remote_irq_ack_data_in <= fifo_header;
          irq_snd_next           <= irq_snd_payload_1;
        end if;

      when irq_snd_payload_1 =>
        if remote_irq_ack_full = '0' then
          irqo_send_payload_1    <= '1';
          remote_irq_ack_wrreq   <= '1';
          remote_irq_ack_data_in <= fifo_payload_1;
          if fifo_empty /= '1' then
            irq_snd_next <= irq_snd_header;
          else
            irq_snd_next <= idle;
          end if;
        end if;

      when others => irq_snd_next <= idle;
    end case;
  end process noc_irq_snd;


  -- Receive interrupt request
  noc_irq_rcv : process (irq_rcv_state, remote_irq_empty, remote_irq_data_out, cpu_id, rst_int)
  begin  -- process irq_roundtrip
    irq_rcv_next <= irq_rcv_state;
    irqi_noc     <= irq_in_none;

    sample_irq_1     <= '0';
    sample_irq_2     <= '0';
    remote_irq_rdreq <= '0';

    case irq_rcv_state is
      when reset_active =>
        if cpu_id = 0 then
          irqi_noc.rstrun <= '1';
        end if;
        irqi_noc.index <= conv_std_logic_vector(cpu_id, 4);
        sample_irq_1 <= '1';
        if rst_int = '1' then
          irq_rcv_next <= reset_released;
        end if;

      when reset_released =>
        sample_irq_2 <= '1';
        irq_rcv_next <= idle;

      when idle =>
        if remote_irq_empty = '0' then
          remote_irq_rdreq <= '1';
          if GLOB_CPU_ARCH = leon3 then
            irq_rcv_next     <= irq_rcv_req_1;
          else
            -- reserved field is 4 bits; reused for RISC-V -> {clint.ipi, clint.timer_irq, plic.irq}
            irqi_noc.irl <= get_reserved_field(MISC_NOC_FLIT_SIZE, noc_flit_pad & remote_irq_data_out)(3 downto 0);
            sample_irq_1 <= '1';
            irq_rcv_next <= idle;
          end if;
        end if;

      when irq_rcv_req_1 =>
        if remote_irq_empty = '0' then
          remote_irq_rdreq    <= '1';
          irq_rcv_next        <= irq_rcv_req_2;
          irqi_noc.irl        <= remote_irq_data_out(IRQ_IRL_MSB downto IRQ_IRL_LSB);
          irqi_noc.resume     <= remote_irq_data_out(IRQ_RESUME_BIT);
          irqi_noc.rstrun     <= remote_irq_data_out(IRQ_RSTRUN_BIT);
          irqi_noc.forceerr   <= remote_irq_data_out(IRQ_FORCEERR_BIT);
          irqi_noc.pwdsetaddr <= remote_irq_data_out(IRQ_PWDSETADDR_BIT);
          irqi_noc.index      <= remote_irq_data_out(IRQ_INDEX_MSB downto IRQ_INDEX_LSB);
          sample_irq_1        <= '1';
        end if;

      when irq_rcv_req_2 =>
        if remote_irq_empty = '0' then
          remote_irq_rdreq    <= '1';
          irqi_noc.pwdnewaddr <= remote_irq_data_out(IRQ_PWDNEWADDR_MSB downto IRQ_PWDNEWADDR_LSB);
          sample_irq_2        <= '1';
          irq_rcv_next        <= idle;
        end if;

      when others => irq_rcv_next <= idle;
    end case;
  end process noc_irq_rcv;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      if GLOB_CPU_ARCH = leon3 then
        irq_rcv_state <= reset_active;
      else
        irq_rcv_state <= idle;
      end if;
      irq_snd_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      irq_rcv_state <= irq_rcv_next;
      irq_snd_state <= irq_snd_next;
    end if;
  end process;

end rtl;
