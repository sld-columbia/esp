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
-- Entity: 	various
-- File:    fifo_inferred.vhd
-- Authors: Pascal Trotta
--          Andrea Gianarro - Cobham Gaisler AB
-- Description:	Behavioural fifo generators
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.">";
use ieee.std_logic_unsigned."<";
use work.gencomp.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity generic_fifo is
  generic (
    tech  : integer := 0;   -- target technology
    abits : integer := 10;  -- fifo address bits (actual fifo depth = 2**abits)
    dbits : integer := 32;  -- fifo data width
    sepclk : integer := 1;  -- 1 = asynchrounous read/write clocks, 0 = synchronous read/write clocks
    pfull : integer := 100; -- almost full threshold (max 2**abits - 3)
    pempty : integer := 10; -- almost empty threshold (min 2)
    fwft : integer := 0     -- 1 = first word fall trough mode, 0 = standard mode
  );
  port (
    rclk    : in std_logic;  -- read clock
    rrstn   : in std_logic;  -- read clock domain synchronous reset
    wrstn   : in std_logic;  -- write clock domain synchronous reset
    renable : in std_logic;  -- read enable
    rfull   : out std_logic; -- fifo full (synchronized in read clock domain)
    rempty  : out std_logic; -- fifo empty
    aempty  : out std_logic; -- fifo almost empty (depending on pempty threshold)
    rusedw  : out std_logic_vector(abits-1 downto 0);  -- fifo used words (synchronized in read clock domain)
    dataout : out std_logic_vector(dbits-1 downto 0);  -- fifo data output
    wclk    : in std_logic;  -- write clock
    write   : in std_logic;  -- write enable
    wfull   : out std_logic; -- fifo full
    afull   : out std_logic; -- fifo almost full (depending on pfull threshold)
    wempty  : out std_logic; -- fifo empty (synchronized in write clock domain)
    wusedw  : out std_logic_vector(abits-1 downto 0); -- fifo used words (synchronized in write clock domain)
    datain  : in std_logic_vector(dbits-1 downto 0)); -- fifo data input
end;

architecture rtl_fifo of generic_fifo is

  type wr_fifo_type is record
    waddr : std_logic_vector(abits downto 0);
    waddr_gray : std_logic_vector(abits downto 0);
    full : std_logic;
  end record;

  type rd_fifo_type is record
    raddr : std_logic_vector(abits downto 0);
    raddr_gray : std_logic_vector(abits downto 0);
    empty : std_logic;
  end record;

  signal wr_r, wr_rin : wr_fifo_type;
  signal rd_r, rd_rin : rd_fifo_type;
  signal wr_raddr_gray, rd_waddr_gray : std_logic_vector(abits downto 0);

