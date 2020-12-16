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
-- Entity:      gptimer
-- File:        gptimer.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: This unit implemets a set of general-purpose timers with a 
--              common prescaler. Then number of timers and the width of
--              the timers is propgrammable through generics
--
-- Revision 1 of this core merges functionality of the GRTIMET unit:
--
-- This unit also implements the use of an external clock source for the
-- timers.
--
-- This unit also implements a latching register for each timer, latching the
-- timer value on the occurence of an interrupt on the apbi.priq input. The
-- interrupt selection in possible via a mask register. 
--
-- This unit also implements loading of all timers on the event of a selected
-- incoming interrupt.
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gptimer_pkg.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on

entity gptimer is
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    pirq     : integer := 0;
    sepirq   : integer := 0;    -- use separate interrupts for each timer
    sbits    : integer := 16;                   -- scaler bits
    ntimers  : integer range 1 to 7 := 1;       -- number of timers
    nbits    : integer := 32;                   -- timer bits
    wdog     : integer := 0;
    ewdogen  : integer := 0;
    glatch   : integer := 0;
    gextclk  : integer := 0;
    gset     : integer := 0;
    gelatch  : integer range 0 to 2 := 0;
    wdogwin  : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    gpti   : in  gptimer_in_type;
    gpto   : out gptimer_out_type
  );
end; 
 
architecture rtl of gptimer is

constant REVISION : integer := 1;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_GPTIMER, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask),
  2 => (others => '0'));

type timer_reg is record
  enable        :  std_ulogic;  -- enable counter
  load          :  std_ulogic;  -- load counter
  restart       :  std_ulogic;  -- restart counter
  irqpen        :  std_ulogic;  -- interrupt pending
  irqen         :  std_ulogic;  -- interrupt enable
  irq           :  std_ulogic;  -- interrupt pulse
  chain         :  std_ulogic;  -- chain with previous timer
  value         :  std_logic_vector(nbits-1 downto 0);
  reload        :  std_logic_vector(nbits-1 downto 0);
  latch         :  std_logic_vector(glatch*(nbits-1) downto 0);
end record;

type timer_reg_vector is array (Natural range <> ) of timer_reg;

constant TBITS   : integer := log2x(ntimers+1);

type registers is record
  scaler        :  std_logic_vector(sbits-1 downto 0);
  reload        :  std_logic_vector(sbits-1 downto 0);
  tick          :  std_ulogic;
  tsel          :  integer range 0 to ntimers;
  timers        :  timer_reg_vector(1 to ntimers);
  dishlt        :  std_ulogic;
  wdogn         :  std_ulogic;
  wdog          :  std_ulogic;
  wdogdis       :  std_ulogic;
  wdognmi       :  std_ulogic;
  wdogwc        :  std_logic_vector(15 downto 0);
  wdogwcr       :  std_logic_vector(15 downto 0);
end record;

type registers2 is record
  setdis        :  std_ulogic;
  latchdis      :  std_ulogic;
  elatchen      :  std_ulogic;
  latchsel      :  std_logic_vector(NAHBIRQ-1 downto 0);
  latchen       :  std_ulogic;
  latchdel      :  std_ulogic;
  extclken      :  std_ulogic;
  extclk        :  std_logic_vector(2 downto 0);
  seten         :  std_ulogic;
  setdel        :  std_ulogic;
end record;

constant NMI : integer := 15;

constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
function RESVAL_FUNC return registers is
  variable vres : registers;
begin
  vres.scaler := (others => '1');
  vres.reload := (others => '1');
  vres.tick := '0';
  vres.tsel := 0;
  for i in 1 to ntimers loop
    vres.timers(i).enable := '0';
    vres.timers(i).load := '0';
    vres.timers(i).restart := '0';
    vres.timers(i).irqpen := '0';
    vres.timers(i).irqen := '0';
    vres.timers(i).irq := '0';
    vres.timers(i).chain := '0';
    vres.timers(i).value := (others => '0');
    vres.timers(i).reload := (others => '0');
    vres.timers(i).latch := (others => '0');
  end loop;
  if wdog /= 0 then
    vres.timers(ntimers).enable := '1';  -- May be overriden by ewdogen
    vres.timers(ntimers).load := '1';
    vres.timers(ntimers).reload := conv_std_logic_vector(wdog, nbits);
    vres.timers(ntimers).irqen := '1';
  end if;
  vres.dishlt := '0';
  vres.wdogn := '1';
  vres.wdog := '0';
  vres.wdogdis := '0';
  vres.wdognmi := '0';
  vres.wdogwc := (others => '0');
  vres.wdogwcr := (others => '0');
  return vres;
