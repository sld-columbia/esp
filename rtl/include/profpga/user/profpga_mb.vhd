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
--!  @file         profpga_mb.vhd
--!  @author       Sebastian Fluegel
--!  @email        sebastian.fluegel@prodesign-europe.com
--!  @brief        proFPGA mainboard simulation model.
-- =============================================================================


--! TODO: check port naming mmi64_p_muxdemux since regular mmi64 naming scheme breaks on bidirectional modules. Also check if this is called a phy since bridge seams to be more appropriate!

package profpga_mb_pkg is

  -- number of master beats on mainboard (clock and associated sync)
  constant MASTER_BEAT_COUNT : natural := 8;

  -- number of external clocks
  constant EXT_CLOCK_COUNT : natural := 4;

  -- number of source clocks per fpga module (clock and associated sync)
  constant SRC_CLOCK_COUNT : natural := 4;

  -- bit width of DMBI bus transferring MMI64 domain signals between fpga module and mainboard
  constant DMBI_BUS_WIDTH : natural := 20;

end profpga_mb_pkg;

--

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.profpga_mb_pkg.all;

entity profpga_mb is
  generic (
    DMBI_TRAINING_SPEED  : string := "fast"; -- Pin training speed: "real"=real calibration, "fast"=fast simulation
    MB_IS_MASTER : boolean := true
    );
  port (
    -- external clock/sync inputs
    ext_clk  : in std_ulogic_vector(EXT_CLOCK_COUNT-1 downto 0) := (others => '0');
    ext_sync : in std_ulogic_vector(EXT_CLOCK_COUNT-1 downto 0) := (others => '0');

    -- master beats
    clk_p  : out std_ulogic_vector(MASTER_BEAT_COUNT-1 downto 0);
    clk_n  : out std_ulogic_vector(MASTER_BEAT_COUNT-1 downto 0);
    sync_p : out std_ulogic_vector(MASTER_BEAT_COUNT-1 downto 0);
    sync_n : out std_ulogic_vector(MASTER_BEAT_COUNT-1 downto 0);

    -- communication with user FPGA at site A1
    ta1_dmbi_h2f  : out std_ulogic_vector(DMBI_BUS_WIDTH-1 downto 0);  -- @TODO: add symbolic mappings for these signals
    ta1_dmbi_f2h  : in  std_ulogic_vector(DMBI_BUS_WIDTH-1 downto 0)  := (others => '0');  -- @TODO: add symbolic mappings for these signals
    ta1_srcclk_p  : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '0');
    ta1_srcclk_n  : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '1');
    ta1_srcsync_p : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '0');
    ta1_srcsync_n : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '1');

    -- communication with user FPGA at site C1
    tc1_dmbi_h2f  : out std_ulogic_vector(DMBI_BUS_WIDTH-1 downto 0);
    tc1_dmbi_f2h  : in  std_ulogic_vector(DMBI_BUS_WIDTH-1 downto 0)  := (others => '0');
    tc1_srcclk_p  : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '0');
    tc1_srcclk_n  : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '1');
    tc1_srcsync_p : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '0');
    tc1_srcsync_n : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '1');

    -- communication with user FPGA at site A3
    ta3_dmbi_h2f  : out std_ulogic_vector(DMBI_BUS_WIDTH-1 downto 0);
    ta3_dmbi_f2h  : in  std_ulogic_vector(DMBI_BUS_WIDTH-1 downto 0)  := (others => '0');
    ta3_srcclk_p  : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '0');
    ta3_srcclk_n  : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '1');
    ta3_srcsync_p : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '0');
    ta3_srcsync_n : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '1');

    -- communication with user FPGA at site C3
    tc3_dmbi_h2f  : out std_ulogic_vector(DMBI_BUS_WIDTH-1 downto 0);
    tc3_dmbi_f2h  : in  std_ulogic_vector(DMBI_BUS_WIDTH-1 downto 0)  := (others => '0');
    tc3_srcclk_p  : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '0');
    tc3_srcclk_n  : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '1');
    tc3_srcsync_p : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '0');
    tc3_srcsync_n : in  std_ulogic_vector(SRC_CLOCK_COUNT-1 downto 0) := (others => '1');

    -- communication with next motherboard (if present)
    nmb_dn : out std_ulogic_vector(84 downto 0) := (others => '0');  -- 8 clk, 8 sync, 64 data, 5 ctrl (valid, first, last, ack, present)
    nmb_up : in  std_ulogic_vector(84 downto 0) := (others => '0');

    -- communication with previous motherboard (only if this is not the master motherboard)
    pmb_up : out std_ulogic_vector(84 downto 0) := (others => '0');
    pmb_dn : in  std_ulogic_vector(84 downto 0) := (others => '0')
    );
end entity profpga_mb;

--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mmi64_pkg.all;
use work.mmi64_router_comp.all;
use work.mmi64_m_regif_comp.all;
use work.mmi64_m_devzero_comp.all;
use work.mmi64_p_pli_comp.all;
use work.mmi64_p_muxdemux_comp.all;
use work.profpga_pkg.all;

