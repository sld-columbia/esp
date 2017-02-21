-------------------------------------------------------------------------------
-- Monitoring interface for proFPGA mmi64 debug interface
-- Copyright (C) 2014 - 2015, Columbia University
-------------------------------------------------------------------------------
-- author    : Paolo Mantovani
-- contact   : paolo @ cs . columbia . edu
-- filename  : monitor.vhd
-- enity     : monitor
-- purpose   : providing an interface between mmi64_regif and the user design
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.allclkgen.all;

--pragma translate off
use std.textio.all;
library unisim;
use unisim.vcomponents.all;
--pragma translate_on

library profpga;
use profpga.afifo_core_pkg.all;
use profpga.mmi64_pkg.all;
use profpga.profpga_pkg.all;
use profpga.mmi64_m_regif_comp.all;

use work.sldcommon.all;

entity monitor is

  generic (
    memtech                : integer;
    mmi64_width            : integer;
    ddrs_num               : integer;
    nocs_num               : integer;
    tiles_num              : integer;
    accelerators_num       : integer;
    mon_ddr_en             : integer;
    mon_noc_tile_inject_en : integer;
    mon_noc_queues_full_en : integer;
    mon_acc_en             : integer;
    mon_dvfs_en            : integer);
  port (
    profpga_clk0_p  : in  std_ulogic; -- 100 MHz clock
    profpga_clk0_n  : in  std_ulogic; -- 100 MHz clock
    profpga_sync0_p : in  std_ulogic;
    profpga_sync0_n : in  std_ulogic;
    dmbi_h2f        : in  std_ulogic_vector(19 downto 0);
    dmbi_f2h        : out std_ulogic_vector(19 downto 0);
    user_rstn       : in  std_ulogic;
    mon_ddr         : in  monitor_ddr_vector(0 to ddrs_num-1);
    mon_noc         : in  monitor_noc_matrix(0 to nocs_num-1, 0 to tiles_num-1);
    mon_acc         : in  monitor_acc_vector(0 to accelerators_num-1);
    mon_dvfs        : in  monitor_dvfs_vector(0 to tiles_num-1)
    );

end monitor;

