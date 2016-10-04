------------------------------------------------------------------------------
--  Copyright (C) 2015, System Level Design (SLD) group @ Columbia University
-----------------------------------------------------------------------------
-- Entity:  acc_dma2bus
-- File:    acc_dma2bus.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description: DMA controller for accelerators over AMBA 2.0 bus
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.sldcommon.all;

use work.acctypes.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

entity acc_dma2bus is

  generic (
    tech                  : integer range 0 to NTECH           := virtex5;
    hindex                : integer                            := 0;
    pindex                : integer                            := 0;
    paddr                 : integer                            := 0;
    pmask                 : integer                            := 16#fff#;
    pirq                  : integer                            := 0;
    memtech               : integer range 0 to NTECH           := 0;
    revision              : integer                            := 0;
    devid                 : amba_device_type                   := 16#001#;
    available_reg_mask    : std_logic_vector(0 to MAXREGNUM-1) := (others => '1');
    rdonly_reg_mask       : std_logic_vector(0 to MAXREGNUM-1) := (others => '0');
    exp_registers         : integer range 0 to 1               := 0;  -- Not implemented
    scatter_gather        : integer range 0 to 1               := 1;
    tlb_entries           : integer                            := 256
    );
  port (
    rst           : in  std_ulogic;
    clk           : in  std_ulogic;

    apbi          : in  apb_slv_in_type;
    apbo          : out apb_slv_out_type;
    ahbi          : in  ahb_mst_in_type;
    ahbo          : out ahb_mst_out_type;
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

    acc_done      : in  std_ulogic
    );

end acc_dma2bus;


architecture rtl of acc_dma2bus is

  -- APB interface signals and constants
  constant pconfig : apb_config_type := (
    0 => ahb_device_reg (VENDOR_SLD, devid, 0, revision, pirq),
    1 => apb_iobar(paddr, pmask));
  -- AHB interface signals and constants
  constant hconfig : ahb_config_type := (
  0 => ahb_device_reg (VENDOR_SLD, devid, 0, REVISION, 0),
  others => zero32);

  signal bankreg : bank_type(0 to MAXREGNUM - 1);
  signal bankin  : bank_type(0 to MAXREGNUM - 1);
  signal sample  : std_logic_vector(0 to MAXREGNUM - 1);
  signal sample_status : std_ulogic;

  signal status : std_logic_vector(2 downto 0);

  signal irq    : std_logic_vector(NAHBIRQ-1 downto 0);
  signal irqset : std_ulogic;

  signal readdata : std_logic_vector(31 downto 0);

  constant hlock : std_ulogic := '0';
  constant hprot : std_logic_vector(3 downto 0) := "0011";
  constant hsize : std_logic_vector(2 downto 0) := HSIZE_WORD;

  constant DMA_IDLE : std_logic_vector(2 downto 0) := "000";
  constant DMA_RUN  : std_logic_vector(2 downto 0) := "001";
  constant DMA_DONE : std_logic_vector(2 downto 0) := "010";
  constant DMA_ERR  : std_logic_vector(2 downto 0) := "100";

  type dmac_state is (idle, request, read1, read2, read3, read4,
                      requestwr, write1, write2, write3, write4,
                      config, read_start, write_start, read_1w,
                      read_2w, write_1w,
                      running, reset, wait_for_completion, wait_tlb);

  type reg_type is record
                     grant   : std_ulogic;
                     ready   : std_ulogic;
                     resp    : std_logic_vector(1 downto 0);
                     addr    : std_logic_vector(31 downto 0);
                     data    : std_logic_vector(31 downto 0);
                     state   : dmac_state;
                     len     : std_logic_vector(31 downto 0);
                     bufen   : std_ulogic;
                     bufwren : std_ulogic;
                     htrans  : std_logic_vector(1 downto 0);
                     hwrite  : std_ulogic;
                     hbusreq : std_ulogic;
                     tlb_write : std_ulogic;
                   end record;
  constant reg_none : reg_type := (
    grant   => '0',
    ready   => '0',
    resp    => HRESP_OKAY,
    addr    => (others => '0'),
    data    => (others => '0'),
    state   => idle,
    len     => (others => '1'),
    bufen   => '0',
    bufwren => '0',
    htrans  => HTRANS_IDLE,
    hwrite  => '0',
    hbusreq => '0',
    tlb_write => '0');

  signal r, rin : reg_type;

  constant index_shift : integer := 2;

  -- TLB
  signal pending_dma_read, pending_dma_write : std_ulogic;
  signal tlb_valid, tlb_clear, tlb_empty : std_ulogic;
  signal tlb_wr_address : std_logic_vector((log2(tlb_entries) -1) downto 0);
  signal dma_address, dma_address_r : std_logic_vector(31 downto 0);
  signal dma_length, dma_length_r : std_logic_vector(31 downto 0);
  signal sample_dma_info : std_ulogic;
  signal dma_tran_done       : std_ulogic;
  signal dma_tran_header_sent : std_ulogic;
  signal dma_tran_start      : std_ulogic;

  -- Sample acc_done:
  signal pending_acc_done, clear_acc_done : std_ulogic;

