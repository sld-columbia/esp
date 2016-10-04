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
-- Package:     ddrpkg
-- File:        ddrpkg.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Components and types for DDR SDRAM controllers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gencomp.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;

package ddrpkg is

  type ddrctrl_in_type is record
    -- Data signals
    data      : std_logic_vector (127 downto 0);-- data in
    cb        : std_logic_vector(63 downto 0);  -- checkbits in
    -- Bus/timing control signals
    datavalid : std_logic;                      -- Data-valid signal (DDR2,LPDDR2,LPDDR3)
    writereq  : std_logic;                      -- Write-data request (LPDDR2,LPDDR3)
    -- Calibration and configuration
    regrdata  : std_logic_vector(63 downto 0);  -- PHY-specific reg in (DDR2)
  end record;

  constant ddrctrl_in_none : ddrctrl_in_type :=
    ((others => '0'), (others => '0'), '0', '0', (others => '0'));

  type ddrctrl_out_type is record
    -- Control signals to memory
    sdcke   : std_logic_vector ( 1 downto 0);   -- clk en
    sdcsn   : std_logic_vector ( 1 downto 0);   -- chip sel
    sdwen   : std_ulogic;                       -- write en     (DDR1,DDR2,LPDDR1)
    rasn    : std_ulogic;                       -- row addr stb (DDR1,DDR2,LPDDR1)
    casn    : std_ulogic;                       -- col addr stb (DDR1,DDR2,LPDDR1)
    address : std_logic_vector(14 downto 0);    -- address out  (DDR1,DDR2,LPDDR1)
    ba      : std_logic_vector (2 downto 0);    -- bank address (DDR1,DDR2,LPDDR1)
    odt     : std_logic_vector(1 downto 0);     -- On Die Termination (DDR2,LPDDR3)
    ca      : std_logic_vector(19 downto 0);    -- Ctrl/Addr bus (LPDDR2,LPDDR3)
    -- Data signals
    data      : std_logic_vector(127 downto 0); -- data out
    dqm       : std_logic_vector(15 downto 0);  -- data i/o mask
    cb        : std_logic_vector(63 downto 0);  -- checkbits
    cbdqm     : std_logic_vector(7 downto 0);   -- checkbits data mask
    -- Bus/timing control signals
    bdrive    : std_ulogic;                     -- bus drive (DDR1,DDR2,LPDDR1)
    qdrive    : std_ulogic;                     -- bus drive (DDR1,DDR2,LPDDR1)
    nbdrive   : std_ulogic;                     -- bdrive 1 cycle early (DDR2)
    sdck      : std_logic_vector(2 downto 0);   -- Clock enable (DDR1,LPDDR1,LPDDR2,LPDDR3)
    moben     : std_logic;                      -- Mobile DDR mode (DDR1/LPDDR1)
    oct       : std_logic;                      -- On Chip Termination (DDR2)
    dqs_gate  : std_logic;                      -- DQS gate control (DDR2)
    read_pend : std_logic_vector(7 downto 0);   -- Read pending within 7...0
                                                -- cycles (not including phy
                                                -- delays) (DDR2,LPDDR2,LPDDR3)
    wrpend    : std_logic_vector(7 downto 0);   -- Write pending (LPDDR2,LPDDR3)
    boot      : std_ulogic;                     -- Boot clock selection (LPDDR2,LPDDR3)
    -- Calibration and configuration
    cal_en    : std_logic_vector(7 downto 0);   -- enable delay calibration (DDR2)
    cal_inc   : std_logic_vector(7 downto 0);   -- inc/dec delay (DDR2)
    cal_pll   : std_logic_vector(1 downto 0);   -- (enable,inc/dec) pll phase (DDR2)
    cal_rst   : std_logic;                      -- calibration reset (DDR2)
    conf      : std_logic_vector(63 downto 0);  -- Conf. interface (DDR1,LPDDR1)
    cbcal_en  : std_logic_vector(3 downto 0);   -- CB enable delay calib (DDR2)
    cbcal_inc : std_logic_vector(3 downto 0);   -- CB inc/dec delay (DDR2)
    regwdata  : std_logic_vector(63 downto 0);  -- Reg Write data (DDR2)
    regwrite  : std_logic_vector(1 downto 0);   -- Reg write strobe (DDR2)
    -- Status outputs to front-end
    ce        : std_ulogic;                     -- Error corrected
  end record;

  constant ddrctrl_out_none : ddrctrl_out_type :=
    ((others => '0'), (others => '0'), '0', '0', '0', (others => '0'), (others => '0'),
     (others => '0'), (others => '0'), (others => '0'), (others => '0'),
     (others => '0'), (others => '0'), '0', '0', '0', (others => '0'),
     '0', '0', '0', (others => '0'), (others => '0'), '0', (others => '0'),
     (others => '0'), (others => '0'), '0', (others => '0'),
     (others => '0'), (others => '0'), (others => '0'), (others => '0'), '0' );

  -----------------------------------------------------------------------------
  -- DDR2SPA types and components
  -----------------------------------------------------------------------------

  -- DDR2 controller without PHY
  component ddr2spax is
    generic (
      memtech    : integer := 0;
      phytech    : integer := 0;
      hindex     : integer := 0;
      haddr      : integer := 0;
      hmask      : integer := 16#f00#;
      ioaddr     : integer := 16#000#;
      iomask     : integer := 16#fff#;
      ddrbits    : integer := 32;
      burstlen   : integer := 8;
      MHz        : integer := 100;
      TRFC       : integer := 130;
      col        : integer := 9;
      Mbyte      : integer := 8;
      pwron      : integer := 0;
      oepol      : integer := 0;
      readdly    : integer := 1;
      odten      : integer := 0;
      octen      : integer := 0;
      dqsgating  : integer := 0;
      nosync     : integer := 0;
      eightbanks : integer range 0 to 1 := 0; -- Set to 1 if 8 banks instead of 4
      dqsse      : integer range 0 to 1 := 0;  -- single ended DQS
      ddr_syncrst: integer range 0 to 1 := 0;
      ahbbits    : integer := ahbdw;
      ft         : integer range 0 to 1 := 0;
      bigmem     : integer range 0 to 1 := 0;
      raspipe    : integer range 0 to 1 := 0;
      hwidthen   : integer range 0 to 1 := 0;
      rstdel     : integer := 200;
      scantest   : integer := 0;
      cke_rst    : integer := 0;
      pipe_ctrl  : integer := 0
      );
    port (
      ddr_rst : in  std_ulogic;
      ahb_rst : in  std_ulogic;
      clk_ddr : in  std_ulogic;
      clk_ahb : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      sdi     : in  ddrctrl_in_type;
      sdo     : out ddrctrl_out_type;
      hwidth  : in  std_ulogic
      );
  end component;

