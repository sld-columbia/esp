------------------------------------------------------------------------------
--  This file is part of an extension to the GRLIB VHDL IP library.
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
--
--  GRLIP is a Copyright (C) 2008 - 2013, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity:  nocpackage
-- File:    nocpackage.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description:	NoC constants declaration
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

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
  -- |33        32|31     27|26     22|21     17|16     12|11          9|8          5|4   0|
  -- |  PREAMBLE  |  Src Y  |  Src X  |  Dst Y  |  Dst X  |  Msg. type  |  Reserved  |LEWSN|
  --

  constant HEADER_ROUTE_L : natural := 4;
  constant HEADER_ROUTE_E : natural := 3;
  constant HEADER_ROUTE_W : natural := 2;
  constant HEADER_ROUTE_S : natural := 1;
  constant HEADER_ROUTE_N : natural := 0;

  constant PREAMBLE_WIDTH      : natural := 2;
  constant YX_WIDTH            : natural := 5;
  constant MSG_TYPE_WIDTH      : natural := 3;
  constant RESERVED_WIDTH      : natural := 4;
  constant NEXT_ROUTING_WIDTH  : natural := 5;
  constant NOC_FLIT_SIZE       : natural := PREAMBLE_WIDTH+
                                            4*YX_WIDTH+
                                            MSG_TYPE_WIDTH+
                                            RESERVED_WIDTH+
                                            NEXT_ROUTING_WIDTH;

  subtype local_yx is std_logic_vector(2 downto 0);
  subtype noc_preamble_type is std_logic_vector(PREAMBLE_WIDTH-1 downto 0);
  subtype noc_msg_type is std_logic_vector(MSG_TYPE_WIDTH-1 downto 0);
  subtype noc_flit_type is std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
  subtype reserved_field_type is std_logic_vector(RESERVED_WIDTH-1 downto 0);

  type noc_flit_vector is array (natural range <>) of noc_flit_type;

  -- Preamble encoding
  constant PREAMBLE_HEADER : noc_preamble_type := "10";
  constant PREAMBLE_TAIL   : noc_preamble_type := "01";
  constant PREAMBLE_BODY   : noc_preamble_type := "00";
  constant PREAMBLE_1FLIT  : noc_preamble_type := "11";

  -- Message type encoding
  -- Cachable data plane 1 -> request messages
  constant REQ_GETS_B   : noc_msg_type := "000";  --Get Shared (Byte)
  constant REQ_GETS_HW  : noc_msg_type := "001";  --Get Shared (Half Word)
  constant REQ_GETS_W   : noc_msg_type := "010";  --Get Shared (word)
  constant REQ_GETM_B   : noc_msg_type := "011";  --Get Modified (Byte)
  constant REQ_GETM_HW  : noc_msg_type := "100";  --Get Modified (Half word)
  constant REQ_GETM_W   : noc_msg_type := "101";  --Get Modified (word)
  constant REQ_PUTS     : noc_msg_type := "110";  --Put Shared/Exclusive
  constant REQ_PUTM     : noc_msg_type := "111";  --Put Modified
  -- Cachable data plane 2 -> forwarded messages
  constant FWD_GETS     : noc_msg_type := "000";
  constant FWD_GETM     : noc_msg_type := "001";
  constant FWD_INV      : noc_msg_type := "010";  --Invalidation
  constant FWD_PUT_ACK  : noc_msg_type := "011";  --Put Acknowledge
  -- Cachable data plane 3 -> response messages
  constant RSP_DATA     : noc_msg_type := "000";  --CacheLine
  --constant RSP_EDATA    : noc_msg_type := "001";  --Cache Line (Exclusive)
  constant RSP_INV_ACK  : noc_msg_type := "010";  --Invalidation Acknowledge
  -- Non cachable data data plane 4 -> DMA transfers
  constant DMA_TO_DEV   : noc_msg_type := "001";
  constant DMA_FROM_DEV : noc_msg_type := "010";
  -- Configuration plane 5 -> RD/WR registers
  constant REQ_REG_RD   : noc_msg_type := "000";
  constant REQ_REG_WR   : noc_msg_type := "001";
  constant AHB_RD       : noc_msg_type := "010";
  constant AHB_WR       : noc_msg_type := "011";
  constant IRQ_MSG      : noc_msg_type := "100";
  constant RSP_REG_RD   : noc_msg_type := "101";
  constant INTERRUPT    : noc_msg_type := "111";

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
    hmask => 16#000#
    );

  -- TODO: For now we only support 2 memory controllers and one frame buffer
  type tile_mem_info_vector is array (2 downto 0) of tile_mem_info;

  -- Components
  component fifo
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

  component sync_noc_transmitter
    generic (
      DATA_WIDTH : integer := NOC_FLIT_SIZE);
    port(
      clock             : in std_logic;
      reset             : in std_logic;
      valid_in          : in std_logic;
      ack               : in std_logic;
      data_in           : in std_logic_vector(DATA_WIDTH-1 downto 0);
      chnl_stop         : in std_logic;
      req               : out std_logic;
      data_out          : out std_logic_vector(DATA_WIDTH-1 downto 0);
      stop_in           : out std_logic);
  end component;

  component sync_transmitter
    generic (
      DATA_WIDTH : integer := NOC_FLIT_SIZE);
    port(
      clock		: in std_logic;
      reset		: in std_logic;
      valid_in		: in std_logic;
      ack		: in std_logic;
      data_in 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
      chnl_stop		: in std_logic;
      req       	: out std_logic;
      data_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
      stop_in		: out std_logic);
  end component;

  component sync_receiver
    generic (
      DATA_WIDTH : integer := NOC_FLIT_SIZE);
    port(
      clock		: in std_logic;
      reset		: in std_logic;
      req		: in std_logic;
      data_in 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
      stop_out		: in std_logic;
      ack		: out std_logic;
      data_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
      valid_out		: out std_logic;
      chnl_stop		: out std_logic);
  end component;

  component sync_noc_receiver
    generic (
      DATA_WIDTH : integer := NOC_FLIT_SIZE);
    port(
      clock             : in std_logic;
      reset             : in std_logic;
      req               : in std_logic;
      data_in           : in std_logic_vector(DATA_WIDTH-1 downto 0);
      stop_out          : in std_logic;
      ack               : out std_logic;
      data_out          : out std_logic_vector(DATA_WIDTH-1 downto 0);
      valid_out         : out std_logic;
      chnl_stop         : out std_logic);
  end component;

  component inferred_async_fifo
    generic (
      g_data_width : natural := NOC_FLIT_SIZE;
      g_size       : natural := 6);
    port (
      rst_n_i    : in  std_logic := '1';
      clk_wr_i   : in  std_logic;
      we_i       : in  std_logic;
      d_i        : in  std_logic_vector(g_data_width-1 downto 0);
      wr_full_o  : out std_logic;
      clk_rd_i   : in  std_logic;
      rd_i       : in  std_logic;
      q_o        : out std_logic_vector(g_data_width-1 downto 0);
      rd_empty_o : out std_logic);
  end component;

  -- Helper functions
  function get_origin_y (
    flit : noc_flit_type)
    return local_yx;

  function get_origin_x (
    flit : noc_flit_type)
    return local_yx;

  function get_msg_type (
    flit : noc_flit_type)
    return noc_msg_type;

  function get_preamble (
    flit : noc_flit_type)
    return noc_preamble_type;

  function get_reserved_field (
    flit : noc_flit_type)
    return reserved_field_type;

  function is_gets (
    msg : noc_msg_type)
    return boolean;

  function is_getm (
    msg : noc_msg_type)
    return boolean;

  function create_header (
    local_y           : local_yx;
    local_x           : local_yx;
    remote_y          : local_yx;
    remote_x          : local_yx;
    msg_type          : noc_msg_type;
    reserved          : reserved_field_type)
    return noc_flit_type;


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

  function get_origin_y (
    flit : noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_origin_y
    ret := flit(29 downto 27);
    return ret;
  end get_origin_y;

  function get_origin_x (
    flit : noc_flit_type)
    return local_yx is
    variable ret : local_yx;
  begin  -- get_origin_y
    ret := flit(24 downto 22);
    return ret;
  end get_origin_x;

  function get_msg_type (
    flit : noc_flit_type)
    return noc_msg_type is
    variable msg : noc_msg_type;
  begin
    msg := flit(NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - 1 downto
                NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH);
    return msg;
  end get_msg_type;

  function get_preamble (
    flit : noc_flit_type)
    return noc_preamble_type is
    variable ret : noc_preamble_type;
  begin
    ret := flit(NOC_FLIT_SIZE - 1 downto NOC_FLIT_SIZE - PREAMBLE_WIDTH);
    return ret;
  end get_preamble;

  function get_reserved_field (
    flit : noc_flit_type)
    return reserved_field_type is
    variable ret : reserved_field_type;
  begin
    ret := flit(NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - 1 downto
                NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH);
    return ret;
  end get_reserved_field;

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
    local_y           : local_yx;
    local_x           : local_yx;
    remote_y          : local_yx;
    remote_x          : local_yx;
    msg_type          : noc_msg_type;
    reserved          : reserved_field_type)
    return noc_flit_type is
    variable header : std_logic_vector(NOC_FLIT_SIZE - 1 downto 0);
    variable go_left, go_right, go_up, go_down : std_logic_vector(NEXT_ROUTING_WIDTH - 1 downto 0);
  begin  -- create_header
    header := (others => '0');
    header(NOC_FLIT_SIZE - 1 downto
           NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_HEADER;
    header(NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto
           NOC_FLIT_SIZE - PREAMBLE_WIDTH - YX_WIDTH) := "00" & local_y;
    header(NOC_FLIT_SIZE - PREAMBLE_WIDTH - YX_WIDTH - 1 downto
           NOC_FLIT_SIZE - PREAMBLE_WIDTH - 2*YX_WIDTH) := "00" & local_x;
    header(NOC_FLIT_SIZE - PREAMBLE_WIDTH - 2*YX_WIDTH - 1 downto
           NOC_FLIT_SIZE - PREAMBLE_WIDTH - 3*YX_WIDTH) := "00" & remote_y;
    header(NOC_FLIT_SIZE - PREAMBLE_WIDTH - 3*YX_WIDTH - 1 downto
           NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH) := "00" & remote_x;
    header(NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - 1 downto
           NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH) := msg_type;
    header(NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - 1 downto
           NOC_FLIT_SIZE - PREAMBLE_WIDTH - 4*YX_WIDTH - MSG_TYPE_WIDTH - RESERVED_WIDTH) := reserved;

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


end nocpackage;
