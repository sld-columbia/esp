-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- ESP Accelerator TLB
--
-- The accelerators communicate with memory by issuing DMA requests. This module
-- translates the accelerator virtual index (expressed in number of 32-bit
-- words) into a physical address in bytes. The latter corresponds to the DMA
-- burst starting address. In addition, this module converts the DMA burst
-- length (expressed in number of 32-bit words) issued by the accelerator into
-- the corresponding DMA burst length in bytes.
--
-- When scatter-gather mode is enabled, the TLB loads the list of base addresses
-- specified in the configuration registers, located at the following address
-- "bankreg[PT_ADDRESS_EXTENDED_REG] & bankreg[PT_ADDRESS_REG]".  A single DMA
-- request may result into more than one transaction, depending on the lenght of
-- the request and the size of the accelerator pages, specified in
-- bankreg[PT_SHIFT_REG]. The total number of accelerator pages is saved into
-- bankreg[PT_NCHUNK_REG].
-- In this mode, the registers bankreg[SRC_OFFSET_REG] and
-- bankreg[DST_OFFSET_REG] should store the offset in bytes for the input and
-- the output buffers, with respect to the virtual memory area reserved for the
-- accelerator. For more complicated data structures, user-defined registers can
-- be used to specify multiple offsets, while leaving the standard offset
-- registers set to zero.
--
-- When contiguous memory allocation is selected, instead,
-- bankreg[SRC_OFFSET_REG] and bankreg[DST_OFFSET_REG] contain the base
-- addresses of the input and output buffers, which must both be contiguous in
-- physical memory. Every DMA request can be served with a single transaction.
-- Note that with the current implementation, we only support the contiguous
-- memory setting when the physical address is 32 bits. This is defined by the
-- global ESP constant GLOB_PHYS_ADDR_BITS.
--
-- Note that the accelerator interface limits the accelerator virtual memory to
-- at most 4 GB. Therefore, accelerators can process up to 4 GB of data on a
-- single invocation.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.esp_global.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.esp_acc_regmap.all;

entity esp_acc_tlb is

  generic (
    tech            : integer := virtex7;
    scatter_gather  : integer range 0 to 1 := 1;
    tlb_entries     : integer := 256);
  port (
    clk                  : in  std_ulogic;
    rst                  : in  std_ulogic;
    bankreg              : in  bank_type(0 to MAXREGNUM - 1);
    rd_request           : in  std_ulogic;
    rd_index             : in  std_logic_vector(31 downto 0);
    rd_length            : in  std_logic_vector(31 downto 0);
    wr_request           : in  std_ulogic;
    wr_index             : in  std_logic_vector(31 downto 0);
    wr_length            : in  std_logic_vector(31 downto 0);
    dma_tran_start       : out std_ulogic;
    dma_tran_header_sent : in  std_ulogic;
    dma_tran_done        : in  std_ulogic;
    pending_dma_write    : out std_ulogic;
    pending_dma_read     : out std_ulogic;
    tlb_empty            : out std_ulogic;
    tlb_clear            : in  std_ulogic;
    tlb_valid            : in  std_ulogic;
    tlb_write            : in  std_ulogic;
    tlb_wr_address       : in  std_logic_vector((log2xx(tlb_entries) -1) downto 0);
    tlb_datain           : in  std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    dma_address          : out std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    dma_length           : out std_logic_vector(31 downto 0)
    );

end esp_acc_tlb;


