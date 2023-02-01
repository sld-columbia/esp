-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.esp_acc_regmap.all;
use work.amba.all;

entity jtag2apb_reg is
  generic (
    pindex : integer range 0 to 1 := 0);
  port(
    clk     : in  std_logic;
    rstn    : in  std_logic;
    pconfig : in  apb_config_type;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    fifo_c  : in  std_logic_vector(5 downto 0);
    req     : out std_logic_vector(5 downto 0);
    ack2apb : out std_logic;
    apbreq  : in  std_logic;
    in_p    : in  std_logic_vector(95 downto 0));
end jtag2apb_reg;


architecture arch of jtag2apb_reg is

  -- APB Interface

  -- type state_type is (start, idle, read1);
  type state_type is (idle, read1);

  type ctrl_t is record
    state : state_type;
    free  : std_logic_vector(5 downto 0);
  end record ctrl_t;

  constant CTRL_RESET : ctrl_t := (
    state => idle,
    free  => (others => '1')
    );


  signal bank_reg, bankin : bank_type(0 to 2);

  signal readd                         : std_logic_vector(17 downto 0);
  signal req_fifo, sendin, free, free1 : std_logic_vector(5 downto 0);
  signal readdata                      : std_logic_vector(31 downto 0);

  signal r, rin : ctrl_t;

  signal write_en, read_en : std_logic;
  signal addr              : std_logic_vector(6 downto 0);
  signal DEV_START         : integer range 0 to 5;
  signal idx               : integer range 0 to 2;


  attribute mark_debug : string;

  attribute mark_debug of bank_reg : signal is "true";
  attribute mark_debug of addr : signal is "true";
  attribute mark_debug of idx : signal is "true";
  attribute mark_debug of DEV_START : signal is "true";
  attribute mark_debug of r : signal is "true";
  attribute mark_debug of sendin : signal is "true";
  attribute mark_debug of bankin : signal is "true";

begin

  apbo.prdata  <= readdata;
  apbo.pirq    <= (others => '0');
  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  ack2apb <= '1';

  IDX_UPDATE : process(apbi)
  begin
    if apbi.paddr(8) = '1' then
      addr <= apbi.paddr(6 downto 0);
    else
      addr <= (others => '0');
    end if;
  end process IDX_UPDATE;

  idx       <= conv_integer(unsigned(addr(3 downto 2)));
  DEV_START <= conv_integer(unsigned(addr(6 downto 4)));

  CU_REG : process(clk, rstn)
  begin
    if rstn = '0' then
      r <= CTRL_RESET;
    elsif clk'event and clk = '1' then
      r <=rin;
    end if;
  end process CU_REG;

  sendin <= fifo_c and r.free;

  NSL : process(r, DEV_START, readd, sendin, idx, rstn, apbi)
    variable v : ctrl_t;
  begin

    v        := r;
    req_fifo <= (others => '0');
    write_en <= '0';
    read_en  <= '0';

    case r.state is

      -- when start =>
      --   if rstn = '1' then
      --     v.state := idle;
      --   end if;

      when read1 => read_en <= '1';
                    if readd(2) /= '0' then
                      v.free(DEV_START) := '1';
                      v.state             := idle;
                    end if;


      when idle =>
        if (apbi.psel(pindex) = '1' and r.free(DEV_START) = '0' and idx = 0) then
          v.state := read1;
        elsif sendin(0) = '1' then
          req_fifo <= "100000";
          write_en <= '1';
          -- v.state  := start;
          read_en  <= '0';
          v.free(0):='0';
        elsif sendin(1) = '1' then
          req_fifo <= "010000";
          write_en <= '1';
          -- v.state  := start;
          read_en  <= '0';
          v.free(1):='0';
        elsif sendin(2) = '1' then
          req_fifo <= "001000";
          write_en <= '1';
          -- v.state  := start;
          v.free(2):='0';
          read_en  <= '0';
        elsif sendin(3) = '1' then
          req_fifo <= "000100";
          write_en <= '1';
          -- v.state  := start;
          v.free(3):='0';
          read_en  <= '0';
        elsif sendin(4) = '1' then
          req_fifo <= "000010";
          write_en <= '1';
          -- v.state  := start;
          v.free(4):='0';
          read_en  <= '0';
        elsif sendin(5) = '1' then
          req_fifo <= "000001";
          write_en <= '1';
          -- v.state  := start;
          v.free(5):='0';
          read_en  <= '0';
        end if;

      -- when write1 => v.state := start;
      --                v.free(DEV_START) := '0';

    end case;

    rin <= v;

  end process NSL;

  req <= req_fifo;

  READ_PROC : process (apbi, bank_reg, idx, read_en, r, DEV_START)

  begin

    readdata <= (others => '0');
    readd    <= (others => '0');

    if (apbi.psel(pindex) = '1' and apbi.penable = '1' and r.free(DEV_START)='0' and apbi.pwrite='0' and read_en='1') then

      readd(idx) <= '1';
      readdata   <= bank_reg(idx);
    end if;

  end process READ_PROC;


  process(in_p, rstn)
  begin

    if rstn = '0' then
      bankin <= (others => (others => '0'));
    else
      bankin(0) <= in_p(31 downto 0);
      bankin(1) <= in_p(63 downto 32);
      bankin(2) <= in_p(95 downto 64);
    end if;
  end process;


  registers : process (clk, rstn)
  begin
    if clk'event and clk = '1' then
      if rstn = '0' then
        bank_reg <= (others => (others => '0'));
      elsif write_en = '1' then
        bank_reg(0) <= bankin(0);
        bank_reg(1) <= bankin(1);
        bank_reg(2) <= bankin(2);
      end if;
    end if;
  end process registers;


end;
