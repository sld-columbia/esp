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
-- Entity:      ddr2buf
-- File:        ddr2buf.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Convenience wrapper for syncram2p with data width conversion
--------------------------------------------------------------------------------

-- 2^rabits x rdbits determines amount of RAM.
--
-- If 2^wabits x wdbits is larger than this, the lowest bits of waddress are
-- used for sub-size writes. writebig ignores these lower bits and writes the
-- full data vector at once.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdlib.all;
use work.gencomp.all;

entity ddr2buf is
  generic (tech : integer := 0; wabits : integer := 6; wdbits : integer := 8;
        rabits : integer := 6; rdbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0; testen : integer := 0);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((rabits-1) downto 0);
    dataout  : out std_logic_vector((rdbits-1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    writebig : in std_ulogic;
    waddress : in std_logic_vector((wabits-1) downto 0);
    datain   : in std_logic_vector((wdbits-1) downto 0);
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0));
end;

architecture rtl of ddr2buf is

  function xlog2(x: integer) return integer is
    variable q,r: integer;
  begin
    r := 0; q := 1;
    while x > q loop
     q := q+q; r := r+1;
    end loop;
    return r;
  end xlog2;

  function xmax(a,b: integer) return integer is
  begin
    if a>b then return a; else return b; end if;
  end xmax;

  function xmin(a,b: integer) return integer is
  begin
    if a<b then return a; else return b; end if;
  end xmin;
  
  constant membits : integer := (2**rabits) * rdbits;

  constant wabitsbig : integer := xlog2(membits/wdbits);
  constant wdbitsbig : integer := wdbits;
  constant wabitssml : integer := wabits;
  constant wdbitssml : integer := membits / (2**wabits);

  constant totdwidth: integer := xmax(wdbitsbig,rdbits);
  constant partdwidth: integer := wdbitssml;
    
  constant nrams : integer := totdwidth/partdwidth;
  constant dbits : integer := wdbitssml;
  constant abits : integer := xlog2(membits/(dbits*nrams));

  constant rdratio : integer := rdbits/dbits;
  constant wdratio : integer := wdbitsbig/dbits;
  

  type dv_type is array (0 to nrams-1) of std_logic_vector(dbits-1 downto 0);
  signal do: dv_type;
  signal di: dv_type;
  signal we: std_logic_vector(0 to nrams-1);

  signal prev_raddress: std_logic_vector(rabits-1 downto 0);
  
begin

  regs: process(rclk)
  begin
    if rising_edge(rclk) then
      prev_raddress <= raddress;
    end if;
  end process;
  
  comb: process(prev_raddress,write,writebig,waddress,datain,do)        

    type rdvx_type is array (0 to totdwidth/rdbits-1) of std_logic_vector(rdbits-1 downto 0);  
    variable rdvx: rdvx_type;
    variable vdo: std_logic_vector((rdbits-1) downto 0);
    variable vdi: dv_type;
    variable vwe: std_logic_vector(0 to nrams-1);
    variable we1: std_logic_vector(0 to wdbitsbig/wdbitssml-1);
    variable we2: std_logic_vector(0 to wdratio-1);
        
  begin
    vdi := (others => (others => '0'));
    vwe := (others => '0');

    -- Generate rdvx from do
    for x in 0 to nrams-1 loop
      if rdbits > dbits then
        rdvx(x/rdratio)(rdbits-1-(x mod rdratio)*dbits downto rdbits-dbits-(x mod rdratio)*dbits) := do(x);
      else
        for y in 0 to dbits/rdbits-1 loop
          rdvx(x*dbits/rdbits + y) := do(x)(dbits-1-y*rdbits downto dbits-rdbits-y*rdbits);
        end loop;
      end if;        
    end loop;
    -- Generate dataout from rdvx and prev_address
    vdo := rdvx(totdwidth/rdbits-1);
    if totdwidth > rdbits then
      for x in 0 to totdwidth/rdbits-2 loop
        if prev_raddress(log2(totdwidth/rdbits)-1 downto 0) =
          std_logic_vector(to_unsigned(x,log2(totdwidth/rdbits))) then
          vdo := rdvx(x);
        end if;
      end loop;
    end if;

    

    -- Generate vdi from datain
    for x in 0 to nrams-1 loop
      vdi(x) := datain(wdbits-(x mod wdratio)*dbits-1 downto wdbits-(x mod wdratio)*dbits-dbits);
    end loop;
    
    -- Generate we2 from write/writebig
    we2 := (others => writebig);
    if wdbitsbig > wdbitssml then
      for x in 0 to wdbitsbig/wdbitssml-1 loop
        if write='1' and waddress(log2(wdbitsbig/wdbitssml)-1 downto 0) =
          std_logic_vector(to_unsigned(x,log2(wdbitsbig/wdbitssml))) then
          we2(x*wdbitssml/dbits to (x+1)*wdbitssml/dbits-1) := (others => '1');
        end if;
      end loop;
    else
      if write='1' then we2:=(others => '1'); end if;
    end if;
    
    -- Generate write-enable from we2
    vwe := (others => '0');
    if totdwidth > wdbitsbig then
      for x in 0 to totdwidth/wdbitsbig-1 loop
        if waddress(log2(totdwidth/wdbitssml)-1 downto log2(wdbitsbig/wdbitssml))=
          std_logic_vector(to_unsigned(x,log2(totdwidth/wdbitsbig))) then
          vwe(x*wdratio to (x+1)*wdratio-1) := we2;
        end if;      
      end loop;
    else
      vwe := we2;
    end if;

    
    dataout <= vdo;
    di <= vdi;
    we <= vwe;
  end process;
  
  ramgen: for x in 0 to nrams-1 generate
    r: syncram_2p generic map (tech,abits,dbits,sepclk,wrfst,testen)
      port map (rclk => rclk,renable => renable,
                raddress => raddress((rabits-1) downto (rabits-abits)),
                dataout => do(x),wclk => wclk,write => we(x),
                waddress => waddress((wabits-1) downto (wabits-abits)),
                datain => di(x), testin => testin);
  end generate;
  
end;

