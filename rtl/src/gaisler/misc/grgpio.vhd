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
-- Entity: 	grgpio
-- File:	grgpio.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Scalable general-purpose I/O port
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.misc.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on

entity grgpio is
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    imask    : integer := 16#0000#;
    nbits    : integer := 16;			-- GPIO bits
    oepol    : integer := 0;                    -- Output enable polarity
    syncrst  : integer := 0;                    -- Only synchronous reset
    bypass   : integer := 16#0000#;
    scantest : integer := 0;
    bpdir    : integer := 16#0000#;
    pirq     : integer := 0;
    irqgen   : integer := 0;
    iflagreg : integer range 0 to 1 := 0;
    bpmode   : integer range 0 to 1 := 0;
    inpen    : integer range 0 to 1 := 0;
    doutresv : integer := 0;
    dirresv  : integer := 0;
    bpresv   : integer := 0;
    inpresv  : integer := 0;
    pulse    : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    gpioi  : in  gpio_in_type;
    gpioo  : out gpio_out_type
  );
end;

architecture rtl of grgpio is

constant REVISION : integer := 3;
constant PIMASK : std_logic_vector(31 downto 0) := '0' & conv_std_logic_vector(imask, 31);

constant BPMASK : std_logic_vector(31 downto 0) := conv_std_logic_vector(bypass, 32);
constant BPDIRM  : std_logic_vector(31 downto 0) := conv_std_logic_vector(bpdir, 32);

constant DOUT_RESVAL : std_logic_vector(31 downto 0) := conv_std_logic_vector(doutresv, 32);
constant DIR_RESVAL : std_logic_vector(31 downto 0) := conv_std_logic_vector(dirresv, 32);
constant BP_RESVAL : std_logic_vector(31 downto 0) := conv_std_logic_vector(bpresv, 32);
constant INPEN_RESVAL : std_logic_vector(31 downto 0) := conv_std_logic_vector(inpresv, 32);

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GPIO, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask),
  2 => (others => '0'));

-- Prevent tools from issuing index errors for unused code
function calc_nirqmux return integer is
begin
  if irqgen = 0 then return 1; end if;
  return irqgen;
end;

constant NIRQMUX : integer := calc_nirqmux;

subtype irqmap_type is std_logic_vector(log2x(NIRQMUX)-1 downto 0);

type irqmap_array_type is array (natural range <>) of irqmap_type;

type registers is record
  din1  	:  std_logic_vector(nbits-1 downto 0);
  din2  	:  std_logic_vector(nbits-1 downto 0);
  dout   	:  std_logic_vector(nbits-1 downto 0);
  imask  	:  std_logic_vector(nbits-1 downto 0);
  level  	:  std_logic_vector(nbits-1 downto 0);
  edge   	:  std_logic_vector(nbits-1 downto 0);
  ilat   	:  std_logic_vector(nbits-1 downto 0);
  dir    	:  std_logic_vector(nbits-1 downto 0);
  bypass        :  std_logic_vector(nbits-1 downto 0);
  irqmap        :  irqmap_array_type(nbits-1 downto 0);
  iflag         :  std_logic_vector(nbits-1 downto 0);
  inpen         :  std_logic_vector(nbits-1 downto 0);
  pulse         :  std_logic_vector(nbits-1 downto 0);
end record;

constant nbitszero : std_logic_vector(nbits-1 downto 0) := (others => '0');
constant irqmapzero : irqmap_array_type(nbits-1 downto 0) := (others => (others => '0'));

constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
constant RES : registers := (
  din1 => nbitszero, din2 => nbitszero,  -- Sync. regs, not reset
  dout => DOUT_RESVAL(nbits-1 downto 0), imask => nbitszero, level => nbitszero, edge => nbitszero,
  ilat => nbitszero, dir => DIR_RESVAL(nbits-1 downto 0), bypass => BP_RESVAL(nbits-1 downto 0), irqmap => irqmapzero,
  iflag => nbitszero, inpen => INPEN_RESVAL(nbits-1 downto 0),
  pulse => nbitszero);


signal r, rin : registers;
signal arst     : std_ulogic;

