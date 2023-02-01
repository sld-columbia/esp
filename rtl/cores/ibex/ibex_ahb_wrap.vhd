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
use work.genacc.all;


entity ibex_ahb_wrap is
  generic (
    hindex  : integer range 0 to NAHBSLV - 1 := 0;
    ROMBase : std_logic_vector(31 downto 0)  := X"0001_0000");
  port (
    rstn      : in  std_ulogic;
    clk       : in  std_ulogic;
    HART_ID   : in  std_logic_vector(31 downto 0);
    -- Interrupts
    irq       : in  std_logic_vector(1 downto 0);
    timer_irq : in  std_ulogic;
    ipi       : in  std_ulogic;
    -- idle
    core_idle : out std_ulogic;
    -- AHB master interface
    ahbmi     : in  ahb_mst_in_type;
    ahbmo     : out ahb_mst_out_type
    );
end ibex_ahb_wrap;


architecture rtl of ibex_ahb_wrap is

  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_LOWRISC, LOWRISC_IBEX_SMALL, 0, 0, 0),
    others => zero32);

  component ibex_wrap is
    generic (
      ROMBase : std_logic_vector(31 downto 0));
    port (
      clk            : in  std_ulogic;
      rstn           : in  std_ulogic;
      HART_ID        : in  std_logic_vector(31 downto 0);
      instr_req_o    : out std_ulogic;
      instr_gnt_i    : in  std_ulogic;
      instr_rvalid_i : in  std_ulogic;
      instr_addr_o   : out std_logic_vector(31 downto 0);
      instr_rdata_i  : in  std_logic_vector(31 downto 0);
      data_req_o     : out std_ulogic;
      data_gnt_i     : in  std_ulogic;
      data_rvalid_i  : in  std_ulogic;
      data_we_o      : out std_ulogic;
      data_be_o      : out std_logic_vector(3 downto 0);
      data_addr_o    : out std_logic_vector(31 downto 0);
      data_wdata_o   : out std_logic_vector(31 downto 0);
      data_rdata_i   : in  std_logic_vector(31 downto 0);
      irq            : in  std_logic_vector(1 downto 0);
      timer_irq      : in  std_ulogic;
      ipi            : in  std_ulogic;
      core_sleep_o   : out std_ulogic);
  end component ibex_wrap;

  signal instr_req_o    : std_ulogic;
  signal instr_gnt_i    : std_ulogic;
  signal instr_rvalid_i : std_ulogic;
  signal instr_addr_o   : std_logic_vector(31 downto 0);
  signal instr_rdata_i  : std_logic_vector(31 downto 0);
  signal data_req_o     : std_ulogic;
  signal data_gnt_i     : std_ulogic;
  signal data_rvalid_i  : std_ulogic;
  signal data_we_o      : std_ulogic;
  signal data_be_o      : std_logic_vector(3 downto 0);
  signal data_addr_o    : std_logic_vector(31 downto 0);
  signal data_wdata_o   : std_logic_vector(31 downto 0);
  signal data_rdata_i   : std_logic_vector(31 downto 0);

  type ahbm_state_t is (idle, ird, dwr, drd);
  type ahbm_fsm_t is record
    state      : ahbm_state_t;
    hbusreq    : std_ulogic;
    htrans     : std_logic_vector(1 downto 0);
    haddr      : std_logic_vector(31 downto 0);
    hsize      : std_logic_vector(2 downto 0);
    hwrite     : std_ulogic;
    hwdata     : std_logic_vector(31 downto 0);
    misaligned : std_ulogic;
  end record ahbm_fsm_t;

  signal r, rin : ahbm_fsm_t;
  constant AHBM_DEFAULT : ahbm_fsm_t := (
    state      => idle,
    hbusreq    => '0',
    htrans     => HTRANS_IDLE,
    haddr      => (others => '0'),
    hsize      => HSIZE_WORD,
    hwrite     => '0',
    hwdata     => (others => '0'),
    misaligned => '0'
    );

  procedure set_bus_control(
    byte_mask  : in  std_logic_vector(3 downto 0);
    addr       : in  std_logic_vector(31 downto 0);
    hsize      : out std_logic_vector(2 downto 0);
    haddr      : out std_logic_vector(31 downto 0);
    misaligned : out std_ulogic
    ) is
    variable haddr_lsb : std_logic_vector(1 downto 0);
  begin
    misaligned := '0';
    case byte_mask is
      when "1111" => hsize := HSIZE_WORD; haddr_lsb := "00";
      when "0011" => hsize := HSIZE_HWORD; haddr_lsb := "00";
      when "1100" => hsize := HSIZE_HWORD; haddr_lsb := "10";
      when "0001" => hsize := HSIZE_BYTE; haddr_lsb := "00";
      when "0010" => hsize := HSIZE_BYTE; haddr_lsb := "01";
      when "0100" => hsize := HSIZE_BYTE; haddr_lsb := "10";
      when "1000" => hsize := HSIZE_BYTE; haddr_lsb := "11";
      when others =>
        hsize := HSIZE_WORD; haddr_lsb := "00";
        -- pragma translate_off
        misaligned := '1';
        -- pragma translate_on
    end case;
    haddr := addr(31 downto 2) & haddr_lsb;
  end;

  procedure set_bus_data(
    byte_mask : in  std_logic_vector(3 downto 0);
    wdata     : in  std_logic_vector(31 downto 0);
    hwdata    : out std_logic_vector(31 downto 0)
    ) is
  begin
    case byte_mask is
      when "1111" => hwdata := ahbdrivedata(wdata);
      when "0011" => hwdata := ahbdrivedata(wdata(15 downto 0));
      when "1100" => hwdata := ahbdrivedata(wdata(31 downto 16));
      when "0001" => hwdata := ahbdrivedata(wdata(7 downto 0));
      when "0010" => hwdata := ahbdrivedata(wdata(15 downto 8));
      when "0100" => hwdata := ahbdrivedata(wdata(23 downto 16));
      when "1000" => hwdata := ahbdrivedata(wdata(31 downto 24));
      when others =>
        hwdata := ahbdrivedata(wdata);
    end case;
  end;

  function is_seq_trans (
    signal addr   : std_logic_vector(31 downto 0);
    signal addr_r : std_logic_vector(31 downto 0))
    return std_ulogic is
    variable addr_msb_incr : std_logic_vector(29 downto 0);
  begin
    addr_msb_incr := addr_r(31 downto 2) + ("00" & X"0000001");
    if addr_msb_incr = addr(31 downto 2) then
      return '1';
    else
      return '0';
    end if;
  end;

