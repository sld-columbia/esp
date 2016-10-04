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

component rhumc_iddr_reg is
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

component unisim_iddr_reg is
  generic ( tech : integer := virtex4; arch : integer := 0);
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

component rhumc_oddr_reg
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

component ec_oddr_reg
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

component unisim_oddr_reg
  generic (tech : integer := virtex4; arch : integer := 0);
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

component axcel_oddr_reg is
  port(
    Q : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D1 : in std_ulogic;
    D2 : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic);
end component;

component axcel_iddr_reg is
  port(
    Q1 : out std_ulogic;
    Q2 : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic);
end component;

component nextreme_oddr_reg
  port(
    CK   : in  std_ulogic;
    DH   : in  std_ulogic;
    DL   : in  std_ulogic;
    DOE  : in  std_ulogic;
    Q    : out std_ulogic;
    OE   : out std_ulogic;
    RSTB : in  std_ulogic);
end component;

component nextreme_iddr_reg
  port(
    CK   : in  std_ulogic;
    D    : in  std_ulogic;
    QH   : out std_ulogic;
    QL   : out std_ulogic;
    RSTB : in  std_ulogic);
end component;

component apa3_oddr_reg is
  port(
    Q : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D1 : in std_ulogic;
    D2 : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic);                        
end component;

component apa3_iddr_reg is
  port(
    Q1 : out std_ulogic;
    Q2 : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic);
end component;

component apa3e_oddr_reg is
  port(
    Q : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D1 : in std_ulogic;
    D2 : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic);                        
end component;

component apa3e_iddr_reg is
  port(
    Q1 : out std_ulogic;
    Q2 : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic);
end component;

component apa3l_oddr_reg is
  port(
    Q : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D1 : in std_ulogic;
    D2 : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic);                        
end component;

component apa3l_iddr_reg is
  port(
    Q1 : out std_ulogic;
    Q2 : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic);
end component;

component igloo2_oddr_reg is
  port(
    Q : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D1 : in std_ulogic;
    D2 : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic);
end component;

component igloo2_iddr_reg is
  port(
    Q1 : out std_ulogic;
    Q2 : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic);
end component;

component spartan3e_ddr_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2; rskew : integer := 0);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- DDR state clock
    clkread   : out std_ulogic;			-- DDR read clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0)
  );

end component;

component virtex4_ddr_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2; rskew : integer := 0; phyiconf : integer := 0);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0);
    ck        	: in  std_logic_vector(2 downto 0)
  );

end component;

component virtex2_ddr_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2; rskew : integer := 0);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0)
  );

end component;

component stratixii_ddr_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0)
  );

end component;

component cycloneiii_ddr_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2; rskew : integer := 0);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0)
  );

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

component tsmc90_tci_ddr_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
           dbits : integer := 16);

  port (
    rst           : in  std_ulogic;
    clk           : in  std_logic;    -- input clock
    clk90_sigi_0  : in  std_logic;
    rclk_sigi_1   : in  std_logic;
    clkout        : out std_ulogic;   -- system clock
    lock          : out std_ulogic;   -- DCM locked

    ddr_clk     : out std_logic_vector(2 downto 0);
    ddr_clkb    : out std_logic_vector(2 downto 0);
    --ddr_clk_fb_out : out std_logic;
    --ddr_clk_fb  : in std_logic;
    ddr_cke     : out std_logic_vector(1 downto 0);
    ddr_csb     : out std_logic_vector(1 downto 0);
    ddr_web     : out std_ulogic;                             -- ddr write enable
    ddr_rasb    : out std_ulogic;                             -- ddr ras
    ddr_casb    : out std_ulogic;                             -- ddr cas
    ddr_dm      : out std_logic_vector (dbits/8-1 downto 0);  -- ddr dm
    ddr_dqsin   : in std_logic_vector (dbits/8-1 downto 0);-- ddr dqs
    ddr_dqsout  : out std_logic_vector (dbits/8-1 downto 0);-- ddr dqs
    ddr_dqsoen  : out std_logic_vector (dbits/8-1 downto 0);-- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);         -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);          -- ddr bank address
    ddr_dqin    : in  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dqout   : out  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dqoen   : out  std_logic_vector (dbits-1 downto 0); -- ddr data

    addr        : in  std_logic_vector (13 downto 0);         -- ddr address
    ba          : in  std_logic_vector ( 1 downto 0);         -- ddr bank address
    dqin        : out std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dqout       : in  std_logic_vector (dbits*2-1 downto 0);  -- ddr output data
    dm          : in  std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen         : in  std_ulogic;
    dqs         : in  std_ulogic;
    dqsoen      : in  std_ulogic;
    rasn        : in  std_ulogic;
    casn        : in  std_ulogic;
    wen         : in  std_ulogic;
    csn         : in  std_logic_vector(1 downto 0);
    cke         : in  std_logic_vector(1 downto 0);
    ck          : in  std_logic_vector(2 downto 0);
    moben       : in  std_logic;
    conf        : in  std_logic_vector(63 downto 0);
    tstclkout   : out std_logic_vector(3 downto 0)
  );

