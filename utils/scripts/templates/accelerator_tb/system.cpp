// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#include <sstream>
#include "system.hpp"

// Process
void system_t::config_proc()
{

	// Reset
	{
		conf_done.write(false);
		conf_info.write(conf_info_t());
		wait();
	}

	ESP_REPORT_INFO("reset done");

	// Config
	load_memory();
	{
		conf_info_t config;
		// Custom configuration

		wait(); conf_info.write(config);
		conf_done.write(true);
	}

	ESP_REPORT_INFO("config done");

	// Compute
	{
		// Print information about begin time
		sc_time begin_time = sc_time_stamp();
		ESP_REPORT_TIME(begin_time, "BEGIN - <accelerator_name>");

		// Wait the termination of the accelerator
		do { wait(); } while (!acc_done.read());
		debug_info_t debug_code = debug.read();

		// Print information about end time
		sc_time end_time = sc_time_stamp();
		ESP_REPORT_TIME(end_time, "END - <accelerator_name>");

		esc_log_latency(clock_cycle(end_time - begin_time));
		wait(); conf_done.write(false);
	}

	// Validate
	{
		dump_memory(); // store the output in more suitable data structure if needed
		// check the results with the golden model
		if (validate())
		{
			ESP_REPORT_ERROR("validation failed!");
		} else
		{
			ESP_REPORT_INFO("validation passed!");
		}
	}

	// Conclude
	{
		sc_stop();
	}
}

// Functions
void system_t::load_memory()
{
	// Optional usage check
	if (esc_argc() != /* argc */)
	{
		ESP_REPORT_INFO("usage: %s <ARG1> <ARG2> ...\n", esc_argv()[0]);
		sc_stop();
	}

	//  Memory initialization:

	ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
	// Get results from memory

	ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
	uint32_t errors = 0;

	// Compute golden output

	// Check for mismatches

	return errors;
}
