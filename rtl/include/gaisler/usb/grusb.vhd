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
-- Package:     grusb
-- File:        grusb.vhd
-- Author:      Marko Isomaki, Jonas Ekergarn
-- Description: Package for GRUSBHC, GRUSBDC, and GRUSB_DCL
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.amba.all;
use work.gencomp.all;

package grusb is
  -----------------------------------------------------------------------------
  -- USB in/out types
  -----------------------------------------------------------------------------  
  type grusb_in_type is record
    datain         : std_logic_vector(15 downto 0);
    rxactive       : std_ulogic;
    rxvalid        : std_ulogic;
    rxvalidh       : std_ulogic;
    rxerror        : std_ulogic;
    txready        : std_ulogic;
    linestate      : std_logic_vector(1 downto 0);
    nxt            : std_ulogic;
    dir            : std_ulogic;
    vbusvalid      : std_ulogic;
    hostdisconnect : std_ulogic;
    functesten     : std_ulogic;
    urstdrive      : std_ulogic;
  end record;

  constant grusb_in_none : grusb_in_type :=
    ((others => '0'), '0', '0', '0', '0', '0', (others => '0'),
     '0', '0', '0', '0', '0', '0');
  
  type grusb_out_type is record
    dataout           : std_logic_vector(15 downto 0);
    txvalid           : std_ulogic;
    txvalidh          : std_ulogic;
    opmode            : std_logic_vector(1 downto 0);
    xcvrselect        : std_logic_vector(1 downto 0);
    termselect        : std_ulogic;
    suspendm          : std_ulogic;
    reset             : std_ulogic;
    stp               : std_ulogic;
    oen               : std_ulogic;
    databus16_8       : std_ulogic;
    dppulldown        : std_ulogic;
    dmpulldown        : std_ulogic;
    idpullup          : std_ulogic;
    drvvbus           : std_ulogic;
    dischrgvbus       : std_ulogic;
    chrgvbus          : std_ulogic;
    txbitstuffenable  : std_ulogic;
    txbitstuffenableh : std_ulogic;
    fslsserialmode    : std_ulogic;
    tx_enable_n       : std_ulogic;
    tx_dat            : std_ulogic;
    tx_se0            : std_ulogic;
  end record;

  constant grusb_out_none : grusb_out_type :=
    ((others => '0'), '0', '0', (others => '0'), (others => '0'),
     '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
     '0', '0', '0', '0', '0', '0');
  
  type grusb_in_vector is array (natural range <>) of grusb_in_type;
  type grusb_out_vector is array (natural range <>) of grusb_out_type;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component grusbhc is
    generic (
      ehchindex   : integer range 0 to NAHBMST-1 := 0;
      ehcpindex   : integer range 0 to NAPBSLV-1 := 0;
      ehcpaddr    : integer range 0 to 16#FFF#   := 0;
      ehcpirq     : integer range 0 to NAHBIRQ-1 := 0;
      ehcpmask    : integer range 0 to 16#FFF#   := 16#FFF#;
      uhchindex   : integer range 0 to NAHBMST-1 := 0;
      uhchsindex  : integer range 0 to NAHBSLV-1 := 0;
      uhchaddr    : integer range 0 to 16#FFF#   := 0;
      uhchmask    : integer range 0 to 16#FFF#   := 16#FFF#;
      uhchirq     : integer range 0 to NAHBIRQ-1 := 0;
      tech        : integer range 0 to NTECH     := DEFFABTECH;
      memtech     : integer range 0 to NTECH     := DEFMEMTECH;
      nports      : integer range 1 to 15        := 1;
      ehcgen      : integer range 0 to 1         := 1;
      uhcgen      : integer range 0 to 1         := 1;
      n_cc        : integer range 1 to 15        := 1;
      n_pcc       : integer range 1 to 15        := 1;
      prr         : integer range 0 to 1         := 0;
      portroute1  : integer                      := 0;
      portroute2  : integer                      := 0;
      endian_conv : integer range 0 to 1         := 1;
      be_regs     : integer range 0 to 1         := 0;
      be_desc     : integer range 0 to 1         := 0;
      uhcblo      : integer range 0 to 255       := 2;
      bwrd        : integer range 1 to 256       := 16;
      utm_type    : integer range 0 to 2         := 2;
      vbusconf    : integer                      := 3;
      netlist     : integer range 0 to 1         := 0;
      ramtest     : integer range 0 to 1         := 0;
      urst_time   : integer                      := 0;
      oepol       : integer range 0 to 1         := 0;
      scantest    : integer range 0 to 1         := 0;
      memsel      : integer                      := 0;
      syncprst    : integer range 0 to 1         := 0;
      sysfreq     : integer                      := 65000;
      pcidev      : integer range 0 to 1         := 0;
      debug       : integer                      := 0;
      debugsize   : integer                      := 8192);
    port (
      clk       : in  std_ulogic;
      uclk      : in  std_ulogic;
      rst       : in  std_ulogic;
      apbi      : in  apb_slv_in_type;
      ehc_apbo  : out apb_slv_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbsi     : in  ahb_slv_in_type;
      ehc_ahbmo : out ahb_mst_out_type;
      uhc_ahbmo : out ahb_mst_out_vector_type(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbso : out ahb_slv_out_vector_type(n_cc*uhcgen downto 1*uhcgen);
      o         : out grusb_out_vector((nports-1) downto 0);
      i         : in  grusb_in_vector((nports-1) downto 0));               
  end component;

  component grusbdc is
    generic (
      hsindex    : integer range 0 to NAHBSLV-1 := 0;
      hirq       : integer range 0 to NAHBIRQ-1 := 0;
      haddr      : integer                      := 0;
      hmask      : integer                      := 16#FFF#;
      hmindex    : integer range 0 to NAHBMST-1 := 0;
      aiface     : integer range 0 to 1         := 0;
      memtech    : integer range 0 to NTECH     := DEFMEMTECH;
      uiface     : integer range 0 to 1         := 0;
      dwidth     : integer range 8 to 16        := 8;
      blen       : integer range 4 to 128       := 16;
      nepi       : integer range 1 to 16        := 1;
      nepo       : integer range 1 to 16        := 1;
      i0         : integer range 8 to 3072      := 1024;
      i1         : integer range 8 to 3072      := 1024;
      i2         : integer range 8 to 3072      := 1024;
      i3         : integer range 8 to 3072      := 1024;
      i4         : integer range 8 to 3072      := 1024;
      i5         : integer range 8 to 3072      := 1024;
      i6         : integer range 8 to 3072      := 1024;
      i7         : integer range 8 to 3072      := 1024;
      i8         : integer range 8 to 3072      := 1024;
      i9         : integer range 8 to 3072      := 1024;
      i10        : integer range 8 to 3072      := 1024;
      i11        : integer range 8 to 3072      := 1024;
      i12        : integer range 8 to 3072      := 1024;
      i13        : integer range 8 to 3072      := 1024;
      i14        : integer range 8 to 3072      := 1024;
      i15        : integer range 8 to 3072      := 1024;
      o0         : integer range 8 to 3072      := 1024;
      o1         : integer range 8 to 3072      := 1024;
      o2         : integer range 8 to 3072      := 1024;
      o3         : integer range 8 to 3072      := 1024;
      o4         : integer range 8 to 3072      := 1024;
      o5         : integer range 8 to 3072      := 1024;
      o6         : integer range 8 to 3072      := 1024;
      o7         : integer range 8 to 3072      := 1024;
      o8         : integer range 8 to 3072      := 1024;
      o9         : integer range 8 to 3072      := 1024;
      o10        : integer range 8 to 3072      := 1024;
      o11        : integer range 8 to 3072      := 1024;
      o12        : integer range 8 to 3072      := 1024;
      o13        : integer range 8 to 3072      := 1024;
      o14        : integer range 8 to 3072      := 1024;
      o15        : integer range 8 to 3072      := 1024;
      oepol      : integer range 0 to 1         := 0;
      syncprst   : integer range 0 to 1         := 0;
      prsttime   : integer range 0 to 512       := 0;
      sysfreq    : integer                      := 50000;
      keepclk    : integer range 0 to 1         := 0;
      sepirq     : integer range 0 to 1         := 0;
      irqi       : integer range 0 to NAHBIRQ-1 := 1;
      irqo       : integer range 0 to NAHBIRQ-1 := 2;
      functesten : integer range 0 to 1         := 0;
      scantest   : integer range 0 to 1         := 0;
      nsync      : integer range 1 to 2         := 1);
    port (
      uclk  : in  std_ulogic;
      usbi  : in  grusb_in_type;
      usbo  : out grusb_out_type;
      hclk  : in  std_ulogic;
      hrst  : in  std_ulogic;
      ahbmi : in  ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type
      );
  end component;

  component grusb_dcl is
    generic (
      hindex     : integer                := 0;
      memtech    : integer                := DEFMEMTECH;
      uiface     : integer range 0 to 1   := 0;
      dwidth     : integer range 8 to 16  := 8;
      oepol      : integer range 0 to 1   := 0;
      syncprst   : integer range 0 to 1   := 0;
      prsttime   : integer range 0 to 512 := 0;
      sysfreq    : integer                := 50000;
      keepclk    : integer range 0 to 1   := 0;
      functesten : integer range 0 to 1   := 0;
      burstlength: integer range 1 to 512 := 8;
      scantest   : integer range 0 to 1   := 0;
      nsync      : integer range 1 to 2   := 1
      );
    port (
      uclk : in  std_ulogic;
      usbi : in  grusb_in_type;
      usbo : out grusb_out_type;
      hclk : in  std_ulogic;
      hrst : in  std_ulogic;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type
      );
  end component grusb_dcl;

  component grusbhc_gen is
    generic (
      tech        : integer                      := 0;
      memtech     : integer                      := 0;
      nports      : integer range 1 to 15        := 1;
      ehcgen      : integer range 0 to 1         := 1;
      uhcgen      : integer range 0 to 1         := 1;
      n_cc        : integer range 1 to 15        := 1;
      n_pcc       : integer range 1 to 15        := 1;
      prr         : integer range 0 to 1         := 0;
      portroute1  : integer                      := 0;
      portroute2  : integer                      := 0;
      endian_conv : integer range 0 to 1         := 1;
      be_regs     : integer range 0 to 1         := 0;
      be_desc     : integer range 0 to 1         := 0;
      uhcblo      : integer range 0 to 255       := 2;
      bwrd        : integer range 1 to 256       := 16;
      utm_type    : integer range 0 to 2         := 2;
      vbusconf    : integer                      := 3;
      netlist     : integer range 0 to 1         := 0;
      ramtest     : integer range 0 to 1         := 0;
      urst_time   : integer                      := 0;
      oepol       : integer range 0 to 1         := 0;
      scantest    : integer range 0 to 1         := 0;
      memsel      : integer                      := 0;
      syncprst    : integer range 0 to 1         := 0;
      sysfreq     : integer                      := 65000;
      pcidev      : integer range 0 to 1         := 0;
      debug       : integer                      := 0;
      debugsize   : integer                      := 8192);
    port (
      clk               : in  std_ulogic;
      uclk              : in  std_ulogic;
      rst               : in  std_ulogic;
      -- EHC APB slave input signals
      ehc_apbsi_psel    : in  std_ulogic;
      ehc_apbsi_penable : in  std_ulogic;
      ehc_apbsi_paddr   : in  std_logic_vector(31 downto 0);
      ehc_apbsi_pwrite  : in  std_ulogic;
      ehc_apbsi_pwdata  : in  std_logic_vector(31 downto 0);
      -- EHC APB slave output signals    
      ehc_apbso_prdata  : out std_logic_vector(31 downto 0);
      ehc_irq           : out std_ulogic;
      -- EHC/UHC(s) AHB master input signals
      ahbmi_hgrant      : in  std_logic_vector(n_cc*uhcgen downto 0);
      ahbmi_hready      : in  std_ulogic;
      ahbmi_hresp       : in  std_logic_vector(1 downto 0);
      ahbmi_hrdata      : in  std_logic_vector(31 downto 0);
      -- UHC(s) AHB slave input signals
      uhc_ahbsi_hsel    : in  std_logic_vector((n_cc-1)*uhcgen downto 0);
      uhc_ahbsi_haddr   : in  std_logic_vector(31 downto 0);
      uhc_ahbsi_hwrite  : in  std_ulogic;
      uhc_ahbsi_htrans  : in  std_logic_vector(1 downto 0);
      uhc_ahbsi_hsize   : in  std_logic_vector(2 downto 0);
      uhc_ahbsi_hwdata  : in  std_logic_vector(31 downto 0);
      uhc_ahbsi_hready  : in  std_ulogic;
      -- EHC AHB master output signals
      ehc_ahbmo_hbusreq : out std_ulogic;
      ehc_ahbmo_hlock   : out std_ulogic;
      ehc_ahbmo_htrans  : out std_logic_vector(1 downto 0);
      ehc_ahbmo_haddr   : out std_logic_vector(31 downto 0);
      ehc_ahbmo_hwrite  : out std_ulogic;
      ehc_ahbmo_hsize   : out std_logic_vector(2 downto 0);
      ehc_ahbmo_hburst  : out std_logic_vector(2 downto 0);
      ehc_ahbmo_hprot   : out std_logic_vector(3 downto 0);
      ehc_ahbmo_hwdata  : out std_logic_vector(31 downto 0);
      -- UHC(s) AHB master output signals
      uhc_ahbmo_hbusreq : out std_logic_vector((n_cc-1)*uhcgen downto 0);
      uhc_ahbmo_hlock   : out std_logic_vector((n_cc-1)*uhcgen downto 0);
      uhc_ahbmo_htrans  : out std_logic_vector(((n_cc*2)-1)*uhcgen downto 0);
      uhc_ahbmo_haddr   : out std_logic_vector(((n_cc*32)-1)*uhcgen downto 0);
      uhc_ahbmo_hwrite  : out std_logic_vector((n_cc-1)*uhcgen downto 0);
      uhc_ahbmo_hsize   : out std_logic_vector(((n_cc*3)-1)*uhcgen downto 0);
      uhc_ahbmo_hburst  : out std_logic_vector(((n_cc*3)-1)*uhcgen downto 0);
      uhc_ahbmo_hprot   : out std_logic_vector(((n_cc*4)-1)*uhcgen downto 0);
      uhc_ahbmo_hwdata  : out std_logic_vector(((n_cc*32)-1)*uhcgen downto 0);
      -- UHC(s) AHB slave output signals
      uhc_ahbso_hready  : out std_logic_vector((n_cc-1)*uhcgen downto 0);
      uhc_ahbso_hresp   : out std_logic_vector(((n_cc*2)-1)*uhcgen downto 0);
      uhc_ahbso_hrdata  : out std_logic_vector(((n_cc*32)-1)*uhcgen downto 0);
      uhc_ahbso_hsplit  : out std_logic_vector(((n_cc*NAHBMST)-1)*uhcgen downto 0);
      uhc_irq           : out std_logic_vector((n_cc-1)*uhcgen downto 0);
      -- ULPI/UTMI+ output signals
      xcvrselect        : out std_logic_vector(((nports*2)-1) downto 0);
      termselect        : out std_logic_vector((nports-1) downto 0);
      opmode            : out std_logic_vector(((nports*2)-1) downto 0);
      txvalid           : out std_logic_vector((nports-1) downto 0);
      drvvbus           : out std_logic_vector((nports-1) downto 0);
      dataout           : out std_logic_vector(((nports*16)-1) downto 0);
      txvalidh          : out std_logic_vector((nports-1) downto 0);
      stp               : out std_logic_vector((nports-1) downto 0);    
      reset             : out std_logic_vector((nports-1) downto 0);
      oen               : out std_logic_vector((nports-1) downto 0);
      suspendm          : out std_ulogic;
      databus16_8       : out std_ulogic;
      dppulldown        : out std_ulogic;
      dmpulldown        : out std_ulogic;
      idpullup          : out std_ulogic;
      dischrgvbus       : out std_ulogic;
      chrgvbus          : out std_ulogic;
      txbitstuffenable  : out std_ulogic;
      txbitstuffenableh : out std_ulogic;
      fslsserialmode    : out std_ulogic;
      tx_enable_n       : out std_ulogic;
      tx_dat            : out std_ulogic;
      tx_se0            : out std_ulogic;
      -- ULPI/UTMI+ input signals
      linestate         : in  std_logic_vector(((nports*2)-1) downto 0);
      txready           : in  std_logic_vector((nports-1) downto 0);
      rxvalid           : in  std_logic_vector((nports-1) downto 0);
      rxactive          : in  std_logic_vector((nports-1) downto 0);
      rxerror           : in  std_logic_vector((nports-1) downto 0);
      vbusvalid         : in  std_logic_vector((nports-1) downto 0);
      datain            : in  std_logic_vector(((nports*16)-1) downto 0);
      rxvalidh          : in  std_logic_vector((nports-1) downto 0);
      hostdisconnect    : in  std_logic_vector((nports-1) downto 0);
      nxt               : in  std_logic_vector((nports-1) downto 0);
      dir               : in  std_logic_vector((nports-1) downto 0);
      urstdrive         : in  std_logic_vector((nports-1) downto 0);
      -- scan signals
      testen            : in  std_ulogic;
      testrst           : in  std_ulogic;
      scanen            : in  std_ulogic;
      testoen           : in  std_ulogic);
  end component;

  component grusbdc_gen is
    generic (
      aiface     : integer range 0 to 1         := 0;
      memtech    : integer range 0 to NTECH     := DEFMEMTECH;
      uiface     : integer range 0 to 1         := 0;
      dwidth     : integer range 8 to 16        := 8;
      blen       : integer range 4 to 128       := 16;
      nepi       : integer range 1 to 16        := 1;
      nepo       : integer range 1 to 16        := 1;
      i0         : integer range 8 to 3072      := 1024;
      i1         : integer range 8 to 3072      := 1024;
      i2         : integer range 8 to 3072      := 1024;
      i3         : integer range 8 to 3072      := 1024;
      i4         : integer range 8 to 3072      := 1024;
      i5         : integer range 8 to 3072      := 1024;
      i6         : integer range 8 to 3072      := 1024;
      i7         : integer range 8 to 3072      := 1024;
      i8         : integer range 8 to 3072      := 1024;
      i9         : integer range 8 to 3072      := 1024;
      i10        : integer range 8 to 3072      := 1024;
      i11        : integer range 8 to 3072      := 1024;
      i12        : integer range 8 to 3072      := 1024;
      i13        : integer range 8 to 3072      := 1024;
      i14        : integer range 8 to 3072      := 1024;
      i15        : integer range 8 to 3072      := 1024;
      o0         : integer range 8 to 3072      := 1024;
      o1         : integer range 8 to 3072      := 1024;
      o2         : integer range 8 to 3072      := 1024;
      o3         : integer range 8 to 3072      := 1024;
      o4         : integer range 8 to 3072      := 1024;
      o5         : integer range 8 to 3072      := 1024;
      o6         : integer range 8 to 3072      := 1024;
      o7         : integer range 8 to 3072      := 1024;
      o8         : integer range 8 to 3072      := 1024;
      o9         : integer range 8 to 3072      := 1024;
      o10        : integer range 8 to 3072      := 1024;
      o11        : integer range 8 to 3072      := 1024;
      o12        : integer range 8 to 3072      := 1024;
      o13        : integer range 8 to 3072      := 1024;
      o14        : integer range 8 to 3072      := 1024;
      o15        : integer range 8 to 3072      := 1024;
      oepol      : integer range 0 to 1         := 0;
      syncprst   : integer range 0 to 1         := 0;
      prsttime   : integer range 0 to 512       := 0;
      sysfreq    : integer                      := 50000;
      keepclk    : integer range 0 to 1         := 0;
      sepirq     : integer range 0 to 1         := 0;
      functesten : integer range 0 to 1         := 0;
      scantest   : integer range 0 to 1         := 0;
      nsync      : integer range 1 to 2         := 1);
    port (
      -- usb clock
      uclk              : in  std_ulogic;
      --usb in signals
      datain            : in  std_logic_vector(15 downto 0);
      rxactive          : in  std_ulogic;
      rxvalid           : in  std_ulogic;
      rxvalidh          : in  std_ulogic;
      rxerror           : in  std_ulogic;
      txready           : in  std_ulogic;
      linestate         : in  std_logic_vector(1 downto 0);
      nxt               : in  std_ulogic;
      dir               : in  std_ulogic;
      vbusvalid         : in  std_ulogic;
      urstdrive         : in  std_ulogic;
      --usb out signals
      dataout           : out std_logic_vector(15 downto 0);
      txvalid           : out std_ulogic;
      txvalidh          : out std_ulogic;
      opmode            : out std_logic_vector(1 downto 0);
      xcvrselect        : out std_logic_vector(1 downto 0);
      termselect        : out std_ulogic;
      suspendm          : out std_ulogic;
      reset             : out std_ulogic;
      stp               : out std_ulogic;
      oen               : out std_ulogic;
      databus16_8       : out std_ulogic;
      dppulldown        : out std_ulogic;
      dmpulldown        : out std_ulogic;
      idpullup          : out std_ulogic;
      drvvbus           : out std_ulogic;
      dischrgvbus       : out std_ulogic;
      chrgvbus          : out std_ulogic;
      txbitstuffenable  : out std_ulogic;
      txbitstuffenableh : out std_ulogic;
      fslsserialmode    : out std_ulogic;
      tx_enable_n       : out std_ulogic;
      tx_dat            : out std_ulogic;
      tx_se0            : out std_ulogic;
      -- amba clock/rst
      hclk              : in  std_ulogic;
      hrst              : in  std_ulogic;
      --ahb master in signals
      ahbmi_hgrant      : in  std_ulogic;
      ahbmi_hready      : in  std_ulogic;
      ahbmi_hresp       : in  std_logic_vector(1 downto 0);
      ahbmi_hrdata      : in  std_logic_vector(31 downto 0);
      --ahb master out signals    
      ahbmo_hbusreq     : out std_ulogic;
      ahbmo_hlock       : out std_ulogic;
      ahbmo_htrans      : out std_logic_vector(1 downto 0);
      ahbmo_haddr       : out std_logic_vector(31 downto 0);
      ahbmo_hwrite      : out std_ulogic;
      ahbmo_hsize       : out std_logic_vector(2 downto 0);
      ahbmo_hburst      : out std_logic_vector(2 downto 0);
      ahbmo_hprot       : out std_logic_vector(3 downto 0);
      ahbmo_hwdata      : out std_logic_vector(31 downto 0);
      --ahb slave in signals
      ahbsi_hsel        : in  std_ulogic;
      ahbsi_haddr       : in  std_logic_vector(31 downto 0);
      ahbsi_hwrite      : in  std_ulogic;
      ahbsi_htrans      : in  std_logic_vector(1 downto 0);
      ahbsi_hsize       : in  std_logic_vector(2 downto 0);
      ahbsi_hburst      : in  std_logic_vector(2 downto 0);
      ahbsi_hwdata      : in  std_logic_vector(31 downto 0);
      ahbsi_hprot       : in  std_logic_vector(3 downto 0);
      ahbsi_hready      : in  std_ulogic;
      ahbsi_hmaster     : in  std_logic_vector(3 downto 0);
      ahbsi_hmastlock   : in  std_ulogic;
      --ahb slave out signals
      ahbso_hready      : out std_ulogic;
      ahbso_hresp       : out std_logic_vector(1 downto 0);
      ahbso_hrdata      : out std_logic_vector(31 downto 0);
      ahbso_hsplit      : out std_logic_vector(NAHBMST-1 downto 0);
      -- misc
      irq               : out std_logic_vector(2*sepirq downto 0);
      -- scan signals
      testen            : in  std_ulogic;
      testrst           : in  std_ulogic;
      scanen            : in  std_ulogic;
      testoen           : in  std_ulogic
      );
    end component;
end grusb;

