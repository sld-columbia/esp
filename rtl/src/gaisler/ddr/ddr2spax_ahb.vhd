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
-- Entity:      ddr2spa_ahb
-- File:        ddr2spa_ahb.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Asynch AHB interface for DDR memory controller
--              Based on ddr2sp(16/32/64)a, generalized and expanded
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stdlib.all;
use work.amba.all;
use work.devices.all;
use work.ddrpkg.all;
use work.ddrintpkg.all;

entity ddr2spax_ahb is
   generic (
      hindex     : integer := 0;
      haddr      : integer := 0;
      hmask      : integer := 16#f00#;
      ioaddr     : integer := 16#000#;
      iomask     : integer := 16#fff#;
      burstlen   : integer := 8;
      nosync     : integer := 0;
      ahbbits    : integer := ahbdw;
      revision   : integer := 0;
      devid      : integer := GAISLER_DDR2SP;
      ddrbits    : integer := 32;
      regarea    : integer := 0
   );
   port (
      rst      : in  std_ulogic;
      clk_ahb  : in  std_ulogic;
      ahbsi    : in  ahb_slv_in_type;
      ahbso    : out ahb_slv_out_type;
      request  : out ddr_request_type;
      start_tog: out std_logic;
      response : in ddr_response_type;
      wbwaddr   : out std_logic_vector(log2(burstlen) downto 0);
      wbwdata   : out std_logic_vector(ahbbits-1 downto 0);
      wbwrite   : out std_logic;
      wbwritebig: out std_logic;
      rbraddr   : out std_logic_vector(log2(burstlen*32/ahbbits)-1 downto 0);
      rbrdata   : in std_logic_vector(ahbbits-1 downto 0);
      hwidth    : in std_logic;
      beid      : in std_logic_vector(3 downto 0)
   );  
end ddr2spax_ahb;

architecture rtl of ddr2spax_ahb is

  constant CMD_PRE  : std_logic_vector(2 downto 0) := "010";
  constant CMD_REF  : std_logic_vector(2 downto 0) := "100";
  constant CMD_LMR  : std_logic_vector(2 downto 0) := "110";
  constant CMD_EMR  : std_logic_vector(2 downto 0) := "111";

  constant ramwt: integer := 0;
  
  constant hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, DEVID, 0, REVISION, 0),
    4 => ahb_membar(haddr, '1', '1', hmask),
    5 => ahb_iobar(ioaddr, iomask),
    others => zero32);  

  function zerov(w: integer) return std_logic_vector is
    constant r: std_logic_vector(w-1 downto 0) := (others => '0');
  begin
    return r;
  end zerov;

  constant l2blen: integer := log2(burstlen)+log2(32);
  constant l2ahbw: integer := log2(ahbbits);
  constant l2ddrw: integer := log2(2*ddrbits);
  
  -- Write buffer dimensions
  -- Write buffer is addressable down to 32-bit level on write (AHB) side.
  constant wbuf_wabits: integer := 1+l2blen-5; --  log2(burstlen);
  constant wbuf_wdbits: integer := ahbbits;
  -- Read buffer dimensions
  constant rbuf_rabits: integer := l2blen-l2ahbw; -- log2(burstlen*32/ahbbits);
  constant rbuf_rdbits: integer := ahbbits;
  
  type ahbstate is (asnormal,asw1,asw2,asww1,asww2,aswr,aswwx);

  type ahb_reg_type is record
    s         : ahbstate;
    start_tog : std_logic;
    ramaddr   : std_logic_vector(l2blen-4 downto 2);
    -- These are sent to the DDR layer
    req       : ddr_request_type;
    -- Posted write following current request
    nreq      : ddr_request_type;
    -- Read flow control
    rctr_lin  : std_logic_vector(3 downto 0);
    endpos    : std_logic_vector(7 downto log2(ddrbits/4));
    block_read: std_logic_vector(1 downto 0);
    -- Current AHB control signals
    haddr     : std_logic_vector(31 downto 0);
    haddr_nonseq: std_logic_vector(9 downto 0);
    hio       : std_logic;
    hsize     : std_logic_vector(2 downto 0);
    hwrite    : std_logic;
    hburst0   : std_logic;
    -- AHB slave outputs
    so_hready : std_logic;
    -- From DDR layer
    resp1,resp2: ddr_response_type;
  end record;

  signal ar,nar    : ahb_reg_type;

