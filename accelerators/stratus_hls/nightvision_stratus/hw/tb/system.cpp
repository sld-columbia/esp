// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

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
        conf_info_t config(n_Images, n_Rows, n_Cols, do_dwt);
        wait();
        conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - nightvision");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - nightvision");

        esc_log_latency(sc_object::name(), clock_cycle(end_time - begin_time));
        wait();
        conf_done.write(false);
    }

    // Validate
    {
        dump_memory(); // store the output in more suitable data structure if needed

	if (do_validation) {
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
        // while(true) wait();
        sc_stop();
    }
}

// Functions
void system_t::load_memory()
{
#ifdef CADENCE
    // Optional usage check
    if (esc_argc() != 1)
    {
        ESP_REPORT_INFO("usage: %s\n", esc_argv()[0]);
        sc_stop();
    }
#endif

    //  Memory initialization:
    ESP_REPORT_INFO("---- load memory ----");

    //  ===================================  ^
    //  |  in/out image 1 (int32)         |  | img_size (in bytes)
    //  ===================================  v
    //  ===================================  ^
    //  |  in/out image 2 (int32)         |  | img_size (in bytes)
    //  ===================================  v

    //                   ...

    //  ===================================  ^
    //  |  in/out image n_Images (int32)  |  | img_size (in bytes)
    //  ===================================  v

    // -- Read images
    int n_Pixels = n_Rows * n_Cols;
    uint16_t *imgA = (uint16_t *) calloc(n_Pixels, sizeof(uint16_t));

    ESP_REPORT_INFO("------------ read image start ------------");

    int i = 0, j = 0;
    uint16_t val = 0;
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
        imgA[i++] = val;
        fscanf(fileA, "%d", &val);
    }

    fclose(fileA);

    int mem_i = 0;
    for (i = 0; i < n_Images; i++) {
        for (j = 0; j < n_Pixels; j += WORDS_PER_DMA) {
            for (uint8_t k = 0; k < WORDS_PER_DMA; k++)
                mem[mem_i].range(((k + 1) << MAX_PXL_WIDTH_LOG) - 1, k << MAX_PXL_WIDTH_LOG) =
		    sc_bv<MAX_PXL_WIDTH>(imgA[j + k]);
            mem_i++;
        }
    }

    free(imgA);

    ESP_REPORT_INFO("------------ read image finish ------------");

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    int n_Pixels = n_Rows * n_Cols;

    // -- Read the gold image
    FILE *fileOut = NULL;
    if((fileOut = fopen(image_out_path.c_str(), "w")) == (FILE*)NULL)
    {
        ESP_REPORT_ERROR("[Err] could not open %s", image_out_path.c_str());
        fclose(fileOut);
    }

    ESP_REPORT_INFO("image_out_path: %s", image_out_path.c_str());

    // Store output file
    int mem_j = 0;
    for (int i = 0; i < n_Images; i++) {
        for(uint32_t j = 0 ; j < n_Pixels ; j += WORDS_PER_DMA) {
            for (uint8_t k = 0; k < WORDS_PER_DMA; k++) {
		if (do_dwt)
		    fprintf(fileOut, "%u\n",
			    mem[mem_j].range(((k + 1) << MAX_PXL_WIDTH_LOG) - 1,
					     k << MAX_PXL_WIDTH_LOG).to_int());
		else
		    fprintf(fileOut, "%u\n",
			    mem[mem_j].range(((k + 1) << MAX_PXL_WIDTH_LOG) - 1,
					     k << MAX_PXL_WIDTH_LOG).to_uint());
	    }
            mem_j++;
        }
    }

    fclose(fileOut);

    ESP_REPORT_INFO("dump memory completed");
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
    int mem_j = 0;
    for (int i = 0; i < n_Images; i++) {
        for(uint32_t j = 0 ; j < n_Pixels ; j += WORDS_PER_DMA) {
            for (uint8_t k = 0; k < WORDS_PER_DMA; k++) {
		if (do_dwt) {
		    if (mem[mem_j].range(((k + 1) << MAX_PXL_WIDTH_LOG) - 1,
					 k << MAX_PXL_WIDTH_LOG).to_int() != imgGold[j + k])
		    {
			ESP_REPORT_INFO("Error: %d: %d %d.", mem_j,
					mem[mem_j].range(((k + 1) << MAX_PXL_WIDTH_LOG) - 1,
							 k << MAX_PXL_WIDTH_LOG).to_int(), imgGold[j + k]);
			errors++;
		    }
		} else {
		    if (mem[mem_j].range(((k + 1) << MAX_PXL_WIDTH_LOG) - 1,
					 k << MAX_PXL_WIDTH_LOG).to_uint() != imgGold[j + k])
		    {
			ESP_REPORT_INFO("Error: %d: %d %d.", mem_j,
					mem[mem_j].range(((k + 1) << MAX_PXL_WIDTH_LOG) - 1,
							 k << MAX_PXL_WIDTH_LOG).to_uint(), imgGold[j + k]);
			errors++;
		    }
		}
	    }
            mem_j++;
        }
    }

    ESP_REPORT_INFO("====================================================");
    if (errors)
    {
        ESP_REPORT_INFO("Errors: %d pixel(s) not match.", errors);
    }
    else
    {
        ESP_REPORT_INFO("Correct!!");
    }
    ESP_REPORT_INFO("====================================================");


    fclose(fileGold);
    ESP_REPORT_INFO("Validate completed");

    return errors;
}
