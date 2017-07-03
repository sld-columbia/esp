-------------------------------------------------------------------------------
-- Design Name: cachepackage
-- File: cachepackage.vhd
-- Author: Davide Giri - SLD @ Columbia University
-- Description: Package containing two components. A L2 cache and a LLC (Last
-- Level Cache).
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.nocpackage.all;
use work.socmap_types.all;

package cachepackage is

  -- NoC-L2cache planes encoding
  constant MSG_REQ_PLANE : std_logic_vector(1 downto 0) := "00";
  constant MSG_FWD_PLANE : std_logic_vector(1 downto 0) := "01";
  constant MSG_RSP_PLANE : std_logic_vector(1 downto 0) := "10";
  constant MSG_DMA_PLANE : std_logic_vector(1 downto 0) := "11";

  -- Cache size (256 sets, 16bytes/line, 32KB L2 cache)
  constant WORDS_PER_LINE     : std_logic_vector(7 downto 0) := "00000100";
  constant WORDS_PER_LINE_INT : integer                      := 4;
  constant BYTES_PER_WORD_LG2 : integer                      := 2;
  constant WORDS_PER_LINE_LG2 : integer                      := 2;
  constant ADDR_BITS          : integer                      := 32;
  constant OFFSET_BITS        : integer                      := WORDS_PER_LINE_LG2 + BYTES_PER_WORD_LG2;
  constant L2_SET_BITS        : integer                      := 8;
  constant L2_WAY_BITS        : integer                      := 3;
  constant TAG_BITS           : integer                      := ADDR_BITS - OFFSET_BITS - L2_SET_BITS;
  constant L2_CACHE_LINES     : integer                      := (2**L2_SET_BITS) * (2**L2_WAY_BITS);

  -- L2 cache encoding of coherency message types
  constant REQ_GETS : std_logic_vector(1 downto 0) := "00";
  constant REQ_GETM : std_logic_vector(1 downto 0) := "01";
  constant REQ_PUTS : std_logic_vector(1 downto 0) := "10";
  constant REQ_PUTM : std_logic_vector(1 downto 0) := "11";

  constant FWD_GETS : std_logic_vector(1 downto 0) := "00";
  constant FWD_GETM : std_logic_vector(1 downto 0) := "01";
  constant FWD_INV  : std_logic_vector(1 downto 0) := "10";

  constant RSP_DATA   : std_logic_vector(1 downto 0) := "00";
  constant RSP_EDATA  : std_logic_vector(1 downto 0) := "01";
  constant RSP_INVACK : std_logic_vector(1 downto 0) := "10";
  constant RSP_PUTACK : std_logic_vector(1 downto 0) := "11";

  constant L2_MSG_DMA_TO_DEV     : std_logic_vector(5 downto 0) := "011" & "001";
  constant L2_MSG_DMA_FROM_DEV_R : std_logic_vector(5 downto 0) := "011" & "010";
  constant L2_MSG_DMA_FROM_DEV_W : std_logic_vector(5 downto 0) := "011" & "011";

  constant READ       : std_logic_vector(1 downto 0) := "00";
  constant READ_ATOM  : std_logic_vector(1 downto 0) := "01";
  constant WRITE      : std_logic_vector(1 downto 0) := "10";
  constant WRITE_ATOM : std_logic_vector(1 downto 0) := "11";

  -----------------------------------------------------------------------------
  -- l2_wrapper component
  -----------------------------------------------------------------------------

  component l2_wrapper is
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
      destination : integer := 0;       -- 0: mem, 1: DSU
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
      flush_req : in  std_ulogic;       -- flush request from CPU

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
  end component;

  -----------------------------------------------------------------------------
  -- l2_cache component
  -----------------------------------------------------------------------------
  component l2_basic
    port (
      clk : in std_ulogic;
      rst : in std_ulogic;

      l2_cpu_req_valid          : in std_ulogic;
      l2_cpu_req_data_cpu_msg   : in std_logic_vector(1 downto 0);
      l2_cpu_req_data_hsize     : in std_logic_vector(2 downto 0);
      l2_cpu_req_data_hprot     : in std_logic_vector(3 downto 0);
      l2_cpu_req_data_addr      : in std_logic_vector(31 downto 0);
      l2_cpu_req_data_word      : in std_logic_vector(31 downto 0);
      l2_fwd_in_valid           : in std_ulogic;
      l2_fwd_in_data_coh_msg    : in std_logic_vector(1 downto 0);
      l2_fwd_in_data_addr       : in std_logic_vector(31 downto 0);
      l2_rsp_in_valid           : in std_ulogic;
      l2_rsp_in_data_coh_msg    : in std_logic_vector(1 downto 0);
      l2_rsp_in_data_addr       : in std_logic_vector(31 downto 0);
      l2_rsp_in_data_line       : in std_logic_vector(127 downto 0);
      l2_rsp_in_data_invack_cnt : in std_logic_vector(2 downto 0);
      l2_flush_valid            : in std_ulogic;
      l2_flush_data             : in std_ulogic;
      l2_rd_rsp_ready           : in std_ulogic;
      l2_wr_rsp_ready           : in std_ulogic;
      l2_inval_ready            : in std_ulogic;
      l2_req_out_ready          : in std_ulogic;
      l2_rsp_out_ready          : in std_ulogic;

      asserts                 : out std_logic_vector(8 downto 0);
      bookmark                : out std_logic_vector(18 downto 0);
      l2_cpu_req_ready        : out std_ulogic;
      l2_fwd_in_ready         : out std_ulogic;
      l2_rsp_in_ready         : out std_ulogic;
      l2_flush_ready          : out std_ulogic;
      l2_rd_rsp_valid         : out std_ulogic;
      l2_rd_rsp_data_line     : out std_logic_vector(127 downto 0);
      l2_wr_rsp_valid         : out std_ulogic;
      l2_wr_rsp_data_set      : out std_logic_vector(7 downto 0);
      l2_inval_valid          : out std_ulogic;
      l2_inval_data           : out std_logic_vector(31 downto 0);
      l2_req_out_valid        : out std_ulogic;
      l2_req_out_data_coh_msg : out std_logic_vector(1 downto 0);
      l2_req_out_data_hprot   : out std_logic_vector(3 downto 0);
      l2_req_out_data_addr    : out std_logic_vector(31 downto 0);
      l2_req_out_data_line    : out std_logic_vector(127 downto 0);
      l2_rsp_out_valid        : out std_ulogic;
      l2_rsp_out_data_coh_msg : out std_logic_vector(1 downto 0);
      l2_rsp_out_data_hprot   : out std_logic_vector(3 downto 0);
      l2_rsp_out_data_addr    : out std_logic_vector(31 downto 0);
      l2_rsp_out_data_line    : out std_logic_vector(127 downto 0)
      );
  end component;


