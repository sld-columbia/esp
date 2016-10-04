-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2012-2013, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : ProDesign generic HDL components
--  Module/Entity : fpga_wrapper_pkg.vhd
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  Wrappers for FPGA primitives (entity and cmponent)
-- =============================================================================
-------------
-- Entity  --
-------------
library ieee;
use ieee.std_logic_1164.all;
--! OSERDES
entity OSERDES_WRAPPER is
  generic (
    DATA_RATE_OQ     : string  := "DDR";
    DATA_RATE_TQ     : string  := "DDR";
    DATA_WIDTH       : integer := 4;
    INIT_OQ          : bit     := '0';
    INIT_TQ          : bit     := '0';
    SERDES_MODE      : string  := "MASTER";
    SRVAL_OQ         : bit     := '0';
    SRVAL_TQ         : bit     := '0';
    TBYTE_CTL        : string  := "FALSE";
    TBYTE_SRC        : string  := "FALSE";
    TRISTATE_WIDTH   : integer := 4);
  port (
    OFB              : out std_ulogic;
    OQ               : out std_ulogic;
    SHIFTOUT1        : out std_ulogic;
    SHIFTOUT2        : out std_ulogic;
    TBYTEOUT         : out std_ulogic;
    TFB              : out std_ulogic;
    TQ               : out std_ulogic;
    CLK              : in  std_ulogic;
    CLKDIV           : in  std_ulogic;
    D1               : in  std_ulogic;
    D2               : in  std_ulogic;
    D3               : in  std_ulogic;
    D4               : in  std_ulogic;
    D5               : in  std_ulogic;
    D6               : in  std_ulogic;
    D7               : in  std_ulogic;
    D8               : in  std_ulogic;
    OCE              : in  std_ulogic;
    RST              : in  std_ulogic;
    SHIFTIN1         : in  std_ulogic;
    SHIFTIN2         : in  std_ulogic;
    T1               : in  std_ulogic;
    T2               : in  std_ulogic;
    T3               : in  std_ulogic;
    T4               : in  std_ulogic;
    TBYTEIN          : in  std_ulogic;
    TCE              : in  std_ulogic);
end entity OSERDES_WRAPPER;

library ieee;
use ieee.std_logic_1164.all;
--! ODELAY
entity ODELAY_WRAPPER is
  generic(
    CINVCTRL_SEL          : string  := "FALSE";
    DELAY_SRC             : string  := "ODATAIN";
    HIGH_PERFORMANCE_MODE : string  := "FALSE";
    ODELAY_TYPE           : string  := "FIXED";
    ODELAY_VALUE          : integer := 0;
    PIPE_SEL              : string  := "FALSE";
    REFCLK_FREQUENCY      : real    := 200.0;
    SIGNAL_PATTERN        : string  := "DATA");
  port(
    CNTVALUEOUT           : out std_logic_vector(4 downto 0);
    DATAOUT               : out std_ulogic;
    C                     : in  std_ulogic;
    CE                    : in  std_ulogic;
    CINVCTRL              : in  std_ulogic;
    CLKIN                 : in  std_ulogic;
    CNTVALUEIN            : in  std_logic_vector(4 downto 0);
    INC                   : in  std_ulogic;
    LD                    : in  std_ulogic;
    LDPIPEEN              : in  std_ulogic;
    ODATAIN               : in  std_ulogic;
    REGRST                : in  std_ulogic);
end entity ODELAY_WRAPPER;

library ieee;
use ieee.std_logic_1164.all;
--! IDELAY
entity IDELAY_WRAPPER is
  generic(
    CINVCTRL_SEL          : string  := "FALSE";
    DELAY_SRC             : string  := "IDATAIN";
    HIGH_PERFORMANCE_MODE : string  := "FALSE";
    IDELAY_TYPE           : string  := "FIXED";
    IDELAY_VALUE          : integer := 0;
    PIPE_SEL              : string  := "FALSE";
    REFCLK_FREQUENCY      : real    := 200.0;
    SIGNAL_PATTERN        : string  := "DATA");
  port(
    CNTVALUEOUT           : out std_logic_vector(4 downto 0);
    DATAOUT               : out std_ulogic;
    C                     : in  std_ulogic;
    CE                    : in  std_ulogic;
    CINVCTRL              : in  std_ulogic;
    CNTVALUEIN            : in  std_logic_vector(4 downto 0);
    DATAIN                : in  std_ulogic;
    IDATAIN               : in  std_ulogic;
    INC                   : in  std_ulogic;
    LD                    : in  std_ulogic;
    LDPIPEEN              : in  std_ulogic;
    REGRST                : in  std_ulogic);
end entity IDELAY_WRAPPER;

