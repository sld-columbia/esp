-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
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

entity ext2ahbm is
  generic (
    hindex : integer range 0 to NAHBSLV - 1;
    little_end  : integer range 0 to 1 := 0);
  port (
    clk             : in  std_ulogic;
    rstn            : in  std_ulogic;
    -- Memory link
    fpga_data_in    : out std_logic_vector(ARCH_BITS - 1 downto 0);
    fpga_data_out   : in  std_logic_vector(ARCH_BITS - 1 downto 0);
    fpga_valid_in   : out std_ulogic;
    fpga_valid_out  : in  std_ulogic;
    fpga_data_ien   : out std_logic;
    fpga_clk_in     : out std_logic;
    fpga_clk_out    : in  std_logic;
    fpga_credit_in  : out std_logic;
    fpga_credit_out : in  std_logic;
    ahbmo           : out ahb_mst_out_type;
    ahbmi           : in  ahb_mst_in_type);

end entity ext2ahbm;

architecture rtl of ext2ahbm is

  -- Synchronized to clk
  signal ext_snd_wrreq    : std_ulogic;
  signal ext_snd_data_in  : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_snd_full     : std_ulogic;
  signal ext_snd_almost_full : std_ulogic;
  signal ext_rcv_rdreq    : std_ulogic;
  signal ext_rcv_data_out : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_rcv_empty    : std_ulogic;
  -- Synchronized to fpga_clk_in
  signal ext_snd_rdreq    : std_ulogic;
  signal ext_snd_data_out : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_snd_empty    : std_ulogic;
  -- Synchronized to fpga_clk_out
  signal ext_rcv_wrreq    : std_ulogic;
  signal ext_rcv_data_in  : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_rcv_full     : std_ulogic;

  constant QUEUE_DEPTH : integer := 8;

  signal credits         : integer range 0 to QUEUE_DEPTH;
  signal credit_in       : std_ulogic;
  signal credit_in_empty : std_ulogic;
  signal credit_received : std_ulogic;

  -- State delay
  type rcv_sync_type is record
    sync_clk  : std_ulogic;
    async     : std_ulogic;
    sync_fpga : std_ulogic;
  end record rcv_sync_type;

  type snd_sync_type is record
    sync_clk  : std_ulogic;
    async     : std_ulogic;
    delay     : std_logic_vector(1 downto 0);
    sync_fpga : std_ulogic;
  end record snd_sync_type;

  signal receiving_fsm : std_ulogic;
  signal receiving : rcv_sync_type;
  signal sending : snd_sync_type;

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of receiving : signal is "TRUE";
  -- attribute ASYNC_REG of sending : signal is "TRUE";

  type ext_ahbm_state_t is (receive_address, receive_length, bus_req, receive_data, send_data);

  type ext_ahbm_fsm_t is record
    state   : ext_ahbm_state_t;
    count   : integer;
    haddr   : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    hwrite  : std_ulogic;
    hwdata  : std_logic_vector(ARCH_BITS - 1 downto 0);
    first_busy : std_ulogic;
    valid_data : std_ulogic;
    saved_data : std_logic_vector(ARCH_BITS - 1 downto 0);
  end record ext_ahbm_fsm_t;

  constant DEFAULT_EXT_AHBM : ext_ahbm_fsm_t := (
    state   => receive_address,
    count   => 0,
    haddr   => (others => '0'),
    hwrite  => '0',
    hwdata  => (others => '0'),
    first_busy => '1',
    valid_data => '0',
    saved_data => (others => '0')
    );

  signal r, rin : ext_ahbm_fsm_t;

  -- AHB bus configuration
  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_SLD, SLD_EXTMEM_LINK, 0, 0, 0),
    others => zero32);

  function target_word_hsize
    return std_logic_vector is
  begin
    case ARCH_BITS is
      when 64 => return HSIZE_DWORD;
      when others => return HSIZE_WORD;
    end case;
  end target_word_hsize;

  -- Endianness fix
  function fix_endian (
    le : std_logic_vector(ARCH_BITS - 1 downto 0))
    return std_logic_vector is
    variable be : std_logic_vector(ARCH_BITS - 1 downto 0);
  begin
    if little_end = 0 then
      be := le;
    else
      for i in 0 to (ARCH_BITS / 8) - 1 loop
        be(8 * (i + 1) - 1 downto 8 * i) := le(ARCH_BITS - 8 * i - 1 downto ARCH_BITS - 8 * (i + 1));
      end loop;  -- i
    end if;
    return be;
  end fix_endian;

  -- Bus address increment
  constant default_incr : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0) := conv_std_logic_vector(GLOB_ADDR_INCR, GLOB_PHYS_ADDR_BITS);

  attribute keep : string;
  attribute keep of credits          : signal is "true";
  attribute keep of credit_in        : signal is "true";
  attribute keep of credit_in_empty  : signal is "true";
  attribute keep of ext_snd_wrreq    : signal is "true";
  attribute keep of ext_snd_data_in  : signal is "true";
  attribute keep of ext_snd_full     : signal is "true";
  attribute keep of ext_rcv_rdreq    : signal is "true";
  attribute keep of ext_rcv_data_out : signal is "true";
  attribute keep of ext_rcv_empty    : signal is "true";

begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- Drive fpga_clk_in (use clk if FPGA design freq = link freq)
  fpga_clk_in <= clk;

  -----------------------------------------------------------------------------
  -- Delay FSM state change
  -- Switch from sending (fpga_data_ien = '1') to receiving (fpga_data_ien = '0') in 2
  -- cycles, but switching from receiving to sending in 4 cycles to make sure
  -- pads enables are never driven on both ends of the line at the same time.
  state_synchronizer: process (fpga_clk_out) is
  begin
    if rising_edge(fpga_clk_out) then  -- rising clock edge
      receiving.async <= receiving.sync_clk;
      receiving.sync_fpga <= receiving.async;
    end if;
  end process state_synchronizer;

  state_delay: process (clk) is
  begin
    if rising_edge(clk) then  -- rising clock edge
      receiving.sync_clk <= receiving_fsm;

      sending.async     <= sending.sync_clk;
      sending.delay(0)  <= sending.async;
      sending.delay(1)  <= sending.delay(0);
      sending.sync_fpga <= sending.delay(1) and not receiving.sync_clk;
    end if;
  end process state_delay;


  sending.sync_clk <= not receiving.sync_clk;

  -----------------------------------------------------------------------------
  -- Credits out (to chip)
  fpga_redit_in_reg: process (clk) is
  begin  -- process fpga_redit_in_reg
    if clk'event and clk = '1' then  -- rising clock edge
      fpga_credit_in <= ext_rcv_rdreq;
    end if;
  end process fpga_redit_in_reg;


  -----------------------------------------------------------------------------
  -- Credits in (from chip)
  credits_in_fifo: inferred_async_fifo
    generic map (
      g_data_width => 1,
      g_size       => 2 * QUEUE_DEPTH)
    port map (
      rst_wr_n_i => rstn,
      clk_wr_i   => fpga_clk_out,
      we_i       => fpga_credit_out,
      d_i        => "0",
      wr_full_o  => open,
      rst_rd_n_i => rstn,
      clk_rd_i   => clk,
      rd_i       => '1',
      q_o(0)     => credit_in,
      rd_empty_o => credit_in_empty);

  credit_received <= credit_in nor credit_in_empty;

  process (clk) is
  begin  -- process
    if clk'event and clk = '1' then  -- rising clock edge
      if rstn = '0' then
        credits <= QUEUE_DEPTH;
      else
        if ext_snd_rdreq = '1' and credit_received = '0' and credits /= 0 then
          credits <= credits - 1;
        elsif ext_snd_rdreq = '0' and credit_received = '1' and credits /= QUEUE_DEPTH then
          credits <= credits + 1;
        end if;
      end if;
    end if;
  end process;



  -----------------------------------------------------------------------------
  -- Chip to FPGA
  mem2ext_fifo: inferred_async_fifo
    generic map (
      g_data_width => ARCH_BITS,
      g_size       => 2 * QUEUE_DEPTH)
    port map (
      rst_wr_n_i => rstn,
      clk_wr_i   => fpga_clk_out,
      we_i       => ext_rcv_wrreq,
      d_i        => ext_rcv_data_in,
      wr_full_o  => ext_rcv_full,
      rst_rd_n_i => rstn,
      clk_rd_i   => clk,
      rd_i       => ext_rcv_rdreq,
      q_o        => ext_rcv_data_out,
      rd_empty_o => ext_rcv_empty);

  ext_rcv_wrreq   <= receiving.sync_fpga and fpga_valid_out;
  ext_rcv_data_in <= fpga_data_out;

  -----------------------------------------------------------------------------
  -- FPGA to Chip (this requires no synchronization: clk is fpga_clk_in)
  ext2mem_fifo: fifo3
    generic map (
      depth => 2 * QUEUE_DEPTH,
      width => ARCH_BITS)
    port map (
      clk         => clk,
      rst         => rstn,
      wrreq       => ext_snd_wrreq,
      data_in     => ext_snd_data_in,
      full        => ext_snd_full,
      rdreq       => ext_snd_rdreq,
      data_out    => ext_snd_data_out,
      empty       => ext_snd_empty,
      almost_full => ext_snd_almost_full);

  ext_snd_rdreq <= '0' when credits = 0 else (not ext_snd_empty);
  fpga_data_in  <= ext_snd_data_out;
  fpga_data_ien <= sending.sync_fpga or (not ext_snd_empty);
  fpga_valid_in <= ext_snd_rdreq;

  -----------------------------------------------------------------------------
  -- Handle external link

  -- update stage registers
  state_update: process (clk, rstn) is
  begin  -- process state_update
    if rstn = '0' then                  -- asynchronous reset (active low)
      r <= DEFAULT_EXT_AHBM;
    elsif clk'event and clk = '1' then  -- rising clock edge
      r <= rin;
    end if;
  end process state_update;


  ext_fsm: process (r, ahbmi, ext_rcv_data_out, ext_rcv_empty, ext_snd_full,
                    ext_snd_almost_full) is
    variable v : ext_ahbm_fsm_t;
    variable granted : std_ulogic;
  begin  -- process ext_fsm

    v := r;

    receiving_fsm <= '1';

    ext_rcv_rdreq <= '0';
    ext_snd_wrreq <= '0';
    ext_snd_data_in <= (others => '0');

    granted := ahbmi.hgrant(hindex);

    ahbmo.hbusreq <= '0';
    ahbmo.htrans  <= HTRANS_IDLE;

    v.first_busy := '1';

    case r.state is
      when  receive_address =>
        if ext_rcv_empty = '0' then
          -- Set address
          v.haddr   := ext_rcv_data_out(GLOB_PHYS_ADDR_BITS - 1 downto 1) & '0';
          v.hwrite  := ext_rcv_data_out(0);
          -- Pop ext queue
          ext_rcv_rdreq <= '1';
          -- Update state
          v.state := receive_length;
        end if;


      when receive_length =>
        if ext_rcv_empty = '0' then
          -- Set count
          v.count := conv_integer(ext_rcv_data_out(31 downto 0));
          -- Pop ext queue
          ext_rcv_rdreq <= '1';
          -- Update state
          v.state := bus_req;
        end if;


      when bus_req =>
        if r.hwrite = '1' then
          -- Write transaction
          if ext_rcv_empty = '0' then
            -- Data ready: request bus
            ahbmo.hbusreq <= '1';
            ahbmo.htrans  <= HTRANS_NONSEQ;
            if (granted and ahbmi.hready) = '1' then
              -- Increment address
              v.haddr := r.haddr + default_incr;
              -- Decrement word count
              v.count := r.count - 1;
              -- Set data
              v.hwdata := fix_endian(ext_rcv_data_out);
              -- Pop ext queue
              ext_rcv_rdreq <= '1';
              -- Write data next cycle
              v.state := receive_data;
            end if;
          end if;
        else
          -- Read transaction
          if (ext_snd_almost_full or ext_snd_full) = '0' then
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
              -- Change the channel state from receiving to send
              receiving_fsm <= '0';
            end if;
          end if;
        end if;

      when receive_data =>
        if r.count > 1 then
          ahbmo.hbusreq <= '1';
        end if;
        if r.count = 0 then
          -- Release address bus
          ahbmo.htrans <= HTRANS_IDLE;
          if ahbmi.hready = '1' then
            -- End of transaction
            v.state := receive_address;
          end if;
        elsif ext_rcv_empty = '0' then
          -- Continue with burst transaction
          ahbmo.htrans <= HTRANS_SEQ;
          if ahbmi.hready = '1' then
            -- Data bus acquired
            -- Set data
            v.hwdata := fix_endian(ext_rcv_data_out);
            -- Pop ext queue
            ext_rcv_rdreq <= '1';
            -- Increment address
            v.haddr := r.haddr + default_incr;
            -- Decrement word count
            v.count := r.count - 1;
          end if;
        else
          -- Data not received from chip
          ahbmo.htrans <= HTRANS_BUSY;
        end if;


      when send_data =>
        receiving_fsm <= '0';
        if r.count > 1 then
            ahbmo.hbusreq <= '1';
        end if;
        if r.count = 0 then
          -- Release address bus
          ahbmo.htrans <= HTRANS_IDLE;
          if (granted and ahbmi.hready) = '1' then
            -- Read data is valid
            -- Push ext queue
            if r.valid_data = '1' then
              ext_snd_data_in <= r.saved_data;
              v.valid_data := '0';
            else
              ext_snd_data_in <= fix_endian(ahbmi.hrdata);
            end if;

            ext_snd_wrreq   <= '1';
            -- End of transaction
            v.state := receive_address;
            receiving_fsm <= '1';
          end if;
        elsif (ext_snd_almost_full or ext_snd_full) = '0' then
          ahbmo.htrans <= HTRANS_SEQ;
          -- Continue with burst transaction
          if (granted and ahbmi.hready) = '1' then
            -- Read data is valid
            -- Push ext queue
            if r.valid_data = '1' then
              ext_snd_data_in <= r.saved_data;
              v.valid_data := '0';
            else
              ext_snd_data_in <= fix_endian(ahbmi.hrdata);
            end if;
            ext_snd_wrreq   <= '1';
            -- Increment address
            v.haddr := r.haddr + default_incr;
            -- Decrement word count
            v.count := r.count - 1;
          end if;
        else
          -- ext queue is full
          v.first_busy := '0';
          if r.first_busy = '1' then
            if (granted and ahbmi.hready) = '1' then
              v.saved_data := fix_endian(ahbmi.hrdata);
              v.valid_data := '1';
            else
              v.first_busy := '1';
            end if;
          end if;
          ahbmo.htrans <= HTRANS_BUSY;
        end if;

    end case;

    rin <= v;
  end process ext_fsm;

  ahbmo.haddr   <= r.haddr;
  ahbmo.hwrite  <= r.hwrite;
  ahbmo.hwdata  <= r.hwdata;

  ahbmo.hprot   <= "0011";
  ahbmo.hsize   <= target_word_hsize;
  ahbmo.hlock   <= '0';
  ahbmo.hirq    <= (others => '0');
  ahbmo.hconfig <= hconfig;
  ahbmo.hindex  <= hindex;
  ahbmo.hburst  <= HBURST_INCR;

end architecture rtl;
