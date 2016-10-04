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
--!  @project      Module Message Interface 64
-- =============================================================================
--!  @file         mmi64_async_buffer_e.vhd
--!  @author       Dragan Dukaric
--!  @email        dragan.dukaric@prodesign-europe.com
--!  @brief        Buffer for clock domain crossing
--                 (entity and component declaration package).
-- =============================================================================

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.mmi64_pkg.all;                 --! MMI64 declarations
  use work.rtl_templates.all;             --! Common functions
  use work.generic_ram_comp.all;          --! Generic Memory
  use work.afifo_core_pkg.all;            --! Async FIFO core
  use work.mmi64_deserializer_comp.all;   --! MMI64 data deserializer

architecture rtl of mmi64_async_buffer is
-------------------------------------------------
--! Interconnection signals
-------------------------------------------------
  signal mmi64_h_reset_n                  : std_ulogic;                                     --! Reset host logic (Low active)
  signal mmi64_m_reset_n                  : std_ulogic;                                     --! Reset module logic (Low active)
  --! Downlink
  signal dl_wr_enable                     : std_ulogic;                                     --! Write enable memory
  signal dl_wr_address                    : std_ulogic_vector(BUFF_AWIDTH-1 downto 0);      --! Memory write address
  signal dl_wr_data                       : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Memory write data
  signal dl_rd_enable                     : std_ulogic;                                     --! Read enable memory
  signal dl_rd_address                    : std_ulogic_vector(BUFF_AWIDTH-1 downto 0);      --! Memory read address
  signal dl_rd_data                       : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Memory read data
  signal dl_fifo_wenable_h                : std_ulogic;                                     --! Enable downstream FIFO (host clock domain)
  signal dl_fifo_empty_m                  : std_ulogic;                                     --! Enable downstream FIFO empty (module clock domain)
  signal dl_fifo_full_h                   : std_ulogic;                                     --! Downstream FIFO full(host clock domain)
  signal dl_fifo_renable_m                : std_ulogic;                                     --! Enable downstream FIFO (module clock domain)
  signal dl_fifo_wdata_h                  : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Write data downstream FIFO (host clock domain)
  signal dl_fifo_rdata_m                  : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Read data downstream FIFO (module clock domain)
  signal dl_deserializer_data             : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Deserializer input data
  signal dl_deserializer_valid            : std_ulogic;                                     --! Deserializer input valid
  signal dl_deserializer_ready            : std_ulogic;                                     --! Deserializer ready to receive new data
  -- Uplink
  signal ul_wr_enable                     : std_ulogic;                                     --! Write enable memory
  signal ul_wr_address                    : std_ulogic_vector(BUFF_AWIDTH-1 downto 0);      --! Memory write address
  signal ul_wr_data                       : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Memory write data
  signal ul_rd_enable                     : std_ulogic;                                     --! Read enable memory
  signal ul_rd_address                    : std_ulogic_vector(BUFF_AWIDTH-1 downto 0);      --! Memory read address
  signal ul_rd_data                       : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Memory read data
  signal ul_fifo_wenable_m                : std_ulogic;                                     --! Enable downstream FIFO (module clock domain)
  signal ul_fifo_empty_h                  : std_ulogic;                                     --! Enable downstream FIFO empty (host clock domain)
  signal ul_fifo_full_m                   : std_ulogic;                                     --! Downstream FIFO full(module clock domain)
  signal ul_fifo_renable_h                : std_ulogic;                                     --! Enable downstream FIFO (host clock domain)
  signal ul_fifo_wdata_m                  : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Write data downstream FIFO (module clock domain)
  signal ul_fifo_rdata_h                  : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Read data downstream FIFO (host clock domain)
  signal ul_deserializer_data             : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0); --! Deserializer input data
  signal ul_deserializer_valid            : std_ulogic;                                     --! Deserializer input valid
  signal ul_deserializer_ready            : std_ulogic;                                     --! Deserializer ready to receive new data



begin 
-------------------------------------------------
--! General logic
-------------------------------------------------
  mmi64_h_reset_n <= not mmi64_h_reset;
  mmi64_m_reset_n <= not mmi64_m_reset;

