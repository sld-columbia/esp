// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <fstream>
#include <iostream>
#include <string>
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

    // Load input data

    load_memory();

    // Config
    {
	conf_info_t config(nrows, ncols, max_nonzero, mtx_len, 1024, true);
	wait();
	conf_info.write(config);
	conf_done.write(true);
    }

    // Compute
    {
	// Print information about begin time
	sc_time begin_time = sc_time_stamp();
	ESP_REPORT_TIME(begin_time, "BEGIN - spmv");

	// Wait the termination of the accelerator
	do {
	    wait();
	} while (!acc_done.read());

	debug_info_t debug_code = debug.read();

	// Print information about end time
	sc_time end_time = sc_time_stamp();
	ESP_REPORT_TIME(end_time, "END - spmv");

	esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
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
    sc_stop();
}

// Functions
void system_t::load_memory()
{
    int i = 0;
    std::string str, tok;
    FILE *fp = NULL;
    char str_tmp[4];

    // Memory allocation

    //  ===========================  ^
    //  |  vals (input)  (float)  |  | mtx_len
    //  ===========================  -
    //  |  cols (input)  (uint)   |  | mtx_len
    //  ===========================  -
    //  |  rows (input)  (uint)   |  | nrows
    //  ===========================  -
    //  |  vect (input)  (float)  |  | ncols
    //  ===========================  -
    //  |  cols (output) (float)  |  | nrows
    //  ===========================  v

    fp = fopen(IN_FILE, "r");
    if (!fp) {
    	ESP_REPORT_INFO("cannot open file.");
    	return;
    }

    // Read configuration

    fscanf(fp, "%u %u %u %u\n", &nrows, &ncols, &max_nonzero, &mtx_len); 

    // Memory position
    vals_addr = 0;
    cols_addr = mtx_len;
    rows_addr = 2 * mtx_len;
    vect_addr = nrows + 2 * mtx_len;
    out_addr  = nrows + ncols + 2 * mtx_len;

    // Read and store input arrays

    // Vals
    
    fscanf(fp, "%s\n", str_tmp); // Read separator line: %%

    for (i = 0; i < cols_addr; i++) {

    	float val;

    	fscanf(fp, "%f\n", &val);

    	mem[i] = fp2bv<FPDATA, WORD_SIZE>((FPDATA) val); // FPDATA -> sc_bv and store it
    }


    // Cols

    fscanf(fp, "%s\n", str_tmp); // Read separator line: %%

    for (; i < rows_addr; i++) {

    	uint32_t col;

    	fscanf(fp, "%u\n", &col);

    	mem[i] = sc_bv<WORD_SIZE>(col); // uint -> sc_bv and store it
    }

    // Rows

    fscanf(fp, "%s\n", str_tmp); // Read separator line: %%
    fscanf(fp, "%s\n", str_tmp); // Read 0

    for (; i < vect_addr; i++) {

    	uint32_t row;

    	fscanf(fp, "%u\n", &row);

    	mem[i] = sc_bv<WORD_SIZE>(row); // uint -> sc_bv and store it
    }

    // Vect

    fscanf(fp, "%s\n", str_tmp); // Read separator line: %%

    for (; i < out_addr; i++) {

    	float vect;

    	fscanf(fp, "%f\n", &vect);

    	mem[i] = fp2bv<FPDATA, WORD_SIZE>((FPDATA) vect);  // FPDATA -> sc_bv and store it
    }

    // Initialize output arrays

    // Out

    for (; i < out_addr + nrows; i++) {

    	mem[i] = sc_bv<WORD_SIZE>(0); // write 0 to output array
    }

    fclose(fp);
}

void system_t::dump_memory()
{

}

int system_t::validate()
{
    FILE *fp = NULL;
    uint32_t errors = 0;
    char *str_tmp[4];

    // Open output file
    fp = fopen(CHK_FILE, "r");
    if (!fp)
    	exit(EXIT_FAILURE);

    fscanf(fp, "%s\n", str_tmp); // Read separator line: %%

    for (int i = out_addr; i < out_addr + nrows; i++) {

    	float gold;

    	fscanf(fp, "%f\n", &gold);

    	float out = (float) bv2fp<FPDATA, WORD_SIZE>(mem[i]);

    	if (check_error_threshold(out, gold)) {
    	    ESP_REPORT_INFO("spmv[%d] failed. out: %f. gold: %f.\n", i, out, gold);
	    errors++;
	}
    }

    fclose(fp);

    return errors;
}

bool system_t::check_error_threshold(float out, float gold)
{
    float error;

    assert(!isinf(gold) && !isnan(gold));

    // return an error if out is Infinite or NaN
    
    if (isinf(out) || isnan(out)) { 
	ESP_REPORT_INFO("Something wrong");
	return true;
    }

    if (gold != 0)
        error = fabs((gold - out) / gold);
    else if (out != 0)
        error = fabs((out - gold) / out);
    else
	error = 0;

    if (fabs(gold) >= 1) {
	return (error > MAX_REL_ERROR);
    } else {
	return (fabs(gold - out) > MAX_ABS_ERROR);
    }
}
