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
-- Entity:      spi2ahbx
-- File:        spi2ahbx.vhd
-- Author:      Jan Andersson - Aeroflex Gaisler AB
-- Contact:     support@gaisler.com
-- Description: Simple SPI slave providing a bridge to AMBA AHB
--              This entity is typically wrapped with spi2ahb or spi2ahb_apb.
-------------------------------------------------------------------------------
--
-- Short core documentation, for additional information see the GRLIB IP
-- Library User's Manual (GRIP):
--
-- The core functions as a SPI memory device. To write to the core, issue the
-- following SPI bus sequence:
--
-- 0. Assert chip select
-- 1. Write instruction
-- 2. Send 32-bit address
-- 3. Send data to be written
-- 4. Deassert chip select
--
-- The core will expect 32-bits of data and write these as a word. This can be
-- changed by writing to the core's control register. See documentation further
-- down. If less than HSIZE bytes are transferred the core will drop the data.
-- After HSIZE bytes has been transferred the core will perform the write to
-- memory. If another byte is received before the core has written its data
-- then the core will discard the current and any following bytes. This
-- condition can be detected by checking the MALFUNCTION bit in the core's
-- status register.
--
-- To read to the core, issue the following SPI bus sequence:
--
-- 0. Assert chip select
-- 1. Send read instruction 
-- 2. Send 32-bit address to be used
-- 3. Send dummy byte (depending on read instruction used)
-- 4. Read bytes
-- 5. Deassert chip select
--
-- The core will perform 32-bit data accesses to fill its internal buffer. This
-- can be changed by writing to the core's control register (see documentation
-- further down). If the buffer is empty when the core should return the first
-- byte then the core will return invalid data. This condition can be later
-- detected by checking the MALFUNCTION bit in the core's status register.
-- When the core initiates additional data fetches can be configured via the
-- RAHEAD bit in the control/status register.
--
-- The cores control/status register is read via the RDSR instruction and
-- written via the WRSR instruction.
--
-- +--------+-----------------------------------------------------------------+
-- | Bit(s) | Description                                                     |
-- +--------+-----------------------------------------------------------------+
-- |   7    | Reserved, always zero (RO)                                      |
-- |   6    | RAHEAD: Read ahead. When this bit is set the core will make a   |
-- |        | new access to fetch data as soon as the last current data bit   |
-- |        | has been moved. Otherwise the core will not attempt the new     |
-- |        | access until the 'change' transition on SCK. See GRIP doc. for  |
-- |        | details. Default value is '1'. (RW)                             |
-- |   5    | PROT: Memory protection triggered. Last access was outside      |
-- |        | range. Updated after each AMBA access (RO)                      |
-- |   4    | MEXC: Memory exception. Gets set if core receives AMBA ERROR    |
-- |        | response. Updated after each AMBA access. (RO)                  |
-- |   3    | DMAACT: Core is currently performing DMA (RO)                   |
-- |   2    | MALFUNCTION: Set to 1 if DMA is not finished when new byte      |
-- |        | starts getting shifted                                          |
-- |  1:0   | HSIZE: Controls the access size core will use for AMBA accesses |
-- |        | Default is HSIZE = WORD. HSIZE 11 is illegal (RW)               |
-- +--------+-----------------------------------------------------------------+
--
-- Documentation of generics:
--
-- [hindex]  AHB master index
--
-- [oepol]   Output enable polarity
--
-- [filter]  Length of filter used on SCK
--


library ieee;
use ieee.std_logic_1164.all;

use work.spi.all;

use work.amba.all;
use work.devices.all;
use work.stdlib.all;

entity spi2ahbx is
 generic (
   -- AHB configuration
   hindex   : integer := 0;
   oepol    : integer range 0 to 1 := 0;
   filter   : integer range 2 to 512 := 2;
   cpol     : integer range 0 to 1 := 0;
   cpha     : integer range 0 to 1 := 0
   );
 port (
   rstn     : in  std_ulogic;
   clk      : in  std_ulogic;
   -- AHB master interface
   ahbi     : in  ahb_mst_in_type;
   ahbo     : out ahb_mst_out_type;
   -- SPI signals
   spii     : in  spi_in_type;
   spio     : out spi_out_type;
   --
   spi2ahbi : in  spi2ahb_in_type;
   spi2ahbo : out spi2ahb_out_type
   );
