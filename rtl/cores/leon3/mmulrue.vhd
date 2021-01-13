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
-- Entity: 	mmulrue
-- File:	mmulrue.vhd
-- Author:	Konrad Eisele, Jiri Gaisler, Gaisler Research
-- Description:	MMU LRU logic
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.mmuconfig.all;
use work.mmuiface.all;

entity mmulrue is
  generic (
    position : integer;
    entries  : integer := 8 );
  port (
    rst    : in std_logic;
    clk    : in std_logic;
    lruei  : in mmulrue_in_type;
    lrueo  : out mmulrue_out_type );
end mmulrue;

architecture rtl of mmulrue is

  constant entries_log : integer := log2(entries);  
  type lru_rtype is record
    pos      : std_logic_vector(entries_log-1 downto 0);
    movetop  : std_logic;
  end record;

  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
  constant ASYNC_RESET : boolean := GRLIB_CONFIG_ARRAY(grlib_async_reset_enable) = 1;

  signal c,r   : lru_rtype;
begin  
  
  p0: process (rst, r, lruei)
    variable v : lru_rtype;
    variable ov : mmulrue_out_type;
  begin
    v := r; ov := mmulrue_out_none;
    -- #init

    if (r.movetop) = '1' then
      if (lruei.fromleft) = '0' then
        v.pos := lruei.left(entries_log-1 downto 0); 
        v.movetop := '0';
      end if;
    elsif (lruei.fromright) = '1' then
      v.pos := lruei.right(entries_log-1 downto 0);
      v.movetop := not lruei.clear;
    end if;

    if (lruei.touch and not lruei.clear) = '1' then  -- touch request
      if (v.pos = lruei.pos(entries_log-1 downto 0)) then     -- check
          v.movetop := '1';
      end if;
    end if;

    if ((not ASYNC_RESET) and (not RESET_ALL) and (rst = '0')) or (lruei.flush = '1') then
      v.pos := conv_std_logic_vector(position, entries_log);
      v.movetop := '0';
    end if;
    
    --# Drive signals
    ov.pos(entries_log-1 downto 0) := r.pos; 
    ov.movetop := r.movetop;
    lrueo <= ov; 
    
    c <= v;
  end process p0;

  syncrregs : if not ASYNC_RESET generate
    p1: process (clk)
    begin
      if rising_edge(clk) then
        r <= c;
        if RESET_ALL and (rst = '0') then
          r.pos <= conv_std_logic_vector(position, entries_log);
          r.movetop <= '0';
        end if;
      end if;
    end process p1;
  end generate;
  asyncrregs : if ASYNC_RESET generate
    p1: process (clk, rst)
    begin
      if rst = '0' then
        r.pos <= conv_std_logic_vector(position, entries_log);
        r.movetop <= '0';
      elsif rising_edge(clk) then
        r <= c;
      end if;
    end process p1;
  end generate;

end rtl;








