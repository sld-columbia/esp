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
-- Entity: 	syncram128
-- File:	syncram128.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	128-bit syncronous 1-port ram with 32-bit write strobes
--		and tech selection
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allmem.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity syncram128 is
  generic (tech : integer := 0; abits : integer := 6; testen : integer := 0;
	   paren : integer := 0; custombits : integer := 1);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127+16*paren downto 0);
    dataout : out std_logic_vector (127+16*paren downto 0);
    enable  : in  std_logic_vector (3 downto 0);
    write   : in  std_logic_vector (3 downto 0);
    testin  : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none
    );
end;

architecture rtl of syncram128 is
  component unisim_syncram128
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (3 downto 0);
    write   : in  std_logic_vector (3 downto 0)
  );
  end component;

signal dinp, doutp : std_logic_vector(143 downto 0);
signal xenable,xwrite : std_logic_vector(3 downto 0);

  signal custominx,customoutx: std_logic_vector(syncram_customif_maxwidth downto 0);

begin

  xenable <= enable when testen=0 or testin(TESTIN_WIDTH-2)='0' else "0000";
  xwrite <= write when testen=0 or testin(TESTIN_WIDTH-2)='0' else "0000";

    custominx <= (others => '0');
  
  nocust: if syncram_has_customif(tech)=0 or has_sram128(tech)=0 or paren=1 generate
    customoutx <= (others => '0');
  end generate;

nopar : if paren = 0 generate
  s128 : if has_sram128(tech) = 1 generate
    uni : if (is_unisim(tech) = 1) generate 
      x0 : unisim_syncram128 generic map (abits)
         port map (clk, address, datain, dataout, xenable, xwrite);
    end generate;
    n2x : if (tech = easic45) generate
      x0 : n2x_syncram_we generic map (abits => abits, dbits => 128)
        port map(clk, address, datain, dataout, xenable, xwrite);
    end generate;
-- pragma translate_off
    dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
      x : process
      begin
        assert false report "syncram128: " & tost(2**abits) & "x128" &
         " (" & tech_table(tech) & ")"
        severity note;
        wait;
      end process;
    end generate;
-- pragma translate_on
  end generate;

  nos128 : if has_sram128(tech) = 0 generate
    x0 : syncram64 generic map (tech, abits, testen, 0, custombits)
         port map (clk, address, datain(127 downto 64), dataout(127 downto 64), 
	           enable(3 downto 2), write(3 downto 2), testin
                   );
    x1 : syncram64 generic map (tech, abits, testen, 0, custombits)
         port map (clk, address, datain(63 downto 0), dataout(63 downto 0), 
	           enable(1 downto 0), write(1 downto 0), testin
                   );
  end generate;
end generate;

par : if paren = 1 generate
    dinp <= datain(127+16*paren downto 120+16*paren) &  datain(127 downto 64) &
            datain(127+8*paren downto 120+8*paren) &  datain(63 downto 0);
    dataout <= doutp(143 downto 136) & doutp(71 downto 64) &
	       doutp(135 downto 72) & doutp(63-16+16*paren downto 0);
    x0 : syncram64 generic map (tech, abits, testen, 1, custombits)
         port map (clk, address, dinp(143 downto 72), doutp(143 downto 72), 
	           enable(3 downto 2), write(3 downto 2), testin
                   );
    x1 : syncram64 generic map (tech, abits, testen, 1, custombits)
         port map (clk, address, dinp(71 downto 0), doutp(71 downto 0), 
	           enable(1 downto 0), write(1 downto 0), testin
                   );
end generate;


end;

