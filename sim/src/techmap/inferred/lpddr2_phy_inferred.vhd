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
-- Entity:      generic_lpddr2phy_wo_pads
-- File:        lpddr2_phy_inferred.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Generic LPDDR2/LPDDR3 PHY (simulation only), without pads
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity clkswitch is
  port (clk1,clk2,sel: in std_ulogic;
        clko: out std_ulogic);
end;

architecture sim of clkswitch is
  signal c1en,c2en: std_ulogic := '0';
begin
  clko <= (clk1 and c1en) or (clk2 and c2en);

  p1: process(clk1)
  begin
    if falling_edge(clk1) then
      c1en <= (not sel) and (not c2en);
    end if;
  end process;
  p2: process(clk2)
  begin
    if falling_edge(clk2) then
      c2en <= (sel) and (not c1en);
    end if;
  end process;
end;

library ieee;
use ieee.std_logic_1164.all;

entity generic_lpddr2phy_wo_pads is
  generic (
    tech : integer := 0;
    dbits : integer := 16;
    nclk: integer := 3;
    ncs: integer := 2;
    clkratio: integer := 1;
    scantest: integer := 0;
    oepol: integer := 0);
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
end;

architecture beh of generic_lpddr2phy_wo_pads is

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

  signal extclkb,extclkn,extclk,intclkb,intclkn,intclk: std_ulogic;
  signal gextclk,gextclkn: std_ulogic;
  signal clkoutb,clkoutn: std_ulogic;
  signal llockb,llockn,llock: std_ulogic;
  signal dqsout,dqsoen,dqsand,dqoen,dqsien,dqsiend: std_ulogic;
  signal dqsin,dqsind: std_logic_vector(dbits/8-1 downto 0);

  signal tmeas: time := 0 ns;
  signal tdqsck: time := 0 ns;
begin

  bootpll: sim_pll
    generic map (clkmul => clkratio,
                 clkdiv1 => 1,        clkphase1 => 180,
                 clkdiv2 => 1,        clkphase2 => 90,
                 clkdiv3 => clkratio, clkphase3 => 0)
    port map (i => clkin2, o1 => extclkb, o2 => intclkb,
              o3 => clkoutb, lock => llockb, rst => rst);

  pll0: sim_pll
    generic map (clkmul => clkratio,
                 clkdiv1 => 1,        clkphase1 => 180,
                 clkdiv2 => 1,        clkphase2 => 90,
                 clkdiv3 => clkratio, clkphase3 => 0)
    port map (i => clkin, o1 => extclkn, o2 => intclkn,
              o3 => clkoutn, lock => llockn, rst => rst);

  llock <= llockb and llockn;
  lock <= llock;

  clkout2 <= '0';

  cs0: entity work.clkswitch port map (extclkn, extclkb, boot, extclk);
  cs1: entity work.clkswitch port map (intclkn, intclkb, boot, intclk);
  cs2: entity work.clkswitch port map (clkoutn, clkoutb, boot, clkout);

  gextclk  <= extclk and (llock and not ckstop);
  gextclkn <= not gextclk;

  dqsout <= gextclk and dqsand;

  ddr_dqs_out <= (others => dqsout);
  ddr_dqs_oen <= (others => dqsoen);
  ddr_dqs_oen <= (others => dqsoen or (not rst) or (not llock)) when oepol=0 else
                 (others => (not dqsoen) and rst and llock);
  ddr_dq_oen <= (others => dqoen or (not rst) or (not llock)) when oepol=0 else
                (others => (not dqoen) and rst and llock);
  ddr_clk  <= (others => gextclk);
  ddr_clkb <= (others => gextclkn);
  dqsiend <= dqsien after tdqsck;
  dqsin <= ddr_dqs_in when dqsiend='1' else (others => '0');
  dqsind <= dqsin after tmeas * 0.25;

  wrreq <= wrpend(1+clkratio-1-1 downto 1-1);

  outregs: process(clkoutret,intclk,dqsind)
    variable phase: integer;
    variable wrpend_samp: std_logic_vector(1 downto 0);
    variable rdpend_prev: std_ulogic;
    type intarr is array(natural range <>) of integer;
    variable dl: intarr(dbits/8-1 downto 0) := (others => 0);
    variable dqq: std_logic_vector(3*dbits*2-1 downto 0);
    variable lt: time := 0 ns;
    variable dqsind_prev: std_logic_vector(dbits/8-1 downto 0) := (others => '0');
    variable i: integer;
  begin
    if dqsind /= dqsind_prev then
      for x in dqsind'range loop
        if (dqsind(x)='1' and dqsind_prev(x)='0') or (dqsind(x)='0' and dqsind_prev(x)='1') then
          for y in 5 downto 1 loop
            dqq(x*8+dbits*y+7 downto x*8+dbits*y) := dqq(x*8+dbits*(y-1)+7 downto x*8+dbits*(y-1));
          end loop;
          dqq(x*8+7 downto x*8) := ddr_dq_in(x*8+7 downto x*8);
          if dqsind(x)='0' then
            dl(x) := dl(x)+1;
          end if;
        end if;
      end loop;
      dqsind_prev := dqsind;
    end if;
    if rising_edge(clkoutret) then
      dqsien <= rdpend(1);
      phase := 0;
      wrpend_samp := wrpend(1 downto 0);
      rdvalid <= (others => '0');
      dqin <= (others => '-');
      i := clkratio;
      for x in dl'range loop
        if dl(x)<i then i:=dl(x); end if;
      end loop;
      for x in dl'range loop
        dl(x) := dl(x)-i;
      end loop;
      for x in 2*i-1 downto 0 loop
        for y in dbits/8-1 downto 0 loop
          dqin(x*dbits+y*8+7 downto x*dbits+y*8) <= dqq((x+dl(y))*dbits+y*8+7 downto (x+dl(y))*dbits+y*8);
        end loop;
      end loop;
      rdvalid(i-1 downto 0) <= (others => '1');
    end if;
    if falling_edge(clkoutret) then
      dqsoen <= not (wrpend_samp(1) or wrpend_samp(0));
      rdpend_prev := rdpend(0);
    end if;
    if rising_edge(intclk) then
      dqsand <= wrpend_samp(0);
      dqoen <= not wrpend_samp(0);
      tmeas <= now - lt;
      lt := now;
    end if;
    if rising_edge(intclk) or falling_edge(intclk) then
      -- DDR outputs
      ddr_ca <= ca(ca'high-10*phase downto ca'high-10*phase-9);
      ddr_dm <= dm(dm'high-dbits/8*phase downto dm'high+1-dbits/8*(phase+1));
      ddr_dq_out <= dqout(dqout'high-dbits*phase downto dqout'high+1-dbits*(phase+1));
      if rising_edge(intclk) then
        -- SDR outputs
        ddr_cke <= cke(cke'high-ncs*(phase/2) downto cke'high+1-ncs*(phase/2+1));
        ddr_csb <= csn(csn'high-ncs*(phase/2) downto csn'high+1-ncs*(phase/2+1));
      end if;
      if phase < 2*clkratio-1 then
        phase := phase+1;
      end if;
    end if;
  end process;

  dqsckproc: process
    variable t: time;
  begin
    wait until dqsien='1';
    loop
      t := now;
      if dqsin/=(dqsin'range => '0') then
        wait until dqsin=(dqsin'range => '0');
      end if;
      wait until dqsin=(dqsin'range => '1');
      tdqsck <= tdqsck + (now-t)-0.25*tmeas;
      wait until dqsin=(dqsin'range => 'X') and dqsien='1';
    end loop;
  end process;

end;

