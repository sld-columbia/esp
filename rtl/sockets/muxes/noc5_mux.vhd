-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Bidirectional multiplexer for NoC plan 5:
--  - to be placed in the NoC clock domain
--  - multiplex between tile, CSRs, dvfs controller
--
--  Author: Davide Giri
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.allclkgen.all;
use work.gencomp.all;
use work.esp_csr_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.esp_acc_regmap.all;
use work.socmap.all;
use work.tiles_pkg.all;
use work.dvfs.all;
use work.misc.all;

entity noc5_mux is
  port (
    rstn                    : in  std_ulogic;
    clk                     : in  std_ulogic;
    -- NoC interface
    noc5_input_port         : out misc_noc_flit_type;
    noc5_data_void_in       : out std_ulogic;
    noc5_stop_out           : in  std_ulogic;
    noc5_output_port        : in  misc_noc_flit_type;
    noc5_data_void_out      : in  std_ulogic;
    noc5_stop_in            : out std_ulogic;
    -- Tile inferface
    noc5_input_port_tile    : in  misc_noc_flit_type;
    noc5_data_void_in_tile  : in  std_ulogic;
    noc5_stop_out_tile      : out std_ulogic;
    noc5_output_port_tile   : out misc_noc_flit_type;
    noc5_data_void_out_tile : out std_ulogic;
    noc5_stop_in_tile       : in  std_ulogic;
    -- Local CSR inferface
    noc5_input_port_csr     : in  misc_noc_flit_type;
    noc5_data_void_in_csr   : in  std_ulogic;
    noc5_stop_out_csr       : out std_ulogic;
    noc5_output_port_csr    : out misc_noc_flit_type;
    noc5_data_void_out_csr  : out std_ulogic;
    noc5_stop_in_csr        : in  std_ulogic;
    -- Power Management interface
    noc5_input_port_pm      : in  misc_noc_flit_type;
    noc5_data_void_in_pm    : in  std_ulogic;
    noc5_stop_out_pm        : out std_ulogic;
    noc5_output_port_pm     : out misc_noc_flit_type;
    noc5_data_void_out_pm   : out std_ulogic;
    noc5_stop_in_pm         : in  std_ulogic);
end entity noc5_mux;

