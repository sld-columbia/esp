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
-- Entity:      apbctrl
-- File:        apbctrl.vhd
-- Author:      Cobham Gaisler
-- Description: AMBA AHB/APB bridge with plug&play support
------------------------------------------------------------------------------ 

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on

entity apbctrlx is
  generic (
    hindex0     : integer := 0;
    haddr0      : integer := 0;
    hmask0      : integer := 16#fff#;
    hindex1     : integer := 0;
    haddr1      : integer := 0;
    hmask1      : integer := 16#fff#;
    nslaves     : integer range 1 to NAPBSLV := NAPBSLV;
    nports      : integer range 1 to 2 := 2;
    wprot       : integer range 0 to 1 := 0;
    debug       : integer range 0 to 2 := 2;
    icheck      : integer range 0 to 1 := 1;
    enbusmon    : integer range 0 to 1 := 0;
    asserterr   : integer range 0 to 1 := 0;
    assertwarn  : integer range 0 to 1 := 0;
    pslvdisable : integer := 0;
    mcheck      : integer range 0 to 1 := 1;
    ccheck      : integer range 0 to 1 := 1
    );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbi    : in  ahb_slv_in_vector_type(0 to nports-1);
    ahbo    : out ahb_slv_out_vector_type(0 to nports-1);
    apbi    : out apb_slv_in_vector;
    apbo    : in  apb_slv_out_vector;
    wp      : in  std_logic_vector(0 to nports-1) := (others => '0');
    wpv     : in  std_logic_vector(256*nports-1 downto 0) := (others => '0')
  );
end;

architecture rtl of apbctrlx is

type ivector_type is array (natural range <>) of integer range 0 to NAHBMST-1;
type pvector_type is array (natural range <>) of std_logic_vector(0 to NAPBSLV-1);
type pinteger_type is array (natural range <>) of integer range 0 to nslaves-1;
type ahb_config_vector_type is array (natural range <>) of ahb_config_type;


constant apbmax 	: integer := 19;
constant multiport: integer := conv_integer(conv_std_logic(nports>1));
constant VERSION   : amba_version_type := 1;


constant hindex : ivector_type(0 to 1) := (hindex0, hindex1);
constant hconfig : ahb_config_vector_type(0 to 1) := (
  (0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_APBMST, 0, VERSION, 0),
   4 => ahb_membar(haddr0, '0', '0', hmask0),
   others => zero32),
  (0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_APBMST, 0, VERSION, 0),
   4 => ahb_membar(haddr1, '0', '0', hmask1),
   others => zero32));

constant IOAREA : std_logic_vector(11 downto 0) := 
        conv_std_logic_vector(haddr0, 12);
constant IOMSK  : std_logic_vector(11 downto 0) := 
        conv_std_logic_vector(hmask0, 12);

constant IOAREA1 : std_logic_vector(11 downto 0) := 
        conv_std_logic_vector(haddr1, 12);
constant IOMSK1  : std_logic_vector(11 downto 0) := 
        conv_std_logic_vector(hmask1, 12);


type port_reg_type is record
  haddr   : std_logic_vector(apbmax downto 0);   -- address bus
  hwrite  : std_logic;                       -- read/write
  hready  : std_logic;                       -- ready
  penable : std_logic;
  psel    : std_logic;
  prdata  : std_logic_vector(31 downto 0);   -- read data
  pwdata  : std_logic_vector(31 downto 0);   -- write data
  state   : std_logic_vector(1 downto 0);   -- state
  cfgsel  : std_logic;
  hresp   : std_logic_vector(1 downto 0);
  hmaster : std_logic_vector(3 downto 0);
end record;
constant RES_PORT : port_reg_type :=
  (haddr => (others => '0'), hwrite => '0', hready => '1', penable => '0',
   psel => '0', prdata => (others => '0'), pwdata => (others => '0'),
   state => (others => '0'), cfgsel => '0', hresp => (others => '0'),
   hmaster => (others => '0'));
type port_reg_vector is array (natural range <>) of port_reg_type;
type reg_type is record
	p				: port_reg_vector(0 to nports-1);
end record;
constant RES : reg_type := (
	p => (others => RES_PORT));

constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;

signal r, rin : reg_type;
--pragma translate_off
signal lapbi  : apb_slv_in_type;
--pragma translate_on

