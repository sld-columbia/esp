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
-------------------------------------------------------------------------------
-- Entity:     spictrlx
-- File:       spictrlx.vhd
-- Author:     Jan Andersson - Aeroflex Gaisler AB
--             Auto mode: J. Andersson, J. Ekergarn - Aeroflex Gaisler AB
-- Contact:    support@gaisler.com
--
-- Description: SPI controller with an interface compatible with MPC83xx SPI.
--              Relies on APB's wait state between back-to-back transfers.
--
-------------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.gencomp.all;
use work.config_types.all;
use work.config.all;
use work.stdlib.all;
use work.spi.all;

entity spictrlx is
  generic (
    rev       : integer                  := 0;  -- Core revision
    fdepth    : integer range 1 to 7     := 1;  -- FIFO depth is 2^fdepth
    slvselen  : integer range 0 to 1     := 0;  -- Slave select register enable
    slvselsz  : integer range 1 to 32    := 1;  -- Number of slave select signals
    oepol     : integer range 0 to 1     := 0;  -- Output enable polarity
    odmode    : integer range 0 to 1     := 0;  -- Support open drain mode, only
                                                -- set if pads are i/o or od pads.
    automode  : integer range 0 to 1     := 0;  -- Enable automated transfer mode
    acntbits  : integer range 1 to 32    := 32; -- # Bits in am period counter
    aslvsel   : integer range 0 to 1     := 0;  -- Automatic slave select
    twen      : integer range 0 to 1     := 1;  -- Enable three wire mode
    maxwlen   : integer range 0 to 15    := 0;  -- Maximum word length;

    syncram   : integer range 0 to 1     := 1;  -- Use SYNCRAM for buffers
    memtech   : integer range 0 to NTECH := 0;  -- Memory technology
    ft        : integer range 0 to 2     := 0;  -- Fault-Tolerance
    scantest  : integer range 0 to 1     := 0;  -- Scan test support
    syncrst   : integer range 0 to 1     := 0;  -- Use only sync reset
    automask0 : integer                  := 0;  -- Mask 0 for automated transfers
    automask1 : integer                  := 0;  -- Mask 1 for automated transfers
    automask2 : integer                  := 0;  -- Mask 2 for automated transfers
    automask3 : integer                  := 0;  -- Mask 3 for automated transfers
    ignore    : integer range 0 to 1     := 0   -- Ignore samples
    );
  port (
    rstn          : in std_ulogic;
    clk           : in std_ulogic;

    -- APB signals
    apbi_psel     : in  std_ulogic;
    apbi_penable  : in  std_ulogic;
    apbi_paddr    : in  std_logic_vector(31 downto 0);
    apbi_pwrite   : in  std_ulogic;
    apbi_pwdata   : in  std_logic_vector(31 downto 0);
    apbi_testen   : in  std_ulogic;
    apbi_testrst  : in  std_ulogic;
    apbi_scanen   : in  std_ulogic;
    apbi_testoen  : in  std_ulogic;
    apbo_prdata   : out std_logic_vector(31 downto 0);
    apbo_pirq     : out std_ulogic;

    -- SPI signals
    spii_miso     : in  std_ulogic;
    spii_mosi     : in  std_ulogic;
    spii_sck      : in  std_ulogic;
    spii_spisel   : in  std_ulogic;
    spii_astart   : in  std_ulogic;
    spii_cstart   : in  std_ulogic;
    spii_ignore   : in  std_ulogic;
    spio_miso     : out std_ulogic;
    spio_misooen  : out std_ulogic;
    spio_mosi     : out std_ulogic;
    spio_mosioen  : out std_ulogic;
    spio_sck      : out std_ulogic;
    spio_sckoen   : out std_ulogic;
    spio_enable   : out std_ulogic;
    spio_astart   : out std_ulogic;
    spio_aready   : out std_ulogic;
    slvsel        : out std_logic_vector((slvselsz-1) downto 0)
    );
  attribute sync_set_reset of rstn : signal is "true";
end entity spictrlx;