architecture tlb of esp_acc_tlb is

  -- Page table
  -- Dependent on configuration registers only
  signal chunk_shift : std_logic_vector(4 downto 0);
  -- TLB FSM control signals
  signal pt_fsm_sample_0 : std_ulogic;
  signal pt_fsm_sample_1 : std_ulogic;
  signal pt_fsm_sample_2 : std_ulogic;
  signal pt_fsm_sample_3 : std_ulogic;
  signal pt_fsm_sample_4 : std_ulogic;
  -- TLB FSM stage 0
  signal chunk_size_in, chunk_size : std_logic_vector(31 downto 0);
  signal dma_offset_mask_in, dma_offset_mask : std_logic_vector(31 downto 0);
  signal vaddress_in, vaddress : std_logic_vector(31 downto 0);
  signal remaining_length_in, remaining_length : std_logic_vector(31 downto 0);
  -- TLB FSM stage 1
  signal chunk_index_in, chunk_index : std_logic_vector(31 downto 0);
  signal dma_offset_in, dma_offset : std_logic_vector(31 downto 0);
  -- TLB FSM stage 2
  signal dma_length_fallback_in, dma_length_fallback, dma_length_int : std_logic_vector(31 downto 0);
  signal dma_end_address_in, dma_end_address : std_logic_vector(31 downto 0);
  signal dma_split_in, dma_split : std_ulogic;
  -- TLB FSM stage 3
  signal dma_base_address : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  signal dma_address_in : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  signal dma_length_in  : std_logic_vector(31 downto 0);
  -- TLB FSM stage 4 (back to 0 if dma_length = remaining_length else back to 1)
  -- ** remain in stage 4 until DMA transfer completes **
  signal vaddress_update_in : std_logic_vector(31 downto 0);
  signal remaining_length_update_in : std_logic_vector(31 downto 0);

  type tlb_fsm_type is (tlb_init, tlb_s0, tlb_s1, tlb_s2, tlb_s3, tlb_s4, tlb_s4bis, tlb_s5);
  signal tlb_fsm_current, tlb_fsm_next : tlb_fsm_type;

  -- TLB
  signal tlb_address         : std_logic_vector((log2(tlb_entries) -1) downto 0);
  signal tlb_rd_address      : std_logic_vector((log2(tlb_entries) -1) downto 0);
  signal tlb_dataout         : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  signal tlb_enable          : std_ulogic;
  signal tlb_read            : std_ulogic;
  signal tlb_empty_int       : std_ulogic;

  -- DMA FSM handshake
  signal dma_write_done      : std_ulogic;
  signal dma_write_start     : std_ulogic;
  signal dma_read_done      : std_ulogic;
  signal dma_read_start     : std_ulogic;

  -- P2P
  signal src_is_p2p        : std_ulogic;
  signal dst_is_p2p        : std_ulogic;
  signal is_p2p_in, is_p2p : std_ulogic;

  -- Auxiliary
  signal one_sig : std_logic_vector(31 downto 0);
  signal fff_sig : std_logic_vector(31 downto 0);

  constant address_pad_lsb : std_logic_vector(GLOB_BYTE_OFFSET_BITS - 1 downto 0) := (others => '0');

