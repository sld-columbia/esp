#include "prc_utils.h"
#include "soc_defs.h"
#include "soc_locs.h"
#include "monitors.h"
#include <pbs_map.h>
#include <prc_aux.h>

#ifdef __riscv
#define APB_BASE_ADDR 0x60000000
#endif

//#define MEASURE_RECONF_TIME
static struct esp_device esp_tile_decoupler;
static struct esp_device esp_prc;
struct pbs_map *pb_map;
    
const unsigned monitor_base = 0x90180;

static void get_io_tile_id(struct esp_device* io_tile)
{
    unsigned int tile_id;

    tile_id = io_loc.row * SOC_COLS + io_loc.col;
    io_tile->addr = (long long unsigned) APB_BASE_ADDR + (monitor_base + tile_id * 0x200);
#ifdef DPR_VERBOSE   
    printf("[PRC DRIVER]: io_tile id -- %u, io_tile addr -- 0x%0x \n", tile_id, (unsigned) io_tile->addr); 
#endif
}

static int get_decoupler_addr(struct esp_device *dev, struct esp_device *decoupler)
{
    unsigned i;
    unsigned tile_id = 0xFF;
    unsigned dev_addr;
    unsigned dev_addr_trunc;   
    unsigned dev_start_addr = 0x10000;

    const unsigned addr_incr = 0x100;

    dev_addr = (unsigned) dev->addr;
    dev_addr_trunc = (dev_addr << 12) >> 12;
#ifdef DPR_VERBOSE       
    printf("[PRC DRIVER]: device address -- 0x%0x, truncated addr -- 0x%0x \n", dev_addr, dev_addr_trunc);
#endif
//#ifdef ACCS_PRESENT

    //Obtain tile id
    for (i = 0; i < SOC_NACC; i++) {
        if(dev_start_addr == dev_addr_trunc) {
            tile_id = acc_locs[i].row * SOC_COLS + acc_locs[i].col;
            break;
        }
         else
            dev_start_addr += addr_incr;
    }

    if(tile_id == 0XFF) {
        printf("Error: cannot find tile id\n");
        return -1;
        //exit(EXIT_FAILURE);
    }

    //compute apb address for tile decoupler
    (*decoupler).addr = APB_BASE_ADDR + (monitor_base + tile_id * 0x200);
#ifdef DPR_VERBOSE   
    printf("[PRC DRIVER]: tile_id -- 0x%0x, decoupler addr is -- 0x%0x \n", tile_id, (unsigned) esp_tile_decoupler.addr);
#endif
    return 0;
}

int decouple_acc(struct esp_device *dev, unsigned val)
{
    get_decoupler_addr(dev, &esp_tile_decoupler);
    
    if (val == 0)
        iowrite32(&esp_tile_decoupler, DECOUPLER_REG, 0);
    else 
        iowrite32(&esp_tile_decoupler, DECOUPLER_REG, BIT(0));
    
    return 0;
}

static void init_prc()
{   
    //TODO: replace this with probe
    esp_prc.addr = (long long unsigned) APB_BASE_ADDR + 0xE400;
    
    pb_map = (struct pbs_map *) &bs_descriptor;    
#ifdef DPR_VERBOSE   
    printf("[PRC DRIVER]: bitstream size -- 0x%0x, bitstream addr -- 0x%08x \n", pb_map->pbs_size, (unsigned) pb_map->pbs_addr);
#endif
}

static int shutdown_prc()
{
    int prc_status;
#ifdef DPR_VERBOSE
    printf("[PRC DRIVER]: Shutting down PRC\n");
#endif
    iowrite32(&esp_prc, 0x0, 0x0);

    prc_status = ioread32(&esp_prc, 0x0);
#ifdef DPR_VERBOSE   
    printf("[PRC DRIVER]: PRC status -- 0x%0x \n", prc_status);
#endif
    prc_status &= (1<<7);
    if (!prc_status) {
#ifdef DPR_VERBOSE   
        printf("[PRC DRIVER]: error shutting controller \n");
#endif
        return 1;    
    }

    return 0;
}

