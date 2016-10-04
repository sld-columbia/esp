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
-------------------------------------------------------------------------------
-- Entity:      sim_pll
-- File:        sim_pll.vhd
-- Author:      Magnus Hjorth, Aeroflex Gaisler
-- Description: Generic simulated PLL with input frequency checking
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;

entity sim_pll is
  generic (
    clkmul: integer := 1;
    clkdiv1: integer := 1;
    clkphase1: integer := 0;
    clkdiv2: integer := 1;
    clkphase2: integer := 0;
    clkdiv3: integer := 1;
    clkphase3: integer := 0;
    clkdiv4: integer := 1;
    clkphase4: integer := 0;
    -- Frequency limits in kHz, for checking only
    minfreq: integer := 0;
    maxfreq: integer := 10000000;
    -- Lock tolerance in ps
    locktol: integer := 2
    );
  port (
    i: in std_logic;
    o1: out std_logic;
    o2: out std_logic;
    o3: out std_logic;
    o4: out std_logic;
    lock: out std_logic;
    rst: in std_logic
    );
end;

architecture sim of sim_pll is
  signal clkout1,clkout2,clkout3,clkout4: std_logic;
  signal tp: time := 1 ns;
  signal timeset: boolean := false;
  signal fb: std_ulogic;
  signal comp: time := 0 ns;
  signal llock: std_logic;
begin

  o1 <= transport clkout1 after tp + (tp*clkdiv1*(clkphase1 mod 360)) / (clkmul*360);
  o2 <= transport clkout2 after tp + (tp*clkdiv2*(clkphase2 mod 360)) / (clkmul*360);
  o3 <= transport clkout3 after tp + (tp*clkdiv3*(clkphase3 mod 360)) / (clkmul*360);
  o4 <= transport clkout4 after tp + (tp*clkdiv4*(clkphase4 mod 360)) / (clkmul*360);
  lock <= llock after tp*20;            -- 20 cycle inertia on lock signal
  
  freqmeas: process(i)
    variable ts,te: time;
    variable mf: integer;
    variable warned: boolean := false;
    variable first: boolean := true;
  begin
    if rising_edge(i) and (now /= (0 ps)) then 
      ts := te;
      te := now;
      if first then
        first := false;
      else
        mf := (1 ms) / (te-ts);
        assert (mf >= minfreq and mf <= maxfreq) or warned or rst='0' or llock/='1'
          report "Input frequency out of range, " &
          "measured: " & tost(mf) & ", min:" & tost(minfreq) & ", max:" & tost(maxfreq)
          severity warning;
        if (mf < minfreq or mf > maxfreq) and rst/='0' and llock='1' then warned := true; end if;
        if llock='0' or te-ts-tp > locktol*(1 ps) or te-ts-tp < -locktol*(1 ps) then
          tp <= te-ts;
          timeset <= true;
        end if;
      end if;
    end if;
  end process;
  
  genclk: process
    variable divcount1,divcount2,divcount3,divcount4: integer;
    variable compen: boolean;
    variable t: time;
    variable compps: integer;
    
  begin
    compen := false;
    clkout1 <= '0';
    clkout2 <= '0';
    clkout3 <= '0';
    clkout4 <= '0';
    
    if not timeset or rst='0' then 
      wait until timeset and rst/='0';
    end if;
    divcount1 := 0;
    divcount2 := 0;
    divcount3 := 0;
    divcount4 := 0;
    fb <= '1';
    clkout1 <= '1';
    clkout2 <= '1';
    clkout3 <= '1';
    clkout4 <= '1';
    oloop: loop
      for x in 0 to 2*clkmul-1 loop
        if x=0 then fb <= '1'; end if;
        if x=clkmul then fb <= '0'; end if;
        t := tp/(2*clkmul);
        if compen and comp /= (0 ns) then
          -- Handle compensation below resolution limit (1 ps assumed)
          if comp < 2*clkmul*(1 ps) and comp > -2*clkmul*(1 ps) then
            compps := abs(comp / (1 ps));
            if x > 0 and x <= compps then 
              if comp > 0 ps then
                t := t + 1 ps; 
              else
                t := t - 1 ps; 
              end if;
            end if;
          else
            t:=t+comp/(2*clkmul);
          end if;
        end if;
        if t > (0 ns) then
          wait on rst for t;
        else
          wait for 1 ns;
        end if;
        exit oloop when rst='0';
        divcount1 := divcount1+1;
        if divcount1 >= clkdiv1 then
          clkout1 <= not clkout1;
          divcount1 := 0;          
        end if;        
        divcount2 := divcount2+1;
        if divcount2 >= clkdiv2 then
          clkout2 <= not clkout2;
          divcount2 := 0;          
        end if;        
        divcount3 := divcount3+1;
        if divcount3 >= clkdiv3 then
          clkout3 <= not clkout3;
          divcount3 := 0;          
        end if;        
        divcount4 := divcount4+1;
        if divcount4 >= clkdiv4 then
          clkout4 <= not clkout4;
          divcount4 := 0;          
        end if;        
      end loop;
      compen := true;
    end loop oloop;
  end process;

  fbchk: process(fb,i)
    variable last_i,prev_i: time;
    variable last_fb,prev_fb: time;
    variable vlock: std_logic := '0';
  begin
    if falling_edge(i) then
      prev_i := last_i;
      last_i := now;
    end if;
    if falling_edge(fb) then
      -- Update phase compensation
      if last_i < last_fb+tp/2 then
        comp <= (last_i - last_fb);
      else
        comp <= last_i - now;
      end if;
      prev_fb := last_fb;
      last_fb := now;
    end if;
    if (last_i<=(last_fb+locktol*(1 ps)) and last_i>=(last_fb-locktol*(1 ps)) and
        prev_i<=(prev_fb+locktol*(1 ps)) and prev_i>=(prev_fb-locktol*(1 ps))) then
      vlock := '1';
    end if;
    if prev_fb > last_i+locktol*(1 ps) or prev_i>last_fb+locktol*(1 ps) then
      vlock := '0';
    end if;
    llock <= vlock;

  end process;
  
end;
  