architecture rtl of spictrlx is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant OEPOL_LEVEL : std_ulogic := conv_std_logic(oepol = 1);

  constant OUTPUT : std_ulogic := OEPOL_LEVEL;      -- Enable outputs
  constant INPUT : std_ulogic := not OEPOL_LEVEL;   -- Tri-state outputs

  constant FIFO_DEPTH  : integer := 2**fdepth;
  constant SLVSEL_EN   : integer := slvselen;
  constant SLVSEL_SZ   : integer := slvselsz;
  constant ASEL_EN     : integer := aslvsel * slvselen;
  constant AM_EN       : integer := automode;
  constant AM_CNT_BITS : integer := acntbits;
  constant OD_EN       : integer := odmode;
  constant TW_EN       : integer := twen;
  constant MAX_WLEN    : integer := maxwlen;
  constant AM_MSK1_EN  : boolean := AM_EN = 1 and FIFO_DEPTH > 32;
  constant AM_MSK2_EN  : boolean := AM_EN = 1 and FIFO_DEPTH > 64;
  constant AM_MSK3_EN  : boolean := AM_EN = 1 and FIFO_DEPTH > 96;
  constant FIFO_BITS   : integer := fdepth;

  constant APBBITS : integer := 6+3*AM_EN;
  constant APBH    : integer := 2+APBBITS-1;

  constant CAP_ADDR    : std_logic_vector(APBH downto 2) := conv_std_logic_vector(0, APBBITS);

  constant MODE_ADDR   : std_logic_vector(APBH downto 2) := conv_std_logic_vector(8, APBBITS);
  constant EVENT_ADDR  : std_logic_vector(APBH downto 2) := conv_std_logic_vector(9, APBBITS);
  constant MASK_ADDR   : std_logic_vector(APBH downto 2) := conv_std_logic_vector(10, APBBITS);
  constant COM_ADDR    : std_logic_vector(APBH downto 2) := conv_std_logic_vector(11, APBBITS);
  constant TD_ADDR     : std_logic_vector(APBH downto 2) := conv_std_logic_vector(12, APBBITS);
  constant RD_ADDR     : std_logic_vector(APBH downto 2) := conv_std_logic_vector(13, APBBITS);
  constant SLVSEL_ADDR : std_logic_vector(APBH downto 2) := conv_std_logic_vector(14, APBBITS);
  constant ASEL_ADDR   : std_logic_vector(APBH downto 2) := conv_std_logic_vector(15, APBBITS);

  constant AMCFG_ADDR  : std_logic_vector(APBH downto 2) := conv_std_logic_vector(16, APBBITS);
  constant AMPER_ADDR  : std_logic_vector(APBH downto 2) := conv_std_logic_vector(17, APBBITS);

  constant AMMSK0_ADDR : std_logic_vector(10 downto 2) := "000010100";  -- 0x050
  constant AMMSK1_ADDR : std_logic_vector(10 downto 2) := "000010101";  -- 0x054
  constant AMMSK2_ADDR : std_logic_vector(10 downto 2) := "000010110";  -- 0x058
  constant AMMSK3_ADDR : std_logic_vector(10 downto 2) := "000010111";  -- 0x05C

  constant AMTX_ADDR   : std_logic_vector(10 downto 2) := "010000000";  -- 0x200
  constant AMRX_ADDR   : std_logic_vector(10 downto 2) := "100000000";  -- 0x40

  constant SPICTRLCAPREG : std_logic_vector(31 downto 0) :=
    conv_std_logic_vector(SLVSEL_SZ, 8) & conv_std_logic_vector(MAX_WLEN, 4) &
    conv_std_logic_vector(TW_EN, 1) & conv_std_logic_vector(AM_EN, 1) &
    conv_std_logic_vector(ASEL_EN, 1) & conv_std_logic_vector(SLVSEL_EN, 1) &
    conv_std_logic_vector(FIFO_DEPTH, 8) & conv_std_logic(syncram = 1) &
    conv_std_logic_vector(ft, 2) & conv_std_logic_vector(rev, 5);

  -- Returns an integer containing the maximum characted length - 1 as
  -- restricted by the maxwlen VHDL generic.
  function wlen return integer is
  begin  -- maxwlen
    if MAX_WLEN = 0 then return 31; end if;
    return MAX_WLEN;
  end wlen;

  constant PROG_AM_MASK : boolean :=
    AM_EN = 1 and automask0 = 0 and (automask1 = 0 or FIFO_DEPTH <= 32) and
    (automask2 = 0 or FIFO_DEPTH <= 64) and (automask3 = 0 or FIFO_DEPTH <= 96);
  constant AM_MASK : std_logic_vector(127 downto 0) :=
    conv_std_logic_vector_signed(automask3,32) &
    conv_std_logic_vector_signed(automask2,32) &
    conv_std_logic_vector_signed(automask1,32) &
    conv_std_logic_vector_signed(automask0,32);

  function check_discont_am_mask return boolean is
    variable foundzero : boolean;
  begin
    if AM_EN = 0 then
      return false;
    elsif PROG_AM_MASK then
      return true;
    else
      foundzero := false;
      for i in 0 to FIFO_DEPTH-1 loop
        if AM_MASK(i) = '0' then
          foundzero := true;
        else
          if foundzero then
            return true;
          end if;
        end if;
      end loop;
      return false;
    end if;
  end function;
  constant DISCONT_AM_MASK : boolean := check_discont_am_mask;

  function check_am_mask_end return integer is
    variable ret : integer;
  begin
    ret := 0;
    for i in 0 to FIFO_DEPTH-1 loop
      if AM_MASK(i) = '1' then
        ret := i;
      end if;
    end loop;
    return ret;
  end function;
  constant AM_MASK_END : integer := check_am_mask_end;

  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  type spi_mode_rec is record           -- SPI Mode register
    amen    : std_ulogic;
    loopb   : std_ulogic;  -- loopback mode
    cpol    : std_ulogic;  -- clock polarity
    cpha    : std_ulogic;  -- clock phase
    div16   : std_ulogic;  -- Divide by 16
    rev     : std_ulogic;  -- Reverse data mode
    ms      : std_ulogic;  -- Master/slave
    en      : std_ulogic;  -- Enable SPI
    len     : std_logic_vector(3 downto 0);  -- Bits per character
    pm      : std_logic_vector(3 downto 0);  -- Prescale modulus
    tw      : std_ulogic;  -- 3-wire mode
    asel    : std_ulogic;  -- Automatic slave select
    fact    : std_ulogic;  -- PM multiplication factor
    od      : std_ulogic;  -- Open drain mode
    cg      : std_logic_vector(4 downto 0);  -- Clock gap
    aseldel : std_logic_vector(1 downto 0);  -- Asel delay
    tac     : std_ulogic;
    tto     : std_ulogic;  -- Three-wire mode word order
    igsel   : std_ulogic;  -- Ignore spisel input
    cite    : std_ulogic;  -- Require SCK = CPOL for TIP end
  end record;

  type spi_em_rec is record             -- SPI Event and Mask registers
    tip : std_ulogic;  -- Transfer in progress/Clock generated
    lt  : std_ulogic;  -- last character transmitted
    ov  : std_ulogic;  -- slave/master overrun
    un  : std_ulogic;  -- slave/master underrun
    mme : std_ulogic;  -- Multiple-master error
    ne  : std_ulogic;  -- Not empty
    nf  : std_ulogic;  -- Not full
    at  : std_ulogic;  -- Automated transfer
  end record;

  type spi_fifo is array (0 to (1-syncram)*(FIFO_DEPTH-1)) of std_logic_vector(wlen downto 0);

  type spi_amcfg_rec is record          -- AM config register
    seq    : std_ulogic;  -- Data must always be read out of receive queue
    strict : std_ulogic;  -- Strict period
    ovtb   : std_ulogic;  -- Perform transfer on OV
    ovdb   : std_ulogic;  -- Skip data on OV
    act    : std_ulogic;  -- Start immediately
    eact   : std_ulogic;  -- Activate on external event
    erpt   : std_ulogic;  -- Repeat on external event, not on period done
    lock   : std_ulogic;  -- Lock receive registers when reading data
    ecgc   : std_ulogic;  -- External clock gap control
  end record;

  type spi_am_rec is record             -- Automode state
    -- Register interface
    cfg       : spi_amcfg_rec;  -- AM config register
    per       : std_logic_vector((AM_CNT_BITS-1)*AM_EN downto 0);  -- AM period
    --
    active    : std_ulogic; -- Auto mode active
    lock      : std_ulogic;
    cnt       : unsigned((AM_CNT_BITS-1)*AM_EN downto 0);
    --
    skipdata  : std_ulogic;
    rxfull    : std_ulogic;  -- AM RX FIFO is filled
    rxfifo    : spi_fifo;    -- Receive data FIFO
    txfifo    : spi_fifo;    -- Transmit data FIFO
    rfreecnt  : integer range 0 to FIFO_DEPTH; -- free rx fifo slots
    mask      : std_logic_vector(FIFO_DEPTH-1 downto 0);
    mask_shdw : std_logic_vector(FIFO_DEPTH-1 downto 0);
    unread    : std_logic_vector(FIFO_DEPTH-1 downto 0);
    at        : std_ulogic;
    --
    rxread    : std_ulogic;
    txwrite   : std_ulogic;
    txread    : std_ulogic;
    apbaddr   : std_logic_vector(FIFO_BITS-1 downto 0);
    rxsel     : std_ulogic;
  end record;

  -- Two stage synchronizers on each input coming from off-chip
  type spi_in_local_type is record
    miso    : std_ulogic;
    mosi    : std_ulogic;
    sck     : std_ulogic;
    spisel  : std_ulogic;
  end record;

  type spi_in_array is array (1 downto 0) of spi_in_local_type;

  -- Local spi out type without ssn
  type spi_out_local_type is record
    miso     : std_ulogic;
    misooen  : std_ulogic;
    mosi     : std_ulogic;
    mosioen  : std_ulogic;
    sck      : std_ulogic;
    sckoen   : std_ulogic;
    enable   : std_ulogic;
    astart   : std_ulogic;
    aready   : std_ulogic;
  end record;

  -- Yet another subset of out type to make it easier for certain tools to
  -- place registers near pads.
  type spi_out_local_lb_type is record
    mosi     : std_ulogic;
    sck      : std_ulogic;
  end record;

  type spi_reg_type is record
    -- SPI registers
    mode     : spi_mode_rec;  -- Mode register
    event    : spi_em_rec;    -- Event register
    mask     : spi_em_rec;    -- Mask register
    lst      : std_ulogic;    -- Only field on command register
    td       : std_logic_vector(31 downto 0);  -- Transmit register
    rd       : std_logic_vector(31 downto 0);  -- Receive register
    slvsel   : std_logic_vector((SLVSEL_SZ-1) downto 0);  -- Slave select register
    aslvsel  : std_logic_vector((SLVSEL_SZ-1) downto 0);  -- Automatic slave select
    --
    uf       : std_ulogic;    -- Slave in underflow condition
    ov       : std_ulogic;    -- Receive overflow condition
    td_occ   : std_ulogic;    -- Transmit register occupied
    rd_free  : std_ulogic;    -- Receive register free (empty)
    txfifo   : spi_fifo;      -- Transmit data FIFO
    rxfifo   : spi_fifo;      -- Receive data FIFO
    rxd      : std_logic_vector(wlen downto 0);  -- Receive shift register
    txd      : std_logic_vector(wlen downto 0);  -- Transmit shift register
    txdupd   : std_ulogic;    -- Update txd
    txdbyp   : std_ulogic;    -- txd update bypass
    toggle   : std_ulogic;    -- SCK has toggled
    samp     : std_ulogic;    -- Sample
    chng     : std_ulogic;    -- Change
    psck     : std_ulogic;    -- Previous value of SC
    twdir    : std_ulogic;    -- Direction in 3-wire mode
    syncsamp : std_logic_vector(1 downto 0);    -- Sample synchronized input
    incrdli  : std_ulogic;
    rxdone   : std_ulogic;
    rxdone2  : std_ulogic;
    running  : std_ulogic;
    ov2      : std_ulogic;
    -- counters
    tfreecnt : integer range 0 to FIFO_DEPTH; -- free td fifo slots
    rfreecnt : integer range 0 to FIFO_DEPTH; -- free td fifo slots
    tdfi     : std_logic_vector(fdepth-1 downto 0);  -- First tx queue element
    rdfi     : std_logic_vector(fdepth-1 downto 0);  -- First rx queue element
    tdli     : std_logic_vector(fdepth-1 downto 0);  -- Last tx queue element
    rdli     : std_logic_vector(fdepth-1 downto 0);  -- Last rx queue element
    rbitcnt  : std_logic_vector(log2(wlen+1)-1 downto 0);  -- Current receive bit
    tbitcnt  : std_logic_vector(log2(wlen+1)-1 downto 0);  -- Current transmit bit
    divcnt   : unsigned(9 downto 0);   -- Clock scaler
    cgcnt    : unsigned(5 downto 0);   -- Clock gap counter
    cgcntblock: std_ulogic;
    aselcnt  : unsigned(1 downto 0);   -- ASEL delay
    cgasel   : std_ulogic;             -- ASEL when entering CG
    --
    irq      : std_ulogic;
    --
    -- Automode
    am       : spi_am_rec;
    -- Sync registers for inputs
    spii     : spi_in_array;
    -- Output
    spio     : spi_out_local_type;
    spiolb   : spi_out_local_lb_type;
    --
    astart   : std_ulogic;
    cstart   : std_ulogic;
    txdupd2  : std_ulogic;
    twdir2   : std_ulogic;
  end record;

  -----------------------------------------------------------------------------
  -- Sub programs
  -----------------------------------------------------------------------------
  -- Returns a vector containing the character length - 1 in bits as selected
  -- by the Mode field LEN.
  function spilen (
    len : std_logic_vector(3 downto 0))
    return std_logic_vector is
  begin  -- spilen
    if len = zero32(3 downto 0) then
      return "11111";
    else
      return "0" & len;
    end if;
  end spilen;

  -- Write clear
  procedure wc (
    reg_o : out std_ulogic;
    reg_i : in  std_ulogic;
    b     : in  std_ulogic) is
  begin
    reg_o := reg_i and not b;
  end procedure wc;

  -- Reverses string. After this function has been called the first bit
  -- to send is always at position 0.
  function reverse(
    data : std_logic_vector)
    return std_logic_vector is
    variable rdata: std_logic_vector(data'reverse_range);
  begin
    for i in data'range loop
      rdata(i) := data(i);
    end loop;
    return rdata;
  end function reverse;

  -- Performs a HWORD swap if len /= 0
  function condhwordswap (
    data : std_logic_vector(31 downto 0);
    len  : std_logic_vector(4 downto 0))
    return std_logic_vector is
    variable rdata : std_logic_vector(31 downto 0);
  begin  -- condhwordswap
    if len = one32(4 downto 0) then
      rdata := data;
    else
      rdata := data(15 downto 0) & data(31 downto 16);
    end if;
    return rdata;
  end condhwordswap;

  -- Zeroes out unused part of receive vector.
  function select_data (
    data : std_logic_vector(wlen downto 0);
    len  : std_logic_vector(4 downto 0))
    return std_logic_vector is
    variable rdata : std_logic_vector(31 downto 0) := (others => '0');
    variable length : integer range 0 to 31 := conv_integer(len);
    variable sdata : std_logic_vector(31 downto 0) := (others => '0');
  begin  -- select_data
    -- Quartus can not handle variable ranges
    -- rdata(conv_integer(len) downto 0) := data(conv_integer(len) downto 0);
    sdata := (others => '0'); sdata(wlen downto 0) := data;
    case length is
      when 15 => rdata(15 downto 0) := sdata(15 downto 0);
      when 14 => rdata(14 downto 0) := sdata(14 downto 0);
      when 13 => rdata(13 downto 0) := sdata(13 downto 0);
      when 12 => rdata(12 downto 0) := sdata(12 downto 0);
      when 11 => rdata(11 downto 0) := sdata(11 downto 0);
      when 10 => rdata(10 downto 0) := sdata(10 downto 0);
      when 9 => rdata(9 downto 0) := sdata(9 downto 0);
      when 8 => rdata(8 downto 0) := sdata(8 downto 0);
      when 7 => rdata(7 downto 0) := sdata(7 downto 0);
      when 6 => rdata(6 downto 0) := sdata(6 downto 0);
      when 5 => rdata(5 downto 0) := sdata(5 downto 0);
      when 4 => rdata(4 downto 0) := sdata(4 downto 0);
      when 3 => rdata(3 downto 0) := sdata(3 downto 0);
      when others => rdata := sdata;
    end case;
    return rdata;
  end select_data;

   -- purpose: Returns true when a slave is selected and the clock starts
  function slv_start (
    spisel   : std_ulogic;
    cpol     : std_ulogic;
    sck      : std_ulogic;
    fsck_chg : std_ulogic)
    return boolean is
  begin  -- slv_start
    if spisel = '0' then          -- Slave is selected
      if fsck_chg = '1' then      -- The clock has changed
        return (cpol xor sck) = '1';    -- The clock is not idle
      end if;
    end if;
    return false;
  end slv_start;

  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
  function spictrl_resval return spi_reg_type is
    variable v : spi_reg_type;
  begin
    v.mode        := ('0','0','0','0','0','0','0','0',"0000","0000",
                      '0','0','0','0',"00000","00", '0', '0', '0', '0');
    v.event       := ('0', '0', '0', '0', '0', '0', '0', '0');
    v.mask        := ('0', '0', '0', '0', '0', '0', '0', '0');
    v.lst         := '0';
    v.td          := (others => '0');
    v.rd          := (others => '0');
    v.slvsel      := (others => '1');
    v.aslvsel     := (others => '0');
    v.uf          := '0';
    v.ov          := '0';
    v.td_occ      := '0';
    v.rd_free     := '1';
    for i in 0 to (1-syncram)*(FIFO_DEPTH-1) loop
      v.txfifo(i) := (others => '0');
      v.rxfifo(i) := (others => '0');
    end loop;
    v.rxd         := (others => '0');
    v.txd         := (others => '0'); v.txd(0) := '1';
    v.txdupd      := '0';
    v.txdbyp      := '0';
    v.toggle      := '0';
    v.samp        := '1';
    v.chng        := '0';
    v.psck        := '0';
    v.twdir       := INPUT;
    v.syncsamp    := (others => '0');
    v.incrdli     := '0';
    v.rxdone      := '0';
    v.rxdone2     := '0';
    v.running     := '0';
    v.ov2         := '0';
    v.tfreecnt    := FIFO_DEPTH;
    v.rfreecnt    := FIFO_DEPTH;
    v.tdfi        := (others => '0');
    v.rdfi        := (others => '0');
    v.tdli        := (others => '0');
    v.rdli        := (others => '0');
    v.rbitcnt     := (others => '0');
    v.tbitcnt     := (others => '0');
    v.divcnt      := (others => '0');
    v.cgcnt       := (others => '0');
    v.cgcntblock  := '0';
    v.aselcnt     := (others => '0');
    v.cgasel      := '0';
    v.irq         := '0';
    v.am.cfg      := ('0', '0', '0', '0', '0', '0', '0', '0', '0');
    v.am.per      := (others => '0');
    v.am.active   := '0';
    v.am.lock     := '0';
    v.am.cnt      := (others => '0');
    v.am.skipdata := '0';
    v.am.rxfull   := '0';
    for i in 0 to (1-syncram)*(FIFO_DEPTH-1) loop
      v.am.rxfifo := (others => (others => '0'));
      v.am.txfifo := (others => (others => '0'));
    end loop;
    v.am.rfreecnt  := 0;
    v.am.mask      := (others => '0');
    v.am.mask_shdw := (others => '1');
    v.am.unread    := (others => '0');
    v.am.at        := '0';
    v.am.rxread    := '0';
    v.am.txwrite   := '0';
    v.am.txread    := '0';
    v.am.apbaddr   := (others => '0');
    v.am.rxsel     := '0';
    for i in 1 downto 0 loop
      v.spii(i).miso   := '1';
      v.spii(i).mosi   := '1';
      v.spii(i).sck    := '0';
      v.spii(i).spisel := '1'; 
    end loop;
    v.spio.miso     := '1';
    v.spio.misooen  := INPUT;
    v.spio.mosi     := '1';
    v.spio.mosioen  := INPUT;
    v.spio.sck      := '0';
    v.spio.sckoen   := INPUT;
    v.spio.enable   := '0';
    v.spio.astart   := '0';
    v.spio.aready   := '0';
    v.spiolb.mosi := '1';
    v.spiolb.sck  := '1';
    v.astart   := '0';
    v.cstart   := '0';
    v.txdupd2  := '0';
    v.twdir2   := '0';
    return v;
  end spictrl_resval;
  constant RES : spi_reg_type := spictrl_resval;
  
  
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  signal r, rin : spi_reg_type;

  type fifo_data_vector_array is array (automode downto 0) of std_logic_vector(wlen downto 0);
  type fifo_addr_vector_array is array (automode downto 0) of std_logic_vector(fdepth-1 downto 0);

  signal rx_di, rx_do, tx_di, tx_do : fifo_data_vector_array;
  signal rx_ra, rx_wa, tx_ra, tx_wa : fifo_addr_vector_array;
  signal rx_read, tx_read, rx_write, tx_write : std_logic_vector(automode downto 0);

  signal arstn : std_ulogic;

begin

  arstn <= apbi_testrst when (scantest = 1) and (apbi_testen = '1') else rstn;

  -- SPI controller, register interface and related logic
  comb: process (r, rstn, apbi_psel, apbi_penable, apbi_paddr, apbi_pwrite,
                 apbi_pwdata, apbi_testen, apbi_testrst, apbi_scanen,
                 apbi_testoen, spii_miso, spii_mosi, spii_sck, spii_spisel,
                 spii_astart, rx_do, tx_do, spii_cstart, spii_ignore)
    variable v        : spi_reg_type;
    variable apbaddr  : std_logic_vector(APBH downto 2);
    variable apbout   : std_logic_vector(31 downto 0);
    variable len      : std_logic_vector(4 downto 0);
    variable indata   : std_ulogic;
    variable change   : std_ulogic;
    variable update   : std_ulogic;
    variable sample   : std_ulogic;
    variable reload   : std_ulogic;
    variable cgasel   : std_ulogic;
    variable txshift  : std_ulogic;
    -- automode
    variable rstop1   : std_ulogic;
    variable rstop2   : std_ulogic;
    variable rstop3   : std_ulogic;
    variable tstop1   : std_ulogic;
    variable tstop2   : std_ulogic;
    variable tstop3   : std_ulogic;
    variable astart   : std_ulogic;
    -- fifos
    variable rx_rd    : std_ulogic;
    variable tx_rd    : std_ulogic;
    variable rx_wr    : std_ulogic;
    variable tx_wr    : std_ulogic;
    --
    variable fsck     : std_ulogic;
    variable fsck_chg : std_ulogic;
    --
    variable spisel   : std_ulogic;
    --
    variable rntxd    : std_logic_vector(0 to 31);
    variable ntxd     : std_logic_vector(wlen downto 0);

    variable amask : std_logic_vector(FIFO_DEPTH-1 downto 0);
    variable aloop : integer;
  begin  -- process comb
    v := r;  v.irq := '0';
    apbaddr := apbi_paddr(APBH downto 2); apbout := (others => '0');
    len := spilen(r.mode.len); v.toggle := '0'; v.txdupd := '0';
    v.syncsamp := r.syncsamp(0) & '0'; update := '0'; v.rxdone := '0';
    indata := '0'; sample := '0'; change := '0'; reload := '0';
    v.spio.astart := '0'; cgasel := '0'; v.ov2 := r.ov; txshift := '0';
    fsck := '0'; fsck_chg := '0'; v.txdbyp := '0';
    spisel := r.spii(1).spisel or r.mode.igsel;
    ntxd := r.td(wlen downto 0); rntxd := reverse(r.td);
    if r.mode.rev = '1' then ntxd := rntxd(31-wlen to 31); end if;

    v.spio.aready := '0';

    if AM_EN = 1 then
      v.txdupd2 := '0';
      v.cstart := '0';
      if TW_EN = 1 then
        v.twdir2 := r.twdir;
      end if;
    end if;

    if PROG_AM_MASK then
      amask := r.am.mask;
      aloop := FIFO_DEPTH-1;
    else
      amask := AM_MASK(FIFO_DEPTH-1 downto 0);
      aloop := AM_MASK_END;
    end if;

    rx_rd := '0'; tx_rd := '0'; rx_wr := '0'; tx_wr := '0';

    rstop1 := '0'; rstop2 := '0'; rstop3 := '0';
    tstop1 := '0'; tstop2 := '0'; tstop3 := '0';

    astart := '0'; v.am.txwrite := '0'; v.am.txwrite := '0'; v.am.rxread := '0';
    if AM_EN = 1 then
      v.am.at := r.event.at;
      v.astart := spii_astart;
      if r.event.at = '0' then
        astart := spii_astart and (not r.astart);
        if PROG_AM_MASK then
          v.am.mask := r.am.mask_shdw;
        end if;
      end if;
      if spii_cstart = '1' then v.cstart := '1'; end if;
    end if;

    if (apbi_psel and apbi_penable and (not apbi_pwrite)) = '1' then
      if apbaddr = CAP_ADDR then
        apbout := SPICTRLCAPREG;
      elsif apbaddr = MODE_ADDR then
        apbout := r.mode.amen & r.mode.loopb & r.mode.cpol & r.mode.cpha &
                  r.mode.div16 & r.mode.rev & r.mode.ms & r.mode.en &
                  r.mode.len & r.mode.pm & r.mode.tw & r.mode.asel &
                  r.mode.fact & r.mode.od & r.mode.cg & r.mode.aseldel &
                  r.mode.tac & r.mode.tto & r.mode.igsel & r.mode.cite &
                  zero32(0);
      elsif apbaddr = EVENT_ADDR then
        apbout := r.event.tip & zero32(30 downto 16) & r.event.at &
                  r.event.lt & zero32(13) & r.event.ov & r.event.un &
                  r.event.mme & r.event.ne & r.event.nf & zero32(7 downto 0);
      elsif apbaddr = MASK_ADDR then
        apbout := r.mask.tip & zero32(30 downto 16) & r.mask.at &
                  r.mask.lt & zero32(13) & r.mask.ov & r.mask.un &
                  r.mask.mme & r.mask.ne & r.mask.nf & zero32(7 downto 0);
      elsif apbaddr = RD_ADDR then
        apbout := condhwordswap(r.rd, len);
        if AM_EN = 0 or r.mode.amen = '0' then
          v.rd_free := '1';
        end if;
      elsif apbaddr = SLVSEL_ADDR then
        if SLVSEL_EN /= 0 then apbout((SLVSEL_SZ-1) downto 0) := r.slvsel;
        else null; end if;
      elsif apbaddr = ASEL_ADDR then
        if ASEL_EN /= 0 then
          apbout((SLVSEL_SZ-1) downto 0) := r.aslvsel;
        else null; end if;
      end if;
    end if;

    -- write registers
    if (apbi_psel and apbi_penable and apbi_pwrite) = '1' then
      if apbaddr = MODE_ADDR then
        if AM_EN = 1 then v.mode.amen := apbi_pwdata(31); end if;
        v.mode.loopb := apbi_pwdata(30);
        v.mode.cpol  := apbi_pwdata(29);
        v.mode.cpha  := apbi_pwdata(28);
        v.mode.div16 := apbi_pwdata(27);
        v.mode.rev   := apbi_pwdata(26);
        v.mode.ms    := apbi_pwdata(25);
        v.mode.en    := apbi_pwdata(24);
        v.mode.len   := apbi_pwdata(23 downto 20);
        v.mode.pm    := apbi_pwdata(19 downto 16);
        if TW_EN = 1 then v.mode.tw := apbi_pwdata(15); end if;
        if ASEL_EN = 1 then v.mode.asel := apbi_pwdata(14); end if;
        v.mode.fact  := apbi_pwdata(13);
        if OD_EN = 1 then v.mode.od := apbi_pwdata(12); end if;
        v.mode.cg    := apbi_pwdata(11 downto 7);
        if ASEL_EN = 1 then
          v.mode.aseldel := apbi_pwdata(6 downto 5);
          v.mode.tac     := apbi_pwdata(4);
        end if;
        if TW_EN = 1 then v.mode.tto := apbi_pwdata(3); end if;
        v.mode.igsel := apbi_pwdata(2);
        v.mode.cite  := apbi_pwdata(1);
      elsif apbaddr = EVENT_ADDR then
        wc(v.event.lt, r.event.lt, apbi_pwdata(14));
        wc(v.event.ov, r.event.ov, apbi_pwdata(12));
        wc(v.event.un, r.event.un, apbi_pwdata(11));
        wc(v.event.mme, r.event.mme, apbi_pwdata(10));
      elsif apbaddr = MASK_ADDR then
        v.mask.tip := apbi_pwdata(31);
        if AM_EN = 1 then
          v.mask.at := apbi_pwdata(15);
        end if;
        v.mask.lt  := apbi_pwdata(14);
        v.mask.ov  := apbi_pwdata(12);
        v.mask.un  := apbi_pwdata(11);
        v.mask.mme := apbi_pwdata(10);
        v.mask.ne  := apbi_pwdata(9);
        v.mask.nf  := apbi_pwdata(8);
      elsif apbaddr =  COM_ADDR then
        v.lst := apbi_pwdata(22);
      elsif apbaddr = TD_ADDR then
        -- The write is lost if the transmit register is written when
        -- the not full bit is zero.
        if r.event.nf = '1' then
          v.td := apbi_pwdata;
          if AM_EN = 0 or r.mode.amen = '0' then
            v.td_occ := '1';
          end if;
        end if;
      elsif apbaddr = SLVSEL_ADDR then
        if SLVSEL_EN /= 0 then v.slvsel := apbi_pwdata((SLVSEL_SZ-1) downto 0);
        else null; end if;
      elsif apbaddr = ASEL_ADDR then
        if ASEL_EN /= 0 then
          v.aslvsel := apbi_pwdata((SLVSEL_SZ-1) downto 0);
        else null; end if;
      end if;
    end if;

    -- Automode register interface
    if AM_EN /= 0 then
      if apbi_psel = '1' then
        v.am.apbaddr := apbaddr(FIFO_BITS+1 downto 2);
        if syncram /= 0 then
          -- Check if tx queue will be read
          if apbaddr(10 downto 9) = AMTX_ADDR(10 downto 9) then
            v.am.txread := apbi_pwrite and not r.am.txread;
          end if;
          if apbaddr(10 downto 9) = AMRX_ADDR(10 downto 9) then
            v.am.rxread := not r.am.rxread;
          end if;
        end if;
      end if;
      if (apbi_psel and apbi_penable) = '1' then
        if apbaddr =  AMCFG_ADDR then
          apbout := zero32(31 downto 9) & r.am.cfg.ecgc & r.am.cfg.lock &
                    r.am.cfg.erpt & r.am.cfg.seq & r.am.cfg.strict &
                    r.am.cfg.ovtb & r.am.cfg.ovdb & r.am.active &
                    r.am.cfg.eact;
          if apbi_pwrite = '1' then
            v.am.cfg.ecgc := apbi_pwdata(8);
            v.am.cfg.lock := apbi_pwdata(7);
            v.am.cfg.erpt := apbi_pwdata(6);
            v.am.cfg.seq  := apbi_pwdata(5);
            v.am.cfg.strict := apbi_pwdata(4);
            v.am.cfg.ovtb := apbi_pwdata(3);
            v.am.cfg.ovdb := apbi_pwdata(2);
            v.am.cfg.act  := apbi_pwdata(1);
            v.spio.astart := apbi_pwdata(1);
            v.am.cfg.eact := apbi_pwdata(0);
          end if;
        elsif apbaddr =  AMPER_ADDR then
          apbout((AM_CNT_BITS-1)*AM_EN downto 0) := r.am.per;
          if apbi_pwrite = '1' then
            v.am.per := apbi_pwdata((AM_CNT_BITS-1)*AM_EN downto 0);
          end if;
        elsif apbaddr = AMMSK0_ADDR then
          if FIFO_DEPTH > 32 then
            apbout := amask(31 downto 0);
            if PROG_AM_MASK then
              if apbi_pwrite = '1' then
                v.am.mask_shdw(31 downto 0) := apbi_pwdata;
              end if;
            end if;
          else
            apbout(FIFO_DEPTH-1 downto 0) := amask(FIFO_DEPTH-1 downto 0);
            if PROG_AM_MASK then
              if apbi_pwrite = '1' then
                v.am.mask_shdw(FIFO_DEPTH-1 downto 0) := apbi_pwdata(FIFO_DEPTH-1 downto 0);
              end if;
            end if;
          end if;
        elsif apbaddr = AMMSK1_ADDR then
          if AM_MSK1_EN then
            if FIFO_DEPTH > 64 then
              apbout := amask(63 downto 32);
              if PROG_AM_MASK then
                if apbi_pwrite = '1' then
                  v.am.mask_shdw(63 downto 32) := apbi_pwdata;
                end if;
              end if;
            else
              apbout(FIFO_DEPTH-33 downto 0) := amask(FIFO_DEPTH-1 downto 32);
              if PROG_AM_MASK then
                if apbi_pwrite = '1' then
                  v.am.mask_shdw(FIFO_DEPTH-1 downto 32) := apbi_pwdata(FIFO_DEPTH-33 downto 0);
                end if;
              end if;
            end if;
          else
            null;
          end if;
        elsif apbaddr = AMMSK2_ADDR then
          if AM_MSK2_EN then
            if FIFO_DEPTH > 96 then
              apbout := amask(95 downto 64);
              if PROG_AM_MASK then
                if apbi_pwrite = '1' then
                  v.am.mask_shdw(95 downto 64) := apbi_pwdata;
                end if;
              end if;
            else
              apbout(FIFO_DEPTH-65 downto 0) := amask(FIFO_DEPTH-1 downto 64);
              if PROG_AM_MASK then
                if apbi_pwrite = '1' then
                  v.am.mask_shdw(FIFO_DEPTH-1 downto 64) := apbi_pwdata(FIFO_DEPTH-65 downto 0);
                end if;
              end if;
            end if;
          else
            null;
          end if;
        elsif apbaddr = AMMSK3_ADDR then
          if AM_MSK3_EN then
            apbout(FIFO_DEPTH-97 downto 0) := amask(FIFO_DEPTH-1 downto 96);
            if PROG_AM_MASK then
              if apbi_pwrite = '1' then
                v.am.mask_shdw(FIFO_DEPTH-1 downto 96) := apbi_pwdata(FIFO_DEPTH-97 downto 0);
              end if;
            end if;
          else
            null;
          end if;
        elsif apbaddr(10 downto 9) = AMTX_ADDR(10 downto 9) then
          if conv_integer(apbaddr(8 downto 2)) < FIFO_DEPTH then
            if syncram = 0 then
              apbout(wlen downto 0) :=
                r.am.txfifo(conv_integer(apbaddr(FIFO_BITS+1 downto 2)));
            else
              apbout(wlen downto 0) := tx_do(automode);
            end if;
            if apbi_pwrite = '1' then
              v.am.txwrite := '1';
              v.td := apbi_pwdata;
            end if;
          end if;
        elsif apbaddr(10 downto 9) = AMRX_ADDR(10 downto 9) then
          if conv_integer(apbaddr(8 downto 2)) < FIFO_DEPTH then
            if syncram = 0 then
              if r.mode.rev = '0' then
                apbout := condhwordswap(reverse(select_data(r.rxfifo(conv_integer(r.am.apbaddr)), len)), len);
              else
                apbout := condhwordswap(select_data(r.rxfifo(conv_integer(r.am.apbaddr)), len), len);
              end if;
            else
              if r.mode.rev = '0' then
                apbout := condhwordswap(reverse(select_data(rx_do(conv_integer(not r.am.rxsel)), len)), len);
              else
                apbout := condhwordswap(select_data(rx_do(conv_integer(not r.am.rxsel)), len), len);
              end if;
            end if;
            if r.am.unread(conv_integer(r.am.apbaddr)) = '1' then
              v.rd_free := '1';
              v.am.unread(conv_integer(r.am.apbaddr)) := '0';
              v.am.lock := r.am.cfg.lock;
            end if;
          end if;
        end if;
      end if;
    end if;

    -- Handle transmit FIFO
    if r.td_occ = '1' and r.tfreecnt /= 0 then
      if syncram = 0 then
        v.txfifo(conv_integer(r.tdli)) := ntxd;
      else
        tx_wr := '1';
      end if;
      v.tdli := r.tdli + 1;
      v.tfreecnt := r.tfreecnt - 1;
      v.td_occ := '0';
      if r.tfreecnt = FIFO_DEPTH then
        v.txdbyp := r.running and r.mode.ms and r.txdupd;
        v.txdupd := not r.uf;
        tx_rd := '1';
      end if;
    end if;
    -- AM transmit FIFO handling when core is not implemented with SYNCRAM
    if syncram = 0 and AM_EN /= 0 and r.am.txwrite = '1' then
      if r.mode.rev = '0' then
        v.am.txfifo(conv_integer(r.am.apbaddr)) := r.td(wlen downto 0);
      else
        v.am.txfifo(conv_integer(r.am.apbaddr)) := reverse(r.td)(31-wlen to 31);
      end if;
    end if;

    -- Update receive register and FIFO
    if r.rd_free = '1' and r.rfreecnt /= FIFO_DEPTH then
      if syncram = 0 then
        if r.mode.rev = '0' then
          v.rd := reverse(select_data(r.rxfifo(conv_integer(r.rdfi)), len));
        else
          v.rd := select_data(r.rxfifo(conv_integer(r.rdfi)), len);
        end if;
      else
        if r.mode.rev = '0' then
          v.rd := reverse(select_data(rx_do(0), len));
        else
          v.rd := select_data(rx_do(0), len);
        end if;
      end if;
      if not ((ignore > 0) and (spii_ignore = '1')) then
        v.rdfi := r.rdfi + 1;
        v.rfreecnt := r.rfreecnt + 1;
        v.rd_free := '0';
      end if;
    end if;
    if v.rd_free = '1' and r.rfreecnt /= FIFO_DEPTH then rx_rd := '1'; end if;

    if r.mode.en = '1' then             -- Core is enabled
      -- Not full detection
      if r.tfreecnt /= 0 or r.td_occ /= '1' then
        v.event.nf := '1';
        if (r.mask.nf and not r.event.nf) = '1' then
          v.irq := '1';
        end if;
      else
        v.event.nf := '0';
      end if;

      -- Not empty detection
      if ((AM_EN = 0 or r.mode.amen = '0') and (r.rfreecnt /= FIFO_DEPTH or r.rd_free /= '1')) or
        (AM_EN = 1 and r.mode.amen = '1' and r.am.unread /= zero128(FIFO_DEPTH-1 downto 0)) then
        v.event.ne := '1';
        if (r.mask.ne and not r.event.ne) = '1' then
          v.irq := '1';
        end if;
      else
        v.event.ne := '0';
        if AM_EN = 1 then v.am.lock := '0'; end if;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Automated periodic transfer control
    ---------------------------------------------------------------------------
    if AM_EN = 1 and r.mode.amen = '1' then
      if r.am.active = '0' then
        -- Activation either from register write or external event.
        v.am.active := r.spio.astart or (astart and r.am.cfg.eact);
        v.am.cfg.act := v.am.active;
        v.am.rfreecnt := 0;
        for i in 0 to aloop loop
          if amask(i) = '1' then
            v.am.rfreecnt := v.am.rfreecnt+1;
          end if;
        end loop;
        v.am.skipdata := '0'; v.am.rxfull := '0';
        v.am.cnt := unsigned(r.am.per);
        v.event.at := v.am.active;
        v.tdfi := (others => '0');
        -- Check mask to see which word in the FIFO to start with.
        for i in 0 to aloop loop
          if amask(i) = '1' then
            if tstop1 = '0' then
              v.tdfi := conv_std_logic_vector(i, r.tdfi'length);
            end if;
            tstop1 := '1';
          end if;
        end loop;
        if v.am.active = '1' then
          v.txdupd2 := '1'; tx_rd := '1';
          v.tfreecnt := FIFO_DEPTH;
          for i in 0 to aloop loop
            if amask(i) = '1' then
              v.tfreecnt := v.tfreecnt-1;
            end if;
          end loop;
        end if;
        v.rdli := (others => '0');
        for i in 0 to aloop loop
          if rstop1 = '0' then
            if amask(i) = '0' then
              v.rdli := v.rdli + 1;
            else
              rstop1 := '1';
            end if;
          end if;
        end loop;
        v.cstart := v.am.active;
      else
        -- Receive fifo handling
        if r.am.rxfull = '1' then           -- AM RX fifo is filled
          -- Move to receive queue if the queue is empty or if there is no
          -- requirement on sequential transfers and the queue is not locked.
          if (r.event.ne and (v.am.lock or r.am.cfg.seq)) = '0' then
            -- Queue is empty
            if syncram = 0 then
              v.rxfifo := r.am.rxfifo;
            else
              v.am.rxsel := not r.am.rxsel;
            end if;
            v.rdfi := (others => '0');
            v.rfreecnt := r.am.rfreecnt;
            v.rd_free := '0';
            v.am.rxfull := '0';
            for i in 0 to aloop loop
              if amask(i) = '1' then
                v.am.unread(i) := '1';
              end if;
            end loop;
          end if;
          if r.event.tip = '0' and r.am.at = '1' then
            v.event.at := '0';
          end if;
          if (r.mask.at and r.event.at) = '1' then
            v.irq := '1';
          end if;
        end if;
        if r.am.cfg.act = '0' then v.am.active := r.running; end if;
        v.am.cfg.eact := '0';
        if (r.am.cnt = 0 and r.am.cfg.erpt = '0') or (astart = '1' and r.am.cfg.erpt = '1') then
          -- Only allowed to start new transfer if previous transfer(s) is finished
          if r.event.tip = '0' then
            if (not v.am.rxfull or r.am.cfg.strict) = '1' then
              v.am.cnt := unsigned(r.am.per);
            end if;
            if (not v.am.rxfull or (r.am.cfg.strict and not r.am.cfg.ovtb)) = '1' then
              -- Start transfer. Initialize indexes and fifo counter
              v.txdupd2 := '1'; tx_rd := '1';
              v.am.cnt := unsigned(r.am.per);
              v.rdli := (others => '0');
              for i in 0 to aloop loop
                if rstop2 = '0' then
                  if amask(i) = '0' then
                    v.rdli := v.rdli + 1;
                  else
                    rstop2 := '1';
                  end if;
                end if;
              end loop;
              v.tfreecnt := FIFO_DEPTH;
              v.am.rfreecnt := 0;
              for i in 0 to aloop loop
                if amask(i) = '1' then
                  v.am.rfreecnt := v.am.rfreecnt+1;
                  v.tfreecnt := v.tfreecnt-1;
                end if;
              end loop;
              v.tdfi := (others => '0');
              -- Check mask to see which word in the FIFO to start with.
              for i in 0 to aloop loop
                if amask(i) = '1' then
                  if tstop2 = '0' then
                    v.tdfi := conv_std_logic_vector(i, r.tdfi'length);
                  end if;
                  tstop2 := '1';
                end if;
              end loop;
              -- Skip incoming data if receive FIFO is full and OVDB is '1'.
              v.am.skipdata := v.am.rxfull and r.am.cfg.ovdb;
              if v.am.skipdata = '0' then
                -- Clear AM receive fifo if we will overwrite it.
                v.am.rfreecnt := FIFO_DEPTH;
                for i in 0 to aloop loop
                  if amask(i) = '0' then
                    v.am.rfreecnt := v.am.rfreecnt-1;
                  end if;
                end loop;
                v.am.rxfull := '0';
              end if;
              v.event.at := '1';
              v.cstart := astart and r.am.cfg.erpt;
            end if;
          end if;
        else
          v.am.cnt := r.am.cnt - 1;
        end if;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- SCK filtering, only used in slave mode
    ---------------------------------------------------------------------------
    fsck := r.psck;
    if (r.mode.en and not r.mode.ms) = '1' then
      if (r.spii(1).sck xor r.psck) = '0' then
        reload := '1';
      else
        -- Detected SCK change
        if r.divcnt = 0 then
          v.psck := r.spii(1).sck;
          fsck := r.spii(1).sck;
          fsck_chg := '1';
          reload := '1';
        else
          v.divcnt := r.divcnt - 1;
        end if;
      end if;
    elsif r.mode.en = '1' then
      v.psck := r.spii(1).sck;
    end if;

    ---------------------------------------------------------------------------
    -- SPI bus control
    ---------------------------------------------------------------------------
    if (r.mode.en and not r.running) = '1' and (r.mode.ms = '0' or r.divcnt = 0) then
      if r.mode.ms = '1' then
        if r.divcnt = 0 then
          v.spio.sck := r.mode.cpol;
        end if;
        v.spio.misooen := INPUT;
        if TW_EN = 0 or r.mode.tw = '0' then
          if OD_EN = 0 or r.mode.od = '0' then
            v.spio.mosioen := OUTPUT;
          end if;
        else
          v.spio.mosioen := INPUT;
        end if;
        v.spio.sckoen := OUTPUT;
        if TW_EN = 1 then v.twdir := OUTPUT xor r.mode.tto; end if;
      else
        if (spisel or r.mode.tw) = '0' then
          v.spio.misooen := OUTPUT;
        else
          v.spio.misooen := INPUT;
        end if;
        if (not spisel and r.mode.tw and r.mode.tto) = '0' then
          v.spio.mosioen := INPUT;
        else
          v.spio.mosioen := OUTPUT;
        end if;
        v.spio.sckoen := INPUT;
        if TW_EN = 1 then v.twdir := INPUT xor r.mode.tto; end if;
      end if;
      if ((((AM_EN = 0 or r.mode.amen = '0') or
            (AM_EN = 1 and r.mode.amen = '1' and r.am.active = '1')) and
           r.mode.ms = '1' and r.tfreecnt /= FIFO_DEPTH and r.txdupd = '0' and (AM_EN = 0 or r.txdupd2 = '0')) or
          slv_start(spisel, r.mode.cpol, fsck, fsck_chg)) then
        -- Slave underrun detection
        if r.tfreecnt = FIFO_DEPTH then
          v.uf := '1';
          if (r.mask.un and not v.event.un) = '1' then
            v.irq := '1';
          end if;
          v.event.un := '1';
        end if;
        v.running := '1';
        if r.mode.ms = '1' then
          if TW_EN = 0 or r.mode.tw = '0' then
            v.spio.mosioen := OUTPUT;
          else
            v.spio.mosioen := OUTPUT xor r.mode.tto;
          end if;
          change := not r.mode.cpha;
          -- Insert cycles when cpha = '0' to ensure proper setup
          -- time for first MOSI value in master mode.
          reload := not r.mode.cpha;
        end if;
      end if;
      v.cgcnt := (others => '0');
      v.rbitcnt := (others => '0'); v.tbitcnt := (others => '0');
      if r.mode.ms = '0' then
        update := not (r.mode.cpha or (fsck xor r.mode.cpol));
        if r.mode.cpha = '0' then
          -- Prepare first bit
          v.tbitcnt := (others => '0'); v.tbitcnt(0) := '1';
          if v.running = '1' and (TW_EN = 0 or r.mode.tw = '0' or r.twdir = OUTPUT) then
            txshift := '1';
          end if;
        end if;
      end if;

      -- samp and chng should not be changed on b2b
      if spisel /= '0' then
        v.samp := not r.mode.cpha;
        v.chng := r.mode.cpha;
        v.psck := r.mode.cpol;
      end if;
    end if;

    if AM_EN = 0 or r.mode.amen = '0' or r.am.cfg.ecgc = '0' then
      v.cgcntblock := '0';
    else
      if r.cstart = '1' then
        v.cgcntblock := '0';
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Clock generation, only in master mode
    ---------------------------------------------------------------------------
    if r.mode.ms = '1' and (r.running = '1' or r.divcnt /= 0) then
      -- The frequency of the SPI clock relative to the system clock is
      -- determined by the fact, div16 and pm register fields.
      --
      -- With fact = 0 the fields have the same meaning as in the MPC83xx
      -- register interface. The clock is divided by 4*([PM]+1) and if div16
      -- is set the clock is divided by 16*(4*([PM]+1)).
      --
      -- With fact = 1 the core's register i/f is no longer compatible with
      -- the MPC83xx register interface. The clock is divided by 2*([PM]+1) and
      -- if div16 is set the clock is divided by 16*(2*([PM]+1)).
      --
      -- The generated clock's duty cycle is always 50%.
      if r.divcnt = 0 then
        if ASEL_EN = 0 or r.aselcnt = 0 then
          -- Toggle SCK unless we are in a clock gap
          if (r.cgcnt = 0 and (AM_EN = 0 or r.cgcntblock = '0')) or
            r.spiolb.sck /= r.mode.cpol then
            v.spio.sck := not r.spiolb.sck;
            v.toggle := r.running;
          end if;
          if r.cgcnt /= 0 and (AM_EN = 0 or r.cgcntblock = '0') then
            v.cgcnt := r.cgcnt - 1;
            if ASEL_EN /= 0 and r.cgcnt = 1 then
              cgasel := r.mode.tac;
            end if;
          end if;
        elsif ASEL_EN = 1 then
          v.aselcnt := r.aselcnt - 1;
        end if;
        reload := '1';
      else
        v.divcnt := r.divcnt - 1;
      end if;
    elsif r.mode.ms = '1' then
      v.divcnt := (others => '0');
    end if;

    if reload = '1' then
      -- Reload clock scale counter
      v.divcnt(4 downto 0) := unsigned('0' & r.mode.pm) + 1;
      if (not r.mode.fact and r.mode.ms) = '1' then
        if r.mode.div16 = '1' then
          v.divcnt := shift_left(v.divcnt, 5) - 1;
        else
          v.divcnt := shift_left(v.divcnt, 1) - 1;
        end if;
      else
        if (r.mode.div16 and r.mode.ms) = '1' then
          v.divcnt := shift_left(v.divcnt, 4) - 1;
        else
          v.divcnt(9 downto 4) := (others => '0');
          v.divcnt(3 downto 0) := unsigned(r.mode.pm);
        end if;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Handle master operation.
    ---------------------------------------------------------------------------
    if r.mode.ms = '1' then
      -- Sample data
      if r.toggle = '1' then
        v.samp := not r.samp;
        sample := r.samp;
      end if;

      -- Change data on the clock flank...
      if v.toggle  = '1' then
        v.chng := not r.chng;
        change := r.chng;
      end if;

      -- Detect multiple-master errors (mode-fault)
      if spisel = '0' then
        v.mode.en := '0';
        v.mode.ms := '0';
        v.event.mme := '1';
        if (r.mask.mme and not r.event.mme) = '1' then
          v.irq := '1';
        end if;
        v.running := '0';
        v.event.tip := '0';
        if AM_EN = 1 then
          v.event.at := '0';
        end if;
      end if;

      -- Select input data
      if r.mode.loopb = '1' then
        indata := r.spiolb.mosi;
      elsif TW_EN = 1 and r.mode.tw = '1' then
        indata := r.spii(1).mosi;
      else
        indata := r.spii(1).miso;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Handle slave operation
    ---------------------------------------------------------------------------
    if (r.mode.en and not r.mode.ms) = '1' then
      if spisel = '0' then
        if fsck_chg = '1' then
          sample := r.samp; v.samp := not r.samp;
          change := r.chng; v.chng := not r.chng;
        end if;
        indata := r.spii(1).mosi;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Used in both master and slave operation
    ---------------------------------------------------------------------------
    if sample = '1' then
      -- Detect receive overflow
      if ((AM_EN = 0 or r.mode.amen = '0' ) and (r.rfreecnt = 0 and r.rd_free = '0')) or
        (AM_EN = 1 and r.mode.amen = '1' and r.am.rfreecnt = 0) or
        r.ov = '1' then
        if TW_EN = 0 or r.mode.tw = '0' or r.twdir = INPUT then
          -- Overflow event and IRQ
          v.ov := '1';
          if r.ov = '0' then
            if (r.mask.ov and not r.event.ov) = '1' then
              v.irq := '1';
            end if;
            v.event.ov := '1';
          end if;
        end if;
        sample := '0';                  -- Prevent sample below
      else
        sample := not r.mode.ms or r.mode.loopb;
        v.syncsamp(0) := not sample;
      end if;
      if r.rbitcnt = len(log2(wlen+1)-1 downto 0) then
        v.rbitcnt := (others => '0');
        if TW_EN = 1 then
          v.twdir := r.twdir xor not r.mode.loopb;
        end if;
        if (TW_EN = 0 or r.mode.tw = '0' or r.mode.loopb = '1' or
            (r.mode.tw = '1' and r.twdir = INPUT)) then
          v.incrdli := not r.ov;
        end if;
        if (TW_EN = 0 or r.mode.tw = '0' or r.mode.loopb = '1' or
            (TW_EN = 1 and r.mode.tw = '1' and
             (((r.mode.ms xor r.mode.tto) = '1' and r.twdir = INPUT) or
              ((r.mode.ms xor r.mode.tto) = '0' and r.twdir = OUTPUT)))) then
          if r.mode.cpha = '0' then
            v.cgcnt := unsigned(r.mode.cg & '0');
            if ASEL_EN /= 0 then v.cgasel := r.mode.tac; end if;
            if AM_EN = 1 and r.mode.amen = '1' and r.am.cfg.ecgc = '1' then
              v.cgcntblock := '1';
            end if;
          end if;
          v.ov := '0';
          if r.tfreecnt = FIFO_DEPTH then
            v.running := '0';
            -- When running with with SCK freq. at half the system freq. we are
            -- past the last edge here and SCK has transitioned from CPOL.
            -- Force controller into idle state, only applies to master mode.
            if (r.toggle and v.toggle) = '1' then
              v.toggle := '0';
              v.spio.sck := r.mode.cpol;
              v.chng := r.chng;
            end if;
          end if;
          v.uf := '0';
        end if;
      else
        v.rbitcnt := r.rbitcnt + 1;
      end if;
    end if;

    -- Sample data line and put into shift register.
    if (r.syncsamp(1) or sample) = '1' then
      v.rxd := r.rxd(wlen-1 downto 0) & indata;
      if ((r.syncsamp(1) and r.incrdli) or (sample and v.incrdli)) = '1' then
        v.rxdone := '1'; v.rxdone2 := '1'; v.incrdli := '0';
      end if;
    end if;

    -- Put data into receive queue
    if ((AM_EN = 0 or (r.mode.amen and r.am.skipdata) = '0') and
        r.rxdone = '1') then
      if AM_EN = 1 and r.am.active = '1'then
        if not ((ignore > 0) and (spii_ignore = '1')) then
          -- Check mask, maybe we need to skip next word in fifo
          v.rdli := r.rdli + 1;
          v.am.rfreecnt := v.am.rfreecnt - 1;
          if DISCONT_AM_MASK then
            for i in 0 to aloop loop
              if i > conv_integer(r.rdli) and rstop3 = '0' then
                if amask(i) = '0' then
                  v.rdli := v.rdli + 1;
                else
                  rstop3 := '1';
                end if;
              end if;
            end loop;
          end if;
        end if;
      else
        v.rdli := r.rdli + 1;
        v.rfreecnt := v.rfreecnt - 1;
        rx_rd := v.rd_free;
      end if;
      if syncram = 0 then
        if AM_EN = 1 and r.am.active = '1' then
          v.am.rxfifo(conv_integer(r.rdli)) := r.rxd;
        else
          v.rxfifo(conv_integer(r.rdli)) := r.rxd;
        end if;
      else
        rx_wr := '1';
      end if;
      if r.running = '0' then
        if AM_EN = 1 then v.am.rxfull := r.am.active; end if;
      end if;
    end if;
    if AM_EN = 1 and r.mode.amen = '1' then
      if TW_EN = 0 or r.mode.tw = '0' or r.mode.tto = '0' then
        if r.rxdone = '1' then
          v.spio.aready := '1';
        end if;
      else
        if r.twdir = '1' and r.twdir2 = '0' then
          v.spio.aready := '1';
        end if;
      end if;
    end if;

    -- Special case to put data in receive queue for automatic
    -- transfer while in three wire mode with tto = 1
    if AM_EN = 1 and TW_EN = 1 and r.mode.amen = '1' and
      r.mode.tw = '1' and r.running = '0' and r.rxdone2 = '1' and
      r.mode.tto = '1' and r.twdir = INPUT and r.mode.ms = '1' then
      v.am.rxfull := r.am.active;
    end if;

    -- Advance transmit queue
    if change = '1' then
      if TW_EN = 1 and r.mode.tw = '1' then
        v.spio.mosioen := r.twdir;
      end if;
      if r.tbitcnt = len(log2(wlen+1)-1 downto 0) then
        if (TW_EN = 0 or r.mode.tw = '0' or r.mode.loopb = '1' or
            (TW_EN = 1 and r.mode.tw = '1' and
             (((r.mode.ms xor r.mode.tto) = '1' and r.twdir = INPUT) or
              ((r.mode.ms xor r.mode.tto) = '0' and r.twdir = OUTPUT)))) then
          if r.mode.cpha = '1' then
            v.cgcnt := unsigned(r.mode.cg & '0');
            if ASEL_EN /= 0 then v.cgasel := r.mode.tac; end if;
            if AM_EN = 1 and r.mode.amen = '1' and r.am.cfg.ecgc = '1' then
              v.cgcntblock := '1';
            end if;
          end if;
        end if;
        if (TW_EN = 0 or r.mode.tw = '0' or r.mode.loopb = '1' or r.twdir = OUTPUT) then
          if r.uf = '0' then
            if not ((ignore > 0) and (spii_ignore = '1')) then
              v.tfreecnt := v.tfreecnt + 1;
            end if;
          end if;
          v.txdupd := '1'; tx_rd := '1';
        end if;
        v.tbitcnt := (others => '0');
      else
        v.tbitcnt := r.tbitcnt + 1;
      end if;
      if v.uf = '0' and (TW_EN = 0 or r.mode.tw = '0' or r.mode.loopb = '1' or r.twdir = OUTPUT) then
        txshift := v.running;
      end if;
    end if;

    if txshift = '1' then
      v.txd := '1' & r.txd(wlen downto 1);
    end if;

    if AM_EN = 1 then
      if r.txdupd2 = '1' then
        tx_rd := '1';
        v.txdupd := '1';
      end if;
    end if;
    if r.txdupd = '1' then
      tx_rd := '1';
      if r.txdbyp = '0' then
        if syncram = 0 then
          if AM_EN = 1 and r.mode.amen = '1' then
            v.txd := r.am.txfifo(conv_integer(r.tdfi));
          else
            v.txd := r.txfifo(conv_integer(r.tdfi));
          end if;
        else
          -- The first FIFO is always used when using syncrams, even in AM mode
          v.txd := tx_do(0);
        end if;
      end if;
      -- Data written to TD, bypass
      if v.txdbyp = '1' then
       v.txd := ntxd;
      end if;
      if r.tfreecnt /= FIFO_DEPTH then
        if AM_EN = 0 or r.mode.amen = '0' then
          v.tdfi := v.tdfi + 1;
        else
          -- Check mask, might need to skip next word
          if not (((ignore > 0) and (spii_ignore = '1'))) then
             if DISCONT_AM_MASK then
               for i in 0 to aloop loop
                 if tstop3 = '0' and i > conv_integer(v.tdfi) then
                   if amask(i) = '0' then
                     v.tdfi := v.tdfi + 1;
                   else
                     tstop3 := '1';
                   end if;
                 end if;
               end loop;
             end if;
             v.tdfi := v.tdfi + 1;
           end if;
        end if;
      elsif v.txdbyp = '0' then
        -- Bus idle value
        v.txd(0) := '1';
      end if;
    end if;

    -- Transmit bit
    if (change or update) = '1' then
      if v.uf = '0' then
        v.spio.miso := r.txd(0);
        v.spio.mosi := r.txd(0);
        if OD_EN = 1 and r.mode.od = '1' then
          if (r.mode.ms or r.mode.tw) = '1' then
            v.spio.mosioen := r.txd(0) xor OUTPUT;
          else
            v.spio.misooen := r.txd(0) xor OUTPUT;
          end if;
        end if;
      else
        v.spio.miso := '1';
        v.spio.mosi := '1';
        if OD_EN = 1 and r.mode.od = '1' then
          v.spio.misooen := INPUT;
          v.spio.mosioen := INPUT;
        end if;
      end if;
    end if;

    -- Transfer in progress interrupt generation
    if (not r.running and (r.ov2 or (r.rxdone2 or (not r.mode.ms and r.mode.tw)))) = '1' then
      if r.mode.ms = '0' or r.mode.cite = '0' or r.divcnt = 0 then
        v.event.tip := '0'; v.rxdone2 := '0';
      end if;
    end if;
    if v.running = '1' then v.event.tip := '1'; end if;
    if (v.running and not r.event.tip and r.mask.tip and r.mode.en) = '1' then
      v.irq := '1';
    end if;

    -- LST detection and interrupt generation
    if v.running = '0' and v.tfreecnt = FIFO_DEPTH and r.lst = '1' then
      v.event.lt := '1'; v.lst := '0';
      if (r.mask.lt and not r.event.lt) = '1' then v.irq := '1'; end if;
    end if;

    ---------------------------------------------------------------------------
    -- Automatic slave select, only in master mode
    ---------------------------------------------------------------------------
    if ASEL_EN /= 0 then
      if (r.mode.ms and r.mode.asel) = '1' then
        if ((not r.running and v.running) or  -- Transfer start or
            (r.event.tip and not v.event.tip) or  -- transfer end or
            (v.running and (cgasel or   -- End or start of CG
            (r.cgasel and not (r.spiolb.sck xor r.mode.cpol))))) = '1'
        then
          v.slvsel := r.aslvsel;
          v.aslvsel := r.slvsel;
          v.cgasel := '0';
        end if;
        -- May need to delay start of transfer
        if ((not r.running and v.running) or cgasel) = '1' then  -- Transfer start
          v.aselcnt := unsigned(r.mode.aseldel);
        end if;
      else
        v.cgasel := '0';
        v.aselcnt := (others => '0');
      end if;
    end if;

    -- Do not toggle outputs in loopback mode
    if (r.mode.loopb = '1' or
        (r.mode.tw = '1' and TW_EN = 1 and r.twdir = INPUT)) then
      v.spio.mosioen := INPUT; v.spio.misooen := INPUT;
    end if;
    if r.mode.loopb = '1' then v.spio.sckoen  := INPUT; end if;

    -- When driving in OD mode, always drive low.
    if OD_EN = 1 and (r.mode.od and not r.mode.loopb) = '1' then
      v.spio.miso := v.spio.miso and not r.mode.od;
      v.spio.mosi := v.spio.mosi and not r.mode.od;
    end if;

    -- Core is disabled
    if ((not RESET_ALL) and rstn = '0') or (r.mode.en = '0') then
      v.tfreecnt := FIFO_DEPTH;
      v.rfreecnt := FIFO_DEPTH;
      v.tdfi := RES.tdfi; v.rdfi := RES.rdfi;
      v.tdli := RES.tdli; v.rdli := RES.rdli;
      v.rd_free := RES.rd_free;
      v.td_occ := RES.td_occ;
      v.lst := RES.lst;
      v.uf := RES.uf;
      v.ov := RES.ov;
      v.running := RES.running;
      v.event.tip := RES.event.tip;
      v.incrdli := RES.incrdli;
      if TW_EN = 1 then
        v.twdir := RES.twdir;
      end if;
      v.spio.miso := RES.spio.miso;
      v.spio.mosi := RES.spio.mosi;
      if syncrst = 1 or (r.mode.en = '0') then
        v.spio.misooen := RES.spio.misooen;
        v.spio.mosioen := RES.spio.mosioen;
        v.spio.sckoen  := RES.spio.sckoen;
      end if;
      if AM_EN = 1 then
        v.event.at := RES.event.at;
      end if;
      -- Need to assign samp, chng and psck here if spisel is low when the
      -- core is enabled
      v.samp := not r.mode.cpha;
      v.chng := r.mode.cpha;
      v.psck := r.mode.cpol;
      if AM_EN = 1 then
        v.am.active := RES.am.active;
        v.am.cfg.act := RES.am.cfg.act;
        v.am.cfg.eact := RES.am.cfg.eact;
        v.am.unread := RES.am.unread;
        v.am.rxsel := RES.am.rxsel;
      end if;
      v.rxdone2 := '0';
      v.divcnt := (others => '0');
    end if;

    -- Chip reset
    if (not RESET_ALL) and (rstn = '0') then
      v.mode := RES.mode;
      v.event.tip := RES.event.tip;
      v.event.lt := RES.event.lt;
      v.event.ov := RES.event.ov;
      v.event.un := RES.event.un;
      v.event.mme := RES.event.mme;
      v.event.ne := RES.event.ne;
      v.event.nf := RES.event.nf;
      v.mask := RES.mask;
      if AM_EN = 1 then
        v.event.at := RES.event.at;
        if PROG_AM_MASK then
          v.am.mask_shdw := RES.am.mask_shdw;
        end if;
        v.am.per := RES.am.per;
        v.am.cfg := RES.am.cfg;
        v.am.rxread  := RES.am.rxread;
        v.am.txwrite := RES.am.txwrite;
        v.am.txread  := RES.am.txread;
        v.am.apbaddr := RES.am.apbaddr;
        v.am.rxsel := RES.am.rxsel;
        v.cgcntblock := RES.cgcntblock;
      end if;
      v.lst := RES.lst;
      if syncrst = 1 then
        v.slvsel := RES.slvsel;
      end if;
      v.cgcnt := RES.cgcnt;
      v.rbitcnt := RES.rbitcnt; v.tbitcnt := RES.tbitcnt;
      v.txd := RES.txd;
    end if;

    -- Drive unused bit if open drain mode is not supported
    if OD_EN = 0 then v.mode.od := '0'; end if;

    -- Drive unused bits if automode is not supported
    if AM_EN = 0 then
      v.mode.amen := '0';
      --
      v.am.cfg.seq := '0';
      v.am.cfg.strict := '0';
      v.am.cfg.ovtb := '0';
      v.am.cfg.ovdb := '0';
      v.am.cfg.act := '0';
      v.am.cfg.eact := '0';
      v.am.per := (others => '0');
      v.am.active := '0';
      v.am.lock := '0';
      v.am.skipdata := '0';
      v.am.rxfull := '0';
      v.am.rfreecnt := 0;
      v.event.at := '0';
      v.am.unread := (others=>'0');
      v.am.cfg.erpt := '0';
      v.am.cfg.lock := '0';
      v.am.cfg.ecgc := '0';
      v.am.cnt := (others=>'0');
      v.am.rxread  := '0';
      v.am.txwrite := '0';
      v.am.txread  := '0';
      v.am.apbaddr := (others => '0');
      v.am.rxsel := '0';
      v.mask.at := '0';
      v.cstart := '0';
    end if;

    if AM_EN = 0 or not PROG_AM_MASK then
      v.am.mask := (others=>'0');
      v.am.mask_shdw := (others=>'0');
    end if;

    -- Drive unused bits if automatic slave select is not enabled
    if ASEL_EN = 0 then
      v.mode.asel := '0';
      v.aslvsel := (others => '0');
      v.mode.aseldel := (others => '0');
      v.mode.tac := '0';
      v.aselcnt := (others => '0');
      v.cgasel := '0';
    end if;

    -- Drive unused bits if three-wire mode is not enabled
    if TW_EN = 0 then
      v.mode.tw := '0';
      v.mode.tto := '0';
      v.twdir := INPUT;
    end if;
    if TW_EN = 0 or AM_EN = 0 then
      v.twdir2 := INPUT;
    end if;

    if SLVSEL_EN = 0 then
      v.slvsel := (others => '1');
    end if;

    -- Propagate core enable bit
    v.spio.enable := r.mode.en;

    -- Synchronize inputs coming from off-chip
    v.spii(0) := (spii_miso, spii_mosi, spii_sck, spii_spisel);
    v.spii(1) := r.spii(0);

    -- Outputs to RAMs
    if syncram = 0 then
      rx_di <= (others => (others => '0'));
      tx_di <= (others => (others => '0'));
      rx_ra <= (others => (others => '0'));
      rx_wa <= (others => (others => '0'));
      tx_ra <= (others => (others => '0'));
      tx_wa <= (others => (others => '0'));
      rx_read <= (others => '0'); rx_write <= (others => '0');
      tx_read <= (others => '0'); tx_write <= (others => '0');
    else
      -- TX RAM(s) write
      -- TX RAM(s) are either written from TX register or AM TX area
      for i in 0 to automode loop
        tx_di(i) <= ntxd;
      end loop;
      for i in 0 to automode loop
        tx_wa(i) <= r.tdli;
      end loop;
      tx_write(0) <= tx_wr;
      if AM_EN /= 0 then
        -- Auto mode present
        -- Write from AM register interface writes both RAMs
        -- Write from TXD register writes RAM 0
        tx_write(automode) <= r.am.txwrite;
        tx_write(0) <= tx_wr or r.am.txwrite;
        if r.am.txwrite = '1' then
          for i in 0 to automode loop
            tx_wa(i) <= r.am.apbaddr;
          end loop;
        end if;
      end if;
      -- TX RAM(s) read
      -- First RAM is read by bit shift logic
      tx_read(0) <= tx_rd;
      tx_ra(0) <= r.tdfi;
      if AM_EN /= 0 then
        -- Second RAM is read from register interface
        tx_read(automode) <= v.am.txread or r.am.txread;
        tx_ra(automode) <= v.am.apbaddr;
      end if;
      -- RX RAM(s) write
      -- RX RAM(s) is always written from receive shift register
      for i in 0 to automode loop
        rx_di(i) <= r.rxd;
        rx_wa(i) <= r.rdli;
      end loop;
      rx_write(0) <= rx_wr;
      if AM_EN /= 0 then
        rx_write(automode) <= '0';
      end if;
      if AM_EN /= 0 and r.mode.amen = '1' then
        -- AM active
        -- Handle writes from bit shift logic
        if r.am.rxsel = '0' then
          rx_write(0) <= rx_wr;
          rx_write(automode) <= '0';
        else
          rx_write(0) <= '0';
          rx_write(automode) <= rx_wr;
        end if;
      end if;
      -- RX RAM(s) are read via register interface
      for i in 0 to automode loop
        rx_ra(i) <= r.rdfi;
        rx_read(i) <= rx_rd;
      end loop;
      if AM_EN /= 0 and r.mode.amen = '1' then
        if r.am.rxsel = '0' then
          rx_read(0) <= '0';
          rx_read(automode) <= v.am.rxread;
          if v.am.rxread = '1' then
            rx_ra(automode) <= v.am.apbaddr;
          end if;
        else
          rx_read(0) <= v.am.rxread;
          rx_read(automode) <= '0';
          if v.am.rxread = '1' then
            rx_ra(0) <= v.am.apbaddr;
          end if;
        end if;
      end if;
      if scantest = 1 and (apbi_scanen and apbi_testen) = '1' then
        rx_read <= (others => '0'); rx_write <= (others => '0');
        tx_read <= (others => '0'); tx_write <= (others => '0');
      end if;
    end if;

    v.spiolb.mosi := v.spio.mosi;
    v.spiolb.sck := v.spio.sck;

    -- Update registers
    rin <= v;

    -- Update outputs
    apbo_prdata <= apbout;
    apbo_pirq <= r.irq;

    slvsel <= r.slvsel;

    spio_miso    <= r.spio.miso;
    spio_misooen <= r.spio.misooen;
    spio_mosi    <= r.spio.mosi;
    spio_mosioen <= r.spio.mosioen;
    spio_sck     <= r.spio.sck;
    spio_sckoen  <= r.spio.sckoen;
    spio_enable  <= r.spio.enable;
    spio_astart  <= r.spio.astart;
    spio_aready  <= r.spio.aready;

    if scantest = 1 and apbi_testen = '1' then
      spio_misooen <= apbi_testoen;
      spio_mosioen <= apbi_testoen;
      spio_sckoen  <= apbi_testoen;
    end if;

  end process comb;

  -- FIFOs
  fiforams : if syncram /= 0 generate
    fifoloop : for i in 0 to automode generate
      noft : if ft = 0 generate
        rxfifo : syncram_2p
          generic map (
            tech   => memtech,
            abits  => fdepth,
            dbits  => wlen+1,
            sepclk => 0,
            wrfst  => 1)
          port map (
            rclk     => clk,
            renable  => rx_read(i),
            raddress => rx_ra(i),
            dataout  => rx_do(i),
            wclk     => clk,
            write    => rx_write(i),
            waddress => rx_wa(i),
            datain   => rx_di(i));
--          testin   => testin);
        txfifo : syncram_2p
          generic map (
            tech   => memtech,
            abits  => fdepth,
            dbits  => wlen+1,
            sepclk => 0,
            wrfst  => 1)
          port map (
            rclk     => clk,
            renable  => tx_read(i),
            raddress => tx_ra(i),
            dataout  => tx_do(i),
            wclk     => clk,
            write    => tx_write(i),
            waddress => tx_wa(i),
            datain   => tx_di(i));
--          testin   => testin);
      end generate noft;
      ftfifos : if ft /= 0 generate
        ftrxfifo : syncram_2pft
          generic map (
            tech   => memtech,
            abits  => fdepth,
            dbits  => wlen+1,
            sepclk => 0,
            wrfst  => 1,
            ft     => ft)
          port map (
            rclk     => clk,
            renable  => rx_read(i),
            raddress => rx_ra(i),
            dataout  => rx_do(i),
            wclk     => clk,
            write    => rx_write(i),
            waddress => rx_wa(i),
            datain   => rx_di(i),
            error    => open);
--          testin   => testin);
        fttxfifo : syncram_2pft
          generic map (
            tech   => memtech,
            abits  => fdepth,
            dbits  => wlen+1,
            sepclk => 0,
            wrfst  => 1,
            ft     => ft)
          port map (
            rclk     => clk,
            renable  => tx_read(i),
            raddress => tx_ra(i),
            dataout  => tx_do(i),
            wclk     => clk,
            write    => tx_write(i),
            waddress => tx_wa(i),
            datain   => tx_di(i),
            error    => open);
--          testin   => testin);
      end generate ftfifos;
    end generate fifoloop;
  end generate fiforams;
  nofiforams : if syncram = 0 generate
    rx_do <= (others => (others => '0'));
    tx_do <= (others => (others => '0'));
  end generate;

  -- Registers
  reg: process (clk, arstn)
  begin  -- process reg
    if rising_edge(clk) then
      r <= rin;
      if rstn = '0' then
        r.spio.sck <= RES.spio.sck;
        r.rbitcnt <= RES.rbitcnt; r.tbitcnt <= RES.tbitcnt;
        if RESET_ALL then
          r <= RES;
          -- Do not use synchronous reset for sync. registers
          r.spii <= rin.spii;
        end if;
      end if;
    end if;
    if syncrst = 0 and arstn = '0' then
      r.spio.misooen  <= RES.spio.misooen;
      r.spio.mosioen  <= RES.spio.mosioen;
      r.spio.sckoen   <= RES.spio.sckoen;
      if SLVSEL_EN /= 0 then
        r.slvsel <= RES.slvsel;
      end if;
    end if;
  end process reg;

end architecture rtl;

