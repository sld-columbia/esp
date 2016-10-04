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
-- Entity:      generic_ddr_phy
-- File:        ddr_phy_inferred.vhd
-- Author:      Nils-Johan Wessman - Gaisler Research
-- Modified:    Magnus Hjorth - Aeroflex Gaisler
-- Description: Generic DDR PHY (simulation only)
------------------------------------------------------------------------------


--###################################################################################
-- Generic DDR1 PHY
--###################################################################################
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.stdlib.all;

entity generic_ddr_phy_wo_pads is
  generic (MHz : integer := 100; rstdelay : integer := 200;
    dbits : integer := 16; clk_mul : integer := 2 ;
    clk_div : integer := 2; rskew : integer := 0; mobile : integer := 0;
           abits: integer := 14; nclk: integer := 3; ncs: integer := 2);
  port(
    rst       : in  std_ulogic;
    clk       : in  std_logic;  -- input clock
    clkout    : out std_ulogic; -- system clock
    clk0r     : in  std_ulogic;
    lock      : out std_ulogic; -- DCM locked

    ddr_clk   : out std_logic_vector(nclk-1 downto 0);
    ddr_clkb  : out std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb: in std_logic;
    ddr_cke   : out std_logic_vector(ncs-1 downto 0);
    ddr_csb   : out std_logic_vector(ncs-1 downto 0);
    ddr_web   : out std_ulogic;                       -- ddr write enable
    ddr_rasb  : out std_ulogic;                       -- ddr ras
    ddr_casb  : out std_ulogic;                       -- ddr cas
    ddr_dm    : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in  : in std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad    : out std_logic_vector (abits-1 downto 0);   -- ddr address
    ddr_ba    : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq_in   : in  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dq_out  : out  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dq_oen  : out  std_logic_vector (dbits-1 downto 0); -- ddr data

    addr      : in  std_logic_vector (abits-1 downto 0); -- data mask
    ba        : in  std_logic_vector ( 1 downto 0); -- data mask
    dqin      : out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout     : in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm        : in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       : in  std_ulogic;
    dqs       : in  std_ulogic;
    dqsoen    : in  std_ulogic;
    rasn      : in  std_ulogic;
    casn      : in  std_ulogic;
    wen       : in  std_ulogic;
    csn       : in  std_logic_vector(ncs-1 downto 0);
    cke       : in  std_logic_vector(ncs-1 downto 0);
    ck        : in  std_logic_vector(nclk-1 downto 0);
    moben     : in  std_logic -- Mobile DDR enable
      );
end;

architecture rtl of generic_ddr_phy_wo_pads is

component sim_pll
  generic (
    clkmul: integer := 1;
    clkdiv1: integer := 1;
    clkphase1: integer := 0;
    clkdiv2: integer := 1;
    clkphase2: integer := 0;
    clkdiv3: integer := 1;
    clkphase3: integer := 0;
    clkdiv4: integer := 1;
    clkphase4: integer := 0;
    minfreq: integer := 0;
    maxfreq: integer := 10000000
    );
  port (
    i: in std_logic;
    o1: out std_logic;
    o2: out std_logic;
    o3: out std_logic;
    o4: out std_logic;
    lock: out std_logic;
    rst: in std_logic
    );
end component;

constant freq_khz: integer := (1000*MHz*clk_mul)/(clk_div);
constant freq_mhz: integer := freq_khz / 1000;
constant td90: time := 250 us * (1.0 / real(freq_khz));

signal vcc, gnd : std_logic;                                    -- VCC and GND
signal clk0, clk90r, clk180r, clk270r : std_ulogic;
signal lockl,vlockl,locked: std_ulogic;
signal dqs90,dqs90n: std_logic_vector(dbits/8-1 downto 0);

signal ckl: std_logic_vector(nclk-1 downto 0);
signal ckel: std_logic_vector(ncs-1 downto 0);

begin
  vcc <= '1'; gnd <= '0';

  -----------------------------------------------------------------------------------
  -- Clock generation (Only for simulation)
  -----------------------------------------------------------------------------------
  -- Phase shifted clocks  
--pragma translate_off
  -- To avoid jitter problems when using ddr without sync regs we shift
  -- 10 degrees extra.
  pll0: sim_pll
    generic map (
      clkmul => clk_mul,
      clkdiv1 => clk_div,
      clkphase1 => 0-10+360,
      clkdiv2 => clk_div,
      clkphase2 => 90-10,
      clkdiv3 => clk_div,
      clkphase3 => 180-10,
      clkdiv4 => clk_div,
      clkphase4 => 270-10,
      minfreq => MHz*1000,
      maxfreq => MHz*1000
      )
    port map (
      i => clk,
      o1 => clk0,
      o2 => clk90r,
      o3 => clk180r,
      o4 => clk270r,
      lock => lockl,
      rst => rst);
