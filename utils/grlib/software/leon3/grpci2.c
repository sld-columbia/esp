/*
  Systest for GRPCI2.
    Configure the cores:  Enable Master and Target, set latency timer to 0x40
                          BAR0 = 0x40000000 => AHB address of data[]
                          All AHB master => PCI address 0x80000000
                          PCI IO cycles => PCI address 0xC0000000
    Configure TB target:  Enable Target 
                          BAR0 = 0x80000000 - MEM BAR
                          BAR1 = 0xC0000001 - IO BAR
    Test:
      Setup data[]
      Write PCI address fot data[] to 0x80000100
      PCI MEM write/read test to 0x80000000 - 0x80000040
      PCI IO write/read test to 0xC0000000 - 0xC0000040
      Wait for TB master to replace data[] (wait for PCI address 0x80000104 reading 1)
      Check the incremental data in data[]
      done
*/

#include <stdlib.h>

static inline int loadmem(int addr)
{
  int tmp;        
  asm volatile (" lda [%1]1, %0 "
    : "=r"(tmp)
    : "r"(addr)
  );
  return tmp;
}
int grpci2_test(unsigned int base_addr, unsigned int conf_addr, unsigned int apb_addr, int slot, int reset) {
  volatile unsigned int *base   = (unsigned int *) base_addr; 
  volatile unsigned int *baseio = (unsigned int *) (conf_addr); 
  volatile unsigned int *conf   = (unsigned int *) (conf_addr + 0x10000); 
  volatile unsigned int *apb    = (unsigned int *) apb_addr; 
  int i;

  unsigned int tmp, data_addr, data_addr_al;
  unsigned int data[36], *data_al;

  unsigned int tw(unsigned int data){
    return ((data & 0xff) << 24) | (((data >> 8) & 0xff) << 16) | (((data >> 16) & 0xff) << 8) | (((data >> 24) & 0xff)); 
  }

  report_device(0x0107C000);

  data_addr = (int)data;
  data_addr_al = (data_addr+15) & (~15);
  data_al = (unsigned int *)data_addr_al;

  // PCI self configuration
  report_subtest(1);

  // Software reset
  if (reset != 0) {
    *apb = 0x80000000;
    if ((*apb & 0x80000000) == 0) fail(1);
    *apb = 0x00000000;
    if ((*apb & 0x80000000) != 0) fail(2);
  };


  report_subtest(2);
  // Enable PCI master and mem access
  *(conf+1) = tw(0x00000146);
  tmp = *(conf+1);
  *(conf+3) = tw(0x00004000);
  *(conf+0x60/4) = tw(0x00000001);

  // BAR0
  *(conf+4) = tw(0x40000000);
  if ((*(conf+4) & 0xf0ffffff) != tw(0x40000000)) fail(1);
  // BAR0 to AHB
  //*(conf+17) = tw(0x00000000);
  //if (*(conf+17) != tw(0x00000000)) fail(2);
  *(conf+17) = tw(0xffffffff);
  tmp = tw((*(conf+17) & 0xf0ffffff));
  *(conf+17) = tw(data_addr);
  if ((*(conf+17) & 0xf0ffffff) != tw((data_addr & tmp))) fail(2);

  // AHB master to PCI
  for (i=0; i<16; i++){
    *(apb+16+i) = 0x80000000;
  }
  
  // AHB => PCI IO
  *(apb+3) = 0xc0000000;
  
  // conf target
  report_subtest(3);
  *(conf+(0x800*(18+slot))/4+1) = tw(0x00000146);
  if (*(conf+(0x800*(18+slot))/4) != tw(0x2badaffe)) fail(3);
  *(conf+(0x800*(18+slot))/4+4) = tw(0x80000000);
  if (*(conf+(0x800*(18+slot))/4+4) != tw(0x80000000)) fail(4);
  *(conf+(0x800*(18+slot))/4+5) = tw(0xC0000000);
  if (*(conf+(0x800*(18+slot))/4+5) != tw(0xC0000001)) fail(5);

  // generate test data for TB master
  for (i=0;i<16;i++){
    data[i] = (((i+7)&0xf)<<28) |(((i+6)&0xf)<<24) |(((i+5)&0xf)<<20) |(((i+4)&0xf)<<16) 
             |(((i+3)&0xf)<<12) |(((i+2)&0xf)<<8)  |(((i+1)&0xf)<<4)  |(((i+0)&0xf));
  }
  *(base + 0x100/4) = tw(0x40000000 | (data_addr&(~tmp)));

  // test PCI mem-access
  report_subtest(4);
  for (i=0; i<16; i++){
    *(base+i) = ((i&0xf)<<28) |((i&0xf)<<24) |((i&0xf)<<20) |((i&0xf)<<16) 
               |((i&0xf)<<12) |((i&0xf)<<8)  |((i&0xf)<<4)  |((i&0xf));
  }

  for (i=0; i<16; i++){
    if (*(base+i) != (((i&0xf)<<28) |((i&0xf)<<24) |((i&0xf)<<20) |((i&0xf)<<16) 
                    |((i&0xf)<<12) |((i&0xf)<<8)  |((i&0xf)<<4)  |((i&0xf)))) fail(1);
  }
  
  // test PCI io-access
  report_subtest(5);
  for (i=0; i<16; i++){
    *(baseio+i) = ((i&0xf)<<28) |((i&0xf)<<24) |((i&0xf)<<20) |((i&0xf)<<16) 
                 |((i&0xf)<<12) |((i&0xf)<<8)  |((i&0xf)<<4)  |((i&0xf));
  }

  for (i=0; i<16; i++){
    if (*(baseio+i) != (((i&0xf)<<28) |((i&0xf)<<24) |((i&0xf)<<20) |((i&0xf)<<16) 
                      |((i&0xf)<<12) |((i&0xf)<<8)  |((i&0xf)<<4)  |((i&0xf)))) fail(1);
  }
 
  // wait on testbench master
  do{
    i=50;while(i!=0)i--;
    tmp = *(base + 0x104/4);
  }while (tmp != 1);

  // check data
  report_subtest(6);
  for (i=0;i<16;i++){
    //if (data[i] != i)fail(1);
    if (loadmem((int)&data[i]) != i)fail(1);
  }

  // Test DMA engine
  report_subtest(7);
  //  Control descriptor
  data_al[ 0] = 0x80100000;
  data_al[ 1] = data_addr_al;
  data_al[ 2] = data_addr_al+16;
  data_al[ 3] = 0x00000000;
  // Data descriptor 1 (AHB->PCI 2 words)
  data_al[ 4] = 0xA0000001;
  data_al[ 5] = 0x80000000;
  data_al[ 6] = data_addr_al+64;
  data_al[ 7] = data_addr_al+32;
  // Data descriptor 2 (PCI->AHB 2 words)
  data_al[ 8] = 0xC0000001;
  data_al[ 9] = 0x80000000;
  data_al[10] = data_addr_al+72;
  data_al[11] = data_addr_al+48;
  // Data descriptor 3 (disabled)
  data_al[12] = 0x00000000;
  data_al[13] = 0x00000000;
  data_al[14] = 0x00000000;
  data_al[15] = 0x00000000;
  // Data buffer
  data_al[16] = 0x19283746;
  data_al[17] = 0xF0E1D2C3;
  data_al[18] = data_al[19] = 0;
  // Start
  apb[5] = data_addr_al;
  apb[4] = 0x80000F81;
  while ((apb[4] & 0x8) != 0) { }
  if ((loadmem(data_addr_al+16) & 0x80000) != 0) fail(1);
  if ((loadmem(data_addr_al+32) & 0x80000) != 0) fail(2);
  if (loadmem(data_addr_al+72) != 0x19283746 || loadmem(data_addr_al+76) != 0xF0E1D2C3)
    fail(3);

  return 0;
}

