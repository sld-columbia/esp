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
-- Entity: 	various
-- File:	ddr_phy_unisim.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	DDR PHY for Virtex-2 and Virtex-4
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
-- pragma translate_off
library unisim;
use unisim.vcomponents.BUFG;
use unisim.vcomponents.DCM;
use unisim.vcomponents.ODDR;
use unisim.vcomponents.FD;
use unisim.vcomponents.IDDR;
-- pragma translate_on

use work.gencomp.all;

------------------------------------------------------------------
-- Virtex4 DDR PHY -----------------------------------------------
------------------------------------------------------------------

entity virtex4_ddr_phy is
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2; rskew : integer := 0;
        phyiconf : integer := 0);

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

end;

architecture rtl of virtex4_ddr_phy is

  component DCM
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false 
    );
    port (
      CLKFB    : in  std_logic;
      CLKIN    : in  std_logic;
      DSSEN    : in  std_logic;
      PSCLK    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      RST      : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKDV    : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      STATUS   : out std_logic_vector (7 downto 0));
  end component;
  component BUFG port (O : out std_logic; I : in std_logic); end component;
  component ODDR
    generic
      ( DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
--        INIT : bit := '0';
        SRTYPE : string := "SYNC");
    port
      (
        Q : out std_ulogic;
        C : in std_ulogic;
        CE : in std_ulogic;
        D1 : in std_ulogic;
        D2 : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic
      );
  end component;
  component FD
	generic ( INIT : bit := '0');
	port (  Q : out std_ulogic;
		C : in std_ulogic;
		D : in std_ulogic);
  end component;
    component IDDR
      generic ( DDR_CLK_EDGE : string := "SAME_EDGE";
          INIT_Q1 : bit := '0';
          INIT_Q2 : bit := '0';
          SRTYPE : string := "ASYNC");
      port
        ( Q1 : out std_ulogic;
          Q2 : out std_ulogic;
          C : in std_ulogic;
          CE : in std_ulogic;
          D : in std_ulogic;
          R : in std_ulogic;
          S : in std_ulogic);
    end component;

signal vcc, gnd, dqsn, oe, lockl : std_ulogic;
signal ddr_clk_fb_outr : std_ulogic;
signal ddr_clk_fbl, fbclk : std_ulogic;
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;
signal ddr_clkl, ddr_clkbl : std_logic_vector(2 downto 0);
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(1 downto 0);
signal clk_0ro, clk_90ro, clk_180ro, clk_270ro : std_ulogic;
signal clk_0r, clk_90r, clk_180r, clk_270r : std_ulogic;
signal clk0r, clk90r, clk180r, clk270r : std_ulogic;
signal locked, vlockl, ddrclkfbl, dllfb : std_ulogic;

signal ddr_dqin  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqout  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqoen  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_adr      	: std_logic_vector (13 downto 0);   -- ddr address
signal ddr_bar      	: std_logic_vector (1 downto 0);   -- ddr address
signal ddr_dmr      	: std_logic_vector (dbits/8-1 downto 0);   -- ddr address
signal ddr_dqsin  	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoen 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoutl 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsdel, dqsclk 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal da     		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dqinl		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dllrst		: std_logic_vector(0 to 3);
signal dll0rst, dll2rst	: std_logic_vector(0 to 3);
signal mlock, mclkfb, mclk, mclkfx, mclk0 : std_ulogic;
signal rclk270b, rclk90b, rclk0b : std_ulogic;
signal rclk270, rclk90, rclk0 : std_ulogic;

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

  attribute keep : boolean;
  attribute keep of rclk90b : signal is true;
  attribute syn_keep : boolean;
  attribute syn_keep of rclk90b : signal is true;
  attribute syn_preserve : boolean;
  attribute syn_preserve of rclk90b : signal is true;

  -- To prevent synplify 9.4 to remove any of these registers.
  attribute syn_noprune : boolean;
  attribute syn_noprune of FD : component is true;
  attribute syn_noprune of IDDR : component is true;
  attribute syn_noprune of ODDR : component is true;

begin

  oe <= not oen;
  vcc <= '1'; gnd <= '0';

  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    mclk <= clk;
  end generate;

  clkscale : if clk_mul /= clk_div generate

    rstdel : process (clk, rst)
    begin
        if rst = '0' then dll0rst <= (others => '1');
        elsif rising_edge(clk) then
  	  dll0rst <= dll0rst(1 to 3) & '0';
        end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0, O => mclkfb);

    dllm : DCM
      generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div)
      port map ( CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
      LOCKED => mlock, CLKFX => mclkfx );
  end generate;

  -- DDR clock generation

  ddrref_pad : clkpad generic map (tech => virtex4) 
	port map (ddr_clk_fb, ddrclkfbl); 
  
  bufg1 : BUFG port map (I => clk_0ro, O => clk_0r);
--  bufg2 : BUFG port map (I => clk_90ro, O => clk_90r);
  clk_90r <= not clk_270r;
--  bufg3 : BUFG port map (I => clk_180ro, O => clk_180r);
  clk_180r <= not clk_0r;
  bufg4 : BUFG port map (I => clk_270ro, O => clk_270r);

  clkout <= clk_270r; clk0r <= clk_270r; clk90r <= clk_0r;
  clk180r <= clk_90r; clk270r <= clk_180r;

  
  dllfb <= clk_0r;

  dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2)
      port map ( CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_0ro, 
      CLK90 => clk_90ro, CLK180 => clk_180ro, CLK270 => clk_270ro, 
      LOCKED => lockl);

  rstdel : process (mclk, rst)
  begin
      if rst = '0' then dllrst <= (others => '1');
      elsif rising_edge(mclk) then
	dllrst <= dllrst(1 to 3) & '0';
      end if;
  end process;

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk_0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk_0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
	  cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16); vlock := '0';
        else
	  if vlock = '0' then
	    cnt := cnt -1;  vlock := cnt(15) and not co;
	  end if;
        end if;
      end if;
      if lockl = '0' then
	vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock <= locked;

  -- Generate external DDR clock

  fbdclk0r : ODDR port map ( Q => ddr_clk_fb_outr, C => clk90r, CE => vcc,
		D1 => vcc, D2 => gnd, R => gnd, S => gnd);
  fbclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk_fb_out, ddr_clk_fb_outr);

  ddrclkdiffio : if phyiconf = 0 generate
    ddrclocks0 : for i in 0 to 2 generate
      dclk0r : ODDR port map ( Q => ddr_clkl(i), C => clk90r, CE => vcc,
                               D1 => vcc, D2 => gnd, R => gnd, S => gnd);
      ddrclk_pad : outpad_ds generic map (tech => virtex4, level => sstl2_ii) 
        port map (ddr_clk(i), ddr_clkb(i), ddr_clkl(i), '1');
    end generate;    
  end generate;
  ddrclknodiffio : if phyiconf = 1 generate
    ddrclocks1 : for i in 0 to 2 generate
      dclk0r : ODDR port map ( Q => ddr_clkl(i), C => clk90r, CE => vcc,
                               D1 => vcc, D2 => gnd, R => gnd, S => gnd);
      ddrclk1_pad : outpad generic map (tech => virtex4, level => sstl2_ii) 
	port map (ddr_clk(i), ddr_clkl(i));

      dclk0rb : ODDR port map ( Q => ddr_clkbl(i), C => clk90r, CE => vcc,
                                D1 => gnd, D2 => vcc, R => gnd, S => gnd);
      ddrclk1b_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clkb(i), ddr_clkbl(i));
    end generate;
  end generate;

  ddrbanks : for i in 0 to 1 generate
    csn0gen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_csnr(i), C => clk0r, CE => vcc,
		D1 => csn(i), D2 => csn(i), R => gnd, S => gnd);
    csn0_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_csb(i), ddr_csnr(i));

    ckel(i) <= cke(i) and locked;
    ckegen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_ckenr(i), C => clk0r, CE => vcc,
		D1 => ckel(i), D2 => ckel(i), R => gnd, S => gnd);
    cke_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_cke(i), ddr_ckenr(i));
  end generate;

  rasgen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_rasnr, C => clk0r, CE => vcc,
		D1 => rasn, D2 => rasn, R => gnd, S => gnd);
  rasn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_rasb, ddr_rasnr);

  casgen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_casnr, C => clk0r, CE => vcc,
		D1 => casn, D2 => casn, R => gnd, S => gnd);
  casn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_casb, ddr_casnr);

  wengen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_wenr, C => clk0r, CE => vcc,
		D1 => wen, D2 => wen, R => gnd, S => gnd);
  wen_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_web, ddr_wenr);

  dmgen : for i in 0 to dbits/8-1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
               port map ( Q => ddr_dmr(i), C => clk0r, CE => vcc,
		D1 => dm(i+dbits/8), D2 => dm(i), R => gnd, S => gnd);
    ddr_bm_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  bagen : for i in 0 to 1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
               port map ( Q => ddr_bar(i), C => clk0r, CE => vcc,
		D1 => ba(i), D2 => ba(i), R => gnd, S => gnd);
    ddr_ba_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ba(i), ddr_bar(i));
  end generate;

  dagen : for i in 0 to 13 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
               port map ( Q => ddr_adr(i), C => clk0r, CE => vcc,
		D1 => addr(i), D2 => addr(i), R => gnd, S => gnd);
    ddr_ad_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ad(i), ddr_adr(i));

  end generate;

  -- DQS generation
  dsqreg : FD port map ( Q => dqsn, C => clk180r, D => oe);
  dqsgen : for i in 0 to dbits/8-1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
    	port map ( Q => ddr_dqsin(i), C => clk90r, CE => vcc,
		D1 => dqsn, D2 => gnd, R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);
    dqs_pad : iopad generic map (tech => virtex4, level => sstl2_ii)
         port map (pad => ddr_dqs(i), i => ddr_dqsin(i), en => ddr_dqsoen(i), 
		o => ddr_dqsoutl(i));
  end generate;

  -- Data bus


    read_rstdel : process (clk_0r, lockl)
    begin
        if lockl = '0' then dll2rst <= (others => '1');
        elsif rising_edge(clk_0r) then
  	  dll2rst <= dll2rst(1 to 3) & '0';
        end if;
    end process;

    bufg7 : BUFG port map (I => rclk0, O => rclk0b);
    bufg8 : BUFG port map (I => rclk90, O => rclk90b);
--    bufg9 : BUFG port map (I => rclk270, O => rclk270b);
    rclk270b <= not rclk90b;

  nops : if rskew = 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS")
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

  ps : if rskew /= 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", 
	CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => rskew)
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

    ddgen : for i in 0 to dbits-1 generate
      qi : IDDR generic map (DDR_CLK_EDGE => "OPPOSITE_EDGE")
      port map ( Q1 => dqinl(i), --(i+dbits), -- 1-bit output for positive edge of clock 
               Q2 => dqin(i), -- 1-bit output for negative edge of clock 
               C => rclk90b, --clk270r, --dqsclk((2*i)/dbits), -- 1-bit clock input 
              CE => vcc, -- 1-bit clock enable input 
               D => ddr_dqin(i), -- 1-bit DDR data input 
               R => gnd, -- 1-bit reset 
               S => gnd -- 1-bit set 
             );

      dinq1 : FD port map ( Q => dqin(i+dbits), C => rclk270b, D => dqinl(i));
      dout : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_dqout(i), C => clk0r, CE => vcc,
		D1 => dqout(i+dbits), D2 => dqout(i), R => gnd, S => gnd);
      doen : FD port map ( Q => ddr_dqoen(i), C => clk0r, D => oen);
      dq_pad : iopad generic map (tech => virtex4, level => sstl2_ii)
         port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => ddr_dqin(i));
    end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
--use unisim.vcomponents.BUFG;
--use unisim.vcomponents.DCM;
--use unisim.vcomponents.FDDRRSE;
--use unisim.vcomponents.IFDDRRSE;
--use unisim.vcomponents.FD;
-- pragma translate_on

use work.stdlib.all;
use work.gencomp.all;

------------------------------------------------------------------
-- Virtex2 DDR PHY -----------------------------------------------
------------------------------------------------------------------

entity virtex2_ddr_phy is
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

end;

architecture rtl of virtex2_ddr_phy is

  component DCM
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false 
    );
    port (
      CLKFB    : in  std_logic;
      CLKIN    : in  std_logic;
      DSSEN    : in  std_logic;
      PSCLK    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      RST      : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKDV    : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      STATUS   : out std_logic_vector (7 downto 0));
  end component;
  component BUFG port (O : out std_logic; I : in std_logic); end component;
  component FDDRRSE
