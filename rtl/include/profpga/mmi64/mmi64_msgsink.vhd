-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2012, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--!  @project      Module Message Interface 64
-- =============================================================================
--!  @file         mmi64_msgsink.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 message parser (simulation only).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mmi64_pkg.all;
use work.txt_util.all;

entity mmi64_msgsink is
  generic (
    sink_id : string := ""
    );
  port (
    -- clock and reset
    mmi64_clk      : in std_ulogic;     --! clock of mmi64 domain
    mmi64_reset    : in std_ulogic;     --! reset of mmi64 domain

    mmi64_d_i      : in  mmi64_data_t;  --! mmi64 data
    mmi64_valid_i  : in  std_ulogic;    --! mmi64 data valid
    mmi64_accept_o : out std_ulogic;    --! mmi64 data accept
    mmi64_start_i  : in  std_ulogic;    --! mmi64 start of message
    mmi64_stop_i   : in  std_ulogic     --! mmi64 end of message
    );
end entity mmi64_msgsink;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! component declaration package for mmi64_msgsink
package mmi64_msgsink_comp is

  --! see description of entity mmi64_msgsink
  component mmi64_msgsink is
    generic (
      sink_id : string := ""
    );
    port (
      -- clock and reset
      mmi64_clk      : in std_ulogic;     --! clock of mmi64 domain
      mmi64_reset    : in std_ulogic;     --! reset of mmi64 domain

      mmi64_d_i      : in  mmi64_data_t;  --! mmi64 data
      mmi64_valid_i  : in  std_ulogic;    --! mmi64 data valid
      mmi64_accept_o : out std_ulogic;    --! mmi64 data accept
      mmi64_start_i  : in  std_ulogic;    --! mmi64 start of message
      mmi64_stop_i   : in  std_ulogic     --! mmi64 end of message
      );
  end component mmi64_msgsink;

end mmi64_msgsink_comp;

--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mmi64_pkg.all;

architecture beh of mmi64_msgsink is
  signal accept : std_ulogic := '1';
begin

  p_msgsink: process (mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      if mmi64_reset = '1' then
      else
        if mmi64_valid_i = '1' and accept = '1' then
          print("sink  " & sink_id & ": " & hstr(std_logic_vector(mmi64_d_i)) & " " & str(mmi64_start_i) & " " & str(mmi64_stop_i) );

          if (mmi64_start_i = '1') then
            if mmi64_header_is_valid(mmi64_d_i) and (mmi64_start_i = '1') then
              print("sink  " & sink_id & ": " & " valid mmi header detected:");
              print("sink  " & sink_id & ": " & "   command           : " & hstr(std_logic_vector(mmi64_command(mmi64_d_i))));
              print("sink  " & sink_id & ": " & "   command parameter : " & hstr(std_logic_vector(mmi64_command_parameter(mmi64_d_i))));
              print("sink  " & sink_id & ": " & "   payload length    : " & hstr(std_logic_vector(mmi64_payload_length(mmi64_d_i))));
              print("sink  " & sink_id & ": " & "   tag               : " & hstr(std_logic_vector(mmi64_tag(mmi64_d_i))));
              print("sink  " & sink_id & ": " & "   checksum          : " & hstr(std_logic_vector(mmi64_checksum(mmi64_d_i))));
            else
              print("sink  " & sink_id & ": " & " invalid mmi header detected!");
            end if;
          end if;
        end if;
      end if;
    end if;
  end process p_msgsink;

  mmi64_accept_o <= accept;

end beh;
