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

library ieee;
use ieee.std_logic_1164.all;

use work.gencomp.all;

entity grpci2_phy_net is
  generic(
    tech    : integer := DEFMEMTECH;
    oepol   : integer := 0;
    bypass  : integer range 0 to 1 := 1;
    netlist : integer := 0
  );
  port(
    pciclk  : in  std_logic;

    --pcii                      : in  pci_in_type;
    pcii_rst                  : in  std_ulogic;
    pcii_gnt                  : in  std_ulogic;
    pcii_idsel                : in  std_ulogic;
    pcii_ad                   : in  std_logic_vector(31 downto 0);
    pcii_cbe                  : in  std_logic_vector(3 downto 0);
    pcii_frame                : in  std_ulogic;
    pcii_irdy                 : in  std_ulogic;
    pcii_trdy                 : in  std_ulogic;
    pcii_devsel               : in  std_ulogic;
    pcii_stop                 : in  std_ulogic;
    pcii_lock                 : in  std_ulogic;
    pcii_perr                 : in  std_ulogic;
    pcii_serr                 : in  std_ulogic;
    pcii_par                  : in  std_ulogic;
    pcii_host                 : in  std_ulogic;
    pcii_pci66                : in  std_ulogic;
    pcii_pme_status           : in  std_ulogic;
    pcii_int                  : in  std_logic_vector(3 downto 0);
    
    --phyi                      : in  grpci2_phy_in_type; 
    phyi_pcirstout            : in  std_logic;
    phyi_pciasyncrst          : in  std_logic;
    phyi_pcisoftrst           : in  std_logic_vector(2 downto 0);
    phyi_pciinten             : in  std_logic_vector(3 downto 0);
    phyi_m_request            : in  std_logic;
    phyi_m_mabort             : in  std_logic;
    phyi_pr_m_fstate          : in  std_logic_vector(1 downto 0); --pci_master_fifo_state_type;
    
    --phyi_pr_m_cfifo           : in  pci_core_fifo_vector_type; 
    phyi_pr_m_cfifo_0_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_m_cfifo_0_last    : in  std_logic;
    phyi_pr_m_cfifo_0_stlast  : in  std_logic;
    phyi_pr_m_cfifo_0_hold    : in  std_logic;
    phyi_pr_m_cfifo_0_valid   : in  std_logic;
    phyi_pr_m_cfifo_0_err     : in  std_logic;
    phyi_pr_m_cfifo_1_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_m_cfifo_1_last    : in  std_logic;
    phyi_pr_m_cfifo_1_stlast  : in  std_logic;
    phyi_pr_m_cfifo_1_hold    : in  std_logic;
    phyi_pr_m_cfifo_1_valid   : in  std_logic;
    phyi_pr_m_cfifo_1_err     : in  std_logic;
    phyi_pr_m_cfifo_2_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_m_cfifo_2_last    : in  std_logic;
    phyi_pr_m_cfifo_2_stlast  : in  std_logic;
    phyi_pr_m_cfifo_2_hold    : in  std_logic;
    phyi_pr_m_cfifo_2_valid   : in  std_logic;
    phyi_pr_m_cfifo_2_err     : in  std_logic;
  
    --phyi_pv_m_cfifo           : in  pci_core_fifo_vector_type; 
    phyi_pv_m_cfifo_0_data    : in  std_logic_vector(31 downto 0);
    phyi_pv_m_cfifo_0_last    : in  std_logic;
    phyi_pv_m_cfifo_0_stlast  : in  std_logic;
    phyi_pv_m_cfifo_0_hold    : in  std_logic;
    phyi_pv_m_cfifo_0_valid   : in  std_logic;
    phyi_pv_m_cfifo_0_err     : in  std_logic;
    phyi_pv_m_cfifo_1_data    : in  std_logic_vector(31 downto 0);
    phyi_pv_m_cfifo_1_last    : in  std_logic;
    phyi_pv_m_cfifo_1_stlast  : in  std_logic;
    phyi_pv_m_cfifo_1_hold    : in  std_logic;
    phyi_pv_m_cfifo_1_valid   : in  std_logic;
    phyi_pv_m_cfifo_1_err     : in  std_logic;
    phyi_pv_m_cfifo_2_data    : in  std_logic_vector(31 downto 0);
    phyi_pv_m_cfifo_2_last    : in  std_logic;
    phyi_pv_m_cfifo_2_stlast  : in  std_logic;
    phyi_pv_m_cfifo_2_hold    : in  std_logic;
    phyi_pv_m_cfifo_2_valid   : in  std_logic;
    phyi_pv_m_cfifo_2_err     : in  std_logic;
    
    phyi_pr_m_addr            : in  std_logic_vector(31 downto 0);
    phyi_pr_m_cbe_data        : in  std_logic_vector(3 downto 0);
    phyi_pr_m_cbe_cmd         : in  std_logic_vector(3 downto 0);
    phyi_pr_m_first           : in  std_logic_vector(1 downto 0);
    phyi_pv_m_term            : in  std_logic_vector(1 downto 0);
    phyi_pr_m_ltimer          : in  std_logic_vector(7 downto 0);
    phyi_pr_m_burst           : in  std_logic;
    phyi_pr_m_abort           : in  std_logic_vector(0 downto 0);
    phyi_pr_m_perren          : in  std_logic_vector(0 downto 0);
    phyi_pr_m_done_fifo       : in  std_logic;
    
    phyi_t_abort              : in  std_logic;
    phyi_t_ready              : in  std_logic;
    phyi_t_retry              : in  std_logic;
    phyi_pr_t_state           : in  std_logic_vector(2 downto 0); --pci_target_state_type;
    phyi_pv_t_state           : in  std_logic_vector(2 downto 0); --pci_target_state_type;
    phyi_pr_t_fstate          : in  std_logic_vector(1 downto 0); --pci_target_fifo_state_type;

    --phyi_pr_t_cfifo           : in  pci_core_fifo_vector_type;
    phyi_pr_t_cfifo_0_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_t_cfifo_0_last    : in  std_logic;
    phyi_pr_t_cfifo_0_stlast  : in  std_logic;
    phyi_pr_t_cfifo_0_hold    : in  std_logic;
    phyi_pr_t_cfifo_0_valid   : in  std_logic;
    phyi_pr_t_cfifo_0_err     : in  std_logic;
    phyi_pr_t_cfifo_1_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_t_cfifo_1_last    : in  std_logic;
    phyi_pr_t_cfifo_1_stlast  : in  std_logic;
    phyi_pr_t_cfifo_1_hold    : in  std_logic;
    phyi_pr_t_cfifo_1_valid   : in  std_logic;
    phyi_pr_t_cfifo_1_err     : in  std_logic;
    phyi_pr_t_cfifo_2_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_t_cfifo_2_last    : in  std_logic;
    phyi_pr_t_cfifo_2_stlast  : in  std_logic;
    phyi_pr_t_cfifo_2_hold    : in  std_logic;
    phyi_pr_t_cfifo_2_valid   : in  std_logic;
    phyi_pr_t_cfifo_2_err     : in  std_logic;
    phyi_pv_t_diswithout      : in  std_logic;
    phyi_pr_t_stoped          : in  std_logic;
    phyi_pr_t_lcount          : in  std_logic_vector(2 downto 0);
    phyi_pr_t_first_word      : in  std_logic;
    phyi_pr_t_cur_acc_0_read  : in  std_logic;
    phyi_pv_t_hold_write      : in  std_logic;
    phyi_pv_t_hold_reset      : in  std_logic;
    phyi_pr_conf_comm_perren  : in  std_logic;
    phyi_pr_conf_comm_serren  : in  std_logic;
    
    --pcio                      : out pci_out_type;
    pcio_aden                 : out std_ulogic;
    pcio_vaden                : out std_logic_vector(31 downto 0);
    pcio_cbeen                : out std_logic_vector(3 downto 0);
    pcio_frameen              : out std_ulogic;
    pcio_irdyen               : out std_ulogic;
    pcio_trdyen               : out std_ulogic;
    pcio_devselen             : out std_ulogic;
    pcio_stopen               : out std_ulogic;
    pcio_ctrlen               : out std_ulogic;
    pcio_perren               : out std_ulogic;
    pcio_paren                : out std_ulogic;
    pcio_reqen                : out std_ulogic;
    pcio_locken               : out std_ulogic;
    pcio_serren               : out std_ulogic;
    pcio_inten                : out std_ulogic;
    pcio_vinten               : out std_logic_vector(3 downto 0);
    pcio_req                  : out std_ulogic;
    pcio_ad                   : out std_logic_vector(31 downto 0);
    pcio_cbe                  : out std_logic_vector(3 downto 0);
    pcio_frame                : out std_ulogic;
    pcio_irdy                 : out std_ulogic;
    pcio_trdy                 : out std_ulogic;
    pcio_devsel               : out std_ulogic;
    pcio_stop                 : out std_ulogic;
    pcio_perr                 : out std_ulogic;
    pcio_serr                 : out std_ulogic;
    pcio_par                  : out std_ulogic;
    pcio_lock                 : out std_ulogic;
    pcio_power_state          : out std_logic_vector(1 downto 0);
    pcio_pme_enable           : out std_ulogic;
    pcio_pme_clear            : out std_ulogic;
    pcio_int                  : out std_ulogic;
    pcio_rst                  : out std_ulogic;
    
    --phyo                      : out grpci2_phy_out_type
    --phyo_pciv                 : out pci_in_type;
    phyo_pciv_rst             : out std_ulogic;
    phyo_pciv_gnt             : out std_ulogic;
    phyo_pciv_idsel           : out std_ulogic;
    phyo_pciv_ad              : out std_logic_vector(31 downto 0);
    phyo_pciv_cbe             : out std_logic_vector(3 downto 0);
    phyo_pciv_frame           : out std_ulogic;
    phyo_pciv_irdy            : out std_ulogic;
    phyo_pciv_trdy            : out std_ulogic;
    phyo_pciv_devsel          : out std_ulogic;
    phyo_pciv_stop            : out std_ulogic;
    phyo_pciv_lock            : out std_ulogic;
    phyo_pciv_perr            : out std_ulogic;
    phyo_pciv_serr            : out std_ulogic;
    phyo_pciv_par             : out std_ulogic;
    phyo_pciv_host            : out std_ulogic;
    phyo_pciv_pci66           : out std_ulogic;
    phyo_pciv_pme_status      : out std_ulogic;
    phyo_pciv_int             : out std_logic_vector(3 downto 0);

    phyo_pr_m_state           : out std_logic_vector(2 downto 0); --pci_master_state_type;
    phyo_pr_m_last            : out std_logic_vector(1 downto 0);
    phyo_pr_m_hold            : out std_logic_vector(1 downto 0);
    phyo_pr_m_term            : out std_logic_vector(1 downto 0);
    phyo_pr_t_hold            : out std_logic_vector(0 downto 0);
    phyo_pr_t_stop            : out std_logic;
    phyo_pr_t_abort           : out std_logic;
    phyo_pr_t_diswithout      : out std_logic;
    phyo_pr_t_addr_perr       : out std_logic;
    phyo_pcirsto              : out std_logic_vector(0 downto 0);
    
    --phyo_pr_po                : out pci_reg_out_type;
    phyo_pr_po_ad             : out std_logic_vector(31 downto 0);
    phyo_pr_po_aden           : out std_logic_vector(31 downto 0);
    phyo_pr_po_cbe            : out std_logic_vector(3 downto 0); 
    phyo_pr_po_cbeen          : out std_logic_vector(3 downto 0); 
    phyo_pr_po_frame          : out std_logic;
    phyo_pr_po_frameen        : out std_logic;
    phyo_pr_po_irdy           : out std_logic;
    phyo_pr_po_irdyen         : out std_logic;
    phyo_pr_po_trdy           : out std_logic;
    phyo_pr_po_trdyen         : out std_logic;
    phyo_pr_po_stop           : out std_logic;
    phyo_pr_po_stopen         : out std_logic;
    phyo_pr_po_devsel         : out std_logic;
    phyo_pr_po_devselen       : out std_logic;
    phyo_pr_po_par            : out std_logic;
    phyo_pr_po_paren          : out std_logic;
    phyo_pr_po_perr           : out std_logic;
    phyo_pr_po_perren         : out std_logic;
    phyo_pr_po_lock           : out std_logic;
    phyo_pr_po_locken         : out std_logic;
    phyo_pr_po_req            : out std_logic;
    phyo_pr_po_reqen          : out std_logic;
    phyo_pr_po_serren         : out std_logic;
    phyo_pr_po_inten          : out std_logic;
    phyo_pr_po_vinten         : out std_logic_vector(3 downto 0);

    --phyo_pio                  : out pci_in_type;
    phyo_pio_rst              : out std_ulogic;
    phyo_pio_gnt              : out std_ulogic;
    phyo_pio_idsel            : out std_ulogic;
    phyo_pio_ad               : out std_logic_vector(31 downto 0);
    phyo_pio_cbe              : out std_logic_vector(3 downto 0);
    phyo_pio_frame            : out std_ulogic;
    phyo_pio_irdy             : out std_ulogic;
    phyo_pio_trdy             : out std_ulogic;
    phyo_pio_devsel           : out std_ulogic;
    phyo_pio_stop             : out std_ulogic;
    phyo_pio_lock             : out std_ulogic;
    phyo_pio_perr             : out std_ulogic;
    phyo_pio_serr             : out std_ulogic;
    phyo_pio_par              : out std_ulogic;
    phyo_pio_host             : out std_ulogic;
    phyo_pio_pci66            : out std_ulogic;
    phyo_pio_pme_status       : out std_ulogic;
    phyo_pio_int              : out std_logic_vector(3 downto 0);

    --phyo_poo                  : out pci_reg_out_type;
    phyo_poo_ad               : out std_logic_vector(31 downto 0);
    phyo_poo_aden             : out std_logic_vector(31 downto 0);
    phyo_poo_cbe              : out std_logic_vector(3 downto 0); 
    phyo_poo_cbeen            : out std_logic_vector(3 downto 0); 
    phyo_poo_frame            : out std_logic;
    phyo_poo_frameen          : out std_logic;
    phyo_poo_irdy             : out std_logic;
    phyo_poo_irdyen           : out std_logic;
    phyo_poo_trdy             : out std_logic;
    phyo_poo_trdyen           : out std_logic;
    phyo_poo_stop             : out std_logic;
    phyo_poo_stopen           : out std_logic;
    phyo_poo_devsel           : out std_logic;
    phyo_poo_devselen         : out std_logic;
    phyo_poo_par              : out std_logic;
    phyo_poo_paren            : out std_logic;
    phyo_poo_perr             : out std_logic;
    phyo_poo_perren           : out std_logic;
    phyo_poo_lock             : out std_logic;
    phyo_poo_locken           : out std_logic;
    phyo_poo_req              : out std_logic;
    phyo_poo_reqen            : out std_logic;
    phyo_poo_serren           : out std_logic;
    phyo_poo_inten            : out std_logic;
    phyo_poo_vinten           : out std_logic_vector(3 downto 0)
  );