architecture rtl of noc5_mux is

  constant csr_base_address : std_logic_vector(19 downto 16) := X"9";

  -------------------------------------------------------------------------------
  -- FSM: Incoming packets from NoC5
  -------------------------------------------------------------------------------
  type noc5_rcv_fsm is (idle, addr_rcv, pm_rcv, tile_rcv, csr_rcv);

  type noc5_rcv_reg_type is record
    state    : noc5_rcv_fsm;
    header   : misc_noc_flit_type;
    msg_type : noc_msg_type;
  end record noc5_rcv_reg_type;

  constant NOC5_RCV_REG_DEFAULT : noc5_rcv_reg_type := (
    state    => idle,
    header   => (others => '0'),
    msg_type => (others => '0'));

  signal noc5_rcv_reg      : noc5_rcv_reg_type;
  signal noc5_rcv_reg_next : noc5_rcv_reg_type;

  -------------------------------------------------------------------------------
  -- FSM: Outgoing packets to NoC5
  -------------------------------------------------------------------------------
  type noc5_snd_fsm is (idle_tile, idle_pm, idle_csr, tile_snd, pm_snd, csr_snd);

  type noc5_snd_reg_type is record
    state : noc5_snd_fsm;
  end record noc5_snd_reg_type;

  constant NOC5_SND_REG_DEFAULT : noc5_snd_reg_type := (
    state => idle_tile);

  signal noc5_snd_reg      : noc5_snd_reg_type;
  signal noc5_snd_reg_next : noc5_snd_reg_type;

  -------------------------------------------------------------------------------

  signal noc5_input_port_int    : misc_noc_flit_type;
  signal noc5_data_void_in_int  : std_ulogic;
  signal noc5_stop_out_int      : std_ulogic;
  signal noc5_output_port_int   : misc_noc_flit_type;
  signal noc5_data_void_out_int : std_ulogic;
  signal noc5_stop_in_int       : std_ulogic;

  signal noc5_input_port_csr_int    : misc_noc_flit_type;
  signal noc5_data_void_in_csr_int  : std_ulogic;
  signal noc5_stop_out_csr_int      : std_ulogic;
  signal noc5_output_port_csr_int   : misc_noc_flit_type;
  signal noc5_data_void_out_csr_int : std_ulogic;
  signal noc5_stop_in_csr_int       : std_ulogic;

  signal fifo_rcv_full      : std_ulogic;
  signal fifo_rcv_rdreq     : std_ulogic;
  signal fifo_rcv_wrreq     : std_ulogic;
  signal fifo_csr_rcv_rdreq : std_ulogic;
  signal fifo_csr_rcv_wrreq : std_ulogic;

  attribute mark_debug : string;

  attribute mark_debug of noc5_input_port            : signal is "true";
  attribute mark_debug of noc5_data_void_in          : signal is "true";
  attribute mark_debug of noc5_stop_out              : signal is "true";
  attribute mark_debug of noc5_output_port           : signal is "true";
  attribute mark_debug of noc5_data_void_out         : signal is "true";
  attribute mark_debug of noc5_stop_in               : signal is "true";
  attribute mark_debug of noc5_input_port_tile       : signal is "true";
  attribute mark_debug of noc5_data_void_in_tile     : signal is "true";
  attribute mark_debug of noc5_stop_out_tile         : signal is "true";
  attribute mark_debug of noc5_output_port_tile      : signal is "true";
  attribute mark_debug of noc5_data_void_out_tile    : signal is "true";
  attribute mark_debug of noc5_stop_in_tile          : signal is "true";
  attribute mark_debug of noc5_input_port_csr        : signal is "true";
  attribute mark_debug of noc5_data_void_in_csr      : signal is "true";
  attribute mark_debug of noc5_stop_out_csr          : signal is "true";
  attribute mark_debug of noc5_output_port_csr       : signal is "true";
  attribute mark_debug of noc5_data_void_out_csr     : signal is "true";
  attribute mark_debug of noc5_stop_in_csr           : signal is "true";
  attribute mark_debug of noc5_input_port_pm         : signal is "true";
  attribute mark_debug of noc5_data_void_in_pm       : signal is "true";
  attribute mark_debug of noc5_stop_out_pm           : signal is "true";
  attribute mark_debug of noc5_output_port_pm        : signal is "true";
  attribute mark_debug of noc5_data_void_out_pm      : signal is "true";
  attribute mark_debug of noc5_stop_in_pm            : signal is "true";
  attribute mark_debug of noc5_rcv_reg               : signal is "true";
  attribute mark_debug of noc5_rcv_reg_next          : signal is "true";
  attribute mark_debug of noc5_snd_reg               : signal is "true";
  attribute mark_debug of noc5_snd_reg_next          : signal is "true";
  attribute mark_debug of noc5_input_port_int        : signal is "true";
  attribute mark_debug of noc5_data_void_in_int      : signal is "true";
  attribute mark_debug of noc5_stop_out_int          : signal is "true";
  attribute mark_debug of noc5_output_port_int       : signal is "true";
  attribute mark_debug of noc5_data_void_out_int     : signal is "true";
  attribute mark_debug of noc5_stop_in_int           : signal is "true";
  attribute mark_debug of noc5_input_port_csr_int    : signal is "true";
  attribute mark_debug of noc5_data_void_in_csr_int  : signal is "true";
  attribute mark_debug of noc5_stop_out_csr_int      : signal is "true";
  attribute mark_debug of noc5_output_port_csr_int   : signal is "true";
  attribute mark_debug of noc5_data_void_out_csr_int : signal is "true";
  attribute mark_debug of noc5_stop_in_csr_int       : signal is "true";
  attribute mark_debug of fifo_rcv_rdreq             : signal is "true";
  attribute mark_debug of fifo_rcv_wrreq             : signal is "true";
  attribute mark_debug of fifo_csr_rcv_rdreq         : signal is "true";
  attribute mark_debug of fifo_csr_rcv_wrreq         : signal is "true";