static int start_prc()
{
    int prc_status;
#ifdef DPR_VERBOSE   
    printf("[PRC DRIVER]: Restarting PRC\n");
#endif
    iowrite32(&esp_prc, 0x0, 0x1);

    prc_status = ioread32(&esp_prc, 0x0);
    prc_status &= (1<<7);
    if (prc_status) {
#ifdef DPR_VERBOSE   
         printf("[PRC DRIVER]: error starting controller \n");
#endif
        return 1;    
    }

    return 0;
}

//TODO: trigger registers need to be modified for Ultrascale devices
static void set_trigger(unsigned pbs_id)
{
    if (!shutdown_prc()) {
        iowrite32(&esp_prc, 0x60, 0x0);
        iowrite32(&esp_prc, 0x64, PBS_BASE_ADDR + pb_map[pbs_id].pbs_addr);
        iowrite32(&esp_prc, 0x68, pb_map[pbs_id].pbs_size);
#ifdef DPR_VERBOSE   
        printf("[PRC DRIVER]: Trigger armed \n");    
#endif
    }
    else
        printf("[PRC DRIVER]: Error arming trigger \n");
#ifdef DPR_VERBOSE   
    printf("[PRC DRIVER]: PBS addr -- 0x%08x \n", (unsigned) pb_map[pbs_id].pbs_addr);
    printf("[PRC DRIVER]: PBS size -- 0x%08x \n", pb_map[pbs_id].pbs_size);
#endif   
}

unsigned int reconfigure_FPGA(struct esp_device *dev, unsigned pbs_id)
{
    unsigned prc_done = 0;

#ifdef MEASURE_RECONF_TIME
    //esp monitor for measuring time
    esp_monitor_args_t mon_args;
    const int CPU_TILE_IDX = 1;
    mon_args.read_mode = ESP_MON_READ_SINGLE;
    mon_args.tile_index = CPU_TILE_IDX;
    mon_args.mon_index = MON_DVFS_BASE_INDEX + 3;
    unsigned int cycles_start, cycles_end, cycles_diff;
#endif

    struct esp_device io_tile_csr;
    //io_tile_csr.addr = (long long unsigned) APB_BASE_ADDR + 0x90980;
    get_io_tile_id(&io_tile_csr);
    
    init_prc();
    
    //send a Proceed cmd to PRC to reset pending interrupt 
    prc_done = ioread32(&io_tile_csr, PRC_INTERRUPT_REG);
#ifdef DPR_VERBOSE   
    printf("[PRC DRIVER]: prc done -- %u \n", prc_done);
#endif
    if (prc_done == 1)
        iowrite32(&esp_prc, 0x0, 0x3);
    

    //set bitstream trigger
    set_trigger(pbs_id);
    
    if (!(start_prc())) {
        decouple_acc(dev, 1); //decouple tile
        printf("[PRC DRIVER]: Starting Reconfiguration \n");
        iowrite32(&esp_prc, 0x4, 0); //send reconfig trigger
   }

    else {
        printf("[PRC DRIVER]: Error reconfiguring FPGA \n");
        return -1;;
    }
#ifdef MEASURE_RECONF_TIME
    cycles_start = esp_monitor(mon_args, NULL);
#endif

    while (prc_done == 0) {
        prc_done = ioread32(&io_tile_csr, PRC_INTERRUPT_REG);
    }

#ifdef MEASURE_RECONF_TIME
    cycles_end = esp_monitor(mon_args, NULL);
    cycles_diff = sub_monitor_vals(cycles_start, cycles_end);
    printf("[PRC DRIVER]: time is %u %u %u \n", cycles_start, cycles_end, cycles_diff);
#endif

    //send a Proceed cmd to PRC 
    iowrite32(&esp_prc, 0x0, 0x3);
    
    //remove decoupling
    decouple_acc(dev, 0); //decouple tile

    printf("[PRC DRIVER]: Reconfigured FPGA \n \n \n");
    
    return 0;
}
