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

constant NTECH : integer := 57;
type tech_ability_type is array (0 to NTECH) of integer;

constant inferred    : integer := 0;
constant virtex      : integer := 1;
constant virtex2     : integer := 2;
constant memvirage   : integer := 3;
constant axcel       : integer := 4;
constant proasic     : integer := 5;
constant atc18s      : integer := 6;
constant altera      : integer := 7;
constant umc         : integer := 8;
constant rhumc       : integer := 9;
constant apa3        : integer := 10;
constant spartan3    : integer := 11;
constant ihp25       : integer := 12;
constant rhlib18t    : integer := 13;
constant virtex4     : integer := 14;
constant lattice     : integer := 15;
constant ut25        : integer := 16;
constant spartan3e   : integer := 17;
constant peregrine   : integer := 18;
constant memartisan  : integer := 19;
constant virtex5     : integer := 20;
constant custom1     : integer := 21;
constant ihp25rh     : integer := 22;
constant stratix1    : integer := 23;
constant stratix2    : integer := 24;
constant eclipse     : integer := 25;
constant stratix3    : integer := 26;
constant cyclone3    : integer := 27;
constant memvirage90 : integer := 28;
constant tsmc90      : integer := 29;
constant easic90     : integer := 30;
constant atc18rha    : integer := 31;
constant smic013     : integer := 32;
constant tm65gplus   : integer := 33;
constant axdsp       : integer := 34;
constant spartan6    : integer := 35;
constant virtex6     : integer := 36;
constant actfus      : integer := 37;
constant stratix4    : integer := 38;
constant st65lp      : integer := 39;
constant st65gp      : integer := 40;
constant easic45     : integer := 41;
constant cmos9sf     : integer := 42;
constant apa3e       : integer := 43;
constant apa3l       : integer := 44;
constant ut130       : integer := 45;
constant ut90        : integer := 46;
constant gf65        : integer := 47;
constant virtex7     : integer := 48;
constant kintex7     : integer := 49;
constant artix7      : integer := 50;
constant zynq7000    : integer := 51;
constant rhlib13t    : integer := 52;
constant saed32      : integer := 53;
constant dare        : integer := 54;
constant igloo2      : integer := 55;
constant smartfusion2: integer := 55;
constant rhs65       : integer := 56;
constant rtg4        : integer := 57;

constant DEFMEMTECH  : integer := inferred;
constant DEFPADTECH  : integer := inferred;
constant DEFFABTECH  : integer := inferred;

constant is_fpga : tech_ability_type :=
	(inferred => 1, virtex => 1, virtex2 => 1, axcel => 1,
	 proasic => 1, altera => 1, apa3 => 1, spartan3 => 1,
         virtex4 => 1, lattice => 1, spartan3e => 1, virtex5 => 1,
	 stratix1 => 1, stratix2 => 1, eclipse => 1,
	 stratix3 => 1, cyclone3 => 1, axdsp => 1,
	 spartan6 => 1, virtex6 => 1, actfus => 1,
	 stratix4 => 1, apa3e => 1, apa3l => 1, virtex7 => 1, kintex7 => 1,
	 artix7 => 1, zynq7000 => 1, igloo2 => 1, rtg4 => 1,
	 others => 0);

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
	(rhumc => 1, eclipse => 1, others => 0);

constant regfile_3p_write_through : tech_ability_type :=
	(rhumc => 1, ihp25 => 1, ihp25rh => 1, eclipse => 1, others => 0);

constant regfile_3p_infer : tech_ability_type :=
	(inferred => 1, rhumc => 1, ihp25 => 1, rhlib18t => 0, ut90 => 1,
	 peregrine => 1, ihp25rh => 1, umc => 1, custom1 => 0, rhs65 => 1, others => 0);

constant syncram_2p_dest_rw_collision : tech_ability_type :=
        (memartisan => 1, smic013 => 1, easic45 => 1, ut130 => 1, rhs65 => 0,
         igloo2 => 1, rtg4 => 1, others => 0);

constant syncram_dp_dest_rw_collision : tech_ability_type :=
        (memartisan => 1, smic013 => 1, easic45 => 1, others => 0);

-- The readhold table should be set to 1 if the techology mapping's
-- memory blocks keep the read-data bus stable at it's current value
-- when enable/renable is clocked in low any number of cycles after
-- a read.

constant syncram_readhold : tech_ability_type :=
        (rhs65 => 1, others => 0);

constant syncram_2p_readhold : tech_ability_type :=
        (rhs65 => 1, others => 0);

constant syncram_dp_readhold : tech_ability_type :=
        (others => 0);

constant regfile_3p_readhold : tech_ability_type :=
        (others => 0);

constant syncram_has_customif : tech_ability_type := (rhs65 => 1, others => 0);
constant syncram_customif_maxwidth: integer := 64;  -- Expand as needed

-- Set to 1 to add input-to-output bypass logic during scan mode in the syncram
-- wrappers.
constant syncram_add_scan_bypass : tech_ability_type := (others => 0);

constant has_sram : tech_ability_type :=
	(atc18s => 0, others => 1);

constant has_2pram : tech_ability_type :=
	( atc18s => 0, umc => 0, rhumc => 0, ihp25 => 0, others => 1);

constant has_dpram : tech_ability_type :=
	(virtex => 1, virtex2 => 1, memvirage => 1, axcel => 0,
	 altera => 1, apa3 => 1, spartan3 => 1, virtex4 => 1,
	 lattice => 1, spartan3e => 1, memartisan => 1, virtex5 => 1,
	 custom1 => 1, stratix1 => 1, stratix2 => 1, stratix3 => 1,
	 cyclone3 => 1, memvirage90 => 1, atc18rha => 1, smic013 => 1,
	 tm65gplus => 1, axdsp => 0, spartan6 => 1, virtex6 => 1,
	 actfus => 1, stratix4 => 1, easic45 => 1, apa3e => 1,
	 apa3l => 1, ut90 => 1, virtex7 => 1, kintex7 => 1, artix7 => 1, zynq7000 => 1, 
         dare => 1, igloo2 => 1, rtg4 => 1, others => 0);

