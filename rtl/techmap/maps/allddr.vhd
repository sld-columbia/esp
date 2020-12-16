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
-- Package:     allddr
-- File:        allddr.vhd
-- Author:      David Lindh, Jiri Gaisler - Gaisler Research
-- Description: DDR input/output registers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

package allddr is

component unisim_iddr_reg is
  generic ( tech : integer; arch : integer := 0);
  port(
         Q1 : out std_ulogic;
         Q2 : out std_ulogic;
         C1 : in std_ulogic;
         C2 : in std_ulogic;
         CE : in std_ulogic;
         D : in std_ulogic;
         R : in std_ulogic;
         S : in std_ulogic
      );
end component;

component gen_iddr_reg
  generic (scantest: integer; noasync: integer);
  port (
    Q1 : out std_ulogic;
    Q2 : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic;
    testen: in std_ulogic;
    testrst: in std_ulogic);
end component;

component unisim_oddr_reg
  generic (tech : integer; arch : integer := 0);
  port (
      Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end component;

component gen_oddr_reg
  generic (scantest: integer; noasync: integer);
  port (
      Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic;
      testen: in std_ulogic;
      testrst: in std_ulogic);
end component;

component generic_ddr_phy_wo_pads
  generic (MHz : integer := 100; rstdelay : integer := 200;
           dbits : integer := 16; clk_mul : integer := 2 ;
           clk_div : integer := 2; rskew : integer := 0; mobile : integer := 0;
           abits: integer := 14; nclk: integer := 3; ncs: integer := 2);

  port (
    rst         : in  std_ulogic;
    clk         : in  std_logic;    -- input clock
    clkout      : out std_ulogic;   -- system clock
    clk0r       : in  std_ulogic;
    lock        : out std_ulogic;   -- DCM locked

    ddr_clk     : out std_logic_vector(nclk-1 downto 0);
    ddr_clkb    : out std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke     : out std_logic_vector(ncs-1 downto 0);
    ddr_csb     : out std_logic_vector(ncs-1 downto 0);
    ddr_web     : out std_ulogic;                             -- ddr write enable
    ddr_rasb    : out std_ulogic;                             -- ddr ras
    ddr_casb    : out std_ulogic;                             -- ddr cas
    ddr_dm      : out std_logic_vector (dbits/8-1 downto 0);  -- ddr dm
    ddr_dqs_in  : in std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs    
    ddr_ad      : out std_logic_vector (abits-1 downto 0);         -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);          -- ddr bank address
    ddr_dq_in   : in  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dq_out  : out  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dq_oen  : out  std_logic_vector (dbits-1 downto 0); -- ddr data

    addr        : in  std_logic_vector (abits-1 downto 0);         -- data mask
    ba          : in  std_logic_vector ( 1 downto 0);         -- data mask
    dqin        : out std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dqout       : in  std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dm          : in  std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen         : in  std_ulogic;
    dqs         : in  std_ulogic;
    dqsoen      : in  std_ulogic;
    rasn        : in  std_ulogic;
    casn        : in  std_ulogic;
    wen         : in  std_ulogic;
    csn         : in  std_logic_vector(ncs-1 downto 0);
    cke         : in  std_logic_vector(ncs-1 downto 0);
    ck          : in  std_logic_vector(nclk-1 downto 0);
    moben       : in  std_logic
  );

end component;


component generic_ddr2_phy_wo_pads is
  generic (MHz : integer := 100; rstdelay : integer := 200;
    dbits : integer := 16; clk_mul : integer := 2 ;
    clk_div : integer := 2; rskew : integer := 0;
           eightbanks: integer := 0; abits: integer := 14;
           nclk: integer := 3; ncs: integer := 2);
  port(
    rst         : in  std_ulogic;
    clk         : in  std_logic;  -- input clock
    clkout      : out std_ulogic; -- system clock
    clk0r       : in  std_ulogic; -- system clock returned
    --clkread   : out std_ulogic;
    lock        : out std_ulogic; -- DCM locked

    ddr_clk     : out std_logic_vector(2 downto 0);
    ddr_clkb    : out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke     : out std_logic_vector(1 downto 0);
    ddr_csb     : out std_logic_vector(1 downto 0);
    ddr_web     : out std_ulogic;                       -- ddr write enable
    ddr_rasb    : out std_ulogic;                       -- ddr ras
    ddr_casb    : out std_ulogic;                       -- ddr cas
    ddr_dm      : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in  : in std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (abits-1 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1+eightbanks downto 0);    -- ddr bank address
    ddr_dq_in   : in  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dq_out  : out  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dq_oen  : out  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_odt     : out std_logic_vector(1 downto 0);  -- ddr odt

    addr        : in  std_logic_vector (abits-1 downto 0); -- data mask
    ba          : in  std_logic_vector (2 downto 0); -- data mask
    dqin        : out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout       : in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm          : in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen         : in  std_ulogic;
    dqs         : in  std_ulogic;
    dqsoen      : in  std_ulogic;
    rasn        : in  std_ulogic;
    casn        : in  std_ulogic;
    wen         : in  std_ulogic;
    csn         : in  std_logic_vector(1 downto 0);
    cke         : in  std_logic_vector(1 downto 0);
    ck          : in  std_logic_vector(2 downto 0);
    odt         : in  std_logic_vector(1 downto 0)
    );
end component;


component generic_lpddr2phy_wo_pads is
  generic (
    tech : integer := 0;
    dbits : integer := 16;
    nclk: integer := 3;
    ncs: integer := 2;
    clkratio: integer := 1;
    scantest: integer := 0);
  port (
    rst            : in    std_ulogic;
    clkin          : in    std_ulogic;
    clkin2         : in    std_ulogic;
    clkout         : out   std_ulogic;
    clkoutret      : in    std_ulogic;    -- clkout returned
    clkout2        : out   std_ulogic;
    lock           : out   std_ulogic;

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_ca         : out   std_logic_vector(9 downto 0);
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in     : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dq_in      : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_out     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_oen     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data

    ca             : in    std_logic_vector (10*2*clkratio-1 downto 0);
    cke            : in    std_logic_vector (ncs*clkratio-1 downto 0);
    csn            : in    std_logic_vector (ncs*clkratio-1 downto 0);
    dqin           : out   std_logic_vector (dbits*2*clkratio-1 downto 0);  -- ddr output data
    dqout          : in    std_logic_vector (dbits*2*clkratio-1 downto 0);  -- ddr input data
    dm             : in    std_logic_vector (dbits/4*clkratio-1 downto 0);  -- data mask
    ckstop         : in    std_ulogic;
    boot           : in    std_ulogic;
    wrpend         : in    std_logic_vector(7 downto 0);
    rdpend         : in    std_logic_vector(7 downto 0);
    wrreq          : out   std_logic_vector(clkratio-1 downto 0);
    rdvalid        : out   std_logic_vector(clkratio-1 downto 0);

    refcal         : in    std_ulogic;
    refcalwu       : in    std_ulogic;
    refcaldone     : out   std_ulogic;

    phycmd         : in    std_logic_vector(7 downto 0);
    phycmden       : in    std_ulogic;
    phycmdin       : in    std_logic_vector(31 downto 0);
    phycmdout      : out   std_logic_vector(31 downto 0);

    testen      : in  std_ulogic;
    testrst     : in  std_ulogic;
    scanen      : in  std_ulogic;
    testoen     : in  std_ulogic);
end component;

end;

