-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2013, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--!  @project      proFPGA
-- =============================================================================
--!  @file         profpga_sync.vhd
--!  @author       Sebastian Fluegel
--!  @email        sebastian.fluegel@prodesign-europe.com
--!  @brief        proFPGA clock sync receiver and transmitter modules
--!                (Xilinx Virtex-6 und Virtex-7 implementation)
-- =============================================================================

-- === profpga SYNC transmitter ===

library ieee;
    use ieee.std_logic_1164.all;
entity profpga_sync_tx is
  port (
    -- sync event interface
    clk             : in  std_ulogic;
    rst             : in  std_ulogic;
    event_id_i      : in  std_ulogic_vector(7 downto 0);
    event_en_i      : in  std_ulogic;
    event_busy_o    : out std_ulogic;

    -- extra wait cycles between 2 sync events (needed when recipent derives very slow clock)
    event_pause_i   : in  std_ulogic_vector(15 downto 0);

    -- automatic sync events
    user_reset_i    : in  std_ulogic;
    user_strobe1_i  : in  std_ulogic;
    user_strobe2_i  : in  std_ulogic;

    -- sync output
    sync_p_o        : out std_ulogic;
    sync_n_o        : out std_ulogic
  );
end entity profpga_sync_tx;



library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library work;
    use work.profpga_pkg.all;
architecture rtl of profpga_sync_tx is

  component profpga_sync_opad is
    port (
      clk       : in  std_ulogic;
      sync_i    : in  std_ulogic;
      sync_p_o  : out std_ulogic;
      sync_n_o  : out std_ulogic
    );
  end component profpga_sync_opad;

  type userevent_t is record
    curr : std_ulogic_vector(1 downto 0);  -- current value
    rise  : std_ulogic; -- rising edge detected (curr="10"), need to issue event
    fall  : std_ulogic; -- falling edge detected (curr="01"), need to issue event
  end record;
  constant USER_INIT1 : userevent_t := ("11", '0', '0');
  constant USER_INIT0 : userevent_t := ("00", '0', '0');

  signal event_r    : std_ulogic_vector(8 downto 0);
  signal busy_r     : std_ulogic_vector(8 downto 0);
  signal delay_r    : unsigned(15 downto 0);
  signal delay_load_r : unsigned(15 downto 0);
  signal delay_loading_r : std_ulogic;
  signal delay_done_r : std_ulogic;
  
  signal event_pause_r : unsigned(15 downto 0);
  signal event_pause_zero_r : std_ulogic;

  -- user trigger states
  signal reset_r    : userevent_t;
  signal strobe1_r  : userevent_t;
  signal strobe2_r  : userevent_t;

