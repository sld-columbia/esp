-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

use work.esp_global.all;
use work.stdlib.all;
use work.gencomp.all;
use work.monitor_pkg.all;

package nocpackage is

-------------------------------------------------------------------------------
-- RTL NOC constants and type
--
-- Addressing is XY; X: from left to right, Y: from top to bottom
--
-- Check the module "router" in router.vhd for details on routing algorithm
--
-------------------------------------------------------------------------------


  -- Header fields
  --
  -- Let W be the global constant ARCH_BITS
  --
  -- |W+1        W|W-1     W-3|W-4     W-6|W-7     W-9|W-10   W-12|W-13     W-17|W-18      W-25|W-26       5|4   0|
  -- |  PREAMBLE  |   Src Y   |   Src X   |   Dst Y   |   Dst X   |  Msg. type  |   Reserved   |  [Unused]  |LEWSN|

  -- |mmmm00xx|
  -- |reserved|
  --

  -- Header with 2 destinations
  -- |W+1        W|W-1     W-3|W-4     W-6|W-7     W-9|W-10   W-12|W-13   W-15|W-16   W-18|W-19  W-20|W-21     W-25|W-26       5|4   0|
  -- |  PREAMBLE  |   Src Y   |   Src X   |   Dst1 Y  |   Dst1 X  |   Dst1 Y  |   Dst1 X  |   Valid  |  Msg. type  |   Reserved |LEWSN|



  constant HEADER_ROUTE_L : natural := 4;
  constant HEADER_ROUTE_E : natural := 3;
  constant HEADER_ROUTE_W : natural := 2;
  constant HEADER_ROUTE_S : natural := 1;
  constant HEADER_ROUTE_N : natural := 0;

  constant PREAMBLE_WIDTH      : natural := 2;
  constant YX_WIDTH            : natural := 3;
  constant MSG_TYPE_WIDTH      : natural := 5;
  constant RESERVED_WIDTH      : natural := 8;
  constant NEXT_ROUTING_WIDTH  : natural := 5;
  constant COH_NOC_FLIT_SIZE       : natural := PREAMBLE_WIDTH + COH_NOC_WIDTH;
  constant DMA_NOC_FLIT_SIZE       : natural := PREAMBLE_WIDTH + DMA_NOC_WIDTH;
  constant MISC_NOC_FLIT_SIZE  : natural := PREAMBLE_WIDTH + 32;
  constant ARCH_NOC_FLIT_SIZE  : natural := PREAMBLE_WIDTH + ARCH_BITS;
  constant MAX_NOC_FLIT_SIZE  : natural := PREAMBLE_WIDTH + MAX_NOC_WIDTH;

  subtype local_yx is std_logic_vector(YX_WIDTH-1 downto 0);
  subtype noc_preamble_type is std_logic_vector(PREAMBLE_WIDTH-1 downto 0);
  subtype noc_msg_type is std_logic_vector(MSG_TYPE_WIDTH-1 downto 0);
  subtype coh_noc_flit_type is std_logic_vector(COH_NOC_FLIT_SIZE-1 downto 0);
  subtype dma_noc_flit_type is std_logic_vector(DMA_NOC_FLIT_SIZE-1 downto 0);
  subtype arch_noc_flit_type is std_logic_vector(ARCH_NOC_FLIT_SIZE-1 downto 0);
  subtype misc_noc_flit_type is std_logic_vector(33 downto 0);
  subtype max_noc_flit_type is std_logic_vector(MAX_NOC_FLIT_SIZE downto 0);
  subtype reserved_field_type is std_logic_vector(RESERVED_WIDTH-1 downto 0);
  subtype ports_vec is std_logic_vector(4 downto 0);

  type coh_noc_flit_vector is array (natural range <>) of coh_noc_flit_type;
  type dma_noc_flit_vector is array (natural range <>) of dma_noc_flit_type;
  type misc_noc_flit_vector is array (natural range <>) of misc_noc_flit_type;
  type arch_noc_flit_vector is array (natural range <>) of arch_noc_flit_type;

 
  type mcast_type is record
    header_vec : dma_noc_flit_vector(0 to 3);
    quad_count : std_logic_vector(0 to 3);
  end record;
  --Rather than define seaprate functions for interacting with each NoC width,
  --we make them take the max width and then pad the inputs to fill.
  constant coh_noc_flit_pad : std_logic_vector(MAX_NOC_FLIT_SIZE - COH_NOC_FLIT_SIZE downto 0) := (others => '0');
  constant dma_noc_flit_pad : std_logic_vector(MAX_NOC_FLIT_SIZE - DMA_NOC_FLIT_SIZE downto 0) := (others => '0');
  constant misc_noc_flit_pad : std_logic_vector(MAX_NOC_FLIT_SIZE - MISC_NOC_FLIT_SIZE downto 0) := (others => '0');
  constant arch_noc_flit_pad : std_logic_vector(MAX_NOC_FLIT_SIZE - ARCH_NOC_FLIT_SIZE downto 0) := (others => '0');

  type dest_arr is array (natural range <>) of local_yx;

  -- Preamble encoding
  constant PREAMBLE_HEADER : noc_preamble_type := "10";
  constant PREAMBLE_TAIL   : noc_preamble_type := "01";
  constant PREAMBLE_BODY   : noc_preamble_type := "00";
  constant PREAMBLE_1FLIT  : noc_preamble_type := "11";

  -- -- Message type preamble
  constant MSG_T_PR : std_logic := to_std_logic(1 - USE_SPANDEX);

  -- -- Message type encoding
  -- -- Cachable data plane 1 -> request messages
  constant REQ_S          : noc_msg_type := "00000";  -- Writer-invalidated Read
  constant REQ_Odata      : noc_msg_type := "00001";  -- Ownership Write (overwrites all requested data)
  constant REQ_WT         : noc_msg_type := "00010";  -- Write-through Write (overwrites all requested data)
  constant REQ_WB         : noc_msg_type := "00011";  -- Write-back owned data
  constant REQ_O          : noc_msg_type := "00100";  -- Ownership Write (returns the value before update)
  constant REQ_V          : noc_msg_type := "00101";  -- Self-invalidated Read
  constant REQ_WTdata     : noc_msg_type := "00110";  -- Write-through Write (returns the value before update)
  constant REQ_AMO_SWAP   : noc_msg_type := "00110";
  constant REQ_AMO_ADD    : noc_msg_type := "00111";
  constant REQ_AMO_AND    : noc_msg_type := "01000";
  constant REQ_AMO_OR     : noc_msg_type := "01001";
  constant REQ_AMO_XOR    : noc_msg_type := "01010";
  constant REQ_AMO_MAX    : noc_msg_type := "01011";
  constant REQ_AMO_MAXU   : noc_msg_type := "01100";
  constant REQ_AMO_MIN    : noc_msg_type := "01101";
  constant REQ_AMO_MINU   : noc_msg_type := "01110";
  constant REQ_WTfwd      : noc_msg_type := "01111";
  -- Cachable data plane 2 -> forwarded messages
  constant FWD_REQ_S      : noc_msg_type := "00000";
  constant FWD_REQ_Odata  : noc_msg_type := "00001";
  constant FWD_INV_SPDX   : noc_msg_type := "00010";
  constant FWD_WB_ACK     : noc_msg_type := "00011";
  constant FWD_RVK_O      : noc_msg_type := "00100";
  constant FWD_REQ_V      : noc_msg_type := "00111";
  constant FWD_REQ_O      : noc_msg_type := "00110";
  constant FWD_WTfwd      : noc_msg_type := "00101";
  -- Cachable data plane 3 -> response messages
  constant RSP_S              : noc_msg_type := "00000";
  constant RSP_Odata          : noc_msg_type := "00001";
  constant RSP_INV_ACK_SPDX   : noc_msg_type := "00010";
  constant RSP_NACK           : noc_msg_type := "00011";
  constant RSP_RVK_O          : noc_msg_type := "00100";
  constant RSP_V              : noc_msg_type := "00101";
  constant RSP_O              : noc_msg_type := "00110";
  constant RSP_WT             : noc_msg_type := "00111";
  constant RSP_WTdata         : noc_msg_type := "01000";
  constant RSP_DATA_DMA       : noc_msg_type := MSG_T_PR & MSG_T_PR & "011"; -- message type in common with original ESP caches

