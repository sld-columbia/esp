-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;

package allcaches is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

  -- Warning: setting max number of fully-coherent devices to 16 and max number
  -- of LLC-coherent devices to 16. This is due to VHDL limitation, but the
  -- following constant can be changed arbitrarily.
  constant NL2_MAX_LOG2  : integer := 4;
  constant NLLC_MAX_LOG2 : integer := 6;
  type cache_attribute_array is array (0 to 2**NL2_MAX_LOG2 - 1) of integer;
  type dma_attribute_array is array (0 to 2**NLLC_MAX_LOG2 - 1) of integer;

  -- Global architecture parameters
  constant WORD_OFFSET_BITS : integer := GLOB_WORD_OFFSET_BITS;
  constant BYTE_OFFSET_BITS : integer := GLOB_BYTE_OFFSET_BITS;
  constant ADDR_BITS        : integer := GLOB_PHYS_ADDR_BITS;
  --

  constant OFFSET_BITS    : integer := WORD_OFFSET_BITS + BYTE_OFFSET_BITS;
  constant LINE_ADDR_BITS : integer := ADDR_BITS - OFFSET_BITS;
  constant WORDS_PER_LINE : integer := 2**WORD_OFFSET_BITS;
  constant AMO_BITS       : integer := 6;
  constant DCS_BITS       : integer := 2;
  constant BYTES_PER_WORD : integer := 2**BYTE_OFFSET_BITS;
  constant BYTES_PER_LINE : integer := WORDS_PER_LINE * BYTES_PER_WORD;
  constant BITS_PER_WORD  : integer := (BYTES_PER_WORD * 8);
  constant BITS_PER_HWORD : integer := BITS_PER_WORD/2;
  constant BITS_PER_LINE  : integer := (BITS_PER_WORD * WORDS_PER_LINE);

  -- Cache data types width
  constant CPU_MSG_TYPE_WIDTH : integer := 2;
  constant COH_MSG_TYPE_WIDTH : integer := 4;
  constant MIX_MSG_TYPE_WIDTH : integer := 5;

  constant HSIZE_WIDTH           : integer := 3;
  constant HPROT_WIDTH           : integer := 2;
  constant BRESP_WIDTH           : integer := 2;
  constant INVACK_CNT_WIDTH      : integer := NL2_MAX_LOG2;
  constant INVACK_CNT_CALC_WIDTH : integer := INVACK_CNT_WIDTH + 1;

  --constant ASSERTS_WIDTH : integer := 19;
  --constant BOOKMARK_WIDTH : integer := 32;
  --constant LLC_ASSERTS_WIDTH : integer := 6;
  --constant LLC_BOOKMARK_WIDTH : integer := 10;
  constant ASSERTS_AHBS_WIDTH     : integer := 14;
  constant ASSERTS_AHBM_WIDTH     : integer := 1;
  constant ASSERTS_REQ_WIDTH      : integer := 1;
  constant ASSERTS_RSP_IN_WIDTH   : integer := 1;
  constant ASSERTS_FWD_WIDTH      : integer := 1;
  constant ASSERTS_RSP_OUT_WIDTH  : integer := 1;
  constant ASSERTS_LLC_AHBM_WIDTH : integer := 2;


  -----------------------------------------------------------------------------
  -- Implementations
  -----------------------------------------------------------------------------

  component l2_rtl_top
    port (
      clk                       : in  std_ulogic;
      rst                       : in  std_ulogic;
      l2_cpu_req_valid          : in  std_ulogic;
      l2_cpu_req_data_cpu_msg   : in  std_logic_vector(CPU_MSG_TYPE_WIDTH - 1 downto 0);
      l2_cpu_req_data_hsize     : in  std_logic_vector(HSIZE_WIDTH - 1 downto 0);
      l2_cpu_req_data_hprot     : in  std_logic_vector(HPROT_WIDTH - 1 downto 0);
      l2_cpu_req_data_addr      : in  std_logic_vector(ADDR_BITS - 1 downto 0);
      l2_cpu_req_data_word      : in  std_logic_vector(BITS_PER_WORD - 1 downto 0);
      l2_cpu_req_data_amo       : in  std_logic_vector(AMO_BITS - 1 downto 0);
      l2_fwd_in_valid           : in  std_ulogic;
      l2_fwd_in_data_coh_msg    : in  std_logic_vector(MIX_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      l2_fwd_in_data_addr       : in  std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      l2_fwd_in_data_req_id     : in  std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
      l2_rsp_in_valid           : in  std_ulogic;
      l2_rsp_in_data_coh_msg    : in  std_logic_vector(COH_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      l2_rsp_in_data_addr       : in  std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      l2_rsp_in_data_line       : in  std_logic_vector(BITS_PER_LINE - 1 downto 0);
      l2_rsp_in_data_invack_cnt : in  std_logic_vector(INVACK_CNT_WIDTH - 1 downto 0);
      l2_flush_valid            : in  std_ulogic;
      l2_flush_data             : in  std_ulogic;
      l2_rd_rsp_ready           : in  std_ulogic;
      l2_inval_ready            : in  std_ulogic;
      l2_req_out_ready          : in  std_ulogic;
      l2_rsp_out_ready          : in  std_ulogic;
      l2_bresp_ready            : in  std_ulogic;
      l2_stats_ready            : in  std_ulogic;
      flush_done                : out std_ulogic;
      l2_cpu_req_ready          : out std_ulogic;
      l2_fwd_in_ready           : out std_ulogic;
      l2_rsp_in_ready           : out std_ulogic;
      l2_flush_ready            : out std_ulogic;
      l2_rd_rsp_valid           : out std_ulogic;
      l2_rd_rsp_data_line       : out std_logic_vector(BITS_PER_LINE - 1 downto 0);
      l2_inval_valid            : out std_ulogic;
      l2_inval_data_addr        : out std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      l2_inval_data_hprot       : out std_logic_vector(HPROT_WIDTH - 1 downto 0);
      l2_req_out_valid          : out std_ulogic;
      l2_req_out_data_coh_msg   : out std_logic_vector(COH_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      l2_req_out_data_hprot     : out std_logic_vector(HPROT_WIDTH - 1 downto 0);
      l2_req_out_data_addr      : out std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      l2_req_out_data_line      : out std_logic_vector(BITS_PER_LINE - 1 downto 0);
      l2_rsp_out_valid          : out std_ulogic;
      l2_rsp_out_data_coh_msg   : out std_logic_vector(COH_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      l2_rsp_out_data_req_id    : out std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
      l2_rsp_out_data_to_req    : out std_logic_vector(1 downto 0);
      l2_rsp_out_data_addr      : out std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      l2_rsp_out_data_line      : out std_logic_vector(BITS_PER_LINE - 1 downto 0);
      l2_bresp_valid            : out std_ulogic;
      l2_bresp_data             : out std_logic_vector(BRESP_WIDTH - 1 downto 0);
      l2_stats_valid            : out std_ulogic;
      l2_stats_data             : out std_ulogic
      );
  end component;

  component llc_rtl_top
    port (
      clk                              : in  std_ulogic;
      rst                              : in  std_ulogic;
      llc_req_in_valid                 : in  std_ulogic;
      llc_req_in_data_coh_msg          : in  std_logic_vector(MIX_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      llc_req_in_data_hprot            : in  std_logic_vector(HPROT_WIDTH - 1 downto 0);
      llc_req_in_data_addr             : in  std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      llc_req_in_data_word_offset      : in  std_logic_vector(WORD_OFFSET_BITS - 1 downto 0);
      llc_req_in_data_valid_words      : in  std_logic_vector(WORD_OFFSET_BITS - 1 downto 0);
      llc_req_in_data_line             : in  std_logic_vector(BITS_PER_LINE - 1 downto 0);
      llc_req_in_data_req_id           : in  std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
      llc_dma_req_in_valid             : in  std_ulogic;
      llc_dma_req_in_data_coh_msg      : in  std_logic_vector(MIX_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      llc_dma_req_in_data_hprot        : in  std_logic_vector(HPROT_WIDTH - 1 downto 0);
      llc_dma_req_in_data_addr         : in  std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      llc_dma_req_in_data_word_offset  : in  std_logic_vector(WORD_OFFSET_BITS - 1 downto 0);
      llc_dma_req_in_data_valid_words  : in  std_logic_vector(WORD_OFFSET_BITS - 1 downto 0);
      llc_dma_req_in_data_line         : in  std_logic_vector(BITS_PER_LINE - 1 downto 0);
      llc_dma_req_in_data_req_id       : in  std_logic_vector(NLLC_MAX_LOG2 - 1 downto 0);
      llc_rsp_in_valid                 : in  std_ulogic;
      llc_rsp_in_data_coh_msg          : in  std_logic_vector(COH_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      llc_rsp_in_data_addr             : in  std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      llc_rsp_in_data_line             : in  std_logic_vector(BITS_PER_LINE - 1 downto 0);
      llc_rsp_in_data_req_id           : in  std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
      llc_mem_rsp_valid                : in  std_ulogic;
      llc_mem_rsp_data_line            : in  std_logic_vector(BITS_PER_LINE - 1 downto 0);
      llc_rst_tb_valid                 : in  std_ulogic;
      llc_rst_tb_data                  : in  std_ulogic;
      llc_rsp_out_ready                : in  std_ulogic;
      llc_dma_rsp_out_ready            : in  std_ulogic;
      llc_fwd_out_ready                : in  std_ulogic;
      llc_mem_req_ready                : in  std_ulogic;
      llc_rst_tb_done_ready            : in  std_ulogic;
      llc_stats_ready                  : in  std_ulogic;
      llc_req_in_ready                 : out std_ulogic;
      llc_dma_req_in_ready             : out std_ulogic;
      llc_rsp_in_ready                 : out std_ulogic;
      llc_mem_rsp_ready                : out std_ulogic;
      llc_rst_tb_ready                 : out std_ulogic;
      llc_rsp_out_valid                : out std_ulogic;
      llc_rsp_out_data_coh_msg         : out std_logic_vector(COH_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      llc_rsp_out_data_addr            : out std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      llc_rsp_out_data_line            : out std_logic_vector(BITS_PER_LINE - 1 downto 0);
      llc_rsp_out_data_invack_cnt      : out std_logic_vector(INVACK_CNT_WIDTH - 1 downto 0);
      llc_rsp_out_data_req_id          : out std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
      llc_rsp_out_data_dest_id         : out std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
      llc_rsp_out_data_word_offset     : out std_logic_vector(WORD_OFFSET_BITS - 1 downto 0);
      llc_dma_rsp_out_valid            : out std_ulogic;
      llc_dma_rsp_out_data_coh_msg     : out std_logic_vector(COH_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      llc_dma_rsp_out_data_addr        : out std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      llc_dma_rsp_out_data_line        : out std_logic_vector(BITS_PER_LINE - 1 downto 0);
      llc_dma_rsp_out_data_invack_cnt  : out std_logic_vector(INVACK_CNT_WIDTH - 1 downto 0);
      llc_dma_rsp_out_data_req_id      : out std_logic_vector(NLLC_MAX_LOG2 - 1 downto 0);
      llc_dma_rsp_out_data_dest_id     : out std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
      llc_dma_rsp_out_data_word_offset : out std_logic_vector(WORD_OFFSET_BITS - 1 downto 0);
      llc_fwd_out_valid                : out std_ulogic;
      llc_fwd_out_data_coh_msg         : out std_logic_vector(MIX_MSG_TYPE_WIDTH - 2 - 1 downto 0);
      llc_fwd_out_data_addr            : out std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      llc_fwd_out_data_req_id          : out std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
      llc_fwd_out_data_dest_id         : out std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
      llc_mem_req_valid                : out std_ulogic;
      llc_mem_req_data_hwrite          : out std_ulogic;
      llc_mem_req_data_hsize           : out std_logic_vector(HSIZE_WIDTH - 1 downto 0);
      llc_mem_req_data_hprot           : out std_logic_vector(HPROT_WIDTH - 1 downto 0);
      llc_mem_req_data_addr            : out std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
      llc_mem_req_data_line            : out std_logic_vector(BITS_PER_LINE - 1 downto 0);
      llc_stats_valid                  : out std_ulogic;
      llc_stats_data                   : out std_ulogic;
      llc_rst_tb_done_valid            : out std_ulogic;
      llc_rst_tb_done_data             : out std_ulogic
      );
  end component;

  -- <<caches-components>>

end;