--    generic ( INIT : bit := '0');
    port
      (
        Q : out std_ulogic;
        C0 : in std_ulogic;
        C1 : in std_ulogic;
        CE : in std_ulogic;
        D0 : in std_ulogic;
        D1 : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic
      );
  end component;

  component IFDDRRSE
	port (
		Q0 : out std_ulogic;
		Q1 : out std_ulogic;
		C0 : in std_ulogic;
		C1 : in std_ulogic;
		CE : in std_ulogic;
		D : in std_ulogic;
		R : in std_ulogic;
		S : in std_ulogic);
  end component;
  component FD
	generic ( INIT : bit := '0');
	port (  Q : out std_ulogic;
		C : in std_ulogic;
		D : in std_ulogic);
  end component;

  component oddrv2
  generic ( tech : integer := virtex4); 
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
  end component;

signal vcc, gnd, dqsn, oe, lockl : std_ulogic;
signal ddr_clk_fb_outr : std_ulogic;
signal ddr_clk_fbl, fbclk : std_ulogic;
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;
signal ddr_clkl, ddr_clkbl : std_logic_vector(2 downto 0);
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(1 downto 0);
signal clk_0ro, clk_90ro, clk_180ro, clk_270ro : std_ulogic;
signal clk_0r, clk_90r, clk_180r, clk_270r : std_ulogic;
signal clk0r, clk90r, clk180r, clk270r : std_ulogic;
signal locked, vlockl, ddrclkfbl : std_ulogic;
signal ddr_dqin  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqout  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqoen  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_adr      	: std_logic_vector (13 downto 0);   -- ddr address
signal ddr_bar      	: std_logic_vector (1 downto 0);   -- ddr address
signal ddr_dmr      	: std_logic_vector (dbits/8-1 downto 0);   -- ddr address
signal ddr_dqsin  	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoen 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoutl 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsdel, dqsclk 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal da     		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dqinl		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dllrst		: std_logic_vector(0 to 3);
signal dll0rst, dll2rst	: std_logic_vector(0 to 3);
signal mlock, mclkfb, mclk, mclkfx, mclk0 : std_ulogic;
signal rclk270b, rclk90b, rclk0b : std_ulogic;
signal rclk270, rclk90, rclk0 : std_ulogic;

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

-- To prevent synplify 9.4 to remove any of these registers.
attribute syn_noprune : boolean;
attribute syn_noprune of FD : component is true;
attribute syn_noprune of FDDRRSE : component is true;
attribute syn_noprune of IFDDRRSE : component is true;
attribute syn_noprune of oddrv2 : component is true;

begin

  oe <= not oen;
  vcc <= '1'; gnd <= '0';

  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    mclk <= clk; mlock <= rst;
  end generate;

  clkscale : if clk_mul /= clk_div generate

    rstdel : process (clk, rst)
    begin
        if rst = '0' then dll0rst <= (others => '1');
        elsif rising_edge(clk) then
  	  dll0rst <= dll0rst(1 to 3) & '0';
        end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0, O => mclkfb);

    dllm : DCM
      generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div,
	CLKIN_PERIOD => 10.0)
      port map ( CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
      LOCKED => mlock, CLKFX => mclkfx );
  end generate;

  -- DDR output clock generation
  
  bufg1 : BUFG port map (I => clk_0ro, O => clk_0r);
--  bufg2 : BUFG port map (I => clk_90ro, O => clk_90r);
  clk_90r <= not clk_270r;
--  bufg3 : BUFG port map (I => clk_180ro, O => clk_180r);
  clk_180r <= not clk_0r;
  bufg4 : BUFG port map (I => clk_270ro, O => clk_270r);

  clkout <= clk_270r; clk0r <= clk_270r; clk90r <= clk_0r;
  clk180r <= clk_90r; clk270r <= clk_180r;

  
  dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2)
      port map ( CLKIN => mclk, CLKFB => clk_0r, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_0ro, 
      CLK90 => clk_90ro, CLK180 => clk_180ro, CLK270 => clk_270ro, 
      LOCKED => lockl);

  rstdel : process (mclk, mlock)
  begin
      if mlock = '0' then dllrst <= (others => '1');
      elsif rising_edge(mclk) then
	dllrst <= dllrst(1 to 3) & '0';
      end if;
  end process;

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk_0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk_0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
	  cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16); vlock := '0';
        else
	  if vlock = '0' then
	    cnt := cnt -1;  vlock := cnt(15) and not co;
	  end if;
        end if;
      end if;
      if lockl = '0' then
	vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock <= locked;

  -- Generate external DDR clock

  fbdclk0r : FDDRRSE port map ( Q => ddr_clk_fb_outr, C0 => clk90r, C1 => clk270r,
	CE => vcc, D0 => vcc, D1 => gnd, R => gnd, S => gnd);
  fbclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk_fb_out, ddr_clk_fb_outr);

  ddrclocks : for i in 0 to 2 generate
    dclk0r : FDDRRSE port map ( Q => ddr_clkl(i), C0 => clk90r, C1 => clk270r, 
	CE => vcc, D0 => vcc, D1 => gnd, R => gnd, S => gnd);
    ddrclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk(i), ddr_clkl(i));

    dclk0rb : FDDRRSE port map ( Q => ddr_clkbl(i), C0 => clk90r, C1 => clk270r,
	CE => vcc, D0 => gnd, D1 => vcc, R => gnd, S => gnd);
    ddrclkb_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clkb(i), ddr_clkbl(i));
  end generate;

  ddrbanks : for i in 0 to 1 generate
    csn0gen : FD port map ( Q => ddr_csnr(i), C => clk0r, D => csn(i));
    csn0_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_csb(i), ddr_csnr(i));

    ckel(i) <= cke(i) and locked;
    ckegen : FD port map ( Q => ddr_ckenr(i), C => clk0r, D => ckel(i));
    cke_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_cke(i), ddr_ckenr(i));

  end generate;

  --  DDR single-edge control signals
  rasgen : FD port map ( Q => ddr_rasnr, C => clk0r, D => rasn);
  rasn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_rasb, ddr_rasnr);

  casgen : FD port map ( Q => ddr_casnr, C => clk0r, D => casn);
  casn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_casb, ddr_casnr);

  wengen : FD port map ( Q => ddr_wenr, C => clk0r, D => wen);
  wen_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_web, ddr_wenr);

  dmgen : for i in 0 to dbits/8-1 generate
    da0 : oddrv2 port map ( Q => ddr_dmr(i), C1 => clk0r, C2 => clk180r,
	CE => vcc, D1 => dm(i+dbits/8), D2 => dm(i), R => gnd, S => gnd);
    ddr_bm_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  bagen : for i in 0 to 1 generate
    da0 : FD port map ( Q => ddr_bar(i), C => clk0r, D => ba(i));
    ddr_ba_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ba(i), ddr_bar(i));
  end generate;

  dagen : for i in 0 to 13 generate
    da0 : FD port map ( Q => ddr_adr(i), C => clk0r, D => addr(i));
    ddr_ad_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ad(i), ddr_adr(i));

  end generate;

  -- DQS generation
  dsqreg : FD port map ( Q => dqsn, C => clk180r, D => oe);
  dqsgen : for i in 0 to dbits/8-1 generate
    da0 : oddrv2
    	port map ( Q => ddr_dqsin(i), C1 => clk90r,  C2 => clk270r, 
	CE => vcc, D1 => dqsn, D2 => gnd, R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);
    dqs_pad : iopad generic map (tech => virtex4, level => sstl2_ii)
         port map (pad => ddr_dqs(i), i => ddr_dqsin(i), en => ddr_dqsoen(i), 
		o => ddr_dqsoutl(i));
  end generate;

  -- Data bus

  ddrref_pad : clkpad generic map (tech => virtex2) 
	port map (ddr_clk_fb, ddrclkfbl); 

    read_rstdel : process (clk_0r, lockl)
    begin
        if lockl = '0' then dll2rst <= (others => '1');
        elsif rising_edge(clk_0r) then
  	  dll2rst <= dll2rst(1 to 3) & '0';
        end if;
    end process;

    bufg7 : BUFG port map (I => rclk0, O => rclk0b);
    bufg8 : BUFG port map (I => rclk90, O => rclk90b);
--    bufg9 : BUFG port map (I => rclk270, O => rclk270b);
    rclk270b <= not rclk90b;

  nops : if rskew = 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS")
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

  ps : if rskew /= 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", 
	CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => rskew)
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

  ddgen : for i in 0 to dbits-1 generate
    qi : IFDDRRSE
    port map ( Q0 => dqinl(i), --(i+dbits), -- 1-bit output for positive edge of clock 
               Q1 => dqin(i), -- 1-bit output for negative edge of clock 
	       C0 => rclk90b, -- clk270r, --dqsclk((2*i)/dbits), -- 1-bit clock input 
	       C1 => rclk270b, -- clk90r, --dqsclk((2*i)/dbits), -- 1-bit clock input 
	       CE => vcc, -- 1-bit clock enable input 
		D => ddr_dq(i), -- 1-bit DDR data input 
		R => gnd, -- 1-bit reset 
		S => gnd -- 1-bit set 
	      );

--    dinq1 : FD port map ( Q => dqin(i+dbits), C => clk90r, D => dqinl(i));
    dinq1 : FD port map ( Q => dqin(i+dbits), C => rclk270b, D => dqinl(i));
    dout : oddrv2
	port map ( Q => ddr_dqout(i), C1 => clk0r, C2 => clk180r, CE => vcc,
		D1 => dqout(i+dbits), D2 => dqout(i), R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqoen(i), C => clk0r, D => oen);
    dq_pad : iopad generic map (tech => virtex4, level => sstl2_ii)
         port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => open); -- o => ddr_dqin(i));
  end generate;


  
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.vcomponents.BUFG;
use unisim.vcomponents.DCM;
use unisim.vcomponents.ODDR2;
use unisim.vcomponents.IDDR2;
use unisim.vcomponents.FD;
-- pragma translate_on

use work.stdlib.all;
use work.gencomp.all;

------------------------------------------------------------------
-- Spartan3E DDR PHY -----------------------------------------------
------------------------------------------------------------------

entity spartan3e_ddr_phy is
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

end;

architecture rtl of spartan3e_ddr_phy is

component oddrc3e
  generic ( tech : integer := virtex4); 
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end component;

  component DCM
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false 
    );
    port (
      CLKFB    : in  std_logic;
      CLKIN    : in  std_logic;
      DSSEN    : in  std_logic;
      PSCLK    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      RST      : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKDV    : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      STATUS   : out std_logic_vector (7 downto 0));
  end component;
  component BUFG port (O : out std_logic; I : in std_logic); end component;
  component FD
	generic ( INIT : bit := '0');
	port (  Q : out std_ulogic;
		C : in std_ulogic;
		D : in std_ulogic);
  end component;

  component ODDR2
	generic
	(
		DDR_ALIGNMENT : string := "NONE";
		INIT : bit := '0';
		SRTYPE : string := "SYNC"
	);
	port
	(
		Q : out std_ulogic;
		C0 : in std_ulogic;
		C1 : in std_ulogic;
		CE : in std_ulogic;
		D0 : in std_ulogic;
		D1 : in std_ulogic;
		R : in std_ulogic;
		S : in std_ulogic
	);
  end component;
  component IDDR2
	generic
	(
		DDR_ALIGNMENT : string := "NONE";
		INIT_Q0 : bit := '0';
		INIT_Q1 : bit := '0';
		SRTYPE : string := "SYNC"
	);
	port
	(
		Q0 : out std_ulogic;
		Q1 : out std_ulogic;
		C0 : in std_ulogic;
		C1 : in std_ulogic;
		CE : in std_ulogic;
		D : in std_ulogic;
		R : in std_ulogic;
		S : in std_ulogic
	);
  end component;

signal vcc, gnd, dqsn, oe, lockl : std_ulogic;
signal ddr_clk_fb_outr : std_ulogic;
signal ddr_clk_fbl, fbclk : std_ulogic;
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;
signal ddr_clkl, ddr_clkbl : std_logic_vector(2 downto 0);
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(1 downto 0);
signal clk_0ro, clk_90ro, clk_180ro, clk_270ro : std_ulogic;
signal clk_0r, clk_90r, clk_180r, clk_270r : std_ulogic;
signal clk0r, clk90r, clk180r, clk270r : std_ulogic;
signal locked, vlockl, ddrclkfbl, dllfb : std_ulogic;
signal ddr_dqin  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqout  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqoen  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_adr      	: std_logic_vector (13 downto 0);   -- ddr address
signal ddr_bar      	: std_logic_vector (1 downto 0);   -- ddr address
signal ddr_dmr      	: std_logic_vector (dbits/8-1 downto 0);   -- ddr address
signal ddr_dqsin  	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoen 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoutl 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsdel, dqsclk 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal da     		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dqinl		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dllrst		: std_logic_vector(0 to 3);
signal dll0rst, dll2rst	: std_logic_vector(0 to 3);
signal mlock, mclkfb, mclk, mclkfx, mclk0 : std_ulogic;
signal rclk270b, rclk90b, rclk0b : std_ulogic;
signal rclk270, rclk90, rclk0 : std_ulogic;

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