constant has_sram64 : tech_ability_type :=
	(inferred => 0, virtex2 => 1, spartan3 => 1, virtex4 => 1,
	 spartan3e => 1, memartisan => 1, virtex5 => 1, smic013 => 1,
	 spartan6 => 1, virtex6 => 1, easic45 => 1, virtex7 => 1, kintex7 => 1,
	 artix7 => 1, zynq7000 => 1, others => 0);

constant has_sram128bw : tech_ability_type := (
	virtex2 => 1, virtex4 => 1, virtex5 => 1, spartan3 => 1,
	spartan3e => 1, spartan6 => 1, virtex6 => 1,  virtex7 => 1, kintex7 => 1,
	altera => 1, cyclone3 => 1, stratix2 => 1, stratix3 => 1, stratix4 => 1,
	ut90 => 1, others => 0);

constant has_sram128 : tech_ability_type := (
	virtex2 => 1, virtex4 => 1, virtex5 => 1, spartan3 => 1,
	spartan3e => 1, spartan6 => 1, virtex6 => 1, virtex7 => 1, kintex7 => 1,
	tm65gplus => 0, easic45 => 1, others => 0);

constant has_sram156bw : tech_ability_type := (
	virtex2 => 0, virtex4 => 0, virtex5 => 0, spartan3 => 0,
	spartan3e => 0, spartan6 => 0, virtex6 => 0, virtex7 => 0, kintex7 => 0,
	altera => 0, cyclone3 => 0, stratix2 => 0, stratix3 => 0, stratix4 => 0,
	tm65gplus => 0, custom1 => 1, ut90 => 1, rhs65 => 1, others => 0);

constant has_sram256bw : tech_ability_type := (
	virtex2 => 1, virtex4 => 1, virtex5 => 1, spartan3 => 1,
	spartan3e => 1, spartan6 => 1, virtex6 => 1, virtex7 => 1, kintex7 => 1,
	altera => 1, cyclone3 => 1, stratix2 => 1, stratix3 => 1, stratix4 => 1,
	tm65gplus => 0, cmos9sf => 1, others => 0);

constant has_sram_2pbw : tech_ability_type := (
    easic45 => 1, others => 0);

constant has_srambw : tech_ability_type := (easic45 => 1, virtex => 0, virtex2 => 0,
	      virtex4 => 0, virtex5 => 1, spartan3 => 0, spartan3e => 0, spartan6 => 0,
	      virtex6 => 1, virtex7 => 1, kintex7 => 1, artix7 => 1, zynq7000 => 1, rtg4 => 1,
	      igloo2 => 1, others => 0);

constant has_2pfifo : tech_ability_type := (
  altera    => 1, stratix1  => 1, stratix2 => 1, stratix3 => 1,
  stratix4  => 1, others    => 0);

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
constant ram_raw_latency : tech_ability_type := (easic45 => 1, others => 0);

-- Support for target (memory) technology FT features
-- has_sram_ecc(tech) = 1 -> target tech has SECDED capabilities for SRAM
constant has_sram_ecc :  tech_ability_type :=
  (rtg4 => 1, virtex5 => 1, virtex6 => 1,
   artix7 => 1, kintex7 => 1, virtex7 => 1,
   others => 0);

constant padoen_polarity : tech_ability_type :=
        (axcel => 1, proasic => 1, umc => 1, rhumc => 1, saed32 => 1, rhs65 => 0, dare => 1, apa3 => 1,
         ihp25 => 1, ut25 => 1, peregrine => 1, easic90 => 1, axdsp => 1,
	 actfus => 1, apa3e => 1, apa3l => 1, ut130 => 1, easic45 => 1,
         ut90 => 1, igloo2 => 1, rtg4 => 1, others => 0);

constant has_pads : tech_ability_type :=
	(inferred => 0, virtex => 1, virtex2 => 1, memvirage => 0,
	 axcel => 1, proasic => 1, atc18s => 1, altera => 0,
	 umc => 1, rhumc => 1, saed32 => 1, dare => 1, rhs65 => 1, apa3 => 1, spartan3 => 1,
         ihp25 => 1, rhlib18t => 1, virtex4 => 1, lattice => 0,
	 ut25 => 1, spartan3e => 1, peregrine => 1, virtex5 => 1, axdsp => 1,
	 easic90 => 1, atc18rha => 1, spartan6 => 1, virtex6 => 1,
         actfus => 1, apa3e => 1, apa3l => 1, ut130 => 1, easic45 => 1,
         ut90 => 1, virtex7 => 1, kintex7 => 1,
         artix7 => 1, zynq7000 => 1, igloo2 => 1, rtg4 => 1, others => 0);

constant has_ds_pads : tech_ability_type :=
	(inferred => 0, virtex => 1, virtex2 => 1, memvirage => 0,
	 axcel => 1, proasic => 0, atc18s => 0, altera => 0,
	 umc => 0, rhumc => 0, saed32 => 0, dare => 0, rhs65 => 0, apa3 => 1, spartan3 => 1,
         ihp25 => 0, rhlib18t => 1, virtex4 => 1, lattice => 0,
	 ut25 => 1, spartan3e => 1, virtex5 => 1, axdsp => 1,
	 spartan6 => 1, virtex6 => 1, actfus => 1,
	 apa3e => 1, apa3l => 1, ut130 => 0, easic45 => 1, virtex7 => 1, kintex7 => 1,
         artix7 => 1, zynq7000 => 1, igloo2 => 1, rtg4 => 1, others => 0);

constant has_ds_combo : tech_ability_type :=
	( rhumc => 1, ut25 => 1, ut130 => 1, others => 0);

constant has_tm_pads : tech_ability_type := (rhs65 => 1, others => 0);

constant has_clkand : tech_ability_type :=
	( virtex => 1, virtex2 => 1, spartan3 => 1, spartan3e => 1, virtex4 => 1,
	  virtex5 => 1, ut25 => 1, rhlib18t => 1,
          spartan6 => 1, virtex6 => 1, ut130 => 1, easic45 => 1,
          ut90 => 1, virtex7 => 1, kintex7 => 1, artix7 => 1, zynq7000 => 1, saed32 => 1, dare => 1, rhs65 => 1, others => 0);

