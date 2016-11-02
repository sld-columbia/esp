#include "grpci2api.h"
#include "grpci2extra.h"

/* GRPCI2 DMA Descriptors print ************************************************** */
  void grpci2_dma_desc_print(volatile unsigned int *chdesc){
    int i,j;
    struct grpci2_dma_ch_desc *ch = (struct grpci2_dma_ch_desc*)chdesc;
    struct grpci2_dma_data_desc *desc;
    struct grpci2_dma_data_desc *desc_ref;

    i = 0;
    do{
      printf("ch[%d]: 0x%08X, ctrl: 0x%08X, next: 0x%08X, desc: 0x%08X\n", 
             i, (ch + i), (ch + i)->ctrl, (ch + i)->next, (ch + i)->desc);
      j = 0;
      desc = (struct grpci2_dma_data_desc*)(ch + i)->desc;
      desc_ref = desc;
      do{
        printf("\tdesc[%d]: %08X, ctrl: %08X, paddr: %08X, aaddr: %08X, next: %08X\n", 
               j, (desc), (desc)->ctrl, (desc)->paddr, (desc)->aaddr, (desc)->next);
        desc = (struct grpci2_dma_data_desc*)desc->next;
        j++;
      }while( desc != desc_ref);
    }while( (ch + i++)->next != (int)ch);
  };
/* ******************************************************************************* */

