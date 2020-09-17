library ieee;
use ieee.std_logic_1164.all;

entity unread is

  port (
    d_i : in std_ulogic);

end entity unread;


architecture dummy of unread is

  signal B : std_ulogic;

begin  -- architecture dummy

  B <= d_i;

end architecture dummy;
