-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2015, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : Module Message Interface
--  Version       : 2.0
--  Module/Entity : mmi64_p_muxdemux_p.vhd
--  Author        : mberger, sfluegel
--  Description   : ProDesign's implementation of the pin multiplexing and
--                  demultiplexing modules using serdes primitives and
--                  a training algorithm to adjust the input delay (using
--                  IDELAY primitive) and the bit slip parameter.
-- =============================================================================

-------------------------------------------------------------------------------
-- mmi64_p_muxdemux_pkg package
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package mmi64_p_muxdemux_pkg is

  -- mux_mode BIT definition
  constant MUX_MODE_BIT_RST               : integer := 0;  -- reset to mux/demux
  constant MUX_MODE_BIT_MUX_PAT_DELAY     : integer := 1;  -- enables delay training pattern for mux
  constant MUX_MODE_BIT_MUX_PAT_BITSLIP   : integer := 2;  -- enables bit slip training pattern for mux
  constant MUX_MODE_BIT_MUX_PAT_WORDSLIP  : integer := 3;  -- enables word slip training pattern for mux
  constant MUX_MODE_BIT_DEMUX_PAT_DELAY   : integer := 4;  -- enables delay training pattern for demux
  constant MUX_MODE_BIT_DEMUX_PAT_BITSLIP : integer := 5;  -- enables bit slip training for demux
  constant MUX_MODE_BIT_DEMUX_NEXT_TAP    : integer := 6;  -- enables bit slip training for demux
  constant MUX_MODE_BIT_DEMUX_PAT_WORDSLIP: integer := 7;  -- enables word slip training for demux
  constant MUX_MODE_BIT_PAT_USER          : integer := 8;  -- enables DUT I/O multiplexing

  -- the number if IDELAY_CTRL modules to instantiate
  constant IDELAY_CTRL_INSTANCES : integer := 1;  -- for (ise >= 14.3; vivado >= 2012.3)
  --constant IDELAY_CTRL_INSTANCES : integer := 24;  -- for ise 14.2

  -- determines the training Tap counter width
  function GetTTCBitWidth (
    constant DEVICE : string)
    return integer;
    
  -- determines the Tap counter width
  function GetTCBitWidth (
    constant DEVICE : string)
    return integer;
  
  -- determines the statistic output width of one mux/demux channel
  function GetBasicStatBitWidth (
    constant DEVICE : string)
    return integer;
  
  -- determines the statistic output width (all chennels together)
  function GetStatBitWidth (
    constant DEVICE : string;
    constant MUX_FACTOR: integer)
    return integer;
  
  -- determines the ISERDES/OSERDES multiplexing factor
  function GetSerdesMuxFactor (
    constant MUX_FACTOR : integer;
    constant DDR_ENABLED: integer)
    return integer;

  -- determines the muxing word count
  function GetMuxWordCount (
    constant MUX_FACTOR : integer;
    constant DDR_ENABLED: integer)
    return integer;

  -- determines the muxing word count counter bitwidth
  function GetMuxWordCountBitWidth (
    constant MUX_FACTOR : integer;
    constant DDR_ENABLED: integer)
    return integer;

  -- returns true if the given number is even
  function IsEven (
    constant NUMBER : integer)
    return boolean;

  -- returns a delay tap training pattern vector depends on the vector's bit width
  function GetPatDelay (
    constant BIT_WIDTH : integer)
    return std_logic_vector;

  -- returns a bitslip training pattern vector depends on the vector's bit width
  function GetPatBitslip (
    constant BIT_WIDTH : integer)
    return std_logic_vector;

  function GetSDR_DDR (
    constant DDR_ENABLED : integer range 0 to 1)
    return string;

  -- returns number of bits for training cycle counter
  function TrainingCounterWidth(constant TRAINING_SPEED : string) return integer;

end package mmi64_p_muxdemux_pkg;