-- To prevent synplify 9.4 to remove any of these registers.
attribute syn_noprune : boolean;
attribute syn_noprune of FD : component is true;
attribute syn_noprune of IDDR2 : component is true;
attribute syn_noprune of ODDR2 : component is true;
attribute syn_noprune of oddrc3e : component is true;

begin

  oe <= not oen;
  vcc <= '1'; gnd <= '0';

  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    mclk <= clk; mlock <= rst;
  end generate;

  clkscale : if clk_mul /= clk_div generate

    rstdel : process (clk, rst)
    begin
        if rst = '0' then dll0rst <= (others => '1');
        elsif rising_edge(clk) then
  	  dll0rst <= dll0rst(1 to 3) & '0';
        end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0, O => mclkfb);

    dllm : DCM
      generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div,
	CLKIN_PERIOD => 10.0)
      port map ( CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
      LOCKED => mlock, CLKFX => mclkfx );
  end generate;

  -- DDR output clock generation
  
  bufg1 : BUFG port map (I => clk_0ro, O => clk_0r);
--  bufg2 : BUFG port map (I => clk_90ro, O => clk_90r);
  clk_90r <= not clk_270r;
--  bufg3 : BUFG port map (I => clk_180ro, O => clk_180r);
  clk_180r <= not clk_0r;
  bufg4 : BUFG port map (I => clk_270ro, O => clk_270r);

  clkout <= clk_270r; 
--  clkout <= clk_90r when DDR_FREQ > 120 else clk_0r; 

  clk0r <= clk_270r; clk90r <= clk_0r;
  clk180r <= clk_90r; clk270r <= clk_180r;

  dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2)
      port map ( CLKIN => mclk, CLKFB => clk_0r, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_0ro, 
      CLK90 => clk_90ro, CLK180 => clk_180ro, CLK270 => clk_270ro, 
      LOCKED => lockl);

  rstdel : process (mclk, mlock)
  begin
      if mlock = '0' then dllrst <= (others => '1');
      elsif rising_edge(mclk) then
	dllrst <= dllrst(1 to 3) & '0';
      end if;
  end process;

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk_0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk_0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
	  cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16); vlock := '0';
        else
	  if vlock = '0' then
	    cnt := cnt -1;  vlock := cnt(15) and not co;
	  end if;
        end if;
      end if;
      if lockl = '0' then
	vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock <= locked;

  -- Generate external DDR clock

  fbdclk0r : ODDR2 port map ( Q => ddr_clk_fb_outr, C0 => clk90r, C1 => clk270r,
	CE => vcc, D0 => vcc, D1 => gnd, R => gnd, S => gnd);
  fbclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk_fb_out, ddr_clk_fb_outr);

  ddrclocks : for i in 0 to 2 generate
    dclk0r : ODDR2 port map ( Q => ddr_clkl(i), C0 => clk90r, C1 => clk270r, 
	CE => vcc, D0 => vcc, D1 => gnd, R => gnd, S => gnd);
    ddrclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk(i), ddr_clkl(i));

    dclk0rb : ODDR2 port map ( Q => ddr_clkbl(i), C0 => clk90r, C1 => clk270r,
	CE => vcc, D0 => gnd, D1 => vcc, R => gnd, S => gnd);
    ddrclkb_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clkb(i), ddr_clkbl(i));
  end generate;

  ddrbanks : for i in 0 to 1 generate
    csn0gen : FD port map ( Q => ddr_csnr(i), C => clk0r, D => csn(i));
    csn0_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_csb(i), ddr_csnr(i));

    ckel(i) <= cke(i) and locked;
    ckegen : FD port map ( Q => ddr_ckenr(i), C => clk0r, D => ckel(i));
    cke_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_cke(i), ddr_ckenr(i));

  end generate;

  --  DDR single-edge control signals
  rasgen : FD port map ( Q => ddr_rasnr, C => clk0r, D => rasn);
  rasn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_rasb, ddr_rasnr);

  casgen : FD port map ( Q => ddr_casnr, C => clk0r, D => casn);
  casn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_casb, ddr_casnr);

  wengen : FD port map ( Q => ddr_wenr, C => clk0r, D => wen);
  wen_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_web, ddr_wenr);

  dmgen : for i in 0 to dbits/8-1 generate
    da0 : oddrc3e 
        port map ( Q => ddr_dmr(i), C1 => clk0r, C2 => clk180r,
	CE => vcc, D1 => dm(i+dbits/8), D2 => dm(i), R => gnd, S => gnd);
    ddr_bm_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  bagen : for i in 0 to 1 generate
    da0 : FD port map ( Q => ddr_bar(i), C => clk0r, D => ba(i));
    ddr_ba_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ba(i), ddr_bar(i));
  end generate;

  dagen : for i in 0 to 13 generate
    da0 : FD port map ( Q => ddr_adr(i), C => clk0r, D => addr(i));
    ddr_ad_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ad(i), ddr_adr(i));

  end generate;

  -- DQS generation
  dsqreg : FD port map ( Q => dqsn, C => clk180r, D => oe);
  dqsgen : for i in 0 to dbits/8-1 generate
    da0 : oddrc3e
    	port map ( Q => ddr_dqsin(i), C1 => clk90r,  C2 => clk270r, 
	CE => vcc, D1 => dqsn, D2 => gnd, R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);
    dqs_pad : iopad generic map (tech => virtex4, level => sstl2_i)
         port map (pad => ddr_dqs(i), i => ddr_dqsin(i), en => ddr_dqsoen(i), 
		o => ddr_dqsoutl(i));
  end generate;

  -- Data bus

  ddrref_pad : clkpad generic map (tech => virtex2) 
	port map (ddr_clk_fb, ddrclkfbl); 


    read_rstdel : process (clk_0r, lockl)
    begin
        if lockl = '0' then dll2rst <= (others => '1');
        elsif rising_edge(clk_0r) then
  	  dll2rst <= dll2rst(1 to 3) & '0';
        end if;
    end process;

    bufg7 : BUFG port map (I => rclk0, O => rclk0b);
    bufg8 : BUFG port map (I => rclk90, O => rclk90b);
--    bufg9 : BUFG port map (I => rclk270, O => rclk270b);
    rclk270b <= not rclk90b;
    clkread <= not rclk90b;

  nops : if rskew = 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS")
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;
  ps : if rskew /= 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", 
	CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => rskew)
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

  ddgen : for i in 0 to dbits-1 generate
    qi : IDDR2
    port map ( Q0 => dqinl(i), Q1 => dqin(i), C0 => rclk90b, C1 => rclk270b, 
	       CE => vcc, D => ddr_dqin(i), R => gnd, S => gnd );
    dinq1 : FD port map ( Q => dqin(i+dbits), C => rclk270b, D => dqinl(i));
    dout : oddrc3e
	port map ( Q => ddr_dqout(i), C1 => clk0r, C2 => clk180r, CE => vcc,
		D1 => dqout(i+dbits), D2 => dqout(i), R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqoen(i), C => clk0r, D => oen);
    dq_pad : iopad generic map (tech => virtex4, level => sstl2_i)
       port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => ddr_dqin(i));
  end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
-- pragma translate_off
library unisim;
use unisim.vcomponents.BUFG;
use unisim.vcomponents.DCM;
use unisim.vcomponents.ODDR;
use unisim.vcomponents.FD;
use unisim.vcomponents.IDELAY;
use unisim.vcomponents.IDELAYE2;
use unisim.vcomponents.PLLE2_ADV;
use unisim.vcomponents.ISERDES;
use unisim.vcomponents.BUFIO;
use unisim.vcomponents.IDELAYCTRL;
use unisim.vcomponents.IDDR;
-- pragma translate_on

use work.gencomp.all;
------------------------------------------------------------------
-- Virtex5 DDR2 PHY ----------------------------------------------
------------------------------------------------------------------

entity virtex5_ddr2_phy_wo_pads is
  generic (MHz : integer := 100; rstdelay : integer := 200;
           dbits : integer := 16; clk_mul : integer := 2; clk_div : integer := 2;
           ddelayb0 : integer := 0; ddelayb1 : integer := 0; ddelayb2 : integer := 0;
           ddelayb3 : integer := 0; ddelayb4 : integer := 0; ddelayb5 : integer := 0;
           ddelayb6 : integer := 0; ddelayb7 : integer := 0; ddelayb8 : integer := 0;
           ddelayb9 : integer := 0; ddelayb10: integer := 0; ddelayb11: integer := 0;
           numidelctrl : integer := 4; norefclk : integer := 0; 
           tech : integer := virtex5; odten : integer := 0;
           eightbanks : integer  range 0 to 1 := 0;
           dqsse : integer range 0 to 1 := 0; abits: integer := 14; nclk: integer := 3;
           ncs: integer := 2);
  port (
    rst        : in  std_ulogic;
    clk        : in  std_logic;        -- input clock
    clkref200  : in  std_logic;        -- input 200MHz clock
    clkout     : out std_ulogic;       -- system clock
    clkoutret  : in  std_ulogic;       -- system clock return
    lock       : out std_ulogic;       -- DCM locked

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

    addr       : in  std_logic_vector (abits-1 downto 0);           -- ddr address
    ba         : in  std_logic_vector ( 2 downto 0);           -- ddr bank address
    dqin       : out std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
    dqout      : in  std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
    dm         : in  std_logic_vector (dbits/4-1 downto 0);    -- data mask
    oen        : in  std_ulogic;
    dqs        : in  std_ulogic;
    dqsoen     : in  std_ulogic;
    rasn       : in  std_ulogic;
    casn       : in  std_ulogic;
    wen        : in  std_ulogic;
    csn        : in  std_logic_vector(ncs-1 downto 0);
    cke        : in  std_logic_vector(ncs-1 downto 0);
    cal_en     : in  std_logic_vector(dbits/8-1 downto 0);
    cal_inc    : in  std_logic_vector(dbits/8-1 downto 0);
    cal_rst    : in  std_logic;
    odt        : in  std_logic_vector(ncs-1 downto 0)
  );

end;

architecture rtl of virtex5_ddr2_phy_wo_pads is

  component DCM
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false 
    );
    port (
      CLKFB    : in  std_logic;
      CLKIN    : in  std_logic;
      DSSEN    : in  std_logic;
      PSCLK    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      RST      : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKDV    : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      STATUS   : out std_logic_vector (7 downto 0));
  end component;

  component BUFG port (O : out std_logic; I : in std_logic); end component;
  component ODDR
    generic
      ( DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
--        INIT : bit := '0';
        SRTYPE : string := "SYNC");
    port
      (
        Q : out std_ulogic;
        C : in std_ulogic;
        CE : in std_ulogic;
        D1 : in std_ulogic;
        D2 : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic
      );
  end component;
  component FD
    generic ( INIT : bit := '0');
    port (  Q : out std_ulogic;
      C : in std_ulogic;
      D : in std_ulogic);
  end component;
  component IDDR
    generic ( DDR_CLK_EDGE : string := "SAME_EDGE";
        INIT_Q1 : bit := '0';
        INIT_Q2 : bit := '0';
        SRTYPE : string := "ASYNC");
    port
      ( Q1 : out std_ulogic;
        Q2 : out std_ulogic;
        C : in std_ulogic;
        CE : in std_ulogic;
        D : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic);
  end component;

  component IDELAY
    generic ( IOBDELAY_TYPE : string := "DEFAULT";
              IOBDELAY_VALUE : integer := 0);
    port (  O : out std_ulogic;
      C : in std_ulogic;
      CE : in std_ulogic;
      I : in std_ulogic;
      INC : in std_ulogic;
      RST : in std_ulogic);
  end component;


  component OBUFDS
    generic (
     CAPACITANCE : string := "DONT_CARE";
     IOSTANDARD : string := "DEFAULT";
     SLEW : string := "SLOW"
    );
    port (
     O : out std_ulogic;
     OB : out std_ulogic;
     I : in std_ulogic
    );
  end component;

   component IDELAYCTRL
   port (  RDY : out std_ulogic;
      REFCLK : in std_ulogic;
      RST : in std_ulogic);
  end component;

  component PLLE2_ADV
  generic (
     BANDWIDTH : string := "OPTIMIZED";
     CLKFBOUT_MULT : integer := 5;
     CLKFBOUT_PHASE : real := 0.0;
     CLKIN1_PERIOD : real := 0.0;
     CLKIN2_PERIOD : real := 0.0;
     CLKOUT0_DIVIDE : integer := 1;
     CLKOUT0_DUTY_CYCLE : real := 0.5;
     CLKOUT0_PHASE : real := 0.0;
     CLKOUT1_DIVIDE : integer := 1;
     CLKOUT1_DUTY_CYCLE : real := 0.5;
     CLKOUT1_PHASE : real := 0.0;
     CLKOUT2_DIVIDE : integer := 1;
     CLKOUT2_DUTY_CYCLE : real := 0.5;
     CLKOUT2_PHASE : real := 0.0;
     CLKOUT3_DIVIDE : integer := 1;
     CLKOUT3_DUTY_CYCLE : real := 0.5;
     CLKOUT3_PHASE : real := 0.0;
     CLKOUT4_DIVIDE : integer := 1;
     CLKOUT4_DUTY_CYCLE : real := 0.5;
     CLKOUT4_PHASE : real := 0.0;
     CLKOUT5_DIVIDE : integer := 1;
     CLKOUT5_DUTY_CYCLE : real := 0.5;
     CLKOUT5_PHASE : real := 0.0;
     COMPENSATION : string := "ZHOLD";
     DIVCLK_DIVIDE : integer := 1;
     REF_JITTER1 : real := 0.0;
     REF_JITTER2 : real := 0.0;
     STARTUP_WAIT : string := "FALSE"
  );
  port (
     CLKFBOUT : out std_ulogic := '0';
     CLKOUT0 : out std_ulogic := '0';
     CLKOUT1 : out std_ulogic := '0';
     CLKOUT2 : out std_ulogic := '0';
     CLKOUT3 : out std_ulogic := '0';
     CLKOUT4 : out std_ulogic := '0';
     CLKOUT5 : out std_ulogic := '0';
     DO : out std_logic_vector (15 downto 0);
     DRDY : out std_ulogic := '0';
     LOCKED : out std_ulogic := '0';
     CLKFBIN : in std_ulogic;
     CLKIN1 : in std_ulogic;
     CLKIN2 : in std_ulogic;
     CLKINSEL : in std_ulogic;
     DADDR : in std_logic_vector(6 downto 0);
     DCLK : in std_ulogic;
     DEN : in std_ulogic;
     DI : in std_logic_vector(15 downto 0);
     DWE : in std_ulogic;
     PWRDWN : in std_ulogic;
     RST : in std_ulogic
  );
  end component;

  component IDELAYE2
  generic (
     CINVCTRL_SEL : string := "FALSE";
     DELAY_SRC : string := "IDATAIN";
     HIGH_PERFORMANCE_MODE : string := "FALSE";
     IDELAY_TYPE : string := "FIXED";
     IDELAY_VALUE : integer := 0;
     PIPE_SEL : string := "FALSE";
     REFCLK_FREQUENCY : real := 200.0;
     SIGNAL_PATTERN : string := "DATA"
  );
  port (
     CNTVALUEOUT : out std_logic_vector(4 downto 0);
     DATAOUT : out std_ulogic;
     C : in std_ulogic;
     CE : in std_ulogic;
     CINVCTRL : in std_ulogic;
     CNTVALUEIN : in std_logic_vector(4 downto 0);
     DATAIN : in std_ulogic;
     IDATAIN : in std_ulogic;
     INC : in std_ulogic;
     LD : in std_ulogic;
     LDPIPEEN : in std_ulogic;
     REGRST : in std_ulogic
  );
