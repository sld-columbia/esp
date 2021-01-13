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
-- Entity: 	Various
-- File:	grgates.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Various gates with tech mapping
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allclkgen.all;

entity grmux2 is generic( tech : integer := inferred; imp :  integer := 0);
  port( ip0, ip1, sel : in std_logic; op : out std_ulogic); end;

architecture rtl of grmux2 is

begin

  op <= ip0 when sel = '0' else ip1;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
entity grmux2v is generic( tech : integer := inferred; 
	bits : integer := 2; imp :  integer := 0);
  port( ip0, ip1 : in std_logic_vector(bits-1 downto 0); 
        sel : in std_logic;
        op : out std_logic_vector(bits-1 downto 0));
end;

architecture rtl of grmux2v is
begin

  x0 : for i in bits-1 downto 0 generate
    y0 : grmux2 generic map (tech, imp) port map (ip0(i), ip1(i), sel, op(i));
  end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity grdff is generic( tech : integer := inferred; imp :  integer := 0);
  port( clk, d : in std_ulogic; q : out std_ulogic); end;

architecture rtl of grdff is


begin

  x0 : process(clk)
  begin if rising_edge(clk) then q <= d; end if; end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity gror2 is generic( tech : integer := inferred; imp :  integer := 0);
  port( i0, i1 : in std_ulogic; q : out std_ulogic); end;

architecture rtl of gror2 is

begin

  q <= i0 or i1;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity grand12 is generic( tech : integer := inferred; imp :  integer := 0);
  port( i0, i1 : in std_ulogic; q : out std_ulogic); end;

architecture rtl of grand12 is

begin

  q <= i0 and not i1;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity grnand2 is
  generic (
    tech: integer := 0;
    imp: integer := 0
    );
  port (
    i0: in  std_ulogic;
    i1: in  std_ulogic;
    q : out std_ulogic
    );
end;

architecture rtl of grnand2 is

begin

  q <= not (i0 and i1);

end;

