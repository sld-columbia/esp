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
-- Package: 	gencomp
-- File:	gencomp.vhd
-- Author:	Jiri Gaisler et al. - Aeroflex Gaisler
-- Description:	Declaration of portable memory modules, pads, e.t.c.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.config.grlib_config_array;
use work.config_types.grlib_techmap_testin_extra;

package gencomp is

---------------------------------------------------------------------------
-- BASIC DECLARATIONS
---------------------------------------------------------------------------

-- technologies and libraries

constant NTECH : integer := 4;
type tech_ability_type is array (0 to NTECH) of integer;

constant inferred    : integer := 0;
constant virtex7     : integer := 1;
constant virtexup    : integer := 2;
constant virtexu     : integer := 3;
constant gf12        : integer := 4;

constant DEFMEMTECH  : integer := inferred;
constant DEFPADTECH  : integer := inferred;
constant DEFFABTECH  : integer := inferred;

constant is_fpga : tech_ability_type :=
	(inferred => 1, virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant infer_mul : tech_ability_type := is_fpga;

-- The write_through and dest_rw_collision tables should be set up
-- depending on how the raw memory cells behave on simultaneous read
-- and write to the same address:
--  write_through rw_collision  | read-result     write-result
--       0             0        | undefined       success
--       1             0        | new write-data  success
--       0             1        | undefined       wrong data written
--
-- If the write-through behavior is required by the IP, then set wrfst
-- on the syncram_2p instantiation and the syncram wrapper will add logic to
-- implement this if needed. The wrapper will also avoid simulatneous
-- read/write if rw_collision is set but this can only be done when the
-- read/write ports are known to be in the same clock domain (sepclk=0),
-- otherwise this requirement has to be managed at higher level.

constant syncram_2p_write_through : tech_ability_type :=
	(others => 0);

constant regfile_3p_write_through : tech_ability_type :=
	(others => 0);

constant regfile_3p_infer : tech_ability_type :=
	(inferred => 1, others => 0);

constant syncram_2p_dest_rw_collision : tech_ability_type :=
        (others => 0);

constant syncram_dp_dest_rw_collision : tech_ability_type :=
        (others => 0);

-- The readhold table should be set to 1 if the techology mapping's
-- memory blocks keep the read-data bus stable at it's current value
-- when enable/renable is clocked in low any number of cycles after
-- a read.

constant syncram_readhold : tech_ability_type :=
        (others => 0);

constant syncram_2p_readhold : tech_ability_type :=
        (others => 0);

constant syncram_dp_readhold : tech_ability_type :=
        (others => 0);

constant regfile_3p_readhold : tech_ability_type :=
        (others => 0);

constant syncram_has_customif : tech_ability_type := (others => 0);
constant syncram_customif_maxwidth: integer := 64;  -- Expand as needed

-- Set to 1 to add input-to-output bypass logic during scan mode in the syncram
-- wrappers.
constant syncram_add_scan_bypass : tech_ability_type :=
        (others => 0);

constant has_sram : tech_ability_type :=
	(others => 1);

constant has_2pram : tech_ability_type :=
	(others => 1);

constant has_dpram : tech_ability_type :=
	(virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_sram64 : tech_ability_type :=
	(inferred => 0, virtex7 => 1, virtexup => 1, virtexu => 1, gf12 => 1, others => 0);

constant has_sram128bw : tech_ability_type :=
	(virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_sram128 : tech_ability_type :=
	(virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_sram156bw : tech_ability_type :=
	(virtex7 => 0, virtexup => 1, virtexu => 1, others => 0);

constant has_sram256bw : tech_ability_type :=
	(virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_sram_2pbw : tech_ability_type :=
        (others => 0);

constant has_srambw : tech_ability_type :=
	(virtex7 => 1, virtexup => 1, virtexu => 1, gf12 => 1, others => 0);

constant has_2pfifo : tech_ability_type :=
        (others => 0);

-- ram_raw_latency - describes how many edges on the write-port clock that
-- must pass before data is commited to memory. for example, if the write data
-- is commited to memory on the falling edge after a write cycle, and is
-- available to the read port after a short T_{raw} then ram_raw_latency
-- should be set to 1. If the data is available to the read port immediately
-- after the write-port clock rising edge that latches the write operation then
-- ram_raw_latency(tech) should return 0. If T_{raw} cannot be assumed to be
-- negligible (for instance, it is longer than a clock cycle on the read port)
-- then the ram_raw_latency value should be increased to cover also T_{raw}.
-- this value is important for cores that use DP or 2P memories in CDC.
constant ram_raw_latency : tech_ability_type :=
        (others => 0);

-- Support for target (memory) technology FT features
-- has_sram_ecc(tech) = 1 -> target tech has SECDED capabilities for SRAM
constant has_sram_ecc :  tech_ability_type :=
        (virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant padoen_polarity : tech_ability_type :=
        (gf12 => 1, others => 0);

constant has_pads : tech_ability_type :=
	(inferred => 0, virtex7 => 1, virtexup => 1, virtexu => 1, gf12 => 1, others => 0);

constant has_ds_pads : tech_ability_type :=
	(inferred => 0, virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_ds_combo : tech_ability_type :=
	(others => 0);

constant has_tm_pads : tech_ability_type :=
        (others => 0);

constant has_clkand : tech_ability_type :=
	(virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_clkmux : tech_ability_type :=
	(virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_clkinv : tech_ability_type :=
	(others => 0);

constant has_techbuf : tech_ability_type :=
        (virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_tapsel : tech_ability_type :=
        (virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant tap_tck_gated : tech_ability_type :=
        (others => 0);

constant need_extra_sync_reset : tech_ability_type :=
	(gf12 => 1, others => 0);

constant is_unisim : tech_ability_type :=
        (virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_tap : tech_ability_type :=
	(inferred => 0, virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);

constant has_clkgen : tech_ability_type :=
	(inferred => 0, virtex7 => 1, virtexup => 1, virtexu => 1, others => 0);


constant has_ddr2phy: tech_ability_type :=
       (inferred => 0, virtex7 => 1, others => 0);

constant ddr2phy_builtin_pads: tech_ability_type :=
       (others => 0);

constant ddr2phy_has_fbclk: tech_ability_type :=
       (inferred => 1, others => 0);

constant ddrphy_has_fbclk: tech_ability_type :=
       (others => 0);

constant ddr2phy_has_reg: tech_ability_type :=
       (others => 0);

constant ddr2phy_dis_caslat: tech_ability_type :=
      (others => 0);

constant ddr2phy_dis_init: tech_ability_type :=
      (others => 0);

constant ddr2phy_has_custom: tech_ability_type :=
      (others => 0);

constant ddr2phy_refclk_type: tech_ability_type :=
      (virtex7 => 1, others => 0);                              -- 0: None

constant ddr2phy_has_datavalid: tech_ability_type :=
      (others => 0);

constant ddrphy_has_datavalid: tech_ability_type :=
      (others => 0);

constant ddrphy_builtin_pads: tech_ability_type :=
      (inferred => 0, others => 1);

constant ddrphy_latency: tech_ability_type :=
      (inferred => 1, others => 0);

-- If the PHY passes through the control signals directly to the pads
-- and therefore needs them to be set asynchronously at reset
constant ddr2phy_ptctrl: tech_ability_type :=
     (inferred => 1, others => 0);

constant ddrphy_ptctrl: tech_ability_type :=
     (inferred => 1, others => 0);

constant has_syncreg: tech_ability_type :=
     (inferred => 0, others => 0);

constant has_pll : tech_ability_type :=
     (virtex7 => 1, virtexup => 1, virtexu => 1,  others => 0);

constant has_dco : tech_ability_type :=
     (gf12 => 1, others => 0);

-- pragma translate_off

subtype tech_description is string(1 to 10);

type tech_table_type is array (0 to NTECH) of tech_description;
-------------------------------------------------------------------------------
constant tech_table : tech_table_type := (
  inferred  => "inferred  ", virtex7   => "virtex7   ",
  virtexup  => "virtexup  ", virtexu   => "virtexu   ",
  gf12      => "gf12      ");

-- pragma translate_on

-- input/output voltage

constant x12v      : integer := 12;
constant x15v      : integer := 15;
constant x18v      : integer := 1;
constant x25v      : integer := 2;
constant x33v      : integer := 3;
constant x50v      : integer := 5;

-- input/output levels

constant ttl      : integer := 0;
constant cmos     : integer := 1;
constant pci33    : integer := 2;
constant pci66    : integer := 3;
constant lvds     : integer := 4;
constant sstl2_i  : integer := 5;
constant sstl2_ii : integer := 6;
constant sstl3_i  : integer := 7;
constant sstl3_ii : integer := 8;
constant sstl18_i : integer := 9;
constant sstl18_ii: integer := 10;
constant lvpecl   : integer := 11;
constant sstl     : integer := 12;

-- pad types

constant normal   : integer := 0;
constant pullup   : integer := 1;
constant pulldown : integer := 2;
constant opendrain: integer := 3;
constant schmitt  : integer := 4;
constant dci      : integer := 5;

-- transceivers types
-- Xilinx transceiver type and channel number
constant GTP0     : integer := 0;
constant GTP1     : integer := 1;
constant GTP2     : integer := 2;
constant GTP3     : integer := 3;
constant GTX0     : integer := 16;
constant GTX1     : integer := 17;
constant GTX2     : integer := 18;
constant GTX3     : integer := 19;
constant GTH0     : integer := 32;
constant GTH1     : integer := 33;
constant GTH2     : integer := 34;
constant GTH3     : integer := 35;
-- Microsemi transceiver type
constant m075     : integer := 14; -- values represent the length of the paddr field of serdes APB interface
constant m010     : integer := 13;

-------------------------------------------------------------------------------
-- Clocking
-------------------------------------------------------------------------------

  -- PLL
  component pll
    generic (
      tech : integer);
    port (
      plllock   : out std_ulogic;
      pllouta   : out std_ulogic;
      reset     : in  std_ulogic;
      divchange : in  std_ulogic;
      rangea    : in  std_logic_vector(4 downto 0);
      refclk    : in  std_ulogic;
      pllbypass : in  std_ulogic;
      stopclka  : in  std_ulogic;
      framestop : in  std_ulogic;
      locksel   : in  std_ulogic;
      lftune    : in  std_logic_vector(40 downto 0);
      startup   : in  std_logic_vector(1 downto 0);
      locktune  : in  std_logic_vector(4 downto 0);
      vergtune  : in  std_logic_vector(2 downto 0));
  end component;

  component dco is
    generic (
      tech : integer;
      enable_div2 : integer range 0 to 1;
      dlog : integer range 0 to 15);
    port (
      rstn     : in  std_ulogic;
      ext_clk  : in  std_logic;
      en       : in  std_ulogic;
      clk_sel  : in  std_ulogic;
      cc_sel   : in  std_logic_vector(5 downto 0);
      fc_sel   : in  std_logic_vector(5 downto 0);
      div_sel  : in  std_logic_vector(2 downto 0);
      freq_sel : in  std_logic_vector(1 downto 0);
      clk      : out std_logic;
      clk_div  : out std_logic;
      clk_div2 : out std_logic;
      clk_div2_90 : out std_logic;
      lock     : out std_ulogic);
  end component dco;

---------------------------------------------------------------------------
-- MEMORY
---------------------------------------------------------------------------

  -- testin vector is testen & scanen & (tech-dependent...)
  constant TESTIN_WIDTH : integer := 4 + GRLIB_CONFIG_ARRAY(grlib_techmap_testin_extra);
  constant testin_none : std_logic_vector(TESTIN_WIDTH-1 downto 0) := (others => '0');

  -- Used for mbist support via customin/out on cores that support it
  constant memtest_vlen: integer := 16;
  subtype memtest_vector is std_logic_vector(memtest_vlen-1 downto 0);
  type memtest_vector_array is array(natural range <>) of memtest_vector;

-- synchronous single-port ram
  component syncram
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	testen : integer := 0; custombits : integer := 1);
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic;
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

-- synchronous two-port ram (1 read, 1 write port)
  component syncram_2p
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0; testen : integer := 0;
	words : integer := 0; custombits : integer := 1);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

-- synchronous dual-port ram (2 read/write ports)
  component syncram_dp
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	testen : integer := 0; custombits : integer := 1; sepclk: integer := 1;
           wrfst : integer := 0);
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic;
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

-- synchronous 3-port regfile (2 read, 1 write port)
  component regfile_3p
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
           wrfst : integer := 0; numregs : integer := 64; testen : integer := 0;
           custombits : integer := 1);
  port (
    wclk   : in  std_ulogic;
    waddr  : in  std_logic_vector((abits -1) downto 0);
    wdata  : in  std_logic_vector((dbits -1) downto 0);
    we     : in  std_ulogic;
    rclk   : in  std_ulogic;
    raddr1 : in  std_logic_vector((abits -1) downto 0);
    re1    : in  std_ulogic;
    rdata1 : out std_logic_vector((dbits -1) downto 0);
    raddr2 : in  std_logic_vector((abits -1) downto 0);
    re2    : in  std_ulogic;
    rdata2 : out std_logic_vector((dbits -1) downto 0);
    ce1    : out std_ulogic;
    ce2    : out std_ulogic;
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

-- 64-bit synchronous single-port ram with 32-bit write strobe
  component syncram64
  generic (tech : integer := 0; abits : integer := 6; testen : integer := 0;
	   paren : integer := 0; custombits : integer := 1);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63+8*paren downto 0);
    dataout : out std_logic_vector (63+8*paren downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0);
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

-- 128-bit synchronous single-port ram with 32-bit write strobe
  component syncram128
  generic (tech : integer := 0; abits : integer := 6; testen : integer := 0;
	   paren : integer := 0; custombits : integer := 1);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127+16*paren downto 0);
    dataout : out std_logic_vector (127+16*paren downto 0);
    enable  : in  std_logic_vector (3 downto 0);
    write   : in  std_logic_vector (3 downto 0);
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

  component syncramft
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	ft : integer range 0 to 5 := 0; testen : integer := 0; custombits : integer := 1 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    write    : in std_ulogic;
    enable   : in std_ulogic;
    error    : out std_logic_vector((((dbits+7)/8)-1)*(1-ft/4)+ft/4 downto 0);
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none;
    errinj   : in std_logic_vector(((dbits + 7)/8)*2-1 downto 0) := (others => '0')
    );
  end component;

  component syncram_2pft
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0; ft : integer := 0;
        testen : integer := 0; words : integer := 0; custombits : integer := 1);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    error    : out std_logic_vector((((dbits+7)/8)-1)*(1-ft/4)+ft/4 downto 0);
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none;
    errinj   : in std_logic_vector((((dbits + 7)/8)*2-1)*(1-ft/4)+(6*(ft/4)) downto 0) := (others => '0')
    );
  end component;

  component syncram128bw
  generic (tech : integer := 0; abits : integer := 6; testen : integer := 0; custombits : integer := 1);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (15 downto 0);
    write   : in  std_logic_vector (15 downto 0);
    testin  : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

  component syncram156bw
  generic (tech : integer := 0; abits : integer := 6; testen : integer := 0; custombits : integer := 1);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (155 downto 0);
    dataout : out std_logic_vector (155 downto 0);
    enable  : in  std_logic_vector (15 downto 0);
    write   : in  std_logic_vector (15 downto 0);
    testin  : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

  component syncram256bw is
  generic (tech : integer := 0; abits : integer := 6; testen : integer := 0; custombits : integer := 1);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (255 downto 0);
    dataout : out std_logic_vector (255 downto 0);
    enable  : in  std_logic_vector (31 downto 0);
    write   : in  std_logic_vector (31 downto 0);
    testin  : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

  component syncrambw
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
    testen : integer := 0; custombits : integer := 1; large_banks : integer := 0);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits-1 downto 0);
    datain  : in  std_logic_vector (dbits-1 downto 0);
    dataout : out std_logic_vector (dbits-1 downto 0);
    enable  : in  std_logic_vector (dbits/8-1 downto 0);
    write   : in  std_logic_vector (dbits/8-1 downto 0);
    testin  : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

  component syncram_2pbw
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0; testen : integer := 0;
	words : integer := 0; custombits : integer := 1);
  port (
    rclk     : in std_ulogic;
    renable  : in std_logic_vector((dbits/8-1) downto 0);
    raddress : in std_logic_vector((abits-1) downto 0);
    dataout  : out std_logic_vector((dbits-1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_logic_vector((dbits/8-1) downto 0);
    waddress : in std_logic_vector((abits-1) downto 0);
    datain   : in std_logic_vector((dbits-1) downto 0);
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
  end component;

  component syncrambwft is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
    ft : integer range 0 to 3 := 0; testen : integer := 0; custombits : integer := 1);
  port (
    clk       : in  std_ulogic;
    address   : in  std_logic_vector (abits-1 downto 0);
    datain    : in  std_logic_vector (dbits-1 downto 0);
    dataout   : out std_logic_vector (dbits-1 downto 0);
    enable    : in  std_logic_vector (dbits/8-1 downto 0);
    write     : in  std_logic_vector (dbits/8-1 downto 0);
    error     : out std_logic_vector (dbits/8-1 downto 0);
    testin    : in  std_logic_vector (TESTIN_WIDTH-1 downto 0) := testin_none;
    errinj    : in  std_logic_vector((dbits/8)*2-1 downto 0) := (others => '0')
    );
  end component;

  component from is
    generic (
      timingcheckson:   boolean := True;
      instancepath:     string  := "*";
      xon:              boolean := False;
      msgon:            boolean := True;
      data_x:           integer := 1;
      memoryfile:       string  := "";
      progfile:         string  := "");
   port (
      clk:        in    std_ulogic;
      addr:       in    std_logic_vector(6 downto 0);
      data:       out   std_logic_vector(7 downto 0));
  end component;

  component syncfifo_2p is
    generic (
      tech  : integer := 0;
      abits : integer := 6;
      dbits : integer := 8;
      sepclk : integer := 1;  -- 1 = asynchronous, 0 = synchronous
      pfull : integer := 100; -- almost full threshold
      pempty : integer := 10; -- almost empty threshold
      fwft : integer := 0     -- 0 = standard fifo mode, 1 = first word-fall through mode
    );
    port (
      rclk    : in std_logic;
      rrstn   : in std_logic;  -- synchronous reset (read domain)
      wrstn   : in std_logic;  -- synchronous reest (write domain)
      renable : in std_logic;
      rfull   : out std_logic;
      rempty  : out std_logic;
      aempty  : out std_logic;
      rusedw  : out std_logic_vector(abits-1 downto 0);
      dataout : out std_logic_vector(dbits-1 downto 0);
      wclk    : in std_logic;
      write   : in std_logic;
      wfull   : out std_logic;
      afull   : out std_logic;
      wempty  : out std_logic;
      wusedw  : out std_logic_vector(abits-1 downto 0);
      datain  : in std_logic_vector(dbits-1 downto 0));
  end component;

---------------------------------------------------------------------------
-- PADS
---------------------------------------------------------------------------

component inpad
  generic (tech : integer := 0; level : integer := 0;
	voltage : integer := x33v; filter : integer := 0;
	strength : integer := 0; loc : std_logic := '0');
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component inpadv
  generic (tech : integer := 0; level : integer := 0;
	   voltage : integer := x33v; width : integer := 1;
           filter : integer := 0; strength : integer := 0;
           loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end component;

component iopad
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0; filter : integer := 0; loc : std_logic := '0');
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component iopadien
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0; filter : integer := 0; loc : std_logic := '0');
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic; ien : in std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component iopadv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	   oepol : integer := 0; filter : integer := 0; loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_ulogic;
    o   : out std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component iopadienv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
           voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	   oepol : integer := 0; filter : integer := 0; loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0);
    ien : in  std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component iopadvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0; filter : integer := 0; loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000"
  );