architecture beh of profpga_mb is

  function Log2(constant W : integer) return integer is
  begin
    for i in 0 to 31 loop
      if 2**i >= W then return i; end if;
    end loop;
    return 32;
  end function Log2;

  -- hardware and software revisions
  constant FIRMWARE_REVISION     : integer                        := 0;
  constant PCB_REVISION          : integer                        := 0;
  constant FIRMWARE_REVISION_VEC : std_ulogic_vector(31 downto 0) := std_ulogic_vector(to_signed(FIRMWARE_REVISION, 32));
  constant PCB_REVISION_VEC      : std_ulogic_vector(3 downto 0)  := std_ulogic_vector(to_signed(PCB_REVISION, 4));

  -- port assignment of mmi64 router for this mainboard
  constant MMI64_MODULE_IDX_NEXT_MB      : integer :=  0;  --! mmi64 downstream connection to next mainboard
  constant MMI64_MODULE_IDX_USERMMI64_A1 : integer :=  1;  --! mmi64 user connection to fpga module at site A1
  constant MMI64_MODULE_IDX_USERMMI64_A3 : integer :=  2;  --! mmi64 user connection to fpga module at site A3
  constant MMI64_MODULE_IDX_USERMMI64_C1 : integer :=  3;  --! mmi64 user connection to fpga module at site C1
  constant MMI64_MODULE_IDX_USERMMI64_C3 : integer :=  4;  --! mmi64 user connection to fpga module at site C3
  constant MMI64_MODULE_IDX_SELECTMAP_A1 : integer :=  5;  --! mmi64 connection to select map programmer for fpga module at site A1
  constant MMI64_MODULE_IDX_SELECTMAP_A3 : integer :=  6;  --! mmi64 connection to select map programmer for fpga module at site A3
  constant MMI64_MODULE_IDX_SELECTMAP_C1 : integer :=  7;  --! mmi64 connection to select map programmer for fpga module at site C1
  constant MMI64_MODULE_IDX_SELECTMAP_C3 : integer :=  8;  --! mmi64 connection to select map programmer for fpga module at site C3
  constant MMI64_MODULE_IDX_CTRL_REGIF   : integer :=  9;  --! mmi64 connection to motherboards configuration and control register file
  constant MMI64_MODULE_IDX_CLK01        : integer := 10;  --! mmi64 connection to register file in clock fpga #01
  constant MMI64_MODULE_IDX_CLK23        : integer := 11;  --! mmi64 connection to register file in clock fpga #23
  constant MMI64_MODULE_IDX_CLK45        : integer := 12;  --! mmi64 connection to register file in clock fpga #45
  constant MMI64_MODULE_IDX_CLK67        : integer := 13;  --! mmi64 connection to register file in clock fpga #67
  constant MMI64_MODULE_IDX_MBOX         : integer := 14;  --! mmi64 connection to ARM communication module (message box)
  constant MMI64_MODULE_IDX_DEVZERO      : integer := 15;  --! mmi64 connection to ARM communication module (message box)
  constant MMI64_MODULE_COUNT            : integer := 16;  --! number of defined mmi64 modules

  -- register map for main boards control and clock register files

  constant REGIF_CLKGEN_ADDRESS      : integer :=  0;
  constant REGIF_CLKGEN_MASK         : integer :=  1;
  constant REGIF_CLKGEN_COMMAND      : integer :=  2;
  constant REGIF_CLKGEN_RESERVED     : integer :=  3;
  constant REGIF_CTRL_CLKFPGA_PROGB  : integer :=  4;
  constant REGIF_CTRL_CLKFPGA_DONE   : integer :=  5;
  constant REGIF_CTRL_EMERG_SHUTDOWN : integer :=  6;
  constant REGIF_CTRL_STATUS_LED     : integer :=  7;
  constant REGIF_CTRL_PSU_STATUS     : integer :=  8;
  constant REGIF_CTRL_COMM_RST       : integer :=  9;
  constant REGIF_CTRL_RESET          : integer := 10;
  constant REGIF_CTRL_REVISION_LO    : integer := 11;
  constant REGIF_CTRL_REVISION_HI    : integer := 12;
  constant REGIF_CTRL_CFG_MMI_MUX    : integer := 13;
  constant REGIF_CTRL_PCB_REVISION   : integer := 14;
  constant REGIF_EXTCLK_MEASURE      : integer := 15;
  constant REGIF_EXTCLK0_COUNT       : integer := 16;
  constant REGIF_EXTCLK1_COUNT       : integer := 17;
  constant REGIF_EXTCLK2_COUNT       : integer := 18;
  constant REGIF_EXTCLK3_COUNT       : integer := 19;
  constant REGIF_UPTIME_LO           : integer := 20;
  constant REGIF_UPTIME_HI           : integer := 21;
  constant REGIF_RESERVED22          : integer := 22;
  constant REGIF_RESERVED23          : integer := 23;
  constant REGIF_CTRL_REGS_HI        : integer := 23;
  constant REGIF_CTRL_SYNC_LO        : integer := 24;
  constant REGIF_CTRL_SYNC_HI        : integer := REGIF_CTRL_SYNC_LO+2*8-1;

  constant CTRL_REGISTER_COUNT : integer := REGIF_CTRL_SYNC_HI+1;

  -- register map of clock fpga #01
  constant REGIF_CLK01_REVISION_LO : integer := 0;
  constant REGIF_CLK01_REVISION_HI : integer := 1;
  constant REGIF_CLK01_CLK0_SEL    : integer := 2;
  constant REGIF_CLK01_CLK1_SEL    : integer := 3;
  constant REGIF_CLK01_CLK2_SEL    : integer := 4;
  constant REGIF_CLK01_CLK3_SEL    : integer := 5;
  constant REGIF_CLK01_CLK4_SEL    : integer := 6;
  constant REGIF_CLK01_CLK5_SEL    : integer := 7;
  constant REGIF_CLK01_CLK6_SEL    : integer := 8;
  constant REGIF_CLK01_CLK7_SEL    : integer := 9;
  constant REGIF_CLK01_PRESENT     : integer := 10;

  constant CLK01_REGISTER_COUNT : integer := 11;

  -- register map of clock fpga #23
  constant REGIF_CLK23_REVISION_LO : integer := 0;
  constant REGIF_CLK23_REVISION_HI : integer := 1;
  constant REGIF_CLK23_SYNC0_SEL   : integer := 2;
  constant REGIF_CLK23_SYNC1_SEL   : integer := 3;
  constant REGIF_CLK23_SYNC2_SEL   : integer := 4;
  constant REGIF_CLK23_SYNC3_SEL   : integer := 5;
  constant REGIF_CLK23_SYNC4_SEL   : integer := 6;
  constant REGIF_CLK23_SYNC5_SEL   : integer := 7;
  constant REGIF_CLK23_SYNC6_SEL   : integer := 8;
  constant REGIF_CLK23_SYNC7_SEL   : integer := 9;
  constant REGIF_CLK23_PSU_A1_RUN  : integer := 10;
  constant REGIF_CLK23_PSU_C1_RUN  : integer := 11;
  constant REGIF_CLK23_PSU_A3_RUN  : integer := 12;
  constant REGIF_CLK23_PSU_C3_RUN  : integer := 13;
  constant REGIF_CLK23_PRESENT     : integer := 14;

  constant CLK23_REGISTER_COUNT : integer := 15;

  -- register map of clock fpga #45
  constant REGIF_CLK45_REVISION_LO  : integer := 0;
  constant REGIF_CLK45_REVISION_HI  : integer := 1;
  constant REGIF_CLK45_SRCCLK0_SEL  : integer := 2;
  constant REGIF_CLK45_SRCCLK1_SEL  : integer := 3;
  constant REGIF_CLK45_SRCCLK2_SEL  : integer := 4;
  constant REGIF_CLK45_SRCCLK3_SEL  : integer := 5;
  constant REGIF_CLK45_SRCCLK4_SEL  : integer := 6;
  constant REGIF_CLK45_SRCCLK5_SEL  : integer := 7;
  constant REGIF_CLK45_SRCCLK6_SEL  : integer := 8;
  constant REGIF_CLK45_SRCCLK7_SEL  : integer := 9;
  constant REGIF_CLK45_SRCSYNC0_SEL : integer := 10;
  constant REGIF_CLK45_SRCSYNC1_SEL : integer := 11;
  constant REGIF_CLK45_SRCSYNC2_SEL : integer := 12;
  constant REGIF_CLK45_SRCSYNC3_SEL : integer := 13;
  constant REGIF_CLK45_SRCSYNC4_SEL : integer := 14;
  constant REGIF_CLK45_SRCSYNC5_SEL : integer := 15;
  constant REGIF_CLK45_SRCSYNC6_SEL : integer := 16;
  constant REGIF_CLK45_SRCSYNC7_SEL : integer := 17;
  constant REGIF_CLK45_PCIE_PSUGOOD : integer := 18;

  constant CLK45_REGISTER_COUNT : integer := 19;

  -- register map of clock fpga #67
  constant REGIF_CLK67_REVISION_LO : integer := 0;
  constant REGIF_CLK67_REVISION_HI : integer := 1;

  constant CLK67_REGISTER_COUNT : integer := 2;

  -- pin mapping between motherboards
  subtype  MB2MB_CLK_RANGE is natural range 7 downto 0;
  subtype  MB2MB_SYNC_RANGE is natural range 15 downto 8;
  subtype  MB2MB_MMI64_DATA_RANGE is natural range 79 downto 16;
  constant MB2MB_MMI64_VALID_IDX  : integer := 80;
  constant MB2MB_MMI64_START_IDX  : integer := 81;
  constant MB2MB_MMI64_STOP_IDX   : integer := 82;
  constant MB2MB_MMI64_ACCEPT_IDX : integer := 83;
  constant MB2MB_MB_PRESENT_IDX   : integer := 84;

  -- clock periods for external clock inputs
  constant CLKPERIOD_60MHz  : time := 1 us / 60.0;
  constant CLKPERIOD_18MHz  : time := 1 us / 18.432;
  constant CLKPERIOD_125MHz : time := 1 us / 125.0;
  constant CLKPERIOD_MMI64  : time := 1 us / 100.0;
  constant CLKPERIOD_DMBI   : time := 1 us / 200.0;

  component mb_clock_generator is
    port (
      -- configuration clock and reset
      cfg_clk : in std_ulogic;
      cfg_rst : in std_ulogic;

      -- reference clock inputs
      refclk_125MHz_i : in std_ulogic;
      refclk_60MHz_i  : in std_ulogic;
      refclk_18MHz_i  : in std_ulogic;
      refclk_ext_i    : in std_ulogic_vector(3 downto 0);

      -- synthesized clock outputs
      srcclk_o : out std_ulogic_vector(7 downto 1);
      locked_o : out std_ulogic_vector(7 downto 1);

      -- configuration register file interface
      reg_we_i     : in  std_ulogic;
      reg_ce_i     : in  std_ulogic;
      reg_addr_i   : in  std_ulogic_vector(1 downto 0);
      reg_wdata_i  : in  std_ulogic_vector(15 downto 0);
      reg_accept_o : out std_ulogic;
      reg_rdata_o  : out std_ulogic_vector(15 downto 0);
      reg_rvalid_o : out std_ulogic
      );
  end component mb_clock_generator;

  -- external clock inputs
  signal clk_60mhz     : std_ulogic := '1';
  signal clk_18_432mhz : std_ulogic := '1';
  signal clk_125mhz    : std_ulogic := '1';

  -- clocks and sync from previous and next mainboard
  signal clk_from_pmb  : std_ulogic_vector(7 downto 0);
  signal sync_from_pmb : std_ulogic_vector(7 downto 0);
  signal clk_from_nmb  : std_ulogic_vector(7 downto 0);
  signal sync_from_nmb : std_ulogic_vector(7 downto 0);

  -- main clock signals on motherboard
  signal clk  : std_ulogic_vector(7 downto 0);
  signal sync : std_ulogic_vector(7 downto 0);

  -- mmi64 domain clock and reset
  signal mmi64_clk   : std_ulogic := '1';
  signal mmi64_reset : std_ulogic;

  -- clock used for pin multiplexing of mmi64 domain over dmbi pins
  signal dmbi_clk     : std_ulogic := '1';
  signal dmbi_clk_x4  : std_ulogic := '1';

  -- mmi64 signals connected to the PLI host
  signal mmi64_pli_host_up_d      : mmi64_data_t := (others => '0');
  signal mmi64_pli_host_up_valid  : std_ulogic   := '0';
  signal mmi64_pli_host_up_accept : std_ulogic   := '0';
  signal mmi64_pli_host_up_start  : std_ulogic   := '0';
  signal mmi64_pli_host_up_stop   : std_ulogic   := '0';
  signal mmi64_pli_host_dn_d      : mmi64_data_t := (others => '0');
  signal mmi64_pli_host_dn_valid  : std_ulogic   := '0';
  signal mmi64_pli_host_dn_accept : std_ulogic   := '0';
  signal mmi64_pli_host_dn_start  : std_ulogic   := '0';
  signal mmi64_pli_host_dn_stop   : std_ulogic   := '0';

  -- main controller signals (either PLI host or prev MB)
  signal main_up_d      : mmi64_data_t := (others => '0');
  signal main_up_valid  : std_ulogic   := '0';
  signal main_up_accept : std_ulogic   := '0';
  signal main_up_start  : std_ulogic   := '0';
  signal main_up_stop   : std_ulogic   := '0';
  signal main_dn_d      : mmi64_data_t := (others => '0');
  signal main_dn_valid  : std_ulogic   := '0';
  signal main_dn_accept : std_ulogic   := '0';
  signal main_dn_start  : std_ulogic   := '0';
  signal main_dn_stop   : std_ulogic   := '0';

  -- mmi64 connections from mainboard mmi64 router to mmi64 modules
  signal mmi64_mbrouter_m_present   : std_ulogic_vector(0 to MMI64_MODULE_COUNT-1)   := (others => '0');
  signal mmi64_mbrouter_m_up_d      : mmi64_data_vector_t(0 to MMI64_MODULE_COUNT-1) := (others => (others => '0'));
  signal mmi64_mbrouter_m_up_valid  : std_ulogic_vector(0 to MMI64_MODULE_COUNT-1)   := (others => '0');
  signal mmi64_mbrouter_m_up_accept : std_ulogic_vector(0 to MMI64_MODULE_COUNT-1)   := (others => '0');
  signal mmi64_mbrouter_m_up_start  : std_ulogic_vector(0 to MMI64_MODULE_COUNT-1)   := (others => '0');
  signal mmi64_mbrouter_m_up_stop   : std_ulogic_vector(0 to MMI64_MODULE_COUNT-1)   := (others => '0');
  signal mmi64_mbrouter_m_dn_d      : mmi64_data_vector_t(0 to MMI64_MODULE_COUNT-1) := (others => (others => '0'));
  signal mmi64_mbrouter_m_dn_valid  : std_ulogic_vector(0 to MMI64_MODULE_COUNT-1)   := (others => '0');
  signal mmi64_mbrouter_m_dn_accept : std_ulogic_vector(0 to MMI64_MODULE_COUNT-1)   := (others => '0');
  signal mmi64_mbrouter_m_dn_start  : std_ulogic_vector(0 to MMI64_MODULE_COUNT-1)   := (others => '0');
  signal mmi64_mbrouter_m_dn_stop   : std_ulogic_vector(0 to MMI64_MODULE_COUNT-1)   := (others => '0');

  -- control register interface
  signal ctrl_regfile_en     : std_ulogic;
  signal ctrl_regfile_we     : std_ulogic;
  signal ctrl_regfile_addr   : std_ulogic_vector(log2(CTRL_REGISTER_COUNT)-1 downto 0);
  signal ctrl_regfile_wdata  : std_ulogic_vector(15 downto 0);
  signal ctrl_regfile_accept : std_ulogic;
  signal ctrl_regfile_rdata  : std_ulogic_vector(15 downto 0);
  signal ctrl_regfile_rvalid : std_ulogic;

  -- clk01 register interface
  signal clk01_regfile_en     : std_ulogic;
  signal clk01_regfile_we     : std_ulogic;
  signal clk01_regfile_addr   : std_ulogic_vector(log2(CLK01_REGISTER_COUNT)-1 downto 0);
  signal clk01_regfile_wdata  : std_ulogic_vector(15 downto 0);
  signal clk01_regfile_accept : std_ulogic;
  signal clk01_regfile_rdata  : std_ulogic_vector(15 downto 0);
  signal clk01_regfile_rvalid : std_ulogic;

  -- clk23 register interface
  signal clk23_regfile_en     : std_ulogic;
  signal clk23_regfile_we     : std_ulogic;
  signal clk23_regfile_addr   : std_ulogic_vector(log2(CLK23_REGISTER_COUNT)-1 downto 0);
  signal clk23_regfile_wdata  : std_ulogic_vector(15 downto 0);
  signal clk23_regfile_accept : std_ulogic;
  signal clk23_regfile_rdata  : std_ulogic_vector(15 downto 0);
  signal clk23_regfile_rvalid : std_ulogic;

  -- clk45 register interface
  signal clk45_regfile_en     : std_ulogic;
  signal clk45_regfile_we     : std_ulogic;
  signal clk45_regfile_addr   : std_ulogic_vector(log2(CLK45_REGISTER_COUNT)-1 downto 0);
  signal clk45_regfile_wdata  : std_ulogic_vector(15 downto 0);
  signal clk45_regfile_accept : std_ulogic;
  signal clk45_regfile_rdata  : std_ulogic_vector(15 downto 0);
  signal clk45_regfile_rvalid : std_ulogic;

  -- clk67 register interface
  signal clk67_regfile_en     : std_ulogic;
  signal clk67_regfile_we     : std_ulogic;
  signal clk67_regfile_addr   : std_ulogic_vector(log2(CLK67_REGISTER_COUNT)-1 downto 0);
  signal clk67_regfile_wdata  : std_ulogic_vector(15 downto 0);
  signal clk67_regfile_accept : std_ulogic;
  signal clk67_regfile_rdata  : std_ulogic_vector(15 downto 0);
  signal clk67_regfile_rvalid : std_ulogic;

  --
  -- signals connected to ctrl register interface
  --

  --  main clock generator
  signal clkgen_clk        : std_ulogic_vector(7 downto 0);
  signal clkgen_locked     : std_ulogic_vector(7 downto 0);
  signal regfile_clkgen_ce : std_ulogic;
  signal clkgen_accept     : std_ulogic;
  signal clkgen_rdata      : std_ulogic_vector(15 downto 0);
  signal clkgen_rvalid     : std_ulogic;

  signal clkgen_sync : std_ulogic_vector(7 downto 0);

  -- main register interface
  signal regif_ce       : std_ulogic;
  signal regif_accept_r : std_ulogic;
  signal regif_rdata_r  : std_ulogic_vector(15 downto 0);
  signal regif_rvalid_r : std_ulogic;

  -- control registers
  signal ctrl_cfg_mmi_mux_r    : std_ulogic_vector(MMI64_MODULE_IDX_USERMMI64_C3 downto MMI64_MODULE_IDX_USERMMI64_A1);
  signal ctrl_clkfpga_progb_r  : std_ulogic_vector(3 downto 0);
  signal ctrl_comm_rst_r       : std_ulogic;
  signal ctrl_emerg_shutdown_r : std_ulogic;
  signal ctrl_status_led_r     : std_ulogic_vector(3 downto 0);
  
  signal ta1_muxdemux_reset     : std_ulogic;
  signal ta3_muxdemux_reset     : std_ulogic;
  signal tc1_muxdemux_reset     : std_ulogic;
  signal tc3_muxdemux_reset     : std_ulogic;

  --
  -- clock synchronization stuff
  --

  type sync_cmd_t is record
    event_id    : std_ulogic_vector(7 downto 0);
    event_en    : std_ulogic;
    event_pause : std_ulogic_vector(15 downto 0);
    strobe1_sel : std_ulogic_vector(1 downto 0);
    strobe2_sel : std_ulogic_vector(1 downto 0);
  end record;

  constant SYNC_CMD_INIT : sync_cmd_t := (
    event_id    => x"00",
    event_en    => '0',
    event_pause => x"0000",
    strobe1_sel => "00",
    strobe2_sel => "00"
    );

  type   sync_cmd_vector is array(natural range <>) of sync_cmd_t;
  type   sync_rst_vector is array(natural range <>) of std_ulogic_vector(1 downto 0);

  -- sync registers (connected to control register file)
  signal sync_cmd_r          : sync_cmd_vector(7 downto 0) := (others => SYNC_CMD_INIT);  -- mmi64 clock domain
  signal sync_cmd_rEXT       : sync_cmd_vector(7 downto 0) := (others => SYNC_CMD_INIT);  -- external clock domain
  signal sync_event_busy_EXT : std_ulogic_vector(7 downto 0);
  signal sync_strobe1_EXT    : std_ulogic_vector(7 downto 0);
  signal sync_strobe2_EXT    : std_ulogic_vector(7 downto 0);

  signal sync_rst_rEXT           : sync_rst_vector(7 downto 0);
  signal sync_event_en_META_rEXT : std_ulogic_vector(7 downto 0);  -- handshake mmi64 to ext clock domain
  signal sync_event_done_rEXT    : std_ulogic_vector(7 downto 0);  -- handshake EXT to mmi64 clock domain
  signal sync_event_done_rMMI    : std_ulogic_vector(7 downto 0);  -- handshake EXT to mmi64 clock domain

  -- handshake order over clock domains:
  --     1. sync_cmd_r(i).event_en     <= '1';
  --     2. sync_event_en_META_rEXT(i) <= '1';
  --     3. sync_cmd_rEXT(i).event_en  <= '1';
  --     4. sync_event_done_rEXT(i)    <= '1'; --> after sync_busy(i)='0'
  --        sync_cmd_rEXT(i).event_en  <= '0';
  --     5. sync_event_done_rMMI(i)    <= '1';
  --     6. sync_cmd_r(i).sync_event_done_rMMI     <= '0';
  --     7. sync_event_en_META_rEXT(i) <= '0';
  --     8. sync_event_done_rEXT(i)    <= '0';
  --     9. sync_event_done_rMMI(i)    <= '0';
  --  not accepting MMI command while sync_cmd_r(i).event_en='1' or sync_event_done_rMMI(i)='1'


