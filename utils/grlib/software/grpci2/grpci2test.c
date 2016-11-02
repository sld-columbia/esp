/* *******************************************************************************
 * GRPCI2 test 
 *
 * ******************************************************************************* */

#include <stdlib.h>
#include "grpci2api.h"
#include "grpci2extra.h"

#define APB_ADDR 0xffa00000
#define IRQMP_ADDR 0xff904000
#define PCI_CONF_ADDR 0xff810000
#define MAXTSIZE 1024*1024
#define PCI_ADDR 0x20000000
#define PCI_ADDR_MASK 0xC0000000
#define PCI_AHB_ADDR 0x80000000
#define PCI_AHB_ADDR_MASK 0xF0000000
#define TRANS_MAX_LEN 0x100000
#define MAX_Q_ENTRY 32
#define CH_ENTRY 16
#define NUM_CH 8
#define DMA_IRQ 11 

/*#define APB_ADDR 0xffa00000
#define IRQMP_ADDR 0xff904000
#define PCI_CONF_ADDR 0xff810000
#define MAXTSIZE 1024*1024
#define PCI_ADDR 0x20000000
#define PCI_ADDR_MASK 0xC0000000
#define PCI_AHB_ADDR 0x80000000
#define PCI_AHB_ADDR_MASK 0xF0000000
#define TRANS_MAX_LEN 0x19
#define MAX_Q_ENTRY 1
#define CH_ENTRY 1
#define NUM_CH 1
#define DMA_IRQ 11 */

/*#define APB_ADDR 0x80000600
#define IRQMP_ADDR 0x80000300
#define PCI_CONF_ADDR 0xfff10000
#define MAXTSIZE 1024*1024
#define PCI_ADDR 0x20000000
#define PCI_ADDR_MASK 0xC0000000
#define PCI_AHB_ADDR 0xC0000000
#define PCI_AHB_ADDR_MASK 0xF0000000
#define TRANS_MAX_LEN 0x10000
#define MAX_Q_ENTRY 1
#define CH_ENTRY 1
#define NUM_CH 8
#define DMA_IRQ 6 */

/*#define APB_ADDR 0x80000600
#define IRQMP_ADDR 0x80000300
#define PCI_CONF_ADDR 0xfff10000
#define MAXTSIZE 1024*1024
#define PCI_ADDR 0x20000000
#define PCI_ADDR_MASK 0xC0000000
#define PCI_AHB_ADDR 0xC0000000
#define PCI_AHB_ADDR_MASK 0xF0000000
#define TRANS_MAX_LEN 0x100000
#define MAX_Q_ENTRY 32
#define CH_ENTRY 16
#define NUM_CH 8
#define DMA_IRQ 6 */

#define DBG 1


  
/* ******************************************************************************* */
  

  
  static irq_cnt[8] = {0,0,0,0,0,0,0,0};

  static grpci2dma_irqhandler(int irq){
  
    struct grpci2regs *apb = (struct grpci2regs*)APB_ADDR;
    int i, tmp; 
    apb->status = 0x10000;
    tmp = apb->dma_ctrl;
    apb->dma_ctrl = tmp | GRPCI2_DMACTRL_EN;
    tmp = (tmp & GRPCI2_DMACTRL_CHIRQ_MASK) >> GRPCI2_DMACTRL_CHIRQ;
    for (i=0; i<8; i++) if ((tmp>>i)&1) irq_cnt[i]++;
  };