end component;

signal dllfbout, dllfbin, refdllfbout, refdllfbin, ddrdllfbout, ddrdllfbin : std_logic;

signal vcc, gnd, oe, lockl : std_ulogic;
signal dqsn : std_logic_vector(dbits/8-1 downto 0);
signal cbdqsn : std_logic_vector(dbits/8-1 downto 0);

signal ddr_clk_fb_outr : std_ulogic;
signal ddr_clk_fbl, fbclk : std_ulogic;
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;
signal ddr_rasnr2, ddr_casnr2, ddr_wenr2 : std_ulogic;
signal ddr_clkl, ddr_clkbl : std_logic_vector(nclk-1 downto 0);
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(ncs-1 downto 0);
signal clk_0ro, clk_90ro, clk_180ro, clk_270ro : std_ulogic;
signal clk_0r, clk_90r, clk_180r, clk_270r : std_ulogic;
signal clk90r, clk180r, clk270r : std_ulogic;
signal locked, vlockl, ddrclkfbl, dllfb : std_ulogic;

signal ddr_dqin, ddr_dqin_nodel, ddr_dqintemp : std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqout     : std_logic_vector (dbits-1 downto 0);      -- ddr data
signal ddr_dqoen     : std_logic_vector (dbits-1 downto 0);      -- ddr data
signal ddr_cbdqin, ddr_cbdqin_nodel : std_logic_vector (dbits-1 downto 0); -- ddr checkbits
signal ddr_cbdqout   : std_logic_vector (dbits-1 downto 0);      -- ddr checkbits
signal ddr_cbdqoen   : std_logic_vector (dbits-1 downto 0);      -- ddr checkbits
signal ddr_adr       : std_logic_vector (abits-1 downto 0);           -- ddr address
signal ddr_bar       : std_logic_vector (1+eightbanks downto 0); -- ddr address
signal ddr_adr2      : std_logic_vector (abits-1 downto 0);           -- ddr address
signal ddr_bar2      : std_logic_vector (1+eightbanks downto 0); -- ddr address
signal ddr_dmr       : std_logic_vector (dbits/8-1 downto 0);    -- ddr data mask
signal ddr_cbdmr     : std_logic_vector (dbits/8-1 downto 0);    -- ddr checkbit mask
signal ddr_dqsin     : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoen_reg: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs reg
signal ddr_dqsoen    : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoutl   : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_cbdqsin     : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_cbdqsoen_reg: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs reg
signal ddr_cbdqsoen    : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_cbdqsoutl   : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsdel, dqsclk, dqsclkn : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal da            : std_logic_vector (dbits-1 downto 0); -- ddr data
signal dqinl         : std_logic_vector (dbits-1 downto 0); -- ddr data
signal dllrst        : std_logic_vector(0 to 3);
signal dll0rst, dll2rst : std_logic_vector(0 to 3);
signal mlock, mclkfb, mclk, mclkfx, mclk0 : std_ulogic;
signal rclk270b, rclk90b, rclk0b : std_ulogic;
signal rclk270, rclk90, rclk0 : std_ulogic;
signal clk200, clk200_0, clk200fb, clk200fx, lock200 : std_logic;
signal odtl : std_logic_vector(ncs-1 downto 0);
signal refclk_rdy : std_logic_vector(numidelctrl-1 downto 0);

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

type ddelay_type is array (0 to 11) of integer;
constant ddelay : ddelay_type := (ddelayb0, ddelayb1, ddelayb2,
                                  ddelayb3, ddelayb4, ddelayb5,
                                  ddelayb6, ddelayb7, ddelayb8,
                                  ddelayb9, ddelayb10, ddelayb11);

attribute syn_noprune : boolean;
attribute syn_noprune of IDELAYCTRL : component is true;
attribute syn_keep : boolean;
attribute syn_keep of dqsclk : signal is true;
attribute syn_preserve : boolean;
attribute syn_preserve of dqsclk : signal is true;
attribute syn_keep of dqsn : signal is true;
attribute syn_preserve of dqsn : signal is true;

-- To prevent synplify 9.4 to remove any of these registers.
attribute syn_noprune of FD : component is true;
attribute syn_noprune of IDDR : component is true;
attribute syn_noprune of ODDR : component is true;

attribute keep : boolean;
attribute keep of mclkfx : signal is true;
attribute keep of clk_90ro : signal is true;
attribute syn_keep of mclkfx : signal is true;
attribute syn_keep of clk_90ro : signal is true;

signal clk_180temp : std_logic;