end component;

component iopadvvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0; filter : integer := 0; loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(width*20 - 1 downto 0) := (others => '0')
  );
end component;

component iodpad
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0; loc : std_logic := '0');
  port (pad : inout std_ulogic; i : in std_ulogic; o : out std_ulogic);
end component;

component iodpadv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	   oepol : integer := 0; loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end component;

component outpad
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12; loc : std_logic := '0');
  port (pad : out std_ulogic; i : in std_ulogic;
  cfgi : in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component outpadv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12; width : integer := 1; loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : out std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    cfgi: in  std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component outpadvvv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12; width : integer := 1; loc : std_logic_vector := (31 downto 0 => '0'));
  port (
    pad : out std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(width*20 - 1 downto 0) := (others => '0'));
end component;

component odpad
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component odpadv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	   oepol : integer := 0);
  port (
    pad : out std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component toutpad
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component toutpadv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	   oepol : integer := 0);
  port (
    pad : out std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_ulogic;
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component toutpadvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0);
  port (
    pad : out std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component toutpad_ds
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0);
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end component;

component toutpad_dsv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	   oepol : integer := 0);
  port (
    padp : out std_logic_vector(width-1 downto 0);
    padn : out std_logic_vector(width-1 downto 0);
    i    : in  std_logic_vector(width-1 downto 0);
    en   : in  std_ulogic);
