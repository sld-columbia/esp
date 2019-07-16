-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
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
use work.net.all;
use work.jtag.all;
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
use work.memoryctrl.all;

entity tile_io is
  generic (
    SIMULATION : boolean := false);
  port (
    rst                : in  std_ulogic;
    srst               : out std_ulogic;
    clk                : in  std_ulogic;
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
    --TODO: REMOVE THIS and use NoC proxies
    uart_irq           : out std_ulogic;
    eth0_irq           : out std_ulogic;
    sgmii0_irq         : out std_ulogic;
    -- NOC
    noc1_input_port    : out noc_flit_type;
    noc1_data_void_in  : out std_ulogic;
    noc1_stop_in       : out std_ulogic;
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
    noc4_stop_in       : out std_ulogic;
    noc4_output_port   : in  noc_flit_type;
    noc4_data_void_out : in  std_ulogic;
    noc4_stop_out      : in  std_ulogic;
    noc5_input_port    : out misc_noc_flit_type;
    noc5_data_void_in  : out std_ulogic;
    noc5_stop_in       : out std_ulogic;
    noc5_output_port   : in  misc_noc_flit_type;
    noc5_data_void_out : in  std_ulogic;
    noc5_stop_out      : in  std_ulogic;
    noc6_input_port    : out noc_flit_type;
    noc6_data_void_in  : out std_ulogic;
    noc6_stop_in       : out std_ulogic;
    noc6_output_port   : in  noc_flit_type;
    noc6_data_void_out : in  std_ulogic;
    noc6_stop_out      : in  std_ulogic;
    mon_dvfs           : out monitor_dvfs_type
    );

end;

