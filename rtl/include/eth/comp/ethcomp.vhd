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
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package ethcomp is
  component grethc is
    generic(
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
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
      oepol	     : integer range 0 to 1  := 0; 
      scanen	     : integer range 0 to 1  := 0;
      mdint_pol      : integer range 0 to 1  := 0;
      enable_mdint   : integer range 0 to 1  := 0;
      multicast      : integer range 0 to 1  := 0;
      edclsepahbg    : integer range 0 to 1  := 0;
      ramdebug       : integer range 0 to 2  := 0;
      mdiohold       : integer := 1;
      maxsize        : integer;
      gmiimode       : integer range 0 to 1  := 0
      );
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      mdcscaler      : in  integer range 0 to 2047 := 25; 
      --ahb mst in
      hgrant         : in  std_ulogic;
      hready         : in  std_ulogic;   
      hresp          : in  std_logic_vector(1 downto 0);
      hrdata         : in  std_logic_vector(31 downto 0); 
      --ahb mst out
      hbusreq        : out  std_ulogic;        
      hlock          : out  std_ulogic;
      htrans         : out  std_logic_vector(1 downto 0);
      haddr          : out  std_logic_vector(31 downto 0);
      hwrite         : out  std_ulogic;
      hsize          : out  std_logic_vector(2 downto 0);
      hburst         : out  std_logic_vector(2 downto 0);
      hprot          : out  std_logic_vector(3 downto 0);
      hwdata         : out  std_logic_vector(31 downto 0);
      --edcl ahb mst in
      ehgrant        : in  std_ulogic;
      ehready        : in  std_ulogic;   
      ehresp         : in  std_logic_vector(1 downto 0);
      ehrdata        : in  std_logic_vector(31 downto 0); 
      --edcl ahb mst out
      ehbusreq       : out  std_ulogic;        
      ehlock         : out  std_ulogic;
      ehtrans        : out  std_logic_vector(1 downto 0);
      ehaddr         : out  std_logic_vector(31 downto 0);
      ehwrite        : out  std_ulogic;
      ehsize         : out  std_logic_vector(2 downto 0);
      ehburst        : out  std_logic_vector(2 downto 0);
      ehprot         : out  std_logic_vector(3 downto 0);
      ehwdata        : out  std_logic_vector(31 downto 0);
      --apb slv in 
      psel	     : in   std_ulogic;
      penable	     : in   std_ulogic;
      paddr	     : in   std_logic_vector(31 downto 0);
      pwrite	     : in   std_ulogic;
      pwdata	     : in   std_logic_vector(31 downto 0);
      --apb slv out
      prdata	     : out  std_logic_vector(31 downto 0);
      --irq
      irq            : out  std_logic;
      --rx ahb fifo
      rxrenable      : out  std_ulogic;
      rxraddress     : out  std_logic_vector(10 downto 0);
      rxwrite        : out  std_ulogic;
      rxwdata        : out  std_logic_vector(31 downto 0);
      rxwaddress     : out  std_logic_vector(10 downto 0);
      rxrdata        : in   std_logic_vector(31 downto 0);    
      --tx ahb fifo  
      txrenable      : out  std_ulogic;
      txraddress     : out  std_logic_vector(10 downto 0);
      txwrite        : out  std_ulogic;
      txwdata        : out  std_logic_vector(31 downto 0);
      txwaddress     : out  std_logic_vector(10 downto 0);
      txrdata        : in   std_logic_vector(31 downto 0);    
      --edcl buf     
      erenable       : out  std_ulogic;
      eraddress      : out  std_logic_vector(15 downto 0);
      ewritem        : out  std_ulogic;
      ewritel        : out  std_ulogic;
      ewaddressm     : out  std_logic_vector(15 downto 0);
      ewaddressl     : out  std_logic_vector(15 downto 0);
      ewdata         : out  std_logic_vector(31 downto 0);
      erdata         : in   std_logic_vector(31 downto 0);
      --ethernet input signals
      rmii_clk       : in   std_ulogic;
      tx_clk         : in   std_ulogic;
      rx_clk         : in   std_ulogic;
      tx_dv          : in   std_ulogic;
      rxd            : in   std_logic_vector(3 downto 0);   
      rx_dv          : in   std_ulogic; 
      rx_er          : in   std_ulogic; 
      rx_col         : in   std_ulogic;
      rx_en          : in   std_ulogic;
      rx_crs         : in   std_ulogic;
      mdio_i         : in   std_ulogic;
      phyrstaddr     : in   std_logic_vector(4 downto 0);
      mdint          : in   std_ulogic;
      --ethernet output signals
      reset          : out  std_ulogic;
      txd            : out  std_logic_vector(3 downto 0);   
      tx_en          : out  std_ulogic; 
      tx_er          : out  std_ulogic; 
      mdc            : out  std_ulogic;    
      mdio_o         : out  std_ulogic; 
      mdio_oe        : out  std_ulogic;
      --scantest
      testrst        : in   std_ulogic;
      testen         : in   std_ulogic;
      testoen        : in   std_ulogic;
      edcladdr       : in   std_logic_vector(3 downto 0) := "0000";
      edclsepahb     : in   std_ulogic;
      edcldisable    : in   std_ulogic;
      speed          : out  std_ulogic
      );
  end component;
  
  component greth_gbitc is
    generic(
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      burstlength    : integer range 4 to 128 := 32;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      sim            : integer range 0 to 1 := 0;
      oepol          : integer range 0 to 1 := 0;
      scanen         : integer range 0 to 1 := 0;
      mdint_pol      : integer range 0 to 1 := 0;
      enable_mdint   : integer range 0 to 1 := 0;
      multicast      : integer range 0 to 1 := 0;
      edclsepahbg    : integer range 0 to 1 := 0;
      ramdebug       : integer range 0 to 2 := 0;
      mdiohold       : integer := 1;
      gmiimode       : integer range 0 to 1 := 0;
      mdiochain      : integer range 0 to 1 := 0;
      iotest         : integer range 0 to 1 := 0
    );
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      mdcscaler      : in  integer range 0 to 2047 := 25; 
      --ahb mst in
      hgrant         : in  std_ulogic;
      hready         : in  std_ulogic;   
      hresp          : in  std_logic_vector(1 downto 0);
      hrdata         : in  std_logic_vector(31 downto 0); 
      --ahb mst out
      hbusreq        : out  std_ulogic;        
      hlock          : out  std_ulogic;
      htrans         : out  std_logic_vector(1 downto 0);
      haddr          : out  std_logic_vector(31 downto 0);
      hwrite         : out  std_ulogic;
      hsize          : out  std_logic_vector(2 downto 0);
      hburst         : out  std_logic_vector(2 downto 0);
      hprot          : out  std_logic_vector(3 downto 0);
      hwdata         : out  std_logic_vector(31 downto 0);
      --edcl ahb mst in
      ehgrant        : in  std_ulogic;
      ehready        : in  std_ulogic;   
      ehresp         : in  std_logic_vector(1 downto 0);
      ehrdata        : in  std_logic_vector(31 downto 0); 
      --edcl ahb mst out
      ehbusreq       : out  std_ulogic;        
      ehlock         : out  std_ulogic;
      ehtrans        : out  std_logic_vector(1 downto 0);
      ehaddr         : out  std_logic_vector(31 downto 0);
      ehwrite        : out  std_ulogic;
      ehsize         : out  std_logic_vector(2 downto 0);
      ehburst        : out  std_logic_vector(2 downto 0);
      ehprot         : out  std_logic_vector(3 downto 0);
      ehwdata        : out  std_logic_vector(31 downto 0);
      --apb slv in 
      psel	     : in   std_ulogic;
      penable	     : in   std_ulogic;
      paddr	     : in   std_logic_vector(31 downto 0);
      pwrite	     : in   std_ulogic;
      pwdata	     : in   std_logic_vector(31 downto 0);
      --apb slv out
      prdata	     : out  std_logic_vector(31 downto 0);
      --irq
      irq            : out  std_logic;
      --rx ahb fifo
      rxrenable      : out  std_ulogic;
      rxraddress     : out  std_logic_vector(8 downto 0);
      rxwrite        : out  std_ulogic;
      rxwdata        : out  std_logic_vector(31 downto 0);
      rxwaddress     : out  std_logic_vector(8 downto 0);
      rxrdata        : in   std_logic_vector(31 downto 0);    
      --tx ahb fifo  
      txrenable      : out  std_ulogic;
      txraddress     : out  std_logic_vector(8 downto 0);
      txwrite        : out  std_ulogic;
      txwdata        : out  std_logic_vector(31 downto 0);
      txwaddress     : out  std_logic_vector(8 downto 0);
      txrdata        : in   std_logic_vector(31 downto 0);    
      --edcl buf     
      erenable       : out  std_ulogic;
      eraddress      : out  std_logic_vector(15 downto 0);
      ewritem        : out  std_ulogic;
      ewritel        : out  std_ulogic;
      ewaddressm     : out  std_logic_vector(15 downto 0);
      ewaddressl     : out  std_logic_vector(15 downto 0);
      ewdata         : out  std_logic_vector(31 downto 0);
      erdata         : in   std_logic_vector(31 downto 0);
      --ethernet input signals
      gtx_clk        : in   std_ulogic;                     
      tx_clk         : in   std_ulogic;
      tx_dv          : in   std_ulogic;
      rx_clk         : in   std_ulogic;
      rxd            : in   std_logic_vector(7 downto 0);   
      rx_dv          : in   std_ulogic; 
      rx_er          : in   std_ulogic; 
      rx_col         : in   std_ulogic;
      rx_crs         : in   std_ulogic;
      rx_en          : in   std_ulogic;
      mdio_i         : in   std_ulogic;
      phyrstaddr     : in   std_logic_vector(4 downto 0);
      mdint          : in   std_ulogic;
      --ethernet output signals
      reset          : out  std_ulogic;
      txd            : out  std_logic_vector(7 downto 0);   
      tx_en          : out  std_ulogic; 
      tx_er          : out  std_ulogic; 
      mdc            : out  std_ulogic;    
      mdio_o         : out  std_ulogic; 
      mdio_oe        : out  std_ulogic;
      --scantest
      testrst        : in   std_ulogic;
      testen         : in   std_ulogic;
      testoen        : in   std_ulogic;
      edcladdr       : in   std_logic_vector(3 downto 0) := "0000";
      edclsepahb     : in   std_ulogic;
      edcldisable    : in   std_ulogic;
      gbit           : out  std_ulogic;
      speed          : out  std_ulogic;
      -- mdio sharing
      mdiochain_first : in  std_ulogic := '0';   -- First in chain (ignore ticki/sampi)
      mdiochain_ticki : in  std_ulogic := '0';   -- From above in chain
      mdiochain_datai : in  std_ulogic := '0';
      mdiochain_locko : out std_ulogic;   -- To above in chain
      mdiochain_ticko : out std_ulogic;   -- To below in chain
      mdiochain_i     : out std_ulogic;   -- To below in chain
      mdiochain_locki : in  std_ulogic := '0';   -- From below in chain
      mdiochain_o     : in  std_ulogic := '0';
      mdiochain_oe    : in  std_ulogic := '0'
      );
  end component;

  component greth_gen is
    generic(
      memtech        : integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      mdcscaler      : integer range 0 to 2047 := 25; 
      enable_mdio    : integer range 0 to 1 := 0;
      fifosize       : integer range 4 to 64 := 8;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 31 := 0;
      rmii           : integer range 0 to 1  := 0;
      oepol	         : integer range 0 to 1  := 0; 
      scanen	       : integer range 0 to 1  := 0;
      mdint_pol      : integer range 0 to 1  := 0;
      enable_mdint   : integer range 0 to 1  := 0;
      multicast      : integer range 0 to 1  := 0;
      gmiimode       : integer range 0 to 1  := 0
      ); 
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      --ahb mst in
      hgrant         : in  std_ulogic;
      hready         : in  std_ulogic;   
      hresp          : in  std_logic_vector(1 downto 0);
      hrdata         : in  std_logic_vector(31 downto 0); 
      --ahb mst out
      hbusreq        : out  std_ulogic;        
      hlock          : out  std_ulogic;
      htrans         : out  std_logic_vector(1 downto 0);
      haddr          : out  std_logic_vector(31 downto 0);
      hwrite         : out  std_ulogic;
      hsize          : out  std_logic_vector(2 downto 0);
      hburst         : out  std_logic_vector(2 downto 0);
      hprot          : out  std_logic_vector(3 downto 0);
      hwdata         : out  std_logic_vector(31 downto 0);
      --apb slv in 
      psel	         : in   std_ulogic;
      penable	       : in   std_ulogic;
      paddr	         : in   std_logic_vector(31 downto 0);
      pwrite	       : in   std_ulogic;
      pwdata	       : in   std_logic_vector(31 downto 0);
      --apb slv out
      prdata	       : out  std_logic_vector(31 downto 0);
      --irq
      irq            : out  std_logic;
      --ethernet input signals
      rmii_clk       : in   std_ulogic;
      tx_clk         : in   std_ulogic;
      tx_dv          : in   std_ulogic;
      rx_clk         : in   std_ulogic;
      rxd            : in   std_logic_vector(3 downto 0);   
      rx_dv          : in   std_ulogic; 
      rx_er          : in   std_ulogic; 
      rx_col         : in   std_ulogic;
      rx_crs         : in   std_ulogic;
      rx_en          : in   std_ulogic;
      mdio_i         : in   std_ulogic;
      phyrstaddr     : in   std_logic_vector(4 downto 0);
      mdint          : in   std_ulogic;
      --ethernet output signals
      reset          : out  std_ulogic;
      txd            : out  std_logic_vector(3 downto 0);   
      tx_en          : out  std_ulogic; 
      tx_er          : out  std_ulogic; 
      mdc            : out  std_ulogic;    
      mdio_o         : out  std_ulogic; 
      mdio_oe        : out  std_ulogic;
      --scantest
      testrst        : in   std_ulogic;
      testen         : in   std_ulogic;
      testoen        : in   std_ulogic;
      edcladdr       : in   std_logic_vector(3 downto 0);
      edclsepahb     : in   std_ulogic;
      edcldisable    : in   std_ulogic;
      speed          : out  std_ulogic
    );
  end component;

  component greth_gbit_gen is
    generic(
      memtech        : integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      mdcscaler      : integer range 0 to 2047 := 25; 
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 3 := 1;
      edclbufsz      : integer range 1 to 64 := 1;
      burstlength    : integer range 4 to 128 := 32;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      sim            : integer range 0 to 1 := 0;
      oepol          : integer range 0 to 1 := 0;
      scanen         : integer range 0 to 1 := 0;
      ft             : integer range 0 to 2 := 0;
      edclft         : integer range 0 to 2 := 0;
      mdint_pol      : integer range 0 to 1 := 0;
      enable_mdint   : integer range 0 to 1 := 0;
      multicast      : integer range 0 to 1 := 0;
      edclsepahbg    : integer range 0 to 1 := 0;
      ramdebug       : integer range 0 to 2 := 0;
      gmiimode       : integer range 0 to 1 := 0
      );
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      --ahb mst in
      hgrant         : in  std_ulogic;
      hready         : in  std_ulogic;   
      hresp          : in  std_logic_vector(1 downto 0);
      hrdata         : in  std_logic_vector(31 downto 0); 
      --ahb mst out
      hbusreq        : out  std_ulogic;        
      hlock          : out  std_ulogic;
      htrans         : out  std_logic_vector(1 downto 0);
      haddr          : out  std_logic_vector(31 downto 0);
      hwrite         : out  std_ulogic;
      hsize          : out  std_logic_vector(2 downto 0);
      hburst         : out  std_logic_vector(2 downto 0);
      hprot          : out  std_logic_vector(3 downto 0);
      hwdata         : out  std_logic_vector(31 downto 0);
      --edcl ahb mst in
      ehgrant        : in  std_ulogic;
      ehready        : in  std_ulogic;   
      ehresp         : in  std_logic_vector(1 downto 0);
      ehrdata        : in  std_logic_vector(31 downto 0); 
      --edcl ahb mst out
      ehbusreq       : out  std_ulogic;        
      ehlock         : out  std_ulogic;
      ehtrans        : out  std_logic_vector(1 downto 0);
      ehaddr         : out  std_logic_vector(31 downto 0);
      ehwrite        : out  std_ulogic;
      ehsize         : out  std_logic_vector(2 downto 0);
      ehburst        : out  std_logic_vector(2 downto 0);
      ehprot         : out  std_logic_vector(3 downto 0);
      ehwdata        : out  std_logic_vector(31 downto 0);
      --apb slv in 
      psel	   : in   std_ulogic;
      penable	   : in   std_ulogic;
      paddr	   : in   std_logic_vector(31 downto 0);
      pwrite	   : in   std_ulogic;
      pwdata	   : in   std_logic_vector(31 downto 0);
      --apb slv out
      prdata	   : out  std_logic_vector(31 downto 0);
      --irq
      irq            : out  std_logic;
      --ethernet input signals
      gtx_clk        : in   std_ulogic;                     
      tx_clk         : in   std_ulogic;
      tx_dv          : in   std_ulogic;
      rx_clk         : in   std_ulogic;
      rxd            : in   std_logic_vector(7 downto 0);   
      rx_dv          : in   std_ulogic; 
      rx_er          : in   std_ulogic; 
      rx_col         : in   std_ulogic;
      rx_crs         : in   std_ulogic;
      rx_en          : in   std_ulogic;
      mdio_i         : in   std_ulogic;
      phyrstaddr     : in   std_logic_vector(4 downto 0);
      mdint          : in   std_ulogic;
      --ethernet output signals
      reset          : out  std_ulogic;
      txd            : out  std_logic_vector(7 downto 0);   
      tx_en          : out  std_ulogic; 
      tx_er          : out  std_ulogic; 
      mdc            : out  std_ulogic;    
      mdio_o         : out  std_ulogic; 
      mdio_oe        : out  std_ulogic;
      --scantest
      testrst        : in   std_ulogic;
      testen         : in   std_ulogic;
      testoen        : in   std_ulogic;
      edcladdr       : in   std_logic_vector(3 downto 0);
      edclsepahb     : in   std_ulogic;
      edcldisable    : in   std_ulogic;
      speed          : out  std_ulogic;
      gbit           : out  std_ulogic
      );
  end component;
  
end package;

