-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: MIT

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

use work.sldcommon.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;

use work.acctypes.all;

entity acc_dma2noc is
  generic (
    tech        : integer := virtex7;
    extra_clk_buf : integer range 0 to 1;
    local_y     : local_yx;
    local_x     : local_yx;
    mem_num     : integer := 1;
    mem_info    : tile_mem_info_vector(0 to MEM_MAX_NUM);
    io_y        : local_yx;
    io_x        : local_yx;
    pindex                : integer                            := 0;
    paddr                 : integer                            := 0;
    pmask                 : integer                            := 16#fff#;
    pirq                  : integer                            := 0;
    revision              : integer                            := 0;
    devid                 : devid_t                   := 16#001#;
    available_reg_mask    : std_logic_vector(0 to MAXREGNUM - 1) := (others => '1');
    rdonly_reg_mask       : std_logic_vector(0 to MAXREGNUM - 1) := (others => '0');
    exp_registers         : integer range 0 to 1               := 0;  -- Not implemented
    scatter_gather        : integer range 0 to 1               := 1;
    tlb_entries           : integer                            := 256;
    has_dvfs              : integer                            := 1;
    has_pll               : integer);
  port (
    rst           : in  std_ulogic;
    clk           : in  std_ulogic;
    refclk        : in  std_ulogic;
    pllbypass     : in  std_ulogic;
    pllclk        : out std_ulogic;
    -- APB interface
    apbi          : in  apb_slv_in_type;
    apbo          : out apb_slv_out_type;
    -- Accelerator interface
    bank          : out bank_type(0 to MAXREGNUM - 1);
    bankdef       : in  bank_type(0 to MAXREGNUM - 1);
    acc_rst       : out std_ulogic;
    conf_done     : out std_ulogic;
    rd_request    : in  std_ulogic;
    rd_index      : in  std_logic_vector(31 downto 0);
    rd_length     : in  std_logic_vector(31 downto 0);
    rd_grant      : out std_ulogic;
    bufdin_ready  : in  std_ulogic;
    bufdin_data   : out std_logic_vector(31 downto 0);
    bufdin_valid  : out std_ulogic;
    wr_request    : in  std_ulogic;
    wr_index      : in  std_logic_vector(31 downto 0);
    wr_length     : in  std_logic_vector(31 downto 0);
    wr_grant      : out std_ulogic;
    bufdout_ready : out std_ulogic;
    bufdout_data  : in  std_logic_vector(31 downto 0);
    bufdout_valid : in  std_ulogic;
    acc_done      : in  std_ulogic;
    flush         : out std_ulogic;
    mon_dvfs_in   : in  monitor_dvfs_type;
    --Monitor signals
    mon_dvfs      : out monitor_dvfs_type;

    -- Coherent requests parallel control
    coherent_dma_read    : out std_ulogic;
    coherent_dma_write   : out std_ulogic;
    coherent_dma_length  : out addr_t;
    coherent_dma_address : out addr_t;
    coherent_dma_ready   : in  std_ulogic;
    -- NoC6->tile
    llc_coherent_dma_rcv_rdreq          : out std_ulogic;
    llc_coherent_dma_rcv_data_out       : in  noc_flit_type;
    llc_coherent_dma_rcv_empty          : in  std_ulogic;
    -- tile->NoC4
    llc_coherent_dma_snd_wrreq          : out std_ulogic;
    llc_coherent_dma_snd_data_in        : out noc_flit_type;
    llc_coherent_dma_snd_full           : in  std_ulogic;
    -- NoC4->tile
    dma_rcv_rdreq                       : out std_ulogic;
    dma_rcv_data_out                    : in  noc_flit_type;
    dma_rcv_empty                       : in  std_ulogic;
    -- tile->NoC6
    dma_snd_wrreq                       : out std_ulogic;
    dma_snd_data_in                     : out noc_flit_type;
    dma_snd_full                        : in  std_ulogic;
    -- tile->NoC5
    interrupt_wrreq                     : out std_ulogic;
    interrupt_data_in                   : out noc_flit_type;
    interrupt_full                      : in  std_ulogic);

end acc_dma2noc;