begin

  arst <= apbi.testrst when (scantest = 1) and (apbi.testen = '1') else rst;
  
  
  comb : process(rst, r, apbi, gpioi)
  variable readdata, tmp2, dout, dir, pval, din : std_logic_vector(31 downto 0);
  variable v : registers;
  variable xirq : std_logic_vector(NAHBIRQ-1 downto 0);
  begin

    din := (others => '0');
    din(nbits-1 downto 0) := gpioi.din(nbits-1 downto 0);
    if inpen /= 0 then
      din(nbits-1 downto 0) := din(nbits-1 downto 0) and r.inpen;
    end if;

    v := r; v.din2 := r.din1; v.din1 := din(nbits-1 downto 0);
    v.ilat := r.din2; dout := (others => '0'); dir := (others => '0');
    dir(nbits-1 downto 0) := r.dir(nbits-1 downto 0);
    if (syncrst = 1) and (rst = '0') then
      dir(nbits-1 downto 0) := DIR_RESVAL(nbits-1 downto 0);
    end if;
    dout(nbits-1 downto 0) := r.dout(nbits-1 downto 0);

-- read registers
    readdata := (others => '0');
    case apbi.paddr(6 downto 2) is
    when "00000" => readdata(nbits-1 downto 0) := r.din2;
    when "00001" | "10101" | "11001" | "11101" =>
      readdata(nbits-1 downto 0) := r.dout;
    when "00010" | "10110" | "11010" | "11110" =>
      readdata(nbits-1 downto 0) := r.dir;
    when "00011" | "10111" | "11011" | "11111"=>
      if (imask /= 0) then
	readdata(nbits-1 downto 0) :=
	  r.imask(nbits-1 downto 0) and PIMASK(nbits-1 downto 0);
      end if;
    when "00100" =>
      if (imask /= 0) then
	readdata(nbits-1 downto 0) :=
	  r.level(nbits-1 downto 0) and PIMASK(nbits-1 downto 0);
      end if;
    when "00101" =>
      if (imask /= 0) then
	readdata(nbits-1 downto 0) :=
	  r.edge(nbits-1 downto 0) and PIMASK(nbits-1 downto 0);
      end if;
    when "00110" =>
      if (bypass /= 0) then
        readdata(nbits-1 downto 0) :=
          r.bypass(nbits-1 downto 0) and BPMASK(nbits-1 downto 0);
      end if;
    when "00111" =>
      readdata(18) := conv_std_logic(pulse /= 0);
      readdata(17) := conv_std_logic(inpen /= 0);
      readdata(16) := conv_std_logic(iflagreg /= 0);
      readdata(12 downto 8) := conv_std_logic_vector(irqgen, 5);
      readdata(4 downto 0) := conv_std_logic_vector(nbits-1, 5);  
    when "10000" =>
      if (iflagreg /= 0) then
        readdata(nbits-1 downto 0) := PIMASK(nbits-1 downto 0);
      end if;
    when "10001" =>
      if (iflagreg) /= 0 then
        readdata(nbits-1 downto 0) := r.iflag and PIMASK(nbits-1 downto 0);
      end if;
    when "10010"  | "10100" | "11000" | "11100" =>
      if (inpen /= 0) then
        readdata(nbits-1 downto 0) := r.inpen;
      end if;
    when "10011" =>
      if (pulse /= 0) then
        readdata(nbits-1 downto 0) := r.pulse;
      end if;
    when others => --when "01000" to "01111" =>
      if (irqgen > 1) then
        for i in 0 to (nbits+3)/4-1 loop
          if i = conv_integer(apbi.paddr(4 downto 2)) then
            for j in 0 to 3 loop
              if (j+i*4) > (nbits-1) then
                exit;
              end if;
              readdata((24+log2x(NIRQMUX)-1-j*8) downto (24-j*8)) := r.irqmap(i*4+j);
            end loop;
          end if;
        end loop;
      end if;
    end case;

