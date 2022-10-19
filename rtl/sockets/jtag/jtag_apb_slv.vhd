 
-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.esp_acc_regmap.all;
use work.amba.all;

entity jtag_apb_slv is
  generic (
    pindex : integer range 0 to 2 := 0;
    DEF_TMS : std_logic_vector(31 downto 0) := (others=>'0'));
  port(
    clk     : in  std_logic;
    rstn    : in  std_logic;
    pconfig : in  apb_config_type;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    apbreq  : in  std_logic;
    out_p   : out std_logic_vector(31 downto 0));
end jtag_apb_slv;

architecture arch of jtag_apb_slv is

  type state_type is (aread, rst);

  type ctrl_t is record
    state    : state_type;
    write_en : std_logic;
  end record ctrl_t;

  constant CTRL_RESET : ctrl_t := (
    state    => rst,
    write_en => '0'
    );

  signal send_ack : std_logic;
  signal bank_reg : bank_type(0 to 0);
  signal bankin   : bank_type(0 to 0);

  signal r, rin : ctrl_t;
  signal sample : std_logic;

  -- signal addr      : std_logic_vector(6 downto 0);
  signal idx       : integer range 0 to 2;

begin

  apbo.prdata  <= (others => '0');
  apbo.pirq    <= (others => '0');
  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  CU_REG : process(clk, rstn)
  begin
    if rstn = '0' then
      r <= CTRL_RESET;
    elsif clk'event and clk = '1' then
      r <=rin;
    end if;
  end process CU_REG;

  NSL : process(r, bank_reg, sample, rstn, apbreq, apbi)
    variable v : ctrl_t;
  begin

    v          := r;
    v.write_en := '1';

    case r.state is

      when rst =>
        v.write_en := '0';
        if rstn = '1' and apbreq = '1' and apbi.psel(pindex) = '1' then
          v.state := aread;
          v.write_en := '1';
        end if;

      when aread =>
        v.state := rst;

    end case;

    rin <= v;

  end process NSL;

  process(apbi, r.write_en)
  begin
    bankin <= (others => (others => '0'));
    sample <= '0';

    bankin(0) <= apbi.pwdata;
    sample <= apbi.psel(pindex) and apbi.penable and apbi.pwrite and r.write_en;

  end process;

  -- registers
    process (clk, rstn, sample, bankin)
    begin
      if clk'event and clk = '1' then
        if rstn = '0' then
          bank_reg(0) <= DEF_TMS;
        elsif sample = '1' then
          bank_reg(0) <= bankin(0);
        end if;
      end if;
    end process;

  out_p <= bank_reg(0);

end;