architecture rtl of acc_dma2noc is

  -- plug & play info
  constant pconfig : apb_config_type := (
    0 => ahb_device_reg (VENDOR_SLD, devid, 0, revision, pirq),
    1 => apb_iobar(paddr, pmask));
  constant hprot : std_logic_vector(3 downto 0) := "0011";

  -- Register bank
  signal bankreg   : bank_type(0 to MAXREGNUM - 1);
  signal bankin    : bank_type(0 to MAXREGNUM - 1);
  signal sample    : std_logic_vector(0 to MAXREGNUM - 1);
  signal readdata  : std_logic_vector(31 downto 0);
  signal dvfs_apbo : apb_slv_out_type;

  -- IRQ
  signal irq      : std_logic_vector(NAHBIRQ-1 downto 0);
  signal irqset   : std_ulogic;
  type irq_fsm is (idle, pending);
  signal irq_state, irq_next : irq_fsm;

  -- NoC flit
  signal header, header_r                    : noc_flit_type;
  signal payload_address, payload_address_r  : noc_flit_type;
  signal payload_length, payload_length_r    : noc_flit_type;
  signal sample_flits                        : std_ulogic;
  signal irq_header_i, irq_header            : noc_flit_type;
  constant irq_info                          : std_logic_vector(3 downto 0) := conv_std_logic_vector(pirq, 4);

  -- DMA
  type dma_fsm is (idle, request_header, request_address, request_length,
                   request_data, reply_header, reply_data, config,
                   send_header, rd_handshake, wr_handshake,
                   running, reset, wait_for_completion, fully_coherent_request);
  signal dma_state, dma_next : dma_fsm;
  signal status : std_logic_vector(31 downto 0);
  signal sample_status : std_ulogic;

  -- Internal signals muxed to output queues depending on coherence configuration
  signal dma_rcv_rdreq_int    :  std_ulogic;
  signal dma_rcv_data_out_int :  noc_flit_type;
  signal dma_rcv_empty_int    :  std_ulogic;
  signal dma_snd_wrreq_int    :  std_ulogic;
  signal dma_snd_data_in_int  :  noc_flit_type;
  signal dma_snd_full_int     :  std_ulogic;

  -- DMA word count
  signal count                : std_logic_vector(31 downto 0);
  signal increment_count      : std_ulogic;
  signal clear_count          : std_ulogic;
  signal dma_tran_done        : std_ulogic;
  signal dma_tran_header_sent : std_ulogic;
  signal dma_tran_start       : std_ulogic;
  signal dvfs_transient       : std_ulogic;  -- prevent DMA transaction while DVFS is switching

  -- TLB
  signal pending_dma_read, pending_dma_write : std_ulogic;
  signal tlb_valid, tlb_clear, tlb_empty, tlb_write : std_ulogic;
  signal tlb_wr_address : std_logic_vector((log2xx(tlb_entries) -1) downto 0);
  signal dma_address : std_logic_vector(31 downto 0);
  signal dma_length : std_logic_vector(31 downto 0);

  -- Sample acc_done:
  signal pending_acc_done, clear_acc_done : std_ulogic;

  -- DVFS
  signal dma_snd_delay : std_ulogic;
  signal dma_rcv_delay : std_ulogic;
  signal read_burst : std_ulogic;
  signal write_burst : std_ulogic;
  signal noc_delay : std_ulogic;
  signal burst : std_ulogic;
  signal acc_idle : std_ulogic;
  signal mon_dvfs_ctrl : monitor_dvfs_type;

  -----------------------------------------------------------------------------
  -- De-comment signals you wish to debug
  -----------------------------------------------------------------------------
  -- attribute mark_debug : string;

  -- attribute mark_debug of sample    : signal is "true";
  -- attribute mark_debug of readdata  : signal is "true";
  -- attribute mark_debug of dvfs_apbo : signal is "true";
  -- attribute mark_debug of irq      : signal is "true";
  -- attribute mark_debug of irqset   : signal is "true";
  -- attribute mark_debug of irq_state: signal is "true";
  -- attribute mark_debug of header                    : signal is "true";
  -- attribute mark_debug of payload_address: signal is "true";
  -- attribute mark_debug of payload_length    : signal is "true";
  -- attribute mark_debug of sample_flits                        : signal is "true";
  -- attribute mark_debug of irq_header            : signal is "true";
  -- attribute mark_debug of dma_state : signal is "true";
  -- attribute mark_debug of status : signal is "true";
  -- attribute mark_debug of sample_status : signal is "true";
  -- attribute mark_debug of count                : signal is "true";
  -- attribute mark_debug of increment_count      : signal is "true";
  -- attribute mark_debug of clear_count          : signal is "true";
  -- attribute mark_debug of dma_tran_done        : signal is "true";
  -- attribute mark_debug of dma_tran_header_sent : signal is "true";
  -- attribute mark_debug of dma_tran_start       : signal is "true";
  -- attribute mark_debug of dvfs_transient       : signal is "true";
  -- attribute mark_debug of pending_dma_read : signal is "true";
  -- attribute mark_debug of pending_dma_write : signal is "true";
  -- attribute mark_debug of tlb_valid : signal is "true";
  -- attribute mark_debug of tlb_clear : signal is "true";
  -- attribute mark_debug of tlb_empty : signal is "true";
  -- attribute mark_debug of tlb_write : signal is "true";
  -- attribute mark_debug of tlb_wr_address : signal is "true";
  -- attribute mark_debug of dma_address : signal is "true";
  -- attribute mark_debug of dma_length : signal is "true";
  -- attribute mark_debug of pending_acc_done : signal is "true";
  -- attribute mark_debug of clear_acc_done : signal is "true";
  -- attribute mark_debug of dma_snd_delay : signal is "true";
  -- attribute mark_debug of dma_rcv_delay : signal is "true";
  -- attribute mark_debug of read_burst : signal is "true";
  -- attribute mark_debug of write_burst : signal is "true";
  -- attribute mark_debug of noc_delay : signal is "true";
  -- attribute mark_debug of burst : signal is "true";
  -- attribute mark_debug of acc_idle : signal is "true";
  -- attribute mark_debug of mon_dvfs_ctrl : signal is "true";
  
