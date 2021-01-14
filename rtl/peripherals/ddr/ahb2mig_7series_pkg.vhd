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
-- Package:     ah2mig_7series_pkg
-- File:        ah2mig_7series_pkg.vhd
-- Author:      Fredrik Ringhage - Aeroflex Gaisler
-- Description:	Components, types and functions for AHB2MIG 7-Series controller
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gencomp.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.config_types.all;
use work.config.all;

package ahb2mig_7series_pkg is

-------------------------------------------------------------------------------
-- AHB2MIG configuration
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- AHB2MIG interface type declarations and constant
-------------------------------------------------------------------------------

  type lpddr_out_t is record
    calib_done  : std_ulogic;
    ck_p        : std_logic;
    ck_n        : std_logic;
    cke         : std_logic;
    ba          : std_logic_vector(2 downto 0);
    addr        : std_logic_vector(15 downto 0);
    cs_n        : std_logic;
    ras_n       : std_logic;
    cas_n       : std_logic;
    we_n        : std_logic;
    reset_n     : std_logic;
    odt         : std_logic;
    dm_oen      : std_logic_vector(3 downto 0);
    dm          : std_logic_vector(3 downto 0);
    dqs_p_oen   : std_logic_vector(3 downto 0);
    dqs_p_ien   : std_logic_vector(3 downto 0);
    dqs_p_o     : std_logic_vector(3 downto 0);
    dqs_n_oen   : std_logic_vector(3 downto 0);
    dqs_n_ien   : std_logic_vector(3 downto 0);
    dqs_n_o     : std_logic_vector(3 downto 0);
    dq_oen      : std_logic_vector(31 downto 0);
    dq_o        : std_logic_vector(31 downto 0);
  end record lpddr_out_t;

  type lpddr_in_t is record
    dqs_p_i     : std_logic_vector(3 downto 0);
    dqs_n_i     : std_logic_vector(3 downto 0);
    dq_i        : std_logic_vector(31 downto 0);
  end record lpddr_in_t;

  type lpddr_out_vector is array (natural range <>) of lpddr_out_t;
  type lpddr_in_vector is array (natural range <>) of lpddr_in_t;

-------------------------------------------------------------------------------
-- AHB2MIG Subprograms
-------------------------------------------------------------------------------

 function nbrmaxmigcmds (
    datawidth : integer)
    return integer;

 function nbrmigcmds (
    hwrite    : std_logic;
    hsize     : std_logic_vector;
    htrans    : std_logic_vector;
    step      : unsigned;
    datawidth : integer)
    return integer;

 function nbrmigcmds16 (
    hwrite    : std_logic;
    hsize     : std_logic_vector;
    htrans    : std_logic_vector;
    step      : unsigned;
    datawidth : integer)
    return integer;

 function reversebyte (
    data : std_logic_vector)
    return std_logic_vector;

 function reversebytemig (
    data : std_logic_vector)
    return std_logic_vector;

  function ahbselectdatanoreplicastep (
    haddr : std_logic_vector(7 downto 2);
    hsize : std_logic_vector(2 downto 0)
    )
    return unsigned;

  -- Added in order to make it working for 16-bit memory (only with 32-bit bus)
  function ahbselectdatanoreplicastep16 (
    haddr : std_logic_vector(7 downto 2);
    hsize : std_logic_vector(2 downto 0)
    )
    return unsigned;

  function ahbselectdatanoreplicaoutput (
    haddr : std_logic_vector(7 downto 0);
    counter : unsigned(31 downto 0);
    hsize : std_logic_vector(2 downto 0);
    rdbuffer : unsigned;
    wr_count : unsigned;
    replica : boolean)
    return std_logic_vector;

  -- Added in order to make it working for 16-bit memory (only with 32-bit bus)
  function ahbselectdatanoreplicaoutput16 (
    haddr : std_logic_vector(7 downto 0);
    counter : unsigned(31 downto 0);
    hsize : std_logic_vector(2 downto 0);
    rdbuffer : unsigned;
    wr_count : unsigned;
    replica : boolean)
    return std_logic_vector;

  function ahbselectdatanoreplicamask (
    haddr : std_logic_vector(6 downto 0);
    hsize : std_logic_vector(2 downto 0))
    return std_logic_vector;

  function ahbselectdatanoreplica (hdata : std_logic_vector(AHBDW-1 downto 0);
    haddr : std_logic_vector(4 downto 0); hsize : std_logic_vector(2 downto 0))
    return std_logic_vector;

  function ahbdrivedatanoreplica (hdata : std_logic_vector) return std_logic_vector;

-------------------------------------------------------------------------------
-- AHB2MIG Components
-------------------------------------------------------------------------------

end;