/* From GRPCI2 API */
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

/* AHB IO base and PCI bus config register */
#define GRPCI2_ECFG_AHBIOBASE 20                      /* 31:20 */
#define GRPCI2_ECFG_AHBIOBASE_MASK (0xFFF << 20)
#define GRPCI2_ECFG_DISEN               (1 <<  1)
#define GRPCI2_ECFG_ENDIAN              (1 <<  0)

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

unsigned int grpci2_tw(unsigned int data){
  return ((data & 0xff) << 24) | (((data >> 8) & 0xff) << 16) | (((data >> 16) & 0xff) << 8) | (((data >> 24) & 0xff)); 
}

/* GRPCI2 Get Master/Target/DMA enabled ****************************************** */
  int grpci2_get_dma(volatile struct grpci2regs* apb){
    return ((apb->status & GRPCI2_STA_DMA) != 0);
  };

/* GRPCI2 Set/Get AHB Master-to-PCI map ****************************************** */
  void grpci2_set_mstmap(volatile struct grpci2regs* apb, int mst, unsigned int addr){
    apb->mst_to_pci[mst] = addr;
  };
  
  unsigned int grpci2_get_mstmap(volatile struct grpci2regs* apb, int mst){
    return apb->mst_to_pci[mst];
  };

/* GRPCI2 Set/Get Bus-endiannes ************************************************** */
  void grpci2_set_bus_litle_endian(volatile struct grpci2_pci_conf_space_regs* conf){
    conf->ext->ahbio_endiannes |= grpci2_tw(1);
  };
  
  void grpci2_set_bus_big_endian(volatile struct grpci2_pci_conf_space_regs* conf){
    conf->ext->ahbio_endiannes &= grpci2_tw(0xfffffffe);
  };

