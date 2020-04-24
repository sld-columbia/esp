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
-- Entity: 	irqmp
-- File:	irqmp.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Multi-processor APB interrupt controller. Implements a
--		two-level interrupt controller for 15 interrupts.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.leon3.all;
use work.coretypes.all;

entity irqmp is
  generic (
    pindex  : integer := 0;
    paddr   : integer := 0;
    pmask   : integer := 16#fff#;
    ncpu    : integer := 1;
    eirq    : integer := 0;
    irqmap  : integer := 0;
    bootreg : integer := 1
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    irqi   : in  irq_out_vector(0 to ncpu-1);
    irqo   : out irq_in_vector(0 to ncpu-1)
  );
end;

architecture rtl of irqmp is

constant REVISION : integer := 4;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_IRQMP, 0, REVISION, 0),
  1 => apb_iobar(paddr, pmask),
  2 => (others => '0'));

function IMAP_HIGH return integer is
begin
  if irqmap = 0 then
    return 0;
  elsif eirq /= 0 or irqmap = 2 then
    return 31;
  end if;
  return 15;
end function IMAP_HIGH;
constant IMAP_LOW : integer := 0; -- allow remap of irq line 0
function IMAP_LEN return integer is
begin
  if irqmap = 0 then
    return 1;
  elsif eirq /= 0 then
    return 5;
  end if;
  return 4;
end function IMAP_LEN;

type mask_type is array (0 to ncpu-1) of std_logic_vector(15 downto 1);
type mask2_type is array (0 to ncpu-1) of std_logic_vector(15 downto 0);
type irl_type is array (0 to ncpu-1) of std_logic_vector(3 downto 0);
type irl2_type is array (0 to ncpu-1) of std_logic_vector(4 downto 0);
type irqmap_type is array (IMAP_LOW to (IMAP_HIGH)) of std_logic_vector(IMAP_LEN-1 downto 0);

type reg_type is record
  imask		: mask_type;
  ilevel	: std_logic_vector(15 downto 1);
  ipend		: std_logic_vector(15 downto 1);
  iforce	: mask_type;
  ibroadcast	: std_logic_vector(15 downto 1);
  irl    	: irl_type;
  cpurst	: std_logic_vector(ncpu-1 downto 0);
  imap          : irqmap_type;
  setaddr       : std_logic_vector(ncpu-1 downto 0);
  newaddr       : std_logic_vector(31 downto 2);
  setaddrboot   : std_ulogic;
  forceerr      : std_logic_vector(ncpu-1 downto 0);
  clkcount      : std_logic_vector(2 downto 0);
end record;

type ereg_type is record
  imask		: mask2_type;
  ipend		: std_logic_vector(15 downto 0);
  irl    	: irl2_type;
end record;

constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
constant RRES : reg_type := (
  imask => (others => (others => '0')), ilevel => (others => '0'),
  ipend => (others => '0'), iforce => (others => (others => '0')),
  ibroadcast => (others => '0'), irl => (others => (others => '0')),
  cpurst => (others => '0'), imap => (others => (others => '0')),
  setaddr => (others => '0'), newaddr => (others => '0'), setaddrboot => '0',
  forceerr => (others => '0'), clkcount => "000");
constant ERES : ereg_type := (
  imask => (others => (others => '0')), ipend => (others => '0'),
  irl => (others => (others => '0')));
  

function prioritize(b : std_logic_vector(15 downto 0)) return std_logic_vector is
variable a : std_logic_vector(15 downto 0);
variable irl : std_logic_vector(3 downto 0);
variable level : integer range 0 to 15;
begin
  irl := "0000"; level := 0; a := b;
  for i in 15 downto 0 loop
    level := i;
    if a(i) = '1' then exit; end if;
  end loop;
  irl := conv_std_logic_vector(level, 4);
  return(irl);
end;

signal r, rin : reg_type;
signal r2, r2in : ereg_type;