package body ahb2mig_7series_pkg is

  -- Number of Max MIG commands
  function nbrmaxmigcmds(
  datawidth : integer)
  return integer is
  variable ret : integer;
  begin
     case datawidth is
     when 128 =>
        ret:= 4;
     when 64 =>
        ret := 2;
     when others =>
        ret := 2;
     end case;
    return ret;
  end function nbrmaxmigcmds;

  -- Number of MIG commands
  function nbrmigcmds(
  hwrite    : std_logic;
  hsize     : std_logic_vector;
  htrans    : std_logic_vector;
  step      : unsigned;
  datawidth : integer)
  return integer is
  variable ret : integer;
  begin
    if (hwrite = '0') then
       case datawidth is
       when 128 =>
          if (hsize = HSIZE_4WORD) then
             ret:= 4;
          elsif (hsize = HSIZE_DWORD) then
             ret := 2;
          elsif (hsize = HSIZE_WORD) then
             ret := 1;
          else
             ret := 1;
          end if;
       when 64 =>
          if (hsize = HSIZE_DWORD) then
             ret := 2;
          elsif (hsize = HSIZE_WORD) then
             ret := 2;
          else
             ret := 1;
          end if;
       -- 32
       when others =>
          if (hsize = HSIZE_WORD) then
             ret := 2;
          else
             ret := 1;
          end if;
       end case;

       if (htrans /= HTRANS_SEQ) then
          ret := 1;
       end if;


    else
      ret := to_integer(shift_right(step,4)) + 1;
    end if;

    return ret;
  end function nbrmigcmds;

  function nbrmigcmds16(
  hwrite    : std_logic;
  hsize     : std_logic_vector;
  htrans    : std_logic_vector;
  step      : unsigned;
  datawidth : integer)
  return integer is
  variable ret : integer;
  begin
    if (hwrite = '0') then
      if (hsize = HSIZE_WORD) then
        ret := 2;
      else
        ret := 1;
      end if;

      if (htrans /= HTRANS_SEQ) then
        ret := 1;
      end if;
    else
       ret := to_integer(shift_right(step,2)) + 1;
    end if;

    return ret;
  end function nbrmigcmds16;

  -- Reverses byte order.
  function reversebyte(
    data : std_logic_vector)
    return std_logic_vector is
    variable rdata: std_logic_vector(data'length-1 downto 0);
  begin
    for i in 0 to (data'length/8-1) loop
      rdata(i*8+8-1 downto i*8) := data(data'length-i*8-1 downto data'length-i*8-8);
    end loop;
    return rdata;
  end function reversebyte;

  -- Reverses byte order.
  function reversebytemig(
    data : std_logic_vector)
    return std_logic_vector is
    variable rdata: std_logic_vector(data'length-1 downto 0);
  begin
    for i in 0 to (data'length/8-1) loop
      rdata(i*8+8-1 downto i*8) := data(data'left-i*8 downto data'left-i*8-7);
    end loop;
    return rdata;
  end function reversebytemig;


 -- Takes in AHB data vector 'hdata' and returns valid data on the full
  -- data vector output based on 'haddr' and 'hsize' inputs together with
  -- GRLIB AHB bus width. The function works down to word granularity.
  function ahbselectdatanoreplica (
    hdata : std_logic_vector(AHBDW-1 downto 0);
    haddr : std_logic_vector(4 downto 0);
    hsize : std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable ret   : std_logic_vector(AHBDW-1 downto 0);
  begin  -- ahbselectdatanoreplica

    ret := (others => '0');

    case hsize is

    when HSIZE_4WORD =>
        ret(AHBDW-1 downto 0) := reversebytemig(hdata(AHBDW-1 downto 0));

    when HSIZE_DWORD =>
      if AHBDW = 128 then
        case haddr(3) is
          when '0' =>    ret(AHBDW/2-1 downto 0) := reversebytemig(hdata(AHBDW-1 downto AHBDW/2));
          when others => ret(AHBDW/2-1 downto 0) := reversebytemig(hdata(AHBDW/2-1 downto 0));
        end case;
      elsif AHBDW = 64 then
        ret(AHBDW-1 downto 0) := reversebytemig(hdata(AHBDW-1 downto 0));
      end if;

    when HSIZE_WORD =>
      if AHBDW = 128 then
        case haddr(3 downto 2) is
          when "00" =>   ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)) := reversebytemig(hdata(4*(AHBDW/4)-1 downto 3*(AHBDW/4)));
          when "01" =>   ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)) := reversebytemig(hdata(3*(AHBDW/4)-1 downto 2*(AHBDW/4)));
          when "10" =>   ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)) := reversebytemig(hdata(2*(AHBDW/4)-1 downto 1*(AHBDW/4)));
          when others => ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)) := reversebytemig(hdata(1*(AHBDW/4)-1 downto 0*(AHBDW/4)));
        end case;
      elsif AHBDW = 64 then
        case haddr(2) is
          when '0' =>    ret(AHBDW/2-1 downto 0) := reversebytemig(hdata(AHBDW-1 downto AHBDW/2));
          when others => ret(AHBDW/2-1 downto 0) := reversebytemig(hdata(AHBDW/2-1 downto 0));
        end case;
      elsif AHBDW = 32 then
        ret(AHBDW-1 downto 0) := reversebytemig(hdata(AHBDW-1 downto 0));
      end if;

    when HSIZE_HWORD =>
      if AHBDW = 128 then
        case haddr(3 downto 1) is
          when "000"  => ret(1*(AHBDW/8)-1 downto 0*(AHBDW/8))  := reversebytemig(hdata(8*(AHBDW/8)-1 downto 7*(AHBDW/8)));
          when "001"  => ret(2*(AHBDW/8)-1 downto 1*(AHBDW/8))  := reversebytemig(hdata(7*(AHBDW/8)-1 downto 6*(AHBDW/8)));
          when "010"  => ret(1*(AHBDW/8)-1 downto 0*(AHBDW/8))  := reversebytemig(hdata(6*(AHBDW/8)-1 downto 5*(AHBDW/8)));
          when "011"  => ret(2*(AHBDW/8)-1 downto 1*(AHBDW/8))  := reversebytemig(hdata(5*(AHBDW/8)-1 downto 4*(AHBDW/8)));
          when "100"  => ret(1*(AHBDW/8)-1 downto 0*(AHBDW/8))  := reversebytemig(hdata(4*(AHBDW/8)-1 downto 3*(AHBDW/8)));
          when "101"  => ret(2*(AHBDW/8)-1 downto 1*(AHBDW/8))  := reversebytemig(hdata(3*(AHBDW/8)-1 downto 2*(AHBDW/8)));
          when "110"  => ret(1*(AHBDW/8)-1 downto 0*(AHBDW/8))  := reversebytemig(hdata(2*(AHBDW/8)-1 downto 1*(AHBDW/8)));
          when others => ret(2*(AHBDW/8)-1 downto 1*(AHBDW/8))  := reversebytemig(hdata(1*(AHBDW/8)-1 downto 0*(AHBDW/8)));
        end case;
      elsif AHBDW = 64 then
        case haddr(2 downto 1) is
          when "00" =>   ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)) := reversebytemig(hdata(4*(AHBDW/4)-1 downto 3*(AHBDW/4)));
          when "01" =>   ret(2*(AHBDW/4)-1 downto 1*(AHBDW/4)) := reversebytemig(hdata(3*(AHBDW/4)-1 downto 2*(AHBDW/4)));
          when "10" =>   ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)) := reversebytemig(hdata(2*(AHBDW/4)-1 downto 1*(AHBDW/4)));
          when others => ret(2*(AHBDW/4)-1 downto 1*(AHBDW/4)) := reversebytemig(hdata(1*(AHBDW/4)-1 downto 0*(AHBDW/4)));
        end case;
      elsif AHBDW = 32 then
        case haddr(1) is
          when '0' =>    ret(AHBDW/2-1 downto 0)       := reversebytemig(hdata(AHBDW-1 downto AHBDW/2));
          when others => ret(AHBDW-1   downto AHBDW/2) := reversebytemig(hdata(AHBDW/2-1 downto 0));
        end case;
      end if;
    -- HSIZE_BYTE
    when others =>
      if AHBDW = 128 then
        case haddr(3 downto 0) is
          when "0000" => ret( 1*(AHBDW/16)-1 downto  0*(AHBDW/16)) := hdata(16*(AHBDW/16)-1 downto 15*(AHBDW/16));
          when "0001" => ret( 2*(AHBDW/16)-1 downto  1*(AHBDW/16)) := hdata(15*(AHBDW/16)-1 downto 14*(AHBDW/16));
          when "0010" => ret( 3*(AHBDW/16)-1 downto  2*(AHBDW/16)) := hdata(14*(AHBDW/16)-1 downto 13*(AHBDW/16));
          when "0011" => ret( 4*(AHBDW/16)-1 downto  3*(AHBDW/16)) := hdata(13*(AHBDW/16)-1 downto 12*(AHBDW/16));
          when "0100" => ret( 1*(AHBDW/16)-1 downto  0*(AHBDW/16)) := hdata(12*(AHBDW/16)-1 downto 11*(AHBDW/16));
          when "0101" => ret( 2*(AHBDW/16)-1 downto  1*(AHBDW/16)) := hdata(11*(AHBDW/16)-1 downto 10*(AHBDW/16));
          when "0110" => ret( 3*(AHBDW/16)-1 downto  2*(AHBDW/16)) := hdata(10*(AHBDW/16)-1 downto  9*(AHBDW/16));
          when "0111" => ret( 4*(AHBDW/16)-1 downto  3*(AHBDW/16)) := hdata( 9*(AHBDW/16)-1 downto  8*(AHBDW/16));
          when "1000" => ret( 1*(AHBDW/16)-1 downto  0*(AHBDW/16)) := hdata( 8*(AHBDW/16)-1 downto  7*(AHBDW/16));
          when "1001" => ret( 2*(AHBDW/16)-1 downto  1*(AHBDW/16)) := hdata( 7*(AHBDW/16)-1 downto  6*(AHBDW/16));
          when "1010" => ret( 3*(AHBDW/16)-1 downto  2*(AHBDW/16)) := hdata( 6*(AHBDW/16)-1 downto  5*(AHBDW/16));
          when "1011" => ret( 4*(AHBDW/16)-1 downto  3*(AHBDW/16)) := hdata( 5*(AHBDW/16)-1 downto  4*(AHBDW/16));
          when "1100" => ret( 1*(AHBDW/16)-1 downto  0*(AHBDW/16)) := hdata( 4*(AHBDW/16)-1 downto  3*(AHBDW/16));
          when "1101" => ret( 2*(AHBDW/16)-1 downto  1*(AHBDW/16)) := hdata( 3*(AHBDW/16)-1 downto  2*(AHBDW/16));
          when "1110" => ret( 3*(AHBDW/16)-1 downto  2*(AHBDW/16)) := hdata( 2*(AHBDW/16)-1 downto  1*(AHBDW/16));
          when others => ret( 4*(AHBDW/16)-1 downto  3*(AHBDW/16)) := hdata( 1*(AHBDW/16)-1 downto  0*(AHBDW/16));
        end case;
      elsif AHBDW = 64 then
        case haddr(2 downto 0) is
          when "000"  => ret(1*(AHBDW/8)-1 downto 0*(AHBDW/8))  := hdata(8*(AHBDW/8)-1 downto 7*(AHBDW/8));
          when "001"  => ret(2*(AHBDW/8)-1 downto 1*(AHBDW/8))  := hdata(7*(AHBDW/8)-1 downto 6*(AHBDW/8));
          when "010"  => ret(3*(AHBDW/8)-1 downto 2*(AHBDW/8))  := hdata(6*(AHBDW/8)-1 downto 5*(AHBDW/8));
          when "011"  => ret(4*(AHBDW/8)-1 downto 3*(AHBDW/8))  := hdata(5*(AHBDW/8)-1 downto 4*(AHBDW/8));
          when "100"  => ret(1*(AHBDW/8)-1 downto 0*(AHBDW/8))  := hdata(4*(AHBDW/8)-1 downto 3*(AHBDW/8));
          when "101"  => ret(2*(AHBDW/8)-1 downto 1*(AHBDW/8))  := hdata(3*(AHBDW/8)-1 downto 2*(AHBDW/8));
          when "110"  => ret(3*(AHBDW/8)-1 downto 2*(AHBDW/8))  := hdata(2*(AHBDW/8)-1 downto 1*(AHBDW/8));
          when others => ret(4*(AHBDW/8)-1 downto 3*(AHBDW/8))  := hdata(1*(AHBDW/8)-1 downto 0*(AHBDW/8));
        end case;
      elsif AHBDW = 32 then
        case haddr(1 downto 0) is
          when "00" =>   ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)) := hdata(4*(AHBDW/4)-1 downto 3*(AHBDW/4));
          when "01" =>   ret(2*(AHBDW/4)-1 downto 1*(AHBDW/4)) := hdata(3*(AHBDW/4)-1 downto 2*(AHBDW/4));
          when "10" =>   ret(3*(AHBDW/4)-1 downto 2*(AHBDW/4)) := hdata(2*(AHBDW/4)-1 downto 1*(AHBDW/4));
          when others => ret(4*(AHBDW/4)-1 downto 3*(AHBDW/4)) := hdata(1*(AHBDW/4)-1 downto 0*(AHBDW/4));
        end case;
      end if;
    end case;

    return ret;
  end ahbselectdatanoreplica;

  function ahbselectdatanoreplicastep (
    haddr : std_logic_vector(7 downto 2);
    hsize : std_logic_vector(2 downto 0))
    return unsigned is
    variable ret   : unsigned(31 downto 0);
  begin  -- ahbselectdatanoreplicastep

    ret := (others => '0');

    case AHBDW is

    when 128 =>
       if (hsize = HSIZE_4WORD) then
          ret := resize(unsigned(haddr(5 downto 2)),ret'length);
       elsif (hsize = HSIZE_DWORD) then
          ret := resize(unsigned(haddr(5 downto 2)),ret'length);
       else
          ret := resize(unsigned(haddr(5 downto 2)),ret'length);
       end if;
    when 64 =>
       if (hsize = HSIZE_DWORD) then
          ret := resize(unsigned(haddr(5 downto 2)),ret'length);
       else
          ret := resize(unsigned(haddr(5 downto 2)),ret'length);
       end if;
    -- 32
    when others =>
       ret := resize(unsigned(haddr(5 downto 2)),ret'length);

    end case;

    return ret;
  end ahbselectdatanoreplicastep;

  function ahbselectdatanoreplicastep16 (
    haddr : std_logic_vector(7 downto 2);
    hsize : std_logic_vector(2 downto 0))
    return unsigned is
    variable ret   : unsigned(31 downto 0);
  begin  -- ahbselectdatanoreplicastep

    ret := resize(unsigned(haddr(3 downto 2)),ret'length);

    return ret;
  end ahbselectdatanoreplicastep16;

  function ahbselectdatanoreplicamask (
    haddr : std_logic_vector(6 downto 0);
    hsize : std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable ret   : std_logic_vector(AHBDW/4-1 downto 0);
    variable ret128   : std_logic_vector(128/4-1 downto 0);
  begin  -- ahbselectdatanoreplicamask

    ret := (others => '0');
    ret128 := (others => '0');

    case hsize is

    when HSIZE_4WORD =>
       ret(AHBDW/8-1 downto 0) := (others => '1');

    when HSIZE_DWORD =>
      if AHBDW = 128 then
        case haddr(3) is
          when '0' =>    ret(AHBDW/8/2-1 downto 0) := (others => '1');
          when others => ret(AHBDW/8/2-1 downto 0) := (others => '1');
        end case;
      else
        ret(AHBDW/8-1 downto 0) := (others => '1');
      end if;

    when HSIZE_WORD =>
      if AHBDW = 128 then
        case haddr(3 downto 2) is
          when "00" =>   ret(1*(AHBDW/8/4)-1 downto 0*(AHBDW/8/4)) := (others => '1');
          when "01" =>   ret(1*(AHBDW/8/4)-1 downto 0*(AHBDW/8/4)) := (others => '1');
          when "10" =>   ret(1*(AHBDW/8/4)-1 downto 0*(AHBDW/8/4)) := (others => '1');
          when others => ret(1*(AHBDW/8/4)-1 downto 0*(AHBDW/8/4)) := (others => '1');
        end case;
      elsif AHBDW = 64 then
        case haddr(2) is
          when '0' =>    ret(AHBDW/8/2-1 downto   0) := (others => '1');
          when others => ret(AHBDW/8/2-1 downto   0) := (others => '1');
        end case;
      elsif AHBDW = 32 then
        ret(AHBDW/8-1 downto 0) := (others => '1');
      end if;

    when HSIZE_HWORD =>
      if AHBDW = 128 then
        case haddr(3 downto 1) is
          when "000"  => ret128(1*(128/8/8)-1 downto 0*(128/8/8)) :=  (others => '1');
          when "001"  => ret128(2*(128/8/8)-1 downto 1*(128/8/8)) :=  (others => '1');
          when "010"  => ret128(1*(128/8/8)-1 downto 0*(128/8/8)) :=  (others => '1');
          when "011"  => ret128(2*(128/8/8)-1 downto 1*(128/8/8)) :=  (others => '1');
          when "100"  => ret128(1*(128/8/8)-1 downto 0*(128/8/8)) :=  (others => '1');
          when "101"  => ret128(2*(128/8/8)-1 downto 1*(128/8/8)) :=  (others => '1');
          when "110"  => ret128(1*(128/8/8)-1 downto 0*(128/8/8)) :=  (others => '1');
          when others => ret128(2*(128/8/8)-1 downto 1*(128/8/8)) :=  (others => '1');
        end case;
        ret := std_logic_vector(resize(unsigned(ret128),ret'length));
      elsif AHBDW = 64 then
        case haddr(2 downto 1) is
          when "00" =>   ret(1*(AHBDW/8/4)-1 downto 0*(AHBDW/8/4)) := (others => '1');
          when "01" =>   ret(2*(AHBDW/8/4)-1 downto 1*(AHBDW/8/4)) := (others => '1');
          when "10" =>   ret(1*(AHBDW/8/4)-1 downto 0*(AHBDW/8/4)) := (others => '1');
          when others => ret(2*(AHBDW/8/4)-1 downto 1*(AHBDW/8/4)) := (others => '1');
        end case;
      elsif AHBDW = 32 then
        case haddr(1) is
          when '0' =>    ret(AHBDW/8/2-1 downto 0)         := (others => '1');
          when others => ret(AHBDW/8-1   downto AHBDW/8/2) := (others => '1');
        end case;
      end if;

    -- HSIZE_BYTE
    when others =>
      if AHBDW = 128 then
        case haddr(3 downto 0) is
          when "0000" => ret( 0)  := '1';
          when "0001" => ret( 1)  := '1';
          when "0010" => ret( 2)  := '1';
          when "0011" => ret( 3)  := '1';
          when "0100" => ret( 0)  := '1';
          when "0101" => ret( 1)  := '1';
          when "0110" => ret( 2)  := '1';
          when "0111" => ret( 3)  := '1';
          when "1000" => ret( 0)  := '1';
          when "1001" => ret( 1)  := '1';
          when "1010" => ret( 2)  := '1';
          when "1011" => ret( 3)  := '1';
          when "1100" => ret( 0)  := '1';
          when "1101" => ret( 1)  := '1';
          when "1110" => ret( 2)  := '1';
          when others => ret( 3)  := '1';
        end case;
      elsif AHBDW = 64 then
        case haddr(2 downto 0) is
          when "000"  => ret(0)  := '1';
          when "001"  => ret(1)  := '1';
          when "010"  => ret(2)  := '1';
          when "011"  => ret(3)  := '1';
          when "100"  => ret(0)  := '1';
          when "101"  => ret(1)  := '1';
          when "110"  => ret(2)  := '1';
          when others => ret(3)  := '1';
        end case;
      elsif AHBDW = 32 then
        case haddr(1 downto 0) is
          when "00" =>   ret(0) := '1';
          when "01" =>   ret(1) := '1';
          when "10" =>   ret(2) := '1';
          when others => ret(3) := '1';
        end case;
      end if;
    end case;
    return ret;
  end ahbselectdatanoreplicamask;

  function ahbselectdatanoreplicaoutput (
    haddr : std_logic_vector(7 downto 0);
    counter : unsigned(31 downto 0);
    hsize : std_logic_vector(2 downto 0);
    rdbuffer : unsigned;
    wr_count : unsigned;
    replica : boolean)
    return std_logic_vector is
    variable ret   : std_logic_vector(AHBDW-1 downto 0);
    variable retrep   : std_logic_vector(AHBDW-1 downto 0);
    variable rdbuffer_int : unsigned(AHBDW-1 downto 0);
    variable hdata : std_logic_vector(AHBDW-1 downto 0);
    variable offset : unsigned(31 downto 0);
    variable steps : unsigned(31 downto 0);
    variable stepsint : natural;
    variable hstart_offset : unsigned(31 downto 0);
    
    variable byteOffset   : unsigned(31 downto 0);
    variable rdbufferByte : unsigned(AHBDW-1 downto 0);
    variable hdataByte    : std_logic_vector(AHBDW-1 downto 0);
    
  begin  -- ahbselectdatanoreplicaoutput

    ret := (others => '0');

    --hstart_offset := (others => '0');
    --synopsys synthesis_off
    --Print("INFO: HADDR " & tost(haddr));
    --Print("INFO: hsize " & tost(hsize));
    --synopsys synthesis_on
  
    --byteOffset := shift_left( resize(unsigned(haddr(5 downto 0)),byteOffset'length) ,3);
    --rdbufferByte := resize(shift_right(rdbuffer,to_integer(byteOffset)),rdbufferByte'length);
    --hdataByte := std_logic_vector(rdbufferByte(AHBDW-1 downto 0));
    
    --Print("INFO: **> byteOffset " & tost(to_integer(byteOffset)));
    --Print("INFO: **> hdataByte " & tost(hdataByte));

    case hsize is
       when HSIZE_4WORD =>
            offset := resize((unsigned(haddr(5 downto 4))&"0000000"),offset'length);
            steps := resize(unsigned(wr_count(wr_count'length-1 downto 0)&"0000000"),steps'length) + offset;
            hstart_offset := (others => '0');
       when HSIZE_DWORD =>
         if AHBDW = 128 then
            offset := resize((unsigned(haddr(5 downto 4))&"0000000"),offset'length);
            steps := resize(unsigned(wr_count(wr_count'length-1 downto 0)&"000000"),steps'length) + offset;
            hstart_offset := shift_left( resize(unsigned(haddr(3 downto 3)),hstart_offset'length) ,5);
         elsif AHBDW = 64 then
            offset := resize((unsigned(haddr(5 downto 3))&"000000"),offset'length);
            steps := resize(unsigned(wr_count(wr_count'length-1 downto 0)&"000000"),steps'length) + offset;
            hstart_offset := (others => '0');
         end if;
       when others =>
         if AHBDW = 128 then
            offset := resize((unsigned(haddr(5 downto 4))&"0000000"),offset'length);
            steps := resize(unsigned(wr_count(wr_count'length-1 downto 0)&"00000"),steps'length) + offset;
            hstart_offset := shift_left( resize(unsigned(haddr(3 downto 2)),hstart_offset'length) ,5);
         elsif AHBDW = 64 then
            offset := resize((unsigned(haddr(5 downto 3))&"000000"),offset'length);
            steps := resize(unsigned(wr_count(wr_count'length-1 downto 0)&"00000"),steps'length) + offset;
            hstart_offset := shift_left( resize(unsigned(haddr(2 downto 2)),hstart_offset'length) ,5);
         elsif AHBDW = 32 then
            offset := resize((unsigned(haddr(5 downto 2))&"00000"),offset'length);
            steps := resize(unsigned(wr_count(wr_count'length-1 downto 0)&"00000"),steps'length) + offset;
            hstart_offset := (others => '0');
         end if;
    end case;

    --synopsys synthesis_off
    --Print("INFO: wr_count " & tost(to_integer(wr_count)));
    --Print("INFO: offset " & tost(to_integer(offset)));
    --Print("INFO: steps " & tost(to_integer(steps)));
    --Print("INFO: hstart_offset " & tost(to_integer(hstart_offset)));
    --synopsys synthesis_on
    stepsint := to_integer(steps) + to_integer(hstart_offset);

    --synopsys synthesis_off
    --Print("INFO: ------> stepsint" & tost(stepsint));
    --synopsys synthesis_on

    rdbuffer_int := resize(shift_right(rdbuffer,stepsint),rdbuffer_int'length);
    hdata := std_logic_vector(rdbuffer_int(AHBDW-1 downto 0));

    --synopsys synthesis_off
    --Print("INFO: rdbuffer_int " & tost( std_logic_vector(rdbuffer(511 downto 0))));
    --Print("INFO: rdbuffer_int " & tost( std_logic_vector(rdbuffer(1023 downto 512))));
    --Print("INFO: hdata " & tost(hdata));
    --synopsys synthesis_on
 
    ret(AHBDW-1 downto 0) := reversebyte(hdata);

    --synopsys synthesis_off
    --Print("INFO: ret " & tost(ret));
    --synopsys synthesis_on

    case hsize is
        when HSIZE_4WORD =>
          offset := resize(unsigned(haddr) + unsigned(counter&"0000" - hstart_offset),offset'length);
        when HSIZE_DWORD =>
          offset := resize(unsigned(haddr) + unsigned(counter&"000" - hstart_offset),offset'length);
        when others =>
          offset := resize(unsigned(haddr) + unsigned(counter&"00" - hstart_offset),offset'length);
    end case;

    if (replica = true) then
    case hsize is
       when HSIZE_4WORD =>
          retrep := ahbdrivedata(ret(AHBDW-1 downto 0));
       when HSIZE_DWORD =>
         if AHBDW = 128 then
           if offset(3) = '0' then retrep := ahbdrivedata(ret(AHBDW-1 downto AHBDW/2));
           else retrep := ahbdrivedata(ret(AHBDW/2-1 downto 0)); end if;
         else
            retrep := ahbdrivedata(ret(AHBDW-1 downto 0));
         end if;
       when HSIZE_WORD =>
         if AHBDW = 128 then
           case offset(3 downto 2) is
             when "00" =>   retrep := ahbdrivedata(ret(4*(AHBDW/4)-1 downto 3*(AHBDW/4)));
             when "01" =>   retrep := ahbdrivedata(ret(3*(AHBDW/4)-1 downto 2*(AHBDW/4)));
             when "10" =>   retrep := ahbdrivedata(ret(2*(AHBDW/4)-1 downto 1*(AHBDW/4)));
             when others => retrep := ahbdrivedata(ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)));
           end case;
         elsif AHBDW = 64 then
           if offset(2) = '0' then retrep := ahbdrivedata(ret(AHBDW-1 downto AHBDW/2));
           else retrep := ahbdrivedata(ret(AHBDW/2-1 downto 0)); end if;
           
           if (wr_count > 0) then 
             retrep := ahbdrivedata(ret(AHBDW-1 downto AHBDW/2));
           end if;
           
           retrep := ahbdrivedata(ret(AHBDW-1 downto AHBDW/2));
         else
            retrep := ahbdrivedata(ret(AHBDW-1 downto 0));
         end if;
       when HSIZE_HWORD =>
         if AHBDW = 128 then
           case offset(3 downto 1) is
             when "000" =>   retrep := ahbdrivedata(ret(8*(AHBDW/8)-1 downto 7*(AHBDW/8)));
             when "001" =>   retrep := ahbdrivedata(ret(7*(AHBDW/8)-1 downto 6*(AHBDW/8)));
             when "010" =>   retrep := ahbdrivedata(ret(6*(AHBDW/8)-1 downto 5*(AHBDW/8)));
             when "011" =>   retrep := ahbdrivedata(ret(5*(AHBDW/8)-1 downto 4*(AHBDW/8)));
             when "100" =>   retrep := ahbdrivedata(ret(4*(AHBDW/8)-1 downto 3*(AHBDW/8)));
             when "101" =>   retrep := ahbdrivedata(ret(3*(AHBDW/8)-1 downto 2*(AHBDW/8)));
             when "110" =>   retrep := ahbdrivedata(ret(2*(AHBDW/8)-1 downto 1*(AHBDW/8)));
             when others =>  retrep := ahbdrivedata(ret(1*(AHBDW/8)-1 downto 0*(AHBDW/8)));
           end case;
         elsif AHBDW = 64 then
           case offset(1) is
             when '0' =>   retrep := ahbdrivedata(ret(4*(AHBDW/4)-1 downto 3*(AHBDW/4)));
             when others =>   retrep := ahbdrivedata(ret(3*(AHBDW/4)-1 downto 2*(AHBDW/4)));
--             when "10" =>   retrep := ahbdrivedata(ret(2*(AHBDW/4)-1 downto 1*(AHBDW/4)));
--             when others => retrep := ahbdrivedata(ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)));
           end case;
         else
           if offset(1) = '0' then retrep := ahbdrivedata(ret(AHBDW-1 downto AHBDW/2));
           else retrep := ahbdrivedata(ret(AHBDW/2-1 downto 0)); end if;
         end if;
       -- HSIZE_BYTE
       when others =>
         if AHBDW = 128 then
           case offset(2 downto 0) is
             when "000" =>   retrep := ahbdrivedata(ret(16*(AHBDW/16)-1 downto 15*(AHBDW/16)));
             when "001" =>   retrep := ahbdrivedata(ret(15*(AHBDW/16)-1 downto 14*(AHBDW/16)));
             when "010" =>   retrep := ahbdrivedata(ret(14*(AHBDW/16)-1 downto 13*(AHBDW/16)));
             when "011" =>   retrep := ahbdrivedata(ret(13*(AHBDW/16)-1 downto 12*(AHBDW/16)));
             when "100" =>   retrep := ahbdrivedata(ret(12*(AHBDW/16)-1 downto 11*(AHBDW/16)));
             when "101" =>   retrep := ahbdrivedata(ret(11*(AHBDW/16)-1 downto 10*(AHBDW/16)));
             when "110" =>   retrep := ahbdrivedata(ret(10*(AHBDW/16)-1 downto  9*(AHBDW/16)));
             when others  =>   retrep := ahbdrivedata(ret( 9*(AHBDW/16)-1 downto  8*(AHBDW/16)));
           end case;
         elsif AHBDW = 64 then
           case offset(1 downto 0) is
             when "00" =>   retrep := ahbdrivedata(ret(8*(AHBDW/8)-1 downto 7*(AHBDW/8)));
             when "01" =>   retrep := ahbdrivedata(ret(7*(AHBDW/8)-1 downto 6*(AHBDW/8)));
             when "10" =>   retrep := ahbdrivedata(ret(6*(AHBDW/8)-1 downto 5*(AHBDW/8)));
             when others =>   retrep := ahbdrivedata(ret(5*(AHBDW/8)-1 downto 4*(AHBDW/8)));
           end case;
         else
           case offset(1 downto 0) is
             when "00" =>   retrep := ahbdrivedata(ret(4*(AHBDW/4)-1 downto 3*(AHBDW/4)));
             when "01" =>   retrep := ahbdrivedata(ret(3*(AHBDW/4)-1 downto 2*(AHBDW/4)));
             when "10" =>   retrep := ahbdrivedata(ret(2*(AHBDW/4)-1 downto 1*(AHBDW/4)));
             when others => retrep := ahbdrivedata(ret(1*(AHBDW/4)-1 downto 0*(AHBDW/4)));
           end case;
         end if;
       end case;

       --synopsys synthesis_off
       -- Print("INFO: retrep " & tost(retrep));
       --synopsys synthesis_on

       --ret := ahbdrivedatamig(retrep);
       ret :=retrep;
    end if;


    return ret;
  end ahbselectdatanoreplicaoutput;

  function ahbselectdatanoreplicaoutput16 (
    haddr : std_logic_vector(7 downto 0);
    counter : unsigned(31 downto 0);
    hsize : std_logic_vector(2 downto 0);
    rdbuffer : unsigned;
    wr_count : unsigned;
    replica : boolean)
    return std_logic_vector is
    variable ret   : std_logic_vector(AHBDW-1 downto 0);
    variable retrep   : std_logic_vector(AHBDW-1 downto 0);
    variable rdbuffer_int : unsigned(AHBDW-1 downto 0);
    variable hdata : std_logic_vector(AHBDW-1 downto 0);
    variable offset : unsigned(31 downto 0);
    variable steps : unsigned(31 downto 0);
    variable stepsint : natural;

    variable hstart_offset : unsigned(31 downto 0);
    
    variable byteOffset   : unsigned(31 downto 0);
    variable rdbufferByte : unsigned(AHBDW-1 downto 0);
    variable hdataByte    : std_logic_vector(AHBDW-1 downto 0);
    
  begin  -- ahbselectdatanoreplicaoutput16

    ret := (others => '0');

    offset := resize((unsigned(haddr(3 downto 2))&"00000"),offset'length);
    steps := resize(unsigned(wr_count(wr_count'length-1 downto 0)&"00000"),steps'length) + offset;
    hstart_offset := (others => '0');

    stepsint := to_integer(steps) + to_integer(hstart_offset);

    rdbuffer_int := resize(shift_right(rdbuffer,stepsint),rdbuffer_int'length);
    hdata := std_logic_vector(rdbuffer_int(AHBDW-1 downto 0));

    ret(AHBDW-1 downto 0) := reversebyte(hdata);

    offset := resize(unsigned(haddr) + unsigned(counter&"00" - hstart_offset),offset'length);

    return ret;
  end ahbselectdatanoreplicaoutput16;

  -- purpose: extends 'hdata' to suite AHB data width. If the input vector's
  -- length exceeds AHBDW the low part is returned.
  function ahbdrivedatanoreplica (
    hdata : std_logic_vector)
    return std_logic_vector is
    variable data : std_logic_vector(AHBDW-1 downto 0);
  begin  -- ahbdrivedatanoreplica
    if AHBDW < hdata'length then
      data := hdata(AHBDW+hdata'low-1 downto hdata'low);
    else
      data := (others => '0');
      data(hdata'length-1 downto 0) := hdata;
    end if;
    return data;
  end ahbdrivedatanoreplica;

end;

