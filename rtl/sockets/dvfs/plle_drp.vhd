-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.allclkgen.all;
use work.gencomp.all;

-- Include PLLE2_ADV component
library UNISIM;
use UNISIM.vcomponents.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

entity plle_drp is
    generic (
        CLKFBOUT_MULT  : integer range 2 to 64 := 16;
        CLKIN1_PERIOD  : real := 8.0;
        CLKIN2_PERIOD  : real := 8.0;
        CLKOUT0_DIVIDE : integer range 1 to 128 := 19;
        CLKOUT1_DIVIDE : integer range 1 to 128 := 18;
        CLKOUT2_DIVIDE : integer range 1 to 128 := 17;
        CLKOUT3_DIVIDE : integer range 1 to 128 := 15;
        CLKOUT4_DIVIDE : integer range 1 to 128 := 14;
        CLKOUT5_DIVIDE : integer range 1 to 128 := 13;
        NUM_OUT_CLOCKS : integer range 1 to 6   := 1;
        EN_FREQ_SEL    : integer range 0 to 1   := 0
    );
    port (
        -- clock and reset interface
        clk           : in  std_ulogic;
        rstn          : in  std_ulogic;

        -- clock output signals
        clk_feedthru0 : out std_ulogic;
        clk_feedthru1 : out std_ulogic;
        clk_feedthru2 : out std_ulogic;
        clk_feedthru3 : out std_ulogic;
        clk_feedthru4 : out std_ulogic;
        clk_feedthru5 : out std_ulogic;
        locked        : out std_ulogic;

        -- hi-cycles control signals
        dco_reconfig  : in  std_ulogic;
        dco_hicycles  : in  std_logic_vector(5 downto 0);

        -- frequency selection logic
        dco_en        : in  std_ulogic;
        dco_div_sel   : in  std_logic_vector(2 downto 0)
    );

end plle_drp;

architecture rtl of plle_drp is

    -- FSM states
    type pll_fsm_type is (idle, send_address, wait_address_ack, send_data,
                      wait_data_ack, wait_lock);
    signal pll_state, next_pll_state : pll_fsm_type;

    -- clock signals
    signal clkin_bufgout     : std_ulogic;
    signal pll_clkfb_bufgout : std_ulogic;
    signal pll_clkfb_bufgin  : std_ulogic;
    signal pll_clkout0       : std_ulogic;
    signal pll_clkout1       : std_ulogic;
    signal pll_clkout2       : std_ulogic;
    signal pll_clkout3       : std_ulogic;
    signal pll_clkout4       : std_ulogic;
    signal pll_clkout5       : std_ulogic;

    -- status signals
    signal pll_locked        : std_ulogic;
    signal pll_rst           : std_ulogic;

    -- reconfiguration signals
    signal next_pll_reconfig : std_ulogic;
    signal pll_reconfig      : std_ulogic;
    signal next_pll_hicycles : std_logic_vector(5 downto 0);
    signal pll_hicycles      : std_logic_vector(5 downto 0);
    signal pll_drdy          : std_ulogic;
    signal pll_drst          : std_ulogic;
    signal pll_daddr         : std_logic_vector(6 downto 0);
    signal pll_den           : std_ulogic;
    signal pll_di            : std_logic_vector(15 downto 0);
    signal pll_dwe           : std_ulogic;

    -- frequency selection masks
    signal freq_sel0         : std_ulogic;
    signal freq_sel1         : std_ulogic;
    signal freq_sel2         : std_ulogic;

    -- clock multiplexing
    signal clk_sel_01        : std_ulogic;
    signal clk_sel_23        : std_ulogic;
    signal clk_sel_45        : std_ulogic;
    signal clk_sel_67        : std_ulogic;
    signal clk_sel_0123      : std_ulogic;
    signal clk_sel_4567      : std_ulogic;
    signal clk_sel           : std_ulogic;

    -- clock multiplexing tracking
    constant LOCK_CNT_WIDTH  : integer := 6;
    signal dco_div_sel_prev  : std_logic_vector(2 downto 0);
    signal div_sel_lock_cnt  : unsigned(LOCK_CNT_WIDTH downto 0);

