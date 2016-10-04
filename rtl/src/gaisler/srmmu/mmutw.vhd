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
-- Entity: 	mmutw
-- File:	mmutw.vhd
-- Author:	Konrad Eisele, Jiri Gaisler, Gaisler Research
-- Description:	MMU table-walk logic
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.mmuconfig.all;
use work.mmuiface.all;
use work.libmmu.all;

entity mmutw is
  generic ( 
    mmupgsz   : integer range 0 to 5  := 0
  );
  port (
    rst     : in  std_logic;
    clk     : in  std_logic;
    mmctrl1 : in  mmctrl_type1;
    twi     : in  mmutw_in_type;
    two     : out mmutw_out_type;
    mcmmo   : in  memory_mm_out_type;
    mcmmi   : out memory_mm_in_type
    );
end mmutw;

architecture rtl of mmutw is

  type write_buffer_type is record			-- write buffer 
    addr, data  : std_logic_vector(31 downto 0);
    read        : std_logic;
  end record;

  constant write_buffer_none : write_buffer_type := (
    addr => (others => '0'), data => (others => '0'), read => '0');
  
  type states is (idle, waitm, pte, lv1, lv2, lv3, lv4);
  type tw_rtype is record
    state       : states;
    wb          : write_buffer_type;
    req         : std_logic;
    walk_op     : std_logic;
  end record;

  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
  constant ASYNC_RESET : boolean := GRLIB_CONFIG_ARRAY(grlib_async_reset_enable) = 1;
  constant RRES : tw_rtype := (
    state   => idle,
    wb      => write_buffer_none,
    req     => '0',
    walk_op => '0');
  
  signal c,r : tw_rtype;
  