end component;

component toutpad_dsvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0);
  port (
    padp : out std_logic_vector(width-1 downto 0);
    padn : out std_logic_vector(width-1 downto 0);
    i    : in  std_logic_vector(width-1 downto 0);
    en   : in  std_logic_vector(width-1 downto 0));
end component;

component skew_outpad
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12; skew : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic; rst : in std_ulogic;
        o : out std_ulogic);
end component;

component clkpad
  generic (tech : integer := 0; level : integer := 0;
	   voltage : integer := x33v; arch : integer := 0;
	   hf : integer := 0; filter : integer := 0; loc : std_logic := '0');
  port (pad : in std_ulogic; o : out std_ulogic; rstn : std_ulogic := '1'; lock : out std_ulogic);
end component;

component inpad_ds
  generic (tech : integer := 0; level : integer := lvds; voltage : integer := x33v; term : integer := 0);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component clkpad_ds
  generic (tech : integer := 0; level : integer := lvds; voltage : integer := x33v; term : integer := 0);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end component;

component inpad_dsv
  generic (tech : integer := 0; level : integer := lvds;
	   voltage : integer := x33v; width : integer := 1; term : integer := 0);
  port (
    padp : in  std_logic_vector(width-1 downto 0);
    padn : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end component;

component iopad_ds
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0; term : integer := 0);
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end component;

