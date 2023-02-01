-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
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

use work.coretypes.all;
use work.esp_acc_regmap.all;

package monitor_pkg is

  type monitor_ddr_type is record
    clk           : std_ulogic;
    word_transfer : std_ulogic;
  end record;

  type monitor_mem_type is record
    clk              : std_ulogic;
    coherent_req     : std_ulogic;
    coherent_fwd     : std_ulogic;
    coherent_rsp_rcv : std_ulogic;
    coherent_rsp_snd : std_ulogic;
    dma_req          : std_ulogic;
    dma_rsp          : std_ulogic;
    coherent_dma_req : std_ulogic;
    coherent_dma_rsp : std_ulogic;
  end record;

  type monitor_noc_type is record
    clk         : std_ulogic;
    tile_inject : std_ulogic;
    queue_full  : std_logic_vector(4 downto 0);
  end record;

  type monitor_cache_type is record
    clk  : std_ulogic;
    hit  : std_ulogic;
    miss : std_ulogic;
  end record monitor_cache_type;

  type monitor_acc_type is record
    clk   : std_ulogic;
    go    : std_ulogic;
    run   : std_ulogic;
    done  : std_ulogic;
    burst : std_ulogic;
  end record;

  type monitor_dvfs_type is record
    clk       : std_ulogic;
    vf        : std_logic_vector(3 downto 0);
    acc_idle  : std_ulogic;
    traffic   : std_ulogic;
    burst     : std_ulogic;
    transient : std_ulogic;
  end record;

  type monitor_ddr_vector is array (natural range <>) of monitor_ddr_type;

  type monitor_noc_vector is array (natural range <>) of monitor_noc_type;
  type monitor_noc_matrix is array (natural range <>, natural range <>) of monitor_noc_type;

  type monitor_mem_vector is array (natural range <>) of monitor_mem_type;

  type monitor_cache_vector is array (natural range <>) of monitor_cache_type;

  type monitor_acc_vector is array (natural range <>) of monitor_acc_type;

  type monitor_dvfs_vector is array (natural range <>) of monitor_dvfs_type;

  constant monitor_noc_none : monitor_noc_type := (
    clk         => '0',
    tile_inject => '0',
    queue_full  => (others => '0')
    );

  constant monitor_acc_none : monitor_acc_type := (
    clk   => '0',
    go    => '0',
    run   => '0',
    done  => '0',
    burst => '0'
    );

  constant monitor_cache_none : monitor_cache_type := (
    clk  => '0',
    hit  => '0',
    miss => '0'
    );

  constant monitor_dvfs_none : monitor_dvfs_type := (
    clk       => '0',
    vf        => (others => '0'),
    acc_idle  => '0',
    traffic   => '0',
    burst     => '0',
    transient => '0'
    );

  constant monitor_ddr_none : monitor_ddr_type := (
    clk           => '0',
    word_transfer => '0'
    );

  constant monitor_mem_none : monitor_mem_type := (
    clk              => '0',
    coherent_req     => '0',
    coherent_fwd     => '0',
    coherent_rsp_rcv => '0',
    coherent_rsp_snd => '0',
    dma_req          => '0',
    dma_rsp          => '0',
    coherent_dma_req => '0',
    coherent_dma_rsp => '0'
    );

  component monitor
    generic (
      memtech                : integer;
      mmi64_width            : integer;
      ddrs_num               : integer;
      slms_num               : integer;
      nocs_num               : integer;
      tiles_num              : integer;
      accelerators_num       : integer;
      l2_num                 : integer;
      llc_num                : integer;
      mon_ddr_en             : integer;
      mon_noc_tile_inject_en : integer;
      mon_noc_queues_full_en : integer;
      mon_acc_en             : integer;
      mon_mem_en             : integer;
      mon_l2_en              : integer;
      mon_llc_en             : integer;
      mon_dvfs_en            : integer);
    port (
      profpga_clk0_p  : in  std_logic;
      profpga_clk0_n  : in  std_logic;
      profpga_sync0_p : in  std_logic;
      profpga_sync0_n : in  std_logic;
      dmbi_h2f        : in  std_logic_vector(19 downto 0);
      dmbi_f2h        : out std_logic_vector(19 downto 0);
      user_rstn       : in  std_logic;
      mon_ddr         : in  monitor_ddr_vector(0 to ddrs_num-1);
      mon_noc         : in  monitor_noc_matrix(0 to nocs_num-1, 0 to tiles_num-1);
      mon_acc         : in  monitor_acc_vector(0 to relu(accelerators_num-1));
      mon_mem         : in  monitor_mem_vector(0 to ddrs_num+slms_num-1);
      mon_l2          : in  monitor_cache_vector(0 to relu(l2_num-1));
      mon_llc         : in  monitor_cache_vector(0 to relu(llc_num-1));
      mon_dvfs        : in  monitor_dvfs_vector(0 to tiles_num-1)
      );
  end component;

end;
