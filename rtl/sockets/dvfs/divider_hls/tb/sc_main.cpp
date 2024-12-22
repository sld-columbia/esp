/* Copyright 2017 Columbia University, SLD Group */

#include "system.hpp"

#define RESET_PERIOD (30 * CLOCK_PERIOD)

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
    // Kills a Warning when using SC_CTHREADS
    // sc_report_handler::set_actions("/IEEE_Std_1666/deprecated", SC_DO_NOTHING);
    sc_report_handler::set_actions(SC_WARNING, SC_DO_NOTHING);

    esc_initialize(argc, argv);
    esc_elaborate();

    sc_clock clk("clk", CLOCK_PERIOD, SC_NS);
    sc_signal<bool> rstn("rstn");

    testbench->clk(clk);
    testbench->rstn(rstn);
    rstn.write(false);

    sc_start(RESET_PERIOD, SC_NS);

    rstn.write(true);

    sc_start();

    esc_log_pass();

    return 0;
}
