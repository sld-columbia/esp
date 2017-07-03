-------------------------------------------------------------------------------
-- Entity: l2_wrapper
-- File: l2_wrapper.vhd
-- Author: Davide Giri - SLD @ Columbia University
-- Description: RTL wrapper for a private L2 cache to be included on a CPU tile
-- on a Embedded Scalable Platform.
-- Frontend: Amba 2.0 AHB to L2 cache wrapper.
-- Backend: L2 cache to Network on Chip wrapper.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TODO:
-- + Substitute numbers with constants wherever possible
-- + Modify the way the cache is loading/storing less-than-word-size
-- loads/writes.
-- + Improve loads management. Pre-ask to the cache words until the end of the
-- line and store them until the asks for them. Discard them if the CPU asks
-- for different data.
-- + Investigate why EDATA is not received correctly by the cache.
-- + Check the correctness of non cacheable data flow through the wrapper and
-- cache. Maybe modify on backend the way data is sent to the NoC changing the
-- fixed size of 4 words to a dynamic quantity.
-- + Send RSP first to directory and then to the requestors
-------------------------------------------------------------------------------

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

use work.socmap_types.all;
use work.nocpackage.all;
use work.cachepackage.all;              -- contains l2 cache component


entity l2_wrapper is
  generic (
    tech        : integer := virtex7;
    ncpu        : integer := 4;
    nslaves     : integer := 1;
    noc_xlen    : integer := 3;
    hindex_slv  : hindex_vector(0 to NAHBSLV-1);
    hindex_mst  : integer := 0;
    local_y     : local_yx;
    local_x     : local_yx;
    mem_num     : integer := 1;
    mem_info    : tile_mem_info_vector;
    destination : integer := 0;         -- 0: mem, 1: DSU
    l1_cache_en : integer := 0;
    cpu_tile_id : cpu_info_array);

  port (
    rst : in std_ulogic;
    clk : in std_ulogic;

    -- frontend (cache - AMBA)
    ahbsi     : in  ahb_slv_in_type;
    ahbso     : out ahb_slv_out_type;
    ahbmi     : in  ahb_mst_in_type;
    ahbmo     : out ahb_mst_out_type;
    flush_req : in  std_ulogic;         -- flush request from CPU

    -- backend (cache - NoC)
    -- tile->NoC1
    coherence_req_wrreq        : out std_ulogic;
    coherence_req_data_in      : out noc_flit_type;
    coherence_req_full         : in  std_ulogic;
    -- NoC2->tile
    coherence_fwd_rdreq        : out std_ulogic;
    coherence_fwd_data_out     : in  noc_flit_type;
    coherence_fwd_empty        : in  std_ulogic;
    -- Noc3->tile
    coherence_rsp_rcv_rdreq    : out std_ulogic;
    coherence_rsp_rcv_data_out : in  noc_flit_type;
    coherence_rsp_rcv_empty    : in  std_ulogic;
    -- tile->Noc3
    coherence_rsp_snd_wrreq    : out std_ulogic;
    coherence_rsp_snd_data_in  : out noc_flit_type;
    coherence_rsp_snd_full     : in  std_ulogic
    );

end l2_wrapper;


