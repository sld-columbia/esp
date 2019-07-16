// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "system.hpp"

#define RESET_PERIOD (30 * CLOCK_PERIOD)

int sc_main(int argc, char *argv[])
{

#ifdef USE_STRATUS
    // Kills a Warning when using SC_CTHREADS
    // sc_report_handler::set_actions("/IEEE_Std_1666/deprecated", SC_DO_NOTHING);
    sc_report_handler::set_actions (SC_WARNING, SC_DO_NOTHING);
#endif

    system_t tb_system("tb_system");

    sc_clock	    clk("clk", CLOCK_PERIOD, SC_NS);
    sc_signal<bool> rst("rst");

    tb_system.clk(clk);
    tb_system.rst(rst);

    rst.write(false);

    sc_start(RESET_PERIOD, SC_NS);

    rst.write(true);

    sc_start();

    return 0;
}