package body mmi64_p_muxdemux_pkg is

  -- determines the ISERDES/OSERDES multiplexing factor and multiplexing word count
  procedure MuxParameters (
    constant MUX_FACTOR  : in  integer;
    constant DDR_ENABLED : in  integer;
    serdesfactor         : out integer;
    wordcount            : out integer) is
    variable rest : integer := 100;
    variable start, ende, i, factor, wc : integer;
  begin
    if DDR_ENABLED = 0 then
      ende := 8;
      factor := 1;
    else
      ende := 4;
      factor := 2;
    end if;
    -- limit the minimum serdes mux factor to 4 for higher mux factors to help to meet timing
    if MUX_FACTOR < 4 then
      start := (2/factor);
    else
      start := (4/factor);
    end if;
    for j in start to ende loop
      i := j * factor;
      wc := MUX_FACTOR / i;
      if wc * i < MUX_FACTOR then wc := wc + 1; end if;
      if (i * wc) - mux_factor <= rest then
        serdesfactor := i;
        wordcount := wc;
        rest := (i * wc) - mux_factor;
      end if;
    end loop;
  end MuxParameters;

  -- determines the training Tap counter width
  function GetTTCBitWidth (
    constant DEVICE : string)
    return integer is
  begin
    if DEVICE = "XV7S" then
      return 7;
    elsif DEVICE = "XVUS" then
      return 10;
    else
      return 10;
    end if;
  end GetTTCBitWidth;
  
  -- determines the Tap counter width
  function GetTCBitWidth (
    constant DEVICE : string)
    return integer is
  begin
    if DEVICE = "XV7S" then
      return 5;
    elsif DEVICE = "XVUS" then
      return 9;
    else
      return 9;
    end if;
  end GetTCBitWidth;
    
  -- determines the statistic output width of one mux/demux channel
  function GetBasicStatBitWidth (
    constant DEVICE : string)
    return integer is
  begin
    if DEVICE = "XV7S" then
      return 16;
    elsif DEVICE = "XVUS" then
      return 24;
    else
      return 24;
    end if;
  end GetBasicStatBitWidth;
  
  -- determines the statistic output width (all chennels together)
  function GetStatBitWidth (
    constant DEVICE : string;
    constant MUX_FACTOR: integer)
    return integer is
  begin
    return GetBasicStatBitWidth(DEVICE)*(72/MUX_FACTOR);
  end GetStatBitWidth;
  
  -- determines the ISERDES/OSERDES multiplexing factor
  function GetSerdesMuxFactor (
    constant MUX_FACTOR : integer;
    constant DDR_ENABLED: integer)
    return integer is
    variable serdesfactor, wordcount : integer;
  begin
    MuxParameters (MUX_FACTOR, DDR_ENABLED, serdesfactor, wordcount);
    return serdesfactor;
  end GetSerdesMuxFactor;

  -- determines the muxing word count
  function GetMuxWordCount (
    constant MUX_FACTOR : integer;
    constant DDR_ENABLED: integer)
    return integer is
    variable serdesfactor, wordcount : integer;
  begin
    MuxParameters (MUX_FACTOR, DDR_ENABLED, serdesfactor, wordcount);
    return wordcount;
  end GetMuxWordCount;

  -- determines the muxing word count counter bitwidth
  function GetMuxWordCountBitWidth (
    constant MUX_FACTOR : integer;
    constant DDR_ENABLED: integer)
    return integer is
    variable serdesfactor, wordcount : integer;
  begin
    MuxParameters (MUX_FACTOR, DDR_ENABLED, serdesfactor, wordcount);
    if wordcount <= 2 then
      return 1;
    elsif wordcount <= 4 then
      return 2;
    elsif wordcount <= 8 then
      return 3;
    elsif wordcount <= 16 then
      return 4;
    else
      return -1;
    end if;
  end GetMuxWordCountBitWidth;

  -- returns true if the given number is even
  function IsEven (
    constant NUMBER : integer)
    return boolean is
  begin
    if (NUMBER mod 2) = 0 then
      return true;
    else
      return false;
    end if;
  end IsEven;

  -- returns a delay tap training pattern vector depends on the vector's bit width
  function GetPatDelay (
    constant BIT_WIDTH : integer)
    return std_logic_vector is
    variable retsig    : std_logic_vector(BIT_WIDTH-1 downto 0);
  begin
    for i in 0 to BIT_WIDTH-1 loop
      if (i mod 2) = 0 then
        retsig(i) := '0';
      else
        retsig(i) := '1';
      end if;
    end loop;
    return retsig;
  end GetPatDelay;

  -- returns a bitslip training pattern vector depends on the vector's bit width
  function GetPatBitslip (
    constant BIT_WIDTH : integer)
    return std_logic_vector is
    variable retsig    : std_logic_vector(BIT_WIDTH-1 downto 0);
  begin
    retsig              := (others => '1');
    retsig(0)           := '0';
    --retsig(BIT_WIDTH-1) := '0';
    return retsig;
  end GetPatBitslip;

  function GetSDR_DDR (
    constant DDR_ENABLED : integer range 0 to 1)
    return string is
  begin
    if DDR_ENABLED = 0 then
      return "SDR";
    else
      return "DDR";
    end if;
  end GetSDR_DDR;

  function TrainingCounterWidth(constant TRAINING_SPEED  : string) return integer is
    constant REAL_WIDTH : integer  := 8; -- cycle counter bit width used for real IDELAY calibration logic
    constant FAST_WIDTH : integer  := 5; -- cycle counter bit width used for fast simulation
  begin
    if TRAINING_SPEED="real" or TRAINING_SPEED="REAL" then
      return REAL_WIDTH;
    elsif TRAINING_SPEED="fast" or TRAINING_SPEED="FAST" then
      return FAST_WIDTH;
    elsif TRAINING_SPEED="auto" or TRAINING_SPEED="AUTO" then
      -- synthesis translate_off
      return FAST_WIDTH;
      -- synthesis translate_on
      return REAL_WIDTH;
    end if;
    
    report "Illegal setting for PIN_TRAINING_SPEED: " & TRAINING_SPEED & " (allowed: auto, real, fast)" severity failure;
    return 0;
  end function TrainingCounterWidth;

end package body mmi64_p_muxdemux_pkg;


-------------------------------------------------------------------------------
-- mmi64_p_muxdemux_ctrl_fsm module
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mmi64_p_muxdemux_ctrl_fsm is ---X
  generic (
    TRAINING_CLOCK_CYCLES_BIT :     integer range 4 to 16 := 8;
    DEVICE                    :    string := "XV7S");          --! "XV7S"- Xilinx Virtex 7series; "XVUS"- Xilinx Virtex UltraScale
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    mode          : out std_logic_vector(8 downto 0));  -- mux/demux training mode

end mmi64_p_muxdemux_ctrl_fsm;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
library work;
  use work.mmi64_p_muxdemux_pkg.all;

architecture rtl of mmi64_p_muxdemux_ctrl_fsm is
  constant TTC_WIDTH            : integer := GetTTCBitWidth(DEVICE);
  signal int_mux_mode           : std_logic_vector (8 downto 0);
  signal training_clock_counter : std_logic_vector (TRAINING_CLOCK_CYCLES_BIT downto 0);
  signal training_tap_counter   : std_logic_vector(TTC_WIDTH-1 downto 0);
  signal mode_counter           : std_logic_vector (1 downto 0);
  signal next_mux_mode, next_mux_mode_d : std_logic;

