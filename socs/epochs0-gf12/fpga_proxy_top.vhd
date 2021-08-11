-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- FPGA Proxy for chip testing and DDR access
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
library unisim;
use unisim.VCOMPONENTS.all;
-- pragma translate_off
use work.sim.all;
use std.textio.all;
use work.stdio.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.jtag_pkg.all;


ENTITY FPGA_PROXY_TOP IS

  GENERIC (
    SIMULATION : BOOLEAN                               := FALSE;
    JTAG_TRACE : INTEGER RANGE -1 TO CFG_TILES_NUM - 1 := -1);
  PORT (
    RESET             : IN    STD_ULOGIC;  -- GLOBAL FPGA RESET (ACTIVE HIGH)
    CHIP_RESET        : OUT   STD_ULOGIC;  -- CHIP RESET (ACTIVE HIGH)
    -- BACKUP CLOCKS
    EXT_CLK_NOC       : OUT   STD_LOGIC;
    EXT_CLK_IO        : OUT   STD_LOGIC;
    EXT_CLK_CPU       : OUT   STD_LOGIC;
    EXT_CLK_MEM       : OUT   STD_LOGIC;
    EXT_CLK_ACC0      : OUT   STD_LOGIC;
    EXT_CLK_ACC1      : OUT   STD_LOGIC;
    -- MAIN CLOCK
    MAIN_CLK_P        : IN    STD_ULOGIC;  -- 100 MHZ CLOCK
    MAIN_CLK_N        : IN    STD_ULOGIC;  -- 100 MHZ CLOCK
    -- MEMORY LINK
    FPGA_DATA         : INOUT STD_LOGIC_VECTOR(CFG_NMEM_TILE * (ARCH_BITS) - 1 DOWNTO 0);
    FPGA_VALID_IN     : OUT   STD_LOGIC_VECTOR(CFG_NMEM_TILE - 1 DOWNTO 0);
    FPGA_VALID_OUT    : IN    STD_LOGIC_VECTOR(CFG_NMEM_TILE - 1 DOWNTO 0);
    FPGA_CLK_IN       : OUT   STD_LOGIC_VECTOR(CFG_NMEM_TILE - 1 DOWNTO 0);
    FPGA_CLK_OUT      : IN    STD_LOGIC_VECTOR(CFG_NMEM_TILE - 1 DOWNTO 0);
    FPGA_CREDIT_IN    : OUT   STD_LOGIC_VECTOR(CFG_NMEM_TILE - 1 DOWNTO 0);
    FPGA_CREDIT_OUT   : IN    STD_LOGIC_VECTOR(CFG_NMEM_TILE - 1 DOWNTO 0);
    -- TEST INTERFACE
    TDI               : OUT   STD_LOGIC_VECTOR(0 TO CFG_TILES_NUM - 1);
    TDO               : IN    STD_LOGIC_VECTOR(0 TO CFG_TILES_NUM - 1);
    TMS               : OUT   STD_LOGIC;
    TCLK              : OUT   STD_LOGIC;
    -- ETHERNET SIGNALS
    RESET_O2          : OUT   STD_ULOGIC;
    ETX_CLK           : IN    STD_ULOGIC;
    ERX_CLK           : IN    STD_ULOGIC;
    ERXD              : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
    ERX_DV            : IN    STD_ULOGIC;
    ERX_ER            : IN    STD_ULOGIC;
    ERX_COL           : IN    STD_ULOGIC;
    ERX_CRS           : IN    STD_ULOGIC;
    ETXD              : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
    ETX_EN            : OUT   STD_ULOGIC;
    ETX_ER            : OUT   STD_ULOGIC;
    EMDC              : OUT   STD_ULOGIC;
    EMDIO             : INOUT STD_LOGIC;
    -- DDR
    CLK_REF_P         : IN    STD_ULOGIC;  -- 200 MHZ CLOCK
    CLK_REF_N         : IN    STD_ULOGIC;  -- 200 MHZ CLOCK
    -- DDR0
    C0_SYS_CLK_P      : IN    STD_LOGIC;   -- 200 MHZ CLOCK
    C0_SYS_CLK_N      : IN    STD_LOGIC;   -- 200 MHZ CLOCK
    C0_DDR3_DQ        : INOUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    C0_DDR3_DQS_P     : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    C0_DDR3_DQS_N     : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    C0_DDR3_ADDR      : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
    C0_DDR3_BA        : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
    C0_DDR3_RAS_N     : OUT   STD_LOGIC;
    C0_DDR3_CAS_N     : OUT   STD_LOGIC;
    C0_DDR3_WE_N      : OUT   STD_LOGIC;
    C0_DDR3_RESET_N   : OUT   STD_LOGIC;
    C0_DDR3_CK_P      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR3_CK_N      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR3_CKE       : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR3_CS_N      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR3_DM        : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    C0_DDR3_ODT       : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_CALIB_COMPLETE : OUT   STD_LOGIC;
    C0_DIAGNOSTIC_LED : OUT   STD_ULOGIC;
    -- DDR1
    C1_SYS_CLK_P      : IN    STD_LOGIC;   -- 200 MHZ CLOCK
    C1_SYS_CLK_N      : IN    STD_LOGIC;   -- 200 MHZ CLOCK
    C1_DDR3_DQ        : INOUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    C1_DDR3_DQS_P     : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    C1_DDR3_DQS_N     : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    C1_DDR3_ADDR      : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
    C1_DDR3_BA        : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
    C1_DDR3_RAS_N     : OUT   STD_LOGIC;
    C1_DDR3_CAS_N     : OUT   STD_LOGIC;
    C1_DDR3_WE_N      : OUT   STD_LOGIC;
    C1_DDR3_RESET_N   : OUT   STD_LOGIC;
    C1_DDR3_CK_P      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C1_DDR3_CK_N      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C1_DDR3_CKE       : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C1_DDR3_CS_N      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C1_DDR3_DM        : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    C1_DDR3_ODT       : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C1_CALIB_COMPLETE : OUT   STD_LOGIC;
    C1_DIAGNOSTIC_LED : OUT   STD_ULOGIC;
    -- DDR2
    C2_SYS_CLK_P      : IN    STD_LOGIC;   -- 200 MHZ CLOCK
    C2_SYS_CLK_N      : IN    STD_LOGIC;   -- 200 MHZ CLOCK
    C2_DDR3_DQ        : INOUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    C2_DDR3_DQS_P     : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    C2_DDR3_DQS_N     : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    C2_DDR3_ADDR      : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
    C2_DDR3_BA        : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
    C2_DDR3_RAS_N     : OUT   STD_LOGIC;
    C2_DDR3_CAS_N     : OUT   STD_LOGIC;
    C2_DDR3_WE_N      : OUT   STD_LOGIC;
    C2_DDR3_RESET_N   : OUT   STD_LOGIC;
    C2_DDR3_CK_P      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C2_DDR3_CK_N      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C2_DDR3_CKE       : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C2_DDR3_CS_N      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C2_DDR3_DM        : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    C2_DDR3_ODT       : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C2_CALIB_COMPLETE : OUT   STD_LOGIC;
    C2_DIAGNOSTIC_LED : OUT   STD_ULOGIC;
    -- DDR3
    C3_SYS_CLK_P      : IN    STD_LOGIC;   -- 200 MHZ CLOCK
    C3_SYS_CLK_N      : IN    STD_LOGIC;   -- 200 MHZ CLOCK
    C3_DDR3_DQ        : INOUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    C3_DDR3_DQS_P     : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    C3_DDR3_DQS_N     : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    C3_DDR3_ADDR      : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
    C3_DDR3_BA        : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
    C3_DDR3_RAS_N     : OUT   STD_LOGIC;
    C3_DDR3_CAS_N     : OUT   STD_LOGIC;
    C3_DDR3_WE_N      : OUT   STD_LOGIC;
    C3_DDR3_RESET_N   : OUT   STD_LOGIC;
    C3_DDR3_CK_P      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C3_DDR3_CK_N      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C3_DDR3_CKE       : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C3_DDR3_CS_N      : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C3_DDR3_DM        : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    C3_DDR3_ODT       : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
    C3_CALIB_COMPLETE : OUT   STD_LOGIC;
    C3_DIAGNOSTIC_LED : OUT   STD_ULOGIC;
    LED_RED           : OUT   STD_ULOGIC;
    LED_GREEN         : OUT   STD_ULOGIC;
    LED_BLUE          : OUT   STD_ULOGIC;
    LED_YELLOW        : OUT   STD_ULOGIC
    );
END ENTITY FPGA_PROXY_TOP;

