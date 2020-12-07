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
-- Entity: 	syncram64
-- File:	syncram64.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	64-bit syncronous 1-port ram with 32-bit write strobes
--		and tech selection
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allmem.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity syncram64 is
  generic (tech : integer := 0; abits : integer := 6; testen : integer := 0;
	   paren : integer := 0; custombits : integer := 1);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63+8*paren downto 0);
    dataout : out std_logic_vector (63+8*paren downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0);
    testin  : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none
    );
end;

architecture rtl of syncram64 is
  component unisim_syncram64
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63 downto 0);
    dataout : out std_logic_vector (63 downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0)
  );
  end component;


signal dinp, doutp : std_logic_vector(71 downto 0);
signal xenable : std_logic_vector(1 downto 0);

  signal custominx,customoutx: std_logic_vector(syncram_customif_maxwidth downto 0);

begin
  xenable <= enable when testen=0 or testin(TESTIN_WIDTH-2)='0' else "00";

    custominx <= (others => '0');
  nocust: if syncram_has_customif(tech)=0 or has_sram64(tech)=0 or paren=1 generate
    customoutx <= (others => '0');
  end generate;

nopar : if paren = 0 generate

  s64 : if has_sram64(tech) = 1 generate
    xc2v : if (is_unisim(tech) = 1) generate
      x0 : unisim_syncram64 generic map (abits)
         port map (clk, address, datain(63 downto 0), dataout(63 downto 0), xenable, write);
    end generate;

-- pragma translate_off
    dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
      x : process
      begin
        assert false report "syncram64: " & tost(2**abits) & "x64" &
         " (" & tech_table(tech) & ")"
        severity note;
        wait;
      end process;
    end generate;
-- pragma translate_on
  end generate;

  nos64 : if has_sram64(tech) = 0 generate
    x0 : syncram generic map (tech, abits, 32, testen, custombits)
         port map (clk, address, datain(63 downto 32), dataout(63 downto 32),
	           enable(1), write(1), testin
                   );
    x1 : syncram generic map (tech, abits, 32, testen, custombits)
         port map (clk, address, datain(31 downto 0), dataout(31 downto 0),
	           enable(0), write(0), testin
                   );
  end generate;
end generate;

par : if paren = 1 generate
    dinp <= datain(63+8*paren downto 60+8*paren) &  datain(63 downto 32) &
            datain(63+4*paren downto 60+4*paren) &  datain(31 downto 0);
    dataout <= doutp(71 downto 68) & doutp(35 downto 32) &
	       doutp(67 downto 36) & doutp(31-8+8*paren downto 0);
    x0 : syncram generic map (tech, abits, 36, testen, custombits)
         port map (clk, address, dinp(71 downto 36), doutp(71 downto 36),
	           enable(1), write(1), testin
                   );
    x1 : syncram generic map (tech, abits, 36, testen, custombits)
         port map (clk, address, dinp(35 downto 0), doutp(35 downto 0),
	           enable(0), write(0), testin
                   );
end generate;

end;