end grpci2_phy_net;

architecture struct of grpci2_phy_net is

component grpci2_phy_rtax_bypass is
--  generic(
--    tech    : integer := axcel;
--    oepol   : integer := 1;
--    bypass  : integer range 0 to 1 := 1;
--    netlist : integer := 1
--    scantest: integer := 0
--  );
  port(
    pciclk  : in  std_logic;

    --pcii                      : in  pci_in_type;
    pcii_rst                  : in  std_ulogic;
    pcii_gnt                  : in  std_ulogic;
    pcii_idsel                : in  std_ulogic;
    pcii_ad                   : in  std_logic_vector(31 downto 0);
    pcii_cbe                  : in  std_logic_vector(3 downto 0);
    pcii_frame                : in  std_ulogic;
    pcii_irdy                 : in  std_ulogic;
    pcii_trdy                 : in  std_ulogic;
    pcii_devsel               : in  std_ulogic;
    pcii_stop                 : in  std_ulogic;
    pcii_lock                 : in  std_ulogic;
    pcii_perr                 : in  std_ulogic;
    pcii_serr                 : in  std_ulogic;
    pcii_par                  : in  std_ulogic;
    pcii_host                 : in  std_ulogic;
    pcii_pci66                : in  std_ulogic;
    pcii_pme_status           : in  std_ulogic;
    pcii_int                  : in  std_logic_vector(3 downto 0);
    
    --phyi                      : in  grpci2_phy_in_type; 
    phyi_pcirstout            : in  std_logic;
    phyi_pciasyncrst          : in  std_logic;
    phyi_pcisoftrst           : in  std_logic_vector(2 downto 0);
    phyi_pciinten             : in  std_logic_vector(3 downto 0);
    phyi_m_request            : in  std_logic;
    phyi_m_mabort             : in  std_logic;
    phyi_pr_m_fstate          : in  std_logic_vector(1 downto 0); --pci_master_fifo_state_type;
    
    --phyi_pr_m_cfifo           : in  pci_core_fifo_vector_type; 
    phyi_pr_m_cfifo_0_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_m_cfifo_0_last    : in  std_logic;
    phyi_pr_m_cfifo_0_stlast  : in  std_logic;
    phyi_pr_m_cfifo_0_hold    : in  std_logic;
    phyi_pr_m_cfifo_0_valid   : in  std_logic;
    phyi_pr_m_cfifo_0_err     : in  std_logic;
    phyi_pr_m_cfifo_1_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_m_cfifo_1_last    : in  std_logic;
    phyi_pr_m_cfifo_1_stlast  : in  std_logic;
    phyi_pr_m_cfifo_1_hold    : in  std_logic;
    phyi_pr_m_cfifo_1_valid   : in  std_logic;
    phyi_pr_m_cfifo_1_err     : in  std_logic;
    phyi_pr_m_cfifo_2_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_m_cfifo_2_last    : in  std_logic;
    phyi_pr_m_cfifo_2_stlast  : in  std_logic;
    phyi_pr_m_cfifo_2_hold    : in  std_logic;
    phyi_pr_m_cfifo_2_valid   : in  std_logic;
    phyi_pr_m_cfifo_2_err     : in  std_logic;
  
    --phyi_pv_m_cfifo           : in  pci_core_fifo_vector_type; 
    phyi_pv_m_cfifo_0_data    : in  std_logic_vector(31 downto 0);
    phyi_pv_m_cfifo_0_last    : in  std_logic;
    phyi_pv_m_cfifo_0_stlast  : in  std_logic;
    phyi_pv_m_cfifo_0_hold    : in  std_logic;
    phyi_pv_m_cfifo_0_valid   : in  std_logic;
    phyi_pv_m_cfifo_0_err     : in  std_logic;
    phyi_pv_m_cfifo_1_data    : in  std_logic_vector(31 downto 0);
    phyi_pv_m_cfifo_1_last    : in  std_logic;
    phyi_pv_m_cfifo_1_stlast  : in  std_logic;
    phyi_pv_m_cfifo_1_hold    : in  std_logic;
    phyi_pv_m_cfifo_1_valid   : in  std_logic;
    phyi_pv_m_cfifo_1_err     : in  std_logic;
    phyi_pv_m_cfifo_2_data    : in  std_logic_vector(31 downto 0);
    phyi_pv_m_cfifo_2_last    : in  std_logic;
    phyi_pv_m_cfifo_2_stlast  : in  std_logic;
    phyi_pv_m_cfifo_2_hold    : in  std_logic;
    phyi_pv_m_cfifo_2_valid   : in  std_logic;
    phyi_pv_m_cfifo_2_err     : in  std_logic;
    
    phyi_pr_m_addr            : in  std_logic_vector(31 downto 0);
    phyi_pr_m_cbe_data        : in  std_logic_vector(3 downto 0);
    phyi_pr_m_cbe_cmd         : in  std_logic_vector(3 downto 0);
    phyi_pr_m_first           : in  std_logic_vector(1 downto 0);
    phyi_pv_m_term            : in  std_logic_vector(1 downto 0);
    phyi_pr_m_ltimer          : in  std_logic_vector(7 downto 0);
    phyi_pr_m_burst           : in  std_logic;
    phyi_pr_m_abort           : in  std_logic_vector(0 downto 0);
    phyi_pr_m_perren          : in  std_logic_vector(0 downto 0);
    phyi_pr_m_done_fifo       : in  std_logic;
    
    phyi_t_abort              : in  std_logic;
    phyi_t_ready              : in  std_logic;
    phyi_t_retry              : in  std_logic;
    phyi_pr_t_state           : in  std_logic_vector(2 downto 0); --pci_target_state_type;
    phyi_pv_t_state           : in  std_logic_vector(2 downto 0); --pci_target_state_type;
    phyi_pr_t_fstate          : in  std_logic_vector(1 downto 0); --pci_target_fifo_state_type;

    --phyi_pr_t_cfifo           : in  pci_core_fifo_vector_type;
    phyi_pr_t_cfifo_0_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_t_cfifo_0_last    : in  std_logic;
    phyi_pr_t_cfifo_0_stlast  : in  std_logic;
    phyi_pr_t_cfifo_0_hold    : in  std_logic;
    phyi_pr_t_cfifo_0_valid   : in  std_logic;
    phyi_pr_t_cfifo_0_err     : in  std_logic;
    phyi_pr_t_cfifo_1_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_t_cfifo_1_last    : in  std_logic;
    phyi_pr_t_cfifo_1_stlast  : in  std_logic;
    phyi_pr_t_cfifo_1_hold    : in  std_logic;
    phyi_pr_t_cfifo_1_valid   : in  std_logic;
    phyi_pr_t_cfifo_1_err     : in  std_logic;
    phyi_pr_t_cfifo_2_data    : in  std_logic_vector(31 downto 0);
    phyi_pr_t_cfifo_2_last    : in  std_logic;
    phyi_pr_t_cfifo_2_stlast  : in  std_logic;
    phyi_pr_t_cfifo_2_hold    : in  std_logic;
    phyi_pr_t_cfifo_2_valid   : in  std_logic;
    phyi_pr_t_cfifo_2_err     : in  std_logic;
    phyi_pv_t_diswithout      : in  std_logic;
    phyi_pr_t_stoped          : in  std_logic;
    phyi_pr_t_lcount          : in  std_logic_vector(2 downto 0);
    phyi_pr_t_first_word      : in  std_logic;
    phyi_pr_t_cur_acc_0_read  : in  std_logic;
    phyi_pv_t_hold_write      : in  std_logic;
    phyi_pv_t_hold_reset      : in  std_logic;
    phyi_pr_conf_comm_perren  : in  std_logic;
    phyi_pr_conf_comm_serren  : in  std_logic;
    
    --pcio                      : out pci_out_type;
    pcio_aden                 : out std_ulogic;
    pcio_vaden                : out std_logic_vector(31 downto 0);
    pcio_cbeen                : out std_logic_vector(3 downto 0);
    pcio_frameen              : out std_ulogic;
    pcio_irdyen               : out std_ulogic;
    pcio_trdyen               : out std_ulogic;
    pcio_devselen             : out std_ulogic;
    pcio_stopen               : out std_ulogic;
    pcio_ctrlen               : out std_ulogic;
    pcio_perren               : out std_ulogic;
    pcio_paren                : out std_ulogic;
    pcio_reqen                : out std_ulogic;
    pcio_locken               : out std_ulogic;
    pcio_serren               : out std_ulogic;
    pcio_inten                : out std_ulogic;
    pcio_vinten               : out std_logic_vector(3 downto 0);
    pcio_req                  : out std_ulogic;
    pcio_ad                   : out std_logic_vector(31 downto 0);
    pcio_cbe                  : out std_logic_vector(3 downto 0);
    pcio_frame                : out std_ulogic;
    pcio_irdy                 : out std_ulogic;
    pcio_trdy                 : out std_ulogic;
    pcio_devsel               : out std_ulogic;
    pcio_stop                 : out std_ulogic;
    pcio_perr                 : out std_ulogic;
    pcio_serr                 : out std_ulogic;
    pcio_par                  : out std_ulogic;
    pcio_lock                 : out std_ulogic;
    pcio_power_state          : out std_logic_vector(1 downto 0);
    pcio_pme_enable           : out std_ulogic;
    pcio_pme_clear            : out std_ulogic;
    pcio_int                  : out std_ulogic;
    pcio_rst                  : out std_ulogic;
    
    --phyo                      : out grpci2_phy_out_type
    --phyo_pciv                 : out pci_in_type;
    phyo_pciv_rst             : out std_ulogic;
    phyo_pciv_gnt             : out std_ulogic;
    phyo_pciv_idsel           : out std_ulogic;
    phyo_pciv_ad              : out std_logic_vector(31 downto 0);
    phyo_pciv_cbe             : out std_logic_vector(3 downto 0);
    phyo_pciv_frame           : out std_ulogic;
    phyo_pciv_irdy            : out std_ulogic;
    phyo_pciv_trdy            : out std_ulogic;
    phyo_pciv_devsel          : out std_ulogic;
    phyo_pciv_stop            : out std_ulogic;
    phyo_pciv_lock            : out std_ulogic;
    phyo_pciv_perr            : out std_ulogic;
    phyo_pciv_serr            : out std_ulogic;
    phyo_pciv_par             : out std_ulogic;
    phyo_pciv_host            : out std_ulogic;
    phyo_pciv_pci66           : out std_ulogic;
    phyo_pciv_pme_status      : out std_ulogic;
    phyo_pciv_int             : out std_logic_vector(3 downto 0);

    phyo_pr_m_state           : out std_logic_vector(2 downto 0); --pci_master_state_type;
    phyo_pr_m_last            : out std_logic_vector(1 downto 0);
    phyo_pr_m_hold            : out std_logic_vector(1 downto 0);
    phyo_pr_m_term            : out std_logic_vector(1 downto 0);
    phyo_pr_t_hold            : out std_logic_vector(0 downto 0);
    phyo_pr_t_stop            : out std_logic;
    phyo_pr_t_abort           : out std_logic;
    phyo_pr_t_diswithout      : out std_logic;
    phyo_pr_t_addr_perr       : out std_logic;
    phyo_pcirsto              : out std_logic_vector(0 downto 0);
    
    --phyo_pr_po                : out pci_reg_out_type;
    phyo_pr_po_ad             : out std_logic_vector(31 downto 0);
    phyo_pr_po_aden           : out std_logic_vector(31 downto 0);
    phyo_pr_po_cbe            : out std_logic_vector(3 downto 0); 
    phyo_pr_po_cbeen          : out std_logic_vector(3 downto 0); 
    phyo_pr_po_frame          : out std_logic;
    phyo_pr_po_frameen        : out std_logic;
    phyo_pr_po_irdy           : out std_logic;
    phyo_pr_po_irdyen         : out std_logic;
    phyo_pr_po_trdy           : out std_logic;
    phyo_pr_po_trdyen         : out std_logic;
    phyo_pr_po_stop           : out std_logic;
    phyo_pr_po_stopen         : out std_logic;
    phyo_pr_po_devsel         : out std_logic;
    phyo_pr_po_devselen       : out std_logic;
    phyo_pr_po_par            : out std_logic;
    phyo_pr_po_paren          : out std_logic;
    phyo_pr_po_perr           : out std_logic;
    phyo_pr_po_perren         : out std_logic;
    phyo_pr_po_lock           : out std_logic;
    phyo_pr_po_locken         : out std_logic;
    phyo_pr_po_req            : out std_logic;
    phyo_pr_po_reqen          : out std_logic;
    phyo_pr_po_serren         : out std_logic;
    phyo_pr_po_inten          : out std_logic;
    phyo_pr_po_vinten         : out std_logic_vector(3 downto 0);

    --phyo_pio                  : out pci_in_type;
    phyo_pio_rst              : out std_ulogic;
    phyo_pio_gnt              : out std_ulogic;
    phyo_pio_idsel            : out std_ulogic;
    phyo_pio_ad               : out std_logic_vector(31 downto 0);
    phyo_pio_cbe              : out std_logic_vector(3 downto 0);
    phyo_pio_frame            : out std_ulogic;
    phyo_pio_irdy             : out std_ulogic;
    phyo_pio_trdy             : out std_ulogic;
    phyo_pio_devsel           : out std_ulogic;
    phyo_pio_stop             : out std_ulogic;
    phyo_pio_lock             : out std_ulogic;
    phyo_pio_perr             : out std_ulogic;
    phyo_pio_serr             : out std_ulogic;
    phyo_pio_par              : out std_ulogic;
    phyo_pio_host             : out std_ulogic;
    phyo_pio_pci66            : out std_ulogic;
    phyo_pio_pme_status       : out std_ulogic;
    phyo_pio_int              : out std_logic_vector(3 downto 0);

    --phyo_poo                  : out pci_reg_out_type;
    phyo_poo_ad               : out std_logic_vector(31 downto 0);
    phyo_poo_aden             : out std_logic_vector(31 downto 0);
    phyo_poo_cbe              : out std_logic_vector(3 downto 0); 
    phyo_poo_cbeen            : out std_logic_vector(3 downto 0); 
    phyo_poo_frame            : out std_logic;
    phyo_poo_frameen          : out std_logic;
    phyo_poo_irdy             : out std_logic;
    phyo_poo_irdyen           : out std_logic;
    phyo_poo_trdy             : out std_logic;
    phyo_poo_trdyen           : out std_logic;
    phyo_poo_stop             : out std_logic;
    phyo_poo_stopen           : out std_logic;
    phyo_poo_devsel           : out std_logic;
    phyo_poo_devselen         : out std_logic;
    phyo_poo_par              : out std_logic;
    phyo_poo_paren            : out std_logic;
    phyo_poo_perr             : out std_logic;
    phyo_poo_perren           : out std_logic;
    phyo_poo_lock             : out std_logic;
    phyo_poo_locken           : out std_logic;
    phyo_poo_req              : out std_logic;
    phyo_poo_reqen            : out std_logic;
    phyo_poo_serren           : out std_logic;
    phyo_poo_inten            : out std_logic;
    phyo_poo_vinten           : out std_logic_vector(3 downto 0)
  );