begin

  -----------------------------------------------------------------------------
  -- TLB
  -----------------------------------------------------------------------------
  acc_tlb_1: acc_tlb
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
      tlb_write            => r.tlb_write,
      tlb_wr_address       => tlb_wr_address,
      tlb_datain           => r.data,
      dma_address          => dma_address,
      dma_length           => dma_length);

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      dma_address_r <= (others => '0');
      dma_length_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sample_dma_info = '1' then
        if tlb_empty = '0' then
          dma_address_r <= dma_address;
          dma_length_r <= dma_length;
        else
          dma_address_r <= bankreg(PT_ADDRESS_REG);
          dma_length_r  <= bankreg(PT_NCHUNK_REG)(29 downto 0) & "00";
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------
  -- DMA Transactor AHB Master
  -------------------------------------------------------------------------------
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

  comb : process(r, ahbi, bankreg, bufdout_data, rd_index, rd_request, wr_index,
                 wr_request, rd_length, wr_length, pending_acc_done, rst,
                 dma_address_r, dma_length_r, dma_tran_start, tlb_empty,
                 pending_dma_write, pending_dma_read)
    variable v : reg_type;

    variable vstatus : std_logic_vector(2 downto 0);
    variable vsample_status : std_ulogic;

    variable newlen     : std_logic_vector(31 downto 0);
    variable newaddr    : std_logic_vector(31 downto 2);
    variable oldlen     : std_logic_vector(31 downto 0);
    variable oldaddr    : std_logic_vector(31 downto 2);
    variable size_rd    : std_logic_vector(31 downto 0);
    variable size_wr    : std_logic_vector(31 downto 0);
    variable dma_addr   : std_logic_vector(31 downto 0);
    variable dma_len    : std_logic_vector(31 downto 0);
    variable rd_offset, wr_offset : std_logic_vector(31 downto 0);

    variable haddr   : std_logic_vector(31 downto 0);
    variable hwdata  : std_logic_vector(AHBDW-1 downto 0);
    variable htrans  : std_logic_vector(1 downto 0);
    variable hwrite  : std_ulogic;
    variable hburst  : std_logic_vector(2 downto 0);
    variable hbusreq : std_ulogic;
    variable hirq   : std_logic_vector(NAHBIRQ-1 downto 0);

    variable tlb_wr_address_next : std_logic_vector(31 downto 0);

  begin
    acc_rst <= rst;
    rd_grant <= '0';
    wr_grant <= '0';
    conf_done <= '0';

    dma_len := "00" & dma_length_r(31 downto 2);
    if scatter_gather = 0 then
      size_rd := rd_length(31 downto 0) - 2;
      size_wr := wr_length(31 downto 0) - 2;
    else
      size_rd := dma_len - 2;
      size_wr := dma_len - 2;
    end if;

    -- scatter/gather DMA default
    dma_addr := dma_address_r;
    sample_dma_info <= '0';
    tlb_wr_address_next := r.len;
    tlb_wr_address <= tlb_wr_address_next(log2(tlb_entries) - 1 downto 0);
    tlb_valid <= '0';
    dma_tran_done <= '0';
    dma_tran_header_sent <= '0';

    -- r default
    v := r;
    v.grant := ahbi.hgrant(hindex);
    v.ready := ahbi.hready;
    v.resp  := ahbi.hresp;
    v.bufen := '0';
    v.bufwren := '0';
    v.tlb_write := '0';

    vstatus := DMA_IDLE;
    vsample_status := '0';

    clear_acc_done <= '0';

    haddr   := r.addr;
    hwdata  := ahbdrivedata(r.data);
    htrans  := r.htrans;
    hwrite  := r.hwrite;
    hburst  := HBURST_INCR;
    hbusreq := r.hbusreq;
    hirq    := (others => '0');

    -- address incrementer
    newlen  := r.len + 1;
    newaddr := r.addr(31 downto 2) + 1;
    oldlen  := r.len - 1;
    oldaddr := r.addr(31 downto 2) - 1;

    -- compute base address + offset
    rd_offset := rd_index(31 - index_shift downto 0) & zero32(index_shift - 1 downto 0);
    wr_offset := wr_index(31 - index_shift downto 0) & zero32(index_shift - 1 downto 0);

    case r.state is
      when idle =>
        v.len  := (others => '1');
        if bankreg(CMD_REG)(CMD_BIT_START) = '1' and tlb_empty = '1' and scatter_gather /= 0 then
          sample_dma_info <= '1';
          v.addr := bankreg(PT_ADDRESS_REG);
          v.state := request;
        elsif bankreg(CMD_REG)(CMD_BIT_START) = '1' and (tlb_empty = '0' or scatter_gather = 0) then
          v.state := config;
          vstatus := DMA_RUN;
          vsample_status := '1';
        end if;

      when running =>
        v.len  := (others => '1');
        if pending_dma_read = '1' and scatter_gather /= 0 then
          if dma_tran_start = '1' then
            sample_dma_info <= '1';
            v.state := request;
          end if;
        elsif pending_dma_write = '1' and scatter_gather /= 0 then
          if dma_tran_start = '1' then
            sample_dma_info <= '1';
            v.state := requestwr;
          end if;
        elsif bankreg(CMD_REG)(CMD_BIT_START) = '0' then
          v.state := reset;
        elsif pending_acc_done = '1' then
          vstatus := DMA_DONE;
          vsample_status := '1';
          clear_acc_done <= '1';
          v.state := wait_for_completion;
        elsif rd_request = '1' or wr_request = '1' then
          v.state := wait_tlb;
        end if;

      when wait_tlb =>
        if rd_request = '1' then
          if scatter_gather = 0 then
            v.addr := bankreg(SRC_OFFSET_REG) + rd_offset;
            v.state := read_start;
          elsif dma_tran_start = '1' then
            sample_dma_info <= '1';
            v.state := read_start;
          end if;
        elsif wr_request = '1' then
          if scatter_gather = 0 then
            v.addr := bankreg(DST_OFFSET_REG) + wr_offset;
            v.state := write_start;
          elsif dma_tran_start = '1' then
            sample_dma_info <= '1';
            v.state := write_start;
          end if;
        end if;

      when wait_for_completion =>
        if bankreg(CMD_REG)(CMD_BIT_START) = '0' then
          v.state := reset;
        end if;

      when reset =>
        acc_rst <= '0';
        vstatus := DMA_IDLE;
        vsample_status := '1';
        v.state := idle;

      when config =>
        conf_done <= '1';
        v.state := running;

      when read_start =>
        if scatter_gather /= 0 then
          v.addr := dma_addr;
        end if;
        if rd_request = '1' then
          rd_grant <= '1';
        else
          v.hbusreq := '1';
          v.htrans := HTRANS_NONSEQ;
          v.state := request;
          rd_grant <= '0';
        end if;

      when write_start =>
        if scatter_gather /= 0 then
          v.addr := dma_addr;
        end if;
        if wr_request = '1' then
          wr_grant <= '1';
        else
          v.state := requestwr;
          wr_grant <= '0';
        end if;

      when request =>
        dma_tran_header_sent <= '1';
        v.hbusreq := '1';            --need to sample grant and ready
        if scatter_gather /= 0 then
          v.addr := dma_addr;
        end if;
        if (v.grant and v.ready) = '1' then  -- address bus granted
          v.state := read1;
          v.htrans := HTRANS_NONSEQ;
        end if;

      when read1 =>
        v.hbusreq := '1';  --need to sample grant and ready
        v.htrans := HTRANS_NONSEQ;
        if (v.grant and v.ready) = '1' then  -- data bus granted
          if size_rd = X"ffffffff" then
            v.state := read_1w;
            v.hbusreq := '0';
          elsif size_rd = X"00000000" then
            v.htrans := HTRANS_SEQ;
            v.addr(31 downto 2) := newaddr;
            v.state := read_2w;
          else
            v.htrans := HTRANS_SEQ;
            v.addr(31 downto 2) := newaddr;
            v.state := read2;
          end if;
        elsif v.grant = '0' then
          v.state := request;
        end if;


      when read_1w =>
        v.data := ahbreadword(ahbi.hrdata);
        if v.ready = '1' then
          if v.resp = HRESP_OKAY then
            if tlb_empty = '1' then
              v.len := newlen;
              v.tlb_write := '1';
            else
              v.bufwren := '1';
            end if;
            v.hbusreq := '0';
            v.htrans := HTRANS_IDLE;
            v.state := read4;
          elsif v.resp = HRESP_ERROR then
            v.hbusreq := '0';
            v.bufwren := '0';
            v.htrans := HTRANS_IDLE;
            v.state := running;
            vstatus := DMA_ERR;
            vsample_status := '1';
          else                        -- retry
            v.hbusreq := '1';
            v.htrans := HTRANS_NONSEQ;
            v.state := read_1w;
          end if;
        end if;

      when read_2w =>
        v.hbusreq := '1';
        v.data := ahbreadword(ahbi.hrdata);
        if v.grant = '1' then
          v.htrans := HTRANS_SEQ;
          if v.ready = '1' then
            if v.resp = HRESP_OKAY then
              if tlb_empty = '1' then
                v.len := newlen;
                v.tlb_write := '1';
              else
                v.bufwren := '1';
              end if;
              v.addr(31 downto 2) := newaddr;
              v.hbusreq := '0';
              v.state := read3;
            elsif v.resp = HRESP_ERROR then
              v.bufwren := '0';
              v.htrans := HTRANS_IDLE;
              v.state := running;
              vstatus := DMA_ERR;
              vsample_status := '1';
            elsif v.resp = HRESP_SPLIT then
              v.htrans := HTRANS_NONSEQ;
              v.state := request;
              v.addr(31 downto 2) := oldaddr;
            else                        -- retry previous address
              v.htrans := HTRANS_NONSEQ;
              v.addr(31 downto 2) := oldaddr;
              v.state := read1;
            end if;
          end if;
        else
          v.htrans := HTRANS_NONSEQ;
          v.state := request;
          v.addr(31 downto 2) := oldaddr;
        end if;

      when read2 =>
        v.hbusreq := '1';
        v.data := ahbreadword(ahbi.hrdata);
        if v.grant = '1' then
          v.htrans := HTRANS_SEQ;
          if v.ready = '1' then
            if v.resp = HRESP_OKAY then
              if tlb_empty = '1' then
                v.tlb_write := '1';
              else
                v.bufwren := '1';
              end if;
              v.addr(31 downto 2) := newaddr;
              v.len := newlen;
              if newlen = size_rd then
                v.hbusreq := '0';
                v.state := read3;
              end if;
            elsif v.resp = HRESP_ERROR then
              v.hbusreq := '0';
              v.htrans := HTRANS_IDLE;
              v.state := running;
              vstatus := DMA_ERR;
              vsample_status := '1';
            elsif v.resp = HRESP_SPLIT then
              v.htrans := HTRANS_NONSEQ;
              v.state := request;
              v.addr(31 downto 2) := oldaddr;
            else                        -- retry previous address
              v.htrans := HTRANS_NONSEQ;
              v.addr(31 downto 2) := oldaddr;
              v.state := read1;
            end if;
          end if;
        else
          v.htrans := HTRANS_NONSEQ;
          v.state := request;
          v.addr(31 downto 2) := oldaddr;
        end if;

      when read3 =>
        -- When bus request is lowered there will be
        -- most likely a bus handover, however, data
        -- bus and hready are still owned.
        v.data := ahbreadword(ahbi.hrdata);
        if v.ready = '1' then
          if v.resp = HRESP_OKAY then
            if tlb_empty = '1' then
              v.tlb_write := '1';
            else
              v.bufwren := '1';
            end if;
            v.hbusreq := '0';
            v.htrans := HTRANS_IDLE;
            v.len := newlen;
            v.state := read4;
          elsif v.resp = HRESP_ERROR then
            v.hbusreq := '0';
            v.bufwren := '0';
            v.htrans := HTRANS_IDLE;
            v.state := running;
            vstatus := DMA_ERR;
            vsample_status := '1';
          else                        -- retry previous address
            v.hbusreq := '1';
            v.htrans := HTRANS_NONSEQ;
            v.addr(31 downto 2) := oldaddr;
            v.state := read3;
          end if;
        end if;

      when read4 =>
        if tlb_empty = '1' then
          tlb_valid <= '1';
          v.state := idle;
        else
          dma_tran_done <= '1';
          v.state := running;
        end if;
        v.htrans := HTRANS_IDLE;

      when requestwr =>
        dma_tran_header_sent <= '1';
        v.hbusreq := '1';            --need to sample grant and ready
        if scatter_gather /= 0 then
          v.addr := dma_addr;
        end if;
        v.hwrite  := '1';
        v.len  := (others => '0');
        v.htrans := HTRANS_NONSEQ;
        if (v.grant and v.ready) = '1' then  -- address bus granted
          v.state := write1;
        end if;

      when write1 =>
        v.hbusreq := '1';
        v.hwrite  := '1';
        v.htrans := HTRANS_NONSEQ; --need to sample grant and ready
        if (v.grant and v.ready) = '1' then  -- data bus granted
          if size_wr = X"ffffffff" then
            v.state := write_1w;
            v.hbusreq := '0';
          elsif size_wr = X"00000000" then
            v.hbusreq := '0';
            v.htrans := HTRANS_SEQ;
            v.addr(31 downto 2) := newaddr;
            v.state := write3;
          else
            v.htrans := HTRANS_SEQ;
            v.addr(31 downto 2) := newaddr;
            v.state := write2;
            v.len := newlen;
          end if;
          v.data := bufdout_data;
          v.bufen := '1';
        elsif v.grant = '0' then --TOOD: SPPLIT/RETRY WR not implemented
          v.state := requestwr;
        end if;

      when write_1w =>
        v.hwrite  := '1';
        if v.ready = '1' then
          if v.resp = HRESP_OKAY then
            v.hwrite  := '0';
            v.hbusreq := '0';
            v.htrans := HTRANS_IDLE;
            v.state := write4;
          elsif v.resp = HRESP_ERROR then
            v.hbusreq := '0';
            v.htrans := HTRANS_IDLE;
            v.state := running;
            vstatus := DMA_ERR;
            vsample_status := '1';
          else --TOOD: SPPLIT/RETRY WR not implemented
            v.hbusreq := '1';
            v.htrans := HTRANS_NONSEQ;
            v.state := write_1w;
          end if;
        end if;

      when write2 =>
        v.hbusreq := '1';
        v.hwrite  := '1';
        v.htrans := HTRANS_SEQ;
        if (v.grant and v.ready) = '1' then
          if v.resp = HRESP_OKAY then
            v.addr(31 downto 2) := newaddr;
            v.data := bufdout_data;
            v.bufen := '1';
            v.len := newlen;
            if r.len = size_wr then
              v.hbusreq := '0';
              v.state := write3;
            end if;
          elsif v.resp = HRESP_ERROR then
            v.hbusreq := '0';
            v.htrans := HTRANS_IDLE;
            v.state := running;
            vstatus := DMA_ERR;
            vsample_status := '1';
          elsif v.resp = HRESP_SPLIT then --TOOD: SPPLIT/RETRY WR not implemented
            v.htrans := HTRANS_NONSEQ;
            v.state := requestwr;
            v.addr(31 downto 2) := oldaddr;
            v.len := oldlen;
          else --TOOD: SPPLIT/RETRY WR not implemented
            v.htrans := HTRANS_NONSEQ;
            v.addr(31 downto 2) := oldaddr;
            v.len := oldlen;
            v.state := write1;
          end if;
        elsif v.grant = '0' then --TOOD: SPPLIT/RETRY WR not implemented
          v.htrans := HTRANS_NONSEQ;
          v.state := requestwr;
          v.addr(31 downto 2) := oldaddr;
          v.len := oldlen;
        end if;

      when write3 =>
        v.hwrite  := '1';
        if v.ready = '1' then
          if v.resp = HRESP_OKAY then
            v.hbusreq := '0';
            v.htrans := HTRANS_IDLE;
            v.data := bufdout_data;
            v.bufen := '1';
            v.hwrite  := '1';
            v.state := write4;
          elsif v.resp = HRESP_ERROR then
            v.hbusreq := '0';
            v.htrans := HTRANS_IDLE;
            v.state := running;
            vstatus := DMA_ERR;
            vsample_status := '1';
          else --TOOD: SPPLIT/RETRY WR not implemented
            v.hbusreq := '1';
            v.htrans := HTRANS_NONSEQ;
            v.addr(31 downto 2) := oldaddr;
            v.state := write3;
          end if;
        end if;

      when write4 =>
        dma_tran_done <= '1';
        v.htrans := HTRANS_IDLE;
        v.state := running;
        v.hwrite  := '0';

      when others => v.state := idle;
    end case;

    rin <= v;

    if hwrite = '1' then
      bufdout_ready <= v.bufen;
    else
      bufdout_ready <= r.bufen;
    end if;
    bufdin_data <= r.data;
    bufdin_valid <= r.bufwren;

    status <= vstatus;
    sample_status <= vsample_status;

    ahbo.haddr   <= haddr;
    ahbo.htrans  <= htrans;
    ahbo.hbusreq <= hbusreq;
    ahbo.hwdata  <= hwdata;
    ahbo.hconfig <= hconfig;
    ahbo.hlock   <= hlock;
    ahbo.hwrite  <= hwrite;
    ahbo.hsize   <= hsize;
    ahbo.hburst  <= hburst;
    ahbo.hprot   <= hprot;
    ahbo.hirq    <= hirq;
    ahbo.hindex  <= hindex;

  end process;

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      r <= reg_none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      r <= rin;
    end if;
  end process;

