// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#include <iostream>
#include <vector>
#include <sstream>
#include <fstream>
#include <stdio.h>
#include "system.hpp"

std::ofstream ofs;

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

	// Load input data
	load_memory();

	// Config
	{
		// TODO do not hardcode
		conf_info_t config(16, 16);
		wait();
		conf_info.write(config);
		conf_done.write(true);
	}

	ESP_REPORT_INFO("config done");

	// Compute
	{
		// Print information about begin time
		sc_time begin_time = sc_time_stamp();
		ESP_REPORT_TIME(begin_time, "BEGIN - visionchip");

		// Wait the termination of the accelerator
		do { wait(); } while (!acc_done.read());
		debug_info_t debug_code = debug.read();

		// Print information about end time
		sc_time end_time = sc_time_stamp();
		ESP_REPORT_TIME(end_time, "END - visionchip");

		esc_log_latency(clock_cycle(end_time - begin_time));
		wait();
		conf_done.write(false);
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
	if (esc_argc() != 1)
	{
		ESP_REPORT_INFO("usage: %s\n", esc_argv()[0]);
		sc_stop();
	}

	//  Memory initialization:
	ESP_REPORT_INFO("---- load memory ----");

	//  ===========================  ^
	//  |  in/out image (uint32)  |  | img_size (in bytes)
	//  ===========================  v

	// -- Read images
	int n_Pixels = n_Rows * n_Cols;
	int *imgA = (int*)calloc(n_Pixels, sizeof(int));

	ESP_REPORT_INFO("------------ read image start ------------");

	int i = 0;
	int val = 0;
	FILE *fileA = NULL;

	if((fileA = fopen(image_A_path.c_str(), "r")) == (FILE*)NULL)
	{
		ESP_REPORT_ERROR("[Err] could not open %s", image_A_path.c_str());
		fclose(fileA);
	}

	i = 0;
	fscanf(fileA, "%d", &val);
	while(!feof(fileA))
	{
		mem[i++] = val;
		fscanf(fileA, "%d", &val);
	}

	fclose(fileA);

	ESP_REPORT_INFO("------------ read image finish ------------");

	ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
	// ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
	ESP_REPORT_INFO("---- validate ----");

	uint32_t errors = 0;
	int n_Pixels = n_Rows * n_Cols;

	// Load golden output
	int *imgGold = (int*)calloc(n_Pixels, sizeof(int));

	// -- Read the gold image
	FILE *fileGold = NULL;
	if((fileGold = fopen(image_gold_test_path.c_str(), "r")) == (FILE*)NULL)
	{
		ESP_REPORT_ERROR("[Err] could not open %s", image_gold_test_path.c_str());
		fclose(fileGold);
	}

	ESP_REPORT_INFO("image_gold_test_path: %s", image_gold_test_path.c_str());

	uint32_t i = 0;
	int val = 0;
	fscanf(fileGold, "%d", &val);
	while(!feof(fileGold))
	{
		imgGold[i++] = val;
		fscanf(fileGold, "%d", &val);
	}

	// Check for mismatches
	// -- Compare the output with gold image
	for(uint32_t i = 0 ; i < n_Pixels ; i++)
	{
		if (mem[i].to_int() != imgGold[i])
		{
			ESP_REPORT_INFO("Error: %d %d.", mem[i].to_int(), imgGold[i])
			errors++;
		}
	}

	ESP_REPORT_INFO("====================================================");
	if (errors)
	{
		ESP_REPORT_INFO("Errors: %d pixel(s) not match.", errors)
			}
	else
	{
		ESP_REPORT_INFO("Correct!!")
			}
	ESP_REPORT_INFO("====================================================");


	fclose(fileGold);
	ESP_REPORT_INFO("Validate completed");

	return errors;
}
