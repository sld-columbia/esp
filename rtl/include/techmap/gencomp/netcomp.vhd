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
-- Package: 	netcomp
-- File:	netcomp.vhd
-- Author:	Jiri Gaisler - Aeroflex Gaisler
-- Description:	Declaration of netlists components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.gencomp.all;

package netcomp is

---------------------------------------------------------------------------
-- netlists ---------------------------------------------------------------
---------------------------------------------------------------------------

component grusbhc_net is
  generic (
    tech        : integer                  := 0;
    nports      : integer range 1 to 15    := 1;
    ehcgen      : integer range 0 to 1     := 1;
    uhcgen      : integer range 0 to 1     := 1;
    n_cc        : integer range 1 to 15    := 1;
    n_pcc       : integer range 1 to 15    := 1;
    prr         : integer range 0 to 1     := 0;
    portroute1  : integer                  := 0;
    portroute2  : integer                  := 0;
    endian_conv : integer range 0 to 1     := 1;
    be_regs     : integer range 0 to 1     := 0;
    be_desc     : integer range 0 to 1     := 0;
    uhcblo      : integer range 0 to 255   := 2;
    bwrd        : integer range 1 to 256   := 16;
    utm_type    : integer range 0 to 2     := 2;
    vbusconf    : integer                  := 3;
    ramtest     : integer range 0 to 1     := 0;
    urst_time   : integer                  := 250;
    oepol       : integer range 0 to 1     := 0;
    scantest    : integer range 0 to 1     := 0;
    isfpga      : integer range 0 to 1     := 1;
    memsel      : integer                  := 0;
    syncprst    : integer range 0 to 1     := 0;
    sysfreq     : integer                  := 65000;
    pcidev      : integer range 0 to 1     := 0;
    debug       : integer                  := 0;
    debug_abits : integer                  := 12);
  port (
    clk               : in  std_ulogic;
    uclk              : in  std_ulogic;
    rst               : in  std_ulogic;
    -- EHC apb_slv_in_type unwrapped
    ehc_apbsi_psel    : in  std_ulogic;
    ehc_apbsi_penable : in  std_ulogic;
    ehc_apbsi_paddr   : in  std_logic_vector(31 downto 0);
    ehc_apbsi_pwrite  : in  std_ulogic;
    ehc_apbsi_pwdata  : in  std_logic_vector(31 downto 0);
    -- EHC apb_slv_out_type unwrapped
    ehc_apbso_prdata  : out std_logic_vector(31 downto 0);
    ehc_apbso_pirq    : out std_ulogic;
    -- EHC/UHC ahb_mst_in_type unwrapped
    ahbmi_hgrant      : in  std_logic_vector(n_cc*uhcgen downto 0);
    ahbmi_hready      : in  std_ulogic;
    ahbmi_hresp       : in  std_logic_vector(1 downto 0);
    ahbmi_hrdata      : in  std_logic_vector(31 downto 0);
    -- UHC ahb_slv_in_type unwrapped
    uhc_ahbsi_hsel    : in  std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbsi_haddr   : in  std_logic_vector(31 downto 0);
    uhc_ahbsi_hwrite  : in  std_ulogic;
    uhc_ahbsi_htrans  : in  std_logic_vector(1 downto 0);
    uhc_ahbsi_hsize   : in  std_logic_vector(2 downto 0);
    uhc_ahbsi_hwdata  : in  std_logic_vector(31 downto 0);
    uhc_ahbsi_hready  : in  std_ulogic;
    -- EHC ahb_mst_out_type_unwrapped
    ehc_ahbmo_hbusreq : out std_ulogic;
    ehc_ahbmo_hlock   : out std_ulogic;
    ehc_ahbmo_htrans  : out std_logic_vector(1 downto 0);
    ehc_ahbmo_haddr   : out std_logic_vector(31 downto 0);
    ehc_ahbmo_hwrite  : out std_ulogic;
    ehc_ahbmo_hsize   : out std_logic_vector(2 downto 0);
    ehc_ahbmo_hburst  : out std_logic_vector(2 downto 0);
    ehc_ahbmo_hprot   : out std_logic_vector(3 downto 0);
    ehc_ahbmo_hwdata  : out std_logic_vector(31 downto 0);
    -- UHC ahb_mst_out_vector_type unwrapped
    uhc_ahbmo_hbusreq : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hlock   : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbmo_htrans  : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_haddr   : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hwrite  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hsize   : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hburst  : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hprot   : out std_logic_vector((n_cc*4)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hwdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    -- UHC ahb_slv_out_vector_type unwrapped
    uhc_ahbso_hready  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbso_hresp   : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
    uhc_ahbso_hrdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    uhc_ahbso_hsplit  : out std_logic_vector((n_cc*16)*uhcgen downto 1*uhcgen);
    uhc_ahbso_hirq    : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    -- grusb_out_type_vector unwrapped
    xcvrsel           : out std_logic_vector(((nports*2)-1) downto 0);
    termsel           : out std_logic_vector((nports-1) downto 0);
    opmode            : out std_logic_vector(((nports*2)-1) downto 0);
    txvalid           : out std_logic_vector((nports-1) downto 0);
    drvvbus           : out std_logic_vector((nports-1) downto 0);
    dataho            : out std_logic_vector(((nports*8)-1) downto 0);
    validho           : out std_logic_vector((nports-1) downto 0);
    stp               : out std_logic_vector((nports-1) downto 0);
    datao             : out std_logic_vector(((nports*8)-1) downto 0);
    utm_rst           : out std_logic_vector((nports-1) downto 0);
    dctrlo            : out std_logic_vector((nports-1) downto 0);
    suspendm          : out std_ulogic;
    dbus16_8          : out std_ulogic;
    dppulldown        : out std_ulogic;
    dmpulldown        : out std_ulogic;
    idpullup          : out std_ulogic;
    dischrgvbus       : out std_ulogic;
    chrgvbus          : out std_ulogic;
    txbitstuffenable  : out std_ulogic;
    txbitstuffenableh : out std_ulogic;
    fslsserialmode    : out std_ulogic;
    txenablen         : out std_ulogic;
    txdat             : out std_ulogic;
    txse0             : out std_ulogic;
    -- grusb_in_type_vector unwrapped
    linestate         : in  std_logic_vector(((nports*2)-1) downto 0);
    txready           : in  std_logic_vector((nports-1) downto 0);
    rxvalid           : in  std_logic_vector((nports-1) downto 0);
    rxactive          : in  std_logic_vector((nports-1) downto 0);
    rxerror           : in  std_logic_vector((nports-1) downto 0);
    vbusvalid         : in  std_logic_vector((nports-1) downto 0);
    datahi            : in  std_logic_vector(((nports*8)-1) downto 0);
    validhi           : in  std_logic_vector((nports-1) downto 0);
    hostdisc          : in  std_logic_vector((nports-1) downto 0);
    nxt               : in  std_logic_vector((nports-1) downto 0);
    dir               : in  std_logic_vector((nports-1) downto 0);
    datai             : in  std_logic_vector(((nports*8)-1) downto 0);
    urstdrive         : in  std_logic_vector((nports-1) downto 0);
    -- EHC transaction buffer signals
    mbc20_tb_addr     : out std_logic_vector(8 downto 0);
    mbc20_tb_data     : out std_logic_vector(31 downto 0);
    mbc20_tb_en       : out std_ulogic;
    mbc20_tb_wel      : out std_ulogic;
    mbc20_tb_weh      : out std_ulogic;
    tb_mbc20_data     : in  std_logic_vector(31 downto 0);
    pe20_tb_addr      : out std_logic_vector(8 downto 0);
    pe20_tb_data      : out std_logic_vector(31 downto 0);
    pe20_tb_en        : out std_ulogic;
    pe20_tb_wel       : out std_ulogic;
    pe20_tb_weh       : out std_ulogic;
    tb_pe20_data      : in  std_logic_vector(31 downto 0);
    -- EHC packet buffer signals
    mbc20_pb_addr     : out std_logic_vector(8 downto 0);
    mbc20_pb_data     : out std_logic_vector(31 downto 0);
    mbc20_pb_en       : out std_ulogic;
    mbc20_pb_we       : out std_ulogic;
    pb_mbc20_data     : in  std_logic_vector(31 downto 0);
    sie20_pb_addr     : out std_logic_vector(8 downto 0);
    sie20_pb_data     : out std_logic_vector(31 downto 0);
    sie20_pb_en       : out std_ulogic;
    sie20_pb_we       : out std_ulogic;
    pb_sie20_data     : in  std_logic_vector(31 downto 0);
    -- UHC packet buffer signals
    sie11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
    sie11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    sie11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    sie11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    pb_sie11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    mbc11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
    mbc11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    mbc11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    mbc11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    pb_mbc11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    bufsel            : out std_ulogic;
    -- scan signals
    testen            : in  std_ulogic;
    testrst           : in  std_ulogic;
    scanen            : in  std_ulogic;
    testoen           : in  std_ulogic;
    -- debug signals
    debug_raddr       : out std_logic_vector(15 downto 0);
    debug_waddr       : out std_logic_vector(15 downto 0);
    debug_wdata       : out std_logic_vector(31 downto 0);
    debug_we          : out std_ulogic;
    debug_rdata       : in  std_logic_vector(31 downto 0));
  end component;

component grspwc_net
  generic(
    tech         : integer := 0;
    sysfreq      : integer := 40000;
    usegen       : integer range 0 to 1  := 1;
    nsync        : integer range 1 to 2  := 1;
    rmap         : integer range 0 to 2  := 0;
    rmapcrc      : integer range 0 to 1  := 0;
    fifosize1    : integer range 4 to 32 := 32;
    fifosize2    : integer range 16 to 64 := 64;
    rxunaligned  : integer range 0 to 1 := 0;
    rmapbufs     : integer range 2 to 8 := 4;
    scantest     : integer range 0 to 1 := 0;
    nodeaddr     : integer range 0 to 255 := 254;
    destkey      : integer range 0 to 255 := 0
  );
  port(
    rst          : in  std_ulogic;
    clk          : in  std_ulogic;
    txclk        : in  std_ulogic;
    --ahb mst in
    hgrant       : in  std_ulogic;
    hready       : in  std_ulogic;
    hresp        : in  std_logic_vector(1 downto 0);
    hrdata       : in  std_logic_vector(31 downto 0);
    --ahb mst out
    hbusreq      : out  std_ulogic;
    hlock        : out  std_ulogic;
    htrans       : out  std_logic_vector(1 downto 0);
    haddr        : out  std_logic_vector(31 downto 0);
    hwrite       : out  std_ulogic;
    hsize        : out  std_logic_vector(2 downto 0);
    hburst       : out  std_logic_vector(2 downto 0);
    hprot        : out  std_logic_vector(3 downto 0);
    hwdata       : out  std_logic_vector(31 downto 0);
    --apb slv in
    psel	 : in   std_ulogic;
    penable	 : in   std_ulogic;
    paddr	 : in   std_logic_vector(31 downto 0);
    pwrite	 : in   std_ulogic;
    pwdata	 : in   std_logic_vector(31 downto 0);
    --apb slv out
    prdata	 : out  std_logic_vector(31 downto 0);
    --spw in
    d 		 : in std_logic_vector(1 downto 0);
    nd 		 : in std_logic_vector(9 downto 0);
    dconnect	 : in std_logic_vector(3 downto 0);
    --spw out
    do 		 : out std_logic_vector(1 downto 0);
    so 		 : out std_logic_vector(1 downto 0);
    rxrsto       : out std_ulogic;
    --time iface
    tickin       : in   std_ulogic;
    tickout      : out  std_ulogic;
    --irq
    irq          : out  std_logic;
    --misc
    clkdiv10     : in   std_logic_vector(7 downto 0);
    dcrstval     : in   std_logic_vector(9 downto 0);
    timerrstval  : in   std_logic_vector(11 downto 0);
    --rmapen
    rmapen       : in   std_ulogic;
    rmapnodeaddr : in   std_logic_vector(7 downto 0);
    --clk bufs
    rxclki       : in std_logic_vector(1 downto 0);
    --rx ahb fifo
    rxrenable    : out  std_ulogic;
    rxraddress   : out  std_logic_vector(4 downto 0);
    rxwrite      : out  std_ulogic;
    rxwdata      : out  std_logic_vector(31 downto 0);
    rxwaddress   : out  std_logic_vector(4 downto 0);
    rxrdata      : in   std_logic_vector(31 downto 0);
    --tx ahb fifo
    txrenable    : out  std_ulogic;
    txraddress   : out  std_logic_vector(4 downto 0);
    txwrite      : out  std_ulogic;
    txwdata      : out  std_logic_vector(31 downto 0);
    txwaddress   : out  std_logic_vector(4 downto 0);
    txrdata      : in   std_logic_vector(31 downto 0);
    --nchar fifo
    ncrenable    : out  std_ulogic;
    ncraddress   : out  std_logic_vector(5 downto 0);
    ncwrite      : out  std_ulogic;
    ncwdata      : out  std_logic_vector(8 downto 0);
    ncwaddress   : out  std_logic_vector(5 downto 0);
    ncrdata      : in   std_logic_vector(8 downto 0);
    --rmap buf
    rmrenable    : out  std_ulogic;
    rmraddress   : out  std_logic_vector(7 downto 0);
    rmwrite      : out  std_ulogic;
    rmwdata      : out  std_logic_vector(7 downto 0);
    rmwaddress   : out  std_logic_vector(7 downto 0);
    rmrdata      : in   std_logic_vector(7 downto 0);
    linkdis      : out  std_ulogic;
    testclk      : in   std_ulogic := '0';
    testrst      : in   std_ulogic := '0';
    testen       : in   std_ulogic := '0'
  );
end component;

component grspwc2_net is
  generic(
    rmap            : integer range 0 to 2  := 0;
    rmapcrc         : integer range 0 to 1  := 0;
    fifosize1       : integer range 4 to 32 := 32;
    fifosize2       : integer range 16 to 64 := 64;
    rxunaligned     : integer range 0 to 1 := 0;
    rmapbufs        : integer range 2 to 8 := 4;
    scantest        : integer range 0 to 1 := 0;
    ports           : integer range 1 to 2 := 1;
    dmachan         : integer range 1 to 4 := 1;
    tech            : integer;
    input_type      : integer range 0 to 4 := 0;
    output_type     : integer range 0 to 2 := 0;
    rxtx_sameclk    : integer range 0 to 1 := 0;
    nodeaddr        : integer range 0 to 255 := 254;
    destkey         : integer range 0 to 255 := 0;
    interruptdist   : integer range 0 to 32 := 0;
    intscalerbits   : integer range 0 to 31 := 0;
    intisrtimerbits : integer range 0 to 31 := 0;
    intiatimerbits  : integer range 0 to 31 := 0;
    intctimerbits   : integer range 0 to 31 := 0;
    tickinasync     : integer range 0 to 1 := 0;
    pnp             : integer range 0 to 2 := 0;
    pnpvendid       : integer range 0 to 16#FFFF# := 0;
    pnpprodid       : integer range 0 to 16#FFFF# := 0;
    pnpmajorver     : integer range 0 to 16#FF# := 0;
    pnpminorver     : integer range 0 to 16#FF# := 0;
    pnppatch        : integer range 0 to 16#FF# := 0;
    num_txdesc      : integer range 64 to 512 := 64;
    num_rxdesc      : integer range 128 to 1024 := 128    
    );
  port(
    rst          : in  std_ulogic;
    clk          : in  std_ulogic;
    rxclk        : in  std_logic_vector(1 downto 0);
    txclk        : in  std_ulogic;
    txclkn       : in  std_ulogic;
    --ahb mst in
    hgrant       : in  std_ulogic;
    hready       : in  std_ulogic;
    hresp        : in  std_logic_vector(1 downto 0);
    hrdata       : in  std_logic_vector(31 downto 0);
    --ahb mst out
    hbusreq      : out  std_ulogic;
    hlock        : out  std_ulogic;
    htrans       : out  std_logic_vector(1 downto 0);
    haddr        : out  std_logic_vector(31 downto 0);
    hwrite       : out  std_ulogic;
    hsize        : out  std_logic_vector(2 downto 0);
    hburst       : out  std_logic_vector(2 downto 0);
    hprot        : out  std_logic_vector(3 downto 0);
    hwdata       : out  std_logic_vector(31 downto 0);
    --apb slv in
    psel	 : in   std_ulogic;
    penable	 : in   std_ulogic;
    paddr	 : in   std_logic_vector(31 downto 0);
    pwrite	 : in   std_ulogic;
    pwdata	 : in   std_logic_vector(31 downto 0);
    --apb slv out
    prdata	 : out  std_logic_vector(31 downto 0);
    --spw in
    d            : in   std_logic_vector(3 downto 0);
    dv           : in   std_logic_vector(3 downto 0);
    dconnect     : in   std_logic_vector(3 downto 0);
    --spw out
    do           : out  std_logic_vector(3 downto 0);
    so           : out  std_logic_vector(3 downto 0);
    --time iface
    tickin       : in   std_logic;
    tickinraw    : in   std_logic;
    timein       : in   std_logic_vector(7 downto 0);
    tickindone   : out  std_logic;
    tickout      : out  std_logic;
    tickoutraw   : out  std_logic;
    timeout      : out  std_logic_vector(7 downto 0);
    --irq
    irq          : out  std_logic;
    --misc
    clkdiv10     : in   std_logic_vector(7 downto 0);
    dcrstval     : in   std_logic_vector(9 downto 0);
    timerrstval  : in   std_logic_vector(11 downto 0);
    --rmapen
    rmapen       : in   std_ulogic;
    rmapnodeaddr : in   std_logic_vector(7 downto 0);
    --rx ahb fifo
    rxrenable    : out  std_ulogic;
    rxraddress   : out  std_logic_vector(5 downto 0);
    rxwrite      : out  std_ulogic;
    rxwdata      : out  std_logic_vector(31 downto 0);
    rxwaddress   : out  std_logic_vector(5 downto 0);
    rxrdata      : in   std_logic_vector(31 downto 0);
    --tx ahb fifo
    txrenable    : out  std_ulogic;
    txraddress   : out  std_logic_vector(5 downto 0);
    txwrite      : out  std_ulogic;
    txwdata      : out  std_logic_vector(31 downto 0);
    txwaddress   : out  std_logic_vector(5 downto 0);
    txrdata      : in   std_logic_vector(31 downto 0);
    --nchar fifo
    ncrenable    : out  std_ulogic;
    ncraddress   : out  std_logic_vector(5 downto 0);
    ncwrite      : out  std_ulogic;
    ncwdata      : out  std_logic_vector(9 downto 0);
    ncwaddress   : out  std_logic_vector(5 downto 0);
    ncrdata      : in   std_logic_vector(9 downto 0);
    --rmap buf
    rmrenable    : out  std_ulogic;
    rmraddress   : out  std_logic_vector(7 downto 0);
    rmwrite      : out  std_ulogic;
    rmwdata      : out  std_logic_vector(7 downto 0);
    rmwaddress   : out  std_logic_vector(7 downto 0);
    rmrdata      : in   std_logic_vector(7 downto 0);
    linkdis      : out  std_ulogic;
    testclk      : in   std_ulogic;
    testrst      : in   std_logic;
    testen       : in   std_logic;
    rxdav        : out  std_logic;
    rxdataout    : out  std_logic_vector(8 downto 0);
    loopback     : out  std_logic;
    -- interrupt dist. default values
    intpreload   : in   std_logic_vector(30 downto 0);
    inttreload   : in   std_logic_vector(30 downto 0);
    intiareload  : in   std_logic_vector(30 downto 0);
    intcreload   : in   std_logic_vector(30 downto 0);
    irqtxdefault : in   std_logic_vector(4 downto 0);
    --SpW PnP enable
    pnpen        : in   std_ulogic;
    pnpuvendid   : in   std_logic_vector(15 downto 0);
    pnpuprodid   : in   std_logic_vector(15 downto 0);
    pnpusn       : in   std_logic_vector(31 downto 0)    
  );
end component;

  component grlfpw_net
  generic (tech     : integer := 0;
           pclow    : integer range 0 to 2 := 2;
           dsu      : integer range 0 to 1 := 1;
           disas    : integer range 0 to 2 := 0;
           pipe     : integer range 0 to 2 := 0
           );
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi_flush  	: in std_ulogic;			  -- pipeline flush
    cpi_exack    	: in std_ulogic;			  -- FP exception acknowledge
    cpi_a_rs1  	: in std_logic_vector(4 downto 0);
    cpi_d_pc    : in std_logic_vector(31 downto 0);
    cpi_d_inst  : in std_logic_vector(31 downto 0);
    cpi_d_cnt   : in std_logic_vector(1 downto 0);
    cpi_d_trap  : in std_ulogic;
    cpi_d_annul : in std_ulogic;
    cpi_d_pv    : in std_ulogic;
    cpi_a_pc    : in std_logic_vector(31 downto 0);
    cpi_a_inst  : in std_logic_vector(31 downto 0);
    cpi_a_cnt   : in std_logic_vector(1 downto 0);
    cpi_a_trap  : in std_ulogic;
    cpi_a_annul : in std_ulogic;
    cpi_a_pv    : in std_ulogic;
    cpi_e_pc    : in std_logic_vector(31 downto 0);
    cpi_e_inst  : in std_logic_vector(31 downto 0);
    cpi_e_cnt   : in std_logic_vector(1 downto 0);
    cpi_e_trap  : in std_ulogic;
    cpi_e_annul : in std_ulogic;
    cpi_e_pv    : in std_ulogic;
    cpi_m_pc    : in std_logic_vector(31 downto 0);
    cpi_m_inst  : in std_logic_vector(31 downto 0);
    cpi_m_cnt   : in std_logic_vector(1 downto 0);
    cpi_m_trap  : in std_ulogic;
    cpi_m_annul : in std_ulogic;
    cpi_m_pv    : in std_ulogic;
    cpi_x_pc    : in std_logic_vector(31 downto 0);
    cpi_x_inst  : in std_logic_vector(31 downto 0);
    cpi_x_cnt   : in std_logic_vector(1 downto 0);
    cpi_x_trap  : in std_ulogic;
    cpi_x_annul : in std_ulogic;
    cpi_x_pv    : in std_ulogic;
    cpi_lddata        : in std_logic_vector(31 downto 0);     -- load data
    cpi_dbg_enable : in std_ulogic;
    cpi_dbg_write  : in std_ulogic;
    cpi_dbg_fsr    : in std_ulogic;                            -- FSR access
    cpi_dbg_addr   : in std_logic_vector(4 downto 0);
    cpi_dbg_data   : in std_logic_vector(31 downto 0);
    cpo_data          : out std_logic_vector(31 downto 0); -- store data
    cpo_exc  	        : out std_logic;			 -- FP exception
    cpo_cc           : out std_logic_vector(1 downto 0);  -- FP condition codes
    cpo_ccv  	       : out std_ulogic;			 -- FP condition codes valid
    cpo_ldlock       : out std_logic;			 -- FP pipeline hold
    cpo_holdn         : out std_ulogic;
    cpo_dbg_data     : out std_logic_vector(31 downto 0);

    rfi1_rd1addr 	: out std_logic_vector(3 downto 0);
    rfi1_rd2addr 	: out std_logic_vector(3 downto 0);
    rfi1_wraddr 	: out std_logic_vector(3 downto 0);
    rfi1_wrdata 	: out std_logic_vector(31 downto 0);
    rfi1_ren1        : out std_ulogic;
    rfi1_ren2        : out std_ulogic;
    rfi1_wren        : out std_ulogic;

    rfi2_rd1addr 	: out std_logic_vector(3 downto 0);
    rfi2_rd2addr 	: out std_logic_vector(3 downto 0);
    rfi2_wraddr 	: out std_logic_vector(3 downto 0);
    rfi2_wrdata 	: out std_logic_vector(31 downto 0);
    rfi2_ren1        : out std_ulogic;
    rfi2_ren2        : out std_ulogic;
    rfi2_wren        : out std_ulogic;

    rfo1_data1    	: in std_logic_vector(31 downto 0);
    rfo1_data2    	: in std_logic_vector(31 downto 0);
    rfo2_data1    	: in std_logic_vector(31 downto 0);
    rfo2_data2    	: in std_logic_vector(31 downto 0)
    );
  end component;

  component grfpw_net
  generic (tech     : integer := 0;
           pclow    : integer range 0 to 2 := 2;
           dsu      : integer range 0 to 2 := 1;
           disas    : integer range 0 to 2 := 0;
           pipe     : integer range 0 to 2 := 0
           );
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi_flush  	: in std_ulogic;			  -- pipeline flush
    cpi_exack    	: in std_ulogic;			  -- FP exception acknowledge
    cpi_a_rs1  	: in std_logic_vector(4 downto 0);
    cpi_d_pc    : in std_logic_vector(31 downto 0);
    cpi_d_inst  : in std_logic_vector(31 downto 0);
    cpi_d_cnt   : in std_logic_vector(1 downto 0);
    cpi_d_trap  : in std_ulogic;
    cpi_d_annul : in std_ulogic;
    cpi_d_pv    : in std_ulogic;
    cpi_a_pc    : in std_logic_vector(31 downto 0);
    cpi_a_inst  : in std_logic_vector(31 downto 0);
    cpi_a_cnt   : in std_logic_vector(1 downto 0);
    cpi_a_trap  : in std_ulogic;
    cpi_a_annul : in std_ulogic;
    cpi_a_pv    : in std_ulogic;
    cpi_e_pc    : in std_logic_vector(31 downto 0);
    cpi_e_inst  : in std_logic_vector(31 downto 0);
    cpi_e_cnt   : in std_logic_vector(1 downto 0);
    cpi_e_trap  : in std_ulogic;
    cpi_e_annul : in std_ulogic;
    cpi_e_pv    : in std_ulogic;
    cpi_m_pc    : in std_logic_vector(31 downto 0);
    cpi_m_inst  : in std_logic_vector(31 downto 0);
    cpi_m_cnt   : in std_logic_vector(1 downto 0);
    cpi_m_trap  : in std_ulogic;
    cpi_m_annul : in std_ulogic;
    cpi_m_pv    : in std_ulogic;
    cpi_x_pc    : in std_logic_vector(31 downto 0);
    cpi_x_inst  : in std_logic_vector(31 downto 0);
    cpi_x_cnt   : in std_logic_vector(1 downto 0);
    cpi_x_trap  : in std_ulogic;
    cpi_x_annul : in std_ulogic;
    cpi_x_pv    : in std_ulogic;
    cpi_lddata        : in std_logic_vector(31 downto 0);     -- load data
    cpi_dbg_enable : in std_ulogic;
    cpi_dbg_write  : in std_ulogic;
    cpi_dbg_fsr    : in std_ulogic;                            -- FSR access
    cpi_dbg_addr   : in std_logic_vector(4 downto 0);
    cpi_dbg_data   : in std_logic_vector(31 downto 0);
    cpo_data          : out std_logic_vector(31 downto 0); -- store data
    cpo_exc  	        : out std_logic;			 -- FP exception
    cpo_cc           : out std_logic_vector(1 downto 0);  -- FP condition codes
    cpo_ccv  	       : out std_ulogic;			 -- FP condition codes valid
    cpo_ldlock       : out std_logic;			 -- FP pipeline hold
    cpo_holdn         : out std_ulogic;
    cpo_dbg_data     : out std_logic_vector(31 downto 0);

    rfi1_rd1addr 	: out std_logic_vector(3 downto 0);
    rfi1_rd2addr 	: out std_logic_vector(3 downto 0);
    rfi1_wraddr 	: out std_logic_vector(3 downto 0);
    rfi1_wrdata 	: out std_logic_vector(31 downto 0);
    rfi1_ren1        : out std_ulogic;
    rfi1_ren2        : out std_ulogic;
    rfi1_wren        : out std_ulogic;

    rfi2_rd1addr 	: out std_logic_vector(3 downto 0);
    rfi2_rd2addr 	: out std_logic_vector(3 downto 0);
    rfi2_wraddr 	: out std_logic_vector(3 downto 0);
    rfi2_wrdata 	: out std_logic_vector(31 downto 0);
    rfi2_ren1        : out std_ulogic;
    rfi2_ren2        : out std_ulogic;
    rfi2_wren        : out std_ulogic;

    rfo1_data1    	: in std_logic_vector(31 downto 0);
    rfo1_data2    	: in std_logic_vector(31 downto 0);
    rfo2_data1    	: in std_logic_vector(31 downto 0);
    rfo2_data2    	: in std_logic_vector(31 downto 0)
    );
  end component;

  component leon3_net
  generic (
    hindex     :     integer                  := 0;
    fabtech    :     integer range 0 to NTECH := DEFFABTECH;
    memtech    :     integer range 0 to NTECH := DEFMEMTECH;
    nwindows   :     integer range 2 to 32    := 8;
    dsu        :     integer range 0 to 1     := 0;
    fpu        :     integer range 0 to 63    := 0;
    v8         :     integer range 0 to 63    := 0;
    cp         :     integer range 0 to 1     := 0;
    mac        :     integer range 0 to 1     := 0;
    pclow      :     integer range 0 to 2     := 2;
    notag      :     integer range 0 to 1     := 0;
    nwp        :     integer range 0 to 4     := 0;
    icen       :     integer range 0 to 1     := 0;
    irepl      :     integer range 0 to 3     := 2;
    isets      :     integer range 1 to 4     := 1;
    ilinesize  :     integer range 4 to 8     := 4;
    isetsize   :     integer range 1 to 256   := 1;
    isetlock   :     integer range 0 to 1     := 0;
    dcen       :     integer range 0 to 1     := 0;
    drepl      :     integer range 0 to 3     := 2;
    dsets      :     integer range 1 to 4     := 1;
    dlinesize  :     integer range 4 to 8     := 4;
    dsetsize   :     integer range 1 to 256   := 1;
    dsetlock   :     integer range 0 to 1     := 0;
    dsnoop     :     integer range 0 to 6     := 0;
    ilram      :     integer range 0 to 1     := 0;
    ilramsize  :     integer range 1 to 512   := 1;
    ilramstart :     integer range 0 to 255   := 16#8e#;
    dlram      :     integer range 0 to 1     := 0;
    dlramsize  :     integer range 1 to 512   := 1;
    dlramstart :     integer range 0 to 255   := 16#8f#;
    mmuen      :     integer range 0 to 1     := 0;
    itlbnum    :     integer range 2 to 64    := 8;
    dtlbnum    :     integer range 2 to 64    := 8;
    tlb_type   :     integer range 0 to 3     := 1;
    tlb_rep    :     integer range 0 to 1     := 0;
    lddel      :     integer range 1 to 2     := 2;
    disas      :     integer range 0 to 2     := 0;
    tbuf       :     integer range 0 to 128   := 0;
    pwd        :     integer range 0 to 2     := 2;
    svt        :     integer range 0 to 1     := 1;
    rstaddr    :     integer                  := 0;
    smp        :     integer range 0 to 15    := 0;
    iuft       :     integer range 0 to 4     := 0;
    fpft       :     integer range 0 to 4     := 0;
    cmft       :     integer range 0 to 1     := 0;
    cached     :     integer                  := 0;
    clk2x      :     integer                  := 1;
    scantest   :     integer                  := 0;
    mmupgsz    :     integer range 0 to 5     := 0;
    bp         :     integer                  := 1;
    npasi      :     integer range 0 to 1     := 0;
    pwrpsr     :     integer range 0 to 1     := 0;
    rex        :     integer range 0 to 1     := 0;
    altwin     :     integer range 0 to 1     := 0
  );
  port (
     clk               : in  std_ulogic;                     -- free-running clock
     gclk2             : in  std_ulogic;                     -- gated 2x clock
     gfclk2            : in  std_ulogic;                     -- gated 2x FPU clock
     clk2              : in  std_ulogic;                     -- free-running 2x clock
     rstn              : in  std_ulogic;
     ahbi              : in  ahb_mst_in_type;
     ahbo              : out ahb_mst_out_type;
     ahbsi             : in  ahb_slv_in_type;
--   ahbso      : in  ahb_slv_out_vector;
     irqi_irl          : in  std_logic_vector(3 downto 0);
     irqi_resume       : in  std_ulogic;
     irqi_rstrun       : in  std_ulogic;
     irqi_rstvec       : in  std_logic_vector(31 downto 12);
     irqi_index        : in  std_logic_vector(3 downto 0);
     irqi_pwdsetaddr   : in  std_ulogic;
     irqi_pwdnewaddr   : in  std_logic_vector(31 downto 2);
     irqi_forceerr     : in  std_ulogic;

     irqo_intack       : out std_ulogic;
     irqo_irl          : out std_logic_vector(3 downto 0);
     irqo_pwd          : out std_ulogic;
     irqo_fpen         : out std_ulogic;
     irqo_err          : out std_ulogic;

     dbgi_dsuen        : in  std_ulogic;                               -- DSU enable
     dbgi_denable      : in  std_ulogic;                               -- diagnostic register access enablee
     dbgi_dbreak       : in  std_ulogic;                               -- debug break-in
     dbgi_step         : in  std_ulogic;                               -- single step
     dbgi_halt         : in  std_ulogic;                               -- halt processor
     dbgi_reset        : in  std_ulogic;                               -- reset processor
     dbgi_dwrite       : in  std_ulogic;                               -- read/write
     dbgi_daddr        : in  std_logic_vector(23 downto 2);            -- diagnostic address
     dbgi_ddata        : in  std_logic_vector(31 downto 0);            -- diagnostic data
     dbgi_btrapa       : in  std_ulogic;                               -- break on IU trap
     dbgi_btrape       : in  std_ulogic;                               -- break on IU trap
     dbgi_berror       : in  std_ulogic;                               -- break on IU error mode
     dbgi_bwatch       : in  std_ulogic;                               -- break on IU watchpoint
     dbgi_bsoft        : in  std_ulogic;                               -- break on software breakpoint (TA 1)
     dbgi_tenable      : in  std_ulogic;
     dbgi_timer        : in  std_logic_vector(30 downto 0);
    
     dbgo_data         : out std_logic_vector(31 downto 0);
     dbgo_crdy         : out std_ulogic;
     dbgo_dsu          : out std_ulogic;
     dbgo_dsumode      : out std_ulogic;
     dbgo_error        : out std_ulogic;
     dbgo_halt         : out std_ulogic;
     dbgo_pwd          : out std_ulogic;
     dbgo_idle         : out std_ulogic;
     dbgo_ipend        : out std_ulogic;
     dbgo_icnt         : out std_ulogic;
     dbgo_fcnt         : out std_ulogic;
     dbgo_optype       : out std_logic_vector(5 downto 0);     -- instruction type
     dbgo_bpmiss       : out std_ulogic;                       -- branch predict miss
     dbgo_istat_cmiss  : out std_ulogic;
     dbgo_istat_tmiss  : out std_ulogic;
     dbgo_istat_chold  : out std_ulogic;
     dbgo_istat_mhold  : out std_ulogic;
     dbgo_dstat_cmiss  : out std_ulogic;
     dbgo_dstat_tmiss  : out std_ulogic;
     dbgo_dstat_chold  : out std_ulogic;
     dbgo_dstat_mhold  : out std_ulogic;
     dbgo_wbhold       : out std_ulogic;                       -- write buffer hold
     dbgo_su           : out std_ulogic;
     
    -- fpui       : out grfpu_in_type;
    -- fpuo       : in  grfpu_out_type;
     
     clken             : in std_ulogic
    );
  end component;

