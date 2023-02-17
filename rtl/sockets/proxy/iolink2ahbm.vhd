-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- FPGA Proxy for chip testing and DDR access
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

-------------------------------------------------------------------------------
-- Packet encoding
--
-- Flit 1: Address
--         | GLOB_PHYS_ADDR_BITS - 1 downto 1                      | 0            |
--         | 31 bits                                               | 1 bit        |
--         | address excluding bit 0, which is masked and set to 0 | write_enable |
-- Flit 2: Length
--         | 31 downto 0          |
--         | 31 bits              |
--         | number of data words |
-- Flit 3 to length+2: Data
--         | word_bitwidth-1 downto 0 |
--         | word_bitwidth bits       |
--         | data word                |

-------------------------------------------------------------------------------


entity iolink2ahbm is
  generic (
    hindex        : integer range 0 to NAHBSLV - 1 := 0;
    io_bitwidth   : integer range 1 to 64          := 32;  -- power of 2, <= word_bitwidth
    word_bitwidth : integer range 1 to 64          := 32;  -- 32 or 64
    little_end    : integer range 0 to 1           := 0);
  port (
    clk           : in  std_ulogic;
    rstn          : in  std_ulogic;
    -- Memory link
    io_clk_in     : in  std_logic;
    io_clk_out    : out std_logic;
    io_valid_in   : in  std_ulogic;
    io_valid_out  : out std_ulogic;
    io_credit_in  : in  std_logic;
    io_credit_out : out std_logic;
    io_data_oen   : out std_logic;
    io_data_in    : in  std_logic_vector(io_bitwidth - 1 downto 0);
    io_data_out   : out std_logic_vector(io_bitwidth - 1 downto 0);
    ahbmo         : out ahb_mst_out_type;
    ahbmi         : in  ahb_mst_in_type);

end entity iolink2ahbm;

