library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.netcomp.all;
use work.pci.all;

use work.pcilib2.all;

entity grpci2_phy_wrapper is
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

architecture wrapper of grpci2_phy_wrapper is
attribute dont_touch : boolean;
attribute dont_touch of net : label is true;

begin

  rtl : if netlist = 0 generate
    phy0 : grpci2_phy
    generic map( tech => tech, oepol => oepol, 
                 bypass => bypass, netlist => netlist,
                 scantest => scantest, iotest => iotest)
    port map(
      pciclk  => pciclk,
      pcii    => pcii,
      phyi    => phyi,
      pcio    => pcio,
      phyo    => phyo,
      iotmact => iotmact,
      iotmoe  => iotmoe,
      iotdout => iotdout,
      iotdin  => iotdin
    );
  end generate;
    
  net : if netlist /= 0 generate
    phy0 : grpci2_phy_net
    generic map( tech => tech, oepol => oepol, 
                 bypass => bypass, netlist => netlist)
    port map(
      pciclk                    => pciclk,
  
      --pcii                    : in  pci_in_type,
      pcii_rst                  => pcii.rst,
      pcii_gnt                  => pcii.gnt,
      pcii_idsel                => pcii.idsel,
      pcii_ad                   => pcii.ad,
      pcii_cbe                  => pcii.cbe,
      pcii_frame                => pcii.frame,
      pcii_irdy                 => pcii.irdy,
      pcii_trdy                 => pcii.trdy,
      pcii_devsel               => pcii.devsel,
      pcii_stop                 => pcii.stop,
      pcii_lock                 => pcii.lock,
      pcii_perr                 => pcii.perr,
      pcii_serr                 => pcii.serr,
      pcii_par                  => pcii.par,
      pcii_host                 => pcii.host,
      pcii_pci66                => pcii.pci66,
      pcii_pme_status           => pcii.pme_status,
      pcii_int                  => pcii.int,
                                                             
      --phyi                    : in  grpci2_phy_in_type, 
      phyi_pcirstout            => phyi.pcirstout,
      phyi_pciasyncrst          => phyi.pciasyncrst,
      phyi_pcisoftrst           => phyi.pcisoftrst,
      phyi_pciinten             => phyi.pciinten,
      phyi_m_request            => phyi.m_request,
      phyi_m_mabort             => phyi.m_mabort,
      phyi_pr_m_fstate          => phyi.pr_m_fstate,
      phyi_pr_m_cfifo_0_data    => phyi.pr_m_cfifo(0).data,
      phyi_pr_m_cfifo_0_last    => phyi.pr_m_cfifo(0).last,
      phyi_pr_m_cfifo_0_stlast  => phyi.pr_m_cfifo(0).stlast,
      phyi_pr_m_cfifo_0_hold    => phyi.pr_m_cfifo(0).hold,
      phyi_pr_m_cfifo_0_valid   => phyi.pr_m_cfifo(0).valid,
      phyi_pr_m_cfifo_0_err     => phyi.pr_m_cfifo(0).err,
      phyi_pr_m_cfifo_1_data    => phyi.pr_m_cfifo(1).data,
      phyi_pr_m_cfifo_1_last    => phyi.pr_m_cfifo(1).last,
      phyi_pr_m_cfifo_1_stlast  => phyi.pr_m_cfifo(1).stlast,
      phyi_pr_m_cfifo_1_hold    => phyi.pr_m_cfifo(1).hold,
      phyi_pr_m_cfifo_1_valid   => phyi.pr_m_cfifo(1).valid,
      phyi_pr_m_cfifo_1_err     => phyi.pr_m_cfifo(1).err,
      phyi_pr_m_cfifo_2_data    => phyi.pr_m_cfifo(2).data,
      phyi_pr_m_cfifo_2_last    => phyi.pr_m_cfifo(2).last,
      phyi_pr_m_cfifo_2_stlast  => phyi.pr_m_cfifo(2).stlast,
      phyi_pr_m_cfifo_2_hold    => phyi.pr_m_cfifo(2).hold,
      phyi_pr_m_cfifo_2_valid   => phyi.pr_m_cfifo(2).valid,
      phyi_pr_m_cfifo_2_err     => phyi.pr_m_cfifo(2).err,
      phyi_pv_m_cfifo_0_data    => phyi.pv_m_cfifo(0).data,
      phyi_pv_m_cfifo_0_last    => phyi.pv_m_cfifo(0).last,
      phyi_pv_m_cfifo_0_stlast  => phyi.pv_m_cfifo(0).stlast,
      phyi_pv_m_cfifo_0_hold    => phyi.pv_m_cfifo(0).hold,
      phyi_pv_m_cfifo_0_valid   => phyi.pv_m_cfifo(0).valid,
      phyi_pv_m_cfifo_0_err     => phyi.pv_m_cfifo(0).err,
      phyi_pv_m_cfifo_1_data    => phyi.pv_m_cfifo(1).data,
      phyi_pv_m_cfifo_1_last    => phyi.pv_m_cfifo(1).last,
      phyi_pv_m_cfifo_1_stlast  => phyi.pv_m_cfifo(1).stlast,
      phyi_pv_m_cfifo_1_hold    => phyi.pv_m_cfifo(1).hold,
      phyi_pv_m_cfifo_1_valid   => phyi.pv_m_cfifo(1).valid,
      phyi_pv_m_cfifo_1_err     => phyi.pv_m_cfifo(1).err,
      phyi_pv_m_cfifo_2_data    => phyi.pv_m_cfifo(2).data,
      phyi_pv_m_cfifo_2_last    => phyi.pv_m_cfifo(2).last,
      phyi_pv_m_cfifo_2_stlast  => phyi.pv_m_cfifo(2).stlast,
      phyi_pv_m_cfifo_2_hold    => phyi.pv_m_cfifo(2).hold,
      phyi_pv_m_cfifo_2_valid   => phyi.pv_m_cfifo(2).valid,
      phyi_pv_m_cfifo_2_err     => phyi.pv_m_cfifo(2).err,
      phyi_pr_m_addr            => phyi.pr_m_addr,
      phyi_pr_m_cbe_data        => phyi.pr_m_cbe_data,
      phyi_pr_m_cbe_cmd         => phyi.pr_m_cbe_cmd,
      phyi_pr_m_first           => phyi.pr_m_first,
      phyi_pv_m_term            => phyi.pv_m_term,
      phyi_pr_m_ltimer          => phyi.pr_m_ltimer,
      phyi_pr_m_burst           => phyi.pr_m_burst,
      phyi_pr_m_abort           => phyi.pr_m_abort,
      phyi_pr_m_perren          => phyi.pr_m_perren,
      phyi_pr_m_done_fifo       => phyi.pr_m_done_fifo,
      phyi_t_abort              => phyi.t_abort,
      phyi_t_ready              => phyi.t_ready,
      phyi_t_retry              => phyi.t_retry,
      phyi_pr_t_state           => phyi.pr_t_state,
      phyi_pv_t_state           => phyi.pv_t_state,
      phyi_pr_t_fstate          => phyi.pr_t_fstate,
      phyi_pr_t_cfifo_0_data    => phyi.pr_t_cfifo(0).data,
      phyi_pr_t_cfifo_0_last    => phyi.pr_t_cfifo(0).last,
      phyi_pr_t_cfifo_0_stlast  => phyi.pr_t_cfifo(0).stlast,
      phyi_pr_t_cfifo_0_hold    => phyi.pr_t_cfifo(0).hold,
      phyi_pr_t_cfifo_0_valid   => phyi.pr_t_cfifo(0).valid,
      phyi_pr_t_cfifo_0_err     => phyi.pr_t_cfifo(0).err,
      phyi_pr_t_cfifo_1_data    => phyi.pr_t_cfifo(1).data,
      phyi_pr_t_cfifo_1_last    => phyi.pr_t_cfifo(1).last,
      phyi_pr_t_cfifo_1_stlast  => phyi.pr_t_cfifo(1).stlast,
      phyi_pr_t_cfifo_1_hold    => phyi.pr_t_cfifo(1).hold,
      phyi_pr_t_cfifo_1_valid   => phyi.pr_t_cfifo(1).valid,
      phyi_pr_t_cfifo_1_err     => phyi.pr_t_cfifo(1).err,
      phyi_pr_t_cfifo_2_data    => phyi.pr_t_cfifo(2).data,
      phyi_pr_t_cfifo_2_last    => phyi.pr_t_cfifo(2).last,
      phyi_pr_t_cfifo_2_stlast  => phyi.pr_t_cfifo(2).stlast,
      phyi_pr_t_cfifo_2_hold    => phyi.pr_t_cfifo(2).hold,
      phyi_pr_t_cfifo_2_valid   => phyi.pr_t_cfifo(2).valid,
      phyi_pr_t_cfifo_2_err     => phyi.pr_t_cfifo(2).err,
      phyi_pv_t_diswithout      => phyi.pv_t_diswithout,
      phyi_pr_t_stoped          => phyi.pr_t_stoped,
      phyi_pr_t_lcount          => phyi.pr_t_lcount,
      phyi_pr_t_first_word      => phyi.pr_t_first_word,
      phyi_pr_t_cur_acc_0_read  => phyi.pr_t_cur_acc_0_read,
      phyi_pv_t_hold_write      => phyi.pv_t_hold_write,
      phyi_pv_t_hold_reset      => phyi.pv_t_hold_reset,
      phyi_pr_conf_comm_perren  => phyi.pr_conf_comm_perren,
      phyi_pr_conf_comm_serren  => phyi.pr_conf_comm_serren,
                                                             
      --pcio                    : out pci_out_type,
      pcio_aden                 => pcio.aden,
      pcio_vaden                => pcio.vaden,
      pcio_cbeen                => pcio.cbeen,
      pcio_frameen              => pcio.frameen,
      pcio_irdyen               => pcio.irdyen,
      pcio_trdyen               => pcio.trdyen,
      pcio_devselen             => pcio.devselen,
      pcio_stopen               => pcio.stopen,
      pcio_ctrlen               => pcio.ctrlen,
      pcio_perren               => pcio.perren,
      pcio_paren                => pcio.paren,
      pcio_reqen                => pcio.reqen,
      pcio_locken               => pcio.locken,
      pcio_serren               => pcio.serren,
      pcio_inten                => pcio.inten,
      pcio_vinten               => pcio.vinten,
      pcio_req                  => pcio.req,
      pcio_ad                   => pcio.ad,
      pcio_cbe                  => pcio.cbe,
      pcio_frame                => pcio.frame,
      pcio_irdy                 => pcio.irdy,
      pcio_trdy                 => pcio.trdy,
      pcio_devsel               => pcio.devsel,
      pcio_stop                 => pcio.stop,
      pcio_perr                 => pcio.perr,
      pcio_serr                 => pcio.serr,
      pcio_par                  => pcio.par,
      pcio_lock                 => pcio.lock,
      pcio_power_state          => pcio.power_state,
      pcio_pme_enable           => pcio.pme_enable,
      pcio_pme_clear            => pcio.pme_clear,
      pcio_int                  => pcio.int,
      pcio_rst                  => pcio.rst,
                                                             
      --phyo                    : out grpci2_phy_out_type
      phyo_pciv_rst             => phyo.pciv.rst,
      phyo_pciv_gnt             => phyo.pciv.gnt,
      phyo_pciv_idsel           => phyo.pciv.idsel,
      phyo_pciv_ad              => phyo.pciv.ad,
      phyo_pciv_cbe             => phyo.pciv.cbe,
      phyo_pciv_frame           => phyo.pciv.frame,
      phyo_pciv_irdy            => phyo.pciv.irdy,
      phyo_pciv_trdy            => phyo.pciv.trdy,
      phyo_pciv_devsel          => phyo.pciv.devsel,
      phyo_pciv_stop            => phyo.pciv.stop,
      phyo_pciv_lock            => phyo.pciv.lock,
      phyo_pciv_perr            => phyo.pciv.perr,
      phyo_pciv_serr            => phyo.pciv.serr,
      phyo_pciv_par             => phyo.pciv.par,
      phyo_pciv_host            => phyo.pciv.host,
      phyo_pciv_pci66           => phyo.pciv.pci66,
      phyo_pciv_pme_status      => phyo.pciv.pme_status,
      phyo_pciv_int             => phyo.pciv.int,
      phyo_pr_m_state           => phyo.pr_m_state,
      phyo_pr_m_last            => phyo.pr_m_last,
      phyo_pr_m_hold            => phyo.pr_m_hold,
      phyo_pr_m_term            => phyo.pr_m_term,
      phyo_pr_t_hold            => phyo.pr_t_hold,
      phyo_pr_t_stop            => phyo.pr_t_stop,
      phyo_pr_t_abort           => phyo.pr_t_abort,
      phyo_pr_t_diswithout      => phyo.pr_t_diswithout,
      phyo_pr_t_addr_perr       => phyo.pr_t_addr_perr,
      phyo_pcirsto              => phyo.pcirsto,
      phyo_pr_po_ad             => phyo.pr_po.ad,
      phyo_pr_po_aden           => phyo.pr_po.aden,
      phyo_pr_po_cbe            => phyo.pr_po.cbe,
      phyo_pr_po_cbeen          => phyo.pr_po.cbeen,
      phyo_pr_po_frame          => phyo.pr_po.frame,
      phyo_pr_po_frameen        => phyo.pr_po.frameen,
      phyo_pr_po_irdy           => phyo.pr_po.irdy,
      phyo_pr_po_irdyen         => phyo.pr_po.irdyen,
      phyo_pr_po_trdy           => phyo.pr_po.trdy,
      phyo_pr_po_trdyen         => phyo.pr_po.trdyen,
      phyo_pr_po_stop           => phyo.pr_po.stop,
      phyo_pr_po_stopen         => phyo.pr_po.stopen,
      phyo_pr_po_devsel         => phyo.pr_po.devsel,
      phyo_pr_po_devselen       => phyo.pr_po.devselen,
      phyo_pr_po_par            => phyo.pr_po.par,
      phyo_pr_po_paren          => phyo.pr_po.paren,
      phyo_pr_po_perr           => phyo.pr_po.perr,
      phyo_pr_po_perren         => phyo.pr_po.perren,
      phyo_pr_po_lock           => phyo.pr_po.lock,
      phyo_pr_po_locken         => phyo.pr_po.locken,
      phyo_pr_po_req            => phyo.pr_po.req,
      phyo_pr_po_reqen          => phyo.pr_po.reqen,
      phyo_pr_po_serren         => phyo.pr_po.serren,
      phyo_pr_po_inten          => phyo.pr_po.inten,
      phyo_pr_po_vinten         => phyo.pr_po.vinten,
      phyo_pio_rst              => phyo.pio.rst,
      phyo_pio_gnt              => phyo.pio.gnt,
      phyo_pio_idsel            => phyo.pio.idsel,
      phyo_pio_ad               => phyo.pio.ad,
      phyo_pio_cbe              => phyo.pio.cbe,
      phyo_pio_frame            => phyo.pio.frame,
      phyo_pio_irdy             => phyo.pio.irdy,
      phyo_pio_trdy             => phyo.pio.trdy,
      phyo_pio_devsel           => phyo.pio.devsel,
      phyo_pio_stop             => phyo.pio.stop,
      phyo_pio_lock             => phyo.pio.lock,
      phyo_pio_perr             => phyo.pio.perr,
      phyo_pio_serr             => phyo.pio.serr,
      phyo_pio_par              => phyo.pio.par,
      phyo_pio_host             => phyo.pio.host,
      phyo_pio_pci66            => phyo.pio.pci66,
      phyo_pio_pme_status       => phyo.pio.pme_status,
      phyo_pio_int              => phyo.pio.int,
      phyo_poo_ad               => phyo.poo.ad,
      phyo_poo_aden             => phyo.poo.aden,
      phyo_poo_cbe              => phyo.poo.cbe,
      phyo_poo_cbeen            => phyo.poo.cbeen,
      phyo_poo_frame            => phyo.poo.frame,
      phyo_poo_frameen          => phyo.poo.frameen,
      phyo_poo_irdy             => phyo.poo.irdy,
      phyo_poo_irdyen           => phyo.poo.irdyen,
      phyo_poo_trdy             => phyo.poo.trdy,
      phyo_poo_trdyen           => phyo.poo.trdyen,
      phyo_poo_stop             => phyo.poo.stop,
      phyo_poo_stopen           => phyo.poo.stopen,
      phyo_poo_devsel           => phyo.poo.devsel,
      phyo_poo_devselen         => phyo.poo.devselen,
      phyo_poo_par              => phyo.poo.par,
      phyo_poo_paren            => phyo.poo.paren,
      phyo_poo_perr             => phyo.poo.perr,
      phyo_poo_perren           => phyo.poo.perren,
      phyo_poo_lock             => phyo.poo.lock,
      phyo_poo_locken           => phyo.poo.locken,
      phyo_poo_req              => phyo.poo.req,
      phyo_poo_reqen            => phyo.poo.reqen,
      phyo_poo_serren           => phyo.poo.serren,
      phyo_poo_inten            => phyo.poo.inten,
      phyo_poo_vinten           => phyo.poo.vinten
    );
  end generate;
end;

