/* GRPCI2 APB Register *********************************************************** */
/* Ctrl register */
#define GRPCI2_CTRL_RST       (1 << 31)
#define GRPCI2_CTRL_MRST      (1 << 30)
#define GRPCI2_CTRL_TRST      (1 << 29)
#define GRPCI2_CTRL_SERRIEN   (1 << 27)
#define GRPCI2_CTRL_PERRAEEN  (1 << 26)
#define GRPCI2_CTRL_ABORTAEEN (1 << 25)
#define GRPCI2_CTRL_ABORTIEN  (1 << 24)
#define GRPCI2_CTRL_CFG_BUS 16                /* 23:16 */
#define GRPCI2_CTRL_CFG_BUS_MASK (0xFF << 16)
#define GRPCI2_CTRL_IOBURST   (1 << 10)
#define GRPCI2_CTRL_CFGBURST  (1 <<  9)
#define GRPCI2_CTRL_PINTFORCE (1 <<  8)
#define GRPCI2_CTRL_DEVINT_MASK 4             /*  7: 4 */
#define GRPCI2_CTRL_DEVINT_MASK_MASK (0xF << 4)
#define GRPCI2_CTRL_HOSTINT_MASK 0            /*  3: 0 */
#define GRPCI2_CTRL_HOSTINT_MASK_MASK (0xF << 0)

/* Status register */
#define GRPCI2_STA_HOST         (1 << 31)
#define GRPCI2_STA_MASTER       (1 << 30)
#define GRPCI2_STA_TARGET       (1 << 29)
#define GRPCI2_STA_DMA          (1 << 28)
#define GRPCI2_STA_DEVINT       (1 << 27)
#define GRPCI2_STA_HOSTINT      (1 << 26)
#define GRPCI2_STA_IRQ_MODE 24                  /* 25:24 */
#define GRPCI2_STA_IRQ_MODE_MASK (0x3 << 24)
#define GRPCI2_STA_TRACE        (1 << 23)
#define GRPCI2_STA_CFG_DONE     (1 << 20)
#define GRPCI2_STA_CFG_ERR      (1 << 19)
#define GRPCI2_STA_IRQ_STATUS 12                /* 18:12 */
#define GRPCI2_STA_IRQ_STATUS_MASK (0x7F << 12)
#define GRPCI2_STA_IRQ_DISCARD  (1 << 18)
#define GRPCI2_STA_IRQ_SERR     (1 << 17)
#define GRPCI2_STA_IRQ_DMAINT   (1 << 16)
#define GRPCI2_STA_IRQ_DMAERR   (1 << 15)
#define GRPCI2_STA_IRQ_MABORT   (1 << 14)
#define GRPCI2_STA_IRQ_TABORT   (1 << 13)
#define GRPCI2_STA_IRQ_PERR     (1 << 12)
#define GRPCI2_STA_HOSTINT_STATUS 8             /* 11: 8 */
#define GRPCI2_STA_HOSTINT_STATUS_MASK (0xF << 8)
#define GRPCI2_STA_FIFO_DEPTH 2                 /*  4: 2 */
#define GRPCI2_STA_FIFO_DEPTH_MASK (0x3 << 2)
#define GRPCI2_STA_FIFO_CNT 0                   /*  4: 2 */
#define GRPCI2_STA_FIFO_CNT_MASK (0x3 << 0)

/* PCI-master burst limit register */
#define GRPCI2_PCIMSTBURST_AHBMST_INDEX 16      /* 31:16 */
#define GRPCI2_PCIMSTBURST_AHBMST_INDEX_MASK (0xFFFF << 16)
#define GRPCI2_PCIMSTBURST_BURST_LENGTH 0       /*  7: 0 */
#define GRPCI2_PCIMSTBURST_BURST_LENGHT_MASK (0xFF << 0)

/* PCI IO map register */
#define GRPCI2_PCIIO_MAP 16                     /* 31:16 */
#define GRPCI2_PCIIO_MAP_MASK (0xFFFF << 16)