architecture rtl of iolink2ahbm is

  constant IO_BEATS : natural range 1 to 64 := word_bitwidth / io_bitwidth;

  signal io_clk_out_int   : std_logic;
  signal io_valid_out_int : std_ulogic;

  -- I/O link synchronizers 

  --   synchronized to clk
  signal io_snd_wrreq, io_snd_wrreq_int       : std_ulogic;
  signal io_snd_data_in, io_snd_data_in_int   : std_logic_vector(word_bitwidth - 1 downto 0);
  signal io_snd_full, io_snd_full_int         : std_ulogic;
  signal io_snd_almost_full                   : std_ulogic;
  signal io_rcv_rdreq                         : std_ulogic;
  signal io_rcv_data_out                      : std_logic_vector(word_bitwidth - 1 downto 0);
  signal io_rcv_empty                         : std_ulogic;
  --   synchronized to io_clk_in
  signal io_snd_rdreq, io_snd_rdreq_int       : std_ulogic;
  signal io_snd_data_out, io_snd_data_out_int : std_logic_vector(word_bitwidth - 1 downto 0);
  signal io_snd_empty, io_snd_empty_int       : std_ulogic;
  --   synchronized to io_clk_out
  signal io_rcv_wrreq                         : std_ulogic;
  signal io_rcv_data_in                       : std_logic_vector(word_bitwidth - 1 downto 0);
  signal io_rcv_full                          : std_ulogic;

  constant QUEUE_DEPTH : integer := 8;

  signal credits         : integer range 0 to QUEUE_DEPTH;
  signal credit_in       : std_ulogic;
  signal credit_in_empty : std_ulogic;
  signal credit_received : std_ulogic;

  -- State delay
  type rcv_sync_type is record
    sync_clk    : std_ulogic;
    async       : std_ulogic;
    sync_clk_io : std_ulogic;
  end record rcv_sync_type;

  type snd_sync_type is record
    sync_clk    : std_ulogic;
    async       : std_ulogic;
    delay       : std_logic_vector(1 downto 0);
    sync_clk_io : std_ulogic;
  end record snd_sync_type;

  signal receiving : rcv_sync_type;
  signal sending   : snd_sync_type;

  attribute ASYNC_REG              : string;
  attribute ASYNC_REG of receiving : signal is "TRUE";
  -- attribute ASYNC_REG of sending : signal is "TRUE";

  type iolink2ahbm_state_t is (receive_address, receive_length, bus_req, snd_bus_req,
                               receive_data, send_data, wait_send_data);

  type iolink2ahbm_fsm_t is record
    state  : iolink2ahbm_state_t;
    count  : integer;
    haddr  : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    hwrite : std_ulogic;
    hwdata : std_logic_vector(ARCH_BITS - 1 downto 0);
  end record iolink2ahbm_fsm_t;

  constant DEFAULT_IOLINK2AHBM : iolink2ahbm_fsm_t := (
    state  => receive_address,
    count  => 0,
    haddr  => (others => '0'),
    hwrite => '0',
    hwdata => (others => '0')
    );

  signal r, rin : iolink2ahbm_fsm_t;

  -------------------------------------------------------------------------------
  -- FSM: I/O Receive
  -------------------------------------------------------------------------------
  type io_rcv_reg_type is record
    word : std_logic_vector(word_bitwidth - 1 downto 0);
    cnt  : integer range 0 to 64;
  end record io_rcv_reg_type;

  constant IO_RCV_REG_DEFAULT : io_rcv_reg_type := (
    word => (others => '0'),
    cnt  => 0);

  signal io_rcv_reg, io_rcv_reg_next : io_rcv_reg_type;

  -------------------------------------------------------------------------------
  -- FSM: I/O Send
  -------------------------------------------------------------------------------
  type io_snd_fsm_t is (idle, send);

  type io_snd_reg_type is record
    state : io_snd_fsm_t;
    word  : std_logic_vector(word_bitwidth - 1 downto 0);
    cnt   : integer range 0 to 64;
  end record io_snd_reg_type;

  constant IO_SND_REG_DEFAULT : io_snd_reg_type := (
    state => idle,
    word  => (others => '0'),
    cnt   => 0);

  signal io_snd_reg, io_snd_reg_next : io_snd_reg_type;

  -------------------------------------------------------------------------------
  -- FSM: Output enable
  -------------------------------------------------------------------------------
  type oen_fsm_t is (receive_address, receive_length, receive_data, send_data);

  type oen_reg_type is record
    state  : oen_fsm_t;
    count  : integer;
    write  : std_ulogic;
  end record oen_reg_type;

  constant OEN_REG_DEFAULT : oen_reg_type := (
    state => receive_address,
    count => 0,
    write => '0');

  signal oen_reg, oen_reg_next : oen_reg_type;
  signal oen_fsm_idle, oen_fsm_idle_sync : std_logic;
  
  -- AHB bus configuration
  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_SLD, SLD_IO_LINK, 0, 0, 0),
    others => zero32);

  -- Endianness fix
  function fix_endian (
    le : std_logic_vector(ARCH_BITS -  1 downto 0))
    return std_logic_vector is
    variable be     : std_logic_vector(ARCH_BITS - 1 downto 0);
  begin
    if little_end = 0 then
      be := le;
    else
      for i in 0 to (word_bitwidth / 8) - 1 loop
        be(8 * (i + 1) - 1 downto 8 * i) := le(word_bitwidth - 8 * i - 1 downto word_bitwidth - 8 * (i + 1));
      end loop;  -- i
    end if;
  return be;

  end fix_endian;

  -- Bus address increment
  constant addr_incr_int : natural := word_bitwidth / 8;
  constant default_incr  : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0) :=
    conv_std_logic_vector(addr_incr_int, GLOB_PHYS_ADDR_BITS);

  attribute keep            : string;
  attribute keep of credits : signal is "true";

  attribute mark_debug            : string;
  --attribute mark_debug of io_clk_out_int   : signal is "true";
  --attribute mark_debug of io_valid_out_int : signal is "true";
  --attribute mark_debug of io_snd_wrreq, io_snd_wrreq_int       : signal is "true";
  --attribute mark_debug of io_snd_data_in, io_snd_data_in_int   : signal is "true";
  --attribute mark_debug of io_snd_full, io_snd_full_int         : signal is "true";
  --attribute mark_debug of io_snd_almost_full                   : signal is "true";
  --attribute mark_debug of io_rcv_rdreq                         : signal is "true";
  --attribute mark_debug of io_rcv_data_out                      : signal is "true";
  --attribute mark_debug of io_rcv_empty                         : signal is "true";
  --attribute mark_debug of io_snd_rdreq, io_snd_rdreq_int       : signal is "true";
  --attribute mark_debug of io_snd_data_out, io_snd_data_out_int : signal is "true";
  --attribute mark_debug of io_snd_empty, io_snd_empty_int       : signal is "true";
  --attribute mark_debug of io_rcv_wrreq                         : signal is "true";
  --attribute mark_debug of io_rcv_data_in                       : signal is "true";
  --attribute mark_debug of io_rcv_full                          : signal is "true";
  --attribute mark_debug of credits         : signal is "true";
  --attribute mark_debug of credit_in       : signal is "true";
  --attribute mark_debug of credit_in_empty : signal is "true";
  --attribute mark_debug of credit_received : signal is "true";
  --attribute mark_debug of receiving : signal is "true";
  --attribute mark_debug of sending   : signal is "true";
  --attribute mark_debug of r : signal is "true";
  --attribute mark_debug of io_rcv_reg : signal is "true";
  --attribute mark_debug of io_snd_reg : signal is "true";
  --attribute mark_debug of oen_fsm_idle : signal is "true";

