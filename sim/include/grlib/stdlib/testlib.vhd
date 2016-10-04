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
-- package: 	testlib
-- file:	testlib.vhd
-- author:	Marko Isomaki - Aeroflex Gaisler
-- description:	package for common vhdl functions for testbenches
------------------------------------------------------------------------------

-- pragma translate_off
library  std;
use      std.standard.all;
use      std.textio.all;

library  ieee;
use      ieee.std_logic_1164.all;
use      ieee.numeric_std.all;
use      ieee.math_real.all;

use      work.stdio.all;
use      work.stdlib.tost;
-- pragma translate_on

package testlib is
-- pragma translate_off
   type octet_vector   is array (natural range <>) of std_logic_vector(7 downto 0);
   subtype data_vector8 is octet_vector;
   type data_vector16  is array (natural range <>) of std_logic_vector(15 downto 0);
   type data_vector32  is array (natural range <>) of std_logic_vector(31 downto 0);
   type data_vector64  is array (natural range <>) of std_logic_vector(63 downto 0);
   type data_vector128 is array (natural range <>) of std_logic_vector(127 downto 0);
   type data_vector256 is array (natural range <>) of std_logic_vector(255 downto 0);
   type nibble_vector  is array (natural range <>) of std_logic_vector(3 downto 0);
   subtype data_vector is data_vector32;
   
   -----------------------------------------------------------------------------
   -- compare function handling '-'. c is the expected data parameter. If it is
   --'-' or 'U' then this bit is not compared. Returns true if the vectors match
   -----------------------------------------------------------------------------
   function compare(o, c: in std_logic_vector) return boolean;

   -----------------------------------------------------------------------------
   -- compare function handling '-'
   -----------------------------------------------------------------------------
   function compare(o, c: in std_ulogic_vector) return boolean;

   -----------------------------------------------------------------------------
   -- this procedure prints a message to standard output. Also includes the time
   -- at which it occurs.
   -----------------------------------------------------------------------------
   procedure print(
      constant comment:    in    string         := "-";
      constant severe:     in    severity_level := note;
      constant screen:     in    boolean        := true);

   -----------------------------------------------------------------------------
   -- synchronisation with respect to clock and with output offset
   -----------------------------------------------------------------------------
   procedure synchronise(
      signal   clock:      in    std_ulogic;
      constant offset:     in    time    := 5 ns;
      constant enable:     in    boolean := true);

   -----------------------------------------------------------------------------
   -- this procedure initialises the test error counters. Used in testbenches
   -- with a test variable to check if a subtest has failed and at the end how
   -- many subtests have failed. This procedure is called before the first
   -- subtest
   -----------------------------------------------------------------------------
   procedure tinitialise(
      variable test:       inout boolean;
      variable testcount:  inout integer);

   -----------------------------------------------------------------------------
   -- this procedure completes the sub-test. Called at the end of each subtest
   -----------------------------------------------------------------------------
   procedure tintermediate(
      variable test:       inout boolean;
      variable testcount:  inout integer);

   -----------------------------------------------------------------------------
   -- this procedure completes the test. Called at the end of the complete test
   -----------------------------------------------------------------------------
   procedure tterminate(
      variable test:       inout boolean;
      variable testcount:  inout integer);

   -----------------------------------------------------------------------------
   -- check std_logic_vector array
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    std_logic_vector;
      constant expected:   in    std_logic_vector;
      constant message:    in    string := "");

   -----------------------------------------------------------------------------
   -- check std_logic
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    std_logic;
      constant expected:   in    std_logic;
      constant message:    in    string := "");

   -----------------------------------------------------------------------------
   -- check std_ulogic_vector array
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    std_ulogic_vector;
      constant expected:   in    std_ulogic_vector;
      constant message:    in    string := "");

   -----------------------------------------------------------------------------
   -- check natural
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    natural;
      constant expected:   in    natural;
      constant message:    in    string := "");

   -----------------------------------------------------------------------------
   -- check time
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    time;
      constant expected:   in    time;
      constant spread:     in    time;
      constant message:    in    string := "");

   -----------------------------------------------------------------------------
   -- check boolean
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    boolean;
      constant expected:   in    boolean;
      constant message:    in    string := "");

   -----------------------------------------------------------------------------
   -- Convert Data_Vector to Octet_Vector
   -----------------------------------------------------------------------------
   function conv_octet_vector(
      constant d:             in    data_vector)
      return                        octet_vector;

   -----------------------------------------------------------------------------
   -- Convert Octet_Vector to Data_Vector, with padding
   -----------------------------------------------------------------------------
   function conv_data_vector(
      constant o:             in    octet_vector)
      return                        data_vector;

   procedure compare(
     constant data:     in    octet_vector;
     constant cxdata:   in    octet_vector;
     variable tP:       inout boolean);

   ----------------------------------------------------------------------------
   -- Read file contents to octet vector
   ----------------------------------------------------------------------------
   --Expects data only in hex with four bytes on each line.
   procedure readfile(
     constant filename:      in    string := "";
     constant filetype:      in    integer := 0;
     constant size:          in    integer := 0;
     variable dataout:       out   octet_vector);

   --Reads bytes from a file with the format packets are output from ethereal
   procedure readfile(
     constant filename:      in    string := "";
     constant size:          in    integer := 0;
     variable dataout:       out   octet_vector);
   
   ----------------------------------------------------------------------------
   -- Read file contents to data_vector
   ----------------------------------------------------------------------------
   --Expects data only in hex with four bytes on each line.
   procedure readfile(
     constant filename:      in    string := "";
     constant size:          in    integer := 0;
     variable dataout:       out   data_vector);

   --generates an random integer from 0 to the maximum value specified with max
   procedure gen_rand_int(
     constant max   : in    real;
     variable seed1 : inout positive;
     variable seed2 : inout positive;
     variable rand  : out   integer);

   --reverses std_logic_vector
   function reverse(din : std_logic_vector) return std_logic_vector;

   -- Returns offset to start of valid data for an access of size 'size' in
   -- AMBA data vector
   function ahb_doff (
     constant dw   : integer;
     constant size : integer;           -- access size
     constant addr : std_logic_vector(4 downto 0))
     return integer;