component iopad_dsv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0);
  port (
    padp, padn : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_ulogic;
    o   : out std_logic_vector(width-1 downto 0));
end component;

component iopad_dsvv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0);
  port (
    padp, padn : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end component;

component outpad_ds
  generic (tech : integer := 0; level : integer := lvds;
	voltage : integer := x33v; oepol : integer := 0; slew : integer := 0);
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end component;

component outpad_dsv
  generic (tech : integer := 0; level : integer := lvds;
	voltage : integer := x33v; width : integer := 1; slew : integer := 0);
  port (
    padp : out std_logic_vector(width-1 downto 0);
    padn : out std_logic_vector(width-1 downto 0);
    i, en: in  std_logic_vector(width-1 downto 0));
end component;

component lvds_combo  is
  generic (tech : integer := 0; voltage : integer := 0; width : integer := 1;
		oepol : integer := 0; term : integer := 0);
  port (odpadp, odpadn, ospadp, ospadn : out std_logic_vector(0 to width-1);
        odval, osval, en : in std_logic_vector(0 to width-1);
	idpadp, idpadn, ispadp, ispadn : in std_logic_vector(0 to width-1);
	idval, isval : out std_logic_vector(0 to width-1);
        powerdown : in std_logic_vector(0 to width-1) := (others => '0');
        powerdownrx : in std_logic_vector(0 to width-1) := (others => '0');
	lvdsref : in std_logic := '1'; lvdsrefo : out std_logic
  );
end component;

component iopad_tm
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0; filter : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic;
        test: in std_ulogic; ti, ten: in std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component iopad_tmvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0; filter : integer := 0);
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0);
    test: in  std_ulogic;
    ti  : in  std_logic_vector(width-1 downto 0);
    ten : in  std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000"
  );
