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
-- Entity:      devices
-- File:        devices.vhd
-- Author:      Cobham Gaisler AB
-- Description: Vendor and devices IDs for AMBA plug&play
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.sld_devices.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on

package devices is

-- Vendor codes

  constant VENDOR_RESERVED   : vendor_t := 16#00#;  -- Do not use!
  constant VENDOR_GAISLER    : vendor_t := 16#01#;
  constant VENDOR_PENDER     : vendor_t := 16#02#;
  constant VENDOR_ESA        : vendor_t := 16#04#;
  constant VENDOR_ASTRIUM    : vendor_t := 16#06#;
  constant VENDOR_OPENCHIP   : vendor_t := 16#07#;
  constant VENDOR_OPENCORES  : vendor_t := 16#08#;
  constant VENDOR_CONTRIB    : vendor_t := 16#09#;
  constant VENDOR_DLR        : vendor_t := 16#0A#;
  constant VENDOR_EONIC      : vendor_t := 16#0B#;
  constant VENDOR_TELECOMPT  : vendor_t := 16#0C#;
  constant VENDOR_DTU        : vendor_t := 16#0D#;
  constant VENDOR_BSC        : vendor_t := 16#0E#;
  constant VENDOR_RADIONOR   : vendor_t := 16#0F#;
  constant VENDOR_GLEICHMANN : vendor_t := 16#10#;
  constant VENDOR_MENTA      : vendor_t := 16#11#;
  constant VENDOR_SUN        : vendor_t := 16#13#;
  constant VENDOR_MOVIDIA    : vendor_t := 16#14#;
  constant VENDOR_ORBITA     : vendor_t := 16#17#;
  constant VENDOR_SYNOPSYS   : vendor_t := 16#21#;
  constant VENDOR_NASA       : vendor_t := 16#22#;
  constant VENDOR_S3         : vendor_t := 16#31#;
  constant VENDOR_ACTEL      : vendor_t := 16#AC#;
  constant VENDOR_APPLECORE  : vendor_t := 16#AE#;
  constant VENDOR_C3E        : vendor_t := 16#C3#;
  constant VENDOR_CBKPAN     : vendor_t := 16#C8#;
  constant VENDOR_CAL        : vendor_t := 16#CA#;
  constant VENDOR_CETON      : vendor_t := 16#CB#;
  constant VENDOR_EMBEDDIT   : vendor_t := 16#EA#;
  constant VENDOR_NASA_GSFC  : vendor_t := 16#FC#;

