library ieee;
use ieee.std_logic_1164.all;

package allslm is

  component slm_bank_1mb_unisim is
    port (
      CLK  : in  std_ulogic;
      CE0  : in  std_ulogic;
      A0   : in  std_logic_vector(16 downto 0);
      D0   : in  std_logic_vector(63 downto 0);
      WE0  : in  std_ulogic;
      WEM0 : in  std_logic_vector(63 downto 0);
      CE1  : in  std_ulogic;
      A1   : in  std_logic_vector(16 downto 0);
      Q1   : out std_logic_vector(63 downto 0));
  end component slm_bank_1mb_unisim;

  component slm_bank_2mb_unisim is
    port (
      CLK  : in  std_ulogic;
      CE0  : in  std_ulogic;
      A0   : in  std_logic_vector(17 downto 0);
      D0   : in  std_logic_vector(63 downto 0);
      WE0  : in  std_ulogic;
      WEM0 : in  std_logic_vector(63 downto 0);
      CE1  : in  std_ulogic;
      A1   : in  std_logic_vector(17 downto 0);
      Q1   : out std_logic_vector(63 downto 0));
  end component slm_bank_2mb_unisim;

  component slm_bank_4mb_unisim is
    port (
      CLK  : in  std_ulogic;
      CE0  : in  std_ulogic;
      A0   : in  std_logic_vector(18 downto 0);
      D0   : in  std_logic_vector(63 downto 0);
      WE0  : in  std_ulogic;
      WEM0 : in  std_logic_vector(63 downto 0);
      CE1  : in  std_ulogic;
      A1   : in  std_logic_vector(18 downto 0);
      Q1   : out std_logic_vector(63 downto 0));
  end component slm_bank_4mb_unisim;

end allslm;