--
-- clock fpga registers
--

  -- clk01 registers
  signal clk01_clk0_sel_r : std_ulogic_vector(1 downto 0);
  signal clk01_clk1_sel_r : std_ulogic_vector(1 downto 0);
  signal clk01_clk2_sel_r : std_ulogic_vector(1 downto 0);
  signal clk01_clk3_sel_r : std_ulogic_vector(1 downto 0);
  signal clk01_clk4_sel_r : std_ulogic_vector(1 downto 0);
  signal clk01_clk5_sel_r : std_ulogic_vector(1 downto 0);
  signal clk01_clk6_sel_r : std_ulogic_vector(1 downto 0);
  signal clk01_clk7_sel_r : std_ulogic_vector(1 downto 0);

  -- clk23 registers
  signal clk23_sync0_sel_r  : std_ulogic_vector(1 downto 0);
  signal clk23_sync1_sel_r  : std_ulogic_vector(1 downto 0);
  signal clk23_sync2_sel_r  : std_ulogic_vector(1 downto 0);
  signal clk23_sync3_sel_r  : std_ulogic_vector(1 downto 0);
  signal clk23_sync4_sel_r  : std_ulogic_vector(1 downto 0);
  signal clk23_sync5_sel_r  : std_ulogic_vector(1 downto 0);
  signal clk23_sync6_sel_r  : std_ulogic_vector(1 downto 0);
  signal clk23_sync7_sel_r  : std_ulogic_vector(1 downto 0);
  signal clk23_psu_a1_run_r : std_ulogic;
  signal clk23_psu_c1_run_r : std_ulogic;
  signal clk23_psu_a3_run_r : std_ulogic;
  signal clk23_psu_c3_run_r : std_ulogic;

  -- clk45 registers
  signal clk45_pcie_psugood_r : std_ulogic_vector(4 downto 0);
  signal clk45_srcclk0_sel_r  : std_ulogic;
  signal clk45_srcclk1_sel_r  : std_ulogic;
  signal clk45_srcclk2_sel_r  : std_ulogic;
  signal clk45_srcclk3_sel_r  : std_ulogic;
  signal clk45_srcclk4_sel_r  : std_ulogic;
  signal clk45_srcclk5_sel_r  : std_ulogic;
  signal clk45_srcclk6_sel_r  : std_ulogic;
  signal clk45_srcclk7_sel_r  : std_ulogic;
  signal clk45_srcsync0_sel_r : std_ulogic;
  signal clk45_srcsync1_sel_r : std_ulogic;
  signal clk45_srcsync2_sel_r : std_ulogic;
  signal clk45_srcsync3_sel_r : std_ulogic;
  signal clk45_srcsync4_sel_r : std_ulogic;
  signal clk45_srcsync5_sel_r : std_ulogic;
  signal clk45_srcsync6_sel_r : std_ulogic;
  signal clk45_srcsync7_sel_r : std_ulogic;

  function ClkMux(signal clksel : std_ulogic_vector(1 downto 0); signal usersel : std_ulogic; signal user0, user1, gen, pmb, nmb : std_ulogic) return std_ulogic is
    variable sel : std_ulogic;
  begin
    case clksel is
      when "00"   => sel := pmb;
      when "01"   => sel := nmb;
      when "10"   => sel := gen;
      when others =>
        if usersel = '0' then
          sel := user0;
        else
          sel := user1;
        end if;
    end case;

    return sel;
  end function ClkMux;

begin

  --
  -- clock and reset generation
  --

  -- all local clocks signals
  clk_60mhz       <= not clk_60mhz        after CLKPERIOD_60MHz/2;
  clk_18_432mhz   <= not clk_18_432mhz    after CLKPERIOD_18MHz/2;
  clk_125mhz      <= not clk_125mhz       after CLKPERIOD_125MHz/2;
  mmi64_clk       <= not mmi64_clk        after CLKPERIOD_MMI64/2;
  dmbi_clk        <= not dmbi_clk         after (CLKPERIOD_DMBI/2)*4;
  dmbi_clk_x4     <= not dmbi_clk_x4      after CLKPERIOD_DMBI/2;

  clk_p <= clk;
  clk_n <= not clk;

  -- local sync signals
  sync_p <= sync;
  sync_n <= not sync;

  -- clock and sync from previous mainboard
  clk_from_pmb  <= pmb_dn(MB2MB_CLK_RANGE);
  sync_from_pmb <= pmb_dn(MB2MB_SYNC_RANGE);

  -- clock and sync from next mainboard
  clk_from_nmb  <= nmb_up(MB2MB_CLK_RANGE);
  sync_from_nmb <= nmb_up(MB2MB_SYNC_RANGE);

  -- reset generation
  p_reset : process
  begin
    --mmi64_reset <= '1', '0' after 50.4*CLKPERIOD_MMI64;
    mmi64_reset <= '1', '0' after 150.4*CLKPERIOD_MMI64;
    wait;
  end process p_reset;

  --
  -- mmi64 infrastructure of this mainboard
  --

  -- instanciate local PLI host if this mainboard is the master
  g_host_pli : if MB_IS_MASTER generate
    u_host_mmi64_p_pli : mmi64_p_pli
      port map (
        mmi64_clk   => mmi64_clk,
        mmi64_reset => mmi64_reset,

        mmi64_m_up_d_i      => mmi64_pli_host_up_d,
        mmi64_m_up_valid_i  => mmi64_pli_host_up_valid,
        mmi64_m_up_accept_o => mmi64_pli_host_up_accept,
        mmi64_m_up_start_i  => mmi64_pli_host_up_start,
        mmi64_m_up_stop_i   => mmi64_pli_host_up_stop,

        mmi64_m_dn_d_o      => mmi64_pli_host_dn_d,
        mmi64_m_dn_valid_o  => mmi64_pli_host_dn_valid,
        mmi64_m_dn_accept_i => mmi64_pli_host_dn_accept,
        mmi64_m_dn_start_o  => mmi64_pli_host_dn_start,
        mmi64_m_dn_stop_o   => mmi64_pli_host_dn_stop
        );
  end generate;

  -- check if no prev MB is connected in master mode
  assert now = 0 ns or (MB_IS_MASTER = true and pmb_dn(MB2MB_MB_PRESENT_IDX) = '0')
    report "Master MB must not have previous MB. Please check your testbench."
    severity failure;

  -- check if prev MB is connected correctly in slave mode
  assert now = 0 ns or (MB_IS_MASTER = false and pmb_dn(MB2MB_MB_PRESENT_IDX) = '1')
    report "Slave MB must have previous MB. Please check your testbench."
    severity failure;

  -- assign output signals to prev MB
  pmb_up(MB2MB_CLK_RANGE)        <= clk;
  pmb_up(MB2MB_SYNC_RANGE)       <= sync;
  pmb_up(MB2MB_MMI64_DATA_RANGE) <= main_up_d;
  pmb_up(MB2MB_MMI64_VALID_IDX)  <= main_up_valid;
  pmb_up(MB2MB_MMI64_START_IDX)  <= main_up_start;
  pmb_up(MB2MB_MMI64_STOP_IDX)   <= main_up_stop;
  pmb_up(MB2MB_MMI64_ACCEPT_IDX) <= main_dn_accept;
  pmb_up(MB2MB_MB_PRESENT_IDX)   <= '0' when MB_IS_MASTER else '1';

  -- assign signals to host
  mmi64_pli_host_up_d      <= main_up_d;
  mmi64_pli_host_up_valid  <= main_up_valid;
  mmi64_pli_host_up_start  <= main_up_start;
  mmi64_pli_host_up_stop   <= main_up_stop;
  mmi64_pli_host_dn_accept <= main_dn_accept;

  -- select between local host and prev MB
  main_dn_d      <= mmi64_pli_host_dn_d      when MB_IS_MASTER else pmb_dn(MB2MB_MMI64_DATA_RANGE);
  main_dn_valid  <= mmi64_pli_host_dn_valid  when MB_IS_MASTER else pmb_dn(MB2MB_MMI64_VALID_IDX);
  main_dn_start  <= mmi64_pli_host_dn_start  when MB_IS_MASTER else pmb_dn(MB2MB_MMI64_START_IDX);
  main_dn_stop   <= mmi64_pli_host_dn_stop   when MB_IS_MASTER else pmb_dn(MB2MB_MMI64_STOP_IDX);
  main_up_accept <= mmi64_pli_host_up_accept when MB_IS_MASTER else pmb_dn(MB2MB_MMI64_ACCEPT_IDX);

  -- the router for this motherboard
  u_mmi64_mb_router : mmi64_router
    generic map (
      MODULE_ID  => X"800000FF",
      PORT_COUNT => MMI64_MODULE_COUNT
      ) port map (
        -- clock and reset
        mmi64_clk          => mmi64_clk,
        mmi64_reset        => mmi64_reset,
        mmi64_initialize_o => open,

        -- connections to mmi64 phy or upstream router
        mmi64_h_up_d_o      => main_up_d,
        mmi64_h_up_valid_o  => main_up_valid,
        mmi64_h_up_accept_i => main_up_accept,
        mmi64_h_up_start_o  => main_up_start,
        mmi64_h_up_stop_o   => main_up_stop,

        mmi64_h_dn_d_i      => main_dn_d,
        mmi64_h_dn_valid_i  => main_dn_valid,
        mmi64_h_dn_accept_o => main_dn_accept,
        mmi64_h_dn_start_i  => main_dn_start,
        mmi64_h_dn_stop_i   => main_dn_stop,

        -- connections to mmi64 modules or downstream router
        mmi64_m_up_d_i      => mmi64_mbrouter_m_up_d,
        mmi64_m_up_valid_i  => mmi64_mbrouter_m_up_valid,
        mmi64_m_up_accept_o => mmi64_mbrouter_m_up_accept,
        mmi64_m_up_start_i  => mmi64_mbrouter_m_up_start,
        mmi64_m_up_stop_i   => mmi64_mbrouter_m_up_stop,
        mmi64_m_dn_d_o      => mmi64_mbrouter_m_dn_d,
        mmi64_m_dn_valid_o  => mmi64_mbrouter_m_dn_valid,
        mmi64_m_dn_accept_i => mmi64_mbrouter_m_dn_accept,
        mmi64_m_dn_start_o  => mmi64_mbrouter_m_dn_start,
        mmi64_m_dn_stop_o   => mmi64_mbrouter_m_dn_stop,

        -- module presence detection
        module_presence_detection_i => mmi64_mbrouter_m_present
        );

  --
  -- mmi64 module presence detection pins for mainboard router output ports
  --

  -- control register file interface is always present
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_CTRL_REGIF) <= '1';

  -- test module is always present
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_DEVZERO) <= '1';

  -- presence of previous mainboard
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_NEXT_MB) <= nmb_up(MB2MB_MB_PRESENT_IDX);

  -- keep MMI-64 to user FPGAs in reset until MMI-64 is selected on DMBI pins and user FPGA replied "present" on pins 19:18
  ta1_muxdemux_reset <= '1' when ta1_dmbi_f2h(19 downto 18) /= "10" or ctrl_cfg_mmi_mux_r(MMI64_MODULE_IDX_USERMMI64_A1)='0' else '0';
  ta3_muxdemux_reset <= '1' when ta3_dmbi_f2h(19 downto 18) /= "10" or ctrl_cfg_mmi_mux_r(MMI64_MODULE_IDX_USERMMI64_A3)='0' else '0';
  tc1_muxdemux_reset <= '1' when tc1_dmbi_f2h(19 downto 18) /= "10" or ctrl_cfg_mmi_mux_r(MMI64_MODULE_IDX_USERMMI64_C1)='0' else '0';
  tc3_muxdemux_reset <= '1' when tc3_dmbi_f2h(19 downto 18) /= "10" or ctrl_cfg_mmi_mux_r(MMI64_MODULE_IDX_USERMMI64_C3)='0' else '0';

  -- mark user modules as present only if user MMI-64 is not in reset state
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_USERMMI64_A1) <= not ta1_muxdemux_reset;
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_USERMMI64_A3) <= not ta3_muxdemux_reset;
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_USERMMI64_C1) <= not tc1_muxdemux_reset;
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_USERMMI64_C3) <= not tc3_muxdemux_reset;
  
  -- mark clk modules as present only if clock fpgas are not in reset state
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_CLK01) <= not ctrl_comm_rst_r;
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_CLK23) <= not ctrl_comm_rst_r;
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_CLK45) <= not ctrl_comm_rst_r;
  mmi64_mbrouter_m_present(MMI64_MODULE_IDX_CLK67) <= not ctrl_comm_rst_r;

  -- next motherboard (signal mapping only)
  nmb_dn(MB2MB_CLK_RANGE)        <= clk;
  nmb_dn(MB2MB_SYNC_RANGE)       <= sync;
  nmb_dn(MB2MB_MMI64_DATA_RANGE) <= mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_NEXT_MB);
  nmb_dn(MB2MB_MMI64_VALID_IDX)  <= mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_NEXT_MB);
  nmb_dn(MB2MB_MMI64_START_IDX)  <= mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_NEXT_MB);
  nmb_dn(MB2MB_MMI64_STOP_IDX)   <= mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_NEXT_MB);
  nmb_dn(MB2MB_MMI64_ACCEPT_IDX) <= mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_NEXT_MB);
  nmb_dn(MB2MB_MB_PRESENT_IDX)   <= '1';

  mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_NEXT_MB)     <= nmb_up(MB2MB_MMI64_DATA_RANGE);
  mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_NEXT_MB) <= nmb_up(MB2MB_MMI64_VALID_IDX);
  mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_NEXT_MB) <= nmb_up(MB2MB_MMI64_START_IDX);
  mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_NEXT_MB)  <= nmb_up(MB2MB_MMI64_STOP_IDX);
  mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_NEXT_MB) <= nmb_up(MB2MB_MMI64_ACCEPT_IDX);

  -- control register file interface
  u_mb_ctrl_regif : mmi64_m_regif
    generic map (
      MODULE_ID         => X"80000009",
      REGISTER_COUNT    => CTRL_REGISTER_COUNT,
      REGISTER_WIDTH    => 16,
      READ_BUFFER_DEPTH => 4
      ) port map (
        mmi64_clk   => mmi64_clk,
        mmi64_reset => mmi64_reset,

        -- connections to mmi64 router
        mmi64_h_dn_d_i      => mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_CTRL_REGIF),
        mmi64_h_dn_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_CTRL_REGIF),
        mmi64_h_dn_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_CTRL_REGIF),
        mmi64_h_dn_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_CTRL_REGIF),
        mmi64_h_dn_stop_i   => mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_CTRL_REGIF),
        mmi64_h_up_d_o      => mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_CTRL_REGIF),
        mmi64_h_up_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_CTRL_REGIF),
        mmi64_h_up_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_CTRL_REGIF),
        mmi64_h_up_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_CTRL_REGIF),
        mmi64_h_up_stop_o   => mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_CTRL_REGIF),

        -- connections to register interface
        reg_en_o     => ctrl_regfile_en,
        reg_we_o     => ctrl_regfile_we,
        reg_addr_o   => ctrl_regfile_addr,
        reg_wdata_o  => ctrl_regfile_wdata,
        reg_accept_i => ctrl_regfile_accept,
        reg_rdata_i  => ctrl_regfile_rdata,
        reg_rvalid_i => ctrl_regfile_rvalid
        );

  -- clk01 register interface
  CLK01_REGIF : mmi64_m_regif
    generic map (
      MODULE_ID         => X"8000000A", 
      REGISTER_COUNT    => CLK01_REGISTER_COUNT,
      REGISTER_WIDTH    => 16,
      READ_BUFFER_DEPTH => 4
      ) port map (
        mmi64_clk   => mmi64_clk,
        mmi64_reset => mmi64_reset,

        -- connections to mmi64 router
        mmi64_h_dn_d_i      => mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_CLK01),
        mmi64_h_dn_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_CLK01),
        mmi64_h_dn_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_CLK01),
        mmi64_h_dn_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_CLK01),
        mmi64_h_dn_stop_i   => mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_CLK01),
        mmi64_h_up_d_o      => mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_CLK01),
        mmi64_h_up_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_CLK01),
        mmi64_h_up_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_CLK01),
        mmi64_h_up_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_CLK01),
        mmi64_h_up_stop_o   => mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_CLK01),

        -- connections to register interface
        reg_en_o     => clk01_regfile_en,
        reg_we_o     => clk01_regfile_we,
        reg_addr_o   => clk01_regfile_addr,
        reg_wdata_o  => clk01_regfile_wdata,
        reg_accept_i => clk01_regfile_accept,
        reg_rdata_i  => clk01_regfile_rdata,
        reg_rvalid_i => clk01_regfile_rvalid
        );

  clk01_regfile_accept <= '1';

  -- clk23 register interface
  CLK23_REGIF : mmi64_m_regif
    generic map (
      MODULE_ID         => X"8000000B", 
      REGISTER_COUNT    => CLK23_REGISTER_COUNT,
      REGISTER_WIDTH    => 16,
      READ_BUFFER_DEPTH => 4
      ) port map (
        mmi64_clk   => mmi64_clk,
        mmi64_reset => mmi64_reset,

        -- connections to mmi64 router
        mmi64_h_dn_d_i      => mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_CLK23),
        mmi64_h_dn_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_CLK23),
        mmi64_h_dn_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_CLK23),
        mmi64_h_dn_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_CLK23),
        mmi64_h_dn_stop_i   => mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_CLK23),
        mmi64_h_up_d_o      => mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_CLK23),
        mmi64_h_up_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_CLK23),
        mmi64_h_up_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_CLK23),
        mmi64_h_up_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_CLK23),
        mmi64_h_up_stop_o   => mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_CLK23),

        -- connections to register interface
        reg_en_o     => clk23_regfile_en,
        reg_we_o     => clk23_regfile_we,
        reg_addr_o   => clk23_regfile_addr,
        reg_wdata_o  => clk23_regfile_wdata,
        reg_accept_i => clk23_regfile_accept,
        reg_rdata_i  => clk23_regfile_rdata,
        reg_rvalid_i => clk23_regfile_rvalid
        );

  clk23_regfile_accept <= '1';

  -- clk45 register interface
  CLK45_REGIF : mmi64_m_regif
    generic map (
      MODULE_ID         => X"8000000C", 
      REGISTER_COUNT    => CLK45_REGISTER_COUNT,
      REGISTER_WIDTH    => 16,
      READ_BUFFER_DEPTH => 4
      ) port map (
        mmi64_clk   => mmi64_clk,
        mmi64_reset => mmi64_reset,

        -- connections to mmi64 router
        mmi64_h_dn_d_i      => mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_CLK45),
        mmi64_h_dn_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_CLK45),
        mmi64_h_dn_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_CLK45),
        mmi64_h_dn_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_CLK45),
        mmi64_h_dn_stop_i   => mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_CLK45),
        mmi64_h_up_d_o      => mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_CLK45),
        mmi64_h_up_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_CLK45),
        mmi64_h_up_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_CLK45),
        mmi64_h_up_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_CLK45),
        mmi64_h_up_stop_o   => mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_CLK45),

        -- connections to register interface
        reg_en_o     => clk45_regfile_en,
        reg_we_o     => clk45_regfile_we,
        reg_addr_o   => clk45_regfile_addr,
        reg_wdata_o  => clk45_regfile_wdata,
        reg_accept_i => clk45_regfile_accept,
        reg_rdata_i  => clk45_regfile_rdata,
        reg_rvalid_i => clk45_regfile_rvalid
        );

  clk45_regfile_accept <= '1';

  -- clk67 register interface
  CLK67_REGIF : mmi64_m_regif
    generic map (
      MODULE_ID         => X"8000000D",
      REGISTER_COUNT    => CLK67_REGISTER_COUNT,
      REGISTER_WIDTH    => 16,
      READ_BUFFER_DEPTH => 4
      ) port map (
        mmi64_clk   => mmi64_clk,
        mmi64_reset => mmi64_reset,

        -- connections to mmi64 router
        mmi64_h_dn_d_i      => mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_CLK67),
        mmi64_h_dn_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_CLK67),
        mmi64_h_dn_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_CLK67),
        mmi64_h_dn_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_CLK67),
        mmi64_h_dn_stop_i   => mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_CLK67),
        mmi64_h_up_d_o      => mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_CLK67),
        mmi64_h_up_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_CLK67),
        mmi64_h_up_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_CLK67),
        mmi64_h_up_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_CLK67),
        mmi64_h_up_stop_o   => mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_CLK67),

        -- connections to register interface
        reg_en_o     => clk67_regfile_en,
        reg_we_o     => clk67_regfile_we,
        reg_addr_o   => clk67_regfile_addr,
        reg_wdata_o  => clk67_regfile_wdata,
        reg_accept_i => clk67_regfile_accept,
        reg_rdata_i  => clk67_regfile_rdata,
        reg_rvalid_i => clk67_regfile_rvalid
        );

  clk67_regfile_accept <= '1';