component ssrctrl_net
   generic (
      tech:                   Integer := 0;
      bus16:                  Integer := 1);
   port (
      rst:              in    Std_Logic;
      clk:              in    Std_Logic;

      n_ahbsi_hsel:     in    Std_Logic_Vector(0 to 15);
      n_ahbsi_haddr:    in    Std_Logic_Vector(31 downto 0);
      n_ahbsi_hwrite:   in    Std_Logic;
      n_ahbsi_htrans:   in    Std_Logic_Vector(1 downto 0);
      n_ahbsi_hsize:    in    Std_Logic_Vector(2 downto 0);
      n_ahbsi_hburst:   in    Std_Logic_Vector(2 downto 0);
      n_ahbsi_hwdata:   in    Std_Logic_Vector(31 downto 0);
      n_ahbsi_hprot:    in    Std_Logic_Vector(3 downto 0);
      n_ahbsi_hready:   in    Std_Logic;
      n_ahbsi_hmaster:  in    Std_Logic_Vector(3 downto 0);
      n_ahbsi_hmastlock:in    Std_Logic;
      n_ahbsi_hmbsel:   in    Std_Logic_Vector(0 to 3);
      n_ahbsi_hirq:     in    Std_Logic_Vector(31 downto 0);

      n_ahbso_hready:   out   Std_Logic;
      n_ahbso_hresp:    out   Std_Logic_Vector(1 downto 0);
      n_ahbso_hrdata:   out   Std_Logic_Vector(31 downto 0);
      n_ahbso_hsplit:   out   Std_Logic_Vector(15 downto 0);
      n_ahbso_hirq:     out   Std_Logic_Vector(31 downto 0);

      n_apbi_psel:      in    Std_Logic_Vector(0 to 15);
      n_apbi_penable:   in    Std_Logic;
      n_apbi_paddr:     in    Std_Logic_Vector(31 downto 0);
      n_apbi_pwrite:    in    Std_Logic;
      n_apbi_pwdata:    in    Std_Logic_Vector(31 downto 0);
      n_apbi_pirq:      in    Std_Logic_Vector(31 downto 0);

      n_apbo_prdata:    out   Std_Logic_Vector(31 downto 0);
      n_apbo_pirq:      out   Std_Logic_Vector(31 downto 0);

      n_sri_data:       in    Std_Logic_Vector(31 downto 0);
      n_sri_brdyn:      in    Std_Logic;
      n_sri_bexcn:      in    Std_Logic;
      n_sri_writen:     in    Std_Logic;
      n_sri_wrn:        in    Std_Logic_Vector(3 downto 0);
      n_sri_bwidth:     in    Std_Logic_Vector(1 downto 0);
      n_sri_sd:         in    Std_Logic_Vector(63 downto 0);
      n_sri_cb:         in    Std_Logic_Vector(7 downto 0);
      n_sri_scb:        in    Std_Logic_Vector(7 downto 0);
      n_sri_edac:       in    Std_Logic;

      n_sro_address:    out   Std_Logic_Vector(31 downto 0);
      n_sro_data:       out   Std_Logic_Vector(31 downto 0);
      n_sro_sddata:     out   Std_Logic_Vector(63 downto 0);
      n_sro_ramsn:      out   Std_Logic_Vector(7 downto 0);
      n_sro_ramoen:     out   Std_Logic_Vector(7 downto 0);
      n_sro_ramn:       out   Std_Logic;
      n_sro_romn:       out   Std_Logic;
      n_sro_mben:       out   Std_Logic_Vector(3 downto 0);
      n_sro_iosn:       out   Std_Logic;
      n_sro_romsn:      out   Std_Logic_Vector(7 downto 0);
      n_sro_oen:        out   Std_Logic;
      n_sro_writen:     out   Std_Logic;
      n_sro_wrn:        out   Std_Logic_Vector(3 downto 0);
      n_sro_bdrive:     out   Std_Logic_Vector(3 downto 0);
      n_sro_vbdrive:    out   Std_Logic_Vector(31 downto 0);
      n_sro_svbdrive:   out   Std_Logic_Vector(63 downto 0);
      n_sro_read:       out   Std_Logic;
      n_sro_sa:         out   Std_Logic_Vector(14 downto 0);
      n_sro_cb:         out   Std_Logic_Vector(7 downto 0);
      n_sro_scb:        out   Std_Logic_Vector(7 downto 0);
      n_sro_vcdrive:    out   Std_Logic_Vector(7 downto 0);
      n_sro_svcdrive:   out   Std_Logic_Vector(7 downto 0);
      n_sro_ce:         out   Std_Logic);
