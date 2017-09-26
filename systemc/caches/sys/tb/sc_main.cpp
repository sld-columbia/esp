/* Copyright 2017 Columbia University, SLD Group */

#include "system.hpp"

#define RESET_PERIOD (30 * CLOCK_PERIOD)

system_t *tb_system = NULL;

extern void esc_elaborate()
{
	// Creating the whole system
	tb_system = new system_t("tb_system");
}

extern void esc_cleanup()
{
	// Deleting the system
	delete tb_system;
}

int sc_main(int argc, char *argv[])
{

	sc_report_handler::set_actions (SC_WARNING, SC_DO_NOTHING);
	esc_initialize(argc, argv);
	esc_elaborate();

	sc_clock	clk("clk", CLOCK_PERIOD, SC_NS);
	sc_signal<bool> rst("rst");

	tb_system->clk(clk);
	tb_system->rst(rst);

	rst.write(false);

	sc_start(RESET_PERIOD, SC_NS);

	rst.write(true);

	sc_start();

	esc_log_pass();

	return 0;
}