end function RESVAL_FUNC;
constant RESVAL : registers := RESVAL_FUNC;
constant RESVAL2 : registers2 := (
  setdis   => '0',
  latchdis => '0',
  elatchen => '0',
  latchsel => (others => '0'),
  latchen  => '0', 
  latchdel => '0',
  extclken => '0',
  extclk   => (others => '0'),
  seten    => '0',
  setdel   => '0');

signal r, rin : registers;
signal r2, rin2 : registers2;

begin

  comb : process(rst, r, r2, apbi, gpti)
  variable scaler : std_logic_vector(sbits downto 0);
  variable readdata, timer1 : std_logic_vector(31 downto 0);
  variable res, addin : std_logic_vector(nbits-1 downto 0);
  variable v : registers;
  variable z : std_ulogic;
  variable vtimers : timer_reg_vector(0 to ntimers);
  variable xirq : std_logic_vector(NAHBIRQ-1 downto 0);
  variable nirq : std_logic_vector(0 to ntimers-1);
  variable tick : std_logic_vector(1 to 7);
  variable latch : std_ulogic;
  variable latchval : std_logic_vector(NAHBIRQ-1 downto 0);
  variable latchd : std_ulogic;
  variable v2 : registers2;
  variable wdogwc : std_logic_vector(r.wdogwc'left+1 downto 0);
  variable timeren : std_logic;
  begin

    v := r; v2 := r2; v.tick := '0'; tick := (others => '0'); latch := '0';
    latchval := apbi.pirq; latchd := '0';
    vtimers(0) := ('0', '0', '0', '0', '0', '0', '0', 
                   zero32(nbits-1 downto 0), zero32(nbits-1 downto 0),
                   zero32(glatch*(nbits-1) downto 0));
    vtimers(1 to ntimers) := r.timers; xirq := (others => '0');
    for i in 1 to ntimers loop
      v.timers(i).irq := '0'; v.timers(i).load := '0';
      tick(i) := r.timers(i).irq;
    end loop;
    v.wdog := r.timers(ntimers).irqpen and not r.wdogdis;
    v.wdogn := not v.wdog;
    
-- wdog timer window counter
    
    if wdogwin /= 0 and wdog /= 0 then
      wdogwc := ('0' & r.wdogwc) - 1;     -- decrement scaler
      if wdogwc(wdogwc'left) = '0' then
        v.wdogwc := wdogwc(v.wdogwc'range);
      end if;
    else
      wdogwc := (others => '0');
    end if;
-- scaler operation
    
    timeren := '0'; -- set if any of the timers are enabled
    for i in 1 to ntimers loop timeren := timeren or r.timers(i).enable; end loop;

    scaler := ('0' & r.scaler) - 1;     -- decrement scaler

    if gextclk = 1 then -- optional external timer clock
      v2.extclk := r2.extclk(1 downto 0) & gpti.extclk;
    end if;

    if ((gextclk=0) or (gextclk=1 and r2.extclken='0') or
        (gextclk=1 and r2.extclken='1' and r2.extclk(2 downto 1) = "01")) then
      if (not gpti.dhalt or r.dishlt) = '1'   -- halt timers in debug mode. 
         and timeren = '1' then               -- scaler is halted when all timers are disabled
        if (scaler(sbits) = '1') then
          v.scaler := r.reload; v.tick := '1'; -- reload scaler
        else v.scaler := scaler(sbits-1 downto 0); end if;
      end if;
    end if;

-- timer operation

    if (r.tick = '1') or (r.tsel /= 0) then
      if r.tsel = ntimers then v.tsel := 0;
      else v.tsel := r.tsel + 1; end if;
    end if;

    res := vtimers(r.tsel).value - 1;   -- decrement selected timer
    if (res(nbits-1) = '1') and ((vtimers(r.tsel).value(nbits-1) = '0'))
    then z := '1'; else z := '0'; end if; -- undeflow detect

-- update corresponding register and generate irq

    for i in 1 to ntimers-1 loop nirq(i) := r.timers(i).irq; end loop;
    nirq(0) := r.timers(ntimers).irq;

    for i in 1 to ntimers loop

      if i = r.tsel then
        if (r.timers(i).enable = '1') and 
           (((r.timers(i).chain and nirq(i-1)) or not (r.timers(i).chain)) = '1') 
        then
          v.timers(i).irq := z and not r.timers(i).load;
          if (v.timers(i).irq and r.timers(i).irqen) = '1' then 
            v.timers(i).irqpen := '1';
          end if;
          v.timers(i).value := res;
          if (z and not r.timers(i).load) = '1' then 
            v.timers(i).enable := r.timers(i).restart;
            if r.timers(i).restart = '1' then 
              v.timers(i).value := r.timers(i).reload;
            end if;
          end if;
        end if;
      end if;
      if r.timers(i).load = '1' then 
        v.timers(i).value := r.timers(i).reload;
        if (i = ntimers) and wdogwin /= 0 and wdog /= 0 then
          v.wdogwc := r.wdogwcr;
          if wdogwc(wdogwc'left) = '0' then
            v.timers(i).irq := '1';
            v.timers(i).irqpen := '1';
          end if;
        end if;
      end if;
    end loop;

-- timer external set
    if gset = 1 then
      if gelatch /= 0 and r2.elatchen = '1' then
        latchval := gpti.latchv;
      end if;
      if NAHBIRQ <= 32 then
        for i in NAHBIRQ-1 downto 0 loop
          latch := latch or (v2.latchsel(i) and latchval(i));
          if gelatch = 2 then latchd := latchd or (v2.latchsel(i) and gpti.latchd(i)); end if;
        end loop;
      else
        for i in 31 downto 0 loop
          latch := latch or (v2.latchsel(i) and latchval(i));
          if gelatch = 2 then latchd := latchd or (v2.latchsel(i) and gpti.latchd(i)); end if;
        end loop;
      end if;
      if gelatch = 2 and (r2.seten = '1' and r2.elatchen = '1') then
        if latchd = '1' then
          v2.setdis := '1';
        end if;
        if r2.setdis = '1' and r.tsel = 0 then
          v2.setdis := '0'; v2.seten := '0'; v2.setdel := '0';
        end if;
      end if;
      if (latch='1' and r2.seten='1' and r.tsel = 0) or
        (r2.setdel = '1' and r2.seten='1' and r.tsel = 0) then
        for i in 1 to ntimers loop
          v.timers(i).value := r.timers(i).reload;
        end loop;
        v2.setdel := '0';
        if gelatch < 2 or (gelatch = 2 and (r2.elatchen = '0' or v2.setdis = '1')) then
          v2.seten := '0';
          if gelatch = 2 then v2.setdis := '0'; end if;
        end if;
      elsif latch='1' and r2.seten='1' and r.tsel /= 0 then
        v2.setdel := '1';
      end if;
    end if;
    
    if sepirq /= 0 then 
      for i in 1 to ntimers loop 
        xirq(i-1+pirq) := r.timers(i).irq and r.timers(i).irqen;
      end loop;
    else 
      for i in 1 to ntimers loop
        xirq(pirq) := xirq(pirq) or (r.timers(i).irq and r.timers(i).irqen);
      end loop;
    end if;
    if wdog /= 0 then
      if (r.wdognmi and r.timers(ntimers).irq and r.timers(ntimers).irqen) = '1' then
        xirq(NMI) := '1';
      end if;
    end if;

-- read registers

    readdata := (others => '0');
    case apbi.paddr(6 downto 2) is
    when "00000" => readdata(sbits-1 downto 0)  := r.scaler;
    when "00001" => readdata(sbits-1 downto 0)  := r.reload;
    when "00010" => 
        readdata(2 downto 0) := conv_std_logic_vector(ntimers, 3) ;
        readdata(7 downto 3) := conv_std_logic_vector(pirq, 5) ;
        if (sepirq /= 0) then readdata(8) := '1'; end if;
        readdata(9) := r.dishlt;
        if gextclk = 1 then readdata(10) := r2.extclken; end if;
        if glatch = 1 then readdata(11) := r2.latchen; end if;
        if gset = 1 then readdata(12) := r2.seten; end if;
        if gelatch /= 0 then readdata(13) := r2.elatchen; end if;
    when "00011" =>
      if glatch = 1 then
        if NAHBIRQ <= 32 then
          for i in NAHBIRQ-1 downto 0 loop
            readdata(i) := r2.latchsel(i);
          end loop;
        else
          for i in 31 downto 0 loop
            readdata(i) := r2.latchsel(i);
          end loop;
        end if;
      end if;
    when others =>
      for i in 1 to ntimers loop
        if conv_integer(apbi.paddr(6 downto 4)) = i then
          case apbi.paddr(3 downto 2) is
          when "00" => readdata(nbits-1 downto 0) := r.timers(i).value;
          when "01" => readdata(nbits-1 downto 0) := r.timers(i).reload;
          when "10" =>
            if wdog /= 0 and i = ntimers then
              if wdogwin /= 0 then
                readdata(31 downto 16) := r.wdogwcr;
              end if;
              readdata(8 downto 7) := r.wdogdis & r.wdognmi;
            end if;
            readdata(6 downto 0) := 
              gpti.dhalt & r.timers(i).chain &
              r.timers(i).irqpen & r.timers(i).irqen & r.timers(i).load &
              r.timers(i).restart & r.timers(i).enable;
            when "11" =>
            if glatch = 1 then
              readdata(glatch*(nbits-1) downto 0) := r.timers(i).latch;
            end if;
          when others => 
          end case;
        end if;
      end loop;
    end case;

-- write registers

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(6 downto 2) is
      when "00000" => v.scaler := apbi.pwdata(sbits-1 downto 0);
      when "00001" => v.reload := apbi.pwdata(sbits-1 downto 0);
                      v.scaler := apbi.pwdata(sbits-1 downto 0);
      when "00010" => v.dishlt := apbi.pwdata(9);
                      if gextclk = 1 then v2.extclken := apbi.pwdata(10); end if;
                      if glatch = 1 then v2.latchen := apbi.pwdata(11); end if;
                      if gset = 1 then v2.seten := apbi.pwdata(12); end if;
                      if gelatch /= 0 then v2.elatchen := apbi.pwdata(13); end if;
                      for i in 1 to ntimers loop
                        v.timers(i).enable := r.timers(i).enable or apbi.pwdata(15+i);
                      end loop;
      when "00011" =>
        if glatch=1 then
          if NAHBIRQ <= 32 then
            for i in NAHBIRQ-1 downto 0 loop
              v2.latchsel(i) := apbi.pwdata(i);
            end loop;
          else
            for i in 31 downto 0 loop
              v2.latchsel(i) := apbi.pwdata(i);
            end loop;
          end if;
        end if;
      when others => 
        for i in 1 to ntimers loop
          if conv_integer(apbi.paddr(6 downto 4)) = i then
            case apbi.paddr(3 downto 2) is
              when "00" => v.timers(i).value   := apbi.pwdata(nbits-1 downto 0);
              when "01" => v.timers(i).reload  := apbi.pwdata(nbits-1 downto 0);
              when "10" => if wdog /= 0 and i = ntimers then
                             if wdogwin /= 0 then
                               v.wdogwcr := apbi.pwdata(31 downto 16);
                             end if;
                             v.wdogdis := apbi.pwdata(8);
                             v.wdognmi := apbi.pwdata(7);
                           end if;
                           v.timers(i).chain   := apbi.pwdata(5);
                           v.timers(i).irqpen  := v.timers(i).irqpen and not apbi.pwdata(4);
                           v.timers(i).irqen   := apbi.pwdata(3);
                           v.timers(i).load    := apbi.pwdata(2);
                           v.timers(i).restart := apbi.pwdata(1);
                           v.timers(i).enable  := apbi.pwdata(0);
            when others => 
            end case;
          end if;
        end loop;
      end case;
    end if;

-- timer latches
    if glatch=1 then
      latch := '0'; latchd := '0';
      if gelatch /= 0 and r2.elatchen = '1' then
        latchval := gpti.latchv;
      end if;
      if NAHBIRQ <= 32 then
        for i in NAHBIRQ-1 downto 0 loop
          latch := latch or (v2.latchsel(i) and latchval(i));
          if gelatch = 2 then latchd := latchd or (v2.latchsel(i) and gpti.latchd(i)); end if;
        end loop;
      else
        for i in 31 downto 0 loop
          latch := latch or (v2.latchsel(i) and latchval(i));
          if gelatch = 2 then latchd := latchd or (v2.latchsel(i) and gpti.latchd(i)); end if;
        end loop;
      end if;
      if gelatch /= 0 and (r2.latchen = '1' and r2.elatchen = '1') then
        if latchd = '1' then
          v2.latchdis := '1';
        end if;
        if r2.latchdis = '1' and r.tsel = 0 then
          v2.latchdis := '0'; v2.latchen := '0'; v2.latchdel := '0';
        end if;
      end if;
      if ((latch='1' and r2.latchen='1' and r.tsel = 0) or
          (r2.latchdel = '1' and r2.latchen='1' and r.tsel = 0)) then
        for i in 1 to ntimers loop
          v.timers(i).latch := r.timers(i).value(glatch*(nbits-1) downto 0);
        end loop;
        v2.latchdel := '0';
        if gelatch < 2 or (gelatch = 2 and (r2.elatchen = '0' or v2.latchdis = '1')) then
          v2.latchen := '0';
          if gelatch = 2 then v2.latchdis := '0'; end if;
        end if;
      elsif latch='1' and r2.latchen='1' and r.tsel /= 0 then
        v2.latchdel := '1';
      end if;
    end if;

-- reset operation

    if (not RESET_ALL) and (rst = '0') then 
      for i in 1 to ntimers loop
        v.timers(i).enable := RESVAL.timers(i).enable;
        v.timers(i).irqen := RESVAL.timers(i).irqen;
        v.timers(i).irqpen := RESVAL.timers(i).irqpen;
        v.timers(i).irq := RESVAL.timers(i).irq;
      end loop;
      v.scaler := RESVAL.scaler; v.reload := RESVAL.reload;
      v.tsel := RESVAL.tsel; v.dishlt := RESVAL.dishlt;
      v.timers(ntimers).irq := RESVAL.timers(ntimers).irq; 
      if (wdog /= 0) then
        if ewdogen /= 0 then v.timers(ntimers).enable := gpti.wdogen;
        else v.timers(ntimers).enable := RESVAL.timers(ntimers).enable; end if;
        v.timers(ntimers).load := RESVAL.timers(ntimers).load;
        v.timers(ntimers).reload := RESVAL.timers(ntimers).reload;
        v.timers(ntimers).chain := RESVAL.timers(ntimers).chain;
        v.timers(ntimers).irqen := RESVAL.timers(ntimers).irqen;
        v.timers(ntimers).irqpen := RESVAL.timers(ntimers).irqpen;
        v.timers(ntimers).restart := RESVAL.timers(ntimers).restart;
      end if;
      v.wdogdis := RESVAL.wdogdis; v.wdognmi := RESVAL.wdognmi;
      v.wdogwcr := RESVAL.wdogwcr;
      if glatch = 1 then
        for i in 1 to ntimers loop v.timers(i).latch := RESVAL.timers(i).latch; end loop;
        if gelatch /= 0 then v2.elatchen := RESVAL2.elatchen; end if;
        if gelatch = 2 then v2.setdis := '0'; v2.latchdis := '0'; end if;
        v2.latchen := RESVAL2.latchen; v2.latchdel := RESVAL2.latchdel;
        v2.latchsel := RESVAL2.latchsel;
      end if;
      if gextclk = 1 then
        v2.extclken := RESVAL2.extclken;
        v2.extclk := RESVAL2.extclk;
      end if;
      if gset = 1 then v2.seten := RESVAL2.seten; v2.setdel := RESVAL2.setdel; end if;
    end if;
    if wdog = 0 then v.wdogdis := '0'; v.wdognmi := '0'; end if;
    if wdogwin = 0 then v.wdogwc := (others => '0'); v.wdogwcr := (others => '0'); end if;
    if glatch = 0 then
      for i in 1 to ntimers loop v.timers(i).latch := (others => '0'); end loop;
      v2.latchen := '0'; v2.latchdel := '0'; v2.latchsel := (others => '0');
    end if;
    if glatch = 0 or gelatch = 0 then v2.elatchen := '0'; end if;
    if glatch = 0 or gelatch < 2 then v2.latchdis := '0'; v2.setdis := '0'; end if;
    if gextclk = 0 then v2.extclken := '0'; v2.extclk := (others => '0'); end if;
    if gset = 0 then v2.seten := '0'; v2.setdel := '0'; end if;
    
    timer1 := (others => '0'); timer1(nbits-1 downto 0) := r.timers(1).value;

    rin <= v; rin2 <= v2;
    apbo.prdata <= readdata;    -- drive apb read bus
    apbo.pirq <= xirq;
    apbo.pindex <= pindex;
    gpto.tick <= r.tick & tick;
    gpto.timer1 <= timer1;      -- output timer1 value for debugging
    gpto.wdogn <= r.wdogn;
    gpto.wdog  <= r.wdog;

  end process;

  apbo.pconfig <= pconfig;

-- registers

  regs : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin; r2 <= rin2;
      if RESET_ALL and rst = '0' then
        r <= RESVAL; r2 <= RESVAL2;
        if wdog /= 0 and ewdogen /= 0 then
          r.timers(ntimers).enable <= gpti.wdogen;
        end if;
      end if;
    end if;
  end process;

-- boot message

-- pragma translate_off
    bootmsg : report_version 
    generic map ("gptimer" & tost(pindex) & 
        ": Timer Unit rev " & tost(REVISION) & 
        ", " & tost(sbits) & "-bit scaler, " & tost(ntimers) & 
        " " & tost(nbits) & "-bit timers" & ", irq " & tost(pirq));
-- pragma translate_on

end;