-- write registers

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(6 downto 2) is
      when "00000" => null;
      when "00001" => v.dout := apbi.pwdata(nbits-1 downto 0);
      when "00010" => v.dir := apbi.pwdata(nbits-1 downto 0);
      when "00011" =>
        if (imask /= 0) then
	  v.imask := apbi.pwdata(nbits-1 downto 0) and PIMASK(nbits-1 downto 0);
        end if;
      when "00100" =>
        if (imask /= 0) then
	  v.level := apbi.pwdata(nbits-1 downto 0) and PIMASK(nbits-1 downto 0);
        end if;
      when "00101" =>
        if (imask /= 0) then
	  v.edge := apbi.pwdata(nbits-1 downto 0) and PIMASK(nbits-1 downto 0);
        end if;
      when "00110" =>
        if (bypass /= 0) then
	  v.bypass := apbi.pwdata(nbits-1 downto 0) and BPMASK(nbits-1 downto 0);
        end if;
      when "00111" => 
        null;
      when "10000" =>
        null;
      when "10001" =>
        if (iflagreg /= 0) then
          v.iflag := (r.iflag and not apbi.pwdata(nbits-1 downto 0)) and PIMASK(nbits-1 downto 0);
        end if;
      when "10010" =>
        if (inpen /= 0) then
          v.inpen := apbi.pwdata(nbits-1 downto 0);
        end if;
      when "10011" =>
        if (pulse /= 0) then
          v.pulse := apbi.pwdata(nbits-1 downto 0);
        end if;
      when "10100" =>
        if (inpen /= 0) then
          v.inpen := r.inpen or apbi.pwdata(nbits-1 downto 0);
        end if;
      when "10101" => v.dout := r.dout or apbi.pwdata(nbits-1 downto 0);
      when "10110" => v.dir := r.dir or apbi.pwdata(nbits-1 downto 0);
      when "10111" =>
        if (imask /= 0) then
          v.imask := (r.imask or apbi.pwdata(nbits-1 downto 0)) and PIMASK(nbits-1 downto 0);
        end if;
      when "11000" =>
        if (inpen /= 0) then
          v.inpen := r.inpen and apbi.pwdata(nbits-1 downto 0);
        end if;
      when "11001" => v.dout := r.dout and apbi.pwdata(nbits-1 downto 0);
      when "11010" => v.dir := r.dir and apbi.pwdata(nbits-1 downto 0);
      when "11011" =>
        if (imask /= 0) then
          v.imask := (r.imask and apbi.pwdata(nbits-1 downto 0)) and PIMASK(nbits-1 downto 0);
        end if;
      when "11100" =>
        if (inpen /= 0) then
          v.inpen := r.inpen xor apbi.pwdata(nbits-1 downto 0);
        end if;
      when "11101" => v.dout := r.dout xor apbi.pwdata(nbits-1 downto 0);
      when "11110" => v.dir := r.dir xor apbi.pwdata(nbits-1 downto 0);
      when "11111" =>
        if (imask /= 0) then
          v.imask := (r.imask xor apbi.pwdata(nbits-1 downto 0)) and PIMASK(nbits-1 downto 0);
        end if;        
      when others => --when "01000" to "01111" =>
        if (irqgen > 1) then
          for i in 0 to (nbits+3)/4-1 loop
            if i = conv_integer(apbi.paddr(4 downto 2)) then
              for j in 0 to 3 loop
                if (j+i*4) > (nbits-1) then
                  exit;
                end if;
                v.irqmap(i*4+j) := apbi.pwdata((24+log2x(NIRQMUX)-1-j*8) downto (24-j*8));
              end loop;
            end if;
          end loop;
        end if;
      end case;
    end if;

-- interrupt filtering and routing

    xirq := (others => '0'); tmp2 := (others => '0');
    if (imask /= 0) then
      tmp2(nbits-1 downto 0) := r.din2;
      for i in 0 to nbits-1 loop
        if (PIMASK(i) and r.imask(i)) = '1' then
	  if r.edge(i) = '1' then
	    if r.level(i) = '1' then tmp2(i) := r.din2(i) and not r.ilat(i);
            else tmp2(i) := not r.din2(i) and r.ilat(i); end if;
          else tmp2(i) := r.din2(i) xor not r.level(i); end if;
	else
	  tmp2(i) := '0';
        end if;
      end loop;

      for i in 0 to nbits-1 loop
        if irqgen = 0 then
          -- IRQ for line i = i + pirq
          if (i+pirq) > NAHBIRQ-1 then
            exit;
          end if;
          xirq(i+pirq) := tmp2(i);
        else
          -- IRQ for line i determined by irq select register i
          for j in 0 to NIRQMUX-1 loop
            if (j+pirq) > NAHBIRQ-1 then
              exit;
            end if;
            if (irqgen = 1) or (j = conv_integer(r.irqmap(i))) then
              xirq(j+pirq) := xirq(j+pirq) or tmp2(i);
            end if;
          end loop;
        end if;
      end loop;

      if iflagreg /= 0 then
        v.iflag := tmp2(nbits-1 downto 0) and PIMASK(nbits-1 downto 0);
      end if;

    end if;

