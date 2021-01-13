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
-- Entity:      memrwcol
-- File:        memrwcol.vhd
-- Author:      Magnus Hjorth - Cobham Gaisler
-- Description: Sub-block for R/W collision management in syncram_2p/dp
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity memrwcol is
  generic (
    techwrfst : integer;
    techrwcol : integer;
    techrdhold : integer;
    abits: integer;
    dbits: integer;
    sepclk: integer;
    wrfst: integer
    );
  port (
    clk1     : in  std_ulogic;
    clk2     : in  std_ulogic;
    uenable1 : in  std_ulogic;
    uwrite1  : in  std_ulogic;
    uaddress1: in  std_logic_vector((abits-1) downto 0);
    udatain1 : in  std_logic_vector((dbits-1) downto 0);
    udataout1: out std_logic_vector((dbits-1) downto 0);
    uenable2 : in  std_ulogic;
    uwrite2  : in  std_ulogic;
    uaddress2: in  std_logic_vector((abits-1) downto 0);
    udatain2 : in  std_logic_vector((dbits-1) downto 0);
    udataout2: out std_logic_vector((dbits-1) downto 0);
    menable1 : out std_ulogic;
    menable2 : out std_ulogic;
    mdataout1: in  std_logic_vector((dbits-1) downto 0);
    mdataout2: in  std_logic_vector((dbits-1) downto 0);
    testmode : in  std_ulogic;
    testdata : in  std_logic_vector((dbits-1) downto 0)
    );
end;

architecture rtl of memrwcol is

  type memrwcol_regs is record
    address  : std_logic_vector((abits-1) downto 0);
    mux      : std_ulogic;              -- Read gated prev cycle
    wdata    : std_logic_vector((dbits-1) downto 0);
    wren     : std_ulogic;
  end record;

  signal r1, r1i, r2, r2i: memrwcol_regs;

  constant iwrfst : integer := (1-techwrfst) * wrfst;

begin

  comb: process(uenable1,uwrite1,uaddress1,udatain1,mdataout1,
                uenable2,uwrite2,uaddress2,udatain2,mdataout2,
                r1,r2,testmode,testdata)
    variable v1,v2: memrwcol_regs;
    variable ven1,ven2: std_ulogic;
    variable vout1,vout2: std_logic_vector((dbits-1) downto 0);
    variable domux1,domux2: std_ulogic;
  begin
    v1.address := uaddress1;
    v1.mux := '0';
    v1.wdata := udatain1;
    v1.wren := uenable1 and uwrite1;
    v2.address := uaddress2;
    v2.mux := '0';
    v2.wdata := udatain2;
    v2.wren := uenable2 and uwrite2;
    ven1 := uenable1;
    ven2 := uenable2;
    vout1 := mdataout1;
    vout2 := mdataout2;
    domux1 := '0';
    domux2 := '0';

    if sepclk=0 and techrwcol=1 then
      if uaddress1=uaddress2 then
        if v1.wren='1' then
          ven2 := '0';
          v2.mux := '1';
        end if;
        if v2.wren='1' then
          ven1 := '0';
          v1.mux := '1';
        end if;
      end if;
      domux1 := r1.mux;
      domux2 := r2.mux;
    elsif sepclk=0 and iwrfst=1 then
      if r1.address=r2.address then
        domux1 := r2.wren;
        domux2 := r1.wren;
      end if;
    end if;

    if (domux1='1' and wrfst=1) or testmode='1' then
      vout1 := r2.wdata;
    end if;
    if (domux2='1' and wrfst=1) or testmode='1' then
      vout2 := r1.wdata;
    end if;

    if (techrwcol=1 or iwrfst=1) and techrdhold=1 then
      -- If technology provides read-hold characteristics but not
      -- write-first behavior, make sure that works also in case
      -- of collisions. This is done by holding all the
      -- registers of the rw collision logic so the muxing stays active
      -- with the same write data.
      if (domux1='1' and uenable1='0') or (domux2='1' and uenable2='0') then
        v1 := r1;
        v2 := r2;
      end if;
    end if;

    if testmode='1' then
      v1.wdata := testdata;
      v2.wdata := testdata;
    end if;

    r1i <= v1;
    r2i <= v2;
    menable1 <= ven1;
    menable2 <= ven2;
    udataout1 <= vout1;
    udataout2 <= vout2;
  end process;

  regs1: process(clk1) is
  begin
    if rising_edge(clk1) then
      r1 <= r1i;
    end if;
  end process;

  regs2: process(clk2) is
  begin
    if rising_edge(clk2) then
      r2 <= r2i;
    end if;
  end process;

end;