end entity spi2ahbx;

architecture rtl of spi2ahbx is
  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant OE         : std_ulogic := conv_std_logic(oepol = 1);
  constant HIZ        : std_ulogic := not OE;
  
  -----------------------------------------------------------------------------
  -- Instructions
  -----------------------------------------------------------------------------
  constant RDSR_INST  : std_logic_vector(7 downto 0) := X"05";
  constant WRSR_INST  : std_logic_vector(7 downto 0) := X"01";
  constant READ_INST  : std_logic_vector(7 downto 0) := X"03";
  constant READD_INST : std_logic_vector(7 downto 0) := X"0B";  -- with dummy
  constant WRITE_INST : std_logic_vector(7 downto 0) := X"02";
  
  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  type state_type is (decode, rdsr, wrsr, addr, dummy, rd, wr, idle, malfunction);
  
  type spi2ahb_reg_type is record
    state    : state_type;
    --
    haddr    : std_logic_vector(31 downto 0);
    hdata    : std_logic_vector(31 downto 0);
    hsize    : std_logic_vector(1 downto 0);
    hwrite   : std_ulogic;
    --
    rahead   : std_ulogic;
    mexc     : std_ulogic;
    dodma    : std_ulogic;
    prot     : std_ulogic;
    malf     : std_ulogic;
    --
    brec     : std_ulogic;
    rec      : std_ulogic;
    dummy    : std_ulogic;
    cnt      : std_logic_vector(2 downto 0);
    bcnt     : std_logic_vector(1 downto 0);
    sreg     : std_logic_vector(7 downto 0);
    miso     : std_ulogic;
    rdop     : std_logic_vector(1 downto 0);
    --
    misooen  : std_ulogic;
    sel      : std_logic_vector(1 downto 0);
    psck     : std_ulogic;
    sck      : std_logic_vector(filter downto 0);
    mosi     : std_logic_vector(1 downto 0);
  end record;  
  
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  signal ami : ahb_dma_in_type;
  signal amo : ahb_dma_out_type;
  
  signal r, rin : spi2ahb_reg_type;