-- toggle dout based on gpioi.sig_in pulse
    if pulse /= 0 then
      for i in 0 to nbits-1 loop
        if r.pulse(i) = '1' and gpioi.sig_in(i) = '1' then
          v.dout(i) := not r.dout(i);
        end if;
      end loop;
    end if;
    
-- drive filtered inputs on the output record

   pval := (others => '0');
   pval(nbits-1 downto 0) := r.din2;

-- Drive output with gpioi.sig_in for bypassed registers
   if bypass /= 0 then
       for i in 0 to nbits-1 loop
           if r.bypass(i) = '1' then
               dout(i) := gpioi.sig_in(i);
           end if;
       end loop;
   end if;

-- Drive output with gpioi.sig_in for bypassed registers
   if bpdir /= 0 then
     for i in 0 to nbits-1 loop
       if ((BPDIRM(i) = '1') and
           ((gpioi.sig_en(i) = '1' and bpmode = 0) or
            (r.bypass(i) = '1' and bpmode = 1)))  then
         dout(i) := gpioi.sig_in(i);
         if bpmode = 0 then
           dir(i) := '1';
         else
           dir(i) := gpioi.sig_en(i);
         end if;
       end if;
     end loop;
   end if;

-- reset operation

    if (not RESET_ALL) and (rst = '0') then
      v.imask := RES.imask; v.bypass := RES.bypass;
      v.dir := RES.dir; v.dout := RES.dout;
      v.irqmap := RES.irqmap;
      if iflagreg /= 0 then
        v.iflag := RES.iflag;
      end if;
      if inpen /= 0 then
        v.inpen := RES.inpen;
      end if;
      if pulse /= 0 then
        v.pulse := RES.pulse;
      end if;
    end if;

    if irqgen < 2 then v.irqmap := (others => (others => '0')); end if;

    if iflagreg = 0 then v.iflag := (others => '0'); end if;

    if inpen = 0 then v.inpen := (others => '0'); end if;

    if pulse = 0 then v.pulse := (others => '0'); end if;
    
    rin <= v;

    apbo.prdata <= readdata; 	-- drive apb read bus
    apbo.pirq <= xirq;

    if (scantest = 1) and (apbi.testen = '1') then
      dir := (others => apbi.testoen);
      if oepol = 0 then dir := not dir; end if;
    elsif (syncrst = 1 ) and (rst = '0') then
      dir := (others => '0');
    end if;
      
    gpioo.dout <= dout;
    gpioo.oen <= dir;
    if oepol = 0 then gpioo.oen <= not dir; end if;
    gpioo.val <= pval;

-- non filtered input
    gpioo.sig_out <= din;

  end process;

  apbo.pindex <= pindex;
  apbo.pconfig <= pconfig;

-- registers

  regs : process(clk, arst)
  begin
    if rising_edge(clk) then
      r <= rin;
      if RESET_ALL and rst = '0' then
        r <= RES;
        -- Sync. registers din1 and din2 not reset
        r.din1 <= rin.din1;
        r.din2 <= rin.din2;
      end if;
    end if;
    if (syncrst = 0 ) and (arst = '0') then
      r.dir <= DIR_RESVAL(nbits-1 downto 0);
      r.dout <= DOUT_RESVAL(nbits-1 downto 0);
      if bypass /= 0 then
        r.bypass <= BP_RESVAL(nbits-1 downto 0);
      end if;
      if inpen /= 0 then
        r.inpen <= INPEN_RESVAL(nbits-1 downto 0);
      end if;
    end if;
  end process;

-- boot message

-- pragma translate_off
    bootmsg : report_version
    generic map ("grgpio" & tost(pindex) &
	": " &  tost(nbits) & "-bit GPIO Unit rev " & tost(REVISION));
-- pragma translate_on

end;