-- Cobham Gaisler device ids

  constant GAISLER_LEON2DSU  : devid_t := 16#002#;
  constant GAISLER_LEON3     : devid_t := 16#003#;
  constant GAISLER_LEON3DSU  : devid_t := 16#004#;
  constant GAISLER_ETHAHB    : devid_t := 16#005#;
  constant GAISLER_APBMST    : devid_t := 16#006#;
  constant GAISLER_AHBUART   : devid_t := 16#007#;
  constant GAISLER_SRCTRL    : devid_t := 16#008#;
  constant GAISLER_SDCTRL    : devid_t := 16#009#;
  constant GAISLER_SSRCTRL   : devid_t := 16#00A#;
  constant GAISLER_I2C2AHB   : devid_t := 16#00B#;
  constant GAISLER_APBUART   : devid_t := 16#00C#;
  constant GAISLER_IRQMP     : devid_t := 16#00D#;
  constant GAISLER_AHBRAM    : devid_t := 16#00E#;
  constant GAISLER_AHBDPRAM  : devid_t := 16#00F#;
  constant GAISLER_GRIOMMU2  : devid_t := 16#010#;
  constant GAISLER_GPTIMER   : devid_t := 16#011#;
  constant GAISLER_PCITRG    : devid_t := 16#012#;
  constant GAISLER_PCISBRG   : devid_t := 16#013#;
  constant GAISLER_PCIFBRG   : devid_t := 16#014#;
  constant GAISLER_PCITRACE  : devid_t := 16#015#;
  constant GAISLER_DMACTRL   : devid_t := 16#016#;
  constant GAISLER_AHBTRACE  : devid_t := 16#017#;
  constant GAISLER_DSUCTRL   : devid_t := 16#018#;
  constant GAISLER_CANAHB    : devid_t := 16#019#;
  constant GAISLER_GPIO      : devid_t := 16#01A#;
  constant GAISLER_AHBROM    : devid_t := 16#01B#;
  constant GAISLER_AHBJTAG   : devid_t := 16#01C#;
  constant GAISLER_ETHMAC    : devid_t := 16#01D#;
  constant GAISLER_SWNODE    : devid_t := 16#01E#;
  constant GAISLER_SPW       : devid_t := 16#01F#;
  constant GAISLER_AHB2AHB   : devid_t := 16#020#;
  constant GAISLER_USBDC     : devid_t := 16#021#;
  constant GAISLER_USB_DCL   : devid_t := 16#022#;
  constant GAISLER_DDRMP     : devid_t := 16#023#;
  constant GAISLER_ATACTRL   : devid_t := 16#024#;
  constant GAISLER_DDRSP     : devid_t := 16#025#;
  constant GAISLER_EHCI      : devid_t := 16#026#;
  constant GAISLER_UHCI      : devid_t := 16#027#;
  constant GAISLER_I2CMST    : devid_t := 16#028#;
  constant GAISLER_SPW2      : devid_t := 16#029#;
  constant GAISLER_AHBDMA    : devid_t := 16#02A#;
  constant GAISLER_NUHOSP3   : devid_t := 16#02B#;
  constant GAISLER_CLKGATE   : devid_t := 16#02C#;
  constant GAISLER_SPICTRL   : devid_t := 16#02D#;
  constant GAISLER_DDR2SP    : devid_t := 16#02E#;
  constant GAISLER_SLINK     : devid_t := 16#02F#;
  constant GAISLER_GRTM      : devid_t := 16#030#;
  constant GAISLER_GRTC      : devid_t := 16#031#;
  constant GAISLER_GRPW      : devid_t := 16#032#;
  constant GAISLER_GRCTM     : devid_t := 16#033#;
  constant GAISLER_GRHCAN    : devid_t := 16#034#;
  constant GAISLER_GRFIFO    : devid_t := 16#035#;
  constant GAISLER_GRADCDAC  : devid_t := 16#036#;
  constant GAISLER_GRPULSE   : devid_t := 16#037#;
  constant GAISLER_GRTIMER   : devid_t := 16#038#;
  constant GAISLER_AHB2PP    : devid_t := 16#039#;
  constant GAISLER_GRVERSION : devid_t := 16#03A#;
  constant GAISLER_APB2PW    : devid_t := 16#03B#;
  constant GAISLER_PW2APB    : devid_t := 16#03C#;
  constant GAISLER_GRCAN     : devid_t := 16#03D#;
  constant GAISLER_I2CSLV    : devid_t := 16#03E#;
  constant GAISLER_U16550    : devid_t := 16#03F#;
  constant GAISLER_AHBMST_EM : devid_t := 16#040#;
  constant GAISLER_AHBSLV_EM : devid_t := 16#041#;
  constant GAISLER_GRTESTMOD : devid_t := 16#042#;
  constant GAISLER_ASCS      : devid_t := 16#043#;
  constant GAISLER_IPMVBCTRL : devid_t := 16#044#;
  constant GAISLER_SPIMCTRL  : devid_t := 16#045#;
  constant GAISLER_L4STAT    : devid_t := 16#047#;
  constant GAISLER_LEON4     : devid_t := 16#048#;
  constant GAISLER_LEON4DSU  : devid_t := 16#049#;
  constant GAISLER_PWM       : devid_t := 16#04A#;
  constant GAISLER_L2CACHE   : devid_t := 16#04B#;
  constant GAISLER_SDCTRL64  : devid_t := 16#04C#;
  constant GAISLER_GR1553B   : devid_t := 16#04D#;
  constant GAISLER_1553TST   : devid_t := 16#04E#;
  constant GAISLER_GRIOMMU   : devid_t := 16#04F#;
  constant GAISLER_FTAHBRAM  : devid_t := 16#050#;
  constant GAISLER_FTSRCTRL  : devid_t := 16#051#;
  constant GAISLER_AHBSTAT   : devid_t := 16#052#;
  constant GAISLER_LEON3FT   : devid_t := 16#053#;
  constant GAISLER_FTMCTRL   : devid_t := 16#054#;
  constant GAISLER_FTSDCTRL  : devid_t := 16#055#;
  constant GAISLER_FTSRCTRL8 : devid_t := 16#056#;
  constant GAISLER_MEMSCRUB  : devid_t := 16#057#;
  constant GAISLER_FTSDCTRL64: devid_t := 16#058#;
  constant GAISLER_NANDFCTRL : devid_t := 16#059#;
  constant GAISLER_N2DLLCTRL : devid_t := 16#05A#;
  constant GAISLER_N2PLLCTRL : devid_t := 16#05B#;
  constant GAISLER_SPI2AHB   : devid_t := 16#05C#;
  constant GAISLER_DDRSDMUX  : devid_t := 16#05D#;
  constant GAISLER_AHBFROM   : devid_t := 16#05E#;
  constant GAISLER_PCIEXP    : devid_t := 16#05F#;
  constant GAISLER_APBPS2    : devid_t := 16#060#;
  constant GAISLER_VGACTRL   : devid_t := 16#061#;
  constant GAISLER_LOGAN     : devid_t := 16#062#;
  constant GAISLER_SVGACTRL  : devid_t := 16#063#;
  constant GAISLER_T1AHB     : devid_t := 16#064#;
  constant GAISLER_MP7WRAP   : devid_t := 16#065#;
  constant GAISLER_GRSYSMON  : devid_t := 16#066#;
  constant GAISLER_GRACECTRL : devid_t := 16#067#;
  constant GAISLER_ATAHBSLV  : devid_t := 16#068#;
  constant GAISLER_ATAHBMST  : devid_t := 16#069#;
  constant GAISLER_ATAPBSLV  : devid_t := 16#06A#;
  constant GAISLER_MIGDDR2   : devid_t := 16#06B#;
  constant GAISLER_LCDCTRL   : devid_t := 16#06C#;
  constant GAISLER_SWITCHOVER: devid_t := 16#06D#;
  constant GAISLER_FIFOUART  : devid_t := 16#06E#;
  constant GAISLER_MUXCTRL   : devid_t := 16#06F#;
  constant GAISLER_B1553BC   : devid_t := 16#070#;
  constant GAISLER_B1553RT   : devid_t := 16#071#;
  constant GAISLER_B1553BRM  : devid_t := 16#072#;
  constant GAISLER_AES       : devid_t := 16#073#;
  constant GAISLER_ECC       : devid_t := 16#074#;
  constant GAISLER_PCIF      : devid_t := 16#075#;
  constant GAISLER_CLKMOD    : devid_t := 16#076#;
  constant GAISLER_HAPSTRAK  : devid_t := 16#077#;
  constant GAISLER_TEST_1X2  : devid_t := 16#078#;
  constant GAISLER_WILD2AHB  : devid_t := 16#079#;
  constant GAISLER_BIO1      : devid_t := 16#07A#;
  constant GAISLER_AESDMA    : devid_t := 16#07B#;
  constant GAISLER_GRPCI2    : devid_t := 16#07C#;
  constant GAISLER_GRPCI2_DMA: devid_t := 16#07D#;
  constant GAISLER_GRPCI2_TB : devid_t := 16#07E#;
  constant GAISLER_MMA       : devid_t := 16#07F#;
  constant GAISLER_SATCAN    : devid_t := 16#080#;
  constant GAISLER_CANMUX    : devid_t := 16#081#;
  constant GAISLER_GRTMRX    : devid_t := 16#082#;
  constant GAISLER_GRTCTX    : devid_t := 16#083#;
  constant GAISLER_GRTMDESC  : devid_t := 16#084#;
  constant GAISLER_GRTMVC    : devid_t := 16#085#;
  constant GAISLER_GEFFE     : devid_t := 16#086#;
  constant GAISLER_GPREG     : devid_t := 16#087#;
  constant GAISLER_GRTMPAHB  : devid_t := 16#088#;
  constant GAISLER_SPWCUC    : devid_t := 16#089#;
  constant GAISLER_SPW2_DMA  : devid_t := 16#08A#;
  constant GAISLER_SPWROUTER : devid_t := 16#08B#;
  constant GAISLER_EDCLMST   : devid_t := 16#08C#;
  constant GAISLER_GRPWTX    : devid_t := 16#08D#;
  constant GAISLER_GRPWRX    : devid_t := 16#08E#;
  constant GAISLER_GPREGBANK : devid_t := 16#08F#;
  constant GAISLER_MIG_7SERIES   : devid_t := 16#090#;
  constant GAISLER_GRSPW2_SIST   : devid_t := 16#091#;
  constant GAISLER_SGMII     : devid_t := 16#092#;
  constant GAISLER_RGMII     : devid_t := 16#093#;
  constant GAISLER_IRQGEN    : devid_t := 16#094#;
  constant GAISLER_GRDMAC    : devid_t := 16#095#;
  constant GAISLER_AHB2AVLA  : devid_t := 16#096#;
  constant GAISLER_SPWTDP    : devid_t := 16#097#;
  constant GAISLER_L3STAT    : devid_t := 16#098#;
  constant GAISLER_GR740THS  : devid_t := 16#099#;
  constant GAISLER_GRRM      : devid_t := 16#09A#;
  constant GAISLER_CMAP      : devid_t := 16#09B#;
  constant GAISLER_CPGEN     : devid_t := 16#09C#;
  constant GAISLER_AMBAPROT  : devid_t := 16#09D#;
  constant GAISLER_IGLOO2_BRIDGE : devid_t := 16#09E#;
  constant GAISLER_AHB2AXI   : devid_t := 16#09F#;
  constant GAISLER_AXI2AHB   : devid_t := 16#0A0#;
  constant GAISLER_FDIR_RSTCTRL : devid_t := 16#0A1#;
  constant GAISLER_APB3MST   : devid_t := 16#0A2#;
  constant GAISLER_LRAM      : devid_t := 16#0A3#;
  constant GAISLER_BOOTSEQ   : devid_t := 16#0A4#;

