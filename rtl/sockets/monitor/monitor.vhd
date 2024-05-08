-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
  use ieee.std_logic_1164.all;
  use work.amba.all;
  use work.stdlib.all;
  use work.sld_devices.all;
  use work.devices.all;
  use work.gencomp.all;
  use work.allclkgen.all;

  -- pragma translate off
  use std.textio.all;

library unisim;
  use unisim.vcomponents.all;
-- pragma translate_on

library profpga;
  use work.monitor_pkg.all;

entity monitor is
  generic (
    memtech                : integer;
    mmi64_width            : integer;
    ddrs_num               : integer;
    slms_num               : integer;
    nocs_num               : integer;
    tiles_num              : integer;
    accelerators_num       : integer;
    l2_num                 : integer;
    llc_num                : integer;
    mon_ddr_en             : integer;
    mon_noc_tile_inject_en : integer;
    mon_noc_queues_full_en : integer;
    mon_acc_en             : integer;
    mon_mem_en             : integer;
    mon_l2_en              : integer;
    mon_llc_en             : integer;
    mon_dvfs_en            : integer
  );
  port (
    profpga_clk0_p  : in    std_logic; -- 100 MHz clock
    profpga_clk0_n  : in    std_logic; -- 100 MHz clock
    profpga_sync0_p : in    std_logic;
    profpga_sync0_n : in    std_logic;
    dmbi_h2f        : in    std_logic_vector(19 downto 0);
    dmbi_f2h        : out   std_logic_vector(19 downto 0);
    user_rstn       : in    std_logic;
    mon_ddr         : in    monitor_ddr_vector(0 to ddrs_num - 1);
    mon_noc         : in    monitor_noc_matrix(0 to nocs_num - 1, 0 to tiles_num - 1);
    mon_acc         : in    monitor_acc_vector(0 to relu(accelerators_num - 1));
    mon_mem         : in    monitor_mem_vector(0 to ddrs_num + slms_num - 1);
    mon_l2          : in    monitor_cache_vector(0 to relu(l2_num - 1));
    mon_llc         : in    monitor_cache_vector(0 to relu(llc_num - 1));
    mon_dvfs        : in    monitor_dvfs_vector(0 to tiles_num - 1)
  );
end entity monitor;

