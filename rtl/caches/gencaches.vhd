-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use work.esp_global.all;
use work.sld_devices.all;
use work.cachepackage.all;

package gencaches is


  component l2
    generic (
      use_rtl : integer;
      little_end : integer range 0 to 1;
      llsc : integer range 0 to 1;
      sets : integer;
      ways : integer
      );

    port (
      clk : in std_ulogic;
      rst : in std_ulogic;
      l2_cpu_req_valid : in std_ulogic;
      l2_cpu_req_data_cpu_msg : in cpu_msg_t;
      l2_cpu_req_data_hsize : in hsize_t;
      l2_cpu_req_data_hprot : in hprot_t;
      l2_cpu_req_data_addr : in addr_t;
      l2_cpu_req_data_word : in word_t;
      l2_cpu_req_data_amo : in amo_t;
      l2_fwd_in_valid : in std_ulogic;
      l2_fwd_in_data_coh_msg : in std_logic_vector(2 downto 0);
      l2_fwd_in_data_addr : in line_addr_t;
      l2_fwd_in_data_req_id : in cache_id_t;
      l2_rsp_in_valid : in std_ulogic;
      l2_rsp_in_data_coh_msg : in std_logic_vector(1 downto 0);
      l2_rsp_in_data_addr : in line_addr_t;
      l2_rsp_in_data_line : in line_t;
      l2_rsp_in_data_invack_cnt : in invack_cnt_t;
      l2_flush_valid : in std_ulogic;
      l2_flush_data : in std_ulogic;
      l2_rd_rsp_ready : in std_ulogic;
      l2_inval_ready : in std_ulogic;
      l2_bresp_ready : in std_ulogic;
      l2_req_out_ready : in std_ulogic;
      l2_rsp_out_ready : in std_ulogic;
      l2_stats_ready : in std_ulogic;
      flush_done : out std_ulogic;
      l2_cpu_req_ready : out std_ulogic;
      l2_fwd_in_ready : out std_ulogic;
      l2_rsp_in_ready : out std_ulogic;
      l2_flush_ready : out std_ulogic;
      l2_rd_rsp_valid : out std_ulogic;
      l2_rd_rsp_data_line : out line_t;
      l2_inval_valid : out std_ulogic;
      l2_inval_data_addr : out line_addr_t;
      l2_inval_data_hprot : out hprot_t;
      l2_bresp_valid : out std_ulogic;
      l2_bresp_data : out bresp_t;
      l2_req_out_valid : out std_ulogic;
      l2_req_out_data_coh_msg : out std_logic_vector(1 downto 0);
      l2_req_out_data_hprot : out hprot_t;
      l2_req_out_data_addr : out line_addr_t;
      l2_req_out_data_line : out line_t;
      l2_rsp_out_valid : out std_ulogic;
      l2_rsp_out_data_coh_msg : out std_logic_vector(1 downto 0);
      l2_rsp_out_data_req_id : out cache_id_t;
      l2_rsp_out_data_to_req : out std_logic_vector(1 downto 0);
      l2_rsp_out_data_addr : out line_addr_t;
      l2_rsp_out_data_line : out line_t;
      l2_stats_valid : out std_ulogic;
      l2_stats_data : out std_ulogic
      );
  end component;

  component l2_spandex
    generic (
      use_rtl : integer;
      little_end : integer range 0 to 1;
      sets : integer;
      ways : integer
      );

    port (
      clk : in std_ulogic;
      rst : in std_ulogic;
      l2_cpu_req_valid : in std_ulogic;
      l2_cpu_req_data_cpu_msg : in cpu_msg_t;
      l2_cpu_req_data_hsize : in hsize_t;
      l2_cpu_req_data_hprot : in hprot_t;
      l2_cpu_req_data_addr : in addr_t;
      l2_cpu_req_data_word : in word_t;
      l2_cpu_req_data_amo : in amo_t;
      l2_cpu_req_data_aq : in std_ulogic;
      l2_cpu_req_data_rl : in std_ulogic;
      l2_cpu_req_data_dcs_en : in std_ulogic;
      l2_cpu_req_data_use_owner_pred : in std_ulogic;
      l2_cpu_req_data_dcs : in dcs_t;
      l2_cpu_req_data_pred_cid : in cache_id_t;
      l2_fwd_in_valid : in std_ulogic;
      l2_fwd_in_data_coh_msg : in mix_msg_t;
      l2_fwd_in_data_addr : in line_addr_t;
      l2_fwd_in_data_req_id : in cache_id_t;
      l2_fwd_in_data_word_mask : in word_mask_t;
      l2_fwd_in_data_line : in line_t;
      l2_rsp_in_valid : in std_ulogic;
      l2_rsp_in_data_coh_msg : in coh_msg_t;
      l2_rsp_in_data_addr : in line_addr_t;
      l2_rsp_in_data_line : in line_t;
      l2_rsp_in_data_word_mask : in word_mask_t;
      l2_rsp_in_data_invack_cnt : in invack_cnt_t;
      l2_flush_valid : in std_ulogic;
      l2_flush_data : in std_ulogic;
      l2_rd_rsp_ready : in std_ulogic;
      l2_inval_ready : in std_ulogic;
      l2_req_out_ready : in std_ulogic;
      l2_rsp_out_ready : in std_ulogic;
      l2_fwd_out_ready : in std_ulogic;
      l2_bresp_ready : in std_ulogic;
      l2_stats_ready : in std_ulogic;
      flush_done : out std_ulogic;
      acc_flush_done : out std_ulogic;
      l2_cpu_req_ready : out std_ulogic;
      l2_fwd_in_ready : out std_ulogic;
      l2_rsp_in_ready : out std_ulogic;
      l2_flush_ready : out std_ulogic;
      l2_rd_rsp_valid : out std_ulogic;
      l2_rd_rsp_data_line : out line_t;
      l2_inval_valid : out std_ulogic;
      l2_inval_data_addr : out line_addr_t;
      l2_inval_data_hprot : out hprot_t;
      l2_bresp_valid : out std_ulogic;
      l2_bresp_data : out bresp_t;
      l2_req_out_valid : out std_ulogic;
      l2_req_out_data_coh_msg : out coh_msg_t;
      l2_req_out_data_hprot : out hprot_t;
      l2_req_out_data_addr : out line_addr_t;
      l2_req_out_data_line : out line_t;
      l2_req_out_data_word_mask : out word_mask_t;
      l2_rsp_out_valid : out std_ulogic;
      l2_rsp_out_data_coh_msg : out coh_msg_t;
      l2_rsp_out_data_req_id : out cache_id_t;
      l2_rsp_out_data_to_req : out std_logic_vector(1 downto 0);
      l2_rsp_out_data_addr : out line_addr_t;
      l2_rsp_out_data_line : out line_t;
      l2_rsp_out_data_word_mask : out word_mask_t;
      l2_fwd_out_valid : out std_ulogic;
      l2_fwd_out_data_coh_msg : out coh_msg_t;
      l2_fwd_out_data_req_id : out cache_id_t;
      l2_fwd_out_data_to_req : out std_logic_vector(1 downto 0);
      l2_fwd_out_data_addr : out line_addr_t;
      l2_fwd_out_data_line : out line_t;
      l2_fwd_out_data_word_mask : out word_mask_t;
      l2_stats_valid : out std_ulogic;
      l2_stats_data : out std_ulogic;
      l2_fence_ready : out std_logic;
      l2_fence_valid : in std_logic;
      l2_fence_data : in std_logic_vector(1 downto 0)
      );
  end component;


  component llc
    generic (
      use_rtl : integer;
      sets : integer;
      ways : integer
      );

    port (
      clk : in std_ulogic;
      rst : in std_ulogic;
      llc_req_in_valid : in std_ulogic;
      llc_req_in_data_coh_msg : in std_logic_vector(2 downto 0);
      llc_req_in_data_hprot : in hprot_t;
      llc_req_in_data_addr : in line_addr_t;
      llc_req_in_data_word_offset : in word_offset_t;
      llc_req_in_data_valid_words : in word_offset_t;
      llc_req_in_data_line : in line_t;
      llc_req_in_data_req_id : in cache_id_t;
      llc_dma_req_in_valid : in std_ulogic;
      llc_dma_req_in_data_coh_msg : in std_logic_vector(2 downto 0);
      llc_dma_req_in_data_hprot : in hprot_t;
      llc_dma_req_in_data_addr : in line_addr_t;
      llc_dma_req_in_data_word_offset : in word_offset_t;
      llc_dma_req_in_data_valid_words : in word_offset_t;
      llc_dma_req_in_data_line : in line_t;
      llc_dma_req_in_data_req_id : in llc_coh_dev_id_t;
      llc_rsp_in_valid : in std_ulogic;
      llc_rsp_in_data_coh_msg : in std_logic_vector(1 downto 0);
      llc_rsp_in_data_addr : in line_addr_t;
      llc_rsp_in_data_line : in line_t;
      llc_rsp_in_data_req_id : in cache_id_t;
      llc_mem_rsp_valid : in std_ulogic;
      llc_mem_rsp_data_line : in line_t;
      llc_rst_tb_valid : in std_ulogic;
      llc_rst_tb_data : in std_ulogic;
      llc_rsp_out_ready : in std_ulogic;
      llc_dma_rsp_out_ready : in std_ulogic;
      llc_fwd_out_ready : in std_ulogic;
      llc_mem_req_ready : in std_ulogic;
      llc_rst_tb_done_ready : in std_ulogic;
      llc_stats_ready : in std_ulogic;
      llc_req_in_ready : out std_ulogic;
      llc_dma_req_in_ready : out std_ulogic;
      llc_rsp_in_ready : out std_ulogic;
      llc_mem_rsp_ready : out std_ulogic;
      llc_rst_tb_ready : out std_ulogic;
      llc_rsp_out_valid : out std_ulogic;
      llc_rsp_out_data_coh_msg : out std_logic_vector(1 downto 0);
      llc_rsp_out_data_addr : out line_addr_t;
      llc_rsp_out_data_line : out line_t;
      llc_rsp_out_data_invack_cnt : out invack_cnt_t;
      llc_rsp_out_data_req_id : out cache_id_t;
      llc_rsp_out_data_dest_id : out cache_id_t;
      llc_rsp_out_data_word_offset : out word_offset_t;
      llc_dma_rsp_out_valid : out std_ulogic;
      llc_dma_rsp_out_data_coh_msg : out std_logic_vector(1 downto 0);
      llc_dma_rsp_out_data_addr : out line_addr_t;
      llc_dma_rsp_out_data_line : out line_t;
      llc_dma_rsp_out_data_invack_cnt : out invack_cnt_t;
      llc_dma_rsp_out_data_req_id : out llc_coh_dev_id_t;
      llc_dma_rsp_out_data_dest_id : out cache_id_t;
      llc_dma_rsp_out_data_word_offset : out word_offset_t;
      llc_fwd_out_valid : out std_ulogic;
      llc_fwd_out_data_coh_msg : out std_logic_vector(2 downto 0);
      llc_fwd_out_data_addr : out line_addr_t;
      llc_fwd_out_data_req_id : out cache_id_t;
      llc_fwd_out_data_dest_id : out cache_id_t;
      llc_mem_req_valid : out std_ulogic;
      llc_mem_req_data_hwrite : out std_ulogic;
      llc_mem_req_data_hsize : out hsize_t;
      llc_mem_req_data_hprot : out hprot_t;
      llc_mem_req_data_addr : out line_addr_t;
      llc_mem_req_data_line : out line_t;
      llc_stats_valid : out std_ulogic;
      llc_stats_data : out std_ulogic;
      llc_rst_tb_done_valid : out std_ulogic;
      llc_rst_tb_done_data : out std_ulogic
      );
  end component;


  component llc_spandex
    generic (
      use_rtl : integer;
      sets : integer;
      ways : integer
      );

    port (
      clk : in std_ulogic;
      rst : in std_ulogic;
      llc_req_in_valid : in std_ulogic;
      llc_req_in_data_coh_msg : in mix_msg_t;
      llc_req_in_data_hprot : in hprot_t;
      llc_req_in_data_addr : in line_addr_t;
      llc_req_in_data_word_offset : in word_offset_t;
      llc_req_in_data_valid_words : in word_offset_t;
      llc_req_in_data_line : in line_t;
      llc_req_in_data_word_mask : in word_mask_t;
      llc_req_in_data_req_id : in cache_id_t;
      llc_dma_req_in_valid : in std_ulogic;
      llc_dma_req_in_data_coh_msg : in mix_msg_t;
      llc_dma_req_in_data_hprot : in hprot_t;
      llc_dma_req_in_data_addr : in line_addr_t;
      llc_dma_req_in_data_word_offset : in word_offset_t;
      llc_dma_req_in_data_valid_words : in word_offset_t;
      llc_dma_req_in_data_line : in line_t;
      llc_dma_req_in_data_req_id : in llc_coh_dev_id_t;
      llc_dma_req_in_data_word_mask : in word_mask_t;
      llc_rsp_in_valid : in std_ulogic;
      llc_rsp_in_data_coh_msg : in coh_msg_t;
      llc_rsp_in_data_addr : in line_addr_t;
      llc_rsp_in_data_line : in line_t;
      llc_rsp_in_data_word_mask : in word_mask_t;
      llc_rsp_in_data_req_id : in cache_id_t;
      llc_mem_rsp_valid : in std_ulogic;
      llc_mem_rsp_data_line : in line_t;
      llc_rst_tb_valid : in std_ulogic;
      llc_rst_tb_data : in std_ulogic;
      llc_rsp_out_ready : in std_ulogic;
      llc_dma_rsp_out_ready : in std_ulogic;
      llc_fwd_out_ready : in std_ulogic;
      llc_mem_req_ready : in std_ulogic;
      llc_rst_tb_done_ready : in std_ulogic;
      llc_stats_ready : in std_ulogic;
      llc_req_in_ready : out std_ulogic;
      llc_dma_req_in_ready : out std_ulogic;
      llc_rsp_in_ready : out std_ulogic;
      llc_mem_rsp_ready : out std_ulogic;
      llc_rst_tb_ready : out std_ulogic;
      llc_rsp_out_valid : out std_ulogic;
      llc_rsp_out_data_coh_msg : out coh_msg_t;
      llc_rsp_out_data_addr : out line_addr_t;
      llc_rsp_out_data_line : out line_t;
      llc_rsp_out_data_invack_cnt : out invack_cnt_t;
      llc_rsp_out_data_req_id : out cache_id_t;
      llc_rsp_out_data_dest_id : out cache_id_t;
      llc_rsp_out_data_word_mask : out word_mask_t;
      llc_rsp_out_data_word_offset : out word_offset_t;
      llc_dma_rsp_out_valid : out std_ulogic;
      llc_dma_rsp_out_data_coh_msg : out coh_msg_t;
      llc_dma_rsp_out_data_addr : out line_addr_t;
      llc_dma_rsp_out_data_line : out line_t;
      llc_dma_rsp_out_data_invack_cnt : out invack_cnt_t;
      llc_dma_rsp_out_data_req_id : out llc_coh_dev_id_t;
      llc_dma_rsp_out_data_dest_id : out cache_id_t;
      llc_dma_rsp_out_data_word_offset : out word_offset_t;
      llc_dma_rsp_out_data_word_mask : out word_mask_t;
      llc_fwd_out_valid : out std_ulogic;
      llc_fwd_out_data_coh_msg : out mix_msg_t;
      llc_fwd_out_data_addr : out line_addr_t;
      llc_fwd_out_data_req_id : out cache_id_t;
      llc_fwd_out_data_word_mask : out word_mask_t;
      llc_fwd_out_data_line : out line_t;
      llc_fwd_out_data_dest_id : out cache_id_t;
      llc_mem_req_valid : out std_ulogic;
      llc_mem_req_data_hwrite : out std_ulogic;
      llc_mem_req_data_hsize : out hsize_t;
      llc_mem_req_data_hprot : out hprot_t;
      llc_mem_req_data_addr : out line_addr_t;
      llc_mem_req_data_line : out line_t;
      llc_stats_valid : out std_ulogic;
      llc_stats_data : out std_ulogic;
      llc_rst_tb_done_valid : out std_ulogic;
      llc_rst_tb_done_data : out std_ulogic
      );
  end component;



end;