-------------------------------------------------------------------------------
-- DMA Controller APB Slave
-------------------------------------------------------------------------------

  -- APB Interface
  apbo.prdata  <= readdata;
  apbo.pirq    <= irq;
  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  reg_out: for i in 0 to MAXREGNUM - 1 generate
    bank(i) <= bankreg(i);
  end generate reg_out;

  drive_irq: process (clk, rst)
    variable vstatus : std_logic_vector(2 downto 0);
  begin  -- process drive_irq
    if rst = '0' then                   -- asynchronous reset (active low)
      irq <= (others => '0');
      irqset <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      vstatus := bankreg(STATUS_REG)(STATUS_BIT_LAST downto 0);
      if irqset = '1' then
        irq(pirq) <= '0';
      elsif (vstatus = DMA_DONE or vstatus = DMA_ERR) and irqset = '0' then
        irq(pirq) <= '1';
        irqset <=  '1';
      end if;
      if vstatus = DMA_IDLE then
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

    sample(addr) <= apbi.psel(pindex) and apbi.penable and apbi.pwrite;
    if addr = PT_ADDRESS_REG and (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      tlb_clear <= '1';
    end if;
    bankin(addr) <= apbi.pwdata;
    readdata <= bankreg(addr);
  end process;


  registers: for i in 0 to MAXREGNUM - 1 generate

    is_status_Reg: if i = STATUS_REG generate
      -- sample registers
      cmd_status: process (clk, rst)
      begin  -- process cmd_status
        if rst = '0' then                   -- asynchronous reset (active low)
          bankreg(STATUS_REG) <= (others => '0');
        elsif clk'event and clk = '1' then  -- rising clock edge
          if sample_status = '1' then
            bankreg(STATUS_REG)(STATUS_BIT_LAST downto 0) <= status;
          end if;
        end if;
      end process cmd_status;
    end generate is_status_Reg;

    other_registers: if i /= STATUS_REG generate

      unused_registers: if available_reg_mask(i) = '0' generate
        bankreg(i) <= (others => '0');
      end generate unused_registers;

      used_registers: if available_reg_mask(i) = '1' generate
        process (clk, rst)
        begin  -- process
          if rst = '0' then                   -- asynchronous reset (active low)
            bankreg(i) <= bankdef(i);
          elsif clk'event and clk = '1' then  -- rising clock edge
            if sample(i) = '1' and rdonly_reg_mask(i) = '0' then
              bankreg(i) <= bankin(i);
            end if;
          end if;
        end process;
      end generate used_registers;

    end generate other_registers;

  end generate registers;

end rtl;