-- ********
-- Original ESP
-- ********


-- -- Message type encoding
  -- -- Cachable data plane 1 -> request messages
  constant REQ_GETS_W   : noc_msg_type := "11000";  --Get Shared (word)
  constant REQ_GETM_W   : noc_msg_type := "11001";  --Get Modified (word)
  constant REQ_PUTS     : noc_msg_type := "11010";  --Put Shared/Exclusive
  constant REQ_PUTM     : noc_msg_type := "11011";  --Put Modified
  constant REQ_GETS_B   : noc_msg_type := "11100";  --Get Shared (Byte)
  constant REQ_GETS_HW  : noc_msg_type := "11101";  --Get Shared (Half Word)
  constant REQ_GETM_B   : noc_msg_type := "11110";  --Get Modified (Byte)
  constant REQ_GETM_HW  : noc_msg_type := "11111";  --Get Modified (Half word)
  -- Cachable data plane 2 -> forwarded messages
  constant FWD_GETS       : noc_msg_type := "11000";
  constant FWD_GETM       : noc_msg_type := "11001";
  constant FWD_INV        : noc_msg_type := "11010";  --Invalidation
  constant FWD_PUT_ACK    : noc_msg_type := "11011";  --Put Acknowledge
  constant FWD_GETM_NOCOH : noc_msg_type := "11100";  --Recall on exclusive/modified
  constant FWD_INV_NOCOH  : noc_msg_type := "11101";  --Recall on shared
  -- Cachable data plane 3 -> response messages
  constant RSP_DATA     : noc_msg_type := "11000";  --CacheLine
  constant RSP_EDATA    : noc_msg_type := "11001";  --Cache Line (Exclusive)
  constant RSP_INV_ACK  : noc_msg_type := "11010";  --Invalidation Acknowledge
  -- [LLC|Non]-Coherent DMA request plane 6 and response plane 4
  constant DMA_TO_DEV    : noc_msg_type := "11001";
  constant DMA_FROM_DEV  : noc_msg_type := "11010";
  -- constant RSP_DATA_DMA  : noc_msg_type := "11011";  --CacheLine (DMA)
  constant RSP_P2P       : noc_msg_type := "11100";
  constant REQ_P2P       : noc_msg_type := "11101";
  constant REQ_DMA_READ  : noc_msg_type := "11110";  -- Read coherent with LLC
  constant REQ_DMA_WRITE : noc_msg_type := "11111";  -- Write coherent with LLC
  constant CPU_DMA       : noc_msg_type := "11100";  -- identify DMA from CPU
  -- Configuration plane 5 -> RD/WR registers
  constant REQ_REG_RD   : noc_msg_type := "11000";
  constant REQ_REG_WR   : noc_msg_type := "11001";
  constant AHB_RD       : noc_msg_type := "11010";
  constant AHB_WR       : noc_msg_type := "11011";
  constant IRQ_MSG      : noc_msg_type := "11100";
  constant RSP_REG_RD   : noc_msg_type := "11101";
  constant RSP_AHB_RD   : noc_msg_type := "11110";
  constant INTERRUPT    : noc_msg_type := "11111";
  constant DVFS_MSG     : noc_msg_type := "00000";

  constant ROUTE_NOC3 : std_logic_vector(1 downto 0) := "01";
  constant ROUTE_NOC4 : std_logic_vector(1 downto 0) := "10";
  constant ROUTE_NOC5 : std_logic_vector(1 downto 0) := "11";

  -- Ports routing encoding
  -- 4 = Local tile
  -- 3 = East
  -- 2 = West
  -- 1 = South
  -- 0 = North

  -- 0 = AN; 1 = CB
  constant FLOW_CONTROL : integer := 0;
  -- FIFOs depth
  constant ROUTER_DEPTH : integer := 4;

  type yx_vec is array (natural range <>) of std_logic_vector(2 downto 0);
  type routing_vec is array (natural range <>) of std_logic_vector(NEXT_ROUTING_WIDTH - 1 downto 0);

  type tile_mem_info is record
    x     : local_yx;
    y     : local_yx;
    haddr : integer;
    hmask : integer;
  end record;

  constant tile_mem_info_none : tile_mem_info := (
    x => (others => '0'),
    y => (others => '0'),
    haddr => 16#000#,
    hmask => 16#fff#
    );

  type tile_mem_info_vector is array (natural range <>) of tile_mem_info;

  -- Components
  component fifo0
    generic (
      depth : integer;
      width : integer);
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      rdreq    : in  std_logic;
      wrreq    : in  std_logic;
      data_in  : in  std_logic_vector(width-1 downto 0);
      empty    : out std_logic;
      full     : out std_logic;
      data_out : out std_logic_vector(width-1 downto 0));
  end component;

  component fifo2
    generic (
      depth : integer;
      width : integer);
    port (
      clk            : in  std_logic;
      rst            : in  std_logic;
      rdreq          : in  std_logic;
      wrreq          : in  std_logic;
      data_in        : in  std_logic_vector(width-1 downto 0);
      empty          : out std_logic;
      full           : out std_logic;
      atleast_4slots : out std_logic;
      exactly_3slots : out std_logic;
      data_out       : out std_logic_vector(width-1 downto 0));
  end component;

  component fifo3
    generic (
      depth : integer;
      width : integer);
    port (
      clk         : in  std_logic;
      rst         : in  std_logic;
      rdreq       : in  std_logic;
      wrreq       : in  std_logic;
      data_in     : in  std_logic_vector(width-1 downto 0);
      empty       : out std_logic;
      full        : out std_logic;
      almost_full : out std_logic;
      data_out    : out std_logic_vector(width-1 downto 0));
  end component;

  component inferred_async_fifo
    generic (
      g_data_width : natural := COH_NOC_FLIT_SIZE;
      g_size       : natural := 6);
    port (
      rst_wr_n_i : in  std_logic := '1';
      clk_wr_i   : in  std_logic;
      we_i       : in  std_logic;
      d_i        : in  std_logic_vector(g_data_width-1 downto 0);
      wr_full_o  : out std_logic;
      rst_rd_n_i : in  std_logic := '1';
      clk_rd_i   : in  std_logic;
      rd_i       : in  std_logic;
      q_o        : out std_logic_vector(g_data_width-1 downto 0);
      rd_empty_o : out std_logic);
  end component;

  component noc32_synchronizers is
    port (
      noc_rstn  : in std_ulogic;
      tile_rstn : in std_ulogic;
      noc_clk   : in std_ulogic;
      tile_clk  : in std_ulogic;
      -- NoC out to synchronizers
      output_port   : in  misc_noc_flit_type;
      data_void_out : in  std_ulogic;
      stop_in       : out std_ulogic;
      -- synchronizers to NoC in
      input_port   : out misc_noc_flit_type;
      data_void_in : out std_ulogic;
      stop_out     : in  std_ulogic;
      -- synchronizers out to tile
      output_port_tile   : out  misc_noc_flit_type;
      data_void_out_tile : out  std_ulogic;
      stop_in_tile       : in  std_ulogic;
      -- tile to synchronizers in
      input_port_tile   : in  misc_noc_flit_type;
      data_void_in_tile : in  std_ulogic;
      stop_out_tile     : out  std_ulogic);
  end component noc32_synchronizers;

  component sync_noc_set
    generic (
      PORTS     : std_logic_vector(4 downto 0);
      HAS_SYNC  : integer range 0 to 1 := 0);
    port (
      clk                : in  std_logic;
      clk_tile           : in  std_logic;
      rst                : in  std_logic;
      rst_tile           : in  std_logic;
      CONST_local_x      : in  std_logic_vector(2 downto 0);
      CONST_local_y      : in  std_logic_vector(2 downto 0);
      noc1_data_n_in     : in  coh_noc_flit_type;
      noc1_data_s_in     : in  coh_noc_flit_type;
      noc1_data_w_in     : in  coh_noc_flit_type;
      noc1_data_e_in     : in  coh_noc_flit_type;
      noc1_input_port    : in  coh_noc_flit_type;
      noc1_data_void_in  : in  std_logic_vector(4 downto 0);
      noc1_stop_in       : in  std_logic_vector(4 downto 0);
      noc1_data_n_out    : out coh_noc_flit_type;
      noc1_data_s_out    : out coh_noc_flit_type;
      noc1_data_w_out    : out coh_noc_flit_type;
      noc1_data_e_out    : out coh_noc_flit_type;
      noc1_output_port   : out coh_noc_flit_type;
      noc1_data_void_out : out std_logic_vector(4 downto 0);
      noc1_stop_out      : out std_logic_vector(4 downto 0);
      noc2_data_n_in     : in  coh_noc_flit_type;
      noc2_data_s_in     : in  coh_noc_flit_type;
      noc2_data_w_in     : in  coh_noc_flit_type;
      noc2_data_e_in     : in  coh_noc_flit_type;
      noc2_input_port    : in  coh_noc_flit_type;
      noc2_data_void_in  : in  std_logic_vector(4 downto 0);
      noc2_stop_in       : in  std_logic_vector(4 downto 0);
      noc2_data_n_out    : out coh_noc_flit_type;
      noc2_data_s_out    : out coh_noc_flit_type;
      noc2_data_w_out    : out coh_noc_flit_type;
      noc2_data_e_out    : out coh_noc_flit_type;
      noc2_output_port   : out coh_noc_flit_type;
      noc2_data_void_out : out std_logic_vector(4 downto 0);
      noc2_stop_out      : out std_logic_vector(4 downto 0);
      noc3_data_n_in     : in  coh_noc_flit_type;
      noc3_data_s_in     : in  coh_noc_flit_type;
      noc3_data_w_in     : in  coh_noc_flit_type;
      noc3_data_e_in     : in  coh_noc_flit_type;
      noc3_input_port    : in  coh_noc_flit_type;
      noc3_data_void_in  : in  std_logic_vector(4 downto 0);
      noc3_stop_in       : in  std_logic_vector(4 downto 0);
      noc3_data_n_out    : out coh_noc_flit_type;
      noc3_data_s_out    : out coh_noc_flit_type;
      noc3_data_w_out    : out coh_noc_flit_type;
      noc3_data_e_out    : out coh_noc_flit_type;
      noc3_output_port   : out coh_noc_flit_type;
      noc3_data_void_out : out std_logic_vector(4 downto 0);
      noc3_stop_out      : out std_logic_vector(4 downto 0);
      noc4_data_n_in     : in  dma_noc_flit_type;
      noc4_data_s_in     : in  dma_noc_flit_type;
      noc4_data_w_in     : in  dma_noc_flit_type;
      noc4_data_e_in     : in  dma_noc_flit_type;
      noc4_input_port    : in  dma_noc_flit_type;
      noc4_data_void_in  : in  std_logic_vector(4 downto 0);
      noc4_stop_in       : in  std_logic_vector(4 downto 0);
      noc4_data_n_out    : out dma_noc_flit_type;
      noc4_data_s_out    : out dma_noc_flit_type;
      noc4_data_w_out    : out dma_noc_flit_type;
      noc4_data_e_out    : out dma_noc_flit_type;
      noc4_output_port   : out dma_noc_flit_type;
      noc4_data_void_out : out std_logic_vector(4 downto 0);
      noc4_stop_out      : out std_logic_vector(4 downto 0);
      noc5_data_n_in     : in  misc_noc_flit_type;
      noc5_data_s_in     : in  misc_noc_flit_type;
      noc5_data_w_in     : in  misc_noc_flit_type;
      noc5_data_e_in     : in  misc_noc_flit_type;
      noc5_input_port    : in  misc_noc_flit_type;
      noc5_data_void_in  : in  std_logic_vector(4 downto 0);
      noc5_stop_in       : in  std_logic_vector(4 downto 0);
      noc5_data_n_out    : out misc_noc_flit_type;
      noc5_data_s_out    : out misc_noc_flit_type;
      noc5_data_w_out    : out misc_noc_flit_type;
      noc5_data_e_out    : out misc_noc_flit_type;
      noc5_output_port   : out misc_noc_flit_type;
      noc5_data_void_out : out std_logic_vector(4 downto 0);
      noc5_stop_out      : out std_logic_vector(4 downto 0);
      noc6_data_n_in     : in  dma_noc_flit_type;
      noc6_data_s_in     : in  dma_noc_flit_type;
      noc6_data_w_in     : in  dma_noc_flit_type;
      noc6_data_e_in     : in  dma_noc_flit_type;
      noc6_input_port    : in  dma_noc_flit_type;
      noc6_data_void_in  : in  std_logic_vector(4 downto 0);
      noc6_stop_in       : in  std_logic_vector(4 downto 0);
      noc6_data_n_out    : out dma_noc_flit_type;
      noc6_data_s_out    : out dma_noc_flit_type;
      noc6_data_w_out    : out dma_noc_flit_type;
      noc6_data_e_out    : out dma_noc_flit_type;
      noc6_output_port   : out dma_noc_flit_type;
      noc6_data_void_out : out std_logic_vector(4 downto 0);
      noc6_stop_out      : out std_logic_vector(4 downto 0);
      noc1_mon_noc_vec   : out monitor_noc_type;
      noc2_mon_noc_vec   : out monitor_noc_type;
      noc3_mon_noc_vec   : out monitor_noc_type;
      noc4_mon_noc_vec   : out monitor_noc_type;
      noc5_mon_noc_vec   : out monitor_noc_type;
      noc6_mon_noc_vec   : out monitor_noc_type
      );
  end component;

  -- Helper functions
  function ncpu_log (
    ncpu : integer)
    return integer;

  function set_mem_id_range
    return integer;

  function set_slmddr_id_range
    return integer;

  function get_origin_y (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return local_yx;

  function get_origin_x (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return local_yx;

  function get_destination_y (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return local_yx;

  function get_destination_x (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return local_yx;

  function get_msg_type (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return noc_msg_type;

  function get_preamble (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return noc_preamble_type;

  function get_reserved_field (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return reserved_field_type;

  function get_unused_msb_field (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return std_ulogic;

  function get_origin_y_misc (
    flit : misc_noc_flit_type)
    return local_yx;

  function get_origin_x_misc (
    flit : misc_noc_flit_type)
    return local_yx;

  function get_destination_y_misc (
    flit : misc_noc_flit_type)
    return local_yx;

  function get_destination_x_misc (
    flit : misc_noc_flit_type)
    return local_yx;

  function get_msg_type_misc (
    flit : misc_noc_flit_type)
    return noc_msg_type;

  function get_preamble_misc (
    flit : misc_noc_flit_type)
    return noc_preamble_type;

  function get_reserved_field_misc (
    flit : misc_noc_flit_type)
    return reserved_field_type;

  function get_unused_msb_field_misc (
    flit : misc_noc_flit_type)
    return std_ulogic;

  function is_gets (
    msg : noc_msg_type)
    return boolean;

  function is_getm (
    msg : noc_msg_type)
    return boolean;

  function create_header (
    constant flit_sz : integer;
    local_y          : local_yx;
    local_x          : local_yx;
    remote_y         : local_yx;
    remote_x         : local_yx;
    msg_type         : noc_msg_type;
    reserved         : reserved_field_type)
    return std_logic_vector;

  function create_header_mcast (
    constant flit_sz  : integer;
    local_y           : local_yx;
    local_x           : local_yx;
    remote_y_arr      : yx_vec(MAX_MCAST_DESTS - 2 downto 0);
    remote_x_arr      : yx_vec(MAX_MCAST_DESTS - 2 downto 0);
    remote_y_comb     : local_yx;
    remote_x_comb     : local_yx;
    mcast_ndests      : integer;
    msg_type          : noc_msg_type;
    p2p_mcast_nsrcs   : std_ulogic)
    return mcast_type;

  function narrow_to_large_flit (
    narrow_flit : misc_noc_flit_type)
    return arch_noc_flit_type;

  function large_to_narrow_flit (
    large_flit : arch_noc_flit_type)
    return misc_noc_flit_type;

  function set_router_ports (
    constant TECH     : integer;
    constant CFG_XLEN : integer;
    constant CFG_YLEN : integer;
    constant local_x  : local_yx;
    constant local_y  : local_yx)
    return ports_vec;

  -- IRQ snd packet (Header + 2 flits):
  -- Payload 1
  -- |31    12|11    8|7          7|6        6|5      5|4      4|3   0|
  -- | unused | index | pwdsetaddr | forceerr | rstrun | resume | irl |
  -- Payload 2
  -- |31         2|1      0|
  -- | pwdnewaddr | unused |

  -- IRQ ack packet (Header + 1 flit):
  -- Payload 1
  -- |31    12|11    8|7   7|6    6|5   5|4      4|3   0|
  -- | unused | index | err | fpen | pwd | intack | irl |

  constant IRQ_IRL_MSB        : integer := 3;
  constant IRQ_IRL_LSB        : integer := 0;
  constant IRQ_RESUME_BIT     : integer := 4;
  constant IRQ_RSTRUN_BIT     : integer := 5;
  constant IRQ_FORCEERR_BIT   : integer := 6;
  constant IRQ_PWDSETADDR_BIT : integer := 7;
  constant IRQ_INDEX_LSB      : integer := 8;
  constant IRQ_INDEX_MSB      : integer := 11;

  constant IRQ_PWDNEWADDR_MSB : integer := 31;
  constant IRQ_PWDNEWADDR_LSB : integer := 2;

  constant IRQ_INTACK_BIT : integer := 4;
  constant IRQ_PWD_BIT    : integer := 5;
  constant IRQ_FPEN_BIT   : integer := 6;
  constant IRQ_ERR_BIT    : integer := 7;


end nocpackage;

package body nocpackage is

  function ncpu_log(
    ncpu : integer)
    return integer is
  begin
    if log2(ncpu) = 0 then
      return 1;
    else
      return log2(ncpu);
    end if;
  end;

  function set_mem_id_range
    return integer is
  begin
    if CFG_NMEM_TILE = 0 then
      return 0;
    else
      return CFG_NMEM_TILE - 1;
    end if;
  end;

  function set_slmddr_id_range
    return integer is
  begin
    if CFG_NSLMDDR_TILE = 0 then
      return 0;
    else
      return CFG_NSLMDDR_TILE - 1;
    end if;
  end;

  function get_origin_y (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_origin_y
    ret := (others => '0');
    ret := flit(flit_sz - PREAMBLE_WIDTH - YX_WIDTH + 2 downto flit_sz - PREAMBLE_WIDTH - YX_WIDTH);
    return ret;
  end get_origin_y;

  function get_origin_x (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_origin_x
    ret := (others => '0');
    ret := flit(flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH + 2 downto flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH);
    return ret;
  end get_origin_x;

  function get_destination_y (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_destination_y
    ret := (others => '0');
    ret := flit(flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - YX_WIDTH + 2 downto flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - YX_WIDTH);
    return ret;
  end get_destination_y;

  function get_destination_x (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_destination_x
    ret := (others => '0');
    ret := flit(flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - 2*YX_WIDTH + 2 downto flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - 2*YX_WIDTH);
    return ret;
  end get_destination_x;

  function get_msg_type (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return noc_msg_type is
    variable msg : noc_msg_type;
  begin
    msg := (others => '0');
    msg := flit(flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - 1 downto
                flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH);
    return msg;
  end get_msg_type;

  function get_preamble (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return noc_preamble_type is
    variable ret : noc_preamble_type;
  begin
    ret := flit(flit_sz - 1 downto flit_sz - PREAMBLE_WIDTH);
    return ret;
  end get_preamble;

  function get_reserved_field (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return reserved_field_type is
    variable ret : reserved_field_type;
  begin
    ret := flit(flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - 1 downto
                flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH);
    return ret;
  end get_reserved_field;

  function get_unused_msb_field (
    constant flit_sz : integer;
    flit : max_noc_flit_type)
    return std_ulogic is
    variable ret : std_ulogic;
  begin
    ret := flit(flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH - 1);
    return ret;
  end get_unused_msb_field;

  function get_origin_y_misc (
    flit : misc_noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_origin_y
    ret := (others => '0');
    ret := flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - YX_WIDTH + 2 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - YX_WIDTH);
    return ret;
  end get_origin_y_misc;

  function get_origin_x_misc (
    flit : misc_noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_origin_x
    ret := (others => '0');
    ret := flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 2*YX_WIDTH + 2 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 2*YX_WIDTH);
    return ret;
  end get_origin_x_misc;

  function get_destination_y_misc (
    flit : misc_noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_destination_y
    ret := (others => '0');
    ret := flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 2*YX_WIDTH - YX_WIDTH + 2 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 2*YX_WIDTH - YX_WIDTH);
    return ret;
  end get_destination_y_misc;

  function get_destination_x_misc (
    flit : misc_noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_destination_x
    ret := (others => '0');
    ret := flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 2*YX_WIDTH - 2*YX_WIDTH + 2 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 2*YX_WIDTH - 2*YX_WIDTH);
    return ret;
  end get_destination_x_misc;

  function get_msg_type_misc (
    flit : misc_noc_flit_type)
    return noc_msg_type is
    variable msg : noc_msg_type;
  begin
    msg := (others => '0');
    msg := flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - 1 downto
                MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH);
    return msg;
  end get_msg_type_misc;

  function get_preamble_misc (
    flit : misc_noc_flit_type)
    return noc_preamble_type is
    variable ret : noc_preamble_type;
  begin
    ret := flit(MISC_NOC_FLIT_SIZE - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH);
    return ret;
  end get_preamble_misc;

  function get_reserved_field_misc (
    flit : misc_noc_flit_type)
    return reserved_field_type is
    variable ret : reserved_field_type;
  begin
    ret := flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - 1 downto
                MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH);
    return ret;
  end get_reserved_field_misc;

  function get_unused_msb_field_misc (
    flit : misc_noc_flit_type)
    return std_ulogic is
    variable ret : std_ulogic;
  begin
    ret := flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH - 1);
    return ret;
  end get_unused_msb_field_misc;

  function is_gets (
    msg : noc_msg_type)
    return boolean is
  begin
    if msg = REQ_GETS_W or msg = REQ_GETS_HW or msg = REQ_GETS_B then
      return true;
    else
      return false;
    end if;
  end is_gets;

  function is_getm (
    msg : noc_msg_type)
    return boolean is
  begin
    if msg = REQ_GETM_W or msg = REQ_GETM_HW or msg = REQ_GETM_B then
      return true;
    else
      return false;
    end if;
  end is_getm;

  function create_header (
    constant flit_sz : integer;
    local_y          : local_yx;
    local_x          : local_yx;
    remote_y         : local_yx;
    remote_x         : local_yx;
    msg_type         : noc_msg_type;
    reserved         : reserved_field_type)
    return std_logic_vector is
    variable header                            : std_logic_vector(flit_sz - 1 downto 0);
    variable go_left, go_right, go_up, go_down : std_logic_vector(NEXT_ROUTING_WIDTH - 1 downto 0);
  begin  -- create_header
    header := (others => '0');
    header(flit_sz - 1 downto
           flit_sz - PREAMBLE_WIDTH) := PREAMBLE_HEADER;
    header(flit_sz - PREAMBLE_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - YX_WIDTH) := local_y;
    header(flit_sz - PREAMBLE_WIDTH - YX_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH) := local_x;
    header(flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - 3*YX_WIDTH) := remote_y;
    header(flit_sz - PREAMBLE_WIDTH - 3*YX_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH) := remote_x;
    header(flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH) := msg_type;
    header(flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH) := reserved;

    if local_x < remote_x then
      go_right := "01000";
    else
      go_right := "10111";
    end if;

    if local_x > remote_x then
      go_left := "00100";
    else
      go_left := "11011";
    end if;

    if local_y < remote_y then
      header(NEXT_ROUTING_WIDTH - 1 downto 0) := "01110" and go_left and go_right;
    else
      header(NEXT_ROUTING_WIDTH - 1 downto 0) := "01101" and go_left and go_right;
    end if;

    if local_y = remote_y and local_x = remote_x then
      header(NEXT_ROUTING_WIDTH - 1 downto 0) := "10000";
    end if;

    return header;
  end create_header;

function create_header_mcast (
    constant flit_sz  : integer;
    local_y           : local_yx;
    local_x           : local_yx;
    remote_y_arr      : yx_vec(MAX_MCAST_DESTS - 2 downto 0);
    remote_x_arr      : yx_vec(MAX_MCAST_DESTS - 2 downto 0);
    remote_y_comb     : local_yx;
    remote_x_comb     : local_yx;
    mcast_ndests      : integer;
    msg_type          : noc_msg_type;
    p2p_mcast_nsrcs   : std_ulogic)
    return mcast_type is
    variable mcast_data : mcast_type;
    variable header : std_logic_vector(flit_sz - 1 downto 0);
    variable go_right, go_left, go_up, go_down, routing: std_logic_vector(NEXT_ROUTING_WIDTH - 1 downto 0);
    variable remote_y, remote_x : yx_vec(MAX_MCAST_DESTS - 1 downto 0);
    variable valid_0, valid_1, valid_2, valid_3 : std_logic_vector(MAX_MCAST_DESTS - 1 downto 0);
    constant RESERVED_OFFSET_MCAST : integer := flit_sz - PREAMBLE_WIDTH - NEXT_ROUTING_WIDTH - MSG_TYPE_WIDTH
                                                - (1 + MAX_MCAST_DESTS) * 2 * YX_WIDTH - MAX_MCAST_DESTS;
  begin  -- create_header_ndest

    header := (others => '0');
    mcast_data.header_vec := (others => (others => '0'));
    mcast_data.quad_count := (others => '0');
    remote_y := (others => (others => '0'));
    remote_x := (others => (others => '0'));
    remote_y(MAX_MCAST_DESTS - 2 downto 0) := remote_y_arr;
    remote_x(MAX_MCAST_DESTS - 2 downto 0) := remote_x_arr;
    remote_y(mcast_ndests) := remote_y_comb;
    remote_x(mcast_ndests) := remote_x_comb;

    valid_0 := (others => '0');
    valid_1 := (others => '0');
    valid_2 := (others => '0');
    valid_3 := (others => '0');

    header(flit_sz - 1 downto
           flit_sz - PREAMBLE_WIDTH) := PREAMBLE_HEADER;
    header(flit_sz - PREAMBLE_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - YX_WIDTH) := local_y;
    header(flit_sz - PREAMBLE_WIDTH - YX_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH) := local_x;
    header(flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - 3*YX_WIDTH) := remote_y(0);
    header(flit_sz - PREAMBLE_WIDTH - 3*YX_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH) := remote_x(0);
    header(flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - 1 downto
           flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH) := msg_type;
    for i in 1 to MAX_MCAST_DESTS - 1 loop
      header(flit_sz - PREAMBLE_WIDTH - (4+2*(i-1))*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_OFFSET_MCAST - 1 downto
             flit_sz - PREAMBLE_WIDTH - (5+2*(i-1))*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_OFFSET_MCAST) := remote_y(i);
      header(flit_sz - PREAMBLE_WIDTH - (5+2*(i-1))*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_OFFSET_MCAST - 1 downto
             flit_sz - PREAMBLE_WIDTH - (6+2*(i-1))*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_OFFSET_MCAST) := remote_x(i);
    end loop;

    for i in 0 to MAX_MCAST_DESTS - 1 loop
      if i <= mcast_ndests then
        if local_x < remote_x(i) then
          go_right := "01000";
        else
          go_right := "10111";
        end if;

        if local_x > remote_x(i) then
          go_left := "00100";
        else
          go_left := "11011";
        end if;

        if local_y < remote_y(i) then
          routing := "01110" and go_left and go_right;
        else
          routing := "01101" and go_left and go_right;
        end if;

        if local_y = remote_y(i) and local_x = remote_x(i) then
          routing := "10000";
        end if;
        if p2p_mcast_nsrcs = '1' then	--multi source mcast
          if (local_y >= remote_y(i)) and (local_x < remote_x(i)) then  --top right
            valid_0(i) := '1';
            valid_1(i) := '0';
            valid_2(i) := '0';
            valid_3(i) := '0';
            mcast_data.quad_count(0) := '1';
            mcast_data.header_vec(0)(NEXT_ROUTING_WIDTH-1 downto 0) := mcast_data.header_vec(0)(NEXT_ROUTING_WIDTH-1 downto 0) or routing;
          end if;
          if (local_y > remote_y(i)) and (local_x >= remote_x(i)) then --top left
            valid_0(i) := '0';
            valid_1(i) := '1';
            valid_2(i) := '0';
            valid_3(i) := '0';
            mcast_data.quad_count(1) := '1';
            mcast_data.header_vec(1)(NEXT_ROUTING_WIDTH-1 downto 0) := mcast_data.header_vec(1)(NEXT_ROUTING_WIDTH-1 downto 0) or routing;
          end if;
          if (local_y < remote_y(i)) and (local_x <= remote_x(i)) then --bottom right
            valid_0(i) := '0';
            valid_1(i) := '0';
            valid_2(i) := '1';
            valid_3(i) := '0';
            mcast_data.quad_count(2) := '1';
            mcast_data.header_vec(2)(NEXT_ROUTING_WIDTH-1 downto 0) := mcast_data.header_vec(2)(NEXT_ROUTING_WIDTH-1 downto 0) or routing;
          end if;
          if (local_y <= remote_y(i)) and (local_x > remote_x(i)) then --bottom left
            valid_0(i) := '0';
            valid_1(i) := '0';
            valid_2(i) := '0';
            valid_3(i) := '1';
            mcast_data.quad_count(3) := '1';
            mcast_data.header_vec(3)(NEXT_ROUTING_WIDTH-1 downto 0) := mcast_data.header_vec(3)(NEXT_ROUTING_WIDTH-1 downto 0) or routing;
          end if;
        else	--single source mcast
          header(flit_sz - PREAMBLE_WIDTH - (1 + MAX_MCAST_DESTS) * 2 * YX_WIDTH - MSG_TYPE_WIDTH
                 - MAX_MCAST_DESTS - RESERVED_OFFSET_MCAST + i) := '1';
          header(NEXT_ROUTING_WIDTH-1 downto 0) := header(NEXT_ROUTING_WIDTH-1 downto 0) or routing;
        end if;
      end if;	--if i <= mcast_ndests
    end loop;

    if p2p_mcast_nsrcs = '1' then
      mcast_data.header_vec(0) := header(flit_sz - 1 downto flit_sz - PREAMBLE_WIDTH - (1 + MAX_MCAST_DESTS) * 2 * YX_WIDTH - MSG_TYPE_WIDTH
                                                 - RESERVED_OFFSET_MCAST)
                       & valid_0 &
                       mcast_data.header_vec(0)(NEXT_ROUTING_WIDTH - 1 downto 0);
      mcast_data.header_vec(1) := header(flit_sz - 1 downto flit_sz - PREAMBLE_WIDTH - (1 + MAX_MCAST_DESTS) * 2 * YX_WIDTH - MSG_TYPE_WIDTH
                                                 - RESERVED_OFFSET_MCAST)
                       & valid_1 &
                       mcast_data.header_vec(1)(NEXT_ROUTING_WIDTH - 1 downto 0);
      mcast_data.header_vec(2) := header(flit_sz - 1 downto flit_sz - PREAMBLE_WIDTH - (1 + MAX_MCAST_DESTS) * 2 * YX_WIDTH - MSG_TYPE_WIDTH
                                                 - RESERVED_OFFSET_MCAST)
                       & valid_2 &
                       mcast_data.header_vec(2)(NEXT_ROUTING_WIDTH - 1 downto 0);
      mcast_data.header_vec(3) := header(flit_sz - 1 downto flit_sz - PREAMBLE_WIDTH - (1 + MAX_MCAST_DESTS) * 2 * YX_WIDTH - MSG_TYPE_WIDTH
                                                 - RESERVED_OFFSET_MCAST)
                       & valid_3 &
                       mcast_data.header_vec(3)(NEXT_ROUTING_WIDTH - 1 downto 0);
    else
      mcast_data.header_vec(0) := header;
      mcast_data.header_vec(1) := (others => '0');
      mcast_data.header_vec(2) := (others => '0');
      mcast_data.header_vec(3) := (others => '0');
    end if;

    return mcast_data;
  end create_header_mcast;

  function narrow_to_large_flit (
    narrow_flit : misc_noc_flit_type)
    return arch_noc_flit_type is
    variable ret : arch_noc_flit_type;
    variable preamble : noc_preamble_type;
  begin
    ret := (others => '0');
    preamble := get_preamble(MISC_NOC_FLIT_SIZE, misc_noc_flit_pad & narrow_flit);

    if preamble = PREAMBLE_HEADER or preamble = PREAMBLE_1FLIT then
      ret(ARCH_NOC_FLIT_SIZE - 1 downto ARCH_NOC_FLIT_SIZE - MISC_NOC_FLIT_SIZE + NEXT_ROUTING_WIDTH) :=
        narrow_flit(MISC_NOC_FLIT_SIZE - 1 downto NEXT_ROUTING_WIDTH);
      ret(NEXT_ROUTING_WIDTH - 1 downto 0) := narrow_flit(NEXT_ROUTING_WIDTH - 1 downto 0);
    else
      ret(ARCH_NOC_FLIT_SIZE - 1 downto ARCH_NOC_FLIT_SIZE - PREAMBLE_WIDTH) :=
        narrow_flit(MISC_NOC_FLIT_SIZE - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH);
      ret(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0) :=
        narrow_flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);
    end if;

    return ret;
  end narrow_to_large_flit;

  function large_to_narrow_flit (
    large_flit : arch_noc_flit_type)
    return misc_noc_flit_type is
    variable ret      : misc_noc_flit_type;
    variable preamble : noc_preamble_type;
  begin
    ret := (others => '0');
    preamble := get_preamble(ARCH_NOC_FLIT_SIZE, arch_noc_flit_pad & large_flit);

    if preamble = PREAMBLE_HEADER or preamble = PREAMBLE_1FLIT then
      ret(MISC_NOC_FLIT_SIZE - 1 downto NEXT_ROUTING_WIDTH) :=
        large_flit(ARCH_NOC_FLIT_SIZE - 1 downto ARCH_NOC_FLIT_SIZE - MISC_NOC_FLIT_SIZE + NEXT_ROUTING_WIDTH);
      ret(NEXT_ROUTING_WIDTH - 1 downto 0) := large_flit(NEXT_ROUTING_WIDTH - 1 downto 0);
    else
      ret(MISC_NOC_FLIT_SIZE - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) :=
        large_flit(ARCH_NOC_FLIT_SIZE - 1 downto ARCH_NOC_FLIT_SIZE - PREAMBLE_WIDTH);
      ret(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0) :=
        large_flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);
    end if;

    return ret;
  end large_to_narrow_flit;

----------------------------------------------------------------------------------------
-- Use conditionals of local_x and local_y to find required ports
-- Same port generation must be used in tiles ports
-- This function will go to top and ROUTER_PORTS will be passed through parameter

  function set_router_ports (
    constant TECH     : integer;
    constant CFG_XLEN : integer;
    constant CFG_YLEN : integer;
    constant local_x  : local_yx;
    constant local_y  : local_yx)
    return ports_vec is
    variable ports : ports_vec;
  begin
    -- initialize all local ports set
    ports := (others => '1');
    -- nord ports removed in top tiles
    if local_y = "000" then
      ports(0) := '0';
    end if;
    -- west ports removed in left edge tiles
    if local_x = "000" then
      ports(2) := '0';
    end if;
    if is_fpga(TECH) /= 0 then
      -- On FPGA we want to simplify logic as much as possible.
      -- For ASIC flow, however, we want to minimize the number of tiles that
      -- differ due to router's ports. We assume that routers are placed on the
      -- bottom-right corner of each tile, so leaving east and south ports
      -- enabled won't incur long dangling metal lines. Unused ports should
      -- have inputs tied to VSS, except for void signals, which must be tied
      -- to VDD.

      -- south ports removed in bottom tiles
      if (to_integer(unsigned(local_y))) = CFG_YLEN-1 then
        ports(1) := '0';
      end if;
      -- east ports removed in right edge tiles
      if (to_integer(unsigned(local_x))) = CFG_XLEN-1 then
        ports(3) := '0';
      end if;

    end if;
    return ports;
  end set_router_ports;

end nocpackage;
