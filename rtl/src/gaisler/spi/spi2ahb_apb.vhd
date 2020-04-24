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
-- Entity:      spi2ahb_apb
-- File:        spi2ahb_apb.vhd
-- Author:      Jan Andersson - Aeroflex Gaisler AB
-- Contact:     support@gaisler.com
-- Description: Simple SPI slave providing a bridge to AMBA AHB
--              This entity provides an APB interface for setting defining the
--              AHB address window that can be accessed from SPI.
--              See spi2ahbx.vhd and GRIP for documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.spi.all;

use work.amba.all;
use work.devices.all;
use work.stdlib.conv_std_logic;
use work.stdlib.conv_std_logic_vector;

entity spi2ahb_apb is
 generic (
   -- AHB Configuration
   hindex     : integer := 0;
   --
   ahbaddrh   : integer := 0;
   ahbaddrl   : integer := 0;
   ahbmaskh   : integer := 0;
   ahbmaskl   : integer := 0;
   resen      : integer := 0;
   -- APB configuration
   pindex     : integer := 0;         -- slave bus index
   paddr      : integer := 0;
   pmask      : integer := 16#fff#;
   pirq       : integer := 0;
   --
   oepol      : integer range 0 to 1 := 0;
   --
   filter     : integer range 2 to 512 := 2;
   --
   cpol       : integer range 0 to 1 := 0;
   cpha       : integer range 0 to 1 := 0
   );
 port (
   rstn   : in  std_ulogic;
   clk    : in  std_ulogic;
   -- AHB master interface
   ahbi   : in  ahb_mst_in_type;
   ahbo   : out ahb_mst_out_type;
   --
   apbi   : in  apb_slv_in_type;
   apbo   : out apb_slv_out_type;
   -- SPI signals
   spii   : in  spi_in_type;
   spio   : out spi_out_type
   );
end entity spi2ahb_apb;

architecture rtl of spi2ahb_apb is

  -- Register offsets
  constant CTRL_OFF : std_logic_vector(4 downto 2) := "000";
  constant STS_OFF  : std_logic_vector(4 downto 2) := "001";
  constant ADDR_OFF : std_logic_vector(4 downto 2) := "010";
  constant MASK_OFF : std_logic_vector(4 downto 2) := "011";
  
  -- AMBA PnP
  constant PCONFIG : apb_config_type := (
    0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_SPI2AHB, 0, 0, 0),
    1 => apb_iobar(paddr, pmask),
    2 => (others => '0'));

  type apb_reg_type is record
    spi2ahbi : spi2ahb_in_type;
    irq      : std_ulogic;
    irqen    : std_ulogic;
    prot     : std_ulogic;
    protx    : std_ulogic;
    wr       : std_ulogic;
    dma      : std_ulogic;
    dmax     : std_ulogic;
  end record;
  
  signal r, rin   : apb_reg_type;
  signal spi2ahbo : spi2ahb_out_type;
  
begin

  bridge : spi2ahbx
    generic map (hindex => hindex, oepol => oepol, filter => filter,
                 cpol => cpol, cpha => cpha)
    port map (rstn => rstn, clk => clk, ahbi => ahbi, ahbo => ahbo,
              spii => spii, spio => spio, spi2ahbi => r.spi2ahbi,
              spi2ahbo => spi2ahbo);
    
  comb: process (r, rstn, apbi, spi2ahbo)
    variable v         : apb_reg_type;
    variable apbaddr   : std_logic_vector(4 downto 2);
    variable apbout    : std_logic_vector(31 downto 0);
    variable irqout    : std_logic_vector(NAHBIRQ-1 downto 0);
  begin
    v := r; apbaddr := apbi.paddr(apbaddr'range); apbout := (others => '0');
    v.irq := '0'; irqout := (others => '0'); irqout(pirq) := r.irq;
    v.protx := spi2ahbo.prot; v.dmax := spi2ahbo.dma;
    
    ---------------------------------------------------------------------------
    -- APB register interface
    ---------------------------------------------------------------------------
    -- read registers
    if (apbi.psel(pindex) and apbi.penable) = '1' then
      case apbaddr is
        when CTRL_OFF => apbout(1 downto 0) := r.irqen & r.spi2ahbi.en;
        when STS_OFF  => apbout(2 downto 0) := r.prot & r.wr & r.dma;
        when ADDR_OFF => apbout := r.spi2ahbi.haddr;
        when MASK_OFF => apbout := r.spi2ahbi.hmask;
        when others => null;
      end case;
    end if;
   
    -- write registers
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbaddr is
        when CTRL_OFF => v.irqen := apbi.pwdata(1); v.spi2ahbi.en := apbi.pwdata(0);
        when STS_OFF  => v.dma := r.dma and not apbi.pwdata(0);
                         v.prot := r.prot and not apbi.pwdata(2);
        when ADDR_OFF => v.spi2ahbi.haddr := apbi.pwdata;
        when MASK_OFF => v.spi2ahbi.hmask := apbi.pwdata;
        when others => null;
      end case;
    end if;

    -- interrupt and status register handling
    if ((spi2ahbo.dma and not r.dmax) or
        (spi2ahbo.prot and not r.protx)) = '1' then
      v.dma := '1'; v.prot := r.prot or spi2ahbo.prot; v.wr := spi2ahbo.wr;
      if (r.irqen and not r.dma) = '1' then v.irq := '1'; end if;
    end if;
    
    ---------------------------------------------------------------------------
    -- reset
    ---------------------------------------------------------------------------
    if rstn = '0' then
      v.spi2ahbi.en := conv_std_logic(resen = 1);
      v.spi2ahbi.haddr := conv_std_logic_vector(ahbaddrh, 16) &
                          conv_std_logic_vector(ahbaddrl, 16);
      v.spi2ahbi.hmask := conv_std_logic_vector(ahbmaskh, 16) &
                          conv_std_logic_vector(ahbmaskl, 16);
      v.irqen := '0'; v.prot := '0'; v.wr := '0'; v.dma := '0';
    end if;

    ---------------------------------------------------------------------------
    -- signal assignments
    ---------------------------------------------------------------------------
    -- update registers
    rin <= v;

    -- update outputs
    apbo.prdata  <= apbout;
    apbo.pirq    <= irqout;
    apbo.pconfig <= PCONFIG;
    apbo.pindex  <= pindex;

  end process comb;

  reg: process(clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process reg;

  -- Boot message provided in spi2ahbx...
  
end architecture rtl;