end component;

  component ftsrctrl_net
  generic (
    hindex       : integer := 0;
    romaddr      : integer := 0;
    rommask      : integer := 16#ff0#;
    ramaddr      : integer := 16#400#;
    rammask      : integer := 16#ff0#;
    ioaddr       : integer := 16#200#;
    iomask       : integer := 16#ff0#;
    ramws        : integer := 0;
    romws        : integer := 2;
    iows         : integer := 2;
    rmw          : integer := 0;
    srbanks      : integer range 1 to 8  := 1;
    banksz       : integer range 0 to 15 := 15;
    rombanks     : integer range 1 to 8  := 1;
    rombanksz    : integer range 0 to 15 := 15;
    rombankszdef : integer range 0 to 15 := 15;
    pindex       : integer := 0;
    paddr        : integer := 0;
    pmask        : integer := 16#fff#;
    edacen       : integer range 0 to 1 := 1;
    errcnt       : integer range 0 to 1 := 0;
    cntbits      : integer range 1 to 8 := 1;
    wsreg        : integer := 0;
    oepol        : integer := 0;
    prom8en      : integer := 0;
    netlist      : integer := 0;
    tech         : integer := 0
  );
  port (
      rst:              in    Std_ULogic;
      clk:              in    Std_ULogic;
      ahbsi        : in  ahb_slv_in_type;
      ahbso        : out ahb_slv_out_type;
      apbi         : in  apb_slv_in_type;
      apbo         : out apb_slv_out_type;

      sri_data:         in    Std_Logic_Vector(31 downto 0);            -- Data bus address
      sri_brdyn:        in    Std_Logic;
      sri_bexcn:        in    Std_Logic;
      sri_writen:       in    Std_Logic;
      sri_wrn:          in    Std_Logic_Vector(3 downto 0);
      sri_bwidth:       in    Std_Logic_Vector(1 downto 0);
      sri_sd:           in    Std_Logic_Vector(63 downto 0);
      sri_cb:           in    Std_Logic_Vector(15 downto 0);
      sri_scb:          in    Std_Logic_Vector(15 downto 0);
      sri_edac:         in    Std_Logic;

      sro_address:      out   Std_Logic_Vector(31 downto 0);
      sro_data:         out   Std_Logic_Vector(31 downto 0);
      sro_sddata:       out   Std_Logic_Vector(63 downto 0);
      sro_ramsn:        out   Std_Logic_Vector(7 downto 0);
      sro_ramoen:       out   Std_Logic_Vector(7 downto 0);
      sro_ramn:         out   Std_ULogic;
      sro_romn:         out   Std_ULogic;
      sro_mben:         out   Std_Logic_Vector(3 downto 0);
      sro_iosn:         out   Std_Logic;
      sro_romsn:        out   Std_Logic_Vector(7 downto 0);
      sro_oen:          out   Std_Logic;
      sro_writen:       out   Std_Logic;
      sro_wrn:          out   Std_Logic_Vector(3 downto 0);
      sro_bdrive:       out   Std_Logic_Vector(3 downto 0);
      sro_vbdrive:      out   Std_Logic_Vector(31 downto 0);            --vector bus drive
      sro_svbdrive:     out   Std_Logic_Vector(63 downto 0);            --vector bus drive sdram
      sro_read:         out   Std_Logic;
      sro_sa:           out   Std_Logic_Vector(14 downto 0);
      sro_cb:           out   Std_Logic_Vector(15 downto 0);
      sro_scb:          out   Std_Logic_Vector(15 downto 0);
      sro_vcdrive:      out   Std_Logic_Vector(15 downto 0);             --vector bus drive cb
      sro_svcdrive:     out   Std_Logic_Vector(15 downto 0);             --vector bus drive cb sdram
      sro_ce:           out   Std_ULogic;

      sdo_sdcke:        out   Std_Logic_Vector( 1 downto 0);            -- clk en
      sdo_sdcsn:        out   Std_Logic_Vector( 1 downto 0);            -- chip sel
      sdo_sdwen:        out   Std_ULogic;                               -- write en
      sdo_rasn:         out   Std_ULogic;                               -- row addr stb
      sdo_casn:         out   Std_ULogic;                               -- col addr stb
      sdo_dqm:          out   Std_Logic_Vector(15 downto 0);            -- data i/o mask
      sdo_bdrive:       out   Std_ULogic;                               -- bus drive
      sdo_qdrive:       out   Std_ULogic;                               -- bus drive
      sdo_vbdrive:      out   Std_Logic_Vector(31 downto 0);            -- vector bus drive
      sdo_address:      out   Std_Logic_Vector(16 downto 2);            -- address out
      sdo_data:         out   Std_Logic_Vector(127 downto 0);           -- data out
      sdo_cb:           out   Std_Logic_Vector(15 downto 0);
      sdo_ce:           out   Std_ULogic;
      sdo_ba:           out   Std_Logic_Vector(2 downto 0));            -- bank address
  end component;

  component grlfpw4_net
  generic (tech     : integer := 0;
           pclow    : integer range 0 to 2 := 2;
           dsu      : integer range 0 to 1 := 1;
           disas    : integer range 0 to 2 := 0;
           pipe     : integer range 0 to 2 := 0;
           wrt      : integer range 0 to 2 := 0
           );
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi_flush  	: in std_ulogic;			  -- pipeline flush
    cpi_exack    	: in std_ulogic;			  -- FP exception acknowledge
    cpi_a_rs1  	: in std_logic_vector(4 downto 0);
    cpi_d_pc    : in std_logic_vector(31 downto 0);
    cpi_d_inst  : in std_logic_vector(31 downto 0);
    cpi_d_cnt   : in std_logic_vector(1 downto 0);
    cpi_d_trap  : in std_ulogic;
    cpi_d_annul : in std_ulogic;
    cpi_d_pv    : in std_ulogic;
    cpi_a_pc    : in std_logic_vector(31 downto 0);
    cpi_a_inst  : in std_logic_vector(31 downto 0);
    cpi_a_cnt   : in std_logic_vector(1 downto 0);
    cpi_a_trap  : in std_ulogic;
    cpi_a_annul : in std_ulogic;
    cpi_a_pv    : in std_ulogic;
    cpi_e_pc    : in std_logic_vector(31 downto 0);
    cpi_e_inst  : in std_logic_vector(31 downto 0);
    cpi_e_cnt   : in std_logic_vector(1 downto 0);
    cpi_e_trap  : in std_ulogic;
    cpi_e_annul : in std_ulogic;
    cpi_e_pv    : in std_ulogic;
    cpi_m_pc    : in std_logic_vector(31 downto 0);
    cpi_m_inst  : in std_logic_vector(31 downto 0);
    cpi_m_cnt   : in std_logic_vector(1 downto 0);
    cpi_m_trap  : in std_ulogic;
    cpi_m_annul : in std_ulogic;
    cpi_m_pv    : in std_ulogic;
    cpi_x_pc    : in std_logic_vector(31 downto 0);
    cpi_x_inst  : in std_logic_vector(31 downto 0);
    cpi_x_cnt   : in std_logic_vector(1 downto 0);
    cpi_x_trap  : in std_ulogic;
    cpi_x_annul : in std_ulogic;
    cpi_x_pv    : in std_ulogic;
    cpi_lddata        : in std_logic_vector(63 downto 0);     -- load data
    cpi_dbg_enable : in std_ulogic;
    cpi_dbg_write  : in std_ulogic;
    cpi_dbg_fsr    : in std_ulogic;                            -- FSR access
    cpi_dbg_addr   : in std_logic_vector(4 downto 0);
    cpi_dbg_data   : in std_logic_vector(31 downto 0);
    cpo_data          : out std_logic_vector(63 downto 0); -- store data
    cpo_exc  	        : out std_logic;			 -- FP exception
    cpo_cc           : out std_logic_vector(1 downto 0);  -- FP condition codes
    cpo_ccv  	       : out std_ulogic;			 -- FP condition codes valid
    cpo_ldlock       : out std_logic;			 -- FP pipeline hold
    cpo_holdn         : out std_ulogic;
    cpo_dbg_data     : out std_logic_vector(31 downto 0);

    rfi1_rd1addr 	: out std_logic_vector(3 downto 0);
    rfi1_rd2addr 	: out std_logic_vector(3 downto 0);
    rfi1_wraddr 	: out std_logic_vector(3 downto 0);
    rfi1_wrdata 	: out std_logic_vector(31 downto 0);
    rfi1_ren1        : out std_ulogic;
    rfi1_ren2        : out std_ulogic;
    rfi1_wren        : out std_ulogic;

    rfi2_rd1addr 	: out std_logic_vector(3 downto 0);
    rfi2_rd2addr 	: out std_logic_vector(3 downto 0);
    rfi2_wraddr 	: out std_logic_vector(3 downto 0);
    rfi2_wrdata 	: out std_logic_vector(31 downto 0);
    rfi2_ren1        : out std_ulogic;
    rfi2_ren2        : out std_ulogic;
    rfi2_wren        : out std_ulogic;

    rfo1_data1    	: in std_logic_vector(31 downto 0);
    rfo1_data2    	: in std_logic_vector(31 downto 0);
    rfo2_data1    	: in std_logic_vector(31 downto 0);
    rfo2_data2    	: in std_logic_vector(31 downto 0)
    );
  end component;

  component grfpw4_net
  generic (tech     : integer := 0;
           pclow    : integer range 0 to 2 := 2;
           dsu      : integer range 0 to 2 := 1;
           disas    : integer range 0 to 2 := 0;
           pipe     : integer range 0 to 2 := 0
           );
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    fpuclk : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi_flush  	: in std_ulogic;			  -- pipeline flush
    cpi_exack    	: in std_ulogic;			  -- FP exception acknowledge
    cpi_a_rs1  	: in std_logic_vector(4 downto 0);
    cpi_d_pc    : in std_logic_vector(31 downto 0);
    cpi_d_inst  : in std_logic_vector(31 downto 0);
    cpi_d_cnt   : in std_logic_vector(1 downto 0);
    cpi_d_trap  : in std_ulogic;
    cpi_d_annul : in std_ulogic;
    cpi_d_pv    : in std_ulogic;
    cpi_a_pc    : in std_logic_vector(31 downto 0);
    cpi_a_inst  : in std_logic_vector(31 downto 0);
    cpi_a_cnt   : in std_logic_vector(1 downto 0);
    cpi_a_trap  : in std_ulogic;
    cpi_a_annul : in std_ulogic;
    cpi_a_pv    : in std_ulogic;
    cpi_e_pc    : in std_logic_vector(31 downto 0);
    cpi_e_inst  : in std_logic_vector(31 downto 0);
    cpi_e_cnt   : in std_logic_vector(1 downto 0);
    cpi_e_trap  : in std_ulogic;
    cpi_e_annul : in std_ulogic;
    cpi_e_pv    : in std_ulogic;
    cpi_m_pc    : in std_logic_vector(31 downto 0);
    cpi_m_inst  : in std_logic_vector(31 downto 0);
    cpi_m_cnt   : in std_logic_vector(1 downto 0);
    cpi_m_trap  : in std_ulogic;
    cpi_m_annul : in std_ulogic;
    cpi_m_pv    : in std_ulogic;
    cpi_x_pc    : in std_logic_vector(31 downto 0);
    cpi_x_inst  : in std_logic_vector(31 downto 0);
    cpi_x_cnt   : in std_logic_vector(1 downto 0);
    cpi_x_trap  : in std_ulogic;
    cpi_x_annul : in std_ulogic;
    cpi_x_pv    : in std_ulogic;
    cpi_lddata        : in std_logic_vector(63 downto 0);     -- load data
    cpi_dbg_enable : in std_ulogic;
    cpi_dbg_write  : in std_ulogic;
    cpi_dbg_fsr    : in std_ulogic;                            -- FSR access
    cpi_dbg_addr   : in std_logic_vector(4 downto 0);
    cpi_dbg_data   : in std_logic_vector(31 downto 0);
    cpo_data          : out std_logic_vector(63 downto 0); -- store data
    cpo_exc  	        : out std_logic;			 -- FP exception
    cpo_cc           : out std_logic_vector(1 downto 0);  -- FP condition codes
    cpo_ccv  	       : out std_ulogic;			 -- FP condition codes valid
    cpo_ldlock       : out std_logic;			 -- FP pipeline hold
    cpo_holdn         : out std_ulogic;
    cpo_dbg_data     : out std_logic_vector(31 downto 0);

    rfi1_rd1addr 	: out std_logic_vector(3 downto 0);
    rfi1_rd2addr 	: out std_logic_vector(3 downto 0);
    rfi1_wraddr 	: out std_logic_vector(3 downto 0);
    rfi1_wrdata 	: out std_logic_vector(31 downto 0);
    rfi1_ren1        : out std_ulogic;
    rfi1_ren2        : out std_ulogic;
    rfi1_wren        : out std_ulogic;

    rfi2_rd1addr 	: out std_logic_vector(3 downto 0);
    rfi2_rd2addr 	: out std_logic_vector(3 downto 0);
    rfi2_wraddr 	: out std_logic_vector(3 downto 0);
    rfi2_wrdata 	: out std_logic_vector(31 downto 0);
    rfi2_ren1        : out std_ulogic;
    rfi2_ren2        : out std_ulogic;
    rfi2_wren        : out std_ulogic;

    rfo1_data1    	: in std_logic_vector(31 downto 0);
    rfo1_data2    	: in std_logic_vector(31 downto 0);
    rfo2_data1    	: in std_logic_vector(31 downto 0);
    rfo2_data2    	: in std_logic_vector(31 downto 0)
    );
  end component;

  component spictrl_net
    generic (
      tech      : integer range 0 to NTECH := 0;
      fdepth    : integer range 1 to 7  := 1;
      slvselen  : integer range 0 to 1  := 0;
      slvselsz  : integer range 1 to 32 := 1;
      oepol     : integer range 0 to 1  := 0;
      odmode    : integer range 0 to 1  := 0;
      automode  : integer range 0 to 1  := 0;
      acntbits  : integer range 1 to 32 := 32;
      aslvsel   : integer range 0 to 1  := 0;
      twen      : integer range 0 to 1  := 1;
      maxwlen   : integer range 0 to 15 := 0;
      automask0 : integer               := 0;
      automask1 : integer               := 0;
      automask2 : integer               := 0;
      automask3 : integer               := 0);
    port (
      rstn          : in std_ulogic;
      clk           : in std_ulogic;
      apbi_psel     : in  std_ulogic;
      apbi_penable  : in  std_ulogic;
      apbi_paddr    : in  std_logic_vector(31 downto 0);
      apbi_pwrite   : in  std_ulogic;
      apbi_pwdata   : in  std_logic_vector(31 downto 0);
      apbi_testen   : in  std_ulogic;
      apbi_testrst  : in  std_ulogic;
      apbi_scanen   : in  std_ulogic;
      apbi_testoen  : in  std_ulogic;
      apbo_prdata   : out std_logic_vector(31 downto 0);
      apbo_pirq     : out std_ulogic;
      spii_miso     : in  std_ulogic;
      spii_mosi     : in  std_ulogic;
      spii_sck      : in  std_ulogic;
      spii_spisel   : in  std_ulogic;
      spii_astart   : in  std_ulogic;
      spii_cstart   : in  std_ulogic;
      spio_miso     : out std_ulogic;
      spio_misooen  : out std_ulogic;
      spio_mosi     : out std_ulogic;
      spio_mosioen  : out std_ulogic;
      spio_sck      : out std_ulogic;
      spio_sckoen   : out std_ulogic;
      spio_enable   : out std_ulogic;
      spio_astart   : out std_ulogic;
      spio_aready   : out std_ulogic;
      slvsel        : out std_logic_vector((slvselsz-1) downto 0));
  end component;

  component leon4_net
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63  := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2  := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 31 := 0;    -- support SMP systems
    iuft      : integer range 0 to 4  := 0;
    fpft      : integer range 0 to 4  := 0;
    cmft      : integer range 0 to 1  := 0;
    cached    : integer               := 0;
    scantest  : integer               := 0
  );

   port (
      clk     : in  std_ulogic;
      gclk    : in  std_ulogic;
      hclken  : in  std_ulogic;
      rstn    : in  std_ulogic;
      ahbix   : in  ahb_mst_in_type;
      ahbox   : out ahb_mst_out_type;
      ahbsix  : in  ahb_slv_in_type;
      ahbso   : in  ahb_slv_out_vector;
      irqi_irl          : in  std_logic_vector(3 downto 0);
      irqi_resume       : in  std_ulogic;
      irqi_rstrun       : in  std_ulogic;
      irqi_rstvec       : in  std_logic_vector(31 downto 12);
      irqi_index        : in  std_logic_vector(3 downto 0);
      irqi_pwdsetaddr   : in  std_ulogic;
      irqi_pwdnewaddr   : in  std_logic_vector(31 downto 2);
      irqi_forceerr     : in  std_ulogic;

      irqo_intack       : out std_ulogic;
      irqo_irl          : out std_logic_vector(3 downto 0);
      irqo_pwd          : out std_ulogic;
      irqo_fpen         : out std_ulogic;
      irqo_err          : out std_ulogic;

      dbgi_dsuen:       in    std_ulogic;                               -- DSU enable
      dbgi_denable:     in    std_ulogic;                               -- diagnostic register access enable
      dbgi_dbreak:      in    std_ulogic;                               -- debug break-in
      dbgi_step:        in    std_ulogic;                               -- single step
      dbgi_halt:        in    std_ulogic;                               -- halt processor
      dbgi_reset:       in    std_ulogic;                               -- reset processor
      dbgi_dwrite:      in    std_ulogic;                               -- read/write
      dbgi_daddr:       in    std_logic_vector(23 downto 2);            -- diagnostic address
      dbgi_ddata:       in    std_logic_vector(31 downto 0);            -- diagnostic data
      dbgi_btrapa:      in    std_ulogic;                               -- break on IU trap
      dbgi_btrape:      in    std_ulogic;                               -- break on IU trap
      dbgi_berror:      in    std_ulogic;                               -- break on IU error mode
      dbgi_bwatch:      in    std_ulogic;                               -- break on IU watchpoint
      dbgi_bsoft:       in    std_ulogic;                               -- break on software breakpoint (TA 1)
      dbgi_tenable:     in    std_ulogic;
      dbgi_timer:       in    std_logic_vector(63 downto 0);

      dbgo_data:        out   std_logic_vector(31 downto 0);
      dbgo_crdy:        out   std_ulogic;
      dbgo_dsu:         out   std_ulogic;
      dbgo_dsumode:     out   std_ulogic;
      dbgo_error:       out   std_ulogic;
      dbgo_halt:        out   std_ulogic;
      dbgo_pwd:         out   std_ulogic;
      dbgo_idle:        out   std_ulogic;
      dbgo_ipend:       out   std_ulogic;
      dbgo_icnt:        out   std_ulogic;
      dbgo_fcnt    : 	out   std_ulogic;
      dbgo_optype  : 	out   std_logic_vector(5 downto 0);	-- instruction type
      dbgo_bpmiss  : 	out   std_ulogic;			-- branch predict miss
      dbgo_istat_cmiss:  out   std_ulogic;
      dbgo_istat_tmiss:  out   std_ulogic;
      dbgo_istat_chold:  out   std_ulogic;
      dbgo_istat_mhold:  out   std_ulogic;
      dbgo_dstat_cmiss:  out   std_ulogic;
      dbgo_dstat_tmiss:  out   std_ulogic;
      dbgo_dstat_chold:  out   std_ulogic;
      dbgo_dstat_mhold:  out   std_ulogic;
      dbgo_wbhold  : 	out   std_ulogic;			-- write buffer hold
      dbgo_su      : 	out   std_ulogic;
      dbgo_ducnt   :    out   std_ulogic);
  end component;

  component grpci2_phy_net is
    generic(
      tech    : integer := DEFMEMTECH;
      oepol   : integer := 0;
      bypass  : integer range 0 to 1 := 1;
      netlist : integer := 0
    );
    port(
      pciclk  : in  std_logic;

      pcii_rst                  : in  std_ulogic;
      pcii_gnt                  : in  std_ulogic;
      pcii_idsel                : in  std_ulogic;
      pcii_ad                   : in  std_logic_vector(31 downto 0);
      pcii_cbe                  : in  std_logic_vector(3 downto 0);
      pcii_frame                : in  std_ulogic;
      pcii_irdy                 : in  std_ulogic;
      pcii_trdy                 : in  std_ulogic;
      pcii_devsel               : in  std_ulogic;
      pcii_stop                 : in  std_ulogic;
      pcii_lock                 : in  std_ulogic;
      pcii_perr                 : in  std_ulogic;
      pcii_serr                 : in  std_ulogic;
      pcii_par                  : in  std_ulogic;
      pcii_host                 : in  std_ulogic;
      pcii_pci66                : in  std_ulogic;
      pcii_pme_status           : in  std_ulogic;
      pcii_int                  : in  std_logic_vector(3 downto 0);

      phyi_pcirstout            : in  std_logic;
      phyi_pciasyncrst          : in  std_logic;
      phyi_pcisoftrst           : in  std_logic_vector(2 downto 0);
      phyi_pciinten             : in  std_logic_vector(3 downto 0);
      phyi_m_request            : in  std_logic;
      phyi_m_mabort             : in  std_logic;
      phyi_pr_m_fstate          : in  std_logic_vector(1 downto 0);

      phyi_pr_m_cfifo_0_data    : in  std_logic_vector(31 downto 0);
      phyi_pr_m_cfifo_0_last    : in  std_logic;
      phyi_pr_m_cfifo_0_stlast  : in  std_logic;
      phyi_pr_m_cfifo_0_hold    : in  std_logic;
      phyi_pr_m_cfifo_0_valid   : in  std_logic;
      phyi_pr_m_cfifo_0_err     : in  std_logic;
      phyi_pr_m_cfifo_1_data    : in  std_logic_vector(31 downto 0);
      phyi_pr_m_cfifo_1_last    : in  std_logic;
      phyi_pr_m_cfifo_1_stlast  : in  std_logic;
      phyi_pr_m_cfifo_1_hold    : in  std_logic;
      phyi_pr_m_cfifo_1_valid   : in  std_logic;
      phyi_pr_m_cfifo_1_err     : in  std_logic;
      phyi_pr_m_cfifo_2_data    : in  std_logic_vector(31 downto 0);
      phyi_pr_m_cfifo_2_last    : in  std_logic;
      phyi_pr_m_cfifo_2_stlast  : in  std_logic;
      phyi_pr_m_cfifo_2_hold    : in  std_logic;
      phyi_pr_m_cfifo_2_valid   : in  std_logic;
      phyi_pr_m_cfifo_2_err     : in  std_logic;

      phyi_pv_m_cfifo_0_data    : in  std_logic_vector(31 downto 0);
      phyi_pv_m_cfifo_0_last    : in  std_logic;
      phyi_pv_m_cfifo_0_stlast  : in  std_logic;
      phyi_pv_m_cfifo_0_hold    : in  std_logic;
      phyi_pv_m_cfifo_0_valid   : in  std_logic;
      phyi_pv_m_cfifo_0_err     : in  std_logic;
      phyi_pv_m_cfifo_1_data    : in  std_logic_vector(31 downto 0);
      phyi_pv_m_cfifo_1_last    : in  std_logic;
      phyi_pv_m_cfifo_1_stlast  : in  std_logic;
      phyi_pv_m_cfifo_1_hold    : in  std_logic;
      phyi_pv_m_cfifo_1_valid   : in  std_logic;
      phyi_pv_m_cfifo_1_err     : in  std_logic;
      phyi_pv_m_cfifo_2_data    : in  std_logic_vector(31 downto 0);
      phyi_pv_m_cfifo_2_last    : in  std_logic;
      phyi_pv_m_cfifo_2_stlast  : in  std_logic;
      phyi_pv_m_cfifo_2_hold    : in  std_logic;
      phyi_pv_m_cfifo_2_valid   : in  std_logic;
      phyi_pv_m_cfifo_2_err     : in  std_logic;

      phyi_pr_m_addr            : in  std_logic_vector(31 downto 0);
      phyi_pr_m_cbe_data        : in  std_logic_vector(3 downto 0);
      phyi_pr_m_cbe_cmd         : in  std_logic_vector(3 downto 0);
      phyi_pr_m_first           : in  std_logic_vector(1 downto 0);
      phyi_pv_m_term            : in  std_logic_vector(1 downto 0);
      phyi_pr_m_ltimer          : in  std_logic_vector(7 downto 0);
      phyi_pr_m_burst           : in  std_logic;
      phyi_pr_m_abort           : in  std_logic_vector(0 downto 0);
      phyi_pr_m_perren          : in  std_logic_vector(0 downto 0);
      phyi_pr_m_done_fifo       : in  std_logic;

      phyi_t_abort              : in  std_logic;
      phyi_t_ready              : in  std_logic;
      phyi_t_retry              : in  std_logic;
      phyi_pr_t_state           : in  std_logic_vector(2 downto 0);
      phyi_pv_t_state           : in  std_logic_vector(2 downto 0);
      phyi_pr_t_fstate          : in  std_logic_vector(1 downto 0);

      phyi_pr_t_cfifo_0_data    : in  std_logic_vector(31 downto 0);
      phyi_pr_t_cfifo_0_last    : in  std_logic;
      phyi_pr_t_cfifo_0_stlast  : in  std_logic;
      phyi_pr_t_cfifo_0_hold    : in  std_logic;
      phyi_pr_t_cfifo_0_valid   : in  std_logic;
      phyi_pr_t_cfifo_0_err     : in  std_logic;
      phyi_pr_t_cfifo_1_data    : in  std_logic_vector(31 downto 0);
      phyi_pr_t_cfifo_1_last    : in  std_logic;
      phyi_pr_t_cfifo_1_stlast  : in  std_logic;
      phyi_pr_t_cfifo_1_hold    : in  std_logic;
      phyi_pr_t_cfifo_1_valid   : in  std_logic;
      phyi_pr_t_cfifo_1_err     : in  std_logic;
      phyi_pr_t_cfifo_2_data    : in  std_logic_vector(31 downto 0);
      phyi_pr_t_cfifo_2_last    : in  std_logic;
      phyi_pr_t_cfifo_2_stlast  : in  std_logic;
      phyi_pr_t_cfifo_2_hold    : in  std_logic;
      phyi_pr_t_cfifo_2_valid   : in  std_logic;
      phyi_pr_t_cfifo_2_err     : in  std_logic;
      phyi_pv_t_diswithout      : in  std_logic;
      phyi_pr_t_stoped          : in  std_logic;
      phyi_pr_t_lcount          : in  std_logic_vector(2 downto 0);
      phyi_pr_t_first_word      : in  std_logic;
      phyi_pr_t_cur_acc_0_read  : in  std_logic;
      phyi_pv_t_hold_write      : in  std_logic;
      phyi_pv_t_hold_reset      : in  std_logic;
      phyi_pr_conf_comm_perren  : in  std_logic;
      phyi_pr_conf_comm_serren  : in  std_logic;

      pcio_aden                 : out std_ulogic;
      pcio_vaden                : out std_logic_vector(31 downto 0);
      pcio_cbeen                : out std_logic_vector(3 downto 0);
      pcio_frameen              : out std_ulogic;
      pcio_irdyen               : out std_ulogic;
      pcio_trdyen               : out std_ulogic;
      pcio_devselen             : out std_ulogic;
      pcio_stopen               : out std_ulogic;
      pcio_ctrlen               : out std_ulogic;
      pcio_perren               : out std_ulogic;
      pcio_paren                : out std_ulogic;
      pcio_reqen                : out std_ulogic;
      pcio_locken               : out std_ulogic;
      pcio_serren               : out std_ulogic;
      pcio_inten                : out std_ulogic;
      pcio_vinten               : out std_logic_vector(3 downto 0);
      pcio_req                  : out std_ulogic;
      pcio_ad                   : out std_logic_vector(31 downto 0);
      pcio_cbe                  : out std_logic_vector(3 downto 0);
      pcio_frame                : out std_ulogic;
      pcio_irdy                 : out std_ulogic;
      pcio_trdy                 : out std_ulogic;
      pcio_devsel               : out std_ulogic;
      pcio_stop                 : out std_ulogic;
      pcio_perr                 : out std_ulogic;
      pcio_serr                 : out std_ulogic;
      pcio_par                  : out std_ulogic;
      pcio_lock                 : out std_ulogic;
      pcio_power_state          : out std_logic_vector(1 downto 0);
      pcio_pme_enable           : out std_ulogic;
      pcio_pme_clear            : out std_ulogic;
      pcio_int                  : out std_ulogic;
      pcio_rst                  : out std_ulogic;

      phyo_pciv_rst             : out std_ulogic;
      phyo_pciv_gnt             : out std_ulogic;
      phyo_pciv_idsel           : out std_ulogic;
      phyo_pciv_ad              : out std_logic_vector(31 downto 0);
      phyo_pciv_cbe             : out std_logic_vector(3 downto 0);
      phyo_pciv_frame           : out std_ulogic;
      phyo_pciv_irdy            : out std_ulogic;
      phyo_pciv_trdy            : out std_ulogic;
      phyo_pciv_devsel          : out std_ulogic;
      phyo_pciv_stop            : out std_ulogic;
      phyo_pciv_lock            : out std_ulogic;
      phyo_pciv_perr            : out std_ulogic;
      phyo_pciv_serr            : out std_ulogic;
      phyo_pciv_par             : out std_ulogic;
      phyo_pciv_host            : out std_ulogic;
      phyo_pciv_pci66           : out std_ulogic;
      phyo_pciv_pme_status      : out std_ulogic;
      phyo_pciv_int             : out std_logic_vector(3 downto 0);

      phyo_pr_m_state           : out std_logic_vector(2 downto 0);
      phyo_pr_m_last            : out std_logic_vector(1 downto 0);
      phyo_pr_m_hold            : out std_logic_vector(1 downto 0);
      phyo_pr_m_term            : out std_logic_vector(1 downto 0);
      phyo_pr_t_hold            : out std_logic_vector(0 downto 0);
      phyo_pr_t_stop            : out std_logic;
      phyo_pr_t_abort           : out std_logic;
      phyo_pr_t_diswithout      : out std_logic;
      phyo_pr_t_addr_perr       : out std_logic;
      phyo_pcirsto              : out std_logic_vector(0 downto 0);

      phyo_pr_po_ad             : out std_logic_vector(31 downto 0);
      phyo_pr_po_aden           : out std_logic_vector(31 downto 0);
      phyo_pr_po_cbe            : out std_logic_vector(3 downto 0);
      phyo_pr_po_cbeen          : out std_logic_vector(3 downto 0);
      phyo_pr_po_frame          : out std_logic;
      phyo_pr_po_frameen        : out std_logic;
      phyo_pr_po_irdy           : out std_logic;
      phyo_pr_po_irdyen         : out std_logic;
      phyo_pr_po_trdy           : out std_logic;
      phyo_pr_po_trdyen         : out std_logic;
      phyo_pr_po_stop           : out std_logic;
      phyo_pr_po_stopen         : out std_logic;
      phyo_pr_po_devsel         : out std_logic;
      phyo_pr_po_devselen       : out std_logic;
      phyo_pr_po_par            : out std_logic;
      phyo_pr_po_paren          : out std_logic;
      phyo_pr_po_perr           : out std_logic;
      phyo_pr_po_perren         : out std_logic;
      phyo_pr_po_lock           : out std_logic;
      phyo_pr_po_locken         : out std_logic;
      phyo_pr_po_req            : out std_logic;
      phyo_pr_po_reqen          : out std_logic;
      phyo_pr_po_serren         : out std_logic;
      phyo_pr_po_inten          : out std_logic;
      phyo_pr_po_vinten         : out std_logic_vector(3 downto 0);

      phyo_pio_rst              : out std_ulogic;
      phyo_pio_gnt              : out std_ulogic;
      phyo_pio_idsel            : out std_ulogic;
      phyo_pio_ad               : out std_logic_vector(31 downto 0);
      phyo_pio_cbe              : out std_logic_vector(3 downto 0);
      phyo_pio_frame            : out std_ulogic;
      phyo_pio_irdy             : out std_ulogic;
      phyo_pio_trdy             : out std_ulogic;
      phyo_pio_devsel           : out std_ulogic;
      phyo_pio_stop             : out std_ulogic;
      phyo_pio_lock             : out std_ulogic;
      phyo_pio_perr             : out std_ulogic;
      phyo_pio_serr             : out std_ulogic;
      phyo_pio_par              : out std_ulogic;
      phyo_pio_host             : out std_ulogic;
      phyo_pio_pci66            : out std_ulogic;
      phyo_pio_pme_status       : out std_ulogic;
      phyo_pio_int              : out std_logic_vector(3 downto 0);

      phyo_poo_ad               : out std_logic_vector(31 downto 0);
      phyo_poo_aden             : out std_logic_vector(31 downto 0);
      phyo_poo_cbe              : out std_logic_vector(3 downto 0);
      phyo_poo_cbeen            : out std_logic_vector(3 downto 0);
      phyo_poo_frame            : out std_logic;
      phyo_poo_frameen          : out std_logic;
      phyo_poo_irdy             : out std_logic;
      phyo_poo_irdyen           : out std_logic;
      phyo_poo_trdy             : out std_logic;
      phyo_poo_trdyen           : out std_logic;
      phyo_poo_stop             : out std_logic;
      phyo_poo_stopen           : out std_logic;
      phyo_poo_devsel           : out std_logic;
      phyo_poo_devselen         : out std_logic;
      phyo_poo_par              : out std_logic;
      phyo_poo_paren            : out std_logic;
      phyo_poo_perr             : out std_logic;
      phyo_poo_perren           : out std_logic;
      phyo_poo_lock             : out std_logic;
      phyo_poo_locken           : out std_logic;
      phyo_poo_req              : out std_logic;
      phyo_poo_reqen            : out std_logic;
      phyo_poo_serren           : out std_logic;
      phyo_poo_inten            : out std_logic;
      phyo_poo_vinten           : out std_logic_vector(3 downto 0)
    );
  end component;

  component gr1553b_net
  generic (
    tech : integer range 0 to NTECH  := DEFFABTECH;
    bc_enable: integer range 0 to 1 := 1;
    rt_enable: integer range 0 to 1 := 1;
    bm_enable: integer range 0 to 1 := 1;
    bc_timer: integer range 0 to 2 := 1;
    bc_rtbusmask: integer range 0 to 1 := 1;
    extra_regkeys: integer range 0 to 1 := 0;
    syncrst: integer range 0 to 2 := 1;
    ahbendian: integer := 0;
    bm_filters: integer range 0 to 1 := 1;
    codecfreq: integer := 20;
    sameclk: integer range 0 to 1 := 0;
    codecver: integer range 0 to 2 := 0
    );
  port (
    clk: in std_logic;
    rst: in std_logic;
    codec_clk: in std_logic;
    codec_rst: in std_logic;

    -- AHB interface
    
    mi_hgrant	: in std_logic;                         -- bus grant
    mi_hready	: in std_ulogic;                        -- transfer done
    mi_hresp	: in std_logic_vector(1 downto 0); 	-- response type
    mi_hrdata	: in std_logic_vector(31 downto 0); 	-- read data bus
    
    mo_hbusreq	: out std_ulogic;                       -- bus request
    mo_htrans	: out std_logic_vector(1 downto 0); 	-- transfer type
    mo_haddr	: out std_logic_vector(31 downto 0); 	-- address bus (byte)
    mo_hwrite	: out std_ulogic;                       -- read/write
    mo_hsize	: out std_logic_vector(2 downto 0); 	-- transfer size
    mo_hburst	: out std_logic_vector(2 downto 0); 	-- burst type
    mo_hwdata	: out std_logic_vector(31 downto 0); 	-- write data bus

    -- APB interface
    
    si_psel	: in std_logic;     -- slave select
    si_penable	: in std_ulogic;                        -- strobe
    si_paddr	: in std_logic_vector(7 downto 0); 	-- address bus (byte addr)
    si_pwrite	: in std_ulogic;                        -- write
    si_pwdata	: in std_logic_vector(31 downto 0); 	-- write data bus
    so_prdata	: out std_logic_vector(31 downto 0); 	-- read data bus
    so_pirq 	: out std_logic;                        -- interrupt bus    

    -- Aux signals
    bcsync     : in std_logic;
    rtsync     : out std_logic;
    busreset   : out std_logic;

    rtaddr     : in std_logic_vector(4 downto 0);
    rtaddrp    : in std_logic;

    -- 1553 transceiver interface
    busainen   : out std_logic;
    busainp    : in  std_logic;
    busainn    : in  std_logic;
    busaouten  : out std_logic;  
    busaoutp   : out std_logic;
    busaoutn   : out std_logic;
    busbinen   : out std_logic;
    busbinp    : in  std_logic;
    busbinn    : in  std_logic;
    busbouten  : out std_logic;
    busboutp   : out std_logic;
    busboutn   : out std_logic
    );
  end component;
  
end;

