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
-- Entity: 	mul
-- File:	mul.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	This unit implements signed/unsigned 32-bit multiply module,
--		producing a 64-bit result.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.stdlib.all;
use work.multlib.all;
use work.arith.all;
use work.gencomp.all;

entity mul32 is
generic (
    tech    : integer := 0;
    multype : integer range 0 to 3 := 0;
    pipe    : integer range 0 to 1 := 0;
    mac     : integer range 0 to 1 := 0;
    arch    : integer range 0 to 3 := 0;
    scantest: integer := 0
);
port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    holdn   : in  std_ulogic;
    muli    : in  mul32_in_type;
    mulo    : out mul32_out_type;
    testen  : in  std_ulogic := '0';
    testrst : in  std_ulogic := '1'
);
end;

architecture rtl of mul32 is

--attribute sync_set_reset : string;
--attribute sync_set_reset of rst : signal is "true";

constant m16x16 : integer := 0;
constant m32x8  : integer := 1;
constant m32x16 : integer := 2;
constant m32x32 : integer := 3;

constant MULTIPLIER : integer := multype;
constant MULPIPE : boolean := ((multype = 0) or (multype = 3)) and (pipe = 1);
constant MACEN  : boolean := (multype = 0) and (mac = 1);

type mul_regtype is record
  acc    : std_logic_vector(63 downto 0);
  state  : std_logic_vector(1 downto 0);
  start  : std_logic;
  ready  : std_logic;
  nready : std_logic;
end record;

type mac_regtype is record
  mmac, xmac    : std_logic;
  msigned, xsigned : std_logic;
end record;

constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
constant ASYNC_RESET : boolean := GRLIB_CONFIG_ARRAY(grlib_async_reset_enable) = 1;
constant MULRES : mul_regtype := (
  acc     => (others => '0'),
  state   => (others => '0'),
  start   => '0',
  ready   => '0',
  nready  => '0');
constant MACRES : mac_regtype := (
  mmac    => '0',
  xmac    => '0',
  msigned => '0',
  xsigned => '0');

signal arst : std_ulogic;
signal rm, rmin : mul_regtype;
signal mm, mmin : mac_regtype;
signal ma, mb : std_logic_vector(32 downto 0);
signal prod : std_logic_vector(65 downto 0);
signal mreg : std_logic_vector(49 downto 0);
signal vcc : std_logic;

begin

  vcc <= '1';

  arst <= testrst when (ASYNC_RESET and scantest/=0 and testen/='0') else
          rst when ASYNC_RESET else
          '1';

  mulcomb : process(rst, rm, muli, mreg, prod, mm)
  variable mop1, mop2 : std_logic_vector(32 downto 0);
  variable acc, acc1, acc2 : std_logic_vector(48 downto 0);
  variable zero, rsigned, rmac : std_logic;
  variable v : mul_regtype;
  variable w : mac_regtype;
  constant CZero: std_logic_vector(47 downto 0) := "000000000000000000000000000000000000000000000000";
  begin

    v := rm; w := mm; v.start := muli.start; v.ready := '0'; v.nready := '0';
    mop1 := muli.op1; mop2 := muli.op2;
    acc1 := (others => '0'); acc2 := (others => '0'); zero := '0';
    w.mmac := muli.mac; w.xmac := mm.mmac;
    w.msigned := muli.signed; w.xsigned := mm.msigned;

    if MULPIPE then rsigned := mm.xsigned; rmac := mm.xmac;
    else rsigned := mm.msigned; rmac := mm.mmac; end if;

-- select input 2 to accumulator
    case MULTIPLIER is
    when m16x16 =>
      acc2(32 downto 0) := mreg(32 downto 0);
    when m32x8  =>
      acc2(40 downto 0) := mreg(40 downto 0);
    when m32x16 =>
      acc2(48 downto 0) := mreg(48 downto 0);
    when others => null;
    end case;