begin
  P_muxdemux_ctrl : process (clk)
  begin
    if clk'event and clk = '1' then
      if rst = '1' then
        training_clock_counter                                                        <= (others => '0');
        training_tap_counter                                                          <= (others => '0');
        training_tap_counter(0)                                                       <= ('1');
        mode_counter                                                                  <= (others => '0');
        int_mux_mode(MUX_MODE_BIT_RST)                                                <= '1';
        int_mux_mode(MUX_MODE_BIT_MUX_PAT_DELAY)                                      <= '1';
        int_mux_mode(MUX_MODE_BIT_MUX_PAT_BITSLIP)                                    <= '0';
        int_mux_mode(MUX_MODE_BIT_MUX_PAT_WORDSLIP)                                   <= '0';
        int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_DELAY)                                    <= '0';
        int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_BITSLIP)                                  <= '0';
        int_mux_mode(MUX_MODE_BIT_DEMUX_NEXT_TAP)                                     <= '0';
        int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_WORDSLIP)                                 <= '0';
        int_mux_mode(MUX_MODE_BIT_PAT_USER)                                           <= '0';
        next_mux_mode <= '0';
        next_mux_mode_d <= '0';
      else
        int_mux_mode(MUX_MODE_BIT_RST)                                                <= '0';
        int_mux_mode(MUX_MODE_BIT_DEMUX_NEXT_TAP)                                     <= next_mux_mode or next_mux_mode_d;
        next_mux_mode <= '0';
        next_mux_mode_d <= next_mux_mode;
        training_clock_counter                                                        <= training_clock_counter + 1;
        case mode_counter is
          when "00"                                                   =>
            -- we are in the tap delay training stage
            -- the reset to the demux modules we release after a while
            if int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_DELAY) = '0' and training_clock_counter(TRAINING_CLOCK_CYCLES_BIT) = '1' then
              int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_DELAY)                              <= '1';
              training_clock_counter                                                  <= (others => '0');
            end if;
            if int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_DELAY) = '1' and training_clock_counter(TRAINING_CLOCK_CYCLES_BIT) = '1' then
              training_tap_counter                                                    <= training_tap_counter + 1;
              training_clock_counter                                                  <= (others => '0');
              next_mux_mode <= '1';
            end if;
            if training_tap_counter(5) = '1' then
              mode_counter                                                            <= mode_counter + 1;
              training_clock_counter                                                  <= (others => '0');
            end if;
          when "01"                                                   =>
            -- now we are in the bit slip training stage
            int_mux_mode(MUX_MODE_BIT_MUX_PAT_DELAY)                                  <= '0';
            int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_DELAY)                                <= '0';
            int_mux_mode(MUX_MODE_BIT_MUX_PAT_BITSLIP)                                <= '1';
            if int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_BITSLIP) = '0' and training_clock_counter(TRAINING_CLOCK_CYCLES_BIT) = '1' then
              training_clock_counter                                                  <= (others => '0');
              int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_BITSLIP)                            <= '1';
            end if;
            if int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_BITSLIP) = '1' and training_clock_counter(TRAINING_CLOCK_CYCLES_BIT) = '1' then
              mode_counter                                                            <= mode_counter + 1;
            end if;
          when "10"                                                   =>
            -- now we are in word slip training stage
            int_mux_mode(MUX_MODE_BIT_MUX_PAT_BITSLIP)                                <= '0';
            int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_BITSLIP)                              <= '0';
            int_mux_mode(MUX_MODE_BIT_MUX_PAT_WORDSLIP)                               <= '1';
            if int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_WORDSLIP) = '0' and training_clock_counter(TRAINING_CLOCK_CYCLES_BIT) = '1' then
              training_clock_counter                                                  <= (others => '0');
              int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_WORDSLIP)                           <= '1';
            end if;
            if int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_WORDSLIP) = '1' and training_clock_counter(TRAINING_CLOCK_CYCLES_BIT) = '1' then
              mode_counter                                                            <= mode_counter + 1;
            end if;
          when "11"                                                   =>
            -- DUR muxing enabled
            int_mux_mode(MUX_MODE_BIT_MUX_PAT_WORDSLIP)                               <= '0';
            int_mux_mode(MUX_MODE_BIT_DEMUX_PAT_WORDSLIP)                             <= '0';
            int_mux_mode(MUX_MODE_BIT_PAT_USER)                                       <= '1';
            mode_counter                                                              <= mode_counter;
          when others                                                 => mode_counter <= mode_counter;
        end case;
      end if;
    end if;
  end process P_muxdemux_ctrl;
  mode                                                                          <= int_mux_mode;

end architecture rtl;


-------------------------------------------------------------------------------
-- mmi64_p_muxdemux_mux module
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mmi64_p_muxdemux_mux is

  generic (
    DIFF_ENABLED : integer range 0 to 1  := 0;   -- use/don't use differential signaling
    DDR_ENABLED  : integer range 0 to 1  := 0;   -- use/don't use DDR
    MUX_FACTOR   : integer range 2 to 64 := 8;   -- supported multiplexing factors
    ODELAY_VALUE : integer range 0 to 31 := 0;  -- ODELAY2 tap value
    DEVICE       : string                := "XV7S");   --! "XV7S"- Xilinx Virtex 7series; "XVUS"- Xilinx Virtex UltraScale
  port (
    mux_clk_hs    : in  std_logic;                     -- high speed multiplexing clock
    mux_clk_dv    : in  std_logic;                     -- divided (low speed) multiplexing clock
    mode          : in  std_logic_vector(8 downto 0);  -- operation mode
    data_from_dut : in  std_logic_vector (MUX_FACTOR-1 downto 0);
                                                       -- signals provided by the user design (DUT)
    data_to_pin   : out std_logic;                     -- outgoing data (I/O pin) if differential
                                                       -- signaling is not used
    data_to_pin_n : out std_logic := '0';              -- outgoing data (I/O pins) if differential
    data_to_pin_p : out std_logic := '1');             -- signaling is used
end entity mmi64_p_muxdemux_mux;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
library unisim;
use unisim.vcomponents.all;
library work;
use work.mmi64_p_muxdemux_pkg.all;
use work.fpga_wrapper_pkg.all;

architecture rtl of mmi64_p_muxdemux_mux is
  constant SERDES_MUX_FACTOR        : integer := GetSerdesMuxFactor(MUX_FACTOR, DDR_ENABLED);
  constant MUX_WORD_COUNT           : integer := GetMuxWordCount(MUX_FACTOR, DDR_ENABLED);
  constant MUX_WORD_COUNT_BITWIDTH  : integer := GetMuxWordCountBitWidth(MUX_FACTOR, DDR_ENABLED);

  signal rst, pat_delay, pat_bitslip, pat_user : std_logic;
  signal pat_wordslip                          : std_logic;
  signal pre_serdes_data                       : std_logic_vector (SERDES_MUX_FACTOR-1 downto 0);
  signal serdes_data, serdes_data_raw          : std_logic_vector (7 downto 0);
  signal wordcounter                           : std_logic_vector (MUX_WORD_COUNT_BITWIDTH-1 downto 0);
  signal data_to_pin_int                       : std_logic;
  signal data_to_pin_dly                       : std_logic;