end component;

component toutpad_tm
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic;
        test: in std_ulogic; ti, ten: in std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component toutpad_tmvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0);
  port (
    pad : out std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    test: in  std_ulogic;
    ti  : in  std_logic_vector(width-1 downto 0);
    ten : in  std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;



-------------------------------------------------------------------------------
-- DDR PADS (bundles PAD and DDR register(s))
-------------------------------------------------------------------------------

component inpad_ddr
  generic (tech : integer := 0; level : integer := 0; voltage : integer := x33v;
           filter : integer := 0; strength : integer := 0 );
  port (pad : in std_ulogic; o1, o2 : out std_ulogic; c1, c2 : in std_ulogic;
        ce : in std_ulogic; r : in std_ulogic; s : in std_ulogic);
end component;

component inpad_ddrv
  generic (tech : integer := 0; level : integer := 0; voltage : integer := 0;
           filter : integer := 0; strength : integer := 0; width : integer := 1);
  port (pad : in std_logic_vector(width-1 downto 0);
        o1, o2 : out std_logic_vector(width-1 downto 0); c1, c2 : in std_ulogic;
        ce : in std_ulogic; r: in std_ulogic; s : in  std_ulogic);
end component;

component outpad_ddr
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
           voltage : integer := x33v; strength : integer := 12);
  port (pad : out std_ulogic; i1, i2 : in std_ulogic; c1, c2 : in std_ulogic;
        ce : in  std_ulogic; r : in std_ulogic; s : in std_ulogic);
