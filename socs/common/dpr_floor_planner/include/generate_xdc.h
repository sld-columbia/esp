#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include "fine_grained.h"

using namespace std;

#ifndef GENERATE_XDC_H
#define GENERATE_XDC_H

//TODO: Make slot_names be assigned dynamically depending on the 
//      number of slots instead of being a fixed array

string slot_names[] = {"slot_0", "slot_1", "slot_2", "slot_3",
                       "slot_4", "slot_5"};

#define generate_xdc_file(fpga_type, from_fp_solver, to_solver,  num_slots, cell_name, fplan_xdc_file)\
{\
    unsigned long a;\
    int status;\
    unsigned long width, num_rows, num_forbidden_slots;\
    vector<slice> slices_in_slot = vector<slice> (MAX_SLOTS);\
    ofstream write_xdc;\
    sort_output(fpga_type, from_fp_solver, to_solver, slices_in_slot, num_slots)\
    cout << "GENERATE_XDC: Started xdc generation " << endl;\
    for (a = 0; a < num_slots; a++){\
    /*    cout << "x1 " << slices_in_slot[a][0].slice_x1  <<" y1 " << slices_in_slot[a][0].slice_y1*/\
    /*             << " x2 " << slices_in_slot[a][0].slice_x2 << " y2 " << slices_in_slot[a][0].slice_y2 << endl;*/\
    }\
    /*cout << "inside sort output bram 18" << endl;*/\
    for (a = 0; a < num_slots; a++){\
    /*    cout << "x1 " << slices_in_slot[a][1].slice_x1 << " y1 " << slices_in_slot[a][1].slice_y1 << */\
    /*             " x2 " << slices_in_slot[a][1].slice_x2 << " y2 " << slices_in_slot[a][1].slice_y2 << endl;*/\
    }\
    /*cout << "inside sort output bram 36" << endl;*/\
    for (a = 0; a < num_slots; a++){\
    /*    cout << "x1 " << slices_in_slot[a][2].slice_x1 << " y1 " << slices_in_slot[a][2].slice_y1 */\
    /*            <<" x2 " << slices_in_slot[a][2].slice_x2 << " y2 " << slices_in_slot[a][2].slice_y2 << endl;*/\
    }\
    /*cout << "inside sort output dsp " << endl;*/\
    for (a = 0; a < num_slots; a++){\
    /*    cout << "x1 " << slices_in_slot[a][3].slice_x1 << " y1 " << slices_in_slot[a][3].slice_y1<< */\
    /*             " x2 " << slices_in_slot[a][3].slice_x2  << " y2 " << slices_in_slot[a][3].slice_y2 << endl;*/\
    }\
    write_xdc.open(fplan_xdc_file);\
    write_xdc<< "# User Generated miscellaneous constraints" << endl <<endl <<endl;\
    for(a = 0; a < num_slots; a++){\
        write_xdc << "set_property HD.RECONFIGURABLE true [get_cells "<<cell_name[a] <<"]" <<endl;\
        write_xdc <<"create_pblock pblock_"<<slot_names[a] <<endl;\
        write_xdc <<"add_cells_to_pblock [get_pblocks pblock_"<<slot_names[a] <<"] [get_cells -quiet [list "<<cell_name[a] <<"]]" <<endl;\
        if((*from_fp_solver->clb_from_solver)[a] != 0) {\
            write_xdc << "resize_pblock [get_pblocks pblock_"<<slot_names[a]<< "] -add {SLICE_X" <<slices_in_slot[a][0].slice_x1<<"Y" <<\
                     slices_in_slot[a][0].slice_y1 <<":" <<"SLICE_X"<<slices_in_slot[a][0].slice_x2<<"Y"<<slices_in_slot[a][0].slice_y2 << "}" <<endl;\
        }\
        if((*from_fp_solver->bram_from_solver)[a] != 0) {\
        write_xdc << "resize_pblock [get_pblocks pblock_"<<slot_names[a]<< "] -add {RAMB18_X" <<slices_in_slot[a][1].slice_x1<<"Y" <<\
                     slices_in_slot[a][1].slice_y1 <<":" <<"RAMB18_X"<<slices_in_slot[a][1].slice_x2<<"Y"<<slices_in_slot[a][1].slice_y2 << "}" <<endl;\
        write_xdc << "resize_pblock [get_pblocks pblock_"<<slot_names[a]<< "] -add {RAMB36_X" <<slices_in_slot[a][2].slice_x1<<"Y" <<\
                    slices_in_slot[a][2].slice_y1 <<":" <<"RAMB36_X"<<slices_in_slot[a][2].slice_x2<<"Y"<<slices_in_slot[a][2].slice_y2 << "}" <<endl;\
        }\
        if((*from_fp_solver->dsp_from_solver)[a] != 0) {\
        write_xdc << "resize_pblock [get_pblocks pblock_"<<slot_names[a]<< "] -add {DSP48_X" <<slices_in_slot[a][3].slice_x1<<"Y" <<\
                    slices_in_slot[a][3].slice_y1 <<":" <<"DSP48_X"<<slices_in_slot[a][3].slice_x2<<"Y"<<slices_in_slot[a][3].slice_y2 << "}" <<endl;\
        }\
        write_xdc << "set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_"<< slot_names[a] <<"]" <<endl;\
        write_xdc << "set_property SNAPPING_MODE ON [get_pblocks pblock_"<< slot_names[a] <<"]" <<endl;\
        write_xdc <<endl <<endl;\
    }\
    write_xdc << "set_property SEVERITY {Warning} [get_drc_checks NSTD-1]" <<endl;\
    write_xdc << "set_property SEVERITY {Warning} [get_drc_checks UCIO-1]" <<endl;\
    write_xdc.close();\
    cout << "GENERATE_XDC: Finsihded xdc generation " << endl;\
}

