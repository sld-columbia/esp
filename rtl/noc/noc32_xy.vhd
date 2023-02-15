-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- Module:      noc_xy
-- Description: Mesh of x columns by y rows RTL routers
--
-- Author:      Paolo Mantovani @ Columbia University
-------------------------------------------------------------------------------
--
-- Addressing is XY; X: from left to right, Y: from top to bottom
--
-- Local mapping for the latency insensitive protocol
-- 0 = North
-- 1 = South
-- 2 = West
-- 3 = East
-- 4 = Local tile
--
-- Check the module "router" in router.vhd for details on routing algorithm
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.monitor_pkg.all;
use work.nocpackage.all;

entity noc32_xy is
  generic (
    XLEN      : integer;
    YLEN      : integer;
    TILES_NUM : integer);
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    input_port    : in  misc_noc_flit_vector(TILES_NUM-1 downto 0);
    data_void_in  : in  std_logic_vector(TILES_NUM-1 downto 0);
    stop_in       : in  std_logic_vector(TILES_NUM-1 downto 0);
    output_port   : out misc_noc_flit_vector(TILES_NUM-1 downto 0);
    data_void_out : out std_logic_vector(TILES_NUM-1 downto 0);
    stop_out      : out std_logic_vector(TILES_NUM-1 downto 0);
    -- Monitor output. Can be left unconnected
    mon_noc       : out monitor_noc_vector(0 to TILES_NUM-1)
    );

end noc32_xy;

architecture mesh of noc32_xy is

  type ports_vec is array (TILES_NUM-1 downto 0) of std_logic_vector(4 downto 0);
  type local_vec is array (TILES_NUM-1 downto 0) of local_yx;
  type handshake_vec is array (TILES_NUM-1 downto 0) of
    std_logic_vector(4 downto 0);

  function set_router_ports(
    constant XLEN : integer;
    constant YLEN : integer)
    return ports_vec is
    variable ports : ports_vec;
  begin
    ports := (others => (others => '0'));
    --   0,0    - 0,1 - 0,2 - ... -    0,XLEN-1
    --    |        |     |     |          |
    --   1,0    - ...   ...   ... -    1,XLEN-1
    --    |        |     |     |          |
    --   ...    - ...   ...   ... -      ...
    --    |        |     |     |          |
    -- YLEN-1,0 - ...   ...   ... - YLEN-1,XLEN-1
    for i in 0 to YLEN-1 loop
      for j in 0 to XLEN-1 loop
        -- local ports are all set
        ports(i * XLEN + j)(4) := '1';
        if j /= XLEN-1 then
          -- east ports
          ports(i * XLEN + j)(3) := '1';
        end if;
        if j /= 0 then
          -- west ports
          ports(i * XLEN + j)(2) := '1';
        end if;
        if i /= YLEN-1 then
          -- south ports
          ports(i * XLEN + j)(1) := '1';
        end if;
        if i /= 0 then
          -- nord ports
          ports(i * XLEN + j)(0) := '1';
        end if;
      end loop;  -- j
    end loop;  -- i
    return ports;
  end set_router_ports;

  function set_tile_x (
    constant XLEN : integer;
    constant YLEN : integer;
    constant id_bits  : integer)
    return local_vec is
    variable x : local_vec;
  begin  -- set_tile_id
    for i in 0 to YLEN-1 loop
      for j in 0 to XLEN-1 loop
        x(i * XLEN + j) := conv_std_logic_vector(j, id_bits);
      end loop;  -- j
    end loop;  -- i
    return x;
  end set_tile_x;

  function set_tile_y (
    constant XLEN : integer;
    constant YLEN : integer;
    constant id_bits  : integer)
    return local_vec is
    variable y : local_vec;
  begin  -- set_tile_id
    for i in 0 to YLEN-1 loop
      for j in 0 to XLEN-1 loop
        y(i * XLEN + j) := conv_std_logic_vector(i, id_bits);
      end loop;  -- j
    end loop;  -- i
    return y;
  end set_tile_y;

  constant ROUTER_PORTS : ports_vec := set_router_ports(XLEN, YLEN);
  constant localx       : local_vec := set_tile_x(XLEN, YLEN, 3);
  constant localy       : local_vec := set_tile_y(XLEN, YLEN, 3);

  component router
    generic (
      flow_control : integer;
      width        : integer;
      depth        : integer;
      ports        : std_logic_vector(4 downto 0);
      localx       : std_logic_vector(2 downto 0);
      localy       : std_logic_vector(2 downto 0));

    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      data_n_in     : in  std_logic_vector(width-1 downto 0);
      data_s_in     : in  std_logic_vector(width-1 downto 0);
      data_w_in     : in  std_logic_vector(width-1 downto 0);
      data_e_in     : in  std_logic_vector(width-1 downto 0);
      data_p_in     : in  std_logic_vector(width-1 downto 0);
      data_void_in  : in  std_logic_vector(4 downto 0);
      stop_in       : in  std_logic_vector(4 downto 0);
      data_n_out    : out std_logic_vector(width-1 downto 0);
      data_s_out    : out std_logic_vector(width-1 downto 0);
      data_w_out    : out std_logic_vector(width-1 downto 0);
      data_e_out    : out std_logic_vector(width-1 downto 0);
      data_p_out    : out std_logic_vector(width-1 downto 0);
      data_void_out : out std_logic_vector(4 downto 0);
      stop_out      : out std_logic_vector(4 downto 0));
  end component;

  signal data_n_in     : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_s_in     : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_w_in     : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_e_in     : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_p_in     : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_void_in_i  : handshake_vec;
  signal stop_in_i       : handshake_vec;
  signal data_n_out    : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_s_out    : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_w_out    : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_e_out    : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_p_out    : misc_noc_flit_vector(TILES_NUM-1 downto 0);
  signal data_void_out_i : handshake_vec;
  signal stop_out_i      : handshake_vec;


