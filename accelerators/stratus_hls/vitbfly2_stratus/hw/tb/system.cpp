// Copyright (c) 2011-2023 Columbia University, System Level Design Group
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
        conf_info_t config;
        wait();
        conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - vitbfly2");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - vitbfly2");

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
    {
        sc_stop();
    }
}

// Functions
void system_t::load_memory()
{
    // Optional usage check
    // if (esc_argc() != /* argc */)
    // {
    //     ESP_REPORT_INFO("usage: %s <ARG1> <ARG2> ...\n", esc_argv()[0]);
    //     sc_stop();
    // }

    //  Memory initialization:

    ESP_REPORT_INFO("---- load memory ----");

    //  ==========================================  ^
    //  |  in/out mm0 (uint 8) [64]              |  | in/out  (64 bytes) {d_metric0}
    //  ==========================================  v
    //  ==========================================  ^
    //  |  in/out mm1 (uint 8) [64]              |  | in/out  (64 bytes) {d_metric1}
    //  ==========================================  v
    //  ==========================================  ^
    //  |  in/out pp0 (uint 8) [64]              |  | in/out  (64 bytes) {d_path0}
    //  ==========================================  v
    //  ==========================================  ^
    //  |  in/out pp1 (uint 8) [64]              |  | in/out  (64 bytes) {d_path1}
    //  ==========================================  v
    //  ==========================================  ^
    //  |  input d_brtab27_gen (uint 8) [2][32]  |  | input br_table(64 bytes)
    //  ==========================================  v
    //  ==========================================  ^
    //  |  input symbols (uint 8) [64]           |  | input symbols (64 bytes) {depunctured}
    //  ==========================================  v

    // -- Read images
    int n_membytes = 6 * 64;  // The above 6 64-byte memories
    uint8_t *theMem = (uint8_t *) calloc(n_membytes, sizeof(uint8_t));
    uint8_t *m_mm0     = &(theMem[  0]);
    uint8_t *m_mm1     = &(theMem[ 64]);
    uint8_t *m_pp0     = &(theMem[128]);
    uint8_t *m_pp1     = &(theMem[192]);
    uint8_t *m_d_brtab = &(theMem[256]);
    uint8_t *m_symbols = &(theMem[320]);

    ESP_REPORT_INFO("------------ read input data start ------------");

    int i = 0, j = 0;
    uint8_t val = 0;
    FILE *fileA = NULL;

    if((fileA = fopen(input_data_path.c_str(), "r")) == (FILE*)NULL)
    {
        ESP_REPORT_ERROR("[Err] could not open %s", input_data_path.c_str());
        fclose(fileA);
    }

    i = 0;
    fscanf(fileA, "%u,", &val);
    while(!feof(fileA))
    {
        theMem[i++] = val;
        fscanf(fileA, "%u,", &val);
    }

    fclose(fileA);

    int mem_i = 0;
    for (j = 0; j < n_membytes; j += WORDS_PER_DMA) {
        for (uint8_t k = 0; k < WORDS_PER_DMA; k++)
            mem[mem_i].range(((k + 1) << 3) - 1, k << 3) = sc_bv<8>(theMem[j + k]);
        mem_i++;
    }

    free(theMem);

    ESP_REPORT_INFO("------------ read image finish ------------");

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
    ESP_REPORT_INFO("---- validate ----");

    uint32_t errors = 0;
    int n_membytes = 4 * 64;  // This is only in/out : mm0, mm1, pp0, pp1

    // Compute golden output
    uint *imgGold = (uint32_t*)calloc(n_membytes, sizeof(uint32_t));

    // -- Read the gold image
    FILE *fileGold = NULL;
    if((fileGold = fopen(image_gold_test_path.c_str(), "r")) == (FILE*)NULL)
    {
        ESP_REPORT_ERROR("[Err] could not open %s", image_gold_test_path.c_str());
        fclose(fileGold);
    }

    ESP_REPORT_INFO("mem_image_gold_test_path: %s", image_gold_test_path.c_str());

    uint32_t i = 0;
    uint32_t val = 0;
    fscanf(fileGold, "%u,", &val);
    while(!feof(fileGold))
    {
        imgGold[i++] = val;
        fscanf(fileGold, "%u,", &val);
    }

    // Check for mismatches
    // -- Compare the output with gold image
    uint32_t mem_j = 0;
    for(uint32_t j = 0 ; j < n_membytes ; j += WORDS_PER_DMA) {
        for (uint8_t k = 0; k < WORDS_PER_DMA; k++)
            if (mem[mem_j].range(((k + 1) << 3) - 1, (k << 3)).to_int() != imgGold[j + k])
            {
                ESP_REPORT_INFO("Error: %u: %u %u.",
                                mem_j, mem[mem_j].range(((k + 1) << 3) - 1, k << 3).to_int(), imgGold[j + k]);
                errors++;
            }
        mem_j++;
    }

    ESP_REPORT_INFO("====================================================");
    if (errors)
    {
        ESP_REPORT_INFO("Errors: %d value(s) not match.", errors);
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
