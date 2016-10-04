------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2016, Cobham Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	nandtree
-- File:	nandtree.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Nand-tree with tech mapping
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity nandtree is
  generic(
    tech     :  integer := inferred;
    width    :  integer := 2;
    imp      :  integer := 0 );
  port( i :  in  std_logic_vector(width-1 downto 0); 
	o :  out std_ulogic;
	en :  in std_ulogic
  );
end entity;

architecture rtl of nandtree is

  component rh_lib18t_nand_tree
  generic (npins : integer := 2);
  port(
       -- Input Signlas: --
       TEST_MODE      : in  std_logic;
       IN_PINS_BUS    : in  std_logic_vector(npins-1 downto 0);
       NAND_TREE_OUT  : out std_logic
    );  
  end component;

  function fnandtree(v : std_logic_vector) return std_ulogic is
  variable a : std_logic_vector(v'length-1 downto 0);
  variable b : std_logic_vector(v'length downto 0);
  begin

    a := v; b(0) := '1';

    for i in 0 to v'length-1 loop
      b(i+1) := a(i) nand b(i);
    end loop;

    return b(v'length);

  end;
begin

  behav : if tech /= rhlib18t generate
    o <= fnandtree(i);
  end generate;

  rhlib : if tech = rhlib18t generate
    rhnand : rh_lib18t_nand_tree generic map (width)
      port map (en, i, o);  
  end generate;

end;