library ieee;
use ieee.std_logic_1164.all;
--! ISERDES
entity ISERDES_WRAPPER is
  generic (
    DATA_RATE         : string  := "DDR";
    DATA_WIDTH        : integer := 4;
    DYN_CLKDIV_INV_EN : string  := "FALSE";
    DYN_CLK_INV_EN    : string  := "FALSE";
    INIT_Q1           : bit     := '0';
    INIT_Q2           : bit     := '0';
    INIT_Q3           : bit     := '0';
    INIT_Q4           : bit     := '0';
    INTERFACE_TYPE    : string  := "MEMORY";
    IOBDELAY          : string  := "NONE";
    NUM_CE            : integer := 2;
    OFB_USED          : string  := "FALSE";
    SERDES_MODE       : string  := "MASTER";
    SRVAL_Q1          : bit     := '0';
    SRVAL_Q2          : bit     := '0';
    SRVAL_Q3          : bit     := '0';
    SRVAL_Q4          : bit     := '0');
  port (
    O                 : out std_ulogic;
    Q1                : out std_ulogic;
    Q2                : out std_ulogic;
    Q3                : out std_ulogic;
    Q4                : out std_ulogic;
    Q5                : out std_ulogic;
    Q6                : out std_ulogic;
    Q7                : out std_ulogic;
    Q8                : out std_ulogic;
    SHIFTOUT1         : out std_ulogic;
    SHIFTOUT2         : out std_ulogic;
    BITSLIP           : in std_ulogic;
    CE1               : in std_ulogic;
    CE2               : in std_ulogic;
    CLK               : in std_ulogic;
    CLKB              : in std_ulogic;
    CLKDIV            : in std_ulogic;
    CLKDIVP           : in std_ulogic;
    D                 : in std_ulogic;
    DDLY              : in std_ulogic;
    DYNCLKDIVSEL      : in std_ulogic;
    DYNCLKSEL         : in std_ulogic;
    OCLK              : in std_ulogic;
    OCLKB             : in std_ulogic;
    OFB               : in std_ulogic;
    RST               : in std_ulogic;
    SHIFTIN1          : in std_ulogic;
    SHIFTIN2          : in std_ulogic);
end entity ISERDES_WRAPPER;

library ieee;
use ieee.std_logic_1164.all;
--! IBUF
entity IBUF_WRAPPER is
  generic(
    CAPACITANCE      : string  := "DONT_CARE";
    IBUF_DELAY_VALUE : string  := "0";
    IBUF_LOW_PWR     : boolean :=  TRUE;
    IFD_DELAY_VALUE  : string  := "AUTO";
    IOSTANDARD       : string  := "DEFAULT");
  port(
    O                : out std_ulogic;
    I                : in  std_ulogic);
end entity IBUF_WRAPPER;

library ieee;
use ieee.std_logic_1164.all;
--! IBUFDS
entity IBUFDS_WRAPPER is
  generic(
    CAPACITANCE      : string  := "DONT_CARE";
    DIFF_TERM        : boolean :=  FALSE;
    DQS_BIAS         : string  :=  "FALSE";
    IBUF_DELAY_VALUE : string  := "0";
    IBUF_LOW_PWR     : boolean :=  TRUE;
    IFD_DELAY_VALUE  : string  := "AUTO";
    IOSTANDARD       : string  := "DEFAULT");
  port(
    O                : out std_ulogic;
    I                : in  std_ulogic;
    IB               : in  std_ulogic);
end entity IBUFDS_WRAPPER;

library ieee;
use ieee.std_logic_1164.all;
--! IBUFGDS
entity IBUFGDS_WRAPPER is
  generic(
   CAPACITANCE      : string  := "DONT_CARE";
   DIFF_TERM        : boolean :=  FALSE;
   IBUF_DELAY_VALUE : string  := "0";
   IBUF_LOW_PWR     : boolean :=  TRUE;
   IOSTANDARD       : string  := "DEFAULT");
  port(
    O               : out std_ulogic;
    I               : in  std_ulogic;
    IB              : in  std_ulogic);
end entity IBUFGDS_WRAPPER;

library ieee;
use ieee.std_logic_1164.all;
--! IDELAYCTRL
entity IDELAYCTRL_WRAPPER is
  port(
    RDY    : out std_ulogic;
    REFCLK : in  std_ulogic;
    RST    : in  std_ulogic);
end entity IDELAYCTRL_WRAPPER;

library ieee;
use ieee.std_logic_1164.all;
--! OBUF
entity OBUF_WRAPPER is
  generic(
    CAPACITANCE : string  := "DONT_CARE";
    DRIVE       : integer := 12;
    IOSTANDARD  : string  := "DEFAULT";
    SLEW        : string  := "SLOW");
  port(
    O           : out std_ulogic;
    I           : in  std_ulogic);
end entity OBUF_WRAPPER;

