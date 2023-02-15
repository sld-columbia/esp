// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "system.hpp"

#define RESET_PERIOD (30 * CLOCK_PERIOD)

system_t * testbench = NULL;

// Default settings if argv[] is not set
std::string in_path = "in.txt";
std::string gold_path = "gold.txt";

extern void esc_elaborate()
{
  // Creating the whole system
  testbench = new system_t("testbench", in_path, gold_path);
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
  // Kills Warning from FlexChannels library: no unique name assignment
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