/* DMA Ctrl/Status register */
#define GRPCI2_DMACTRL_GUARD        (1 << 31)
#define GRPCI2_DMACTRL_CHIRQ 12                 /* 19:12 */
#define GRPCI2_DMACTRL_CHIRQ_MASK   (0xFF<< 12)
#define GRPCI2_DMACTRL_MABORT       (1 << 11)
#define GRPCI2_DMACTRL_TABORT       (1 << 10)
#define GRPCI2_DMACTRL_PERR         (1 <<  9)
#define GRPCI2_DMACTRL_AHBDATA_ERR  (1 <<  8)
#define GRPCI2_DMACTRL_AHBDESC_ERR  (1 <<  7)
#define GRPCI2_DMACTRL_NUMCH 4                  /*  6: 4 */
#define GRPCI2_DMACTRL_NUMCH_MASK   (0x7 << 4)
#define GRPCI2_DMACTRL_ACTIVE       (1 <<  3)
#define GRPCI2_DMACTRL_IRQEN        (1 <<  1)
#define GRPCI2_DMACTRL_EN           (1 <<  0)

/* DMA Descriptor base register */
#define GRPCI2_DMADESC 0      /* 31: 0 */
#define GRPCI2_DMADESC_MASK (0xFFFFFFFF << 0)

/* DMA Active channel register */
#define GRPCI2_DMACH 0                          /* 31: 0 */
#define GRPCI2_DMACH_MASK (0xFFFFFFFF << 0)

/* PCI BAR Map register */
#define GRPCI2_PCIBAR_MAP 0                     /* 31: 0 */
#define GRPCI2_PCIBAR_MAP_MASK (0xFFFFFFFF << 0)

/* AHB Master Map register */
#define GRPCI2_AHBMST_MAP 0                     /* 31: 0 */
#define GRPCI2_AHBMST_MAP_MASK (0xFFFFFFFF << 0)

/* PCI-trace Ctrl/Status register */
#define GRPCI2_TBCTRL_INDEX 16                  /* 31:16 */
#define GRPCI2_TBCTRL_INDEX_MASK (0xFFFF << 16)
#define GRPCI2_TBCTRL_ARMED       (1 << 15)
#define GRPCI2_TBCTRL_RUNNING     (1 << 14)
#define GRPCI2_TBCTRL_DEPTH 4                   /* 11: 4 */
#define GRPCI2_TBCTRL_DEPTH_MASK (0xFF << 4)
#define GRPCI2_TBCTRL_START      (1 <<  1)
#define GRPCI2_TBCTRL_STOP       (1 <<  0)

/* PCI-trace Count/Mode register */
#define GRPCI2_TBCM_MODE 24                     /* 27:24 */
#define GRPCI2_TBCM_MODE_MASK (0xF << 24)
#define GRPCI2_TBCM_TCNT 16                     /* 23:16 */
#define GRPCI2_TBCM_TCNT_MASK (0xFF << 16)
#define GRPCI2_TBCM_DEL 0                       /* 15: 0 */
#define GRPCI2_TBCM_DEL_MASK (0xFFFF << 0)

/* PCI-trace AD pattern register */
#define GRPCI2_TBAD_PAT 0                       /* 31: 0 */
#define GRPCI2_TBAD_PAT_MASK (0xFFFFFFFF << 0)

/* PCI-trace AD mask register */
#define GRPCI2_TBAD_MASK 0                      /* 31: 0 */
#define GRPCI2_TBAD_MASK_MASK (0xFFFFFFFF << 0)