end component;

component virtex5_ddr2_phy_wo_pads
  generic (
    MHz         : integer := 100;       rstdelay   : integer := 200;
    dbits       : integer := 16;        clk_mul    : integer := 2 ;     clk_div  : integer := 2; 
    ddelayb0    : integer := 0;         ddelayb1   : integer := 0;      ddelayb2 : integer := 0;
    ddelayb3    : integer := 0;         ddelayb4   : integer := 0;      ddelayb5 : integer := 0;
    ddelayb6    : integer := 0;         ddelayb7   : integer := 0;      ddelayb8: integer := 0;
    ddelayb9   : integer := 0;          ddelayb10  : integer := 0;      ddelayb11: integer := 0;    
    numidelctrl : integer := 4;         norefclk   : integer := 0; 
    tech        : integer := virtex5;   eightbanks : integer range 0 to 1 := 0;
    dqsse       : integer range 0 to 1 := 0;
    abits       : integer := 14;        nclk       : integer := 3;      ncs      : integer := 2);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkref200 : in  std_logic;			-- input 200MHz clock
    clkout    : out std_ulogic;			-- system clock
    clkoutret : in  std_ulogic;                 -- system clock return
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(nclk-1 downto 0);
    ddr_clkb	: out std_logic_vector(nclk-1 downto 0);
    ddr_cke  	: out std_logic_vector(ncs-1 downto 0);
    ddr_csb  	: out std_logic_vector(ncs-1 downto 0);
    ddr_web  	: out std_ulogic;                               -- ddr write enable
    ddr_rasb  	: out std_ulogic;                               -- ddr ras
    ddr_casb  	: out std_ulogic;                               -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in  : in    std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
    ddr_dqs_out : out   std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
    ddr_dqs_oen : out   std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
    ddr_ad      : out std_logic_vector (abits-1 downto 0);      -- ddr address
    ddr_ba      : out std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq_in   : in    std_logic_vector (dbits-1 downto 0);    -- ddr data
    ddr_dq_out  : out   std_logic_vector (dbits-1 downto 0);    -- ddr data
    ddr_dq_oen  : out   std_logic_vector (dbits-1 downto 0);    -- ddr data
    ddr_odt	: out std_logic_vector(ncs-1 downto 0);

    addr  	: in  std_logic_vector (abits-1 downto 0);   -- ddr addr
    ba    	: in  std_logic_vector ( 2 downto 0);        -- ddr bank address
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(ncs-1 downto 0);
    cke       	: in  std_logic_vector(ncs-1 downto 0);
    cal_en	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_inc	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_rst	: in  std_logic;
    odt     : in  std_logic_vector(ncs-1 downto 0)
 );
end component;

component stratixii_ddr2_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2; eightbanks : integer range 0 to 1 := 0);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- PLL locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1+eightbanks downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_odt	: out std_logic_vector(1 downto 0);

    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 2 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0);
    cal_en	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_inc	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_rst	: in  std_logic;
    odt     : in  std_logic_vector(1 downto 0)
 );
end component;

component stratixiii_ddr2_phy
  generic (
    MHz         : integer := 100;       rstdelay : integer := 200;
    dbits       : integer := 16;        clk_mul  : integer := 2 ;       clk_div  : integer := 2; 
    ddelayb0    : integer := 0;         ddelayb1 : integer := 0;        ddelayb2 : integer := 0;
    ddelayb3    : integer := 0;         ddelayb4 : integer := 0;        ddelayb5 : integer := 0;
    ddelayb6    : integer := 0;         ddelayb7 : integer := 0;
    numidelctrl : integer := 4;         norefclk : integer := 0; 
    tech        : integer := stratix3;  rskew    : integer := 0;
    eightbanks  : integer range 0 to 1 := 0);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkref200 : in  std_logic;			-- input 200MHz clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                               -- ddr write enable
    ddr_rasb  	: out std_ulogic;                               -- ddr ras
    ddr_casb  	: out std_ulogic;                               -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
    ddr_dqsn  	: inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqsn
    ddr_ad      : out std_logic_vector (13 downto 0);           -- ddr address
    ddr_ba      : out std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0);   -- ddr data
    ddr_odt	: out std_logic_vector(1 downto 0);

    addr  	: in  std_logic_vector (13 downto 0);        -- ddr addrees
    ba    	: in  std_logic_vector ( 2 downto 0);        -- ddr bank address
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0);
    cal_en	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_inc	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_pll	: in  std_logic_vector(1 downto 0);
    cal_rst	: in  std_logic;
    odt     : in  std_logic_vector(1 downto 0);
    oct     : in  std_logic
 );