begin

  ahbcomb : process(ahbsi,rst,ar,response,rbrdata,hwidth,beid)
    variable av: ahb_reg_type;
    variable va2d: ddr_request_type;
    variable so: ahb_slv_out_type;
    variable vdone: std_logic;
    variable vresp: ddr_response_type;
    variable bigsize,midsize,canburst: std_logic;
    variable inc_ramaddr: std_logic;
    variable row: std_logic_vector(14 downto 0);
    variable wbwa: std_logic_vector(wbuf_wabits-1 downto 0);
    variable wbwd: std_logic_vector(wbuf_wdbits-1 downto 0);
    variable wbw,wbwb: std_logic;
    variable rbra: std_logic_vector(rbuf_rabits-1 downto 0);
    variable ha0: std_logic_vector(31 downto 0);
    variable rend,nrend: std_logic_vector(7 downto log2(ddrbits/4));
    variable datavalid, writedone: std_logic;
    variable rctr_gray: std_logic_vector(3 downto 0);
    variable tog_start: std_logic;
    variable regdata: std_logic_vector(31 downto 0);
  begin
    ha0 := ahbsi.haddr;
    ha0(31 downto 20) := ha0(31 downto 20) and not std_logic_vector(to_unsigned(hmask,12));

    av := ar;
    so := (hready => ar.so_hready, hresp => HRESP_OKAY, hrdata => (others => '0'),
           hsplit => (others => '0'), hirq => (others => '0'),
           hconfig => hconfig, hindex => hindex);
    wbw := '0';
    wbwb := '0';
    wbwa := ar.start_tog & ar.ramaddr;
    wbwd := ahbreaddata(ahbsi.hwdata,ar.haddr(4 downto 2),
                        std_logic_vector(to_unsigned(log2(ahbbits/8),3)));
    rbra := ar.ramaddr(l2blen-4 downto l2ahbw-3);
        
    
    -- Determine whether the current hsize is a big (ahbbits-width) access
    bigsize := '0';
    if (ahbbits = 256 and ar.hsize(2)='1' and ar.hsize(0)='1') or
      (ahbbits = 128 and ar.hsize(2)='1') or
      (ahbbits = 64 and ar.hsize="011") then
      bigsize := '1';
    end if;
    midsize := '0';
    if ( (ahbbits = 256 and ((ar.hsize(2)='1' and ar.hsize(0)='0') or (ar.hsize(1 downto 0)="11"))) or
         (ahbbits = 128 and ar.hsize="011") ) then
      midsize := '1';
    end if;
    -- Determine whether sequential burst is allowed after current access
    canburst := '0';
    if (bigsize='1' and ar.haddr(l2blen-4 downto l2ahbw-3)/=(not zerov(l2blen-l2ahbw))) or
      (ar.hsize="010" and ar.haddr(l2blen-4 downto 2)/=(not zerov(l2blen-5))) then
      canburst := '1';
    end if;
