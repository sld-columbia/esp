-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  I/O tile.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.gptimer_pkg.all;
use work.net.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.ariane_esp_pkg.all;
use work.ibex_esp_pkg.all;

entity tile_io is
  generic (
    SIMULATION : boolean := false;
    this_has_dco : integer range 0 to 1 := 0);
  port (
    raw_rstn           : in  std_ulogic;  -- active low raw reset (connect to DCO if present)
    tile_rst           : in  std_ulogic;  -- active low tile reset synch on clk
    clk                : in  std_ulogic;  -- tile clock (connect to external clock or DCO clock)
    refclk_noc         : in  std_ulogic;  -- NoC DCO external backup clock
    pllclk_noc         : out std_ulogic;  -- NoC DCO test out clock
    refclk             : in  std_ulogic;  -- tile DCO external backup clock
    pllbypass          : in  std_ulogic;  -- unused
    pllclk             : out std_ulogic;  -- tile DCO test out clock
    dco_clk            : out std_ulogic;  -- tile clock (if DCO is present)
    dco_rstn           : out std_ulogic;  -- tile reset output (if DCO is present)
    local_x            : out local_yx;
    local_y            : out local_yx;
    -- Ethernet MDC Scaler configuration
    mdcscaler          : out integer range 0 to 2047;
    -- I/O bus interfaces
    eth0_apbi          : out apb_slv_in_type;
    eth0_apbo          : in  apb_slv_out_type;
    sgmii0_apbi        : out apb_slv_in_type;
    sgmii0_apbo        : in  apb_slv_out_type;
    eth0_ahbmi         : out ahb_mst_in_type;
    eth0_ahbmo         : in  ahb_mst_out_type;
    edcl_ahbmo         : in  ahb_mst_out_type;
    dvi_apbi           : out apb_slv_in_type;
    dvi_apbo           : in  apb_slv_out_type;
    dvi_ahbmi          : out ahb_mst_in_type;
    dvi_ahbmo          : in  ahb_mst_out_type;
    uart_rxd           : in  std_ulogic;
    uart_txd           : out std_ulogic;
    uart_ctsn          : in  std_ulogic;
    uart_rtsn          : out std_ulogic;
    -- Pads configuration
    pad_cfg            : out std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
    -- NOC
    sys_clk_out        : out std_ulogic;  -- NoC clock out (if DCO is present)
    sys_clk_lock       : out std_ulogic;  -- NoC DCO lock
    noc1_mon_noc_vec   : in monitor_noc_type;
    noc2_mon_noc_vec   : in monitor_noc_type;
    noc3_mon_noc_vec   : in monitor_noc_type;
    noc4_mon_noc_vec   : in monitor_noc_type;
    noc5_mon_noc_vec   : in monitor_noc_type;
    noc6_mon_noc_vec   : in monitor_noc_type;
    test1_output_port   : in noc_flit_type;
    test1_data_void_out : in std_ulogic;
    test1_stop_in       : in std_ulogic;
    test2_output_port   : in noc_flit_type;
    test2_data_void_out : in std_ulogic;
    test2_stop_in       : in std_ulogic;
    test3_output_port   : in noc_flit_type;
    test3_data_void_out : in std_ulogic;
    test3_stop_in       : in std_ulogic;
    test4_output_port   : in noc_flit_type;
    test4_data_void_out : in std_ulogic;
    test4_stop_in       : in std_ulogic;
    test5_output_port   : in misc_noc_flit_type;
    test5_data_void_out : in std_ulogic;
    test5_stop_in       : in std_ulogic;
    test6_output_port   : in noc_flit_type;
    test6_data_void_out : in std_ulogic;
    test6_stop_in       : in std_ulogic;
    test1_input_port    : out noc_flit_type;
    test1_data_void_in  : out std_ulogic;
    test1_stop_out      : out std_ulogic;
    test2_input_port    : out noc_flit_type;
    test2_data_void_in  : out std_ulogic;
    test2_stop_out      : out std_ulogic;
    test3_input_port    : out noc_flit_type;
    test3_data_void_in  : out std_ulogic;
    test3_stop_out      : out std_ulogic;
    test4_input_port    : out noc_flit_type;
    test4_data_void_in  : out std_ulogic;
    test4_stop_out      : out std_ulogic;
    test5_input_port    : out misc_noc_flit_type;
    test5_data_void_in  : out std_ulogic;
    test5_stop_out      : out std_ulogic;
    test6_input_port    : out noc_flit_type;
    test6_data_void_in  : out std_ulogic;
    test6_stop_out      : out std_ulogic;
    mon_dvfs           : out monitor_dvfs_type
    );

end;

