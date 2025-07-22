#include "prc_utils.h"
#include "soc_defs.h"
//#include "soc_locs.h"
#include <monitors.h>
#include <pbs_map.h>
#include <prc_aux.h>
#include <esplink.h>

#ifdef __riscv
#define APB_BASE_ADDR 0x60000000
#endif

#define DPR_VERBOSE
#define DPR_MEASURE_RECONF_TIME

struct esp_device esp_tile_decoupler;
struct esp_device esp_prc;
struct esp_device io_tile_csr;
struct pbs_map *pb_map;

const unsigned monitor_base = 0x90180;

#ifdef DPR_MEASURE_RECONF_TIME
// esp monitor for measuring time
const int CPU_TILE_IDX = 1;
esp_monitor_args_t __prc__mon_args = {ESP_MON_READ_SINGLE, 0xffff, 1, 0, MON_DVFS_BASE_INDEX + 3, 0};
unsigned int __prc__cycles_start, __prc__cycles_end, __prc__cycles_diff;
#endif

static void get_io_tile_id(struct esp_device* io_tile)
{
    unsigned int tile_id;

    tile_id = io_loc.row * SOC_COLS + io_loc.col;
    io_tile->addr = (long long unsigned) APB_BASE_ADDR + (monitor_base + tile_id * 0x200);
#ifdef DPR_VERBOSE
    printf("[PRC DRIVER]: io_tile id -- %u, io_tile addr -- 0x%0x \n", tile_id, (unsigned) io_tile->addr);
#endif
}

int decouple_acc(struct esp_device *dev, unsigned val, unsigned is_router_dev)
{
    // get address of router
    if (is_router_dev) {
        esp_tile_decoupler.addr = dev->addr;
    }
    else {
        esp_tile_decoupler.addr = get_router_addr(dev->addr);
    }

    if (val == 0) {
        iowrite32(&esp_tile_decoupler, DECOUPLER_REG, 0);
    }
    else {
        iowrite32(&esp_tile_decoupler, DECOUPLER_REG, BIT(0));
    }

#ifdef DPR_VERBOSE
    printf("After writing %0x to decoupler at 0x%0x, read bit %0x\n", val, (unsigned) esp_tile_decoupler.addr, ioread32(&esp_tile_decoupler, DECOUPLER_REG));
#endif

    return 0;
}

static void init_prc()
{
    // TODO: replace this with probe
    esp_prc.addr = (long long unsigned) APB_BASE_ADDR + 0xE400;
    get_io_tile_id(&io_tile_csr);

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
    printf("[PRC DRIVER]: PBS addr -- 0x%08x (offset 0x%08x) \n", (unsigned) pb_map[pbs_id].pbs_addr, PBS_BASE_ADDR);
    printf("[PRC DRIVER]: PBS size -- 0x%08x \n", pb_map[pbs_id].pbs_size);
#endif
}

unsigned int reconfigure_FPGA_async(struct esp_device *dev, unsigned pbs_id, unsigned is_router_dev)
{
    // TODO get lock on ICAP
    unsigned prc_done = 0;

    init_prc();

    //send a Proceed cmd to PRC to reset pending interrupt
    prc_done = ioread32(&io_tile_csr, PRC_INTERRUPT_REG);
#ifdef DPR_VERBOSE
    printf("[PRC DRIVER]: prc done -- %u \n", prc_done);
#endif
    if (prc_done == 1<<16)
        iowrite32(&esp_prc, 0x0, 0x3);


    //set bitstream trigger
    set_trigger(pbs_id);

    if (!(start_prc())) {
        decouple_acc(dev, 1, is_router_dev); // decouple tile
        printf("[PRC DRIVER]: Starting Reconfiguration \n");
        #ifdef DPR_MEASURE_RECONF_TIME
            __prc__cycles_start = esp_monitor(__prc__mon_args, NULL);
        #endif
        iowrite32(&esp_prc, 0x4, 0); // send reconfig trigger

        return 0;
    }
    else {
        printf("[PRC DRIVER]: Error reconfiguring FPGA \n");
        return -1;
    }
}

unsigned int wait_for_reconfigure_FPGA_completion(struct esp_device *dev, unsigned is_router_dev)
{
    unsigned prc_done = 0;

    while (prc_done == 0) {
        prc_done = ioread32(&io_tile_csr, PRC_INTERRUPT_REG);
    }

#ifdef DPR_MEASURE_RECONF_TIME
    __prc__cycles_end = esp_monitor(__prc__mon_args, NULL);
    __prc__cycles_diff = sub_monitor_vals(__prc__cycles_start, __prc__cycles_end);
    printf("[PRC DRIVER]: time is %u %u %u \n", __prc__cycles_start, __prc__cycles_end, __prc__cycles_diff);
#endif

    //send a Proceed cmd to PRC
    iowrite32(&esp_prc, 0x0, 0x3);

    //remove decoupling
    decouple_acc(dev, 0, is_router_dev); //decouple tile

    printf("[PRC DRIVER]: Reconfigured FPGA \n \n \n");
    // TODO release lock on ICAP

    return 0;
}

unsigned int reconfigure_FPGA(struct esp_device *dev, unsigned pbs_id, unsigned is_router_dev)
{
    reconfigure_FPGA_async(dev, pbs_id, is_router_dev);
    return wait_for_reconfigure_FPGA_completion(dev, is_router_dev);
}
