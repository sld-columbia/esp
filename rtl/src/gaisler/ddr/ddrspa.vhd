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
-- Entity: 	ddrspm
-- File:	ddrspm.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	16-, 32- or 64-bit DDR266 memory controller module.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.ddrpkg.all;
use work.gencomp.all;

entity ddrspa is
  generic (
    fabtech : integer := virtex2;
    memtech : integer := 0;
    rskew   : integer := 0;
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#f00#;
    ioaddr  : integer := 16#000#;
    iomask  : integer := 16#fff#;
    MHz     : integer := 100;
    clkmul  : integer := 2; 
    clkdiv  : integer := 2; 
    col     : integer := 9; 
    Mbyte   : integer := 16; 
    rstdel  : integer := 200; 
    pwron   : integer := 0;
    oepol   : integer := 0;
    ddrbits : integer := 16;
    ahbfreq : integer := 50;
    mobile  : integer := 0;
    confapi : integer := 0;
    conf0   : integer := 0;
    conf1   : integer := 0;
    regoutput : integer := 0;
    nosync    : integer := 0;
    ddr400  : integer := 1;
    scantest: integer := 0;
    phyiconf : integer := 0
  );
  port (
    rst_ddr : in  std_ulogic;
    rst_ahb : in  std_ulogic;
    clk_ddr : in  std_ulogic;
    clk_ahb : in  std_ulogic;
    lock    : out std_ulogic;			-- DCM locked
    clkddro : out std_ulogic;			-- DCM locked
    clkddri : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (ddrbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (ddrbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (ddrbits-1 downto 0) -- ddr data

  );
end; 

architecture rtl of ddrspa is

constant DDR_FREQ : integer := (clkmul * MHz) / clkdiv;
signal sdi     : ddrctrl_in_type;
signal sdo     : ddrctrl_out_type;
signal clkread  : std_ulogic;

signal ilock: std_ulogic;
signal ddr_rst: std_logic;
signal ddr_rst_gen: std_logic_vector(3 downto 0);

constant ddr_syncrst: integer := 0;

begin

  lock <= ilock;

  ddr_rst <= (ddr_rst_gen(3) and ddr_rst_gen(2) and ddr_rst_gen(1) and rst_ahb); -- Reset signal in DDR clock domain

  ddrrstproc: process(clkddri, ilock)
  begin
    if rising_edge(clkddri) then
      ddr_rst_gen <= ddr_rst_gen(2 downto 0) & '1';
      if ddr_syncrst /= 0 and rst_ahb='0' then
        ddr_rst_gen <= "0000";
      end if;
    end if;
    if ddr_syncrst=0 and ilock='0' then
      ddr_rst_gen <= "0000";
    end if;
  end process;       
  
  ddr_phy0 : ddrphy_wrap_cbd generic map (tech => fabtech, MHz => MHz,  
	dbits => ddrbits, rstdelay => 0, clk_mul => clkmul, 
	clk_div => clkdiv, rskew => rskew, mobile => mobile,
	scantest => scantest, phyiconf => phyiconf)
  port map (
	rst_ddr, clk_ddr, clkddro, clkddri, clkread, ilock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq, sdi, sdo,
        ahbsi.testen, ahbsi.testrst, ahbsi.scanen, ahbsi.testoen);

  ddrc : ddr1spax generic map (ddrbits => ddrbits, memtech => memtech, phytech => fabtech,
        hindex => hindex, haddr => haddr, hmask => hmask, ioaddr => ioaddr, iomask => iomask,
	pwron => pwron, MHz => DDR_FREQ, col => col, Mbyte => Mbyte,
        mobile => mobile, confapi => confapi, conf0 => conf0, 
        conf1 => conf1, regoutput => regoutput, nosync => nosync, ddr400 => ddr400, ahbbits => 32,
        rstdel => rstdel, scantest => scantest)
    port map (ddr_rst, rst_ahb, clkddri, clk_ahb, ahbsi, ahbso, sdi, sdo);
    
end;

