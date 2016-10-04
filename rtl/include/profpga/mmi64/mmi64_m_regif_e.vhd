-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2012, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--!  @project      Module Message Interface 64
-- =============================================================================
--!  @file         mmi64_m_regif_e.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 module for accessing register files
--!                (entity and component declaration package).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.rtl_templates.all;

--! @brief   MMI64 module mmi64_m_regif provides access to a register file via module message interface.
--! @details mmi64_m_regif provides a simple local register read and write interface to a register files
--!          of arbritary register range and data width. The register file itself is not part of this module.
--!          mmi64_m_regif can be customized using generics MMI64_REGIF_REGISTER_RANGE and REGISTER_WIDTH.
--!          See module regfile for an example register file compatible to mmi64_m_regif.
--!          mmi64_m_regif and register file have to share the same clock domain.

entity mmi64_m_regif is
    generic (
      MODULE_ID         : mmi64_module_id_t  := X"00000000";  --! unique id of the module instance
      REGISTER_COUNT    : positive := 16;      --! number of registers in register file
      REGISTER_WIDTH    : positive := 16;      --! register data width in bit
      READ_BUFFER_DEPTH : positive := 4        --! number of entries in read data buffer
      );
    port (
      -- clock and reset
      mmi64_clk   : in std_ulogic;             --! clock of mmi64 domain
      mmi64_reset : in std_ulogic;             --! reset of mmi64 domain

      -- connections to mmi64 router
      mmi64_h_dn_d_i      : in  mmi64_data_t;  --! downstream data from router
      mmi64_h_dn_valid_i  : in  std_ulogic;    --! downstream data valid from router
      mmi64_h_dn_accept_o : out std_ulogic;    --! downstream data accept to router
      mmi64_h_dn_start_i  : in  std_ulogic;    --! downstream data start (first byte of transfer) from router
      mmi64_h_dn_stop_i   : in  std_ulogic;    --! downstream data end (last byte of transfer) from router

      mmi64_h_up_d_o      : out mmi64_data_t;  --! upstream data output to router
      mmi64_h_up_valid_o  : out std_ulogic;    --! upstream data valid to router
      mmi64_h_up_accept_i : in  std_ulogic;    --! upstream data accept from router
      mmi64_h_up_start_o  : out std_ulogic;    --! upstream data start (first byte of transfer) to router
      mmi64_h_up_stop_o   : out std_ulogic;    --! upstream data end (last byte of transfer) to router

      -- connections to register interface
      reg_en_o            : out std_ulogic;                                         --! register access enable
      reg_we_o            : out std_ulogic;                                         --! register write enable
      reg_addr_o          : out std_ulogic_vector(log2(REGISTER_COUNT)-1 downto 0); --! register read/write address
      reg_wdata_o         : out std_ulogic_vector(REGISTER_WIDTH-1 downto 0);       --! register data output
      reg_accept_i        : in  std_ulogic;                                         --! register data command accepted
      reg_rdata_i         : in  std_ulogic_vector(REGISTER_WIDTH-1 downto 0);       --! register input data
      reg_rvalid_i        : in  std_ulogic                                          --! register input data valid
      );
end entity mmi64_m_regif;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.rtl_templates.all;

--! component declaration package for mmi64_m_regif
package mmi64_m_regif_comp is

  --! see description of entity mmi64_m_regif
  component mmi64_m_regif
    generic (
      MODULE_ID         : mmi64_module_id_t  := X"00000000";  --! unique id of the module instance
      REGISTER_COUNT    : positive := 16;      --! number of registers in register file
      REGISTER_WIDTH    : positive := 16;      --! register data width in bit
      READ_BUFFER_DEPTH : positive := 4        --! number of entries in read data buffer
      );
    port (
      -- clock and reset
      mmi64_clk   : in std_ulogic;             --! clock of mmi64 domain
      mmi64_reset : in std_ulogic;             --! reset of mmi64 domain

      -- connections to mmi64 router
      mmi64_h_dn_d_i      : in  mmi64_data_t;  --! downstream data from router
      mmi64_h_dn_valid_i  : in  std_ulogic;    --! downstream data valid from router
      mmi64_h_dn_accept_o : out std_ulogic;    --! downstream data accept to router
      mmi64_h_dn_start_i  : in  std_ulogic;    --! downstream data start (first byte of transfer) from router
      mmi64_h_dn_stop_i   : in  std_ulogic;    --! downstream data end (last byte of transfer) from router

      mmi64_h_up_d_o      : out mmi64_data_t;  --! upstream data output to router
      mmi64_h_up_valid_o  : out std_ulogic;    --! upstream data valid to router
      mmi64_h_up_accept_i : in  std_ulogic;    --! upstream data accept from router
      mmi64_h_up_start_o  : out std_ulogic;    --! upstream data start (first byte of transfer) to router
      mmi64_h_up_stop_o   : out std_ulogic;    --! upstream data end (last byte of transfer) to router

      -- connections to register interface
      reg_en_o            : out std_ulogic;                                         --! register access enable
      reg_we_o            : out std_ulogic;                                         --! register write enable
      reg_addr_o          : out std_ulogic_vector(log2(REGISTER_COUNT)-1 downto 0); --! register read/write address
      reg_wdata_o         : out std_ulogic_vector(REGISTER_WIDTH-1 downto 0);       --! register data output
      reg_accept_i        : in  std_ulogic;                                         --! register data command accepted
      reg_rdata_i         : in  std_ulogic_vector(REGISTER_WIDTH-1 downto 0);       --! register input data
      reg_rvalid_i        : in  std_ulogic                                          --! register input data valid
      );
  end component;

end package mmi64_m_regif_comp;
