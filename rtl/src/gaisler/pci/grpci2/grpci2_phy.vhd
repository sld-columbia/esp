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
-- Entity:  grpci2_phy
-- File:    grpci2_phy.vhd
-- Author:  Nils-Johan Wessman - Aeroflex Gaisler
-- Description: Logic controlled by the PCI control signals in the GRPCI2 core
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.config.all;
use work.config_types.all;
use work.gencomp.all;
use work.pci.all;

use work.pcilib2.all;


entity grpci2_phy is
  generic(
    tech    : integer := DEFMEMTECH;
    oepol   : integer := 0;
    bypass  : integer range 0 to 1 := 1;
    netlist : integer := 0;
    scantest: integer := 0;
    iotest  : integer := 0
  );
  port(
    pciclk  : in  std_logic;
    pcii    : in  pci_in_type;
    phyi    : in  grpci2_phy_in_type; 
    pcio    : out pci_out_type;
    phyo    : out grpci2_phy_out_type;
    iotmact : in  std_ulogic;
    iotmoe  : in  std_ulogic;
    iotdout : in  std_logic_vector(44 downto 0);
    iotdin  : out std_logic_vector(45 downto 0)
  );
end;

architecture rtl of grpci2_phy is
constant oeon : std_logic := conv_std_logic_vector(oepol,1)(0);
constant oeoff : std_logic := not conv_std_logic_vector(oepol,1)(0);
constant ones32 : std_logic_vector(31 downto 0) := (others => '1');
type phy_m_reg_type is record
  state : pci_master_state_type;
  cfi : integer range 0 to 2; 
  pi_irdy_or_trdy : std_logic;
  last  : std_logic_vector(1 downto 0);
  hold  : std_logic_vector(1 downto 0);
  term  : std_logic_vector(1 downto 0);
end record;
type phy_t_reg_type is record
  cfi : integer range 0 to 2; 
  pi_irdy_or_trdy : std_logic;
  hold  : std_logic_vector(0 downto 0);
  stop  : std_logic;
  abort : std_logic;
  diswithout : std_logic;
  addr_perr : std_logic;
end record;
type phy_reg_type is record
  po  : pci_reg_out_type;
  m   : phy_m_reg_type;
  t   : phy_t_reg_type;
