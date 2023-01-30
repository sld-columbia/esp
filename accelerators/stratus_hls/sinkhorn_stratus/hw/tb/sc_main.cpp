// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "system.hpp"

#define RESET_PERIOD (30 * CLOCK_PERIOD)

system_t * testbench = NULL;

uint32_t p_rows = 229;
uint32_t q_cols = 177;
uint32_t m_rows = 3;
float gamma_sink = 1.6;
uint32_t maxiter = 10;
uint32_t p2p_in = 0;
uint32_t p2p_out = 0;
uint32_t p2p_iter = 0;
uint32_t store_state = 0;

extern void esc_elaborate()
{
    // Creating the whole system
    testbench = new system_t("testbench", p_rows, q_cols, m_rows, gamma_sink, maxiter, p2p_in, p2p_out, p2p_iter, store_state);
}

extern void esc_cleanup()
{
	// Deleting the system
	delete testbench;
}

int sc_main(int argc, char *argv[])
{
	// Kills a Warning when using SC_CTHREADS
	//sc_report_handler::set_actions("/IEEE_Std_1666/deprecated", SC_DO_NOTHING);
	sc_report_handler::set_actions (SC_WARNING, SC_DO_NOTHING);

	esc_initialize(argc, argv);
	esc_elaborate();

	sc_clock        clk("clk", CLOCK_PERIOD, SC_PS);
	sc_signal<bool> rst("rst");

	testbench->clk(clk);
	testbench->rst(rst);
	rst.write(false);

	sc_start(RESET_PERIOD, SC_PS);

	rst.write(true);

	sc_start();

	esc_log_pass();
        esc_cleanup();

	return 0;
}