library ieee;
use ieee.std_logic_1164.all;
--! OBUFDS
entity OBUFDS_WRAPPER is
  generic(
    CAPACITANCE : string  := "DONT_CARE";
    IOSTANDARD  : string  := "DEFAULT";
    SLEW        : string  := "SLOW");
  port(
    O           : out std_ulogic;
    OB          : out std_ulogic;
    I           : in  std_ulogic);
end entity OBUFDS_WRAPPER;

------------------------
-- Component/Package  --
------------------------

library ieee;
use ieee.std_logic_1164.all;
package fpga_wrapper_pkg is
  component OSERDES_WRAPPER is
    generic (
      DATA_RATE_OQ     : string  := "DDR";
      DATA_RATE_TQ     : string  := "DDR";
      DATA_WIDTH       : integer := 4;
      INIT_OQ          : bit     := '0';
      INIT_TQ          : bit     := '0';
      SERDES_MODE      : string  := "MASTER";
      SRVAL_OQ         : bit     := '0';
      SRVAL_TQ         : bit     := '0';
      TBYTE_CTL        : string  := "FALSE";
      TBYTE_SRC        : string  := "FALSE";
      TRISTATE_WIDTH   : integer := 4);
    port (
      OFB              : out std_ulogic;
      OQ               : out std_ulogic;
      SHIFTOUT1        : out std_ulogic;
      SHIFTOUT2        : out std_ulogic;
      TBYTEOUT         : out std_ulogic;
      TFB              : out std_ulogic;
      TQ               : out std_ulogic;
      CLK              : in  std_ulogic;
      CLKDIV           : in  std_ulogic;
      D1               : in  std_ulogic;
      D2               : in  std_ulogic;
      D3               : in  std_ulogic;
      D4               : in  std_ulogic;
      D5               : in  std_ulogic;
      D6               : in  std_ulogic;
      D7               : in  std_ulogic;
      D8               : in  std_ulogic;
      OCE              : in  std_ulogic;
      RST              : in  std_ulogic;
      SHIFTIN1         : in  std_ulogic;
      SHIFTIN2         : in  std_ulogic;
      T1               : in  std_ulogic;
      T2               : in  std_ulogic;
      T3               : in  std_ulogic;
      T4               : in  std_ulogic;
      TBYTEIN          : in  std_ulogic;
      TCE              : in  std_ulogic);
  end component OSERDES_WRAPPER;

  component ODELAY_WRAPPER is
    generic(
      CINVCTRL_SEL          : string  := "FALSE";
      DELAY_SRC             : string  := "ODATAIN";
      HIGH_PERFORMANCE_MODE : string  := "FALSE";
      ODELAY_TYPE           : string  := "FIXED";
      ODELAY_VALUE          : integer := 0;
      PIPE_SEL              : string  := "FALSE";
      REFCLK_FREQUENCY      : real    := 200.0;
      SIGNAL_PATTERN        : string  := "DATA");
    port(
      CNTVALUEOUT : out std_logic_vector(4 downto 0);
      DATAOUT     : out std_ulogic;
      C           : in  std_ulogic;
      CE          : in  std_ulogic;
      CINVCTRL    : in  std_ulogic;
      CLKIN       : in  std_ulogic;
      CNTVALUEIN  : in  std_logic_vector(4 downto 0);
      INC         : in  std_ulogic;
      LD          : in  std_ulogic;
      LDPIPEEN    : in  std_ulogic;
      ODATAIN     : in  std_ulogic;
      REGRST      : in  std_ulogic
    );
  end component ODELAY_WRAPPER;

  component IDELAY_WRAPPER is
    generic(
      CINVCTRL_SEL          : string  := "FALSE";
      DELAY_SRC             : string  := "IDATAIN";
      HIGH_PERFORMANCE_MODE : string  := "FALSE";
      IDELAY_TYPE           : string  := "FIXED";
      IDELAY_VALUE          : integer := 0;
      PIPE_SEL              : string  := "FALSE";
      REFCLK_FREQUENCY      : real    := 200.0;
      SIGNAL_PATTERN        : string  := "DATA");
    port(
      CNTVALUEOUT           : out std_logic_vector(4 downto 0);
      DATAOUT               : out std_ulogic;
      C                     : in  std_ulogic;
      CE                    : in  std_ulogic;
      CINVCTRL              : in  std_ulogic;
      CNTVALUEIN            : in  std_logic_vector(4 downto 0);
      DATAIN                : in  std_ulogic;
      IDATAIN               : in  std_ulogic;
      INC                   : in  std_ulogic;
      LD                    : in  std_ulogic;
      LDPIPEEN              : in  std_ulogic;
      REGRST                : in  std_ulogic);
  end component IDELAY_WRAPPER;

  component ISERDES_WRAPPER is
    generic (
      DATA_RATE         : string  := "DDR";
      DATA_WIDTH        : integer := 4;
      DYN_CLKDIV_INV_EN : string  := "FALSE";
      DYN_CLK_INV_EN    : string  := "FALSE";
      INIT_Q1           : bit     := '0';
      INIT_Q2           : bit     := '0';
      INIT_Q3           : bit     := '0';
      INIT_Q4           : bit     := '0';
      INTERFACE_TYPE    : string  := "MEMORY";
      IOBDELAY          : string  := "NONE";
      NUM_CE            : integer := 2;
      OFB_USED          : string  := "FALSE";
      SERDES_MODE       : string  := "MASTER";
      SRVAL_Q1          : bit     := '0';
      SRVAL_Q2          : bit     := '0';
      SRVAL_Q3          : bit     := '0';
      SRVAL_Q4          : bit     := '0');
    port (
      O                 : out std_ulogic;
      Q1                : out std_ulogic;
      Q2                : out std_ulogic;
      Q3                : out std_ulogic;
      Q4                : out std_ulogic;
      Q5                : out std_ulogic;
      Q6                : out std_ulogic;
      Q7                : out std_ulogic;
      Q8                : out std_ulogic;
      SHIFTOUT1         : out std_ulogic;
      SHIFTOUT2         : out std_ulogic;
      BITSLIP           : in std_ulogic;
      CE1               : in std_ulogic;
      CE2               : in std_ulogic;
      CLK               : in std_ulogic;
      CLKB              : in std_ulogic;
      CLKDIV            : in std_ulogic;
      CLKDIVP           : in std_ulogic;
      D                 : in std_ulogic;
      DDLY              : in std_ulogic;
      DYNCLKDIVSEL      : in std_ulogic;
      DYNCLKSEL         : in std_ulogic;
      OCLK              : in std_ulogic;
      OCLKB             : in std_ulogic;
      OFB               : in std_ulogic;
      RST               : in std_ulogic;
      SHIFTIN1          : in std_ulogic;
      SHIFTIN2          : in std_ulogic);
  end component ISERDES_WRAPPER;

  component IBUF_WRAPPER is
    generic(
      CAPACITANCE      : string  := "DONT_CARE";
      IBUF_DELAY_VALUE : string  := "0";
      IBUF_LOW_PWR     : boolean :=  TRUE;
      IFD_DELAY_VALUE  : string  := "AUTO";
      IOSTANDARD       : string  := "DEFAULT");
    port(
      O                : out std_ulogic;
      I                : in  std_ulogic);
  end component IBUF_WRAPPER;

  component IBUFDS_WRAPPER is
    generic(
      CAPACITANCE      : string  := "DONT_CARE";
      DIFF_TERM        : boolean :=  FALSE;
      DQS_BIAS         : string  :=  "FALSE";
      IBUF_DELAY_VALUE : string  := "0";
      IBUF_LOW_PWR     : boolean :=  TRUE;
      IFD_DELAY_VALUE  : string  := "AUTO";
      IOSTANDARD       : string  := "DEFAULT");
    port(
      O                : out std_ulogic;
      I                : in  std_ulogic;
      IB               : in  std_ulogic);
  end component IBUFDS_WRAPPER;

  component IBUFGDS_WRAPPER is
    generic(
    CAPACITANCE      : string  := "DONT_CARE";
    DIFF_TERM        : boolean :=  FALSE;
    IBUF_DELAY_VALUE : string  := "0";
    IBUF_LOW_PWR     : boolean :=  TRUE;
    IOSTANDARD       : string  := "DEFAULT");
    port(
      O               : out std_ulogic;
      I               : in  std_ulogic;
      IB              : in  std_ulogic);
  end component IBUFGDS_WRAPPER;

  component IDELAYCTRL_WRAPPER is
    port(
      RDY    : out std_ulogic;
      REFCLK : in  std_ulogic;
      RST    : in  std_ulogic);
  end component IDELAYCTRL_WRAPPER;

  component OBUF_WRAPPER is
    generic(
      CAPACITANCE : string  := "DONT_CARE";
      DRIVE       : integer := 12;
      IOSTANDARD  : string  := "DEFAULT";
      SLEW        : string  := "SLOW");
    port(
      O           : out std_ulogic;
      I           : in  std_ulogic);
  end component OBUF_WRAPPER;

  component OBUFDS_WRAPPER is
    generic(
      CAPACITANCE : string  := "DONT_CARE";
      IOSTANDARD  : string  := "DEFAULT";
      SLEW        : string  := "SLOW");
    port(
      O           : out std_ulogic;
      OB          : out std_ulogic;
      I           : in  std_ulogic);
  end component OBUFDS_WRAPPER;
end package fpga_wrapper_pkg;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2012-12-26  First draft.
-- =============================================================================
