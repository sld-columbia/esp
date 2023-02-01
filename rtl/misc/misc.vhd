-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.gencomp.all;

package misc is

  type attribute_vector is array (natural range <>) of integer;

  component esp_init is
    generic (
      hindex        : integer;
      sequence      : attribute_vector(0 to CFG_TILES_NUM + CFG_NCPU_TILE - 1);
      srst_sequence : attribute_vector(0 to CFG_NMEM_TILE + CFG_NCPU_TILE - 1));
    port (
      rstn      : in  std_ulogic;
      clk       : in  std_ulogic;
      noinit    : in  std_ulogic;
      srst      : in  std_ulogic;
      init_done : out std_ulogic;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type);
  end component esp_init;

  component esplink is
    generic (
      APB_DW     : integer;
      APB_AW     : integer;
      REV_ENDIAN : integer range 0 to 1);
    port (
      clk     : in  std_ulogic;
      rstn    : in  std_ulogic;
      srst    : out std_ulogic;
      psel    : in  std_ulogic;
      penable : in  std_ulogic;
      pwrite  : in  std_ulogic;
      paddr   : in  std_logic_vector(APB_AW - 1 downto 0);
      pwdata  : in  std_logic_vector(APB_DW - 1 downto 0);
      pready  : out std_ulogic;
      pslverr : out std_ulogic;
      prdata  : out std_logic_vector(APB_DW - 1 downto 0));
  end component esplink;

  component unread is
    port (
      d_i : in std_ulogic);
  end component unread;

  component rstgen
  generic (acthigh : integer := 0; syncrst : integer := 0;
	   scanen : integer := 0; syncin  : integer := 0);
  port (
    rstin     : in  std_ulogic;
    clk       : in  std_ulogic;
    clklock   : in  std_ulogic;
    rstout    : out std_ulogic;
    rstoutraw : out std_ulogic;
    testrst   : in  std_ulogic := '0';
    testen    : in  std_ulogic := '0');
  end component;

  component ahbram
  generic (
    hindex  : integer := 0;
    tech    : integer := DEFMEMTECH;
    large_banks : integer := 0;
    kbytes  : integer := 1;
    pipe    : integer := 0;
    maccsz  : integer := AHBDW;
    scantest: integer := 0);
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    haddr  : in  integer range 0 to 4095;
    hmask  : in  integer range 0 to 4095;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type);
  end component;

  component ahbram_dp is
    generic (
      hindex1 : integer;
      haddr1  : integer;
      hindex2 : integer;
      haddr2  : integer;
      hmask   : integer;
      tech    : integer;
      kbytes  : integer;
      wordsz  : integer);
    port (
      rst    : in  std_ulogic;
      clk    : in  std_ulogic;
      ahbsi1 : in  ahb_slv_in_type;
      ahbso1 : out ahb_slv_out_type;
      ahbsi2 : in  ahb_slv_in_type;
      ahbso2 : out ahb_slv_out_type);
  end component ahbram_dp;

  component ahbslm is
    generic (
      SIMULATION : boolean;
      hindex     : integer;
      tech       : integer;
      kbytes     : integer);
    port (
      rst   : in  std_ulogic;
      clk   : in  std_ulogic;
      haddr : in  integer range 0 to 4095;
      hmask : in  integer range 0 to 4095;
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type);
  end component ahbslm;

end;
