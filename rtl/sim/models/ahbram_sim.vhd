------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2018, Cobham Gaisler
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
-- Entity:  ahbram
-- File:  ahbram.vhd
-- Author:  Jiri Gaisler - Gaisler Research
-- Modified:    Jan Andersson - Aeroflex Gaisler
-- Description: AHB ram. 0-waitstate read, 0/1-waitstate write.
--              Added Sx-Record read function
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use IEEE.Numeric_Std.all;

use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.stdio.all;

use work.gencomp.all;

entity ahbram_sim is
  generic (
    hindex      : integer := 0;
    tech        : integer := DEFMEMTECH;
    kbytes      : integer := 1;
    pipe        : integer := 0;
    maccsz      : integer := AHBDW;
    endianness  : integer := 0; --0 access as BE
                                --1 access as LE
    fname   : string  := "ram.dat"
   );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    haddr   : in  integer := 0;
    hmask   : in  integer := 16#fff#;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type
  );
end;

architecture rtl of ahbram_sim is

constant dw : integer := maccsz;

constant abits : integer := log2ext(kbytes) + 10 - log2(dw/8);

signal hconfig : ahb_config_type;

type reg_type is record
  hwrite : std_ulogic;
  hready : std_ulogic;
  hsel   : std_ulogic;
  addr   : std_logic_vector(abits-1+log2(dw/8) downto 0);
  size   : std_logic_vector(2 downto 0);
  prdata : std_logic_vector((dw-1)*pipe downto 0);
  pwrite : std_ulogic;
  pready : std_ulogic;
end record;

constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
constant RES : reg_type :=
  (hwrite => '0', hready => '1', hsel => '0', addr => (others => '0'),
   size => (others => '0'), prdata => (others => '0'), pwrite => '0',
   pready => '1');


signal r, c     : reg_type;
signal ramsel   : std_logic_vector(dw/8-1 downto 0);
signal write    : std_logic_vector(dw/8-1 downto 0);
signal ramaddr  : std_logic_vector(abits-1 downto 0);
signal ramdata  : std_logic_vector(dw-1 downto 0);
signal hwdata   : std_logic_vector(dw-1 downto 0);

