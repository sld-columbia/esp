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
-- Entity: 	system_monitor
-- File:	system_monitor.vhd
-- Author:	Jan Andersson, Jiri Gaisler - Gaisler Research
-- Description:	System monitor wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity system_monitor is
  
  generic (
    -- GRLIB generics
    tech    : integer    := DEFFABTECH;
    -- Virtex 5 SYSMON generics
    INIT_40 : bit_vector := X"0000";
    INIT_41 : bit_vector := X"0000";
    INIT_42 : bit_vector := X"0800";
    INIT_43 : bit_vector := X"0000";
    INIT_44 : bit_vector := X"0000";
    INIT_45 : bit_vector := X"0000";
    INIT_46 : bit_vector := X"0000";
    INIT_47 : bit_vector := X"0000";
    INIT_48 : bit_vector := X"0000";
    INIT_49 : bit_vector := X"0000";
    INIT_4A : bit_vector := X"0000";
    INIT_4B : bit_vector := X"0000";
    INIT_4C : bit_vector := X"0000";
    INIT_4D : bit_vector := X"0000";
    INIT_4E : bit_vector := X"0000";
    INIT_4F : bit_vector := X"0000";
    INIT_50 : bit_vector := X"0000";
    INIT_51 : bit_vector := X"0000";
    INIT_52 : bit_vector := X"0000";
    INIT_53 : bit_vector := X"0000";
    INIT_54 : bit_vector := X"0000";
    INIT_55 : bit_vector := X"0000";
    INIT_56 : bit_vector := X"0000";
    INIT_57 : bit_vector := X"0000";
    SIM_MONITOR_FILE : string := "design.txt");
  
  port (
    alm          : out std_logic_vector(2 downto 0);
    busy         : out std_ulogic;
    channel      : out std_logic_vector(4 downto 0);
    do           : out std_logic_vector(15 downto 0);
    drdy         : out std_ulogic;
    eoc          : out std_ulogic;
    eos          : out std_ulogic;
    jtagbusy     : out std_ulogic;
    jtaglocked   : out std_ulogic;
    jtagmodified : out std_ulogic;
    ot           : out std_ulogic;
    convst       : in std_ulogic;
    convstclk    : in std_ulogic;
    daddr        : in std_logic_vector(6 downto 0);
    dclk         : in std_ulogic;
    den          : in std_ulogic;
    di           : in std_logic_vector(15 downto 0);
    dwe          : in std_ulogic;
    reset        : in std_ulogic;
    vauxn        : in std_logic_vector(15 downto 0);
    vauxp        : in std_logic_vector(15 downto 0);
    vn           : in std_ulogic;
    vp           : in std_ulogic);
end system_monitor;

