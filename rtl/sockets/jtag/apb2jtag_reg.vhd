-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.reg_package.all;
use work.esp_acc_regmap.all;
use work.amba.all;

entity apb2jtag_reg is
  generic (
    pindex : integer range 0 to NAPBSLV_FP -1 := 0);
  port(
    clk     : in  std_logic;
    rstn    : in  std_logic;
    pconfig : in  apb_config_type;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    ack_w   : in  std_logic_vector(5 downto 0);
    ack2apb : out std_logic;
    apbreq  : in  std_logic;
    valid   : out std_logic_vector(5 downto 0);
    out_p   : out std_logic_vector(74 downto 0));
end apb2jtag_reg;


architecture arch of apb2jtag_reg is

  type state_type is (aread, flush, rst);

  type ctrl_t is record
    state    : state_type;
    write_en : std_logic;
  end record ctrl_t;

  constant CTRL_RESET : ctrl_t := (
    state    => rst,
    write_en => '0'
    );

  constant ZERO   : std_logic_vector(31 downto 0) := (others => '0');
  signal send_ack : std_logic;
  signal bank_reg : bank_type(0 to 2);
  signal bankin   : bank_type(0 to 2);

  signal r, rin : ctrl_t;
  signal sample : std_logic_vector(2 downto 0);

  signal addr      : std_logic_vector(4 downto 0);
  signal curr_addr : integer range 0 to 17;
  signal idx       : integer range 0 to 2;
  signal DEV_START : integer range 0 to 17;

begin

  apbo.prdata  <= (others => '0');
  apbo.pirq    <= (others => '0');
  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  IDX_WRITE_EN : process(clk, r, rstn, apbi)
  begin
    if rstn = '0' then
      addr <= (others => '0');
    elsif clk'event and clk = '1' and r.write_en = '1' then
      addr <= apbi.paddr(4 downto 0);
    end if;
  end process IDX_WRITE_EN;

  curr_addr <= conv_integer(unsigned(addr));
  idx       <= curr_addr mod 3;
  DEV_START <= curr_addr - (curr_addr mod 3);

  CU_REG : process(clk, rstn)
  begin
    if rstn = '0' then
      r <= CTRL_RESET;
    elsif clk'event and clk = '1' then
      r <=rin;
    end if;
  end process CU_REG;

  NSL : process(r, bank_reg, ack_w, sample, rstn, apbreq, apbi, DEV_START)
    variable v : ctrl_t;
  begin

    v          := r;
    valid      <= (others => '0');
    ack2apb    <= '1';
    v.write_en := '1';

    case r.state is

      when rst =>
        v.write_en := '0';
        if rstn = '1' and apbreq = '1' and apbi.psel(pindex) = '1' then
          v.state := aread;
        end if;


      when aread =>
        if (sample(2) /= '0') then
          v.state := flush;
        end if;

      when flush => v.write_en := '0';
                    if ack_w(DEV_START/3) = '1' then
                      valid(DEV_START/3) <= '1';
                      v.state            := rst;
                    else
                      ack2apb <= '0';
                    end if;

    end case;

    rin <= v;

  end process NSL;

  process(apbi, curr_addr, r.write_en, idx)
  begin
    bankin <= (others => (others => '0'));
    sample <= (others => '0');

    bankin(idx) <= apbi.pwdata;
    sample(idx) <= apbi.psel(pindex) and apbi.penable and apbi.pwrite and r.write_en;

  end process;


  -- registers
  registers : for i in 0 to 2 generate
    process (clk, rstn, sample, bankin)
    begin
      if clk'event and clk = '1' then
        if rstn = '0' then
          bank_reg(i) <= (others => '0');
        elsif sample(i) = '1' then
          bank_reg(i) <= bankin(i);
        end if;
      end if;
    end process;
  end generate registers;

  out_p <= bank_reg(0)(10 downto 0) & bank_reg(1) & bank_reg(2);

end;
