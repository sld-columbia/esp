------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2016, Cobham Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity:      unisim_iddr_reg
-- File:        unisim_iddr_reg.vhd
-- Author:      David Lindh, Jiri Gaisler - Gaisler Research
-- Description: Xilinx DDR input register
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.vcomponents.iddr;
--pragma translate_on

entity unisim_iddr_reg is
  generic (tech : integer := virtex4;arch : integer := 0);
  port(
         Q1 : out std_ulogic;
         Q2 : out std_ulogic;
         C1 : in std_ulogic;
         C2 : in std_ulogic;
         CE : in std_ulogic;
         D : in std_ulogic;
         R : in std_ulogic;
         S : in std_ulogic
      );
end;
  
architecture rtl of unisim_iddr_reg is
    attribute BOX_TYPE : string;
    component IDDR
      generic ( DDR_CLK_EDGE : string := "SAME_EDGE";
          INIT_Q1 : bit := '0';
          INIT_Q2 : bit := '0';
          SRTYPE : string := "ASYNC");
      port
        ( Q1 : out std_ulogic;
          Q2 : out std_ulogic;
          C : in std_ulogic;
          CE : in std_ulogic;
          D : in std_ulogic;
          R : in std_ulogic;
          S : in std_ulogic);
    end component;
    attribute BOX_TYPE of IDDR : component is "PRIMITIVE";

    component IDDR2
  generic
  (
    DDR_ALIGNMENT : string := "NONE";
    INIT_Q0 : bit := '0';
    INIT_Q1 : bit := '0';
    SRTYPE : string := "SYNC"
  );
  port
  (
    Q0 : out std_ulogic;
    Q1 : out std_ulogic;
    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic
  );
    end component;

  signal preQ1, preQ2   : std_ulogic;
  signal D_delay : std_ulogic;
   
begin
     V7 : if (tech = virtex7) or (tech = kintex7) or (tech = artix7) generate
       U0 : IDDR generic map( DDR_CLK_EDGE => "SAME_EDGE")
         Port map( Q1 => Q1, Q2 => Q2, C => C1, CE => CE,
                   D => D, R => R, S => S);
     end generate;

     V4 : if (tech = virtex4) or (tech = virtex5) or (tech = virtex6) or (tech = zynq7000) generate
       U0 : IDDR generic map( DDR_CLK_EDGE => "OPPOSITE_EDGE")
         Port map( Q1 => Q1, Q2 => preQ2, C => C1, CE => CE,
               D => D, R => R,    S => S);

       q3reg : process (C1, preQ2, R)
       begin
          if R='1' then --asynchronous reset, active high
            Q2 <= '0';
          elsif C1'event and C1='1' then --Clock event - posedge
            Q2 <= preQ2;
          end if;
       end process;
     end generate;

     S6 : if (tech = spartan6) generate

       noalign : if arch = 0 generate
         U0 : IDDR2 generic map( DDR_ALIGNMENT => "NONE")
           Port map( Q0 => Q1, Q1 => preQ2, C0 => C1, C1 => C2, CE => CE,
                 D => D, R => R, S => S);
         q3reg : process (C1)
         begin
            if C1'event and C1='1' then --Clock event - posedge
              Q2 <= preQ2;
            end if;
         end process;

       end generate;
       
       align : if arch /= 0 generate
         U0 : IDDR2 generic map( DDR_ALIGNMENT => "C0")
           Port map( Q0 => preQ1, Q1 => Q2, C0 => C1, C1 => C2, CE => CE,
                 D => D, R => R, S => S);
         q3reg : process (C1)
         begin
            if C1'event and C1='1' then --Clock event - posedge
              Q1 <= preQ1;
            end if;
         end process;

       end generate;

     end generate;

    V2 : if tech = virtex2 or tech = spartan3 generate

      -- CE and S inputs inactive for virtex 2
      
      q1reg : process (C1, D, R)
      begin
        if R='1' then --asynchronous reset, active high
          Q1 <= '0';
        elsif C1'event and C1='1' then --Clock event - posedge
          Q1 <= D;
        end if;
      end process;

      q2reg : process (C1, D, R)
      begin
        if R='1' then --asynchronous reset, active high
         preQ2 <= '0';
        elsif C1'event and C1='0' then --Clock event - negedge
         preQ2 <= D;
        end if;
      end process;

      q3reg : process (C1, preQ2, R)
      begin
        if R='1' then --asynchronous reset, active high
          Q2 <= '0';
        elsif C1'event and C1='1' then --Clock event - posedge
          Q2 <= preQ2;
        end if;
      end process;

    end generate;
      
--    S6 : if tech = spartan6 generate
--
--      x0 : IFDDRRSE port map (
--  Q0 => Q1, Q1 => Q2, C0 => C1, C1 => C2, CE => CE,
--  D => D, R => R, S => S);
--
--    end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.vcomponents.oddr;
use unisim.vcomponents.oddr2;
--use unisim.vcomponents.FDDRRSE;
--pragma translate_on

entity unisim_oddr_reg is
  generic (tech : integer := virtex4; arch : integer := 0); 
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end;