int main(){


  struct grpci2regs *apb;
  struct grpci2regs *slot_apb;
  struct grpci2_pci_conf_space_regs conf_host;
  struct grpci2_pci_conf_space_regs *conf[21];

  int i,j,k;
  int dir_pta = 0;
  int dir_atp = 1;
  int irq_en = 1;
  int irq_di = 0;
  int failed;

  volatile unsigned int* ahbmem;
  volatile unsigned int* pcimem;
  unsigned int ahbdata;
  int ahblen;
  int ahboffset;

  struct op_queue q;


  /* PCI core configuration ******************************************************
   *  BAR[0] = 0x20000000
   *  BAR[0] => AHB 0x00000000
   * ***************************************************************************** */
  apb = (struct grpci2regs*)APB_ADDR;
  conf[0] = (struct grpci2_pci_conf_space_regs*)&conf_host;
  conf[0]->head = (struct grpci2_head_pci_conf_space_regs*)PCI_CONF_ADDR;
  conf[0]->ext = (struct grpci2_ext_pci_conf_space_regs*)((unsigned int)conf[0]->head + 
                 (grpci2_tw(conf[0]->head->cap_pointer) & 0xff));

  grpci2_mst_enable(conf[0]);
  grpci2_mem_enable(conf[0]);
  grpci2_io_disable(conf[0]);
  grpci2_set_latency_timer(conf[0], 0x20);
  grpci2_set_bar(conf[0], 0, PCI_ADDR);
  grpci2_set_barmap(conf[0], 0, 0);
  grpci2_set_bus_big_endian(conf[0]);

  grpci2_set_mstmap(apb, 0, PCI_ADDR);

  catch_interrupt(grpci2dma_irqhandler, DMA_IRQ);
  *(unsigned int*)(IRQMP_ADDR + 0x40) = (1 << DMA_IRQ); // Unmask PCIDMA irq

  /* DMA descriptor table setup */
  grpci2_dma_desc_init(apb, &q.chbase, irq_en, NUM_CH, CH_ENTRY);
  grpci2_dma_desc_print(q.chbase); /**/

  /* setup queue */
  op_setup_queue(&q, NUM_CH, CH_ENTRY, MAX_Q_ENTRY, PCI_ADDR, PCI_ADDR_MASK);
  op_print_queue(&q, NUM_CH, MAX_Q_ENTRY);

  ahbmem = malloc(sizeof(int)*TRANS_MAX_LEN);
  pcimem = (volatile unsigned int*)(PCI_AHB_ADDR | (((int)ahbmem) &~ PCI_AHB_ADDR_MASK));
  
  failed = 0;
  while(failed == 0){
    /* Setup Q */
    while(q.opq[q.setup_qindex].pen == 0) { /* queue not full */
      q.opq[q.setup_qindex].data = rand();
      q.opq[q.setup_qindex].irqen = 1;
      q.opq[q.setup_qindex].dir = rand() % 2;
      q.opq[q.setup_qindex].ch = rand() % NUM_CH;
      q.opq[q.setup_qindex].len = (rand() % (TRANS_MAX_LEN - 1)) + 1;
      q.opq[q.setup_qindex].adata = malloc(sizeof(int)*(q.opq[q.setup_qindex].len));
      q.opq[q.setup_qindex].pdata = malloc(sizeof(int)*(q.opq[q.setup_qindex].len));
      if (DBG >= 1) printf("setup opq[%d]: %p, ch: %d dir: %d, len: %d, data: 0x%08X, pa: [%p-%p], pp: [%p-%p]\n", 
             q.setup_qindex, &q.opq[q.setup_qindex], q.opq[q.setup_qindex].ch, q.opq[q.setup_qindex].dir, 
			   q.opq[q.setup_qindex].len, q.opq[q.setup_qindex].data, q.opq[q.setup_qindex].adata, &q.opq[q.setup_qindex].adata[q.opq[q.setup_qindex].len], q.opq[q.setup_qindex].pdata, &q.opq[q.setup_qindex].pdata[q.opq[q.setup_qindex].len]);
      if (q.opq[q.setup_qindex].adata == NULL || q.opq[q.setup_qindex].pdata == NULL){
        printf("ERROR: can't allocate memory");
        exit(-1);
      };
      memset(q.opq[q.setup_qindex].adata, 0, sizeof(int)*q.opq[q.setup_qindex].len);
      memset(q.opq[q.setup_qindex].pdata, 0, sizeof(int)*q.opq[q.setup_qindex].len);

      /* debug 
      q.opq[q.setup_qindex].atail = q.opq[q.setup_qindex].adata[q.opq[q.setup_qindex].len];
      q.opq[q.setup_qindex].ptail = q.opq[q.setup_qindex].pdata[q.opq[q.setup_qindex].len]; */

      
      
      if (q.opq[q.setup_qindex].dir == dir_atp) {
        for(i=0; i<q.opq[q.setup_qindex].len; i++){
          *(q.opq[q.setup_qindex].adata + i) = q.opq[q.setup_qindex].data + i;
        };
      }else{
        for(i=0; i<q.opq[q.setup_qindex].len; i++){
          *(q.opq[q.setup_qindex].pdata + i) = q.opq[q.setup_qindex].data + i;
        };
      };
      q.opq[q.setup_qindex].pen = 3;
      /*if (DBG >= 1) printf("setup opq[%d]: %p, ch: %d dir: %d, len: %d, data: 0x%08X, pa: %p, pp: %p\n", 
             q.setup_qindex, &q.opq[q.setup_qindex], q.opq[q.setup_qindex].ch, q.opq[q.setup_qindex].dir, 
             q.opq[q.setup_qindex].len, q.opq[q.setup_qindex].data, q.opq[q.setup_qindex].adata, q.opq[q.setup_qindex].pdata);*/
      if (++q.setup_qindex == MAX_Q_ENTRY) q.setup_qindex = 0;
    };
    
    /* Add Q */
    while(q.opq[q.add_qindex].pen > 1) { /* queue pending */
      if (DBG >= 1) printf("add opq[%d]: %p, ch: %d dir: %d, len: %d, data: 0x%08X, pa: %p, pp: %p\n", 
             q.add_qindex, &q.opq[q.add_qindex], q.opq[q.add_qindex].ch, q.opq[q.add_qindex].dir, 
             q.opq[q.add_qindex].len, q.opq[q.add_qindex].data, q.opq[q.add_qindex].adata, q.opq[q.add_qindex].pdata);
      if (op_add((struct op_queue*)&q, apb, DBG) == 0) {
        q.opq[q.add_qindex].pen = 1;
        if (++q.add_qindex == MAX_Q_ENTRY) q.add_qindex = 0;
      } else {
        if (DBG >= 2) printf("All desc not added for op!\n");
        break;
      };
    };
  
    /* AHB interface test */
    ahblen = (rand() % (TRANS_MAX_LEN - 10));
    ahbdata = rand();
    ahboffset = rand() % 10;
    if (DBG >= 1) printf("ahb-int: pciahb-addr: %p, data: 0x%08X len: %d\n", (pcimem + ahboffset), ahbdata, ahblen);
    for (i=0; i<ahblen; i++){
      *(pcimem + ahboffset + i) = ahbdata + i;
    };
    for (i=0; i<ahblen; i++){
      if (*(pcimem + ahboffset + i) != (ahbdata + i)) {
        printf("AHB interface test ERROR. paddr: 0x%08X data: 0x%08X aaddr: 0x%08X data: 0x%08X\n", 
               (pcimem + ahboffset + i), *(pcimem + ahboffset + i), (ahbmem + ahboffset + i), *(ahbmem + ahboffset + i));
      };
    };
    
    /* Check Q */
    while(q.opq[q.check_qindex].pen != 0 && q.opq[q.check_qindex].pen != 3) { /* queue pending */
     if (DBG >= 1) printf("check opq[%d]: %p desc: 0x%08X pen: %d ch: %d dir: %d data: 0x%08X, pa: %p, pp: %p\n",
            q.check_qindex, &q.opq[q.check_qindex], q.opq[q.check_qindex].desc, q.opq[q.check_qindex].pen, 
            q.opq[q.check_qindex].ch, q.opq[q.check_qindex].dir, 
            q.opq[q.check_qindex].data, q.opq[q.check_qindex].adata, q.opq[q.check_qindex].pdata);

     /* debug 
     if (q.opq[q.check_qindex].atail != q.opq[q.check_qindex].adata[q.opq[q.check_qindex].len]  ||
     	   q.opq[q.check_qindex].ptail != q.opq[q.check_qindex].pdata[q.opq[q.check_qindex].len]) {
     	     printf("---- eee Error ---- 0x%x 0x%x 0x%x 0x%x\n", q.opq[q.check_qindex].atail, q.opq[q.check_qindex].adata[q.opq[q.check_qindex].len],
		              q.opq[q.check_qindex].ptail, q.opq[q.check_qindex].pdata[q.opq[q.check_qindex].len]);
     } */
    if (failed == 0) {

      if (op_check((struct op_queue*)&q, apb, DBG) == 0) {
        if (op_checkdata(q.opq[q.check_qindex].adata, q.opq[q.check_qindex].pdata, 
                         q.opq[q.check_qindex].data, q.opq[q.check_qindex].len) != 0) {
          printf("check Error\n");
          failed = 1;
          break;
        }else{
  	      /* debug
          printf("free 0x%x %x\n",q.opq[q.check_qindex].adata,q.opq[q.check_qindex].pdata); */
		
          free(q.opq[q.check_qindex].adata); 
          free(q.opq[q.check_qindex].pdata); 
          q.opq[q.check_qindex].pen = 0;
          if (++q.check_qindex == MAX_Q_ENTRY) q.check_qindex = 0;
        };
      } else {
        if (DBG >= 2) printf("All desc not ready for op!\n");
        break;
      };
    };
    };

    /* Print IRQ stat */
    printf("IRQ cnt: %d %d %d %d %d %d %d %d\n\n", irq_cnt[7], irq_cnt[6], irq_cnt[5], irq_cnt[4], 
                                                   irq_cnt[3], irq_cnt[2], irq_cnt[1], irq_cnt[0]);
  };

}