architecture struct of system_monitor is

  component sysmon_virtex5
    generic (
      INIT_40 : bit_vector := X"0000";
      INIT_41 : bit_vector := X"0000";
      INIT_42 : bit_vector := X"0800";
      INIT_43 : bit_vector := X"0000";
      INIT_44 : bit_vector := X"0000";
      INIT_45 : bit_vector := X"0000";
      INIT_46 : bit_vector := X"0000";
      INIT_47 : bit_vector := X"0000";
      INIT_48 : bit_vector := X"0000";
      INIT_49 : bit_vector := X"0000";
      INIT_4A : bit_vector := X"0000";
      INIT_4B : bit_vector := X"0000";
      INIT_4C : bit_vector := X"0000";
      INIT_4D : bit_vector := X"0000";
      INIT_4E : bit_vector := X"0000";
      INIT_4F : bit_vector := X"0000";
      INIT_50 : bit_vector := X"0000";
      INIT_51 : bit_vector := X"0000";
      INIT_52 : bit_vector := X"0000";
      INIT_53 : bit_vector := X"0000";
      INIT_54 : bit_vector := X"0000";
      INIT_55 : bit_vector := X"0000";
      INIT_56 : bit_vector := X"0000";
      INIT_57 : bit_vector := X"0000";
      SIM_MONITOR_FILE : string := "design.txt");
  
    port (
      alm          : out std_logic_vector(2 downto 0);
      busy         : out std_ulogic;
      channel      : out std_logic_vector(4 downto 0);
      do           : out std_logic_vector(15 downto 0);
      drdy         : out std_ulogic;
      eoc          : out std_ulogic;
      eos          : out std_ulogic;
      jtagbusy     : out std_ulogic;
      jtaglocked   : out std_ulogic;
      jtagmodified : out std_ulogic;
      ot           : out std_ulogic;
      convst       : in std_ulogic;
      convstclk    : in std_ulogic;
      daddr        : in std_logic_vector(6 downto 0);
      dclk         : in std_ulogic;
      den          : in std_ulogic;
      di           : in std_logic_vector(15 downto 0);
      dwe          : in std_ulogic;
      reset        : in std_ulogic;
      vauxn        : in std_logic_vector(15 downto 0);
      vauxp        : in std_logic_vector(15 downto 0);
      vn           : in std_ulogic;
      vp           : in std_ulogic);
  end component;

  component sysmon
    generic (
      INIT_40 : bit_vector := X"0000";
      INIT_41 : bit_vector := X"0000";
      INIT_42 : bit_vector := X"0800";
      INIT_43 : bit_vector := X"0000";
      INIT_44 : bit_vector := X"0000";
      INIT_45 : bit_vector := X"0000";
      INIT_46 : bit_vector := X"0000";
      INIT_47 : bit_vector := X"0000";
      INIT_48 : bit_vector := X"0000";
      INIT_49 : bit_vector := X"0000";
      INIT_4A : bit_vector := X"0000";
      INIT_4B : bit_vector := X"0000";
      INIT_4C : bit_vector := X"0000";
      INIT_4D : bit_vector := X"0000";
      INIT_4E : bit_vector := X"0000";
      INIT_4F : bit_vector := X"0000";
      INIT_50 : bit_vector := X"0000";
      INIT_51 : bit_vector := X"0000";
      INIT_52 : bit_vector := X"0000";
      INIT_53 : bit_vector := X"0000";
      INIT_54 : bit_vector := X"0000";
      INIT_55 : bit_vector := X"0000";
      INIT_56 : bit_vector := X"0000";
      INIT_57 : bit_vector := X"0000";
      SIM_DEVICE : string := "VIRTEX5";
      SIM_MONITOR_FILE : string := "design.txt");
  
    port (
      alm          : out std_logic_vector(2 downto 0);
      busy         : out std_ulogic;
      channel      : out std_logic_vector(4 downto 0);
      do           : out std_logic_vector(15 downto 0);
      drdy         : out std_ulogic;
      eoc          : out std_ulogic;
      eos          : out std_ulogic;
      jtagbusy     : out std_ulogic;
      jtaglocked   : out std_ulogic;
      jtagmodified : out std_ulogic;
      ot           : out std_ulogic;
      convst       : in std_ulogic;
      convstclk    : in std_ulogic;
      daddr        : in std_logic_vector(6 downto 0);
      dclk         : in std_ulogic;
      den          : in std_ulogic;
      di           : in std_logic_vector(15 downto 0);
      dwe          : in std_ulogic;
      reset        : in std_ulogic;
      vauxn        : in std_logic_vector(15 downto 0);
      vauxp        : in std_logic_vector(15 downto 0);
      vn           : in std_ulogic;
      vp           : in std_ulogic);
  end component;