constant has_clkmux : tech_ability_type :=
	( virtex => 1, virtex2 => 1, spartan3 => 1, spartan3e => 1,
	  virtex4 => 1, virtex5 => 1,  rhlib18t => 1,
          spartan6 => 1, virtex6 => 1, ut130 => 1, easic45 => 1,
          ut90 => 1, virtex7 => 1, kintex7 => 1, artix7 => 1, zynq7000 => 1, saed32 => 1, dare => 1, rhumc => 1, rhs65 => 1, others => 0);

constant has_clkinv : tech_ability_type :=
	( saed32 => 1, dare => 1, rhs65 => 1, others => 0);

constant has_techbuf : tech_ability_type :=
        ( virtex => 1, virtex2 => 1, virtex4 => 1, virtex5 => 1,
          spartan3 => 1, spartan3e => 1, axcel => 1, ut25 => 1,
	  apa3 => 1, easic90 => 1, axdsp => 1, actfus => 1,
	  apa3e => 1, apa3l => 1, ut130 => 1, easic45 => 1,
          ut90 => 1, spartan6 => 1, virtex6 => 1, virtex7 => 1, kintex7 => 1,
          artix7 => 1, zynq7000 => 1, igloo2 => 1, rtg4 => 1, others => 0);

constant has_tapsel : tech_ability_type :=
        ( virtex => 1, virtex2 => 1, virtex4 => 1, virtex5 => 1,
          spartan3 => 1, spartan3e => 1,
	 spartan6 => 1, virtex6 => 1, virtex7 => 1, kintex7 => 1,
	 artix7 => 1, zynq7000 => 1, others => 0);

constant tap_tck_gated : tech_ability_type :=
  ( virtex => 1, virtex2 => 1, virtex4 => 1, virtex5 => 1, spartan3 => 1, spartan3e => 1,
    spartan6 => 0, others => 0);

constant need_extra_sync_reset : tech_ability_type :=
	(axcel => 1, atc18s => 1, ut25 => 1, rhumc => 1, saed32 => 1, dare => 1, rhs65 => 1, tsmc90 => 1,
	 rhlib18t => 1, atc18rha => 1, easic90 => 1, tm65gplus => 1,
         axdsp => 1, cmos9sf => 1, apa3 => 1, apa3e => 1, apa3l => 1,
	 ut130 => 1, easic45 => 1, ut90 => 1, others => 0);

constant is_unisim : tech_ability_type :=
        ( virtex => 1, virtex2 => 1, virtex4 => 1, virtex5 => 1,
          spartan3 => 1, spartan3e => 1,
	  spartan6 => 1, virtex6 => 1, virtex7 => 1, kintex7 => 1, artix7 => 1, zynq7000 => 1, others => 0);

constant has_tap : tech_ability_type :=
	(inferred => 0, virtex => 1, virtex2 => 1, axcel => 0,
	 proasic => 0, altera => 1, apa3 => 1, spartan3 => 1,
         virtex4 => 1, lattice => 0, spartan3e => 1, virtex5 => 1,
	 stratix1 => 1, stratix2 => 1, eclipse => 0,
	 stratix3 => 1, cyclone3 => 1, axdsp => 0,
	 spartan6 => 1, virtex6 => 1, actfus => 1,
	 stratix4 => 1, easic45 => 0, apa3e => 1, apa3l => 1, virtex7 => 1, kintex7 => 1,
	 artix7 => 1, zynq7000 => 1, igloo2 => 1, rtg4 => 1,
	 others => 0);

constant has_clkgen : tech_ability_type :=
	(inferred => 0, virtex => 1, virtex2 => 1, axcel => 1,
	 proasic => 1, altera => 1, apa3 => 1, spartan3 => 1,
         virtex4 => 1, lattice => 0, spartan3e => 1, virtex5 => 1,
	 stratix1 => 1, stratix2 => 1, eclipse => 0, rhumc => 1, saed32 => 1, dare => 1, rhs65 => 1,
	 stratix3 => 1, cyclone3 => 1, axdsp => 1,
	 spartan6 => 1, virtex6 => 1, actfus => 1, easic90 => 1,
	 stratix4 => 1, easic45 => 1, apa3e => 1, apa3l => 1,
	 rhlib18t => 1, ut130 => 1, ut90 => 1, virtex7 => 1, kintex7 => 1, artix7 => 1, zynq7000 => 1, others => 0);

constant has_ddr2phy: tech_ability_type :=
  (inferred => 0, stratix2 => 1, stratix3 => 1, stratix4 => 1, spartan3 => 1,
	easic90 => 1, spartan6 => 1, easic45 => 1,
	virtex4 => 1, virtex5 => 1, virtex6 => 1, virtex7 => 1, kintex7 => 1,
	 artix7 => 1, zynq7000 => 1, others => 0);

constant ddr2phy_builtin_pads: tech_ability_type := (
   -- Wrapped DDR2 IP cores with builtin pads
   easic45 => 1,
   -- Below techs have builtin pads for legacy reasons, can be converted if needed
   easic90 => 1, spartan3 => 1, stratix4 => 1, stratix3 => 1, stratix2 => 1,
   others => 0);

constant ddr2phy_has_fbclk: tech_ability_type :=
  (inferred => 1, others => 0);

constant ddrphy_has_fbclk: tech_ability_type :=
  (others => 0);

constant ddr2phy_has_reg: tech_ability_type :=
  (easic45 => 1, stratix4 => 1, others => 0);

constant ddr2phy_dis_caslat: tech_ability_type :=
  (stratix4 => 1, others => 0);

constant ddr2phy_dis_init: tech_ability_type :=
  (stratix4 => 1, others => 0);

constant ddr2phy_has_custom: tech_ability_type :=
  (easic45 => 1, others => 0);

