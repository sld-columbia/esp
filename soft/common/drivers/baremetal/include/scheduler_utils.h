
//#include <monitors.h>
//#include <esp_probe.h>
//#include "soc_defs.h"

#ifndef __SCHEDULER_UTILS_H__
#define __SCHEDULER_UTILS_H__

#ifdef SCHEDULER_DEBUG
    #define DEBUG(a) printf("DEBUG [SCHEDULER] %s\n", a);
    #define DEBUGF(a, ...) printf("DEBUG [SCHEDULER] "); printf(a, __VA_ARGS__); printf("\n");
#else
    #define DEBUG(a)
    #define DEBUGF(a, ...)
#endif

#ifdef SCHEDULER_LOG
    #define LOG(a) printf("LOG [SCHEDULER] %s\n", a);
    #define LOGF(a, ...) printf("LOG [SCHEDULER] "); printf(a, __VA_ARGS__); printf("\n");
#else
    #define LOG(a)
    #define LOGF(a, ...)
#endif // SCHEDULER_LOG

#ifdef SCHEDULER_PERF
    #define SCHEDULER_PERF_INCREMENT(v) ++(v)
    #define SCHEDULER_PERF_MAX(v, m) if (m > v) v = m;
    #define SCHEDULER_PERF_MIN(v, m) if (m < v) v = m;
#else
    #define SCHEDULER_PERF_INCREMENT(v)
    #define SCHEDULER_PERF_MAX(v, m)
    #define SCHEDULER_PERF_MIN(v, m)
#endif // SCHEDULER_PERF

#ifndef ESP

typedef unsigned long int uint64_t;
typedef unsigned int uint32_t;
typedef unsigned char bool;

#define false 0
#define true (!false)

struct esp_device {
    uint32_t dev_id;
    uint64_t addr;
};

unsigned ioread32(struct esp_device *dev, unsigned offset)
{
    const long unsigned addr = dev->addr + offset;
    DEBUGF("Read address is %08lx", addr);
    volatile unsigned *reg   = (unsigned *)addr;
    return *reg;
}

void iowrite32(struct esp_device *dev, unsigned offset, unsigned payload)
{
    const long unsigned addr = dev->addr + offset;
    DEBUGF("Write address is %08lx", addr);
    volatile unsigned *reg   = (unsigned *)addr;
    *reg                     = payload;
}

static uint32_t _time = 0;

void set_time(uint32_t time) { _time = time; }
uint32_t get_time() { return _time; }

#endif // ESP

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
    uint32_t viable;
    uint32_t power;
    uint32_t latency;
} acc_operating_point_t;

