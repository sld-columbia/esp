-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package esp_acc_regmap is

  constant MAXREGNUM : integer := 64;
  type bank_type is array (natural range <>) of std_logic_vector(31 downto 0);

  -- bank(0): CMD (reset if cleared)
  constant CMD_REG : integer range 0 to MAXREGNUM - 1:= 0;
  constant CMD_BIT_START : integer range 0 to 31 := 0;
  constant CMD_BIT_LAST  : integer range 0 to 31 := 0;

  -- bank(1): STATUS (idle when cleared) - Read only
  constant STATUS_REG : integer range 0 to MAXREGNUM - 1 := 1;
  constant STATUS_BIT_RUN  : integer range 0 to 31 := 0;
  constant STATUS_BIT_DONE : integer range 0 to 31 := 1;
  constant STATUS_BIT_ERR  : integer range 0 to 31 := 2;
  constant STATUS_BIT_LAST : integer range 0 to 31 := 2;

  -- bank(2)        : SELECT (which accelerator will run in 1 hot encoding)
  constant SELECT_REG : integer range 0 to MAXREGNUM - 1 := 2;

  -- bank(3)        : RESERVED - Read only
  constant DEVID_REG : integer range 0 to MAXREGNUM - 1 := 3;

  -- bank(4)        : PT_ADDRESS (page table bus address)
  constant PT_ADDRESS_REG : integer range 0 to MAXREGNUM - 1 := 4;

  -- bank(5)        : PT_NCHUNK (number of physical contiguous buffers in memory)
  constant PT_NCHUNK_REG : integer range 0 to MAXREGNUM - 1 := 5;

  -- bank(6)        : PT_SHIFT (log2(cunk size))
  constant PT_SHIFT_REG : integer range 0 to MAXREGNUM - 1 := 6;

  -- bank(7)        : PT_NCHUNK_MAX (maximum number of chunks supported) - Read only
  constant PT_NCHUNK_MAX_REG : integer range 0 to MAXREGNUM - 1 := 7;

  -- bank(8)        : PT_ADDRESS_EXTENDED (page table bus address MSBs for
  --                  architectures with more than 32 bits of address)
  constant PT_ADDRESS_EXTENDED_REG : integer range 0 to MAXREGNUM - 1 := 8;

  -- bank(9)        : Type of coherence (None, LLC, Full)
  constant COHERENCE_REG : integer range 0 to MAXREGNUM - 1 := 9;

  -- bank(10)       : P2P_REG (point-to-point configuration)
  -- |31      28|27 25|24 22|21 19|18 16|15 13|12 10|9   7|6   4|3          3|2          2|1       0|
  -- | reserved |  Y  |  X  |  Y  |  X  |  Y  |  X  |  Y  |  X  | DST_IS_P2P | SRC_IS_P2P | NSRCS-1 |
  constant P2P_REG : integer range 0 to MAXREGNUM - 1 := 10;
  constant P2P_BIT_NSRCS : integer range 0 to 31 := 0;
  constant P2P_WIDTH_NSRCS : integer range 0 to 31 := 2;
  constant P2P_BIT_SRC_IS_P2P : integer range 0 to 31 := 2;
  constant P2P_BIT_DST_IS_P2P : integer range 0 to 31 := 3;
  constant P2P_BIT_SRCS_YX : integer range 0 to 31 := 4;

  -- bank(11)       : RESERVED for extra P2P_REG fields if NSRCS > 4
  constant YX_REG  : integer range 0 to MAXREGNUM - 1 := 11;
  constant YX_WIDTH_YX : integer := 16;
  constant YX_BIT_Y : integer range 0 to 31 := 16;
  constant YX_BIT_X : integer range 0 to 31 := 0;

  -- bank(12)       : SRC_OFFSET (offset in bytes from beginning of physical buffer)
  constant SRC_OFFSET_REG : integer range 0 to MAXREGNUM - 1 := 12;

  -- bank(13)       : DST_OFFSET (offset in bytes from beginning of physical buffer)
  constant DST_OFFSET_REG : integer range 0 to MAXREGNUM - 1 := 13;

  -- bank(14)       : SPANDEX_REG
  constant SPANDEX_REG : integer range 0 to MAXREGNUM - 1 := 14;

  -- bank(15)       : RESERVED

  -- bank(16 to 63) : USR (user defined)

  -- Re-enable the following 3 registers if adding an SRAM expanding the register bank
  -- -- bank(29)       : EXP_ADDR (bits 29:0 address an SRAM expanding the register bank)
  -- constant EXP_ADDR_REG : integer range 0 to MAXREGNUM - 1 := 29;
  -- constant EXT_BIT_R : integer range 0 to 31 := 30;
  -- constant EXT_BIT_W : integer range 0 to 31 := 31;

  -- -- bank(30)       : EXP_DI (data to be written to the expansion SRAM)
  -- constant EXP_DI_REG : integer range 0 to MAXREGNUM - 1 := 30;

  -- -- bank(31)       : EXP_DO (data read from the exansion SRAM)
  -- constant EXP_DO_REG : integer range 0 to MAXREGNUM - 1 := 31;

  -- Helper functions
  constant zero : std_logic_vector(31 downto 0) := (others => '0');
  constant one : std_logic_vector(31 downto 0) := x"00000001";
  constant fff : std_logic_vector(31 downto 0) := x"ffffffff";

  function right_shift (
    signal in_vect : std_logic_vector(31 downto 0);
    signal amount  : std_logic_vector(4 downto 0))
    return std_logic_vector;

  function left_shift (
    signal in_vect : std_logic_vector(31 downto 0);
    signal amount  : std_logic_vector(4 downto 0))
    return std_logic_vector;