constant ddr2phy_refclk_type: tech_ability_type :=
  (virtex4 => 1, virtex5 => 1, virtex6 => 1,  -- 1: 200 MHz reference
  virtex7 => 1, kintex7 => 1, artix7 => 1, zynq7000 => 1,
   easic45 => 2,                              -- 2: 270 degree shifted clock
   others => 0);                              -- 0: None

constant ddr2phy_has_datavalid: tech_ability_type :=
  ( stratix4 => 1,
  	easic45 => 1,
   others => 0);

constant ddrphy_has_datavalid: tech_ability_type :=
  (ut90 => 1, others => 0);

constant ddrphy_builtin_pads: tech_ability_type := (
   inferred => 0,
   -- Most techs have builtin pads for legacy reasons, can be converted if needed
   others => 1);

constant ddrphy_latency: tech_ability_type := (
  -- extra read latency, only used when not datavalid signal is available
  inferred => 1,
  others => 0
  );

-- If the PHY passes through the control signals directly to the pads
-- and therefore needs them to be set asynchronously at reset
constant ddr2phy_ptctrl: tech_ability_type := (
  inferred => 1, others => 0
  );

constant ddrphy_ptctrl: tech_ability_type := (
  inferred => 1, others => 0
  );

constant has_syncreg: tech_ability_type := (
   inferred => 0, others => 0);

constant has_transceivers : tech_ability_type := (
    stratix3 => 1, stratix4 => 1,
    virtex5 => 1, virtex6 => 1,
    igloo2 => 1, rtg4 => 1,
    others => 0
  );


constant has_pll : tech_ability_type := (
  virtex7 => 1, others => 0
  );

-- ESP Accelerators
constant has_sort : tech_ability_type := (
  virtex7 => 1, others => 0
  );

constant has_fft : tech_ability_type := (
  virtex7 => 1, others => 0
  );

constant has_fft2d : tech_ability_type := (
  virtex7 => 1, others => 0
  );


-- pragma translate_off

  subtype tech_description is string(1 to 10);

  type tech_table_type is array (0 to NTECH) of tech_description;
-------------------------------------------------------------------------------
  constant tech_table : tech_table_type := (
  inferred  => "inferred  ", virtex    => "virtex    ",
  virtex2   => "virtex2   ", memvirage => "virage    ",
  axcel     => "axcel     ", proasic   => "proasic   ",
  atc18s    => "atc18s    ", altera    => "altera    ",
  umc       => "umc18     ", rhumc     => "rhumc     ",
  apa3      => "proasic3  ", spartan3  => "spartan3  ",
  ihp25     => "ihp25     ", rhlib18t  => "rhlib18t  ",
  virtex4   => "virtex4   ", lattice   => "lattice   ",
  ut25      => "ut025crh  ", spartan3e => "spartan3e ",
  peregrine => "peregrine ", memartisan => "artisan   ",
  virtex5   => "virtex5   ", custom1   => "custom1   ",
  ihp25rh   => "ihp25rh   ", stratix1  => "stratix   ",
  stratix2  => "stratixii ", eclipse   => "eclipse   ",
  stratix3  => "stratixiii", cyclone3  => "cycloneiii",
  memvirage90 => "virage90  ", tsmc90 =>  "tsmc90    ",
  easic90   => "nextreme  ", atc18rha  => "atc18rha  ",
  smic013   => "smic13    ", tm65gplus => "tm65gplus ",
  axdsp     => "axdsp     ", spartan6  => "spartan6  ",
  virtex6   => "virtex6   ", actfus    => "fusion    ",
  stratix4  => "stratix4  ", st65lp    => "st65lp    ",
  st65gp    => "st65gp    ", easic45   => "nextreme2 ",
  cmos9sf   => "cmos9sf   ", apa3e     => "proasic3e ",
  apa3l     => "proasic3l ", ut130     => "ut130hbd  ",
  ut90      => "ut90nhbd  ", gf65      => "gf65g     ",
  virtex7   => "virtex7   ", kintex7   => "kintex7   ",
  artix7    => "artix7    ", zynq7000  => "zynq7000  ",
  rhlib13t  => "rhlib13t  ", saed32    => "saed32    ",
  dare      => "dare      ", igloo2    => "igloo2    ",
  rhs65     => "rhs65     ", rtg4      => "rtg4      ");

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
    testen : integer := 0; custombits : integer := 1);
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
	strength : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end component;

component inpadv
  generic (tech : integer := 0; level : integer := 0;
	   voltage : integer := x33v; width : integer := 1;
           filter : integer := 0; strength : integer := 0);
  port (
    pad : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end component;

component iopad
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0; filter : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic;
        cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component iopadv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	   oepol : integer := 0; filter : integer := 0);
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_ulogic;
    o   : out std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component iopadvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0; filter : integer := 0);
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0);
    cfgi: in std_logic_vector(19 downto 0) := "00000000000000000000"
  );
end component;

component iodpad
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0);
  port (pad : inout std_ulogic; i : in std_ulogic; o : out std_ulogic);
end component;

component iodpadv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	   oepol : integer := 0);
  port (
    pad : inout std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end component;

component outpad
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12);
  port (pad : out std_ulogic; i : in std_ulogic;
  cfgi : in std_logic_vector(19 downto 0) := "00000000000000000000");
end component;

component outpadv
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12; width : integer := 1);
  port (
    pad : out std_logic_vector(width-1 downto 0);
    i   : in  std_logic_vector(width-1 downto 0);
    cfgi: in  std_logic_vector(19 downto 0) := "00000000000000000000");
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
	   hf : integer := 0; filter : integer := 0);
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
-- TAP controller and boundary scan
---------------------------------------------------------------------------

