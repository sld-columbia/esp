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
-- Entity: 	
-- File:	sysmon_unisim.vhd
-- Author:	Jan Andersson - Gaisler Research
-- Description:	Xilinx System Monitor
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- pragma translate_off
library unisim;
use unisim.vcomponents.SYSMON;
-- pragma translate_on

-------------------------------------------------------------------------------
-- Virtex 5 System Monitor
-------------------------------------------------------------------------------

entity sysmon_virtex5 is  
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
end sysmon_virtex5;

architecture struct of sysmon_virtex5 is

  component SYSMON
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
      SIM_MONITOR_FILE : string := "design.txt"
      );
    port (
      ALM : out std_logic_vector(2 downto 0);
      BUSY : out std_ulogic;
      CHANNEL : out std_logic_vector(4 downto 0);
      DO : out std_logic_vector(15 downto 0);
      DRDY : out std_ulogic;
      EOC : out std_ulogic;
      EOS : out std_ulogic;
      JTAGBUSY : out std_ulogic;
      JTAGLOCKED : out std_ulogic;
      JTAGMODIFIED : out std_ulogic;
      OT : out std_ulogic;
      CONVST : in std_ulogic;
      CONVSTCLK : in std_ulogic;
      DADDR : in std_logic_vector(6 downto 0);
      DCLK : in std_ulogic;
      DEN : in std_ulogic;
      DI : in std_logic_vector(15 downto 0);
      DWE : in std_ulogic;
      RESET : in std_ulogic;
      VAUXN : in std_logic_vector(15 downto 0);
      VAUXP : in std_logic_vector(15 downto 0);
      VN : in std_ulogic;
      VP : in std_ulogic
      );
  end component;
  
begin  -- struct
 
  sysmon0 : SYSMON
    generic map (INIT_40 => INIT_40, INIT_41 => INIT_41, INIT_42 => INIT_42,
                 INIT_43 => INIT_43, INIT_44 => INIT_44, INIT_45 => INIT_45,
                 INIT_46 => INIT_46, INIT_47 => INIT_47, INIT_48 => INIT_48,
                 INIT_49 => INIT_49, INIT_4A => INIT_4A, INIT_4B => INIT_4B,
                 INIT_4C => INIT_4C, INIT_4D => INIT_4D, INIT_4E => INIT_4E,
                 INIT_4F => INIT_4F, INIT_50 => INIT_50, INIT_51 => INIT_51,
                 INIT_52 => INIT_52, INIT_53 => INIT_53, INIT_54 => INIT_54,
                 INIT_55 => INIT_55, INIT_56 => INIT_56, INIT_57 => INIT_57,
                 SIM_MONITOR_FILE => SIM_MONITOR_FILE)
    port map (alm => alm, busy => busy, channel => channel, do => do,
              drdy => drdy, eoc => eoc, eos => eos, jtagbusy => jtagbusy,
              jtaglocked => jtaglocked, jtagmodified => jtagmodified,
              ot => ot, convst => convst, convstclk => convstclk,
              daddr => daddr, dclk => dclk, den => den, di => di, 
              dwe => dwe, reset => reset, vauxn => vauxn, vauxp => vauxp,
              vn => vn, vp => vp);

end struct;

