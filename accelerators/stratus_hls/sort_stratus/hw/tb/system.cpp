// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <sstream>
#include "system.hpp"

void system_t::insertion_sort (float * value, int len)
{
	int i;
	for (i = 1; i < len; i++)
	{
		double current;
		int empty;

		current = value[i];
		empty = i;

		while (empty > 0 && current < value[empty - 1])
		{
			value[empty] = value[empty - 1];
			empty--;
		}

		value[empty] = current;
	}
}

int system_t::check_gold (float *gold, float *array, int len)
{
	int i;
	int rtn = 0;
	for (i = 1; i < len; i++)
	{
		ESP_REPORT_DEBUG("result -> 0x%08x \t gold -> 0x%08x\n", *((uint32_t *) &array[i]), *((uint32_t *) &gold[i]))
		if (array[i] != gold[i])
		{
			unsigned *elem = (unsigned *) &array[i];
			ESP_REPORT_ERROR("result -> 0x%08x \t gold -> 0x%08x\n", *((uint32_t *) &array[i]), *((uint32_t *) &gold[i]))
			rtn++;
		}
	}
	return rtn;
}


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
		conf_info_t config(SORT_LEN, SORT_BATCH);
		wait(); conf_info.write(config);
		conf_done.write(true);
	}

	ESP_REPORT_INFO("config done");

	// Compute
	{
		// Print information about begin time
		sc_time begin_time = sc_time_stamp();
		ESP_REPORT_TIME(begin_time, "BEGIN - sort");

		// Wait the termination of the accelerator
		do { wait(); } while (!acc_done.read());
		debug_info_t debug_code = debug.read();

		// Print information about end time
		sc_time end_time = sc_time_stamp();
		ESP_REPORT_TIME(end_time, "END - sort");

		esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
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
		delete vectors;
		delete gold;
		sc_stop();
	}
}

// Functions
void system_t::load_memory()
{

	//  Memory initialization:
#ifdef CADENCE
	if (esc_argc() != 3)
	{
		ESP_REPORT_INFO("usage: %s <SORT_LEN> <SORT_BATCH>\n", esc_argv()[0]);
		sc_stop();
	}

	int x;
        std::istringstream s1(esc_argv()[1]);
	if (!(s1 >> x))
	{
		ESP_REPORT_ERROR("Invalid number %s \n", esc_argv()[1]);
	}
	SORT_LEN = x;
        std::istringstream s2(esc_argv()[2]);
	if (!(s2 >> x))
	{
		ESP_REPORT_ERROR("Invalid number %s \n", esc_argv()[2]);
	}
	SORT_BATCH = x;
#else
        // esp_argv causes segfault w/ Accelera SystemC 2.3.0. Using default values instead
        SORT_LEN = 1024;
        SORT_BATCH = 16;
#endif

	ESP_REPORT_INFO("Sort %d vectors of %d float elements", SORT_BATCH, SORT_LEN);

	vectors = new float[SORT_LEN * SORT_BATCH];
	gold = new float[SORT_LEN * SORT_BATCH];

	const uint32_t ratio = DMA_WIDTH / 32;
	for (int32_t j = 0; j < SORT_BATCH; j++)
		for (uint32_t i = 0; i < SORT_LEN / ratio; i++)
			for (uint32_t k = 0; k < ratio; k++) {
				float data_fl = ((float) rand () / (float) RAND_MAX);
				uint32_t data_uint = *((uint32_t *) &data_fl);
				sc_dt::sc_bv<32> data_bv(data_uint);
				gold[SORT_LEN * j + i * ratio + k] = data_fl;
				mem[SORT_LEN * j / ratio + i].range(32 * (k + 1) - 1, 32 * k) = data_bv;
			}

	ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
	// Get results
	const uint32_t ratio = DMA_WIDTH / 32;
	for (int32_t j = 0; j < SORT_BATCH; j++)
		for (uint32_t i = 0; i < SORT_LEN / ratio; i++)
			for (uint32_t k = 0; k < ratio; k++) {
				sc_dt::sc_bv<32> data_bv = mem[SORT_LEN * j / ratio + i].range(32 * (k + 1) - 1, 32 * k);
				uint32_t data_uint = data_bv.to_uint();
				float data_fl = *((float *) &data_uint);
				vectors[SORT_LEN * j + i * ratio + k] = data_fl;
			}

	ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
	uint32_t errors = 0;

	// Compute golden output
	for (int j = 0; j < SORT_BATCH; j++)
		insertion_sort (&gold[j * SORT_LEN], SORT_LEN);

	// Check for mismatches
	for (int j = 0; j < SORT_BATCH; j++) {
		uint32_t local_errors = check_gold(&gold[j * SORT_LEN], &vectors[j * SORT_LEN], SORT_LEN);
		if (local_errors) {
			ESP_REPORT_INFO("sort[%d] faild\n", j);
		}
		errors += local_errors;
	}

	return errors;
}
