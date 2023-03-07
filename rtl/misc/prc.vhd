--Copyright (c) 2011-2023 Columbia University, System Level Design Group
--SPDX-License-Identifier: Apache-2.0 

library ieee;
use ieee.std_logic_1164.all;
use work.esp_global.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.misc.all;
use work.devices.all;
use work.gencomp.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
-- pragma translate_on

entity prc_inst is
  generic (
    tech : integer);
  port (
      clk                               : in  std_logic;
      reset                             : in  std_logic;
      vsm_VS_0_rm_shutdown_req          : out std_logic;
      vsm_VS_0_rm_shutdown_ack          : in  std_logic;
      vsm_VS_0_rm_decouple              : out std_logic;
      vsm_VS_0_rm_reset                 : out std_logic;
      vsm_VS_0_event_error              : out std_logic;
      vsm_VS_0_sw_startup_req           : out std_logic;
      icap_clk                          : in  std_logic;
      icap_reset                        : in  std_logic;
      icap_i                            : in  std_logic_vector(31 downto 0);
      icap_o                            : out std_logic_vector(31 downto 0);
      icap_csib                         : out std_logic;
      icap_rdwrb                        : out std_logic;
      icap_avail                        : in std_logic;
      icap_prdone                       : in std_logic;
      icap_prerror                      : in std_logic;
      s_axi_reg_awaddr                  : in  std_logic_vector(31 downto 0);
      s_axi_reg_awvalid                 : in  std_logic;
      s_axi_reg_awready                 : out std_logic;
      s_axi_reg_wdata                   : in  std_logic_vector(31 downto 0);
      s_axi_reg_wvalid                  : in  std_logic;
      s_axi_reg_wready                  : out std_logic;
      s_axi_reg_bresp                   : out std_logic_vector(1 downto 0);
      s_axi_reg_bvalid                  : out std_logic;
      s_axi_reg_bready                  : in  std_logic;
      s_axi_reg_araddr                  : in  std_logic_vector(31 downto 0);
      s_axi_reg_arvalid                 : in  std_logic;
      s_axi_reg_arready                 : out std_logic;
      s_axi_reg_rdata                   : out std_logic_vector(31 downto 0);
      s_axi_reg_rresp                   : out std_logic_vector(1 downto 0);
      s_axi_reg_rvalid                  : out std_logic;
      s_axi_reg_rready                  : in  std_logic;
      m_axi_mem_araddr                  : out std_logic_vector(31 downto 0);
      m_axi_mem_arlen                   : out std_logic_vector(7 downto 0);
      m_axi_mem_arsize                  : out std_logic_vector(2 downto 0);
      m_axi_mem_arburst                 : out std_logic_vector(1 downto 0);
      m_axi_mem_arprot                  : out std_logic_vector(2 downto 0);
      m_axi_mem_arcache                 : out std_logic_vector(3 downto 0);
      m_axi_mem_aruser                  : out std_logic_vector(3 downto 0);
      m_axi_mem_arvalid                 : out std_logic;
      m_axi_mem_arready                 : in  std_logic;
      m_axi_mem_rdata                   : in  std_logic_vector(31 downto 0);
      m_axi_mem_rresp                   : in  std_logic_vector(1 downto 0);
      m_axi_mem_rlast                   : in  std_logic;
      m_axi_mem_rvalid                  : in  std_logic;
      m_axi_mem_rready                  : out std_logic);
 end;