begin

   -- Generate 200 MHz ref clock if not supplied
  refclkx : if norefclk = 0 generate
    buf_clk200 : BUFG port map( I => clkref200, O => clk200);
    lock200 <= '1';
  end generate;
  
  norefclkx : if norefclk /= 0 generate
    bufg0 : BUFG port map (I => clk200fx, O => clk200);

    HMODE_dll200 : if (tech = virtex4 and MHz >= 210) or (tech = virtex5) generate
      dll200 : DCM
        generic map (
          CLKFX_MULTIPLY => 400/MHz, CLKFX_DIVIDE => 2,
          DFS_FREQUENCY_MODE => "HIGH", DLL_FREQUENCY_MODE => "HIGH",
          CLK_FEEDBACK => "NONE")
        port map (
          CLKIN => clk, CLKFB => clk200fb, DSSEN => gnd, PSCLK => gnd,
          PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0),
          LOCKED => lock200, CLKFX => clk200fx);
    end generate;
    LMODE_dll200 : if not ((tech = virtex4 and MHz >= 210) or (tech = virtex5) or 
                     tech = virtex7 or tech = kintex7 or tech = artix7 or tech = zynq7000) generate
      dll200 : DCM
        generic map (
          CLKFX_MULTIPLY => 400/MHz, CLKFX_DIVIDE => 2,
          DFS_FREQUENCY_MODE => "LOW", DLL_FREQUENCY_MODE => "LOW",
          CLK_FEEDBACK => "NONE")
        port map (
          CLKIN => clk, CLKFB => clk200fb, DSSEN => gnd, PSCLK => gnd,
          PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0),
          LOCKED => lock200, CLKFX => clk200fx);
    end generate;
    V7_refdll : if (tech = virtex7 or tech = kintex7 or tech = artix7 or tech = zynq7000) generate
    bufg0_fb : BUFG port map (I => refdllfbout, O => refdllfbin);
        PLLE2_ADV_inst : PLLE2_ADV generic map (
          BANDWIDTH          => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
          CLKFBOUT_MULT      => 1200/MHz,   -- Multiply value for all CLKOUT, (2-64)
          CLKFBOUT_PHASE     => 0.0, -- Phase offset in degrees of CLKFB, (-360.000-360.000).
          -- CLKIN_PERIOD: Input clock period in nS to ps resolution (i.e. 33.333 is 30 MHz).
          CLKIN1_PERIOD      => 1000.0/real(MHz),
          CLKIN2_PERIOD      => 0.0,
          -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT (1-128)
          CLKOUT0_DIVIDE     => 6,
          CLKOUT1_DIVIDE     => 1,
          CLKOUT2_DIVIDE     => 1,
          CLKOUT3_DIVIDE     => 1,
          CLKOUT4_DIVIDE     => 1,
          CLKOUT5_DIVIDE     => 1,
          -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
          CLKOUT0_DUTY_CYCLE => 0.5,
          CLKOUT1_DUTY_CYCLE => 0.5,
          CLKOUT2_DUTY_CYCLE => 0.5,
          CLKOUT3_DUTY_CYCLE => 0.5,
          CLKOUT4_DUTY_CYCLE => 0.5,
          CLKOUT5_DUTY_CYCLE => 0.5,
          -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
          CLKOUT0_PHASE      => 0.0,
          CLKOUT1_PHASE      => 0.0,
          CLKOUT2_PHASE      => 0.0,
          CLKOUT3_PHASE      => 0.0,
          CLKOUT4_PHASE      => 0.0,
          CLKOUT5_PHASE      => 0.0,
          COMPENSATION       => "ZHOLD", -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
          DIVCLK_DIVIDE      => 1, -- Master division value (1-56)
          -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
          REF_JITTER1        => 0.0,
          REF_JITTER2        => 0.0,
          STARTUP_WAIT       => "TRUE" -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
        )
        port map (
          -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
          CLKOUT0           => clk200fx,
          CLKOUT1           => open, -- actually is only 20 degrees (see CLKOUT1_PHASE)
          CLKOUT2           => open,
          CLKOUT3           => open,
          CLKOUT4           => open,
          CLKOUT5           => open,
          -- DRP Ports: 16-bit (each) output: Dynamic reconfigration ports
          DO                => open,
          DRDY              => open,
          -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
          CLKFBOUT          => refdllfbout,
          -- Status Ports: 1-bit (each) output: PLL status ports
          LOCKED            => lock200,
          -- Clock Inputs: 1-bit (each) input: Clock inputs
          CLKIN1            => clk,
          CLKIN2            => '0',
          -- Con trol Ports: 1-bit (each) input: PLL control ports
          CLKINSEL          => '1',
          PWRDWN            => '0',
          RST               => dll0rst(0),
          -- DRP Ports: 7-bit (each) input: Dynamic reconfigration ports
          DADDR             => "0000000",
          DCLK              => '0',
          DEN               => '0',
          DI                => "0000000000000000",
          DWE               => '0',
          -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
          CLKFBIN           => refdllfbin
        );
    end generate;
  end generate;

  -- Delay control
  idelctrl : for i in 0 to numidelctrl-1 generate
     u : IDELAYCTRL port map (rst => dllrst(0), refclk => clk200, rdy => refclk_rdy(i));
  end generate;

  oe  <= not oen;
  vcc <= '1';
  gnd <= '0';
  
  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    rstdel : process (clk, rst)
    begin
        if rst = '0' then
          dll0rst <= (others => '1');
        elsif rising_edge(clk) then
          dll0rst <= dll0rst(1 to 3) & '0';
        end if;
    end process;
    --dll0rst <= dllrst;
    mlock   <= '1';
    mbufg0 : BUFG port map (I => clk, O => mclk);
  end generate;

  clkscale : if clk_mul /= clk_div generate
    rstdel : process (clk, rst)
    begin
        if rst = '0' then
          dll0rst <= (others => '1');
        elsif rising_edge(clk) then
          dll0rst <= dll0rst(1 to 3) & '0';
        end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0, O => mclkfb);

    HMODE_dllm : if    (tech = virtex4 and (((MHz*clk_mul)/clk_div >= 210) or (MHz >= 210))) 
                    or (tech = virtex5 and (((MHz*clk_mul)/clk_div > 140)  or (MHz > 120))) generate
      dllm : DCM
        generic map (
          CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div,
          DFS_FREQUENCY_MODE => "HIGH", DLL_FREQUENCY_MODE => "HIGH")
        port map (
          CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
          PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
          LOCKED => mlock, CLKFX => mclkfx );
    end generate;
    LMODE_dllm : if not ((tech = virtex4 and (((MHz*clk_mul)/clk_div >= 210) or (MHz >= 210))) 
                      or (tech = virtex5 and (((MHz*clk_mul)/clk_div > 140)  or (MHz > 120))) or 
                     tech = virtex7 or tech = kintex7 or tech = artix7 or tech = zynq7000) generate
      dllm : DCM
        generic map (
          CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div,
          DFS_FREQUENCY_MODE => "LOW", DLL_FREQUENCY_MODE => "LOW")
        port map (
          CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
          PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
          LOCKED => mlock, CLKFX => mclkfx );
    end generate;
    V7_ddrdll : if (tech = virtex7 or tech = kintex7 or tech = artix7 or tech = zynq7000) generate
      bufg1_fb : BUFG port map (I => ddrdllfbout, O => ddrdllfbin);
          PLLE2_ADV_inst : PLLE2_ADV generic map (
            BANDWIDTH          => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
            CLKFBOUT_MULT      => clk_mul,   -- Multiply value for all CLKOUT, (2-64)
            CLKFBOUT_PHASE     => 0.0, -- Phase offset in degrees of CLKFB, (-360.000-360.000).
            -- CLKIN_PERIOD: Input clock period in nS to ps resolution (i.e. 33.333 is 30 MHz).
            CLKIN1_PERIOD      => 1000.0/real(MHz),
            CLKIN2_PERIOD      => 0.0,
            -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT (1-128)
            CLKOUT0_DIVIDE     => clk_div,
            CLKOUT1_DIVIDE     => 1,
            CLKOUT2_DIVIDE     => 1,
            CLKOUT3_DIVIDE     => 1,
            CLKOUT4_DIVIDE     => 1,
            CLKOUT5_DIVIDE     => 1,
            -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
            CLKOUT0_DUTY_CYCLE => 0.5,
            CLKOUT1_DUTY_CYCLE => 0.5,
            CLKOUT2_DUTY_CYCLE => 0.5,
            CLKOUT3_DUTY_CYCLE => 0.5,
            CLKOUT4_DUTY_CYCLE => 0.5,
            CLKOUT5_DUTY_CYCLE => 0.5,
            -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
            CLKOUT0_PHASE      => 0.0,
            CLKOUT1_PHASE      => 0.0,
            CLKOUT2_PHASE      => 0.0,
            CLKOUT3_PHASE      => 0.0,
            CLKOUT4_PHASE      => 0.0,
            CLKOUT5_PHASE      => 0.0,
            COMPENSATION       => "ZHOLD", -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
            DIVCLK_DIVIDE      => 1, -- Master division value (1-56)
            -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
            REF_JITTER1        => 0.0,
            REF_JITTER2        => 0.0,
            STARTUP_WAIT       => "TRUE" -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
          )
          port map (
            -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
            CLKOUT0           => mclkfx,
            CLKOUT1           => open,
            CLKOUT2           => open,
            CLKOUT3           => open,
            CLKOUT4           => open,
            CLKOUT5           => open,
            -- DRP Ports: 16-bit (each) output: Dynamic reconfigration ports
            DO                => open,
            DRDY              => open,
            -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
            CLKFBOUT          => ddrdllfbout,
            -- Status Ports: 1-bit (each) output: PLL status ports
            LOCKED            => mlock,
            -- Clock Inputs: 1-bit (each) input: Clock inputs
            CLKIN1            => clk,
            CLKIN2            => '0',
            -- Con trol Ports: 1-bit (each) input: PLL control ports
            CLKINSEL          => '1',
            PWRDWN            => '0',
            RST               => dll0rst(0),
            -- DRP Ports: 7-bit (each) input: Dynamic reconfigration ports
            DADDR             => "0000000",
            DCLK              => '0',
            DEN               => '0',
            DI                => "0000000000000000",
            DWE               => '0',
            -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
            CLKFBIN           => ddrdllfbin
          );
    end generate;
  end generate;
    
  -- DDR clock generation


  bufg2 : BUFG port map (I => clk_90ro, O => clk90r);  
  clkout <= mclk;
  dllfb  <= clk90r;

    HMODE_dll : if (tech = virtex4 and ((MHz*clk_mul)/clk_div >= 150))
                   or (tech = virtex5 and ((MHz*clk_mul)/clk_div >= 120)) generate
      dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2, 
                             DFS_FREQUENCY_MODE => "HIGH", DLL_FREQUENCY_MODE => "HIGH", --"HIGH")
                             PHASE_SHIFT => 64, CLKOUT_PHASE_SHIFT => "FIXED")--, CLKIN_PERIOD => real((1000*clk_div)/(MHz*clk_mul)))
          port map ( CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
          PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_90ro,
          CLK90 => open, CLK180 => open, CLK270 => open,
          LOCKED => lockl);
      clk180r <= not mclk;
    end generate;
    LMODE_dll : if not ((tech = virtex4 and ((MHz*clk_mul)/clk_div >= 150))
                   or (tech = virtex5 and ((MHz*clk_mul)/clk_div >= 120))
                   or tech = virtex7 or tech = kintex7 or tech = artix7 or tech = zynq7000) generate
      dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2, 
                             DFS_FREQUENCY_MODE => "LOW", DLL_FREQUENCY_MODE => "LOW", --"HIGH")
                             PHASE_SHIFT => 64, CLKOUT_PHASE_SHIFT => "FIXED")--, CLKIN_PERIOD => real((1000*clk_div)/(MHz*clk_mul)))
          port map ( CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
          PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_90ro,
          CLK90 => open, CLK180 => open, CLK270 => open,
          LOCKED => lockl);
      clk180r <= not mclk;
    end generate;
    V7_dll : if (tech = virtex7 or tech = kintex7 or tech = artix7 or tech = zynq7000) generate
        bufg2 : BUFG port map (I => dllfbout, O => dllfbin);
        bufg3 : BUFG port map (I => clk_180temp, O => clk180r);

        PLLE2_ADV_inst : PLLE2_ADV generic map (
          BANDWIDTH          => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
          CLKFBOUT_MULT      => 9,   -- Multiply value for all CLKOUT, (2-64)
          CLKFBOUT_PHASE     => 0.0, -- Phase offset in degrees of CLKFB, (-360.000-360.000).
          -- CLKIN_PERIOD: Input clock period in nS to ps resolution (i.e. 33.333 is 30 MHz).
          CLKIN1_PERIOD      => 1000.0/real(MHz*clk_mul/clk_div),
          CLKIN2_PERIOD      => 0.0,
          -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT (1-128)
          CLKOUT0_DIVIDE     => 1,
          CLKOUT1_DIVIDE     => 9,
          CLKOUT2_DIVIDE     => 9,
          CLKOUT3_DIVIDE     => 1,
          CLKOUT4_DIVIDE     => 1,
          CLKOUT5_DIVIDE     => 1,
          -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
          CLKOUT0_DUTY_CYCLE => 0.5,
          CLKOUT1_DUTY_CYCLE => 0.5,
          CLKOUT2_DUTY_CYCLE => 0.5,
          CLKOUT3_DUTY_CYCLE => 0.5,
          CLKOUT4_DUTY_CYCLE => 0.5,
          CLKOUT5_DUTY_CYCLE => 0.5,
          -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
          CLKOUT0_PHASE      => 0.0,
          CLKOUT1_PHASE      => 90.0,
          CLKOUT2_PHASE      => 180.0,
          CLKOUT3_PHASE      => 0.0,
          CLKOUT4_PHASE      => 0.0,
          CLKOUT5_PHASE      => 0.0,
          COMPENSATION       => "ZHOLD", -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
          DIVCLK_DIVIDE      => 1, -- Master division value (1-56)
          -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
          REF_JITTER1        => 0.0,
          REF_JITTER2        => 0.0,
          STARTUP_WAIT       => "TRUE" -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
        )
        port map (
          -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
          CLKOUT0           => open,
          CLKOUT1           => clk_90ro,
          CLKOUT2           => clk_180temp,
          CLKOUT3           => open,
          CLKOUT4           => open,
          CLKOUT5           => open,
          -- DRP Ports: 16-bit (each) output: Dynamic reconfigration ports
          DO                => open,
          DRDY              => open,
          -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
          CLKFBOUT          => dllfbout,
          -- Status Ports: 1-bit (each) output: PLL status ports
          LOCKED            => lockl,
          -- Clock Inputs: 1-bit (each) input: Clock inputs
          CLKIN1            => mclk,
          CLKIN2            => '0',
          -- Con trol Ports: 1-bit (each) input: PLL control ports
          CLKINSEL          => '1',
          PWRDWN            => '0',
          RST               => dllrst(0),
          -- DRP Ports: 7-bit (each) input: Dynamic reconfigration ports
          DADDR             => "0000000",
          DCLK              => '0',
          DEN               => '0',
          DI                => "0000000000000000",
          DWE               => '0',
          -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
          CLKFBIN           => dllfbin
        );
    end generate;


  rstdel : process (mclk, rst, mlock, lock200)
  begin
      if rst = '0' or mlock = '0' or lock200 = '0' then dllrst <= (others => '1');
      elsif rising_edge(mclk) then
         dllrst <= dllrst(1 to 3) & '0';
      end if;
  end process;

  rdel : if rstdelay /= 0 generate
    --rcnt : process (clk_0r)
    rcnt : process (clkoutret)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      --if rising_edge(clk_0r) then
      if rising_edge(clkoutret) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
          cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16); vlock := '0';
        else
          if vlock = '0' then
            cnt := cnt -1;  vlock := cnt(15) and not co;
          end if;
        end if;
      end if;
      if lockl = '0' then
        vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock <= locked and orv(refclk_rdy);

  -- Generate external DDR clock
  ddrclocks : for i in 0 to nclk-1 generate
    dclk0r : ODDR port map ( Q => ddr_clk(i), C => clk90r, CE => vcc,
                             D1 => vcc, D2 => gnd, R => gnd, S => gnd);
    ddr_clkb(i) <= '0'; -- unused
  end generate;

  -- ODT
  odtgen : for i in 0 to ncs-1 generate
    odtl(i) <= locked and orv(refclk_rdy) and odt(i);
    ddr_odt(i) <= odtl(i);
  end generate;

  ddrbanks : for i in 0 to ncs-1 generate
    csn0gen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_csnr(i), C => clk180r, CE => vcc,
                 D1 => csn(i), D2 => csn(i), R => gnd, S => gnd);
    ddr_csb(i) <= ddr_csnr(i);

    ckel(i) <= cke(i) and locked;
    ckegen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_ckenr(i), C => clk180r, CE => vcc,
                 D1 => ckel(i), D2 => ckel(i), R => gnd, S => gnd);
    ddr_cke(i) <= ddr_ckenr(i);
  end generate;

  rasgen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
    port map ( Q => ddr_rasnr, C => clk180r, CE => vcc,
               D1 => rasn, D2 => rasn, R => gnd, S => gnd);
  ddr_rasb <= ddr_rasnr;

  casgen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
    port map ( Q => ddr_casnr, C => clk180r, CE => vcc,
               D1 => casn, D2 => casn, R => gnd, S => gnd);
  ddr_casb <= ddr_casnr;

  wengen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
    port map ( Q => ddr_wenr, C => clk180r, CE => vcc,
               D1 => wen, D2 => wen, R => gnd, S => gnd);
  ddr_web <= ddr_wenr;

  dmgen : for i in 0 to dbits/8-1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_dmr(i), C => clkoutret, CE => vcc,
                 D1 => dm(i+dbits/8), D2 => dm(i), R => gnd, S => gnd);    
  end generate;
  ddr_dm <= ddr_dmr;

  bagen : for i in 0 to 1+eightbanks generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_bar(i), C => clk180r, CE => vcc,
                 D1 => ba(i), D2 => ba(i), R => gnd, S => gnd);    
  end generate;
  ddr_ba <= ddr_bar;

  dagen : for i in 0 to abits-1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_adr(i), C => clk180r, CE => vcc,
                 D1 => addr(i), D2 => addr(i), R => gnd, S => gnd);
  end generate;
  ddr_ad <= ddr_adr;

  -- DQS generation
  dqsgen : for i in 0 to dbits/8-1 generate
    dsqreg : FD port map ( Q => dqsn(i), C => clk180r, D => oe);
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_dqsin(i), C => clk90r, CE => vcc,
                 --D1 => dqsn, D2 => gnd, R => gnd, S => gnd);
                 D1 => dqsn(i), D2 => gnd, R => gnd, S => gnd);
    doen_reg : FD port map ( Q => ddr_dqsoen_reg(i), C => clk180r, D => dqsoen);
    doen : FD port map ( Q => ddr_dqsoen(i), C => clk90r, D => ddr_dqsoen_reg(i));
    
  end generate;
  ddr_dqs_out <= ddr_dqsin;
  ddr_dqs_oen <= ddr_dqsoen;
  ddr_dqsoutl <= ddr_dqs_in;
  
  -- Data bus
  ddgen : for i in 0 to dbits-1 generate
    idelay_v4: if (tech = virtex4 or tech = virtex5 or tech = virtex6) generate
      del_dq0 : IDELAY generic map(IOBDELAY_TYPE => "VARIABLE", IOBDELAY_VALUE => ddelay(i/8))
        port map(O => ddr_dqin(i), I => ddr_dqin_nodel(i), C => clkoutret, CE => cal_en(i/8),
                 INC => cal_inc(i/8), RST => cal_rst);
    end generate;
    idelay_v7: if (tech = virtex7 or tech = kintex7 or tech = artix7 or tech = zynq7000) generate
      del_dq0 : IDELAYE2 generic map(CINVCTRL_SEL => "FALSE", DELAY_SRC => "IDATAIN",
          HIGH_PERFORMANCE_MODE => "TRUE", IDELAY_TYPE => "VARIABLE", IDELAY_VALUE => ddelay(i/8),
          PIPE_SEL => "FALSE", REFCLK_FREQUENCY => 200.0, SIGNAL_PATTERN => "DATA")
        port map(
          CNTVALUEOUT => open, DATAOUT => ddr_dqintemp(i), C => clkoutret, CE => cal_en(i/8), CINVCTRL => '0',
          CNTVALUEIN => "00000", DATAIN => '0', IDATAIN => ddr_dqin_nodel(i), INC => cal_inc(i/8), LD => cal_rst,
          LDPIPEEN => '0', REGRST => '0');

      del_dq1 : IDELAYE2 generic map(CINVCTRL_SEL => "FALSE", DELAY_SRC => "DATAIN",
          HIGH_PERFORMANCE_MODE => "TRUE", IDELAY_TYPE => "VARIABLE", IDELAY_VALUE => ddelay(i/8),
          PIPE_SEL => "FALSE", REFCLK_FREQUENCY => 200.0, SIGNAL_PATTERN => "DATA")
        port map(
          CNTVALUEOUT => open, DATAOUT => ddr_dqin(i), C => clkoutret, CE => cal_en(i/8), CINVCTRL => '0',
          CNTVALUEIN => "00000", DATAIN => ddr_dqintemp(i), IDATAIN => '0', INC => cal_inc(i/8), LD => cal_rst,
          LDPIPEEN => '0', REGRST => '0');
    end generate;
    
    qi : IDDR generic map (DDR_CLK_EDGE => "OPPOSITE_EDGE")
      port map ( Q1 => dqinl(i),   --(i+dbits), -- 1-bit output for positive edge of clock 
                 Q2 => dqin(i),    --dqin(i), -- 1-bit output for negative edge of clock 
                 C => clk180r,     --clk270r, --dqsclk((2*i)/dbits), -- 1-bit clock input 
                 CE => vcc,        -- 1-bit clock enable input 
                 D => ddr_dqin(i), -- 1-bit DDR data input 
                 R => gnd,         -- 1-bit reset 
                 S => gnd          -- 1-bit set 
               );
    dinq1 : FD port map ( Q => dqin(i+dbits), C => clkoutret, D => dqinl(i));
    
    dout : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_dqout(i), C => clkoutret, CE => vcc,
                 D1 => dqout(i+dbits), D2 => dqout(i), R => gnd, S => gnd);
    doen : FD
      generic map (INIT => '1')
      port map ( Q => ddr_dqoen(i), C => clkoutret, D => oen);
    
  end generate;
  ddr_dq_out <= ddr_dqout;
  ddr_dq_oen <= ddr_dqoen;
  ddr_dqin_nodel <= ddr_dq_in;
  