type ram_type is array (0 to (2**ramaddr'length)-1) of std_logic_vector(ramdata'range);
signal ram : ram_type;
signal read_address : std_logic_vector(ramaddr'range);

begin

  hconfig <= (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBRAM, 0, abits+2+maccsz/64, 0),
    4 => ahb_membar(haddr, '1', '1', hmask),
    others => zero32);

  comb : process (ahbsi, r, rst, ramdata)
  variable bs      : std_logic_vector(dw/8-1 downto 0);
  variable v       : reg_type;
  variable haddr   : std_logic_vector(abits-1 downto 0);
  variable hrdata  : std_logic_vector(dw-1 downto 0);
  variable wdata   : std_logic_vector(dw-1 downto 0);
  variable seldata : std_logic_vector(dw-1 downto 0);
  variable raddr   : std_logic_vector(3 downto 2);
  variable adsel   : std_logic;

  function reversedata(data : std_logic_vector; step : integer)
    return std_logic_vector is
    variable rdata: std_logic_vector(data'length-1 downto 0);
  begin
    for i in 0 to (data'length/step-1) loop
      rdata(i*step+step-1 downto i*step) := data(data'length-i*step-1 downto data'length-i*step-step);
    end loop;
    return rdata;
  end function reversedata;

  begin
    v := r; v.hready := '1'; bs := (others => '0');
    v.pready := r.hready;
    if pipe=0 then
      adsel := r.hwrite or not r.hready;
    else
      adsel := r.hwrite or r.pwrite;
      v.hready := r.hready or not r.pwrite;
    end if;
    if adsel = '1' then
      haddr := r.addr(abits-1+log2(dw/8) downto log2(dw/8));
    else
      haddr := ahbsi.haddr(abits-1+log2(dw/8) downto log2(dw/8));
      bs := (others => '0');
    end if;
    raddr := (others => '0');

    v.pwrite := '0';
    if pipe/=0 and (r.hready='1' or r.pwrite='0') then
      v.addr := ahbsi.haddr(abits-1+log2(dw/8) downto 0);
    end if;
    if ahbsi.hready = '1' then
      if pipe=0 then
        v.addr := ahbsi.haddr(abits-1+log2(dw/8) downto 0);
      end if;
      v.hsel := ahbsi.hsel(hindex) and ahbsi.htrans(1);
      v.size := ahbsi.hsize(2 downto 0);
      v.hwrite := ahbsi.hwrite and v.hsel;
      if pipe = 1 and v.hsel = '1' and ahbsi.hwrite = '0' and (r.pready='1' or ahbsi.htrans(0)='0') then
        v.hready := '0';
        v.pwrite := r.hwrite;
      end if;
    end if;

    if r.hwrite = '1' then
      case r.size is
      when HSIZE_BYTE =>
        bs(bs'left-conv_integer(r.addr(log2(dw/16) downto 0))) := '1';
      when HSIZE_HWORD =>
        for i in 0 to dw/16-1 loop
          if i = conv_integer(r.addr(log2(dw/16) downto 1)) then
            bs(bs'left-i*2 downto bs'left-i*2-1) := (others => '1');
          end if;
        end loop;  -- i
      when HSIZE_WORD =>
        if dw = 32 then bs := (others => '1');
        else
          for i in 0 to dw/32-1 loop
            if i = conv_integer(r.addr(log2(dw/8)-1 downto 2)) then
              bs(bs'left-i*4 downto bs'left-i*4-3) := (others => '1');
            end if;
          end loop;  -- i
        end if;
      when HSIZE_DWORD =>
        if dw = 32 then null;
        elsif dw = 64 then bs := (others => '1');
        else
          for i in 0 to dw/64-1 loop
            if i = conv_integer(r.addr(3)) then
              bs(bs'left-i*8 downto bs'left-i*8-7) := (others => '1');
            end if;
          end loop;  -- i
        end if;
      when HSIZE_4WORD =>
        if dw < 128 then null;
        elsif dw = 128 then bs := (others => '1');
        else
          for i in 0 to dw/64-1 loop
            if i = conv_integer(r.addr(3)) then
              bs(bs'left-i*8 downto bs'left-i*8-7) := (others => '1');
            end if;
          end loop;  -- i
        end if;
      when others => --HSIZE_8WORD
        if dw < 256 then null;
        else bs := (others => '1'); end if;
      end case;
      v.hready := not (v.hsel and not ahbsi.hwrite);
      v.hwrite := v.hwrite and v.hready;
    end if;

    -- Duplicate read data on word basis, unless CORE_ACDM is enabled
    if CORE_ACDM = 0 then
      if dw = 32 then
        seldata := ramdata;
      elsif dw = 64 then
        if r.size = HSIZE_DWORD then seldata := ramdata; else
         if r.addr(2) = '0' then
           seldata(dw/2-1 downto 0) := ramdata(dw-1 downto dw/2);
         else
           seldata(dw/2-1 downto 0) := ramdata(dw/2-1 downto 0);
         end if;
         seldata(dw-1 downto dw/2) := seldata(dw/2-1 downto 0);
        end if;
      elsif dw = 128 then
        if r.size = HSIZE_4WORD then
          seldata := ramdata;
        elsif r.size = HSIZE_DWORD then
          if r.addr(3) = '0' then seldata(dw/2-1 downto 0) := ramdata(dw-1 downto dw/2);
          else seldata(dw/2-1 downto 0) := ramdata(dw/2-1 downto 0); end if;
          seldata(dw-1 downto dw/2) := seldata(dw/2-1 downto 0);
        else
          raddr := r.addr(3 downto 2);
          case raddr is
            when "00" => seldata(dw/4-1 downto 0) := ramdata(4*dw/4-1 downto 3*dw/4);
            when "01" => seldata(dw/4-1 downto 0) := ramdata(3*dw/4-1 downto 2*dw/4);
            when "10" => seldata(dw/4-1 downto 0) := ramdata(2*dw/4-1 downto 1*dw/4);
            when others => seldata(dw/4-1 downto 0) := ramdata(dw/4-1 downto 0);
          end case;
          seldata(dw-1 downto dw/4) := seldata(dw/4-1 downto 0) &
                                       seldata(dw/4-1 downto 0) &
                                       seldata(dw/4-1 downto 0);
        end if;
      else
        seldata := ahbselectdata(ramdata, r.addr(4 downto 2), r.size);
      end if;
    else
      seldata := ramdata;
    end if;

    if pipe = 0 then
      v.prdata := (others => '0');
      hrdata := seldata;
    else
      v.prdata := seldata;
      hrdata := r.prdata;
    end if;

    wdata := ahbsi.hwdata;

    -- Revert endianness
    if endianness = 1 then
      hrdata    := reversedata(hrdata, 8);
      wdata     := reversedata(wdata, 8);
    end if;

    if (not RESET_ALL) and (rst = '0') then
      v.hwrite := RES.hwrite; v.hready := RES.hready;
    end if;
    write <= bs; for i in 0 to dw/8-1 loop ramsel(i) <= v.hsel or r.hwrite; end loop;
    ramaddr <= haddr; c <= v;

    ahbso.hrdata <= ahbdrivedata(hrdata);
    ahbso.hready <= r.hready;

    -- Select correct write data
    hwdata <= ahbreaddata(wdata, r.addr(4 downto 2), conv_std_logic_vector(log2(dw/8), 3));

  end process;

  ahbso.hresp   <= "00";
  ahbso.hsplit  <= (others => '0');
  ahbso.hirq    <= (others => '0');
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;

--  aram : syncrambw generic map (tech, abits, dw, scantest) port map (
--  clk, ramaddr, hwdata, ramdata, ramsel, write, ahbsi.testin);
  RamProc: process(clk) is

  variable L1 : line;
  variable FIRST : boolean := true;
  variable SECOND : boolean := false;
  variable ADR : std_logic_vector(19 downto 0);
  variable BUF : std_logic_vector(31 downto 0);
  variable CH : character;
  variable ai : integer := 0;
  variable len : integer := 0;
  variable wrd : integer := 0;
  variable bts_pre : integer := 0;
  variable bts_post : integer := 0;
  file TCF : text open read_mode is fname;
  variable rectype : std_logic_vector(3 downto 0);
  variable recaddr : std_logic_vector(31 downto 0);
  variable reclen  : std_logic_vector(7 downto 0);
  variable recdata : std_logic_vector(0 to 16*8-1);

  begin
    if rising_edge(clk) then
      if conv_integer(write) > 0 then
        for i in 0 to dw/8-1 loop
         if (write(i) = '1') then
           ram(to_integer(unsigned(ramaddr)))(i*8+7 downto i*8) <= hwdata(i*8+7 downto i*8);
         end if;
        end loop;
      end if;
      read_address <= ramaddr;
    end if;

    -- if (rst = '0') and (SECOND = true) then
    --   for i in 0 to (2**ramaddr'length) - 1 loop
    --     report "ram(" & tost(conv_std_logic_vector(i*(dw/8), 32)) & ") = " & tost(ram(i));
    --   end loop;  -- i
    --   SECOND := false;
    -- end if;

    if (rst = '0') and (FIRST = true) then
      ram <= (others => (others => '0'));
      SECOND := true;

      L1:= new string'("");
      while not endfile(TCF) loop
        readline(TCF,L1);
        if (L1'length /= 0) then  --'
          while (not (L1'length=0)) and (L1(L1'left) = ' ') loop
            std.textio.read(L1,CH);
          end loop;

          if L1'length > 0 then --'
            read(L1, ch);
            if (ch = 'S') or (ch = 's') then
              hread(L1, rectype);
              hread(L1, reclen);
              recaddr := (others => '0');
              case rectype is
                when "0001" =>
                  hread(L1, recaddr(15 downto 0));
                  len := conv_integer(reclen)-3;
                when "0010" =>
                  hread(L1, recaddr(23 downto 0));
                  len := conv_integer(reclen)-4;
                when "0011" =>
                  hread(L1, recaddr);
                  len := conv_integer(reclen)-5;
                when others => next;
              end case;
              hread(L1, recdata(0 to len*8-1));

              recaddr(31 downto abits+log2(dw/8)) := (others => '0');
              ai := conv_integer(recaddr)/(dw/8);
              bts_pre := ((dw/8) - (conv_integer(recaddr) mod (dw/8))) mod (dw/8);
              len := len - bts_pre;
              wrd := len / (dw/8);
              bts_post := len mod (dw/8);

              for i in bts_pre - 1 downto 0 loop
                ram(ai)((i + 1) * 8 - 1 downto i * 8) <= recdata((bts_pre - i - 1) * 8 to (bts_pre - i) * 8 - 1);
              end loop;  -- i

              if bts_pre /= 0 then
                ai := ai + 1;
              end if;

              for i in 0 to wrd-1 loop
                ram(ai+i) <= recdata(i*dw + bts_pre * 8 to i*dw+dw-1 + bts_pre * 8);
              end loop;

              for i in 0 to bts_post - 1 loop
                ram(ai + wrd)(dw - i * 8 - 1 downto dw - (i + 1) * 8) <= recdata(wrd * dw + (bts_pre + i) * 8 to wrd * dw + (bts_pre + i + 1) * 8 - 1);
              end loop;  -- i

              if ai = 0 then
                ai := 1;
              end if;
            end if;
          end if;
        end if;
      end loop;

      FIRST := false;

    end if;

  end process RamProc;

  ramdata <= ram(to_integer(unsigned(read_address)));

  reg : process (clk)
  begin
    if rising_edge(clk) then
      r <= c;
      if RESET_ALL and rst = '0' then
        r <= RES;
      end if;
    end if;
  end process;

    bootmsg : report_version
    generic map ("ahbram" & tost(hindex) &
    ": AHB SRAM Module rev 1, " & tost(kbytes) & " kbytes");
end;

-- pragma translate_on