architecture rtl of l2_wrapper is

  -- AHB to cache
  signal cpu_req_ready          : std_ulogic;
  signal cpu_req_valid          : std_ulogic;
  signal cpu_req_data_cpu_msg   : std_logic_vector(1 downto 0);
  signal cpu_req_data_hsize     : std_logic_vector(2 downto 0);
  signal cpu_req_data_hprot     : std_logic_vector(3 downto 0);
  signal cpu_req_data_addr      : std_logic_vector(31 downto 0);
  signal cpu_req_data_word      : std_logic_vector(31 downto 0);
  signal flush_ready            : std_ulogic;
  signal flush_valid            : std_ulogic;
  signal flush_data             : std_ulogic;
  -- cache to AHB
  signal rd_rsp_ready           : std_ulogic;
  signal rd_rsp_valid           : std_ulogic;
  signal rd_rsp_data_line       : std_logic_vector(127 downto 0);
  signal wr_rsp_ready           : std_ulogic;
  signal wr_rsp_valid           : std_ulogic;
  signal wr_rsp_data_set        : std_logic_vector(7 downto 0);
  signal inval_ready            : std_ulogic;
  signal inval_valid            : std_ulogic;
  signal inval_data             : std_logic_vector(31 downto 0);
  -- cache to NoC
  signal req_out_ready          : std_ulogic;
  signal req_out_valid          : std_ulogic;
  signal req_out_data_coh_msg   : std_logic_vector(1 downto 0);
  signal req_out_data_hprot     : std_logic_vector(3 downto 0);
  signal req_out_data_addr      : std_logic_vector(31 downto 0);
  signal req_out_data_line      : std_logic_vector(127 downto 0);
  signal rsp_out_ready          : std_ulogic;
  signal rsp_out_valid          : std_ulogic;
  signal rsp_out_data_coh_msg   : std_logic_vector(1 downto 0);
  signal rsp_out_data_hprot     : std_logic_vector(3 downto 0);
  signal rsp_out_data_addr      : std_logic_vector(31 downto 0);
  signal rsp_out_data_line      : std_logic_vector(127 downto 0);
  -- NoC to cache
  signal fwd_in_ready           : std_ulogic;
  signal fwd_in_valid           : std_ulogic;
  signal fwd_in_data_coh_msg    : std_logic_vector(1 downto 0);
  signal fwd_in_data_addr       : std_logic_vector(31 downto 0);
  signal rsp_in_valid           : std_ulogic;
  signal rsp_in_ready           : std_ulogic;
  signal rsp_in_data_coh_msg    : std_logic_vector(1 downto 0);
  signal rsp_in_data_addr       : std_logic_vector(31 downto 0);
  signal rsp_in_data_line       : std_logic_vector(127 downto 0);
  signal rsp_in_data_invack_cnt : std_logic_vector(2 downto 0);
  -- debug
  signal asserts                   : std_logic_vector(8 downto 0);
  signal bookmark                  : std_logic_vector(18 downto 0);

begin  -- architecture rtl of l2_wrapper

-----------------------------------------------------------------------------
-- instantiations
-----------------------------------------------------------------------------

  -- instantiation of l2 cache on cpu tile
  l2_cache_0 : l2_basic
    port map (
      clk => clk,
      rst => rst,

      -- AHB to cache
      l2_cpu_req_ready          => cpu_req_ready,
      l2_cpu_req_valid          => cpu_req_valid,
      l2_cpu_req_data_cpu_msg   => cpu_req_data_cpu_msg,
      l2_cpu_req_data_hsize     => cpu_req_data_hsize,
      l2_cpu_req_data_hprot     => cpu_req_data_hprot,
      l2_cpu_req_data_addr      => cpu_req_data_addr,
      l2_cpu_req_data_word      => cpu_req_data_word,
      l2_flush_ready            => flush_ready,
      l2_flush_valid            => flush_valid,
      l2_flush_data             => flush_data,
      -- cache to AHB
      l2_rd_rsp_ready           => rd_rsp_ready,
      l2_rd_rsp_valid           => rd_rsp_valid,
      l2_rd_rsp_data_line       => rd_rsp_data_line,
      l2_wr_rsp_ready           => wr_rsp_ready,
      l2_wr_rsp_valid           => wr_rsp_valid,
      l2_wr_rsp_data_set        => wr_rsp_data_set,
      l2_inval_ready            => inval_ready,
      l2_inval_valid            => inval_valid,
      l2_inval_data             => inval_data,
      -- cache to NoC
      l2_req_out_ready          => req_out_ready,
      l2_req_out_valid          => req_out_valid,
      l2_req_out_data_coh_msg   => req_out_data_coh_msg,
      l2_req_out_data_hprot     => req_out_data_hprot,
      l2_req_out_data_addr      => req_out_data_addr,
      l2_req_out_data_line      => req_out_data_line,
      l2_rsp_out_ready          => rsp_out_ready,
      l2_rsp_out_valid          => rsp_out_valid,
      l2_rsp_out_data_coh_msg   => rsp_out_data_coh_msg,
      l2_rsp_out_data_hprot     => rsp_out_data_hprot,
      l2_rsp_out_data_addr      => rsp_out_data_addr,
      l2_rsp_out_data_line      => rsp_out_data_line,
      -- NoC to cache
      l2_fwd_in_ready           => fwd_in_ready,
      l2_fwd_in_valid           => fwd_in_valid,
      l2_fwd_in_data_coh_msg    => fwd_in_data_coh_msg,
      l2_fwd_in_data_addr       => fwd_in_data_addr,
      l2_rsp_in_ready           => rsp_in_ready,
      l2_rsp_in_valid           => rsp_in_valid,
      l2_rsp_in_data_coh_msg    => rsp_in_data_coh_msg,
      l2_rsp_in_data_addr       => rsp_in_data_addr,
      l2_rsp_in_data_line       => rsp_in_data_line,
      l2_rsp_in_data_invack_cnt => rsp_in_data_invack_cnt,
      -- debug
      asserts                   => asserts,
      bookmark                  => bookmark
      );

end rtl;