begin
  comb : process(ahbi, apbo, wp, wpv, r, rst)
  variable v : reg_type;
  variable psel   : pvector_type(0 to nports-1);   
  variable pwdata : std_logic_vector(31 downto 0);
  variable apbaddr : std_logic_vector(31 downto 0);
  variable pirq : std_logic_vector(NAHBIRQ-1 downto 0);
  variable nslave : pinteger_type(0 to nports-1);
  variable bnslave : std_logic_vector(3 downto 0);
  variable vapbi    : apb_slv_in_vector_type(0 to nports-1);

  variable lwprot : std_logic_vector(0 to 1);
  variable lwprotv  : std_logic_vector(15 downto 0);

  begin

    v := r; pirq := (others => '0'); 
		
		for j in 0 to nports-1 loop
			v.p(j).psel := '0'; v.p(j).penable := '0'; psel(j) := (others => '0');
    	
      -- Decode APB slave
      for i in 0 to nslaves-1 loop
    	  if ((apbo(i).pconfig(1)(1 downto 0) = "01") and
    	    ((apbo(i).pconfig(1)(31 downto 20) and apbo(i).pconfig(1)(15 downto 4)) = 
    	    (r.p(j).haddr(19 downto  8) and apbo(i).pconfig(1)(15 downto 4))))
    	  then psel(j)(i) := '1'; end if;
    	end loop;

    	bnslave(0) := psel(j)( 1) or psel(j)( 3) or psel(j)( 5) or psel(j)( 7) or
    	              psel(j)( 9) or psel(j)(11) or psel(j)(13) or psel(j)(15);
    	bnslave(1) := psel(j)( 2) or psel(j)( 3) or psel(j)( 6) or psel(j)( 7) or
    	              psel(j)(10) or psel(j)(11) or psel(j)(14) or psel(j)(15);
    	bnslave(2) := psel(j)( 4) or psel(j)( 5) or psel(j)( 6) or psel(j)( 7) or
    	              psel(j)(12) or psel(j)(13) or psel(j)(14) or psel(j)(15);
    	bnslave(3) := psel(j)( 8) or psel(j) (9) or psel(j)(10) or psel(j)(11) or
    	              psel(j)(12) or psel(j)(13) or psel(j)(14) or psel(j)(15);
    	nslave(j) := conv_integer(bnslave);


      -- write protection
      if wprot = 1 then
        --lwprotv := wpv(15+16*nslave(j)+256*j downto 16*nslave(j)+256*j); 
        --lwprot(j) := lwprotv(conv_integer(r.p(j).hmaster)); 
        lwprot(j) := wpv(16*nslave(j)+256*j+conv_integer(r.p(j).hmaster)); 
      else
        lwprotv := (others => '0');
        lwprot(j) := '0';
        v.p(j).hmaster := (others => '0');
        v.p(j).hresp := HRESP_OKAY;
      end if;

    	-- detect start of cycle
    	if (ahbi(j).hready = '1') then
    	  if ((ahbi(j).htrans = HTRANS_NONSEQ) or (ahbi(j).htrans = HTRANS_SEQ)) and
    	      (ahbi(j).hsel(hindex(j)) = '1')
    	  then
    	    v.p(j).hready := '0'; v.p(j).hwrite := ahbi(j).hwrite; 
    	    v.p(j).haddr(apbmax downto 0) := ahbi(j).haddr(apbmax downto 0); 
    	    v.p(j).state := "01"; v.p(j).psel := not ahbi(j).hwrite;
          if wprot = 1 then
            v.p(j).hmaster := ahbi(j).hmaster;
          end if;
    	  end if;
    	end if;

    	case r.p(j).state is
    	when "00" => -- idle
        v.p(j).hresp := HRESP_OKAY;
    	when "01" =>
        if (multiport = 1) and (
           (j = 1 and (r.p(0).penable = '0' or r.p(1*multiport).hwrite = '0') and (r.p(0).psel and orv(psel(0) and psel(1*multiport))) = '1') or 
           (j = 0 and r.p(1*multiport).penable = '1' and (r.p(1*multiport).psel and not r.p(0).hwrite and orv(psel(0) and psel(1*multiport))) = '1')) then
          v.p(j).psel := '1'; 
        else
    	    if r.p(j).hwrite = '0' then v.p(j).penable := '1'; 
    	    else v.p(j).pwdata := ahbreadword(ahbi(j).hwdata, r.p(j).haddr(4 downto 2)); end if;
    	    v.p(j).psel := '1'; v.p(j).state := "10";
        end if;
        if wprot = 1 and r.p(j).hwrite = '1' and (wp(j*multiport) or lwprot(j*multiport)) = '1' then
          v.p(j).state := "11";
          v.p(j).psel := '0';
          v.p(j).hresp := HRESP_ERROR;
        end if;
      when "11" =>
        if wprot = 1 then
          v.p(j).hready := '1';
          v.p(j).state := "00";
        else
          null;
        end if;
    	when others =>
        if (multiport = 1) and (
           (j = 1 and r.p(1*multiport).penable = '0' and (r.p(0).psel and orv(psel(0) and psel(1*multiport))) = '1') or 
           (j = 0 and r.p(1*multiport).penable = '1' and (r.p(1*multiport).psel and orv(psel(0) and psel(1*multiport))) = '1')) then
          v.p(j).psel := '1';
        else
    	    if r.p(j).penable = '0' then v.p(j).psel := '1'; v.p(j).penable := '1'; end if;
    	    v.p(j).state := "00"; v.p(j).hready := '1';
        end if;
    	end case;

      -- Decode PNP access
    	if (r.p(j).haddr(19 downto  12) = "11111111") then 
    	 v.p(j).cfgsel := '1'; psel(j) := (others => '0'); v.p(j).penable := '0';
    	else v.p(j).cfgsel := '0'; end if;

    	v.p(j).prdata := apbo(nslave(j)).prdata;

    	if r.p(j).cfgsel = '1' then
    	  v.p(j).prdata := apbo(conv_integer(r.p(j).haddr(6 downto 3))).pconfig(conv_integer(r.p(j).haddr(2 downto 2)));
    	  if nslaves <= conv_integer(r.p(j).haddr(6 downto 3)) then
    	    v.p(j).prdata := (others => '0');
    	  end if;
    	end if;
		end loop;

    for i in 0 to nslaves-1 loop pirq := pirq or apbo(i).pirq; end loop;

    -- AHB respons
    for j in 0 to nports-1 loop
      ahbo(j).hready <= r.p(j).hready;
      ahbo(j).hrdata <= ahbdrivedata(r.p(j).prdata);
      ahbo(j).hirq   <= pirq;
      ahbo(j).hresp  <= r.p(j).hresp;
    
      ahbo(j).hindex <= hindex(j);
      ahbo(j).hconfig <= hconfig(j);
      ahbo(j).hsplit <= (others => '0');
    end loop;

    -- Reset
    if (not RESET_ALL) and (rst = '0') then
      for j in 0 to nports-1 loop
        v.p(j).penable  := RES.p(j).penable;
			  v.p(j).hready   := RES.p(j).hready;
        v.p(j).psel     := RES.p(j).psel;
			  v.p(j).state    := RES.p(j).state;
        v.p(j).hwrite   := RES.p(j).hwrite;
        v.p(j).hresp    := RES.p(j).hresp;
