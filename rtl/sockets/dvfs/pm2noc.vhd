-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Bridge from token-based DVFS core unit to NoC
--
-- Author: Davide Giri
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
--use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
--use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
--use work.cachepackage.all;
use work.tile.all;
--use work.misc.all;
--use work.coretypes.all;
use work.esp_acc_regmap.all;
use work.socmap.all;
--use work.grlib_config.all;
use work.tiles_pkg.all;

entity pm2noc is
  port (
    rstn               : in  std_ulogic;
    clk                : in  std_ulogic;
    -- tile parameters
    local_x            : in  local_yx;
    local_y            : in  local_yx;
    -- token FSM interface towards NoC
    packet_in          : out std_ulogic;
    packet_in_val      : out std_logic_vector(31 downto 0);
    packet_in_addr     : out std_logic_vector(4 downto 0);
    packet_out_ready   : out std_ulogic;
    packet_out         : in  std_ulogic;
    packet_out_val     : in  std_logic_vector(31 downto 0);
    packet_out_addr    : in  std_logic_vector(4 downto 0);
    -- NoC interface
    noc5_input_port    : out misc_noc_flit_type;
    noc5_data_void_in  : out std_ulogic;
    noc5_stop_out      : in  std_ulogic;
    noc5_output_port   : in  misc_noc_flit_type;
    noc5_data_void_out : in  std_ulogic;
    noc5_stop_in       : out std_ulogic);
end entity pm2noc;

architecture rtl of pm2noc is

  -------------------------------------------------------------------------------
  -- FSM: Incoming packets from NoC
  -------------------------------------------------------------------------------
  type rcv_fsm_state is (rcv_header, rcv_tail);

  type rcv_reg_type is record
    state : rcv_fsm_state;
    addr  : std_logic_vector(4 downto 0);
  end record rcv_reg_type;

  constant RCV_REG_DEFAULT : rcv_reg_type := (
    state => rcv_header,
    addr  => (others => '0'));

  signal rcv_reg      : rcv_reg_type;
  signal rcv_reg_next : rcv_reg_type;

  -------------------------------------------------------------------------------
  -- FSM: Outgoing packets to NoC
  -------------------------------------------------------------------------------
  type snd_fsm_state is (snd_header, snd_tail);

  type snd_reg_type is record
    state : snd_fsm_state;
    val   : std_logic_vector(31 downto 0);
  end record snd_reg_type;

  constant SND_REG_DEFAULT : snd_reg_type := (
    state => snd_header,
    val   => (others => '0'));

  signal snd_reg      : snd_reg_type;
  signal snd_reg_next : snd_reg_type;

begin

  fsms_state_update : process (clk, rstn)
  begin
    if rstn = '0' then
      rcv_reg <= RCV_REG_DEFAULT;
      snd_reg <= SND_REG_DEFAULT;
    elsif clk'event and clk = '1' then
      rcv_reg <= rcv_reg_next;
      snd_reg <= snd_reg_next;
    end if;
  end process fsms_state_update;


-------------------------------------------------------------------------------
-- FSM: Messages from NoC
-------------------------------------------------------------------------------
  rcv_fsm : process (rcv_reg,
                     noc5_output_port, noc5_data_void_out) is

    variable reg            : rcv_reg_type;
    variable orig_y, orig_x : local_yx;
    variable tile_id        : integer range 0 to CFG_TILES_NUM;
    variable acc_id         : std_logic_vector(4 downto 0);

  begin  -- process rcv_fsm

    -- initialize variables
    reg := rcv_reg;

    -- initialize signals toward PM
    packet_in      <= '0';
    packet_in_val  <= (others => '0');
    packet_in_addr <= (others => '0');

    -- initialize signals toward NoC
    noc5_stop_in <= '1';

    orig_y := noc5_output_port(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - YX_WIDTH);
    orig_x := noc5_output_port(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - YX_WIDTH - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 2 * YX_WIDTH);
    if unsigned(orig_x) >= 0 and unsigned(orig_x) < CFG_XLEN and
      unsigned(orig_y) >= 0 and unsigned(orig_y) < CFG_YLEN
    then

      tile_id := to_integer(unsigned(orig_x)) +
                 to_integer(unsigned(orig_y)) * CFG_XLEN;

      if tile_acc_id(tile_id) >= 0 then
        acc_id := std_logic_vector(to_unsigned(tile_acc_id(tile_id), 5));
      end if;

    end if;

    case reg.state is

      -- RCV_HEADER
      when rcv_header =>

        if noc5_data_void_out = '0' then
          reg.state := rcv_tail;
          reg.addr  := acc_id;

          noc5_stop_in <= '0';
        end if;

      -- RCV TAIL
      when rcv_tail =>

        if noc5_data_void_out = '0' then
          reg.state := rcv_header;

          noc5_stop_in <= '0';

          packet_in      <= '1';
          packet_in_addr <= reg.addr;
          packet_in_val  <= noc5_output_port(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0);
        end if;

    end case;

    rcv_reg_next <= reg;

  end process rcv_fsm;


-------------------------------------------------------------------------------
-- FSM: Messages to NoC
-------------------------------------------------------------------------------
  snd_fsm : process (snd_reg,
                     packet_out, packet_out_val, packet_out_addr,
                     noc5_stop_out) is

    variable reg            : snd_reg_type;
    variable dest_y, dest_x : local_yx;
    variable tile_id        : integer range 0 to CFG_TILES_NUM - 1;
  begin  -- process snd_fsm

    -- initialize variables
    reg := snd_reg;

    -- initialize signals toward PM
    packet_out_ready <= '0';

    -- initialize signals toward NoC
    noc5_input_port   <= (others => '0');
    noc5_data_void_in <= '1';

    -- dest_x := packet_out_addr(YX_WIDTH - 1 downto 0);
    -- dest_y := packet_out_addr(5 + YX_WIDTH - 1 downto 5);
    if to_integer(unsigned(packet_out_addr)) >= 0 then
      tile_id := acc_tile_id(to_integer(unsigned(packet_out_addr)));
    end if;
    dest_y  := tile_y(tile_id);
    dest_x  := tile_x(tile_id);

    case reg.state is

      -- SND_HEADER
      when snd_header =>

        if noc5_stop_out = '0' then
          packet_out_ready <= '1';
          if packet_out = '1' then
            reg.state := snd_tail;
            reg.val   := packet_out_val;

            noc5_data_void_in <= '0';
            noc5_input_port <= create_header(MISC_NOC_FLIT_SIZE,
                                             local_y, local_x, dest_y, dest_x,
                                             DVFS_MSG, (others => '0'));
          end if;
        end if;

      -- SND TAIL
      when snd_tail =>

        if noc5_stop_out = '0' then
          reg.state := snd_header;

          noc5_data_void_in                                                                  <= '0';
          noc5_input_port(MISC_NOC_FLIT_SIZE - 1 downto MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) <= PREAMBLE_TAIL;
          noc5_input_port(MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH - 1 downto 0)                  <= reg.val;
        end if;

    end case;

    snd_reg_next <= reg;

  end process snd_fsm;

end;
