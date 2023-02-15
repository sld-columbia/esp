-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.ariane_esp_pkg.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.jtag_pkg.all;



entity jtag_test is
  generic (
    test_if_en : integer range 0 to 1 := 0);
  port (
    rst                 : in std_ulogic;
    refclk              : in std_ulogic;
    tile_rst            : in std_ulogic;
    tdi                 : in  std_ulogic;
    tdo                 : out std_ulogic;
    tms                 : in  std_ulogic;
    tclk                : in  std_ulogic;
    -- NoC out to Test/TileQ in
    noc1_output_port    : in  noc_flit_type;
    noc1_data_void_out  : in  std_ulogic;
    noc1_stop_in        : out std_ulogic;
    noc2_output_port    : in  noc_flit_type;
    noc2_data_void_out  : in  std_ulogic;
    noc2_stop_in        : out std_ulogic;
    noc3_output_port    : in  noc_flit_type;
    noc3_data_void_out  : in  std_ulogic;
    noc3_stop_in        : out std_ulogic;
    noc4_output_port    : in  noc_flit_type;
    noc4_data_void_out  : in  std_ulogic;
    noc4_stop_in        : out std_ulogic;
    noc5_output_port    : in  misc_noc_flit_type;
    noc5_data_void_out  : in  std_ulogic;
    noc5_stop_in        : out std_ulogic;
    noc6_output_port    : in  noc_flit_type;
    noc6_data_void_out  : in  std_ulogic;
    noc6_stop_in        : out std_ulogic;
    -- Test/NoC out to TileQ in
    test1_output_port   : out noc_flit_type;
    test1_data_void_out : out std_ulogic;
    test1_stop_in       : in  std_ulogic;
    test2_output_port   : out noc_flit_type;
    test2_data_void_out : out std_ulogic;
    test2_stop_in       : in  std_ulogic;
    test3_output_port   : out noc_flit_type;
    test3_data_void_out : out std_ulogic;
    test3_stop_in       : in  std_ulogic;
    test4_output_port   : out noc_flit_type;
    test4_data_void_out : out std_ulogic;
    test4_stop_in       : in  std_ulogic;
    test5_output_port   : out misc_noc_flit_type;
    test5_data_void_out : out std_ulogic;
    test5_stop_in       : in  std_ulogic;
    test6_output_port   : out noc_flit_type;
    test6_data_void_out : out std_ulogic;
    test6_stop_in       : in  std_ulogic;
    -- TileQ out to Test/NoC in
    test1_input_port    : in  noc_flit_type;
    test1_data_void_in  : in  std_ulogic;
    test1_stop_out      : out std_ulogic;
    test2_input_port    : in  noc_flit_type;
    test2_data_void_in  : in  std_ulogic;
    test2_stop_out      : out std_ulogic;
    test3_input_port    : in  noc_flit_type;
    test3_data_void_in  : in  std_ulogic;
    test3_stop_out      : out std_ulogic;
    test4_input_port    : in  noc_flit_type;
    test4_data_void_in  : in  std_ulogic;
    test4_stop_out      : out std_ulogic;
    test5_input_port    : in  misc_noc_flit_type;
    test5_data_void_in  : in  std_ulogic;
    test5_stop_out      : out std_ulogic;
    test6_input_port    : in  noc_flit_type;
    test6_data_void_in  : in  std_ulogic;
    test6_stop_out      : out std_ulogic;
    -- Test/TileQ out to NoC in
    noc1_input_port     : out noc_flit_type;
    noc1_data_void_in   : out std_ulogic;
    noc1_stop_out       : in  std_ulogic;
    noc2_input_port     : out noc_flit_type;
    noc2_data_void_in   : out std_ulogic;
    noc2_stop_out       : in  std_ulogic;
    noc3_input_port     : out noc_flit_type;
    noc3_data_void_in   : out std_ulogic;
    noc3_stop_out       : in  std_ulogic;
    noc4_input_port     : out noc_flit_type;
    noc4_data_void_in   : out std_ulogic;
    noc4_stop_out       : in  std_ulogic;
    noc5_input_port     : out misc_noc_flit_type;
    noc5_data_void_in   : out std_ulogic;
    noc5_stop_out       : in  std_ulogic;
    noc6_input_port     : out noc_flit_type;
    noc6_data_void_in   : out std_ulogic;
    noc6_stop_out       : in  std_ulogic);

end;


