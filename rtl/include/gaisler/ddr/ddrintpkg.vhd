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
-- Package:     ddrintpkg
-- File:        ddrintpkg.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Internal components and types for DDR SDRAM controllers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gencomp.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.ddrpkg.all;

package ddrintpkg is

  -----------------------------------------------------------------------------
  -- DDR2SPA types and components
  -----------------------------------------------------------------------------
  component ddr2buf is
    generic (
      tech   : integer := 0;
      wabits : integer := 6;
      wdbits : integer := 8;
      rabits : integer := 6;
      rdbits : integer := 8;
      sepclk : integer := 0;
      wrfst  : integer := 0;
      testen : integer := 0);
    port (
      rclk     : in std_ulogic;
      renable  : in std_ulogic;
      raddress : in std_logic_vector((rabits -1) downto 0);
      dataout  : out std_logic_vector((rdbits -1) downto 0);
      wclk     : in std_ulogic;
      write    : in std_ulogic;
      writebig : in std_ulogic;
      waddress : in std_logic_vector((wabits -1) downto 0);
      datain   : in std_logic_vector((wdbits -1) downto 0);
      testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0));
  end component;

  type ddr_request_type is record
    startaddr : std_logic_vector(31 downto 0);
    endaddr   : std_logic_vector(9 downto 0);
    hsize     : std_logic_vector(2 downto 0);
    hwrite    : std_ulogic;
    hio       : std_ulogic;
    maskdata  : std_ulogic;
    maskcb    : std_ulogic;
    burst     : std_ulogic;
  end record;

  type ddr_response_type is record
    done_tog  : std_ulogic;
    rctr_gray : std_logic_vector(3 downto 0);
    readerr   : std_ulogic;
  end record;

  constant ddr_request_none: ddr_request_type :=
    ((others => '0'), (others => '0'), "000", '0','0','0','0','0');

  constant ddr_response_none: ddr_response_type := ('0',"0000",'0');

  component ddr2spax_ahb is
    generic (
      hindex     : integer := 0;
      haddr      : integer := 0;
      hmask      : integer := 16#f00#;
      ioaddr     : integer := 16#000#;
      iomask     : integer := 16#fff#;
      burstlen   : integer := 8;
      nosync     : integer := 0;
      ahbbits    : integer := ahbdw;
      revision   : integer := 0;
      devid      : integer := GAISLER_DDR2SP;
      ddrbits    : integer := 32;
      regarea    : integer := 0
   );
   port (
      rst       : in  std_ulogic;
      clk_ahb   : in  std_ulogic;
      ahbsi     : in  ahb_slv_in_type;
      ahbso     : out ahb_slv_out_type;
      request   : out ddr_request_type;
      start_tog : out std_logic;
      response  : in ddr_response_type;
      wbwaddr   : out std_logic_vector(log2(burstlen) downto 0);
      wbwdata   : out std_logic_vector(ahbbits-1 downto 0);
      wbwrite   : out std_logic;
      wbwritebig: out std_logic;
      rbraddr   : out std_logic_vector(log2(burstlen*32/ahbbits)-1 downto 0);
      rbrdata   : in std_logic_vector(ahbbits-1 downto 0);
      hwidth    : in std_logic;
      beid      : in std_logic_vector(3 downto 0)
   );
  end component;

  component ft_ddr2spax_ahb is
    generic (
      hindex     : integer := 0;
      haddr      : integer := 0;
      hmask      : integer := 16#f00#;
      ioaddr     : integer := 16#000#;
      iomask     : integer := 16#fff#;
      burstlen   : integer := 8;
      nosync     : integer := 0;
      ahbbits    : integer := 64;
      bufbits    : integer := 96;
      ddrbits    : integer := 16;
      hwidthen   : integer := 0;
      revision   : integer := 0;
      devid      : integer := GAISLER_DDR2SP
   );
   port (
      rst        : in  std_ulogic;
      clk_ahb    : in  std_ulogic;
      ahbsi      : in  ahb_slv_in_type;
      ahbso      : out ahb_slv_out_type;
      ce         : out std_logic;
      request    : out ddr_request_type;
      start_tog  : out std_logic;
      response   : in  ddr_response_type;
      wbwaddr    : out std_logic_vector(log2(burstlen)-2 downto 0);
      wbwdata    : out std_logic_vector(bufbits-1 downto 0);
      wbwrite    : out std_logic;
      wbwritebig : out std_logic;
      rbraddr    : out std_logic_vector(log2(burstlen*32/ahbbits)-1 downto 0);
      rbrdata    : in  std_logic_vector(bufbits-1 downto 0);
      hwidth     : in  std_logic;
      synccfg    : in  std_logic;
      request2   : out ddr_request_type;
      start_tog2 : out std_logic;
      beid       : in  std_logic_vector(3 downto 0)
   );
  end component;

  constant FTFE_BEID_DDR2  : std_logic_vector(3 downto 0) := "0000";
  constant FTFE_BEID_SDR   : std_logic_vector(3 downto 0) := "0001";
  constant FTFE_BEID_DDR1  : std_logic_vector(3 downto 0) := "0010";
  constant FTFE_BEID_SSR   : std_logic_vector(3 downto 0) := "0011";
  constant FTFE_BEID_LPDDR2: std_logic_vector(3 downto 0) := "0100";

  component ddr2spax_ddr is
    generic (
      ddrbits    : integer := 32;
      burstlen   : integer := 8;
      MHz        : integer := 100;
      TRFC       : integer := 130;
      col        : integer := 9;
      Mbyte      : integer := 8;
      pwron      : integer := 0;
      oepol      : integer := 0;
      readdly    : integer := 1;
      odten      : integer := 0;
      octen      : integer := 0;
      dqsgating  : integer := 0;
      nosync     : integer := 0;
      eightbanks : integer range 0 to 1 := 0; -- Set to 1 if 8 banks instead of 4
      dqsse      : integer range 0 to 1 := 0;  -- single ended DQS
      ddr_syncrst: integer range 0 to 1 := 0;
      chkbits    : integer := 0;
      bigmem     : integer range 0 to 1 := 0;
      raspipe    : integer range 0 to 1 := 0;
      hwidthen   : integer range 0 to 1 := 0;
      phytech    : integer := 0;
      hasdqvalid : integer := 0;
      rstdel     : integer := 200;
      phyptctrl  : integer := 0;
      scantest   : integer := 0;
      dis_caslat : integer := 0;
      dis_init   : integer := 0;
      cke_rst    : integer := 0
   );
   port (
      ddr_rst  : in  std_ulogic;
      clk_ddr  : in  std_ulogic;
      request  : in  ddr_request_type;
      start_tog: in  std_logic;
      response : out ddr_response_type;
      sdi      : in  ddrctrl_in_type;
      sdo      : out ddrctrl_out_type;
      wbraddr  : out std_logic_vector(log2((16*burstlen)/ddrbits) downto 0);
      wbrdata  : in  std_logic_vector(2*(ddrbits+chkbits)-1 downto 0);
      rbwaddr  : out std_logic_vector(log2((16*burstlen)/ddrbits)-1 downto 0);
      rbwdata  : out std_logic_vector(2*(ddrbits+chkbits)-1 downto 0);
      rbwrite  : out std_logic;
      hwidth   : in  std_ulogic;
      -- dynamic sync (nosync=2)
      reqsel   : in  std_ulogic;
      frequest : in  ddr_request_type;
      response2: out ddr_response_type;
      testen   : in  std_ulogic;
      testrst  : in  std_ulogic;
      testoen  : in  std_ulogic
   );
  end component;

  -----------------------------------------------------------------------------
  -- DDRSPA types and components
  -----------------------------------------------------------------------------

  component ddr1spax_ddr is
    generic (
      ddrbits    : integer := 32;
      burstlen   : integer := 8;
      MHz        : integer := 100;
      col        : integer := 9;
      Mbyte      : integer := 8;
      pwron      : integer := 0;
      oepol      : integer := 0;
      mobile     : integer := 0;
      confapi    : integer := 0;
      conf0      : integer := 0;
      conf1      : integer := 0;
      nosync     : integer := 0;
      ddr_syncrst: integer range 0 to 1 := 0;
      chkbits    : integer := 0;
      hasdqvalid : integer := 0;
      readdly    : integer := 0;
      regoutput  : integer := 1;
      ddr400     : integer := 1;
      rstdel     : integer := 200;
      phyptctrl  : integer := 0;
      scantest   : integer := 0
      );
    port (
      ddr_rst  : in  std_ulogic;
      clk_ddr  : in  std_ulogic;
      request  : in  ddr_request_type;
      start_tog: in  std_logic;
      response : out ddr_response_type;
      sdi      : in  ddrctrl_in_type;
      sdo      : out ddrctrl_out_type;
      wbraddr  : out std_logic_vector(log2((16*burstlen)/ddrbits) downto 0);
      wbrdata  : in  std_logic_vector(2*(ddrbits+chkbits)-1 downto 0);
      rbwaddr  : out std_logic_vector(log2((16*burstlen)/ddrbits)-1 downto 0);
      rbwdata  : out std_logic_vector(2*(ddrbits+chkbits)-1 downto 0);
      rbwrite  : out std_logic;
      reqsel   : in std_ulogic;
      frequest : in  ddr_request_type;
      response2: out ddr_response_type;
      testen   : in std_ulogic;
      testrst  : in std_ulogic;
      testoen  : in std_ulogic
      );
  end component;

  -----------------------------------------------------------------------------
  -- Other components re-using sub-components above
  -----------------------------------------------------------------------------
  component ahb2avl_async_be is
    generic (
      avldbits  : integer := 32;
      avlabits  : integer := 20;
      ahbbits   : integer := ahbdw;
      burstlen  : integer := 8;
      nosync    : integer := 0
      );
    port (
      rst : in std_ulogic;
      clk : in std_ulogic;
      avlsi : out ddravl_slv_in_type;
      avlso : in  ddravl_slv_out_type;
      request: in ddr_request_type;
      start_tog: in std_ulogic;
      response: out ddr_response_type;
      wbraddr  : out std_logic_vector(log2((32*burstlen)/avldbits) downto 0);
      wbrdata  : in std_logic_vector(avldbits-1 downto 0);
      rbwaddr  : out std_logic_vector(log2((32*burstlen)/avldbits)-1 downto 0);
      rbwdata  : out std_logic_vector(avldbits-1 downto 0);
      rbwrite  : out std_logic
      );
  end component;

  -----------------------------------------------------------------------------
  -- Gray-code routines
  -----------------------------------------------------------------------------
  function lin2gray(l: std_logic_vector) return std_logic_vector;
  function gray2lin(g: std_logic_vector) return std_logic_vector;
  function nextgray(g: std_logic_vector) return std_logic_vector;

  -----------------------------------------------------------------------------
  -- Data-mask routines
  -----------------------------------------------------------------------------
  function maskfirst(addr: std_logic_vector(9 downto 0); ddrbits: integer) return std_logic_vector;
  function masklast(addr: std_logic_vector(9 downto 0); hsize: std_logic_vector(2 downto 0); ddrbits: integer) return std_logic_vector;
  function masksub32(addr: std_logic_vector(9 downto 0); hsize: std_logic_vector(2 downto 0); ddrbits: integer) return std_logic_vector;

