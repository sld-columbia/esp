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
-- Entity:      regfile_3p_l3
-- File:        regfile_3p_l3.vhd
-- Author:      Jiri Gaisler, Edvin Catovic - Gaisler Research
-- Description: 3-port regfile implemented with two 2-port rams
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.stdlib.all;

entity regfile_3p_l3 is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
           wrfst : integer := 0; numregs : integer := 64;
           testen : integer := 0);
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
    testin : in  std_logic_vector(TESTIN_WIDTH-1 downto 0)
    );


end;

architecture rtl of regfile_3p_l3 is
  
constant rfinfer : boolean := (regfile_3p_infer(tech) = 1);
signal wd1, wd2  : std_logic_vector((dbits -1 + 8) downto 0);
signal e1, e2 : std_logic_vector((dbits-1) downto 0);
signal we1, we2 : std_ulogic;

signal vcc, gnd : std_ulogic;
signal vgnd : std_logic_vector(dbits-1 downto 0);
signal write2, renable2 : std_ulogic;


begin

  vcc <= '1'; gnd <= '0'; vgnd <= (others => '0');
  we1 <= we 
        ;
  we2 <= we
        ;
  
  s0 : if rfinfer generate
      inf : regfile_3p generic map (0, abits, dbits, wrfst, numregs, testen, memtest_vlen)
      port map ( wclk, waddr, wdata, we, rclk, raddr1, re1, rdata1, raddr2, re2, rdata2,
                 open, open, testin
                 );
  end generate;

  s1 : if not rfinfer generate
      rhu : regfile_3p generic map (tech, abits, dbits, wrfst, numregs, testen, memtest_vlen)
      port map ( wclk, waddr, wdata, we, rclk, raddr1, re1, rdata1, raddr2, re2, rdata2,
                 open, open, testin
                 );
  end generate;



end;