begin

  fifo_rcv : fifo0
    generic map (
      depth => 4,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => rstn,
      rdreq    => fifo_rcv_rdreq,
      wrreq    => fifo_rcv_wrreq,
      data_in  => noc5_output_port,
      empty    => noc5_data_void_out_int,
      full     => fifo_rcv_full,
      data_out => noc5_output_port_int);

  noc5_stop_in   <= fifo_rcv_full and (not noc5_data_void_out);
  fifo_rcv_rdreq <= not noc5_stop_in_int;
  fifo_rcv_wrreq <= (not noc5_data_void_out) and (not fifo_rcv_full);

  fifo_csr_rcv : fifo0
    generic map (
      depth => 4,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => rstn,
      rdreq    => fifo_csr_rcv_rdreq,
      wrreq    => fifo_csr_rcv_wrreq,
      data_in  => noc5_output_port_csr_int,
      empty    => noc5_data_void_out_csr,
      full     => noc5_stop_in_csr_int,
      data_out => noc5_output_port_csr);

  fifo_csr_rcv_rdreq <= not noc5_stop_in_csr;
  fifo_csr_rcv_wrreq <= not noc5_data_void_out_csr_int;

  fsm_noc5_rcv : process (noc5_rcv_reg,
                          noc5_output_port_int, noc5_data_void_out_int,
                          noc5_stop_in_tile, noc5_stop_in_pm, noc5_stop_in_csr_int)

    variable reg           : noc5_rcv_reg_type;
    variable preamble      : noc_preamble_type;
    variable msg_type      : noc_msg_type;
    variable addr_csr_type : std_logic_vector(2 downto 0);
    variable addr_csrs     : std_logic_vector(3 downto 0);

  begin  -- process
    reg := noc5_rcv_reg;

    noc5_stop_in_int <= '1';  -- <= noc5_stop_in_tile and noc5_stop_in_pm and noc5_stop_in_csr;

    noc5_output_port_tile      <= noc5_output_port_int;
    noc5_output_port_pm        <= noc5_output_port_int;
    noc5_output_port_csr_int   <= noc5_output_port_int;
    noc5_data_void_out_tile    <= '1';
    noc5_data_void_out_pm      <= '1';
    noc5_data_void_out_csr_int <= '1';

    preamble := get_preamble_misc(noc5_output_port_int);
    msg_type := get_msg_type_misc(noc5_output_port_int);

    addr_csr_type := noc5_output_port_int(8 downto 6);
    addr_csrs     := noc5_output_port_int(19 downto 16);

    case reg.state is

      -- IDLE
      when idle =>
        if noc5_data_void_out_int = '0' then
          if msg_type = DVFS_MSG then
            noc5_data_void_out_pm <= '0';
            if preamble /= PREAMBLE_1FLIT then
              reg.state := pm_rcv;
            end if;
            noc5_stop_in_int <= noc5_stop_in_pm;
          else
            if preamble /= PREAMBLE_1FLIT then
              reg.state        := addr_rcv;
              reg.header       := noc5_output_port_int;
              reg.msg_type     := msg_type;
              noc5_stop_in_int <= '0';
            else
              noc5_data_void_out_tile <= '0';
              if noc5_stop_in_tile = '0' then
                noc5_stop_in_int <= '0';
              end if;
            end if;
          end if;
        end if;

      when addr_rcv =>
        if noc5_data_void_out_int = '0' then
          -- noc5_stop_in_int <= '1';
          -- TODO do not hard-code these values
          if (reg.msg_type = REQ_REG_RD or reg.msg_type = REQ_REG_WR) and addr_csrs = csr_base_address and
            (addr_csr_type = "111" or (unsigned(noc5_output_port_int(8 downto 2)) <= 59 and
                                       unsigned(noc5_output_port_int(8 downto 2)) >= 23)) then
            if noc5_stop_in_csr_int = '0' then
              reg.state                  := csr_rcv;
              noc5_data_void_out_csr_int <= '0';
              noc5_output_port_csr_int   <= reg.header;
            end if;
          else
            noc5_data_void_out_tile <= '0';
            if noc5_stop_in_tile = '0' then
              reg.state             := tile_rcv;
              noc5_output_port_tile <= reg.header;
            end if;
          end if;
        end if;

      when pm_rcv =>
        noc5_data_void_out_pm <= noc5_data_void_out_int;
        if noc5_data_void_out_int = '0' and noc5_stop_in_pm = '0' then
          noc5_stop_in_int <= noc5_stop_in_pm;
          if preamble = PREAMBLE_TAIL then
            reg.state := idle;
          end if;
        end if;

      when tile_rcv =>
        if noc5_data_void_out_int = '0' then
          noc5_data_void_out_tile <= '0';
          if noc5_stop_in_tile = '0' then
            noc5_stop_in_int <= '0';
            if preamble = PREAMBLE_TAIL then
              reg.state := idle;
            end if;
          end if;
        end if;

      when csr_rcv =>
        if noc5_stop_in_csr_int = '0' then
          noc5_data_void_out_csr_int <= noc5_data_void_out_int;
          if noc5_data_void_out_int = '0' then
            noc5_stop_in_int <= '0';
            if preamble = PREAMBLE_TAIL then
              reg.state := idle;
            end if;
          end if;
        end if;

    end case;

    noc5_rcv_reg_next <= reg;

  end process;

