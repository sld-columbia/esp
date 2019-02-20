-----------------------------------------------------------------------------
--  Testbench for ESP on Xilinx VCU118
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.libdcom.all;
use work.sim.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;

use work.grlib_config.all;

entity testbench is
  generic (
    fabtech : integer := CFG_FABTECH;
    memtech : integer := CFG_MEMTECH;
    padtech : integer := CFG_PADTECH;
    disas   : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart : integer := CFG_DUART;     -- Print UART on console
    pclow   : integer := CFG_PCLOW;
    testahb : boolean := true
    );
end;

architecture behav of testbench is

  constant SIMULATION      : boolean := true;
  constant autonegotiation : integer := 1;

  constant promfile : string := "prom.srec";  -- rom contents
  constant ramfile  : string := "ram.srec";   -- ram contents

  component top is
    generic (
      fabtech         : integer;
      memtech         : integer;
      padtech         : integer;
      disas           : integer;
      dbguart         : integer;
      pclow           : integer;
      testahb         : boolean;
      SIMULATION      : boolean;
      autonegotiation : integer);
    port (
      reset            : in    std_ulogic;
      c0_sys_clk_p     : in    std_logic;
      c0_sys_clk_n     : in    std_logic;
      c0_ddr4_act_n    : out   std_logic;
      c0_ddr4_adr      : out   std_logic_vector(16 downto 0);
      c0_ddr4_ba       : out   std_logic_vector(1 downto 0);
      c0_ddr4_bg       : out   std_logic_vector(0 downto 0);
      c0_ddr4_cke      : out   std_logic_vector(0 downto 0);
      c0_ddr4_odt      : out   std_logic_vector(0 downto 0);
      c0_ddr4_cs_n     : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_t     : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_c     : out   std_logic_vector(0 downto 0);
      c0_ddr4_reset_n  : out   std_logic;
      c0_ddr4_dm_dbi_n : inout std_logic_vector(7 downto 0);
      c0_ddr4_dq       : inout std_logic_vector(63 downto 0);
      c0_ddr4_dqs_c    : inout std_logic_vector(7 downto 0);
      c0_ddr4_dqs_t    : inout std_logic_vector(7 downto 0);
      address          : out   std_logic_vector(25 downto 0);
      data             : inout std_logic_vector(15 downto 0);
      oen              : out   std_ulogic;
      writen           : out   std_ulogic;
      romsn            : out   std_logic;
      adv              : out   std_logic;
      gtrefclk_p       : in    std_logic;
      gtrefclk_n       : in    std_logic;
      txp              : out   std_logic;
      txn              : out   std_logic;
      rxp              : in    std_logic;
      rxn              : in    std_logic;
      emdio            : inout std_logic;
      emdc             : out   std_ulogic;
      eint             : in    std_ulogic;
      erst             : out   std_ulogic;
      uart_rxd         : in    std_ulogic;
      uart_txd         : out   std_ulogic;
      uart_ctsn        : in    std_ulogic;
      uart_rtsn        : out   std_ulogic;
      button           : in    std_logic_vector(3 downto 0);
      switch           : inout std_logic_vector(3 downto 0);
      led              : out   std_logic_vector(6 downto 0));
  end component top;

-- Bein TOP-level interface --

-- Reset and clock
  signal reset        : std_ulogic := '1';
  signal c0_sys_clk_p : std_logic  := '0';
  signal c0_sys_clk_n : std_logic  := '1';

-- DDR4
  signal c0_ddr4_act_n    : std_logic;
  signal c0_ddr4_adr      : std_logic_vector(16 downto 0);
  signal c0_ddr4_ba       : std_logic_vector(1 downto 0);
  signal c0_ddr4_bg       : std_logic_vector(0 downto 0);
  signal c0_ddr4_cke      : std_logic_vector(0 downto 0);
  signal c0_ddr4_odt      : std_logic_vector(0 downto 0);
  signal c0_ddr4_cs_n     : std_logic_vector(0 downto 0);
  signal c0_ddr4_ck_t     : std_logic_vector(0 downto 0);
  signal c0_ddr4_ck_c     : std_logic_vector(0 downto 0);
  signal c0_ddr4_reset_n  : std_logic;
  signal c0_ddr4_dm_dbi_n : std_logic_vector(7 downto 0);
  signal c0_ddr4_dq       : std_logic_vector(63 downto 0);
  signal c0_ddr4_dqs_c    : std_logic_vector(7 downto 0);
  signal c0_ddr4_dqs_t    : std_logic_vector(7 downto 0);

-- PROM (Simulation only for now)
  signal address : std_logic_vector(25 downto 0);
  signal data    : std_logic_vector(15 downto 0);
  signal oen     : std_ulogic;
  signal writen  : std_ulogic;
  signal romsn   : std_logic;
  signal adv     : std_logic;

