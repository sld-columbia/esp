-----------------------------------------------------------------------------
--  I/O tile.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity tile_io is
  generic (
    fabtech             : integer := CFG_FABTECH;
    memtech             : integer := CFG_MEMTECH;
    padtech             : integer := CFG_PADTECH;
    disas               : integer := CFG_DISAS;   -- Enable disassembly to console
    dbguart             : integer := CFG_DUART;   -- Print UART on console
    pclow               : integer := CFG_PCLOW);
  port (
    rst             : in    std_ulogic;
    clk             : in    std_ulogic;
    uart_rxd        : in    std_ulogic;   -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_ulogic;   -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_ulogic;   -- UART1_CTSN (u1i.ctsn)
    uart_rtsn       : out   std_ulogic;   -- UART1_RTSN (u1o.rtsn)
    dvi_apbi        : out apb_slv_in_type;
    dvi_apbo        : in  apb_slv_out_type;
    dvi_ahbmi       : out ahb_mst_in_type;
    dvi_ahbmo       : in  ahb_mst_out_type;
    --TODO: REMOVE and use proxy for eth irq!
    eth0_pirq    : in  std_logic_vector(NAHBIRQ-1 downto 0);
    sgmii0_pirq    : in  std_logic_vector(NAHBIRQ-1 downto 0);
    -- TODO: REMOVE!
    irqi_o  : out irq_in_vector(0 to CFG_NCPU_TILE-1);
    irqo_i  : in  irq_out_vector(0 to CFG_NCPU_TILE-1);
    -- NOC
    noc1_input_port    : out noc_flit_type;
    noc1_data_void_in  : out std_ulogic;
    noc1_stop_in       : out  std_ulogic;
    noc1_output_port   : in  noc_flit_type;
    noc1_data_void_out : in  std_ulogic;
    noc1_stop_out      : in  std_ulogic;
    noc2_input_port    : out noc_flit_type;
    noc2_data_void_in  : out std_ulogic;
    noc2_stop_in       : out std_ulogic;
    noc2_output_port   : in  noc_flit_type;
    noc2_data_void_out : in  std_ulogic;
    noc2_stop_out      : in  std_ulogic;
    noc3_input_port    : out noc_flit_type;
    noc3_data_void_in  : out std_ulogic;
    noc3_stop_in       : out std_ulogic;
    noc3_output_port   : in  noc_flit_type;
    noc3_data_void_out : in  std_ulogic;
    noc3_stop_out      : in  std_ulogic;
    noc4_input_port    : out noc_flit_type;
    noc4_data_void_in  : out std_ulogic;
    noc4_stop_in       : out  std_ulogic;
    noc4_output_port   : in  noc_flit_type;
    noc4_data_void_out : in  std_ulogic;
    noc4_stop_out      : in  std_ulogic;
    noc5_input_port    : out noc_flit_type;
    noc5_data_void_in  : out std_ulogic;
    noc5_stop_in       : out  std_ulogic;
    noc5_output_port   : in  noc_flit_type;
    noc5_data_void_out : in  std_ulogic;
    noc5_stop_out      : in  std_ulogic;
    noc6_input_port    : out noc_flit_type;
    noc6_data_void_in  : out std_ulogic;
    noc6_stop_in       : out  std_ulogic;
    noc6_output_port   : in  noc_flit_type;
    noc6_data_void_out : in  std_ulogic;
    noc6_stop_out      : in  std_ulogic;
    mon_dvfs           : out monitor_dvfs_type
    );

end;

architecture rtl of tile_io is

-- Amba bus signals and configuration
signal apbi  : apb_slv_in_type;
signal apbo  : apb_slv_out_vector;
signal noc_pirq  : std_logic_vector(NAHBIRQ-1 downto 0); -- interrupt result bus
                                                         -- from noc
-- Interrupt controller
signal irqi : irq_in_vector(0 to CFG_NCPU_TILE-1);
signal irqo : irq_out_vector(0 to CFG_NCPU_TILE-1);

