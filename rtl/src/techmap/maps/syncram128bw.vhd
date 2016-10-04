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
-- Entity: 	syncram128bw
-- File:	syncram128bw.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	128-bit syncronous 1-port ram with 8-bit write strobes
--		and tech selection
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity syncram128bw is
  generic (tech : integer := 0; abits : integer := 6; testen : integer := 0; custombits: integer := 1);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (15 downto 0);
    write   : in  std_logic_vector (15 downto 0);
    testin  : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none
    );
end;

architecture rtl of syncram128bw is

  component unisim_syncram128bw
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (15 downto 0);
    write   : in  std_logic_vector (15 downto 0)
  );
  end component;

  component altera_syncram128bw
  generic ( abits : integer := 9);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (15 downto 0);
    write   : in  std_logic_vector (15 downto 0)
  );
  end component;

  component tm65gplus_syncram128bw
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (15 downto 0);
    write   : in  std_logic_vector (15 downto 0);
    testin  : in  std_logic_vector (3 downto 0) := "0000"
  );
  end component;

  component ut90nhbd_syncram128bw
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (15 downto 0);
    write   : in  std_logic_vector (15 downto 0);
    tdbn    : in  std_ulogic
  );
  end component;

  signal xenable, xwrite : std_logic_vector(15 downto 0);
  signal custominx,customoutx: std_logic_vector(syncram_customif_maxwidth downto 0);

begin

  xenable <= enable when testen=0 or testin(TESTIN_WIDTH-2)='0' else (others => '0');
  xwrite <= write when testen=0 or testin(TESTIN_WIDTH-2)='0' else (others => '0');

    custominx <= (others => '0');

  nocust: if syncram_has_customif(tech)=0 or has_sram128bw(tech)=0 generate
    customoutx <= (others => '0');
  end generate;
  
  s64 : if has_sram128bw(tech) = 1 generate
    xc2v : if (is_unisim(tech) = 1) generate 
      x0 : unisim_syncram128bw generic map (abits)
         port map (clk, address, datain, dataout, xenable, xwrite);
    end generate;
    alt : if (tech = stratix2) or (tech = stratix3) or (tech = stratix4) or 
	(tech = cyclone3) or (tech = altera) generate
      x0 : altera_syncram128bw generic map (abits)
         port map (clk, address, datain, dataout, xenable, xwrite);
    end generate;
    tm65: if tech = tm65gplus generate
      x0 : tm65gplus_syncram128bw generic map (abits)
         port map (clk, address, datain, dataout, xenable, xwrite, testin);
    end generate;
    ut09: if tech = ut90 generate
      x0 : ut90nhbd_syncram128bw generic map (abits)
         port map (clk, address, datain, dataout, xenable, xwrite, testin(TESTIN_WIDTH-3));
    end generate;


-- pragma translate_off
    dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
      x : process
      begin
        assert false report "syncram128bw: " & tost(2**abits) & "x128" &
         " (" & tech_table(tech) & ")"
        severity note;
        wait;
      end process;
    end generate;
-- pragma translate_on
  end generate;

  nos64 : if has_sram128bw(tech) = 0 generate
    rx : for i in 0 to 15 generate
      x0 : syncram generic map (tech, abits, 8, testen, custombits)
         port map (clk, address, datain(i*8+7 downto i*8), 
	    dataout(i*8+7 downto i*8), enable(i), write(i), testin
                   );
    end generate;
  end generate;

end;

