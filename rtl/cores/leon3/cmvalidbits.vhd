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
-- Entity:      cmvalidbits
-- File:        cmvalidbits.vhd
-- Author:      Magnus Hjorth - Cobham Gaisler
-- Description: Separate valid bits for data cache implemented with registers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cmvalidbits is
  generic (
    abits : integer;
    nways : integer range 1 to 4
    );
  port (
    clk : in std_ulogic;
    caddr: in std_logic_vector(abits-1 downto 0);
    cenable: in std_logic_vector(0 to nways-1);
    cwrite: in std_logic_vector(0 to nways-1);
    cwdata: in std_logic_vector(0 to nways-1);
    crdata: out std_logic_vector(0 to nways-1);
    saddr: in std_logic_vector(abits-1 downto 0);
    sclear: in std_logic_vector(0 to nways-1);
    flush: in std_ulogic
    );


end;

architecture rtl of cmvalidbits is

  type validbits_array_type is array(0 to 2**abits-1) of std_logic_vector(0 to nways-1);

  type validbits_regs is record
    valid: validbits_array_type;
    pcaddr: std_logic_vector(abits-1 downto 0);
    pcwrite: std_logic_vector(0 to nways-1);
    pcwdata: std_logic_vector(0 to nways-1);
    psaddr: std_logic_vector(abits-1 downto 0);
  end record;

  signal r,nr: validbits_regs;

begin

  comb: process(r,caddr,cenable,cwrite,cwdata,saddr,sclear,flush)
    variable vrdata: std_logic_vector(0 to nways-1);
    variable v: validbits_regs;
    variable wv: std_logic_vector(0 to nways-1);
    variable av: std_logic_vector(abits-1 downto 0);
    variable amask: std_logic_vector(0 to 2**abits-1);
  begin
    v := r;
    v.pcaddr := caddr;
    v.pcwrite := cenable and cwrite;
    v.pcwdata := cwdata;
    v.psaddr := saddr;
    -- Note: sclear is asserted one cycle after saddr so no pipeline reg on that
    vrdata := r.valid(to_integer(unsigned(r.pcaddr)));
    for i in 0 to 2**abits-1 loop
      wv := r.valid(i);
      av := std_logic_vector(to_unsigned(i,abits));
      if r.pcaddr=av then
        for j in 0 to nways-1 loop
          if r.pcwrite(j)='1' then
            wv(j) := r.pcwdata(j);
          end if;
        end loop;
      end if;
      if r.psaddr=av then
        for j in 0 to nways-1 loop
          if sclear(j)='1' then
            wv(j) := '0';
          end if;
        end loop;
      end if;
      if flush='1' then
        wv := (others => '0');
      end if;
      v.valid(i) := wv;
    end loop;
    nr <= v;
    crdata <= vrdata;
  end process;

  regs: process(clk)
  begin
    if rising_edge(clk) then r <= nr; end if;
  end process;

end;