architecture rtl of tile_io is

  -- Tile synchronous reset
  signal rst : std_ulogic;

  -- DCO
  signal dco_noc_en       : std_ulogic;
  signal dco_noc_clk_sel  : std_ulogic;
  signal dco_noc_cc_sel   : std_logic_vector(5 downto 0);
  signal dco_noc_fc_sel   : std_logic_vector(5 downto 0);
  signal dco_noc_div_sel  : std_logic_vector(2 downto 0);
  signal dco_noc_freq_sel : std_logic_vector(1 downto 0);

  signal dco_en       : std_ulogic;
  signal dco_clk_sel  : std_ulogic;
  signal dco_cc_sel   : std_logic_vector(5 downto 0);
  signal dco_fc_sel   : std_logic_vector(5 downto 0);
  signal dco_div_sel  : std_logic_vector(2 downto 0);
  signal dco_freq_sel : std_logic_vector(1 downto 0);
  signal dco_clk_lock : std_ulogic;
  signal dco_clk_int  : std_ulogic;

  -- Bootrom
  component ahbrom is
    generic (
      hindex : integer;
      haddr  : integer;
      hmask  : integer;
      pipe   : integer;
      tech   : integer;
      kbytes : integer);
    port (
      rst   : in  std_ulogic;
      clk   : in  std_ulogic;
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type);
  end component ahbrom;


  -- Interrupt controller
  signal irqi               : irq_in_vector(0 to CFG_NCPU_TILE-1);
  signal irqo               : irq_out_vector(0 to CFG_NCPU_TILE-1);
  signal irqi_fifo_overflow : std_logic;
  signal noc_pirq           : std_logic_vector(NAHBIRQ-1 downto 0);  -- interrupt result bus from noc
  signal plic_pready        : std_ulogic;  -- PLIC APB3
  signal plic_pslverr       : std_ulogic;  -- PLIC APB3
  signal ibex_timer_pready  : std_ulogic;  -- IBEX Timer APB3
  signal ibex_timer_pslverr : std_ulogic;  -- IBEX Timer APB3
  signal ibex_timer_irq     : std_ulogic;
  signal irq_sources        : std_logic_vector(29 downto 0);  -- PLIC0 interrupt lines
  signal irq                : std_logic_vector(CFG_NCPU_TILE * 2 - 1 downto 0);
  signal timer_irq          : std_logic_vector(CFG_NCPU_TILE - 1 downto 0);  --CLINT
  signal ipi                : std_logic_vector(CFG_NCPU_TILE - 1 downto 0);  --CLINT

  signal override_cpu_loc : std_ulogic;
  signal cpu_loc_y        : yx_vec(0 to CFG_NCPU_TILE - 1);
  signal cpu_loc_x        : yx_vec(0 to CFG_NCPU_TILE - 1);

  -- UART
  signal u1i : uart_in_type;
  signal u1o : uart_out_type;

  -- General Purpose Timer
  signal gpti : gptimer_in_type;
  signal gpto : gptimer_out_type;       --Unused

  -- SVGA with dedicated memory
  signal ahbsi2 : ahb_slv_in_type;
  signal ahbso2 : ahb_slv_out_vector;
  signal ahbmi2 : ahb_mst_in_type;
  signal ahbmo2 : ahb_mst_out_vector;

  -- EDCL/Ethernet select
  signal coherent_dma_selected : std_ulogic;

  -- Queues
  -- These requests are delivered through NoC5 (32 bits always)
  -- however, the proxy that handles expects a flit size in
  -- accordance with ARCH_BITS. Hence we need to pad and move
  -- header info and preamble to the right bit position
  signal ahbs_rcv_rdreq            : std_ulogic;
  signal ahbs_rcv_data_out         : misc_noc_flit_type;
  signal ahbs_rcv_empty            : std_ulogic;
  signal ahbs_snd_wrreq            : std_ulogic;
  signal ahbs_snd_data_in          : misc_noc_flit_type;
  signal ahbs_snd_full             : std_ulogic;
  -- Extended remote_ahbs_* signals that
  signal ahbm_rcv_rdreq      : std_ulogic;
  signal ahbm_rcv_data_out   : noc_flit_type;
  signal ahbm_rcv_empty      : std_ulogic;
  signal ahbm_snd_wrreq      : std_ulogic;
  signal ahbm_snd_data_in    : noc_flit_type;
  signal ahbm_snd_full       : std_ulogic;

  signal remote_ahbs_rcv_rdreq     : std_ulogic;
  signal remote_ahbs_rcv_data_out  : misc_noc_flit_type;
  signal remote_ahbs_rcv_empty     : std_ulogic;
  signal remote_ahbs_snd_wrreq     : std_ulogic;
  signal remote_ahbs_snd_data_in   : misc_noc_flit_type;
  signal remote_ahbs_snd_full      : std_ulogic;

  -- DPR DMA queue entries
  signal prc_dma_rcv_rdreq             : std_ulogic;
  signal prc_dma_rcv_data_out          : noc_flit_type;
  signal prc_dma_rcv_empty             : std_ulogic;
  signal prc_dma_snd_wrreq             : std_ulogic;
  signal prc_dma_snd_data_in           : noc_flit_type;
  signal prc_dma_snd_full              : std_ulogic;

  signal dma_rcv_rdreq             : std_ulogic;
  signal dma_rcv_data_out          : noc_flit_type;
  signal dma_rcv_empty             : std_ulogic;
  signal dma_snd_wrreq             : std_ulogic;
  signal dma_snd_data_in           : noc_flit_type;
  signal dma_snd_full              : std_ulogic;
  signal dma_snd_atleast_4slots    : std_ulogic;
  signal dma_snd_exactly_3slots    : std_ulogic;
  signal coherent_dma_rcv_rdreq    : std_ulogic;
  signal coherent_dma_rcv_data_out : noc_flit_type;
  signal coherent_dma_rcv_empty    : std_ulogic;
  signal coherent_dma_snd_wrreq    : std_ulogic;
  signal coherent_dma_snd_data_in  : noc_flit_type;
  signal coherent_dma_snd_full     : std_ulogic;
  signal apb_rcv_rdreq             : std_ulogic;
  signal apb_rcv_data_out          : misc_noc_flit_type;
  signal apb_rcv_empty             : std_ulogic;
  signal apb_snd_wrreq             : std_ulogic;
  signal apb_snd_data_in           : misc_noc_flit_type;
  signal apb_snd_full              : std_ulogic;
  signal remote_apb_rcv_rdreq      : std_ulogic;
  signal remote_apb_rcv_data_out   : misc_noc_flit_type;
  signal remote_apb_rcv_empty      : std_ulogic;
  signal remote_apb_snd_wrreq      : std_ulogic;
  signal remote_apb_snd_data_in    : misc_noc_flit_type;
  signal remote_apb_snd_full       : std_ulogic;
  signal local_apb_rcv_rdreq          : std_ulogic;
  signal local_apb_rcv_data_out       : misc_noc_flit_type;
  signal local_apb_rcv_empty          : std_ulogic;
  signal local_remote_apb_snd_wrreq   : std_ulogic;
  signal local_remote_apb_snd_data_in : misc_noc_flit_type;
  signal local_remote_apb_snd_full    : std_ulogic;
  signal irq_ack_rdreq             : std_ulogic;
  signal irq_ack_data_out          : misc_noc_flit_type;
  signal irq_ack_empty             : std_ulogic;
  signal irq_wrreq                 : std_ulogic;
  signal irq_data_in               : misc_noc_flit_type;
  signal irq_full                  : std_ulogic;
  signal interrupt_rdreq           : std_ulogic;
  signal interrupt_data_out        : misc_noc_flit_type;
  signal interrupt_empty           : std_ulogic;
  signal interrupt_ack_wrreq       : std_ulogic;
  signal interrupt_ack_data_in     : misc_noc_flit_type;
  signal interrupt_ack_full        : std_ulogic;

  -- ESPLink
  signal init_done : std_ulogic;
  signal srst : std_ulogic;             -- soft reset
  signal soft_reset : std_ulogic;       -- local soft reset
  signal ibex_reset : std_ulogic;       -- local

  -- bus
  signal ahbsi            : ahb_slv_in_type;
  signal ahbso            : ahb_slv_out_vector;
  signal noc_ahbso        : ahb_slv_out_vector;
  signal ctrl_ahbso       : ahb_slv_out_vector;
  signal ahbmi            : ahb_mst_in_type;
  signal ahbmo            : ahb_mst_out_vector;
  signal apbi             : apb_slv_in_type;
  signal apbo             : apb_slv_out_vector;
  signal local_apbo       : apb_slv_out_vector;
  signal remote_apbo      : apb_slv_out_vector;
  signal noc_apbi         : apb_slv_in_type;
  signal noc_apbi_wirq    : apb_slv_in_type;
  signal noc_apbo         : apb_slv_out_vector;
  signal apb_req, apb_ack : std_ulogic;
  signal local_apb_ack    : std_ulogic;
  signal remote_apb_ack   : std_ulogic;
  signal pready           : std_ulogic;
  
  -- apb2axil
  signal s_axil_awvalid     : std_logic; 
  signal s_axil_awready     : std_logic;
  signal s_axil_awaddr      : std_logic_vector(31 downto 0);
  signal s_axil_awaddr_masked : std_logic_vector(31 downto 0);
  signal s_axil_wvalid      : std_logic;
  signal s_axil_wready      : std_logic;
  signal s_axil_wdata       : std_logic_vector(31 downto 0);
  signal s_axil_wstrb       : std_logic_vector(3 downto 0);
  signal s_axil_arvalid     : std_logic;
  signal s_axil_arready     : std_logic;
  signal s_axil_araddr      : std_logic_vector(31 downto 0);
  signal s_axil_araddr_masked      : std_logic_vector(31 downto 0);
  signal s_axil_rvalid      : std_logic;
  signal s_axil_rready      : std_logic;
  signal s_axil_rdata       : std_logic_vector(31 downto 0);
  signal s_axil_rresp       : std_logic_vector(1 downto 0);
  signal s_axil_bvalid      : std_logic;
  signal s_axil_bready      : std_logic;
  signal s_axil_bresp       : std_logic_vector(1 downto 0);

  signal prc_pready         : std_logic;
  
  -- AXI4 Master
  signal mosi : axi_mosi_vector(0 to 0);
  signal somi : axi_somi_vector(0 to 0);

  -- PRC axi master bus
  signal m_axi_mem_araddr   : std_logic_vector(31 downto 0);
  signal m_axi_mem_arlen    : std_logic_vector(7 downto 0);
  signal m_axi_mem_arsize   : std_logic_vector(2 downto 0);
  signal m_axi_mem_arburst  : std_logic_vector(1 downto 0);
  signal m_axi_mem_arprot   : std_logic_vector(2 downto 0);
  signal m_axi_mem_arcache  : std_logic_vector(3 downto 0);
  signal m_axi_mem_aruser   : std_logic_vector(3 downto 0);
  signal m_axi_mem_arvalid  : std_logic;
  signal m_axi_mem_arready  : std_logic;
  signal m_axi_mem_rdata    : std_logic_vector(31 downto 0);
  signal m_axi_mem_rresp    : std_logic_vector(1  downto 0);
  signal m_axi_mem_rlast    : std_logic;
  signal m_axi_mem_rvalid   : std_logic;
  signal m_axi_mem_rready   : std_logic;
  
  --ICAP3 
  signal icap_clk       : std_logic;
  signal icap_reset     : std_logic;
  signal icap_csib      : std_logic;
  signal icap_rdwrb     : std_logic;
  signal icap_i         : std_logic_vector(31 downto 0);
  signal icap_o         : std_logic_vector(31 downto 0);
  signal icap_avail     : std_logic;
  signal icap_prdone    : std_logic;
  signal icap_prerror   : std_logic; 

  --PRC configuration signals
  signal vsm_VS_0_rm_shutdown_req       : std_logic := '0';
  signal vsm_VS_0_rm_shutdown_ack       : std_logic := '1';
  signal vsm_VS_0_rm_decouple           : std_logic := '0';
  signal vsm_VS_0_rm_reset              : std_logic := '0';
  signal vsm_VS_0_event_error           : std_logic;
  signal vsm_VS_0_sw_shutdown_req       : std_logic;
  signal vsm_VS_0_sw_startup_req        : std_logic;  --interrupt

  constant prc_mask  : std_logic_vector(31 downto 0) := x"000000FF";
  constant prc_coherence : integer := 0;
  -- Mon
  signal mon_dvfs_int   : monitor_dvfs_type;
  signal mon_noc        : monitor_noc_vector(1 to 6);

  -- Interrupt ack to NoC
  type intr_ack_fsm is (idle, send_packet);
  signal intr_ack_state, intr_ack_state_next : intr_ack_fsm := idle;
  signal header, header_next : std_logic_vector(MISC_NOC_FLIT_SIZE - 1 downto 0);

  -- Tile parameters
  signal tile_config : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);

  constant this_local_y           : local_yx                           := tile_y(io_tile_id);
  constant this_local_x           : local_yx                           := tile_x(io_tile_id);
  constant this_csr_pindex        : integer                            := tile_csr_pindex(io_tile_id);
  constant this_csr_pconfig       : apb_config_type                    := fixed_apbo_pconfig(this_csr_pindex);

  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := (
    0      => '1',                                  -- CSRs
    1      => '1',                                  -- uart
    2      => '1',                                  -- irq3mp / plic
    3      => '1',                                  -- gptimer
    4      => '1',                                  -- esplink
    13     => to_std_logic(CFG_SVGA_ENABLE),        -- svga
    14     => to_std_logic(CFG_GRETH),              -- eth mac
    15     => to_std_logic(CFG_SGMII * CFG_GRETH),  -- eth phy
    127    => to_std_logic(CFG_PRC),                -- prc
    others => '0');

  constant this_local_ahb_en : std_logic_vector(0 to NAHBSLV - 1) := (
    0      => '1',                            -- bootrom
    1      => '1',                            -- ahb2apb
    2      => to_std_logic(GLOB_CPU_RISCV * GLOB_CPU_AXI),  -- risc-v clint
    12     => to_std_logic(CFG_SVGA_ENABLE),  -- frame buffer
    others => '0');

  constant this_remote_apb_slv_en : std_logic_vector(0 to NAPBSLV - 1) := remote_apb_slv_mask_misc;
  constant this_apb_en            : std_logic_vector(0 to NAPBSLV - 1) := this_local_apb_en or this_remote_apb_slv_en;
  constant this_remote_ahb_slv_en : std_logic_vector(0 to NAHBSLV - 1) := remote_ahb_mask_misc;
  
  --constant nofb_mem_info : tile_mem_info_vector(0 to CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE - 1) := mem_info(0 to CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE - 1);
  
  
  function set_local_pconfig (
    constant csr_pconfig   : apb_config_type;
    constant fixed_pconfig : apb_slv_config_vector)
    return apb_slv_config_vector is
    variable cfg : apb_slv_config_vector;
  begin  -- function set_local_pconfig
    cfg := (others => pconfig_none);
    cfg(0) := csr_pconfig;
    for i in 1 to 19 loop
      cfg(i) := fixed_pconfig(i);
    end loop;  -- i
    return cfg;
  end function set_local_pconfig;

  constant local_apbo_pconfig : apb_slv_config_vector := set_local_pconfig(this_csr_pconfig, fixed_apbo_pconfig);

  attribute mark_debug : string;
  attribute keep       : string;
  attribute keep of irq_sources : signal is "true";
  attribute keep of irq : signal is "true";
  attribute keep of timer_irq : signal is "true";
  attribute keep of ipi : signal is "true";

  attribute mark_debug of s_axil_awvalid     : signal is "true";
  attribute mark_debug of s_axil_awready     : signal is "true";
  attribute mark_debug of s_axil_awaddr      : signal is "true";
 -- attribute mark_debug of s_axil_awaddr_masked      : signal is "true";
  attribute mark_debug of s_axil_wvalid      : signal is "true";
  attribute mark_debug of s_axil_wready      : signal is "true";
  attribute mark_debug of s_axil_wdata       : signal is "true";
  attribute mark_debug of s_axil_wstrb       : signal is "true";
  attribute mark_debug of s_axil_arvalid     : signal is "true";
  attribute mark_debug of s_axil_arready     : signal is "true";
  attribute mark_debug of s_axil_araddr      : signal is "true";
 -- attribute mark_debug of s_axil_araddr_masked      : signal is "true";
  attribute mark_debug of s_axil_rvalid      : signal is "true";
  attribute mark_debug of s_axil_rready      : signal is "true";
  attribute mark_debug of s_axil_rdata       : signal is "true";
  attribute mark_debug of s_axil_rresp       : signal is "true";
  attribute mark_debug of s_axil_bvalid      : signal is "true";
  attribute mark_debug of s_axil_bready      : signal is "true";
  attribute mark_debug of s_axil_bresp       : signal is "true";

  attribute mark_debug of icap_clk       : signal is "true";
  attribute mark_debug of icap_reset     : signal is "true";
  attribute mark_debug of icap_csib      : signal is "true";
  attribute mark_debug of icap_rdwrb     : signal is "true";
  attribute mark_debug of icap_i         : signal is "true";
  attribute mark_debug of icap_o         : signal is "true";
  attribute mark_debug of icap_avail     : signal is "true";
  attribute mark_debug of icap_prdone    : signal is "true";
  attribute mark_debug of icap_prerror   : signal is "true";
  
  attribute mark_debug of vsm_VS_0_sw_startup_req : signal is "true";

  attribute mark_debug of m_axi_mem_araddr   : signal is "true";
  attribute mark_debug of m_axi_mem_arlen    : signal is "true";
  attribute mark_debug of m_axi_mem_arsize   : signal is "true";
  attribute mark_debug of m_axi_mem_arburst  : signal is "true";
  attribute mark_debug of m_axi_mem_arprot   : signal is "true";
  attribute mark_debug of m_axi_mem_arcache  : signal is "true";
  attribute mark_debug of m_axi_mem_aruser   : signal is "true";
  attribute mark_debug of m_axi_mem_arvalid  : signal is "true";
  attribute mark_debug of m_axi_mem_arready  : signal is "true";
  attribute mark_debug of m_axi_mem_rdata    : signal is "true";
  attribute mark_debug of m_axi_mem_rresp    : signal is "true";
  attribute mark_debug of m_axi_mem_rlast    : signal is "true";
  attribute mark_debug of m_axi_mem_rvalid   : signal is "true";
  attribute mark_debug of m_axi_mem_rready   : signal is "true";

  attribute mark_debug of prc_dma_rcv_rdreq    : signal is "true";
  attribute mark_debug of prc_dma_rcv_data_out : signal is "true";
  attribute mark_debug of prc_dma_rcv_empty    : signal is "true";
  attribute mark_debug of prc_dma_snd_wrreq    : signal is "true";
  attribute mark_debug of prc_dma_snd_data_in  : signal is "true";
  attribute mark_debug of prc_dma_snd_full     : signal is "true";

  -- attribute mark_debug of ahbs_rcv_rdreq : signal is "true";
  -- attribute mark_debug of ahbs_rcv_data_out : signal is "true";
  -- attribute mark_debug of ahbs_rcv_empty : signal is "true";
  -- attribute mark_debug of ahbs_snd_wrreq : signal is "true";
  -- attribute mark_debug of ahbs_snd_data_in : signal is "true";
  -- attribute mark_debug of ahbs_snd_full : signal is "true";
  -- attribute mark_debug of ahbm_rcv_rdreq : signal is "true";
  -- attribute mark_debug of ahbm_rcv_data_out : signal is "true";
  -- attribute mark_debug of ahbm_rcv_empty : signal is "true";
  -- attribute mark_debug of ahbm_snd_wrreq : signal is "true";
  -- attribute mark_debug of ahbm_snd_data_in : signal is "true";
  -- attribute mark_debug of ahbm_snd_full : signal is "true";
  -- attribute mark_debug of remote_ahbs_rcv_rdreq : signal is "true";
  -- attribute mark_debug of remote_ahbs_rcv_data_out : signal is "true";
  -- attribute mark_debug of remote_ahbs_rcv_empty : signal is "true";
  -- attribute mark_debug of remote_ahbs_snd_wrreq : signal is "true";
  -- attribute mark_debug of remote_ahbs_snd_data_in : signal is "true";
  -- attribute mark_debug of remote_ahbs_snd_full : signal is "true";
   attribute mark_debug of dma_rcv_rdreq : signal is "true";
   attribute mark_debug of dma_rcv_data_out : signal is "true";
   attribute mark_debug of dma_rcv_empty : signal is "true";
   attribute mark_debug of dma_snd_wrreq : signal is "true";
   attribute mark_debug of dma_snd_data_in : signal is "true";
   attribute mark_debug of dma_snd_full : signal is "true";
   attribute mark_debug of dma_snd_atleast_4slots : signal is "true";
   attribute mark_debug of dma_snd_exactly_3slots : signal is "true";
  -- attribute mark_debug of coherent_dma_rcv_rdreq : signal is "true";
  -- attribute mark_debug of coherent_dma_rcv_data_out : signal is "true";
  -- attribute mark_debug of coherent_dma_rcv_empty : signal is "true";
  -- attribute mark_debug of coherent_dma_snd_wrreq : signal is "true";
  -- attribute mark_debug of coherent_dma_snd_data_in : signal is "true";
  -- attribute mark_debug of coherent_dma_snd_full : signal is "true";
  
  attribute keep of apb_rcv_rdreq : signal is "true";
  attribute keep of apb_rcv_data_out : signal is "true";
  attribute keep of apb_rcv_empty : signal is "true";
  attribute keep of apb_snd_wrreq : signal is "true";
  attribute keep of apb_snd_data_in : signal is "true";
  attribute keep of apb_snd_full : signal is "true";
 
  -- attribute mark_debug of remote_apb_rcv_rdreq : signal is "true";
  -- attribute mark_debug of remote_apb_rcv_data_out : signal is "true";
  -- attribute mark_debug of remote_apb_rcv_empty : signal is "true";
  -- attribute mark_debug of remote_apb_snd_wrreq : signal is "true";
  -- attribute mark_debug of remote_apb_snd_data_in : signal is "true";
  -- attribute mark_debug of remote_apb_snd_full : signal is "true";
  -- attribute mark_debug of local_apb_rcv_rdreq : signal is "true";
  -- attribute mark_debug of local_apb_rcv_data_out : signal is "true";
  -- attribute mark_debug of local_apb_rcv_empty : signal is "true";
  -- attribute mark_debug of local_remote_apb_snd_wrreq : signal is "true";
  -- attribute mark_debug of local_remote_apb_snd_data_in : signal is "true";
  -- attribute mark_debug of local_remote_apb_snd_full : signal is "true";
  -- attribute mark_debug of irq_ack_rdreq : signal is "true";
  -- attribute mark_debug of irq_ack_data_out : signal is "true";
  -- attribute mark_debug of irq_ack_empty : signal is "true";
  -- attribute mark_debug of irq_wrreq : signal is "true";
  -- attribute mark_debug of irq_data_in : signal is "true";
  -- attribute mark_debug of irq_full : signal is "true";
  attribute keep of interrupt_rdreq : signal is "true";
  attribute keep of interrupt_data_out : signal is "true";
  attribute keep of interrupt_empty : signal is "true";
  attribute keep of interrupt_ack_wrreq : signal is "true";
  attribute keep of interrupt_ack_data_in : signal is "true";
  attribute keep of interrupt_ack_full : signal is "true";
  attribute keep of noc_apbi_wirq : signal is "true";
  
  attribute mark_debug of noc_apbo : signal is "true";
  attribute mark_debug of noc_apbi : signal is "true";

  attribute keep of intr_ack_state : signal is "true";
  attribute keep of intr_ack_state_next : signal is "true";
  attribute keep of header : signal is "true";
  attribute keep of header_next : signal is "true";