-- state machine + inputs to multiplier and accumulator input 1
    case rm.state is
    when "00" =>
      case MULTIPLIER is
      when m16x16 =>
        mop1(16 downto 0) := '0' & muli.op1(15 downto 0);
        mop2(16 downto 0) := '0' & muli.op2(15 downto 0);
	if MULPIPE and (rm.ready = '1' ) then
	  acc1(32 downto 0) := rm.acc(48 downto 16);
        else acc1(32 downto 0) := '0' & rm.acc(63 downto 32); end if;
      when m32x8 =>
        mop1 := muli.op1;
        mop2(8 downto 0) := '0' & muli.op2(7 downto 0);
        acc1(40 downto 0) := '0' & rm.acc(63 downto 24);
      when m32x16 =>
        mop1 := muli.op1;
        mop2(16 downto 0) := '0' & muli.op2(15 downto 0);
        acc1(48 downto 0) := '0' & rm.acc(63 downto 16);
      when others => null;
      end case;
      if (rm.start = '1') then v.state := "01"; end if;
    when "01" =>
      case MULTIPLIER is
      when m16x16 =>
        mop1(16 downto 0) := muli.op1(32 downto 16);
        mop2(16 downto 0) := '0' & muli.op2(15 downto 0);
        if MULPIPE then acc1(32 downto 0) := '0' & rm.acc(63 downto 32); end if;
        v.state := "10";
      when m32x8 =>
        mop1 := muli.op1; mop2(8 downto 0) := '0' & muli.op2(15 downto 8);
        v.state := "10";
      when m32x16 =>
        mop1 := muli.op1; mop2(16 downto 0) := muli.op2(32 downto 16);
        v.state := "00";
      when others => null;
      end case;
    when "10" =>
      case MULTIPLIER is
      when m16x16 =>
        mop1(16 downto 0) := '0' & muli.op1(15 downto 0);
        mop2(16 downto 0) := muli.op2(32 downto 16);
	if MULPIPE then acc1 := (others => '0'); acc2 := (others => '0');
        else acc1(32 downto 0) := rm.acc(48 downto 16); end if;
        v.state := "11";
      when m32x8 =>
        mop1 := muli.op1; mop2(8 downto 0) := '0' & muli.op2(23 downto 16);
        acc1(40 downto 0) := rm.acc(48 downto 8);
        v.state := "11";
      when others => null;
      end case;
    when others =>
      case MULTIPLIER is
      when m16x16 =>
        mop1(16 downto 0) := muli.op1(32 downto 16);
        mop2(16 downto 0) := muli.op2(32 downto 16);
        if MULPIPE then acc1(32 downto 0) := rm.acc(48 downto 16);
        else acc1(32 downto 0) := rm.acc(48 downto 16); end if;
        v.state := "00";
      when m32x8 =>
        mop1 := muli.op1; mop2(8 downto 0) := muli.op2(32 downto 24);
        acc1(40 downto 0) := rm.acc(56 downto 16);
        v.state := "00";
      when others => null;
      end case;
    end case;

-- optional UMAC/SMAC support

    if MACEN then
      if ((muli.mac and muli.signed) = '1') then
        mop1(16) := muli.op1(15); mop2(16) := muli.op2(15);
      end if;
      if rmac = '1' then
         acc1(32 downto 0) := muli.acc(32 downto 0);--muli.y(0) & muli.asr18;
         if rsigned = '1' then acc2(39 downto 32) := (others => mreg(31));
         else acc2(39 downto 32) := (others => '0'); end if;
      end if;
       acc1(39 downto 33) := muli.acc(39 downto 33);--muli.y(7 downto 1);
    end if;


-- accumulator for iterative multiplication (and MAC)
-- pragma translate_off
    if not (is_x(acc1 & acc2)) then
-- pragma translate_on
    case MULTIPLIER is
    when m16x16 =>
      if MACEN then
        acc(39 downto 0) := acc1(39 downto 0) + acc2(39 downto 0);
      else
        acc(32 downto 0) := acc1(32 downto 0) + acc2(32 downto 0);
      end if;
    when m32x8 =>
      acc(40 downto 0) := acc1(40 downto 0) + acc2(40 downto 0);
    when m32x16 =>
      acc(48 downto 0) := acc1(48 downto 0) + acc2(48 downto 0);
    when m32x32 =>
      v.acc(31 downto 0) := prod(63 downto 32);
    when others => null;
    end case;
