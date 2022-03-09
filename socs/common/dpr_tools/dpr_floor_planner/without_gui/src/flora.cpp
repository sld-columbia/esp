#include "flora.h"
#include "generate_xdc.h"
#include "fpga.h"
#include <iostream>
#include <string>
#include <cmath>

using namespace std;

flora::flora(input_to_flora *input_fl)
{

    flora_input = input_fl;

    if(flora_input->num_rm_partitions > 0) {
        num_rm_partitions = flora_input->num_rm_partitions;
//        type = flora_input->type_of_fpga; 

        cout << "FLORA: num of partitions **** " << num_rm_partitions <<endl;
//        cout << "FLORA: type of FPGA **** " << type <<endl;
        cout << "FLORA: path for input **** " << flora_input->path_to_input <<endl;
    } 
    else {
        cout <<"FLORA: The number of Reconfigurable modules > 0";
        exit(-1);
    }
}

flora::~flora()
{
    cout << "FLORA: destruction " << endl;
}

//Prepare the input
void flora::clear_vectors()
{
    clb_vector.clear();
    bram_vector.clear();
    dsp_vector.clear();

    eng_x.clear();
    eng_y.clear();
    eng_w.clear();
    eng_h.clear();

    x_vector.clear();
    y_vector.clear();
    w_vector.clear();
    h_vector.clear();
}

void flora::prep_input()
{
    unsigned long row, col;
    int i , k;
    unsigned int ptr;
    string str;
    CSVData csv_data(flora_input->path_to_input);

    row = csv_data.rows();
    col = csv_data.columns();

    cout << endl << "FLORA: resource requirement of the input slots " <<endl;
    cout << "\t clb " << " \t bram " << "\t dsp " <<endl;
    for(i = 0, ptr = 0, k = 0; i < num_rm_partitions; i++, ptr++) {
        str = csv_data.get_value(i, k++);
        clb_vector[ptr] = std::stoul(str);

        str = csv_data.get_value(i, k++);
        bram_vector[ptr] = std::stoul(str);

        str = csv_data.get_value(i, k++);
        dsp_vector[ptr] = std::stoul(str);

        str = csv_data.get_value(i, k++);
        cell_name[i] = str;
        k = 0;

        cout << "\t " << clb_vector[ptr] << "\t " << bram_vector[ptr] << "\t " 
             << dsp_vector[ptr] << endl;
    }
}

