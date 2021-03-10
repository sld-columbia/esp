-- new top for accelerator
library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.monitor_pkg.all;
use work.nocpackage.all;
use work.allcaches.all;
use work.cachepackage.all;
use work.tile.all;
use work.genacc.all;
use work.esp_acc_regmap.all;


entity acc_dpr_top is 

  generic (
    hls_conf       : hlscfg_t;
    this_device    : devid_t  := 0;  -- new parameter
    tech           : integer;
    mem_num        : integer;
    cacheable_mem_num : integer;
    mem_info       : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE);
    io_y           : local_yx;
    io_x           : local_yx;
    pindex         : integer := 0;
    irq_type       : integer := 0;
    scatter_gather : integer := 1;
    sets           : integer := 256;
    ways           : integer := 8;
    cache_tile_id  : cache_attribute_array;
    cache_y        : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
    cache_x        : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
    has_l2         : integer := 1;
    has_dvfs       : integer := 1;
    has_pll        : integer;
    extra_clk_buf  : integer);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_ulogic;
    refclk    : in  std_ulogic;
    pllbypass : in  std_ulogic;
    pllclk    : out std_ulogic;
    local_y   : in  local_yx;
    local_x   : in  local_yx;
    paddr     : in  integer range 0 to 4095;
    pmask     : in  integer range 0 to 4095;
    paddr_ext : in  integer range 0 to 4095;
    pmask_ext : in  integer range 0 to 4095;
    pirq      : in  integer range 0 to NAHBIRQ - 1;
    -- APB
    apbi      : in apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    pready    : out std_ulogic;

    -- NoC plane coherence request
    coherence_req_wrreq        : out std_ulogic;
    coherence_req_data_in      : out noc_flit_type;
    coherence_req_full         : in  std_ulogic;
    -- NoC plane coherence forward
    coherence_fwd_rdreq        : out std_ulogic;
    coherence_fwd_data_out     : in  noc_flit_type;
    coherence_fwd_empty        : in  std_ulogic;
    -- Noc plane coherence response
    coherence_rsp_rcv_rdreq    : out std_ulogic;
    coherence_rsp_rcv_data_out : in  noc_flit_type;
    coherence_rsp_rcv_empty    : in  std_ulogic;
    coherence_rsp_snd_wrreq    : out std_ulogic;
    coherence_rsp_snd_data_in  : out noc_flit_type;
    coherence_rsp_snd_full     : in  std_ulogic;
    -- NoC plane MEM2DEV
    dma_rcv_rdreq     : out std_ulogic;
    dma_rcv_data_out  : in  noc_flit_type;
    dma_rcv_empty     : in  std_ulogic;
    -- NoC plane DEV2MEM
    dma_snd_wrreq     : out std_ulogic;
    dma_snd_data_in   : out noc_flit_type;
    dma_snd_full      : in  std_ulogic;
    -- NoC plane LLC-coherent MEM2DEV
    coherent_dma_rcv_rdreq     : out std_ulogic;
    coherent_dma_rcv_data_out  : in  noc_flit_type;
    coherent_dma_rcv_empty     : in  std_ulogic;
    -- NoC plane LLC-coherent DEV2MEM
    coherent_dma_snd_wrreq     : out std_ulogic;
    coherent_dma_snd_data_in   : out noc_flit_type;
    coherent_dma_snd_full      : in  std_ulogic;
    -- Noc plane miscellaneous (tile -> NoC)
    interrupt_wrreq   : out std_ulogic;
    interrupt_data_in : out misc_noc_flit_type;
    interrupt_full    : in  std_ulogic;
    -- Noc plane miscellaneous (NoC -> tile)
    interrupt_ack_rdreq    : out std_ulogic;
    interrupt_ack_data_out : in  misc_noc_flit_type;
    interrupt_ack_empty    : in  std_ulogic;
    mon_dvfs_in       : in  monitor_dvfs_type;
    dvfs_transient_in    : in std_ulogic
    --Monitor signals
    mon_acc           : out monitor_acc_type;
    mon_cache         : out monitor_cache_type
--    mon_dvfs          : out monitor_dvfs_type;
    );

end;

architecture rtl of acc_dpr_top is

begin

-------------------------------------------------------------------------------
-- ACCELERATOR ----------------------------------------------------------------
-------------------------------------------------------------------------------

  -- <<accelerator-wrappers-gen>>

  -----------------------------------------------------------------------------

end rtl;