architecture rtl of jtag_test is

  type jtag_state_type is (rti, inject1, inject2, inject3,
                           inject4, inject5, inject6, extract,
                           read_and_check, request_instr,sw_plane,
                           waitforvoid1, waitforvoid2, waitforvoid3,
                           waitforvoid4, waitforvoid5, waitforvoid6);

  type jtag_ctrl_t is record
    state       : jtag_state_type;
    demux_sel   : std_logic_vector(5 downto 0);
    compare     : std_logic_vector(5 downto 0);
    sipo_clear  : std_ulogic;
    piso_load0  : std_ulogic;
    piso_en     : std_ulogic;
    piso_en0    : std_ulogic;
    piso_clear  : std_ulogic;
    piso_clear0 : std_ulogic;
    skip        : std_ulogic;
    lastwrite   : std_ulogic;
    rd_i_out    : std_logic_vector(1 to 6);
  end record jtag_ctrl_t;

  constant JTAG_CTRL_RESET : jtag_ctrl_t := (
    state       => rti,
    demux_sel   => (others => '0'),
    compare     => (others => '0'),
    sipo_clear  => '0',
    piso_load0  => '0',
    piso_en     => '0',
    piso_en0    => '0',
    piso_clear  => '0',
    piso_clear0 => '0',
    skip        => '0',
    lastwrite   => '0',
    rd_i_out    => (others => '0')
    );

  type tms_sync_type is record
    async : std_ulogic;
    sync  : std_ulogic;
  end record tms_sync_type;
  signal tms_int : tms_sync_type;

  attribute ASYNC_REG            : string;
  attribute ASYNC_REG of tms_int : signal is "TRUE";

  signal r, rin : jtag_ctrl_t;

  -- signal tclk_int  : std_ulogic ;

  -- Main FSM output signals
  signal tdo_data     : std_ulogic;
  signal tdo_data0    : std_ulogic;
  signal sipo_done    : std_ulogic;
  signal piso_load    : std_ulogic;
  signal piso_done    : std_ulogic;
  signal piso_done0   : std_ulogic;
  signal skipwait     : std_ulogic;
  signal sipo_en_in   : std_ulogic;
  signal sipo_en_i    : std_logic_vector(1 to 6);
  signal op_i         : std_logic_vector(1 to 6);  -- maybe unused
  signal sipo_done_i  : std_logic_vector(1 to 6);
  signal sipo_clear_i : std_logic_vector(1 to 6);
  signal tdi_i        : std_logic_vector(1 to 6);

  --signals for logic JTAG->CPU
  signal rd_i            : std_logic_vector(1 to 6);
  signal we_in           : std_logic_vector(1 to 6);
  signal fwd_wr_full_o   : std_logic_vector(1 to 6);
  signal end_trace       : std_logic_vector(1 to 6);
  signal fwd_rd_empty_o1 : std_ulogic;
  signal fwd_rd_empty_o2 : std_ulogic;
  signal fwd_rd_empty_o3 : std_ulogic;
  signal fwd_rd_empty_o4 : std_ulogic;
  signal fwd_rd_empty_o5 : std_ulogic;
  signal fwd_rd_empty_o6 : std_ulogic;

  type test_vect is array(1 to 6) of noc_flit_type;
  signal test_in, test_in_sync : test_vect;

  signal sipo_comp         : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal test_comp, sipo_c : std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
  signal mismatch_detected : std_ulogic;
  signal data              : std_logic_vector(NOC_FLIT_SIZE+7 downto 0);
  type t_comp is array (1 to 6) of std_logic_vector(NOC_FLIT_SIZE+8 downto 0);
  signal sipo_comp_i       : t_comp;

  signal source_compare : std_logic_vector(6 downto 0);
  signal test_out       : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal piso_in        : std_logic_vector(NOC_FLIT_SIZE+7 downto 0);
  signal piso0_in       : std_logic_vector(7 downto 0);

  --signals for logic CPU->JTAG
  signal A, B, C, D, E, F : std_logic_vector(NOC_FLIT_SIZE downto 0);

  signal test1_out, t1_out      : noc_flit_type;
  signal test1_cpu_data_void_in : std_ulogic;
  signal test1_cpu_stop_out     : std_ulogic;
  signal t1_cpu_data_void_in    : std_ulogic;

  signal test2_out, t2_out      : noc_flit_type;
  signal test2_cpu_data_void_in : std_ulogic;
  signal test2_cpu_stop_out     : std_ulogic;
  signal t2_cpu_data_void_in    : std_ulogic;

  signal test3_out, t3_out      : noc_flit_type;
  signal test3_cpu_data_void_in : std_ulogic;
  signal test3_cpu_stop_out     : std_ulogic;
  signal t3_cpu_data_void_in    : std_ulogic;

  signal test4_out, t4_out      : noc_flit_type;
  signal test4_cpu_data_void_in : std_ulogic;
  signal test4_cpu_stop_out     : std_ulogic;
  signal t4_cpu_data_void_in    : std_ulogic;

  signal test6_out, t6_out      : noc_flit_type;
  signal test6_cpu_data_void_in : std_ulogic;
  signal test6_cpu_stop_out     : std_ulogic;
  signal t6_cpu_data_void_in    : std_ulogic;

  signal test5_out, t5_out      : misc_noc_flit_type;
  signal test5_cpu_data_void_in : std_ulogic;
  signal test5_cpu_stop_out     : std_ulogic;
  signal t5_cpu_data_void_in    : std_ulogic;

  signal rd_i_out : std_logic_vector(1 to 6);
  signal we_in_out : std_logic_vector(1 to 6);

  signal fwd_rd_empty_o5out : std_ulogic;
  signal fwd_wr_full_o5out  : std_ulogic;

  attribute keep : boolean;
  -- attribute keep of tclk_int : signal is true;

  attribute mark_debug : string;

  attribute mark_debug of r : signal is "true";
  attribute mark_debug of tdo_data : signal is "true";
  attribute mark_debug of tdo_data0 : signal is "true";
  attribute mark_debug of sipo_done : signal is "true";
  attribute mark_debug of piso_load : signal is "true";
  attribute mark_debug of piso_done : signal is "true";
  attribute mark_debug of piso_done0 : signal is "true";
  attribute mark_debug of sipo_en_in : signal is "true";
  attribute mark_debug of sipo_en_i : signal is "true";
  attribute mark_debug of op_i : signal is "true";
  attribute mark_debug of sipo_done_i : signal is "true";
  attribute mark_debug of sipo_clear_i : signal is "true";
  attribute mark_debug of tdi_i : signal is "true";
  attribute mark_debug of rd_i : signal is "true";
  attribute mark_debug of we_in : signal is "true";
  attribute mark_debug of fwd_wr_full_o : signal is "true";
  attribute mark_debug of end_trace : signal is "true";
  attribute mark_debug of sipo_comp : signal is "true";
  attribute mark_debug of test_comp : signal is "true";
  attribute mark_debug of sipo_c : signal is "true";
  attribute mark_debug of mismatch_detected : signal is "true";
  attribute mark_debug of sipo_comp_i : signal is "true";
  attribute mark_debug of test_out : signal is "true";
  attribute mark_debug of piso_in : signal is "true";
  attribute mark_debug of piso0_in : signal is "true";
  attribute mark_debug of tms_int : signal is "true";
  -- attribute mark_debug of tms : signal is "true";
  -- attribute mark_debug of tclk : signal is "true";
  -- attribute mark_debug of tclk_int : signal is "true";