end package;

package body ddrintpkg is

  function lin2gray(l: std_logic_vector) return std_logic_vector is
    variable lx,r: std_logic_vector(l'length-1 downto 0);
  begin
    lx := l;
    r(l'length-1) := lx(l'length-1);
    if l'length > 1 then
      r(l'length-2 downto 0) := lx(l'length-1 downto 1) xor lx(l'length-2 downto 0);
    end if;
    return r;
  end lin2gray;

  function gray2lin(g: std_logic_vector) return std_logic_vector is
    variable x: std_logic_vector(15 downto 0);
    variable r: std_logic_vector(g'length-1 downto 0);
  begin
    x := (others => '0');
    x(g'length-1 downto 0) := g;
    if g'length > 1 then
      x(14 downto 0) := x(14 downto 0) xor x(15 downto 1);
    end if;
    if g'length > 2 then
      x(13 downto 0) := x(13 downto 0) xor x(15 downto 2);
    end if;
    if g'length > 4 then
      x(11 downto 0) := x(11 downto 0) xor x(15 downto 4);
    end if;
    if g'length > 8 then
      x(7 downto 0) := x(7 downto 0) xor x(15 downto 8);
    end if;
    r := x(g'length-1 downto 0);
    return r;
  end gray2lin;

  function nextgray(g: std_logic_vector) return std_logic_vector is
    variable gx,r: std_logic_vector(g'length-1 downto 0);
    variable gx3,r3: std_logic_vector(2 downto 0) := "000";
    variable l,nl: std_logic_vector(g'length-1 downto 0);
  begin
    gx := g;
    if gx'length = 1 then
      r(0) := not gx(0);
    elsif gx'length = 2 then
      r(1) := gx(0);
      r(0) := not gx(1);
    elsif gx'length = 3 then
--      r(2) := (gx(1) or gx(0)) and (not gx(2) or not gx(0));
--      r(1) := (gx(1) or gx(0)) and (gx(2) or not gx(0));
--      r(0) := gx(2) xor gx(1);
      gx3 := gx(2 downto 0);
      case gx3 is
        when "000"  => r3 := "001";
        when "001"  => r3 := "011";
        when "011"  => r3 := "010";
        when "010"  => r3 := "110";
        when "110"  => r3 := "111";
        when "111"  => r3 := "101";
        when "101"  => r3 := "100";
        when others => r3 := "000";
      end case;
      r(2 downto 0) := r3;
    else
      l := gray2lin(g);
      nl := std_logic_vector(unsigned(l)+1);
      r := lin2gray(nl);
    end if;
    return r;
  end nextgray;

  function maskfirst(addr: std_logic_vector(9 downto 0); ddrbits: integer) return std_logic_vector is
    variable r: std_logic_vector(ddrbits/4-1 downto 0);
    variable a32: std_logic_vector(3 downto 2);
    variable a432: std_logic_vector(4 downto 2);
  begin
    r := (others => '0');
    a32 := addr(3 downto 2);
    a432 := addr(4 downto 2);
    case ddrbits is
      when 32 =>
        if addr(2)='0' then r := "00000000";
        else                r := "11110000";
        end if;
      when 64 =>
        case a32 is
          when "00"   => r := x"0000";
          when "01"   => r := x"F000";
          when "10"   => r := x"FF00";
          when others => r := x"FFF0";
        end case;
      when 128 =>
        case a432 is
          when "000"  => r := x"00000000";
          when "001"  => r := x"F0000000";
          when "010"  => r := x"FF000000";
          when "011"  => r := x"FFF00000";
          when "100"  => r := x"FFFF0000";
          when "101"  => r := x"FFFFF000";
          when "110"  => r := x"FFFFFF00";
          when others => r := x"FFFFFFF0";
        end case;
      when others =>
        --pragma translate_off
        assert ddrbits=16 report "Unsupported DDR width" severity failure;
        --pragma translate_on
        null;
    end case;
    return r;
  end maskfirst;

  function masklast(addr: std_logic_vector(9 downto 0);
                    hsize: std_logic_vector(2 downto 0); ddrbits: integer)
    return std_logic_vector is
    variable r: std_logic_vector(ddrbits/4-1 downto 0);
    variable xaddr: std_logic_vector(9 downto 0);
    variable a32: std_logic_vector(3 downto 2);
    variable a432: std_logic_vector(4 downto 2);
  begin
    xaddr := addr;
    if hsize(2)='1' then
      xaddr(3 downto 2) := "11";
      xaddr(3 downto 2) := "11";
    end if;
    if hsize(2)='1' and hsize(0)='1' then
      xaddr(4) := '1';
    end if;
    if hsize(1 downto 0)="11" then
      xaddr(2) := '1';
    end if;
    a32 := xaddr(3 downto 2);
    a432 := xaddr(4 downto 2);
    r := (others => '0');
    case ddrbits is
      when 32 =>
        if xaddr(2)='0' then r := "00001111";
        else                 r := "00000000";
        end if;
      when 64 =>
        case a32 is
          when "00"   => r := x"0FFF";
          when "01"   => r := x"00FF";
          when "10"   => r := x"000F";
          when others => r := x"0000";
        end case;
      when 128 =>
        case a432 is
          when "000"  => r := x"0FFFFFFF";
          when "001"  => r := x"00FFFFFF";
          when "010"  => r := x"000FFFFF";
          when "011"  => r := x"0000FFFF";
          when "100"  => r := x"00000FFF";
          when "101"  => r := x"000000FF";
          when "110"  => r := x"0000000F";
          when others => r := x"00000000";
        end case;
      when others =>
        --pragma translate_off
        assert ddrbits=16 report "Unsupported DDR width" severity failure;
        --pragma translate_on
        null;
    end case;
    return r;
  end masklast;

  function masksub32(addr: std_logic_vector(9 downto 0); hsize: std_logic_vector(2 downto 0); ddrbits: integer)
    return std_logic_vector is
    variable r: std_logic_vector(ddrbits/4-1 downto 0);
    variable r16: std_logic_vector(3 downto 0);
    variable a10: std_logic_vector(1 downto 0);
  begin
    r16 := (others => '0');
    if hsize(2 downto 1)="00" then
      r16 := addr(1) & addr(1) & (not addr(1)) & (not addr(1));
      if hsize(0)='0' then
        r16 := r16 or (addr(0) & (not addr(0)) & addr(0) & (not addr(0)));
      end if;
    end if;
    r := (others => '0');
    for x in 0 to ddrbits/16-1 loop
      r(x*4+3 downto x*4) := r16;
    end loop;
    return r;
  end masksub32;

end;