-- pragma translate_off
    end if;
-- pragma translate_on

-- save intermediate result to accumulator
    case rm.state is
    when "00" =>
      case MULTIPLIER is
      when m16x16 =>
	if MULPIPE and (rm.ready = '1' ) then
          v.acc(48 downto 16) := acc(32 downto 0);
	  if rsigned = '1' then
	    v.acc(63 downto 49) := (others => acc(32));
	  end if;
	else
	  v.acc(63 downto 32) := acc(31 downto 0);
	end if;
      when m32x8  => v.acc(63 downto 24) := acc(39 downto 0);
      when m32x16 => v.acc(63 downto 16) := acc(47 downto 0);
      when others => null;
      end case;
    when "01" =>
      case MULTIPLIER is
      when m16x16 =>
	if MULPIPE then v.acc := (others => '0');
	else v.acc := CZero(31 downto 0) & mreg(31 downto 0); end if;
      when m32x8 =>
        v.acc := CZero(23 downto 0) & mreg(39 downto 0);
	if muli.signed = '1' then v.acc(48 downto 40) := (others => acc(40)); end if;
      when m32x16 =>
        v.acc := CZero(15 downto 0) & mreg(47 downto 0); v.ready := '1';
	if muli.signed = '1' then v.acc(63 downto 48) := (others => acc(48)); end if;
      when others => null;
      end case;
      v.nready := '1';
    when "10" =>
      case MULTIPLIER is
      when m16x16 =>
	if MULPIPE then
	  v.acc := CZero(31 downto 0) & mreg(31 downto 0);
	else
	  v.acc(48 downto 16) := acc(32 downto 0);
	end if;
      when m32x8 => v.acc(48 downto 8) := acc(40 downto 0);
	if muli.signed = '1' then v.acc(56 downto 49) := (others => acc(40)); end if;
      when others => null;
      end case;
    when others =>
      case MULTIPLIER is
      when m16x16 =>
	if MULPIPE then
	  v.acc(48 downto 16) := acc(32 downto 0);
	else
          v.acc(48 downto 16) := acc(32 downto 0);
	  if rsigned = '1' then
	    v.acc(63 downto 49) := (others => acc(32));
	  end if;
	end if;
        v.ready := '1';
      when m32x8 => v.acc(56 downto 16) := acc(40 downto 0); v.ready := '1';
	if muli.signed = '1' then v.acc(63 downto 57) := (others => acc(40)); end if;
      when others => null;
      end case;
    end case;

-- drive result and condition codes
    if (muli.flush = '1') then v.state := "00"; v.start := '0'; end if;
    if (not ASYNC_RESET) and (not RESET_ALL) and (rst = '0') then
      v.nready := MULRES.nready; v.ready := MULRES.ready;
      v.state := MULRES.state; v.start := MULRES.start;
    end if;
    rmin <= v; ma <= mop1; mb <= mop2; mmin <= w;
    if MULPIPE then mulo.ready <= rm.ready; mulo.nready <= rm.nready;
    else mulo.ready <= v.ready; mulo.nready <= v.nready;   end if;

    case MULTIPLIER is
    when m16x16 =>
      if rm.acc(31 downto 0) = CZero(31 downto 0) then zero := '1'; end if;
      if MACEN and (rmac = '1') then
        mulo.result(39 downto 0) <= acc(39 downto 0);
	if rsigned = '1' then
          mulo.result(63 downto 40) <= (others => acc(39));
	else
          mulo.result(63 downto 40) <= (others => '0');
	end if;
      else
        mulo.result(39 downto 0) <= v.acc(39 downto 32) & rm.acc(31 downto 0);
        mulo.result(63 downto 40) <= v.acc(63 downto 40);
      end if;
      mulo.icc <= rm.acc(31) & zero & "00";
    when m32x8 =>
      if (rm.acc(23 downto 0) = CZero(23 downto 0)) and
         (v.acc(31 downto 24) = CZero(7 downto 0))
      then zero := '1'; end if;
      mulo.result <= v.acc(63 downto 24) & rm.acc(23 downto 0);
      mulo.icc <= v.acc(31) & zero & "00";
    when m32x16 =>
      if (rm.acc(15 downto 0) = CZero(15 downto 0)) and
         (v.acc(31 downto 16) = CZero(15 downto 0))
      then zero := '1'; end if;
      mulo.result <= v.acc(63 downto 16) & rm.acc(15 downto 0);
      mulo.icc <= v.acc(31) & zero & "00";
    when m32x32 =>