begin

  -- clock in mode signals to help P&R to meet timing
  P_mode_regs : process (mux_clk_dv)
  begin  -- process P_mode_regs
    if mux_clk_dv'event and mux_clk_dv = '1' then
      rst         <= mode(MUX_MODE_BIT_RST);
      pat_delay   <= mode(MUX_MODE_BIT_MUX_PAT_DELAY);
      pat_bitslip <= mode(MUX_MODE_BIT_MUX_PAT_BITSLIP);
      pat_wordslip <= mode(MUX_MODE_BIT_MUX_PAT_WORDSLIP);
      pat_user    <= mode(MUX_MODE_BIT_PAT_USER);
    end if;
  end process P_mode_regs;

  -- word counter signal generation
  P_toggle : process (mux_clk_dv)
  begin  -- process P_toggle
    if mux_clk_dv'event and mux_clk_dv = '1' then
      if rst = '1' then
        wordcounter <= (others => '0');
      else
        if wordcounter = conv_std_logic_vector(MUX_WORD_COUNT-1, wordcounter'length) then
          wordcounter <= (others => '0');
        else
          wordcounter <= wordcounter + 1;
        end if;
      end if;
    end if;
  end process P_toggle;

  P_pre_serdes_data: process (data_from_dut, wordcounter)
    variable data_from_dut_int : std_logic_vector ((SERDES_MUX_FACTOR*MUX_WORD_COUNT)-1 downto 0);
  begin
    data_from_dut_int := (others => '0');
    data_from_dut_int (MUX_FACTOR-1 downto 0) := data_from_dut;
    pre_serdes_data <= (others=>'0');
    for i in 0 to MUX_WORD_COUNT-1 loop
      if wordcounter = i then
        pre_serdes_data <= data_from_dut_int (((i+1)*SERDES_MUX_FACTOR)-1 downto i*SERDES_MUX_FACTOR);
      end if;
    end loop;
  end process P_pre_serdes_data;

  -- set serdes data depends on operation mode
  P_serdes_data : process (pat_bitslip, pat_delay, pat_user, pat_wordslip, pre_serdes_data, wordcounter)
  begin
    serdes_data                          <= (others => '0');
    if pat_delay = '1' then
      serdes_data(SERDES_MUX_FACTOR-1 downto 0) <= GetPatDelay(SERDES_MUX_FACTOR);
    end if;
    if pat_bitslip = '1' then
      serdes_data(SERDES_MUX_FACTOR-1 downto 0) <= GetPatBitslip(SERDES_MUX_FACTOR);
    end if;
    if pat_wordslip = '1' then
      if wordcounter = 0 then
        serdes_data(SERDES_MUX_FACTOR-1 downto 0) <= (others => '1');
      else
        serdes_data(SERDES_MUX_FACTOR-1 downto 0) <= (others => '0');
      end if;
    end if;
    if pat_user = '1' then
      serdes_data(SERDES_MUX_FACTOR-1 downto 0) <= pre_serdes_data;
    end if;
  end process P_serdes_data;
  
  G_SERDES_DATA_RAW:for bit_idx in 0 to SERDES_MUX_FACTOR-1 generate
      serdes_data_raw(bit_idx*2)   <= serdes_data(bit_idx);
      serdes_data_raw(bit_idx*2+1) <= serdes_data(bit_idx);
  end generate;

  -- OSERDES
  G_XILINX_7_SERIES : if DEVICE = "XV7S" generate 
    oserdese2_master : OSERDES_WRAPPER
    generic map (
      DATA_RATE_OQ => GetSDR_DDR(DDR_ENABLED),
      DATA_RATE_TQ => "SDR",
      DATA_WIDTH   => SERDES_MUX_FACTOR,
  
      TRISTATE_WIDTH => 1,
      SERDES_MODE    => "MASTER")
    port map (
      D1             => serdes_data(0),
      D2             => serdes_data(1),
      D3             => serdes_data(2),
      D4             => serdes_data(3),
      D5             => serdes_data(4),
      D6             => serdes_data(5),
      D7             => serdes_data(6),
      D8             => serdes_data(7),
      T1             => '0',
      T2             => '0',
      T3             => '0',
      T4             => '0',
      SHIFTIN1       => '0',
      SHIFTIN2       => '0',
      SHIFTOUT1      => open,
      SHIFTOUT2      => open,
      OCE            => '1',
      CLK            => mux_clk_hs,
      CLKDIV         => mux_clk_dv,
      OQ             => data_to_pin_dly,
      TQ             => open,
      OFB            => open,
      TBYTEIN        => '0',
      TBYTEOUT       => open,
      TFB            => open,
      TCE            => '0',
      RST            => rst
    );
    
  data_to_pin_int <= data_to_pin_dly;
  end generate G_XILINX_7_SERIES;
  
  G_XILINX_ULTRA_SCALE : if DEVICE = "XVUS" generate
    oserdese3_master : OSERDESE3 
    generic map(
      DATA_WIDTH      => 8
    ) port map (
      OQ              => data_to_pin_dly,
      T_OUT           => open,
      CLK             => mux_clk_hs,
      CLKDIV          => mux_clk_dv,
      D               => serdes_data_raw,
      RST             => rst,
      T               => '0'
    );
  data_to_pin_int <= data_to_pin_dly;
  end generate G_XILINX_ULTRA_SCALE;

  G_DIFF_ENABLED_0 : if DIFF_ENABLED = 0 generate
    I_OBUF         : OBUF_WRAPPER port map (O => data_to_pin, I => data_to_pin_int);
  end generate G_DIFF_ENABLED_0;
  G_DIFF_ENABLED_1 : if DIFF_ENABLED = 1 generate
    I_OBUFDS       : OBUFDS_WRAPPER
      generic map (
        SLEW => "FAST")
      port map (
        O => data_to_pin_p,
        OB => data_to_pin_n,
        I => data_to_pin_int);
  end generate G_DIFF_ENABLED_1;

end architecture rtl;


-------------------------------------------------------------------------------
-- mmi64_p_muxdemux_demux module
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.mmi64_p_muxdemux_pkg.all;

entity mmi64_p_muxdemux_demux is
  generic (
    DEVICE       : string                := "XV7S";   --! "XV7S"- Xilinx Virtex 7series; "XVUS"- Xilinx Virtex UltraScale
    DIFF_ENABLED : integer range 0 to 1  := 0;   -- use/don't use differential signalling
    DDR_ENABLED  : integer range 0 to 1  := 0;   -- use/don't use DDR
    MUX_FACTOR   : integer range 2 to 64 := 8);  -- supported multiplexing factors

  port (
    mux_clk_hs      : in  std_logic;                     -- high speed multiplexing clock
    mux_clk_dv      : in  std_logic;                     -- divided (low speed) multiplexing clock
    mode            : in  std_logic_vector(8 downto 0);  -- operation mode
    output_delay_i  : in  std_logic;                     -- delay data_to_dut for one clock cycle 
    sync_detected_o : out std_logic;                     -- pulse signalling syncing word has been found
    data_to_dut     : out std_logic_vector (MUX_FACTOR-1 downto 0);
                                                         -- signals delivered to the user design (DUT)
    data_from_pin   : in  std_logic;                     -- incoming data (I/O pin) if differential
                                                         -- signalling is not used
    data_from_pin_n : in  std_logic;                     -- incoming data (I/O pin) if differential
    data_from_pin_p : in  std_logic;                     -- signalling is used
    -- status signals
    tap_start       : out std_logic_vector (GetTCBitWidth(DEVICE)-1 downto 0);
    tap_end         : out std_logic_vector (GetTCBitWidth(DEVICE)-1 downto 0);
    tap_value_in    : out std_logic_vector (GetTCBitWidth(DEVICE)-1 downto 0);
    tap_value_out   : out std_logic_vector (GetTCBitWidth(DEVICE)-1 downto 0);
    bitslip         : out std_logic_vector (2 downto 0));
end entity mmi64_p_muxdemux_demux;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
library unisim;
use unisim.vcomponents.all;
library work;
use work.mmi64_p_muxdemux_pkg.all;
use work.fpga_wrapper_pkg.all;
use work.BitSlipInLogic_comp.all;

architecture rtl of mmi64_p_muxdemux_demux is
  constant SERDES_MUX_FACTOR        : integer := GetSerdesMuxFactor(MUX_FACTOR, DDR_ENABLED);
  constant MUX_WORD_COUNT           : integer := GetMuxWordCount(MUX_FACTOR, DDR_ENABLED);
  constant MUX_WORD_COUNT_BITWIDTH  : integer := GetMuxWordCountBitWidth(MUX_FACTOR, DDR_ENABLED);
  constant TC_WIDTH                 : integer := GetTCBitWidth(DEVICE);

  signal rst, pat_delay, pat_bitslip, pat_wordslip, pat_user, next_tap              : std_logic;
  signal serdes_data, training_data, training_data_d, serdes_data_all_one           : std_logic_vector (7 downto 0);
  signal serdes_data_d, serdes_data_raw                                             : std_logic_vector (7 downto 0);
  signal delayed_data                                                               : std_logic;
  signal in_delay_ce, in_delay_inc_dec, in_delay_ld, in_delay_ld_exe                : std_logic;
  signal in_delay_value_in, in_delay_value_out, in_delay_value_out_r                : std_logic_vector (TC_WIDTH-1 downto 0);
  signal mux_clk_hs_inv                                                             : std_logic;
  signal iserdes_bitslip                                                            : std_logic;
  signal pat_delay_stable                                                           : std_logic;
  signal pat_bitslip_valid, pat_bitslip_stable                                      : std_logic;
  signal next_tap_d                                                                 : std_logic;
  signal tap_delay_start, tap_delay_end, tap_delay_start_saved, tap_delay_end_saved : std_logic_vector (TC_WIDTH-1 downto 0);
  signal tap_delay_training_start                                                   : std_logic;
  signal pat_delay_d, pat_delay_dd                                                  : std_logic;
  signal bit_slip_counter                                                           : std_logic_vector (2 downto 0);
  signal bit_slip_value                                                             : std_logic_vector (2 downto 0);
  signal data_from_pin_int                                                          : std_logic;
  signal int_next_tap, int_next_tap_d                                               : std_logic;
  signal int_data_to_dut, int_data_to_dut_t1, int_data_to_dut_d                     : std_logic_vector ((SERDES_MUX_FACTOR*MUX_WORD_COUNT)-1 downto 0);
  signal wordcounter                                                                : std_logic_vector (MUX_WORD_COUNT_BITWIDTH-1 downto 0);
  signal us_delay_cnt_r                                                             : std_logic_vector(4 downto 0);
  signal us_load_enable_r                                                           : std_logic;
  signal us_load_execute_r                                                          : std_logic;
  signal en_vtc                                                                     : std_ulogic;
  signal sync_detected_r                                                            : std_ulogic;

begin

  -- clock in mode signals to help P&R to meet timing
  P_mode_regs : process (mux_clk_dv)
  begin
    if mux_clk_dv'event and mux_clk_dv = '1' then
      rst         <= mode(MUX_MODE_BIT_RST);
      pat_delay   <= mode(MUX_MODE_BIT_DEMUX_PAT_DELAY);
      pat_bitslip <= mode(MUX_MODE_BIT_DEMUX_PAT_BITSLIP);
      pat_wordslip <= mode(MUX_MODE_BIT_DEMUX_PAT_WORDSLIP);
      pat_user    <= mode(MUX_MODE_BIT_PAT_USER);
      int_next_tap    <= mode(MUX_MODE_BIT_DEMUX_NEXT_TAP);
      int_next_tap_d <= int_next_tap;
    end if;
  end process P_mode_regs;
  next_tap <= int_next_tap and (not int_next_tap_d);

  G_DIFF_ENABLED_0 : if DIFF_ENABLED = 0 generate
    I_IBUF         : IBUF_WRAPPER port map (O => data_from_pin_int, I => data_from_pin);
  end generate G_DIFF_ENABLED_0;
  G_DIFF_ENABLED_1 : if DIFF_ENABLED = 1 generate
    I_IBUFDS       : IBUFDS_WRAPPER
      generic map ( DIFF_TERM    => true,  -- Differential Termination
                    IBUF_LOW_PWR => false)  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      port map (O                => data_from_pin_int,
                I                => data_from_pin_p,
                IB               => data_from_pin_n);
  end generate G_DIFF_ENABLED_1;

  G_XILINX_7_SERIES : if DEVICE = "XV7S" generate 
    -- IDELAY instance
    -- IDELAY/ODELAY chain delay resolution = 1/(32 x 2 x FREF)
    -- => 78ps @ FREF = 200MHz
    --   => range: 0ps - 2.4 ns
    I_idelay : IDELAY_WRAPPER
    generic map (
      CINVCTRL_SEL          => "FALSE",           -- TRUE, FALSE
      DELAY_SRC             => "IDATAIN",         -- IDATAIN, DATAIN
      HIGH_PERFORMANCE_MODE => "FALSE",           -- TRUE, FALSE
      IDELAY_TYPE           => "VAR_LOAD",        -- FIXED, VARIABLE, or VAR_LOAD
      IDELAY_VALUE          => 0,                 -- 0 to 31
      REFCLK_FREQUENCY      => 200.0,
      PIPE_SEL              => "FALSE",
      SIGNAL_PATTERN        => "DATA"             -- CLOCK, DATA
      )
    port map (
      DATAOUT               => delayed_data,
      DATAIN                => '0',               -- Data from FPGA logic
      C                     => mux_clk_dv,
      CE                    => in_delay_ce,       --IN_DELAY_DATA_CE,
      INC                   => in_delay_inc_dec,  --IN_DELAY_DATA_INC,
      IDATAIN               => data_from_pin_int, -- Driven by IOB
      LD                    => in_delay_ld,
      REGRST                => rst,
      LDPIPEEN              => '0',
      CNTVALUEIN            => in_delay_value_in,
      CNTVALUEOUT           => in_delay_value_out,
      CINVCTRL              => '0'
    );
  
    -- ISERDES instance
    mux_clk_hs_inv <= not mux_clk_hs;
    i_iserdes : ISERDES_WRAPPER
    generic map (
      DATA_RATE         => GetSDR_DDR(DDR_ENABLED),
      DATA_WIDTH        => SERDES_MUX_FACTOR,
      INTERFACE_TYPE    => "NETWORKING",
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN    => "FALSE",
      NUM_CE            => 2,
      OFB_USED          => "FALSE",
      IOBDELAY          => "IFD",            -- Use input at DDLY to output the data on Q1-Q6
      SERDES_MODE       => "MASTER")
    port map (
      Q1                => serdes_data(7),
      Q2                => serdes_data(6),
      Q3                => serdes_data(5),
      Q4                => serdes_data(4),
      Q5                => serdes_data(3),
      Q6                => serdes_data(2),
      Q7                => serdes_data(1),
      Q8                => serdes_data(0),
      SHIFTOUT1         => open,
      SHIFTOUT2         => open,
      BITSLIP           => iserdes_bitslip,  -- 1-bit Invoke Bitslip. This can be used with any
                                            -- DATA_WIDTH, cascaded or not.
      CE1               => '1',              -- 1-bit Clock enable input
      CE2               => '1',              -- 1-bit Clock enable input
      CLK               => mux_clk_hs,       -- Fast clock driven by MMCM
      CLKB              => mux_clk_hs_inv,   -- Locally inverted clock
      CLKDIV            => mux_clk_dv,       -- Slow clock driven by MMCM
      CLKDIVP           => '0',
      D                 => '0',
      DDLY              => delayed_data,     -- 1-bit Input signal from IODELAYE1.
      RST               => rst,              -- 1-bit Asynchronous reset only.
      SHIFTIN1          => '0',
      SHIFTIN2          => '0',
      -- unused connections
      DYNCLKDIVSEL      => '0',
      DYNCLKSEL         => '0',
      OFB               => '0',
      OCLK              => '0',
      OCLKB             => '0',
      O                 => open            -- unregistered output of ISERDESE1
    );
  end generate G_XILINX_7_SERIES;
  
  G_XILINX_ULTRA_SCALE : if DEVICE = "XVUS" generate
    -----------------------------------------
    -- IDELAY instance
    -- IDELAY/ODELAY chain delay resolution = 1/(32 x 2 x FREF)
    -- => 78ps @ FREF = 200MHz
    -- => range: 0ps - 2.4 ns
    -----------------------------------------
    I_idelay : IDELAYE3           
    generic map (
      CASCADE          => "NONE",
      DELAY_FORMAT     => "COUNT",
      DELAY_SRC        => "IDATAIN",
      DELAY_TYPE       => "VAR_LOAD",
      DELAY_VALUE      => 16,
      IS_CLK_INVERTED  => '0',
      IS_RST_INVERTED  => '0',
      REFCLK_FREQUENCY => 200.0,
      UPDATE_MODE      => "ASYNC"
    ) port map (
      CASC_OUT         => open,
      CNTVALUEOUT      => in_delay_value_out,
      DATAOUT          => delayed_data,
      CASC_IN          => '0',
      CASC_RETURN      => '0',
      CE               => '0',
      CLK              => mux_clk_dv,
      CNTVALUEIN       => in_delay_value_in,
      DATAIN           => '0',
      EN_VTC           => en_vtc,
      IDATAIN          => data_from_pin_int,
      INC              => in_delay_inc_dec,
      LOAD             => in_delay_ld_exe,
      RST              => rst
    );
    en_vtc <= not us_load_enable_r; --The EN_VTC pin should be held Low during the delay change command to ensure that any automatic adjustments are stopped
    -----------------------------------------
    -- ISERDES instance
    -----------------------------------------
    mux_clk_hs_inv <= not mux_clk_hs;
    i_iserdes : ISERDESE3 
    generic map(
      DATA_WIDTH      => 8, -- Parallel data width (4,8)
      IDDR_MODE       => "FALSE"
    ) port map (
      FIFO_EMPTY      => open,
      INTERNAL_DIVCLK => open,
      Q               => serdes_data_raw,
      CLK             => mux_clk_hs,
      CLKDIV          => mux_clk_dv,
      CLK_B           => mux_clk_hs_inv,
      D               => delayed_data,
      FIFO_RD_CLK     => '0',
      FIFO_RD_EN      => '0',
      RST             => rst
    );
    -----------------------------------------
    -- Bitslip instance
    -----------------------------------------
    serdes_data_d <=  serdes_data_raw when (DDR_ENABLED = 1) else ("0000" & serdes_data_raw(6) & serdes_data_raw(4) & serdes_data_raw(2) & serdes_data_raw(0)); 
    
    i_BitSlipInLogic : BitSlipInLogic    
    generic map(
      C_DataWidth     => SERDES_MUX_FACTOR,
      C_InputReg      => 0
    ) port map (
      DataIn_pin      => serdes_data_d(SERDES_MUX_FACTOR-1 downto 0),
      Bitslip_pin     => iserdes_bitslip,
      SlipVal_pin     => (others=>'0'),
      CompVal_pin     => (others=>'0'),
      Ena_pin         => '1',
      Rst_pin         => rst,
      Clk_pin         => mux_clk_dv,
      DataOut_pin     => serdes_data(SERDES_MUX_FACTOR-1 downto 0),
      ErrOut_pin      => open
    );  
  end generate G_XILINX_ULTRA_SCALE;
  

  -- training algorithm                 -------------------------------------------------------
  in_delay_inc_dec                      <= '1';  -- always increment
  in_delay_ce                           <= next_tap and pat_delay;
  
  P_training          : process (mux_clk_dv)
  begin
    if mux_clk_dv'event and mux_clk_dv = '1' then
      if rst = '1' then
        training_data                     <= (others => '0');
        training_data_d                   <= (others => '0');
        pat_delay_stable                  <= '1';
        pat_bitslip_valid                 <= '0';
        pat_bitslip_stable                <= '0';
        next_tap_d                        <= '0';
        tap_delay_start                   <= (others => '0');
        tap_delay_end                     <= (others => '0');
        tap_delay_start_saved             <= (others => '0');
        tap_delay_end_saved               <= (others => '0');
        tap_delay_training_start          <= '1';
        pat_delay_d                       <= '0';
        pat_delay_dd                      <= '0';
        bit_slip_counter                  <= (others => '0');
        bit_slip_value                    <= (others => '0');
        iserdes_bitslip                   <= '0';
      else
        -- some preparation work          ------------------------------------------------
        pat_delay_d                       <= pat_delay;
        pat_delay_dd                      <= pat_delay_d;
        iserdes_bitslip                   <= '0';
        -- register iserdes output data to relax timing
          training_data                     <= serdes_data;
          training_data_d                   <= training_data;
        -- determine status signals of the received data
        next_tap_d                        <= next_tap;
        if (pat_delay = '1') and (training_data(SERDES_MUX_FACTOR-1 downto 0) /= training_data_d(SERDES_MUX_FACTOR-1 downto 0)) then
          pat_delay_stable                <= '0';
        end if;
        if (next_tap_d = '1') and (pat_delay_stable = '0') then
          pat_delay_stable                <= '1';
        end if;
        if training_data (SERDES_MUX_FACTOR-1 downto 0) = GetPatBitslip(SERDES_MUX_FACTOR) then
          pat_bitslip_valid               <= '1';
        else
          pat_bitslip_valid               <= '0';
        end if;
        -- tap delay training             ---------------------------------------------------
        if (pat_delay_d = '1') and (us_load_enable_r = '1') then
          -- do we have stable data and we are looking for the start of a window?
          if (pat_delay_stable = '1') and (tap_delay_training_start = '1') then
            -- we found the start of a window
            --   -> store start tap value and type of stable pattern
            tap_delay_start               <= in_delay_value_out_r;
            tap_delay_end                 <= in_delay_value_out_r;
            tap_delay_training_start      <= '0';
          end if;
          -- do we look for the end of a window?
          if tap_delay_training_start = '0' then
            -- check if the data are still valid?
            if (pat_delay = '1') and (pat_delay_stable = '1') then
              -- store the current tap value as the (properly) end of the window
              tap_delay_end               <= in_delay_value_out_r;
            else
              -- data are not valid anymore or end of tap delays reached
              --   -> we found the end of the window
              --   -> check if the new window is better as the saved one
              --   -> reset window search algorithm
              if (tap_delay_end - tap_delay_start) > (1 + tap_delay_end_saved - tap_delay_start_saved) then
                tap_delay_start_saved     <= tap_delay_start;
                tap_delay_end_saved       <= tap_delay_end;
              end if;
              tap_delay_training_start    <= '1';
            end if;
          end if;
        end if;
        -- bitslip training               -----------------------------------------------------
        if pat_bitslip = '1' then
          bit_slip_counter                <= bit_slip_counter + 1;
          -- change bit slip until data are valid
          if bit_slip_counter = "111" then
             if (pat_bitslip_valid /= '1') and (pat_bitslip_stable /= '1') then
              iserdes_bitslip             <= '1';
              bit_slip_value              <= bit_slip_value + 1;
            else
              pat_bitslip_stable <= '1';
            end if;
          end if;
        else
          bit_slip_counter                <= (others => '0');
        end if;
      end if;
    end if;
  end process P_training;
  -- tap delay training                 -------------------------------------------------------
  -- at the end of the tap delay training we need to load the best tap
  -- delay value into the IDELAY primitive
  P_in_delay_value_in : process (tap_delay_end_saved, tap_delay_start_saved, in_delay_ld, in_delay_value_out_r)
    variable diff     : std_logic_vector (TC_WIDTH-1 downto 0);
  begin
    diff := tap_delay_end_saved - tap_delay_start_saved;
    
    if DEVICE = "XV7S" then
      in_delay_value_in   <= tap_delay_start_saved + diff (TC_WIDTH-1 downto 1);
    elsif DEVICE = "XVUS" then
      if pat_delay = '0' then
        in_delay_value_in   <= tap_delay_start_saved + diff (TC_WIDTH-1 downto 1);
      else
        in_delay_value_in <= in_delay_value_out_r + 16;
      end if;
    end if;
  end process P_in_delay_value_in;
  
  in_delay_ld                           <= rst or (pat_delay_dd and (not pat_delay_d));
  in_delay_ld_exe                       <= us_load_execute_r; -- load new delay tap
  tap_start                             <= tap_delay_start_saved;
  tap_end                               <= tap_delay_end_saved;
  
  P_tap_value         : process (mux_clk_dv, rst)
  begin
    if rst = '1' then
      tap_value_in                      <= (others => '0');
      tap_value_out                     <= (others => '0');
    elsif mux_clk_dv'event and mux_clk_dv = '1' then
      tap_value_out                     <= in_delay_value_out_r;
      if in_delay_ld = '1' then
        tap_value_in                    <= in_delay_value_in;
      end if;
    end if;
  end process P_tap_value;
  -- bitslip training                   ---------------------------------------------------------
  bitslip                               <= bit_slip_value;
  -----------------------------------------------------------------------------

  -- expand ISERDES data to DUT signals
  serdes_data_all_one <= (others => '1');
  P_toggle : process (mux_clk_dv)
    variable i : integer;
  begin
    if mux_clk_dv'event and mux_clk_dv = '1' then
      if rst = '1' then
        wordcounter     <= (others => '0');
        int_data_to_dut_d   <= (others => '0');
        int_data_to_dut_t1  <= (others => '0');
        sync_detected_o     <= '0';
        sync_detected_r     <= '0';
      else
        if (pat_wordslip = '1') and (serdes_data (SERDES_MUX_FACTOR-1 downto 0) = serdes_data_all_one(SERDES_MUX_FACTOR-1 downto 0)) then
          if MUX_WORD_COUNT > 1 then
            wordcounter <= conv_std_logic_vector (1, wordcounter'length);
          else
            wordcounter <= conv_std_logic_vector (0, wordcounter'length);
          end if;
        elsif wordcounter = conv_std_logic_vector (MUX_WORD_COUNT-1, wordcounter'length) then
          wordcounter <= (others => '0');
        else
          wordcounter <= wordcounter + 1;
        end if;
        i := conv_integer (unsigned(wordcounter));
        int_data_to_dut_d ((i+1)*SERDES_MUX_FACTOR-1 downto i*SERDES_MUX_FACTOR) <= serdes_data (SERDES_MUX_FACTOR-1 downto 0);
    
        --Sync multiple dmux together
        int_data_to_dut_t1 <= int_data_to_dut;
        sync_detected_o <= '0';
        if (pat_wordslip = '1') and (serdes_data (SERDES_MUX_FACTOR-1 downto 0) = serdes_data_all_one(SERDES_MUX_FACTOR-1 downto 0)) and (sync_detected_r = '0') then
          -- provide pulse once sync word has been detected
          sync_detected_o <= '1';
          sync_detected_r <= '1';
        end if;
        
        
      end if;
    end if;
  end process P_toggle;
  --P_data_to_dut: process (serdes_data, int_data_to_dut_d, wordcounter)
  --  variable i: integer;
  --begin
  --  i := conv_integer (unsigned(wordcounter));
  --  int_data_to_dut <= int_data_to_dut_d;
  --  int_data_to_dut (((i+1)*SERDES_MUX_FACTOR)-1 downto (i*SERDES_MUX_FACTOR)) <= serdes_data (SERDES_MUX_FACTOR-1 downto 0);
  --end process P_data_to_dut;

  int_data_to_dut <= int_data_to_dut_d;

  --- Output data delay if required ---------
  data_to_dut <= int_data_to_dut_t1(data_to_dut'range) when (output_delay_i = '1') else int_data_to_dut(data_to_dut'range);
  
  --- UltraScale specific --------
  G_XV7S_DUMMY_LOGIC: if DEVICE = "XV7S" generate
    in_delay_value_out_r <= in_delay_value_out;
    us_load_enable_r     <= '1';
  end generate G_XV7S_DUMMY_LOGIC;
  
  G_XVUS_IDELAY_LOGIC: if DEVICE = "XVUS" generate
    P_UltraScale_delay_training : process (mux_clk_dv)
    begin
      if mux_clk_dv'event and mux_clk_dv = '1' then
        if rst = '1' then
          us_delay_cnt_r    <= (others=>'0');
          us_load_enable_r  <= '0';
          us_load_execute_r <= '0';
          in_delay_value_out_r <= (others=>'0');
        else
          -- In UltraScale CNTVALUEOUT is valid only when EN_VTC is low
          if en_vtc = '0' then
            in_delay_value_out_r <= in_delay_value_out;
          end if;
          -- Enable load sequence
          if next_tap = '1' then
            us_load_enable_r <= '1';
          elsif us_delay_cnt_r = 20 then
            us_load_enable_r <= '0';
          end if;
          -- count required cycles
          if us_load_enable_r = '1' then
            us_delay_cnt_r <= us_delay_cnt_r + 1;
          else
            us_delay_cnt_r <= (others =>'0');
          end if;
          -- Execute load stage
          if us_delay_cnt_r = 9 then
            us_load_execute_r <= '1';
          else
            us_load_execute_r <= '0';
          end if;
        end if;
      end if;
    end process P_UltraScale_delay_training;
  end generate G_XVUS_IDELAY_LOGIC;

end architecture rtl;

-------------------------------------------------------------------------------
-- mmi64_p_muxdemux_sync module
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mmi64_p_muxdemux_sync is
  generic (
    DMUX_NUM : integer := 8);   -- number of demux cells used

  port (
    clk            : in  std_logic;                     -- divided (low speed) multiplexing clock
    rst            : in  std_logic;                     -- reset signal (high active)
    sync_found_i   : in  std_logic_vector (DMUX_NUM-1 downto 0);  -- DMUX cell detected sync word
    output_delay_o : out std_logic_vector (DMUX_NUM-1 downto 0);  -- Activate delay cycle in DMUX cell
    error_o        : out std_logic);                              -- More then one cycle difference d 
end entity mmi64_p_muxdemux_sync;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
library unisim;
use unisim.vcomponents.all;
library work;
use work.mmi64_p_muxdemux_pkg.all;

architecture rtl of mmi64_p_muxdemux_sync is
  function OR_REDUCE(v : std_logic_vector) return std_logic is
    variable r : std_logic;
  begin
    r := '0';
    for i in v'range loop r := r or v(i); end loop;
    return r;
  end function OR_REDUCE;
  
  signal sync_started_r   : std_logic_vector (2 downto 0);
  signal output_delay_r   : std_logic_vector (DMUX_NUM-1 downto 0);
  signal delay_enable_r   : std_logic;
begin
  
  P_CTRL_FF : process (clk)
    variable sync_detected_v : std_logic;
    variable delay_assigned_v : std_logic;
  begin
    if clk'event and clk = '1' then
      if rst = '1' then
        sync_started_r <= (others => '0'); 
        output_delay_r <= (others => '0'); 
        output_delay_o <= (others => '0'); 
        delay_enable_r <= '0';
        error_o        <= '0';
      else
        sync_detected_v   := OR_REDUCE(sync_found_i); -- synchronization detected on some DMUX cells
        delay_assigned_v := OR_REDUCE(output_delay_r); -- Delay assigned for cells which had sync detected in earlier stages
        
        --! STAGE1 : Assign delay for DMUX cells which had detected sync in first stage
        if (sync_detected_v = '1') and (delay_assigned_v = '0') then
          output_delay_r <= sync_found_i;
        end if;
        
        --! STAGE2 : Enable output delays if mismatch detected
        if delay_assigned_v = '1' then
          delay_enable_r <= '1';
        end if;
        
        --! STAGE3 : ERROR - no more then one cycle misalignment allowed
        if (sync_detected_v = '1') and (delay_enable_r = '1') then
          error_o <= '1';
        end if;
        
        output_delay_o <= output_delay_r;

      end if;
    end if;
  end process P_CTRL_FF;

end architecture rtl;
