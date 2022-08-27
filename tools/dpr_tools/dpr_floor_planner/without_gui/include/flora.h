#ifndef FP_H
#define FP_H

#include "gurobi_c++.h"
#include "milp_solver_interface.h"
#include "csv_data_manipulator.hpp"
#include <string>

/*                                                                         
#ifdef WITH_PARTITIONING                                                 
    #include "fine_grained.h"                                            
    #ifdef FPGA_ZYNQ                                                     
        #include "zynq_fine_grained.h"                                   
    #elif FPGA_PYNQ                                                      
        #include "pynq_fine_grained.h"                                   
    #endif                                                               
#else                                                                    
    #ifdef FPGA_ZYNQ                                                     
        #include "zynq.h"                                                
    #elif FPGA_PYNQ                                                      
        #include "pynq.h"                                                
    #endif                                                               
#endif 
*/

#include "fine_grained.h"
#ifdef FPGA_ZYNQ
    #include "zynq_fine_grained.h"
//    #include "zynq.h"
#elif FPGA_PYNQ
    #include "pynq_fine_grained.h"
//    #include "pynq.h"
#elif FPGA_VC707 
    #include "vc707_fine_grained.h"
#endif

namespace Ui {
class fp;
}

enum fpga_type {
    TYPE_ZYNQ = 0,
    TYPE_VIRTEX,
    TYPE_VIRTEX_5,
    TYPE_PYNQ
};

typedef std::vector<pos> position_vec;
typedef std::vector<std::vector<unsigned long>> vec_2d;
typedef struct{
    unsigned long clb;
    unsigned long bram;
    unsigned long dsp;
}slot;

typedef struct{
    unsigned long num_rm_partitions;
    std::string path_to_input;
    std::string path_to_output;
}input_to_flora;

#define MY_RAND() ((double)((double)rand()/(double)RAND_MAX))

class flora 
{

public:
    explicit flora(input_to_flora*);
    ~flora();

#ifdef FPGA_ZYNQ
    zynq_7010 *zynq;
#elif FPGA_PYNQ
    pynq *pynq_inst;
#elif FPGA_VC707
    vc707 *vc707_inst;
#endif

    unsigned long num_rm_partitions = 0;
    
    //enum fpga_type type = ZYNQ;
    enum fpga_type type;
    unsigned long connections = 0;

    std::vector<unsigned long> clb_vector =  std::vector<unsigned long>(MAX_SLOTS);
    std::vector<unsigned long> bram_vector = std::vector<unsigned long>(MAX_SLOTS);
    std::vector<unsigned long> dsp_vector =  std::vector<unsigned long>(MAX_SLOTS);

    std::vector<int> clb_from_solver  = std::vector<int>(MAX_SLOTS);
    std::vector<int> bram_from_solver = std::vector<int>(MAX_SLOTS);
    std::vector<int> dsp_from_solver  = std::vector<int>(MAX_SLOTS);

    std::vector<slot> sl_array = std::vector<slot>(MAX_SLOTS);

    vec_2d connection_matrix = std::vector<std::vector<unsigned long>> (MAX_SLOTS, std::vector<unsigned long> (MAX_SLOTS, 0));

    std::vector<int> eng_x = std::vector<int>(MAX_SLOTS);
    std::vector<int> eng_y = std::vector<int>(MAX_SLOTS);
    std::vector<int> eng_w = std::vector<int>(MAX_SLOTS);
    std::vector<int> eng_h = std::vector<int>(MAX_SLOTS);

    std::vector<int> x_vector =  std::vector<int>(MAX_SLOTS);
    std::vector<int> y_vector =  std::vector<int>(MAX_SLOTS);
    std::vector<int> w_vector =  std::vector<int>(MAX_SLOTS);
    std::vector<int> h_vector =  std::vector<int>(MAX_SLOTS);

    std::vector<hw_task_allocation> alloc =  std::vector<hw_task_allocation>(MAX_SLOTS);

    position_vec forbidden_region = position_vec(MAX_SLOTS);
//    position_vec forbidden_region_pynq = position_vec(MAX_SLOTS);
//    position_vec forbidden_region_virtex = position_vec(MAX_SLOTS);
//    position_vec forbidden_region_virtex_5 = position_vec(MAX_SLOTS);
    std::vector<unsigned long> get_units_per_task(unsigned long n,
                                                  unsigned long n_units,
                                                  unsigned long n_min,
                                                  unsigned long n_max);
    input_to_flora *flora_input;
    param_to_solver param;
    param_from_solver from_solver = {0, 0, &eng_x, &eng_y,
                                    &eng_w, &eng_h,
                                    &clb_from_solver,
                                    &bram_from_solver,
                                    &dsp_from_solver,
                                    &alloc};
    std::vector<std::string> cell_name = std::vector<std::string>(MAX_SLOTS);

    void clear_vectors();
    void prep_input();
    void write_output(param_from_solver *from_solver);
    void start_optimizer();
    void generate_cell_name(unsigned long num_part, vector<std::string> *cell);
    void generate_xdc(std::string fplan_file_name);

//    void init_fpga(enum fpga_type);
//    void init_gui();
//    void plot_rects(param_from_solver *);
//    bool is_compatible(std::vector<slot> ptr, unsigned long slot_num, int max, unsigned long min, int type);
    vector <double> generate_slacks(Taskset& t, Platform& platform, double alpha);
    Taskset generate_taskset_one_HW_task_per_SW_task
            (uint n, Platform& p,
            const vector<double>& res_usage,
            double WCET_area_ratio,
            double max_area_usage);
};

#endif // FP_H
