------------------------------------------------------------------------------
-- Design Name: cachepackage
-- File: cachepackage.vhd
-- Author: Davide Giri - SLD @ Columbia University
-- Description: Package containing two components. A L2 cache and a LLC (Last
-- Level Cache).
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.nocpackage.all;

package cachepackage is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

  -- Warning: setting max number of fully-coherent devices to 8 and max number
  -- of LLC-coherent devices to 8. This is due to VHDL limitation, but the
  -- following constant can be changed arbitrarily.
  constant NL2_MAX_LOG2 : integer := 3;
  type cache_attribute_array is array (0 to 2**NL2_MAX_LOG2 - 1) of integer;

  -- NoC-L2cache planes encoding
  constant MSG_REQ_PLANE : std_logic_vector(1 downto 0) := "00";
  constant MSG_FWD_PLANE : std_logic_vector(1 downto 0) := "01";
  constant MSG_RSP_PLANE : std_logic_vector(1 downto 0) := "10";
  constant MSG_DMA_PLANE : std_logic_vector(1 downto 0) := "11";

  -- Accelerator coherence type encoding
  constant ACC_COH_NONE : integer := 0;
  constant ACC_COH_LLC : integer := 1;
  constant ACC_COH_FULL : integer := 2;

  -- TODO: The following are predefined by processor architecture and should
  --       not be set here
  constant WORD_OFFSET_BITS   : integer := 2;
  constant BYTE_OFFSET_BITS   : integer := 2;
  constant ADDR_BITS          : integer := 32;
  --

  constant OFFSET_BITS        : integer := WORD_OFFSET_BITS + BYTE_OFFSET_BITS;
  constant WORDS_PER_LINE     : integer := 2**WORD_OFFSET_BITS;
  constant BYTES_PER_WORD     : integer := 2**BYTE_OFFSET_BITS;
  constant BYTES_PER_LINE     : integer := WORDS_PER_LINE * BYTES_PER_WORD;
  constant BITS_PER_WORD      : integer := (BYTES_PER_WORD * 8);
  constant BITS_PER_HWORD     : integer := BITS_PER_WORD/2;
  constant BITS_PER_LINE      : integer := (BITS_PER_WORD * WORDS_PER_LINE);

  -- Cache data types width
  constant CPU_MSG_TYPE_WIDTH : integer := 2;
  constant COH_MSG_TYPE_WIDTH : integer := 2;
  constant MIX_MSG_TYPE_WIDTH : integer := 3;

  constant HSIZE_WIDTH           : integer := 3;
  constant HPROT_WIDTH           : integer := 1;
  constant INVACK_CNT_WIDTH      : integer := 2;
  constant INVACK_CNT_CALC_WIDTH : integer := 3;

  constant CPU_READ       : std_logic_vector(1 downto 0) := "00";
  constant CPU_READ_ATOM  : std_logic_vector(1 downto 0) := "01";
  constant CPU_WRITE      : std_logic_vector(1 downto 0) := "10";
  constant CPU_WRITE_ATOM : std_logic_vector(1 downto 0) := "11";

  --constant ASSERTS_WIDTH          : integer := 19;
  --constant BOOKMARK_WIDTH         : integer := 32;
  --constant LLC_ASSERTS_WIDTH      : integer := 6;
  --constant LLC_BOOKMARK_WIDTH     : integer := 10;
  constant ASSERTS_AHBS_WIDTH     : integer := 13;
  constant ASSERTS_AHBM_WIDTH     : integer := 1;
  constant ASSERTS_REQ_WIDTH      : integer := 1;
  constant ASSERTS_RSP_IN_WIDTH   : integer := 1;
  constant ASSERTS_FWD_WIDTH      : integer := 1;
  constant ASSERTS_RSP_OUT_WIDTH  : integer := 1;
  constant ASSERTS_LLC_AHBM_WIDTH : integer := 2;

  -- Ongoing transaction buffers
  constant N_REQS : integer := 4;

  constant LINE_RANGE_HI    : integer := (ADDR_BITS - 1);
  constant LINE_RANGE_LO    : integer := (OFFSET_BITS);
  constant OFF_RANGE_HI     : integer := (OFFSET_BITS - 1);
  constant OFF_RANGE_LO     : integer := 0;
  constant W_OFF_RANGE_HI   : integer := (OFFSET_BITS - 1);
  constant W_OFF_RANGE_LO   : integer := (OFFSET_BITS - WORD_OFFSET_BITS);
  constant B_OFF_RANGE_HI   : integer := (BYTE_OFFSET_BITS - 1);
  constant B_OFF_RANGE_LO   : integer := 0;

