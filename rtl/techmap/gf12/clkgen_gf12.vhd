library ieee;
use ieee.std_logic_1164.all;


entity gf12_dco is

  port (
    RSTN     : in  std_ulogic;
    EXT_CLK  : in  std_logic;
    EN       : in  std_ulogic;
    CLK_SEL  : in  std_ulogic;
    CC_SEL   : in  std_logic_vector(5 downto 0);
    FC_SEL   : in  std_logic_vector(5 downto 0);
    DIV_SEL  : in  std_logic_vector(2 downto 0);
    FREQ_SEL : in  std_logic_vector(1 downto 0);
    CLK      : out std_logic;
    CLK_DIV  : out std_logic);

end entity gf12_dco;

architecture rtl of gf12_dco is

  component DCO_GF12_C14 is
    port (
      RSTN     : in  std_ulogic;
      EXT_CLK  : in  std_logic;
      EN       : in  std_ulogic;
      CLK_SEL  : in  std_ulogic;
      CC_SEL   : in  std_logic_vector(5 downto 0);
      FC_SEL   : in  std_logic_vector(5 downto 0);
      DIV_SEL  : in  std_logic_vector(2 downto 0);
      FREQ_SEL : in  std_logic_vector(1 downto 0);
      CLK      : out std_logic;
      CLK_DIV  : out std_logic);
  end component DCO_GF12_C14;

begin  -- architecture rtl

  DCO_GF12_C14_1: DCO_GF12_C14
    port map (
      RSTN     => RSTN,
      EXT_CLK  => EXT_CLK,
      EN       => EN,
      CLK_SEL  => CLK_SEL,
      CC_SEL   => CC_SEL,
      FC_SEL   => FC_SEL,
      DIV_SEL  => DIV_SEL,
      FREQ_SEL => FREQ_SEL,
      CLK      => CLK,
      CLK_DIV  => CLK_DIV);

end architecture rtl;