-- NoC5 send FSM
  fsm_noc5_snd : process (noc5_snd_reg, noc5_stop_out,
                          noc5_input_port_tile, noc5_input_port_pm, noc5_input_port_csr,
                          noc5_data_void_in_tile, noc5_data_void_in_pm, noc5_data_void_in_csr)
    variable reg                                      : noc5_snd_reg_type;
    variable preamble_tile, preamble_pm, preamble_csr : noc_preamble_type;

  begin  -- process
    reg := noc5_snd_reg;

    noc5_stop_out_tile <= '1';
    noc5_stop_out_pm   <= '1';
    noc5_stop_out_csr  <= '1';

    noc5_input_port   <= noc5_input_port_tile;
    noc5_data_void_in <= noc5_data_void_in_tile;

    preamble_tile := get_preamble_misc(noc5_input_port_tile);
    preamble_pm   := get_preamble_misc(noc5_input_port_pm);
    preamble_csr  := get_preamble_misc(noc5_input_port_csr);

    case reg.state is

      when idle_tile =>
        reg.state := idle_pm;

        if noc5_stop_out = '0' then
          noc5_stop_out_tile <= '0';
          if noc5_data_void_in_tile = '0' then
            if preamble_tile /= PREAMBLE_1FLIT then
              reg.state := tile_snd;
            end if;
          end if;
        end if;

      when idle_pm =>
        reg.state         := idle_csr;
        noc5_data_void_in <= noc5_data_void_in_pm;
        noc5_input_port   <= noc5_input_port_pm;
        if noc5_stop_out = '0' then
          noc5_stop_out_pm <= '0';
          if noc5_data_void_in_pm = '0' then
            if preamble_pm /= PREAMBLE_1FLIT then
              reg.state := pm_snd;
            end if;
          end if;
        end if;

      when idle_csr =>
        reg.state         := idle_tile;
        noc5_data_void_in <= noc5_data_void_in_csr;
        noc5_input_port   <= noc5_input_port_csr;
        if noc5_stop_out = '0' then
          noc5_stop_out_csr <= '0';
          if noc5_data_void_in_csr = '0' then
            if preamble_csr /= PREAMBLE_1FLIT then
              reg.state := csr_snd;
            end if;
          end if;
        end if;

      when tile_snd =>
        if noc5_stop_out = '0' then
          noc5_stop_out_tile <= '0';
          if noc5_data_void_in_tile = '0' then
            if preamble_tile = PREAMBLE_TAIL then
              reg.state := idle_pm;
            end if;
          end if;
        end if;

      when pm_snd =>
        noc5_data_void_in <= noc5_data_void_in_pm;
        noc5_input_port   <= noc5_input_port_pm;
        if noc5_stop_out = '0' then
          noc5_stop_out_pm <= '0';
          if noc5_data_void_in_pm = '0' then
            if preamble_pm = PREAMBLE_TAIL then
              reg.state := idle_csr;
            end if;
          end if;
        end if;

      when csr_snd =>
        noc5_data_void_in <= noc5_data_void_in_csr;
        noc5_input_port   <= noc5_input_port_csr;
        if noc5_stop_out = '0' then
          noc5_stop_out_csr <= '0';
          if noc5_data_void_in_csr = '0' then
            if preamble_csr = PREAMBLE_TAIL then
              reg.state := idle_tile;
            end if;
          end if;
        end if;

    end case;

    noc5_snd_reg_next <= reg;

  end process;

  fsms_state_update : process (clk, rstn)
  begin
    if rstn = '0' then
      noc5_rcv_reg <= NOC5_RCV_REG_DEFAULT;
      noc5_snd_reg <= NOC5_SND_REG_DEFAULT;
    elsif clk'event and clk = '1' then
      noc5_rcv_reg <= noc5_rcv_reg_next;
      noc5_snd_reg <= noc5_snd_reg_next;
    end if;
  end process fsms_state_update;

end;