-- SGMII Ethernet
  signal gtrefclk_p : std_logic := '0';
  signal gtrefclk_n : std_logic := '1';
  signal txp        : std_logic;
  signal txn        : std_logic;
  signal rxp        : std_logic;
  signal rxn        : std_logic;
  signal emdio      : std_logic;
  signal emdc       : std_ulogic;
  signal eint       : std_ulogic;
  signal erst       : std_ulogic;

-- UART
  signal uart_rxd  : std_ulogic;
  signal uart_txd  : std_ulogic;
  signal uart_ctsn : std_ulogic;
  signal uart_rtsn : std_ulogic;

-- GPIO
  signal button : std_logic_vector(3 downto 0);
  signal switch : std_logic_vector(3 downto 0);
  signal led    : std_logic_vector(6 downto 0);

-- End TOP-level interface --

begin

  -- clock and reset
  reset        <= '0'              after 2500 ns;
  c0_sys_clk_p <= not c0_sys_clk_p after 2 ns;
  c0_sys_clk_n <= not c0_sys_clk_n after 2 ns;

  -- DDR4 (memory simulation model does not emulate DDR behavior)
  c0_ddr4_dm_dbi_n <= (others => 'Z');
  c0_ddr4_dq       <= (others => 'Z');
  c0_ddr4_dqs_c    <= (others => 'Z');
  c0_ddr4_dqs_t    <= (others => 'Z');

  -- Simulation model of generic async SRAM from GRLIB. For now the PROM is present
  -- in simulation only. First-stage boot loader of FPGA is replaced by runtime
  -- configuration through debug unit. Supporting boot from SDCARD is on the
  -- TODO list.
  prom0 : for i in 0 to 1 generate
    sr0 : sram generic map (index => i+4, abits => 26, fname => promfile)
      port map (address(25 downto 0), data(15-i*8 downto 8-i*8), romsn,
                writen, oen);
  end generate;
  data <= buskeep(data) after 5 ns;

  -- Ethernet (We do not simulate any model of the PHY to speedup RTL simulation)
  gtrefclk_p <= not gtrefclk_p after 800 ps;
  gtrefclk_n <= not gtrefclk_n after 800 ps;
  rxp        <= '0';
  rxn        <= '1';
  emdio      <= 'H';
  eint       <= '0';

  -- UART
  uart_rxd  <= '0';
  uart_ctsn <= '0';

  -- Switches
  button <= (others => '0');
  switch <= (others => '0');

  cpu : top
    generic map (
      fabtech         => fabtech,
      memtech         => memtech,
      padtech         => padtech,
      disas           => disas,
      dbguart         => dbguart,
      pclow           => pclow,
      testahb         => testahb,
      SIMULATION      => SIMULATION,
      autonegotiation => autonegotiation)
    port map (
      reset            => reset,
      c0_sys_clk_p     => c0_sys_clk_p,
      c0_sys_clk_n     => c0_sys_clk_n,
      c0_ddr4_act_n    => c0_ddr4_act_n,
      c0_ddr4_adr      => c0_ddr4_adr,
      c0_ddr4_ba       => c0_ddr4_ba,
      c0_ddr4_bg       => c0_ddr4_bg,
      c0_ddr4_cke      => c0_ddr4_cke,
      c0_ddr4_odt      => c0_ddr4_odt,
      c0_ddr4_cs_n     => c0_ddr4_cs_n,
      c0_ddr4_ck_t     => c0_ddr4_ck_t,
      c0_ddr4_ck_c     => c0_ddr4_ck_c,
      c0_ddr4_reset_n  => c0_ddr4_reset_n,
      c0_ddr4_dm_dbi_n => c0_ddr4_dm_dbi_n,
      c0_ddr4_dq       => c0_ddr4_dq,
      c0_ddr4_dqs_c    => c0_ddr4_dqs_c,
      c0_ddr4_dqs_t    => c0_ddr4_dqs_t,
      address          => address,
      data             => data,
      oen              => oen,
      writen           => writen,
      romsn            => romsn,
      adv              => adv,
      gtrefclk_p       => gtrefclk_p,
      gtrefclk_n       => gtrefclk_n,
      txp              => txp,
      txn              => txn,
      rxp              => rxp,
      rxn              => rxn,
      emdio            => emdio,
      emdc             => emdc,
      eint             => eint,
      erst             => erst,
      uart_rxd         => uart_rxd,
      uart_txd         => uart_txd,
      uart_ctsn        => uart_ctsn,
      uart_rtsn        => uart_rtsn,
      button           => button,
      switch           => switch,
      led              => led);


end;
