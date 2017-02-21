------------------------------------------------------------------------------
--  Copyright (C) 2015, System Level Design (SLD) group @ Columbia University
-----------------------------------------------------------------------------
-- Package: sldbus
-- File:    sldbus.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description: bus based SoC components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.acctypes.all;

package sldbus is

  component acc_dma2bus
    generic (
      tech               : integer range 0 to NTECH;
      hindex             : integer;
      pindex             : integer;
      paddr              : integer;
      pmask              : integer;
      pirq               : integer;
      memtech            : integer range 0 to NTECH;
      revision           : integer;
      devid              : devid_t;
      available_reg_mask : std_logic_vector(0 to MAXREGNUM-1);
      rdonly_reg_mask    : std_logic_vector(0 to MAXREGNUM-1);
      exp_registers      : integer range 0 to 1;
      scatter_gather     : integer range 0 to 1;
      tlb_entries        : integer);
    port (
      rst           : in  std_ulogic;
      clk           : in  std_ulogic;
      apbi          : in  apb_slv_in_type;
      apbo          : out apb_slv_out_type;
      ahbi          : in  ahb_mst_in_type;
      ahbo          : out ahb_mst_out_type;
      bank          : out bank_type(0 to MAXREGNUM - 1);
      bankdef       : in  bank_type(0 to MAXREGNUM - 1);
      acc_rst       : out std_ulogic;
      conf_done     : out std_ulogic;
      rd_request    : in  std_ulogic;
      rd_index      : in  std_logic_vector(31 downto 0);
      rd_length     : in  std_logic_vector(31 downto 0);
      rd_grant      : out std_ulogic;
      bufdin_ready  : in  std_ulogic;
      bufdin_data   : out std_logic_vector(31 downto 0);
      bufdin_valid  : out std_ulogic;
      wr_request    : in  std_ulogic;
      wr_index      : in  std_logic_vector(31 downto 0);
      wr_length     : in  std_logic_vector(31 downto 0);
      wr_grant      : out std_ulogic;
      bufdout_ready : out std_ulogic;
      bufdout_data  : in  std_logic_vector(31 downto 0);
      bufdout_valid : in  std_ulogic;
      acc_done      : in  std_ulogic);
  end component;

end sldbus;