end component;

component outpad_ddrv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
           voltage : integer := 0; strength : integer := 12;
           width : integer := 1);
  port (pad  : out std_logic_vector(width-1 downto 0);
        i1, i2 : in std_logic_vector(width-1 downto 0);
        c1, c2 : in std_ulogic; ce : in std_ulogic;
        r : in std_ulogic; s : in std_ulogic);
end component;

component iopad_ddr
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
           voltage : integer := x33v; strength : integer := 12;
           oepol : integer := 0);
  port (pad : inout std_ulogic; i1, i2 : in std_ulogic; en : in  std_ulogic;
        o1, o2 : out std_ulogic; c1, c2 : in  std_ulogic; ce : in  std_ulogic;
        r : in  std_ulogic; s : in  std_ulogic);
end component;

component iopad_ddrv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
           voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	   oepol : integer := 0);
  port (pad : inout std_logic_vector(width-1 downto 0);
        i1, i2 : in  std_logic_vector(width-1 downto 0); en : in std_ulogic;
        o1, o2 : out std_logic_vector(width-1 downto 0); c1, c2 : in std_ulogic;
        ce : in std_ulogic; r : in std_ulogic; s : in std_ulogic);
end component;

component iopad_ddrvv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
           voltage : integer := x33v; strength : integer := 12; width : integer := 1;
           oepol : integer := 0);
  port (pad : inout std_logic_vector(width-1 downto 0);
        i1, i2 : in std_logic_vector(width-1 downto 0);
        en : in std_logic_vector(width-1 downto 0);
        o1, o2 : out std_logic_vector(width-1 downto 0); c1, c2 : in std_ulogic;
        ce : in std_ulogic; r : in std_ulogic; s : in std_ulogic);
end component;

---------------------------------------------------------------------------
-- BUFFERS
---------------------------------------------------------------------------

  component techbuf is
    generic(
      buftype  :  integer range 0 to 6 := 0;
      tech     :  integer range 0 to NTECH := inferred);
    port(
      i        :  in  std_ulogic;
      o        :  out std_ulogic
    );
  end component;

---------------------------------------------------------------------------
-- CLOCK GENERATION
---------------------------------------------------------------------------

type clkgen_in_type is record
  pllref  : std_logic;			-- optional reference for PLL
  pllrst  : std_logic;			-- optional reset for PLL
  pllctrl : std_logic_vector(1 downto 0);  -- optional control for PLL
  clksel  : std_logic_vector(1 downto 0);  -- optional clock select
end record;

type clkgen_out_type is record
  clklock : std_logic;
  pcilock : std_logic;
end record;

component clkgen
  generic (
    tech     : integer := DEFFABTECH;
    clk_mul  : integer := 1;
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    noclkfb  : integer := 1;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;
    clk2xen  : integer := 0;
    clksel   : integer := 0;             -- enable clock select
    clk_odiv : integer := 1;            -- Proasic3/Fusion output divider clkA
    clkb_odiv: integer := 0;            -- Proasic3/Fusion output divider clkB
    clkc_odiv: integer := 0);           -- Proasic3/Fusion output divider clkC
port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- 2x clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type;
    clk4x   : out std_logic;			-- 4x clock
    clk1xu  : out std_logic;			-- unscaled 1X clock
    clk2xu  : out std_logic;			-- unscaled 2X clock
    clkb    : out std_logic;            -- Proasic3/Fusion clkB
    clkc    : out std_logic;            -- Proasic3/Fusion clkC
    clk8x   : out std_logic);           -- 8x clock
end component;

component clkand
  generic( tech : integer := 0;
           ren  : integer range 0 to 1 := 0); -- registered enable
  port(
    i      :  in  std_ulogic;
    en     :  in  std_ulogic;
    o      :  out std_ulogic;
    tsten  :  in  std_ulogic := '0'
  );
end component;

component clkmux
  generic( tech : integer := 0;
           rsel : integer range 0 to 1 := 0); -- registered sel
  port(
    i0, i1  :  in  std_ulogic;
    sel     :  in  std_ulogic;
    o       :  out std_ulogic;
    rst     :  in  std_ulogic := '1'
  );