architecture rtl of monitor is

  -- X = ddrs_num
  --
  -- r0
  -- r1
  -- ...
  -- rX
  function mem_offset (
    constant ddr : integer range 0 to ddrs_num)
    return integer is
    variable offset : integer;
  begin  -- mem_offset
    offset := ddr;
    return offset * mon_ddr_en;
  end mem_offset;

  -- X = nocs_num
  -- Y = tiles_num
  --
  -- r00  r01  ...  r0Y
  -- r10  ...  ...  ...
  -- ...  ...  ...  ...
  -- rX0  ...  ...  rXY
  function noc_tile_inject_offset (
    constant plane : integer range 0 to nocs_num;
    constant tile  : integer range 0 to tiles_num)
    return integer is
    variable offset : integer;
  begin  -- noc_offset
    offset := (plane * tiles_num) + tile;
    return mem_offset(ddrs_num) + (offset * mon_noc_tile_inject_en);
  end noc_tile_inject_offset;

  -- X = nocs_num
  -- Y = tiles_num
  -- r = n|s|w|e|l
  --
  -- n00,s00,w00,e00,l00  ...  ...  n0Y,s0Y,w0Y,e0Y,l0Y
  --         ...          ...  ...         ...
  --         ...          ...  ...         ...
  -- nX0,sX0,wX0,eX0,lX0  ...  ...  nXY,sXY,wXY,eXY,lXY
  function noc_queues_full_offset (
    constant plane     : integer range 0 to nocs_num;
    constant tile      : integer range 0 to tiles_num;
    constant direction : integer range 0 to 5)
    return integer is
    variable offset : integer;
  begin
    offset := (plane * tiles_num * 5) + (tile * 5) + direction;
    return noc_tile_inject_offset(nocs_num-1, tiles_num) + (offset * mon_noc_queues_full_en);
  end noc_queues_full_offset;
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
    constant reg : integer range 0 to 5)
    return integer is
    variable offset : integer;
  begin
    offset := (acc * 5) + reg;
    return noc_queues_full_offset(nocs_num-1, tiles_num-1, 5) + (offset * mon_acc_en);
  end acc_offset;
  constant ACC_TLB    : integer range 0 to 4 := 0;
  constant ACC_MEM_LO : integer range 0 to 4 := 1;
  constant ACC_MEM_HI : integer range 0 to 4 := 2;
  constant ACC_TOT_LO : integer range 0 to 4 := 3;
  constant ACC_TOT_HI : integer range 0 to 4 := 4;

  constant VF_OP_POINTS : integer := 4;
  function dvfs_offset (
    constant tile : integer range 0 to tiles_num;
    constant pair : integer range 0 to VF_OP_POINTS)
    return integer is
    variable offset : integer;
  begin
    offset := (tile * VF_OP_POINTS) + pair;
    return acc_offset(accelerators_num-1, 5) + (offset * mon_dvfs_en);
  end dvfs_offset;

  constant CTRL_REG_COUNT              : integer := 4;
  function ctrl_offset (
    constant ctrl : integer range 0 to CTRL_REG_COUNT)
    return integer is
    variable offset : integer;
  begin  -- ctrl_offset
    offset := ctrl;
    return dvfs_offset(tiles_num-1, VF_OP_POINTS) + offset;
  end ctrl_offset;
  constant CTRL_RESET           : integer := 0;
  constant CTRL_WINDOW_SIZE     : integer := 1;
  constant CTRL_WINDOW_COUNT_LO : integer := 2;
  constant CTRL_WINDOW_COUNT_HI : integer := 3;

  constant MONITOR_REG_COUNT : integer := ctrl_offset(0);
  constant REGISTER_COUNT    : integer := MONITOR_REG_COUNT + CTRL_REG_COUNT;
  constant REGISTER_WIDTH    : integer := mmi64_width;
  -- Counters must be updated using user_clk.
  constant DEFAULT_WINDOW : std_logic_vector(REGISTER_WIDTH-1 downto 0) := conv_std_logic_vector(65536, REGISTER_WIDTH);

  signal mmi64_clk                                     : std_ulogic;
  signal mmi64_reset                                   : std_ulogic;
  signal mmi64_resetn                                  : std_ulogic;
  signal mmi64_dn_d                                    : mmi64_data_t;
  signal mmi64_dn_valid                                : std_ulogic;
  signal mmi64_dn_accept : std_ulogic;
  signal mmi64_dn_start                                : std_ulogic;
  signal mmi64_dn_stop                                 : std_ulogic;
  signal mmi64_up_d                                    : mmi64_data_t;
  signal mmi64_up_valid                                : std_ulogic;
  signal mmi64_up_accept : std_ulogic;
  signal mmi64_up_start                                : std_ulogic;
  signal mmi64_up_stop                                 : std_ulogic;

  signal reg_en     : std_ulogic;
  signal reg_we     : std_ulogic;
  signal reg_addr   : std_ulogic_vector(log2(REGISTER_COUNT)-1 downto 0);
  signal reg_wdata  : std_ulogic_vector(REGISTER_WIDTH-1 downto 0);
  signal reg_accept : std_ulogic;
  signal reg_rdata  : std_ulogic_vector(REGISTER_WIDTH-1 downto 0);
  signal reg_rvalid : std_ulogic;

  type counter_type is array (0 to MONITOR_REG_COUNT-1) of std_logic_vector(REGISTER_WIDTH-1 downto 0);
  type counter_u_type is array (0 to MONITOR_REG_COUNT-1) of std_ulogic_vector(REGISTER_WIDTH-1 downto 0);
  signal count : counter_type;
  signal count_value, count_value_sync : counter_type;
  signal count_value_tmp : counter_u_type;
  signal count_reset  : std_logic_vector(0 to MONITOR_REG_COUNT-1);

  signal window_size            : std_logic_vector(REGISTER_WIDTH-1 downto 0);
  signal time_counter           : std_logic_vector(REGISTER_WIDTH-1 downto 0);
  signal window_reset           : std_ulogic;
  signal new_window             : std_ulogic;
  signal new_window_delayed     : std_ulogic;
  signal new_window_sync_ddr    : std_logic_vector(0 to ddrs_num-1);
  signal new_window_sync_noc    : std_logic_vector(0 to nocs_num-1);
  signal new_window_sync_acc    : std_logic_vector(0 to accelerators_num-1);
  signal new_window_sync_dvfs   : std_logic_vector(0 to tiles_num-1);
  signal updated_ddr    : std_logic_vector(0 to ddrs_num-1);
  signal updated_noc    : std_logic_vector(0 to nocs_num-1);
  signal updated_acc    : std_logic_vector(0 to accelerators_num-1);
  signal updated_dvfs   : std_logic_vector(0 to tiles_num-1);

  signal window_count : std_logic_vector(63 downto 0);

  type accelerator_cycles_counter_type is array (0 to accelerators_num - 1) of std_logic_vector(2*REGISTER_WIDTH-1 downto 0);
  signal accelerator_mem_count : accelerator_cycles_counter_type;
  signal accelerator_tot_count : accelerator_cycles_counter_type;
  type accelerator_cycles_small_counter_type is array (0 to accelerators_num - 1) of std_logic_vector(REGISTER_WIDTH-1 downto 0);
  signal accelerator_tlb_count : accelerator_cycles_small_counter_type;

