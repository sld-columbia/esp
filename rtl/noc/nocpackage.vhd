-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
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
  constant NOC_FLIT_SIZE       : natural := PREAMBLE_WIDTH + ARCH_BITS;
  constant MISC_NOC_FLIT_SIZE  : natural := PREAMBLE_WIDTH + 32;

  subtype local_yx is std_logic_vector(2 downto 0);
  subtype noc_preamble_type is std_logic_vector(PREAMBLE_WIDTH-1 downto 0);
  subtype noc_msg_type is std_logic_vector(MSG_TYPE_WIDTH-1 downto 0);
  subtype noc_flit_type is std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
  subtype misc_noc_flit_type is std_logic_vector(33 downto 0);
  subtype reserved_field_type is std_logic_vector(RESERVED_WIDTH-1 downto 0);
  subtype ports_vec is std_logic_vector(4 downto 0);

  type noc_flit_vector is array (natural range <>) of noc_flit_type;
  type misc_noc_flit_vector is array (natural range <>) of misc_noc_flit_type;

  constant noc_flit_pad : std_logic_vector(NOC_FLIT_SIZE - MISC_NOC_FLIT_SIZE - 1 downto 0) := (others => '0');

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
      clk         : in  std_logic;
      rst         : in  std_logic;
      rdreq       : in  std_logic;
      wrreq       : in  std_logic;
      data_in     : in  std_logic_vector(width-1 downto 0);
      empty       : out std_logic;
      full        : out std_logic;
      atleast_4slots  : out std_logic;
      exactly_3slots  : out std_logic;
      data_out    : out std_logic_vector(width-1 downto 0));
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
      g_data_width : natural := NOC_FLIT_SIZE;
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
      noc1_data_n_in     : in  noc_flit_type;
      noc1_data_s_in     : in  noc_flit_type;
      noc1_data_w_in     : in  noc_flit_type;
      noc1_data_e_in     : in  noc_flit_type;
      noc1_input_port    : in  noc_flit_type;
      noc1_data_void_in  : in  std_logic_vector(4 downto 0);
      noc1_stop_in       : in  std_logic_vector(4 downto 0);
      noc1_data_n_out    : out noc_flit_type;
      noc1_data_s_out    : out noc_flit_type;
      noc1_data_w_out    : out noc_flit_type;
      noc1_data_e_out    : out noc_flit_type;
      noc1_output_port   : out noc_flit_type;
      noc1_data_void_out : out std_logic_vector(4 downto 0);
      noc1_stop_out      : out std_logic_vector(4 downto 0);
      noc2_data_n_in     : in  noc_flit_type;
      noc2_data_s_in     : in  noc_flit_type;
      noc2_data_w_in     : in  noc_flit_type;
      noc2_data_e_in     : in  noc_flit_type;
      noc2_input_port    : in  noc_flit_type;
      noc2_data_void_in  : in  std_logic_vector(4 downto 0);
      noc2_stop_in       : in  std_logic_vector(4 downto 0);
      noc2_data_n_out    : out noc_flit_type;
      noc2_data_s_out    : out noc_flit_type;
      noc2_data_w_out    : out noc_flit_type;
      noc2_data_e_out    : out noc_flit_type;
      noc2_output_port   : out noc_flit_type;
      noc2_data_void_out : out std_logic_vector(4 downto 0);
      noc2_stop_out      : out std_logic_vector(4 downto 0);
      noc3_data_n_in     : in  noc_flit_type;
      noc3_data_s_in     : in  noc_flit_type;
      noc3_data_w_in     : in  noc_flit_type;
      noc3_data_e_in     : in  noc_flit_type;
      noc3_input_port    : in  noc_flit_type;
      noc3_data_void_in  : in  std_logic_vector(4 downto 0);
      noc3_stop_in       : in  std_logic_vector(4 downto 0);
      noc3_data_n_out    : out noc_flit_type;
      noc3_data_s_out    : out noc_flit_type;
      noc3_data_w_out    : out noc_flit_type;
      noc3_data_e_out    : out noc_flit_type;
      noc3_output_port   : out noc_flit_type;
      noc3_data_void_out : out std_logic_vector(4 downto 0);
      noc3_stop_out      : out std_logic_vector(4 downto 0);
      noc4_data_n_in     : in  noc_flit_type;
      noc4_data_s_in     : in  noc_flit_type;
      noc4_data_w_in     : in  noc_flit_type;
      noc4_data_e_in     : in  noc_flit_type;
      noc4_input_port    : in  noc_flit_type;
      noc4_data_void_in  : in  std_logic_vector(4 downto 0);
      noc4_stop_in       : in  std_logic_vector(4 downto 0);
      noc4_data_n_out    : out noc_flit_type;
      noc4_data_s_out    : out noc_flit_type;
      noc4_data_w_out    : out noc_flit_type;
      noc4_data_e_out    : out noc_flit_type;
      noc4_output_port   : out noc_flit_type;
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
      noc6_data_n_in     : in  noc_flit_type;
      noc6_data_s_in     : in  noc_flit_type;
      noc6_data_w_in     : in  noc_flit_type;
      noc6_data_e_in     : in  noc_flit_type;
      noc6_input_port    : in  noc_flit_type;
      noc6_data_void_in  : in  std_logic_vector(4 downto 0);
      noc6_stop_in       : in  std_logic_vector(4 downto 0);
      noc6_data_n_out    : out noc_flit_type;
      noc6_data_s_out    : out noc_flit_type;
      noc6_data_w_out    : out noc_flit_type;
      noc6_data_e_out    : out noc_flit_type;
      noc6_output_port   : out noc_flit_type;
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
    flit : noc_flit_type)
    return local_yx;

  function get_origin_x (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return local_yx;

  function get_destination_y (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return local_yx;

  function get_destination_x (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return local_yx;

  function get_msg_type (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return noc_msg_type;

  function get_preamble (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return noc_preamble_type;

  function get_reserved_field (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return reserved_field_type;

  function get_unused_msb_field (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return std_ulogic;

  function is_gets (
    msg : noc_msg_type)
    return boolean;

  function is_getm (
    msg : noc_msg_type)
    return boolean;

  function create_header (
    constant flit_sz : integer;
    local_y           : local_yx;
    local_x           : local_yx;
    remote_y          : local_yx;
    remote_x          : local_yx;
    msg_type          : noc_msg_type;
    reserved          : reserved_field_type)
    return std_logic_vector;

  function narrow_to_large_flit (
    narrow_flit : misc_noc_flit_type)
    return noc_flit_type;

  function large_to_narrow_flit (
    large_flit : noc_flit_type)
    return misc_noc_flit_type;

  function set_router_ports (
    constant TECH : integer;
    constant CFG_XLEN : integer;
    constant CFG_YLEN : integer;
    constant local_x : local_yx;
    constant local_y : local_yx)
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
    flit : noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_origin_y
    ret := (others => '0');
    ret := flit(flit_sz - PREAMBLE_WIDTH - YX_WIDTH + 2 downto flit_sz - PREAMBLE_WIDTH - YX_WIDTH);
    return ret;
  end get_origin_y;

  function get_origin_x (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_origin_x
    ret := (others => '0');
    ret := flit(flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH + 2 downto flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH);
    return ret;
  end get_origin_x;

  function get_destination_y (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_destination_y
    ret := (others => '0');
    ret := flit(flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - YX_WIDTH + 2 downto flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - YX_WIDTH);
    return ret;
  end get_destination_y;

  function get_destination_x (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_destination_x
    ret := (others => '0');
    ret := flit(flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - 2*YX_WIDTH + 2 downto flit_sz - PREAMBLE_WIDTH - 2*YX_WIDTH - 2*YX_WIDTH);
    return ret;
  end get_destination_x;

  function get_msg_type (
    constant flit_sz : integer;
    flit : noc_flit_type)
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
    flit : noc_flit_type)
    return noc_preamble_type is
    variable ret : noc_preamble_type;
  begin
    ret := flit(flit_sz - 1 downto flit_sz - PREAMBLE_WIDTH);
    return ret;
  end get_preamble;

  function get_reserved_field (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return reserved_field_type is
    variable ret : reserved_field_type;
  begin
    ret := flit(flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - 1 downto
                flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH);
    return ret;
  end get_reserved_field;

  function get_unused_msb_field (
    constant flit_sz : integer;
    flit : noc_flit_type)
    return std_ulogic is
    variable ret : std_ulogic;
  begin
    ret := flit(flit_sz - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH - 1);
    return ret;
  end get_unused_msb_field;


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
    local_y           : local_yx;
    local_x           : local_yx;
    remote_y          : local_yx;
    remote_x          : local_yx;
    msg_type          : noc_msg_type;
    reserved          : reserved_field_type)
    return std_logic_vector is
    variable header : std_logic_vector(flit_sz - 1 downto 0);
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

  function narrow_to_large_flit (
    narrow_flit : misc_noc_flit_type)
    return noc_flit_type is
    variable ret : noc_flit_type;
    variable preamble : noc_preamble_type;
  begin
    ret := (others => '0');
    preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & narrow_flit);

    if preamble = PREAMBLE_HEADER or preamble = PREAMBLE_1FLIT then
      ret(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - MISC_NOC_FLIT_SIZE + NEXT_ROUTING_WIDTH) :=
        narrow_flit(MISC_NOC_FLIT_SIZE - 1 downto NEXT_ROUTING_WIDTH);
      ret(NEXT_ROUTING_WIDTH - 1 downto 0) := narrow_flit(NEXT_ROUTING_WIDTH - 1 downto 0);
    else
      ret(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH) :=
        narrow_flit(MISC_NOC_FLIT_SIZE - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH);
      ret(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0) :=
        narrow_flit(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);
    end if;

    return ret;
  end narrow_to_large_flit;

  function large_to_narrow_flit (
    large_flit : noc_flit_type)
    return misc_noc_flit_type is
    variable ret : misc_noc_flit_type;
    variable preamble : noc_preamble_type;
  begin
    ret := (others => '0');
    preamble := get_preamble(NOC_FLIT_SIZE, large_flit);

    if preamble = PREAMBLE_HEADER or preamble = PREAMBLE_1FLIT then
      ret(MISC_NOC_FLIT_SIZE - 1 downto NEXT_ROUTING_WIDTH) :=
        large_flit(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - MISC_NOC_FLIT_SIZE + NEXT_ROUTING_WIDTH);
      ret(NEXT_ROUTING_WIDTH - 1 downto 0) := large_flit(NEXT_ROUTING_WIDTH - 1 downto 0);
    else
      ret(MISC_NOC_FLIT_SIZE - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) :=
        large_flit(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH);
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
    constant TECH : integer;
    constant CFG_XLEN : integer;
    constant CFG_YLEN : integer;
    constant local_x : local_yx;
    constant local_y : local_yx)
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
