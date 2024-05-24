------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
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
-- Entity:      apbctrl
-- File:        apbctrl.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: AMBA AHB/APB bridge with plug&play support
------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity:      patient_apbctrl
-- File:        patient_apbctrl.vhd
-- Author:      Paolo Mantovani - Columbia University
-- Description: Patient version of the AHB/APB bridge
------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on

entity patient_apbctrl is
  generic (
    hindex      : integer := 0;
    haddr       : integer := 0;
    hmask       : integer := 16#fff#;
    nslaves     : integer range 1 to NAPBSLV := NAPBSLV;
    debug       : integer range 0 to 2 := 2;
    icheck      : integer range 0 to 1 := 1;
    enbusmon    : integer range 0 to 1 := 0;
    asserterr   : integer range 0 to 1 := 0;
    assertwarn  : integer range 0 to 1 := 0;
    pslvdisable : integer := 0;
    mcheck      : integer range 0 to 1 := 1;
    ccheck      : integer range 0 to 1 := 1;
    remote_apb  : std_logic_vector(0 to NAPBSLV - 1));
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbi    : in  ahb_slv_in_type;
    ahbo    : out ahb_slv_out_type;
    apbi    : out apb_slv_in_type;
    apbo    : in  apb_slv_out_vector;
    req     : out std_ulogic;           --Send APB request
    ack     : in  std_ulogic);

end;

architecture rtl of patient_apbctrl is

constant apbmax : integer := 27;

constant VERSION   : amba_version_type := 0;

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( 1, 6, 0, VERSION, 0),
  4 => ahb_membar(haddr, '0', '0', hmask),
  others => zero32);

constant IOAREA : std_logic_vector(11 downto 0) := 
        conv_std_logic_vector(haddr, 12);
constant IOMSK  : std_logic_vector(11 downto 0) := 
        conv_std_logic_vector(hmask, 12);

type reg_type is record
  haddr   : std_logic_vector(apbmax downto 0);   -- address bus
  hwrite  : std_logic;                       -- read/write
  hready  : std_logic;                       -- ready
  penable : std_logic;
  psel    : std_logic;
  prdata  : std_logic_vector(31 downto 0);   -- read data
  pwdata  : std_logic_vector(31 downto 0);   -- write data
  state   : std_logic_vector(1 downto 0);   -- state
  cfgsel  : std_ulogic;
  req     : std_ulogic;                 -- request to slave
end record;

constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
constant RES : reg_type :=
  (haddr => (others => '0'), hwrite => '0', hready => '1', penable => '0',
   psel => '0', prdata => (others => '0'), pwdata => (others => '0'),
   state => (others => '0'), cfgsel => '0', req => '0');

signal r, rin : reg_type;
--pragma translate_off
signal lapbi  : apb_slv_in_type;
--pragma translate_on

signal psel_sig : std_logic_vector(0 to nslaves-1);