-- Sun Microsystems

  constant SUN_T1             : devid_t := 16#001#;
  constant SUN_S1             : devid_t := 16#011#;

-- Caltech

  constant CAL_DDRCTRL        : devid_t := 16#188#;

-- CBK PAN
  constant CBKPAN_FTNANDCTRL    : devid_t := 16#001#;
  constant CBKPAN_FTEEPROMCTRL  : devid_t := 16#002#;
  constant CBKPAN_FTSDCTRL16    : devid_t := 16#003#;
  constant CBKPAN_STIXCTRL      : devid_t := 16#300#;

-- European Space Agency device ids

  constant ESA_LEON2        : devid_t := 16#002#;
  constant ESA_LEON2APB     : devid_t := 16#003#;
  constant ESA_IRQ          : devid_t := 16#005#;
  constant ESA_TIMER        : devid_t := 16#006#;
  constant ESA_UART         : devid_t := 16#007#;
  constant ESA_CFG          : devid_t := 16#008#;
  constant ESA_IO           : devid_t := 16#009#;
  constant ESA_MCTRL        : devid_t := 16#00F#;
  constant ESA_PCIARB       : devid_t := 16#010#;
  constant ESA_HURRICANE    : devid_t := 16#011#;
  constant ESA_SPW_RMAP     : devid_t := 16#012#;
  constant ESA_AHBUART      : devid_t := 16#013#;
  constant ESA_SPWA         : devid_t := 16#014#;
  constant ESA_BOSCHCAN     : devid_t := 16#015#;
  constant ESA_IRQ2         : devid_t := 16#016#;
  constant ESA_AHBSTAT      : devid_t := 16#017#;
  constant ESA_WPROT        : devid_t := 16#018#;
  constant ESA_WPROT2       : devid_t := 16#019#;

  constant ESA_PDEC3AMBA    : devid_t := 16#020#;
  constant ESA_PTME3AMBA    : devid_t := 16#021#;

-- OpenChip IDs

  constant OPENCHIP_APBGPIO     : devid_t := 16#001#;
  constant OPENCHIP_APBI2C      : devid_t := 16#002#;
  constant OPENCHIP_APBSPI      : devid_t := 16#003#;
  constant OPENCHIP_APBCHARLCD  : devid_t := 16#004#;
  constant OPENCHIP_APBPWM      : devid_t := 16#005#;
  constant OPENCHIP_APBPS2      : devid_t := 16#006#;
  constant OPENCHIP_APBMMCSD    : devid_t := 16#007#;
  constant OPENCHIP_APBNAND     : devid_t := 16#008#;
  constant OPENCHIP_APBLPC      : devid_t := 16#009#;
  constant OPENCHIP_APBCF       : devid_t := 16#00A#;
  constant OPENCHIP_APBSYSACE   : devid_t := 16#00B#;
  constant OPENCHIP_APB1WIRE    : devid_t := 16#00C#;
  constant OPENCHIP_APBJTAG     : devid_t := 16#00D#;
  constant OPENCHIP_APBSUI      : devid_t := 16#00E#;


-- Gleichmann's device ids

  constant GLEICHMANN_CUSTOM   : devid_t := 16#001#;
  constant GLEICHMANN_GEOLCD01 : devid_t := 16#002#;
  constant GLEICHMANN_DAC      : devid_t := 16#003#;
  constant GLEICHMANN_HPI      : devid_t := 16#004#;
  constant GLEICHMANN_SPI      : devid_t := 16#005#;
  constant GLEICHMANN_HIFC     : devid_t := 16#006#;
  constant GLEICHMANN_ADCDAC   : devid_t := 16#007#;
  constant GLEICHMANN_SPIOC    : devid_t := 16#008#;
  constant GLEICHMANN_AC97     : devid_t := 16#009#;

-- MENTA device ids

  constant MENTA_EFPGA_IP       : devid_t := 16#002#;
  
-- DTU device ids

  constant DTU_IV              : devid_t := 16#001#;
  constant DTU_RBMMTRANS       : devid_t := 16#002#;
  constant DTU_FTMCTRL         : devid_t := 16#054#;

-- BSC device ids

  constant BSC_CORE1           : devid_t := 16#001#;
  constant BSC_CORE2           : devid_t := 16#002#;
  
-- Orbita device ids

  constant ORBITA_1553B        : devid_t := 16#001#;
  constant ORBITA_429          : devid_t := 16#002#;
  constant ORBITA_SPI          : devid_t := 16#003#;
  constant ORBITA_I2C          : devid_t := 16#004#;
  constant ORBITA_SMARTCARD    : devid_t := 16#064#;
  constant ORBITA_SDCARD       : devid_t := 16#065#;
  constant ORBITA_UART16550    : devid_t := 16#066#;
  constant ORBITA_CRYPTO       : devid_t := 16#067#;
  constant ORBITA_SYSIF        : devid_t := 16#068#;
  constant ORBITA_PIO          : devid_t := 16#069#;
  constant ORBITA_RTC          : devid_t := 16#0C8#;
  constant ORBITA_COLORLCD     : devid_t := 16#12C#;
  constant ORBITA_PCI          : devid_t := 16#190#;
  constant ORBITA_DSP          : devid_t := 16#1F4#;
  constant ORBITA_USBHOST      : devid_t := 16#258#;
  constant ORBITA_USBDEV       : devid_t := 16#2BC#;

  
-- Actel device ids

  constant ACTEL_COREMP7       : devid_t := 16#001#;

-- NASA device ids

  constant NASA_EP32           : devid_t := 16#001#;

-- AppleCore device ids

  constant APPLECORE_UTLEON3    : devid_t := 16#001#;
  constant APPLECORE_UTLEON3DSU : devid_t := 16#002#;
  constant APPLECORE_APBPERFCNT : devid_t := 16#003#;