/* PCI-trace Ctrl-signals register */
#define GRPCI2_TBSIG_CBE 16                     /* 19:16 */
#define GRPCI2_TBSIG_CBE_MASK (0xFFFF << 16)
#define GRPCI2_TBSIG_FRAME        (1 << 15)
#define GRPCI2_TBSIG_IRDY         (1 << 14)
#define GRPCI2_TBSIG_TRDY         (1 << 13)
#define GRPCI2_TBSIG_STOP         (1 << 12)
#define GRPCI2_TBSIG_DEVSEL       (1 << 11)
#define GRPCI2_TBSIG_PAR          (1 << 10)
#define GRPCI2_TBSIG_PERR         (1 <<  9)
#define GRPCI2_TBSIG_SERR         (1 <<  8)
#define GRPCI2_TBSIG_IDSEL        (1 <<  7)
#define GRPCI2_TBSIG_REQ          (1 <<  6)
#define GRPCI2_TBSIG_GNT          (1 <<  5)
#define GRPCI2_TBSIG_LOCK         (1 <<  4)
#define GRPCI2_TBSIG_RST          (1 <<  3)

/* PCI-trace Ctrl-signals mask register */
#define GRPCI2_TBSIG_MASK_CBE 16                     /* 19:16 */
#define GRPCI2_TBSIG_MASK_CBE_MASK (0xFFFF << 16)
#define GRPCI2_TBSIG_MASK_FRAME        (1 << 15)
#define GRPCI2_TBSIG_MASK_IRDY         (1 << 14)
#define GRPCI2_TBSIG_MASK_TRDY         (1 << 13)
#define GRPCI2_TBSIG_MASK_STOP         (1 << 12)
#define GRPCI2_TBSIG_MASK_DEVSEL       (1 << 11)
#define GRPCI2_TBSIG_MASK_PAR          (1 << 10)
#define GRPCI2_TBSIG_MASK_PERR         (1 <<  9)
#define GRPCI2_TBSIG_MASK_SERR         (1 <<  8)
#define GRPCI2_TBSIG_MASK_IDSEL        (1 <<  7)
#define GRPCI2_TBSIG_MASK_REQ          (1 <<  6)
#define GRPCI2_TBSIG_MASK_GNT          (1 <<  5)
#define GRPCI2_TBSIG_MASK_LOCK         (1 <<  4)
#define GRPCI2_TBSIG_MASK_RST          (1 <<  3)

/* PCI-trace AD state register */
#define GRPCI2_TBAD_STATE 0                       /* 31: 0 */
#define GRPCI2_TBAD_STATE_MASK (0xFFFFFFFF << 0)

/* PCI-trace Ctrl-signals state register */
#define GRPCI2_TBSIG_STATE_CBE 16                     /* 19:16 */
#define GRPCI2_TBSIG_STATE_CBE_MASK (0xFFFF << 16)
#define GRPCI2_TBSIG_STATE_FRAME        (1 << 15)
#define GRPCI2_TBSIG_STATE_IRDY         (1 << 14)
#define GRPCI2_TBSIG_STATE_TRDY         (1 << 13)
#define GRPCI2_TBSIG_STATE_STOP         (1 << 12)
#define GRPCI2_TBSIG_STATE_DEVSEL       (1 << 11)
#define GRPCI2_TBSIG_STATE_PAR          (1 << 10)
#define GRPCI2_TBSIG_STATE_PERR         (1 <<  9)
#define GRPCI2_TBSIG_STATE_SERR         (1 <<  8)
#define GRPCI2_TBSIG_STATE_IDSEL        (1 <<  7)
#define GRPCI2_TBSIG_STATE_REQ          (1 <<  6)
#define GRPCI2_TBSIG_STATE_GNT          (1 <<  5)
#define GRPCI2_TBSIG_STATE_LOCK         (1 <<  4)
#define GRPCI2_TBSIG_STATE_RST          (1 <<  3)
/* ******************************************************************************* */

/* GRPCI2 Ext. Config Space Register ********************************************* */
/* PCI BAR Map register */
#define GRPCI2_ECFG_PCIBAR_MAP 0                     /* 31: 0 */
#define GRPCI2_ECFG_PCIBAR_MAP_MASK (0xFFFFFFFF << 0)

/* Extended PCI Configuration Space AHB map register */
#define GRPCI2_ECFG_ECFGAHB_MAP 8                     /* 31: 8 */
#define GRPCI2_ECFG_ECFGAHB_MAP_MASK (0xFFFFFF << 8)

