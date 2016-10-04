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
-- Entity:      comma_detect
-- File:        comma_detect.vhd
-- Author:      Andrea Gianarro - Aeroflex Gaisler AB
-- Description: SGMII' comma detector with bitslip output signal
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_types.all;
use work.config.all;
use work.stdlib.all;
use work.devices.all;
use work.amba.all;
use work.gencomp.all;

entity comma_detect is
  generic (
    bsbreak : integer range 0 to 31  := 0;   -- number of extra deassertion cycles between bitslip assertions in a sequence
    bswait  : integer range 0 to 127 := 7    -- number of cycles to pause recognition after a sequence is issued
    );
  port (
    clk   : in std_logic;
    rstn  : in std_logic;
    indata  : in std_logic_vector(9 downto 0);
    bitslip : out std_logic
  );
end entity;

architecture arch of comma_detect is

  type fsm_state_type is (idle, bitslip1, bitslip2, bitslip3);

  type reg_type is record
    data      : std_logic_vector(19 downto 0);
    state     : fsm_state_type;
    slipcnt   : integer range 0 to 15;
    slipbreak : integer range 0 to 31;
    slipwait  : integer range 0 to 127;
  end record;

  constant RESET_ALL : boolean :=   GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;

  constant RES : reg_type := (
    data      => (others => '0'),
    state     => idle,
    slipcnt   => 0,
    slipbreak => 0,
    slipwait  => 0
  );

  signal r, rin : reg_type;
begin

  comb : process( rstn, r, indata )
    variable v      : reg_type;
    --variable vbitslip   : std_logic_vector(15 downto 0);
  begin
    v := r;

    v.data(19 downto 10)  := r.data(9 downto 0);
    v.data(9 downto 0)    := indata;

    -- -- we match pattern comma+, present in +K.28.x
    -- for i in 19 downto 10 loop
    --  if r.data(i downto i-6) = "0011111" then
    --    vbitslip(9-(i-10)) := '1'; -- unary representation of number of bitslips
    --    exit;
    --  end if;
    -- end loop ;
    -- v.slipcnt := unary_to_slv(vbitslip);


    case r.state is
      when idle =>
        -- we match pattern comma+, present in +K.28.x
        if    r.data(18 downto 12) = "0011111" then
          v.slipcnt := 9;
        elsif r.data(17 downto 11) = "0011111" then
          v.slipcnt := 8;
        elsif r.data(16 downto 10) = "0011111" then
          v.slipcnt := 7;
        elsif r.data(15 downto  9) = "0011111" then
          v.slipcnt := 6;
        elsif r.data(14 downto  8) = "0011111" then
          v.slipcnt := 5;
        elsif r.data(13 downto  7) = "0011111" then
          v.slipcnt := 4;
        elsif r.data(12 downto  6) = "0011111" then
          v.slipcnt := 3;
        elsif r.data(11 downto  5) = "0011111" then
          v.slipcnt := 2;
        elsif r.data(10 downto  4) = "0011111" then
          v.slipcnt := 1;
        else
          v.slipcnt := 0;
        end if;

        if v.slipcnt /= 0 then
          v.state := bitslip1;
        end if;
      when bitslip1 =>
        v.slipcnt := r.slipcnt - 1;
        v.state := bitslip2;
        v.slipbreak := 0;
      when bitslip2 =>
        if r.slipcnt /= 0 then
          if r.slipbreak = bsbreak then
            v.state := bitslip1;
          else
            v.slipbreak := r.slipbreak + 1;
          end if;
        else
          v.slipwait := 0;
          v.state := bitslip3;
        end if;
      when bitslip3 =>
        if r.slipwait = bswait then
          v.state := idle;
          v.data := (others => '0');
        else
          v.slipwait := r.slipwait + 1;
        end if;
      when others =>
    end case ;

    if (not RESET_ALL) and (rstn = '0') then
      v.data  := (others => '0');
      v.state := idle;
    end if;

    rin <= v;

    if r.state = bitslip1 then
      bitslip <= '1';
    else
      bitslip <= '0';
    end if;
  end process ;

  reg : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
      if RESET_ALL and rstn = '0' then
        r <= RES;
      end if;
    end if;
  end process;

end architecture ;
