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
--  Module/Entity : fpga_wrapper_v7.vhd
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  Wrappers architecture for Virtex7 device
-- =============================================================================
-------------------
-- Architectures  --
-------------------
library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;

architecture VIRTEX7_ARCHIRECTURE of OSERDES_WRAPPER is
begin

  U_OSERDESE2  : OSERDESE2
  generic map(
    DATA_RATE_OQ   => DATA_RATE_OQ,
    DATA_RATE_TQ   => DATA_RATE_TQ,
    DATA_WIDTH     => DATA_WIDTH,
    INIT_OQ        => INIT_OQ,
    INIT_TQ        => INIT_TQ,
    SERDES_MODE    => SERDES_MODE,
    SRVAL_OQ       => SRVAL_OQ,
    SRVAL_TQ       => SRVAL_TQ,
    TBYTE_CTL      => TBYTE_CTL,
    TBYTE_SRC      => TBYTE_SRC,
    TRISTATE_WIDTH => TRISTATE_WIDTH
  ) port map(
   OFB             => OFB,
   OQ              => OQ,
   SHIFTOUT1       => SHIFTOUT1,
   SHIFTOUT2       => SHIFTOUT2,
   TBYTEOUT        => TBYTEOUT,
   TFB             => TFB,
   TQ              => TQ,
   CLK             => CLK,
   CLKDIV          => CLKDIV,
   D1              => D1,
   D2              => D2,
   D3              => D3,
   D4              => D4,
   D5              => D5,
   D6              => D6,
   D7              => D7,
   D8              => D8,
   OCE             => OCE,
   RST             => RST,
   SHIFTIN1        => SHIFTIN1,
   SHIFTIN2        => SHIFTIN2,
   T1              => T1,
   T2              => T2,
   T3              => T3,
   T4              => T4,
   TBYTEIN         => TBYTEIN,
   TCE             => TCE
  );
end architecture VIRTEX7_ARCHIRECTURE;

library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
architecture VIRTEX7_ARCHIRECTURE of ODELAY_WRAPPER is
begin
  --DATAOUT <= ODATAIN;

  U_ODELAYE2 : ODELAYE2
  generic map(
    CINVCTRL_SEL          => CINVCTRL_SEL,
    DELAY_SRC             => DELAY_SRC,
    HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
    ODELAY_TYPE           => ODELAY_TYPE,
    ODELAY_VALUE          => ODELAY_VALUE,
    PIPE_SEL              => PIPE_SEL,
    REFCLK_FREQUENCY      => REFCLK_FREQUENCY,
    SIGNAL_PATTERN        => SIGNAL_PATTERN
  ) port map (
    CNTVALUEOUT           => CNTVALUEOUT,
    DATAOUT               => DATAOUT,
    C                     => C,
    CE                    => CE,
    CINVCTRL              => CINVCTRL,
    CLKIN                 => CLKIN,
    CNTVALUEIN            => CNTVALUEIN,
    INC                   => INC,
    LD                    => LD,
    LDPIPEEN              => LDPIPEEN,
    ODATAIN               => ODATAIN,
    REGRST                => REGRST
  );


end architecture VIRTEX7_ARCHIRECTURE;


library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
architecture VIRTEX7_ARCHIRECTURE of IDELAY_WRAPPER is
begin
  U_IDELAYE2 : IDELAYE2
  generic map(
    CINVCTRL_SEL          => CINVCTRL_SEL,
    DELAY_SRC             => DELAY_SRC,
    HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
    IDELAY_TYPE           => IDELAY_TYPE,
    IDELAY_VALUE          => IDELAY_VALUE,
    PIPE_SEL              => PIPE_SEL,
    REFCLK_FREQUENCY      => REFCLK_FREQUENCY,
    SIGNAL_PATTERN        => SIGNAL_PATTERN
  ) port map(
    CNTVALUEOUT           => CNTVALUEOUT,
    DATAOUT               => DATAOUT,
    C                     => C,
    CE                    => CE,
    CINVCTRL              => CINVCTRL,
    CNTVALUEIN            => CNTVALUEIN,
    DATAIN                => DATAIN,
    IDATAIN               => IDATAIN,
    INC                   => INC,
    LD                    => LD,
    LDPIPEEN              => LDPIPEEN,
    REGRST                => REGRST
  );
end architecture VIRTEX7_ARCHIRECTURE;