/* GRPCI2 Set/Get BARMAP ********************************************************* */
  void grpci2_set_barmap(volatile struct grpci2_pci_conf_space_regs* conf, int bar, unsigned int addr){
    conf->ext->bar_to_ahb[bar] = grpci2_tw(addr);
  };

/* GRPCI2 Set/Get BAR ************************************************************ */
  void grpci2_set_bar(volatile struct grpci2_pci_conf_space_regs* conf, int bar, unsigned int addr){
    conf->head->bar[bar] = grpci2_tw(addr);
  };
  
  unsigned int grpci2_get_bar(volatile struct grpci2_pci_conf_space_regs* conf, int bar){
    return conf->head->bar[bar];
  };

/* GRPCI2 Set Latency Timer ****************************************************** */
  void grpci2_set_latency_timer(volatile struct grpci2_pci_conf_space_regs* conf, int timer){
    conf->head->lat_timer = grpci2_tw((grpci2_tw(conf->head->lat_timer) & 0xffff00ff) | (timer & 0xff) << 8);
  };

/* GRPCI2 Master Enable/Disable ************************************************** */
  void grpci2_mst_enable(volatile struct grpci2_pci_conf_space_regs* conf){
    conf->head->sta_cmd |= grpci2_tw(0x4);
  };
  
/* GRPCI2 Memory target Enable/Disable ******************************************* */
  void grpci2_mem_enable(volatile struct grpci2_pci_conf_space_regs* conf){
    conf->head->sta_cmd |= grpci2_tw(0x2);
  };

/* GRPCI2 IO target Enable/Disable *********************************************** */
  void grpci2_io_disable(volatile struct grpci2_pci_conf_space_regs* conf){
    conf->head->sta_cmd &= ~grpci2_tw(0x1);
  };

/* GRPCI2 DMA Descriptors init *************************************************** */
  int grpci2_dma_desc_init(struct grpci2regs* apb, volatile unsigned int **chdesc, int irqen, 
                           int num_ch, int ch_entry){
    int i,j;
    struct grpci2_dma_ch_desc *ch = malloc(sizeof(struct grpci2_dma_ch_desc)*(num_ch+1));
    struct grpci2_dma_data_desc *ddesc = malloc(sizeof(struct grpci2_dma_data_desc)*(ch_entry*num_ch+1));
    /*printf("ch: %p, desc: %p\n", ch, ddesc);*/
    if (((int)ch & 0xf) != 0) ch = (struct grpci2_dma_ch_desc*)((int)ch + (0x10 - (int)ch & 0xf));
    if (((int)ddesc & 0xf) != 0) ddesc = (struct grpci2_dma_data_desc*)((int)ddesc + (0x10 - (int)ddesc & 0xf));
    /*printf("ch: %p, desc: %p\n", ch, ddesc);*/

    *chdesc = (int*)ch;
    /*printf("ch base: %08p\n", ch);*/

    for(i=0; i<num_ch; i++){
      for(j=0; j<ch_entry; j++){
        (ddesc + i*ch_entry + j)->ctrl = 0;
        (ddesc + i*ch_entry + j)->paddr = 0;
        (ddesc + i*ch_entry + j)->aaddr = 0;
        if (j == ch_entry-1) (ddesc + i*ch_entry + j)->next = (int)(ddesc + i*ch_entry);
        else (ddesc + i*ch_entry + j)->next = (int)(ddesc + i*ch_entry + j + 1);
      }
      
      (ch + i)->ctrl = GRPCI2_DMA_CHDESC_EN | 
                       ((i << GRPCI2_DMA_CHDESC_ID)& GRPCI2_DMA_CHDESC_ID_MASK) | 
                       GRPCI2_DMA_DESC_TYPE_CH;
      if (i == num_ch-1) (ch + i)->next = (int)ch;
      else (ch + i)->next = (int)(ch + i + 1);
      (ch + i)->desc = (int)(ddesc + i*ch_entry);
      (ch + i)->res = 0;

      //desc[i] = (int*)(ddesc + i*CH_ENTRY);
      //printf("datadesc[%d] base: %08p\n", i, desc[i]);
    };

    apb->dma_ctrl = GRPCI2_DMACTRL_GUARD | GRPCI2_DMACTRL_MABORT | GRPCI2_DMACTRL_TABORT | 
                    GRPCI2_DMACTRL_PERR | GRPCI2_DMACTRL_AHBDATA_ERR | GRPCI2_DMACTRL_AHBDESC_ERR |
                    (((num_ch-1) << GRPCI2_DMACTRL_NUMCH) & GRPCI2_DMACTRL_NUMCH_MASK) |
                    (irqen*GRPCI2_DMACTRL_IRQEN);
    apb->dma_desc = (int)ch;

    apb->status = GRPCI2_STA_IRQ_DMAINT | GRPCI2_STA_IRQ_DMAERR;
    
  };