architecture rtl of prc_inst is
  component prc_ctrlr_v7 is
    port (
      clk                               : in  std_logic;
      reset                             : in  std_logic;
      vsm_VS_0_rm_shutdown_req          : out std_logic;
      vsm_VS_0_rm_shutdown_ack          : in  std_logic;
      vsm_VS_0_rm_decouple              : out std_logic;
      vsm_VS_0_rm_reset                 : out std_logic;
      vsm_VS_0_event_error              : out std_logic;
      vsm_VS_0_sw_startup_req           : out std_logic;
      icap_clk                          : in  std_logic;
      icap_reset                        : in  std_logic;
      icap_i                            : in  std_logic_vector(31 downto 0);
      icap_o                            : out std_logic_vector(31 downto 0);
      icap_csib                         : out std_logic;
      icap_rdwrb                        : out std_logic;
      s_axi_reg_awaddr                  : in  std_logic_vector(31 downto 0);
      s_axi_reg_awvalid                 : in  std_logic;
      s_axi_reg_awready                 : out std_logic;
      s_axi_reg_wdata                   : in  std_logic_vector(31 downto 0);
      s_axi_reg_wvalid                  : in  std_logic;
      s_axi_reg_wready                  : out std_logic;
      s_axi_reg_bresp                   : out std_logic_vector(1 downto 0);
      s_axi_reg_bvalid                  : out std_logic;
      s_axi_reg_bready                  : in  std_logic;
      s_axi_reg_araddr                  : in  std_logic_vector(31 downto 0);
      s_axi_reg_arvalid                 : in  std_logic;
      s_axi_reg_arready                 : out std_logic;
      s_axi_reg_rdata                   : out std_logic_vector(31 downto 0);
      s_axi_reg_rresp                   : out std_logic_vector(1 downto 0);
      s_axi_reg_rvalid                  : out std_logic;
      s_axi_reg_rready                  : in  std_logic;
      m_axi_mem_araddr                  : out std_logic_vector(31 downto 0);
      m_axi_mem_arlen                   : out std_logic_vector(7 downto 0);
      m_axi_mem_arsize                  : out std_logic_vector(2 downto 0);
      m_axi_mem_arburst                 : out std_logic_vector(1 downto 0);
      m_axi_mem_arprot                  : out std_logic_vector(2 downto 0);
      m_axi_mem_arcache                 : out std_logic_vector(3 downto 0);
      m_axi_mem_aruser                  : out std_logic_vector(3 downto 0);
      m_axi_mem_arvalid                 : out std_logic;
      m_axi_mem_arready                 : in  std_logic;
      m_axi_mem_rdata                   : in  std_logic_vector(31 downto 0);
      m_axi_mem_rresp                   : in  std_logic_vector(1 downto 0);
      m_axi_mem_rlast                   : in  std_logic;
      m_axi_mem_rvalid                  : in  std_logic;
      m_axi_mem_rready                  : out std_logic);
    end component prc_ctrlr_v7;

  component prc_ctrlr_us is
    port (
      clk                               : in  std_logic;
      reset                             : in  std_logic;
      vsm_VS_0_rm_shutdown_req          : out std_logic;
      vsm_VS_0_rm_shutdown_ack          : in  std_logic;
      vsm_VS_0_rm_decouple              : out std_logic;
      vsm_VS_0_rm_reset                 : out std_logic;
      vsm_VS_0_event_error              : out std_logic;
      vsm_VS_0_sw_startup_req           : out std_logic;
      icap_clk                          : in  std_logic;
      icap_reset                        : in  std_logic;
      icap_i                            : in  std_logic_vector(31 downto 0);
      icap_o                            : out std_logic_vector(31 downto 0);
      icap_csib                         : out std_logic;
      icap_rdwrb                        : out std_logic;
      icap_avail                        : in std_logic;
      icap_prdone                       : in std_logic;
      icap_prerror                      : in std_logic;
      s_axi_reg_awaddr                  : in  std_logic_vector(31 downto 0);
      s_axi_reg_awvalid                 : in  std_logic;
      s_axi_reg_awready                 : out std_logic;
      s_axi_reg_wdata                   : in  std_logic_vector(31 downto 0);
      s_axi_reg_wvalid                  : in  std_logic;
      s_axi_reg_wready                  : out std_logic;
      s_axi_reg_bresp                   : out std_logic_vector(1 downto 0);
      s_axi_reg_bvalid                  : out std_logic;
      s_axi_reg_bready                  : in  std_logic;
      s_axi_reg_araddr                  : in  std_logic_vector(31 downto 0);
      s_axi_reg_arvalid                 : in  std_logic;
      s_axi_reg_arready                 : out std_logic;
      s_axi_reg_rdata                   : out std_logic_vector(31 downto 0);
      s_axi_reg_rresp                   : out std_logic_vector(1 downto 0);
      s_axi_reg_rvalid                  : out std_logic;
      s_axi_reg_rready                  : in  std_logic;
      m_axi_mem_araddr                  : out std_logic_vector(31 downto 0);
      m_axi_mem_arlen                   : out std_logic_vector(7 downto 0);
      m_axi_mem_arsize                  : out std_logic_vector(2 downto 0);
      m_axi_mem_arburst                 : out std_logic_vector(1 downto 0);
      m_axi_mem_arprot                  : out std_logic_vector(2 downto 0);
      m_axi_mem_arcache                 : out std_logic_vector(3 downto 0);
      m_axi_mem_aruser                  : out std_logic_vector(3 downto 0);
      m_axi_mem_arvalid                 : out std_logic;
      m_axi_mem_arready                 : in  std_logic;
      m_axi_mem_rdata                   : in  std_logic_vector(31 downto 0);
      m_axi_mem_rresp                   : in  std_logic_vector(1 downto 0);
      m_axi_mem_rlast                   : in  std_logic;
      m_axi_mem_rvalid                  : in  std_logic;
      m_axi_mem_rready                  : out std_logic);
    end component prc_ctrlr_us;

