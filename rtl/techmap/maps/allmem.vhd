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
-- Package:     allmem
-- File:        allmem.vhd
-- Author:      Jiri Gaisler Gaisler Research
-- Description: All tech specific memories
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package allmem is

  -- Xilinx

  component unisim_syncram
    generic (abits : integer := 10; dbits : integer := 8);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector((abits -1) downto 0);
      datain  : in  std_logic_vector((dbits -1) downto 0);
      dataout : out std_logic_vector((dbits -1) downto 0);
      enable  : in  std_ulogic;
      write   : in  std_ulogic
      );
  end component;

  component unisim_syncram_ecc
    generic (abits : integer := 9; dbits : integer := 32);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector(abits-1 downto 0);
      datain  : in  std_logic_vector(dbits-1 downto 0);
      dataout : out std_logic_vector(dbits-1 downto 0);
      enable  : in  std_ulogic;
      write   : in  std_ulogic;
      error   : out std_logic_vector(1 downto 0);
      errinj  : in  std_logic_vector(1 downto 0)
      );
  end component;

  component unisim_syncram_dp
    generic (abits : integer := 10; dbits : integer := 8);
    port (
      clk1     : in  std_ulogic;
      address1 : in  std_logic_vector((abits -1) downto 0);
      datain1  : in  std_logic_vector((dbits -1) downto 0);
      dataout1 : out std_logic_vector((dbits -1) downto 0);
      enable1  : in  std_ulogic;
      write1   : in  std_ulogic;
      clk2     : in  std_ulogic;
      address2 : in  std_logic_vector((abits -1) downto 0);
      datain2  : in  std_logic_vector((dbits -1) downto 0);
      dataout2 : out std_logic_vector((dbits -1) downto 0);
      enable2  : in  std_ulogic;
      write2   : in  std_ulogic
      );
  end component;

  component unisim_syncram_2p is
    generic (abits : integer := 6; dbits : integer := 8; sepclk : integer := 0;
             wrfst : integer := 0);
    port (
      rclk     : in  std_ulogic;
      renable  : in  std_ulogic;
      raddress : in  std_logic_vector((abits -1) downto 0);
      dataout  : out std_logic_vector((dbits -1) downto 0);
      wclk     : in  std_ulogic;
      write    : in  std_ulogic;
      waddress : in  std_logic_vector((abits -1) downto 0);
      datain   : in  std_logic_vector((dbits -1) downto 0));
  end component;


  component unisim_syncram64
    generic (abits : integer := 9);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector (abits -1 downto 0);
      datain  : in  std_logic_vector (63 downto 0);
      dataout : out std_logic_vector (63 downto 0);
      enable  : in  std_logic_vector (1 downto 0);
      write   : in  std_logic_vector (1 downto 0)
      );
  end component;

  component unisim_syncram_be
    generic (abits : integer := 9; dbits : integer := 32; tech : integer := 0);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector (abits -1 downto 0);
      datain  : in  std_logic_vector (dbits -1 downto 0);
      dataout : out std_logic_vector (dbits -1 downto 0);
      enable  : in  std_logic_vector (dbits/8-1 downto 0);
      write   : in  std_logic_vector(dbits/8-1 downto 0)
      );
  end component;


  -- GF12

  component gf12_syncram is
    generic (
      abits : integer;
      dbits : integer);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector (abits -1 downto 0);
      datain  : in  std_logic_vector (dbits -1 downto 0);
      dataout : out std_logic_vector (dbits -1 downto 0);
      enable  : in  std_ulogic;
      write   : in  std_ulogic);
  end component gf12_syncram;

  component gf12_syncram_2p is
    generic (
      abits : integer;
      dbits : integer);
    port (
      rclk     : in  std_ulogic;
      renable  : in  std_ulogic;
      raddress : in  std_logic_vector((abits -1) downto 0);
      dataout  : out std_logic_vector((dbits -1) downto 0);
      wclk     : in  std_ulogic;
      write    : in  std_ulogic;
      waddress : in  std_logic_vector((abits -1) downto 0);
      datain   : in  std_logic_vector((dbits -1) downto 0));
  end component gf12_syncram_2p;

  component gf12_syncram_be is
    generic (
      abits : integer;
      dbits : integer);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector(abits -1 downto 0);
      datain  : in  std_logic_vector(dbits -1 downto 0);
      dataout : out std_logic_vector(dbits -1 downto 0);
      enable  : in  std_logic_vector(dbits/8-1 downto 0);
      write   : in  std_logic_vector(dbits/8-1 downto 0));
  end component gf12_syncram_be;

  -- Inferred
  component generic_syncram
    generic (abits : integer := 10; dbits : integer := 8);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector((abits -1) downto 0);
      datain  : in  std_logic_vector((dbits -1) downto 0);
      dataout : out std_logic_vector((dbits -1) downto 0);
      write   : in  std_ulogic
      );
  end component;

  component generic_syncram_2p
    generic (abits : integer := 8; dbits : integer := 32; sepclk : integer := 0);
    port (
      rclk      : in  std_ulogic;
      wclk      : in  std_ulogic;
      rdaddress : in  std_logic_vector (abits -1 downto 0);
      wraddress : in  std_logic_vector (abits -1 downto 0);
      data      : in  std_logic_vector (dbits -1 downto 0);
      wren      : in  std_ulogic;
      q         : out std_logic_vector (dbits -1 downto 0)
      );
  end component;

  component generic_syncram_reg
    generic (abits : integer := 10; dbits : integer := 8);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector((abits -1) downto 0);
      datain  : in  std_logic_vector((dbits -1) downto 0);
      dataout : out std_logic_vector((dbits -1) downto 0);
      write   : in  std_ulogic
      );
  end component;

  component generic_syncram_2p_reg
    generic (abits : integer := 8; dbits : integer := 32; sepclk : integer := 0);
    port (
      rclk      : in  std_ulogic;
      wclk      : in  std_ulogic;
      rdaddress : in  std_logic_vector (abits -1 downto 0);
      wraddress : in  std_logic_vector (abits -1 downto 0);
      data      : in  std_logic_vector (dbits -1 downto 0);
      wren      : in  std_ulogic;
      q         : out std_logic_vector (dbits -1 downto 0)
      );
  end component;

  component generic_regfile_3p
    generic (tech   : integer := 0; abits : integer := 6; dbits : integer := 32;
             wrfst  : integer := 0; numregs : integer := 40;
             delout : integer := 0);
    port (
      wclk    : in  std_ulogic;
      waddr   : in  std_logic_vector((abits -1) downto 0);
      wdata   : in  std_logic_vector((dbits -1) downto 0);
      we      : in  std_ulogic;
      rclk    : in  std_ulogic;
      raddr1  : in  std_logic_vector((abits -1) downto 0);
      re1     : in  std_ulogic;
      rdata1  : out std_logic_vector((dbits -1) downto 0);
      raddr2  : in  std_logic_vector((abits -1) downto 0);
      re2     : in  std_ulogic;
      rdata2  : out std_logic_vector((dbits -1) downto 0);
      pre1    : out std_ulogic;
      pre2    : out std_ulogic;
      prdata1 : out std_logic_vector((dbits -1) downto 0);
      prdata2 : out std_logic_vector((dbits -1) downto 0)
      );
  end component;

  component generic_fifo
    generic (tech   : integer := 0; abits : integer := 10; dbits : integer := 32;
             sepclk : integer := 1; pfull : integer := 100; pempty : integer := 10; fwft : integer := 0);
    port (
      rclk    : in  std_logic;
      rrstn   : in  std_logic;
      wrstn   : in  std_logic;
      renable : in  std_logic;
      rfull   : out std_logic;
      rempty  : out std_logic;
      aempty  : out std_logic;
      rusedw  : out std_logic_vector(abits-1 downto 0);
      dataout : out std_logic_vector(dbits-1 downto 0);
      wclk    : in  std_logic;
      write   : in  std_logic;
      wfull   : out std_logic;
      afull   : out std_logic;
      wempty  : out std_logic;
      wusedw  : out std_logic_vector(abits-1 downto 0);
      datain  : in  std_logic_vector(dbits-1 downto 0));
  end component;

  component generic_regfile_4p
    generic (tech   : integer := 0; abits : integer := 6; dbits : integer := 32;
             wrfst  : integer := 0; numregs : integer := 40; g0addr : integer := 0;
             delout : integer := 0);
    port (
      wclk    : in  std_ulogic;
      waddr   : in  std_logic_vector((abits -1) downto 0);
      wdata   : in  std_logic_vector((dbits -1) downto 0);
      we      : in  std_ulogic;
      rclk    : in  std_ulogic;
      raddr1  : in  std_logic_vector((abits -1) downto 0);
      re1     : in  std_ulogic;
      rdata1  : out std_logic_vector((dbits -1) downto 0);
      raddr2  : in  std_logic_vector((abits -1) downto 0);
      re2     : in  std_ulogic;
      rdata2  : out std_logic_vector((dbits -1) downto 0);
      raddr3  : in  std_logic_vector((abits -1) downto 0);
      re3     : in  std_ulogic;
      rdata3  : out std_logic_vector((dbits -1) downto 0);
      pre1    : out std_ulogic;
      pre2    : out std_ulogic;
      pre3    : out std_ulogic;
      prdata1 : out std_logic_vector((dbits -1) downto 0);
      prdata2 : out std_logic_vector((dbits -1) downto 0);
      prdata3 : out std_logic_vector((dbits -1) downto 0)
      );
  end component;



end;
