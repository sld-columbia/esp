-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
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

entity intreq2noc is
  generic (
    tech  : integer := virtex7;
    ncpu  : integer := 0;
    cpu_y : yx_vec(0 to CFG_NCPU_TILE - 1);
    cpu_x : yx_vec(0 to CFG_NCPU_TILE - 1));
  port (
    rst : in std_ulogic;
    clk : in std_ulogic;

    local_y : in local_yx;
    local_x : in local_yx;

    override_cpu_loc : in std_ulogic;
    cpu_loc_y        : in yx_vec(0 to CFG_NCPU_TILE - 1);
    cpu_loc_x        : in yx_vec(0 to CFG_NCPU_TILE - 1);

    irqi : in  irq_in_vector(0 to ncpu-1);
    irqo : out irq_out_vector(0 to ncpu-1);

    irqi_fifo_overflow : out std_ulogic;  -- Increase queue if asserted

    -- NoC5->tile
    irq_ack_rdreq    : out std_ulogic;
    irq_ack_data_out : in  misc_noc_flit_type;
    irq_ack_empty    : in  std_ulogic;
    -- tile->NoC5
    irq_wrreq        : out std_ulogic;
    irq_data_in      : out misc_noc_flit_type;
    irq_full         : in  std_ulogic);

end intreq2noc;

architecture rtl of intreq2noc is

  constant IRQ_FIFO_DEPTH : integer := 8;
 
  type irq_snd_fsm is (idle, irq_snd_header, irq_snd_payload_1, irq_snd_payload_2);
  type irq_rcv_fsm is (idle, irq_ack_rcv);
  signal irq_snd_state, irq_snd_next : irq_snd_fsm;
  signal irq_rcv_state, irq_rcv_next : irq_rcv_fsm;

  signal irqi_reg     : irq_in_vector(0 to ncpu-1);
  signal irqi_changed : std_logic_vector(ncpu-1 downto 0);

  signal irqo_noc : l3_irq_out_type;
  signal irqo_reg : irq_out_vector(0 to ncpu-1);

  signal intack_delay_1   : std_logic_vector(ncpu-1 downto 0);
  signal intack_delay_2   : std_logic_vector(ncpu-1 downto 0);
  signal same_irl_pending : std_logic_vector(ncpu-1 downto 0);

  signal header    : misc_noc_flit_vector(ncpu-1 downto 0);
  signal payload_1 : misc_noc_flit_vector(ncpu-1 downto 0);
  signal payload_2 : misc_noc_flit_vector(ncpu-1 downto 0);

  signal fifo_header    : misc_noc_flit_vector(ncpu-1 downto 0);
  signal fifo_payload_1 : misc_noc_flit_vector(ncpu-1 downto 0);
  signal fifo_payload_2 : misc_noc_flit_vector(ncpu-1 downto 0);

  signal irqi_send_header    : std_logic_vector(ncpu-1 downto 0);
  signal irqi_send_payload_1 : std_logic_vector(ncpu-1 downto 0);
  signal irqi_send_payload_2 : std_logic_vector(ncpu-1 downto 0);

  signal fifo_full  : std_logic_vector(ncpu-1 downto 0);
  signal fifo_empty : std_logic_vector(ncpu-1 downto 0);
  signal overflow   : std_logic_vector(ncpu-1 downto 0);

  signal priority          : std_logic_vector(ncpu_log(ncpu)-1 downto 0);
  signal forwarding        : std_logic_vector(ncpu_log(ncpu)-1 downto 0);
  signal forwarding_req    : std_logic_vector(ncpu-1 downto 0);
  signal sample_forwarding : std_ulogic;

  signal sample_irq : std_logic_vector(ncpu-1 downto 0);

  -- attribute mark_debug : string;

  -- attribute mark_debug of irqi             : signal is "true";
  -- attribute mark_debug of irqo             : signal is "true";
  -- attribute mark_debug of irq_ack_rdreq    : signal is "true";
  -- attribute mark_debug of irq_ack_data_out : signal is "true";
  -- attribute mark_debug of irq_ack_empty    : signal is "true";
  -- attribute mark_debug of irq_wrreq        : signal is "true";
  -- attribute mark_debug of irq_data_in      : signal is "true";
  -- attribute mark_debug of irq_full         : signal is "true";
  -- attribute mark_debug of irqi_changed     : signal is "true";
  -- attribute mark_debug of fifo_full        : signal is "true";
  -- attribute mark_debug of fifo_empty       : signal is "true";
  -- attribute mark_debug of overflow         : signal is "true";
  -- attribute mark_debug of irq_snd_state    : signal is "true";
  -- attribute mark_debug of irq_rcv_state    : signal is "true";
  -- attribute mark_debug of intack_delay_1   : signal is "true";
  -- attribute mark_debug of intack_delay_2   : signal is "true";
  -- attribute mark_debug of same_irl_pending : signal is "true";


  component gp_arbiter is
    generic (
      log2n : integer range 0 to 4);
    port (
      clk         : in  std_ulogic;
      rst         : in  std_ulogic;
      req_i       : in  std_logic_vector(2**log2n - 1 downto 0);
      req_valid_i : in  std_ulogic;
      gnt_o       : out std_logic_vector(2**log2n - 1 downto 0);
      priority_o  : out std_logic_vector(log2n - 1 downto 0));
  end component gp_arbiter;

  constant zero : std_logic_vector(ncpu-1 downto 0) := (others => '0');
  constant ones : std_logic_vector(ncpu-1 downto 0) := (others => '1');

