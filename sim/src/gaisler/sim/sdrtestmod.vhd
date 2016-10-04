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
-- Entity:      sdrtestmod
-- File:        sdrtestmod.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Test report module with SDRAM interface
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.devices.all;
use work.sim.all;

entity sdrtestmod is
  generic (
    width: integer := 32;               -- 32-bit or 64-bit supported
    bank: integer range 0 to 3 := 0;
    row: integer := 0;
    halt: integer range 0 to 1 := 1;
    swwidth: integer := 32 -- Internal reportdev size, can be 32/64
    );
  port (
    clk: in std_ulogic;
    csn: in std_ulogic;
    rasn: in std_ulogic;
    casn: in std_ulogic;
    wen: in std_ulogic;
    ba: in std_logic_vector(1 downto 0);
    addr: in std_logic_vector(12 downto 0);
    dq: inout std_logic_vector(width-1 downto 0);
    dqm: in std_logic_vector(width/8-1 downto 0)
    );
end;


architecture sim of sdrtestmod is
begin

  dq <= (others => 'Z');

  p: process(clk)
    variable modereg: std_logic_vector(12 downto 0);
    variable myrow: boolean := false;
    variable wrburst: integer := 0;
    variable wrcol: integer;
    variable i,j,k: integer;
    variable d: std_logic_vector(31 downto 0);

    variable errcnt, vendorid, deviceid : integer;
    procedure write_main(addr: integer; d: std_logic_vector) is
      variable errno, subtest : integer;
    begin
      case i is
        when 0 =>
          vendorid := conv_integer(d(31 downto 24));
          deviceid := conv_integer(d(23 downto 12));
          print(iptable(vendorid).device_table(deviceid));
        when 1 =>
          errno := conv_integer(d(15 downto 0));
          if  (halt = 1) then
            assert false
              report "test failed, error (" & tost(errno) & ")"
              severity failure;
          else
            assert false
              report "test failed, error (" & tost(errno) & ")"
              severity warning;
          end if;
        when 2 =>
          subtest := conv_integer(d(7 downto 0));
          call_subtest(vendorid, deviceid, subtest);
        when 4 =>
          print ("");
          print ("**** GRLIB system test starting ****");
          errcnt := 0;
        when 5 =>
          if errcnt = 0 then
            print ("Test passed, halting with IU error mode");
          elsif errcnt = 1 then
            print ("1 error detected, halting with IU error mode");
          else
            print (tost(errcnt) & " errors detected, halting with IU error mode");
          end if;
          print ("");
        when 6 =>
          work.testlib.print("Checkpoint " & tost(conv_integer(d(15 downto 0))));
        when 7 =>
          vendorid := 0; deviceid := 0;
          print ("Basic memory test");
        when others =>
      end case;
    end write_main;

  begin
    if rising_edge(clk) then
      if csn='0' then
        if rasn='0' and casn='0' and wen='0' then
          modereg := addr;
        elsif rasn='0' and casn='1' and wen='1' then
          if ba=conv_std_logic_vector(bank,2) and addr=conv_std_logic_vector(row,13) then
            myrow := true;
          else
            myrow := false;
          end if;
        elsif rasn='1' and casn='0' and wen='0' then
          if myrow then
            if modereg(9)='0' and modereg(2 downto 0)="001" then
              wrburst := 2;
            elsif modereg(9)='0' and modereg(2 downto 0)="010" then
              wrburst := 4;
            elsif modereg(9)='0' and (modereg(2 downto 0)="011" or modereg(2)='1') then
              wrburst := 8;
            else
              wrburst := 1;
            end if;
            wrcol := conv_integer(addr(7 downto 0));
          end if;
        elsif rasn='0' and casn='1' and wen='0' then
          if ba=conv_std_logic_vector(bank,2) or addr(10)='1' then
            myrow := false;
            wrburst := 0;
          end if;
        end if;
      end if;

      if wrburst > 0 then
        for x in 0 to (width/32)-1 loop
          if width=32 and swwidth=64 and (wrcol mod 2 < 1) then next; end if;
          if width=64 and swwidth=64 and x=0 then next; end if;
          if dqm(width/8-1-x*4 downto width/8-4-x*4) = "0000" then
            i := (wrcol*width)/swwidth + (x*32)/swwidth;
            d := dq(width-1-x*32 downto width-32-x*32);
            if d /= x"DEADBEEF" then
              write_main(i,d);
            end if;
          end if;
        end loop;
        wrburst := wrburst-1;
        wrcol := wrcol+1;
      end if;
    end if;
  end process;

end;

