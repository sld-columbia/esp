-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.allclkgen.all;
use work.gencomp.all;
use work.genacc.all;

use work.monitor_pkg.all;
use work.nocpackage.all;
use work.tile.all;
use work.dvfs.all;

use work.esp_acc_regmap.all;

entity dvfs_fsm is

  generic (
    tech : integer;
    extra_clk_buf : integer range 0 to 1 := 1);

  port (
    rst           : in  std_ulogic;
    refclk        : in  std_ulogic;
    pllbypass     : in  std_ulogic;
    pllclk        : out std_ulogic;
    clear_command : out std_ulogic;
    sample_status : out std_ulogic;
    voltage       : out std_logic_vector(31 downto 0);
    frequency     : out std_logic_vector(31 downto 0);
    qadc          : out std_logic_vector(31 downto 0);
    bank          : in  bank_type(0 to MAXREGNUM - 1);
    acc_idle      : in  std_ulogic;
    traffic       : in  std_ulogic;
    burst         : in  std_ulogic;
    --Monitor signals
    mon_dvfs      : out monitor_dvfs_type);

end dvfs_fsm;

architecture rtl of dvfs_fsm is

  type fsm_type is (idle, v_set_ddac, v_wait_transient, v_freeze_logic, f_freeze_logic,
                    f_set_rangea, f_assert_divchange, f_assert_pll_reset,
                    f_wait_transient, f_wait_pll_reset, f_wait_pll_lock,
                    unfreeze_logic, f_wait_pll_handshake);
  signal dvfs_current, dvfs_next : fsm_type;
  signal count, count_in : std_logic_vector(31 downto 0);
  signal pll_reset_count, pll_reset_count_in : std_logic_vector(4 downto 0);
  signal set_count, set_pll_reset_count : std_ulogic;
  constant pll_reset_cycles : std_logic_vector(4 downto 0) := "11001";

  signal plllock   : std_ulogic;
  signal pllouta   : std_ulogic;
  signal reset     : std_ulogic;

  signal divchange, divchange_in : std_ulogic;
  signal rangea, rangea_next, rangea_in, rangea_next_in : std_logic_vector(4 downto 0);
  signal ddac, ddac_next, ddac_in, ddac_next_in: std_logic_vector(4 downto 0);
  signal feq, veq, vup, vdown : std_ulogic;
  signal v_lo, f_lo, v_hi, f_hi, v_ovf, f_ovf : std_ulogic;
  signal auto_update, auto_update_in : std_ulogic;

  signal timestamp : std_logic_vector(31 downto 0);
  signal current_window : std_logic_vector(31 downto 0);
  signal reset_window : std_ulogic;
  signal statistics_traffic_count  : std_logic_vector(31 downto 0);
  signal statistics_burst_count    : std_logic_vector(31 downto 0);
  signal statistics_traffic_incr   : std_logic_vector(31 downto 0);
  signal statistics_burst_incr     : std_logic_vector(31 downto 0);

  signal clk_gate, clk_gate_latch : std_ulogic;
  signal pending_f_update, pending_v_update : std_ulogic;
  signal pending_f_update_in, pending_v_update_in : std_ulogic;

  type handshake_fsm_type is (hs_idle, hs_req, hs_counting, hs_done, hs_ack);
  signal handshake_current, handshake_next : handshake_fsm_type;
  signal pll_reset_start_req_in, pll_reset_start_ack_out : std_ulogic;
  signal pll_reset_done_req_out, pll_reset_done_ack_in : std_ulogic;
  signal pll_reset_start_req : std_logic_vector(3 downto 0);
  signal pll_reset_start_ack : std_logic_vector(3 downto 0);
  signal pll_reset_done_req  : std_logic_vector(3 downto 0);
  signal pll_reset_done_ack  : std_logic_vector(3 downto 0);
  signal pll_reset_start_req_fsm : std_ulogic;
  signal pll_reset_start_ack_fsm : std_ulogic;
  signal pll_reset_done_req_fsm : std_ulogic;
  signal pll_reset_done_ack_fsm : std_ulogic;

  signal is_transient : std_ulogic;

--  signal pllclk_int : std_ulogic;

