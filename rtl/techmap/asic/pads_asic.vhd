-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.esp_csr_pkg.all;

-------------------------------------------------------------------------------
-- Inpad
-------------------------------------------------------------------------------
entity asic_inpad is
  generic (
    PAD_TYPE : std_logic := '0');
  port (
    pad : in  std_ulogic;
    o   : out std_ulogic);
end;

architecture rtl of asic_inpad is

  component INPAD_H is
    port (
      PAD : in   std_logic;
      Y   : out  std_ulogic);
  end component INPAD_H;

  component INPAD_V is
    port (
      PAD : in   std_logic;
      Y   : out  std_ulogic);
  end component INPAD_V;

  signal pad_int : std_logic;

begin

  pad_int <= pad;

  pad_v_gen: if PAD_TYPE = '0' generate
    p_i: INPAD_V
      port map (
        PAD => pad_int,
        Y   => o);
  end generate pad_v_gen;

  pad_h_gen: if PAD_TYPE = '1' generate
    p_i: INPAD_H
      port map (
        PAD => pad_int,
        Y   => o);
  end generate pad_h_gen;

end;


-------------------------------------------------------------------------------
-- Inoutpad
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.esp_csr_pkg.all;

entity asic_iopad is
  generic (
    PAD_TYPE : std_logic := '0');
  port (
    pad : inout std_logic;
    i   : in    std_ulogic;
    en  : in    std_ulogic;
    o   : out   std_logic;
    cfg : in    std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0)
    );
end;

architecture rtl of asic_iopad is

  component IOPAD_H is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      CFG : in    std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0));
  end component IOPAD_H;

  component IOPAD_V is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      CFG : in    std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0));
  end component IOPAD_V;

begin

  pad_v_gen: if PAD_TYPE = '0' generate
    p_i: IOPAD_V
      port map (
        PAD => pad,
        Y   => o,
        A   => i,
        OE  => en,
        CFG => cfg);
  end generate pad_v_gen;

  pad_h_gen: if PAD_TYPE = '1' generate
    p_i: IOPAD_H
      port map (
        PAD => pad,
        Y   => o,
        A   => i,
        OE  => en,
        CFG => cfg);
  end generate pad_h_gen;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.esp_csr_pkg.all;

entity asic_iopadien is
  generic (
    PAD_TYPE : std_logic := '0');
  port (
    pad : inout std_logic;
    i   : in    std_ulogic;
    en  : in    std_ulogic;
    o   : out   std_logic;
    ien : in    std_ulogic;
    cfg : in    std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0)
    );
end;

architecture rtl of asic_iopadien is

  component IOPADIEN_H is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      CFG : in    std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
      IE  : in    std_ulogic);
  end component IOPADIEN_H;

  component IOPADIEN_V is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      CFG : in    std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
      IE  : in    std_ulogic);
  end component IOPADIEN_V;

begin

  pad_v_gen: if PAD_TYPE = '0' generate
    p_i: IOPADIEN_V
      port map (
        PAD => pad,
        Y   => o,
        A   => i,
        OE  => en,
        CFG => cfg,
        IE  => ien);
  end generate pad_v_gen;

  pad_h_gen: if PAD_TYPE = '1' generate
    p_i: IOPADIEN_H
      port map (
        PAD => pad,
        Y   => o,
        A   => i,
        OE  => en,
        CFG => cfg,
        IE  => ien);
  end generate pad_h_gen;

end;


-------------------------------------------------------------------------------
-- Outpad
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.esp_csr_pkg.all;

entity asic_outpad is
  generic (
    PAD_TYPE : std_logic := '0');
  port (
    pad  : out std_ulogic;
    i    : in  std_ulogic;
    cfg : in  std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0)
    );
end;

architecture rtl of asic_outpad is

  component OUTPAD_H is
    port (
      PAD : inout std_logic;
      A   : in    std_ulogic;
      CFG : in    std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0));
  end component OUTPAD_H;

  component OUTPAD_V is
    port (
      PAD : inout std_logic;
      A   : in    std_ulogic;
      CFG : in    std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0));
  end component OUTPAD_V;

  signal pad_int : std_logic;

begin

  pad <= pad_int;

  pad_v_gen: if PAD_TYPE = '0' generate
    p_i: OUTPAD_V
      port map (
        PAD => pad_int,
        A   => i,
        CFG => cfg);
  end generate pad_v_gen;

  pad_h_gen: if PAD_TYPE = '1' generate
    p_i: OUTPAD_H
      port map (
        PAD => pad_int,
        A   => i,
        CFG => cfg);
  end generate pad_h_gen;


end;