--
-- mmi64 pin multiplexers to user fpgas
--

  -- mmi64 pin multiplexer to user fpga at site ta1
  u_mmi64_muxdemux_ta1 : mmi64_p_muxdemux
  generic map (
    PIN_TRAINING_SPEED => DMBI_TRAINING_SPEED  
    --  MUX_FACTOR => MMI64_PINMUX_FACTOR
      )
  port map (
    --! pad interface
    pad_hs_clk => dmbi_clk_x4,
    pad_data_o => ta1_dmbi_h2f(17 downto 0),
    pad_data_i => ta1_dmbi_f2h(17 downto 0),

    pad_dv_clk          => dmbi_clk,
    pad_dv_reset        => ta1_muxdemux_reset,
    --! mmi64 reliable transmission statistic
    rt_crc_errors_o     => open,
    rt_ack_errors_o     => open,
    rt_id_errors_o      => open,
    rt_id_warnings_o    => open,
    muxdemux_mode_o     => open,
    muxdemux_status_o   => open,
    --! mmi64 connections
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,
    mmi64_m_dn_d_o      => mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_USERMMI64_A1),
    mmi64_m_dn_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_USERMMI64_A1),
    mmi64_m_dn_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_USERMMI64_A1),
    mmi64_m_dn_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_USERMMI64_A1),
    mmi64_m_dn_stop_o   => mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_USERMMI64_A1),
    mmi64_m_up_d_i      => mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_USERMMI64_A1),
    mmi64_m_up_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_USERMMI64_A1),
    mmi64_m_up_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_USERMMI64_A1),
    mmi64_m_up_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_USERMMI64_A1),
    mmi64_m_up_stop_i   => mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_USERMMI64_A1)
  );

  -- mmi64 pin multiplexer to user fpga at site ta3
  u_mmi64_muxdemux_ta3 : mmi64_p_muxdemux
  generic map (
    PIN_TRAINING_SPEED => DMBI_TRAINING_SPEED  
  --  MUX_FACTOR => MMI64_PINMUX_FACTOR
    ) 
  port map (
    --! pad interface
    pad_hs_clk => dmbi_clk_x4,
    pad_data_o => ta3_dmbi_h2f(17 downto 0),
    pad_data_i => ta3_dmbi_f2h(17 downto 0),

    pad_dv_clk          => dmbi_clk,
    pad_dv_reset        => ta3_muxdemux_reset,
    --! mmi64 reliable transmission statistic
    rt_crc_errors_o     => open,
    rt_ack_errors_o     => open,
    rt_id_errors_o      => open,
    rt_id_warnings_o    => open,
    muxdemux_mode_o     => open,
    muxdemux_status_o   => open,
    --! mmi64 connections
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,
    mmi64_m_dn_d_o      => mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_USERMMI64_A3),
    mmi64_m_dn_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_USERMMI64_A3),
    mmi64_m_dn_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_USERMMI64_A3),
    mmi64_m_dn_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_USERMMI64_A3),
    mmi64_m_dn_stop_o   => mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_USERMMI64_A3),
    mmi64_m_up_d_i      => mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_USERMMI64_A3),
    mmi64_m_up_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_USERMMI64_A3),
    mmi64_m_up_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_USERMMI64_A3),
    mmi64_m_up_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_USERMMI64_A3),
    mmi64_m_up_stop_i   => mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_USERMMI64_A3)
  );

  -- mmi64 pin multiplexer to user fpga at site tc1
  u_mmi64_muxdemux_tc1 : mmi64_p_muxdemux
  generic map (
    PIN_TRAINING_SPEED => DMBI_TRAINING_SPEED  
  --  MUX_FACTOR => MMI64_PINMUX_FACTOR
    ) 
  port map (
    --! pad interface
    pad_hs_clk => dmbi_clk_x4,
    pad_data_o => tc1_dmbi_h2f(17 downto 0),
    pad_data_i => tc1_dmbi_f2h(17 downto 0),

    pad_dv_clk          => dmbi_clk,
    pad_dv_reset        => tc1_muxdemux_reset,
    --! mmi64 reliable transmission statistic
    rt_crc_errors_o     => open,
    rt_ack_errors_o     => open,
    rt_id_errors_o      => open,
    rt_id_warnings_o    => open,
    muxdemux_mode_o     => open,
    muxdemux_status_o   => open,
    --! mmi64 connections
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,
    mmi64_m_dn_d_o      => mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_USERMMI64_C1),
    mmi64_m_dn_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_USERMMI64_C1),
    mmi64_m_dn_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_USERMMI64_C1),
    mmi64_m_dn_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_USERMMI64_C1),
    mmi64_m_dn_stop_o   => mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_USERMMI64_C1),
    mmi64_m_up_d_i      => mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_USERMMI64_C1),
    mmi64_m_up_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_USERMMI64_C1),
    mmi64_m_up_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_USERMMI64_C1),
    mmi64_m_up_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_USERMMI64_C1),
    mmi64_m_up_stop_i   => mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_USERMMI64_C1)
  );


  -- mmi64 pin multiplexer to user fpga at site tc3
  u_mmi64_muxdemux_tc3 : mmi64_p_muxdemux
  generic map (
    PIN_TRAINING_SPEED => DMBI_TRAINING_SPEED  
  --  MUX_FACTOR => MMI64_PINMUX_FACTOR
    ) 
  port map (
    --! Pad interface
    pad_hs_clk => dmbi_clk_x4,
    pad_data_o => tc3_dmbi_h2f(17 downto 0),
    pad_data_i => tc3_dmbi_f2h(17 downto 0),

    pad_dv_clk          => dmbi_clk,
    pad_dv_reset        => tc3_muxdemux_reset,
    --! MMI64 Reliable Transmission statistic
    rt_crc_errors_o     => open,
    rt_ack_errors_o     => open,
    rt_id_errors_o      => open,
    rt_id_warnings_o    => open,
    muxdemux_mode_o     => open,
    muxdemux_status_o   => open,
    -- MMI64 connections
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,
    mmi64_m_dn_d_o      => mmi64_mbrouter_m_up_d (MMI64_MODULE_IDX_USERMMI64_C3),
    mmi64_m_dn_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_USERMMI64_C3),
    mmi64_m_dn_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_USERMMI64_C3),
    mmi64_m_dn_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_USERMMI64_C3),
    mmi64_m_dn_stop_o   => mmi64_mbrouter_m_up_stop (MMI64_MODULE_IDX_USERMMI64_C3),
    mmi64_m_up_d_i      => mmi64_mbrouter_m_dn_d (MMI64_MODULE_IDX_USERMMI64_C3),
    mmi64_m_up_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_USERMMI64_C3),
    mmi64_m_up_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_USERMMI64_C3),
    mmi64_m_up_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_USERMMI64_C3),
    mmi64_m_up_stop_i   => mmi64_mbrouter_m_dn_stop (MMI64_MODULE_IDX_USERMMI64_C3)
  );

  -- declare DMBI present after DMBI mux selected MMI-64 PHY
  ta1_dmbi_h2f(19 downto 18) <= ctrl_cfg_mmi_mux_r(MMI64_MODULE_IDX_USERMMI64_A1) & '0';
  ta3_dmbi_h2f(19 downto 18) <= ctrl_cfg_mmi_mux_r(MMI64_MODULE_IDX_USERMMI64_A3) & '0';
  tc1_dmbi_h2f(19 downto 18) <= ctrl_cfg_mmi_mux_r(MMI64_MODULE_IDX_USERMMI64_C1) & '0';
  tc3_dmbi_h2f(19 downto 18) <= ctrl_cfg_mmi_mux_r(MMI64_MODULE_IDX_USERMMI64_C3) & '0';