begin


  test_if_gen : if test_if_en /= 0 generate

    -- jtag_fsm
    CU_REG : process (tclk, rst)
    begin
      if rst = '0' then
        r <= JTAG_CTRL_RESET;
      elsif tclk'event and tclk = '1' then
        r <= rin;
      end if;
    end process CU_REG;

    NSL : process(r, sipo_done, sipo_done_i,
                  piso_done, piso_done0,
                  tms, sipo_comp, sipo_comp_i,
                  end_trace, op_i,
                  test1_cpu_data_void_in,
                  test2_cpu_data_void_in,
                  test3_cpu_data_void_in,
                  test4_cpu_data_void_in,
                  test5_cpu_data_void_in,
                  test6_cpu_data_void_in,
                  fwd_wr_full_o)

      variable v : jtag_ctrl_t;
    begin
      -- Default assignments
      v        := r;
      --
      rd_i_out <= (others => '0');
      we_in    <= (others => '0');

      piso_load  <= '0';
      sipo_en_in <= '0';

      case r.state is

        when rti =>
          if tms = '1' then
            v.state := waitforvoid5;
          end if;

        when request_instr => v.piso_load0 := '0';
                              we_in        <= (others => '0');
                              v.piso_en0   := '1';
                              v.sipo_clear := '1';
                              if piso_done0 = '1' then
                                v.sipo_clear := '0';
                                case r.compare is
                                  when "100000" => v.state := inject1;
                                  when "010000" => v.state := inject2;
                                  when "001000" => v.state := inject3;
                                  when "000100" => v.state := inject4;
                                  when "000010" => v.state := inject5;
                                  when "000001" => v.state := inject6;
                                  when others   => null;
                                end case;
                              end if;



        when inject1 => v.piso_en0 := '0';
                        v.demux_sel := "100000";
                        sipo_en_in  <= '1';

                        if sipo_done_i(1) = '1' then
                          sipo_en_in <= '0';
                          v.state    := waitforvoid1;
                        end if;



        when inject2 => v.piso_en0 := '0';
                        v.demux_sel := "010000";
                        sipo_en_in  <= '1';
                        if sipo_done_i(2) = '1' then
                          sipo_en_in <= '0';
                          v.state    := waitforvoid2;
                        end if;


        when inject3 => v.piso_en0 := '0';
                        v.demux_sel := "001000";
                        sipo_en_in  <= '1';
                        if sipo_done_i(3) = '1' then
                          sipo_en_in <= '0';
                          v.state    := waitforvoid3;
                        end if;


        when inject4 => v.piso_en0 := '0';
                        v.demux_sel := "000100";
                        sipo_en_in  <= '1';
                        if sipo_done_i(4) = '1' then
                          sipo_en_in <= '0';
                          v.state    := waitforvoid4;
                        end if;


        when inject5 => v.piso_en0 := '0';
                        v.demux_sel := "000010";
                        sipo_en_in  <= '1';
                        if sipo_done_i(5) = '1' then
                          sipo_en_in <= '0';
                          v.state    := waitforvoid5;
                        end if;


        when inject6 => v.piso_en0 := '0';
                        v.demux_sel := "000001";
                        sipo_en_in  <= '1';
                        if sipo_done_i(6) = '1' then
                          sipo_en_in <= '0';
                          v.state    := waitforvoid6;
                        end if;

        when sw_plane =>
          case r.compare is
            when "100000" => v.compare := "010000" ;
            when "010000" => v.compare := "001000" ;
            when "001000" => v.compare := "000100" ;
            when "000100" => v.compare := "000010" ;
            when "000010" => v.compare := "000001" ;
            when "000001" => v.compare := "100000" ;
            when others => null;
          end case;
          v.state :=request_instr;
          v.piso_load0 := '1';


        when waitforvoid1 =>
          if sipo_done_i(1) = '1' then
            if sipo_comp_i(1)(2)='1' then       -- if "not yet" instruction go to
                                                -- next plane 
              if sipo_comp_i(2)(2)='1' then
                v.state :=request_instr;
                v.compare :="010000";
                v.piso_load0 := '1';
              else
                v.state :=waitforvoid2;
              end if;
            else
              if op_i(1) = '0' then                   -- instr is a wait
                if test1_cpu_data_void_in = '0' then  -- check queue
                  v.compare := "100000";
                  v.state   := read_and_check;
                else                                  --plane not manageable
                  v.state := waitforvoid2;
                end if;
              else                                    -- instr is a write
                if fwd_wr_full_o(1) = '0' then        -- check queue
                  v.sipo_clear  := '1';
                  we_in(1)     <= '1';
                  if sipo_comp_i(2)(2)='1' then
                    v.state :=sw_plane;               -- go to next plane after
                                                      -- writing
                  else
                    v.state :=waitforvoid2;
                  end if;
                else                      --plane not manageable
                  v.state := waitforvoid2;
                end if;
              end if;
            end if;
          else                          -- register still empty
            v.state      := request_instr;
            v.compare    := "100000";
            v.piso_load0 := '1';
          end if;

        when waitforvoid2 =>
          if sipo_done_i(2) = '1' then
            if sipo_comp_i(2)(2)='1' then
              if sipo_comp_i(3)(2)='1' then
                v.state :=request_instr;
                v.compare :="001000";
                v.piso_load0 := '1';
              else
                v.state :=waitforvoid3;
              end if;
            else
              if op_i(2) = '0' then                   -- instr is a wait
                if test2_cpu_data_void_in = '0' then  -- check queue
                  v.compare := "010000";
                  v.state   := read_and_check;
                else                                  --plane not manageable
                  v.state := waitforvoid3;
                end if;
              else                                    -- instr is a write
                if fwd_wr_full_o(2) = '0' then        -- check queue
                  v.sipo_clear  := '1';
                  we_in(2)      <= '1';
                  if sipo_comp_i(3)(2)='1' then
                    v.state :=sw_plane;
                  else
                    v.state :=waitforvoid3;
                  end if;
                else                      --plane not manageable
                  v.state := waitforvoid3;
                end if;
              end if;
            end if;
          else                          -- register still empty

            v.state      := request_instr;
            v.compare    := "010000";
            v.piso_load0 := '1';
          end if;

        when waitforvoid3 =>
          if sipo_done_i(3) = '1' then
            if sipo_comp_i(3)(2)='1' then
              if sipo_comp_i(4)(2)='1' then
                v.state :=request_instr;
                v.compare :="000100";
                v.piso_load0 := '1';
              else
                v.state :=waitforvoid4;
              end if;
            else
              if op_i(3) = '0' then                   -- instr is a wait
                if test3_cpu_data_void_in = '0' then  -- check queue
                  v.compare := "001000";
                  v.state   := read_and_check;
                else                                  --plane not manageable
                  v.state := waitforvoid4;
                end if;
              else                                    -- instr is a write
                if fwd_wr_full_o(3) = '0' then        -- check queue
                  v.sipo_clear  := '1';
                  we_in(3)      <= '1';
                  if sipo_comp_i(4)(2)='1' then
                    v.state :=sw_plane;
                  else
                    v.state :=waitforvoid4;
                  end if;
                else                      --plane not manageable
                  v.state := waitforvoid4;
                end if;
              end if;
            end if;
          else                          -- register still empty
            v.state      := request_instr;
            v.compare    := "001000";
            v.piso_load0 := '1';
          end if;

        when waitforvoid4 =>
          if sipo_done_i(4) = '1' then
            if sipo_comp_i(4)(2)='1' then
              if sipo_comp_i(5)(2)='1' then
                v.state :=request_instr;
                v.compare :="000010";
                v.piso_load0 := '1';
              else
                v.state :=waitforvoid5;
              end if;
            else
              if op_i(4) = '0' then                   -- instr is a wait
                if test4_cpu_data_void_in = '0' then  -- check queue
                  v.compare := "000100";
                  v.state   := read_and_check;
                else                                  --plane not manageable
                  v.state := waitforvoid5;
                end if;
              else                                    -- instr is a write
                if fwd_wr_full_o(1) = '0' then        -- check queue
                  v.sipo_clear  := '1';
                  we_in(4)      <= '1';
                  if sipo_comp_i(5)(2)='1' then
                    v.state :=sw_plane;
                  else
                    v.state :=waitforvoid5;
                  end if;
                else                      --plane not manageable
                  v.state := waitforvoid5;
                end if;
              end if;
            end if;
          else                          -- register still empty
            v.state      := request_instr;
            v.compare    := "000100";
            v.piso_load0 := '1';
          end if;

        when waitforvoid5 =>
          if sipo_done_i(5) = '1' then
            if sipo_comp_i(5)(2)='1' then
              if sipo_comp_i(6)(2)='1' then
                v.state :=request_instr;
                v.compare :="000001";
                v.piso_load0 := '1';
              else
                v.state :=waitforvoid6;
              end if;
            else
              if op_i(5) = '0' then                   -- instr is a wait
                if test5_cpu_data_void_in = '0' then  -- check queue
                  v.compare := "000010";
                  v.state   := read_and_check;
                else                                  --plane not manageable
                  v.state := waitforvoid6;
                end if;
              else                                    -- instr is a write
                if fwd_wr_full_o(5) = '0' then        -- check queue
                  v.sipo_clear  := '1';
                  we_in(5)      <= '1';
                  v.compare :="000010";
                  v.piso_load0 := '1';
                  v.state:=request_instr;
                else                      --plane not manageable
                  v.state := waitforvoid6;
                end if;
              end if;
            end if;
          else                          -- register still empty
            v.state      := request_instr;
            v.compare    := "000010";
            v.piso_load0 := '1';
          end if;

        when waitforvoid6 =>
          if sipo_done_i(6) = '1' then
            if sipo_comp_i(6)(2)='1' then
              if sipo_comp_i(1)(2)='1' then
                v.state :=request_instr;
                v.compare :="100000";
                v.piso_load0 := '1';
              else
                v.state :=waitforvoid1;
              end if;
            else
              if op_i(6) = '0' then                   -- instr is a wait
                if test6_cpu_data_void_in = '0' then  -- check queue
                  v.compare := "000001";
                  v.state   := read_and_check;
                else                                  --plane not manageable
                  v.state := waitforvoid1;
                end if;
              else                                    -- instr is a write
                if fwd_wr_full_o(6) = '0' then        -- check queue
                  v.sipo_clear  := '1';
                  we_in(6)      <= '1';
                  if sipo_comp_i(1)(2)='1' then
                    v.state :=sw_plane;
                  else
                    v.state :=waitforvoid1;
                  end if;
                else                      --plane not manageable
                  v.state := waitforvoid1;
                end if;
              end if;
            end if;
          else                          -- register still empty
            v.piso_load0 := '1';
            v.state      := request_instr;
            v.compare    := "000001";
          end if;

        when read_and_check =>
          case r.compare is
            when "100000" =>
              rd_i_out(1) <= '1';
            when "010000" =>
              rd_i_out(2) <= '1';
            when "001000" =>
              rd_i_out(3) <= '1';
            when "000100" =>
              rd_i_out(4) <= '1';
            when "000010" =>
              rd_i_out(5) <= '1';
            when "000001" =>
              rd_i_out(6) <= '1';
            when others   => null;
          end case;
          piso_load  <= '1';
          v.state    := extract;
          v.piso_en  := '1';
          v.sipo_clear :='1';

        when extract => piso_load <= '0';
                        rd_i_out <= (others => '0');
                        if piso_done = '1' then
                          case r.compare is
                            when "100000" =>
                              v.compare :="010000";
                            when "010000" =>
                              v.compare :="001000";
                            when "001000" =>
                              v.compare :="000100";
                            when "000100" =>
                              v.compare :="000010";
                            when "000010" =>
                              v.compare :="000001";
                            when "000001" =>
                              v.compare :="100000";
                            when others   => null;
                          end case;
                          v.state      := request_instr;
                          v.piso_load0 := '1';
                          v.sipo_clear := '0';
                          v.piso_en    := '0';
                        end if;

      end case;

      rin <= v;

    end process NSL;


    process(r.compare, sipo_done_i)
    begin
      case r.compare is
        when "100000" => sipo_done <= sipo_done_i(1);
        when "010000" => sipo_done <= sipo_done_i(2);
        when "001000" => sipo_done <= sipo_done_i(3);
        when "000100" => sipo_done <= sipo_done_i(4);
        when "000010" => sipo_done <= sipo_done_i(5);
        when "000001" => sipo_done <= sipo_done_i(6);
        when others   => sipo_done <= '0';
      end case;

    end process;


    -- Enable serial-in-parallel-out register to get next instruction from trace

    process(sipo_en_in, r.compare)
    begin
      sipo_en_i    <= (others => '0');
      if sipo_en_in = '1' then
        case r.compare is
          when "100000" => sipo_en_i(1) <= '1';
          when "010000" => sipo_en_i(2) <= '1';
          when "001000" => sipo_en_i(3) <= '1';
          when "000100" => sipo_en_i(4) <= '1';
          when "000010" => sipo_en_i(5) <= '1';
          when "000001" => sipo_en_i(6) <= '1';
          when others   => sipo_en_i    <= (others => '0');
        end case;
      end if;
    end process;

    process(r.sipo_clear, r.compare)
    begin
      sipo_clear_i <= (others => '0');
      if r.sipo_clear = '1' then
        case r.compare is
          when "100000" => sipo_clear_i(1) <= '1';
          when "010000" => sipo_clear_i(2) <= '1';
          when "001000" => sipo_clear_i(3) <= '1';
          when "000100" => sipo_clear_i(4) <= '1';
          when "000010" => sipo_clear_i(5) <= '1';
          when "000001" => sipo_clear_i(6) <= '1';
          when others   => sipo_clear_i    <= (others => '0');
        end case;
      end if;
    end process;

    GEN_SIPO : for i in 1 to 6 generate

      sipo_i : sipo_jtag
        generic map (DIM => NOC_FLIT_SIZE+9,
                     en_mo => 1)
        port map (
          rst       => rst,
          clk       => tclk,
          clear     => sipo_clear_i(i),
          en_in     => sipo_en_i(i),
          serial_in => tdi_i(i),
          test_comp => sipo_comp_i(i),
          data_out  => test_in(i),
          op        => op_i(i),
          done      => sipo_done_i(i),
          end_trace => end_trace(i));


    end generate GEN_SIPO;


    demux_1to6_1 : demux_1to6
      port map(
        data_in => tdi,
        sel     => r.demux_sel,
        out1    => tdi_i(1),
        out2    => tdi_i(2),
        out3    => tdi_i(3),
        out4    => tdi_i(4),
        out5    => tdi_i(5),
        out6    => tdi_i(6));


    --synchronise tms with refclk
    process (refclk) is
    begin  -- process
      if refclk'event and refclk = '1' then  -- rising clock edge
        tms_int.async <= tms;
        tms_int.sync  <= tms_int.async;
      end if;
    end process;

    --from NoC plane 1
    rd_i(1) <= test1_stop_in nor fwd_rd_empty_o1;

    async_fifo_01 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 2)
      port map (
        rst_wr_n_i => rst,
        clk_wr_i   => tclk,
        we_i       => we_in(1),
        d_i        => test_in(1),
        wr_full_o  => fwd_wr_full_o(1),
        rst_rd_n_i => tile_rst,
        clk_rd_i   => refclk,
        rd_i       => rd_i(1),
        q_o        => test_in_sync(1),
        rd_empty_o => fwd_rd_empty_o1);


    test1_output_port   <= test_in_sync(1) when tms_int.sync = '1' else noc1_output_port;
    test1_data_void_out <= fwd_rd_empty_o1 when tms_int.sync = '1' else noc1_data_void_out;



    --from NoC plane 2
    rd_i(2) <= test2_stop_in nor fwd_rd_empty_o2;

    async_fifo_02 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 2)
      port map (
        rst_wr_n_i => rst,
        clk_wr_i   => tclk,
        we_i       => we_in(2),
        d_i        => test_in(2),
        wr_full_o  => fwd_wr_full_o(2),
        rst_rd_n_i => tile_rst,
        clk_rd_i   => refclk,
        rd_i       => rd_i(2),
        q_o        => test_in_sync(2),
        rd_empty_o => fwd_rd_empty_o2);


    test2_output_port   <= test_in_sync(2) when tms_int.sync = '1' else noc2_output_port;
    test2_data_void_out <= fwd_rd_empty_o2 when tms_int.sync = '1' else noc2_data_void_out;


    --from NoC plane 3
    rd_i(3) <= test3_stop_in nor fwd_rd_empty_o3;

    async_fifo_03 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 2)
      port map (
        rst_wr_n_i => rst,
        clk_wr_i   => tclk,
        we_i       => we_in(3),
        d_i        => test_in(3),
        wr_full_o  => fwd_wr_full_o(3),
        rst_rd_n_i => tile_rst,
        clk_rd_i   => refclk,
        rd_i       => rd_i(3),
        q_o        => test_in_sync(3),
        rd_empty_o => fwd_rd_empty_o3);


    test3_output_port   <= test_in_sync(3) when tms_int.sync = '1' else noc3_output_port;
    test3_data_void_out <= fwd_rd_empty_o3 when tms_int.sync = '1' else noc3_data_void_out;

    --from NoC plane 4
    rd_i(4) <= test4_stop_in nor fwd_rd_empty_o4;

    async_fifo_04 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 2)
      port map (
        rst_wr_n_i => rst,
        clk_wr_i   => tclk,
        we_i       => we_in(4),
        d_i        => test_in(4),
        wr_full_o  => fwd_wr_full_o(4),
        rst_rd_n_i => tile_rst,
        clk_rd_i   => refclk,
        rd_i       => rd_i(4),
        q_o        => test_in_sync(4),
        rd_empty_o => fwd_rd_empty_o4);


    test4_output_port   <= test_in_sync(4) when tms_int.sync = '1' else noc4_output_port;
    test4_data_void_out <= fwd_rd_empty_o4 when tms_int.sync = '1' else noc4_data_void_out;

    --from NoC plane 5
    rd_i(5) <= test5_stop_in nor fwd_rd_empty_o5;

    async_fifo_05 : inferred_async_fifo
      generic map (
        g_data_width => MISC_NOC_FLIT_SIZE,
        g_size       => 2)
      port map (
        rst_wr_n_i => rst,
        clk_wr_i   => tclk,
        we_i       => we_in(5),
        d_i        => test_in(5)(MISC_NOC_FLIT_SIZE-1 downto 0),
        wr_full_o  => fwd_wr_full_o(5),
        rst_rd_n_i => tile_rst,
        clk_rd_i   => refclk,
        rd_i       => rd_i(5),
        q_o        => test_in_sync(5)(MISC_NOC_FLIT_SIZE-1 downto 0),
        rd_empty_o => fwd_rd_empty_o5);


    test5_output_port   <= test_in_sync(5)(MISC_NOC_FLIT_SIZE-1 downto 0) when tms_int.sync = '1' else noc5_output_port;
    test5_data_void_out <= fwd_rd_empty_o5                                when tms_int.sync = '1' else noc5_data_void_out;


    --from NoC plane 6
    rd_i(6) <= test6_stop_in nor fwd_rd_empty_o6;

    async_fifo_06 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 2)
      port map (
        rst_wr_n_i => rst,
        clk_wr_i   => tclk,
        we_i       => we_in(6),
        d_i        => test_in(6),
        wr_full_o  => fwd_wr_full_o(6),
        rst_rd_n_i => tile_rst,
        clk_rd_i   => refclk,
        rd_i       => rd_i(6),
        q_o        => test_in_sync(6),
        rd_empty_o => fwd_rd_empty_o6);


    test6_output_port   <= test_in_sync(6) when tms_int.sync = '1' else noc6_output_port;
    test6_data_void_out <= fwd_rd_empty_o6 when tms_int.sync = '1' else noc6_data_void_out;

    -- Pick data for comparison with expected value
    process(r.compare, sipo_comp_i)
    begin
      case r.compare is
        when "100000" => sipo_comp <= sipo_comp_i(1)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(1)(1);
        when "010000" => sipo_comp <= sipo_comp_i(2)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(2)(1);
        when "001000" => sipo_comp <= sipo_comp_i(3)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(3)(1);
        when "000100" => sipo_comp <= sipo_comp_i(4)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(4)(1);
        when "000010" => sipo_comp <= sipo_comp_i(5)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(5)(1);
        when "000001" => sipo_comp <= sipo_comp_i(6)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(6)(1);
        when others   => sipo_comp <= (others => '0');
      end case;
    end process;

    -- Drive tdo
    tdoout : process(r.piso_en, r.piso_en0, sipo_comp, tdo_data, tdo_data0, r.state, test_comp, sipo_c)
    begin
      mismatch_detected <= '0';
      if r.piso_en = '1' then
        tdo <= tdo_data;
      elsif r.piso_en0 = '1' then
        tdo <= tdo_data0;
      elsif r.state = read_and_check then
        tdo <= '1';
        if test_comp /= sipo_c then
          mismatch_detected <= '1';
        end if;
      else
        tdo <= '0';
      end if;
    end process tdoout;

    sipo_c <= sipo_comp(NOC_FLIT_SIZE downto 1);

    -- to NoC plane 1
    we_in_out(1) <= t1_cpu_data_void_in nor test1_cpu_stop_out;

    async_fifo_i1 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 4)
      port map (
        rst_wr_n_i => tile_rst,
        clk_wr_i   => refclk,
        we_i       => we_in_out(1),
        d_i        => t1_out,
        wr_full_o  => test1_cpu_stop_out,
        rst_rd_n_i => rst,
        clk_rd_i   => tclk,
        rd_i       => rd_i_out(1),
        q_o        => test1_out,
        rd_empty_o => test1_cpu_data_void_in);

    noc1_input_port   <= test1_input_port;
    -- Do not inject any packet to the NoC if tms is active
    noc1_data_void_in <= '1' when tms_int.sync = '1' else test1_data_void_in;
    -- Hold any packet incoming from the NoC if tms is active
    noc1_stop_in      <= not noc1_data_void_out when tms_int.sync = '1' else test1_stop_in;

    t1_out              <= test1_input_port;
    t1_cpu_data_void_in <= test1_data_void_in when tms_int.sync = '1' else '1';


    -- to NoC plane 2
    we_in_out(2) <= t2_cpu_data_void_in nor test2_cpu_stop_out;

    async_fifo_i2 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 4)
      port map (
        rst_wr_n_i => tile_rst,
        clk_wr_i   => refclk,
        we_i       => we_in_out(2),
        d_i        => t2_out,
        wr_full_o  => test2_cpu_stop_out,
        rst_rd_n_i => rst,
        clk_rd_i   => tclk,
        rd_i       => rd_i_out(2),
        q_o        => test2_out,
        rd_empty_o => test2_cpu_data_void_in);

    noc2_input_port   <= test2_input_port;
    noc2_data_void_in <= '1' when tms_int.sync = '1' else test2_data_void_in;
    noc2_stop_in      <= not noc2_data_void_out when tms_int.sync = '1' else test2_stop_in;

    t2_out              <= test2_input_port;
    t2_cpu_data_void_in <= test2_data_void_in when tms_int.sync = '1' else '1';


    -- to NoC plane 3
    we_in_out(3) <= t3_cpu_data_void_in nor test3_cpu_stop_out;

    async_fifo_i3 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 4)
      port map (
        rst_wr_n_i => tile_rst,
        clk_wr_i   => refclk,
        we_i       => we_in_out(3),
        d_i        => t3_out,
        wr_full_o  => test3_cpu_stop_out,
        rst_rd_n_i => rst,
        clk_rd_i   => tclk,
        rd_i       => rd_i_out(3),
        q_o        => test3_out,
        rd_empty_o => test3_cpu_data_void_in);

    noc3_input_port   <= test3_input_port;
    noc3_data_void_in <= '1' when tms_int.sync = '1' else test3_data_void_in;
    noc3_stop_in      <= not noc3_data_void_out when tms_int.sync = '1' else test3_stop_in;

    t3_out              <= test3_input_port;
    t3_cpu_data_void_in <= test3_data_void_in when tms_int.sync = '1' else '1';


    -- to NoC plane 4
    we_in_out(4) <= t4_cpu_data_void_in nor test4_cpu_stop_out;

    async_fifo_i4 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 4)
      port map (
        rst_wr_n_i => tile_rst,
        clk_wr_i   => refclk,
        we_i       => we_in_out(4),
        d_i        => t4_out,
        wr_full_o  => test4_cpu_stop_out,
        rst_rd_n_i => rst,
        clk_rd_i   => tclk,
        rd_i       => rd_i_out(4),
        q_o        => test4_out,
        rd_empty_o => test4_cpu_data_void_in);

    noc4_input_port   <= test4_input_port;
    noc4_data_void_in <= '1' when tms_int.sync = '1' else test4_data_void_in;
    noc4_stop_in      <= not noc4_data_void_out when tms_int.sync = '1' else test4_stop_in;

    t4_out              <= test4_input_port;
    t4_cpu_data_void_in <= test4_data_void_in when tms_int.sync = '1' else '1';


    -- to NoC plane 5
    we_in_out(5) <= t5_cpu_data_void_in nor test5_cpu_stop_out;

    async_fifo_i5 : inferred_async_fifo
      generic map (
        g_data_width => MISC_NOC_FLIT_SIZE,
        g_size       => 4)
      port map (
        rst_wr_n_i => tile_rst,
        clk_wr_i   => refclk,
        we_i       => we_in_out(5),
        d_i        => t5_out,
        wr_full_o  => test5_cpu_stop_out,
        rst_rd_n_i => rst,
        clk_rd_i   => tclk,
        rd_i       => rd_i_out(5),
        q_o        => test5_out,
        rd_empty_o => test5_cpu_data_void_in);

    noc5_input_port   <= test5_input_port;
    noc5_data_void_in <= '1' when tms_int.sync = '1' else test5_data_void_in;
    noc5_stop_in      <= not noc5_data_void_out when tms_int.sync = '1' else test5_stop_in;

    t5_out              <= test5_input_port;
    t5_cpu_data_void_in <= test5_data_void_in when tms_int.sync = '1' else '1';


    -- to NoC plane 6
    we_in_out(6) <= t6_cpu_data_void_in nor test6_cpu_stop_out;

    async_fifo_i6 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE,
        g_size       => 4)
      port map (
        rst_wr_n_i => tile_rst,
        clk_wr_i   => refclk,
        we_i       => we_in_out(6),
        d_i        => t6_out,
        wr_full_o  => test6_cpu_stop_out,
        rst_rd_n_i => rst,
        clk_rd_i   => tclk,
        rd_i       => rd_i_out(6),
        q_o        => test6_out,
        rd_empty_o => test6_cpu_data_void_in);

    noc6_input_port   <= test6_input_port;
    noc6_data_void_in <= '1' when tms_int.sync = '1' else test6_data_void_in;
    noc6_stop_in      <= not noc6_data_void_out when tms_int.sync = '1' else test6_stop_in;

    t6_out              <= test6_input_port;
    t6_cpu_data_void_in <= test6_data_void_in when tms_int.sync = '1' else '1';

    -- Stop signals from NoC/JTAG to tile
    process(tms_int.sync,
            noc1_stop_out,
            noc2_stop_out,
            noc3_stop_out,
            noc4_stop_out,
            noc5_stop_out,
            noc6_stop_out,
            test1_cpu_stop_out,
            test2_cpu_stop_out,
            test3_cpu_stop_out,
            test4_cpu_stop_out,
            test5_cpu_stop_out,
            test6_cpu_stop_out)
    begin
      if tms_int.sync = '0' then
        test1_stop_out <= noc1_stop_out;
        test2_stop_out <= noc2_stop_out;
        test3_stop_out <= noc3_stop_out;
        test4_stop_out <= noc4_stop_out;
        test5_stop_out <= noc5_stop_out;
        test6_stop_out <= noc6_stop_out;
      else
        test1_stop_out <= test1_cpu_stop_out;
        test2_stop_out <= test2_cpu_stop_out;
        test3_stop_out <= test3_cpu_stop_out;
        test4_stop_out <= test4_cpu_stop_out;
        test5_stop_out <= test5_cpu_stop_out;
        test6_stop_out <= test6_cpu_stop_out;
      end if;
    end process;

    --final mux to test_out_reg
    A <= test1_out & mismatch_detected;
    B <= test2_out & mismatch_detected;
    C <= test3_out & mismatch_detected;
    D <= test4_out & mismatch_detected;
    E <= noc_flit_pad & test5_out & mismatch_detected;
    F <= test6_out & mismatch_detected;


    mux_6to1_1 : mux_6to1
      generic map(sz => NOC_FLIT_SIZE+1)
      port map(
        sel => r.compare,
        A   => A,
        B   => B,
        C   => C,
        D   => D,
        E   => E,
        F   => F,
        X   => test_out);

    piso_in  <= "0" & test_out & r.compare;
    piso0_in <= "11" & r.compare;

    piso_0 : piso_jtag
      generic map(sz => 8)
      port map(
        rst      => rst,
        clk      => tclk,
        clear    => r.piso_clear0,
        load     => r.piso_load0,
        A        => piso0_in,
        shift_en => r.piso_en0,
        Y        => tdo_data0,
        done     => piso_done0);

    test_comp <= piso_in(NOC_FLIT_SIZE+6 downto 7);

    piso_1 : piso_jtag
      generic map(sz => NOC_FLIT_SIZE+8)
      port map(
        rst      => rst,
        clk      => tclk,
        clear    => r.piso_clear,
        load     => piso_load,
        A        => piso_in,
        shift_en => r.piso_en,
        Y        => tdo_data,
        done     => piso_done);

  end generate test_if_gen;

  no_test_if_gen : if test_if_en = 0 generate
    -- Simply bypass
    noc1_stop_in <= test1_stop_in;
    noc2_stop_in <= test2_stop_in;
    noc3_stop_in <= test3_stop_in;
    noc4_stop_in <= test4_stop_in;
    noc5_stop_in <= test5_stop_in;
    noc6_stop_in <= test6_stop_in;

    test1_output_port <= noc1_output_port;
    test2_output_port <= noc2_output_port;
    test3_output_port <= noc3_output_port;
    test4_output_port <= noc4_output_port;
    test5_output_port <= noc5_output_port;
    test6_output_port <= noc6_output_port;

    test1_data_void_out <= noc1_data_void_out;
    test2_data_void_out <= noc2_data_void_out;
    test3_data_void_out <= noc3_data_void_out;
    test4_data_void_out <= noc4_data_void_out;
    test5_data_void_out <= noc5_data_void_out;
    test6_data_void_out <= noc6_data_void_out;

    test1_stop_out <= noc1_stop_out;
    test2_stop_out <= noc2_stop_out;
    test3_stop_out <= noc3_stop_out;
    test4_stop_out <= noc4_stop_out;
    test5_stop_out <= noc5_stop_out;
    test6_stop_out <= noc6_stop_out;

    noc1_input_port <= test1_input_port;
    noc2_input_port <= test2_input_port;
    noc3_input_port <= test3_input_port;
    noc4_input_port <= test4_input_port;
    noc5_input_port <= test5_input_port;
    noc6_input_port <= test6_input_port;

    noc1_data_void_in <= test1_data_void_in;
    noc2_data_void_in <= test2_data_void_in;
    noc3_data_void_in <= test3_data_void_in;
    noc4_data_void_in <= test4_data_void_in;
    noc5_data_void_in <= test5_data_void_in;
    noc6_data_void_in <= test6_data_void_in;

    tdo <= '0';
  end generate no_test_if_gen;

end;