-- Asserts
  constant AS_AHBS_HSIZE         : integer := 0;
  constant AS_AHBS_CACHEABLE     : integer := 1;
  constant AS_AHBS_OPCODE        : integer := 2;
  constant AS_AHBS_IDLE_HTRANS   : integer := 3;
  constant AS_AHBS_FLUSH_HREADY  : integer := 4;
  constant AS_AHBS_FLUSH_DUE     : integer := 5;
  constant AS_AHBS_MEM_HREADY    : integer := 6;
  constant AS_AHBS_MEM_DUE       : integer := 7;
  constant AS_AHBS_LDREQ_HREADY  : integer := 8;
  constant AS_AHBS_LDRSP_HREADY  : integer := 9;
  constant AS_AHBS_STRSP_HREADY  : integer := 10;
  constant AS_AHBS_INV_FIFO      : integer := 11;
  constant AS_AHBS_NON_CACHEABLE : integer := 12;
  -- constant AS_AHBM_ : integer := 0;

  -- constant AS_REQ_ : integer := 0;

  -- constant AS_RSPIN_ : integer := 0;

  --
  constant AS_AHBM_LOAD_NOT_GRANTED  : integer := 0;
  constant AS_AHBM_STORE_NOT_GRANTED : integer := 1;

  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  subtype addr_t is std_logic_vector(ADDR_BITS - 1 downto 0);
  subtype line_addr_t is std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
  subtype cpu_msg_t is std_logic_vector(CPU_MSG_TYPE_WIDTH - 1 downto 0);
  subtype hsize_t is std_logic_vector(HSIZE_WIDTH - 1 downto 0);
  subtype hprot_t is std_logic_vector(HPROT_WIDTH - 1 downto 0);
  subtype word_t is std_logic_vector(BITS_PER_WORD - 1 downto 0);
  subtype line_t is std_logic_vector(BITS_PER_LINE - 1 downto 0);
  subtype coh_msg_t is std_logic_vector(COH_MSG_TYPE_WIDTH - 1 downto 0);
  subtype mix_msg_t is std_logic_vector(MIX_MSG_TYPE_WIDTH - 1 downto 0);
  -- subtype l2_set_t is std_logic_vector(SET_BITS - 1 downto 0);
  -- subtype llc_set_t is std_logic_vector(SET_BITS - 1 downto 0);
  subtype invack_cnt_t is std_logic_vector(INVACK_CNT_WIDTH - 1 downto 0);
  subtype invack_cnt_calc_t is std_logic_vector(INVACK_CNT_CALC_WIDTH - 1 downto 0);
  --subtype asserts_t is std_logic_vector(ASSERTS_WIDTH - 1 downto 0);
  --subtype llc_asserts_t is std_logic_vector(LLC_ASSERTS_WIDTH - 1 downto 0);
  subtype asserts_ahbs_t is std_logic_vector(ASSERTS_AHBS_WIDTH - 1 downto 0);
  subtype asserts_ahbm_t is std_logic_vector(ASSERTS_AHBM_WIDTH - 1 downto 0);
  subtype asserts_req_t is std_logic_vector(ASSERTS_REQ_WIDTH - 1 downto 0);
  subtype asserts_rsp_in_t is std_logic_vector(ASSERTS_RSP_IN_WIDTH - 1 downto 0);
  subtype asserts_fwd_t is std_logic_vector(ASSERTS_FWD_WIDTH - 1 downto 0);
  subtype asserts_rsp_out_t is std_logic_vector(ASSERTS_RSP_OUT_WIDTH - 1 downto 0);
  subtype asserts_llc_ahbm_t is std_logic_vector(ASSERTS_LLC_AHBM_WIDTH - 1 downto 0);
  --subtype bookmark_t is std_logic_vector(BOOKMARK_WIDTH - 1 downto 0);
  --subtype llc_bookmark_t is std_logic_vector(LLC_BOOKMARK_WIDTH - 1 downto 0);
  --subtype custom_dbg_t is std_logic_vector(31 downto 0);
  subtype cache_id_t is std_logic_vector(NL2_MAX_LOG2 - 1 downto 0);
  -- hprot
  constant DEFAULT_HPROT : hprot_t := "0";

  -- hsize
  constant HSIZE_B  : hsize_t := "000";
  constant HSIZE_HW : hsize_t := "001";
  constant HSIZE_W  : hsize_t := "010";

  -----------------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------------
  function read_from_line (addr : addr_t; line : line_t)
    return word_t;

  function make_header (coh_msg     : coh_msg_t; mem_info : tile_mem_info_vector;
                        mem_num     : integer; hprot : hprot_t; addr : line_addr_t;
                        local_x     : local_yx; local_y : local_yx;
                        to_req      : std_ulogic; req_id : cache_id_t;
                        cache_tile_id : cache_attribute_array; noc_xlen : integer)
    return noc_flit_type;

  function get_owner_bits (ncpu_bits : integer)
    return integer;

  -----------------------------------------------------------------------------
  -- l2_wrapper component
  -----------------------------------------------------------------------------

  component l2_wrapper is
    generic (
      tech        : integer := virtex7;
      sets        : integer := 256;
      ways        : integer := 8;
      nl2         : integer := 4;
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
      cache_tile_id : cache_attribute_array);

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

  component l2_acc_wrapper is
    generic (
      tech        : integer := virtex7;
      sets        : integer := 256;
      ways        : integer := 8;
      nl2         : integer := 4;
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
      cahce_tile_id : cache_attribute_array);

    port (
      rst : in std_ulogic;
      clk : in std_ulogic;

      -- frontend (cache - Accelerator DMA)
      -- header / lenght parallel ports
      dma_read                  : in std_ulogic;
      dma_write                 : in std_ulogic;
      dma_length                : in addr_t;
      dma_address               : in addr_t;
      -- cahce->acc (data only)
      dma_rcv_ready             : in  std_ulogic;
      dma_rcv_data              : out noc_flit_type;
      dma_rcv_valid             : out std_ulogic;
      -- acc->cache (data only)
      dma_snd_valid             : in  std_ulogic;
      dma_snd_data              : in  noc_flit_type;
      dma_snd_ready             : out std_ulogic;
      -- Accelerator done causes a flush
      flush                     : in  std_ulogic;

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
  -- l2 component
  -----------------------------------------------------------------------------

  component l2
    generic (
      tech : integer := virtex7;
      sets : integer := 256;
      ways : integer := 8);
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
      l2_fwd_in_data_addr       : in line_addr_t;
      l2_fwd_in_data_req_id     : in cache_id_t;
      l2_rsp_in_valid           : in std_ulogic;
      l2_rsp_in_data_coh_msg    : in coh_msg_t;
      l2_rsp_in_data_addr       : in line_addr_t;
      l2_rsp_in_data_line       : in line_t;
      l2_rsp_in_data_invack_cnt : in invack_cnt_t;
      l2_flush_valid            : in std_ulogic;
      l2_flush_data             : in std_ulogic;
      l2_rd_rsp_ready           : in std_ulogic;
      l2_inval_ready            : in std_ulogic;
      l2_req_out_ready          : in std_ulogic;
      l2_rsp_out_ready          : in std_ulogic;
      flush_done              : out std_ulogic;
      l2_cpu_req_ready        : out std_ulogic;
      l2_fwd_in_ready         : out std_ulogic;
      l2_rsp_in_ready         : out std_ulogic;
      l2_flush_ready          : out std_ulogic;
      l2_rd_rsp_valid         : out std_ulogic;
      l2_rd_rsp_data_line     : out line_t;
      l2_inval_valid          : out std_ulogic;
      l2_inval_data           : out line_addr_t;
      l2_req_out_valid        : out std_ulogic;
      l2_req_out_data_coh_msg : out coh_msg_t;
      l2_req_out_data_hprot   : out hprot_t;
      l2_req_out_data_addr    : out line_addr_t;
      l2_req_out_data_line    : out line_t;
      l2_rsp_out_valid        : out std_ulogic;
      l2_rsp_out_data_coh_msg : out coh_msg_t;
      l2_rsp_out_data_req_id  : out cache_id_t;
      l2_rsp_out_data_to_req  : out std_ulogic;
      l2_rsp_out_data_addr    : out line_addr_t;
      l2_rsp_out_data_line    : out line_t

      );

  end component;

  -----------------------------------------------------------------------------
  -- llc_wrapper component
  -----------------------------------------------------------------------------

  component llc_wrapper is
    generic (
      tech        : integer                      := virtex7;
      sets        : integer                      := 256;
      ways        : integer                      := 16;
      nl2         : integer                      := 4;
      noc_xlen    : integer                      := 2;
      hindex      : integer range 0 to NAHBSLV-1 := 4;
      local_y     : local_yx;
      local_x     : local_yx;
      cacheline   : integer;
      l2_cache_en : integer                      := 0;
      cache_tile_id : cache_attribute_array;
      dma_tile_id   : dma_attribute_array;
      tile_cahce_id : tile_attribute_array;
      tile_dma_id   : tile_attribute_array;
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
      coherence_rsp_rcv_empty    : in  std_ulogic;
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
      debug_led                  : out std_ulogic);
  end component;


  -----------------------------------------------------------------------------
  -- llc component
  -----------------------------------------------------------------------------
  component llc
    generic (
      tech : integer := virtex7;
      sets : integer := 256;
      ways : integer := 8);
    port (
      clk : in std_ulogic;
      rst : in std_ulogic;

      llc_rst_tb_valid      : in  std_ulogic;
      llc_rst_tb_data       : in  std_ulogic;
      llc_rst_tb_done_ready : in  std_ulogic;
      llc_rst_tb_ready      : out std_ulogic;
      llc_rst_tb_done_valid : out std_ulogic;
      llc_rst_tb_done_data  : out std_ulogic;

      llc_req_in_ready        : out std_ulogic;
      llc_req_in_valid        : in  std_ulogic;
      llc_req_in_data_coh_msg : in  coh_msg_t;
      llc_req_in_data_hprot   : in  hprot_t;
      llc_req_in_data_addr    : in  line_addr_t;
      llc_req_in_data_line    : in  line_t;
      llc_req_in_data_req_id  : in  cache_id_t;

      llc_rsp_in_ready       : out std_ulogic;
      llc_rsp_in_valid       : in  std_ulogic;
      llc_rsp_in_data_addr   : in  line_addr_t;
      llc_rsp_in_data_line   : in  line_t;
      llc_rsp_in_data_req_id : in  cache_id_t;

      llc_mem_rsp_ready     : out std_ulogic;
      llc_mem_rsp_valid     : in  std_ulogic;
      llc_mem_rsp_data_line : in  line_t;

      llc_rsp_out_ready           : in  std_ulogic;
      llc_rsp_out_valid           : out std_ulogic;
      llc_rsp_out_data_coh_msg    : out coh_msg_t;
      llc_rsp_out_data_addr       : out line_addr_t;
      llc_rsp_out_data_line       : out line_t;
      llc_rsp_out_data_invack_cnt : out invack_cnt_t;
      llc_rsp_out_data_req_id     : out cache_id_t;
      llc_rsp_out_data_dest_id    : out cache_id_t;

      llc_fwd_out_ready        : in  std_ulogic;
      llc_fwd_out_valid        : out std_ulogic;
      llc_fwd_out_data_coh_msg : out coh_msg_t;
      llc_fwd_out_data_addr    : out line_addr_t;
      llc_fwd_out_data_req_id  : out cache_id_t;
      llc_fwd_out_data_dest_id : out cache_id_t;

      llc_mem_req_ready       : in  std_ulogic;
      llc_mem_req_valid       : out std_ulogic;
      llc_mem_req_data_hwrite : out std_ulogic;
      llc_mem_req_data_hsize  : out hsize_t;
      llc_mem_req_data_hprot  : out hprot_t;
      llc_mem_req_data_addr   : out line_addr_t;
      llc_mem_req_data_line   : out line_t
      );

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

  function read_from_line (addr : addr_t; line : line_t) return word_t is
    variable w_off : integer;
    variable word  : word_t;

  begin

    w_off := to_integer(unsigned(addr(W_OFF_RANGE_HI downto W_OFF_RANGE_LO)));
    word  := line((w_off * BITS_PER_WORD) + BITS_PER_WORD - 1 downto w_off * BITS_PER_WORD);

    return word;

  end function read_from_line;

  function make_header (coh_msg     : coh_msg_t; mem_info : tile_mem_info_vector;
                        mem_num     : integer; hprot : hprot_t; addr : line_addr_t;
                        local_x     : local_yx; local_y : local_yx;
                        to_req      : std_ulogic; req_id : cache_id_t;
                        cache_tile_id : cache_attribute_array; noc_xlen : integer)
    return noc_flit_type is

    variable header         : noc_flit_type;
    variable dest_x, dest_y : local_yx;
    variable dest_init      : integer;

  begin

    if to_req = '0' then

      dest_x := mem_info(0).x;
      dest_y := mem_info(0).y;
      if mem_num /= 1 then
        for i in 0 to mem_num - 1 loop
          if ((addr(TAG_BITS + SET_BITS - 1 downto TAG_BITS + SET_BITS - 12)
               xor conv_std_logic_vector(mem_info(i).haddr, 12))
              and conv_std_logic_vector(mem_info(i).hmask, 12)) = x"000" then
            dest_x := mem_info(i).x;
            dest_y := mem_info(i).y;
          end if;
        end loop;
      end if;

    else

      if req_id >= "0" then
        dest_init := conv_std_logic_vector(cache_tile_id(to_integer(unsigned(req_id))), 3);
        if dest_init >= 0 then
          dest_x := std_logic_vector(to_unsigned((dest_init mod noc_xlen), 3));
          dest_y := std_logic_vector(to_unsigned((dest_init / noc_xlen), 3));
        end if;
      end if;

    end if;

    -- compose header
    header := create_header(local_y, local_x, dest_y, dest_x, '0' & coh_msg,
                            std_logic_vector(resize(unsigned(hprot), RESERVED_WIDTH)));

    return header;

  end function make_header;

  function get_owner_bits (ncpu_bits : integer)
    return integer is

    variable owner_bits : integer;
    
  begin

    if ncpu_bits = 0 then
      owner_bits := 1;
    else
      owner_bits := ncpu_bits;
    end if;

    return owner_bits;

  end function get_owner_bits;

  
end package body cachepackage;
