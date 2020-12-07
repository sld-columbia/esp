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
-- Entity: 	greth
-- File:	greth.vhd
-- Author:	Marko Isomaki 
-- Description:	Ethernet Media Access Controller with Ethernet Debug
--              Communication Link
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.esp_global.all;
use work.amba.all;
use work.devices.all;
use work.gencomp.all;
use work.net.all;
use work.ethernet_mac.all;
use work.ethcomp.all;

entity greth is
  generic(
    hindex         : integer := 0;
    ehindex        : integer := 1;
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#FFF#;
    pirq           : integer := 0;
    memtech        : integer := 0;
    little_end     : integer range 0 to 1 := 0;
    ifg_gap        : integer := 24; 
    attempt_limit  : integer := 16;
    backoff_limit  : integer := 10;
    slot_time      : integer := 128;
    enable_mdio    : integer range 0 to 1 := 0;
    fifosize       : integer range 4 to 512 := 8;
    nsync          : integer range 1 to 2 := 2;
    edcl           : integer range 0 to 3 := 0;
    edclbufsz      : integer range 1 to 64 := 1;
    macaddrh       : integer := 16#00005E#;
    macaddrl       : integer := 16#000000#;
    ipaddrh        : integer := 16#c0a8#;
    ipaddrl        : integer := 16#0035#;
    phyrstadr      : integer range 0 to 32 := 0;
    vcu118         : integer range 0 to 1  := 0;
    rmii           : integer range 0 to 1  := 0;
    oepol	   : integer range 0 to 1  := 0; 
    scanen	   : integer range 0 to 1  := 0;
    ft             : integer range 0 to 2  := 0;
    edclsepahbg    : integer range 0 to 1  := 0;
    edclft         : integer range 0 to 2  := 0;
    mdint_pol      : integer range 0 to 1  := 0;
    enable_mdint   : integer range 0 to 1  := 0;
    multicast      : integer range 0 to 1  := 0;
    ramdebug       : integer range 0 to 2  := 0;
    mdiohold       : integer := 1;
    maxsize        : integer := 1518;
    gmiimode       : integer range 0 to 1  := 0
    );
  port(
    rst            : in  std_ulogic;
    clk            : in  std_ulogic;
    mdcscaler      : in  integer range 0 to 2047 := 25; 
    ahbmi          : in  ahb_mst_in_type;
    ahbmo          : out ahb_mst_out_type;
    eahbmo         : out ahb_mst_out_type;
    apbi           : in  apb_slv_in_type;
    apbo           : out apb_slv_out_type;
    ethi           : in  eth_in_type;
    etho           : out eth_out_type
  );
end entity;
  
architecture rtl of greth is


  function fix_endian (
    le : std_logic_vector(ARCH_BITS - 1 downto 0))
    return std_logic_vector is
    variable be : std_logic_vector(ARCH_BITS - 1 downto 0);
  begin
    if little_end = 0 then
      be := le;
    else
      for i in 0 to (ARCH_BITS / 8) - 1 loop
        be(8 * (i + 1) - 1 downto 8 * i) := le(ARCH_BITS - 8 * i - 1 downto ARCH_BITS - 8 * (i + 1));
      end loop;  -- i
    end if;
    return be;
  end fix_endian;


  function getfifosize(edcl, fifosize, ebufsize : in integer) return integer is
  begin
    if (edcl /= 0) and (ebufsize > fifosize) then
      return ebufsize;
    else
      return fifosize;
    end if;
  end function;
  
  constant fabits          : integer := log2(fifosize);

  type szvct is array (0 to 6) of integer;
  constant ebuf       : szvct   := (64, 128, 128, 256, 256, 256, 256);
  constant eabits     : integer := log2(edclbufsz) + 8;
  constant bufsize    : std_logic_vector(2 downto 0) :=
                       conv_std_logic_vector(log2(edclbufsz), 3);
  constant ebufsize   : integer := ebuf(log2(edclbufsz));
  constant txfifosize : integer := getfifosize(edcl, fifosize, ebufsize);
  constant txfabits   : integer := log2(txfifosize);
 
  constant REVISION : amba_version_type := 0;

  constant pconfig : apb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_ETHMAC, 0, REVISION, pirq),
    1 => apb_iobar(paddr, pmask),