begin  -- rtl

  irqi_fifo_overflow <= '0' when overflow = zero else '1';
--pragma translate_off
  die_on_overflow : process (clk) is
  begin  -- process die_on_overflow
    if clk'event and clk = '1' then
      if rst /= '0' then
        assert overflow = zero report "IRQ request FIFO overflow" severity failure;
      end if;
    end if;
  end process die_on_overflow;
--pragma translate_on

  ncpu_irq_proxy_gen : for cpuid in ncpu - 1 downto 0 generate

    -- Check for overflow, which must never occur!
    detect_fifo_overflow : process (clk, rst) is
    begin  -- process detect_fifo_overflow
      if rst = '0' then                   -- asynchronous reset (active low)
        overflow(cpuid) <= '0';
      elsif clk'event and clk = '1' then  -- rising clock edge
        if fifo_full(cpuid) = '1' and irqi_changed(cpuid) = '1' then
          overflow(cpuid) <= '1';
        end if;
      end if;
    end process detect_fifo_overflow;

    -- Make a packet for interrupt request
    make_packet : process (irqi(cpuid), local_y, local_x, override_cpu_loc, cpu_loc_y, cpu_loc_x)
      variable msg_type    : noc_msg_type;
      variable tmp         : noc_flit_type;
      variable header_v    : misc_noc_flit_type;
      variable payload_1_v : misc_noc_flit_type;
      variable payload_2_v : misc_noc_flit_type;
      variable reserved    : reserved_field_type;
      variable target_y    : local_yx;
      variable target_x    : local_yx;
    begin  -- process make_packet
      msg_type := IRQ_MSG;

      if GLOB_CPU_ARCH = ariane or GLOB_CPU_ARCH = ibex then
        reserved := "0000" & irqi(cpuid).irl;
      else
        reserved := (others => '0');
      end if;

      if override_cpu_loc = '1' and ncpu > 1 then
        target_y := cpu_loc_y(cpuid);
        target_x := cpu_loc_x(cpuid);
      else
        target_y := cpu_y(cpuid);
        target_x := cpu_x(cpuid);
      end if;

      header_v := (others                                                                       => '0');
      header_v := create_header(MISC_NOC_FLIT_SIZE, local_y, local_x, target_y, target_x, msg_type, reserved);
      if GLOB_CPU_ARCH = ariane or GLOB_CPU_ARCH = ibex then
        header_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_1FLIT;
      end if;


      payload_1_v                                                      := (others => '0');
      payload_1_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_BODY;
      payload_1_v(IRQ_IRL_MSB downto IRQ_IRL_LSB)                      := irqi(cpuid).irl;
      payload_1_v(IRQ_RESUME_BIT)                                      := irqi(cpuid).resume;
      payload_1_v(IRQ_RSTRUN_BIT)                                      := irqi(cpuid).rstrun;
      payload_1_v(IRQ_FORCEERR_BIT)                                    := irqi(cpuid).forceerr;
      payload_1_v(IRQ_PWDSETADDR_BIT)                                  := irqi(cpuid).pwdsetaddr;
      payload_1_v(IRQ_INDEX_MSB downto IRQ_INDEX_LSB)                  := irqi(cpuid).index;

      payload_2_v                                                      := (others => '0');
      payload_2_v(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
      payload_2_v(IRQ_PWDNEWADDR_MSB downto IRQ_PWDNEWADDR_LSB)        := irqi(cpuid).pwdnewaddr;

      header(cpuid)    <= header_v;
      payload_1(cpuid) <= payload_1_v;
      payload_2(cpuid) <= payload_2_v;
    end process make_packet;

    -- Sample interrupt output from IRQMP and determine if it changed
    irqi_sample : process (clk)
    begin  -- process
      if clk'event and clk = '1' then   -- rising clock edge
        irqi_reg(cpuid) <= irqi(cpuid);
      end if;
    end process irqi_sample;

    -- Check if fast IRQ arrived after clear from CPU, but before intack
    -- reached the interrupt controller
    same_irl_pending_detect : process (clk, rst) is
    begin  -- process same_irl_pending_detect
      if rst = '0' then                   -- asynchronous reset (active low)
        same_irl_pending(cpuid) <= '0';
        intack_delay_1(cpuid)   <= '0';
        intack_delay_2(cpuid)   <= '0';
      elsif clk'event and clk = '1' then  -- rising clock edge
        intack_delay_1(cpuid) <= irqo_reg(cpuid).intack;
        intack_delay_2(cpuid) <= intack_delay_1(cpuid);
        if intack_delay_2(cpuid) = '1' and
          irqi(cpuid).irl /= "0000" then
          same_irl_pending(cpuid) <= '1';
        else
          same_irl_pending(cpuid) <= '0';
        end if;
      end if;
    end process same_irl_pending_detect;

    irqi_diff : process (irqi(cpuid), irqi_reg(cpuid), same_irl_pending(cpuid))
    begin  -- process irqi_diff
      irqi_changed(cpuid) <= '0';
      if irqi(cpuid) /= irqi_reg(cpuid) or same_irl_pending(cpuid) = '1' then
        irqi_changed(cpuid) <= '1';
      else
        irqi_changed(cpuid) <= '0';
      end if;
    end process irqi_diff;

    fifo_header_i : fifo0
      generic map (
        depth => IRQ_FIFO_DEPTH,
        width => MISC_NOC_FLIT_SIZE)
      port map (
        clk      => clk,
        rst      => rst,
        rdreq    => irqi_send_header(cpuid),
        wrreq    => irqi_changed(cpuid),
        data_in  => header(cpuid),
        empty    => fifo_empty(cpuid),
        full     => fifo_full(cpuid),
        data_out => fifo_header(cpuid));

    irqlevel_payload_gen: if GLOB_CPU_ARCH = leon3 generate

      fifo_payload_1_i : fifo0
        generic map (
          depth => IRQ_FIFO_DEPTH,
          width => MISC_NOC_FLIT_SIZE)
        port map (
          clk      => clk,
          rst      => rst,
          rdreq    => irqi_send_payload_1(cpuid),
          wrreq    => irqi_changed(cpuid),
          data_in  => payload_1(cpuid),
          empty    => open,
          full     => open,
          data_out => fifo_payload_1(cpuid));

      fifo_payload_2_i : fifo0
        generic map (
          depth => IRQ_FIFO_DEPTH,
          width => MISC_NOC_FLIT_SIZE)
        port map (
          clk      => clk,
          rst      => rst,
          rdreq    => irqi_send_payload_2(cpuid),
          wrreq    => irqi_changed(cpuid),
          data_in  => payload_2(cpuid),
          empty    => open,
          full     => open,
          data_out => fifo_payload_2(cpuid));

    end generate irqlevel_payload_gen;

    unused_fifo_gen: if GLOB_CPU_ARCH /= leon3 generate
      fifo_payload_1(cpuid) <= (others => '0');
      fifo_payload_2(cpuid) <= (others => '0');
    end generate unused_fifo_gen;

    -- Sample interrupt ack.to IRQMP
    irqo(cpuid) <= irqo_reg(cpuid);
    process (clk, rst)
    begin  -- process
      if rst = '0' then                   -- asynchronous reset (active low)
        irqo_reg(cpuid) <= irq_out_none;
      elsif clk'event and clk = '1' then  -- rising clock edge
        if sample_irq(cpuid) = '1' then
          irqo_reg(cpuid) <= irqo_noc;
        end if;
        -- IRQ ACK should only be set for one cycle, but NoC roundtrip takes longer!
        if irqo_reg(cpuid).intack = '1' and sample_irq(cpuid) = '0' then
          irqo_reg(cpuid).intack <= '0';
        end if;
      end if;
    end process;

  end generate ncpu_irq_proxy_gen;


  arbitration_gen : if ncpu > 1 generate
    -- Sample CPUID of IRQ being currenlty forwarded
    sample_current_cpuid : process (clk, rst) is
    begin  -- process update_priority
      if rst = '0' then                   -- asynchronous reset (active low)
        forwarding <= (others => '0');
      elsif clk'event and clk = '1' then  -- rising clock edge
        if sample_forwarding = '1' then
          forwarding <= priority;
        end if;
      end if;
    end process sample_current_cpuid;

    -- Compute which queue (cpuid) has priority
    forwarding_req <= not fifo_empty;
    gp_arbiter_1 : gp_arbiter
      generic map (
        log2n => log2(ncpu))
      port map (
        clk         => clk,
        rst         => rst,
        req_i       => forwarding_req,
        req_valid_i => sample_forwarding,
        gnt_o       => open,
        priority_o  => priority);
  end generate arbitration_gen;

  -- Send interrupt request
  noc_irq_snd : process (irq_snd_state, irq_full, fifo_header,
                         fifo_payload_1, fifo_payload_2,
                         fifo_empty, forwarding)
    variable cpuid : integer range 0 to ncpu-1;
  begin
    irq_snd_next <= irq_snd_state;

    irq_data_in <= (others => '0');
    irq_wrreq   <= '0';

    irqi_send_header    <= (others => '0');
    irqi_send_payload_1 <= (others => '0');
    irqi_send_payload_2 <= (others => '0');

    sample_forwarding <= '0';

    if ncpu > 1 then
      cpuid := conv_integer(forwarding);
    else
      cpuid := 0;
    end if;

    case irq_snd_state is
      when idle =>
        if fifo_empty /= ones then
          sample_forwarding <= '1';
          irq_snd_next      <= irq_snd_header;
        end if;

      when irq_snd_header =>
        if irq_full = '0' then
          irqi_send_header(cpuid) <= '1';
          irq_wrreq               <= '1';
          irq_data_in             <= fifo_header(cpuid);
          if GLOB_CPU_ARCH = leon3 then
            irq_snd_next            <= irq_snd_payload_1;
          else
            irq_snd_next            <= idle;
          end if;
        end if;

      when irq_snd_payload_1 =>
        if irq_full = '0' then
          irqi_send_payload_1(cpuid) <= '1';
          irq_wrreq                  <= '1';
          irq_data_in                <= fifo_payload_1(cpuid);
          irq_snd_next               <= irq_snd_payload_2;
        end if;

      when irq_snd_payload_2 =>
        if irq_full = '0' then
          irqi_send_payload_2(cpuid) <= '1';
          irq_wrreq                  <= '1';
          irq_data_in                <= fifo_payload_2(cpuid);
          irq_snd_next               <= idle;
        end if;

      when others => irq_snd_next <= idle;
    end case;
  end process noc_irq_snd;


  -- Receive interrupt acknowledge
  noc_irq_rcv : process (irq_rcv_state, irq_ack_empty, irq_ack_data_out)
    variable index : integer range 0 to ncpu-1;
  begin  -- process irq_roundtrip
    irq_rcv_next <= irq_rcv_state;
    irqo_noc     <= irq_out_none;

    sample_irq    <= (others => '0');
    irq_ack_rdreq <= '0';

    if ncpu > 1 then
      index := conv_integer(irq_ack_data_out(IRQ_INDEX_LSB + ncpu_log(ncpu) - 1 downto IRQ_INDEX_LSB));
    else
      index := 0;
    end if;

    case irq_rcv_state is
      when idle =>
        if irq_ack_empty = '0' then
          irq_ack_rdreq <= '1';
          irq_rcv_next  <= irq_ack_rcv;
        end if;

      when irq_ack_rcv =>
        if irq_ack_empty = '0' then
          irq_ack_rdreq     <= '1';
          irq_rcv_next      <= idle;
          irqo_noc.irl      <= irq_ack_data_out(IRQ_IRL_MSB downto IRQ_IRL_LSB);
          irqo_noc.intack   <= irq_ack_data_out(IRQ_INTACK_BIT);
          irqo_noc.pwd      <= irq_ack_data_out(IRQ_PWD_BIT);
          irqo_noc.fpen     <= irq_ack_data_out(IRQ_FPEN_BIT);
          irqo_noc.err      <= irq_ack_data_out(IRQ_ERR_BIT);
          sample_irq(index) <= '1';
        end if;

      when others => irq_rcv_next <= idle;
    end case;
  end process noc_irq_rcv;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      irq_rcv_state <= idle;
      irq_snd_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      irq_rcv_state <= irq_rcv_next;
      irq_snd_state <= irq_snd_next;
    end if;
  end process;


end rtl;
