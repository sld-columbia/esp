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
-- Entity:      pcilib2
-- File:        pcilib2.vhd
-- Author:      Nils-Johan Wessman - Aeroflex Gaisler
-- Description: Package with type declarations for PCI registers & constants
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.pci.pci_in_type;
use work.pci.pci_out_type;

package pcilib2 is

-- Constants for PCI commands
constant INT_ACK      : std_logic_vector(3 downto 0) := "0000";
constant SPEC_CYCLE   : std_logic_vector(3 downto 0) := "0001";
constant IO_READ      : std_logic_vector(3 downto 0) := "0010";
constant IO_WRITE     : std_logic_vector(3 downto 0) := "0011";
constant MEM_READ     : std_logic_vector(3 downto 0) := "0110";
constant MEM_WRITE    : std_logic_vector(3 downto 0) := "0111";
constant CONF_READ    : std_logic_vector(3 downto 0) := "1010";
constant CONF_WRITE   : std_logic_vector(3 downto 0) := "1011";
constant MEM_R_MULT   : std_logic_vector(3 downto 0) := "1100";
constant DAC          : std_logic_vector(3 downto 0) := "1101";
constant MEM_R_LINE   : std_logic_vector(3 downto 0) := "1110";
constant MEM_W_INV    : std_logic_vector(3 downto 0) := "1111";


type pci_config_command_type is record
  ioen     : std_logic; -- I/O access enable
  memen    : std_logic; -- Memory access enable
  msten    : std_logic; -- Master enable
--  spcen    : std_logic; -- Special cycle enable
  mwien    : std_logic; -- Memory write and invalidate enable
--  vgaps    : std_logic; -- VGA palette snooping enable
  perren    : std_logic; -- Parity error response enable
  serren    : std_logic; -- SERR error response enable
  intdis    : std_logic; -- Interrupt disable
--  wcc      : std_logic; -- Address stepping enable
--  serre    : std_logic; -- Enable SERR# driver
--  fbtbe    : std_logic; -- Fast back-to-back enable
end record;
constant pci_config_command_none : pci_config_command_type := ('0','0','0','0','0','0','0');
type pci_config_status_type is record
  intsta   : std_logic; -- Interrupt status 
--  c66mhz   : std_logic; -- 66MHz capability
--  udf      : std_logic; -- UDF supported
--  fbtbc    : std_logic; -- Fast back-to-back capability
  mdpe     : std_logic; -- Master data parity error
--  dst      : std_logic_vector(1 downto 0); -- DEVSEL timing
  sta      : std_logic; -- Signaled target abort
  rta      : std_logic; -- Received target abort
  rma      : std_logic; -- Received master abort
  sse      : std_logic; -- Signaled system error
  dpe      : std_logic; -- Detected parity error
end record;
constant pci_config_status_none : pci_config_status_type := ('0','0','0','0','0','0','0');

----type pci_config_type is record
----  conf_en  : std_logic;
----  bus      : std_logic_vector(7 downto 0);
----  dev      : std_logic_vector(4 downto 0);
----  func     : std_logic_vector(2 downto 0);
----  reg      : std_logic_vector(5 downto 0);
----  data     : std_logic_vector(31 downto 0);
----end record;
type pci_sigs_type is record
  ad       : std_logic_vector(31 downto 0);
  cbe      : std_logic_vector(3 downto 0);
  frame    : std_logic; -- Master frame
  devsel   : std_logic; -- PCI device select
  trdy     : std_logic; -- Target ready
  irdy     : std_logic; -- Master ready
  stop     : std_logic; -- Target stop request
  par      : std_logic; -- PCI bus parity
  req      : std_logic; -- Master bus request
  perr     : std_logic; -- Parity Error
  serr     : std_logic;
  oe_par   : std_logic;
  oe_ad    : std_logic;
  oe_ctrl  : std_logic;
  oe_cbe   : std_logic;
  oe_frame : std_logic;
  oe_irdy  : std_logic;
  oe_req   : std_logic;
  oe_perr  : std_logic;
  oe_serr  : std_logic;
end record;