--pragma translate_on

  -- Clock to DDR controller
  clkout <= clk0;

  ddr_clk_fb_out <= '0';
  
  -----------------------------------------------------------------------------------
  -- Lock delay
  -----------------------------------------------------------------------------------

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk0r, lockl, rst)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
          cnt := conv_std_logic_vector(rstdelay*FREQ_MHZ, 16); vlock := '0';
        else
          if vlock = '0' then
            cnt := cnt -1;  vlock := cnt(15) and not co;
          end if;
        end if;
      end if;
      if lockl = '0' or rst='0' then
        vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock <= locked;

  -----------------------------------------------------------------------------
  -- DQS shifting
  -----------------------------------------------------------------------------
-- pragma translate_off
  dqs90 <= transport ddr_dqs_in after td90;
  dqs90n <= not dqs90;
-- pragma translate_on
  
  -----------------------------------------------------------------------------
  -- Data path
  -----------------------------------------------------------------------------

  -- For mobile SDRAM, force Cke high during reset and reset-delay,
  -- For regular SDRAM, force Cke low
  -- also disable outgoing clock until we have achieved PLL lock
  mobgen: if mobile > 1 generate
    ckel <= cke or (cke'range => not locked);
  end generate;
  nmobgen: if mobile < 2 generate
    ckel <= cke and (cke'range => locked);    
  end generate;
  ckl <= ck and (ck'range => lockl);
  
  dp0: ddrphy_datapath
    generic map (
      regtech => inferred, dbits => dbits, abits => abits,
      bankbits => 2, ncs => ncs, nclk => nclk,
      resync => 2 )
    port map (
      clk0 => clk0r,
      clk90 => clk90r,
      clk180 => clk180r,
      clk270 => clk270r,
      clkresync => gnd,
      ddr_clk => ddr_clk,
      ddr_clkb => ddr_clkb,
      ddr_dq_in => ddr_dq_in,
      ddr_dq_out => ddr_dq_out,
      ddr_dq_oen => ddr_dq_oen,
      ddr_dqs_in90 => dqs90,
      ddr_dqs_in90n => dqs90n,
      ddr_dqs_out => ddr_dqs_out,
      ddr_dqs_oen => ddr_dqs_oen,
      ddr_cke => ddr_cke,
      ddr_csb => ddr_csb,
      ddr_web => ddr_web,
      ddr_rasb => ddr_rasb,
      ddr_casb => ddr_casb,
      ddr_ad => ddr_ad,
      ddr_ba => ddr_ba,
      ddr_dm => ddr_dm,
      ddr_odt => open,
      dqin => dqin,
      dqout => dqout,
      addr => addr,
      ba => ba,
      dm => dm,
      oen => oen,
      rasn => rasn,
      casn => casn,
      wen => wen,
      csn => csn,
      cke => ckel,
      odt => (others => '0'),
      dqs_en => dqs,
      dqs_oen => dqsoen,
      ddrclk_en => ckl
      );

end;


--###################################################################################
-- Generic DDR2 PHY
--###################################################################################

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.stdlib.all;

entity generic_ddr2_phy_wo_pads is
  generic (MHz : integer := 100; rstdelay : integer := 200;
    dbits : integer := 16; clk_mul : integer := 2 ;
    clk_div : integer := 2; rskew : integer := 0;
           eightbanks: integer := 0; abits: integer := 14;
           cben: integer := 0; chkbits: integer := 8;
           nclk: integer := 3; ncs: integer := 2);
  port(
    rst         : in  std_ulogic;
    clk         : in  std_logic;  -- input clock
    clkout      : out std_ulogic; -- system clock
    clk0r       : in  std_ulogic; -- system clock returned
    lock        : out std_ulogic; -- DCM locked

    ddr_clk     : out std_logic_vector(nclk-1 downto 0);
    ddr_clkb    : out std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke     : out std_logic_vector(ncs-1 downto 0);
    ddr_csb     : out std_logic_vector(ncs-1 downto 0);
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
    ddr_odt     : out std_logic_vector(ncs-1 downto 0);  -- ddr odt

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
    csn         : in  std_logic_vector(ncs-1 downto 0);
    cke         : in  std_logic_vector(ncs-1 downto 0);
    ck          : in  std_logic_vector(2 downto 0);
    odt         : in  std_logic_vector(1 downto 0)
    );
end;

architecture rtl of generic_ddr2_phy_wo_pads is

component sim_pll
  generic (
    clkmul: integer := 1;
    clkdiv1: integer := 1;
    clkphase1: integer := 0;
    clkdiv2: integer := 1;
    clkphase2: integer := 0;
    clkdiv3: integer := 1;
    clkphase3: integer := 0;
    clkdiv4: integer := 1;
    clkphase4: integer := 0;
    minfreq: integer := 0;
    maxfreq: integer := 10000000
    );
  port (
    i: in std_logic;
    o1: out std_logic;
    o2: out std_logic;
    o3: out std_logic;
    o4: out std_logic;
    lock: out std_logic;
    rst: in std_logic
    );
end component;

constant freq_khz: integer := (1000*MHz*clk_mul)/(clk_div);
constant freq_mhz: integer := freq_khz / 1000;
constant td90: time := 250 us * (1.0 / real(freq_khz));

signal vcc, gnd : std_logic;                                    -- VCC and GND
signal clk0, clk90r, clk180r, clk270r : std_ulogic;
signal lockl,vlockl,locked: std_ulogic;
signal dqs90,dqs90n: std_logic_vector(dbits/8-1 downto 0);

begin
  vcc <= '1'; gnd <= '0';

  -----------------------------------------------------------------------------------
  -- Clock generation (Only for simulation)
  -----------------------------------------------------------------------------------
  -- Phase shifted clocks
--pragma translate_off
  -- To avoid jitter problems when using ddr2 without sync regs we shift
  -- 10 degrees extra.
  pll0: sim_pll
    generic map (
      clkmul => clk_mul,
      clkdiv1 => clk_div,
      clkphase1 => 0-10+360,
      clkdiv2 => clk_div,
      clkphase2 => 90-10,
      clkdiv3 => clk_div,
      clkphase3 => 180-10,
      clkdiv4 => clk_div,
      clkphase4 => 270-10,
      minfreq => MHz*1000,
      maxfreq => MHz*1000
      )
    port map (
      i => clk,
      o1 => clk0,
      o2 => clk90r,
      o3 => clk180r,
      o4 => clk270r,
      lock => lockl,
      rst => rst);
--pragma translate_on
  
  -- Clock to DDR controller
  clkout <= clk0;

  ddr_clk_fb_out <= '0';
  
  -----------------------------------------------------------------------------------
  -- Lock delay
  -----------------------------------------------------------------------------------

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk0r, lockl)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
          cnt := conv_std_logic_vector(rstdelay*FREQ_MHZ, 16); vlock := '0';
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

  -----------------------------------------------------------------------------
  -- DQS shifting
  -----------------------------------------------------------------------------
-- pragma translate_off
  dqs90 <= transport ddr_dqs_in after td90;  
  dqs90n <= not dqs90;
-- pragma translate_on
  
  -----------------------------------------------------------------------------
  -- Data path
  -----------------------------------------------------------------------------
  dp0: ddrphy_datapath
    generic map (
      regtech => inferred, dbits => dbits, abits => abits,
      bankbits => 2+EIGHTBANKS, ncs => ncs, nclk => nclk,
      resync => 0 )
    port map (
      clk0 => clk0r,
      clk90 => clk90r,
      clk180 => clk180r,
      clk270 => clk270r,
      clkresync => gnd,
      ddr_clk => ddr_clk,
      ddr_clkb => ddr_clkb,
      ddr_dq_in => ddr_dq_in,
      ddr_dq_out => ddr_dq_out,
      ddr_dq_oen => ddr_dq_oen,
      ddr_dqs_in90 => dqs90,
      ddr_dqs_in90n => dqs90n,
      ddr_dqs_out => ddr_dqs_out,
      ddr_dqs_oen => ddr_dqs_oen,
      ddr_cke => ddr_cke,
      ddr_csb => ddr_csb,
      ddr_web => ddr_web,
      ddr_rasb => ddr_rasb,
      ddr_casb => ddr_casb,
      ddr_ad => ddr_ad,
      ddr_ba => ddr_ba,
      ddr_dm => ddr_dm,
      ddr_odt => ddr_odt,
      dqin => dqin,
      dqout => dqout,
      addr => addr,
      ba => ba(1+eightbanks downto 0),
      dm => dm,
      oen => oen,
      rasn => rasn,
      casn => casn,
      wen => wen,
      csn => csn,
      cke => cke,
      odt => odt,
      dqs_en => dqs,
      dqs_oen => dqsoen,
      ddrclk_en => ck(nclk-1 downto 0)
      );
  
end;