begin

  comb : process(rst, r, r2, apbi, irqi)
  variable v      : reg_type;
  variable temp   : mask_type;
  variable prdata : std_logic_vector(31 downto 0);
  variable tmpirq : std_logic_vector(15 downto 0);
  variable tmpvar : std_logic_vector(15 downto 1);
  variable cpurun : std_logic_vector(ncpu-1 downto 0);
  variable v2     : ereg_type;
  variable irl2   : std_logic_vector(3 downto 0);
  variable ipend2 : std_logic_vector(ncpu-1 downto 0);
  variable temp2  : mask2_type;
  variable irq    : std_logic_vector(NAHBIRQ-1 downto 0);
  variable vcpu   : std_logic_vector(3 downto 0);
  variable bootreg_sel : std_ulogic;
  variable paddr  : std_logic_vector(19 downto 2);
  
  begin

    v := r; v.cpurst := (others => '0');
    cpurun := (others => '0'); cpurun(0) := '1';
    tmpvar := (others => '0'); ipend2 := (others => '0');
    v2 := r2;

    paddr := apbi.paddr(19 downto 2);
    paddr(19 downto 8) := paddr(19 downto 8) and not std_logic_vector(to_unsigned(pmask,12));

-- prioritize interrupts

    if eirq /= 0 then
      for i in 0 to ncpu-1 loop
        temp2(i) := r2.ipend and r2.imask(i);
        ipend2(i) := orv(temp2(i));
      end loop;
    end if;

    for i in 0 to ncpu-1 loop
      temp(i) := ((r.iforce(i) or r.ipend) and r.imask(i));
      if eirq /= 0 then temp(i)(eirq) := temp(i)(eirq) or ipend2(i); end if;
      v.irl(i) := prioritize((temp(i) and r.ilevel) & '0');
      if v.irl(i) = "0000" then
        if eirq /= 0 then temp(i)(eirq) := temp(i)(eirq) or ipend2(i); end if;
        v.irl(i) := prioritize((temp(i) and not r.ilevel) & '0');
      end if;
    end loop;

    if bootreg /= 0 then
      if r.clkcount/="000" then
        v.clkcount := std_logic_vector(unsigned(r.clkcount)-1);
      end if;
    end if;

-- register read

    prdata := (others => '0');
    case apbi.paddr(7 downto 6) is
    when "00" =>
      case apbi.paddr(4 downto 2) is
      when "000" => prdata(15 downto 1) := r.ilevel;
      when "001" => 
	prdata(15 downto 1) := r.ipend;
        if eirq /= 0 then prdata(31 downto 16) := r2.ipend; end if;
      when "010" => prdata(15 downto 1) := r.iforce(0);
      when "011" =>
      when "100" | "101" =>
        prdata(31 downto 28) := conv_std_logic_vector(ncpu-1, 4);
        prdata(19 downto 16) := conv_std_logic_vector(eirq, 4);
        for i in 0 to ncpu -1 loop prdata(i) := irqi(i).pwd; end loop;
        if ncpu > 1 then
          prdata(27) := '1';
          case apbi.paddr(4 downto 2) is
            when "101" =>
              prdata := (others => '0');
              prdata(15 downto 1) := r.ibroadcast;
            when others =>  
          end case;
        end if;
        if bootreg /= 0 then
          prdata(26) := '1';
        end if;
      when "110" =>
        for i in 0 to ncpu-1 loop prdata(i):=irqi(i).err; end loop;
      when others =>
      end case;
    when "01" =>
      for i in 0 to ncpu-1 loop
	if i = conv_integer( apbi.paddr(5 downto 2)) then
	  prdata(15 downto 1) := r.imask(i);
          if eirq /= 0 then prdata(31 downto 16) := r2.imask(i); end if;
	end if;
      end loop;
    when "10" =>
      for i in 0 to ncpu-1 loop
	if i = conv_integer( apbi.paddr(5 downto 2)) then
	    prdata(15 downto  1) := r.iforce(i);
	end if;
      end loop;
    when "11" =>
      if eirq /= 0 then
        for i in 0 to ncpu-1 loop
	  if i = conv_integer( apbi.paddr(5 downto 2)) then
	    prdata(4 downto 0) := r2.irl(i);
	  end if;
        end loop;
      end if;
    when others =>
    end case;