begin

  -- Generic AHB master interface
  ahbmst0 : ahbmst
    generic map (hindex => hindex, hirq => 0, venid => VENDOR_GAISLER,
                 devid => GAISLER_SPI2AHB, version => 0,
                 chprot => 3, incaddr => 0)
    port map (rstn, clk, ami, amo, ahbi, ahbo);
  
  comb: process (r, rstn, spii, amo, spi2ahbi)
    variable v         : spi2ahb_reg_type;
    variable hrdata    : std_logic_vector(31 downto 0);
    variable ahbreq    : std_ulogic;
    variable lb        : std_ulogic;
    variable sample    : std_ulogic;
    variable change    : std_ulogic;
  begin
    v := r; ahbreq := '0'; lb := '0'; hrdata := (others => '0');
    sample := '0'; change := '0'; v.brec := '0';
    
    ---------------------------------------------------------------------------
    -- Sync input signals
    ---------------------------------------------------------------------------
    v.sel := r.sel(0) & spii.spisel;
    v.sck := r.sck(filter-1 downto 0) & spii.sck;
    v.mosi := r.mosi(0) & spii.mosi;

    ---------------------------------------------------------------------------
    -- DMA control
    ---------------------------------------------------------------------------
    if r.dodma = '1' then
      if amo.active = '1' then
        if amo.ready = '1' then
          hrdata := ahbreadword(amo.rdata);
          case r.hsize is
            when "00" =>
              v.haddr := r.haddr + 1;
              for i in 1 to 3 loop
                if i = conv_integer(r.haddr(1 downto 0)) then
                  hrdata(31 downto 24) := hrdata(31-8*i downto 24-8*i);
                end if;
              end loop;
            when "01" =>
              v.haddr := r.haddr + 2;
              if r.haddr(1) = '1' then
                hrdata(31 downto 16) := hrdata(15 downto 0);
              end if;
            when others =>
              v.haddr := r.haddr + 4;
          end case;
          v.sreg := hrdata(31 downto 24);
          v.hdata(31 downto 8) := hrdata(23 downto 0);
          v.mexc := '0';
          v.dodma := '0';
        end if;
        if amo.mexc = '1' then
          v.mexc := '1';
          v.dodma := '0';
        end if;
      else
        ahbreq := '1';
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- SPI communication
    ---------------------------------------------------------------------------
    if andv(r.sck(filter downto 1)) = '1' then v.psck := '1'; end if;
    if orv(r.sck(filter downto 1)) = '0' then v.psck := '0';  end if;
    if (r.psck xor v.psck) = '1' then
      if r.psck = conv_std_logic(cpol = 1) then
        sample := not conv_std_logic(cpha = 1);
        change := conv_std_logic(cpha = 1);
      else
        sample := conv_std_logic(cpha = 1);
        change := not conv_std_logic(cpha = 1);
      end if;
    end if;

    if sample = '1' then
      v.cnt := r.cnt + 1;
      if r.cnt = "111" then
        v.cnt := (others => '0');
        v.brec := '1';
      end if;
      if r.state /= dummy then
        v.sreg := r.sreg(6 downto 0) & r.mosi(1);
      end if;
    end if;

    if change = '1' then
      v.miso := r.sreg(7);
    end if;
    
    ---------------------------------------------------------------------------
    -- SPI slave control FSM
    ---------------------------------------------------------------------------
    if ((r.hsize = "00") or ((r.hsize(0) and r.bcnt(0)) = '1') or
        (r.bcnt = "11")) then
      lb := '1';
    end if;

    case r.state is
      when decode =>
        if r.brec = '1' then
          case r.sreg is
            when RDSR_INST =>
              v.state := rdsr;
              v.sreg := '0' & r.rahead & r.prot & r.mexc &
                        r.dodma & r.malf & r.hsize;
            when WRSR_INST => v.state := wrsr;
            when READ_INST | READD_INST=>
              v.state := addr; v.rec := '0';
              v.dummy := r.sreg(3);
            when WRITE_INST => v.state := addr; v.rec := '1';
            when others => null;
          end case;
        end if;

      when rdsr => 
        if r.brec = '1' then
          v.sreg := '0' & r.rahead & r.prot & r.mexc &
                    r.dodma & r.malf & r.hsize;
        end if;

      when wrsr =>
        if r.brec = '1' then
          v.rahead := r.sreg(6);
          v.hsize := r.sreg(1 downto 0);
        end if;

      when addr =>
        -- First we need a 4 byte address, then we handle data.
        if r.brec = '1' then
          if r.dodma = '1' then
            v.state := malfunction;
          else
            v.haddr := r.haddr(23 downto 0) & r.sreg;
          end if;
          v.bcnt := r.bcnt + 1;
          if r.bcnt = "11" then
            if r.rec = '1' then
              v.state := wr;
            else
              if r.dummy = '1' then
                v.state := dummy;
              else
                v.state := rd;
              end if;
              v.malf := '0';
              v.dodma := '1';
              v.hwrite := '0';
            end if;
          end if;
        end if;

      when dummy => 
        if r.brec = '1' then
          v.state := rd;
        end if;
        
      when rd =>
        if r.brec = '1' then
          v.bcnt := r.bcnt + 1;
          v.hdata(31 downto 8) := r.hdata(23 downto 0);
          v.sreg := r.hdata(31 downto 24);
          if (lb and r.rahead) = '1' then
            v.dodma := '1';
            v.bcnt := "00";
          end if;
          v.rdop(0) := lb and not r.rahead;
        end if;
        if (change and v.dodma) = '1' then
          v.state := malfunction;
        end if;
        -- Without readahead
        if orv(r.rdop) = '1' then
          if (sample and v.dodma) = '1' then
            -- Case is a little tricky. Master may have sampled bad
            -- data but we detect the DMA operation as completed.
            v.state := malfunction;
          end if;
          if (r.rdop(0) and change) = '1' then
            v.dodma := '1';
            v.rdop := "10";
          end if;
          if (r.dodma and not v.dodma) = '1' then
            v.miso := hrdata(31);
            v.rdop := (others => '0');
          end if;
        end if;
        
      when wr => 
        if r.brec = '1' then
          v.bcnt := r.bcnt + 1;
          if v.dodma = '0' then
            if r.bcnt = "00" then v.hdata(31 downto 24) := r.sreg; end if;
            if r.bcnt(1) = '0' then v.hdata(23 downto 16) := r.sreg; end if;
            if r.bcnt(0) = '0' then v.hdata(15 downto 8) := r.sreg; end if;
            v.hdata(7 downto 0) := r.sreg;
            if lb = '1' then v.dodma := '1'; v.hwrite := '1'; v.malf := '0'; end if;
          else
            v.state := malfunction;
          end if;
        end if;
        
      when idle =>
        if r.sel(1) = '0' then
          v.state := decode;
          v.misooen := OE;
          v.cnt := (others => '0');
          v.bcnt := (others => '0');
        end if;

      when malfunction =>
        v.malf := '1';
        
    end case;

    if r.state /= rd then v.rdop := (others => '0'); end if;
    
    if spi2ahbi.hmask /= zero32 then
      if v.dodma = '1' then
        if ((spi2ahbi.haddr xor r.haddr) and spi2ahbi.hmask) /= zero32 then
          v.dodma := '0';
          v.prot := '1';
          v.state := idle;
        else
          v.prot := '0';
        end if;
      end if;
    else
      v.prot := '0';
    end if;
    
    if spi2ahbi.en = '1' then
      if r.sel(1) = '1' then
        v.state := idle;
        v.misooen := HIZ;
      end if;
    else
      v.state := idle;
      v.misooen := HIZ;
    end if;
   
   ----------------------------------------------------------------------------
   -- Reset
   ----------------------------------------------------------------------------

    if rstn = '0' then
      v.state   := idle;
      v.haddr   := (others => '0');
      v.hdata   := (others => '0');
      v.hsize   := HSIZE_WORD(1 downto 0);
      v.rahead  := '1';
      v.mexc    := '0';
      v.dodma   := '0';
      v.prot    := '0';
      v.malf    := '0';
      v.psck    := conv_std_logic(cpol = 1);
      v.miso    := '1';
      v.misooen := HIZ;
    end if;

    if spi2ahbi.hmask = zero32 then v.prot := '0'; end if;
    
    ----------------------------------------------------------------------------
    -- Signal assignments
    ----------------------------------------------------------------------------
   
    -- Core registers
    rin <= v;
    
    -- AHB master control
    ami.address   <= r.haddr;
    ami.wdata     <= ahbdrivedata(r.hdata);
    ami.start     <= ahbreq;
    ami.burst     <= '0';
    ami.write     <= r.hwrite;
    ami.busy      <= '0';
    ami.irq       <= '0';
    ami.size      <= '0' & r.hsize;
    
    -- Update outputs
    spi2ahbo.dma  <= r.dodma;
    spi2ahbo.wr   <= r.hwrite;
    spi2ahbo.prot <= r.prot;

    -- Several unused here..
    spio.miso     <= r.miso;
    spio.misooen  <= r.misooen;
    spio.mosi     <= '0';
    spio.mosioen  <= HIZ;
    spio.sck      <= '0';
    spio.sckoen   <= HIZ;
    spio.ssn      <= (others => '0');
    spio.enable   <= spi2ahbi.en;
    spio.astart   <= '0';
  end process comb;

  reg: process (clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process reg;

 -- Boot message
 -- pragma translate_off
 bootmsg : report_version
   generic map ("spi2ahb" & tost(hindex) & ": SPI to AHB bridge");
 -- pragma translate_on

end architecture rtl;

