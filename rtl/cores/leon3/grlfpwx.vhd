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
-- Entity:      grlfpwx
-- File:        grlfpwx.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Description: GRFPU LITE / GRFPC wrapper and FP register file
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.stdlib.all;
use work.leon3.all;
use work.libleon3.all;
use work.libfpu.all;
use work.gencomp.all;
use work.netcomp.all;
use work.coretypes.all;

entity grlfpwx is
  generic (
    tech     : integer := 0;
    pclow    : integer range 0 to 2 := 2;
    dsu      : integer range 0 to 1 := 0;           
    disas    : integer range 0 to 2 := 0;
    pipe     : integer              := 0;
    netlist  : integer              := 0;
    index    : integer              := 0;
    scantest : integer              := 0);
  port (
    rst    : in  std_ulogic;                    -- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;                    -- pipeline hold
    cpi    : in  fpc_in_type;
    cpo    : out fpc_out_type;
    testin : in  std_logic_vector(TESTIN_WIDTH-1 downto 0)
    );


end;

architecture rtl of grlfpwx is

  signal rfi1, rfi2  : fp_rf_in_type;
  signal rfo1, rfo2  : fp_rf_out_type;


begin

  x1 : if true generate
   grlfpw0 : grlfpw_net generic map (tech, pclow, dsu, disas, pipe)
   port map (
    rst          ,
    clk          ,
    holdn        , 
    cpi.flush    ,
    cpi.exack    ,
    cpi.a_rs1    ,
    cpi.d.pc     ,
    cpi.d.inst   ,
    cpi.d.cnt    ,
    cpi.d.trap   ,
    cpi.d.annul  ,
    cpi.d.pv     ,
    cpi.a.pc     ,
    cpi.a.inst   ,
    cpi.a.cnt    ,
    cpi.a.trap   ,
    cpi.a.annul  ,
    cpi.a.pv     ,
    cpi.e.pc     ,
    cpi.e.inst   ,
    cpi.e.cnt    ,
    cpi.e.trap   ,
    cpi.e.annul  ,
    cpi.e.pv     ,
    cpi.m.pc     ,
    cpi.m.inst   ,
    cpi.m.cnt    ,
    cpi.m.trap   ,
    cpi.m.annul  ,
    cpi.m.pv     ,
    cpi.x.pc     ,
    cpi.x.inst   ,
    cpi.x.cnt    ,
    cpi.x.trap   ,
    cpi.x.annul  ,
    cpi.x.pv     ,
    cpi.lddata   ,
    cpi.dbg.enable  ,
    cpi.dbg.write   ,
    cpi.dbg.fsr     ,
    cpi.dbg.addr    ,
    cpi.dbg.data    ,

    cpo.data        ,
    cpo.exc  	    ,
    cpo.cc          ,
    cpo.ccv  	    ,
    cpo.ldlock      ,
    cpo.holdn       ,
    cpo.dbg.data    ,

    rfi1.rd1addr    ,
    rfi1.rd2addr     ,
    rfi1.wraddr      ,
    rfi1.wrdata      ,
    rfi1.ren1        ,
    rfi1.ren2        ,
    rfi1.wren        ,

    rfi2.rd1addr     ,
    rfi2.rd2addr     ,
    rfi2.wraddr       ,
    rfi2.wrdata       ,
    rfi2.ren1         ,
    rfi2.ren2         ,
    rfi2.wren         ,        

    rfo1.data1        ,
    rfo1.data2        ,
    rfo2.data1        ,
    rfo2.data2        
    );
  end generate;

  rf1 : regfile_3p_l3 generic map (tech, 4, 32, 1, 16,
                                        scantest
                                        )
         port map (clk, rfi1.wraddr, rfi1.wrdata, rfi1.wren, clk, rfi1.rd1addr,
                 rfi1.ren1, rfo1.data1, rfi1.rd2addr, rfi1.ren2, rfo1.data2,
                 testin
        );
  
  rf2 : regfile_3p_l3 generic map (tech, 4, 32, 1, 16,
                                        scantest
                                        )
         port map (clk, rfi2.wraddr, rfi2.wrdata, rfi2.wren, clk, rfi2.rd1addr,
                 rfi2.ren1, rfo2.data1, rfi2.rd2addr, rfi2.ren2, rfo2.data2,
                 testin
        );



end;

