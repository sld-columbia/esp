-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.nocpackage.all;
use work.misc.all;
use work.monitor_pkg.all;
use work.allcaches.all;

package cachepackage is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

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

  constant AS_INV_STATE          : integer := 13;
  -- constant AS_AHBM_ : integer := 0;

  -- constant AS_REQ_ : integer := 0;

  -- constant AS_RSPIN_ : integer := 0;

  --

  -- NoC-L2cache planes encoding
  constant MSG_REQ_PLANE : std_logic_vector(1 downto 0) := "00";
  constant MSG_FWD_PLANE : std_logic_vector(1 downto 0) := "01";
  constant MSG_RSP_PLANE : std_logic_vector(1 downto 0) := "10";
  constant MSG_DMA_PLANE : std_logic_vector(1 downto 0) := "11";

  -- Accelerator coherence type encoding
  constant ACC_COH_NONE   : integer := 0;
  constant ACC_COH_LLC    : integer := 1;
  constant ACC_COH_RECALL : integer := 2;
  constant ACC_COH_FULL   : integer := 3;

  constant COH_T_LOG2 : integer := 2;

  -- Bus state
  constant AS_AHBM_LOAD_NOT_GRANTED  : integer := 0;
  constant AS_AHBM_STORE_NOT_GRANTED : integer := 1;

  -- CPU request type
  constant CPU_READ       : std_logic_vector(1 downto 0) := "00";
  constant CPU_READ_ATOM  : std_logic_vector(1 downto 0) := "01";
  constant CPU_WRITE      : std_logic_vector(1 downto 0) := "10";
  constant CPU_WRITE_ATOM : std_logic_vector(1 downto 0) := "11";

  -- Ongoing transaction buffers
  constant N_REQS : integer := 4;

  constant LINE_RANGE_HI  : integer := (ADDR_BITS - 1);
  constant LINE_RANGE_LO  : integer := (OFFSET_BITS);
  constant OFF_RANGE_HI   : integer := (OFFSET_BITS - 1);
  constant OFF_RANGE_LO   : integer := 0;
  constant W_OFF_RANGE_HI : integer := (OFFSET_BITS - 1);
  constant W_OFF_RANGE_LO : integer := (OFFSET_BITS - WORD_OFFSET_BITS);
  constant B_OFF_RANGE_HI : integer := (BYTE_OFFSET_BITS - 1);
  constant B_OFF_RANGE_LO : integer := 0;

  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  subtype addr_t is std_logic_vector(ADDR_BITS - 1 downto 0);
  subtype word_offset_t is std_logic_vector(WORD_OFFSET_BITS - 1 downto 0);
  subtype line_addr_t is std_logic_vector(ADDR_BITS - OFFSET_BITS - 1 downto 0);
  subtype cpu_msg_t is std_logic_vector(CPU_MSG_TYPE_WIDTH - 1 downto 0);
  subtype hsize_t is std_logic_vector(HSIZE_WIDTH - 1 downto 0);
  subtype hprot_t is std_logic_vector(HPROT_WIDTH - 1 downto 0);
  subtype word_t is std_logic_vector(BITS_PER_WORD - 1 downto 0);
  subtype dcs_t is std_logic_vector(DCS_BITS - 1 downto 0);
  subtype line_t is std_logic_vector(BITS_PER_LINE - 1 downto 0);
  subtype word_mask_t is std_logic_vector(WORDS_PER_LINE - 1 downto 0);
  subtype amo_t is std_logic_vector(AMO_BITS - 1 downto 0);
  subtype coh_msg_t is std_logic_vector(COH_MSG_TYPE_WIDTH - 1 downto 0);
  subtype mix_msg_t is std_logic_vector(MIX_MSG_TYPE_WIDTH - 1 downto 0);
  subtype bresp_t is std_logic_vector(BRESP_WIDTH - 1 downto 0);
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
  subtype llc_coh_dev_id_t is std_logic_vector(NLLC_MAX_LOG2 - 1 downto 0);
  -- hprot
  constant DEFAULT_HPROT : hprot_t := "00";

  -- hsize
  constant HSIZE_B  : hsize_t := "000";
  constant HSIZE_HW : hsize_t := "001";
  constant HSIZE_W  : hsize_t := "010";

  constant dma32_words : integer := ARCH_BITS / 32;

  -- Constants to handle special case in which there is no memory tile
  -- In this case LLC and memory-related components won't be present in the
  -- system. This constant simply fixes CAD tools complains about null ranges
  constant MEM_ID_RANGE_MSB : integer := set_mem_id_range;
  constant SLMDDR_ID_RANGE_MSB : integer := set_slmddr_id_range;

  -----------------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------------
  function read_from_line (addr : addr_t; line : line_t)
    return word_t;

  function read_word (line : line_t; w_off : integer)
    return word_t;

  function read_word32 (line : line_t; w_off : integer; w32_off : integer)
    return word_t;

  function make_header (coh_msg     : coh_msg_t; mem_info : tile_mem_info_vector(0 to MEM_ID_RANGE_MSB);
                        mem_num     : integer; hprot : hprot_t; addr : line_addr_t;
                        local_x     : local_yx; local_y : local_yx;
                        to_req      : std_ulogic; req_id : cache_id_t;
                        cache_x     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
                        cache_y     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
                        word_mask    : word_mask_t)
    return noc_flit_type;

  function make_dcs_header (coh_msg     : coh_msg_t; mem_info : tile_mem_info_vector(0 to MEM_ID_RANGE_MSB);
    mem_num     : integer; hprot : hprot_t; addr : line_addr_t;
    local_x     : local_yx; local_y : local_yx;
    to_req      : std_ulogic; req_id : cache_id_t; src_id : cache_id_t;
    cache_x     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
    cache_y     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
    word_mask    : word_mask_t)
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
      little_end  : integer range 0 to 1 := 1;
      hindex_mst  : integer := 0;
      pindex      : integer range 0 to NAPBSLV - 1 := 6;
      pirq        : integer := 4;
      mem_hindex  : integer := 4;
      mem_hconfig : ahb_config_type;
      mem_num     : integer := 1;
      mem_info    : tile_mem_info_vector(0 to MEM_ID_RANGE_MSB);
      cache_y     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
      cache_x     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
      cache_tile_id : cache_attribute_array);
    port (
      rst : in std_ulogic;
      clk : in std_ulogic;

      local_y  : in local_yx;
      local_x  : in local_yx;
      pconfig  : in apb_config_type;
      cache_id : in integer;
      tile_id  : in integer range 0 to CFG_TILES_NUM - 1;

      -- frontend (cache - AMBA)
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type;
      ahbmi : in  ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
      mosi  : in  axi_mosi_type;
      somi  : out axi_somi_type;
      ace_req : out  ace_req_type;
      ace_resp: in ace_resp_type;
      apbi  : in  apb_slv_in_type;
      apbo  : out apb_slv_out_type;
      flush : in  std_ulogic;           -- flush request from CPU
      flush_l1 : out std_ulogic;

      -- fence to L2
      fence_l2 : in std_logic_vector(1 downto 0);

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
      -- tile->Noc3
      coherence_fwd_snd_wrreq    : out std_ulogic;
      coherence_fwd_snd_data_in  : out noc_flit_type;
      coherence_fwd_snd_full     : in  std_ulogic;

      mon_cache                  : out monitor_cache_type
      );
  end component;

  component l2_acc_wrapper is
    generic (
      tech        : integer := virtex7;
      sets        : integer := 256;
      ways        : integer := 8;
      little_end  : integer range 0 to 1 := 1;
      mem_num     : integer := 1;
      mem_info    : tile_mem_info_vector(0 to MEM_ID_RANGE_MSB);
      cache_y     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
      cache_x     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
      cache_tile_id : cache_attribute_array);
    port (
      rst : in std_ulogic;
      clk : in std_ulogic;

      local_y  : in local_yx;
      local_x  : in local_yx;
      tile_id  : in integer range 0 to CFG_TILES_NUM - 1;

      -- frontend (cache - Accelerator DMA)
      -- header / lenght parallel ports
      dma_read                  : in  std_ulogic;
      dma_write                 : in  std_ulogic;
      dma_length                : in  addr_t;
      dma_address               : in  addr_t;
      dma_ready                 : out std_ulogic;
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
      aq                        : in  std_ulogic;
      rl                        : in  std_ulogic;
      spandex_conf              : in  std_logic_vector(31 downto 0);
      acc_flush_done            : out std_ulogic;
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
      -- tile->Noc3
      coherence_fwd_snd_wrreq    : out std_ulogic;
      coherence_fwd_snd_data_in  : out noc_flit_type;
      coherence_fwd_snd_full     : in  std_ulogic;

      mon_cache                  : out monitor_cache_type
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
      ahb_if_en   : integer range 0 to 1         := 1;
      nl2         : integer                      := 4;
      nllc        : integer                      := 1;
      noc_xlen    : integer                      := 2;
      noc_ylen    : integer                      := 2;
      hindex      : integer range 0 to NAHBSLV - 1 := 4;
      pindex      : integer range 0 to NAPBSLV - 1 := 5;
      pirq        : integer                      := 4;
      cacheline   : integer;
      little_end  : integer range 0 to 1 := 0;
      l2_cache_en : integer                      := 0;
      cache_tile_id : cache_attribute_array;
      dma_tile_id   : dma_attribute_array;
      tile_cache_id : attribute_vector(0 to CFG_TILES_NUM - 1);
      tile_dma_id   : attribute_vector(0 to CFG_TILES_NUM - 1);
      eth_dma_id    : integer;
      dma_y         : yx_vec(0 to 2**NLLC_MAX_LOG2 - 1);
      dma_x         : yx_vec(0 to 2**NLLC_MAX_LOG2 - 1);
      cache_y       : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
      cache_x       : yx_vec(0 to 2**NL2_MAX_LOG2 - 1));
    port (
      rst   : in  std_ulogic;
      clk   : in  std_ulogic;

      local_y : in local_yx;
      local_x : in local_yx;
      pconfig : in apb_config_type;

      ahbmi : in  ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
      apbi  : in  apb_slv_in_type;
      apbo  : out apb_slv_out_type;

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
      dma_rcv_rdreq              : out std_ulogic;
      dma_rcv_data_out       : in  noc_flit_type;
      dma_rcv_empty          : in  std_ulogic;
      -- -- tile->NoC4
      dma_snd_wrreq          : out std_ulogic;
      dma_snd_data_in        : out noc_flit_type;
      dma_snd_full           : in  std_ulogic;
      -- LLC->ext
      ext_req_ready              : in  std_ulogic;
      ext_req_valid              : out std_ulogic;
      ext_req_data               : out std_logic_vector(ARCH_BITS - 1 downto 0);
      -- ext->LLC
      ext_rsp_ready              : out std_ulogic;
      ext_rsp_valid              : in  std_ulogic;
      ext_rsp_data               : in  std_logic_vector(ARCH_BITS - 1 downto 0);
      mon_cache                  : out monitor_cache_type
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
    word := read_word(line, w_off);

    return word;

  end function read_from_line;

  function read_word (line : line_t; w_off : integer) return word_t is

    variable word  : word_t;
    
  begin

    word := line((w_off * BITS_PER_WORD) + BITS_PER_WORD - 1 downto w_off * BITS_PER_WORD);

    return word;

  end function read_word;
  
  function read_word32 (line : line_t; w_off : integer; w32_off : integer) return word_t is

    variable word  : word_t;
    
  begin

    word := (others => '0');
    word(31 downto 0) := line((w_off * BITS_PER_WORD) + (w32_off * 32) + 32 - 1 downto (w_off * BITS_PER_WORD) + (w32_off * 32));

    return word;

  end function read_word32;

  function make_header (coh_msg     : coh_msg_t; mem_info : tile_mem_info_vector(0 to MEM_ID_RANGE_MSB);
                        mem_num     : integer; hprot : hprot_t; addr : line_addr_t;
                        local_x     : local_yx; local_y : local_yx;
                        to_req      : std_ulogic; req_id : cache_id_t;
                        cache_x     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
                        cache_y     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
                        word_mask    : word_mask_t)
    return noc_flit_type is

    variable header         : noc_flit_type;
    variable dest_x, dest_y : local_yx;
    variable dest_init      : integer;
    variable reserved       : std_logic_vector(RESERVED_WIDTH-1 downto 0);
    variable noc_msg        : noc_msg_type;

  begin

    if to_req = '0' then

      dest_x := mem_info(0).x;
      dest_y := mem_info(0).y;
      if mem_num /= 1 then
        for i in 0 to mem_num - 1 loop
          if ((addr(LINE_ADDR_BITS - 1 downto LINE_ADDR_BITS - 12)
               xor conv_std_logic_vector(mem_info(i).haddr, 12))
              and conv_std_logic_vector(mem_info(i).hmask, 12)) = x"000" then
            dest_x := mem_info(i).x;
            dest_y := mem_info(i).y;
          end if;
        end loop;
      end if;

    else

      if req_id >= "0" then
        dest_init := to_integer(unsigned(req_id));
        if dest_init >= 0 then
          dest_x := cache_x(dest_init);
          dest_y := cache_y(dest_init);
        end if;
      end if;

    end if;

    -- compose header
    if USE_SPANDEX = 0 then
      noc_msg := '1' & coh_msg;
    else
      noc_msg := '0' & coh_msg;
    end if;
    reserved := word_mask & std_logic_vector(resize(unsigned(hprot), RESERVED_WIDTH - WORDS_PER_LINE));
    header := create_header(NOC_FLIT_SIZE, local_y, local_x, dest_y, dest_x, noc_msg, reserved);

    return header;

  end function make_header;

  function make_dcs_header (coh_msg     : coh_msg_t; mem_info : tile_mem_info_vector(0 to MEM_ID_RANGE_MSB);
                        mem_num     : integer; hprot : hprot_t; addr : line_addr_t;
                        local_x     : local_yx; local_y : local_yx;
                        to_req      : std_ulogic; req_id : cache_id_t; src_id : cache_id_t;
                        cache_x     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
                        cache_y     : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
                        word_mask    : word_mask_t)
    return noc_flit_type is

    variable header         : noc_flit_type;
    variable dest_x, dest_y : local_yx;
    variable dest_init      : integer;
    variable reserved       : std_logic_vector(RESERVED_WIDTH-1 downto 0);

  begin

    if to_req = '0' then

      dest_x := mem_info(0).x;
      dest_y := mem_info(0).y;
      if mem_num /= 1 then
        for i in 0 to mem_num - 1 loop
          if ((addr(LINE_ADDR_BITS - 1 downto LINE_ADDR_BITS - 12)
               xor conv_std_logic_vector(mem_info(i).haddr, 12))
              and conv_std_logic_vector(mem_info(i).hmask, 12)) = x"000" then
            dest_x := mem_info(i).x;
            dest_y := mem_info(i).y;
          end if;
        end loop;
      end if;

    else

      if req_id >= "0" then
        dest_init := to_integer(unsigned(req_id));
        if dest_init >= 0 then
          dest_x := cache_x(dest_init);
          dest_y := cache_y(dest_init);
        end if;
      end if;

    end if;

    -- compose header
    reserved := word_mask & std_logic_vector(resize(unsigned(src_id), RESERVED_WIDTH - WORDS_PER_LINE));
    header := create_header(NOC_FLIT_SIZE, local_y, local_x, dest_y, dest_x, '0' & coh_msg, reserved);

    return header;

  end function make_dcs_header;

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