-- pragma translate_off
        v.p(j).haddr    := RES.p(j).haddr;
-- pragma translate_on
      end loop;
    end if;

    rin <= v;

    -- drive APB bus
    for j in 0 to NAPBSLV-1 loop
      apbaddr := (others => '0');
      apbi(j).psel <= (others => '0');
      
      if multiport = 0 and j < nslaves then
        apbaddr(apbmax downto 0) := r.p(0).haddr(apbmax downto 0);
        apbi(j).pwdata  <= r.p(0).pwdata;
        apbi(j).pwrite  <= r.p(0).hwrite;
        apbi(j).penable <= r.p(0).penable;
        if r.p(0).psel = '1' then
          apbi(j).psel    <= psel(0);
        end if;
      elsif j < nslaves then
        if (psel(0)(j) and r.p(0).psel and not (r.p(1*multiport).penable and r.p(1*multiport).psel and orv(psel(0) and psel(1*multiport)))) = '1' then
          apbaddr(apbmax downto 0) := r.p(0).haddr(apbmax downto 0);
          apbi(j).pwdata  <= r.p(0).pwdata;
          apbi(j).pwrite  <= r.p(0).hwrite;
          apbi(j).penable <= r.p(0).penable;
          apbi(j).psel(j) <= '1';
        elsif (psel(1*multiport)(j) and r.p(1*multiport).psel) = '1' then
          apbaddr(apbmax downto 0) := r.p(1*multiport).haddr(apbmax downto 0);
          apbi(j).pwdata  <= r.p(1*multiport).pwdata;
          apbi(j).pwrite  <= r.p(1*multiport).hwrite;
          apbi(j).penable <= r.p(1*multiport).penable;
          apbi(j).psel(j) <= '1';
        else
          apbi(j).pwdata  <= r.p(0).pwdata;
          apbi(j).pwrite  <= '0';
          apbi(j).penable <= '0';
        end if;
      else
        apbi(j).pwdata  <= (others => '0');
        apbi(j).pwrite  <= '0';
        apbi(j).penable <= '0';
      end if;

      apbi(j).paddr   <= apbaddr;
      apbi(j).pirq    <= ahbi(0).hirq;
      apbi(j).testen  <= ahbi(0).testen;
      apbi(j).testoen <= ahbi(0).testoen;
      apbi(j).scanen  <= ahbi(0).scanen;
      apbi(j).testrst <= ahbi(0).testrst;
      apbi(j).testin  <= ahbi(0).testin;
    end loop;