2 => (others => '0'));

  constant hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_ETHMAC, 0, revision, 0),
    others => zero32);

  constant ehconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_EDCLMST, 0, REVISION, 0),
  others => zero32);

  signal irq          : std_ulogic;
  --rx ahb fifo
  signal rxrenable    : std_ulogic;
  signal rxraddress   : std_logic_vector(10 downto 0);
  signal rxwrite      : std_ulogic;
  signal rxwdata      : std_logic_vector(31 downto 0);
  signal rxwaddress   : std_logic_vector(10 downto 0);
  signal rxrdata      : std_logic_vector(31 downto 0);    
  --tx ahb fifo
  signal txrenable    : std_ulogic;
  signal txraddress   : std_logic_vector(10 downto 0);
  signal txwrite      : std_ulogic;
  signal txwdata      : std_logic_vector(31 downto 0);
  signal txwaddress   : std_logic_vector(10 downto 0);
  signal txrdata      : std_logic_vector(31 downto 0);
  --edcl buf
  signal ehgrant      : std_ulogic;
  signal erenable     : std_ulogic;
  signal eraddress    : std_logic_vector(15 downto 0);
  signal ewritem      : std_ulogic;
  signal ewritel      : std_ulogic;
  signal ewaddressm   : std_logic_vector(15 downto 0);
  signal ewaddressl   : std_logic_vector(15 downto 0);
  signal ewdata       : std_logic_vector(31 downto 0);
  signal erdata       : std_logic_vector(31 downto 0);
  signal lmdio_oe     : std_ulogic;
  -- Fix for wider bus
  signal hwdata       : std_logic_vector(31 downto 0);
  signal ehwdata      : std_logic_vector(31 downto 0);
  signal hrdata       : std_logic_vector(31 downto 0);
  signal ehrdata      : std_logic_vector(31 downto 0);

begin


  ethc0: grethc 
    generic map(
      ifg_gap        => ifg_gap,
      attempt_limit  => attempt_limit,
      backoff_limit  => backoff_limit,
      enable_mdio    => enable_mdio,
      fifosize       => fifosize,
      nsync          => nsync,
      edcl           => edcl,
      edclbufsz      => edclbufsz,
      macaddrh       => macaddrh,
      macaddrl       => macaddrl,
      ipaddrh        => ipaddrh,
      ipaddrl        => ipaddrl,
      phyrstadr      => phyrstadr,
      vcu118         => vcu118,
      rmii           => rmii,
      oepol	     => oepol,
      scanen	     => scanen,
      mdint_pol      => mdint_pol,
      enable_mdint   => enable_mdint,
      multicast      => multicast,
      edclsepahbg    => edclsepahbg,
      ramdebug       => ramdebug,
      mdiohold       => mdiohold, 
      maxsize        => maxsize,
      gmiimode       => gmiimode
      )
    port map(
      rst            => rst,
      clk            => clk,
      mdcscaler      => mdcscaler,
      --ahb mst in
      hgrant         => ahbmi.hgrant(hindex),
      hready         => ahbmi.hready,
      hresp          => ahbmi.hresp,
      hrdata         => hrdata,
      --ahb mst out
      hbusreq        => ahbmo.hbusreq,
      hlock          => ahbmo.hlock,
      htrans         => ahbmo.htrans,
      haddr          => ahbmo.haddr(31 downto 0),
      hwrite         => ahbmo.hwrite,
      hsize          => ahbmo.hsize,
      hburst         => ahbmo.hburst,
      hprot          => ahbmo.hprot,
      hwdata         => hwdata,
      --edcl ahb mst in   
      ehgrant        => ehgrant,
      ehready        => ahbmi.hready,
      ehresp         => ahbmi.hresp,
      ehrdata        => ehrdata,
      --edcl ahb mst out  
      ehbusreq       => eahbmo.hbusreq,
      ehlock         => eahbmo.hlock,
      ehtrans        => eahbmo.htrans,
      ehaddr         => eahbmo.haddr(31 downto 0),
      ehwrite        => eahbmo.hwrite,
      ehsize         => eahbmo.hsize,
      ehburst        => eahbmo.hburst,
      ehprot         => eahbmo.hprot,
      ehwdata        => ehwdata,
      --apb slv in 
      psel	         => apbi.psel(pindex),
      penable	       => apbi.penable,
      paddr	         => apbi.paddr,
      pwrite	       => apbi.pwrite,
      pwdata	       => apbi.pwdata,
      --apb slv out
      prdata	       => apbo.prdata,
      --irq
      irq            => irq,
      --rx ahb fifo
      rxrenable      => rxrenable,
      rxraddress     => rxraddress,
      rxwrite        => rxwrite,
      rxwdata        => rxwdata,
      rxwaddress     => rxwaddress,
      rxrdata        => rxrdata,
      --tx ahb fifo  
      txrenable      => txrenable,
      txraddress     => txraddress,
      txwrite        => txwrite,
      txwdata        => txwdata,
      txwaddress     => txwaddress,
      txrdata        => txrdata,
      --edcl buf     
      erenable       => erenable,
      eraddress      => eraddress,
      ewritem        => ewritem,
      ewritel        => ewritel,
      ewaddressm     => ewaddressm,
      ewaddressl     => ewaddressl,
      ewdata         => ewdata,
      erdata         => erdata,
      --ethernet input signals
      rmii_clk       => ethi.rmii_clk,
      tx_clk         => ethi.tx_clk,
      tx_dv          => ethi.tx_dv,
      rx_clk         => ethi.rx_clk,
      rxd            => ethi.rxd(3 downto 0),   
      rx_dv          => ethi.rx_dv,
      rx_er          => ethi.rx_er,
      rx_col         => ethi.rx_col,
      rx_crs         => ethi.rx_crs,
      rx_en          => ethi.rx_en,
      mdio_i         => ethi.mdio_i,
      phyrstaddr     => ethi.phyrstaddr,
      mdint          => ethi.mdint,
      --ethernet output signals
      reset          => etho.reset,
      txd            => etho.txd(3 downto 0),
      tx_en          => etho.tx_en,
      tx_er          => etho.tx_er,
      mdc            => etho.mdc,
      mdio_o         => etho.mdio_o,
      mdio_oe        => lmdio_oe,
      --scantest     
      testrst        => ahbmi.testrst,
      testen         => ahbmi.testen,
      testoen        => ahbmi.testoen,
      edcladdr       => ethi.edcladdr,
      edclsepahb     => ethi.edclsepahb,
      edcldisable    => ethi.edcldisable,
      speed          => etho.speed);

  etho.txd(7 downto 4) <= "0000";
  etho.mdio_oe <= ahbmi.testoen when (scanen = 1) and (ahbmi.testen = '1')
	else lmdio_oe;
  etho.gbit <= '0';
  etho.tx_clk <= '0';                   -- driven in rgmii component

  irqdrv : process(irq)
  begin
    apbo.pirq       <= (others => '0');
    apbo.pirq(pirq) <= irq;
  end process;

  hrdata <= ahbreadword(fix_endian(ahbmi.hrdata));
  -- hrdata <= ahbreadword(ahbmi.hrdata);
  ehrdata <= ahbreadword(ahbmi.hrdata);

  ahbmo.hwdata <= fix_endian(ahbdrivedata(hwdata));
  -- ahbmo.hwdata <= ahbdrivedata(hwdata);
  ahbmo.hconfig <= hconfig;
  ahbmo.hindex  <= hindex;
  ahbmo.hirq    <= (others => '0');

  eahbmo.hwdata <= ahbdrivedata(ehwdata);
  eahbmo.hconfig <= ehconfig;
  eahbmo.hindex  <= ehindex;
  eahbmo.hirq    <= (others => '0');

  ehgrant <= ahbmi.hgrant(hindex) when edclsepahbg = 0 else ahbmi.hgrant(ehindex);

  apbo.pconfig  <= pconfig;
  apbo.pindex   <= pindex;