end;


------------------------------------------------------------------
-- Spartan 3A DDR2 PHY -------------------------------------------
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
-- pragma translate_off
library unisim;
use unisim.vcomponents.BUFG;
use unisim.vcomponents.DCM;
use unisim.vcomponents.IDDR2;
use unisim.vcomponents.ODDR2;
use unisim.vcomponents.FD;
use unisim.vcomponents.BUFIO;
-- pragma translate_on

use work.gencomp.all;

entity spartan3a_ddr2_phy is
  generic (MHz         : integer := 125; rstdelay   : integer := 200;
           dbits       : integer := 16;  clk_mul    : integer := 2;
           clk_div     : integer := 2;   tech       : integer := spartan3;
           rskew       : integer := 0;   eightbanks : integer range 0 to 1 := 0);
  port (   rst         : in  std_ulogic;
           clk         : in  std_logic;        -- input clock
           clkout      : out std_ulogic;       -- DDR clock
           lock        : out std_ulogic;       -- DCM locked
           
           ddr_clk     : out std_logic_vector(2 downto 0);
           ddr_clkb    : out std_logic_vector(2 downto 0);
           ddr_clk_fb_out : out std_logic;
           ddr_clk_fb  : in  std_logic;
           ddr_cke     : out std_logic_vector(1 downto 0);
           ddr_csb     : out std_logic_vector(1 downto 0);
           ddr_web     : out std_ulogic;                               -- ddr write enable
           ddr_rasb    : out std_ulogic;                               -- ddr ras
           ddr_casb    : out std_ulogic;                               -- ddr cas
           ddr_dm      : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
           ddr_dqs     : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
           ddr_dqsn    : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqsn
           ddr_ad      : out std_logic_vector (13 downto 0);           -- ddr address
           ddr_ba      : out std_logic_vector (1+eightbanks downto 0); -- ddr bank address
           ddr_dq      : inout  std_logic_vector (dbits-1 downto 0);   -- ddr data
           ddr_odt     : out std_logic_vector(1 downto 0);

           addr        : in  std_logic_vector (13 downto 0);           -- row address
           ba          : in  std_logic_vector ( 2 downto 0);           -- bank address
           dqin        : out std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
           dqout       : in  std_logic_vector (dbits*2-1 downto 0);    -- ddr output data
           dm          : in  std_logic_vector (dbits/4-1 downto 0);    -- data mask
           oen         : in  std_ulogic;
           dqs         : in  std_ulogic;
           dqsoen      : in  std_ulogic;
           rasn        : in  std_ulogic;
           casn        : in  std_ulogic;
           wen         : in  std_ulogic;
           csn         : in  std_logic_vector(1 downto 0);
           cke         : in  std_logic_vector(1 downto 0);
           cal_pll     : in  std_logic_vector(1 downto 0);
           odt         : in  std_logic_vector(1 downto 0));
end;

architecture rtl of spartan3a_ddr2_phy is
  component DCM
    generic (CLKDV_DIVIDE          :     real       := 2.0;
             CLKFX_DIVIDE          :     integer    := 1;
             CLKFX_MULTIPLY        :     integer    := 4;
             CLKIN_DIVIDE_BY_2     :     boolean    := false;
             CLKIN_PERIOD          :     real       := 10.0;
             CLKOUT_PHASE_SHIFT    :     string     := "NONE";
             CLK_FEEDBACK          :     string     := "1X";
             DESKEW_ADJUST         :     string     := "SYSTEM_SYNCHRONOUS";
             DFS_FREQUENCY_MODE    :     string     := "LOW";
             DLL_FREQUENCY_MODE    :     string     := "LOW";
             DSS_MODE              :     string     := "NONE";
             DUTY_CYCLE_CORRECTION :     boolean    := true;
             FACTORY_JF            :     bit_vector := X"C080";
             PHASE_SHIFT           :     integer    := 0;
             STARTUP_WAIT          :     boolean    := false);
    port (   CLKFB                 : in  std_logic;
             CLKIN                 : in  std_logic;
             DSSEN                 : in  std_logic;
             PSCLK                 : in  std_logic;
             PSEN                  : in  std_logic;
             PSINCDEC              : in  std_logic;
             RST                   : in  std_logic;
             CLK0                  : out std_logic;
             CLK90                 : out std_logic;
             CLK180                : out std_logic;
             CLK270                : out std_logic;
             CLK2X                 : out std_logic;
             CLK2X180              : out std_logic;
             CLKDV                 : out std_logic;
             CLKFX                 : out std_logic;
             CLKFX180              : out std_logic;
             LOCKED                : out std_logic;
             PSDONE                : out std_logic;
             STATUS                : out std_logic_vector (7 downto 0));
  end component;

  component BUFG
    port (O : out std_logic;
          I : in std_logic);
  end component;

  component ODDR2
    generic (DDR_ALIGNMENT : string := "NONE"; -- Sets output alignment to "NONE", "C0" or "C1"
             INIT : bit := '0';                -- Sets initial state of the Q0  
             SRTYPE : string := "SYNC");       -- Specifies "SYNC" or "ASYNC" set/reset
    port (   Q  : out std_ulogic;              -- 1-bit DDR output data
             C0 : in  std_ulogic;              -- 1-bit clock input
             C1 : in  std_ulogic;              -- 1-bit clock input
             CE : in  std_ulogic;              -- 1-bit clock enable input
             D0 : in  std_ulogic;              -- 1-bit data input (associated with C1)
             D1 : in  std_ulogic;              -- 1-bit data input (associated with C1)
             R  : in  std_ulogic;              -- 1-bit reset input
             S  : in  std_ulogic);             -- 1-bit set input
  end component;

  component FD
    generic (INIT : bit := '0');
    port (   Q : out std_ulogic;
             C : in std_ulogic;
             D : in std_ulogic);
  end component;

  component IDDR2
    generic (DDR_ALIGNMENT : string := "NONE"; -- Sets output alignment to "NONE", "C0" or "C1"
             INIT_Q0 : bit := '0';             -- Sets initial state of the Q0
             INIT_Q1 : bit := '0';             -- Sets initial state of the Q1
             SRTYPE  : string := "SYNC");      -- Specifies "SYNC" or "ASYNC" set/reset
    port (   Q0 : out std_ulogic;              -- 1-bit output captured with C0 clock
             Q1 : out std_ulogic;              -- 1-bit output captured with C1 clock
             C0 : in  std_ulogic;              -- 1-bit clock input
             C1 : in  std_ulogic;              -- 1-bit clock input
             CE : in  std_ulogic;              -- 1-bit clock enable input
             D  : in  std_ulogic;              -- 1-bit DDR data input
             R  : in  std_ulogic;              -- 1-bit reset input
             S  : in  std_ulogic);             -- 1-bit set input
  end component;

  signal vcc, gnd, oe, lockl : std_ulogic;
  signal dqsn                : std_logic_vector(dbits/8-1 downto 0);

  signal ddr_rasnr, ddr_casnr, ddr_wenr      : std_ulogic;
  signal ddr_clkl, ddr_clkbl                 : std_logic_vector(2 downto 0);
  signal ddr_csnr, ddr_ckenr, ckel           : std_logic_vector(1 downto 0);
  signal ddr_clk_fbl, ddr_clk_fb_outl        : std_ulogic;
  signal clk_90ro                            : std_ulogic;
  signal clk0r, clk90r, clk180r, clk270r     : std_ulogic;
  signal rclk0b, rclk90b, rclk180b, rclk270b : std_ulogic;
  signal rclk0, rclk90, rclk180, rclk270     : std_ulogic;
  signal rclk0b_high, rclk90b_high, rclk270b_high : std_ulogic;
  signal rclk0_high, rclk90_high, rclk270_high : std_ulogic;
  signal locked, vlockl, dllfb               : std_ulogic;

  signal ddr_dqin                            : std_logic_vector (dbits-1 downto 0);      -- ddr data
  signal ddr_dqout                           : std_logic_vector (dbits-1 downto 0);      -- ddr data
  signal ddr_dqoen                           : std_logic_vector (dbits-1 downto 0);      -- ddr data
  signal ddr_adr                             : std_logic_vector (13 downto 0);           -- ddr row address
  signal ddr_bar                             : std_logic_vector (1+eightbanks downto 0); -- ddr bank address
  signal ddr_dmr                             : std_logic_vector (dbits/8-1 downto 0);    -- ddr mask
  signal ddr_dqsin                           : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
  signal ddr_dqsoen                          : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
  signal ddr_dqsoutl                         : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
  signal dqinl                               : std_logic_vector (dbits*2-1 downto 0);    -- ddr data
  signal dllrst                              : std_logic_vector(0 to 3);
  signal dll0rst                             : std_ulogic;
  signal dll1rst                             : std_ulogic;
  signal mlock, mclkfb, mclk, mclkfx, mclk0  : std_ulogic;
  signal odtl                                : std_logic_vector(1 downto 0);

  --signals needed for alignment with DQS
  signal dm_delay                            : std_logic_vector (dbits/8-1 downto 0);      
  signal dqout_delay                         : std_logic_vector (dbits-1 downto 0);

  constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

  attribute keep                   : boolean;
  attribute syn_keep               : boolean;
  attribute syn_preserve           : boolean;
  attribute syn_keep of dqsn       : signal is true;
  attribute syn_preserve of dqsn   : signal is true;
  attribute keep of mclkfx         : signal is true;
  attribute keep of clk_90ro       : signal is true;
  attribute syn_keep of mclkfx     : signal is true;
  attribute syn_keep of clk_90ro   : signal is true;

  -- To prevent synplify 9.4 to remove any of these registers.
  attribute syn_noprune : boolean;
  attribute syn_noprune of FD : component is true;
  attribute syn_noprune of IDDR2 : component is true;
  attribute syn_noprune of ODDR2 : component is true;