void flora::write_output(param_from_solver *from_solver)
{
    unsigned long row, col;
    int i , k;
    unsigned int ptr;
    string str;
    CSVData csv_data_in(flora_input->path_to_input);
    CSVData csv_data_out(flora_input->path_to_input);

    cout << endl << "FLORA: writing resource inside slots " <<endl;
    cout << "\t clb " << " \t bram " << "\t dsp " <<endl;
    for(i = 0, ptr = 0, k = 0; i < num_rm_partitions; i++, ptr++) {
        str = to_string((*from_solver->clb_from_solver)[i]);
        csv_data_out.set_value(i, k++, str);
        //cout << "clb after flora " << str <<endl;
        
        str = to_string((*from_solver->bram_from_solver)[i]);
        csv_data_out.set_value(i, k++, " " + str);
        //cout << "bram after flora " << str <<endl;
        
        str = to_string((*from_solver->dsp_from_solver)[i]);
        csv_data_out.set_value(i, k++, " " + str); 
        //cout << "dsp after flora " << str <<endl;
        
        str = csv_data_in.get_value(i, k);
        csv_data_out.set_value(i, k++, " " + str); 
        //cout << "cell after flora " << str <<endl;
        
        str = csv_data_in.get_value(i, k);
        csv_data_out.set_value(i, k++, " " + str); 
        //cout << "cell after flora " << str <<endl;


        k = 0;
    }
   csv_data_out.write_data(flora_input->path_to_output);
}
void flora::start_optimizer()
{
    int i;
    param.bram = &bram_vector;
    param.clb  = &clb_vector;
    param.dsp  = &dsp_vector;
    param.num_rm_partitions = num_rm_partitions;
    param.num_connected_slots = connections;
    param.conn_vector = &connection_matrix;

//if(type == TYPE_ZYNQ){
#ifdef FPGA_ZYNQ
    zynq = new zynq_7010();
    for(i = 0; i < zynq->num_forbidden_slots; i++) {
        forbidden_region[i] = zynq->forbidden_pos[i];
    //cout<< " fbdn" << forbidden_region[i].x << endl;
    }

    param.num_forbidden_slots = zynq->num_forbidden_slots;
    param.num_rows = zynq->num_rows;
    param.width = zynq->width;
    param.fbdn_slot = &forbidden_region;
    param.num_clk_regs  = zynq->num_clk_reg /2;
    param.clb_per_tile  = ZYNQ_CLB_PER_TILE;
    param.bram_per_tile = ZYNQ_BRAM_PER_TILE;
    param.dsp_per_tile  = ZYNQ_DSP_PER_TILE;

    cout <<"FLORA: starting ZYNQ MILP optimizer " <<endl;
    zynq_start_optimizer(&param, &from_solver);
    cout <<"FLORA: finished MILP optimizer " <<endl;

//    }

#elif FPGA_PYNQ
    pynq_inst = new pynq();
    for(i = 0; i < pynq_inst->num_forbidden_slots; i++) {
        forbidden_region[i] = pynq_inst->forbidden_pos[i];
    //cout<< " fbdn" << forbidden_region[i].x << endl;
    }   

    param.num_forbidden_slots = pynq_inst->num_forbidden_slots;
    param.num_rows = pynq_inst->num_rows;
    param.width = pynq_inst->width;
    param.fbdn_slot = &forbidden_region;
    param.num_clk_regs  = pynq_inst->num_clk_reg /2; 
    param.clb_per_tile  = PYNQ_CLB_PER_TILE;
    param.bram_per_tile = PYNQ_BRAM_PER_TILE;
    param.dsp_per_tile  = PYNQ_DSP_PER_TILE;

    cout <<"FLORA: starting PYNQ MILP optimizer " <<endl;
    pynq_start_optimizer(&param, &from_solver);
    cout <<"FLORA: finished MILP optimizer " <<endl;

#elif FPGA_VC707
    vc707_inst = new vc707();

/*
    for(i = 0; i < vc707_inst->num_forbidden_slots; i++) {
        forbidden_region[i] = vc707_insti->forbidden_pos[i];
    //cout<< " fbdn" << forbidden_region[i].x << endl;
    }
*/

//    param.num_forbidden_slots = vc707_inst->num_forbidden_slots;
//    param.fbdn_slot = &forbidden_region;
//    param.num_rows = vc707_inst->num_rows;
    param.width = vc707_inst->width;
    param.num_clk_regs  = vc707_inst->num_clk_reg /2;
    param.clb_per_tile  = vc707_inst->clb_per_tile;
    param.bram_per_tile = vc707_inst->bram_per_tile;
    param.dsp_per_tile  = vc707_inst->dsp_per_tile;

    cout <<"FLORA: starting VC707 MILP optimizer " <<endl;
    vc707_start_optimizer(&param, &from_solver);
    write_output(&from_solver);
    cout <<"FLORA: finished VC707 optimizer " <<endl;

#endif  
}


void flora::generate_cell_name(unsigned long num_part, vector<std::string> *cell)
{
    int i;
    for(i = 0; i < num_part; i++)
//        (*cell)[i] = "design_1_i/hw_task_0_" + to_string(i) + "/inst";
//        (*cell)[i] = "hdmi_out_i/slot_" + to_string(i) + "_0";
        (*cell)[i] = "system_i/slot_p0_s" + to_string(i);
}

void flora::generate_xdc(std::string fplan_xdc_file)
{
    param_from_solver *from_sol_ptr = &from_solver;

#ifdef FPGA_ZYNQ
    zynq_fine_grained *fg_zynq_instance = new zynq_fine_grained();
    //generate_cell_name(num_rm_partitions, &cell_name);
    generate_xdc_file(fg_zynq_instance, from_sol_ptr, param, num_rm_partitions, cell_name, fplan_xdc_file);    
#elif FPGA_PYNQ
    pynq_fine_grained *fg_pynq_instance = new pynq_fine_grained();
    //generate_cell_name(num_rm_partitions, &cell_name);
    generate_xdc_file(fg_pynq_instance, from_sol_ptr, param, num_rm_partitions, cell_name, fplan_xdc_file);
#elif FPGA_VC707
    vc707_fine_grained *fg_vc707_instance = new vc707_fine_grained();
    //generate_cell_name(num_rm_partitions, &cell_name);
    generate_xdc_file(fg_vc707_instance, from_sol_ptr, param, num_rm_partitions, cell_name, fplan_xdc_file);
#endif
}