library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
architecture VIRTEX7_ARCHIRECTURE of ISERDES_WRAPPER is
begin
  U_ISERDESE2 : ISERDESE2
  generic map(
    DATA_RATE         => DATA_RATE,
    DATA_WIDTH        => DATA_WIDTH,
    DYN_CLKDIV_INV_EN => DYN_CLKDIV_INV_EN,
    DYN_CLK_INV_EN    => DYN_CLK_INV_EN,
    INIT_Q1           => INIT_Q1,
    INIT_Q2           => INIT_Q2,
    INIT_Q3           => INIT_Q3,
    INIT_Q4           => INIT_Q4,
    INTERFACE_TYPE    => INTERFACE_TYPE,
    IOBDELAY          => IOBDELAY,
    NUM_CE            => NUM_CE,
    OFB_USED          => OFB_USED,
    SERDES_MODE       => SERDES_MODE,
    SRVAL_Q1          => SRVAL_Q1,
    SRVAL_Q2          => SRVAL_Q2,
    SRVAL_Q3          => SRVAL_Q3,
    SRVAL_Q4          => SRVAL_Q4
  ) port map(
    O                 => O,
    Q1                => Q1,
    Q2                => Q2,
    Q3                => Q3,
    Q4                => Q4,
    Q5                => Q5,
    Q6                => Q6,
    Q7                => Q7,
    Q8                => Q8,
    SHIFTOUT1         => SHIFTOUT1,
    SHIFTOUT2         => SHIFTOUT2,
    BITSLIP           => BITSLIP,
    CE1               => CE1,
    CE2               => CE2,
    CLK               => CLK,
    CLKB              => CLKB,
    CLKDIV            => CLKDIV,
    CLKDIVP           => CLKDIVP,
    D                 => D,
    DDLY              => DDLY,
    DYNCLKDIVSEL      => DYNCLKDIVSEL,
    DYNCLKSEL         => DYNCLKSEL,
    OCLK              => OCLK,
    OCLKB             => OCLKB,
    OFB               => OFB,
    RST               => RST,
    SHIFTIN1          => SHIFTIN1,
    SHIFTIN2          => SHIFTIN2
  );
end architecture VIRTEX7_ARCHIRECTURE;

library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
architecture VIRTEX7_ARCHIRECTURE of IBUF_WRAPPER is
begin
  U_IBUF : IBUF
  generic map (
    CAPACITANCE      => CAPACITANCE,
    IBUF_DELAY_VALUE => IBUF_DELAY_VALUE,
    IBUF_LOW_PWR     => IBUF_LOW_PWR,
    IFD_DELAY_VALUE  => IFD_DELAY_VALUE,
    IOSTANDARD       => IOSTANDARD
  ) port map(
    O                => O,
    I                => I
  );
end architecture VIRTEX7_ARCHIRECTURE;


library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
architecture VIRTEX7_ARCHIRECTURE of IBUFDS_WRAPPER is
begin
  U_IBUFDS : IBUFDS
  generic map(
    CAPACITANCE      => CAPACITANCE,
    DIFF_TERM        => DIFF_TERM,
    DQS_BIAS         => DQS_BIAS,
    IBUF_DELAY_VALUE => IBUF_DELAY_VALUE,
    IBUF_LOW_PWR     => IBUF_LOW_PWR,
    IFD_DELAY_VALUE  => IFD_DELAY_VALUE,
    IOSTANDARD       => IOSTANDARD
  ) port map(
    O                => O,
    I                => I,
    IB               => IB
  );
end architecture VIRTEX7_ARCHIRECTURE;

library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
architecture VIRTEX7_ARCHIRECTURE of IBUFGDS_WRAPPER is
begin
  U_IBUFGDS : IBUFGDS
  generic map (
    CAPACITANCE      => CAPACITANCE,
    DIFF_TERM        => DIFF_TERM,
    IBUF_DELAY_VALUE => IBUF_DELAY_VALUE,
    IBUF_LOW_PWR     => IBUF_LOW_PWR,
    IOSTANDARD       => IOSTANDARD
  ) port map(
    O               => O,
    I               => I,
    IB              => IB
  );
end architecture VIRTEX7_ARCHIRECTURE;

library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
architecture VIRTEX7_ARCHIRECTURE of IDELAYCTRL_WRAPPER is
begin
  U_IDELAYCTRL : IDELAYCTRL
  port map(
    RDY    => RDY,
    REFCLK => REFCLK,
    RST    => RST
  );
end architecture VIRTEX7_ARCHIRECTURE;

library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
architecture VIRTEX7_ARCHIRECTURE of OBUF_WRAPPER is
begin
  U_OBUF : OBUF
  generic map(
    CAPACITANCE => CAPACITANCE,
    DRIVE       => DRIVE,
    IOSTANDARD  => IOSTANDARD,
    SLEW        => SLEW
  ) port map (
    O           => O,
    I           => I
  );
end architecture VIRTEX7_ARCHIRECTURE;

library ieee;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
architecture VIRTEX7_ARCHIRECTURE of OBUFDS_WRAPPER is
begin
  u_OBUFDS : OBUFDS
  generic map(
    CAPACITANCE => CAPACITANCE,
    IOSTANDARD  => IOSTANDARD,
    SLEW        => SLEW
  ) port map(
    O           => O,
    OB          => OB,
    I           => I
  );
end architecture VIRTEX7_ARCHIRECTURE;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2012-12-26  First draft.
-- =============================================================================