end record;
signal pr, prin : phy_reg_type;
signal pi, piin, piin_buf   : pci_in_type;  -- Registered PCI signals.
signal po, poin, po_keep  : pci_reg_out_type;     -- PCI output signals (to drive pads)
signal poin_keep    : std_logic_vector(90 downto 0);
signal raden, rinaden, rinaden_tmp : std_logic_vector(31 downto 0);
signal pcirst : std_logic_vector(2 downto 0);    -- PCI reset
signal xarst : std_ulogic;
signal pcisynrst : std_ulogic;
attribute sync_set_reset of pcisynrst : signal is "true"; 
attribute syn_keep : boolean;
attribute syn_keep of poin_keep : signal is true;
begin
  phycomb : process(pcii, pr, pi, po, phyi, pcisynrst, rinaden)      
  variable pv  : phy_reg_type;
  variable pci : pci_in_type;
  begin
    -- defaults ---------------------------------------------------------------------
    pv := pr; 
    pv.po.frame := '1'; pv.po.irdy := '1'; pv.po.req := '1';
    pv.po.trdy := '1'; pv.po.stop := '1';
    pv.po.perr := '1'; pv.po.lock := '1'; pv.po.devsel := '1';
    pv.po.serr := '1';
  
    pv.po.devselen := oeoff; pv.po.trdyen := oeoff; pv.po.stopen := oeoff;
    pv.po.aden := (others => oeoff); pv.po.cbeen := (others => oeoff);
    pv.po.frameen := oeoff; pv.po.irdyen := oeoff; 
    pv.po.perren := oeoff; pv.po.serren := oeoff;
    pv.po.reqen := oeon; -- Always on (point-to-point signal, tri-state during reset)
    
    -- PCI input mux ----------------------------------------------------------------
    pci := pcii;
    if bypass /= 0 then
      if pr.po.aden(0) = oeon then pci.ad := pr.po.ad; end if;
      if pr.po.cbeen(0) = oeon then pci.cbe := pr.po.cbe; end if;
      if pr.po.frameen = oeon then pci.frame := pr.po.frame; end if;
      if pr.po.irdyen = oeon then pci.irdy := pr.po.irdy; end if;
      if pr.po.trdyen = oeon then pci.trdy := pr.po.trdy; end if;
      if pr.po.stopen = oeon then pci.stop := pr.po.stop; end if;
      if pr.po.paren = oeon then pci.par := pr.po.par; end if;
      if pr.po.devselen = oeon then pci.devsel := pr.po.devsel; end if;
      if pr.po.perren = oeon then pci.perr := pr.po.perr; end if;
      if pr.po.serren = oeon then pci.serr := pr.po.serren; end if;
    end if;
  
    -- Master -----------------------------------------------------------------------
    
    pv.m.pi_irdy_or_trdy := pi.irdy or pi.trdy;
    if ((not (pr.po.irdy or pci.trdy)) and pr.m.pi_irdy_or_trdy) = '1' then 
      if pr.m.state = pm_m_data or pr.m.state = pm_turn_ar then
        --pv.m.cfi := pr.m.cfi + 1;
        case pr.m.cfi is
          when 0 => pv.m.cfi := 1;
          when 1 => pv.m.cfi := 2;
          when others => pv.m.cfi := 0;
        end case;
      end if;
    elsif ((pr.po.irdy or pci.trdy) and (not pr.m.pi_irdy_or_trdy)) = '1' then 
      if pr.m.state = pm_m_data or pr.m.state = pm_turn_ar then
        --pv.m.cfi := pr.m.cfi - 1; 
        case pr.m.cfi is
          when 2 => pv.m.cfi := 1;
          when 1 => pv.m.cfi := 0;
          when others => pv.m.cfi := 0;
        end case;
      end if;
    end if;

    -- PCI state machine
    case pr.m.state is
      when pm_idle =>
        if pci.gnt = '0' and (pci.frame and pci.irdy) = '1' then
          if phyi.m_request = '1' then pv.m.state := pm_addr;
          else pv.m.state := pm_dr_bus; end if;
        end if;
        pv.m.cfi := 0;
      when pm_addr =>
        pv.m.state := pm_m_data;
      when pm_m_data =>
        if pr.po.frame = '0' or (pr.po.frame and pci.trdy and pci.stop and not phyi.m_mabort) = '1' then 
          pv.m.state := pm_m_data;
        elsif (pr.po.frame and (phyi.m_mabort or not pci.stop)) = '1' then 
          pv.m.state := pm_s_tar;
        else
          pv.m.state := pm_turn_ar;
        end if;
      when pm_turn_ar =>
        if pci.gnt = '0' then
          if phyi.m_request = '1' then pv.m.state := pm_addr; -- remove if no back-to-back
          else pv.m.state := pm_dr_bus; end if;
        else
          pv.m.state := pm_idle;
        end if;
      when pm_s_tar =>
        if pci.gnt = '0' then pv.m.state := pm_dr_bus;
        else pv.m.state := pm_idle; end if;
      when pm_dr_bus =>
        if pci.gnt = '1' then pv.m.state := pm_idle;
        elsif phyi.m_request = '1' then pv.m.state := pm_addr; end if;
        pv.m.cfi := 0;
      when others =>
    end case;
          
    if phyi.pr_m_fstate = pmf_fifo then
      if (phyi.pv_m_cfifo(0).valid = '1' and phyi.pv_m_cfifo(1).valid = '1' and phyi.pv_m_cfifo(2).valid = '1')
          or (phyi.pv_m_cfifo(0).valid = '1' and phyi.pr_m_done_fifo = '1' and not (phyi.pv_m_cfifo(1).valid = '0' and phyi.pv_m_cfifo(2).valid = '1')) then
        pv.m.hold(0) := '0';
      end if;

      if ((pi.trdy or pi.irdy) = '0' and (pr.m.state = pm_m_data or pr.m.state = pm_turn_ar or pr.m.state = pm_s_tar)) 
         or (phyi.pr_m_abort(0)) = '1' then
        if phyi.pr_m_cfifo(pv.m.cfi).last = '1' and pr.m.last(0) = '0' then pv.m.last(0) := '1'; end if; -- This is the last data phase
        pv.m.last(1) := pr.m.last(0);
        if phyi.pr_m_done_fifo = '1' and phyi.pr_m_cfifo(pv.m.cfi).valid = '0' then pv.m.last(1) := '1'; end if; -- This is the last data phase
        pv.m.hold(1) := pr.m.hold(0);
      end if;

      if (pr.m.state = pm_m_data or pr.m.state = pm_addr) and phyi.pr_m_cfifo(pv.m.cfi).hold = '1' then pv.m.hold(0) := '1'; end if;  -- Transfer not done but no avalible fifo => deassert IRDY#

      if (pr.m.state = pm_s_tar or pr.m.state = pm_turn_ar) then 
        pv.m.last := (others => '0');
        pv.m.hold(0) := '0'; 
      end if;

      if phyi.pr_m_cfifo(0).last = '1' and phyi.pr_m_first(0) = '1' and pr.m.state = pm_addr and (phyi.pr_m_cbe_cmd = MEM_WRITE or phyi.pr_m_cbe_cmd = CONF_WRITE or phyi.pr_m_cbe_cmd = IO_WRITE) then pv.m.last := "11"; end if; -- Single data phase
      if phyi.pr_m_first(1) = '1' and pr.m.state = pm_m_data and  phyi.pr_m_cfifo(pv.m.cfi).last = '1' then pv.m.last(0) := '1'; end if;  -- This is the last data phase
    end if;
    if phyi.pr_m_fstate = pmf_idle then 
      pv.m.last := (others => '0');
      pv.m.hold := (others => '0');
    end if;

    -- PCI master latency timer timeout
    pv.m.term := phyi.pv_m_term;
    if pci.gnt = '1' then 
      if phyi.pr_m_ltimer = x"00" and pr.m.state = pm_m_data and phyi.pr_m_burst = '1' and phyi.pr_m_fstate /= pmf_idle then 
        pv.m.term(0) := '1'; 
      end if;
    end if;
  
    -- FRAME#
    if (pci.frame and pci.irdy and not pci.gnt and phyi.m_request) = '1'     -- Address phase
        or (pr.po.frame = '0' and phyi.m_mabort = '0'                        -- Not Master abort
            and (pr.po.irdy or pci.stop) = '1'                          -- Not Disconnect
            and ((phyi.pr_m_first(0) or not (pr.po.irdy or pci.trdy)) and (phyi.pr_m_cfifo(pv.m.cfi).last or pv.m.term(0))) = '0') then -- Not last data phase
      pv.po.frame := '0';
    end if;

    -- IRDY#
    if (pr.po.frame = '0' and phyi.m_mabort = '0' and (pr.m.hold(0) = '0' or (not pr.po.irdy and (pci.trdy and pci.stop)) = '1'))  -- Access ongoing, not Master abort, not hold (no data available)
        or (pr.po.frame and not phyi.m_mabort and not pr.po.irdy and (pci.trdy and pci.stop)) = '1' then  -- Last data phase, not Master abort (if first access, can get master abort)
      pv.po.irdy := '0';
    end if;

    -- Output enable ctrl signals
    if (pci.frame and pci.irdy and not pci.gnt) = '1' -- Address phase
        or pr.po.frame = '0'                          -- Access ongoing
        or (not pr.po.irdy and (pci.stop and pci.trdy)) = '1' then -- Last data phase
      pv.po.frameen := oeon;
      pv.po.cbeen := (others => oeon);
    end if;
    
    pv.po.irdyen := pr.po.frameen;

    -- REQ#
    if (phyi.m_request) = '1' and (phyi.m_mabort or phyi.pr_m_abort(0)) = '0' then
      pv.po.req := '0';
    end if;

    -- Output enable req
    --pv.po.reqen := oeon; -- always on if not in reset

    -- CBE#
    if pr.po.irdy = '0' or pr.po.req = '0' or phyi.m_request = '1' then
      if pr.m.state /= pm_idle and (pr.m.state /= pm_dr_bus) then pv.po.cbe := phyi.pr_m_cbe_data;
      else pv.po.cbe := phyi.pr_m_cbe_cmd; end if;
    else
      pv.po.cbe := (others => '0');
    end if;

    -- Target -----------------------------------------------------------------------
    
    pv.t.pi_irdy_or_trdy := pi.irdy or pi.trdy;
    if (pr.t.pi_irdy_or_trdy and (not (pci.irdy or pr.po.trdy))) = '1' then 
      if phyi.pr_t_state = pt_s_data or phyi.pr_t_state = pt_turn_ar or phyi.pr_t_state = pt_backoff then
        --pv.t.cfi := pr.t.cfi + 1;
        case pr.t.cfi is
          when 0 => pv.t.cfi := 1;
          when 1 => pv.t.cfi := 2;
          when others => pv.t.cfi := 0;
        end case;
      end if;
    elsif ((not pr.t.pi_irdy_or_trdy) and (pci.irdy or pr.po.trdy)) = '1' then 
      if phyi.pr_t_state = pt_s_data or phyi.pr_t_state = pt_turn_ar or phyi.pr_t_state = pt_backoff then
        --pv.t.cfi := pr.t.cfi - 1; 
        case pr.t.cfi is
          when 2 => pv.t.cfi := 1;
          when 1 => pv.t.cfi := 0;
          when others => pv.t.cfi := 0;
        end case;
      end if;
    end if;
    
    pv.t.hold(0) := (phyi.pr_t_cfifo(pv.t.cfi).hold or pr.t.hold(0) or phyi.pv_t_hold_write) and phyi.pv_t_hold_reset;
    pv.t.stop := (phyi.pr_t_cfifo(pv.t.cfi).stlast or pr.t.stop) and phyi.pv_t_hold_reset;

    if phyi.pr_t_state = pt_s_data and phyi.pr_t_cfifo(pv.t.cfi).err = '1' and (phyi.pr_t_stoped = '0' or pr.t.abort = '1') and phyi.t_retry = '0' then pv.t.abort := '1'; 
    else pv.t.abort := '0'; end if;
    
    pv.t.diswithout := phyi.pv_t_diswithout;
    -- Disconnect without data if CBE change in burst
    if pci.cbe /= pi.cbe and (phyi.pr_t_state = pt_s_data and phyi.pr_t_fstate = ptf_write) then pv.t.diswithout := '1'; end if;
          
    -- Parity error detected on address phase
    if (phyi.pr_t_state = pt_idle or phyi.pr_t_state = pt_turn_ar) and pi.frame = '0' then
      pv.t.addr_perr := (pci.par xor xorv(pi.ad & pi.cbe));
    else
      pv.t.addr_perr := '0';
    end if;
  
    -- TRDY#
    if (phyi.pr_t_state = pt_s_data and ((phyi.t_ready and not phyi.t_retry) = '1' and pv.t.diswithout = '0' and 
        pv.t.abort = '0') and (pr.po.stop and not phyi.pr_t_stoped) = '1' and (phyi.pr_t_first_word or not pci.frame) = '1') -- Target accessed, data/fifo available, not stoped 
       or (not pr.po.trdy and pci.irdy) = '1' then -- During master waitstates
      pv.po.trdy := '0';
    end if;

    -- STOP#
    if 
       (pr.po.stop = '1' and phyi.pr_t_stoped = '0' and phyi.pr_t_lcount = "111" and pr.po.trdy = '1')                          -- latency timerout  
       or ((
           ((phyi.t_abort = '1' or pv.t.diswithout = '1') and (pci.irdy or pr.po.trdy) = '0' and pci.frame = '0')          -- transfer done or disconnect without data (when cbe has changed during write to target)
           or (pv.t.abort = '1' and (((pci.irdy or pr.po.trdy) = '0' and pci.frame = '0') or phyi.pr_t_first_word = '1'))  -- To signal target abort
           or ((phyi.pr_t_cfifo(0).valid and phyi.pr_t_cfifo(0).hold and phyi.pr_t_cfifo(0).stlast and phyi.pr_t_first_word) = '1')       -- When first word in this access is the last word in the transfer
           ) and pr.po.stop = '1' and phyi.pr_t_stoped = '0')                                                              -- Only stop when master is ready (and target ready)
       or (pr.po.stop = '0' and pci.frame = '0')                                                                      -- When stop and frame are asserted 
       or (phyi.t_retry = '1' and pr.po.stop = '1' and phyi.pr_t_stoped = '0') then                                             -- To signal retry
      pv.po.stop := '0';
    end if;
    
    -- DEVSEL#
    if (phyi.pr_t_state /= pt_s_data and phyi.pv_t_state = pt_s_data) 
       or (pr.po.devsel = '0' and (pci.frame and not pci.irdy and not (pr.po.trdy and pr.po.stop)) = '0'
           and pv.t.abort = '0' -- To signal target abort 
          ) then
      pv.po.devsel := '0';
    end if;

    -- Output enable ctrl signals
    if phyi.pv_t_state = pt_s_data or phyi.pv_t_state = pt_backoff then
      pv.po.devselen := oeon; pv.po.trdyen := oeon; pv.po.stopen := oeon;
    end if;
    
    

    -- Master & Target --------------------------------------------------------------

    -- AD 
    if (pr.m.state /= pm_idle and pr.m.state /= pm_dr_bus and phyi.pr_m_fstate = pmf_fifo) then
      pv.po.ad := phyi.pr_m_cfifo(pv.m.cfi).data;  -- PCI master data
    elsif (phyi.pr_t_state = pt_s_data and phyi.pv_t_state /= pt_turn_ar) then
      pv.po.ad := phyi.pr_t_cfifo(pv.t.cfi).data;  -- PCI target data
    else
      pv.po.ad := phyi.pr_m_addr;              -- Address
    end if;
    
    -- Output enable AD [target]
    if phyi.pr_t_state = pt_s_data  and phyi.pv_t_state /= pt_turn_ar and phyi.pr_t_cur_acc_0_read = '1' 
       and (pci.frame and (not pr.po.stop or not pr.po.trdy)) = '0' then
      pv.po.aden := (others => oeon);
    end if;
    -- Output enable AD [master]
    if (pcii.frame and pcii.irdy and not pcii.gnt) = '1'
       or ((pr.m.state = pm_addr or pr.m.state = pm_m_data) and phyi.pr_m_fstate /= pmf_read and (pr.po.frame and (not pci.stop or not pci.trdy)) = '0') then
      pv.po.aden := (others => oeon);
    end if;

    -- PAR
    pv.po.par := xorv(pr.po.ad & pci.cbe);
    
    -- Output enable PAR
    pv.po.paren := pr.po.aden(15); -- AD[15] should be closest to PAR

    -- PERR
    pv.po.perr := pi.irdy or pi.trdy or not (pci.par xor xorv(pi.ad & pi.cbe)); -- Signal perr two cycles after data phase is completed

    -- Output enable PERR
    if phyi.pr_conf_comm_perren = '1' and                                -- Parity error response enable bit[6] = 1
       (phyi.pr_m_perren(0) = '1'                                        -- During master read
        or (phyi.pr_t_state = pt_s_data and phyi.pr_t_cur_acc_0_read = '0')  -- Write to target
        or (pr.po.perr = '0' and pr.po.perren = oeon)) then         -- Parity error on last phase 
      pv.po.perren := oeon;
    end if;

    -- SERR & Output enable for SERR
    if phyi.pr_conf_comm_perren = '1' and phyi.pr_conf_comm_serren = '1' and pv.t.addr_perr = '1' then
      pv.po.serren := oeon;
    end if;


    -- PCI reset --------------------------------------------------------------------
    -- soft reset
    if (pcisynrst and not phyi.pcisoftrst(2) and not phyi.pcisoftrst(1)) = '0' then -- Master reset
      -- Master
      pv.m.state := pm_idle;
      pv.m.cfi := 0;
      pv.m.hold := (others => '0');
      pv.m.term := (others => '0');
    end if;
    
    if (pcisynrst and not phyi.pcisoftrst(2) and not phyi.pcisoftrst(0)) = '0' then -- Target reset
      -- Target
      pv.t.cfi := 0;
      pv.t.hold := (others => '0');
      pv.t.stop := '0';
      pv.t.addr_perr := '0';
    end if;
    
    if (pcisynrst and not phyi.pcisoftrst(2)) = '0' then -- Hard reset
      -- PCI signals
      pv.po.frame := '1'; pv.po.irdy := '1'; pv.po.req := '1';
      pv.po.trdy := '1'; pv.po.stop := '1';
      pv.po.perr := '1'; pv.po.devsel := '1'; 
    end if;

    ---------------------------------------------------------------------------------

    piin <= pci;
    prin <= pv;
    poin <= pv.po;

    phyo.pciv <= pci;
    phyo.pr_m_state <= pr.m.state;
    phyo.pr_m_last <= pr.m.last;
    phyo.pr_m_hold <= pr.m.hold;
    phyo.pr_m_term <= pr.m.term;
    phyo.pr_t_hold <= pr.t.hold;
    phyo.pr_t_stop <= pr.t.stop;
    phyo.pr_t_abort <= pr.t.abort;
    phyo.pr_t_diswithout <= pr.t.diswithout;
    phyo.pr_t_addr_perr <= pr.t.addr_perr;
    phyo.pcirsto(0) <= pcisynrst;
    phyo.pr_po  <= pr.po;
    phyo.pio  <= pi;
    phyo.poo  <= po;

    -- PCI output signals
    pcio.ad <= po.ad; pcio.vaden <= po.aden;
    pcio.cbe <= po.cbe; pcio.cbeen <= po.cbeen;
    pcio.frame <= po.frame; pcio.frameen <= po.frameen;
    pcio.irdy <= po.irdy; pcio.irdyen <= po.irdyen;
    pcio.trdy <= po.trdy; pcio.trdyen <= po.trdyen;
    pcio.stop <= po.stop; pcio.stopen <= po.stopen;
    pcio.devsel <= po.devsel; pcio.devselen <= po.devselen;
    pcio.par <= po.par; pcio.paren <= po.paren;
    pcio.perr <= po.perr; pcio.perren <= po.perren;
    pcio.req <= po.req; pcio.reqen <= po.reqen;
    pcio.int <= '0'; pcio.inten <= phyi.pciinten(0);
    pcio.vinten <= phyi.pciinten;
    pcio.rst <= phyi.pcirstout;
    pcio.serr <= po.serr; pcio.serren <= po.serren;

    if SCANTEST/=0 and GRLIB_CONFIG_ARRAY(GRLIB_EXTERNAL_TESTOEN)=0 then
      if phyi.testen='1' then
        pcio.vaden <= (others => phyi.testoen);
        pcio.cbeen <= (others => phyi.testoen);
        pcio.frameen <= phyi.testoen;
        pcio.irdyen <= phyi.testoen;
        pcio.trdyen <= phyi.testoen;
        pcio.stopen <= phyi.testoen;
        pcio.devselen <= phyi.testoen;
        pcio.paren <= phyi.testoen;
        pcio.perren <= phyi.testoen;
        pcio.reqen <= phyi.testoen;
        pcio.inten <= phyi.testoen;
        pcio.vinten <= (others => phyi.testoen);
        pcio.rst <= phyi.testoen xor oeon;
        pcio.serren <= phyi.testoen;
      end if;
    end if;
    
    -- Unused signals
    pcio.lock <= oeoff; pcio.locken <= oeoff;
    pcio.aden <= oeoff; pcio.ctrlen <= oeoff;
    pcio.pme_enable <= oeoff; pcio.pme_clear <= oeoff;
    pcio.power_state <= (others => oeoff);
    
  end process;

  
  -- po_keep <= poin_keep;
  poin_keep(31 downto  0) <= poin.ad;        po_keep.ad       <= poin_keep(31 downto  0);
  poin_keep(63 downto 32) <= poin.aden;      po_keep.aden     <= poin_keep(63 downto 32);
  poin_keep(67 downto 64) <= poin.cbe;       po_keep.cbe      <= poin_keep(67 downto 64);
  poin_keep(71 downto 68) <= poin.cbeen;     po_keep.cbeen    <= poin_keep(71 downto 68);
  poin_keep(          72) <= poin.frame;     po_keep.frame    <= poin_keep(          72);
  poin_keep(          73) <= poin.frameen;   po_keep.frameen  <= poin_keep(          73);
  poin_keep(          74) <= poin.irdy;      po_keep.irdy     <= poin_keep(          74);
  poin_keep(          75) <= poin.irdyen;    po_keep.irdyen   <= poin_keep(          75);
  poin_keep(          76) <= poin.trdy;      po_keep.trdy     <= poin_keep(          76);
  poin_keep(          77) <= poin.trdyen;    po_keep.trdyen   <= poin_keep(          77);
  poin_keep(          78) <= poin.stop;      po_keep.stop     <= poin_keep(          78);
  poin_keep(          79) <= poin.stopen;    po_keep.stopen   <= poin_keep(          79);
  poin_keep(          80) <= poin.devsel;    po_keep.devsel   <= poin_keep(          80);
  poin_keep(          81) <= poin.devselen;  po_keep.devselen <= poin_keep(          81);
  poin_keep(          82) <= poin.par;       po_keep.par      <= poin_keep(          82);
  poin_keep(          83) <= poin.paren;     po_keep.paren    <= poin_keep(          83);
  poin_keep(          84) <= poin.perr;      po_keep.perr     <= poin_keep(          84);
  poin_keep(          85) <= poin.perren;    po_keep.perren   <= poin_keep(          85);
  poin_keep(          86) <= poin.lock;      po_keep.lock     <= poin_keep(          86);
  poin_keep(          87) <= poin.locken;    po_keep.locken   <= poin_keep(          87);
  poin_keep(          88) <= poin.req;       po_keep.req      <= poin_keep(          88);
  poin_keep(          89) <= poin.reqen;     po_keep.reqen    <= poin_keep(          89);
  poin_keep(          90) <= poin.serren;    po_keep.serren   <= poin_keep(          90);
                                             po_keep.inten    <= phyi.pciinten(0);
                                             po_keep.vinten   <= phyi.pciinten;
  

                                             
  xarst <= phyi.testrst when scantest/=0 and phyi.testen='1' else pcirst(0);

  phyreg : process(pciclk, phyi.pciasyncrst, pcirst, xarst)
  begin
    if rising_edge(pciclk) then
      pr <= prin;
      pi <= piin;
      po <= po_keep;
      if iotmact /= '0' then
        po.ad <= iotdout(31 downto 0);
        po.cbe <= iotdout(35 downto 32);
        po.frame <= iotdout(36);
        po.irdy <= iotdout(37);
        po.trdy <= iotdout(38);
        po.par <= iotdout(39);
        po.perr <= iotdout(40);
        po.serr <= iotdout(41);
        po.devsel <= iotdout(42);
        po.stop <= iotdout(43);
        po.req <= iotdout(44);
        po.reqen <= oeon;
        if iotmoe /= '0' then
          po.aden <= (others => oeon); po.cbeen <= (others => oeon); po.frameen <= oeon;
          po.devselen <= oeon; po.trdyen <= oeon; po.irdyen <= oeon; po.stopen <= oeon;
          po.paren <= oeon; po.perren <= oeon; po.locken <= oeon;
          po.inten <= oeon; po.vinten <= (others => oeon); po.serren <= oeon;
        else
          po.aden <= (others => oeoff); po.cbeen <= (others => oeoff); po.frameen <= oeoff;
          po.devselen <= oeoff; po.trdyen <= oeoff; po.irdyen <= oeoff; po.stopen <= oeoff;
          po.paren <= oeoff; po.perren <= oeoff; po.locken <= oeoff;
          po.inten <= oeoff; po.vinten <= (others => oeoff); po.serren <= oeoff;
        end if;
      end if;
      pcisynrst <= pcirst(1) and pcirst(2); 
      pcirst(0) <= pcirst(1) and pcirst(2); 
      pcirst(1) <= pcirst(2); pcirst(2) <= '1';
    end if;

    if phyi.pciasyncrst = '0' then pcirst <= (others => '0'); end if;

    if xarst = '0' then -- asynch reset required
      po.ad <= (others => '1'); pi.ad <= (others => '1'); -- for virtex-4 all registers in IOB need to have same reset
      po.trdy <= '1'; pi.trdy <= '1'; po.stop <= '1'; pi.stop <= '1';
      po.irdy <= '1'; pi.irdy <= '1'; po.frame <= '1'; pi.frame <= '1';
      po.cbe <= (others => '1'); pi.cbe <= (others => '1');
      po.par <= '1'; pi.par <= '1';
      po.perr <= '1'; pi.perr <= '1';
      po.devsel <= '1'; pi.devsel <= '1';
      pi.serr <= '1';


      po.aden <= (others => oeoff); po.cbeen <= (others => oeoff); po.frameen <= oeoff; 
      po.devselen <= oeoff; po.trdyen <= oeoff; po.irdyen <= oeoff; po.stopen <= oeoff; 
      po.paren <= oeoff; po.perren <= oeoff; po.locken <= oeoff; po.reqen <= oeoff;
      po.inten <= oeoff; po.vinten <= (others => oeoff); po.serren <= oeoff;
    end if;
  end process;

  
  iotdin(45) <= pi.idsel;
  iotdin(44) <= pi.gnt;
  iotdin(43) <= pi.stop;
  iotdin(42) <= pi.devsel;
  iotdin(41) <= pi.serr;
  iotdin(40) <= pi.perr;
  iotdin(39) <= pi.par;
  iotdin(38) <= pi.trdy;
  iotdin(37) <= pi.irdy;
  iotdin(36) <= pi.frame;
  iotdin(35 downto 32) <= pi.cbe;
  iotdin(31 downto 0) <= pi.ad;
end;