begin

  psel_gen: for i in 0 to nslaves-1 generate
    psel_sig(i) <= apb_slv_decode(apbo(i).pconfig, r.haddr(19 downto  8), r.haddr(apbmax downto 20));
  end generate psel_gen;

  comb : process(ahbi, apbo, r, rst, ack, psel_sig)
  variable v : reg_type;
  variable psel   : std_logic_vector(0 to nslaves-1);
  variable psel_idx : integer range 0 to NAPBSLV - 1;
  variable pwdata : std_logic_vector(31 downto 0);
  variable apbaddr : std_logic_vector(apbmax downto 0);
  variable apbaddr2 : std_logic_vector(31 downto 0);
  variable pirq : std_logic_vector(NAHBIRQ-1 downto 0);
  variable nslave : integer range 0 to nslaves-1;
  variable bnslave : std_logic_vector(8 downto 0);
  begin

    v := r; v.psel := '0'; v.penable := '0'; psel := (others => '0');
    pirq := (others => '0'); 

    -- detect start of cycle
    if (ahbi.hready = '1') then
      if ((ahbi.htrans = HTRANS_NONSEQ) or (ahbi.htrans = HTRANS_SEQ)) and
          (ahbi.hsel(hindex) = '1')
      then
        v.hready := '0'; v.hwrite := ahbi.hwrite; 
        v.haddr(apbmax downto 0) := ahbi.haddr(apbmax downto 0); 
        v.state := "01"; v.psel := not ahbi.hwrite;
      end if;
    end if;

    psel := psel_sig;
    psel_idx := 0;
    for i in 0 to nslaves-1 loop
      if psel(i) = '1' then
        psel_idx := i;
      end if;
    end loop;

    -- Decode PNP access
    if (r.haddr(19 downto  12) = "11111111") and (r.haddr(apbmax downto 20) = zero32(apbmax downto 20)) then
      v.cfgsel := '1';
    else
      v.cfgsel := '0';
    end if;

    case r.state is
    when "00" => null;          -- idle
    when "01" =>
      if r.hwrite = '0' then v.penable := '1';
      else v.pwdata := ahbreadword(ahbi.hwdata, r.haddr(4 downto 2)); end if;
      v.psel := '1'; v.state := "10";
      --Make request
      if v.cfgsel = '0' and remote_apb(psel_idx) = '1' then
        v.req := '1';
      end if;
    when others =>
      if ack = '1' or v.cfgsel = '1' or remote_apb(psel_idx) = '0' then
        -- Lower request. Forward reply to AHB bus
        v.req := '0';
        if r.penable = '0' then v.psel := '1'; v.penable := '1'; end if;
        v.state := "00"; v.hready := '1';
      end if;
    end case;


    -- WARNING: the following encoder is fast, but we're hard-coding the number
    -- of APB slaves that can be seen on the bus.
    if NAPBSLV = 32 then
      bnslave(0) := psel(1)  or psel(3)  or psel(5)  or psel(7)  or
                    psel(9)  or psel(11) or psel(13) or psel(15) or
                    psel(17) or psel(19) or psel(21) or psel(23) or
                    psel(25) or psel(27) or psel(29) or psel(31);
      bnslave(1) := psel(2)  or psel(3)  or psel(6)  or psel(7)  or
                    psel(10) or psel(11) or psel(14) or psel(15) or
                    psel(18) or psel(19) or psel(22) or psel(23) or
                    psel(26) or psel(27) or psel(30) or psel(31);
      bnslave(2) := psel(4)  or psel(5)  or psel(6)  or psel(7)  or
                    psel(12) or psel(13) or psel(14) or psel(15) or
                    psel(20) or psel(21) or psel(22) or psel(23) or
                    psel(28) or psel(29) or psel(30) or psel(31);
      bnslave(3) := psel(8)  or psel(9)  or psel(10) or psel(11) or
                    psel(12) or psel(13) or psel(14) or psel(15) or
                    psel(24) or psel(25) or psel(26) or psel(27) or
                    psel(28) or psel(29) or psel(30) or psel(31);
      bnslave(4) := psel(16) or psel(17) or psel(18) or psel(19) or
                    psel(20) or psel(21) or psel(22) or psel(23) or
                    psel(24) or psel(25) or psel(26) or psel(27) or
                    psel(28) or psel(29) or psel(30) or psel(31);
      bnslave(5) := '0';
      bnslave(6) := '0';
      bnslave(7) := '0';
      bnslave(8) := '0';
    elsif NAPBSLV = 64 then
      bnslave(0) := psel(1)  or psel(3)  or psel(5)  or psel(7)  or
                    psel(9)  or psel(11) or psel(13) or psel(15) or
                    psel(17) or psel(19) or psel(21) or psel(23) or
                    psel(25) or psel(27) or psel(29) or psel(31) or
                    psel(33) or psel(35) or psel(37) or psel(39) or
                    psel(41) or psel(43) or psel(45) or psel(47) or
                    psel(49) or psel(51) or psel(53) or psel(55) or
                    psel(57) or psel(59) or psel(61) or psel(63);
      bnslave(1) := psel(2)  or psel(3)  or psel(6)  or psel(7)  or
                    psel(10) or psel(11) or psel(14) or psel(15) or
                    psel(18) or psel(19) or psel(22) or psel(23) or
                    psel(26) or psel(27) or psel(30) or psel(31) or
                    psel(34) or psel(35) or psel(38) or psel(39) or
                    psel(42) or psel(43) or psel(46) or psel(47) or
                    psel(50) or psel(51) or psel(54) or psel(55) or
                    psel(58) or psel(59) or psel(62) or psel(63);
      bnslave(2) := psel(4)  or psel(5)  or psel(6)  or psel(7)  or
                    psel(12) or psel(13) or psel(14) or psel(15) or
                    psel(20) or psel(21) or psel(22) or psel(23) or
                    psel(28) or psel(29) or psel(30) or psel(31) or
                    psel(36) or psel(37) or psel(38) or psel(39) or
                    psel(44) or psel(45) or psel(46) or psel(47) or
                    psel(52) or psel(53) or psel(54) or psel(55) or
                    psel(60) or psel(61) or psel(62) or psel(63);
      bnslave(3) := psel(8)  or psel(9)  or psel(10) or psel(11) or
                    psel(12) or psel(13) or psel(14) or psel(15) or
                    psel(24) or psel(25) or psel(26) or psel(27) or
                    psel(28) or psel(29) or psel(30) or psel(31) or
                    psel(40) or psel(41) or psel(42) or psel(43) or
                    psel(44) or psel(45) or psel(46) or psel(47) or
                    psel(56) or psel(57) or psel(58) or psel(59) or
                    psel(60) or psel(61) or psel(62) or psel(63);
      bnslave(4) := psel(16) or psel(17) or psel(18) or psel(19) or
                    psel(20) or psel(21) or psel(22) or psel(23) or
                    psel(24) or psel(25) or psel(26) or psel(27) or
                    psel(28) or psel(29) or psel(30) or psel(31) or
                    psel(48) or psel(49) or psel(50) or psel(51) or
                    psel(52) or psel(53) or psel(54) or psel(55) or
                    psel(56) or psel(57) or psel(58) or psel(59) or
                    psel(60) or psel(61) or psel(62) or psel(63);
      bnslave(5) := psel(32) or psel(33) or psel(34) or psel(35) or
                    psel(36) or psel(37) or psel(38) or psel(39) or
                    psel(40) or psel(41) or psel(42) or psel(43) or
                    psel(44) or psel(45) or psel(46) or psel(47) or
                    psel(48) or psel(49) or psel(50) or psel(51) or
                    psel(52) or psel(53) or psel(54) or psel(55) or
                    psel(56) or psel(57) or psel(58) or psel(59) or
                    psel(60) or psel(61) or psel(62) or psel(63);
      bnslave(6) := '0';
      bnslave(7) := '0';
      bnslave(8) := '0';
    elsif NAPBSLV = 128 then
      bnslave(0) := psel(1)   or psel(3)   or psel(5)   or psel(7)   or
                    psel(9)   or psel(11)  or psel(13)  or psel(15)  or
                    psel(17)  or psel(19)  or psel(21)  or psel(23)  or
                    psel(25)  or psel(27)  or psel(29)  or psel(31)  or
                    psel(33)  or psel(35)  or psel(37)  or psel(39)  or
                    psel(41)  or psel(43)  or psel(45)  or psel(47)  or
                    psel(49)  or psel(51)  or psel(53)  or psel(55)  or
                    psel(57)  or psel(59)  or psel(61)  or psel(63)  or
                    psel(65)  or psel(67)  or psel(69)  or psel(71)  or
                    psel(73)  or psel(75)  or psel(77)  or psel(79)  or
                    psel(81)  or psel(83)  or psel(85)  or psel(87)  or
                    psel(89)  or psel(91)  or psel(93)  or psel(95)  or
                    psel(97)  or psel(99)  or psel(101) or psel(103) or
                    psel(105) or psel(107) or psel(109) or psel(111) or
                    psel(113) or psel(115) or psel(117) or psel(119) or
                    psel(121) or psel(123) or psel(125) or psel(127);
      bnslave(1) := psel(2)   or psel(3)   or psel(6)   or psel(7)   or
                    psel(10)  or psel(11)  or psel(14)  or psel(15)  or
                    psel(18)  or psel(19)  or psel(22)  or psel(23)  or
                    psel(26)  or psel(27)  or psel(30)  or psel(31)  or
                    psel(34)  or psel(35)  or psel(38)  or psel(39)  or
                    psel(42)  or psel(43)  or psel(46)  or psel(47)  or
                    psel(50)  or psel(51)  or psel(54)  or psel(55)  or
                    psel(58)  or psel(59)  or psel(62)  or psel(63)  or
                    psel(66)  or psel(67)  or psel(70)  or psel(71)  or
                    psel(74)  or psel(75)  or psel(78)  or psel(79)  or
                    psel(82)  or psel(83)  or psel(86)  or psel(87)  or
                    psel(90)  or psel(91)  or psel(94)  or psel(95)  or
                    psel(98)  or psel(99)  or psel(102) or psel(103) or
                    psel(106) or psel(107) or psel(110) or psel(111) or
                    psel(114) or psel(115) or psel(118) or psel(119) or
                    psel(122) or psel(123) or psel(126) or psel(127);
      bnslave(2) := psel(4)   or psel(5)   or psel(6)   or psel(7)   or
                    psel(12)  or psel(13)  or psel(14)  or psel(15)  or
                    psel(20)  or psel(21)  or psel(22)  or psel(23)  or
                    psel(28)  or psel(29)  or psel(30)  or psel(31)  or
                    psel(36)  or psel(37)  or psel(38)  or psel(39)  or
                    psel(44)  or psel(45)  or psel(46)  or psel(47)  or
                    psel(52)  or psel(53)  or psel(54)  or psel(55)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(68)  or psel(69)  or psel(70)  or psel(71)  or
                    psel(76)  or psel(77)  or psel(78)  or psel(79)  or
                    psel(84)  or psel(85)  or psel(86)  or psel(87)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(100) or psel(101) or psel(102) or psel(103) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(124) or psel(125) or psel(126) or psel(127);
      bnslave(3) := psel(8)   or psel(9)   or psel(10)  or psel(11)  or
                    psel(12)  or psel(13)  or psel(14)  or psel(15)  or
                    psel(24)  or psel(25)  or psel(26)  or psel(27)  or
                    psel(28)  or psel(29)  or psel(30)  or psel(31)  or
                    psel(40)  or psel(41)  or psel(42)  or psel(43)  or
                    psel(44)  or psel(45)  or psel(46)  or psel(47)  or
                    psel(56)  or psel(57)  or psel(58)  or psel(59)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(72)  or psel(73)  or psel(74)  or psel(75)  or
                    psel(76)  or psel(77)  or psel(78)  or psel(79)  or
                    psel(88)  or psel(89)  or psel(90)  or psel(91)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(104) or psel(105) or psel(106) or psel(107) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127);
      bnslave(4) := psel(16)  or psel(17)  or psel(18)  or psel(19)  or
                    psel(20)  or psel(21)  or psel(22)  or psel(23)  or
                    psel(24)  or psel(25)  or psel(26)  or psel(27)  or
                    psel(28)  or psel(29)  or psel(30)  or psel(31)  or
                    psel(48)  or psel(49)  or psel(50)  or psel(51)  or
                    psel(52)  or psel(53)  or psel(54)  or psel(55)  or
                    psel(56)  or psel(57)  or psel(58)  or psel(59)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(80)  or psel(81)  or psel(82)  or psel(83)  or
                    psel(84)  or psel(85)  or psel(86)  or psel(87)  or
                    psel(88)  or psel(89)  or psel(90)  or psel(91)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(112) or psel(113) or psel(114) or psel(115) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127);
      bnslave(5) := psel(32)  or psel(33)  or psel(34)  or psel(35)  or
                    psel(36)  or psel(37)  or psel(38)  or psel(39)  or
                    psel(40)  or psel(41)  or psel(42)  or psel(43)  or
                    psel(44)  or psel(45)  or psel(46)  or psel(47)  or
                    psel(48)  or psel(49)  or psel(50)  or psel(51)  or
                    psel(52)  or psel(53)  or psel(54)  or psel(55)  or
                    psel(56)  or psel(57)  or psel(58)  or psel(59)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(96)  or psel(97)  or psel(98)  or psel(99)  or
                    psel(100) or psel(101) or psel(102) or psel(103) or
                    psel(104) or psel(105) or psel(106) or psel(107) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(112) or psel(113) or psel(114) or psel(115) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127);
      bnslave(6) := psel(64)  or psel(65)  or psel(66)  or psel(67)  or
                    psel(68)  or psel(69)  or psel(70)  or psel(71)  or
                    psel(72)  or psel(73)  or psel(74)  or psel(75)  or
                    psel(76)  or psel(77)  or psel(78)  or psel(79)  or
                    psel(80)  or psel(81)  or psel(82)  or psel(83)  or
                    psel(84)  or psel(85)  or psel(86)  or psel(87)  or
                    psel(88)  or psel(89)  or psel(90)  or psel(91)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(96)  or psel(97)  or psel(98)  or psel(99)  or
                    psel(100) or psel(101) or psel(102) or psel(103) or
                    psel(104) or psel(105) or psel(106) or psel(107) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(112) or psel(113) or psel(114) or psel(115) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127);
      bnslave(7) := '0';
      bnslave(8) := '0';
    elsif NAPBSLV = 256 then
      bnslave(0) := psel(1)   or psel(3)   or psel(5)   or psel(7)   or
                    psel(9)   or psel(11)  or psel(13)  or psel(15)  or
                    psel(17)  or psel(19)  or psel(21)  or psel(23)  or
                    psel(25)  or psel(27)  or psel(29)  or psel(31)  or
                    psel(33)  or psel(35)  or psel(37)  or psel(39)  or
                    psel(41)  or psel(43)  or psel(45)  or psel(47)  or
                    psel(49)  or psel(51)  or psel(53)  or psel(55)  or
                    psel(57)  or psel(59)  or psel(61)  or psel(63)  or
                    psel(65)  or psel(67)  or psel(69)  or psel(71)  or
                    psel(73)  or psel(75)  or psel(77)  or psel(79)  or
                    psel(81)  or psel(83)  or psel(85)  or psel(87)  or
                    psel(89)  or psel(91)  or psel(93)  or psel(95)  or
                    psel(97)  or psel(99)  or psel(101) or psel(103) or
                    psel(105) or psel(107) or psel(109) or psel(111) or
                    psel(113) or psel(115) or psel(117) or psel(119) or
                    psel(121) or psel(123) or psel(125) or psel(127) or
                    psel(129) or psel(131) or psel(133) or psel(135) or
                    psel(137) or psel(139) or psel(141) or psel(143) or
                    psel(145) or psel(147) or psel(149) or psel(151) or
                    psel(153) or psel(155) or psel(157) or psel(159) or
                    psel(161) or psel(163) or psel(165) or psel(167) or
                    psel(169) or psel(171) or psel(173) or psel(175) or
                    psel(177) or psel(179) or psel(181) or psel(183) or
                    psel(185) or psel(187) or psel(189) or psel(191) or
                    psel(193) or psel(195) or psel(197) or psel(199) or
                    psel(201) or psel(203) or psel(205) or psel(207) or
                    psel(209) or psel(211) or psel(213) or psel(215) or
                    psel(217) or psel(219) or psel(221) or psel(223) or
                    psel(225) or psel(227) or psel(229) or psel(231) or
                    psel(233) or psel(235) or psel(237) or psel(239) or
                    psel(241) or psel(243) or psel(245) or psel(247) or
                    psel(249) or psel(251) or psel(253) or psel(255);
      bnslave(1) := psel(2)   or psel(3)   or psel(6)   or psel(7)   or
                    psel(10)  or psel(11)  or psel(14)  or psel(15)  or
                    psel(18)  or psel(19)  or psel(22)  or psel(23)  or
                    psel(26)  or psel(27)  or psel(30)  or psel(31)  or
                    psel(34)  or psel(35)  or psel(38)  or psel(39)  or
                    psel(42)  or psel(43)  or psel(46)  or psel(47)  or
                    psel(50)  or psel(51)  or psel(54)  or psel(55)  or
                    psel(58)  or psel(59)  or psel(62)  or psel(63)  or
                    psel(66)  or psel(67)  or psel(70)  or psel(71)  or
                    psel(74)  or psel(75)  or psel(78)  or psel(79)  or
                    psel(82)  or psel(83)  or psel(86)  or psel(87)  or
                    psel(90)  or psel(91)  or psel(94)  or psel(95)  or
                    psel(98)  or psel(99)  or psel(102) or psel(103) or
                    psel(106) or psel(107) or psel(110) or psel(111) or
                    psel(114) or psel(115) or psel(118) or psel(119) or
                    psel(122) or psel(123) or psel(126) or psel(127) or
                    psel(130) or psel(131) or psel(134) or psel(135) or
                    psel(138) or psel(139) or psel(142) or psel(143) or
                    psel(146) or psel(147) or psel(150) or psel(151) or
                    psel(154) or psel(155) or psel(158) or psel(159) or
                    psel(162) or psel(163) or psel(166) or psel(167) or
                    psel(170) or psel(171) or psel(174) or psel(175) or
                    psel(178) or psel(179) or psel(182) or psel(183) or
                    psel(186) or psel(187) or psel(190) or psel(191) or
                    psel(194) or psel(195) or psel(198) or psel(199) or
                    psel(202) or psel(203) or psel(206) or psel(207) or
                    psel(210) or psel(211) or psel(214) or psel(215) or
                    psel(218) or psel(219) or psel(222) or psel(223) or
                    psel(226) or psel(227) or psel(230) or psel(231) or
                    psel(234) or psel(235) or psel(238) or psel(239) or
                    psel(242) or psel(243) or psel(246) or psel(247) or
                    psel(250) or psel(251) or psel(254) or psel(255);
      bnslave(2) := psel(4)   or psel(5)   or psel(6)   or psel(7)   or
                    psel(12)  or psel(13)  or psel(14)  or psel(15)  or
                    psel(20)  or psel(21)  or psel(22)  or psel(23)  or
                    psel(28)  or psel(29)  or psel(30)  or psel(31)  or
                    psel(36)  or psel(37)  or psel(38)  or psel(39)  or
                    psel(44)  or psel(45)  or psel(46)  or psel(47)  or
                    psel(52)  or psel(53)  or psel(54)  or psel(55)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(68)  or psel(69)  or psel(70)  or psel(71)  or
                    psel(76)  or psel(77)  or psel(78)  or psel(79)  or
                    psel(84)  or psel(85)  or psel(86)  or psel(87)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(100) or psel(101) or psel(102) or psel(103) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(132) or psel(133) or psel(134) or psel(135) or
                    psel(140) or psel(141) or psel(142) or psel(143) or
                    psel(148) or psel(149) or psel(150) or psel(151) or
                    psel(156) or psel(157) or psel(158) or psel(159) or
                    psel(164) or psel(165) or psel(166) or psel(167) or
                    psel(172) or psel(173) or psel(174) or psel(175) or
                    psel(180) or psel(181) or psel(182) or psel(183) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(196) or psel(197) or psel(198) or psel(199) or
                    psel(204) or psel(205) or psel(206) or psel(207) or
                    psel(212) or psel(213) or psel(214) or psel(215) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(228) or psel(229) or psel(230) or psel(231) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(252) or psel(253) or psel(254) or psel(255);
      bnslave(3) := psel(8)   or psel(9)   or psel(10)  or psel(11)  or
                    psel(12)  or psel(13)  or psel(14)  or psel(15)  or
                    psel(24)  or psel(25)  or psel(26)  or psel(27)  or
                    psel(28)  or psel(29)  or psel(30)  or psel(31)  or
                    psel(40)  or psel(41)  or psel(42)  or psel(43)  or
                    psel(44)  or psel(45)  or psel(46)  or psel(47)  or
                    psel(56)  or psel(57)  or psel(58)  or psel(59)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(72)  or psel(73)  or psel(74)  or psel(75)  or
                    psel(76)  or psel(77)  or psel(78)  or psel(79)  or
                    psel(88)  or psel(89)  or psel(90)  or psel(91)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(104) or psel(105) or psel(106) or psel(107) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(136) or psel(137) or psel(138) or psel(139) or
                    psel(140) or psel(141) or psel(142) or psel(143) or
                    psel(152) or psel(153) or psel(154) or psel(155) or
                    psel(156) or psel(157) or psel(158) or psel(159) or
                    psel(168) or psel(169) or psel(170) or psel(171) or
                    psel(172) or psel(173) or psel(174) or psel(175) or
                    psel(184) or psel(185) or psel(186) or psel(187) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(200) or psel(201) or psel(202) or psel(203) or
                    psel(204) or psel(205) or psel(206) or psel(207) or
                    psel(216) or psel(217) or psel(218) or psel(219) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(232) or psel(233) or psel(234) or psel(235) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255);
      bnslave(4) := psel(16)  or psel(17)  or psel(18)  or psel(19)  or
                    psel(20)  or psel(21)  or psel(22)  or psel(23)  or
                    psel(24)  or psel(25)  or psel(26)  or psel(27)  or
                    psel(28)  or psel(29)  or psel(30)  or psel(31)  or
                    psel(48)  or psel(49)  or psel(50)  or psel(51)  or
                    psel(52)  or psel(53)  or psel(54)  or psel(55)  or
                    psel(56)  or psel(57)  or psel(58)  or psel(59)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(80)  or psel(81)  or psel(82)  or psel(83)  or
                    psel(84)  or psel(85)  or psel(86)  or psel(87)  or
                    psel(88)  or psel(89)  or psel(90)  or psel(91)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(112) or psel(113) or psel(114) or psel(115) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(144) or psel(145) or psel(146) or psel(147) or
                    psel(148) or psel(149) or psel(150) or psel(151) or
                    psel(152) or psel(153) or psel(154) or psel(155) or
                    psel(156) or psel(157) or psel(158) or psel(159) or
                    psel(176) or psel(177) or psel(178) or psel(179) or
                    psel(180) or psel(181) or psel(182) or psel(183) or
                    psel(184) or psel(185) or psel(186) or psel(187) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(208) or psel(209) or psel(210) or psel(211) or
                    psel(212) or psel(213) or psel(214) or psel(215) or
                    psel(216) or psel(217) or psel(218) or psel(219) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(240) or psel(241) or psel(242) or psel(243) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255);
      bnslave(5) := psel(32)  or psel(33)  or psel(34)  or psel(35)  or
                    psel(36)  or psel(37)  or psel(38)  or psel(39)  or
                    psel(40)  or psel(41)  or psel(42)  or psel(43)  or
                    psel(44)  or psel(45)  or psel(46)  or psel(47)  or
                    psel(48)  or psel(49)  or psel(50)  or psel(51)  or
                    psel(52)  or psel(53)  or psel(54)  or psel(55)  or
                    psel(56)  or psel(57)  or psel(58)  or psel(59)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(96)  or psel(97)  or psel(98)  or psel(99)  or
                    psel(100) or psel(101) or psel(102) or psel(103) or
                    psel(104) or psel(105) or psel(106) or psel(107) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(112) or psel(113) or psel(114) or psel(115) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(160) or psel(161) or psel(162) or psel(163) or
                    psel(164) or psel(165) or psel(166) or psel(167) or
                    psel(168) or psel(169) or psel(170) or psel(171) or
                    psel(172) or psel(173) or psel(174) or psel(175) or
                    psel(176) or psel(177) or psel(178) or psel(179) or
                    psel(180) or psel(181) or psel(182) or psel(183) or
                    psel(184) or psel(185) or psel(186) or psel(187) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(224) or psel(225) or psel(226) or psel(227) or
                    psel(228) or psel(229) or psel(230) or psel(231) or
                    psel(232) or psel(233) or psel(234) or psel(235) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(240) or psel(241) or psel(242) or psel(243) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255);
      bnslave(6) := psel(64)  or psel(65)  or psel(66)  or psel(67)  or
                    psel(68)  or psel(69)  or psel(70)  or psel(71)  or
                    psel(72)  or psel(73)  or psel(74)  or psel(75)  or
                    psel(76)  or psel(77)  or psel(78)  or psel(79)  or
                    psel(80)  or psel(81)  or psel(82)  or psel(83)  or
                    psel(84)  or psel(85)  or psel(86)  or psel(87)  or
                    psel(88)  or psel(89)  or psel(90)  or psel(91)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(96)  or psel(97)  or psel(98)  or psel(99)  or
                    psel(100) or psel(101) or psel(102) or psel(103) or
                    psel(104) or psel(105) or psel(106) or psel(107) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(112) or psel(113) or psel(114) or psel(115) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(192) or psel(193) or psel(194) or psel(195) or
                    psel(196) or psel(197) or psel(198) or psel(199) or
                    psel(200) or psel(201) or psel(202) or psel(203) or
                    psel(204) or psel(205) or psel(206) or psel(207) or
                    psel(208) or psel(209) or psel(210) or psel(211) or
                    psel(212) or psel(213) or psel(214) or psel(215) or
                    psel(216) or psel(217) or psel(218) or psel(219) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(224) or psel(225) or psel(226) or psel(227) or
                    psel(228) or psel(229) or psel(230) or psel(231) or
                    psel(232) or psel(233) or psel(234) or psel(235) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(240) or psel(241) or psel(242) or psel(243) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255);
      bnslave(7) := psel(128) or psel(129) or psel(130) or psel(131) or
                    psel(132) or psel(133) or psel(134) or psel(135) or
                    psel(136) or psel(137) or psel(138) or psel(139) or
                    psel(140) or psel(141) or psel(142) or psel(143) or
                    psel(144) or psel(145) or psel(146) or psel(147) or
                    psel(148) or psel(149) or psel(150) or psel(151) or
                    psel(152) or psel(153) or psel(154) or psel(155) or
                    psel(156) or psel(157) or psel(158) or psel(159) or
                    psel(160) or psel(161) or psel(162) or psel(163) or
                    psel(164) or psel(165) or psel(166) or psel(167) or
                    psel(168) or psel(169) or psel(170) or psel(171) or
                    psel(172) or psel(173) or psel(174) or psel(175) or
                    psel(176) or psel(177) or psel(178) or psel(179) or
                    psel(180) or psel(181) or psel(182) or psel(183) or
                    psel(184) or psel(185) or psel(186) or psel(187) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(192) or psel(193) or psel(194) or psel(195) or
                    psel(196) or psel(197) or psel(198) or psel(199) or
                    psel(200) or psel(201) or psel(202) or psel(203) or
                    psel(204) or psel(205) or psel(206) or psel(207) or
                    psel(208) or psel(209) or psel(210) or psel(211) or
                    psel(212) or psel(213) or psel(214) or psel(215) or
                    psel(216) or psel(217) or psel(218) or psel(219) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(224) or psel(225) or psel(226) or psel(227) or
                    psel(228) or psel(229) or psel(230) or psel(231) or
                    psel(232) or psel(233) or psel(234) or psel(235) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(240) or psel(241) or psel(242) or psel(243) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255);
      bnslave(8) := '0';
    else --NAPBSLV = 512
      bnslave(0) := psel(1)   or psel(3)   or psel(5)   or psel(7)   or
                    psel(9)   or psel(11)  or psel(13)  or psel(15)  or
                    psel(17)  or psel(19)  or psel(21)  or psel(23)  or
                    psel(25)  or psel(27)  or psel(29)  or psel(31)  or
                    psel(33)  or psel(35)  or psel(37)  or psel(39)  or
                    psel(41)  or psel(43)  or psel(45)  or psel(47)  or
                    psel(49)  or psel(51)  or psel(53)  or psel(55)  or
                    psel(57)  or psel(59)  or psel(61)  or psel(63)  or
                    psel(65)  or psel(67)  or psel(69)  or psel(71)  or
                    psel(73)  or psel(75)  or psel(77)  or psel(79)  or
                    psel(81)  or psel(83)  or psel(85)  or psel(87)  or
                    psel(89)  or psel(91)  or psel(93)  or psel(95)  or
                    psel(97)  or psel(99)  or psel(101) or psel(103) or
                    psel(105) or psel(107) or psel(109) or psel(111) or
                    psel(113) or psel(115) or psel(117) or psel(119) or
                    psel(121) or psel(123) or psel(125) or psel(127) or
                    psel(129) or psel(131) or psel(133) or psel(135) or
                    psel(137) or psel(139) or psel(141) or psel(143) or
                    psel(145) or psel(147) or psel(149) or psel(151) or
                    psel(153) or psel(155) or psel(157) or psel(159) or
                    psel(161) or psel(163) or psel(165) or psel(167) or
                    psel(169) or psel(171) or psel(173) or psel(175) or
                    psel(177) or psel(179) or psel(181) or psel(183) or
                    psel(185) or psel(187) or psel(189) or psel(191) or
                    psel(193) or psel(195) or psel(197) or psel(199) or
                    psel(201) or psel(203) or psel(205) or psel(207) or
                    psel(209) or psel(211) or psel(213) or psel(215) or
                    psel(217) or psel(219) or psel(221) or psel(223) or
                    psel(225) or psel(227) or psel(229) or psel(231) or
                    psel(233) or psel(235) or psel(237) or psel(239) or
                    psel(241) or psel(243) or psel(245) or psel(247) or
                    psel(249) or psel(251) or psel(253) or psel(255) or
                    psel(257) or psel(259) or psel(261) or psel(263) or
                    psel(265) or psel(267) or psel(269) or psel(271) or
                    psel(273) or psel(275) or psel(277) or psel(279) or
                    psel(281) or psel(283) or psel(285) or psel(287) or
                    psel(289) or psel(291) or psel(293) or psel(295) or
                    psel(297) or psel(299) or psel(301) or psel(303) or
                    psel(305) or psel(307) or psel(309) or psel(311) or
                    psel(313) or psel(315) or psel(317) or psel(319) or
                    psel(321) or psel(323) or psel(325) or psel(327) or
                    psel(329) or psel(331) or psel(333) or psel(335) or
                    psel(337) or psel(339) or psel(341) or psel(343) or
                    psel(345) or psel(347) or psel(349) or psel(351) or
                    psel(353) or psel(355) or psel(357) or psel(359) or
                    psel(361) or psel(363) or psel(365) or psel(367) or
                    psel(369) or psel(371) or psel(373) or psel(375) or
                    psel(377) or psel(379) or psel(381) or psel(383) or
                    psel(385) or psel(387) or psel(389) or psel(391) or
                    psel(393) or psel(395) or psel(397) or psel(399) or
                    psel(401) or psel(403) or psel(405) or psel(407) or
                    psel(409) or psel(411) or psel(413) or psel(415) or
                    psel(417) or psel(419) or psel(421) or psel(423) or
                    psel(425) or psel(427) or psel(429) or psel(431) or
                    psel(433) or psel(435) or psel(437) or psel(439) or
                    psel(441) or psel(443) or psel(445) or psel(447) or
                    psel(449) or psel(451) or psel(453) or psel(455) or
                    psel(457) or psel(459) or psel(461) or psel(463) or
                    psel(465) or psel(467) or psel(469) or psel(471) or
                    psel(473) or psel(475) or psel(477) or psel(479) or
                    psel(481) or psel(483) or psel(485) or psel(487) or
                    psel(489) or psel(491) or psel(493) or psel(495) or
                    psel(497) or psel(499) or psel(501) or psel(503) or
                    psel(505) or psel(507) or psel(509) or psel(511);
      bnslave(1) := psel(2)   or psel(3)   or psel(6)   or psel(7)   or
                    psel(10)  or psel(11)  or psel(14)  or psel(15)  or
                    psel(18)  or psel(19)  or psel(22)  or psel(23)  or
                    psel(26)  or psel(27)  or psel(30)  or psel(31)  or
                    psel(34)  or psel(35)  or psel(38)  or psel(39)  or
                    psel(42)  or psel(43)  or psel(46)  or psel(47)  or
                    psel(50)  or psel(51)  or psel(54)  or psel(55)  or
                    psel(58)  or psel(59)  or psel(62)  or psel(63)  or
                    psel(66)  or psel(67)  or psel(70)  or psel(71)  or
                    psel(74)  or psel(75)  or psel(78)  or psel(79)  or
                    psel(82)  or psel(83)  or psel(86)  or psel(87)  or
                    psel(90)  or psel(91)  or psel(94)  or psel(95)  or
                    psel(98)  or psel(99)  or psel(102) or psel(103) or
                    psel(106) or psel(107) or psel(110) or psel(111) or
                    psel(114) or psel(115) or psel(118) or psel(119) or
                    psel(122) or psel(123) or psel(126) or psel(127) or
                    psel(130) or psel(131) or psel(134) or psel(135) or
                    psel(138) or psel(139) or psel(142) or psel(143) or
                    psel(146) or psel(147) or psel(150) or psel(151) or
                    psel(154) or psel(155) or psel(158) or psel(159) or
                    psel(162) or psel(163) or psel(166) or psel(167) or
                    psel(170) or psel(171) or psel(174) or psel(175) or
                    psel(178) or psel(179) or psel(182) or psel(183) or
                    psel(186) or psel(187) or psel(190) or psel(191) or
                    psel(194) or psel(195) or psel(198) or psel(199) or
                    psel(202) or psel(203) or psel(206) or psel(207) or
                    psel(210) or psel(211) or psel(214) or psel(215) or
                    psel(218) or psel(219) or psel(222) or psel(223) or
                    psel(226) or psel(227) or psel(230) or psel(231) or
                    psel(234) or psel(235) or psel(238) or psel(239) or
                    psel(242) or psel(243) or psel(246) or psel(247) or
                    psel(250) or psel(251) or psel(254) or psel(255) or
                    psel(258) or psel(259) or psel(262) or psel(263) or
                    psel(266) or psel(267) or psel(270) or psel(271) or
                    psel(274) or psel(275) or psel(278) or psel(279) or
                    psel(282) or psel(283) or psel(286) or psel(287) or
                    psel(290) or psel(291) or psel(294) or psel(295) or
                    psel(298) or psel(299) or psel(302) or psel(303) or
                    psel(306) or psel(307) or psel(310) or psel(311) or
                    psel(314) or psel(315) or psel(318) or psel(319) or
                    psel(322) or psel(323) or psel(326) or psel(327) or
                    psel(330) or psel(331) or psel(334) or psel(335) or
                    psel(338) or psel(339) or psel(342) or psel(343) or
                    psel(346) or psel(347) or psel(350) or psel(351) or
                    psel(354) or psel(355) or psel(358) or psel(359) or
                    psel(362) or psel(363) or psel(366) or psel(367) or
                    psel(370) or psel(371) or psel(374) or psel(375) or
                    psel(378) or psel(379) or psel(382) or psel(383) or
                    psel(386) or psel(387) or psel(390) or psel(391) or
                    psel(394) or psel(395) or psel(398) or psel(399) or
                    psel(402) or psel(403) or psel(406) or psel(407) or
                    psel(410) or psel(411) or psel(414) or psel(415) or
                    psel(418) or psel(419) or psel(422) or psel(423) or
                    psel(426) or psel(427) or psel(430) or psel(431) or
                    psel(434) or psel(435) or psel(438) or psel(439) or
                    psel(442) or psel(443) or psel(446) or psel(447) or
                    psel(450) or psel(451) or psel(454) or psel(455) or
                    psel(458) or psel(459) or psel(462) or psel(463) or
                    psel(466) or psel(467) or psel(470) or psel(471) or
                    psel(474) or psel(475) or psel(478) or psel(479) or
                    psel(482) or psel(483) or psel(486) or psel(487) or
                    psel(490) or psel(491) or psel(494) or psel(495) or
                    psel(498) or psel(499) or psel(502) or psel(503) or
                    psel(506) or psel(507) or psel(510) or psel(511);
      bnslave(2) := psel(4)   or psel(5)   or psel(6)   or psel(7)   or
                    psel(12)  or psel(13)  or psel(14)  or psel(15)  or
                    psel(20)  or psel(21)  or psel(22)  or psel(23)  or
                    psel(28)  or psel(29)  or psel(30)  or psel(31)  or
                    psel(36)  or psel(37)  or psel(38)  or psel(39)  or
                    psel(44)  or psel(45)  or psel(46)  or psel(47)  or
                    psel(52)  or psel(53)  or psel(54)  or psel(55)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(68)  or psel(69)  or psel(70)  or psel(71)  or
                    psel(76)  or psel(77)  or psel(78)  or psel(79)  or
                    psel(84)  or psel(85)  or psel(86)  or psel(87)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(100) or psel(101) or psel(102) or psel(103) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(132) or psel(133) or psel(134) or psel(135) or
                    psel(140) or psel(141) or psel(142) or psel(143) or
                    psel(148) or psel(149) or psel(150) or psel(151) or
                    psel(156) or psel(157) or psel(158) or psel(159) or
                    psel(164) or psel(165) or psel(166) or psel(167) or
                    psel(172) or psel(173) or psel(174) or psel(175) or
                    psel(180) or psel(181) or psel(182) or psel(183) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(196) or psel(197) or psel(198) or psel(199) or
                    psel(204) or psel(205) or psel(206) or psel(207) or
                    psel(212) or psel(213) or psel(214) or psel(215) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(228) or psel(229) or psel(230) or psel(231) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(252) or psel(253) or psel(254) or psel(255) or
                    psel(260) or psel(261) or psel(262) or psel(263) or
                    psel(268) or psel(269) or psel(270) or psel(271) or
                    psel(276) or psel(277) or psel(278) or psel(279) or
                    psel(284) or psel(285) or psel(286) or psel(287) or
                    psel(292) or psel(293) or psel(294) or psel(295) or
                    psel(300) or psel(301) or psel(302) or psel(303) or
                    psel(308) or psel(309) or psel(310) or psel(311) or
                    psel(316) or psel(317) or psel(318) or psel(319) or
                    psel(324) or psel(325) or psel(326) or psel(327) or
                    psel(332) or psel(333) or psel(334) or psel(335) or
                    psel(340) or psel(341) or psel(342) or psel(343) or
                    psel(348) or psel(349) or psel(350) or psel(351) or
                    psel(356) or psel(357) or psel(358) or psel(359) or
                    psel(364) or psel(365) or psel(366) or psel(367) or
                    psel(372) or psel(373) or psel(374) or psel(375) or
                    psel(380) or psel(381) or psel(382) or psel(383) or
                    psel(388) or psel(389) or psel(390) or psel(391) or
                    psel(396) or psel(397) or psel(398) or psel(399) or
                    psel(404) or psel(405) or psel(406) or psel(407) or
                    psel(412) or psel(413) or psel(414) or psel(415) or
                    psel(420) or psel(421) or psel(422) or psel(423) or
                    psel(428) or psel(429) or psel(430) or psel(431) or
                    psel(436) or psel(437) or psel(438) or psel(439) or
                    psel(444) or psel(445) or psel(446) or psel(447) or
                    psel(452) or psel(453) or psel(454) or psel(455) or
                    psel(460) or psel(461) or psel(462) or psel(463) or
                    psel(468) or psel(469) or psel(470) or psel(471) or
                    psel(476) or psel(477) or psel(478) or psel(479) or
                    psel(484) or psel(485) or psel(486) or psel(487) or
                    psel(492) or psel(493) or psel(494) or psel(495) or
                    psel(500) or psel(501) or psel(502) or psel(503) or
                    psel(508) or psel(509) or psel(510) or psel(511);
      bnslave(3) := psel(8)   or psel(9)   or psel(10)  or psel(11)  or
                    psel(12)  or psel(13)  or psel(14)  or psel(15)  or
                    psel(24)  or psel(25)  or psel(26)  or psel(27)  or
                    psel(28)  or psel(29)  or psel(30)  or psel(31)  or
                    psel(40)  or psel(41)  or psel(42)  or psel(43)  or
                    psel(44)  or psel(45)  or psel(46)  or psel(47)  or
                    psel(56)  or psel(57)  or psel(58)  or psel(59)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(72)  or psel(73)  or psel(74)  or psel(75)  or
                    psel(76)  or psel(77)  or psel(78)  or psel(79)  or
                    psel(88)  or psel(89)  or psel(90)  or psel(91)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(104) or psel(105) or psel(106) or psel(107) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(136) or psel(137) or psel(138) or psel(139) or
                    psel(140) or psel(141) or psel(142) or psel(143) or
                    psel(152) or psel(153) or psel(154) or psel(155) or
                    psel(156) or psel(157) or psel(158) or psel(159) or
                    psel(168) or psel(169) or psel(170) or psel(171) or
                    psel(172) or psel(173) or psel(174) or psel(175) or
                    psel(184) or psel(185) or psel(186) or psel(187) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(200) or psel(201) or psel(202) or psel(203) or
                    psel(204) or psel(205) or psel(206) or psel(207) or
                    psel(216) or psel(217) or psel(218) or psel(219) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(232) or psel(233) or psel(234) or psel(235) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255) or
                    psel(264) or psel(265) or psel(266) or psel(267) or
                    psel(268) or psel(269) or psel(270) or psel(271) or
                    psel(280) or psel(281) or psel(282) or psel(283) or
                    psel(284) or psel(285) or psel(286) or psel(287) or
                    psel(296) or psel(297) or psel(298) or psel(299) or
                    psel(300) or psel(301) or psel(302) or psel(303) or
                    psel(312) or psel(313) or psel(314) or psel(315) or
                    psel(316) or psel(317) or psel(318) or psel(319) or
                    psel(328) or psel(329) or psel(330) or psel(331) or
                    psel(332) or psel(333) or psel(334) or psel(335) or
                    psel(344) or psel(345) or psel(346) or psel(347) or
                    psel(348) or psel(349) or psel(350) or psel(351) or
                    psel(360) or psel(361) or psel(362) or psel(363) or
                    psel(364) or psel(365) or psel(366) or psel(367) or
                    psel(376) or psel(377) or psel(378) or psel(379) or
                    psel(380) or psel(381) or psel(382) or psel(383) or
                    psel(392) or psel(393) or psel(394) or psel(395) or
                    psel(396) or psel(397) or psel(398) or psel(399) or
                    psel(408) or psel(409) or psel(410) or psel(411) or
                    psel(412) or psel(413) or psel(414) or psel(415) or
                    psel(424) or psel(425) or psel(426) or psel(427) or
                    psel(428) or psel(429) or psel(430) or psel(431) or
                    psel(440) or psel(441) or psel(442) or psel(443) or
                    psel(444) or psel(445) or psel(446) or psel(447) or
                    psel(456) or psel(457) or psel(458) or psel(459) or
                    psel(460) or psel(461) or psel(462) or psel(463) or
                    psel(472) or psel(473) or psel(474) or psel(475) or
                    psel(476) or psel(477) or psel(478) or psel(479) or
                    psel(488) or psel(489) or psel(490) or psel(491) or
                    psel(492) or psel(493) or psel(494) or psel(495) or
                    psel(504) or psel(505) or psel(506) or psel(507) or
                    psel(508) or psel(509) or psel(510) or psel(511);
      bnslave(4) := psel(16)  or psel(17)  or psel(18)  or psel(19)  or
                    psel(20)  or psel(21)  or psel(22)  or psel(23)  or
                    psel(24)  or psel(25)  or psel(26)  or psel(27)  or
                    psel(28)  or psel(29)  or psel(30)  or psel(31)  or
                    psel(48)  or psel(49)  or psel(50)  or psel(51)  or
                    psel(52)  or psel(53)  or psel(54)  or psel(55)  or
                    psel(56)  or psel(57)  or psel(58)  or psel(59)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(80)  or psel(81)  or psel(82)  or psel(83)  or
                    psel(84)  or psel(85)  or psel(86)  or psel(87)  or
                    psel(88)  or psel(89)  or psel(90)  or psel(91)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(112) or psel(113) or psel(114) or psel(115) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(144) or psel(145) or psel(146) or psel(147) or
                    psel(148) or psel(149) or psel(150) or psel(151) or
                    psel(152) or psel(153) or psel(154) or psel(155) or
                    psel(156) or psel(157) or psel(158) or psel(159) or
                    psel(176) or psel(177) or psel(178) or psel(179) or
                    psel(180) or psel(181) or psel(182) or psel(183) or
                    psel(184) or psel(185) or psel(186) or psel(187) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(208) or psel(209) or psel(210) or psel(211) or
                    psel(212) or psel(213) or psel(214) or psel(215) or
                    psel(216) or psel(217) or psel(218) or psel(219) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(240) or psel(241) or psel(242) or psel(243) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255) or
                    psel(272) or psel(273) or psel(274) or psel(275) or
                    psel(276) or psel(277) or psel(278) or psel(279) or
                    psel(280) or psel(281) or psel(282) or psel(283) or
                    psel(284) or psel(285) or psel(286) or psel(287) or
                    psel(304) or psel(305) or psel(306) or psel(307) or
                    psel(308) or psel(309) or psel(310) or psel(311) or
                    psel(312) or psel(313) or psel(314) or psel(315) or
                    psel(316) or psel(317) or psel(318) or psel(319) or
                    psel(336) or psel(337) or psel(338) or psel(339) or
                    psel(340) or psel(341) or psel(342) or psel(343) or
                    psel(344) or psel(345) or psel(346) or psel(347) or
                    psel(348) or psel(349) or psel(350) or psel(351) or
                    psel(368) or psel(369) or psel(370) or psel(371) or
                    psel(372) or psel(373) or psel(374) or psel(375) or
                    psel(376) or psel(377) or psel(378) or psel(379) or
                    psel(380) or psel(381) or psel(382) or psel(383) or
                    psel(400) or psel(401) or psel(402) or psel(403) or
                    psel(404) or psel(405) or psel(406) or psel(407) or
                    psel(408) or psel(409) or psel(410) or psel(411) or
                    psel(412) or psel(413) or psel(414) or psel(415) or
                    psel(432) or psel(433) or psel(434) or psel(435) or
                    psel(436) or psel(437) or psel(438) or psel(439) or
                    psel(440) or psel(441) or psel(442) or psel(443) or
                    psel(444) or psel(445) or psel(446) or psel(447) or
                    psel(464) or psel(465) or psel(466) or psel(467) or
                    psel(468) or psel(469) or psel(470) or psel(471) or
                    psel(472) or psel(473) or psel(474) or psel(475) or
                    psel(476) or psel(477) or psel(478) or psel(479) or
                    psel(496) or psel(497) or psel(498) or psel(499) or
                    psel(500) or psel(501) or psel(502) or psel(503) or
                    psel(504) or psel(505) or psel(506) or psel(507) or
                    psel(508) or psel(509) or psel(510) or psel(511);
      bnslave(5) := psel(32)  or psel(33)  or psel(34)  or psel(35)  or
                    psel(36)  or psel(37)  or psel(38)  or psel(39)  or
                    psel(40)  or psel(41)  or psel(42)  or psel(43)  or
                    psel(44)  or psel(45)  or psel(46)  or psel(47)  or
                    psel(48)  or psel(49)  or psel(50)  or psel(51)  or
                    psel(52)  or psel(53)  or psel(54)  or psel(55)  or
                    psel(56)  or psel(57)  or psel(58)  or psel(59)  or
                    psel(60)  or psel(61)  or psel(62)  or psel(63)  or
                    psel(96)  or psel(97)  or psel(98)  or psel(99)  or
                    psel(100) or psel(101) or psel(102) or psel(103) or
                    psel(104) or psel(105) or psel(106) or psel(107) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(112) or psel(113) or psel(114) or psel(115) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(160) or psel(161) or psel(162) or psel(163) or
                    psel(164) or psel(165) or psel(166) or psel(167) or
                    psel(168) or psel(169) or psel(170) or psel(171) or
                    psel(172) or psel(173) or psel(174) or psel(175) or
                    psel(176) or psel(177) or psel(178) or psel(179) or
                    psel(180) or psel(181) or psel(182) or psel(183) or
                    psel(184) or psel(185) or psel(186) or psel(187) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(224) or psel(225) or psel(226) or psel(227) or
                    psel(228) or psel(229) or psel(230) or psel(231) or
                    psel(232) or psel(233) or psel(234) or psel(235) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(240) or psel(241) or psel(242) or psel(243) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255) or
                    psel(288) or psel(289) or psel(290) or psel(291) or
                    psel(292) or psel(293) or psel(294) or psel(295) or
                    psel(296) or psel(297) or psel(298) or psel(299) or
                    psel(300) or psel(301) or psel(302) or psel(303) or
                    psel(304) or psel(305) or psel(306) or psel(307) or
                    psel(308) or psel(309) or psel(310) or psel(311) or
                    psel(312) or psel(313) or psel(314) or psel(315) or
                    psel(316) or psel(317) or psel(318) or psel(319) or
                    psel(352) or psel(353) or psel(354) or psel(355) or
                    psel(356) or psel(357) or psel(358) or psel(359) or
                    psel(360) or psel(361) or psel(362) or psel(363) or
                    psel(364) or psel(365) or psel(366) or psel(367) or
                    psel(368) or psel(369) or psel(370) or psel(371) or
                    psel(372) or psel(373) or psel(374) or psel(375) or
                    psel(376) or psel(377) or psel(378) or psel(379) or
                    psel(380) or psel(381) or psel(382) or psel(383) or
                    psel(416) or psel(417) or psel(418) or psel(419) or
                    psel(420) or psel(421) or psel(422) or psel(423) or
                    psel(424) or psel(425) or psel(426) or psel(427) or
                    psel(428) or psel(429) or psel(430) or psel(431) or
                    psel(432) or psel(433) or psel(434) or psel(435) or
                    psel(436) or psel(437) or psel(438) or psel(439) or
                    psel(440) or psel(441) or psel(442) or psel(443) or
                    psel(444) or psel(445) or psel(446) or psel(447) or
                    psel(480) or psel(481) or psel(482) or psel(483) or
                    psel(484) or psel(485) or psel(486) or psel(487) or
                    psel(488) or psel(489) or psel(490) or psel(491) or
                    psel(492) or psel(493) or psel(494) or psel(495) or
                    psel(496) or psel(497) or psel(498) or psel(499) or
                    psel(500) or psel(501) or psel(502) or psel(503) or
                    psel(504) or psel(505) or psel(506) or psel(507) or
                    psel(508) or psel(509) or psel(510) or psel(511);
      bnslave(6) := psel(64)  or psel(65)  or psel(66)  or psel(67)  or
                    psel(68)  or psel(69)  or psel(70)  or psel(71)  or
                    psel(72)  or psel(73)  or psel(74)  or psel(75)  or
                    psel(76)  or psel(77)  or psel(78)  or psel(79)  or
                    psel(80)  or psel(81)  or psel(82)  or psel(83)  or
                    psel(84)  or psel(85)  or psel(86)  or psel(87)  or
                    psel(88)  or psel(89)  or psel(90)  or psel(91)  or
                    psel(92)  or psel(93)  or psel(94)  or psel(95)  or
                    psel(96)  or psel(97)  or psel(98)  or psel(99)  or
                    psel(100) or psel(101) or psel(102) or psel(103) or
                    psel(104) or psel(105) or psel(106) or psel(107) or
                    psel(108) or psel(109) or psel(110) or psel(111) or
                    psel(112) or psel(113) or psel(114) or psel(115) or
                    psel(116) or psel(117) or psel(118) or psel(119) or
                    psel(120) or psel(121) or psel(122) or psel(123) or
                    psel(124) or psel(125) or psel(126) or psel(127) or
                    psel(192) or psel(193) or psel(194) or psel(195) or
                    psel(196) or psel(197) or psel(198) or psel(199) or
                    psel(200) or psel(201) or psel(202) or psel(203) or
                    psel(204) or psel(205) or psel(206) or psel(207) or
                    psel(208) or psel(209) or psel(210) or psel(211) or
                    psel(212) or psel(213) or psel(214) or psel(215) or
                    psel(216) or psel(217) or psel(218) or psel(219) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(224) or psel(225) or psel(226) or psel(227) or
                    psel(228) or psel(229) or psel(230) or psel(231) or
                    psel(232) or psel(233) or psel(234) or psel(235) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(240) or psel(241) or psel(242) or psel(243) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255) or
                    psel(320) or psel(321) or psel(322) or psel(323) or
                    psel(324) or psel(325) or psel(326) or psel(327) or
                    psel(328) or psel(329) or psel(330) or psel(331) or
                    psel(332) or psel(333) or psel(334) or psel(335) or
                    psel(336) or psel(337) or psel(338) or psel(339) or
                    psel(340) or psel(341) or psel(342) or psel(343) or
                    psel(344) or psel(345) or psel(346) or psel(347) or
                    psel(348) or psel(349) or psel(350) or psel(351) or
                    psel(352) or psel(353) or psel(354) or psel(355) or
                    psel(356) or psel(357) or psel(358) or psel(359) or
                    psel(360) or psel(361) or psel(362) or psel(363) or
                    psel(364) or psel(365) or psel(366) or psel(367) or
                    psel(368) or psel(369) or psel(370) or psel(371) or
                    psel(372) or psel(373) or psel(374) or psel(375) or
                    psel(376) or psel(377) or psel(378) or psel(379) or
                    psel(380) or psel(381) or psel(382) or psel(383) or
                    psel(448) or psel(449) or psel(450) or psel(451) or
                    psel(452) or psel(453) or psel(454) or psel(455) or
                    psel(456) or psel(457) or psel(458) or psel(459) or
                    psel(460) or psel(461) or psel(462) or psel(463) or
                    psel(464) or psel(465) or psel(466) or psel(467) or
                    psel(468) or psel(469) or psel(470) or psel(471) or
                    psel(472) or psel(473) or psel(474) or psel(475) or
                    psel(476) or psel(477) or psel(478) or psel(479) or
                    psel(480) or psel(481) or psel(482) or psel(483) or
                    psel(484) or psel(485) or psel(486) or psel(487) or
                    psel(488) or psel(489) or psel(490) or psel(491) or
                    psel(492) or psel(493) or psel(494) or psel(495) or
                    psel(496) or psel(497) or psel(498) or psel(499) or
                    psel(500) or psel(501) or psel(502) or psel(503) or
                    psel(504) or psel(505) or psel(506) or psel(507) or
                    psel(508) or psel(509) or psel(510) or psel(511);
      bnslave(7) := psel(128) or psel(129) or psel(130) or psel(131) or
                    psel(132) or psel(133) or psel(134) or psel(135) or
                    psel(136) or psel(137) or psel(138) or psel(139) or
                    psel(140) or psel(141) or psel(142) or psel(143) or
                    psel(144) or psel(145) or psel(146) or psel(147) or
                    psel(148) or psel(149) or psel(150) or psel(151) or
                    psel(152) or psel(153) or psel(154) or psel(155) or
                    psel(156) or psel(157) or psel(158) or psel(159) or
                    psel(160) or psel(161) or psel(162) or psel(163) or
                    psel(164) or psel(165) or psel(166) or psel(167) or
                    psel(168) or psel(169) or psel(170) or psel(171) or
                    psel(172) or psel(173) or psel(174) or psel(175) or
                    psel(176) or psel(177) or psel(178) or psel(179) or
                    psel(180) or psel(181) or psel(182) or psel(183) or
                    psel(184) or psel(185) or psel(186) or psel(187) or
                    psel(188) or psel(189) or psel(190) or psel(191) or
                    psel(192) or psel(193) or psel(194) or psel(195) or
                    psel(196) or psel(197) or psel(198) or psel(199) or
                    psel(200) or psel(201) or psel(202) or psel(203) or
                    psel(204) or psel(205) or psel(206) or psel(207) or
                    psel(208) or psel(209) or psel(210) or psel(211) or
                    psel(212) or psel(213) or psel(214) or psel(215) or
                    psel(216) or psel(217) or psel(218) or psel(219) or
                    psel(220) or psel(221) or psel(222) or psel(223) or
                    psel(224) or psel(225) or psel(226) or psel(227) or
                    psel(228) or psel(229) or psel(230) or psel(231) or
                    psel(232) or psel(233) or psel(234) or psel(235) or
                    psel(236) or psel(237) or psel(238) or psel(239) or
                    psel(240) or psel(241) or psel(242) or psel(243) or
                    psel(244) or psel(245) or psel(246) or psel(247) or
                    psel(248) or psel(249) or psel(250) or psel(251) or
                    psel(252) or psel(253) or psel(254) or psel(255) or
                    psel(384) or psel(385) or psel(386) or psel(387) or
                    psel(388) or psel(389) or psel(390) or psel(391) or
                    psel(392) or psel(393) or psel(394) or psel(395) or
                    psel(396) or psel(397) or psel(398) or psel(399) or
                    psel(400) or psel(401) or psel(402) or psel(403) or
                    psel(404) or psel(405) or psel(406) or psel(407) or
                    psel(408) or psel(409) or psel(410) or psel(411) or
                    psel(412) or psel(413) or psel(414) or psel(415) or
                    psel(416) or psel(417) or psel(418) or psel(419) or
                    psel(420) or psel(421) or psel(422) or psel(423) or
                    psel(424) or psel(425) or psel(426) or psel(427) or
                    psel(428) or psel(429) or psel(430) or psel(431) or
                    psel(432) or psel(433) or psel(434) or psel(435) or
                    psel(436) or psel(437) or psel(438) or psel(439) or
                    psel(440) or psel(441) or psel(442) or psel(443) or
                    psel(444) or psel(445) or psel(446) or psel(447) or
                    psel(448) or psel(449) or psel(450) or psel(451) or
                    psel(452) or psel(453) or psel(454) or psel(455) or
                    psel(456) or psel(457) or psel(458) or psel(459) or
                    psel(460) or psel(461) or psel(462) or psel(463) or
                    psel(464) or psel(465) or psel(466) or psel(467) or
                    psel(468) or psel(469) or psel(470) or psel(471) or
                    psel(472) or psel(473) or psel(474) or psel(475) or
                    psel(476) or psel(477) or psel(478) or psel(479) or
                    psel(480) or psel(481) or psel(482) or psel(483) or
                    psel(484) or psel(485) or psel(486) or psel(487) or
                    psel(488) or psel(489) or psel(490) or psel(491) or
                    psel(492) or psel(493) or psel(494) or psel(495) or
                    psel(496) or psel(497) or psel(498) or psel(499) or
                    psel(500) or psel(501) or psel(502) or psel(503) or
                    psel(504) or psel(505) or psel(506) or psel(507) or
                    psel(508) or psel(509) or psel(510) or psel(511);
      bnslave(8) := psel(256) or psel(257) or psel(258) or psel(259) or
                    psel(260) or psel(261) or psel(262) or psel(263) or
                    psel(264) or psel(265) or psel(266) or psel(267) or
                    psel(268) or psel(269) or psel(270) or psel(271) or
                    psel(272) or psel(273) or psel(274) or psel(275) or
                    psel(276) or psel(277) or psel(278) or psel(279) or
                    psel(280) or psel(281) or psel(282) or psel(283) or
                    psel(284) or psel(285) or psel(286) or psel(287) or
                    psel(288) or psel(289) or psel(290) or psel(291) or
                    psel(292) or psel(293) or psel(294) or psel(295) or
                    psel(296) or psel(297) or psel(298) or psel(299) or
                    psel(300) or psel(301) or psel(302) or psel(303) or
                    psel(304) or psel(305) or psel(306) or psel(307) or
                    psel(308) or psel(309) or psel(310) or psel(311) or
                    psel(312) or psel(313) or psel(314) or psel(315) or
                    psel(316) or psel(317) or psel(318) or psel(319) or
                    psel(320) or psel(321) or psel(322) or psel(323) or
                    psel(324) or psel(325) or psel(326) or psel(327) or
                    psel(328) or psel(329) or psel(330) or psel(331) or
                    psel(332) or psel(333) or psel(334) or psel(335) or
                    psel(336) or psel(337) or psel(338) or psel(339) or
                    psel(340) or psel(341) or psel(342) or psel(343) or
                    psel(344) or psel(345) or psel(346) or psel(347) or
                    psel(348) or psel(349) or psel(350) or psel(351) or
                    psel(352) or psel(353) or psel(354) or psel(355) or
                    psel(356) or psel(357) or psel(358) or psel(359) or
                    psel(360) or psel(361) or psel(362) or psel(363) or
                    psel(364) or psel(365) or psel(366) or psel(367) or
                    psel(368) or psel(369) or psel(370) or psel(371) or
                    psel(372) or psel(373) or psel(374) or psel(375) or
                    psel(376) or psel(377) or psel(378) or psel(379) or
                    psel(380) or psel(381) or psel(382) or psel(383) or
                    psel(384) or psel(385) or psel(386) or psel(387) or
                    psel(388) or psel(389) or psel(390) or psel(391) or
                    psel(392) or psel(393) or psel(394) or psel(395) or
                    psel(396) or psel(397) or psel(398) or psel(399) or
                    psel(400) or psel(401) or psel(402) or psel(403) or
                    psel(404) or psel(405) or psel(406) or psel(407) or
                    psel(408) or psel(409) or psel(410) or psel(411) or
                    psel(412) or psel(413) or psel(414) or psel(415) or
                    psel(416) or psel(417) or psel(418) or psel(419) or
                    psel(420) or psel(421) or psel(422) or psel(423) or
                    psel(424) or psel(425) or psel(426) or psel(427) or
                    psel(428) or psel(429) or psel(430) or psel(431) or
                    psel(432) or psel(433) or psel(434) or psel(435) or
                    psel(436) or psel(437) or psel(438) or psel(439) or
                    psel(440) or psel(441) or psel(442) or psel(443) or
                    psel(444) or psel(445) or psel(446) or psel(447) or
                    psel(448) or psel(449) or psel(450) or psel(451) or
                    psel(452) or psel(453) or psel(454) or psel(455) or
                    psel(456) or psel(457) or psel(458) or psel(459) or
                    psel(460) or psel(461) or psel(462) or psel(463) or
                    psel(464) or psel(465) or psel(466) or psel(467) or
                    psel(468) or psel(469) or psel(470) or psel(471) or
                    psel(472) or psel(473) or psel(474) or psel(475) or
                    psel(476) or psel(477) or psel(478) or psel(479) or
                    psel(480) or psel(481) or psel(482) or psel(483) or
                    psel(484) or psel(485) or psel(486) or psel(487) or
                    psel(488) or psel(489) or psel(490) or psel(491) or
                    psel(492) or psel(493) or psel(494) or psel(495) or
                    psel(496) or psel(497) or psel(498) or psel(499) or
                    psel(500) or psel(501) or psel(502) or psel(503) or
                    psel(504) or psel(505) or psel(506) or psel(507) or
                    psel(508) or psel(509) or psel(510) or psel(511);
    end if;

    nslave := conv_integer(bnslave);

    v.prdata := apbo(nslave).prdata;

    if v.cfgsel = '1' then
      psel := (others => '0'); v.penable := '0';
    end if;

    if r.cfgsel = '1' then
      v.prdata := apbo(conv_integer(r.haddr(log2(nslaves)-1+3 downto 3))).pconfig(conv_integer(r.haddr(2 downto 2)));
      if nslaves <= conv_integer(r.haddr(log2(nslaves)-1+3 downto 3)) then
        v.prdata := (others => '0');
      end if;
    end if;

    for i in 0 to nslaves-1 loop pirq := pirq or apbo(i).pirq; end loop;

    -- AHB respons
    ahbo.hready <= r.hready;
    ahbo.hrdata <= ahbdrivedata(r.prdata);
    ahbo.hirq   <= pirq;

    if (not RESET_ALL) and (rst = '0') then
      v.penable := RES.penable; v.hready := RES.hready;
      v.psel := RES.psel; v.state := RES.state;
      v.hwrite := RES.hwrite;
      v.req := RES.req;