-------------------------------------------------------------------------------
-- FIFOS ----------------------------------------------------------------------
-------------------------------------------------------------------------------
  nft : if ft = 0 generate
    tx_fifo0 : syncram_2p generic map(tech => memtech, abits => txfabits,
      dbits => 32, sepclk => 0)
      port map(clk, txrenable, txraddress(txfabits-1 downto 0), txrdata, clk,
      txwrite, txwaddress(txfabits-1 downto 0), txwdata);

    rx_fifo0 : syncram_2p generic map(tech => memtech, abits => fabits,
      dbits => 32, sepclk => 0)
      port map(clk, rxrenable, rxraddress(fabits-1 downto 0), rxrdata, clk,
      rxwrite, rxwaddress(fabits-1 downto 0), rxwdata);
  end generate;
-------------------------------------------------------------------------------
-- EDCL buffer ram ------------------------------------------------------------
-------------------------------------------------------------------------------
  edclramnft : if (edcl /= 0) and (edclft = 0) generate
    r0 : syncram_2p generic map (memtech, eabits, 16) port map(
      clk, erenable, eraddress(eabits-1 downto 0), erdata(31 downto 16), clk,
      ewritem, ewaddressm(eabits-1 downto 0), ewdata(31 downto 16)); 
    r1 : syncram_2p generic map (memtech, eabits, 16) port map(
      clk, erenable, eraddress(eabits-1 downto 0), erdata(15 downto 0), clk,
      ewritel, ewaddressl(eabits-1 downto 0), ewdata(15 downto 0)); 
  end generate;
  
-- pragma translate_off
  bootmsg : report_version 
  generic map (
    "greth" & tost(hindex) & ": 10/100 Mbit Ethernet MAC rev " & tost(REVISION)
    & tost(hindex) & ", EDCL " & tost(edcl) & ", buffer " & 
		tost(edclbufsz) & " kbyte " & tost(txfifosize) & " txfifo," &
    " irq " & tost(pirq)
  );
-- pragma translate_on

end architecture;

