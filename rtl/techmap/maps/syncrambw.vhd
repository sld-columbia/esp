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
-- Entity: 	syncrambw
-- File:	syncrambw.vhd
-- Author:	Jan Andersson - Aeroflex Gaisler
-- Description:	Synchronous 1-port ram with 8-bit write strobes
--		and tech selection
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allmem.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity syncrambw is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
    testen : integer := 0; custombits: integer := 1; large_banks : integer := 0);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits-1 downto 0);
    datain  : in  std_logic_vector (dbits-1 downto 0);
    dataout : out std_logic_vector (dbits-1 downto 0);
    enable  : in  std_logic_vector (dbits/8-1 downto 0);
    write   : in  std_logic_vector (dbits/8-1 downto 0);
    testin  : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none
    );
end;

architecture rtl of syncrambw is

  constant nctrl : integer := abits + (TESTIN_WIDTH-2) + 2*dbits/8;
  signal dataoutx, databp, testdata : std_logic_vector((dbits -1) downto 0);
  constant SCANTESTBP : boolean := (testen = 1) and syncram_add_scan_bypass(tech)=1;

  signal xenable, xwrite : std_logic_vector(dbits/8-1 downto 0);
  signal custominx,customoutx: std_logic_vector(syncram_customif_maxwidth downto 0);

begin

  xenable <= enable when testen=0 or testin(TESTIN_WIDTH-2)='0' else (others => '0');
  xwrite <= write when testen=0 or testin(TESTIN_WIDTH-2)='0' else (others => '0');

  sbw : if has_srambw(tech) = 1 generate
    -- RAM bypass for scan
    scanbp : if SCANTESTBP generate
      comb : process (address, datain, enable, write, testin)
        variable tmp : std_logic_vector((dbits -1) downto 0);
        variable ctrlsigs : std_logic_vector((nctrl -1) downto 0);
      begin
        ctrlsigs := testin(TESTIN_WIDTH-3 downto 0) & write & enable & address;
        tmp := datain;
        for i in 0 to nctrl-1 loop
          tmp(i mod dbits) := tmp(i mod dbits) xor ctrlsigs(i);
        end loop;
        testdata <= tmp;
      end process;

      reg : process (clk)
      begin
        if rising_edge(clk) then
          databp <= testdata;
        end if;
      end process;
      dmuxout : for i in 0 to dbits-1 generate
        x0: grmux2 generic map (tech)
          port map (dataoutx(i), databp(i), testin(TESTIN_WIDTH-1), dataout(i));
      end generate;
    end generate;

    noscanbp : if not SCANTESTBP generate dataout <= dataoutx; end generate;


    uni : if is_unisim(tech) = 1 generate
      x0 : unisim_syncram_be generic map (abits, dbits, tech)
        port map (clk, address, datain, dataoutx, xenable, xwrite);
    end generate;

    g12 : if tech = gf12 and large_banks /= 0 generate
      x0 : gf12_syncram_be generic map (abits, dbits)
        port map (clk, address, datain, dataoutx, xenable, xwrite);
    end generate;


-- pragma translate_off
    dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
      x : process
      begin
        assert false report "syncrambw: " & tost(2**abits) & "x" & tost(dbits) &
          " (" & tech_table(tech) & ")"
          severity note;
        wait;
      end process;
    end generate;
-- pragma translate_on
  end generate;

  nosbw : if has_srambw(tech) = 0 or (tech = gf12 and large_banks = 0) generate
    rx : for i in 0 to dbits/8-1 generate
      x0 : syncram generic map (tech, abits, 8, testen, custombits)
         port map (clk, address, datain(i*8+7 downto i*8),
	    dataoutx(i*8+7 downto i*8), enable(i), write(i), testin
                   );
    end generate;
    dataout <= dataoutx;
  end generate;

    custominx <= (others => '0');

  nocust: if has_srambw(tech)=0 or syncram_has_customif(tech)=0 generate
    customoutx <= (others => '0');
  end generate;

end;
