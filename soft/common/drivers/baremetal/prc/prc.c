#include "prc_utils.h"
#include "soc_defs.h"
#include "soc_locs.h"
#include <pbs_map.h>
#include <prc_aux.h>

#ifdef __riscv
#define APB_BASE_ADDR 0x60000000
#endif
static struct esp_device esp_tile_decoupler;
static struct esp_device esp_prc;
struct pbs_map *pb_map;
    
const unsigned monitor_base = 0x90180;

static void get_io_tile_id(struct esp_device* io_tile)
{
    unsigned int tile_id;

    tile_id = io_loc.row * SOC_COLS + io_loc.col;
    io_tile->addr = (long long unsigned) APB_BASE_ADDR + (monitor_base + tile_id * 0x200);
    //printf("io tile id is %u  io_tile addr is %0x \n", tile_id, (unsigned) io_tile->addr); 
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
    
    //printf("device address %0x truncated addr %0x \n", dev_addr, dev_addr_trunc);
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
    //printf("tile_id is %0x decoupler addr is %0x \n", tile_id, (unsigned) esp_tile_decoupler.addr);
    return 0;
}

int decouple_acc(struct esp_device *dev, unsigned val)
{
    get_decoupler_addr(dev, &esp_tile_decoupler);
    
    if (val == 0)
        iowrite32(&esp_tile_decoupler, 0, 0);
    else 
        iowrite32(&esp_tile_decoupler, 0, BIT(0));
    
    return 0;
}

static void init_prc()
{   
    //TODO: replace this with probe
    esp_prc.addr = (long long unsigned) APB_BASE_ADDR + 0xE400;
    
    pb_map = (struct pbs_map *) &bs_descriptor;    
    //printf("bitstream addr %0x %08x \n", pb_map->pbs_size, (unsigned) pb_map->pbs_addr);
}

static int shutdown_prc()
{
    int prc_status;

    printf("PRC: Shutting down PRC\n");
    iowrite32(&esp_prc, 0x0, 0x0);

    prc_status = ioread32(&esp_prc, 0x0);
    printf("PRC status: %0x \n", prc_status);
    prc_status &= (1<<7);
    if (!prc_status) {
        printf("PRC: error shutting controller \n");
        return 1;    
    }

    return 0;
}

static int start_prc()
{
    int prc_status;

    printf("PRC: restarting PRC\n");
    iowrite32(&esp_prc, 0x0, 0x1);

    prc_status = ioread32(&esp_prc, 0x0);
    prc_status &= (1<<7);
    if (prc_status) {
        printf("PRC: error starting controller \n");
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
        printf("PRC: Trigger armed \n");    
    }
    else
        printf("PRC: Error arming trigger \n");
   
    //printf("PBS address local %08x remote %08x \n", (unsigned) pb_map[pbs_id].pbs_addr, ioread32(&esp_prc, 0x64));
    //printf("PBS size local %08x  remote %08x \n", pb_map[pbs_id].pbs_size, ioread32(&esp_prc, 0x68));
}

void reconfigure_FPGA(struct esp_device *dev, unsigned pbs_id)
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

    struct esp_device io_tile;
    //io_tile.addr = (long long unsigned) APB_BASE_ADDR + 0x90980;
    get_io_tile_id(&io_tile);
    
    init_prc();    
    
    //send a Proceed cmd to PRC to reset pending interrupt 
    prc_done = ioread32(&io_tile, 0);
    if (prc_done == 1)
        iowrite32(&esp_prc, 0x0, 0x3);

    //set bitstream trigger
    set_trigger(pbs_id);
    
    if (!(start_prc())) {
        decouple_acc(dev, 1); //decouple tile
        printf("PRC: Starting Reconfiguration \n");
        iowrite32(&esp_prc, 0x4, 0); //send reconfig trigger
   }

    else {
        printf("PRC: Error reconfiguring FPGA \n");
        //return -1;;
    }
#ifdef MEASURE_RECONF_TIME
    cycles_start = esp_monitor(mon_args, NULL);
#endif

    while (prc_done == 0) {
        prc_done = ioread32(&io_tile, 0);
    }

#ifdef MEASURE_RECONF_TIME
    cycles_end = esp_monitor(mon_args, NULL);
    cycles_diff = sub_monitor_vals(cycles_start, cycles_end);
    printf("time is %u %u %u \n", cycles_start, cycles_end, cycles_diff);
#endif

    //send a Proceed cmd to PRC 
    iowrite32(&esp_prc, 0x0, 0x3);

    printf("PRC: Reconfigured FPGA \n \n \n");
}