component tap
  generic (
    tech   : integer := 0;
    irlen  : integer range 2 to 8 := 4;
    idcode : integer range 0 to 255 := 9;
    manf   : integer range 0 to 2047 := 804;
    part   : integer range 0 to 65535 := 0;
    ver    : integer range 0 to 15 := 0;
    trsten : integer range 0 to 1 := 1;
    scantest : integer := 0;
    oepol  : integer := 1;
    tcknen : integer := 0);
  port (
    trst         : in std_ulogic;
    tck         : in std_ulogic;
    tms         : in std_ulogic;
    tdi         : in std_ulogic;
    tdo         : out std_ulogic;
    tapo_tck    : out std_ulogic;
    tapo_tdi    : out std_ulogic;
    tapo_inst   : out std_logic_vector(7 downto 0);
    tapo_rst    : out std_ulogic;
    tapo_capt   : out std_ulogic;
    tapo_shft   : out std_ulogic;
    tapo_upd    : out std_ulogic;
    tapo_xsel1  : out std_ulogic;
    tapo_xsel2  : out std_ulogic;
    tapi_en1    : in std_ulogic;
    tapi_tdo1   : in std_ulogic;
    tapi_tdo2   : in std_ulogic;
    tapo_ninst  : out std_logic_vector(7 downto 0);
    tapo_iupd   : out std_ulogic;
    tapo_tckn   : out std_ulogic;
    testen      : in std_ulogic := '0';
    testrst     : in std_ulogic := '1';
    testoen     : in std_ulogic := '0';
    tdoen       : out std_ulogic;
    tckn        : in std_ulogic := '0'
    );
end component;

component scanregi
  generic (
    tech : integer := 0;
    intesten: integer := 1
    );
  port (
    pad     : in std_ulogic;
    core    : out std_ulogic;
    tck     : in std_ulogic;
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapt  : in std_ulogic;    -- capture signal to scan reg on next tck edge
    bsupd   : in std_ulogic;    -- update data reg from scan reg on next tck edge
    bsdrive : in std_ulogic;     -- drive data reg to core
    bshighz : in std_ulogic
    );
end component;

component scanrego
  generic (
    tech : integer := 0
    );
  port (
    pad     : out std_ulogic;
    core    : in std_ulogic;
    samp    : in std_ulogic;    -- normally same as core unless outpad has feedback
    tck     : in std_ulogic;
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapt  : in std_ulogic;    -- capture signal to scan reg on next tck edge
    bsupd   : in std_ulogic;    -- update data reg from scan reg on next tck edge
    bsdrive : in std_ulogic     -- drive data reg to pad
    );
end component;

component scanregto -- 2 scan registers: tdo<---output<--outputen<--tdi
  generic (
    tech : integer := 0;
    hzsup: integer range 0 to 1 := 1;
    oepol: integer range 0 to 1 := 1;
    scantest: integer range 0 to 1 := 0
    );
  port (
    pado    : out std_ulogic;
    padoen  : out std_ulogic;
    samp    : in std_ulogic;    -- normally same as core unless outpad has feedback
    coreo   : in std_ulogic;
    coreoen : in std_ulogic;
    tck     : in std_ulogic;
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapto  : in std_ulogic;    -- capture signal to scan reg on next tck edge
    bscaptoe : in std_ulogic;    -- capture signal to scan reg on next tck edge
    bsupdo  : in std_ulogic;    -- update data reg from scan reg on next tck edge
    bsdrive : in std_ulogic;     -- drive data reg to pad
    bshighz : in std_ulogic;     -- tri-state output
    testen  : in std_ulogic := '0';
    testoen : in std_ulogic := '0'
    );
end component;

component scanregio -- 3 scan registers: tdo<--input<--output<--outputen<--tdi
  generic (
    tech : integer := 0;
    hzsup: integer range 0 to 1 := 1;
    oepol: integer range 0 to 1 := 1;
    intesten: integer range 0 to 1 := 1;
    scantest: integer range 0 to 1 := 0
    );
  port (
    pado    : out std_ulogic;
    padoen  : out std_ulogic;
    padi    : in std_ulogic;
    coreo   : in std_ulogic;
    coreoen : in std_ulogic;
    corei   : out std_ulogic;
    tck     : in std_ulogic;
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapti : in std_ulogic;    -- capture signals to scan regs on next tck edge
    bscapto : in std_ulogic;    -- capture signals to scan regs on next tck edge
    bscaptoe: in std_ulogic;    -- capture signals to scan regs on next tck edge
    bsupdi  : in std_ulogic;    -- update indata reg from scan reg on next tck edge
    bsupdo  : in std_ulogic;    -- update outdata reg from scan reg on next tck edge
    bsdrive : in std_ulogic;    -- drive outdata regs to pad,
                                -- drive datareg(coreoen=0) or coreo(coreoen=1) to corei
    bshighz : in std_ulogic;     -- tri-state output
    testen  : in std_ulogic := '0';
    testoen : in std_ulogic := '0'
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

component ddrphy
  generic (tech : integer := virtex2; MHz : integer := 100;
	rstdelay : integer := 200; dbits : integer := 16;
	clk_mul : integer := 2 ; clk_div : integer := 2;
	rskew : integer :=0; mobile : integer := 0;
        abits: integer := 14; nclk: integer := 3; ncs: integer := 2;
        scantest : integer := 0; phyiconf : integer := 0);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    clkoutret : in  std_ulogic;                 -- system clock return
    clkread   : out std_ulogic;			-- read clock
    lock      : out std_ulogic;			-- DCM locked
    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data

    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0);
    ck          : in  std_logic_vector(2 downto 0);
    moben       : in  std_logic;
    dqvalid     : out std_ulogic;
    testen      : in  std_ulogic;
    testrst     : in  std_ulogic;
    scanen      : in  std_ulogic;
    testoen     : in  std_ulogic);
end component;