#define sort_output(fpga_type, from_fp_solver, to_solver, output_vec, num_slots) {\
    int i, k, m, index;\
    int flag = 0;\
    int x, y, w, h;\
    int col;\
    int bram_type = 0;\
    bool is_bram_18 = false;\
    for(i = 0; i < num_slots; i++){\
        x = (*from_fp_solver->x)[i];\
        y = (*from_fp_solver->y)[i];\
        w = (*from_fp_solver->w)[i];\
        h = (*from_fp_solver->h)[i];\
    is_bram_18 = false;\
    bram_type = 0;\
    /*cout<< "starting " << x << " " << y <<endl;*/\
    for(m = 0, index = 0; m < 3; m++, index++) {\
            k = x;\
            flag = 0;\
            while(flag == 0){\
                if(k < x + w){\
                    if((fpga_type->fg[k].type_of_res) == m) {\
                        output_vec[i][index].slice_x1 = fpga_type->fg[k].slice_1;\
                        /*cout << "left m " << m << " k " << k << " res " <<fpga_type->fg[k].slice_2 <<endl;*/\
                        flag = 1;\
                    }\
                    else\
                        k += 1;\
                }\
                else\
                    flag = 1;\
            }\
            flag = 0;\
            k = x + w - 1 ;\
            while(flag == 0){\
                if (k >= x) {\
                    if((fpga_type->fg[k].type_of_res) == m){\
                        output_vec[i][index].slice_x2 = fpga_type->fg[k].slice_2;\
                        /*cout << " right m " << m << " k " << k << " res " <<fpga_type->fg[k].slice_2 <<endl;*/\
                        flag = 1;\
                    }\
                    else\
                        k -= 1;\
                }\
                else\
                    flag = 1;\
            }\
            if(m == CLB)\
                col = to_solver.clb_per_tile;\
            else if (m == BRAM && bram_type == 0)\
                col = to_solver.bram_per_tile * 2;\
            else if(m == BRAM && bram_type == 1)\
                col = to_solver.bram_per_tile;\
            else if(m == DSP)\
                col = to_solver.dsp_per_tile;\
            if(m == CLB) {\
                if((*from_fp_solver->clb_from_solver)[i] != 0) {\
                    output_vec[i][index].slice_y1 = y /10 * col;\
                    output_vec[i][index].slice_y2 = (((y + h)/10) * col) - 1;\
                }\
                else {\
                    output_vec[i][index].slice_y1 = 0;\
                    output_vec[i][index].slice_y2 = 0;\
                }\
            }\
                if(m == BRAM) {\
                    if((*from_fp_solver->bram_from_solver)[i] != 0) {\
                        output_vec[i][index].slice_y1 = y /10 * col;\
                        output_vec[i][index].slice_y2 = (((y + h)/10) * col) - 1;\
                    }\
                    else {\
                        output_vec[i][index].slice_y1 = 0;\
                        output_vec[i][index].slice_y2 = 0;\
                    }\
               }\
                 if(m == DSP) {\
                      if((*from_fp_solver->dsp_from_solver)[i] != 0) {\
                          output_vec[i][index].slice_y1 = y /10 * col;\
                          output_vec[i][index].slice_y2 = (((y + h)/10) * col) - 1;\
                      }\
                       else {\
                            output_vec[i][index].slice_y1 = 0;\
                            output_vec[i][index].slice_y2 = 0;\
                        }\
                }\
                 if(m == BRAM && is_bram_18 == false) {\
                     m -= 1;\
                     is_bram_18 = true;\
                     bram_type = 1;\
                 }\
        }\
    }\
}
#endif // GENERATE_XDC_H