architecture rtl of tile_io is

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

  -- JTAG (Connected internally through tap and bscan components
  signal tck, tckn, tms, tdi, tdo : std_ulogic;

  -- Interrupt controller
  signal irqi               : irq_in_vector(0 to CFG_NCPU_TILE-1);
  signal irqo               : irq_out_vector(0 to CFG_NCPU_TILE-1);
  signal irqi_fifo_overflow : std_logic;
  signal noc_pirq           : std_logic_vector(NAHBIRQ-1 downto 0);  -- interrupt result bus from noc

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

  -- Tile parameters
  constant this_local_y           : local_yx                           := tile_y(io_tile_id);
  constant this_local_x           : local_yx                           := tile_x(io_tile_id);
  constant this_local_apb_en      : std_logic_vector(0 to NAPBSLV - 1) := local_apb_mask(io_tile_id);
  constant this_remote_apb_slv_en : std_logic_vector(0 to NAPBSLV - 1) := remote_apb_slv_mask(io_tile_id);
  constant this_apb_en            : std_logic_vector(0 to NAPBSLV - 1) := this_local_apb_en or this_remote_apb_slv_en;
  constant this_local_ahb_en      : std_logic_vector(0 to NAHBSLV - 1) := local_ahb_mask(io_tile_id);
  constant this_remote_ahb_slv_en : std_logic_vector(0 to NAHBSLV - 1) := remote_ahb_mask(io_tile_id);

  -- attribute mark_debug : string;

  -- attribute mark_debug of ahbsi                 : signal is "true";
  -- attribute mark_debug of ctrl_ahbso            : signal is "true";
  -- attribute mark_debug of ahbmi                 : signal is "true";
  -- attribute mark_debug of eth0_ahbmo            : signal is "true";
  -- attribute mark_debug of edcl_ahbmo            : signal is "true";
  -- attribute mark_debug of coherent_dma_selected : signal is "true";
  -- attribute mark_debug of coherent_dma_rcv_rdreq    : signal is "true";
  -- attribute mark_debug of coherent_dma_rcv_data_out : signal is "true";
  -- attribute mark_debug of coherent_dma_rcv_empty    : signal is "true";
  -- attribute mark_debug of coherent_dma_snd_wrreq    : signal is"true";
  -- attribute mark_debug of coherent_dma_snd_data_in  : signal is"true";
  -- attribute mark_debug of coherent_dma_snd_full     : signal is"true";
  -- attribute mark_debug of remote_ahbs_rcv_rdreq     : signal is"true";
  -- attribute mark_debug of remote_ahbs_rcv_data_out  : signal is"true";
  -- attribute mark_debug of remote_ahbs_rcv_empty     : signal is"true";
  -- attribute mark_debug of remote_ahbs_snd_wrreq     : signal is"true";
  -- attribute mark_debug of remote_ahbs_snd_data_in   : signal is"true";
  -- attribute mark_debug of remote_ahbs_snd_full      : signal is"true";

begin


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
                 nahbm   => CFG_AHB_JTAG + CFG_GRETH + CFG_DSU_ETH + 1, nahbs => maxahbs)
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

  nam0 : for i in (CFG_AHB_JTAG + CFG_GRETH + CFG_DSU_ETH + 1) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

  -- NB: all local I/O-bus slaves are accessed through proxy as if they were
  -- remote. This allows any master in the system to access them
  no_pslv_gen_1 : for i in 5 to 12 generate
    noc_apbo(i) <= apb_none;
  end generate no_pslv_gen_1;
  no_pslv_gen_2 : for i in 16 to NAPBSLV - 1 generate
    noc_apbo(i) <= apb_none;
  end generate no_pslv_gen_2;


  -----------------------------------------------------------------------------
  -- JTAG Master
  -----------------------------------------------------------------------------
  ahbjtaggen0 : if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => CFG_FABTECH, hindex => 0)
      port map(rst, clk, tck, tms, tdi, tdo, ahbmi, ahbmo(0),
               open, open, open, open, open, open, open, '0');
  end generate;

  -----------------------------------------------------------------------------
  -- ETH0 and EDCL Master
  -----------------------------------------------------------------------------

  eth0_gen : if CFG_GRETH = 1 generate
    ahbmo(CFG_AHB_JTAG) <= eth0_ahbmo;
    eth0_ahbmi          <= ahbmi;

    noc_apbo(14) <= eth0_apbo;
    eth0_apbi    <= noc_apbi;

    sgmii_gen : if CFG_SGMII = 1 generate
      noc_apbo(15) <= sgmii0_apbo;
      sgmii0_apbi  <= noc_apbi;
    end generate sgmii_gen;

    edcl_gen : if CFG_DSU_ETH = 1 generate
      ahbmo(CFG_AHB_JTAG + 1) <= edcl_ahbmo;
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

  -- TODO: Remove
  eth0_irq <= noc_apbo(14).pirq(12);
  sgmii0_irq <= noc_apbo(15).pirq(11);

  -----------------------------------------------------------------------------
  -- Memory Controller Slave (BOOTROM is implemented as RAM for development)
  -----------------------------------------------------------------------------

-- pragma translate_off
  bootram_model_gen: if SIMULATION = true generate
    ahbram_1 : ahbram_sim
      generic map (
        hindex   => ahbrom_hindex,
        haddr    => ahbrom_haddr,
        hmask    => ahbrom_hmask,
        tech     => 0,
        kbytes   => 100,
        pipe     => 0,
        maccsz   => AHBDW,
        fname    => "prom.srec"
        )
      port map(
        rst     => rst,
        clk     => clk,
        ahbsi   => ahbsi,
        ahbso   => ahbso(ahbrom_hindex)
        );
  end generate bootram_model_gen;
