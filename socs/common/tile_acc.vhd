-----------------------------------------------------------------------------
--  Accelerator Tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.acctypes.all;
use work.socmap.all;
use work.grlib_config.all;

entity tile_acc is
  generic (
    fabtech             : integer := virtex7;
    memtech             : integer := virtex7;
    padtech             : integer := virtex7;
    local_y             : local_yx := "000";
    local_x             : local_yx := "011";
    io_y                : local_yx := "001";
    io_x                : local_yx := "010";
    device              : devid_t := SLD_SORT;
    pindex              : integer := 5;
    paddr               : integer := 16#105#;
    pmask               : integer := 16#fff#;
    pirq                : integer := 3;
    scatter_gather      : integer range 0 to 1 := 1;
    local_apb_mask      : std_logic_vector(NAPBSLV-1 downto 0);
    has_dvfs            : integer;
    has_pll             : integer;
    extra_clk_buf       : integer;
    domain              : integer);
  port (
    rst                : in std_ulogic;
    refclk             : in std_ulogic;
    pllbypass          : in std_ulogic;
    pllclk             : out std_ulogic;
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
    vdd_ivr            : in  std_ulogic;
    vref               : out std_ulogic;
    mon_dvfs_in        : in  monitor_dvfs_type;
    --Monitor signals
    mon_acc            : out monitor_acc_type;
    mon_dvfs           : out monitor_dvfs_type
    );

end;

architecture rtl of tile_acc is

  signal clk_feedthru      : std_ulogic;

  signal dma_rcv_rdreq     : std_ulogic;
  signal dma_rcv_data_out  : noc_flit_type;
  signal dma_rcv_empty     : std_ulogic;
  signal dma_snd_wrreq     : std_ulogic;
  signal dma_snd_data_in   : noc_flit_type;
  signal dma_snd_full      : std_ulogic;
  signal interrupt_wrreq   : std_ulogic;
  signal interrupt_data_in : noc_flit_type;
  signal interrupt_full    : std_ulogic;
  signal apb_snd_wrreq     : std_ulogic;
  signal apb_snd_data_in   : noc_flit_type;
  signal apb_snd_full      : std_ulogic;
  signal apb_rcv_rdreq     : std_ulogic;
  signal apb_rcv_data_out  : noc_flit_type;
  signal apb_rcv_empty     : std_ulogic;

begin

  pllclk <= clk_feedthru;


