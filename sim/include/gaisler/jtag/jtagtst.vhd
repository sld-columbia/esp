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
-- Package:     sim
-- File:        sim.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Description: JTAG debug link communication test 
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.stdlib.all;
use work.stdio.all;
use work.amba.all;

package jtagtst is

  procedure clkj(tmsi, tdii : in std_ulogic; tdoo : out std_ulogic;
                 signal tck, tms, tdi : out std_ulogic;
                 signal tdo           : in std_ulogic;
                 cp                   : in integer);

  procedure shift(dr : in boolean; len : in integer;
                  din : in std_logic_vector; dout : out std_logic_vector;
                  signal tck, tms, tdi : out std_ulogic;
                  signal tdo           : in std_ulogic;
                  cp                   : in integer);                  

  procedure jtagcom(signal tdo           : in std_ulogic;
                    signal tck, tms, tdi : out std_ulogic;
                    cp, start, addr      : in integer;
                                                          -- cp - TCK clock period in ns
                                                          -- start - time in us when JTAG test
                                                          -- is started
                                                          -- addr - read/write operation destination address 
                    haltcpu          : in boolean;
                    justinit         : in boolean := false;  -- Only perform initialization
                    reread           : in boolean := false;  -- Re-read on slow AHB response
                    assertions       : in boolean := false   -- Allow output from assertions 
                    );

  subtype jword_type is std_logic_vector(31 downto 0);
  type jdata_vector_type is array (integer range <>) of jword_type;

  procedure jwritem(addr                 : in std_logic_vector;
                    data                 : in jdata_vector_type;
                    signal tck, tms, tdi : out std_ulogic;
                    signal tdo           : in std_ulogic;
                    cp                   : in integer);

  procedure jwritem(addr                 : in std_logic_vector;
                    data                 : in jdata_vector_type;
                    hsize                : in std_logic_vector(1 downto 0);
                    signal tck, tms, tdi : out std_ulogic;
                    signal tdo           : in std_ulogic;
                    cp                   : in integer);
  
  procedure jreadm(addr                 : in  std_logic_vector;
                   data                 : out jdata_vector_type;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                   cp                   : in integer;
                   reread               : in boolean := false;
                   assertions           : in boolean := false);

  procedure jreadm(addr                 : in  std_logic_vector;
                   hsize                : in std_logic_vector(1 downto 0);
                   data                 : out jdata_vector_type;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                   cp                   : in integer;
                   reread               : in boolean := false;
                   assertions           : in boolean := false);

  procedure jwrite(addr, data           : in std_logic_vector;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                   cp                   : in integer);

  procedure jwrite(addr, hsize, data           : in std_logic_vector;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                   cp                   : in integer;
                   ainst                : in integer := 2;
                   dinst                : in integer := 3;
                   isize                : in integer := 6);

  procedure jread(addr                 : in  std_logic_vector;
                  data                 : out std_logic_vector;
                  signal tck, tms, tdi : out std_ulogic;
                  signal tdo           : in std_ulogic;
                  cp                   : in integer;
                  reread               : in boolean := false;
                  assertions           : in boolean := false);

  procedure jread(addr                 : in  std_logic_vector;
                  hsize                : in  std_logic_vector;
                  data                 : out std_logic_vector;
                  signal tck, tms, tdi : out std_ulogic;
                  signal tdo           : in std_ulogic;
                  cp                   : in integer;
                  reread               : in boolean := false;
                  assertions           : in boolean := false);

  procedure bscantest(signal tdo : in std_ulogic;
                      signal tck, tms, tdi : out std_ulogic;
                      cp: in integer;
                      inst_samp: integer := 5;
                      inst_extest: integer := 6;
                      inst_intest: integer := 7;
                      inst_mbist: integer := 11;
                      fastmode: boolean := false);

  procedure bscansampre(signal tdo : in std_ulogic;
                        signal tck, tms, tdi : out std_ulogic;
                        nsigs: in integer;
                        sigpre: in std_logic_vector; sigsamp: out std_logic_vector;
                        cp: in integer; inst_samp: integer);
  
end;  


