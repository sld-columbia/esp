-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2012, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--!  @project      Module Message Interface 64
-- =============================================================================
--!  @file         mmi64_p.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 global declarations package.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Global declarations package for module message interface.
package mmi64_pkg is

  --! width of mmi64 data word (in bit)
  constant MMI64_DATA_WIDTH : natural := 64;

  --! width of mmi64 command (in bit)
  constant MMI64_COMMAND_WIDTH : natural := 8;

  --! length of mmi64 message (in word)
  constant MMI64_MESSAGE_LENGTH : natural := 65535;

  --! maximum number of modules per router
  constant MMI64_MODULES_PER_ROUTER_MAX : natural := 256;

  --! width of mmi64 module type (in bit)
  constant MMI64_MODULE_TYPE_WIDTH : natural := 32;

  --! width of mmi64 module id (in bit)
  constant MMI64_MODULE_ID_WIDTH : natural := 32;

  --! type for data connection to single mmi64 module or router
  subtype mmi64_data_t is std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);

  --! array type for data connection to multiple mmi64 modules or routers
  type mmi64_data_vector_t is array(natural range <>) of mmi64_data_t;

  --! type for mmi64 command
  subtype mmi64_command_t is unsigned(7 downto 0);

  --! type for mmi64 command parameter
  subtype mmi64_command_parameter_t is unsigned(7 downto 0);

  --! type for mmi64 command parameter
  subtype mmi64_payload_length_t is unsigned(15 downto 0);

  --! type for checksum information
  subtype mmi64_checksum_t is std_ulogic_vector(15 downto 0);

  --! type for module addressing through router
  subtype mmi64_module_addr_t is unsigned(7 downto 0);

  --! type for modules unique identifier
  subtype mmi64_module_id_t is bit_vector(MMI64_MODULE_ID_WIDTH-1 downto 0);

  --! type for tag
  subtype mmi64_tag_t is std_ulogic_vector(15 downto 0);

  --! mmi64 header: position of command field
  subtype mmi64_header_command_r           is natural range  7 downto  0;

  --! mmi64 header: position of command parameter field
  subtype mmi64_header_command_parameter_r is natural range 15 downto  8;

  --! mmi64 header: position of command and command parameter field
  subtype mmi64_header_command_and_parameter_r is natural range 15 downto  0;

  --! mmi64 header: position of tag field
  subtype mmi64_header_tag_r               is natural range 31 downto 16;

  --! mmi64 header: position of tag field (low)
  subtype mmi64_header_tag_lo_r            is natural range 23 downto 16;

  --! mmi64 header: position of tag field (high)
  subtype mmi64_header_tag_hi_r            is natural range 31 downto 24;

  --! mmi64 header: position of payload length field
  subtype mmi64_header_payload_length_r    is natural range 47 downto 32;

  --! mmi64 header: position of payload length field (low)
  subtype mmi64_header_payload_length_lo_r is natural range 39 downto 32;

  --! mmi64 header: position of payload length field (high)
  subtype mmi64_header_payload_length_hi_r is natural range 47 downto 40;

  --! mmi64 header: position of header checksum field
  subtype mmi64_header_checksum_r          is natural range 63 downto 48;

  --! mmi64 identify: position of module id field
  subtype mmi64_identify_module_id_r       is natural range 31 downto 0;

  --! mmi64 identify: position of module id field
  subtype mmi64_identify_module_type_r     is natural range 63 downto 32;

  --! type of declaring the number of modules connected to a router
  subtype mmi64_module_range_t is integer range 1 to MMI64_MODULES_PER_ROUTER_MAX-1;

  -- supported mmi64 system commands (reserved range 0x00 to 0x1F)
  constant MMI64_CMD_NOP        : mmi64_command_t := x"00";  --! do nothing
  constant MMI64_CMD_INITIALIZE : mmi64_command_t := x"01";  --! perform mmi64 domain identify operation
  constant MMI64_CMD_IDENTIFY   : mmi64_command_t := x"02";  --! perform mmi64 domain identify operation
  constant MMI64_CMD_LOOPBACK   : mmi64_command_t := x"03";  --! perform mmi64 data loopback operation
  constant MMI64_CMD_ROUTE      : mmi64_command_t := x"04";  --! perform mmi64 route operation

  constant MMI64_ZERO_COMMAND_PARAMETER : mmi64_command_parameter_t := (others=>'0');
  constant MMI64_ZERO_PAYLOAD_LENGTH    : mmi64_payload_length_t    := (others=>'0');

  -- module id codes of all modules provided by Pro Design
  constant MMI64_TID_ROUTER        : unsigned(MMI64_MODULE_TYPE_WIDTH-1 downto 0) := x"00000000";  --! type id code of mmi64_router
  constant MMI64_TID_M_REGIF       : unsigned(MMI64_MODULE_TYPE_WIDTH-1 downto 0) := x"00000001";  --! type id code of mmi64_m_regif
  constant MMI64_TID_M_MEMIF       : unsigned(MMI64_MODULE_TYPE_WIDTH-1 downto 0) := x"00000002";  --! type id code of mmi64_m_memif
  constant MMI64_TID_M_SELECTMAPIF : unsigned(MMI64_MODULE_TYPE_WIDTH-1 downto 0) := x"00000003";  --! type id code of mmi64_m_selectmapif
  constant MMI64_TID_M_MBOX        : unsigned(MMI64_MODULE_TYPE_WIDTH-1 downto 0) := x"00000004";  --! type id code of mmi64_m_mbox
  constant MMI64_TID_M_DEVZERO     : unsigned(MMI64_MODULE_TYPE_WIDTH-1 downto 0) := x"00000005";  --! type id code of mmi64_m_mbox
  constant MMI64_TID_M_AXIM        : unsigned(MMI64_MODULE_TYPE_WIDTH-1 downto 0) := x"00000006";  --! type id code of mmi64_axi_master
  constant MMI64_TID_M_UPSTREAMIF  : unsigned(MMI64_MODULE_TYPE_WIDTH-1 downto 0) := x"00000007";  --! type id code of mmi64_m_upstreamif

  -- update checksum field in mmi64 header data word
  function mmi64_header_checksum_calc (mmi64_header : mmi64_data_t) return mmi64_data_t;

  -- generate mmi64 message header with valid checksum
  function mmi64_header_generate (
    command            : mmi64_command_t;
    command_parameter  : mmi64_command_parameter_t;
    payload_length     : mmi64_payload_length_t;
    tag                : mmi64_tag_t
    )return mmi64_data_t;

  -- generate mmi64 message header with valid checksum (test bench use only)
  function mmi64_header_generate_tb (
    command            : mmi64_command_t;
    command_parameter  : mmi64_command_parameter_t;
    payload_length     : natural;
    tag                : mmi64_tag_t
    )return mmi64_data_t;

  -- check if data word is a valid mmi64 header
  function mmi64_header_is_valid(mmi64_word : mmi64_data_t) return boolean;

  -- return command parameter from mmi64 header
  function mmi64_command(mmi64_header_word : mmi64_data_t) return mmi64_command_t;

  -- return command parameter from mmi64 header
  function mmi64_command_parameter(mmi64_header_word : mmi64_data_t) return mmi64_command_parameter_t;

  -- return payload length information from mmi64 header
  function mmi64_payload_length(mmi64_header_word : mmi64_data_t) return mmi64_payload_length_t;

  -- return tag from mmi64 header
  function mmi64_tag(mmi64_header_word : mmi64_data_t) return mmi64_tag_t;

  -- return checksum from mmi64 header
  function mmi64_checksum(mmi64_header_word : mmi64_data_t) return mmi64_checksum_t;

  -- return single byte from mmi64 data word
  function mmi64_data_get_byte(mmi64_data : mmi64_data_t; byte_index : natural) return std_ulogic_vector;
  
  -- convert module_id from bit_vector into std_ulogic_vector
  function convert(bv : bit_vector) return std_ulogic_vector;

