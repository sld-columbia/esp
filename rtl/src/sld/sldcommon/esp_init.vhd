-- Copyright (c) 2011-2020 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.grethpkg.all;
use work.sld_devices.all;
use work.devices.all;
use work.sldcommon.all;

entity esp_init is

  generic (
    hindex   : integer := 0;
    sequence : attribute_vector(0 to CFG_TILES_NUM + CFG_NCPU_TILE - 1));
  port (
    rstn   : in  std_ulogic;
    clk    : in  std_ulogic;
    noinit : in  std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbmo  : out ahb_mst_out_type);

end entity esp_init;


architecture rtl of esp_init is

  constant hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_SLD, SLD_ESP_INIT, 0, 0, 0),
    others => zero32);

  function get_apb_base_address (
    constant arch : cpu_arch_type := ariane)
    return std_logic_vector is
    variable addr : std_logic_vector(11 downto 0);
  begin
    if arch= leon3 then
      addr := X"800";
    else
      addr := X"600";
    end if;
    return addr;
  end function get_apb_base_address;

  constant apb_base_address : std_logic_vector(31 downto 20) := get_apb_base_address(GLOB_CPU_ARCH);
  constant csr_base_address : std_logic_vector(19 downto 16) := X"9";

  constant data_width : integer := ESP_CSR_TILE_ID_MSB - ESP_CSR_TILE_ID_LSB + 1;

  signal req : eth_tx_ahb_in_type;
  signal rsp : eth_tx_ahb_out_type;

  signal count : integer range 0 to CFG_TILES_NUM + CFG_NCPU_TILE - 1;
  signal incr : std_ulogic;

  type init_state_t is (start, busy, pause, done);
  signal init_state, init_next : init_state_t;

  signal msti : ahbc_mst_in_type;
  signal msto : ahbc_mst_out_type;

begin  -- architecture rtl

  count_gen: process (clk, rstn) is
  begin  -- process count_gen
    if rstn = '0' then                  -- asynchronous reset (active low)
      count <= 0;
      init_state <= start;
    elsif clk'event and clk = '1' then  -- rising clock edge
      init_state <= init_next;
      if incr = '1' then
        count <= count + 1;
      end if;
    end if;
  end process count_gen;

  init_fsm: process (init_state, count, rsp) is
    variable tile_id_address : std_logic_vector(31 downto 0);
    variable valid_address : std_logic_vector(31 downto 0);
    variable data : std_logic_vector(data_width - 1 downto 0);
  begin  -- process init_fsm

    tile_id_address := apb_base_address & csr_base_address & conv_std_logic_vector(sequence(count), 7) & "11" & conv_std_logic_vector(ESP_CSR_TILE_ID_ADDR, 5) & "00";
    valid_address   := apb_base_address & csr_base_address & conv_std_logic_vector(sequence(count), 7) & "11" & conv_std_logic_vector(ESP_CSR_VALID_ADDR, 5) & "00";
    data            := conv_std_logic_vector(sequence(count), data_width);

    req.req                        <= '0';
    req.write                      <= '1';
    req.data(31 downto data_width) <= (others => '0');
    if count >= CFG_TILES_NUM then
      req.data(data_width - 1 downto 1) <= (others => '0');
      req.data(0)                       <= '1';
      req.addr                          <= valid_address;
    else
      req.addr                          <= tile_id_address;
      req.data(data_width - 1 downto 0) <= data;
    end if;

    incr <= '0';
    init_next <= init_state;

    case init_state is
      when start =>
        -- wait as long as reset is active
        init_next <= busy;

      when busy =>
        req.req <= '1';
        if rsp.grant = '1' then
          init_next <= pause;
        end if;

      when pause =>
        req.req <= '0';
        if rsp.ready = '1' then
          if count /= CFG_TILES_NUM + CFG_NCPU_TILE - 1 then
            incr      <= '1';
            init_next <= busy;
          else
            init_next <= done;
          end if;
        end if;

      when done =>
        incr <= '0';

      when others =>
        null;
    end case;


  end process init_fsm;

  -- AHB  interface
  msti.hgrant                           <= ahbmi.hgrant(hindex);
  msti.hready                           <= ahbmi.hready;
  msti.hresp                            <= ahbmi.hresp;
  msti.hrdata                           <= ahbmi.hrdata(31 downto 0);
  ahbmo.hbusreq                         <= msto.hbusreq;
  ahbmo.hlock                           <= msto.hlock;
  ahbmo.htrans                          <= msto.htrans;
  ahbmo.haddr                           <= msto.haddr;
  ahbmo.hwrite                          <= msto.hwrite;
  ahbmo.hsize                           <= msto.hsize;
  ahbmo.hburst                          <= msto.hburst;
  ahbmo.hprot                           <= msto.hprot;
  ahbmo.hwdata(ARCH_BITS - 1 downto 32) <= (others => '0');
  ahbmo.hwdata(31 downto 0)             <= msto.hwdata;
  ahbmo.hirq                            <= (others => '0');
  ahbmo.hconfig                         <= hconfig;
  ahbmo.hindex                          <= hindex;

  ahb1 : eth_edcl_ahb_mst
    port map(rstn, clk, msti, msto, req, rsp);

end architecture rtl;
