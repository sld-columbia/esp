-- Copyright (c) 2011 CERN
-- SPDX-License-Identifier: LGPL-3.0-only

-------------------------------------------------------------------------------
-- Title      : Parametrizable asynchronous FIFO (Generic version)
-- Project    : Generics RAMs and FIFOs collection
-------------------------------------------------------------------------------
-- File       : generic_async_fifo.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2011-01-25
-- Last update: 2019-04-03
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Dual-clock asynchronous FIFO.
-- - configurable data width and size
-- - configurable full/empty/almost full/almost empty/word count signals
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2011-01-25  1.0      twlostow        Created
-- 2015-01-22  1.0.1    pmantovani      Adapted for ESP NoC (Columbia University)
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.genram_pkg.all;

entity inferred_async_fifo is

  generic (
    g_data_width : natural := 32;
    g_size       : natural := 8
    );

  port (
    -- write port
    rst_wr_n_i   : in std_logic := '1';
    clk_wr_i     : in std_logic;
    we_i         : in std_logic;
    d_i          : in std_logic_vector(g_data_width-1 downto 0);
    wr_full_o    : out std_logic;

    -- read port
    rst_rd_n_i   : in  std_logic := '1';
    clk_rd_i     : in  std_logic;
    rd_i         : in  std_logic;
    q_o          : out std_logic_vector(g_data_width-1 downto 0);
    rd_empty_o   : out std_logic
    );

end inferred_async_fifo;


architecture syn of inferred_async_fifo is

  function f_bin2gray(bin : unsigned) return unsigned is
  begin
    return bin(bin'left) & (bin(bin'left-1 downto 0) xor bin(bin'left downto 1));
  end f_bin2gray;

  function f_gray2bin(gray : unsigned) return unsigned is
    variable bin : unsigned(gray'left downto 0);
  begin
    -- gray to binary
    for i in 0 to gray'left loop
      bin(i) := '0';
      for j in i to gray'left loop
        bin(i) := bin(i) xor gray(j);
      end loop;  -- j
    end loop;  -- i
    return bin;
  end f_gray2bin;

  subtype t_counter is unsigned(f_log2_size(g_size) downto 0);

  type t_counter_block is record
    bin, bin_next, gray, gray_next : t_counter;
    bin_x, gray_x, gray_xm         : t_counter;
  end record;

  type   t_mem_type is array (0 to g_size-1) of std_logic_vector(g_data_width-1 downto 0);
  signal mem : t_mem_type;

  signal rcb, wcb                          : t_counter_block;

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of wcb: signal is "TRUE";
  attribute ASYNC_REG of rcb: signal is "TRUE";

  signal full_int, empty_int               : std_logic;
  signal going_full                        : std_logic;

  signal wr_count, rd_count : t_counter;
  signal rd_int, we_int : std_logic;

--  signal wr_empty_xm, wr_empty_x : std_logic;
--  signal rd_full_xm, rd_full_x   : std_logic;

begin  -- syn

  rd_int <= rd_i and not empty_int;
  we_int <= we_i and not full_int;

  p_mem_write : process(clk_wr_i)
  begin
    if rising_edge(clk_wr_i) then
      if(we_int = '1') then
        mem(to_integer(wcb.bin(wcb.bin'left-1 downto 0))) <= d_i;
      end if;
    end if;
  end process;

  q_o <= mem(to_integer(rcb.bin(rcb.bin'left-1 downto 0)));

  wcb.bin_next  <= wcb.bin + 1;
  wcb.gray_next <= f_bin2gray(wcb.bin_next);

  p_write_ptr : process(clk_wr_i, rst_wr_n_i)
  begin
    if rst_wr_n_i = '0' then
      wcb.bin  <= (others => '0');
      wcb.gray <= (others => '0');
    elsif rising_edge(clk_wr_i) then
      if(we_int = '1') then
        wcb.bin  <= wcb.bin_next;
        wcb.gray <= wcb.gray_next;
      end if;
    end if;
  end process;

  rcb.bin_next  <= rcb.bin + 1;
  rcb.gray_next <= f_bin2gray(rcb.bin_next);

  p_read_ptr : process(clk_rd_i, rst_rd_n_i)
  begin
    if rst_rd_n_i = '0' then
      rcb.bin  <= (others => '0');
      rcb.gray <= (others => '0');
    elsif rising_edge(clk_rd_i) then
      if(rd_int = '1') then
        rcb.bin  <= rcb.bin_next;
        rcb.gray <= rcb.gray_next;
      end if;
    end if;
  end process;

  p_sync_read_ptr : process(clk_wr_i)
  begin
    if rising_edge(clk_wr_i) then
      rcb.gray_xm <= rcb.gray;
      rcb.gray_x  <= rcb.gray_xm;
    end if;
  end process;


  p_sync_write_ptr : process(clk_rd_i)
  begin
    if rising_edge(clk_rd_i) then
      wcb.gray_xm <= wcb.gray;
      wcb.gray_x  <= wcb.gray_xm;
    end if;
  end process;

  wcb.bin_x <= f_gray2bin(wcb.gray_x);
  rcb.bin_x <= f_gray2bin(rcb.gray_x);

  p_gen_empty : process(clk_rd_i, rst_rd_n_i)
  begin
    if rst_rd_n_i = '0' then
      empty_int <= '1';
    elsif rising_edge (clk_rd_i) then
      if(rcb.gray = wcb.gray_x or (rd_int = '1' and (wcb.gray_x = rcb.gray_next))) then
        empty_int <= '1';
      else
        empty_int <= '0';
      end if;
    end if;
  end process;

  rd_empty_o <= empty_int;

--  p_sync_empty : process(clk_wr_i)
--  begin
--    if rising_edge(clk_wr_i) then
--      wr_empty_xm <= empty_int;
--      wr_empty_x  <= wr_empty_xm;
--    end if;
--  end process;

  p_gen_going_full : process(we_int, wcb, rcb)
  begin
    if ((wcb.bin (wcb.bin'left-1 downto 0) = rcb.bin_x(rcb.bin_x'left-1 downto 0))
        and (wcb.bin(wcb.bin'left) /= rcb.bin_x(wcb.bin_x'left))) then
      going_full <= '1';
    elsif (we_int = '1'
           and (wcb.bin_next(wcb.bin'left-1 downto 0) = rcb.bin_x(rcb.bin_x'left-1 downto 0))
           and (wcb.bin_next(wcb.bin'left) /= rcb.bin_x(rcb.bin_x'left))) then
      going_full <= '1';
    else
      going_full <= '0';
    end if;
  end process;

  p_register_full : process(clk_wr_i, rst_wr_n_i)
  begin
    if rst_wr_n_i = '0' then
      full_int <= '0';
    elsif rising_edge (clk_wr_i) then
      full_int <= going_full;
    end if;
  end process;

--  p_sync_full : process(clk_rd_i)
--  begin
--    if rising_edge(clk_rd_i) then
--      rd_full_xm <= full_int;
--      rd_full_x  <= rd_full_xm;
--    end if;
--  end process p_sync_full;

  wr_full_o <= full_int;


end syn;