/* GRPCI2 DMA Queue ************************************************************** */
  int op_setup_queue(struct op_queue *q, int num_ch, int ch_entry, int max_q_entry, 
                     unsigned int pci_addr, unsigned int pci_mask) {
    int i;

    q->setup_qindex = 0;
    q->add_qindex = 0;
    q->check_qindex = 0;
    q->pciaddr = pci_addr;
    q->pcimask = pci_mask;

    for (i=0; i<num_ch; i++){
      q->ch[i].chbase = ((struct grpci2_dma_ch_desc*)(q->chbase) + i);
      q->ch[i].add = (unsigned int*)q->ch[i].chbase->desc;
      q->ch[i].check = (unsigned int*)q->ch[i].chbase->desc;
      q->ch[i].empty = ch_entry;
      q->ch[i].pending = 0;
    };

    for (i=0; i<max_q_entry; i++){
      q->opq[i].pen = 0;
      q->opq[i].desc = 0;
      q->opq[i].num_desc = 0;
      q->opq[i].pdata = 0;
      q->opq[i].adata = 0;
      q->opq[i].data = 0;
      q->opq[i].len = 0;
      q->opq[i].dir = 0;
      q->opq[i].irqen = 0;
      q->opq[i].ch = 0;
      q->opq[i].sub_paddr = 0;
      q->opq[i].sub_aaddr = 0;
      q->opq[i].sub_len = 0;
      q->opq[i].sub_num_desc = 0;
    };
  };
  void op_print_queue(struct op_queue *q, int num_ch, int max_q_entry) {
    int i;

    for (i=0; i<num_ch; i++){
      printf("DMA CH[%d]: base: 0x%08X add: 0x%08X check: 0x%08X empty: %d pen: %d\n",
             i, q->ch[i].chbase, q->ch[i].add, q->ch[i].check, q->ch[i].empty, q->ch[i].pending);
    };

    printf("OPQ: setup_qindex: %d add_qindex: %d check_qindex: %d\n",    
           q->setup_qindex, q->add_qindex, q->check_qindex);
    for (i=0; i<max_q_entry; i++){
      printf("OPQ[%d]: pen: %d len: %d dir %d irq: %d ch: %d data: 0x%08X\n", 
             i, q->opq[i].pen, q->opq[i].len, q->opq[i].dir, q->opq[i].irqen, q->opq[i].ch, q->opq[i].data);
      printf("        pdata: 0x%08X adata: 0x%08X desc: 0x%08X num_desc: %d sub_num_desc %d\n",    
             q->opq[i].pdata, q->opq[i].adata, q->opq[i].desc, q->opq[i].num_desc, q->opq[i].sub_num_desc);
    };
    
  };
  
  int op_add(struct op_queue *q, struct grpci2regs* apb, int dbg){
    int failed;
    
    if (q->opq[q->add_qindex].pen == 3) { 
      q->opq[q->add_qindex].desc = (int*)q->ch[q->opq[q->add_qindex].ch].add;
      q->opq[q->add_qindex].num_desc = (q->opq[q->add_qindex].len-1) / GRPCI2_DMA_MAX_LEN + 1;
      q->opq[q->add_qindex].sub_num_desc = q->opq[q->add_qindex].num_desc;
      
      q->opq[q->add_qindex].sub_paddr = q->pciaddr | (((int)q->opq[q->add_qindex].pdata) &~ q->pcimask);
      q->opq[q->add_qindex].sub_aaddr = (int)q->opq[q->add_qindex].adata;
      q->opq[q->add_qindex].sub_len = q->opq[q->add_qindex].len;
    };

    do {

      if (q->ch[q->opq[q->add_qindex].ch].empty > 0) {
        if (dbg >= 2) printf("  add: paddr: 0x%08X, aaddr: 0x%08X, len: %d emp: %d pen: %d\n", 
               q->opq[q->add_qindex].sub_paddr, q->opq[q->add_qindex].sub_aaddr, 
               (q->opq[q->add_qindex].sub_len > GRPCI2_DMA_MAX_LEN) ? GRPCI2_DMA_MAX_LEN : q->opq[q->add_qindex].sub_len,
               q->ch[q->opq[q->add_qindex].ch].empty, q->ch[q->opq[q->add_qindex].ch].pending);
        if (q->opq[q->add_qindex].sub_len > GRPCI2_DMA_MAX_LEN) {
          failed = grpci2_dma_add(apb, &q->ch[q->opq[q->add_qindex].ch].add, 
                                  q->opq[q->add_qindex].sub_paddr, q->opq[q->add_qindex].sub_aaddr, 
                                  q->opq[q->add_qindex].dir, 0, GRPCI2_DMA_MAX_LEN-1);
        } else {
          failed = grpci2_dma_add(apb, &q->ch[q->opq[q->add_qindex].ch].add, 
                                  q->opq[q->add_qindex].sub_paddr, q->opq[q->add_qindex].sub_aaddr, 
                                  q->opq[q->add_qindex].dir, q->opq[q->add_qindex].irqen, q->opq[q->add_qindex].sub_len-1);
        };
        if (failed == 0) {
          q->ch[q->opq[q->add_qindex].ch].empty--;
          q->ch[q->opq[q->add_qindex].ch].pending++;
          q->opq[q->add_qindex].sub_len = q->opq[q->add_qindex].sub_len - GRPCI2_DMA_MAX_LEN;
          q->opq[q->add_qindex].sub_paddr = q->opq[q->add_qindex].sub_paddr + 4*GRPCI2_DMA_MAX_LEN;
          q->opq[q->add_qindex].sub_aaddr = q->opq[q->add_qindex].sub_aaddr + 4*GRPCI2_DMA_MAX_LEN;
        };
      } else {
        failed = -1;
      };
    }while(q->opq[q->add_qindex].sub_len > 0 && failed == 0);
      
    if (q->opq[q->add_qindex].sub_len <= 0) {
      q->opq[q->add_qindex].pen = 1;
    } else {
      q->opq[q->add_qindex].pen = 2;
    };
    
    return (q->opq[q->add_qindex].pen != 1);
  };

  int op_check(struct op_queue *q, struct grpci2regs* apb, int dbg){
    int failed, done;
    unsigned int tmp;
   
    failed = 0; done = 0;

    if (q->opq[q->check_qindex].pen != 0) {
      do {
        if (q->ch[q->opq[q->check_qindex].ch].pending > 0) {
          tmp = grpci2_dma_check(&q->ch[q->opq[q->check_qindex].ch].check);
          if (!(tmp & GRPCI2_DMA_DESC_EN)) {
            q->opq[q->check_qindex].sub_num_desc--;
            q->ch[q->opq[q->check_qindex].ch].empty++;
            q->ch[q->opq[q->check_qindex].ch].pending--;
            if (q->opq[q->check_qindex].sub_num_desc == 0) {
              done = 1;
            };
          };
        } else {
          failed = 1;
        };
        if (dbg >= 2) printf("  check OPQ[%d]: sub_num_desc: %d failed: %d done: %d emp: %d pen: %d\n", q->check_qindex, 
            q->opq[q->check_qindex].sub_num_desc, failed, done, 
            q->ch[q->opq[q->check_qindex].ch].empty, q->ch[q->opq[q->check_qindex].ch].pending);
      }while (failed == 0 && done == 0);
    };

    return (done != 1);
  };

   int op_checkdata(volatile unsigned int* p1, volatile unsigned int*p2, unsigned int data, int length){
     int i, res;
     res = 0;
     for (i=0; i<length; i++){
       if ((*(p1+i) != *(p2+i)) || (*(p1+i) != data + i) || (*(p2+i) != data + i)) {
         res = (int)(p1+i);
         printf("Error: p1[%p]: 0x%08X  != p2[%p]: 0x%08X\n", (p1+i), *(p1+i), (p2+i), *(p2+i));
         break;
       };
     };
     return res;
   }