begin

  oe <= not oen;
  vcc <= '1'; gnd <= '0';
  
  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    mlock <= '1';
    mbufg0 : BUFG port map (I => clk, O => mclk);
  end generate;

  clkscale : if clk_mul /= clk_div generate
    rstdel : process (clk, rst)
    begin
      if rst = '0' then
        dll0rst <= '1';
      elsif rising_edge(clk) then
        dll0rst <= '0';
      end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0,  O => mclkfb);

    dllm : DCM
      generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div)
      port map (CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
                PSEN => gnd, PSINCDEC => gnd, RST => dll0rst, CLK0 => mclk0,
                LOCKED => mlock, CLKFX => mclkfx );
  end generate;

  -- DDR clock generation (90 degrees phase-shifted DLL)

  bufg2 : BUFG port map (I => clk_90ro, O => clk90r);
  dllfb <= clk90r;

  dll : DCM
    generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2, 
                 CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => 64)
    port map (CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
              PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_90ro,
              CLK90 => open, CLK180 => open, CLK270 => open,
              LOCKED => lockl);

  clk0r   <= mclk;
  clk180r <= not mclk;
  clk270r <= not clk90r;
  clkout  <= mclk;
  
  rstdel : process (mclk, rst, mlock)
  begin
    if rst = '0' or mlock = '0' then
      dllrst <= (others => '1');
    elsif rising_edge(mclk) then
      dllrst <= dllrst(1 to 3) & '0';
    end if;
  end process;

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk0r)
      variable cnt : std_logic_vector(15 downto 0);
      variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
          cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16);
          vlock := '0';
        elsif vlock = '0' then
          cnt := cnt -1;
          vlock := cnt(15) and not co;
        end if;
      end if;
      if lockl = '0' then
        vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock   <= locked;

  -- Generate external DDR clock
  ddrclocks : for i in 0 to 2 generate
    dclk0r : ODDR2
      port map (Q => ddr_clkl(i), C0 => clk90r, C1 => clk270r, CE => vcc,
                D0 => vcc, D1 => gnd, R => gnd, S => gnd);
    ddrclk_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_clk(i), ddr_clkl(i));

    dclk0rb : ODDR2
      port map (Q => ddr_clkbl(i), C0 => clk90r, C1 => clk270r, CE => vcc,
                D0 => gnd, D1 => vcc, R => gnd, S => gnd);
    ddrclkb_pad : outpad
      generic map (tech => virtex4, level => sstl18_i)
      port map (ddr_clkb(i), ddr_clkbl(i));
  end generate;

  -- Generate the DDR clock to be fed back for DQ synchronization
  dclkfb0r : ODDR2
    port map (Q => ddr_clk_fb_outl, C0 => clk90r, C1 => clk270r, CE => vcc,
              D0 => vcc, D1 => gnd, R => gnd, S => gnd);
  ddrclkfb_pad : outpad
    generic map (tech => virtex4, level => sstl18_i) 
    port map (ddr_clk_fb_out, ddr_clk_fb_outl);

  -- The above clock fed back for DQ synchronization
  ddrref_pad : clkpad generic map (tech => virtex4) 
	port map (ddr_clk_fb, ddr_clk_fbl); 
  
  -- ODT pads
  odtgen : for i in 0 to 1 generate
    odtl(i) <= locked and odt(i);
    ddr_odt_pad : outpad
      generic map (tech => virtex4, level => sstl18_i)
      port map (ddr_odt(i), odtl(i));
  end generate;

  --  DDR single-edge control signals
  ddrbanks : for i in 0 to 1 generate
    csn0gen : FD
      port map ( Q => ddr_csnr(i), C => clk0r, D => csn(i));
    csn0_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_csb(i), ddr_csnr(i));

    ckel(i) <= cke(i) and locked;
    ckegen : FD
      port map ( Q => ddr_ckenr(i), C => clk0r, D => ckel(i));
    cke_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_cke(i), ddr_ckenr(i));
  end generate;

  rasgen : FD
    port map ( Q => ddr_rasnr, C => clk0r, D => rasn);
  rasn_pad : outpad
    generic map (tech => virtex4, level => sstl18_i) 
    port map (ddr_rasb, ddr_rasnr);

  casgen : FD
    port map ( Q => ddr_casnr, C => clk0r, D => casn);
  casn_pad : outpad
    generic map (tech => virtex4, level => sstl18_i) 
    port map (ddr_casb, ddr_casnr);

  wengen : FD
    port map ( Q => ddr_wenr, C => clk0r, D => wen);
  wen_pad : outpad
    generic map (tech => virtex4, level => sstl18_i) 
    port map (ddr_web, ddr_wenr);

  bagen : for i in 0 to 1+eightbanks generate
    ba0 : FD
      port map ( Q => ddr_bar(i), C => clk0r, D => ba(i));
    ddr_ba_pad  : outpad
      generic map (tech => virtex4, level => sstl18_i)
      port map (ddr_ba(i), ddr_bar(i));
  end generate;

  addrgen : for i in 0 to 13 generate
    addr0 : FD
      port map ( Q => ddr_adr(i), C => clk0r, D => addr(i));
    ddr_ad_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_ad(i), ddr_adr(i));
  end generate;

  -- Data mask (DM) generation
  dmgen : for i in 0 to dbits/8-1 generate
    dq_delay : FD
      port map ( Q => dm_delay(i), C => clk0r, D => dm(i));
    dm0 : ODDR2
      generic map (DDR_ALIGNMENT => "NONE")
      port map (Q => ddr_dmr(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                D0 => dm(i+dbits/8), D1 => dm_delay(i), R => gnd, S => gnd);
    ddr_bm_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  -- Data strobe (DQS) generation
  dqsgen : for i in 0 to dbits/8-1 generate
    dsqreg : FD port map ( Q => dqsn(i), C => clk180r, D => oe);
    da0 : ODDR2
      port map ( Q => ddr_dqsin(i), C0 => clk90r, C1 => clk270r, CE => vcc,
                 D0 => dqsn(i), D1 => gnd, R => gnd, S => gnd);
    doen : FD
      port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);

    dqs_pad : iopad_ds
      generic map (tech => virtex5, level => sstl18_ii)
      port map (padp => ddr_dqs(i), padn => ddr_dqsn(i), i => ddr_dqsin(i), 
                en => ddr_dqsoen(i), o => ddr_dqsoutl(i));
  end generate;

  -- Phase shift the feedback clock and use it to latch DQ
  rstphase : process (ddr_clk_fbl, rst, lockl)
  begin
    if rst = '0' or lockl = '0' then
      dll1rst <= '1';
    elsif rising_edge(ddr_clk_fbl) then
      dll1rst <= '0';
    end if;
  end process;

  bufg7 : BUFG port map (I => rclk90,  O => rclk90b);
--  bufg8 : BUFG port map (I => rclk270, O => rclk270b);
  rclk270b <= not rclk90b;
  bufg9 : BUFG port map (I => rclk180, O => rclk180b);

  read_dll : DCM
    generic map (clkin_period => 8.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", 
                 CLKOUT_PHASE_SHIFT => "VARIABLE", PHASE_SHIFT => rskew)
    port map ( CLKIN => ddr_clk_fbl, CLKFB => rclk90b, DSSEN => gnd, PSCLK => mclk,
               PSEN => cal_pll(0), PSINCDEC => cal_pll(1), RST => dll1rst, CLK0 => rclk90,
               CLK90 => rclk180); --, CLK180 => rclk270);
  
  -- Data bus
  ddgen : for i in 0 to dbits-1 generate
    qi : IDDR2
      port map (Q0 => dqinl(i+dbits), -- 1-bit output for positive edge of C0
                Q1 => dqinl(i),       -- 1-bit output for negative edge of C1
                C0 => rclk90b,        -- 1-bit clock input 
                C1 => rclk270b,       -- 1-bit clock input 
                CE => vcc,            -- 1-bit clock enable input 
                D  => ddr_dqin(i),    -- 1-bit DDR data input 
                R  => gnd,            -- 1-bit reset 
                S  => gnd);           -- 1-bit set 

    dinq0 : FD
      port map ( Q => dqin(i+dbits), C => rclk180b, D => dqinl(i));
    dinq1 : FD
      port map ( Q => dqin(i), C => rclk180b, D => dqinl(i+dbits));

    dq_delay : FD
      port map ( Q => dqout_delay(i), C => clk0r, D => dqout(i));
    
    dout : ODDR2
      generic map (DDR_ALIGNMENT => "NONE")
      port map (Q => ddr_dqout(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                D0 => dqout(i+dbits), D1 => dqout_delay(i), R => gnd, S => gnd);
    doen : FD
      port map (Q => ddr_dqoen(i), C => clk0r, D => oen);

    dq_pad : iopad
      generic map (tech => virtex4, level => sstl18_ii)
      port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => ddr_dqin(i));
  end generate;
end;

------------------------------------------------------------------
-- Spartan 6 DDR2 PHY  -------------------------------------------
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
-- pragma translate_off
library unisim;
use unisim.vcomponents.BUFG;
use unisim.vcomponents.DCM_SP;
use unisim.vcomponents.IDDR2;
use unisim.vcomponents.ODDR2;
use unisim.vcomponents.FD;
use unisim.vcomponents.IODELAY2;
-- pragma translate_on

use work.gencomp.all;

entity spartan6_ddr2_phy_wo_pads is
  generic (MHz         : integer := 125; rstdelay   : integer := 200;
           dbits       : integer := 16;  clk_mul    : integer := 2;
           clk_div     : integer := 2;   tech       : integer := spartan6;
           rskew       : integer := 0;   eightbanks : integer range 0 to 1 := 0;
           abits       : integer := 14;
           nclk        : integer := 3;   ncs        : integer := 2 );
  port (   rst         : in  std_ulogic;
           clk         : in  std_logic;        -- input clock
           clkout      : out std_ulogic;       -- DDR clock
           lock        : out std_ulogic;       -- DCM locked

           ddr_clk     : out std_logic_vector(nclk-1 downto 0);
           ddr_cke     : out std_logic_vector(ncs-1 downto 0);
           ddr_csb     : out std_logic_vector(ncs-1 downto 0);
           ddr_web     : out std_ulogic;                               -- ddr write enable
           ddr_rasb    : out std_ulogic;                               -- ddr ras
           ddr_casb    : out std_ulogic;                               -- ddr cas
           ddr_dm      : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
           ddr_dqs_in  : in  std_logic_vector (dbits/8-1 downto 0);
           ddr_dqs_out : out std_logic_vector (dbits/8-1 downto 0);
           ddr_dqs_oen : out std_logic_vector (dbits/8-1 downto 0);
           ddr_ad      : out std_logic_vector (abits-1 downto 0);      -- ddr address
           ddr_ba      : out std_logic_vector (1+eightbanks downto 0); -- ddr bank address
           ddr_dq_in   : in  std_logic_vector (dbits-1 downto 0);   -- ddr data
           ddr_dq_out  : out std_logic_vector (dbits-1 downto 0);   -- ddr data
           ddr_dq_oen  : out std_logic_vector (dbits-1 downto 0);   -- ddr data
           ddr_odt     : out std_logic_vector(ncs-1 downto 0);

           addr        : in  std_logic_vector (abits-1 downto 0);      -- row address
           ba          : in  std_logic_vector ( 2 downto 0);           -- bank address
           dqin        : out std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
           dqout       : in  std_logic_vector (dbits*2-1 downto 0);    -- ddr output data
           dm          : in  std_logic_vector (dbits/4-1 downto 0);    -- data mask
           oen         : in  std_ulogic;
           dqs         : in  std_ulogic;
           dqsoen      : in  std_ulogic;
           rasn        : in  std_ulogic;
           casn        : in  std_ulogic;
           wen         : in  std_ulogic;
           csn         : in  std_logic_vector(ncs-1 downto 0);
           cke         : in  std_logic_vector(ncs-1 downto 0);
           cal_en      : in  std_logic_vector(dbits/8-1 downto 0);
           cal_inc     : in  std_logic_vector(dbits/8-1 downto 0);
           cal_rst     : in  std_logic;
           odt         : in  std_logic_vector(ncs-1 downto 0));