-- pragma translate_off
      v.haddr := RES.haddr;
-- pragma translate_on
    end if;

    rin <= v;

    -- drive APB bus
    apbaddr2 := (others => '0');
    -- MSB hex digit of extended addr must always be 0
    apbaddr2(apbmax downto 0) := r.haddr(apbmax downto 0);
    apbi.paddr   <= apbaddr2;
    apbi.pwdata  <= r.pwdata;
    apbi.pwrite  <= r.hwrite;
    apbi.penable <= r.penable;
    apbi.pirq    <= ahbi.hirq;
    apbi.testen  <= ahbi.testen;
    apbi.testoen <= ahbi.testoen;
    apbi.scanen <= ahbi.scanen;
    apbi.testrst <= ahbi.testrst;
    apbi.testin  <= ahbi.testin;

    apbi.psel <= (others => '0');
    for i in 0 to nslaves-1 loop apbi.psel(i) <= psel(i) and r.psel; end loop;

    -- Make request
    req <= r.req;

--pragma translate_off
    lapbi.paddr   <= apbaddr2;
    lapbi.pwdata  <= r.pwdata;
    lapbi.pwrite  <= r.hwrite;
    lapbi.penable <= r.penable;
    lapbi.pirq    <= ahbi.hirq;

    for i in 0 to nslaves-1 loop lapbi.psel(i) <= psel(i) and r.psel; end loop;
