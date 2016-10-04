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
-- Entity: 	ahbrep
-- File:	ahbrep.vhd
-- Author:	Jiri Gaisler - Gaisler Reserch
-- Description:	Test report module with AHB interface
--
-- See also the work.debug.grtestmod module for a module connected via a
-- PROM/IO interface.
--
-- The base address of the module can be defined for the systest software via
-- the define GRLIB_REPORTDEV_BASE.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.sim.all;
use work.stdlib.all;
use work.stdio.all;
use work.devices.all;
use work.amba.all;

use std.textio.all;

entity ahbrep is
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    halt    : integer := 1); 
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type
  );
end;

architecture rtl of ahbrep is

constant abits : integer := 31;

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GRTESTMOD, 0, 0, 0),
  4 => ahb_membar(haddr, '0', '0', hmask),
  others => zero32);


type reg_type is record
  hwrite : std_ulogic;
  hsel   : std_ulogic;
  haddr  : std_logic_vector(31 downto 0);
  htrans : std_logic_vector(1 downto 0);
end record;

signal r, rin : reg_type;

begin

  ahbso.hresp   <= "00"; 
  ahbso.hsplit  <= (others => '0'); 
  ahbso.hirq    <= (others => '0');
  ahbso.hrdata    <= (others => '0');
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;
  ahbso.hready  <= '1';

  log : process(clk, ahbsi )
  variable errno, errcnt, subtest, vendorid, deviceid : integer;
  variable addr : std_logic_vector(21 downto 2);
  variable hwdata : std_logic_vector(31 downto 0);
  variable v : reg_type;
  begin
  if falling_edge(clk) then
    if (ahbsi.hready = '1') then
      v.haddr := ahbsi.haddr; v.hsel := ahbsi.hsel(hindex);
      v.hwrite := ahbsi.hwrite; v.htrans := ahbsi.htrans;
    end if;
    if (r.hsel and r.htrans(1) and r.hwrite and rst) = '1' then
      hwdata := ahbreadword(ahbsi.hwdata, r.haddr(4 downto 2));
      case r.haddr(7 downto 2) is
      when "000000" =>
        vendorid := conv_integer(hwdata(31 downto 24));
        deviceid := conv_integer(hwdata(23 downto 12));
	print(iptable(vendorid).device_table(deviceid));
      when "000001" =>
        errno := conv_integer(hwdata(15 downto 0));
	if  (halt = 1) then
	  assert false
	  report "test failed, error (" & tost(errno) & ")"
	  severity failure;
	else
	  assert false
	  report "test failed, error (" & tost(errno) & ")"
	  severity warning;
	end if;
      when "000010" =>
        subtest := conv_integer(hwdata(7 downto 0));
	call_subtest(vendorid, deviceid, subtest);
      when "000100" =>
        print ("");
        print ("**** GRLIB system test starting ****");
	errcnt := 0;
      when "000101" =>
	if errcnt = 0 then
          print ("Test passed, halting with IU error mode");
	elsif errcnt = 1 then
          print ("1 error detected, halting with IU error mode");
	else
          print (tost(errcnt) & " errors detected, halting with IU error mode");
        end if;
        print ("");
      when "000110" =>
        work.testlib.print("Checkpoint " & tost(conv_integer(hwdata(15 downto 0))));
      when "000111" =>
        vendorid := 0; deviceid := 0;
        print ("Basic memory test");
      when others =>
      end case;
    end if;
  end if;
  rin <= v;
  end process;

  reg : process (clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process;

-- pragma translate_off
    bootmsg : report_version 
    generic map ("testmod" & tost(hindex) & ": Test report module");
-- pragma translate_on
end;

