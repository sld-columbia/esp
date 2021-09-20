-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Token-based DVFS integration unit
--  - To be inserted in the NoC clock domain, between NoC routers and NoC-tile
--    synchronizers
--
--  Author: Davide Giri
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.allclkgen.all;
use work.gencomp.all;
use work.esp_csr_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.esp_acc_regmap.all;
use work.socmap.all;
use work.tiles_pkg.all;
use work.dvfs.all;

entity token_pm is

  generic (
    SIMULATION : boolean := false;
    is_asic    : boolean := false);

  port (
    noc_rstn              : in  std_ulogic;
    tile_rstn             : in  std_ulogic;
    noc_clk               : in  std_ulogic;
    refclk                : in  std_ulogic;
    tile_clk              : in  std_ulogic;
    -- runtime configuration for LDO ctrl and token FSM
    pm_config             : in  pm_config_type;
    -- runtime status for LDO ctrl and token FSM
    pm_status             : out pm_status_type;
    -- tile parameters
    local_x               : in  local_yx;
    local_y               : in  local_yx;
    -- NoC interface
    noc5_input_port       : out misc_noc_flit_type;
    noc5_data_void_in     : out std_ulogic;
    noc5_stop_out         : in  std_ulogic;
    noc5_output_port      : in  misc_noc_flit_type;
    noc5_data_void_out    : in  std_ulogic;
    noc5_stop_in          : out std_ulogic;
    -- Accelerator tile NoC inferface
    noc5_input_port_pm    : in  misc_noc_flit_type;
    noc5_data_void_in_pm  : in  std_ulogic;
    noc5_stop_out_pm      : out std_ulogic;
    noc5_output_port_pm   : out misc_noc_flit_type;
    noc5_data_void_out_pm : out std_ulogic;
    noc5_stop_in_pm       : in  std_ulogic;
    -- LDO switch control
    acc_clk               : out std_ulogic);

end entity token_pm;