end;

architecture rtl of spartan6_ddr2_phy_wo_pads is

  component DCM_SP is
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false );
    port (
      CLK0 : out std_ulogic;
      CLK180 : out std_ulogic;
      CLK270 : out std_ulogic;
      CLK2X : out std_ulogic;
      CLK2X180 : out std_ulogic;
      CLK90 : out std_ulogic;
      CLKDV : out std_ulogic;
      CLKFX : out std_ulogic;
      CLKFX180 : out std_ulogic;
      LOCKED : out std_ulogic;
      PSDONE : out std_ulogic;
      STATUS : out std_logic_vector(7 downto 0);
      CLKFB : in std_ulogic;
      CLKIN : in std_ulogic;
      DSSEN : in std_ulogic;
      PSCLK : in std_ulogic;
      PSEN : in std_ulogic;
      PSINCDEC : in std_ulogic;
      RST : in std_ulogic );
  end component;

  component BUFG
    port (O : out std_logic;
          I : in std_logic);
  end component;

  component ODDR2
    generic (DDR_ALIGNMENT : string := "NONE"; -- Sets output alignment to "NONE", "C0" or "C1"
             INIT : bit := '0';                -- Sets initial state of the Q0  
             SRTYPE : string := "SYNC");       -- Specifies "SYNC" or "ASYNC" set/reset
    port (   Q  : out std_ulogic;              -- 1-bit DDR output data
             C0 : in  std_ulogic;              -- 1-bit clock input
             C1 : in  std_ulogic;              -- 1-bit clock input
             CE : in  std_ulogic;              -- 1-bit clock enable input
             D0 : in  std_ulogic;              -- 1-bit data input (associated with C1)
             D1 : in  std_ulogic;              -- 1-bit data input (associated with C1)
             R  : in  std_ulogic;              -- 1-bit reset input
             S  : in  std_ulogic);             -- 1-bit set input
  end component;

  component FD
    generic (INIT : bit := '0');
    port (   Q : out std_ulogic;
             C : in std_ulogic;
             D : in std_ulogic);
  end component;

  component IDDR2
    generic (DDR_ALIGNMENT : string := "NONE"; -- Sets output alignment to "NONE", "C0" or "C1"
             INIT_Q0 : bit := '0';             -- Sets initial state of the Q0
             INIT_Q1 : bit := '0';             -- Sets initial state of the Q1
             SRTYPE  : string := "SYNC");      -- Specifies "SYNC" or "ASYNC" set/reset
    port (   Q0 : out std_ulogic;              -- 1-bit output captured with C0 clock
             Q1 : out std_ulogic;              -- 1-bit output captured with C1 clock
             C0 : in  std_ulogic;              -- 1-bit clock input
             C1 : in  std_ulogic;              -- 1-bit clock input
             CE : in  std_ulogic;              -- 1-bit clock enable input
             D  : in  std_ulogic;              -- 1-bit DDR data input
             R  : in  std_ulogic;              -- 1-bit reset input
             S  : in  std_ulogic);             -- 1-bit set input
  end component;

  component IODELAY2 is
    generic (
      COUNTER_WRAPAROUND : string := "WRAPAROUND";
      DATA_RATE : string := "SDR";
      DELAY_SRC : string := "IO";
      IDELAY2_VALUE : integer := 0;
      IDELAY_MODE : string := "NORMAL";
      IDELAY_TYPE : string := "DEFAULT";
      IDELAY_VALUE : integer := 0;
      ODELAY_VALUE : integer := 0;
      SERDES_MODE : string := "NONE";
      SIM_TAPDELAY_VALUE : integer := 75 );
    port (
      BUSY                 : out std_ulogic;
      DATAOUT              : out std_ulogic;
      DATAOUT2             : out std_ulogic;
      DOUT                 : out std_ulogic;
      TOUT                 : out std_ulogic;
      CAL                  : in std_ulogic;
      CE                   : in std_ulogic;
      CLK                  : in std_ulogic;
      IDATAIN              : in std_ulogic;
      INC                  : in std_ulogic;
      IOCLK0               : in std_ulogic;
      IOCLK1               : in std_ulogic;
      ODATAIN              : in std_ulogic;
      RST                  : in std_ulogic;
      T                    : in std_ulogic );
  end component;

  signal vcc, gnd, oe, lockl : std_ulogic;
  signal dqsn                : std_logic_vector(dbits/8-1 downto 0);
  signal dqsoen_reg          : std_logic_vector(dbits/8-1 downto 0);
  signal ddr_dq_indel        : std_logic_vector(dbits-1 downto 0);
  signal ckel                : std_logic_vector(ncs-1 downto 0);
  signal clk_90ro                            : std_ulogic;
  signal clk0r, clk90r, clk180r, clk270r     : std_ulogic;
  signal locked, vlockl, dllfb               : std_ulogic;

  signal dllrst                              : std_logic_vector(0 to 3);
  signal dll0rst                             : std_logic_vector(0 to 3);
  signal mlock, mclkfb, mclk, mclkfx, mclk0  : std_ulogic;

  signal delay_cal                           : std_ulogic;
  signal dcal_started                        : std_ulogic;

  constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

  attribute keep                   : boolean;
  attribute syn_keep               : boolean;
  attribute syn_preserve           : boolean;
  attribute syn_keep of dqsn       : signal is true;
  attribute syn_preserve of dqsn   : signal is true;
  attribute keep of mclkfx         : signal is true;
  attribute keep of clk_90ro       : signal is true;
  attribute syn_keep of mclkfx     : signal is true;
  attribute syn_keep of clk_90ro   : signal is true;

  -- To prevent synplify 9.4 to remove any of these registers.
  attribute syn_noprune : boolean;
  attribute syn_noprune of FD : component is true;
  attribute syn_noprune of IDDR2 : component is true;
  attribute syn_noprune of ODDR2 : component is true;

begin

  oe <= not oen;
  vcc <= '1'; gnd <= '0';

  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    mlock <= '1';
    mclk <= clk;
    -- mbufg0 : BUFG port map (I => clk, O => mclk);
  end generate;

  clkscale : if clk_mul /= clk_div generate

    -- Extend DCM reset signal.
    dll0rstdel : process (clk, rst)
    begin
      if rst = '0' then
        dll0rst <= (others => '1');
      elsif rising_edge(clk) then
        dll0rst <= dll0rst(1 to 3) & "0";
      end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0,  O => mclkfb);

    dllm : DCM_SP
      generic map (
        CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div,
        CLK_FEEDBACK => "1X", CLKIN_PERIOD => 1000.0/real(MHz) )
      port map (CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
                PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
                LOCKED => mlock, CLKFX => mclkfx );
  end generate;

  -- DDR clock generation (90 degrees phase-shifted DLL)

  bufg2 : BUFG port map (I => clk_90ro, O => clk90r);
  dllfb <= clk90r;

  dll : DCM_SP
    generic map ( CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2, 
                  CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => 64 )
    port map (CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
              PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_90ro,
              CLK90 => open, CLK180 => open, CLK270 => open,
              LOCKED => lockl);

  clk0r   <= mclk;
  clk180r <= not mclk;
  clk270r <= not clk90r;
  clkout  <= mclk;

  -- Extend DCM reset signal.
  dllrstdel : process (mclk, rst, mlock)
  begin
    if rst = '0' or mlock = '0' then
      dllrst <= (others => '1');
    elsif rising_edge(mclk) then
      dllrst <= dllrst(1 to 3) & "0";
    end if;
  end process;

  -- Delay lock signal.
  rdel : if rstdelay /= 0 generate
    rcnt : process (clk0r)
      variable cnt : std_logic_vector(15 downto 0);
      variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
          cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16);
          vlock := '0';
        elsif vlock = '0' then
          cnt := cnt -1;
          vlock := cnt(15) and not co;
        end if;
      end if;
      if lockl = '0' then
        vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock   <= locked;

  -- Generate external DDR clock
  ddrclocks : for i in 0 to nclk-1 generate
    dclk0r : ODDR2
      port map ( Q => ddr_clk(i), C0 => clk90r, C1 => clk270r, CE => vcc,
                 D0 => vcc, D1 => gnd, R => gnd, S => gnd );
  end generate;

  --  DDR single-edge control signals
  ddrbanks : for i in 0 to ncs-1 generate

    ddr_odt(i) <= locked and odt(i);

    csn0gen : ODDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
      port map ( Q => ddr_csb(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                 D0 => csn(i), D1 => csn(i), R => gnd, S => gnd );

    ckel(i) <= cke(i) and locked;
    ckegen : ODDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC"  )
      port map ( Q => ddr_cke(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                 D0 => ckel(i), D1 => ckel(i), R => gnd, S => gnd );
  end generate;

  rasgen : ODDR2
    generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC"  )
    port map ( Q => ddr_rasb, C0 => clk0r, C1 => clk180r, CE => vcc,
               D0 => rasn, D1 => rasn, R => gnd, S => gnd );

  casgen : ODDR2
    generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
    port map ( Q => ddr_casb, C0 => clk0r, C1 => clk180r, CE => vcc,
               D0 => casn, D1 => casn, R => gnd, S => gnd );

  wengen : ODDR2
    generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
    port map ( Q => ddr_web, C0 => clk0r, C1 => clk180r, CE => vcc,
               D0 => wen, D1 => wen, R => gnd, S => gnd );

  bagen : for i in 0 to 1+eightbanks generate
    ba0 : ODDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
      port map ( Q => ddr_ba(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                 D0 => ba(i), D1 => ba(i), R => gnd, S => gnd );
  end generate;

  addrgen : for i in 0 to abits-1 generate
    addr0 : ODDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
      port map ( Q => ddr_ad(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                 D0 => addr(i), D1 => addr(i), R => gnd, S => gnd );
  end generate;

  -- Data mask (DM) generation
  dmgen : for i in 0 to dbits/8-1 generate
    dmgen0 : ODDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
      port map ( Q => ddr_dm(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                 D0 => dm(i+dbits/8), D1 => dm(i), R => gnd, S => gnd );
  end generate;

  -- Data strobe (DQS) generation
  dqsgen : for i in 0 to dbits/8-1 generate

    dqsreg : FD
      port map ( Q => dqsn(i), C => clk180r, D => oe );
    dqsgen0 : ODDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
      port map ( Q => ddr_dqs_out(i), C0 => clk90r, C1 => clk270r, CE => vcc,
                 D0 => dqsn(i), D1 => gnd, R => gnd, S => gnd );

    doenreg : FD
      port map ( Q => dqsoen_reg(i), C => clk180r, D => dqsoen );
    doen0 : ODDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
      port map ( Q => ddr_dqs_oen(i), C0 => clk90r, C1 => clk270r, CE => vcc,
                 D0 => dqsoen_reg(i), D1 => dqsoen_reg(i), R => gnd, S => gnd );
  end generate;

  -- Data bus
  ddgen : for i in 0 to dbits-1 generate

    dqdelay : IODELAY2
      generic map ( DATA_RATE => "DDR", DELAY_SRC => "IDATAIN",
                    IDELAY_TYPE => "VARIABLE_FROM_ZERO" )
      port map ( BUSY => open, CAL => delay_cal, CE => cal_en(i/8), CLK => clk0r,
                 DATAOUT => ddr_dq_indel(i), DATAOUT2 => open, DOUT => open,
                 IDATAIN => ddr_dq_in(i), INC => cal_inc(i/8),
                 IOCLK0 => clk0r, IOCLK1 => clk180r,
                 ODATAIN => gnd, RST => cal_rst, T => vcc, TOUT => open );

    din : IDDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
      port map ( D => ddr_dq_indel(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                 R => gnd, S => gnd, Q0 => dqin(i), Q1 => dqin(i+dbits) );

    dout : ODDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
      port map ( Q => ddr_dq_out(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                 D0 => dqout(i+dbits), D1 => dqout(i), R => gnd, S => gnd );

    doen : ODDR2
      generic map ( DDR_ALIGNMENT => "C0", SRTYPE => "ASYNC" )
      port map ( Q => ddr_dq_oen(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                 D0 => oen, D1 => oen, R => gnd, S => gnd );
  end generate;

  -- Generate IODELAY calibration command after core reset.
  calcmd : process (mclk, rst)
  begin
    if rst = '0' then
      dcal_started <= '0';
      delay_cal    <= '0';
    elsif rising_edge(mclk) then
      if mlock = '1' then
        dcal_started <= '1';
        delay_cal    <= not dcal_started;
      end if;
    end if;
  end process;

end architecture;