begin -- rtl

    -- next state process
    locked <= pll_locked;
    p_next_state : process(pll_state, pll_reconfig, pll_drdy, pll_locked)
    begin
        next_pll_state <= pll_state;
        case pll_state is
            when idle =>
                if pll_reconfig = '1' then
                    next_pll_state <= send_address;
                end if;
            when send_address =>
                next_pll_state <= wait_address_ack;
            when wait_address_ack =>
                if pll_drdy = '1' then
                    next_pll_state <= send_data;
                end if;
            when send_data =>
                next_pll_state <= wait_data_ack;
            when wait_data_ack =>
                if pll_drdy = '1' then
                    next_pll_state <= wait_lock;
                end if;
            when wait_lock =>
                if pll_locked = '1' then
                    next_pll_state <= idle;
                end if;
            when others => next_pll_state <= idle;
        end case;
    end process p_next_state;

    -- save new input signals
    p_input : process(dco_reconfig, dco_hicycles,
                    pll_locked,
                    next_pll_state, pll_reconfig, pll_hicycles)
    begin
        if dco_reconfig = '1' then
            -- save new input if already locked
            next_pll_reconfig <= pll_locked;
            if pll_locked = '1' then
                next_pll_hicycles <= dco_hicycles;
            else
                next_pll_hicycles <= pll_hicycles;
            end if;
        else
            -- keep previous input
            next_pll_hicycles <= pll_hicycles;
            if next_pll_state = idle then
                next_pll_reconfig <= pll_reconfig;
            else
                -- do not reconfigure if already processing request
                next_pll_reconfig <= '0';
            end if;
        end if;
    end process p_input;

    -- propagate next state
    p_state : process(clk, rstn)
    begin
        if rstn = '0' then
            pll_state    <= idle;
            pll_hicycles <= (others => '0');
            pll_reconfig <= '0';
        elsif clk'event and clk = '1' then
            pll_state    <= next_pll_state;
            pll_hicycles <= next_pll_hicycles;
            pll_reconfig <= next_pll_reconfig;
        end if;
    end process p_state;

    -- output process
    pll_daddr <= "0010110"; -- 0x16, DIVCLK Register
    pll_di    <= "00" & "1" & "0" & next_pll_hicycles & next_pll_hicycles; -- DivReg bitmap
    p_output : process(pll_state)
    begin
        case pll_state is
            when idle =>
                pll_drst  <= '0';
                pll_den   <= '0';
                pll_dwe   <= '0';
            when send_address =>
                pll_drst  <= '1';
                pll_den   <= '1';
                pll_dwe   <= '0';
            when wait_address_ack =>
                pll_drst  <= '1';
                pll_den   <= '0';
                pll_dwe   <= '0';
            when send_data =>
                pll_drst  <= '1';
                pll_den   <= '1';
                pll_dwe   <= '1';
            when wait_data_ack =>
                pll_drst  <= '1';
                pll_den   <= '0';
                pll_dwe   <= '0';
            when wait_lock =>
                pll_drst  <= '0';
                pll_den   <= '0';
                pll_dwe   <= '0';
            when others =>
                pll_drst  <= '0';
                pll_den   <= '0';
                pll_dwe   <= '0';
        end case;
    end process p_output;

    -- PLL buffers
    u_pll_clk_bufg : BUFG
    port map (
       O => clkin_bufgout,
       I => clk
    );
    u_pll_clkfb_bufg : BUFG
    port map (
       O => pll_clkfb_bufgout,
       I => pll_clkfb_bufgin
    );

    no_freq_sel_gen : if EN_FREQ_SEL = 0 generate

        pll_rst <= pll_drst or not rstn;

    end generate no_freq_sel_gen;

    -- multiplex output clocks
    clk_freq_sel_gen : if EN_FREQ_SEL /= 0 generate

        -- avoid X propagation
        freq_sel0 <= '1' when dco_div_sel(0) = '1' and dco_en = '1' else '0';
        freq_sel1 <= '1' when dco_div_sel(1) = '1' and dco_en = '1' else '0';
        freq_sel2 <= '0' when dco_div_sel(2) = '0' and dco_en = '1' else '1';

        -- first level selection
        clk_sel_01 <= pll_clkout0;
        clk_sel_23 <= pll_clkout1 when freq_sel0 = '0' else pll_clkout2;
        clk_sel_45 <= clkin_bufgout when freq_sel0 = '0' else pll_clkout3;
        clk_sel_67 <= pll_clkout4 when freq_sel0 = '0' else pll_clkout5;

        -- second level selection
        clk_sel_0123 <= clk_sel_01 when freq_sel1 = '0' else clk_sel_23;
        clk_sel_4567 <= clk_sel_45 when freq_sel1 = '0' else clk_sel_67;

        -- final level selection
        clkmux_vote : clkmux
            generic map (
                tech => virtex7
            )
            port map (
                clk_sel_0123, clk_sel_4567, freq_sel2, clk_sel, rstn
            );
        --clk_feedthru0 <= clk_sel;
        u_pll_clkout0_bufg : BUFG
        port map (
           O => clk_feedthru0,
           I => clk_sel
        );

        -- locked state
        p_locked_cnt : process(clkin_bufgout, rstn)
        begin
            if rstn = '0' then
                dco_div_sel_prev <= (others => '0');
                div_sel_lock_cnt <= (others => '0');
            elsif clkin_bufgout'event and clkin_bufgout = '1' then
                dco_div_sel_prev <= dco_div_sel;
                if (dco_div_sel /= dco_div_sel_prev) then
                    div_sel_lock_cnt <= (others => '0');
                elsif (div_sel_lock_cnt(LOCK_CNT_WIDTH) /= '1') then
                    div_sel_lock_cnt <= div_sel_lock_cnt + 1;
                else
                    div_sel_lock_cnt <= div_sel_lock_cnt;
                end if;
            end if;
        end process p_locked_cnt;
        pll_rst <= pll_drst or not div_sel_lock_cnt(LOCK_CNT_WIDTH) or not rstn;

    end generate clk_freq_sel_gen;

    -- buffer all output clocks
    clk_mult_gen : if EN_FREQ_SEL = 0 generate

        u_pll_clkout0_bufg : BUFG
        port map (
           O => clk_feedthru0,
           I => pll_clkout0
        );

    end generate clk_mult_gen;

    clkout1_gen : if NUM_OUT_CLOCKS >= 2 generate
        u_pll_clkout1_bufg : BUFG
        port map (
           O => clk_feedthru1,
           I => pll_clkout1
        );
    end generate clkout1_gen;

    clkout2_gen : if NUM_OUT_CLOCKS >= 3 generate
        u_pll_clkout2_bufg : BUFG
        port map (
           O => clk_feedthru2,
           I => pll_clkout2
        );
    end generate clkout2_gen;

    clkout3_gen : if NUM_OUT_CLOCKS >= 4 generate
        u_pll_clkout3_bufg : BUFG
        port map (
           O => clk_feedthru3,
           I => pll_clkout3
        );
    end generate clkout3_gen;

    clkout4_gen : if NUM_OUT_CLOCKS >= 5 generate
        u_pll_clkout4_bufg : BUFG
        port map (
           O => clk_feedthru4,
           I => pll_clkout4
        );
    end generate clkout4_gen;

    clkout5_gen : if NUM_OUT_CLOCKS = 6 generate
        u_pll_clkout5_bufg : BUFG
        port map (
           O => clk_feedthru5,
           I => pll_clkout5
        );
    end generate clkout5_gen;

    -- PLL instantiation
    u_plle2_adv : PLLE2_ADV
    generic map (
        BANDWIDTH => "OPTIMIZED",       -- OPTIMIZED, HIGH, LOW
        CLKFBOUT_MULT => CLKFBOUT_MULT, -- Multiply value for all CLKOUT, (2-64)
        CLKFBOUT_PHASE => 0.0,          -- Phase offset in degrees of CLKFB, (-360.000-360.000).

        -- CLKIN_PERIOD: Input clock period in nS to ps resolution (i.e. 33.333 is 30 MHz).
        CLKIN1_PERIOD => CLKIN1_PERIOD,
        CLKIN2_PERIOD => CLKIN2_PERIOD,

        -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT (1-128)
        CLKOUT0_DIVIDE => CLKOUT0_DIVIDE,
        CLKOUT1_DIVIDE => CLKOUT1_DIVIDE,
        CLKOUT2_DIVIDE => CLKOUT2_DIVIDE,
        CLKOUT3_DIVIDE => CLKOUT3_DIVIDE,
        CLKOUT4_DIVIDE => CLKOUT4_DIVIDE,
        CLKOUT5_DIVIDE => CLKOUT5_DIVIDE,

        -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT1_DUTY_CYCLE => 0.5,
        CLKOUT2_DUTY_CYCLE => 0.5,
        CLKOUT3_DUTY_CYCLE => 0.5,
        CLKOUT4_DUTY_CYCLE => 0.5,
        CLKOUT5_DUTY_CYCLE => 0.5,

        -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
        CLKOUT0_PHASE => 0.0,
        CLKOUT1_PHASE => 0.0,
        CLKOUT2_PHASE => 0.0,
        CLKOUT3_PHASE => 0.0,
        CLKOUT4_PHASE => 0.0,
        CLKOUT5_PHASE => 0.0,
        COMPENSATION => "ZHOLD",   -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
        DIVCLK_DIVIDE => 1,        -- Master division value (1-56)

        -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
        REF_JITTER1 => 0.010, -- MG XXX
        REF_JITTER2 => 0.010 -- MG XXX
    )
    port map (
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0 => pll_clkout0, -- 1-bit output: CLKOUT0
        CLKOUT1 => pll_clkout1,      -- 1-bit output: CLKOUT1
        CLKOUT2 => pll_clkout2,      -- 1-bit output: CLKOUT2
        CLKOUT3 => pll_clkout3,      -- 1-bit output: CLKOUT3
        CLKOUT4 => pll_clkout4,      -- 1-bit output: CLKOUT4
        CLKOUT5 => pll_clkout5,      -- 1-bit output: CLKOUT5
        -- DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
        DO => open,       -- 16-bit output: DRP data
        --DO => pll_do,     -- 16-bit output: DRP data
        DRDY => pll_drdy, -- 1-bit output: DRP ready

        -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
        CLKFBOUT => pll_clkfb_bufgin, -- 1-bit output: Feedback clock
        LOCKED => pll_locked,         -- 1-bit output: LOCK

        -- Clock Inputs: 1-bit (each) input: Clock inputs
        CLKIN1 => clkin_bufgout,   -- 1-bit input: Primary clock
        CLKIN2 => '0',             -- 1-bit input: Secondary clock

        -- Control Ports: 1-bit (each) input: PLL control ports
        CLKINSEL => '1',       -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
        PWRDWN => '0',         -- 1-bit input: Power-down
        RST => pll_rst,        -- 1-bit input: Reset

        -- DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
        DADDR => pll_daddr,    -- 7-bit input: DRP address
        DCLK => clkin_bufgout, -- 1-bit input: DRP clock
        DEN => pll_den,        -- 1-bit input: DRP enable
        DI => pll_di,          -- 16-bit input: DRP data
        DWE => pll_dwe,        -- 1-bit input: DRP write enable

        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => pll_clkfb_bufgout  -- 1-bit input: Feedback clock
    );

end rtl;