end component;

component clkinv
  generic( tech : integer := 0);
  port(
    i :  in  std_ulogic;
    o :  out std_ulogic
  );
end component;

component clkrand is
  generic( tech : integer := 0);
  port(
    i      :  in  std_ulogic;
    en     :  in  std_ulogic;
    o      :  out std_ulogic;
    tsten  :  in  std_ulogic := '0'
  );
end component;


---------------------------------------------------------------------------
-- DDR registers and PHY
---------------------------------------------------------------------------

component ddr_ireg is
generic ( tech : integer; arch : integer := 0; scantest: integer := 0);
port ( Q1 : out std_ulogic;
         Q2 : out std_ulogic;
         C1 : in std_ulogic;
         C2 : in std_ulogic;
         CE : in std_ulogic;
         D : in std_ulogic;
         R : in std_ulogic;
         S : in std_ulogic;
         testen : in std_ulogic := '0';
         testrst : in std_ulogic := '1');
end component;

component ddr_oreg is generic (tech : integer; arch : integer := 0; scantest: integer := 0);
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic;
      testen : in std_ulogic := '0';
      testrst: in std_ulogic := '1');
end component;

---------------------------------------------------------------------------
--  61x61 Multiplier
---------------------------------------------------------------------------

component mul_61x61
  generic (multech : integer := 0;
           fabtech : integer := 0);
    port(A       : in std_logic_vector(60 downto 0);
         B       : in std_logic_vector(60 downto 0);
         EN      : in std_logic;
         CLK     : in std_logic;
         PRODUCT : out std_logic_vector(121 downto 0));
end component;

---------------------------------------------------------------------------
--  Ring oscillator
---------------------------------------------------------------------------

   component ringosc
   generic (tech : integer := 0);
   port (
      roen  :  in    Std_ULogic;
      roout :  out   Std_ULogic);
  end component;

---------------------------------------------------------------------------
--  System monitor
---------------------------------------------------------------------------

component system_monitor
  generic (
    -- GRLIB generics
    tech    : integer    := DEFFABTECH;
    -- Virtex 5 SYSMON generics
    INIT_40 : bit_vector := X"0000";
    INIT_41 : bit_vector := X"0000";
    INIT_42 : bit_vector := X"0800";
    INIT_43 : bit_vector := X"0000";
    INIT_44 : bit_vector := X"0000";
    INIT_45 : bit_vector := X"0000";
    INIT_46 : bit_vector := X"0000";
    INIT_47 : bit_vector := X"0000";
    INIT_48 : bit_vector := X"0000";
    INIT_49 : bit_vector := X"0000";
    INIT_4A : bit_vector := X"0000";
    INIT_4B : bit_vector := X"0000";
    INIT_4C : bit_vector := X"0000";
    INIT_4D : bit_vector := X"0000";
    INIT_4E : bit_vector := X"0000";
    INIT_4F : bit_vector := X"0000";
    INIT_50 : bit_vector := X"0000";
    INIT_51 : bit_vector := X"0000";
    INIT_52 : bit_vector := X"0000";
    INIT_53 : bit_vector := X"0000";
    INIT_54 : bit_vector := X"0000";
    INIT_55 : bit_vector := X"0000";
    INIT_56 : bit_vector := X"0000";
    INIT_57 : bit_vector := X"0000";
    SIM_MONITOR_FILE : string := "design.txt");
  port (
    alm          : out std_logic_vector(2 downto 0);
    busy         : out std_ulogic;
    channel      : out std_logic_vector(4 downto 0);
    do           : out std_logic_vector(15 downto 0);
    drdy         : out std_ulogic;
    eoc          : out std_ulogic;
    eos          : out std_ulogic;
    jtagbusy     : out std_ulogic;
    jtaglocked   : out std_ulogic;
    jtagmodified : out std_ulogic;
    ot           : out std_ulogic;
    convst       : in std_ulogic;
    convstclk    : in std_ulogic;
    daddr        : in std_logic_vector(6 downto 0);
    dclk         : in std_ulogic;
    den          : in std_ulogic;
    di           : in std_logic_vector(15 downto 0);
    dwe          : in std_ulogic;
    reset        : in std_ulogic;
    vauxn        : in std_logic_vector(15 downto 0);
    vauxp        : in std_logic_vector(15 downto 0);
    vn           : in std_ulogic;
    vp           : in std_ulogic);
end component;


component nandtree
  generic(
    tech     :  integer := inferred;
    width    :  integer := 2;
    imp      :  integer := 0 );
  port( i :  in  std_logic_vector(width-1 downto 0);
	o :  out std_ulogic;
	en :  in std_ulogic
  );
end component;

component grmux2 is generic( tech : integer := inferred; imp :  integer := 0);
  port( ip0, ip1, sel : in std_logic; op : out std_ulogic); end component;