--pragma translate_on

  end process;

  ahbo.hindex <= hindex;
  ahbo.hconfig <= hconfig;
  ahbo.hsplit <= (others => '0');
  ahbo.hresp  <= HRESP_OKAY;

  reg : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
      if RESET_ALL and rst = '0' then
        r <= RES;
      end if;
    end if;
  end process;

-- pragma translate_off

  mon0 : if enbusmon /= 0 generate
    mon :  apbmon 
      generic map(
        asserterr   => asserterr,
        assertwarn  => assertwarn,
        pslvdisable => pslvdisable,
        napb        => nslaves)
      port map(
        rst         => rst,
        clk         => clk,
        apbi        => lapbi,
        apbo        => apbo,
        err         => open);
  end generate;

  diag : process
  type apb_memarea_type is record
     start : std_logic_vector(31 downto 8);
     stop  : std_logic_vector(31 downto 8);
  end record;
  type memmap_type is array (0 to nslaves-1) of apb_memarea_type;
  variable k : integer;
  variable mask : std_logic_vector(11 downto 0);
  variable device : std_logic_vector(11 downto 0);
  variable devicei : integer;
  variable vendor : std_logic_vector( 7 downto 0);
  variable vendori : integer;
  variable iosize : integer;
  variable iosize_unit : integer;
  variable iounit : string(1 to 5) := "byte ";
  variable memstart : std_logic_vector(11 downto 0) := IOAREA and IOMSK;
  variable L1 : line := new string'("");
  variable memmap : memmap_type;
  begin
    wait for 3 ns;
    if debug > 0 then
      print("apbctrl: APB Bridge at " & tost(memstart) & "00000 rev 1");
    end if;
    for i in 0 to nslaves-1 loop
      vendor := apbo(i).pconfig(0)(31 downto 24); 
      vendori := conv_integer(vendor);
      if vendori /= 0 then
        if debug > 1 then
          device := apbo(i).pconfig(0)(23 downto 12); 
          devicei := conv_integer(device);
          std.textio.write(L1, "apbctrl: slv" & tost(i) & ": " &                
           iptable(vendori).vendordesc  & iptable(vendori).device_table(devicei));
          std.textio.writeline(OUTPUT, L1);
          if apbo(i).pconfig(2)(apbmax downto 20) = zero32(7 downto 0) then
            mask := apbo(i).pconfig(1)(15 downto 4);
            iosize_unit := 256;
          else
            mask := apbo(i).pconfig(2)(15 downto 4);
            iosize_unit := 1048576;
          end if;
          k := 0;
          while (k<12) and (mask(k) = '0') loop k := k+1; end loop;      
          iosize := iosize_unit * 2**k; iounit := "byte ";
          if (iosize > 1023) then iosize := iosize/1024; iounit := "kbyte";
          elsif (iosize > 1048575) then iosize := iosize/1048576; iounit := "mbyte";
          end if;
          print("apbctrl:       I/O ports at " &
                tost(memstart(11 downto 8) &
                     (apbo(i).pconfig(2)(apbmax downto 20) and apbo(i).pconfig(2)(11 downto 4)) &
                     (apbo(i).pconfig(1)(31 downto 20) and apbo(i).pconfig(1)(15 downto 4))) &
                "00, size " & tost(iosize) & " " & iounit);
          if mcheck /= 0 then
            memmap(i).start := (apbo(i).pconfig(2)(31 downto 20) and
                                apbo(i).pconfig(2)(15 downto 4)) &
                               (apbo(i).pconfig(1)(31 downto 20) and
                                apbo(i).pconfig(1)(15 downto 4));
            memmap(i).stop := memmap(i).start + (2**k) * iosize_unit/256;
          end if;
        end if;
        assert (apbo(i).pindex = i) or (icheck = 0)
        report "APB slave index error on slave " & tost(i) &
          ". Detected index value " & tost(apbo(i).pindex) severity failure;
        if mcheck /= 0 then
          for j in 0 to i loop
            if memmap(i).start /= memmap(i).stop then
              assert ((memmap(i).start >= memmap(j).stop) or
                      (memmap(i).stop <= memmap(j).start) or (i = j))
                report "APB slave " & tost(i) & " memory area" &  
                " intersects with APB slave " & tost(j) & " memory area."
                severity failure;
            end if;
          end loop;
        end if;
      else
        for j in 0 to NAPBCFG-1 loop
          assert (apbo(i).pconfig(j) = zx or ccheck = 0)
            report "APB slave " & tost(i) & " appears to be disabled, " &
            "but the config record is not driven to zero"
            severity warning;
        end loop;
      end if;
    end loop;
    if nslaves < NAPBSLV then
      for i in nslaves to NAPBSLV - 1 loop
        for j in 0 to NAPBCFG-1 loop
          assert (apbo(i).pconfig(j) = zx or ccheck = 0)
            report "APB slave " & tost(i) & " is outside the range of decoded " &
            "slave indexes but the config record is not driven to zero"
            severity warning;
        end loop;  -- j
      end loop;  -- i
    end if;
    wait;
  end process;
-- pragma translate_on

end;