component ddrphy_wo_pads
  generic (tech : integer := virtex2; MHz : integer := 100;
	rstdelay : integer := 200; dbits : integer := 16;
	clk_mul : integer := 2; clk_div : integer := 2;
        rskew : integer := 0; mobile: integer := 0;
        abits       : integer := 14;   nclk: integer := 3; ncs: integer := 2;
        scantest : integer := 0; phyiconf : integer := 0);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkout         : out   std_ulogic;  -- system clock
    clkoutret      : in  std_ulogic;         -- system clock returned
    clkread        : out   std_ulogic;
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in     : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1 downto 0); -- ddr bank address
    ddr_dq_in      : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_out     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_oen     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data

    addr           : in    std_logic_vector (abits-1 downto 0);
    ba             : in    std_logic_vector (1 downto 0);
    dqin           : out   std_logic_vector (dbits*2-1 downto 0);  -- ddr output data
    dqout          : in    std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dm             : in    std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen            : in    std_ulogic;
    dqs            : in    std_ulogic;
    dqsoen         : in    std_ulogic;
    rasn           : in    std_ulogic;
    casn           : in    std_ulogic;
    wen            : in    std_ulogic;
    csn            : in    std_logic_vector(ncs-1 downto 0);
    cke            : in    std_logic_vector(ncs-1 downto 0);
    ck             : in    std_logic_vector(2 downto 0);
    moben          : in  std_logic;
    dqvalid        : out   std_ulogic;
    testen      : in  std_ulogic;
    testrst     : in  std_ulogic;
    scanen      : in  std_ulogic;
    testoen     : in  std_ulogic);
end component;

component ddr2phy
  generic (
    tech        : integer := virtex5; MHz      : integer := 100;
    rstdelay    : integer := 200;     dbits    : integer := 16;
    clk_mul     : integer := 2;       clk_div  : integer := 2;
    ddelayb0    : integer := 0;       ddelayb1 : integer := 0; ddelayb2 : integer := 0;
    ddelayb3    : integer := 0;       ddelayb4 : integer := 0; ddelayb5 : integer := 0;
    ddelayb6    : integer := 0;       ddelayb7 : integer := 0;
    ddelayb8   : integer := 0;
    ddelayb9   : integer := 0;       ddelayb10: integer := 0; ddelayb11: integer := 0;
    numidelctrl : integer := 4;       norefclk : integer := 0; rskew    : integer := 0;
    eightbanks  : integer range 0 to 1 := 0; dqsse : integer range 0 to 1 := 0;
    abits       : integer := 14;   nclk: integer := 3; ncs: integer := 2;
    ctrl2en: integer := 0; resync: integer := 0; custombits: integer := 8; extraio: integer := 0;
    scantest    : integer := 0);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkref         : in    std_logic;   -- input reference clock
    clkout         : out   std_ulogic;  -- system clock
    clkoutret      : in    std_ulogic;  -- system clock return
    clkresync      : in    std_ulogic;  -- resync clock (if resync/=0)
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;                               -- ddr write enable
    ddr_rasb       : out   std_ulogic;                               -- ddr ras
    ddr_casb       : out   std_ulogic;                               -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector (extraio+dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqsn       : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqsn
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq         : inout std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);

    addr           : in    std_logic_vector (abits-1 downto 0);
    ba             : in    std_logic_vector ( 2 downto 0);
    dqin           : out   std_logic_vector (dbits*2-1 downto 0);    -- ddr output data
    dqout          : in    std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
    dm             : in    std_logic_vector (dbits/4-1 downto 0);    -- data mask
    oen            : in    std_ulogic;
    noen           : in    std_ulogic;
    dqs            : in    std_ulogic;
    dqsoen         : in    std_ulogic;
    rasn           : in    std_ulogic;
    casn           : in    std_ulogic;
    wen            : in    std_ulogic;
    csn            : in    std_logic_vector(ncs-1 downto 0);
    cke            : in    std_logic_vector(ncs-1 downto 0);
    cal_en         : in    std_logic_vector(dbits/8-1 downto 0);
    cal_inc        : in    std_logic_vector(dbits/8-1 downto 0);
    cal_pll        : in    std_logic_vector(1 downto 0);
    cal_rst        : in    std_logic;
    odt            : in    std_logic_vector(ncs-1 downto 0);
    oct            : in    std_logic;
    read_pend      : in    std_logic_vector(7 downto 0);
    regwdata       : in    std_logic_vector(63 downto 0);
    regwrite       : in    std_logic_vector(1 downto 0);
    regrdata       : out   std_logic_vector(63 downto 0);
    dqin_valid     : out   std_ulogic;
    customclk      : in    std_ulogic;
    customdin      : in    std_logic_vector(custombits-1 downto 0);
    customdout     : out   std_logic_vector(custombits-1 downto 0);

    -- Copy of control signals for 2nd DIMM
    ddr_web2    : out std_ulogic;                               -- ddr write enable
    ddr_rasb2   : out std_ulogic;                               -- ddr ras
    ddr_casb2   : out std_ulogic;                               -- ddr cas
    ddr_ad2     : out std_logic_vector (abits-1 downto 0);      -- ddr address
    ddr_ba2     : out std_logic_vector (1+eightbanks downto 0);  -- ddr bank address

    testen      : in  std_ulogic;
    testrst     : in  std_ulogic;
    scanen      : in  std_ulogic;
    testoen     : in  std_ulogic;
    oct_rdn        : in  std_logic := '0';
    oct_rup        : in  std_logic := '0');
end component;