/* AHB IO base and PCI bus config register */
#define GRPCI2_ECFG_AHBIOBASE 20                      /* 31:20 */
#define GRPCI2_ECFG_AHBIOBASE_MASK (0xFFF << 20)
#define GRPCI2_ECFG_DISEN               (1 <<  1)
#define GRPCI2_ECFG_ENDIAN              (1 <<  0)

/* PCI BAR size register */
#define GRPCI2_BARSIZE_MASK  4                        /* 31: 4 */
#define GRPCI2_BARSIZE_MASK_MASK (0xFFFFFFF << 4)
#define GRPCI2_BARSIZE_PRE              (1 <<  1)
#define GRPCI2_BARSIZE_TYPE             (1 <<  0)
#define GRPCI2_BARSIZE_TYPE_MEM         (0 <<  0)
#define GRPCI2_BARSIZE_TYPE_IO          (1 <<  0)

/* AHB-master burst limit register */
#define GRPCI2_AHBMSTBURST_BURST_LENGTH 0             /* 15: 0 */
#define GRPCI2_AHBMSTBURST_BURST_LENGHT_MASK (0xFFFF << 0)
/* ******************************************************************************* */

/* GRPCI2 DMA Descriptors ******************************************************** */
/* DMA Channel Ctrl Descriptor */
#define GRPCI2_DMA_CHDESC_DCNT  0                     /* 15: 0 */
#define GRPCI2_DMA_CHDESC_DCNT_MASK (0xFFFF << 0)
#define GRPCI2_DMA_CHDESC_TYPE  20                    /* 21:20 */
#define GRPCI2_DMA_CHDESC_TYPE_MASK (0x3 << 20)
#define GRPCI2_DMA_CHDESC_ID  22                      /* 24:22 */
#define GRPCI2_DMA_CHDESC_ID_MASK (0x7 << 22)
#define GRPCI2_DMA_CHDESC_EN            (1 <<  31)

/* DMA Data Ctrl Descriptor */
#define GRPCI2_DMA_DESC_LENGTH  0                   /* 15: 0 */
#define GRPCI2_DMA_DESC_LENGTH_MASK (0xFFFF << 0)
#define GRPCI2_DMA_DESC_ERR           (1 <<  19)
#define GRPCI2_DMA_DESC_TYPE  20                    /* 21:20 */
#define GRPCI2_DMA_DESC_TYPE_MASK (0x3 << 20)
#define GRPCI2_DMA_DESC_DIR           (1 <<  29)
#define GRPCI2_DMA_DESC_IRQEN         (1 <<  30)
#define GRPCI2_DMA_DESC_EN            (1 <<  31)

#define GRPCI2_DMA_DESC_DIR_PTA         (0 <<  29)
#define GRPCI2_DMA_DESC_DIR_ATP         (1 <<  29)
#define GRPCI2_DMA_DESC_TYPE_CH         (1 <<  20)
#define GRPCI2_DMA_DESC_TYPE_DATA       (0 <<  20)

#define GRPCI2_DMA_MAX_LEN 0x10000

/* ******************************************************************************* */

struct grpci2regs {
  volatile unsigned int ctrl;
  volatile unsigned int status;
  volatile unsigned int res0;
  volatile unsigned int ahb_to_pciio;
  volatile unsigned int dma_ctrl;
  volatile unsigned int dma_desc;
  volatile unsigned int dma_ch;
  volatile unsigned int dma_res;
  volatile unsigned int bar_to_ahb[6];
  volatile unsigned int res1[2];
  volatile unsigned int mst_to_pci[16];
  volatile unsigned int tb_ctrl;
  volatile unsigned int tb_cmode;
  volatile unsigned int tb_ad;
  volatile unsigned int tb_ad_mask;
  volatile unsigned int tb_sig;
  volatile unsigned int tb_sig_mask;
  volatile unsigned int tb_ad_state;
  volatile unsigned int tb_sig_state;
};

struct grpci2_ext_pci_conf_space_regs {
  volatile unsigned int id_next;
  volatile unsigned int bar_to_ahb[6];
  volatile unsigned int extpcs_to_ahb;
  volatile unsigned int ahbio_endiannes;
};

