-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;
use work.tile.all;

entity empty_tile_q is
  generic (
    tech : integer := virtex7);
  port (
    rst                             : in  std_ulogic;
    clk                             : in  std_ulogic;
    -- NoC5->tile
    apb_rcv_rdreq           : in  std_ulogic;
    apb_rcv_data_out        : out misc_noc_flit_type;
    apb_rcv_empty           : out std_ulogic;
    -- tile->NoC5
    apb_snd_wrreq           : in  std_ulogic;
    apb_snd_data_in         : in  misc_noc_flit_type;
    apb_snd_full            : out std_ulogic;

    -- Cachable data plane 1 -> request messages
    noc1_out_data : in  noc_flit_type;
    noc1_out_void : in  std_ulogic;
    noc1_out_stop : out std_ulogic;
    noc1_in_data  : out noc_flit_type;
    noc1_in_void  : out std_ulogic;
    noc1_in_stop  : in  std_ulogic;
    -- Cachable data plane 2 -> forwarded messages
    noc2_out_data : in  noc_flit_type;
    noc2_out_void : in  std_ulogic;
    noc2_out_stop : out std_ulogic;
    noc2_in_data  : out noc_flit_type;
    noc2_in_void  : out std_ulogic;
    noc2_in_stop  : in  std_ulogic;
    -- Cachable data plane 3 -> response messages
    noc3_out_data : in  noc_flit_type;
    noc3_out_void : in  std_ulogic;
    noc3_out_stop : out std_ulogic;
    noc3_in_data  : out noc_flit_type;
    noc3_in_void  : out std_ulogic;
    noc3_in_stop  : in  std_ulogic;
    -- Non cachable data data plane 4 -> DMA response
    noc4_out_data : in  noc_flit_type;
    noc4_out_void : in  std_ulogic;
    noc4_out_stop : out std_ulogic;
    noc4_in_data  : out noc_flit_type;
    noc4_in_void  : out std_ulogic;
    noc4_in_stop  : in  std_ulogic;
    -- Configuration plane 5 -> RD/WR registers
    noc5_out_data : in  misc_noc_flit_type;
    noc5_out_void : in  std_ulogic;
    noc5_out_stop : out std_ulogic;
    noc5_in_data  : out misc_noc_flit_type;
    noc5_in_void  : out std_ulogic;
    noc5_in_stop  : in  std_ulogic;
    -- Non cachable data data plane 6 -> DMA requests
    noc6_out_data : in  noc_flit_type;
    noc6_out_void : in  std_ulogic;
    noc6_out_stop : out std_ulogic;
    noc6_in_data  : out noc_flit_type;
    noc6_in_void  : out std_ulogic;
    noc6_in_stop  : in  std_ulogic);

end empty_tile_q;

architecture rtl of empty_tile_q is

  signal fifo_rst : std_ulogic;

  -- NoC5->tile
  signal apb_rcv_wrreq     : std_ulogic;
  signal apb_rcv_data_in   : misc_noc_flit_type;
  signal apb_rcv_full      : std_ulogic;
  -- tile->NoC5
  signal apb_snd_rdreq     : std_ulogic;
  signal apb_snd_data_out  : misc_noc_flit_type;
  signal apb_snd_empty     : std_ulogic;


begin  -- rtl

  fifo_rst <= rst;                      --FIFO rst active low

  -- noc1: unused
  noc1_in_data  <= (others => '0');
  noc1_in_void  <= '1';
  noc1_out_stop <= '0';

  -- noc2: unused
  noc2_in_data  <= (others => '0');
  noc2_in_void  <= '1';
  noc2_out_stop <= '0';

  -- to noc3: unused
  noc3_in_data  <= (others => '0');
  noc3_in_void  <= '1';
  noc3_out_stop <= '0';

  -- to noc4: unused
  noc4_in_data  <= (others => '0');
  noc4_in_void  <= '1';
  noc4_out_stop <= '0';

  -- to noc6: unused
  noc6_in_data  <= (others => '0');
  noc6_in_void  <= '1';
  noc6_out_stop <= '0';

  -- From noc5: APB requests
  noc5_out_stop           <= apb_rcv_full and (not noc5_out_void);
  apb_rcv_data_in <= noc5_out_data;
  apb_rcv_wrreq   <= (not noc5_out_void) and (not apb_rcv_full);
  fifo_8 : fifo0
    generic map (
      depth => 5,                       --Header, data up to 4 words
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_rcv_rdreq,
      wrreq    => apb_rcv_wrreq,
      data_in  => apb_rcv_data_in,
      empty    => apb_rcv_empty,
      full     => apb_rcv_full,
      data_out => apb_rcv_data_out);

  -- To noc5: APB response
  noc5_in_data          <= apb_snd_data_out;
  noc5_in_void          <= apb_snd_empty or noc5_in_stop;
  apb_snd_rdreq <= (not apb_snd_empty) and (not noc5_in_stop);
  fifo_11 : fifo0
    generic map (
      depth => 6,                       --Header, address, data (up to 4 words)
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_snd_rdreq,
      wrreq    => apb_snd_wrreq,
      data_in  => apb_snd_data_in,
      empty    => apb_snd_empty,
      full     => apb_snd_full,
      data_out => apb_snd_data_out);

end rtl;