begin

  local_x <= this_local_x;
  local_y <= this_local_y;

  -- DCO Reset synchronizer
  rst_gen: if this_has_dco /= 0 generate
    tile_rstn : rstgen
      generic map (acthigh => 1, syncin => 0)
      port map (tile_rst, dco_clk_int, dco_clk_lock, rst, open);
  end generate rst_gen;

  no_rst_gen: if this_has_dco = 0 generate
    rst <= tile_rst;
  end generate no_rst_gen;

  dco_rstn <= rst;

  -- DCO
  dco_gen: if this_has_dco /= 0 generate
    dco_noc_i : dco
      generic map (
        tech => CFG_FABTECH,
        enable_div2 => 0,
        dlog => 8)                      -- NoC is the first to come out of reset
      port map (
        rstn     => raw_rstn,
        ext_clk  => refclk_noc,
        en       => dco_noc_en,
        clk_sel  => dco_noc_clk_sel,
        cc_sel   => dco_noc_cc_sel,
        fc_sel   => dco_noc_fc_sel,
        div_sel  => dco_noc_div_sel,
        freq_sel => dco_noc_freq_sel,
        clk      => sys_clk_out,
        clk_div  => pllclk_noc,
        lock     => sys_clk_lock);

    dco_noc_freq_sel <= tile_config(ESP_CSR_DCO_NOC_CFG_MSB - 0  downto ESP_CSR_DCO_NOC_CFG_MSB - 0  - 1);
    dco_noc_div_sel  <= tile_config(ESP_CSR_DCO_NOC_CFG_MSB - 2  downto ESP_CSR_DCO_NOC_CFG_MSB - 2  - 2);
    dco_noc_fc_sel   <= tile_config(ESP_CSR_DCO_NOC_CFG_MSB - 5  downto ESP_CSR_DCO_NOC_CFG_MSB - 5  - 5);
    dco_noc_cc_sel   <= tile_config(ESP_CSR_DCO_NOC_CFG_MSB - 11 downto ESP_CSR_DCO_NOC_CFG_MSB - 11 - 5);
    dco_noc_clk_sel  <= tile_config(ESP_CSR_DCO_NOC_CFG_LSB + 1);
    dco_noc_en       <= raw_rstn and tile_config(ESP_CSR_DCO_NOC_CFG_LSB);

    dco_i: dco
      generic map (
        tech => CFG_FABTECH,
        enable_div2 => 0,
        dlog => 10)                     -- Tile I/O is the first sending NoC
                                        -- packets; last reset to be released
      port map (
        rstn     => raw_rstn,
        ext_clk  => refclk,
        en       => dco_en,
        clk_sel  => dco_clk_sel,
        cc_sel   => dco_cc_sel,
        fc_sel   => dco_fc_sel,
        div_sel  => dco_div_sel,
        freq_sel => dco_freq_sel,
        clk      => dco_clk_int,
        clk_div  => pllclk,
        lock     => dco_clk_lock);

    dco_freq_sel <= tile_config(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 0  downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 0  - 1);
    dco_div_sel  <= tile_config(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 2  downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 2  - 2);
    dco_fc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 5  downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 5  - 5);
    dco_cc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 11 downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 11 - 5);
    dco_clk_sel  <= tile_config(ESP_CSR_DCO_CFG_LSB + 1);
    dco_en       <= raw_rstn and tile_config(ESP_CSR_DCO_CFG_LSB);

  end generate dco_gen;

  no_dco_gen: if this_has_dco = 0 generate
    pllclk       <= '0';
    pllclk_noc   <= '0';
    dco_clk_int  <= '0';
    sys_clk_out  <= '0';
    dco_clk_lock <= '1';
    sys_clk_lock <= '1';
  end generate no_dco_gen;

  dco_clk <= dco_clk_int;

  -- MDC scaler configuration
  mdcscaler              <= conv_integer(tile_config(ESP_CSR_MDC_SCALER_CFG_MSB downto ESP_CSR_MDC_SCALER_CFG_LSB));

  -- Pads configuration
  pad_cfg                <= tile_config(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB);

  -----------------------------------------------------------------------------
  -- Bus
  -----------------------------------------------------------------------------

  hbus_pnp_gen : process (ahbso, noc_ahbso) is
  begin  -- process hbus_pnp_gen
    ctrl_ahbso <= noc_ahbso;

    for i in 0 to NAHBSLV - 1 loop
      if this_local_ahb_en(i) = '1' then
        ctrl_ahbso(i) <= ahbso(i);
      end if;
    end loop;  -- i

  end process hbus_pnp_gen;

  ahb0 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => CFG_GRETH + CFG_DSU_ETH + 2, nahbs => maxahbs,
                 cfgmask => 0)
    port map (rst, clk, ahbmi, ahbmo, ahbsi, ctrl_ahbso);


  -- apb2noc proxy handles pindex and pconfig assignments
  -- All APB slaves in this tile are seen as remote for the local masters, even those
  -- that are local to the tile. This allows any SoC master to access these slaves.
  -- Requests from the EDCL/JTAG are forwarded to an apb2noc proxy, then to the
  -- router. Requests for local slaves reenter immediately the tile and are
  -- served by a noc2apb proxy. All other requests will reach the destination
  -- tile. The AHB2APB bridge has been modified to be latency insensitive.
  apb0 : patient_apbctrl                -- AHB/APB bridge
    generic map (hindex     => ahb2apb_hindex, haddr => CFG_APBADDR, hmask => ahb2apb_hmask, nslaves => NAPBSLV,
                 remote_apb => this_apb_en)
    port map (rst, clk, ahbsi, ahbso(ahb2apb_hindex), apbi, apbo, apb_req, apb_ack);

  -----------------------------------------------------------------------------
  -- Drive unused bus ports
  -----------------------------------------------------------------------------

  nam0 : for i in (CFG_GRETH + CFG_DSU_ETH + 2) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

  -- NB: all local I/O-bus slaves are accessed through proxy as if they were
  -- remote. This allows any master in the system to access them
  no_pslv_gen_1 : for i in 5 to 12 generate
    noc_apbo(i) <= apb_none;
  end generate no_pslv_gen_1;
  no_pslv_gen_2 : for i in 16 to NAPBSLV - 2 generate
    skip_csr_apb_gen : if i /= this_csr_pindex generate
      noc_apbo(i) <= apb_none;
    end generate skip_csr_apb_gen;
  end generate no_pslv_gen_2;

  -----------------------------------------------------------------------------
  -- Self configuration
  -----------------------------------------------------------------------------
  esp_init_1 : esp_init
    generic map (
      hindex => CFG_GRETH + CFG_DSU_ETH + 1,
      sequence => esp_init_sequence,
      srst_sequence => esp_srst_sequence)
    port map (
      rstn   => rst,
      clk    => clk,
      noinit => '0',
      srst   => srst,
      init_done  => init_done,
      ahbmi  => ahbmi,
      ahbmo  => ahbmo(CFG_GRETH + CFG_DSU_ETH + 1));

  -----------------------------------------------------------------------------
  -- ETH0 and EDCL Master
  -----------------------------------------------------------------------------

  eth0_gen : if CFG_GRETH = 1 generate
    ahbmo(0) <= eth0_ahbmo;
    eth0_ahbmi          <= ahbmi;

    noc_apbo(14) <= eth0_apbo;
    eth0_apbi    <= noc_apbi;

    sgmii_gen : if CFG_SGMII = 1 generate
      noc_apbo(15) <= sgmii0_apbo;
      sgmii0_apbi  <= noc_apbi;
    end generate sgmii_gen;

    edcl_gen : if CFG_DSU_ETH = 1 generate
      ahbmo(1) <= edcl_ahbmo;
    end generate edcl_gen;

  end generate eth0_gen;

  no_ethernet : if CFG_GRETH = 0 generate
    eth0_ahbmi   <= ahbm_in_none;
    eth0_apbi    <= apb_slv_in_none;
    noc_apbo(14) <= apb_none;
  end generate no_ethernet;

  no_sgmii_gen : if (CFG_GRETH * CFG_SGMII) = 0 generate
    sgmii0_apbi  <= apb_slv_in_none;
    noc_apbo(15) <= apb_none;
  end generate no_sgmii_gen;

  -----------------------------------------------------------------------------
  -- Memory Controller Slave (BOOTROM is implemented as RAM for development)
  -----------------------------------------------------------------------------

