--  COPYRIGHT (C) 2015, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--   @project      Module Message Interface 64
-- =============================================================================
--   @file         mmi64_m_ahbm_pkg.vhd
--   @author       Sebastian Fluegel
--   @email        sebastian.fluegel@prodesign-europe.com
--   @brief        MMI64 AHB master VHDL package
-- =============================================================================

library ieee;
    use ieee.std_logic_1164.all;
library work;
    use work.mmi64_pkg.all;

package mmi64_m_ahbm_comp is
  component mmi64_m_ahbm is
    generic (
      MODULE_ID  : mmi64_module_id_t  := X"00000000";   -- MMI64 Module Identify code
      AHB_DATA_W : integer            := 64;            -- AHB data width (8,16,32, or 64 bit)
      ENDIANESS  : integer            := 1              -- AHB endianess  (0=little-endian, 1=big-endian)
    );
    port (
      ---------------------------
      -- AHB interface
      ---------------------------
      -- Global signals
      ahb_hclk            : in  std_ulogic;           -- Global clock signal
      ahb_hreset_n        : in  std_ulogic;           -- Global reset signal, active LOW
      -- AHB Master port
      ahb_hrequest_o      : out std_ulogic;
      ahb_hgrant_i        : in  std_ulogic;
      ahb_haddr_o         : out std_ulogic_vector(31 downto 0);
      ahb_hwrite_o        : out std_ulogic;
      ahb_htrans_o        : out std_ulogic_vector(1 downto 0);
      ahb_hsize_o         : out std_ulogic_vector(2 downto 0);
      ahb_hburst_o        : out std_ulogic_vector(2 downto 0);
      ahb_hprot_o         : out std_ulogic_vector(3 downto 0);
      ahb_hwdata_o        : out std_ulogic_vector(AHB_DATA_W-1 downto 0);
      ahb_hrdata_i        : in  std_ulogic_vector(AHB_DATA_W-1 downto 0);
      ahb_hresp_i         : in  std_ulogic_vector(1 downto 0);
      ahb_hready_i        : in  std_ulogic;

      ---------------------------
      -- MMI64 interface
      ---------------------------
      mmi64_clk           : in  std_ulogic;
      mmi64_reset         : in  std_ulogic;
      mmi64_h_up_d_o      : out std_ulogic_vector(63 downto 0);
      mmi64_h_up_valid_o  : out std_ulogic;
      mmi64_h_up_accept_i : in  std_ulogic;
      mmi64_h_up_start_o  : out std_ulogic;
      mmi64_h_up_stop_o   : out std_ulogic;
      mmi64_h_dn_d_i      : in  std_ulogic_vector(63 downto 0);
      mmi64_h_dn_valid_i  : in  std_ulogic;
      mmi64_h_dn_accept_o : out std_ulogic;
      mmi64_h_dn_start_i  : in  std_ulogic;
      mmi64_h_dn_stop_i   : in  std_ulogic
    );
  end component mmi64_m_ahbm;

end package mmi64_m_ahbm_comp;
