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
-- Entity:      synciotest
-- File:        synciotest.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Synchronous I/O test module
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdlib.all;

entity synciotest is
  generic (
    ninputs : integer := 1;
    noutputs : integer := 1;
    nbidir : integer := 1;
    dirmode: integer range 0 to 2 := 0  -- 0=both, 1=in-only, 2=out-only
    );
  port (
    clk: in std_ulogic;
    rstn: in std_ulogic;
    datain: in std_logic_vector(ninputs+nbidir-1 downto 0);
    dataout: out std_logic_vector(noutputs+nbidir-1 downto 0);
    -- 000=stopped, 001=input 010=output one-by-one, 011=output prng
    -- 110=on-off 111=on-off with oe toggle
    -- bit 5:3 inverted copy of 2:0, otherwise stopped
    tmode: in std_logic_vector(5 downto 0);
    tmodeact: out std_ulogic;
    tmodeoe: out std_ulogic            -- 0=input, 1=output
    );
end;

architecture rtl of synciotest is
  constant bytelanes_in : integer := (ninputs+nbidir)/8;  -- rounded down
  constant bytelanes_out : integer := (noutputs+nbidir+7)/8;  -- rounded up

  function int_max(i1,i2: integer) return integer is
  begin
    if i1>i2 then return i1; else return i2; end if;
  end int_max;

  constant bytelanes_max: integer := int_max(bytelanes_in, bytelanes_out);

  -- LFSR with period 255 (x^8+x^6+x^5+x^4+1)
  -- Rotate 7 steps each time to remove correlation between bits
  -- between successive samples
  -- Step    State -->shift direction--->
  --          *8    7    *6    *5    *4     3     2     1
  -- 0         a    b     c     d     e     f     g     h
  -- 1         h    a    hb    hc    hd     e     f     g
  -- 2         g    h    ga   ghb   ghc    hd     e     f
  -- 3         f    g    fh   fga  fghb   ghc    hd     e
  -- 4         e    f    eg   efh  efga  fghb   ghc    hd
  -- 5        hd    e   hdf  hdeg   def  efga  fghb   ghc
  -- 6       ghc   hd  ghce  gcdf   cde   def  efga  fghb
  -- 7      fghb  ghc  fgbd  fbce  hbcd   cde   def  efga
  subtype lfsrstate is std_logic_vector(8 downto 1);
  function nextlfsr (s: lfsrstate) return lfsrstate is
    variable nsx: lfsrstate;
    variable a,b,c,d,e,f,g,h: std_ulogic;
  begin
    a := s(8);
    b := s(7);
    c := s(6);
    d := s(5);
    e := s(4);
    f := s(3);
    g := s(2);
    h := s(1);
    nsx := (f xor g xor h xor b) & (g xor h xor c) & (f xor g xor b xor d) & (f xor b xor c xor e)
           & (h xor b xor c xor d) & (c xor d xor e) & (d xor e xor f) & (e xor f xor g xor a);
    return nsx;
  end nextlfsr;

  type synciotest_regs is record
    datareg: std_logic_vector(bytelanes_max*8-1 downto 0);
  end record;

  signal r,nr: synciotest_regs;