-- pragma translate_on
   
end package testlib;

-- pragma translate_off
--============================================================================--

package body testlib is
   -----------------------------------------------------------------------------
   -- compare function handling '-'
   -----------------------------------------------------------------------------
   function compare(o, c: in std_logic_vector) return boolean is
      variable t:       std_logic_vector(o'range) := c;
      variable result:  boolean;
   begin
      result := true;
      for i in o'range loop
          if not (o(i)=t(i) or t(i)='-' or t(i)='U') then
            result   := false;
          end if;
      end loop;
      return result;
   end function compare;

   -----------------------------------------------------------------------------
   -- compare function handling '-'
   -----------------------------------------------------------------------------
   function compare(o, c: in std_ulogic_vector) return boolean is
      variable t:       std_ulogic_vector(o'range) := c;
      variable result:  boolean;
   begin
      result := true;
      for i in o'range loop
          if not (o(i)=t(i) or t(i)='-' or t(i)='U') then
            result   := false;
          end if;
      end loop;
      return result;
   end function compare;

   -----------------------------------------------------------------------------
   -- this procedure prints a message to standard output
   -----------------------------------------------------------------------------
   procedure print(
      constant comment:    in    string         := "-";
      constant severe:     in    severity_level := note;
      constant screen:     in    boolean        := true) is
      variable l:                line;
   begin
      if screen then
         write(l, now, right, 15);
         write(l, " : " & comment);
         if    severe = warning then
            write(l, string'(" # warning, "));
         elsif severe = error then
            write(l, string'(" # error, "));
         elsif severe = failure then
            write(l, string'(" # failure, "));
         end if;
         writeline(output, l);
         end if;
   end procedure print;

   -----------------------------------------------------------------------------
   -- synchronisation with respect to clock and with output offset
   -----------------------------------------------------------------------------
   procedure synchronise(
      signal   clock:      in    std_ulogic;
      constant offset:     in    time    := 5 ns;
      constant enable:     in    boolean := true) is
   begin
      if enable then
         wait until clock = '1';                         -- synchronise
         wait for offset;                                -- output offset delay
      end if;
   end procedure synchronise;

   -----------------------------------------------------------------------------
   -- this procedure initialises the test error counters
   -----------------------------------------------------------------------------
   procedure tinitialise(
      variable test:       inout boolean;
      variable testcount:  inout integer) is
   begin
      --------------------------------------------------------------------------
      -- initialise test status
      --------------------------------------------------------------------------
      test           := true;                            -- reset any errors
      testcount      := 0;
      print("--=========================================================--");
      print("*** test initialised                                      ***");
      print("--=========================================================--");
   end procedure tinitialise;

   -----------------------------------------------------------------------------
   -- this procedure completes the sub-test
   -----------------------------------------------------------------------------
   procedure tintermediate(
      variable test:       inout boolean;
      variable testcount:  inout integer) is
      variable l:                line;
   begin
      --------------------------------------------------------------------------
      -- report test status
      --------------------------------------------------------------------------
      wait for 10 us;
      print("--=========================================================--");
      if test then
         print("*** sub-test completed successfully                       ***");
         if testcount >  0 then
            write(l, now, right, 15);
            write(l, string'(" :     "));
            write(l, testcount);
            write(l, string'(" sub-test(s) ended with one or more errors."));
            writeline(output, l);
         end if;
      else
         print("*** sub-test completed with errors   -- # error # --      ***");
         testcount   := testcount + 1;
         test        := true;
         if testcount >  0 then
            write(l, now, right, 15);
            write(l, string'(" :     "));
            write(l, testcount);
            write(l, string'(" sub-test(s) ended with one or more errors."));
            writeline(output, l);
         end if;
      end if;
      print("--=========================================================--");
   end procedure tintermediate;

   -----------------------------------------------------------------------------
   -- this procedure completes the test
   -----------------------------------------------------------------------------
   procedure tterminate(
      variable test:       inout boolean;
      variable testcount:  inout integer) is
      variable l:                line;
   begin
      --------------------------------------------------------------------------
      -- end of test
      --------------------------------------------------------------------------
      wait for 1 ms;
      print("--=========================================================--");
      if testcount = 0  then
         print("*** test completed successfully                           ***");
      else
         print("*** test completed with errors       -- # error # --      ***");
         write(l, now, right, 15);
         write(l, string'(" :     "));
         write(l, testcount);
         write(l, string'(" sub-test(s) ended with one or more errors."));
         writeline(output, l);
      end if;
      print("--=========================================================--");
      report "---- end of test ----"
         severity failure;
      wait;
   end procedure tterminate;

   -----------------------------------------------------------------------------
   -- check std_logic_vector array
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    std_logic_vector;
      constant expected:   in    std_logic_vector;
      constant message:    in    string := "") is
      variable l:                line;
      constant padding:          std_logic_vector(1 to
                                                 (4-(received'length mod 4))) :=
                                    (others => '0');
   begin
      if not compare(received, expected) then
         write(l, now, right, 15);
         write(l, string'(" : ") & message & string'(" :"));
         write(l, string'(" received: "));
         if padding'length > 0 and padding'length < 4 then
            hwrite(l, padding & std_logic_vector(received));
         else
            hwrite(l, std_logic_vector(received));
         end if;
         write(l, string'(" expected: "));
         if padding'length > 0 and padding'length < 4 then
            hwrite(l, padding & std_logic_vector(expected));
         else
            hwrite(l, std_logic_vector(expected));
         end if;
         write(l, string'(" # error"));
         writeline(output, l);
         tp := false;
      end if;
   end procedure check;

   -----------------------------------------------------------------------------
   -- check std_logic
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    std_logic;
      constant expected:   in    std_logic;
      constant message:    in    string := "") is
      variable l:                line;
   begin
      if not (to_x01z(received)=to_x01z(expected)) then
         write(l, now, right, 15);
         write(l, string'(" : ") & message & string'(" :"));
         write(l, string'(" received: "));
         write(l, received);
         write(l, string'(" expected: "));
         write(l, expected);
         write(l, string'(" # error"));
         writeline(output, l);
         tp := false;
      end if;
   end procedure check;

   -----------------------------------------------------------------------------
   -- check std_ulogic_vector array
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    std_ulogic_vector;
      constant expected:   in    std_ulogic_vector;
      constant message:    in    string := "") is
      variable l:                line;
      constant padding:          std_ulogic_vector(1 to
                                                 (4-(received'length mod 4))) :=
                                    (others => '0');
   begin
      if not compare(received, expected) then
         write(l, now, right, 15);
         write(l, string'(" : ") & message & string'(" :"));
         write(l, string'(" received: "));
         if padding'length > 0 and padding'length < 4 then
            hwrite(l, std_logic_vector(padding) & std_logic_vector(received));
         else
            hwrite(l, std_logic_vector(received));
         end if;
         write(l, string'(" expected: "));
         if padding'length > 0 and padding'length < 4 then
            hwrite(l, std_logic_vector(padding) & std_logic_vector(expected));
         else
            hwrite(l, std_logic_vector(expected));
         end if;
         write(l, string'(" # error"));
         writeline(output, l);
         tp := false;
      end if;
   end procedure check;

   -----------------------------------------------------------------------------
   -- check natural
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    natural;
      constant expected:   in    natural;
      constant message:    in    string := "") is
      variable l:                line;
   begin
      if received /= expected then
         write(l, now, right, 15);
         write(l, string'(" : ") & message & string'(" :"));
         write(l, string'(" received: "));
         write(l, received);
         write(l, string'(" expected: "));
         write(l, expected);
         write(l, string'(" # error"));
         writeline(output, l);
         tp := false;
      end if;
   end procedure check;

   -----------------------------------------------------------------------------
   -- check time
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    time;
      constant expected:   in    time;
      constant spread:     in    time;
      constant message:    in    string := "") is
      variable l:                line;
   begin
      if (received > expected+spread) or
         (received < expected-spread) then
         write(l, now, right, 15);
         write(l, string'(" : ") & message & string'(" :"));
         write(l, string'(" received: "));
         write(l, received);
         write(l, string'(" expected: "));
         write(l, expected);
         write(l, string'(" # error"));
         writeline(output, l);
         tp := false;
      end if;
   end procedure check;

   -----------------------------------------------------------------------------
   -- check boolean
   -----------------------------------------------------------------------------
   procedure check(
      variable tp:         inout boolean;
      constant received:   in    boolean;
      constant expected:   in    boolean;
      constant message:    in    string := "") is
      variable l:                line;
   begin
      if received /= expected then
         write(l, now, right, 15);
         write(l, string'(" : ") & message & string'(" :"));
         write(l, string'(" received: "));
         write(l, received);
         write(l, string'(" expected: "));
         write(l, expected);
         write(l, string'(" # error"));
         writeline(output, l);
         tp := false;
      end if;
   end procedure check;

   -----------------------------------------------------------------------------
   -- Convert Data_Vector to Octet_Vector
   -----------------------------------------------------------------------------
   function conv_octet_vector(
      constant d:             in    data_vector)
      return                        octet_vector is
      variable o:                   octet_vector(0 to d'Length*4-1);
   begin
      for i in o'range loop
         o(i) := d(i/4)((3-(i mod 4))*8+7 downto (3-(i mod 4))*8);
      end loop;
      return o;
   end function conv_octet_vector;

  -----------------------------------------------------------------------------
   -- Convert Octet_Vector to Data_Vector, with padding
   -----------------------------------------------------------------------------
   function conv_data_vector(
      constant o:             in    octet_vector)
      return                        data_vector is
      variable d:                   data_vector(0 to (1+(o'Length-1)/4)-1);
   begin
      for i in o'Range loop
        d(i/4)((3-(i mod 4))*8+7 downto (3-(i mod 4))*8) := o(i);
      end loop;
      return d;
   end function conv_data_vector;  
   
  procedure compare(
    constant data:     in    octet_vector;
    constant cxdata:   in    octet_vector;
    variable tp:       inout boolean) is
  begin
    if (data'length /= cxdata'length) then
      tp := false;
      print("compare error: lengths do not match");
    else
      for i in data'low to data'low+data'length-1 loop
        if not compare(data(i), cxdata(i)) then
          tp := false;
          print("compare error. index: " & tost(i) & " data: " & tost(data(i)) & " expected: " & tost(cxdata(i)));
        end if;
      end loop;
    end if;
  end compare;

  function FromChar(C: Character) return Std_Logic_Vector is
      variable R:       Std_Logic_Vector(0 to 3);
   begin
      case C is
         when '0'    => R := "0000";
         when '1'    => R := "0001";
         when '2'    => R := "0010";
         when '3'    => R := "0011";
         when '4'    => R := "0100";
         when '5'    => R := "0101";
         when '6'    => R := "0110";
         when '7'    => R := "0111";
         when '8'    => R := "1000";
         when '9'    => R := "1001";

         when 'A'    => R := "1010";
         when 'B'    => R := "1011";
         when 'C'    => R := "1100";
         when 'D'    => R := "1101";
         when 'E'    => R := "1110";
         when 'F'    => R := "1111";

         when 'a'    => R := "1010";
         when 'b'    => R := "1011";
         when 'c'    => R := "1100";
         when 'd'    => R := "1101";
         when 'e'    => R := "1110";
         when 'f'    => R := "1111";
         when others => R := "XXXX";
      end case;
   return R;
   end FromChar; 
   
   procedure readfile(
     constant filename:      in    string := "";
     constant filetype:      in    integer := 0;
     constant size:          in    integer := 0;
     variable dataout:       out   octet_vector) is
     file     readfile:           text;
     variable l:                  line;
     variable test:               boolean := true;
     variable count:              integer := 0;
     variable dtmp:               std_logic_vector(31 downto 0);
     variable data:               octet_vector(0 to size-1);
     variable i:                  integer := 0;
     variable good:               boolean := true;
     variable c:                  character;
   begin
     if size /= 0 then
      if filename = "" then
        print("no file given");
      else
        if filetype = 0 then
          file_open(readfile, filename, read_mode);
          while not endfile(readfile) loop
            readline(readfile, l);
            hread(l, dtmp, test);
            if (not test) then
              print("illegal data in file");
              exit; 
            end if;
            for i in 0 to 3 loop
              data(count) := dtmp(31-i*8 downto 24-i*8);
              count := count + 1;
              if count >= size then
                exit;
              end if;
            end loop;
            if count >= size then
              exit; 
            end if;
          end loop;
          if count < size then
            print("not enough data in file");
          else
            for i in 0 to size-1 loop
              dataout(dataout'low+i) := data(i);
            end loop;
          end if;
        else
          file_open(readfile, filename, read_mode);
          while not endfile(readfile) loop
            readline(readfile, L);
            while (i < 4) loop
              Read(L, C, good);
              if not good then
                Print("Error in read data");
                exit;
              end if;
              if (C = character'val(32)) or (C = character'val(160)) or (C = HT) then
                next;
              else
                i := i + 1;
              end if;
            end loop;
            i := 0;
            while (i < 32) loop
              Read(L, C, good);
              if not good then
                Print("Error in read data");
                exit;
              end if;
              if (C = character'val(32)) or (C = character'val(160)) or (C = HT) then
                next;
              else
                if (i mod 2) = 0 then
                  data(count)(7 downto 4) := fromchar(C);
                else
                  data(count)(3 downto 0) := fromchar(C);
--                   Print(tost(data(count)));
                  count := count + 1;
                  if count >= size then
                    exit; 
                  end if;
                end if;
                i := i + 1;
              end if;
            end loop;
            i := 0;
          end loop;
          if count < size then
            Print("Not enough data in file");
          else
            dataout := data;
          end if;
        end if;
      end if;
    else
      print("size is zero. no data read");
    end if;
   end procedure;

   procedure readfile(
     constant filename:      in    string := "";
     constant size:          in    integer := 0;
     variable dataout:       out   octet_vector) is
   begin
     readfile(filename, 0, size, dataout);
   end procedure;
   
   procedure readfile(
     constant filename:      in    string := "";
     constant size:          in    integer := 0;
     variable dataout:       out   data_vector) is
     file     readfile:           text;
     variable l:                  line;
     variable test:               boolean := true;
     variable count:              integer := 0;
     variable data:               data_vector(0 to size/4);
   begin
     if size /= 0 then
      if filename = "" then
        print("no file given");
      else
        file_open(readfile, filename, read_mode);
        while not endfile(readfile) loop
          readline(readfile, l);
          hread(l, data(count/4), test);
          if (not test) then
            print("illegal data in file");
            exit; 
          end if;
          count := count + 4;
          if count >= size then
            exit; 
          end if;
        end loop;
        if count < size then
          print("not enough data in file");
        else
          if (size mod 4) = 0 then
            dataout(dataout'low to dataout'low+data'high-1) :=
              data(0 to data'high-1);
          else
            dataout(dataout'low to dataout'low+data'high) := data(0 to data'high);
          end if;
        end if;  
      end if;
    else
      print("size is zero. no data read");
    end if;
   end procedure;

   procedure gen_rand_int(
     constant max   : in    real;
     variable seed1 : inout positive;
     variable seed2 : inout positive;
     variable rand  : out   integer) is
     variable rand_tmp : real;
   begin
     uniform(seed1, seed2, rand_tmp);
     rand := integer(floor(rand_tmp*max));
   end procedure;
   
  function reverse(din : std_logic_vector)
    return std_logic_vector is
    variable dout: std_logic_vector(din'REVERSE_RANGE);
  begin
    for i in din'RANGE loop dout(i) := din(i); end loop;
    return dout; 
  end function reverse; 

   function ahb_doff (
     constant dw   : integer;
     constant size : integer;
     constant addr : std_logic_vector(4 downto 0))
     return integer is
     variable off : integer;
   begin  -- ahb_doff
     if size < 256 and dw = 256 and addr(4) = '0' then off := 128; else off := 0; end if;
     if size < 128 and dw >= 128 and addr(3) = '0' then off := off + 64; end if;
     if size < 64 and dw >= 64 and addr(2) = '0' then off := off + 32; end if;
     if size < 32 and addr(1) = '0' then off := off + 16; end if;
     if size < 16 and addr(0) = '0' then off := off + 8; end if;
     return off;
   end ahb_doff;
   
end package body ; --=======================================--
-- pragma translate_on

