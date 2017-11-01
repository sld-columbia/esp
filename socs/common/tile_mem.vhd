-----------------------------------------------------------------------------
--  Memory interface tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
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
use work.cachepackage.all;
use work.memoryctrl.all;
use work.coretypes.all;

use work.grlib_config.all;
use work.socmap.all;

entity tile_mem is
  generic (
    fabtech                 : integer := CFG_FABTECH;
    memtech                 : integer := CFG_MEMTECH;
    padtech                 : integer := CFG_PADTECH;
    disas                   : integer := CFG_DISAS;  -- Enable disassembly to console
    dbguart                 : integer := CFG_DUART;  -- Print UART on console
    pclow                   : integer := CFG_PCLOW;
    testahb                 : boolean := false;
    USE_MIG_INTERFACE_MODEL : boolean := false
    );
  port (
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    ddr_ahbsi   : out ahb_slv_in_type;
    ddr_ahbso   : in  ahb_slv_out_type;
    eth0_apbi   : out apb_slv_in_type;
    eth0_apbo   : in  apb_slv_out_type;
    sgmii0_apbi : out apb_slv_in_type;
    sgmii0_apbo : in  apb_slv_out_type;
    eth0_ahbmi  : out ahb_mst_in_type;
    eth0_ahbmo  : in  ahb_mst_out_type;
    --pragma translate_off
    mctrl_ahbsi : out ahb_slv_in_type;
    mctrl_ahbso : in  ahb_slv_out_type;
    mctrl_apbi  : out apb_slv_in_type;
    mctrl_apbo  : in  apb_slv_out_type;
    --pragma translate_on

    -- DSU: To led
    ndsuact : out std_ulogic;           -- to chip_led(0)
    dsuerr  : out std_ulogic;
    --TODO: REMOVE THIS!
    dbgi    : out l3_debug_in_vector(0 to CFG_NCPU_TILE-1);
    dbgo    : in  l3_debug_out_vector(0 to CFG_NCPU_TILE-1);

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
    noc5_input_port    : out noc_flit_type;
    noc5_data_void_in  : out std_ulogic;
    noc5_stop_in       : out std_ulogic;
    noc5_output_port   : in  noc_flit_type;
    noc5_data_void_out : in  std_ulogic;
    noc5_stop_out      : in  std_ulogic;
    noc6_input_port    : out noc_flit_type;
    noc6_data_void_in  : out std_ulogic;
    noc6_stop_in       : out std_ulogic;
    noc6_output_port   : in  noc_flit_type;
    noc6_data_void_out : in  std_ulogic;
    noc6_stop_out      : in  std_ulogic;
    mon_dvfs           : out monitor_dvfs_type;
    debug_led          : out std_ulogic
    );

end;


architecture rtl of tile_mem is

-- constants
  constant vcc : std_logic_vector(31 downto 0) := (others => '1');
  constant gnd : std_logic_vector(31 downto 0) := (others => '0');