begin

  --pragma translate_off
  no_v7: if memtech /= virtex7 generate
    assert false report "mmi64 is only supported on Virtex7 FPGAs mounted on proFPGA systems" severity error;
  end generate no_v7;
  --pragma translate_on

  -----------------------------------------------------------------------------
  -- MMI64 Interface (mmi64_clk domain)
  -----------------------------------------------------------------------------
  U_PROFPGA_CTRL : profpga_ctrl
    port map (
      -- access to FPGA pins
      clk0_p        => profpga_clk0_p,
      clk0_n        => profpga_clk0_n,
      sync0_p       => profpga_sync0_p,
      sync0_n       => profpga_sync0_n,
      srcclk_p      => open,
      srcclk_n      => open,
      srcsync_p     => open,
      srcsync_n     => open,
      dmbi_h2f      => dmbi_h2f,
      dmbi_f2h      => dmbi_f2h,
      -- 200 MHz clock (useful for delay calibration)
      clk_200mhz_o => open,
      -- source clock/sync input, not used
      src_clk_i           => (others => '0'),
      src_clk_locked_i    => (others => '1'),
      src_event_id_i      => (others => (others => '0')),
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
      clk7_cfg_up_i => (others => '0')
      );

  mmi64_resetn <= not mmi64_reset;

  USER_REGIF : mmi64_m_regif
    generic map (
      MODULE_ID         => X"FEEDBACC",
      REGISTER_COUNT    => REGISTER_COUNT,
      REGISTER_WIDTH    => REGISTER_WIDTH,
      READ_BUFFER_DEPTH => 4      --! number of entries in read data buffer
      ) port map (
        -- clock and reset
        mmi64_clk   => mmi64_clk,
        mmi64_reset => mmi64_reset,
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
        reg_en_o     => reg_en,
        reg_we_o     => reg_we,
        reg_addr_o   => reg_addr,
        reg_wdata_o  => reg_wdata,
        reg_accept_i => reg_accept,
        reg_rdata_i  => reg_rdata,
        reg_rvalid_i => reg_rvalid
        );

  synchronizer_input: for i in 0 to MONITOR_REG_COUNT - 1 generate
    synchronizer_1: synchronizer
      generic map (
        DATA_WIDTH => REGISTER_WIDTH)
      port map (
        clk    => mmi64_clk,
        reset_n => mmi64_resetn,
        data_i => to_stdULogicVector(count_value(i)),
        data_o => count_value_tmp(i));
    count_value_sync(i) <= to_stdLogicVector(count_value_tmp(i));
  end generate synchronizer_input;

  reg_read_write: process (mmi64_clk, mmi64_resetn)
    variable addr, wdata : integer;
    variable counters_addr : integer range 0 to MONITOR_REG_COUNT - 1;
    variable counters_wdata : integer range 0 to MONITOR_REG_COUNT - 1;
  begin -- process reg_select
    if mmi64_resetn = '0' then       -- asynchronous reset (active low)
      reg_rdata <= (others => '0');
      reg_rvalid <= '0';
      reg_accept <= '0';
      count_reset <= (others => '0');
      window_size <= DEFAULT_WINDOW;
      window_reset <= '0';
      addr := 0;
      wdata := 0;
    elsif mmi64_clk'event and mmi64_clk = '1' then -- rising clock edge
      addr := conv_integer(to_stdLogicVector(reg_addr));
      wdata := conv_integer(to_stdLogicVector(reg_wdata));
      if addr < MONITOR_REG_COUNT then
        counters_addr := addr;
      else
        counters_addr := 0;
      end if;
      if wdata < MONITOR_REG_COUNT then
        counters_wdata := wdata;
      else
        counters_wdata := 0;
      end if;

      count_reset <= (others => '0');
      reg_accept <= '0';
      reg_rvalid <= '0';
      window_reset <= '0';

      if reg_en = '1' then
        if reg_we = '1' then
          -- write control registers at the beginning of a new window
          reg_accept <= new_window;
          if addr = ctrl_offset(CTRL_RESET) then -- Reset counter
            count_reset(counters_wdata) <= '1';
          elsif addr = ctrl_offset(CTRL_WINDOW_SIZE) then -- Set window size
            window_reset <= '1';
            window_size <= to_stdLogicVector(reg_wdata);
          end if;
        else
          if addr = ctrl_offset(CTRL_WINDOW_COUNT_LO) then
            -- read time stamp LO
            reg_rvalid <= '1';
            reg_accept <= '1';
            reg_rdata <= to_stdULogicVector(window_count(REGISTER_WIDTH-1 downto 0));
          elsif addr = ctrl_offset(CTRL_WINDOW_COUNT_HI) then
            -- read time stamp HI
            reg_rvalid <= '1';
            reg_accept <= '1';
            reg_rdata <= to_stdULogicVector(window_count(2*REGISTER_WIDTH-1 downto REGISTER_WIDTH));
          elsif addr = ctrl_offset(CTRL_WINDOW_SIZE) then
            -- read current window size
            reg_rvalid <= '1';
            reg_accept <= '1';
            reg_rdata <= to_stdULogicVector(window_size);
          else
            -- read counters only on new window after hold time
            reg_rvalid <= new_window_delayed;
            reg_accept <= new_window_delayed;
            reg_rdata <= to_stdULogicVector(count_value_sync(counters_addr));
          end if;
        end if;
      end if;
    end if;
  end process reg_read_write;

  time_stamp_update: process (mmi64_clk, mmi64_resetn)
    variable new_window_setup : std_logic_vector(REGISTER_WIDTH-1 downto 0);
  begin -- process time_stamp_update
    if mmi64_resetn = '0' then         -- asynchronous reset (active low)
      new_window <= '0';
      new_window_delayed <= '0';
      window_count <= (others => '0');
      time_counter <= (others => '0');
      new_window_setup := (others => '0');
    elsif mmi64_clk'event and mmi64_clk = '1' then -- rising clock edge
      new_window_setup := window_size - conv_std_logic_vector(64, REGISTER_WIDTH);
      -- Advance time
      time_counter <= time_counter + 1;
      -- Advance window count
      if time_counter = window_size or window_reset = '1' then
        time_counter <= (others => '0');
        window_count <= window_count + 1;
        new_window <= '1';
        new_window_delayed <= '0';
      end if;

      if time_counter = conv_std_logic_vector(10, REGISTER_WIDTH) then
        -- hold new_window for 10 cycles to make sure perf. counters get the reset.
        new_window <= '0';
      end if;

      -- Prevent register read on window update
      if time_counter = conv_std_logic_vector(64, REGISTER_WIDTH) then
        -- 32 cycles are more than enough to make sure all counters are up to date!
        new_window_delayed <= '1';
      end if;
      if time_counter = new_window_setup then
        -- 32 cycles are more than enough to make sure all counters are up to date!
        new_window_delayed <= '0';
      end if;

    end if;
  end process time_stamp_update;


  -----------------------------------------------------------------------------
  -- Monitor and counters (user clk domain)
  -----------------------------------------------------------------------------

  ddr_monitor_enabled_gen: if mon_ddr_en /= 0 generate
    ddr_gen: for i in 0 to ddrs_num-1 generate
      synchronizer_2: synchronizer
        generic map (
          DATA_WIDTH => 1)
        port map (
          clk => mon_ddr(i).clk,
          reset_n => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_ddr(i));

      process (mon_ddr(i).clk, user_rstn)
      begin  -- process
        if user_rstn = '0' then         -- asynchronous reset (active low)
          updated_ddr(i) <= '0';
        elsif mon_ddr(i).clk'event and mon_ddr(i).clk = '1' then  -- rising clock edge
          if new_window_sync_ddr(i) = '1' and updated_ddr(i) = '0' then
            updated_ddr(i) <= '1';
          elsif new_window_sync_ddr(i) = '0' then
            updated_ddr(i) <= '0';
          end if;
        end if;
      end process;

      ddr_counter: process (mon_ddr(i).clk, user_rstn)
        constant index : integer := mem_offset(i);
      begin -- process ddr0_counter
        if user_rstn = '0' then -- asynchronous reset (active low)
          count_value(index) <= (others => '0');
          count(index) <= (others => '0');
        elsif mon_ddr(i).clk'event and mon_ddr(i).clk = '1' then -- rising clock edge
          if mon_ddr(i).word_transfer = '1' then
            count(index) <= count(index) + 1;
          end if;

          if new_window_sync_ddr(i) = '1' and updated_ddr(i) = '0' then
            count(index) <= (others => '0');
            count_value(index) <= count(index);
          end if;

          if count_reset(index) = '1' then
            count(index) <= (others => '0');
            count_value(index) <= (others => '0');
          end if;
        end if;
      end process ddr_counter;

    end generate ddr_gen;

  end generate ddr_monitor_enabled_gen;


  noc_monitor_enabled_gen: if (mon_noc_tile_inject_en + mon_noc_queues_full_en) /= 0 generate
    noc_gen: for i in 0 to nocs_num-1 generate
      synchronizer_4: synchronizer
        generic map (
          DATA_WIDTH => 1)
        port map (
          clk => mon_noc(i,0).clk,        -- NoC plane on single domain
          reset_n => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_noc(i));

      process (mon_noc(i, 0).clk, user_rstn)
      begin  -- process
        if user_rstn = '0' then         -- asynchronous reset (active low)
          updated_noc(i) <= '0';
        elsif mon_noc(i, 0).clk'event and mon_noc(i, 0).clk = '1' then  -- rising clock edge
          if new_window_sync_noc(i) = '1' and updated_noc(i) = '0' then
            updated_noc(i) <= '1';
          elsif new_window_sync_noc(i) = '0' then
            updated_noc(i) <= '0';
          end if;
        end if;
      end process;

      inject_gen: if mon_noc_tile_inject_en /= 0 generate

        noc_inject_counters: for k in 0 to tiles_num-1 generate
          process (mon_noc(i,k).clk, user_rstn)
            constant index : integer := noc_tile_inject_offset(i, k);
          begin -- process
            if user_rstn = '0' then           -- asynchronous reset (active low)
              count_value(index) <= (others => '0');
              count(index) <= (others => '0');
            elsif mon_noc(i,k).clk'event and mon_noc(i,k).clk = '1' then  -- rising clock edge
              if mon_noc(i,k).tile_inject = '1' then
                count(index) <= count(index) + 1;
              end if;

              if new_window_sync_noc(i) = '1' and updated_noc(i) = '0' then
                count(index) <= (others => '0');
                count_value(index) <= count(index);
              end if;

              if count_reset(index) = '1' then
                count(index) <= (others => '0');
                count_value(index) <= (others => '0');
              end if;
            end if;
          end process;
        end generate noc_inject_counters;

      end generate inject_gen;


      queues_full_gen: if mon_noc_queues_full_en /= 0 generate

        noc_queues_full_counters: for k in 0 to tiles_num-1 generate
          noc_queue_dir_counters: for dir in 0 to 4 generate
            process (mon_noc(i,k).clk, user_rstn)
              constant index : integer := noc_queues_full_offset(i, k, dir);
            begin -- process
              if user_rstn = '0' then           -- asynchronous reset (active low)
                count(index) <= (others => '0');
                count_value(index) <= (others => '0');
              elsif mon_noc(i,k).clk'event and mon_noc(i,k).clk = '1' then  -- rising clock edge
                if mon_noc(i,k).queue_full(dir) = '1' then
                  count(index) <= count(index) + 1;
                end if;

                if new_window_sync_noc(i) = '1' and updated_noc(i) = '0' then
                  count(index) <= (others => '0');
                  count_value(index) <= count(index);
                end if;

                if count_reset(index) = '1' then
                  count(index) <= (others => '0');
                  count_value(index) <= (others => '0');
                end if;
              end if;
            end process;
          end generate noc_queue_dir_counters;
        end generate noc_queues_full_counters;

      end generate queues_full_gen;

    end generate noc_gen;
  end generate noc_monitor_enabled_gen;


  mon_acc_gen: if mon_acc_en /= 0 generate

    accelerators_new_window_sync: for i in accelerators_num - 1 downto 0 generate
      synchronizer_5: synchronizer
        generic map (
          DATA_WIDTH => 1)
        port map (
          clk => mon_acc(i).clk,
          reset_n => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_acc(i));

      process (mon_acc(i).clk, user_rstn)
      begin  -- process
        if user_rstn = '0' then         -- asynchronous reset (active low)
          updated_acc(i) <= '0';
        elsif mon_acc(i).clk'event and mon_acc(i).clk = '1' then  -- rising clock edge
          if new_window_sync_acc(i) = '1' and updated_acc(i) = '0' then
            updated_acc(i) <= '1';
          elsif new_window_sync_acc(i) = '0' then
            updated_acc(i) <= '0';
          end if;
        end if;
      end process;

  end generate accelerators_new_window_sync;

    accelerators_counters: for i in 0 to accelerators_num - 1 generate

      process (mon_acc(i).clk, user_rstn)
      begin -- process
        if user_rstn = '0' then           -- asynchronous reset (active low)
          accelerator_tlb_count(i) <=  (others => '0');
          accelerator_mem_count(i) <=  (others => '0');
          accelerator_tot_count(i) <=  (others => '0');
          count_value(acc_offset(i, ACC_TLB))    <= (others => '0');
          count_value(acc_offset(i, ACC_MEM_LO)) <= (others => '0');
          count_value(acc_offset(i, ACC_MEM_HI)) <= (others => '0');
          count_value(acc_offset(i, ACC_TOT_LO)) <= (others => '0');
          count_value(acc_offset(i, ACC_TOT_HI)) <= (others => '0');
        elsif mon_acc(i).clk'event and mon_acc(i).clk = '1' then -- rising clock edge
          if mon_acc(i).done = '0' then
            if mon_acc(i).go = '1' and mon_acc(i).run = '0' then
              accelerator_tlb_count(i) <= accelerator_tlb_count(i) + 1;
            end if;
            if mon_acc(i).run = '1' or mon_acc(i).go = '1' then
              accelerator_tot_count(i) <= accelerator_tot_count(i) + 1;
            end if;
            if mon_acc(i).run = '1' and mon_acc(i).burst = '1' then
              accelerator_mem_count(i) <= accelerator_mem_count(i) + 1;
            end if;
          end if;

          if new_window_sync_acc(i) = '1' and updated_acc(i) = '0' then
            accelerator_tlb_count(i) <= (others => '0');
            accelerator_mem_count(i) <= (others => '0');
            accelerator_tot_count(i) <= (others => '0');
            count_value(acc_offset(i, ACC_TLB))    <= accelerator_tlb_count(i);
            count_value(acc_offset(i, ACC_MEM_LO)) <= accelerator_mem_count(i)(REGISTER_WIDTH-1 downto 0);
            count_value(acc_offset(i, ACC_MEM_HI)) <= accelerator_mem_count(i)(2*REGISTER_WIDTH-1 downto REGISTER_WIDTH);
            count_value(acc_offset(i, ACC_TOT_LO)) <= accelerator_tot_count(i)(REGISTER_WIDTH-1 downto 0);
            count_value(acc_offset(i, ACC_TOT_HI)) <= accelerator_tot_count(i)(2*REGISTER_WIDTH-1 downto REGISTER_WIDTH);
          end if;

          -- Reset all counters when tot_lo count is reset
          if count_reset(acc_offset(i, ACC_TOT_LO)) = '1' then
            accelerator_tlb_count(i) <= (others => '0');
            accelerator_mem_count(i) <= (others => '0');
            accelerator_tot_count(i) <= (others => '0');
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

  mon_dvfs_gen: if mon_dvfs_en /= 0 generate

    mon_dvfs_tiles_gen: for i in 0 to tiles_num-1 generate
      synchronizer_6: synchronizer
        generic map (
          DATA_WIDTH => 1)
        port map (
          clk => mon_dvfs(i).clk,
          reset_n => user_rstn,
          data_i(0) => new_window,
          data_o(0) => new_window_sync_dvfs(i));

      process (mon_dvfs(i).clk, user_rstn)
      begin  -- process
        if user_rstn = '0' then         -- asynchronous reset (active low)
          updated_dvfs(i) <= '0';
        elsif mon_dvfs(i).clk'event and mon_dvfs(i).clk = '1' then  -- rising clock edge
          if new_window_sync_dvfs(i) = '1' and updated_dvfs(i) = '0' then
            updated_dvfs(i) <= '1';
          elsif new_window_sync_dvfs(i) = '0' then
            updated_dvfs(i) <= '0';
          end if;
        end if;
      end process;

      dvfs_op_counters: for k in 0 to VF_OP_POINTS-1 generate
        process (mon_dvfs(i).clk, user_rstn)
          constant index : integer := dvfs_offset(i, k);
        begin -- process
          if user_rstn = '0' then           -- asynchronous reset (active low)
            count(index) <= (others => '0');
            count_value(index) <= (others => '0');
          elsif mon_dvfs(i).clk'event and mon_dvfs(i).clk = '1' then  -- rising clock edge
            if mon_dvfs(i).vf(k) = '1' then
              count(index) <= count(index) + 1;
            end if;

            if new_window_sync_dvfs(i) = '1' and updated_dvfs(i) = '0' then
              count(index) <= (others => '0');
              count_value(index) <= count(index);
            end if;

            if count_reset(index) = '1' then
              count(index) <= (others => '0');
              count_value(index) <= (others => '0');
            end if;
          end if;
        end process;
      end generate dvfs_op_counters;

    end generate mon_dvfs_tiles_gen;

  end generate mon_dvfs_gen;

  --pragma translate_off
  boot_message: process
    variable s : line;
    variable dir : line;
  begin  -- process boot_message
    wait for 200 ns;
    write(s, "==========================" & LF);
    write(s, "MMI64 monitors address map" & LF);
    writeline(output,s);
    if mon_ddr_en /= 0 then
      for i in 0 to ddrs_num-1 loop
        write(s, "DDR" & integer'image(i) & ": " & integer'image(mem_offset(i)) & LF);
        writeline(output,s);
      end loop;  -- i
    end if;

    if mon_noc_tile_inject_en /= 0 then
      for i in 0 to nocs_num-1 loop
        for k in 0 to tiles_num-1 loop
          write(s, "NoC" & integer'image(i) & ".tile_inject" & integer'image(k) & ": "
                & integer'image(noc_tile_inject_offset(i,k)) & LF);
          writeline(output, s);
        end loop; --k
      end loop;  -- i
    end if;

    if mon_noc_queues_full_en /= 0 then
      for i in 0 to nocs_num-1 loop
        for k in 0 to tiles_num-1 loop
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
              when others => null;
            end case;
            writeline(output, s);
          end loop;  -- z
        end loop; --k
      end loop;  -- i
    end if;

    if mon_acc_en /= 0 then
      for k in 0 to accelerators_num-1 loop
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
            when others => null;
          end case;
          writeline(output, s);
        end loop;  -- z
      end loop; --k
    end if;

    if mon_dvfs_en /= 0 then
      for k in 0 to tiles_num-1 loop
        for z in 0 to VF_OP_POINTS-1 loop
              write(s, "dvfs" & integer'image(k) & ".op"  & integer'image(z) & ": "
                    & integer'image(dvfs_offset(k,z)) & LF);
          writeline(output, s);
        end loop;  -- z
      end loop; --k
    end if;

    write(s, "TOTAL MONITOR REGISTERS: " & integer'image(MONITOR_REG_COUNT) & LF);
    writeline(output,s);
    for z in 0 to CTRL_REG_COUNT-1 loop
      case z is
        when CTRL_RESET =>
          write(s, "CTRL" & ".reset " & ": " & integer'image(ctrl_offset(z)) & LF);
        when CTRL_WINDOW_SIZE =>
          write(s, "CTRL" & ".win_sz" & ": " & integer'image(ctrl_offset(z)) & LF);
        when CTRL_WINDOW_COUNT_LO =>
          write(s, "CTRL" & ".win_lo" & ": " & integer'image(ctrl_offset(z)) & LF);
        when CTRL_WINDOW_COUNT_HI =>
          write(s, "CTRL" & ".win_hi" & ": " & integer'image(ctrl_offset(z)) & LF);
        when others => null;
      end case;
      writeline(output, s);
    end loop;  -- z
    write(s, "TOTAL CTRL MONITOR: " & integer'image(CTRL_REG_COUNT) & LF);
    writeline(output,s);
    write(s, "TOTAL MMI64 REG COUNT: " & integer'image(REGISTER_COUNT) & LF);
    writeline(output,s);
    write(s, "==========================" & LF);
    writeline(output, s);
    wait;
  end process boot_message;
  --pragma translate_on

end;