begin  -- mesh


  meshgen_y: for i in 0 to YLEN-1 generate
    meshgen_x: for j in 0 to XLEN-1 generate

      y_0: if (i=0) generate
        -- North port is unconnected
        data_n_in(i*XLEN + j) <= (others => '0');
        data_void_in_i(i*XLEN + j)(0) <= '1';
        stop_in_i(i*XLEN + j)(0) <= '0';
      end generate y_0;

      y_non_0: if (i /= 0) generate
        -- North port is connected
        data_n_in(i*XLEN + j) <= data_s_out((i-1)*XLEN + j);
        data_void_in_i(i*XLEN + j)(0) <= data_void_out_i((i-1)*XLEN + j)(1);
        stop_in_i(i*XLEN + j)(0) <= stop_out_i((i-1)*XLEN + j)(1);
      end generate y_non_0;

      y_YLEN: if (i=YLEN-1) generate
        -- South port is unconnected
        data_s_in(i*XLEN + j) <= (others => '0');
        data_void_in_i(i*XLEN + j)(1) <= '1';
        stop_in_i(i*XLEN + j)(1) <= '0';
      end generate y_YLEN;

      y_non_YLEN: if (i /= YLEN-1) generate
        -- south port is connected
        data_s_in(i*XLEN + j) <= data_n_out((i+1)*XLEN + j);
        data_void_in_i(i*XLEN + j)(1) <= data_void_out_i((i+1)*XLEN + j)(0);
        stop_in_i(i*XLEN + j)(1) <= stop_out_i((i+1)*XLEN + j)(0);
      end generate y_non_YLEN;

      x_0: if (j=0) generate
        -- West port is unconnected
        data_w_in(i*XLEN + j) <= (others => '0');
        data_void_in_i(i*XLEN + j)(2) <= '1';
        stop_in_i(i*XLEN + j)(2) <= '0';
      end generate x_0;

      x_non_0: if (j /= 0) generate
        -- West port is connected
        data_w_in(i*XLEN + j) <= data_e_out(i*XLEN + j - 1);
        data_void_in_i(i*XLEN + j)(2) <= data_void_out_i(i*XLEN + j - 1)(3);
        stop_in_i(i*XLEN + j)(2) <= stop_out_i(i*XLEN + j - 1)(3);
      end generate x_non_0;

      x_XLEN: if (j=XLEN-1) generate
        -- East port is unconnected
        data_e_in(i*XLEN + j) <= (others => '0');
        data_void_in_i(i*XLEN + j)(3) <= '1';
        stop_in_i(i*XLEN + j)(3) <= '0';
      end generate x_XLEN;

      x_non_XLEN: if (j /= XLEN-1) generate
        -- East port is connected
        data_e_in(i*XLEN + j) <= data_w_out(i*XLEN + j + 1);
        data_void_in_i(i*XLEN + j)(3) <= data_void_out_i(i*XLEN + j + 1)(2);
        stop_in_i(i*XLEN + j)(3) <= stop_out_i(i*XLEN + j + 1)(2);
      end generate x_non_XLEN;

    end generate meshgen_x;
  end generate meshgen_y;


  routerinst: for k in 0 to TILES_NUM-1 generate
    data_p_in(k) <= input_port(k);
    output_port(k) <= data_p_out(k);

    data_void_in_i(k)(4) <= data_void_in(k);
    stop_in_i(k)(4) <= stop_in(k);
    data_void_out(k) <= data_void_out_i(k)(4);
    stop_out(k) <= stop_out_i(k)(4);

    router_ij: router
        generic map (
          flow_control => FLOW_CONTROL,
          width        => MISC_NOC_FLIT_SIZE,
          depth        => ROUTER_DEPTH,
          ports        => ROUTER_PORTS(k),
          localx        => localx(k),
          localy        => localy(k))
      port map (
          clk           => clk,
          rst           => rst,
          data_n_in     => data_n_in(k),
          data_s_in     => data_s_in(k),
          data_w_in     => data_w_in(k),
          data_e_in     => data_e_in(k),
          data_p_in     => data_p_in(k),
          data_void_in  => data_void_in_i(k),
          stop_in       => stop_in_i(k),
          data_n_out    => data_n_out(k),
          data_s_out    => data_s_out(k),
          data_w_out    => data_w_out(k),
          data_e_out    => data_e_out(k),
          data_p_out    => data_p_out(k),
          data_void_out => data_void_out_i(k),
          stop_out      => stop_out_i(k));

    -- Monitor signals
    mon_noc(k).clk          <= clk;
    mon_noc(k).tile_inject  <= not data_void_in(k);

    mon_noc(k).queue_full(4) <= data_void_out_i(k)(4) nand data_void_in_i(k)(4);
    mon_noc(k).queue_full(3) <= not data_void_out_i(k)(3);
    mon_noc(k).queue_full(2) <= not data_void_out_i(k)(2);
    mon_noc(k).queue_full(1) <= not data_void_out_i(k)(1);
    mon_noc(k).queue_full(0) <= not data_void_out_i(k)(0);
--    mon_noc(k).queue_full   <= (stop_out_i(k) or stop_in_i(k)) and ROUTER_PORTS(k);
  end generate routerinst;

end mesh;