end component;

component spartan3a_ddr2_phy
  generic (MHz         : integer := 125; rstdelay   : integer := 200;
           dbits       : integer := 16;  clk_mul    : integer := 2;
           clk_div     : integer := 2;   tech       : integer := spartan3;
           rskew       : integer := 0;   eightbanks : integer range 0 to 1 := 0);

  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkout         : out   std_ulogic;  -- system clock
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(2 downto 0);
    ddr_clkb       : out   std_logic_vector(2 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(1 downto 0);
    ddr_csb        : out   std_logic_vector(1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqsn       : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqsn
    ddr_ad         : out   std_logic_vector (13 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq         : inout std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(1 downto 0);

    addr           : in    std_logic_vector (13 downto 0);
    ba             : in    std_logic_vector ( 2 downto 0);
    dqin           : out   std_logic_vector (dbits*2-1 downto 0);  -- ddr data
    dqout          : in    std_logic_vector (dbits*2-1 downto 0);  -- ddr data
    dm             : in    std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen            : in    std_ulogic;
    dqs            : in    std_ulogic;
    dqsoen         : in    std_ulogic;
    rasn           : in    std_ulogic;
    casn           : in    std_ulogic;
    wen            : in    std_ulogic;
    csn            : in    std_logic_vector(1 downto 0);
    cke            : in    std_logic_vector(1 downto 0);
    cal_pll        : in    std_logic_vector(1 downto 0);
    odt            : in    std_logic_vector(1 downto 0)
    );
end component;

component easic90_ddr2_phy
  generic (
    tech           : integer;
    MHz            : integer;
    clk_mul        : integer;
    clk_div        : integer;
    dbits          : integer;
    rstdelay       : integer := 200;
    eightbanks     : integer range 0 to 1 := 0);
  port (
    rstn           : in    std_logic;
    clk            : in    std_logic;
    clkout         : out   std_ulogic;
    lock           : out   std_ulogic;
    ddr_clk        : out   std_logic_vector(2 downto 0);
    ddr_clkb       : out   std_logic_vector(2 downto 0);
    ddr_clk_fb_out : out   std_ulogic;
    ddr_cke        : out   std_logic_vector(1 downto 0);
    ddr_csb        : out   std_logic_vector(1 downto 0);
    ddr_web        : out   std_ulogic;
    ddr_rasb       : out   std_ulogic;
    ddr_casb       : out   std_ulogic;
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);
    ddr_dqs        : inout std_logic_vector (dbits/8-1 downto 0);
    ddr_dqsn       : inout std_logic_vector (dbits/8-1 downto 0);
    ddr_ad         : out   std_logic_vector (13 downto 0);
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0);
    ddr_dq         : inout std_logic_vector (dbits-1 downto 0);
    ddr_odt        : out   std_logic_vector(1 downto 0);
    addr           : in    std_logic_vector (13 downto 0);
    ba             : in    std_logic_vector ( 2 downto 0);
    dqin           : out   std_logic_vector (dbits*2-1 downto 0);
    dqout          : in    std_logic_vector (dbits*2-1 downto 0);
    dm             : in    std_logic_vector (dbits/4-1 downto 0);
    oen            : in    std_ulogic;
    dqs            : in    std_ulogic;
    dqsoen         : in    std_ulogic;
    rasn           : in    std_ulogic;
    casn           : in    std_ulogic;
    wen            : in    std_ulogic;
    csn            : in    std_logic_vector(1 downto 0);
    cke            : in    std_logic_vector(1 downto 0);
    odt            : in    std_logic_vector(1 downto 0);
    dqs_gate       : in    std_ulogic);
end component;