architecture rtl of token_pm is

  -- token FSM interface towards NoC
  signal packet_in        : std_ulogic;
  signal packet_in_val    : std_logic_vector(31 downto 0);
  signal packet_in_addr   : std_logic_vector(4 downto 0);
  signal packet_out_ready : std_ulogic;
  signal packet_out       : std_ulogic;
  signal packet_out_val   : std_logic_vector(31 downto 0);
  signal packet_out_addr  : std_logic_vector(4 downto 0);

  -- pm2noc NoC inferface
  signal noc5_input_port_int    : misc_noc_flit_type;
  signal noc5_data_void_in_int  : std_ulogic;
  signal noc5_stop_out_int      : std_ulogic;
  signal noc5_output_port_int   : misc_noc_flit_type;
  signal noc5_data_void_out_int : std_ulogic;
  signal noc5_stop_in_int       : std_ulogic;

  -------------------------------------------------------------------------------
  -- FSM: Clock gating
  -------------------------------------------------------------------------------

  type clk_gate_fsm is (idle, gate);

  type clk_gate_reg_type is record
    state : clk_gate_fsm;
    sel   : std_logic_vector(1 downto 0);
  end record clk_gate_reg_type;

  constant CLK_GATE_REG_DEFAULT : clk_gate_reg_type := (
    state => idle,
    sel   => (others => '0'));

  signal clk_gate_reg, clk_gate_reg_next : clk_gate_reg_type;

  signal clk_gate, clk_gate_latch : std_ulogic;

  -------------------------------------------------------------------------------
  -- FSM: Incoming packets from NoC5
  -------------------------------------------------------------------------------
  type noc5_rcv_fsm is (idle, pm_rcv, acc_rcv);

  type noc5_rcv_reg_type is record
    state : noc5_rcv_fsm;
  end record noc5_rcv_reg_type;

  constant NOC5_RCV_REG_DEFAULT : noc5_rcv_reg_type := (
    state => idle);

  signal noc5_rcv_reg      : noc5_rcv_reg_type;
  signal noc5_rcv_reg_next : noc5_rcv_reg_type;

  signal pm_rcv_en, acc_rcv_en : std_ulogic;

  -------------------------------------------------------------------------------
  -- FSM: Outgoing packets to NoC5
  -------------------------------------------------------------------------------
  type noc5_snd_fsm is (idle_acc, idle_pm, acc_snd, pm_snd);

  type noc5_snd_reg_type is record
    state : noc5_snd_fsm;
  end record noc5_snd_reg_type;

  constant NOC5_SND_REG_DEFAULT : noc5_snd_reg_type := (
    state => idle_acc);

  signal noc5_snd_reg      : noc5_snd_reg_type;
  signal noc5_snd_reg_next : noc5_snd_reg_type;

  signal pm_snd_en : boolean;
  -------------------------------------------------------------------------------

  signal pm_config_array, pm_config_array_sync : std_logic_vector(PM_REGNUM_CONFIG*32-1 downto 0);
  signal pm_config_sync                        : pm_config_type;
  signal pm_status_array, pm_status_array_sync : std_logic_vector(PM_REGNUM_STATUS*32-1 downto 0);
  signal pm_status_sync                        : pm_status_type;

  signal freq_target                                    : std_logic_vector(7 downto 0);
  signal freq_sel, freq_sel_sync                        : std_logic_vector(1 downto 0);
  signal freq_sel0, freq_sel1                           : std_ulogic;
  signal LDO0, LDO1, LDO2, LDO3, LDO4, LDO5, LDO6, LDO7 : std_ulogic;

  signal acc_clk_div1, acc_clk_div2, acc_clk_div3, acc_clk_div4 : std_ulogic;
  signal acc_clk_div12, acc_clk_div34                           : std_ulogic;
  signal acc_clk_int                                            : std_ulogic;

  attribute mark_debug                     : string;
  attribute mark_debug of freq_target      : signal is "true";
  attribute mark_debug of packet_in        : signal is "true";
  attribute mark_debug of packet_in_val    : signal is "true";
  attribute mark_debug of packet_in_addr   : signal is "true";
  attribute mark_debug of packet_out_ready : signal is "true";
  attribute mark_debug of packet_out       : signal is "true";
  attribute mark_debug of packet_out_val   : signal is "true";
  attribute mark_debug of packet_out_addr  : signal is "true";
  attribute mark_debug of noc5_rcv_reg     : signal is "true";
  attribute mark_debug of pm_rcv_en        : signal is "true";
  attribute mark_debug of acc_rcv_en       : signal is "true";
  attribute mark_debug of noc5_snd_reg     : signal is "true";
  attribute mark_debug of pm_snd_en        : signal is "true";
  attribute mark_debug of LDO0             : signal is "true";
  attribute mark_debug of LDO1             : signal is "true";
  attribute mark_debug of LDO2             : signal is "true";
  attribute mark_debug of LDO3             : signal is "true";
  attribute mark_debug of LDO4             : signal is "true";
  attribute mark_debug of LDO5             : signal is "true";
  attribute mark_debug of LDO6             : signal is "true";
  attribute mark_debug of LDO7             : signal is "true";
  attribute mark_debug of freq_sel         : signal is "true";
  attribute mark_debug of freq_sel_sync    : signal is "true";

