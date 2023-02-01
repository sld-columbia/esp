-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	sldfpw
-- File:	sldfpw.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	FPU and FPC wrapper for GRLIB distributions that lacks FPU
--              source code. This wrapper instanciates a Sparc V8 IEEE-754
--              compliant floating point unit, a controller and the FP
--              register file.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.gencomp.all;
use work.sldfpp.all;
use work.coretypes.all;

entity sldfpw is
  generic (memtech  : integer := virtex7);
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi    : in  fpc_in_type;
    cpo    : out fpc_out_type
    );
end;

architecture rtl of sldfpw is

  signal rfi1, rfi2  : fp_rf_in_type;
  signal rfo1, rfo2  : fp_rf_out_type;

begin

  sldfpc_1: sldfpc
    port map (
      rst   => rst,
      clk   => clk,
      holdn => holdn,
      cpi   => cpi,
      rfi1  => rfi1,
      rfi2  => rfi2,
      rfo1  => rfo1,
      rfo2  => rfo2,
      cpo   => cpo);

  -- These registers are synchronous both for reading and writing.
  -- Usually implemented with 2p sram, unless inferred (implemented with FFs).
  -- the fourth generic is write forward and is defaulted to 1.
   rf1 : regfile_3p generic map (memtech, 4, 32, 1, 16)
     port map (clk, rfi1.wraddr, rfi1.wrdata, rfi1.wren, clk, rfi1.rd1addr, rfi1.ren1, rfo1.data1,
               rfi1.rd2addr, rfi1.ren2, rfo1.data2);

   rf2 : regfile_3p generic map (memtech, 4, 32, 1, 16)
     port map (clk, rfi2.wraddr, rfi2.wrdata, rfi2.wren, clk, rfi2.rd1addr, rfi2.ren1, rfo2.data1,
               rfi2.rd2addr, rfi2.ren2, rfo2.data2);

end;
