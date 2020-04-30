/* Copyright 2018 Columbia University, SLD Group */

#include "system.hpp"

system_t *testbench = NULL;

extern void esc_elaborate()
{
    // Creating the whole system
    testbench = new system_t("testbench");
}

extern void esc_cleanup()
{
    // Deleting the system
    delete testbench;
}

int sc_main(int argc, char *argv[])
{
    // Kills various SystemC warnings
    sc_report_handler::set_actions(SC_WARNING, SC_DO_NOTHING);

    esc_initialize(argc, argv);
    esc_elaborate();

    sc_clock clk("clk", CLOCK_PERIOD, SC_NS);
    sc_signal<bool> rst("rst");

    testbench->clk(clk);
    testbench->rst(rst);

    rst.write(false);

    sc_start(RESET_PERIOD, SC_NS);

    rst.write(true);

    sc_start();

    esc_log_pass();

    return 0;
}
