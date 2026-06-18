------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2023, Cobham Gaisler
--  Copyright (C) 2023,        Frontgrade Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; version 2.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- library techmap;
use work.gencomp.all;
-- pragma translate_off
library altera_mf;
use altera_mf.altpll;
-- pragma translate_on

entity stratix10_pll is
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    clk_freq : integer := 25000;
    clk2xen  : integer := 0;          
    sdramen  : integer := 0
  );
  port (
    inclk0  : in  std_ulogic;
    c0	    : out std_ulogic;
    c0_2x   : out std_ulogic;
    e0	    : out std_ulogic; 
    locked  : out std_ulogic
);
end;

architecture rtl of stratix10_pll is

 

  signal clkena	: std_logic_vector (5 downto 0);
  signal clkout	: std_logic_vector (9 downto 0);
  signal inclk	: std_logic_vector (1 downto 0);
  signal fb     : std_logic;

  constant clk_period : integer := 1000000000/clk_freq;
  constant CLK_MUL2X : integer := clk_mul * 2;
begin

  clkena(5 downto 3) <= (others => '0');
  clkena(0) <= '1';
  clkena(1) <= '1' when sdramen = 1 else '0';
  clkena(2) <= '1' when clk2xen = 1 else '0';

  inclk <= '0' & inclk0;
  c0 <= clkout(0); c0_2x <= clkout(2); e0 <= clkout(1);   

  clkout <= (others => inclk0); 

  locked <= '1';

end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library altera_mf;
-- library grlib;
use work.stdlib.all;
-- pragma translate_on
-- library techmap;
use work.gencomp.all;

entity clkgen_stratix10 is
 generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    sdinvclk : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;
    clk2xen  : integer := 0;      
    tech     : integer := 0);      
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- double clock    
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end; 

architecture rtl of clkgen_stratix10 is

  constant VERSION : integer := 1;
  constant CLKIN_PERIOD : integer := 20;

  signal   clk_i             : std_logic;
  signal   clkint, pciclkint : std_logic;
  signal   pllclk, pllclkn   : std_logic;  -- generated clocks
  signal   s_clk             : std_logic;
  
  component stratix10_pll
    generic (
      clk_mul  : integer := 1; 
      clk_div  : integer := 1;
      clk_freq : integer := 25000;
      clk2xen  : integer := 0;            
      sdramen  : integer := 0
    );
    port (
      inclk0 : in  std_ulogic;
      c0     : out std_ulogic;
      c0_2x  : out std_ulogic;
      e0     : out std_ulogic;
      locked : out std_ulogic);
  end component;
  
  
begin

  cgo.pcilock <= '1';


  c0: if (PCISYSCLK = 0) or (PCIEN = 0) generate
    clkint <= clkin;
  end generate c0;

  c1: if PCIEN /= 0 generate
    d0: if PCISYSCLK = 1 generate
      clkint <= pciclkin;
    end generate d0;
    pciclk <= pciclkin;
  end generate c1;

  c2: if PCIEN = 0 generate
    pciclk <= '0';
  end generate c2;
  

  sdclk_pll : stratix10_pll 
  generic map (clk_mul, clk_div, freq, clk2xen, sdramen)
  port map ( inclk0 => clkint, e0 => sdclk, c0 => s_clk, c0_2x => clk2x,
	locked => cgo.clklock);
  clk <= s_clk;
  clkn <= not s_clk;
 
-- pragma translate_off
  bootmsg : report_version 
  generic map (
    "clkgen_stratix10" & ": sdram/pci clock generator, version " & tost(VERSION),
    "clkgen_stratix10" & ": Frequency " &  tost(freq) & " KHz, PLL scaler " & tost(clk_mul) & "/" & tost(clk_div));
-- pragma translate_on


end;