// Set of operating points
typedef struct acc_profile {
    //unsigned tile_id;
    uint32_t function_id;
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

#define TILE_QUEUE_SIZE 16
#define TILE_QUEUE_SIZE_MASK 0b1111
#ifndef N_TILES
#define N_TILES 4
#endif // N_TILES
#define N_ACCS 10
#define DFX_QUEUE_SIZE 16
#define DFX_QUEUE_SIZE_MASK 0b1111

#define FUNCTION_NONE 0
#define FUNCTION_FFT 1
#define FUNCTION_PAUL1_T1 2
#define FUNCTION_PAUL1_T2 3
#define FUNCTION_PAUL1_T3 4
#define FUNCTION_PAUL1_T4 5
#define FUNCTION_PAUL1_T5 6
#define FUNCTION_PAUL1_T6 7
#define FUNCTION_PAUL2_LZ4 8
#define FUNCTION_PAUL2_ZSTD 9
#define FUNCTION_PAUL2_VADD 10

// TODO store array of pointers to a set array of dispatch_t
//   this way, can use the same objects in both arrays
//   also less copying if want to bypass something in the queue or move around objects in the queue

// profiling
//   get envelope of activity factor versus power
//   match counter to activity factor

// stage of a workload
// how to abstract
//   ESP: one driver invocation
//   Chipyard: one RoCC instruction
typedef struct {
    uint32_t function_id;
    uint32_t deadline; // deadline from stage request (periodic)
    void *conf_args;
} stage_t;

// dispatch from processor to accelerator and reconfiguration manager
typedef struct {
    uint32_t function_id;
    uint32_t tile_id;
    uint32_t div_sel;
    uint32_t pbs_id;
    uint32_t latency;
    uint32_t reconfiguration_latency;
    void *conf_args;
} dispatch_t;

// generic queue of dispatches
typedef struct {
    uint32_t q_head;
    uint32_t q_tail;
    uint32_t q_size;
    dispatch_t q[DFX_QUEUE_SIZE];
    uint32_t last_function_id;
    uint32_t total_latency;
#ifdef SCHEDULER_PERF
    uint32_t num_enqueues;
    uint32_t num_dequeues;
    uint32_t num_blocked_enqueues;
    uint32_t max_size;
    uint32_t max_total_latency;
#endif
} dispatch_queue_t;

// tile in the SoC
typedef struct {
    uint32_t function_id;
    uint32_t div_sel;
    uint32_t time_of_completion;
    dispatch_t dispatch;
    uint32_t reconfiguration_latency;
    struct esp_device *esp_dev;
} tile_t;

static uint32_t cpu_deadline = 1000000;

// queues
static dispatch_queue_t tile_queues[N_TILES];
static dispatch_queue_t dfx_queue;

// accelerator registers
//static uint32_t regs[N_TILES][32];
static struct esp_device devs[N_TILES+1];

// tiles
static tile_t tiles[N_TILES];

#ifdef SCHEDULER_PERF
// global performance counters
uint32_t num_dropped_stages;
#endif // SCHEDULER_PERF

void init_scheduler(uint64_t addrs[N_TILES], uint64_t dfx_controller_addr) {
    for (uint32_t t = 0; t < N_TILES; ++t) {
        //devs[t].addr = ((uint64_t)((uint32_t*)regs[t]));
        devs[t].addr = addrs[t];

        tiles[t].function_id = 0;
        tiles[t].div_sel = 3;
#ifdef EXPERIMENT_PAUL1
        tiles[t].reconfiguration_latency = 6;
#elif defined(EXPERIMENT_PAUL2)
        tiles[t].reconfiguration_latency = 21;
#else
        tiles[t].reconfiguration_latency = 500;
#endif
        tiles[t].esp_dev = &devs[t];

        tile_queues[t].q_head = 0;
        tile_queues[t].q_tail = 0;
        tile_queues[t].q_size = 0;
        tile_queues[t].last_function_id = FUNCTION_NONE;
        tile_queues[t].total_latency = 0;
#ifdef SCHEDULER_PERF
        tile_queues[t].num_enqueues = 0;
        tile_queues[t].num_dequeues = 0;
        tile_queues[t].num_blocked_enqueues = 0;
        tile_queues[t].max_size = 0;
        tile_queues[t].max_total_latency = 0;
#endif
    }

    devs[N_TILES].addr = dfx_controller_addr;
    dfx_queue.q_head = 0;
    dfx_queue.q_tail = 0;
    dfx_queue.q_size = 0;
    dfx_queue.last_function_id = FUNCTION_NONE;
    dfx_queue.total_latency = 0;
#ifdef SCHEDULER_PERF
    dfx_queue.num_enqueues = 0;
    dfx_queue.num_dequeues = 0;
    dfx_queue.num_blocked_enqueues = 0;
    dfx_queue.max_size = 0;
    dfx_queue.max_total_latency = 0;
#endif
}

void log_scheduler() {
    uint32_t time = get_time();

    LOG("===============")
    LOGF("Final time is %d", time);

    for (uint32_t t = 0; t < N_TILES; ++t) {
        LOGF("Tile %d:", t);
        LOGF("    Dispatches left:         %d", tile_queues[t].q_size);
#ifdef SCHEDULER_PERF
        LOGF("    Enqueues:                %d", tile_queues[t].num_enqueues);
        LOGF("    Dequeues:                %d", tile_queues[t].num_dequeues);
        LOGF("    Blocked enqueues:        %d", tile_queues[t].num_blocked_enqueues);
        LOGF("    Maximum stages waiting:  %d", tile_queues[t].max_size);
        LOGF("    Maximum waiting latency: %d", tile_queues[t].max_total_latency);
#endif
    }

    LOG("Reconfiguration queue:");
    LOGF("    Dispatches left:         %d", dfx_queue.q_size);
#ifdef SCHEDULER_PERF
    LOGF("    Enqueues:                %d", dfx_queue.num_enqueues);
    LOGF("    Dequeues:                %d", dfx_queue.num_dequeues);
    LOGF("    Blocked enqueues:        %d", dfx_queue.num_blocked_enqueues);
    LOGF("    Maximum stages waiting:  %d", dfx_queue.max_size);
    LOGF("    Maximum waiting latency: %d", dfx_queue.max_total_latency);

    LOG("Scheduler statistics:");
    LOGF("    Number dropped stages: %d", num_dropped_stages);
#endif
}

static acc_profile_t acc_profiles[N_ACCS+1] = {
    {
        .function_id = FUNCTION_NONE,
        .op = {
            { .viable = 1, .power = 0, .latency = 0 },
            { .viable = 1, .power = 0, .latency = 0 },
            { .viable = 1, .power = 0, .latency = 0 },
            { .viable = 1, .power = 0, .latency = 0 },
            { .viable = 1, .power = 0, .latency = 0 },
            { .viable = 1, .power = 0, .latency = 0 },
            { .viable = 1, .power = 0, .latency = 0 }
        }
    },
    {
        .function_id = FUNCTION_FFT,
        .op = {
            { .viable = 1, .power = 39, .latency = 53599 },
            { .viable = 1, .power = 42, .latency = 50782 },
            { .viable = 1, .power = 45, .latency = 47969 },
            { .viable = 1, .power = 48, .latency = 45156 },
            { .viable = 1, .power = 51, .latency = 42346 },
            { .viable = 0, .power = 54, .latency = 39536 },
            { .viable = 0, .power = 57, .latency = 36726 }
        }
    },
    {
        .function_id = FUNCTION_PAUL1_T1,
        .op = {
            { .viable = 1, .power = 5, .latency = 48 },
            { .viable = 1, .power = 6, .latency = 24 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 }
        }
    },
    {
        .function_id = FUNCTION_PAUL1_T2,
        .op = {
            { .viable = 1, .power = 5, .latency = 36 },
            { .viable = 1, .power = 6, .latency = 18 },
            { .viable = 1, .power = 7, .latency = 12 },
            { .viable = 1, .power = 8, .latency = 9 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 }
        }
    },
    {
        .function_id = FUNCTION_PAUL1_T3,
        .op = {
            { .viable = 1, .power = 6, .latency = 48 },
            { .viable = 1, .power = 7, .latency = 24 },
            { .viable = 1, .power = 8, .latency = 16 },
            { .viable = 1, .power = 9, .latency = 12 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 }
        }
    },
    {
        .function_id = FUNCTION_PAUL1_T4,
        .op = {
            { .viable = 1, .power = 3, .latency = 96 },
            { .viable = 1, .power = 4, .latency = 48 },
            { .viable = 1, .power = 5, .latency = 32 },
            { .viable = 1, .power = 6, .latency = 24 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 }
        }
    },
    {
        .function_id = FUNCTION_PAUL1_T5,
        .op = {
            { .viable = 1, .power = 4, .latency = 48 },
            { .viable = 1, .power = 5, .latency = 24 },
            { .viable = 1, .power = 5, .latency = 16 },
            { .viable = 1, .power = 6, .latency = 12 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 }
        }
    },
    {
        .function_id = FUNCTION_PAUL1_T6,
        .op = {
            { .viable = 1, .power = 4, .latency = 48 },
            { .viable = 1, .power = 5, .latency = 24 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 }
        }
    },
    {
        .function_id = FUNCTION_PAUL2_LZ4,
        .op = {
            { .viable = 1, .power = 638, .latency = 830 },
            { .viable = 1, .power = 655, .latency = 650 },
            { .viable = 1, .power = 664, .latency = 540 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 }
        }
    },
    {
        .function_id = FUNCTION_PAUL2_ZSTD,
        .op = {
            { .viable = 1, .power = 689, .latency = 440 },
            { .viable = 1, .power = 706, .latency = 420 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 }
        }
    },
    {
        .function_id = FUNCTION_PAUL2_VADD,
        .op = {
            { .viable = 1, .power = 612, .latency = 159 },
            { .viable = 1, .power = 621, .latency = 119 },
            { .viable = 1, .power = 638, .latency = 106 },
            { .viable = 1, .power = 655, .latency = 95 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 },
            { .viable = 0, .power = 0, .latency = 0 }
        }
    },
};

/* ===== Public interface ===== */
bool schedule(stage_t s);
void tile_complete(uint32_t tile_id);
void tile_reconfiguration_complete();

/* ===== Private function definitions ===== */
//void dispatch(uint32_t tile_id, uint32_t div_sel, uint32_t function_id, void *conf_args);
void dispatch(dispatch_t d);
void start_dfx_async(uint32_t tile_id, uint32_t pbs_id);

/* ===== Queue functions ===== */

static inline bool push(dispatch_queue_t *q, dispatch_t d, bool is_dfx_queue) {
    // size check
    if (is_dfx_queue) {
        if (q->q_size >= DFX_QUEUE_SIZE) {
            SCHEDULER_PERF_INCREMENT(q->num_blocked_enqueues);
            return false;
        }
    }
    else {
        if (q->q_size >= TILE_QUEUE_SIZE) {
            SCHEDULER_PERF_INCREMENT(q->num_blocked_enqueues);
            return false;
        }
    }

    // add to end of queue
    q->q[q->q_tail & DFX_QUEUE_SIZE_MASK] = d;
    q->q_size++;
    q->q_tail++;

    // update metadata
    q->last_function_id = d.function_id;
    if (is_dfx_queue) {
        q->total_latency += d.reconfiguration_latency;
        DEBUGF("Pushing to dfx queue which now has a last function of %d and total latency of %d after %d stages", q->last_function_id, q->total_latency, q->q_size);
    }
    else {
        q->total_latency += d.latency + d.reconfiguration_latency;
        DEBUGF("Pushing to tile queue which now has a last function of %d and total latency of %d after %d stages", q->last_function_id, q->total_latency, q->q_size);
    }

    SCHEDULER_PERF_INCREMENT(q->num_enqueues);
    SCHEDULER_PERF_MAX(q->max_size, q->q_size);
    SCHEDULER_PERF_MAX(q->max_total_latency, q->total_latency);
    return true;
}

static inline dispatch_t peek(dispatch_queue_t *q, bool is_dfx_queue) {
    dispatch_t d;

    // size check
    if (q->q_size == 0) {
        d.function_id = FUNCTION_NONE;
        return d;
    }

    // take start of queue (do not modify pointers)
    d = q->q[q->q_head & DFX_QUEUE_SIZE_MASK];

    SCHEDULER_PERF_INCREMENT(q->num_dequeues);
    return d;
}

static inline dispatch_t pop(dispatch_queue_t *q, bool is_dfx_queue) {
    dispatch_t d;

    // size check
    if (q->q_size == 0) {
        d.function_id = FUNCTION_NONE;
        return d;
    }

    // remove from start of queue
    d = q->q[q->q_head & DFX_QUEUE_SIZE_MASK];
    q->q_size--;
    q->q_head++;

    // update metadata
    if (is_dfx_queue) {
        q->total_latency -= d.reconfiguration_latency;
    }
    else {
        q->total_latency -= d.latency + d.reconfiguration_latency;
    }

    return d;
}

// submit a stage for execution
bool schedule(stage_t s) {
    uint32_t best_tile = 0x7fffffff;
    uint32_t best_freq = 4; // default frequency
    uint32_t best_latency = 0;

    DEBUGF("Submitting stage with function %d and deadline %d for execution to %d tiles", s.function_id, s.deadline, N_TILES);

    // minimize energy by minimizing reconfiguration time
    //   => less time with CPU idle
    //   => less time with wasted power from CPU who dominates power consumption
    uint32_t min_reconf_time = 0x7fffffff;
    uint32_t min_reconf_time_wait_time = 0;

    // minimize power by minimizing power consumed by each tile
    uint32_t min_power = 0x7fffffff;

    // stay within energy budget
    //   use cpu_energy / cpu_power = cpu_time as "deadline"
    //   but already have a deadline, so must choose minimum
    uint32_t deadline = s.deadline;
    if (cpu_deadline < deadline) {
        deadline = cpu_deadline;
    }

    // find time before next stage
    //deadline -= time_into_current_slice;

    for (uint32_t i = 0; i < N_TILES; ++i) {
        // wait for tile to complete its current and enqueued tasks
        uint32_t wait_time = tile_queues[i].total_latency;
        uint32_t time = get_time();
        if (tiles[i].time_of_completion > time) {
            wait_time += tiles[i].time_of_completion - time;
        }

        // determine if must change bitstream
        uint32_t reconf_time = 0;
        if (tile_queues[i].last_function_id != s.function_id) {
            reconf_time += tiles[i].reconfiguration_latency; // bitstream size for tile (will be constant)
        }
        // determine if must wait to change bitstream
        if (tile_queues[i].q_size) {
            wait_time += dfx_queue.total_latency;
        }
        DEBUGF("Tile %d incurs a reconfiguration time of %d and wait time of %d", i, reconf_time, wait_time);

        // fine-grained power management
        for (uint32_t j = 0; j < N_FREQS; ++j) {
            uint32_t viable = 0;

            acc_operating_point_t op_pt = acc_profiles[s.function_id].op[j];
            if (op_pt.viable) {
                // determine if solution is viable
                DEBUGF("Frequency %d has a total latency of %d+%d+%d=%d around a deadline of %d", j, wait_time, reconf_time, op_pt.latency, (wait_time + reconf_time + op_pt.latency), deadline);
                if ((
                    wait_time       // preceding stages
                    + reconf_time   // time to reconfigure from preceding stage
                    + op_pt.latency // time to execute stage at this frequency
                ) < deadline) {
                    viable = 1;
                }
            }

            // XXX - calculate power that each accelerator will consume at this time (need to snoop through queues)
            uint32_t power = 0;
            power += op_pt.power;

#if defined(SCHEDULER_GOAL_POWER)
            // find new lowest power solution
            if (viable && power < min_power) {
                min_power = power;
                min_reconf_time = reconf_time;
                best_tile = i;
                best_freq = j;
                best_latency = op_pt.latency;
            }

#elif defined(SCHEDULER_GOAL_ENERGY)
            // find new minimum reconfiguration time solution
            if (viable) {
                if (reconf_time < min_reconf_time ||
                    reconf_time == min_reconf_time && wait_time < min_reconf_time_wait_time) {
                    min_power = power;
                    min_reconf_time = reconf_time;
                    min_reconf_time_wait_time = wait_time;
                    best_tile = i;
                    best_freq = j;
                    best_latency = op_pt.latency;
                }
            }
#endif // SCHEDULER_GOAL_POWER
        }
    }

    // dispatch arguments for the function
    if (best_tile < N_TILES) {
        dispatch_t d = {
            .function_id = s.function_id,
            .tile_id = best_tile,
            //.div_sel = div_sel[best_freq],
            .div_sel = best_freq,
            .conf_args = s.conf_args,
            .latency = best_latency,
            .reconfiguration_latency = min_reconf_time
        };

        DEBUGF("Dispatching stage with function %d to tile %d @ frequency %d and power %d (reconfiguration time %d)", s.function_id, best_tile, best_freq, min_power, min_reconf_time);

        // push to accelerator queue
        DEBUG("Enqueueing");
        push(&tile_queues[best_tile], d, false);

        if (
            tile_queues[best_tile].q_size == 1 &&
            ioread32(tiles[best_tile].esp_dev, 0) == 1
        ) {
            DEBUG("Bypassing wait");
            tile_complete(best_tile);
        }
        return true;
    }
    else {
        DEBUG("Could not schedule stage");
        SCHEDULER_PERF_INCREMENT(num_dropped_stages);
        return false;
    }
}

// interrupt for when a tile has completed its function
void tile_complete(uint32_t tile_id) {
    iowrite32(tiles[tile_id].esp_dev, 4, 0);

    // pop next stage to dispatch
    if (tile_queues[tile_id].q_size) {
        dispatch_t d = peek(&tile_queues[tile_id], false);

        DEBUGF("Received dispatch with function %d to tile %d (currently loaded %d)", d.function_id, tile_id, tiles[tile_id].function_id);
        if (tiles[tile_id].function_id != d.function_id) {
            // push to reconfiguration queue
            DEBUGF("Pushing function %d tile %d to reconfiguration queue\n", d.function_id, tile_id);
            push(&dfx_queue, d, true);
            if (dfx_queue.q_size == 1) {
                start_dfx_async(d.tile_id, d.pbs_id);
            }
        }
        else {
            // pop task without new configuration
            pop(&tile_queues[tile_id], false);
            dispatch(d);
        }
    }
    else {
        DEBUGF("No more tasks in tile %d", tile_id);
    }
}

// Interrupt for when the DFX controller has completed
//   Everything in the DFX queue is for a non-busy tile
//   When reconfiguration has finished, need to dispatch the stage to that tile.
//   Start the next reconfiguration unless it is for the same tile. But this will never be the case because a tile will not pop a reconfiguration from its queue until its stage is complete
void tile_reconfiguration_complete() {
    // pop completed reconfiguration
    dispatch_t d = pop(&dfx_queue, true);
    tiles[d.tile_id].function_id = d.function_id;
    struct esp_device *dev = &devs[N_TILES];
    DEBUGF("Completed DFX for tile %d and pbs %d, %d configurations left", d.tile_id, d.function_id, dfx_queue.q_size);
    iowrite32(dev, 4, 0);

    //dispatch(d.tile_id, d.div_sel, d.function_id, d.conf_args);
    //dispatch(d);
    tile_complete(d.tile_id);

    // find the next reconfiguration
    if (dfx_queue.q_size) {
        dispatch_t next_d = peek(&dfx_queue, true);

        // only reconfigure in non-running different tile
        DEBUGF("Next DFX running on tile %d, just completed DFX in tile %d", next_d.tile_id, d.tile_id);
        if (d.tile_id != next_d.tile_id &&
            ioread32(tiles[next_d.tile_id].esp_dev, 0) == 1) {
            start_dfx_async(next_d.tile_id, next_d.pbs_id);
        }
    }
}

// dispatch execution arguments to a tile
void dispatch(dispatch_t d) {
    if (d.function_id == FUNCTION_NONE) {
        return;
    }

    DEBUGF("Dispatching function %d to tile %d @ frequency %d", d.function_id, d.tile_id, d.div_sel);

    // XXX
    struct esp_device *dev = tiles[d.tile_id].esp_dev;
    //iowrite32(dev, 8, encode_dco_ctrl(0, d.div_sel, 0, 0, 0, 1));
    iowrite32(dev, 8, d.div_sel);
    DEBUG("Done writing frequency");

    tiles[d.tile_id].time_of_completion = get_time() + d.latency;

    // issue application-specific configuration
    switch (d.function_id) {
    case FUNCTION_FFT:
        //fft_stratus_access *access = (fft_stratus_access*)conf_args;
        //iowrite32(dev, 0, 0);
        break;
    default:
        break;
    };

    iowrite32(dev, 4, d.function_id);
}

void reconfigure_FPGA_async(struct esp_device *router_dev, uint32_t pbs_id) {}

// issue commands to the DFX controller for a new reconfiguration
static struct esp_device *router_dev = NULL;
void start_dfx_async(uint32_t tile_id, uint32_t pbs_id) {
    // XXX
    struct esp_device *dev = &devs[N_TILES];
    DEBUGF("Starting DFX for tile %d and pbs %d", tile_id, pbs_id);
    iowrite32(dev, 4, 1);
    iowrite32(dev, 8, tile_id);
    iowrite32(dev, 12, pbs_id);

    // do not wait for reconfiguration completion
    // router_dev is io_tile or specific to the tile?
    reconfigure_FPGA_async(router_dev, pbs_id);
}

/*
#define SCHED_PRIORITY_TIME 0
#define SCHED_PRIORITY_POWER 1
#define SCHED_PRIORITY_ENERGY 2

// Submit accelerator stage with deadline and profile
// For each configuration, compute wait time/reconfiguration time/execution time
// If multiple meet deadline, go for lowest power or energy deadline
void spawn_hw_thread(struct esp_device *dev, int server_idx, int pbs_id, int new_div_sel_idx) {
    server_runtime_t *server = &servers[server_idx];
    server_profile_t *profile = &my_profiles[server_idx];
    struct esp_device router_dev;

    // TODO translate dev to router
    router_dev.addr = get_router_addr(dev->addr);

    // select server to spawn stage (dev, pbs_id, new_div_sel_idx)
    // foreach server eligible for a stage
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
            //       = current stage to complete
            //         + queued stages
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

    // resume stage setup (register writing) and execution (write start bit)
}
*/

#endif // __SCHEDULER_UTILS_H__