begin

  -----------------------------------------------------------------------------
  --  Clock multiplexing
  --
  --  Enabled only in simulation and on FPGA to have dynamic frequency scaling
  --  (voltage scaling is not possible). On ASIC there is full DVFS by controlling
  --  an LDO.
  ------------------------------------------------------------------------------

  acc_clk <= acc_clk_int;

  no_clk_mux : if (is_asic = true) generate
    acc_clk_int <= refclk;
  end generate;

  clk_mux : if (is_asic = false) generate

    clkdiv1234_i : clkdiv1234
      port map (
        rstn     => tile_rstn,
        clkin    => refclk,
        clk_div1 => acc_clk_div1,
        clk_div2 => acc_clk_div2,
        clk_div3 => acc_clk_div3,
        clk_div4 => acc_clk_div4);

    freq_sel(0) <= LDO6;
    freq_sel(1) <= LDO7;

    freq_sel_synchronizer : inferred_async_fifo
      generic map (
        g_data_width => 2,
        g_size       => 2)
      port map (
        -- write port
        rst_wr_n_i => noc_rstn,
        clk_wr_i   => noc_clk,
        we_i       => '1',
        d_i        => freq_sel,
        wr_full_o  => open,
        -- read port
        rst_rd_n_i => tile_rstn,
        clk_rd_i   => refclk,
        rd_i       => '1',
        q_o        => freq_sel_sync,
        rd_empty_o => open);

    freq_sel0 <= '1' when freq_sel_sync(0) = '1' else '0';  -- avoid X propagation
    freq_sel1 <= '1' when freq_sel_sync(1) = '1' else '0';  -- avoid X propagation

    acc_clk_div12 <= acc_clk_div1 when freq_sel0 = '0' else acc_clk_div2;
    acc_clk_div34 <= acc_clk_div3 when freq_sel0 = '0' else acc_clk_div4;
    clkmux_1234 : clkmux
      port map (acc_clk_div12, acc_clk_div34, freq_sel1, acc_clk_int, tile_rstn);

  end generate;

  -----------------------------------------------------------------------------
  --  Token-based DVFS core
  ------------------------------------------------------------------------------

  pm_status_sync(0)(31 downto 15) <= (others => '0');
  Token_FSM_i : Token_FSM
    port map (
      clock                  => noc_clk,
      reset                  => noc_rstn,
      packet_in              => packet_in,
      packet_in_val          => packet_in_val,
      packet_in_addr         => packet_in_addr,
      packet_out             => packet_out,
      packet_out_ready       => packet_out_ready,
      packet_out_val         => packet_out_val,
      packet_out_addr        => packet_out_addr,
      enable                 => pm_config_sync(0)(0),            -- enable
      max_tokens             => pm_config_sync(0)(6 downto 1),   -- max_tokens
      refresh_rate_min       => pm_config_sync(0)(18 downto 7),  -- refresh_rate_min
      refresh_rate_max       => pm_config_sync(0)(30 downto 19),  -- refresh_rate_max
      activity               => pm_config_sync(1)(0),            -- activity
      random_rate            => pm_config_sync(1)(5 downto 1),   -- random_rate
      LUT_write              => pm_config_sync(1)(23 downto 6),  -- LUT_write
      token_counter_override => pm_config_sync(1)(31 downto 24),  -- token_counter_override
      neighbors_ID           => pm_config_sync(2)(19 downto 0),  -- neighbors_ID
      PM_network             => pm_config_sync(3)(31 downto 0),  -- PM_network
      tokens_next            => pm_status_sync(0)(6 downto 0),   -- tokens_next
      LUT_read               => pm_status_sync(0)(14 downto 7),  -- LUT_read
      freq_target            => freq_target);

  -- TO DO add the second reset
  Tile_LDO_Ctrl_i : Tile_LDO_Ctrl
    port map (
      clk         => noc_clk,
      DCO_clk     => acc_clk_int,
      reset       => noc_rstn,
      freq_target => freq_target,
      LDO_setup_0 => pm_config_sync(4),
      LDO_setup_1 => pm_config_sync(5),
      LDO_setup_2 => pm_config_sync(6),
      LDO_setup_3 => pm_config_sync(7),
      LDO_setup_4 => pm_config_sync(8),
      LDO_debug_0 => pm_status_sync(1),
      LDO0        => LDO0,
      LDO1        => LDO1,
      LDO2        => LDO2,
      LDO3        => LDO3,
      LDO4        => LDO4,
      LDO5        => LDO5,
      LDO6        => LDO6,
      LDO7        => LDO7);

  -----------------------------------------------------------------------------
  --  Bridge between DVFS core and NoC5
  ------------------------------------------------------------------------------

  pm2noc_i : pm2noc
    port map (
      clk                => noc_clk,
      rstn               => noc_rstn,
      local_x            => local_x,
      local_y            => local_y,
      packet_in          => packet_in,
      packet_in_addr     => packet_in_addr,
      packet_in_val      => packet_in_val,
      packet_out         => packet_out,
      packet_out_ready   => packet_out_ready,
      packet_out_addr    => packet_out_addr,
      packet_out_val     => packet_out_val,
      noc5_input_port    => noc5_input_port_int,
      noc5_data_void_in  => noc5_data_void_in_int,
      noc5_stop_out      => noc5_stop_out_int,
      noc5_output_port   => noc5_output_port_int,
      noc5_data_void_out => noc5_data_void_out_int,
      noc5_stop_in       => noc5_stop_in_int);

  -- NoC5 receive FSM
  noc5_output_port_int   <= noc5_output_port;
  noc5_output_port_pm    <= noc5_output_port;
  noc5_data_void_out_int <= noc5_data_void_out when pm_rcv_en = '1'  else '1';
  noc5_data_void_out_pm  <= noc5_data_void_out when acc_rcv_en = '1' else '1';

  -----------------------------------------------------------------------------
  --  Bidirectional NoC5 Multiplexing between DVFS core and accelerator tile
  ------------------------------------------------------------------------------

  fsm_noc5_rcv : process (noc5_rcv_reg,
                          noc5_output_port, noc5_data_void_out,
                          noc5_stop_in_int, noc5_stop_in_pm)
    variable reg      : noc5_rcv_reg_type;
    variable preamble : noc_preamble_type;
    variable msg_type : noc_msg_type;

  begin  -- process
    reg := noc5_rcv_reg;

    pm_rcv_en  <= '0';
    acc_rcv_en <= '0';

    noc5_stop_in <= noc5_stop_in_int and noc5_stop_in_pm;

    preamble := get_preamble_misc(noc5_output_port);
    msg_type := get_msg_type_misc(noc5_output_port);

    case reg.state is

      -- IDLE
      when idle =>
        if noc5_data_void_out = '0' then

          if msg_type = DVFS_MSG then
            pm_rcv_en <= '1';
            if preamble /= PREAMBLE_1FLIT then
              reg.state := pm_rcv;
            end if;
            noc5_stop_in <= noc5_stop_in_int;
          else
            acc_rcv_en <= '1';
            if preamble /= PREAMBLE_1FLIT then
              reg.state := acc_rcv;
            end if;
            noc5_stop_in <= noc5_stop_in_pm;
          end if;
        end if;

      when pm_rcv =>
        pm_rcv_en    <= '1';
        noc5_stop_in <= noc5_stop_in_int;
        if noc5_data_void_out = '0' and noc5_stop_in_int = '0' and preamble = PREAMBLE_TAIL then
          reg.state := idle;
        end if;

      when acc_rcv =>
        acc_rcv_en   <= '1';
        noc5_stop_in <= noc5_stop_in_pm;
        if noc5_data_void_out = '0' and noc5_stop_in_pm = '0' and preamble = PREAMBLE_TAIL then
          reg.state := idle;
        end if;

    end case;

    noc5_rcv_reg_next <= reg;

  end process;

  -- NoC5 send FSM
  noc5_input_port   <= noc5_input_port_int   when pm_snd_en else noc5_input_port_pm;
  noc5_data_void_in <= noc5_data_void_in_int when pm_snd_en else noc5_data_void_in_pm;

  fsm_noc5_snd : process (noc5_snd_reg, noc5_stop_out,
                          noc5_input_port_int, noc5_input_port_pm,
                          noc5_data_void_in_int, noc5_data_void_in_pm)
    variable reg                       : noc5_snd_reg_type;
    variable preamble_int, preamble_pm : noc_preamble_type;

  begin  -- process
    reg := noc5_snd_reg;

    pm_snd_en <= false;

    noc5_stop_out_int <= '1';
    noc5_stop_out_pm  <= '1';

    preamble_int := get_preamble_misc(noc5_input_port_int);
    preamble_pm  := get_preamble_misc(noc5_input_port_pm);

    case reg.state is

      when idle_acc =>
        reg.state := idle_pm;

        if noc5_stop_out = '0' then
          noc5_stop_out_pm <= '0';
          if noc5_data_void_in_pm = '0' then
            if preamble_pm /= PREAMBLE_1FLIT then
              reg.state := acc_snd;
            end if;
          end if;
        end if;

      when idle_pm =>
        reg.state := idle_acc;

        if noc5_stop_out = '0' then
          noc5_stop_out_int <= '0';
          if noc5_data_void_in_int = '0' then
            pm_snd_en <= true;
            if preamble_int /= PREAMBLE_1FLIT then
              reg.state := pm_snd;
            end if;
          end if;
        end if;

      when acc_snd =>
        if noc5_stop_out = '0' then
          noc5_stop_out_pm <= '0';
          if noc5_data_void_in_pm = '0' then
            if preamble_pm = PREAMBLE_TAIL then
              reg.state := idle_pm;
            end if;
          end if;
        end if;

      when pm_snd =>
        if noc5_stop_out = '0' then
          noc5_stop_out_int <= '0';
          if noc5_data_void_in_int = '0' then
            pm_snd_en <= true;
            if preamble_int = PREAMBLE_TAIL then
              reg.state := idle_acc;
            end if;
          end if;
        end if;

    end case;

    noc5_snd_reg_next <= reg;

  end process;

  fsms_state_update : process (noc_clk, noc_rstn)
  begin
    if noc_rstn = '0' then
      noc5_rcv_reg <= NOC5_RCV_REG_DEFAULT;
      noc5_snd_reg <= NOC5_SND_REG_DEFAULT;
    elsif noc_clk'event and noc_clk = '1' then
      noc5_rcv_reg <= noc5_rcv_reg_next;
      noc5_snd_reg <= noc5_snd_reg_next;
    end if;
  end process fsms_state_update;

  -----------------------------------------------------------------------------
  --  Connection to CSRs of the accelerator tile (read and write)
  ------------------------------------------------------------------------------

  pm_config_vector_gen : for i in 0 to PM_REGNUM_CONFIG - 1 generate
    pm_config_array((i+1)*32-1 downto i*32) <= pm_config(i);
  end generate pm_config_vector_gen;

  pm_config_vector_sync_gen : for i in 0 to PM_REGNUM_CONFIG - 1 generate
    pm_config_sync(i) <= pm_config_array_sync((i+1)*32-1 downto i*32);
  end generate pm_config_vector_sync_gen;

  pm_status_vector_sync_gen : for i in 0 to PM_REGNUM_STATUS - 1 generate
    pm_status_array_sync((i+1)*32-1 downto i*32) <= pm_status_sync(i);
  end generate pm_status_vector_sync_gen;

  pm_status_vector_gen : for i in 0 to PM_REGNUM_STATUS - 1 generate
    pm_status(i) <= pm_status_array((i+1)*32-1 downto i*32);
  end generate pm_status_vector_gen;

  pm_config_synchronizer : inferred_async_fifo
    generic map (
      g_data_width => PM_REGNUM_CONFIG * 32,
      g_size       => 2)
    port map (
      -- write port
      rst_wr_n_i => tile_rstn,
      clk_wr_i   => acc_clk_int,
      we_i       => '1',
      d_i        => pm_config_array,
      wr_full_o  => open,
      -- read port
      rst_rd_n_i => noc_rstn,
      clk_rd_i   => noc_clk,
      rd_i       => '1',
      q_o        => pm_config_array_sync,
      rd_empty_o => open);

  pm_status_synchronizer : inferred_async_fifo
    generic map (
      g_data_width => PM_REGNUM_STATUS * 32,
      g_size       => 2)
    port map (
      -- write port
      rst_wr_n_i => noc_rstn,
      clk_wr_i   => noc_clk,
      we_i       => '1',
      d_i        => pm_status_array_sync,
      wr_full_o  => open,
      -- read port
      rst_rd_n_i => tile_rstn,
      clk_rd_i   => acc_clk_int,
      rd_i       => '1',
      q_o        => pm_status_array,
      rd_empty_o => open);

end;