begin  -- architecture rtl

  ahbm_reg : process (clk, rstn) is
  begin  -- process ahbm_reg
    if rstn = '0' then                  -- asynchronous reset (active low)
      r <= AHBM_DEFAULT;
    elsif clk'event and clk = '1' then  -- rising clock edge
      r <= rin;
      -- pragma translate_off
      assert r.misaligned = '0' report "misaligned bus transaction is not supported" severity failure;
      -- pragma translate_on
    end if;
  end process ahbm_reg;

  ahbm_fsm : process (r, ahbmi, instr_req_o, instr_addr_o, data_req_o, data_we_o, data_be_o, data_addr_o, data_wdata_o) is
    variable v       : ahbm_fsm_t;
    variable granted : std_ulogic;
  begin  -- process ahbm_fsm
    v := r;

    granted := ahbmi.hgrant(hindex);

    instr_gnt_i    <= '0';
    instr_rvalid_i <= '0';

    data_gnt_i    <= '0';
    data_rvalid_i <= '0';

    case r.state is
      when idle =>
        v.hbusreq := '0';
        v.htrans  := HTRANS_IDLE;
        if data_req_o = '1' then
          set_bus_control(data_be_o, data_addr_o, v.hsize, v.haddr, v.misaligned);
          set_bus_data(data_be_o, data_wdata_o, v.hwdata);
          v.hbusreq := '1';
          v.htrans  := HTRANS_NONSEQ;
          v.hwrite  := data_we_o;
          if (ahbmi.hready and granted) = '1' then
            data_gnt_i <= '1';
            if data_we_o = '1' then
              v.state := dwr;
            else
              v.state := drd;
            end if;
          end if;
        elsif instr_req_o = '1' then
          v.hbusreq := '1';
          v.htrans  := HTRANS_NONSEQ;
          v.hsize   := HSIZE_WORD;
          v.haddr   := instr_addr_o;
          v.hwrite  := '0';
          if (ahbmi.hready and granted) = '1' then
            instr_gnt_i <= '1';
            v.state     := ird;
          end if;
        end if;

      when ird =>
        if ahbmi.hready = '1' then
          v.haddr        := instr_addr_o;
          if instr_req_o = '1' then
            if is_seq_trans(instr_addr_o, r.haddr) = '1' then
              -- continue sequential burst
              v.htrans := HTRANS_SEQ;
            else
              v.htrans := HTRANS_NONSEQ;
            end if;
          else
            v.hbusreq := '0';
            v.htrans  := HTRANS_IDLE;
          end if;

          if granted = '1' then
            instr_rvalid_i <= '1';
            if instr_req_o = '1' then
              instr_gnt_i <= '1';
            else
              v.state   := idle;
            end if;
          end if;
        end if;

      when drd =>
        if ahbmi.hready = '1' then
          set_bus_control(data_be_o, data_addr_o, v.hsize, v.haddr, v.misaligned);
          set_bus_data(data_be_o, data_wdata_o, v.hwdata);

          if data_req_o = '1' then
            if data_we_o = '0' then
              if data_be_o = "1111" and is_seq_trans(data_addr_o, r.haddr) = '1' then
                -- continue sequential burst
                v.htrans := HTRANS_SEQ;
              else
                v.htrans := HTRANS_NONSEQ;
              end if;
            else
              -- Move to data write
              v.htrans := HTRANS_NONSEQ;
              v.hwrite := '1';
            end if;
          else
            v.hbusreq := '0';
            v.htrans  := HTRANS_IDLE;
          end if;

          if granted = '1' then
            data_rvalid_i <= '1';
            if data_req_o = '1' then
              data_gnt_i <= '1';
              if data_we_o /= '0' then
                -- Move to data write
                v.state  := dwr;
              end if;
            else
              v.state   := idle;
            end if;
          end if;
        end if;

      when dwr =>
        if ahbmi.hready = '1' then
          set_bus_control(data_be_o, data_addr_o, v.hsize, v.haddr, v.misaligned);
          set_bus_data(data_be_o, data_wdata_o, v.hwdata);

          if data_req_o = '1' then
            if data_we_o = '1' then
              if data_be_o = "1111" and is_seq_trans(data_addr_o, r.haddr) = '1' then
                -- continue sequential burst
                v.htrans := HTRANS_SEQ;
              else
                v.htrans := HTRANS_NONSEQ;
              end if;
            else
              -- Move to data read
              v.htrans := HTRANS_NONSEQ;
              v.hwrite := '0';
            end if;
          else
            v.hbusreq := '0';
            v.htrans  := HTRANS_IDLE;
          end if;

          if granted = '1' then
            data_rvalid_i <= '1';
            if data_req_o = '1' then
              data_gnt_i <= '1';
              if data_we_o /= '1' then
                -- Move to data read
                v.state  := drd;
              end if;
            else
              v.state   := idle;
            end if;
          end if;
        end if;

      when others =>
        v.hbusreq := '0';
        v.htrans  := HTRANS_IDLE;
        v.state   := idle;

    end case;

    -- Combinational bus control signals
    ahbmo.hbusreq <= v.hbusreq;
    ahbmo.htrans  <= v.htrans;
    ahbmo.haddr   <= v.haddr;
    ahbmo.hsize   <= v.hsize;
    ahbmo.hwrite  <= v.hwrite;
    -- State register input
    rin           <= v;
  end process ahbm_fsm;

  -- Sequential bus control signals (pipeline between address and data)
  ahbmo.hwdata  <= ahbdrivedata(r.hwdata);
  -- Constant bus control signals
  ahbmo.hprot   <= "0011";
  ahbmo.hlock   <= '0';
  ahbmo.hirq    <= (others => '0');
  ahbmo.hconfig <= hconfig;
  ahbmo.hindex  <= hindex;
  ahbmo.hburst  <= HBURST_INCR;

  instr_rdata_i <= ahbmi.hrdata(31 downto 0);
  data_rdata_i  <= ahbmi.hrdata(31 downto 0);

  ibex_wrap_i : ibex_wrap
    generic map (
      ROMBase => ROMBase)
    port map (
      clk            => clk,
      rstn           => rstn,
      HART_ID        => HART_ID,
      instr_req_o    => instr_req_o,
      instr_gnt_i    => instr_gnt_i,
      instr_rvalid_i => instr_rvalid_i,
      instr_addr_o   => instr_addr_o,
      instr_rdata_i  => instr_rdata_i,
      data_req_o     => data_req_o,
      data_gnt_i     => data_gnt_i,
      data_rvalid_i  => data_rvalid_i,
      data_we_o      => data_we_o,
      data_be_o      => data_be_o,
      data_addr_o    => data_addr_o,
      data_wdata_o   => data_wdata_o,
      data_rdata_i   => data_rdata_i,
      irq            => irq,
      timer_irq      => timer_irq,
      ipi            => ipi,
      core_sleep_o   => core_idle);

end architecture rtl;