begin

  prc_v7: if tech = virtex7 generate
  prc_1: prc_ctrlr_v7
    port map (
      clk                       => clk,
      reset                     => reset,
      m_axi_mem_araddr          => m_axi_mem_araddr,
      m_axi_mem_arlen           => m_axi_mem_arlen,
      m_axi_mem_arsize          => m_axi_mem_arsize,
      m_axi_mem_arburst         => m_axi_mem_arburst,
      m_axi_mem_arprot          => m_axi_mem_arprot,
      m_axi_mem_arcache         => m_axi_mem_arcache,
      m_axi_mem_aruser          => m_axi_mem_aruser,
      m_axi_mem_arvalid         => m_axi_mem_arvalid,
      m_axi_mem_arready         => m_axi_mem_arready,
      m_axi_mem_rdata           => m_axi_mem_rdata,
      m_axi_mem_rresp           => m_axi_mem_rresp,
      m_axi_mem_rlast           => m_axi_mem_rlast,
      m_axi_mem_rvalid          => m_axi_mem_rvalid,
      m_axi_mem_rready          => m_axi_mem_rready,
      icap_clk                  => clk,
      icap_reset                => reset,
      icap_csib                 => icap_csib,
      icap_rdwrb                => icap_rdwrb,
      icap_i                    => icap_i,
      icap_o                    => icap_o,
      vsm_VS_0_rm_shutdown_ack  => vsm_VS_0_rm_shutdown_ack,
      vsm_VS_0_sw_startup_req   => vsm_VS_0_sw_startup_req,
      s_axi_reg_awaddr          => s_axi_reg_awaddr,
      s_axi_reg_awvalid         => s_axi_reg_awvalid,
      s_axi_reg_awready         => s_axi_reg_awready,
      s_axi_reg_wdata           => s_axi_reg_wdata,
      s_axi_reg_wvalid          => s_axi_reg_wvalid,
      s_axi_reg_wready          => s_axi_reg_wready,
      s_axi_reg_bresp           => s_axi_reg_bresp,
      s_axi_reg_bvalid          => s_axi_reg_bvalid,
      s_axi_reg_bready          => s_axi_reg_bready,
      s_axi_reg_araddr          => s_axi_reg_araddr,
      s_axi_reg_arvalid         => s_axi_reg_arvalid,
      s_axi_reg_arready         => s_axi_reg_arready,
      s_axi_reg_rdata           => s_axi_reg_rdata,
      s_axi_reg_rresp           => s_axi_reg_rresp,
      s_axi_reg_rvalid          => s_axi_reg_rvalid,
      s_axi_reg_rready          => s_axi_reg_rready);
  end generate prc_v7; 
 
  prc_us : if tech = virtexu or tech = virtexup generate
  prc_1: prc_ctrlr_us
    port map (
      clk                       => clk,
      reset                     => reset,
      m_axi_mem_araddr          => m_axi_mem_araddr,
      m_axi_mem_arlen           => m_axi_mem_arlen,
      m_axi_mem_arsize          => m_axi_mem_arsize,
      m_axi_mem_arburst         => m_axi_mem_arburst,
      m_axi_mem_arprot          => m_axi_mem_arprot,
      m_axi_mem_arcache         => m_axi_mem_arcache,
      m_axi_mem_aruser          => m_axi_mem_aruser,
      m_axi_mem_arvalid         => m_axi_mem_arvalid,
      m_axi_mem_arready         => m_axi_mem_arready,
      m_axi_mem_rdata           => m_axi_mem_rdata,
      m_axi_mem_rresp           => m_axi_mem_rresp,
      m_axi_mem_rlast           => m_axi_mem_rlast,
      m_axi_mem_rvalid          => m_axi_mem_rvalid,
      m_axi_mem_rready          => m_axi_mem_rready,
      icap_clk                  => clk,
      icap_reset                => reset,
      icap_csib                 => icap_csib,
      icap_rdwrb                => icap_rdwrb,
      icap_i                    => icap_i,
      icap_o                    => icap_o,
      vsm_VS_0_rm_shutdown_ack  => vsm_VS_0_rm_shutdown_ack,
      vsm_VS_0_sw_startup_req   => vsm_VS_0_sw_startup_req,
      icap_avail                => icap_avail,
      icap_prdone               => icap_prdone,
      icap_prerror              => icap_prerror,
      s_axi_reg_awaddr          => s_axi_reg_awaddr,
      s_axi_reg_awvalid         => s_axi_reg_awvalid,
      s_axi_reg_awready         => s_axi_reg_awready,
      s_axi_reg_wdata           => s_axi_reg_wdata,
      s_axi_reg_wvalid          => s_axi_reg_wvalid,
      s_axi_reg_wready          => s_axi_reg_wready,
      s_axi_reg_bresp           => s_axi_reg_bresp,
      s_axi_reg_bvalid          => s_axi_reg_bvalid,
      s_axi_reg_bready          => s_axi_reg_bready,
      s_axi_reg_araddr          => s_axi_reg_araddr,
      s_axi_reg_arvalid         => s_axi_reg_arvalid,
      s_axi_reg_arready         => s_axi_reg_arready,
      s_axi_reg_rdata           => s_axi_reg_rdata,
      s_axi_reg_rresp           => s_axi_reg_rresp,
      s_axi_reg_rvalid          => s_axi_reg_rvalid,
      s_axi_reg_rready          => s_axi_reg_rready);
    end generate prc_us;
end; 
