#include "grpci2api.h"

static inline int loadmem(int addr){
  int tmp;        
  asm volatile (" lda [%1]1, %0 "
    : "=r"(tmp)
    : "r"(addr)
  );
  return tmp;
};
  
unsigned int grpci2_tw(unsigned int data){
  return ((data & 0xff) << 24) | (((data >> 8) & 0xff) << 16) | (((data >> 16) & 0xff) << 8) | (((data >> 24) & 0xff)); 
}

/* GRPCI2 Get Master/Target/DMA enabled ****************************************** */
  int grpci2_get_master(volatile struct grpci2regs* apb){
    return ((apb->status & GRPCI2_STA_MASTER) != 0);
  };

  int grpci2_get_target(volatile struct grpci2regs* apb){
    return ((apb->status & GRPCI2_STA_TARGET) != 0);
  };

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
  
  int grpci2_get_endian(volatile struct grpci2_pci_conf_space_regs* conf){
    return (grpci2_tw(conf->ext->ahbio_endiannes) & 1);
  };

/* GRPCI2 Set/Get BARMAP ********************************************************* */
  void grpci2_set_barmap(volatile struct grpci2_pci_conf_space_regs* conf, int bar, unsigned int addr){
    conf->ext->bar_to_ahb[bar] = grpci2_tw(addr);
  };
  
  unsigned int grpci2_get_barmap(volatile struct grpci2_pci_conf_space_regs* conf, int bar){
    return conf->ext->bar_to_ahb[bar];
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
  
  void grpci2_mst_disable(volatile struct grpci2_pci_conf_space_regs* conf){
    conf->head->sta_cmd &= ~grpci2_tw(0x4);
  };
  
/* GRPCI2 Memory target Enable/Disable ******************************************* */
  void grpci2_mem_enable(volatile struct grpci2_pci_conf_space_regs* conf){
    conf->head->sta_cmd |= grpci2_tw(0x2);
  };
  
  void grpci2_mem_disable(volatile struct grpci2_pci_conf_space_regs* conf){
    conf->head->sta_cmd &= ~grpci2_tw(0x2);
  };
  
/* GRPCI2 IO target Enable/Disable *********************************************** */
  void grpci2_io_enable(volatile struct grpci2_pci_conf_space_regs* conf){
    conf->head->sta_cmd |= grpci2_tw(0x1);
  };
  
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

/* GRPCI2 DMA add transfer ******************************************************* */
  int grpci2_dma_add(struct grpci2regs* apb, volatile unsigned int **ddesc, unsigned int paddr, 
                     unsigned int aaddr, int dir, int ien, int length){
    struct grpci2_dma_data_desc *desc = (struct grpci2_dma_data_desc*)*ddesc;
    unsigned int tmp = loadmem((int)desc); 
        
    /*printf("desc: %08X, ctrl: %08X, paddr: %08X, aaddr: %08X, next: %08X\n", 
           (desc), (desc)->ctrl, (desc)->paddr, (desc)->aaddr, (desc)->next); /**/
  
    //if ((desc->ctrl & GRPCI2_DMA_DESC_EN) == 0){
    //printf("desc-ctrl: 0x%08X 0x%08X\n", tmp, desc->ctrl);
    if ((tmp & GRPCI2_DMA_DESC_EN) == 0){
      desc->paddr = paddr;
      desc->aaddr = aaddr;
      desc->ctrl = GRPCI2_DMA_DESC_EN | GRPCI2_DMA_DESC_IRQEN*ien | GRPCI2_DMA_DESC_DIR*dir |
                   GRPCI2_DMA_DESC_TYPE_DATA | 
                   (length & GRPCI2_DMA_DESC_LENGTH_MASK) << GRPCI2_DMA_DESC_LENGTH;
      *ddesc = (int*)desc->next;
      apb->dma_ctrl = (apb->dma_ctrl & GRPCI2_DMACTRL_NUMCH_MASK) | 
                      (apb->dma_ctrl & GRPCI2_DMACTRL_IRQEN) | GRPCI2_DMACTRL_EN;
    
    /*printf("desc: %08X, ctrl: %08X, paddr: %08X, aaddr: %08X, next: %08X\n", 
           (desc), (desc)->ctrl, (desc)->paddr, (desc)->aaddr, (desc)->next); /**/
      return 0;
    }else{
      return -1;
    };

  };
/* ******************************************************************************* */

/* GRPCI2 DMA check transfer ******************************************************* */
  unsigned int grpci2_dma_check(volatile unsigned int **ddesc){
    struct grpci2_dma_data_desc *desc = (struct grpci2_dma_data_desc*)*ddesc;
    unsigned int res;

    res = loadmem((int)desc);
    
    if (!(res & GRPCI2_DMA_DESC_EN)) {
      *ddesc = (int*)desc->next;
    };
    return res;
  };

