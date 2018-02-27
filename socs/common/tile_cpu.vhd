-----------------------------------------------------------------------------
--  CPU tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
--pragma translate_off
use work.memctrl.all;
--pragma translate_on
use work.leon3.all;
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
use work.memoryctrl.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity tile_cpu is
  generic (
    fabtech                 : integer  := CFG_FABTECH;
    memtech                 : integer  := CFG_MEMTECH;
    padtech                 : integer  := CFG_PADTECH;
    disas                   : integer  := CFG_DISAS;   -- Enable disassembly to console
    pclow                   : integer  := CFG_PCLOW;
    cpu_id                  : integer  := 0;
    local_y                 : local_yx := "001";
    local_x                 : local_yx := "001";
    remote_apb_slv_en       : std_logic_vector(NAPBSLV-1 downto 0) := (others => '0');
    has_dvfs                : integer;
    has_pll                 : integer;
    domain                  : integer;
    USE_MIG_INTERFACE_MODEL : boolean  := false
  );
  port (
    rst                : in    std_ulogic;
    refclk             : in std_ulogic;
    pllbypass          : in std_ulogic;
    pllclk             : out std_ulogic;

    --pragma translate_off
    mctrl_ahbsi        : out   ahb_slv_in_type;
    mctrl_ahbso        : in    ahb_slv_out_type;
    mctrl_apbi         : out   apb_slv_in_type;
    mctrl_apbo         : in    apb_slv_out_type;
    --pragma translate_on

    -- DSU LED
    ndsuact            : out std_ulogic;            -- to chip_led(0)
    dsuerr             : out std_ulogic;
    -- IRQ overflow LED
    irqo_fifo_overflow : out std_ulogic;

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
    noc6_stop_in       : out std_ulogic;
    noc6_output_port   : in  noc_flit_type;
    noc6_data_void_out : in  std_ulogic;
    noc6_stop_out      : in  std_ulogic;
    mon_dvfs_in        : in  monitor_dvfs_type;
    mon_dvfs           : out monitor_dvfs_type
  );

end;


architecture rtl of tile_cpu is

-- constants
constant vcc : std_logic_vector(31 downto 0) := (others => '1');
constant gnd : std_logic_vector(31 downto 0) := (others => '0');

signal clk_feedthru    : std_ulogic;

-- Amba bus signals and configuration
signal apbi  : apb_slv_in_type;
signal apbo  : apb_slv_out_vector;
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector;
signal ahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector;
signal noc_apbi  : apb_slv_in_type;
signal noc_apbo  : apb_slv_out_vector;


signal ctrl_apbi  : apb_slv_in_type;
signal ctrl_apbo  : apb_slv_out_vector;
signal ctrl_ahbsi : ahb_slv_in_type;
signal ctrl_ahbso : ahb_slv_out_vector;
signal ctrl_ahbmi : ahb_mst_in_type;
signal ctrl_ahbmo : ahb_mst_out_vector;

signal apb_req, apb_ack, noc_apb_ack, local_apb_ack : std_ulogic;

-- Interrupt controller
signal irqi : l3_irq_in_type;
signal irqo : l3_irq_out_type;

