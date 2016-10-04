-- =============================================================================
--  COPYRIGHT (C) 2014, 2015 Pro Design Electronic GmbH
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
--!  @file         mmi64_m_upstreamif_e.vhd
--!  @author       mberger
--!  @brief        MMI64 module to implement a data upstream interface
--!                (entity and component declaration package).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.rtl_templates.all;

--! @brief   MMI64 module mmi64_m_upstreamif provides a upstream interface for direct data transfer to the host
--! @details mmi64_m_upstreamif provides a interface to transfer data directly to the host. The
--!          host application waits within a thread until data were received from the hardware.
--!          Once setup the host does not need to re-initiate any data transfers.
--!          After reset the upstream interface is disabled and will be enabled during the initial
--!          setup process by the host application. During this setup also the max. MMI64 message size
--!          will be configured. If disabled upstream_accept_o is always '0'. The real size of the
--!          MMI64 message is lower than the maximum programmed value if upstream_valid_i goes low.

entity mmi64_m_upstreamif is
    generic (
      MODULE_ID         : mmi64_module_id_t  := X"00000000"; --! unique id of the module instance
      BUFF_AWIDTH       : natural                            --! address bitwidth of the FIFO memory
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

      -- connections to upstream data interface
      upstream_clk        : in  std_ulogic;    --! clock of the upstream data interface
      upstream_reset      : in  std_ulogic;    --! reset of the upstream data interface
      upstream_d_i        : in mmi64_data_t;   --! data interface: input
      upstream_valid_i    : in  std_ulogic;    --! data interface: data valid
      upstream_accept_o   : out std_ulogic     --! data interface: accept
      );
end entity mmi64_m_upstreamif;

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.rtl_templates.all;

--! @brief   MMI64 module mmi64_m_upstreamif_flush is the enhanced version of mmi64_m_upstreamif
--! @details Compared to mmi64_m_upstreamif the mmi64_m_upstreamif_flush module further provides
--!          an handshake upstream_flush_req and upstream_flush_ack to initiate the data transfer
--!          of all remaining data within the FIFO independent of the minimal message size.
--!          To initiate a flush operation set the signal upstream_flush_req to '1' and wait
--!          until upstream_flush_ack becomes '1' too. Thereafter reset upstream_flush_req to '0'
--!          and wait until upstream_flush_ack becomes '0' too before initiating a new flush
--!          operation.
--!          Additionally the signal upstream_fifo_count is added which reports the current fill
--!          level of the FIFO.
--!          The core functionality is the same as with mmi64_m_upstreamif.

entity mmi64_m_upstreamif_flush is
  generic (
    MODULE_ID   :    mmi64_module_id_t := X"00000000";  --! unique id of the module instance
    BUFF_AWIDTH :    natural                            --! address bitwidth of the FIFO memory
    );
  port (
    -- clock and reset
    mmi64_clk   : in std_ulogic;                        --! clock of mmi64 domain
    mmi64_reset : in std_ulogic;                        --! reset of mmi64 domain

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

    -- connections to upstream data interface
    upstream_clk          : in  std_ulogic;    --! clock of the upstream data interface
    upstream_reset        : in  std_ulogic;    --! reset of the upstream data interface
    upstream_d_i          : in  mmi64_data_t;  --! data interface: input
    upstream_valid_i      : in  std_ulogic;    --! data interface: data valid
    upstream_accept_o     : out std_ulogic;    --! data interface: accept
    upstream_flush_req_i  : in  std_ulogic;    --! requests to flush the upstream FIFO
    upstream_flush_ack_o  : out std_ulogic;    --! signals that the flush operation is done
    upstream_fifo_count_o : out std_ulogic_vector(BUFF_AWIDTH downto 0)
                                               --! reports the actual FIFO fill level
    );
end entity mmi64_m_upstreamif_flush;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.rtl_templates.all;

--! component declaration package for mmi64_m_upstreamif
package mmi64_m_upstreamif_comp is

  --! see description of entity mmi64_m_upstreamif
  component mmi64_m_upstreamif
    generic (
      MODULE_ID         : mmi64_module_id_t  := X"00000000";   --! unique id of the module instance
      BUFF_AWIDTH       : natural                              --! address bitwidth of the FIFO memory
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

      -- connections to upstream data interface
      upstream_clk        : in  std_ulogic;    --! clock of the upstream data interface
      upstream_reset      : in  std_ulogic;    --! reset of the upstream data interface
      upstream_d_i        : in mmi64_data_t;   --! data interface: input
      upstream_valid_i    : in  std_ulogic;    --! data interface: data valid
      upstream_accept_o  : out std_ulogic      --! data interface: accept
      );
  end component;

  component mmi64_m_upstreamif_flush
    generic (
      MODULE_ID         : mmi64_module_id_t  := X"00000000"; --! unique id of the module instance
      BUFF_AWIDTH       : natural                            --! address bitwidth of the FIFO memory
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

      -- connections to upstream data interface
      upstream_clk         : in  std_ulogic;    --! clock of the upstream data interface
      upstream_reset       : in  std_ulogic;    --! reset of the upstream data interface
      upstream_d_i         : in mmi64_data_t;   --! data interface: input
      upstream_valid_i     : in  std_ulogic;    --! data interface: data valid
      upstream_accept_o    : out std_ulogic;    --! data interface: accept
      upstream_flush_req_i : in  std_ulogic;    --! requests to flush the upstream FIFO
      upstream_flush_ack_o : out std_ulogic;    --! signals that the flush operation is done
      upstream_fifo_count_o: out std_ulogic_vector(BUFF_AWIDTH downto 0)
                                               --! reports the actual FIFO fill level
      );
  end component;

end package mmi64_m_upstreamif_comp;