-- register write

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' and
      ((irqmap = 0 and bootreg=0) or paddr(9 downto 8) = "00") then
      case apbi.paddr(7 downto 6) is
      when "00" =>
        case apbi.paddr(4 downto 2) is
        when "000" => v.ilevel := apbi.pwdata(15 downto 1);
        when "001" => v.ipend  := apbi.pwdata(15 downto 1);
          if eirq /= 0 then v2.ipend := apbi.pwdata(31 downto 16); end if;
        when "010" => v.iforce(0) := apbi.pwdata(15 downto 1);
        when "011" => v.ipend  := r.ipend and not apbi.pwdata(15 downto 1);
          if eirq /= 0 then v2.ipend := r2.ipend and not apbi.pwdata(31 downto 16); end if;
        when "100" =>
          for i in 0 to ncpu -1 loop v.cpurst(i) := apbi.pwdata(i); end loop;
        when "110" =>
          if bootreg /= 0 then
            v.forceerr := v.forceerr or apbi.pwdata(ncpu-1 downto 0);
            v.clkcount := "111";
          end if;
        when others =>
          if ncpu > 1 then
            case apbi.paddr(4 downto 2) is
              when "101" =>
                v.ibroadcast := apbi.pwdata(15 downto 1);
              when others =>  
            end case;
          end if;
        end case;
      when "01" =>
        for i in 0 to ncpu-1 loop
	  if i = conv_integer( apbi.paddr(5 downto 2)) then
	    v.imask(i) := apbi.pwdata(15 downto 1);
            if eirq /= 0 then v2.imask(i) := apbi.pwdata(31 downto 16); end if;
	  end if;
        end loop;
      when "10" =>
        for i in 0 to ncpu-1 loop
	  if i = conv_integer( apbi.paddr(5 downto 2)) then
	    v.iforce(i) := (r.iforce(i) or apbi.pwdata(15 downto 1)) and
			not apbi.pwdata(31 downto 17);
	  end if;
        end loop;
      when others =>
      end case;
    end if;

-- implement processor reboot / monitor regs
    vcpu := apbi.paddr(5 downto 2);
    bootreg_sel := '0';

    if bootreg /= 0 then
      if r.clkcount="000" then
        if orv(r.setaddr)='1' then
          if r.newaddr(2)='0' then
            v.newaddr(2):='1';
          else
            if r.setaddrboot='1' then
              v.cpurst := v.cpurst or r.setaddr;
            end if;
            v.setaddr := (others => '0');
          end if;
        end if;
        for i in 0 to ncpu-1 loop
          v.forceerr(i) := v.forceerr(i) and not irqi(i).err;
        end loop;
      end if;
      -- Alias bootregs into 256B space if ncpu <= 8
      if paddr(9 downto 6)="1000" then bootreg_sel:='1'; end if;
      if ncpu <= 8 and paddr(9 downto 6)="0001" and apbi.paddr(5)='1' then
        bootreg_sel := '1';
      end if;
      if ncpu <= 8 then vcpu(3):='0'; end if;
      if (apbi.psel(pindex) and apbi.penable)='1' and bootreg_sel='1' then
        -- Reg read
        prdata := (others => '0');
        -- Reg write
        if apbi.pwrite='1' then
          for i in 0 to ncpu-1 loop
            if i = conv_integer( vcpu) then
              v.setaddr(i) := '1';
              v.setaddrboot := apbi.pwdata(0);
            end if;
          end loop;
          v.newaddr := apbi.pwdata(31 downto 3) & "0";
          v.clkcount := "111";
        end if;                         -- pwrite
      end if;                           -- psel/paddr
    end if;                             -- bootreg/=0

-- optionally remap interrupts

    irq := (others => '0');
    if irqmap /= 0 then
      if (apbi.psel(pindex) and apbi.penable)='1' and apbi.paddr(9 downto 8) = "11" then
        prdata := (others => '0');
        for i in r.imap'range loop
          if i/4 = conv_integer(apbi.paddr(4 downto 2)) then
            prdata(IMAP_LEN-1+(24-(i mod 4)*8) downto (24-(i mod 4)*8)) := r.imap(i);
            if apbi.pwrite = '1' then
              v.imap(i) := apbi.pwdata(IMAP_LEN-1+(24-(i mod 4)*8) downto (24-(i mod 4)*8));
            end if;
          end if;
        end loop;
      end if;

      for i in 0 to IMAP_HIGH loop
        if i > NAHBIRQ-1 then
          exit;
        end if;
        if apbi.pirq(i) = '1' then
          irq(conv_integer(r.imap(i))) := '1';
        end if;
      end loop;
    else
      irq := apbi.pirq;
      v.imap := RRES.IMAP;
    end if;