end package mmi64_pkg;

package body mmi64_pkg is

  -- update checksum field in mmi64 header data word
  function mmi64_header_checksum_calc (mmi64_header : mmi64_data_t) return mmi64_data_t is
    variable mmi64_checksum_v                   : mmi64_checksum_t;
    variable mmi64_header_with_updated_checksum : mmi64_data_t;
  begin
    -- calculate mmi64 checksum
    mmi64_checksum_v := not (
      mmi64_header(mmi64_header_command_and_parameter_r) xor
      mmi64_header(mmi64_header_payload_length_r) xor
      mmi64_header(mmi64_header_tag_r)
      );

    -- insert checksum into mmi64 header word
    mmi64_header_with_updated_checksum := mmi64_header;
    mmi64_header_with_updated_checksum(mmi64_header_checksum_r) := std_ulogic_vector(mmi64_checksum_v);

    return mmi64_header_with_updated_checksum;
  end function mmi64_header_checksum_calc;

  -- generate mmi64 message header with valid checksum
  function mmi64_header_generate (
    command            : mmi64_command_t;
    command_parameter  : mmi64_command_parameter_t;
    payload_length     : mmi64_payload_length_t;
    tag                : mmi64_tag_t
    )return mmi64_data_t is
    variable mmi64_header_v : mmi64_data_t;
    variable mmi64_header_with_updated_checksum_v : mmi64_data_t;
  begin
    -- prepare the header
    mmi64_header_v(mmi64_header_command_r)           := std_ulogic_vector(command);
    mmi64_header_v(mmi64_header_command_parameter_r) := std_ulogic_vector(command_parameter);
    mmi64_header_v(mmi64_header_payload_length_r)    := std_ulogic_vector(payload_length);
    mmi64_header_v(mmi64_header_tag_r)               := tag;

    -- update header checksum
    mmi64_header_with_updated_checksum_v := mmi64_header_checksum_calc(mmi64_header_v);

    return mmi64_header_with_updated_checksum_v;

  end function mmi64_header_generate;

  -- generate mmi64 message header with valid checksum (test bench use only)
  function mmi64_header_generate_tb (
    command            : mmi64_command_t;
    command_parameter  : mmi64_command_parameter_t;
    payload_length     : natural;
    tag                : mmi64_tag_t
    ) return mmi64_data_t is
  begin
    return mmi64_header_generate (
      command,
      command_parameter,
      to_unsigned(payload_length, mmi64_payload_length_t'length),
      tag);
  end function mmi64_header_generate_tb;

  -- check if data word is valid mmi64 header
  function mmi64_header_is_valid(mmi64_word : mmi64_data_t) return boolean is
    variable mmi64_header_with_reference_checksum_v : mmi64_data_t;
    variable checksum_ok_v : boolean;
  begin
    -- calculate reference checksum
    mmi64_header_with_reference_checksum_v := mmi64_header_checksum_calc(mmi64_word);

    -- compare actual and reference checksum
    checksum_ok_v := (mmi64_word(mmi64_header_checksum_r) = mmi64_header_with_reference_checksum_v(mmi64_header_checksum_r));

    return checksum_ok_v;

  end function mmi64_header_is_valid;

  -- return command parameter from mmi64 header
  function mmi64_command(mmi64_header_word : mmi64_data_t) return mmi64_command_t is
    variable mmi64_command_v : mmi64_command_t;
  begin
    mmi64_command_v := unsigned(mmi64_header_word(mmi64_header_command_r));
    return mmi64_command_v;
  end function mmi64_command;

  -- return command parameter from mmi64 header
  function mmi64_command_parameter(mmi64_header_word : mmi64_data_t) return mmi64_command_parameter_t is
    variable mmi64_command_parameter_v : mmi64_command_parameter_t;
  begin
    mmi64_command_parameter_v := unsigned(mmi64_header_word(mmi64_header_command_parameter_r));
    return mmi64_command_parameter_v;
  end function mmi64_command_parameter;

  -- return payload length information from mmi64 header
  function mmi64_payload_length(mmi64_header_word : mmi64_data_t) return mmi64_payload_length_t is
    variable mmi64_payload_length_v : mmi64_payload_length_t;
  begin
    mmi64_payload_length_v := unsigned(mmi64_header_word(mmi64_header_payload_length_r));
    return mmi64_payload_length_v;
  end function mmi64_payload_length;

  -- return tag from mmi64 header
  function mmi64_tag(mmi64_header_word : mmi64_data_t) return mmi64_tag_t is
    variable mmi64_tag_v : mmi64_tag_t;
  begin
    mmi64_tag_v := mmi64_header_word(mmi64_header_tag_r);
    return mmi64_tag_v;
  end function mmi64_tag;

  -- return checksum from mmi64 header
  function mmi64_checksum(mmi64_header_word : mmi64_data_t) return mmi64_checksum_t is
    variable mmi64_checksum_v : mmi64_checksum_t;
  begin
    mmi64_checksum_v := mmi64_header_word(mmi64_header_checksum_r);
    return mmi64_checksum_v;
  end function mmi64_checksum;

  -- return single byte from mmi64 data word
  function mmi64_data_get_byte(mmi64_data : mmi64_data_t; byte_index: natural) return std_ulogic_vector is
    variable result_v : std_ulogic_vector(7 downto 0);
    variable bit_offs_v : natural;
  begin
    bit_offs_v := 8 * byte_index;
    return mmi64_data(bit_offs_v+7 downto bit_offs_v);
  end function mmi64_data_get_byte;

  -- convert from bit_vector into std_ulogic_vector
  function convert(bv : bit_vector) return std_ulogic_vector is
  variable slv : std_ulogic_vector(bv'range);
  begin
    for i in bv'range loop
      if bv(i)='0' then
        slv(i) := '0';
      else
        slv(i) := '1';
      end if;
    end loop;
    return slv;
  end function convert;

end mmi64_pkg;
