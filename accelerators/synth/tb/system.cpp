// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

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

    init_acc_params();

    for (int acc_id = 0; acc_id < N_ACC; acc_id++) {

	send_config(acc_id);

        // Compute
	{
	    // Print information about begin time
	    sc_time begin_time = sc_time_stamp();
	    ESP_REPORT_TIME(begin_time, "BEGIN - synth");

	    // Wait the termination of the accelerator
	    do { wait(); } while (!acc_done.read());
	    debug_info_t debug_code = debug.read();

	    // Print information about end time
	    sc_time end_time = sc_time_stamp();
	    ESP_REPORT_TIME(end_time, "END - synth");

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
    }

    // Conclude
    {
	sc_stop();
    }
}

// Functions
void system_t::init_acc_params()
{
    conf_info_t conf0( 1048576, 1048576, 0, 256, 2, 2, 1, 0, 0x12345678,    1,    0, 0); 
    configs[0] = conf0;
    conf_info_t conf1( 1048576,   32768, 0, 4096, 8, 2, 0, 0, 0x12345678,   32,    0, 0);
    configs[1] = conf1;
    conf_info_t conf2( 1048576,   65536, 0, 2048, 4, 4, 0, 0, 0x12345678,   16,    0, 0);
    configs[2] = conf2;
    conf_info_t conf3( 1048576, 1048576, 0, 1024, 2, 1, 0, 0, 0x12345678,    1,    0, 0);
    configs[3] = conf3;
    conf_info_t conf4( 1048576,  131072, 0,  512, 1, 2, 1, 0, 0x12345678,    8,    0, 0);
    configs[4] = conf4;
    conf_info_t conf5( 1048576,  262144, 0,  256, 1, 4, 0, 0, 0x12345678,    4,    0, 0);
    configs[5] = conf5;
    conf_info_t conf6( 1048576,     512, 0,    4, 1, 1, 0, 1, 0x12345678, 2048, 2048, 0);
    configs[6] = conf6;
    conf_info_t conf7( 1048576,    1024, 0,    4, 1, 2, 0, 1, 0x12345678, 1024, 1024, 0);
    configs[7] = conf7;
    conf_info_t conf8( 1048576,    2048, 0,    1, 1, 4, 0, 1, 0x12345678,  512,  512, 0);
    configs[8] = conf8;
    conf_info_t conf9( 1048576,   32768, 0,    4, 1, 1, 0, 2, 0x12345678,   32,    0, 0);
    configs[9] = conf9;
    conf_info_t conf10(1048576,   65536, 2,    1, 1, 2, 0, 2, 0x12345678,    4,    0, 0);
    configs[10] = conf10;
    conf_info_t conf11(1048576,   16384, 4,    1, 1, 4, 0, 2, 0x12345678,    1,    0, 0);
    configs[11] = conf11;
}

void system_t::load_memory()
{
}

void system_t::send_config(int acc_id)
{
    conf_info_t config;
    // Custom configuration

    wait();
    conf_info.write(configs[acc_id]);
    conf_done.write(true);

    ESP_REPORT_INFO("config done");
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
