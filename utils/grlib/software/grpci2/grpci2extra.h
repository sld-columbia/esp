#define MAX_NUM_CH 8
#define MAX_MAX_Q_ENTRY 128

  struct dma_ch_ctrl {
    volatile struct grpci2_dma_ch_desc* chbase;
    volatile unsigned int* add;
    volatile unsigned int* check;
    int empty;
    int pending;
  };

  struct op_queue_entry {
    int pen;
    unsigned int* desc;
    int num_desc;
    unsigned int* pdata;
    unsigned int* adata;
    unsigned int data;
    int len;
    int dir;
    int irqen;
    int ch;
    unsigned int sub_paddr;
    unsigned int sub_aaddr;
    int sub_len;
    int sub_num_desc;
	  unsigned int ptail, atail;
  };

  struct op_queue {
    volatile unsigned int* chbase;
    unsigned int pciaddr;
    unsigned int pcimask;
    struct dma_ch_ctrl ch[MAX_NUM_CH];
    int check_qindex;
    int add_qindex;
    int setup_qindex;
    volatile struct op_queue_entry opq[MAX_MAX_Q_ENTRY];
  };
  
  int op_setup_queue(struct op_queue *q, int num_ch, int ch_entry, int max_q_entry, unsigned int pci_addr, unsigned int pci_mask);
  void op_print_queue(struct op_queue *q, int num_ch, int max_q_entry);
  int op_add(struct op_queue *q, struct grpci2regs* apb, int dbg);
  int op_check(struct op_queue *q, struct grpci2regs* apb, int dbg);
  int op_checkdata(volatile unsigned int* p1, volatile unsigned int*p2, unsigned int data, int length);




