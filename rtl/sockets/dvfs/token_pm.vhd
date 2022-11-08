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
use work.esp_noc_csr_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.esp_acc_regmap.all;
use work.socmap.all;
use work.tiles_pkg.all;
use work.dvfs.all;
use work.allpll.all;

entity token_pm is

  generic (
    SIMULATION : boolean := false;
    is_asic    : boolean := false;
    tech       : integer := virtex7);

  port (
    noc_rstn           : in  std_ulogic;
    tile_rstn          : in  std_ulogic;
    raw_rstn           : in  std_ulogic;
    noc_clk            : in  std_ulogic;
    refclk             : in  std_ulogic;
    tile_clk           : in  std_ulogic;
	acc_activity       : in  std_ulogic;
    -- runtime configuration for LDO ctrl and token FSM
    pm_config          : in  pm_config_type;
    -- runtime status for LDO ctrl and token FSM
    pm_status          : out pm_status_type;
    -- tile parameters
    local_x            : in  local_yx;
    local_y            : in  local_yx;
    -- NoC inferface
    noc5_input_port    : out misc_noc_flit_type;
    noc5_data_void_in  : out std_ulogic;
    noc5_stop_out      : in  std_ulogic;
    noc5_output_port   : in  misc_noc_flit_type;
    noc5_data_void_out : in  std_ulogic;
    noc5_stop_in       : out std_ulogic;
    -- LDO switch control
    acc_clk            : out std_ulogic;
    plllock            : out std_ulogic;
	LDOCTRL			   : out std_logic_vector(7 downto 0)
	);

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

  signal freq_target                                    : std_logic_vector(7 downto 0);
  signal freq_sel, freq_sel_sync                        : std_logic_vector(3 downto 0);
  signal freq_sel0, freq_sel1, freq_sel2, freq_sel3     : std_ulogic;
  signal LDO0, LDO1, LDO2, LDO3, LDO4, LDO5, LDO6, LDO7 : std_ulogic;

  signal acc_clk_div1, acc_clk_div2, acc_clk_div3, acc_clk_div4 : std_ulogic;
  signal acc_clk_div12, acc_clk_div34                           : std_ulogic;
  signal acc_clk_int                                            : std_ulogic;
  signal pll_rst                                                : std_ulogic;
  signal rangea                                                 : std_logic_vector(4 downto 0);
  signal plllock1, plllock2                                     : std_ulogic;

  signal dvfs_clk0   : std_ulogic;
  signal dvfs_clk1   : std_ulogic;
  signal dvfs_clk2   : std_ulogic;
  signal dvfs_clk3   : std_ulogic;
  signal dvfs_clk4   : std_ulogic;
  signal dvfs_clk5   : std_ulogic;
  signal dvfs_clk6   : std_ulogic;
  signal dvfs_clk7   : std_ulogic;
  signal dvfs_clk8   : std_ulogic;
  signal dvfs_clk9   : std_ulogic;
  signal dvfs_clk10  : std_ulogic;
  signal dvfs_clk11  : std_ulogic;

  signal clk01, clk23, clk45, clk67, clk89, clk1011, clk1213, clk1415 : std_ulogic;
  signal clk03, clk47, clk811, clk1215 : std_ulogic;
  signal clk07, clk815 : std_ulogic;
  signal sel : std_logic_vector(3 downto 0);
  signal acc_activity_1, acc_activity_2,acc_activity_3  : std_ulogic;

  attribute keep : string;
  attribute keep of dvfs_clk0 : signal is "true";
  attribute keep of dvfs_clk1 : signal is "true";
  attribute keep of dvfs_clk2 : signal is "true";
  attribute keep of dvfs_clk3 : signal is "true";
  attribute keep of dvfs_clk4 : signal is "true";
  attribute keep of dvfs_clk5 : signal is "true";
  attribute keep of dvfs_clk6 : signal is "true";
  attribute keep of dvfs_clk7 : signal is "true";
  attribute keep of dvfs_clk8 : signal is "true";
  attribute keep of dvfs_clk9 : signal is "true";
  attribute keep of dvfs_clk10 : signal is "true";
  attribute keep of dvfs_clk11 : signal is "true";

  attribute mark_debug                     : string;
  attribute mark_debug of freq_target      : signal is "true";
  attribute mark_debug of packet_in        : signal is "true";
  attribute mark_debug of packet_in_val    : signal is "true";
  attribute mark_debug of packet_in_addr   : signal is "true";
  attribute mark_debug of packet_out_ready : signal is "true";
  attribute mark_debug of packet_out       : signal is "true";
  attribute mark_debug of packet_out_val   : signal is "true";
  attribute mark_debug of packet_out_addr  : signal is "true";
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
  LDOCTRL <= LDO7 & LDO6 & LDO5 & LDO4 & LDO3 & LDO2 & LDO1 & LDO0;
  acc_clk <= acc_clk_int;
  plllock <= plllock1 and plllock2;

  no_clk_mux : if (is_asic = true) generate
    acc_clk_int <= refclk;
  end generate;

  clk_mux : if (is_asic = false) generate
    pll_rst <= not raw_rstn;

    freq_sel(0) <= LDO4;
    freq_sel(1) <= LDO5;
    freq_sel(2) <= LDO6;
    freq_sel(3) <= LDO7;

    freq_sel_synchronizer : inferred_async_fifo
      generic map (
        g_data_width => 4,
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
    freq_sel2 <= '1' when freq_sel_sync(2) = '1' else '0';  -- avoid X propagation
    freq_sel3 <= '1' when freq_sel_sync(3) = '1' else '0';  -- avoid X propagation

    xcvup : if (tech = virtexup) generate
    pll_virtexup_1: pll_virtexup
      generic map (
        clk_mul    => 16,
        clk0_div   => 15,               --83,2MHz
        clk1_div   => 16,               --78MHz
        clk2_div   => 18,               --69.3MHz
        clk3_div   => 20,               --62.4MHz
        clk4_div   => 22,               --56.7MHz
        clk5_div   => 25,               --49.9MHz
        clk0_phase => 0.0,
        clk1_phase => 0.0,
        clk2_phase => 0.0,
        clk3_phase => 0.0,
        clk4_phase => 0.0,
        clk5_phase => 0.0,
        freq       => 78000)
      port map (
        clk    => refclk,
        rst    => pll_rst,
        dvfs_clk0   => dvfs_clk0,
        dvfs_clk1   => dvfs_clk1,
        dvfs_clk2   => dvfs_clk2,
        dvfs_clk3   => dvfs_clk3,
        dvfs_clk4   => dvfs_clk4,
        dvfs_clk5   => dvfs_clk5,
        locked => plllock1);

    pll_virtexup_2: pll_virtexup
      generic map (
        clk_mul    => 12,
        clk0_div   => 22,              --42.5MHz
        clk1_div   => 26,              --36MHz
        clk2_div   => 32,              --29.3MHz
        clk3_div   => 43,              --21.8MHz
        clk4_div   => 62,              --15.1MHz
        clk5_div   => 117,             --8MHz
        clk0_phase => 0.0,
        clk1_phase => 0.0,
        clk2_phase => 0.0,
        clk3_phase => 0.0,
        clk4_phase => 0.0,
        clk5_phase => 0.0,
        freq       => 78000)
      port map (
        clk    => refclk,
        rst    => pll_rst,
        dvfs_clk0   => dvfs_clk6,
        dvfs_clk1   => dvfs_clk7,
        dvfs_clk2   => dvfs_clk8,
        dvfs_clk3   => dvfs_clk9,
        dvfs_clk4   => dvfs_clk10,
        dvfs_clk5   => dvfs_clk11,
        locked => plllock2);
    end generate;

    xcvu : if (tech = virtexu) generate
    pll_virtexu_1: pll_virtexu
      generic map (
        clk_mul    => 16,
        clk0_div   => 15,               --83,2MHz
        clk1_div   => 16,               --78MHz
        clk2_div   => 18,               --69.3MHz
        clk3_div   => 20,               --62.4MHz
        clk4_div   => 22,               --56.7MHz
        clk5_div   => 25,               --49.9MHz
        clk0_phase => 0.0,
        clk1_phase => 0.0,
        clk2_phase => 0.0,
        clk3_phase => 0.0,
        clk4_phase => 0.0,
        clk5_phase => 0.0,
        freq       => 78000)
      port map (
        clk    => refclk,
        rst    => pll_rst,
        dvfs_clk0   => dvfs_clk0,
        dvfs_clk1   => dvfs_clk1,
        dvfs_clk2   => dvfs_clk2,
        dvfs_clk3   => dvfs_clk3,
        dvfs_clk4   => dvfs_clk4,
        dvfs_clk5   => dvfs_clk5,
        locked => plllock1);

    pll_virtexu_2: pll_virtexu
      generic map (
        clk_mul    => 12,
        clk0_div   => 22,              --42.5MHz
        clk1_div   => 26,              --36MHz
        clk2_div   => 32,              --29.3MHz
        clk3_div   => 43,              --21.8MHz
        clk4_div   => 62,              --15.1MHz
        clk5_div   => 117,             --8MHz
        clk0_phase => 0.0,
        clk1_phase => 0.0,
        clk2_phase => 0.0,
        clk3_phase => 0.0,
        clk4_phase => 0.0,
        clk5_phase => 0.0,
        freq       => 78000)
      port map (
        clk    => refclk,
        rst    => pll_rst,
        dvfs_clk0   => dvfs_clk6,
        dvfs_clk1   => dvfs_clk7,
        dvfs_clk2   => dvfs_clk8,
        dvfs_clk3   => dvfs_clk9,
        dvfs_clk4   => dvfs_clk10,
        dvfs_clk5   => dvfs_clk11,
        locked => plllock2);
    end generate;


    xcv : if (tech = virtex7) generate
    pll_virtex7_1: pll_virtex7
      generic map (
        clk_mul    => 16,
        clk0_div   => 15,               --53,3MHz
        clk1_div   => 16,               --50Hz
        clk2_div   => 18,               --44.4MHz
        clk3_div   => 20,               --40MHz
        clk4_div   => 22,               --36.3MHz
        clk5_div   => 25,               --32MHz
        clk0_phase => 0.0,
        clk1_phase => 0.0,
        clk2_phase => 0.0,
        clk3_phase => 0.0,
        clk4_phase => 0.0,
        clk5_phase => 0.0,
        freq       => 78000)
      port map (
        clk    => refclk,
        rst    => pll_rst,
        dvfs_clk0   => dvfs_clk0,
        dvfs_clk1   => dvfs_clk1,
        dvfs_clk2   => dvfs_clk2,
        dvfs_clk3   => dvfs_clk3,
        dvfs_clk4   => dvfs_clk4,
        dvfs_clk5   => dvfs_clk5,
        locked => plllock1);

    pll_virtex7_2: pll_virtex7
      generic map (
        clk_mul    => 12,
        clk0_div   => 22,              --27.2MHz
        clk1_div   => 26,              --23.1MHz
        clk2_div   => 32,               --18.8MHz
        clk3_div   => 43,              --14MHz
        clk4_div   => 62,              --9.7MHz
        clk5_div   => 117,             --5.1MHz
        clk0_phase => 0.0,
        clk1_phase => 0.0,
        clk2_phase => 0.0,
        clk3_phase => 0.0,
        clk4_phase => 0.0,
        clk5_phase => 0.0,
        freq       => 78000)
      port map (
        clk    => refclk,
        rst    => pll_rst,
        dvfs_clk0   => dvfs_clk6,
        dvfs_clk1   => dvfs_clk7,
        dvfs_clk2   => dvfs_clk8,
        dvfs_clk3   => dvfs_clk9,
        dvfs_clk4   => dvfs_clk10,
        dvfs_clk5   => dvfs_clk11,
        locked => plllock2);
    end generate;

    clk01 <= dvfs_clk0;
    clk23 <= dvfs_clk0 when freq_sel0 = '0' else dvfs_clk1;
    clk45 <= dvfs_clk2 when freq_sel0 = '0' else dvfs_clk3;
    clk67 <= dvfs_clk4 when freq_sel0 = '0' else dvfs_clk5;
    clk89 <= dvfs_clk6 when freq_sel0 = '0' else dvfs_clk7;
    clk1011 <= dvfs_clk8 when freq_sel0 = '0' else dvfs_clk9;
    clk1213 <= dvfs_clk10 when freq_sel0 = '0' else dvfs_clk11;
    clk1415 <= dvfs_clk11;

    clk03 <= clk01 when freq_sel1 = '0' else clk23;
    clk47 <= clk45 when freq_sel1 = '0' else clk67;
    clk811 <= clk89 when freq_sel1 = '0' else clk1011;
    clk1215 <= clk1213 when freq_sel1 = '0' else clk1415;

    clk07 <= clk03 when freq_sel2 = '0' else clk47;
    clk815 <= clk811 when freq_sel2 = '0' else clk1215;

    clkmux_i : clkmuxctrl_unisim
      port map (clk07, clk815, freq_sel3, acc_clk_int);

end generate;

  -----------------------------------------------------------------------------
  --  Token-based DVFS core
  ------------------------------------------------------------------------------
	--Rescync of activity to noc domain
 
 process(noc_clk)
 begin 
  if(rising_edge(noc_clk)) then
   	acc_activity_2 <= acc_activity_1; 
   	acc_activity_1 <= acc_activity; 
  end if;      
  acc_activity_3<=pm_config(1)(0) or acc_activity_2;
 end process;  
	
  pm_status(0)(31 downto 15) <= (others => '0');
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
      enable                 => pm_config(0)(0),            -- enable
      max_tokens             => pm_config(0)(6 downto 1),   -- max_tokens
      refresh_rate_min       => pm_config(0)(18 downto 7),  -- refresh_rate_min
      refresh_rate_max       => pm_config(0)(30 downto 19),  -- refresh_rate_max
      activity               => acc_activity_3,            -- activity
      random_rate            => pm_config(1)(5 downto 1),   -- random_rate
      LUT_write              => pm_config(1)(23 downto 6),  -- LUT_write
      token_counter_override => pm_config(1)(31 downto 24),  -- token_counter_override
      neighbors_ID           => pm_config(2)(19 downto 0),  -- neighbors_ID
      PM_network             => pm_config(3)(31 downto 0),  -- PM_network
      tokens_next            => pm_status(0)(6 downto 0),   -- tokens_next
      LUT_read               => pm_status(0)(14 downto 7),  -- LUT_read
      freq_target            => freq_target);

  -- TO DO add the second reset
  Tile_LDO_Ctrl_i : Tile_LDO_Ctrl
    port map (
      clk         => noc_clk,
      DCO_clk     => acc_clk_int,
      reset_tile  => tile_rstn,
      reset_noc   => noc_rstn,
      freq_target => freq_target,
      LDO_setup_0 => pm_config(4),
      LDO_setup_1 => pm_config(5),
      LDO_setup_2 => pm_config(6),
      LDO_setup_3 => pm_config(7),
      LDO_setup_4 => pm_config(8),
      LDO_debug_0 => pm_status(1),
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
      noc5_input_port    => noc5_input_port,
      noc5_data_void_in  => noc5_data_void_in,
      noc5_stop_out      => noc5_stop_out,
      noc5_output_port   => noc5_output_port,
      noc5_data_void_out => noc5_data_void_out,
      noc5_stop_in       => noc5_stop_in);
end;
