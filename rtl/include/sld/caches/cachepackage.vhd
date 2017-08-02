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
use ieee.numeric_std.all;

use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.nocpackage.all;
use work.socmap_types.all;

package cachepackage is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

  -- NoC-L2cache planes encoding
  constant MSG_REQ_PLANE : std_logic_vector(1 downto 0) := "00";
  constant MSG_FWD_PLANE : std_logic_vector(1 downto 0) := "01";
  constant MSG_RSP_PLANE : std_logic_vector(1 downto 0) := "10";
  constant MSG_DMA_PLANE : std_logic_vector(1 downto 0) := "11";

  -- Cache size (256 sets, 16bytes/line, 32KB L2 cache)
  constant WORDS_PER_LINE     : integer := 4;
  constant BYTES_PER_WORD     : integer := 4;
  constant BITS_PER_WORD      : integer := (BYTES_PER_WORD * 8);
  constant BITS_PER_HWORD     : integer := BITS_PER_WORD/2;
  constant BITS_PER_LINE      : integer := (BITS_PER_WORD * WORDS_PER_LINE);
  constant BYTES_PER_WORD_LG2 : integer := 2;
  constant WORDS_PER_LINE_LG2 : integer := 2;
  constant WORD_BITS          : integer := 2;
  constant ADDR_BITS          : integer := 32;
  constant OFFSET_BITS        : integer := WORDS_PER_LINE_LG2 + BYTES_PER_WORD_LG2;
  constant L2_SET_BITS        : integer := 8;
  constant L2_WAY_BITS        : integer := 3;
  constant TAG_BITS           : integer := ADDR_BITS - OFFSET_BITS - L2_SET_BITS;
  constant L2_CACHE_LINES     : integer := (2**L2_SET_BITS) * (2**L2_WAY_BITS);
  constant SET_BITS           : integer := 8;

  -- Cache data types width
  constant CPU_MSG_TYPE_WIDTH : integer := 2;
  constant COH_MSG_TYPE_WIDTH : integer := 2;
  constant HSIZE_WIDTH        : integer := 3;
  constant HPROT_WIDTH        : integer := 4;
  constant INVACK_CNT_WIDTH   : integer := 3;


  constant CPU_READ       : std_logic_vector(1 downto 0) := "00";
  constant CPU_READ_ATOM  : std_logic_vector(1 downto 0) := "01";
  constant CPU_WRITE      : std_logic_vector(1 downto 0) := "10";
  constant CPU_WRITE_ATOM : std_logic_vector(1 downto 0) := "11";

  constant ASSERTS_WIDTH         : integer := 9;
  constant BOOKMARK_WIDTH        : integer := 18;
  constant ASSERTS_AHBS_WIDTH    : integer := 1;
  constant ASSERTS_AHBM_WIDTH    : integer := 1;
  constant ASSERTS_REQ_WIDTH     : integer := 1;
  constant ASSERTS_RSP_IN_WIDTH  : integer := 1;
  constant ASSERTS_FWD_WIDTH     : integer := 1;
  constant ASSERTS_RSP_OUT_WIDTH : integer := 1;

  -- Ongoing transaction buffers
  constant N_REQS    : integer := 4;
  constant REQS_BITS : integer := 2;

  constant LINE_RANGE_HI  : integer := (ADDR_BITS - 1);
  constant LINE_RANGE_LO  : integer := (ADDR_BITS - TAG_BITS - SET_BITS);
  constant TAG_RANGE_HI   : integer := (ADDR_BITS - 1);
  constant TAG_RANGE_LO   : integer := (ADDR_BITS - TAG_BITS);
  constant SET_RANGE_HI   : integer := (ADDR_BITS - TAG_BITS - 1);
  constant SET_RANGE_LO   : integer := (ADDR_BITS - TAG_BITS - SET_BITS);
  constant OFF_RANGE_HI   : integer := (ADDR_BITS - TAG_BITS - SET_BITS - 1);
  constant OFF_RANGE_LO   : integer := 0;
  constant W_OFF_RANGE_HI : integer := (ADDR_BITS - TAG_BITS - SET_BITS - 1);
  constant W_OFF_RANGE_LO : integer := (ADDR_BITS - TAG_BITS - SET_BITS - WORD_BITS);
  constant B_OFF_RANGE_HI : integer := (ADDR_BITS - TAG_BITS - SET_BITS - WORD_BITS - 1);
  constant B_OFF_RANGE_LO : integer := 0;

  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  subtype addr_t is std_logic_vector(ADDR_BITS - 1 downto 0);
  subtype cpu_msg_t is std_logic_vector(CPU_MSG_TYPE_WIDTH - 1 downto 0);
  subtype hsize_t is std_logic_vector(HSIZE_WIDTH - 1 downto 0);
  subtype hprot_t is std_logic_vector(HPROT_WIDTH - 1 downto 0);
  subtype word_t is std_logic_vector(BITS_PER_WORD - 1 downto 0);
  subtype line_t is std_logic_vector(BITS_PER_LINE - 1 downto 0);
  subtype coh_msg_t is std_logic_vector(COH_MSG_TYPE_WIDTH - 1 downto 0);
  subtype set_t is std_logic_vector(SET_BITS - 1 downto 0);
  subtype invack_cnt_t is std_logic_vector(INVACK_CNT_WIDTH - 1 downto 0);
  subtype asserts_t is std_logic_vector(ASSERTS_WIDTH - 1 downto 0);
  subtype asserts_ahbs_t is std_logic_vector(ASSERTS_AHBS_WIDTH - 1 downto 0);
  subtype asserts_ahbm_t is std_logic_vector(ASSERTS_AHBM_WIDTH - 1 downto 0);
  subtype asserts_req_t is std_logic_vector(ASSERTS_REQ_WIDTH - 1 downto 0);
  subtype asserts_rsp_in_t is std_logic_vector(ASSERTS_RSP_IN_WIDTH - 1 downto 0);
  subtype asserts_fwd_t is std_logic_vector(ASSERTS_FWD_WIDTH - 1 downto 0);
  subtype asserts_rsp_out_t is std_logic_vector(ASSERTS_RSP_OUT_WIDTH - 1 downto 0);
  subtype bookmark_t is std_logic_vector(BOOKMARK_WIDTH - 1 downto 0);

  -- hprot
  constant DEFAULT_HPROT : hprot_t := "0100";

  -- hsize
  constant HSIZE_B  : hsize_t := "000";
  constant HSIZE_HW : hsize_t := "001";
  constant HSIZE_W  : hsize_t := "010";
  
  -----------------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------------
  function read_from_line (hsize : hsize_t; addr : addr_t; line : line_t)
    return word_t;

  function make_header (coh_msg : coh_msg_t; mem_info : tile_mem_info_vector;
                        mem_num : integer; hprot : hprot_t; addr : addr_t;
                        local_x : local_yx; local_y : local_yx)
    return noc_flit_type;

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
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type;
      ahbmi : in  ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
      flush : in  std_ulogic;           -- flush request from CPU

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
      coherence_rsp_snd_full     : in  std_ulogic;

      debug_led : out std_ulogic
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
      l2_cpu_req_data_cpu_msg   : in cpu_msg_t;
      l2_cpu_req_data_hsize     : in hsize_t;
      l2_cpu_req_data_hprot     : in hprot_t;
      l2_cpu_req_data_addr      : in addr_t;
      l2_cpu_req_data_word      : in word_t;
      l2_fwd_in_valid           : in std_ulogic;
      l2_fwd_in_data_coh_msg    : in coh_msg_t;
      l2_fwd_in_data_addr       : in addr_t;
      l2_rsp_in_valid           : in std_ulogic;
      l2_rsp_in_data_coh_msg    : in coh_msg_t;
      l2_rsp_in_data_addr       : in addr_t;
      l2_rsp_in_data_line       : in line_t;
      l2_rsp_in_data_invack_cnt : in invack_cnt_t;
      l2_flush_valid            : in std_ulogic;
      l2_flush_data             : in std_ulogic;
      l2_rd_rsp_ready           : in std_ulogic;
      l2_inval_ready            : in std_ulogic;
      l2_req_out_ready          : in std_ulogic;
      l2_rsp_out_ready          : in std_ulogic;

      asserts                 : out asserts_t;
      bookmark                : out bookmark_t;
      l2_cpu_req_ready        : out std_ulogic;
      l2_fwd_in_ready         : out std_ulogic;
      l2_rsp_in_ready         : out std_ulogic;
      l2_flush_ready          : out std_ulogic;
      l2_rd_rsp_valid         : out std_ulogic;
      l2_rd_rsp_data_line     : out line_t;
      l2_inval_valid          : out std_ulogic;
      l2_inval_data           : out addr_t;
      l2_req_out_valid        : out std_ulogic;
      l2_req_out_data_coh_msg : out coh_msg_t;
      l2_req_out_data_hprot   : out hprot_t;
      l2_req_out_data_addr    : out addr_t;
      l2_req_out_data_line    : out line_t;
      l2_rsp_out_valid        : out std_ulogic;
      l2_rsp_out_data_coh_msg : out coh_msg_t;
      l2_rsp_out_data_hprot   : out hprot_t;
      l2_rsp_out_data_addr    : out addr_t;
      l2_rsp_out_data_line    : out line_t);
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