begin

  FF: process(clk, rst)
  variable event_en_v : std_ulogic;
  variable event_id_v : std_ulogic_vector(7 downto 0);
  variable delay_inc  : unsigned(15 downto 0);
  begin
    if rst='1' then
      event_r   <= (others=>'0');
      busy_r    <= (others=>'0');
      delay_r   <= (others=>'0');
      reset_r   <= USER_INIT1;
      strobe1_r <= USER_INIT0;
      strobe2_r <= USER_INIT0;
      delay_load_r <= (others=>'1');
      delay_loading_r <= '0';
      delay_done_r <= '1';
      
      event_pause_r <= (others=>'0');
      event_pause_zero_r <= '1';

    elsif rising_edge(clk) then
      -- process current event
      event_r <= event_r(event_r'high-1 downto 0) & '0';
      
      -- stay busy while event is transmitted
      -- in addition, stay busy during extra delay cycles
      busy_r  <= busy_r(busy_r'high-1 downto 0) & (not delay_done_r);
      
      -- timing optimization for >250 MHz
      -- 3 operations on delay_r:
      -- (a) load next delay value
      --    delay_r = 0, delay_done_r='1', delay_load_r="new value"
      --    new value <= 0 + event_pause_i + 0
      -- (b) decrement delay value
      --    delay_r = curr value, delay_done_r='0', delay_load_r=0
      --    new_value <= curr value + -1 + 0
      -- (c) stay in IDLE mode
      --    delay_r = 0, delay_done_r='1', delay_load_r=0
      --    new_value <= 0 + -1 + 1
      delay_inc := (others=>'0');
      delay_inc(0) := delay_done_r and not delay_loading_r;
      
      delay_r <= delay_r + delay_load_r + delay_inc; --delay_inc implemented as "carry in"

      -- check if we reached zero (or will reach zero in the next cycle)
      if delay_r(15 downto 1)=0 and delay_loading_r='0' then -- delay_r<=1
        delay_done_r <= '1';
        busy_r(0) <= '0';
      end if;
      
      -- clear load operation
      delay_load_r <= (others=>'1');
      delay_loading_r <= '0';
      
      -- sample incoming EVENT_PAUSE setting (required for timing optimization)
      event_pause_r <= unsigned(event_pause_i);
      if event_pause_i=x"0000" then
        event_pause_zero_r <= '1';
      else
        event_pause_zero_r <= '0';
      end if;


      -- process next event (after current event is done)
      if busy_r(8)='0' then
        -- default: no event
        event_id_v := EVENTID_NULL;
        event_en_v := '0';

        if event_en_i='1' then                        -- prio1: incoming events
          event_id_v := event_id_i;
          event_en_v := '1';
        else
          if reset_r.fall='1' or reset_r.rise='1' then -- prio 2: reset
            event_en_v := '1';
            -- check which event to generate
            -- rising when: (a) only rising event (b) both events, current signal value is '0' (i.e. rising event came first)
            if reset_r.rise='1' and (reset_r.fall='0' or reset_r.curr(1)='0') then
              event_id_v := EVENTID_RESET_1;
              reset_r.rise <= '0';
            else
              event_id_v := EVENTID_RESET_0;
              reset_r.fall <= '0';
            end if;
          elsif strobe1_r.fall='1' or strobe1_r.rise='1' then -- prio 3: strobe 1
            event_en_v := '1';
            -- check which event to generate
            -- rising when: (a) only rising event (b) both events, current signal value is '0' (i.e. rising event came first)
            if strobe1_r.rise='1' and (strobe1_r.fall='0' or strobe1_r.curr(1)='0') then
              event_id_v := EVENTID_STROBE1_1;
              strobe1_r.rise <= '0';
            else
              event_id_v := EVENTID_STROBE1_0;
              strobe1_r.fall <= '0';
            end if;
          elsif strobe2_r.fall='1' or strobe2_r.rise='1' then -- prio 4: strobe 2
            event_en_v := '1';
            -- check which event to generate
            -- rising when: (a) only rising event (b) both events, current signal value is '0' (i.e. rising event came first)
            if strobe2_r.rise='1' and (strobe2_r.fall='0' or strobe2_r.curr(1)='0') then
              event_id_v := EVENTID_STROBE2_1;
              strobe2_r.rise <= '0';
            else
              event_id_v := EVENTID_STROBE2_0;
              strobe2_r.fall <= '0';
            end if;
          end if;
        end if;

        -- assign new event to state registers
        if event_en_v='1' then
          event_r <= '1' & event_id_v;
          busy_r  <= (others=>'1');
          if event_pause_zero_r='0' then
            delay_load_r <= event_pause_r;
            delay_loading_r <= '1';
            delay_done_r <= '0';
          end if;
        end if;
      end if;

      -- signal pipe
      reset_r.curr   <= reset_r.curr(0)   & user_reset_i;
      strobe1_r.curr <= strobe1_r.curr(0) & user_strobe1_i;
      strobe2_r.curr <= strobe2_r.curr(0) & user_strobe2_i;

      -- detect events
      if reset_r.curr="10"   then reset_r.fall   <= '1'; end if;
      if reset_r.curr="01"   then reset_r.rise   <= '1'; end if;
      if strobe1_r.curr="10" then strobe1_r.fall <= '1'; end if;
      if strobe1_r.curr="01" then strobe1_r.rise <= '1'; end if;
      if strobe2_r.curr="10" then strobe2_r.fall <= '1'; end if;
      if strobe2_r.curr="01" then strobe2_r.rise <= '1'; end if;
    end if;
  end process FF;

  event_busy_o <= busy_r(8);

  OUT_PAD: profpga_sync_opad
  port map (
    clk       => clk,
    sync_i    => event_r(8),
    sync_p_o  => sync_p_o,
    sync_n_o  => sync_n_o
  );

end architecture rtl;







library ieee;
    use ieee.std_logic_1164.all;
entity profpga_sync_rx is
  port (
    clk             : in  std_ulogic;
    rst             : in  std_ulogic;
    sync_p_i        : in  std_ulogic;
    sync_n_i        : in  std_ulogic;
    sync_delay_i    : in  std_ulogic_vector(5 downto 0);  -- input delay (for multi-motherboard operations)

    user_reset_o    : out std_ulogic;
    user_strobe1_o  : out std_ulogic;
    user_strobe2_o  : out std_ulogic;
    event_id_o      : out std_ulogic_vector(7 downto 0);
    event_en_o      : out std_ulogic
  );
end entity profpga_sync_rx;



library ieee;
    use ieee.std_logic_1164.all;
library work;
    use work.profpga_pkg.all;
architecture rtl of profpga_sync_rx is

begin

  U_SYNC_RX2 : profpga_sync_rx2 
  generic map (
    CLK_CORE_COMPENSATION => "DELAYED"
  ) port map (
    clk_pad         => '0',
    clk_core        => clk,
    rst             => rst,
    sync_p_i        => sync_p_i,
    sync_n_i        => sync_n_i,
    sync_delay_i    => sync_delay_i,
    user_reset_o    => user_reset_o,
    user_strobe1_o  => user_strobe1_o,
    user_strobe2_o  => user_strobe2_o,
    event_id_o      => event_id_o,
    event_en_o      => event_en_o
  );
end architecture rtl;






library ieee;
    use ieee.std_logic_1164.all;
entity profpga_sync_rx2 is
  generic (
    CLK_CORE_COMPENSATION : string := "DELAYED" -- "DELAYED", "ZHOLD" or "DELAYED_XVUS"
  );
  port (
    clk_pad         : in  std_ulogic;
    clk_core        : in  std_ulogic;
    rst             : in  std_ulogic;
    sync_p_i        : in  std_ulogic;
    sync_n_i        : in  std_ulogic;
    sync_delay_i    : in  std_ulogic_vector(5 downto 0);  -- input delay (for multi-motherboard operations)

    user_reset_o    : out std_ulogic;
    user_strobe1_o  : out std_ulogic;
    user_strobe2_o  : out std_ulogic;
    event_id_o      : out std_ulogic_vector(7 downto 0);
    event_en_o      : out std_ulogic
  );
end entity profpga_sync_rx2;




library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library work;
    use work.profpga_pkg.all;
architecture rtl of profpga_sync_rx2 is
  -- sync pulse:
  --  IDLE:  SYNC = 0
  --  START: SYNC = 1 (provided as event_en)
  --  EVENT: ID[7:0]  (provided as event_id)
  --  STOP:  SYNC = 0

  -- Info:  Mainboard-to-mainboard phase adjust adds some pipeline stages to the SYNC signal.
  --        Delay must be added to those receivers who are closer to the transmitter.
  constant MAX_DELAY        : integer := 2**sync_delay_i'length;
  constant IDX_EVENT_START  : integer := MAX_DELAY + event_id_o'length + 1;
  constant IDX_EVENT_HI     : integer := IDX_EVENT_START - 1;
  constant IDX_EVENT_LO     : integer := MAX_DELAY + 1;
  constant IDX_EVENT_STOP   : integer := MAX_DELAY;

  component profpga_sync_ipad is
    generic (
      CLK_CORE_COMPENSATION : string
    );
    port (
      clk_pad         : in  std_ulogic;
      clk_core        : in  std_ulogic;
      sync_p_i  : in  std_ulogic;
      sync_n_i  : in  std_ulogic;
      sync_o    : out std_ulogic
    );
  end component profpga_sync_ipad;

  signal sync           : std_ulogic;
  signal sync_in_r      : std_ulogic_vector(1 downto 0); -- some additinal registers to ease routing
  signal sync_fifo_r    : std_ulogic_vector(MAX_DELAY+9 downto 1) := (others=>'0');
  signal sync_error_r   : std_ulogic;

  signal user_reset_r   : std_ulogic;
  signal user_strobe1_r : std_ulogic;
  signal user_strobe2_r : std_ulogic;
begin

  IPAD : profpga_sync_ipad
  generic map (
    CLK_CORE_COMPENSATION => CLK_CORE_COMPENSATION
  ) port map (
    clk_pad   => clk_pad,
    clk_core  => clk_core,
    sync_p_i  => sync_p_i,
    sync_n_i  => sync_n_i,
    sync_o    => sync
  );

  sync_in_r <= (others=>'0') when rst='1'
          else sync & sync_in_r(sync_in_r'high downto 1) when rising_edge(clk_core);

  FF : process (clk_core, rst)
  begin
    if rst='1' then
      sync_fifo_r     <= (others=>'0');
      user_reset_r    <= '1';
      user_strobe1_r  <= '0';
      user_strobe2_r  <= '0';
      sync_error_r    <= '0';
    elsif rising_edge(clk_core) then
      -- shift sync FIFO
      sync_fifo_r <= sync_fifo_r(sync_fifo_r'high-1 downto 1) & '0';

      -- error handling (typically occurs during MB-to-MB clock training)
      --
      -- enter error state when EVENT_START=1 and EVENT_STOP=1
      -- leave error state after receiving 10x sync=0 in a row
      if sync_fifo_r(IDX_EVENT_START-1)='1' and sync_fifo_r(IDX_EVENT_STOP-1)='1' then
        sync_error_r <= '1';  -- enter error state
        sync_fifo_r(IDX_EVENT_START) <= '0';  -- suppress event
      elsif sync_fifo_r(IDX_EVENT_START-1 downto IDX_EVENT_STOP-1)="0000000000" then
        sync_error_r <= '0';
      end if;
      
      -- suppress sync events during error state
      if sync_error_r='1' then
        sync_fifo_r(IDX_EVENT_START) <= '0';
      end if;
        
      -- clear event ID bits after receiving a complete event
      if sync_fifo_r(IDX_EVENT_START)='1' then  
        sync_fifo_r(IDX_EVENT_START downto IDX_EVENT_LO) <= (others=>'0');
      end if;

      -- insert sync at current delay
      sync_fifo_r(MAX_DELAY-to_integer(unsigned(sync_delay_i))) <= sync_in_r(0);

      if sync_fifo_r(IDX_EVENT_START)='1' then
        -- decode user reset event
        if sync_fifo_r(IDX_EVENT_HI downto IDX_EVENT_LO)=EVENTID_RESET_0
        or sync_fifo_r(IDX_EVENT_HI downto IDX_EVENT_LO)=EVENTID_RESET_1
        then
          user_reset_r <= sync_fifo_r(IDX_EVENT_LO);
        end if;

        -- decode user strobe1 event
        if sync_fifo_r(IDX_EVENT_HI downto IDX_EVENT_LO)=EVENTID_STROBE1_0
        or sync_fifo_r(IDX_EVENT_HI downto IDX_EVENT_LO)=EVENTID_STROBE1_1
        then
          user_strobe1_r <= sync_fifo_r(IDX_EVENT_LO);
        end if;

        -- decode user strobe2 event
        if sync_fifo_r(IDX_EVENT_HI downto IDX_EVENT_LO)=EVENTID_STROBE2_0
        or sync_fifo_r(IDX_EVENT_HI downto IDX_EVENT_LO)=EVENTID_STROBE2_1
        then
          user_strobe2_r <= sync_fifo_r(IDX_EVENT_LO);
        end if;

      end if;
    end if;
  end process FF;

  event_en_o  <= sync_fifo_r(IDX_EVENT_START);
  event_id_o  <= sync_fifo_r(IDX_EVENT_HI downto IDX_EVENT_LO);

  user_reset_o <= user_reset_r;
  user_strobe1_o <= user_strobe1_r;
  user_strobe2_o <= user_strobe2_r;

end architecture rtl;






-- === SYNC Input pad (technology-dependent) ===

library ieee;
    use ieee.std_logic_1164.all;
entity profpga_sync_ipad is
  generic (
    CLK_CORE_COMPENSATION : string := "DELAYED"
  );
  port (
    clk_pad   : in  std_ulogic;
    clk_core  : in  std_ulogic;
    sync_p_i  : in  std_ulogic;
    sync_n_i  : in  std_ulogic;
    sync_o    : out std_ulogic
  );
end entity profpga_sync_ipad;

library ieee;
    use ieee.std_logic_1164.all;
library unisim;
    use unisim.vcomponents.all;
architecture xst of profpga_sync_ipad is
  signal sync_pad : std_ulogic;
  signal sync_r1, sync_r2 : std_ulogic;
  signal sync_r   : std_ulogic := '0';
  signal clk_pad_sel : std_ulogic;
  
  function COMPENSATION_IOB return string is
  begin
    if CLK_CORE_COMPENSATION="DELAYED" then
      return "FALSE";  -- ZHOLD compensation: put sync_ddr into IOB register
    else
      return "TRUE"; -- NO compensation: put sync_ddr into SLICE register
    end if;
  end function COMPENSATION_IOB;
  
  attribute IOB : string;
  attribute IOB of sync_pad : signal is COMPENSATION_IOB;

begin

  -- convert LVDS into single-ended logic
  LVDS_SYNC : IBUFDS
  generic map (
    DIFF_TERM    => true,
    IBUF_LOW_PWR => false,
    IOSTANDARD => "DEFAULT"
  ) port map (
    i  => sync_p_i,
    ib => sync_n_i,
    o  => sync_pad
  );
    
  clk_pad_sel <= not clk_core when CLK_CORE_COMPENSATION="ZHOLD" else -- sampling on rising edge of compensated clock
                 clk_pad after 1 ns;                                  -- sampling on falling edge of low-delay clock
  
  sync_r1 <= sync_pad when falling_edge(clk_pad_sel);
  sync_r2 <= sync_r1  when rising_edge(clk_pad_sel);
  
  -- transfer to internal clock 
  process (clk_core)
  begin
    if rising_edge(clk_core) then
      -- switch clock domains
      if CLK_CORE_COMPENSATION="DELAYED_XVUS" then
        sync_r <= sync_r2;
      else
        sync_r <= sync_r1;
      end if;
      
      sync_o <= sync_r;
    end if;
  end process;
end architecture xst;




-- === SYNC Output pad (technology-dependent) ===

library ieee;
    use ieee.std_logic_1164.all;
entity profpga_sync_opad is
  port (
    clk       : in  std_ulogic;
    sync_i    : in  std_ulogic;
    sync_p_o  : out std_ulogic;
    sync_n_o  : out std_ulogic
  );
end entity profpga_sync_opad;

library ieee;
    use ieee.std_logic_1164.all;
library unisim;
    use unisim.vcomponents.all;
architecture xst of profpga_sync_opad is
  signal sync_pad : std_ulogic;

  attribute iob : string;
  attribute iob of sync_pad: signal is "true";
begin

  sync_pad <= sync_i when rising_edge(clk);

  LVDS_SYNC : OBUFDS
  generic map (
    IOSTANDARD => "DEFAULT"
  ) port map (
    o  => sync_p_o,
    ob => sync_n_o,
    i  => sync_pad
  );
end architecture xst;