component spartan6_ddr2_phy_wo_pads
  generic (MHz         : integer := 125; rstdelay   : integer := 200;
           dbits       : integer := 16;  clk_mul    : integer := 2;
           clk_div     : integer := 2;   tech       : integer := spartan6;
           rskew       : integer := 0;   eightbanks : integer range 0 to 1 := 0;
           abits       : integer := 14;
           nclk        : integer := 3;   ncs        : integer := 2 );
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkout         : out   std_ulogic;  -- system clock
    lock           : out   std_ulogic;  -- DCM locked
    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in     : in    std_logic_vector (dbits/8-1 downto 0);
    ddr_dqs_out    : out   std_logic_vector (dbits/8-1 downto 0);
    ddr_dqs_oen    : out   std_logic_vector (dbits/8-1 downto 0);
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);      -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq_in      : in    std_logic_vector (dbits-1 downto 0);
    ddr_dq_out     : out   std_logic_vector (dbits-1 downto 0);
    ddr_dq_oen     : out   std_logic_vector (dbits-1 downto 0);
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);
    addr           : in    std_logic_vector (abits-1 downto 0);
    ba             : in    std_logic_vector ( 2 downto 0);
    dqin           : out   std_logic_vector (dbits*2-1 downto 0);  -- ddr data
    dqout          : in    std_logic_vector (dbits*2-1 downto 0);  -- ddr data
    dm             : in    std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen            : in    std_ulogic;
    dqs            : in    std_ulogic;
    dqsoen         : in    std_ulogic;
    rasn           : in    std_ulogic;
    casn           : in    std_ulogic;
    wen            : in    std_ulogic;
    csn            : in    std_logic_vector(ncs-1 downto 0);
    cke            : in    std_logic_vector(ncs-1 downto 0);
    cal_en         : in    std_logic_vector(dbits/8-1 downto 0);
    cal_inc        : in    std_logic_vector(dbits/8-1 downto 0);
    cal_rst        : in    std_logic;
    odt            : in    std_logic_vector(1 downto 0)
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

component n2x_ddr2_phy is
  generic (
    MHz        : integer := 100;
    rstdelay   : integer := 200;
    dbits      : integer := 16;
    clk_mul    : integer := 2;
    clk_div    : integer := 2;
    norefclk   : integer := 0;
    eightbanks : integer  range 0 to 1 := 0;
    dqsse      : integer range 0 to 1 := 0;
    abits      : integer := 14;
    nclk       : integer := 3;
    ncs        : integer := 2;
    ctrl2en    : integer := 0);
  port (
    rst        : in  std_ulogic;
    clk        : in  std_logic;        -- input clock
    clk270d    : in  std_logic;        -- input clock shifted 270 degrees
                                       -- for operating without PLL
    clkout     : out std_ulogic;       -- system clock
    clkoutret  : in  std_ulogic;       -- system clock return
    lock       : out std_ulogic;       -- DCM locked

    ddr_clk    : out std_logic_vector(nclk-1 downto 0);
    ddr_clkb   : out std_logic_vector(nclk-1 downto 0);
    ddr_cke    : out std_logic_vector(ncs-1 downto 0);
    ddr_csb    : out std_logic_vector(ncs-1 downto 0);
    ddr_web    : out std_ulogic;                               -- ddr write enable
    ddr_rasb   : out std_ulogic;                               -- ddr ras
    ddr_casb   : out std_ulogic;                               -- ddr cas
    ddr_dm     : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs    : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
    ddr_dqsn   : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqsn
    ddr_ad     : out std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba     : out std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq     : inout  std_logic_vector (dbits-1 downto 0);   -- ddr data
    ddr_odt    : out std_logic_vector(ncs-1 downto 0);

    rden_pad   : inout std_logic_vector(dbits/8-1 downto 0);  -- pad delay comp. dummy I/O
    
    addr       : in  std_logic_vector (abits-1 downto 0);           -- ddr address
    ba         : in  std_logic_vector ( 2 downto 0);           -- ddr bank address
    dqin       : out std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
    dqout      : in  std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
    dm         : in  std_logic_vector (dbits/4-1 downto 0);    -- data mask
    noen       : in  std_ulogic;
    rasn       : in  std_ulogic;
    casn       : in  std_ulogic;
    wen        : in  std_ulogic;
    csn        : in  std_logic_vector(ncs-1 downto 0);
    cke        : in  std_logic_vector(ncs-1 downto 0);
    odt        : in  std_logic_vector(ncs-1 downto 0);
    read_pend  : in  std_logic_vector(7 downto 0);    
    regwdata   : in  std_logic_vector(63 downto 0);
    regwrite   : in  std_logic_vector(1 downto 0);
    regrdata   : out std_logic_vector(63 downto 0);
    dqin_valid : out std_logic;

    -- Copy of control signals for 2nd DIMM
    ddr_web2    : out std_ulogic;                               -- ddr write enable
    ddr_rasb2   : out std_ulogic;                               -- ddr ras
    ddr_casb2   : out std_ulogic;                               -- ddr cas
    ddr_ad2     : out std_logic_vector (abits-1 downto 0);      -- ddr address
    ddr_ba2     : out std_logic_vector (1+eightbanks downto 0); -- ddr bank address

    -- Pass through to pads
    dq_control  : in std_logic_vector(17 downto 0);
    dqs_control : in std_logic_vector(17 downto 0);
    ck_control  : in std_logic_vector(17 downto 0);
    cmd_control : in std_logic_vector(17 downto 0);
    compen      : in std_logic;
    compupd     : in std_logic
  );

