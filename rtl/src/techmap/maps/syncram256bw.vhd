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
-- Entity: 	syncram256bw
-- File:	syncram256bw.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	256-bit syncronous 1-port ram with 8-bit write strobes
--		and tech selection
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity syncram256bw is
  generic (tech : integer := 0; abits : integer := 6; testen : integer := 0; custombits: integer := 1);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (255 downto 0);
    dataout : out std_logic_vector (255 downto 0);
    enable  : in  std_logic_vector (31 downto 0);
    write   : in  std_logic_vector (31 downto 0);
    testin  : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none
    );
end;

architecture rtl of syncram256bw is

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
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (15 downto 0);
    write   : in  std_logic_vector (15 downto 0)
  );
  end component;

  component altera_syncram256bw
  generic ( abits : integer := 9);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (255 downto 0);
    dataout : out std_logic_vector (255 downto 0);
    enable  : in  std_logic_vector (31 downto 0);
    write   : in  std_logic_vector (31 downto 0)
  );
  end component;

  component tm65gplus_syncram256bw
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (255 downto 0);
    dataout : out std_logic_vector (255 downto 0);
    enable  : in  std_logic_vector (31 downto 0);
    write   : in  std_logic_vector (31 downto 0);
    testin  : in  std_logic_vector (3 downto 0) := "0000"
  );
  end component;

  component cmos9sf_syncram256bw
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (255 downto 0);
    dataout : out std_logic_vector (255 downto 0);
    enable  : in  std_logic_vector (31 downto 0);
    write   : in  std_logic_vector (31 downto 0);
    testin  : in  std_logic_vector (3 downto 0) := "0000"
  );
  end component;

  signal xenable, xwrite : std_logic_vector(31 downto 0);
  signal custominx,customoutx: std_logic_vector(syncram_customif_maxwidth downto 0);
  
begin

  xenable <= enable when testen=0 or testin(TESTIN_WIDTH-2)='0' else (others => '0');
  xwrite <= write when testen=0 or testin(TESTIN_WIDTH-2)='0' else (others => '0');

    custominx <= (others => '0');

  nocust: if has_sram256bw(tech)=0 or syncram_has_customif(tech)=0 generate
    customoutx <= (others => '0');
  end generate;

  s256 : if has_sram256bw(tech) = 1 generate
    uni : if (is_unisim(tech) = 1) generate 
      x0 : unisim_syncram128bw generic map (abits)
         port map (clk, address, datain(127 downto 0), dataout(127 downto 0),
		xenable(15 downto 0), xwrite(15 downto 0));
      x1 : unisim_syncram128bw generic map (abits)
         port map (clk, address, datain(255 downto 128), dataout(255 downto 128),
		xenable(31 downto 16), xwrite(31 downto 16));
    end generate;
    alt : if (tech = stratix2) or (tech = stratix3) or (tech = stratix4) or 
	(tech = cyclone3) or (tech = altera) generate
      x0 : altera_syncram256bw generic map (abits)
         port map (clk, address, datain, dataout, xenable, xwrite);
    end generate;

    tm65: if tech = tm65gplus generate
      x0 : tm65gplus_syncram256bw generic map (abits)
         port map (clk, address, datain, dataout, xenable, xwrite, testin);
    end generate;

    cm9s: if tech = cmos9sf generate
      x0 : cmos9sf_syncram256bw generic map (abits)
         port map (clk, address, datain, dataout, xenable, xwrite, testin);
    end generate;


-- pragma translate_off
    dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
      x : process
      begin
        assert false report "syncram256bw: " & tost(2**abits) & "x256" &
         " (" & tech_table(tech) & ")"
        severity note;
        wait;
      end process;
    end generate;
-- pragma translate_on

  end generate;

  nos256 : if has_sram256bw(tech) = 0 generate
    rx : for i in 0 to 31 generate
      x0 : syncram generic map (tech, abits, 8, testen, custombits)
         port map (clk, address, datain(i*8+7 downto i*8), 
	    dataout(i*8+7 downto i*8), enable(i), write(i), testin
                   );
    end generate;
  end generate;

end;