-- Queues
signal coherence_req_wrreq                : std_ulogic;
signal coherence_req_data_in              : noc_flit_type;
signal coherence_req_full                 : std_ulogic;
signal coherence_fwd_inv_rdreq            : std_ulogic;
signal coherence_fwd_inv_data_out         : noc_flit_type;
signal coherence_fwd_inv_empty            : std_ulogic;
signal coherence_fwd_put_ack_rdreq        : std_ulogic;
signal coherence_fwd_put_ack_data_out     : noc_flit_type;
signal coherence_fwd_put_ack_empty        : std_ulogic;
signal coherence_rsp_line_rdreq           : std_ulogic;
signal coherence_rsp_line_data_out        : noc_flit_type;
signal coherence_rsp_line_empty           : std_ulogic;
signal coherence_rsp_inv_ack_rcv_rdreq    : std_ulogic;
signal coherence_rsp_inv_ack_rcv_data_out : noc_flit_type;
signal coherence_rsp_inv_ack_rcv_empty    : std_ulogic;
signal coherence_rsp_inv_ack_snd_wrreq    : std_ulogic;
signal coherence_rsp_inv_ack_snd_data_in  : noc_flit_type;
signal coherence_rsp_inv_ack_snd_full     : std_ulogic;
signal remote_apb_rcv_rdreq               : std_ulogic;
signal remote_apb_rcv_data_out            : noc_flit_type;
signal remote_apb_rcv_empty               : std_ulogic;
signal remote_apb_snd_wrreq               : std_ulogic;
signal remote_apb_snd_data_in             : noc_flit_type;
signal remote_apb_snd_full                : std_ulogic;
signal remote_ahbm_rcv_rdreq              : std_ulogic;
signal remote_ahbm_rcv_data_out           : noc_flit_type;
signal remote_ahbm_rcv_empty              : std_ulogic;
signal remote_ahbm_snd_wrreq              : std_ulogic;
signal remote_ahbm_snd_data_in            : noc_flit_type;
signal remote_ahbm_snd_full               : std_ulogic;
signal remote_irq_rdreq                   : std_ulogic;
signal remote_irq_data_out                : noc_flit_type;
signal remote_irq_empty                   : std_ulogic;
signal remote_irq_ack_wrreq               : std_ulogic;
signal remote_irq_ack_data_in             : noc_flit_type;
signal remote_irq_ack_full                : std_ulogic;

constant nslaves : integer := 2;
constant ahbslv_proxy_hindex : hindex_vector(0 to NAHBSLV-1) := (
  0 => ddr0_hindex,
  1 => fb_hindex,
  others => 0);

-- Debug Support Unit
type l3_debug_in_vector_vector is array (0 to cpu_id) of l3_debug_in_vector(0 to 0);
type l3_debug_out_vector_vector is array (0 to cpu_id) of l3_debug_out_vector(0 to 0);
signal dbgi : l3_debug_in_vector_vector;
signal dbgo : l3_debug_out_vector_vector;
signal dsui : dsu_in_type;
signal dsuo : dsu_out_type;

-- Monitor CPU idle
signal irqo_int : l3_irq_out_type;
signal mon_dvfs_ctrl : monitor_dvfs_type;

begin

pllclk <= clk_feedthru;

  ----------------------------------------------------------------------
  ---  AHB1 CONTROLLER --------------------------------------------------
  ----------------------------------------------------------------------

  assign_bus_ctrl_sig: process (ctrl_ahbmi, ctrl_ahbsi, ctrl_apbi,
                                ahbmo, ahbso, apbo,
                                --pragma translate_off
                                mctrl_ahbso, mctrl_apbo,
                                --pragma translate_on
                                noc_apbo, noc_apb_ack, local_apb_ack)
  begin  -- process assign_bus_ctrl_sig
    ahbmi <= ctrl_ahbmi;
    ahbsi <= ctrl_ahbsi;
    apbi <= ctrl_apbi;
    ctrl_ahbmo <= ahbmo;
    ctrl_ahbso <= ahbso;
    ctrl_apbo <= apbo;

--pragma translate_off
    ctrl_apbo(0) <= mctrl_apbo;
    ctrl_ahbso(0) <= mctrl_ahbso;
    mctrl_apbi <= ctrl_apbi;
    mctrl_ahbsi <= ctrl_ahbsi;