--      mulo.result <= rm.acc(31 downto 0) & prod(31 downto 0);
      mulo.result <= prod(63 downto 0);
      mulo.icc(1 downto 0) <= "00";
      if prod(31 downto 0) = zero32 then mulo.icc(2) <= '1' ;
      else mulo.icc(2) <= '0'; end if;
      mulo.icc(3) <= prod(31);
    when others => null;
      mulo.result <= (others => '-');
      mulo.icc <= (others => '-');
    end case;

  end process;

  xm1616 : if MULTIPLIER = m16x16 generate
    m1616 : techmult generic map (tech, arch, 17, 17, pipe+1, pipe)
      port map (ma(16 downto 0), mb(16 downto 0), clk, holdn, vcc,  prod(33 downto 0));
    syncrregs : if not ASYNC_RESET generate
      reg : process(clk)
      begin
        if rising_edge(clk) then
          if (holdn = '1') then
            mm <= mmin;
            mreg(33 downto 0) <= prod(33 downto 0);
          end if;
          if RESET_ALL and (rst = '0') then
            mm <= MACRES;
            mreg(33 downto 0) <= (others => '0');
          end if;
        end if;
      end process;
    end generate syncrregs;
    asyncrregs : if ASYNC_RESET generate
      reg : process(clk, arst)
      begin
        if (arst = '0') then
          mm <= MACRES;
          mreg(33 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
          if (holdn = '1') then
            mm <= mmin;
            mreg(33 downto 0) <= prod(33 downto 0);
          end if;
        end if;
      end process;
    end generate asyncrregs;
    mreg(49 downto 34) <= (others => '0');
    prod(65 downto 34) <= (others => '0');
  end generate;
  xm3208 : if MULTIPLIER = m32x8 generate
    m3208 : techmult generic map (tech, arch, 33, 8, 2, 1)
      port map (ma(32 downto 0), mb(8 downto 0), clk, holdn, vcc,  mreg(41 downto 0));
    mm <= ('0', '0', '0', '0');
    mreg(49 downto 42) <= (others => '0');
    prod <= (others => '0');
  end generate;

  xm3216 : if MULTIPLIER = m32x16 generate
    m3216 : techmult generic map (tech, arch, 33, 17, 2, 1)
      port map (ma(32 downto 0), mb(16 downto 0), clk, holdn, vcc,  mreg(49 downto 0));
    mm <= ('0', '0', '0', '0');
    prod <= (others => '0');
  end generate;

  xm3232 : if MULTIPLIER = m32x32 generate
    m3232 : techmult generic map (tech, arch, 33, 33, pipe+1, pipe)
      port map (ma(32 downto 0), mb(32 downto 0), clk, holdn, vcc,  prod(65 downto 0));
    mm <= ('0', '0', '0', '0');
    mreg <= (others => '0');
  end generate;

  syncrregs : if not ASYNC_RESET generate
    reg : process(clk)
    begin
      if rising_edge(clk) then
        if (holdn = '1') then rm <= rmin; end if;
        if (rst = '0') then
          if RESET_ALL then
            rm <= MULRES;
          else
            rm.nready <= MULRES.nready; rm.ready <= MULRES.ready;
            rm.state <= MULRES.state; rm.start <= MULRES.start;
          end if;
        end if;
      end if;
    end process;
  end generate syncrregs;
  asyncrregs : if ASYNC_RESET generate
    reg : process(clk, arst)
    begin
      if (arst = '0') then
        rm <= MULRES;
      elsif rising_edge(clk) then
        if (holdn = '1') then rm <= rmin; end if;
      end if;
    end process;
  end generate asyncrregs;

end;

