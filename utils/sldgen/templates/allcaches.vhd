-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;

package allcaches is

    component l2_rtl_top
    port (
      clk                       : in  std_ulogic;
      rst                       : in  std_ulogic;
      l2_cpu_req_valid          : in  std_ulogic;
      l2_cpu_req_data_cpu_msg   : in  std_logic_vector(1 downto 0);
      l2_cpu_req_data_hsize     : in  std_logic_vector(2 downto 0);
      l2_cpu_req_data_hprot     : in  std_logic_vector(1 downto 0);
      l2_cpu_req_data_addr      : in  std_logic_vector(31 downto 0);
      l2_cpu_req_data_word      : in  std_logic_vector(31 downto 0);
      l2_fwd_in_valid           : in  std_ulogic;
      l2_fwd_in_data_coh_msg    : in  std_logic_vector(2 downto 0);
      l2_fwd_in_data_addr       : in  std_logic_vector(27 downto 0);
      l2_fwd_in_data_req_id     : in  std_logic_vector(3 downto 0);
      l2_rsp_in_valid           : in  std_ulogic;
      l2_rsp_in_data_coh_msg    : in  std_logic_vector(1 downto 0);
      l2_rsp_in_data_addr       : in  std_logic_vector(27 downto 0);
      l2_rsp_in_data_line       : in  std_logic_vector(127 downto 0);
      l2_rsp_in_data_invack_cnt : in  std_logic_vector(3 downto 0);
      l2_flush_valid            : in  std_ulogic;
      l2_flush_data             : in  std_ulogic;
      l2_rd_rsp_ready           : in  std_ulogic;
      l2_inval_ready            : in  std_ulogic;
      l2_req_out_ready          : in  std_ulogic;
      l2_rsp_out_ready          : in  std_ulogic;
      l2_stats_ready            : in  std_ulogic;
      flush_done                : out std_ulogic;
      l2_cpu_req_ready          : out std_ulogic;
      l2_fwd_in_ready           : out std_ulogic;
      l2_rsp_in_ready           : out std_ulogic;
      l2_flush_ready            : out std_ulogic;
      l2_rd_rsp_valid           : out std_ulogic;
      l2_rd_rsp_data_line       : out std_logic_vector(127 downto 0);
      l2_inval_valid            : out std_ulogic;
      l2_inval_data             : out std_logic_vector(27 downto 0);
      l2_req_out_valid          : out std_ulogic;
      l2_req_out_data_coh_msg   : out std_logic_vector(1 downto 0);
      l2_req_out_data_hprot     : out std_logic_vector(1 downto 0);
      l2_req_out_data_addr      : out std_logic_vector(27 downto 0);
      l2_req_out_data_line      : out std_logic_vector(127 downto 0);
      l2_rsp_out_valid          : out std_ulogic;
      l2_rsp_out_data_coh_msg   : out std_logic_vector(1 downto 0);
      l2_rsp_out_data_req_id    : out std_logic_vector(3 downto 0);
      l2_rsp_out_data_to_req    : out std_logic_vector(1 downto 0);
      l2_rsp_out_data_addr      : out std_logic_vector(27 downto 0);
      l2_rsp_out_data_line      : out std_logic_vector(127 downto 0);
      l2_stats_valid            : out std_ulogic;
      l2_stats_data             : out std_ulogic
    );
  end component;

  component llc_rtl_top
    port (
      clk                          : in std_ulogic;
      rst                          : in std_ulogic;
      llc_req_in_valid             : in std_ulogic;
      llc_req_in_data_coh_msg      : in std_logic_vector(2 downto 0);
      llc_req_in_data_hprot        : in std_logic_vector(1 downto 0);
      llc_req_in_data_addr         : in std_logic_vector(27 downto 0);
      llc_req_in_data_word_offset  : in std_logic_vector(1 downto 0);
      llc_req_in_data_valid_words  : in std_logic_vector(1 downto 0);
      llc_req_in_data_line         : in std_logic_vector(127  downto 0);
      llc_req_in_data_req_id       : in std_logic_vector(3 downto 0);
      llc_dma_req_in_valid             : in std_ulogic;
      llc_dma_req_in_data_coh_msg      : in std_logic_vector(2 downto 0);
      llc_dma_req_in_data_hprot        : in std_logic_vector(1 downto 0);
      llc_dma_req_in_data_addr         : in std_logic_vector(27 downto 0);
      llc_dma_req_in_data_word_offset  : in std_logic_vector(1 downto 0);
      llc_dma_req_in_data_valid_words  : in std_logic_vector(1 downto 0);
      llc_dma_req_in_data_line         : in std_logic_vector(127 downto 0);
      llc_dma_req_in_data_req_id       : in std_logic_vector(3 downto 0);
      llc_rsp_in_valid             : in std_ulogic;
      llc_rsp_in_data_coh_msg      : in std_logic_vector(1 downto 0);
      llc_rsp_in_data_addr         : in std_logic_vector(27 downto 0);
      llc_rsp_in_data_line         : in std_logic_vector(127 downto 0);
      llc_rsp_in_data_req_id       : in std_logic_vector(3 downto 0);
      llc_mem_rsp_valid            : in std_ulogic;
      llc_mem_rsp_data_line        : in std_logic_vector(127 downto 0);
      llc_rst_tb_valid             : in std_ulogic;
      llc_rst_tb_data              : in std_ulogic;
      llc_rsp_out_ready            : in std_ulogic;
      llc_dma_rsp_out_ready            : in std_ulogic;
      llc_fwd_out_ready            : in std_ulogic;
      llc_mem_req_ready            : in std_ulogic;
      llc_rst_tb_done_ready        : in std_ulogic;
      llc_stats_ready              : in std_ulogic;
      llc_req_in_ready             : out std_ulogic;
      llc_dma_req_in_ready             : out std_ulogic;
      llc_rsp_in_ready             : out std_ulogic;
      llc_mem_rsp_ready            : out std_ulogic;
      llc_rst_tb_ready             : out std_ulogic;
      llc_rsp_out_valid            : out std_ulogic;
      llc_rsp_out_data_coh_msg     : out std_logic_vector(1 downto 0);
      llc_rsp_out_data_addr        : out std_logic_vector(27 downto 0);
      llc_rsp_out_data_line        : out std_logic_vector(127 downto 0);
      llc_rsp_out_data_invack_cnt  : out std_logic_vector(3 downto 0);
      llc_rsp_out_data_req_id      : out std_logic_vector(3 downto 0);
      llc_rsp_out_data_dest_id     : out std_logic_vector(3 downto 0);
      llc_rsp_out_data_word_offset : out std_logic_vector(1 downto 0);
      llc_dma_rsp_out_valid            : out std_ulogic;
      llc_dma_rsp_out_data_coh_msg     : out std_logic_vector(1 downto 0);
      llc_dma_rsp_out_data_addr        : out std_logic_vector(27 downto 0);
      llc_dma_rsp_out_data_line        : out std_logic_vector(127 downto 0);
      llc_dma_rsp_out_data_invack_cnt  : out std_logic_vector(3 downto 0);
      llc_dma_rsp_out_data_req_id      : out std_logic_vector(3 downto 0);
      llc_dma_rsp_out_data_dest_id     : out std_logic_vector(3 downto 0);
      llc_dma_rsp_out_data_word_offset : out std_logic_vector(1 downto 0);
      llc_fwd_out_valid            : out std_ulogic;
      llc_fwd_out_data_coh_msg     : out std_logic_vector(2 downto 0);
      llc_fwd_out_data_addr        : out std_logic_vector(27 downto 0);
      llc_fwd_out_data_req_id      : out std_logic_vector(3 downto 0);
      llc_fwd_out_data_dest_id     : out std_logic_vector(3 downto 0);
      llc_mem_req_valid            : out std_ulogic;
      llc_mem_req_data_hwrite      : out std_ulogic;
      llc_mem_req_data_hsize       : out std_logic_vector(2 downto 0);
      llc_mem_req_data_hprot       : out std_logic_vector(1 downto 0);
      llc_mem_req_data_addr        : out std_logic_vector(27 downto 0);
      llc_mem_req_data_line        : out std_logic_vector(127 downto 0);
      llc_stats_valid              : out std_ulogic;
      llc_stats_data               : out std_ulogic;
      llc_rst_tb_done_valid        : out std_ulogic;
      llc_rst_tb_done_data         : out std_ulogic
    );
  end component;

  -- <<caches-components>>

end;