signal ctrl_apbi  : apb_slv_in_type;
signal ctrl_apbo  : apb_slv_out_vector := (others => apb_none);

-- Peripherals
-- UART
signal u1i : uart_in_type;
signal u1o : uart_out_type;

-- General Purpose Timer
signal gpti : gptimer_in_type;          --Partially driven by DSU..
signal gpto : gptimer_out_type;         --Unused

-- SVGA with dedicated memory
signal ahbsi1 : ahb_slv_in_type;
signal ahbso1 : ahb_slv_out_vector;
signal ahbmi1 : ahb_mst_in_type;
signal ahbmo1 : ahb_mst_out_vector;
signal ahbsi2 : ahb_slv_in_type;
signal ahbso2 : ahb_slv_out_vector;
signal ahbmi2 : ahb_mst_in_type;
signal ahbmo2 : ahb_mst_out_vector;

-- services
signal ahbs_req_rdreq           : std_ulogic;
signal ahbs_req_data_out        : noc_flit_type;
signal ahbs_req_empty           : std_ulogic;
signal ahbs_rsp_line_wrreq      : std_ulogic;
signal ahbs_rsp_line_data_in    :  noc_flit_type;
signal ahbs_rsp_line_full       : std_ulogic;
signal dma_rcv_rdreq                 : std_ulogic;
signal dma_rcv_data_out              : noc_flit_type;
signal dma_rcv_empty                 : std_ulogic;
signal dma_snd_wrreq                 : std_ulogic;
signal dma_snd_data_in               : noc_flit_type;
signal dma_snd_full                  : std_ulogic;
signal dma_snd_atleast_4slots        : std_ulogic;
signal dma_snd_exactly_3slots        : std_ulogic;
signal apb_rcv_rdreq            : std_ulogic;
signal apb_rcv_data_out         : noc_flit_type;
signal apb_rcv_empty            : std_ulogic;
signal apb_snd_wrreq            : std_ulogic;
signal apb_snd_data_in          : noc_flit_type;
signal apb_snd_full             : std_ulogic;
signal irq_wrreq                : std_ulogic;
signal irq_data_in              : noc_flit_type;
signal irq_full                 : std_ulogic;
signal irq_ack_rdreq            : std_ulogic;
signal irq_ack_data_out         : noc_flit_type;
signal irq_ack_empty            : std_ulogic;
signal interrupt_rdreq          : std_ulogic;
signal interrupt_data_out       : noc_flit_type;
signal interrupt_empty          : std_ulogic;

constant local_y : local_yx := tile_y(io_tile_id);
constant local_x : local_yx := tile_x(io_tile_id);
constant local_apb_en : std_logic_vector(NAPBSLV-1 downto 0) := (
  1 => '1',
  2 => '1',
  3 => '1',
  13 => to_std_logic(CFG_SVGA_ENABLE),
  others => '0');

begin


-------------------------------------------------------------------------------
-- APB 1: UART interface ------------------------------------------------------
-------------------------------------------------------------------------------
  uart_txd  <= u1o.txd;
  u1i.rxd   <= uart_rxd;
  uart_rtsn <= u1o.rtsn;
  u1i.ctsn  <= uart_ctsn;

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart                     -- UART 1
      generic map (pindex => 1, paddr => 1, pirq => CFG_UART1_IRQ, console => dbguart,
         fifosize => CFG_UART1_FIFO)
      port map (rst, clk, apbi, apbo(1), u1i, u1o);
      u1i.extclk <= '0';
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;


----------------------------------------------------------------------
---  APB 2: Interrupt Controller -------------------------------------
----------------------------------------------------------------------

  --TODO remove. Temporary hack to test ethernet irq
  irqi <= (others => irq_in_none);

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp         -- interrupt controller
    generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU_TILE)
    port map (rst, clk, apbi, apbo(2), irqo_i, irqi_o);
  end generate;
  irq3 : if CFG_IRQ3_ENABLE = 0 generate
    x : for i in 0 to CFG_NCPU_TILE-1 generate
      irqi(i).irl <= "0000";
    end generate;
    apbo(2) <= apb_none;
  end generate;

