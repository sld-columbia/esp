-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use work.sld_devices.all;
use work.allcaches.all;

entity l2 is

    generic (
      use_rtl          : integer;
      sets             : integer;
      ways             : integer
    );

    port (
      clk                       : in  std_ulogic;
      rst                       : in  std_ulogic;
      l2_cpu_req_valid          : in  std_ulogic;
      l2_cpu_req_data_cpu_msg   : in  std_logic_vector(1 downto 0);
      l2_cpu_req_data_hsize     : in  std_logic_vector(2 downto 0);
      l2_cpu_req_data_hprot     : in  std_logic_vector(1 downto 0);
      l2_cpu_req_data_addr      : in  std_logic_vector(31 downto 0);
      l2_cpu_req_data_word      : in  std_logic_vector(63 downto 0);
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

end entity l2;


architecture mapping of l2 is

begin  -- mapping

  rtl_gen: if use_rtl /= 0 generate
    l2_rtl_top_i: l2_rtl_top
    port map(
      clk                       => clk,
      rst                       => rst,
      l2_cpu_req_valid          => l2_cpu_req_valid,
      l2_cpu_req_data_cpu_msg   => l2_cpu_req_data_cpu_msg,
      l2_cpu_req_data_hsize     => l2_cpu_req_data_hsize,
      l2_cpu_req_data_hprot     => l2_cpu_req_data_hprot,
      l2_cpu_req_data_addr      => l2_cpu_req_data_addr,
      l2_cpu_req_data_word      => l2_cpu_req_data_word,
      l2_fwd_in_valid           => l2_fwd_in_valid,
      l2_fwd_in_data_coh_msg    => l2_fwd_in_data_coh_msg,
      l2_fwd_in_data_addr       => l2_fwd_in_data_addr,
      l2_fwd_in_data_req_id     => l2_fwd_in_data_req_id,
      l2_rsp_in_valid           => l2_rsp_in_valid,
      l2_rsp_in_data_coh_msg    => l2_rsp_in_data_coh_msg,
      l2_rsp_in_data_addr       => l2_rsp_in_data_addr,
      l2_rsp_in_data_line       => l2_rsp_in_data_line,
      l2_rsp_in_data_invack_cnt => l2_rsp_in_data_invack_cnt,
      l2_flush_valid            => l2_flush_valid,
      l2_flush_data             => l2_flush_data,
      l2_rd_rsp_ready           => l2_rd_rsp_ready,
      l2_inval_ready            => l2_inval_ready,
      l2_req_out_ready          => l2_req_out_ready,
      l2_rsp_out_ready          => l2_rsp_out_ready,
      l2_stats_ready            => l2_stats_ready,
      flush_done                => flush_done,
      l2_cpu_req_ready          => l2_cpu_req_ready,
      l2_fwd_in_ready           => l2_fwd_in_ready,
      l2_rsp_in_ready           => l2_rsp_in_ready,
      l2_flush_ready            => l2_flush_ready,
      l2_rd_rsp_valid           => l2_rd_rsp_valid,
      l2_rd_rsp_data_line       => l2_rd_rsp_data_line,
      l2_inval_valid            => l2_inval_valid,
      l2_inval_data             => l2_inval_data,
      l2_req_out_valid          => l2_req_out_valid,
      l2_req_out_data_coh_msg   => l2_req_out_data_coh_msg,
      l2_req_out_data_hprot     => l2_req_out_data_hprot,
      l2_req_out_data_addr      => l2_req_out_data_addr,
      l2_req_out_data_line      => l2_req_out_data_line,
      l2_rsp_out_valid          => l2_rsp_out_valid,
      l2_rsp_out_data_coh_msg   => l2_rsp_out_data_coh_msg,
      l2_rsp_out_data_req_id    => l2_rsp_out_data_req_id,
      l2_rsp_out_data_to_req    => l2_rsp_out_data_to_req,
      l2_rsp_out_data_addr      => l2_rsp_out_data_addr,
      l2_rsp_out_data_line      => l2_rsp_out_data_line,
      l2_stats_valid            => l2_stats_valid,
      l2_stats_data             => l2_stats_data
    );
  end generate rtl_gen;


  hls_gen: if use_rtl = 0 generate
  end generate hls_gen;

end mapping;

library ieee;
use ieee.std_logic_1164.all;
use work.sld_devices.all;
use work.allcaches.all;

entity llc is

    generic (
      use_rtl          : integer;
      sets             : integer;
      ways             : integer
    );

    port (
      clk                          : in std_ulogic;
      rst                          : in std_ulogic;
      llc_req_in_valid             : in std_ulogic;
      llc_req_in_data_coh_msg      : in std_logic_vector(2 downto 0);
      llc_req_in_data_hprot        : in std_logic_vector(1 downto 0);
      llc_req_in_data_addr         : in std_logic_vector(27 downto 0);
      llc_req_in_data_word_offset  : in std_logic_vector(0 downto 0);
      llc_req_in_data_valid_words  : in std_logic_vector(0 downto 0);
      llc_req_in_data_line         : in std_logic_vector(127  downto 0);
      llc_req_in_data_req_id       : in std_logic_vector(3 downto 0);
      llc_dma_req_in_valid             : in std_ulogic;
      llc_dma_req_in_data_coh_msg      : in std_logic_vector(2 downto 0);
      llc_dma_req_in_data_hprot        : in std_logic_vector(1 downto 0);
      llc_dma_req_in_data_addr         : in std_logic_vector(27 downto 0);
      llc_dma_req_in_data_word_offset  : in std_logic_vector(0 downto 0);
      llc_dma_req_in_data_valid_words  : in std_logic_vector(0 downto 0);
      llc_dma_req_in_data_line         : in std_logic_vector(127 downto 0);
      llc_dma_req_in_data_req_id       : in std_logic_vector(5 downto 0);
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
      llc_rsp_out_data_word_offset : out std_logic_vector(0 downto 0);
      llc_dma_rsp_out_valid            : out std_ulogic;
      llc_dma_rsp_out_data_coh_msg     : out std_logic_vector(1 downto 0);
      llc_dma_rsp_out_data_addr        : out std_logic_vector(27 downto 0);
      llc_dma_rsp_out_data_line        : out std_logic_vector(127 downto 0);
      llc_dma_rsp_out_data_invack_cnt  : out std_logic_vector(3 downto 0);
      llc_dma_rsp_out_data_req_id      : out std_logic_vector(5 downto 0);
      llc_dma_rsp_out_data_dest_id     : out std_logic_vector(3 downto 0);
      llc_dma_rsp_out_data_word_offset : out std_logic_vector(0 downto 0);
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

end entity llc;


architecture mapping of llc is

begin  -- mapping

  rtl_gen: if use_rtl /= 0 generate
    llc_rtl_top_i: llc_rtl_top
    port map(
      clk                          => clk,
      rst                          => rst,
      llc_req_in_valid             => llc_req_in_valid,
      llc_req_in_data_coh_msg      => llc_req_in_data_coh_msg,
      llc_req_in_data_hprot        => llc_req_in_data_hprot,
      llc_req_in_data_addr         => llc_req_in_data_addr,
      llc_req_in_data_word_offset  => llc_req_in_data_word_offset,
      llc_req_in_data_valid_words  => llc_req_in_data_valid_words,
      llc_req_in_data_line         => llc_req_in_data_line,
      llc_req_in_data_req_id       => llc_req_in_data_req_id,
      llc_dma_req_in_valid             => llc_dma_req_in_valid,
      llc_dma_req_in_data_coh_msg      => llc_dma_req_in_data_coh_msg,
      llc_dma_req_in_data_hprot        => llc_dma_req_in_data_hprot,
      llc_dma_req_in_data_addr         => llc_dma_req_in_data_addr,
      llc_dma_req_in_data_word_offset  => llc_dma_req_in_data_word_offset,
      llc_dma_req_in_data_valid_words  => llc_dma_req_in_data_valid_words,
      llc_dma_req_in_data_line         => llc_dma_req_in_data_line,
      llc_dma_req_in_data_req_id       => llc_dma_req_in_data_req_id,
      llc_rsp_in_valid             => llc_rsp_in_valid,
      llc_rsp_in_data_coh_msg      => llc_rsp_in_data_coh_msg,
      llc_rsp_in_data_addr         => llc_rsp_in_data_addr,
      llc_rsp_in_data_line         => llc_rsp_in_data_line,
      llc_rsp_in_data_req_id       => llc_rsp_in_data_req_id,
      llc_mem_rsp_valid            => llc_mem_rsp_valid,
      llc_mem_rsp_data_line        => llc_mem_rsp_data_line,
      llc_rst_tb_valid             => llc_rst_tb_valid,
      llc_rst_tb_data              => llc_rst_tb_data,
      llc_rsp_out_ready            => llc_rsp_out_ready,
      llc_dma_rsp_out_ready            => llc_dma_rsp_out_ready,
      llc_fwd_out_ready            => llc_fwd_out_ready,
      llc_mem_req_ready            => llc_mem_req_ready,
      llc_rst_tb_done_ready        => llc_rst_tb_done_ready,
      llc_stats_ready              => llc_stats_ready,
      llc_req_in_ready             => llc_req_in_ready,
      llc_dma_req_in_ready             => llc_dma_req_in_ready,
      llc_rsp_in_ready             => llc_rsp_in_ready,
      llc_mem_rsp_ready            => llc_mem_rsp_ready,
      llc_rst_tb_ready             => llc_rst_tb_ready,
      llc_rsp_out_valid            => llc_rsp_out_valid,
      llc_rsp_out_data_coh_msg     => llc_rsp_out_data_coh_msg,
      llc_rsp_out_data_addr        => llc_rsp_out_data_addr,
      llc_rsp_out_data_line        => llc_rsp_out_data_line,
      llc_rsp_out_data_invack_cnt  => llc_rsp_out_data_invack_cnt,
      llc_rsp_out_data_req_id      => llc_rsp_out_data_req_id,
      llc_rsp_out_data_dest_id     => llc_rsp_out_data_dest_id,
      llc_rsp_out_data_word_offset => llc_rsp_out_data_word_offset,
      llc_dma_rsp_out_valid            => llc_dma_rsp_out_valid,
      llc_dma_rsp_out_data_coh_msg     => llc_dma_rsp_out_data_coh_msg,
      llc_dma_rsp_out_data_addr        => llc_dma_rsp_out_data_addr,
      llc_dma_rsp_out_data_line        => llc_dma_rsp_out_data_line,
      llc_dma_rsp_out_data_invack_cnt  => llc_dma_rsp_out_data_invack_cnt,
      llc_dma_rsp_out_data_req_id      => llc_dma_rsp_out_data_req_id,
      llc_dma_rsp_out_data_dest_id     => llc_dma_rsp_out_data_dest_id,
      llc_dma_rsp_out_data_word_offset => llc_dma_rsp_out_data_word_offset,
      llc_fwd_out_valid            => llc_fwd_out_valid,
      llc_fwd_out_data_coh_msg     => llc_fwd_out_data_coh_msg,
      llc_fwd_out_data_addr        => llc_fwd_out_data_addr,
      llc_fwd_out_data_req_id      => llc_fwd_out_data_req_id,
      llc_fwd_out_data_dest_id     => llc_fwd_out_data_dest_id,
      llc_mem_req_valid            => llc_mem_req_valid,
      llc_mem_req_data_hwrite      => llc_mem_req_data_hwrite,
      llc_mem_req_data_hsize       => llc_mem_req_data_hsize,
      llc_mem_req_data_hprot       => llc_mem_req_data_hprot,
      llc_mem_req_data_addr        => llc_mem_req_data_addr,
      llc_mem_req_data_line        => llc_mem_req_data_line,
      llc_stats_valid              => llc_stats_valid,
      llc_stats_data               => llc_stats_data,
      llc_rst_tb_done_valid        => llc_rst_tb_done_valid,
      llc_rst_tb_done_data         => llc_rst_tb_done_data
    );
  end generate rtl_gen;


  hls_gen: if use_rtl = 0 generate
  end generate hls_gen;

end mapping;