-- pragma translate_on

  bootram_gen: if SIMULATION = false generate
    ahbram_2: ahbram
      generic map (
        hindex   => ahbrom_hindex,
        haddr    => ahbrom_haddr,
        hmask    => ahbrom_hmask,
        tech     => CFG_FABTECH,
        kbytes   => 128,
        pipe     => 0,
        maccsz   => AHBDW)
      port map (
        rst   => rst,
        clk   => clk,
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

  uart_irq <= noc_apbo(1).pirq(CFG_UART1_IRQ);

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

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp                    -- interrupt controller
      generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU_TILE)
      port map (rst, clk, noc_apbi_wirq, noc_apbo(2), irqo, irqi);
  end generate;

  irq3 : if CFG_IRQ3_ENABLE = 0 generate
    x : for i in 0 to CFG_NCPU_TILE-1 generate
      irqi(i).irl <= (others => '0');
    end generate;
    noc_apbo(2) <= apb_none;
  end generate;

  ----------------------------------------------------------------------
  ---  APB 3: Timer ----------------------------------------------------
  ----------------------------------------------------------------------

  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer                    -- timer unit
      generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ,
                   sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM,
                   nbits  => CFG_GPT_TW, wdog => CFG_GPT_WDOGEN*CFG_GPT_WDOG)
      port map (rst, clk, noc_apbi, noc_apbo(3), gpti, gpto);
    gpti.dhalt <= '0'; gpti.extclk <= '0';
  end generate;

  nogpt : if CFG_GPT_ENABLE = 0 generate
    noc_apbo(3) <= apb_none;
  end generate;

  -----------------------------------------------------------------------------
  -- APB 4: ESP Link (Soft reset) ---------------------------------------------
  -----------------------------------------------------------------------------

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

    -- SLV 7: 0xB0100000 - 0xB01FFFFF
    ahbmo2(NAHBMST - 1 downto 1)   <= (others => ahbm_none);
    ahbso2(1 to NAHBSLV - 1) <= (others => ahbs_none);
    ahbram_dp_1 : ahbram_dp
      generic map (
        hindex1 => fb_hindex,
        haddr1  => CFG_SVGA_MEMORY_HADDR,
        hindex2 => 0,
        haddr2  => CFG_SVGA_MEMORY_HADDR,
        hmask   => fb_hmask,
        tech    => CFG_MEMTECH,
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
                   nahbm   => 1, nahbs => 1)
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
    if CFG_LLC_ENABLE /= 0 and hmaster = CFG_AHB_JTAG then
      coherent_dma_selected <= '1';
    end if;

  end process coh_dma_selector;

  cpu_ahbs2noc_1 : cpu_ahbs2noc
    generic map (
      tech             => CFG_FABTECH,
      hindex           => this_remote_ahb_slv_en,
      hconfig          => fixed_ahbso_hconfig,
      local_y          => this_local_y,
      local_x          => this_local_x,
      mem_hindex       => ddr_hindex(0),
      mem_num          => CFG_NMEM_TILE,
      mem_info         => tile_mem_list,
      slv_y            => tile_y(io_tile_id),
      slv_x            => tile_x(io_tile_id),
      retarget_for_dma => 1,
      dma_length       => CFG_DLINE)
    port map (
      rst                        => rst,
      clk                        => clk,
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
      local_y     => this_local_y,
      local_x     => this_local_x,
      apb_slv_en  => this_remote_apb_slv_en,
      apb_slv_cfg => fixed_apbo_pconfig,
      apb_slv_y   => apb_slv_y,
      apb_slv_x   => apb_slv_x)
    port map (
      rst                     => rst,
      clk                     => clk,
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
      local_y     => this_local_y,
      local_x     => this_local_x,
      apb_slv_en  => this_local_apb_en,
      apb_slv_cfg => fixed_apbo_pconfig,
      apb_slv_y   => apb_slv_y,
      apb_slv_x   => apb_slv_x)
    port map (
      rst                     => rst,
      clk                     => clk,
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


  misc_noc2apb_1 : misc_noc2apb
    generic map (
      tech         => CFG_FABTECH,
      local_y      => this_local_y,
      local_x      => this_local_x,
      local_apb_en => this_local_apb_en)
    port map (
      rst              => rst,
      clk              => clk,
      apbi             => noc_apbi,
      apbo             => noc_apbo,
      dvfs_transient   => '0',
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty);

  misc_irq2noc_1 : misc_irq2noc
    generic map (
      tech    => CFG_FABTECH,
      ncpu    => CFG_NCPU_TILE,
      local_y => this_local_y,
      local_x => this_local_x,
      cpu_y   => cpu_y,
      cpu_x   => cpu_x)
    port map (
      rst                => rst,
      clk                => clk,
      irqi               => irqi,
      irqo               => irqo,
      irqi_fifo_overflow => irqi_fifo_overflow,
      irq_ack_rdreq      => irq_ack_rdreq,
      irq_ack_data_out   => irq_ack_data_out,
      irq_ack_empty      => irq_ack_empty,
      irq_wrreq          => irq_wrreq,
      irq_data_in        => irq_data_in,
      irq_full           => irq_full);

  misc_noc2interrupt_1 : misc_noc2interrupt
    generic map (
      tech    => CFG_FABTECH,
      local_y => this_local_y,
      local_x => this_local_x)
    port map (
      rst                => rst,
      clk                => clk,
      noc_pirq           => noc_pirq,
      interrupt_rdreq    => interrupt_rdreq,
      interrupt_data_out => interrupt_data_out,
      interrupt_empty    => interrupt_empty);

  -- Remote uncached slave and non-coherent DMA requests
  -- Requestes may be directed to he frame buffer or the boot ROM
  -- For now, the boot ROM is only present during simulation
  mem_noc2ahbm_1 : mem_noc2ahbm
    generic map (
      tech        => CFG_FABTECH,
      hindex      => CFG_AHB_JTAG + CFG_GRETH + CFG_DSU_ETH,
      local_y     => this_local_y,
      local_x     => this_local_x,
      axitran     => GLOB_CPU_AXI,
      little_end  => GLOB_CPU_AXI,
      cacheline   => 1,
      l2_cache_en => 0)
    port map (
      rst                       => rst,
      clk                       => clk,
      ahbmi                     => ahbmi,
      ahbmo                     => ahbmo(CFG_AHB_JTAG + CFG_GRETH + CFG_DSU_ETH),
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
  mon_dvfs.vf        <= "1000";         -- Run at highest frequency always
  mon_dvfs.transient <= '0';
  mon_dvfs.clk       <= clk;
  mon_dvfs.acc_idle  <= '0';
  mon_dvfs.traffic   <= '0';
  mon_dvfs.burst     <= '0';

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
      noc1_out_data             => noc1_output_port,
      noc1_out_void             => noc1_data_void_out,
      noc1_out_stop             => noc1_stop_in,
      noc1_in_data              => noc1_input_port,
      noc1_in_void              => noc1_data_void_in,
      noc1_in_stop              => noc1_stop_out,
      noc2_out_data             => noc2_output_port,
      noc2_out_void             => noc2_data_void_out,
      noc2_out_stop             => noc2_stop_in,
      noc2_in_data              => noc2_input_port,
      noc2_in_void              => noc2_data_void_in,
      noc2_in_stop              => noc1_stop_out,
      noc3_out_data             => noc3_output_port,
      noc3_out_void             => noc3_data_void_out,
      noc3_out_stop             => noc3_stop_in,
      noc3_in_data              => noc3_input_port,
      noc3_in_void              => noc3_data_void_in,
      noc3_in_stop              => noc3_stop_out,
      noc4_out_data             => noc4_output_port,
      noc4_out_void             => noc4_data_void_out,
      noc4_out_stop             => noc4_stop_in,
      noc4_in_data              => noc4_input_port,
      noc4_in_void              => noc4_data_void_in,
      noc4_in_stop              => noc4_stop_out,
      noc5_out_data             => noc5_output_port,
      noc5_out_void             => noc5_data_void_out,
      noc5_out_stop             => noc5_stop_in,
      noc5_in_data              => noc5_input_port,
      noc5_in_void              => noc5_data_void_in,
      noc5_in_stop              => noc5_stop_out,
      noc6_out_data             => noc6_output_port,
      noc6_out_void             => noc6_data_void_out,
      noc6_out_stop             => noc6_stop_in,
      noc6_in_data              => noc6_input_port,
      noc6_in_void              => noc6_data_void_in,
      noc6_in_stop              => noc6_stop_out);

end;