begin  -- struct

  gen: if not ((tech = virtex5) or (tech = virtex6) or (tech = virtex7) or (tech = kintex7)) generate
    alm          <= (others => '0');
    busy         <= '0';
    channel      <= (others => '0');
    do           <= (others => '0');
    drdy         <= '0';
    eoc          <= '0';
    eos          <= '0';
    jtagbusy     <= '0';
    jtaglocked   <= '0';
    jtagmodified <= '0';
    ot           <= '0';
  end generate gen;

  v5: if tech = virtex5 generate
    v50 : sysmon_virtex5
      generic map (
        INIT_40 => INIT_40,
        INIT_41 => INIT_41,
        INIT_42 => INIT_42,
        INIT_43 => INIT_43,
        INIT_44 => INIT_44,
        INIT_45 => INIT_45,
        INIT_46 => INIT_46,
        INIT_47 => INIT_47,
        INIT_48 => INIT_48,
        INIT_49 => INIT_49,
        INIT_4A => INIT_4A,
        INIT_4B => INIT_4B,
        INIT_4C => INIT_4C,
        INIT_4D => INIT_4D,
        INIT_4E => INIT_4E,
        INIT_4F => INIT_4F,
        INIT_50 => INIT_50,
        INIT_51 => INIT_51,
        INIT_52 => INIT_52,
        INIT_53 => INIT_53,
        INIT_54 => INIT_54,
        INIT_55 => INIT_55,
        INIT_56 => INIT_56,
        INIT_57 => INIT_57,
        SIM_MONITOR_FILE => SIM_MONITOR_FILE)
    port map (alm => alm, busy => busy, channel => channel, do => do,
              drdy => drdy, eoc => eoc, eos => eos, jtagbusy => jtagbusy,
              jtaglocked => jtaglocked, jtagmodified => jtagmodified,
              ot => ot, convst => convst, convstclk => convstclk,
              daddr => daddr, dclk => dclk, den => den, di => di, 
              dwe => dwe, reset => reset, vauxn => vauxn, vauxp => vauxp,
              vn => vn, vp => vp);
  end generate v5;
  
  v6: if tech = virtex6 generate
    v60 : sysmon
      generic map (
        INIT_40 => INIT_40,
        INIT_41 => INIT_41,
        INIT_42 => INIT_42,
        INIT_43 => INIT_43,
        INIT_44 => INIT_44,
        INIT_45 => INIT_45,
        INIT_46 => INIT_46,
        INIT_47 => INIT_47,
        INIT_48 => INIT_48,
        INIT_49 => INIT_49,
        INIT_4A => INIT_4A,
        INIT_4B => INIT_4B,
        INIT_4C => INIT_4C,
        INIT_4D => INIT_4D,
        INIT_4E => INIT_4E,
        INIT_4F => INIT_4F,
        INIT_50 => INIT_50,
        INIT_51 => INIT_51,
        INIT_52 => INIT_52,
        INIT_53 => INIT_53,
        INIT_54 => INIT_54,
        INIT_55 => INIT_55,
        INIT_56 => INIT_56,
        INIT_57 => INIT_57,
        SIM_DEVICE => "VIRTEX6",
        SIM_MONITOR_FILE => SIM_MONITOR_FILE)
    port map (alm => alm, busy => busy, channel => channel, do => do,
              drdy => drdy, eoc => eoc, eos => eos, jtagbusy => jtagbusy,
              jtaglocked => jtaglocked, jtagmodified => jtagmodified,
              ot => ot, convst => convst, convstclk => convstclk,
              daddr => daddr, dclk => dclk, den => den, di => di, 
              dwe => dwe, reset => reset, vauxn => vauxn, vauxp => vauxp,
              vn => vn, vp => vp);
  end generate v6;

  v7: if tech = virtex7 generate
    v70 : sysmon
      generic map (
        INIT_40 => INIT_40,
        INIT_41 => INIT_41,
        INIT_42 => INIT_42,
        INIT_43 => INIT_43,
        INIT_44 => INIT_44,
        INIT_45 => INIT_45,
        INIT_46 => INIT_46,
        INIT_47 => INIT_47,
        INIT_48 => INIT_48,
        INIT_49 => INIT_49,
        INIT_4A => INIT_4A,
        INIT_4B => INIT_4B,
        INIT_4C => INIT_4C,
        INIT_4D => INIT_4D,
        INIT_4E => INIT_4E,
        INIT_4F => INIT_4F,
        INIT_50 => INIT_50,
        INIT_51 => INIT_51,
        INIT_52 => INIT_52,
        INIT_53 => INIT_53,
        INIT_54 => INIT_54,
        INIT_55 => INIT_55,
        INIT_56 => INIT_56,
        INIT_57 => INIT_57,
        SIM_DEVICE => "VIRTEX7",
        SIM_MONITOR_FILE => SIM_MONITOR_FILE)
    port map (alm => alm, busy => busy, channel => channel, do => do,
              drdy => drdy, eoc => eoc, eos => eos, jtagbusy => jtagbusy,
              jtaglocked => jtaglocked, jtagmodified => jtagmodified,
              ot => ot, convst => convst, convstclk => convstclk,
              daddr => daddr, dclk => dclk, den => den, di => di, 
              dwe => dwe, reset => reset, vauxn => vauxn, vauxp => vauxp,
              vn => vn, vp => vp);
  end generate v7;

  k7: if tech = kintex7 generate
    k70 : sysmon
      generic map (
        INIT_40 => INIT_40,
        INIT_41 => INIT_41,
        INIT_42 => INIT_42,
        INIT_43 => INIT_43,
        INIT_44 => INIT_44,
        INIT_45 => INIT_45,
        INIT_46 => INIT_46,
        INIT_47 => INIT_47,
        INIT_48 => INIT_48,
        INIT_49 => INIT_49,
        INIT_4A => INIT_4A,
        INIT_4B => INIT_4B,
        INIT_4C => INIT_4C,
        INIT_4D => INIT_4D,
        INIT_4E => INIT_4E,
        INIT_4F => INIT_4F,
        INIT_50 => INIT_50,
        INIT_51 => INIT_51,
        INIT_52 => INIT_52,
        INIT_53 => INIT_53,
        INIT_54 => INIT_54,
        INIT_55 => INIT_55,
        INIT_56 => INIT_56,
        INIT_57 => INIT_57,
        SIM_DEVICE => "KINTEX7",
        SIM_MONITOR_FILE => SIM_MONITOR_FILE)
    port map (alm => alm, busy => busy, channel => channel, do => do,
              drdy => drdy, eoc => eoc, eos => eos, jtagbusy => jtagbusy,
              jtaglocked => jtaglocked, jtagmodified => jtagmodified,
              ot => ot, convst => convst, convstclk => convstclk,
              daddr => daddr, dclk => dclk, den => den, di => di, 
              dwe => dwe, reset => reset, vauxn => vauxn, vauxp => vauxp,
              vn => vn, vp => vp);
  end generate k7;

end struct;