--pragma translate_on

    noc_apbi <= ctrl_apbi;
    for i in 0 to NAPBSLV-1 loop
      if remote_apb_slv_en(i) = '1' then
        ctrl_apbo(i) <= noc_apbo(i);
      else
        ctrl_apbo(i) <= apbo(i);
      end if;
      ctrl_apbo(i).pirq <= (others => '0');
    end loop;  -- i

    if CFG_FIXED_ADDR /= 0 then
      ctrl_ahbmo(cpu_id).hconfig <= fixed_ahbmo_hconfig(cpu_id);
      for i in 0 to NAHBSLV-1 loop
        ctrl_ahbso(i).hconfig <= fixed_ahbso_hconfig(i);
      end loop;  -- i
      if CFG_MIG_DUAL = 1 then
        ctrl_ahbso(ddr0_hindex).hconfig <= cpu_tile_mig7_hconfig;
        ctrl_ahbso(ddr1_hindex).hconfig <= hconfig_none;
        ctrl_ahbso(ddr1_hindex).hindex <= 0;
      end if;
      for i in 0 to NAPBSLV-1 loop
        ctrl_apbo(i).pconfig <= fixed_apbo_pconfig(i);
        ctrl_apbo(i).pindex <= i;
      end loop;  -- i
    end if;
    for i in 0 to cpu_id-1 loop
      ctrl_ahbmo(i).hindex <= i;
    end loop;  -- i
    -- local power controller is always ready.
    if ctrl_apbi.psel(powerctrl_pindex) = '1' then
      apb_ack <= local_apb_ack;
    else
      apb_ack <= noc_apb_ack;
    end if;
  end process assign_bus_ctrl_sig;

  ahb0 : ahbctrl       -- AHB arbiter/multiplexer
  generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
   rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
     nahbm => maxahbm, nahbs => maxahbs)
  port map (rst, clk_feedthru, ctrl_ahbmi, ctrl_ahbmo, ctrl_ahbsi, ctrl_ahbso);

  -------------------------------------------------------------------------------
  -- APB
  -------------------------------------------------------------------------------

  local_apb_ack <= '1';
  apb0 : patient_apbctrl            -- AHB/APB bridge
  generic map (hindex => ahb2apb_hindex, haddr => CFG_APBADDR, hmask => ahb2apb_hmask, nslaves => NAPBSLV,
               remote_apb => remote_apb_slv_en)
  port map (rst, clk_feedthru, ahbsi, ahbso(ahb2apb_hindex), ctrl_apbi, ctrl_apbo, apb_req, apb_ack);


  no_init_apbo: for i in 0 to NAPBSLV - 1 generate
    no_powerctrl: if i /= powerctrl_pindex generate
      apbo(i) <= apb_none;
    end generate no_powerctrl;
  end generate no_init_apbo;