package body cachepackage is

  function read_from_line (hsize : hsize_t; addr : addr_t; line : line_t) return word_t is
    variable off    : integer;
    variable w_off  : integer;
    variable hw_off : integer;
    variable word   : word_t;

  begin

    if hsize = HSIZE_B then

      off := to_integer(unsigned(addr(OFF_RANGE_HI downto OFF_RANGE_LO)));
      for i in 0 to BYTES_PER_WORD - 1 loop
        word(i * 8 + 7 downto i * 8) :=
          line((off * 8) + 7 downto (off * 8));
      end loop;  -- i

    elsif hsize = HSIZE_HW then

      hw_off := to_integer(unsigned(addr(W_OFF_RANGE_HI downto W_OFF_RANGE_LO - 1)));
      word(BITS_PER_HWORD - 1 downto 0) :=
        line((hw_off * BITS_PER_HWORD) + BITS_PER_HWORD - 1 downto hw_off * BITS_PER_HWORD);
      word(BITS_PER_WORD - 1 downto BITS_PER_HWORD) :=
        line((hw_off * BITS_PER_HWORD) + BITS_PER_HWORD - 1 downto hw_off * BITS_PER_HWORD);

    elsif hsize = HSIZE_W then

      w_off := to_integer(unsigned(addr(W_OFF_RANGE_HI downto W_OFF_RANGE_LO)));
      word  := line((w_off * BITS_PER_WORD) + BITS_PER_WORD - 1 downto w_off * BITS_PER_WORD);

    end if;

    return word;

  end function read_from_line;

  function make_header (coh_msg : coh_msg_t; mem_info : tile_mem_info_vector;
                        mem_num : integer; hprot : hprot_t; addr : addr_t;
                        local_x : local_yx; local_y : local_yx)
    return noc_flit_type is

    variable header         : noc_flit_type;
    variable dest_x, dest_y : local_yx;

  begin

    -- dest_x dest_y
    dest_x := mem_info(0).x;
    dest_y := mem_info(0).y;
    if mem_num /= 1 then
      for i in 0 to mem_num - 1 loop
        if ((addr(31 downto 20) xor conv_std_logic_vector(mem_info(i).haddr, 12))
            and conv_std_logic_vector(mem_info(i).hmask, 12)) = x"000" then
          dest_x := mem_info(i).x;
          dest_y := mem_info(i).y;
        end if;
      end loop;
    end if;

    -- compose header
    header := create_header(local_y, local_x, dest_y, dest_x, '0' & coh_msg, hprot);

    return header;

  end function make_header;

end package body cachepackage;