ARCHITECTURE RTL OF FPGA_PROXY_TOP IS

  CONSTANT FPGA_PROXY_TECH : INTEGER := VIRTEX7;
  CONSTANT FPGA_PROXY_FREQ : INTEGER := 100000;  -- FPGA FREQUENCY IN KHZ
  CONSTANT MAX_NMEM_TILES  : INTEGER := 4;

  COMPONENT AHB2MIG_7SERIES_PROFPGA
    GENERIC(
      HINDEX : INTEGER := 0;
      HADDR  : INTEGER := 0;
      HMASK  : INTEGER := 16#F00#
      );
    PORT(
      APP_ADDR          : OUT STD_LOGIC_VECTOR(28 DOWNTO 0);
      APP_CMD           : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      APP_EN            : OUT STD_LOGIC;
      APP_WDF_DATA      : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
      APP_WDF_END       : OUT STD_LOGIC;
      APP_WDF_MASK      : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      APP_WDF_WREN      : OUT STD_LOGIC;
      APP_RD_DATA       : IN  STD_LOGIC_VECTOR(511 DOWNTO 0);
      APP_RD_DATA_END   : IN  STD_LOGIC;
      APP_RD_DATA_VALID : IN  STD_LOGIC;
      APP_RDY           : IN  STD_LOGIC;
      APP_WDF_RDY       : IN  STD_LOGIC;
      AHBSO             : OUT AHB_SLV_OUT_TYPE;
      AHBSI             : IN  AHB_SLV_IN_TYPE;
      CLK_AMBA          : IN  STD_LOGIC;
      RST_N_SYN         : IN  STD_LOGIC
      );
  END COMPONENT;

  COMPONENT MIG IS
    PORT (
      C0_DDR3_DQ             : INOUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      C0_DDR3_ADDR           : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
      C0_DDR3_BA             : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
      C0_DDR3_RAS_N          : OUT   STD_LOGIC;
      C0_DDR3_CAS_N          : OUT   STD_LOGIC;
      C0_DDR3_WE_N           : OUT   STD_LOGIC;
      C0_DDR3_RESET_N        : OUT   STD_LOGIC;
      C0_DDR3_DQS_N          : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      C0_DDR3_DQS_P          : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      C0_DDR3_CK_P           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C0_DDR3_CK_N           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C0_DDR3_CKE            : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C0_DDR3_CS_N           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C0_DDR3_DM             : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
      C0_DDR3_ODT            : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C1_DDR3_DQ             : INOUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      C1_DDR3_ADDR           : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
      C1_DDR3_BA             : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
      C1_DDR3_RAS_N          : OUT   STD_LOGIC;
      C1_DDR3_CAS_N          : OUT   STD_LOGIC;
      C1_DDR3_WE_N           : OUT   STD_LOGIC;
      C1_DDR3_RESET_N        : OUT   STD_LOGIC;
      C1_DDR3_DQS_N          : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      C1_DDR3_DQS_P          : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      C1_DDR3_CK_P           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C1_DDR3_CK_N           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C1_DDR3_CKE            : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C1_DDR3_CS_N           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C1_DDR3_DM             : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
      C1_DDR3_ODT            : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C2_DDR3_DQ             : INOUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      C2_DDR3_ADDR           : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
      C2_DDR3_BA             : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
      C2_DDR3_RAS_N          : OUT   STD_LOGIC;
      C2_DDR3_CAS_N          : OUT   STD_LOGIC;
      C2_DDR3_WE_N           : OUT   STD_LOGIC;
      C2_DDR3_RESET_N        : OUT   STD_LOGIC;
      C2_DDR3_DQS_N          : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      C2_DDR3_DQS_P          : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      C2_DDR3_CK_P           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C2_DDR3_CK_N           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C2_DDR3_CKE            : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C2_DDR3_CS_N           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C2_DDR3_DM             : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
      C2_DDR3_ODT            : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C3_DDR3_DQ             : INOUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      C3_DDR3_ADDR           : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
      C3_DDR3_BA             : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
      C3_DDR3_RAS_N          : OUT   STD_LOGIC;
      C3_DDR3_CAS_N          : OUT   STD_LOGIC;
      C3_DDR3_WE_N           : OUT   STD_LOGIC;
      C3_DDR3_RESET_N        : OUT   STD_LOGIC;
      C3_DDR3_DQS_N          : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      C3_DDR3_DQS_P          : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      C3_DDR3_CK_P           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C3_DDR3_CK_N           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C3_DDR3_CKE            : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C3_DDR3_CS_N           : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C3_DDR3_DM             : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
      C3_DDR3_ODT            : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
      C0_APP_ADDR            : IN    STD_LOGIC_VECTOR(28 DOWNTO 0);
      C0_APP_CMD             : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
      C0_APP_EN              : IN    STD_LOGIC;
      C0_APP_WDF_DATA        : IN    STD_LOGIC_VECTOR(511 DOWNTO 0);
      C0_APP_WDF_END         : IN    STD_LOGIC;
      C0_APP_WDF_MASK        : IN    STD_LOGIC_VECTOR(63 DOWNTO 0);
      C0_APP_WDF_WREN        : IN    STD_LOGIC;
      C0_APP_RD_DATA         : OUT   STD_LOGIC_VECTOR(511 DOWNTO 0);
      C0_APP_RD_DATA_END     : OUT   STD_LOGIC;
      C0_APP_RD_DATA_VALID   : OUT   STD_LOGIC;
      C0_APP_RDY             : OUT   STD_LOGIC;
      C0_APP_WDF_RDY         : OUT   STD_LOGIC;
      C0_APP_SR_REQ          : IN    STD_LOGIC;
      C0_APP_REF_REQ         : IN    STD_LOGIC;
      C0_APP_ZQ_REQ          : IN    STD_LOGIC;
      C0_APP_SR_ACTIVE       : OUT   STD_LOGIC;
      C0_APP_REF_ACK         : OUT   STD_LOGIC;
      C0_APP_ZQ_ACK          : OUT   STD_LOGIC;
      C0_SYS_CLK_P           : IN    STD_LOGIC;
      C0_SYS_CLK_N           : IN    STD_LOGIC;
      C1_APP_ADDR            : IN    STD_LOGIC_VECTOR(28 DOWNTO 0);
      C1_APP_CMD             : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
      C1_APP_EN              : IN    STD_LOGIC;
      C1_APP_WDF_DATA        : IN    STD_LOGIC_VECTOR(511 DOWNTO 0);
      C1_APP_WDF_END         : IN    STD_LOGIC;
      C1_APP_WDF_MASK        : IN    STD_LOGIC_VECTOR(63 DOWNTO 0);
      C1_APP_WDF_WREN        : IN    STD_LOGIC;
      C1_APP_RD_DATA         : OUT   STD_LOGIC_VECTOR(511 DOWNTO 0);
      C1_APP_RD_DATA_END     : OUT   STD_LOGIC;
      C1_APP_RD_DATA_VALID   : OUT   STD_LOGIC;
      C1_APP_RDY             : OUT   STD_LOGIC;
      C1_APP_WDF_RDY         : OUT   STD_LOGIC;
      C1_APP_SR_REQ          : IN    STD_LOGIC;
      C1_APP_REF_REQ         : IN    STD_LOGIC;
      C1_APP_ZQ_REQ          : IN    STD_LOGIC;
      C1_APP_SR_ACTIVE       : OUT   STD_LOGIC;
      C1_APP_REF_ACK         : OUT   STD_LOGIC;
      C1_APP_ZQ_ACK          : OUT   STD_LOGIC;
      C1_SYS_CLK_P           : IN    STD_LOGIC;
      C1_SYS_CLK_N           : IN    STD_LOGIC;
      C2_APP_ADDR            : IN    STD_LOGIC_VECTOR(28 DOWNTO 0);
      C2_APP_CMD             : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
      C2_APP_EN              : IN    STD_LOGIC;
      C2_APP_WDF_DATA        : IN    STD_LOGIC_VECTOR(511 DOWNTO 0);
      C2_APP_WDF_END         : IN    STD_LOGIC;
      C2_APP_WDF_MASK        : IN    STD_LOGIC_VECTOR(63 DOWNTO 0);
      C2_APP_WDF_WREN        : IN    STD_LOGIC;
      C2_APP_RD_DATA         : OUT   STD_LOGIC_VECTOR(511 DOWNTO 0);
      C2_APP_RD_DATA_END     : OUT   STD_LOGIC;
      C2_APP_RD_DATA_VALID   : OUT   STD_LOGIC;
      C2_APP_RDY             : OUT   STD_LOGIC;
      C2_APP_WDF_RDY         : OUT   STD_LOGIC;
      C2_APP_SR_REQ          : IN    STD_LOGIC;
      C2_APP_REF_REQ         : IN    STD_LOGIC;
      C2_APP_ZQ_REQ          : IN    STD_LOGIC;
      C2_APP_SR_ACTIVE       : OUT   STD_LOGIC;
      C2_APP_REF_ACK         : OUT   STD_LOGIC;
      C2_APP_ZQ_ACK          : OUT   STD_LOGIC;
      C2_SYS_CLK_P           : IN    STD_LOGIC;
      C2_SYS_CLK_N           : IN    STD_LOGIC;
      C3_APP_ADDR            : IN    STD_LOGIC_VECTOR(28 DOWNTO 0);
      C3_APP_CMD             : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
      C3_APP_EN              : IN    STD_LOGIC;
      C3_APP_WDF_DATA        : IN    STD_LOGIC_VECTOR(511 DOWNTO 0);
      C3_APP_WDF_END         : IN    STD_LOGIC;
      C3_APP_WDF_MASK        : IN    STD_LOGIC_VECTOR(63 DOWNTO 0);
      C3_APP_WDF_WREN        : IN    STD_LOGIC;
      C3_APP_RD_DATA         : OUT   STD_LOGIC_VECTOR(511 DOWNTO 0);
      C3_APP_RD_DATA_END     : OUT   STD_LOGIC;
      C3_APP_RD_DATA_VALID   : OUT   STD_LOGIC;
      C3_APP_RDY             : OUT   STD_LOGIC;
      C3_APP_WDF_RDY         : OUT   STD_LOGIC;
      C3_APP_SR_REQ          : IN    STD_LOGIC;
      C3_APP_REF_REQ         : IN    STD_LOGIC;
      C3_APP_ZQ_REQ          : IN    STD_LOGIC;
      C3_APP_SR_ACTIVE       : OUT   STD_LOGIC;
      C3_APP_REF_ACK         : OUT   STD_LOGIC;
      C3_APP_ZQ_ACK          : OUT   STD_LOGIC;
      C3_SYS_CLK_P           : IN    STD_LOGIC;
      C3_SYS_CLK_N           : IN    STD_LOGIC;
      CLK_REF_P              : IN    STD_LOGIC;  -- 200 MHZ CLOCK
      CLK_REF_N              : IN    STD_LOGIC;  -- 200 MHZ CLOCK
      C0_UI_CLK              : OUT   STD_LOGIC;
      C0_UI_CLK_SYNC_RST     : OUT   STD_LOGIC;
      C0_INIT_CALIB_COMPLETE : OUT   STD_LOGIC;
      C0_DEVICE_TEMP         : OUT   STD_LOGIC_VECTOR(11 DOWNTO 0);
      C1_UI_CLK              : OUT   STD_LOGIC;
      C1_UI_CLK_SYNC_RST     : OUT   STD_LOGIC;
      C1_INIT_CALIB_COMPLETE : OUT   STD_LOGIC;
      C1_DEVICE_TEMP         : OUT   STD_LOGIC_VECTOR(11 DOWNTO 0);
      C2_UI_CLK              : OUT   STD_LOGIC;
      C2_UI_CLK_SYNC_RST     : OUT   STD_LOGIC;
      C2_INIT_CALIB_COMPLETE : OUT   STD_LOGIC;
      C2_DEVICE_TEMP         : OUT   STD_LOGIC_VECTOR(11 DOWNTO 0);
      C3_UI_CLK              : OUT   STD_LOGIC;
      C3_UI_CLK_SYNC_RST     : OUT   STD_LOGIC;
      C3_INIT_CALIB_COMPLETE : OUT   STD_LOGIC;
      C3_DEVICE_TEMP         : OUT   STD_LOGIC_VECTOR(11 DOWNTO 0);
      SYS_RST                : IN    STD_LOGIC
      );
  END COMPONENT MIG;

  FUNCTION SET_DDR_INDEX (
    CONSTANT N : INTEGER RANGE 0 TO 3)
    RETURN INTEGER IS
  BEGIN
    IF N > (CFG_NMEM_TILE - 1) THEN
      RETURN CFG_NMEM_TILE - 1;
    ELSE
      RETURN N;
    END IF;
  END SET_DDR_INDEX;

  CONSTANT THIS_DDR_INDEX : ATTRIBUTE_VECTOR(0 TO 3) := (
    0 => SET_DDR_INDEX(0),
    1 => SET_DDR_INDEX(1),
    2 => SET_DDR_INDEX(2),
    3 => SET_DDR_INDEX(3)
    );


  -- CREATE SOCMAP ARRAY FOR THIS INVERSION AS WELL AS FOR SELECTED CLOCK DIV/BACKUP AND TDI/TDO
  -- EPOCHS-0/1 SPECIFIC
  -- MEMORY TILE 0 - FPGA LINK 0
  -- MEMORY TILE 1 - FPGA LINK 1
  -- MEMORY TILE 2 - FPGA LINK 3
  -- MEMORY TILE 3 - FPGA LINK 2
  FUNCTION MEMSWAP (
    CONSTANT N : INTEGER RANGE 0 TO 3)
    RETURN INTEGER IS
  BEGIN
    IF N = 2 THEN
      RETURN 3;
    ELSIF N = 3 THEN
      RETURN 2;
    ELSE
      RETURN N;
    END IF;
  END MEMSWAP;

  -----------------------------------------------------------------------------
  -- CLOCK AND RESET

  -- BACKUP CLOCKS
  SIGNAL EXT_CLK : STD_LOGIC_VECTOR(0 TO CFG_TILES_NUM - 1);

  -- MAIN CLOCK (EDCL CLOCK)
  SIGNAL MAIN_CLK                         : STD_ULOGIC;

  -- DDR CLOCKS
  SIGNAL SYS_CLK  : STD_LOGIC_VECTOR(0 TO MAX_NMEM_TILES - 1) := (OTHERS => '0');
  SIGNAL SYS_RST  : STD_LOGIC_VECTOR(0 TO MAX_NMEM_TILES - 1);

  -- RESETS
  SIGNAL RSTN, RSTRAW : STD_ULOGIC;
  SIGNAL LOCK, RST                                  : STD_ULOGIC;
  SIGNAL MIGRSTN, MIGRSTN_1, MIGRSTN_2, MIGRSTN_3   : STD_LOGIC;

  -- ESP BACKUP CLOCKS
  SIGNAL EXT_CLK_NOC_INT : STD_LOGIC := '0';
  -- ESP CLOCK MONITORS
  SIGNAL EXT_CLK_INT : STD_LOGIC_VECTOR(0 TO CFG_TILES_NUM - 1) := (OTHERS  => '0');

  -----------------------------------------------------------------------------
  -- DDRS DOMAIN
  -- MIG APP
  SIGNAL C0_APP_ADDR          : STD_LOGIC_VECTOR(28 DOWNTO 0);
  SIGNAL C0_APP_CMD           : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL C0_APP_EN            : STD_ULOGIC;
  SIGNAL C0_APP_WDF_DATA      : STD_LOGIC_VECTOR(511 DOWNTO 0);
  SIGNAL C0_APP_WDF_END       : STD_ULOGIC;
  SIGNAL C0_APP_WDF_MASK      : STD_LOGIC_VECTOR(63 DOWNTO 0); 
  SIGNAL C0_APP_WDF_WREN      : STD_ULOGIC;
  SIGNAL C0_APP_RD_DATA       : STD_LOGIC_VECTOR(511 DOWNTO 0);
  SIGNAL C0_APP_RD_DATA_END   : STD_ULOGIC;
  SIGNAL C0_APP_RD_DATA_VALID : STD_ULOGIC;
  SIGNAL C0_APP_RDY           : STD_ULOGIC;
  SIGNAL C0_APP_WDF_RDY       : STD_ULOGIC;
  SIGNAL C1_APP_ADDR          : STD_LOGIC_VECTOR(28 DOWNTO 0);
  SIGNAL C1_APP_CMD           : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL C1_APP_EN            : STD_ULOGIC;
  SIGNAL C1_APP_WDF_DATA      : STD_LOGIC_VECTOR(511 DOWNTO 0);
  SIGNAL C1_APP_WDF_END       : STD_ULOGIC;
  SIGNAL C1_APP_WDF_MASK      : STD_LOGIC_VECTOR(63 DOWNTO 0); 
  SIGNAL C1_APP_WDF_WREN      : STD_ULOGIC;
  SIGNAL C1_APP_RD_DATA       : STD_LOGIC_VECTOR(511 DOWNTO 0);
  SIGNAL C1_APP_RD_DATA_END   : STD_ULOGIC;
  SIGNAL C1_APP_RD_DATA_VALID : STD_ULOGIC;
  SIGNAL C1_APP_RDY           : STD_ULOGIC;
  SIGNAL C1_APP_WDF_RDY       : STD_ULOGIC;
  SIGNAL C2_APP_ADDR          : STD_LOGIC_VECTOR(28 DOWNTO 0);
  SIGNAL C2_APP_CMD           : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL C2_APP_EN            : STD_ULOGIC;
  SIGNAL C2_APP_WDF_DATA      : STD_LOGIC_VECTOR(511 DOWNTO 0);
  SIGNAL C2_APP_WDF_END       : STD_ULOGIC;
  SIGNAL C2_APP_WDF_MASK      : STD_LOGIC_VECTOR(63 DOWNTO 0); 
  SIGNAL C2_APP_WDF_WREN      : STD_ULOGIC;
  SIGNAL C2_APP_RD_DATA       : STD_LOGIC_VECTOR(511 DOWNTO 0);
  SIGNAL C2_APP_RD_DATA_END   : STD_ULOGIC;
  SIGNAL C2_APP_RD_DATA_VALID : STD_ULOGIC;
  SIGNAL C2_APP_RDY           : STD_ULOGIC;
  SIGNAL C2_APP_WDF_RDY       : STD_ULOGIC;
  SIGNAL C3_APP_ADDR          : STD_LOGIC_VECTOR(28 DOWNTO 0);
  SIGNAL C3_APP_CMD           : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL C3_APP_EN            : STD_ULOGIC;
  SIGNAL C3_APP_WDF_DATA      : STD_LOGIC_VECTOR(511 DOWNTO 0);
  SIGNAL C3_APP_WDF_END       : STD_ULOGIC;
  SIGNAL C3_APP_WDF_MASK      : STD_LOGIC_VECTOR(63 DOWNTO 0); 
  SIGNAL C3_APP_WDF_WREN      : STD_ULOGIC;
  SIGNAL C3_APP_RD_DATA       : STD_LOGIC_VECTOR(511 DOWNTO 0);
  SIGNAL C3_APP_RD_DATA_END   : STD_ULOGIC;
  SIGNAL C3_APP_RD_DATA_VALID : STD_ULOGIC;
  SIGNAL C3_APP_RDY           : STD_ULOGIC;
  SIGNAL C3_APP_WDF_RDY       : STD_ULOGIC;

  -- MIG CLOCK AND DIAGNOSTIC
  SIGNAL C0_CALIB_DONE        : STD_ULOGIC;
  SIGNAL C0_DIAGNOSTIC_COUNT  : STD_LOGIC_VECTOR(26 DOWNTO 0);
  SIGNAL C0_DIAGNOSTIC_TOGGLE : STD_ULOGIC;
  SIGNAL C1_CALIB_DONE        : STD_ULOGIC;
  SIGNAL C1_DIAGNOSTIC_COUNT  : STD_LOGIC_VECTOR(26 DOWNTO 0);
  SIGNAL C1_DIAGNOSTIC_TOGGLE : STD_ULOGIC;
  SIGNAL C2_CALIB_DONE        : STD_ULOGIC;
  SIGNAL C2_DIAGNOSTIC_COUNT  : STD_LOGIC_VECTOR(26 DOWNTO 0);
  SIGNAL C2_DIAGNOSTIC_TOGGLE : STD_ULOGIC;
  SIGNAL C3_CALIB_DONE        : STD_ULOGIC;
  SIGNAL C3_DIAGNOSTIC_COUNT  : STD_LOGIC_VECTOR(26 DOWNTO 0);
  SIGNAL C3_DIAGNOSTIC_TOGGLE : STD_ULOGIC;

  -- AHB PROXY EXTENDED
  TYPE NOC_FLIT_VECTOR IS ARRAY (NATURAL RANGE <>) OF NOC_FLIT_TYPE;
  SIGNAL EXTENDED_AHBM_RCV_RDREQ    : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL EXTENDED_AHBM_RCV_DATA_OUT : NOC_FLIT_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL EXTENDED_AHBM_RCV_EMPTY    : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL EXTENDED_AHBM_SND_WRREQ    : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL EXTENDED_AHBM_SND_DATA_IN  : NOC_FLIT_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL EXTENDED_AHBM_SND_FULL     : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);

  -- AHB PROXY QUEUES
  TYPE MISC_NOC_FLIT_VECTOR IS ARRAY (NATURAL RANGE <>) OF MISC_NOC_FLIT_TYPE;
  SIGNAL AHBM_RCV_RDREQ    : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBM_RCV_DATA_OUT : MISC_NOC_FLIT_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBM_RCV_EMPTY    : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBM_SND_WRREQ    : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBM_SND_DATA_IN  : MISC_NOC_FLIT_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBM_SND_FULL     : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);

  -- DUAL-CLOCK QUEUES
  SIGNAL AHBS_RCV_RDREQ    : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBS_RCV_DATA_OUT : MISC_NOC_FLIT_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBS_RCV_EMPTY    : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBS_SND_WRREQ    : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBS_SND_DATA_IN  : MISC_NOC_FLIT_VECTOR(0 TO CFG_NMEM_TILE - 1);
  SIGNAL AHBS_SND_FULL     : STD_LOGIC_VECTOR(0 TO CFG_NMEM_TILE - 1);

  -- AHB bus
  type ahb_mst_out_ddr_matrix is array (natural range <>) of ahb_mst_out_vector;
  type ahb_slv_out_ddr_matrix is array (natural range <>) of ahb_slv_out_vector;

  signal ahb_mst_out_ddr : ahb_mst_out_ddr_matrix(0 to CFG_NMEM_TILE - 1);
  signal ahb_slv_out_ddr : ahb_slv_out_ddr_matrix(0 to CFG_NMEM_TILE - 1);

  signal ahb_mst_in_ddr  : ahb_mst_in_vector_type(0 to CFG_NMEM_TILE - 1);
  signal ahb_slv_in_ddr  : ahb_slv_in_vector_type(0 to CFG_NMEM_TILE - 1);

  signal ddr_ahbsi        : ahb_slv_in_vector_type(0 to MAX_NMEM_TILES - 1);
  signal ddr_ahbso        : ahb_slv_out_vector_type(0 to MAX_NMEM_TILES - 1);

  -----------------------------------------------------------------------------
  -- Debug domain
  -- Mux to/from debug queues
  signal mux_ahbs_rcv_rdreq     : std_ulogic;
  signal mux_ahbs_rcv_data_out  : misc_noc_flit_type;
  signal mux_ahbs_rcv_empty     : std_ulogic;
  signal mux_ahbs_rcv_wrreq     : std_ulogic;
  signal mux_ahbs_rcv_data_in   : misc_noc_flit_type;
  signal mux_ahbs_rcv_full      : std_ulogic;
  signal mux_ahbs_snd_rdreq     : std_ulogic;
  signal mux_ahbs_snd_data_out  : misc_noc_flit_type;
  signal mux_ahbs_snd_empty     : std_ulogic;
  signal mux_ahbs_snd_wrreq     : std_ulogic;
  signal mux_ahbs_snd_data_in   : misc_noc_flit_type;
  signal mux_ahbs_snd_full      : std_ulogic;

  signal sending_packet : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal receiving_packet : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);

  signal target_y : local_yx;
  signal target_x : local_yx;

  -- AHB bus
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector;
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector;
  signal ahbso_edcl : ahb_slv_out_vector;
  signal ahbsi_in, ahbsi_sim : ahb_slv_in_type;
  signal ahbso_sim, ahbso_apb : ahb_slv_out_type;

  function set_remote_ahb_mask (
    constant N : in integer range 1 to CFG_NMEM_TILE)
    return std_logic_vector is
    variable ret : std_logic_vector(0 to NAHBSLV - 1);
  begin
    ret := (others => '0');
    for i in 0 to N - 1 loop
      ret(ddr_hindex(i)) := '1';
    end loop;  -- i
    return ret;
  end set_remote_ahb_mask;

  constant this_remote_ahb_slv_en : std_logic_vector(0 to NAHBSLV - 1) := set_remote_ahb_mask(CFG_NMEM_TILE);

  -----------------------------------------------------------------------------
  -- EDCL
  constant FPGA_PROXY_ETH_IPM : integer := 16#C0A8#;
  constant FPGA_PROXY_ETH_IPL : integer := 16#0114#;
  constant FPGA_PROXY_ETH_ENM : integer := 16#A6A7A0#;
  constant FPGA_PROXY_ETH_ENL : integer := 16#F82440#;

  signal ethi : eth_in_type;
  signal etho : eth_out_type;

  -----------------------------------------------------------------------------
  -- FPGA proxy
  signal fpga_data_ien       : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_data_in        : std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
  signal fpga_data_out       : std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
  signal fpga_valid_in_int   : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_valid_out_int  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_in_int     : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_out_int    : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_in_int  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_out_int : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);

  -----------------------------------------------------------------------------
  -- JTAG

  signal tclk_in : std_logic := '0';
  signal tms_in : std_logic := '0';
  signal tclk_sim : std_logic := '0';

  type source_t is array (1 to 6) of std_logic_vector(5 downto 0);
  type addr_t is array (17 downto 0) of std_logic_vector(31 downto 0);

  -- control
  signal rst_l : std_logic;

  signal tdi_jtag, tdo_jtag : std_logic;


  attribute keep : boolean;
  attribute keep of main_clk : signal is true;
  attribute keep of sys_clk  : signal is true;

  attribute mark_debug : string;

  attribute mark_debug of ahbsi : signal is "true";
  attribute mark_debug of ahbso : signal is "true";

  attribute mark_debug of tdi_jtag : signal is "true";
  attribute mark_debug of tdo_jtag : signal is "true";

  attribute mark_debug of tms_in : signal is "true";

begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- DDR clock diagnostic

  c0_diagnostic : process (sys_clk(0), sys_rst(0))
  begin  -- process c0_diagnostic
    if sys_rst(0) = '1' then           -- asynchronous reset (active high)
      c0_diagnostic_count <= (others => '0');
    elsif sys_clk(0)'event and sys_clk(0) = '1' then  -- rising clock edge
      c0_diagnostic_count <= c0_diagnostic_count + 1;
    end if;
  end process c0_diagnostic;
  c0_diagnostic_toggle <= c0_diagnostic_count(26);
  c0_led_diag_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c0_diagnostic_led, c0_diagnostic_toggle);

  c1_diagnostic : process (sys_clk(1), sys_rst(1))
  begin  -- process c1_diagnostic
    if sys_rst(1) = '1' then       -- asynchronous reset (active high)
      c1_diagnostic_count <= (others => '0');
    elsif sys_clk(1)'event and sys_clk(1) = '1' then  -- rising clock edge
      c1_diagnostic_count <= c1_diagnostic_count + 1;
    end if;
  end process c1_diagnostic;
  c1_diagnostic_toggle <= c1_diagnostic_count(26);
  c1_led_diag_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c1_diagnostic_led, c1_diagnostic_toggle);

  c2_diagnostic : process (sys_clk(2), sys_rst(2))
  begin  -- process c2_diagnostic
    if sys_rst(2) = '1' then       -- asynchronous reset (active high)
      c2_diagnostic_count <= (others => '0');
    elsif sys_clk(2)'event and sys_clk(2) = '1' then  -- rising clock edge
      c2_diagnostic_count <= c2_diagnostic_count + 1;
    end if;
  end process c2_diagnostic;
  c2_diagnostic_toggle <= c2_diagnostic_count(26);
  c2_led_diag_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c2_diagnostic_led, c2_diagnostic_toggle);

  c3_diagnostic : process (sys_clk(3), sys_rst(3))
  begin  -- process c3_diagnostic
    if sys_rst(3) = '1' then       -- asynchronous reset (active high)
      c3_diagnostic_count <= (others => '0');
    elsif sys_clk(3)'event and sys_clk(3) = '1' then  -- rising clock edge
      c3_diagnostic_count <= c3_diagnostic_count + 1;
    end if;
  end process c3_diagnostic;
  c3_diagnostic_toggle <= c3_diagnostic_count(26);
  c3_led_diag_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c3_diagnostic_led, c3_diagnostic_toggle);


  -------------------------------------------------------------------------------
  -- Leds

  -- From memory controllers' PLLs
  lock_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v) port map (LED_GREEN, lock);

  -- From DDR controller (on FPGA)
  calib0_complete_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c0_calib_complete, c0_calib_done);
  calib1_complete_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c1_calib_complete, c1_calib_done);
  calib2_complete_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c2_calib_complete, c2_calib_done);
  calib3_complete_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c3_calib_complete, c3_calib_done);


  led_red_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v) port map (LED_RED, '0');

  led_blue_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v) port map (LED_BLUE, '0');

  led_yellow_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v) port map (LED_YELLOW, '0');

  ----------------------------------------------------------------------
  --- FPGA Reset and Clock generation

  lock <= c0_calib_done and c1_calib_done and c2_calib_done and c3_calib_done;

  reset_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (reset, rst);
  rst0      : rstgen                    -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, sys_clk(0), lock, rstn, open);

  mig_rst0 : rstgen                     -- reset generator
    generic map (acthigh => 1)
    port map (rst, sys_clk(0), lock, migrstn, rstraw);
  mig_rst1 : rstgen                     -- reset generator
    generic map (acthigh => 1)
    port map (rst, sys_clk(1), lock, migrstn_1, open);
  mig_rst2 : rstgen                     -- reset generator
    generic map (acthigh => 1)
    port map (rst, sys_clk(2), lock, migrstn_2, open);
  mig_rst3 : rstgen                     -- reset generator
    generic map (acthigh => 1)
    port map (rst, sys_clk(3), lock, migrstn_3, open);

  main_clk_buf : ibufgds
    generic map(
      IBUF_LOW_PWR => FALSE
      )
    port map (
      I  => main_clk_p,
      IB => main_clk_n,
      O  => main_clk
      );

  -- Chip reset
  chip_rst_gen: process (sys_clk(0)) is
  begin  -- process chip_rst_gen
    if sys_clk(0)'event and sys_clk(0) = '1' then  -- rising clock edge
      chip_reset <= not rstn;
    end if;
  end process chip_rst_gen;

  ----------------------------------------------------------------------
  ---  DDR3 memory controller

  gen_mig : if (SIMULATION /= true) generate
    ddrc0 : ahb2mig_7series_profpga
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(0)),
        hmask  => ddr_hmask(this_ddr_index(0)))
      port map(
        app_addr          => c0_app_addr,
        app_cmd           => c0_app_cmd,
        app_en            => c0_app_en,
        app_wdf_data      => c0_app_wdf_data,
        app_wdf_end       => c0_app_wdf_end,
        app_wdf_mask      => c0_app_wdf_mask,
        app_wdf_wren      => c0_app_wdf_wren,
        app_rd_data       => c0_app_rd_data,
        app_rd_data_end   => c0_app_rd_data_end,
        app_rd_data_valid => c0_app_rd_data_valid,
        app_rdy           => c0_app_rdy,
        app_wdf_rdy       => c0_app_wdf_rdy,
        ahbsi             => ddr_ahbsi(0),
        ahbso             => ddr_ahbso(0),
        rst_n_syn         => migrstn,
        clk_amba          => sys_clk(0)
        );

    ddrc1 : ahb2mig_7series_profpga
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(1)),
        hmask  => ddr_hmask(this_ddr_index(1)))
      port map(
        app_addr          => c1_app_addr,
        app_cmd           => c1_app_cmd,
        app_en            => c1_app_en,
        app_wdf_data      => c1_app_wdf_data,
        app_wdf_end       => c1_app_wdf_end,
        app_wdf_mask      => c1_app_wdf_mask,
        app_wdf_wren      => c1_app_wdf_wren,
        app_rd_data       => c1_app_rd_data,
        app_rd_data_end   => c1_app_rd_data_end,
        app_rd_data_valid => c1_app_rd_data_valid,
        app_rdy           => c1_app_rdy,
        app_wdf_rdy       => c1_app_wdf_rdy,
        ahbsi             => ddr_ahbsi(1),
        ahbso             => ddr_ahbso(1),
        rst_n_syn         => migrstn_1,
        clk_amba          => sys_clk(1)
        );

    ddrc2 : ahb2mig_7series_profpga
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(2)),
        hmask  => ddr_hmask(this_ddr_index(2)))
      port map(
        app_addr          => c2_app_addr,
        app_cmd           => c2_app_cmd,
        app_en            => c2_app_en,
        app_wdf_data      => c2_app_wdf_data,
        app_wdf_end       => c2_app_wdf_end,
        app_wdf_mask      => c2_app_wdf_mask,
        app_wdf_wren      => c2_app_wdf_wren,
        app_rd_data       => c2_app_rd_data,
        app_rd_data_end   => c2_app_rd_data_end,
        app_rd_data_valid => c2_app_rd_data_valid,
        app_rdy           => c2_app_rdy,
        app_wdf_rdy       => c2_app_wdf_rdy,
        ahbsi             => ddr_ahbsi(2),
        ahbso             => ddr_ahbso(2),
        rst_n_syn         => migrstn_2,
        clk_amba          => sys_clk(2)
        );

    ddrc3 : ahb2mig_7series_profpga
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(3)),
        hmask  => ddr_hmask(this_ddr_index(3)))
      port map(
        app_addr          => c3_app_addr,
        app_cmd           => c3_app_cmd,
        app_en            => c3_app_en,
        app_wdf_data      => c3_app_wdf_data,
        app_wdf_end       => c3_app_wdf_end,
        app_wdf_mask      => c3_app_wdf_mask,
        app_wdf_wren      => c3_app_wdf_wren,
        app_rd_data       => c3_app_rd_data,
        app_rd_data_end   => c3_app_rd_data_end,
        app_rd_data_valid => c3_app_rd_data_valid,
        app_rdy           => c3_app_rdy,
        app_wdf_rdy       => c3_app_wdf_rdy,
        ahbsi             => ddr_ahbsi(3),
        ahbso             => ddr_ahbso(3),
        rst_n_syn         => migrstn_3,
        clk_amba          => sys_clk(3)
        );


    MCB_quad_mig_inst : mig
      port map (
        c0_sys_clk_p            => c0_sys_clk_p,
        c0_sys_clk_n            => c0_sys_clk_n,
        c0_ddr3_dq              => c0_ddr3_dq,
        c0_ddr3_dqs_p           => c0_ddr3_dqs_p,
        c0_ddr3_dqs_n           => c0_ddr3_dqs_n,
        c0_ddr3_addr            => c0_ddr3_addr,
        c0_ddr3_ba              => c0_ddr3_ba,
        c0_ddr3_ras_n           => c0_ddr3_ras_n,
        c0_ddr3_cas_n           => c0_ddr3_cas_n,
        c0_ddr3_we_n            => c0_ddr3_we_n,
        c0_ddr3_reset_n         => c0_ddr3_reset_n,
        c0_ddr3_ck_p            => c0_ddr3_ck_p,
        c0_ddr3_ck_n            => c0_ddr3_ck_n,
        c0_ddr3_cke             => c0_ddr3_cke,
        c0_ddr3_cs_n            => c0_ddr3_cs_n,
        c0_ddr3_dm              => c0_ddr3_dm,
        c0_ddr3_odt             => c0_ddr3_odt,
        c1_sys_clk_p            => c1_sys_clk_p,
        c1_sys_clk_n            => c1_sys_clk_n,
        c1_ddr3_dq              => c1_ddr3_dq,
        c1_ddr3_dqs_p           => c1_ddr3_dqs_p,
        c1_ddr3_dqs_n           => c1_ddr3_dqs_n,
        c1_ddr3_addr            => c1_ddr3_addr,
        c1_ddr3_ba              => c1_ddr3_ba,
        c1_ddr3_ras_n           => c1_ddr3_ras_n,
        c1_ddr3_cas_n           => c1_ddr3_cas_n,
        c1_ddr3_we_n            => c1_ddr3_we_n,
        c1_ddr3_reset_n         => c1_ddr3_reset_n,
        c1_ddr3_ck_p            => c1_ddr3_ck_p,
        c1_ddr3_ck_n            => c1_ddr3_ck_n,
        c1_ddr3_cke             => c1_ddr3_cke,
        c1_ddr3_cs_n            => c1_ddr3_cs_n,
        c1_ddr3_dm              => c1_ddr3_dm,
        c1_ddr3_odt             => c1_ddr3_odt,
        c2_sys_clk_p            => c2_sys_clk_p,
        c2_sys_clk_n            => c2_sys_clk_n,
        c2_ddr3_dq              => c2_ddr3_dq,
        c2_ddr3_dqs_p           => c2_ddr3_dqs_p,
        c2_ddr3_dqs_n           => c2_ddr3_dqs_n,
        c2_ddr3_addr            => c2_ddr3_addr,
        c2_ddr3_ba              => c2_ddr3_ba,
        c2_ddr3_ras_n           => c2_ddr3_ras_n,
        c2_ddr3_cas_n           => c2_ddr3_cas_n,
        c2_ddr3_we_n            => c2_ddr3_we_n,
        c2_ddr3_reset_n         => c2_ddr3_reset_n,
        c2_ddr3_ck_p            => c2_ddr3_ck_p,
        c2_ddr3_ck_n            => c2_ddr3_ck_n,
        c2_ddr3_cke             => c2_ddr3_cke,
        c2_ddr3_cs_n            => c2_ddr3_cs_n,
        c2_ddr3_dm              => c2_ddr3_dm,
        c2_ddr3_odt             => c2_ddr3_odt,
        c3_sys_clk_p            => c3_sys_clk_p,
        c3_sys_clk_n            => c3_sys_clk_n,
        c3_ddr3_dq              => c3_ddr3_dq,
        c3_ddr3_dqs_p           => c3_ddr3_dqs_p,
        c3_ddr3_dqs_n           => c3_ddr3_dqs_n,
        c3_ddr3_addr            => c3_ddr3_addr,
        c3_ddr3_ba              => c3_ddr3_ba,
        c3_ddr3_ras_n           => c3_ddr3_ras_n,
        c3_ddr3_cas_n           => c3_ddr3_cas_n,
        c3_ddr3_we_n            => c3_ddr3_we_n,
        c3_ddr3_reset_n         => c3_ddr3_reset_n,
        c3_ddr3_ck_p            => c3_ddr3_ck_p,
        c3_ddr3_ck_n            => c3_ddr3_ck_n,
        c3_ddr3_cke             => c3_ddr3_cke,
        c3_ddr3_cs_n            => c3_ddr3_cs_n,
        c3_ddr3_dm              => c3_ddr3_dm,
        c3_ddr3_odt             => c3_ddr3_odt,
        clk_ref_p               => clk_ref_p,
        clk_ref_n               => clk_ref_n,
        c0_app_addr             => c0_app_addr,
        c0_app_cmd              => c0_app_cmd,
        c0_app_en               => c0_app_en,
        c0_app_wdf_data         => c0_app_wdf_data,
        c0_app_wdf_end          => c0_app_wdf_end,
        c0_app_wdf_mask         => c0_app_wdf_mask,
        c0_app_wdf_wren         => c0_app_wdf_wren,
        c0_app_rd_data          => c0_app_rd_data,
        c0_app_rd_data_end      => c0_app_rd_data_end,
        c0_app_rd_data_valid    => c0_app_rd_data_valid,
        c0_app_rdy              => c0_app_rdy,
        c0_app_wdf_rdy          => c0_app_wdf_rdy,
        c0_app_sr_req           => '0',
        c0_app_ref_req          => '0',
        c0_app_zq_req           => '0',
        c0_app_sr_active        => open,
        c0_app_ref_ack          => open,
        c0_app_zq_ack           => open,
        c0_ui_clk               => sys_clk(0),
        c0_ui_clk_sync_rst      => sys_rst(0),
        c0_init_calib_complete  => c0_calib_done,
        c0_device_temp          => open,
        c1_app_addr             => c1_app_addr,
        c1_app_cmd              => c1_app_cmd,
        c1_app_en               => c1_app_en,
        c1_app_wdf_data         => c1_app_wdf_data,
        c1_app_wdf_end          => c1_app_wdf_end,
        c1_app_wdf_mask         => c1_app_wdf_mask,
        c1_app_wdf_wren         => c1_app_wdf_wren,
        c1_app_rd_data          => c1_app_rd_data,
        c1_app_rd_data_end      => c1_app_rd_data_end,
        c1_app_rd_data_valid    => c1_app_rd_data_valid,
        c1_app_rdy              => c1_app_rdy,
        c1_app_wdf_rdy          => c1_app_wdf_rdy,
        c1_app_sr_req           => '0',
        c1_app_ref_req          => '0',
        c1_app_zq_req           => '0',
        c1_app_sr_active        => open,
        c1_app_ref_ack          => open,
        c1_app_zq_ack           => open,
        c1_ui_clk               => sys_clk(1),
        c1_ui_clk_sync_rst      => sys_rst(1),
        c1_init_calib_complete  => c1_calib_done,
        c1_device_temp          => open,
        c2_app_addr             => c2_app_addr,
        c2_app_cmd              => c2_app_cmd,
        c2_app_en               => c2_app_en,
        c2_app_wdf_data         => c2_app_wdf_data,
        c2_app_wdf_end          => c2_app_wdf_end,
        c2_app_wdf_mask         => c2_app_wdf_mask,
        c2_app_wdf_wren         => c2_app_wdf_wren,
        c2_app_rd_data          => c2_app_rd_data,
        c2_app_rd_data_end      => c2_app_rd_data_end,
        c2_app_rd_data_valid    => c2_app_rd_data_valid,
        c2_app_rdy              => c2_app_rdy,
        c2_app_wdf_rdy          => c2_app_wdf_rdy,
        c2_app_sr_req           => '0',
        c2_app_ref_req          => '0',
        c2_app_zq_req           => '0',
        c2_app_sr_active        => open,
        c2_app_ref_ack          => open,
        c2_app_zq_ack           => open,
        c2_ui_clk               => sys_clk(2),
        c2_ui_clk_sync_rst      => sys_rst(2),
        c2_init_calib_complete  => c2_calib_done,
        c2_device_temp          => open,
        c3_app_addr             => c3_app_addr,
        c3_app_cmd              => c3_app_cmd,
        c3_app_en               => c3_app_en,
        c3_app_wdf_data         => c3_app_wdf_data,
        c3_app_wdf_end          => c3_app_wdf_end,
        c3_app_wdf_mask         => c3_app_wdf_mask,
        c3_app_wdf_wren         => c3_app_wdf_wren,
        c3_app_rd_data          => c3_app_rd_data,
        c3_app_rd_data_end      => c3_app_rd_data_end,
        c3_app_rd_data_valid    => c3_app_rd_data_valid,
        c3_app_rdy              => c3_app_rdy,
        c3_app_wdf_rdy          => c3_app_wdf_rdy,
        c3_app_sr_req           => '0',
        c3_app_ref_req          => '0',
        c3_app_zq_req           => '0',
        c3_app_sr_active        => open,
        c3_app_ref_ack          => open,
        c3_app_zq_ack           => open,
        c3_ui_clk               => sys_clk(3),
        c3_ui_clk_sync_rst      => sys_rst(3),
        c3_init_calib_complete  => c3_calib_done,
        c3_device_temp          => open,
        sys_rst                 => rstraw
        );

  end generate gen_mig;

  gen_mig_model : if (SIMULATION = true) generate
    -- pragma translate_off

    mig_ahbram : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 2048,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => sys_clk(0),
        haddr  => ddr_haddr(this_ddr_index(0)),
        hmask  => ddr_hmask(this_ddr_index(0)),
        ahbsi => ddr_ahbsi(0),
        ahbso => ddr_ahbso(0)
        );

    mig_ahbram1 : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 2048,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => sys_clk(1),
        haddr  => ddr_haddr(this_ddr_index(1)),
        hmask  => ddr_hmask(this_ddr_index(1)),
        ahbsi => ddr_ahbsi(1),
        ahbso => ddr_ahbso(1)
        );

    mig_ahbram2 : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 2048,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => sys_clk(2),
        haddr  => ddr_haddr(this_ddr_index(2)),
        hmask  => ddr_hmask(this_ddr_index(2)),
        ahbsi => ddr_ahbsi(2),
        ahbso => ddr_ahbso(2)
        );

    mig_ahbram3 : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 2048,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => sys_clk(3),
        haddr  => ddr_haddr(this_ddr_index(3)),
        hmask  => ddr_hmask(this_ddr_index(3)),
        ahbsi => ddr_ahbsi(3),
        ahbso => ddr_ahbso(3)
        );

    c0_ddr3_dq           <= (others => 'Z');
    c0_ddr3_dqs_p        <= (others => 'Z');
    c0_ddr3_dqs_n        <= (others => 'Z');
    c0_ddr3_addr         <= (others => '0');
    c0_ddr3_ba           <= (others => '0');
    c0_ddr3_ras_n        <= '0';
    c0_ddr3_cas_n        <= '0';
    c0_ddr3_we_n         <= '0';
    c0_ddr3_reset_n      <= '1';
    c0_ddr3_ck_p         <= (others => '0');
    c0_ddr3_ck_n         <= (others => '0');
    c0_ddr3_cke          <= (others => '0');
    c0_ddr3_cs_n         <= (others => '0');
    c0_ddr3_dm           <= (others => '0');
    c0_ddr3_odt          <= (others => '0');

    c0_calib_done <= '1';

    sys_clk(0)       <= not sys_clk(0) after 3.2 ns;

    c1_ddr3_dq           <= (others => 'Z');
    c1_ddr3_dqs_p        <= (others => 'Z');
    c1_ddr3_dqs_n        <= (others => 'Z');
    c1_ddr3_addr         <= (others => '0');
    c1_ddr3_ba           <= (others => '0');
    c1_ddr3_ras_n        <= '0';
    c1_ddr3_cas_n        <= '0';
    c1_ddr3_we_n         <= '0';
    c1_ddr3_reset_n      <= '1';
    c1_ddr3_ck_p         <= (others => '0');
    c1_ddr3_ck_n         <= (others => '0');
    c1_ddr3_cke          <= (others => '0');
    c1_ddr3_cs_n         <= (others => '0');
    c1_ddr3_dm           <= (others => '0');
    c1_ddr3_odt          <= (others => '0');

    c1_calib_done <= '1';

    sys_clk(1)       <= not sys_clk(1) after 3.2 ns;

    c2_ddr3_dq           <= (others => 'Z');
    c2_ddr3_dqs_p        <= (others => 'Z');
    c2_ddr3_dqs_n        <= (others => 'Z');
    c2_ddr3_addr         <= (others => '0');
    c2_ddr3_ba           <= (others => '0');
    c2_ddr3_ras_n        <= '0';
    c2_ddr3_cas_n        <= '0';
    c2_ddr3_we_n         <= '0';
    c2_ddr3_reset_n      <= '1';
    c2_ddr3_ck_p         <= (others => '0');
    c2_ddr3_ck_n         <= (others => '0');
    c2_ddr3_cke          <= (others => '0');
    c2_ddr3_cs_n         <= (others => '0');
    c2_ddr3_dm           <= (others => '0');
    c2_ddr3_odt          <= (others => '0');

    c2_calib_done <= '1';

    sys_clk(2)       <= not sys_clk(2) after 3.2 ns;

    c3_ddr3_dq           <= (others => 'Z');
    c3_ddr3_dqs_p        <= (others => 'Z');
    c3_ddr3_dqs_n        <= (others => 'Z');
    c3_ddr3_addr         <= (others => '0');
    c3_ddr3_ba           <= (others => '0');
    c3_ddr3_ras_n        <= '0';
    c3_ddr3_cas_n        <= '0';
    c3_ddr3_we_n         <= '0';
    c3_ddr3_reset_n      <= '1';
    c3_ddr3_ck_p         <= (others => '0');
    c3_ddr3_ck_n         <= (others => '0');
    c3_ddr3_cke          <= (others => '0');
    c3_ddr3_cs_n         <= (others => '0');
    c3_ddr3_dm           <= (others => '0');
    c3_ddr3_odt          <= (others => '0');

    c3_calib_done <= '1';

    sys_clk(3)       <= not sys_clk(3) after 3.2 ns;

  -- pragma translate_on
  end generate gen_mig_model;

  -----------------------------------------------------------------------------
  -- Link to ESP memory tiles

  set_upper_ahbsi : for i in CFG_NMEM_TILE to MAX_NMEM_TILES-1 generate
    -- Disable AHB port
    ddr_ahbsi(i) <= ahbs_in_none;
  end generate set_upper_ahbsi;

  fpga_io_gen : for i in 0 to CFG_NMEM_TILE - 1 generate

    -- Bidirection data pins
    fpga_iopad_data_gen : for j in 0 to ARCH_BITS - 1 generate
      fpga_data_pad : iopad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, oepol => 1)
        port map (fpga_data(memswap(i) * (ARCH_BITS) + j), fpga_data_in(i * (ARCH_BITS) + j), fpga_data_ien(i), fpga_data_out(i * (ARCH_BITS) + j));
    end generate fpga_iopad_data_gen;

    -- Valid bit
    fpga_valid_in_pad  : outpad generic map (level => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_valid_in(memswap(i)), fpga_valid_in_int(i));
    fpga_valid_out_pad : inpad generic map (level  => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_valid_out(memswap(i)), fpga_valid_out_int(i));

    -- Source-synchronous clocks
    fpga_clk_in_pad  : outpad generic map (level => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_clk_in(memswap(i)), fpga_clk_in_int(i));
    fpga_clk_out_pad : clkpad generic map (level => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_clk_out(memswap(i)), fpga_clk_out_int(i));

    -- Credit-based flow control
    fpga_credit_in_pad  : outpad generic map (level => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_credit_in(memswap(i)), fpga_credit_in_int(i));
    fpga_credit_out_pad : inpad generic map (level  => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_credit_out(memswap(i)), fpga_credit_out_int(i));

    ahb_slv_out_ddr(i)(0) <= ddr_ahbso(i);
    ddr_ahbsi(i) <= ahb_slv_in_ddr(i);

    -- External-link transaction to AHB master transaction for DDR controllers
    ext2ahbm_i : ext2ahbm
      generic map (
        hindex => 0,
        little_end => GLOB_CPU_AXI)
      port map (
        clk             => sys_clk(i),
        rstn            => rstn,
        fpga_data_in    => fpga_data_in((i + 1) * (ARCH_BITS) - 1 downto i * (ARCH_BITS)),
        fpga_data_out   => fpga_data_out((i + 1) * (ARCH_BITS) - 1 downto i * (ARCH_BITS)),
        fpga_valid_in   => fpga_valid_in_int(i),
        fpga_valid_out  => fpga_valid_out_int(i),
        fpga_data_ien   => fpga_data_ien(i),
        fpga_clk_in     => fpga_clk_in_int(i),
        fpga_clk_out    => fpga_clk_out_int(i),
        fpga_credit_in  => fpga_credit_in_int(i),
        fpga_credit_out => fpga_credit_out_int(i),
        ahbmi           => ahb_mst_in_ddr(i),
        ahbmo           => ahb_mst_out_ddr(i)(0));

    -- Handle EDCL requests to memory (load program/data)
    noc2ahbmst_i  : noc2ahbmst
      generic map (
        tech        => FPGA_PROXY_TECH,
        hindex      => 1,
        axitran     => 0,
        little_end  => 0,
        eth_dma     => 0,
        narrow_noc  => 0,
        cacheline   => 1,
        l2_cache_en => 0)
      port map (
        rst                       => rstn,
        clk                       => sys_clk(i),
        local_y                   => tile_x(mem_tile_id(i)),
        local_x                   => tile_y(mem_tile_id(i)),
        ahbmi                     => ahb_mst_in_ddr(i),
        ahbmo                     => ahb_mst_out_ddr(i)(1),
        coherence_req_rdreq       => extended_ahbm_rcv_rdreq(i),
        coherence_req_data_out    => extended_ahbm_rcv_data_out(i),
        coherence_req_empty       => extended_ahbm_rcv_empty(i),
        coherence_fwd_wrreq       => open,
        coherence_fwd_data_in     => open,
        coherence_fwd_full        => '0',
        coherence_rsp_snd_wrreq   => extended_ahbm_snd_wrreq(i),
        coherence_rsp_snd_data_in => extended_ahbm_snd_data_in(i),
        coherence_rsp_snd_full    => extended_ahbm_snd_full(i),
        dma_rcv_rdreq             => open,
        dma_rcv_data_out          => (others => '0'),
        dma_rcv_empty             => '1',
        dma_snd_wrreq             => open,
        dma_snd_data_in           => open,
        dma_snd_full              => '0',
        dma_snd_atleast_4slots    => '1',
        dma_snd_exactly_3slots    => '0');

    ahbm_rcv_rdreq(i)          <= extended_ahbm_rcv_rdreq(i);
    extended_ahbm_rcv_empty(i) <= ahbm_rcv_empty(i);
    ahbm_snd_wrreq(i)          <= extended_ahbm_snd_wrreq(i);
    extended_ahbm_snd_full(i)  <= ahbm_snd_full(i);

    large_bus: if ARCH_BITS /= 32 generate
      extended_ahbm_rcv_data_out(i) <= narrow_to_large_flit(ahbm_rcv_data_out(i));
      ahbm_snd_data_in(i)           <= large_to_narrow_flit(extended_ahbm_snd_data_in(i));
    end generate large_bus;

    std_bus: if ARCH_BITS = 32 generate
      extended_ahbm_rcv_data_out(i) <= ahbm_rcv_data_out(i);
      ahbm_snd_data_in(i)           <= extended_ahbm_snd_data_in(i);
    end generate std_bus;

    -- AHB bus for DDR access
    ahbctrl_ddr_i : ahbctrl                        -- AHB arbiter/multiplexer
      generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                   rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                   nahbm   => 2, nahbs => 1,
                   cfgmask => 0)
      port map (rstn, sys_clk(i), ahb_mst_in_ddr(i), ahb_mst_out_ddr(i), ahb_slv_in_ddr(i), ahb_slv_out_ddr(i));

    -- Unused bus ports
    unused_ahbm_gen: for j in 2 to NAHBMST - 1 generate
      ahb_mst_out_ddr(i)(j) <= ahbm_none;
    end generate unused_ahbm_gen;
    unused_ahbs_gen: for j in 1 to NAHBSLV - 1 generate
      ahb_slv_out_ddr(i)(j) <= ahbs_none;
    end generate unused_ahbs_gen;

    -- noc2ahbm to ahbs2noc
    mem2ext_fifo_1: inferred_async_fifo
      generic map (
        g_data_width => MISC_NOC_FLIT_SIZE,
        g_size       => 8)
      port map (
        rst_n_i    => rstn,
        clk_wr_i   => sys_clk(i),
        we_i       => ahbm_snd_wrreq(i),
        d_i        => ahbm_snd_data_in(i),
        wr_full_o  => ahbm_snd_full(i),
        clk_rd_i   => main_clk,
        rd_i       => ahbs_rcv_rdreq(i),
        q_o        => ahbs_rcv_data_out(i),
        rd_empty_o => ahbs_rcv_empty(i));

    -- ahbs2noc to noc2ahbm
    mem2ext_fifo_2: inferred_async_fifo
      generic map (
        g_data_width => MISC_NOC_FLIT_SIZE,
        g_size       => 8)
      port map (
        rst_n_i    => rstn,
        clk_wr_i   => main_clk,
        we_i       => ahbs_snd_wrreq(i),
        d_i        => ahbs_snd_data_in(i),
        wr_full_o  => ahbs_snd_full(i),
        clk_rd_i   => sys_clk(i),
        rd_i       => ahbm_rcv_rdreq(i),
        q_o        => ahbm_rcv_data_out(i),
        rd_empty_o => ahbm_rcv_empty(i));

  end generate fpga_io_gen;

  -----------------------------------------------------------------------------
  -- EDCL interface

  -- Multiplexing sending queue
  fifo0_from_edcl : fifo0
    generic map (
      depth => 8,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => main_clk,
      rst      => rstn,
      rdreq    => mux_ahbs_snd_rdreq,
      wrreq    => mux_ahbs_snd_wrreq,
      data_in  => mux_ahbs_snd_data_in,
      empty    => mux_ahbs_snd_empty,
      full     => mux_ahbs_snd_full,
      data_out => mux_ahbs_snd_data_out);

  snd_mux_gen: process (ahbs_snd_full, mux_ahbs_snd_data_out, mux_ahbs_snd_empty, sending_packet) is
  begin
    mux_ahbs_snd_rdreq <= '0';

    ahbs_snd_wrreq    <= (others => '0');
    ahbs_snd_data_in  <= (others => (others => '0'));

    case sending_packet is
      when "0001" =>
        ahbs_snd_wrreq(0)   <= (not mux_ahbs_snd_empty) and (not ahbs_snd_full(0));
        ahbs_snd_data_in(0) <= mux_ahbs_snd_data_out;
        mux_ahbs_snd_rdreq  <= (not mux_ahbs_snd_empty) and (not ahbs_snd_full(0));

      when "0010" =>
        ahbs_snd_wrreq(1)   <= (not mux_ahbs_snd_empty) and (not ahbs_snd_full(1));
        ahbs_snd_data_in(1) <= mux_ahbs_snd_data_out;
        mux_ahbs_snd_rdreq  <= (not mux_ahbs_snd_empty) and (not ahbs_snd_full(1));

      when "0100" =>
        ahbs_snd_wrreq(2)   <= (not mux_ahbs_snd_empty) and (not ahbs_snd_full(2));
        ahbs_snd_data_in(2) <= mux_ahbs_snd_data_out;
        mux_ahbs_snd_rdreq  <= (not mux_ahbs_snd_empty) and (not ahbs_snd_full(2));

      when "1000" =>
        ahbs_snd_wrreq(3)   <= (not mux_ahbs_snd_empty) and (not ahbs_snd_full(3));
        ahbs_snd_data_in(3) <= mux_ahbs_snd_data_out;
        mux_ahbs_snd_rdreq  <= (not mux_ahbs_snd_empty) and (not ahbs_snd_full(3));

      when others => null;
    end case;
  end process snd_mux_gen;

  -- Multiplexing receiving queue
  fifo0_to_edcl : fifo0
    generic map (
      depth => 8,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => main_clk,
      rst      => rstn,
      rdreq    => mux_ahbs_rcv_rdreq,
      wrreq    => mux_ahbs_rcv_wrreq,
      data_in  => mux_ahbs_rcv_data_in,
      empty    => mux_ahbs_rcv_empty,
      full     => mux_ahbs_rcv_full,
      data_out => mux_ahbs_rcv_data_out);

  rcv_mux_gen: process (ahbs_rcv_empty, ahbs_rcv_data_out, mux_ahbs_rcv_full, receiving_packet) is
  begin
    mux_ahbs_rcv_wrreq   <= '0';
    mux_ahbs_rcv_data_in <= (others => '0');

    ahbs_rcv_rdreq    <= (others => '0');

    case receiving_packet is
      when "0001" =>
        mux_ahbs_rcv_wrreq   <= (not mux_ahbs_rcv_full) and (not ahbs_rcv_empty(0));
        mux_ahbs_rcv_data_in <= ahbs_rcv_data_out(0);
        ahbs_rcv_rdreq(0)    <= (not mux_ahbs_rcv_full) and (not ahbs_rcv_empty(0));

      when "0010" =>
        mux_ahbs_rcv_wrreq   <= (not mux_ahbs_rcv_full) and (not ahbs_rcv_empty(1));
        mux_ahbs_rcv_data_in <= ahbs_rcv_data_out(1);
        ahbs_rcv_rdreq(1)    <= (not mux_ahbs_rcv_full) and (not ahbs_rcv_empty(1));

      when "0100" =>
        mux_ahbs_rcv_wrreq   <= (not mux_ahbs_rcv_full) and (not ahbs_rcv_empty(2));
        mux_ahbs_rcv_data_in <= ahbs_rcv_data_out(2);
        ahbs_rcv_rdreq(2)    <= (not mux_ahbs_rcv_full) and (not ahbs_rcv_empty(2));

      when "1000" =>
        mux_ahbs_rcv_wrreq   <= (not mux_ahbs_rcv_full) and (not ahbs_rcv_empty(3));
        mux_ahbs_rcv_data_in <= ahbs_rcv_data_out(3);
        ahbs_rcv_rdreq(3)    <= (not mux_ahbs_rcv_full) and (not ahbs_rcv_empty(3));

      when others => null;
    end case;

  end process rcv_mux_gen;

  -- Mux selectors
  target_x <= get_destination_x(MISC_NOC_FLIT_SIZE, noc_flit_pad & mux_ahbs_snd_data_out);
  target_y <= get_destination_y(MISC_NOC_FLIT_SIZE, noc_flit_pad & mux_ahbs_snd_data_out);

  mux_state_gen: process (main_clk, rstn) is
  begin  -- process mux_state_gen
    if rstn = '0' then                   -- asynchronous reset (active low)
      sending_packet   <= (others => '0');
      receiving_packet <= (others => '0');
    elsif main_clk'event and main_clk = '1' then  -- rising clock edge

      -- Sender state
      if sending_packet = "0000" then
        -- Select target DDR
        if mux_ahbs_snd_empty = '0' then
          for i in 0 to CFG_NMEM_TILE - 1 loop
            if (target_y = tile_mem_list(i).y) and (target_x = tile_mem_list(i).x) then
              sending_packet(i) <= '1';
            end if;
          end loop;  -- i
        end if;
      else
        -- Wait for current transaction to complete (look for tail)
        if (mux_ahbs_snd_empty = '0') and (mux_ahbs_snd_data_out(MISC_NOC_FLIT_SIZE - 2) = '1') then
          sending_packet <= (others => '0');
        end if;
      end if;

      -- Receiver state
      if receiving_packet = "0000" then
        -- Select source DDR
        for i in 0 to CFG_NMEM_TILE - 1 loop
          if ahbs_rcv_empty(i) = '0' then
            receiving_packet    <= (others => '0');
            receiving_packet(i) <= '1';
          end if;
        end loop;  -- i
      else
        -- Wait for current transaction to complete (look for tail)
        if (mux_ahbs_rcv_empty = '0') and (mux_ahbs_rcv_data_out(MISC_NOC_FLIT_SIZE - 2) = '1') then
          receiving_packet <= (others => '0');
        end if;
      end if;

    end if;
  end process mux_state_gen;

  -- Handle EDCL requests to memory
  ahbslv2noc_1 : ahbslv2noc
    generic map (
      tech             => FPGA_PROXY_TECH,
      hindex           => this_remote_ahb_slv_en,
      hconfig          => fixed_ahbso_hconfig,
      mem_hindex       => ddr_hindex(0),
      mem_num          => CFG_NMEM_TILE,
      mem_info         => tile_acc_mem_list(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1),
      slv_y            => tile_y(io_tile_id),
      slv_x            => tile_x(io_tile_id),
      retarget_for_dma => 1,
      dma_length       => CFG_DLINE)
    port map (
      rst                        => rstn,
      clk                        => main_clk,
      local_y                    => tile_y(io_tile_id),
      local_x                    => tile_x(io_tile_id),
      ahbsi                      => ahbsi,
      ahbso                      => ahbso_edcl,
      dma_selected               => '0',
      coherence_req_wrreq        => open,
      coherence_req_data_in      => open,
      coherence_req_full         => '0',
      coherence_rsp_rcv_rdreq    => open,
      coherence_rsp_rcv_data_out => (others => '0'),
      coherence_rsp_rcv_empty    => '1',
      remote_ahbs_snd_wrreq      => mux_ahbs_snd_wrreq,
      remote_ahbs_snd_data_in    => mux_ahbs_snd_data_in,
      remote_ahbs_snd_full       => mux_ahbs_snd_full,
      remote_ahbs_rcv_rdreq      => mux_ahbs_rcv_rdreq,
      remote_ahbs_rcv_data_out   => mux_ahbs_rcv_data_out,
      remote_ahbs_rcv_empty      => mux_ahbs_rcv_empty);

  -- AHB bus for EDCL
  ahbctrl_edcl_1 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => 1, nahbs => NAHBSLV,
                 cfgmask => 0)
    port map (rstn, main_clk, ahbmi, ahbmo, ahbsi, ahbso);

  -- Unused bus ports
  unused_ahbm_eth_gen: for j in 1 to NAHBSLV - 1 generate
    ahbmo(j) <= ahbm_none;
  end generate unused_ahbm_eth_gen;

  -- Ethernet EDCL
  eth0 : if SIMULATION = false and CFG_GRETH = 1 generate  -- Gaisler ethernet MAC
  e1 : grethm
    generic map(
      hindex      => 1,                 -- unused
      ehindex     => 0,
      pindex      => 14,
      paddr       => 16#800#,
      pmask       => 16#f00#,
      pirq        => 12,
      little_end  => GLOB_CPU_AXI,      -- no caches on FPGA proxy
      memtech     => FPGA_PROXY_TECH,
      enable_mdio => 1,
      fifosize    => CFG_ETH_FIFO,
      nsync       => 1,
      edcl        => 1,
      edclbufsz   => CFG_ETH_BUF,
      macaddrh    => FPGA_PROXY_ETH_ENM,
      macaddrl    => FPGA_PROXY_ETH_ENL,
      phyrstadr   => 1,
      ipaddrh     => FPGA_PROXY_ETH_IPM,
      ipaddrl     => FPGA_PROXY_ETH_IPL,
      giga        => CFG_GRETH1G,
      edclsepahbg => 1)
    port map(
      rst    => rstn,
      clk    => main_clk,
      mdcscaler => FPGA_PROXY_FREQ/1000,
      ahbmi  => ahbmi,
      ahbmo  => open,
      eahbmo => ahbmo(0),
      apbi   => apb_slv_in_none,
      apbo   => open,
      ethi   => ethi,
      etho   => etho);
  end generate;

  ethi.edclsepahb <= '1';

  -- eth pads
  reset_o2 <= rstn;
  eth0_inpads : if (CFG_GRETH = 1) generate
    etxc_pad : clkpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, arch => 2)
      port map (etx_clk, ethi.tx_clk);
    erxc_pad : clkpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, arch => 2)
      port map (erx_clk, ethi.rx_clk);
    erxd_pad : inpadv generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, width => 4)
      port map (erxd, ethi.rxd(3 downto 0));
    erxdv_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
      port map (erx_dv, ethi.rx_dv);
    erxer_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
      port map (erx_er, ethi.rx_er);
    erxco_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
      port map (erx_col, ethi.rx_col);
    erxcr_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
      port map (erx_crs, ethi.rx_crs);
  end generate eth0_inpads;

  emdio_pad : iopad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
    port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
  etxd_pad : outpadv generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, width => 4)
    port map (etxd, etho.txd(3 downto 0));
  etxen_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
    port map (etx_en, etho.tx_en);
  etxer_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
    port map (etx_er, etho.tx_er);
  emdc_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
    port map (emdc, etho.mdc);

  no_eth0 : if SIMULATION = true or CFG_GRETH = 0 generate
    ahbmo(0)     <= ahbm_none;
    etho.mdio_o  <= '0';
    etho.mdio_oe <= '0';
    etho.txd     <= (others => '0');
    etho.tx_en   <= '0';
    etho.tx_er   <= '0';
    etho.mdc     <= '0';
  end generate no_eth0;

  -----------------------------------------------------------------------------
  -- DCO backup clocks
  ext_clk_sim_gen: if SIMULATION = true generate
    ext_clk_noc_int <= not ext_clk_noc_int after 5 ns;
    ext_clk_sim_for_gen: for i in 0 to CFG_TILES_NUM - 1 generate
      ext_clk_int(i) <= not ext_clk_int(i) after 8 ns;
    end generate ext_clk_sim_for_gen;

  end generate ext_clk_sim_gen;

  ext_clk_gen: if SIMULATION = false generate
    -- TODO: generate external backup clocks
    ext_clk_int <= (others => '0');
    ext_clk_noc_int <= '0';
  end generate ext_clk_gen;

  ext_clk <= ext_clk_int;

  ext_clk_io   <= ext_clk(io_tile_id);
  ext_clk_cpu  <= ext_clk(cpu_tile_id(0));
  ext_clk_mem  <= ext_clk(mem_tile_id(0));
  ext_clk_acc0 <= ext_clk(1);
  ext_clk_acc1 <= ext_clk(12);

  ext_clk_noc <= ext_clk_noc_int;

  -----------------------------------------------------------------------------
  -- JTAG interface

  rst_l <= not(rst);

  fpga_proxy_jtag0: fpga_proxy_jtag
      port map (
        rst    => rst_l,
        tdi    => tdi_jtag,
        tdo    => tdo_jtag,
        tms    => tms_in,
        tclk   => tclk_in,
        ahbsi  => ahbsi_in,
        ahbso  => ahbso_apb);

  ahbso(0)<= ahbso_apb;
  ahbso(1 to NAHBSLV-1) <= ahbso_edcl(1 to NAHBSLV-1);

  normal_mode_gen: if JTAG_TRACE = -1 generate
    tdi <= (others => '0');
    tms <= '0';
    tclk <= '0';
    tdo_jtag <= '0';

  end generate normal_mode_gen;

  jtag_driver_gen: if JTAG_TRACE /= -1 generate

    tdi(JTAG_TRACE) <= tdi_jtag;
    tdo_jtag <= tdo(JTAG_TRACE);
    
    tdi_gen: for i in 0 to CFG_TILES_NUM - 1 generate
      tdi_inactive_tile_gen: if i /= JTAG_TRACE generate
        tdi(i) <= '0';
      end generate tdi_inactive_tile_gen;
    end generate tdi_gen;
  
    tms_in <= '1';
    tclk_in <= not tclk_in after 10 ns;
    tclk <= tclk_in;
    tms <= tms_in;
    
    jtag_gen_norm: if SIMULATION= false generate 
      ahbsi_in<=ahbsi;
    end generate jtag_gen_norm;

    jtag_gen_sim: if SIMULATION= true generate 

      tclk_sim <= not tclk_sim after 10 ns;

      
      ahbsi_in<=ahbsi_sim;
      ahbso_sim<=ahbso_apb;

      -- pragma translate_off
      PROC_SEQUENCER : process
        file text_file1 : text open read_mode is "stim1.txt";
        file text_file2 : text open read_mode is "stim2.txt";
        file text_file3 : text open read_mode is "stim3.txt";
        file text_file4 : text open read_mode is "stim4.txt";
        file text_file5 : text open read_mode is "stim5.txt";
        file text_file6 : text open read_mode is "stim6.txt";
        file out_file0 : text open write_mode is "stim5_origin.txt";
        file out_file1 : text open write_mode is "stim5_fin.txt";
        file out_file : text open write_mode is "test_out.txt";
        variable text_line :line ;
        variable out_line :line;
        variable ok : boolean;
        variable testin1 : std_logic_vector(31 downto 0); --replace with sipo
        variable testin2 : std_logic_vector(31 downto 0); --replace with sipo
        variable testin3 : std_logic_vector(31 downto 0); --replace with sipo

        variable testout1 : std_logic_vector(31 downto 0); --replace with sipo
        variable testout2 : std_logic_vector(31 downto 0); --replace with sipo
        variable testout3 : std_logic_vector(31 downto 0); --replace with sipo
        variable testfin : std_logic_vector(33 downto 0); --replace with sipo

        constant ZERO_20 : std_logic_vector(19 downto 0) := (others => '0');
        constant ZERO_32 : std_logic_vector(31 downto 0) := (others => '0');
        variable testin_addr : std_logic_vector(31 downto 0); --replace
                                                              --with sipo
        variable flit66 : std_logic_vector(71 downto 0);--(103 downto 0);
        variable flit34 : std_logic_vector(39 downto 0);--(71 downto 0);

        variable source : source_t ;
        variable addr,addr_r : addr_t;

        variable end_trace : std_logic_vector(1 to 6);
        variable testout : std_logic_vector(73 downto 0);

      begin

        ahbsi_sim.hsel       <= (others=>'0');
        ahbsi_sim.haddr      <= (others=>'0');
        ahbsi_sim.hwrite     <= '0';
        ahbsi_sim.htrans     <= HTRANS_NONSEQ;
        ahbsi_sim.hsize      <= (others=>'0');
        ahbsi_sim.hburst     <= (others=>'0');
        ahbsi_sim.hwdata     <= (others=>'0');
        ahbsi_sim.hprot      <= (others=>'0');
        ahbsi_sim.hready     <= '1';
        ahbsi_sim.hmaster    <= (others=>'0');
        ahbsi_sim.hmastlock  <= '0';
        ahbsi_sim.hmbsel     <= (others=>'0');
        ahbsi_sim.hirq       <= (others=>'0');
        ahbsi_sim.testen     <= '0';
        ahbsi_sim.testrst    <= '0';
        ahbsi_sim.scanen     <= '0';
        ahbsi_sim.testoen    <= '0';
        ahbsi_sim.testin     <= (others=>'0');

        source(1) := "100000";
        source(2) := "010000";
        source(3) := "001000";
        source(4) := "000100";
        source(5) := "000010";
        source(6) := "000001";


        addr(0):= std_logic_vector(to_unsigned(16#00010000#, 32));
        addr(1):= std_logic_vector(to_unsigned(16#00010001#, 32));
        addr(2):= std_logic_vector(to_unsigned(16#00010002#, 32));
        addr(3):= std_logic_vector(to_unsigned(16#00010003#, 32));
        addr(4):= std_logic_vector(to_unsigned(16#00010004#, 32));
        addr(5):= std_logic_vector(to_unsigned(16#00010005#, 32));
        addr(6):= std_logic_vector(to_unsigned(16#00010006#, 32));
        addr(7):= std_logic_vector(to_unsigned(16#00010007#, 32));
        addr(8):= std_logic_vector(to_unsigned(16#00010008#, 32));
        addr(9):= std_logic_vector(to_unsigned(16#00010009#, 32));
        addr(10):= std_logic_vector(to_unsigned(16#0001000A#, 32));
        addr(11):= std_logic_vector(to_unsigned(16#0001000B#, 32));
        addr(12):= std_logic_vector(to_unsigned(16#0001000C#, 32));
        addr(13):= std_logic_vector(to_unsigned(16#0001000D#, 32));
        addr(14):= std_logic_vector(to_unsigned(16#0001000E#, 32));
        addr(15):= std_logic_vector(to_unsigned(16#0001000F#, 32));
        addr(16):= std_logic_vector(to_unsigned(16#00010010#, 32));
        addr(17):= std_logic_vector(to_unsigned(16#00010011#, 32));

        addr_r(0):= std_logic_vector(to_unsigned(16#00010100#, 32));
        addr_r(1):= std_logic_vector(to_unsigned(16#00010101#, 32));
        addr_r(2):= std_logic_vector(to_unsigned(16#00010102#, 32));
        addr_r(3):= std_logic_vector(to_unsigned(16#00010103#, 32));
        addr_r(4):= std_logic_vector(to_unsigned(16#00010104#, 32));
        addr_r(5):= std_logic_vector(to_unsigned(16#00010105#, 32));
        addr_r(6):= std_logic_vector(to_unsigned(16#00010106#, 32));
        addr_r(7):= std_logic_vector(to_unsigned(16#00010107#, 32));
        addr_r(8):= std_logic_vector(to_unsigned(16#00010108#, 32));
        addr_r(9):= std_logic_vector(to_unsigned(16#00010109#, 32));
        addr_r(10):= std_logic_vector(to_unsigned(16#0001010A#, 32));
        addr_r(11):= std_logic_vector(to_unsigned(16#0001010B#, 32));
        addr_r(12):= std_logic_vector(to_unsigned(16#0001010C#, 32));
        addr_r(13):= std_logic_vector(to_unsigned(16#0001010D#, 32));
        addr_r(14):= std_logic_vector(to_unsigned(16#0001010E#, 32));
        addr_r(15):= std_logic_vector(to_unsigned(16#0001010F#, 32));
        addr_r(16):= std_logic_vector(to_unsigned(16#00010110#, 32));
        addr_r(17):= std_logic_vector(to_unsigned(16#00010111#, 32));



        testout := (others => '0');
        end_trace := (others => '0');

        wait for 2600 ns;

        while true loop

          ahbsi_sim.hsel(0)<='1';
          ahbsi_sim.hwrite<='1';


          if not endfile(text_file1) then
            readline(text_file1, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(1) & "0" & flit66(0) & "1" & ZERO_20;
            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(0);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(1);
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3
            ahbsi_sim.haddr(31 downto 0)<= addr(2);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          elsif (end_trace(1)/='1') then
            assert false report "end trace " & integer'image(1)  severity note;
            end_trace(1) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(0);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);
            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(1);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(2);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(1)  severity note;

          if not endfile(text_file2) then
            readline(text_file2, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(2) & "0" & flit66(0) & "1" & ZERO_20;

            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(3);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(4);
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.haddr(31 downto 0)<= addr(5);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
          elsif (end_trace(2)/='1') then
            assert false report "end trace " & integer'image(2)  severity note;
            end_trace(2) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(3);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(4);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;
            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(5);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(2)  severity note;
          if not endfile(text_file3) then
            readline(text_file3, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(2) & "0" & flit66(0) & "1" & ZERO_20;

            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(6);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(7);
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.haddr(31 downto 0)<= addr(8);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          elsif (end_trace(3)/='1') then
            assert false report "end trace " & integer'image(3)  severity note;
            end_trace(3) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(6);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(7);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            -- --free the bus and wait for 4 clock cycles

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(8);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            -- --free the bus and wait for 4 clock cycles

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(3)  severity note;

          if not endfile(text_file4) then
            readline(text_file4, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(4) & "0" & flit66(0) & "1" & ZERO_20;

            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(9);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(10);
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.haddr(31 downto 0)<= addr(11);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          elsif (end_trace(4)/='1') then
            assert false report "end trace " & integer'image(4)  severity note;
            end_trace(4) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(9);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(10);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);


            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(11);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(4)  severity note;

          if not endfile(text_file5) then
            readline(text_file5, text_line);
            hread(text_line, flit34, ok);
            testin1 := ZERO_32;
            testin2 := X"00000" & "0" & flit34( MISC_NOC_FLIT_SIZE + 4 - 1 downto 27);
            testin3 := flit34(26 downto 4)& source(5) & "0" & flit34(0) & "1";

            if flit34(0)='0' then

              hwrite(out_line, flit34(MISC_NOC_FLIT_SIZE + 4 - 1 downto 4),right, 4);
              hwrite(out_line, flit34(0 downto 0), right, 4);
              writeline(out_file0,out_line);

            end if;

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(12);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);


            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(13);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);


            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(14);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          elsif (end_trace(5)/='1') then
            assert false report "end trace " & integer'image(5)  severity note;
            end_trace(5) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(12);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(13);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);


            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(14);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(5)  severity note;

          if not endfile(text_file6) then
            readline(text_file6, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(6) & "0" & flit66(0) & "1" & ZERO_20;


            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(15);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(16);

            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3


            ahbsi_sim.haddr(31 downto 0)<= addr(17);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);


          elsif (end_trace(6)/='1') then
            assert false report "end trace " & integer'image(6)  severity note;
            end_trace(6) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(15);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);
            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(16);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(17);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;
            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(6)  severity note;

          wait until rising_edge(tclk_sim);

          ahbsi_sim.haddr(31 downto 0)<= (others=>'0');

          wait until rising_edge(tclk_sim);

          ahbsi_sim.hsel(0)<='1';
          ahbsi_sim.hready<='1';

          wait until rising_edge(tclk_sim);

          ahbsi_sim.hsel(0)<='0';
          ahbsi_sim.hready<='0';

          wait until rising_edge(tclk_sim);

          for i in 1 to 6 loop

            -- READ FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr_r((i-1)*3);
            ahbsi_sim.hready <='1';

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hready<='0';

            wait until rising_edge(ahbso_sim.hready);

            testout1 := ahbso_sim.hrdata(31 downto 0);



            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);


            -- READ FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr_r((i-1)*3+1);
            ahbsi_sim.hready <='1';

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hready<='0';

            wait until rising_edge(ahbso_sim.hready);

            testout2 := ahbso_sim.hrdata(31 downto 0);


            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- READ FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr_r((i-1)*3+2);
            ahbsi_sim.hready <='1';

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr_r((i-1)*3+2);
            ahbsi_sim.hready <='1';

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hready<='0';

            wait until rising_edge(ahbso_sim.hready) ;
            testout3 := ahbso_sim.hrdata(31 downto 0);

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            if testout1/=X"00000000" or testout2/=X"00000000" or testout3/=X"00000000" then
              testfin:=testout2(8 downto 0) &  testout1(31 downto 7);
              hwrite(out_line, testfin, right, 4);
              hwrite(out_line, testout1(6 downto 6), right, 4);
              writeline(out_file1, out_line);
            end if;

          end loop;
        end loop;
      end process;
      -- pragma translate_on
      
    end generate jtag_gen_sim;
    
  end generate jtag_driver_gen;
  
end architecture rtl;