begin  

  p0: process (rst, r, twi, mcmmo, mmctrl1)
  variable v           : tw_rtype;
  variable finish      : std_logic;
  variable index       : std_logic_vector(31-2 downto 0);
  variable lvl         : std_logic_vector(1 downto 0);
  variable fault_mexc  : std_logic;
  variable fault_trans : std_logic;
  variable fault_inv   : std_logic;
  variable fault_lvl   : std_logic_vector(1 downto 0);
  variable pte,ptd,inv,rvd : std_logic;
  variable goon, found : std_logic;
  variable base        : std_logic_vector(31 downto 0);
  variable pagesize : integer range 0 to 3;
  
  begin 
    v := r;
    
    --#init
    finish := '0'; 
    index := (others => '0');
    lvl := (others => '0');
    fault_mexc := '0';
    fault_trans := '0';
    fault_inv := '0';
    fault_lvl := (others => '0');
    pte := '0';ptd := '0';inv := '0';rvd := '0';
    goon := '0'; found := '0';
    base := (others => '0'); 
    base(PADDR_PTD_U downto PADDR_PTD_D) := mcmmo.data(PTD_PTP32_U downto PTD_PTP32_D);
 
    if mcmmo.grant = '1' then
      v.req := '0';
    end if;

    if mcmmo.retry = '1' then v.req := '1'; end if;
    
    -- # pte/ptd
    if ((mcmmo.ready and not r.req)= '1') then -- context
      case mcmmo.data(PT_ET_U downto PT_ET_D) is
        when ET_INV => inv := '1';
        when ET_PTD => ptd := '1'; goon := '1';
        when ET_PTE => pte := '1'; found := '1';
        when ET_RVD => rvd := '1'; null;
        when others => null;
      end case;
    end if;      
    fault_trans := (rvd);
    fault_inv := inv;

    pagesize := MMU_getpagesize(mmupgsz,mmctrl1);
    case pagesize is
      when 1 => 
        -- 8k tag comparision [ 7 6 6 ]
      when 2 => 
        -- 16k tag comparision [ 6 6 6 ]
      when 3 => 
        -- 32k tag comparision [ 4 7 6 ]
      when others =>    -- standard 4k tag comparision [ 8 6 6 ]
    end case;
    
    -- # state machine
    case r.state is
      when idle =>
        if (twi.walk_op_ur) = '1' then
          v.walk_op := '1';
          index(M_CTX_SZ-1 downto 0) := mmctrl1.ctx;
          base := (others => '0');                              
          base(PADDR_PTD_U downto PADDR_PTD_D) := mmctrl1.ctxp(MMCTRL_PTP32_U downto MMCTRL_PTP32_D); 
          v.wb.addr := base or (index&"00");
          v.wb.read := '1';
          v.req := '1';
          v.state := lv1;
        elsif (twi.areq_ur) = '1' then
          index := (others => '0');
          v.wb.addr := twi.aaddr;
          v.wb.data := twi.adata;
          v.wb.read := '0';
          v.req := '1';
          v.state := waitm;
        end if;
      when waitm =>
        if ((mcmmo.ready and not r.req)= '1') then          -- amba: result ready current cycle
          fault_mexc := mcmmo.mexc;
          v.state := idle;
          finish := '1';
        end if;
      when lv1 =>                                               
                                                                
        if ((mcmmo.ready and not r.req)= '1') then          
          lvl := LVL_CTX; fault_lvl := FS_L_CTX;
          case pagesize is
            when 1 => 
              -- 8k tag comparision [ 7 6 6 ]
              index(P8K_VA_I1_SZ-1 downto 0) := twi.data(P8K_VA_I1_U downto P8K_VA_I1_D);       
            when 2 => 
              -- 16k tag comparision [ 6 6 6 ]
              index(P16K_VA_I1_SZ-1 downto 0) := twi.data(P16K_VA_I1_U downto P16K_VA_I1_D);       
            when 3 => 
              -- 32k tag comparision [ 4 7 6 ]
              index(P32K_VA_I1_SZ-1 downto 0) := twi.data(P32K_VA_I1_U downto P32K_VA_I1_D);       
            when others =>
              -- standard 4k tag comparision [ 8 6 6 ]
              index(VA_I1_SZ-1 downto 0) := twi.data(VA_I1_U downto VA_I1_D);       
          end case;
          v.state := lv2;
        end if;
      when lv2 =>                                               
                                                                
        if ((mcmmo.ready and not r.req)= '1') then          
          lvl := LVL_REGION; fault_lvl :=  FS_L_L1;             
          case pagesize is
            when 1 => 
              -- 8k tag comparision [ 7 6 6 ]
              index(P8K_VA_I2_SZ-1 downto 0) := twi.data(P8K_VA_I2_U downto P8K_VA_I2_D);       
            when 2 => 
              -- 16k tag comparision [ 6 6 6 ]
              index(P16K_VA_I2_SZ-1 downto 0) := twi.data(P16K_VA_I2_U downto P16K_VA_I2_D);       
            when 3 => 
              -- 32k tag comparision [ 4 7 6 ]
              index(P32K_VA_I2_SZ-1 downto 0) := twi.data(P32K_VA_I2_U downto P32K_VA_I2_D);       
            when others =>
              -- standard 4k tag comparision [ 8 6 6 ]
              index(VA_I2_SZ-1 downto 0) := twi.data(VA_I2_U downto VA_I2_D);       
          end case;
          v.state := lv3;
        end if;
      when lv3 =>                                               
                                                                
        if ((mcmmo.ready and not r.req)= '1') then          
          lvl := LVL_SEGMENT; fault_lvl := FS_L_L2;             
          case pagesize is
            when 1 => 
              -- 8k tag comparision [ 7 6 6 ]
              index(P8K_VA_I3_SZ-1 downto 0) := twi.data(P8K_VA_I3_U downto P8K_VA_I3_D);
            when 2 => 
              -- 16k tag comparision [ 6 6 6 ]
              index(P16K_VA_I3_SZ-1 downto 0) := twi.data(P16K_VA_I3_U downto P16K_VA_I3_D);
            when 3 => 
              -- 32k tag comparision [ 4 7 6 ]
              index(P32K_VA_I3_SZ-1 downto 0) := twi.data(P32K_VA_I3_U downto P32K_VA_I3_D);
            when others =>
              -- standard 4k tag comparision [ 8 6 6 ]
              index(VA_I3_SZ-1 downto 0) := twi.data(VA_I3_U downto VA_I3_D);
          end case;
          v.state := lv4;
        end if;
      when lv4 =>                                               
                                                                
        if ((mcmmo.ready and not r.req)= '1') then          
          lvl := LVL_PAGE; fault_lvl := FS_L_L3;                
          fault_trans := fault_trans or ptd;
          v.state := idle;
          finish := '1';                                          
        end if;
      when others =>
        v.state := idle;
        finish := '0';

    end case;
    base := base or (index&"00");

    if r.walk_op = '1' then
      if (mcmmo.ready and (not r.req)) = '1' then
        fault_mexc := mcmmo.mexc;
        if (( ptd and
              (not fault_mexc ) and
              (not fault_trans) and
              (not fault_inv  )) = '1') then -- tw  : break table walk?
          v.wb.addr := base;
          v.req := '1';
        else
          v.walk_op := '0';
          finish := '1';
          v.state := idle;
        end if;
      end if;
    end if;
        
    -- # reset
    if (not ASYNC_RESET) and (not RESET_ALL) and ( rst = '0' ) then
      v.state := RRES.state;
      v.req := RRES.req;
      v.walk_op := RRES.walk_op;
      v.wb.read := RRES.wb.read;
    end if;

    --# drive signals
    two.finish      <= finish;
    two.data        <= mcmmo.data;
    two.addr        <= r.wb.addr(31 downto 0);
    two.lvl         <= lvl;
    two.fault_mexc  <= fault_mexc;
    two.fault_trans <= fault_trans;
    two.fault_inv   <= fault_inv;
    two.fault_lvl   <= fault_lvl;
    
    mcmmi.address  <= r.wb.addr;
    mcmmi.data     <= r.wb.data;
    mcmmi.burst    <= '0';
    mcmmi.size     <= "10";
    mcmmi.read     <= r.wb.read;
    mcmmi.lock     <= '0';
    mcmmi.req      <= r.req;

    c <= v;
  end process p0;

  syncrregs : if not ASYNC_RESET generate
    p1: process (clk)
    begin
      if rising_edge(clk) then
        r <= c;
        if RESET_ALL and (rst = '0') then
          r <= RRES;
        end if;
      end if;
    end process p1;
  end generate;
  asyncrregs : if ASYNC_RESET generate
    p1: process (clk, rst)
    begin
      if rst = '0' then
        r <= RRES;
      elsif rising_edge(clk) then
        r <= c;
      end if;
    end process p1;
  end generate;

end rtl;