begin  -- rtl

  -----------------------------------------------------------------------------
  -- IRQ packet
  -----------------------------------------------------------------------------
  irq_header_i <= create_header(local_y, local_x, io_y, io_x, INTERRUPT, irq_info);
  irq_header(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_1FLIT;
  irq_header(NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) <=
    irq_header_i(NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0);

  -----------------------------------------------------------------------------
  -- TLB
  -----------------------------------------------------------------------------

  tlb_gen: if tlb_entries /= 0 generate
    acc_tlb_1 : acc_tlb
      generic map (
        tech           => tech,
        scatter_gather => scatter_gather,
        tlb_entries    => tlb_entries)
      port map (
        clk                  => clk,
        rst                  => rst,
        bankreg              => bankreg,
        rd_request           => rd_request,
        rd_index             => rd_index,
        rd_length            => rd_length,
        wr_request           => wr_request,
        wr_index             => wr_index,
        wr_length            => wr_length,
        dma_tran_start       => dma_tran_start,
        dma_tran_header_sent => dma_tran_header_sent,
        dma_tran_done        => dma_tran_done,
        pending_dma_write    => pending_dma_write,
        pending_dma_read     => pending_dma_read,
        tlb_empty            => tlb_empty,
        tlb_clear            => tlb_clear,
        tlb_valid            => tlb_valid,
        tlb_write            => tlb_write,
        tlb_wr_address       => tlb_wr_address,
        tlb_datain           => dma_rcv_data_out_int(31 downto 0),
        dma_address          => dma_address,
        dma_length           => dma_length);
  end generate tlb_gen;

  no_tlb_gen: if tlb_entries = 0 generate
    -- No DMA transaction can occur
    dma_tran_start <= '0';
    pending_dma_write <= '0';
    pending_dma_read <= '0';
    -- Skip page-table fetch into the TLB
    tlb_empty <= '0';
    -- Don't care
    dma_address <= (others => '0');
    dma_length <= (others => '0');
  end generate no_tlb_gen;

  -----------------------------------------------------------------------------
  -- DMA packet
  -----------------------------------------------------------------------------

  coherence_model_select: process (bankreg, dma_rcv_rdreq_int, dma_rcv_data_out, dma_rcv_empty,
                                   dma_snd_wrreq_int, dma_snd_data_in_int, dma_snd_full,
                                   llc_coherent_dma_rcv_data_out, llc_coherent_dma_rcv_empty,
                                   llc_coherent_dma_snd_full) is
    variable coherence : integer range 0 to ACC_COH_FULL;
  begin  -- process coherence_model_select
    coherence := conv_integer(bankreg(COHERENCE_REG)(COH_T_LOG2 - 1 downto 0));

    if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
      llc_coherent_dma_rcv_rdreq   <= dma_rcv_rdreq_int;
      dma_rcv_data_out_int         <= llc_coherent_dma_rcv_data_out;
      dma_rcv_empty_int            <= llc_coherent_dma_rcv_empty;
      llc_coherent_dma_snd_wrreq   <= dma_snd_wrreq_int;
      llc_coherent_dma_snd_data_in <= dma_snd_data_in_int;
      dma_snd_full_int             <= llc_coherent_dma_snd_full;
      dma_rcv_rdreq                <= '0';
      dma_snd_wrreq                <= '0';
      dma_snd_data_in              <= (others => '0');
    else
      dma_rcv_rdreq                <= dma_rcv_rdreq_int;
      dma_rcv_data_out_int         <= dma_rcv_data_out;
      dma_rcv_empty_int            <= dma_rcv_empty;
      dma_snd_wrreq                <= dma_snd_wrreq_int;
      dma_snd_data_in              <= dma_snd_data_in_int;
      dma_snd_full_int             <= dma_snd_full;
      llc_coherent_dma_rcv_rdreq   <= '0';
      llc_coherent_dma_snd_wrreq   <= '0';
      llc_coherent_dma_snd_data_in <= (others => '0');
    end if;
  end process coherence_model_select;

  make_packet: process (bankreg, pending_dma_write, tlb_empty, dma_address, dma_length)
    variable msg_type : noc_msg_type;
    variable header_v : noc_flit_type;
    variable address : std_logic_vector(31 downto 0);
    variable length : std_logic_vector(31 downto 0);
    variable mem_x, mem_y : local_yx;
    variable coherence : integer range 0 to ACC_COH_FULL;
  begin  -- process make_packet

    -- Get coherence model from configuration registers
    coherence := conv_integer(bankreg(COHERENCE_REG)(COH_T_LOG2 - 1 downto 0));

    if tlb_empty = '1' then
      -- fetch page table
      address := bankreg(PT_ADDRESS_REG);
      length  := bankreg(PT_NCHUNK_REG);
      if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
        msg_type := REQ_DMA_READ;
      else
        msg_type := DMA_TO_DEV;
      end if;
    elsif pending_dma_write = '1' then
      -- accelerator write burst
      address := dma_address;
      length  := "00" & dma_length(31 downto 2);
      if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
        msg_type := REQ_DMA_WRITE;
      else
        msg_type := DMA_FROM_DEV;
      end if;
    else
      -- accelerator read burst
      address := dma_address;
      length  := "00" & dma_length(31 downto 2);
      if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
        msg_type := REQ_DMA_READ;
      else
        msg_type := DMA_TO_DEV;
      end if;
    end if;

    mem_x := mem_info(0).x;
    mem_y := mem_info(0).y;
    if mem_num /= 1 then
      for i in 0 to mem_num - 1 loop
        if ((address(31 downto 20) xor conv_std_logic_vector(mem_info(i).haddr, 12))
            and conv_std_logic_vector(mem_info(i).hmask, 12)) = X"000" then
          mem_x := mem_info(i).x;
          mem_y := mem_info(i).y;
        end if;
      end loop;  -- i
    end if;

    header_v := (others => '0');
    header_v := create_header(local_y, local_x, mem_y, mem_x, msg_type, hprot);
    header <= header_v;

    payload_address(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_BODY;
    payload_address(NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) <= address;

    payload_length(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
    payload_length(NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) <= length;

  end process make_packet;

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      header_r <= (others => '0');
      payload_address_r <= (others => '0');
      payload_length_r <= (others => '0');
      count <= conv_std_logic_vector(1, 32);
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_flits = '1' then
        header_r <= header;
        payload_address_r <= payload_address;
        payload_length_r <= payload_length;
      end if;
      if increment_count = '1' then
        count <= count + 1;
      end if;
      if clear_count = '1' then
        count <= conv_std_logic_vector(1, 32);
      end if;
    end if;
  end process;

  coherent_dma_address <= payload_address_r(ADDR_BITS - 1 downto 0);
  coherent_dma_length  <= payload_length_r(ADDR_BITS - 1 downto 0);

  -----------------------------------------------------------------------------
  -- DMA
  -----------------------------------------------------------------------------
  sample_acc_done: process (clk, rst)
  begin  -- process sample_acc_done
    if rst = '0' then                   -- asynchronous reset (active low)
      pending_acc_done <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if acc_done = '1' then
        pending_acc_done <= '1';
      end if;
      if clear_acc_done = '1' then
        pending_acc_done <= '0';
      end if;
    end if;
  end process sample_acc_done;

  dma_roundtrip: process (dma_state, rst, count, rd_request, bufdin_ready,
                          wr_request, bufdout_valid, bufdout_data, bankreg,
                          pending_acc_done, dma_snd_full_int, dma_rcv_empty_int, dma_rcv_data_out_int,
                          header_r, payload_address_r, payload_length_r,
                          dma_tran_start, tlb_empty, pending_dma_write,
                          pending_dma_read, coherent_dma_ready, dvfs_transient)
    variable payload_data : noc_flit_type;
    variable preamble : noc_preamble_type;
    variable msg : noc_msg_type;
    variable len : std_logic_vector(31 downto 0);
    variable tlb_wr_address_next : std_logic_vector(31 downto 0);
    variable coherence : integer range 0 to ACC_COH_FULL;
  begin  -- process dma_roundtrip

    -- Get coherence model from configuration registers
    coherence := conv_integer(bankreg(COHERENCE_REG)(COH_T_LOG2 - 1 downto 0));

    dma_next <= dma_state;
    sample_flits <= '0';
    increment_count <= '0';
    clear_count <= '0';
    --TLB
    tlb_wr_address_next := count - 1;
    tlb_wr_address <= tlb_wr_address_next(log2xx(tlb_entries) - 1 downto 0);
    tlb_write <= '0';
    tlb_valid <= '0';

    -- Change DMA status
    status <= (others => '0');
    sample_status <= '0';
    dma_tran_done <= '0';
    dma_tran_header_sent <= '0';

    dma_snd_data_in_int <= (others => '0');
    dma_snd_wrreq_int <= '0';
    dma_rcv_rdreq_int <= '0';

    preamble := get_preamble(dma_rcv_data_out_int);
    msg := get_msg_type(header_r);
    len := payload_length_r(31 downto 0);
    if count /= len then
      payload_data(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_BODY;
    else
      payload_data(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) := PREAMBLE_TAIL;
    end if;
    payload_data(31 downto 0) := bufdout_data;

    -- Default private cache inputs
    coherent_dma_read  <= '0';
    coherent_dma_write <= '0';

    -- Default accelerator inputs
    acc_rst <= rst;
    conf_done <= '0';
    rd_grant <= '0';
    bufdin_data <= dma_rcv_data_out_int(31 downto 0);
    bufdin_valid <= '0';
    wr_grant <= '0';
    bufdout_ready <= '0';

    clear_acc_done <= '0';
    flush <= '0';

    -- Default DVFS controller info
    dma_snd_delay <= '0';
    dma_rcv_delay <= '0';
    read_burst <= '0';
    write_burst <= '0';

    case dma_state is
      when idle =>
        -- When TLB is empty, we need to fetch the page table. We wait for the
        -- command, because the driver should write all PT_* registers. This
        -- check could be done in hardware with multiple flags.
        -- There is no need to check the status register, because whenever the
        -- FSM returns to idle, the status register is set to zero.
        clear_acc_done <= '1';
        if bankreg(CMD_REG)(CMD_BIT_START) = '1' and tlb_empty = '1' and scatter_gather /= 0 then
          sample_flits <= '1';
          if coherence /= ACC_COH_FULL then
            dma_next <= send_header;
          else
            dma_next <= fully_coherent_request;
          end if;
        elsif bankreg(CMD_REG)(CMD_BIT_START) = '1' and (tlb_empty = '0' or scatter_gather = 0) then
          dma_next <= config;
          status <= (others => '0');
          status(STATUS_BIT_RUN) <= '1';
          sample_status <= '1';
        end if;

      when fully_coherent_request =>
        if msg = DMA_TO_DEV then
          coherent_dma_read <= '1';
          if coherent_dma_ready = '1' then
            dma_tran_header_sent <= '1';
            dma_next <= reply_data;
          end if;
        else
          coherent_dma_write <= '1';
          if coherent_dma_ready = '1' then
            dma_tran_header_sent <= '1';
            dma_next <= request_data;
          end if;
        end if;

      when running =>
        -- Evaluation of inputs is done in the following order:
        -- 1) If there is a DMA transaction split across multiple chunks
        --    (scattered), we must first complete the transaction, because the
        --    lenght has been sent to the memory tile. If not completed deadlock
        --    will occur on the NoC.
        -- 2) If the software sends a reset command, both the accelerator and
        --    the FSM are reset during the next clock cycle (goto reset state)
        -- 3) If the accelerator has completed, the status register is updated;
        --    this causes an interrupt. At this point we wait for the software to
        --    reset the FSM and the accelerator by writing a 0 to the command
        --    register (goto wait_for_completion).
        -- 4) If there is a rd_request, a read transaction is initiated.
        -- 5) If there a wr_request, a write transaction is initiated. Read has
        --    priority over write
        if (pending_dma_read or pending_dma_write) = '1' and scatter_gather /= 0 then
          if dma_tran_start = '1' then
            sample_flits <= '1';
            if coherence /= ACC_COH_FULL then
              dma_next <= send_header;
            else
              dma_next <= fully_coherent_request;
            end if;
          end if;
        elsif bankreg(CMD_REG)(CMD_BIT_LAST downto 0) = zero(CMD_BIT_LAST downto 0) then
          dma_next <= reset;
        elsif pending_acc_done = '1' then
          status <= (others => '0');
          status(STATUS_BIT_DONE) <= '1';
          sample_status <= '1';
          if coherence = ACC_COH_FULL then
            flush <= '1';
          end if;
          dma_next <= wait_for_completion;
        elsif rd_request = '1' then
          if scatter_gather = 0 then
            sample_flits <= '1';
          end if;
          dma_next <= rd_handshake;
        elsif wr_request = '1' then
          if scatter_gather = 0 then
            sample_flits <= '1';
          end if;
          dma_next <= wr_handshake;
        end if;

      when wait_for_completion =>
        -- The software must reset the accelerator on completion by writing a 0
        -- to the command register
        if bankreg(CMD_REG)(CMD_BIT_LAST downto 0) = zero(CMD_BIT_LAST downto 0) then
          dma_next <= reset;
        end if;

      when reset =>
        -- Reset the accelerator and go back to idle. Note that the TLB is
        -- still valid until the register PT_ADDRESS is written again.
        acc_rst <= '0';
        status <= (others => '0');
        sample_status <= '1';
        clear_acc_done <= '1';
        dma_next <= idle;

      when config =>
        -- Set conf_done to start the accelerator.
        conf_done <= '1';
        dma_next <= running;

      when rd_handshake =>
        if dma_snd_full_int = '0' or coherence = ACC_COH_FULL then
          if rd_request = '1' then
            rd_grant <= '1';
          elsif dma_tran_start = '1' and scatter_gather /= 0 then
            sample_flits <= '1';
            if coherence /= ACC_COH_FULL then
              dma_next <= send_header;
            else
              dma_next <= fully_coherent_request;
            end if;
          elsif scatter_gather = 0 then
            if coherence /= ACC_COH_FULL then
              dma_next <= send_header;
            else
              dma_next <= fully_coherent_request;
            end if;
          end if;
        end if;

      when wr_handshake =>
        if dma_snd_full_int = '0' or coherence = ACC_COH_FULL then
          if wr_request = '1' then
            wr_grant <= '1';
          elsif dma_tran_start = '1' and scatter_gather /= 0 then
            sample_flits <= '1';
            if coherence /= ACC_COH_FULL then
              dma_next <= send_header;
            else
              dma_next <= fully_coherent_request;
            end if;
          elsif scatter_gather = 0 then
            if coherence /= ACC_COH_FULL then
              dma_next <= send_header;
            else
              dma_next <= fully_coherent_request;
            end if;
          end if;
        end if;

      when send_header =>
        if dma_snd_full_int = '0' and dvfs_transient = '0' then
          dma_snd_data_in_int <= header_r;
          dma_snd_wrreq_int <= '1';
          dma_tran_header_sent <= '1';
          dma_next <= request_address;
        end if;

      when request_address =>
        if dma_snd_full_int = '0' and dvfs_transient = '0' then
          dma_snd_data_in_int <= payload_address_r;
          dma_snd_wrreq_int <= '1';
          if msg = DMA_TO_DEV or msg = REQ_DMA_READ then
            dma_next <= request_length;
          else
            dma_next <= request_data;
          end if;
        end if;

      when request_length =>
        if dma_snd_full_int = '0' and dvfs_transient = '0' then
          dma_snd_data_in_int <= payload_length_r;
          dma_snd_wrreq_int <= '1';
          dma_next <= reply_header;
        end if;

      when request_data =>
        dma_snd_delay <= dma_snd_full_int;       -- for DVFS TRAFFIC policy
        if bufdout_valid = '1' and dma_snd_full_int = '0' and dvfs_transient = '0' then
          write_burst <= '1';
            dma_snd_data_in_int <= payload_data;
            dma_snd_wrreq_int <= '1';
            bufdout_ready <= '1';
            if count = len then
              clear_count <= '1';
              dma_tran_done <= '1';
              dma_next <= running;
            else
              increment_count <= '1';
            end if;
        end if;

      when reply_header =>
        dma_rcv_delay <= dma_rcv_empty_int;       -- for DVFS TRAFFIC policy
        if dma_rcv_empty_int = '0' and dvfs_transient = '0' then
          dma_rcv_rdreq_int <= '1';
          dma_next <= reply_data;
        end if;

      when reply_data =>
        dma_rcv_delay <= dma_rcv_empty_int;       -- for DVFS TRAFFIC policy
        if dma_rcv_empty_int = '0' and tlb_empty = '1' and dvfs_transient = '0' then
          dma_rcv_rdreq_int <= '1';
          tlb_write <= '1';
          increment_count <= '1';
          if preamble = PREAMBLE_TAIL then
            clear_count <= '1';
            tlb_valid <= '1';
            dma_next <= idle;
          end if;
        elsif dma_rcv_empty_int = '0' and bufdin_ready = '1' and dvfs_transient = '0' then
          read_burst <= '1';
          dma_rcv_rdreq_int <= '1';
          bufdin_valid <= '1';
          if preamble = PREAMBLE_TAIL then
            dma_tran_done <= '1';
            dma_next <= running;
          end if;
        end if;

      when others =>
        dma_next <= idle;

    end case;
  end process dma_roundtrip;

  -- Interrupt over NoC
  irq_send: process (irq, interrupt_full, irq_state, irq_header)
  begin  -- process irq_send
    interrupt_data_in <= irq_header;
    interrupt_wrreq <= '0';
    irq_next <= irq_state;

    case irq_state is
      when idle =>
        if irq(pirq) = '1' then
          if interrupt_full = '1' then
            irq_next <= pending;
          else
            interrupt_wrreq <= '1';
          end if;
        end if;

      when pending =>
          if interrupt_full = '0' then
            interrupt_wrreq <= '1';
            irq_next <= idle;
          end if;

      when others =>
        irq_next <= idle;
    end case;
  end process irq_send;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      dma_state <= idle;
      irq_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      dma_state <= dma_next;
      irq_state <= irq_next;
    end if;
  end process;

  -------------------------------------------------------------------------------
  -- DMA Controller APB Slave
  -------------------------------------------------------------------------------

  -- APB Interface
  process (apbi, readdata, dvfs_apbo)
  begin  -- process
    if apbi.paddr(7) = '1' then
      apbo.prdata <= dvfs_apbo.prdata;
    else
      apbo.prdata <= readdata;
    end if;
  end process;
  apbo.pirq    <= irq;
  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  reg_out: for i in 0 to MAXREGNUM - 1 generate
    bank(i) <= bankreg(i);
  end generate reg_out;

  drive_irq: process (clk, rst)
  begin  -- process drive_irq
    if rst = '0' then                   -- asynchronous reset (active low)
      irq <= (others => '0');
      irqset <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- Avoid latches on other irq bits
      irq <= (others => '0');
      irq(pirq) <= irq(pirq);
      --
      if irqset = '1' then
        irq(pirq) <= '0';
      elsif ((bankreg(STATUS_REG)(STATUS_BIT_DONE) or
              bankreg(STATUS_REG)(STATUS_BIT_ERR)) = '1' and
             irqset = '0') then
        irq(pirq) <= '1';
        irqset <=  '1';
      end if;
      if ((bankreg(STATUS_REG)(STATUS_BIT_RUN) or
           bankreg(STATUS_REG)(STATUS_BIT_DONE) or
           bankreg(STATUS_REG)(STATUS_BIT_ERR)) = '0') then
        -- Equivalent to clear IRQ
        irqset <= '0';
      end if;
    end if;
  end process drive_irq;

  -- rd/wr registers
  process(apbi, bankreg)
    variable addr : integer range 0 to MAXREGNUM - 1;
  begin
    addr := conv_integer(apbi.paddr(6 downto 2));

    bankin <= (others => (others => '0'));
    sample <= (others => '0');

    -- Clear TLB when page table address is updated
    tlb_clear <= '0';

    if apbi.paddr(7) = '0' then
      sample(addr) <= apbi.psel(pindex) and apbi.penable and apbi.pwrite;
      if addr = PT_ADDRESS_REG then
        tlb_clear <= '1';
      end if;
    end if;
    bankin(addr) <= apbi.pwdata;
    readdata <= bankreg(addr);
  end process;

  -- Status register
  cmd_status: process (clk, rst)
  begin  -- process cmd_status
    if clk'event and clk = '1' then  -- rising clock edge
      if rst = '0' then                   -- asynchronous reset (active low)
        bankreg(STATUS_REG) <= (others => '0');
      elsif sample_status = '1' then
        bankreg(STATUS_REG) <= status;
      end if;
    end if;
  end process cmd_status;

  -- Other registers
  registers: for i in 0 to MAXREGNUM - 1 generate
    written_from_noc: if i /= STATUS_REG and available_reg_mask(i) = '1' generate
      process (clk)
      begin  -- process
        if clk'event and clk = '1' then  -- rising clock edge
          if rst = '0' then                   -- synchronous reset (active low)
            bankreg(i) <= bankdef(i);
          elsif sample(i) = '1' and rdonly_reg_mask(i) = '0' then
            bankreg(i) <= bankin(i);
          end if;
        end if;
      end process;
    end generate written_from_noc;
  end generate registers;

  unused_registers: for i in 0 to MAXREGNUM - 1 generate
    not_available: if available_reg_mask(i) = '0' generate
      bankreg(i) <= (others => '0');
    end generate not_available;
  end generate unused_registers;

  no_dvfs: if has_dvfs = 0 generate
    pllclk <= refclk;
    dvfs_apbo <= apb_none;
    mon_dvfs.clk <= refclk;
    mon_dvfs.vf <= "1000";
    mon_dvfs.transient <= '0';
    dvfs_transient <= '0';
  end generate;

  dvfs_no_master: if has_dvfs /= 0 and has_pll = 0 generate
    pllclk <= refclk;
    dvfs_apbo <= apb_none;
    mon_dvfs.clk <= refclk;
    mon_dvfs.vf <= mon_dvfs_in.vf;
    mon_dvfs.transient <= mon_dvfs_in.transient;
    dvfs_transient <= mon_dvfs_in.transient;
  end generate dvfs_no_master;

  noc_delay <= dma_snd_delay or dma_rcv_delay;
  burst <= read_burst or write_burst;
  acc_idle <= '1' when dma_state = idle and bankreg(CMD_REG)(CMD_BIT_START) = '0' else '0';
  mon_dvfs.acc_idle <= acc_idle;
  mon_dvfs.traffic <= noc_delay;
  mon_dvfs.burst <= burst;

  with_dvfs: if has_dvfs /= 0 and has_pll /= 0 generate
  dvfs_top_1: dvfs_top
    generic map (
      tech     => tech,
      extra_clk_buf => extra_clk_buf,
      pindex   => pindex,
      paddr    => paddr,
      pmask    => pmask)
    port map (
      rst       => rst,
      clk       => clk,
      refclk    => refclk,
      pllbypass => pllbypass,
      pllclk    => pllclk,
      apbi      => apbi,
      apbo      => dvfs_apbo,
      acc_idle  => mon_dvfs_in.acc_idle,
      traffic   => mon_dvfs_in.traffic,
      burst     => mon_dvfs_in.burst,
      mon_dvfs  => mon_dvfs_ctrl);
  mon_dvfs.clk <= mon_dvfs_ctrl.clk;
  mon_dvfs.vf  <= mon_dvfs_ctrl.vf;
  mon_dvfs.transient <= mon_dvfs_ctrl.transient;
  dvfs_transient <= mon_dvfs_ctrl.transient;
  end generate;

end rtl;
