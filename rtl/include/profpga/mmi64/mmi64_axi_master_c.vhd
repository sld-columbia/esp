-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2014, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : MMI64 (Module Message Interface)
--  Module/Entity : mmi64_axi_master (Entity-Component/Package)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  MMI64 AXI 4 master
-- =============================================================================

------------------------
-- Component/Package  --
------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.rtl_templates.all;
use work.mmi64_pkg.all;               --! MMI64 definitions
use work.axi_pkg.all;                 --! AXI definitions
package mmi64_axi_master_comp is
  component mmi64_axi_master is
  generic (
    MODULE_ID        : mmi64_module_id_t  := X"00000000";
    AXI_ID_WIDTH     : integer := 2;
    AXI_ADDR_WIDTH   : integer := 32;
    AXI_USER_WIDTH   : integer := 4;
    AXI_DATA_WIDTH   : integer := 64
  );
  port (
    axi_clk             : in std_ulogic;
    axi_reset_n         : in std_ulogic;
    axim_awid_o         : out std_ulogic_vector(AXI_ID_WIDTH-1 downto 0);
    axim_awaddr_o       : out std_ulogic_vector(AXI_ADDR_WIDTH-1 downto 0);
    axim_awlen_o        : out std_ulogic_vector(AXI_LEN_WIDTH-1 downto 0);
    axim_awsize_o       : out std_ulogic_vector(AXI_SIZE_WIDTH-1 downto 0);
    axim_awburst_o      : out std_ulogic_vector(AXI_BURST_WIDTH-1 downto 0);
    axim_awlock_o       : out std_ulogic_vector(AXI_LOCK_WIDTH-1 downto 0);
    axim_awcache_o      : out std_ulogic_vector(AXI_CACHE_WIDTH-1 downto 0);
    axim_awprot_o       : out std_ulogic_vector(AXI_PROT_WIDTH-1 downto 0);
    axim_awqos_o        : out std_ulogic_vector(AXI_QOS_WIDTH-1 downto 0);
    axim_awregion_o     : out std_ulogic_vector(AXI_REGION_WIDTH-1 downto 0);
    axim_awuser_o       : out std_ulogic_vector(AXI_USER_WIDTH-1 downto 0);
    axim_awvalid_o      : out std_ulogic;
    axim_awready_i      : in  std_ulogic;
    axim_wdata_o        : out std_ulogic_vector(AXI_DATA_WIDTH-1 downto 0);
    axim_wstrb_o        : out std_ulogic_vector(AXI_DATA_WIDTH/8-1 downto 0);
    axim_wlast_o        : out std_ulogic;
    axim_wuser_o        : out std_ulogic_vector(AXI_USER_WIDTH-1 downto 0);
    axim_wvalid_o       : out std_ulogic;
    axim_wready_i       : in  std_ulogic;
    axim_bid_i          : in  std_ulogic_vector(AXI_ID_WIDTH-1 downto 0);
    axim_bresp_i        : in  std_ulogic_vector(AXI_RESP_WIDTH-1 downto 0);
    axim_buser_i        : in  std_ulogic_vector(AXI_USER_WIDTH-1 downto 0);
    axim_bvalid_i       : in  std_ulogic;
    axim_bready_o       : out std_ulogic;
    axim_arid_o         : out std_ulogic_vector(AXI_ID_WIDTH-1 downto 0);
    axim_araddr_o       : out std_ulogic_vector(AXI_ADDR_WIDTH-1 downto 0);
    axim_arlen_o        : out std_ulogic_vector(AXI_LEN_WIDTH-1 downto 0);
    axim_arsize_o       : out std_ulogic_vector(AXI_SIZE_WIDTH-1 downto 0);
    axim_arburst_o      : out std_ulogic_vector(AXI_BURST_WIDTH-1 downto 0);
    axim_arlock_o       : out std_ulogic_vector(AXI_LOCK_WIDTH-1 downto 0);
    axim_arcache_o      : out std_ulogic_vector(AXI_CACHE_WIDTH-1 downto 0);
    axim_arprot_o       : out std_ulogic_vector(AXI_PROT_WIDTH-1 downto 0);
    axim_arqos_o        : out std_ulogic_vector(AXI_QOS_WIDTH-1 downto 0);
    axim_arregion_o     : out std_ulogic_vector(AXI_REGION_WIDTH-1 downto 0);
    axim_aruser_o       : out std_ulogic_vector(AXI_USER_WIDTH-1 downto 0);
    axim_arvalid_o      : out std_ulogic;
    axim_arready_i      : in  std_ulogic;
    axim_rid_i          : in  std_ulogic_vector(AXI_ID_WIDTH-1 downto 0);
    axim_rdata_i        : in  std_ulogic_vector(AXI_DATA_WIDTH-1 downto 0);
    axim_rresp_i        : in  std_ulogic_vector(AXI_RESP_WIDTH-1 downto 0);
    axim_rlast_i        : in  std_ulogic;
    axim_ruser_i        : in  std_ulogic_vector(AXI_USER_WIDTH-1 downto 0);
    axim_rvalid_i       : in  std_ulogic;
    axim_rready_o       : out std_ulogic;
    mmi64_clk           : in  std_ulogic;
    mmi64_reset         : in  std_ulogic;
    mmi64_h_up_d_o      : out mmi64_data_t;
    mmi64_h_up_valid_o  : out std_ulogic;
    mmi64_h_up_accept_i : in  std_ulogic;
    mmi64_h_up_start_o  : out std_ulogic;
    mmi64_h_up_stop_o   : out std_ulogic;
    mmi64_h_dn_d_i      : in  mmi64_data_t;
    mmi64_h_dn_valid_i  : in  std_ulogic;
    mmi64_h_dn_accept_o : out std_ulogic;
    mmi64_h_dn_start_i  : in  std_ulogic;
    mmi64_h_dn_stop_i   : in  std_ulogic
  );
end component mmi64_axi_master;

end package mmi64_axi_master_comp;