--type pci_target_state_type is (pt_idle, pt_b_busy, pt_s_data, pt_backoff, pt_turn_ar);
subtype pci_target_state_type is std_logic_vector(2 downto 0);
constant pt_idle    : std_logic_vector(2 downto 0) := "000";
constant pt_b_busy  : std_logic_vector(2 downto 0) := "001";
constant pt_s_data  : std_logic_vector(2 downto 0) := "010";
constant pt_backoff : std_logic_vector(2 downto 0) := "011";
constant pt_turn_ar : std_logic_vector(2 downto 0) := "100";
--type pci_target_fifo_state_type is (ptf_idle, ptf_fifo, ptf_cwrite, ptf_write);
subtype pci_target_fifo_state_type is std_logic_vector(1 downto 0);
constant ptf_idle   : std_logic_vector(1 downto 0) := "00";
constant ptf_fifo   : std_logic_vector(1 downto 0) := "01";
constant ptf_cwrite : std_logic_vector(1 downto 0) := "10";
constant ptf_write  : std_logic_vector(1 downto 0) := "11";
--type pci_master_state_type is (pm_idle, pm_addr, pm_m_data, pm_turn_ar, pm_s_tar, pm_dr_bus);
subtype pci_master_state_type is std_logic_vector(2 downto 0);
constant pm_idle    : std_logic_vector(2 downto 0) := "000";
constant pm_addr    : std_logic_vector(2 downto 0) := "001";
constant pm_m_data  : std_logic_vector(2 downto 0) := "010";
constant pm_turn_ar : std_logic_vector(2 downto 0) := "011";
constant pm_s_tar   : std_logic_vector(2 downto 0) := "100";
constant pm_dr_bus  : std_logic_vector(2 downto 0) := "101";
--type pci_master_fifo_state_type is (pmf_idle, pmf_fifo, pmf_read);
subtype pci_master_fifo_state_type is std_logic_vector(1 downto 0);
constant pmf_idle   : std_logic_vector(1 downto 0) := "00";
constant pmf_fifo   : std_logic_vector(1 downto 0) := "01";
constant pmf_read   : std_logic_vector(1 downto 0) := "10";

type pci_core_fifo_type is record
  data  : std_logic_vector(31 downto 0);  -- 32 bit FIFO data 
  last  : std_logic;                      -- Last word in FIFO
  stlast: std_logic;                      -- Second to last word in FIFO
  hold  : std_logic;                      
  valid : std_logic;                      -- Contains valid data
  err   : std_logic;                      -- signal target-abort
end record;
constant pci_core_fifo_none : pci_core_fifo_type := ((others => '0'), '0', '0', '0', '0', '0');
type pci_core_fifo_vector_type is array (0 to 2) of pci_core_fifo_type;
constant pci_core_fifo_vector_none : pci_core_fifo_vector_type := (others => pci_core_fifo_none);

type pci_reg_in_type is record
  ad      : std_logic_vector(31 downto 0);  -- PCI address/data
  cbe     : std_logic_vector(3 downto 0);   -- PCI command/byte enable
  frame   : std_logic;  -- Master frame
  devsel  : std_logic;  -- PCI device select
  trdy    : std_logic;  -- Target ready
  irdy    : std_logic;  -- Master ready
  stop    : std_logic;  -- Target stop request
  par     : std_logic;  -- PCI bus parity
  perr    : std_logic;  -- Parity error
  serr    : std_logic;  -- System error
  gnt     : std_logic;  -- Master grant
  idsel   : std_logic;  -- PCI configuration device select
end record;

type pci_reg_out_type is record
  ad      : std_logic_vector(31 downto 0);  -- PCI address/data
  aden    : std_logic_vector(31 downto 0);  -- PCI address/data [enable]
  cbe     : std_logic_vector(3 downto 0);   -- PCI command/byte enable
  cbeen   : std_logic_vector(3 downto 0);   -- PCI command/byte enable [enable]
  frame   : std_logic;  -- Master frame
  frameen : std_logic;  -- Master frame [enable]
  irdy    : std_logic;  -- Master ready
  irdyen  : std_logic;  -- Master ready [enable]
  trdy    : std_logic;  -- Target ready
  trdyen  : std_logic;  -- Target ready [enable]
  stop    : std_logic;  -- Target stop request
  stopen  : std_logic;  -- Target stop request [enable]
  devsel  : std_logic;  -- PCI device select
  devselen: std_logic;  -- PCI device select [enable]
  par     : std_logic;  -- PCI bus parity
  paren   : std_logic;  -- PCI bus parity [enable]
  perr    : std_logic;  -- Parity error
  perren  : std_logic;  -- Parity error [enable]
  lock    : std_logic;  -- PCI lock
  locken  : std_logic;  -- PCI lock [enable]
  req     : std_logic;  -- Master request
  reqen   : std_logic;  -- Master request [enable]
  serren  : std_logic;  -- System error
  inten   : std_logic;  -- PCI interrupt [enable] 
  vinten  : std_logic_vector(3 downto 0);  -- PCI interrupt [enable]
  serr    : std_logic;                  -- SERR value, constant 0 - included for iotest