component grmux2v is generic( tech : integer := inferred; bits : integer := 2; imp :  integer := 0);
  port( ip0, ip1 : in std_logic_vector(bits-1 downto 0);
        sel : in std_logic; op : out std_logic_vector(bits-1 downto 0));
end component;
component grdff is generic( tech : integer := inferred; imp :  integer := 0);
  port( clk, d : in std_ulogic; q : out std_ulogic); end component;
component gror2 is generic( tech : integer := inferred; imp :  integer := 0);
  port( i0, i1 : in std_ulogic; q : out std_ulogic); end component;
component grand12 is generic( tech : integer := inferred; imp :  integer := 0);
  port( i0, i1 : in std_ulogic; q : out std_ulogic); end component;
component grnand2 is generic (tech: integer := inferred; imp: integer := 0);
  port( i0, i1 : in std_ulogic; q : out std_ulogic); end component;

component techmult
    generic (
         tech          : integer := 0;
         arch          : integer := 0;
         a_width       : positive := 2;                      -- multiplier word width
         b_width       : positive := 2;                      -- multiplicand word width
         num_stages    : positive := 2;                 -- number of pipeline stages
         stall_mode    : natural range 0 to 1 := 1      -- '0': non-stallable; '1': stallable
    );
    port(a       : in std_logic_vector(a_width-1 downto 0);
         b       : in std_logic_vector(b_width-1 downto 0);
         clk     : in std_logic;
         en      : in std_logic;
         sign    : in std_logic;
         product : out std_logic_vector(a_width+b_width-1 downto 0));
end component;

component syncreg
  generic (
    tech    : integer := 0;
    stages  : integer range 1 to 5 := 2
    );
  port (
    clk    : in  std_ulogic;
    d      : in  std_ulogic;
    q      : out std_ulogic
    );
end component;

-------------------------------------------------------------------------------
-- GIGABIT ETHERNET SERDES
-------------------------------------------------------------------------------

  -- Types for IGLOO2 serdes
  type apb_in_serdes is record
    paddr : std_logic_vector(14 downto 2);
    pclk : std_logic;
    penable : std_logic;
    prstn : std_logic;
    psel : std_logic;
    pwdata : std_logic_vector(31 downto 0);
    pwrite : std_logic;
  end record;

  constant apb_in_serdes_none : apb_in_serdes := ((others=>'0'), '0', '0', '0', '0', (others =>'0'), '0');

  type apb_out_serdes is record
    prdata : std_logic_vector(31 downto 0);
    pready : std_logic;
    pslverr : std_logic;
  end record;

  constant apb_out_serdes_none : apb_out_serdes := ((others=>'0'), '0', '0');

  type pad_in_serdes is record
    refclkp : std_logic;
    refclkn : std_logic;
    rx0p : std_logic;
    rx0n : std_logic;
    rx1p : std_logic;
    rx1n : std_logic;
    rx2p : std_logic;
    rx2n : std_logic;
    rx3p : std_logic;
    rx3n : std_logic;
  end record;

  constant pad_in_serdes_none : pad_in_serdes := ('0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

  type pad_out_serdes is record
    tx0p : std_logic;
    tx0n : std_logic;
    tx1p : std_logic;
    tx1n : std_logic;
    tx2p : std_logic;
    tx2n : std_logic;
    tx3p : std_logic;
    tx3n : std_logic;
  end record;

  constant pad_out_serdes_none : pad_out_serdes := ('0', '0', '0', '0', '0', '0', '0', '0');

  type sigin_serdes_type is record
    rstn : std_logic;
    tx_data : std_logic_vector(9 downto 0);
  end record;

  type sigout_serdes_type is record
    ready : std_logic;
    rx_clk : std_logic;
    rx_data : std_logic_vector(9 downto 0);
    rx_idle : std_logic;
    rx_rstn : std_logic;
    rx_val : std_logic;
    tx_clk : std_logic;
    tx_clk_lock : std_logic;
    tx_rstn : std_logic;
    refclk : std_logic;
  end record;

component serdes is
  generic (
    fabtech   : integer;
    transtech : integer
  );
  port (
    clk_125     : in std_logic;
    rst_125    : in std_logic;
    rx_in_p     : in std_logic;           -- SER IN
    rx_in_n     : in std_logic;           -- SER IN
    rx_out      : out std_logic_vector(9 downto 0); -- PAR OUT
    rx_clk      : out std_logic;
    rx_rstn     : out std_logic;
    rx_pll_clk  : out std_logic;
    rx_pll_rstn : out std_logic;
    tx_pll_clk  : out std_logic;
    tx_pll_rstn : out std_logic;
    tx_in       : in std_logic_vector(9 downto 0) ; -- PAR IN
    tx_out_p    : out std_logic;          -- SER OUT
    tx_out_n    : out std_logic;          -- SER OUT
    bitslip     : in std_logic;
    -- added for igloo2_serdes
    apbin       : in apb_in_serdes;
    apbout      : out apb_out_serdes;
    m2gl_padin  : in pad_in_serdes;
    m2gl_padout : out pad_out_serdes;
    serdes_clk125 : out std_logic;
    serdes_ready: out std_logic);
end component;

end;