architecture rtl of unisim_oddr_reg is
  attribute BOX_TYPE : string;


  component ODDR
    generic
      ( DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
--        INIT : bit := '0';
        SRTYPE : string := "SYNC");
    port
      (
        Q : out std_ulogic;
        C : in std_ulogic;
        CE : in std_ulogic;
        D1 : in std_ulogic;
        D2 : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic
      );
  end component;
  attribute BOX_TYPE of
    ODDR : component is "PRIMITIVE";

  component ODDR2
  generic
  (
    DDR_ALIGNMENT : string := "NONE";
    INIT : bit := '0';
    SRTYPE : string := "ASYNC"
  );
  port
  (
    Q : out std_ulogic;
    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D0 : in std_ulogic;
    D1 : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic
  );
  end component;
  attribute BOX_TYPE of
    ODDR2 : component is "PRIMITIVE";

  component FDDRRSE
--    generic ( INIT : bit := '0');
    port
      (
        Q : out std_ulogic;
        C0 : in std_ulogic;
        C1 : in std_ulogic;
        CE : in std_ulogic;
        D0 : in std_ulogic;
        D1 : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic
      );
  end component;
  attribute BOX_TYPE of
    FDDRRSE : component is "PRIMITIVE";

  signal preD2 : std_ulogic;
  
begin

  V7 : if (tech = virtex7) or (tech = kintex7) or (tech = artix7) generate
     U0 : ODDR generic map( DDR_CLK_EDGE => "SAME_EDGE")
       port map(
         Q => Q, C => C1, CE => CE, D1 => D1,
         D2 => D2, R => R, S => S);
  end generate;

  V4 : if (tech = virtex4) or (tech = virtex5) or (tech = virtex6) or (tech = zynq7000) generate

    d2r : if arch = 0 generate
      d2reg : process (C1, D2, R)
      begin
        if R='1' then --asynchronous reset, active high
          preD2 <= '0';
        elsif C1'event and C1='1' then --Clock event - posedge
          preD2 <= D2;
        end if;
      end process;
    end generate;
    nod2r : if arch /= 0 generate
      preD2 <= D2;
    end generate;
  
     U0 : ODDR generic map( DDR_CLK_EDGE => "OPPOSITE_EDGE" -- ,INIT => '0'
         , SRTYPE => "ASYNC")
       port map(
         Q => Q,
         C => C1,
         CE => CE,
         D1 => D1,
         D2 => preD2,
         R => R,
         S => S);
  end generate;

  V2 : if tech = virtex2 or tech = spartan3 generate

    d2r : if arch = 0 generate
      d2reg : process (C1, D2, R)
      begin
        if R='1' then --asynchronous reset, active high
          preD2 <= '0';
        elsif C1'event and C1='1' then --Clock event - posedge
          preD2 <= D2;
        end if;
      end process;
    end generate;
    nod2r : if arch /= 0 generate
      preD2 <= D2;
    end generate;

      c_dm : component FDDRRSE
--        generic map( INIT => '0')
        port map(
          Q =>  Q,
          D0 => D1,
          D1 => preD2,
          C0 => C1,
          C1 => C2,
          CE => CE,
          R => R,
          S => S);
  end generate;
      

  s6 : if tech = spartan6 generate

    d2r : if arch = 0 generate
      d2reg : process (C1, D2, R)
      begin
        if R='1' then --asynchronous reset, active high
          preD2 <= '0';
        elsif C1'event and C1='1' then --Clock event - posedge
          preD2 <= D2;
        end if;
      end process;
    end generate;
    nod2r : if arch /= 0 generate
      preD2 <= D2;
    end generate;

    c_dm : component ODDR2  
       generic map (
          DDR_ALIGNMENT => "C0",
          SRTYPE        => "ASYNC")
       port map ( 
          Q => Q, 
          C0 => C1, 
          C1 => C2, 
          CE => CE, 
          D0 => D1, 
          D1 => D2, 
          R => R, 
          S => S);
  end generate;


end ;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.vcomponents.fd;
--use unisim.vcomponents.FDDRRSE;
--pragma translate_on

entity oddrv2 is
  generic ( tech : integer := virtex4); 
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end;

architecture rtl of oddrv2 is
  component FD
  generic ( INIT : bit := '0');
  port (  Q : out std_ulogic;
    C : in std_ulogic;
    D : in std_ulogic);
  end component;

  component FDDRRSE
    port
      (
        Q : out std_ulogic;
        C0 : in std_ulogic;
        C1 : in std_ulogic;
        CE : in std_ulogic;
        D0 : in std_ulogic;
        D1 : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic
      );
  end component;

  signal preD2 : std_ulogic;
  
begin

  rf : FD port map ( Q => preD2, C => C1, D => D2);
  rr : FDDRRSE  port map ( Q => Q, C0 => C1, C1 => C2, 
  CE => CE, D0 => D1, D1 => preD2, R => R, S => R);
end;


library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.vcomponents.fd;
use unisim.vcomponents.oddr2;
--pragma translate_on

entity oddrc3e is
  generic ( tech : integer := virtex4); 
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end;

architecture rtl of oddrc3e is
  component FD
  generic ( INIT : bit := '0');
  port (  Q : out std_ulogic;
    C : in std_ulogic;
    D : in std_ulogic);
  end component;

  component ODDR2
  generic
  (
    DDR_ALIGNMENT : string := "NONE";
    INIT : bit := '0';
    SRTYPE : string := "SYNC"
  );
  port
  (
    Q : out std_ulogic;
    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D0 : in std_ulogic;
    D1 : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic
  );
  end component;

  signal preD2 : std_ulogic;
  
begin

  rf : FD port map ( Q => preD2, C => C1, D => D2);
  rr : ODDR2  port map ( Q => Q, C0 => C1, C1 => C2, 
  CE => CE, D0 => D1, D1 => preD2, R => R, S => R);
end;




