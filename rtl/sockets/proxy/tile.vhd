-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.monitor_pkg.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.allcaches.all;

use work.coretypes.all;
use work.esp_acc_regmap.all;

package tile is

  component cpu_tile_q
    generic (
      tech : integer);
    port (
      rst                      : in  std_ulogic;
      clk                      : in  std_ulogic;
      coherence_req_wrreq      : in  std_ulogic;
      coherence_req_data_in    : in  noc_flit_type;
      coherence_req_full       : out std_ulogic;
      coherence_fwd_rdreq      : in  std_ulogic;
      coherence_fwd_data_out   : out noc_flit_type;
      coherence_fwd_empty      : out std_ulogic;
      coherence_rsp_rcv_rdreq      : in  std_ulogic;
      coherence_rsp_rcv_data_out   : out noc_flit_type;
      coherence_rsp_rcv_empty      : out std_ulogic;
      coherence_rsp_snd_wrreq      : in  std_ulogic;
      coherence_rsp_snd_data_in    : in  noc_flit_type;
      coherence_rsp_snd_full       : out std_ulogic;
      coherence_fwd_snd_wrreq      : in  std_ulogic;
      coherence_fwd_snd_data_in    : in  noc_flit_type;
      coherence_fwd_snd_full       : out std_ulogic;
      dma_rcv_rdreq              : in  std_ulogic;
      dma_rcv_data_out           : out noc_flit_type;
      dma_rcv_empty              : out std_ulogic;
      dma_snd_wrreq              : in  std_ulogic;
      dma_snd_data_in            : in  noc_flit_type;
      dma_snd_full               : out std_ulogic;
      remote_ahbs_snd_wrreq      : in std_ulogic;
      remote_ahbs_snd_data_in    : in misc_noc_flit_type;
      remote_ahbs_snd_full       : out std_ulogic;
      remote_ahbs_rcv_rdreq      : in std_ulogic;
      remote_ahbs_rcv_data_out   : out misc_noc_flit_type;
      remote_ahbs_rcv_empty      : out std_ulogic;
      apb_rcv_rdreq            : in  std_ulogic;
      apb_rcv_data_out         : out misc_noc_flit_type;
      apb_rcv_empty            : out std_ulogic;
      apb_snd_wrreq            : in  std_ulogic;
      apb_snd_data_in          : in  misc_noc_flit_type;
      apb_snd_full             : out std_ulogic;
      remote_apb_rcv_rdreq     : in  std_ulogic;
      remote_apb_rcv_data_out  : out misc_noc_flit_type;
      remote_apb_rcv_empty     : out std_ulogic;
      remote_apb_snd_wrreq     : in  std_ulogic;
      remote_apb_snd_data_in   : in  misc_noc_flit_type;
      remote_apb_snd_full      : out std_ulogic;
      remote_irq_rdreq         : in  std_ulogic;
      remote_irq_data_out      : out misc_noc_flit_type;
      remote_irq_empty         : out std_ulogic;
      remote_irq_ack_wrreq     : in  std_ulogic;
      remote_irq_ack_data_in   : in  misc_noc_flit_type;
      remote_irq_ack_full      : out std_ulogic;
      noc1_out_data            : in  noc_flit_type;
      noc1_out_void            : in  std_ulogic;
      noc1_out_stop            : out std_ulogic;
      noc1_in_data             : out noc_flit_type;
      noc1_in_void             : out std_ulogic;
      noc1_in_stop             : in  std_ulogic;
      noc2_out_data            : in  noc_flit_type;
      noc2_out_void            : in  std_ulogic;
      noc2_out_stop            : out std_ulogic;
      noc2_in_data             : out noc_flit_type;
      noc2_in_void             : out std_ulogic;
      noc2_in_stop             : in  std_ulogic;
      noc3_out_data            : in  noc_flit_type;
      noc3_out_void            : in  std_ulogic;
      noc3_out_stop            : out std_ulogic;
      noc3_in_data             : out noc_flit_type;
      noc3_in_void             : out std_ulogic;
      noc3_in_stop             : in  std_ulogic;
      noc4_out_data            : in  noc_flit_type;
      noc4_out_void            : in  std_ulogic;
      noc4_out_stop            : out std_ulogic;
      noc4_in_data             : out noc_flit_type;
      noc4_in_void             : out std_ulogic;
      noc4_in_stop             : in  std_ulogic;
      noc5_out_data            : in  misc_noc_flit_type;
      noc5_out_void            : in  std_ulogic;
      noc5_out_stop            : out std_ulogic;
      noc5_in_data             : out misc_noc_flit_type;
      noc5_in_void             : out std_ulogic;
      noc5_in_stop             : in  std_ulogic;
      noc6_out_data            : in  noc_flit_type;
      noc6_out_void            : in  std_ulogic;
      noc6_out_stop            : out std_ulogic;
      noc6_in_data             : out noc_flit_type;
      noc6_in_void             : out std_ulogic;
      noc6_in_stop             : in  std_ulogic);
  end component;


  component misc_tile_q is
    generic (
      tech : integer);
    port (
      rst                             : in  std_ulogic;
      clk                             : in  std_ulogic;
      ahbs_rcv_rdreq                  : in  std_ulogic;
      ahbs_rcv_data_out               : out misc_noc_flit_type;
      ahbs_rcv_empty                  : out std_ulogic;
      ahbs_snd_wrreq                  : in  std_ulogic;
      ahbs_snd_data_in                : in  misc_noc_flit_type;
      ahbs_snd_full                   : out std_ulogic;
      remote_ahbs_rcv_rdreq           : in  std_ulogic;
      remote_ahbs_rcv_data_out        : out misc_noc_flit_type;
      remote_ahbs_rcv_empty           : out std_ulogic;
      remote_ahbs_snd_wrreq           : in  std_ulogic;
      remote_ahbs_snd_data_in         : in  misc_noc_flit_type;
      remote_ahbs_snd_full            : out std_ulogic;
      dma_rcv_rdreq                   : in  std_ulogic;
      dma_rcv_data_out                : out noc_flit_type;
      dma_rcv_empty                   : out std_ulogic;
      dma_snd_wrreq                   : in  std_ulogic;
      dma_snd_data_in                 : in  noc_flit_type;
      dma_snd_full                    : out std_ulogic;
      dma_snd_atleast_4slots          : out std_ulogic;
      dma_snd_exactly_3slots          : out std_ulogic;
      coherent_dma_rcv_rdreq          : in  std_ulogic;
      coherent_dma_rcv_data_out       : out noc_flit_type;
      coherent_dma_rcv_empty          : out std_ulogic;
      coherent_dma_snd_wrreq          : in  std_ulogic;
      coherent_dma_snd_data_in        : in  noc_flit_type;
      coherent_dma_snd_full           : out std_ulogic;
      prc_dma_rcv_rdreq               : in  std_ulogic;
      prc_dma_rcv_data_out            : out noc_flit_type;
      prc_dma_rcv_empty               : out std_ulogic;
      prc_dma_snd_wrreq               : in  std_ulogic;
      prc_dma_snd_data_in             : in  noc_flit_type;
      prc_dma_snd_full                : out std_ulogic;
      apb_rcv_rdreq                   : in  std_ulogic;
      apb_rcv_data_out                : out misc_noc_flit_type;
      apb_rcv_empty                   : out std_ulogic;
      apb_snd_wrreq                   : in  std_ulogic;
      apb_snd_data_in                 : in  misc_noc_flit_type;
      apb_snd_full                    : out std_ulogic;
      remote_apb_rcv_rdreq            : in  std_ulogic;
      remote_apb_rcv_data_out         : out misc_noc_flit_type;
      remote_apb_rcv_empty            : out std_ulogic;
      remote_apb_snd_wrreq            : in  std_ulogic;
      remote_apb_snd_data_in          : in  misc_noc_flit_type;
      remote_apb_snd_full             : out std_ulogic;
      local_apb_rcv_rdreq             : in std_ulogic;
      local_apb_rcv_data_out          : out misc_noc_flit_type;
      local_apb_rcv_empty             : out std_ulogic;
      local_remote_apb_snd_wrreq      : in  std_ulogic;
      local_remote_apb_snd_data_in    : in  misc_noc_flit_type;
      local_remote_apb_snd_full       : out std_ulogic;
      irq_ack_rdreq                   : in  std_ulogic;
      irq_ack_data_out                : out misc_noc_flit_type;
      irq_ack_empty                   : out std_ulogic;
      irq_wrreq                       : in  std_ulogic;
      irq_data_in                     : in  misc_noc_flit_type;
      irq_full                        : out std_ulogic;
      interrupt_rdreq                 : in  std_ulogic;
      interrupt_data_out              : out misc_noc_flit_type;
      interrupt_empty                 : out std_ulogic;
      interrupt_ack_wrreq             : in  std_ulogic;
      interrupt_ack_data_in           : in  misc_noc_flit_type;
      interrupt_ack_full              : out std_ulogic;
      noc1_out_data                   : in  noc_flit_type;
      noc1_out_void                   : in  std_ulogic;
      noc1_out_stop                   : out std_ulogic;
      noc1_in_data                    : out noc_flit_type;
      noc1_in_void                    : out std_ulogic;
      noc1_in_stop                    : in  std_ulogic;
      noc2_out_data                   : in  noc_flit_type;
      noc2_out_void                   : in  std_ulogic;
      noc2_out_stop                   : out std_ulogic;
      noc2_in_data                    : out noc_flit_type;
      noc2_in_void                    : out std_ulogic;
      noc2_in_stop                    : in  std_ulogic;
      noc3_out_data                   : in  noc_flit_type;
      noc3_out_void                   : in  std_ulogic;
      noc3_out_stop                   : out std_ulogic;
      noc3_in_data                    : out noc_flit_type;
      noc3_in_void                    : out std_ulogic;
      noc3_in_stop                    : in  std_ulogic;
      noc4_out_data                   : in  noc_flit_type;
      noc4_out_void                   : in  std_ulogic;
      noc4_out_stop                   : out std_ulogic;
      noc4_in_data                    : out noc_flit_type;
      noc4_in_void                    : out std_ulogic;
      noc4_in_stop                    : in  std_ulogic;
      noc5_out_data                   : in  misc_noc_flit_type;
      noc5_out_void                   : in  std_ulogic;
      noc5_out_stop                   : out std_ulogic;
      noc5_in_data                    : out misc_noc_flit_type;
      noc5_in_void                    : out std_ulogic;
      noc5_in_stop                    : in  std_ulogic;
      noc6_out_data                   : in  noc_flit_type;
      noc6_out_void                   : in  std_ulogic;
      noc6_out_stop                   : out std_ulogic;
      noc6_in_data                    : out noc_flit_type;
      noc6_in_void                    : out std_ulogic;
      noc6_in_stop                    : in  std_ulogic);
  end component misc_tile_q;

  component mem_tile_q
    generic (
      tech : integer);
    port (
      rst                       : in  std_ulogic;
      clk                       : in  std_ulogic;
      coherence_req_rdreq       : in  std_ulogic;
      coherence_req_data_out    : out noc_flit_type;
      coherence_req_empty       : out std_ulogic;
      coherence_fwd_wrreq       : in  std_ulogic;
      coherence_fwd_data_in     : in  noc_flit_type;
      coherence_fwd_full        : out std_ulogic;
      coherence_rsp_snd_wrreq      : in  std_ulogic;
      coherence_rsp_snd_data_in    : in  noc_flit_type;
      coherence_rsp_snd_full       : out std_ulogic;
      coherence_rsp_rcv_rdreq      : in  std_ulogic;
      coherence_rsp_rcv_data_out   : out noc_flit_type;
      coherence_rsp_rcv_empty      : out std_ulogic;
      coherent_dma_snd_wrreq    : in  std_ulogic;
      coherent_dma_snd_data_in  : in  noc_flit_type;
      coherent_dma_snd_full     : out std_ulogic;
      coherent_dma_snd_atleast_4slots : out std_ulogic;
      coherent_dma_snd_exactly_3slots : out std_ulogic;
      dma_rcv_rdreq            : in  std_ulogic;
      dma_rcv_data_out         : out noc_flit_type;
      dma_rcv_empty            : out std_ulogic;
      coherent_dma_rcv_rdreq    : in  std_ulogic;
      coherent_dma_rcv_data_out : out noc_flit_type;
      coherent_dma_rcv_empty    : out std_ulogic;
      dma_snd_wrreq            : in  std_ulogic;
      dma_snd_data_in          : in  noc_flit_type;
      dma_snd_full             : out std_ulogic;
      dma_snd_atleast_4slots   : out std_ulogic;
      dma_snd_exactly_3slots   : out std_ulogic;
      remote_ahbs_rcv_rdreq    : in  std_ulogic;
      remote_ahbs_rcv_data_out : out misc_noc_flit_type;
      remote_ahbs_rcv_empty    : out std_ulogic;
      remote_ahbs_snd_wrreq    : in  std_ulogic;
      remote_ahbs_snd_data_in  : in  misc_noc_flit_type;
      remote_ahbs_snd_full     : out std_ulogic;
      apb_rcv_rdreq            : in  std_ulogic;
      apb_rcv_data_out         : out misc_noc_flit_type;
      apb_rcv_empty            : out std_ulogic;
      apb_snd_wrreq            : in  std_ulogic;
      apb_snd_data_in          : in  misc_noc_flit_type;
      apb_snd_full             : out std_ulogic;
      noc1_out_data            : in  noc_flit_type;
      noc1_out_void            : in  std_ulogic;
      noc1_out_stop            : out std_ulogic;
      noc1_in_data             : out noc_flit_type;
      noc1_in_void             : out std_ulogic;
      noc1_in_stop             : in  std_ulogic;
      noc2_out_data            : in  noc_flit_type;
      noc2_out_void            : in  std_ulogic;
      noc2_out_stop            : out std_ulogic;
      noc2_in_data             : out noc_flit_type;
      noc2_in_void             : out std_ulogic;
      noc2_in_stop             : in  std_ulogic;
      noc3_out_data            : in  noc_flit_type;
      noc3_out_void            : in  std_ulogic;
      noc3_out_stop            : out std_ulogic;
      noc3_in_data             : out noc_flit_type;
      noc3_in_void             : out std_ulogic;
      noc3_in_stop             : in  std_ulogic;
      noc4_out_data            : in  noc_flit_type;
      noc4_out_void            : in  std_ulogic;
      noc4_out_stop            : out std_ulogic;
      noc4_in_data             : out noc_flit_type;
      noc4_in_void             : out std_ulogic;
      noc4_in_stop             : in  std_ulogic;
      noc5_out_data            : in  misc_noc_flit_type;
      noc5_out_void            : in  std_ulogic;
      noc5_out_stop            : out std_ulogic;
      noc5_in_data             : out misc_noc_flit_type;
      noc5_in_void             : out std_ulogic;
      noc5_in_stop             : in  std_ulogic;
      noc6_out_data            : in  noc_flit_type;
      noc6_out_void            : in  std_ulogic;
      noc6_out_stop            : out std_ulogic;
      noc6_in_data             : out noc_flit_type;
      noc6_in_void             : out std_ulogic;
      noc6_in_stop             : in  std_ulogic);
  end component;

  component slm_tile_q
    generic (
      tech : integer);
    port (
      rst                             : in  std_ulogic;
      clk                             : in  std_ulogic;
      coherent_dma_snd_wrreq          : in  std_ulogic;
      coherent_dma_snd_data_in        : in  noc_flit_type;
      coherent_dma_snd_full           : out std_ulogic;
      coherent_dma_snd_atleast_4slots : out std_ulogic;
      coherent_dma_snd_exactly_3slots : out std_ulogic;
      dma_rcv_rdreq                   : in  std_ulogic;
      dma_rcv_data_out                : out noc_flit_type;
      dma_rcv_empty                   : out std_ulogic;
      cpu_dma_rcv_rdreq               : in  std_ulogic;
      cpu_dma_rcv_data_out            : out noc_flit_type;
      cpu_dma_rcv_empty               : out std_ulogic;
      coherent_dma_rcv_rdreq          : in  std_ulogic;
      coherent_dma_rcv_data_out       : out noc_flit_type;
      coherent_dma_rcv_empty          : out std_ulogic;
      dma_snd_wrreq                   : in  std_ulogic;
      dma_snd_data_in                 : in  noc_flit_type;
      dma_snd_full                    : out std_ulogic;
      dma_snd_atleast_4slots          : out std_ulogic;
      dma_snd_exactly_3slots          : out std_ulogic;
      cpu_dma_snd_wrreq               : in  std_ulogic;
      cpu_dma_snd_data_in             : in  noc_flit_type;
      cpu_dma_snd_full                : out std_ulogic;
      remote_ahbs_rcv_rdreq           : in  std_ulogic;
      remote_ahbs_rcv_data_out        : out misc_noc_flit_type;
      remote_ahbs_rcv_empty           : out std_ulogic;
      remote_ahbs_snd_wrreq           : in  std_ulogic;
      remote_ahbs_snd_data_in         : in  misc_noc_flit_type;
      remote_ahbs_snd_full            : out std_ulogic;
      apb_rcv_rdreq                   : in  std_ulogic;
      apb_rcv_data_out                : out misc_noc_flit_type;
      apb_rcv_empty                   : out std_ulogic;
      apb_snd_wrreq                   : in  std_ulogic;
      apb_snd_data_in                 : in  misc_noc_flit_type;
      apb_snd_full                    : out std_ulogic;
      noc1_out_data                   : in  noc_flit_type;
      noc1_out_void                   : in  std_ulogic;
      noc1_out_stop                   : out std_ulogic;
      noc1_in_data                    : out noc_flit_type;
      noc1_in_void                    : out std_ulogic;
      noc1_in_stop                    : in  std_ulogic;
      noc2_out_data                   : in  noc_flit_type;
      noc2_out_void                   : in  std_ulogic;
      noc2_out_stop                   : out std_ulogic;
      noc2_in_data                    : out noc_flit_type;
      noc2_in_void                    : out std_ulogic;
      noc2_in_stop                    : in  std_ulogic;
      noc3_out_data                   : in  noc_flit_type;
      noc3_out_void                   : in  std_ulogic;
      noc3_out_stop                   : out std_ulogic;
      noc3_in_data                    : out noc_flit_type;
      noc3_in_void                    : out std_ulogic;
      noc3_in_stop                    : in  std_ulogic;
      noc4_out_data                   : in  noc_flit_type;
      noc4_out_void                   : in  std_ulogic;
      noc4_out_stop                   : out std_ulogic;
      noc4_in_data                    : out noc_flit_type;
      noc4_in_void                    : out std_ulogic;
      noc4_in_stop                    : in  std_ulogic;
      noc5_out_data                   : in  misc_noc_flit_type;
      noc5_out_void                   : in  std_ulogic;
      noc5_out_stop                   : out std_ulogic;
      noc5_in_data                    : out misc_noc_flit_type;
      noc5_in_void                    : out std_ulogic;
      noc5_in_stop                    : in  std_ulogic;
      noc6_out_data                   : in  noc_flit_type;
      noc6_out_void                   : in  std_ulogic;
      noc6_out_stop                   : out std_ulogic;
      noc6_in_data                    : out noc_flit_type;
      noc6_in_void                    : out std_ulogic;
      noc6_in_stop                    : in  std_ulogic);
  end component;


  component acc_tile_q
    generic (
      tech : integer);
    port (
      rst               : in  std_ulogic;
      clk               : in  std_ulogic;
      coherence_req_wrreq        : in  std_ulogic;
      coherence_req_data_in      : in  noc_flit_type;
      coherence_req_full         : out std_ulogic;
      coherence_fwd_rdreq        : in  std_ulogic;
      coherence_fwd_data_out     : out noc_flit_type;
      coherence_fwd_empty        : out std_ulogic;
      coherence_rsp_rcv_rdreq    : in  std_ulogic;
      coherence_rsp_rcv_data_out : out noc_flit_type;
      coherence_rsp_rcv_empty    : out std_ulogic;
      coherence_rsp_snd_wrreq    : in  std_ulogic;
      coherence_rsp_snd_data_in  : in  noc_flit_type;
      coherence_rsp_snd_full     : out std_ulogic;
      coherence_fwd_snd_wrreq    : in  std_ulogic;
      coherence_fwd_snd_data_in  : in  noc_flit_type;
      coherence_fwd_snd_full     : out std_ulogic;
      dma_rcv_rdreq     : in  std_ulogic;
      dma_rcv_data_out  : out noc_flit_type;
      dma_rcv_empty     : out std_ulogic;
      coherent_dma_snd_wrreq     : in  std_ulogic;
      coherent_dma_snd_data_in   : in  noc_flit_type;
      coherent_dma_snd_full      : out std_ulogic;
      dma_snd_wrreq     : in  std_ulogic;
      dma_snd_data_in   : in  noc_flit_type;
      dma_snd_full      : out std_ulogic;
      coherent_dma_rcv_rdreq     : in  std_ulogic;
      coherent_dma_rcv_data_out  : out noc_flit_type;
      coherent_dma_rcv_empty     : out std_ulogic;
      apb_rcv_rdreq     : in  std_ulogic;
      apb_rcv_data_out  : out misc_noc_flit_type;
      apb_rcv_empty     : out std_ulogic;
      apb_snd_wrreq     : in  std_ulogic;
      apb_snd_data_in   : in  misc_noc_flit_type;
      apb_snd_full      : out std_ulogic;
      interrupt_wrreq   : in  std_ulogic;
      interrupt_data_in : in  misc_noc_flit_type;
      interrupt_full    : out std_ulogic;
      interrupt_ack_rdreq    : in  std_ulogic;
      interrupt_ack_data_out : out misc_noc_flit_type;
      interrupt_ack_empty    : out std_ulogic;
      noc1_out_data     : in  noc_flit_type;
      noc1_out_void     : in  std_ulogic;
      noc1_out_stop     : out std_ulogic;
      noc1_in_data      : out noc_flit_type;
      noc1_in_void      : out std_ulogic;
      noc1_in_stop      : in  std_ulogic;
      noc2_out_data     : in  noc_flit_type;
      noc2_out_void     : in  std_ulogic;
      noc2_out_stop     : out std_ulogic;
      noc2_in_data      : out noc_flit_type;
      noc2_in_void      : out std_ulogic;
      noc2_in_stop      : in  std_ulogic;
      noc3_out_data     : in  noc_flit_type;
      noc3_out_void     : in  std_ulogic;
      noc3_out_stop     : out std_ulogic;
      noc3_in_data      : out noc_flit_type;
      noc3_in_void      : out std_ulogic;
      noc3_in_stop      : in  std_ulogic;
      noc4_out_data     : in  noc_flit_type;
      noc4_out_void     : in  std_ulogic;
      noc4_out_stop     : out std_ulogic;
      noc4_in_data      : out noc_flit_type;
      noc4_in_void      : out std_ulogic;
      noc4_in_stop      : in  std_ulogic;
      noc5_out_data     : in  misc_noc_flit_type;
      noc5_out_void     : in  std_ulogic;
      noc5_out_stop     : out std_ulogic;
      noc5_in_data      : out misc_noc_flit_type;
      noc5_in_void      : out std_ulogic;
      noc5_in_stop      : in  std_ulogic;
      noc6_out_data     : in  noc_flit_type;
      noc6_out_void     : in  std_ulogic;
      noc6_out_stop     : out std_ulogic;
      noc6_in_data      : out noc_flit_type;
      noc6_in_void      : out std_ulogic;
      noc6_in_stop      : in  std_ulogic);
  end component;


  component empty_tile_q is
    generic (
      tech : integer);
    port (
      rst              : in  std_ulogic;
      clk              : in  std_ulogic;
      apb_rcv_rdreq    : in  std_ulogic;
      apb_rcv_data_out : out misc_noc_flit_type;
      apb_rcv_empty    : out std_ulogic;
      apb_snd_wrreq    : in  std_ulogic;
      apb_snd_data_in  : in  misc_noc_flit_type;
      apb_snd_full     : out std_ulogic;
      noc1_out_data    : in  noc_flit_type;
      noc1_out_void    : in  std_ulogic;
      noc1_out_stop    : out std_ulogic;
      noc1_in_data     : out noc_flit_type;
      noc1_in_void     : out std_ulogic;
      noc1_in_stop     : in  std_ulogic;
      noc2_out_data    : in  noc_flit_type;
      noc2_out_void    : in  std_ulogic;
      noc2_out_stop    : out std_ulogic;
      noc2_in_data     : out noc_flit_type;
      noc2_in_void     : out std_ulogic;
      noc2_in_stop     : in  std_ulogic;
      noc3_out_data    : in  noc_flit_type;
      noc3_out_void    : in  std_ulogic;
      noc3_out_stop    : out std_ulogic;
      noc3_in_data     : out noc_flit_type;
      noc3_in_void     : out std_ulogic;
      noc3_in_stop     : in  std_ulogic;
      noc4_out_data    : in  noc_flit_type;
      noc4_out_void    : in  std_ulogic;
      noc4_out_stop    : out std_ulogic;
      noc4_in_data     : out noc_flit_type;
      noc4_in_void     : out std_ulogic;
      noc4_in_stop     : in  std_ulogic;
      noc5_out_data    : in  misc_noc_flit_type;
      noc5_out_void    : in  std_ulogic;
      noc5_out_stop    : out std_ulogic;
      noc5_in_data     : out misc_noc_flit_type;
      noc5_in_void     : out std_ulogic;
      noc5_in_stop     : in  std_ulogic;
      noc6_out_data    : in  noc_flit_type;
      noc6_out_void    : in  std_ulogic;
      noc6_out_stop    : out std_ulogic;
      noc6_in_data     : out noc_flit_type;
      noc6_in_void     : out std_ulogic;
      noc6_in_stop     : in  std_ulogic);
  end component empty_tile_q;

  component apb2noc
    generic (
      tech       : integer;
      ncpu       : integer;
      apb_slv_cfg : apb_slv_config_vector;
      apb_slv_en : std_logic_vector(0 to NAPBSLV - 1);
      apb_slv_y  : yx_vec(0 to NAPBSLV - 1);
      apb_slv_x  : yx_vec(0 to NAPBSLV - 1));
    port (
      rst                     : in  std_ulogic;
      clk                     : in  std_ulogic;
      local_y                 : in  local_yx;
      local_x                 : in  local_yx;
      apbi                    : in  apb_slv_in_type;
      apbo                    : out apb_slv_out_vector;
      apb_req                 : in  std_ulogic;
      apb_ack                 : out std_ulogic;
      remote_apb_snd_wrreq    : out std_ulogic;
      remote_apb_snd_data_in  : out misc_noc_flit_type;
      remote_apb_snd_full     : in  std_ulogic;
      remote_apb_rcv_rdreq    : out std_ulogic;
      remote_apb_rcv_data_out : in  misc_noc_flit_type;
      remote_apb_rcv_empty    : in  std_ulogic);
  end component;

  component intack2noc is
    generic (
      tech  : integer;
      irq_y : local_yx;
      irq_x : local_yx);
    port (
      rst                    : in  std_ulogic;
      clk                    : in  std_ulogic;
      cpu_id                 : in  integer;
      local_y                : in  local_yx;
      local_x                : in  local_yx;
      irqi                   : out l3_irq_in_type;
      irqo                   : in  l3_irq_out_type;
      irqo_fifo_overflow     : out std_ulogic;
      remote_irq_rdreq       : out std_ulogic;
      remote_irq_data_out    : in  misc_noc_flit_type;
      remote_irq_empty       : in  std_ulogic;
      remote_irq_ack_wrreq   : out std_ulogic;
      remote_irq_ack_data_in : out misc_noc_flit_type;
      remote_irq_ack_full    : in  std_ulogic);
  end component intack2noc;

  component ahbslv2noc
    generic (
      tech        : integer;
      hindex      : std_logic_vector(0 to NAHBSLV - 1);
      hconfig     : ahb_slv_config_vector;
      mem_hindex  : integer range -1 to NAHBSLV - 1;
      mem_num     : integer;
      mem_info    : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1);
      slv_y       : local_yx;
      slv_x       : local_yx;
      retarget_for_dma : integer range 0 to 1;
      dma_length       : integer);
   port (
      rst                        : in  std_ulogic;
      clk                        : in  std_ulogic;
      local_y                    : in  local_yx;
      local_x                    : in  local_yx;
      ahbsi                      : in  ahb_slv_in_type;
      ahbso                      : out ahb_slv_out_vector;
      dma_selected               : in  std_ulogic;
      coherence_req_wrreq        : out std_ulogic;
      coherence_req_data_in      : out noc_flit_type;
      coherence_req_full         : in  std_ulogic;
      coherence_rsp_rcv_rdreq    : out std_ulogic;
      coherence_rsp_rcv_data_out : in  noc_flit_type;
      coherence_rsp_rcv_empty    : in  std_ulogic;
      remote_ahbs_snd_wrreq      : out std_ulogic;
      remote_ahbs_snd_data_in    : out misc_noc_flit_type;
      remote_ahbs_snd_full       : in  std_ulogic;
      remote_ahbs_rcv_rdreq      : out std_ulogic;
      remote_ahbs_rcv_data_out   : in  misc_noc_flit_type;
      remote_ahbs_rcv_empty      : in  std_ulogic);
  end component;

  component axislv2noc is
    generic (
      tech         : integer;
      nmst         : integer;
      split_transaction : integer range 0 to 1 := 0;
      retarget_for_dma : integer range 0 to 1;
      mem_axi_port : integer range -1 to NAHBSLV - 1;
      mem_num      : integer;
      mem_info     : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1);
      slv_y        : local_yx;
      slv_x        : local_yx);
    port (
      rst                        : in  std_ulogic;
      clk                        : in  std_ulogic;
      local_y                    : in  local_yx;
      local_x                    : in  local_yx;
      mosi                       : in  axi_mosi_vector(0 to nmst - 1);
      somi                       : out axi_somi_vector(0 to nmst - 1);
      coherence_req_wrreq        : out std_ulogic;
      coherence_req_data_in      : out noc_flit_type;
      coherence_req_full         : in  std_ulogic;
      coherence_rsp_rcv_rdreq    : out std_ulogic;
      coherence_rsp_rcv_data_out : in  noc_flit_type;
      coherence_rsp_rcv_empty    : in  std_ulogic;
      remote_ahbs_snd_wrreq      : out std_ulogic;
      remote_ahbs_snd_data_in    : out misc_noc_flit_type;
      remote_ahbs_snd_full       : in  std_ulogic;
      remote_ahbs_rcv_rdreq      : out std_ulogic;
      remote_ahbs_rcv_data_out   : in  misc_noc_flit_type;
      remote_ahbs_rcv_empty      : in  std_ulogic;
      coherence                  : in integer range 0 to 3);
  end component axislv2noc;

  component noc2apb
    generic (
      tech         : integer;
      local_apb_en : in  std_logic_vector(0 to NAPBSLV - 1));
    port (
      rst              : in  std_ulogic;
      clk              : in  std_ulogic;
      local_y          : in  local_yx;
      local_x          : in  local_yx;
      apbi             : out apb_slv_in_type;
      apbo             : in  apb_slv_out_vector;
      pready           : in  std_ulogic;
      dvfs_transient   : in  std_ulogic;
      apb_snd_wrreq    : out std_ulogic;
      apb_snd_data_in  : out misc_noc_flit_type;
      apb_snd_full     : in  std_ulogic;
      apb_rcv_rdreq    : out std_ulogic;
      apb_rcv_data_out : in  misc_noc_flit_type;
      apb_rcv_empty    : in  std_ulogic);
  end component;

  component intreq2noc is
    generic (
      tech  : integer;
      ncpu  : integer;
      cpu_y : yx_vec(0 to CFG_NCPU_TILE - 1);
      cpu_x : yx_vec(0 to CFG_NCPU_TILE - 1));
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      local_y            : in  local_yx;
      local_x            : in  local_yx;
      override_cpu_loc   : in  std_ulogic;
      cpu_loc_y          : in  yx_vec(0 to CFG_NCPU_TILE - 1);
      cpu_loc_x          : in  yx_vec(0 to CFG_NCPU_TILE - 1);
      irqi               : in  irq_in_vector(ncpu-1 downto 0);
      irqo               : out irq_out_vector(ncpu-1 downto 0);
      irqi_fifo_overflow : out std_ulogic;
      irq_ack_rdreq      : out std_ulogic;
      irq_ack_data_out   : in  misc_noc_flit_type;
      irq_ack_empty      : in  std_ulogic;
      irq_wrreq          : out std_ulogic;
      irq_data_in        : out misc_noc_flit_type;
      irq_full           : in  std_ulogic);
  end component intreq2noc;

  component noc2intreq
    generic (
      tech    : integer);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      noc_pirq           : out std_logic_vector(NAHBIRQ-1 downto 0);
      interrupt_rdreq    : out std_ulogic;
      interrupt_data_out : in  misc_noc_flit_type;
      interrupt_empty    : in  std_ulogic);
  end component;

  component noc2ahbmst
    generic (
      tech        : integer;
      hindex      : integer range 0 to NAHBSLV - 1;
      axitran     : integer range 0 to 1 := 0;
      little_end  : integer range 0 to 1 := 0;
      eth_dma     : integer range 0 to 1 := 0;
      narrow_noc  : integer range 0 to 1 := 0;
      cacheline   : integer;
      l2_cache_en : integer := 0);
    port (
      rst                    : in  std_ulogic;
      clk                    : in  std_ulogic;
      local_y                : in  local_yx;
      local_x                : in  local_yx;
      ahbmi                  : in  ahb_mst_in_type;
      ahbmo                  : out ahb_mst_out_type;
      coherence_req_rdreq    : out std_ulogic;
      coherence_req_data_out : in  noc_flit_type;
      coherence_req_empty    : in  std_ulogic;
      coherence_fwd_wrreq    : out std_ulogic;
      coherence_fwd_data_in  : out noc_flit_type;
      coherence_fwd_full     : in  std_ulogic;
      coherence_rsp_snd_wrreq    : out std_ulogic;
      coherence_rsp_snd_data_in  : out noc_flit_type;
      coherence_rsp_snd_full     : in  std_ulogic;
      dma_rcv_rdreq          : out std_ulogic;
      dma_rcv_data_out       : in  noc_flit_type;
      dma_rcv_empty          : in  std_ulogic;
      dma_snd_wrreq          : out std_ulogic;
      dma_snd_data_in        : out noc_flit_type;
      dma_snd_full           : in  std_ulogic;
      dma_snd_atleast_4slots : in  std_ulogic;
      dma_snd_exactly_3slots : in  std_ulogic);
  end component;

  component esp_acc_dma
    generic (
      tech               : integer;
      extra_clk_buf      : integer range 0 to 1;
      mem_num            : integer := 1;
      mem_info           : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE);
      io_y               : local_yx;
      io_x               : local_yx;
      pindex             : integer;
      revision           : integer;
      devid              : devid_t;
      available_reg_mask : std_logic_vector(0 to MAXREGNUM - 1);
      rdonly_reg_mask    : std_logic_vector(0 to MAXREGNUM - 1);
      exp_registers      : integer range 0 to 1;
      scatter_gather     : integer range 0 to 1;
      tlb_entries        : integer;
      has_dvfs           : integer := 1;
      has_pll            : integer);
    port (
      rst               : in  std_ulogic;
      clk               : in  std_ulogic;
      local_y           : in  local_yx;
      local_x           : in  local_yx;
      paddr             : in  integer;
      pmask             : in  integer;
      pirq              : in  integer;
      apbi              : in  apb_slv_in_type;
      apbo              : out apb_slv_out_type;
      bank              : out bank_type(0 to MAXREGNUM - 1);
      bankdef           : in  bank_type(0 to MAXREGNUM - 1);
      acc_rst           : out std_ulogic;
      conf_done         : out std_ulogic;
      rd_request        : in  std_ulogic;
      rd_index          : in  std_logic_vector(31 downto 0);
      rd_length         : in  std_logic_vector(31 downto 0);
      rd_size           : in  std_logic_vector(2 downto 0);
      rd_grant          : out std_ulogic;
      bufdin_ready      : in  std_ulogic;
      bufdin_data       : out std_logic_vector(ARCH_BITS - 1 downto 0);
      bufdin_valid      : out std_ulogic;
      wr_request        : in  std_ulogic;
      wr_index          : in  std_logic_vector(31 downto 0);
      wr_length         : in  std_logic_vector(31 downto 0);
      wr_size           : in  std_logic_vector(2 downto 0);
      wr_grant          : out std_ulogic;
      bufdout_ready     : out std_ulogic;
      bufdout_data      : in  std_logic_vector(ARCH_BITS - 1 downto 0);
      bufdout_valid     : in  std_ulogic;
      acc_done          : in  std_ulogic;
      flush             : out std_ulogic;
      mon_dvfs_in       : in  monitor_dvfs_type;
      mon_dvfs          : out monitor_dvfs_type;
      dvfs_transient_in : in std_ulogic;
      llc_coherent_dma_rcv_rdreq    : out std_ulogic;
      llc_coherent_dma_rcv_data_out : in  noc_flit_type;
      llc_coherent_dma_rcv_empty    : in  std_ulogic;
      llc_coherent_dma_snd_wrreq    : out std_ulogic;
      llc_coherent_dma_snd_data_in  : out noc_flit_type;
      llc_coherent_dma_snd_full     : in  std_ulogic;
      coherent_dma_read    : out std_ulogic;
      coherent_dma_write   : out std_ulogic;
      coherent_dma_length  : out addr_t;
      coherent_dma_address : out addr_t;
      coherent_dma_ready   : in  std_ulogic;
      dma_rcv_rdreq     : out std_ulogic;
      dma_rcv_data_out  : in  noc_flit_type;
      dma_rcv_empty     : in  std_ulogic;
      dma_snd_wrreq     : out std_ulogic;
      dma_snd_data_in   : out noc_flit_type;
      dma_snd_full      : in  std_ulogic;
      interrupt_wrreq   : out std_ulogic;
      interrupt_data_in : out misc_noc_flit_type;
      interrupt_full    : in  std_ulogic);
  end component;

  component fixen_64to32 is
    port (
      clk         : in  std_ulogic;
      rstn        : in  std_ulogic;
      bypass_i    : in  std_ulogic;
      in_data_i   : in  std_logic_vector(ARCH_BITS - 1 downto 0);
      in_valid_i  : in  std_ulogic;
      in_ready_o  : out std_ulogic;
      out_data_o  : out std_logic_vector(ARCH_BITS - 1 downto 0);
      out_valid_o : out std_ulogic;
      out_ready_i : in  std_ulogic);
  end component fixen_64to32;

  component esp_acc_tlb
    generic (
      tech           : integer;
      scatter_gather : integer range 0 to 1;
      tlb_entries    : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      bankreg              : in  bank_type(0 to MAXREGNUM - 1);
      rd_request           : in  std_ulogic;
      rd_index             : in  std_logic_vector(31 downto 0);
      rd_length            : in  std_logic_vector(31 downto 0);
      wr_request           : in  std_ulogic;
      wr_index             : in  std_logic_vector(31 downto 0);
      wr_length            : in  std_logic_vector(31 downto 0);
      dma_tran_start       : out std_ulogic;
      dma_tran_header_sent : in  std_ulogic;
      dma_tran_done        : in  std_ulogic;
      pending_dma_write    : out std_ulogic;
      pending_dma_read     : out std_ulogic;
      tlb_empty            : out std_ulogic;
      tlb_clear            : in  std_ulogic;
      tlb_valid            : in  std_ulogic;
      tlb_write            : in  std_ulogic;
      tlb_wr_address       : in  std_logic_vector((log2xx(tlb_entries) -1) downto 0);
      tlb_datain           : in  std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
      dma_address          : out std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
      dma_length           : out std_logic_vector(31 downto 0));
  end component;

  component tile_dvfs
    generic (
      tech   : integer;
      pindex : integer := 0);
    port (
      rst           : in  std_ulogic;
      clk           : in  std_ulogic;
      paddr         : in  integer;
      pmask         : in  integer;
      apbi          : in  apb_slv_in_type;
      apbo          : out apb_slv_out_type;
      clear_command : in  std_ulogic;
      sample_status : in  std_ulogic;
      voltage       : in  std_logic_vector(31 downto 0);
      frequency     : in  std_logic_vector(31 downto 0);
      qadc          : in  std_logic_vector(31 downto 0);
      bank          : out bank_type(0 to MAXREGNUM - 1)
      );
  end component;

  component dvfs_fsm
    generic (
      tech          : integer;
      extra_clk_buf : integer range 0 to 1 := 1);
    port (
      rst           : in  std_ulogic;
      refclk        : in  std_ulogic;
      pllbypass     : in  std_ulogic;
      pllclk        : out std_ulogic;
      clear_command : out std_ulogic;
      sample_status : out std_ulogic;
      voltage       : out std_logic_vector(31 downto 0);
      frequency     : out std_logic_vector(31 downto 0);
      qadc          : out std_logic_vector(31 downto 0);
      bank          : in  bank_type(0 to MAXREGNUM - 1);
      acc_idle      : in  std_ulogic;
      traffic       : in  std_ulogic;
      burst         : in  std_ulogic;
      mon_dvfs      : out monitor_dvfs_type
      );

  end component;

  component dvfs_top
    generic (
      tech          : integer              := virtex7;
      extra_clk_buf : integer range 0 to 1 := 1;
      pindex        : integer              := 0);
    port (
      rst       : in  std_ulogic;
      clk       : in  std_ulogic;
      paddr     : in integer;
      pmask     : in integer;
      refclk    : in  std_ulogic;
      pllbypass : in  std_ulogic;
      pllclk    : out std_ulogic;
      apbi      : in  apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      acc_idle  : in  std_ulogic;
      traffic   : in  std_ulogic;
      burst     : in  std_ulogic;
      mon_dvfs  : out monitor_dvfs_type);
  end component;

  component mem2ext is
    port (
      clk               : in  std_ulogic;
      rstn              : in  std_ulogic;
      local_y           : in  local_yx;
      local_x           : in  local_yx;
      fpga_data_in      : in  std_logic_vector(ARCH_BITS - 1 downto 0);
      fpga_data_out     : out std_logic_vector(ARCH_BITS - 1 downto 0);
      fpga_valid_in     : in  std_logic;
      fpga_valid_out    : out std_logic;
      fpga_oen          : out std_logic;
      fpga_clk_in       : in  std_logic;
      fpga_clk_out      : out std_logic;
      fpga_credit_in    : in  std_logic;
      fpga_credit_out   : out std_logic;
      llc_ext_req_ready : out std_ulogic;
      llc_ext_req_valid : in  std_ulogic;
      llc_ext_req_data  : in  std_logic_vector(ARCH_BITS - 1 downto 0);
      llc_ext_rsp_ready : in  std_ulogic;
      llc_ext_rsp_valid : out std_ulogic;
      llc_ext_rsp_data  : out std_logic_vector(ARCH_BITS - 1 downto 0);
      dma_rcv_rdreq     : out std_ulogic;
      dma_rcv_data_out  : in  noc_flit_type;
      dma_rcv_empty     : in  std_ulogic;
      dma_snd_wrreq     : out std_ulogic;
      dma_snd_data_in   : out noc_flit_type;
      dma_snd_full      : in  std_ulogic);
  end component mem2ext;

  component ext2ahbm is
    generic (
      hindex : integer range 0 to NAHBSLV - 1;
      little_end  : integer range 0 to 1 := 0);
    port (
      clk             : in  std_ulogic;
      rstn            : in  std_ulogic;
      fpga_data_in    : out std_logic_vector(ARCH_BITS - 1 downto 0);
      fpga_data_out   : in  std_logic_vector(ARCH_BITS - 1 downto 0);
      fpga_valid_in   : out std_ulogic;
      fpga_valid_out  : in  std_ulogic;
      fpga_data_ien   : out std_logic;
      fpga_clk_in     : out std_ulogic;
      fpga_clk_out    : in  std_ulogic;
      fpga_credit_in  : out std_ulogic;
      fpga_credit_out : in  std_ulogic;
      ahbmo           : out ahb_mst_out_type;
      ahbmi           : in  ahb_mst_in_type);
  end component ext2ahbm;

  component acc_top is
  generic (
    hls_conf       : hlscfg_t;
    this_device    : devid_t;
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
    little_end     : integer range 0 to 1 := 0;
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
    local_y   : in  local_yx;
    local_x   : in  local_yx;
    tile_id   : in  integer;
    paddr     : in  integer range 0 to 4095;
    pmask     : in  integer range 0 to 4095;
    paddr_ext : in  integer range 0 to 4095;
    pmask_ext : in  integer range 0 to 4095;
    pirq      : in  integer range 0 to NAHBIRQ - 1;
    apbi      : in apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    pready    : out std_ulogic;
    coherence_req_wrreq        : out std_ulogic;
    coherence_req_data_in      : out noc_flit_type;
    coherence_req_full         : in  std_ulogic;
    coherence_fwd_rdreq        : out std_ulogic;
    coherence_fwd_data_out     : in  noc_flit_type;
    coherence_fwd_empty        : in  std_ulogic;
    coherence_rsp_rcv_rdreq    : out std_ulogic;
    coherence_rsp_rcv_data_out : in  noc_flit_type;
    coherence_rsp_rcv_empty    : in  std_ulogic;
    coherence_rsp_snd_wrreq    : out std_ulogic;
    coherence_rsp_snd_data_in  : out noc_flit_type;
    coherence_rsp_snd_full     : in  std_ulogic;
    coherence_fwd_snd_wrreq    : out  std_ulogic;
    coherence_fwd_snd_data_in  : out  noc_flit_type;
    coherence_fwd_snd_full : in  std_ulogic; 
    dma_rcv_rdreq     : out std_ulogic;
    dma_rcv_data_out  : in  noc_flit_type;
    dma_rcv_empty     : in  std_ulogic;
    dma_snd_wrreq     : out std_ulogic;
    dma_snd_data_in   : out noc_flit_type;
    dma_snd_full      : in  std_ulogic;
    coherent_dma_rcv_rdreq     : out std_ulogic;
    coherent_dma_rcv_data_out  : in  noc_flit_type;
    coherent_dma_rcv_empty     : in  std_ulogic;
    coherent_dma_snd_wrreq     : out std_ulogic;
    coherent_dma_snd_data_in   : out noc_flit_type;
    coherent_dma_snd_full      : in  std_ulogic;
    interrupt_wrreq   : out std_ulogic;
    interrupt_data_in : out misc_noc_flit_type;
    interrupt_full    : in  std_ulogic;
    interrupt_ack_rdreq    : out std_ulogic;
    interrupt_ack_data_out : in  misc_noc_flit_type;
    interrupt_ack_empty    : in  std_ulogic;
    mon_dvfs_in       : in  monitor_dvfs_type;
    dvfs_transient_in    : in std_ulogic;
    mon_acc           : out monitor_acc_type;
    mon_cache         : out monitor_cache_type;
    mon_dvfs          : out monitor_dvfs_type;
    coherence         : in  integer range 0 to 3
    );