-- pragma translate_off
  bootram_model_gen: if SIMULATION = true generate
    ahbram_1 : ahbram_sim
      generic map (
        hindex   => ahbrom_hindex,
        tech     => 0,
        kbytes   => 128,
        pipe     => 0,
        maccsz   => AHBDW,
        fname    => "prom.srec"
        )
      port map(
        rst     => rst,
        clk     => clk,
        haddr   => ahbrom_haddr,
        hmask   => ahbrom_hmask,
        ahbsi   => ahbsi,
        ahbso   => ahbso(ahbrom_hindex)
        );
  end generate bootram_model_gen;
-- pragma translate_on

  bootram_gen: if SIMULATION = false generate
    ahbram_2: ahbram
      generic map (
        hindex   => ahbrom_hindex,
        tech     => CFG_FABTECH,
        large_banks => 0,
        kbytes   => 128,
        pipe     => 0,
        maccsz   => AHBDW)
      port map (
        rst   => rst,
        clk   => clk,
        haddr => ahbrom_haddr,
        hmask => ahbrom_hmask,
        ahbsi => ahbsi,
        ahbso => ahbso(ahbrom_hindex));
  end generate bootram_gen;


  -------------------------------------------------------------------------------
  -- APB 1: UART interface ------------------------------------------------------
  -------------------------------------------------------------------------------
  uart_txd  <= u1o.txd;
  u1i.rxd   <= uart_rxd;
  uart_rtsn <= u1o.rtsn;
  u1i.ctsn  <= uart_ctsn;

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart                     -- UART 1
      generic map (pindex   => 1, paddr => 1, pirq => CFG_UART1_IRQ, console => CFG_DUART,
                   fifosize => CFG_UART1_FIFO)
      port map (rst, clk, noc_apbi, noc_apbo(1), u1i, u1o);
    u1i.extclk <= '0';
  end generate;

  noua0 : if CFG_UART1_ENABLE = 0 generate
    noc_apbo(1) <= apb_none;
  end generate;


  ----------------------------------------------------------------------
  ---  APB 2: Interrupt Controller -------------------------------------
  ----------------------------------------------------------------------

  apb_assignments : process (noc_apbi, noc_pirq)
  begin  -- process apb_assignments
    noc_apbi_wirq      <= noc_apbi;
    noc_apbi_wirq.pirq <= noc_apbi.pirq or noc_pirq;
  end process apb_assignments;

  leon3_irqmp_gen: if GLOB_CPU_ARCH = leon3 generate

    irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
      irqctrl0 : irqmp                    -- interrupt controller
        generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU_TILE)
        port map (soft_reset, clk, noc_apbi_wirq, noc_apbo(2), irqo, irqi);
    end generate;

    irq3 : if CFG_IRQ3_ENABLE = 0 generate
      x : for i in 0 to CFG_NCPU_TILE-1 generate
        irqi(i).irl <= (others => '0');
      end generate;
      noc_apbo(2) <= apb_none;
    end generate;

  end generate;

  irq_sources <= noc_apbi_wirq.pirq(29 downto 0);
  riscv_plic_gen: if GLOB_CPU_ARCH = ariane or GLOB_CPU_ARCH = ibex generate

    x : for i in 0 to CFG_NCPU_TILE-1 generate
      riscv_irqinfo_proc : process (irq, timer_irq, ipi) is
      begin  -- process riscv_irqinfo_gen
        -- Use irq field to send timer IRQ
        irqi(i).irl <= ipi(i) & timer_irq(i) & irq((i + 1) * 2 - 1 downto i * 2);
        irqi(i).resume <= '0';
        irqi(i).rstrun <= '0';
        irqi(i).rstvec <= (others => '0');
        irqi(i).index <= conv_std_logic_vector(i, 4);
        irqi(i).pwdsetaddr <= '0';
        irqi(i).pwdnewaddr <= (others => '0');
        irqi(i).forceerr <= '0';
      end process riscv_irqinfo_proc;
    end generate;

    riscv_plic0 : riscv_plic_apb_wrap
      generic map (
        pindex    => 2,
        pconfig   => irqmp_pconfig,
        NHARTS    => CFG_NCPU_TILE,
        NIRQ_SRCS => 30)
      port map (
        clk         => clk,
        rstn        => soft_reset,
        irq_sources => irq_sources,
        irq         => irq,
        apbi        => noc_apbi_wirq,
        apbo        => noc_apbo(2),
        pready      => plic_pready,
        pslverr     => plic_pslverr);

    riscv_clint_gen: if GLOB_CPU_ARCH /= ibex generate
      riscv_clint_ahb_wrap_1: riscv_clint_ahb_wrap
        generic map (
          hindex  => clint_hindex,
          hconfig => clint_hconfig,
          NHARTS  => CFG_NCPU_TILE)
        port map (
          clk       => clk,
          rstn      => soft_reset,
          timer_irq => timer_irq,
          ipi       => ipi,
          ahbsi     => ahbsi,
          ahbso     => ahbso(clint_hindex));
    end generate riscv_clint_gen;

    ibex_no_clint_gen: if GLOB_CPU_ARCH = ibex generate
      ipi <= (others => '0');
      multi_ibex_timer_irq_gen: if CFG_NCPU_TILE > 1 generate
        timer_irq(CFG_NCPU_TILE - 1 downto 1) <= (others =>  timer_irq(0));
      end generate multi_ibex_timer_irq_gen;
    end generate ibex_no_clint_gen;

    -- TODO: if the interrupt_ack queue is full this entity may miss some irq
    -- restore message to the interrupt controller
    fsm_intr_ack_update : process (clk, rst)
    begin
      if rst = '0' then
        intr_ack_state <= idle;
        header <= (others => '0');
      elsif clk'event and clk = '1' then
        intr_ack_state <= intr_ack_state_next;
        header <= header_next;
      end if;
    end process fsm_intr_ack_update;

    -- purpose: send interrupt acknowledge to accelerator with level-sensitive interrupts
    fsm_intr_ack: process (intr_ack_state, noc_apbi_wirq, plic_pready, interrupt_ack_full, header) is
      variable state_reg : intr_ack_fsm;
      variable irq_pwdata_hit : std_ulogic;
      variable intr_id : integer range 0 to NAHBIRQ - 1;
      variable header_reg : std_logic_vector(MISC_NOC_FLIT_SIZE - 1 downto 0);
      variable dest_y, dest_x : local_yx;
    begin  -- process fsm_intr_ack
      state_reg := intr_ack_state;
      header_reg := header;
      interrupt_ack_wrreq <= '0';
      interrupt_ack_data_in <= (others => '0');

      irq_pwdata_hit := '0';
      dest_y := (others => '0');
      dest_x := (others => '0');
      for i in 0 to CFG_TILES_NUM - 1 loop
        if tile_irq_type(i) = 1 and
            tile_apb_irq(i) = to_integer(unsigned(noc_apbi_wirq.pwdata)) - 1 then
          irq_pwdata_hit := '1';
          dest_y := tile_y(i);
          dest_x := tile_x(i);
        end if;
      end loop;  -- i
      
      case intr_ack_state is

        when idle =>
          
          if (plic_pready = '1' and noc_apbi_wirq.penable = '1' and noc_apbi_wirq.psel(2) = '1' and
              noc_apbi_wirq.pwrite = '1' and noc_apbi_wirq.paddr(11 downto 0) = x"004" and
              noc_apbi_wirq.paddr(31 downto 16) = x"0c20" and irq_pwdata_hit = '1') then

            header_reg := create_header(MISC_NOC_FLIT_SIZE, this_local_y, this_local_x, dest_y, dest_x,
                                        INTERRUPT, X"00");
            header_reg(MISC_NOC_FLIT_SIZE - 1 downto
                       MISC_NOC_FLIT_SIZE - PREAMBLE_WIDTH) := PREAMBLE_1FLIT;

            if interrupt_ack_full = '0' then
              interrupt_ack_wrreq <= '1';
              interrupt_ack_data_in <= header_reg;
            else
              state_reg := send_packet;
            end if;
          end if;

        when send_packet =>

          if interrupt_ack_full = '0' then
            interrupt_ack_wrreq <= '1';
            interrupt_ack_data_in <= header_reg;
            state_reg := idle;
          end if;

      end case;
      
      intr_ack_state_next <= state_reg;
      header_next <= header_reg;

    end process fsm_intr_ack; 
   
  end generate;

  unused_riscv_irq_gen: if GLOB_CPU_ARCH /= ariane and GLOB_CPU_ARCH /= ibex generate
    irq <= (others => '0');
    timer_irq <= (others => '0');
    ipi <= (others => '0');

    interrupt_ack_wrreq <= '0';
    interrupt_ack_data_in <= (others => '0');
    intr_ack_state_next <= idle;
    header_next <= (others => '0');
  end generate;
  
  ----------------------------------------------------------------------
  ---  APB 3: Timer ----------------------------------------------------
  ----------------------------------------------------------------------

  leon3_gpt_gen: if GLOB_CPU_ARCH = leon3 generate

    leon3_gpt_gen : if CFG_GPT_ENABLE /= 0 generate
      timer0 : gptimer                    -- timer unit
        generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ,
                     sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM,
                     nbits  => CFG_GPT_TW, wdog => CFG_GPT_WDOGEN*CFG_GPT_WDOG)
        port map (soft_reset, clk, noc_apbi, noc_apbo(3), gpti, gpto);
      gpti.dhalt <= '0'; gpti.extclk <= '0';
    end generate;

    leon3_nogpt_gen : if CFG_GPT_ENABLE = 0 generate
      noc_apbo(3) <= apb_none;
    end generate;

  end generate;

  ibex_timer_gen : if GLOB_CPU_ARCH = ibex generate
    ibex_timer_apb_wrap_1: ibex_timer_apb_wrap
      generic map (
        pindex  => 3,
        pconfig => ibex_timer_pconfig)
      port map (
        clk       => clk,
        rstn      => ibex_reset,
        timer_irq => ibex_timer_irq,
        apbi      => noc_apbi,
        apbo      => noc_apbo(3),
        pready    => ibex_timer_pready,
        pslverr   => ibex_timer_pslverr);

    ibex_reset <= soft_reset and init_done;
    timer_irq(0) <= ibex_timer_irq;
  end generate;


  ariane_nogpt_gen : if GLOB_CPU_ARCH = ariane  generate
    noc_apbo(3) <= apb_none;
  end generate;

  -----------------------------------------------------------------------------
  -- APB 4: ESP Link (Soft reset) ---------------------------------------------
  -----------------------------------------------------------------------------

  soft_reset <= (not srst) and rst;

  esplink_1: esplink
    generic map (
      APB_DW     => 32,
      APB_AW     => 32,
      REV_ENDIAN => 0)
    port map (
      clk     => clk,
      rstn    => rst,
      srst    => srst,
      psel    => noc_apbi.psel(4),
      penable => noc_apbi.penable,
      pwrite  => noc_apbi.pwrite,
      paddr   => noc_apbi.paddr,
      pwdata  => noc_apbi.pwdata,
      pready  => open,
      pslverr => open,
      prdata  => noc_apbo(4).prdata);

  noc_apbo(4).pirq <= (others => '0');
  noc_apbo(4).pconfig <= fixed_apbo_pconfig(4);
  noc_apbo(4).pindex <= 4;

  -----------------------------------------------------------------------------
  -- APB 13: DVI
  -----------------------------------------------------------------------------

  -- SVGA component interface
  svga_on_apb : if CFG_SVGA_ENABLE /= 0 generate
    noc_apbo(13) <= dvi_apbo;
    ahbmo2(0)    <= dvi_ahbmo;

    -- Dedicated Video Memory with dual-port interface.

    -- SLV 7: 0x30100000 - 0x301FFFFF
    ahbmo2(NAHBMST - 1 downto 1)   <= (others => ahbm_none);
    ahbso2(1 to NAHBSLV - 1) <= (others => ahbs_none);
    ahbram_dp_1 : ahbram_dp
      generic map (
        hindex1 => fb_hindex,
        haddr1  => CFG_SVGA_MEMORY_HADDR,
        hindex2 => 0,
        haddr2  => CFG_SVGA_MEMORY_HADDR,
        hmask   => fb_hmask,
        tech    => CFG_FABTECH,
        kbytes  => 512,
        wordsz  => 32)
      port map (
        rst    => rst,
        clk    => clk,
        ahbsi1 => ahbsi,
        ahbso1 => ahbso(fb_hindex),
        ahbsi2 => ahbsi2,
        ahbso2 => ahbso2(0));

    -- AHB2: SVGA master and R AHBRAM slave
    ahb2 : ahbctrl                      -- AHB arbiter/multiplexer
      generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                   rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                   nahbm   => 1, nahbs => 1,
                   cfgmask => 0)
      port map (rst, clk, ahbmi2, ahbmo2, ahbsi2, ahbso2);

  end generate svga_on_apb;

  no_svga_on_apb : if CFG_SVGA_ENABLE = 0 generate
    noc_apbo(13) <= apb_none;
    ahbmo2(0) <= ahbm_none;
  end generate no_svga_on_apb;

  dvi_apbi  <= noc_apbi;
  dvi_ahbmi <= ahbmi2;


  -----------------------------------------------------------------------------
  -- Services
  -----------------------------------------------------------------------------

  -- Remote high-perf slaves, including memory. These are not cached on this
  -- tile, because masters are debug interfaces (Ethernet EDCL or JTAG). The
  -- only exception is Ethernet used as slave peripheral, which must be
  -- coherent. This leverages coherent DMA requests, so there is no need to
  -- have a private cache on the tile.
  -- Coherent DMA transactions use plane 4 for device-to-memory requests and
  -- plane 6 for memory to device responses. Uncached accesses from debug
  -- interfaces, instead use plane 5. Typically these requests only occur when
  -- the system is idle to preload DRAM.
  coh_dma_selector : process (ahbsi) is
    variable hmaster : integer;
  begin  -- process coh_dma_selector
    coherent_dma_selected <= '0';

    -- Determine if Ethernet (not EDCL!) is selected as master and LLC is present
    -- Note that Ehternet won't work if L2 is enabled and LLC is not.

    hmaster := to_integer(unsigned(ahbsi.hmaster));
    if hmaster = 0 then
      coherent_dma_selected <= '1';
    end if;

  end process coh_dma_selector;

  ahbslv2noc_1 : ahbslv2noc
    generic map (
      tech             => CFG_FABTECH,
      hindex           => this_remote_ahb_slv_en,
      hconfig          => fixed_ahbso_hconfig,
      mem_hindex       => ddr_hindex(0),
      mem_num          => CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE,
      mem_info         => tile_acc_mem_list(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1),
      slv_y            => tile_y(io_tile_id),
      slv_x            => tile_x(io_tile_id),
      retarget_for_dma => 1,
      dma_length       => CFG_DLINE)
    port map (
      rst                        => rst,
      clk                        => clk,
      local_y                    => this_local_y,
      local_x                    => this_local_x,
      ahbsi                      => ahbsi,
      ahbso                      => noc_ahbso,
      dma_selected               => coherent_dma_selected,
      coherence_req_wrreq        => coherent_dma_snd_wrreq,
      coherence_req_data_in      => coherent_dma_snd_data_in,
      coherence_req_full         => coherent_dma_snd_full,
      coherence_rsp_rcv_rdreq    => coherent_dma_rcv_rdreq,
      coherence_rsp_rcv_data_out => coherent_dma_rcv_data_out,
      coherence_rsp_rcv_empty    => coherent_dma_rcv_empty,
      remote_ahbs_snd_wrreq      => remote_ahbs_snd_wrreq,
      remote_ahbs_snd_data_in    => remote_ahbs_snd_data_in,
      remote_ahbs_snd_full       => remote_ahbs_snd_full,
      remote_ahbs_rcv_rdreq      => remote_ahbs_rcv_rdreq,
      remote_ahbs_rcv_data_out   => remote_ahbs_rcv_data_out,
      remote_ahbs_rcv_empty      => remote_ahbs_rcv_empty);

  -- I/O bus proxy - from local masters to remote slaves
  apb2noc_1 : apb2noc
    generic map (
      tech        => CFG_FABTECH,
      ncpu        => CFG_NCPU_TILE,
      apb_slv_en  => this_remote_apb_slv_en,
      apb_slv_cfg => fixed_apbo_pconfig,
      apb_slv_y   => apb_slv_y,
      apb_slv_x   => apb_slv_x)
    port map (
      rst                     => rst,
      clk                     => clk,
      local_y                 => this_local_y,
      local_x                 => this_local_x,
      apbi                    => apbi,
      apbo                    => remote_apbo,
      apb_req                 => apb_req,
      apb_ack                 => remote_apb_ack,
      remote_apb_snd_wrreq    => remote_apb_snd_wrreq,
      remote_apb_snd_data_in  => remote_apb_snd_data_in,
      remote_apb_snd_full     => remote_apb_snd_full,
      remote_apb_rcv_rdreq    => remote_apb_rcv_rdreq,
      remote_apb_rcv_data_out => remote_apb_rcv_data_out,
      remote_apb_rcv_empty    => remote_apb_rcv_empty);

  -- I/O bus proxy - From local masters to local slaves
  apb2noc_2 : apb2noc
    generic map (
      tech        => CFG_FABTECH,
      ncpu        => CFG_NCPU_TILE,
      apb_slv_en  => this_local_apb_en,
      apb_slv_cfg => local_apbo_pconfig,
      apb_slv_y   => apb_slv_y,
      apb_slv_x   => apb_slv_x)
    port map (
      rst                     => rst,
      clk                     => clk,
      local_y                 => this_local_y,
      local_x                 => this_local_x,
      apbi                    => apbi,
      apbo                    => local_apbo,
      apb_req                 => apb_req,
      apb_ack                 => local_apb_ack,
      remote_apb_snd_wrreq    => local_remote_apb_snd_wrreq,
      remote_apb_snd_data_in  => local_remote_apb_snd_data_in,
      remote_apb_snd_full     => local_remote_apb_snd_full,
      remote_apb_rcv_rdreq    => local_apb_rcv_rdreq,
      remote_apb_rcv_data_out => local_apb_rcv_data_out,
      remote_apb_rcv_empty    => local_apb_rcv_empty);

  remote_local_apbo_assign: process (local_apbo, remote_apbo) is
  begin  -- process remote_local_apbo_assign
    for i in 0 to NAPBSLV - 1 loop
      if this_local_apb_en(i) = '1' then
        apbo(i) <= local_apbo(i);
      else
        apbo(i) <= remote_apbo(i);
      end if;
    end loop;  -- i
  end process remote_local_apbo_assign;
  apb_ack <= local_apb_ack or remote_apb_ack;


  -- Connect pready for APB3 devices
  pready_gen: process (plic_pready, ibex_timer_pready, noc_apbi, prc_pready) is
  begin  -- process pready_gen
    if noc_apbi.psel(2) = '1' and (GLOB_CPU_ARCH = ariane or GLOB_CPU_ARCH = ibex) then
      pready <= plic_pready;
    elsif noc_apbi.psel(3) = '1' and GLOB_CPU_ARCH = ibex then
      pready <= ibex_timer_pready;
    elsif noc_apbi.psel(127) = '1' then
      pready <= prc_pready;
    else
      pready <= '1';
    end if;
  end process pready_gen;

  noc2apb_1 : noc2apb
    generic map (
      tech         => CFG_FABTECH,
      local_apb_en => this_local_apb_en)
    port map (
      rst              => rst,
      clk              => clk,
      local_y          => this_local_y,
      local_x          => this_local_x,
      apbi             => noc_apbi,
      apbo             => noc_apbo,
      pready           => pready,
      dvfs_transient   => '0',
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty);


  -- Enable configuration registers to relocate CPUs. Chaing this routing
  -- table, incombination with the reconfiguration of the HART ID allows any
  -- CPU (rather than CPU0 only) to boot in single-core mode.
  -- Default CPU ID and routing tables are defined as constants in the generated
  -- socmap, which is based on the ESP configuration file.
  override_cpu_loc <= tile_config(ESP_CSR_CPU_LOC_OVR_LSB);
  cpu_loc_ovr_gen: for i in 0 to CFG_NCPU_TILE - 1 generate
    cpu_loc_x(i) <= tile_config(ESP_CSR_CPU_LOC_OVR_LSB + 1 + i * 6 + 0 + 2 downto ESP_CSR_CPU_LOC_OVR_LSB + 1 + i * 6 + 0);
    cpu_loc_y(i) <= tile_config(ESP_CSR_CPU_LOC_OVR_LSB + 1 + i * 6 + 3 + 2 downto ESP_CSR_CPU_LOC_OVR_LSB + 1 + i * 6 + 3);
  end generate cpu_loc_ovr_gen;

  intreq2noc_1 : intreq2noc
    generic map (
      tech  => CFG_FABTECH,
      ncpu  => CFG_NCPU_TILE,
      cpu_y => cpu_y,
      cpu_x => cpu_x)
    port map (
      rst                => rst,
      clk                => clk,
      local_y            => this_local_y,
      local_x            => this_local_x,
      override_cpu_loc   => override_cpu_loc,
      cpu_loc_y          => cpu_loc_y,
      cpu_loc_x          => cpu_loc_x,
      irqi               => irqi,
      irqo               => irqo,
      irqi_fifo_overflow => irqi_fifo_overflow,
      irq_ack_rdreq      => irq_ack_rdreq,
      irq_ack_data_out   => irq_ack_data_out,
      irq_ack_empty      => irq_ack_empty,
      irq_wrreq          => irq_wrreq,
      irq_data_in        => irq_data_in,
      irq_full           => irq_full);

  noc2intreq_1 : noc2intreq
    generic map (
      tech    => CFG_FABTECH)
    port map (
      rst                => rst,
      clk                => clk,
      noc_pirq           => noc_pirq,
      interrupt_rdreq    => interrupt_rdreq,
      interrupt_data_out => interrupt_data_out,
      interrupt_empty    => interrupt_empty);

  -- Remote uncached slave and non-coherent DMA requests
  -- Requestes may be directed to the frame buffer or the boot ROM
  noc2ahbmst_1 : noc2ahbmst
    generic map (
      tech        => CFG_FABTECH,
      hindex      => CFG_GRETH + CFG_DSU_ETH,
      axitran     => GLOB_CPU_AXI,
      little_end  => GLOB_CPU_RISCV,
      narrow_noc  => 1,
      eth_dma     => 0,
      cacheline   => 1,
      l2_cache_en => 0)
    port map (
      rst                       => rst,
      clk                       => clk,
      local_y                   => this_local_y,
      local_x                   => this_local_x,
      ahbmi                     => ahbmi,
      ahbmo                     => ahbmo(CFG_GRETH + CFG_DSU_ETH),
      coherence_req_rdreq       => ahbm_rcv_rdreq,
      coherence_req_data_out    => ahbm_rcv_data_out,
      coherence_req_empty       => ahbm_rcv_empty,
      coherence_fwd_wrreq       => open,
      coherence_fwd_data_in     => open,
      coherence_fwd_full        => '0',
      coherence_rsp_snd_wrreq   => ahbm_snd_wrreq,
      coherence_rsp_snd_data_in => ahbm_snd_data_in,
      coherence_rsp_snd_full    => ahbm_snd_full,
      dma_rcv_rdreq             => dma_rcv_rdreq,
      dma_rcv_data_out          => dma_rcv_data_out,
      dma_rcv_empty             => dma_rcv_empty,
      dma_snd_wrreq             => dma_snd_wrreq,
      dma_snd_data_in           => dma_snd_data_in,
      dma_snd_full              => dma_snd_full,
      dma_snd_atleast_4slots    => dma_snd_atleast_4slots,
      dma_snd_exactly_3slots    => dma_snd_exactly_3slots);

  ahbs_rcv_rdreq <= ahbm_rcv_rdreq;
  ahbm_rcv_empty <= ahbs_rcv_empty;
  ahbs_snd_wrreq <= ahbm_snd_wrreq;
  ahbm_snd_full  <= ahbs_snd_full;

  large_bus: if ARCH_BITS /= 32 generate
    ahbm_rcv_data_out <= narrow_to_large_flit(ahbs_rcv_data_out);
    ahbs_snd_data_in <= large_to_narrow_flit(ahbm_snd_data_in);
  end generate large_bus;

  std_bus: if ARCH_BITS = 32 generate
    ahbm_rcv_data_out <= ahbs_rcv_data_out;
    ahbs_snd_data_in  <= ahbm_snd_data_in;
  end generate std_bus;

  -----------------------------------------------------------------------------
  -- Monitor for DVFS. (IO tile has no dvfs)
  -----------------------------------------------------------------------------
  mon_dvfs_int.vf        <= "1000";         -- Run at highest frequency always
  mon_dvfs_int.transient <= '0';
  mon_dvfs_int.clk       <= clk;
  mon_dvfs_int.acc_idle  <= '0';
  mon_dvfs_int.traffic   <= '0';
  mon_dvfs_int.burst     <= '0';

  mon_dvfs <= mon_dvfs_int;
  
  mon_noc(1) <= noc1_mon_noc_vec;
  mon_noc(2) <= noc2_mon_noc_vec;
  mon_noc(3) <= noc3_mon_noc_vec;
  mon_noc(4) <= noc4_mon_noc_vec;
  mon_noc(5) <= noc5_mon_noc_vec;
  mon_noc(6) <= noc6_mon_noc_vec;

  -- Memory mapped registers
  io_tile_csr : esp_tile_csr
    generic map(
      pindex  => 0)
    port map(
      clk => clk,
      rstn => rst,
      pconfig => this_csr_pconfig,
      mon_ddr => monitor_ddr_none,
      mon_mem => monitor_mem_none,
      mon_noc => mon_noc,
      mon_l2 => monitor_cache_none,
      mon_llc => monitor_cache_none,
      mon_acc => monitor_acc_none,
      mon_dvfs => mon_dvfs_int,
      tile_config => tile_config,
      srst => open,
      apbi => noc_apbi,
      apbo => noc_apbo(0),
      prc_interrupt => vsm_VS_0_sw_startup_req 
    );

  -- PRC 
  generate_prc : if has_prc(CFG_FABTECH) = 1 and CFG_PRC = 1 and SIMULATION = false generate
  prc_1: prc_inst
    port map (
      clk                       => clk,
      reset                     => rst,
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
      icap_reset                => rst,
      icap_csib                 => icap_csib,
      icap_rdwrb                => icap_rdwrb,
      icap_i                    => icap_o,
      icap_o                    => icap_i,
      --vsm_VS_0_rm_shutdown_req  => vsm_VS_0_rm_shutdown_req,
      vsm_VS_0_rm_shutdown_ack  => vsm_VS_0_rm_shutdown_ack,
      --vsm_VS_0_rm_decouple      => vsm_VS_0_rm_decouple,
      --vsm_VS_0_rm_reset         => vsm_VS_0_rm_reset,
      --vsm_VS_0_event_error      => vsm_VS_0_event_error,
      --vsm_VS_0_sw_shutdown_req  => vsm_VS_0_sw_shutdown_req,
      vsm_VS_0_sw_startup_req   => vsm_VS_0_sw_startup_req,
      --icap_avail                => icap_avail,
      --icap_prdone               => icap_prdone,
      --icap_prerror              => icap_prerror,
      s_axi_reg_awaddr          => s_axil_awaddr_masked,
      s_axi_reg_awvalid         => s_axil_awvalid,
      s_axi_reg_awready         => s_axil_awready,
      s_axi_reg_wdata           => s_axil_wdata,
      s_axi_reg_wvalid          => s_axil_wvalid,
      s_axi_reg_wready          => s_axil_wready,
      s_axi_reg_bresp           => s_axil_bresp,
      s_axi_reg_bvalid          => s_axil_bvalid,
      s_axi_reg_bready          => s_axil_bready,
      s_axi_reg_araddr          => s_axil_araddr_masked,
      s_axi_reg_arvalid         => s_axil_arvalid,
      s_axi_reg_arready         => s_axil_arready,
      s_axi_reg_rdata           => s_axil_rdata,
      s_axi_reg_rresp           => s_axil_rresp,
      s_axi_reg_rvalid          => s_axil_rvalid,
      s_axi_reg_rready          => s_axil_rready);

    s_axil_araddr_masked <= s_axil_araddr and prc_mask;
    s_axil_awaddr_masked <= s_axil_awaddr and prc_mask;

  -- ICAP3 instance
  icap_inst_1: icap
    generic map (
      tech  =>  CFG_FABTECH)
    port map (
      icap_clk      => clk,
      icap_csib     => icap_csib,
      icap_rdwrb    => icap_rdwrb,
      icap_i        => icap_i,
      icap_o        => icap_o,
      icap_avail    => icap_avail,
      icap_prdone   => icap_prdone,
      icap_prerror  => icap_prerror);
  
  axi2noc_1: axislv2noc
    generic map (
      tech             => CFG_FABTECH,
      nmst             => 1,
      split_transaction => SPLIT_TRANS,
      retarget_for_dma => 1,    --enable retarget_for_dma
      mem_axi_port     => 0,
      mem_num          => CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE,
      mem_info         => tile_mem_list(0 to CFG_NMEM_TILE + CFG_NSLM_TILE - 1), --tile_mem_list, --nofb_mem_info,
      slv_y            => tile_y(io_tile_id), --io_y,
      slv_x            => tile_x(io_tile_id)) --, io_x)
    port map (
      rst                        => rst,
      clk                        => clk,
      local_y                    => tile_y(io_tile_id), --local_y,
      local_x                    => tile_x(io_tile_id), --local_x,
      mosi                       => mosi,
      somi                       => somi,
      coherence_req_wrreq        => prc_dma_snd_wrreq,
      coherence_req_data_in      => prc_dma_snd_data_in,
      coherence_req_full         => prc_dma_snd_full,
      coherence_rsp_rcv_rdreq    => prc_dma_rcv_rdreq,
      coherence_rsp_rcv_data_out => prc_dma_rcv_data_out,
      coherence_rsp_rcv_empty    => prc_dma_rcv_empty,
      remote_ahbs_snd_wrreq      => open,
      remote_ahbs_snd_data_in    => open,
      remote_ahbs_snd_full       => '0',
      remote_ahbs_rcv_rdreq      => open,
      remote_ahbs_rcv_data_out   => (others => '0'),
      remote_ahbs_rcv_empty      => '1',
      coherence                  => prc_coherence);

      mosi(0).ar.addr(31 downto 0)      <= m_axi_mem_araddr;
      mosi(0).ar.len                    <= m_axi_mem_arlen;  
      mosi(0).ar.size                   <= m_axi_mem_arsize;
      mosi(0).ar.burst                  <= m_axi_mem_arburst;
      mosi(0).ar.prot                   <= m_axi_mem_arprot; 
      mosi(0).ar.cache                  <= m_axi_mem_arcache;
      mosi(0).ar.valid                  <= m_axi_mem_arvalid; 
      mosi(0).r.ready                   <= m_axi_mem_rready;
      m_axi_mem_arready                 <= somi(0).ar.ready;
      m_axi_mem_rdata                   <= somi(0).r.data(31 downto 0);
      m_axi_mem_rresp                   <= somi(0).r.resp;
      m_axi_mem_rlast                   <= somi(0).r.last;
      m_axi_mem_rvalid                  <= somi(0).r.valid;
  
  -----------------------------------------------------------------------------
  -- APB 127: apb2axi 
  -----------------------------------------------------------------------------
  apb2axil_1: apb2axil
    port map (
      clk               => clk,
      rstn              => rst,
      paddr             => noc_apbi.paddr,
      penable           => noc_apbi.penable,
      psel              => noc_apbi.psel(127),
      pwdata            => noc_apbi.pwdata,
      pwrite            => noc_apbi.pwrite,
      prdata            => noc_apbo(127).prdata,
      pready            => prc_pready,      
      pslverr           => open,
      s_axil_awvalid    => s_axil_awvalid,  
      s_axil_awready    => s_axil_awready,
      s_axil_awaddr     => s_axil_awaddr,
      s_axil_wvalid     => s_axil_wvalid,
      s_axil_wready     => s_axil_wready,
      s_axil_wdata      => s_axil_wdata,
      s_axil_wstrb      => s_axil_wstrb,
      s_axil_arvalid    => s_axil_arvalid,
      s_axil_arready    => s_axil_arready,
      s_axil_araddr     => s_axil_araddr,
      s_axil_rvalid     => s_axil_rvalid,
      s_axil_rready     => s_axil_rready,
      s_axil_rdata      => s_axil_rdata,
      s_axil_rresp      => s_axil_rresp,
      s_axil_bvalid     => s_axil_bvalid,
      s_axil_bready     => s_axil_bready,
      s_axil_bresp      => s_axil_bresp);

  noc_apbo(127).pirq <= (CFG_PRC_IRQ => vsm_VS_0_sw_startup_req, others => '0'); --connect PRC interrupt
  noc_apbo(127).pconfig <= fixed_apbo_pconfig(127);
  noc_apbo(127).pindex <= 127;
 end generate generate_prc;