--pragma translate_off
    lapbi.paddr   <= apbaddr;
    lapbi.pwdata  <= r.p(0).pwdata;
    lapbi.pwrite  <= r.p(0).hwrite;
    lapbi.penable <= r.p(0).penable;
    lapbi.pirq    <= ahbi(0).hirq;

    for i in 0 to nslaves-1 loop lapbi.psel(i) <= (psel(0)(i) and r.p(0).psel) or (psel(1*multiport)(i) and r.p(1*multiport).psel); end loop;
--pragma translate_on

  end process;

  reg : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
      if RESET_ALL and rst = '0' then
        r <= RES;
      end if;
    end if;
  end process;

-- pragma translate_off

  mon0 : if enbusmon /= 0 generate
    mon :  apbmon 
      generic map(
        asserterr   => asserterr,
        assertwarn  => assertwarn,
        pslvdisable => pslvdisable,
        napb        => nslaves)
      port map(
        rst         => rst,
        clk         => clk,
        apbi        => lapbi,
        apbo        => apbo,
        err         => open);
  end generate;

  diag : process
  type apb_memarea_type is record
     start : std_logic_vector(31 downto 20);
     stop  : std_logic_vector(31 downto 20);
  end record;
  type memmap_type is array (0 to nslaves-1) of apb_memarea_type;
  variable k : integer;
  variable mask : std_logic_vector(11 downto 0);
  variable device : std_logic_vector(11 downto 0);
  variable devicei : integer;
  variable vendor : std_logic_vector( 7 downto 0);
  variable vendori : integer;
  variable iosize : integer;
  variable iounit : string(1 to 5) := "byte ";
  variable memstart : std_logic_vector(11 downto 0) := IOAREA and IOMSK;
  variable memstart1 : std_logic_vector(11 downto 0) := IOAREA1 and IOMSK1;
  variable L1 : line := new string'("");
  variable memmap : memmap_type;
  begin
    wait for 3 ns;
    if debug > 0 then
			if nports = 2 then
      	print("apbctrl: APB Bridge at " & tost(memstart) & "00000 (Port1 at " & tost(memstart1) & "00000) rev 1");
      else
        print("apbctrl: APB Bridge at " & tost(memstart) & "00000 rev 1");
			end if;
    end if;
    for i in 0 to nslaves-1 loop
      vendor := apbo(i).pconfig(0)(31 downto 24); 
      vendori := conv_integer(vendor);
      if vendori /= 0 then
        if debug > 1 then
          device := apbo(i).pconfig(0)(23 downto 12); 
          devicei := conv_integer(device);
          std.textio.write(L1, "apbctrl: slv" & tost(i) & ": " &                
           iptable(vendori).vendordesc  & iptable(vendori).device_table(devicei));
          std.textio.writeline(OUTPUT, L1);
          mask := apbo(i).pconfig(1)(15 downto 4);
          k := 0;
          while (k<15) and (mask(k) = '0') loop k := k+1; end loop;      
          iosize := 256 * 2**k; iounit := "byte ";
          if (iosize > 1023) then iosize := iosize/1024; iounit := "kbyte"; end if;
          print("apbctrl:       I/O ports at " & 
            tost(memstart & (apbo(i).pconfig(1)(31 downto 20) and
                             apbo(i).pconfig(1)(15 downto 4))) &
                "00, size " & tost(iosize) & " " & iounit);
          if mcheck /= 0 then
            memmap(i).start := (apbo(i).pconfig(1)(31 downto 20) and
                                apbo(i).pconfig(1)(15 downto 4));
            memmap(i).stop := memmap(i).start + 2**k;
          end if;
        end if;
        assert (apbo(i).pindex = i) or (icheck = 0)
        report "APB slave index error on slave " & tost(i) &
          ". Detected index value " & tost(apbo(i).pindex) severity failure;
        if mcheck /= 0 then
          for j in 0 to i loop
            if memmap(i).start /= memmap(i).stop then
              assert ((memmap(i).start >= memmap(j).stop) or
                      (memmap(i).stop <= memmap(j).start) or (i = j))
                report "APB slave " & tost(i) & " memory area" &  
                " intersects with APB slave " & tost(j) & " memory area."
                severity failure;
            end if;
          end loop;
        end if;
      else
        for j in 0 to NAPBCFG-1 loop
          assert (apbo(i).pconfig(j) = zx or ccheck = 0)
            report "APB slave " & tost(i) & " appears to be disabled, " &
            "but the config record is not driven to zero"
            severity warning;
        end loop;
      end if;
    end loop;
    if nslaves < NAPBSLV then
      for i in nslaves to NAPBSLV-1 loop
        for j in 0 to NAPBCFG-1 loop
          assert (apbo(i).pconfig(j) = zx or ccheck = 0)
            report "APB slave " & tost(i) & " is outside the range of decoded " &
            "slave indexes but the config record is not driven to zero"
            severity warning;
        end loop;  -- j
      end loop;  -- i
    end if;
    wait;
  end process;
-- pragma translate_on

end;