-------------------------------------------------------------------------------
-- Local APB 4: Power management
-------------------------------------------------------------------------------

  dvfs_gen: if has_dvfs /= 0 and has_pll /= 0 generate
    dvfs_top_1: dvfs_top
      generic map (
        tech     => fabtech,
        pindex   => powerctrl_pindex,
        paddr    => powerctrl_pindex,
        pmask    => 16#fff#,
        revision => 0,
        devid    => SLD_POWERCTRL)
      port map (
        rst       => rst,
        clk       => clk_feedthru,
        refclk    => refclk,
        pllbypass => pllbypass,
        pllclk    => clk_feedthru,
        apbi      => apbi,
        apbo      => apbo(powerctrl_pindex),
        acc_idle  => mon_dvfs_in.acc_idle,
        traffic   => mon_dvfs_in.traffic,
        burst     => mon_dvfs_in.burst,
        mon_dvfs  => mon_dvfs_ctrl
      );

    mon_dvfs.clk <= mon_dvfs_ctrl.clk;
    mon_dvfs.vf  <= mon_dvfs_ctrl.vf;
    mon_dvfs.transient <= mon_dvfs_ctrl.transient;
  end generate dvfs_gen;

  dvfs_no_master_or_no_dvfs: if has_dvfs = 0 or has_pll = 0 generate
    clk_feedthru <= refclk;
    apbo(powerctrl_pindex) <= apb_none;
    process (clk_feedthru, rst)
    begin  -- process
      if rst = '0' then                 -- asynchronous reset (active low)
        mon_dvfs.vf <= "1000";
      elsif clk_feedthru'event and clk_feedthru = '1' then  -- rising clock edge
        if has_dvfs /= 0 then
          mon_dvfs.vf <= mon_dvfs_in.vf;
        end if;
      end if;
    end process;
    process (mon_dvfs_in)
    begin  -- process
      if has_dvfs = 1 then
        mon_dvfs.transient <= mon_dvfs_in.transient;
      else
        mon_dvfs.transient <= '0';
      end if;
    end process;
    mon_dvfs.clk <= clk_feedthru;
  end generate dvfs_no_master_or_no_dvfs;

  mon_dvfs.acc_idle <= irqo_int.pwd;
  mon_dvfs.traffic <= '0';
  mon_dvfs.burst <= '0';

  ----------------------------------------------------------------------
  ---  LEON3 processor and DSU -----------------------------------------
  ----------------------------------------------------------------------

    leon3_0 : leon3s     -- LEON3 processor
    generic map (cpu_id, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8,
                 0, CFG_MAC, pclow, CFG_NOTAG, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
                 CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
                 CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
                 CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
                 CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU_TILE-1,
                 CFG_DFIXED, CFG_SCAN, CFG_MMU_PAGE, CFG_BP)
    port map (clk_feedthru, rst, ahbmi, ahbmo(cpu_id), ahbsi, ahbso,
              irqi, irqo_int, dbgi(cpu_id)(0), dbgo(cpu_id)(0));

  irqo <= irqo_int;


  dsugeni_0 : if CFG_DSU = 1 generate
    dsu0 : dsu3         -- LEON3 Debug Support Unit
      generic map (hindex => dsu_hindex, haddr => dsu_haddr, hmask => dsu_hmask,
                   ncpu => 1, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rst, clk_feedthru, ahbmi, ahbsi, ahbso(dsu_hindex), dbgo(cpu_id), dbgi(cpu_id), dsui, dsuo);
    dsui.enable <= '1';
    dsui.break <= '0';
  end generate;

  nodsu : if CFG_DSU = 0 generate
    dsuo.tstop <= '0'; dsuo.active <= '0'; ahbso(dsu_hindex) <= ahbs_none;
  end generate;

  ndsuact <= not dsuo.active;
  dsuerr <= not dbgo(cpu_id)(0).error;


 -----------------------------------------------------------------------
 ---  AHB Masters unconnected  -----------------------------------------
 -----------------------------------------------------------------------
 -- Masters here are CPU on ahbmo(cpu_id) and noc2ahbm proxy on abmo(CFG_NCPU_TILE)
  nam0 : for i in 0 to cpu_id - 1 generate
    ahbmo(i) <= ahbm_none;
  end generate;
  nam1 : for i in (cpu_id + 1) to CFG_NCPU_TILE - 1 generate
    ahbmo(i) <= ahbm_none;
  end generate;
  nam3 : for i in (CFG_NCPU_TILE + 1) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

  -----------------------------------------------------------------------------
  -- AHB Slaves unconnected  --------------------------------------------------
  -----------------------------------------------------------------------------
  no_init_fixed_ahbso : for i in 0 to NAHBSLV-1 generate
    unconnected: if i /= ahb2apb_hindex and i /= dsu_hindex and i /= ddr0_hindex
                   and i /= fb_hindex generate
      ahbso(i) <= ahbs_none;
    end generate unconnected;
  end generate;

  -----------------------------------------------------------------------------
  -- Services
  -----------------------------------------------------------------------------
  apb2noc_1: apb2noc
    generic map (
      tech       => fabtech,
      ncpu       => CFG_NCPU_TILE,
      local_y    => local_y,
      local_x    => local_x,
      apb_slv_en => remote_apb_slv_en,
      apb_slv_y  => apb_slv_y,
      apb_slv_x  => apb_slv_x)
    port map (
      rst                     => rst,
      clk                     => clk_feedthru,
      apbi                    => noc_apbi,
      apbo                    => noc_apbo,
      apb_req                 => apb_req,
      apb_ack                 => noc_apb_ack,
      remote_apb_snd_wrreq    => remote_apb_snd_wrreq,
      remote_apb_snd_data_in  => remote_apb_snd_data_in,
      remote_apb_snd_full     => remote_apb_snd_full,
      remote_apb_rcv_rdreq    => remote_apb_rcv_rdreq,
      remote_apb_rcv_data_out => remote_apb_rcv_data_out,
      remote_apb_rcv_empty    => remote_apb_rcv_empty);

  cpu_irq2noc_1: cpu_irq2noc
    generic map (
      tech    => fabtech,
      cpu_id  => cpu_id,
      local_y => local_y,
      local_x => local_x,
      irq_y   => tile_y(io_tile_id),
      irq_x   => tile_x(io_tile_id))
    port map (
      rst                    => rst,
      clk                    => clk_feedthru,
      irqi                   => irqi,
      irqo                   => irqo,
      irqo_fifo_overflow     => irqo_fifo_overflow,
      remote_irq_rdreq       => remote_irq_rdreq,
      remote_irq_data_out    => remote_irq_data_out,
      remote_irq_empty       => remote_irq_empty,
      remote_irq_ack_wrreq   => remote_irq_ack_wrreq,
      remote_irq_ack_data_in => remote_irq_ack_data_in,
      remote_irq_ack_full    => remote_irq_ack_full);


  frame_buffer: if CFG_SVGA_ENABLE /= 0 generate
    ahbso(fb_hindex).hready <= ahbso(ddr0_hindex).hready;
    ahbso(fb_hindex).hresp <= ahbso(ddr0_hindex).hresp;
    ahbso(fb_hindex).hrdata <= ahbso(ddr0_hindex).hrdata;
    ahbso(fb_hindex).hsplit <= ahbso(ddr0_hindex).hsplit;
    ahbso(fb_hindex).hirq <= ahbso(ddr0_hindex).hirq;
    ahbso(fb_hindex).hconfig <= fb_hconfig;
    ahbso(fb_hindex).hindex <= fb_hindex;
  end generate frame_buffer;
  no_frame_buffer: if CFG_SVGA_ENABLE = 0 generate
    ahbso(fb_hindex) <= ahbs_none;
  end generate no_frame_buffer;

  cpu_ahbs2noc_1: cpu_ahbs2noc
    generic map (
      tech    => fabtech,
      ncpu    => CFG_NCPU_TILE,
      nslaves => nslaves,
      hindex  => ahbslv_proxy_hindex,
      local_y => local_y,
      local_x => local_x,
      mem_num => NMIG + CFG_SVGA_ENABLE,
      mem_info => tile_mem_list,
      destination => 0)
    port map (
      rst                                => rst,
      clk                                => clk_feedthru,
      ahbsi                              => ahbsi,
      ahbso                              => ahbso(ddr0_hindex),
      coherence_req_wrreq                => coherence_req_wrreq,
      coherence_req_data_in              => coherence_req_data_in,
      coherence_req_full                 => coherence_req_full,
      coherence_fwd_inv_rdreq            => coherence_fwd_inv_rdreq,
      coherence_fwd_inv_data_out         => coherence_fwd_inv_data_out,
      coherence_fwd_inv_empty            => coherence_fwd_inv_empty,
      coherence_fwd_put_ack_rdreq        => coherence_fwd_put_ack_rdreq,
      coherence_fwd_put_ack_data_out     => coherence_fwd_put_ack_data_out,
      coherence_fwd_put_ack_empty        => coherence_fwd_put_ack_empty,
      coherence_rsp_line_rdreq           => coherence_rsp_line_rdreq,
      coherence_rsp_line_data_out        => coherence_rsp_line_data_out,
      coherence_rsp_line_empty           => coherence_rsp_line_empty,
      coherence_rsp_inv_ack_rcv_rdreq    => coherence_rsp_inv_ack_rcv_rdreq,
      coherence_rsp_inv_ack_rcv_data_out => coherence_rsp_inv_ack_rcv_data_out,
      coherence_rsp_inv_ack_rcv_empty    => coherence_rsp_inv_ack_rcv_empty,
      coherence_rsp_inv_ack_snd_wrreq    => coherence_rsp_inv_ack_snd_wrreq,
      coherence_rsp_inv_ack_snd_data_in  => coherence_rsp_inv_ack_snd_data_in,
      coherence_rsp_inv_ack_snd_full     => coherence_rsp_inv_ack_snd_full);

  mem_noc2ahbm_1: mem_noc2ahbm
    generic map (
      tech      => fabtech,
      ncpu      => CFG_NCPU_TILE,
      hindex    => CFG_NCPU_TILE,
      local_y   => local_y,
      local_x   => local_x,
      cacheline => CFG_DLINE,
      destination => 1)
    port map (
      rst                           => rst,
      clk                           => clk_feedthru,
      ahbmi                         => ahbmi,
      ahbmo                         => ahbmo(CFG_NCPU_TILE),
      coherence_req_rdreq           => remote_ahbm_rcv_rdreq,
      coherence_req_data_out        => remote_ahbm_rcv_data_out,
      coherence_req_empty           => remote_ahbm_rcv_empty,
      coherence_fwd_inv_wrreq       => open,
      coherence_fwd_inv_data_in     => open,
      coherence_fwd_inv_full        => '0',
      coherence_fwd_put_ack_wrreq   => open,
      coherence_fwd_put_ack_data_in => open,
      coherence_fwd_put_ack_full    => '0',
      coherence_rsp_line_wrreq      => remote_ahbm_snd_wrreq,
      coherence_rsp_line_data_in    => remote_ahbm_snd_data_in,
      coherence_rsp_line_full       => remote_ahbm_snd_full,
      dma_rcv_rdreq                 => open,
      dma_rcv_data_out              => (others => '0'),
      dma_rcv_empty                 => '1',
      dma_snd_wrreq                 => open,
      dma_snd_data_in               => open,
      dma_snd_full                  => '0',
      dma_snd_atleast_4slots        => '1',
      dma_snd_exactly_3slots        => '0');

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  cpu_tile_q_1: cpu_tile_q
    generic map (
      tech => fabtech)
    port map (
      rst                                => rst,
      clk                                => clk_feedthru,
      coherence_req_wrreq                => coherence_req_wrreq,
      coherence_req_data_in              => coherence_req_data_in,
      coherence_req_full                 => coherence_req_full,
      coherence_fwd_inv_rdreq            => coherence_fwd_inv_rdreq,
      coherence_fwd_inv_data_out         => coherence_fwd_inv_data_out,
      coherence_fwd_inv_empty            => coherence_fwd_inv_empty,
      coherence_fwd_put_ack_rdreq        => coherence_fwd_put_ack_rdreq,
      coherence_fwd_put_ack_data_out     => coherence_fwd_put_ack_data_out,
      coherence_fwd_put_ack_empty        => coherence_fwd_put_ack_empty,
      coherence_rsp_line_rdreq           => coherence_rsp_line_rdreq,
      coherence_rsp_line_data_out        => coherence_rsp_line_data_out,
      coherence_rsp_line_empty           => coherence_rsp_line_empty,
      coherence_rsp_inv_ack_rcv_rdreq    => coherence_rsp_inv_ack_rcv_rdreq,
      coherence_rsp_inv_ack_rcv_data_out => coherence_rsp_inv_ack_rcv_data_out,
      coherence_rsp_inv_ack_rcv_empty    => coherence_rsp_inv_ack_rcv_empty,
      coherence_rsp_inv_ack_snd_wrreq    => coherence_rsp_inv_ack_snd_wrreq,
      coherence_rsp_inv_ack_snd_data_in  => coherence_rsp_inv_ack_snd_data_in,
      coherence_rsp_inv_ack_snd_full     => coherence_rsp_inv_ack_snd_full,
      remote_apb_rcv_rdreq               => remote_apb_rcv_rdreq,
      remote_apb_rcv_data_out            => remote_apb_rcv_data_out,
      remote_apb_rcv_empty               => remote_apb_rcv_empty,
      remote_apb_snd_wrreq               => remote_apb_snd_wrreq,
      remote_apb_snd_data_in             => remote_apb_snd_data_in,
      remote_apb_snd_full                => remote_apb_snd_full,
      remote_ahbm_rcv_rdreq              => remote_ahbm_rcv_rdreq,
      remote_ahbm_rcv_data_out           => remote_ahbm_rcv_data_out,
      remote_ahbm_rcv_empty              => remote_ahbm_rcv_empty,
      remote_ahbm_snd_wrreq              => remote_ahbm_snd_wrreq,
      remote_ahbm_snd_data_in            => remote_ahbm_snd_data_in,
      remote_ahbm_snd_full               => remote_ahbm_snd_full,
      remote_irq_rdreq                   => remote_irq_rdreq,
      remote_irq_data_out                => remote_irq_data_out,
      remote_irq_empty                   => remote_irq_empty,
      remote_irq_ack_wrreq               => remote_irq_ack_wrreq,
      remote_irq_ack_data_in             => remote_irq_ack_data_in,
      remote_irq_ack_full                => remote_irq_ack_full,
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