begin  -- rtl

  clock_gating_latch: process (pllouta)
  begin  -- process clock_gating_latch
    if pllouta = '0' then
      clk_gate_latch <= not clk_gate;
    end if;
  end process clock_gating_latch;
  extra_buf_gen: if extra_clk_buf /= 0 generate
    clkand_unisim_1 : clkand_unisim
      port map (
        i      => pllouta,
        en     => clk_gate_latch,
        o      => pllclk);
  end generate extra_buf_gen;
  no_extra_buf_gen: if extra_clk_buf = 0 generate
    pllclk <= pllouta and clk_gate_latch;
  end generate no_extra_buf_gen;

  pll_1: pll
    generic map (
      tech => tech)
    port map (
      plllock   => plllock,
      pllouta   => pllouta,
      reset     => reset,
      divchange => divchange,           --strobe unused. Frequency updates on rangea
      rangea    => rangea,              --one hot encoding
      refclk    => refclk,
      pllbypass => pllbypass,
      stopclka  => '0',                 -- (unused)
      framestop => '1',                 -- (unused)
      locksel   => '0',                 -- (unused)
      lftune    => '0' & x"00004800f8", -- (unused)
      startup   => (others => '0'),     -- (unused)
      locktune  => (others => '0'),     -- (unused)
      vergtune  => "100");              -- (unused)

  process (pllouta, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      count <= (others => '0');
    elsif pllouta'event and pllouta = '1' then  -- rising clock edge
      if count /= zero then
        count <= count - 1;
      end if;
      if set_count = '1' then
        count <= count_in;
      end if;
    end if;
  end process;


  -----------------------------------------------------------------------------
  -- Synchronized count when PLL_MODE_RST_BIT is set
  -----------------------------------------------------------------------------
  pll_reset_start_req(0) <= pll_reset_start_req_fsm;
  pll_reset_done_ack(0) <= pll_reset_done_ack_fsm;
  pll_reset_start_ack_fsm <= pll_reset_start_ack(3);
  pll_reset_done_req_fsm <= pll_reset_done_req(3);

  pll_reset_start_req_in <= pll_reset_start_req(3);
  pll_reset_done_ack_in <= pll_reset_done_ack(3);
  pll_reset_start_ack(0) <= pll_reset_start_ack_out;
  pll_reset_done_req(0) <= pll_reset_done_req_out;

  synchronizers: for i in 1 to 3 generate
    process (refclk, rst)
    begin  -- process
      if rst = '0' then                 -- asynchronous reset (active low)
        pll_reset_start_req(i) <= '0';
        pll_reset_done_ack(i) <= '0';
      elsif refclk'event and refclk = '1' then  -- rising clock edge
        pll_reset_start_req(i) <= pll_reset_start_req(i-1);
        pll_reset_done_ack(i) <= pll_reset_done_ack(i-1);
      end if;
    end process;

    process (pllouta, rst)
    begin  -- process pllouta_synchronizers
      if rst = '0' then                   -- asynchronous reset (active low)
        pll_reset_start_ack(i) <= '0';
        pll_reset_done_req(i) <= '0';
      elsif pllouta'event and pllouta = '1' then  -- rising clock edge
        pll_reset_start_ack(i) <= pll_reset_start_ack(i-1);
        pll_reset_done_req(i) <= pll_reset_done_req(i-1);
      end if;
    end process;
  end generate synchronizers;


  handshake: process (pll_reset_start_req_in, pll_reset_done_ack_in, pll_reset_count,
                      handshake_current)
  begin  -- process handshake
    pll_reset_start_ack_out <= '0';
    pll_reset_done_req_out <= '0';
    handshake_next <= handshake_current;
    set_pll_reset_count <= '0';
    pll_reset_count_in <= (others => '0');
    reset <= '0';

    case handshake_current is
      when hs_idle =>
        if pll_reset_start_req_in = '1' then
          handshake_next <= hs_req;
        end if;

      when hs_req =>
        pll_reset_start_ack_out <= '1';
        if pll_reset_start_req_in = '0' then
          set_pll_reset_count <= '1';
          pll_reset_count_in <= pll_reset_cycles;
          handshake_next <= hs_counting;
        end if;

      when hs_counting =>
        reset <= '1';                   -- PLL reset is active high
        if pll_reset_count = "00000" then
          handshake_next <= hs_done;
        end if;

      when hs_done =>
        pll_reset_done_req_out <= '1';
        if pll_reset_done_ack_in = '1' then
          handshake_next <= hs_ack;
        end if;

      when hs_ack =>
        if pll_reset_done_ack_in = '0' then
          handshake_next <= hs_idle;
        end if;

      when others => handshake_next <= hs_idle;
    end case;

  end process handshake;

  process (refclk, rst)
  begin  -- process
    if rst = '0' then               -- asynchronous reset (active low)
      handshake_current <= hs_idle;
    elsif refclk'event and refclk = '1' then  -- rising clock edge
      handshake_current <= handshake_next;
    end if;
  end process;

  process (refclk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      pll_reset_count <= (others => '0');
    elsif refclk'event and refclk = '1' then  -- rising clock edge
      if pll_reset_count /= "00000" then
        pll_reset_count <= pll_reset_count - 1;
      end if;
      if set_pll_reset_count = '1' then
        pll_reset_count <= pll_reset_count_in;
      end if;
    end if;
  end process;
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Hardware policies implementation (none based on current feedback here)
  -----------------------------------------------------------------------------
  statistics_incrementer: process (bank, traffic, burst)
  begin  -- process statistics_incrementer
    statistics_traffic_incr <= (others => '0');
    statistics_burst_incr <= (others => '0');
    if bank(POLICY_REG)(POLICY_AUTO_TRAFFIC_BIT) = '1' then
      statistics_traffic_incr(0) <= traffic;
    elsif bank(POLICY_REG)(POLICY_AUTO_BALANCE_BIT) = '1' then
      statistics_traffic_incr(0) <= traffic;
      statistics_burst_incr(0) <= burst;
    end if;
  end process statistics_incrementer;

  reset_window <= '1' when current_window /= bank(POLICY_AUTO_WINDOW_REG) or is_transient = '1' else '0';

  mon_dvfs.clk <= pllouta;
  mon_dvfs.acc_idle <= acc_idle;
  mon_dvfs.traffic <= traffic;
  mon_dvfs.burst <= burst;

  mon_dvfs.vf <= bank(FREQUENCY_STATUS_REG)(3 downto 0) when acc_idle = '0' else (others => '0');

  mon_dvfs.transient <= is_transient;

  statistics_counter: process (pllouta, rst)
  begin  -- process statistics_counter
    if rst = '0' then                   -- asynchronous reset (active low)
      timestamp <= (others => '0');
      current_window <= (others => '0');
      statistics_traffic_count <= (others => '0');
      statistics_burst_count <= (others => '0');

      rangea_next <= "01000";                -- use the highest frequency
      ddac_next   <= "01000";                -- use the highest voltage
      auto_update <= '0';
    elsif pllouta'event and pllouta = '1' then  -- rising clock edge
      -- Window for monitor and decision update.
      current_window <= bank(POLICY_AUTO_WINDOW_REG);
      if (timestamp = current_window) or reset_window = '1' then
        timestamp <= (others => '0');
        auto_update <= auto_update_in and (not is_transient); 
      else
        if auto_update_in = '1' and is_transient = '0' and auto_update = '0' then
          -- sample next VF pair only on auto_update
          rangea_next <= rangea_next_in;
          ddac_next <= ddac_next_in;
        end if;
        timestamp <= timestamp + 1;
        auto_update <= '0';
      end if;

      -- Update statistics
      if (timestamp = current_window) or bank(POLICY_REG)(POLICY_NONE_BIT) = '1'
        or reset_window = '1' then
        statistics_traffic_count <= (others => '0');
        statistics_burst_count <= (others => '0');
      else
        statistics_traffic_count <= statistics_traffic_count + statistics_traffic_incr;
        statistics_burst_count <= statistics_burst_count + statistics_burst_incr;
      end if;
    end if;
  end process statistics_counter;

  v_lo <= ddac(0);
  f_lo <= rangea(0);
  check_for_vf_hi: process (bank)
    variable v_status : std_logic_vector(5 downto 0);
  begin  -- process check_for_vf_hi
    v_status := '0' & ddac;
    if v_status > bank(BUDGET_REG)(5 downto 0) then
      v_ovf <= '1';
      v_hi  <= '1';
      f_ovf <= '1';
      f_hi  <= '1';
    elsif v_status = bank(BUDGET_REG)(5 downto 0) then
      v_ovf <= '0';
      v_hi  <= '1';
      f_ovf <= '0';
      f_hi  <= '1';
    else
      v_ovf <= '0';
      v_hi  <= '0';
      f_ovf <= '0';
      f_hi  <= '0';
    end if;
  end process check_for_vf_hi;
  dvfs_policies: process (bank, ddac, rangea, v_lo, f_lo, v_hi, f_hi, v_ovf, f_ovf,
                          statistics_burst_count, statistics_traffic_count, is_transient)
  begin  -- process dvfs_policies
    ddac_next_in <= ddac;
    rangea_next_in <= rangea;
    auto_update_in <= '0';

    if is_transient = '0' then
          -- Do not take a decision before bank registers are updated!
          if bank(POLICY_REG)(POLICY_NONE_BIT) = '1' then
            ddac_next_in <= bank(VOLTAGE_SELECT_REG)(4 downto 0);
            rangea_next_in <= bank(FREQUENCY_SELECT_REG)(4 downto 0);
            auto_update_in <= '1';
          else
            if (v_ovf or f_ovf) = '1' then
              -- slow down on exceeded power budget
              ddac_next_in <= '0' & ddac(4 downto 1);
              rangea_next_in <= '0' & rangea(4 downto 1);
              auto_update_in <= '1';
            elsif bank(POLICY_REG)(POLICY_AUTO_TRAFFIC_BIT) = '1' then
              if statistics_traffic_count > bank(POLICY_TRAFFIC_TH_REG) and f_lo = '0' and v_lo = '0' then
                -- slow down on high traffic
                ddac_next_in <= '0' & ddac(4 downto 1);
                rangea_next_in <= '0' & rangea(4 downto 1);
                auto_update_in <= '1';
              elsif f_hi = '0' and v_hi = '0' then
                -- go faster if interconnect allows it
                ddac_next_in <= ddac(3 downto 0) & '0';
                rangea_next_in <= rangea(3 downto 0) & '0';
                auto_update_in <= '1';
              end if;
            elsif bank(POLICY_REG)(POLICY_AUTO_BALANCE_BIT) = '1' then
              if (statistics_traffic_count > bank(POLICY_TRAFFIC_TH_REG) or statistics_burst_count > bank(POLICY_BALANCE_TH_REG))
                and (f_lo = '0' and v_lo = '0') then
                -- slow down on high traffic or when communication/computation is too high
                ddac_next_in <= '0' & ddac(4 downto 1);
                rangea_next_in <= '0' & rangea(4 downto 1);
                auto_update_in <= '1';
              elsif f_hi = '0' and v_hi = '0' then
                -- go faster if interconnect allows it and there is more bandwidth
                ddac_next_in <= ddac(3 downto 0) & '0';
                rangea_next_in <= rangea(3 downto 0) & '0';
                auto_update_in <= '1';
              end if;
            end if;
          end if;

    end if;
  end process dvfs_policies;
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- DVFS state machine
  -----------------------------------------------------------------------------
  vup <= '1' when ddac_next > ddac else '0';
  vdown <= '1' when ddac_next < ddac else '0';
  feq <= '1' when rangea_next = rangea else '0';
  veq <= '1' when ddac_next = rangea else '0';

  process (dvfs_current, count, plllock, rst, bank,
           divchange, rangea, ddac,
           feq, veq, vup, vdown, auto_update,
           pending_f_update, pending_v_update,
           rangea_next, ddac_next,
           pll_reset_done_req_fsm, pll_reset_start_ack_fsm)
  begin  -- process
    clk_gate <= '0';
    clear_command <= '0';
    sample_status <= '0';
    dvfs_next <= dvfs_current;

    set_count <= '0';
    count_in <= (others => '0');

    pending_f_update_in <= pending_f_update;
    pending_v_update_in <= pending_v_update;

    -- PLL default
    pll_reset_start_req_fsm <= '0';
    pll_reset_done_ack_fsm <= '0';
    divchange_in <= divchange;

    -- Status default
    rangea_in <= rangea;
    ddac_in <= ddac;

    is_transient <= '1';

    case dvfs_current is
      when idle =>
        is_transient <= '0';
        if (bank(DVFS_CMD_REG)(DVFS_CMD_UPDATE_VF_BIT) = '1' and bank(POLICY_REG)(POLICY_NONE_BIT) = '1')
          or (auto_update = '1' and bank(POLICY_REG)(POLICY_NONE_BIT) = '0') then
          -- Update both F and V
          if vup = '1' then
            -- Update V first
            if feq = '0' then
              pending_f_update_in <= '1';
            end if;
            dvfs_next <= v_freeze_logic;
          elsif vdown = '1' then
            -- Update F first
            if feq = '0' then
              pending_v_update_in <= '1';
              dvfs_next <= f_freeze_logic;
            else
              dvfs_next <= v_freeze_logic;
            end if;
          else
            -- Don't update V
            if feq = '0' then
              dvfs_next <= f_freeze_logic;
            end if;
          end if;
        elsif (bank(DVFS_CMD_REG)(DVFS_CMD_UPDATE_V_BIT) = '1' and bank(POLICY_REG)(POLICY_NONE_BIT) = '1') then
          if veq = '0' then
            -- Update V
            dvfs_next <= v_freeze_logic;
          end if;
        elsif (bank(DVFS_CMD_REG)(DVFS_CMD_UPDATE_F_BIT) = '1' and bank(POLICY_REG)(POLICY_NONE_BIT) = '1') then
          if feq = '0' then
            -- Update F
            dvfs_next <= f_freeze_logic;
          end if;
        end if;

      when v_freeze_logic =>
        clk_gate <= '1';
        dvfs_next <= v_set_ddac;

      when v_set_ddac =>
        ddac_in <= ddac_next;
        count_in <= x"000000" & "00101000";     -- 40 cycles (conservative) = (20 refclk)
                                                -- we leave 40ns to have stable volage
        set_count <= '1';
        clk_gate <= '1';
        dvfs_next <= v_wait_transient;

      when v_wait_transient =>
        clk_gate <= '1';
        if count = zero then
          if pending_f_update = '1' then
            dvfs_next <= f_set_rangea;
          else
            set_count <= '1';
            count_in <= bank(MIN_WAIT_REG);     -- Prevent too frequenc updates
            dvfs_next <= unfreeze_logic;
          end if;
        end if;

      when f_freeze_logic =>
        clk_gate <= '1';
        dvfs_next <= f_set_rangea;

      when f_set_rangea =>
        clk_gate <= '1';
        rangea_in <= rangea_next;
        if bank(PLL_MODE_REG)(PLL_MODE_DFS_BIT) = '1' then
          dvfs_next <= f_assert_divchange;
        else
          dvfs_next <= f_assert_pll_reset;
        end if;

      when f_assert_divchange =>
        clk_gate <= '1';
        divchange_in <= '1';
        set_count <= '1';
        count_in <= x"000000" & "00000101";     -- 5 cycles (5ns)
        dvfs_next <= f_wait_transient;

      when f_wait_transient =>
        clk_gate <= '1';
        if count = zero then
          divchange_in <= '0';
          if pending_v_update = '1' then
            dvfs_next <= v_set_ddac;
          else
            dvfs_next <= unfreeze_logic;
            set_count <= '1';
            count_in <= bank(MIN_WAIT_REG);     -- Prevent too frequenc updates
          end if;
        end if;

      when f_assert_pll_reset =>
        clk_gate <= '1';
        pll_reset_start_req_fsm <= '1';
        if pll_reset_start_ack_fsm = '1' then
          dvfs_next <= f_wait_pll_reset;
        end if;

      when f_wait_pll_reset =>
        clk_gate <= '1';
        if pll_reset_done_req_fsm = '1' then
          dvfs_next <= f_wait_pll_handshake;
        end if;

      when f_wait_pll_handshake =>
        clk_gate <= '1';
        pll_reset_done_ack_fsm <= '1';
        if pll_reset_done_req_fsm = '0' then
          dvfs_next <= f_wait_pll_lock;
        end if;

      when f_wait_pll_lock =>
        clk_gate <= '1';
        if plllock = '1' then
          if pending_v_update = '1' then
            dvfs_next <= v_set_ddac;
          else
            set_count <= '1';
            count_in <= bank(MIN_WAIT_REG);     -- Prevent too frequenc updates
            dvfs_next <= unfreeze_logic;
          end if;
        end if;

      when unfreeze_logic =>
        is_transient <= '0';
        pending_f_update_in <= '0';
        pending_v_update_in <= '0';
        if count = zero then
          clear_command <= '1';
          sample_status <= '1';
          dvfs_next <= idle;
        end if;

      when others => dvfs_next <= idle;
    end case;

  end process;

  -- FSM must be clocked on pllouta because bank registers are also clocked
  -- on tha PLL output. Thus we avoid metastability. Notice that the FSM state
  -- will always be updated, because we hold the pll reset only until count
  -- is equal to zero. The latter will always happen, because count is clocked
  -- on refclk.
  process (pllouta, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      dvfs_current <= idle;
    elsif pllouta'event and pllouta = '1' then  -- rising clock edge
      dvfs_current <= dvfs_next;
    end if;
  end process;

  process (pllouta, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      divchange <= '0';
      rangea <= "01000";                -- use the highest frequency
      ddac   <= "01000";                -- use the highest voltage
      pending_f_update <= '0';
      pending_v_update <= '0';
    elsif pllouta'event and pllouta = '1' then  -- rising clock edge
      divchange <= divchange_in;
      rangea <= rangea_in;
      ddac <= ddac_in;
      pending_f_update <= pending_f_update_in;
      pending_v_update <= pending_v_update_in;
    end if;
  end process;

  -- Assign status output
  frequency(31 downto 5) <= (others => '0');
  frequency(4 downto 0) <= rangea;
  voltage(31 downto 5) <= (others => '0');
  voltage(4 downto 0) <= ddac;
  -- Feedback current not implemented
  qadc <= (others => '1');

end rtl;