component ddr2phy_wo_pads
  generic (tech : integer := virtex5; MHz : integer := 100;
	rstdelay : integer := 200; dbits : integer := 16;
	clk_mul : integer := 2; clk_div : integer := 2;
	ddelayb0 : integer := 0; ddelayb1 : integer := 0; ddelayb2 : integer := 0;
	ddelayb3 : integer := 0; ddelayb4 : integer := 0; ddelayb5 : integer := 0;
	ddelayb6 : integer := 0; ddelayb7 : integer := 0;
        ddelayb8: integer := 0;
	ddelayb9: integer := 0; ddelayb10: integer := 0; ddelayb11: integer := 0;
        numidelctrl : integer := 4; norefclk : integer := 0; rskew : integer := 0;
        eightbanks  : integer  range 0 to 1 := 0; dqsse : integer range 0 to 1 := 0;
        abits       : integer := 14;   nclk: integer := 3; ncs: integer := 2;
        resync      : integer := 0; custombits: integer := 8; scantest: integer := 0);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkref         : in    std_logic;   -- input 200MHz clock
    clkout         : out   std_ulogic;  -- system clock
    clkoutret      : in  std_ulogic;         -- system clock returned
    clkresync      : in    std_ulogic;
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in     : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq_in      : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_out     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_oen     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);

    addr           : in    std_logic_vector (abits-1 downto 0);
    ba             : in    std_logic_vector ( 2 downto 0);
    dqin           : out   std_logic_vector (dbits*2-1 downto 0);  -- ddr output data
    dqout          : in    std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dm             : in    std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen            : in    std_ulogic;
    noen           : in    std_ulogic;
    dqs            : in    std_ulogic;
    dqsoen         : in    std_ulogic;
    rasn           : in    std_ulogic;
    casn           : in    std_ulogic;
    wen            : in    std_ulogic;
    csn            : in    std_logic_vector(ncs-1 downto 0);
    cke            : in    std_logic_vector(ncs-1 downto 0);
    cal_en         : in    std_logic_vector(dbits/8-1 downto 0);
    cal_inc        : in    std_logic_vector(dbits/8-1 downto 0);
    cal_pll        : in    std_logic_vector(1 downto 0);
    cal_rst        : in    std_logic;
    odt            : in    std_logic_vector(ncs-1 downto 0);
    oct            : in    std_logic;
    read_pend      : in    std_logic_vector(7 downto 0);
    regwdata       : in    std_logic_vector(63 downto 0);
    regwrite       : in    std_logic_vector(1 downto 0);
    regrdata       : out   std_logic_vector(63 downto 0);
    dqin_valid     : out   std_ulogic;
    customclk      : in    std_ulogic;
    customdin      : in    std_logic_vector(custombits-1 downto 0);
    customdout     : out   std_logic_vector(custombits-1 downto 0);
    testen      : in  std_ulogic;
    testrst     : in  std_ulogic;
    scanen      : in  std_ulogic;
    testoen     : in  std_ulogic);
end component;

component lpddr2phy_wo_pads
  generic (
    tech : integer := virtex5;
    dbits : integer := 16;
    nclk: integer := 3;
    ncs: integer := 2;
    clkratio: integer := 1;
    scantest: integer := 0);
  port (
    rst            : in    std_ulogic;
    clkin          : in    std_ulogic;
    clkin2         : in    std_ulogic;
    clkout         : out   std_ulogic;
    clkoutret      : in    std_ulogic;    -- ckkout returned
    clkout2        : out   std_ulogic;
    lock           : out   std_ulogic;

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_ca         : out   std_logic_vector(9 downto 0);
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in     : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dq_in      : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_out     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_oen     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data

    ca             : in    std_logic_vector (10*2*clkratio-1 downto 0);
    cke            : in    std_logic_vector (ncs*clkratio-1 downto 0);
    csn            : in    std_logic_vector (ncs*clkratio-1 downto 0);
    dqin           : out   std_logic_vector (dbits*2*clkratio-1 downto 0);  -- ddr output data
    dqout          : in    std_logic_vector (dbits*2*clkratio-1 downto 0);  -- ddr input data
    dm             : in    std_logic_vector (dbits/4*clkratio-1 downto 0);  -- data mask
    ckstop         : in    std_ulogic;
    boot           : in    std_ulogic;
    wrpend         : in    std_logic_vector(7 downto 0);
    rdpend         : in    std_logic_vector(7 downto 0);
    wrreq          : out   std_logic_vector(clkratio-1 downto 0);
    rdvalid        : out   std_logic_vector(clkratio-1 downto 0);

    refcal         : in    std_ulogic;
    refcalwu       : in    std_ulogic;
    refcaldone     : out   std_ulogic;

    phycmd         : in    std_logic_vector(7 downto 0);
    phycmden       : in    std_ulogic;
    phycmdin       : in    std_logic_vector(31 downto 0);
    phycmdout      : out   std_logic_vector(31 downto 0);

    testen      : in  std_ulogic;
    testrst     : in  std_ulogic;
    scanen      : in  std_ulogic;
    testoen     : in  std_ulogic);
end component;

component ddr2pads is
  generic (tech: integer := virtex5;
           dbits: integer := 16;
           eightbanks: integer := 0;
           dqsse: integer range 0 to 1 := 0;
           abits: integer := 14;
           nclk: integer := 3;
           ncs: integer := 2;
           ctrl2en: integer := 0);
  port (
    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqsn       : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqsn
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq         : inout std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);

    -- Copy of control signals for 2nd DIMM (if ctrl2en /= 0)
    ddr_web2       : out std_ulogic;                               -- ddr write enable
    ddr_rasb2      : out std_ulogic;                               -- ddr ras
    ddr_casb2      : out std_ulogic;                               -- ddr cas
    ddr_ad2        : out std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba2        : out std_logic_vector (1+eightbanks downto 0); -- ddr bank address

    lddr_clk        : in    std_logic_vector(nclk-1 downto 0);
    lddr_clkb       : in    std_logic_vector(nclk-1 downto 0);
    lddr_clk_fb_out : in    std_logic;
    lddr_clk_fb     : out   std_logic;
    lddr_cke        : in    std_logic_vector(ncs-1 downto 0);
    lddr_csb        : in    std_logic_vector(ncs-1 downto 0);
    lddr_web        : in    std_ulogic;  -- ddr write enable
    lddr_rasb       : in    std_ulogic;  -- ddr ras
    lddr_casb       : in    std_ulogic;  -- ddr cas
    lddr_dm         : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    lddr_dqs_in     : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    lddr_dqs_out    : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    lddr_dqs_oen    : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    lddr_ad         : in    std_logic_vector (abits-1 downto 0);           -- ddr address
    lddr_ba         : in    std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    lddr_dq_in      : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    lddr_dq_out     : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    lddr_dq_oen     : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    lddr_odt        : in    std_logic_vector(ncs-1 downto 0)
    );
end component;

