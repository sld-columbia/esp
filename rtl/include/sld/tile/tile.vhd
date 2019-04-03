-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: MIT

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.sldcommon.all;
use work.nocpackage.all;
use work.cachepackage.all;

use work.coretypes.all;
use work.acctypes.all;

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
      remote_ahbs_snd_wrreq      : in std_ulogic;
      remote_ahbs_snd_data_in    : in noc_flit_type;
      remote_ahbs_snd_full       : out std_ulogic;
      remote_ahbs_rcv_rdreq      : in std_ulogic;
      remote_ahbs_rcv_data_out   : out noc_flit_type;
      remote_ahbs_rcv_empty      : out std_ulogic;
      apb_rcv_rdreq            : in  std_ulogic;
      apb_rcv_data_out         : out noc_flit_type;
      apb_rcv_empty            : out std_ulogic;
      apb_snd_wrreq            : in  std_ulogic;
      apb_snd_data_in          : in  noc_flit_type;
      apb_snd_full             : out std_ulogic;
      remote_apb_rcv_rdreq     : in  std_ulogic;
      remote_apb_rcv_data_out  : out noc_flit_type;
      remote_apb_rcv_empty     : out std_ulogic;
      remote_apb_snd_wrreq     : in  std_ulogic;
      remote_apb_snd_data_in   : in  noc_flit_type;
      remote_apb_snd_full      : out std_ulogic;
      remote_irq_rdreq         : in  std_ulogic;
      remote_irq_data_out      : out noc_flit_type;
      remote_irq_empty         : out std_ulogic;
      remote_irq_ack_wrreq     : in  std_ulogic;
      remote_irq_ack_data_in   : in  noc_flit_type;
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
      noc5_out_data            : in  noc_flit_type;
      noc5_out_void            : in  std_ulogic;
      noc5_out_stop            : out std_ulogic;
      noc5_in_data             : out noc_flit_type;
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
      ahbs_rcv_data_out               : out noc_flit_type;
      ahbs_rcv_empty                  : out std_ulogic;
      ahbs_snd_wrreq                  : in  std_ulogic;
      ahbs_snd_data_in                : in  noc_flit_type;
      ahbs_snd_full                   : out std_ulogic;
      remote_ahbs_rcv_rdreq           : in  std_ulogic;
      remote_ahbs_rcv_data_out        : out noc_flit_type;
      remote_ahbs_rcv_empty           : out std_ulogic;
      remote_ahbs_snd_wrreq           : in  std_ulogic;
      remote_ahbs_snd_data_in         : in  noc_flit_type;
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
      apb_rcv_rdreq                   : in  std_ulogic;
      apb_rcv_data_out                : out noc_flit_type;
      apb_rcv_empty                   : out std_ulogic;
      apb_snd_wrreq                   : in  std_ulogic;
      apb_snd_data_in                 : in  noc_flit_type;
      apb_snd_full                    : out std_ulogic;
      remote_apb_rcv_rdreq            : in  std_ulogic;
      remote_apb_rcv_data_out         : out noc_flit_type;
      remote_apb_rcv_empty            : out std_ulogic;
      remote_apb_snd_wrreq            : in  std_ulogic;
      remote_apb_snd_data_in          : in  noc_flit_type;
      remote_apb_snd_full             : out std_ulogic;
      irq_ack_rdreq                   : in  std_ulogic;
      irq_ack_data_out                : out noc_flit_type;
      irq_ack_empty                   : out std_ulogic;
      irq_wrreq                       : in  std_ulogic;
      irq_data_in                     : in  noc_flit_type;
      irq_full                        : out std_ulogic;
      interrupt_rdreq                 : in  std_ulogic;
      interrupt_data_out              : out noc_flit_type;
      interrupt_empty                 : out std_ulogic;
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
      noc5_out_data                   : in  noc_flit_type;
      noc5_out_void                   : in  std_ulogic;
      noc5_out_stop                   : out std_ulogic;
      noc5_in_data                    : out noc_flit_type;
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
      remote_ahbs_rcv_data_out : out noc_flit_type;
      remote_ahbs_rcv_empty    : out std_ulogic;
      remote_ahbs_snd_wrreq    : in  std_ulogic;
      remote_ahbs_snd_data_in  : in  noc_flit_type;
      remote_ahbs_snd_full     : out std_ulogic;
      apb_rcv_rdreq            : in  std_ulogic;
      apb_rcv_data_out         : out noc_flit_type;
      apb_rcv_empty            : out std_ulogic;
      apb_snd_wrreq            : in  std_ulogic;
      apb_snd_data_in          : in  noc_flit_type;
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
      noc5_out_data            : in  noc_flit_type;
      noc5_out_void            : in  std_ulogic;
      noc5_out_stop            : out std_ulogic;
      noc5_in_data             : out noc_flit_type;
      noc5_in_void             : out std_ulogic;
      noc5_in_stop             : in  std_ulogic;
      noc6_out_data            : in  noc_flit_type;
      noc6_out_void            : in  std_ulogic;
      noc6_out_stop            : out std_ulogic;
      noc6_in_data             : out noc_flit_type;
      noc6_in_void             : out std_ulogic;
      noc6_in_stop             : in  std_ulogic);
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
      apb_rcv_data_out  : out noc_flit_type;
      apb_rcv_empty     : out std_ulogic;
      apb_snd_wrreq     : in  std_ulogic;
      apb_snd_data_in   : in  noc_flit_type;
      apb_snd_full      : out std_ulogic;
      interrupt_wrreq   : in  std_ulogic;
      interrupt_data_in : in  noc_flit_type;
      interrupt_full    : out std_ulogic;
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
      noc5_out_data     : in  noc_flit_type;
      noc5_out_void     : in  std_ulogic;
      noc5_out_stop     : out std_ulogic;
      noc5_in_data      : out noc_flit_type;
      noc5_in_void      : out std_ulogic;
      noc5_in_stop      : in  std_ulogic;
      noc6_out_data     : in  noc_flit_type;
      noc6_out_void     : in  std_ulogic;
      noc6_out_stop     : out std_ulogic;
      noc6_in_data      : out noc_flit_type;
      noc6_in_void      : out std_ulogic;
      noc6_in_stop      : in  std_ulogic);
  end component;

  component fpga_q
    generic (
      tech : integer);
    port (
      rst                      : in  std_ulogic;
      clk                      : in  std_ulogic;
      remote_ahbs_rcv_rdreq    : in  std_ulogic;
      remote_ahbs_rcv_data_out : out noc_flit_type;
      remote_ahbs_rcv_empty    : out std_ulogic;
      remote_ahbs_snd_wrreq    : in  std_ulogic;
      remote_ahbs_snd_data_in  : in  noc_flit_type;
      remote_ahbs_snd_full     : out std_ulogic;
      remote_apb_rcv_rdreq     : in  std_ulogic;
      remote_apb_rcv_data_out  : out noc_flit_type;
      remote_apb_rcv_empty     : out std_ulogic;
      remote_apb_snd_wrreq     : in  std_ulogic;
      remote_apb_snd_data_in   : in  noc_flit_type;
      remote_apb_snd_full      : out std_ulogic;
      coherence_req_rdreq      : in  std_ulogic;
      coherence_req_data_out   : out noc_flit_type;
      coherence_req_empty      : out std_ulogic;
      coherence_rsp_snd_wrreq      : in  std_ulogic;
      coherence_rsp_snd_data_in    : in  noc_flit_type;
      coherence_rsp_snd_full       : out std_ulogic;
      dma_rcv_rdreq            : in  std_ulogic;
      dma_rcv_data_out         : out noc_flit_type;
      dma_rcv_empty            : out std_ulogic;
      dma_snd_wrreq            : in  std_ulogic;
      dma_snd_data_in          : in  noc_flit_type;
      dma_snd_full             : out std_ulogic;
      dma_snd_atleast_4slots   : out std_ulogic;
      dma_snd_exactly_3slots   : out std_ulogic;
      noc_id_out               : in  std_logic_vector(1 downto 0);
      noc_id_in                : out std_logic_vector(1 downto 0);
      bus_out_data             : in  noc_flit_type;
      bus_out_void             : in  std_ulogic;
      bus_out_stop             : out std_ulogic;
      bus_in_data              : out noc_flit_type;
      bus_in_void              : out std_ulogic;
      bus_in_stop              : in  std_ulogic);
  end component;

  component apb2noc
    generic (
      tech       : integer;
      ncpu       : integer;
      local_y    : local_yx;
      local_x    : local_yx;
      apb_slv_en : std_logic_vector(0 to NAPBSLV - 1);
      apb_slv_cfg : apb_slv_config_vector;
      apb_slv_y  : yx_vec(0 to NAPBSLV - 1);
      apb_slv_x  : yx_vec(0 to NAPBSLV - 1));
    port (
      rst                     : in  std_ulogic;
      clk                     : in  std_ulogic;
      apbi                    : in  apb_slv_in_type;
      apbo                    : out apb_slv_out_vector;
      apb_req                 : in  std_ulogic;
      apb_ack                 : out std_ulogic;
      remote_apb_snd_wrreq    : out std_ulogic;
      remote_apb_snd_data_in  : out noc_flit_type;
      remote_apb_snd_full     : in  std_ulogic;
      remote_apb_rcv_rdreq    : out std_ulogic;
      remote_apb_rcv_data_out : in  noc_flit_type;
      remote_apb_rcv_empty    : in  std_ulogic);
  end component;

  component cpu_irq2noc is
    generic (
      tech    : integer;
      cpu_id  : integer;
      local_y : local_yx;
      local_x : local_yx;
      irq_y   : local_yx;
      irq_x   : local_yx);
    port (
      rst                    : in  std_ulogic;
      clk                    : in  std_ulogic;
      irqi                   : out l3_irq_in_type;
      irqo                   : in  l3_irq_out_type;
      irqo_fifo_overflow     : out std_ulogic;
      remote_irq_rdreq       : out std_ulogic;
      remote_irq_data_out    : in  noc_flit_type;
      remote_irq_empty       : in  std_ulogic;
      remote_irq_ack_wrreq   : out std_ulogic;
      remote_irq_ack_data_in : out noc_flit_type;
      remote_irq_ack_full    : in  std_ulogic);
  end component cpu_irq2noc;

  component cpu_ahbs2noc
    generic (
      tech        : integer;
      hindex      : std_logic_vector(0 to NAHBSLV - 1);
      hconfig     : ahb_slv_config_vector;
      local_y     : local_yx;
      local_x     : local_yx;
      mem_hindex  : integer range 0 to NAHBSLV - 1;
      mem_num     : integer;
      mem_info    : tile_mem_info_vector(0 to MEM_MAX_NUM - 1);
      slv_y       : local_yx;
      slv_x       : local_yx;
      retarget_for_dma : integer range 0 to 1;
      dma_length       : integer);
   port (
      rst                        : in  std_ulogic;
      clk                        : in  std_ulogic;
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
      remote_ahbs_snd_data_in    : out noc_flit_type;
      remote_ahbs_snd_full       : in  std_ulogic;
      remote_ahbs_rcv_rdreq      : out std_ulogic;
      remote_ahbs_rcv_data_out   : in  noc_flit_type;
      remote_ahbs_rcv_empty      : in  std_ulogic);
  end component;

  component misc_noc2apb
    generic (
      tech         : integer;
      local_y      : local_yx;
      local_x      : local_yx;
      local_apb_en : std_logic_vector(0 to NAPBSLV - 1));
    port (
      rst              : in  std_ulogic;
      clk              : in  std_ulogic;
      apbi             : out apb_slv_in_type;
      apbo             : in  apb_slv_out_vector;
      dvfs_transient   : in  std_ulogic;
      apb_snd_wrreq    : out std_ulogic;
      apb_snd_data_in  : out noc_flit_type;
      apb_snd_full     : in  std_ulogic;
      apb_rcv_rdreq    : out std_ulogic;
      apb_rcv_data_out : in  noc_flit_type;
      apb_rcv_empty    : in  std_ulogic);
  end component;

  component misc_irq2noc is
    generic (
      tech    : integer;
      ncpu    : integer;
      local_y : local_yx;
      local_x : local_yx;
      cpu_y   : yx_vec(0 to CPU_MAX_NUM - 1);
      cpu_x   : yx_vec(0 to CPU_MAX_NUM - 1));
    port (
          rst                : in  std_ulogic;
          clk                : in  std_ulogic;
          irqi               : in  irq_in_vector(ncpu-1 downto 0);
          irqo               : out irq_out_vector(ncpu-1 downto 0);
          irqi_fifo_overflow : out std_ulogic;
          irq_ack_rdreq      : out std_ulogic;
          irq_ack_data_out   : in  noc_flit_type;
          irq_ack_empty      : in  std_ulogic;
          irq_wrreq          : out std_ulogic;
          irq_data_in        : out noc_flit_type;
          irq_full           : in  std_ulogic);
  end component misc_irq2noc;

  component misc_noc2interrupt
    generic (
      tech    : integer;
      local_y : local_yx;
      local_x : local_yx);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      noc_pirq           : out std_logic_vector(NAHBIRQ-1 downto 0);
      interrupt_rdreq    : out std_ulogic;
      interrupt_data_out : in  noc_flit_type;
      interrupt_empty    : in  std_ulogic);
  end component;

  component mem_noc2ahbm
    generic (
      tech        : integer;
      hindex      : integer range 0 to NAHBSLV - 1;
      local_y     : local_yx;
      local_x     : local_yx;
      cacheline   : integer;
      l2_cache_en : integer := 0);
    port (
      rst                    : in  std_ulogic;
      clk                    : in  std_ulogic;
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

  component acc_dma2noc
    generic (
      tech               : integer;
      extra_clk_buf      : integer range 0 to 1;
      local_y            : local_yx;
      local_x            : local_yx;
      mem_num            : integer := 1;
      mem_info           : tile_mem_info_vector(0 to MEM_MAX_NUM);
      io_y               : local_yx;
      io_x               : local_yx;
      pindex             : integer;
      paddr              : integer;
      pmask              : integer;
      pirq               : integer;
      revision           : integer;
      devid              : devid_t;
      available_reg_mask : std_logic_vector(0 to 31);
      rdonly_reg_mask    : std_logic_vector(0 to 31);
      exp_registers      : integer range 0 to 1;
      scatter_gather     : integer range 0 to 1;
      tlb_entries        : integer;
      has_dvfs           : integer := 1;
      has_pll            : integer);
    port (
      rst               : in  std_ulogic;
      clk               : in  std_ulogic;
      refclk            : in  std_ulogic;
      pllbypass         : in  std_ulogic;
      pllclk            : out std_ulogic;
      apbi              : in  apb_slv_in_type;
      apbo              : out apb_slv_out_type;
      bank              : out bank_type(0 to MAXREGNUM - 1);
      bankdef           : in  bank_type(0 to MAXREGNUM - 1);
      acc_rst           : out std_ulogic;
      conf_done         : out std_ulogic;
      rd_request        : in  std_ulogic;
      rd_index          : in  std_logic_vector(31 downto 0);
      rd_length         : in  std_logic_vector(31 downto 0);
      rd_grant          : out std_ulogic;
      bufdin_ready      : in  std_ulogic;
      bufdin_data       : out std_logic_vector(31 downto 0);
      bufdin_valid      : out std_ulogic;
      wr_request        : in  std_ulogic;
      wr_index          : in  std_logic_vector(31 downto 0);
      wr_length         : in  std_logic_vector(31 downto 0);
      wr_grant          : out std_ulogic;
      bufdout_ready     : out std_ulogic;
      bufdout_data      : in  std_logic_vector(31 downto 0);
      bufdout_valid     : in  std_ulogic;
      acc_done          : in  std_ulogic;
      flush             : out std_ulogic;
      mon_dvfs_in       : in  monitor_dvfs_type;
      mon_dvfs          : out monitor_dvfs_type;
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
      interrupt_data_in : out noc_flit_type;
      interrupt_full    : in  std_ulogic);
  end component;

  component mem_q2bus
    generic (
      tech : integer);
    port (
      rst                      : in  std_ulogic;
      clk                      : in  std_ulogic;
      remote_ahbs_rcv_rdreq    : out std_ulogic;
      remote_ahbs_rcv_data_out : in  noc_flit_type;
      remote_ahbs_rcv_empty    : in  std_ulogic;
      remote_ahbs_snd_wrreq    : out std_ulogic;
      remote_ahbs_snd_data_in  : out noc_flit_type;
      remote_ahbs_snd_full     : in  std_ulogic;
      remote_apb_rcv_rdreq     : out std_ulogic;
      remote_apb_rcv_data_out  : in  noc_flit_type;
      remote_apb_rcv_empty     : in  std_ulogic;
      remote_apb_snd_wrreq     : out std_ulogic;
      remote_apb_snd_data_in   : out noc_flit_type;
      remote_apb_snd_full      : in  std_ulogic;
      coherence_req_rdreq      : out std_ulogic;
      coherence_req_data_out   : in  noc_flit_type;
      coherence_req_empty      : in  std_ulogic;
      coherence_rsp_snd_wrreq      : out std_ulogic;
      coherence_rsp_snd_data_in    : out noc_flit_type;
      coherence_rsp_snd_full       : in  std_ulogic;
      dma_rcv_rdreq            : out std_ulogic;
      dma_rcv_data_out         : in  noc_flit_type;
      dma_rcv_empty            : in  std_ulogic;
      dma_snd_wrreq            : out std_ulogic;
      dma_snd_data_in          : out noc_flit_type;
      dma_snd_full             : in  std_ulogic;
      noc_id_out               : out std_logic_vector(1 downto 0);
      noc_id_in                : in  std_logic_vector(1 downto 0);
      bus_out_data             : out noc_flit_type;
      bus_out_void             : out std_ulogic;
      bus_out_stop             : in  std_ulogic;
      bus_in_data              : in  noc_flit_type;
      bus_in_void              : in  std_ulogic;
      bus_in_stop              : out std_ulogic);
  end component;

  component tile_dvfs
    generic (
      tech   : integer;
      pindex : integer;
      paddr  : integer;
      pmask  : integer);
    port (
      rst           : in  std_ulogic;
      clk           : in  std_ulogic;
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
      tech          : integer;
      extra_clk_buf : integer;
      pindex        : integer;
      paddr         : integer;
      pmask         : integer);
    port (
      rst       : in  std_ulogic;
      clk       : in  std_ulogic;
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

end tile;
