#ifndef ZYNQ_MODEL_H
#define ZYNQ_MODEL_H
#include <vector>
#include "fpga.h"
#include "partition.h"

typedef std::vector<unsigned long> Vec;
typedef std::vector<Vec> Vec2d;

typedef std::vector<pos> Vecpos;

typedef struct {
    unsigned int num_tasks_in_part;
    std::vector<unsigned int> task_id;                                  
}hw_task_allocation;

typedef struct {
    unsigned long num_rm_partitions;
    unsigned long num_forbidden_slots;
    unsigned long num_rows;
    unsigned long width;
    unsigned long num_connected_slots;
    unsigned long num_clk_regs;
    unsigned long clb_per_tile;
    unsigned long bram_per_tile;
    unsigned long dsp_per_tile;
    Vec *clb;
    Vec *bram;
    Vec *dsp;
    Vec2d  *conn_vector;
    Vecpos *fbdn_slot;
    Taskset *task_set;
    Platform *platform;
    vector<double> *slacks;
}param_to_solver;

typedef  struct{
    unsigned long num_partition;
    unsigned long max_modules_per_partition;
    std::vector<int> *x;
    std::vector<int> *y;
    std::vector<int> *w;
    std::vector<int> *h;
    std::vector<int> *clb_from_solver;
    std::vector<int> *bram_from_solver;
    std::vector<int> *dsp_from_solver;    
    std::vector<hw_task_allocation> *task_alloc;
}param_from_solver;

int zynq_start_optimizer(param_to_solver *, param_from_solver *);
int virtex_start_optimizer(param_to_solver *, param_from_solver *);
int virtex_start_optimizer_v5(param_to_solver *, param_from_solver *);
int pynq_start_optimizer(param_to_solver *, param_from_solver *);
int vc707_start_optimizer(param_to_solver *, param_from_solver *);
#endif // ZYNQ_MODEL_H