begin

  comb: process(rstn, tmode, datain, r)
    variable v: synciotest_regs;
    variable nls: std_logic_vector(bytelanes_max*8-1 downto 0);
    variable o: std_logic_vector(noutputs+nbidir-1 downto 0);
    variable op: std_logic_vector(2**log2(bytelanes_out*8)-1 downto 0);
    variable vact: std_ulogic;
    variable voe: std_ulogic;
    variable vrst, dx: std_logic_vector(bytelanes_max*8-1 downto 0);
  begin
    v := r;
    o := r.datareg(noutputs+nbidir-1 downto 0);
    op := (others => '0');
    vact := '0';
    voe := tmode(1);
    for x in 0 to bytelanes_max-1 loop
      nls(x*8+7 downto x*8) := nextlfsr(r.datareg(x*8+7 downto x*8));
    end loop;
    vrst := (others => '0');
    for x in 0 to bytelanes_max-1 loop
      vrst(x*8+7 downto x*8) := std_logic_vector(to_unsigned(x+1,8));
    end loop;
    dx := r.datareg xor vrst;
    case tmode is
      when "110001" =>
        -- Use datareg as sampled input and LFSR state, compare input with
        -- expected next state
        if dirmode /= 2 then
          vact := '1';
          o(o'high downto nbidir) := (others => '0');
          for x in 0 to bytelanes_in-1 loop
            if datain(x*8+7 downto x*8) /= nls(x*8+7 downto x*8) then
              o(nbidir+(x mod noutputs)) := '1';
            end if;
            v.datareg(x*8+7 downto x*8) := datain(x*8+7 downto x*8);
          end loop;
          -- handle ninputs % 8 != 0 by re-using bottom byte lane LFSR
          if ninputs+nbidir > bytelanes_in*8 then
            if datain(ninputs+nbidir-1 downto 8*bytelanes_in) /= nls(ninputs+nbidir-bytelanes_in*8-1 downto 0) then
              o(nbidir+(bytelanes_in mod noutputs)) := '1';
            end if;
          end if;
        end if;
      when "101010" =>
        if dirmode /= 1 then
          vact := '1';
          -- FIXME handle wrong reset vals
          -- Use datareg as counter
          -- Bits 2:0 pos in sequence "00101010"
          -- Bits 3 inv controls value on other outputs than tested
          -- Bits X:4 controls which bit is tested
          if dx(3)='1' then
            op := (others => '0');
          else
            op := (others => '1');
          end if;
          op(to_integer(unsigned(dx(log2(noutputs+nbidir)+3 downto 4)))) := not dx(0) and (dx(1) or dx(2));
          o := op(noutputs+nbidir-1 downto 0);
          dx(log2(noutputs+nbidir)+3 downto 0) :=
            std_logic_vector(unsigned(dx(log2(noutputs+nbidir)+3 downto 0))+1);
          v.datareg := dx xor vrst;
        end if;
      when "100011" =>
        -- Use datareg as LFSR state, drive as output and clock in next state
        if dirmode /= 1 then
          vact := '1';
          v.datareg := nls;
        end if;
      when "001110" =>
        -- Toggle value on all outputs each cycle
        if dirmode /= 1 then
          vact := '1';
          o := r.datareg(o'length-1 downto 2) & r.datareg(2) & r.datareg(2);
          v.datareg(r.datareg'high downto 2) := (others => r.datareg(1));
          v.datareg(0) := '1';
          v.datareg(1) := r.datareg(1) xor r.datareg(0);
        end if;
      when "000111" =>
        -- Toggle output-enable each cycle, toggle all outputs whenever OE changes
        if dirmode /= 1 and nbidir > 0 then
          vact := '1';
          o := r.datareg(o'length-1 downto 2) & r.datareg(2) & r.datareg(2);
          v.datareg(r.datareg'high downto 2) := (others => r.datareg(1));
          voe := r.datareg(0);
          -- 2-bit counter
          v.datareg(0) := not v.datareg(0);
          v.datareg(1) := r.datareg(1) xor r.datareg(0);
        end if;
      when others =>
    end case;
    if rstn='0' or tmode(2 downto 0)="000" then
      v.datareg := vrst;
    end if;
    nr <= v;
    dataout <= o;
    tmodeact <= vact;
    tmodeoe <= voe;
  end process;

  regs: process(clk)
  begin
    if rising_edge(clk) then
      r <= nr;
    end if;
  end process;

  --pragma translate_off
  tg: if false generate
    lfsrtest: process
      variable s: lfsrstate;
      variable stmap: std_logic_vector(255 downto 0);
      variable i,x: integer;
    begin
      print("------ LFSR test ------");
      stmap := (others => '0');
      s := "10000000";
      i := 0;
      loop
        x := to_integer(unsigned(s));
        print("State: " & tost(s));
        if stmap(x)='1' then
          print("Looped after " & tost(i) & " iterations");
          assert i=255 severity failure;
          assert stmap(0)='0' severity failure;
          for q in 1 to 255 loop
            assert stmap(q)='1' severity failure;
          end loop;
          print("------ LFSR test done ------");
          wait;
        end if;
        stmap(x) := '1';
        s := nextlfsr(s);
        i := i+1;
      end loop;
    end process;
  end generate;
  --pragma translate_on

end;

