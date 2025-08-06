
#include <monitors.h>
#include <esp_probe.h>
#include "soc_defs.h"

#ifndef __SCHEDULER_UTILS_H__
#define __SCHEDULER_UTILS_H__

#ifdef __riscv
    #ifndef APB_BASE_ADDR
        #define APB_BASE_ADDR 0x60000000
    #endif
#endif

// selection values for the clock selector
#define N_FREQS 7
unsigned div_sel[N_FREQS] = { 0b001, 0b010, 0b011, 0b100, 0b101, 0b110, 0b111 };

// Operating point for an accelerator
typedef struct acc_operating_point {
    unsigned viable;
} acc_operating_point_t;

// Set of operating points
typedef struct acc_profile {
    unsigned tile_id;
    acc_operating_point_t op[N_FREQS];
} acc_profile_t;

// DFS register mapping and encoding
#define DCO_REG 0b1001100 // addr[6:2] = 19
int encode_dco_ctrl(int freq_sel, int div_sel, int fc_sel, int cc_sel, int clk_sel, int en) {
    return ((      en & 0b000001) <<  0) |
           (( clk_sel & 0b000001) <<  1) |
           ((  cc_sel & 0b111111) <<  2) |
           ((  fc_sel & 0b111111) <<  8) |
           (( div_sel & 0b000111) << 14) |
           ((freq_sel & 0b000011) << 17);
}

// Write to frequency control register
void write_div_sel(struct esp_device *router_dev, int div_sel, int en) {
    iowrite32(router_dev, DCO_REG, encode_dco_ctrl(0, div_sel, 0, 0, 0, en));
}

/*
#define SCHED_PRIORITY_TIME 0
#define SCHED_PRIORITY_POWER 1
#define SCHED_PRIORITY_ENERGY 2

// Submit accelerator task with deadline and profile
// For each configuration, compute wait time/reconfiguration time/execution time
// If multiple meet deadline, go for lowest power or energy deadline
void spawn_hw_thread(struct esp_device *dev, int server_idx, int pbs_id, int new_div_sel_idx) {
    server_runtime_t *server = &servers[server_idx];
    server_profile_t *profile = &my_profiles[server_idx];
    struct esp_device router_dev;

    // TODO translate dev to router
    router_dev.addr = get_router_addr(dev->addr);

    // select server to spawn task (dev, pbs_id, new_div_sel_idx)
    // foreach server eligible for a task
    //   a server includes tile configuration and sub-tile region set
    unsigned int min_cost = (unsigned int)-1;
    //XXX min_cost_conf = XXX;
    unsigned int server_idx = 0;
    {
        profile = profiles[server_idx];

        // foreach frequency at which a server can run
        for (unsigned int freq_i = 0; freq_i < N_FREQS; freq_i++) {
            if (!profile.op[freq_i].viable) continue;

            // total time =
            //   time waiting for server to free
            //       = current task to complete
            //         + queued tasks
            //   + reconf_dfx_cycles
            //       = reprogram entire tile
            //         + reprogram sub-tile regions
            //   + reconf_dfs_cycles
            //       = change frequency if not already there
            //   + runtime at this frequency
            unsigned int time = 0;

            if (time >= deadline) {
                continue;
            }

            if (priority == SCHED_PRIORITY_TIME) {
                cost = time;
            } else {
                unsigned int power = profile.op[freq_i].power;

                if (priority = SCHED_PRIORITY_POWER) {
                    cost = power;
                }
                else {
                    unsigned int energy = power * time;

                    cost = energy;
                }
            }

            if (cost < min_cost) {
                min_cost = cost;
                //min_cost_conf = XXX;
            }
        }
    }

    // with selected server dev, pbs_id, new_div_sel_idx
    // reconfigure FPGA (wait reconf_dfx_cycles)
    reconfigure_FPGA_async(router_dev, pbs_id);
    // schedule new frequency based on budget (wait reconf_dfs_cycles)
    write_div_sel(&router_dev, div_sel[new_div_sel_idx], 1);
    // write other router registers

    wait_for_reconfigure_FPGA_completion(router_dev);

    // resume task setup (register writing) and execution (write start bit)
}
*/

#endif // __SCHEDULER_UTILS_H__