end component acc_top;
  
  component apb2axil is 
    port (
      clk              : in std_ulogic;
      rstn             : in std_ulogic;
      paddr            : in std_logic_vector(31 downto 0);
      penable          : in std_ulogic;     
      psel             : in std_ulogic;   
      pwdata           : in std_logic_vector(31 downto 0);
      pwrite           : in std_ulogic;
      prdata           : out std_logic_vector(31 downto 0);
      pready           : out std_ulogic;
      pslverr          : out std_ulogic;
      s_axil_awvalid   : out std_ulogic; 
      s_axil_awready   : in std_ulogic;
      s_axil_awaddr    : out std_logic_vector(31 downto 0);
      s_axil_wvalid    : out std_ulogic;
      s_axil_wready    : in std_ulogic;
      s_axil_wdata     : out std_logic_vector(31 downto 0);
      s_axil_wstrb     : out std_logic_vector(3 downto 0);
      s_axil_arvalid   : out std_ulogic;
      s_axil_arready   : in std_ulogic;
      s_axil_araddr    : out std_logic_vector(31 downto 0);
      s_axil_rvalid    : in std_ulogic;
      s_axil_rready    : out std_ulogic;
      s_axil_rdata     : in std_logic_vector(31 downto 0);
      s_axil_rresp     : in std_logic_vector(1 downto 0);
      s_axil_bvalid    : in std_ulogic;
      s_axil_bready    : out std_ulogic;
      s_axil_bresp     : in std_logic_vector(1 downto 0)
      );
end component apb2axil;

end tile;