-- Contribution library IDs

  constant CONTRIB_CORE1        : devid_t := 16#001#;
  constant CONTRIB_CORE2        : devid_t := 16#002#;

-- grlib system device ids

  subtype system_device_type  is integer range 0 to 16#ffff#;
  constant LEON3_ACT_FUSION     : system_device_type := 16#0105#;
  constant LEON3_RTAX_CID1      : system_device_type := 16#0201#;
  constant LEON3_RTAX_CID2      : system_device_type := 16#0202#;
  constant LEON3_RTAX_CID3      : system_device_type := 16#0203#;
  constant LEON3_RTAX_CID4      : system_device_type := 16#0204#;
  constant LEON3_RTAX_CID5      : system_device_type := 16#0205#;
  constant LEON3_RTAX_CID6      : system_device_type := 16#0206#;
  constant LEON3_RTAX_CID7      : system_device_type := 16#0207#;
  constant LEON3_RTAX_CID8      : system_device_type := 16#0208#;
  constant LEON3_PROXIMA        : system_device_type := 16#0252#;
  constant ALTERA_DE2           : system_device_type := 16#0302#;
  constant ALTERA_DE4           : system_device_type := 16#0303#;
  constant XILINX_ML401         : system_device_type := 16#0401#;
  constant LEON3FT_GRXC4V       : system_device_type := 16#0453#;
  constant XILINX_ML501         : system_device_type := 16#0501#;
  constant XILINX_ML505         : system_device_type := 16#0505#;
  constant XILINX_ML506         : system_device_type := 16#0506#;
  constant XILINX_ML507         : system_device_type := 16#0507#;
  constant XILINX_ML509         : system_device_type := 16#0509#;
  constant XILINX_ML510         : system_device_type := 16#0510#;
  constant MICROSEMI_M2GL_EVAL  : system_device_type := 16#0560#;
  constant XILINX_SP601         : system_device_type := 16#0601#;
  constant XILINX_ML605         : system_device_type := 16#0605#;
  constant XILINX_AC701         : system_device_type := 16#A701#;
  constant XILINX_KC705         : system_device_type := 16#A705#;
  constant XILINX_VC707         : system_device_type := 16#A707#;
  constant ESA_SSDP             : system_device_type := 16#ADA2#;