end component;

begin

  ax : if ((tech = axcel) or (tech = axdsp)) and (bypass = 1) generate
    phy_bypass_rtax : grpci2_phy_rtax_bypass
      port map(
        pciclk                    => pciclk,
  
        --pcii                    : in  pci_in_type,
        pcii_rst                  => pcii_rst,
        pcii_gnt                  => pcii_gnt,
        pcii_idsel                => pcii_idsel,
        pcii_ad                   => pcii_ad,
        pcii_cbe                  => pcii_cbe,
        pcii_frame                => pcii_frame,
        pcii_irdy                 => pcii_irdy,
        pcii_trdy                 => pcii_trdy,
        pcii_devsel               => pcii_devsel,
        pcii_stop                 => pcii_stop,
        pcii_lock                 => pcii_lock,
        pcii_perr                 => pcii_perr,
        pcii_serr                 => pcii_serr,
        pcii_par                  => pcii_par,
        pcii_host                 => pcii_host,
        pcii_pci66                => pcii_pci66,
        pcii_pme_status           => pcii_pme_status,
        pcii_int                  => pcii_int,
                                                               
        --phyi                    : in  grpci2_phy_in_type, 
        phyi_pcirstout            => phyi_pcirstout,
        phyi_pciasyncrst          => phyi_pciasyncrst,
        phyi_pcisoftrst           => phyi_pcisoftrst,
        phyi_pciinten             => phyi_pciinten,
        phyi_m_request            => phyi_m_request,
        phyi_m_mabort             => phyi_m_mabort,
        phyi_pr_m_fstate          => phyi_pr_m_fstate,
        phyi_pr_m_cfifo_0_data    => phyi_pr_m_cfifo_0_data,
        phyi_pr_m_cfifo_0_last    => phyi_pr_m_cfifo_0_last,
        phyi_pr_m_cfifo_0_stlast  => phyi_pr_m_cfifo_0_stlast,
        phyi_pr_m_cfifo_0_hold    => phyi_pr_m_cfifo_0_hold,
        phyi_pr_m_cfifo_0_valid   => phyi_pr_m_cfifo_0_valid,
        phyi_pr_m_cfifo_0_err     => phyi_pr_m_cfifo_0_err,
        phyi_pr_m_cfifo_1_data    => phyi_pr_m_cfifo_1_data,
        phyi_pr_m_cfifo_1_last    => phyi_pr_m_cfifo_1_last,
        phyi_pr_m_cfifo_1_stlast  => phyi_pr_m_cfifo_1_stlast,
        phyi_pr_m_cfifo_1_hold    => phyi_pr_m_cfifo_1_hold,
        phyi_pr_m_cfifo_1_valid   => phyi_pr_m_cfifo_1_valid,
        phyi_pr_m_cfifo_1_err     => phyi_pr_m_cfifo_1_err,
        phyi_pr_m_cfifo_2_data    => phyi_pr_m_cfifo_2_data,
        phyi_pr_m_cfifo_2_last    => phyi_pr_m_cfifo_2_last,
        phyi_pr_m_cfifo_2_stlast  => phyi_pr_m_cfifo_2_stlast,
        phyi_pr_m_cfifo_2_hold    => phyi_pr_m_cfifo_2_hold,
        phyi_pr_m_cfifo_2_valid   => phyi_pr_m_cfifo_2_valid,
        phyi_pr_m_cfifo_2_err     => phyi_pr_m_cfifo_2_err,
        phyi_pv_m_cfifo_0_data    => phyi_pv_m_cfifo_0_data,
        phyi_pv_m_cfifo_0_last    => phyi_pv_m_cfifo_0_last,
        phyi_pv_m_cfifo_0_stlast  => phyi_pv_m_cfifo_0_stlast,
        phyi_pv_m_cfifo_0_hold    => phyi_pv_m_cfifo_0_hold,
        phyi_pv_m_cfifo_0_valid   => phyi_pv_m_cfifo_0_valid,
        phyi_pv_m_cfifo_0_err     => phyi_pv_m_cfifo_0_err,
        phyi_pv_m_cfifo_1_data    => phyi_pv_m_cfifo_1_data,
        phyi_pv_m_cfifo_1_last    => phyi_pv_m_cfifo_1_last,
        phyi_pv_m_cfifo_1_stlast  => phyi_pv_m_cfifo_1_stlast,
        phyi_pv_m_cfifo_1_hold    => phyi_pv_m_cfifo_1_hold,
        phyi_pv_m_cfifo_1_valid   => phyi_pv_m_cfifo_1_valid,
        phyi_pv_m_cfifo_1_err     => phyi_pv_m_cfifo_1_err,
        phyi_pv_m_cfifo_2_data    => phyi_pv_m_cfifo_2_data,
        phyi_pv_m_cfifo_2_last    => phyi_pv_m_cfifo_2_last,
        phyi_pv_m_cfifo_2_stlast  => phyi_pv_m_cfifo_2_stlast,
        phyi_pv_m_cfifo_2_hold    => phyi_pv_m_cfifo_2_hold,
        phyi_pv_m_cfifo_2_valid   => phyi_pv_m_cfifo_2_valid,
        phyi_pv_m_cfifo_2_err     => phyi_pv_m_cfifo_2_err,
        phyi_pr_m_addr            => phyi_pr_m_addr,
        phyi_pr_m_cbe_data        => phyi_pr_m_cbe_data,
        phyi_pr_m_cbe_cmd         => phyi_pr_m_cbe_cmd,
        phyi_pr_m_first           => phyi_pr_m_first,
        phyi_pv_m_term            => phyi_pv_m_term,
        phyi_pr_m_ltimer          => phyi_pr_m_ltimer,
        phyi_pr_m_burst           => phyi_pr_m_burst,
        phyi_pr_m_abort           => phyi_pr_m_abort,
        phyi_pr_m_perren          => phyi_pr_m_perren,
        phyi_pr_m_done_fifo       => phyi_pr_m_done_fifo,
        phyi_t_abort              => phyi_t_abort,
        phyi_t_ready              => phyi_t_ready,
        phyi_t_retry              => phyi_t_retry,
        phyi_pr_t_state           => phyi_pr_t_state,
        phyi_pv_t_state           => phyi_pv_t_state,
        phyi_pr_t_fstate          => phyi_pr_t_fstate,
        phyi_pr_t_cfifo_0_data    => phyi_pr_t_cfifo_0_data,
        phyi_pr_t_cfifo_0_last    => phyi_pr_t_cfifo_0_last,
        phyi_pr_t_cfifo_0_stlast  => phyi_pr_t_cfifo_0_stlast,
        phyi_pr_t_cfifo_0_hold    => phyi_pr_t_cfifo_0_hold,
        phyi_pr_t_cfifo_0_valid   => phyi_pr_t_cfifo_0_valid,
        phyi_pr_t_cfifo_0_err     => phyi_pr_t_cfifo_0_err,
        phyi_pr_t_cfifo_1_data    => phyi_pr_t_cfifo_1_data,
        phyi_pr_t_cfifo_1_last    => phyi_pr_t_cfifo_1_last,
        phyi_pr_t_cfifo_1_stlast  => phyi_pr_t_cfifo_1_stlast,
        phyi_pr_t_cfifo_1_hold    => phyi_pr_t_cfifo_1_hold,
        phyi_pr_t_cfifo_1_valid   => phyi_pr_t_cfifo_1_valid,
        phyi_pr_t_cfifo_1_err     => phyi_pr_t_cfifo_1_err,
        phyi_pr_t_cfifo_2_data    => phyi_pr_t_cfifo_2_data,
        phyi_pr_t_cfifo_2_last    => phyi_pr_t_cfifo_2_last,
        phyi_pr_t_cfifo_2_stlast  => phyi_pr_t_cfifo_2_stlast,
        phyi_pr_t_cfifo_2_hold    => phyi_pr_t_cfifo_2_hold,
        phyi_pr_t_cfifo_2_valid   => phyi_pr_t_cfifo_2_valid,
        phyi_pr_t_cfifo_2_err     => phyi_pr_t_cfifo_2_err,
        phyi_pv_t_diswithout      => phyi_pv_t_diswithout,
        phyi_pr_t_stoped          => phyi_pr_t_stoped,
        phyi_pr_t_lcount          => phyi_pr_t_lcount,
        phyi_pr_t_first_word      => phyi_pr_t_first_word,
        phyi_pr_t_cur_acc_0_read  => phyi_pr_t_cur_acc_0_read,
        phyi_pv_t_hold_write      => phyi_pv_t_hold_write,
        phyi_pv_t_hold_reset      => phyi_pv_t_hold_reset,
        phyi_pr_conf_comm_perren  => phyi_pr_conf_comm_perren,
        phyi_pr_conf_comm_serren  => phyi_pr_conf_comm_serren,
                                                               
        --pcio                    : out pci_out_type,
        pcio_aden                 => pcio_aden,
        pcio_vaden                => pcio_vaden,
        pcio_cbeen                => pcio_cbeen,
        pcio_frameen              => pcio_frameen,
        pcio_irdyen               => pcio_irdyen,
        pcio_trdyen               => pcio_trdyen,
        pcio_devselen             => pcio_devselen,
        pcio_stopen               => pcio_stopen,
        pcio_ctrlen               => pcio_ctrlen,
        pcio_perren               => pcio_perren,
        pcio_paren                => pcio_paren,
        pcio_reqen                => pcio_reqen,
        pcio_locken               => pcio_locken,
        pcio_serren               => pcio_serren,
        pcio_inten                => pcio_inten,
        pcio_vinten               => pcio_vinten,
        pcio_req                  => pcio_req,
        pcio_ad                   => pcio_ad,
        pcio_cbe                  => pcio_cbe,
        pcio_frame                => pcio_frame,
        pcio_irdy                 => pcio_irdy,
        pcio_trdy                 => pcio_trdy,
        pcio_devsel               => pcio_devsel,
        pcio_stop                 => pcio_stop,
        pcio_perr                 => pcio_perr,
        pcio_serr                 => pcio_serr,
        pcio_par                  => pcio_par,
        pcio_lock                 => pcio_lock,
        pcio_power_state          => pcio_power_state,
        pcio_pme_enable           => pcio_pme_enable,
        pcio_pme_clear            => pcio_pme_clear,
        pcio_int                  => pcio_int,
        pcio_rst                  => pcio_rst,
                                                               
        --phyo                    : out grpci2_phy_out_type
        phyo_pciv_rst             => phyo_pciv_rst,
        phyo_pciv_gnt             => phyo_pciv_gnt,
        phyo_pciv_idsel           => phyo_pciv_idsel,
        phyo_pciv_ad              => phyo_pciv_ad,
        phyo_pciv_cbe             => phyo_pciv_cbe,
        phyo_pciv_frame           => phyo_pciv_frame,
        phyo_pciv_irdy            => phyo_pciv_irdy,
        phyo_pciv_trdy            => phyo_pciv_trdy,
        phyo_pciv_devsel          => phyo_pciv_devsel,
        phyo_pciv_stop            => phyo_pciv_stop,
        phyo_pciv_lock            => phyo_pciv_lock,
        phyo_pciv_perr            => phyo_pciv_perr,
        phyo_pciv_serr            => phyo_pciv_serr,
        phyo_pciv_par             => phyo_pciv_par,
        phyo_pciv_host            => phyo_pciv_host,
        phyo_pciv_pci66           => phyo_pciv_pci66,
        phyo_pciv_pme_status      => phyo_pciv_pme_status,
        phyo_pciv_int             => phyo_pciv_int,
        phyo_pr_m_state           => phyo_pr_m_state,
        phyo_pr_m_last            => phyo_pr_m_last,
        phyo_pr_m_hold            => phyo_pr_m_hold,
        phyo_pr_m_term            => phyo_pr_m_term,
        phyo_pr_t_hold            => phyo_pr_t_hold,
        phyo_pr_t_stop            => phyo_pr_t_stop,
        phyo_pr_t_abort           => phyo_pr_t_abort,
        phyo_pr_t_diswithout      => phyo_pr_t_diswithout,
        phyo_pr_t_addr_perr       => phyo_pr_t_addr_perr,
        phyo_pcirsto              => phyo_pcirsto,
        phyo_pr_po_ad             => phyo_pr_po_ad,
        phyo_pr_po_aden           => phyo_pr_po_aden,
        phyo_pr_po_cbe            => phyo_pr_po_cbe,
        phyo_pr_po_cbeen          => phyo_pr_po_cbeen,
        phyo_pr_po_frame          => phyo_pr_po_frame,
        phyo_pr_po_frameen        => phyo_pr_po_frameen,
        phyo_pr_po_irdy           => phyo_pr_po_irdy,
        phyo_pr_po_irdyen         => phyo_pr_po_irdyen,
        phyo_pr_po_trdy           => phyo_pr_po_trdy,
        phyo_pr_po_trdyen         => phyo_pr_po_trdyen,
        phyo_pr_po_stop           => phyo_pr_po_stop,
        phyo_pr_po_stopen         => phyo_pr_po_stopen,
        phyo_pr_po_devsel         => phyo_pr_po_devsel,
        phyo_pr_po_devselen       => phyo_pr_po_devselen,
        phyo_pr_po_par            => phyo_pr_po_par,
        phyo_pr_po_paren          => phyo_pr_po_paren,
        phyo_pr_po_perr           => phyo_pr_po_perr,
        phyo_pr_po_perren         => phyo_pr_po_perren,
        phyo_pr_po_lock           => phyo_pr_po_lock,
        phyo_pr_po_locken         => phyo_pr_po_locken,
        phyo_pr_po_req            => phyo_pr_po_req,
        phyo_pr_po_reqen          => phyo_pr_po_reqen,
        phyo_pr_po_serren         => phyo_pr_po_serren,
        phyo_pr_po_inten          => phyo_pr_po_inten,
        phyo_pr_po_vinten         => phyo_pr_po_vinten,
        phyo_pio_rst              => phyo_pio_rst,
        phyo_pio_gnt              => phyo_pio_gnt,
        phyo_pio_idsel            => phyo_pio_idsel,
        phyo_pio_ad               => phyo_pio_ad,
        phyo_pio_cbe              => phyo_pio_cbe,
        phyo_pio_frame            => phyo_pio_frame,
        phyo_pio_irdy             => phyo_pio_irdy,
        phyo_pio_trdy             => phyo_pio_trdy,
        phyo_pio_devsel           => phyo_pio_devsel,
        phyo_pio_stop             => phyo_pio_stop,
        phyo_pio_lock             => phyo_pio_lock,
        phyo_pio_perr             => phyo_pio_perr,
        phyo_pio_serr             => phyo_pio_serr,
        phyo_pio_par              => phyo_pio_par,
        phyo_pio_host             => phyo_pio_host,
        phyo_pio_pci66            => phyo_pio_pci66,
        phyo_pio_pme_status       => phyo_pio_pme_status,
        phyo_pio_int              => phyo_pio_int,
        phyo_poo_ad               => phyo_poo_ad,
        phyo_poo_aden             => phyo_poo_aden,
        phyo_poo_cbe              => phyo_poo_cbe,
        phyo_poo_cbeen            => phyo_poo_cbeen,
        phyo_poo_frame            => phyo_poo_frame,
        phyo_poo_frameen          => phyo_poo_frameen,
        phyo_poo_irdy             => phyo_poo_irdy,
        phyo_poo_irdyen           => phyo_poo_irdyen,
        phyo_poo_trdy             => phyo_poo_trdy,
        phyo_poo_trdyen           => phyo_poo_trdyen,
        phyo_poo_stop             => phyo_poo_stop,
        phyo_poo_stopen           => phyo_poo_stopen,
        phyo_poo_devsel           => phyo_poo_devsel,
        phyo_poo_devselen         => phyo_poo_devselen,
        phyo_poo_par              => phyo_poo_par,
        phyo_poo_paren            => phyo_poo_paren,
        phyo_poo_perr             => phyo_poo_perr,
        phyo_poo_perren           => phyo_poo_perren,
        phyo_poo_lock             => phyo_poo_lock,
        phyo_poo_locken           => phyo_poo_locken,
        phyo_poo_req              => phyo_poo_req,
        phyo_poo_reqen            => phyo_poo_reqen,
        phyo_poo_serren           => phyo_poo_serren,
        phyo_poo_inten            => phyo_poo_inten,
        phyo_poo_vinten           => phyo_poo_vinten
      );

  end generate;

-- pragma translate_off
   nonet : if not (((tech = axcel) or (tech = axdsp)) and
                   (bypass = 1))
      generate
         err : process
         begin
            assert False report "ERROR : No pci_arb netlist available for this configuration!"
            severity Failure;
            wait;
         end process;
      end generate;
-- pragma translate_on

end struct;