/* ******************************************************************************* */

int grpci2_loopback_test(unsigned int base_addr, unsigned int conf_addr, unsigned int apb_addr, 
                         unsigned int pci_addr, int reset) {
  int i;
  struct grpci2regs *apb;
  struct grpci2_pci_conf_space_regs conf_host;
  struct grpci2_pci_conf_space_regs *conf[1];
  
  volatile unsigned int* ahbmem;
  volatile unsigned int* pcimem;
  volatile unsigned int* chbase;
  volatile struct grpci2_dma_data_desc* ddesc1;
  volatile struct grpci2_dma_data_desc* ddesc2;
  volatile struct grpci2_dma_data_desc* ddesc3;
  
  report_device(0x0107C000);
  
  /* PCI core configuration ******************************************************
   *  BAR[0] = PCI_ADDR
   *  BAR[0] => AHB AHBMEM
   * ***************************************************************************** */
  apb = (struct grpci2regs*)apb_addr;
  conf[0] = (struct grpci2_pci_conf_space_regs*)&conf_host;
  conf[0]->head = (struct grpci2_head_pci_conf_space_regs*)conf_addr;
  conf[0]->ext = (struct grpci2_ext_pci_conf_space_regs*)((unsigned int)conf[0]->head + 
                 (grpci2_tw(conf[0]->head->cap_pointer) & 0xff));

  // Software reset
  report_subtest(7);
  if (reset != 0) {
    apb->ctrl = GRPCI2_CTRL_RST;
    if ((apb->ctrl & GRPCI2_CTRL_RST) == 0) fail(1);
    apb->ctrl = 0x00000000;
    if ((apb->ctrl & GRPCI2_CTRL_RST) != 0) fail(2);
  };

  /* Get BASE_ADDR_MASK */
  grpci2_set_mstmap(apb, 0, 0xffffffff);
  unsigned int base_addr_mask = grpci2_get_mstmap(apb, 0);
  grpci2_set_bar(conf[0], 0, 0xffffffff);
  unsigned int pci_addr_mask = grpci2_tw(grpci2_get_bar(conf[0], 0));

  ahbmem = malloc(sizeof(int)*128);
  pcimem = (volatile unsigned int*)((base_addr & base_addr_mask) | (((pci_addr & pci_addr_mask) | ((unsigned int)(ahbmem) &~ pci_addr_mask)) &~ base_addr_mask));
  
  grpci2_mst_enable(conf[0]);
  grpci2_mem_enable(conf[0]);
  grpci2_io_disable(conf[0]);
  grpci2_set_latency_timer(conf[0], 0x20);
  grpci2_set_bar(conf[0], 0, pci_addr);
  grpci2_set_barmap(conf[0], 0, ((unsigned int)ahbmem) & 0xfffffff0);
  grpci2_set_bus_big_endian(conf[0]);

  grpci2_set_mstmap(apb, 0, pci_addr);
  /* PCI-AHB loopback test */
  
  report_subtest(8);
  /* Clear memory */
  for (i=0; i<32; i++){
    *(ahbmem + i) = 0;
  };

  /* Write to memory via PCI*/
  for (i=0; i<32; i++){
    *(pcimem + i) = i;
  };
  
  /* Check memory */
  for (i=0; i<32; i++){
    if (loadmem((unsigned int)(ahbmem + i)) != i) fail(1);
  };
  
  /* Write to memory*/
  for (i=0; i<32; i++){
    *(ahbmem + i) = 31-i;
  };
  
  /* Check memory via PCI*/
  for (i=0; i<32; i++){
    if (loadmem((unsigned int)(pcimem + i)) != 31-i) fail(2);
  };
  
  /* Change PCI bus endianess */
  grpci2_set_bus_litle_endian(conf[0]);

  /* Check memory via PCI*/
  for (i=0; i<32; i++){
    if (loadmem((unsigned int)(pcimem + i)) != 31-i) fail(3);
  };
  
  /* Change PCI bus endianess */
  grpci2_set_bus_big_endian(conf[0]);

  if (grpci2_get_dma(apb)){
  
    /* PCI-DMA loopback test */
    report_subtest(9);

    for (i=0; i<32; i++){
      *(ahbmem + i) = i;
    }
    
    for (i=32; i<128; i++){
      *(ahbmem + i) = 0xafafafaf;
    }

    /* DMA descriptor table setup */
    grpci2_dma_desc_init(apb, &chbase, 0, 2, 2);
    
    ddesc1 = (struct grpci2_dma_data_desc*)*(chbase + 2);
    ddesc2 = (struct grpci2_dma_data_desc*)*(chbase + 6);
    ddesc3 = (struct grpci2_dma_data_desc*)ddesc2->next;

    /* Setup AHB to PCI transfer 32 words */
    ddesc1->paddr = (pci_addr & pci_addr_mask) | ((unsigned int)(ahbmem + 32) &~ pci_addr_mask);
    ddesc1->aaddr = (unsigned int)ahbmem;
    ddesc1->ctrl = GRPCI2_DMA_DESC_EN | GRPCI2_DMA_DESC_IRQEN*0 | GRPCI2_DMA_DESC_DIR*1 |
                   GRPCI2_DMA_DESC_TYPE_DATA | 
                   (31 & GRPCI2_DMA_DESC_LENGTH_MASK) << GRPCI2_DMA_DESC_LENGTH;

    /* Setup PCI to AHB transfer 16 words */
    ddesc2->paddr = (pci_addr & pci_addr_mask) | ((unsigned int)(ahbmem + 32) &~ pci_addr_mask);
    ddesc2->aaddr = (unsigned int)(ahbmem + 64);
    ddesc2->ctrl = GRPCI2_DMA_DESC_EN | GRPCI2_DMA_DESC_IRQEN*0 | GRPCI2_DMA_DESC_DIR*0 |
                   GRPCI2_DMA_DESC_TYPE_DATA | 
                   (15 & GRPCI2_DMA_DESC_LENGTH_MASK) << GRPCI2_DMA_DESC_LENGTH;
    
    /* Setup AHB to PCI transfer 1 word */
    ddesc3->paddr = (pci_addr & pci_addr_mask) | ((unsigned int)(ahbmem + 96) &~ pci_addr_mask);
    ddesc3->aaddr = (unsigned int)(ahbmem + 64);
    ddesc3->ctrl = GRPCI2_DMA_DESC_EN | GRPCI2_DMA_DESC_IRQEN*0 | GRPCI2_DMA_DESC_DIR*1 |
                   GRPCI2_DMA_DESC_TYPE_DATA | 
                   (0 & GRPCI2_DMA_DESC_LENGTH_MASK) << GRPCI2_DMA_DESC_LENGTH;

    /* Start DMA*/
    apb->dma_ctrl = GRPCI2_DMACTRL_EN;

    /* Wait on desc1 done*/
    while((loadmem((unsigned int)&ddesc1->ctrl) & GRPCI2_DMA_DESC_EN) != 0);
    for (i=0; i<32; i++){
      if (loadmem((unsigned int)(ahbmem + 32 + i)) != i) fail(1);
    };
    
    /* Wait on desc2 done*/
    while((loadmem((unsigned int)&ddesc2->ctrl) & GRPCI2_DMA_DESC_EN) != 0);
    for (i=0; i<16; i++){
      if (loadmem((unsigned int)(ahbmem + 64 + i)) != i) fail(2);
    };
    
    /* Wait on desc3 done*/
    while((loadmem((unsigned int)&ddesc3->ctrl) & GRPCI2_DMA_DESC_EN) != 0);
    for (i=0; i<1; i++){
      if (loadmem((unsigned int)(ahbmem + 96 + i)) != i) fail(3);
    };

  };
};