-- DDR2 controller with PHY
  component ddr2spa
    generic (
      fabtech     : integer := 0;
      memtech     : integer := 0;
      rskew       : integer := 0;
      hindex      : integer := 0;
      haddr       : integer := 0;
      hmask       : integer := 16#f00#;
      ioaddr      : integer := 16#000#;
      iomask      : integer := 16#fff#;
      MHz         : integer := 100;
      TRFC        : integer := 130;
      clkmul      : integer := 2;
      clkdiv      : integer := 2;
      col         : integer := 9;
      Mbyte       : integer := 16;
      rstdel      : integer := 200;
      pwron       : integer := 0;
      oepol       : integer := 0;
      ddrbits     : integer := 16;
      ahbfreq     : integer := 50;
      readdly     : integer := 1;
      ddelayb0    : integer := 0;
      ddelayb1    : integer := 0;
      ddelayb2    : integer := 0;
      ddelayb3    : integer := 0;
      ddelayb4    : integer := 0;
      ddelayb5    : integer := 0;
      ddelayb6    : integer := 0;
      ddelayb7    : integer := 0;
      cbdelayb0   : integer := 0;
      cbdelayb1   : integer := 0;
      cbdelayb2   : integer := 0;
      cbdelayb3   : integer := 0;
      numidelctrl : integer := 4;
      norefclk    : integer := 0;
      odten       : integer := 0;
      octen       : integer := 0;
      dqsgating   : integer := 0;
      nosync      : integer := 0;
      eightbanks  : integer := 0;
      dqsse       : integer range 0 to 1 := 0;
      burstlen    : integer range 4 to 128 := 8;
      ahbbits     : integer := ahbdw;
      ft          : integer range 0 to 1 := 0;
      ftbits      : integer := 0;
      bigmem      : integer range 0 to 1 := 0;
      raspipe     : integer range 0 to 1 := 0;
      nclk        : integer range 1 to 3 := 3;
      scantest    : integer := 0;
      ncs         : integer := 2;
      cke_rst     : integer := 0;
      pipe_ctrl   : integer := 0
      );
    port (
      rst_ddr        : in  std_ulogic;
      rst_ahb        : in  std_ulogic;
      clk_ddr        : in  std_ulogic;
      clk_ahb        : in  std_ulogic;
      clkref200      : in  std_ulogic;
      lock           : out std_ulogic;                        -- DCM locked
      clkddro        : out std_ulogic;                        -- DCM locked
      clkddri        : in  std_ulogic;
      ahbsi          : in  ahb_slv_in_type;
      ahbso          : out ahb_slv_out_type;
      ddr_clk        : out std_logic_vector(nclk-1 downto 0);
      ddr_clkb       : out std_logic_vector(nclk-1 downto 0);
      ddr_clk_fb_out : out std_logic;
      ddr_clk_fb     : in std_logic;
      ddr_cke        : out std_logic_vector(1 downto 0);
      ddr_csb        : out std_logic_vector(1 downto 0);
      ddr_web        : out std_ulogic;                       -- ddr write enable
      ddr_rasb       : out std_ulogic;                       -- ddr ras
      ddr_casb       : out std_ulogic;                       -- ddr cas
      ddr_dm         : out std_logic_vector ((ddrbits+ftbits)/8-1 downto 0);   -- ddr dm
      ddr_dqs        : inout std_logic_vector ((ddrbits+ftbits)/8-1 downto 0); -- ddr dqs
      ddr_dqsn       : inout std_logic_vector ((ddrbits+ftbits)/8-1 downto 0); -- ddr dqsn
      ddr_ad         : out std_logic_vector (13 downto 0);                     -- ddr address
      ddr_ba         : out std_logic_vector (1+eightbanks downto 0);           -- ddr bank address
      ddr_dq         : inout  std_logic_vector (ddrbits+ftbits-1 downto 0);    -- ddr data
      ddr_odt        : out std_logic_vector(1 downto 0);
      ce             : out std_logic;
      oct_rdn        : in  std_logic := '0';
      oct_rup        : in  std_logic := '0'
      );
  end component;

  -- DDR2 PHY with just data or checkbits+data on same bus, including pads
  component ddr2phy_wrap_cbd is
    generic (
      tech        : integer := virtex2;
      MHz         : integer := 100;
      rstdelay    : integer := 200;
      dbits       : integer := 16;
      padbits     : integer := 0;
      clk_mul     : integer := 2 ;
      clk_div     : integer := 2;
      ddelayb0    : integer := 0;
      ddelayb1    : integer := 0;
      ddelayb2    : integer := 0;
      ddelayb3    : integer := 0;
      ddelayb4    : integer := 0;
      ddelayb5    : integer := 0;
      ddelayb6    : integer := 0;
      ddelayb7    : integer := 0;
      cbdelayb0   : integer := 0;
      cbdelayb1   : integer := 0;
      cbdelayb2   : integer := 0;
      cbdelayb3   : integer := 0;
      numidelctrl : integer := 4;
      norefclk    : integer := 0;
      odten       : integer := 0;
      rskew       : integer := 0;
      eightbanks  : integer range 0 to 1 := 0;
      dqsse       : integer range 0 to 1 := 0;
      abits       : integer := 14;
      nclk        : integer := 3;
      ncs         : integer := 2;
      chkbits     : integer := 0;
      ctrl2en     : integer := 0;
      resync      : integer := 0;
      custombits  : integer := 8;
      extraio     : integer := 0;
      scantest    : integer := 0
      );
    port (
      rst            : in    std_ulogic;
      clk            : in    std_logic;   -- input clock
      clkref200      : in    std_logic;   -- input 200MHz clock
      clkout         : out   std_ulogic;  -- system clock
      clkoutret      : in    std_ulogic;  -- system clock returned
      clkresync      : in    std_ulogic;
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
      ddr_dm         : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);        -- ddr dm
      ddr_dqs        : inout std_logic_vector (extraio+(dbits+padbits+chkbits)/8-1 downto 0);-- ddr dqs
      ddr_dqsn       : inout std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);        -- ddr dqs
      ddr_ad         : out   std_logic_vector (abits-1 downto 0);      -- ddr address
      ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
      ddr_dq         : inout std_logic_vector (dbits+padbits+chkbits-1 downto 0);            -- ddr data
      ddr_odt        : out   std_logic_vector(ncs-1 downto 0);

      ddr_web2       : out   std_ulogic;                               -- ddr write enable
      ddr_rasb2      : out   std_ulogic;                               -- ddr ras
      ddr_casb2      : out   std_ulogic;                               -- ddr cas
      ddr_ad2        : out   std_logic_vector (abits-1 downto 0);      -- ddr address
      ddr_ba2        : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address

      sdi            : out   ddrctrl_in_type;
      sdo            : in    ddrctrl_out_type;

      customclk      : in    std_ulogic;
      customdin      : in    std_logic_vector(custombits-1 downto 0);
      customdout     : out   std_logic_vector(custombits-1 downto 0);

      testen         : in    std_ulogic;
      testrst        : in    std_ulogic;
      scanen         : in    std_ulogic;
      testoen        : in    std_ulogic;
      oct_rdn        : in  std_logic := '0';
      oct_rup        : in  std_logic := '0'
      );
  end component;

  -- DDR2 PHY with just data or checkbits+data on same bus, not including pads
  component ddr2phy_wrap_cbd_wo_pads is
    generic (
      tech     : integer := virtex2;
      MHz        : integer := 100;
      rstdelay    : integer := 200;
      dbits      : integer := 16;
      padbits  : integer := 0;
      clk_mul     : integer := 2 ;
      clk_div    : integer := 2;
      ddelayb0    : integer := 0;
      ddelayb1   : integer := 0;
      ddelayb2 : integer := 0;
      ddelayb3    : integer := 0;
      ddelayb4   : integer := 0;
      ddelayb5 : integer := 0;
      ddelayb6    : integer := 0;
      ddelayb7   : integer := 0;
      cbdelayb0   : integer := 0;
      cbdelayb1: integer := 0;
      cbdelayb2: integer := 0;
      cbdelayb3   : integer := 0;
      numidelctrl : integer := 4;
      norefclk   : integer := 0;
      odten    : integer := 0;
      rskew       : integer := 0;
      eightbanks : integer range 0 to 1 := 0;
      dqsse       : integer range 0 to 1 := 0;
      abits       : integer := 14;
      nclk     : integer := 3;
      ncs      : integer := 2;
      chkbits     : integer := 0;
      resync     : integer := 0;
      custombits : integer := 8;
      scantest    : integer := 0
      );
    port (
      rst            : in    std_ulogic;
      clk            : in    std_logic;   -- input clock
      clkref200      : in    std_logic;   -- input 200MHz clock
      clkout         : out   std_ulogic;  -- system clock
      clkoutret      : in    std_ulogic;  -- system clock return
      clkresync      : in    std_ulogic;
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
      ddr_dm         : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dm
      ddr_dqs_in     : in    std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
      ddr_dqs_out    : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
      ddr_dqs_oen    : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
      ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
      ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
      ddr_dq_in      : in    std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
      ddr_dq_out     : out   std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
      ddr_dq_oen     : out   std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
      ddr_odt        : out   std_logic_vector(ncs-1 downto 0);

      sdi            : out   ddrctrl_in_type;
      sdo            : in    ddrctrl_out_type;

      customclk      : in    std_ulogic;
      customdin      : in    std_logic_vector(custombits-1 downto 0);
      customdout     : out   std_logic_vector(custombits-1 downto 0);

      testen         : in    std_ulogic;
      testrst        : in    std_ulogic;
      scanen         : in    std_ulogic;
      testoen        : in    std_ulogic
      );
  end component;

  -- DDR2 PHY with separate checkbit and data buses, including pads
  component ddr2phy_wrap
    generic (
      tech        : integer := virtex2;
      MHz         : integer := 100;
      rstdelay    : integer := 200;
      dbits       : integer := 16;
      padbits     : integer := 0;
      clk_mul     : integer := 2;
      clk_div     : integer := 2;
      ddelayb0    : integer := 0;
      ddelayb1    : integer := 0;
      ddelayb2    : integer := 0;
      ddelayb3    : integer := 0;
      ddelayb4    : integer := 0;
      ddelayb5    : integer := 0;
      ddelayb6    : integer := 0;
      ddelayb7    : integer := 0;
      cbdelayb0   : integer := 0;
      cbdelayb1   : integer := 0;
      cbdelayb2   : integer := 0;
      cbdelayb3   : integer := 0;
      numidelctrl : integer := 4;
      norefclk    : integer := 0;
      rskew       : integer := 0;
      eightbanks  : integer range 0 to 1 := 0;
      dqsse       : integer range 0 to 1 := 0;
      abits       : integer := 14;
      nclk        : integer := 3;
      ncs         : integer := 2;
      cben        : integer := 0;
      chkbits     : integer := 8;
      ctrl2en     : integer := 0;
      resync      : integer := 0;
      custombits  : integer := 8;
      scantest    : integer := 0
      );
    port (
      rst            : in    std_ulogic;
      clk            : in    std_logic;   -- input clock
      clkref200      : in    std_logic;   -- input 200MHz clock
      clkout         : out   std_ulogic;  -- system clock
      clkoutret      : in    std_ulogic;  -- system clock returned
      clkresync      : in    std_ulogic;
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
      ddr_dm         : out   std_logic_vector ((dbits+padbits)/8-1 downto 0);    -- ddr dm
      ddr_dqs        : inout std_logic_vector ((dbits+padbits)/8-1 downto 0);    -- ddr dqs
      ddr_dqsn       : inout std_logic_vector ((dbits+padbits)/8-1 downto 0);    -- ddr dqs
      ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
      ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
      ddr_dq         : inout std_logic_vector (dbits+padbits-1 downto 0);      -- ddr data
      ddr_odt        : out   std_logic_vector(ncs-1 downto 0);
      ddr_cbdm       : out   std_logic_vector(chkbits/8-1 downto 0);
      ddr_cbdqs      : inout std_logic_vector(chkbits/8-1 downto 0);
      ddr_cbdqsn     : inout std_logic_vector(chkbits/8-1 downto 0);
      ddr_cbdq       : inout std_logic_vector(chkbits-1 downto 0);
      ddr_web2       : out   std_ulogic;                               -- ddr write enable
      ddr_rasb2      : out   std_ulogic;                               -- ddr ras
      ddr_casb2      : out   std_ulogic;                               -- ddr cas
      ddr_ad2        : out   std_logic_vector (abits-1 downto 0);      -- ddr address
      ddr_ba2        : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address

      sdi            : out   ddrctrl_in_type;
      sdo            : in    ddrctrl_out_type;

      customclk      : in    std_ulogic;
      customdin      : in    std_logic_vector(custombits-1 downto 0);
      customdout     : out   std_logic_vector(custombits-1 downto 0);

      testen         : in    std_ulogic;
      testrst        : in    std_ulogic;
      scanen         : in    std_ulogic;
      testoen        : in    std_ulogic
      );
  end component;

  -----------------------------------------------------------------------------
  -- DDRSPA types and components
  -----------------------------------------------------------------------------

  -- DDR/LPDDR controller, without PHY
  component ddr1spax is
    generic (
      memtech    : integer := 0;
      phytech    : integer := 0;
      hindex     : integer := 0;
      haddr      : integer := 0;
      hmask      : integer := 16#f00#;
      ioaddr     : integer := 16#000#;
      iomask     : integer := 16#fff#;
      ddrbits    : integer := 32;
      burstlen   : integer := 8;
      MHz        : integer := 100;
      col        : integer := 9;
      Mbyte      : integer := 8;
      pwron      : integer := 0;
      oepol      : integer := 0;
      nosync     : integer := 0;
      ddr_syncrst: integer range 0 to 1 := 0;
      ahbbits    : integer := ahbdw;
      mobile     : integer := 0;
      confapi    : integer := 0;
      conf0      : integer := 0;
      conf1      : integer := 0;
      regoutput  : integer := 0;
      ft         : integer := 0;
      ddr400     : integer := 1;
      rstdel     : integer := 200;
      scantest   : integer := 0
      );
    port (
      ddr_rst : in  std_ulogic;
      ahb_rst : in  std_ulogic;
      clk_ddr : in  std_ulogic;
      clk_ahb : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      sdi     : in  ddrctrl_in_type;
      sdo     : out ddrctrl_out_type
      );
  end component;

  -- DDR/LPDDR controller with PHY
  component ddrspa
    generic (
      fabtech   : integer := 0;
      memtech   : integer := 0;
      rskew     : integer := 0;
      hindex    : integer := 0;
      haddr     : integer := 0;
      hmask     : integer := 16#f00#;
      ioaddr    : integer := 16#000#;
      iomask    : integer := 16#fff#;
      MHz       : integer := 100;
      clkmul    : integer := 2;
      clkdiv    : integer := 2;
      col       : integer := 9;
      Mbyte     : integer := 16;
      rstdel    : integer := 200;
      pwron     : integer := 0;
      oepol     : integer := 0;
      ddrbits   : integer := 16;
      ahbfreq   : integer := 50;
      mobile    : integer := 0;
      confapi   : integer := 0;
      conf0     : integer := 0;
      conf1     : integer := 0;
      regoutput : integer  range 0 to 1 := 0;
      ddr400    : integer := 1;
      scantest  : integer := 0;
      phyiconf  : integer := 0
      );
    port (
      rst_ddr        : in  std_ulogic;
      rst_ahb        : in  std_ulogic;
      clk_ddr        : in  std_ulogic;
      clk_ahb        : in  std_ulogic;
      lock           : out std_ulogic;                       -- DCM locked
      clkddro        : out std_ulogic;                       -- DCM locked
      clkddri        : in  std_ulogic;
      ahbsi          : in  ahb_slv_in_type;
      ahbso          : out ahb_slv_out_type;
      ddr_clk        : out std_logic_vector(2 downto 0);
      ddr_clkb       : out std_logic_vector(2 downto 0);
      ddr_clk_fb_out : out std_logic;
      ddr_clk_fb     : in std_logic;
      ddr_cke        : out std_logic_vector(1 downto 0);
      ddr_csb        : out std_logic_vector(1 downto 0);
      ddr_web        : out std_ulogic;                       -- ddr write enable
      ddr_rasb       : out std_ulogic;                       -- ddr ras
      ddr_casb       : out std_ulogic;                       -- ddr cas
      ddr_dm         : out std_logic_vector (ddrbits/8-1 downto 0);    -- ddr dm
      ddr_dqs        : inout std_logic_vector (ddrbits/8-1 downto 0);  -- ddr dqs
      ddr_ad         : out std_logic_vector (13 downto 0);   -- ddr address
      ddr_ba         : out std_logic_vector (1 downto 0);    -- ddr bank address
      ddr_dq         : inout  std_logic_vector (ddrbits-1 downto 0)    -- ddr data
      );
  end component;

  -- DDR/LPDDR PHY, including pads
  component ddrphy_wrap
    generic (
      tech     : integer := virtex2;
      MHz      : integer := 100;
      rstdelay : integer := 200;
      dbits    : integer := 16;
      clk_mul  : integer := 2;
      clk_div  : integer := 2;
      rskew    : integer := 0;
      mobile   : integer := 0;
      scantest : integer := 0;
      phyiconf : integer := 0);
    port (
      rst            : in  std_ulogic;
      clk            : in  std_logic;                       -- input clock
      clkout         : out std_ulogic;                      -- system clock
      clkoutret      : in  std_ulogic;
      clkread        : out std_ulogic;                      -- system clock
      lock           : out std_ulogic;                      -- DCM locked
      ddr_clk        : out std_logic_vector(2 downto 0);
      ddr_clkb       : out std_logic_vector(2 downto 0);
      ddr_clk_fb_out : out std_logic;
      ddr_clk_fb     : in std_logic;
      ddr_cke        : out std_logic_vector(1 downto 0);
      ddr_csb        : out std_logic_vector(1 downto 0);
      ddr_web        : out std_ulogic;                    -- ddr write enable
      ddr_rasb       : out std_ulogic;                    -- ddr ras
      ddr_casb       : out std_ulogic;                    -- ddr cas
      ddr_dm         : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
      ddr_dqs        : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
      ddr_ad         : out std_logic_vector (13 downto 0);-- ddr address
      ddr_ba         : out std_logic_vector (1 downto 0); -- ddr bank address
      ddr_dq         : inout  std_logic_vector (dbits-1 downto 0);   -- ddr data

      sdi            : out ddrctrl_in_type;
      sdo            : in  ddrctrl_out_type;

      testen         : in std_ulogic;
      testrst        : in std_ulogic;
      scanen         : in std_ulogic;
      testoen        : in std_ulogic);
  end component;

  -- DDR/LPDDR PHY with data and checkbits on same bus, including pads
  component ddrphy_wrap_cbd is
    generic (
      tech     : integer := virtex2;
      MHz      : integer := 100;
      rstdelay : integer := 200;
      dbits    : integer := 16;
      chkbits  : integer := 0;
      padbits  : integer := 0;
      clk_mul  : integer := 2;
      clk_div  : integer := 2;
      rskew    : integer := 0;
      mobile   : integer := 0;
      abits    : integer := 14;
      nclk     : integer := 3;
      ncs      : integer := 2;
      scantest : integer := 0;
      phyiconf : integer := 0
      );
    port (
      rst            : in    std_ulogic;
      clk            : in    std_logic;   -- input clock
      clkout         : out   std_ulogic;  -- system clock
      clkoutret      : in    std_ulogic;  -- system clock return
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
      ddr_dm         : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);  -- ddr dm
      ddr_dqs        : inout std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);  -- ddr dqs
      ddr_ad         : out   std_logic_vector (abits-1 downto 0);   -- ddr address
      ddr_ba         : out   std_logic_vector (1 downto 0);         -- ddr bank address
      ddr_dq         : inout std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data

      sdi            : out   ddrctrl_in_type;
      sdo            : in    ddrctrl_out_type;

      testen         : in    std_ulogic;
      testrst        : in    std_ulogic;
      scanen         : in    std_ulogic;
      testoen        : in    std_ulogic
      );
  end component;

  -- DDR/LPDDR PHY with data and checkbits on same bus, without pads
  component ddrphy_wrap_cbd_wo_pads is
    generic (
      tech     : integer := virtex2;
      MHz      : integer := 100;
      rstdelay : integer := 200;
      dbits    : integer := 16;
      padbits  : integer := 0;
      clk_mul  : integer := 2;
      clk_div  : integer := 2;
      rskew    : integer := 0;
      mobile   : integer := 0;
      abits    : integer := 14;
      nclk     : integer := 3;
      ncs      : integer := 2;
      chkbits  : integer := 0;
      scantest : integer := 0
      );
    port (
      rst            : in    std_ulogic;
      clk            : in    std_logic;   -- input clock
      clkout         : out   std_ulogic;  -- system clock
      clkoutret      : in    std_ulogic;  -- system clock return
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
      ddr_dm         : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dm
      ddr_dqs_in     : in    std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
      ddr_dqs_out    : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
      ddr_dqs_oen    : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
      ddr_ad         : out   std_logic_vector (abits-1 downto 0);   -- ddr address
      ddr_ba         : out   std_logic_vector (1 downto 0);         -- ddr bank address
      ddr_dq_in      : in    std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
      ddr_dq_out     : out   std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
      ddr_dq_oen     : out   std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data

      sdi            : out   ddrctrl_in_type;
      sdo            : in    ddrctrl_out_type;

      testen         : in    std_ulogic;
      testrst        : in    std_ulogic;
      scanen         : in    std_ulogic;
      testoen        : in    std_ulogic
      );
  end component;

  component lpddr2phy_wrap_cbd_wo_pads is
    generic (
      tech     : integer := virtex2;
      dbits    : integer := 16;
      nclk     : integer := 3;
      ncs      : integer := 2;
      chkbits  : integer := 0;
      padbits  : integer := 0;
      scantest : integer := 0);
    port (
      rst            : in    std_ulogic;
      clkin          : in    std_ulogic;  -- input clock
      clkin2         : in    std_ulogic;  -- input clock
      clkout         : out   std_ulogic;  -- system clock
      clkoutret      : in    std_ulogic;  -- system clock return
      clkout2        : out   std_ulogic;  -- system clock
      lock           : out   std_ulogic;  -- DCM locked

      ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
      ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
      ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
      ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
      ddr_ca         : out   std_logic_vector(9 downto 0);                             -- ddr cmd/addr
      ddr_dm         : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);  -- ddr dm
      ddr_dqs_in     : in    std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);  -- ddr dqs
      ddr_dqs_out    : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);  -- ddr dqs
      ddr_dqs_oen    : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);  -- ddr dqs
      ddr_dq_in      : in    std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
      ddr_dq_out     : out   std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
      ddr_dq_oen     : out   std_logic_vector (dbits+padbits+chkbits-1 downto 0);
      sdi            : out   ddrctrl_in_type;
      sdo            : in    ddrctrl_out_type;

      testen         : in    std_ulogic;
      testrst        : in    std_ulogic;
      scanen         : in    std_ulogic;
      testoen        : in    std_ulogic);
  end component;

  -----------------------------------------------------------------------------
  -- Other components using DDRxSPA sub-components
  -----------------------------------------------------------------------------
  type ddravl_slv_in_type is record
    burstbegin : std_ulogic;
    addr       : std_logic_vector(31 downto 0);
    wdata      : std_logic_vector(256 downto 0);
    be         : std_logic_vector(32 downto 0);
    read_req   : std_ulogic;
    write_req  : std_ulogic;
    size       : std_logic_vector(3 downto 0);
  end record;

  type ddravl_slv_out_type is record
    ready       : std_ulogic;
    rdata_valid : std_ulogic;
    rdata       : std_logic_vector(256 downto 0);
  end record;

  constant ddravl_slv_in_none: ddravl_slv_in_type :=
    ('0',(others => '0'),(others => '0'),(others => '0'),'0','0',(others => '0'));

  component ahb2avl_async is
    generic (
      hindex     : integer := 0;
      haddr      : integer := 0;
      hmask      : integer := 16#f00#;
      burstlen   : integer := 8;
      nosync     : integer := 0;
      ahbbits    : integer := ahbdw;
      avldbits   : integer := 32;
      avlabits   : integer := 20
      );
    port (
      rst_ahb  : in  std_ulogic;
      clk_ahb  : in  std_ulogic;
      ahbsi    : in  ahb_slv_in_type;
      ahbso    : out ahb_slv_out_type;
      rst_avl  : in  std_ulogic;
      clk_avl  : in  std_ulogic;
      avlsi    : out ddravl_slv_in_type;
      avlso    : in  ddravl_slv_out_type
      );
  end component;

  -----------------------------------------------------------------------------
  -- MIG wrappers / bridges
  -----------------------------------------------------------------------------

  component ahb2mig_7series_ddr2_dq16_ad13_ba3
  generic(
    hindex     : integer := 0;
    haddr      : integer := 0;
    hmask      : integer := 16#f00#;
    pindex     : integer := 0;
    paddr      : integer := 0;
    pmask      : integer := 16#fff#;
    SIM_BYPASS_INIT_CAL : string := "OFF";
    SIMULATION : string  := "FALSE";
    USE_MIG_INTERFACE_MODEL : boolean := false);
  port(
    ddr2_dq           : inout std_logic_vector(15 downto 0);
    ddr2_dqs_p        : inout std_logic_vector(1 downto 0);
    ddr2_dqs_n        : inout std_logic_vector(1 downto 0);
    ddr2_addr         : out   std_logic_vector(12 downto 0);
    ddr2_ba           : out   std_logic_vector(2 downto 0);
    ddr2_ras_n        : out   std_logic;
    ddr2_cas_n        : out   std_logic;
    ddr2_we_n         : out   std_logic;
    ddr2_reset_n      : out   std_logic;
    ddr2_ck_p         : out   std_logic_vector(0 downto 0);
    ddr2_ck_n         : out   std_logic_vector(0 downto 0);
    ddr2_cke          : out   std_logic_vector(0 downto 0);
    ddr2_cs_n         : out   std_logic_vector(0 downto 0);
    ddr2_dm           : out   std_logic_vector(1 downto 0);
    ddr2_odt          : out   std_logic_vector(0 downto 0);
    ahbso             : out   ahb_slv_out_type;
    ahbsi             : in    ahb_slv_in_type;
    apbi              : in    apb_slv_in_type;
    apbo              : out   apb_slv_out_type;
    calib_done        : out   std_logic;
    rst_n_syn         : in    std_logic;
    rst_n_async       : in    std_logic;
    clk_amba          : in    std_logic;
    sys_clk_i         : in    std_logic;
    clk_ref_i         : in    std_logic;
    ui_clk            : out   std_logic;
    ui_clk_sync_rst   : out   std_logic);
  end component ;

  component ahb2mig_7series_ddr3_dq16_ad15_ba3
  generic(
    hindex                  : integer := 0;
    haddr                   : integer := 0;
    hmask                   : integer := 16#f00#;
    pindex                  : integer := 0;
    paddr                   : integer := 0;
    pmask                   : integer := 16#fff#;
    maxwriteburst           : integer := 8;
    maxreadburst            : integer := 8;
    SIM_BYPASS_INIT_CAL     : string  := "OFF";
    SIMULATION              : string  := "FALSE";
    USE_MIG_INTERFACE_MODEL : boolean := false
  );
  port(
    ddr3_dq           : inout std_logic_vector(15 downto 0);
    ddr3_dqs_p        : inout std_logic_vector(1 downto 0);
    ddr3_dqs_n        : inout std_logic_vector(1 downto 0);
    ddr3_addr         : out   std_logic_vector(14 downto 0);
    ddr3_ba           : out   std_logic_vector(2 downto 0);
    ddr3_ras_n        : out   std_logic;
    ddr3_cas_n        : out   std_logic;
    ddr3_we_n         : out   std_logic;
    ddr3_reset_n      : out   std_logic;
    ddr3_ck_p         : out   std_logic_vector(0 downto 0);
    ddr3_ck_n         : out   std_logic_vector(0 downto 0);
    ddr3_cke          : out   std_logic_vector(0 downto 0);
    ddr3_dm           : out   std_logic_vector(1 downto 0);
    ddr3_odt          : out   std_logic_vector(0 downto 0);
    ahbso             : out   ahb_slv_out_type;
    ahbsi             : in    ahb_slv_in_type;
    apbi              : in    apb_slv_in_type;
    apbo              : out   apb_slv_out_type;
    calib_done        : out   std_logic;
    rst_n_syn         : in    std_logic;
    rst_n_async       : in    std_logic;
    clk_amba          : in    std_logic;
    sys_clk_i         : in    std_logic;
--    clk_ref_i         : in    std_logic;
    ui_clk            : out   std_logic;
    ui_clk_sync_rst   : out   std_logic
   );
  end component ;

end package;
