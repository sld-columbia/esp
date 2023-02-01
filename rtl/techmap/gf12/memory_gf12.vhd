-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0



-------------------------------------------------------------------------------
-- Single port memory

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;

entity gf12_syncram is
  generic (abits : integer := 9; dbits : integer := 32);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in  std_ulogic;
    write   : in  std_ulogic
    );
end;

architecture rtl of gf12_syncram is

  component generic_syncram
    generic (abits : integer := 10; dbits : integer := 8);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector((abits -1) downto 0);
      datain  : in  std_logic_vector((dbits -1) downto 0);
      dataout : out std_logic_vector((dbits -1) downto 0);
      write   : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_256x8_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(7 downto 0);
    D0   : in  std_logic_vector(7 downto 0);
    Q0   : out std_logic_vector(7 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(7 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_256x16_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(7 downto 0);
    D0   : in  std_logic_vector(15 downto 0);
    Q0   : out std_logic_vector(15 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(15 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_256x32_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(7 downto 0);
    D0   : in  std_logic_vector(31 downto 0);
    Q0   : out std_logic_vector(31 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(31 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_256x64_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(7 downto 0);
    D0   : in  std_logic_vector(63 downto 0);
    Q0   : out std_logic_vector(63 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(63 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_512x8_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(8 downto 0);
    D0   : in  std_logic_vector(7 downto 0);
    Q0   : out std_logic_vector(7 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(7 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_512x16_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(8 downto 0);
    D0   : in  std_logic_vector(15 downto 0);
    Q0   : out std_logic_vector(15 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(15 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_512x32_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(8 downto 0);
    D0   : in  std_logic_vector(31 downto 0);
    Q0   : out std_logic_vector(31 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(31 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_512x64_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(8 downto 0);
    D0   : in  std_logic_vector(63 downto 0);
    Q0   : out std_logic_vector(63 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(63 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_1024x8_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(9 downto 0);
    D0   : in  std_logic_vector(7 downto 0);
    Q0   : out std_logic_vector(7 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(7 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_1024x16_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(9 downto 0);
    D0   : in  std_logic_vector(15 downto 0);
    Q0   : out std_logic_vector(15 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(15 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_1024x32_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(9 downto 0);
    D0   : in  std_logic_vector(31 downto 0);
    Q0   : out std_logic_vector(31 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(31 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_1024x64_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(9 downto 0);
    D0   : in  std_logic_vector(63 downto 0);
    Q0   : out std_logic_vector(63 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(63 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_2048x8_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(10 downto 0);
    D0   : in  std_logic_vector(7 downto 0);
    Q0   : out std_logic_vector(7 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(7 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_2048x8
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(10 downto 0);
    D0   : in  std_logic_vector(7 downto 0);
    Q0   : out std_logic_vector(7 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(7 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_2048x16_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(10 downto 0);
    D0   : in  std_logic_vector(15 downto 0);
    Q0   : out std_logic_vector(15 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(15 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_2048x32_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(10 downto 0);
    D0   : in  std_logic_vector(31 downto 0);
    Q0   : out std_logic_vector(31 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(31 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_2048x64_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(10 downto 0);
    D0   : in  std_logic_vector(63 downto 0);
    Q0   : out std_logic_vector(63 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(63 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_4096x8_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(11 downto 0);
    D0   : in  std_logic_vector(7 downto 0);
    Q0   : out std_logic_vector(7 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(7 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_4096x16_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(11 downto 0);
    D0   : in  std_logic_vector(15 downto 0);
    Q0   : out std_logic_vector(15 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(15 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_4096x32_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(11 downto 0);
    D0   : in  std_logic_vector(31 downto 0);
    Q0   : out std_logic_vector(31 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(31 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_4096x64_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(11 downto 0);
    D0   : in  std_logic_vector(63 downto 0);
    Q0   : out std_logic_vector(63 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(63 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_8192x8_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(12 downto 0);
    D0   : in  std_logic_vector(7 downto 0);
    Q0   : out std_logic_vector(7 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(7 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_8192x16_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(12 downto 0);
    D0   : in  std_logic_vector(15 downto 0);
    Q0   : out std_logic_vector(15 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(15 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_8192x32_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(12 downto 0);
    D0   : in  std_logic_vector(31 downto 0);
    Q0   : out std_logic_vector(31 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(31 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_8192x64_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(12 downto 0);
    D0   : in  std_logic_vector(63 downto 0);
    Q0   : out std_logic_vector(63 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(63 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_16384x8_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(13 downto 0);
    D0   : in  std_logic_vector(7 downto 0);
    Q0   : out std_logic_vector(7 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(7 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_16384x16_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(13 downto 0);
    D0   : in  std_logic_vector(15 downto 0);
    Q0   : out std_logic_vector(15 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(15 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_16384x32_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(13 downto 0);
    D0   : in  std_logic_vector(31 downto 0);
    Q0   : out std_logic_vector(31 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(31 downto 0);
    CE0  : in  std_ulogic);
  end component;

  component GF12_SRAM_SP_16384x64_PG
  port (
    CLK  : in  std_ulogic;
    A0   : in  std_logic_vector(13 downto 0);
    D0   : in  std_logic_vector(63 downto 0);
    Q0   : out std_logic_vector(63 downto 0);
    WE0  : in  std_ulogic;
    WEM0 : in  std_logic_vector(63 downto 0);
    CE0  : in  std_ulogic);
  end component;

  signal do, di : std_logic_vector(63 downto 0);
  signal xa     : std_logic_vector(13 downto 0);

  -- Replace GF12 16kx8 memory with 8 2kx8 banks
  signal mux_sel : std_logic_vector(2 downto 0);
  signal enable_int : std_logic_vector(7 downto 0);
  type bank_out_type is array (0 to 7) of std_logic_vector(7 downto 0);
  signal do_int : bank_out_type;

begin

  dataout                <= do(dbits - 1 downto 0);
  di(dbits - 1 downto 0) <= datain;
  di_narrow_gen: if dbits < 64 generate
    di(63 downto dbits)  <= (others => '0');
  end generate di_narrow_gen;
  xa(abits - 1 downto 0) <= address;
  xa_narrow_gen: if abits < 14 generate
    xa(13 downto abits)  <= (others => '0');
  end generate xa_narrow_gen;

   a0 : if (abits < 8) generate
    s : generic_syncram
      generic map (
        abits => abits,
        dbits => dbits)
      port map (
        clk     => clk,
        address => address,
        datain  => datain,
        dataout => do(dbits - 1 downto 0),
        write   => write);
    do(63 downto dbits) <= (others => '0');
  end generate;

  a8 : if abits = 8 generate
    d8 : if dbits = 8 generate
      s : GF12_SRAM_SP_256x8_PG
        port map (
          CLK  => clk,
          A0   => xa(7 downto 0),
          D0   => di(7 downto 0),
          Q0   => do(7 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 8) <= (others => '0');
    end generate d8;

    d16 : if dbits = 16 generate
      s : GF12_SRAM_SP_256x16_PG
        port map (
          CLK  => clk,
          A0   => xa(7 downto 0),
          D0   => di(15 downto 0),
          Q0   => do(15 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 16) <= (others => '0');
    end generate d16;

    d32 : if dbits = 32 generate
      s : GF12_SRAM_SP_256x32_PG
        port map (
          CLK  => clk,
          A0   => xa(7 downto 0),
          D0   => di(31 downto 0),
          Q0   => do(31 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 32) <= (others => '0');
    end generate d32;

    d64 : if dbits = 64 generate
      s : GF12_SRAM_SP_256x64_PG
        port map (
          CLK  => clk,
          A0   => xa(7 downto 0),
          D0   => di(63 downto 0),
          Q0   => do(63 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
    end generate d64;

  end generate a8;

  a9 : if abits = 9 generate
    d8 : if dbits = 8 generate
      s : GF12_SRAM_SP_512x8_PG
        port map (
          CLK  => clk,
          A0   => xa(8 downto 0),
          D0   => di(7 downto 0),
          Q0   => do(7 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 8) <= (others => '0');
    end generate d8;

    d16 : if dbits = 16 generate
      s : GF12_SRAM_SP_512x16_PG
        port map (
          CLK  => clk,
          A0   => xa(8 downto 0),
          D0   => di(15 downto 0),
          Q0   => do(15 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 16) <= (others => '0');
    end generate d16;

    d32 : if dbits = 32 generate
      s : GF12_SRAM_SP_512x32_PG
        port map (
          CLK  => clk,
          A0   => xa(8 downto 0),
          D0   => di(31 downto 0),
          Q0   => do(31 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 32) <= (others => '0');
    end generate d32;

    d64 : if dbits = 64 generate
      s : GF12_SRAM_SP_512x64_PG
        port map (
          CLK  => clk,
          A0   => xa(8 downto 0),
          D0   => di(63 downto 0),
          Q0   => do(63 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
    end generate d64;

  end generate a9;

  a10 : if abits = 10 generate
    d8 : if dbits = 8 generate
      s : GF12_SRAM_SP_1024x8_PG
        port map (
          CLK  => clk,
          A0   => xa(9 downto 0),
          D0   => di(7 downto 0),
          Q0   => do(7 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 8) <= (others => '0');
    end generate d8;

    d16 : if dbits = 16 generate
      s : GF12_SRAM_SP_1024x16_PG
        port map (
          CLK  => clk,
          A0   => xa(9 downto 0),
          D0   => di(15 downto 0),
          Q0   => do(15 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 16) <= (others => '0');
    end generate d16;

    d32 : if dbits = 32 generate
      s : GF12_SRAM_SP_1024x32_PG
        port map (
          CLK  => clk,
          A0   => xa(9 downto 0),
          D0   => di(31 downto 0),
          Q0   => do(31 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 32) <= (others => '0');
    end generate d32;

    d64 : if dbits = 64 generate
      s : GF12_SRAM_SP_1024x64_PG
        port map (
          CLK  => clk,
          A0   => xa(9 downto 0),
          D0   => di(63 downto 0),
          Q0   => do(63 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
    end generate d64;

  end generate a10;

  a11 : if abits = 11 generate
    d8 : if dbits = 8 generate
      s : GF12_SRAM_SP_2048x8_PG
        port map (
          CLK  => clk,
          A0   => xa(10 downto 0),
          D0   => di(7 downto 0),
          Q0   => do(7 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 8) <= (others => '0');
    end generate d8;

    d16 : if dbits = 16 generate
      s : GF12_SRAM_SP_2048x16_PG
        port map (
          CLK  => clk,
          A0   => xa(10 downto 0),
          D0   => di(15 downto 0),
          Q0   => do(15 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 16) <= (others => '0');
    end generate d16;

    d32 : if dbits = 32 generate
      s : GF12_SRAM_SP_2048x32_PG
        port map (
          CLK  => clk,
          A0   => xa(10 downto 0),
          D0   => di(31 downto 0),
          Q0   => do(31 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 32) <= (others => '0');
    end generate d32;

    d64 : if dbits = 64 generate
      s : GF12_SRAM_SP_2048x64_PG
        port map (
          CLK  => clk,
          A0   => xa(10 downto 0),
          D0   => di(63 downto 0),
          Q0   => do(63 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
    end generate d64;

  end generate a11;

  a12 : if abits = 12 generate
    d8 : if dbits = 8 generate
      s : GF12_SRAM_SP_4096x8_PG
        port map (
          CLK  => clk,
          A0   => xa(11 downto 0),
          D0   => di(7 downto 0),
          Q0   => do(7 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 8) <= (others => '0');
    end generate d8;

    d16 : if dbits = 16 generate
      s : GF12_SRAM_SP_4096x16_PG
        port map (
          CLK  => clk,
          A0   => xa(11 downto 0),
          D0   => di(15 downto 0),
          Q0   => do(15 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 16) <= (others => '0');
    end generate d16;

    d32 : if dbits = 32 generate
      s : GF12_SRAM_SP_4096x32_PG
        port map (
          CLK  => clk,
          A0   => xa(11 downto 0),
          D0   => di(31 downto 0),
          Q0   => do(31 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 32) <= (others => '0');
    end generate d32;

    d64 : if dbits = 64 generate
      s : GF12_SRAM_SP_4096x64_PG
        port map (
          CLK  => clk,
          A0   => xa(11 downto 0),
          D0   => di(63 downto 0),
          Q0   => do(63 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
    end generate d64;

  end generate a12;

  a13 : if abits = 13 generate
    d8 : if dbits = 8 generate
      s : GF12_SRAM_SP_8192x8_PG
        port map (
          CLK  => clk,
          A0   => xa(12 downto 0),
          D0   => di(7 downto 0),
          Q0   => do(7 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 8) <= (others => '0');
    end generate d8;

    d16 : if dbits = 16 generate
      s : GF12_SRAM_SP_8192x16_PG
        port map (
          CLK  => clk,
          A0   => xa(12 downto 0),
          D0   => di(15 downto 0),
          Q0   => do(15 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 16) <= (others => '0');
    end generate d16;

    d32 : if dbits = 32 generate
      s : GF12_SRAM_SP_8192x32_PG
        port map (
          CLK  => clk,
          A0   => xa(12 downto 0),
          D0   => di(31 downto 0),
          Q0   => do(31 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 32) <= (others => '0');
    end generate d32;

    d64 : if dbits = 64 generate
      s : GF12_SRAM_SP_8192x64_PG
        port map (
          CLK  => clk,
          A0   => xa(12 downto 0),
          D0   => di(63 downto 0),
          Q0   => do(63 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
    end generate d64;

  end generate a13;

  a14 : if abits = 14 generate
    d8 : if dbits = 8 generate
      -- Bank chip enable
      process (xa, enable) is
      begin  -- process
        enable_int <= (others => '0');
        case xa(13 downto 11) is
          when "000" => enable_int(0) <= enable;
          when "001" => enable_int(1) <= enable;
          when "010" => enable_int(2) <= enable;
          when "011" => enable_int(3) <= enable;
          when "100" => enable_int(4) <= enable;
          when "101" => enable_int(5) <= enable;
          when "110" => enable_int(6) <= enable;
          when "111" => enable_int(7) <= enable;
          when others => null;
        end case;
      end process;

      -- Output
      process (clk) is
      begin
        if clk'event and clk = '1' then  -- rising clock edge
          mux_sel <= xa(13 downto 11);
        end if;
      end process;

      process (mux_sel, do_int) is
      begin  -- process
        case mux_sel is
          when "000" => do(7 downto 0) <= do_int(0);
          when "001" => do(7 downto 0) <= do_int(1);
          when "010" => do(7 downto 0) <= do_int(2);
          when "011" => do(7 downto 0) <= do_int(3);
          when "100" => do(7 downto 0) <= do_int(4);
          when "101" => do(7 downto 0) <= do_int(5);
          when "110" => do(7 downto 0) <= do_int(6);
          when "111" => do(7 downto 0) <= do_int(7);
          when others => do(7 downto 0) <= do_int(0);
        end case;
      end process;
      do(63 downto 8) <= (others => '0');

      -- banks
      b8: for b in 0 to 7 generate
        s : GF12_SRAM_SP_2048x8
          port map (
            CLK  => clk,
            A0   => xa(10 downto 0),
            D0   => di(7 downto 0),
            Q0   => do_int(b),
            WE0  => write,
            WEM0 => (others => '1'),
            CE0  => enable_int(b));
      end generate b8;
    end generate d8;

    d16 : if dbits = 16 generate
      s : GF12_SRAM_SP_16384x16_PG
        port map (
          CLK  => clk,
          A0   => xa(13 downto 0),
          D0   => di(15 downto 0),
          Q0   => do(15 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 16) <= (others => '0');
    end generate d16;

    d32 : if dbits = 32 generate
      s : GF12_SRAM_SP_16384x32_PG
        port map (
          CLK  => clk,
          A0   => xa(13 downto 0),
          D0   => di(31 downto 0),
          Q0   => do(31 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
      do(63 downto 32) <= (others => '0');
    end generate d32;

    d64 : if dbits = 64 generate
      s : GF12_SRAM_SP_16384x64_PG
        port map (
          CLK  => clk,
          A0   => xa(13 downto 0),
          D0   => di(63 downto 0),
          Q0   => do(63 downto 0),
          WE0  => write,
          WEM0 => (others => '1'),
          CE0  => enable);
    end generate d64;

  end generate a14;

-- pragma translate_off
 a_to_high : if abits > 14 generate
   x : process
   begin
     assert false
     report  "Address depth larger than 14 not supported for gf12_syncram"
     severity failure;
     wait;
   end process;
 end generate;
 d_to_high : if dbits > 64 generate
   x : process
   begin
     assert false
     report  "Data width larger than 64 not supported for gf12_syncram"
     severity failure;
     wait;
   end process;
 end generate;
-- pragma translate_on

end;



-------------------------------------------------------------------------------
-- 2-port memory

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.stdlib.all;
-- pragma translate_off
use work.sim.all;
use std.textio.all;
use work.stdio.all;
-- pragma translate_on

entity gf12_syncram_2p is
  generic (abits  : integer := 6; dbits : integer := 8);
  port (
    rclk     : in  std_ulogic;
    renable  : in  std_ulogic;
    raddress : in  std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in  std_ulogic;
    write    : in  std_ulogic;
    waddress : in  std_logic_vector((abits -1) downto 0);
    datain   : in  std_logic_vector((dbits -1) downto 0));
end;

architecture behav of gf12_syncram_2p is

  component generic_syncram_2p
    generic (abits  : integer := 8; dbits : integer := 32);
    port (
      rclk      : in  std_ulogic;
      wclk      : in  std_ulogic;
      rdaddress : in  std_logic_vector (abits -1 downto 0);
      wraddress : in  std_logic_vector (abits -1 downto 0);
      data      : in  std_logic_vector (dbits -1 downto 0);
      wren      : in  std_ulogic;
      q         : out std_logic_vector (dbits -1 downto 0)
      );
  end component;

  component GF12_RF_2P_4096x16
  port (
    CLK0 : in  std_ulogic;
    A0   : in  std_logic_vector(11 downto 0);
    Q0   : out std_logic_vector(15 downto 0);
    CE0  : in  std_ulogic;
    CLK1 : in  std_ulogic;
    A1   : in  std_logic_vector(11 downto 0);
    D1   : in  std_logic_vector(15 downto 0);
    WE1  : in  std_ulogic;
    WEM1 : in  std_logic_vector(15 downto 0);
    CE1  : in  std_ulogic);
  end component;

  component GF12_RF_2P_256x32
  port (
    CLK0 : in  std_ulogic;
    A0   : in  std_logic_vector(7 downto 0);
    Q0   : out std_logic_vector(31 downto 0);
    CE0  : in  std_ulogic;
    CLK1 : in  std_ulogic;
    A1   : in  std_logic_vector(7 downto 0);
    D1   : in  std_logic_vector(31 downto 0);
    WE1  : in  std_ulogic;
    WEM1 : in  std_logic_vector(31 downto 0);
    CE1  : in  std_ulogic);
  end component;

  signal do : std_logic_vector(63 downto 0);
  signal di : std_logic_vector(63 downto 0);
  signal wxa, rxa : std_logic_vector(13 downto 0);

begin

  dataout                <= do(dbits - 1 downto 0);
  di(dbits - 1 downto 0) <= datain;
  di_narrow_gen: if dbits < 64 generate
    di(63 downto dbits)  <= (others => '0');
  end generate di_narrow_gen;
  rxa(abits - 1 downto 0) <= raddress;
  wxa(abits - 1 downto 0) <= waddress;
  xa_narrow_gen: if abits < 14 generate
    rxa(13 downto abits) <= (others => '0');
    wxa(13 downto abits) <= (others => '0');
  end generate xa_narrow_gen;

  small2p : if abits <= 5 generate
    s : generic_syncram_2p generic map (abits, dbits)
      port map (rclk, wclk, rxa(abits - 1 downto 0), wxa(abits - 1 downto 0), di(dbits - 1 downto 0), write, do(dbits - 1 downto 0));
  end generate;

  a12d16: if abits = 12 and dbits = 16 generate
    s: GF12_RF_2P_4096x16
      port map (
        CLK0 => rclk,
        A0   => rxa(11 downto 0),
        Q0   => do(15 downto 0),
        CE0  => renable,
        CLK1 => wclk,
        A1   => wxa(11 downto 0),
        D1   => di(15 downto 0),
        WE1  => write,
        WEM1 => (others => '1'),
        CE1  => write);
  end generate a12d16;

  a8d32: if abits = 8 and dbits = 32 generate
    s: GF12_RF_2P_256x32
      port map (
        CLK0 => rclk,
        A0   => rxa(7 downto 0),
        Q0   => do(31 downto 0),
        CE0  => renable,
        CLK1 => wclk,
        A1   => wxa(7 downto 0),
        D1   => di(31 downto 0),
        WE1  => write,
        WEM1 => (others => '1'),
        CE1  => write);
  end generate a8d32;

-- pragma translate_off
 bank_not_available : if not ((abits = 12 and dbits = 16) or
                              (abits = 8  and dbits = 32) or
                              abits <= 5) generate
   x : process
   begin
     assert false
     report  "Requested dual-port memory " & tost(2**12) & "x" & tost(dbits) & " is not available for GF12"
     severity failure;
     wait;
   end process;
 end generate;
-- pragma translate_on

end;


-------------------------
-- gf12_syncram with byte enable

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.config_types.all;
use work.config.all;

entity gf12_syncram_be is
  generic ( abits : integer := 17; dbits : integer := 64);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_logic_vector (dbits/8-1 downto 0);
    write   : in std_logic_vector(dbits/8-1 downto 0)
  );
end;

architecture behav of gf12_syncram_be is


  component gf12_sram64_be_13abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(12 downto 0);
      D0  : in std_logic_vector(63 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(63 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(12 downto 0);
      Q1  : out std_logic_vector(63 downto 0)
      );
  end component gf12_sram64_be_13abits;

  component gf12_sram64_be_14abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(13 downto 0);
      D0  : in std_logic_vector(63 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(63 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(13 downto 0);
      Q1  : out std_logic_vector(63 downto 0)
      );
  end component gf12_sram64_be_14abits;

  component gf12_sram64_be_15abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(14 downto 0);
      D0  : in std_logic_vector(63 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(63 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(14 downto 0);
      Q1  : out std_logic_vector(63 downto 0)
      );
  end component gf12_sram64_be_15abits;

  component gf12_sram64_be_16abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(15 downto 0);
      D0  : in std_logic_vector(63 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(63 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(15 downto 0);
      Q1  : out std_logic_vector(63 downto 0)
      );
  end component gf12_sram64_be_16abits;

  component gf12_sram64_be_17abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(16 downto 0);
      D0  : in std_logic_vector(63 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(63 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(16 downto 0);
      Q1  : out std_logic_vector(63 downto 0)
      );
  end component gf12_sram64_be_17abits;

  component gf12_sram64_be_18abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(17 downto 0);
      D0  : in std_logic_vector(63 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(63 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(17 downto 0);
      Q1  : out std_logic_vector(63 downto 0)
      );
  end component gf12_sram64_be_18abits;

  component gf12_sram64_be_19abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(18 downto 0);
      D0  : in std_logic_vector(63 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(63 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(18 downto 0);
      Q1  : out std_logic_vector(63 downto 0)
      );
  end component gf12_sram64_be_19abits;

  component gf12_sram64_be_20abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(19 downto 0);
      D0  : in std_logic_vector(63 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(63 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(19 downto 0);
      Q1  : out std_logic_vector(63 downto 0)
      );
  end component gf12_sram64_be_20abits;

signal gnd : std_ulogic;
signal do, di : std_logic_vector(dbits+8 downto 0);
signal xa : std_logic_vector(19 downto 0);
signal xenable : std_logic;
signal xrden : std_logic;
signal xwren : std_logic;
signal xwmsk : std_logic_vector(dbits-1 downto 0);
constant zeroen : std_logic_vector(dbits/8-1 downto 0) := (others => '0');

begin
  gnd <= '0';
  dataout <= do(dbits-1 downto 0);
  di(dbits-1 downto 0) <= datain;
  di(dbits+8 downto dbits) <= (others => '0');

  xa(19 downto abits) <= (others => '0');
  xa(abits-1 downto 0) <= address;

  wmask_gen : for i in 0 to ((dbits-1)/8) generate
    wmask_bit_gen: for j in 0 to 7 generate
      xwmsk(i*8+j) <= write(i);
    end generate wmask_bit_gen;
  end generate;

  xenable <= '1' when enable /= zeroen else '0';
  xrden <= xenable when write  = zeroen else '0';
  xwren <= xenable when write /= zeroen else '0';

  a13 : if abits = 13 generate
    r0 : gf12_sram64_be_13abits
      port map (
        CLK  => clk,
        CE0  => xenable,
        A0   => xa(12 downto 0),
        D0   => di(dbits-1 downto 0),
        WE0  => xwren,
        WEM0 => xwmsk,
        CE1  => xrden,
        A1   => xa(12 downto 0),
        Q1   => do(dbits-1 downto 0));
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a14 : if abits = 14 generate
    r0 : gf12_sram64_be_14abits
      port map (
        CLK  => clk,
        CE0  => xenable,
        A0   => xa(13 downto 0),
        D0   => di(dbits-1 downto 0),
        WE0  => xwren,
        WEM0 => xwmsk,
        CE1  => xrden,
        A1   => xa(13 downto 0),
        Q1   => do(dbits-1 downto 0));
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a15 : if abits = 15 generate
    r0 : gf12_sram64_be_15abits
      port map (
        CLK  => clk,
        CE0  => xenable,
        A0   => xa(14 downto 0),
        D0   => di(dbits-1 downto 0),
        WE0  => xwren,
        WEM0 => xwmsk,
        CE1  => xrden,
        A1   => xa(14 downto 0),
        Q1   => do(dbits-1 downto 0));
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a16 : if abits = 16 generate
    r0 : gf12_sram64_be_16abits
      port map (
        CLK  => clk,
        CE0  => xenable,
        A0   => xa(15 downto 0),
        D0   => di(dbits-1 downto 0),
        WE0  => xwren,
        WEM0 => xwmsk,
        CE1  => xrden,
        A1   => xa(15 downto 0),
        Q1   => do(dbits-1 downto 0));
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a17 : if abits = 17 generate
    r0 : gf12_sram64_be_17abits
      port map (
        CLK  => clk,
        CE0  => xenable,
        A0   => xa(16 downto 0),
        D0   => di(dbits-1 downto 0),
        WE0  => xwren,
        WEM0 => xwmsk,
        CE1  => xrden,
        A1   => xa(16 downto 0),
        Q1   => do(dbits-1 downto 0));
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a18 : if abits = 18 generate
    r0 : gf12_sram64_be_18abits
      port map (
        CLK  => clk,
        CE0  => xenable,
        A0   => xa(17 downto 0),
        D0   => di(dbits-1 downto 0),
        WE0  => xwren,
        WEM0 => xwmsk,
        CE1  => xrden,
        A1   => xa(17 downto 0),
        Q1   => do(dbits-1 downto 0));
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a19 : if abits = 19 generate
    r0 : gf12_sram64_be_19abits
      port map (
        CLK  => clk,
        CE0  => xenable,
        A0   => xa(18 downto 0),
        D0   => di(dbits-1 downto 0),
        WE0  => xwren,
        WEM0 => xwmsk,
        CE1  => xrden,
        A1   => xa(18 downto 0),
        Q1   => do(dbits-1 downto 0));
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a20 : if abits = 20 generate
    r0 : gf12_sram64_be_20abits
      port map (
        CLK  => clk,
        CE0  => xenable,
        A0   => xa(19 downto 0),
        D0   => di(dbits-1 downto 0),
        WE0  => xwren,
        WEM0 => xwmsk,
        CE1  => xrden,
        A1   => xa(19 downto 0),
        Q1   => do(dbits-1 downto 0));
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  -- pragma translate_off
  a_to_high : if abits < 13 or abits > 20 or dbits /= 64 generate
    x : process
    begin
      assert false
        report  "Data width must be 64 and address width must be between 13 and 20 gf12_syncram_be"
        severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end;