end esp_acc_regmap;

package body esp_acc_regmap is

  function right_shift (
    signal in_vect : std_logic_vector(31 downto 0);
    signal amount  : std_logic_vector(4 downto 0))
    return std_logic_vector is
    variable after16  : std_logic_vector(31 downto 0);
    variable after8   : std_logic_vector(31 downto 0);
    variable after4   : std_logic_vector(31 downto 0);
    variable after2   : std_logic_vector(31 downto 0);
    variable after1   : std_logic_vector(31 downto 0);
  begin -- right_shift
    if amount(4) = '1' then
      after16 := zero(15 downto 0) & in_vect(31 downto 16);
    else
      after16 := in_vect;
    end if;
    if amount(3) = '1' then
      after8 := zero(7 downto 0) & after16(31 downto 8);
    else
      after8 := after16;
    end if;
    if amount(2) = '1' then
      after4 := zero(3 downto 0) & after8(31 downto 4);
    else
      after4 := after8;
    end if;
    if amount(1) = '1' then
      after2 := "00" & after4(31 downto 2);
    else
      after2 := after4;
    end if;
    if amount(0) = '1' then
      after1 := "0" & after2(31 downto 1);
    else
      after1 := after2;
    end if;
    return after1;
  end right_shift;

  function left_shift (
    signal in_vect    : std_logic_vector(31 downto 0);
    signal amount     : std_logic_vector(4 downto 0))
    return std_logic_vector is
    variable after16  : std_logic_vector(31 downto 0);
    variable after8   : std_logic_vector(31 downto 0);
    variable after4   : std_logic_vector(31 downto 0);
    variable after2   : std_logic_vector(31 downto 0);
    variable after1   : std_logic_vector(31 downto 0);
  begin
    if amount(4) = '1' then
      after16 :=  in_vect(15 downto 0) & zero(15 downto 0);
    else
      after16 := in_vect;
    end if;
    if amount(3) = '1' then
      after8 := after16(23 downto 0) & zero(7 downto 0);
    else
      after8 := after16;
    end if;
    if amount(2) = '1' then
      after4 := after8(27 downto 0) & zero(3 downto 0);
    else
      after4 := after8;
    end if;
    if amount(1) = '1' then
      after2 := after4(29 downto 0) & "00";
    else
      after2 := after4;
    end if;
    if amount(0) = '1' then
      after1 := after2(30 downto 0) & "0";
    else
      after1 := after2;
    end if;
    return after1;
  end left_shift;

end esp_acc_regmap;