component ddrpads is
  generic (tech: integer := virtex5;
           dbits: integer := 16;
           abits: integer := 14;
           nclk: integer := 3;
           ncs: integer := 2;
           ctrl2en: integer := 0);
  port (
    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1 downto 0); -- ddr bank address
    ddr_dq         : inout std_logic_vector (dbits-1 downto 0);      -- ddr data

    -- Copy of control signals for 2nd DIMM (if ctrl2en /= 0)
    ddr_web2       : out std_ulogic;                               -- ddr write enable
    ddr_rasb2      : out std_ulogic;                               -- ddr ras
    ddr_casb2      : out std_ulogic;                               -- ddr cas
    ddr_ad2        : out std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba2        : out std_logic_vector (1 downto 0); -- ddr bank address

    lddr_clk        : in    std_logic_vector(nclk-1 downto 0);
    lddr_clkb       : in    std_logic_vector(nclk-1 downto 0);
    lddr_clk_fb_out : in    std_logic;
    lddr_clk_fb     : out   std_logic;
    lddr_cke        : in    std_logic_vector(ncs-1 downto 0);
    lddr_csb        : in    std_logic_vector(ncs-1 downto 0);
    lddr_web        : in    std_ulogic;  -- ddr write enable
    lddr_rasb       : in    std_ulogic;  -- ddr ras
    lddr_casb       : in    std_ulogic;  -- ddr cas
    lddr_dm         : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    lddr_dqs_in     : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    lddr_dqs_out    : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    lddr_dqs_oen    : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    lddr_ad         : in    std_logic_vector (abits-1 downto 0);           -- ddr address
    lddr_ba         : in    std_logic_vector (1 downto 0); -- ddr bank address
    lddr_dq_in      : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    lddr_dq_out     : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    lddr_dq_oen     : in    std_logic_vector (dbits-1 downto 0)       -- ddr data
    );
end component;

component ddrphy_datapath is
  generic (
    regtech: integer := 0;
    dbits: integer;
    abits: integer;
    bankbits: integer range 2 to 3 := 2;
    ncs: integer;
    nclk: integer;
    resync: integer range 0 to 2 := 0
    );
  port (
    clk0: in std_ulogic;
    clk90: in std_ulogic;
    clk180: in std_ulogic;
    clk270: in std_ulogic;
    clkresync: in std_ulogic;

    ddr_clk: out std_logic_vector(nclk-1 downto 0);
    ddr_clkb: out std_logic_vector(nclk-1 downto 0);

    ddr_dq_in: in std_logic_vector(dbits-1 downto 0);
    ddr_dq_out: out std_logic_vector(dbits-1 downto 0);
    ddr_dq_oen: out std_logic_vector(dbits-1 downto 0);

    ddr_dqs_in90: in std_logic_vector(dbits/8-1 downto 0);
    ddr_dqs_in90n: in std_logic_vector(dbits/8-1 downto 0);
    ddr_dqs_out: out std_logic_vector(dbits/8-1 downto 0);
    ddr_dqs_oen: out std_logic_vector(dbits/8-1 downto 0);

    ddr_cke: out std_logic_vector(ncs-1 downto 0);
    ddr_csb: out std_logic_vector(ncs-1 downto 0);
    ddr_web: out std_ulogic;
    ddr_rasb: out std_ulogic;
    ddr_casb: out std_ulogic;
    ddr_ad: out std_logic_vector(abits-1 downto 0);
    ddr_ba: out std_logic_vector(bankbits-1 downto 0);
    ddr_dm: out std_logic_vector(dbits/8-1 downto 0);
    ddr_odt: out std_logic_vector(ncs-1 downto 0);

    dqin: out std_logic_vector(dbits*2-1 downto 0);
    dqout: in std_logic_vector(dbits*2-1 downto 0);
    addr        : in  std_logic_vector (abits-1 downto 0);
    ba          : in  std_logic_vector (bankbits-1 downto 0);
    dm          : in  std_logic_vector (dbits/4-1 downto 0);
    oen         : in  std_ulogic;
    rasn        : in  std_ulogic;
    casn        : in  std_ulogic;
    wen         : in  std_ulogic;
    csn         : in  std_logic_vector(ncs-1 downto 0);
    cke         : in  std_logic_vector(ncs-1 downto 0);
    odt         : in  std_logic_vector(ncs-1 downto 0);

    dqs_en      : in  std_ulogic;
    dqs_oen     : in  std_ulogic;

    ddrclk_en   : in  std_logic_vector(nclk-1 downto 0)
    );
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
-- SDRAM PHY
-------------------------------------------------------------------------------

component sdram_phy
  generic (
    tech     : integer := spartan3;
    oepol    : integer := 0;
    level    : integer := 0;
    voltage  : integer := x33v;
    strength : integer := 12;
    aw       : integer := 15;               -- # address bits
    dw       : integer := 32;               -- # data bits
    ncs      : integer := 2;
    reg      : integer := 0);               -- 1: include registers on all signals
  port (
    -- SDRAM interface
    addr      : out   std_logic_vector(aw-1 downto 0);
    dq        : inout std_logic_vector(dw-1 downto 0);
    cke       : out   std_logic_vector(ncs-1 downto 0);
    sn        : out   std_logic_vector(ncs-1 downto 0);
    wen       : out   std_ulogic;
    rasn      : out   std_ulogic;
    casn      : out   std_ulogic;
    dqm       : out   std_logic_vector(dw/8-1 downto 0);
    -- Interface toward memory controller
    laddr     : in    std_logic_vector(aw-1 downto 0);
    ldq_din   : out   std_logic_vector(dw-1 downto 0);
    ldq_dout  : in    std_logic_vector(dw-1 downto 0);
    ldq_oen   : in    std_logic_vector(dw-1 downto 0);
    lcke      : in    std_logic_vector(ncs-1 downto 0);
    lsn       : in    std_logic_vector(ncs-1 downto 0);
    lwen      : in    std_ulogic;
    lrasn     : in    std_ulogic;
    lcasn     : in    std_ulogic;
    ldqm      : in    std_logic_vector(dw/8-1 downto 0);
    -- Only used when reg generic is non-zero
    rstn      : in  std_ulogic;         -- Registered pads reset
    clk       : in  std_ulogic;         -- SDRAM clock for registered pads
    -- Optional pad configuration inputs
    cfgi_cmd  : in std_logic_vector(19 downto 0) := "00000000000000000000"; -- CMD pads
    cfgi_dq   : in std_logic_vector(19 downto 0) := "00000000000000000000"  -- DQ pads
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

