//Copyright (c) 2011-2023 Columbia University, System Level Design Group
//SPDX-License-Identifier: Apache-2.0

#include "system.hpp"
#include <systemc.h>
#include <mc_scverify.h>

sc_trace_file *trace_file_ptr;

int sc_main (int argc, char *argv[])
{
    sc_report_handler::set_actions("/IEEE_Std_1666/deprecated", SC_DO_NOTHING);
    sc_report_handler::set_actions(SC_ERROR, SC_DISPLAY);

    system_t system_inst("system_t");
    trace_hierarchy(&system_inst, trace_file_ptr);

    sc_report_handler::set_actions("/IEEE_Std_1666/deprecated", SC_DO_NOTHING);
    sc_start();

    int errcnt = sc_report_handler::get_count(SC_ERROR);
    if (errcnt > 0) {
        std::cout << "Simulation FAILED\n";
    } else {
        std::cout << "Simulation PASSED\n";
    }

    return errcnt; // return 0 for passed
}