--
-- mmi64 register map
--

  -- decode which register file has been addressed
  regfile_clkgen_ce <= ctrl_regfile_en when ctrl_regfile_en='1' and unsigned(ctrl_regfile_addr) <= REGIF_CLKGEN_RESERVED else '0';
  regif_ce          <= ctrl_regfile_en when ctrl_regfile_en='1' and unsigned(ctrl_regfile_addr) > REGIF_CLKGEN_RESERVED  else '0';

  ctrl_regfile_accept <= (clkgen_accept and regfile_clkgen_ce) or (regif_accept_r and regif_ce);
  ctrl_regfile_rvalid <= regif_rvalid_r or clkgen_rvalid;

  ctrl_regfile_rdata <= regif_rdata_r when regif_rvalid_r = '1'
                        else clkgen_rdata when clkgen_rvalid = '1'
                        else x"0000";

  -- main clock generator
  u_mb_clock_generator : mb_clock_generator
    port map (
      cfg_clk => mmi64_clk,
      cfg_rst => mmi64_reset,

      refclk_125MHz_i => clk_125mhz,
      refclk_60MHz_i  => clk_60mhz,
      refclk_18MHz_i  => clk_18_432mhz,
      refclk_ext_i    => ext_clk,

      srcclk_o => clkgen_clk(7 downto 1),
      locked_o => clkgen_locked(7 downto 1),

      reg_we_i     => ctrl_regfile_we,
      reg_addr_i   => ctrl_regfile_addr(1 downto 0),
      reg_wdata_i  => ctrl_regfile_wdata,
      reg_ce_i     => regfile_clkgen_ce,
      reg_accept_o => clkgen_accept,
      reg_rdata_o  => clkgen_rdata,
      reg_rvalid_o => clkgen_rvalid
      );

  clkgen_clk(0)    <= mmi64_clk;
  clkgen_locked(0) <= not mmi64_reset;

  p_ctrl_ff : process(mmi64_clk, mmi64_reset)
    variable rdata_v  : std_ulogic_vector(15 downto 0);
    variable rvalid_v : std_ulogic;
  begin
    if mmi64_reset = '1' then
      regif_accept_r <= '0';
      regif_rdata_r  <= (others => '0');
      regif_rvalid_r <= '0';

      ctrl_cfg_mmi_mux_r    <= (others => '0');
      ctrl_clkfpga_progb_r  <= "1111";
      ctrl_comm_rst_r       <= '0';
      ctrl_emerg_shutdown_r <= '0';
      ctrl_status_led_r     <= (others => '0');

      sync_cmd_r           <= (others => SYNC_CMD_INIT);
      sync_event_done_rMMI <= sync_event_done_rEXT;

    elsif rising_edge(mmi64_clk) then
      sync_event_done_rMMI <= sync_event_done_rEXT;

      rdata_v  := (others => '0');
      rvalid_v := '0';

      -- check for ongoing handshake operations with SYNC clock domains
      -- Note: setting regif_accept_r to '0' when receiving new SYNC op
      regif_accept_r <= '1';
      for idx in 0 to 7 loop
        if sync_cmd_r(idx).event_en = '1' or sync_event_done_rMMI(idx) = '1' then
          regif_accept_r <= '0';
        end if;

        -- handshake phase 6
        if sync_event_done_rMMI(idx) = '1' then
          sync_cmd_r(idx).event_en <= '0';
        end if;
      end loop;

      -- register access
      if regif_ce = '1' and regif_accept_r = '1' then
        if ctrl_regfile_we = '1' then  -- WRITE OPERATION ---------

          -- PROG_B
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_CLKFPGA_PROGB then
            ctrl_clkfpga_progb_r <= ctrl_regfile_wdata(ctrl_clkfpga_progb_r'length-1 downto 0);
          end if;

          -- COMM_RST
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_COMM_RST then
            ctrl_comm_rst_r <= ctrl_regfile_wdata(0);
          end if;

          -- CFG_MMI64_MUX
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_CFG_MMI_MUX then
            ctrl_cfg_mmi_mux_r <= ctrl_regfile_wdata(ctrl_cfg_mmi_mux_r'length-1 downto 0);
          end if;

          -- EMERGENCY_OFF
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_EMERG_SHUTDOWN then
            ctrl_emerg_shutdown_r <= ctrl_regfile_wdata(0);
          end if;

          -- STATUS_LED
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_STATUS_LED then
            for i in ctrl_status_led_r'range loop
              if ctrl_regfile_wdata(i+8) = '1' then  -- upper 8 bit used as bit write enable
                ctrl_status_led_r(i) <= ctrl_regfile_wdata(i);
              end if;
            end loop;
          end if;

          -- SYNC[IDX].EVENT, SYNC[IDX].PAUSE
          for idx in 0 to 7 loop
            if unsigned(ctrl_regfile_addr) = REGIF_CTRL_SYNC_LO+2*idx then  -- SYNC[IDX].EVENT register
              if ctrl_regfile_wdata(15) = '1' then  -- event configuration
                sync_cmd_r(idx).strobe2_sel <= ctrl_regfile_wdata(5 downto 4);
                sync_cmd_r(idx).strobe1_sel <= ctrl_regfile_wdata(1 downto 0);
              else                      -- generate event
                -- handshake phase 1
                sync_cmd_r(idx).event_id <= ctrl_regfile_wdata(7 downto 0);
                sync_cmd_r(idx).event_en <= '1';
                regif_accept_r           <= '0';
              end if;
            end if;
            if unsigned(ctrl_regfile_addr) = REGIF_CTRL_SYNC_LO+2*idx+1 then  -- SYNC[IDX].PAUSE register
              sync_cmd_r(idx).event_pause <= ctrl_regfile_wdata;
            end if;
          end loop;

        else  -- READ OPERATION -----------------
          rvalid_v := '1';  -- always return data (ZERO if unreadable)

          -- PROG_B
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_CLKFPGA_PROGB then
            rdata_v(ctrl_clkfpga_progb_r'length-1 downto 0) := ctrl_clkfpga_progb_r;
          end if;

          -- CLKFPGA_DONE
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_CLKFPGA_DONE then
            rdata_v(3 downto 0) := "1111";
          end if;

          -- PSU_STATUS
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_PSU_STATUS then
            rdata_v(2 downto 0) := "111";
          end if;

          -- COMM_RST
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_COMM_RST then
            rdata_v(0) := rdata_v(0) or ctrl_comm_rst_r;
          end if;

          -- REVISION_LO
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_REVISION_LO then
            rdata_v := rdata_v or FIRMWARE_REVISION_VEC(15 downto 0);
          end if;

          -- REVISION_HI
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_REVISION_HI then
            rdata_v := rdata_v or FIRMWARE_REVISION_VEC(31 downto 16);
          end if;

          -- CFG_MMI64_MUX
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_CFG_MMI_MUX then
            rdata_v(ctrl_cfg_mmi_mux_r'length-1 downto 0) := ctrl_cfg_mmi_mux_r;
          end if;

          -- PCB_REVISION
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_PCB_REVISION then
            rdata_v(PCB_REVISION_VEC'length-1 downto 0) := PCB_REVISION_VEC;
          end if;

          -- STATUS_LED
          if unsigned(ctrl_regfile_addr) = REGIF_CTRL_STATUS_LED then
            rdata_v(ctrl_status_led_r'length-1 downto 0) := ctrl_status_led_r;
          end if;

          -- SYNC[IDX].EVENT, SYNC[IDX].PAUSE
          for idx in 0 to 7 loop
            if unsigned(ctrl_regfile_addr) = REGIF_CTRL_SYNC_LO+2*idx then  -- SYNC[IDX].EVENT register
              rdata_v(5 downto 4) := sync_cmd_r(idx).strobe2_sel;
              rdata_v(1 downto 0) := sync_cmd_r(idx).strobe1_sel;
            end if;
            if unsigned(ctrl_regfile_addr) = REGIF_CTRL_SYNC_LO+2*idx+1 then  -- SYNC[IDX].PAUSE register
              rdata_v := sync_cmd_r(idx).event_pause;
            end if;
          end loop;
        end if;
      end if;

      regif_rdata_r  <= rdata_v;
      regif_rvalid_r <= rvalid_v;
    end if;
  end process p_ctrl_ff;

--
-- sync transmitters
--

  SYNC_GEN : for i in 0 to 7 generate
    sync_rst_rEXT(i) <= "11" when clkgen_locked(i) = '0'
                        else '0' & sync_rst_rEXT(i)(1) when rising_edge(clkgen_clk(i));

    sync_strobe1_EXT(i) <= ext_sync(to_integer(unsigned(sync_cmd_rEXT(i).strobe1_sel)));
    sync_strobe2_EXT(i) <= ext_sync(to_integer(unsigned(sync_cmd_rEXT(i).strobe2_sel)));

    SYNC_CTRL_FF : process(clkgen_clk(i), sync_rst_rEXT(i))
    begin
      if sync_rst_rEXT(i)(0) = '1' then
        sync_event_en_META_rEXT(i) <= '0';
        sync_event_done_rEXT(i)    <= '0';
        -- intended: sync_event_done_rEXT(i)       <= '1'; -- reject events from MMI domain (i.e. handshake at phase 7)
        -- problem: with current REGIF handshaking, this will deadlock because SYNC clock domain never runs

        sync_cmd_rEXT(i) <= SYNC_CMD_INIT;
      elsif rising_edge(clkgen_clk(i)) then
        -- clock domain transition for quasi-static signals
        sync_cmd_rEXT(i).event_pause <= sync_cmd_r(i).event_pause;
        sync_cmd_rEXT(i).strobe1_sel <= sync_cmd_r(i).strobe1_sel;
        sync_cmd_rEXT(i).strobe2_sel <= sync_cmd_r(i).strobe2_sel;

        -- handshake phase 2 and 7: ensure that event_en is the slowest of all signals
        sync_event_en_META_rEXT(i) <= sync_cmd_r(i).event_en;

        -- handshake phase 3
        if sync_event_done_rEXT(i) = '0' then
          sync_cmd_rEXT(i).event_id <= sync_cmd_r(i).event_id;
          sync_cmd_rEXT(i).event_en <= sync_event_en_META_rEXT(i);
        end if;

        -- handshake phase 4
        if sync_cmd_rEXT(i).event_en = '1' and sync_event_busy_EXT(i) = '0' then
          sync_cmd_rEXT(i).event_en <= '0';
          sync_event_done_rEXT(i)   <= '1';
        end if;

        -- handshake phase 8
        if sync_event_en_META_rEXT(i) = '0' then
          sync_event_done_rEXT(i) <= '0';
        end if;

      end if;
    end process SYNC_CTRL_FF;

    -- sync transmitter
    u_sync_tx : profpga_sync_tx
      port map (
        -- sync event interface
        clk          => clkgen_clk(i),
        rst          => sync_rst_rEXT(i)(0),
        event_id_i   => sync_cmd_rEXT(i).event_id,
        event_en_i   => sync_cmd_rEXT(i).event_en,
        event_busy_o => sync_event_busy_EXT(i),

        -- extra wait cycles between 2 sync events (needed when recipent derives very slow clock)
        event_pause_i => sync_cmd_rEXT(i).event_pause,

        -- automatic sync events
        user_reset_i   => '1',
        user_strobe1_i => sync_strobe1_EXT(i),
        user_strobe2_i => sync_strobe2_EXT(i),

        -- sync output
        sync_p_o => clkgen_sync(i),
        sync_n_o => open
        );
  end generate SYNC_GEN;


--
-- clock fpga register file implementations
--

  p_clk01_ff : process(mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      -- default assigments
      clk01_regfile_rdata  <= (others => '0');
      clk01_regfile_rvalid <= '0';

      if clk01_regfile_en = '1' then
        if clk01_regfile_we = '1' then
          -- perform register write access
          case to_integer(unsigned(clk01_regfile_addr)) is
            when REGIF_CLK01_CLK0_SEL => clk01_clk0_sel_r <= clk01_regfile_wdata(clk01_clk0_sel_r'length-1 downto 0);
            when REGIF_CLK01_CLK1_SEL => clk01_clk1_sel_r <= clk01_regfile_wdata(clk01_clk1_sel_r'length-1 downto 0);
            when REGIF_CLK01_CLK2_SEL => clk01_clk2_sel_r <= clk01_regfile_wdata(clk01_clk2_sel_r'length-1 downto 0);
            when REGIF_CLK01_CLK3_SEL => clk01_clk3_sel_r <= clk01_regfile_wdata(clk01_clk3_sel_r'length-1 downto 0);
            when REGIF_CLK01_CLK4_SEL => clk01_clk4_sel_r <= clk01_regfile_wdata(clk01_clk4_sel_r'length-1 downto 0);
            when REGIF_CLK01_CLK5_SEL => clk01_clk5_sel_r <= clk01_regfile_wdata(clk01_clk5_sel_r'length-1 downto 0);
            when REGIF_CLK01_CLK6_SEL => clk01_clk6_sel_r <= clk01_regfile_wdata(clk01_clk6_sel_r'length-1 downto 0);
            when REGIF_CLK01_CLK7_SEL => clk01_clk7_sel_r <= clk01_regfile_wdata(clk01_clk7_sel_r'length-1 downto 0);
            when others               => null;
          end case;
        else
          -- perform register read access
          clk01_regfile_rvalid <= '1';
          case to_integer(unsigned(clk01_regfile_addr)) is
            when REGIF_CLK01_CLK0_SEL    => clk01_regfile_rdata(1 downto 0) <= clk01_clk0_sel_r;
            when REGIF_CLK01_CLK1_SEL    => clk01_regfile_rdata(1 downto 0) <= clk01_clk1_sel_r;
            when REGIF_CLK01_CLK2_SEL    => clk01_regfile_rdata(1 downto 0) <= clk01_clk2_sel_r;
            when REGIF_CLK01_CLK3_SEL    => clk01_regfile_rdata(1 downto 0) <= clk01_clk3_sel_r;
            when REGIF_CLK01_CLK4_SEL    => clk01_regfile_rdata(1 downto 0) <= clk01_clk4_sel_r;
            when REGIF_CLK01_CLK5_SEL    => clk01_regfile_rdata(1 downto 0) <= clk01_clk5_sel_r;
            when REGIF_CLK01_CLK6_SEL    => clk01_regfile_rdata(1 downto 0) <= clk01_clk6_sel_r;
            when REGIF_CLK01_CLK7_SEL    => clk01_regfile_rdata(1 downto 0) <= clk01_clk7_sel_r;
            when REGIF_CLK01_PRESENT     => clk01_regfile_rdata             <= (others => '0');
            when REGIF_CLK01_REVISION_LO => clk01_regfile_rdata             <= FIRMWARE_REVISION_VEC(15 downto 0);
            when REGIF_CLK01_REVISION_HI => clk01_regfile_rdata             <= FIRMWARE_REVISION_VEC(31 downto 16);
            when others                  => null;
          end case;
        end if;
      end if;

      -- perform reset
      if mmi64_reset = '1' or ctrl_comm_rst_r = '1' then
        clk01_clk0_sel_r     <= "10";
        clk01_clk1_sel_r     <= "10";
        clk01_clk2_sel_r     <= "10";
        clk01_clk3_sel_r     <= "10";
        clk01_clk4_sel_r     <= "10";
        clk01_clk5_sel_r     <= "10";
        clk01_clk6_sel_r     <= "10";
        clk01_clk7_sel_r     <= "10";
        clk01_regfile_rvalid <= '0';
      end if;
    end if;
  end process p_clk01_ff;

  p_clk23_ff : process(mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      -- default assignments
      clk23_regfile_rdata  <= (others => '0');
      clk23_regfile_rvalid <= '0';

      if clk23_regfile_en = '1' then
        if clk23_regfile_we = '1' then
          -- perform register write access
          case to_integer(unsigned(clk23_regfile_addr)) is
            when REGIF_CLK23_SYNC0_SEL => clk23_sync0_sel_r <= clk23_regfile_wdata(clk23_sync0_sel_r'length-1 downto 0);
            when REGIF_CLK23_SYNC1_SEL => clk23_sync1_sel_r <= clk23_regfile_wdata(clk23_sync1_sel_r'length-1 downto 0);
            when REGIF_CLK23_SYNC2_SEL => clk23_sync2_sel_r <= clk23_regfile_wdata(clk23_sync2_sel_r'length-1 downto 0);
            when REGIF_CLK23_SYNC3_SEL => clk23_sync3_sel_r <= clk23_regfile_wdata(clk23_sync3_sel_r'length-1 downto 0);
            when REGIF_CLK23_SYNC4_SEL => clk23_sync4_sel_r <= clk23_regfile_wdata(clk23_sync4_sel_r'length-1 downto 0);
            when REGIF_CLK23_SYNC5_SEL => clk23_sync5_sel_r <= clk23_regfile_wdata(clk23_sync5_sel_r'length-1 downto 0);
            when REGIF_CLK23_SYNC6_SEL => clk23_sync6_sel_r <= clk23_regfile_wdata(clk23_sync6_sel_r'length-1 downto 0);
            when REGIF_CLK23_SYNC7_SEL => clk23_sync7_sel_r <= clk23_regfile_wdata(clk23_sync7_sel_r'length-1 downto 0);

            when REGIF_CLK23_PSU_A1_RUN => clk23_psu_a1_run_r <= clk23_regfile_wdata(0);
            when REGIF_CLK23_PSU_C1_RUN => clk23_psu_c1_run_r <= clk23_regfile_wdata(0);
            when REGIF_CLK23_PSU_A3_RUN => clk23_psu_a3_run_r <= clk23_regfile_wdata(0);
            when REGIF_CLK23_PSU_C3_RUN => clk23_psu_c3_run_r <= clk23_regfile_wdata(0);
            when others => null;
          end case;
        else
          -- perform register read access
          clk23_regfile_rvalid <= '1';
          case to_integer(unsigned(clk23_regfile_addr)) is
            when REGIF_CLK23_SYNC0_SEL => clk23_regfile_rdata(1 downto 0) <= clk23_sync0_sel_r;
            when REGIF_CLK23_SYNC1_SEL => clk23_regfile_rdata(1 downto 0) <= clk23_sync1_sel_r;
            when REGIF_CLK23_SYNC2_SEL => clk23_regfile_rdata(1 downto 0) <= clk23_sync2_sel_r;
            when REGIF_CLK23_SYNC3_SEL => clk23_regfile_rdata(1 downto 0) <= clk23_sync3_sel_r;
            when REGIF_CLK23_SYNC4_SEL => clk23_regfile_rdata(1 downto 0) <= clk23_sync4_sel_r;
            when REGIF_CLK23_SYNC5_SEL => clk23_regfile_rdata(1 downto 0) <= clk23_sync5_sel_r;
            when REGIF_CLK23_SYNC6_SEL => clk23_regfile_rdata(1 downto 0) <= clk23_sync6_sel_r;
            when REGIF_CLK23_SYNC7_SEL => clk23_regfile_rdata(1 downto 0) <= clk23_sync7_sel_r;

            when REGIF_CLK23_PSU_A1_RUN => clk23_regfile_rdata(0) <= clk23_psu_a1_run_r;
            when REGIF_CLK23_PSU_C1_RUN => clk23_regfile_rdata(0) <= clk23_psu_c1_run_r;
            when REGIF_CLK23_PSU_A3_RUN => clk23_regfile_rdata(0) <= clk23_psu_a3_run_r;
            when REGIF_CLK23_PSU_C3_RUN => clk23_regfile_rdata(0) <= clk23_psu_c3_run_r;

            when REGIF_CLK23_PRESENT =>     clk23_regfile_rdata     <= (others => '0');
            when REGIF_CLK23_REVISION_LO => clk23_regfile_rdata <= FIRMWARE_REVISION_VEC(15 downto 0);
            when REGIF_CLK23_REVISION_HI => clk23_regfile_rdata <= FIRMWARE_REVISION_VEC(31 downto 16);
            when others => null;
          end case;
        end if;
      end if;

      -- perform reset
      if mmi64_reset = '1' or ctrl_comm_rst_r = '1' then
        clk23_sync0_sel_r <= "10";
        clk23_sync1_sel_r <= "10";
        clk23_sync2_sel_r <= "10";
        clk23_sync3_sel_r <= "10";
        clk23_sync4_sel_r <= "10";
        clk23_sync5_sel_r <= "10";
        clk23_sync6_sel_r <= "10";
        clk23_sync7_sel_r <= "10";

        clk23_psu_a1_run_r <= '0';
        clk23_psu_c1_run_r <= '0';
        clk23_psu_a3_run_r <= '0';
        clk23_psu_c3_run_r <= '0';
      end if;
    end if;
  end process p_clk23_ff;

  p_clk45_ff : process(mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      -- default assignment
      clk45_regfile_rdata  <= (others => '0');
      clk45_regfile_rvalid <= '0';

      if clk45_regfile_en = '1' then
        -- perform register write access
        if clk45_regfile_we = '1' then
          case to_integer(unsigned(clk45_regfile_addr)) is
            when REGIF_CLK45_SRCCLK0_SEL  => clk45_srcclk0_sel_r  <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCCLK1_SEL  => clk45_srcclk1_sel_r  <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCCLK2_SEL  => clk45_srcclk2_sel_r  <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCCLK3_SEL  => clk45_srcclk3_sel_r  <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCCLK4_SEL  => clk45_srcclk4_sel_r  <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCCLK5_SEL  => clk45_srcclk5_sel_r  <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCCLK6_SEL  => clk45_srcclk6_sel_r  <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCCLK7_SEL  => clk45_srcclk7_sel_r  <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCSYNC0_SEL => clk45_srcsync0_sel_r <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCSYNC1_SEL => clk45_srcsync1_sel_r <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCSYNC2_SEL => clk45_srcsync2_sel_r <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCSYNC3_SEL => clk45_srcsync3_sel_r <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCSYNC4_SEL => clk45_srcsync4_sel_r <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCSYNC5_SEL => clk45_srcsync5_sel_r <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCSYNC6_SEL => clk45_srcsync6_sel_r <= clk45_regfile_wdata(0);
            when REGIF_CLK45_SRCSYNC7_SEL => clk45_srcsync7_sel_r <= clk45_regfile_wdata(0);
            when others => null;
          end case;
        else
          -- perform register read access
          clk45_regfile_rvalid <= '1';
          case to_integer(unsigned(clk45_regfile_addr)) is
            when REGIF_CLK45_PCIE_PSUGOOD => clk45_regfile_rdata(4 downto 0) <= clk45_pcie_psugood_r;
            when REGIF_CLK45_SRCCLK0_SEL  => clk45_regfile_rdata(0)          <= clk45_srcclk0_sel_r;
            when REGIF_CLK45_SRCCLK1_SEL  => clk45_regfile_rdata(0)          <= clk45_srcclk1_sel_r;
            when REGIF_CLK45_SRCCLK2_SEL  => clk45_regfile_rdata(0)          <= clk45_srcclk2_sel_r;
            when REGIF_CLK45_SRCCLK3_SEL  => clk45_regfile_rdata(0)          <= clk45_srcclk3_sel_r;
            when REGIF_CLK45_SRCCLK4_SEL  => clk45_regfile_rdata(0)          <= clk45_srcclk4_sel_r;
            when REGIF_CLK45_SRCCLK5_SEL  => clk45_regfile_rdata(0)          <= clk45_srcclk5_sel_r;
            when REGIF_CLK45_SRCCLK6_SEL  => clk45_regfile_rdata(0)          <= clk45_srcclk6_sel_r;
            when REGIF_CLK45_SRCCLK7_SEL  => clk45_regfile_rdata(0)          <= clk45_srcclk7_sel_r;
            when REGIF_CLK45_SRCSYNC0_SEL => clk45_regfile_rdata(0)          <= clk45_srcsync0_sel_r;
            when REGIF_CLK45_SRCSYNC1_SEL => clk45_regfile_rdata(0)          <= clk45_srcsync1_sel_r;
            when REGIF_CLK45_SRCSYNC2_SEL => clk45_regfile_rdata(0)          <= clk45_srcsync2_sel_r;
            when REGIF_CLK45_SRCSYNC3_SEL => clk45_regfile_rdata(0)          <= clk45_srcsync3_sel_r;
            when REGIF_CLK45_SRCSYNC4_SEL => clk45_regfile_rdata(0)          <= clk45_srcsync4_sel_r;
            when REGIF_CLK45_SRCSYNC5_SEL => clk45_regfile_rdata(0)          <= clk45_srcsync5_sel_r;
            when REGIF_CLK45_SRCSYNC6_SEL => clk45_regfile_rdata(0)          <= clk45_srcsync6_sel_r;
            when REGIF_CLK45_SRCSYNC7_SEL => clk45_regfile_rdata(0)          <= clk45_srcsync7_sel_r;
            when REGIF_CLK45_REVISION_LO  => clk45_regfile_rdata             <= FIRMWARE_REVISION_VEC(15 downto 0);
            when REGIF_CLK45_REVISION_HI  => clk45_regfile_rdata             <= FIRMWARE_REVISION_VEC(31 downto 16);
            when others => null;
          end case;
        end if;
      end if;

      -- perform reset
      if mmi64_reset = '1' or ctrl_comm_rst_r = '1' then
        clk45_srcclk0_sel_r  <= '0';
        clk45_srcclk1_sel_r  <= '0';
        clk45_srcclk2_sel_r  <= '0';
        clk45_srcclk3_sel_r  <= '0';
        clk45_srcclk4_sel_r  <= '0';
        clk45_srcclk5_sel_r  <= '0';
        clk45_srcclk6_sel_r  <= '0';
        clk45_srcclk7_sel_r  <= '0';
        clk45_srcsync0_sel_r <= '0';
        clk45_srcsync1_sel_r <= '0';
        clk45_srcsync2_sel_r <= '0';
        clk45_srcsync3_sel_r <= '0';
        clk45_srcsync4_sel_r <= '0';
        clk45_srcsync5_sel_r <= '0';
        clk45_srcsync6_sel_r <= '0';
        clk45_srcsync7_sel_r <= '0';
        clk45_pcie_psugood_r <= (others=>'0');
      end if;
    end if;
  end process p_clk45_ff;

  p_clk67_ff : process(mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      -- default assignments
      clk67_regfile_rdata  <= (others => '0');
      clk67_regfile_rvalid <= '0';

      if clk67_regfile_en = '1' and clk67_regfile_we = '0' then
        -- perform register read access
        clk67_regfile_rvalid <= '1';
        case to_integer(unsigned(clk45_regfile_addr)) is
          when REGIF_CLK67_REVISION_LO => clk67_regfile_rdata <= FIRMWARE_REVISION_VEC(15 downto 0);
          when REGIF_CLK67_REVISION_HI => clk67_regfile_rdata <= FIRMWARE_REVISION_VEC(31 downto 16);
          when others => null;
        end case;
      end if;

    end if;
  end process p_clk67_ff;

  
  u_mmi64_m_devzero : mmi64_m_devzero 
  generic map (
    MODULE_ID => X"8000000F"
  ) port map (
    -- clock and reset
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,

    -- connections to mmi64 router
    mmi64_h_dn_d_i      => mmi64_mbrouter_m_dn_d     (MMI64_MODULE_IDX_DEVZERO),
    mmi64_h_dn_valid_i  => mmi64_mbrouter_m_dn_valid (MMI64_MODULE_IDX_DEVZERO),
    mmi64_h_dn_accept_o => mmi64_mbrouter_m_dn_accept(MMI64_MODULE_IDX_DEVZERO),
    mmi64_h_dn_start_i  => mmi64_mbrouter_m_dn_start (MMI64_MODULE_IDX_DEVZERO),
    mmi64_h_dn_stop_i   => mmi64_mbrouter_m_dn_stop  (MMI64_MODULE_IDX_DEVZERO),
    mmi64_h_up_d_o      => mmi64_mbrouter_m_up_d     (MMI64_MODULE_IDX_DEVZERO),
    mmi64_h_up_valid_o  => mmi64_mbrouter_m_up_valid (MMI64_MODULE_IDX_DEVZERO),
    mmi64_h_up_accept_i => mmi64_mbrouter_m_up_accept(MMI64_MODULE_IDX_DEVZERO),
    mmi64_h_up_start_o  => mmi64_mbrouter_m_up_start (MMI64_MODULE_IDX_DEVZERO),
    mmi64_h_up_stop_o   => mmi64_mbrouter_m_up_stop  (MMI64_MODULE_IDX_DEVZERO)
  );

--
-- motherboard clock/sync multiplexers
--

  clk(0) <= ClkMux(clksel  => clk01_clk0_sel_r,
                   usersel => clk45_srcclk0_sel_r,
                   user0   => ta1_srcclk_p(0),
                   user1   => ta3_srcclk_p(0),
                   gen     => clkgen_clk(0),
                   pmb     => clk_from_pmb(0),
                   nmb     => clk_from_nmb(0));

  clk(1) <= ClkMux(clksel  => clk01_clk1_sel_r,
                   usersel => clk45_srcclk1_sel_r,
                   user0   => ta1_srcclk_p(1),
                   user1   => ta3_srcclk_p(1),
                   gen     => clkgen_clk(1),
                   pmb     => clk_from_pmb(1),
                   nmb     => clk_from_nmb(1));

  clk(2) <= ClkMux(clksel  => clk01_clk2_sel_r,
                   usersel => clk45_srcclk2_sel_r,
                   user0   => tc1_srcclk_p(0),
                   user1   => tc3_srcclk_p(0),
                   gen     => clkgen_clk(2),
                   pmb     => clk_from_pmb(2),
                   nmb     => clk_from_nmb(2));

  clk(3) <= ClkMux(clksel  => clk01_clk3_sel_r,
                   usersel => clk45_srcclk3_sel_r,
                   user0   => tc1_srcclk_p(1),
                   user1   => tc3_srcclk_p(1),
                   gen     => clkgen_clk(3),
                   pmb     => clk_from_pmb(3),
                   nmb     => clk_from_nmb(3));

  clk(4) <= ClkMux(clksel  => clk01_clk4_sel_r,
                   usersel => clk45_srcclk4_sel_r,
                   user0   => ta1_srcclk_p(2),
                   user1   => ta3_srcclk_p(2),
                   gen     => clkgen_clk(4),
                   pmb     => clk_from_pmb(4),
                   nmb     => clk_from_nmb(4));

  clk(5) <= ClkMux(clksel  => clk01_clk5_sel_r,
                   usersel => clk45_srcclk5_sel_r,
                   user0   => ta1_srcclk_p(3),
                   user1   => ta3_srcclk_p(3),
                   gen     => clkgen_clk(5),
                   pmb     => clk_from_pmb(5),
                   nmb     => clk_from_nmb(5));

  clk(6) <= ClkMux(clksel  => clk01_clk6_sel_r,
                   usersel => clk45_srcclk6_sel_r,
                   user0   => tc1_srcclk_p(2),
                   user1   => tc3_srcclk_p(2),
                   gen     => clkgen_clk(6),
                   pmb     => clk_from_pmb(6),
                   nmb     => clk_from_nmb(6));

  clk(7) <= ClkMux(clksel  => clk01_clk7_sel_r,
                   usersel => clk45_srcclk7_sel_r,
                   user0   => tc1_srcclk_p(3),
                   user1   => tc3_srcclk_p(3),
                   gen     => clkgen_clk(7),
                   pmb     => clk_from_pmb(7),
                   nmb     => clk_from_nmb(7));

  sync(0) <= ClkMux(clksel  => clk23_sync0_sel_r,
                    usersel => clk45_srcsync0_sel_r,
                    user0   => ta1_srcsync_p(0),
                    user1   => ta3_srcsync_p(0),
                    gen     => clkgen_sync(0),
                    pmb     => sync_from_pmb(0),
                    nmb     => sync_from_nmb(0));

  sync(1) <= ClkMux(clksel  => clk23_sync1_sel_r,
                    usersel => clk45_srcsync1_sel_r,
                    user0   => ta1_srcsync_p(1),
                    user1   => ta3_srcsync_p(1),
                    gen     => clkgen_sync(1),
                    pmb     => sync_from_pmb(1),
                    nmb     => sync_from_nmb(1));

  sync(2) <= ClkMux(clksel  => clk23_sync2_sel_r,
                    usersel => clk45_srcsync2_sel_r,
                    user0   => tc1_srcsync_p(0),
                    user1   => tc3_srcsync_p(0),
                    gen     => clkgen_sync(2),
                    pmb     => sync_from_pmb(2),
                    nmb     => sync_from_nmb(2));

  sync(3) <= ClkMux(clksel  => clk23_sync3_sel_r,
                    usersel => clk45_srcsync3_sel_r,
                    user0   => tc1_srcsync_p(1),
                    user1   => tc3_srcsync_p(1),
                    gen     => clkgen_sync (3),
                    pmb     => sync_from_pmb(3),
                    nmb     => sync_from_nmb(3));

  sync(4) <= ClkMux(clksel  => clk23_sync4_sel_r,
                    usersel => clk45_srcsync4_sel_r,
                    user0   => ta1_srcsync_p(2),
                    user1   => ta3_srcsync_p(2),
                    gen     => clkgen_sync(4),
                    pmb     => sync_from_pmb(4),
                    nmb     => sync_from_nmb(4));

  sync(5) <= ClkMux(clksel  => clk23_sync5_sel_r,
                    usersel => clk45_srcsync5_sel_r,
                    user0   => ta1_srcsync_p(3),
                    user1   => ta3_srcsync_p(3),
                    gen     => clkgen_sync(5),
                    pmb     => sync_from_pmb(5),
                    nmb     => sync_from_nmb(5));

  sync(6) <= ClkMux(clksel  => clk23_sync6_sel_r,
                    usersel => clk45_srcsync6_sel_r,
                    user0   => tc1_srcsync_p(2),
                    user1   => tc3_srcsync_p(2),
                    gen     => clkgen_sync(6),
                    pmb     => sync_from_pmb(6),
                    nmb     => sync_from_nmb(6));

  sync(7) <= ClkMux(clksel  => clk23_sync7_sel_r,
                    usersel => clk45_srcsync7_sel_r,
                    user0   => tc1_srcsync_p(3),
                    user1   => tc3_srcsync_p(3),
                    gen     => clkgen_sync(7),
                    pmb     => sync_from_pmb(7),
                    nmb     => sync_from_nmb(7));

end architecture beh;  -- of profpga_mb

--

library ieee;
use ieee.std_logic_1164.all;

entity mb_clock_generator is
  port (
    -- configuration clock and reset
    cfg_clk : in std_ulogic;
    cfg_rst : in std_ulogic;

    -- reference clock inputs
    refclk_125MHz_i : in std_ulogic;
    refclk_60MHz_i  : in std_ulogic;
    refclk_18MHz_i  : in std_ulogic;
    refclk_ext_i    : in std_ulogic_vector(3 downto 0);

    -- synthesized clock outputs
    srcclk_o : out std_ulogic_vector(7 downto 1);
    locked_o : out std_ulogic_vector(7 downto 1);

    -- configuration register file interface
    reg_we_i     : in  std_ulogic;
    reg_ce_i     : in  std_ulogic;
    reg_addr_i   : in  std_ulogic_vector(1 downto 0);
    reg_wdata_i  : in  std_ulogic_vector(15 downto 0);
    reg_accept_o : out std_ulogic;
    reg_rdata_o  : out std_ulogic_vector(15 downto 0);
    reg_rvalid_o : out std_ulogic
    );
end entity mb_clock_generator;

--

library ieee;
use ieee.std_logic_1164.all;

architecture beh of mb_clock_generator is
  component clkgen is
    port (
      -- reference clock inputs
      refclk_125MHz_i : in std_ulogic;
      refclk_60MHz_i  : in std_ulogic;
      refclk_18MHz_i  : in std_ulogic;
      refclk_ext_i    : in std_ulogic_vector(3 downto 0);

      -- synthesized clock outputs
      srcclk_o : out std_ulogic_vector(7 downto 1);
      locked_o : out std_ulogic_vector(7 downto 1);

      -- configuration port
      cfg_clk          : in  std_ulogic;
      cfg_rst          : in  std_ulogic;
      cfg_addr_i       : in  std_ulogic_vector(12 downto 0);
      cfg_read_i       : in  std_ulogic;
      cfg_write_i      : in  std_ulogic;
      cfg_wmask_i      : in  std_ulogic_vector(15 downto 0);
      cfg_wdata_i      : in  std_ulogic_vector(15 downto 0);
      cfg_accept_o     : out std_ulogic;
      cfg_rdata_o      : out std_ulogic_vector(15 downto 0);
      cfg_rdatavalid_o : out std_ulogic
      );
  end component clkgen;

  -- MMI command interface
  signal cfg_addr_r  : std_ulogic_vector(12 downto 0);
  signal cfg_read_r  : std_ulogic;
  signal cfg_write_r : std_ulogic;
  signal cfg_wmask_r : std_ulogic_vector(15 downto 0);
  signal cfg_wdata_r : std_ulogic_vector(15 downto 0);

  -- data outputs from core
  signal cfg_accept     : std_ulogic;
  signal cfg_rdata      : std_ulogic_vector(15 downto 0);
  signal cfg_rdatavalid : std_ulogic;

  -- read data registers
  signal cfg_rdata_r      : std_ulogic_vector(15 downto 0);  -- read data
  signal cfg_rdatawait_r  : std_ulogic;  -- flag: waiting for read data
  signal cfg_rdatavalid_r : std_ulogic;  -- read data valid
  signal cfg_wdatawait_r  : std_ulogic;  -- flag: waiting for end of write op

begin

  u_clockgen : clkgen
    port map (
      -- reference clock inputs
      refclk_125MHz_i => refclk_125MHz_i,
      refclk_60MHz_i  => refclk_60MHz_i,
      refclk_18MHz_i  => refclk_18MHz_i,
      refclk_ext_i    => refclk_ext_i,

      -- synthesized clock outputs
      srcclk_o => srcclk_o,
      locked_o => locked_o,

      -- configuration port
      cfg_clk          => cfg_clk,
      cfg_rst          => cfg_rst,
      cfg_addr_i       => cfg_addr_r,
      cfg_read_i       => cfg_read_r,
      cfg_write_i      => cfg_write_r,
      cfg_wmask_i      => cfg_wmask_r,
      cfg_wdata_i      => cfg_wdata_r,
      cfg_accept_o     => cfg_accept,
      cfg_rdata_o      => cfg_rdata,
      cfg_rdatavalid_o => cfg_rdatavalid
      );

  p_ff : process(cfg_clk)
  begin
    if rising_edge(cfg_clk) then
      -- default assignment
      cfg_rdata_r <= (others => '0');
      cfg_rdatavalid_r <= '0';
      --
      -- finish previous operations
      --

      -- invalidate control command when core has accepted it
      if cfg_accept = '1' then
        cfg_write_r <= '0';
        cfg_read_r  <= '0';
      end if;

      -- finish read operation when core provides read data
      if cfg_rdatavalid = '1' and cfg_rdatawait_r = '1' then
        cfg_rdatawait_r  <= '0';
        cfg_rdatavalid_r <= '1';
        cfg_rdata_r      <= cfg_rdata;
      end if;

      -- return write completion check (delayed: write op
      -- was still in progress when original control request arrived)
      if cfg_wdatawait_r = '1' and cfg_accept = '1' then
        cfg_rdata_r      <= x"0000";
        cfg_rdatavalid_r <= '1';
      end if;

      --
      -- process incoming control operation
      --

      if reg_ce_i = '1' then
        if reg_we_i = '1' then
          -- perform write operation
          case reg_addr_i is
            when "00" =>
              -- [0] write address register
              cfg_addr_r <= reg_wdata_i(cfg_addr_r'range);
            when "01" =>
              -- [1] write mask register
              cfg_wmask_r <= reg_wdata_i;
            when "10" =>
              -- [2] ... write command register
              cfg_wdata_r <= reg_wdata_i;
              cfg_write_r <= '1';
            when others =>
              -- more registers are not implemented
              null;
          end case;
        else
          -- perform read operation
          if reg_addr_i = "10" then
            -- initiate read access to command register
            cfg_read_r      <= '1';
            cfg_rdatawait_r <= '1';
          end if;
        end if;
      end if;

      -- reset only flag registers
      if cfg_rst = '1' then
        cfg_read_r       <= '0';
        cfg_write_r      <= '0';
        cfg_wdatawait_r  <= '0';
        cfg_rdatawait_r  <= '0';
        cfg_rdatavalid_r <= '0';
      end if;
    end if;
  end process p_ff;

  reg_rdata_o  <= cfg_rdata_r;
  reg_rvalid_o <= cfg_rdatavalid_r;
  reg_accept_o <= '1' when cfg_accept = '1' or (cfg_read_r = '0' and cfg_write_r = '0')
                  else '0';

end architecture beh;  -- of mb_clock_generator

--

library ieee;
use ieee.std_logic_1164.all;

entity clkgen is
  port (
    -- reference clock inputs
    refclk_125MHz_i : in std_ulogic;
    refclk_60MHz_i  : in std_ulogic;
    refclk_18MHz_i  : in std_ulogic;
    refclk_ext_i    : in std_ulogic_vector(3 downto 0);

    -- synthesized clock outputs
    srcclk_o : out std_ulogic_vector(7 downto 1);
    locked_o : out std_ulogic_vector(7 downto 1);

    -- configuration port
    cfg_clk          : in  std_ulogic;
    cfg_rst          : in  std_ulogic;
    cfg_addr_i       : in  std_ulogic_vector(12 downto 0);
    cfg_read_i       : in  std_ulogic;
    cfg_write_i      : in  std_ulogic;
    cfg_wmask_i      : in  std_ulogic_vector(15 downto 0);
    cfg_wdata_i      : in  std_ulogic_vector(15 downto 0);
    cfg_accept_o     : out std_ulogic;
    cfg_rdata_o      : out std_ulogic_vector(15 downto 0);
    cfg_rdatavalid_o : out std_ulogic
    );
end entity clkgen;

--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

architecture beh of clkgen is
  type     clkinselx_vector is array(natural range <>) of std_ulogic_vector(1 downto 0);
  constant ALL_ZERO : std_ulogic_vector(7 downto 1) := (others => '0');

  signal clkfb  : std_ulogic_vector(7 downto 1);
  signal clkout : std_ulogic_vector(7 downto 1);

  signal clkin1      : std_ulogic_vector(7 downto 1);
  signal clkin2      : std_ulogic_vector(7 downto 1);
  signal clkinsel0_r : std_ulogic_vector(7 downto 1);
  signal clkinsel1_r : std_ulogic_vector(7 downto 1);
  signal clkinselx_r : clkinselx_vector(7 downto 1);
  signal refclk_ext  : std_ulogic_vector(7 downto 1);
  signal mmcm_rst_r  : std_ulogic_vector(7 downto 1) := (others => '1');  -- use default assignment to eliminate simulation error

  signal cfg_read_r       : std_ulogic;
  signal cfg_bitwrite_r   : std_ulogic;
  signal cfg_daddr_r      : std_logic_vector(6 downto 0);
  signal cfg_wmask_r      : std_ulogic_vector(15 downto 0);
  signal cfg_wdata_r      : std_logic_vector(15 downto 0);
  signal cfg_rdata_r      : std_ulogic_vector(15 downto 0);
  signal cfg_rdatavalid_r : std_ulogic;
  signal cfg_dwe_r        : std_ulogic_vector(7 downto 1);
  signal cfg_den_r        : std_ulogic_vector(7 downto 1);
  signal cfg_do           : std_logic_vector(7*16+15 downto 1*16);
  signal cfg_drdy         : std_ulogic_vector(7 downto 1);
  signal cfg_busy_r       : std_ulogic_vector(7 downto 1);

  signal locked        : std_ulogic_vector(7 downto 1);
  signal locked_meta_r : std_ulogic_vector(7 downto 1);
  signal locked_r      : std_ulogic_vector(7 downto 1);
begin
  cfg_accept_o     <= '1' when cfg_busy_r = ALL_ZERO else '0';
  cfg_rdata_o      <= cfg_rdata_r;
  cfg_rdatavalid_o <= cfg_rdatavalid_r;

  p_ff : process (cfg_clk)
    variable rdata      : std_ulogic_vector(15 downto 0);
    variable curr       : std_ulogic_vector(7 downto 0);
    variable clkinsel_v : std_ulogic_vector(2 downto 0);
  begin
    if rising_edge(cfg_clk) then

      -- write and read command are valid only for a single cycle
      cfg_den_r        <= (others => '0');
      cfg_dwe_r        <= (others => '0');
      rdata            := (others => '0');
      cfg_rdatavalid_r <= '0';

      -- accept transfer when all DRP ports are idle
      if cfg_busy_r = ALL_ZERO and (cfg_read_i = '1' or cfg_write_i = '1')
      then
        -- decode current MMCM
        curr := x"00";
        for i in 0 to 7 loop
          if i = unsigned(cfg_addr_i(12 downto 10)) then curr(i) := '1'; end if;
        end loop;

        if cfg_addr_i(9 downto 3) = "0000000" then  -- register 0 --> my MMCM control register

          -- register port
          for i in 7 downto 1 loop  -- registers 1 to 7: input clock selectors for each MMCM
            if curr(i) = '1' then
              rdata(15)         := mmcm_rst_r(i);
              rdata(14)         := locked_r(i);
              rdata(3 downto 2) := clkinselx_r(i);
              rdata(1)          := clkinsel1_r(i);
              rdata(0)          := clkinsel0_r(i);
              if cfg_write_i = '1' then
                if cfg_wmask_i(15) = '1' then mmcm_rst_r(i) <= cfg_wdata_i(15); end if;
                if cfg_wmask_i(2 downto 0) = "111" then
                  clkinsel_v := cfg_wdata_i(2 downto 0);
                  case clkinsel_v is
                    when "000" =>       -- refclk_125mhz
                      clkinsel0_r(i) <= '0';
                      clkinsel1_r(i) <= '0';
                      clkinselx_r(i) <= "--";
                    when "001" =>       -- refclk_60mhz
                      clkinsel0_r(i) <= '0';
                      clkinsel1_r(i) <= '1';
                      clkinselx_r(i) <= "--";
                    when "010" =>       -- refclk_18_432mhz
                      clkinsel0_r(i) <= '1';
                      clkinsel1_r(i) <= '0';
                      clkinselx_r(i) <= "--";
                    when "011" =>       -- invalid
                      clkinsel0_r(i) <= '-';
                      clkinsel1_r(i) <= '-';
                      clkinselx_r(i) <= "--";
                    when others =>      -- refclk_ext
                      clkinsel0_r(i) <= '1';
                      clkinsel1_r(i) <= '1';
                      clkinselx_r(i) <= cfg_wdata_i(1 downto 0);
                  end case;
                end if;
              end if;
            end if;
          end loop;

          if cfg_read_i = '1' then cfg_rdatavalid_r <= '1'; end if;

          -- Note: not setting any cfg_busy_r bits --> immediately ready for next op
        else
          cfg_daddr_r <= std_logic_vector(cfg_addr_i(9 downto 3));
          cfg_wmask_r <= cfg_wmask_i;
          cfg_wdata_r <= std_logic_vector(cfg_wdata_i);
          cfg_den_r   <= curr(7 downto 1);
          cfg_busy_r  <= curr(7 downto 1);

          -- decode write operation
          cfg_bitwrite_r <= '0';
          cfg_read_r     <= cfg_read_i;
          cfg_dwe_r      <= (others => '0');
          if cfg_write_i = '1' then
            if cfg_wmask_i = x"FFFF" then     -- write all bits
              cfg_dwe_r <= curr(7 downto 1);  -- write immediately
            else
              cfg_bitwrite_r <= '1';  -- first read current value, write later
            end if;
          end if;
        end if;
      end if;

      -- detect when DRP operation is done
      for i in 7 downto 1 loop
        if cfg_busy_r(i) = '1' then  -- use cfg_busy_r as MUX control (better timing)
          rdata := rdata or std_ulogic_vector(cfg_do(16*i+15 downto 16*i));
        end if;
        if cfg_drdy(i) = '1' and cfg_bitwrite_r = '0' then
          -- validata transfer as soon as MMCM is ready
          cfg_busy_r(i) <= '0';
        end if;
      end loop;
      cfg_rdata_r <= rdata;

      if cfg_bitwrite_r = '1' and cfg_drdy /= ALL_ZERO then
        -- read cycle for bit write operation complete
        for i in 0 to 15 loop
          if cfg_wmask_r(i) = '0' then  -- do not modify this bit, i.e. keep old value
            cfg_wdata_r(i) <= rdata(i);
          end if;
        end loop;
        -- reissue the transfer, this time write
        cfg_den_r      <= cfg_busy_r;
        cfg_dwe_r      <= cfg_busy_r;
        cfg_bitwrite_r <= '0';
      end if;

      if cfg_read_r = '1' and cfg_drdy /= ALL_ZERO then
        cfg_rdatavalid_r <= '1';
        cfg_read_r       <= '0';
      end if;

      -- reset
      if cfg_rst = '1' then
        -- initial clock selector: 50 MHz
        clkinsel0_r <= (others => '0');
        clkinsel1_r <= (others => '0');
        clkinselx_r <= (others => "00");
        mmcm_rst_r  <= (others => '1');

        -- clear all MMIO bits
        cfg_read_r       <= '0';
        cfg_bitwrite_r   <= '0';
        cfg_daddr_r      <= (others => '0');
        cfg_wmask_r      <= x"0000";
        cfg_wdata_r      <= x"0000";
        cfg_rdata_r      <= x"0000";
        cfg_dwe_r        <= ALL_ZERO;
        cfg_den_r        <= ALL_ZERO;
        cfg_rdatavalid_r <= '0';
        cfg_busy_r       <= ALL_ZERO;
      end if;
    end if;
  end process p_ff;

  g_mmcm : for i in 7 downto 1 generate
    MUX_EXT : refclk_ext(i) <= refclk_ext_i(0) when clkinselx_r(i) = "00"
                                else refclk_ext_i(1) when clkinselx_r(i) = "01"
                                else refclk_ext_i(2) when clkinselx_r(i) = "10"
                                else refclk_ext_i(3);
    MUX_EXOS : clkin2(i) <= refclk_125MHz_i when clkinsel1_r(i) = '0' else refclk_60MHz_i;
    MUX_FREQ : clkin1(i) <= refclk_18MHz_i  when clkinsel1_r(i) = '0' else refclk_ext(i);

    u_mmcm : MMCM_ADV
      generic map (
        BANDWIDTH        => "OPTIMIZED",
        DIVCLK_DIVIDE    => 1,
        CLKFBOUT_MULT_F  => 8.0,  -- calculates to 1000 MHz
        CLKIN1_PERIOD    => 8.0,  -- need to set all clock frequencies to max = 125 MHz
        CLKIN2_PERIOD    => 8.0,  -- (otherwise XST refuses to synthesize MMCM)
        CLKOUT0_DIVIDE_F => 4.0   -- calculates to 250 MHz --> maximum supported value
        ) port map (
          clkfbout     => clkfb(i),
          clkout0      => clkout(i),
          clkout1      => open,
          clkout2      => open,
          clkout3      => open,
          clkout4      => open,
          clkout5      => open,
          clkout6      => open,
          clkout0b     => open,
          clkout1b     => open,
          clkout2b     => open,
          clkout3b     => open,
          clkinstopped => open,
          clkfbstopped => open,
          clkfboutb    => open,
          psdone       => open,
          do           => cfg_do(i*16+15 downto i*16),
          drdy         => cfg_drdy(i),
          locked       => locked(i),
          clkfbin      => clkfb(i),
          clkin1       => clkin1(i),
          clkin2       => clkin2(i),
          clkinsel     => clkinsel0_r(i),
          daddr        => cfg_daddr_r,
          dclk         => cfg_clk,
          den          => cfg_den_r(i),
          di           => cfg_wdata_r,
          dwe          => cfg_dwe_r(i),
          psclk        => cfg_clk,
          psen         => '0',
          psincdec     => '0',
          pwrdwn       => '0',
          rst          => mmcm_rst_r(i)
          );
  end generate;

  locked_meta_r <= locked        when rising_edge(cfg_clk);
  locked_r      <= locked_meta_r when rising_edge(cfg_clk);

  locked_o      <= locked;
  srcclk_o      <= clkout and locked;

end architecture beh;  -- of clkgen