-------------------------------------------------------------------------------
-- ACCELERATOR ----------------------------------------------------------------
-------------------------------------------------------------------------------


  sort_gen: if device = SLD_SORT generate
    sort_1: noc_sort
      generic map (
        tech         => memtech,
        local_y      => local_y,
        local_x      => local_x,
        mem_num      => NMIG+CFG_SVGA_ENABLE,
        mem_info     => tile_mem_list,
        io_y         => io_y,
        io_x         => io_x,
        pindex       => pindex,
        paddr        => paddr,
        pmask        => pmask,
        pirq         => pirq,
        scatter_gather => scatter_gather,
        has_dvfs     => has_dvfs,
        has_pll      => has_pll,
        extra_clk_buf => extra_clk_buf,
        local_apb_en => local_apb_mask)
      port map (
        rst               => rst,
        clk               => clk_feedthru,
        refclk            => refclk,
        pllbypass         => pllbypass,
        pllclk            => clk_feedthru,
        dma_rcv_rdreq     => dma_rcv_rdreq,
        dma_rcv_data_out  => dma_rcv_data_out,
        dma_rcv_empty     => dma_rcv_empty,
        dma_snd_wrreq     => dma_snd_wrreq,
        dma_snd_data_in   => dma_snd_data_in,
        dma_snd_full      => dma_snd_full,
        interrupt_wrreq   => interrupt_wrreq,
        interrupt_data_in => interrupt_data_in,
        interrupt_full    => interrupt_full,
        apb_snd_wrreq     => apb_snd_wrreq,
        apb_snd_data_in   => apb_snd_data_in,
        apb_snd_full      => apb_snd_full,
        apb_rcv_rdreq     => apb_rcv_rdreq,
        apb_rcv_data_out  => apb_rcv_data_out,
        apb_rcv_empty     => apb_rcv_empty,
        vdd_ivr           => vdd_ivr,
        vref              => vref,
        mon_dvfs_in       => mon_dvfs_in,
        -- Monitor signals
        mon_acc           => mon_acc,
        mon_dvfs          => mon_dvfs
        );
  end generate sort_gen;

  fft_gen: if device = SLD_FFT generate
    fft_1: noc_fft
      generic map (
        tech         => memtech,
        local_y      => local_y,
        local_x      => local_x,
        mem_num      => NMIG+CFG_SVGA_ENABLE,
        mem_info     => tile_mem_list,
        io_y         => io_y,
        io_x         => io_x,
        pindex       => pindex,
        paddr        => paddr,
        pmask        => pmask,
        pirq         => pirq,
        scatter_gather => scatter_gather,
        has_dvfs     => has_dvfs,
        has_pll      => has_pll,
        extra_clk_buf => extra_clk_buf,
        local_apb_en => local_apb_mask)
      port map (
        rst               => rst,
        clk               => clk_feedthru,
        refclk            => refclk,
        pllbypass         => pllbypass,
        pllclk            => clk_feedthru,
        dma_rcv_rdreq     => dma_rcv_rdreq,
        dma_rcv_data_out  => dma_rcv_data_out,
        dma_rcv_empty     => dma_rcv_empty,
        dma_snd_wrreq     => dma_snd_wrreq,
        dma_snd_data_in   => dma_snd_data_in,
        dma_snd_full      => dma_snd_full,
        interrupt_wrreq   => interrupt_wrreq,
        interrupt_data_in => interrupt_data_in,
        interrupt_full    => interrupt_full,
        apb_snd_wrreq     => apb_snd_wrreq,
        apb_snd_data_in   => apb_snd_data_in,
        apb_snd_full      => apb_snd_full,
        apb_rcv_rdreq     => apb_rcv_rdreq,
        apb_rcv_data_out  => apb_rcv_data_out,
        apb_rcv_empty     => apb_rcv_empty,
        vdd_ivr           => vdd_ivr,
        vref              => vref,
        mon_dvfs_in       => mon_dvfs_in,
        -- Monitor signals
        mon_acc           => mon_acc,
        mon_dvfs          => mon_dvfs
        );
  end generate fft_gen;

  fft2d_gen: if device = SLD_FFT2D generate
    fft2d_1: noc_fft2d
      generic map (
        tech         => memtech,
        local_y      => local_y,
        local_x      => local_x,
        mem_num      => NMIG+CFG_SVGA_ENABLE,
        mem_info     => tile_mem_list,
        io_y         => io_y,
        io_x         => io_x,
        pindex       => pindex,
        paddr        => paddr,
        pmask        => pmask,
        pirq         => pirq,
        scatter_gather => scatter_gather,
        has_dvfs     => has_dvfs,
        has_pll      => has_pll,
        extra_clk_buf => extra_clk_buf,
        local_apb_en => local_apb_mask)
      port map (
        rst               => rst,
        clk               => clk_feedthru,
        refclk            => refclk,
        pllbypass         => pllbypass,
        pllclk            => clk_feedthru,
        dma_rcv_rdreq     => dma_rcv_rdreq,
        dma_rcv_data_out  => dma_rcv_data_out,
        dma_rcv_empty     => dma_rcv_empty,
        dma_snd_wrreq     => dma_snd_wrreq,
        dma_snd_data_in   => dma_snd_data_in,
        dma_snd_full      => dma_snd_full,
        interrupt_wrreq   => interrupt_wrreq,
        interrupt_data_in => interrupt_data_in,
        interrupt_full    => interrupt_full,
        apb_snd_wrreq     => apb_snd_wrreq,
        apb_snd_data_in   => apb_snd_data_in,
        apb_snd_full      => apb_snd_full,
        apb_rcv_rdreq     => apb_rcv_rdreq,
        apb_rcv_data_out  => apb_rcv_data_out,
        apb_rcv_empty     => apb_rcv_empty,
        vdd_ivr           => vdd_ivr,
        vref              => vref,
        mon_dvfs_in       => mon_dvfs_in,
        -- Monitor signals
        mon_acc           => mon_acc,
        mon_dvfs          => mon_dvfs
        );
  end generate fft2d_gen;

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  acc_tile_q_1: acc_tile_q
    generic map (
      tech => fabtech)
    port map (
      rst               => rst,
      clk               => clk_feedthru,
      dma_rcv_rdreq     => dma_rcv_rdreq,
      dma_rcv_data_out  => dma_rcv_data_out,
      dma_rcv_empty     => dma_rcv_empty,
      dma_snd_wrreq     => dma_snd_wrreq,
      dma_snd_data_in   => dma_snd_data_in,
      dma_snd_full      => dma_snd_full,
      apb_rcv_rdreq     => apb_rcv_rdreq,
      apb_rcv_data_out  => apb_rcv_data_out,
      apb_rcv_empty     => apb_rcv_empty,
      apb_snd_wrreq     => apb_snd_wrreq,
      apb_snd_data_in   => apb_snd_data_in,
      apb_snd_full      => apb_snd_full,
      interrupt_wrreq   => interrupt_wrreq,
      interrupt_data_in => interrupt_data_in,
      interrupt_full    => interrupt_full,
      noc1_out_data     => noc1_output_port,
      noc1_out_void     => noc1_data_void_out,
      noc1_out_stop     => noc1_stop_in,
      noc1_in_data      => noc1_input_port,
      noc1_in_void      => noc1_data_void_in,
      noc1_in_stop      => noc1_stop_out,
      noc2_out_data     => noc2_output_port,
      noc2_out_void     => noc2_data_void_out,
      noc2_out_stop     => noc2_stop_in,
      noc2_in_data      => noc2_input_port,
      noc2_in_void      => noc2_data_void_in,
      noc2_in_stop      => noc1_stop_out,
      noc3_out_data     => noc3_output_port,
      noc3_out_void     => noc3_data_void_out,
      noc3_out_stop     => noc3_stop_in,
      noc3_in_data      => noc3_input_port,
      noc3_in_void      => noc3_data_void_in,
      noc3_in_stop      => noc3_stop_out,
      noc4_out_data     => noc4_output_port,
      noc4_out_void     => noc4_data_void_out,
      noc4_out_stop     => noc4_stop_in,
      noc4_in_data      => noc4_input_port,
      noc4_in_void      => noc4_data_void_in,
      noc4_in_stop      => noc4_stop_out,
      noc5_out_data     => noc5_output_port,
      noc5_out_void     => noc5_data_void_out,
      noc5_out_stop     => noc5_stop_in,
      noc5_in_data      => noc5_input_port,
      noc5_in_void      => noc5_data_void_in,
      noc5_in_stop      => noc5_stop_out,
      noc6_out_data     => noc6_output_port,
      noc6_out_void     => noc6_data_void_out,
      noc6_out_stop     => noc6_stop_in,
      noc6_in_data      => noc6_input_port,
      noc6_in_void      => noc6_data_void_in,
      noc6_in_stop      => noc6_stop_out);

 end;

