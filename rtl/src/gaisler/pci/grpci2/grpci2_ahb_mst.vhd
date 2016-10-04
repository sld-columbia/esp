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
-- Entity:      grpci2_ahb_mst
-- File:        grpci2_ahb_mst.vhd
-- Author:      Nils-Johan Wessman - Aeroflex Gaisler
-- Description: GRPCI2 AHB master interface 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.amba.all;
use work.devices.all;

use work.pcilib2.all;

entity grpci2_ahb_mst is
  generic(
    hindex      : integer := 0;
    venid   : integer := VENDOR_GAISLER;
    devid   : integer := 0;
    version : integer := 0
  );
  port(
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    ahbmi       : in  ahb_mst_in_type;
    ahbmo       : out ahb_mst_out_type;
    dmai0       : in  dma_ahb_in_type;
    dmao0       : out dma_ahb_out_type;
    dmai1       : in  dma_ahb_in_type;
    dmao1       : out dma_ahb_out_type
  );
end entity;

architecture rtl of grpci2_ahb_mst is
  type reg_type is record
    bg     : std_ulogic; --bus granted
    bo     : std_ulogic; --bus owner, 0=dma0, 1=dma1
    ba     : std_ulogic; --bus active
    bb     : std_ulogic; --1kB burst boundary detected
    retry  : std_ulogic; 
  end record;
  
  constant hconfig : ahb_config_type := (
    0 => ahb_device_reg ( venid, devid, 0, version, 0),
    others => zero32);

  signal r, rin : reg_type;
begin
  comb : process(rst, r, dmai1, dmai0, ahbmi) is
  variable v       : reg_type;
  variable htrans  : std_logic_vector(1 downto 0);
  variable hbusreq : std_ulogic;
  variable hwrite  : std_ulogic; 
  variable haddr   : std_logic_vector(31 downto 0);
  variable hwdata  : std_logic_vector(31 downto 0);
  variable nbo     : std_ulogic; 
  variable retry1  : std_ulogic;
  variable retry0  : std_ulogic;
  variable ready0  : std_ulogic;
  variable ready1  : std_ulogic;
  variable error0  : std_ulogic;
  variable error1  : std_ulogic;
  variable grant1  : std_ulogic;
  variable grant0  : std_ulogic;
  variable hsize   : std_logic_vector(2 downto 0);
  variable hburst  : std_logic_vector(2 downto 0);
  begin
    v := r; htrans := HTRANS_IDLE; ready0 := '0'; ready1 := '0'; retry1 := '0';
    retry0 := '0'; error0 := '0'; error1 := '0'; grant1 := '0'; grant0 := '0';
    hsize := HSIZE_WORD;
    hburst := HBURST_INCR;

    if r.bo = '0' then hwdata := dmai0.data;
    else hwdata := dmai1.data; end if;
    
    hbusreq := dmai1.req or dmai0.req;
    if hbusreq = '1' then htrans := HTRANS_NONSEQ; end if;

    if r.retry = '0' then
      nbo := dmai1.req and not (dmai0.req and not r.bo);
    else
      nbo := r.bo;
    end if;

    if nbo = '0' then
      haddr := dmai0.addr; hwrite := dmai0.write; hsize := '0' & dmai0.size;
      if dmai0.burst = '0' then hburst := HBURST_SINGLE; end if;
      if (dmai0.req and r.ba
          and not r.bo and not r.retry and dmai0.size(1)) = '1' and dmai0.burst = '1' then
        htrans := HTRANS_SEQ; 
      end if;
      if (dmai0.req and r.bg and ahbmi.hready and not r.retry) = '1' 
      then grant0 := '1'; end if; 
      
    else
      haddr := dmai1.addr; hwrite := dmai1.write; hsize := '0' & dmai1.size;
      if dmai1.burst = '0' then hburst := HBURST_SINGLE; end if;
      if (dmai1.req and r.ba 
          and r.bo and not r.retry and dmai1.size(1)) = '1' and dmai1.burst = '1' then
        htrans := HTRANS_SEQ; 
      end if;
      if (dmai1.req and r.bg and ahbmi.hready and not r.retry) = '1' 
      then grant1 := '1'; end if; 
    
    end if;

    --1 kB burst boundary
    if ahbmi.hready = '1' then
      if haddr(9 downto 2) = "11111111" 
      then
        v.bb := '1';
        if htrans = HTRANS_SEQ then hbusreq := '0'; end if;
      elsif ((dmai0.noreq and grant0) or (dmai1.noreq and grant1)) = '1' then
        v.bb := '1';
        hbusreq := '0';
      else
        v.bb := '0';
      end if;
    end if;


    if (r.bb = '1') and (htrans /= HTRANS_IDLE) then
      htrans := HTRANS_NONSEQ;
    end if;
        
    if r.bo = '0' then
      if r.ba = '1' then
        if ahbmi.hready = '1' then
          case ahbmi.hresp is
          when HRESP_OKAY => ready0 := '1';
          when HRESP_SPLIT | HRESP_RETRY => retry0 := '1';
          when HRESP_ERROR => error0 := '1';
          when others => null;
          end case; 
        end if;
      end if;
    else
      if r.ba = '1' then
        if ahbmi.hready = '1' then
          case ahbmi.hresp is
          when HRESP_OKAY => ready1 := '1';
          when HRESP_SPLIT | HRESP_RETRY => retry1 := '1';
          when HRESP_ERROR => error1 := '1';
          when others => null;
          end case; 
        end if;
      end if;
    end if;

    if (r.ba = '1') and 
       ((ahbmi.hresp = HRESP_RETRY) or (ahbmi.hresp = HRESP_SPLIT) or (ahbmi.hresp = HRESP_ERROR))
    then v.retry := not ahbmi.hready; else v.retry := '0'; end if;
      
    if r.retry = '1' then htrans := HTRANS_IDLE; end if;
    
    if ahbmi.hready = '1' then
      v.bo := nbo; v.bg := ahbmi.hgrant(hindex);
      if (htrans = HTRANS_NONSEQ) or (htrans = HTRANS_SEQ) then
        v.ba := r.bg;
      else
        v.ba := '0';
      end if;
    end if;

    if rst = '0' then
      v.bg := '0'; v.ba := '0'; v.bo := '0'; v.bb := '0';
    end if;
    
    rin <= v;
    dmao1.data     <= ahbreadword(ahbmi.hrdata);
    dmao0.data     <= ahbreadword(ahbmi.hrdata);
    dmao1.error    <= error1;
    dmao1.retry    <= retry1;
    dmao1.ready    <= ready1;
    dmao0.error    <= error0;
    dmao0.retry    <= retry0;
    dmao0.ready    <= ready0;
    dmao1.grant    <= grant1;
    dmao0.grant    <= grant0;
    ahbmo.htrans   <= htrans;
    ahbmo.hsize	   <= hsize;
    ahbmo.hbusreq  <= hbusreq;
    ahbmo.haddr	   <= haddr;
    ahbmo.hwrite   <= hwrite;
    ahbmo.hwdata   <= ahbdrivedata(hwdata);
    ahbmo.hburst   <= hburst;

    ahbmo.hconfig <= hconfig;
    ahbmo.hindex  <= hindex;
  end process;

  regs : process(clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process; 
 
  ahbmo.hlock	 <= '0';
  ahbmo.hprot	 <= "0011";
  ahbmo.hirq   <= (others => '0');
end architecture; 