end component;

component ut90nhbd_ddr_phy_wo_pads is
  generic (
    MHz: integer := 100;
    abits: integer := 15;
    dbits: integer := 96;
    nclk: integer := 3;
    ncs: integer := 2);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    clkoutret : in  std_ulogic;                 -- system clock return
    lock      : out std_ulogic;			-- DCM locked
    ddr_clk 	: out std_logic_vector(nclk-1 downto 0);
    ddr_clkb	: out std_logic_vector(nclk-1 downto 0);
    ddr_cke  	: out std_logic_vector(ncs-1 downto 0);
    ddr_csb  	: out std_logic_vector(ncs-1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in     : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs    
    ddr_ad      : out std_logic_vector (abits-1 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq_in      : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_out     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_oen     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data    

    addr  	: in  std_logic_vector (abits-1 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(ncs-1 downto 0);
    cke       	: in  std_logic_vector(ncs-1 downto 0);
    ck          : in  std_logic_vector(nclk-1 downto 0);
    moben       : in  std_ulogic;
    dqvalid     : out std_ulogic;

    testen      : in  std_ulogic;
    testrst     : in  std_ulogic;
    scanen      : in  std_ulogic;
    testoen     : in  std_ulogic);
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

component uniphy_ddr2_phy is
  generic (
    MHz        : integer := 100;
    rstdelay   : integer := 200;
    dbits      : integer := 16;
    clk_mul    : integer := 2;
    clk_div    : integer := 2;
    eightbanks : integer  range 0 to 1 := 0;
    abits      : integer := 14;
    nclk       : integer := 3;
    ncs        : integer := 2);
  port (
    rst        : in  std_ulogic;
    clk        : in  std_logic;        -- input clock
                                       -- for operating without PLL
    clkout     : out std_ulogic;       -- system clock
    clkoutret  : in  std_ulogic;       -- system clock return
    lock       : out std_ulogic;       -- DCM locked

    ddr_clk    : out std_logic_vector(nclk-1 downto 0);
    ddr_clkb   : out std_logic_vector(nclk-1 downto 0);
    ddr_cke    : out std_logic_vector(ncs-1 downto 0);
    ddr_csb    : out std_logic_vector(ncs-1 downto 0);
    ddr_web    : out std_ulogic;                               -- ddr write enable
    ddr_rasb   : out std_ulogic;                               -- ddr ras
    ddr_casb   : out std_ulogic;                               -- ddr cas
    ddr_dm     : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs    : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
    ddr_dqsn   : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqsn
    ddr_ad     : out std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba     : out std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq     : inout  std_logic_vector (dbits-1 downto 0);   -- ddr data
    ddr_odt    : out std_logic_vector(ncs-1 downto 0);

    addr       : in  std_logic_vector (abits-1 downto 0);           -- ddr address
    ba         : in  std_logic_vector ( 2 downto 0);           -- ddr bank address
    dqin       : out std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
    dqout      : in  std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
    dm         : in  std_logic_vector (dbits/4-1 downto 0);    -- data mask
    oen        : in  std_ulogic;
    rasn       : in  std_ulogic;
    casn       : in  std_ulogic;
    wen        : in  std_ulogic;
    csn        : in  std_logic_vector(ncs-1 downto 0);
    cke        : in  std_logic_vector(ncs-1 downto 0);
    odt        : in  std_logic_vector(ncs-1 downto 0);
    read_pend  : in  std_logic_vector(7 downto 0);
    regwdata   : in  std_logic_vector(63 downto 0);
    regwrite   : in  std_logic_vector(1 downto 0);
    regrdata   : out std_logic_vector(63 downto 0);
    dqin_valid : out std_ulogic;
    oct_rdn        : in  std_logic := '0';
    oct_rup        : in  std_logic := '0'
  );

end component;

end;