struct grpci2_head_pci_conf_space_regs {
  volatile unsigned int dev_ven_id;
  volatile unsigned int sta_cmd;
  volatile unsigned int class_rev;
  volatile unsigned int lat_timer;
  volatile unsigned int bar[6];
  volatile unsigned int res0[3];
  volatile unsigned int cap_pointer;
  volatile unsigned int res1;
  volatile unsigned int interrupt;
};
struct grpci2_pci_conf_space_regs {
  struct grpci2_head_pci_conf_space_regs *head;
  struct grpci2_ext_pci_conf_space_regs *ext;
};

struct grpci2_dma_ch_desc {
  unsigned int ctrl;
  unsigned int next;
  unsigned int desc;
  unsigned int res;
};

struct grpci2_dma_data_desc {
  unsigned int ctrl;
  unsigned int paddr;
  unsigned int aaddr;
  unsigned int next;
};

unsigned int grpci2_tw(unsigned int data);

/* GRPCI2 Set/Get AHB Master-to-PCI map ****************************************** */
  void grpci2_set_mstmap(volatile struct grpci2regs* apb, int mst, unsigned int addr);
  unsigned int grpci2_get_mstmap(volatile struct grpci2regs* apb, int mst);

/* GRPCI2 Set/Get Bus-endiannes ************************************************** */
  void grpci2_set_bus_litle_endian(volatile struct grpci2_pci_conf_space_regs* conf);
  void grpci2_set_bus_big_endian(volatile struct grpci2_pci_conf_space_regs* conf);
  int grpci2_get_endian(volatile struct grpci2_pci_conf_space_regs* conf);

/* GRPCI2 Set/Get BARMAP ********************************************************* */
  void grpci2_set_barmap(volatile struct grpci2_pci_conf_space_regs* conf, int bar, 
                      unsigned int addr);
  unsigned int grpci2_get_barmap(volatile struct grpci2_pci_conf_space_regs* conf, int bar);

/* GRPCI2 Set/Get BAR ************************************************************ */
  void grpci2_set_bar(volatile struct grpci2_pci_conf_space_regs* conf, int bar, 
                      unsigned int addr);
  unsigned int grpci2_get_bar(volatile struct grpci2_pci_conf_space_regs* conf, int bar);

/* GRPCI2 Set Latency Timer ****************************************************** */
  void grpci2_set_latency_timer(volatile struct grpci2_pci_conf_space_regs* conf, int timer);

/* GRPCI2 Master Enable/Disable ************************************************** */
  void grpci2_mst_enable(volatile struct grpci2_pci_conf_space_regs* conf);
  void grpci2_mst_disable(volatile struct grpci2_pci_conf_space_regs* conf);

/* GRPCI2 Memory target Enable/Disable ******************************************* */
  void grpci2_mem_enable(volatile struct grpci2_pci_conf_space_regs* conf);
  void grpci2_mem_disable(volatile struct grpci2_pci_conf_space_regs* conf);

/* GRPCI2 IO target Enable/Disable *********************************************** */
  void grpci2_io_enable(volatile struct grpci2_pci_conf_space_regs* conf);
  void grpci2_io_disable(volatile struct grpci2_pci_conf_space_regs* conf);

/* GRPCI2 DMA Descriptors init *************************************************** */
int grpci2_dma_desc_init(struct grpci2regs* apb, volatile unsigned int **chdesc, int irqen, 
                         int num_ch, int ch_entry);

/* GRPCI2 DMA Descriptors print ************************************************** */
  void grpci2_dma_desc_print(volatile unsigned int *chdesc);

/* GRPCI2 DMA add transfer ******************************************************* */
  int grpci2_dma_add(struct grpci2regs* apb, volatile unsigned int **ddesc, unsigned int paddr, 
                     unsigned int aaddr, int dir, int ien, int length);

/* GRPCI2 DMA check transfer ***************************************************** */
  unsigned int grpci2_dma_check(volatile unsigned int **ddesc);