-----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  misc_tile_q_1 : misc_tile_q
    generic map (
      tech => CFG_FABTECH)
    port map (
      rst                       => rst,
      clk                       => clk,
      ahbs_rcv_rdreq            => ahbs_rcv_rdreq,
      ahbs_rcv_data_out         => ahbs_rcv_data_out,
      ahbs_rcv_empty            => ahbs_rcv_empty,
      ahbs_snd_wrreq            => ahbs_snd_wrreq,
      ahbs_snd_data_in          => ahbs_snd_data_in,
      ahbs_snd_full             => ahbs_snd_full,
      remote_ahbs_rcv_rdreq     => remote_ahbs_rcv_rdreq,
      remote_ahbs_rcv_data_out  => remote_ahbs_rcv_data_out,
      remote_ahbs_rcv_empty     => remote_ahbs_rcv_empty,
      remote_ahbs_snd_wrreq     => remote_ahbs_snd_wrreq,
      remote_ahbs_snd_data_in   => remote_ahbs_snd_data_in,
      remote_ahbs_snd_full      => remote_ahbs_snd_full,
      prc_dma_rcv_rdreq         => prc_dma_rcv_rdreq,
      prc_dma_rcv_data_out      => prc_dma_rcv_data_out,
      prc_dma_rcv_empty         => prc_dma_rcv_empty,
      prc_dma_snd_wrreq         => prc_dma_snd_wrreq,
      prc_dma_snd_data_in       => prc_dma_snd_data_in,
      prc_dma_snd_full          => prc_dma_snd_full,
      dma_rcv_rdreq             => dma_rcv_rdreq,
      dma_rcv_data_out          => dma_rcv_data_out,
      dma_rcv_empty             => dma_rcv_empty,
      dma_snd_wrreq             => dma_snd_wrreq,
      dma_snd_data_in           => dma_snd_data_in,
      dma_snd_full              => dma_snd_full,
      dma_snd_atleast_4slots    => dma_snd_atleast_4slots,
      dma_snd_exactly_3slots    => dma_snd_exactly_3slots,
      coherent_dma_rcv_rdreq    => coherent_dma_rcv_rdreq,
      coherent_dma_rcv_data_out => coherent_dma_rcv_data_out,
      coherent_dma_rcv_empty    => coherent_dma_rcv_empty,
      coherent_dma_snd_wrreq    => coherent_dma_snd_wrreq,
      coherent_dma_snd_data_in  => coherent_dma_snd_data_in,
      coherent_dma_snd_full     => coherent_dma_snd_full,
      apb_rcv_rdreq             => apb_rcv_rdreq,
      apb_rcv_data_out          => apb_rcv_data_out,
      apb_rcv_empty             => apb_rcv_empty,
      apb_snd_wrreq             => apb_snd_wrreq,
      apb_snd_data_in           => apb_snd_data_in,
      apb_snd_full              => apb_snd_full,
      remote_apb_rcv_rdreq      => remote_apb_rcv_rdreq,
      remote_apb_rcv_data_out   => remote_apb_rcv_data_out,
      remote_apb_rcv_empty      => remote_apb_rcv_empty,
      remote_apb_snd_wrreq      => remote_apb_snd_wrreq,
      remote_apb_snd_data_in    => remote_apb_snd_data_in,
      remote_apb_snd_full       => remote_apb_snd_full,
      local_apb_rcv_rdreq          => local_apb_rcv_rdreq,
      local_apb_rcv_data_out       => local_apb_rcv_data_out,
      local_apb_rcv_empty          => local_apb_rcv_empty,
      local_remote_apb_snd_wrreq   => local_remote_apb_snd_wrreq,
      local_remote_apb_snd_data_in => local_remote_apb_snd_data_in,
      local_remote_apb_snd_full    => local_remote_apb_snd_full,
      irq_ack_rdreq             => irq_ack_rdreq,
      irq_ack_data_out          => irq_ack_data_out,
      irq_ack_empty             => irq_ack_empty,
      irq_wrreq                 => irq_wrreq,
      irq_data_in               => irq_data_in,
      irq_full                  => irq_full,
      interrupt_rdreq           => interrupt_rdreq,
      interrupt_data_out        => interrupt_data_out,
      interrupt_empty           => interrupt_empty,
      interrupt_ack_wrreq       => interrupt_ack_wrreq,
      interrupt_ack_data_in     => interrupt_ack_data_in,
      interrupt_ack_full        => interrupt_ack_full,
      noc1_out_data              => test1_output_port,
      noc1_out_void              => test1_data_void_out,
      noc1_out_stop              => test1_stop_out,
      noc1_in_data               => test1_input_port,
      noc1_in_void               => test1_data_void_in,
      noc1_in_stop               => test1_stop_in,
      noc2_out_data              => test2_output_port,
      noc2_out_void              => test2_data_void_out,
      noc2_out_stop              => test2_stop_out,
      noc2_in_data               => test2_input_port,
      noc2_in_void               => test2_data_void_in,
      noc2_in_stop               => test2_stop_in,
      noc3_out_data              => test3_output_port,
      noc3_out_void              => test3_data_void_out,
      noc3_out_stop              => test3_stop_out,
      noc3_in_data               => test3_input_port,
      noc3_in_void               => test3_data_void_in,
      noc3_in_stop               => test3_stop_in,
      noc4_out_data              => test4_output_port,
      noc4_out_void              => test4_data_void_out,
      noc4_out_stop              => test4_stop_out,
      noc4_in_data               => test4_input_port,
      noc4_in_void               => test4_data_void_in,
      noc4_in_stop               => test4_stop_in,
      noc5_out_data              => test5_output_port,
      noc5_out_void              => test5_data_void_out,
      noc5_out_stop              => test5_stop_out,
      noc5_in_data               => test5_input_port,
      noc5_in_void               => test5_data_void_in,
      noc5_in_stop               => test5_stop_in,
      noc6_out_data              => test6_output_port,
      noc6_out_void              => test6_data_void_out,
      noc6_out_stop              => test6_stop_out,
      noc6_in_data               => test6_input_port,
      noc6_in_void               => test6_data_void_in,
      noc6_in_stop               => test6_stop_in);

end;
