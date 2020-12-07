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
-- Entity: 	regfile_3p
-- File:	regfile_3p.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	3-port regfile implemented with two 2-port rams
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allmem.all;

entity regfile_3p is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
           wrfst : integer := 0; numregs : integer := 64; testen : integer := 0;
           custombits : integer := 1);
  port (
    wclk   : in  std_ulogic;
    waddr  : in  std_logic_vector((abits -1) downto 0);
    wdata  : in  std_logic_vector((dbits -1) downto 0);
    we     : in  std_ulogic;
    rclk   : in  std_ulogic;
    raddr1 : in  std_logic_vector((abits -1) downto 0);
    re1    : in  std_ulogic;
    rdata1 : out std_logic_vector((dbits -1) downto 0);
    raddr2 : in  std_logic_vector((abits -1) downto 0);
    re2    : in  std_ulogic;
    rdata2 : out std_logic_vector((dbits -1) downto 0);
    ce1    : out std_ulogic;
    ce2    : out std_ulogic;
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
end;

architecture rtl of regfile_3p is
  constant rfinfer : boolean := (regfile_3p_infer(tech) = 1) or
	(((is_unisim(tech) = 1)) and (abits <= 5));
  signal xwe,xre1,xre2 : std_ulogic;


  signal custominx,customoutx: std_logic_vector(syncram_customif_maxwidth downto 0);
  
begin
  xwe <= we and not testin(TESTIN_WIDTH-2) when testen/=0 else we;
  xre1 <= re1 and not testin(TESTIN_WIDTH-2) when testen/=0 else re1;
  xre2 <= re2 and not testin(TESTIN_WIDTH-2) when testen/=0 else re2;
  
  s0 : if rfinfer generate
      rhu : generic_regfile_3p generic map (tech, abits, dbits, wrfst, numregs)
        port map ( wclk, waddr, wdata, we, rclk, raddr1, re1, rdata1, raddr2, re2, rdata2);
      ce1 <= '0';
      ce2 <= '0';
    
  end generate;

  s1 : if not rfinfer generate
    x0 : syncram_2p generic map (tech, abits, dbits, 0, wrfst, testen, 0, custombits)
      port map (rclk, re1, raddr1, rdata1, wclk, we, waddr, wdata, testin
                );
    x1 : syncram_2p generic map (tech, abits, dbits, 0, wrfst, testen, 0, custombits)
      port map (rclk, re2, raddr2, rdata2, wclk, we, waddr, wdata, testin
                );
  end generate;

  custominx <= (others => '0');
  nocust: if syncram_has_customif(tech)=0 or rfinfer generate
    customoutx <= (others => '0');
  end generate;
end;

