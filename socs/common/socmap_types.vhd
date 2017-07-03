------------------------------------------------------------------------------
--  Copyright (C) 2015-2017, System Level Design (SLD) @ Columbia University
-----------------------------------------------------------------------------
-- Package:     socmap_types
-- File:        socmap_types.vhd
-- Authors:     Paolo Mantovani
--              Davide Giri
-- Description: Defines unique IDs for SLD devices
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on

package socmap_types is

  -- TODO: find more elegant way of passing CPU_MAX and TILES_MAX
  -- NoC tiles layout information.
  constant CPU_MAX_NUM   : integer := 4;     -- Also defined in bin/socmap/socmap_gen.py
  constant CPU_MAX_NUM_STD : std_logic_vector(3 downto 0) := "0100";     -- Also defined in bin/socmap/socmap_gen.py
  constant TILES_MAX_NUM : integer := 16;
  subtype tile_cpu_id_type is integer range -1 to CPU_MAX_NUM;
  type tile_cpu_id_array is array (0 to TILES_MAX_NUM-1) of tile_cpu_id_type;
  --type tile_mem_id_array is array (0 to TILES_MAX_NUM-1) of tile_mem_id_type;

  type cpu_info_array is array (CPU_MAX_NUM-1 downto 0) of integer;


end;