end record;
type grpci2_phy_in_type is record
  pcirstout           : std_logic;
  pciasyncrst         : std_logic;
  pcisoftrst          : std_logic_vector(2 downto 0);
  pciinten            : std_logic_vector(3 downto 0);
  m_request           : std_logic;
  m_mabort            : std_logic;
  pr_m_fstate         : pci_master_fifo_state_type;
  pr_m_cfifo          : pci_core_fifo_vector_type; 
  pv_m_cfifo          : pci_core_fifo_vector_type; 
  pr_m_addr           : std_logic_vector(31 downto 0);
  pr_m_cbe_data       : std_logic_vector(3 downto 0);
  pr_m_cbe_cmd        : std_logic_vector(3 downto 0);
  pr_m_first          : std_logic_vector(1 downto 0);
  pv_m_term           : std_logic_vector(1 downto 0);
  pr_m_ltimer         : std_logic_vector(7 downto 0);
  pr_m_burst          : std_logic;
  pr_m_abort          : std_logic_vector(0 downto 0);
  pr_m_perren         : std_logic_vector(0 downto 0);
  pr_m_done_fifo      : std_logic;
  t_abort             : std_logic;
  t_ready             : std_logic;
  t_retry             : std_logic;
  pr_t_state          : pci_target_state_type;
  pv_t_state          : pci_target_state_type;
  pr_t_fstate         : pci_target_fifo_state_type;
  pr_t_cfifo          : pci_core_fifo_vector_type;
  pv_t_diswithout     : std_logic;
  pr_t_stoped         : std_logic;
  pr_t_lcount         : std_logic_vector(2 downto 0);
  pr_t_first_word     : std_logic;
  pr_t_cur_acc_0_read : std_logic;
  pv_t_hold_write     : std_logic; 
  pv_t_hold_reset     : std_logic;
  pr_conf_comm_perren : std_logic;
  pr_conf_comm_serren : std_logic;
  testen              : std_logic;
  testoen             : std_logic;
  testrst             : std_logic;
end record;
type grpci2_phy_out_type is record
  pciv        : pci_in_type;
  pr_m_state  : pci_master_state_type;
  pr_m_last   : std_logic_vector(1 downto 0);
  pr_m_hold   : std_logic_vector(1 downto 0);
  pr_m_term   : std_logic_vector(1 downto 0);
  pr_t_hold   : std_logic_vector(0 downto 0);
  pr_t_stop   : std_logic;
  pr_t_abort  : std_logic;
  pr_t_diswithout : std_logic;
  pr_t_addr_perr : std_logic;
  pcirsto     : std_logic_vector(0 downto 0);
  pr_po       : pci_reg_out_type;
  pio         : pci_in_type;
  poo         : pci_reg_out_type;
end record;

component grpci2_phy is
  generic(
    tech    : integer := 0;
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
end component;

component grpci2_phy_wrapper is
  generic(
    tech    : integer := 0;
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
end component;

component grpci2_ahbmst is
  generic (
    hindex  : integer := 0;
    hirq    : integer := 0;
    venid   : integer := VENDOR_GAISLER;
    devid   : integer := 0;
    version : integer := 0;
    chprot  : integer := 3;
    incaddr : integer := 0); 
   port (
      rst  : in  std_ulogic;
      clk  : in  std_ulogic;
      dmai : in ahb_dma_in_type;
      dmao : out ahb_dma_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type 
      );
end component;      

type dma_ahb_in_type is record
  req     : std_ulogic;
  write   : std_ulogic; 
  addr    : std_logic_vector(31 downto 0);
  data    : std_logic_vector(31 downto 0);
  size    : std_logic_vector(1 downto 0);
  noreq   : std_logic;
  burst   : std_logic;
end record;
constant dma_ahb_in_none : dma_ahb_in_type := ('0', '0', (others => '0'),
  (others => '0'), (others => '0'), '0', '0');

type dma_ahb_out_type is record
  grant   : std_ulogic;
  ready   : std_ulogic;
  error   : std_ulogic;
  retry   : std_ulogic;
  data    : std_logic_vector(31 downto 0);
end record;

component grpci2_ahb_mst is
  generic(
    hindex      : integer := 0;
    venid   : integer := VENDOR_GAISLER;
    devid   : integer := 0;
    version : integer := 0
  );
  port(
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    ahbmi       : in  ahb_mst_in_type;
    ahbmo       : out ahb_mst_out_type;
    dmai0       : in  dma_ahb_in_type;
    dmao0       : out dma_ahb_out_type;
    dmai1       : in  dma_ahb_in_type;
    dmao1       : out dma_ahb_out_type
  );
end component;

end ;