architecture rtl of monitor is

  type syscom_dn_t is array (integer range 0 to 0) of std_logic_vector(67 downto 0);

  type syscom_up_t is array (integer range 0 to 0) of std_logic_vector(68 downto 0);

  subtype profpga_tech_description is string(1 to 4);

  type profpga_device_table_t is array (0 to NTECH) of profpga_tech_description;

  constant PROFPGA_DEVICE_TABLE : profpga_device_table_t :=
  (
    virtex7  => "XV7S",
    virtexu  => "XVUS",
    virtexup => "XVUP",
    others   => "NONE"
  );

  component synchronizer is
    generic (
      data_width : integer
    );
    port (
      clk     : in    std_logic;
      reset_n : in    std_logic;
      data_i  : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      data_o  : out   std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
  end component;

  component profpga_ctrl is
    generic (
      device : string := "XV7S"
    );
    port (
      -- access to FPGA pins
      clk0_p    : in    std_logic;
      clk0_n    : in    std_logic;
      sync0_p   : in    std_logic;
      sync0_n   : in    std_logic;
      srcclk_p  : out   std_logic_vector(3 downto 0);
      srcclk_n  : out   std_logic_vector(3 downto 0);
      srcsync_p : out   std_logic_vector(3 downto 0);
      srcsync_n : out   std_logic_vector(3 downto 0);
      dmbi_h2f  : in    std_logic_vector(19 downto 0);
      dmbi_f2h  : out   std_logic_vector(19 downto 0);
      xdmbi_h2f : in    std_logic_vector(3 downto 0);
      xdmbi_f2h : out   std_logic_vector(3 downto 0);

      -- 200 MHz clock (useful for IDELAYCTRL calibration)
      clk_200mhz_o : out   std_logic;

      -- source clock/sync input
      src_clk_i : in    std_logic_vector(3 downto 0) := "0000";
      -- the following signals are synchronous to the associated src_clk_i(i)
      src_clk_locked_i    : in    std_logic_vector(3 downto 0) := "0000";
      src_event_id_i      : in    std_logic_vector(3 * 8 + 7 downto 0) := (others => '0');
      src_event_en_i      : in    std_logic_vector(3 downto 0) := "0000";
      src_event_busy_o    : out   std_logic_vector(3 downto 0);
      src_event_reset_i   : in    std_logic_vector(3 downto 0) := "1111";
      src_event_strobe1_i : in    std_logic_vector(3 downto 0) := "0000";
      src_event_strobe2_i : in    std_logic_vector(3 downto 0) := "0000";

      -- clk0 sync events (synchronous to mmi64_clk)
      clk0_event_id_o      : out   std_logic_vector(7 downto 0);
      clk0_event_en_o      : out   std_logic;
      clk0_event_strobe1_o : out   std_logic;
      clk0_event_strobe2_o : out   std_logic;

      -- MMI-64 access (synchronous to mmi64_clk)
      mmi64_present_i : in    std_logic := '0';
      mmi64_clk_o     : out   std_logic;
      mmi64_reset_o   : out   std_logic;

      mmi64_m_dn_d_o      : out   std_logic_vector(63 downto 0);
      mmi64_m_dn_valid_o  : out   std_logic;
      mmi64_m_dn_accept_i : in    std_logic   := '0';
      mmi64_m_dn_start_o  : out   std_logic;
      mmi64_m_dn_stop_o   : out   std_logic;
      mmi64_m_up_d_i      : in    std_logic_vector(63 downto 0);
      mmi64_m_up_valid_i  : in    std_logic   := '0';
      mmi64_m_up_accept_o : out   std_logic;
      mmi64_m_up_start_i  : in    std_logic   := '0';
      mmi64_m_up_stop_i   : in    std_logic   := '0';

      -- clock configuration ports (synchronous to mmi64_clk)
      clk1_cfg_dn_o : out   std_logic_vector(19 downto 0);
      clk1_cfg_up_i : in    std_logic_vector(19 downto 0) := (others => '0');
      clk2_cfg_dn_o : out   std_logic_vector(19 downto 0);
      clk2_cfg_up_i : in    std_logic_vector(19 downto 0) := (others => '0');
      clk3_cfg_dn_o : out   std_logic_vector(19 downto 0);
      clk3_cfg_up_i : in    std_logic_vector(19 downto 0) := (others => '0');
      clk4_cfg_dn_o : out   std_logic_vector(19 downto 0);
      clk4_cfg_up_i : in    std_logic_vector(19 downto 0) := (others => '0');
      clk5_cfg_dn_o : out   std_logic_vector(19 downto 0);
      clk5_cfg_up_i : in    std_logic_vector(19 downto 0) := (others => '0');
      clk6_cfg_dn_o : out   std_logic_vector(19 downto 0);
      clk6_cfg_up_i : in    std_logic_vector(19 downto 0) := (others => '0');
      clk7_cfg_dn_o : out   std_logic_vector(19 downto 0);
      clk7_cfg_up_i : in    std_logic_vector(19 downto 0) := (others => '0');

      -- Stratix10 temperature monitor
      temp_mon_i2c_sda : inout std_logic := '0';
      temp_mon_i2c_scl : inout std_logic := '0';

      syscom_dn_o : out   syscom_dn_t;
      syscom_up_i : in    syscom_up_t
    );
  end component profpga_ctrl;

  component mmi64_m_regif is
    generic (
      module_id         : integer := 16#00000000#;
      register_count    : integer := 16;
      register_width    : integer := 16;
      read_buffer_depth : integer := 4
    );
    port (
      -- clock and reset
      mmi64_clk   : in    std_logic;
      mmi64_reset : in    std_logic;

      -- connections to mmi64 router
      mmi64_h_dn_d_i      : in    std_logic_vector(63 downto 0);
      mmi64_h_dn_valid_i  : in    std_logic;
      mmi64_h_dn_accept_o : out   std_logic;
      mmi64_h_dn_start_i  : in    std_logic;
      mmi64_h_dn_stop_i   : in    std_logic;

      mmi64_h_up_d_o      : out   std_logic_vector(63 downto 0);
      mmi64_h_up_valid_o  : out   std_logic;
      mmi64_h_up_accept_i : in    std_logic;
      mmi64_h_up_start_o  : out   std_logic;
      mmi64_h_up_stop_o   : out   std_logic;

      -- connections to register interface
      reg_en_o     : out   std_logic;
      reg_we_o     : out   std_logic;
      reg_addr_o   : out   std_logic_vector(log2(REGISTER_COUNT) - 1 downto 0);
      reg_wdata_o  : out   std_logic_vector(REGISTER_WIDTH - 1 downto 0);
      reg_accept_i : in    std_logic;
      reg_rdata_i  : in    std_logic_vector(REGISTER_WIDTH - 1 downto 0);
      reg_rvalid_i : in    std_logic
    );
  end component;

  -- X = ddrs_num
  --
  -- r0
  -- r1
  -- ...
  -- rX

  function ddr_offset (
    constant ddr : integer range 0 to ddrs_num
  )
    return integer is

    variable offset : integer;

  begin -- ddr_offset

    offset := ddr;
    return offset * mon_ddr_en;

  end function ddr_offset;

  -- X = llc_num
  -- r = coh_req, coh_fwd, coh_rsp_rcv, coh_rsp_snd, dma_req, dma_rsp, coh_dma_req, coh_dma_rsp
  --
  -- coh_req0, coh_fwd0, ...
  --      ...
  --      ...
  -- coh_reqX, coh_fwdX, ...

  function mem_offset (
    constant mem : integer range -1 to ddrs_num + slms_num;
    constant reg : integer range 0 to 8
  )
    return integer is

    variable offset : integer;

  begin

    offset := (mem * 8) + reg;
    return ddr_offset(ddrs_num) + (offset * mon_mem_en);

  end function mem_offset;

  constant MEM_COH_REQ     : integer range 0 to 7 := 0;
  constant MEM_COH_FWD     : integer range 0 to 7 := 1;
  constant MEM_COH_RSP_RCV : integer range 0 to 7 := 2;
  constant MEM_COH_RSP_SND : integer range 0 to 7 := 3;
  constant MEM_DMA_REQ     : integer range 0 to 7 := 4;
  constant MEM_DMA_RSP     : integer range 0 to 7 := 5;
  constant MEM_COH_DMA_REQ : integer range 0 to 7 := 6;
  constant MEM_COH_DMA_RSP : integer range 0 to 7 := 7;

  -- X = nocs_num
  -- Y = tiles_num
  --
  -- r00  r01  ...  r0Y
  -- r10  ...  ...  ...
  -- ...  ...  ...  ...
  -- rX0  ...  ...  rXY

  function noc_tile_inject_offset (
    constant plane : integer range -1 to nocs_num;
    constant tile  : integer range 0 to tiles_num
  )
    return integer is

    variable offset : integer;

  begin -- noc_offset

    offset := (plane * tiles_num) + tile;
    return mem_offset(ddrs_num + slms_num - 1, 8) + (offset * mon_noc_tile_inject_en);

  end function noc_tile_inject_offset;

  -- X = nocs_num
  -- Y = tiles_num
  -- r = n|s|w|e|l
  --
  -- n00,s00,w00,e00,l00  ...  ...  n0Y,s0Y,w0Y,e0Y,l0Y
  --         ...          ...  ...         ...
  --         ...          ...  ...         ...
  -- nX0,sX0,wX0,eX0,lX0  ...  ...  nXY,sXY,wXY,eXY,lXY

  function noc_queues_full_offset (
    constant plane     : integer range -1 to nocs_num;
    constant tile      : integer range 0 to tiles_num;
    constant direction : integer range 0 to 5
  )
    return integer is

    variable offset : integer;

  begin

    offset := (plane * tiles_num * 5) + (tile * 5) + direction;
    return noc_tile_inject_offset(nocs_num - 1, tiles_num) + (offset * mon_noc_queues_full_en);

  end function noc_queues_full_offset;

  constant DIR_N : integer range 0 to 4 := 0;
  constant DIR_S : integer range 0 to 4 := 1;
  constant DIR_W : integer range 0 to 4 := 2;
  constant DIR_E : integer range 0 to 4 := 3;
  constant DIR_L : integer range 0 to 4 := 4;

  -- X = accelerators_num
  -- r = tlb|mem|tot
  --
  -- tlb0,mem0,tot0
  --      ...
  --      ...
  -- tlbX,memX,totX

  function acc_offset (
    constant acc : integer range -1 to accelerators_num;
    constant reg : integer range 0 to 5
  )
    return integer is

    variable offset : integer;

  begin

    offset := (acc * 5) + reg;
    return noc_queues_full_offset(nocs_num - 1, tiles_num - 1, 5) + (offset * mon_acc_en);

  end function acc_offset;

  constant ACC_TLB    : integer range 0 to 4 := 0;
  constant ACC_MEM_LO : integer range 0 to 4 := 1;
  constant ACC_MEM_HI : integer range 0 to 4 := 2;
  constant ACC_TOT_LO : integer range 0 to 4 := 3;
  constant ACC_TOT_HI : integer range 0 to 4 := 4;

  -- X = l2_num
  -- r = hit|miss
  --
  -- hit0,miss0,
  --      ...
  --      ...
  -- hitX,missX,

  function l2_offset (
    constant l2 : integer range -1 to l2_num;
    constant reg : integer range 0 to 2
  )
    return integer is

    variable offset : integer;

  begin

    offset := (l2 * 2) + reg;
    return acc_offset(accelerators_num - 1, 5) + (offset * mon_l2_en);

  end function l2_offset;

  constant L2_HIT  : integer range 0 to 1 := 0;
  constant L2_MISS : integer range 0 to 1 := 1;

  -- X = llc_num
  -- r = hit|miss
  --
  -- hit0,miss0,
  --      ...
  --      ...
  -- hitX,missX,

  function llc_offset (
    constant llc : integer range -1 to llc_num;
    constant reg : integer range 0 to 2
  )
    return integer is

    variable offset : integer;

  begin

    offset := (llc * 2) + reg;
    return l2_offset(l2_num - 1, 2) + (offset * mon_llc_en);

  end function llc_offset;

  constant LLC_HIT  : integer range 0 to 1 := 0;
  constant LLC_MISS : integer range 0 to 1 := 1;

  constant VF_OP_POINTS : integer := 4;

  function dvfs_offset (
    constant tile : integer range 0 to tiles_num;
    constant pair : integer range 0 to VF_OP_POINTS
  )
    return integer is

    variable offset : integer;

  begin

    offset := (tile * VF_OP_POINTS) + pair;
    return llc_offset(llc_num - 1, 2) + (offset * mon_dvfs_en);

  end function dvfs_offset;

  constant CTRL_REG_COUNT : integer := 4;

  function ctrl_offset (
    constant ctrl : integer range 0 to CTRL_REG_COUNT
  )
    return integer is

    variable offset : integer;

  begin -- ctrl_offset

    offset := ctrl;
    return dvfs_offset(tiles_num - 1, VF_OP_POINTS) + offset;

  end function ctrl_offset;

  constant CTRL_RESET           : integer := 0;
  constant CTRL_WINDOW_SIZE     : integer := 1;
  constant CTRL_WINDOW_COUNT_LO : integer := 2;
  constant CTRL_WINDOW_COUNT_HI : integer := 3;

  constant MONITOR_REG_COUNT : integer := ctrl_offset(0);
  constant REGISTER_COUNT    : integer := MONITOR_REG_COUNT + CTRL_REG_COUNT;
  constant REGISTER_WIDTH    : integer := mmi64_width;
  -- Counters must be updated using user_clk.
  constant DEFAULT_WINDOW : std_logic_vector(REGISTER_WIDTH - 1 downto 0) := conv_std_logic_vector(65536, REGISTER_WIDTH);

  signal mmi64_clk       : std_logic;
  signal mmi64_reset     : std_logic;
  signal mmi64_resetn    : std_logic;
  signal mmi64_dn_d      : std_logic_vector(63 downto 0);
  signal mmi64_dn_valid  : std_logic;
  signal mmi64_dn_accept : std_logic;
  signal mmi64_dn_start  : std_logic;
  signal mmi64_dn_stop   : std_logic;
  signal mmi64_up_d      : std_logic_vector(63 downto 0);
  signal mmi64_up_valid  : std_logic;
  signal mmi64_up_accept : std_logic;
  signal mmi64_up_start  : std_logic;
  signal mmi64_up_stop   : std_logic;

  signal reg_en     : std_logic;
  signal reg_we     : std_logic;
  signal reg_addr   : std_logic_vector(log2(REGISTER_COUNT) - 1 downto 0);
  signal reg_wdata  : std_logic_vector(REGISTER_WIDTH - 1 downto 0);
  signal reg_accept : std_logic;
  signal reg_rdata  : std_logic_vector(REGISTER_WIDTH - 1 downto 0);
  signal reg_rvalid : std_logic;

  type counter_type is array (0 to MONITOR_REG_COUNT - 1) of std_logic_vector(REGISTER_WIDTH - 1 downto 0);

  type counter_u_type is array (0 to MONITOR_REG_COUNT - 1) of std_logic_vector(REGISTER_WIDTH - 1 downto 0);

  signal count                         : counter_type;
  signal count_value, count_value_sync : counter_type;
  signal count_value_tmp               : counter_u_type;
  signal count_reset                   : std_logic_vector(0 to MONITOR_REG_COUNT - 1);

  signal window_size          : std_logic_vector(REGISTER_WIDTH - 1 downto 0);
  signal time_counter         : std_logic_vector(REGISTER_WIDTH - 1 downto 0);
  signal window_reset         : std_logic;
  signal new_window           : std_logic;
  signal new_window_delayed   : std_logic;
  signal new_window_sync_ddr  : std_logic_vector(0 to ddrs_num - 1);
  signal new_window_sync_mem  : std_logic_vector(0 to ddrs_num + slms_num - 1);
  signal new_window_sync_noc  : std_logic_vector(0 to nocs_num - 1);
  signal new_window_sync_acc  : std_logic_vector(0 to accelerators_num - 1);
  signal new_window_sync_l2   : std_logic_vector(0 to l2_num - 1);
  signal new_window_sync_llc  : std_logic_vector(0 to llc_num - 1);
  signal new_window_sync_dvfs : std_logic_vector(0 to tiles_num - 1);
  signal updated_ddr          : std_logic_vector(0 to ddrs_num - 1);
  signal updated_mem          : std_logic_vector(0 to ddrs_num + slms_num - 1);
  signal updated_noc          : std_logic_vector(0 to nocs_num - 1);
  signal updated_acc          : std_logic_vector(0 to accelerators_num - 1);
  signal updated_l2           : std_logic_vector(0 to l2_num - 1);
  signal updated_llc          : std_logic_vector(0 to llc_num - 1);
  signal updated_dvfs         : std_logic_vector(0 to tiles_num - 1);

  signal window_count : std_logic_vector(63 downto 0);

  type accelerator_cycles_counter_type is array (0 to accelerators_num - 1) of std_logic_vector(2 * REGISTER_WIDTH - 1 downto 0);

  signal accelerator_mem_count : accelerator_cycles_counter_type;
  signal accelerator_tot_count : accelerator_cycles_counter_type;

  type accelerator_cycles_small_counter_type is array (0 to accelerators_num - 1) of std_logic_vector(REGISTER_WIDTH - 1 downto 0);

  signal accelerator_tlb_count : accelerator_cycles_small_counter_type;
  signal temp_mon_sda          : std_logic := '0';
  signal temp_mon_scl          : std_logic := '0';

begin

  -----------------------------------------------------------------------------
  -- MMI64 Interface (mmi64_clk domain)
  -----------------------------------------------------------------------------
  u_profpga_ctrl : component profpga_ctrl
    generic map (
      device => profpga_device_table(memtech)
    )
    port map (
      -- access to FPGA pins
      clk0_p    => profpga_clk0_p,
      clk0_n    => profpga_clk0_n,
      sync0_p   => profpga_sync0_p,
      sync0_n   => profpga_sync0_n,
      srcclk_p  => open,
      srcclk_n  => open,
      srcsync_p => open,
      srcsync_n => open,
      dmbi_h2f  => dmbi_h2f,
      dmbi_f2h  => dmbi_f2h,
      xdmbi_h2f => (others => '0'),
      xdmbi_f2h => open,
      -- 200 MHz clock (useful for delay calibration)
      clk_200mhz_o => open,
      -- source clock/sync input, not used
      src_clk_i           => (others => '0'),
      src_clk_locked_i    => (others => '1'),
      src_event_id_i      => (others => '0'),
      src_event_en_i      => (others => '0'),
      src_event_busy_o    => open,
      src_event_reset_i   => (others => '1'),
      src_event_strobe1_i => (others => '0'),
      src_event_strobe2_i => (others => '0'),
      -- clk0 sync events (synchronized with mmi64_clk)
      clk0_event_id_o      => open,
      clk0_event_en_o      => open,
      clk0_event_strobe1_o => open,
      clk0_event_strobe2_o => open,
      -- MMI-64 access (synchronous to mmi64_clk)
      mmi64_present_i     => '1',
      mmi64_clk_o         => mmi64_clk,
      mmi64_reset_o       => mmi64_reset,
      mmi64_m_dn_d_o      => mmi64_dn_d,
      mmi64_m_dn_valid_o  => mmi64_dn_valid,
      mmi64_m_dn_accept_i => mmi64_dn_accept,
      mmi64_m_dn_start_o  => mmi64_dn_start,
      mmi64_m_dn_stop_o   => mmi64_dn_stop,
      mmi64_m_up_d_i      => mmi64_up_d,
      mmi64_m_up_valid_i  => mmi64_up_valid,
      mmi64_m_up_accept_o => mmi64_up_accept,
      mmi64_m_up_start_i  => mmi64_up_start,
      mmi64_m_up_stop_i   => mmi64_up_stop,
      -- clock configuration ports (synchronous to mmi64_clk), not used in this example
      clk1_cfg_dn_o => open,
      clk1_cfg_up_i => (others => '0'),
      clk2_cfg_dn_o => open,
      clk2_cfg_up_i => (others => '0'),
      clk3_cfg_dn_o => open,
      clk3_cfg_up_i => (others => '0'),
      clk4_cfg_dn_o => open,
      clk4_cfg_up_i => (others => '0'),
      clk5_cfg_dn_o => open,
      clk5_cfg_up_i => (others => '0'),
      clk6_cfg_dn_o => open,
      clk6_cfg_up_i => (others => '0'),
      clk7_cfg_dn_o => open,
      clk7_cfg_up_i => (others => '0'),
      -- Stratix 10 temperature monitor
      temp_mon_i2c_sda => temp_mon_sda,
      temp_mon_i2c_scl => temp_mon_scl,
      syscom_dn_o      => open,
      syscom_up_i      => (others => (others => '0'))
    );

  mmi64_resetn <= not mmi64_reset;

  user_regif : component mmi64_m_regif
    generic map (
      module_id         => 16#00000E5F#,
      register_count    => REGISTER_COUNT,
      register_width    => REGISTER_WIDTH,
      read_buffer_depth => 4
    )
    port map (
      -- clock and reset
      mmi64_clk           => mmi64_clk,
      mmi64_reset         => mmi64_reset,
      mmi64_h_dn_d_i      => mmi64_dn_d,
      mmi64_h_dn_valid_i  => mmi64_dn_valid,
      mmi64_h_dn_accept_o => mmi64_dn_accept,
      mmi64_h_dn_start_i  => mmi64_dn_start,
      mmi64_h_dn_stop_i   => mmi64_dn_stop,
      mmi64_h_up_d_o      => mmi64_up_d,
      mmi64_h_up_valid_o  => mmi64_up_valid,
      mmi64_h_up_accept_i => mmi64_up_accept,
      mmi64_h_up_start_o  => mmi64_up_start,
      mmi64_h_up_stop_o   => mmi64_up_stop,
      reg_en_o            => reg_en,
      reg_we_o            => reg_we,
      reg_addr_o          => reg_addr,
      reg_wdata_o         => reg_wdata,
      reg_accept_i        => reg_accept,
      reg_rdata_i         => reg_rdata,
      reg_rvalid_i        => reg_rvalid
    );

  synchronizer_input : for i in 0 to MONITOR_REG_COUNT - 1 generate

    synchronizer_1 : component synchronizer
      generic map (
        data_width => REGISTER_WIDTH
      )
      port map (
        clk     => mmi64_clk,
        reset_n => mmi64_resetn,
        data_i  => count_value(i),
        data_o  => count_value_tmp(i)
      );

    count_value_sync(i) <= count_value_tmp(i);
  end generate synchronizer_input;

  reg_read_write : process (mmi64_clk, mmi64_resetn) is

    variable addr, wdata    : integer;
    variable counters_addr  : integer range 0 to MONITOR_REG_COUNT - 1;
    variable counters_wdata : integer range 0 to MONITOR_REG_COUNT - 1;

  begin                                                                               -- process reg_select

    if (mmi64_resetn = '0') then                                                      -- asynchronous reset (active low)
      reg_rdata    <= (others => '0');
      reg_rvalid   <= '0';
      reg_accept   <= '0';
      count_reset  <= (others => '0');
      window_size  <= DEFAULT_WINDOW;
      window_reset <= '0';
      addr         := 0;
      wdata        := 0;
    elsif (mmi64_clk'event and mmi64_clk = '1') then                                  -- rising clock edge
      addr  := conv_integer(reg_addr);
      wdata := conv_integer(reg_wdata);
      if (addr < MONITOR_REG_COUNT) then
        counters_addr := addr;
      else
        counters_addr := 0;
      end if;
      if (wdata < MONITOR_REG_COUNT) then
        counters_wdata := wdata;
      else
        counters_wdata := 0;
      end if;

      count_reset  <= (others => '0');
      reg_accept   <= '0';
      reg_rvalid   <= '0';
      window_reset <= '0';

      if (reg_en = '1') then
        if (reg_we = '1') then
          -- write control registers at the beginning of a new window
          reg_accept <= new_window;
          if (addr = ctrl_offset(CTRL_RESET)) then                                    -- Reset counter
            count_reset(counters_wdata) <= '1';
          elsif (addr = ctrl_offset(CTRL_WINDOW_SIZE)) then                           -- Set window size
            window_reset <= '1';
            window_size  <= reg_wdata;
          end if;
        else
          if (addr = ctrl_offset(CTRL_WINDOW_COUNT_LO)) then
            -- read time stamp LO
            reg_rvalid <= '1';
            reg_accept <= '1';
            reg_rdata  <= window_count(REGISTER_WIDTH - 1 downto 0);
          elsif (addr = ctrl_offset(CTRL_WINDOW_COUNT_HI)) then
            -- read time stamp HI
            reg_rvalid <= '1';
            reg_accept <= '1';
            reg_rdata  <= window_count(2 * REGISTER_WIDTH - 1 downto REGISTER_WIDTH);
          elsif (addr = ctrl_offset(CTRL_WINDOW_SIZE)) then
            -- read current window size
            reg_rvalid <= '1';
            reg_accept <= '1';
            reg_rdata  <= window_size;
          else
            -- read counters only on new window after hold time
            reg_rvalid <= new_window_delayed;
            reg_accept <= new_window_delayed;
            reg_rdata  <= count_value_sync(counters_addr);
          end if;
        end if;
      end if;
    end if;

  end process reg_read_write;

  time_stamp_update : process (mmi64_clk, mmi64_resetn) is

    variable new_window_setup : std_logic_vector(REGISTER_WIDTH - 1 downto 0);

  begin                                                                            -- process time_stamp_update

    if (mmi64_resetn = '0') then                                                   -- asynchronous reset (active low)
      new_window         <= '0';
      new_window_delayed <= '0';
      window_count       <= (others => '0');
      time_counter       <= (others => '0');
      new_window_setup   := (others => '0');
    elsif (mmi64_clk'event and mmi64_clk = '1') then                               -- rising clock edge
      new_window_setup := window_size - conv_std_logic_vector(64, REGISTER_WIDTH);
      -- Advance time
      time_counter <= time_counter + 1;
      -- Advance window count
      if (time_counter = window_size or window_reset = '1') then
        time_counter       <= (others => '0');
        window_count       <= window_count + 1;
        new_window         <= '1';
        new_window_delayed <= '0';
      end if;

      if (time_counter = conv_std_logic_vector(10, REGISTER_WIDTH)) then
        -- hold new_window for 10 cycles to make sure perf. counters get the reset.
        new_window <= '0';
      end if;

      -- Prevent register read on window update
      if (time_counter = conv_std_logic_vector(64, REGISTER_WIDTH)) then
        -- 32 cycles are more than enough to make sure all counters are up to date!
        new_window_delayed <= '1';
      end if;
      if (time_counter = new_window_setup) then
        -- 32 cycles are more than enough to make sure all counters are up to date!
        new_window_delayed <= '0';
      end if;
    end if;

  end process time_stamp_update;

  -----------------------------------------------------------------------------
  -- Monitor and counters (user clk domain)
  -----------------------------------------------------------------------------

  ddr_monitor_enabled_gen : if mon_ddr_en /= 0 generate

    ddr_gen : for i in 0 to ddrs_num - 1 generate

      synchronizer_2 : component synchronizer
        generic map (
          data_width => 1
        )
        port map (
          clk       => mon_ddr(i).clk,
          reset_n   => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_ddr(i)
        );

      process (mon_ddr(i).clk, user_rstn) is
      begin                                                               -- process

        if (user_rstn = '0') then                                         -- asynchronous reset (active low)
          updated_ddr(i) <= '0';
        elsif (mon_ddr(i).clk'event and mon_ddr(i).clk = '1') then        -- rising clock edge
          if (new_window_sync_ddr(i) = '1' and updated_ddr(i) = '0') then
            updated_ddr(i) <= '1';
          elsif (new_window_sync_ddr(i) = '0') then
            updated_ddr(i) <= '0';
          end if;
        end if;

      end process;

      ddr_counter : process (mon_ddr(i).clk, user_rstn) is

        constant INDEX : integer := ddr_offset(i);

      begin                                                               -- process ddr0_counter

        if (user_rstn = '0') then                                         -- asynchronous reset (active low)
          count_value(index) <= (others => '0');
          count(index)       <= (others => '0');
        elsif (mon_ddr(i).clk'event and mon_ddr(i).clk = '1') then        -- rising clock edge
          if (mon_ddr(i).word_transfer = '1') then
            count(index) <= count(INDEX) + 1;
          end if;

          if (new_window_sync_ddr(i) = '1' and updated_ddr(i) = '0') then
            count(index)       <= (others => '0');
            count_value(index) <= count(INDEX);
          end if;

          if (count_reset(INDEX) = '1') then
            count(index)       <= (others => '0');
            count_value(index) <= (others => '0');
          end if;
        end if;

      end process ddr_counter;

    end generate ddr_gen;

  end generate ddr_monitor_enabled_gen;

  mem_monitor_enabled_gen : if mon_mem_en /= 0 generate

    mem_gen : for i in 0 to ddrs_num + slms_num - 1 generate

      synchronizer_mem : component synchronizer
        generic map (
          data_width => 1
        )
        port map (
          clk       => mon_mem(i).clk,
          reset_n   => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_mem(i)
        );

      process (mon_mem(i).clk, user_rstn) is
      begin                                                               -- process

        if (user_rstn = '0') then                                         -- asynchronous reset (active low)
          updated_mem(i) <= '0';
        elsif (mon_mem(i).clk'event and mon_mem(i).clk = '1') then        -- rising clock edge
          if (new_window_sync_mem(i) = '1' and updated_mem(i) = '0') then
            updated_mem(i) <= '1';
          elsif (new_window_sync_mem(i) = '0') then
            updated_mem(i) <= '0';
          end if;
        end if;

      end process;

      mem_counter : process (mon_mem(i).clk, user_rstn) is

        constant COH_REQ_INDEX     : integer := mem_offset(i, MEM_COH_REQ);
        constant COH_FWD_INDEX     : integer := mem_offset(i, MEM_COH_FWD);
        constant COH_RSP_RCV_INDEX : integer := mem_offset(i, MEM_COH_RSP_RCV);
        constant COH_RSP_SND_INDEX : integer := mem_offset(i, MEM_COH_RSP_SND);
        constant DMA_REQ_INDEX     : integer := mem_offset(i, MEM_DMA_REQ);
        constant DMA_RSP_INDEX     : integer := mem_offset(i, MEM_DMA_RSP);
        constant COH_DMA_REQ_INDEX : integer := mem_offset(i, MEM_COH_DMA_REQ);
        constant COH_DMA_RSP_INDEX : integer := mem_offset(i, MEM_COH_DMA_RSP);

      begin                                                               -- process mem_counter

        if (user_rstn = '0') then                                         -- asynchronous reset (active low)
          count_value(coh_req_index)     <= (others => '0');
          count_value(coh_fwd_index)     <= (others => '0');
          count_value(coh_rsp_rcv_index) <= (others => '0');
          count_value(coh_rsp_snd_index) <= (others => '0');
          count_value(dma_req_index)     <= (others => '0');
          count_value(dma_rsp_index)     <= (others => '0');
          count_value(coh_dma_req_index) <= (others => '0');
          count_value(coh_dma_rsp_index) <= (others => '0');
          count(coh_req_index)           <= (others => '0');
          count(coh_fwd_index)           <= (others => '0');
          count(coh_rsp_rcv_index)       <= (others => '0');
          count(coh_rsp_snd_index)       <= (others => '0');
          count(dma_req_index)           <= (others => '0');
          count(dma_rsp_index)           <= (others => '0');
          count(coh_dma_req_index)       <= (others => '0');
          count(coh_dma_rsp_index)       <= (others => '0');
        elsif (mon_mem(i).clk'event and mon_mem(i).clk = '1') then        -- rising clock edge
          if (mon_mem(i).coherent_req = '1') then
            count(coh_req_index) <= count(COH_REQ_INDEX) + 1;
          end if;
          if (mon_mem(i).coherent_fwd = '1') then
            count(coh_fwd_index) <= count(COH_FWD_INDEX) + 1;
          end if;
          if (mon_mem(i).coherent_rsp_rcv = '1') then
            count(coh_rsp_rcv_index) <= count(COH_RSP_RCV_INDEX) + 1;
          end if;
          if (mon_mem(i).coherent_rsp_snd = '1') then
            count(coh_rsp_snd_index) <= count(COH_RSP_SND_INDEX) + 1;
          end if;
          if (mon_mem(i).dma_req = '1') then
            count(dma_req_index) <= count(DMA_REQ_INDEX) + 1;
          end if;
          if (mon_mem(i).dma_rsp = '1') then
            count(dma_rsp_index) <= count(DMA_RSP_INDEX) + 1;
          end if;
          if (mon_mem(i).coherent_dma_req = '1') then
            count(coh_dma_req_index) <= count(COH_DMA_REQ_INDEX) + 1;
          end if;
          if (mon_mem(i).coherent_dma_rsp = '1') then
            count(coh_dma_rsp_index) <= count(COH_DMA_RSP_INDEX) + 1;
          end if;

          if (new_window_sync_mem(i) = '1' and updated_mem(i) = '0') then
            count(coh_req_index)     <= (others => '0');
            count(coh_fwd_index)     <= (others => '0');
            count(coh_rsp_rcv_index) <= (others => '0');
            count(coh_rsp_snd_index) <= (others => '0');
            count(dma_req_index)     <= (others => '0');
            count(dma_rsp_index)     <= (others => '0');
            count(coh_dma_req_index) <= (others => '0');
            count(coh_dma_rsp_index) <= (others => '0');

            count_value(coh_req_index)     <= count(COH_REQ_INDEX);
            count_value(coh_fwd_index)     <= count(COH_FWD_INDEX);
            count_value(coh_rsp_rcv_index) <= count(COH_RSP_RCV_INDEX);
            count_value(coh_rsp_snd_index) <= count(COH_RSP_SND_INDEX);
            count_value(dma_req_index)     <= count(DMA_REQ_INDEX);
            count_value(dma_rsp_index)     <= count(DMA_RSP_INDEX);
            count_value(coh_dma_req_index) <= count(COH_DMA_REQ_INDEX);
            count_value(coh_dma_rsp_index) <= count(COH_DMA_RSP_INDEX);
          end if;

          if (count_reset(COH_REQ_INDEX) = '1') then
            count(coh_req_index)       <= (others => '0');
            count_value(coh_req_index) <= (others => '0');
          end if;
          if (count_reset(COH_FWD_INDEX) = '1') then
            count(coh_fwd_index)       <= (others => '0');
            count_value(coh_fwd_index) <= (others => '0');
          end if;
          if (count_reset(COH_RSP_RCV_INDEX) = '1') then
            count(coh_rsp_rcv_index)       <= (others => '0');
            count_value(coh_rsp_rcv_index) <= (others => '0');
          end if;
          if (count_reset(COH_RSP_SND_INDEX) = '1') then
            count(coh_rsp_snd_index)       <= (others => '0');
            count_value(coh_rsp_snd_index) <= (others => '0');
          end if;
          if (count_reset(DMA_REQ_INDEX) = '1') then
            count(dma_req_index)       <= (others => '0');
            count_value(dma_req_index) <= (others => '0');
          end if;
          if (count_reset(DMA_RSP_INDEX) = '1') then
            count(dma_rsp_index)       <= (others => '0');
            count_value(dma_rsp_index) <= (others => '0');
          end if;
          if (count_reset(COH_DMA_REQ_INDEX) = '1') then
            count(coh_dma_req_index)       <= (others => '0');
            count_value(coh_dma_req_index) <= (others => '0');
          end if;
          if (count_reset(COH_DMA_RSP_INDEX) = '1') then
            count(coh_dma_rsp_index)       <= (others => '0');
            count_value(coh_dma_rsp_index) <= (others => '0');
          end if;
        end if;

      end process mem_counter;

    end generate mem_gen;

  end generate mem_monitor_enabled_gen;

  noc_monitor_enabled_gen : if (mon_noc_tile_inject_en + mon_noc_queues_full_en) /= 0 generate

    noc_gen : for i in 0 to nocs_num - 1 generate

      synchronizer_4 : component synchronizer
        generic map (
          data_width => 1
        )
        port map (
          clk       => mon_noc(i,0).clk,
          reset_n   => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_noc(i)
        );

      process (mon_noc(i, 0).clk, user_rstn) is
      begin                                                               -- process

        if (user_rstn = '0') then                                         -- asynchronous reset (active low)
          updated_noc(i) <= '0';
        elsif (mon_noc(i, 0).clk'event and mon_noc(i, 0).clk = '1') then  -- rising clock edge
          if (new_window_sync_noc(i) = '1' and updated_noc(i) = '0') then
            updated_noc(i) <= '1';
          elsif (new_window_sync_noc(i) = '0') then
            updated_noc(i) <= '0';
          end if;
        end if;

      end process;

      inject_gen : if mon_noc_tile_inject_en /= 0 generate

        noc_inject_counters : for k in 0 to tiles_num - 1 generate

          process (mon_noc(i, k).clk, user_rstn) is

            constant INDEX : integer := noc_tile_inject_offset(i, k);

          begin                                                               -- process

            if (user_rstn = '0') then                                         -- asynchronous reset (active low)
              count_value(index) <= (others => '0');
              count(index)       <= (others => '0');
            elsif (mon_noc(i, k).clk'event and mon_noc(i, k).clk = '1') then  -- rising clock edge
              if (mon_noc(i, k).tile_inject = '1') then
                count(index) <= count(INDEX) + 1;
              end if;

              if (new_window_sync_noc(i) = '1' and updated_noc(i) = '0') then
                count(index)       <= (others => '0');
                count_value(index) <= count(INDEX);
              end if;

              if (count_reset(INDEX) = '1') then
                count(index)       <= (others => '0');
                count_value(index) <= (others => '0');
              end if;
            end if;

          end process;

        end generate noc_inject_counters;

      end generate inject_gen;

      queues_full_gen : if mon_noc_queues_full_en /= 0 generate

        noc_queues_full_counters : for k in 0 to tiles_num - 1 generate

          noc_queue_dir_counters : for dir in 0 to 4 generate

            process (mon_noc(i, k).clk, user_rstn) is

              constant INDEX : integer := noc_queues_full_offset(i, k, dir);

            begin                                                               -- process

              if (user_rstn = '0') then                                         -- asynchronous reset (active low)
                count(index)       <= (others => '0');
                count_value(index) <= (others => '0');
              elsif (mon_noc(i, k).clk'event and mon_noc(i, k).clk = '1') then  -- rising clock edge
                if (mon_noc(i, k).queue_full(dir) = '1') then
                  count(index) <= count(INDEX) + 1;
                end if;

                if (new_window_sync_noc(i) = '1' and updated_noc(i) = '0') then
                  count(index)       <= (others => '0');
                  count_value(index) <= count(INDEX);
                end if;

                if (count_reset(INDEX) = '1') then
                  count(index)       <= (others => '0');
                  count_value(index) <= (others => '0');
                end if;
              end if;

            end process;

          end generate noc_queue_dir_counters;

        end generate noc_queues_full_counters;

      end generate queues_full_gen;

    end generate noc_gen;

  end generate noc_monitor_enabled_gen;

  mon_acc_gen : if mon_acc_en /= 0 generate

    accelerators_new_window_sync : for i in accelerators_num - 1 downto 0 generate

      synchronizer_5 : component synchronizer
        generic map (
          data_width => 1
        )
        port map (
          clk       => mon_acc(i).clk,
          reset_n   => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_acc(i)
        );

      process (mon_acc(i).clk, user_rstn) is
      begin                                                               -- process

        if (user_rstn = '0') then                                         -- asynchronous reset (active low)
          updated_acc(i) <= '0';
        elsif (mon_acc(i).clk'event and mon_acc(i).clk = '1') then        -- rising clock edge
          if (new_window_sync_acc(i) = '1' and updated_acc(i) = '0') then
            updated_acc(i) <= '1';
          elsif (new_window_sync_acc(i) = '0') then
            updated_acc(i) <= '0';
          end if;
        end if;

      end process;

    end generate accelerators_new_window_sync;

    accelerators_counters : for i in 0 to accelerators_num - 1 generate

      process (mon_acc(i).clk, user_rstn) is
      begin                                                                                                                   -- process

        if (user_rstn = '0') then                                                                                             -- asynchronous reset (active low)
          accelerator_tlb_count(i)               <= (others => '0');
          accelerator_mem_count(i)               <= (others => '0');
          accelerator_tot_count(i)               <= (others => '0');
          count_value(acc_offset(i, ACC_TLB))    <= (others => '0');
          count_value(acc_offset(i, ACC_MEM_LO)) <= (others => '0');
          count_value(acc_offset(i, ACC_MEM_HI)) <= (others => '0');
          count_value(acc_offset(i, ACC_TOT_LO)) <= (others => '0');
          count_value(acc_offset(i, ACC_TOT_HI)) <= (others => '0');
        elsif (mon_acc(i).clk'event and mon_acc(i).clk = '1') then                                                            -- rising clock edge
          if (mon_acc(i).done = '0') then
            if (mon_acc(i).go = '1' and mon_acc(i).run = '0') then
              accelerator_tlb_count(i) <= accelerator_tlb_count(i) + 1;
            end if;
            if (mon_acc(i).run = '1' or mon_acc(i).go = '1') then
              accelerator_tot_count(i) <= accelerator_tot_count(i) + 1;
            end if;
            if (mon_acc(i).run = '1' and mon_acc(i).burst = '1') then
              accelerator_mem_count(i) <= accelerator_mem_count(i) + 1;
            end if;
          end if;

          if (new_window_sync_acc(i) = '1' and updated_acc(i) = '0') then
            accelerator_tlb_count(i)               <= (others => '0');
            accelerator_mem_count(i)               <= (others => '0');
            accelerator_tot_count(i)               <= (others => '0');
            count_value(acc_offset(i, ACC_TLB))    <= accelerator_tlb_count(i);
            count_value(acc_offset(i, ACC_MEM_LO)) <= accelerator_mem_count(i)(REGISTER_WIDTH - 1 downto 0);
            count_value(acc_offset(i, ACC_MEM_HI)) <= accelerator_mem_count(i)(2 * REGISTER_WIDTH - 1 downto REGISTER_WIDTH);
            count_value(acc_offset(i, ACC_TOT_LO)) <= accelerator_tot_count(i)(REGISTER_WIDTH - 1 downto 0);
            count_value(acc_offset(i, ACC_TOT_HI)) <= accelerator_tot_count(i)(2 * REGISTER_WIDTH - 1 downto REGISTER_WIDTH);
          end if;

          -- Reset all counters when tot_lo count is reset
          if (count_reset(acc_offset(i, ACC_TOT_LO)) = '1') then
            accelerator_tlb_count(i)               <= (others => '0');
            accelerator_mem_count(i)               <= (others => '0');
            accelerator_tot_count(i)               <= (others => '0');
            count_value(acc_offset(i, ACC_TLB))    <= (others => '0');
            count_value(acc_offset(i, ACC_MEM_LO)) <= (others => '0');
            count_value(acc_offset(i, ACC_MEM_HI)) <= (others => '0');
            count_value(acc_offset(i, ACC_TOT_LO)) <= (others => '0');
            count_value(acc_offset(i, ACC_TOT_HI)) <= (others => '0');
          end if;
        end if;

      end process;

    end generate accelerators_counters;

  end generate mon_acc_gen;

  l2_monitor_enabled_gen : if mon_l2_en /= 0 generate

    l2_gen : for i in 0 to l2_num - 1 generate

      synchronizer_2 : component synchronizer
        generic map (
          data_width => 1
        )
        port map (
          clk       => mon_l2(i).clk,
          reset_n   => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_l2(i)
        );

      process (mon_l2(i).clk, user_rstn) is
      begin                                                             -- process

        if (user_rstn = '0') then                                       -- asynchronous reset (active low)
          updated_l2(i) <= '0';
        elsif (mon_l2(i).clk'event and mon_l2(i).clk = '1') then        -- rising clock edge
          if (new_window_sync_l2(i) = '1' and updated_l2(i) = '0') then
            updated_l2(i) <= '1';
          elsif (new_window_sync_l2(i) = '0') then
            updated_l2(i) <= '0';
          end if;
        end if;

      end process;

      l2_counter : process (mon_l2(i).clk, user_rstn) is

        constant HIT_INDEX  : integer := l2_offset(i, L2_HIT);
        constant MISS_INDEX : integer := l2_offset(i, L2_MISS);

      begin                                                             -- process l20_counter

        if (user_rstn = '0') then                                       -- asynchronous reset (active low)
          count_value(hit_index)  <= (others => '0');
          count_value(miss_index) <= (others => '0');
          count(hit_index)        <= (others => '0');
          count(miss_index)       <= (others => '0');
        elsif (mon_l2(i).clk'event and mon_l2(i).clk = '1') then        -- rising clock edge
          if (mon_l2(i).hit = '1') then
            count(hit_index) <= count(HIT_INDEX) + 1;
          end if;
          if (mon_l2(i).miss = '1') then
            count(miss_index) <= count(MISS_INDEX) + 1;
          end if;

          if (new_window_sync_l2(i) = '1' and updated_l2(i) = '0') then
            count(hit_index)        <= (others => '0');
            count(miss_index)       <= (others => '0');
            count_value(hit_index)  <= count(HIT_INDEX);
            count_value(miss_index) <= count(MISS_INDEX);
          end if;

          if (count_reset(HIT_INDEX) = '1') then
            count(hit_index)       <= (others => '0');
            count_value(hit_index) <= (others => '0');
          end if;

          if (count_reset(MISS_INDEX) = '1') then
            count(miss_index)       <= (others => '0');
            count_value(miss_index) <= (others => '0');
          end if;
        end if;

      end process l2_counter;

    end generate l2_gen;

  end generate l2_monitor_enabled_gen;

  llc_monitor_enabled_gen : if mon_llc_en /= 0 generate

    llc_gen : for i in 0 to llc_num - 1 generate

      synchronizer_2 : component synchronizer
        generic map (
          data_width => 1
        )
        port map (
          clk       => mon_llc(i).clk,
          reset_n   => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_llc(i)
        );

      process (mon_llc(i).clk, user_rstn) is
      begin                                                               -- process

        if (user_rstn = '0') then                                         -- asynchronous reset (active low)
          updated_llc(i) <= '0';
        elsif (mon_llc(i).clk'event and mon_llc(i).clk = '1') then        -- rising clock edge
          if (new_window_sync_llc(i) = '1' and updated_llc(i) = '0') then
            updated_llc(i) <= '1';
          elsif (new_window_sync_llc(i) = '0') then
            updated_llc(i) <= '0';
          end if;
        end if;

      end process;

      llc_counter : process (mon_llc(i).clk, user_rstn) is

        constant HIT_INDEX  : integer := llc_offset(i, LLC_HIT);
        constant MISS_INDEX : integer := llc_offset(i, LLC_MISS);

      begin                                                               -- process llc0_counter

        if (user_rstn = '0') then                                         -- asynchronous reset (active low)
          count_value(hit_index)  <= (others => '0');
          count_value(miss_index) <= (others => '0');
          count(hit_index)        <= (others => '0');
          count(miss_index)       <= (others => '0');
        elsif (mon_llc(i).clk'event and mon_llc(i).clk = '1') then        -- rising clock edge
          if (mon_llc(i).hit = '1') then
            count(hit_index) <= count(HIT_INDEX) + 1;
          end if;
          if (mon_llc(i).miss = '1') then
            count(miss_index) <= count(MISS_INDEX) + 1;
          end if;

          if (new_window_sync_llc(i) = '1' and updated_llc(i) = '0') then
            count(hit_index)        <= (others => '0');
            count(miss_index)       <= (others => '0');
            count_value(hit_index)  <= count(HIT_INDEX);
            count_value(miss_index) <= count(MISS_INDEX);
          end if;

          if (count_reset(HIT_INDEX) = '1') then
            count(hit_index)       <= (others => '0');
            count_value(hit_index) <= (others => '0');
          end if;

          if (count_reset(MISS_INDEX) = '1') then
            count(miss_index)       <= (others => '0');
            count_value(miss_index) <= (others => '0');
          end if;
        end if;

      end process llc_counter;

    end generate llc_gen;

  end generate llc_monitor_enabled_gen;

  mon_dvfs_gen : if mon_dvfs_en /= 0 generate

    mon_dvfs_tiles_gen : for i in 0 to tiles_num - 1 generate

      synchronizer_6 : component synchronizer
        generic map (
          data_width => 1
        )
        port map (
          clk       => mon_dvfs(i).clk,
          reset_n   => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_dvfs(i)
        );

      process (mon_dvfs(i).clk, user_rstn) is
      begin                                                                 -- process

        if (user_rstn = '0') then                                           -- asynchronous reset (active low)
          updated_dvfs(i) <= '0';
        elsif (mon_dvfs(i).clk'event and mon_dvfs(i).clk = '1') then        -- rising clock edge
          if (new_window_sync_dvfs(i) = '1' and updated_dvfs(i) = '0') then
            updated_dvfs(i) <= '1';
          elsif (new_window_sync_dvfs(i) = '0') then
            updated_dvfs(i) <= '0';
          end if;
        end if;

      end process;

      dvfs_op_counters : for k in 0 to VF_OP_POINTS - 1 generate

        process (mon_dvfs(i).clk, user_rstn) is

          constant INDEX : integer := dvfs_offset(i, k);

        begin                                                                 -- process

          if (user_rstn = '0') then                                           -- asynchronous reset (active low)
            count(index)       <= (others => '0');
            count_value(index) <= (others => '0');
          elsif (mon_dvfs(i).clk'event and mon_dvfs(i).clk = '1') then        -- rising clock edge
            if (mon_dvfs(i).vf(k) = '1') then
              count(index) <= count(INDEX) + 1;
            end if;

            if (new_window_sync_dvfs(i) = '1' and updated_dvfs(i) = '0') then
              count(index)       <= (others => '0');
              count_value(index) <= count(INDEX);
            end if;

            if (count_reset(INDEX) = '1') then
              count(index)       <= (others => '0');
              count_value(index) <= (others => '0');
            end if;
          end if;

        end process;

      end generate dvfs_op_counters;

    end generate mon_dvfs_tiles_gen;

  end generate mon_dvfs_gen;

  -- pragma translate_off
  boot_message : process is

    variable s   : line;
    variable dir : line;

  begin                                                                                                               -- process boot_message

    wait for 200 ns;
    write(s, "==========================" & LF);
    write(s, "MMI64 monitors address map" & LF);
    writeline(output, s);

    if (mon_ddr_en /= 0) then

      for i in 0 to ddrs_num - 1 loop

        write(s, "DDR" & integer'image(i) & ": " & integer'image(ddr_offset(i)) & LF);
        writeline(output, s);

      end loop;                                                                                                       -- i

    end if;

    if (mon_mem_en /= 0) then

      for i in 0 to ddrs_num + slms_num - 1 loop

        write(s, "MEM-" & integer'image(i) & ".coh_req : " & integer'image(mem_offset(i, MEM_COH_REQ)) & LF);
        writeline(output, s);
        write(s, "MEM-" & integer'image(i) & ".coh_fwd : " & integer'image(mem_offset(i, MEM_COH_FWD)) & LF);
        writeline(output, s);
        write(s, "MEM-" & integer'image(i) & ".coh_rsp_rcv : " & integer'image(mem_offset(i, MEM_COH_RSP_RCV)) & LF);
        writeline(output, s);
        write(s, "MEM-" & integer'image(i) & ".coh_rsp_snd : " & integer'image(mem_offset(i, MEM_COH_RSP_SND)) & LF);
        writeline(output, s);
        write(s, "MEM-" & integer'image(i) & ".dma_req : " & integer'image(mem_offset(i, MEM_DMA_REQ)) & LF);
        writeline(output, s);
        write(s, "MEM-" & integer'image(i) & ".dma_rsp : " & integer'image(mem_offset(i, MEM_DMA_RSP)) & LF);
        writeline(output, s);
        write(s, "MEM-" & integer'image(i) & ".coh_dma_req : " & integer'image(mem_offset(i, MEM_COH_DMA_REQ)) & LF);
        writeline(output, s);
        write(s, "MEM-" & integer'image(i) & ".coh_dma_rsp : " & integer'image(mem_offset(i, MEM_COH_DMA_RSP)) & LF);
        writeline(output, s);

      end loop;                                                                                                       -- i

    end if;

    if (mon_noc_tile_inject_en /= 0) then

      for i in 0 to nocs_num - 1 loop

        for k in 0 to tiles_num - 1 loop

          write(s, "NoC" & integer'image(i) & ".tile_inject" & integer'image(k) & ": "
                & integer'image(noc_tile_inject_offset(i,k)) & LF);
          writeline(output, s);

        end loop;                                                                                                     -- k

      end loop;                                                                                                       -- i

    end if;

    if (mon_noc_queues_full_en /= 0) then

      for i in 0 to nocs_num - 1 loop

        for k in 0 to tiles_num - 1 loop

          for z in 0 to 4 loop

            case z is

              when DIR_N =>

                write(s, "NoC" & integer'image(i) & ".queue_n_full" & integer'image(k) & ": "
                      & integer'image(noc_queues_full_offset(i,k,z)) & LF);

              when DIR_S =>

                write(s, "NoC" & integer'image(i) & ".queue_s_full" & integer'image(k) & ": "
                      & integer'image(noc_queues_full_offset(i,k,z)) & LF);

              when DIR_W =>

                write(s, "NoC" & integer'image(i) & ".queue_w_full" & integer'image(k) & ": "
                      & integer'image(noc_queues_full_offset(i,k,z)) & LF);

              when DIR_E =>

                write(s, "NoC" & integer'image(i) & ".queue_e_full" & integer'image(k) & ": "
                      & integer'image(noc_queues_full_offset(i,k,z)) & LF);

              when DIR_L =>

                write(s, "NoC" & integer'image(i) & ".queue_l_full" & integer'image(k) & ": "
                      & integer'image(noc_queues_full_offset(i,k,z)) & LF);

              when others =>

                null;

            end case;

            writeline(output, s);

          end loop;                                                                                                   -- z

        end loop;                                                                                                     -- k

      end loop;                                                                                                       -- i

    end if;

    if (mon_acc_en /= 0) then

      for k in 0 to accelerators_num - 1 loop

        for z in 0 to 4 loop

          case z is

            when ACC_TLB =>

              write(s, "acc" & integer'image(k) & ".tlb   " & ": "
                    & integer'image(acc_offset(k,z)) & LF);

            when ACC_MEM_LO =>

              write(s, "acc" & integer'image(k) & ".mem_lo" & ": "
                    & integer'image(acc_offset(k,z)) & LF);

            when ACC_MEM_HI =>

              write(s, "acc" & integer'image(k) & ".mem_hi" & ": "
                    & integer'image(acc_offset(k,z)) & LF);

            when ACC_TOT_LO =>

              write(s, "acc" & integer'image(k) & ".tot_lo" & ": "
                    & integer'image(acc_offset(k,z)) & LF);

            when ACC_TOT_HI =>

              write(s, "acc" & integer'image(k) & ".tot_hi" & ": "
                    & integer'image(acc_offset(k,z)) & LF);

            when others =>

              null;

          end case;

          writeline(output, s);

        end loop;                                                                                                     -- z

      end loop;                                                                                                       -- k

    end if;

    if (mon_l2_en /= 0) then

      for i in 0 to l2_num - 1 loop

        write(s, "L2-" & integer'image(i) & ".hit : " & integer'image(l2_offset(i, L2_HIT)) & LF);
        writeline(output, s);
        write(s, "L2-" & integer'image(i) & ".miss: " & integer'image(l2_offset(i, L2_MISS)) & LF);
        writeline(output, s);

      end loop;                                                                                                       -- i

    end if;

    if (mon_llc_en /= 0) then

      for i in 0 to llc_num - 1 loop

        write(s, "LLC-" & integer'image(i) & ".hit : " & integer'image(llc_offset(i, LLC_HIT)) & LF);
        writeline(output, s);
        write(s, "LLC-" & integer'image(i) & ".miss: " & integer'image(llc_offset(i, LLC_MISS)) & LF);
        writeline(output, s);

      end loop;                                                                                                       -- i

    end if;

    if (mon_dvfs_en /= 0) then

      for k in 0 to tiles_num - 1 loop

        for z in 0 to VF_OP_POINTS - 1 loop

          write(s, "dvfs" & integer'image(k) & ".op"  & integer'image(z) & ": "
                & integer'image(dvfs_offset(k,z)) & LF);
          writeline(output, s);

        end loop;                                                                                                     -- z

      end loop;                                                                                                       -- k

    end if;

    write(s, "TOTAL MONITOR REGISTERS: " & integer'image(MONITOR_REG_COUNT) & LF);
    writeline(output, s);

    for z in 0 to CTRL_REG_COUNT - 1 loop

      case z is

        when CTRL_RESET =>

          write(s, "CTRL" & ".reset " & ": " & integer'image(ctrl_offset(z)) & LF);

        when CTRL_WINDOW_SIZE =>

          write(s, "CTRL" & ".win_sz" & ": " & integer'image(ctrl_offset(z)) & LF);

        when CTRL_WINDOW_COUNT_LO =>

          write(s, "CTRL" & ".win_lo" & ": " & integer'image(ctrl_offset(z)) & LF);

        when CTRL_WINDOW_COUNT_HI =>

          write(s, "CTRL" & ".win_hi" & ": " & integer'image(ctrl_offset(z)) & LF);

        when others =>

          null;

      end case;

      writeline(output, s);

    end loop;                                                                                                         -- z

    write(s, "TOTAL CTRL MONITOR: " & integer'image(CTRL_REG_COUNT) & LF);
    writeline(output, s);
    write(s, "TOTAL MMI64 REG COUNT: " & integer'image(REGISTER_COUNT) & LF);
    writeline(output, s);
    write(s, "==========================" & LF);
    writeline(output, s);
    wait;

  end process boot_message;

-- pragma translate_on

end architecture rtl;