-------------------------------------------------
--! Downstream path
-------------------------------------------------
  -- Handshake with host interface
  dl_fifo_wenable_h   <= mmi64_h_dn_valid_i;
  dl_fifo_wdata_h     <= mmi64_h_dn_d_i;
  mmi64_h_dn_accept_o <= not dl_fifo_full_h;
  
  -- FIFO core
  u_dl_afifo_core : afifo_core
  generic map(
    DATA_WIDTH               => MMI64_DATA_WIDTH,
    ADDR_WIDTH               => BUFF_AWIDTH,
    FIRST_WORD_FALLS_THROUGH => true
  )  port map(
    --Write clock domain
    wr_clk      => mmi64_h_clk,
    wr_reset_n  => mmi64_h_reset_n,
    wr_enable_i => dl_fifo_wenable_h,
    wr_data_i   => dl_fifo_wdata_h,
    wr_full_o   => dl_fifo_full_h,
    wr_diff_o   => open,
    -- Read clock domain
    rd_clk      => mmi64_m_clk,
    rd_reset_n  => mmi64_m_reset_n,
    rd_enable_i => dl_fifo_renable_m,
    rd_data_o   => dl_fifo_rdata_m,
    rd_empty_o  => dl_fifo_empty_m,
    rd_diff_o   => open,
    -- Memory interface
    wea_o      => dl_wr_enable,
    addra_o    => dl_wr_address,
    dataa_o    => dl_wr_data,
    enb_o      => dl_rd_enable,
    addrb_o    => dl_rd_address,
    datab_i    => dl_rd_data
  );
  
  --! FIFO storage memory
  u_dl_generic_dpram : generic_dpram
  generic map(
    ADDR_W => BUFF_AWIDTH,
    DATA_W => MMI64_DATA_WIDTH
  ) port map(
    clk1   => mmi64_h_clk,
    ce1    => '1',
    we1    => dl_wr_enable,
    addr1  => dl_wr_address,
    wdata1 => dl_wr_data,
    rdata1 => open,
  
    clk2   => mmi64_m_clk,
    ce2    => dl_rd_enable,
    we2    => '0',
    addr2  => dl_rd_address,
    wdata2 => (others=>'0'),
    rdata2 => dl_rd_data
  );

  --! FIFO-deserializer handshake
  dl_fifo_renable_m     <= dl_deserializer_ready;
  dl_deserializer_data  <= dl_fifo_rdata_m;
  dl_deserializer_valid <= not dl_fifo_empty_m;
  
  u_dl_mmi64_deserializer: mmi64_deserializer
  generic map (
    SERIAL_DATA_WIDTH   => 64
    )
  port map (
    mmi64_clk           => mmi64_m_clk,
    mmi64_reset         => mmi64_m_reset,
    serial_d_i          => dl_deserializer_data,
    serial_valid_i      => dl_deserializer_valid,
    serial_ready_o      => dl_deserializer_ready,
    mmi64_m_dn_d_o      => mmi64_m_dn_d_o,
    mmi64_m_dn_valid_o  => mmi64_m_dn_valid_o,
    mmi64_m_dn_accept_i => mmi64_m_dn_accept_i,
    mmi64_m_dn_start_o  => mmi64_m_dn_start_o,
    mmi64_m_dn_stop_o   => mmi64_m_dn_stop_o
  ); 

-------------------------------------------------
--! Upstream path
-------------------------------------------------
  -- Handshake with host interface
  ul_fifo_wenable_m   <= mmi64_m_up_valid_i;
  ul_fifo_wdata_m     <= mmi64_m_up_d_i;
  mmi64_m_up_accept_o <= not ul_fifo_full_m;
  
  -- FIFO core
  u_ul_afifo_core : afifo_core
  generic map(
    DATA_WIDTH               => MMI64_DATA_WIDTH,
    ADDR_WIDTH               => BUFF_AWIDTH,
    FIRST_WORD_FALLS_THROUGH => true
  )  port map(
    --Write clock domain
    wr_clk      => mmi64_m_clk,
    wr_reset_n  => mmi64_m_reset_n,
    wr_enable_i => ul_fifo_wenable_m,
    wr_data_i   => ul_fifo_wdata_m,
    wr_full_o   => ul_fifo_full_m,
    wr_diff_o   => open,
    -- Read clock domain
    rd_clk      => mmi64_h_clk,
    rd_reset_n  => mmi64_h_reset_n,
    rd_enable_i => ul_fifo_renable_h,
    rd_data_o   => ul_fifo_rdata_h,
    rd_empty_o  => ul_fifo_empty_h,
    rd_diff_o   => open,
    -- Memory interface
    wea_o      => ul_wr_enable,
    addra_o    => ul_wr_address,
    dataa_o    => ul_wr_data,
    enb_o      => ul_rd_enable,
    addrb_o    => ul_rd_address,
    datab_i    => ul_rd_data
  );
  
  --! FIFO storage memory
  u_ul_generic_dpram : generic_dpram
  generic map(
    ADDR_W => BUFF_AWIDTH,
    DATA_W => MMI64_DATA_WIDTH
  ) port map(
    clk1   => mmi64_m_clk,
    ce1    => '1',
    we1    => ul_wr_enable,
    addr1  => ul_wr_address,
    wdata1 => ul_wr_data,
    rdata1 => open,
  
    clk2   => mmi64_h_clk,
    ce2    => ul_rd_enable,
    we2    => '0',
    addr2  => ul_rd_address,
    wdata2 => (others=>'0'),
    rdata2 => ul_rd_data
  );

  --! FIFO-deserializer handshake
  ul_fifo_renable_h     <= ul_deserializer_ready;
  ul_deserializer_data  <= ul_fifo_rdata_h;
  ul_deserializer_valid <= not ul_fifo_empty_h;
  
  u_ul_mmi64_deserializer: mmi64_deserializer
  generic map (
    SERIAL_DATA_WIDTH   => 64
    )
  port map (
    mmi64_clk           => mmi64_h_clk,
    mmi64_reset         => mmi64_h_reset,
    serial_d_i          => ul_deserializer_data,
    serial_valid_i      => ul_deserializer_valid,
    serial_ready_o      => ul_deserializer_ready,
    mmi64_m_dn_d_o      => mmi64_h_up_d_o,
    mmi64_m_dn_valid_o  => mmi64_h_up_valid_o,
    mmi64_m_dn_accept_i => mmi64_h_up_accept_i,
    mmi64_m_dn_start_o  => mmi64_h_up_start_o,
    mmi64_m_dn_stop_o   => mmi64_h_up_stop_o
  );  

end rtl;
-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2013-09-27  First draft.
-- =============================================================================