-- register new interrupts

    for i in 1 to 15 loop
      if i > NAHBIRQ-1 then
         exit;
      end if;
      if ncpu = 1 then
        v.ipend(i) := v.ipend(i) or irq(i);
      else  
        v.ipend(i) := v.ipend(i) or (irq(i) and not r.ibroadcast(i));
        for j in 0 to ncpu-1 loop
          tmpvar := v.iforce(j);
          tmpvar(i) := tmpvar(i) or (irq(i) and r.ibroadcast(i));
          v.iforce(j) := tmpvar;
        end loop;
      end if;
    end loop;

    if eirq /= 0 then
      for i in 16 to 31 loop
        if i > NAHBIRQ-1 then exit; end if;
        v2.ipend(i-16) := v2.ipend(i-16) or irq(i);
      end loop;
    end if;

-- interrupt acknowledge

    for i in 0 to ncpu-1 loop
      if irqi(i).intack = '1' then
        tmpirq := decode(irqi(i).irl);
        temp(i) := tmpirq(15 downto 1);
        v.iforce(i) := v.iforce(i) and not temp(i);
        v.ipend  := v.ipend and not ((not r.iforce(i)) and temp(i));
        if eirq /= 0 then
          if eirq = conv_integer(irqi(i).irl) then
            v2.irl(i) := orv(temp2(i)) & prioritize(temp2(i));
            if v2.irl(i)(4) = '1' then
                v2.ipend(conv_integer(v2.irl(i)(3 downto 0))) := '0';
            end if;
 	  end if;
	end if;
      end if;
    end loop;

-- reset

    if (not RESET_ALL) and (rst = '0') then
      v.imask := RRES.imask; v.iforce := RRES.iforce; v.ipend := RRES.ipend;
      if ncpu > 1 then
        v.ibroadcast := RRES.ibroadcast;
      end if;
      if irqmap /= 0 then
        for i in r.imap'range loop
          v.imap(i) := conv_std_logic_vector(i, IMAP_LEN);
        end loop;
      end if;
      v.forceerr := RRES.forceerr;
      v.setaddr := RRES.setaddr;
      v2.ipend := ERES.ipend; v2.imask := ERES.imask; v2.irl := ERES.irl;
    end if;
    if bootreg=0 then
      v.forceerr := RRES.forceerr;
      v.setaddr := RRES.setaddr;
      v.newaddr := RRES.newaddr;
    end if;

    apbo.prdata <= prdata;
    for i in 0 to ncpu-1 loop
      irqo(i).irl <= r.irl(i); irqo(i).resume <= r.cpurst(i);
      irqo(i).forceerr <= r.forceerr(i);
      irqo(i).pwdsetaddr <= r.setaddr(i);
      irqo(i).pwdnewaddr <= r.newaddr;
      irqo(i).rstrun <= cpurun(i);
      irqo(i).rstvec <= (others => '0');  -- Alternate reset vector
      irqo(i).index <= conv_std_logic_vector(i, 4);
    end loop;

    rin <= v; r2in <= v2;
    
  end process;

  apbo.pirq <= (others => '0');
  apbo.pconfig <= pconfig;
  apbo.pindex <= pindex;

  regs : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
      if RESET_ALL and (rst = '0') then r <= RRES; end if;
    end if;
  end process;
  
  dor2regs : if eirq /= 0 generate
    regs : process(clk)
    begin
      if rising_edge(clk) then
        r2 <= r2in;
        if RESET_ALL and (rst = '0') then r2 <= ERES; end if;
      end if;
    end process;
  end generate;
  nor2regs : if eirq = 0 generate
--    r2 <= ((others => "0000000000000000"), "0000000000000000", (others => "00000"));
    r2.ipend <= (others => '0');
    driveregs: for i in 0 to (ncpu-1) generate
      r2.imask(i) <= (others => '0');
      r2.irl(i) <= (others => '0');
    end generate driveregs;  
  end generate;

-- pragma translate_off
    bootmsg : report_version
    generic map ("irqmp" &
	": Multi-processor Interrupt Controller rev " & tost(REVISION) &
	", #cpu " & tost(NCPU) & ", eirq " & tost(eirq));
-- pragma translate_on

-- pragma translate_off
  cproc : process
  begin
    assert (irqmap = 0) or (apb_membar_size(pmask) >= 1024)
      report "IRQMP: irqmap /= 0 requires pmask to give memory area >= 1024 bytes"
      severity failure;
    wait;
  end process;
-- pragma translate_on

end;