----------------------------------------------------------------------
---  APB 3: Timer ----------------------------------------------------
----------------------------------------------------------------------

  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer          -- timer unit
      generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ,
                   sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM,
                   nbits => CFG_GPT_TW, wdog => CFG_GPT_WDOGEN*CFG_GPT_WDOG)
      port map (rst, clk, apbi, apbo(3), gpti, gpto);
    gpti.dhalt <= '0'; gpti.extclk <= '0';
  end generate;

  nogpt : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  -----------------------------------------------------------------------------
  -- APB 13: DVI
  -----------------------------------------------------------------------------

  -- SVGA component interface
  svga_on_apb: if CFG_SVGA_ENABLE /= 0 generate
    apbo(13) <= dvi_apbo;
    ahbmo2(0) <= dvi_ahbmo;

    -- Dedicated Video Memory with dual-port interface.

    -- SLV 7: 0xB0100000 - 0xB01FFFFF
    ahbmo1(NAHBMST-1 downto 1) <= (others => ahbm_none);
    ahbmo2(NAHBMST-1 downto 1) <= (others => ahbm_none);
    ahbso1(NAHBSLV-1 downto 1) <= (others => ahbs_none);
    ahbso2(NAHBSLV-1 downto 1) <= (others => ahbs_none);
    ahbram_dp_1: ahbram_dp
      generic map (
        hindex1 => 0,
        haddr1  => CFG_SVGA_MEMORY_HADDR,
        hindex2 => 0,
        haddr2  => CFG_SVGA_MEMORY_HADDR,
        hmask   => fb_hmask,
        tech    => memtech,
        kbytes  => 512,
        wordsz  => 32)
      port map (
        rst    => rst,
        clk    => clk,
        ahbsi1 => ahbsi1,
        ahbso1 => ahbso1(0),
        ahbsi2 => ahbsi2,
        ahbso2 => ahbso2(0));

    -- AHB1: Proxy noc to AHB master and R/W AHBRAM slave
    ahb1 : ahbctrl       -- AHB arbiter/multiplexer
      generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                   rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                   nahbm => 1, nahbs => 1)
      port map (rst, clk, ahbmi1, ahbmo1, ahbsi1, ahbso1);

    -- AHB2: SVGA master and R AHBRAM slave
    ahb2 : ahbctrl       -- AHB arbiter/multiplexer
      generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                   rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                   nahbm => 1, nahbs => 1)
      port map (rst, clk, ahbmi2, ahbmo2, ahbsi2, ahbso2);

  end generate svga_on_apb;

  no_svga_on_apb: if CFG_SVGA_ENABLE = 0 generate
    ahbmo2(0) <= ahbm_none;
  end generate no_svga_on_apb;

  dvi_apbi <= apbi;
  dvi_ahbmi <= ahbmi2;


  -----------------------------------------------------------------------------
  -- undriven APB outputs
  -----------------------------------------------------------------------------
  no_apb: for i in 0 to NAPBSLV-1 generate
    no_local_apb: if local_apb_en(i) = '0' generate
      apbo(i) <= apb_none;
    end generate no_local_apb;
  end generate no_apb;

  -----------------------------------------------------------------------------
  -- Services
  -----------------------------------------------------------------------------

  apb_assignments: process (ctrl_apbi, apbo, noc_pirq, eth0_pirq, sgmii0_pirq)
  begin  -- process apb_assignments
    apbi <= ctrl_apbi;
    apbi.pirq <= noc_pirq or apbo(1).pirq or apbo(2).pirq or apbo(3).pirq or
                 eth0_pirq or sgmii0_pirq;
    ctrl_apbo <= apbo;
  end process apb_assignments;

  misc_noc2apb_1: misc_noc2apb
    generic map (
      tech         => fabtech,
      local_y      => local_y,
      local_x      => local_x,
      local_apb_en => local_apb_en)
    port map (
      rst              => rst,
      clk              => clk,
      apbi             => ctrl_apbi,
      apbo             => ctrl_apbo,
      dvfs_transient   => '0',
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty);

  --TODO: make the following broadcast the irq for all CPUs
  no_irqi_cpu: for i in 1 to CFG_NCPU_TILE-1 generate
    --REMOVE THE FOLLOWING!
    irqo(i) <= irq_out_none;
  end generate no_irqi_cpu;

  -- misc_irq2noc_1: misc_irq2noc
  --   generic map (
  --     tech    => fabtech,
  --     cpu_id  => 0,
  --     local_y => local_y,
  --     local_x => local_x,
  --     cpu_y   => cpu_y,
  --     cpu_x   => cpu_x)
  --   port map (
  --     rst              => rst,
  --     clk              => clk,
  --     irqi             => irqi(0),
  --     irqo             => irqo(0),
  --     irq_ack_rdreq    => irq_ack_rdreq,
  --     irq_ack_data_out => irq_ack_data_out,
  --     irq_ack_empty    => irq_ack_empty,
  --     irq_wrreq        => irq_wrreq,
  --     irq_data_in      => irq_data_in,
  --     irq_full         => irq_full);

  misc_noc2interrupt_1: misc_noc2interrupt
    generic map (
      tech    => fabtech,
      local_y => local_y,
      local_x => local_x)
    port map (
      rst                => rst,
      clk                => clk,
      noc_pirq           => noc_pirq,
      interrupt_rdreq    => interrupt_rdreq,
      interrupt_data_out => interrupt_data_out,
      interrupt_empty    => interrupt_empty);

  svga_on_apb_proxy: if CFG_SVGA_ENABLE /= 0 generate
    -- FROM CPU to AMBA1 for frame buffer
    mem_noc2ahbm_1: mem_noc2ahbm
      generic map (
        tech      => fabtech,
        ncpu      => CFG_NCPU_TILE,
        hindex    => 0,
        local_y   => local_y,
        local_x   => local_x,
        cacheline => CFG_DLINE,
        destination => 0)
      port map (
        rst                           => rst,
        clk                           => clk,
        ahbmi                         => ahbmi1,
        ahbmo                         => ahbmo1(0),
        coherence_req_rdreq           => ahbs_req_rdreq,
        coherence_req_data_out        => ahbs_req_data_out,
        coherence_req_empty           => ahbs_req_empty,
        coherence_fwd_wrreq           => open,
        coherence_fwd_data_in         => open,
        coherence_fwd_full            => '0',
        coherence_rsp_snd_wrreq       => ahbs_rsp_line_wrreq,
        coherence_rsp_snd_data_in     => ahbs_rsp_line_data_in,
        coherence_rsp_snd_full        => ahbs_rsp_line_full,
        dma_rcv_rdreq                 => dma_rcv_rdreq,
        dma_rcv_data_out              => dma_rcv_data_out,
        dma_rcv_empty                 => dma_rcv_empty,
        dma_snd_wrreq                 => dma_snd_wrreq,
        dma_snd_data_in               => dma_snd_data_in,
        dma_snd_full                  => dma_snd_full,
        dma_snd_atleast_4slots        => dma_snd_atleast_4slots,
        dma_snd_exactly_3slots        => dma_snd_exactly_3slots);
  end generate svga_on_apb_proxy;

  no_svga_on_apb_proxy: if CFG_SVGA_ENABLE = 0 generate
    ahbs_req_rdreq <= '0';
    ahbs_rsp_line_wrreq <= '0';
    ahbs_rsp_line_data_in <= (others => '0');
    dma_rcv_rdreq <= '0';
    dma_snd_wrreq <= '0';
    dma_snd_data_in <= (others => '0');
  end generate no_svga_on_apb_proxy;


  -----------------------------------------------------------------------------
  -- Monitor for DVFS. (IO tile has no dvfs)
  -----------------------------------------------------------------------------
  mon_dvfs.vf <= "1000";                   -- Run at highest frequency always
  mon_dvfs.transient <= '0';
  mon_dvfs.clk <= clk;
  mon_dvfs.acc_idle <= '0';
  mon_dvfs.traffic <= '0';
  mon_dvfs.burst <= '0';

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  misc_tile_q_1: misc_tile_q
    generic map (
      tech => fabtech)
    port map (
      rst                      => rst,
      clk                      => clk,
      ahbs_req_rdreq           => ahbs_req_rdreq,
      ahbs_req_data_out        => ahbs_req_data_out,
      ahbs_req_empty           => ahbs_req_empty,
      ahbs_rsp_line_wrreq      => ahbs_rsp_line_wrreq,
      ahbs_rsp_line_data_in    => ahbs_rsp_line_data_in,
      ahbs_rsp_line_full       => ahbs_rsp_line_full,
      dma_rcv_rdreq            => dma_rcv_rdreq,
      dma_rcv_data_out         => dma_rcv_data_out,
      dma_rcv_empty            => dma_rcv_empty,
      dma_snd_wrreq            => dma_snd_wrreq,
      dma_snd_data_in          => dma_snd_data_in,
      dma_snd_full             => dma_snd_full,
      dma_snd_atleast_4slots   => dma_snd_atleast_4slots,
      dma_snd_exactly_3slots   => dma_snd_exactly_3slots,
      apb_rcv_rdreq            => apb_rcv_rdreq,
      apb_rcv_data_out         => apb_rcv_data_out,
      apb_rcv_empty            => apb_rcv_empty,
      apb_snd_wrreq            => apb_snd_wrreq,
      apb_snd_data_in          => apb_snd_data_in,
      apb_snd_full             => apb_snd_full,
      irq_wrreq                => irq_wrreq,
      irq_data_in              => irq_data_in,
      irq_full                 => irq_full,
      irq_ack_rdreq            => irq_ack_rdreq,
      irq_ack_data_out         => irq_ack_data_out,
      irq_ack_empty            => irq_ack_empty,
      interrupt_rdreq          => interrupt_rdreq,
      interrupt_data_out       => interrupt_data_out,
      interrupt_empty          => interrupt_empty,
      noc1_out_data            => noc1_output_port,
      noc1_out_void            => noc1_data_void_out,
      noc1_out_stop            => noc1_stop_in,
      noc1_in_data             => noc1_input_port,
      noc1_in_void             => noc1_data_void_in,
      noc1_in_stop             => noc1_stop_out,
      noc2_out_data            => noc2_output_port,
      noc2_out_void            => noc2_data_void_out,
      noc2_out_stop            => noc2_stop_in,
      noc2_in_data             => noc2_input_port,
      noc2_in_void             => noc2_data_void_in,
      noc2_in_stop             => noc1_stop_out,
      noc3_out_data            => noc3_output_port,
      noc3_out_void            => noc3_data_void_out,
      noc3_out_stop            => noc3_stop_in,
      noc3_in_data             => noc3_input_port,
      noc3_in_void             => noc3_data_void_in,
      noc3_in_stop             => noc3_stop_out,
      noc4_out_data            => noc4_output_port,
      noc4_out_void            => noc4_data_void_out,
      noc4_out_stop            => noc4_stop_in,
      noc4_in_data             => noc4_input_port,
      noc4_in_void             => noc4_data_void_in,
      noc4_in_stop             => noc4_stop_out,
      noc5_out_data            => noc5_output_port,
      noc5_out_void            => noc5_data_void_out,
      noc5_out_stop            => noc5_stop_in,
      noc5_in_data             => noc5_input_port,
      noc5_in_void             => noc5_data_void_in,
      noc5_in_stop             => noc5_stop_out,
      noc6_out_data            => noc6_output_port,
      noc6_out_void            => noc6_data_void_out,
      noc6_out_stop            => noc6_stop_in,
      noc6_in_data             => noc6_input_port,
      noc6_in_void             => noc6_data_void_in,
      noc6_in_stop             => noc6_stop_out);

 end;