begin
    
  ---------------------
  -- write clock domain
  ---------------------
  wr_comb: process(wr_r, write, wr_raddr_gray, wrstn, rd_r.raddr)
    variable wr_v : wr_fifo_type;
    variable v_wusedw : std_logic_vector(abits downto 0);
    variable v_raddr : std_logic_vector(abits downto 0);
  begin

    -- initialize fifo signals on write side
    wr_v := wr_r;
    wr_v.full := '0';
    afull <= '0';

    if sepclk = 1 then
      v_raddr := gray_decoder(wr_raddr_gray);
    else
      v_raddr := rd_r.raddr;
    end if;

    -- fifo full generation and compute wusedw
    -- decode read address coming from read clock domain
    v_wusedw := wr_r.waddr - v_raddr;
    wr_v.full := v_wusedw(abits);

    -- write fifo
    if write = '1' then
      wr_v.waddr := wr_r.waddr + 1;
    end if;

    if sepclk = 1 then
      wr_v.waddr_gray := gray_encoder(wr_v.waddr);
    end if;

    -- synchronous reset
    if wrstn = '0' then
      wr_v.waddr := (others =>'0');
      wr_v.waddr_gray := (others =>'0');
      wr_v.full := '0';
    end if;

    -- assign wusedw and almost full fifo output
    if v_wusedw > pfull then
      afull <= '1';
    end if;

    -- signal assignment
    wfull <= wr_v.full;
    wusedw <= v_wusedw(abits-1 downto 0);
    -- update fifo signals
    wr_rin <= wr_v;

  end process;

  wr_sync: process(wclk)
  begin
    if rising_edge(wclk) then
        wr_r <= wr_rin;
    end if;
  end process;


  sync_reg: if sepclk = 1 generate
    -----------------------------------
    -- sync regs for dual clock FIFO --
    -----------------------------------
    -- transfer write address (encoded) in read clock domain
    -- transfer read address (encoded) in write clock domain
    -- transfer empty in write clock domain
    -- transfer full in read block domain
    -- Note: input d is already registered in the source clock domain
    syn_gen0: for i in 0 to abits generate  -- fifo addresses
      syncreg_inst0: syncreg generic map (tech => tech, stages => 2)
        port map(clk => rclk, d => wr_r.waddr_gray(i), q => rd_waddr_gray(i));

      syncreg_inst1: syncreg generic map (tech => tech, stages => 2)
        port map(clk => wclk, d => rd_r.raddr_gray(i), q => wr_raddr_gray(i));
    end generate;

    syncreg_inst2: syncreg generic map (tech => tech, stages => 2)
      port map(clk => wclk, d => rd_r.empty, q => wempty);
    syncreg_inst3: syncreg generic map (tech => tech, stages => 2)
      port map(clk => rclk, d => wr_r.full, q => rfull);
  end generate;
  
  no_sync_reg: if sepclk = 0 generate
    ---------------------------------------
    -- single clock FIFO logic (no sync) --
    ---------------------------------------
    wempty <= rd_r.empty;
    rfull <= wr_r.full;
  end generate;

  --------------------
  -- read clock domain
  --------------------
  rd_comb: process(rd_r, renable, rd_waddr_gray, rrstn, wr_r.waddr)
    variable rd_v : rd_fifo_type;
    variable v_rusedw : std_logic_vector(abits downto 0);
    variable v_waddr : std_logic_vector(abits downto 0);
  begin
  
    -- initialize fifo signals on read side
    rd_v := rd_r;
    rd_v.empty := '0';
    aempty <= '0';

    if sepclk = 1 then
      v_waddr := gray_decoder(rd_waddr_gray);
    else
      v_waddr := wr_r.waddr;
    end if;

    -- fifo empty generation and compute rusedw fifo output
    -- decode write address coming from write clock domain
    v_rusedw := v_waddr - rd_r.raddr;
    if conv_integer(v_rusedw) = 0 then  
      rd_v.empty := '1';
    end if;

    -- read fifo
    if renable = '1' then
      rd_v.raddr := rd_r.raddr + 1;
    end if;

    if sepclk = 1 then
      rd_v.raddr_gray := gray_encoder(rd_v.raddr);
    end if;

    -- synchronous reset
    if rrstn = '0' then
      rd_v.raddr := (others =>'0');
      rd_v.raddr_gray := (others =>'0');
      rd_v.empty := '1';
    end if;

    -- assign almost empty
    if v_rusedw < pempty then
      aempty <= '1';
    end if;

    -- signal assignment
    rempty <= rd_v.empty;
    rusedw <= v_rusedw(abits-1 downto 0);
    -- update fifo signals
    rd_rin <= rd_v;

  end process;

  rd_sync: process(rclk)
  begin
    if rising_edge(rclk) then
      rd_r <= rd_rin;
    end if;
  end process;

  -- memory instantiation
  nofwft_gen: if fwft = 0 generate
    ram0 : syncram_2p generic map ( tech => tech, abits => abits, dbits => dbits, sepclk => sepclk)
      port map (rclk, renable, rd_rin.raddr(abits-1 downto 0), dataout, wclk, write, wr_rin.waddr(abits-1 downto 0), datain);
  end generate;

  fwft_gen: if fwft = 1 generate
    ram0 : syncram_2p generic map ( tech => tech, abits => abits, dbits => dbits, sepclk => sepclk)
      port map (rclk, '1', rd_rin.raddr(abits-1 downto 0), dataout, wclk, write, wr_r.waddr(abits-1 downto 0), datain);
  end generate;

end;

