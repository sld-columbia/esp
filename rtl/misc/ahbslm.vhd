-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use work.esp_global.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.misc.all;
use work.devices.all;
use work.gencomp.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
-- pragma translate_on

entity ahbslm is
  generic (
    SIMULATION : boolean := false;
    hindex : integer := 0;
    tech   : integer := DEFMEMTECH;
    kbytes : integer := 256
    );
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    haddr : in  integer range 0 to 4095;
    hmask : in  integer range 0 to 4095;
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type
    );
end;

architecture rtl of ahbslm is

begin

  -- pragma translate_off
  syn_gen : if (SIMULATION = false) generate
  -- pragma translate_on

    ahbram_i: ahbram
      generic map (
        hindex     => hindex,
        tech       => tech,
        large_banks => 1,
        kbytes     => kbytes,
        pipe       => 0,
        maccsz     => ARCH_BITS
        )
      port map (
        rst   => rst,
        clk   => clk,
        haddr => haddr,
        hmask => hmask,
        ahbsi => ahbsi,
        ahbso => ahbso);

  -- pragma translate_off
  end generate;
  -- pragma translate_on

  -- pragma translate_off
  sim_gen : if (SIMULATION = true) generate

    ahbram_sim_i : ahbram_sim
      generic map (
        hindex => hindex,
        tech   => 0,
        kbytes => kbytes,
        pipe   => 0,
        maccsz => ARCH_BITS,
        fname  => "ram.srec"
        )
      port map(
        rst   => rst,
        clk   => clk,
        haddr => haddr,
        hmask => hmask,
        ahbsi => ahbsi,
        ahbso => ahbso
        );

  end generate;
  -- pragma translate_on

end;