-- pragma translate_off

  constant GAISLER_DESC : vdesc_t :=  "Cobham Gaisler          ";

  constant gaisler_device_table : dtable_t := (
   GAISLER_LEON2DSU  => "LEON2 Debug Support Unit       ",
   GAISLER_LEON3     => "LEON3 SPARC V8 Processor       ",
   GAISLER_LEON3DSU  => "LEON3 Debug Support Unit       ",
   GAISLER_ETHAHB    => "OC ethernet AHB interface      ",
   GAISLER_AHBRAM    => "Single-port AHB SRAM module    ",
   GAISLER_AHBDPRAM  => "Dual-port AHB SRAM module      ",
   GAISLER_APBMST    => "AHB/APB Bridge                 ",
   GAISLER_AHBUART   => "AHB Debug UART                 ",
   GAISLER_SRCTRL    => "Simple SRAM Controller         ",
   GAISLER_SDCTRL    => "PC133 SDRAM Controller         ",
   GAISLER_SSRCTRL   => "Synchronous SRAM Controller    ",
   GAISLER_APBUART   => "Generic UART                   ",
   GAISLER_IRQMP     => "Multi-processor Interrupt Ctrl.",
   GAISLER_GPTIMER   => "Modular Timer Unit             ",
   GAISLER_PCITRG    => "Simple 32-bit PCI Target       ",
   GAISLER_PCISBRG   => "Simple 32-bit PCI Bridge       ",
   GAISLER_PCIFBRG   => "Fast 32-bit PCI Bridge         ",
   GAISLER_PCITRACE  => "32-bit PCI Trace Buffer        ",
   GAISLER_DMACTRL   => "PCI/AHB DMA controller         ",
   GAISLER_AHBTRACE  => "AMBA Trace Buffer              ",
   GAISLER_DSUCTRL   => "DSU/ETH controller             ",
   GAISLER_GRTM      => "CCSDS Telemetry Encoder        ",
   GAISLER_GRTC      => "CCSDS Telecommand Decoder      ",
   GAISLER_GRPW      => "PacketWire to AMBA AHB I/F     ",
   GAISLER_GRCTM     => "CCSDS Time Manager             ",
   GAISLER_GRHCAN    => "ESA HurriCANe CAN with DMA     ",
   GAISLER_GRFIFO    => "FIFO Controller                ",
   GAISLER_GRADCDAC  => "ADC / DAC Interface            ",
   GAISLER_GRPULSE   => "General Purpose I/O with Pulses",
   GAISLER_GRTIMER   => "Timer Unit with Latches        ",
   GAISLER_AHB2PP    => "AMBA AHB to Packet Parallel I/F",
   GAISLER_GRVERSION => "Version and Revision Register  ",
   GAISLER_APB2PW    => "PacketWire Transmit Interface  ",
   GAISLER_PW2APB    => "PacketWire Receive Interface   ",
   GAISLER_GRCAN     => "CAN Controller with DMA        ",
   GAISLER_AHBMST_EM => "AMBA Master Emulator           ",
   GAISLER_AHBSLV_EM => "AMBA Slave Emulator            ",
   GAISLER_CANAHB    => "OC CAN AHB interface           ",
   GAISLER_GPIO      => "General Purpose I/O port       ",
   GAISLER_AHBROM    => "Generic AHB ROM                ",
   GAISLER_AHB2AHB   => "AHB-to-AHB Bridge              ",
   GAISLER_AHBDMA    => "Simple AHB DMA controller      ",
   GAISLER_NUHOSP3   => "Nuhorizons Spartan3 IO I/F     ",
   GAISLER_CLKGATE   => "Clock gating unit              ",
   GAISLER_FTAHBRAM  => "Generic FT AHB SRAM module     ",
   GAISLER_FTSRCTRL  => "Simple FT SRAM Controller      ",
   GAISLER_LEON3FT   => "LEON3-FT SPARC V8 Processor    ",
   GAISLER_FTMCTRL   => "Memory controller with EDAC    ",
   GAISLER_FTSDCTRL  => "FT PC133 SDRAM Controller      ",
   GAISLER_FTSRCTRL8 => "FT 8-bit SRAM/16-bit IO Ctrl   ",
   GAISLER_FTSDCTRL64=> "64-bit FT SDRAM Controller     ",
   GAISLER_AHBSTAT   => "AHB Status Register            ",
   GAISLER_AHBJTAG   => "JTAG Debug Link                ",
   GAISLER_ETHMAC    => "GR Ethernet MAC                ",
   GAISLER_SWNODE    => "SpaceWire Node Interface       ",
   GAISLER_SPW       => "SpaceWire Serial Link          ",
   GAISLER_VGACTRL   => "VGA controller                 ",
   GAISLER_APBPS2    => "PS2 interface                  ",
   GAISLER_LOGAN     => "On chip Logic Analyzer         ",
   GAISLER_SVGACTRL  => "SVGA frame buffer              ",
   GAISLER_T1AHB     => "Niagara T1 PCX/AHB bridge      ",
   GAISLER_B1553BC   => "AMBA Wrapper for Core1553BBC   ",
   GAISLER_B1553RT   => "AMBA Wrapper for Core1553BRT   ",
   GAISLER_B1553BRM  => "AMBA Wrapper for Core1553BRM   ",
   GAISLER_SATCAN    => "SatCAN controller              ",
   GAISLER_CANMUX    => "CAN Bus multiplexer            ",
   GAISLER_GRTMRX    => "CCSDS Telemetry Receiver       ",
   GAISLER_GRTCTX    => "CCSDS Telecommand Transmitter  ",
   GAISLER_GRTMDESC  => "CCSDS Telemetry Descriptor     ",
   GAISLER_GRTMVC    => "CCSDS Telemetry VC Generator   ",
   GAISLER_GRTMPAHB  => "CCSDS Telemetry VC AHB Input   ",
   GAISLER_GEFFE     => "Geffe Generator                ",
   GAISLER_SPWCUC    => "CCSDS CUC / SpaceWire I/F      ",
   GAISLER_GPREG     => "General Purpose Register       ",
   GAISLER_AES       => "Advanced Encryption Standard   ",
   GAISLER_AESDMA    => "AES 256 DMA                    ",
   GAISLER_GRPCI2    => "GRPCI2 PCI/AHB bridge          ",
   GAISLER_GRPCI2_DMA=> "GRPCI2 DMA interface           ",
   GAISLER_GRPCI2_TB => "GRPCI2 Trace buffer            ",
   GAISLER_MMA       => "Memory Mapped AMBA             ",
   GAISLER_ECC       => "Elliptic Curve Cryptography    ",
   GAISLER_PCIF      => "AMBA Wrapper for CorePCIF      ",
   GAISLER_USBDC     => "GR USB 2.0 Device Controller   ",
   GAISLER_USB_DCL   => "USB Debug Communication Link   ",
   GAISLER_DDRMP     => "Multi-port DDR controller      ",
   GAISLER_ATACTRL   => "ATA controller                 ",
   GAISLER_DDRSP     => "Single-port DDR266 controller  ",
   GAISLER_EHCI      => "USB Enhanced Host Controller   ",
   GAISLER_UHCI      => "USB Universal Host Controller  ",
   GAISLER_I2CMST    => "AMBA Wrapper for OC I2C-master ",
   GAISLER_I2CSLV    => "I2C Slave                      ",
   GAISLER_U16550    => "Simple 16550 UART              ",
   GAISLER_SPICTRL   => "SPI Controller                 ",
   GAISLER_DDR2SP    => "Single-port DDR2 controller    ",
   GAISLER_GRTESTMOD => "Test report module             ",
   GAISLER_CLKMOD    => "CPU Clock Switching Ctrl module",
   GAISLER_SLINK     => "SLINK Master                   ",
   GAISLER_HAPSTRAK  => "HAPS HapsTrak I/O Port         ",
   GAISLER_TEST_1X2  => "HAPS TEST_1x2 interface        ",
   GAISLER_WILD2AHB  => "WildCard CardBus interface     ",
   GAISLER_BIO1      => "Basic I/O board BIO1           ",
   GAISLER_ASCS      => "ASCS Master                    ",
   GAISLER_SPW2      => "GRSPW2 SpaceWire Serial Link   ",
   GAISLER_IPMVBCTRL => "IPM-bus/MVBC memory controller ",
   GAISLER_SPIMCTRL  => "SPI Memory Controller          ",
   GAISLER_L4STAT    => "LEON4 Statistics Unit          ",
   GAISLER_LEON4     => "LEON4 SPARC V8 Processor       ",
   GAISLER_LEON4DSU  => "LEON4 Debug Support Unit       ",
   GAISLER_PWM       => "PWM generator                  ",
   GAISLER_L2CACHE   => "L2-Cache Controller            ",
   GAISLER_SDCTRL64  => "64-bit PC133 SDRAM Controller  ",
   GAISLER_MP7WRAP   => "CoreMP7 wrapper                ",
   GAISLER_GRSYSMON  => "AMBA wrapper for System Monitor",
   GAISLER_GRACECTRL => "System ACE I/F Controller      ",
   GAISLER_ATAHBSLV  => "AMBA Test Framework AHB Slave  ",
   GAISLER_ATAHBMST  => "AMBA Test Framework AHB Master ",
   GAISLER_ATAPBSLV  => "AMBA Test Framework APB Slave  ",
   GAISLER_MIGDDR2   => "Xilinx MIG DDR2 Controller     ",
   GAISLER_LCDCTRL   => "LCD Controller                 ",
   GAISLER_SWITCHOVER=> "Switchover Logic               ",
   GAISLER_FIFOUART  => "UART with large FIFO           ",
   GAISLER_MUXCTRL   => "Analogue multiplexer control   ",
   GAISLER_GR1553B   => "MIL-STD-1553B Interface        ",
   GAISLER_1553TST   => "MIL-STD-1553B Test Device      ",
   GAISLER_MEMSCRUB  => "AHB Memory Scrubber            ",
   GAISLER_GRIOMMU   => "IO Memory Management Unit      ",
   GAISLER_SPW2_DMA  => "GRSPW Router DMA interface     ",
   GAISLER_SPWROUTER => "GRSPW Router                   ",
   GAISLER_EDCLMST   => "EDCL master interface          ",
   GAISLER_GRPWTX    => "PacketWire Transmitter with DMA",
   GAISLER_GRPWRX    => "PacketWire Receiver with DMA   ",
   GAISLER_GRIOMMU2  => "IOMMU secondary master i/f     ",
   GAISLER_I2C2AHB   => "I2C to AHB Bridge              ",
   GAISLER_NANDFCTRL => "NAND Flash Controller          ",
   GAISLER_N2PLLCTRL => "N2X PLL Dynamic Config. i/f    ",
   GAISLER_N2DLLCTRL => "N2X DLL Dynamic Config. i/f    ",
   GAISLER_GPREGBANK => "General Purpose Register Bank  ",
   GAISLER_SPI2AHB   => "SPI to AHB Bridge              ",
   GAISLER_DDRSDMUX  => "Muxed FT DDR/SDRAM controller  ",
   GAISLER_AHBFROM   => "Flash ROM Memory               ",
   GAISLER_PCIEXP    => "Xilinx PCI EXPRESS Wrapper     ",
   GAISLER_MIG_7SERIES => "Xilinx MIG DDR3 Controller     ",
   GAISLER_GRSPW2_SIST => "GRSPW Router SIST              ",
   GAISLER_SGMII     => "XILINX SGMII Interface         ",
   GAISLER_RGMII     => "Gaisler RGMII Interface        ",
   GAISLER_IRQGEN    => "Interrupt generator            ",
   GAISLER_GRDMAC    => "GRDMAC DMA Controller          ",
   GAISLER_AHB2AVLA  => "Avalon-MM memory controller    ",
   GAISLER_SPWTDP    => "CCSDS TDP / SpaceWire I/F      ",
   GAISLER_L3STAT    => "LEON3 Statistics Unit          ",
   GAISLER_GR740THS  => "Temperature sensor             ",
   GAISLER_GRRM      => "Reconfiguration Module         ",
   GAISLER_CMAP      => "CCSDS Memory Access Protocol   ",
   GAISLER_CPGEN     => "Discrete Command Pulse Gen     ",
   GAISLER_AMBAPROT  => "AMBA Protection Unit           ",
   GAISLER_IGLOO2_BRIDGE => "Microsemi SF2/IGLOO2 MSS/HPMS  ",
   GAISLER_AHB2AXI   => "AMBA AHB/AXI Bridge            ",
   GAISLER_AXI2AHB   => "AMBA AXI/AHB Bridge            ",
   GAISLER_FDIR_RSTCTRL => "FDIR Reset Controller          ",
   GAISLER_APB3MST   => "AHB/APB3 Bridge                ",
   GAISLER_LRAM      => "Dual-port AHB(/CPU) On-Chip RAM",
   GAISLER_BOOTSEQ   => "Custom AHB sequencer           ",
   others            => "Unknown Device                 ");

   constant gaisler_lib : vlib_t := (
     vendorid        => VENDOR_GAISLER,
     vendordesc      => GAISLER_DESC,
     device_table    => gaisler_device_table
   );

  constant ESA_DESC : vdesc_t := "European Space Agency   ";

  constant esa_device_table : dtable_t := (
   ESA_LEON2        => "LEON2 SPARC V8 Processor       ",
   ESA_LEON2APB     => "LEON2 Peripheral Bus           ",
   ESA_IRQ          => "LEON2 Interrupt Controller     ",
   ESA_TIMER        => "LEON2 Timer                    ",
   ESA_UART         => "LEON2 UART                     ",
   ESA_CFG          => "LEON2 Configuration Register   ",
   ESA_IO           => "LEON2 Input/Output             ",
   ESA_MCTRL        => "LEON2 Memory Controller        ",
   ESA_PCIARB       => "PCI Arbiter                    ",
   ESA_HURRICANE    => "HurriCANe/HurryAMBA CAN Ctrl   ",
   ESA_SPW_RMAP     => "UoD/Saab SpaceWire/RMAP link   ",
   ESA_AHBUART      => "LEON2 AHB Debug UART           ",
   ESA_SPWA         => "ESA/ASTRIUM SpaceWire link     ",
   ESA_BOSCHCAN     => "SSC/BOSCH CAN Ctrl             ",
   ESA_IRQ2         => "LEON2 Secondary Irq Controller ",
   ESA_AHBSTAT      => "LEON2 AHB Status Register      ",
   ESA_WPROT        => "LEON2 Write Protection         ",
   ESA_WPROT2       => "LEON2 Extended Write Protection",
   ESA_PDEC3AMBA    => "ESA CCSDS PDEC3AMBA TC Decoder ",
   ESA_PTME3AMBA    => "ESA CCSDS PTME3AMBA TM Encoder ",
   others           => "Unknown Device                 ");

   constant esa_lib : vlib_t := (
     vendorid       => VENDOR_ESA,
     vendordesc     => ESA_DESC,
     device_table   => esa_device_table
   );

  constant OPENCHIP_DESC : vdesc_t := "OpenChip                ";

  constant openchip_device_table : dtable_t := (
    OPENCHIP_APBGPIO    => "APB General Purpose IO         ",
    OPENCHIP_APBI2C     => "APB I2C Interface              ",
    OPENCHIP_APBSPI     => "APB SPI Interface              ",
    OPENCHIP_APBCHARLCD => "APB Character LCD              ",
    OPENCHIP_APBPWM     => "APB PWM                        ",
    OPENCHIP_APBPS2     => "APB PS/2 Interface             ",
    OPENCHIP_APBMMCSD   => "APB MMC/SD Card Interface      ",
    OPENCHIP_APBNAND    => "APB NAND(SmartMedia) Interface ",
    OPENCHIP_APBLPC     => "APB LPC Interface              ",
    OPENCHIP_APBCF      => "APB CompactFlash (IDE)         ",
    OPENCHIP_APBSYSACE  => "APB SystemACE Interface        ",
    OPENCHIP_APB1WIRE   => "APB 1-Wire Interface           ",
    OPENCHIP_APBJTAG    => "APB JTAG TAP Master            ",
    OPENCHIP_APBSUI     => "APB Simple User Interface      ",

    others              => "Unknown Device                 ");

  constant openchip_lib : vlib_t := (
    vendorid            => VENDOR_OPENCHIP,
    vendordesc          => OPENCHIP_DESC,
    device_table        => openchip_device_table
  );

  constant GLEICHMANN_DESC : vdesc_t := "Gleichmann Electronics  ";

  constant gleichmann_device_table : dtable_t := (
    GLEICHMANN_CUSTOM   => "Custom device                  ",
    GLEICHMANN_GEOLCD01 => "GEOLCD01 graphics system       ",
    GLEICHMANN_DAC      => "Sigma delta DAC                ",
    GLEICHMANN_HPI      => "AHB-to-HPI bridge              ",
    GLEICHMANN_SPI      => "SPI master                     ",
    GLEICHMANN_HIFC     => "Human interface controller     ",
    GLEICHMANN_ADCDAC   => "Sigma delta ADC/DAC            ",
    GLEICHMANN_SPIOC    => "SPI master for SDCard IF       ",
    GLEICHMANN_AC97     => "AC97 Controller                ",
    others              => "Unknown Device                 ");

  constant gleichmann_lib : vlib_t := (
    vendorid     => VENDOR_GLEICHMANN,
    vendordesc   => GLEICHMANN_DESC,
    device_table => gleichmann_device_table
    );

  constant CONTRIB_DESC : vdesc_t := "Various contributions   ";

  constant contrib_device_table : dtable_t := (
   CONTRIB_CORE1    => "Contributed core 1             ",
   CONTRIB_CORE2    => "Contributed core 2             ",
   others           => "Unknown Device                 ");

   constant contrib_lib : vlib_t := (
     vendorid        => VENDOR_CONTRIB,
     vendordesc      => CONTRIB_DESC,
     device_table    => contrib_device_table
   );

  constant MENTA_DESC : vdesc_t :=  "Menta                   ";

  constant menta_device_table : dtable_t := (
   MENTA_EFPGA_IP      => "eFPGA Core IP                  ",
   others              => "Unknown Device                 ");

   constant menta_lib : vlib_t := (
     vendorid          => VENDOR_MENTA,
     vendordesc        => MENTA_DESC,
     device_table      => menta_device_table
   );

  constant SUN_DESC : vdesc_t := "Sun Microsystems        ";

  constant sun_device_table : dtable_t := (
   SUN_T1           => "Niagara T1 SPARC V9 Processor  ",
   SUN_S1           => "Niagara S1 SPARC V9 Processor  ",
   others           => "Unknown Device                 ");

   constant sun_lib : vlib_t := (
     vendorid          => VENDOR_SUN,
     vendordesc        => SUN_DESC,
     device_table      => sun_device_table
   );

  constant OPENCORES_DESC : vdesc_t :=  "OpenCores               ";

  constant opencores_device_table : dtable_t := (
   others              => "Unknown Device                 ");

   constant opencores_lib : vlib_t := (
     vendorid          => VENDOR_OPENCORES,
     vendordesc        => OPENCORES_DESC,
     device_table      => opencores_device_table
   );

  constant CBKPAN_DESC : vdesc_t := "CBK PAN                 ";
  
  constant cbkpan_device_table : dtable_t := (
    CBKPAN_FTNANDCTRL       => "NAND FLASH controller w/DMA    ",
    CBKPAN_FTEEPROMCTRL     => "Fault Toler. EEPROM Controller ",
    CBKPAN_FTSDCTRL16       => "Fault Toler. 16-bit SDRAM Ctrl.",
    CBKPAN_STIXCTRL         => "SolO/STIX IDPU dedicated ctrl. ",
    others                  => "Unknown Device                 ");
   
  constant cbkpan_lib : vlib_t := (
    vendorid       => VENDOR_CBKPAN,
    vendordesc     => CBKPAN_DESC,
    device_table   => cbkpan_device_table
   );
  
  constant CETON_DESC : vdesc_t :=  "Ceton Corporation       ";

  constant ceton_device_table : dtable_t := (
   others              => "Unknown Device                 ");

   constant ceton_lib : vlib_t := (
     vendorid          => VENDOR_CETON,
     vendordesc        => CETON_DESC,
     device_table      => ceton_device_table
   );

  constant SYNOPSYS_DESC : vdesc_t :=  "Synopsys Inc.           ";

  constant synopsys_device_table : dtable_t := (
   others              => "Unknown Device                 ");

   constant synopsys_lib : vlib_t := (
     vendorid          => VENDOR_SYNOPSYS,
     vendordesc        => SYNOPSYS_DESC,
     device_table      => synopsys_device_table
   );

  constant EMBEDDIT_DESC : vdesc_t :=  "Embedd.it               ";

  constant embeddit_device_table : dtable_t := (
   others              => "Unknown Device                 ");

   constant embeddit_lib : vlib_t := (
     vendorid          => VENDOR_EMBEDDIT,
     vendordesc        => EMBEDDIT_DESC,
     device_table      => embeddit_device_table
   );

  constant dlr_device_table : dtable_t := (
   others              => "Unknown Device                 ");

  constant DLR_DESC : vdesc_t :=  "German Aerospace Center ";

  constant dlr_lib : vlib_t := (
     vendorid          => VENDOR_DLR,
     vendordesc        => DLR_DESC,
     device_table      => dlr_device_table
   );

  constant eonic_device_table : dtable_t := (
   others              => "Unknown Device                 ");

  constant EONIC_DESC : vdesc_t :=  "Eonic BV                ";

  constant eonic_lib : vlib_t := (
     vendorid          => VENDOR_EONIC,
     vendordesc        => EONIC_DESC,
     device_table      => eonic_device_table
   );

  constant telecompt_device_table : dtable_t := (
   others              => "Unknown Device                 ");

  constant TELECOMPT_DESC : vdesc_t :=  "Telecom ParisTech       ";

  constant telecompt_lib : vlib_t := (
     vendorid          => VENDOR_TELECOMPT,
     vendordesc        => TELECOMPT_DESC,
     device_table      => telecompt_device_table
   );
  
  constant radionor_device_table : dtable_t := (
   others              => "Unknown Device                 ");

  constant RADIONOR_DESC : vdesc_t :=  "Radionor Communications ";

  constant radionor_lib : vlib_t := (
     vendorid          => VENDOR_RADIONOR,
     vendordesc        => RADIONOR_DESC,
     device_table      => radionor_device_table
   );

  constant bsc_device_table : dtable_t := (
   BSC_CORE1           => "Core 1                         ",
   BSC_CORE2           => "Core 2                         ",
   others              => "Unknown Device                 ");

  constant BSC_DESC : vdesc_t :=  "BSC                     ";

  constant bsc_lib : vlib_t := (
     vendorid          => VENDOR_BSC,
     vendordesc        => BSC_DESC,
     device_table      => bsc_device_table
   );
  
  constant dtu_device_table : dtable_t := (
   DTU_IV              => "Instrument Virtualizer         ",
   DTU_RBMMTRANS       => "RB/MM Transfer                 ",
   DTU_FTMCTRL         => "Memory controller with 8CS     ",
   others              => "Unknown Device                 ");

  constant DTU_DESC : vdesc_t :=  "DTU Space               ";

   constant dtu_lib : vlib_t := (
     vendorid          => VENDOR_DTU,
     vendordesc        => DTU_DESC,
     device_table      => dtu_device_table
   );

  
  constant orbita_device_table : dtable_t := (
   ORBITA_1553B       => "MIL-STD-1553B Controller       ",
   ORBITA_429         => "429 Interface                  ",
   ORBITA_SPI         => "SPI Interface                  ",
   ORBITA_I2C         => "I2C Interface                  ",
   ORBITA_SMARTCARD   => "Smart Card Reader              ",
   ORBITA_SDCARD      => "SD Card Reader                 ",
   ORBITA_UART16550   => "16550 UART                     ",
   ORBITA_CRYPTO      => "Crypto Engine                  ",
   ORBITA_SYSIF       => "System Interface               ",
   ORBITA_PIO         => "Programmable IO module         ",
   ORBITA_RTC         => "Real-Time Clock                ",
   ORBITA_COLORLCD    => "Color LCD Controller           ",
   ORBITA_PCI         => "PCI Module                     ",
   ORBITA_DSP         => "DPS Co-Processor               ",
   ORBITA_USBHOST     => "USB Host                       ",
   ORBITA_USBDEV      => "USB Device                     ",
   others              => "Unknown Device                 ");

  constant ORBITA_DESC : vdesc_t :=  "Orbita                  ";

  constant orbita_lib : vlib_t := (
     vendorid          => VENDOR_ORBITA,
     vendordesc        => ORBITA_DESC,
     device_table      => orbita_device_table
   );

  constant ACTEL_DESC : vdesc_t :=   "Actel Corporation       ";

  constant actel_device_table : dtable_t := (
   ACTEL_COREMP7      => "CoreMP7 Processor              ",
   others             => "Unknown Device                 ");

  constant actel_lib : vlib_t := (
     vendorid          => VENDOR_ACTEL,
     vendordesc        => ACTEL_DESC,
     device_table      => actel_device_table
   );

  constant NASA_DESC : vdesc_t :=   "NASA                    ";

  constant nasa_device_table : dtable_t := (
   NASA_EP32         => "EP32 Forth processor           ",
   others             => "Unknown Device                 ");

  constant nasa_lib : vlib_t := (
     vendorid          => VENDOR_NASA,
     vendordesc        => NASA_DESC,
     device_table      => nasa_device_table
   );

  constant NASA_GSFC_DESC : vdesc_t :=   "NASA GSFC               ";

  constant nasa_gsfc_device_table : dtable_t := (
   others             => "Unknown Device                 ");

  constant nasa_gsfc_lib : vlib_t := (
     vendorid          => VENDOR_NASA_GSFC,
     vendordesc        => NASA_GSFC_DESC,
     device_table      => nasa_gsfc_device_table
   );
  
  constant S3_DESC : vdesc_t :=   "S3 Group                ";

  constant s3_device_table : dtable_t := (
   others             => "Unknown Device                 ");

  constant s3_lib : vlib_t := (
     vendorid          => VENDOR_S3,
     vendordesc        => S3_DESC,
     device_table      => s3_device_table
   );

  constant APPLECORE_DESC : vdesc_t :=   "AppleCore               ";
  constant applecore_device_table : dtable_t := (
      APPLECORE_UTLEON3     => "AppleCore uT-LEON3 Processor   ",
      APPLECORE_UTLEON3DSU  => "AppleCore uT-LEON3 DSU         ",
      others                => "Unknown Device                 ");
  constant applecore_lib : vlib_t := (
      vendorid         => VENDOR_APPLECORE,
      vendordesc        => APPLECORE_DESC,
      device_table      => applecore_device_table
      );

  constant C3E_DESC : vdesc_t :=   "TU Braunschweig C3E     ";
  constant c3e_device_table : dtable_t := (
      others                => "Unknown Device                 ");
  constant c3e_lib : vlib_t := (
      vendorid          => VENDOR_C3E,
      vendordesc        => C3E_DESC,
      device_table      => c3e_device_table
      );
  
  constant UNKNOWN_DESC : vdesc_t :=  "Unknown vendor          ";

  constant unknown_device_table : dtable_t := (
   others              => "Unknown Device                 ");

   constant unknown_lib : vlib_t := (
     vendorid          => 0,
     vendordesc        => UNKNOWN_DESC,
     device_table      => unknown_device_table
   );

  constant iptable : device_array := (
    VENDOR_GAISLER     => gaisler_lib,
    VENDOR_ESA         => esa_lib,
    VENDOR_OPENCHIP    => openchip_lib,
    VENDOR_OPENCORES   => opencores_lib,
    VENDOR_CONTRIB     => contrib_lib,
    VENDOR_DLR         => dlr_lib,
    VENDOR_EONIC       => eonic_lib,
    VENDOR_TELECOMPT   => telecompt_lib,
    VENDOR_GLEICHMANN  => gleichmann_lib,
    VENDOR_MENTA       => menta_lib,
    VENDOR_EMBEDDIT    => embeddit_lib,
    VENDOR_SUN         => sun_lib,
    VENDOR_RADIONOR    => radionor_lib,
    VENDOR_ORBITA      => orbita_lib,
    VENDOR_SYNOPSYS    => synopsys_lib,
    VENDOR_CETON       => ceton_lib,
    VENDOR_ACTEL       => actel_lib,
    VENDOR_NASA        => nasa_lib,
    VENDOR_NASA_GSFC   => nasa_gsfc_lib,
    VENDOR_S3          => s3_lib,
    VENDOR_SLD         => sld_lib,
    VENDOR_SIFIVE      => sifive_lib,
    others             => unknown_lib);

  type system_table_type is array (0 to 65535) of ddesc_t;

  constant system_table : system_table_type := (
   LEON3_ACT_FUSION   => "LEON3 Actel Fusion Dev. board  ",
   LEON3_RTAX_CID2    => "LEON3FT RTAX Configuration 2   ",
   LEON3_RTAX_CID5    => "LEON3FT RTAX Configuration 5   ",
   LEON3_RTAX_CID6    => "LEON3FT RTAX Configuration 6   ",
   LEON3_RTAX_CID7    => "LEON3FT RTAX Configuration 7   ",
   LEON3_RTAX_CID8    => "LEON3FT RTAX Configuration 8   ",
   LEON3_PROXIMA      => "LEON3 PROXIMA FPGA design      ",
   ALTERA_DE2         => "Altera DE2 Development board   ",
   ALTERA_DE4         => "TerASIC DE4 Development board  ",
   XILINX_ML401       => "Xilinx ML401 Development board ",
   XILINX_ML501       => "Xilinx ML501 Development board ",
   XILINX_ML505       => "Xilinx ML505 Development board ",
   XILINX_ML506       => "Xilinx ML506 Development board ",
   XILINX_ML507       => "Xilinx ML507 Development board ",
   XILINX_ML509       => "Xilinx ML509 Development board ",
   XILINX_ML510       => "Xilinx ML510 Development board ",
   XILINX_AC701       => "Xilinx AC701 Development board ",
   XILINX_KC705       => "Xilinx KC705 Development board ",
   XILINX_VC707       => "Xilinx VC707 Development board ",
   MICROSEMI_M2GL_EVAL=> "Microsemi IGLOO2 Evaluation kit", 
   XILINX_SP601       => "Xilinx SP601 Development board ",
   XILINX_ML605       => "Xilinx ML605 Development board ",
   others             => "Unknown system                 ");

-- pragma translate_on

end;

