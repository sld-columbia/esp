-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2013, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--!  @project      proFPGA
-- =============================================================================
--!  @file         profpga_mb.vhd
--!  @author       Sebastian Fluegel
--!  @email        sebastian.fluegel@prodesign-europe.com
--!  @brief        proFPGA mainboard simulation model.
-- =============================================================================


--! TODO: check port naming mmi64_p_muxdemux since regular mmi64 naming scheme breaks on bidirectional modules. Also check if this is called a phy since bridge seams to be more appropriate!

package profpga_mb_pkg is

  -- number of master beats on mainboard (clock and associated sync)
  constant MASTER_BEAT_COUNT : natural := 8;

  -- number of external clocks
  constant EXT_CLOCK_COUNT : natural := 4;

  -- number of source clocks per fpga module (clock and associated sync)
  constant SRC_CLOCK_COUNT : natural := 4;

  -- bit width of DMBI bus transferring MMI64 domain signals between fpga module and mainboard
  constant DMBI_BUS_WIDTH : natural := 20;

end profpga_mb_pkg;

--