begin  -- tlb

  tlb_empty <= tlb_empty_int;
  dma_length <= dma_length_int;
  src_is_p2p <= bankreg(P2P_REG)(P2P_BIT_SRC_IS_P2P);
  dst_is_p2p <= bankreg(P2P_REG)(P2P_BIT_DST_IS_P2P);

  -- TODO: without scatter-gather we only support 32-bits physical address and data width
  no_scatter_gather: if scatter_gather = 0 generate
    dma_address <= (rd_index(29 downto 0) & "00") + bankreg(SRC_OFFSET_REG)
                   when rd_request = '1' else
                   (wr_index(29 downto 0) & "00") + bankreg(DST_OFFSET_REG);
    dma_length_int  <= (rd_length(29 downto 0) & "00")
                   when rd_request = '1' else
                   (wr_length(29 downto 0) & "00");
    dma_tran_start <= '1';
    pending_dma_read <= rd_request;
    pending_dma_write <= wr_request and (not rd_request);
    tlb_empty_int <= '0';
  end generate no_scatter_gather;

  w_scatter_gather: if scatter_gather /= 0 generate
  -----------------------------------------------------------------------------
  -- Page Table
  -----------------------------------------------------------------------------
  -- Info from device registers
  chunk_shift <= bankreg(PT_SHIFT_REG)(4 downto 0);
  -- Stage 0 input
  one_sig <= one;
  fff_sig <= fff;
  chunk_size_in  <= left_shift(one_sig, chunk_shift);
  dma_offset_mask_in <= not left_shift(fff_sig, chunk_shift);
  vaddress_in <= (rd_index(31 - GLOB_BYTE_OFFSET_BITS downto 0) & address_pad_lsb) + bankreg(SRC_OFFSET_REG)
                 when rd_request = '1' else
                 (wr_index(31 - GLOB_BYTE_OFFSET_BITS downto 0) & address_pad_lsb) + bankreg(DST_OFFSET_REG);
  remaining_length_in <= (rd_length(31 - GLOB_BYTE_OFFSET_BITS downto 0) & address_pad_lsb)
                         when rd_request = '1' else
                         (wr_length(31 - GLOB_BYTE_OFFSET_BITS downto 0) & address_pad_lsb);
  -- Stage 1 input
  chunk_index_in <= right_shift(vaddress, chunk_shift);
  dma_offset_in <= vaddress and dma_offset_mask;
  -- Stage 2 input
  dma_length_fallback_in <= chunk_size - dma_offset;
  dma_end_address_in <= dma_offset + remaining_length;
  dma_split_in <= '0' when dma_end_address_in <= chunk_size else '1';
  -- Stage 3 input
  dma_base_address <= tlb_dataout;

  large_phys_addr: process (dma_base_address, dma_offset) is
    variable extended_offset : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  begin  -- process lpa_1
    extended_offset := (others => '0');
    extended_offset(31 downto 0) := dma_offset;
    dma_address_in <= dma_base_address + extended_offset;
  end process large_phys_addr;

  dma_length_in <= remaining_length when (dma_split = '0') or (is_p2p = '1') else dma_length_fallback;
  -- Stage 4 input
  remaining_length_update_in <= remaining_length - dma_length_int;
  vaddress_update_in <= vaddress + dma_length_int;

  tlb_fsm_proc: process(tlb_fsm_current, rd_request, wr_request, tlb_empty_int,
                        dma_tran_done, dma_tran_header_sent, remaining_length,
                        src_is_p2p, dst_is_p2p, is_p2p)
  begin  -- process tlb_fsm_proc
    pt_fsm_sample_0 <= '0';
    pt_fsm_sample_1 <= '0';
    pt_fsm_sample_2 <= '0';
    pt_fsm_sample_3 <= '0';
    pt_fsm_sample_4 <= '0';
    tlb_fsm_next <= tlb_fsm_current;
    tlb_read <= '0';
    dma_tran_start <= '0';
    dma_read_start <= '0';
    dma_read_done <= '0';
    dma_write_start <= '0';
    dma_write_done <= '0';
    is_p2p_in <= '0';
    case tlb_fsm_current is
      when tlb_init =>
        if tlb_empty_int = '0' then
          tlb_fsm_next <= tlb_s0;
        end if;
      when tlb_s0 =>
        -- Priority is always read first
        if rd_request = '1' then
          dma_read_start <= '1';
          pt_fsm_sample_0 <= '1';
          if src_is_p2p = '0' then
            tlb_fsm_next <= tlb_s1;
          else
            is_p2p_in <= '1';
            tlb_fsm_next <= tlb_s3;
          end if;
        elsif wr_request = '1' then
          dma_write_start <= '1';
          pt_fsm_sample_0 <= '1';
          if dst_is_p2p = '0' then
            tlb_fsm_next <= tlb_s1;
          else
            is_p2p_in <= '1';
            tlb_fsm_next <= tlb_s3;
          end if;
        end if;
      when tlb_s1 =>
        pt_fsm_sample_1 <= '1';
        tlb_fsm_next <= tlb_s2;
      when tlb_s2 =>
        tlb_read <= '1';
        pt_fsm_sample_2 <= '1';
        tlb_fsm_next <= tlb_s3;
      when tlb_s3 =>
        pt_fsm_sample_3 <= '1';
        tlb_fsm_next <= tlb_s4;
      when tlb_s4 =>
        pt_fsm_sample_4 <= '1';
        dma_tran_start <= '1';
        tlb_fsm_next <= tlb_s4bis;
      when tlb_s4bis =>
        dma_tran_start <= '1';
        if dma_tran_header_sent = '1' then
          tlb_fsm_next <= tlb_s5;
        end if;
      when tlb_s5 =>
        if dma_tran_done = '1' then
          if (remaining_length = zero) or (is_p2p = '1') then
            dma_read_done <= '1';
            dma_write_done <= '1';
            tlb_fsm_next <= tlb_s0;
          else
            tlb_fsm_next <= tlb_s1;
          end if;
        end if;
      when others =>
        tlb_fsm_next <= tlb_init;
    end case;
  end process tlb_fsm_proc;

  address_resolve_pipeline: process (clk, rst)
  begin  -- process address_resolve_pipeline
    if rst = '0' then                   -- asynchronous reset (active low)
      tlb_fsm_current <= tlb_init;
      pending_dma_read <= '0';
      pending_dma_write <= '0';
      chunk_size <= (others => '0');
      dma_offset_mask <= (others => '0');
      vaddress <= (others => '0');
      remaining_length <= (others => '0');
      chunk_index <= (others => '0');
      dma_offset <= (others => '0');
      dma_length_fallback <= (others => '0');
      dma_end_address <= (others => '0');
      dma_split <= '0';
      dma_address <= (others => '0');
      dma_length_int <= (others => '0');
      is_p2p <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if tlb_empty_int = '1' then
        tlb_fsm_current <= tlb_init;
      else
        tlb_fsm_current <= tlb_fsm_next;
      end if;
      if dma_read_start = '1' then
        pending_dma_read <= '1';
      elsif dma_read_done = '1' then
        pending_dma_read <= '0';
      end if;
      if dma_write_start = '1' then
        pending_dma_write <= '1';
      elsif dma_write_done = '1' then
        pending_dma_write <= '0';
      end if;

      if pt_fsm_sample_0 = '1' then
        is_p2p <= is_p2p_in;
        chunk_size <= chunk_size_in;
        dma_offset_mask <= dma_offset_mask_in;
        vaddress <= vaddress_in;
        remaining_length <= remaining_length_in;
      end if;
      if pt_fsm_sample_1 = '1' then
        chunk_index <= chunk_index_in;
        dma_offset <= dma_offset_in;  
      end if;
      if pt_fsm_sample_2 = '1' then
        dma_length_fallback <= dma_length_fallback_in;
        dma_end_address <= dma_end_address_in;
        dma_split <= dma_split_in;  
      end if;
      if pt_fsm_sample_3 = '1' then
        dma_address <= dma_address_in;
        dma_length_int <= dma_length_in;
      end if;
      if pt_fsm_sample_4 = '1' then
        vaddress <= vaddress_update_in;
        remaining_length <= remaining_length_update_in;
      end if;
    end if;
  end process address_resolve_pipeline;

  -- Read during TLB FSM Stage 2
  tlb_status_register: process (clk, rst)
  begin  -- process tlb_status_register
    if rst = '0' then                   -- asynchronous reset (active low)
      tlb_empty_int <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (src_is_p2p and dst_is_p2p) = '1' then
        tlb_empty_int <= '0';
      else
        if tlb_valid = '1' then
          tlb_empty_int <= '0';
        end if;
        if tlb_clear = '1' then
          tlb_empty_int <= '1';
        end if;
      end if;
    end if;
  end process tlb_status_register;
  tlb_rd_address <= chunk_index((log2(tlb_entries) -1) downto 0);
  tlb_address <= tlb_wr_address when tlb_write = '1' else tlb_rd_address;
  tlb_enable <= tlb_read or tlb_write;

  -- TLB
  syncram_1: syncram
    generic map (
      tech       => tech,
      abits      => log2(tlb_entries),
      dbits      => GLOB_PHYS_ADDR_BITS)
    port map (
      clk       => clk,
      address   => tlb_address,
      datain    => tlb_datain,
      dataout   => tlb_dataout,
      enable    => tlb_enable,
      write     => tlb_write);

  end generate w_scatter_gather;


end tlb;
