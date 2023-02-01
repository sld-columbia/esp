-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- FPGA Proxy for chip testing and DDR access
--
-- This module can only handle LLC requests and non-coherent DMA transactions.
-- Hence, the ESP cache hierarchy must be enabled when using this proxy.
-- In addition, the EDCL module in the I/O tile  won't be able to access memory.
-- To load programs and data into main memory, a second EDCL must be available
-- in the FPGA design that hosts the DDR controllers.
--
-- To improve link performance, the read/write bit is combined with the address.
-- Trasnsactions are assumed to be of an integer number of entire words (64 or
-- 32 bits depending on the global variable ARCH_BITS). The address is,
-- therefore, forced to be aligned with one word (LSBs are zeroed) and address
-- bit zero is used as write (not read) flag. The assumption on hsize is always
-- valid for LLC requests (full cache-line access) and DMA transactions.
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
use work.monitor_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity mem2ext is

  port (
    clk               : in  std_ulogic;
    rstn              : in  std_ulogic;
    local_y           : in  local_yx;
    local_x           : in  local_yx;
    -- Memory link
    fpga_data_in      : in  std_logic_vector(ARCH_BITS - 1 downto 0);
    fpga_data_out     : out std_logic_vector(ARCH_BITS - 1 downto 0);
    fpga_valid_in     : in  std_logic;
    fpga_valid_out    : out std_logic;
    fpga_oen          : out std_logic;
    fpga_clk_in       : in  std_logic;
    fpga_clk_out      : out std_logic;
    fpga_credit_in    : in  std_logic;
    fpga_credit_out   : out std_logic;
    -- LLC->ext
    llc_ext_req_ready : out std_ulogic;
    llc_ext_req_valid : in  std_ulogic;
    llc_ext_req_data  : in  std_logic_vector(ARCH_BITS - 1 downto 0);
    -- ext->LLC
    llc_ext_rsp_ready : in  std_ulogic;
    llc_ext_rsp_valid : out std_ulogic;
    llc_ext_rsp_data  : out std_logic_vector(ARCH_BITS - 1 downto 0);
    -- DMA->ext
    dma_rcv_rdreq              : out std_ulogic;
    dma_rcv_data_out           : in  noc_flit_type;
    dma_rcv_empty              : in  std_ulogic;
    -- ext->DMA
    dma_snd_wrreq              : out std_ulogic;
    dma_snd_data_in            : out noc_flit_type;
    dma_snd_full               : in  std_ulogic
    );
end mem2ext;

architecture rtl of mem2ext is

  -- Synchronized to clk
  signal ext_snd_wrreq    : std_ulogic;
  signal ext_snd_data_in  : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_snd_full     : std_ulogic;
  signal ext_rcv_rdreq    : std_ulogic;
  signal ext_rcv_data_out : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_rcv_empty    : std_ulogic;
  -- Synchronized to fpga_clk_in
  signal ext_snd_rdreq    : std_ulogic;
  signal ext_snd_data_out : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_snd_empty    : std_ulogic;
  signal ext_rcv_wrreq    : std_ulogic;
  signal ext_rcv_data_in  : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_rcv_full     : std_ulogic;

  constant LSB : integer := GLOB_BYTE_OFFSET_BITS;
  constant QUEUE_DEPTH : integer := 8;

  signal credits          : integer range 0 to QUEUE_DEPTH;
  signal credit_out       : std_ulogic;
  signal credit_out_empty : std_ulogic;

  signal fpga_credit_in_int : std_ulogic;

  type ext_req_type is (llc_req, dma_req);
  signal req, req_reg : ext_req_type;

  type ext_state_type is (idle, send_addr, send_len, send_data, recv_header, recv_data);
  signal ext_current, ext_next : ext_state_type;

  signal dma_header, dma_header_reg                   : noc_flit_type;
  signal dma_writing, dma_writing_reg                 : std_ulogic;
  signal llc_writing, llc_writing_reg                 : std_ulogic;

  signal sample_header : std_ulogic;

  -- Assume at most 32-bit lenght. No need for a 64-bit counter!
  signal tran_count, tran_count_reg : std_logic_vector(31 downto 0);

  signal sample_tran_count : std_ulogic;
  signal tran_count_en : std_ulogic;

  -- State synchronizer
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

  signal receiving : rcv_sync_type;
  signal sending : snd_sync_type;

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of receiving : signal is "TRUE";
  attribute ASYNC_REG of sending : signal is "TRUE";

  attribute keep : string;
  attribute keep of credits          : signal is "true";
  attribute keep of credit_out       : signal is "true";
  attribute keep of credit_out_empty : signal is "true";
  attribute keep of ext_snd_wrreq    : signal is "true";
  attribute keep of ext_snd_data_in  : signal is "true";
  attribute keep of ext_snd_full     : signal is "true";
  attribute keep of ext_rcv_rdreq    : signal is "true";
  attribute keep of ext_rcv_data_out : signal is "true";
  attribute keep of ext_rcv_empty    : signal is "true";


begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- Drive fpga_clk_out (should be lenght-matched w/ credit and data)
  fpga_clk_out <= fpga_clk_in;

  -----------------------------------------------------------------------------
  -- Synchronize FSM state to FPGA clock
  -- Switch from sending (fpga_oen = '1') to receiving (fpga_oen = '0') in 2
  -- cycles, but switching from receiving to sending in 4 cycles to make sure
  -- pads enables are never driven on both ends of the line at the same time.
  state_synchronizer: process (fpga_clk_in) is
  begin
    if rising_edge(fpga_clk_in) then  -- rising clock edge
      receiving.async <= receiving.sync_clk;
      receiving.sync_fpga <= receiving.async;

      sending.async <= sending.sync_clk;
      sending.delay(0) <= sending.async;
      sending.delay(1) <= sending.delay(0);
      sending.sync_fpga <= sending.delay(1) and not receiving.sync_fpga;
    end if;
  end process state_synchronizer;

  sending.sync_clk <= not receiving.sync_clk;

  -----------------------------------------------------------------------------
  -- Credits in
  process (fpga_clk_in) is
  begin  -- process
    if fpga_clk_in'event and fpga_clk_in = '1' then  -- rising clock edge
      if rstn = '0' then
        credits <= QUEUE_DEPTH;
        fpga_credit_in_int <= '0';
      else
        fpga_credit_in_int <= fpga_credit_in;
        if ext_snd_rdreq = '1' and fpga_credit_in_int = '0' and credits /= 0 then
          credits <= credits - 1;
        elsif ext_snd_rdreq = '0' and fpga_credit_in_int = '1' and credits /= QUEUE_DEPTH then
          credits <= credits + 1;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Credits out
  credits_out_fifo: inferred_async_fifo
    generic map (
      g_data_width => 1,
      g_size       => 2 * QUEUE_DEPTH)
    port map (
      rst_wr_n_i => rstn,
      clk_wr_i   => clk,
      we_i       => ext_rcv_rdreq,
      d_i        => "0",
      wr_full_o  => open,
      rst_rd_n_i => rstn,
      clk_rd_i   => fpga_clk_in,
      rd_i       => '1',
      q_o(0)     => credit_out,
      rd_empty_o => credit_out_empty);

  fpga_credit_out <= credit_out nor credit_out_empty;


  -----------------------------------------------------------------------------
  -- Chip to FPGA
  mem2ext_fifo: inferred_async_fifo
    generic map (
      g_data_width => ARCH_BITS,
      g_size       => 2 * QUEUE_DEPTH)
    port map (
      rst_wr_n_i => rstn,
      clk_wr_i   => clk,
      we_i       => ext_snd_wrreq,
      d_i        => ext_snd_data_in,
      wr_full_o  => ext_snd_full,
      rst_rd_n_i => rstn,
      clk_rd_i   => fpga_clk_in,
      rd_i       => ext_snd_rdreq,
      q_o        => ext_snd_data_out,
      rd_empty_o => ext_snd_empty);

  ext_snd_rdreq  <= '0' when credits = 0 else (not ext_snd_empty);
  fpga_data_out  <= ext_snd_data_out;
  fpga_oen       <= sending.sync_fpga or (not ext_snd_empty);
  fpga_valid_out <= ext_snd_rdreq;

  -----------------------------------------------------------------------------
  -- FPGA to Chip
  ext2mem_fifo: inferred_async_fifo
    generic map (
      g_data_width => ARCH_BITS,
      g_size       => 2 * QUEUE_DEPTH)
    port map (
      rst_wr_n_i => rstn,
      clk_wr_i   => fpga_clk_in,
      we_i       => ext_rcv_wrreq,
      d_i        => ext_rcv_data_in,
      wr_full_o  => ext_rcv_full,       -- ignored: using credits
      rst_rd_n_i => rstn,
      clk_rd_i   => clk,
      rd_i       => ext_rcv_rdreq,
      q_o        => ext_rcv_data_out,
      rd_empty_o => ext_rcv_empty);

  ext_rcv_wrreq   <= receiving.sync_fpga and fpga_valid_in;
  ext_rcv_data_in <= fpga_data_in;

  -----------------------------------------------------------------------------
  -- Handle external link

  -- Create packet for DMA response message
  make_dma_packet : process (dma_rcv_data_out, local_y, local_x) is
    variable msg_type_req       : noc_msg_type;
    variable msg_type_rsp       : noc_msg_type;
    variable header_v           : noc_flit_type;
    variable reserved           : reserved_field_type;
    variable origin_y, origin_x : local_yx;
  begin  -- process make_packet
    msg_type_req := get_msg_type(NOC_FLIT_SIZE, dma_rcv_data_out);
    if msg_type_req = DMA_FROM_DEV or msg_type_req = REQ_DMA_WRITE then
      dma_writing <= '1';
      msg_type_rsp := DMA_TO_DEV;
    elsif msg_type_req = REQ_DMA_READ then
      dma_writing <= '0';
      msg_type_rsp := RSP_DATA_DMA;
    else
      dma_writing <= '0';
      msg_type_rsp := DMA_TO_DEV;
    end if;

    reserved   := (others => '0');
    header_v   := (others => '0');
    origin_y   := get_origin_y(NOC_FLIT_SIZE, dma_rcv_data_out);
    origin_x   := get_origin_x(NOC_FLIT_SIZE, dma_rcv_data_out);
    header_v   := create_header(NOC_FLIT_SIZE, local_y, local_x, origin_y, origin_x, msg_type_rsp, reserved);
    dma_header <= header_v;
  end process make_dma_packet;

  -- Parse LLC request (using LSBs of address as control bits)
  llc_writing <= llc_ext_req_data(0);

  -- Update state registers
  state_update: process (clk) is
  begin  -- process state_update
    if clk'event and clk = '1' then     -- rising clock edge
      if rstn = '0' then
        ext_current     <= idle;
        req_reg         <= llc_req;
        dma_header_reg  <= (others => '0');
        dma_writing_reg <= '0';
        llc_writing_reg <= '0';
        tran_count_reg  <= (others => '0');
      else
        ext_current <= ext_next;
        if sample_header = '1' then
          req_reg         <= req;
          dma_header_reg  <= dma_header;
          dma_writing_reg <= dma_writing;
          llc_writing_reg <= llc_writing;
        end if;
        if sample_tran_count = '1' then
          tran_count_reg <= tran_count;
        elsif tran_count_en = '1' then
          tran_count_reg <= tran_count_reg - conv_std_logic_vector(1, 32);
        end if;
      end if;
    end if;
  end process state_update;

  ext_fsm: process (ext_current, req_reg, dma_writing_reg, llc_writing_reg, tran_count_reg,
                    llc_ext_req_valid, llc_ext_req_data, llc_ext_rsp_ready,
                    dma_rcv_data_out, dma_rcv_empty, dma_snd_full, dma_header_reg,
                    ext_snd_full, ext_rcv_data_out, ext_rcv_empty) is
  begin  -- process ext_fsm

    -- State
    ext_next      <= ext_current;
    req           <= req_reg;
    sample_header <= '0';

    tran_count <= (others => '0');
    sample_tran_count <= '0';
    tran_count_en <= '0';

    receiving.sync_clk <= '0';

    -- To tile
    llc_ext_req_ready <= '0';
    llc_ext_rsp_valid <= '0';
    dma_rcv_rdreq <= '0';
    dma_snd_wrreq <= '0';

    llc_ext_rsp_data <= ext_rcv_data_out;
    dma_snd_data_in  <= PREAMBLE_BODY & ext_rcv_data_out;

    -- To dual-clock FIFOs
    ext_snd_wrreq <= '0';
    ext_snd_data_in <= (others => '0');
    ext_rcv_rdreq <= '0';

    case ext_current is
      when idle =>
        if llc_ext_req_valid = '1' then
          req <= llc_req;
          -- state
          sample_header <= '1';
          ext_next <= send_addr;
        elsif dma_rcv_empty = '0' then
          req <= dma_req;
          ext_next <= send_addr;
          -- Sample response header and state
          sample_header <= '1';
          -- Pop DMA queue
          dma_rcv_rdreq <= '1';
        end if;

      when send_addr =>
        if ext_snd_full = '0' then
          -- Force address alignment to architecture word size
          ext_snd_data_in(LSB - 1 downto 1) <= (others => '0');
          case req_reg is
            when llc_req =>
              -- Set write (not read)
              ext_snd_data_in(0) <= llc_writing_reg;
              -- Set address
              ext_snd_data_in(ARCH_BITS - 1 downto LSB) <= llc_ext_req_data(ARCH_BITS - 1 downto LSB);
              -- Pop LLC req queue
              llc_ext_req_ready <= '1';
              -- Push ext queue
              ext_snd_wrreq <= '1';
              -- Next state
              ext_next <= send_len;

            when dma_req =>
              -- Set write (not read)
              ext_snd_data_in(0) <= dma_writing_reg;
              -- Set address
              ext_snd_data_in(ARCH_BITS - 1 downto LSB) <= dma_rcv_data_out(ARCH_BITS - 1 downto LSB);
              if dma_rcv_empty = '0' then
                -- Pop DMA queue
                dma_rcv_rdreq <= '1';
                -- Push ext queue
                ext_snd_wrreq <= '1';
                -- Next state
                ext_next <= send_len;
              end if;

          end case;
        end if;


      when send_len =>
        if ext_snd_full = '0' then
          case req_reg is
            when llc_req =>
              -- Set length (cache line)
              ext_snd_data_in <= conv_std_logic_vector(2**GLOB_WORD_OFFSET_BITS, ARCH_BITS);
              tran_count <= conv_std_logic_vector(2**GLOB_WORD_OFFSET_BITS, 32);
              -- Sample length
              sample_tran_count <= '1';
              -- Push ext queue
              ext_snd_wrreq <= '1';
              -- Next state
              if llc_writing_reg = '1' then
                ext_next <= send_data;
              else
                ext_next <= recv_data;
              end if;

            when dma_req =>
              -- Set length
              ext_snd_data_in <= dma_rcv_data_out(ARCH_BITS - 1 downto 0);
              tran_count <= dma_rcv_data_out(31 downto 0);
              if dma_rcv_empty = '0' then
                -- Sample length
                sample_tran_count <= '1';
                -- Pop DMA queue
                dma_rcv_rdreq <= '1';
                -- Push ext queue
                ext_snd_wrreq <= '1';
                -- Next state
                if dma_writing_reg = '1' then
                  ext_next <= send_data;
                else
                  ext_next <= recv_header;
                end if;
              end if;
          end case;
        end if;


      when send_data =>
        if tran_count_reg = X"00000000" then
          -- Transfer complete
          ext_next <= idle;
        elsif ext_snd_full = '0'then
          case req_reg is
            when llc_req =>
              -- Set data
              ext_snd_data_in <= llc_ext_req_data;
              -- Next state
              if llc_ext_req_valid = '1' then
                -- Decrement counter
                tran_count_en <= '1';
                -- Push ext queue
                ext_snd_wrreq <= '1';
                -- Pop LLC req queue
                llc_ext_req_ready <= '1';
              end if;

            when dma_req =>
              -- Set data
              ext_snd_data_in <= dma_rcv_data_out(ARCH_BITS - 1 downto 0);
              if dma_rcv_empty = '0' then
                -- Decrement counter
                tran_count_en <= '1';
                -- Push ext queue
                ext_snd_wrreq <= '1';
                -- Pop DMA queue
                dma_rcv_rdreq <= '1';
              end if;
          end case;
        end if;

      when recv_header =>
        receiving.sync_clk <= '1';
        if ext_rcv_empty = '0' and dma_snd_full = '0' then
          -- Set header
          dma_snd_data_in <= dma_header_reg;
          -- Push dma queue
          dma_snd_wrreq <= '1';
          -- Next state
          ext_next <= recv_data;
        end if;

      when recv_data =>
        receiving.sync_clk <= '1';
        if tran_count_reg = X"00000000" then
          -- Transfer complete
          ext_next <= idle;
        elsif ext_rcv_empty = '0' then
          case req_reg is

            when llc_req =>
              -- Push to LLC rsp queue
              llc_ext_rsp_valid <= '1';
              if llc_ext_rsp_ready = '1' then
                -- Decrement counter
                tran_count_en <= '1';
                -- Pop ext queue
                ext_rcv_rdreq <= '1';
              end if;

            when dma_req =>
              if tran_count_reg = X"00000001" then
                dma_snd_data_in(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH)  <= PREAMBLE_TAIL;
              end if;
              if dma_snd_full = '0' then
                -- Decrement counter
                tran_count_en <= '1';
                -- Push to DMA snd queue
                dma_snd_wrreq <= '1';
                -- Pop ext queue
                ext_rcv_rdreq <= '1';
              end if;

          end case;
        end if;

      when others =>
        ext_next <= idle;

    end case;
  end process ext_fsm;

end architecture rtl;