-- Last Level Cache (LLC) component. (aka L3 cache, in the frame of this project)
  component l3_cache_0_top_unisim_rtl
    port (
      clk : in std_ulogic;
      rst : in std_ulogic;

      -- Frontend interface inputs
      f_ctl_in_valid          : in std_ulogic;
      f_ctl_in_data           : in std_logic_vector(5 downto 0);
      f_addr_in_valid         : in std_ulogic;
      f_addr_in_data          : in std_logic_vector(31 downto 0);
      f_cache_id_in_valid     : in std_ulogic;
      f_cache_id_in_data      : in std_logic_vector(2 downto 0);
      f_data_in_valid         : in std_ulogic;
      f_data_in_data          : in std_logic_vector(31 downto 0);
      f_hprot_in_valid        : in std_ulogic;
      f_hprot_in_data         : in std_logic_vector(3 downto 0);
      f_ctl_out_ready         : in std_ulogic;
      f_inv_ack_cnt_out_ready : in std_ulogic;
      f_cache_id_out_ready    : in std_ulogic;
      f_msg_body_out_ready    : in std_ulogic;
      f_addr_out_ready        : in std_ulogic;
      f_data_out_ready        : in std_ulogic;
      f_hprot_out_ready       : in std_ulogic;

      -- Frontend interface outputs
      f_ctl_in_ready          : out std_ulogic;
      f_addr_in_ready         : out std_ulogic;
      f_cache_id_in_ready     : out std_ulogic;
      f_data_in_ready         : out std_ulogic;
      f_hprot_in_ready        : out std_ulogic;
      f_ctl_out_valid         : out std_ulogic;
      f_ctl_out_data          : out std_logic_vector(5 downto 0);
      f_inv_ack_cnt_out_valid : out std_ulogic;
      f_inv_ack_cnt_out_data  : out std_logic_vector(2 downto 0);
      f_cache_id_out_valid    : out std_ulogic;
      f_cache_id_out_data     : out std_logic_vector(2 downto 0);
      f_msg_body_out_valid    : out std_ulogic;
      f_msg_body_out_data     : out std_logic_vector(2 downto 0);
      f_addr_out_valid        : out std_ulogic;
      f_addr_out_data         : out std_logic_vector(31 downto 0);
      f_data_out_valid        : out std_ulogic;
      f_data_out_data         : out std_logic_vector(31 downto 0);
      f_hprot_out_valid       : out std_ulogic;
      f_hprot_out_data        : out std_logic_vector(3 downto 0);

      -- Backend interface inputs
      b_ctl_in_valid    : in std_ulogic;
      b_ctl_in_data     : in std_logic_vector(5 downto 0);
      b_addr_in_valid   : in std_ulogic;
      b_addr_in_data    : in std_logic_vector(31 downto 0);
      b_data_in_valid   : in std_ulogic;
      b_data_in_data    : in std_logic_vector(31 downto 0);
      b_hprot_in_valid  : in std_ulogic;
      b_hprot_in_data   : in std_logic_vector(3 downto 0);
      b_ctl_out_ready   : in std_ulogic;
      b_addr_out_ready  : in std_ulogic;
      b_data_out_ready  : in std_ulogic;
      b_hprot_out_ready : in std_ulogic;

      -- Backend interface outputs
      b_ctl_in_ready    : out std_ulogic;
      b_addr_in_ready   : out std_ulogic;
      b_data_in_ready   : out std_ulogic;
      b_hprot_in_ready  : out std_ulogic;
      b_ctl_out_valid   : out std_ulogic;
      b_ctl_out_data    : out std_logic_vector(5 downto 0);
      b_addr_out_valid  : out std_ulogic;
      b_addr_out_data   : out std_logic_vector(31 downto 0);
      b_data_out_valid  : out std_ulogic;
      b_data_out_data   : out std_logic_vector(31 downto 0);
      b_hprot_out_valid : out std_ulogic;
      b_hprot_out_data  : out std_logic_vector(3 downto 0)
      );
  end component;

  component l3_wrapper is
    generic (
      tech        : integer                      := virtex7;
      ncpu        : integer                      := 4;
      noc_xlen    : integer                      := 2;
      hindex      : integer range 0 to NAHBSLV-1 := 4;
      local_y     : local_yx;
      local_x     : local_yx;
      cacheline   : integer;
      l2_cache_en : integer                      := 0;
      cpu_tile_id : cpu_info_array;
      tile_cpu_id : tile_cpu_id_array;
      destination : integer                      := 0);  -- 0: mem
                                                         -- 1: DSU
    port (
      rst   : in  std_ulogic;
      clk   : in  std_ulogic;
      ahbmi : in  ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;

      -- NoC1->tile
      coherence_req_rdreq        : out std_ulogic;
      coherence_req_data_out     : in  noc_flit_type;
      coherence_req_empty        : in  std_ulogic;
      -- tile->NoC2
      coherence_fwd_wrreq        : out std_ulogic;
      coherence_fwd_data_in      : out noc_flit_type;
      coherence_fwd_full         : in  std_ulogic;
      -- tile->NoC3
      coherence_rsp_snd_wrreq    : out std_ulogic;
      coherence_rsp_snd_data_in  : out noc_flit_type;
      coherence_rsp_snd_full     : in  std_ulogic;
      -- NoC3->tile
      coherence_rsp_rcv_rdreq    : out std_ulogic;
      coherence_rsp_rcv_data_out : in  noc_flit_type;
      coherence_rsp_rcv_empty    : in  std_ulogic);
  -- -- NoC4->tile
  -- dma_rcv_rdreq                       : out std_ulogic;
  -- dma_rcv_data_out                    : in  noc_flit_type;
  -- dma_rcv_empty                       : in  std_ulogic;
  -- -- tile->NoC4
  -- dma_snd_wrreq                       : out std_ulogic;
  -- dma_snd_data_in                     : out noc_flit_type;
  -- dma_snd_full                        : in  std_ulogic;
  -- dma_snd_atleast_4slots              : in  std_ulogic;
  -- dma_snd_exactly_3slots              : in  std_ulogic);
  end component;

  component fifo_custom is
    generic(
      depth : integer := 5;
      width : integer := 18);
    port(
      clk : in std_logic;
      rst : in std_logic;

      rdreq   : in std_logic;
      wrreq   : in std_logic;
      data_in : in std_logic_vector(width-1 downto 0);

      --request registers
      empty        : out std_logic;
      full         : out std_logic;
      almost_empty : out std_logic;
      data_out     : out std_logic_vector(width-1 downto 0));

  end component;

end cachepackage;