-- JTAG (Connected internally through tap and bscan components
  signal tck, tckn, tms, tdi, tdo : std_ulogic;

-- Queues
  signal coherence_req_rdreq        : std_ulogic;
  signal coherence_req_data_out     : noc_flit_type;
  signal coherence_req_empty        : std_ulogic;
  signal coherence_fwd_wrreq        : std_ulogic;
  signal coherence_fwd_data_in      : noc_flit_type;
  signal coherence_fwd_full         : std_ulogic;
  signal coherence_rsp_snd_wrreq    : std_ulogic;
  signal coherence_rsp_snd_data_in  : noc_flit_type;
  signal coherence_rsp_snd_full     : std_ulogic;
  signal coherence_rsp_rcv_rdreq    : std_ulogic;
  signal coherence_rsp_rcv_data_out : noc_flit_type;
  signal coherence_rsp_rcv_empty    : std_ulogic;
  signal dma_rcv_rdreq              : std_ulogic;
  signal dma_rcv_data_out           : noc_flit_type;
  signal dma_rcv_empty              : std_ulogic;
  signal dma_snd_wrreq              : std_ulogic;
  signal dma_snd_data_in            : noc_flit_type;
  signal dma_snd_full               : std_ulogic;
  signal dma_snd_atleast_4slots     : std_ulogic;
  signal dma_snd_exactly_3slots     : std_ulogic;
  signal remote_ahbs_rcv_rdreq      : std_ulogic;
  signal remote_ahbs_rcv_data_out   : noc_flit_type;
  signal remote_ahbs_rcv_empty      : std_ulogic;
  signal remote_ahbs_snd_wrreq      : std_ulogic;
  signal remote_ahbs_snd_data_in    : noc_flit_type;
  signal remote_ahbs_snd_full       : std_ulogic;
  signal remote_apb_rcv_rdreq       : std_ulogic;
  signal remote_apb_rcv_data_out    : noc_flit_type;
  signal remote_apb_rcv_empty       : std_ulogic;
  signal remote_apb_snd_wrreq       : std_ulogic;
  signal remote_apb_snd_data_in     : noc_flit_type;
  signal remote_apb_snd_full        : std_ulogic;
  signal apb_rcv_rdreq              : std_ulogic;
  signal apb_rcv_data_out           : noc_flit_type;
  signal apb_rcv_empty              : std_ulogic;
  signal apb_snd_wrreq              : std_ulogic;
  signal apb_snd_data_in            : noc_flit_type;
  signal apb_snd_full               : std_ulogic;


  signal ddr_rcv_rdreq    : std_ulogic;
  signal ddr_rcv_data_out : noc_flit_type;
  signal ddr_rcv_empty    : std_ulogic;
  signal ddr_rcv_wrreq    : std_ulogic;
  signal ddr_rcv_data_in  : noc_flit_type;
  signal ddr_rcv_full     : std_ulogic;
  signal ddr_snd_rdreq    : std_ulogic;
  signal ddr_snd_data_out : noc_flit_type;
  signal ddr_snd_empty    : std_ulogic;
  signal ddr_snd_wrreq    : std_ulogic;
  signal ddr_snd_data_in  : noc_flit_type;
  signal ddr_snd_full     : std_ulogic;


  signal apbi     : apb_slv_in_type;
  signal apbo     : apb_slv_out_vector := (others => apb_none);
  signal ahbsi    : ahb_slv_in_type;
  signal ahbso    : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi    : ahb_mst_in_type;
  signal ahbmo    : ahb_mst_out_vector := (others => ahbm_none);
  signal ahbsi2   : ahb_slv_in_type;
  signal ahbso2   : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi2   : ahb_mst_in_type;
  signal ahbmo2   : ahb_mst_out_vector := (others => ahbm_none);
  signal noc_apbi : apb_slv_in_type;
  signal noc_apbo : apb_slv_out_vector := (others => apb_none);

  signal ctrl_apbi   : apb_slv_in_type;
  signal ctrl_apbo   : apb_slv_out_vector := (others => apb_none);
  signal ctrl_ahbsi  : ahb_slv_in_type;
  signal ctrl_ahbso  : ahb_slv_out_vector := (others => ahbs_none);
  signal ctrl_ahbmi  : ahb_mst_in_type;
  signal ctrl_ahbmo  : ahb_mst_out_vector := (others => ahbm_none);
  signal ctrl_ahbsi2 : ahb_slv_in_type;
  signal ctrl_ahbso2 : ahb_slv_out_vector := (others => ahbs_none);
  signal ctrl_ahbmi2 : ahb_mst_in_type;
  signal ctrl_ahbmo2 : ahb_mst_out_vector := (others => ahbm_none);
  signal ctrl_apbi2  : apb_slv_in_type;
  signal ctrl_apbo2  : apb_slv_out_vector := (others => apb_none);

  signal apb_req, apb_ack : std_ulogic;

  constant local_y        : local_yx := tile_mem_0.y;
  constant local_x        : local_yx := tile_mem_0.x;
  constant bridge_nslaves : integer  := 4;
  constant ahbslv_bridge_hindex : hindex_vector(0 to NAHBSLV-1) := (
    0      => ddr0_hindex,
    2      => dsu_hindex,
-- pragma translate_off
    3      => mctrl_hindex,
-- pragma translate_on
    others => 0);

-- JTAG has no access to frame-buffer (would require additional proxy...)
  constant proxy_nslaves : integer := CFG_MIG_DUAL;
  constant ahbslv_proxy_hindex : hindex_vector(0 to NAHBSLV-1) := (
    1      => ddr1_hindex,
    others => 0);

  constant local_apb_en : std_logic_vector(NAPBSLV-1 downto 0) := (
    14     => to_std_logic(CFG_GRETH),
    15     => to_std_logic(CFG_SGMII * CFG_GRETH),
    others => '0');

-- Debug Support Unit
  signal dsui : dsu_in_type;
  signal dsuo : dsu_out_type;

  signal ahbmi2_hgrant : std_logic_vector(0 to NAHBMST-1);
  signal ahbmi2_hready : std_ulogic;
  signal ahbmi2_hrdata : std_logic_vector(31 downto 0);
  signal ahbmo2_hbusreq : std_ulogic; 
  signal ahbmo2_htrans : std_logic_vector(1 downto 0);
  signal ahbmo2_haddr : std_logic_vector(31 downto 0);
  signal ahbmo2_hwrite : std_ulogic;
  signal ahbmo2_hsize : std_logic_vector(2 downto 0);
  signal ahbmo2_hprot : std_logic_vector(3 downto 0);
  
-- Attributes for hardware debug with Vivado ILA
  attribute mark_debug : string;
  attribute keep       : string;

  attribute mark_debug of coherence_req_empty        : signal is "true";
  attribute mark_debug of coherence_req_rdreq        : signal is "true";
  attribute mark_debug of coherence_req_data_out     : signal is "true";
  -- attribute mark_debug of coherence_fwd_full         : signal is "true";
  -- attribute mark_debug of coherence_fwd_wrreq        : signal is "true";
  -- attribute mark_debug of coherence_fwd_data_in      : signal is "true";
  attribute mark_debug of coherence_rsp_snd_full     : signal is "true";
  attribute mark_debug of coherence_rsp_snd_wrreq    : signal is "true";
  attribute mark_debug of coherence_rsp_snd_data_in  : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_empty    : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_rdreq    : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_data_out : signal is "true";

  attribute mark_debug of ahbmi2_hgrant : signal is "true";
  attribute mark_debug of ahbmi2_hready : signal is "true";
  attribute mark_debug of ahbmi2_hrdata : signal is "true";

  attribute mark_debug of ahbmo2_hbusreq : signal is "true";
  attribute mark_debug of ahbmo2_htrans : signal is "true";
  attribute mark_debug of ahbmo2_haddr : signal is "true";
  attribute mark_debug of ahbmo2_hwrite : signal is "true";
  attribute mark_debug of ahbmo2_hsize : signal is "true";
  attribute mark_debug of ahbmo2_hprot : signal is "true";
  
begin

  ahbmi2_hgrant <= ahbmi2.hgrant;
  ahbmi2_hready <= ahbmi2.hready; 
  ahbmi2_hrdata <= ahbmi2.hrdata;
  ahbmo2_hbusreq <= ahbmo2(0).hbusreq;
  ahbmo2_htrans <= ahbmo2(0).htrans;
  ahbmo2_haddr <= ahbmo2(0).haddr;
  ahbmo2_hwrite <= ahbmo2(0).hwrite;
  ahbmo2_hsize <= ahbmo2(0).hsize;
  ahbmo2_hprot <= ahbmo2(0).hprot;
  
  -----------------------------------------------------------------------------
  -- JTAG
  -----------------------------------------------------------------------------
  ahbjtaggen0 : if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU)
      port map(rst, clk, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU),
               open, open, open, open, open, open, open, gnd(0));
  end generate;

  -----------------------------------------------------------------------------
  -- ETH0 Master
  -----------------------------------------------------------------------------

  eth0_gen : if CFG_GRETH = 1 generate
    ahbmo(CFG_NCPU+CFG_AHB_JTAG) <= eth0_ahbmo;
    eth0_ahbmi                   <= ahbmi;
  end generate eth0_gen;

  no_ethernet : if CFG_GRETH = 0 generate
    eth0_ahbmi <= ahbm_in_none;
  end generate no_ethernet;

  -----------------------------------------------------------------------------
  -- AMBA1 MST: JTAG (local), ETH0 (local)
  -- AMBA1 SLV: APB (local bridge, remote devices), DSU (remote),
  --            DDR0 (other bus), ETH0 Slave (other bus)
  -----------------------------------------------------------------------------

  assign_bus_ctrl_sig : process (ctrl_ahbmi, ctrl_ahbsi, ctrl_apbi,
                                 ahbmo, ahbso, apbo,
                                 --pragma translate_off
                                 mctrl_apbo, mctrl_ahbso,
                                 --pragma translate_on
                                 noc_apbo)
  begin  -- process assign_bus_ctrl_sig
    ahbmi      <= ctrl_ahbmi;
    ahbsi      <= ctrl_ahbsi;
    apbi       <= ctrl_apbi;
    ctrl_ahbmo <= ahbmo;
    ctrl_ahbso <= ahbso;

    ctrl_apbo               <= apbo;
    --pragma translate_off
    ctrl_apbo(mctrl_hindex) <= mctrl_apbo;
    mctrl_apbi              <= ctrl_apbi;
    --pragma translate_on

    ctrl_ahbso(dsu_hindex)        <= ahbso(ddr0_hindex);
    ctrl_ahbso(dsu_hindex).hindex <= dsu_hindex;

    if CFG_MIG_DUAL /= 0 then
      ctrl_ahbso(ddr1_hindex)        <= ahbso(dbg_remote_ahb_hindex);
      ctrl_ahbso(ddr1_hindex).hindex <= ddr1_hindex;
    end if;
    if CFG_MIG_DUAL = 0 then
      ctrl_ahbso(ddr1_hindex)        <= ahbs_none;
      ctrl_ahbso(ddr1_hindex).hindex <= 0;
    end if;

    noc_apbi <= ctrl_apbi;
    for i in 0 to NAPBSLV-1 loop
      if remote_apb_slv_en(i) = '1' then
        ctrl_apbo(i) <= noc_apbo(i);
      end if;
      ctrl_apbo(i).pirq <= (others => '0');
    end loop;  -- i

    if CFG_FIXED_ADDR /= 0 then
      for i in 0 to NAHBMST-1 loop
        ctrl_ahbmo(i).hconfig <= fixed_ahbmo_hconfig(i);
        if ahb_mst_en(i) = '1' then
          ctrl_ahbmo(i).hindex <= i;
        end if;
      end loop;  -- i
      for i in 0 to NAHBSLV-1 loop
        if i /= fb_hindex then
          ctrl_ahbso(i).hconfig <= fixed_ahbso_hconfig(i);
        end if;
        if i = fb_hindex then
          ctrl_ahbso(i).hconfig <= hconfig_none;
        end if;
      end loop;  -- i
      --pragma translate_off
      ctrl_ahbso(ddr0_hindex).hconfig  <= ahbram_sim0_hconfig;
      ctrl_ahbso(ddr1_hindex).hconfig  <= ahbram_sim1_hconfig;
      ctrl_ahbso(mctrl_hindex).hconfig <= mctrl_hconfig;
      --pragma translate_on
      for i in 0 to NAPBSLV-1 loop
        ctrl_apbo(i).pconfig <= fixed_apbo_pconfig(i);
        ctrl_apbo(i).pindex  <= i;
      end loop;  -- i
    end if;
  end process assign_bus_ctrl_sig;

  ahb1 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => maxahbm, nahbs => maxahbs)
    port map (rst, clk, ctrl_ahbmi, ctrl_ahbmo, ctrl_ahbsi, ctrl_ahbso);

  apb0 : patient_apbctrl                -- AHB/APB bridge
    generic map (hindex     => 1, haddr => CFG_APBADDR, hmask => 16#F00#, nslaves => NAPBSLV,
                 remote_apb => remote_apb_slv_en)
    port map (rst, clk, ahbsi, ahbso(ahb2apb_hindex), ctrl_apbi, ctrl_apbo, apb_req, apb_ack);

  -----------------------------------------------------------------------------
  -- AMBA2 MST: cpu (remote), JTAG (other bus)
  -- AMBA2 SLV: ddr (local)
  -----------------------------------------------------------------------------

  assign_bus_ctrl_sig2 : process (ctrl_ahbmi2, ctrl_ahbsi2,
                                  ahbmo2, ahbso2,
                                  --pragma translate_off
                                  mctrl_ahbso,
                                  --pragma translate_on
                                  ddr_ahbso)
  begin  -- process assign_bus_ctrl_sig
    ahbmi2      <= ctrl_ahbmi2;
    ahbsi2      <= ctrl_ahbsi2;
    ctrl_ahbmo2 <= ahbmo2;
    ctrl_ahbso2 <= ahbso2;

    --pragma translate_off
    ctrl_ahbso2(mctrl_hindex) <= mctrl_ahbso;
    mctrl_ahbsi               <= ctrl_ahbsi2;
    --pragma translate_on

    ctrl_ahbso2(ddr0_hindex) <= ddr_ahbso;
    ddr_ahbsi                <= ctrl_ahbsi2;

    if CFG_FIXED_ADDR /= 0 then
      for i in 0 to NAHBMST-1 loop
        ctrl_ahbmo2(i).hconfig <= fixed_ahbmo_hconfig(i);
        if ahb_mst_en(i) = '1' then
          ctrl_ahbmo2(i).hindex <= i;
        end if;
      end loop;  -- i
      for i in 0 to NAHBSLV-1 loop
        if i /= ddr1_hindex and i /= fb_hindex then
          ctrl_ahbso2(i).hconfig <= fixed_ahbso_hconfig(i);
        end if;
        if i = ddr1_hindex or i = fb_hindex then
          ctrl_ahbso2(i).hconfig <= hconfig_none;
        end if;
      end loop;  -- i
      --pragma translate_off
      ctrl_ahbso2(ddr0_hindex).hconfig   <= ahbram_sim0_hconfig;
      ctrl_ahbso2(mctrl_hindex).hconfig  <= mctrl_hconfig;
      --pragma translate_on
      ctrl_ahbso2(ahb2apb_hindex).hindex <= ahb2apb_hindex;
    end if;
  end process assign_bus_ctrl_sig2;

  ahb2 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => maxahbm, nahbs => maxahbs)
    port map (rst, clk, ctrl_ahbmi2, ctrl_ahbmo2, ctrl_ahbsi2, ctrl_ahbso2);

  -----------------------------------------------------------------------------
  -- DSU
  -----------------------------------------------------------------------------
  dsugeni_0 : if CFG_DSU = 1 generate
    dsu0 : dsu3                         -- LEON3 Debug Support Unit
      generic map (hindex => dsu_hindex, haddr => dsu_haddr, hmask => dsu_hmask,
                   ncpu   => CFG_NCPU_TILE, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rst, clk, ahbmi, ahbsi2, ahbso2(dsu_hindex), dbgo, dbgi, dsui, dsuo);
    dsui.enable <= '1';
    dsui.break  <= '0';
  end generate;

  nodsu : if CFG_DSU = 0 generate
    dsuo.tstop <= '0'; dsuo.active <= '0'; ahbso(dsu_hindex) <= ahbs_none;
  end generate;

  ndsuact <= not dsuo.active;
  dsuerr  <= not dbgo(0).error;

  -----------------------------------------------------------------------
  ---  Drive unused bus elements  ---------------------------------------
  -----------------------------------------------------------------------

  nam1 : for i in (sldidx) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

  nam2 : for i in 2 to NAHBMST-1 generate
    ahbmo2(i) <= ahbm_none;
  end generate;

  -----------------------------------------------------------------------------
  -- AMBA1 proxies
  -----------------------------------------------------------------------------
  -- TO APB devices
  apb2noc_1 : apb2noc
    generic map (
      tech       => fabtech,
      ncpu       => CFG_NCPU,
      local_y    => local_y,
      local_x    => local_x,
      apb_slv_en => remote_apb_slv_en,
      apb_slv_y  => apb_slv_y,
      apb_slv_x  => apb_slv_x)
    port map (
      rst                     => rst,
      clk                     => clk,
      apbi                    => noc_apbi,
      apbo                    => noc_apbo,
      apb_req                 => apb_req,
      apb_ack                 => apb_ack,
      remote_apb_snd_wrreq    => remote_apb_snd_wrreq,
      remote_apb_snd_data_in  => remote_apb_snd_data_in,
      remote_apb_snd_full     => remote_apb_snd_full,
      remote_apb_rcv_rdreq    => remote_apb_rcv_rdreq,
      remote_apb_rcv_data_out => remote_apb_rcv_data_out,
      remote_apb_rcv_empty    => remote_apb_rcv_empty);

  -- TO DSU
  cpu_ahbs2noc_1 : cpu_ahbs2noc
    generic map (
      tech        => fabtech,
      ncpu        => CFG_NCPU,
      nslaves     => proxy_nslaves,
      hindex      => ahbslv_proxy_hindex,
      local_y     => local_y,
      local_x     => local_x,
      mem_num     => NMIG,
      mem_info    => jtag_target_list,
      destination => 1)
    port map (
      rst                        => rst,
      clk                        => clk,
      ahbsi                      => ahbsi,
      ahbso                      => ahbso(dbg_remote_ahb_hindex),
      coherence_req_wrreq        => remote_ahbs_snd_wrreq,
      coherence_req_data_in      => remote_ahbs_snd_data_in,
      coherence_req_full         => remote_ahbs_snd_full,
      coherence_fwd_rdreq        => open,
      coherence_fwd_data_out     => (others => '0'),
      coherence_fwd_empty        => '1',
      coherence_rsp_rcv_rdreq    => remote_ahbs_rcv_rdreq,
      coherence_rsp_rcv_data_out => remote_ahbs_rcv_data_out,
      coherence_rsp_rcv_empty    => remote_ahbs_rcv_empty);

  -- TO DDR on AMBA2
  cpu_ahbs2noc_2 : cpu_ahbs2noc
    generic map (
      tech        => fabtech,
      ncpu        => CFG_NCPU,
      nslaves     => bridge_nslaves,
      hindex      => ahbslv_bridge_hindex,
      local_y     => local_y,
      local_x     => local_x,
      mem_num     => 1,                 -- bridge to local ddr controller bus
      mem_info    => tile_mem_list,
      destination => 0)
    port map (
      rst                        => rst,
      clk                        => clk,
      ahbsi                      => ahbsi,
      ahbso                      => ahbso(ddr0_hindex),
      coherence_req_wrreq        => ddr_snd_wrreq,
      coherence_req_data_in      => ddr_snd_data_in,
      coherence_req_full         => ddr_snd_full,
      coherence_fwd_rdreq        => open,
      coherence_fwd_data_out     => (others => '0'),
      coherence_fwd_empty        => '1',
      coherence_rsp_rcv_rdreq    => ddr_rcv_rdreq,
      coherence_rsp_rcv_data_out => ddr_rcv_data_out,
      coherence_rsp_rcv_empty    => ddr_rcv_empty);

  -----------------------------------------------------------------------------
  -- AMBA2 proxies
  -----------------------------------------------------------------------------
  -- FROM CPU
  no_cache_coherence : if CFG_LLC_ENABLE = 0 generate
    coherence_rsp_rcv_rdreq <= '0';
    mem_noc2ahbm_1 : mem_noc2ahbm
      generic map (
        tech        => fabtech,
        ncpu        => CFG_NCPU_TILE,   --unused
        hindex      => 0,
        local_y     => local_y,
        local_x     => local_x,
        cacheline   => CFG_DLINE,
        l2_cache_en => CFG_L2_ENABLE,
        destination => 0)
      port map (
        rst                       => rst,
        clk                       => clk,
        ahbmi                     => ahbmi2,
        ahbmo                     => ahbmo2(0),
        coherence_req_rdreq       => coherence_req_rdreq,
        coherence_req_data_out    => coherence_req_data_out,
        coherence_req_empty       => coherence_req_empty,
        coherence_fwd_wrreq       => coherence_fwd_wrreq,
        coherence_fwd_data_in     => coherence_fwd_data_in,
        coherence_fwd_full        => coherence_fwd_full,
        coherence_rsp_snd_wrreq   => coherence_rsp_snd_wrreq,
        coherence_rsp_snd_data_in => coherence_rsp_snd_data_in,
        coherence_rsp_snd_full    => coherence_rsp_snd_full,
        dma_rcv_rdreq             => dma_rcv_rdreq,
        dma_rcv_data_out          => dma_rcv_data_out,
        dma_rcv_empty             => dma_rcv_empty,
        dma_snd_wrreq             => dma_snd_wrreq,
        dma_snd_data_in           => dma_snd_data_in,
        dma_snd_full              => dma_snd_full,
        dma_snd_atleast_4slots    => dma_snd_atleast_4slots,
        dma_snd_exactly_3slots    => dma_snd_exactly_3slots);
  end generate no_cache_coherence;

  with_cache_coherence : if CFG_LLC_ENABLE /= 0 generate

    dma_rcv_rdreq <= '0';
    dma_snd_wrreq <= '0';

    llc_wrapper_1 : llc_wrapper
      generic map (
        tech        => fabtech,
        ncpu        => CFG_NCPU_TILE,
        noc_xlen    => CFG_XLEN,
        hindex      => 0,
        local_y     => local_y,
        local_x     => local_x,
        cacheline   => CFG_DLINE,
        l2_cache_en => CFG_L2_ENABLE,
        cpu_tile_id => cpu_tile_id,
        tile_cpu_id => tile_cpu_id,
        destination => 0)

      port map (
        rst   => rst,
        clk   => clk,
        ahbmi => ahbmi2,
        ahbmo => ahbmo2(0),

        -- NoC1->tile
        coherence_req_rdreq        => coherence_req_rdreq,
        coherence_req_data_out     => coherence_req_data_out,
        coherence_req_empty        => coherence_req_empty,
        -- tile->NoC2
        coherence_fwd_wrreq        => coherence_fwd_wrreq,
        coherence_fwd_data_in      => coherence_fwd_data_in,
        coherence_fwd_full         => coherence_fwd_full,
        -- tile->NoC3
        coherence_rsp_snd_wrreq    => coherence_rsp_snd_wrreq,
        coherence_rsp_snd_data_in  => coherence_rsp_snd_data_in,
        coherence_rsp_snd_full     => coherence_rsp_snd_full,
        -- NoC3->tile
        coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,
        coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
        coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,

        debug_led                  => debug_led
        );
  end generate with_cache_coherence;

  -- FROM JTAG on AMBA1
  mem_noc2ahbm_2 : mem_noc2ahbm
    generic map (
      tech        => fabtech,
      ncpu        => CFG_NCPU,
      hindex      => CFG_NCPU,
      local_y     => local_y,
      local_x     => local_x,
      l2_cache_en => 0,
      cacheline   => CFG_DLINE,
      destination => 0)
    port map (
      rst                       => rst,
      clk                       => clk,
      ahbmi                     => ahbmi2,
      ahbmo                     => ahbmo2(1),
      coherence_req_rdreq       => ddr_snd_rdreq,
      coherence_req_data_out    => ddr_snd_data_out,
      coherence_req_empty       => ddr_snd_empty,
      coherence_fwd_wrreq       => open,
      coherence_fwd_data_in     => open,
      coherence_fwd_full        => '0',
      coherence_rsp_snd_wrreq   => ddr_rcv_wrreq,
      coherence_rsp_snd_data_in => ddr_rcv_data_in,
      coherence_rsp_snd_full    => ddr_rcv_full,
      dma_rcv_rdreq             => open,
      dma_rcv_data_out          => (others => '0'),
      dma_rcv_empty             => '1',
      dma_snd_wrreq             => open,
      dma_snd_data_in           => open,
      dma_snd_full              => '0',
      dma_snd_atleast_4slots    => '1',
      dma_snd_exactly_3slots    => '0');


  misc_noc2apb_1 : misc_noc2apb
    generic map (
      tech         => fabtech,
      local_y      => local_y,
      local_x      => local_x,
      local_apb_en => local_apb_en)
    port map (
      rst              => rst,
      clk              => clk,
      apbi             => ctrl_apbi2,
      apbo             => ctrl_apbo2,
      dvfs_transient   => '0',
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty);

  apb_ethernet_gen : if CFG_GRETH /= 0 generate
    ctrl_apbo2(14) <= eth0_apbo;
    eth0_apbi      <= ctrl_apbi2;
  end generate apb_ethernet_gen;

  no_apb_ethernet_gen : if CFG_GRETH = 0 generate
    eth0_apbi <= apb_slv_in_none;
  end generate no_apb_ethernet_gen;

  with_sgmii_gen : if (CFG_GRETH * CFG_SGMII) /= 0 generate
    ctrl_apbo2(15) <= sgmii0_apbo;
    sgmii0_apbi    <= ctrl_apbi2;
  end generate with_sgmii_gen;

  no_sgmii_gen : if (CFG_SGMII * CFG_SGMII) = 0 generate
    sgmii0_apbi <= apb_slv_in_none;
  end generate no_sgmii_gen;


  -- DVFS monitor
  mon_dvfs.vf        <= "1000";         --run at highest frequency always
  mon_dvfs.transient <= '0';
  mon_dvfs.clk       <= clk;
  mon_dvfs.acc_idle  <= '0';
  mon_dvfs.traffic   <= '0';
  mon_dvfs.burst     <= '0';

  ------------------------------------------------------------------------------
  -- Queues
  ------------------------------------------------------------------------------

  -- Bridge between AMBA1 and AMBA2
  fifo_TX : fifo
    generic map (
      depth => 6,
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => rst,
      rdreq    => ddr_snd_rdreq,
      wrreq    => ddr_snd_wrreq,
      data_in  => ddr_snd_data_in,
      empty    => ddr_snd_empty,
      full     => ddr_snd_full,
      data_out => ddr_snd_data_out);
  fifo_RX : fifo
    generic map (
      depth => 6,
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => rst,
      rdreq    => ddr_rcv_rdreq,
      wrreq    => ddr_rcv_wrreq,
      data_in  => ddr_rcv_data_in,
      empty    => ddr_rcv_empty,
      full     => ddr_rcv_full,
      data_out => ddr_rcv_data_out);


  --TODO: directory

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------


  mem_tile_q_1 : mem_tile_q
    generic map (
      tech => fabtech)
    port map (
      rst                        => rst,
      clk                        => clk,
      coherence_req_rdreq        => coherence_req_rdreq,
      coherence_req_data_out     => coherence_req_data_out,
      coherence_req_empty        => coherence_req_empty,
      coherence_fwd_wrreq        => coherence_fwd_wrreq,
      coherence_fwd_data_in      => coherence_fwd_data_in,
      coherence_fwd_full         => coherence_fwd_full,
      coherence_rsp_snd_wrreq    => coherence_rsp_snd_wrreq,
      coherence_rsp_snd_data_in  => coherence_rsp_snd_data_in,
      coherence_rsp_snd_full     => coherence_rsp_snd_full,
      coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,
      coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
      coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,
      dma_rcv_rdreq              => dma_rcv_rdreq,
      dma_rcv_data_out           => dma_rcv_data_out,
      dma_rcv_empty              => dma_rcv_empty,
      dma_snd_wrreq              => dma_snd_wrreq,
      dma_snd_data_in            => dma_snd_data_in,
      dma_snd_full               => dma_snd_full,
      dma_snd_atleast_4slots     => dma_snd_atleast_4slots,
      dma_snd_exactly_3slots     => dma_snd_exactly_3slots,
      remote_ahbs_rcv_rdreq      => remote_ahbs_rcv_rdreq,
      remote_ahbs_rcv_data_out   => remote_ahbs_rcv_data_out,
      remote_ahbs_rcv_empty      => remote_ahbs_rcv_empty,
      remote_ahbs_snd_wrreq      => remote_ahbs_snd_wrreq,
      remote_ahbs_snd_data_in    => remote_ahbs_snd_data_in,
      remote_ahbs_snd_full       => remote_ahbs_snd_full,
      remote_apb_rcv_rdreq       => remote_apb_rcv_rdreq,
      remote_apb_rcv_data_out    => remote_apb_rcv_data_out,
      remote_apb_rcv_empty       => remote_apb_rcv_empty,
      remote_apb_snd_wrreq       => remote_apb_snd_wrreq,
      remote_apb_snd_data_in     => remote_apb_snd_data_in,
      remote_apb_snd_full        => remote_apb_snd_full,
      apb_rcv_rdreq              => apb_rcv_rdreq,
      apb_rcv_data_out           => apb_rcv_data_out,
      apb_rcv_empty              => apb_rcv_empty,
      apb_snd_wrreq              => apb_snd_wrreq,
      apb_snd_data_in            => apb_snd_data_in,
      apb_snd_full               => apb_snd_full,
      noc1_out_data              => noc1_output_port,
      noc1_out_void              => noc1_data_void_out,
      noc1_out_stop              => noc1_stop_in,
      noc1_in_data               => noc1_input_port,
      noc1_in_void               => noc1_data_void_in,
      noc1_in_stop               => noc1_stop_out,
      noc2_out_data              => noc2_output_port,
      noc2_out_void              => noc2_data_void_out,
      noc2_out_stop              => noc2_stop_in,
      noc2_in_data               => noc2_input_port,
      noc2_in_void               => noc2_data_void_in,
      noc2_in_stop               => noc1_stop_out,
      noc3_out_data              => noc3_output_port,
      noc3_out_void              => noc3_data_void_out,
      noc3_out_stop              => noc3_stop_in,
      noc3_in_data               => noc3_input_port,
      noc3_in_void               => noc3_data_void_in,
      noc3_in_stop               => noc3_stop_out,
      noc4_out_data              => noc4_output_port,
      noc4_out_void              => noc4_data_void_out,
      noc4_out_stop              => noc4_stop_in,
      noc4_in_data               => noc4_input_port,
      noc4_in_void               => noc4_data_void_in,
      noc4_in_stop               => noc4_stop_out,
      noc5_out_data              => noc5_output_port,
      noc5_out_void              => noc5_data_void_out,
      noc5_out_stop              => noc5_stop_in,
      noc5_in_data               => noc5_input_port,
      noc5_in_void               => noc5_data_void_in,
      noc5_in_stop               => noc5_stop_out,
      noc6_out_data              => noc6_output_port,
      noc6_out_void              => noc6_data_void_out,
      noc6_out_stop              => noc6_stop_in,
      noc6_in_data               => noc6_input_port,
      noc6_in_void               => noc6_data_void_in,
      noc6_in_stop               => noc6_stop_out);
end;

