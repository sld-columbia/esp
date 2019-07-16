-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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
      ROMBase          : std_logic_vector(63 downto 0);
      ROMLength        : std_logic_vector(63 downto 0);
      APBBase          : std_logic_vector(63 downto 0);
      APBLength        : std_logic_vector(63 downto 0);
      CLINTBase        : std_logic_vector(63 downto 0);
      CLINTLength      : std_logic_vector(63 downto 0);
      PLICBase         : std_logic_vector(63 downto 0);
      PLICLength       : std_logic_vector(63 downto 0);
      DRAMBase         : std_logic_vector(63 downto 0);
      DRAMLength       : std_logic_vector(63 downto 0);
      DRAMCachedLength : std_logic_vector(63 downto 0));
    port (
      clk         : in  std_logic;
      rstn        : in  std_logic;
      irq_sources : in  std_logic_vector(NIRQ_SRCS-1 downto 0);
      romi        : out axi_mosi_type;
      romo        : in  axi_somi_type;
      drami       : out axi_mosi_type;
      dramo       : in  axi_somi_type;
      apbi        : out apb_slv_in_type;
      apbo        : in  apb_slv_out_vector;
      apb_req     : out std_ulogic;
      apb_ack     : in  std_ulogic);
  end component ariane_axi_wrap;


end ariane_esp_pkg;