package body jtagtst is

  procedure clkj(tmsi, tdii : in std_ulogic; tdoo : out std_ulogic;
                 signal tck, tms, tdi : out std_ulogic;
                 signal tdo           : in std_ulogic;
                 cp                   : in integer) is
  begin
    tdi <= tdii;
    tck <= '0'; tms <= tmsi;
    wait for 2 * cp * 1 ns;
    tck <= '1'; tdoo := tdo;
    wait for 2 * cp * 1 ns;
  end;        

  procedure shift(dr : in boolean; len : in integer;
                  din : in std_logic_vector; dout : out std_logic_vector;
                  signal tck, tms, tdi : out std_ulogic;
                  signal tdo           : in std_ulogic;
                  cp                   : in integer) is
    variable dc : std_ulogic;
  begin
    clkj('0', '0', dc, tck, tms, tdi, tdo, cp);
    clkj('1', '0', dc, tck, tms, tdi, tdo, cp);
    if (not dr) then clkj('1', '0', dc, tck, tms, tdi, tdo, cp); end if;
    clkj('0', '0', dc, tck, tms, tdi, tdo, cp);  -- capture
    clkj('0', '0', dc, tck, tms, tdi, tdo, cp);  -- shift (state)
    for i in 0 to len-2 loop
      clkj('0', din(i), dout(i), tck, tms, tdi, tdo, cp);  
    end loop;        
    clkj('1', din(len-1), dout(len-1), tck, tms, tdi, tdo, cp);  -- end shift, goto exit1
    clkj('1', '0', dc, tck, tms, tdi, tdo, cp);  -- update ir/dr
    clkj('0', '0', dc, tck, tms, tdi, tdo, cp);  -- run_test/idle                                                      
  end;

  procedure jwrite(addr, data           : in std_logic_vector;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                  cp                    : in integer) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
    variable hsize : std_logic_vector(1 downto 0);        
  begin
    hsize := "10";
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;
    tmp2 := '1' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    tmp := '0' & data;
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- write data reg
  end;

  procedure jwrite(addr, hsize, data    : in std_logic_vector;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                   cp                   : in integer;
                   ainst                : in integer := 2;
                   dinst                : in integer := 3;
                   isize                : in integer := 6) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
    variable v_ainst : std_logic_vector(0 to 7);
    variable v_dinst : std_logic_vector(0 to 7);
    variable tmp3 : std_logic_vector(7 downto 0);
    variable tmp4 : std_logic_vector(7 downto 0);
  begin
    tmp3 := conv_std_logic_vector(ainst,8);
    tmp4 := conv_std_logic_vector(dinst,8);
    for i in 0 to 7 loop
      v_ainst(i) := tmp3(i);
      v_dinst(i) := tmp4(i);
    end loop;

    wait for 10 * cp * 1 ns;
    shift(false, isize, v_ainst(0 to isize-1), dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;
    tmp2 := '1' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, isize, v_dinst(0 to isize-1), dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    tmp := '0' & data;
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- write data reg
  end;

  procedure jread(addr                 : in  std_logic_vector;
                  data                 : out std_logic_vector;
                  signal tck, tms, tdi : out std_ulogic;
                  signal tdo           : in std_ulogic;
                  cp                   : in integer;
                  reread               : in boolean := false;
                  assertions           : in boolean := false) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
    variable hsize : std_logic_vector(1 downto 0);            
  begin
    hsize := "10";    
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;    
    tmp2 := '0' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    tmp := (others => '0'); --tmp(32) := '1'; 
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    assert dr(32) = '1' or not assertions
      report "JTAG READ: data read out before AHB access completed"
      severity warning;
    while dr(32) /= '1' and reread loop
      assert not assertions report "Re-reading JTAG data register" severity note;
      tmp := (others => '0');
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    end loop;
    data := dr(31 downto 0);
  end;

  procedure jread(addr                 : in  std_logic_vector;
                  hsize                : in  std_logic_vector;
                  data                 : out std_logic_vector;
                  signal tck, tms, tdi : out std_ulogic;
                  signal tdo           : in std_ulogic;
                  cp                   : in integer;
                  reread               : in boolean := false;
                  assertions           : in boolean := false) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
  begin
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;    
    tmp2 := '0' & hsize & addr;
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    tmp := (others => '0'); --tmp(32) := '1';
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    assert dr(32) = '1' or not assertions
      report "JTAG READ: data read out before AHB access completed"
      severity warning;
    while dr(32) /= '1' and reread loop
      assert not assertions report "Re-reading JTAG data register" severity note;
      wait for 5 * cp * 1 ns;
      tmp := (others => '0');
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    end loop;
    data := dr(31 downto 0);
  end;
  
  procedure jwritem(addr                 : in std_logic_vector;
                    data                 : in jdata_vector_type;
                    signal tck, tms, tdi : out std_ulogic;
                    signal tdo           : in std_ulogic;
                    cp                   : in integer) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
    variable hsize : std_logic_vector(1 downto 0);        
  begin
    hsize := "10";    
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;
    tmp2 := '1' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    for i in data'left to data'right-1 loop
      tmp := '1' & data(i);
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- write data reg
    end loop;
    tmp := '0' & data(data'right);
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- write data reg    
  end;

  procedure jwritem(addr                 : in std_logic_vector;
                    data                 : in jdata_vector_type;
                    hsize                : in std_logic_vector(1 downto 0);
                    signal tck, tms, tdi : out std_ulogic;
                    signal tdo           : in std_ulogic;
                    cp                   : in integer) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
  begin
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;
    tmp2 := '1' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    for i in data'left to data'right-1 loop
      tmp := '1' & data(i);
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- write data reg
    end loop;
    tmp := '0' & data(data'right);
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- write data reg    
  end;  

  procedure jreadm(addr                 : in  std_logic_vector;
                   data                 : out jdata_vector_type;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                   cp                   : in integer;
                   reread               : in boolean := false;
                   assertions           : in boolean := false) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
    variable hsize : std_logic_vector(1 downto 0);
  begin
    hsize := "10";    
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;    
    tmp2 := '0' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    for i in data'left to data'right-1 loop
      tmp := (others => '0'); tmp(32) := '1';
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
      assert dr(32) = '1' or not assertions
        report "JTAG READ: data read out before AHB access completed"
        severity warning;
      while dr(32) /= '1' and reread loop
        assert not assertions report "Re-reading JTAG data register" severity note;
        tmp := (others => '0'); tmp(32) := '1';
        shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
      end loop;
      data(i) := dr(31 downto 0);
    end loop;
    tmp := (others => '0');
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    assert dr(32) = '1' or not assertions
      report "JTAG READ: data read out before AHB access completed"
      severity warning;
    while dr(32) /= '1' and reread loop
      assert not assertions report "Re-reading JTAG data register" severity note;
      tmp := (others => '0');
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    end loop;
    data(data'right) := dr(31 downto 0);
  end;

  procedure jreadm(addr                 : in  std_logic_vector;
                   hsize                : in  std_logic_vector(1 downto 0);
                   data                 : out jdata_vector_type;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                   cp                   : in integer;
                   reread               : in boolean := false;
                   assertions           : in boolean := false) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
  begin
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;    
    tmp2 := '0' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    for i in data'left to data'right-1 loop
      tmp := (others => '0'); tmp(32) := '1';
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
      assert dr(32) = '1' or not assertions
        report "JTAG READ: data read out before AHB access completed"
        severity warning;
      while dr(32) /= '1' and reread loop
        assert not assertions report "Re-reading JTAG data register" severity note;
        tmp := (others => '0'); tmp(32) := '1';
        shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
      end loop;
      data(i) := dr(31 downto 0);
    end loop;
    tmp := (others => '0');
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    assert dr(32) = '1' or not assertions
      report "JTAG READ: data read out before AHB access completed"
      severity warning;
    while dr(32) /= '1' and reread loop
      assert not assertions report "Re-reading JTAG data register" severity note;
      tmp := (others => '0');
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    end loop;
    data(data'right) := dr(31 downto 0);
  end;

procedure jtagcom(signal tdo : in std_ulogic;
                  signal tck, tms, tdi : out std_ulogic;
                  cp, start, addr  : in integer;
                  haltcpu          : in boolean;
                  justinit         : in boolean := false;
                  reread           : in boolean := false;
                  assertions       : in boolean := false) is
  variable dc : std_ulogic;
  variable dr : std_logic_vector(32 downto 0);
  variable tmp : std_logic_vector(32 downto 0);
  variable data : std_logic_vector(31 downto 0);
  variable datav : jdata_vector_type(0 to 3);
begin

  tck <= '0'; tms <= '0'; tdi <= '0';

  wait for start * 1 us;
  
  print("AHB JTAG TEST");    
  for i in 1 to 5 loop     -- reset
    clkj('1', '0', dc, tck, tms, tdi, tdo, cp);
  end loop;        
  clkj('0', '0', dc, tck, tms, tdi, tdo, cp);

  --read IDCODE
  wait for 10 * cp * 1 ns;
  shift(true, 32, conv_std_logic_vector(0, 32), dr, tck, tms, tdi, tdo, cp);        
  print("JTAG TAP ID:" & tost(dr(31 downto 0)));
 
  wait for 10 * cp * 1 ns;
  shift(false, 6, conv_std_logic_vector(63, 6), dr, tck, tms, tdi, tdo, cp);    -- BYPASS

  --shift data through BYPASS reg
  shift(true, 32, conv_std_logic_vector(16#AAAA#, 16) & conv_std_logic_vector(16#AAAA#, 16), dr,
        tck, tms, tdi, tdo, cp);                

  -- put CPUs in debug mode
  if haltcpu then
      jwrite(X"90000000", X"00000004", tck, tms, tdi, tdo, cp);      
      jwrite(X"90000020", X"0000FFFF", tck, tms, tdi, tdo, cp);
    print("JTAG: Putting CPU in debug mode");
  end if;

  if false then
  jwrite(X"90000000", X"FFFFFFFF", tck, tms, tdi, tdo, cp);
  jread (X"90000000", data, tck, tms, tdi, tdo, cp, reread, assertions);  
  print("JTAG WRITE " &  tost(X"90000000") & ":" & tost(X"FFFFFFFF"));
  print("JTAG READ  " &  tost(X"90000000") & ":" & tost(data));
  
  jwrite(X"90100034", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90100034", data, tck, tms, tdi, tdo, cp, reread, assertions);
  print("JTAG WRITE " &  tost(X"90100034") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  " &  tost(X"90100034") & ":" & tost(data));  

  jwrite(X"90200058", X"ABCDEF01", tck, tms, tdi, tdo, cp);
  jread (X"90200058", data, tck, tms, tdi, tdo, cp, reread, assertions);
  print("JTAG WRITE " &  tost(X"90200058") & ":" & tost(X"ABCDEF01"));
  print("JTAG READ  " &  tost(X"90200058") & ":" & tost(data));  
  
  jwrite(X"90300000", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90300000", data, tck, tms, tdi, tdo, cp, reread, assertions);
  print("JTAG WRITE " &  tost(X"90300000") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  " &  tost(X"90300000") & ":" & tost(data));  
  
  jwrite(X"90400000", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90400000", data, tck, tms, tdi, tdo, cp, reread, assertions);
  print("JTAG WRITE " &  tost(X"90400000") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  " &  tost(X"90400000") & ":" & tost(data));  

  jwrite(X"90400024", X"0000000C", tck, tms, tdi, tdo, cp);
  jwrite(X"90700100", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90700100", data, tck, tms, tdi, tdo, cp, reread, assertions);
  print("JTAG WRITE ITAG :" &  tost(X"00000100") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  ITAG :" &  tost(X"00000100") & ":" & tost(data));  
    
  jwrite(X"90400024", X"0000000D", tck, tms, tdi, tdo, cp);
  jwrite(X"90700100", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90700100", data, tck, tms, tdi, tdo, cp, reread, assertions);
  print("JTAG WRITE IDATA:" &  tost(X"00000100") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  IDATA:" &  tost(X"00000100") & ":" & tost(data));  
    
  jwrite(X"90400024", X"0000000E", tck, tms, tdi, tdo, cp);
  jwrite(X"90700100", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90700100", data, tck, tms, tdi, tdo, cp, reread, assertions);
  print("JTAG WRITE DTAG :" &  tost(X"00000100") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  DTAG :" &  tost(X"00000100") & ":" & tost(data));  

  jwrite(X"90400024", X"0000000F", tck, tms, tdi, tdo, cp);  
  jwrite(X"90700100", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90700100", data, tck, tms, tdi, tdo, cp, reread, assertions);
  print("JTAG WRITE DDATA:" &  tost(X"00000100") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  DDATA:" &  tost(X"00000100") & ":" & tost(data));  
  end if;

  if not justinit then
  
  --jwritem(addr, (X"00000010", X"00000010", X"00000010", X"00000010"), tck, tms, tdi, tdo, cp);
  datav(0) := X"00000010"; datav(1) := X"00000011"; datav(2) := X"00000012";  datav(3) := X"00000013";
  jwritem(conv_std_logic_vector(addr, 32), datav, tck, tms, tdi, tdo, cp);  
  print("JTAG WRITE " &  tost(conv_std_logic_vector(addr,32)) & ":" & tost(X"00000010") & " " & tost(X"00000011") & " " & tost(X"00000012") & " " & tost(X"00000013"));

  datav := (others => (others => '0'));
  jreadm(conv_std_logic_vector(addr, 32), datav, tck, tms, tdi, tdo, cp, reread, assertions);
  print("JTAG READ  " &  tost(conv_std_logic_vector(addr,32)) & ":" & tost(datav(0)) & " " & tost(datav(1)) & " "  & tost(datav(2)) & " " & tost(datav(3))); 

  -- Not affected by 'assertions' parameter
  assert (datav(0) = X"00000010") and (datav(1) = X"00000011") and (datav(2) = X"00000012") and (datav(3) = X"00000013")
    report "JTAG test failed" severity failure;
  
  print("JTAG test passed");

  end if;
  
  end procedure;

  -- Sample/Preload
  procedure bscansampre(signal tdo : in std_ulogic;
                        signal tck, tms, tdi : out std_ulogic;
                        nsigs: in integer;
                        sigpre: in std_logic_vector; sigsamp: out std_logic_vector;
                        cp: in integer; inst_samp: integer) is
    variable tmp: std_logic_vector(5 downto 0);
  begin
    shift(false,6, conv_std_logic_vector(inst_samp,6), tmp, tck,tms,tdi,tdo, cp);
    shift(true, nsigs, sigpre, sigsamp, tck,tms,tdi,tdo, cp);
  end procedure;

  -- Boundary scan test
  procedure bscantest(signal tdo : in std_ulogic;
                      signal tck, tms, tdi : out std_ulogic;
                      cp: in integer;
                      inst_samp: integer := 5;
                      inst_extest: integer := 6;
                      inst_intest: integer := 7;
                      inst_mbist: integer := 11;
                      fastmode: boolean := false) is
    variable tmpin,tmpout: std_logic_vector(1999 downto 0);
    variable i,bslen: integer;
    variable dc: std_logic;
    variable tmp6: std_logic_vector(5 downto 0);
    variable tmp1: std_logic_vector(0 downto 0);
  begin
    print("[bscan] Boundary scan test starting...");
    for i in 1 to 5 loop     -- reset
      clkj('1', '0', dc, tck, tms, tdi, tdo, cp);
    end loop;        
    clkj('0', '0', dc, tck, tms, tdi, tdo, cp);
    -- Probe length of boundary scan chain    
    tmpin := (others => '0');
    tmpin(tmpin'length/2) := '1';
    bscansampre(tdo,tck,tms,tdi,tmpin'length,tmpin,tmpout,cp,inst_samp);
    i := tmpout'length/2;
    for x in tmpout'length/2 to tmpout'high loop
      if tmpout(x)='1' then
        -- print("tmpout(" & tost(x) & ") set");
        i := x;
      end if;
    end loop;
    bslen := i-tmpout'length/2;
    if bslen=0 then
      print("[bscan] Scan chain not present, skipping test");
      return;
    end if;
    print("[bscan] Detected boundary scan chain length: " & tost(bslen));
    if fastmode then
      print("[bscan] Setting EXTEST with all chain regs=0");
      shift(false,6, conv_std_logic_vector(inst_extest,6), tmp6, tck,tms,tdi,tdo, cp);  -- extest
      print("[bscan] In EXTEST, changing all chain regs to 1");
      tmpin := (others => '1');
      shift(true, bslen, tmpin(bslen-1 downto 0), tmpout(bslen-1 downto 0), tck,tms,tdi,tdo, cp);
      print("[bscan] Setting INTEST with all chain regs=1");
      shift(false,6, conv_std_logic_vector(inst_intest,6), tmp6, tck,tms,tdi,tdo, cp);  -- intest
      print("[bscan] In INTEST, changing all chain regs to 0");
      tmpin := (others => '0');
      shift(true, bslen, tmpin(bslen-1 downto 0), tmpout(bslen-1 downto 0), tck,tms,tdi,tdo, cp);
    else
      print("[bscan] Looping over outputs...");
      shift(false,6, conv_std_logic_vector(inst_extest,6), tmp6, tck,tms,tdi,tdo, cp);  -- extest
      for x in 0 to bslen loop
        tmpin :=(others => '0');
        tmpin(x) := '1';
        shift(true, bslen, tmpin(bslen-1 downto 0), tmpout(bslen-1 downto 0), tck,tms,tdi,tdo, cp);
      end loop;
      print("[bscan] Looping over inputs...");
      shift(false,6, conv_std_logic_vector(inst_intest,6), tmp6, tck,tms,tdi,tdo, cp);  -- intest
      for x in 0 to bslen loop
        tmpin :=(others => '0');
        tmpin(x) := '1';
        shift(true, bslen, tmpin(bslen-1 downto 0), tmpout(bslen-1 downto 0), tck,tms,tdi,tdo, cp);
      end loop;
    end if;
    if inst_mbist >= 0 then
      print("[bscan] Shifting in MBIST command");
      shift(false,6, conv_std_logic_vector(inst_mbist,6), tmp6, tck,tms,tdi,tdo, cp);  -- MBIST command
    end if;
    print("[bscan] Test done");
  end procedure;
  
end;

-- pragma translate_on

