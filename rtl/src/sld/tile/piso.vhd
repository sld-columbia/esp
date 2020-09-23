library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity piso is
  generic (
    sz : integer);
  port (
    rst      : in  std_logic;
    clk      : in  std_logic;
    clear    : in  std_logic;
    load     : in  std_logic;
    A        : in  std_logic_vector(sz-1 downto 0);
    B        : out std_logic_vector(sz-1 downto 0);
    shift_en : in  std_logic;
    Y        : out std_logic;
    done     : out std_logic);
end piso;

architecture arch of piso is

  signal sr     : std_logic_vector(sz downto 0);
  constant ZERO : std_logic_vector(sz-1 downto 0) := (others => '0');
  constant D    : std_logic_vector(sz downto 0)   := '1' & ZERO;

begin

  B <= sr(sz downto 1);

  process (clk, rst)
  begin
    -- sr<=(others<='0');
    if rst = '0' then
      sr <= (others => '0');
    elsif clk'event and clk = '1' then
      if clear = '1' then
        sr <= (others => '0');
      elsif load = '1' then
        sr <= A & '1';
      elsif shift_en = '1' then
        sr <= sr(sz-1 downto 0) & '0';
      end if;
    end if;
  end process;

  Y    <= sr(sz);
  done <= '1' when sr = D else '0';
end arch;
