-------------------------------------------------------------------------------
-- Entity: l3_wrapper
-- File: l3_wrapper.vhd
-- Author: Davide Giri - SLD @ Columbia University
-- Description: RTL wrapper for a Last Level Cache (LLC or L3) with directory
-- to be included on a memory tile on an Embedded Scalable Platform.
-- Frontend: Network on Chip to L3 cache wrapper.
-- Backend: LLC cache wrapper to Amba 2.0 AHB.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TODO:
-- + add reset management
-- + reason about non cacheable rd/wr, why doesn't the LEON3 send any?
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.socmap_types.all;
use work.nocpackage.all;
use work.cachepackage.all; -- contains l3 cache component


entity l3_wrapper is
  generic (
    tech        : integer                      := virtex7;
    ncpu        : integer                      := 4;
    noc_xlen    : integer                      := 3;
    hindex      : integer range 0 to NAHBSLV-1 := 4;
    local_y     : local_yx;
    local_x     : local_yx;
    cacheline   : integer;
    l2_cache_en : integer                      := 0;
    cpu_tile_id : cpu_info_array;
    tile_cpu_id : tile_cpu_id_array;
    destination : integer                      := 0);  -- 0: mem
                                                       -- 1: DSU
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;

    -- NoC1->tile
    coherence_req_rdreq             : out std_ulogic;
    coherence_req_data_out          : in  noc_flit_type;
    coherence_req_empty             : in  std_ulogic;
    -- tile->NoC2
    coherence_fwd_wrreq             : out std_ulogic;
    coherence_fwd_data_in           : out noc_flit_type;
    coherence_fwd_full              : in  std_ulogic;
    -- tile->NoC3
    coherence_rsp_wrreq    : out std_ulogic;
    coherence_rsp_data_in  : out noc_flit_type;
    coherence_rsp_full     : in  std_ulogic;
    -- NoC3->tile
    coherence_rsp_rdreq    : out std_ulogic;
    coherence_rsp_data_out : in  noc_flit_type;
    coherence_rsp_empty    : in  std_ulogic);
    -- -- NoC4->tile
    -- dma_rcv_rdreq                       : out std_ulogic;
    -- dma_rcv_data_out                    : in  noc_flit_type;
    -- dma_rcv_empty                       : in  std_ulogic;
    -- -- tile->NoC4
    -- dma_snd_wrreq                       : out std_ulogic;
    -- dma_snd_data_in                     : out noc_flit_type;
    -- dma_snd_full                        : in  std_ulogic;
    -- dma_snd_atleast_4slots              : in  std_ulogic;
    -- dma_snd_exactly_3slots              : in  std_ulogic);

end l3_wrapper;

architecture rtl of l3_wrapper is


begin  -- architecture rtl


end architecture rtl;
