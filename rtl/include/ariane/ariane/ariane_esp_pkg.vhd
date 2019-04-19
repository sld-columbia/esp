-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: MIT

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;

package ariane_esp_pkg is

  component ariane_axi_wrap is
    generic (
      HART_ID          : std_logic_vector(63 downto 0);
      NMST             : integer;
      NSLV             : integer;
      NIRQ_SRCS        : integer;
      AXI_ID_WIDTH     : integer;
      AXI_ID_WIDTH_SLV : integer;
      AXI_ADDR_WIDTH   : integer;
      AXI_DATA_WIDTH   : integer;
      AXI_USER_WIDTH   : integer;
      AXI_STRB_WIDTH   : integer;
      ROMBase          : std_logic_vector(63 downto 0);
      ROMLength        : std_logic_vector(63 downto 0);
      APBBase          : std_logic_vector(63 downto 0);
      APBLength        : std_logic_vector(63 downto 0);
      CLINTBase        : std_logic_vector(63 downto 0);
      CLINTLength      : std_logic_vector(63 downto 0);
      PLICBase         : std_logic_vector(63 downto 0);
      PLICLength       : std_logic_vector(63 downto 0);
      DRAMBase         : std_logic_vector(63 downto 0);
      DRAMLength       : std_logic_vector(63 downto 0));
    port (
      clk         : in  std_logic;
      rstn        : in  std_logic;
      irq_sources : in  std_logic_vector(NIRQ_SRCS-1 downto 0);
      romi        : out axi_mosi_type;
      romo        : in  axi_somi_type;
      drami       : out axi_mosi_type;
      dramo       : in  axi_somi_type;
      penable     : out std_logic;
      pwrite      : out std_logic;
      paddr       : out std_logic_vector(31 downto 0);
      psel        : out std_logic;
      pwdata      : out std_logic_vector(31 downto 0);
      prdata      : in  std_logic_vector(31 downto 0);
      pready      : in  std_logic);
  end component ariane_axi_wrap;

end ariane_esp_pkg;