--    if canburst='1' then
--      print("ar.hsize=" & tost(ar.hsize) & "ar.haddr: " & tost(ar.haddr(l2blen-4 downto 2)) & " /= " & tost(not zerov(l2blen-5)));
--    end if;
    if ar.hio='1' then
      canburst := '0';
    end if;
    
    if ahbsi.hready='1' and ahbsi.hsel(hindex)='1' and ahbsi.htrans(1)='1' then
      av.haddr := ha0;
      av.ramaddr := ha0(log2(4*burstlen)-1 downto 2);
      av.hio := ahbsi.hmbsel(1);
      av.hsize := ahbsi.hsize;
      av.hwrite := ahbsi.hwrite;
      av.hburst0 := ahbsi.hburst(0);
      if ahbsi.htrans(0)='0' or canburst='0' then
        av.haddr_nonseq := ha0(9 downto 0);
      end if;
    end if;

    
    -- Synchronize from DDR domain
    av.resp1:=response; av.resp2:=ar.resp1;
    vresp := ar.resp2;
    if nosync /= 0 then vresp := response; end if;
    vdone := vresp.done_tog;

    -- Determine whether we can read more data in burst
    datavalid := '0';
    writedone := '0';
    if ar.start_tog=vdone then
      datavalid := '1';
      writedone := '1';
    end if;

    if ar.rctr_lin="0000" then rend:=ar.haddr(7 downto l2ddrw-3); else rend:=ar.endpos; end if;
    nrend := std_logic_vector(unsigned(rend)+1);
    
    rctr_gray := lin2gray(ar.rctr_lin);
    if ar.start_tog/=vdone and rctr_gray /= vresp.rctr_gray and ar.block_read(0)='0' then
      av.rctr_lin := std_logic_vector(unsigned(ar.rctr_lin)+1);
      av.endpos := nrend;
      rend := nrend;
    end if;
    
    if 2*ddrbits > ahbbits then
      if rend /= ar.haddr(7 downto log2(ddrbits/4)) then
        datavalid := '1';
      end if;
    else
      if rend(7 downto log2(ahbbits/8)) /= ar.haddr(7 downto log2(ahbbits/8)) then
        datavalid := '1';
      end if;
      if 2*ddrbits < ahbbits and ahbbits > 32 then
        if ar.hsize="010" or ar.hsize="001" or ar.hsize="000" then
          if rend(log2(ahbbits/8)-1 downto log2(ddrbits/4)) /=
            ar.haddr(log2(ahbbits/8)-1 downto log2(ddrbits/4)) then
            datavalid := '1';
          end if;
        end if;
      end if;
    end if;

    if ar.block_read(1)='1' or (ar.start_tog/=vdone and ar.block_read(0)='1') then
      datavalid := '0';
      writedone := '0';
    end if;
    
    if ar.block_read(1)='1' and ar.start_tog/=vdone then
      av.block_read(1) := '0';
    end if;
    if ar.block_read(1)='0' and vresp.rctr_gray="0000" then
      av.block_read(0) := '0';
    end if;
    
    -- FSM
    inc_ramaddr := '0';
    tog_start := '0';
    case ar.s is
      when asnormal =>
        -- Idle and memory read state

        if ahbsi.hready='1' and ahbsi.hsel(hindex)='1' and ahbsi.htrans(1)='1' then
          -- Pass on address immediately to request for read case
          av.req := (startaddr => ha0,
                     endaddr   => ha0(9 downto 0),
                     hsize     => ahbsi.hsize,
                     hwrite    => ahbsi.hwrite,
                     hio       => ahbsi.hmbsel(1),
                     burst     => ahbsi.hburst(0),
                     maskdata  => '0', maskcb => '0');
          
          if ahbsi.hwrite='0' then
            if ahbsi.htrans(0)='0' or canburst='0' then
              av.so_hready := '0';
              tog_start := '1';
            elsif datavalid='1' then
              inc_ramaddr := '1';
            else
              av.so_hready := '0';
              -- grlib.testlib.print("Going to waitstate!");
            end if;
          else
            av.s := asw1;
          end if;
          
        end if;
        
        if ar.so_hready='0' and datavalid='1' then
          av.so_hready := '1';
          inc_ramaddr := '1';
        end if;
        
        
      when asw1 =>
        -- Transfer data for write request
        wbw := '1';
        if bigsize='1' or midsize='1' then wbwb:='1'; end if;
        av.so_hready := '1';
        av.req.endaddr := ar.haddr(9 downto 0);
        if ahbsi.hready='1' and ahbsi.hsel(hindex)='1' and ahbsi.htrans(1)='1' then
          if ahbsi.htrans(0)='0' or canburst='0' then
            if ahbsi.hwrite='1' then
              av.s := asww1;
            else
              av.so_hready := '0';
              av.s := aswr;
            end if;
            tog_start := '1';
          end if;
        else
          av.s := asw2;
          tog_start := '1';
        end if;


        
      when asw2 =>
        -- Write request ongoing
        av.so_hready := '1';
        if ahbsi.hready='1' and ahbsi.hsel(hindex)='1' and ahbsi.htrans(1)='1' then
          if ahbsi.hwrite='1' then
            av.s := asww1;
          else
            av.so_hready := '0';
            av.s := aswr;
          end if;
        elsif writedone='1' then
          av.s := asnormal;          
        end if;


        
      when asww1 =>
        -- Transfer data for second write while write request ongoing
        wbw := '1';
        if bigsize='1' or midsize='1' then wbwb:='1'; end if;
        av.so_hready := '1';
        av.nreq := (startaddr => ar.haddr(31 downto 10) & ar.haddr_nonseq(9 downto 0),
                    endaddr   => ar.haddr(9 downto 0),
                    hsize     => ar.hsize,
                    hwrite    => ar.hwrite,
                    hio       => ar.hio,
                    burst     => ar.hburst0,
                    maskdata  => '0', maskcb => '0');
        if ahbsi.hready='1' and ahbsi.hsel(hindex)='1' and ahbsi.htrans(1)='1' then
          if ahbsi.htrans(0)='0' or canburst='0' then
            av.so_hready := '0';
            av.s := aswwx;
          end if;
        else
          av.s := asww2;
        end if;
        
      when asww2 =>
        -- Second write enqueued, wait for first write to finish
        -- Any new request here will cause HREADY to go low
        av.so_hready := '1';
        if ahbsi.hready='1' and ahbsi.hsel(hindex)='1' and ahbsi.htrans(1)='1' then
          av.so_hready := '0';
          av.s := aswwx;
        elsif writedone='1' then
          av.req := ar.nreq;
          tog_start := '1';
          av.s := asw2;
        end if;

      when aswr =>
        -- Read request following ongoing write request
        -- HREADY is low in this state
        av.so_hready := '0';
        if writedone='1' then
          av.req := (startaddr => ar.haddr(31 downto 10) & ar.haddr_nonseq(9 downto 0),
                     endaddr   => ar.haddr(9 downto 0),
                     hsize     => ar.hsize,
                     hwrite    => ar.hwrite,
                     hio       => ar.hio,
                     burst     => ar.hburst0,
                     maskdata  => '0', maskcb => '0');
          av.hwrite := '0';
          tog_start := '1';
          av.s := asnormal;
        end if;

      when aswwx =>
        -- Write ongoing + write posted + another AHB request (read or write)
        -- Keep HREADY low
        av.so_hready := '0';
        if writedone='1' then
          tog_start := '1';
          av.req := ar.nreq;
          if ar.hwrite='1' then
            av.nreq := (startaddr => ar.haddr(31 downto 10) & ar.haddr_nonseq(9 downto 0),
                        endaddr   => ar.haddr(9 downto 0),
                        hsize     => ar.hsize,
                        hwrite    => ar.hwrite,
                        hio       => ar.hio,
                        burst     => ar.hburst0,
                        maskdata  => '0', maskcb => '0');
            av.so_hready := '1';
            av.s := asww1;
          else
            av.s := aswr;
          end if;
        end if;

        
    end case;

    if tog_start='1' and (regarea=0 or av.req.hio='0' or av.req.startaddr(5)='0') then
      av.start_tog := not ar.start_tog;
      av.rctr_lin := "0000";
      if ar.start_tog /= vdone then
        av.block_read(1) := '1';
      end if;
      av.block_read(0) := '1';
    end if;
      
    if inc_ramaddr='1' then
      if bigsize='1' then
        av.ramaddr(log2(4*burstlen)-1 downto log2(ahbbits/8)) :=
          std_logic_vector(unsigned(ar.ramaddr(log2(4*burstlen)-1 downto log2(ahbbits/8)))+1);
      else
        av.ramaddr(log2(4*burstlen)-1 downto 2) :=
          std_logic_vector(unsigned(ar.ramaddr(log2(4*burstlen)-1 downto 2))+1);
      end if;
    end if;

    -- Used only if regarea /= 0
    regdata := (others => '0');
    regdata(18 downto 16) := std_logic_vector(to_unsigned(log2(ddrbits/8),3));
    if hwidth/='0' then
      regdata(18 downto 16) := std_logic_vector(to_unsigned(log2(ddrbits/16),3));
    end if;
    regdata(15 downto 12) := beid;

    -- If we are using AMBA-compliant data muxing, nothing needs to be done to
    -- the hrdata vector. Otherwise, we need to duplicate 32-bit lanes
    if regarea/=0 and ar.req.hio='1' and ar.req.startaddr(5)='1' then
      so.hrdata := ahbdrivedata(regdata);
    elsif CORE_ACDM /= 0 then
      so.hrdata := ahbdrivedata(rbrdata);
    else
      so.hrdata := ahbselectdata(ahbdrivedata(rbrdata),ar.haddr(4 downto 2),ar.hsize);
    end if;

    if rst='0' then
      av.s := asnormal;
      av.block_read := "00";
      av.start_tog := '0';
      av.so_hready := '1';
      so.hready := '1';
      so.hresp := HRESP_OKAY;      
    end if;

    if l2blen-l2ddrw < 4 then
      av.rctr_lin(3 downto l2blen-l2ddrw) := (others => '0');
    end if;
    
    nar        <= av;
    request    <= ar.req;
    start_tog  <= ar.start_tog;
    ahbso      <= so;
    wbwrite    <= wbw;
    wbwritebig <= wbwb;
    wbwaddr    <= wbwa;
    wbwdata    <= wbwd;
    rbraddr    <= rbra;
  end process;
                    
  ahbregs : process(clk_ahb)
  begin
    if rising_edge(clk_ahb) then
      ar <= nar;
    end if;
  end process;

end;