begin  -- architecture rtl

  io_clk_out     <= io_clk_out_int;
  -- if on chip
  io_clk_out_int <= io_clk_in;
  -- if off chip, on FPGA proxy
  -- io_clk_out_int <= clk;

  io_valid_out <= io_valid_out_int;
  
  -----------------------------------------------------------------------------
  -- Delay FSM state change
  -- Switch from sending (io_data_oen = '1') to receiving (io_data_oen = '0') in 2
  -- cycles, but switching from receiving to sending in 4 cycles to make sure
  -- pads enables are never driven on both ends of the line at the same time.
  state_synchronizer : process (io_clk_in) is
  begin
    if rising_edge(io_clk_in) then
      receiving.async       <= receiving.sync_clk;
      receiving.sync_clk_io <= receiving.async;
    end if;
  end process state_synchronizer;

  state_delay : process (io_clk_out_int) is
  begin
    if rising_edge(io_clk_out_int) then
      sending.async       <= sending.sync_clk;
      sending.delay(0)    <= sending.async;
      sending.delay(1)    <= sending.delay(0);
      sending.sync_clk_io <= sending.delay(1) and not receiving.sync_clk;
    end if;
  end process state_delay;

  sending.sync_clk <= not receiving.sync_clk;

  -----------------------------------------------------------------------------
  -- Credits out
  credits_out_reg : process (io_clk_out_int) is
  begin  -- process io_credit_out_reg
    if io_clk_out_int'event and io_clk_out_int = '1' then
      io_credit_out <= io_rcv_rdreq;
    end if;
  end process credits_out_reg;


  -----------------------------------------------------------------------------
  -- Credits in
  credits_in_fifo : inferred_async_fifo
    generic map (
      g_data_width => 1,
      g_size       => 2 * QUEUE_DEPTH)
    port map (
      rst_wr_n_i    => rstn,
      clk_wr_i   => io_clk_in,
      we_i       => io_credit_in,
      d_i        => "0",
      wr_full_o  => open,
      rst_rd_n_i    => rstn,
      clk_rd_i   => clk,
      rd_i       => '1',
      q_o(0)     => credit_in,
      rd_empty_o => credit_in_empty);

  credit_received <= credit_in nor credit_in_empty;

  process (clk) is
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if rstn = '0' then
        credits <= QUEUE_DEPTH;
      else
        if io_snd_rdreq = '1' and credit_received = '0' and credits /= 0 then
          credits <= credits - 1;
        elsif io_snd_rdreq = '0' and credit_received = '1' and credits /= QUEUE_DEPTH then
          credits <= credits + 1;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Receiving FIFO
  io_in_fifo : inferred_async_fifo
    generic map (
      g_data_width => word_bitwidth,
      g_size       => 2 * QUEUE_DEPTH)
    port map (
      rst_wr_n_i    => rstn,
      clk_wr_i   => io_clk_in,
      we_i       => io_rcv_wrreq,
      d_i        => io_rcv_data_in,
      wr_full_o  => io_rcv_full,
      rst_rd_n_i    => rstn,
      clk_rd_i   => clk,
      rd_i       => io_rcv_rdreq,
      q_o        => io_rcv_data_out,
      rd_empty_o => io_rcv_empty);

  -----------------------------------------------------------------------------
  -- Sending FIFO (no synchronization: clk is io_clk_out)

  io_out_fifo : inferred_async_fifo
    generic map (
      g_data_width => word_bitwidth,
      g_size       => QUEUE_DEPTH)
    port map (
      rst_wr_n_i    => rstn,
      clk_wr_i   => clk,
      we_i       => io_snd_wrreq_int,
      d_i        => io_snd_data_in_int,
      wr_full_o  => io_snd_full_int,
      rst_rd_n_i    => rstn,
      clk_rd_i   => io_clk_out_int,
      rd_i       => io_snd_rdreq,
      q_o        => io_snd_data_out,
      rd_empty_o => io_snd_empty);

  io_out_fifo_int : fifo3
    generic map (
      depth => QUEUE_DEPTH,
      width => word_bitwidth)
    port map (
      clk         => clk,
      rst         => rstn,
      wrreq       => io_snd_wrreq,
      data_in     => io_snd_data_in,
      full        => io_snd_full,
      almost_full => io_snd_almost_full,
      rdreq       => io_snd_rdreq_int,
      data_out    => io_snd_data_out_int,
      empty       => io_snd_empty_int);

  io_snd_rdreq_int   <= not io_snd_full_int and not io_snd_empty_int;
  io_snd_wrreq_int   <= not io_snd_full_int and not io_snd_empty_int;
  io_snd_data_in_int <= io_snd_data_out_int;

  io_data_oen <= sending.sync_clk_io;

  -----------------------------------------------------------------------------
  -- Handle I/O link

  -- update stage registers
  state_update : process (clk, rstn) is
  begin  -- process state_update
    if rstn = '0' then                  -- asynchronous reset (active low)
      r <= DEFAULT_IOLINK2AHBM;
    elsif clk'event and clk = '1' then  -- rising clock edge
      r <= rin;
    end if;
  end process state_update;

  rcv_state_update : process (io_clk_in, rstn) is
  begin  -- process state_update
    if rstn = '0' then                  -- asynchronous reset (active low)
      io_rcv_reg <= IO_RCV_REG_DEFAULT;
      oen_reg    <= OEN_REG_DEFAULT;
    elsif io_clk_in'event and io_clk_in = '1' then  -- rising clock edge
      io_rcv_reg <= io_rcv_reg_next;
      oen_reg    <= oen_reg_next;
    end if;
  end process rcv_state_update;

  snd_state_update : process (io_clk_out_int, rstn) is
  begin  -- process state_update
    if rstn = '0' then                  -- asynchronous reset (active low)
      io_snd_reg <= IO_SND_REG_DEFAULT;
    elsif io_clk_out_int'event and io_clk_out_int = '1' then  -- rising clock edge
      io_snd_reg <= io_snd_reg_next;
    end if;
  end process snd_state_update;

  io_rcv_fsm : process (io_rcv_reg, io_rcv_full, io_valid_in, io_data_in, receiving) is
    variable reg : io_rcv_reg_type;
  begin
    reg          := io_rcv_reg;
    io_rcv_wrreq <= '0';

    if io_valid_in = '1' and io_rcv_full = '0' and receiving.sync_clk_io = '1' then
      reg.word((reg.cnt + 1) * io_bitwidth - 1 downto reg.cnt * io_bitwidth) := io_data_in;
      reg.cnt                                                                := reg.cnt + 1;
      if reg.cnt = IO_BEATS then
        reg.cnt        := 0;
        io_rcv_wrreq   <= '1';
        io_rcv_data_in <= reg.word;
      end if;
    end if;

    io_rcv_reg_next <= reg;
  end process io_rcv_fsm;

  io_snd_fsm : process (io_snd_reg, io_snd_empty, io_snd_data_out, credits, sending) is
    variable reg : io_snd_reg_type;
  begin
    reg          := io_snd_reg;
    io_snd_rdreq <= '0';
    io_valid_out_int <= '0';

    case io_snd_reg.state is

      when idle =>
        reg.cnt := 0;
        if credits /= 0 and io_snd_empty = '0' and sending.sync_clk_io = '1' then
          reg.word     := io_snd_data_out;
          io_valid_out_int <= '1';
          io_data_out  <= io_snd_data_out((reg.cnt + 1) * io_bitwidth - 1 downto reg.cnt * io_bitwidth);
          if IO_BEATS > 1 then
            reg.state := send;
            reg.cnt   := reg.cnt + 1;
          else
            io_snd_rdreq <= '1';
          end if;
        end if;

      when send =>
        if credits /= 0 and sending.sync_clk_io = '1' then
          io_valid_out_int <= '1';
          io_data_out  <= io_snd_data_out((reg.cnt + 1) * io_bitwidth - 1 downto reg.cnt * io_bitwidth);
          reg.cnt      := reg.cnt + 1;
          if reg.cnt = IO_BEATS then
            reg.state    := idle;
            io_snd_rdreq <= '1';
          end if;
        end if;

    end case;

    io_snd_reg_next <= reg;

  end process io_snd_fsm;

  oen_fsm : process (oen_reg, io_rcv_wrreq, io_rcv_data_in, io_snd_rdreq) is
    variable reg : oen_reg_type;
  begin
    reg := oen_reg;

    receiving.sync_clk <= '1';

    case oen_reg.state is

      when receive_address =>
        if io_rcv_wrreq = '1' then
          reg.state := receive_length;
          reg.write := io_rcv_data_in(0);
        end if;

      when receive_length =>
        if io_rcv_wrreq = '1' then
          reg.count := conv_integer(io_rcv_data_in(31 downto 0));
          if reg.write = '1' then
            reg.state := receive_data;
          else
            reg.state := send_data;
          end if;
        end if;

      when receive_data =>
        if io_rcv_wrreq = '1' then
          reg.count := reg.count - 1;
          if reg.count = 0 then
            reg.state := receive_address;
          end if;
        end if;

      when send_data =>
        receiving.sync_clk <= '0';
        if io_snd_rdreq = '1' then
          reg.count := reg.count - 1;
          if reg.count = 0 then
            reg.state := receive_address;
          end if;
        end if;

    end case;

    oen_reg_next <= reg;
  end process oen_fsm;

  oen_fsm_idle <= '1' when oen_reg.state = receive_address else '0';
  
  -- Credits in
  oen_reg_fifo : inferred_async_fifo
    generic map (
      g_data_width => 1,
      g_size       => 2)
    port map (
      rst_wr_n_i    => rstn,
      clk_wr_i   => io_clk_in,
      we_i       => '1',
      d_i(0)     => oen_fsm_idle,
      wr_full_o  => open,
      rst_rd_n_i    => rstn,
      clk_rd_i   => clk,
      rd_i       => '1',
      q_o(0)     => oen_fsm_idle_sync,
      rd_empty_o => open);

  
  io_fsm : process (r, ahbmi, oen_fsm_idle_sync,
                    io_rcv_data_out, io_rcv_empty,
                    io_snd_full, io_snd_almost_full) is
    variable v       : iolink2ahbm_fsm_t;
    variable granted : std_ulogic;
  begin  -- process io_fsm

    v := r;

    -- receiving.sync_clk <= '1';

    io_rcv_rdreq   <= '0';
    io_snd_wrreq   <= '0';
    io_snd_data_in <= (others => '0');

    granted := ahbmi.hgrant(hindex);

    ahbmo.hbusreq <= '0';
    ahbmo.htrans  <= HTRANS_IDLE;

    case r.state is

      when receive_address =>
        if io_rcv_empty = '0' then
          -- Set address
          v.haddr      := io_rcv_data_out(GLOB_PHYS_ADDR_BITS - 1 downto 1) & '0';
          v.hwrite     := io_rcv_data_out(0);
          -- Pop io queue
          io_rcv_rdreq <= '1';
          -- Update state
          v.state      := receive_length;
        end if;

      when receive_length =>
        if io_rcv_empty = '0' then
          -- Set count
          v.count      := conv_integer(io_rcv_data_out(31 downto 0));
          -- Pop io queue
          io_rcv_rdreq <= '1';
          -- Update state
          v.state      := bus_req;
        end if;

      when bus_req =>
        if r.hwrite = '1' then
          -- Write transaction
          if io_rcv_empty = '0' then
            -- Data ready: request bus
            ahbmo.hbusreq <= '1';
            if (granted and ahbmi.hready) = '1' then
              v.state := snd_bus_req;
            end if;
          end if;
        else
          -- Read transaction
          if (io_snd_almost_full or io_snd_full) = '0' then
            -- Queue is available: request bus
            ahbmo.hbusreq <= '1';
            if (granted and ahbmi.hready) = '1' then
              v.state := snd_bus_req;
            end if;
          end if;
        end if;

      when snd_bus_req =>
        if r.hwrite = '1' then
          -- Write transaction
          if io_rcv_empty = '0' then
            -- Data ready: request bus
            ahbmo.hbusreq <= '1';
            ahbmo.htrans  <= HTRANS_NONSEQ;
            if (granted and ahbmi.hready) = '1' then
              -- Increment address
              v.haddr      := r.haddr + default_incr;
              -- Decrement word count
              v.count      := r.count - 1;
              -- Set data
              v.hwdata     := fix_endian(ahbdrivedata(io_rcv_data_out));
              -- Pop io queue
              io_rcv_rdreq <= '1';
              -- Write data next cycle
              v.state      := receive_data;
            end if;
          end if;
        else
          -- Read transaction
          if (io_snd_almost_full or io_snd_full) = '0' then
            -- Queue is available: request bus
            ahbmo.hbusreq <= '1';
            ahbmo.htrans  <= HTRANS_NONSEQ;
            if (granted and ahbmi.hready) = '1' then
              -- Increment address
              v.haddr := r.haddr + default_incr;
              -- Decrement word count
              v.count := r.count - 1;
              -- Read data next time hready is high
              v.state := send_data;
            end if;
          end if;
        end if;

      when receive_data =>
        if r.count = 0 then
          -- Release address bus
          -- End of transaction
          ahbmo.htrans <= HTRANS_IDLE;
          v.state := receive_address;
        elsif io_rcv_empty = '0' then
          -- Continue with burst transaction
          ahbmo.htrans <= HTRANS_SEQ;
          ahbmo.hbusreq <= '1';
          if (granted and ahbmi.hready) = '1' then
            -- Data bus acquired
            -- Set data
            v.hwdata     := fix_endian(ahbdrivedata(io_rcv_data_out));
            -- Pop io queue
            io_rcv_rdreq <= '1';
            -- Increment address
            v.haddr      := r.haddr + default_incr;
            -- Decrement word count
            v.count      := r.count - 1;
          end if;
        else
          -- Data not received from chip
          ahbmo.htrans <= HTRANS_BUSY;
        end if;


      when send_data =>
        -- receiving.sync_clk <= '0';
        if r.count = 0 then
          -- Release address bus
          ahbmo.htrans <= HTRANS_IDLE;
          if (ahbmi.hready) = '1' then
            -- Read data is valid
            -- Push io queue
            io_snd_data_in <= ahbreadword(fix_endian(ahbmi.hrdata));
            io_snd_wrreq   <= '1';
            -- End of transaction
            v.state        := wait_send_data;
          end if;
        elsif (io_snd_almost_full or io_snd_full) = '0' then
          -- Continue with burst transaction
          ahbmo.htrans <= HTRANS_SEQ;
          if (ahbmi.hready) = '1' then
            -- Read data is valid
            -- Push io queue
            io_snd_data_in <= ahbreadword(fix_endian(ahbmi.hrdata));
            io_snd_wrreq   <= '1';
            -- Increment address
            v.haddr        := r.haddr + default_incr;
            -- Decrement word count
            v.count        := r.count - 1;
            if r.count = 1 then
              -- Let abritration occur at the next cycle
              ahbmo.hbusreq <= '0';
            else
              ahbmo.hbusreq <= '1';
            end if;
          end if;
        else
          -- io queue is full
          ahbmo.htrans <= HTRANS_BUSY;
        end if;

      when wait_send_data =>
        if oen_fsm_idle_sync = '1' then
          v.state := receive_address;
        end if;

    end case;

    rin <= v;
  end process io_fsm;

  ahbmo.haddr  <= r.haddr;
  ahbmo.hwrite <= r.hwrite;
  ahbmo.hwdata <= r.hwdata;

  ahbmo.hprot   <= "0011";
  ahbmo.hsize   <= HSIZE_WORD;
  ahbmo.hlock   <= '0';
  ahbmo.hirq    <= (others => '0');
  ahbmo.hconfig <= hconfig;
  ahbmo.hindex  <= hindex;
  ahbmo.hburst  <= HBURST_INCR;

end architecture rtl;
